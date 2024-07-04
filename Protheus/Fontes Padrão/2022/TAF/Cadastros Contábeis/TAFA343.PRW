#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA343.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA343
Cadastro MVC de Detalhamento das Exportações da Comercial Exportadora

@author Paulo Vilas Boas 
@since 26/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA343()

Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 )	//"Detalhamento das Exportações da Comercial Exportadora"
oBrw:SetAlias( 'CGJ')
oBrw:SetMenuDef( 'TAFA343' )
CGJ->(DbSetOrder(2))
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu
@author Paulo VilasBoas Santana
@since 26/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {{ "" , "TAF343Vld" , "2" } }
Local aRotina := {}

aRotina	:=	xFunMnuTAF( "TAFA343" , , aFuncao )

Return( aRotina )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Paulo Vilas Boas
@since 26/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruCGJ := FWFormStruct( 1, 'CGJ' )
LocaL oModel 	:=  MPFormModel():New( 'TAFA343' , , , {|oModel| SaveModel( oModel ) } )  


lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )
	
If lVldModel
	oStruCGJ:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel }) 		
EndIf

oModel:AddFields('MODEL_CGJ' , /*cOwner*/, oStruCGJ) 

//Define a chave única de gravação das informações
oModel:GetModel('MODEL_CGJ'):SetPrimaryKey( { 'CGJ_PERIOD','CGJ_CNPJ','CGJ_CODNCM'} )
             

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Paulo Vilas Boas Santana
@since 26/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel 	:= 	FWLoadModel( 'TAFA343' )
Local oStruCGJ:= 	FWFormStruct( 2, 'CGJ' )
Local oView 	:= 	FWFormView():New()


/*----------------------------------------------------------------------------------
Esrutura da View
-------------------------------------------------------------------------------------*/
oView:SetModel( oModel ) 

oStruCGJ:RemoveField('CGJ_ID')
                                       
oView:AddField('VIEW_CGJ' , oStruCGJ,  'MODEL_CGJ' ) 
oView:EnableTitleView( 'VIEW_CGJ', STR0001 ) //"Detalhamento das Exportações da Comercial Exportadora" 

/*-----------------------------------------------------------------------------------
Estrutura do Folder
-------------------------------------------------------------------------------------*/
oView:CreateHorizontalBox("PAINEL_PRINCIPAL",100)
oView:CreateFolder("FOLDER_PRINCIPAL","PAINEL_PRINCIPAL")

/*-----------------------------------------------------------------------------------
Amarração para exibição das informações
-------------------------------------------------------------------------------------*/
oView:SetOwnerView( 'VIEW_CGJ', 'PAINEL_PRINCIPAL' )   

Return oView    

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Paulo Vilas Boas 
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
		TAFAltStat( "CGJ", " " )	
	
	EndIf

	FwFormCommit( oModel )
        

End Transaction
       

Return .T.
 
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Taf343Vld

@author Paulo Vilas Boas Santana
@since 26/05/2014
@version 1.0
/*/                                                                                                                                          
//------------------------------------------------------------------------------------
Function TAF343Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro	:= {}
Local cBlc0CNPJ  	:= Iif( RetPessoa( SM0->M0_CGC ) == "J", SM0->M0_CGC, "" )
Local nAno			:= Year(CGJ->CGJ_PERIOD)

Default lJob := .F.

If CGJ->CGJ_STATUS $ ( " |1" )      

	//Valida o Periodo do lancamento    
	If Empty(CGJ->CGJ_PERIOD)
		Aadd( aLogErro, {"CGJ_PERIOD", "000001", "CGJ", nRecno }) //000001 - Campo Inconsistente ou Vazio
	EndIf
	
	//Valida o CNPJ
	If Empty(CGJ->CGJ_CNPJ)
		Aadd( aLogErro, {"CGJ_CNPJ", "000001", "CGJ", nRecno }) //000010 - Campo Inconsistente ou Vazio
	Else
		If !CGC(CGJ->CGJ_CNPJ,,.F.)
			Aadd( aLogErro, {"CGJ_CNPJ", "000006", "CGJ", nRecno }) //000006 - "CPF/CNPJ inconsistente." 
		EndIf
		
		//REGRA_CNPJ_DIFERENTE
		IF nAno == 2014
			If CGJ->CGJ_CNPJ == cBlc0CNPJ
				Aadd( aLogErro, {"CGJ_CNPJ", "000163", "CGJ", nRecno }) //STR0163 - "O valor do campo deve ser diferente do CNPJ do declarante."
			EndIf
		EndIF
	EndIf
	
	//Valida o Código NCM 
	If Empty(CGJ->CGJ_CODNCM)
		Aadd( aLogErro, {"CGJ_CODNCM", "000001", "CGJ", nRecno }) //000001 - Campo Inconsistente ou Vazio
    Else
    	//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := CGJ->CGJ_CODNCM
		xVldECFTab("C0A",cChave,3,,@aLogErro,{"CGJ","CGJ_CODNCM",nRecno })
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
		RecLock("CGJ",.F.)
		CGJ->CGJ_STATUS := "1"
		MsUnlock()
	Else
		RecLock("CGJ",.F.)
		CGJ->CGJ_STATUS := "0"
		MsUnlock()
	EndIf	  	    
	
	
Else
	
	AADD(aLogErro,{"CGJ_ID","000017", "CGJ", nRecno })//Registros que já foram transmitidos ao Fisco, não podem ser validados
	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Não apresento o alert quando utilizo o JOB para validar³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lJob
	VldECFLog(aLogErro)
EndIf

Return(aLogErro)