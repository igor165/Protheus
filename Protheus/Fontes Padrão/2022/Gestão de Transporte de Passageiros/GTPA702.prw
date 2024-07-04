#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA702.CH'

Static oGtpLog	:= GTPLog():New("Reajuste de Preço") 
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA702
Rotina para atualização do valor de tarifa, taxa e pedagio 
@type function
@author jacomo.fernandes
@since 03/11/2017
@version 1.0
@example
(examples)
@see (links_or_references)
/*///------------------------------------------------------------------------------------------
FUNCTION GTPA702()

	Local aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T., "Confirmar" },{.T., "Fechar"},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}	//"Confirmar"###"Fechar"

		If Pergunte('GTPA702',.T.)
		
			FWExecView( "Reajuste de Preço - View" , "GTPA702", 4,  /*oDlgKco*/, {|| .T. } , /*bOk*/ , /*nPercReducao*/, aButtons, /*bCancel*/, /*cOperatId*/ , /*cToolBar*/ , /*oModel*/ )
		
		Endif
		
Return
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
(long_description)
@type function
@author jacomo.fernandes
@since 03/11/2017
@version 1.0
@return oModel, retorna o objeto do Modelo de dados 
@example
(examples)
@see (links_or_references)
/*///------------------------------------------------------------------------------------------
Static Function ModelDef()

	Local oModel		:= MPFormModel():New('GTPA702',/*bPreValid*/, {|oModel|Ga702PosVld(oModel)}/*bPost*/, /*bCommit*/)
	Local oStruCab	:= FWFormModelStruct():New()
	Local oStruGI0	:= FWFormStruct( 1,"GI0")	//Tabela de Poder Concedente
	Local oStruGQD	:= FWFormStruct( 1,"GQD")	//Tipo de Linhas x OrgÆo
	Local oStruG5F	:= FWFormStruct( 1,"G5F")	// Categorias x Orgão
	Local oStruG5H	:= FWFormStruct( 1,"G5H")	//Calculo Reajuste Tarifa
	Local oStruGI2	:= FWFormStruct( 1,"GI2")	// Linhas
	Local oStruGI4	:= FWFormStruct( 1,"GI4")	// Trechos e Tarifas
	Local oStruG5G	:= FWFormStruct( 1,"G5G")   // Histórico de Preço

	Local aFilterGI4	:= {}

		GaLoadStruct("M",oStruCab,oStruGI0,oStruGQD,oStruG5F,oStruGI2,oStruGI4)
	
		oModel:SetDescription("Reajustes de Preço")
		oModel:AddFields('MASTER'	, /*cOwner*/	, oStruCab, /*bPreValidacao*/, /*bPosValidacao*/, {|oGrid| GA702Load(oGrid)}/*bLoad*/)
		oModel:AddGrid( 'GI0DETAIL'	, 'MASTER'		, oStruGI0,,,,,{|oGrid| GA702Load(oGrid)})
		oModel:AddGrid( 'GQDDETAIL'	, 'GI0DETAIL'	, oStruGQD)
		oModel:AddGrid( 'G5FDETAIL'	, 'GQDDETAIL'	, oStruG5F)
		oModel:AddGrid( 'G5HDETTAR' , 'G5FDETAIL'   , oStruG5H)
		oModel:AddGrid( 'G5HDETPED' , 'G5FDETAIL'   , oStruG5H)
		oModel:AddGrid( 'G5HDETTAX' , 'G5FDETAIL'   , oStruG5H)
		oModel:AddGrid( 'GI2DETAIL'	, 'G5FDETAIL'	, oStruGI2)
		oModel:AddGrid( 'GI4DETAIL'	, 'GI2DETAIL'	, oStruGI4)
		oModel:AddGrid( 'G5GDETAIL'	, 'GI4DETAIL'	, oStruG5G)
	
		oModel:SetRelation('GI0DETAIL',{ { 'GI0_FILIAL','xFilial("GI0")'},{'GI0_COD'		,'XXX_CODIGO' } },GI0->(IndexKey(1)))
		oModel:SetRelation('GQDDETAIL',{ { 'GQD_FILIAL','xFilial("GQD")'},{'GQD_CODGI0'	,'GI0_COD'	} },GQD->(IndexKey(2)))
		oModel:SetRelation('G5FDETAIL',{ { 'G5F_FILIAL','xFilial("G5F")'},{'G5F_CODGI0'	,'GI0_COD'},{'G5F_CODGQC','GQD_CODGQC' } },G5F->(IndexKey(1)))
	
		oModel:SetRelation('G5HDETTAR',{ { 'G5H_FILIAL','xFilial("G5H")'},{'G5H_CODORG'	,'GI0_COD'},{'G5H_TPLIN','GQD_CODGQC' },{'G5H_CODG5F','G5F_CODGYR'},{'G5H_TPREAJ',"'1'"} },G5H->(IndexKey(1)))
		oModel:SetRelation('G5HDETPED',{ { 'G5H_FILIAL','xFilial("G5H")'},{'G5H_CODORG'	,'GI0_COD'},{'G5H_TPLIN','GQD_CODGQC' },{'G5H_CODG5F','G5F_CODGYR'},{'G5H_TPREAJ',"'2'"} },G5H->(IndexKey(1)))
		oModel:SetRelation('G5HDETTAX',{ { 'G5H_FILIAL','xFilial("G5H")'},{'G5H_CODORG'	,'GI0_COD'},{'G5H_TPLIN','GQD_CODGQC' },{'G5H_CODG5F','G5F_CODGYR'},{'G5H_TPREAJ',"'3'"} },G5H->(IndexKey(1)))
	
		oModel:SetRelation('GI2DETAIL',{ { 'GI2_FILIAL','xFilial("GI2")'},{'GI2_ORGAO'	,'GI0_COD'},{'GI2_TIPLIN','GQD_CODGQC' },{'GI2_CATEG ','G5F_CODGYR'},{'GI2_HIST',"'2'"} },GI2->(IndexKey(1)))
		oModel:SetRelation('GI4DETAIL',{ { 'GI4_FILIAL','xFilial("GI4")'},{'GI4_LINHA'	,'GI2_COD'},{'GI4_HIST',"'2'" }},"GI4_FILIAL+GI4_LINHA+GI4_ITEM")
		oModel:SetRelation('G5GDETAIL',{ { 'G5G_FILIAL','xFilial("G5G")'},{'G5G_CODLIN'	,'GI2_COD'},{'G5G_VIA','GI2_VIA'},{'G5G_LOCORI','GI4_LOCORI'},{'G5G_LOCDES','GI4_LOCDES'},{'G5G_SENTID','GI4_SENTID'}, { 'G5G_REVISA'	, 'GI4_REVISA' } } , G5G->(IndexKey(1)))
	
		oModel:GetModel( 'GQDDETAIL' ):SetLoadFilter(,GetQryFilLoad("GQD"))
		oModel:GetModel( 'G5FDETAIL' ):SetLoadFilter(,GetQryFilLoad("G5F"))
		oModel:GetModel( 'GI2DETAIL' ):SetLoadFilter(,GetQryFilLoad("GI2"))
	
		If !Empty(MV_PAR09) 
			aAdd(aFilterGI4,{ 'GI4_LOCORI', "'"+MV_PAR09+"'" })
		Endif
	
		If !Empty(MV_PAR10) 
			aAdd(aFilterGI4,{ 'GI4_LOCDES', "'"+MV_PAR10+"'" })
		Endif
	
		If Len(aFilterGI4) > 0
			oModel:GetModel( 'GI4DETAIL' ):SetLoadFilter(aFilterGI4 )
		Endif
	
		oModel:GetModel('GI0DETAIL'):SetOnlyQuery( .T. )
		oModel:GetModel('GQDDETAIL'):SetOnlyQuery( .T. )
		oModel:GetModel('G5FDETAIL'):SetOnlyQuery( .T. )
		oModel:GetModel('GI2DETAIL'):SetOnlyQuery( .T. )
	
		oModel:GetModel('GI0DETAIL'):SetNoDeleteLine(.T.)
		oModel:GetModel('GQDDETAIL'):SetNoDeleteLine(.T.)
		oModel:GetModel('G5FDETAIL'):SetNoDeleteLine(.T.)
		oModel:GetModel('GI2DETAIL'):SetNoDeleteLine(.T.)
		oModel:GetModel('GI4DETAIL'):SetNoDeleteLine(.T.)
	
		oModel:GetModel('GI0DETAIL'):SetNoInsertLine(.T.)
		oModel:GetModel('GQDDETAIL'):SetNoInsertLine(.T.)
		oModel:GetModel('G5FDETAIL'):SetNoInsertLine(.T.)
		oModel:GetModel('GI2DETAIL'):SetNoInsertLine(.T.)
		oModel:GetModel('GI4DETAIL'):SetNoInsertLine(.T.)
	
		oModel:GetModel('GQDDETAIL'):SetOptional( .T. )
		oModel:GetModel('G5FDETAIL'):SetOptional( .T. )
		oModel:GetModel('GI2DETAIL'):SetOptional( .T. )
		oModel:GetModel('GI4DETAIL'):SetOptional( .T. )
		oModel:GetModel('G5GDETAIL'):SetOptional( .T. )
		oModel:GetModel('G5HDETTAR'):SetOptional( .T. )
		oModel:GetModel('G5HDETPED'):SetOptional( .T. )
		oModel:GetModel('G5HDETTAX'):SetOptional( .T. )
	
		//Definição da Chave unica
		oModel:SetPrimaryKey({})
	
		oModel:SetDescription("Reajustes de Preço")
		oModel:GetModel('MASTER'):SetDescription("Reajuste")
		oModel:GetModel('GI0DETAIL'):SetDescription("Órgão")       
		oModel:GetModel('GQDDETAIL'):SetDescription("Tipo de Linha")
		oModel:GetModel('G5FDETAIL'):SetDescription("Categoria")   
		oModel:GetModel('GI2DETAIL'):SetDescription("Linha")       
		oModel:GetModel('GI4DETAIL'):SetDescription("Trechos")     
	
		GTPDestroy(aFilterGI4)
	
		oModel:SetActivate( {|oModel| GA702Reajuste(oModel) } )

