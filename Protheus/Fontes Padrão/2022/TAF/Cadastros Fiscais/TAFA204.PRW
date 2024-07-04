#INCLUDE "PROTHEUS.CH"                                                                                                                                                                                                                                                                                    
#INCLUDE "FWMVCDEF.CH"                                                                                                                                                                                                                                                                                    
#INCLUDE "TAFA204.CH"                                                                                                                                                                                                                                                                                     
                                                                                                                                                                                                                                                                                                          
//-------------------------------------------------------------------                                                                                                                                                                                                                                     
/*/{Protheus.doc} TAFA204                                                                                                                                                                                                                                                                                 
Cadastro MVC -                                                                                                                                                                                                                                                                           

                                                                                                                                                                                                                                                                                                          
@author Jefferson Guermandi                                                                                                                                                                                                                                                                                   
@since 08/02/2013                                                                                                                                                                                                                                                                                        
@version 1.0                                                                                                                                                                                                                                                                                              
                                                                                                                                                                                                                                                                                                          
/*/   
                                                                                                                                                                                                                                                                                                    
//-------------------------------------------------------------------                                                                                                                                                                                                                                     
Function TAFA204                                                                                                                                                                                                                                                                                          
Local	oBrw	:= FWmBrowse():New()                                                                                                                                                                                                                                                                          
                                                                                                                                                                                                                                                                                                          
oBrw:SetDescription( STR0001 ) //"Registro analítico dos Bilhetes Consolidados de Passagens"                                                                                                                                                                                                                                                      
oBrw:SetAlias( 'C7U' )                                                                                                                                                                                                                                                                                    
oBrw:SetMenuDef( 'TAFA204' )                                                                                                                                                                                                                                                                              
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

Aadd( aFuncao, { "" , "Taf204Vld" , "2" } )
aRotina	:=	xFunMnuTAF( "TAFA204" , , aFuncao )

Return( aRotina )
                                                                                                                                                                                                                                                                                                          
//-------------------------------------------------------------------                                                                                                                                                                                                                                     
/*/{Protheus.doc} ModelDef                                                                                                                                                                                                                                                                                
Funcao generica MVC do model                                                                                                                                                                                                                                                                              
                                                                                                                                                                                                                                                                                                          
@return oModel - Objeto do Modelo MVC                                                                                                                                                                                                                                                                     
                                                                                                                                                                                                                                                                                                          
@author Jefferson Guermandi                                                                                                                                                                                                                                                                                   
@since 08/02/2013                                                                                                                                                                                                                                                                                        
@version 1.0                                                                                                                                                                                                                                                                                                  
/*/                                                                                                                                                                                                                                                                                                       
//-------------------------------------------------------------------                                                                                                                                                                                                                                     
Static Function ModelDef()
Local oStruC7U 	:= 	FWFormStruct( 1, 'C7U' )
Local oStruC7V 	:= 	FWFormStruct( 1, 'C7V' )
Local oStruC7X 	:= 	FWFormStruct( 1, 'C7X' )
Local 	oModel 	:=  MPFormModel():New( 'TAFA204' , , , {|oModel| SaveModel( oModel ) } )

oModel:AddFields('MODEL_C7U', /*cOwner*/, oStruC7U )

oModel:AddGrid('MODEL_C7V', 'MODEL_C7U', oStruC7V)
oModel:GetModel( 'MODEL_C7V' ):SetUniqueLine( { 'C7V_DOCCAN' } )
oModel:GetModel( 'MODEL_C7V' ):SetOptional( .T. )

oModel:AddGrid('MODEL_C7X', 'MODEL_C7U', oStruC7X)
oModel:GetModel( 'MODEL_C7X' ):SetUniqueLine( { 'C7X_UF' , 'C7X_CODMUN' } )
oModel:GetModel( 'MODEL_C7X' ):SetOptional( .T. )
                                                                                                                                                                                                                                                                                                          
