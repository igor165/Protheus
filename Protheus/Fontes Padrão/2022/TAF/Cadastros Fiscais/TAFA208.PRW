#INCLUDE "PROTHEUS.CH"                                                                                                                                                                                                                                                                                    
#INCLUDE "FWMVCDEF.CH"                                                                                                                                                                                                                                                                                    
#INCLUDE "TAFA208.CH"                                                                                                                                                                                                                                                                                     
                                                                                                                                                                                                                                                                                                          
//-------------------------------------------------------------------                                                                                                                                                                                                                                     
/*/{Protheus.doc} TAFA208                                                                                                                                                                                                                                                                                 
Cadastro MVC 

  - C77   - D695 - Consolidação da Prestação de Serviços;
  - C78   - D696 - Registro Analítico dos Documentos;                                                                                                                                                             
  - C79   - D967 - Registro de Informações de Outras Ufs.                                                                                       
                                                                                                                                                                                                                                                                                                          
@author Ana Laura Olegini                                                                                                                                                                                                                                                                                   
@since 05/02/2013                                                                                                                                                                                                                                                                                         
@version 1.0                                                                                                                                                                                                                                                                                            
/*/                                                                                                                                                                                                                                                                                                       
//-------------------------------------------------------------------                                                                                                                                                                                                                                     
Function TAFA208                                                                                                                                                                                                                                                                                          
Local	oBrw	:= FWmBrowse():New()                                                                                                                                                                                                                                                                          
                                                                                                                                                                                                                                                                                                          
oBrw:SetDescription( STR0001 ) //"D695 - Consolidação da Prestação de Serviços"                                                                                                                                                                                                                                                     
oBrw:SetAlias( 'C77' )                                                                                                                                                                                                                                                                                    
oBrw:SetMenuDef( 'TAFA208' )                                                                                                                                                                                                                                                                              
oBrw:Activate()                                                                                                                                                                                                                                                                                           
                                                                                                                                                                                                                                                                                                          
Return                                                                                                                                                                                                                                                                                                    
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Denis R. de Oliveira
@since 17/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf208Vld" , "2" } )
aRotina	:=	xFunMnuTAF( "TAFA208" , , aFuncao )

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
                                                                                                                                                                                                                                                                               
Local oStruC77 	:= 	FWFormStruct( 1, 'C77' ) //"D695 - Consolidação da Prestação de Serviços"                                                                                                                                                                                                                                                           
Local oStruC78 	:= 	FWFormStruct( 1, 'C78' ) //"D696 - Registro Analítico dos Documentos"                
Local oStruC79 	:= 	FWFormStruct( 1, 'C79' ) //"D967 - Registro de Informações de Outras Ufs"
Local 	oModel 	:=  MPFormModel():New( 'TAFA208' , , , {|oModel| SaveModel( oModel ) } )

Local oModel 	  := 	MPFormModel():New( 'TAFA208' )                                                                                                                                                                                                                                                          
                                                                                                                                                                                                                                                                                                          
oModel:AddFields('MODEL_C77', /*cOwner*/, oStruC77 )                                                                                                                                                                                                                                                      

oModel:AddGrid('MODEL_C78', 'MODEL_C77', oStruC78)  
oModel:GetModel( 'MODEL_C78' ):SetUniqueLine( { 'C78_CSTICM' , 'C78_CFOP' , 'C78_ALQICM' } )

oModel:AddGrid('MODEL_C79', 'MODEL_C78', oStruC79)  
oModel:GetModel( 'MODEL_C79' ):SetUniqueLine( { 'C79_UF' } )
oModel:GetModel( 'MODEL_C79' ):SetOptional( .T. ) //não precisa preencher

oModel:SetRelation( 'MODEL_C78' , { { 'C78_FILIAL' , 'xFilial( "C78" )' } , { 'C78_ID' , 'C77_ID' } } , C78->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_C79' , { { 'C79_FILIAL' , 'xFilial( "C79" )' } , { 'C79_ID' , 'C77_ID' } , {'C79_CSTICM' , 'C78_CSTICM'} , {'C79_CFOP' , 'C78_CFOP'} , {'C79_ALQICM' , 'C78_ALQICM'} } , C79->( IndexKey( 1 ) ) )

oModel:GetModel( "MODEL_C77" ):SetPrimaryKey( { "C77_DTMOV" } )                                                                                                                                                                                                                                          
                                                                                                                                                                                                                                                                                                          
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
                                                                                                                                                                                                                                                                         
Local oModel 	  := 	FWLoadModel( 'TAFA208' ) 
Local oStruC77 	:= 	FWFormStruct( 2, 'C77' ) //"D695 - Consolidação da Prestação de Serviços"                                                                                                                                                                                                                           
Local oStruC78 	:= 	FWFormStruct( 2, 'C78' ) //"D696 - Registro Analítico dos Documentos" 
Local oStruC79 	:= 	FWFormStruct( 2, 'C79' ) //"D967 - Registro de Informações de Outras Ufs"

Local oView 	  := 	FWFormView():New()                                                                                                                                                                                                                                                                      

oStruC77:SetProperty( 'C77_CODMOD' , MVC_VIEW_LOOKUP   , "C01" )
oStruC78:SetProperty( 'C78_CSTICM' , MVC_VIEW_LOOKUP   , "C14" )
//oStruC78:SetProperty( 'C79_UF'     , MVC_VIEW_LOOKUP   , "C09" )
                                                                                                                                                                                                                                       
oView:SetModel( oModel )                                                                                                                                                                                                                                                                               
                                                                                                                                                                                                                                                                                                        
oView:AddField( 'VIEW_C77', oStruC77, 'MODEL_C77' ) //"D695 - Consolidação da Prestação de Serviços"                                                                                                                                                                                                                                                      
oView:EnableTitleView( 'VIEW_C77', STR0002 )                                                                                                                                                                                                                                       
 
oView:AddGrid ( 'VIEW_C79', oStruC79, 'MODEL_C79' ) //"D967 - Registro de Informações de Outras Ufs"
oView:EnableTitleView( 'VIEW_C79', STR0004 )

oView:AddGrid ( 'VIEW_C78', oStruC78, 'MODEL_C78' )
                                                                                                                                                                                                                                                                                                          
oView:CreateHorizontalBox( 'FIELDSC77'  , 30 )                                                                                                                                                                                                                                                              
oView:CreateHorizontalBox( 'FOLDERGERAL', 70 ) 

oView:CreateFolder( 'FOLDER1', 'FOLDERGERAL' )

oView:AddSheet( 'FOLDER1', 'ABA01', STR0003 ) 
oView:CreateHorizontalBox( 'GRIDC78',   50,,, 'FOLDER1', 'ABA01' )
oView:CreateHorizontalBox( 'FOLDERC79', 50,,, 'FOLDER1', 'ABA01' ) 
                                                                                                                                                                                                                                                                                                 
oView:SetOwnerView( 'VIEW_C77', 'FIELDSC77' )
oView:SetOwnerView( 'VIEW_C79', 'FOLDERC79' )                                                                                                                                                                                                                                                             
oView:SetOwnerView( 'VIEW_C78', 'GRIDC78' )
                                                                                                                                                                                                                                                                                                          
Return oView               

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Denis R. de Oliveira
@since 17/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

Local nOperation := oModel:GetOperation()

Begin Transaction

	If nOperation == MODEL_OPERATION_UPDATE
	
		//Funcao responsavel por setar o Status do registro para Branco
		TAFAltStat( "C77", " " )	
	
	EndIf

	FwFormCommit( oModel )
        

End Transaction
       

Return .T.
 
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} TAF208Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacões caso seja necessario gerar um XML

