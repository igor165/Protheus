#INCLUDE "OGAA910.ch"
#include "protheus.ch"
#include "fwmbrowse.ch"
#include "fwmvcdef.ch"

	
/*/{Protheus.doc} OGAA910()
Rotina para cadastro de Peso e Qualidade no Destino
@type  Function
@author tamyris ganzenmueller
@since 28/09/2018
@version 1.0
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function OGAA910(  )
	Local   oMBrowse
	
	//Proteç?o
	If !TableInDic('N82')
		Help( , , STR0021, , STR0058, 1, 0 ) //"Atenç?o" //"Para acessar esta funcionalidade é necessario atualizar o dicionario do Protheus."
		Return(Nil)
	EndIf 
	
	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "N82" )
	oMBrowse:SetDescription( STR0001 ) //"Registro de Peso e Qualidade no Destino"
	oMBrowse:AddLegend( "N82_STATUS='1'", "GRAY"  , STR0018 ) //"Pendente"
	oMBrowse:AddLegend( "N82_STATUS='2'", "YELLOW", STR0019 ) //"Aguardando Aprovação"
	oMBrowse:AddLegend( "N82_STATUS='3'", "GREEN" , STR0020 ) //"Aprovado"

	oMBrowse:aColumns[1]:cTitle := RetTitle("N82_STATUS") // "Sts. Qld/Pes"

	oMBrowse:AddStatusColumns( {||OGAA910Est(N82->( N82_STAPES ))}, {||OGAA910Leg()})
	oMBrowse:aColumns[2]:cTitle := RetTitle("N82_STAPES") //"Sts. Peso"

	oMBrowse:AddStatusColumns( {||OGAA910Est(N82->( N82_STAQUA ))}, {||OGAA910Leg()})
	oMBrowse:aColumns[3]:cTitle := RetTitle("N82_STAQUA") //"Sts. Qualidade"
	
	oMBrowse:SetMenuDef( "OGAA910" )
	oMBrowse:SetAttach( .T. ) //Visualização

	oMBrowse:Activate()

Return()

/*/{Protheus.doc} MenuDef()
Função que retorna os itens para construção do menu da rotina
@type  Function
@author tamyris ganzenmueller
@since 28/09/2018
@version 1.0
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0003, 'PesqBrw'           , 0, 1 , 0, .T. } ) //'Pesquisar'
aAdd( aRotina, { STR0004, 'ViewDef.OGAA910'   , 0, 2 , 0, Nil } ) //'Visualizar'
aAdd( aRotina, { STR0006, 'ViewDef.OGAA910'   , 0, 4 , 0, Nil } ) //"Registrar Peso / Qualidade Destino"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                '
aAdd( aRotina, { STR0008, 'ViewDef.OGAA910'   , 0, 8 , 0, Nil } ) //'Imprimir'
aAdd( aRotina, { STR0011, "AGRCONHECIM('N82')", 0, 4 , 0, .F. } ) //"Conhecimento"
aAdd( aRotina, { STR0017, "OGAA910APR()"      , 0, 7 , 0, .F. } ) //"Aprovar Peso"
aAdd( aRotina, { STR0045, "OGAA910AQR()"      , 0, 9 , 0, .F. } ) //"Aprovar Qualidade"
aAdd( aRotina, { STR0050, "OGAA910AGR()"      , 0, 10, 0, .F. } ) //"Aprovar Consolidação Peso e Qual. no Dest."
aAdd( aRotina, { STR0029, "OGAA910HIS()"      , 0, 11, 0, .F. } ) //"Histórico"
aAdd( aRotina, { STR0057, 'OGAA950()'   	  , 0, 12, 0, NIL } ) //'Encontro de Contas Invoice'

Return aRotina

/*/{Protheus.doc} ModelDef()
Função que retorna o modelo padrao para a rotina
@type  Function
@author tamyris ganzenmueller
@since 28/09/2018
@version 1.0
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ModelDef()
	Local oStruN82 := FWFormStruct( 1, "N82" )
	Local oStruNLB := FWFormStruct( 1, "NLB" )
	Local oStruNLD := FWFormStruct( 1, "NLD" )
	Local oStruNLE := FWFormStruct( 1, "NLE" )
	Local oModel   := MPFormModel():New( "OGAA910", , , {| oModel | GrvModelo( oModel ) } )

	oStruN82:AddField(RetTitle("N82_STAPES"), RetTitle("N82_STAPES"), 'N82_STAPES', 'BT' , 1 , 0, {|| OGA810Leg()} , NIL , NIL, NIL, {||OGA810Est(N82->N82_STAPES)}, NIL, .F., .F.)
	oStruN82:AddField(RetTitle("N82_STAQUA"), RetTitle("N82_STAQUA"), 'N82_STAQUA', 'BT' , 1 , 0, {|| OGA810Leg()} , NIL , NIL, NIL, {||OGA810Est(N82->N82_STAQUA)}, NIL, .F., .F.)
	oStruN82:AddField('(-) ' + RetTitle("N82_TOTDES"), '(-) ' + RetTitle("N82_TOTDES"), 'N82_TOTDE1', 'N' , TamSX3("N82_TOTDES")[1] , TamSX3("N82_TOTDES")[2] , /*bValid*/, /*bWhen*/, /*aValues*/, /*lObrigat*/.F. , { | | N82->N82_TOTDES } , .F./*lKey*/, /*lNoUpd*/,  .T. /*lVirtual*/) //"Descrição" ### "Descrição"
	
	oStruN82:SetProperty( "N82_TOTQUA" , MODEL_FIELD_TITULO , ('(+) ' + RetTitle("N82_TOTQUA")) )
	oStruN82:SetProperty( "N82_TOTTAX" , MODEL_FIELD_TITULO , ('(+) ' + RetTitle("N82_TOTTAX")) )
	oStruN82:SetProperty( "N82_TOTDES" , MODEL_FIELD_TITULO , ('(=) ' + RetTitle("N82_TOTDES")) )
	oStruN82:SetProperty( "N82_SLDINV" , MODEL_FIELD_TITULO , ('(=) ' + RetTitle("N82_SLDINV")) )

	oStruN82:SetProperty( "N82_CODINE" , MODEL_FIELD_WHEN , { | | .F. } )
	oStruN82:SetProperty( "N82_PEDIDO" , MODEL_FIELD_WHEN , { | | .F. } )
	oStruN82:SetProperty( "N82_ITEM"   , MODEL_FIELD_WHEN , { | | .F. } )
	oStruN82:SetProperty( "N82_FILORI" , MODEL_FIELD_WHEN , { | | .F. } )
	oStruN82:SetProperty( "N82_QTLQDE" , MODEL_FIELD_WHEN , { | | IIF(N82->N82_STATUS <> '3',.T.,.F.)})
	
	oStruNLB:SetProperty( "NLB_QLDCTR" , MODEL_FIELD_VALID,  { | | fValidRes("NLB_QLDCTR") })
	oStruNLB:SetProperty( "NLB_TPCALA" , MODEL_FIELD_VALID , { | | fValidRes("NLB_TPCALA") })
	oStruNLB:SetProperty( "NLB_TOCALD" , MODEL_FIELD_VALID , { | | fValidRes("NLB_TOCALD") })
	
	oStruNLD:SetProperty( "NLD_VALDES" , MODEL_FIELD_VALID, { | | fCalcQua()  })
	oStruNLD:SetProperty( "NLD_CODTIP" , MODEL_FIELD_VALID, { | | fValidRes("NLD_CODTIP") })
	oStruNLE:SetProperty( "NLE_VLRTOT" , MODEL_FIELD_VALID, { | | fCalcTot()})
	
	oStruN82:AddTrigger( "N82_QTLQDE", "N82_DIFPES", { || .T. }, { | x | fTrgN82Pes( "N82_DIFPES" ) } )
	oStruN82:AddTrigger( "N82_QTLQDE", "N82_VARPES", { || .T. }, { | x | fTrgN82Pes( "N82_VARPES" ) } )
	oStruN82:AddTrigger( "N82_QTLQDE", "N82_VALTOT", { || .T. }, { | x | fTrgN82Pes( "N82_VALTOT" ) } )
	oStruN82:AddTrigger( "N82_QTLQDE", "N82_PESMED", { || .T. }, { | x | fTrgN82Pes( "N82_PESMED" ) } )
	oStruN82:AddTrigger( "N82_QTLQDE", "N82_PESLD2", { || .T. }, { | x | fTrgN82Pes( "N82_PESLD2" ) } )
	oStruN82:AddTrigger( "N82_UTPESO", "N82_TOTPES", { || .T. }, { | x | fTrgN82Pes( "N82_TOTPES" ) } )
	oStruN82:AddTrigger( "N82_CODTAB", "N82_DESTAB", { || .T. }, { | x | fTipQuali(			  ) } )

	oStruN82:AddTrigger( "N82_QTLDC", "N82_DIFPEC", { || .T. }, { | x | fTrgN82Pes( "N82_DIFPEC" ) } )
	oStruN82:AddTrigger( "N82_QTLDC", "N82_VARPEC", { || .T. }, { | x | fTrgN82Pes( "N82_VARPEC" ) } )
	oStruN82:AddTrigger( "N82_QTLDC", "N82_VLTOCL", { || .T. }, { | x | fTrgN82Pes( "N82_VLTOCL" ) } )
	oStruN82:AddTrigger( "N82_QTLDC", "N82_PEFRCL", { || .T. }, { | x | fTrgN82Pes( "N82_PEFRCL" ) } )
	
	oStruNLB:AddTrigger( "NLB_QLDCTR", "NLB_DESQLD", { || .T. }, { | x | fTrgNLDRes( "NLB_DESQLD" ) } )
	
	oStruNLD:AddTrigger( "NLD_CODTIP", "NLD_DESTIP", { || .T. }, { | x | fTrgNLDRes( "NLD_DESTIP" ) } )
	oStruNLD:AddTrigger( "NLD_CODTIP", "NLD_QNTREP", { || .T. }, { | x | fTrgNLDRes( "NLD_QNTREP" ) } )
	oStruNLD:AddTrigger( "NLD_CODTIP", "NLD_DESCON", { || .T. }, { | x | fTrgNLDRes( "NLD_DESCON" ) } )
	oStruNLD:AddTrigger( "NLD_CODTIP", "NLD_VLUDES", { || .T. }, { | x | fTrgNLDRes( "NLD_VLUDES" ) } )
	oStruNLD:AddTrigger( "NLD_CODTIP", "NLD_VALDES", { || .T. }, { | x | fTrgNLDRes( "NLD_VALDES" ) } )
	
	oStruNLD:AddTrigger( "NLD_QTFRDO", "NLD_PESDES", { || .T. }, { | x | fTrgNLDPes( "NLD_PESDES" ) } )
	oStruNLD:SetProperty( "NLD_QTFRDO" , MODEL_FIELD_VALID, { |oField| fLoadFar(oField) })
		
	oStruNLE:AddTrigger( "NLE_CODTAX" ,"NLE_DESTAX", { || .T. }, { | x | fTrgNLE( "NLE_DESTAX" ) } )
	oStruNLE:AddTrigger( "NLE_CODTAX" ,"NLE_VALUNI", { || .T. }, { | x | fTrgNLE( "NLE_VALUNI" ) } )
	oStruNLE:AddTrigger( "NLE_QTDFAR" ,"NLE_VLRTOT", { || .T. }, { | x | fTrgNLE( "NLE_QTDFAR" ) } )
	oStruNLE:AddTrigger( "NLE_VALUNI" ,"NLE_VLRTOT", { || .T. }, { | x | fTrgNLE( "NLE_VLRTOT" ) } )
	oStruNLE:AddTrigger( "NLE_CODTAX" ,"NLE_CODTAB", { || .T. }, { | x | fTrgNLE( "NLE_CODTAB" ) } )
	
	oModel:AddFields( 'N82UNICO', Nil, oStruN82 )
	oModel:SetDescription( STR0001 ) //"Peso e Qualidade no Destino"
	oModel:GetModel( 'N82UNICO' ):SetDescription( STR0002 ) //"Peso e Qualidade no Destino
	
	oModel:AddGrid(  "NLBUNICO", "N82UNICO", oStruNLB,,,,, )
	oModel:GetModel( "NLBUNICO" ):SetDescription( STR0032 ) //"Qualidade no Destino"
	oModel:GetModel( "NLBUNICO" ):SetUniqueLine( { "NLB_SEQRES" } )
	oModel:GetModel( "NLBUNICO" ):SetOptional( .t. )
	oModel:GetModel( "NLBUNICO" ):SetNoDelete()
	oModel:GetModel( "NLBUNICO" ):SetNoInsert()
	oModel:SetRelation( "NLBUNICO", { { "NLB_FILIAL", "xFilial( 'NLB' )" }, { "NLB_CODINE", "N82_CODINE" }, { "NLB_PEDIDO", "N82_PEDIDO" }, { "NLB_FILORI", "N82_FILORI" }, { "NLB_ITEM", "N82_ITEM" } }, NLB->( IndexKey( 1 ) ) )
	
	oModel:AddGrid(  "NLDUNICO", "NLBUNICO", oStruNLD,,,,, )
	oModel:GetModel( "NLDUNICO" ):SetDescription( STR0034 ) //"Resultado Qualidade no Destino"
	oModel:GetModel( "NLDUNICO" ):SetUniqueLine( { "NLD_SEQRES" } )
	oModel:GetModel( "NLDUNICO" ):SetOptional( .t. )
	oModel:SetRelation( "NLDUNICO", { { "NLD_FILIAL", "xFilial( 'NLD' )" }, { "NLD_CODINE", "NLB_CODINE" }, { "NLD_PEDIDO", "NLB_PEDIDO" }, { "NLD_FILORI", "NLB_FILORI" }, { "NLD_ITEM", "NLB_ITEM" }, { "NLD_SEQTIP", "NLB_SEQRES" } }, NLD->( IndexKey( 1 ) ) )
		
	oModel:AddGrid(  "NLEUNICO", "N82UNICO", oStruNLE,,,,, )
	oModel:GetModel( "NLEUNICO" ):SetDescription( STR0033 ) //"Taxa de Serviços"
	oModel:GetModel( "NLEUNICO" ):SetUniqueLine( { "NLE_CODTIP", "NLE_CODTAX" } )
	oModel:GetModel( "NLEUNICO" ):SetOptional( .t. )
	oModel:SetRelation( "NLEUNICO", { { "NLE_FILIAL", "xFilial( 'NLE' )" }, { "NLE_CODINE", "N82_CODINE" }, { "NLE_PEDIDO", "N82_PEDIDO" }, { "NLE_FILORI", "N82_FILORI" }, { "NLE_ITEM", "N82_ITEM" }, { "NLE_CODTAB", "N82_CODTAB" } }, NLE->( IndexKey( 1 ) ) )
	
