#INCLUDE "PROTHEUS.CH"                                                                                                                                                                                                                                                                                    
#INCLUDE "FWMVCDEF.CH"                                                                                                                                                                                                                                                                                    
#INCLUDE "TAFA202.CH"                                                                                                                                                                                                                                                                                     
                                                                                                                                                                                                                                                                                                          
//-------------------------------------------------------------------                                                                                                                                                                                                                                     
/*/{Protheus.doc} TAFA202                                                                                                                                                                                                                                                                                 
Cadastro MVC 

  - C7M   - C700 - Consolidação diária de Docs mod. 06 e 28 Obr. ao conv.115;
  - C7N   - C790 - Registro Analítico dos Documentos (Código 06); 
  - C7O   - C791 - Registro de informações de ST por UF. (Código 06).
                                                                                                                                                                                                                                                                                                          
@author Ana Laura Olegini                                                                                                                                                                                                                                                                                   
@since 05/02/2013                                                                                                                                                                                                                                                                                         
@version 1.0                                                                                                                                                                                                                                                                                            
/*/                                                                                                                                                                                                                                                                                                       
//-------------------------------------------------------------------                                                                                                                                                                                                                                     
Function TAFA202                                                                                                                                                                                                                                                                                          
Local	oBrw	:= FWmBrowse():New()                                                                                                                                                                                                                                                                          
                                                                                                                                                                                                                                                                                                          
oBrw:SetDescription( STR0001 ) //"C700 - Consolidação diária de Docs mod. 06 e 28 Obr. ao conv.115"                                                                                                                                                                                                                                                     
oBrw:SetAlias( 'C7M' )                                                                                                                                                                                                                                                                                    
oBrw:SetMenuDef( 'TAFA202' )                                                                                                                                                                                                                                                                              
oBrw:Activate()                                                                                                                                                                                                                                                                                           
                                                                                                                                                                                                                                                                                                          
Return                                                                                                                                                                                                                                                                                                    
//-------------------------------------------------------------------                                                                                                                                                                                                                                     
/*/{Protheus.doc} MenuDef                                                                                                                                                                                                                                                                                 
Funcao generica MVC com as opcoes de menu                                                                                                                                                                                                                                                                 
                                                                                                                                                                                                                                                                                                          
@return aRotina - Array com as opcoes de menu                                                                                                                                                                                                                                                             
                                                                                                                                                                                                                                                                                                          
@author Ana Laura Olegini                                                                                                                                                                                                                                                                                   
@since 05/02/2013                                                                                                                                                                                                                                                                                         
@version 1.0                                                                                                                                                                                                                                                                                              
/*/                                                                                                                                                                                                                                                                                                       
//-------------------------------------------------------------------                                                                                                                                                                                                                                     
Static Function MenuDef()                                                                                                                                                                                                                                                                                 
Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf202Vld" , "2" } )

lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If lMenuDif
	ADD OPTION aRotina Title "Visualizar" Action 'VIEWDEF.TAFA202' OPERATION 2 ACCESS 0
Else
	aRotina	:=	xFunMnuTAF( "TAFA202" , , aFuncao)
EndIf                                     

Return( aRotina )                                                                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                                                                          
//-------------------------------------------------------------------                                                                                                                                                                                                                                     
/*/{Protheus.doc} ModelDef                                                                                                                                                                                                                                                                                
Funcao generica MVC do model                                                                                                                                                                                                                                                                              
                                                                                                                                                                                                                                                                                                          
@return oModel - Objeto do Modelo MVC                                                                                                                                                                                                                                                                     
                                                                                                                                                                                                                                                                                                          
@author Ana Laura Olegini                                                                                                                                                                                                                                                                                   
@since 05/02/2013                                                                                                                                                                                                                                                                                         
@version 1.0                                                                                                                                                                                                                                                                                            
/*/                                                                                                                                                                                                                                                                                                       
//-------------------------------------------------------------------
Static Function ModelDef() 
                                                                                                                                                                                                                                                                               
