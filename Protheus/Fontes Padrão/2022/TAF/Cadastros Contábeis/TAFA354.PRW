#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA354.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA354
Cadastro MVC de Participações em Consórcios de Empresas

@author Denis R de Oliveira
@since 19/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA354()

Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 )	//"Cadastro de Participações em Consórcios de Empresas"
oBrw:SetAlias( 'CGR')
oBrw:SetMenuDef( 'TAFA354' )
CGR->(DbSetOrder(2))
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

Local aFuncao := {{ "" , "TAF354Vld" , "2" } }
Local aRotina := {}

aRotina	:=	xFunMnuTAF( "TAFA354" , , aFuncao )


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

Local oStruCGR 	:= 	FWFormStruct( 1, 'CGR' )
Local oStruCGS 	:= 	FWFormStruct( 1, 'CGS' )
LocaL oModel 	:=  MPFormModel():New( 'TAFA354' , , , {|oModel| SaveModel( oModel ) } )  

lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )
	
If lVldModel
	oStruCGR:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel }) 		
EndIf

oModel:AddFields('MODEL_CGR' , /*cOwner*/, oStruCGR) 

oModel:AddGrid ('MODEL_CGS', 'MODEL_CGR',oStruCGS)  
oModel:GetModel('MODEL_CGS'):SetOptional( .T. )
oModel:GetModel('MODEL_CGS'):SetUniqueLine( { 'CGS_CNPJEM' } ) 
 
/*-----------------------------------------------------------------------------------
Abaixo realiza-se a amarração das tabelas
-------------------------------------------------------------------------------------*/
//Define a chave única de gravação das informações
oModel:GetModel('MODEL_CGR'):SetPrimaryKey( {'CGR_PERIOD','CGR_CNPJCO'} ) 

oModel:SetRelation(  "MODEL_CGS", {{ "CGS_FILIAL","xFilial('CGS')" },{"CGS_ID","CGR_ID"}}, CGS->( IndexKey(1)))
        
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

Local oModel 	:= 	FWLoadModel( 'TAFA354' )
Local oStruCGR 	:= 	FWFormStruct( 2, 'CGR' )
Local oStruCGS	:= 	FWFormStruct( 2, 'CGS' )

Local oView 	:= 	FWFormView():New()
 

/*----------------------------------------------------------------------------------
Esrutura da View
-------------------------------------------------------------------------------------*/

oStruCGR:RemoveField('CGR_ID')  
oStruCGR:RemoveField('CGR_IDPERA')

oView:SetModel( oModel )
                                       
oView:AddField('VIEW_CGR' , oStruCGR,  'MODEL_CGR' ) 
oView:EnableTitleView( 'VIEW_CGR', STR0001 ) //"Cadastro de Participações em Consórcios de Empresas" 

oView:AddGrid( 'VIEW_CGS' , oStruCGS,  'MODEL_CGS' )
oView:EnableTitleView( 'VIEW_CGS', STR0002 ) //"Participantes do Consórcio"


/*-----------------------------------------------------------------------------------
Estrutura do Folder
-------------------------------------------------------------------------------------*/
oView:CreateHorizontalBox("PAINEL_PRINCIPAL",30)
oView:CreateFolder("FOLDER_PRINCIPAL","PAINEL_PRINCIPAL") // CGR - Participações em Consórcios de Empresas

oView:CreateHorizontalBox("PAINEL_INFERIOR",70)// CGS - Participantes do Consórcio
oView:CreateFolder("FOLDER_INFERIOR","PAINEL_INFERIOR")

/*-----------------------------------------------------------------------------------
Amarração para exibição das informações
-------------------------------------------------------------------------------------*/
oView:SetOwnerView( 'VIEW_CGR', 'PAINEL_PRINCIPAL' )   

oView:SetOwnerView( 'VIEW_CGS', 'PAINEL_INFERIOR' ) 

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
		TAFAltStat( "CGR", " " )	
	
	EndIf

	FwFormCommit( oModel )

End Transaction
       

Return .T.
 
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Taf354Vld