Return oModel

/*/{Protheus.doc} ViewDef()
Função que retorna a view para o modelo padrao da rotina
@type  Function
@author tamyris ganzenmueller
@since 28/09/2018
@version 1.0
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ViewDef()
	Local oModel   := FWLoadModel( 'OGAA910' )
	Local oView    := FWFormView():New()
	Local cCpoPeso := 'N82_PESLD2, N82_UNIMED, N82_UMEPRC, N82_QTLQIV, N82_VALUNI, N82_QNTFAR, N82_UTPESO, N82_PESMED, N82_QTLQDE, N82_VARPES, N82_DIFPES, N82_VALTOT, N82_STATUS, N82_QTLDC, N82_DIFPEC, N82_VARPEC, N82_VLTOCL, N82_PEFRCL, N82_MOEDA, N82_DESMOE '
	Local oStruN82Pes := FWFormStruct( 2, "N82", { |x| ALLTRIM(x)  $ cCpoPeso + ', N82_VLINVO' }) 
	Local oStruN82    := FWFormStruct( 2, "N82", { |x| !ALLTRIM(x) $ (cCpoPeso + 'N82_CODTAB, N82_DESTAB, N82_STAQUA, N82_STAPES')})
	Local oStruN82Qual:= FWFormStruct( 2, "N82", { |x| ALLTRIM(x)  $ 'N82_CODTAB, N82_DESTAB' }) 
	Local oStruN82TTax:= FWFormStruct( 2, "N82", { |x| ALLTRIM(x)  $ 'N82_TOTTAX' })
	Local oStruN82TQua:= FWFormStruct( 2, "N82", { |x| ALLTRIM(x)  $ 'N82_TOTQUA' }) 
	Local oStruNLB    := FWFormStruct( 2, 'NLB' )
	Local oStruNLD    := FWFormStruct( 2, 'NLD' ) 
	Local oStruNLE    := FWFormStruct( 2, 'NLE' )
	
	oStruN82:AddField( "N82_TOTDE1" ,'14' , '(-) ' + RetTitle("N82_TOTDES"), '(-) ' + RetTitle("N82_TOTDES") , {} , 'N' , PesqPict( "N82", "N82_TOTDES" ), NIL, NIL, .F., NIL, NIL, NIL, NIL, NIL, .T. )
	
	oStruNLB:RemoveField( "NLB_CODINE" )
	oStruNLB:RemoveField( "NLB_PEDIDO" )
	oStruNLB:RemoveField( "NLB_FILORI" )
	oStruNLB:RemoveField( "NLB_ITEM" )
	
	oStruNLD:RemoveField( "NLD_CODINE" )
	oStruNLD:RemoveField( "NLD_PEDIDO" )
	oStruNLD:RemoveField( "NLD_FILORI" )
	oStruNLD:RemoveField( "NLD_ITEM" )
	oStruNLD:RemoveField( "NLD_SEQTIP" )
		
	oStruNLE:RemoveField( "NLE_CODINE" )
	oStruNLE:RemoveField( "NLE_PEDIDO" )
	oStruNLE:RemoveField( "NLE_FILORI" )
	oStruNLE:RemoveField( "NLE_ITEM" )
	oStruNLE:RemoveField( "NLE_CODTAB" )
		
	oView:SetModel( oModel )
	oView:AddField( 'VIEW_N82'  , oStruN82,    'N82UNICO' )
	oView:AddField( 'VIEW_N82P' , oStruN82Pes, 'N82UNICO' )
	oView:AddField( 'VIEW_N82Q' , oStruN82Qual,'N82UNICO' )
	oView:AddField( 'VIEW_N82T' , oStruN82TTax,'N82UNICO' )
	oView:AddField( 'VIEW_N82TQ', oStruN82TQua,'N82UNICO' )
	oView:AddGrid ( 'VIEW_NLB'  , oStruNLB,    'NLBUNICO' )
	oView:AddGrid ( 'VIEW_NLD'  , oStruNLD,    'NLDUNICO' )
	oView:AddGrid(  'VIEW_NLE'  , oStruNLE,    'NLEUNICO' )
	
	oView:AddIncrementField( "VIEW_NLB", "NLB_SEQRES" )
	oView:AddIncrementField( "VIEW_NLD", "NLD_SEQRES" )
		
	oView:CreateHorizontalBox( "SUPERIOR" , 100 )
	
	oView:CreateFolder( "GRADES", "SUPERIOR")
	oView:AddSheet( "GRADES", "PASTA01", STR0009) //"Principal"
	oView:AddSheet( "GRADES", "PASTA02", STR0010) //"Peso no Destino"
	oView:AddSheet( "GRADES", "PASTA03", STR0032) //"Qualidade no Destino"
	oView:AddSheet( "GRADES", "PASTA04", STR0033) //"Taxas de Serviço"
	
	oView:CreateHorizontalBox( "PASTA_GERAL", 100, , , "GRADES", "PASTA01" ) 
	oView:CreateHorizontalBox( "PASTA_PESO" , 100, , , "GRADES", "PASTA02" )
	oView:CreateHorizontalBox( "PASTA_QUALI1", 10, , , "GRADES", "PASTA03" )
	oView:CreateHorizontalBox( "PASTA_QUALI2", 40, , , "GRADES", "PASTA03" )
	oView:CreateHorizontalBox( "PASTA_QUALI3", 40, , , "GRADES", "PASTA03" )
	oView:CreateHorizontalBox( "PASTA_QUALI4", 10, , , "GRADES", "PASTA03" )
	oView:CreateHorizontalBox( "PASTA_TAXAS1", 85, , , "GRADES", "PASTA04" )
	oView:CreateHorizontalBox( "PASTA_TAXAS2", 15, , , "GRADES", "PASTA04" )
	
	oView:SetOwnerView( "VIEW_N82" 	 , "PASTA_GERAL"  )
	oView:SetOwnerView( "VIEW_N82P"	 , "PASTA_PESO"   )
	oView:SetOwnerView( "VIEW_N82Q"	 , "PASTA_QUALI1" )
	oView:SetOwnerView( "VIEW_NLB" 	 , "PASTA_QUALI2" )
	oView:SetOwnerView( "VIEW_NLD"   , "PASTA_QUALI3" )
	oView:SetOwnerView( "VIEW_N82TQ" , "PASTA_QUALI4" )

	oView:SetOwnerView( "VIEW_NLE",  "PASTA_TAXAS1" )
	oView:SetOwnerView( "VIEW_N82T", "PASTA_TAXAS2" )
	
	oStruN82:AddGroup("GrpGeral"    , STR0054  , "1", 2) //"Geral"
	oStruN82:AddGroup("GrpConsol"    , STR0055  , "1", 2) //"Perda ou Ganho de Peso e Qualidade - Consolidado"
	oStruN82:AddGroup("GrpResult"    , STR0056  , "1", 2) //"Apuração do Resultado"
	
	oStruN82:SetProperty("N82_ITEM",    MVC_VIEW_GROUP_NUMBER, "GrpGeral")
	oStruN82:SetProperty("N82_CODINE",  MVC_VIEW_GROUP_NUMBER, "GrpGeral")
	oStruN82:SetProperty("N82_DESINE",  MVC_VIEW_GROUP_NUMBER, "GrpGeral")
	oStruN82:SetProperty("N82_FILORI",  MVC_VIEW_GROUP_NUMBER, "GrpGeral")
	oStruN82:SetProperty("N82_PEDIDO",  MVC_VIEW_GROUP_NUMBER, "GrpGeral")
	oStruN82:SetProperty("N82_CODPRO",  MVC_VIEW_GROUP_NUMBER, "GrpGeral")
	oStruN82:SetProperty("N82_DESPRO",  MVC_VIEW_GROUP_NUMBER, "GrpGeral")
	oStruN82:SetProperty("N82_LOJENT",  MVC_VIEW_GROUP_NUMBER, "GrpGeral")
	oStruN82:SetProperty("N82_CODENT",  MVC_VIEW_GROUP_NUMBER, "GrpGeral")
	oStruN82:SetProperty("N82_NOMENT",  MVC_VIEW_GROUP_NUMBER, "GrpGeral")
	oStruN82:SetProperty("N82_NLJENT",  MVC_VIEW_GROUP_NUMBER, "GrpGeral")
	oStruN82:SetProperty("N82_CODINV",  MVC_VIEW_GROUP_NUMBER, "GrpGeral")
	
	oStruN82:SetProperty("N82_TOTPES",  MVC_VIEW_GROUP_NUMBER, "GrpConsol")
	oStruN82:SetProperty("N82_TOTQUA",  MVC_VIEW_GROUP_NUMBER, "GrpConsol")
	oStruN82:SetProperty("N82_TOTTAX",  MVC_VIEW_GROUP_NUMBER, "GrpConsol")
	oStruN82:SetProperty("N82_TOTDES",  MVC_VIEW_GROUP_NUMBER, "GrpConsol")
		
	oStruN82:SetProperty("N82_VLINVO",  MVC_VIEW_GROUP_NUMBER, "GrpResult")
	oStruN82:SetProperty("N82_SLDINV",  MVC_VIEW_GROUP_NUMBER, "GrpResult")
	oStruN82:SetProperty("N82_TOTDE1",  MVC_VIEW_GROUP_NUMBER, "GrpResult")
	oStruN82:SetProperty("N82_TOTDE1" , MVC_VIEW_ORDEM, Soma1(oStruN82:GetProperty("N82_VLINVO",MVC_VIEW_ORDEM)) )
		
	oStruN82:SetProperty( "N82_TOTQUA" , MVC_VIEW_TITULO , ('(+) ' + RetTitle("N82_TOTQUA")) )
	oStruN82:SetProperty( "N82_TOTTAX" , MVC_VIEW_TITULO , ('(+) ' + RetTitle("N82_TOTTAX")) )
	oStruN82:SetProperty( "N82_TOTDES" , MVC_VIEW_TITULO , ('(=) ' + RetTitle("N82_TOTDES")) )
	oStruN82:SetProperty( "N82_SLDINV" , MVC_VIEW_TITULO , ('(=) ' + RetTitle("N82_SLDINV")) )
		
	oStruN82Pes:AddGroup("GrpPeso"   , STR0012  , "1", 2) //"Peso Líquido no Destino"
	oStruN82Pes:AddGroup("GrpFornec" , STR0013  , "1", 2) //"Relatório de Desembarque (Fornecedor)" 
	oStruN82Pes:AddGroup("GrpCliente", STR0014  , "1", 2) //"Relatório de Desembarque (Cliente)"
	
	oStruN82Pes:SetProperty("N82_QTLQIV",  MVC_VIEW_GROUP_NUMBER, "GrpPeso")
	oStruN82Pes:SetProperty("N82_QTLQDE",  MVC_VIEW_GROUP_NUMBER, "GrpPeso")
	oStruN82Pes:SetProperty("N82_UNIMED",  MVC_VIEW_GROUP_NUMBER, "GrpPeso")
	oStruN82Pes:SetProperty("N82_VALUNI",  MVC_VIEW_GROUP_NUMBER, "GrpPeso")
	oStruN82Pes:SetProperty("N82_VLINVO",  MVC_VIEW_GROUP_NUMBER, "GrpPeso")
	oStruN82Pes:SetProperty("N82_UMEPRC",  MVC_VIEW_GROUP_NUMBER, "GrpPeso")
	oStruN82Pes:SetProperty("N82_MOEDA" ,  MVC_VIEW_GROUP_NUMBER, "GrpPeso")
	oStruN82Pes:SetProperty("N82_DESMOE",  MVC_VIEW_GROUP_NUMBER, "GrpPeso")
	oStruN82Pes:SetProperty("N82_QNTFAR",  MVC_VIEW_GROUP_NUMBER, "GrpPeso")
	oStruN82Pes:SetProperty("N82_STATUS",  MVC_VIEW_GROUP_NUMBER, "GrpPeso")
	oStruN82Pes:SetProperty("N82_UTPESO",  MVC_VIEW_GROUP_NUMBER, "GrpPeso")

	oStruN82Pes:SetProperty("N82_PESLD2",  MVC_VIEW_GROUP_NUMBER, "GrpFornec")
	oStruN82Pes:SetProperty("N82_VARPES",  MVC_VIEW_GROUP_NUMBER, "GrpFornec")
	oStruN82Pes:SetProperty("N82_DIFPES",  MVC_VIEW_GROUP_NUMBER, "GrpFornec")
	oStruN82Pes:SetProperty("N82_VALTOT",  MVC_VIEW_GROUP_NUMBER, "GrpFornec")
	oStruN82Pes:SetProperty("N82_PESMED",  MVC_VIEW_GROUP_NUMBER, "GrpFornec")
			
	oStruN82Pes:SetProperty("N82_QTLDC",   MVC_VIEW_GROUP_NUMBER, "GrpCliente")
	oStruN82Pes:SetProperty("N82_VARPEC",  MVC_VIEW_GROUP_NUMBER, "GrpCliente")
	oStruN82Pes:SetProperty("N82_DIFPEC",  MVC_VIEW_GROUP_NUMBER, "GrpCliente")
	oStruN82Pes:SetProperty("N82_VLTOCL",  MVC_VIEW_GROUP_NUMBER, "GrpCliente")
	oStruN82Pes:SetProperty("N82_PEFRCL",  MVC_VIEW_GROUP_NUMBER, "GrpCliente")
		
	oView:SetCloseOnOk( {||.t.} )
	oView:SetViewCanActivate({ ||.t. })

Return oView


/** {Protheus.doc} fTrgN82Pes
Função criada para gatilhar as informações após informar o peso
@return:    cRet - conteudo do campo
@author:    Tamyris Ganzenmueller
@since:     28/09/2018
@Uso:       OGA830*/

