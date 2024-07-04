#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA065.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA065
Det Base  Calc Cred Apur Per PIS/COFINS
Ajuste da Contribuição do Pis/Cofins 

@author: 
02/08/2012 - Marcio Nunes
03/10/2014 - Alterado por Rodrigo Aguilar

@since 02/08/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA065

Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //"Crédito Relativo ao Período" 
oBrw:SetAlias( 'C49')
oBrw:SetMenuDef( 'TAFA065' )
oBrw:Activate()  

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author:
02/08/2012 - Marcio Nunes
03/10/2014 - Alterado por Rodrigo Aguilar

@since 02/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf065Vld" , "2" } )

lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If lMenuDif
	ADD OPTION aRotina Title "Visualizar" Action 'VIEWDEF.TAFA065' OPERATION 2 ACCESS 0
Else
	aRotina	:=	xFunMnuTAF( "TAFA065" , , aFuncao)
EndIf                                     

Return( aRotina ) 

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author: 
02/08/2012 - Marcio Nunes
03/10/2014 - Alterado por Rodrigo Aguilar

@since 02/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local 	oStruC49	:= 	FWFormStruct( 1, 'C49' )
Local 	oStruCZM	:= 	FWFormStruct( 1, 'CZM' )
Local 	oStruC4A	:= 	FWFormStruct( 1, 'C4A' ) 
Local 	oStruCA9	:= 	FWFormStruct( 1, 'CA9' )
Local 	oModel 	:= 	MPFormModel():New( 'TAFA065',,,{ |oModel| SaveModel( oModel ) } )

oModel:AddFields('MODEL_C49', /*cOwner*/, oStruC49)

oModel:AddGrid(  'MODEL_CZM', 'MODEL_C49', oStruCZM )
oModel:GetModel( 'MODEL_CZM' ):SetOptional( .T. )
oModel:GetModel( 'MODEL_CZM' ):SetUniqueLine({ 'CZM_NATBC' , 'CZM_CST' })

oModel:SetRelation( 'MODEL_CZM', { { 'CZM_FILIAL', 'xFilial( "CZM" )' } , { 'CZM_ID' , 'C49_ID' }}, CZM->( IndexKey( 1 ) ) )

oModel:AddGrid('MODEL_C4A', 'MODEL_C49', oStruC4A)
oModel:GetModel( 'MODEL_C4A' ):SetOptional( .T. )
oModel:GetModel( 'MODEL_C4A' ):SetUniqueLine({ 'C4A_INDAJU' , 'C4A_CAJAPC' , 'C4A_NUMDOC' }) 

oModel:SetRelation( 'MODEL_C4A', { { 'C4A_FILIAL', 'xFilial( "C4A" )' } , { 'C4A_ID' , 'C49_ID' }}, C4A->( IndexKey( 1 ) ) )

oModel:AddGrid('MODEL_CA9', 'MODEL_C4A', oStruCA9)
oModel:GetModel( 'MODEL_CA9' ):SetOptional( .T. )
oModel:GetModel( 'MODEL_CA9' ):SetUniqueLine({ 'CA9_CSTPC' , 'CA9_DETBCC' , 'CA9_DTAJUS', 'CA9_CODCTA'})                                                                                                              

oModel:SetRelation( 'MODEL_CA9', { { 'CA9_FILIAL', 'xFilial( "CA9" )' } , { 'CA9_ID' , 'C49_ID' },{ 'CA9_INDAJU' , 'C4A_INDAJU' },{ 'CA9_CAJAPC' , 'C4A_CAJAPC' }, { 'CA9_NUMDOC' , 'C4A_NUMDOC' } }, CA9->( IndexKey( 1 ) ) )

oModel:GetModel('MODEL_C49'):SetPrimaryKey( { 'C49_PERIOD', 'C49_TIPTRB', 'C49_CODCRD', 'C49_INDCOR', 'C49_ALIQPC', 'C49_ALPCQT', 'C49_INDDCR' } )

Return oModel
                                                                                                                              
//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo
                                                                                                                               
@param  oModel -> Modelo de dados
@return .T.

@author:
24/02/2014 - Paulo Sérgio V.B. Santana
03/10/2014 - Alterado por Rodrigo Aguilar

@since 24/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

Local 	nOperation 	:= 	oModel:GetOperation()  
Begin Transaction

	If nOperation == MODEL_OPERATION_UPDATE 
		TAFAltStat( 'C49', " " ) //Limpa o Status do Registro, tornando possível nova validação.
	Endif          
	
	FwFormCommit( oModel )		
	
End Transaction

Return .T.  

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author:
02/08/2012 - Marcio Nunes
03/10/2014 - Alterado por Rodrigo Aguilar

