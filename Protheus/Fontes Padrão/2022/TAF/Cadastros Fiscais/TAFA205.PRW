#INCLUDE "PROTHEUS.CH"                                                                                                                                                                                                                                                                                    
#INCLUDE "FWMVCDEF.CH"                                                                                                                                                                                                                                                                                    
#INCLUDE "TAFA205.CH"                                                                                                                                                                                                                                                                                     
                                                                                                                                                                                                                                                                                                          
//-------------------------------------------------------------------                                                                                                                                                                                                                                     
/*/{Protheus.doc} TAFA205                                                                                                                                                                                                                                                                                 
Cadastro MVC 

     - C7Z - D300 - Consolidados - Registro analítico dos Bilhetes Consolidados de Passagem Rodoviária (Código 13), 
                    de Passagem Aquaviária (Código 14), de Passagem e Nota de Bagagem (Código 14) e 
                    Passagem Ferroviária (Código 16) e Resumo de Movimento Diário (Código 18);
     - C70 - D309 - Processos referenciados.

                                                                                                                                                                                                                                                                                                          
@author Ana Laura Olegini                                                                                                                                                                                                                                                                                   
@since 05/02/2013                                                                                                                                                                                                                                                                                         
@version 1.0                                                                                                                                                                                                                                                                                            
/*/                                                                                                                                                                                                                                                                                                       
//-------------------------------------------------------------------                                                                                                                                                                                                                                     
Function TAFA205                                                                                                                                                                                                                                                                                          
Local	oBrw	:= FWmBrowse():New()                                                                                                                                                                                                                                                                          
                                                                                                                                                                                                                                                                                                          
oBrw:SetDescription( STR0001 ) //"D300 - Registro analítico dos Bilhetes Consolidados de Passagem "                                                                                                                                                                                                                                                     
oBrw:SetAlias( 'C7Z' )                                                                                                                                                                                                                                                                                    
oBrw:SetMenuDef( 'TAFA205' )                                                                                                                                                                                                                                                                              
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

Aadd( aFuncao, { "" , "Taf205Vld" , "2" } )
aRotina	:=	xFunMnuTAF( "TAFA205" , , aFuncao )

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
                                                                                                                                                                                                                                                                               
Local oStruC7Z 	:= 	FWFormStruct( 1, 'C7Z' ) //"D300 - Registro analítico dos Bilhetes Consolidados de Passagem "                                                                                                                                                                                                                                                           
Local oStruC70 	:= 	FWFormStruct( 1, 'C70' ) //"D309 - Processos referenciados"                
Local 	oModel 	:=  MPFormModel():New( 'TAFA205' , , , {|oModel| SaveModel( oModel ) } )                                                                                                                                                                                                                                                       
                                                                                                                                                                                                                                                                                                          
oModel:AddFields('MODEL_C7Z', /*cOwner*/, oStruC7Z )                                                                                                                                                                                                                                                      

oModel:AddGrid('MODEL_C70', 'MODEL_C7Z', oStruC70)  
oModel:GetModel( 'MODEL_C70' ):SetUniqueLine( { 'C70_IDPRO' } )
oModel:GetModel( 'MODEL_C70' ):SetOptional( .T. ) //campo processo referenciado não necessita ser obrigatorio.


oModel:SetRelation( 'MODEL_C70' , { { 'C70_FILIAL' , 'xFilial( "C70" )' } , { 'C70_ID' , 'C7Z_ID' } } , C70->( IndexKey( 1 ) ) )

oModel:GetModel( "MODEL_C7Z" ):SetPrimaryKey( { "C7Z_DTMOV" } )                                                                                                                                                                                                                                          
                                                                                                                                                                                                                                                                                                          
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
                                                                                                                                                                                                                                                                         
Local oModel 	  := 	FWLoadModel( 'TAFA205' ) 
Local oStruC7Z 	:= 	FWFormStruct( 2, 'C7Z' ) //"D300 - Registro analítico dos Bilhetes Consolidados de Passagem "                                                                                                                                                                                                                            
Local oStruC70 	:= 	FWFormStruct( 2, 'C70' ) //"D309 - Processos referenciados"                                   


Local oView 	  := 	FWFormView():New()                                                                                                                                                                                                                                                                      

oStruC7Z:SetProperty( 'C7Z_IDMOD'   , MVC_VIEW_LOOKUP   , "C01" )
oStruC70:SetProperty( 'C70_IDPRO'   , MVC_VIEW_LOOKUP   , "C1G" )

                                                                                                                                                                                                                                       
oView:SetModel( oModel )                                                                                                                                                                                                                                                                               
                                                                                                                                                                                                                                                                                                        
oView:AddField( 'VIEW_C7Z', oStruC7Z, 'MODEL_C7Z' ) //"D300 - Registro analítico dos Bilhetes Consolidados de Passagem "                                                                                                                                                                                                                                                      
oView:EnableTitleView( 'VIEW_C7Z', STR0002 )                                                                                                                                                                                                                                       
 
//oView:AddGrid ( 'VIEW_C70', oStruC70, 'MODEL_C70' ) //"D309 - Processos referenciados"
//oView:EnableTitleView( 'VIEW_C70', STR0003 )        