Static Function fTrgN82Pes( cOpc )
	Local oModel	:= FwModelActive()
	Local oN82		:= oModel:GetModel( "N82UNICO" )
	Local xRet      := 0
	Local cCodPro   := oN82:GetValue("N82_CODPRO")
	Local cUnMedPes := Posicione("SB1",1,xFilial("SB1")+cCodPro,'B1_UM')
	Local cUnMedPrc := Posicione("SB5",1,xFilial("SB5")+cCodPro,'B5_UMPRC') 
	Local nQtLqDePrc := Round ( ConvUN(oN82:GetValue("N82_QTLQDE") , 1 , cCodPro, cUnMedPes, cUnMedPrc  ) , TamSX3("N82_QTLQDE")[2] ) 
	Local nQtLqInPrc := Round ( ConvUN(oN82:GetValue("N82_QTLQIV") , 1 , cCodPro, cUnMedPes, cUnMedPrc  ) , TamSX3("N82_QTLQDE")[2] )
	Local nTotTax	:= oN82:GetValue("N82_TOTTAX")
	Local nTotQua	:= oN82:GetValue("N82_TOTQUA")
	Local cTipo		:= oN82:GetValue("N82_UTPESO")
	Local nTotDes	:= 0

	Do Case
		Case cOpc == "N82_PESLD2"
		xRet := nQtLqDePrc
		
		Case cOpc == "N82_DIFPES"
		xRet := Round(  nQtLqDePrc - nQtLqInPrc , TamSX3("N82_DIFPES")[2]  )
		
		Case cOpc == "N82_VARPES"
		xRet := Round ( ( nQtLqDePrc /  nQtLqInPrc - 1) * 100 , TamSX3("N82_VARPES")[2]  )
		
		Case cOpc == "N82_VALTOT"
		xRet := Round ( ( nQtLqDePrc - nQtLqInPrc ) * oN82:GetValue("N82_VALUNI") , TamSX3("N82_VALTOT")[2])
		If cTipo == '1' 
			nTotDes := nTotTax + nTotQua + xRet
			oN82:SetValue("N82_TOTDES", nTotDes)
			oN82:SetValue("N82_TOTDE1", nTotDes)
			oN82:SetValue("N82_TOTPES", xRet)
			oN82:SetValue("N82_SLDINV", oN82:GetValue("N82_VLINVO") + nTotDes)
		endif
		
		Case cOpc == "N82_PESMED"
		xRet := Round ( nQtLqDePrc / oN82:GetValue("N82_QNTFAR") , TamSX3("N82_PESMED")[2] )
		
		Case cOpc == "N82_DIFPEC"
		xRet := Round(oN82:GetValue("N82_QTLDC") - nQtLqInPrc, TamSX3("N82_DIFPEC")[2]) 
		
		Case cOpc == "N82_VARPEC"
		xRet := Round(( oN82:GetValue("N82_QTLDC") /  nQtLqInPrc -1 ) * 100, TamSX3("N82_VARPEC")[2])
		
		Case  cOpc == "N82_VLTOCL" 
		xRet :=  Round(( oN82:GetValue("N82_QTLDC") -  nQtLqInPrc ) * oN82:GetValue("N82_VALUNI"), TamSX3("N82_VLTOCL")[2])
		If cTipo == '2' 
			nTotDes := nTotTax + nTotQua + xRet
			oN82:SetValue("N82_TOTDES", nTotDes)
			oN82:SetValue("N82_TOTDE1", nTotDes)
			oN82:SetValue("N82_TOTPES", xRet)
			oN82:SetValue("N82_SLDINV", oN82:GetValue("N82_VLINVO") + nTotDes)
		endif
	
		Case cOpc == "N82_PEFRCL"
		xRet := Round(oN82:GetValue("N82_QTLDC")  / oN82:GetValue("N82_QNTFAR"), TamSX3("N82_PEFRCL")[2])

		Case  cOpc == "N82_TOTPES" 
		If cTipo == '1' 
			xRet := oN82:GetValue("N82_VALTOT")
		else 
			xRet := oN82:GetValue("N82_VLTOCL")
		endif
			nTotDes := nTotTax + nTotQua + xRet
			oN82:SetValue("N82_TOTDES", nTotDes)
			oN82:SetValue("N82_TOTDE1", nTotDes)
			oN82:SetValue("N82_SLDINV", oN82:GetValue("N82_VLINVO") + nTotDes)
		
	EndCase