lJob - Informa se foi chamado por Job

@return .T.

@author Denis R. de Oliveira
@since 18/02/2014
@version 1.0
/*/                                                                                                                                          
//------------------------------------------------------------------------------------
Function TAF208Vld(cAlias,nRecno,nOpc,lJob)
Local aLogErro	:= {}

Default lJob := .F.

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C77->( Recno() )

If C77->C77_STATUS $ ( " |1" )
	
	//Valida o Codigo Identificacao Modelo
	If !Empty(C77->C77_CODMOD)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C77->C77_CODMOD
		xValRegTab("C01",cChave,3,,@aLogErro,, {"C77", "C77_CODMOD", nRecno } )
	EndIf
	
	//Valida a Grid Registro analitico dos documentos     
	dbSelectArea("C78")
	C78->(dbSetORder(1))
	If C78->(MsSeek(xFilial("C78") + C77->C77_ID))
		cId:=C78->C78_ID
		While (!C78->(Eof()) .And. cId==C78->C78_ID)
			
			//Valida o Codigo Identific. Origem
			If !Empty(C78->C78_ORIMER)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C78->C78_ORIMER
				xValRegTab("C03",cChave,3,,@aLogErro,, {"C77", "C78_ORIMER", nRecno })
			EndIf
			
			//Valida o Identificador CFOP
			If !Empty(C78->C78_CFOP)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C78->C78_CFOP
				xValRegTab("C0Y",cChave,3,,@aLogErro,, {"C77", "C78_CFOP", nRecno })
			EndIf
			
			//Valida a Observacao Lanc. Fiscal
			If !Empty(C78->C78_CODOBS)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C78->C78_CODOBS
				xValRegTab("C3R",cChave,3,,@aLogErro,, {"C77", "C78_CODOBS", nRecno })
			EndIf 
			
			//Valida o Id. CST ICMS     
			If !Empty(C78->C78_CSTICM)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C78->C78_CSTICM
				xValRegTab("C14",cChave,3,,@aLogErro,, {"C77", "C78_CSTICM", nRecno })
			EndIf
			
			C78->(dbSkip())
			
		Enddo
		
	Endif
	
	
	//Valida a Grid Registro de informações de outras UFs      
	dbSelectArea("C79")
	C79->(dbSetORder(1))
	If C79->(MsSeek(xFilial("C79") + C77->C77_ID))
		cId:=C79->C79_ID
		While (!C79->(Eof()) .And. cId==C79->C79_ID)			
			
			//Valida o Identificador CFOP
			If !Empty(C79->C79_CFOP)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C79->C79_CFOP
				xValRegTab("C0Y",cChave,3,,@aLogErro,, {"C77", "C79_CFOP", nRecno })
			EndIf
			
			//Valida o Codigo UF Origem
			If !Empty(C79->C79_UF)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C79->C79_UF
				xValRegTab("C09",cChave,3,,@aLogErro,, {"C77", "C79_UF", nRecno })
			EndIf 								
			C79->(dbSkip())
			
		Enddo
		
	Endif
	
	//ATUALIZO O STATUS DO REGISTRO
	If Len(aLogErro)>0
		//Utilizo RecLock, pois o SETVALUE somente funciona em campos USADOS
		RecLock("C77",.F.)
			C77->C77_STATUS := "1"
		C77->( MsUnlock() )
	Else
		RecLock("C77",.F.)
			C77->C77_STATUS := "0"
		C77->( MsUnlock() )
	EndIf
	
Else	
	AADD(aLogErro,{"C77_ID","000305", "C77", nRecno })//Registros que já foram transmitidos ao Fisco, não podem ser validados
EndIf

//Não apresento o alert quando utilizo o JOB para validar
If !lJob
	xValLogEr(aLogErro)
EndIf

Return(aLogErro)
	        