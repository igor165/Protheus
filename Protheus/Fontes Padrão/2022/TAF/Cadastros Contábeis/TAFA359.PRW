#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA359.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA359
Cadastro MVC de Informações de Optantes pelo Refis - Imunes ou Isentas

@author Denis R de Oliveira
@since 26/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA359()

Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 )	//"Cadastro de Informações de Optantes pelo Refis - Imunes ou Isentas"
oBrw:SetAlias( 'CGY') 
oBrw:SetMenuDef( 'TAFA359' ) 
CGY->(DbSetOrder(2))
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

Local aFuncao := {{ "" , "TAF359Vld" , "2" } }
Local aRotina := {}

aRotina	:=	xFunMnuTAF( "TAFA359" , , aFuncao )

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

Local oStruCGY 	:= 	FWFormStruct( 1, 'CGY' )
LocaL oModel 	:=  MPFormModel():New( 'TAFA359' , , , {|oModel| SaveModel( oModel ) } )  


lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )
	
If lVldModel
	oStruCGY:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel }) 		
EndIf

oModel:AddFields('MODEL_CGY' , /*cOwner*/, oStruCGY) 

//Define a chave única de gravação das informações
oModel:GetModel('MODEL_CGY'):SetPrimaryKey( {'CGY_PERIOD'} ) 
             

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

Local oModel 	:= 	FWLoadModel( 'TAFA359' )
Local oStruCGY 	:= 	FWFormStruct( 2, 'CGY' )
Local oView 	:= 	FWFormView():New()


/*----------------------------------------------------------------------------------
Esrutura da View
-------------------------------------------------------------------------------------*/
oView:SetModel( oModel ) 

oStruCGY:RemoveField('CGY_ID')
                                       
oView:AddField('VIEW_CGY' , oStruCGY,  'MODEL_CGY' ) 
oView:EnableTitleView( 'VIEW_CGY', STR0001 ) //"Cadastro de Informações de Optantes pelo Refis - Imunes ou Isentas" 

/*-----------------------------------------------------------------------------------
Estrutura do Folder
-------------------------------------------------------------------------------------*/
oView:CreateHorizontalBox("PAINEL_PRINCIPAL",100)
oView:CreateFolder("FOLDER_PRINCIPAL","PAINEL_PRINCIPAL") // CGY - Informações de Optantes pelo Refis - Imunes ou Isentas

/*-----------------------------------------------------------------------------------
Amarração para exibição das informações
-------------------------------------------------------------------------------------*/
oView:SetOwnerView( 'VIEW_CGY', 'PAINEL_PRINCIPAL' )   

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
		TAFAltStat( "CGY", " " )	
	
	EndIf

	FwFormCommit( oModel )
        

End Transaction
       

Return .T.
 
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Taf359Vld

@author Denis R. de Oliveira
@since 26/05/2014
@version 1.0
/*/                                                                                                                                          
//------------------------------------------------------------------------------------
Function TAF359Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro	:= {}

Default lJob := .F.

If CGY->CGY_STATUS $ ( " |1" )      

	//Valida o Periodo do lancamento     
	If Empty(CGY->CGY_PERIOD)
		Aadd( aLogErro, {"CGY_PERIOD", "000001", "CGY", nRecno}) //STR0001 - Campo Inconsistente ou Vazio
	EndIf
	
	//--------
	// Combos
	//--------
	If Empty(CGY->CGY_MES)                                           
		AADD(aLogErro,{"CGY_MES","000001","CGY",nRecno}) //STR0001 - "Campo inconsistente ou vazio." 
	Else
		If !CGY->CGY_MES $ ("01|02|03|04|05|06|07|08|09|10|11|12|")
			AADD(aLogErro,{"CGY_MES","000002", "CGY",nRecno }) //STR0002 - "Conteúdo do campo não condiz com as opções possíveis."   
		EndIf
	EndIf
	
	/*REGRA_MES_FORA_PERIOD*/
	xVldECFReg("CGY","REGRA_MES_FORA_PERIODO",@aLogErro, {CGY->CGY_PERIOD,CGY->CGY_MES})	
	
	//---------------------
	// Campos obrigatórios
	//---------------------
	If Empty(CGY->CGY_ACRPAT)
		Aadd( aLogErro, {"CGY_ACRPAT", "000001", "CGY", nRecno}) //STR0001 - Campo Inconsistente ou Vazio
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
		RecLock("CGY",.F.)
		CGY->CGY_STATUS := "1"
		MsUnlock()
	Else
		RecLock("CGY",.F.)
		CGY->CGY_STATUS := "0"
		MsUnlock()
	EndIf	  	    
	
	
Else
	
	AADD(aLogErro,{"CGY_ID","000017","CGY", nRecno})//STR0017 - Registro já validado.
	
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Não apresento o alert quando utilizo o JOB para validar³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lJob
	VldECFLog(aLogErro)
EndIf


Return(aLogErro)