return xRet

/*/{Protheus.doc} ConvUN
//Converter unidade de medida
@author tamyris.g	
@since 24/09/2018
@version 1.0
@param nValor - Valor que será convertido
       nTipo - 1 - conversão de volume / 2-conversão de preço
@type function
/*/
Static Function ConvUN(nValor,nTipo,cCodPro,cUnidDe,cUnidAte)
	Local nQtUM := 1
	
	If cUnidDe <> cUnidAte
		If nTipo == 1 //Conversão de volume
			nQtUM	:= AGRX001(cUnidDe, cUnidAte ,1, cCodPro)
		Else //Conversão do preço
			nQtUM	:= AGRX001(cUnidAte, cUnidDe ,1, cCodPro)
		EndIF
	EndIf
	
	nValor := nvalor * nQtUM
	
Return nValor

/*/{Protheus.doc} OGAA910APR
//Função para aprovação do peso certificado
@author tamyris.g	
@since 11/10/2018
@version 1.0
@param 
@type function
/*/
Function OGAA910APR()
	Local oMsg     := .F.
	Local oRadio   := Nil
	Local nRadio   := 1
	Local cMsgMemo := TamSX3("NK9_MSGMEM")
	Local cTitmsg  := ""
	Local nOpcao   := 2

	IF Empty(N82->N82_QTLQDE) //Não tem peso destino informado
		Help( , , STR0021, , STR0022, 1, 0 ) //AJUDA ## Peso no Destino não foi informado
		Return .T.
	EndIF
	
	IF N82->N82_STAPES <> '2' //2-Aguardando Aprovação
		Help( , , STR0021, , STR0023, 1, 0 ) //AJUDA ## Status deve ser igual a 'Aguardando Aprovação'
		Return .T.
	EndIF

	//Verifica no cadastro de aprovadores do processo(OGAA760) se o usuário tem permissão de executar a ação de acordo com a faixa de tolerância de variação.
	If .Not. ValidTol('1')
		Return .T.
	EndIf

	cTitmsg  := STR0017 //"Aprovar Peso"

	oDlg	:= TDialog():New(350,406,638,795,cTitmsg,,,,,CLR_BLACK,CLR_WHITE,,,.t.) 
	oDlg:lEscClose := .f.

	@ 038,008 SAY STR0035 PIXEL //"Ação: "
	@ 038,035 Radio oRadio VAR nRadio;
	ITEMS STR0036,; //"Aprovar"
		  STR0037 ; //"Rejeitar"
	3D SIZE 100,20 OF oDlg PIXEL 
	@ 058,008 SAY " " PIXEL
	@ 058,008 SAY STR0029 PIXEL	
	@ 070,008 GET oMsg Var cMsgMemo OF oDlg Multiline Size 172,062 PIXEL 	

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpcao := 1, oDlg:End()},{|| nOpcao := 0,oDlg:End()}) CENTERED
	
	If nOpcao == 1

		If Vazio(cMsgMemo)
			cMsgMemo := IIF( nRadio == 1, STR0017, STR0038)//"Aprovar Peso"###"Rejeitar Peso"
		EndIf

		cTitmsg := IIF( nRadio == 1, STR0017, STR0038)//"Aprovar Peso"###"Rejeitar Peso"

		fAtuSts('P', Iif(nRadio == 1, '3', '1'), cTitmsg, cMsgMemo)

	Else
		Return .F.
	EndIf
	
Return .T.


/*/{Protheus.doc} ValToler()
Verifica no cadastro de aprovadores do processo(OGAA760) se o usuário tem permissão de executar a ação de acordo com a faixa de tolerância de variação.
@type  Function
@author tamyris.g	
@since 01/10/2018
@version 1.0
@param cOpcao, caracter, tipo do processo a ser verificado.
@return lRet, logical, True or False.
@example
SX5: 020 - Aprovar Peso Destino
/*/
Static Function ValidTol(cOpcao)
	Local lRet     := .F.
	Local cGrupo   := Posicione('SB1', 1, xFilial('SB1') + N82->N82_CODPRO, 'B1_GRUPO')
	Local nVaria   := 0
	Local cProcess := ""
	
	If cOpcao = '1' //Peso
		cProcess := '020'
		nVaria := N82->N82_VARPES
	ElseIf cOpcao = '2' //Qualidade
		cProcess := '030'
		nVaria := (N82->N82_TOTQUA * 100) / N82->N82_VLINVO
	Else //Consolidação Peso e Qualidade no Destino
		cProcess := '050'
		nVaria := (N82->N82_TOTDES * 100) / N82->N82_VLINVO
	EndIf
	
	DbSelectArea("N99")
	DbGoTop()
	While !N99->( Eof() )
		If ((N99->N99_COPROD == N82->N82_CODPRO) .Or. (Iif(!Empty(cGrupo) .And. cGrupo == N99->N99_GRPROD, .T., .F.))) .And. (AllTrim(N99->N99_CODPRO) == cProcess)
			If !Empty(N99->N99_CODUSU) 
				If N99->N99_CODUSU == RetCodUsr()
					If (nVaria >= N99->N99_PERINI .And. nVaria <= N99->N99_PERFIN)
						lRet := .T.
					EndIf
					EXIT
				EndIf
			Else 
				If aScan( UsrRetGrp( cUserName, RetCodUsr()), AllTrim(N99->N99_GRPUSU)) > 0 
					If (nVaria >= N99->N99_PERINI .And. nVaria <= N99->N99_PERFIN)
						lRet := .T.
					EndIf
					EXIT
				EndIf
			EndIf
		EndIf	
		N99->(dbSkip())
	EndDo

	If !lRet .And. (N99->N99_CODUSU != RetCodUsr())
		Help(" ", 1, ".OGA710000002.")	
		return .F.
	Elseif !lRet
								
		If cOpcao = '1' //Peso
			cString := STR0024 + CHR(13)+CHR(10) + STR0025 + cValToChar(N99->N99_PERINI) + "% " + STR0026 + cValToChar(N99->N99_PERFIN) + "%. " + STR0027 + cValToChar(nVaria) + "%." 
			MSGSTOP(cString, STR0028 )
			/* "Ação não permitida!"
			"Usuário não tem permissão para realizar esta ação conforme faixa de tolerância miníma: maxíma: "
			"A variação entre peso certificado e peso remetido da instrução de embarque foi de: "
			"%, ajuste os pesos da instrução de embarque ou aumente a faixa de aprovação do usuário no cadastro de Aprovadores do Processo." 
			*/
		ElseIf cOpcao = '2' //Qualidade
			cString := STR0024 + CHR(13)+CHR(10) + STR0025 + cValToChar(N99->N99_PERINI) + "% " + STR0026 + cValToChar(N99->N99_PERFIN) + "%. " + STR0039 + cValToChar(nVaria) + "%." 
			MSGSTOP(cString, STR0040 )
			/* "Ação não permitida!"
			"Usuário não tem permissão para realizar esta ação conforme faixa de tolerância miníma: maxíma: "
			"A variação entre o valor dos descontos de qualidade e o valor da invoice foi de: "
			"Ajuste os resultados de qualidade ou aumente a faixa de aprovação do usuário no cadastro de Aprovadores do Processo." 
			*/
		Else //Consolidação Peso e Qualidade no Destino
			cString := STR0024 + CHR(13)+CHR(10) + STR0025 + cValToChar(N99->N99_PERINI) + "% " + STR0026 + cValToChar(N99->N99_PERFIN) + "%. " + STR0048 + cValToChar(nVaria) + "%." 
			MSGSTOP(cString, STR0049 )
			/* "Ação não permitida!"
			"Usuário não tem permissão para realizar esta ação conforme faixa de tolerância miníma: maxíma: "
			"A variação entre a consolidação peso e qualidade no destino e o valor da invoice foi de: "
			"Ajuste os resultados de peso, qualidade ou serviços ou aumente a faixa de aprovação do usuário no cadastro de Aprovadores do Processo." 
			*/
		EndIf
	EndIf

Return lRet

/** {Protheus.doc} GrvModelo
Função que grava o modelo de dados após a confirmação
@param: 	oModel - Modelo de dados
@return:	.t. - sempre verdadeiro
@author: 	Tamyris Ganzenmueller
@since: 	01/10/2018
@Uso: 		OGAA910
*/
Static Function GrvModelo( oModel )
	Local nOperation := oModel:GetOperation()
	Local oModelN82  := oModel:GetModel( "N82UNICO" )

	If nOperation == MODEL_OPERATION_UPDATE
		If oModelN82:GetValue( "N82_STAPES" ) == "1" .And. !Empty(oModelN82:GetValue( "N82_QTLQDE" ))
			oModelN82:SetValue("N82_STAPES", "2" )
		EndIf

		If oModelN82:GetValue( "N82_STAQUA" ) == "1" .And. !Empty(oModelN82:GetValue( "N82_TOTQUA" ))
			oModelN82:SetValue("N82_STAQUA", "2" )
		EndIf

		If oModelN82:GetValue( "N82_STAPES" ) == '3' .And. oModelN82:GetValue( "N82_STAQUA" ) == '3'
			oModelN82:SetValue("N82_STATUS", "2" )
		EndIf

	EndIf

	FWFormCommit( oModel )

