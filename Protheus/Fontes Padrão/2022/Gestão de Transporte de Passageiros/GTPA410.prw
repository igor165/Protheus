#INCLUDE 'GTPA410.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH' 
#INCLUDE 'FWEDITPANEL.CH'

//------------------------------------------------------------------------------  
/*/{Protheus.doc} GTPA410
Cálculo de Comissão de Agência
sample 	GTPA410()
@author		SI4503 - Marcio Martins Pereira  
@since	 	10/02/2016 
@version	P12  
@comments  
/*///------------------------------------------------------------------------------
Function GTPA410()
Local oBrowse := FWLoadBrw('GTPA410')

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
Local oBrowse       :=  FWMBrowse():New()
Local cLegRed       := "!Empty(GQ6_SIMULA)"
Local cLegYellow    := "Empty(GQ6_EXPFOL) .AND. Empty(GQ6_SIMULA) .AND. GQ6_VTCOMI > 0 .AND. Empty(GQ6_FORNEC)"
Local cLegGreen     := "!Empty(GQ6_EXPFOL) .AND. Empty(GQ6_SIMULA)"
Local cLegPink      := "Empty(GQ6_SIMULA) .AND. GQ6_VTCOMI > 0 .AND. !Empty(GQ6_FORNEC) .AND. GQ6_GERTIT .AND. Empty(GQ6_EXPFIN)"
Local cLegBlue      := "!Empty(GQ6_FORNEC) .AND. !Empty(GQ6_EXPFIN) .AND. Empty(GQ6_SIMULA)"
Local cLegWhite     := "Empty(GQ6_SIMULA) .AND. !Empty(GQ6_FORNEC) .AND. !GQ6_GERTIT"
Local cLegBlack     := "GQ6_VTCOMI <= 0"

oBrowse:SetAlias('GQ6')

oBrowse:SetDescription(STR0001) //'Cálculo de Comissão'

oBrowse:AddLegend(cLegRed    ,"RED"     , STR0002 )//"Comissão Simulada"
oBrowse:AddLegend(cLegYellow ,"YELLOW"  , STR0003 )//"Pendente de exportação com o RH"
oBrowse:AddLegend(cLegGreen  ,"GREEN"   , STR0004 )//Comissão exportada p/ o RH"
oBrowse:AddLegend(cLegPink   ,"PINK"    , STR0067 )//"Pendente de exportação p/financeiro"
oBrowse:AddLegend(cLegBlue   ,"BLUE"    , STR0005 )//"Comissão exportada p/ financeiro"
oBrowse:AddLegend(cLegWhite  ,"WHITE"   , STR0076)//"Não Gera titulo"
oBrowse:AddLegend(cLegBlack  ,"BLACK"   , STR0006 ) //"Sem valores de comissão."     

If GQ6->(FieldPos('GQ6_TPCOMI')) = 0
    oBrowse:SetFilterDefault("!Empty(GQ6_AGENCI)")
Else
    oBrowse:SetFilterDefault("GQ6_TPCOMI = '1'")
Endif

Return oBrowse
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados
@sample		ModelDef()
@return		oModel 		Objeto do Model
@author	 	SI4503 - Marcio Martins Pereira  
@since	 	10/02/2016 
@version	P12
/*///-------------------------------------------------------------------
Static Function ModelDef()
Local oModel        := nil
Local oStruGQ6      := FWFormStruct(1,"GQ6")//Cabeçalho
Local oStruGQ9      := FWFormStruct(1,"GQ9")//Itens de Venda
Local oStruGQ7      := FWFormStruct(1,"GQ7")//Tipos de Linhas
Local oStruGQ3      := FWFormStruct(1,"GQ3")//DSR 
Local oStruGZL      := FWFormStruct(1,"GZL")//Taxas
Local oStruGZMB     := FWFormStruct(1,"GZM")//Comissões x Bonificações
Local oStruGZMD     := FWFormStruct(1,"GZM")//Comissões x  Despesas
Local oStrGZO       := FWFormStruct(1,"GZO")//Processament x  NF X Titulo
Local lEncomenda    := AliasInDic('GIV') .AND. AliasInDic('GIX')
Local oStruGIV      := If(lEncomenda,FWFormStruct(1,"GIV"),nil)//Soma Encomendas 
Local oStruGIX      := If(lEncomenda,FWFormStruct(1,"GIX"),nil)//Comissões x Encomendas
Local bPosValid		:= {|oModel|GTP410TdOK(oModel)}	


oStruGQ9:SetProperty('GQ9_CODTPV'   , MODEL_FIELD_TAMANHO, TamSx3('GIC_TIPO')[1])

oStruGQ6:SetProperty('GQ6_CODIGO'   , MODEL_FIELD_INIT,{|| GtpXeNum('GQ6','GQ6_CODIGO')})
oStruGZL:SetProperty("GZL_DESCRI"	, MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,'IIF(!Empty(GZL->GZL_CODGIH),Posicione("GYA",1,xFilial("GYA")+GZL->GZL_CODGIH ,"GYA_DESCRI" ),"")') )
oStruGZMB:SetProperty("GZM_DESCRI"	, MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,'IIF(!Empty(GZM->GZM_G5KG5L),Posicione("G5K",1,xFilial("G5K")+GZM->GZM_G5KG5L ,"G5K_DESCRI" ),"")') )
oStruGZMD:SetProperty("GZM_DESCRI"	, MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,'IIF(!Empty(GZM->GZM_G5KG5L),Posicione("G5K",1,xFilial("G5K")+GZM->GZM_G5KG5L ,"G5K_DESCRI" ),"")') )
oStruGQ7:SetProperty('GQ7_CODTPV'   , MODEL_FIELD_OBRIGAT, .F.)
oStruGQ7:SetProperty('GQ7_ORIGEM'   , MODEL_FIELD_OBRIGAT, .F.)
oStruGQ3:SetProperty('GQ3_PROCES'   , MODEL_FIELD_OBRIGAT, .F.)

If oStruGQ6:HasField('GQ6_TPCOMI')
    oStruGQ6:SetProperty("GQ6_TPCOMI"	, MODEL_FIELD_INIT,{|| '1'})
Endif

oModel := MPFormModel():New('GTPA410',/*bPreValid*/, bPosValid, /*bCommit*/)

oModel:AddFields("GQ6MASTER",/*cOwner*/ ,oStruGQ6 )//Cabeçalho
oModel:AddGrid("GQ9DETAIL"  ,"GQ6MASTER",oStruGQ9 )//Tipos de Vendas
oModel:AddGrid("GQ7DETAIL"  ,"GQ9DETAIL",oStruGQ7 )//Tipos de Linhas
oModel:AddGrid("GQ3DETAIL"  ,"GQ6MASTER",oStruGQ3 )//DSR
oModel:AddGrid("GZLDETAIL"  ,"GQ6MASTER",oStruGZL )//Taxas
oModel:AddGrid("GZMBONIF"   ,"GQ6MASTER",oStruGZMB )//Bonificações
oModel:AddGrid("GZMDESCO"   ,"GQ6MASTER",oStruGZMD )//Descontos
oModel:AddGrid("GZOMASTER"  ,"GQ6MASTER",oStrGZO  )//NF x Titulo

oModel:SetRelation('GQ9DETAIL'  ,{{'GQ9_FILIAL','xFilial("GQ9")'},{'GQ9_CODGQ6','GQ6_CODIGO'},{'GQ9_SIMULA','GQ6_SIMULA'}}  ,GQ9->(IndexKey(1)))
oModel:SetRelation('GQ7DETAIL'  ,{{'GQ7_FILIAL','xFilial("GQ7")'},{'GQ7_CODGQ6','GQ6_CODIGO'},{'GQ7_SIMULA','GQ6_SIMULA'};
                                                                 ,{'GQ7_TPCALC','GQ9_TPCALC'},{'GQ7_CODTPV','GQ9_CODTPV'};
                                                                 ,{'GQ7_STATUS','GQ9_STATUS'},{'GQ7_ORIGEM','GQ9_ORIGEM'}}  ,GQ7->(IndexKey(1)))
oModel:SetRelation('GQ3DETAIL'  ,{{'GQ3_FILIAL','xFilial("GQ3")'},{'GQ3_PROCES','GQ6_CODIGO'},{'GQ3_SIMULA','GQ6_SIMULA'}}  ,GQ3->(IndexKey(1)))
oModel:SetRelation('GZLDETAIL'  ,{{'GZL_FILIAL','xFilial("GZL")'},{'GZL_CODGQ6','GQ6_CODIGO'},{'GZL_SIMULA','GQ6_SIMULA'}}  ,GZL->(IndexKey(1)))
oModel:SetRelation('GZMBONIF'   ,{{'GZM_FILIAL','xFilial("GZM")'},{'GZM_CODGQ6','GQ6_CODIGO'},{"GZM_BONDES","'1'"}}         ,GZM->(IndexKey(1)))
oModel:SetRelation('GZMDESCO'   ,{{'GZM_FILIAL','xFilial("GZM")'},{'GZM_CODGQ6','GQ6_CODIGO'},{"GZM_BONDES","'2'"}}         ,GZM->(IndexKey(1)))
oModel:SetRelation('GZOMASTER'  ,{{'GZO_FILIAL','xFilial("GZO")'},{'GZO_CODGQ6','GQ6_CODIGO'}}                              ,GZO->(IndexKey(1)))

oModel:GetModel('GQ9DETAIL' ):SetOptional( .T. )
oModel:GetModel('GQ7DETAIL' ):SetOptional( .T. )
oModel:GetModel('GQ3DETAIL' ):SetOptional( .T. )
oModel:GetModel('GZLDETAIL' ):SetOptional( .T. )
oModel:GetModel('GZMBONIF'  ):SetOptional( .T. )
oModel:GetModel('GZMDESCO'  ):SetOptional( .T. )
oModel:GetModel('GZOMASTER' ):SetOptional( .T. )

oModel:SetPrimaryKey({"GQ6_FILIAL","GQ6_CODIGO"})

oModel:SetDescription("Cálculo de Comissão de Agências")//"Cálculo de Comissão de Agências"	
oModel:GetModel('GQ9DETAIL' ):SetDescription("Tipos de Vendas"              )//"Tipos de Vendas"
oModel:GetModel('GQ7DETAIL' ):SetDescription("Tipos de Linhas"              )//"Tipos de Linhas"
oModel:GetModel('GQ3DETAIL' ):SetDescription("Descanço Semanal Remunerado"  )//"Descanço Semanal Remunerado"
oModel:GetModel('GZLDETAIL' ):SetDescription("Taxas"                        )//"Taxas"
oModel:GetModel('GZMBONIF'  ):SetDescription("Bonificações"                 )//"Bonificações"
oModel:GetModel('GZMDESCO'  ):SetDescription("Descontos"                    )//"Descontos"
oModel:GetModel('GZOMASTER' ):SetDescription("NF x Títulos"                 )//"NF x Títulos"


If lEncomenda
    
    oModel:AddGrid("GIVDETAIL"  ,"GQ6MASTER",oStruGIV  )//NF x Titulo
    oModel:SetRelation('GIVDETAIL'  ,{{'GIV_FILIAL','xFilial("GIV")'},{'GIV_CODGQ6','GQ6_CODIGO'},{'GIV_SIMULA','GQ6_SIMULA'}}  ,GIV->(IndexKey(1)))
    oModel:GetModel('GIVDETAIL'):SetOptional( .T. )
    oModel:GetModel('GIVDETAIL'):SetDescription("Encomendas"                 )//"NF x Títulos"

    oModel:AddGrid("GIXDETAIL" ,"GIVDETAIL",oStruGIX  )//NF x Titulo
    oModel:SetRelation('GIXDETAIL'  ,{{'GIX_FILIAL','xFilial("GIX")'},{'GIX_CODGQ6','GQ6_CODIGO'},{'GIX_SIMULA','GQ6_SIMULA'},{'GIX_SEQUEN','GIV_SEQUEN'}}  ,GIX->(IndexKey(1)))
    oModel:GetModel('GIXDETAIL'):SetOptional( .T. )
    oModel:GetModel('GIXDETAIL'):SetDescription("Comissões x Encomendas"                 )//"NF x Títulos"

