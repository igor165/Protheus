#INCLUDE "PROTHEUS.CH"                                                                                                                                                                                                                                                                                    
#INCLUDE "FWMVCDEF.CH"                                                                                                                                                                                                                                                                                    
#INCLUDE "TAFA206.CH"                                                                                                                                                                                                                                                                                     
                                                                                                                                                                                                                                                                                                          
//-------------------------------------------------------------------                                                                                                                                                                                                                                     
/*/{Protheus.doc} TAFA206                                                                                                                                                                                                                                                                                 
Cadastro MVC -                                                                                                                                                                                                                                                                           

                                                                                                                                                                                                                                                                                                          
@author Gustavo Baptista                                                                                                                                                                                                                                                                                   
@since 13/02/2013                                                                                                                                                                                                                                                                                        
@version 1.0                                                                                                                                                                                                                                                                                              
                                                                                                                                                                                                                                                                                                          
/*/   
                                                                                                                                                                                                                                                                                                    
//-------------------------------------------------------------------                                                                                                                                                                                                                                     
Function TAFA206                                                                                                                                                                                                                                                                                          
Local	oBrw	:= FWmBrowse():New()                                                                                                                                                                                                                                                                          
                                                                                                                                                                                                                                                                                                          
oBrw:SetDescription( STR0001 ) //"Resumo Diario de Cupom Fiscal por ECF"                                                                                                                                                                                                                                                     
oBrw:SetAlias( 'C71' )                                                                                                                                                                                                                                                                                    
oBrw:SetMenuDef( 'TAFA206' )                                                                                                                                                                                                                                                                              
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

Aadd( aFuncao, { "" , "Taf206Vld" , "2" } )
aRotina	:=	xFunMnuTAF( "TAFA206" , , aFuncao )

Return( aRotina )
                                                                                                                                                                                                                                                                                                          
//-------------------------------------------------------------------                                                                                                                                                                                                                                     
/*/{Protheus.doc} ModelDef                                                                                                                                                                                                                                                                                
Funcao generica MVC do model                                                                                                                                                                                                                                                                              
                                                                                                                                                                                                                                                                                                          
@return oModel - Objeto do Modelo MVC                                                                                                                                                                                                                                                                     
                                                                                                                                                                                                                                                                                                          
@author Gustavo Baptista                                                                                                                                                                                                                                                                                   
@since 13/02/2013                                                                                                                                                                                                                                                                                        
@version 1.0                                                                                                                                                                                                                                                                                                  
/*/                                                                                                                                                                                                                                                                                                       
//-------------------------------------------------------------------                                                                                                                                                                                                                                     
Static Function ModelDef()
Local oStruC71 	:= 	FWFormStruct( 1, 'C71' )
Local oStruC72 	:= 	FWFormStruct( 1, 'C72' )
Local 	oModel 	:=  MPFormModel():New( 'TAFA206' , , , {|oModel| SaveModel( oModel ) } )

oModel:AddFields('MODEL_C71', /*cOwner*/, oStruC71 )

oModel:AddGrid('MODEL_C72', 'MODEL_C71', oStruC72)
oModel:GetModel( 'MODEL_C72' ):SetUniqueLine( { 'C72_NUMPRO' } )
oModel:GetModel( 'MODEL_C72' ):SetOptional( .T. )
                                                                                                                                                                                                                                    
oModel:SetRelation( 'MODEL_C72' , { {'C72_FILIAL' , 'xFilial( "C72" )'} , {'C72_ID' , 'C71_ID'} } , C72->( IndexKey( 1 ) ) )


oModel:GetModel( "MODEL_C71" ):SetPrimaryKey( { "C71_DTMOV" } )

Return oModel
//-------------------------------------------------------------------                                                                                                                                                                                                                                     
/*/{Protheus.doc} ViewDef                                                                                                                                                                                                                                                                                 
Funcao generica MVC do View                                                                                                                                                                                                                                                                               
                                                                                                                                                                                                                                                                                                          
@return oView - Objeto da View MVC   
                                                                                                                                                                                                                                                                     
@author Gustavo Baptista                                                                                                                                                                                                                                                                                  
@since 13/02/2013                                                                                                                                                                                                                                                                                        
@version 1.0                                                                                                                                                                                                                                                                                                    
/*/                                                                                                                                                                                                                                                                                                       
//-------------------------------------------------------------------                                                                                                                                                                                                                                     
Static Function ViewDef()                                                                                                                                                                                                                                                                                 
Local oModel   	:= 	FWLoadModel( 'TAFA206' )                                                                                                                                                                                                                                                                
Local oStruC71 	:= 	FWFormStruct( 2, 'C71' )
Local oStruC72 	:= 	FWFormStruct( 2, 'C72' )
                                                                                                                                                                                                                                                                                                     
Local oView 	:= 	FWFormView():New()                                                                                                                                                                                                                                                                      

oStruC71:SetProperty( 'C71_CODMOD' , MVC_VIEW_LOOKUP   , "C01" )         
oStruC72:SetProperty( 'C72_NUMPRO' , MVC_VIEW_LOOKUP   , "C1G" )
                                                                                                                                                                                                                                                                                                          
oView:SetModel( oModel )                                                                                                                                                                                                                                                                                  
                                                                                                                                                                                                                                                                                                          
oView:AddField( 'VIEW_C71', oStruC71, 'MODEL_C71' )
oView:EnableTitleView( 'VIEW_C71', STR0001 ) //" Resumo Diario de Cupom Fiscal por ECF "


