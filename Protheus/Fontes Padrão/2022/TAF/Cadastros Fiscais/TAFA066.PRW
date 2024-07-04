#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"    
#INCLUDE "TAFA066.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA066
Cadastro MVC - Detalhamento da contribuicao - PIS/PASEP e/ou Cofins  do periodo

@author Rodrigo Aguilar
@since 13/10/2014
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA066

Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //"Consolidação da Contribuição do Período" 
oBrw:SetAlias( "C46" )
oBrw:SetMenuDef( "TAFA066" )
oBrw:Activate()  

Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@return aRotina - Array com as opcoes de menu

@author Rodrigo Aguilar
@since 13/10/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf066Vld" , "2" } )

lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If lMenuDif
	ADD OPTION aRotina Title "Visualizar" Action 'VIEWDEF.TAFA066' OPERATION 2 ACCESS 0
Else
	aRotina :=	xFunMnuTAF( "TAFA066" , , aFuncao )
EndIf                                     

Return( aRotina ) 

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Rodrigo Aguilar
@since 13/10/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruC46 := FWFormStruct( 1, 'C46' )
Local oStruC47 := FWFormStruct( 1, 'C47' )
Local oStruC48 := FWFormStruct( 1, 'C48' )
Local oStruCUX := FWFormStruct( 1, 'CUX' )
Local oStruCAA := FWFormStruct( 1, 'CAA' )
Local oStruC4C := FWFormStruct( 1, 'C4C' )
Local oStruCZO := FWFormStruct( 1, 'CZO' )
Local oModel 	 := MPFormModel():New( 'TAFA066',,, { |oModel| SaveModel( oModel ) })
      
oModel:AddFields('MODEL_C46', /*cOwner*/, oStruC46 )

oModel:AddGrid('MODEL_C47', 'MODEL_C46', oStruC47)  
oModel:GetModel( 'MODEL_C47' ):SetUniqueLine( { 'C47_NUMCMP', 'C47_CODREC' } )
oModel:GetModel( 'MODEL_C47' ):SetOptional( .T. )

oModel:AddGrid('MODEL_C48', 'MODEL_C46', oStruC48)   
oModel:GetModel( 'MODEL_C48' ):SetUniqueLine( { 'C48_CODCON', 'C48_ALQPER', 'C48_ALQQTD' } )
oModel:GetModel( 'MODEL_C48' ):SetOptional( .T. )

oModel:AddGrid('MODEL_C4C', 'MODEL_C48', oStruC4C)   
oModel:GetModel( 'MODEL_C4C' ):SetUniqueLine( { 'C4C_INDCOO' } )
oModel:GetModel( 'MODEL_C4C' ):SetOptional( .T. )

oModel:AddGrid('MODEL_CUX', 'MODEL_C48', oStruCUX)  
oModel:GetModel( 'MODEL_CUX' ):SetUniqueLine( { 'CUX_INDAJU', 'CUX_CODAJU', 'CUX_NUMDOC', 'CUX_DTREF' } )
oModel:GetModel( 'MODEL_CUX' ):SetOptional( .T. )

oModel:AddGrid('MODEL_CAA', 'MODEL_CUX', oStruCAA)  
oModel:GetModel( 'MODEL_CAA' ):SetUniqueLine( { 'CAA_CSTPC', 'CAA_DTAJUS', 'CAA_CODCTA' } ) 
oModel:GetModel( 'MODEL_CAA' ):SetOptional( .T. )

oModel:AddGrid('MODEL_CZO', 'MODEL_C48', oStruCZO)   
oModel:GetModel( 'MODEL_CZO' ):SetUniqueLine( { 'CZO_CNPJ', 'CZO_CODCRE' } )
oModel:GetModel( 'MODEL_CZO' ):SetOptional( .T. )