Endif

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface 
@sample		ViewDef()
@return		oView		Retorna objeto da interface
@author	 	SI4503 - Marcio Martins Pereira  
@since	 	10/02/2016 
@version	P12
/*///-------------------------------------------------------------------
Static Function ViewDef()
Local oView		:= FWFormView():New()
Local oModel	:= FWLoadModel('GTPA410')
Local cCpos		:= "GQ6_TIPREC|GQ6_DTPREC|GQ6_VTCOMI|GQ6_VTIMPO|GQ6_VTTAXA|GQ6_VTBONF|GQ6_VTDESC|GQ6_VTVEND|GQ6_VTENCO|"
Local oStruGQ6	:= FWFormStruct(2,'GQ6',{|cCampo| !(AllTrim(cCampo) $ cCpos                                                                                 ) }) 
Local oStruGQ9	:= FWFormStruct(2,'GQ9',{|cCampo| !(AllTrim(cCampo) + '|' $ "GQ9_CODGQ6|GQ9_SIMULA|GQ9_VCANCE|"                                             ) })
Local oStruGQ7	:= FWFormStruct(2,'GQ7',{|cCampo| !(AllTrim(cCampo) + '|' $ "GQ7_CODGQ6|GQ7_SIMULA|GQ7_TPCALC|GQ7_CODTPV|GQ7_STATUS|GQ7_ORIGEM|GQ7_VCANCE|" ) })
Local oStruGQ3	:= FWFormStruct(2,'GQ3',{|cCampo| !(AllTrim(cCampo) + '|' $ "GQ3_PROCES|GQ3_SIMULA|GQ3_CODIGO|"                                             ) })
Local oStruGZL	:= FWFormStruct(2,'GZL',{|cCampo| !(AllTrim(cCampo) + '|' $ "GZL_CODGQ6|GZL_SIMULA|GZL_VLCANC|"                                             ) })
Local oStruGZMD	:= FWFormStruct(2,'GZM',{|cCampo| !(AllTrim(cCampo) + '|' $ "GZM_CODGQ6|GZM_SIMULA|GZM_BONDES|"                                             ) })
Local oStruGZMB	:= FWFormStruct(2,'GZM',{|cCampo| !(AllTrim(cCampo) + '|' $ "GZM_CODGQ6|GZM_SIMULA|GZM_BONDES|"                                             ) })
Local oStruGQ6T := FWFormStruct(2,'GQ6',{|cCampo|  (AllTrim(cCampo) + '|' $ "GQ6_VTCOMI|GQ6_VTIMPO|GQ6_VTTAXA|GQ6_VTBONF|GQ6_VTDESC|GQ6_VTVEND|GQ6_VTENCO|" ) })
Local lEncomenda:= AliasInDic('GIV') .AND. AliasInDic('GIX')
Local oStruGIV  := If(lEncomenda,FWFormStruct(2,"GIV"),nil)//Soma Encomendas 


SetViewStruct(oStruGQ6,oStruGQ9,oStruGQ7,oStruGQ3,oStruGZL,oStruGZMD,oStruGZMB,oStruGQ6T,oStruGIV)

oView:SetModel(oModel)

oView:AddField("VIEW_GQ6"   , oStruGQ6  , "GQ6MASTER"   )//cabeçalho
oView:AddGrid("VIEW_GQ9"    , oStruGQ9  , "GQ9DETAIL"   )//Tp Vendas
oView:AddGrid("VIEW_GQ7"    , oStruGQ7  , "GQ7DETAIL"   )//Tipos de Linhas
oView:AddGrid("VIEW_GQ3"    , oStruGQ3  , "GQ3DETAIL"   )//DSR
oView:AddGrid("VIEW_GZL"    , oStruGZL  , "GZLDETAIL"   )//Taxas
oView:AddGrid("VIEW_GZMB"   , oStruGZMB , "GZMBONIF"    ) //Bonificações
oView:AddGrid("VIEW_GZMD"   , oStruGZMD , "GZMDESCO"    ) //Descontos
oView:AddField("VIEW_GQ6T"  , oStruGQ6T , "GQ6MASTER"   )//Totais cabeçalho

oView:CreateHorizontalBox("BOX_GQ6"     ,20)
oView:CreateHorizontalBox("DETALHE"     ,60)
oView:CreateHorizontalBox("BOX_GQ6T"    ,20)

oView:CreateFolder("PASTAS","DETALHE" )
oView:AddSheet("PASTAS","ABAVENDAS"     ,"Bilhetes"            )//"Bilhetes"
oView:AddSheet("PASTAS","ABATAXAS"      ,STR0008               )// "Taxas"

If lEncomendas
    oView:AddSheet("PASTAS","ABAENCOMENDAS" ,"Encomendas"          )//"Encomendas"
Endif

oView:AddSheet("PASTAS","ABAVALORES"    ,"Valores Adicionais"  )//"Valores Adicionais" 
oView:AddSheet("PASTAS","ABADSR"        ,STR0007               )//"DSR" 

oView:CreateVerticalBox("BOX_GQ9"   ,050,,,"PASTAS","ABAVENDAS"    )
oView:CreateVerticalBox("BOX_GQ7"   ,050,,,"PASTAS","ABAVENDAS"    )
oView:CreateHorizontalBox("BOX_GZL" ,100,,,"PASTAS","ABATAXAS"     )
oView:CreateVerticalBox("BOX_GZMB"  ,050,,,"PASTAS","ABAVALORES"   )
oView:CreateVerticalBox("BOX_GZMD"  ,050,,,"PASTAS","ABAVALORES"   )
oView:CreateHorizontalBox("BOX_GQ3" ,100,,,"PASTAS","ABADSR"       )

oView:SetOwnerView("VIEW_GQ6"  ,"BOX_GQ6"  )//Cabeçalho
oView:SetOwnerView("VIEW_GQ9"  ,"BOX_GQ9"  )//Grid de Tipos de Vendas
oView:SetOwnerView("VIEW_GQ7"  ,"BOX_GQ7"  )//Grid de Tipos de Linhas
oView:SetOwnerView("VIEW_GQ3"  ,"BOX_GQ3"  )//Grid DSR
oView:SetOwnerView("VIEW_GZL"  ,"BOX_GZL"  )//Grid de Taxas	
oView:SetOwnerView("VIEW_GZMB" ,"BOX_GZMB" )//Grid Bonificações
oView:SetOwnerView("VIEW_GZMD" ,"BOX_GZMD" )//Grid Descontos
oView:SetOwnerView("VIEW_GQ6T" ,"BOX_GQ6T" )//Totalizadores

oView:EnableTitleView("VIEW_GQ9"  ,STR0077          )//"Tipos de Vendas"
oView:EnableTitleView("VIEW_GQ7"  ,STR0078          )//"Tipo de Linhas"
oView:EnableTitleView("VIEW_GQ6T" ,STR0011          )//"Totalizadores"
oView:EnableTitleView("VIEW_GZMB" ,"Bonificações"   )//"Bonificações"
oView:EnableTitleView("VIEW_GZMD" ,"Descontos"      )//"Descontos"

If lEncomenda

    oView:AddGrid("VIEW_GIV"    , oStruGIV  , "GIVDETAIL"   )//"Encomendas"
    oView:CreateHorizontalBox("BOX_GIV" ,100,,,"PASTAS","ABAENCOMENDAS")
    oView:SetOwnerView("VIEW_GIV" ,"BOX_GIV" )//Totalizadores
Endif

oView:SetViewProperty("VIEW_GQ6T", "SETLAYOUT", { FF_LAYOUT_HORZ_DESCR_TOP,10} )

Return oView

//------------------------------------------------------------------------------
/* /{Protheus.doc} SetViewStruct

@type Static Function
@author jacomo.fernandes
@since 09/01/2020
@version 1.0
@param , character, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Static Function SetViewStruct(oStruGQ6,oStruGQ9,oStruGQ7,oStruGQ3,oStruGZL,oStruGZMD,oStruGZMB,oStruGQ6T,oStruGIV)

If ValType(oStruGQ9) == "O"
    oStruGQ9:SetProperty('GQ9_CODTPV'   ,MVC_VIEW_COMBOBOX  , GtpxCbox('GIC_TIPO'))
Endif

If ValType(oStruGQ6T) == "O"
    oStruGQ6T:SetProperty("GQ6_VTCOMI",MVC_VIEW_ORDEM,'01')
    oStruGQ6T:SetProperty("GQ6_VTIMPO",MVC_VIEW_ORDEM,'02')
    oStruGQ6T:SetProperty("GQ6_VTTAXA",MVC_VIEW_ORDEM,'03')
    If oStruGQ6T:HasField("GQ6_VTENCO")
        oStruGQ6T:SetProperty("GQ6_VTENCO",MVC_VIEW_ORDEM,'04')
    Endif
    oStruGQ6T:SetProperty("GQ6_VTBONF",MVC_VIEW_ORDEM,'05')
    oStruGQ6T:SetProperty("GQ6_VTDESC",MVC_VIEW_ORDEM,'06')
    oStruGQ6T:SetProperty("GQ6_VTVEND",MVC_VIEW_ORDEM,'07')

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

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do Menu
@sample		MenuDef()
@return		aRotina   Array contendo as opções do Menu                                                                                                                          
@author	 	SI4503 - Marcio Martins Pereira  
@since	 	20/01/2016 
@version	P12
/*///-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

	ADD OPTION aRotina TITLE STR0066    ACTION 'VIEWDEF.GTPA410' OPERATION 2 ACCESS 0//'Visualizar'
	ADD OPTION aRotina TITLE STR0075    ACTION 'VIEWDEF.GTPA410' OPERATION 8 ACCESS 0//'Imprimir'
	ADD OPTION aRotina TITLE STR0065    ACTION 'GTPA410Proc()'   OPERATION 3 ACCESS 0//'Proc de Comissões'
	ADD OPTION aRotina TITLE STR0074    ACTION 'VIEWDEF.GTPA410' OPERATION 5 ACCESS 0//'Excluir'
	ADD OPTION aRotina TITLE STR0012    ACTION 'TP410SIMUL()'    OPERATION 3 ACCESS 0//"Transf Simulação"
	ADD OPTION aRotina TITLE STR0013	ACTION 'TP410RH()'       OPERATION 3 ACCESS 0//'Exportação Folha Pgto.'
	ADD OPTION aRotina TITLE STR0014	ACTION 'TP410FIN()'      OPERATION 3 ACCESS 0//'Exportação Financeiro'
	
Return aRotina

//------------------------------------------------------------------------------
/* /{Protheus.doc} GTPA410Proc
Função responsavel pelo Calculo da Comissão
@type Function
@author jacomo.fernandes
@since 30/12/2019
@version 1.0
/*/
//------------------------------------------------------------------------------
Function GTPA410Proc()
Local cAgeIni 	:= ''
Local cAgeFim 	:= ''
Local dDataIni	:= ''
Local dDataFim	:= ''
Local cFormula	:= ''

If Pergunte('GTPA410A',.T.)

	cAgeIni 	:= MV_PAR01
	cAgeFim 	:= MV_PAR02
	dDataIni	:= MV_PAR03
	dDataFim	:= MV_PAR04
	cFormula	:= MV_PAR05

    //Verifica se para o período informado existem comissões calculadas.
    FWMsgRun( ,{|| TP410SIMUL( .F. )}, STR0084, STR0085) // "Comissões calculadas anteriormente", "Aguarde...Verificando se existem comissões pendentes para o mesmo periodo, caso existam as mesmas serão transformadas em simulação."

    FwMsgRun(,{|oSay| ProcComissao(oSay, cAgeIni, cAgeFim, dDataIni, dDataFim, cFormula)}, STR0082, STR0085) // "Processo de Comissão","Inicializando o processamento..."
Else
    FwAlertInfo(STR0086, STR0087) // "Processo Abortado pelo usuário","Atenção!!"
Endif

Return

