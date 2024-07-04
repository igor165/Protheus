#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA360.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA360
Cadastro MVC de Informações Optantes pelo PAES

@author Denis R de Oliveira
@since 26/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA360()

Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 )	//"Cadastro de Informações Optantes pelo PAES"
oBrw:SetAlias( 'CGZ')
oBrw:SetMenuDef( 'TAFA360' )
CGZ->(DbSetOrder(2))
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu
@author Denis R de Oliveira
@since 26/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {{ "" , "TAF360Vld" , "2" } }
Local aRotina := {}

aRotina	:=	xFunMnuTAF( "TAFA360" , , aFuncao )

Return( aRotina )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Denis R de Oliveira
@since 26/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruCGZ 	:= 	FWFormStruct( 1, 'CGZ' )
LocaL oModel 	:=  MPFormModel():New( 'TAFA360' , , , {|oModel| SaveModel( oModel ) } )  


lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )
	
If lVldModel
	oStruCGZ:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel }) 		
EndIf

oModel:AddFields('MODEL_CGZ' , /*cOwner*/, oStruCGZ) 

//Define a chave única de gravação das informações
oModel:GetModel('MODEL_CGZ'):SetPrimaryKey( {'CGZ_PERIOD','CGZ_MES'} ) 
             

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Denis R de Oliveira
@since 26/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel 	:= 	FWLoadModel( 'TAFA360' )
Local oStruCGZ 	:= 	FWFormStruct( 2, 'CGZ' )
Local oView 	:= 	FWFormView():New()


/*----------------------------------------------------------------------------------
Esrutura da View
-------------------------------------------------------------------------------------*/
oView:SetModel( oModel ) 

oStruCGZ:RemoveField('CGZ_ID')
                                       
oView:AddField('VIEW_CGZ' , oStruCGZ,  'MODEL_CGZ' ) 
oView:EnableTitleView( 'VIEW_CGZ', STR0001 ) //"Cadastro de Informações Optantes pelo PAES" 

/*-----------------------------------------------------------------------------------
Estrutura do Folder
-------------------------------------------------------------------------------------*/
oView:CreateHorizontalBox("PAINEL_PRINCIPAL",100)
oView:CreateFolder("FOLDER_PRINCIPAL","PAINEL_PRINCIPAL") // CGZ - Informações Optantes pelo PAES

/*-----------------------------------------------------------------------------------
Amarração para exibição das informações
-------------------------------------------------------------------------------------*/
oView:SetOwnerView( 'VIEW_CGZ', 'PAINEL_PRINCIPAL' )   

Return oView    

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Denis R. de Oliveira
@since 26/05/2014
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
		TAFAltStat( "CGZ", " " )	
	
	EndIf

	FwFormCommit( oModel )
        

End Transaction
       

Return .T.
 
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Taf360Vld

@author Denis R. de Oliveira
@since 26/05/2014
@version 1.0
/*/                                                                                                                                          
//------------------------------------------------------------------------------------
Function TAF360Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro	:= {}

Default lJob := .F.

If CGZ->CGZ_STATUS $ ( " |1" )      

	//Valida o Periodo do lancamento    
	If Empty(CGZ->CGZ_PERIOD)
		Aadd( aLogErro, {"CGZ_PERIOD", "000001", "CGZ", nRecno}) //STR0001 - Campo Inconsistente ou Vazio
	EndIf
	
	//Valida o Mes                      
	If Empty(CGZ->CGZ_MES)
		Aadd( aLogErro, {"CGZ_MES", "000001", "CGZ", nRecno}) //STR0001 - Campo Inconsistente ou Vazio
	Else
		If !(CGZ->CGZ_MES $ ("01|02|03|04|05|06|07|08|09|10|11|12"))
			AADD(aLogErro,{"CGZ_MES","000002","CGV", nRecno}) //STR0002 - Conteúdo do campo não condiz com as opções possíveis.
		EndIf 
	EndIf  
	
	//Valida a Receita Bruta            
	If Empty(CGZ->CGZ_RECBRU)
		Aadd( aLogErro, {"CGZ_RECBRU", "000001", "CGZ", nRecno}) //STR0001 - Campo Inconsistente ou Vazio
	EndIf  

	/*REGRA_MES_FORA_PERIOD*/
	xVldECFReg("CGZ","REGRA_MES_FORA_PERIODO",@aLogErro, {CGZ->CGZ_PERIOD,CGZ->CGZ_MES})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ATUALIZO O STATUS DO REGISTRO³
	//³1 = Registro Invalido        ³
	//³0 = Registro Valido          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aLogErro)>0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Utilizo RecLock, pois o SETVALUE somente funciona em campos USADOS³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RecLock("CGZ",.F.)
		CGZ->CGZ_STATUS := "1"
		MsUnlock()
	Else
		RecLock("CGZ",.F.)
		CGZ->CGZ_STATUS := "0"
		MsUnlock()
	EndIf	  	    
	
	
Else
	
	AADD(aLogErro,{"CGZ_ID","000017","CGZ", nRecno})//STR0017 - Registro já validado.
	
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Não apresento o alert quando utilizo o JOB para validar³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lJob
	VldECFLog(aLogErro)
EndIf


Return(aLogErro)