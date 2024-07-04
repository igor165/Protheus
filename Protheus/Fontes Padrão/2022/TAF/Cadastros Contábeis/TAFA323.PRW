#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA323.CH"

//------------------------------------------------------------------------
/*/{Protheus.doc} TAFA323
Cadastro MVC - Identificação dos períodos e formas de apuração do 
IRPJ e da CSLL das empresas tributadas pelo lucro arbitrado.

@author Paulo Sérgio V.B. Santana
@since 19/05/2014
@version 1.0
/*/
//------------------------------------------------------------------------
Function TAFA323()
Local	oBrw	:=	FWmBrowse():New()
Local cTitulo := STR0001
dbSelectArea("CEJ")
CEJ->(DbSetOrder(2))
oBrw:SetDescription(cTitulo) 
						  
oBrw:SetAlias( 'CEJ')
oBrw:SetMenuDef( 'TAFA323' )
oBrw:SetCacheView(.F.)
oBrw:Activate()


Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Paulo Sérgio V.B. Santana
@since 19/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()  
Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf323Vld" , "2" } )

lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If lMenuDif
	ADD OPTION aRotina Title "Visualizar" Action 'VIEWDEF.TAFA323' OPERATION 2 ACCESS 0
Else
	aRotina	:=	xFunMnuTAF( "TAFA323" , , aFuncao)
EndIf                                     

Return( aRotina )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Paulo Sérgio V.B. Santana
@since 19/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()  

Local  oStruCEJ := FWFormStruct( 1, 'CEJ' )
Local  oStruCEK := FWFormStruct( 1, 'CEK' )
Local  cRecEcf   := ""
Local  oModel    :=  MpFormModel():New("TAFA323" , , , {|oModel| SaveModel( oModel ) } )

lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )
	
If lVldModel
	oStruCEJ:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel }) 		
EndIf

oStruCEK:SetProperty( 'CEK_REGECF' , MODEL_FIELD_INIT ,{| oModel | Iif(oModel:Getid()=='MODEL_CEKa',"01",Iif(oModel:Getid()=='MODEL_CEKb',"02", Iif(oModel:Getid()=='MODEL_CEKc','03','04')))})


