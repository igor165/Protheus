#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"    
#INCLUDE "TAFA093.CH"                     

STATIC aCmpsAlts	:=	{}

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA093
Cadastro MVC - Movimentos do ECF

@author Rodrigo Aguilar
@since 28/08/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA093
Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //"Movimentos do ECF"
oBrw:SetAlias( 'C6F' )
oBrw:SetMenuDef( 'TAFA093' )
oBrw:SetCacheView(.F.)
oBrw:Activate()  

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@return aRotina - Array com as opcoes de menu

@author Rodrigo Aguilar
@since 28/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf093Vld" , "2" } )

lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If lMenuDif
	ADD OPTION aRotina Title "Visualizar" Action 'VIEWDEF.TAFA093' OPERATION 2 ACCESS 0
Else
	aRotina	:=	xFunMnuTAF( "TAFA093" , , aFuncao)
EndIf                                     

Return( aRotina )  

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Rodrigo Aguilar
@since 28/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC6F 	:= 	FWFormStruct( 1, 'C6F' )
Local oStruC6G 	:= 	FWFormStruct( 1, 'C6G' )
Local oStruC6H 	:= 	FWFormStruct( 1, 'C6H' )
Local oStruC3O 	:= 	FWFormStruct( 1, 'C3O' )
Local oStruC6I 	:= 	FWFormStruct( 1, 'C6I' )
Local oStruC6J 	:= 	FWFormStruct( 1, 'C6J' )
Local oStruC6K 	:= 	FWFormStruct( 1, 'C6K' )
Local oStruC6L 	:= 	FWFormStruct( 1, 'C6L' )        

Local oStruC7C 	:= 	FWFormStruct( 1, 'C7C' )  
Local oStruC7D 	:= 	FWFormStruct( 1, 'C7D' ) 
Local oStruC7E	:= 	FWFormStruct( 1, 'C7E' ) 

Local oStruC7F 	:= 	FWFormStruct( 1, 'C7F' )                                                                                                                                                                                                                                                              
Local oStruC7G	:= 	FWFormStruct( 1, 'C7G' ) 
                                                                                                                                                                                                                                                                                                         
Local oModel 	:= 	MPFormModel():New( 'TAFA093' ,,{ |oModel| ValidModel( oModel ) },{ |oModel| SaveModel( oModel ) } )

// ---------------------------------------------------------------------------------------------
// Parametro que define se informacaoes individualizadas deve ser obrigatorio ou opcional        
// DEFAULT .T. (sempre obrigatório) - Criado para atender marcas - DATASUL 
// ---------------------------------------------------------------------------------------------
Local lMovIndObg	:= SuperGetMv ("MV_TAFIOBG",.F.,.T.) 


aCmpsAlts	:=	{}
     
oModel:AddFields('MODEL_C6F', /*cOwner*/, oStruC6F )

oModel:AddGrid('MODEL_C6G', 'MODEL_C6F', oStruC6G)  
oModel:GetModel( 'MODEL_C6G' ):SetUniqueLine( { 'C6G_DTMOV' } )

oModel:AddGrid('MODEL_C6H', 'MODEL_C6G', oStruC6H)   
oModel:GetModel( 'MODEL_C6H' ):SetUniqueLine( { 'C6H_CDTOT' } )

oModel:AddGrid('MODEL_C3O', 'MODEL_C6H', oStruC3O)   
oModel:GetModel( 'MODEL_C3O' ):SetUniqueLine( { 'C3O_CODITE' } )
oModel:GetModel( 'MODEL_C3O' ):SetOptional( .T. )
                                                  
oModel:AddGrid('MODEL_C6I', 'MODEL_C6G', oStruC6I)   
oModel:GetModel( 'MODEL_C6I' ):SetUniqueLine( { 'C6I_CMOD', 'C6I_CODSIT' , 'C6I_NUMDOC' , 'C6I_DTEMIS' } )    
oModel:GetModel( 'MODEL_C6I' ):SetOptional(  !lMovIndObg )

oModel:AddGrid('MODEL_C6J', 'MODEL_C6I', oStruC6J)   
oModel:GetModel( 'MODEL_C6J' ):SetUniqueLine( { 'C6J_ITEMNF', 'C6J_IT' } )   
oModel:GetModel( 'MODEL_C6J' ):SetOptional( !lMovIndObg )

oModel:AddGrid('MODEL_C6K', 'MODEL_C6J', oStruC6K)   
oModel:GetModel( 'MODEL_C6K' ):SetUniqueLine( { 'C6K_CODTRI' , 'C6K_CST' } )     
oModel:GetModel( 'MODEL_C6K' ):SetOptional(  !lMovIndObg )

oModel:AddGrid('MODEL_C6L', 'MODEL_C6F', oStruC6L)   
oModel:GetModel( 'MODEL_C6L' ):SetUniqueLine( { 'C6L_IDPROC' } )
oModel:GetModel( 'MODEL_C6L' ):SetOptional( .T. )    

oModel:AddGrid('MODEL_C7C', 'MODEL_C6G', oStruC7C)   
oModel:GetModel( 'MODEL_C7C' ):SetUniqueLine( { 'C7C_CST' } )
oModel:GetModel( 'MODEL_C7C' ):SetOptional( .T. )   

oModel:AddGrid('MODEL_C7D', 'MODEL_C6G', oStruC7D)   
oModel:GetModel( 'MODEL_C7D' ):SetUniqueLine( { 'C7D_CST' } )
oModel:GetModel( 'MODEL_C7D' ):SetOptional( .T. )

oModel:AddGrid('MODEL_C7E', 'MODEL_C6G', oStruC7E)   
oModel:GetModel( 'MODEL_C7E' ):SetUniqueLine( { 'C7E_CST' , 'C7E_CFOP' , 'C7E_ALIQ' } )
oModel:GetModel( 'MODEL_C7E' ):SetOptional( .T. )

oModel:AddGrid('MODEL_C7F', 'MODEL_C6H', oStruC7F)                                                                                                                                                                                                                                                        
oModel:GetModel( 'MODEL_C7F' ):SetUniqueLine( { 'C7F_UF' , 'C7F_CODMUN' } )  
oModel:GetModel( 'MODEL_C7F' ):SetOptional( .T. )

oModel:AddGrid('MODEL_C7G', 'MODEL_C6G', oStruC7G)                                                                                                                                                                                                                                                        
oModel:GetModel( 'MODEL_C7G' ):SetUniqueLine( { 'C7G_CSTICM'} ) // , 'C7G_CFOP ' , 'C7G_ ALQICM' } )                                                                                                                                                                                                                   
oModel:GetModel( 'MODEL_C7G' ):SetOptional( .T. )