Return oModel

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
(long_description)
@type function
@author jacomo.fernandes
@since 03/11/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///------------------------------------------------------------------------------------------
Static Function ViewDef()

	Local oView		:= FWFormView():New()
	Local oModel		:= FWLoadModel('GTPA702')
	Local oStruGI0	:= FWFormStruct( 2,"GI0")	//Tabela de Poder Concedente
	Local oStruGQD	:= FWFormStruct( 2,"GQD")	//Tipo de Linhas x OrgÆo
	Local oStruG5F	:= FWFormStruct( 2,"G5F")	// Categorias x Orgão
	Local oStruGI2	:= FWFormStruct( 2,"GI2",{|cCampo| AllTrim(cCampo)+"|" $ "GI2_COD|GI2_LOCINI|GI2_NLOCIN|GI2_LOCFIM|GI2_NLOCFI|GI2_PREFIX|"})	// Linhas
	Local oStruGI4	:= FWFormStruct( 2,"GI4")	// Trechos
	
		GaLoadStruct("V",/*oStruCab*/,oStruGI0,oStruGQD,oStruG5F,oStruGI2,oStruGI4)
	
		oView:SetModel(oModel)
	
		oView:AddGrid('VIEW_GI0', oStruGI0, 'GI0DETAIL')
		oView:AddGrid('VIEW_GQD', oStruGQD, 'GQDDETAIL')
		oView:AddGrid('VIEW_G5F', oStruG5F, 'G5FDETAIL')
		oView:AddGrid('VIEW_GI2', oStruGI2, 'GI2DETAIL')
		oView:AddGrid('VIEW_GI4', oStruGI4, 'GI4DETAIL')
	
		oView:CreateHorizontalBox('TOP',40)
	
		oView:CreateVerticalBox('TOP_GI0',25,'TOP')
		oView:CreateVerticalBox('TOP_GQD',25,'TOP')
		oView:CreateVerticalBox('TOP_G5F',25,'TOP')
		oView:CreateVerticalBox('TOP_GI2',25,'TOP')
	
		oView:CreateHorizontalBox('BOTTOM',60)
	
		oView:SetOwnerView('VIEW_GI0'   ,'TOP_GI0')
		oView:SetOwnerView('VIEW_GQD'   ,'TOP_GQD')
		oView:SetOwnerView('VIEW_G5F'   ,'TOP_G5F')
		oView:SetOwnerView('VIEW_GI2'   ,'TOP_GI2')
		oView:SetOwnerView('VIEW_GI4'   ,'BOTTOM')
	
		oView:SetOnlyView("VIEW_GI0")
		oView:SetOnlyView("VIEW_GQD")
		oView:SetOnlyView("VIEW_GI2")
	
		oView:SetViewProperty("VIEW_GI4", "GRIDSEEK", {.T.})
		oView:SetViewProperty("VIEW_GI4", "GRIDFILTER", {.T.}) 
	
		oView:EnableTitleView('VIEW_GI0',"Órgão")
		oView:EnableTitleView('VIEW_GQD',"Tipo de Linha")
		oView:EnableTitleView('VIEW_G5F',"Categoria")
		oView:EnableTitleView('VIEW_GI2',"Linha")
		oView:EnableTitleView('VIEW_GI4',"Trechos")