@since 02/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel      :=	FWLoadModel( 'TAFA065' )
Local oStruC49 	:= 	FWFormStruct( 2, 'C49' )
Local oStruCZM 	:= 	FWFormStruct( 2, 'CZM' )
Local oStruC4A 	:= 	FWFormStruct( 2, 'C4A' )
Local oStruCA9 	:= 	FWFormStruct( 2, 'CA9' )
Local oView 		:= 	FWFormView():New()

oView:SetModel( oModel )

oView:AddField( 'VIEW_C49', oStruC49, 'MODEL_C49' )
oView:AddGrid ( 'VIEW_CZM', oStruCZM, 'MODEL_CZM' )
oView:AddGrid ( 'VIEW_C4A', oStruC4A, 'MODEL_C4A' )
oView:AddGrid ( 'VIEW_CA9', oStruCA9, 'MODEL_CA9' )

oView:EnableTitleView( 'VIEW_C49', STR0001 ) //"Crédito Relativo ao Período"

oView:CreateHorizontalBox( 'FIELDSC49' , 40 )          
oView:CreateHorizontalBox( 'PANFOLDER1', 60 )

oView:CreateFolder( 'FOLDER1', 'PANFOLDER1' )
oView:AddSheet( 'FOLDER1', 'ABA01', STR0002 ) //"Detalhamento Base Cálculo" 
oView:CreateHorizontalBox( 'GRIDCZM', 100,,, 'FOLDER1', 'ABA01' )

oView:AddSheet( 'FOLDER1', 'ABA02', STR0003 ) //Ajuste do Crédito Apurado
oView:CreateHorizontalBox( 'GRIDC4A', 50,,, 'FOLDER1', 'ABA02' )
oView:CreateHorizontalBox( 'TELAFOLDERS', 50,,, 'FOLDER1', 'ABA02' )

oView:CreateFolder( 'FOLDERS', 'TELAFOLDERS' )
oView:AddSheet( 'FOLDERS', 'ABA01', STR0004 ) //"Detalhamento dos Ajustes do Crédito " 
oView:CreateHorizontalBox( 'GRIDCA9', 100,,, 'FOLDERS', 'ABA01' )                                           

If TamSX3("CA9_CODCTA")[1] == 36
	oStruCA9:RemoveField( "CA9_CODCTA")
	oStruCA9:SetProperty( "CA9_CTACTB", MVC_VIEW_ORDEM, "13" )
EndIf
oView:SetOwnerView( 'VIEW_C49', 'FIELDSC49' )
oView:SetOwnerView( 'VIEW_C4A', 'GRIDC4A' ) 
oView:SetOwnerView( 'VIEW_CA9', 'GRIDCA9' )
oView:SetOwnerView( 'VIEW_CZM', 'GRIDCZM' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} Taf065Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacões 

lJob - Informa se foi chamado por Job

@return .T.

@author:
24/02/2014 - Paulo V.B. Santana
03/10/2014 - Alterado por Rodrigo Aguilar

@since 24/02/2014
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function Taf065Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro := {}
Local cChave   := "" 

Default lJob := .F.

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C49->( Recno() )