oModel:SetRelation( 'MODEL_C6G' , { { 'C6G_FILIAL' , 'xFilial( "C6G" )' } , { 'C6G_ID' , 'C6F_ID' } } , C6G->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_C6H' , { { 'C6H_FILIAL' , 'xFilial( "C6H" )' } , { 'C6H_ID' , 'C6F_ID' }, {'C6H_DTMOV' , 'C6G_DTMOV'}} , C6H->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_C3O' , { { 'C3O_FILIAL' , 'xFilial( "C3O" )' } , { 'C3O_ID' , 'C6F_ID' }, {'C3O_DTMOV' , 'C6G_DTMOV'} , {'C3O_CDTOT' , 'C6H_CDTOT'}} , C3O->( IndexKey( 1 ) ) )
 
oModel:SetRelation( 'MODEL_C6I' , { { 'C6I_FILIAL' , 'xFilial( "C6I" )' } , { 'C6I_ID' , 'C6F_ID' }, {'C6I_DTMOV' , 'C6G_DTMOV'}} , C6I->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_C6J' , { { 'C6J_FILIAL' , 'xFilial( "C6J" )' } , { 'C6J_ID' , 'C6F_ID' }, {'C6J_DTMOV' , 'C6G_DTMOV'}, {'C6J_CMOD' , 'C6I_CMOD'}, {'C6J_CODSIT' , 'C6I_CODSIT'}, {'C6J_NUMDOC' , 'C6I_NUMDOC'}, {'C6J_DTEMIS', 'C6I_DTEMIS'}} , C6J->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_C6K' , { { 'C6K_FILIAL' , 'xFilial( "C6K" )' } , { 'C6K_ID' , 'C6F_ID' }, {'C6K_DTMOV' , 'C6G_DTMOV'}, {'C6K_CMOD' , 'C6I_CMOD'}, {'C6K_CODSIT' , 'C6I_CODSIT'}, {'C6K_NUMDOC' , 'C6I_NUMDOC'}, {'C6K_DTEMIS', 'C6I_DTEMIS'}, {'C6K_ITEMNF', 'C6J_ITEMNF' }, {'C6K_IT', 'C6J_IT' }} , C6K->( IndexKey( 1 ) ) )

oModel:SetRelation( 'MODEL_C6L' , { { 'C6L_FILIAL' , 'xFilial( "C6L" )' } , { 'C6L_ID' , 'C6F_ID' } } , C6L->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_C7C' , { { 'C7C_FILIAL' , 'xFilial( "C7C" )' } , { 'C7C_ID' , 'C6F_ID' }, {'C7C_DTMOV' , 'C6G_DTMOV'}} , C7C->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_C7D' , { { 'C7D_FILIAL' , 'xFilial( "C7D" )' } , { 'C7D_ID' , 'C6F_ID' }, {'C7D_DTMOV' , 'C6G_DTMOV'}} , C7D->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_C7E' , { { 'C7E_FILIAL' , 'xFilial( "C7E" )' } , { 'C7E_ID' , 'C6F_ID' }, {'C7E_DTMOV' , 'C6G_DTMOV'}} , C7E->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_C7F' , { { 'C7F_FILIAL' , 'xFilial( "C7F" )' } , { 'C7F_ID' , 'C6F_ID' }, {'C7F_DTMOV' , 'C6G_DTMOV'}, {'C7F_CDTOT' , 'C6H_CDTOT'}} , C7F->( IndexKey( 1 ) ) )                                                                                                                                              
oModel:SetRelation( 'MODEL_C7G' , { { 'C7G_FILIAL' , 'xFilial( "C7G" )' } , { 'C7G_ID' , 'C6F_ID' }, {'C7G_DTMOV' , 'C6G_DTMOV'}} , C7G->( IndexKey( 1 ) ) )                                                                                                                                              

oModel:AddRules( 'MODEL_C6K', 'C6K_CODTRI', 'MODEL_C6K', 'C6K_CST', 2 )
oModel:AddRules( 'MODEL_C6K', 'C6K_CODTRI', 'MODEL_C6K', 'C6K_MODBC', 2 )   

oModel:GetModel( "MODEL_C6F" ):SetPrimaryKey( { "C6F_CODECF" } )

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Rodrigo Aguilar
@since 28/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel 	:= 	FWLoadModel( 'TAFA093' )
Local oStruC6F 	:= 	FWFormStruct( 2, 'C6F' ) //Cadastro de Equipamento ECF
Local oStruC6G 	:= 	FWFormStruct( 2, 'C6G' ) //Redução Z
Local oStruC6H 	:= 	FWFormStruct( 2, 'C6H' ) //Tot.Parc.Redução Z
Local oStruC3O 	:= 	FWFormStruct( 2, 'C3O' ) //Itens do Resumo diário
Local oStruC6I 	:= 	FWFormStruct( 2, 'C6I' ) //Doc.Fiscal Emitido ECF
Local oStruC6J 	:= 	FWFormStruct( 2, 'C6J' ) //Itens Doc.Fiscal Emitido ECF
Local oStruC6K 	:= 	FWFormStruct( 2, 'C6K' ) //Tp. Itens Doc.Fiscal Emit. ECF
Local oStruC6L 	:= 	FWFormStruct( 2, 'C6L' ) //Processo Referenciado
Local oStruC7C 	:= 	FWFormStruct( 2, 'C7C' )//"Resumo Diário do ECF por PIS/COFINS"
Local oStruC7D 	:= 	FWFormStruct( 2, 'C7D' )//"Resumo Diário do ECF por PIS/COFINS"
Local oStruC7E	:= 	FWFormStruct( 2, 'C7E' ) //"Resumo Diário do ECF por ICMS"
Local oStruC7F 	:= 	FWFormStruct( 2, 'C7F' ) //Complemento dos Documentos Informados
Local oStruC7G	:= 	FWFormStruct( 2, 'C7G' ) //Registro Analitico do Movimento
Local oView 	:= 	FWFormView():New()       

oStruC6K:SetProperty( 'C6K_CST'   , MVC_VIEW_LOOKUP  , { || XFUNChgF3( "C6K_CODTRI" ) } )  
oStruC6K:SetProperty( 'C6K_MODBC' , MVC_VIEW_LOOKUP  , { || XFUNChgF3( "C6K_CODTRI",,"MBC" ) } )       
oStruC7C:SetProperty( 'C7C_CST'   , MVC_VIEW_LOOKUP  , { ||  'C17'} ) 
oStruC7D:SetProperty( 'C7D_CST'   , MVC_VIEW_LOOKUP  , { ||  'C17'} )
oStruC7E:SetProperty( 'C7E_CST'   , MVC_VIEW_LOOKUP  , "C14" )
oStruC7G:SetProperty( 'C7G_CSTICM', MVC_VIEW_LOOKUP  , "C14" )

oView:SetModel( oModel )                                                                          

oView:AddField( 'VIEW_C6F', oStruC6F, 'MODEL_C6F' )  
oView:EnableTitleView( 'VIEW_C6F', STR0002 ) //"Cadastro de Equipamento ECF"