Return oView
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GaLoadStruct
(long_description)
@type function
@author jacomo.fernandes
@since 10/11/2017
@version 1.0
@param cTipo, character, (Descrição do parâmetro)
@param oStruCab, objeto, (Descrição do parâmetro)
@param oStruGI0, objeto, (Descrição do parâmetro)
@param oStruGQD, objeto, (Descrição do parâmetro)
@param oStruG5F, objeto, (Descrição do parâmetro)
@param oStruGI2, objeto, (Descrição do parâmetro)
@param oStruGI4, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*///------------------------------------------------------------------------------------------
Static Function GaLoadStruct( cTipo, oStruCab, oStruGI0, oStruGQD, oStruG5F, oStruGI2, oStruGI4 )

	If cTipo == "M"
	
		//Estrutura do Cabeçalho

		oStruCab:AddTable("   ",{" "}," ")
		oStruCab:AddField("FAKECOD","FAKECOD","XXX_CODIGO","C",TAMSX3('GI0_COD')[1],0,Nil,Nil,Nil,.F.,Nil,.F.,.F.,.T.)			

		oStruGI0:SetProperty("*",MODEL_FIELD_OBRIGAT,.F.)
		oStruGI0:SetProperty("*",MODEL_FIELD_VALID,{|| .T.})

		oStruGQD:SetProperty("*",MODEL_FIELD_OBRIGAT,.F.)
		oStruGQD:SetProperty("*",MODEL_FIELD_VALID,{|| .T.})

		oStruG5F:SetProperty("*",MODEL_FIELD_OBRIGAT,.F.)
		oStruG5F:SetProperty("*",MODEL_FIELD_VALID,{|| .T.})

		oStruG5F:AddField("REAJTAR_OK","REAJTAR_OK","G5F_OKTAR","L",1,0,Nil,Nil,Nil,.F.,{||.T.},.F.,.F.,.T.)
		oStruG5F:AddField("REAJPED_OK","REAJPED_OK","G5F_OKPED","L",1,0,Nil,Nil,Nil,.F.,{||.T.},.F.,.F.,.T.)
		oStruG5F:AddField("REAJTAX_OK","REAJTAX_OK","G5F_OKTAX","L",1,0,Nil,Nil,Nil,.F.,{||.T.},.F.,.F.,.T.)

		oStruGI2:SetProperty("*",MODEL_FIELD_OBRIGAT,.F.)
		oStruGI2:SetProperty("*",MODEL_FIELD_VALID,{|| .T.})


		oStruGI4:AddField("Nova Tarifa"	,"Nova Tarifa"	,"GI4_TARATU","N",TAMSX3('GI4_TAR')[1],TAMSX3('GI4_TAR')[2],Nil,Nil,Nil,.F.,{||GI4->GI4_TAR},.F.,.F.,.T.)
		oStruGI4:AddField("Nova Taxa"	,"Nova Taxa"	,"GI4_TAXATU","N",TAMSX3('GI4_TAX')[1],TAMSX3('GI4_TAX')[2],Nil,Nil,Nil,.F.,{||GI4->GI4_TAX},.F.,.F.,.T.)
		oStruGI4:AddField("Novo Pedágio","Novo PEdágio"	,"GI4_PEDATU","N",TAMSX3('GI4_PED')[1],TAMSX3('GI4_PED')[2],Nil,Nil,Nil,.F.,{||GI4->GI4_PED},.F.,.F.,.T.)
		
		//Caso existam duas configuraçoes e a primeira não carregue qualquer trecho, permite a visualizaçao da segunda configuração	
		oStruGI4:SetProperty("GI4_SENTID",MODEL_FIELD_OBRIGAT,.F.)
		
	Else
	
		oStruGI4:AddField("GI4_TARATU","13",GTPX3TIT("GI4_TAR"),GTPX3TIT("GI4_TAR"),{},"Get",PesqPict('GI4','GI4_TAR'),NIL,"",.F.,NIL,"",NIL,NIL,NIL,.T.,NIL,.F.)
		oStruGI4:AddField("GI4_TAXATU","16",GTPX3TIT("GI4_TAX"),GTPX3TIT("GI4_TAX"),{},"Get",PesqPict('GI4','GI4_TAX'),NIL,"",.F.,NIL,"",NIL,NIL,NIL,.T.,NIL,.F.)
		oStruGI4:AddField("GI4_PEDATU","19",GTPX3TIT("GI4_PED"),GTPX3TIT("GI4_PED"),{},"Get",PesqPict('GI4','GI4_PED'),NIL,"",.F.,NIL,"",NIL,NIL,NIL,.T.,NIL,.F.)

		oStruGI4:SetProperty("GI4_TAR"		, MVC_VIEW_TITULO,	"Nova tarifa")
		oStruGI4:SetProperty("GI4_TAX"		, MVC_VIEW_TITULO,	"Nova Taxa")
		oStruGI4:SetProperty("GI4_PED"		, MVC_VIEW_TITULO,	"Novo Pedágio")
		
		oStruGI4:SetProperty('GI4_ITEM'		, MVC_VIEW_ORDEM,	'01')
		oStruGI4:SetProperty('GI4_SENTID'	, MVC_VIEW_ORDEM,	'02')
		oStruGI4:SetProperty('GI4_LOCORI'	, MVC_VIEW_ORDEM,	'03')
		oStruGI4:SetProperty('GI4_NLOCOR'	, MVC_VIEW_ORDEM,	'04')
		oStruGI4:SetProperty('GI4_LOCDES'	, MVC_VIEW_ORDEM,	'05')
		oStruGI4:SetProperty('GI4_NLOCDE'	, MVC_VIEW_ORDEM,	'06')
		oStruGI4:SetProperty('GI4_KM'		, MVC_VIEW_ORDEM,	'07')
		oStruGI4:SetProperty('GI4_KMASFA'	, MVC_VIEW_ORDEM,	'08')
		oStruGI4:SetProperty('GI4_KMTERR'	, MVC_VIEW_ORDEM,	'09')
		oStruGI4:SetProperty('GI4_KMPED'	, MVC_VIEW_ORDEM,	'10')
		oStruGI4:SetProperty('GI4_TEMPO'	, MVC_VIEW_ORDEM,	'11')

		oStruGI4:SetProperty('GI4_VIGTAR'	, MVC_VIEW_ORDEM,	'12')
		oStruGI4:SetProperty('GI4_TAR'		, MVC_VIEW_ORDEM,	'14')

		oStruGI4:SetProperty('GI4_VIGTAX'	, MVC_VIEW_ORDEM,	'15')
		oStruGI4:SetProperty('GI4_TAX'		, MVC_VIEW_ORDEM,	'17')

		oStruGI4:SetProperty('GI4_VIGPED'	, MVC_VIEW_ORDEM,	'18')
		oStruGI4:SetProperty('GI4_PED'		, MVC_VIEW_ORDEM,	'20')

		oStruGI4:SetProperty("*",MVC_VIEW_CANCHANGE,.F.)
		oStruGI4:SetProperty("GI4_TAR",MVC_VIEW_CANCHANGE,.T.)
		oStruGI4:SetProperty("GI4_TAX",MVC_VIEW_CANCHANGE,.T.)
		oStruGI4:SetProperty("GI4_PED",MVC_VIEW_CANCHANGE,.T.)
				
		oStruG5F:RemoveField('G5F_VLRMIN')
		oStruG5F:SetProperty("*",MVC_VIEW_CANCHANGE,.F.)
		
		oStruGI0:RemoveField('GI0_MSBLQL')

		oStruGQD:RemoveField('GQD_TPREAJ')

		oStruGI4:RemoveField('GI4_VIGENC')
		oStruGI4:RemoveField('GI4_DTATU')
		oStruGI4:RemoveField('GI4_VIGSGF')
		oStruGI4:RemoveField('GI4_HIST')
		oStruGI4:RemoveField('GI4_DTALT')
		oStruGI4:RemoveField('GI4_MSBLQL')
		oStruGI4:RemoveField('GI4_REVISA')
		oStruGI4:RemoveField('GI4_TARANU')
		oStruGI4:RemoveField('GI4_CSC')
		oStruGI4:RemoveField('GI4_CCS')
		oStruGI4:RemoveField('GI4_STATUS')
		oStruGI4:RemoveField('GI4_SGFACU')


		If MV_PAR11 == 1 //Tarifa
			oStruGI4:RemoveField('GI4_VIGTAX')
			oStruGI4:RemoveField('GI4_TAX')
			oStruGI4:RemoveField('GI4_TAXATU')
			oStruGI4:RemoveField('GI4_VIGPED')
			oStruGI4:RemoveField('GI4_PED')
			oStruGI4:RemoveField('GI4_PEDATU')
		Endif
		If MV_PAR11 == 2 //Pedagio
			oStruGI4:RemoveField('GI4_VIGTAR')
			oStruGI4:RemoveField('GI4_TAR')
			oStruGI4:RemoveField('GI4_TARATU')
			oStruGI4:RemoveField('GI4_VIGTAX')
			oStruGI4:RemoveField('GI4_TAX')
			oStruGI4:RemoveField('GI4_TAXATU')
		Endif
		If MV_PAR11 == 3 //Taxa
			oStruGI4:RemoveField('GI4_VIGTAR')
			oStruGI4:RemoveField('GI4_TAR')
			oStruGI4:RemoveField('GI4_TARATU')
			oStruGI4:RemoveField('GI4_VIGPED')
			oStruGI4:RemoveField('GI4_PED')
			oStruGI4:RemoveField('GI4_PEDATU')
		Endif	

	Endif
	
