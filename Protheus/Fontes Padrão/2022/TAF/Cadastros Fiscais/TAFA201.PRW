#INCLUDE "PROTHEUS.CH"                                                                                                                                                                                                                                                                                    
#INCLUDE "FWMVCDEF.CH"                                                                                                                                                                                                                                                                                    
#INCLUDE "TAFA201.CH"                                                                                                                                                                                                                                                                                     
                                                                                                                                                                                                                                                                                                          
//-------------------------------------------------------------------                                                                                                                                                                                                                                     
/*/{Protheus.doc} TAFA201                                                                                                                                                                                                                                                                                 
Cadastro MVC -                                                                                                                                                                                                                                                                           
                                                                                                                                                                                                                                                                                                          
@author Gustavo Baptista                                                                                                                                                                                                                                                                                   
@since 29/01/2013                                                                                                                                                                                                                                                                                         
@version 1.0                                                                                                                                                                                                                                                                                              
                                                                                                                                                                                                                                                                                                          
/*/                                                                                                                                                                                                                                                                                                       
//-------------------------------------------------------------------                                                                                                                                                                                                                                     
Function TAFA201                                                                                                                                                                                                                                                                                          
Local	oBrw	:= FWmBrowse():New()                                                                                                                                                                                                                                                                          
                                                                                                                                                                                                                                                                                                          
oBrw:SetDescription( STR0001 ) //"Consolidacion Diaria de Facturas"                                                                                                                                                                                                                                                    
oBrw:SetAlias( 'C7I' )                                                                                                                                                                                                                                                                                    
oBrw:SetMenuDef( 'TAFA201' )                                                                                                                                                                                                                                                                              
oBrw:Activate()                                                                                                                                                                                                                                                                                           
                                                                                                                                                                                                                                                                                                          
Return                                                                                                                                                                                                                                                                                                    
//-------------------------------------------------------------------                                                                                                                                                                                                                                     
/*/{Protheus.doc} MenuDef                                                                                                                                                                                                                                                                                 
Funcao generica MVC com as opcoes de menu                                                                                                                                                                                                                                                                 
                                                                                                                                                                                                                                                                                                          
@return aRotina - Array com as opcoes de menu                                                                                                                                                                                                                                                             
                                                                                                                                                                                                                                                                                                          
@author Gustavo Baptista                                                                                                                                                                                                                                                                                   
@since 29/01/2013                                                                                                                                                                                                                                                                                         
@version 1.0                                                                                                                                                                                                                                                                                              
/*/                                                                                                                                                                                                                                                                                                       
//-------------------------------------------------------------------                                                                                                                                                                                                                                     
Static Function MenuDef()                                                                                                                                                                                                                                                                                 
Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf201Vld" , "2" } )

lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If lMenuDif
	ADD OPTION aRotina Title "Visualizar" Action 'VIEWDEF.TAFA201' OPERATION 2 ACCESS 0
Else
	aRotina	:=	xFunMnuTAF( "TAFA201" , , aFuncao)
EndIf                                     

Return( aRotina )          
                                                                                                                                                                                                                                                                          
//-------------------------------------------------------------------                                                                                                                                                                                                                                     
/*/{Protheus.doc} ModelDef                                                                                                                                                                                                                                                                                
Funcao generica MVC do model                                                                                                                                                                                                                                                                              
                                                                                                                                                                                                                                                                                                          
@return oModel - Objeto do Modelo MVC                                                                                                                                                                                                                                                                     
                                                                                                                                                                                                                                                                                                          
@author Gustavo Baptista                                                                                                                                                                                                                                                                                   
@since 29/01/2012                                                                                                                                                                                                                                                                                         
@version 1.0                                                                                                                                                                                                                                                                                              
/*/                                                                                                                                                                                                                                                                                                       
//-------------------------------------------------------------------                                                                                                                                                                                                                                     
Static Function ModelDef()
Local oStruC7I 	:= 	FWFormStruct( 1, 'C7I' )
Local oStruC7J 	:= 	FWFormStruct( 1, 'C7J' )
Local oStruC7K 	:= 	FWFormStruct( 1, 'C7K' )
Local oStruC7L 	:= 	FWFormStruct( 1, 'C7L' )

Local oModel 	:= 	MPFormModel():New( 'TAFA201',,,{ |oModel| SaveModel( oModel ) }  )