Local oStruC7M 	:= 	FWFormStruct( 1, 'C7M' ) //"C700 - Consolidação diária de Docs mod. 06 e 28 Obr. ao conv.115"                                                                                                                                                                                                                                                           
Local oStruC7N 	:= 	FWFormStruct( 1, 'C7N' ) //"C790 - Registro Analítico dos Documentos (Código 06)"                
Local oStruC7O 	:= 	FWFormStruct( 1, 'C7O' ) //"C791 - Registro de informações de ST por UF. (Código 06)"
                                                                                                                                                                                                                                                          
Local oModel 	:= 	MPFormModel():New( 'TAFA202',,,{ |oModel| SaveModel( oModel ) }  )
                                                                                                                                                                                                                                                                                                         
oModel:AddFields('MODEL_C7M', /*cOwner*/, oStruC7M )                                                                                                                                                                                                                                                      

oModel:AddGrid('MODEL_C7N', 'MODEL_C7M', oStruC7N)  
oModel:AddGrid('MODEL_C7O', 'MODEL_C7N', oStruC7O)  

oModel:GetModel( 'MODEL_C7N' ):SetOptional( .T. )
oModel:GetModel( 'MODEL_C7N' ):SetUniqueLine( { 'C7N_CSTICM','C7N_CFOP','C7N_ALQICM' } )
oModel:SetRelation( 'MODEL_C7N' , { { 'C7N_FILIAL' , 'xFilial( "C7N" )' } , { 'C7N_ID' , 'C7M_ID' } } , C7N->( IndexKey( 1 ) ) ) 

oModel:GetModel( 'MODEL_C7O' ):SetOptional( .T. )
oModel:GetModel( 'MODEL_C7O' ):SetUniqueLine( { 'C7O_UF' } )
oModel:SetRelation( 'MODEL_C7O' , { { 'C7O_FILIAL' , 'xFilial( "C7O" )' } , { 'C7O_ID' , 'C7M_ID' } , { 'C7O_CSTICM' , 'C7N_CSTICM'} ,  { 'C7O_CFOP' , 'C7N_CFOP' } , { 'C7O_ALQICM' , 'C7N_ALQICM' } } , C7O->( IndexKey( 1 ) ) )

oModel:GetModel( "MODEL_C7M" ):SetPrimaryKey( { 'C7M_ID' , 'C7M_DTMOV' , 'C7M_CODMOD' , 'C7M_NSER' , 'C7M_NORDIN' , 'C7M_NORDFI' } )
                                                                                                                                                                                                                                                                                                        
Return oModel                                                                                       

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
		TAFAltStat( 'C7M', " " ) //Limpa o Status do Registro, tornando possível nova validação.
	Endif          
	
	FwFormCommit( oModel )		
	
End Transaction


Return .T.         
                                                                                                                                                                                                      
//-------------------------------------------------------------------                                                                                                                                                                                                                                     
/*/{Protheus.doc} ViewDef                                                                                                                                                                                                                                                                                 
Funcao generica MVC do View                                                                                                                                                                                                                                                                               
                                                                                                                                                                                                                                                                                                          
@return oView - Objeto da View MVC                                                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                                                                          
@author Ana Laura Olegini                                                                                                                                                                                                                                                                                   
@since 05/02/2013                                                                                                                                                                                                                                                                                         
@version 1.0                                                                                                                                                                                                                                                                                               
/*/                                                                                                                                                                                                                                                                                                       
//-------------------------------------------------------------------                                                                                                                                                                                                                                     
Static Function ViewDef()        
                                                                                                                                                                                                                                                                         
Local oModel 	  := 	FWLoadModel( 'TAFA202' ) 
Local oStruC7M 	:= 	FWFormStruct( 2, 'C7M' ) //"C700 - Consolidação diária de Docs mod. 06 e 28 Obr. ao conv.115"                                                                                                                                                                                                                           
Local oStruC7N 	:= 	FWFormStruct( 2, 'C7N' ) //"C790 - Registro Analítico dos Documentos (Código 06)" 
Local oStruC7O 	:= 	FWFormStruct( 2, 'C7O' ) //"C791 - Registro de informações de ST por UF. (Código 06)"