//------------------------------------------------------------------------------
/* /{Protheus.doc} ProcComissao

@type Static Function
@author jacomo.fernandes
@since 30/12/2019
@version 1.0
@param oSay, Object, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Static Function ProcComissao(oSay, cAgeIni, cAgeFim, dDataIni, dDataFim, cFormula, cNumFch, lOnlyCalc)
Local oModel        := Nil
Local oMdlGQ6       := Nil
Local aFormula      := {}
Local cTmpAgencia   := "" 
Local lEncomenda    := AliasInDic('GIV') .AND. AliasInDic('GIX')
Local nTotReg       := 0
Local nCount        := 0
Local nVlrCom		:= 0
Local lCalcFicha	:= .F.

Default lOnlyCalc	:= .F.
Default cNumFch		:= ''

Static lSay

lCalcFicha := !Empty(cNumFch)

lSay := ValType(oSay) == "O" .and. !IsBlind()

//Atualizando tamanho do objeto de processamento
IF lSay
    oSay:nHeight := 50
    oSay:oParent:nHeight := 130
    oSay:CoorsUpdate()
Endif

//Carrega a formula cadastrada
if !VldFormula(cFormula,aFormula) 
    Return
EndIf

cTmpAgencia := GetListAge(oSay,cAgeIni,cAgeFim,lCalcFicha)

nTotReg := (cTmpAgencia)->(ScopeCount())

(cTmpAgencia)->(DbGoTop())

If (cTmpAgencia)->(!Eof())
    oModel := FwLoadModel('GTPA410')
    oModel:SetOperation(MODEL_OPERATION_INSERT)
    
    oMdlGQ6 := oModel:GetModel('GQ6MASTER')

    While (cTmpAgencia)->(!Eof())
        nCount++
        SetSayText(oSay,I18n("Realizando o calculo das Agências #1/#2",{nCount,nTotReg}) )

        If oModel:Activate()
            oMdlGQ6:SetValue('GQ6_CODIGO', GtpXeNum('GQ6','GQ6_CODIGO') )
            oMdlGQ6:SetValue('GQ6_AGENCI', (cTmpAgencia)->G5D_AGENCI )
            oMdlGQ6:SetValue('GQ6_DATADE', dDataIni)
            oMdlGQ6:SetValue('GQ6_DATATE', dDataFim)
            oMdlGQ6:SetValue('GQ6_FORMUL', cFormula)        
            oMdlGQ6:SetValue('GQ6_CODG5D', (cTmpAgencia)->G5D_CODIGO)
            oMdlGQ6:SetValue('GQ6_FORNEC', (cTmpAgencia)->GI6_FORNEC    )
            oMdlGQ6:SetValue('GQ6_LOJA'  , (cTmpAgencia)->GI6_LOJA      )
            oMdlGQ6:SetValue('GQ6_GERTIT', (cTmpAgencia)->G5D_GERTIT    )
            
			If GQ6->(FieldPos('GQ6_NUMFCH')) > 0 .And. !Empty(cNumFch)
				oMdlGQ6:SetValue('GQ6_NUMFCH', cNumFch)
			Endif

            If (cTmpAgencia)->GI6_TIPO == '1' // nao gravar cod. colaborador quando for agencia terceirizada
                oMdlGQ6:SetValue('GQ6_CODCOL', (cTmpAgencia)->GI6_COLRSP)
            Endif
            
            //Preenche a comissão com os Dados dos Bilhetes
            SetBilhetes(oSay,oModel,aFormula,lCalcFicha)

            //Preenche a comissão com os Dados das Taxas
            SetTaxas(oSay,oModel,aFormula,lCalcFicha)

            //Preenche a comissão com os Dados das Encomendas
            If lEncomenda
                SetEncomendas(oSay,oModel,aFormula)
            Endif

            //Preenche a comissão com os Dados de Bonificação e Desconto, 
            //só acrecentará valor adicional se tiver algo de comissão
            If oMdlGQ6:GetValue('GQ6_VTCOMI') > 0
                SetVlrAdc(oSay,oModel,aFormula)
            Endif

            //Caso a Agencia seja própria, paga DSR, a matricula esteja preenchida e o valor de comissão não for zerado.
            //Preenche a comissão com os Dados de DSR
            If (cTmpAgencia)->GI6_DSR .AND. (cTmpAgencia)->GI6_TIPO == '1' ;
                .AND. !Empty((cTmpAgencia)->GYG_FUNCIO) .AND. oMdlGQ6:GetValue('GQ6_VTCOMI') > 0
                SetDSR(oSay,oModel,aFormula)
            Endif

            If oMdlGQ6:GetValue('GQ6_VTCOMI') > 0 

				nVlrcom := oMdlGQ6:GetValue('GQ6_VTCOMI')

				If  !(lOnlyCalc)

					If !(oModel:VldData() .and. oModel:CommitData())
						lRet := .F.
					Endif

				Endif

            Endif

        Endif

        oModel:DeActivate()
        (cTmpAgencia)->(DbSkip())

    End
    
    oModel:Destroy()

Endif

(cTmpAgencia)->(DbCloseArea())


GtpDestroy(oModel)

Return nVlrCom

//------------------------------------------------------------------------------
/* /{Protheus.doc} GetListAge
Função responsavel para buscar os dados de Comissão da Agencia
@type Static Function
@author jacomo.fernandes
@since 30/12/2019
@version 1.0
@param cAgeIni, character, (Descrição do parâmetro)
@param cAgeFim, character, (Descrição do parâmetro)
@return cTmpAgencia, return_description
/*/
//------------------------------------------------------------------------------
Static Function GetListAge(oSay,cAgeIni,cAgeFim,lCalcFicha)
Local cTmpAgencia   := GetNextAlias()
Local cQryFch		:= ''

If GI6->(FieldPos('GI6_COMFCH')) > 0 .And. !lCalcFicha
	cQryFch := " AND GI6.GI6_COMFCH <> '1' "
Endif

cQryFch := '%' + cQryFch + '%'

SetSayText(oSay,"Buscando Lista de Agencia...")

BeginSql Alias cTmpAgencia
    Column G5D_GERTIT as Logical
    Column GI6_DSR as Logical
    Select
        G5D.G5D_CODIGO, 
        G5D.G5D_AGENCI, 
        GI6.GI6_TIPO,
        G5D.G5D_GERTIT,
        GI6.GI6_COLRSP,
        GYG.GYG_FUNCIO,
        GI6.GI6_FORNEC, 
        GI6.GI6_LOJA, 
        GI6.GI6_DSR
    From %Table:G5D% G5D
        Inner Join %Table:GI6% GI6 ON
            GI6.GI6_FILIAL = %xFilial:GI6%
            AND GI6.GI6_CODIGO = G5D.G5D_AGENCI
			%Exp:cQryFch%
            AND GI6.%NotDel%
        Left Join %Table:GYG% GYG ON
            GYG.GYG_FILIAL = %xFilial:GYG%
            AND GYG.GYG_CODIGO = GI6.GI6_COLRSP
            AND GYG.%NotDel%
    Where
        G5D.G5D_FILIAL = %xFilial:G5D%
        AND G5D.G5D_STATUS = '2'
        AND G5D.G5D_AGENCI BETWEEN %Exp:cAgeIni% AND %Exp:cAgeFim%
        AND G5D.%NotDel%
EndSql

Return cTmpAgencia

//------------------------------------------------------------------------------
/* /{Protheus.doc} SetBilhetes

@type Static Function
@author jacomo.fernandes
@since 30/12/2019
@version 1.0
@param , character, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Static Function SetBilhetes(oSay,oModel,aFormula,lCalcFicha)
Local oMdlGQ6    := oModel:GetModel("GQ6MASTER") //Cabeçalho
Local oMdlGQ9    := oModel:GetModel("GQ9DETAIL") //Tipos de Venda
Local oMdlGQ7    := oModel:GetModel("GQ7DETAIL") //Tipos de Linha
Local cTmpGQ4    := GetTmpGQ4(oMdlGQ6,lCalcFicha)
Local lQtdBil    := GQ9->(FieldPos('GQ9_QTDBIL')) .And. GQ7->(FieldPos('GQ7_QTDBIL')) 

Local cTpCalc    := ""
Local cTpVenda   := ""
Local cStatus    := ""
Local cOrigem    := ""
Local cTpLinha   := ""
Local cAuxVar    := ""
Local nComissao  := 0
Local nImposto   := 0
Local nQtd       := 0
Local nVlrTotal  := 0
Local nVlrImpost := 0
Local nVlrComiss := 0

Local nTotVenda  := oMdlGQ6:GetValue('GQ6_VTVEND')
Local nTotImpos  := oMdlGQ6:GetValue('GQ6_VTIMPO')
Local nTotComis  := oMdlGQ6:GetValue('GQ6_VTCOMI')

Default lCalcFicha := .F.

SetSayText(oSay,"Calculando comissões de bilhetes...",.T. )

While (cTmpGQ4)->(!Eof())

    cTpCalc    := (cTmpGQ4)->GQ4_TPCALC
    cTpVenda   := (cTmpGQ4)->GQ4_TPVEND
    cStatus    := (cTmpGQ4)->GQ4_STATUS
    cOrigem    := (cTmpGQ4)->GQ4_ORIGEM
    cTpLinha   := (cTmpGQ4)->G5E_CODGQC
    nComissao  := (cTmpGQ4)->COMISSAO 
    nImposto   := (cTmpGQ4)->IMPOSTO
    nVlrTotal  := (cTmpGQ4)->VALORTOTAL
    nQtd       := (cTmpGQ4)->QTD
    nVlrImpost := Round( (nVlrTotal*nImposto)/100   ,2)
    nVlrComiss := Round( ((nVlrTotal-nVlrImpost)*nComissao)/100   ,2)

    If cTpVenda == "C" .or. cTpVenda == "D" 
        nVlrTotal  := nVlrTotal * (-1)
        nVlrImpost := nVlrImpost* (-1)
        nVlrComiss := nVlrComiss* (-1)
    Endif

	If cAuxVar != (cTmpGQ4)->GQ4_TPCALC+(cTmpGQ4)->GQ4_TPVEND+(cTmpGQ4)->GQ4_STATUS+(cTmpGQ4)->GQ4_ORIGEM
		If !oMdlGQ9:SeekLine({ {"GQ9_TPCALC",cTpCalc},{"GQ9_CODTPV",Padr(cTpVenda,TamSx3('GQ9_CODTPV')[1])},;
                            {"GQ9_STATUS",cStatus},{"GQ9_ORIGEM",cOrigem}})
			cAuxVar := (cTmpGQ4)->GQ4_TPCALC+(cTmpGQ4)->GQ4_TPVEND+(cTmpGQ4)->GQ4_STATUS+(cTmpGQ4)->GQ4_ORIGEM      
			If !Empty(oMdlGQ9:GetValue("GQ9_CODTPV"))
				oMdlGQ9:AddLine()
			Endif
			oMdlGQ9:SetValue('GQ9_TPCALC',cTpCalc   )
			oMdlGQ9:SetValue('GQ9_CODTPV',cTpVenda  )
			oMdlGQ9:SetValue('GQ9_STATUS',cStatus   )
			oMdlGQ9:SetValue('GQ9_ORIGEM',cOrigem   )
			If lQtdBil
				oMdlGQ9:SetValue('GQ9_QTDBIL',nQtd  )
			Endif
			
		Endif
	EndIf

    

    If cTpCalc <> '1' //Por Venda
        oMdlGQ9:SetValue('GQ9_PCOMIS',nComissao     )
        oMdlGQ9:SetValue('GQ9_PIMPOS',nImposto      )
        oMdlGQ9:SetValue('GQ9_VALTOT',nVlrTotal     )
        oMdlGQ9:SetValue('GQ9_VIMPOS',nVlrImpost    )
        oMdlGQ9:SetValue('GQ9_VCOMIS',nVlrComiss    )
        
    Else //Por tipo de Linha

        If !oMdlGQ7:SeekLine({ {"GQ7_CODGQC",cTpLinha}}) 
            If !Empty(oMdlGQ7:GetValue("GQ7_CODGQC"))
            	oMdlGQ7:AddLine()
			Endif
        Endif 

        oMdlGQ7:SetValue('GQ7_CODGQC',cTpLinha      )
        oMdlGQ7:SetValue('GQ7_PCOMIS',nComissao     )
        oMdlGQ7:SetValue('GQ7_PIMPOS',nImposto      )
        oMdlGQ7:SetValue('GQ7_VALTOT',nVlrTotal     )
        oMdlGQ7:SetValue('GQ7_VIMPOS',nVlrImpost    )
        oMdlGQ7:SetValue('GQ7_VCOMIS',nVlrComiss    )
        If lQtdBil
            oMdlGQ7:SetValue('GQ7_QTDBIL',nQtd      )
        Endif
    Endif

    nTotVenda += nVlrTotal
    nTotImpos += nVlrImpost
    nTotComis += nVlrComiss

    (cTmpGQ4)->(DbSkip())
End
(cTmpGQ4)->(DbCloseArea())

oMdlGQ6:SetValue('GQ6_VTVEND', nTotVenda )
oMdlGQ6:SetValue('GQ6_VTCOMI', nTotComis )
oMdlGQ6:SetValue('GQ6_VTIMPO', nTotImpos )


Return 

//------------------------------------------------------------------------------
/* /{Protheus.doc} GetTmpGQ4

@type Static Function
@author jacomo.fernandes
@since 30/12/2019
@version 1.0
@param cCodG5D, character, (Descrição do parâmetro)
@return cTmpGQ4, return_description
/*/
//------------------------------------------------------------------------------
Static Function GetTmpGQ4(oMdlGQ6, lCalcFicha)
Local cTmpGQ4   := GetNextAlias()
Local cCodG5D   := oMdlGQ6:GetValue('GQ6_CODG5D')
Local cCodAge   := oMdlGQ6:GetValue('GQ6_AGENCI')
Local dDtIni    := oMdlGQ6:GetValue('GQ6_DATADE')
Local dDtFim    := oMdlGQ6:GetValue('GQ6_DATATE')
Local cQryConf	:= ''

Default lCalcFicha := .F.

If !(lCalcFicha)
	cQryConf := " AND GIC_CONFER = '2' "
Endif

cQryConf := "%" + cQryConf + "%"