oModel:AddFields('MODEL_C7I', /*cOwner*/, oStruC7I )

oModel:AddGrid('MODEL_C7J', 'MODEL_C7I', oStruC7J)
oModel:GetModel( 'MODEL_C7J' ):SetUniqueLine( { 'C7J_CST' } )

oModel:AddGrid('MODEL_C7K', 'MODEL_C7I', oStruC7K)
oModel:GetModel( 'MODEL_C7K' ):SetUniqueLine( { 'C7K_CST' } )
                                                                                                                                                                                                                                                                                                          
oModel:AddGrid('MODEL_C7L', 'MODEL_C7I', oStruC7L)
oModel:GetModel( 'MODEL_C7L' ):SetUniqueLine( { 'C7L_NUMPRO' } )
oModel:GetModel( 'MODEL_C7L' ):SetOptional( .T. )

oModel:SetRelation( 'MODEL_C7J' , { { 'C7J_FILIAL' , 'xFilial( "C7J" )' } , { 'C7J_ID' , 'C7I_ID' } } , C7J->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_C7K' , { { 'C7K_FILIAL' , 'xFilial( "C7K" )' } , { 'C7K_ID' , 'C7I_ID' } } , C7K->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_C7L' , { { 'C7L_FILIAL' , 'xFilial( "C7L" )' } , { 'C7L_ID' , 'C7I_ID' } } , C7L->( IndexKey( 1 ) ) )

oModel:GetModel( "MODEL_C7I" ):SetPrimaryKey( { "C7I_FILIAL", "C7I_ID" } )

Return oModel

//-------------------------------------------------------------------                                                                                                                                                                                                                                     
/*/{Protheus.doc} ViewDef                                                                                                                                                                                                                                                                                 
Funcao generica MVC do View                                                                                                                                                                                                                                                                               
                                                                                                                                                                                                                                                                                                          
@return oView - Objeto da View MVC                                                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                                                                          
@author Gustavo Baptista                                                                                                                                                                                                                                                                                   
@since 29/01/2012                                                                                                                                                                                                                                                                                         
@version 1.0                                                                                                                                                                                                                                                                                              
/*/                                                                                                                                                                                                                                                                                                       
//-------------------------------------------------------------------                                                                                                                                                                                                                                     
Static Function ViewDef()                                                                                                                                                                                                                                                                                 
Local oModel 	:= 	FWLoadModel( 'TAFA201' )                                                                                                                                                                                                                                                                
Local oStruC7I 	:= 	FWFormStruct( 2, 'C7I' )
Local oStruC7J 	:= 	FWFormStruct( 2, 'C7J' )
Local oStruC7K 	:= 	FWFormStruct( 2, 'C7K' )
Local oStruC7L 	:= 	FWFormStruct( 2, 'C7L' )
                                                                                                                                                                                                                                                                                                     
Local oView 	:= 	FWFormView():New()                                                                                                                                                                                                                                                                      
                                                                                                                                                                                                                                                                                                          
oView:SetModel( oModel )                                                                                                                                                                                                                                                                                  
                                                                                                                                                                                                                                                                                                          
oView:AddField( 'VIEW_C7I', oStruC7I, 'MODEL_C7I' )
oView:EnableTitleView( 'VIEW_C7I', STR0001 ) //"Consolidacion Diaria de Facturas"


oView:AddGrid( 'VIEW_C7J', oStruC7J, 'MODEL_C7J' )
oView:EnableTitleView( 'VIEW_C7J', STR0002 ) //"Documentos de salidas - PIS/PASEP"

oView:AddGrid( 'VIEW_C7K', oStruC7K, 'MODEL_C7K' )
oView:EnableTitleView( 'VIEW_C7K', STR0003 ) //"Documentos de salidas - COFINS"

oView:AddGrid( 'VIEW_C7L', oStruC7L, 'MODEL_C7L' )
oView:EnableTitleView( 'VIEW_C7L', STR0004 ) //"Proceso Referenciado"                                                                                                                                                                                                                                                                                                         

oView:CreateHorizontalBox( 'FIELDSC7I', 50 )
oView:CreateHorizontalBox( 'FOLDERGERAL', 50 )

oView:CreateFolder( 'FOLDER1', 'FOLDERGERAL' )

oView:AddSheet( 'FOLDER1', 'ABA01', STR0002 ) //"Documentos de salidas - PIS/PASEP"
oView:CreateHorizontalBox( 'GRIDC7J', 100,,, 'FOLDER1', 'ABA01' )