Return( .t. )

/** {Protheus.doc} OGAA910HIS
Descrição: Mostra em tela de Histórico  
@param: 	Nil
@author: 	Tamyris Ganzenmueller
@since: 	11/08/2017
@Uso: 		OGAA910HIS 
*/
Function OGAA910HIS()
	Local cChaveI := "N82->("+Alltrim(AGRSEEKDIC("SIX","N821",1,"CHAVE"))+")"
	Local cChaveA := &(cChaveI)+Space(Len(NK9->NK9_CHAVE)-Len(&cChaveI))

	AGRHISTTABE("N82",cChaveA)
Return

/** {Protheus.doc} fTipQuali
Função criada para gatilhar as informações após informar o código da tabela
@return:    
@author:    Christopher Miranda
@since:     10/10/2018
**/
Function fTipQuali()

	Local oView      := FWViewActive()
	Local oModel  	 := FwModelActive()
	Local oGrdNLB 	 := oModel:GetModel("NLBUNICO")
	Local oGrdNLD 	 := oModel:GetModel("NLDUNICO")
	Local oStruNLB   := oGrdNLB:GetStruct()
	Local aCampNLB   := oStruNLB:GetFields()
	Local oGrdN82 	 := oModel:GetModel("N82UNICO")
	Local nX	 	 := 0 
	Local nY		 := 0
	Local cCodigo    := oGrdN82:GetValue('N82_CODTAB')
	Local nFardos	 := oGrdN82:GetValue('N82_QNTFAR')
	Local cDescr	 := POSICIONE('NL8',1,XFILIAL('NL8')+cCodigo ,'NL8_DESTAB')
	Local aAreaNL9   := {}
	Local nQtFAm     := 0
	Local nVlrIni    := 0
	Local nVlrFim    := 0
	Local cCodUns    := ""
	
	oGrdNLB:SetNoInsert( .f. )
	oGrdNLB:SetNoDelete( .f. )

	For nX := 1 to oGrdNLB:Length()

		oGrdNLB:GoLine( nX )
		
		For nY := 1 to oGrdNLD:Length()
			oGrdNLD:GoLine( nY )
			If !oGrdNLD:IsDeleted() 
				oGrdNLD:DeleteLine()
			EndIf
		Next nY
		
		If !oGrdNLB:IsDeleted() .And. !empty(oGrdNLB:GetValue('NLB_CODTIP'))
			oGrdNLB:DeleteLine()
		EndIf

	Next nX

	oView:Refresh() 

	oGrdNLB:SetNoInsert( .f. )
	oGrdNLB:SetNoDelete( .f. )
	
	nY := 1
	DbselectArea('NL9')
	NL9->(dbGoTop())
	NL9->(dbSetOrder(1))
	If NL9->(dbSeek( xFilial( "NL9" ) + cCodigo))
		While  NL9->(!EOF()) .And. NL9->NL9_CODTAB = cCodigo

			oGrdNLB:GoLine(oGrdNLB:Length())

			if nY > 1 .Or. oGrdNLB:IsDeleted()
				aAreaNL9 :=  NL9->(GetArea())
				oGrdNLB:AddLine()
				RestArea(aAreaNL9)
			EndIf
						
			oGrdNLB:LoadValue( "NLB_SEQRES", STRzero(nY,6) )
			oGrdNLB:LoadValue( "NLB_CODTIP", NL9->NL9_CODTIP )
			oGrdNLB:LoadValue( "NLB_DESTIP", NL9->NL9_DESTIP )
			oGrdNLB:LoadValue( "NLB_PERFRD", NL9->NL9_PERAMO )
			oGrdNLB:LoadValue( "NLB_TPCALA", NL9->NL9_TPCALA )
			oGrdNLB:LoadValue( "NLB_TOCALD", NL9->NL9_TPCALD )

			nQtFAm :=  Round( NL9->NL9_PERAMO * (nFardos / 100), TamSX3("N82_QNTFAR")[2] )

			oGrdNLB:LoadValue( "NLB_QTFRDA", IIF(nQtFAm < 1, 1, nQtFAm) )
			
			If NL9->NL9_TIPO <> '1' //Nenhum
				
				//Regra fiscal da IE - Considera primeira regra com a filial de origem
				DbselectArea('N7S')
				N7S->(dbGoTop())
				N7S->(dbSetOrder(3)) //N7S_FILIAL+N7S_CODINE+N7S_FILORG
				If N7S->(dbSeek( xFilial("N7S") + N82->N82_CODINE + N82->N82_FILORI ))
				 	
				 	//Contratos
				 	DbSelectArea("NJR") //Contratos
					NJR->(DbSetOrder(1))
					If NJR->(DbSeek( xFilial("NJR") + N7S->N7S_CODCTR ))
						
						If NL9->NL9_TIPO == '2' //Universal Standard
							cCodUns := POSICIONE('DXA',1,XFILIAL('DXA')+NJR->NJR_TIPALG ,'DXA_CODUNS')
						
						ElseIf NL9->NL9_TIPO == '3' //Padrão HVI
							cAliasQry := GetNextAlias()
							cQuery := "   SELECT N7H_VLRINI, N7H_VLRFIM "
							cQuery += "     FROM " + RetSqlName('N7H') + " N7H "
							cQuery += "    WHERE N7H.N7H_FILIAL = '" + xFilial("N7H") + "'"
							cQuery += "      AND N7H.N7H_CODCTR = '" + N7S->N7S_CODCTR + "'"
							cQuery += "      AND N7H.N7H_CAMPO  = '" + NL9->NL9_CODHVI + "'"
							cQuery += "      AND N7H.D_E_L_E_T_ = ' ' "
							cQuery := ChangeQuery( cQuery )
							dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
							(cAliasQry)->(dbGoTop())
							If !(cAliasQry)->( Eof() )		
								nVlrIni := (cAliasQry)->N7H_VLRINI
								nVlrFim := (cAliasQry)->N7H_VLRFIM
							EndIf
							(cAliasQry)->(DbCloseArea())  
						EndIF
						
						cAliasQry := GetNextAlias()
						cQuery := "   SELECT NLA_SEQTIP, NLA_DESRES "
						cQuery += "     FROM " + RetSqlName('NLA') + " NLA "
						cQuery += "    WHERE NLA.NLA_FILIAL = '" + NL9->NL9_FILIAL + "'"
						cQuery += "      AND NLA.NLA_CODTAB = '" + NL9->NL9_CODTAB + "'"
						cQuery += "      AND NLA.NLA_CODTIP = '" + NL9->NL9_CODTIP + "'"
						If NL9->NL9_TIPO == '2' //Universal Standard
							cQuery += "      AND NLA.NLA_CODUNS = '" + cCodUns + "'"
						ElseIf NL9->NL9_TIPO == '3' //Padrão HVI
							cQuery += "      AND NLA.NLA_VALINI >= '" + Str(nVlrIni) + "'"
							cQuery += "      AND NLA.NLA_VALFIM <= '" + Str(nVlrFim) + "'"
						EndIf
						cQuery += "      AND NLA.D_E_L_E_T_ = ' ' "
						cQuery := ChangeQuery( cQuery )
						dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
						(cAliasQry)->(dbGoTop())
						If !(cAliasQry)->( Eof() )		
							oGrdNLB:SetValue( "NLB_QLDCTR", (cAliasQry)->NLA_SEQTIP )
						EndIf
						
						(cAliasQry)->(DbCloseArea())  
						
					EndIf			
					NJR->(DbCloseArea())
				EndIf
				N7S->(DbCloseArea())
			EndIf

			nY ++ 

			NL9->(DbSkip())
			
		Enddo

		oGrdNLB:GoLine(1)
		oView:Refresh() 

	EndIf
	NL9->(DbCloseArea())

	oGrdNLB:SetNoInsert( .T. )
	oGrdNLB:SetNoDelete( .T. )

	//Bloqueia a ediÃ§Ã£o dos campos
	For nX := 1 To Len(aCampNLB)

		If .Not. aCampNLB[nX, 3] $ "NLB_QLDCTR|NLB_TPCALA|NLB_TOCALD"

			oStruNLB:SetProperty( aCampNLB[nX, 3] , MODEL_FIELD_WHEN , { | | .F. } )

		EndIf

	Next nX

	fLoadNLE()	

return(cDescr)

/*/{Protheus.doc} fTrgNLE(cOpc)
(long_description)
@type  Static Function
@author rafael.kleestadt
@since 10/10/2018
@version 1.0
@param cOpc, caracter, campo que está sendo editado 
@return xRet, undefined, conteúdo a ser atribuído no retorno
@example
(examples)
@see (links_or_references)
/*/
Static Function fTrgNLE(cOpc)
	Local oModel   := FwModelActive()
	Local oNLE	   := oModel:GetModel( "NLEUNICO" )
	Local oN82	   := oModel:GetModel( "N82UNICO" )
	Local xRet     := NIL
	Local cCodTab  := NLC->NLC_CODTAB
	Local cCodTip  := NLC->NLC_CODTIP
	Local aArea    := NLE->(GetArea())
	Local nLinNLE  := oNLE:GetLine()
	Local cTipCalc := ""

	If Empty(cCodTab)
		cCodTab := oNLE:GetValue("NLE_CODTAB")	
	EndIf

	If Empty(cCodTab)
		cCodTip := oNLE:GetValue("NLE_CODTIP")	
	EndIf

	Do Case

		Case cOpc == "NLE_DESTAX"

			xRet := POSICIONE('NLC',1,XFILIAL('NLC')+cCodTab+cCodTip,'NLC_DESCRI')

		Case cOpc == "NLE_VALUNI"

			xRet := POSICIONE('NLC',1,XFILIAL('NLC')+cCodTab+cCodTip,'NLC_VALOR')

		Case cOpc == "NLE_QTDFAR" .OR. cOpc == "NLE_VLRTOT"

			If !Empty(oNLE:GetValue('NLE_CODTIP')) .And. !Empty(oNLE:GetValue('NLE_CODTAX'))

				cTipCalc := Posicione('NLC', 1, FwxFilial('NLC')+oN82:GetValue('N82_CODTAB')+oNLE:GetValue('NLE_CODTIP')+oNLE:GetValue('NLE_CODTAX'), 'NLC_CALCUL') //1=Qtd Fardos Fora;2=Qtd Total Fardos;3=Taxa Única
				
				nTaxUnic := Posicione('NLC', 1, FwxFilial('NLC')+oN82:GetValue('N82_CODTAB')+oNLE:GetValue('NLE_CODTIP')+oNLE:GetValue('NLE_CODTAX'), 'NLC_VALOR')

			EndIf

			If !Empty(cTipCalc)

				Do Case
					Case cTipCalc = '1' //Qtd Fardos Fora
						xRet := oNLE:GetValue("NLE_QTDFAR") * oNLE:GetValue("NLE_VALUNI")
					Case cTipCalc = '2' //Qtd Total Fardos
						xRet := oN82:GetValue("N82_QNTFAR") * oNLE:GetValue("NLE_VALUNI")
					Case cTipCalc = '3' //Taxa Única
						xRet := nTaxUnic
				End Case

			Else
				xRet := oNLE:GetValue("NLE_QTDFAR") * oNLE:GetValue("NLE_VALUNI")
			EndIf

		Case cOpc == "NLE_CODTAB"

			xRet := cCodTab	

	End Case

	oNLE:GoLine(nLinNLE)

	RestArea(aArea)