Local oView 	  := 	FWFormView():New()                                                                                                                                                                                                                                                                      

oStruC7M:SetProperty( 'C7M_CODMOD'   , MVC_VIEW_LOOKUP   , "C01" )
oStruC7N:SetProperty( 'C7N_CSTICM'   , MVC_VIEW_LOOKUP   , "C14" )

                                                                                                                                                                                                                                       
oView:SetModel( oModel )                                                                                                                                                                                                                                                                               
                                                                                                                                                                                                                                                                                                        
oView:AddField( 'VIEW_C7M', oStruC7M, 'MODEL_C7M' ) //"C700 - Consolidação diária de Docs mod. 06 e 28 Obr. ao conv.115"                                                                                                                                                                                                                                                      
oView:EnableTitleView( 'VIEW_C7M', STR0002 )                                                                                                                                                                                                                                       
 
 oView:AddGrid ( 'VIEW_C7N', oStruC7N, 'MODEL_C7N' ) //"C790 - Registro Analítico dos Documentos (Código 06)"
 oView:EnableTitleView( 'VIEW_C7N', STR0003 )        
 
oView:AddGrid ( 'VIEW_C7O', oStruC7O, 'MODEL_C7O' ) //"C791 - Registro de informações de ST por UF. (Código 06)"
oView:EnableTitleView( 'VIEW_C7O', STR0004 )

                                                                                                                                                                                                                                                                        
oView:CreateHorizontalBox( 'FIELDSC7M'  , 30 )                                                                                                                                                                                                                                                              
oView:CreateHorizontalBox( 'FOLDERGERAL', 70 ) 

oView:CreateFolder( 'FOLDER1', 'FOLDERGERAL' )

oView:AddSheet( 'FOLDER1', 'ABA01', STR0003 ) 
oView:CreateHorizontalBox( 'GRIDC7N',   50,,, 'FOLDER1', 'ABA01' )
oView:CreateHorizontalBox( 'FOLDERC7O', 50,,, 'FOLDER1', 'ABA01' ) 
                                                                                                                                                                                                                                                                                                 
oView:SetOwnerView( 'VIEW_C7M', 'FIELDSC7M' )
oView:SetOwnerView( 'VIEW_C7O', 'FOLDERC7O' )                                                                                                                                                                                                                                                             
oView:SetOwnerView( 'VIEW_C7N', 'GRIDC7N' )
                                                                                                                                                                                                                                                                                                          
Return oView           

//-------------------------------------------------------------------
/*/{Protheus.doc} Taf202Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacões 

lJob - Informa se foi chamado por Job

@return .T.

@author Paulo V.B. Santana
@since 24/02/2014
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function Taf202Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro   := {}
Local cChave     := ""                                                                                                                         
Local nVlrContP := 0 
Local cID:= "" 

Default lJob := .F.

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C7M->( Recno() )

If (C7M->C7M_STATUS $ (' 1'))
    
    //Nenhuma validação disponível
    
	//ATUALIZO O STATUS DO REGISTRO
	If Len(aLogErro)>0	
		//Utilizo RecLock, pois o SETVALUE somente funciona em campos USADOS
		RecLock("C7M",.F.)
	    	C7M->C7M_STATUS := "1" 
	    C7M->( MsUnlock() )    
	Else
		RecLock("C7M",.F.)
	    	C7M->C7M_STATUS := "0" 
	    C7M->( MsUnlock() )        
	EndIf
Else
	AADD(aLogErro,{"C7M_ID","000305", "C7M", nRecno }) //Registros válidos não podem ser validados novamente
EndIf	

If !lJob
	xValLogEr(aLogErro)
EndIf

Return(aLogErro)            
