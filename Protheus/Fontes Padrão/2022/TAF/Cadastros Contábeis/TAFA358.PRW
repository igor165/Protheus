#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA358.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA358
Cadastro MVC do Mês das Informações de Optantes pelo Refis Lucro R/P/A

@author Denis R de Oliveira
@since 19/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA358()

Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 )	//"Cadastro do Mês das Informações de Optantes pelo Refis Lucro R/P/A"
oBrw:SetAlias( 'CGW')
oBrw:SetMenuDef( 'TAFA358' )
CGW->(DbSetOrder(2))
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu
@author Denis R de Oliveira
@since 19/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {{ "" , "TAF358Vld" , "2" } }
Local aRotina := {}

aRotina	:=	xFunMnuTAF( "TAFA358" , , aFuncao )


Return( aRotina )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Denis R de Oliveira
@since 19/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruCGW 	:= 	FWFormStruct( 1, 'CGW' )
Local oStruCGX 	:= 	FWFormStruct( 1, 'CGX' )
LocaL oModel 	:=  MPFormModel():New( 'TAFA358' , , , {|oModel| SaveModel( oModel ) } )  

lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )
	
If lVldModel
	oStruCGW:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel }) 		
EndIf                                                                                             	

oModel:AddFields('MODEL_CGW' , /*cOwner*/, oStruCGW) 

oModel:AddGrid ('MODEL_CGX', 'MODEL_CGW',oStruCGX)  
oModel:GetModel('MODEL_CGX'):SetOptional( .T. )
oModel:GetModel('MODEL_CGX'):SetUniqueLine( { 'CGX_IDCODC' } ) 
 
/*-----------------------------------------------------------------------------------
Abaixo realiza-se a amarração das tabelas
-------------------------------------------------------------------------------------*/
//Define a chave única de gravação das informações
oModel:GetModel('MODEL_CGW'):SetPrimaryKey( {'CGW_PERIOD','CGW_MES'} ) 

oModel:SetRelation(  "MODEL_CGX", {{ "CGX_FILIAL","xFilial('CGX')" },{"CGX_ID","CGW_ID"}}, CGX->( IndexKey(1)))
           

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Denis R de Oliveira
@since 19/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel 	:= 	FWLoadModel( 'TAFA358' )
Local oStruCGW 	:= 	FWFormStruct( 2, 'CGW' )
Local oStruCGX	:= 	FWFormStruct( 2, 'CGX' )

Local oView 	:= 	FWFormView():New()
 

/*----------------------------------------------------------------------------------
Esrutura da View
-------------------------------------------------------------------------------------*/

oStruCGW:RemoveField('CGW_ID')  
oStruCGW:RemoveField('CGW_IDPERA')
oStruCGX:RemoveField('CGX_IDCODC')

oView:SetModel( oModel )
                                       
oView:AddField('VIEW_CGW' , oStruCGW,  'MODEL_CGW' ) 
oView:EnableTitleView( 'VIEW_CGW', STR0001 ) //"Cadastro do Mês das Informações de Optantes pelo Refis Lucro R/P/A" 

oView:AddGrid( 'VIEW_CGX' , oStruCGX,  'MODEL_CGX' )
oView:EnableTitleView( 'VIEW_CGX', STR0002 ) //"Info.opt. refis Lucro R/P/A"


/*-----------------------------------------------------------------------------------
Estrutura do Folder
-------------------------------------------------------------------------------------*/
oView:CreateHorizontalBox("PAINEL_PRINCIPAL",25)
oView:CreateFolder("FOLDER_PRINCIPAL","PAINEL_PRINCIPAL") // CGW - Mês das Informações de Optantes pelo Refis Lucro R/P/A

oView:CreateHorizontalBox("PAINEL_INFERIOR",75)// CGX - Info.opt. refis Lucro R/P/A
oView:CreateFolder("FOLDER_INFERIOR","PAINEL_INFERIOR")

/*-----------------------------------------------------------------------------------
Amarração para exibição das informações
-------------------------------------------------------------------------------------*/
oView:SetOwnerView( 'VIEW_CGW', 'PAINEL_PRINCIPAL' )   

oView:SetOwnerView( 'VIEW_CGX', 'PAINEL_INFERIOR' ) 

Return oView    

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Denis R. de Oliveira
@since 19/05/2014
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
		TAFAltStat( "CGW", " " )	
	
	EndIf

	FwFormCommit( oModel )
        

End Transaction
       

Return .T.
 
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Taf358Vld

@author Denis R. de Oliveira
@since 19/05/2014
@version 1.0
/*/                                                                                                                                          
//------------------------------------------------------------------------------------
Function TAF358Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro	:= {}

Default lJob := .F.

If CGW->CGW_STATUS $ ( " |1" )      

	//Valida o Periodo     
	If Empty(CGW->CGW_PERIOD)
		Aadd( aLogErro, {"CGW_PERIOD","000001","CGW", nRecno}) //STR0001 - Campo Inconsistente ou Vazio
	EndIf   
			
	//Valida o Mês      
	If Empty(CGW->CGW_MES)
		Aadd( aLogErro, {"CGW_MES","000001", "CGW", nRecno}) //STR0001 - Campo Inconsistente ou Vazio
    Else 
		
		If !(CGW->CGW_MES $ ("01|02|03|04|05|06|07|08|09|10|11|12"))
		
			AADD(aLogErro,{"CGW_MES","000002","CGW", nRecno}) //STR0002 - Conteúdo do campo não condiz com as opções possíveis.	
			
        EndIf
   
	EndIf  
	
	/*REGRA_MES_FORA_PERIOD*/
	xVldECFReg("CGW","REGRA_MES_FORA_PERIODO",@aLogErro, {CGW->CGW_PERIOD,CGW->CGW_MES})
	
	//--------------------------------------------//                                                                            
	/* Valida a Grid Info.opt. refis Lucro R/P/A  */
	//--------------------------------------------//
	dbSelectArea("CGX")
	CGX->(dbSetORder(1))
	If CGX->(MsSeek(xFilial("CGX") + CGW->CGW_ID))
		cId:=CGX->CGX_ID
		While (!CGX->(Eof()) .And. cId==CGX->CGX_ID)	
			//------------------
			// Consultas padrão
			//------------------			
			If Empty(CGX->CGX_IDCODC)                                            
				Aadd(aLogErro,{"CGX_CODCTA","000001","CGX",nRecno}) //STR0001 - "Campo inconsistente ou vazio." 
			Else
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := CGX->CGX_IDCODC
				xVldECFTab("CH6",cChave,1,,@aLogErro,{ "CGX","CGX_CODCTA", nRecno })
			EndIf	
			
			CGX->(dbSkip())
			
		Enddo		
	Endif
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ATUALIZO O STATUS DO REGISTRO³
	//³1 = Registro Invalido        ³
	//³0 = Registro Valido          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aLogErro)>0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Utilizo RecLock, pois o SETVALUE somente funciona em campos USADOS³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RecLock("CGW",.F.)
		CGW->CGW_STATUS := "1"
		MsUnlock()
	Else
		RecLock("CGW",.F.)
		CGW->CGW_STATUS := "0"
		MsUnlock()
	EndIf	  	    	
	
Else
	
	AADD(aLogErro,{"CGW_ID","000017","CGW", nRecno})//STR0017 - Registro já validado.
	
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Não apresento o alert quando utilizo o JOB para validar³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lJob
	VldECFLog(aLogErro)
EndIf

Return(aLogErro)