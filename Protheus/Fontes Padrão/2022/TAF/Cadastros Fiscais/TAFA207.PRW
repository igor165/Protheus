#INCLUDE "PROTHEUS.CH"                                                                                                                                                                                                                                                                                    
#INCLUDE "FWMVCDEF.CH"                                                                                                                                                                                                                                                                                    
#INCLUDE "TAFA207.CH"                                                                                                                                                                                                                                                                                     
                                                                                                                                                                                                                                                                                                          
//-------------------------------------------------------------------                                                                                                                                                                                                                                     
/*/{Protheus.doc} TAFA207                                                                                                                                                                                                                                                                                 
Cadastro MVC -                                                                                                                                                                                                                                                                           
                                                                                                                                                                                                                                                                                                          
@author Gustavo Baptista                                                                                                                                                                                                                                                                                   
@since 15/02/2013                                                                                                                                                                                                                                                                                         
@version 1.0                                                                                                                                                                                                                                                                                              
                                                                                                                                                                                                                                                                                                          
/*/                                                                                                                                                                                                                                                                                                       
//-------------------------------------------------------------------                                                                                                                                                                                                                                     
Function TAFA207                                                                                                                                                                                                                                                                                          
Local	oBrw	:= FWmBrowse():New()                                                                                                                                                                                                                                                                          
                                                                                                                                                                                                                                                                                                          
oBrw:SetDescription( STR0001 ) //                                                                                                                                                                                                                                                 
oBrw:SetAlias( 'C73' )                                                                                                                                                                                                                                                                                    
oBrw:SetMenuDef( 'TAFA207' )                                                                                                                                                                                                                                                                              
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

Aadd( aFuncao, { "" , "Taf207Vld" , "2" } )
aRotina	:=	xFunMnuTAF( "TAFA207" , , aFuncao )

Return( aRotina )
                                                                                                                                                                                                                                                                                                          
//-------------------------------------------------------------------                                                                                                                                                                                                                                     
/*/{Protheus.doc} ModelDef                                                                                                                                                                                                                                                                                
Funcao generica MVC do model                                                                                                                                                                                                                                                                              
                                                                                                                                                                                                                                                                                                          
@return oModel - Objeto do Modelo MVC                                                                                                                                                                                                                                                                     
                                                                                                                                                                                                                                                                                                          
@author Gustavo Baptista                                                                                                                                                                                                                                                                                   
@since 15/02/2013                                                                                                                                                                                                                                                                                         
@version 1.0                                                                                                                                                                                                                                                                                              
/*/                                                                                                                                                                                                                                                                                                       
//-------------------------------------------------------------------                                                                                                                                                                                                                                     
Static Function ModelDef()
Local oStruC73 	:= 	FWFormStruct( 1, 'C73' )
Local oStruC74 	:= 	FWFormStruct( 1, 'C74' )
Local oStruC75 	:= 	FWFormStruct( 1, 'C75' )
Local oStruC76 	:= 	FWFormStruct( 1, 'C76' )
Local 	oModel 	:=  MPFormModel():New( 'TAFA207' , , , {|oModel| SaveModel( oModel ) } )

oModel:AddFields('MODEL_C73', /*cOwner*/, oStruC73 )

oModel:AddGrid('MODEL_C74', 'MODEL_C73', oStruC74)
oModel:GetModel( 'MODEL_C74' ):SetUniqueLine( { 'C74_CSTPIS' } )

oModel:AddGrid('MODEL_C75', 'MODEL_C73', oStruC75)
oModel:GetModel( 'MODEL_C75' ):SetUniqueLine( { 'C75_CSTCOF','C75_CCLASS' } )
                                                                                                                                                                                                                                                                                                          
oModel:AddGrid('MODEL_C76', 'MODEL_C73', oStruC76)
oModel:GetModel( 'MODEL_C76' ):SetUniqueLine( { 'C76_NUMPRO' } )
oModel:GetModel( 'MODEL_C76' ):SetOptional( .T. )

oModel:SetRelation( 'MODEL_C74' , { { 'C74_FILIAL' , 'xFilial( "C74" )' } , { 'C74_ID' , 'C73_ID' } } , C74->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_C75' , { { 'C75_FILIAL' , 'xFilial( "C75" )' } , { 'C75_ID' , 'C73_ID' } } , C75->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_C76' , { { 'C76_FILIAL' , 'xFilial( "C76" )' } , { 'C76_ID' , 'C73_ID' } } , C76->( IndexKey( 1 ) ) )

oModel:GetModel( "MODEL_C73" ):SetPrimaryKey( { "C73_FILIAL","C73_ID","C73_DTMOV","C73_CODMOD","C73_UF","C73_CODMUN","C73_SER","C73_SUB","C73_INDREC","C73_DTDINI","C73_DTDFIM" } )

