#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA351.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA351
Cadastro MVC de Rendimentos de Dirigentes e Conselheiros - Imunes ou Isentas

@author Denis R de Oliveira
@since 03/06/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA351()

Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 )	//"Cadastro de Rendimentos de Dirigentes e Conselheiros - Imunes ou Isentas"
oBrw:SetAlias( 'CGO')
oBrw:SetMenuDef( 'TAFA351' ) 
CGO->(DbSetOrder(2))
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

Local aFuncao := {{ "" , "TAF351Vld" , "2" } }
Local aRotina := {}

aRotina	:=	xFunMnuTAF( "TAFA351" , , aFuncao )


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

Local oStruCGO 	:= 	FWFormStruct( 1, 'CGO' )
LocaL oModel 	:=  MPFormModel():New( 'TAFA351' , , , {|oModel| SaveModel( oModel ) } )  

lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )
	
If lVldModel
	oStruCGO:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel }) 		
EndIf     

oModel:AddFields('MODEL_CGO' , /*cOwner*/, oStruCGO) 

//Define a chave única de gravação das informações
oModel:GetModel('MODEL_CGO'):SetPrimaryKey( {'CGO_PERIOD','CGO_CPF','CGO_IDQUA'} ) 
             

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

Local oModel 	:= 	FWLoadModel( 'TAFA351' )
Local oStruCGO 	:= 	FWFormStruct( 2, 'CGO' )
Local oView 	:= 	FWFormView():New()


/*----------------------------------------------------------------------------------
Esrutura da View
-------------------------------------------------------------------------------------*/
oView:SetModel( oModel ) 

oStruCGO:RemoveField('CGO_ID') 
oStruCGO:RemoveField('CGO_IDQUA') 
                                       
oView:AddField('VIEW_CGO' , oStruCGO,  'MODEL_CGO' ) 
oView:EnableTitleView( 'VIEW_CGO', STR0001 ) //"Cadastro de Rendimentos de Dirigentes e Conselheiros - Imunes ou Isentas" 

/*-----------------------------------------------------------------------------------
Estrutura do Folder
-------------------------------------------------------------------------------------*/
oView:CreateHorizontalBox("PAINEL_PRINCIPAL",100)
oView:CreateFolder("FOLDER_PRINCIPAL","PAINEL_PRINCIPAL") // CGO - Rendimentos de Dirigentes e Conselheiros - Imunes ou Isentas

/*-----------------------------------------------------------------------------------
Amarração para exibição das informações
-------------------------------------------------------------------------------------*/
oView:SetOwnerView( 'VIEW_CGO', 'PAINEL_PRINCIPAL' )   

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
		TAFAltStat( "CGO", " " )	
	
	EndIf

	FwFormCommit( oModel )
        

End Transaction
       

Return .T.
 
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Taf351Vld

@author Denis R. de Oliveira
@since 03/06/2014
@version 1.0
/*/                                                                                                                                          
//------------------------------------------------------------------------------------
Function TAF351Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro	:= {}

Default lJob := .F.

If CGO->CGO_STATUS $ ( " |1" )      

	//Valida o Periodo     
	If Empty(CGO->CGO_PERIOD)
		Aadd( aLogErro, {"CGO_PERIOD","000001","CGO", nRecno}) //STR0001 - Campo Inconsistente ou Vazio
	EndIf   
	
	//Valida o CPF        
	If Empty(CGO->CGO_CPF)
		Aadd( aLogErro, {"CGO_CPF","000001","CGO", nRecno}) //STR0001 - Campo Inconsistente ou Vazio
	Else
	
		If !CGC(CGO->CGO_CPF,,.F.)
			aAdd(aLogErro,{'CGO_CPF','000006','CGO',nRecno}) //STR0006 - CPF Inconsistente
		EndIf
		
	EndIf  
		
	//Valida o Nome     
	If Empty(CGO->CGO_NOME)
		Aadd( aLogErro, {"CGO_NOME","000001","CGO", nRecno}) //STR0001 - Campo Inconsistente ou Vazio 
	EndIf
	
	//Valida a Qualificação        
	If Empty(CGO->CGO_IDQUA)
		Aadd( aLogErro, {"CGO_QUALIF", "000001", "CGO", nRecno}) //STR0001 - Campo Inconsistente ou Vazio
    Else 
    	//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := CGO->CGO_IDQUA
		xVldECFTab("CGN",cChave,1,,@aLogErro,{ "CGO","CGO_QUALIF",nRecno}) 
		
		cQualif:= Alltrim(Posicione("CGN",1,xFilial("CGN")+CGO->CGO_IDQUA,"CGN_CODIGO"))
		
		If !(cQualif $ ("10|11|12|13|14|15|16|17"))
		
			AADD(aLogErro,{"CGO_QUALIF","000026","CGO", nRecno}) //"Qualificação inválida para o registro. Selecione entre as seguintes opções:10 - Administrador sem Vínculo Empregatício;
													               //11 - Diretor sem Vínculo Empregatício;12 - Presidente sem Vínculo Empregatício;13 - Administrador com Vínculo Empregatício;
		                                                           //14 - Conselheiro de Administração ou Fiscal;15 - Diretor com Vínculo Empregatício;16 - Fundador;
		                                                           //17 - Presidente com Vínculo Empregatício" 
			
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
		RecLock("CGO",.F.)
		CGO->CGO_STATUS := "1"
		MsUnlock()
	Else
		RecLock("CGO",.F.)
		CGO->CGO_STATUS := "0"
		MsUnlock()
	EndIf	  	    	
	
Else
	
	AADD(aLogErro,{"CGO_ID","000017","CGO", nRecno})//STR0017 - Registro já validado.
	
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Não apresento o alert quando utilizo o JOB para validar³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lJob
	VldECFLog(aLogErro)
EndIf

Return(aLogErro)