oView:AddGrid ( 'VIEW_C6G', oStruC6G, 'MODEL_C6G' )
oView:EnableTitleView( 'VIEW_C6G', STR0003 )//"Redução Z"

oView:AddGrid ( 'VIEW_C6H', oStruC6H, 'MODEL_C6H' )

oView:AddGrid ( 'VIEW_C3O', oStruC3O, 'MODEL_C3O' )
oView:EnableTitleView( 'VIEW_C3O', STR0011 )	//'Itens do Resumo de Movimento Diário'
  
oView:AddGrid ( 'VIEW_C6I', oStruC6I, 'MODEL_C6I' )
oView:EnableTitleView( 'VIEW_C6I', STR0004 ) //"Documento Fiscal Emitido por ECF"
	
oView:AddGrid ( 'VIEW_C6J', oStruC6J, 'MODEL_C6J' )
oView:EnableTitleView( 'VIEW_C6J', STR0005 ) //"Itens do Documento Fiscal Emitido por ECF"

oView:AddGrid ( 'VIEW_C6K', oStruC6K, 'MODEL_C6K' )
oView:EnableTitleView( 'VIEW_C6K', STR0006 ) //"Tributos referente aos Itens do Documento Fiscal"       

oView:AddGrid ( 'VIEW_C7C', oStruC7C, 'MODEL_C7C' )
oView:EnableTitleView( 'VIEW_C7C', STR0013 ) //"Resumo Diário do ECF por PIS"

oView:AddGrid ( 'VIEW_C7D', oStruC7D, 'MODEL_C7D' )
oView:EnableTitleView( 'VIEW_C7D', STR0014 ) //"Resumo Diário do ECF por COFINS"

oView:AddGrid ( 'VIEW_C7E', oStruC7E, 'MODEL_C7E' )
oView:EnableTitleView( 'VIEW_C7E', STR0015 ) //"Resumo Diário do ECF por ICMS"

oView:AddGrid ( 'VIEW_C7F', oStruC7F, 'MODEL_C7F' )                                  
oView:EnableTitleView( 'VIEW_C7F', STR0016 )	//"Complemento dos Documentos Informados"
                                                                                                                                                                                                                                                                                                          
oView:AddGrid ( 'VIEW_C7G', oStruC7G, 'MODEL_C7G' )                              
oView:EnableTitleView( 'VIEW_C7G', STR0017 ) //"Registro Analitico do Movimento"   

oView:AddGrid ( 'VIEW_C6L', oStruC6L, 'MODEL_C6L' )

oView:CreateHorizontalBox( 'FIELDSC6F', 10 )
oView:CreateHorizontalBox( 'FOLDERGERAL', 90 )

oView:CreateFolder( 'FOLDER1', 'FOLDERGERAL' )

oView:AddSheet( 'FOLDER1', 'ABA01', STR0007 ) //"Processos Referenciados do ECF"
oView:CreateHorizontalBox( 'GRIDC6L', 100,,, 'FOLDER1', 'ABA01' )

oView:AddSheet( 'FOLDER1', 'ABA02', STR0008 ) //"Movimentos do ECF"
oView:CreateHorizontalBox( 'GRIDC6G', 20,,, 'FOLDER1', 'ABA02' )  
oView:CreateHorizontalBox( 'TELAFOLDERS', 80,,, 'FOLDER1', 'ABA02' )

oView:CreateFolder( 'FOLDERS', 'TELAFOLDERS' )
oView:AddSheet( 'FOLDERS', 'ABA01', STR0009 ) //"Totalizadores Parciais da Redução Z"
oView:CreateHorizontalBox( 'FOLDERC6H', 30,,, 'FOLDERS', 'ABA01' )

oView:CreateHorizontalBox( 'PAINEL_FOLDERS_C3OC7F', 70,,, 'FOLDERS', 'ABA01' )
oView:CreateFolder( 'FOLDERS_C3OC7F', 'PAINEL_FOLDERS_C3OC7F' )

oView:AddSheet( 'FOLDERS_C3OC7F', 'ABA01', STR0011 )	//'Itens do Resumo de Movimento Diário'
oView:CreateVerticalBox  ( 'FOLDERC3O', 100,,, 'FOLDERS_C3OC7F', 'ABA01' )

oView:AddSheet( 'FOLDERS_C3OC7F', 'ABA02', STR0016 )	//'Complemento dos Documentos Informados'
oView:CreateVerticalBox  ( 'FOLDERC7F', 100,,, 'FOLDERS_C3OC7F', 'ABA02' )

oView:AddSheet( 'FOLDERS', 'ABA02', STR0010 ) //"Documentos Fiscais Emitidos"
oView:CreateHorizontalBox( 'FOLDERC6I', 030,,, 'FOLDERS', 'ABA02' )
oView:CreateHorizontalBox( 'FOLDERC6J', 040,,, 'FOLDERS', 'ABA02' )
oView:CreateHorizontalBox( 'FOLDERC6K', 030,,, 'FOLDERS', 'ABA02' ) 
                                                                                                                                          
oView:AddSheet( 'FOLDERS', 'ABA03', STR0012 ) //"Resumo Diário do ECF por PIS/COFINS"
oView:CreateVerticalBox  ( 'PAINEL_FOLDERS_ABA03', 100,,, 'FOLDERS', 'ABA03' )
oView:CreateFolder( 'PAINEL_FOLDERS_ABA03_FOLDERS', 'PAINEL_FOLDERS_ABA03' )

oView:AddSheet( 'PAINEL_FOLDERS_ABA03_FOLDERS', 'ABA01', 'Resumo Diário do ECF por PIS' )
oView:CreateHorizontalBox( 'FOLDERC7C', 100,,, 'PAINEL_FOLDERS_ABA03_FOLDERS', 'ABA01' ) 

oView:AddSheet( 'PAINEL_FOLDERS_ABA03_FOLDERS', 'ABA02', 'Resumo Diário do ECF por Cofins' )
oView:CreateHorizontalBox( 'FOLDERC7D', 100,,, 'PAINEL_FOLDERS_ABA03_FOLDERS', 'ABA02' ) 

oView:AddSheet( 'FOLDERS', 'ABA04', STR0015 ) //"Resumo Diário do ECF por ICMS"
oView:CreateHorizontalBox( 'FOLDERC7E', 100,,, 'FOLDERS', 'ABA04' ) 
                                                                                                                                                                                                                                                                                                          
oView:AddSheet( 'FOLDERS', 'ABA05', STR0017 ) //"Registro Analitico do Movimento"
oView:CreateHorizontalBox( 'FOLDERC7G', 100,,, 'FOLDERS', 'ABA05' )

oView:AddIncrementField( 'VIEW_C6J', 'C6J_ITEMNF' )    