oView:AddGrid( 'VIEW_C72', oStruC72, 'MODEL_C72' )
oView:EnableTitleView( 'VIEW_C72', STR0002 ) //"Processos referenciados"

oView:CreateHorizontalBox( 'FIELDSC71', 60 )
oView:CreateHorizontalBox( 'FOLDERGERAL', 40 )

oView:CreateFolder( 'FOLDER1', 'FOLDERGERAL' )

oView:AddSheet( 'FOLDER1', 'ABA01', STR0002 ) //"Processos referenciados"
oView:CreateHorizontalBox( 'GRIDC72', 100,,, 'FOLDER1', 'ABA01' )
                                                                                                                                                                                                            
If TamSX3("C71_CTA")[1] == 36
	oStruC71:RemoveField( "C71_CTA")
	oStruC71:SetProperty( "C71_CTACTB", MVC_VIEW_ORDEM, "28" )
EndIf

oView:SetOwnerView( 'VIEW_C71', 'FIELDSC71' )        
oView:SetOwnerView( 'VIEW_C72', 'GRIDC72' ) 

                                                                                                                                                                                                                                                                                                         
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
		//Funcao responsavel por setar o Status do registro para Branco³
		TAFAltStat( "C71", " " )		
	EndIf
	FwFormCommit( oModel )
        
End Transaction
       

Return .T.
 
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} TAF206Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacões caso seja necessario gerar um XML

lJob - Informa se foi chamado por Job

@return .T.

@author Denis R. de Oliveira
@since 18/02/2014
@version 1.0
/*/                                                                                                                                          
//-----------------------------------------------------------------------------------
Function TAF206Vld(cAlias,nRecno,nOpc,lJob)
Local aLogErro	:= {}

Default lJob := .F.

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C71->( Recno() )

If C71->C71_STATUS $ ( " |1" )
	
	//Valida o Codigo de Identificacao de Modelo
	If !Empty(C71->C71_CODMOD)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C71->C71_CODMOD
		xValRegTab("C01",cChave,3,,@aLogErro,, { "C71", "C71_CODMOD", nRecno } )
	EndIf   
	
	//Valida a Conta Contabil           
	If !Empty(C71->C71_CTA)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C71->C71_CTA
		xValRegTab("C1O",cChave,3,,@aLogErro,, { "C71", "C71_CTA", nRecno })
	EndIf 
	
	//Valida o Codigo Situação Tributaria        
	If !Empty(C71->C71_CSTPIS)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C71->C71_CSTPIS
		xValRegTab("C17",cChave,3,,@aLogErro,, { "C71", "C71_CSTPIS", nRecno })
	EndIf
	
	//Valida o Codigo Situacao Tributaria COFINS          
	If !Empty(C71->C71_CSTCOF)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C71->C71_CSTCOF
		xValRegTab("C17",cChave,3,,@aLogErro,, { "C71", "C71_CSTCOF", nRecno })
	EndIf
	
	//Valida a Grid Processos referenciados    
	dbSelectArea("C72")
	C72->(dbSetORder(1))
	If C72->(MsSeek(xFilial("C72") + C7Z->C7Z_ID))
		cId:=C72->C72_ID
		While (!C72->(Eof()) .And. cId==C72->C72_ID)
						
			cIndProc:= Alltrim(Posicione("C1G",3,xFilial("C1G")+C72->C72_NUMPRO,"C1G_INDPRO"))
			
			//Valida o Id. Processo Referenciado
			If !Empty(C72->C72_NUMPRO)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C72->C72_NUMPRO
				xValRegTab("C1G",cChave,3,,@aLogErro,, { "C71", "C72_NUMPRO", nRecno })
				If !(cIndProc $ ("1|3|9"))
					AADD(aLogErro,{"C72_NUMPRO","000006","C71", nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
				EndIf
			EndIf
			
			C72->(dbSkip())
			
		Enddo
		
	Endif 
	
	//Valida o Contador de Reinicio Operação
	If !(C71->C71_CRO > 0)
		AADD(aLogErro,{"C71_CRO","000520","C71", nRecno }) //STR0520 - "O valor informado no campo deve ser maior que 0 (zero)"
				
	EndIF   
	
	//Valida o Contador de Reducao Z
	If !(C71->C71_CRZ > 0)
		AADD(aLogErro,{"C71_CRZ","000520","C71", nRecno }) //STR0520 - "O valor informado no campo deve ser maior que 0 (zero)"
				
	EndIF   
	
	//Valida o COO na Reducao Z         
	If !(VAL(C71->C71_COOFIN) > 0)
		AADD(aLogErro,{"C71_COOFIN","000520","C71", nRecno }) //STR0520 - "O valor informado no campo deve ser maior que 0 (zero)"
				
	EndIF   
	
	//ATUALIZO O STATUS DO REGISTRO
	If Len(aLogErro)>0
		//Utilizo RecLock, pois o SETVALUE somente funciona em campos USADOS
		RecLock("C71",.F.)
			C71->C71_STATUS := "1"
		C71->( MsUnlock() )
	Else
		RecLock("C71",.F.)
			C71->C71_STATUS := "0"
		C71->( MsUnlock() )
	EndIf
	
Else
	AADD(aLogErro,{"C71_ID","000305", "C71", nRecno })//Registros que já foram transmitidos ao Fisco, não podem ser validados
EndIf

//Não apresento o alert quando utilizo o JOB para validar
If !lJob
	xValLogEr(aLogErro)
EndIf

Return(aLogErro)
	                                                                                                                                                                                                                                                                                          