Return xRet

/*/{Protheus.doc} fLoadNLE()
Função responsavel pela carga automatica da grid de taxas de serviços.
@type  Static Function
@author rafael.kleestadt
@since 11/10/2018
@version 1.0
@param param, param_type, param_descr
@return true, logycal, true or false
@example
(examples)
@see (links_or_references)
/*/
Static Function fLoadNLE()
	Local oModel    := FwModelActive()
	Local oGrdNLB   := oModel:GetModel("NLBUNICO")
	Local oGrdN82   := oModel:GetModel("N82UNICO")
	Local oGrdNLE   := oModel:GetModel("NLEUNICO")
	Local nX	    := 0
	Local nY        := 1 
	Local cDesTab   := AllTrim(Posicione("NL8", 1, xFilial( "NL8" ) + oGrdN82:GetValue('N82_CODTAB'), "NL8_DESTAB"))
	Local cQryNLC   := ""
	Local cAliasQry := GetNextAlias()

	For nX := 1 to oGrdNLE:Length()

		oGrdNLE:GoLine( nX )

		If .Not. oGrdNLE:IsDeleted()
			
			oGrdNLE:DeleteLine()

		EndIf

	Next nX

	For nX := 1 to oGrdNLB:Length()

		oGrdNLB:GoLine( nX )

		If .Not. oGrdNLB:IsDeleted()

			cQryNLC := " SELECT * "
			cQryNLC += "   FROM " + RetSqlName("NLC") + " NLC "
			cQryNLC += "  WHERE NLC.D_E_L_E_T_ = ' ' "
			cQryNLC += "    AND NLC.NLC_FILIAL = '" + xFilial( "NLC" ) + "' "
			cQryNLC += "    AND NLC.NLC_CODTAB = '" + oGrdN82:GetValue('N82_CODTAB') + "' "
			cQryNLC += "    AND NLC.NLC_CODTIP = '" + oGrdNLB:GetValue('NLB_CODTIP') + "' "

			cQryNLC := ChangeQuery(cQryNLC)
			DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQryNLC),cAliasQry,.F.,.T.)

			dbSelectArea(cAliasQry)
			(cAliasQry)->(dbGoTop())
			If (cAliasQry)->( !Eof() )
				While (cAliasQry)->( !Eof() )

					oGrdNLE:GoLine(oGrdNLE:Length())

					if nY > 1 .Or. oGrdNLE:IsDeleted()
						oGrdNLE:AddLine()
					EndIf
 
					oGrdNLE:LoadValue( "NLE_DESTAB", cDesTab                 )
					oGrdNLE:LoadValue( "NLE_CODTIP", (cAliasQry)->NLC_CODTIP )			
					oGrdNLE:LoadValue( "NLE_DESTIP", POSICIONE('NL9',1,XFILIAL('NL9')+oGrdN82:GetValue('N82_CODTAB')+oGrdNLB:GetValue('NLB_CODTIP'),'NL9_DESTIP') )			
					oGrdNLE:LoadValue( "NLE_CODTAX", (cAliasQry)->NLC_CODTAX )
					oGrdNLE:LoadValue( "NLE_DESTAX", (cAliasQry)->NLC_DESCRI )
					oGrdNLE:LoadValue( "NLE_VALUNI", (cAliasQry)->NLC_VALOR  )
					
					IF (cAliasQry)->NLC_CALCUL = '2' //Qtd Total Fardos
						oGrdNLE:LoadValue( "NLE_QTDFAR", oGrdN82:GetValue("N82_QNTFAR")  )
						oGrdNLE:LoadValue( "NLE_VLRTOT", (cAliasQry)->NLC_VALOR * oGrdN82:GetValue("N82_QNTFAR")  )
					ElseIF (cAliasQry)->NLC_CALCUL = '3' //Taxa Única
						oGrdNLE:LoadValue( "NLE_VLRTOT", (cAliasQry)->NLC_VALOR )
					EndIF
				
					nY ++ 

					(cAliasQry)->( DbSkip() )
				EndDo
			EndIf
			(cAliasQry)->(DbcloseArea())

		EndIf

	Next nX

Return .T.

/*{Protheus.doc} OGAA910FQ()
Função para filtrar os resultados da consulta padrão de resultados de qualidade
@type Function
@author Tamyris Ganzenmueller
@since 11/10/2018
@version 1.0.
@param param, param_type, param_descr
@return cRet, Caractere, expressão com o filtro para a consulta padrão
@example
(examples)
@see (links_or_references)*/
Function OGAA910FQ()
	Local oModel    := FwModelActive()
	Local oModelN82 := oModel:GetModel("N82UNICO")
	Local oModelNLB := oModel:GetModel("NLBUNICO")
	Local cRet      := "##"
	
	Local cCodTab	:= oModelN82:GetValue("N82_CODTAB")
	Local cCodTip	:= oModelNLB:GetValue("NLB_CODTIP")
			
	cRet := "@#"
	cRet += "( NLA_CODTAB = '" + cCodTab + "' .AND. NLA_CODTIP = '" + cCodTip +  "' )"
	cRet += "@#"
	
Return cRet 

/*{Protheus.doc} fValidRes()
Valida Resultado informado
@type Function
@author Tamyris Ganzenmueller
@since 11/10/2018
@version 1.0.
@param param, param_type, param_descr
@return lRet
@see (links_or_references)*/
Static Function fValidRes(cOpcao)
	Local oModel    := FwModelActive()
	Local oModelN82 := oModel:GetModel("N82UNICO")
	Local oModelNLB := oModel:GetModel("NLBUNICO")
	Local oModelNLD := oModel:GetModel("NLDUNICO")
	Local cCodTab	:= oModelN82:GetValue("N82_CODTAB")
	Local cCodTip	:= oModelNLB:GetValue("NLB_CODTIP")
	Local cSeqTip	:= IIf (cOpcao == "NLB_QLDCTR", oModelNLB:GetValue("NLB_QLDCTR") , oModelNLD:GetValue("NLD_CODTIP"))
	Local lRet := .T.
	Local nX      := 0
	
	If cOpcao == "NLB_QLDCTR" .Or. cOpcao == "NLD_CODTIP"
		lRet := ExistCpo("NLA", cCodTab + cCodTip + cSeqTip)
	EndIF
	
	//Não permite alterar se tem resultados informados
	If lRet .And. cOpcao $ "NLB_QLDCTR|NLB_TPCALA|NLB_TOCALD"
		For nX := 1 to oModelNLD:Length()
			oModelNLD:GoLine( nX )
			If !oModelNLD:IsDeleted() .And. !Empty(oModelNLD:GetValue("NLD_CODTIP") )
				lRet := .F.
			EndIf
		Next nX
		If !lRet 
			MsgAlert(STR0043 + CRLF + STR0044) //"Alteração não permitida" "Já existem resultados informados para este tipo de qualidade"
		EndIf
	EndIF
	
Return lRet

/*{Protheus.doc} fTrgNLDRes()
Gatilho para Resultado de Qualidade
@type Function
@author Tamyris Ganzenmueller
@since 11/10/2018
@version 1.0.
@param param, param_type, param_descr
@return lRet
@see (links_or_references)*/
Static Function fTrgNLDRes(cOpcao)
	Local oModel    := FwModelActive()
	Local oModelN82 := oModel:GetModel("N82UNICO")
	Local oModelNLB := oModel:GetModel("NLBUNICO")
	Local oModelNLD := oModel:GetModel("NLDUNICO")
	Local cCodTab	:= oModelN82:GetValue("N82_CODTAB")
	Local cCodTip	:= oModelNLB:GetValue("NLB_CODTIP")
	Local cSeqTip	:= oModelNLD:GetValue("NLD_CODTIP")
	Local cRet := ""
	
	Local nDescCtr := 0
	Local nDescInf := 0
	Local nDesc    := 0
	Local nOper    := ""
	Local cQldCtr  := ""
	Local cQldInf  := ""
	
	If cOpcao == 'NLD_DESTIP'
		cRet := Posicione("NLA",1,xFilial("NLA")+cCodTab+cCodTip+cSeqTip,'NLA_DESRES')
	ElseIf cOpcao == 'NLD_QNTREP'
		cRet := Round ( oModelN82:GetValue("N82_QNTFAR") / oModelNLB:GetValue("NLB_QTFRDA"), 0)
	ElseIF cOpcao == 'NLB_DESQLD'
		cSeqTip := oModelNLB:GetValue("NLB_QLDCTR")
		cRet := Posicione("NLA",1,xFilial("NLA")+cCodTab+cCodTip+cSeqTip,'NLA_DESRES')
	EndIF
	
	//Cálculo do Desconto
	cQldCtr  := oModelNLB:GetValue("NLB_QLDCTR")
	cQldInf  := cSeqTip
	
	If cOpcao $ "NLD_DESCON|NLD_VLUDES|NLD_VALDES" .And. cQldCtr <> cQldInf //Qualidade do Contrato diferente da informada
		
		nDescCtr := Posicione("NLA",1,xFilial("NLA")+cCodTab+cCodTip+cQldCtr,'NLA_PERDES')
		nDescInf := Posicione("NLA",1,xFilial("NLA")+cCodTab+cCodTip+cQldInf,'NLA_PERDES')
		
		//Determina a operação, se for ágio ou deságio
		If nDescInf > nDescCtr //Deságio
			nOper := oModelNLB:GetValue("NLB_TOCALD")  
		Else //Ágio
			nOper := oModelNLB:GetValue("NLB_TPCALA") 
		EndIf
		
		Do Case
			Case nOper == "2" //Diferença
				nDesc := nDescCtr - nDescInf  
			Case nOper == "3" //Soma
				nDesc := 0
				
				If cQldCtr < cQldInf
					cTipDe  := cQldCtr 
					cTipAte := cQldInf
				else
					cTipDe  := cQldInf 
					cTipAte := cQldCtr
				EndIf
								
				aAreaNLA :=  NLA->(GetArea())
				DbselectArea('NLA')
				NLA->(dbGoTop())
				NLA->(dbSetOrder(1))
				If NLA->(dbSeek( xFilial("NLA") +cCodTab+cCodTip+cTipDe ))
					While  NLA->(!EOF()) .And. NLA->(NLA_FILIAL+NLA_CODTAB+NLA_CODTIP) == xFilial("NLA") +cCodTab+cCodTip ; 
					                     .And. NLA->NLA_SEQTIP <= cTipAte
					    If NLA->NLA_SEQTIP <> cQldCtr //Não considera o próprio valor
					    	nDesc += NLA->NLA_PERDES
					    EndIF
			  
                        NLA->(DbSkip())
					Enddo
				EndIf
				NLA->(DbCloseArea())
				RestArea(aAreaNLA)
				
				If nDescInf > nDescCtr //Deságio
					nDesc := nDesc * (-1)
				EndIf
				
			OtherWise
				nDesc := nDescInf
				
				If nDescInf > nDescCtr //Deságio
					nDesc := nDesc * (-1)
				EndIf
		EndCase
		
		Do Case
			Case cOpcao == "NLD_DESCON"
				cRet := nDesc  
			Case cOpcao == "NLD_VLUDES"
				cRet := Round ((nDesc * oModelN82:GetValue("N82_VALUNI") / 100), TamSX3("NLD_VLUDES")[2]  )
			Case cOpcao == "NLD_VALDES"
				cRet := Round((nDesc * oModelN82:GetValue("N82_VALUNI")/100  * oModelNLD:GetValue("NLD_PESDES")), TamSX3("NLD_VALDES")[2] )
		EndCase
		
	EndIf
	
