#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPX600Mdl
Inclui os sub-modelos (Model) do SIGAGTP
@author Inovação
@Owner 	SIGAGTP
@since 31/05/2017
@version P12
/*/
//-------------------------------------------------------------------
Function GTPX600Mdl(oModel, oStrADZPro)

Local oStrGIN		:= FWFormStruct(1,'GIN')//Percurso
Local oStrGIQ		:= FWFormStruct(1,'GIQ') //Trechos 
Local oStrGIP		:= FWFormStruct(1,'GIP')//Pasta Veiculos
Local oStrGIO		:= FWFormStruct(1,'GIO')//Pasta Custos
Local aGIOTrig		:= oStrGIO:GetTriggers()

oStrADZPro:SetProperty("ADZ_QTDVEN"	, MODEL_FIELD_INIT	, FwBuildFeature(STRUCT_FEATURE_INIPAD,"1")) // Qtdade Prod

// GATILHO - Quando utilizado o GTP, não deverá considerar o valor de Tabela de preço
oStrADZPro:AddTrigger("ADZ_PRCVEN","ADZ_PRCVEN"	,{||.T.},{|oMdl,cField,xVal|GX600ZeraTab(oMdl,cField,xVal)})

oModel:AddGrid('GINDETAIL','ADYMASTER', oStrGIN ) //-- Percurso 

oModel:AddGrid('GIQDETAIL' , 'ADYMASTER', oStrGIQ) //Trecho
oModel:AddGrid('GIPDETAIL', 'ADYMASTER', oStrGIP)
oModel:AddGrid('GIODETAIL' , 'ADYMASTER', oStrGIO)

oModel:SetRelation('GINDETAIL',{{'GIN_FILIAL','xFilial("GIN")'},{"GIN_PROPOS","ADY_PROPOS"}},GIN->( IndexKey(1)))
oModel:SetRelation('GIQDETAIL'	,{{'GIQ_FILIAL','xFilial("GIQ")'},{"GIQ_PROPOS","ADY_PROPOS"}},"GIQ_SEQ" )
oModel:SetRelation('GIPDETAIL'	,{{'GIP_FILIAL','xFilial("GIP")'},{"GIP_PROPOS","ADY_PROPOS"}},GIP->( IndexKey(1)))
oModel:SetRelation('GIODETAIL'	,{{'GIO_FILIAL','xFilial("GIO")'},{"GIO_PROPOS","ADY_PROPOS"}},GIO->( IndexKey(1)))
		
// -------------------------------------------------+
// Nao permite duplicidade no Grid Produto, Acessorio e Custo  |
// -------------------------------------------------+	
oModel:GetModel("ADZPRODUTO"):SetUniqueLine( { "ADZ_PRODUT"  } )
oModel:GetModel("ADZACESSOR"):SetUniqueLine( { "ADZ_PRODUT" } )
oModel:GetModel("GIQDETAIL"):SetUniqueLine(  { "GIQ_TRECHO"  } )
oModel:GetModel("GIODETAIL"):SetUniqueLine(  { "GIO_CUSTO"  } )
oModel:GetModel("GIPDETAIL"):SetUniqueLine( { "GIP_CODBEM"  } )

oModel:GetModel('GINDETAIL'):SetDescription("Percurso")   //"Percurso"
oModel:GetModel('GIQDETAIL'):SetDescription("Percurso")   //"Percurso"
oModel:GetModel('GIPDETAIL'):SetDescription("Veículos")  //"Veículos"
oModel:GetModel('GIODETAIL'):SetDescription("Custos")   //"Custos""

//-- Determina a qtdade de linhas do grid produto
oModel:GetModel('ADZPRODUTO'):SetMaxLine(1)


oModel:AddCalc( 'CALC', 'ADYMASTER', 'GIODETAIL', 'GIO_VALTOT', 'GIO__CUSTOS', 'SUM', {||.T.}, /*bInitValue*/, "Total Geral de Custo"/*cTitle*/, /*bFormula*/)
oModel:GetModel('CALC'):AddEvents('CALC',"ADZ__TOTPRO","GIO__CUSTOS",{|| .T.})
oModel:GetModel('CALC'):AddEvents('CALC',"ADZ__TOTPRO","GIO__CUSTOS",{|| A600CroFinance()})	//"Total" ''


