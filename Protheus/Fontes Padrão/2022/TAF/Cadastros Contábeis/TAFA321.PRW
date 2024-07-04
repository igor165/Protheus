#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA321.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA321
Cadastro MVC de Identificação dos Períodos e Formas de Apuração do IRPJ e da CSLL das Empresas Tributadas pelo Lucro Presumido 

@author Denis R de Oliveira
@since 19/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA321()

Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 )	//"Cadastro de Identificação dos Períodos e Formas de Apuração do IRPJ e da CSLL das Empresas Tributadas pelo Lucro Presumido"
oBrw:SetAlias( 'CEG')
oBrw:SetMenuDef( 'TAFA321' )
CEG->(DbSetOrder(2))
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu
@author Denis R de Oliveira
@since 19/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {{ "" , "TAF321Vld" , "2" } }
Local aRotina := {}

aRotina	:=	xFunMnuTAF( "TAFA321" , , aFuncao )


Return( aRotina )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Denis R de Oliveira
@since 19/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruCEG 	:= 	FWFormStruct( 1, 'CEG' )
Local oStruCEH 	:= 	FWFormStruct( 1, 'CEH' )
Local oStruCEI 	:= 	FWFormStruct( 1, 'CEI' )
Local oStruCHE 	:= 	FWFormStruct( 1, 'CHE' )
LocaL oModel 	:=  MPFormModel():New( 'TAFA321' , , , {|oModel| SaveModel( oModel ) } )  

lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )
	
If lVldModel
	oStruCEG:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel }) 		
EndIf

oStruCEI:SetProperty( 'CEI_REGECF' , MODEL_FIELD_INIT ,{| oModel | Iif(oModel:Getid()=='MODEL_CEIa',"01",Iif(oModel:Getid()=='MODEL_CEIb',"02",;
 Iif(oModel:Getid()=='MODEL_CEIc',"03",Iif(oModel:Getid()=='MODEL_CEId',"04",Iif(oModel:Getid()=='MODEL_CEIe',"05","06"))))) })