oView:AddGrid ( 'VIEW_C70', oStruC70, 'MODEL_C70' )
                                                                                                                                                                                                                                                                                                          
oView:CreateHorizontalBox( 'FIELDSC7Z'  , 50 )                                                                                                                                                                                                                                                              
oView:CreateHorizontalBox( 'FOLDERGERAL', 50 ) 

oView:CreateFolder( 'FOLDER1', 'FOLDERGERAL' )

oView:AddSheet( 'FOLDER1', 'ABA01', STR0003 ) 
oView:CreateHorizontalBox( 'GRIDC70', 100,,, 'FOLDER1', 'ABA01' )
                                                                                                                                                                                                                                                                                                 
If TamSX3("C7Z_CTA")[1] == 36
	oStruC7Z:RemoveField( "C7Z_CTA")
	oStruC7Z:SetProperty( "C7Z_CTACTB", MVC_VIEW_ORDEM, "25" )
EndIf                   
oView:SetOwnerView( 'VIEW_C7Z', 'FIELDSC7Z' )
oView:SetOwnerView( 'VIEW_C70', 'GRIDC70' )
                                                                                                                                                                                                                                                                                                          
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
		TAFAltStat( "C7Z", " " )		
	EndIf
	FwFormCommit( oModel )        

End Transaction
       

Return .T.
 
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} TAF205Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacões caso seja necessario gerar um XML

lJob - Informa se foi chamado por Job

@return .T.

@author Denis R. de Oliveira
@since 18/02/2014
@version 1.0
/*/                                                                                                                                          
//------------------------------------------------------------------------------------
Function TAF205Vld(cAlias,nRecno,nOpc,lJob)
Local aLogErro	:= {} 
Local cIndProc

Default lJob := .F.

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C7Z->( Recno() )

If C7Z->C7Z_STATUS $ ( " |1" )
	
	//Valida a Identificacao do Modelo
	If !Empty(C7Z->C7Z_IDMOD)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C7Z->C7Z_IDMOD
		xValRegTab("C01",cChave,3,,@aLogErro,, {"C7Z", "C7Z_IDMOD", nRecno } )
	EndIf
	
	//Valida o Identificador do CFOP
	If !Empty(C7Z->C7Z_CFOP)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C7Z->C7Z_CFOP
		xValRegTab("C0Y",cChave,3,,@aLogErro,, {"C7Z", "C7Z_CFOP", nRecno } )
	EndIf
	
	//Valida a Conta Contabil
	If !Empty(C7Z->C7Z_CTA)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C7Z->C7Z_CTA
		xValRegTab("C1O",cChave,3,,@aLogErro,, {"C7Z", "C7Z_CTA", nRecno } )
	EndIf
	
	//Valida o Identificador CST PIS           
	If !Empty(C7Z->C7Z_CSTPIS)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C7Z->C7Z_CSTPIS
		xValRegTab("C17",cChave,3,,@aLogErro,, {"C7Z", "C7Z_CSTPIS", nRecno } )
	EndIf
	
	//Valida o Identificador CST COFINS         
	If !Empty(C7Z->C7Z_CSTCFS)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C7Z->C7Z_CSTCFS
		xValRegTab("C17",cChave,3,,@aLogErro,, {"C7Z", "C7Z_CSTCFS", nRecno } )
	EndIf

	//Valida a Grid Processos referenciados    
	dbSelectArea("C70")
	C70->(dbSetORder(1))
	If C70->(MsSeek(xFilial("C70") + C7Z->C7Z_ID))
		cId:=C70->C70_ID
		While (!C70->(Eof()) .And. cId==C70->C70_ID)
			
			cIndProc:= Alltrim(Posicione("C1G",3,xFilial("C1G")+C70->C70_IDPRO,"C1G_INDPRO"))
			
			//Valida o Id. Processo Referenciado
			If !Empty(C70->C70_IDPRO)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C70->C70_IDPRO
				xValRegTab("C1G",cChave,3,,@aLogErro,, {"C7Z", "C70_IDPRO", nRecno } )
				If !(cIndProc $ ("1|3|9"))
					AADD(aLogErro,{"C70_IDPRO","000006","C7Z", nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
				EndIf
			EndIf
			
			C70->(dbSkip())
			
		Enddo
		
	Endif	

	//ATUALIZO O STATUS DO REGISTRO
	If Len(aLogErro)>0
		//Utilizo RecLock, pois o SETVALUE somente funciona em campos USADOS
		RecLock("C7Z",.F.)
			C7Z->C7Z_STATUS := "1"
		C7Z->( MsUnlock() )
	Else
		RecLock("C7Z",.F.)
			C7Z->C7Z_STATUS := "0"
		C7Z->( MsUnlock() )
	EndIf
	
Else	
	AADD(aLogErro,{"C7Z_ID","000305", "C7Z", nRecno })//Registros que já foram transmitidos ao Fisco, não podem ser validados
EndIf

//Não apresento o alert quando utilizo o JOB para validar
If !lJob
	xValLogEr(aLogErro)
EndIf

Return(aLogErro)
	                