BeginSql Alias cTmpGQ4
        
    Select 
        GQ4.GQ4_TPCALC,
        GQ4.GQ4_TPVEND,
        GQ4.GQ4_STATUS,
        GQ4.GQ4_ORIGEM,
        IsNull(G5E_CODGQC,'') As G5E_CODGQC,
        IsNull(G5E_IMPOST,GQ4_IMPOST) As IMPOSTO,
        IsNull(G5E_COMISS,GQ4_COMISS) As COMISSAO,
        Count(GIC.GIC_CODIGO) As QTD,
        Sum( 
            Case
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
            End
        ) As VALORTOTAL
    From %Table:GQ4% GQ4
        LEFT JOIN %Table:G5E% G5E ON
            G5E.G5E_FILIAL = GQ4.GQ4_FILIAL
            AND G5E.G5E_CODG5D = GQ4.GQ4_CODG5D
            AND G5E.G5E_CODGQ4 = GQ4.GQ4_TPVEND
            AND G5E.G5E_TPCALC = GQ4.GQ4_TPCALC
            AND G5E.G5E_ORIGEM = GQ4.GQ4_ORIGEM
            AND G5E.G5E_STATUS = GQ4.GQ4_STATUS
            AND G5E.%NotDel%
        Inner Join %Table:GIC% GIC on
            GIC.GIC_FILIAL = %xFilial:GIC%
            AND GIC.GIC_AGENCI = %Exp:cCodAge%
            AND GIC.GIC_DTVEND BETWEEN %Exp:dDtIni% AND  %Exp:dDtFim%
		    AND GIC.GIC_TIPO = GQ4.GQ4_TPVEND
            AND GIC.GIC_STATUS = GQ4.GQ4_STATUS
            AND GIC.GIC_ORIGEM = GQ4.GQ4_ORIGEM
			%Exp:cQryConf%
            AND GIC.%NotDel%
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
    Group By 
        GQ4.GQ4_TPCALC,
        GQ4.GQ4_TPVEND,
        GQ4.GQ4_STATUS,
        GQ4.GQ4_ORIGEM,
        IsNull(G5E_CODGQC,''),
        IsNull(G5E_IMPOST,GQ4_IMPOST),
        IsNull(G5E_COMISS,GQ4_COMISS)
    Order By GQ4.GQ4_TPCALC,GQ4.GQ4_TPVEND,GQ4.GQ4_STATUS,GQ4.GQ4_ORIGEM,G5E_CODGQC

EndSql

Return cTmpGQ4


//------------------------------------------------------------------------------
/* /{Protheus.doc} SetTaxas

@type Static Function
@author jacomo.fernandes
@since 30/12/2019
@version 1.0
@param , character, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Static Function SetTaxas(oSay,oModel,aFormula,lCalcFicha)
Local oMdlGQ6    := oModel:GetModel("GQ6MASTER") //Cabeçalho
Local oMdlGZL    := oModel:GetModel("GZLDETAIL") //Taxas
Local cTmpGIH    := GetTmpGIH(oMdlGQ6, lCalcFicha)

Local lQtdTaxa   := GZL->(FieldPos('GZL_QTDTXA'))

Local cTpDoc     := ""
Local nComissao  := 0
Local nImposto   := 0
Local nQtd       := 0
Local nVlrTotal  := 0
Local nVlrImpost := 0
Local nVlrComiss := 0

Local nTotVenda  := 0
Local nTotImpos  := 0
Local nTotComis  := 0

SetSayText(oSay,"Calculando comissões de taxas...",.T. )

While (cTmpGIH)->(!Eof())
    If !Empty(oMdlGZL:GetValue("GZL_CODGIH")) 
        oMdlGZL:AddLine()
    EndIf

    cTpDoc     := (cTmpGIH)->GIH_CODGYA
    nComissao  := (cTmpGIH)->GIH_COMISS
    nImposto   := (cTmpGIH)->GIH_IMPOST
    nQtd       := (cTmpGIH)->QTD
    nVlrTotal  := (cTmpGIH)->VALORTOTAL
    nVlrImpost := Round((nVlrTotal*nImposto )/100 ,2)
    nVlrComiss := Round(((nVlrTotal-nVlrImpost)*nComissao )/100 ,2)


    nTotVenda += nVlrTotal
    nTotImpos += nVlrImpost
    nTotComis += nVlrComiss

    oMdlGZL:SetValue('GZL_CODGIH',cTpDoc     )
    oMdlGZL:SetValue('GZL_PCOMIS',nComissao  )
    oMdlGZL:SetValue('GZL_PIMPOS',nImposto   )
    oMdlGZL:SetValue('GZL_VLRTOT',nVlrTotal  )
    oMdlGZL:SetValue('GZL_VLIMPO',nVlrImpost )
    oMdlGZL:SetValue('GZL_VLCOMI',nVlrComiss )
    
    If lQtdTaxa
        oMdlGZL:SetValue('GZL_QTDTXA',nQtd   )
    Endif

    (cTmpGIH)->(DbSkip())
End

(cTmpGIH)->(DbCloseArea())


oMdlGQ6:SetValue('GQ6_VTTAXA', oMdlGQ6:GetValue('GQ6_VTTAXA') + nTotVenda )
oMdlGQ6:SetValue('GQ6_VTCOMI', oMdlGQ6:GetValue('GQ6_VTCOMI') + nTotComis )
oMdlGQ6:SetValue('GQ6_VTIMPO', oMdlGQ6:GetValue('GQ6_VTIMPO') + nTotImpos )


Return


//------------------------------------------------------------------------------
/* /{Protheus.doc} GetTmpGIH

@type Static Function
@author jacomo.fernandes
@since 30/12/2019
@version 1.0
@param cCodG5D, character, (Descrição do parâmetro)
@return cTmpGIH, return_description
/*/
//------------------------------------------------------------------------------
Static Function GetTmpGIH(oMdlGQ6, lCalcFicha)
Local cTmpGIH   := GetNextAlias()
Local cCodG5D   := oMdlGQ6:GetValue('GQ6_CODG5D')
Local cCodAge   := oMdlGQ6:GetValue('GQ6_AGENCI')
Local dDtIni    := oMdlGQ6:GetValue('GQ6_DATADE')
Local dDtFim    := oMdlGQ6:GetValue('GQ6_DATATE')
Local cQryConf  := ''

Default lCalcFicha := .F.

If !(lCalcFicha)
	cQryConf := " AND G57_CONFER = '2' "
Endif

cQryConf := "%" + cQryConf + "%"

BeginSql Alias cTmpGIH
    Select 
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
        INNER JOIN %Table:G57% G57 ON	
            G57.G57_FILIAL = %xFilial:G57%
            AND G57.G57_TIPO = GIH.GIH_CODGYA
			%Exp:cQryConf%
            AND G57.G57_AGENCI = %Exp:cCodAge%
            AND G57.G57_EMISSA BETWEEN %Exp:dDtIni% AND %Exp:dDtFim%
            AND G57.%NotDel%
    WHERE
        GIH.GIH_FILIAL = %xFilial:GIH%
        AND GIH.GIH_CODG5D = %Exp:cCodG5D%
        AND GIH.%NotDel%
    GROUP BY 
        GIH.GIH_CODGYA, 
        GIH.GIH_COMISS, 
        GIH.GIH_IMPOST

EndSql

Return cTmpGIH


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
Static Function SetEncomendas(oSay,oModel,aFormula)
Local oMdlGQ6    := oModel:GetModel("GQ6MASTER") //Cabeçalho
Local oMdlGIV    := oModel:GetModel("GIVDETAIL") //Soma Encomendas
Local oMdlGIX    := oModel:GetModel("GIXDETAIL") //Comissão x Encomendas
Local cTmpGIU    := GetTmpGIU(oMdlGQ6)

Local nVlrImpost := 0
Local nVlrComiss := 0
Local nQtd       := 0

SetSayText(oSay,"Calculando comissões de encomendas...",.T. )

While (cTmpGIU)->(!Eof())


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


	oMdlGQ6:SetValue('GQ6_VTENCO'	, oMdlGQ6:GetValue('GQ6_VTENCO')+(cTmpGIU)->GIY_VALOR	)
	oMdlGQ6:SetValue('GQ6_VTCOMI'	, oMdlGQ6:GetValue('GQ6_VTCOMI')+nVlrComiss 			)
	oMdlGQ6:SetValue('GQ6_VTIMPO'	, oMdlGQ6:GetValue('GQ6_VTIMPO')+nVlrImpost 			)

    (cTmpGIU)->(DbSkip())
End

(cTmpGIU)->(DbCloseArea())



Return 

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
Local cCodGI6	:= oMdlGQ6:GetValue('GQ6_AGENCI')