oView:SetOwnerView( 'VIEW_C6F', 'FIELDSC6F' )
oView:SetOwnerView( 'VIEW_C6G', 'GRIDC6G' )
oView:SetOwnerView( 'VIEW_C6H', 'FOLDERC6H' )
oView:SetOwnerView( 'VIEW_C3O', 'FOLDERC3O' ) 

oView:SetOwnerView( 'VIEW_C6I', 'FOLDERC6I' )
oView:SetOwnerView( 'VIEW_C6J', 'FOLDERC6J' )
oView:SetOwnerView( 'VIEW_C6K', 'FOLDERC6K' )  
            
oView:SetOwnerView( 'VIEW_C7C', 'FOLDERC7C' )
oView:SetOwnerView( 'VIEW_C7D', 'FOLDERC7D' )    
oView:SetOwnerView( 'VIEW_C7E', 'FOLDERC7E' )
oView:SetOwnerView( 'VIEW_C7F', 'FOLDERC7F' ) 
oView:SetOwnerView( 'VIEW_C7G', 'FOLDERC7G' )                                                                                                                                                                                                                                                             
oView:SetOwnerView( 'VIEW_C6L', 'GRIDC6L' )


If TamSX3("C3O_CODITE")[1] == 36
	oStruC3O:RemoveField("C3O_CODITE")
	oStruC3O:SetProperty("C3O_ITEM", MVC_VIEW_ORDEM, "05")
EndIf

If TamSX3("C6J_IT")[1] == 36
	oStruC6J:RemoveField("C6J_IT")
	oStruC6J:SetProperty("C6J_ITEM", MVC_VIEW_ORDEM, "09")
EndIf

If TamSX3("C7C_IT")[1] == 36
	oStruC7C:RemoveField("C7C_IT")
	oStruC7C:SetProperty("C7C_ITEM", MVC_VIEW_ORDEM, "04")
EndIf

If TamSX3("C7D_IT")[1] == 36
	oStruC7D:RemoveField("C7D_IT")
	oStruC7D:SetProperty("C7D_ITEM", MVC_VIEW_ORDEM, "04")
EndIf
If TamSX3("C6J_CCONT")[1] == 36
	oStruC6J:RemoveField("C6J_CCONT")
	oStruC6J:SetProperty("C6J_CTACTB", MVC_VIEW_ORDEM, "22")		
	oStruC6J:SetProperty("C6J_DCCON",  MVC_VIEW_ORDEM, "23")
	oStruC6J:SetProperty("C6J_ORIGEM", MVC_VIEW_ORDEM, "24")
	oStruC6J:SetProperty("C6J_DORIGE", MVC_VIEW_ORDEM, "25")
EndIf

If TamSX3("C7C_CTA")[1] == 36
	oStruC7C:RemoveField("C7C_CTA")
	oStruC7C:SetProperty("C7C_CTACTB", 	MVC_VIEW_ORDEM, "11")		
	oStruC7C:SetProperty("C7C_DCTA", 	MVC_VIEW_ORDEM, "12")
	oStruC7C:SetProperty("C7C_VLITEM", 	MVC_VIEW_ORDEM, "13")
	oStruC7C:SetProperty("C7C_VLRBC", 	MVC_VIEW_ORDEM, "14")
	oStruC7C:SetProperty("C7C_ALIQ", 	MVC_VIEW_ORDEM, "15")
	oStruC7C:SetProperty("C7C_VL", 		MVC_VIEW_ORDEM, "16")
	oStruC7C:SetProperty("C7C_QTDBC", 	MVC_VIEW_ORDEM, "17")
	oStruC7C:SetProperty("C7C_ALQQTD", 	MVC_VIEW_ORDEM, "18")
EndIf

If TamSX3("C7D_CTA")[1] == 36
	oStruC7D:RemoveField("C7D_CTA")	
	oStruC7D:SetProperty("C7D_CTACTB", 	MVC_VIEW_ORDEM, "11")
	oStruC7D:SetProperty("C7D_DCTA", 	MVC_VIEW_ORDEM, "12")
	oStruC7D:SetProperty("C7D_VLITEM", 	MVC_VIEW_ORDEM, "13")
	oStruC7D:SetProperty("C7D_VLRBC", 	MVC_VIEW_ORDEM, "14")
	oStruC7D:SetProperty("C7D_ALIQ", 	MVC_VIEW_ORDEM, "15")
	oStruC7D:SetProperty("C7D_VL", 		MVC_VIEW_ORDEM, "16")
	oStruC7D:SetProperty("C7D_QTDBC", 	MVC_VIEW_ORDEM, "17")
	oStruC7D:SetProperty("C7D_ALQQTD", 	MVC_VIEW_ORDEM, "18")	
EndIf

Return oView
//-------------------------------------------------------------------
/*/{Protheus.doc} ValidModel
Funcao de valida da inclusao dos dados, chamada no final, no momento da gravacao do modelo

@param  oModel -> Modelo de dados
@return .T. ou  .F.

@author Gustavo G. Rueda
@since 01/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValidModel( oModel )
Local 	nOperation 	:= 	oModel:GetOperation()
Return XFUNReflex( nOperation , aCmpsAlts , 'TAFA093' )
//-------------------------------------------------------------------
/*/{Protheus.doc} A093LogAlt
Funcao utilizada para atualizar uma variavel STATIC tratada no SAVE no modelo.
	Tratamento passado por framework para podermos identificar os campos alterados
	no modelo para podermos exibir alguns alertas.

@param  Nil

@return Sempre .T.
                
@author Gustavo G. Rueda
@since 01/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function A093LogAlt()

If ValType( aCmpsAlts ) == "A" .And. aScan( aCmpsAlts , ReadVar() ) == 0
	aAdd( aCmpsAlts , ReadVar() )
EndIf

Return .T.                                                                               


//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo
                                                                                                                               
@param  oModel -> Modelo de dados
@return .T.

@author Paulo Sérgio V.B. Santana
@since 19/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )
Local 	nOperation 	:= 	oModel:GetOperation()  
Begin Transaction

	If nOperation == MODEL_OPERATION_UPDATE 
		TAFAltStat( 'C6F', " " ) //Limpa o Status do Registro, tornando possível nova validação.
	Endif          
	
	FwFormCommit( oModel )		
	
End Transaction


Return .T.                    