Return(oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} TPSubViewGTP
Inclui os sub-modelos (View) do SIGAGTP
@author Inovação
@Owner 	SIGAGTP
@since 31/05/2017
@version P12
/*/
//-------------------------------------------------------------------
Function GTPX600View(oView,oStrADY,oStrADZPro)

Local oStrGIN		:= FWFormStruct(2, 'GIN') 
Local oStrGIQ		:= FWFormStruct(2, 'GIQ') 
Local oStrGIP		:= FWFormStruct(2, 'GIP') 
Local oStrGIO		:= FWFormStruct(2, 'GIO') 


	//-- Esconde compa desconto do cabeçalho
	oStrADY:RemoveField( 'ADY_DESCON' )
	
	//-- Esconde campos da grid produto.
	oStrADZPro:RemoveField("ADZ_QTDVEN")	
	oStrADZPro:RemoveField("ADZ_TPPROD")
	oStrADZPro:RemoveField("ADZ_PRDALO")
	oStrADZPro:RemoveField("ADZ_LOCAL")	
	oStrADZPro:RemoveField("ADZ_FOLDER")
	oStrADZPro:RemoveField("ADZ_ITPAI")		
	oStrADZPro:RemoveField("ADZ_PMS")	
	oStrADZPro:RemoveField("ADZ_PMSVER")
	oStrADZPro:RemoveField("ADZ_CODVIS")	
	oStrADZPro:RemoveField("ADZ_ITEMVI")
	oStrADZPro:RemoveField("ADZ_CODAGR")
	oStrADZPro:RemoveField("ADZ_CODNIV")				

	//-- Bloqueia edição do campo
	oStrADZPro:SetProperty("ADZ_VALDES",MVC_VIEW_CANCHANGE,.F.)
	// oStrADZPro:SetProperty("ADZ_QTDVEN",MVC_VIEW_CANCHANGE,.F.)
	
	// Adiciona o componente para estrutura
	oView:AddGrid('GINDETAIL'	, oStrGIN	, 'GINDETAIL' )
	oView:AddGrid('GIQDETAIL'	, oStrGIQ	, 'GIQDETAIL' )
	oView:AddGrid('GIPDETAIL' 	, oStrGIP	, 'GIPDETAIL' )
	oView:AddGrid('GIODETAIL'	, oStrGIO	, 'GIODETAIL' )	

	oView:AddSheet( 'ABAS', 'ABA04', "Percurso" ) //  "Percurso"	
	oView:CreateHorizontalBox('ID_ABA04' , 100,,, 'ABAS', 'ABA04' )
	oView:CreateVerticalBox('ID_ABA04ESQ', 30,'ID_ABA04',/*lUsePixel*/,'ABAS', 'ABA04')
	oView:CreateVerticalBox('ID_ABA04DIR', 70,'ID_ABA04',/*lUsePixel*/,'ABAS', 'ABA04')		
	
	oView:AddSheet( 'ABAS', 'ABA05', "Veículos" ) // "Veículos" 	
	oView:CreateHorizontalBox( 'ID_ABA05' , 100,,, 'ABAS', 'ABA05' )
	
	oView:AddSheet( 'ABAS', 'ABA06', "Custos") // "Custos"	
	oView:CreateHorizontalBox( 'ID_ABA06' , 100,,, 'ABAS', 'ABA06' )

	oView:SetOwnerView( 'GINDETAIL'	, 'ID_ABA04DIR')
	oView:SetOwnerView( 'GIQDETAIL'	, 'ID_ABA04ESQ')
	oView:SetOwnerView( 'GIPDETAIL'	, 'ID_ABA05')
	oView:SetOwnerView( 'GIODETAIL'	, 'ID_ABA06')

	oView:EnableTitleView('GINDETAIL'		, "Trechos"		) 
	oView:EnableTitleView('GIQDETAIL'		, "Percurso"	) 
	
	oView:GetModel('GINDETAIL'):SetNoInsertLine(.T.)
	oView:GetModel('GINDETAIL'):SetNoDeleteLine(.T.)
	
	oView:GetModel('GIQDETAIL'):SetNoInsertLine(.T.)
	oView:GetModel('GIQDETAIL'):SetNoDeleteLine(.T.)
	
	oView:GetModel('GIPDETAIL'):SetNoInsertLine(.T.)
	oView:GetModel('GIPDETAIL'):SetNoDeleteLine(.T.)
	
	oView:GetModel('GIODETAIL'):SetNoInsertLine(.T.)
	oView:GetModel('GIODETAIL'):SetNoDeleteLine(.T.)
	
Return(oView)


/*/{Protheus.doc} GX600ZeraTab
Zera o valor do preço de tabela quando utilizado o módulo GTP
@type function
@author jacomo.fernandes
@since 03/08/2018
@version 1.0
@param oMdl, objeto, (Descrição do parâmetro)
@param cField, character, (Descrição do parâmetro)
@param xVal, variável, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GX600ZeraTab(oMdl,cField,xVal)
If oMdl:GetValue("ADZ_PRCVEN") > 0 .And. oMdl:GetValue("ADZ_PRCTAB") > 0
	oMdl:LoadValue( "ADZ_PRCTAB"	, 0 )
EndIf

Return xVal

