#INCLUDE "PROTHEUS.CH"                                                                                                                                                                                                                                                                                    
#INCLUDE "FWMVCDEF.CH"                                                                                                                                                                                                                                                                                    
#INCLUDE "TAFA200.CH"                                                                                                                                                                                                                                                                                     
                                                                                                                                                                                                                                                                                                          
//-------------------------------------------------------------------                                                                                                                                                                                                                                     
/*/{Protheus.doc} TAFA200                                                                                                                                                                                                                                                                                 
Cadastro MVC - Consolidado - Resumo Mensal dos Itens do ECF por Estabelecimento                                                                                                                                                                                                                                                                           
                                                                                                                                                                                                                                                                                                          
@author Ana Laura Olegini                                                                                                                                                                                                                                                                                   
@since 30/01/2013                                                                                                                                                                                                                                                                                         
@version 1.0                                                                                                                                                                                                                                                                                              
                                                                                                                                                                                                                                                                                                          
/*/                                                                                                                                                                                                                                                                                                       
//-------------------------------------------------------------------                                                                                                                                                                                                                                     
Function TAFA200                                                                                                                                                                                                                                                                                          
Local	oBrw	:= FWmBrowse():New()                                                                                                                                                                                                                                                                          
                                                                                                                                                                                                                                                                                                          
oBrw:SetDescription( STR0001 ) //"Resumo Mensal dos Itens do ECF por Estabelecimento"                                                                                                                                                                                                                                                      
oBrw:SetAlias( 'C7H' )                                                                                                                                                                                                                                                                                    
oBrw:SetMenuDef( 'TAFA200' )                                                                                                                                                                                                                                                                              
oBrw:Activate()                                                                                                                                                                                                                                                                                           
                                                                                                                                                                                                                                                                                                          
Return                                                                                                                                                                                                                                                                                                    
//-------------------------------------------------------------------                                                                                                                                                                                                                                     
/*/{Protheus.doc} MenuDef                                                                                                                                                                                                                                                                                 
Funcao generica MVC com as opcoes de menu                                                                                                                                                                                                                                                                 
                                                                                                                                                                                                                                                                                                          
@return aRotina - Array com as opcoes de menu                                                                                                                                                                                                                                                             
                                                                                                                                                                                                                                                                                                          
@author Ana Laura Olegini                                                                                                                                                                                                                                                                                   
@since 30/01/2013                                                                                                                                                                                                                                                                                         
@version 1.0                                                                                                                                                                                                                                                                                              
/*/                                                                                                                                                                                                                                                                                                       
//-------------------------------------------------------------------                                                                                                                                                                                                                                     
Static Function MenuDef()                                                                                                                                                                                                                                                                                 
Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf200Vld" , "2" } )

lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If lMenuDif
	ADD OPTION aRotina Title "Visualizar" Action 'VIEWDEF.TAFA200' OPERATION 2 ACCESS 0
Else
	aRotina	:=	xFunMnuTAF( "TAFA200" , , aFuncao)
EndIf                                     

Return( aRotina )                                                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                                                                          
//-------------------------------------------------------------------                                                                                                                                                                                                                                     
/*/{Protheus.doc} ModelDef                                                                                                                                                                                                                                                                                
Funcao generica MVC do model                                                                                                                                                                                                                                                                              
                                                                                                                                                                                                                                                                                                          
@return oModel - Objeto do Modelo MVC                                                                                                                                                                                                                                                                     
                                                                                                                                                                                                                                                                                                          
@author Ana Laura Olegini                                                                                                                                                                                                                                                                                   
@since 30/01/2013                                                                                                                                                                                                                                                                                         
@version 1.0                                                                                                                                                                                                                                                                                            
/*/                                                                                                                                                                                                                                                                                                       
//-------------------------------------------------------------------
Static Function ModelDef() 
                                                                                                                                                                                                                                                                               
Local oStruC7H 	:= 	FWFormStruct( 1, 'C7H' )                                                                                                                                                                                                                                                              
Local oModel 	  := 	MPFormModel():New( 'TAFA200',,{ |oModel| SaveModel( oModel ) } )                                                                                                                                                                                                                                                          
                                                                                                                                                                                                                                                                                                          
oModel:AddFields('MODEL_C7H', /*cOwner*/, oStruC7H )                                                                                                                                                                                                                                                      

oModel:GetModel( "MODEL_C7H" ):SetPrimaryKey( { "C7H_DTMOVI" } )                                                                                                                                                                                                                                          
                                                                                                                                                                                                                                                                                                          
Return oModel                                                                                                                                                                                                                                                                                             
//-------------------------------------------------------------------                                                                                                                                                                                                                                     
/*/{Protheus.doc} ViewDef                                                                                                                                                                                                                                                                                 
Funcao generica MVC do View                                                                                                                                                                                                                                                                               
                                                                                                                                                                                                                                                                                                          
@return oView - Objeto da View MVC                                                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                                                                          
@author Ana Laura Olegini                                                                                                                                                                                                                                                                                   
@since 30/01/2013                                                                                                                                                                                                                                                                                         
@version 1.0                                                                                                                                                                                                                                                                                               
/*/                                                                                                                                                                                                                                                                                                       
//-------------------------------------------------------------------                                                                                                                                                                                                                                     
Static Function ViewDef()        
                                                                                                                                                                                                                                                                         