@author Denis R. de Oliveira
@since 19/05/2014
@version 1.0
/*/                                                                                                                                          
//------------------------------------------------------------------------------------
Function TAF354Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro	:= {}
Local nSumPart	:= 0
Local cId			:= ""

Default lJob := .F.

If CGR->CGR_STATUS $ ( " |1" )      

	//Valida o Periodo     
	If Empty(CGR->CGR_PERIOD)
		Aadd( aLogErro, {"CGR_PERIOD","000001","CGR", nRecno}) //STR0001 - Campo Inconsistente ou Vazio
	EndIf   
	
	//Valida o CNPJ do Consórcio
	If Empty(CGR->CGR_CNPJCO)
		Aadd( aLogErro, {"CGR_CNPJCO","000001","CGR", nRecno}) //STR0001 - Campo Inconsistente ou Vazio
	Else
	
		If !CGC(CGR->CGR_CNPJCO,,.F.)
			aAdd(aLogErro,{'CGR_CNPJCO','000006','CGR',nRecno}) //STR0006 - CNPJ Inconsistente
		EndIf
		
	EndIf
			  
	//Valida a Condição do Declarante      
	If Empty(CGR->CGR_CONDDE)
		Aadd( aLogErro, {"CGR_CONDDE", "000001", "CGR", nRecno}) //STR0001 - Campo Inconsistente ou Vazio
    Else 
		
		If !(Alltrim(CGR->CGR_CONDDE) $ ("1|2"))		
			AADD(aLogErro,{"CGR_CONDDE","000002","CGR", nRecno}) //STR0002 - Conteúdo do campo não condiz com as opções possíveis.			
        EndIf
   
	EndIf 
	
	//Valida a Receita do Consórcio
	If Alltrim(CGR->CGR_CONDDE) == "1"
		If Empty(CGR->CGR_VLCONS)
			Aadd( aLogErro, {"CGR_VLCONS","000001","CGR", nRecno}) //STR0001 - Campo Inconsistente ou Vazio
		EndIf
		
		/*REGRA_CNPJ_LI*/
		If (SM0->M0_CGC <> CGR_CNPJLI)
			Aadd( aLogErro, {"CGR_CNPJLI", "000195", "CGR", nRecno}) //STR0195 - O campo CNPJ Líder está diferente do cadastro de empresas (SM0).
		EndIf
		
	Else	
		If !Empty(CGR->CGR_VLCONS)
			Aadd( aLogErro, {"CGR_VLCONS","000015","CGR", nRecno}) //STR0015 - O campo Receita do Consórcio deve ser nulo caso a condição do declarante do consórcio seja igual a participante.
		EndIf	 		  
	EndIf  
					  		
	//Valida o CNPJ da empresa líder
	If Empty(CGR->CGR_CNPJLI)
		Aadd( aLogErro, {"CGR_CNPJLI","000001","CGR", nRecno}) //STR0001 - Campo Inconsistente ou Vazio
	Else
		/*REGRA_VALIDA_CNPJ*/
		If !CGC(CGR->CGR_CNPJLI,,.F.)
			aAdd(aLogErro,{'CGR_CNPJLI','000006','CGR',nRecno}) //STR0006 - CNPJ Inconsistente
		EndIf
		
	EndIf
	
	//Valida a Receita do declarante no consórcio  
	/*REGRA_VL_DECL_MENOR_VL_CONS*/	
	If CGR->CGR_VLDECL > CGR->CGR_VLCONS
		Aadd( aLogErro, {"CGR_VLDECL","000196","CGR", nRecno}) //STR0196 - "O campo 'Receita de Declarante' deve ser menor ou igual que o campo 'Receita do Consórcio'."
	EndIf 

	//------------------------------------------//                                                                            
	/* Valida a Grid Participantes do Consórcio */
	//------------------------------------------//)
	If CGS->(MsSeek(xFilial("CGS") + CGR->CGR_ID))

		If AllTrim( CGR->CGR_CONDDE ) == "2"
			aAdd( aLogErro, { "CGS_VLPART", "000016", "CGR", nRecno } ) //STR0016 - "Quando o Campo 'Cond. Decla' for igual a '2-Participante', não deve existir registro(s) na Aba 'Participantes do Consórcio'."
		EndIf

		cId := CGS->CGS_ID
		While (!CGS->(Eof()) .And. cId==CGS->CGS_ID)
			
			nSumPart += CGS->CGS_VLPART
			
			//Valida o CNPJ da empresa participante
			If Empty(CGS->CGS_CNPJEM)
				Aadd( aLogErro, {"CGS_CNPJEM","000001","CGR", nRecno}) //STR0001 - Campo Inconsistente ou Vazio
			Else
				If !CGC(CGS->CGS_CNPJEM,,.F.)
					aAdd(aLogErro,{'CGS_CNPJEM','000006','CGR',nRecno}) //STR0006 - CNPJ Inconsistente
				EndIf
			EndIf 

			CGS->(dbSkip())
			
		EndDo
	Else

		If CGR->CGR_CONDDE == "1"
			aAdd( aLogErro, { "CGS_VLPART", "000197", "CGR", nRecno } ) //STR0197 - "Quando o Campo 'Cond. Decla' for igual a '1-Líder', obrigatoriamente deve existir registro(s) na Aba 'Participantes do Consórcio'."
		EndIf

	EndIf	
	
	/*REGRA_SOMA_VL_PART*/
	If !Empty(cId) .And. (nSumPart + CGR->CGR_VLDECL) <> CGR->CGR_VLCONS
		Aadd( aLogErro, {"CGR_VLCONS","000198","CGR", nRecno}) //STR0198 -"O somatório do campo 'Rec Particip' + campo 'Rec Declaram' deve ser igual ao valor do campo 'Rec. Consórc.'"    
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
		RecLock("CGR",.F.)
		CGR->CGR_STATUS := "1"
		MsUnlock()
	Else
		RecLock("CGR",.F.)
		CGR->CGR_STATUS := "0"
		MsUnlock()
	EndIf	  	    	
	
Else
	
	AADD(aLogErro,{"CGR_ID","000017","CGR", nRecno})//STR0017 - Registro já validado.
	
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Não apresento o alert quando utilizo o JOB para validar³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lJob
	VldECFLog(aLogErro)
EndIf

Return(aLogErro)