oModel:SetRelation( 'MODEL_C47' , { { 'C47_FILIAL' , 'xFilial( "C47" )' } , { 'C47_ID' , 'C46_ID' }} , C47->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_C48' , { { 'C48_FILIAL' , 'xFilial( "C48" )' } , { 'C48_ID' , 'C46_ID' }} , C48->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_C4C' , { { 'C4C_FILIAL' , 'xFilial( "C4C" )' } , { 'C4C_ID' , 'C46_ID' }, { 'C4C_CODCON' , 'C48_CODCON' }, { 'C4C_ALQPER' , 'C48_ALQPER' }, { 'C4C_ALQQTD' , 'C48_ALQQTD' }} , C4C->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_CUX' , { { 'CUX_FILIAL' , 'xFilial( "CUX" )' } , { 'CUX_ID' , 'C46_ID' }, { 'CUX_CODCON' , 'C48_CODCON' }, { 'CUX_ALQPER' , 'C48_ALQPER' }, { 'CUX_ALQQTD' , 'C48_ALQQTD' } } , CUX->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_CAA' , { { 'CAA_FILIAL' , 'xFilial( "CAA" )' } , { 'CAA_ID' , 'C46_ID' }, { 'CAA_CODCON' , 'C48_CODCON' }, { 'CAA_ALQPER' , 'C48_ALQPER' }, { 'CAA_ALQQTD' , 'C48_ALQQTD' }, { 'CAA_INDAJU' , 'CUX_INDAJU' }, { 'CAA_CODAJU' , 'CUX_CODAJU' }, { 'CAA_NUMDOC' , 'CUX_NUMDOC' }, { 'CAA_DTREF' , 'CUX_DTREF' } } , CAA->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_CZO' , { { 'CZO_FILIAL' , 'xFilial( "CZO" )' } , { 'CZO_ID' , 'C46_ID' }, { 'CZO_CODCON' , 'C48_CODCON' }, { 'CZO_ALQPER' , 'C48_ALQPER' }, { 'CZO_ALQQTD' , 'C48_ALQQTD' } } , CZO->( IndexKey( 1 ) ) )

oModel:GetModel ( "MODEL_C46" ):SetPrimaryKey( { "C46_PERIOD", "C46_TIPTRB" } )

Return ( oModel )

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
		//Limpa o Status do Registro, tornando possível nova validação. 
		TAFAltStat( 'C46', " " ) 
	Endif          
	
	FwFormCommit( oModel )		
	
End Transaction

Return ( .T. )  

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Rodrigo Aguilar
@since 14/10/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oStruC46  := FWFormStruct( 2, 'C46' )      
Local oStruC47  := FWFormStruct( 2, 'C47' ) 
Local oStruC48  := FWFormStruct( 2, 'C48' )  
Local oStruC4C  := FWFormStruct( 2, 'C4C' )   
Local oStruCUX  := FWFormStruct( 2, 'CUX' )  
Local oStruCAA  := FWFormStruct( 2, 'CAA' )   
Local oStruCZO  := FWFormStruct( 2, 'CZO' )  

Local oModel := FWLoadModel( 'TAFA066' )
Local oView  := FWFormView():New()

oView:SetModel( oModel )

oView:AddField( 'VIEW_C46', oStruC46, 'MODEL_C46' )
oView:AddGrid ( 'VIEW_C47', oStruC47, 'MODEL_C47' )
oView:AddGrid ( 'VIEW_C48', oStruC48, 'MODEL_C48' )
oView:AddGrid ( 'VIEW_C4C', oStruC4C, 'MODEL_C4C' )
oView:AddGrid ( 'VIEW_CUX', oStruCUX, 'MODEL_CUX' )
oView:AddGrid ( 'VIEW_CAA', oStruCAA, 'MODEL_CAA' )
oView:AddGrid ( 'VIEW_CZO', oStruCZO, 'MODEL_CZO' ) 

oView:EnableTitleView( 'VIEW_C46', STR0001 ) //"Consolidação da Contribuição do Período"	

oView:CreateHorizontalBox( 'FIELDSC46' , 30 )          
oView:CreateHorizontalBox( 'PANFOLDER1', 70 )

oView:CreateFolder( 'FOLDER1', 'PANFOLDER1' )
oView:AddSheet( 'FOLDER1', 'ABA01', STR0002 ) //"Detalhamento Código Receita" 
oView:CreateHorizontalBox( 'GRIDC47', 100,,, 'FOLDER1', 'ABA01' )
         
oView:AddSheet( 'FOLDER1', 'ABA02', STR0003 ) //"Detalhamento Contribuição Período" 
oView:CreateHorizontalBox( 'GRIDC48', 20,,, 'FOLDER1', 'ABA02' )
oView:CreateHorizontalBox( 'TELAFOLDERS', 80,,, 'FOLDER1', 'ABA02' )

oView:CreateFolder( 'FOLDERS', 'TELAFOLDERS' )
oView:AddSheet( 'FOLDERS', 'ABA01', STR0004 ) //"Composição Base de Cálculo" 
oView:CreateHorizontalBox( 'GRIDC4C', 100,,, 'FOLDERS', 'ABA01' )

oView:AddSheet( 'FOLDERS', 'ABA02', STR0005 ) //"Ajustes da Contribuição" 
oView:CreateHorizontalBox( 'GRIDCUX', 30,,, 'FOLDERS', 'ABA02' )
oView:CreateHorizontalBox( 'TELAFOLDERS2', 70,,, 'FOLDERS', 'ABA02' )

oView:AddSheet( 'FOLDERS', 'ABA03', STR0006 ) //"Informações Adicionais Diferimento" 
oView:CreateHorizontalBox( 'GRIDCZO', 100,,, 'FOLDERS', 'ABA03' )

oView:CreateFolder( 'FOLDERS2', 'TELAFOLDERS2' )
oView:AddSheet( 'FOLDERS2', 'ABA01', STR0007 ) //"Detalhamento Ajustes Contribuição" 
oView:CreateHorizontalBox( 'GRIDCAA', 100,,, 'FOLDERS2', 'ABA01' )

If TamSX3("CAA_CODCTA")[1] == 36
	oStruCAA:RemoveField( "CAA_CODCTA")
	oStruCAA:SetProperty( "CAA_CTACTB", MVC_VIEW_ORDEM, "17" )
EndIf	
oView:SetOwnerView( 'VIEW_C46', 'FIELDSC46' )
oView:SetOwnerView( 'VIEW_C47', 'GRIDC47'   )
oView:SetOwnerView( 'VIEW_C48', 'GRIDC48'   )
oView:SetOwnerView( 'VIEW_C4C', 'GRIDC4C'   ) 
oView:SetOwnerView( 'VIEW_CUX', 'GRIDCUX'   )
oView:SetOwnerView( 'VIEW_CAA', 'GRIDCAA'   )
oView:SetOwnerView( 'VIEW_CZO', 'GRIDCZO'   )

Return ( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} Taf066Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacões 

lJob - Informa se foi chamado por Job

@return .T.

@author Rodrigo Aguilar
@since 20/10/2014
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function Taf066Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro   := {}
Local cChave     := ""                                                                                                                         
Local nVlrContP := 0 
Local cID:= "" 

Default lJob := .F.

DbSelectArea( "C47" )
C47->( dbSetorder(1) )

DbSelectArea( "C48" )
C48->( dbSetorder(1) )

DbSelectArea( "C4C" )
C4C->( dbSetorder(1) )

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C46->( Recno() )

If (C46->C46_STATUS $ (' 1'))

	If Empty(C46->C46_PERIOD)
		aAdd(aLogErro,{"C46_PERIOD","000010","C46",nRecno}) //"Campo Inconsistente ou Vazio"
		 
	ElseIf !(C46->C46_TIPTRB)$("12")
		aAdd(aLogErro,{"C46_TIPTRB","000006","C46",nRecno}) // "Conteúdo do campo não condiz com as opções possíveis" 
	EndIf  
	                                                              			      			       
	If Empty(C46->C46_VLTCNC)
		aAdd(aLogErro,{"C46_VLRECB","000010","C46",nRecno}) //"Campo Inconsistente ou Vazio" 
	EndIf	

	If Empty(C46->C46_VLCRDE)
		aAdd(aLogErro,{"C46_VLCRDE","000010","C46",nRecno}) //"Campo Inconsistente ou Vazio" 
	EndIf	

	If Empty(C46->C46_VLCRDA)
		aAdd(aLogErro,{"C46_VLCRDA","000010","C46",nRecno}) //"Campo Inconsistente ou Vazio" 
	EndIf			
	
	If Empty(C46->C46_VLTNCD)
		aAdd(aLogErro,{"C46_VLRECB","000010","C46",nRecno}) //"Campo Inconsistente ou Vazio" 
	EndIf	
	
	If Empty(C46->C46_VLRENC)
		aAdd(aLogErro,{"C46_VLRENC","000010","C46",nRecno}) //"Campo Inconsistente ou Vazio" 
	EndIf	
	
	If Empty(C46->C46_VLOTNC)
		aAdd(aLogErro,{"C46_VLOTNC","000010","C46",nRecno}) //"Campo Inconsistente ou Vazio" 
	EndIf	
	
	If Empty(C46->C46_VLNCRE)
		aAdd(aLogErro,{"C46_VLNCRE","000010","C46",nRecno}) //"Campo Inconsistente ou Vazio" 
	EndIf	
	
	If Empty(C46->C46_VLCUPE)
		aAdd(aLogErro,{"C46_VLCUPE","000010","C46",nRecno}) //"Campo Inconsistente ou Vazio" 
	EndIf	
	
	If Empty(C46->C46_VLRECU)
		aAdd(aLogErro,{"C46_VLRECU","000010","C46",nRecno}) //"Campo Inconsistente ou Vazio" 
	EndIf	
	
	If Empty(C46->C46_VLOTDE)
		aAdd(aLogErro,{"C46_VLOTDE","000010","C46",nRecno}) //"Campo Inconsistente ou Vazio" 
	EndIf	
	
	If Empty(C46->C46_VLCTCU)
		aAdd(aLogErro,{"C46_VLCTCU","000010","C46",nRecno}) //"Campo Inconsistente ou Vazio" 
	EndIf	
	
	If Empty(C46->C46_VLTCNT)
		aAdd(aLogErro,{"C46_VLTCNT","000010","C46",nRecno}) //"Campo Inconsistente ou Vazio" 
	EndIf	
		
	cID:= C46->C46_ID
	If C47->( MsSeek( xFilial( "C47" ) + cID ) )	 	
	 	While (!C47->(Eof()) .And. cID == C47->C47_ID) 
	 		 			
			If Empty(C47->C47_NUMCMP)
				aAdd(aLogErro,{"C47_NUMCMP","000010","C46",nRecno}) //"Campo Inconsistente ou Vazio"			
			EndIf	  
							        
			If Empty(C47->C47_CODREC)
				aAdd(aLogErro,{"C47_CODREC","000010","C46",nRecno}) //"Campo Inconsistente ou Vazio" 
			EndIf	    	
						 					    			
			C47->(dbSkip())			
	 	Enddo    
    EndIf

	If C48->( MsSeek( xFilial( "C48" ) + cID ) )	 	
	 	While (!C48->(Eof()) .And. cID == C48->C48_ID) 
	 		 			
			If Empty(C48->C48_CODCON)
				aAdd(aLogErro,{"C48_CODCON","000010","C46",nRecno}) //"Campo Inconsistente ou Vazio"			
			Else
				xValRegTab("C1C",C48->C48_CODCON,3,,@aLogErro,, { "C48", "C48_CODCON", nRecno } )				
			EndIf	  

			If Empty(C48->C48_VLRCBR)
				aAdd(aLogErro,{"C48_VLRCBR","000010","C46",nRecno}) //"Campo Inconsistente ou Vazio" 
			EndIf	    								           	

			If Empty(C48->C48_VLBCCT)
				aAdd(aLogErro,{"C48_VLBCCT","000010","C46",nRecno}) //"Campo Inconsistente ou Vazio"
			EndIf	    								      

			If Empty(C48->C48_VLRCBR)
				aAdd(aLogErro,{"C48_VLRCBR","000010","C46",nRecno}) //"Campo Inconsistente ou Vazio" 
			EndIf	    								      			

			If Empty(C48->C48_VLCTAP)
				aAdd(aLogErro,{"C48_VLCTAP","000010","C46",nRecno}) //"Campo Inconsistente ou Vazio" 
			EndIf	    					
			
			If Empty(C48->C48_VLALAC)
				aAdd(aLogErro,{"C48_VLALAC","000010","C46",nRecno}) //"Campo Inconsistente ou Vazio" 
			EndIf	    					

			If Empty(C48->C48_VLCTPE)
				aAdd(aLogErro,{"C48_VLCTPE","000010","C46",nRecno}) //"Campo Inconsistente ou Vazio" 
			EndIf	    								      			
						      						      									 					    			
			C48->(dbSkip())			
	 	Enddo    
    EndIf    

	If C4C->( MsSeek( xFilial( "C4C" ) + cID ) )
	 	
	 	While (!C4C->(Eof()) .And. cID == C4C->C4C_ID)    					

			If Empty(C4C->C4C_INDCOO)
				aAdd(aLogErro,{"C4C_INDCOO","000010","C46",nRecno}) //"Campo Inconsistente ou Vazio" 
			EndIf	    								      			

			If Empty(C4C->C4C_VLBCCT)
				aAdd(aLogErro,{"C4C_VLBCCT","000010","C46",nRecno}) //"Campo Inconsistente ou Vazio" 
			EndIf	    					
			
			If Empty(C4C->C4C_VLBCFI)
				aAdd(aLogErro,{"C4C_VLBCFI","000010","C46",nRecno}) //"Campo Inconsistente ou Vazio" 
			EndIf	    				
												      						      									 					    			
			C4C->(dbSkip())			
	 	Enddo    
    EndIf 	 
	 
	If CUX->( MsSeek( xFilial( "CUX" ) + cID ) )
	 	
	 	While (!CUX->(Eof()) .And. cID == CUX->CUX_ID)    					

			If Empty(CUX->CUX_INDAJU)
				aAdd(aLogErro,{"CUX_INDAJU","000010","C46",nRecno}) //"Campo Inconsistente ou Vazio" 
			EndIf	    								      					

			If Empty(CUX->CUX_VLRAJU)
				aAdd(aLogErro,{"CUX_VLRAJU","000010","C46",nRecno}) //"Campo Inconsistente ou Vazio" 
			EndIf	    								      

			If Empty(CUX->CUX_CODAJU)
				aAdd(aLogErro,{"CUX_CODAJU","000010","C46",nRecno}) //"Campo Inconsistente ou Vazio" 
			Else
				xValRegTab("C1D",CUX->CUX_CODAJU,3,,@aLogErro,, { "C46", "CUX_CODAJU", nRecno } )
			EndIf	    								      
																		      						      									 					    			
			CUX->(dbSkip())			
	 	Enddo    
    EndIf

	If CAA->( MsSeek( xFilial( "CAA" ) + cID ) )
	 	
	 	While (!CAA->(Eof()) .And. cID == CAA->CAA_ID)    					

			If Empty(CAA->CAA_DETVAL)
				aAdd(aLogErro,{"CAA_DETVAL","000010","C46",nRecno}) //"Campo Inconsistente ou Vazio" 
			EndIf	    								      					   								      

			If Empty(CAA->CAA_CSTPC)
				aAdd(aLogErro,{"CAA_CSTPC","000010","C46",nRecno}) //"Campo Inconsistente ou Vazio" 
			Else
				xValRegTab("C17",CAA->CAA_CSTPC,3,,@aLogErro,, { "C46", "CAA_CSTPC", nRecno } )
			EndIf	    					

			If Empty(CAA->CAA_DTAJUS)
				aAdd(aLogErro,{"CAA_DTAJUS","000010","C46",nRecno}) //"Campo Inconsistente ou Vazio" 
			EndIf

			If Empty(CAA->CAA_CODCTA)
				aAdd(aLogErro,{"CAA_CODCTA","000010","C46",nRecno}) //"Campo Inconsistente ou Vazio" 
			Else
				xValRegTab("C1O",CAA->CAA_CODCTA,3,,@aLogErro,, { "C46", "CAA_CODCTA", nRecno } )
			EndIf
																											      						      									 					    			
			CAA->(dbSkip())			
	 	Enddo    
    EndIf

	If CZO->( MsSeek( xFilial( "CZO" ) + cID ) )
	 	
	 	While (!CZO->(Eof()) .And. cID == CZO->CZO_ID)    					

			If Empty(CZO->CZO_CNPJ)
				aAdd(aLogErro,{"CZO_CNPJ","000010","C46",nRecno}) //"Campo Inconsistente ou Vazio" 
			EndIf

			If Empty(CZO->CZO_VLVEND)
				aAdd(aLogErro,{"CZO_VLVEND","000010","C46",nRecno}) //"Campo Inconsistente ou Vazio" 
			EndIf			

			If Empty(CZO->CZO_VLNRPR)
				aAdd(aLogErro,{"CZO_VLNRPR","000010","C46",nRecno}) //"Campo Inconsistente ou Vazio" 
			EndIf				    		
			
			If Empty(CZO->CZO_VLCTDI)
				aAdd(aLogErro,{"CZO_VLCTDI","000010","C46",nRecno}) //"Campo Inconsistente ou Vazio" 
			EndIf							
			
			If Empty(CZO->CZO_VLCRDI)
				aAdd(aLogErro,{"CZO_VLCRDI","000010","C46",nRecno}) //"Campo Inconsistente ou Vazio" 
			EndIf	
			
			If Empty(CZO->CZO_CODCRE)
				aAdd(aLogErro,{"CZO_CODCRE","000010","C46",nRecno}) //"Campo Inconsistente ou Vazio" 
			Else
				xValRegTab("C4D",CZO->CZO_CODCRE,3,,@aLogErro,, { "C46", "CZO_CODCRE", nRecno } )
			EndIf							      					   								      
																											      						      									 					    			
			CZO->(dbSkip())			
	 	Enddo    
    EndIf
    	 
	//Atualizo o Status do Registro
	If Len(aLogErro)>0	
	
		//Utilizo RecLock, pois o SETVALUE somente funciona em campos USADOS
		RecLock("C46",.F.)
	    	C46->C46_STATUS := "1" 
	    C46->( MsUnlock() )    
	Else
		RecLock("C46",.F.)
	    	C46->C46_STATUS := 	"0" 
	    C46->( MsUnlock() )        
	EndIf

Else
	AADD(aLogErro,{"C46_ID","000305", "C46", nRecno }) //Registros válidos não podem ser validados novamente
EndIf	

If !lJob
	xValLogEr(aLogErro)
EndIf

Return(aLogErro)