#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA329.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA329
Cadastro MVC de Pagamentos ou Rend. Recebidos Exterior/Não Residente

@author Paulo Vilas Boas 
@since 26/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA329()

Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 )	//"Pagamentos ou Rend. Recebidos Exterior/Não Residente"
oBrw:SetAlias( 'CFQ')
oBrw:SetMenuDef( 'TAFA329' )
CFQ->(DbSetOrder(2))
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

Local aFuncao := {{ "" , "TAF329Vld" , "2" } }
Local aRotina := {}

aRotina	:=	xFunMnuTAF( "TAFA329" , , aFuncao )

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

Local oStruCFQ:= 	FWFormStruct( 1, 'CFQ' )
LocaL oModel 	:=  MPFormModel():New( 'TAFA329' , , , {|oModel| SaveModel( oModel ) } )  


lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )
	
If lVldModel
	oStruCFQ:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel }) 		
EndIf

oModel:AddFields('MODEL_CFQ' , /*cOwner*/, oStruCFQ) 

//Define a chave única de gravação das informações
oModel:GetModel('MODEL_CFQ'):SetPrimaryKey( { 'CFQ_PERIOD','CFQ_TIPEXT','CFQ_PAIS'} ) 
             

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

Local oModel 	:= 	FWLoadModel( 'TAFA329' )
Local oStruCFQ	:= 	FWFormStruct( 2, 'CFQ' )
Local oView 	:= 	FWFormView():New()


/*----------------------------------------------------------------------------------
Esrutura da View
-------------------------------------------------------------------------------------*/
oView:SetModel( oModel ) 

oStruCFQ:RemoveField('CFQ_ID')
                                       
oView:AddField('VIEW_CFQ' , oStruCFQ,  'MODEL_CFQ' ) 
oView:EnableTitleView( 'VIEW_CFQ', STR0001 ) //"Pagamentos ou Rend. Recebidos Exterior/Não Residente" 

/*-----------------------------------------------------------------------------------
Estrutura do Folder
-------------------------------------------------------------------------------------*/
oView:CreateHorizontalBox("PAINEL_PRINCIPAL",100)
oView:CreateFolder("FOLDER_PRINCIPAL","PAINEL_PRINCIPAL")

/*-----------------------------------------------------------------------------------
Amarração para exibição das informações
-------------------------------------------------------------------------------------*/
oView:SetOwnerView( 'VIEW_CFQ', 'PAINEL_PRINCIPAL' )   
If TamSX3("CFQ_NATOPE")[1] == 36
	oStruCFQ:RemoveField( "CFQ_NATOPE")
	oStruCFQ:SetProperty( "CFQ_CODNAT", MVC_VIEW_ORDEM, "08" )
EndIf   

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
		TAFAltStat( "CFQ", " " )	
	
	EndIf

	FwFormCommit( oModel )
        

End Transaction
       

Return .T.
 
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Taf329Vld