//-------------------------------------------------------------------
/*/{Protheus.doc} Taf093Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacões 

lJob - Informa se foi chamado por Job

@return .T.

@author Paulo V.B. Santana
@since 17/02/2014
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function Taf093Vld(cAlias,nRecno,nOpc,lJob)
Local aLogErro	:= {} 
Local cChave		:= ""           

Local nItemDocF	:= 0 // Totalizador do valor de Item de Documento Fiscal
Local nTotVlOp	:= 0   // Totalizador do Valor da Operação

Local cC6GKey		:= ""
Local cC6HKey		:= ""
Local cC3OKey		:= ""
Local cC6IKey		:= ""
Local cC6JKey		:= ""
Local cC6KKey		:= ""
Local cC6LKey		:= ""
Local cC7CKey		:= ""
Local cC7DKey		:= ""
Local cC7EKey		:= ""
Local cC7FKey		:= ""
Local cC7GKey		:= ""

Default lJob		:= .F.

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C6F->( Recno() )

If (C6F->C6F_STATUS $ (' 1'))  
		
	If Empty(C6F->C6F_CODECF)
		aAdd(aLogErro,{"C6F_CODECF","000010","C6F",nRecno}) //"Campo Inconsistente ou Vazio" 
	Else                                                                                                                                             
		cChave := C6F->C6F_CODECF
		xValRegTab("C0W",cChave,4,,@aLogErro,, { "C6F", "C6F_CODECF", nRecno } )
	EndIF			

	//ÚÄÄÄÄÄÄÄÄÄÄ¿
	//³INICIO C6G³
	//ÀÄÄÄÄÄÄÄÄÄÄÙ
	//Validação da Grid Redução Z																	   
	C6G->( DBSetOrder(1) )
	
	cC6GKey := C6F->C6F_ID
	If C6G->( MsSeek( xFilial("C6G") + cC6GKey ) )

		Do While !C6G->( Eof() ) .And. cC6GKey == C6G->C6G_ID

			//---------------------
			// Campos obrigatórios
			//---------------------
			// Validação de campos obrigatórios
			If Empty(C6G->C6G_DTMOV)
				aAdd(aLogErro,{"C6G_DTMOV","000010","C6G",nRecno}) //"Campo Inconsistente ou Vazio" 
			EndIf
		
			If Empty(C6G->C6G_PCREOP)
				aAdd(aLogErro,{"C6G_PCREOP","000010","C6G",nRecno}) //"Campo Inconsistente ou Vazio" 
			EndIf

			If Empty(C6G->C6G_PCREDZ)
				aAdd(aLogErro,{"C6G_PCREDZ","000010","C6G",nRecno}) //"Campo Inconsistente ou Vazio" 
			EndIf

			If Empty(C6G->C6G_NRCOPF)
				aAdd(aLogErro,{"C6G_NRCOPF","000010","C6G",nRecno}) //"Campo Inconsistente ou Vazio" 
			EndIf

			If Empty(C6G->C6G_VLGRTF)
				aAdd(aLogErro,{"C6G_VLGRTF","000010","C6G",nRecno}) //"Campo Inconsistente ou Vazio"
			EndIf

			If Empty(C6G->C6G_VLBRU)
				aAdd(aLogErro,{"C6G_VLBRU","000010","C6G",nRecno}) //"Campo Inconsistente ou Vazio" 
			EndIf

			If Empty(C6G->C6G_NRCOPI)
				aAdd(aLogErro,{"C6G_NRCOPI","000010","C6G",nRecno}) //"Campo Inconsistente ou Vazio" 
			EndIf

			If !(C6G->C6G_VLGRTF >= C6G->C6G_VLBRU)
				aAdd(aLogErro,{"C6G_VLGRTF","000507","C6F",nRecno}) //"o campo Vlr.Grd.TFin deve ser maior ou igual ao campo Vlr. Bruto, exceto se houver reinício de operação."  
			EndIf	                                

			//ÚÄÄÄÄÄÄÄÄÄÄ¿
			//³INICIO C7C³
			//ÀÄÄÄÄÄÄÄÄÄÄÙ
			//Resumo Diário do ECF por PIS             													   
			C7C->( DBSetOrder(1) )
			
			cC7CKey := C6G->C6G_ID+DtoS(C6G->C6G_DTMOV)
			If C7C->( MsSeek( xFilial("C7C") + cC7CKey ) )
		
				Do While !C7C->( Eof() ) .And. cC7CKey == C7C->C7C_ID+DToS(C7C->C7C_DTMOV)
		
					//---------------------
					// Campos obrigatórios
					//---------------------
				 	//Validação de campos obrigatórios
				 	If Empty(C7C->C7C_CST)
				 		aAdd(aLogErro,{"C7C->C7C_CST","000010","C7C",nRecno}) //"Campo Inconsistente ou Vazio"
				 	EndIf
				 	
				 	//Validação de consulta padrão
					If !Empty(C7C->C7C_IT)
						cChave := C7C->C7C_IT
						xValRegTab("C1L",cChave,3,,@aLogErro,, { "C6F", "C7C_IT", nRecno } )
					EndIf
				 	
					If !Empty(C7C->C7C_CFOP)
						cChave := C7C->C7C_CFOP
						xValRegTab("C0Y",cChave,3,,@aLogErro,, { "C6F", "C7C_CFOP", nRecno } )
					EndIf
				 	
					If !Empty(C7C->C7C_CTA)
						cChave := C7C->C7C_CTA
						xValRegTab("C1O",cChave,3,,@aLogErro,, { "C6F", "C7C_CTA", nRecno } )
					EndIf
					
					C7C->( DbSkip() )
				EndDo
			EndIf
			//ÚÄÄÄÄÄÄÄ¿
			//³FIM C7C³
			//ÀÄÄÄÄÄÄÄÙ

			//ÚÄÄÄÄÄÄÄÄÄÄ¿
			//³INICIO C7D³
			//ÀÄÄÄÄÄÄÄÄÄÄÙ
			//Resumo Diário do ECF por COFINS
			C7D->( DBSetOrder(1) )
			
			cC7DKey := C6G->C6G_ID+DtoS(C6G->C6G_DTMOV)
			If C7D->( MsSeek( xFilial("C7D") + cC7DKey ) )
		
				Do While !C7D->( Eof() ) .And. cC7DKey == C7D->C7D_ID+DToS(C7D->C7D_DTMOV)
				 	//Validação de campos obrigatórios
				 	If Empty(C7D->C7D_CST)
				 		aAdd(aLogErro,{"C7D->C7D_CST","000010","C7D",nRecno}) //"Campo Inconsistente ou Vazio"
				 	EndIf
				 	
				 	//Validação de consulta padrão
					If !Empty(C7D->C7D_IT)
						cChave := C7D->C7D_IT
						xValRegTab("C1L",cChave,3,,@aLogErro,, { "C6F", "C7D_IT", nRecno } )
					EndIf
				 	
					If !Empty(C7D->C7D_CFOP)
						cChave := C7D->C7D_CFOP
						xValRegTab("C0Y",cChave,3,,@aLogErro,, { "C6F", "C7D_CFOP", nRecno } )
					EndIf
				 	
					If !Empty(C7D->C7D_CTA)
						cChave := C7D->C7D_CTA
						xValRegTab("C1O",cChave,3,,@aLogErro,, { "C6F", "C7D_CTA", nRecno } )
					EndIf
					
					C7D->( DbSkip() )
				EndDo
			EndIf
			//ÚÄÄÄÄÄÄÄ¿
			//³FIM C7D³
			//ÀÄÄÄÄÄÄÄÙ

			//ÚÄÄÄÄÄÄÄÄÄÄ¿
			//³INICIO C7E³
			//ÀÄÄÄÄÄÄÄÄÄÄÙ
			//Resumo diario do ECF por ICMS             													   
			C7E->( DBSetOrder(1) )
			
			cC7EKey := C6G->C6G_ID+DtoS(C6G->C6G_DTMOV)
			If C7E->( MsSeek( xFilial("C7E") + cC7EKey ) )
		
				Do While !C7E->( Eof() ) .And. cC7EKey == C7E->C7E_ID+DToS(C7E->C7E_DTMOV)
					nTotVlOp+= C7E->C7E_VLOPR       // Calculo do Valor Total da Operação

				 	//Validação de campos obrigatórios
				 	If Empty(C7E->C7E_CST)
				 		aAdd(aLogErro,{"C7E->C7E_CST","000010","C7E",nRecno}) //"Campo Inconsistente ou Vazio"
				 	EndIf
				 	
				 	If Empty(C7E->C7E_CFOP)
				 		aAdd(aLogErro,{"C7E->C7E_CFOP","000010","C7E",nRecno}) //"Campo Inconsistente ou Vazio"
				 	EndIf
				 	
				 	If Empty(C7E->C7E_ALIQ)
				 		aAdd(aLogErro,{"C7E->C7E_ALIQ","000010","C7E",nRecno}) //"Campo Inconsistente ou Vazio"
				 	EndIf
				 	
				 	//Validação de consulta padrão
					If !Empty(C7E->C7E_CFOP)
						cChave := C7E->C7E_CFOP
						xValRegTab("C0Y",cChave,3,,@aLogErro,, { "C6F", "C7E_CFOP", nRecno } )
					EndIf

					If !Empty(C7E->C7E_CODOBS)
						cChave := C7E->C7E_CODOBS
						xValRegTab("C3R",cChave,3,,@aLogErro,, { "C6F", "C7E_CODOBS", nRecno } )
					EndIf
					
					C7E->( DbSkip() )
				EndDo
			EndIf
			//ÚÄÄÄÄÄÄÄ¿
			//³FIM C7E³
			//ÀÄÄÄÄÄÄÄÙ

			//ÚÄÄÄÄÄÄÄÄÄÄ¿
			//³INICIO C7G³
			//ÀÄÄÄÄÄÄÄÄÄÄÙ
			//Resumo Diário do ECF por COFINS
			C7G->( DBSetOrder(1) )
			
			cC7GKey := C6G->C6G_ID+DtoS(C6G->C6G_DTMOV)
			If C7G->( MsSeek( xFilial("C7G") + cC7GKey ) )
		
				Do While !C7G->( Eof() ) .And. cC7GKey == C7G->C7G_ID+DToS(C7G->C7G_DTMOV)
				 	//Validação de campos obrigatórios
				 	If Empty(C7G->C7G_CSTICM)
				 		aAdd(aLogErro,{"C7G->C7G_CSTICM","000010","C7G",nRecno}) //"Campo Inconsistente ou Vazio"
				 	EndIf
				 	
				 	//Validação de consulta padrão
					If !Empty(C7G->C7G_CFOP)
						cChave := C7G->C7G_CFOP
						xValRegTab("C0Y",cChave,3,,@aLogErro,, { "C6F", "C7G_CFOP", nRecno } )
					EndIf
				 	
					If !Empty(C7G->C7G_CODOBS)
						cChave := C7G->C7G_CODOBS
						xValRegTab("C3R",cChave,3,,@aLogErro,, { "C6F", "C7G_CODOBS", nRecno } )
					EndIf
					
					C7G->( DbSkip() )
				EndDo
			EndIf
			//ÚÄÄÄÄÄÄÄ¿
			//³FIM C7G³
			//ÀÄÄÄÄÄÄÄÙ
			
			//ÚÄÄÄÄÄÄÄÄÄÄ¿
			//³INICIO C6H³
			//ÀÄÄÄÄÄÄÄÄÄÄÙ
			//Validação da Grid Totalizadores parciais de Redução Z				   
			C6H->( DBSetOrder(1) )
			
			cC6HKey := C6G->C6G_ID+DToS(C6G->C6G_DTMOV)
			If C6H->( MsSeek( xFilial("C6H") + cC6HKey ) )
		
				Do While !C6H->( Eof() ) .And. cC6HKey == C6H->C6H_ID+DToS(C6H->C6H_DTMOV)
					If Empty(C6H->C6H_CDTOT)  
						aAdd(aLogErro,{"C6H_CDTOT","000010","C6F",nRecno}) //"Campo Inconsistente ou Vazio"  
					Else
						cChave := C6H->C6H_CDTOT
						xValRegTab("C6D",cChave,3,,@aLogErro,, { "C6F", "C6H_CDTOT", nRecno } )
					EndIf	                
					
					If !(C6H->C6H_VLRTOT==nTotVlOp)
						aAdd(aLogErro,{"C6H_VLRTOT","000505","C6F",nRecno}) //"O Valor do campo 'Vlr. Acum Tot.' deve ser a Soma do 'Vlr. Operação' "  
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄ¿
					//³INICIO C3O³
					//ÀÄÄÄÄÄÄÄÄÄÄÙ
					//Validação da Grid Itens do Resumo de Movimento Diário
					C3O->( DBSetOrder(1) )
					
					cC3OKey := C6H->(C6H_ID+DToS(C6H_DTMOV)+C6H_CDTOT)
					If C3O->( MsSeek( xFilial("C3O") + cC3OKey ) )
				
						Do While !C3O->( Eof() ) .And. cC3OKey == C3O->(C3O_ID+DToS(C3O_DTMOV)+C3O_CDTOT)
							//Validação dos campos obrigatórios
							If Empty(C3O->C3O_QTD)  
								aAdd(aLogErro,{"C3O_QTD","000010","C3O",nRecno}) //"Campo Inconsistente ou Vazio"  
							EndIf	                
		
							If Empty(C3O->C3O_CODITE)  
								aAdd(aLogErro,{"C3O_CODITE","000010","C3O",nRecno}) //"Campo Inconsistente ou Vazio"  
							EndIf	                
		
							If Empty(C3O->C3O_UNID)  
								aAdd(aLogErro,{"C3O_UNID","000010","C3O",nRecno}) //"Campo Inconsistente ou Vazio"  
							EndIf	                
		
							If Empty(C3O->C3O_VLITEM)  
								aAdd(aLogErro,{"C3O_VLITEM","000010","C3O",nRecno}) //"Campo Inconsistente ou Vazio"  
							EndIf
							
							//Validação de consulta padrão
							If !Empty(C3O->C3O_CODITE)
								cChave := C3O->C3O_CODITE
								xValRegTab("C1L",cChave,3,,@aLogErro,, { "C6F", "C3O_CODITE", nRecno }) //Verifica se conteúdo existe na tabela de consulta padrão
							EndIf
							
							If !Empty(C3O->C3O_UNID)
								cChave := C3O->C3O_UNID
								xValRegTab("C1J",cChave,3,,@aLogErro,, { "C6F", "C3O_UNID", nRecno })  //Verifica se conteúdo existe na tabela de consulta padrão
							EndIf
							
							C3O->( DbSkip() )
						EndDo
					EndIf
					//ÚÄÄÄÄÄÄÄ¿
					//³FIM C3O³
					//ÀÄÄÄÄÄÄÄÙ

					//ÚÄÄÄÄÄÄÄÄÄÄ¿
					//³INICIO C7F³
					//ÀÄÄÄÄÄÄÄÄÄÄÙ
					//Validação da Grid Itens do Resumo de Movimento Diário
					C7F->( DBSetOrder(1) )
					
					cC7FKey := C6H->(C6H_ID+DToS(C6H_DTMOV)+C6H_CDTOT)
					If C7F->( MsSeek( xFilial("C7F") + cC7FKey ) )
				
						Do While !C7F->( Eof() ) .And. cC7FKey == C7F->(C7F_ID+DToS(C7F_DTMOV)+C7F_CDTOT)
			   				//Validação de campos obrigatórios
							If Empty(C7F->C7F_UF)
								aAdd(aLogErro,{"C7F_UF","000010","C7F",nRecno}) //"Campo Inconsistente ou Vazio" 
							EndIf
			   				
							If Empty(C7F->C7F_CODMUN)
								aAdd(aLogErro,{"C7F_CODMUN","000010","C7F",nRecno}) //"Campo Inconsistente ou Vazio" 
							EndIf
			   				
							//Validação de consulta padrão
							If !Empty(C7F->C7F_UF)
								cChave := C7F->C7F_UF
								xValRegTab("C09",cChave,3,,@aLogErro,, { "C6F", "C7F_UF", nRecno } )
							EndIf
														
							If !Empty(C7F->C7F_CODMUN)
								cChave := C7F->C7F_CODMUN
								xValRegTab("C07",cChave,3,,@aLogErro,, { "C6F", "C7F_CODMUN", nRecno } )
							EndIf
														
							C7F->( DbSkip() )
						EndDo
					EndIf
					//ÚÄÄÄÄÄÄÄ¿
					//³FIM C7F³
					//ÀÄÄÄÄÄÄÄÙ

					C6H->( DbSkip() )
				EndDo
			EndIf
			//ÚÄÄÄÄÄÄÄ¿
			//³FIM C6H³
			//ÀÄÄÄÄÄÄÄÙ

			//ÚÄÄÄÄÄÄÄÄÄÄ¿
			//³INICIO C6I³
			//ÀÄÄÄÄÄÄÄÄÄÄÙ
			//Validação da Grid Totalizadores parciais de Redução Z				   
			C6I->( DBSetOrder(1) )
			
			cC6IKey := C6G->C6G_ID+DToS(C6G->C6G_DTMOV)
			If C6I->( MsSeek( xFilial("C6I") + cC6IKey ) )

				Do While !C6I->( Eof() ) .And. cC6IKey == C6I->C6I_ID+DToS(C6I->C6I_DTMOV)
	   				//Validação de campos obrigatórios
					If Empty(C6I->C6I_CMOD)
						aAdd(aLogErro,{"C6I_CMOD","000010","C6I",nRecno}) //"Campo Inconsistente ou Vazio" 
					EndIf
	   				
					If Empty(C6I->C6I_CODSIT)
						aAdd(aLogErro,{"C6I_CODSIT","000010","C6I",nRecno}) //"Campo Inconsistente ou Vazio" 
					EndIf
	   				
					If Empty(C6I->C6I_NUMDOC)
						aAdd(aLogErro,{"C6I_NUMDOC","000010","C6I",nRecno}) //"Campo Inconsistente ou Vazio" 
					EndIf
	   				
					If Empty(C6I->C6I_DTEMIS)
						aAdd(aLogErro,{"C6I_DTEMIS","000010","C6I",nRecno}) //"Campo Inconsistente ou Vazio" 
					EndIf
	   				
					If Empty(C6I->C6I_VLDOC)
						aAdd(aLogErro,{"C6I_VLDOC","000010","C6I",nRecno}) //"Campo Inconsistente ou Vazio" 
					EndIf
					
					//Validação de consulta padrão
					If !Empty(C6I->C6I_CMOD)
						cChave := C6I->C6I_CMOD
						xValRegTab("C01",cChave,3,,@aLogErro,, { "C6F", "C6I_CMOD", nRecno } )
					EndIf
	   				
					If !Empty(C6I->C6I_CODSIT)
						cChave := C6I->C6I_CODSIT
						xValRegTab("C02",cChave,3,,@aLogErro,, { "C6F", "C6I_CODSIT", nRecno } )
					EndIf
	   				
					If !Empty(C6I->C6I_CODOBS)
						cChave := C6I->C6I_CODOBS
						xValRegTab("C3R",cChave,3,,@aLogErro,, { "C6F", "C6I_CODOBS", nRecno } )
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄ¿
					//³INICIO C6J³
					//ÀÄÄÄÄÄÄÄÄÄÄÙ
					//Validação da Grid Itens do Resumo de Movimento Diário
					C6J->( DBSetOrder(1) )

					cC6JKey := C6I->(C6I_ID+DToS(C6I_DTMOV)+C6I_CMOD+C6I_CODSIT+C6I_NUMDOC+DToS(C6I_DTEMIS))
					If C6J->( MsSeek( xFilial("C6J") + cC6JKey ) )
				
						Do While !C6J->( Eof() ) .And. cC6JKey == C6J->(C6J_ID+DToS(C6J_DTMOV)+C6J_CMOD+C6J_CODSIT+C6J_NUMDOC+DToS(C6J_DTEMIS))
	   						//Validação de campos obrigatórios
	   						If Empty(C6J->C6J_IT)
								aAdd(aLogErro,{"C6J_IT","000010","C6J",nRecno}) //"Campo Inconsistente ou Vazio" 
	   						EndIf
	   						
	   						If Empty(C6J->C6J_UNDITE)
								aAdd(aLogErro,{"C6J_UNDITE","000010","C6J",nRecno}) //"Campo Inconsistente ou Vazio" 
	   						EndIf
	   						
	   						If Empty(C6J->C6J_CFOP)
								aAdd(aLogErro,{"C6J_CFOP","000010","C6J",nRecno}) //"Campo Inconsistente ou Vazio" 
	   						EndIf
	   						
	   						If Empty(C6J->C6J_QTDE)
								aAdd(aLogErro,{"C6J_QTDE","000010","C6J",nRecno}) //"Campo Inconsistente ou Vazio" 
	   						EndIf
	   						
	   						If Empty(C6J->C6J_VLRITE)
								aAdd(aLogErro,{"C6J_VLRITE","000010","C6J",nRecno}) //"Campo Inconsistente ou Vazio" 
	   						EndIf
	   						
	   						If Empty(C6J->C6J_ORIGEM)
								aAdd(aLogErro,{"C6J_ORIGEM","000010","C6J",nRecno}) //"Campo Inconsistente ou Vazio" 
	   						EndIf
	   						
							//Validação de consulta padrão
							If !Empty(C6J->C6J_IT)
								cChave := C6J->C6J_IT
								xValRegTab("C1L",cChave,3,,@aLogErro,, { "C6F", "C6J_IT", nRecno } )
							EndIf
	   						
							If !Empty(C6J->C6J_UNDITE)
								cChave := C6J->C6J_UNDITE
								xValRegTab("C1J",cChave,3,,@aLogErro,, { "C6F", "C6J_UNDITE", nRecno } )
							EndIf
	   						
							If !Empty(C6J->C6J_CFOP)
								cChave := C6J->C6J_CFOP
								xValRegTab("C0Y",cChave,3,,@aLogErro,, { "C6F", "C6J_CFOP", nRecno } )
							EndIf
	   						
							If !Empty(C6J->C6J_CCONT)
								cChave := C6J->C6J_CCONT
								xValRegTab("C1O",cChave,3,,@aLogErro,, { "C6F", "C6J_CCONT", nRecno } )
							EndIf
	   						
							If !Empty(C6J->C6J_ORIGEM)
								cChave := C6J->C6J_ORIGEM
								xValRegTab("C03",cChave,3,,@aLogErro,, { "C6F", "C6J_ORIGEM", nRecno } )
							EndIf

							//ÚÄÄÄÄÄÄÄÄÄÄ¿
							//³INICIO C6K³
							//ÀÄÄÄÄÄÄÄÄÄÄÙ
							//Validação da Grid Itens do Resumo de Movimento Diário
							C6K->( DBSetOrder(1) )
							
							cC6KKey := C6J->(C6J_ID+DToS(C6J_DTMOV)+C6J_CMOD+C6J_CODSIT+C6J_NUMDOC+DToS(C6J_DTEMIS)+C6J_ITEMNF+C6J_IT)
							If C6K->( MsSeek( xFilial("C6K") + cC6KKey ) )
						
								Do While !C6K->( Eof() ) .And. cC6KKey == C6K->(C6K_ID+DToS(C6K_DTMOV)+C6K_CMOD+C6K_CODSIT+C6K_NUMDOC+DToS(C6K_DTEMIS)+C6K_ITEMNF+C6K_IT)
	   								If Empty(C6K->C6K_CODTRI)  
										aAdd(aLogErro,{"C6K_CODTRI","000010","C6F",nRecno}) //"Campo Inconsistente ou Vazio"  
									Else
										cChave := C6K->C6K_CODTRI
										xValRegTab("C3S",cChave,3,,@aLogErro,, { "C6F", "C6K_CODTRI", nRecno } )
									EndIf   
									
									If !Empty(C6K->C6K_CENIPI)  
										cChave := C6K->C6K_CENIPI
										xValRegTab("C3T",cChave,3,,@aLogErro,, { "C6F","C6K_CENIPI",nRecno } )
									EndIf
									
									C6K->( DbSkip() )
								EndDo
							EndIf
							//ÚÄÄÄÄÄÄÄ¿
							//³FIM C6K³
							//ÀÄÄÄÄÄÄÄÙ
							
							// Valor Total do Itens da NF.
							nItemDocF+= C6J->C6J_VLRITE
					
							C6J->( DbSkip() )
						EndDo
					EndIf
					//ÚÄÄÄÄÄÄÄ¿
					//³FIM C6J³
					//ÀÄÄÄÄÄÄÄÙ

   					If !(C6I->C6I_VLDOC==nItemDocF)
   						aAdd(aLogErro,{"C6I_VLDOC","000506","C6F",nRecno}) //"O valor informado no campo 'Valor Total' deve ser igual à soma do campo 'Valor Item' dos registros "  
   					EndiF     
   					
   					If  Empty(C6I->C6I_CNPJ)
 						aAdd(aLogErro,{"C6I_CNPJ","000010","C6F",nRecno}) //STR0010 - Vazio ou inconsistente
					ElseIf !CGC(C6I->C6I_CNPJ,,.F.)
						aAdd(aLogErro,{"C6I_CNPJ","000005","C6F",nRecno}) //STR0005 - CPF/CNPJ Inconsistente
					EndIf

					C6I->( DbSkip() )
				EndDo
			EndIf
			//ÚÄÄÄÄÄÄÄ¿
			//³FIM C6I³
			//ÀÄÄÄÄÄÄÄÙ

			C6G->( DbSkip() )
		EndDo
	EndIf
	//ÚÄÄÄÄÄÄÄ¿
	//³FIM C6G³
	//ÀÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄ¿
	//³INICIO C6L³
	//ÀÄÄÄÄÄÄÄÄÄÄÙ
	//Validação da Grid Processos Referenciados ECF									  
	C6L->( DBSetOrder(1) )
	
	cC6LKey := C6F->C6F_ID
	If C6L->( MsSeek( xFilial("C6L") + cC6LKey ) )

		Do While !C6L->( Eof() ) .And. cC6LKey == C6L->C6L_ID
		 	//Validação de consulta padrão
			If !Empty(C6L->C6L_IDPROC)
				cChave := C6L->C6L_IDPROC
				xValRegTab("C1G",cChave,3,,@aLogErro,, { "C6F", "C6L_IDPROC", nRecno } )
			EndIf

			C6L->( DbSkip() )
		EndDo
	EndIf
	//ÚÄÄÄÄÄÄÄ¿
	//³FIM C6L³
	//ÀÄÄÄÄÄÄÄÙ
 
	//ATUALIZO O STATUS DO REGISTRO
	If Len(aLogErro)>0	
		//Utilizo RecLock, pois o SETVALUE somente funciona em campos USADOS
		RecLock("C6F",.F.)
		C6F->C6F_STATUS := "1" 
		C6F->( MsUnlock() )    
	Else
		RecLock("C6F",.F.)
		C6F->C6F_STATUS := "0" 
		C6F->( MsUnlock() )        
	EndIf

Else
	AADD(aLogErro,{"C6F_ID","000305", "C6F", nRecno })   //Registros válidos não podem ser validados novamente
EndIf	

If !lJob
	xValLogEr(aLogErro)
EndIf

Return(aLogErro)