Return oModel
//-------------------------------------------------------------------                                                                                                                                                                                                                                     
/*/{Protheus.doc} ViewDef                                                                                                                                                                                                                                                                                 
Funcao generica MVC do View                                                                                                                                                                                                                                                                               
                                                                                                                                                                                                                                                                                                          
@return oView - Objeto da View MVC                                                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                                                                          
@author Gustavo Baptista                                                                                                                                                                                                                                                                                   
@since 15/02/2013                                                                                                                                                                                                                                                                                         
@version 1.0                                                                                                                                                                                                                                                                                              
/*/                                                                                                                                                                                                                                                                                                       
//-------------------------------------------------------------------                                                                                                                                                                                                                                     
Static Function ViewDef()                                                                                                                                                                                                                                                                                 
Local oModel 	:= 	FWLoadModel( 'TAFA207' )                                                                                                                                                                                                                                                                
Local oStruC73 	:= 	FWFormStruct( 2, 'C73' )
Local oStruC74 	:= 	FWFormStruct( 2, 'C74' )
Local oStruC75 	:= 	FWFormStruct( 2, 'C75' )
Local oStruC76 	:= 	FWFormStruct( 2, 'C76' )
                                                                                                                                                                                                                                                                                                     
Local oView 	:= 	FWFormView():New()                                                                                                                                                                                                                                                                      
                                                                                                                                                                                                                                                                                                          
oView:SetModel( oModel )                                                                                                                                                                                                                                                                                  
                                                                                                                                                                                                                                                                                                          
oView:AddField( 'VIEW_C73', oStruC73, 'MODEL_C73' )
oView:EnableTitleView( 'VIEW_C73', STR0001 ) // 


oView:AddGrid( 'VIEW_C74', oStruC74, 'MODEL_C74' )
oView:EnableTitleView( 'VIEW_C74', STR0002 ) // 

oView:AddGrid( 'VIEW_C75', oStruC75, 'MODEL_C75' )
oView:EnableTitleView( 'VIEW_C75', STR0003 ) // 

oView:AddGrid( 'VIEW_C76', oStruC76, 'MODEL_C76' )
oView:EnableTitleView( 'VIEW_C76', STR0004 ) //                                                                                                                                                                                                                                                                                                     

oView:CreateHorizontalBox( 'FIELDSC73', 50 )
oView:CreateHorizontalBox( 'FOLDERGERAL', 50 )

oView:CreateFolder( 'FOLDER1', 'FOLDERGERAL' )

oView:AddSheet( 'FOLDER1', 'ABA01', STR0002 ) // 
oView:CreateHorizontalBox( 'GRIDC74', 100,,, 'FOLDER1', 'ABA01' )

oView:AddSheet( 'FOLDER1', 'ABA02', STR0003 ) // 
oView:CreateHorizontalBox( 'GRIDC75', 100,,, 'FOLDER1', 'ABA02' )  

oView:AddSheet( 'FOLDER1', 'ABA03', STR0004 ) //
oView:CreateHorizontalBox( 'GRIDC76', 100,,, 'FOLDER1', 'ABA03' )  
                                                                                                                                                                                                            
If TamSX3("C74_CTA")[1] == 36
	oStruC74:RemoveField( "C74_CTA")
	oStruC74:SetProperty( "C74_CTACTB", MVC_VIEW_ORDEM, "12" )
EndIf

If TamSX3("C75_CTA")[1] == 36
	oStruC75:RemoveField( "C75_CTA")
	oStruC75:SetProperty( "C75_CTACTB", MVC_VIEW_ORDEM, "12" )
EndIf

oView:SetOwnerView( 'VIEW_C73', 'FIELDSC73' )        
oView:SetOwnerView( 'VIEW_C74', 'GRIDC74' ) 
oView:SetOwnerView( 'VIEW_C75', 'GRIDC75' ) 
oView:SetOwnerView( 'VIEW_C76', 'GRIDC76' ) 
                                                                                                                                                                                                                                                                                                         
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
		TAFAltStat( "C73", " " )	
	EndIf

	FwFormCommit( oModel )
        

End Transaction
       

Return .T.
 
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} TAF207Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacões caso seja necessario gerar um XML

lJob - Informa se foi chamado por Job

@return .T.