BeginSql Alias cTmpGiu

    Select 
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
		INNER JOIN %Table:G99% G99 ON
			G99.G99_FILIAL = %xFilial:G99%
			AND G99.G99_STATRA  = '2'
			AND G99.G99_TIPCTE <> '2'
			AND G99.G99_COMPLM <> 'I'
			AND G99.%NotDel%
			AND G99.G99_CODEMI = (Case GIU.GIU_ACAO
									When '1' then %Exp:cCodGI6%
									Else G99.G99_CODEMI 	
								End)
			AND G99.G99_CODREC = (Case GIU.GIU_ACAO
									When '2' then %Exp:cCodGI6%
									Else G99.G99_CODREC 
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
			AND G9Q.G9Q_AGEDES = (Case GIU.GIU_ACAO
									When '3' then %Exp:cCodGI6%
									Else G9Q.G9Q_AGEDES
								End)
			AND G9Q.G9Q_STAENC = (Case 
									When GIU.GIU_ACAO = '3' and G9Q_STAENC in ('3','4') 
										then G9Q_STAENC
									When GIU.GIU_ACAO = '3' and G9Q_STAENC not in ('3','4') 
										then ''
									Else G9Q_STAENC
								End)
			AND G9Q.%NotDel%
		LEFT JOIN (
                Select
                    GIV.GIV_TOMADO,
                    GIV_ACAO,
                    GIV_TPCOBR,
                    GIX_CODG99,
                    GIX_CODGIR,
                    GIX_CODGIY
                From %Table:GQ6% GQ6
                    INNER JOIN %Table:GIV% GIV ON
                        GIV.GIV_FILIAL = GQ6.GQ6_FILIAL
                        AND GIV_CODGQ6 = GQ6.GQ6_CODIGO
                        AND GIV_SIMULA = GQ6.GQ6_SIMULA
                        AND GIV.%NotDel%
                    INNER JOIN %Table:GIX% GIX ON
                        GIX.GIX_FILIAL = GQ6.GQ6_FILIAL
                        AND GIX.GIX_CODGQ6 = GIV.GIV_CODGQ6
                        AND GIX.GIX_SEQUEN = GIV.GIV_SEQUEN
                        AND GIX.%NotDel%
                Where
                    GQ6.GQ6_FILIAL = %xFilial:GQ6%
                    AND GQ6.GQ6_AGENCI = %Exp:cCodGI6%
                    AND GQ6.GQ6_SIMULA = %Exp:Space(TamSx3('GQ6_SIMULA')[1])%
                    AND GQ6.%NotDel%
        ) TMP ON
       		TMP.GIV_TOMADO = GIU.GIU_TOMADO
			and TMP.GIV_ACAO = GIU.GIU_ACAO
			AND TMP.GIV_TPCOBR = GIU.GIU_TPCOBR
            AND TMP.GIX_CODG99 = G99.G99_CODIGO
			AND TMP.GIX_CODGIR = GIR.GIR_SEQ
			AND TMP.GIX_CODGIY = GIY.GIY_IDORIG

	Where
		GIU_FILIAL = %xFilial:GIU%
		AND GIU_CODG5D = %Exp:cCodG5D%
		AND GIU.GIU_MSBLQL = '2'
		AND GIU.%NotDel%
        AND TMP.GIX_CODGIY IS NULL
EndSql

Return cTmpGiu

//------------------------------------------------------------------------------
/* /{Protheus.doc} SetVlrAdc

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
Static Function SetVlrAdc(oSay,oModel,aFormula)
Local oMdlGQ6    := oModel:GetModel("GQ6MASTER") //Cabeçalho
Local oMdlGZM    := nil //Valores Adicionais (bonificação/Desconto)
Local cMdlGZM    := ""
Local cTmpG5L    := GetTmpG5L(oMdlGQ6)

Local nBonific   := 0
Local nDesconto  := 0

Local nTotComis  := 0

SetSayText(oSay,"Calculando comissões de valores Adicionais...",.T. )

While (cTmpG5L)->(!Eof())
    
    If (cTmpG5L)->G5L_BONDES == "1"
        cMdlGZM     := "GZMBONIF"
        nBonific    += (cTmpG5L)->G5L_VALOR
        nTotComis   += (cTmpG5L)->G5L_VALOR
    Else
        cMdlGZM     := "GZMDESCO"
        nDesconto   += (cTmpG5L)->G5L_VALOR
        nTotComis   -= (cTmpG5L)->G5L_VALOR
    Endif

    oMdlGZM := oModel:GetModel(cMdlGZM)

    If !Empty(oMdlGZM:GetValue("GZM_G5KG5L")) 
        oMdlGZM:AddLine()
    EndIf

    oMdlGZM:SetValue('GZM_G5KG5L'  ,(cTmpG5L)->G5L_TIPO    )
	oMdlGZM:SetValue('GZM_BONDES'  ,(cTmpG5L)->G5L_BONDES  )
	oMdlGZM:SetValue('GZM_VALOR'   ,(cTmpG5L)->G5L_VALOR   )
    
    (cTmpG5L)->(DbSkip())
End

(cTmpG5L)->(DbCloseArea())

oMdlGQ6:SetValue('GQ6_VTBONF', oMdlGQ6:GetValue('GQ6_VTBONF') + nBonific )
oMdlGQ6:SetValue('GQ6_VTDESC', oMdlGQ6:GetValue('GQ6_VTDESC') + nDesconto )
oMdlGQ6:SetValue('GQ6_VTCOMI', oMdlGQ6:GetValue('GQ6_VTCOMI') + nTotComis )

Return 


//------------------------------------------------------------------------------
/* /{Protheus.doc} GetTmpG5L

@type Static Function
@author jacomo.fernandes
@since 02/01/2020
@version 1.0
@param oMdlGQ6, object, (Descrição do parâmetro)
@return cTmpG5L, return_description
/*/
//------------------------------------------------------------------------------
Static Function GetTmpG5L(oMdlGQ6)
Local cTmpG5L   := GetNextAlias()
Local cCodG5D   := oMdlGQ6:GetValue('GQ6_CODG5D')
Local cCodAge   := oMdlGQ6:GetValue('GQ6_AGENCI')


BeginSql Alias cTmpG5L
    SELECT 
        G5L.G5L_TIPO,
        G5L.G5L_BONDES,
        G5L.G5L_VALOR
    FROM %Table:G5L% G5L
    WHERE 
        G5L.G5L_FILIAL = %xFilial:G5L%
        AND G5L.G5L_CODIGO = %exp:cCodG5D%
        AND G5L.G5L_AGENCI = %exp:cCodAge%
        AND G5L.%NotDel%
    ORDER BY G5L.G5L_BONDES,G5L.G5L_TIPO
EndSql


Return cTmpG5L

//------------------------------------------------------------------------------
/* /{Protheus.doc} SetDSR

@type Static Function
@author jacomo.fernandes
@since 02/01/2020
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
/*/
//------------------------------------------------------------------------------
Static Function SetDSR(oSay,oModel,aFormula)
Local oMdlGQ6   := oModel:GetModel("GQ6MASTER") //Cabeçalho
Local oMdlGQ3   := oModel:GetModel("GQ3DETAIL") //DSR

Local cAgencia  := oMdlGQ6:GetValue('GQ6_AGENCI')
Local cColRsp   := oMdlGQ6:GetValue('GQ6_CODCOL')
Local cFilSRA   := Posicione('GYG',1,xFilial('GYG')+cColRsp,"GYG_FILSRA")
Local cMatric   := Posicione('GYG',1,xFilial('GYG')+cColRsp,"GYG_FUNCIO")
Local dDtIni    := oMdlGQ6:GetValue('GQ6_DATADE')
Local dDtFim    := oMdlGQ6:GetValue('GQ6_DATATE')
Local nTtComis  := oMdlGQ6:GetValue('GQ6_VTCOMI')

Local dFerIni   := Stod("")
Local dFerFim   := Stod("")
Local nDiasUt   := 0
Local nFeriados := 0
Local nDsr      := 0
Local nVlrDSR   := 0

Local nDiasTot  := dDtFim - dDtIni
Local dDtAux    := dDtIni

SetSayText(oSay,"Calculando comissões de DSR...",.T. )

While dDtAux <= dDtFim

    //Verifica se o Colaborador está de Férias
    If Ga409xColFer(cFilSRA,cMatric,dDtAux)
        If Empty(dFerIni)
            dFerIni := dDtAux
        Endif
        dFerFim := dDtAux
    Else
        //Verifica se o dia é um feriado
        If GTPxGetFer(dDtAux, dDtAux, , cFilSRA,.T.)
            nFeriados++
            nDsr++
        ElseIf DoW(dDtAux) == 1 //Se não for Feriado e for domingo, adiciona 1 DSR  
            nDsr++
        Endif
        nDiasUt++
    Endif

    dDtAux++
End

nDiasUt -= nDsr

nVlrDSR := Round( (nTtComis/nDiasTot)*nDsr ,2)

If !Empty(oMdlGQ3:GetValue('GQ3_CODCOL') )
    oMdlGQ3:AddLine()
Endif

oMdlGQ3:SetValue('GQ3_AGENCI',cAgencia  )
oMdlGQ3:SetValue('GQ3_CODCOL',cColRsp   )
oMdlGQ3:SetValue('GQ3_DATINI',dDtIni    )
oMdlGQ3:SetValue('GQ3_DATFIM',dDtFim    )
oMdlGQ3:SetValue('GQ3_FERINI',dFerIni   )
oMdlGQ3:SetValue('GQ3_FERFIM',dFerFim   )
oMdlGQ3:SetValue('GQ3_DIASUT',nDiasUt   )
oMdlGQ3:SetValue('GQ3_FERIAD',nFeriados )
oMdlGQ3:SetValue('GQ3_DSR'   ,nDsr      )
oMdlGQ3:SetValue('GQ3_VALDSR',nVlrDSR   )

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} TP410SIMUL
Transforma as comissões calculadas e pendentes de exportaçaõ para o RH em comissões simuladas.
@type function
@author crisf
@since 23/11/2017
@version 1.0
@return ${return}, ${return_description}
/*///-------------------------------------------------------------------
Function TP410SIMUL(lAsk)
Local lRet      := .T.
Local cTmpAlias := ""
Local oModel    := nil
Local cResumo   := ''
Local nTtSimul  := 0

Default lAsk    := .t.

If lAsk .and. !Pergunte('GTPA410A',.T.)
    lRet := .F.
EndIf

If lRet 
    cTmpAlias := ExistProc(MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04 )

    If (cTmpAlias)->(!Eof())
        DbSelectArea('GQ6')
        oModel	:= FwLoadModel('GTPA410')
        oModel:SetOperation(MODEL_OPERATION_UPDATE )

        While (cTmpAlias)->(!Eof())
            
            GQ6->(DbGoTo((cTmpAlias)->GQ6RECNO ))

            If oModel:Activate()
                oModel:GetModel("GQ6MASTER"):SetValue("GQ6_SIMULA",StrZero(1,TamSx3("GQ6_SIMULA")[1]) )
                If !(oModel:VldData() .and. oModel:CommitData() )
                    JurShowErro( oModel:GetModel():GetErrormessage() )
                Else 
                    nTtSimul++
                Endif
            Endif
            oModel:DeActivate()

            (cTmpAlias)->(DbSkip())
        End

        (cTmpAlias)->(DbCloseArea())
        oModel:Destroy()

        cResumo	:= STR0041+StrZero(nTtSimul,3)+STR0042//"Foram transferidas "##" calculos de comissões pendentes."
    Endif
Endif

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} ExistProc
Verifica se existem comissões pendentes para os mesmos parametros informados
@type function
@author crisf
@since 23/11/2017
@version 1.0
@param ${param}, ${param_type}, ${param_descr}
@return ${return}, ${return_description}
/*///-------------------------------------------------------------------
Static Function ExistProc( cAgenDe, cAgenAte, dDtDe, dDtAte )
Local  cTmpGQ6	:= GetNextAlias()
Local cQryFch	:= ''

If GQ6->(FieldPos('GQ6_NUMFCH')) > 0
	cQryFch := " AND GQ6.GQ6_NUMFCH = '' "
Endif

cQryFch := '%' + cQryFch + '%'

BeginSql Alias cTmpGQ6

    SELECT 
        GQ6.R_E_C_N_O_ as GQ6RECNO
    FROM %Table:GQ6% GQ6
    WHERE 
        GQ6.GQ6_FILIAL = %xFilial:GQ6%
        AND GQ6.GQ6_AGENCI BETWEEN %exp:cAgenDe% AND  %exp:cAgenAte%
        AND ( 
                %exp:Dtos(dDtDe)% BETWEEN GQ6.GQ6_DATADE AND GQ6.GQ6_DATATE 
                OR %exp:Dtos(dDtAte)% BETWEEN GQ6.GQ6_DATADE AND GQ6.GQ6_DATATE 
            )
        AND GQ6.GQ6_SIMULA = ''
        AND GQ6.GQ6_EXPFOL = ''
        AND GQ6.GQ6_EXPFIN = ''
		%Exp:cQryFch%
        AND GQ6.%NotDel%

EndSql


Return cTmpGQ6
 //------------------------------------------------------------------- 
/*/{Protheus.doc} TP410RH
Efetua a exportação dos registros de comissão para os lançamentos futuros da folha
@type function
@author crisf
@since 25/11/2017
@version 1.0
@return ${return}, ${return_description}
/*/ //-------------------------------------------------------------------  
Function TP410RH()
	Local cTmpGQ6	:= ''
	Local cAgenDe	:= ''
	Local cAgenAte	:= ''
		
	Local nExpFol	:= 0
	Local nGrvFol	:= 0

	Local lGrvFol	:= .T.
	
	Local aExpFol	:= {}
	Local aExpDSR	:= {}
	Local cPeriodo  := ''
	
	if Empty(AllTrim(GTPGetRules("VRBAGCOMSN"))) .OR. Empty( AllTrim(GTPGetRules("VRBAGCMDSR"))) 

		Help( " ", 1, "TP410RH", , "Preencha os parâmetros "+"VRBAGCOMSN e VRBAGCMDSR.", 1, 0 ) 
		Return 
	
	EndIf	
 	//Pergunte
 	If Pergunte("GTPA410C",.T.)
 			
		cAgenDe		:= MV_PAR01
		cAgenAte	:= MV_PAR02

		cTmpGQ6	:= GetNextAlias()
		
		//Seleciona registros, conforme parametros	 		
		FWMsgRun( ,{|| QryComis(cTmpGQ6, cAgenDe, cAgenAte, @aExpFol, @aExpDSR)}, STR0049, STR0050 )//"Comissões Ativas"##"Aguarde.Consultando comissões a serem exportadas...."

 		if len(aExpFol) > 0
 			
 			//Solicita a gravação de lançamentos futuros na folha de pagamento referente a comissão normal 			
 			For nExpFol	:= 1 to len(aExpFol)
 			
 				FWMsgRun( ,{||  lGrvFol	:= TPExpGPE(aExpFol[nExpFol],,@cPeriodo)}, STR0023, STR0056 )//"Aguarde..."##"Incluindo informações no lançamentos futuros da folha de pagamento..."
 				
 				if !lGrvFol
 				
 				//Gravar informaçoes para log
 				
 				Else
 				
 					nGrvFol	:= nGrvFol+1
 				
 				EndIf
 				
 			Next nExpFol
 		
 			//Solicita a gravação de lançamentos futuros na folha de pagamento referente ao DSR sobre comissão
 			if len(aExpDSR) > 0 .AND. lGrvFol
 			 			
	 			For nExpFol	:= 1 to len(aExpDSR)
	 			
	 				FWMsgRun( ,{||  lGrvFol	:= TPExpGPE(aExpDSR[nExpFol],,@cPeriodo)}, STR0023, STR0056 )//"Aguarde..."##"Incluindo informações no lançamentos futuros da folha de pagamento..."
	 				
	 				if !lGrvFol
	 				
	 				//Gravar informaçoes para log
	 				
	 				Else
	 				
	 					nGrvFol	:= nGrvFol+1
	 					
	 				EndIf
	 				
	 			Next nExpFol
		 	
	 		EndIf

 			//Atualizo os Processamentos de Comissões de Agência
	 		if lGrvFol
	 		
	 			FWMsgRun( ,{||  AtuGQ6(cTmpGQ6,cPeriodo)}, STR0023, STR0055 )//"Aguarde..."##"Datando a confirmação dos lançamentos em folha de pagamento com as comissões...."

	 		EndIf

 		Else

 			FWAlertHelp( STR0051, STR0052)	
 			//"Para os parametros informados não existem registros."##"Preencher os parametros e clicar no botão OK ou verifique
 			// quais comissões estão pendentes."	
 		EndIf

 		(cTmpGQ6)->(dbCloseArea())

 		FWAlertSuccess( STR0053, STR0054 )//"Exportação de Comissão finalizada."## "Exportação"

 	Else
 	
 		FWAlertHelp( STR0032, STR0033 )//"Rotina cancelada pelo usuário."##"Preencher os parametros e clicar no botão OK."		
 		
 	EndIf
	 
 Return
 //-------------------------------------------------------------------  