Return
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA702Load
@author  
@since 
@version 1.0
@return ${return}, ${return_description}
@param oGrid, object, descricao
@type function
/*///------------------------------------------------------------------------------------------
Static Function GA702Load(oGrid)

	Local aRet		:= {}
	Local aFldConv:= {}
	Local cGridId	:= oGrid:GetId()
	Local cField	:= ""
	Local cFilRec	:= ""
	Local cNewAli	:= ''
	Local aIndex	:= {}
	Local oTable	:= Nil
	Local cQry		:= ""

	Local aFields := oGrid:GetStruct():GetFields()
	Local aAux		:= {}
	Local nI		:= 0

		If cGridId <>  'MASTER'
		
			Pergunte('GTPA702',.F.)
			
			cField		:= GTPFld2Str(oGrid:GetStruct(),.t.,aFldConv)
	
			aIndex	:= {{"INDEX1",{"GI0_FILIAL","GI0_COD"}}}
			cFilRec:= ", GI0.R_E_C_N_O_ RECNO "
	
			cQry := "	Select Distinct" + chr(13)
			cQry += "	" +	Alltrim(cField) + cFilRec + chr(13)
			cQry += " 	From "+RetSqlName("GI0")+" GI0 " + chr(13)
			cQry += "	Inner Join "+RetSqlName('GQD')+" GQD ON " + chr(13)
			cQry += "		GQD.GQD_FILIAL = '" + xFilial("GQD") + "' AND " + chr(13)
			cQry += "		GQD.GQD_CODGI0 = GI0.GI0_COD AND " + chr(13)
			cQry += "		GQD.GQD_CODGQC BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' AND " + chr(13)
			cQry += "		GQD.D_E_L_E_T_ = ' ' " + chr(13)
			cQry += "	Inner Join "+RetSqlName('G5F')+" G5F ON " + chr(13)
			cQry += "		G5F.G5F_FILIAL = '" + xFilial("G5F") + "' AND " + chr(13)
			cQry += "		G5F.G5F_CODGI0 = GI0.GI0_COD AND " + chr(13)
			cQry += "		G5F.G5F_CODGQC = GQD.GQD_CODGQC AND " + chr(13)
			cQry += "		G5F.G5F_CODGYR BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' AND " + chr(13)
			cQry += "		G5F.D_E_L_E_T_ = ' ' " + chr(13)
			cQry += "	Inner Join "+RetSqlName('GI2')+" GI2 ON " + chr(13)
			cQry += "		GI2.GI2_FILIAL = '" + xFilial("GI2") + "' AND " + chr(13)
			cQry += "		GI2.GI2_ORGAO = GI0.GI0_COD AND " + chr(13)
			cQry += "		GI2.GI2_TIPLIN = GQD.GQD_CODGQC AND " + chr(13)
			cQry += "		GI2.GI2_CATEG = G5F.G5F_CODGYR AND " + chr(13)
			cQry += "		GI2.GI2_HIST = '2' AND " + chr(13)
			cQry += "		GI2.GI2_COD BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' AND " + chr(13)
			cQry += "		GI2.D_E_L_E_T_ = ' '  " + chr(13)
			
			If !Empty(MV_PAR09) .or. !Empty(MV_PAR10) 
				cQry += "	Inner Join "+RetSqlName('GI4')+" GI4 ON " + chr(13)
				cQry += "		GI4.GI4_FILIAL = '"+xFilial("GI4")+"' AND " + chr(13)
				cQry += "		GI4.GI4_LINHA = GI2.GI2_COD AND " + chr(13)
				cQry += "		GI4.GI4_HIST = '2' AND " + chr(13)
				
				If !Empty(MV_PAR09)
				
					cQry += "		GI4.GI4_LOCORI = '"+MV_PAR09+"' AND " + chr(13)
				
				Endif
				
				If !Empty(MV_PAR10)
				
					cQry += "		GI4.GI4_LOCDES = '"+MV_PAR10+"' AND " + chr(13)
				
				Endif
				
				cQry += "		GI4.D_E_L_E_T_  = ' '  " + chr(13)
		
			Endif
			
			cQry += "Where " + chr(13)
			cQry += "	GI0.GI0_FILIAL = '" + xFilial("GI0") + "' AND " + chr(13)
			cQry += "	GI0.GI0_COD BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND " + chr(13)
			cQry += "	GI0_MSBLQL <> '1' AND "+ chr(13)
			cQry += "	GI0.D_E_L_E_T_  = ' ' " + chr(13)
	
			cNewAli	:= GetNextAlias()
			GTPTemporaryTable(cQry,cNewAli,aIndex,aFldConv,@oTable)
			aRet:= FWLoadByAlias(oGrid, oTable:GetAlias())//, /*oTable:GetRealName()*/,"RECNO")
	
			If ( Len(aRet) == 0 )

				For nI := 1 to Len(aFields)
					aAdd(aAux,GtpCastType(,aFields[nI,4]))		
				Next nI

				aAdd(aRet,{0,aClone(aAux)})

			EndIf	 

			oTable:Delete()
	
		Else
		
			aRet:= {{""},0}	
			
		EndIf
	
		GTPDestroy(oTable)
		GTPDestroy(aFldConv)
		GTPDestroy(aIndex)

