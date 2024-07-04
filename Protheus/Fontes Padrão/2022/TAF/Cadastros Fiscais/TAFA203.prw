#INCLUDE "PROTHEUS.CH"                                                                                                                                                                                                                                                                                    
#INCLUDE "FWMVCDEF.CH"                                                                                                                                                                                                                                                                                    
#INCLUDE "TAFA203.CH"                                                                                                                                                                                                                                                                                     
                                                                                                                                                                                                                                                                                                          
//------------------------------------------------------------------                                                                                                                                                                                                                                     
/*/{Protheus.doc} TAFA203                                                                                                                                                                                                                                                                                 
Cadastro MVC - Consolidado 
             - C860 C7P - Identificação do Equipamento SAT-CF-E                                                                                                                                                                                                                                                                         
             - C890 C7T - Resumo Diário do CF-e (Código 59) 
             
                                                                                                                                                                                                                                                                                                          
@author Ana Laura Olegini                                                                                                                                                                                                                                                                                   
@since 05/02/2013                                                                                                                                                                                                                                                                                         
@version 1.0                                                                                                                                                                                                                                                                                            
/*/                                                                                                                                                                                                                                                                                                       
//------------------------------------------------------------------                                                                                                                                                                                                                                     
Function TAFA203                                                                                                                                                                                                                                                                                          
Local	oBrw	:= FWmBrowse():New()                                                                                                                                                                                                                                                                          
                                                                                                                                                                                                                                                                                                          
oBrw:SetDescription( STR0001 ) //"Consolidado - Identificação do Equipamento SAT-CF-E"                                                                                                                                                                                                                                                     
oBrw:SetAlias( 'C7P' )                                                                                                                                                                                                                                                                                    
oBrw:SetMenuDef( 'TAFA203' )                                                                                                                                                                                                                                                                              
oBrw:Activate()                                                                                                                                                                                                                                                                                           
                                                                                                                                                                                                                                                                                                          
Return                                                                                                                                                                                                                                                                                                    
//------------------------------------------------------------------                                                                                                                                                                                                                                     
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

Aadd( aFuncao, { "" , "Taf203Vld" , "2" } )

lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If lMenuDif
	ADD OPTION aRotina Title "Visualizar" Action 'VIEWDEF.TAFA203' OPERATION 2 ACCESS 0
Else
	aRotina	:=	xFunMnuTAF( "TAFA203" , , aFuncao)
EndIf                                                                                                                                                                                                                                                                                        
Return (aRotina)                                                                                                                                                                                                                                                                            
                                                                                                                                                                                                                                                                                                          
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
                                                                                                                                                                                                                                                                               
Local oStruC7P 	:= 	FWFormStruct( 1, 'C7P' ) //"C860 - Identificação do Equipamento SAT-CF-E"                                                                                                                                                                                                                                                             
              
Local oStruC7Q 	:= 	FWFormStruct( 1, 'C7Q' ) //"C870 - Resumo Diário – PIS/PASEP E COFINS"                
Local oStruC7R 	:= 	FWFormStruct( 1, 'C7R' ) //"C880 - Resumo Diário – PIS/PASEP E COFINS Unidade De Medida De Produto"                
Local oStruC7S 	:= 	FWFormStruct( 1, 'C7S' ) //"C890 - Processo Referenciado" 

Local oStruC7T 	:= 	FWFormStruct( 1, 'C7T' ) //"C890 - Resumo Diário do CF-E"                 

Local 	oModel 	:=  MPFormModel():New( 'TAFA203' , , , {|oModel| SaveModel( oModel ) } )
                                                                                                                                                                                                                                                                                                          
oModel:AddFields('MODEL_C7P', /*cOwner*/, oStruC7P )

oModel:AddGrid('MODEL_C7Q', 'MODEL_C7P', oStruC7Q)  
oModel:GetModel( 'MODEL_C7Q' ):SetUniqueLine( { 'C7Q_CFOP' , 'C7Q_IT'} )

oModel:AddGrid('MODEL_C7R', 'MODEL_C7P', oStruC7R)  
oModel:GetModel( 'MODEL_C7R' ):SetUniqueLine( { 'C7R_IT' , 'C7R_CFOP' } )
oModel:GetModel( 'MODEL_C7R' ):SetOptional( .T. )

oModel:AddGrid('MODEL_C7S', 'MODEL_C7P', oStruC7S)  
oModel:GetModel( 'MODEL_C7S' ):SetUniqueLine( { 'C7S_NUMPRO' } )
oModel:GetModel( 'MODEL_C7S' ):SetOptional( .T. )