/*/{Protheus.doc} $QryComis
Seleciona as comissões de responsáveis de agência que estão pendentes de exportação 
para a folha de pagamento.
@type function
@author crisf
@since 25/11/2017
@version 1.0
@param ${param}, ${param_type}, ${param_descr}
@return ${return}, ${return_description}
/*///-------------------------------------------------------------------   
Static Function QryComis(cTmpGQ6, cAgenDe, cAgenAte, aExpFol, aExpDSR)

	Local cSRVCom	:= ''
	Local cSRVDSR	:= ''
	Local cExpGQ3   := '%'
	Local cJoinGQ3  := '%'
	Local lHasGQ3   := ChkFile('GQ3')
	Local cQryFch	:= ''

	If GQ6->(FieldPos('GQ6_NUMFCH')) > 0
		cQryFch := " AND GQ6.GQ6_NUMFCH = '' "
	Endif

	cQryFch := '%' + cQryFch + '%'

	If lHasGQ3
		cExpGQ3  += ',ISNULL(GQ3.GQ3_VALDSR,0) VALDSR'
		
		cJoinGQ3 +='LEFT JOIN '+RetSqlName("GQ3")+ ' GQ3'
		cJoinGQ3 += "			    ON GQ3.GQ3_FILIAL = '"+xFilial("GQ3")+"'"
		cJoinGQ3 += '			   AND GQ3.GQ3_PROCES = GQ6.GQ6_CODIGO'
		cJoinGQ3 +=	'		   AND GQ3.GQ3_CODCOL = GQ6.GQ6_CODCOL'
		cJoinGQ3 +=	"	       AND GQ3.GQ3_SIMULA = ' '"
		cJoinGQ3 +=	"		   AND GQ3.D_E_L_E_T_= ' '"			   
	EndIf
		cExpGQ3  += '%'
		cJoinGQ3 += '%'

		 BeginSql Alias cTmpGQ6
		
			SELECT GQ6.GQ6_CODIGO, 
					GQ6.GQ6_CODCOL, 
					GQ6.GQ6_VTCOMI, 
					GYG.GYG_FILIAL, 
					GYG.GYG_FUNCIO, 
					GYG.GYG_FILSRA
					%exp:cExpGQ3%					
			FROM %Table:GYG% GYG
			INNER JOIN  %Table:GQ6%  GQ6
			        ON GQ6.GQ6_FILIAL = %xFilial:GQ6%
			       AND GQ6.GQ6_AGENCI BETWEEN %exp:cAgenDe% AND %exp:cAgenAte%
			       AND GQ6.GQ6_SIMULA = ''
			       AND GQ6.GQ6_EXPFOL = '' 
			       AND GQ6.GQ6_VTCOMI > 0
				   %Exp:cQryFch%
			       AND GQ6.%NotDel%
			       AND GQ6.GQ6_CODCOL = GYG.GYG_CODIGO
			       AND GYG.GYG_FILIAL = %xFilial:GYG%
			 INNER JOIN %Table:GI6%  GI6
			 		ON GI6.GI6_FILIAL = %xFilial:GI6%
			       AND GI6.GI6_CODIGO = GQ6.GQ6_AGENCI
			       AND GI6.GI6_TIPO = '1'
			       AND GI6.GI6_DSR = 'T'
			       AND GI6.%NotDel%
				   %exp:cJoinGQ3%		   
		EndSql
		
		(cTmpGQ6)->(dbGotop())
		if !(cTmpGQ6)->(Eof())
			
	 		cSRVCom	:= AllTrim(GTPGetRules("VRBAGCOMSN"))
	 		cSRVDSR	:= AllTrim(GTPGetRules("VRBAGCMDSR"))
	 				
			While !(cTmpGQ6)->(Eof())
			
				aAdd(aExpFol,{(cTmpGQ6)->GYG_FUNCIO, cSRVCom, (cTmpGQ6)->GQ6_VTCOMI,(cTmpGQ6)->GYG_FILSRA})
				
				if lHasGQ3 .AND. (cTmpGQ6)->VALDSR > 0
				
						aAdd(aExpDSR,{(cTmpGQ6)->GYG_FUNCIO, cSRVDSR, (cTmpGQ6)->VALDSR,(cTmpGQ6)->GYG_FILSRA})
				
				EndIf
			
			(cTmpGQ6)->(dbSkip())
				
			EndDo
			
		EndIf
		
		
 Return
  //-------------------------------------------------------------------  
/*/{Protheus.doc} $TPExpGPE
Grava lançamentos futuros na folha de pagamento. 
@type function
@author crisf
@since 25/11/2017
@version 1.0
@param ${aDados}, ${array}, ${Deverá conter: matricula do funcionário, código da verba, valor positivo a lançar}
@return ${return}, ${return_description}
/*///-------------------------------------------------------------------  
Function TPExpGPE(aDados,nOpc, cPerFol)

Local aAreaSRA	:= SRA->(GetArea())
Local aAreaSRK	:= SRK->(GetArea())
Local aAreaSRV	:= SRV->(GetArea())
Local aPerAtual	:= {}

Local cProces	:= ''
Local cCCusto	:= ''
Local cFilSRA	:= ""
Local cProxDoc	:= ""

Local lGravou	:= .T.
Local lExist	:= .T.

Local nRECNOSRK	:= 0	
Local nVlAux	:= 0

Default	aDados	:= {}
Default nOpc	:= 1
		
dbSelectArea("SRV")
SRV->(dbSetOrder(1))

if Empty(aDados[2]) .OR. !SRV->(dbSeek(xFilial("SRV")+aDados[2])) 

	//Acumular informações de não gravado -log
	lGravou	:= .F.
	
EndIf

If ( FWIsInCallStack("GTPA418") .Or. FWIsInCallStack("GTPA418A") )
	cFilSRA := GA410RetFilMat(aDados[1],aDados[5])
Else
	cFilSRA	:= aDados[4]
EndIf

dbSelectArea("SRA")
SRA->(DbSetOrder(1))//RK_FILIAL, RK_MAT, RK_PD, RK_CC, RK_ITEM, RK_CLVL, RK_DOCUMEN, R_E_C_D_E_L_

If (SRA->(DbSeek(cFilSRA+aDados[1]))) .AND. lGravou	 			
	
	cCCusto	:= SRA->RA_CC
	cProces	:= SRA->RA_PROCES
	cItem	:= SRA->RA_ITEM
	cClVl	:= SRA->RA_CLVL
	
	If fGetPerAtual( @aPerAtual, xFilial("RCH", SRA->RA_FILIAL), cProces, fGetRotOrdinar() )
		//Função do RH que verifica se a folha de pagamento esta aberta no mês (GPEXPER.PRX)
		// @aPerAtual[1,1] ano/mês do período da folha
		// @aPerAtual[1,11] data de pagamento da folha
		//Verifica se para aquele funcionario+verba+mês já existe lançamento
		
		lExist	:= ChkSRKExist(cFilSRA, aDados[1], aDados[2], aPerAtual[1,1], @nRECNOSRK)
		
		dbSelectArea("SRK")
		
		if lExist
		
			SRK->(dbgoto(nRECNOSRK))
		
		Else
			
			//Verifico se existe lançamento para o funcionário+verba+CC+Item Contábil+Classe Valor
			//Caso exista carrega o ultimo numero de documento para devolver o proximo numero
			//Chave única SRK: RK_FILIAL, RK_MAT, RK_PD, RK_CC, RK_ITEM, RK_CLVL, RK_DOCUMEN
			ProxDoc(cFilSRA, aDados[1], aDados[2], SRA->RA_CC, SRA->RA_ITEM, SRA->RA_CLVL, aPerAtual[1,1], @cProxDoc)
			
		EndIf

		cPerFol := aPerAtual[1,1]

		Begin Transaction

			if SRK->(RecLock('SRK',!lExist))			
			
				if !lExist
					
					SRK->RK_FILIAL	:= cFilSRA	//xFilial('SRK') 
					SRK->RK_MAT		:= aDados[1]		// Matricula do funcionário
					SRK->RK_PD  	:= aDados[2] 		// Código da verba da folha
					SRK->RK_DOCUMEN	:= cProxDoc			// Código do documento (número sequencial do lançamento..não existe uma regra de preenchimento...pode ser 000001, 000002 e por aí vai)
					SRK->RK_DTVENC 	:= aPerAtual[1,11] 	//Data do próximo vencimento
					SRK->RK_CC		:= cCCusto			// Centro de custo do funcionário
					SRK->RK_PERINI	:= aPerAtual[1,1]	// Período de início do desconto (AAAAMM) (variável aPerAtual[1,1])
					SRK->RK_NUMPAGO	:= '01' 			// Número de pagamento (01)
					SRK->RK_PROCES 	:= cProces			// Código do processo do funcionário (campo RA_PROCES)								
					SRK->RK_VALORTO	:= aDados[3]		// Valor total a ser descontado/pago
					SRK->RK_PARCELA := 1				// Quantidade de parcelas que serão descontadas
					SRK->RK_VALORPA	:= aDados[3]		// Valor da parcela a ser descontada/paga
					
					//Acrescentado em 17/05/2018
					SRK->RK_DTMOVI 	:= dDataBase
					SRK->RK_DTREF 	:= dDataBase
					SRK->RK_STATUS	:= "2"
					SRK->RK_VLSALDO	:= SRK->RK_VALORTO
					SRK->RK_EMPCONS	:= "2"
					SRK->RK_ITEM	:= cItem
					SRK->RK_CLVL	:= cClVl
					SRK->RK_NUMPAGO	:= "01"	
					SRK->RK_NUMID	:= "SRK" + cFilSRA + aDados[1] + aDados[2] + cProxDoc //cAlias + cFilFun + SRA->RA_MAT + aCols[n,nPosPd] + aCols[n,nPosNrDoc]
																							
				Else
					
					If ( nOpc == 1 )
					
						nVlAux	:= SRK->RK_VALORTO
						SRK->RK_VALORTO	:= SRK->RK_VALORTO+aDados[3]// Valor total a ser descontado/pago
						SRK->RK_VALORPA	:= SRK->RK_VALORPA+aDados[3]// Valor da parcela a ser descontada/paga
					
					Else
						SRK->(DbDelete())
					EndIf
											
				EndIf
				
				lGravou	:= SRK->( MsUnlock() )
			
			EndIf

		End Transaction

		//Verifica se a inclusão ocorreu com exito
		if !lExist
		
			lGravou	:= ChkSRKExist(cFilSRA, aDados[1], aDados[2], aPerAtual[1,1], @nRECNOSRK)
		
		Elseif nVlAux <> SRK->RK_VALORTO
		
			lGravou	:= .T.
			
		EndIf 
		
		If ( !lGravou .And. nOpc == 2 )
			lGravou := .t.
		EndIf
		
    Else
	
	//Acumular informações de não gravado -log
		lGravou := .F.
		
	EndIf

Else
	
	//Acumular informações de não gravado -log
	lGravou := .F.
						
EndIf

RestArea(aAreaSRA)
RestArea(aAreaSRK)
RestArea(aAreaSRV)
	
Return lGravou
//-------------------------------------------------------------------  
/*/{Protheus.doc} ChkSRKExist
Veifica se para o funcionário+codigo da verba+periodo já existe lançamento futuro
@type function
@author crisf
@since 25/11/2017
@version 1.0
@param ${param}, ${param_type}, ${param_descr}
@return ${lExist}, ${.t. existe .F. não existe}
/*///-------------------------------------------------------------------  
Static Function ChkSRKExist(cFilMat, cMatricula, cCodVerba, cPeriodo, nRECNOSRK)

	Local cTmpSRK	:= GetNextAlias()
	Local lExist	:= .F.	
		
		Beginsql Alias cTmpSRK
		
			SELECT SRK.R_E_C_N_O_
			FROM %Table:SRK% SRK
			WHERE SRK.RK_FILIAL = %Exp:cFilMat%
			  AND SRK.RK_MAT = %exp:cMatricula%
		      AND SRK.RK_PD = %exp:cCodVerba%
		      AND SRK.RK_PERINI = %exp:cPeriodo%
		      AND SRK.%NotDel%
		      
		EndSql		
		
		if !(cTmpSRK)->(Eof())
		
			nRECNOSRK	:= (cTmpSRK)->R_E_C_N_O_
			lExist	:= .T.	
			
		Else
			
			lExist	:= .F.
				
		EndIf
		
		(cTmpSRK)->(dbCloseArea())
	