oStruCEK:SetProperty( "CEK_CODCTA", MODEL_FIELD_VALID , { |oModel|  Iif( oModel:GetId() == "MODEL_CEKa", xFunVldCmp( "CH6", 2, PadR( "T120", TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CEK_CODCTA" )),;
                                                                    Iif( oModel:GetId() == "MODEL_CEKb", xFunVldCmp( "CH6", 2, PadR( "T150", TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CEK_CODCTA" )),;
                                                                    Iif( oModel:GetId() == "MODEL_CEKc", xFunVldCmp( "CH6", 2, PadR( "T170", TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CEK_CODCTA" )),xFunVldCmp( "CH6", 2, PadR( "T181", TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CEK_CODCTA" )))))})
                                                                    
oStruCEK:AddTrigger( "CEK_CODCTA", "CEK_DCODCT",, { |oModel|  Iif( oModel:GetId() == "MODEL_CEKa", Posicione( "CH6", 2, xFilial( "CH6" ) + PadR( "T120", TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CEK_CODCTA" ), "CH6_DESCRI" ),;
                                                              Iif( oModel:GetId() == "MODEL_CEKb", Posicione( "CH6", 2, xFilial( "CH6" ) + PadR( "T150", TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CEK_CODCTA" ), "CH6_DESCRI" ),;
                                                              Iif( oModel:GetId() == "MODEL_CEKc", Posicione( "CH6", 2, xFilial( "CH6" ) + PadR( "T170", TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CEK_CODCTA" ), "CH6_DESCRI" ), Posicione( "CH6", 2, xFilial( "CH6" ) + PadR( "T181", TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CEK_CODCTA" ), "CH6_DESCRI" ))))})

oStruCEK:AddTrigger( "CEK_CODCTA", "CEK_IDCODC",, { |oModel|  Iif( oModel:GetId() == "MODEL_CEKa", Posicione( "CH6", 2, xFilial( "CH6" ) + PadR( "T120", TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CEK_CODCTA" ), "CH6_ID" ),;
                                                              Iif( oModel:GetId() == "MODEL_CEKb", Posicione( "CH6", 2, xFilial( "CH6" ) + PadR( "T150", TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CEK_CODCTA" ), "CH6_ID" ),;
                                                              Iif( oModel:GetId() == "MODEL_CEKc", Posicione( "CH6", 2, xFilial( "CH6" ) + PadR( "T170", TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CEK_CODCTA" ), "CH6_ID" ), Posicione( "CH6", 2, xFilial( "CH6" ) + PadR( "T181", TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CEK_CODCTA" ), "CH6_ID" ))))})

oModel:AddFields( 'MODEL_CEJ', /*cOwner*/, oStruCEJ )
oModel:GetModel( 'MODEL_CEJ' ):SetPrimaryKey( { 'CEJ_DTINI','CEJ_DTFIN','CEJ_IDPERA' } )
	
oModel:AddGrid('MODEL_CEKa', 'MODEL_CEJ',oStruCEK )
oModel:GetModel('MODEL_CEKa'):SetOptional( .T. )
oModel:GetModel('MODEL_CEKa'):SetLoadFilter( { { 'CEK_REGECF', "'01'" } } )
oModel:GetModel('MODEL_CEKa'):SetUniqueLine( { "CEK_REGECF","CEK_IDCODC" } )                                                                                                                                                                         

oModel:AddGrid('MODEL_CEKb', 'MODEL_CEJ',oStruCEK )
oModel:GetModel('MODEL_CEKb'):SetOptional( .T. )
oModel:GetModel('MODEL_CEKb'):SetLoadFilter( { { 'CEK_REGECF', "'02'" } } )
oModel:GetModel('MODEL_CEKb'):SetUniqueLine( { "CEK_REGECF","CEK_IDCODC" } )        

oModel:AddGrid('MODEL_CEKc', 'MODEL_CEJ',oStruCEK )
oModel:GetModel('MODEL_CEKc'):SetOptional( .T. )
oModel:GetModel('MODEL_CEKc'):SetLoadFilter( { { 'CEK_REGECF', "'03'" } } )
oModel:GetModel('MODEL_CEKc'):SetUniqueLine( { "CEK_REGECF","CEK_IDCODC" } )        

oModel:AddGrid('MODEL_CEKd', 'MODEL_CEJ',oStruCEK )
oModel:GetModel('MODEL_CEKd'):SetOptional( .T. )
oModel:GetModel('MODEL_CEKd'):SetLoadFilter( { { 'CEK_REGECF', "'04'" } } )
oModel:GetModel('MODEL_CEKd'):SetUniqueLine( { "CEK_REGECF","CEK_IDCODC" } )        

//Relacionamento das Grids
oModel:SetRelation( 'MODEL_CEKa' , { { 'CEK_FILIAL', 'xFilial( "CEK" )' } , {'CEK_ID','CEJ_ID'}}, CEK->( IndexKey( 1 ) ) )                                                                                       
oModel:SetRelation( 'MODEL_CEKb' , { { 'CEK_FILIAL', 'xFilial( "CEK" )' } , {'CEK_ID','CEJ_ID'}}, CEK->( IndexKey( 1 ) ) )    
oModel:SetRelation( 'MODEL_CEKc' , { { 'CEK_FILIAL', 'xFilial( "CEK" )' } , {'CEK_ID','CEJ_ID'}}, CEK->( IndexKey( 1 ) ) )    
oModel:SetRelation( 'MODEL_CEKd' , { { 'CEK_FILIAL', 'xFilial( "CEK" )' } , {'CEK_ID','CEJ_ID'}}, CEK->( IndexKey( 1 ) ) )                                                                                     
Return ( oModel )

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Paulo Sérgio V.B. Santana
@since 19/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel 	  := FWLoadModel( 'TAFA323' )
Local oStruCEJ  := FWFormStruct( 2, 'CEJ' )

Local oStruCEKa := FWFormStruct( 2, 'CEK' )
Local oStruCEKb := FWFormStruct( 2, 'CEK' )
Local oStruCEKc := FWFormStruct( 2, 'CEK' )
Local oStruCEKd := FWFormStruct( 2, 'CEK' )

Local oView 	  := FWFormView():New()

oStruCEJ:RemoveField("CEJ_IDPERA")
oStruCEJ:RemoveField("CEJ_ID")

oStruCEKa:RemoveField("CEK_REGECF")
oStruCEKb:RemoveField("CEK_REGECF")
oStruCEKc:RemoveField("CEK_REGECF")
oStruCEKd:RemoveField("CEK_REGECF")
oStruCEKa:RemoveField("CEK_IDCODC")
oStruCEKb:RemoveField("CEK_IDCODC")
oStruCEKc:RemoveField("CEK_IDCODC")
oStruCEKd:RemoveField("CEK_IDCODC")

If TAFColumnPos( "CEK_ORIGEM" )
	oStruCEKa:RemoveField( "CEK_ORIGEM" )
	oStruCEKb:RemoveField( "CEK_ORIGEM" )
	oStruCEKc:RemoveField( "CEK_ORIGEM" )
	oStruCEKd:RemoveField( "CEK_ORIGEM" )
EndIf

oStruCEKa:SetProperty( "CEK_CODCTA", MVC_VIEW_LOOKUP, "CH6A" )
oStruCEKb:SetProperty( "CEK_CODCTA", MVC_VIEW_LOOKUP, "CH6B" )
oStruCEKc:SetProperty( "CEK_CODCTA", MVC_VIEW_LOOKUP, "CH6C" )
oStruCEKd:SetProperty( "CEK_CODCTA", MVC_VIEW_LOOKUP, "CH6D" )

oView:SetModel( oModel )
oView:AddField( 'VIEW_CEJ', oStruCEJ, 'MODEL_CEJ' )

oView:AddGrid( 'VIEW_CEKa', oStruCEKa, 'MODEL_CEKa' )      
oView:AddGrid( 'VIEW_CEKb', oStruCEKb, 'MODEL_CEKb' )      
oView:AddGrid( 'VIEW_CEKc', oStruCEKc, 'MODEL_CEKc' )      
oView:AddGrid( 'VIEW_CEKd', oStruCEKd, 'MODEL_CEKd' )      

 
oView:EnableTitleView( 'VIEW_CEJ') 
   
oView:CreateHorizontalBox( 'FIELDSCEJ', 30 )
oView:CreateHorizontalBox( 'PANFOLDER1', 70 )

oView:CreateFolder( 'FOLDER1', 'PANFOLDER1' )
    
oView:SetOwnerView( 'VIEW_CEJ' , 'FIELDSCEJ')

//ABA1
oView:CreateHorizontalBox( 'PAINEL_FOLDER1' , 100,,, 'FOLDER1', 'F1ABA1' )

oView:AddSheet( 'FOLDER1', 'ABA01',STR0002)//Apuração da Base de Cálculo do IRPJ com Base no Lucro Arbitrado
oView:CreateHorizontalBox( 'AGRIDCEKA', 100,,, 'FOLDER1',  'ABA01' )
oView:SetOwnerView( 'VIEW_CEKa', 'AGRIDCEKA' )   

oView:AddSheet( 'FOLDER1', 'ABA02', STR0003 )//Cálculo do IRPJ com Base no Lucro Arbitrado 
oView:CreateHorizontalBox( 'AGRIDCEKB', 100,,, 'FOLDER1',  'ABA02')         
oView:SetOwnerView( 'VIEW_CEKb', 'AGRIDCEKB' )   
                                                                                                        
oView:AddSheet( 'FOLDER1', 'ABA03', STR0004)//Apuração da Base de Cálculo da CSLL com Base no Lucro Arbitrado
oView:CreateHorizontalBox( 'AGRIDCEKC', 100,,, 'FOLDER1',  'ABA03')
oView:SetOwnerView( 'VIEW_CEKc', 'AGRIDCEKC' )   

oView:AddSheet( 'FOLDER1', 'ABA04', STR0005)//Cálculo da CSLL com Base no Lucro Arbitrado
oView:CreateHorizontalBox( 'AGRIDCEKD', 100,,, 'FOLDER1',  'ABA04' )
oView:SetOwnerView( 'VIEW_CEKd', 'AGRIDCEKD' )   
 
Return oView        


//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@Param  oModel -> Modelo de dados

@Return .T.

@Author Paulo Sérgio Santana
@Since 24/09/2013
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

Local 	nOperation 	:= 	oModel:GetOperation()  

Begin Transaction

		If nOperation == MODEL_OPERATION_UPDATE
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Funcao responsavel por setar o Status do registro para Branco³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			TAFAltStat( 'CEJ', " " )   		
		
		Endif
		
		FwFormCommit( oModel )
	
End Transaction

Return .T.
                  
//-------------------------------------------------------------------
/*/ {Protheus.doc} Taf322Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacos 

@Param
cAlias -> Alias da Tabela
nRecno -> Recno do Registro corrente
nOpc   -> Operacao a ser realizada
lJob   -> Job / Aplicacao

@return ( T. )

@author Paulo Santana
@since 14/05/2014
@version 1.0
/*/                                                                                                                                          

//-------------------------------------------------------------------
Function Taf323Vld( cAlias, nRecno, nOpc, lJob )
Local cChave  := ""
Local aLogErro:= {}
Default lJob  := .F.

If !CEJ->CEJ_STATUS $ ( " |1" )
	AADD(aLogErro,{ "CEJ_ID", "000017", "CEJ", nRecno }) //Registro já validado
Else
	
	//Valida a data de saldo inicial
	If Empty(CEJ->CEJ_DTINI)
		Aadd( aLogErro, {"CEJ_DTINI", "000003", "CEJ", nRecno}) //STR0003 - Data inconsistente ou vazia.	
	EndIf
	
	//Valida a data de saldo final
	If Empty(CEJ->CEJ_DTFIN)
		Aadd( aLogErro, {"CEJ_DTFIN", "000003", "CEJ", nRecno}) //STR0003 - Data inconsistente ou vazia.
	EndIf  
		
	//Valida o Periodo de apuração
	If Empty(CEJ->CEJ_IDPERA)
		Aadd( aLogErro, {"CEJ_PERAPU", "000001","CEJ", nRecno}) //STR0001 - Campo Inconsistente ou Vazio
    Else 
    	//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := CEJ->CEJ_IDPERA
		xVldECFTab("CAH",cChave,1,,@aLogErro,{"CEJ","CEJ_PERAPU",nRecno })
	EndIf
		
	//Valida as Datas de Inicio e Final
	If ! Empty(CEJ->CEJ_DTINI) .And. ! Empty(CEJ->CEJ_DTFIN)
		If CEJ->CEJ_DTFIN < CEJ->CEJ_DTINI 
			Aadd( aLogErro, {"CEJ_DTFIN", "000032", "CEJ", nRecno}) //STR0032 - A data de saldo final dever ser maior ou igual a data de saldo inicial.
		EndIf
	EndIf
	
	//VALIDA_PERIODO
	//xVldECFReg( cAlias,"VALIDA_PERIODO_TRIMESTRAL", @aLogErro,{CEJ->CEJ_DTINI,CEJ->CEJ_DTFIN,CEJ->CEJ_IDPERA,"A"})

	//ÚÄÄÄÄÄÄÄÄÄÄ¿
	//³INICIO CEK³
	//ÀÄÄÄÄÄÄÄÄÄÄÙ
	CEK->( DBSetOrder(1) )
	
	cCEKKey := CEJ->CEJ_ID
	If CEK->( MsSeek( xFilial("CEK") + cCEKKey ) )

		Do While !CEK->( Eof() ) .And. cCEKKey == CEK->CEK_ID						
			//------------------
			// Consultas padrão
			//------------------			
			If Empty(CEK->CEK_IDCODC)                                            
				Aadd(aLogErro,{"CEK_CODCTA","000001","CEK",nRecno}) //STR0001 - "Campo inconsistente ou vazio." 
			Else
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := CEK->CEK_IDCODC
				xVldECFTab("CH6",cChave,1,,@aLogErro,{ "CEK","CEK_CODCTA", nRecno })
			EndIf		

			CEK->( DbSkip() )

		EndDo
		
	EndIf
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ATUALIZO O STATUS DO REGISTRO³
	//³1 = Registro Invalido        ³
	//³0 = Registro Valido          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len( aLogErro ) > 0
		RecLock( "CEJ", .F. )
		CEJ->CEJ_STATUS := "1"
		MsUnlock()
	Else
		RecLock( "CEJ", .F. )
		CEJ->CEJ_STATUS := "0"
		MsUnlock()
	EndIf
	
EndIf

	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Não apresento o alert quando utilizo o JOB para validar³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lJob
	VldECFLog( aLogErro )
EndIf	

Return(aLogErro)