Return aRet
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA702Reajuste
(long_description)
@type function
@author jacomo.fernandes
@since 28/11/2017
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*///------------------------------------------------------------------------------------------
Static Function GA702Reajuste(oModel)

	Local oMdlGI0		:= oModel:GetModel('GI0DETAIL')
	Local oMdlGQD		:= oModel:GetModel('GQDDETAIL')
	Local oMdlG5F		:= oModel:GetModel('G5FDETAIL')
	Local oMdlGI2		:= oModel:GetModel('GI2DETAIL')
	Local oMdlGI4		:= oModel:GetModel('GI4DETAIL')
	Local cTpReaj		:= MV_PAR11 // 1=Tarifa;2=Pedagio;3=Taxa;4=Todos
	Local lCalc			:= .F.
	Local lTarifa		:= cTpReaj == 1 .or. cTpReaj == 4 
	Local lPedagio		:= cTpReaj == 2 .or. cTpReaj == 4 
	Local lTaxa			:= cTpReaj == 3 .or. cTpReaj == 4 
	Local n1,n2,n3,n4,n5

	For n1 :=  1 To oMdlGI0:Length()
	
		oMdlGI0:GoLine(n1)

		For n2 :=  1 To oMdlGQD:Length()
		
			oMdlGQD:GoLine(n2)
			lCalc := .F.
			lCalc := lCalc .Or. (lTarifa .and. oMdlGQD:GetValue('GQD_RJTTAR') $ '1/2') 
			lCalc := lCalc .Or. (lPedagio .and. oMdlGQD:GetValue('GQD_RJTPED') $ '1/2') 
			lCalc := lCalc .Or. (lTaxa .and. oMdlGQD:GetValue('GQD_RJTTAX') $ '1/2') 

			If lCalc
				For n3 :=  1 To oMdlG5F:Length()
				
					oMdlG5F:GoLine(n3)
					
					lCalc := .F.
					lCalc := lCalc .or. lTarifa 
					lCalc := lCalc .or. lPedagio  
					lCalc := lCalc .or. lTaxa  

					If lCalc
						
						If (lTarifa .and. !oMdlG5F:GetValue('G5F_OKTAR')) .or. ;
						(lPedagio .and. !oMdlG5F:GetValue('G5F_OKPED')) .or. ;
						(lTaxa .and. !oMdlG5F:GetValue('G5F_OKTAX'))
							Exit
						Endif
						
						For n4 :=  1 To oMdlGI2:Length()
						
							oMdlGI2:GoLine(n4)
							
							For n5 :=  1 To oMdlGI4:Length()
								
								oMdlGI4:GoLine(n5)
								
								If lTarifa  .AND. !Empty(oModel:GetModel('G5HDETTAR'):GetValue("G5H_CODORG"))
								
									oMdlGI4:LoadValue('GI4_TAR',GetReajVal(oModel,'1'))
								Endif

								If lPedagio .AND. !Empty(oModel:GetModel('G5HDETPED'):GetValue("G5H_CODORG"))
								
									oMdlGI4:LoadValue('GI4_PED',GetReajVal(oModel,'2'))
									
								Endif

								If lTaxa .AND. !Empty(oModel:GetModel('G5HDETTAX'):GetValue("G5H_CODORG"))
								
									oMdlGI4:LoadValue('GI4_TAX',GetReajVal(oModel,'3'))
									
								Endif

							Next
							
						Next
						
					Endif
				
				Next
				
			Endif
			
		Next
		
	Next
	
	oMdlGI0:GoLine(1)
	oMdlGQD:GoLine(1)
	oMdlG5F:GoLine(1)
	oMdlGI2:GoLine(1)
	oMdlGI4:GoLine(1)

	If oGtpLog:HasInfo()
		oGtpLog:ShowLog()
	Endif