Local oModel 	  := 	FWLoadModel( 'TAFA200' ) 
Local oStruC7H 	:= 	FWFormStruct( 2, 'C7H' ) //Resumo Mensal dos Itens do ECF por Estabelecimento                                                                                                                                                                                                                               
Local oView 	  := 	FWFormView():New()                                                                                                                                                                                                                                                                      
                                                                                                                                                                                                                                       
oView:SetModel( oModel )                                                                                                                                                                                                                                                                               
                                                                                                                                                                                                                                                                                                        
oView:AddField( 'VIEW_C7H', oStruC7H, 'MODEL_C7H' )                                                                                                                                                                                                                                                       
oView:EnableTitleView( 'VIEW_C7H', STR0002 ) //Resumo Mensal dos Itens do ECF por Estabelecimento                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                                                                          
oView:CreateHorizontalBox( 'FIELDSC7H'  , 90 )                                                                                                                                                                                                                                                              
                                                                                                                                                                                                                                                                                                      
oView:SetOwnerView( 'VIEW_C7H', 'FIELDSC7H' )                                                                                                                                                                                                                                                             
If TamSX3("C7H_ITEM")[1] == 36
	oStruC7H:RemoveField("C7H_ITEM")
	oStruC7H:SetProperty("C7H_CODITE", 	MVC_VIEW_ORDEM, "04")
EndIf                                                                                                                                                                                                                                                             
                                                                                                                                                                                                                                                                                                          
Return oView                      

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo
                                                                                                                               
@param  oModel -> Modelo de dados
@return .T.

@author Paulo Sérgio V.B. Santana
@since 24/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

Local 	nOperation 	:= 	oModel:GetOperation()  

Begin Transaction

	If nOperation == MODEL_OPERATION_UPDATE 
		TAFAltStat( 'C7H', " " ) //Limpa o Status do Registro, tornando possível nova validação.
	Endif          	
	FwFormCommit( oModel )		
	
End Transaction

Return .T. 

//-------------------------------------------------------------------
/*/{Protheus.doc} Taf200Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacões 

lJob - Informa se foi chamado por Job

@return .T.

@author Paulo V.B. Santana
@since 24/02/2014
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function Taf200Vld(cAlias,nRecno,nOpc,lJob)
Local aLogErro   := {}
Local cChave     := ""                                                                                                                         
Local nVlrContP := 0 
Local cID:= "" 

Default lJob := .F.

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C7H->( Recno() )

If (C7H->C7H_STATUS $ (' 1'))

	If Empty(C7H->C7H_ITEM)
		aAdd(aLogErro,{"C7H_ITEM","000010","C7H",nRecno}) 	//"Campo Inconsistente ou Vazio" 
	Else
		cChave := C7H->C7H_ITEM
		xValRegTab("C1L",cChave,3,,@aLogErro,, {"C7H","C7H_ITEM", nRecno } )     
	EndIf   
	             
	If Empty(C7H->C7H_UNID)
		aAdd(aLogErro,{"C7H_UNID","000010","C7H",nRecno}) 	//"Campo Inconsistente ou Vazio" 
	Else
		cChave := C7H->C7H_UNID
		xValRegTab("C1J",cChave,3,,@aLogErro,, {"C7H","C7H_UNID", nRecno })     
	EndIf
	
	If Empty(C7H->C7H_DTMOVI)
		aAdd(aLogErro,{"C7H_DTMOVI","000010","C7H",nRecno}) 	//"Campo Inconsistente ou Vazio" 
	EndIf

	If Empty(C7H->C7H_ITEM)
		aAdd(aLogErro,{"C7H_ITEM","000010","C7H",nRecno}) 	//"Campo Inconsistente ou Vazio" 
	EndIf
	
	If Empty(C7H->C7H_QTD)
		aAdd(aLogErro,{"C7H_QTD","000010","C7H",nRecno}) 	//"Campo Inconsistente ou Vazio" 
	EndIf

	If Empty(C7H->C7H_VLITEM)
		aAdd(aLogErro,{"C7H_VLITEM","000010","C7H",nRecno}) 	//"Campo Inconsistente ou Vazio" 
	EndIf
	                                
	//ATUALIZO O STATUS DO REGISTRO
	If Len(aLogErro)>0	
		//Utilizo RecLock, pois o SETVALUE somente funciona em campos USADOS
		RecLock("C7H",.F.)
	    	C7H->C7H_STATUS := "1" 
	    C7H->( MsUnlock() )    
	Else
		RecLock("C7H",.F.)
	    	C7H->C7H_STATUS := "0" 
	    C7H->( MsUnlock() )        
	EndIf

Else
	AADD(aLogErro,{"C7H_ID","000305", "C7H", nRecno }) //Registros válidos não podem ser validados novamente
EndIf	

If !lJob
	xValLogEr(aLogErro)
EndIf

Return(aLogErro)         