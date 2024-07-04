#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA355.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA355
Cadastro MVC de Dados de Sucessoras

@author Denis R de Oliveira
@since 23/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA355()

Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 )	//"Cadastro de Dados de Sucessoras"
oBrw:SetAlias( 'CGT')
oBrw:SetMenuDef( 'TAFA355' ) 
CGT->(DbSetOrder(2))
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu
@author Denis R de Oliveira
@since 23/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {{ "" , "TAF355Vld" , "2" } }
Local aRotina := {}

aRotina	:=	xFunMnuTAF( "TAFA355" , , aFuncao )


Return( aRotina )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Denis R de Oliveira
@since 23/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruCGT 	:= 	FWFormStruct( 1, 'CGT' )
LocaL oModel 	:=  MPFormModel():New( 'TAFA355' , , , {|oModel| SaveModel( oModel ) } )  

lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )
	
If lVldModel
	oStruCGT:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel }) 		
EndIf     

oModel:AddFields('MODEL_CGT' , /*cOwner*/, oStruCGT) 

//Define a chave única de gravação das informações
oModel:GetModel('MODEL_CGT'):SetPrimaryKey( {'CGT_PERIOD','CGT_CNPJ'} ) 
             

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Denis R de Oliveira
@since 23/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel 	:= 	FWLoadModel( 'TAFA355' )
Local oStruCGT 	:= 	FWFormStruct( 2, 'CGT' )
Local oView 	:= 	FWFormView():New()


/*----------------------------------------------------------------------------------
Esrutura da View
-------------------------------------------------------------------------------------*/
oView:SetModel( oModel ) 

oStruCGT:RemoveField('CGT_ID') 
                                       
oView:AddField('VIEW_CGT' , oStruCGT,  'MODEL_CGT' ) 
oView:EnableTitleView( 'VIEW_CGT', STR0001 ) //"Cadastro de Dados de Sucessoras" 

/*-----------------------------------------------------------------------------------
Estrutura do Folder
-------------------------------------------------------------------------------------*/
oView:CreateHorizontalBox("PAINEL_PRINCIPAL",100)
oView:CreateFolder("FOLDER_PRINCIPAL","PAINEL_PRINCIPAL") // CGT - Dados de Sucessoras

/*-----------------------------------------------------------------------------------
Amarração para exibição das informações
-------------------------------------------------------------------------------------*/
oView:SetOwnerView( 'VIEW_CGT', 'PAINEL_PRINCIPAL' )   

Return oView    

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Denis R. de Oliveira
@since 23/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

Local nOperation := oModel:GetOperation()

Begin Transaction

	If nOperation == MODEL_OPERATION_UPDATE
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Funcao responsavel por setar o Status do registro para Branco³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TAFAltStat( "CGT", " " )	
	
	EndIf

	FwFormCommit( oModel )
        

End Transaction
       

Return .T.
 
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Taf355Vld

@author Denis R. de Oliveira
@since 23/05/2014
@version 1.0
/*/                                                                                                                                          
//------------------------------------------------------------------------------------
Function TAF355Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro	:= {}

Default lJob := .F.

If CGT->CGT_STATUS $ ( " |1" )      

	//Valida o Periodo     
	If Empty(CGT->CGT_PERIOD)
		Aadd( aLogErro, {"CGT_PERIOD","000001","CGT", nRecno}) //STR0001 - Campo Inconsistente ou Vazio
	EndIf
	
	//Valida o CNPJ        
	If Empty(CGT->CGT_CNPJ)
		Aadd( aLogErro, {"CGT_CNPJ","000001","CGT", nRecno}) //STR0001 - Campo Inconsistente ou Vazio
	Else
	
		If !CGC(CGT->CGT_CNPJ,,.F.)
			aAdd(aLogErro,{'CGT_CNPJ','000006','CGT',nRecno}) //STR0006 - CNPJ Inconsistente
		EndIf
		
	EndIf  
		
	//Valida o Nome Empresarial         
	If Empty(CGT->CGT_NOMEMP)
		Aadd( aLogErro, {"CGT_NOMEMP","000001","CGT", nRecno}) //STR0001 - Campo Inconsistente ou Vazio 
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ATUALIZO O STATUS DO REGISTRO³
	//³1 = Registro Invalido        ³
	//³0 = Registro Valido          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aLogErro)>0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Utilizo RecLock, pois o SETVALUE somente funciona em campos USADOS³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RecLock("CGT",.F.)
		CGT->CGT_STATUS := "1"
		MsUnlock()
	Else
		RecLock("CGT",.F.)
		CGT->CGT_STATUS := "0"
		MsUnlock()
	EndIf	  	    	
		
Else
	
	AADD(aLogErro,{"CGT_ID","000017","CGT",nRecno})//STR0017 - Registro já validado.
	
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Não apresento o alert quando utilizo o JOB para validar³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lJob
	VldECFLog(aLogErro)
EndIf

Return(aLogErro)