oModel:AddGrid('MODEL_C7T', 'MODEL_C7P', oStruC7T)              
oModel:GetModel( 'MODEL_C7T' ):SetUniqueLine( { 'C7T_CSTICM' , 'C7T_CFOP' , 'C7T_ALQICM' } )
oModel:GetModel( 'MODEL_C7T' ):SetOptional( .T. )

oModel:SetRelation( 'MODEL_C7Q' , { { 'C7Q_FILIAL' , 'xFilial( "C7Q" )' } , { 'C7Q_ID' , 'C7P_ID' } } , C7Q->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_C7R' , { { 'C7R_FILIAL' , 'xFilial( "C7R" )' } , { 'C7R_ID' , 'C7P_ID' } } , C7R->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_C7S' , { { 'C7S_FILIAL' , 'xFilial( "C7S" )' } , { 'C7S_ID' , 'C7P_ID' } } , C7S->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_C7T' , { { 'C7T_FILIAL' , 'xFilial( "C7T" )' } , { 'C7T_ID' , 'C7P_ID' } } , C7T->( IndexKey( 1 ) ) )

oModel:GetModel( "MODEL_C7P" ):SetPrimaryKey( { "C7P_DTMOV" } )                                                                                                                                                                                                                                          
                                                                                                                                                                                                                                                                                                          
Return oModel                                                                                                                                                                                                                                                                                             
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
                                                                                                                                                                                                                                                                         
Local oModel 	  := 	FWLoadModel( 'TAFA203' ) 
Local oStruC7P 	:= 	FWFormStruct( 2, 'C7P' ) //"C860 - Identificação do Equipamento SAT-CF-E"                                                                                                                                                                                                                               

Local oStruC7Q 	:= 	FWFormStruct( 2, 'C7Q' ) //"C870 - Resumo Diário – PIS/PASEP E COFINS"                             
Local oStruC7R 	:= 	FWFormStruct( 2, 'C7R' ) //"C880 - Resumo Diário – PIS/PASEP E COFINS Unidade De Medida De Produto"
Local oStruC7S 	:= 	FWFormStruct( 2, 'C7S' ) //"C890 - Processo Referenciado"                                          

Local oStruC7T 	:= 	FWFormStruct( 2, 'C7T' ) //"C890 - Resumo Diário do CF-E"

Local oView 	  := 	FWFormView():New()                                                                                                                                                                                                                                                                      

oStruC7P:SetProperty( 'C7P_CODMOD'   , MVC_VIEW_LOOKUP   , "C01" )
oStruC7T:SetProperty( 'C7T_CSTICM'   , MVC_VIEW_LOOKUP   , "C14" )
                                                                                                                                                                                                                                       
oView:SetModel( oModel )                                                                                                                                                                                                                                                                               

oView:AddField( 'VIEW_C7P', oStruC7P, 'MODEL_C7P' )                                                                                                                                                                                                                                                       
oView:EnableTitleView( 'VIEW_C7P', STR0002 )         //"C860 - Identificação do Equipamento SAT-CF-E"                                                                                                                                                                                                                               

oView:AddGrid( 'VIEW_C7Q', oStruC7Q, 'MODEL_C7Q' )   //"C870 - Resumo Diário – PIS/PASEP E COFINS" 
oView:EnableTitleView( 'VIEW_C7Q', STR0003 )

oView:AddGrid( 'VIEW_C7R', oStruC7R, 'MODEL_C7R' )
oView:EnableTitleView( 'VIEW_C7R', STR0004 )         //"C880 - Resumo Diário – PIS/PASEP E COFINS Unidade De Medida De Produto"

oView:AddGrid( 'VIEW_C7S', oStruC7S, 'MODEL_C7S' )
oView:EnableTitleView( 'VIEW_C7S', STR0005 )         //"C890 - Processo Referenciado"      

oView:AddGrid ( 'VIEW_C7T', oStruC7T, 'MODEL_C7T' )  //"C890 - Resumo Diário do CF-E"
oView:EnableTitleView( 'VIEW_C7T', STR0006 ) 

oView:CreateHorizontalBox( 'FIELDSC7P'  , 30 )                                                                                                                                                                                                                                                              
oView:CreateHorizontalBox( 'FOLDERGERAL', 70 ) 

oView:CreateFolder( 'FOLDER1', 'FOLDERGERAL' )

oView:AddSheet( 'FOLDER1', 'ABA02', STR0003 ) 
oView:CreateHorizontalBox( 'GRIDC7Q', 100,,, 'FOLDER1', 'ABA02' )

oView:AddSheet( 'FOLDER1', 'ABA03', STR0004 ) 
oView:CreateHorizontalBox( 'GRIDC7R', 100,,, 'FOLDER1', 'ABA03' )

oView:AddSheet( 'FOLDER1', 'ABA04', STR0005 ) 
oView:CreateHorizontalBox( 'GRIDC7S', 100,,, 'FOLDER1', 'ABA04' )

oView:AddSheet( 'FOLDER1', 'ABA05', STR0006 ) 
oView:CreateHorizontalBox( 'GRIDC7T', 100,,, 'FOLDER1', 'ABA05' )

oView:SetOwnerView( 'VIEW_C7P', 'FIELDSC7P' )                                                                                                                                                                                                                                                             

oView:SetOwnerView( 'VIEW_C7Q', 'GRIDC7Q' )
oView:SetOwnerView( 'VIEW_C7R', 'GRIDC7R' )
oView:SetOwnerView( 'VIEW_C7S', 'GRIDC7S' )

oView:SetOwnerView( 'VIEW_C7T', 'GRIDC7T' )

If TamSX3("C7Q_CTA")[1] == 36
	oStruC7Q:RemoveField("C7Q_CTA")
	oStruC7Q:SetProperty("C7Q_CTACTB", 	MVC_VIEW_ORDEM, "18")
EndIf
If TamSX3("C7Q_IT")[1] == 36
	oStruC7Q:RemoveField("C7Q_IT")
	oStruC7Q:SetProperty("C7Q_ITEM", 	MVC_VIEW_ORDEM, "06")
EndIf

If TamSX3("C7R_CTA")[1] == 36
	oStruC7R:RemoveField("C7R_CTA")		
	oStruC7R:SetProperty("C7R_CTACTB", 	MVC_VIEW_ORDEM, "18")	
EndIf   
If TamSX3("C7R_IT")[1] == 36
	oStruC7R:RemoveField("C7R_IT")		
	oStruC7R:SetProperty("C7R_ITEM", 	MVC_VIEW_ORDEM, "03")	
EndIf       

Return oView          

//-------------------------------------------------------------------
/*/{Protheus.doc} Taf203Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacões 

lJob - Informa se foi chamado por Job

@return .T.

@author Paulo V.B. Santana
@since 24/02/2014
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function Taf203Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro   := {}
Local cChave     := ""                                                                                                                         
Local nVlrContP := 0 
Local cID:= "" 

Default lJob := .F.

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C7P->( Recno() )

If (C7P->C7P_STATUS $ (' 1'))                             
	If !Empty(C7P->C7P_CODMOD)
		cChave := C7P->C7P_CODMOD
		xValRegTab("C01",cChave,3,,@aLogErro,, {"C7P", "C7P_CODMOD", nRecno } )     
	EndIf                

	dbSelectArea("C7Q")
	dbSetorder(1)
	If dbSeek(xFilial('C7Q')+C7P->C7P_ID)
		cID:=C7Q->C7Q_ID
		While  (cID==C7Q->C7Q_ID) 
			If !Empty(C7Q->C7Q_CFOP)
				cChave := C7Q->C7Q_CFOP
				xValRegTab("C0Y",cChave,3,,@aLogErro,, {"C7P", "C7Q_CFOP", nRecno })     
			EndIf                 
			If !Empty(C7Q->C7Q_IT)
				cChave := C7Q->C7Q_IT
				xValRegTab("C1L",cChave,3,,@aLogErro,, {"C7P", "C7Q_IT", nRecno })     
			EndIf   
			If !Empty(C7Q->C7Q_CTA)
				cChave := C7Q->C7Q_CTA
				xValRegTab("C1O",cChave,3,,@aLogErro,, {"C7P", "C7Q_CTA", nRecno })     
			EndIf   
			cID:=C7Q->C7Q_ID
			C7Q->(dbSkip())     
		EndDo 
	Endif	                          
	
	dbSelectArea("C7R")
	C7R->(dbSetorder(1))
	If dbSeek(xFilial('C7R')+C7P->C7P_ID)
		cID:=C7R->C7R_ID
		While  (cID==C7R->C7R_ID) 
			If !Empty(C7R->C7R_IT)
				cChave := C7R->C7R_IT
				xValRegTab("C1L",cChave,3,,@aLogErro,, {"C7P", "C7R_IT", nRecno })     
			EndIf   
			If !Empty(C7R->C7R_CFOP)
				cChave := C7R->C7R_CFOP
				xValRegTab("C0Y",cChave,3,,@aLogErro,, {"C7P", "C7R_CFOP", nRecno })     
			EndIf                 
			If !Empty(C7R->C7R_CTA)
				cChave := C7R->C7R_CTA
				xValRegTab("C1O",cChave,3,,@aLogErro,, {"C7P", "C7R_CTA", nRecno })     
			EndIf          
			cID:=C7R->C7R_ID
			C7R->(dbSkip())    
		EndDo 
	Endif	     
	
	dbSelectArea("C7S")
	C7S->(dbSetorder(1))
	If dbSeek(xFilial('C7S')+C7P->C7P_ID)
		cID:=C7S->C7S_ID
		While  (cID==C7S->C7S_ID) 
			If !Empty(C7S->C7S_NUMPRO)
				cChave := C7S->C7S_NUMPRO
				xValRegTab("C1G",cChave,3,,@aLogErro,, {"C7P", "C7S_NUMPRO", nRecno })     
			EndIf   
			cID:=C7S->C7S_ID
			C7S->(dbSkip())    
		EndDo 
	Endif	

	dbSelectArea("C7T")
	C7T->(dbSetorder(1))
	If dbSeek(xFilial('C7T')+C7P->C7P_ID)
		cID:=C7T->C7T_ID
		While  (cID==C7T->C7T_ID) 
			If !Empty(C7T->C7T_ORIMER)
				cChave := C7T->C7T_ORIMER
				xValRegTab("C03",cChave,3,,@aLogErro,, {"C7P", "C7T_ORIMER", nRecno })     
			EndIf   
			If !Empty(C7T->C7T_CFOP)
				cChave := C7T->C7T_CFOP
				xValRegTab("C0Y",cChave,3,,@aLogErro,, {"C7P", "C7T_CFOP", nRecno })     
			EndIf                 
			If !Empty(C7T->C7T_CODOBS)
				cChave := C7T->C7T_CODOBS
				xValRegTab("C3R",cChave,3,,@aLogErro,, {"C7P", "C7T_CODOBS", nRecno })     
			EndIf          
			cID:=C7T->C7T_ID
			C7T->(dbSkip())    
		EndDo 
	Endif	

	//ATUALIZO O STATUS DO REGISTRO
	If Len(aLogErro)>0	
		//Utilizo RecLock, pois o SETVALUE somente funciona em campos USADOS
		RecLock("C7P",.F.)
		    C7P->C7P_STATUS := "1" 
	    C7P->( MsUnlock() )    
	Else
		RecLock("C7P",.F.)
	    	C7P->C7P_STATUS := "0" 
	    C7P->( MsUnlock() )        
	EndIf
	
	/*----------------------------------------------------------------------
		O DbselectArea abaixo é utilizado para proteção de dicionario.
		Ao remove-lo deve-se remover o TAFColumnPos.
	-----------------------------------------------------------------------*/
	//TRATAMENTO PARA DICIONARIO DESATUALIZADO(12.1.8)
	DbSelectArea("C7Q")	
  	If TAFColumnPos( 'C7Q_VLDESC' )
  	
		//VALIDAÇÃO DO CAMPO VL_BC_PIS
		("C7Q")->( DbSetOrder( 1 ) )
		("C7Q")->( DbSeek ( C7P->C7P_FILIAL+C7P->C7P_ID) )
	
		//Laço para geração dos registros filhos
		While C7Q->(!Eof()) .And. (xFilial("C7Q")+C7Q->C7Q_FILIAL+C7Q->C7Q_ID == xFilial("C7P")+C7P->C7P_FILIAL+C7P->C7P_ID)
			
			If C7Q->C7Q_BCPIS <> (C7Q->C7Q_VLRITE - C7Q->C7Q_VLDESC)
				AADD(aLogErro,{"C7Q_BCPIS","000675", "C7P", nRecno }) //O valor informado deve corresponder ao valor informado no Campo (Vlr. Item) menos as exclusões de base de cálculo informadas no Campo (Vl. Excl/Desc)
			EndIf
					
			C7Q->( dbSkip() )
		EndDo
	EndIf
	C7Q->(DbCloseArea())
	

Else
	AADD(aLogErro,{"C7P_ID","000305", "C46", nRecno }) //Registros válidos não podem ser validados novamente
EndIf	

If !lJob
	xValLogEr(aLogErro)
EndIf

Return(aLogErro)

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo
                                                                                                                               
@param  oModel -> Modelo de dados
@return .T.

@author Rodrigo Aguilar
@since 22/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

Local 	nOperation 	:= 	oModel:GetOperation()  

Begin Transaction
	If nOperation == MODEL_OPERATION_UPDATE 
		TAFAltStat( 'C7P', " " ) //Limpa o Status do Registro, tornando possível nova validação.
	Endif          	
	FwFormCommit( oModel )			
End Transaction

Return .T.     