oModel:SetRelation( 'MODEL_C7V' , { { 'C7V_FILIAL' , 'xFilial( "C7V" )' } , { 'C7V_ID' , 'C7U_ID' } } , C7V->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_C7X' , { { 'C7X_FILIAL' , 'xFilial( "C7X" )' } , { 'C7X_ID' , 'C7U_ID' } } , C7X->( IndexKey( 1 ) ) )

oModel:GetModel( "MODEL_C7U" ):SetPrimaryKey( { "C7U_DTMOV" , "C7U_CODMOD" , "C7U_DTDOC" , "C7U_SER" , "C7U_SUB" , "C7U_DOCINI" , "C7U_DOCFIM" , "C7U_CST" , "C7U_CFOP" } )

Return oModel
//-------------------------------------------------------------------                                                                                                                                                                                                                                     
/*/{Protheus.doc} ViewDef                                                                                                                                                                                                                                                                                 
Funcao generica MVC do View                                                                                                                                                                                                                                                                               
                                                                                                                                                                                                                                                                                                          
@return oView - Objeto da View MVC   
                                                                                                                                                                                                                                                                     
@author Jefferson Guermandi                                                                                                                                                                                                                                                                                   
@since 08/02/2013                                                                                                                                                                                                                                                                                        
@version 1.0                                                                                                                                                                                                                                                                                                    
/*/                                                                                                                                                                                                                                                                                                       
//-------------------------------------------------------------------                                                                                                                                                                                                                                     
Static Function ViewDef()                                                                                                                                                                                                                                                                                 
Local oModel 	:= 	FWLoadModel( 'TAFA204' )                                                                                                                                                                                                                                                                
Local oStruC7U 	:= 	FWFormStruct( 2, 'C7U' )
Local oStruC7V 	:= 	FWFormStruct( 2, 'C7V' )
Local oStruC7X 	:= 	FWFormStruct( 2, 'C7X' )

                                                                                                                                                                                                                                                                                                     
Local oView 	:= 	FWFormView():New()                                                                                                                                                                                                                                                                      
                                                                                                                                                                                                                                                                                                          
oView:SetModel( oModel )                                                                                                                                                                                                                                                                                  
                                                                                                                                                                                                                                                                                                          
oView:AddField( 'VIEW_C7U', oStruC7U, 'MODEL_C7U' )
oView:EnableTitleView( 'VIEW_C7U', STR0001 ) //"Registro analítico dos Bilhetes"


oView:AddGrid( 'VIEW_C7V', oStruC7V, 'MODEL_C7V' )
oView:EnableTitleView( 'VIEW_C7V', STR0002 ) //"Documentos Cancelados dos Bilhetes"

oView:AddGrid( 'VIEW_C7X', oStruC7X, 'MODEL_C7X' )
oView:EnableTitleView( 'VIEW_C7X', STR0003 ) //"Complementos dos Bilhetes"                                                                                                                                                                                                                                                                                                        

oView:CreateHorizontalBox( 'FIELDSC7U', 50 )
oView:CreateHorizontalBox( 'FOLDERGERAL', 50 )

oView:CreateFolder( 'FOLDER1', 'FOLDERGERAL' )

oView:AddSheet( 'FOLDER1', 'ABA01', STR0002 ) //"Documentos Cancelados dos Bilhetes""
oView:CreateHorizontalBox( 'GRIDC7V', 100,,, 'FOLDER1', 'ABA01' )

oView:AddSheet( 'FOLDER1', 'ABA02', STR0003 ) //"Complementos dos Bilhetes"
oView:CreateHorizontalBox( 'GRIDC7X', 100,,, 'FOLDER1', 'ABA02' )  
                                                                                                                                                                                                            

oView:SetOwnerView( 'VIEW_C7U', 'FIELDSC7U' )        
oView:SetOwnerView( 'VIEW_C7V', 'GRIDC7V' ) 
oView:SetOwnerView( 'VIEW_C7X', 'GRIDC7X' ) 
 
If TamSX3("C7U_CTA")[1] == 36
	oStruC7U:RemoveField("C7U_CTA")
	oStruC7U:SetProperty("C7U_CTACTB", 	MVC_VIEW_ORDEM, "27")		
	oStruC7U:SetProperty("C7U_DCTA", 	MVC_VIEW_ORDEM, "28")
EndIf  
                                                                                                                                                                                                                                                                                                         
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
		TAFAltStat( "C7U", " " )		
	EndIf
	FwFormCommit( oModel )      
End Transaction
       
Return .T.
 
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} TAF204Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacões caso seja necessario gerar um XML