oStruCEI:SetProperty( "CEI_CODIGO", MODEL_FIELD_VALID , ;
{ |oModel| Iif( oModel:GetId() == "MODEL_CEIa", xFunVldCmp( "CH6", 2, PadR( "P130", TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CEI_CODIGO" ) ),;
Iif( oModel:GetId() == "MODEL_CEIb", xFunVldCmp( "CH6", 2, PadR( "P200", TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CEI_CODIGO" ) ),;
Iif( oModel:GetId() == "MODEL_CEIc", xFunVldCmp( "CH6", 2, PadR( "P230", TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CEI_CODIGO" ) ),;
Iif( oModel:GetId() == "MODEL_CEId", xFunVldCmp( "CH6", 2, PadR( "P300", TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CEI_CODIGO" ) ),;
Iif( oModel:GetId() == "MODEL_CEIe", xFunVldCmp( "CH6", 2, PadR( "P400", TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CEI_CODIGO" ) ),;
xFunVldCmp( "CH6", 2, PadR( "P500", TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CEI_CODIGO" )  ) ) ) ) ) ) } )

oStruCEI:AddTrigger( "CEI_CODIGO", "CEI_DESCRI",, ;
{ |oModel| Iif( oModel:GetId() == "MODEL_CEIa", Posicione( "CH6", 2, xFilial( "CH6" ) + PadR( "P130", TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CEI_CODIGO" ), "CH6_DESCRI" ),;
Iif( oModel:GetId() == "MODEL_CEIb", Posicione( "CH6", 2, xFilial( "CH6" ) + PadR( "P200", TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CEI_CODIGO" ), "CH6_DESCRI" ),;
Iif( oModel:GetId() == "MODEL_CEIc", Posicione( "CH6", 2, xFilial( "CH6" ) + PadR( "P230", TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CEI_CODIGO" ), "CH6_DESCRI" ),;
Iif( oModel:GetId() == "MODEL_CEId", Posicione( "CH6", 2, xFilial( "CH6" ) + PadR( "P300", TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CEI_CODIGO" ), "CH6_DESCRI" ),;
Iif( oModel:GetId() == "MODEL_CEIe", Posicione( "CH6", 2, xFilial( "CH6" ) + PadR( "P400", TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CEI_CODIGO" ), "CH6_DESCRI" ),;
Posicione( "CH6", 2, xFilial( "CH6" ) + PadR( "P500", TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CEI_CODIGO" ), "CH6_DESCRI" ))))))})

oStruCEI:AddTrigger( "CEI_CODIGO", "CEI_IDCODC",, ;
{ |oModel| Iif( oModel:GetId() == "MODEL_CEIa", Posicione( "CH6", 2, xFilial( "CH6" ) + PadR( "P130", TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CEI_CODIGO" ), "CH6_ID" ),;
Iif( oModel:GetId() == "MODEL_CEIb", Posicione( "CH6", 2, xFilial( "CH6" ) + PadR( "P200", TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CEI_CODIGO" ), "CH6_ID" ),;
Iif( oModel:GetId() == "MODEL_CEIc", Posicione( "CH6", 2, xFilial( "CH6" ) + PadR( "P230", TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CEI_CODIGO" ), "CH6_ID" ),;
Iif( oModel:GetId() == "MODEL_CEId", Posicione( "CH6", 2, xFilial( "CH6" ) + PadR( "P300", TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CEI_CODIGO" ), "CH6_ID" ),;
Iif( oModel:GetId() == "MODEL_CEIe", Posicione( "CH6", 2, xFilial( "CH6" ) + PadR( "P400", TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CEI_CODIGO" ), "CH6_ID" ),;
Posicione( "CH6", 2, xFilial( "CH6" ) + PadR( "P500", TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CEI_CODIGO" ), "CH6_ID" ))))))})

oModel:AddFields('MODEL_CEG' , /*cOwner*/, oStruCEG) 

oModel:AddGrid ('MODEL_CEH', 'MODEL_CEG',oStruCEH)  
oModel:GetModel('MODEL_CEH'):SetOptional( .T. )
oModel:GetModel('MODEL_CEH'):SetUniqueLine( { 'CEH_IDCODC' } )  

oModel:AddGrid('MODEL_CEIa', 'MODEL_CEG',oStruCEI)  
oModel:GetModel('MODEL_CEIa'):SetOptional( .T. )
oModel:GetModel('MODEL_CEIa'):SetLoadFilter({{ "CEI_REGECF", "'01'" }})
oModel:GetModel('MODEL_CEIa'):SetUniqueLine({ "CEI_REGECF","CEI_IDCODC" } )

oModel:AddGrid('MODEL_CEIb', 'MODEL_CEG',oStruCEI)
oModel:GetModel('MODEL_CEIb'):SetOptional( .T. )
oModel:GetModel('MODEL_CEIb'):SetLoadFilter({{ "CEI_REGECF", "'02'" }})
oModel:GetModel('MODEL_CEIb'):SetUniqueLine({ "CEI_REGECF","CEI_IDCODC" } ) 

oModel:AddGrid('MODEL_CEIc', 'MODEL_CEG',oStruCEI)  
oModel:GetModel('MODEL_CEIc'):SetOptional( .T. )
oModel:GetModel('MODEL_CEIc'):SetLoadFilter({{ "CEI_REGECF", "'03'" }})
oModel:GetModel('MODEL_CEIc'):SetUniqueLine({ "CEI_REGECF","CEI_IDCODC" } ) 

oModel:AddGrid('MODEL_CEId', 'MODEL_CEG',oStruCEI)
oModel:GetModel('MODEL_CEId'):SetOptional( .T. )
oModel:GetModel('MODEL_CEId'):SetLoadFilter({{ "CEI_REGECF", "'04'" }})
oModel:GetModel('MODEL_CEId'):SetUniqueLine({ "CEI_REGECF","CEI_IDCODC" } ) 

oModel:AddGrid('MODEL_CEIe', 'MODEL_CEG',oStruCEI)  
oModel:GetModel('MODEL_CEIe'):SetOptional( .T. )
oModel:GetModel('MODEL_CEIe'):SetLoadFilter({{ "CEI_REGECF", "'05'" }})
oModel:GetModel('MODEL_CEIe'):SetUniqueLine({ "CEI_REGECF","CEI_IDCODC" } )

oModel:AddGrid('MODEL_CEIf', 'MODEL_CEG',oStruCEI)  
oModel:GetModel('MODEL_CEIf'):SetOptional( .T. )
oModel:GetModel('MODEL_CEIf'):SetLoadFilter({{ "CEI_REGECF", "'06'" }})
oModel:GetModel('MODEL_CEIf'):SetUniqueLine({ "CEI_REGECF","CEI_IDCODC" } )  

oModel:AddGrid ('MODEL_CHE', 'MODEL_CEG',oStruCHE)  
oModel:GetModel('MODEL_CHE'):SetOptional( .T. )
oModel:GetModel('MODEL_CHE'):SetUniqueLine( { 'CHE_IDCODC' } )  

/*-----------------------------------------------------------------------------------
Abaixo realiza-se a amarração das tabelas
-------------------------------------------------------------------------------------*/
//Define a chave única de gravação das informações
oModel:GetModel('MODEL_CEG'):SetPrimaryKey( {'CEG_DTINI','CEG_DTFIN','CEG_IDPERA'} ) 

oModel:SetRelation(  "MODEL_CEH", {{ "CEH_FILIAL","xFilial('CEH')" },{'CEH_ID','CEG_ID'}}, CEH->( IndexKey(1)))

oModel:SetRelation( 'MODEL_CEIa', {{ 'CEI_FILIAL',"xFilial('CEI')" },{'CEI_ID','CEG_ID'}}, CEI->( IndexKey(1)))
oModel:SetRelation( 'MODEL_CEIb', {{ 'CEI_FILIAL',"xFilial('CEI')" },{'CEI_ID','CEG_ID'}}, CEI->( IndexKey(1)))
oModel:SetRelation( 'MODEL_CEIc', {{ 'CEI_FILIAL',"xFilial('CEI')" },{'CEI_ID','CEG_ID'}}, CEI->( IndexKey(1)))
oModel:SetRelation( 'MODEL_CEId', {{ 'CEI_FILIAL',"xFilial('CEI')" },{'CEI_ID','CEG_ID'}}, CEI->( IndexKey(1)))
oModel:SetRelation( 'MODEL_CEIe', {{ 'CEI_FILIAL',"xFilial('CEI')" },{'CEI_ID','CEG_ID'}}, CEI->( IndexKey(1)))
oModel:SetRelation( 'MODEL_CEIf', {{ 'CEI_FILIAL',"xFilial('CEI')" },{'CEI_ID','CEG_ID'}}, CEI->( IndexKey(1)))
             
oModel:SetRelation(  "MODEL_CHE", {{ "CHE_FILIAL","xFilial('CHE')" },{'CHE_ID','CEG_ID'}}, CHE->( IndexKey(1)))

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Denis R de Oliveira
@since 19/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel 	:= 	FWLoadModel( 'TAFA321' )
Local oStruCEG 	:= 	FWFormStruct( 2, 'CEG' )
Local oStruCEH	:= 	FWFormStruct( 2, 'CEH' )

Local oStruCEIa := 	FWFormStruct( 2, 'CEI' )
Local oStruCEIb := 	FWFormStruct( 2, 'CEI' )
Local oStruCEIc := 	FWFormStruct( 2, 'CEI' )
Local oStruCEId := 	FWFormStruct( 2, 'CEI' )
Local oStruCEIe := 	FWFormStruct( 2, 'CEI' )
Local oStruCEIf := 	FWFormStruct( 2, 'CEI' )

Local oStruCHE	:= 	FWFormStruct( 2, 'CHE' )

Local oView 	  := 	FWFormView():New()

oStruCEIa:SetProperty( "CEI_CODIGO" , MVC_VIEW_LOOKUP , "CH6A" )
oStruCEIb:SetProperty( "CEI_CODIGO" , MVC_VIEW_LOOKUP , "CH6B" )
oStruCEIc:SetProperty( "CEI_CODIGO" , MVC_VIEW_LOOKUP , "CH6C" ) 
oStruCEId:SetProperty( "CEI_CODIGO" , MVC_VIEW_LOOKUP , "CH6D" )
oStruCEIe:SetProperty( "CEI_CODIGO" , MVC_VIEW_LOOKUP , "CH6E" )
oStruCEIf:SetProperty( "CEI_CODIGO" , MVC_VIEW_LOOKUP , "CH6F" )

/*----------------------------------------------------------------------------------
Esrutura da View
-------------------------------------------------------------------------------------*/

oStruCEG:RemoveField('CEG_ID')  
oStruCEG:RemoveField('CEG_IDPERA')
oStruCEH:RemoveField('CEH_IDCODC')
oStruCEIa:RemoveField('CEI_REGECF')
oStruCEIb:RemoveField('CEI_REGECF')
oStruCEIc:RemoveField('CEI_REGECF')
oStruCEId:RemoveField('CEI_REGECF')
oStruCEIe:RemoveField('CEI_REGECF')
oStruCEIf:RemoveField('CEI_REGECF')
oStruCEIa:RemoveField('CEI_IDCODC')
oStruCEIb:RemoveField('CEI_IDCODC')
oStruCEIc:RemoveField('CEI_IDCODC')
oStruCEId:RemoveField('CEI_IDCODC')
oStruCEIe:RemoveField('CEI_IDCODC')
oStruCEIf:RemoveField('CEI_IDCODC')

If TAFColumnPos( "CEI_ORIGEM" )
	oStruCEIa:RemoveField( "CEI_ORIGEM" )
	oStruCEIb:RemoveField( "CEI_ORIGEM" )
	oStruCEIc:RemoveField( "CEI_ORIGEM" )
	oStruCEId:RemoveField( "CEI_ORIGEM" )
	oStruCEIe:RemoveField( "CEI_ORIGEM" )
	oStruCEIf:RemoveField( "CEI_ORIGEM" )
EndIf

oStruCHE:RemoveField('CHE_IDCODC')


oView:SetModel( oModel )
                                       
oView:AddField('VIEW_CEG' , oStruCEG,  'MODEL_CEG' ) 
oView:EnableTitleView( 'VIEW_CEG', STR0001 ) //"Cadastro de Identificação dos Períodos e Formas de Apuração do IRPJ e da CSLL das Empresas Tributadas pelo Lucro Presumido" 

oView:AddGrid( 'VIEW_CEH' , oStruCEH,  'MODEL_CEH' )
oView:EnableTitleView( 'VIEW_CEH', STR0003 ) //"Balanço Patrimonial"

oView:AddGrid( 'aVIEW_CEI', oStruCEIa, 'MODEL_CEIa' )
oView:EnableTitleView( 'aVIEW_CEI', STR0004 ) //"Demonstração das Receitas Incentivadas do Lucro Presumido"
oView:AddGrid( 'bVIEW_CEI', oStruCEIb, 'MODEL_CEIb' ) 
oView:EnableTitleView( 'bVIEW_CEI', STR0005 ) //"Apuração da Base de Cálculo do Lucro Presumido"
oView:AddGrid( 'cVIEW_CEI', oStruCEIc, 'MODEL_CEIc' )    
oView:EnableTitleView( 'cVIEW_CEI', STR0006 ) //"Cálculo da Isenção e Redução do Lucro Presumido"
oView:AddGrid( 'dVIEW_CEI', oStruCEId, 'MODEL_CEId' )
oView:EnableTitleView( 'dVIEW_CEI', STR0007 ) //"Cálculo do IRPJ com Base no Lucro Presumido"
oView:AddGrid( 'eVIEW_CEI', oStruCEIe, 'MODEL_CEIe' )
oView:EnableTitleView( 'eVIEW_CEI', STR0008 ) //"Apuração da Base de Cálculo da CSLL com Base no Lucro Presumido"
oView:AddGrid( 'fVIEW_CEI', oStruCEIf, 'MODEL_CEIf' )
oView:EnableTitleView( 'fVIEW_CEI', STR0009 ) //"Cálculo da CSLL com Base no Lucro Presumido" 

oView:AddGrid( 'VIEW_CHE' , oStruCHE,  'MODEL_CHE' )
oView:EnableTitleView( 'VIEW_CHE', STR0017 ) //"Demonstrativo do Resultado do Exercício"

/*-----------------------------------------------------------------------------------
Estrutura do Folder
-------------------------------------------------------------------------------------*/
oView:CreateHorizontalBox("PAINEL_PRINCIPAL",25)
oView:CreateFolder("FOLDER_PRINCIPAL","PAINEL_PRINCIPAL") // CEG - Identificação dos Períodos e Formas de Apuração do IRPJ e da CSLL das Empresas Tributadas pelo Lucro Presumido 

oView:CreateHorizontalBox("PAINEL_INFERIOR",75)
oView:CreateFolder("FOLDER_INFERIOR","PAINEL_INFERIOR") //CEI - Registros Genéricos - Bloco P  

oView:AddSheet("FOLDER_INFERIOR","ABA01",STR0003) //"Balanço Patrimonial"
oView:CreateHorizontalBox("PAINEL_BALANCO",100,,,"FOLDER_INFERIOR","ABA01")  
oView:CreateFolder("FOLDER_BALANCO","PAINEL_BALANCO")

oView:AddSheet("FOLDER_INFERIOR","ABA02",STR0016) //Registros Genéricos 
oView:CreateHorizontalBox("PAINEL_REGISTROS",100,,,"FOLDER_INFERIOR","ABA02")
oView:CreateFolder("FOLDER_REGISTROS","PAINEL_REGISTROS") //CEI - Registros Genéricos - Bloco 

oView:AddSheet("FOLDER_REGISTROS","ABA01",STR0010) //Demonst. Receitas Incentivadas do Lucro Presumido
oView:CreateHorizontalBox("PAINEL_CEIa",100,,,"FOLDER_REGISTROS","ABA01")
oView:AddSheet("FOLDER_REGISTROS","ABA02",STR0011) //Apur. da Base de Cálculo do Lucro Presumido
oView:CreateHorizontalBox("PAINEL_CEIb",100,,,"FOLDER_REGISTROS","ABA02")
oView:AddSheet("FOLDER_REGISTROS","ABA03",STR0012) //Cálc. da Isenção e Redução do Lucro Presumido
oView:CreateHorizontalBox("PAINEL_CEIc",100,,,"FOLDER_REGISTROS","ABA03")
oView:AddSheet("FOLDER_REGISTROS","ABA04",STR0013) //Cálc. do IRPJ com Base no Lucro Presumido
oView:CreateHorizontalBox("PAINEL_CEId",100,,,"FOLDER_REGISTROS","ABA04")
oView:AddSheet("FOLDER_REGISTROS","ABA05",STR0014) //Apur. da Base de Cálculo da CSLL c/ Base no Lucro Pres.
oView:CreateHorizontalBox("PAINEL_CEIe",100,,,"FOLDER_REGISTROS","ABA05")
oView:AddSheet("FOLDER_REGISTROS","ABA06",STR0015) //Cálc. da CSLL com Base no Lucro Presumido
oView:CreateHorizontalBox("PAINEL_CEIf",100,,,"FOLDER_REGISTROS","ABA06")

oView:AddSheet("FOLDER_INFERIOR","ABA03",STR0017) //"Demonstrativo do Resultado do Exercício"
oView:CreateHorizontalBox("PAINEL_DEMONSTRATIVO",100,,,"FOLDER_INFERIOR","ABA03")  
oView:CreateFolder("FOLDER_DEMONSTRATIVO","PAINEL_DEMONSTRATIVO")

/*-----------------------------------------------------------------------------------
Amarração para exibição das informações
-------------------------------------------------------------------------------------*/
oView:SetOwnerView( 'VIEW_CEG', 'PAINEL_PRINCIPAL' )   

oView:SetOwnerView( 'VIEW_CEH', 'PAINEL_BALANCO' ) 

oView:SetOwnerView( 'aVIEW_CEI', 'PAINEL_CEIa' ) 
oView:SetOwnerView( 'bVIEW_CEI', 'PAINEL_CEIb' ) 
oView:SetOwnerView( 'cVIEW_CEI', 'PAINEL_CEIc' ) 
oView:SetOwnerView( 'dVIEW_CEI', 'PAINEL_CEId' ) 
oView:SetOwnerView( 'eVIEW_CEI', 'PAINEL_CEIe' ) 
oView:SetOwnerView( 'fVIEW_CEI', 'PAINEL_CEIf' ) 

oView:SetOwnerView( 'VIEW_CHE', 'PAINEL_DEMONSTRATIVO' ) 

xFunRmFStr(@oStruCEIa, 'CEI')

xFunRmFStr(@oStruCEIb, 'CEI')

xFunRmFStr(@oStruCEIc, 'CEI')

xFunRmFStr(@oStruCEId, 'CEI')

xFunRmFStr(@oStruCEIe, 'CEI')

xFunRmFStr(@oStruCEIf, 'CEI')


Return oView    

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Denis R. de Oliveira
@since 19/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

Local nOperation := oModel:GetOperation()

Begin Transaction

	If nOperation == MODEL_OPERATION_UPDATE
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Funcao responsavel por setar o Status do registro para Branco³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TAFAltStat( "CEG", " " )	
	
	EndIf

	FwFormCommit( oModel )
        

End Transaction
       

Return .T.
 
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Taf321Vld

@author Denis R. de Oliveira
@since 19/05/2014
@version 1.0
/*/                                                                                                                                          
//------------------------------------------------------------------------------------
Function TAF321Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro	:= {}
Local cIdTpCnt := ""
Local cTipCont := ""
Local cPerAPur := ""
Local nSALINIA := 0
Local nSALINIP := 0
Local nSALFINA := 0
Local nSALFINP := 0

Default lJob := .F.

If CEG->CEG_STATUS $ ( " |1" )      

    //Chave de busca na tabela FILHO ou Consulta padrao
	cChave := CEG->CEG_IDPERA
	xVldECFTab("CAH",cChave,1,,@aLogErro,{ "CEG","CEG_PERAPU", nRecno}) 
		
	cPerApur:= Alltrim(Posicione("CAH",1,xFilial("CAH")+CEG->CEG_IDPERA,"CAH_CODIGO"))


	//Valida a Data de início do período
	If Empty(CEG->CEG_DTINI)
		Aadd( aLogErro, {"CEG_DTINI", "000001", "CEG", nRecno}) //STR0001 - Campo Inconsistente ou Vazio
	EndIf
	
	//Valida a Data de fim do período
	If Empty(CEG->CEG_DTFIN)
		Aadd( aLogErro, {"CEG_DTFIN", "000001", "CEG", nRecno}) //STR0001 - Campo Inconsistente ou Vazio
	EndIf  
		
	If CEG->CEG_DTINI > CEG->CEG_DTFIN
		aAdd( aLogErro,{ "CEG_DTFIN", "000033", "CEG", nRecno } ) //STR0033 - "A data de período final dever ser maior ou igual a data de período inicial."
	EndIf
	
	//VALIDA_PERIODO
	//xVldECFReg( cAlias,"VALIDA_PERIODO_TRIMESTRAL", @aLogErro,{CEG->CEG_DTINI,CEG->CEG_DTFIN,CEG->CEG_IDPERA,"P",.T.})

	//Valida o Periodo de apuração
	If Empty(CEG->CEG_IDPERA)
		Aadd( aLogErro, {"CEG_PERAPU", "000001","CEG", nRecno}) //STR0001 - Campo Inconsistente ou Vazio
    Else 
		
		If !(cPerApur $ ("T01|T02|T03|T04"))
		
			AADD(aLogErro,{"CEG_PERAPU","000009","CEG", nRecno}) //STR0010 - O período deve estar compreendido entre a data de início e data fim de período.
			
   		ElseIf cPerApur == "T01" .And. ( !( Substr(DTOS(CEG->CEG_DTINI),5,2) >= "01" .And. Substr(DTOS(CEG->CEG_DTINI),5,2) <= "03" ) .OR. !( Substr(DTOS(CEG->CEG_DTFIN),5,2) >= "01" .And. Substr(DTOS(CEG->CEG_DTFIN),5,2) <= "03" )) 
	   
	   		AADD(aLogErro,{"CEG_PERAPU","000009","CEG", nRecno}) //STR0010 - O período deve estar compreendido entre a data de início e data fim de período.
	   
	    ElseIf cPerApur == "T02" .And. ( !( Substr(DTOS(CEG->CEG_DTINI),5,2) >= "04" .And. Substr(DTOS(CEG->CEG_DTINI),5,2) <= "06" ) .OR. !( Substr(DTOS(CEG->CEG_DTFIN),5,2) >= "04" .And. Substr(DTOS(CEG->CEG_DTFIN),5,2) <= "06" ))  
	        
	    	AADD(aLogErro,{"CEG_PERAPU","000009","CEG", nRecno}) //STR0010 - O período deve estar compreendido entre a data de início e data fim de período.
	    
	   	ElseIf cPerApur == "T03" .And. ( !( Substr(DTOS(CEG->CEG_DTINI),5,2) >= "07" .And. Substr(DTOS(CEG->CEG_DTINI),5,2) <= "09" ) .OR. !( Substr(DTOS(CEG->CEG_DTFIN),5,2) >= "07" .And. Substr(DTOS(CEG->CEG_DTFIN),5,2) <= "09" ))
	        
	   		AADD(aLogErro,{"CEG_PERAPU","000009","CEG", nRecno}) //STR0010 - O período deve estar compreendido entre a data de início e data fim de período.
	   		
	    ElseIf cPerApur == "T04" .And. ( !( Substr(DTOS(CEG->CEG_DTINI),5,2) >= "10" .And. Substr(DTOS(CEG->CEG_DTINI),5,2) <= "12" ) .OR. !( Substr(DTOS(CEG->CEG_DTFIN),5,2) >= "10" .And. Substr(DTOS(CEG->CEG_DTFIN),5,2) <= "12" ))
	          
	   		AADD(aLogErro,{"CEG_PERAPU","000009","CEG", nRecno}) //STR0010 - O período deve estar compreendido entre a data de início e data fim de período.
	   
		ElseIf (CEG->CEG_DTFIN) < (CEG->CEG_DTINI)
		    
			AADD(aLogErro,{"CEG_DTFIN","000010","CEG", nRecno}) //STR0011 - A data de fim do período dever ser maior ou igual a data de início do período.
		
		EndIf
   
	EndIf

	//-----------------------------------//
	// Valida a Grid Balanço Patrimonial //
	//-----------------------------------//
	DBSelectArea( "CEH" )
	CEH->( DBSetOrder( 1 ) )
	If CEH->( MsSeek( xFilial( "CEH" ) + CEG->CEG_ID ) )

		If TAFSeekPer( dtos(CEG->CEG_DTINI), dtos(CEG->CEG_DTFIN ))
			If CHD->CHD_TIPESC == "2" .and. CHD->CHD_RECREC <> "2"
				aAdd( aLogErro, { "CEH_CODCTA", "000327", "CEG", nRecno } ) //STR0327 - "Caso a Escrituração seja informada com 'L' (Livro Caixa), o Registro P100 (Balanço Patrimonial) não deve ser preenchido, exceto se estiver parametrizado como Regime de Competência, quando este registro será obrigatório, mesmo que a empresa não tenha entregue/recuperado a ECD."
			EndIf
		EndIf

		cID := CEH->CEH_ID

		While ( !CEH->( Eof() ) .and. cId == CEH->CEH_ID )

			//Valida o Código da Conta
			If Empty( CEH->CEH_IDCODC) 
				aAdd( aLogErro, { "CEH_CODCTA", "000001", "CEG", nRecno } ) //STR0001 - "Campo Inconsistente ou Vazio"
			Else
				//Chave de busca na Tabela Filha ou Consulta Padrão
				cChave := CEH->CEH_IDCODC
				xVldECFTab( "CHA", cChave, 1,, @aLogErro, { "CEG", "CEH_CODCTA", nRecno } )
			EndIf

			//Valida o Saldo Inicial
			If Empty( CEH->CEH_SALINI )
				aAdd( aLogErro, { "CEH_SALINI", "000001", "CEG", nRecno } ) //STR0001 - "Campo Inconsistente ou Vazio"
			EndIf

			//Valida o Ind. Saldo Inicial
			If Empty( CEH->CEH_INDINI )
				aAdd( aLogErro, { "CEH_INDINI", "000001", "CEG", nRecno } ) //STR0001 - "Campo Inconsistente ou Vazio"
			Else
				If !( CEH->CEH_INDINI $ ( "1|2" ) )
					aAdd( aLogErro, { "CEH_INDINI", "000002", "CEG", nRecno } ) //STR0002 - "Conteúdo do campo não condiz com as opções possíveis"
				EndIf
			EndIf

			//Valida o Saldo Final
			If Empty( CEH->CEH_SALFIN )
				aAdd( aLogErro, { "CEH_SALFIN", "000001", "CEG", nRecno } ) //STR0001 - "Campo Inconsistente ou Vazio"
			EndIf

			//Valida o Ind. Saldo Final
			If Empty( CEH->CEH_INDFIN )
				aAdd( aLogErro, { "CEH_INDFIN", "000001", "CEG", nRecno } ) //STR0001 - "Campo Inconsistente ou Vazio"
			Else
				If !( CEH->CEH_INDFIN $ ( "1|2" ) )
					aAdd( aLogErro, { "CEH_INDFIN", "000002", "CEG", nRecno } ) //STR0002 - "Conteúdo do campo não condiz com as opções possíveis"
				EndIf
			EndIf

			cIDTpCnt := Posicione( "CHA", 1, xFilial( "CHA" ) + CEH->CEH_IDCODC, "CHA_CODNAT" )
			cTipCont := Posicione( "C2R", 3, xFilial( "C2R" ) + cIDTpCnt, "C2R_CODIGO" )

			//Somatório do valor do saldo inicial.
			//Se situação do saldo final for devedor, subtrai. Senão, soma.
			If cTipCont == "01"
				If CEH->CEH_INDINI == "1"
					nSALINIA -= CEH->CEH_SALINI
				Else
					nSALINIA += CEH->CEH_SALINI
				EndIf
			ElseIf cTipCont == "02"
				If CEH->CEH_INDINI == "1"
					nSALINIP -= CEH->CEH_SALINI
				Else
					nSALINIP += CEH->CEH_SALINI
				EndIf
			EndIf

			//Somatório do valor do saldo final.
			//Se situação do saldo final for devedor, subtrai. Senão, soma.
			If cTipCont == "01"
				If CEH->CEH_INDFIN == "1"
					nSALFINA -= CEH->CEH_SALFIN
				Else
					nSALFINA += CEH->CEH_SALFIN
				EndIf
			ElseIf cTipCont == "02"
				If CEH->CEH_INDFIN == "1"
					nSALFINP -= CEH->CEH_SALFIN
				Else
					nSALFINP += CEH->CEH_SALFIN
				EndIf
			EndIf

			CEH->( DBSkip() )
		EndDo

	EndIf

	//------------------------------------------//                                                                            
	/* Valida a Grid Registros Genéricos        */
	//------------------------------------------//
	dbSelectArea("CEI")
	CEI->(dbSetORder(1))
	If CEI->(MsSeek(xFilial("CEI") + CEG->CEG_ID))
		cId:=CEI->CEI_ID
		While (!CEI->(Eof()) .And. cId==CEI->CEI_ID)
			
			//Valida o Código
			If Empty( CEI->CEI_IDCODC )
				aAdd( aLogErro, { "CEI_IDCODC", "000001", "CEG", nRecno } ) //STR0001 - Campo Inconsistente ou Vazio
			EndIf
			
			CEI->(dbSkip())
			
		Enddo
		
	Endif

	//-------------------------------------------------------//
	// Valida a Grid Demonstrativo do Resultado do Exercício //
	//-------------------------------------------------------//
	DBSelectArea( "CHE" )
	CHE->( DBSetORder( 1 ) )
	If CHE->( MsSeek( xFilial( "CHE" ) + CEG->CEG_ID ) )

		If TAFSeekPer( dtos(CEG->CEG_DTINI), dtos(CEG->CEG_DTFIN) )
			If CHD->CHD_TIPESC == "2" .and. CHD->CHD_RECREC <> "2"
				aAdd( aLogErro, { "CHE_CODCTA", "000328", "CEG", nRecno } ) //STR0328 - "Caso a Escrituração seja informada com 'L' (Livro Caixa), o Registro P150 (Demonstrativo do Resultado Líquido no Período Fiscal) não deve ser preenchido, exceto se estiver parametrizado como Regime de Competência, quando este registro será obrigatório, mesmo que a empresa não tenha entregue/recuperado a ECD."
			EndIf
		EndIf

		cID := CHE->CHE_ID

		While ( !CHE->(Eof() ) .and. cID == CHE->CHE_ID )
			//Valida o Código da Conta
			If Empty( CHE->CHE_IDCODC )
				aAdd( aLogErro, { "CHE_CODCTA", "000001", "CEG", nRecno } ) //STR0001 - "Campo Inconsistente ou Vazio"
			Else
				//Chave de busca na Tabela Filha ou Consulta Padrão
				cChave := CHE->CHE_IDCODC
				xVldECFTab( "CHA", cChave, 1,, @aLogErro,{ "CEG", "CHE_CODCTA", nRecno } )
			EndIf

			//Valida o Saldo Inicial
			If Empty( CHE->CHE_SALFIN )
				aAdd( aLogErro, { "CHE_SALFIN", "000001", "CEG", nRecno } ) //STR0001 - "Campo Inconsistente ou Vazio"
			EndIf

			//Valida o Ind. Saldo Inicial
			If Empty( CHE->CHE_INDFIN )
				aAdd( aLogErro, { "CHE_INDFIN", "000001", "CEG", nRecno } ) //STR0001 - "Campo Inconsistente ou Vazio"
			Else
				If !( CHE->CHE_INDFIN $ ( "1|2" ) )
					aAdd( aLogErro, { "CHE_INDFIN", "000002", "CEG", nRecno } ) //STR0002 - "Conteúdo do campo não condiz com as opções possíveis"
				EndIf
			EndIf

			CHE->( DBSkip() )
		EndDo
	EndIf

	//REGRA_BALANCO_SALDO_FINAL
	If ( nSALFINA + nSALFINP ) <> 0 
		If  cPerAPur == "T04"
			AADD(aLogErro,{"CEH_SALFIN","000162","CEG",nRecno}) //STR0161 - "Saldo do Ativo deve ser Igual ao Passivo (soma dos campos 'Saldo Ini' e 'Saldo Ini' devem ser iguais de acordo com a natureza) para o periodo T01"
		EndIf
	EndIf		
	
	//REGRA_BALANCO_SALDO_INICIAL
	If ( nSALINIA + nSALINIP ) <> 0
		If cPerAPur == "T01"
			AADD(aLogErro,{"CEH_SALINI","000161","CEG",nRecno}) //STR0162 - "Saldo do Ativo deve ser Igual ao Passivo (soma dos campos 'Saldo Fin' e 'Saldo Fin' devem ser iguais de acordo com a natureza) para o periodo T04"
		EndIf
	EndIf	


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ATUALIZO O STATUS DO REGISTRO³
	//³1 = Registro Invalido        ³
	//³0 = Registro Valido          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aLogErro)>0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Utilizo RecLock, pois o SETVALUE somente funciona em campos USADOS³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RecLock("CEG",.F.)
		CEG->CEG_STATUS := "1"
		MsUnlock()
	Else
		RecLock("CEG",.F.)
		CEG->CEG_STATUS := "0"
		MsUnlock()
	EndIf	  	    	
		
Else
	
	AADD(aLogErro,{"CEG_ID","000017","CEG", nRecno})//STR0017 - Registro já validado.
	
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Não apresento o alert quando utilizo o JOB para validar³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lJob
	VldECFLog(aLogErro)
EndIf

Return(aLogErro)

//---------------------------------------------------------------------
/*/{Protheus.doc} VerEcf50

Rotina para verificar se existem os campos utilizados no ECF layout 5.0

@Param

@Author Denis Souza
@Since 23/04/2019
@Version 1.0
/*/
//---------------------------------------------------------------------
Function EcfBlP50()

	Local aGetArea := GetArea()
	Local lEcf50  := .F.

	If AliasIndic("CEH") .And. Empty(Select("CEH"))
		DbSelectArea("CEH")
		CAE->(DbSetOrder(1))
	endif

	If TafColumnPos( "CEH_VLRTD" ) .And. TafColumnPos( "CEH_VLRTC" )
		lEcf50 := .T.
	endif

	RestArea(aGetArea)

Return lEcf50