@author Denis R. de Oliveira
@since 18/02/2014
@version 1.0
/*/                                                                                                                                          
//------------------------------------------------------------------------------------
Function TAF207Vld(cAlias,nRecno,nOpc,lJob)
Local aLogErro	:= {}

Default lJob := .F.

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C73->( Recno() )

If C73->C73_STATUS $ ( " |1" )
	
	//Valida o Codigo de Identificacao de Modelo
	If !Empty(C73->C73_CODMOD)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C73->C73_CODMOD
		xValRegTab("C01",cChave,3,,@aLogErro,, {"C73", "C73_CODMOD", nRecno } )
	EndIf
	
	//Valida o Codigo UF Origem
	If !Empty(C73->C73_UF)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C73->C73_UF
		xValRegTab("C09",cChave,3,,@aLogErro,, {"C73", "C73_UF", nRecno })
	EndIf
	
	//Valida o Codigo Municipio de Origem
	If !Empty(C73->C73_CODMUN)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C73->C73_CODMUN
		xValRegTab("C07",cChave,3,,@aLogErro,, {"C73", "C73_CODMUN", nRecno })
	EndIf
	
	//Valida a Grid Compl.Consol.Prestação Serviços (PIS/PASEP)   
	dbSelectArea("C74")
	C74->(dbSetORder(1))
	If C74->(MsSeek(xFilial("C74")+C73->C73_ID))
		cId:=C74->C74_ID
		While (!C74->(Eof()) .And. cId==C74->C74_ID)
			
			//Valida o Codigo Class. Item
			If !Empty(C74->C74_CCLASS)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C74->C74_CCLASS
				xValRegTab("C0K",cChave,4,,@aLogErro,, {"C73", "C74_CCLASS", nRecno })
			EndIf
			
			//Valida a Conta Contabil
			If !Empty(C74->C74_CTA)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C74->C74_CTA
				xValRegTab("C1O",cChave,3,,@aLogErro,, {"C73", "C74_CTA", nRecno })
			EndIf			
			
			C74->(dbSkip())
		Enddo		
	Endif

	//Valida a Grid Compl.Consol.Prestação Serviços (COFINS)      
	dbSelectArea("C75")
	C75->(dbSetORder(1))
	If C75->(MsSeek(xFilial("C75") + C73->C73_ID))
		cId:=C75->C75_ID
		While (!C75->(Eof()) .And. cId==C75->C75_ID)
			
			//Valida o Codigo Class. Item
			If !Empty(C75->C75_CCLASS)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C75->C75_CCLASS
				xValRegTab("C0K",cChave,4,,@aLogErro,, {"C73", "C75_CCLASS", nRecno })
			EndIf
			
			//Valida a Conta Contabil
			If !Empty(C75->C75_CTA)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C75->C75_CTA
				xValRegTab("C1O",cChave,3,,@aLogErro,, {"C73", "C75_CTA", nRecno })
			EndIf
			
			//Valida o Codigo Situacao Tributaria COFINS          
			If !Empty(C75->C75_CSTCOF)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C75->C75_CSTCOF
				xValRegTab("C17",cChave,3,,@aLogErro,, {"C73", "C75_CSTCOF", nRecno })
			EndIf
			
			C75->(dbSkip())
			
		Enddo
		
	Endif
	
	//------------------------------------------//
	/* Valida a Grid Processos referenciados    */
	//------------------------------------------//
	dbSelectArea("C76")
	C76->(dbSetORder(1))
	If C76->(MsSeek(xFilial("C76") + C73->C73_ID))
		cId:=C76->C76_ID
		While (!C76->(Eof()) .And. cId==C76->C76_ID)
			
			cIndProc:= Alltrim(Posicione("C1G",3,xFilial("C1G")+C76->C76_NUMPRO,"C1G_INDPRO"))
			
			//Valida o Id. Processo Referenciado
			If !Empty(C76->C76_NUMPRO)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C76->C76_NUMPRO
				xValRegTab("C1G",cChave,3,,@aLogErro,, {"C73", "C76_NUMPRO", nRecno })
				If !(cIndProc $ ("1|3|9"))
					AADD(aLogErro,{"C76_NUMPRO","000006","C73", nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
				EndIf
			EndIf
			
			C76->(dbSkip())
			
		Enddo
		
	Endif
	
	//ATUALIZO O STATUS DO REGISTRO
	If Len(aLogErro)>0
		//Utilizo RecLock, pois o SETVALUE somente funciona em campos USADOS
		RecLock("C73",.F.)
			C73->C73_STATUS := "1"
		C73->( MsUnlock() )
	Else
		RecLock("C73",.F.)
			C73->C73_STATUS := "0"
		C73->( MsUnlock() )
	EndIf
	
Else	
	AADD(aLogErro,{"C73_ID","000305", "C73", nRecno })//Registros que já foram transmitidos ao Fisco, não podem ser validados
EndIf

//Não apresento o alert quando utilizo o JOB para validar
If !lJob
	xValLogEr(aLogErro)
EndIf

Return(aLogErro)
	                                                                                                                                                                                                                                                                              