Return
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetReajVal
(long_description)
@type function
@author jacomo.fernandes
@since 28/11/2017
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@param cTpReaj, character, (1=Tarifa,2=Pedágio,3=Taxa)
@return ${return}, ${return_description}
/*///------------------------------------------------------------------------------------------
Static Function GetReajVal( oModel, cTpReaj )

	Local nRet		:= 0
	Local oMdlG5F	:= oModel:GetModel('G5FDETAIL')
	Local oMdlGI4	:= oModel:GetModel('GI4DETAIL')
	Local aFieldG5H	:= nil
	Local cMdlAux	:= ""
	Local oMdlG5H	:= nil
	Local cTpCalc	:= ""
	Local aDataMdl	:= Nil
	Local nPos		:= 0
	Local nPosKmIni	:= 0
	Local nPosKmFim	:= 0
	Local nPosVlr	:= 0
	
		If cTpReaj == '1'
			cMdlAux := "G5HDETTAR"
		ElseIf cTpReaj == '2'
			cMdlAux := "G5HDETPED"
		Else
			cMdlAux := "G5HDETTAX"
		Endif
		oMdlG5H		:= oModel:GetModel(cMdlAux)
		aFieldG5H	:= aClone(oMdlG5H:GetStruct():GetFields())
	
		if !oMdlG5H:IsEmpty()
			
			cTpCalc		:= oMdlG5H:GetValue('G5H_TPCALR') //1=Coeficiente;2=Valor Fixo;3=Não Calcular. Lembrete: campo com preenchimento default 2.
		
			If cTpCalc == '1' //Coeficiente 
			
				nRet := GetRetForm(oMdlGI4,oMdlG5F,oMdlG5H,cTpReaj) 
			
			Elseif cTpCalc == '2'  //Valor Fixo
			
				nPosKmIni	:= aScan(aFieldG5H,{|x|x[3] == 'G5H_KMINI' })
				nPosKmFim	:= aScan(aFieldG5H,{|x|x[3] == 'G5H_KMFIM' })
				nPosVlr		:= aScan(aFieldG5H,{|x|x[3] == 'G5H_VALOR' })
				aDataMdl := aClone(oMdlG5H:GetData())
			
				If (nPos := aScan(aDataMdl,{|x| oMdlGI4:GetValue('GI4_KM') >= x[1,1,nPosKmIni].and. oMdlGI4:GetValue('GI4_KM') <= x[1,1,nPosKmFim] }) )> 0
			
					nRet := aDataMdl[nPos,1,1,nPosVlr]
			
				Endif
			
			Endif
		
		EndIf
		
		GTPDestroy(aDataMdl)
		GTPDestroy(aFieldG5H)
		
Return nRet
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetRetForm
(long_description)
@type function
@author jacom
@since 22/11/2017
@version 1.0
@param oMdlGI4, objeto, (Descrição do parâmetro)
@param oMdlG5F, objeto, (Descrição do parâmetro)
@param oMdlG5H, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*///------------------------------------------------------------------------------------------
Static Function GetRetForm(oMdlGI4,oMdlG5F,oMdlG5H,cTpReaj)
	
	Local cFormula	:= oMdlG5H:GetValue('G5H_FORMUL')
	Local nRet		:= 0
	Local bError	:= ErrorBlock({|e| SetErrorMsg(e:Description,oMdlG5F,cTpReaj),Break(e)})
	
		BEGIN SEQUENCE
		
			While At('[|',cFormula) > 0 .or. At('|]',cFormula) > 0  
				cFormula := StrTran(cFormula,'[|',"oMdlGI4:GetValue('")
				cFormula := StrTran(cFormula,'|]',"')")
			End
			If Empty(cFormula)
				cFormula := "0"
			Endif
			nRet := &(cFormula)
			//G5F_VLRMIN campo removido da view, trecho comentado caso cliente solicite esta configuração
			/*If oMdlG5H:GetId() == "G5HDETTAR" .and. (nRet < oMdlG5F:GetValue('G5F_VLRMIN'))
				nRet := oMdlG5F:GetValue('G5F_VLRMIN')
			Endif*/
			If At('.',cValToChar(nRet)) > 0
			
				nRet := Val(SubStr(cValToChar(nRet),1,At('.',cValToChar(nRet))+2))
			
			Endif
			
		END SEQUENCE
		
		ErrorBlock(bError)
		