oView:AddSheet( 'FOLDER1', 'ABA02', STR0003 ) //"Documentos de salidas - COFINS"
oView:CreateHorizontalBox( 'GRIDC7K', 100,,, 'FOLDER1', 'ABA02' )  

oView:AddSheet( 'FOLDER1', 'ABA03', STR0004 ) //"Proceso Referenciado"
oView:CreateHorizontalBox( 'GRIDC7L', 100,,, 'FOLDER1', 'ABA03' )  
If TamSX3("C7J_CODCTA")[1] == 36
	oStruC7J:RemoveField( "C7J_CODCTA")
	oStruC7J:SetProperty( "C7J_CTACTB", MVC_VIEW_ORDEM, "10" )
	oStruC7J:SetProperty( "C7J_DCODCT", MVC_VIEW_ORDEM, "11" )
EndIf                                                                                                                                                                                                            
If TamSX3("C7K_CODCTA")[1] == 36
	oStruC7K:RemoveField( "C7K_CODCTA")
	oStruC7K:SetProperty( "C7K_CTACTB", MVC_VIEW_ORDEM, "10" )
	oStruC7K:SetProperty( "C7K_DCODCT", MVC_VIEW_ORDEM, "11" )
EndIf                                                                                                                                                                                                            

oView:SetOwnerView( 'VIEW_C7I', 'FIELDSC7I' )        
oView:SetOwnerView( 'VIEW_C7J', 'GRIDC7J' ) 
oView:SetOwnerView( 'VIEW_C7K', 'GRIDC7K' ) 
oView:SetOwnerView( 'VIEW_C7L', 'GRIDC7L' ) 
                                                                                                                                                                                                                                                                                                         
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
		TAFAltStat( 'C7I', " " ) //Limpa o Status do Registro, tornando possível nova validação.
	Endif          	
	FwFormCommit( oModel )		
End Transaction

Return .T.                                                                                                                                                                                                                                                                 
                                