Return cRet

/*{Protheus.doc} fTrgNLDPes()
Gatilho para Quantidade de Fardos Fora
@type Function
@author Tamyris Ganzenmueller
@since 11/10/2018
@version 1.0.
@param param, param_type, param_descr
@return lRet
@see (links_or_references)*/
Static Function fTrgNLDPes(cOpcao)
	Local oModel    := FwModelActive()
	Local oModelN82 := oModel:GetModel("N82UNICO")
	Local oModelNLD := oModel:GetModel("NLDUNICO")
	Local nVlUnit   := oModelNLD:GetValue("NLD_VLUDES")
	Local nRet := ""
	
	aAreaNLB :=  NLB->(GetArea())
	
	If oModelN82:GetValue("N82_UTPESO") == '1'
		nRet :=  oModelNLD:GetValue("NLD_QTFRDO") * oModelNLD:GetValue("NLD_QNTREP") * oModelN82:GetValue("N82_PESMED")
	Else
		nRet :=  oModelNLD:GetValue("NLD_QTFRDO") * oModelNLD:GetValue("NLD_QNTREP") * oModelN82:GetValue("N82_PEFRCL")
	EndIF
	
	oModelNLD:setValue("NLD_VALDES", nVlUnit * nRet) 
	
	RestArea(aAreaNLB)
	
Return nRet

/*/{Protheus.doc} fCalcTot
Função responsavel por atualizar o campo total das taxas.
@type  Static Function
@author rafael.kleestadt
@since 12/10/2018
@version 1.0
@param param, param_type, param_descr
@return True, Logycal, True or False
@example
(examples)
@see (links_or_references)
/*/
Static Function fCalcTot()
	Local oModel  := FwModelActive()
	Local oView   := FWViewActive()
	Local oMdlN82 := oModel:GetModel("N82UNICO")
	Local oGrdNLE := oModel:GetModel("NLEUNICO")
	Local nX      := 0
	Local nValor  := 0
	Local aArea   := NLE->(GetArea())
	Local nTotQua := oMdlN82:GetValue("N82_TOTQUA")
	Local nValTot := oMdlN82:GetValue("N82_VALTOT")
	Local nVlToCl := oMdlN82:GetValue("N82_VLTOCL")
	Local cTipo	  := oMdlN82:GetValue("N82_UTPESO")
	Local nTotDes := 0
	Local nTotPes := 0
	Local nLine   := oGrdNLE:GetLine()

	For nX := 1 to oGrdNLE:Length()

		oGrdNLE:GoLine( nX )

		If .Not. oGrdNLE:IsDeleted()
			
			nValor += oGrdNLE:GetValue('NLE_VLRTOT')

		EndIf

	Next nX

	nTotPes := IiF(cTipo == '1', nValTot, nVlToCl)
	nTotDes := nValor + nTotQua + nTotPes
	oMdlN82:SetValue("N82_TOTDES", nTotDes)
	oMdlN82:SetValue("N82_TOTDE1", nTotDes)
	oMdlN82:SetValue("N82_SLDINV", oMdlN82:GetValue("N82_VLINVO") + nTotDes)

	oMdlN82:LoadValue('N82_TOTTAX', nValor)
	
	oGrdNLE:GoLine(nLine)

	RestArea(aArea)

	oView:Refresh()
	
Return .T.

/*/{Protheus.doc} fCalcQua
Função responsavel por atualizar o campo total da qualidade.
@type  Static Function
@author christopher.miranda
@since 12/10/2018
@version 1.0
@param param, param_type, param_descr
@return True, Logycal, True or False
@example
(examples)
@see (links_or_references)
/*/
Static Function fCalcQua()
	Local oModel  := FwModelActive()
	Local oView   := FWViewActive()
	Local oMdlN82 := oModel:GetModel("N82UNICO")
	Local oGrdNLD := oModel:GetModel("NLDUNICO")
	Local oGrdNLB := oModel:GetModel("NLBUNICO")
	Local nX      := 0
	Local nY      := 0
	Local nValor  := 0
	Local nTotTax := oMdlN82:GetValue("N82_TOTTAX")
	Local nValTot := oMdlN82:GetValue("N82_VALTOT")
	Local nVlToCl := oMdlN82:GetValue("N82_VLTOCL")
	Local cTipo	  := oMdlN82:GetValue("N82_UTPESO")
	Local nTotDes := 0
	Local nTotPes := 0

	aAreaNLB   := NLB->(GetArea())
	aAreaNLD   := NLD->(GetArea())
	
	nLineNLB := oGrdNLB:GetLine( )
	nLineNLD := oGrdNLD:GetLine( )
	
	For nX := 1 to oGrdNLB:Length()

		oGrdNLB:GoLine( nX )

		For nY := 1 to oGrdNLD:Length()

			oGrdNLD:GoLine( nY )

			If .Not. oGrdNLD:IsDeleted()
				
				nValor += oGrdNLD:GetValue('NLD_VALDES')

			EndIf 

		Next nY

	Next nX

	nTotPes := IiF(cTipo == '1', nValTot, nVlToCl)
	nTotDes := nTotTax + nValor + nTotPes
	oMdlN82:SetValue("N82_TOTDES", nTotDes)
	oMdlN82:SetValue("N82_TOTDE1", nTotDes)
	oMdlN82:SetValue("N82_SLDINV", oMdlN82:GetValue("N82_VLINVO") + nTotDes)

	oMdlN82:LoadValue('N82_TOTQUA', nValor)

	oGrdNLB:GoLine( nLineNLB )
	oGrdNLD:GoLine( nLineNLD )
	RestArea(aAreaNLB)
	RestArea(aAreaNLD)

	oView:Refresh()
Return .T.

/*/{Protheus.doc} fAtuSts()
Função que realiza a atualização dos status do pedido e gravar o histórico
@type  Static Function
@author user
@since date
@version version
@param cOpcao, caractere, define o status a ser atualizado: 'P'-N82_STAPES, 'Q'-N82_STAQUA, 'G'-N82_STATUS
@param cStatus, caractere, define o valor do status a ser atualizado: 1=Pendente;2=Aguardando Aprovação;3=Aprovado
@param cTitmsg, caractere, titulo da mensagem a ser gravada no histórico
@param cMsgMemo, caractere, mensagem a ser gravada no histórico
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function fAtuSts(cOpcao, cStatus, cTitmsg, cMsgMemo)

	Begin Transaction
		RecLock("N82", .F. )
			Do Case
				Case cOpcao = 'P' //Peso
					N82->N82_STAPES := cStatus
					cMsgMemo += CHR(13)+CHR(10) + STR0030 + ": " + cValToChar(N82->N82_QTLQIV) //Peso Invoice
					cMsgMemo += CHR(13)+CHR(10) + STR0031 + ": " + cValToChar(N82->N82_QTLQDE) //Peso no Destino
				Case cOpcao = 'Q' //Qualidade
					N82->N82_STAQUA := cStatus
					cMsgMemo += CHR(13)+CHR(10) + STR0041 + ": " + cValToChar(N82->N82_VLINVO) //"Valor Invoice"
					cMsgMemo += CHR(13)+CHR(10) + STR0042 + ": " + cValToChar(N82->N82_TOTQUA) //"Total Descontos Qualidade"
				Case cOpcao = 'G' //Geral
					N82->N82_STATUS := cStatus
					cMsgMemo += CHR(13)+CHR(10) + STR0041 + ": " + cValToChar(N82->N82_VLINVO) //"Valor Invoice"
					cMsgMemo += CHR(13)+CHR(10) + STR0053 + ": " + cValToChar(N82->N82_TOTDES) //"Total Descontos Consolidado"
			End Case

			If N82->N82_STAPES = "3" .And. N82->N82_STAQUA = "3" .And. N82->N82_STATUS = "1" .And. cOpcao <> 'G'
				N82->N82_STATUS := "2"
			EndIf

		N82->( msUnLock() )
	End Transaction

	AGRGRAVAHIS(,,,,{"N82",N82->N82_FILIAL+N82->N82_CODINE+N82->N82_PEDIDO+N82->N82_FILORI+N82->N82_ITEM,"T", cTitmsg + '  :  ' + cMsgMemo}) //T=Atualizar

Return .T.

/*/{Protheus.doc} OGAA910Est(cStatus)
Define a cor do farol da Legenda
@type  Static Function
@author rafael.kleestadt
@since 16/10/2018
@version 1.0
@param cStatus, caractere, Conteudo do campo N82_STATUS, N82_STAPES, N82_STAQUA posicionado
@return cStatus, caractere, nome do icone de legenda  ser exibido.
@example
(examples)
@see (links_or_references)
/*/
Static Function OGAA910Est(cStatus)

	Do Case
		Case cStatus == "1"
		cStatus := "BR_CINZA" //Pendente 
		Case cStatus == "2"
		cStatus := "BR_AMARELO" //Aberto
		Case cStatus == "3"
		cStatus := "BR_VERDE" //Finalizado
	EndCase
    
Return cStatus

/*/{Protheus.doc} OGAA910Leg()
Exibe a Legenda
@type  Static Function
@author rafael.kleestadt
@since 16/10/2018
@version 1.0
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function OGAA910Leg()

	Local oLegenda := FWLegend():New() // Objeto FwLegend.

	oLegenda:Add("","BR_CINZA" 	 , X3CboxDesc("N82_STAPES",'1')) // "Pendente"
	oLegenda:Add("","BR_AMARELO" , X3CboxDesc("N82_STAPES",'2')) // "Aguardando Aprovação"
	oLegenda:Add("","BR_VERDE"   , X3CboxDesc("N82_STAPES",'3')) // "Aprovado"

	oLegenda:Activate()
	oLegenda:View()
	oLegenda:DeActivate()
	