lJob - Informa se foi chamado por Job

@return .T.

@author Denis R. de Oliveira
@since 18/02/2014
@version 1.0
/*/                                                                                                                                          
//------------------------------------------------------------------------------------
Function TAF204Vld(cAlias,nRecno,nOpc,lJob)
Local aLogErro	:= {}

Default lJob := .F.

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C7U->( Recno() )

If C7U->C7U_STATUS $ ( " |1" )
	
	//Valida o Codigo Identificacao Modelo
	If !Empty(C7U->C7U_CODMOD)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C7U->C7U_CODMOD
		xValRegTab("C01",cChave,3,,@aLogErro,, { "C7U", "C7U_CODMOD", nRecno } )
	EndIf
	
	//Valida o Codigo Fiscal de Operacao
	If !Empty(C7U->C7U_CFOP)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C7U->C7U_CFOP
		xValRegTab("C0Y",cChave,3,,@aLogErro,, { "C7U", "C7U_CFOP", nRecno })
	EndIf
	
	//Valida a Observacao Lanc. Fiscal
	If !Empty(C7U->C7U_CODOBS)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C7U->C7U_CODOBS
		xValRegTab("C3R",cChave,3,,@aLogErro,, { "C7U", "C7U_CODOBS", nRecno })
	EndIf
	
	//Valida a Conta Contabil
	If !Empty(C7U->C7U_CTA)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C7U->C7U_CTA
		xValRegTab("C1O",cChave,3,,@aLogErro,, { "C7U", "C7U_CTA", nRecno })
	EndIf 
	
	//Valida o Codigo CST       
	If !Empty(C7U->C7U_CST)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C7U->C7U_CST
		xValRegTab("C14",cChave,3,,@aLogErro,, { "C7U", "C7U_CST", nRecno })
	EndIf
	
	//Valida a Grid Complementos          
	dbSelectArea("C7X")
	C7X->(dbSetORder(1))
	If C7X->(MsSeek(xFilial("C7X") + C7U->C7U_ID))
		cId:=C7X->C7X_ID
		While (!C7X->(Eof()) .And. cId==C7X->C7X_ID)
			
			//Valida o Codigo UF
			If !Empty(C7X->C7X_UF)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C7X->C7X_UF
				xValRegTab("C09",cChave,3,,@aLogErro,, { "C7U", "C7X_UF", nRecno })
			EndIf
			
			//Valida o Codigo Municipio de Origem
			If !Empty(C7X->C7X_CODMUN)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C7X->C7X_CODMUN
				xValRegTab("C07",cChave,3,,@aLogErro,, { "C7U", "C7X_CODMUN", nRecno })
			EndIf
			
			C7X->(dbSkip())
			
		Enddo
		
	Endif
	
	//ATUALIZO O STATUS DO REGISTRO
	If Len(aLogErro)>0
		
		//Utilizo RecLock, pois o SETVALUE somente funciona em campos USADOS
		RecLock("C7U",.F.)
			C7U->C7U_STATUS := "1"
		C7U->( MsUnlock() )
	Else
		RecLock("C7U",.F.)
			C7U->C7U_STATUS := "0"
		C7U->( MsUnlock() )
	EndIf
	
Else	
	AADD(aLogErro,{"C7U_ID","000305", "C7U", nRecno })//Registros que já foram transmitidos ao Fisco, não podem ser validados
EndIf

//Não apresento o alert quando utilizo o JOB para validar
If !lJob
	xValLogEr(aLogErro)
EndIf


Return(aLogErro)

	                                                                                                                                                                                                                                                                                             