//-------------------------------------------------------------------
/*/{Protheus.doc} Taf201Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacões 

lJob - Informa se foi chamado por Job

@return .T.

@author Paulo V.B. Santana
@since 24/02/2014
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function Taf201Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro   := {}
Local cChave     := ""                                                                                                                         
Local cID:= "" 

Default lJob := .F.

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C7I->( Recno() )

If (C7I->C7I_STATUS $ (' 1'))      
	If !Empty(C7I->C7I_CODMOD)
		cChave := C7I->C7I_CODMOD
		xValRegTab("C01",cChave,3,,@aLogErro,, { "C7I", "C7I_CODMOD", nRecno } )     
	EndIf                
    
    If !Empty(C7I->C7I_UF)
		cChave := C7I->C7I_UF
		xValRegTab("C09",cChave,3,,@aLogErro,, { "C7I", "C7I_UF", nRecno })     
	EndIf                          
	
    If !Empty(C7I->C7I_CODCON)
		cChave := C7I->C7I_CODCON
		xValRegTab("C0L",cChave,3,,@aLogErro,, { "C7I", "C7I_CODCON", nRecno })     
	EndIf 

   	If Empty(C7I->C7I_QTDCON)
		aAdd(aLogErro,{"C7I_QTDCON","000010","C7I",nRecno})  //"Campo Inconsistente ou Vazio" 
	EndIf

   	If Empty(C7I->C7I_DTDOC)
		aAdd(aLogErro,{"C7I_DTDOC","000010","C7I",nRecno})  	//"Campo Inconsistente ou Vazio" 
	EndIf

   	If Empty(C7I->C7I_VLDOC)
		aAdd(aLogErro,{"C7I_VLDOC","000010","C7I",nRecno})  	//"Campo Inconsistente ou Vazio" 
	EndIf
         
   	If Empty(C7I->C7I_VLPIS)
		aAdd(aLogErro,{"C7I_VLPIS","000010","C7I",nRecno})  	//"Campo Inconsistente ou Vazio" 
	EndIf

   	If Empty(C7I->C7I_VLCOFI)
		aAdd(aLogErro,{"C7I_VLCOFI","000010","C7I",nRecno})  //"Campo Inconsistente ou Vazio" 
	EndIf
	
	
	dbSelectArea("C7J")
	C7J->(dbSetOrder(1))
	If C7J->(MsSeek(xFilial("C7J")+C7I->C7I_ID))
		While !C7J->(Eof()) .And. (C7I->C7I_FILIAL+C7I->C7I_ID == C7J->C7J_FILIAL+C7J->C7J_ID)
		
		   	If Empty(C7J->C7J_CST)
				aAdd(aLogErro,{"C7J_CST","000010","C7I",nRecno})  //"Campo Inconsistente ou Vazio" 
			Else
         		xValRegTab("C17",C7J->C7J_CST,3,,@aLogErro,, { "C7I", "C7J_CST", nRecno } )
         	EndIf

		   	If Empty(C7J->C7J_VLRITE)
				aAdd(aLogErro,{"C7J_VLRITE","000010","C7I",nRecno})  //"Campo Inconsistente ou Vazio" 
			EndIf

		   	If Empty(C7J->C7J_VLRBC)
				aAdd(aLogErro,{"C7J_VLRBC","000010","C7I",nRecno})  //"Campo Inconsistente ou Vazio" 
			EndIf

		   	If Empty(C7J->C7J_ALIQ)
				aAdd(aLogErro,{"C7J_ALIQ","000010","C7I",nRecno})  //"Campo Inconsistente ou Vazio" 
			EndIf

		   	If Empty(C7J->C7J_VL)
				aAdd(aLogErro,{"C7J_VL","000010","C7I",nRecno})  //"Campo Inconsistente ou Vazio" 
			EndIf

			If !Empty( C7J->C7J_CODCTA )
         		xValRegTab("C1O",C7J->C7J_CODCTA,3,,@aLogErro,, { "C7I", "C7J_CODCTA", nRecno } )
         	EndIf
			
			C7J->(dbSkip())
		EndDo
	EndIf
	
	dbSelectArea("C7K")
	C7K->(dbSetOrder(1))
	If C7K->(MsSeek(xFilial("C7K")+C7I->C7I_ID))

		While !C7K->(Eof()) .And. (C7I->C7I_FILIAL+C7I->C7I_ID == C7K->C7K_FILIAL+C7K->C7K_ID)
		
		   	If Empty(C7K->C7K_CST)
				aAdd(aLogErro,{"C7K_CST","000010","C7I",nRecno})  //"Campo Inconsistente ou Vazio" 
			Else
         		xValRegTab("C17",C7K->C7K_CST,3,,@aLogErro,, { "C7I", "C7K_CST", nRecno } )
         	EndIf
			
		   	If Empty(C7K->C7K_VLRITE)
				aAdd(aLogErro,{"C7K_VLRITE","000010","C7I",nRecno})  //"Campo Inconsistente ou Vazio" 
			EndIf

		   	If Empty(C7K->C7K_VLBC)
				aAdd(aLogErro,{"C7K_VLBC","000010","C7I",nRecno})  //"Campo Inconsistente ou Vazio" 
			EndIf

		   	If Empty(C7K->C7K_ALIQ)
				aAdd(aLogErro,{"C7K_ALIQ","000010","C7I",nRecno})  //"Campo Inconsistente ou Vazio" 
			EndIf

		   	If Empty(C7K->C7K_VL)
				aAdd(aLogErro,{"C7K_VL","000010","C7I",nRecno})  //"Campo Inconsistente ou Vazio" 
			EndIf
			
			If !Empty( C7K->C7K_CODCTA )
         		xValRegTab("C1O",C7K->C7K_CODCTA,3,,@aLogErro,, { "C7I", "C7K_CODCTA", nRecno } )
         	EndIf
			
		
			C7K->(dbSkip())
		EndDo
	EndIf
	
	//ATUALIZO O STATUS DO REGISTRO
	If Len(aLogErro)>0	
		//Utilizo RecLock, pois o SETVALUE somente funciona em campos USADOS
		RecLock("C7I",.F.)
		C7I->C7I_STATUS := "1"
		C7I->( MsUnlock() )    
	Else
		RecLock("C7I",.F.)
		C7I->C7I_STATUS := "0"
		C7I->( MsUnlock() )        
	EndIf

Else
	AADD(aLogErro,{"C7I_ID","000305", "C7I", nRecno }) //Registros válidos não podem ser validados novamente
EndIf	

If !lJob
	xValLogEr(aLogErro)
EndIf

Return(aLogErro)                                                                                                                                                                                                                                                             