Return lExist
//------------------------------------------------------------------- 
/*/{Protheus.doc} ProxDoc
Retorna o próximo número de documento disponível para o filtro enviado pelos parametros da função..
@type function
@author crisf
@since 25/11/2017
@version 1.0
@param ${param}, ${param_type}, ${param_descr}
@return ${return}, ${return_description}
/*///------------------------------------------------------------------- 
Static Function ProxDoc(cFilMat,cMatricula, cCodVerba, cCCusto, cItemCnt, cClVL, cPeriodo, cProxDoc)

	Local cTMPSRK	:= GetNextAlias()
	
		BeginSql Alias cTMPSRK
			
			SELECT MAX(SRK.RK_DOCUMEN) ULTDOC 	
			FROM %Table:SRK% SRK
			WHERE SRK.RK_FILIAL = %Exp:cFilMat%
			  AND SRK.RK_MAT = %exp:cMatricula%
		      AND SRK.RK_PD = %exp:cCodVerba%
		      AND SRK.RK_PERINI = %exp:cPeriodo%
			  AND SRK.%NotDel%
	
		EndSql
		
		if !(cTMPSRK)->(Eof())
		
			cProxDoc	:= SOMA1((cTMPSRK)->ULTDOC)
		
		Else
			
			cProxDoc	:= Padl(cProxDoc,TamSX3("RK_DOCUMEN")[1],'0')
				
		EndIf
		
		(cTMPSRK)->(dbCloseArea())
		
Return 
//------------------------------------------------------------------- 
/*/{Protheus.doc} AtuGQ6
Atualização do Processamento de Comissão de Agência
@type function
@author crisf
@since 25/11/2017
@version 1.0
@param ${param}, ${param_type}, ${param_descr}
@return ${return}, ${return_description}
/*///------------------------------------------------------------------- 
Static Function AtuGQ6(cTmpGQ6,cPeriodo)

	Local lGravou	:= .T.
	Local aAreaGQ6	:= GQ6->(GetARea())
	Local aNewFlds      := {'GQ6_PERFOL', 'GQ6_VRBCOM', 'GQ6_VRBDSR'}
	Default cPeriodo := ''

		(cTmpGQ6)->(dbGotop())
				
		dbSelectArea("GQ6")
		GQ6->(dbsetOrder(1))
			
		While !(cTmpGQ6)->(Eof())

			if GQ6->(dbSeek(xFilial("GQ6")+(cTmpGQ6)->GQ6_CODIGO))
			
				if	GQ6->(Reclock("GQ6",.F.))
					GQ6->GQ6_EXPFOL	:= MsDate()

					If  GTPxVldDic('GQ6', aNewFlds, .F., .T.)	 		
        				GQ6->GQ6_PERFOL := cPeriodo
        				GQ6->GQ6_VRBCOM := AllTrim(GTPGetRules("VRBAGCOMSN"))
        				GQ6->GQ6_VRBDSR := AllTrim(GTPGetRules("VRBAGCMDSR"))
    				Endif

					GQ6->(MsUnLock())
					
				EndIf
				
			EndIf

		(cTmpGQ6)->(dbSkip())
		
		EndDo
				
	RestArea(aAreaGQ6)
	
Return lGravou
//------------------------------------------------------------------- 
/*/{Protheus.doc} TP410FIN
Exportação para o financeiro
@type function
@author crisf
@since 25/11/2017
@version 1.0
@return ${return}, ${return_description}
/*///------------------------------------------------------------------- 
Function TP410FIN()

	Local aArea		:= GetArea()
	Local cResumo	:= ''
	Local cTmpGQ6	:= ''
	Local aExpFil	:= {}
	Local cAgenDe	:= ''
	Local cAgenAte	:= ''
	Local dDtDe		:= Ctod('//')
	Local dDtAte	:= MsDate()
	Local cPrefix	:= ''
	Local cTpTit	:= ''
	Local cHistSE2	:= ''
	Local cNaturez	:= ''
	Local cCndPgto	:= ''//possibilitar a divisão do pagamennto de titulo através da SE4
	Local cCndPgTP	:= ''//Condição de pagamento configuravel  pelo GTP, sem vinculo com a SE4
	Local nExpFin	:= 0
	Local lGravou	:= .T.
	Local aTitInc	:= {}
	Local aParcTit	:= {}
	Local nSE2		:= 0
	Local nTtTit	:= 0
			
		If Pergunte("GTPA410C",.T.)
		
			cAgenDe	:= MV_PAR01
			cAgenAte	:= MV_PAR02
			
			cCndPgto	:= AllTrim(GTPGetRules("CDPGTITFOR"))
			
			if Empty(cCndPgto)
			
				//"Código da condição de pagamento não informada."##"Cadastrar uma condição de pagamento e associar ao parametro do módulo CDPGTITFOR." 
				FWAlertHelp(STR0072 , STR0073 )
				
				Return
				
			EndIf				
					
			cTmpGQ6	:= GetNextAlias()
			
			FWMsgRun( ,{|| QryExFin(cTmpGQ6, cAgenDe, cAgenAte, dDtDe, dDtAte , cCndPgto, cCndPgTP, @aExpFil )}, STR0049, STR0062 )
			//"Comissões Ativas"##"Aguarde.Consultando comissões a serem exportadas para o financeiro...."
			if len(aExpFil) > 0
									
				cPrefix		:= AllTrim(GTPGetRules("PREFTITFOR"))
				cTpTit		:= AllTrim(GTPGetRules("TIPOTITFOR"))
				cNaturez	:= AllTrim(GTPGetRules("NATUTITFOR"))				
				cHistSE2	:= AllTrim(GTPGetRules("HISTTITFOR"))
				
				//MntTela nf entrada x comissão aExpFil
				GTPA410A(@aExpFil)
				
				For nExpFin	:= 1 to len(aExpFil)
				
					//Se for vinculado a comissão com a nota fiscal
					//if !Empty(aExpFil[nExpFin][06]) .And. !Empty(aExpFil[nExpFin][07]) //Verificar o campo da nota fiscal + serie
					
						aTitInc	:= aClone(aExpFil[nExpFin])
						
						TitParc( @aTitInc, cPrefix, cTpTit )
						
						Begin Transaction
							
							For nSE2	:= 1 to len(aTitInc)
								
								aParcTit	:= aClone(aTitInc[nSE2])
								lGravou	:= TP410GvFinanceiro( aParcTit, cNaturez, cHistSE2, 3)
								
								if !lGravou
							
									Exit
								
								Else
									
									nTtTit	:= nTtTit+1
									
								EndIf
															
							Next nSE2
														
							if lGravou
							
								if !AtuaFinGQ6(aExpFil[nExpFin][1])
									
									lGravou	:= .F.
								
								  EndIf								
								
							EndIf
							If lGravou 
								GrvFinGZO(aTitInc)
							EndIF
						End Transaction
						
				//	EndIf
					
					if nTtTit > 0
						//"Foram gerados "##" titulos."
						cResumo	:= cResumo+CRLF+STR0070+strzero(nTtTit,4)+STR0071
						FWAlertSuccess(STR0070+strzero(nTtTit,4)+STR0071, STR0031 )//"Finalizado
				
					Else
					
						FWAlertHelp(STR0068 , STR0069 )
						//"Não foram exportados titulos"
						// "Verificar se as comissões foram vinculadas a notas fiscais, caso tenha sido, verificar o preenchimentos dos parametros" 
								
					EndIf
					 
				Next nExpFin
				
			Else
			
				cResumo	:= cResumo+CRLF+STR0063//"Para os parametros informados não existem comissões a serem exportados ao financeiro."
				FWAlertHelp( cResumo, STR0064 )//"Verificar o preechimento dos parametros, ou filtrar na tela principal as comissões pendentes de exportação ao financeiro."
			
			EndIf

		Else

			FWAlertHelp( STR0032, STR0033 )//"Rotina cancelada pelo usuário."##"Preencher parametros e clicar no botão OK."		

		EndIf
		
	RestArea(aArea)
		
Return 
//------------------------------------------------------------------- 
/*/{Protheus.doc} QryExFin
(long_description)
@type function
@author crisf
@since 26/11/2017
@version 1.0
@param ${param}, ${param_type}, ${param_descr}
@return ${return}, ${return_description}
/*///------------------------------------------------------------------- 
Static Function QryExFin(cTmpGQ6, cAgenDe, cAgenAte, dDtDe, dDtAte, cCndPgto, cCndPgTP, aExpFil)
	
	Local aParc		:= {}
	Local cQryFch	:= ''

	If GQ6->(FieldPos('GQ6_NUMFCH')) > 0
		cQryFch := " AND GQ6.GQ6_NUMFCH = '' "
	Endif

	cQryFch := '%' + cQryFch + '%'

		Beginsql Alias cTmpGQ6
			
			SELECT GQ6.GQ6_CODIGO, GQ6.GQ6_AGENCI, GQ6.GQ6_FORNEC, GQ6.GQ6_LOJA, 
			(ISNULL(GQ6.GQ6_VTCOMI,0) + ISNULL(GQ6.GQ6_VTBONF,0) - ISNULL(GQ6.GQ6_VTDESC,0)) VLRCOMISSAO
			FROM %Table:GQ6% GQ6
			WHERE GQ6.GQ6_FILIAL  =  %xFilial:GQ6%
			  AND GQ6.GQ6_AGENCI BETWEEN %exp:cAgenDe% AND %exp:cAgenAte%
			  AND GQ6.GQ6_EXPFIN = ''
			  AND GQ6.GQ6_GERTIT = 'T' 
			  AND GQ6.GQ6_VTCOMI > 0
			  AND GQ6.GQ6_SIMULA = ''
			  %Exp:cQryFch%
			  AND GQ6.%NotDel%
		
		EndSql
		
		if !(cTmpGQ6)->(Eof())
			
			While	!(cTmpGQ6)->(Eof())
				
				if !Empty(cCndPgto)
				
					aParc := Condicao((cTmpGQ6)->VLRCOMISSAO,cCndPgto, ,  )
				
				EndIf
				
				aAdd(aExpFil,{ (cTmpGQ6)->GQ6_CODIGO, (cTmpGQ6)->GQ6_FORNEC, (cTmpGQ6)->GQ6_LOJA, (cTmpGQ6)->VLRCOMISSAO, (cTmpGQ6)->GQ6_AGENCI, ;
								'', '', aParc, '', '', '', '', '', '', Ctod('//')})
							
			(cTmpGQ6)->(dbSkip())
			
			EndDo
			
		EndIf
		  
 Return 
//-------------------------------------------------------------------  
/*/{Protheus.doc} TP410GvFinanceiro
Grava no financeiro
@type function
@author crisf
@since 26/11/2017
@version 1.0
@param ${param}, ${param_type}, ${param_descr}
@return ${return}, ${return_description}
/*///-------------------------------------------------------------------  
Function TP410GvFinanceiro(aTitPagar, cNaturez, cHistSE2, nOpcx)

	Local aAreaSE2 		:= SE2->(GetArea())
	Local lGravou		:= .T.
	Default nOpcx 	    := 0
	Default aTitPagar	:= {''}
	Private lMsErroAuto := .F.
	
		if !Empty(aTitPagar[2])
		
			dbSelectArea("SE2")
					
			if !Empty(cHistSE2)
			
				cHistSE2	:= Substring(cHistSE2,1,TamSx3('E2_HIST')[1]) 
		
			EndIf
			
			dbSelectArea("SE2")
			SE2->(dbSetORder(1))//E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, R_E_C_N_O_, D_E_L_E_T_
			if !SE2->(dbSeek(xFilial("SE2")+aTitPagar[10]+aTitPagar[11]+aTitPagar[12]+aTitPagar[13]+aTitPagar[2]+aTitPagar[3]))
			
				If nOpcx == 3
				
					aTitPagar := {	{"E2_PREFIXO"	, aTitPagar[10]			, Nil },; //Prefixo
									{"E2_NUM"    	, aTitPagar[11]			, Nil },; //Numero								
									{"E2_PARCELA"	, aTitPagar[12]			, Nil },; //Parcela
									{"E2_TIPO"   	, aTitPagar[13]			, Nil },; //Tipo
									{"E2_NATUREZ"	, cNaturez				, Nil },; //Natureza
									{"E2_FORNECE"	, aTitPagar[2]			, Nil },; //Fornecedor
									{"E2_LOJA"   	, aTitPagar[3]			, Nil },; //Loja
									{"E2_EMISSAO"	, MsDate()				, Nil },; //Emissão
									{"E2_VENCTO"	, aTitPagar[15]			, Nil },; //Vencimento
									{"E2_VENCREA"	, aTitPagar[15]			, Nil },; //Vencimento Real
									{"E2_VENCORI"	, aTitPagar[15]			, Nil },; //Vencimento Original      
									{"E2_EMIS1"  	, MsDate()				, Nil },; //Emissão
									{"E2_VALOR"  	, aTitPagar[4]			, Nil },; //Valor
									{"E2_VLCRUZ" 	, aTitPagar[4]			, Nil },; //Vl R$
									{"E2_HIST" 		, cHistSE2 				, Nil },;
									{"E2_ORIGEM" 	, "GTPA410"				, Nil }}  //Origem
				EndIf
			
				MSExecAuto({|x,y,z| FINA050(x,y,z)}, aTitPagar, , nOpcx)
					
				If lMsErroAuto
				
					//MostraErro()
					lGravou := .F.
					SE2->(RollBackSx8())
					
				Else
					
					SE2->(ConfirmSX8())
						
				Endif
			
			Else
				
				lGravou := .F.
				
			EndIf
		
		Else
		
			lGravou := .F.
			
		EndIf
			
		RestArea(aAreaSE2)