Return nRet
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} SetErrorMsg
(long_description)
@type function
@author jacom
@since 27/11/2017
@version 1.0
@param cMsg, character, (Descrição do parâmetro)
@param oMdlG5F, objeto, (Descrição do parâmetro)
@param cTpReaj, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*///------------------------------------------------------------------------------------------
Static Function SetErrorMsg(cMsg,oMdlG5F,cTpReaj)

	Local cMsgErro	:= "Falha na aplicação da formula da Categoria: " +Alltrim(oMdlG5F:GetValue('G5F_CODGYR')) + " do Órgão: " + Alltrim(FwFldGet('GI0_COD'))
	Local lErro		:= .F.
	
		If cTpReaj == '1' .and. oMdlG5F:GetValue('G5F_OKTAR')
			oMdlG5F:SetValue('G5F_OKTAR',.F.)
			lErro	:= .T.
		ElseIf cTpReaj == '2' .and. oMdlG5F:GetValue('G5F_OKPED')
			oMdlG5F:SetValue('G5F_OKPED',.F.)
			lErro	:= .T.
		ElseIf cTpReaj == '3' .and. oMdlG5F:GetValue('G5F_OKTAX')
			oMdlG5F:SetValue('G5F_OKTAX',.F.)
			lErro	:= .T.
		Endif
	
		If lErro
			cMsgErro += Chr(13)+Chr(10)+"Foi retornado o seguinte erro: "+cMsg
			oGtpLog:SetText(cMsgErro)
		Endif
		
Return
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} Ga702PosVld
(long_description)
@type function
@author jacomo.fernandes
@since 28/11/2017
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*///------------------------------------------------------------------------------------------
Static Function Ga702PosVld(oModel)

	Local lRet 		:= .T.
	Local oMdlGI0	:= oModel:GetModel('GI0DETAIL')
	Local oMdlGQD	:= oModel:GetModel('GQDDETAIL')
	Local oMdlG5F	:= oModel:GetModel('G5FDETAIL')
	Local oMdlGI2	:= oModel:GetModel('GI2DETAIL')
	Local oMdlGI4	:= oModel:GetModel('GI4DETAIL')
	Local oMdlG5G	:= oModel:GetModel('G5GDETAIL')
	Local n1,n2,n3,n4,n5,nI
	Local dDtReaj	:= dDataBase
	Local cTmReaj	:= Time()
	Local lHist		:= .F.

	For n1 :=  1 To oMdlGI0:Length()
		oMdlGI0:GoLine(n1)
		For n2 :=  1 To oMdlGQD:Length()
			oMdlGQD:GoLine(n2)
			For n3 :=  1 To oMdlG5F:Length()
				oMdlG5F:GoLine(n3)
				For n4 :=  1 To oMdlGI2:Length()
					oMdlGI2:GoLine(n4)
					For n5 :=  1 To oMdlGI4:Length()
						oMdlGI4:GoLine(n5)
						//Adiciona no modelo o historio de tarifa
						For nI := 1 to 3
							lHist := .F.
							//Tarifa - Verifica se uma tarifa e se campo de valor ou data vigencia foi alterada
							If (nI == 1 .And. (oMdlGI4:GetValue('GI4_TAR') <> oMdlGI4:GetValue('GI4_TARATU')))
								nVal := oMdlGI4:GetValue('GI4_TAR')
								dVig := oMdlGI4:GetValue('GI4_VIGTAR')
								lHist := .T.
								//Pedagio - Verifica se uma tarifa e se campo de valor ou data vigencia foi alterada
							Elseif (nI == 2 .And. (oMdlGI4:GetValue('GI4_PED') <> oMdlGI4:GetValue('GI4_PEDATU')))
								nVal := oMdlGI4:GetValue('GI4_PED')
								dVig := oMdlGI4:GetValue('GI4_VIGPED')
								lHist := .T.
								//Embarque - Verifica se uma tarifa e se campo de valor ou data vigencia foi alterada
							Elseif (nI == 3 .And. (oMdlGI4:GetValue('GI4_TAX') <> oMdlGI4:GetValue('GI4_TAXATU')))
								nVal := oMdlGI4:GetValue('GI4_TAX')
								dVig := oMdlGI4:GetValue('GI4_VIGTAX')
								lHist := .T.
							Endif
							If lHist
								If oMdlG5G:Length() >= 1 .and. !Empty(oMdlG5G:GetValue('G5G_TPREAJ'))
									oMdlG5G:AddLine()
								Endif

								oMdlG5G:SetValue('G5G_DTREAJ'	,dDtReaj) 
								oMdlG5G:SetValue('G5G_HRREAJ'	,cTmReaj)
								oMdlG5G:SetValue('G5G_TPREAJ'	,ALLTRIM(STR(nI,0)))
								oMdlG5G:SetValue('G5G_VALOR'	,nVal)
								oMdlG5G:SetValue('G5G_VIGENC'	,dVig)

							Endif
						Next nI

					Next
				Next
			Next
		Next
	Next
	