If (C49->C49_STATUS $ (' 1'))
	
	//Validação da tabela de Crédito de Pis/Pasep/Cofins relaivo ao período
	If Empty(C49->C49_PERIOD)
		aAdd(aLogErro,{"C49_PERIOD","000010","C49",nRecno}) //"Campo Inconsistente ou Vazio" 
	EndIf
	
	If Empty(C49->C49_TIPTRB)
		aAdd(aLogErro,{"C49_TIPTRB","000010","C49",nRecno}) //"Campo Inconsistente ou Vazio"
		 
	ElseIf !(C49->C49_TIPTRB)$("12")
		aAdd(aLogErro,{"C49_TIPTRB","000006","C49",nRecno}) // "Conteúdo do campo não condiz com as opções possíveis"
		
	EndIf 

	If Empty(C49->C49_CODCRD)
		aAdd(aLogErro,{"C49_CODCRD","000010","C49",nRecno}) //"Campo Inconsistente ou Vazio"
		 
	Else
		cChave := C49->C49_CODCRD
		xValRegTab("C4D",cChave,3,,@aLogErro,, { "C49", "C49_CODCRD", nRecno } )
		     
	EndIf	 
	
	If Empty(C49->C49_INDCOR)
		aAdd(aLogErro,{"C49_INDCOR","000010","C49",nRecno}) //"Campo Inconsistente ou Vazio"
		 
	ElseIf !(C49->C49_INDCOR $ " 01")
		aAdd(aLogErro,{"C49_INDCOR","000006","C49",nRecno}) // "Conteúdo do campo não condiz com as opções possíveis"
		
	EndIf
		
	If Empty(C49->C49_INDCOR)
		aAdd(aLogErro,{"C49_INDCOR","000010","C49",nRecno}) //"Campo Inconsistente ou Vazio"		 
	EndIf
    
    If Empty( C49->C49_VLCRED )
    	aAdd(aLogErro,{"C49_VLCRED","000010","C49",nRecno}) //"Campo Inconsistente ou Vazio"    	
    EndIf     

    If Empty( C49->C49_VLAJAC )
    	aAdd(aLogErro,{"C49_VLAJAC","000010","C49",nRecno}) //"Campo Inconsistente ou Vazio"    	
    EndIf
        
    If Empty( C49->C49_VLAJRD )
    	aAdd(aLogErro,{"C49_VLAJRD","000010","C49",nRecno}) //"Campo Inconsistente ou Vazio"    	
    EndIf    
        
    If Empty( C49->C49_VLCRDF )
    	aAdd(aLogErro,{"C49_VLCRDF","000010","C49",nRecno}) //"Campo Inconsistente ou Vazio"    	
    EndIf    

    If Empty( C49->C49_VLCRDI )
    	aAdd(aLogErro,{"C49_VLCRDI","000010","C49",nRecno}) //"Campo Inconsistente ou Vazio"    	
    EndIf    

    If Empty( C49->C49_INDDCR )
    	aAdd(aLogErro,{"C49_INDDCR","000010","C49",nRecno}) //"Campo Inconsistente ou Vazio"    	
    EndIf    

    If Empty( C49->C49_SLDCRD )
    	aAdd(aLogErro,{"C49_SLDCRD","000010","C49",nRecno}) //"Campo Inconsistente ou Vazio"    	
    EndIf            	
    
   //Validação de Ajustes da Apuracao do credito do PIS/Cofins
	DbSelectArea("C4A")
	DbSetOrder(1)
	If MsSeek(xFilial("C4A")+C49->C49_ID)
	
		While (C4A->( !Eof() ) .And. C4A->C4A_ID == C49->C49_ID)
		
			If Empty(C4A->C4A_INDAJU)
				aAdd(aLogErro,{"C4A_INDAJU","000010","C49",nRecno}) //"Campo Inconsistente ou Vazio"
				 
			ElseIf !(C4A->C4A_INDAJU)$("01")
				aAdd(aLogErro,{"C4A_INDAJU","000006","C49",nRecno}) // "Conteúdo do campo não condiz com as opções possíveis"
				
			EndIf  

			If Empty(C4A->C4A_CAJAPC)
				aAdd(aLogErro,{"C4A_CAJAPC","000010","C49",nRecno}) //"Campo Inconsistente ou Vazio"
				 
			Else 
				cChave := C4A->C4A_CAJAPC
				xValRegTab("C1D",cChave,3,,@aLogErro,, { "C49", "C4A_CAJAPC", nRecno } )
				
			EndIf
									
			If Empty(C4A->C4A_VLAJPC)
				aAdd(aLogErro,{"C4A_VLAJPC","000010","C49",nRecno}) //"Campo Inconsistente ou Vazio" 
			EndIf			
	
			C4A->(dbSkip())	
		EndDo
	EndIf 
	
	//Detalhamento dos ajustes de crédito de Pis/Cofins apurado
	DbSelectArea("CA9")
	DbSetOrder(1)
	If MsSeek(xFilial("CA9")+C49->C49_ID)
		While (!CA9->(Eof()) .And. CA9->CA9_ID == C49->C49_ID)
			
			
			If Empty(CA9->CA9_DETVAL)
				aAdd(aLogErro,{"CA9_DETVAL","000010","C49",nRecno}) //"Campo Inconsistente ou Vazio" 
			EndIf						
			
			If !Empty(CA9->CA9_CSTPC)
				cChave := CA9->CA9_CSTPC
				xValRegTab("C17",cChave,3,,@aLogErro,, { "C49", "CA9_CSTPC", nRecno } )
				
			EndIf	
			
			If !Empty(CA9->CA9_CODCTA)
				cChave := CA9->CA9_CODCTA
				xValRegTab("C1O",cChave,3,,@aLogErro,, { "C49", "CA9_CODCTA", nRecno } )
				
			EndIf		
			
			If Empty(CA9->CA9_DTAJUS)
				aAdd(aLogErro,{"CA9_DTAJUS","000010","C49",nRecno}) //"Campo Inconsistente ou Vazio" 
			EndIf
			
			CA9->(dbSkip())	
		EndDo 
	EndIf
	
	If Len(aLogErro)>0	
			
		//Utilizo RecLock, pois o SETVALUE somente funciona em campos USADOS
		RecLock("C49",.F.)
	    	C49->C49_STATUS := "1" 
	    C49->( MsUnlock() )
	        
	Else
		RecLock("C49",.F.)
	    	C49->C49_STATUS := "0" 
	    C49->( MsUnlock() )
	            
	EndIf

Else
	//Registros válidos não podem ser validados novamente
	AADD(aLogErro,{"C49_ID","000305", "C49", nRecno })   
		
EndIf	

If !lJob
	xValLogEr(aLogErro)
EndIf

Return(aLogErro)