Return .T.

/** {Protheus.doc} OGAA910AQR
Descrição: 	Atualização do status da qualidade no browse 
@param: 	Nil
@author: 	Christopher.miranda
@since: 	17/10/2018
@Uso: 		OGAA910AQR 
*/
Function OGAA910AQR()
	Local oMsg     := .F.
	Local oRadio   := Nil
	Local nRadio   := 1
	Local cMsgMemo := TamSX3("NK9_MSGMEM")
	Local cTitmsg  := ""
	Local nOpcao   := 2

	IF Empty(N82->N82_TOTQUA) //Não tem qualidade informada
		Help( , , STR0021, , STR0047, 1, 0 ) //AJUDA ## Não foram identificados descontos referentes a qualidade.
		Return .T.
	EndIF
	
	IF N82->N82_STAQUA <> '2' //2-Aguardando Aprovação
		Help( , , STR0021, , STR0023, 1, 0 ) //AJUDA ## Status deve ser igual a 'Aguardando Aprovação'
		Return .T.
	EndIF

	//Verifica no cadastro de aprovadores do processo(OGAA760) se o usuário tem permissão de executar a ação de acordo com a faixa de tolerância de variação.
	If .Not. ValidTol('2')
		Return .T.
	EndIf

	cTitmsg  := STR0045 //"Aprovar Qualidade"

	oDlg	:= TDialog():New(350,406,638,795,cTitmsg,,,,,CLR_BLACK,CLR_WHITE,,,.t.) 
	oDlg:lEscClose := .f.

	@ 038,008 SAY STR0035 PIXEL //"Ação: "
	@ 038,035 Radio oRadio VAR nRadio;
	ITEMS STR0036,; //"Aprovar"
		  STR0037 ; //"Rejeitar"
	3D SIZE 100,20 OF oDlg PIXEL 
	@ 058,008 SAY " " PIXEL
	@ 058,008 SAY STR0029 PIXEL	
	@ 070,008 GET oMsg Var cMsgMemo OF oDlg Multiline Size 172,062 PIXEL 	

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpcao := 1, oDlg:End()},{|| nOpcao := 0,oDlg:End()}) CENTERED
	
	If nOpcao == 1

		If Vazio(cMsgMemo)
			cMsgMemo := IIF( nRadio == 1, STR0045, STR0046)//"Aprovar Qualidade"###"Rejeitar Qualidade"
		EndIf

		cTitmsg := IIF( nRadio == 1, STR0045, STR0046)//"Aprovar Qualidade"###"Rejeitar Qualidade"

		fAtuSts('Q', Iif(nRadio == 1, '3', '1'), cTitmsg, cMsgMemo)

	Else
		Return .F.
	EndIf
Return .T.

/*/{Protheus.doc} OGAA910AGR()
Rotina destinada a realizar a aprovação geral peso/qualidade/serviços
@type  Static Function
@author rafael.kleestadt
@since 17/10/2018
@version 1.0
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function OGAA910AGR()
	Local oMsg     := .F.
	Local oRadio   := Nil
	Local nRadio   := 1
	Local cMsgMemo := TamSX3("NK9_MSGMEM")
	Local cTitmsg  := ""
	Local nOpcao   := 2

	IF Empty(N82->N82_TOTDES) //Não tem descontos informados
		Help( , , STR0021, , STR0052, 1, 0 ) //AJUDA ## "Não foram identificados descontos referente a Peso, Qualidade ou serviços."
		Return .T.
	EndIF
	
	IF N82->N82_STATUS <> '2' //2-Aguardando Aprovação
		Help( , , STR0021, , STR0023, 1, 0 ) //AJUDA ## Status deve ser igual a 'Aguardando Aprovação'
		Return .T.
	EndIF

	//Verifica no cadastro de aprovadores do processo(OGAA760) se o usuário tem permissão de executar a ação de acordo com a faixa de tolerância de variação.
	If .Not. ValidTol('3')
		Return .T.
	EndIf

	cTitmsg  := STR0050 //"Aprovar Consolidação Peso e Qual. no Dest."

	oDlg	:= TDialog():New(350,406,638,795,cTitmsg,,,,,CLR_BLACK,CLR_WHITE,,,.t.) 
	oDlg:lEscClose := .f.

	@ 038,008 SAY STR0035 PIXEL //"Ação: "
	@ 038,035 Radio oRadio VAR nRadio;
	ITEMS STR0036,; //"Aprovar"
		  STR0037 ; //"Rejeitar"
	3D SIZE 100,20 OF oDlg PIXEL 
	@ 058,008 SAY " " PIXEL
	@ 058,008 SAY STR0029 PIXEL	
	@ 070,008 GET oMsg Var cMsgMemo OF oDlg Multiline Size 172,062 PIXEL 	

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpcao := 1, oDlg:End()},{|| nOpcao := 0,oDlg:End()}) CENTERED
	
	If nOpcao == 1

		If Vazio(cMsgMemo)
			cMsgMemo := IIF( nRadio == 1, STR0050, STR0051)//"Aprovar Consolidação Peso e Qual. no Dest."###"Rejeitar Qualidade"
		EndIf

		cTitmsg := IIF( nRadio == 1, STR0050, STR0051)//"Aprovar Consolidação Peso e Qual. no Dest."###"Rejeitar Qualidade"

		fAtuSts('G', Iif(nRadio == 1, '3', '1'), cTitmsg, cMsgMemo)

	Else
		Return .F.
	EndIf
Return .T.

/*/{Protheus.doc} fLoadFar(oField)
Função destinada a carregar as quantidades de fardos na grid de taxas NLE
@type  Static Function
@author rafael.kleestadt
@since 19/10/2018
@version 1.0
@param param, param_type, param_descr
@return true, logycal, true or false
@example
(examples)
@see (links_or_references)
/*/
Static Function fLoadFar(oField)
	Local oModel   := FwModelActive()
	Local oView    := FWViewActive()
	Local oGrdN82  := oModel:GetModel("N82UNICO")
	Local oGrdNLB  := oModel:GetModel("NLBUNICO")
	Local oGrdNLD  := oModel:GetModel("NLDUNICO")
	Local oGrdNLE  := oModel:GetModel("NLEUNICO")
	Local nX       := 0
	Local aArea    := GetArea()
	Local nLinNLD  := oGrdNLD:GetLine()
	Local nTotFrd  := 0
	Local cTipCalc := ""
	LOcal nTaxUnic := 0
	
	aAreaNLB   := NLB->(GetArea())
	aAreaNLD   := NLD->(GetArea())
	
	nLineNLB := oGrdNLB:GetLine( )
	nLineNLD := oGrdNLD:GetLine( )

	//Obtém o total de fardos fora informado para este tipo de desconto.
	For nX := 1 To oGrdNLD:Length()

		oGrdNLD:GoLine(nX)

		If !oGrdNLD:IsDeleted()
			nTotFrd += oGrdNLD:GetValue("NLD_QTFRDO")
		EndIf

	Next nX

	//carrega a quantidade de fardos conforme a regra do cálculo(NLC)
	For nX := 1 To oGrdNLE:Length()

		oGrdNLE:GoLine(nX)

		If !oGrdNLE:IsDeleted()

			If oGrdNLE:GetValue("NLE_CODTIP") = oGrdNLB:GetValue("NLB_CODTIP")

				If !Empty(oGrdNLE:GetValue('NLE_CODTIP')) .And. !Empty(oGrdNLE:GetValue('NLE_CODTAX'))
					cTipCalc := Posicione('NLC', 1, FwxFilial('NLC')+oGrdN82:GetValue('N82_CODTAB')+oGrdNLE:GetValue('NLE_CODTIP')+oGrdNLE:GetValue('NLE_CODTAX'), 'NLC_CALCUL') //1=Qtd Fardos Fora;2=Qtd Total Fardos;3=Taxa Única
					nTaxUnic := Posicione('NLC', 1, FwxFilial('NLC')+oGrdN82:GetValue('N82_CODTAB')+oGrdNLE:GetValue('NLE_CODTIP')+oGrdNLE:GetValue('NLE_CODTAX'), 'NLC_VALOR')
				EndIf

				If !Empty(cTipCalc)
					Do Case
						Case cTipCalc = '1' //Qtd Fardos Fora
							oGrdNLE:SetValue("NLE_QTDFAR", nTotFrd)
						Case cTipCalc = '2' //Qtd Total Fardos
							oGrdNLE:SetValue("NLE_QTDFAR", oGrdN82:GetValue("N82_QNTFAR"))
						Case cTipCalc = '3' //Taxa Única
							oGrdNLE:SetValue("NLE_QTDFAR", 0)
							oGrdNLE:SetValue("NLE_VLRTOT", nTaxUnic)
					End Case
				Else
					oGrdNLE:SetValue("NLE_QTDFAR", nTotFrd)
				EndIf

			EndIf

		EndIf

	Next nX

	oGrdNLE:GoLine(1)

	oGrdNLD:GoLine(nLinNLD)
	
	oGrdNLB:GoLine( nLineNLB )
	oGrdNLD:GoLine( nLineNLD )
	RestArea(aAreaNLB)
	RestArea(aAreaNLD)

	oView:Refresh()

	RestArea(aArea)

Return .T.