@author Paulo Vilas Boas Santana
@since 26/05/2014
@version 1.0
/*/                                                                                                                                          
//------------------------------------------------------------------------------------
Function TAF329Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro	:= {}
Local cRecExt		:= Posicione("CHD",1,xFilial("CHD")+TAFEcfPer(CFQ->CFQ_PERIOD),"CHD_INDREC") //Recebimento do exterior
Local cPgtoExt	:= Posicione("CHD",1,xFilial("CHD")+TAFEcfPer(CFQ->CFQ_PERIOD),"CHD_INDPGE") //Pagamento ao exterior

Default lJob := .F.

If CFQ->CFQ_STATUS $ ( " |1" )      

	//Valida o Periodo do lancamento    
	If Empty(CFQ->CFQ_PERIOD)
		Aadd( aLogErro, {"CFQ_PERIOD", "000001", "CFQ", nRecno }) //000010 - Campo Inconsistente ou Vazio
	EndIf
	
	//Valida o Tipo
    If Empty(CFQ->CFQ_TIPEXT)
		Aadd( aLogErro, {"CFQ_TIPEXT", "000001", "CFQ", nRecno }) //STR0001 - Campo Inconsistente ou Vazio
    ElseIf !CFQ->CFQ_TIPEXT $ ('12')
    	Aadd( aLogErro, {"CFQ_TIPEXT", "000002", "CFQ", nRecno }) //STR0002 - Conteúdo do campo não condiz
    EndIf
	
	//Valida o País
    If Empty(CFQ->CFQ_PAIS)
		Aadd( aLogErro, {"CFQ_PAIS", "000001", "CFQ", nRecno }) //STR0001 - Campo Inconsistente ou Vazio
    Else
    	//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := CFQ->CFQ_PAIS
		xVldECFTab("C08",cChave,3,,@aLogErro,{"CFQ","CFQ_PAIS",nRecno })
    EndIf
    
    //Valida a forma de recebimento
    If Empty(CFQ->CFQ_FORMA)
		Aadd( aLogErro, {"CFQ_FORMA", "000001", "CFQ", nRecno }) //STR0001 - Campo Inconsistente ou Vazio
    ElseIf !CFQ->CFQ_FORMA $ ('123456')
    	Aadd( aLogErro, {"CFQ_FORMA", "000002", "CFQ", nRecno }) //STR0002 - Conteúdo do campo não condiz
    EndIf
    
	//Valida a natureza da operação
	If Empty(CFQ->CFQ_NATOPE)
		Aadd( aLogErro, {"CFQ_NATOPE", "000001", "CFQ", nRecno }) //STR0001 - Campo Inconsistente ou Vazio
    Else
    	//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := CFQ->CFQ_NATOPE
		xVldECFTab("C1N",cChave,3,,@aLogErro,{"CFQ","CFQ_NATOPE",nRecno })
    EndIf
    
    //Valida o valor no período
    If Empty(CFQ->CFQ_VLPERI)
		Aadd( aLogErro, {"CFQ_VLPERI", "000001", "CFQ", nRecno }) //STR0001 - Campo Inconsistente ou Vazio
    EndIf
    
    //REGRA_TIP_EXT_PERMITIDO
	If CFQ->CFQ_TIPEXT == "1" .And. cRecExt <> "1"
		Aadd( aLogErro, {"CFQ_TIPEXT", "000204", "CFQ", nRecno }) //STR0204 - O Campo 'Tipo' só pode ser igual a '1 - Rendimentos recebidos' quando o campo 'Rend Exter' do bloco de abertura (Registro 0020) for igual a '1 - Sim'.
	EndIf
	
	If CFQ->CFQ_TIPEXT == "2" .And. cPgtoExt <> "1"
		Aadd( aLogErro, {"CFQ_TIPEXT", "000205", "CFQ", nRecno }) //STR0205 - O Campo 'Tipo' só pode ser igual a '2 - Pagamentos' quando o campo 'Pag Exterior' do bloco de abertura (Registro 0020) for igual a '1 - Sim'.
	EndIf
	
	//REGRA_FORMA_PAGTO_INVALIDA
	If CFQ->CFQ_FORMA == "4" .And. CFQ->CFQ_TIPEXT == "2" 
		Aadd( aLogErro, {"CFQ_FORMA", "000206", "CFQ", nRecno }) //STR0206 - "Quando o campo 'Tipo' for igual a '2 - Pagamentos', o Campo 'Forma' não pode ser igual a '4 - Depósito em Conta do Exterior'."
	EndIf
	
	If CFQ->CFQ_FORMA == "5" .And. CFQ->CFQ_TIPEXT == "1" 
		Aadd( aLogErro, {"CFQ_FORMA", "000207", "CFQ", nRecno }) //STR0207 - "Quando o campo 'Tipo' for igual a '1 - Rendimentos recebidos', o Campo 'Forma' não pode ser igual a '5 - Utilização de Recursos Mantidos no Exterior'."
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
		RecLock("CFQ",.F.)
		CFQ->CFQ_STATUS := "1"
		MsUnlock()
	Else
		RecLock("CFQ",.F.)
		CFQ->CFQ_STATUS := "0"
		MsUnlock()
	EndIf	  	    
	
	
Else
	
	AADD(aLogErro,{"CFQ_ID","000017", "CFQ", nRecno })//Registros que já foram transmitidos ao Fisco, não podem ser validados
	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Não apresento o alert quando utilizo o JOB para validar³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lJob
	VldECFLog(aLogErro)
EndIf

Return(aLogErro)