#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA353.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA353
Cadastro MVC de Fundos/Clubes de Investimento

@author Denis R de Oliveira
@since 03/06/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA353()

Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 )	//"Cadastro de Fundos/Clubes de Investimento"
oBrw:SetAlias( 'CGQ')
oBrw:SetMenuDef( 'TAFA353' ) 
CGQ->(DbSetOrder(2))
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu
@author Denis R de Oliveira
@since 03/06/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {{ "" , "TAF353Vld" , "2" } }
Local aRotina := {}

aRotina	:=	xFunMnuTAF( "TAFA353" , , aFuncao )


Return( aRotina )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Denis R de Oliveira
@since 03/06/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruCGQ 	:= 	FWFormStruct( 1, 'CGQ' )
LocaL oModel 	:=  MPFormModel():New( 'TAFA353' , , , {|oModel| SaveModel( oModel ) } )  

lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )
	
If lVldModel
	oStruCGQ:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel }) 		
EndIf     

oModel:AddFields('MODEL_CGQ' , /*cOwner*/, oStruCGQ) 

//Define a chave única de gravação das informações
oModel:GetModel('MODEL_CGQ'):SetPrimaryKey( {'CGQ_PERIOD','CGQ_CNPJ'} ) 
             

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Denis R de Oliveira
@since 03/06/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel 	:= 	FWLoadModel( 'TAFA353' )
Local oStruCGQ 	:= 	FWFormStruct( 2, 'CGQ' )
Local oView 	:= 	FWFormView():New()


/*----------------------------------------------------------------------------------
Esrutura da View
-------------------------------------------------------------------------------------*/
oView:SetModel( oModel ) 

oStruCGQ:RemoveField('CGQ_ID') 
                                       
oView:AddField('VIEW_CGQ' , oStruCGQ,  'MODEL_CGQ' ) 
oView:EnableTitleView( 'VIEW_CGQ', STR0001 ) //"Cadastro de Fundos/Clubes de Investimento" 

/*-----------------------------------------------------------------------------------
Estrutura do Folder
-------------------------------------------------------------------------------------*/
oView:CreateHorizontalBox("PAINEL_PRINCIPAL",100)
oView:CreateFolder("FOLDER_PRINCIPAL","PAINEL_PRINCIPAL") // CGQ - Fundos/Clubes de Investimento

/*-----------------------------------------------------------------------------------
Amarração para exibição das informações
-------------------------------------------------------------------------------------*/
oView:SetOwnerView( 'VIEW_CGQ', 'PAINEL_PRINCIPAL' )   

Return oView    

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Denis R. de Oliveira
@since 03/06/2014
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
		TAFAltStat( "CGQ", " " )	
	
	EndIf

	FwFormCommit( oModel )
        

End Transaction
       

Return .T.
 
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Taf353Vld

@author Denis R. de Oliveira
@since 03/06/2014
@version 1.0
/*/                                                                                                                                          
//------------------------------------------------------------------------------------
Function TAF353Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro	:= {}

Default lJob := .F.

If CGQ->CGQ_STATUS $ ( " |1" )      

	//Valida o Periodo     
	If Empty(CGQ->CGQ_PERIOD)
		Aadd( aLogErro, {"CGQ_PERIOD","000001","CGQ", nRecno}) //STR0001 - Campo Inconsistente ou Vazio
	EndIf   
	
	//Valida o CNPJ  
	If Empty(CGQ->CGQ_CNPJ)
		Aadd( aLogErro, {"CGQ_CNPJ","000001","CGQ", nRecno}) //STR0001 - Campo Inconsistente ou Vazio
	Else
		/*REGRA_VALIDA_CNPJ*/
		If !CGC(CGQ->CGQ_CNPJ,,.F.)
			aAdd(aLogErro,{'CGQ_CNPJ','000006','CGQ',nRecno}) //STR0006 - CNPJ Inconsistente
		EndIf
	EndIf  
		
	//Valida a Quantidade de Quotistas   
	If Empty(CGQ->CGQ_QUOTIS)
		Aadd( aLogErro, {"CGQ_QUOTIS","000001","CGQ", nRecno}) //STR0001 - Campo Inconsistente ou Vazio
	EndIf  
	
	//Valida a Quantidade de Quotas   
	If Empty(CGQ->CGQ_QUOTA)
		Aadd( aLogErro, {"CGQ_QUOTA","000001","CGQ", nRecno}) //STR0001 - Campo Inconsistente ou Vazio
	EndIf  
	
	//Valida o Patrimônio 
	If Empty(CGQ->CGQ_PATRIM)
		Aadd( aLogErro, {"CGQ_PATRIM","000001","CGQ", nRecno}) //STR0001 - Campo Inconsistente ou Vazio
	EndIf  
	
	//Valida a Data de Abertura
	If Empty(CGQ->CGQ_DTABER)
		Aadd( aLogErro, {"CGQ_DTABER","000001","CGQ", nRecno}) //STR0001 - Campo Inconsistente ou Vazio
	Else
		/*--------------------------------------*
		 | Validações conforme Layout Dez/14    |
		 | Responsável: Evandro dos S. Oliveira |
		 | Data: 05/02/2014					     |
		 *--------------------------------------*/ 
		/*REGRA_DATA_ABERT_ENCER*/
		If !Empty(CGQ->CGQ_DTENCE) .And. CGQ->CGQ_DTABER > CGQ->CGQ_DTENCE 
			AADD(aLogErro,{"CGQ_DTABER","000191","CGQ",nRecno}) //STR0191 - O campo "Dt Abertura" não pode ser maior que o campo "Dt Encerram".
		EndIf
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
		RecLock("CGQ",.F.)
		CGQ->CGQ_STATUS := "1"
		MsUnlock()
	Else
		RecLock("CGQ",.F.)
		CGQ->CGQ_STATUS := "0"
		MsUnlock()
	EndIf	  	    	
	
Else
	
	AADD(aLogErro,{"CGQ_ID","000017","CGQ", nRecno})//STR0017 - Registro já validado.
	
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Não apresento o alert quando utilizo o JOB para validar³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lJob
	VldECFLog(aLogErro)
EndIf

Return(aLogErro) 