Return lGravou
//------------------------------------------------------------------- 
/*/{Protheus.doc} AtuaFinGQ6
Vincula a comissão calculada com o titulo a pagar e a nota fiscal
@type function
@author crisf
@since 26/11/2017
@version 1.0
@param ${param}, ${param_type}, ${param_descr}
@return ${return}, ${return_description}
/*///------------------------------------------------------------------- 
Static Function AtuaFinGQ6(cCodComis)
	
	Local lGrvGQ6Fin	:= .T.
	Local aAreaGQ6		:= GQ6->(GetArea())
	Local oModelGQ6	
		
		dbSelectArea("GQ6")
		GQ6->(dbSetOrder(1))

		if GQ6->(dbSeek(xFilial("GQ6")+cCodComis+space(TamSx3("GQ6_SIMULA")[1])))
			
			oModelGQ6  	:=  FWLoadModel( 'GTPA410' ) 
			
			oModelGQ6:SetOperation(MODEL_OPERATION_UPDATE)
			
			If oModelGQ6:Activate()

				oModelGQ6:GetModel('GQ6MASTER'):SetValue('GQ6_EXPFIN','EXPORT')
			
				If oModelGQ6:VldData()
						
					FwFormCommit(oModelGQ6)
					oModelGQ6:DeActivate()
					lGrvGQ6Fin	:= .T.
					
				Else
				
					JurShowErro( oModelGQ6:GetModel():GetErrormessage() ) 
					lGrvGQ6Fin	:= .F.
					
				EndIf	
				
			EndIf
	
		Else
			
			lGrvGQ6Fin	:= .F.
			
		EndIf
	
	RestArea(aAreaGQ6)
	
Return lGrvGQ6Fin
//-------------------------------------------------------------------
/*/{Protheus.doc} TitParc
@type function
@author crisf
@since 28/11/2017
@version 1.0
@param ${param}, ${param_type}, ${param_descr}
@return ${return}, ${return_description}
/*///-------------------------------------------------------------------
Static Function TitParc( aTitInc, cPrefix, cTpTit )

	Local nParc			:= 0
	Local aTitParcV		:= {}
	Local aParcVencto	:= aTitInc[8]
	Local cNumSE2		:= GetSxeNum("SE2","E2_NUM")
	Local cParcAtu		:= space(TamSx3('E2_PARCELA')[1])
	
		
		For nParc := 1 to len(aParcVencto)
			
			if len(aParcVencto) > 1
			
				cParcAtu		:= Padl(Alltrim(cParcAtu),TamSx3('E2_PARCELA')[1],'0')
				cParcAtu		:= Soma1(cParcAtu)
				
			EndIf
			
			aAdd(aTitParcV, {aTitInc[1],aTitInc[2],aTitInc[3],aParcVencto[nParc][2],aTitInc[5],aTitInc[6],aTitInc[7],{}, xFilial("SE2"), cPrefix, cNumSE2, cParcAtu, cTpTit, aTitInc[14], aParcVencto[nParc][1] })
				
		Next nParc
	
		aTitInc	:= aClone(aTitParcV)
		
Return

//------------------------------------------------------------------- 
/*/{Protheus.doc} GrvFinGZO
Realiza vinculo do processamento X Nota Fiscal X Titulo Gerado
@type function 
@author Yuki
@since 
@version 1.0
@param ${param}, ${param_type}, ${param_descr}
@return ${return}, ${return_description}
/*///------------------------------------------------------------------- 
Static Function GrvFinGZO(aTitInc)
	Local lRet			:= .T.
	Local oModel  	:=  FWLoadModel( 'GTPA410B' ) 
	Local oMdlGZO		:=	oModel:GetModel("GZOMASTER")
	//Local nI			:= 1
	//Local nY 			:= 1
	
//	GQ6->(DbSetOrder(1)) //GQ6_FILIAL+GQ6_CODIGO+GQ6_SIMULA
	//If GQ6->(DbSeek(xFilial('GQ6') + aTitInc[1][1] + SPACE(TamSx3("GQ6_SIMULA")[1])))
		oModel:SetOperation(MODEL_OPERATION_INSERT)
		oModel:Activate()
//	Endif	
		
	/*If !oMdlGZO:IsActive()
		oModel:SetOperation(3)
		oModel:Activate()
	EndIf*/
	
//	For nI	:= 1 To Len(aTitInc)
//		If nI <> 1
//			oMdlGZO:AddLine()
//		EndIf
	//	If  oMdlGZO:IsEmpty() .and. oMdlGZO:Length() == 0
	//		oMdlGZO:AddLine()
	//	Endif 
		oMdlGZO:SetValue("GZO_CODGQ6", aTitInc[1][1])
		oMdlGZO:SetValue("GZO_FILSNF", aTitInc[1][14])
		oMdlGZO:SetValue("GZO_DOCNF ", aTitInc[1][6])
		oMdlGZO:SetValue("GZO_SERNF ", aTitInc[1][7])
		oMdlGZO:SetValue("GZO_FILTIT", aTitInc[1][9])
		oMdlGZO:SetValue("GZO_PRETIT", aTitInc[1][10])
		oMdlGZO:SetValue("GZO_NUMTIT", aTitInc[1][11])
		oMdlGZO:SetValue("GZO_PARTIT", aTitInc[1][12])
		oMdlGZO:SetValue("GZO_TPTIT ", aTitInc[1][13])
//	Next
	
	If  oModel:VldData()
		lRet	:= FwFormCommit(oModel)
	Else
		lRet := .F.
	Endif		
	
	If !lRet
		JurShowErro( oModel:GetModel():GetErrormessage() ) 
	EndIf
		
	oModel:DeActivate()
	
	oModel:Destroy()
	
Return lRet


Function GA410RetFilMat(cMatricula,cCPF)

Local aResult	:= {{"RA_FILIAL"}}
Local aSeek		:= {}

Local cRetFilMat:= "" 

aAdd(aSeek,{"RA_MAT",cMatricula})
aAdd(aSeek,{"RA_CIC",cCPF})
aAdd(aSeek,{"RA_SITFOLH",space(TamSx3("RA_SITFOLH")[1])})

If ( GtpSeekTable("SRA",aSeek,aResult) )
	cRetFilMat := IIf(Len(aResult) > 1, PadR(aResult[2,1],TamSx3("RA_FILIAL")[1]),Space(TamSx3("RA_FILIAL")[1]))	
EndIf

Return(cRetFilMat)


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
        If GQ5->GQ5_TPCOMI == '1' 
            TP413XmlArray(cCodForm, aFormula)
            //Caso a formula não esteja associada a um cadastro de comissão de agência ou não seja preennchida, o calculo de comissão
            //será efetuado com regras simples descritas na evidência de teste 
            If Len(aFormula) == 0 .AND. !MsgYesNo( STR0021 ) // "Fórmula não encontrada. Deseja continuar?" 
                lRet := .T.
            EndIf
        Else
            lRet := .F.
            FWAlertHelp( "Fórmula para agência", "Informar um código de fórmula com o campo 'Tp.Comissão' igual a Agência.","Atenção!!" )	
        EndIf
    Else
        lRet := .F.
        FwAlertHelp("Formula informada não encontrada","Verifique os dados informados","Atenção!!")
    EndIf
    RestArea(aAreaGQ5)

Endif

GtpDestroy(aAreaGQ5)

Return lRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} SetSayText

@type Static Function
@author jacomo.fernandes
@since 30/12/2019
@version 1.0
@param oSay, Object, (Descrição do parâmetro)
@Param cText, character, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Static Function SetSayText(oSay,cText,lGetOld)
Local nAt := 0
Default lGetOld := .F.
If lSay
    If lGetOld
        If (nAt := At(chr(13),oSay:GetText()) ) > 0
            cText := SubStr(oSay:GetText(),1,nAt)+Chr(13)+Chr(10)+cText
        Else
            cText := oSay:GetText()+Chr(13)+Chr(10)+cText
        Endif
    Endif
    oSay:SetText(cText)
    ProcessMessages()
Endif

Return 

//------------------------------------------------------------------------------
/* /{Protheus.doc} GTP410TdOK

@type Static Function
@author GTP
@since 31/03/20120
@version 1.0
/*/
//------------------------------------------------------------------------------
Function GTP410TdOK(oModel)
Local lRet 	:= .T.
Local oMdlGQ6	:= oModel:GetModel('GQ6MASTER')
Local oMdlGZO	:= oModel:GetModel('GZOMASTER')

Local aAreaSE2	:= SE2->( GetArea() )
Local aTitSE2	:= {}
Private lMsErroAuto := .F.


If (oMdlGQ6:GetOperation() == MODEL_OPERATION_DELETE)

	If (oMdlGQ6:GetValue("GQ6_EXPFIN") == 'EXPORT')
		
		dbSelectArea("SE2")
		SE2->(dbSetORder(1))	//E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, R_E_C_N_O_, D_E_L_E_T_
		If SE2->(dbSeek(oMdlGZO:GetValue('GZO_FILTIT')+oMdlGZO:GetValue('GZO_PRETIT')+oMdlGZO:GetValue('GZO_NUMTIT')+oMdlGZO:GetValue('GZO_PARTIT')+oMdlGZO:GetValue('GZO_TPTIT')+oMdlGQ6:GetValue('GQ6_FORNEC')+oMdlGQ6:GetValue('GQ6_LOJA')))
			If SE2->E2_VALOR <> SE2->E2_SALDO
				Help( ,, 'Help',"GTP410TdOK", STR0079, 1, 0 )	//Não será permitida a exclusão, título de comissão com movimentação.
       			lRet := .F.
			Else
				aTitSE2 := {	{ "E2_FILIAL"	, SE2->E2_FILIAL			        , Nil },; 
								{ "E2_NUM"		, SE2->E2_NUM  					    , Nil },; 				
								{ "E2_PREFIXO"	, SE2->E2_PREFIXO		            , Nil },; 					
								{ "E2_PARCELA"	, SE2->E2_PARCELA				    , Nil },; 
								{ "E2_TIPO"		, SE2->E2_TIPO					    , Nil },; 
								{ "E2_NATUREZ"	, SE2->E2_NATUREZ			        , Nil },; 
								{ "E2_FORNECE"	, SE2->E2_FORNECE				    , Nil },; 
								{ "E2_LOJA"		, SE2->E2_LOJA			 		    , Nil },; 
								{ "E2_EMISSAO"	, SE2->E2_EMISSAO		         	, Nil }; 
							} 
				 				
				 MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aTitSE2,, 5) // Exclui o título
						 	
				 If lMsErroAuto
					lRet := .F.
					MostraErro()					
				 Else
					lRet := .T.
					CONFIRMSX8()
				 EndIf

			EndIf   
	   EndIf
	ElseIf  !Empty( oMdlGQ6:GetValue("GQ6_EXPFOL") )  
		Help( ,, 'Help',"GTP410TdOK", STR0080, 1, 0 )	//Não será permitida a exclusão, possui exportação para folha.
		lRet := .F.
    EndIf

	If GQ6->(FieldPos('GQ6_NUMFCH')) > 0 .And.;
	 		!Empty(oMdlGQ6:GetValue('GQ6_NUMFCH')) .And.;
	 		!FwIsInCallStack("G421DelCom")
		lRet := .F.
		Help( ,, 'Help',"GTP410TdOK", STR0081, 1, 0 ) // "Cálculos gerados pela ficha de remessa não podem ser excluídos diretamente"
	Endif

EndIf

RestArea( aAreaSE2 )

Return lRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} GTP410ComFch(cAgencia, dDataIni, dDataFim, cNumFch, lOnlyCalc)
@type Static Function
@author flavio.martins
@since 15/09/2021
@version 1.0
/*/
//------------------------------------------------------------------------------
Function GTP410ComFch(cAgencia, dDataIni, dDataFim, cNumFch, lOnlyCalc)
Local nVlrCom := 0

    FwMsgRun(,{|oSay| nVlrcom := ProcComissao(oSay, cAgencia, cAgencia, dDataIni, dDataFim,, cNumFch, lOnlyCalc)}, STR0082, STR0085) // "Processo de Comissão","Inicializando o processamento..."

Return nVlrCom