Return lRet
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetQryFilLoad
(long_description)
@type function
@author jacomo.fernandes
@since 28/11/2017
@version 1.0
@param cQryAlais, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*///------------------------------------------------------------------------------------------
Static Function GetQryFilLoad(cQryAlais)
	
	Local cQryRet := ""
	
	Pergunte('GTPA702',.F.)
	
		If cQryAlais == 'GQD'
		
			cQryRet += "GQD_CODGQC In ( "
			cQryRet += "	Select Distinct GQD_CODGQC " + chr(13)
			cQryRet += "	From "+RetSqlName('GQD')+" GQD " + chr(13)
			cQryRet += "		Inner Join "+RetSqlName('G5F')+" G5F ON " + chr(13)
			cQryRet += "			G5F.G5F_FILIAL = '" + xFilial("G5F") + "' AND " + chr(13)
			cQryRet += "			G5F.G5F_CODGI0 = GQD.GQD_CODGI0 AND " + chr(13)
			cQryRet += "			G5F.G5F_CODGQC = GQD.GQD_CODGQC AND " + chr(13)
			cQryRet += "			G5F.G5F_CODGYR BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' AND " + chr(13)
			cQryRet += "			G5F.D_E_L_E_T_ = ' ' " + chr(13)
			cQryRet += "		Inner Join "+RetSqlName('GI2')+" GI2 ON " + chr(13)
			cQryRet += "			GI2.GI2_FILIAL = '" + xFilial("GI2") + "' AND " + chr(13)
			cQryRet += "			GI2.GI2_ORGAO = GQD.GQD_CODGI0 AND " + chr(13)
			cQryRet += "			GI2.GI2_TIPLIN = GQD.GQD_CODGQC AND " + chr(13)
			cQryRet += "			GI2.GI2_CATEG = G5F.G5F_CODGYR AND " + chr(13)
			cQryRet += "			GI2.GI2_HIST = '2' AND " + chr(13)
			cQryRet += "			GI2.GI2_COD BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' AND " + chr(13)
			cQryRet += "			GI2.D_E_L_E_T_ = ' ' " + chr(13)
			If !Empty(MV_PAR09) .or. !Empty(MV_PAR10) 
				cQryRet += "	Inner Join "+RetSqlName('GI4')+" GI4 ON " + chr(13)
				cQryRet += "		GI4.GI4_FILIAL = '"+xFilial("GI4")+"' AND " + chr(13)
				cQryRet += "		GI4.GI4_LINHA = GI2.GI2_COD AND " + chr(13)
				cQryRet += "		GI4.GI4_HIST = '2' AND " + chr(13)
				If !Empty(MV_PAR09)
					cQryRet += "		GI4.GI4_LOCORI = '"+MV_PAR09+"' AND " + chr(13)
				Endif
				If !Empty(MV_PAR10)
					cQryRet += "		GI4.GI4_LOCDES = '"+MV_PAR10+"' AND " + chr(13)
				Endif
				cQryRet += "		GI4.D_E_L_E_T_ = ' ' " + chr(13)
			Endif
			cQryRet += "	Where " + chr(13)
			cQryRet += "		GQD.GQD_FILIAL = '" + xFilial("GQD") + "' AND " + chr(13)
			cQryRet += "		GQD.GQD_CODGQC BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' AND " + chr(13)
			cQryRet += "		GQD.D_E_L_E_T_ = ' ' " + chr(13)
			cQryRet += ")"
		ElseIf cQryAlais == 'G5F'
			cQryRet += "G5F_CODGYR In ( "
			cQryRet += "	Select Distinct G5F_CODGYR " + chr(13)
			cQryRet += "	From "+RetSqlName('G5F')+" G5F " + chr(13)
			cQryRet += "		Inner Join "+RetSqlName('GI2')+" GI2 ON " + chr(13)
			cQryRet += "			GI2.GI2_FILIAL = '" + xFilial("GI2") + "' AND " + chr(13)
			cQryRet += "			GI2.GI2_ORGAO = G5F.G5F_CODGI0 AND " + chr(13)
			cQryRet += "			GI2.GI2_TIPLIN = G5F.G5F_CODGQC AND " + chr(13)
			cQryRet += "			GI2.GI2_CATEG = G5F.G5F_CODGYR AND " + chr(13)
			cQryRet += "			GI2.GI2_HIST = '2' AND " + chr(13)
			cQryRet += "			GI2.GI2_COD BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' AND " + chr(13)
			cQryRet += "			GI2.D_E_L_E_T_ = ' ' " + chr(13)
			If !Empty(MV_PAR09) .or. !Empty(MV_PAR10) 
				cQryRet += "	Inner Join "+RetSqlName('GI4')+" GI4 ON " + chr(13)
				cQryRet += "		GI4.GI4_FILIAL = '"+xFilial("GI4")+"' AND " + chr(13)
				cQryRet += "		GI4.GI4_LINHA = GI2.GI2_COD AND " + chr(13)
				cQryRet += "		GI4.GI4_HIST = '2' AND " + chr(13)
				If !Empty(MV_PAR09)
					cQryRet += "		GI4.GI4_LOCORI = '"+MV_PAR09+"' AND " + chr(13)
				Endif
				If !Empty(MV_PAR10)
					cQryRet += "		GI4.GI4_LOCDES = '"+MV_PAR10+"' AND " + chr(13)
				Endif
				cQryRet += "		GI4.D_E_L_E_T_ = ' ' " + chr(13)
			Endif
			cQryRet += "	Where " + chr(13)
			cQryRet += "		G5F.G5F_FILIAL = '" + xFilial("G5F") + "' AND " + chr(13)
			cQryRet += "		G5F.G5F_CODGYR BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' AND " + chr(13)
			cQryRet += "		G5F.D_E_L_E_T_ = ' ' " + chr(13)
			cQryRet += ")"
	
		ElseIf cQryAlais == 'GI2'
			cQryRet += "GI2_COD In ( "
			cQryRet += "	Select Distinct GI2_COD " + chr(13)
			cQryRet += "	From "+RetSqlName('GI2')+" GI2 " + chr(13)
			If !Empty(MV_PAR09) .or. !Empty(MV_PAR10) 
				cQryRet += "	Inner Join "+RetSqlName('GI4')+" GI4 ON " + chr(13)
				cQryRet += "		GI4.GI4_FILIAL = '"+xFilial("GI4")+"' AND " + chr(13)
				cQryRet += "		GI4.GI4_LINHA = GI2.GI2_COD AND " + chr(13)
				cQryRet += "		GI4.GI4_HIST = '2' AND " + chr(13)
				If !Empty(MV_PAR09)
					cQryRet += "		GI4.GI4_LOCORI = '"+MV_PAR09+"' AND " + chr(13)
				Endif
				If !Empty(MV_PAR10)
					cQryRet += "		GI4.GI4_LOCDES = '"+MV_PAR10+"' AND " + chr(13)
				Endif
				cQryRet += "		GI4.D_E_L_E_T_ = ' ' " + chr(13)
			Endif
			cQryRet += "	Where " + chr(13)
			cQryRet += "			GI2.GI2_HIST = '2' AND " + chr(13)
			cQryRet += "			GI2.GI2_COD BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' AND " + chr(13)
			cQryRet += "			GI2.D_E_L_E_T_ = ' ' " + chr(13)
			cQryRet += ")"
	
		Endif

Return cQryRet
