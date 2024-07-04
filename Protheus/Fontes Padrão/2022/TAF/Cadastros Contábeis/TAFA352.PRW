#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA352.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA352
Cadastro MVC de Participação Permanente em Coligadas ou Controladas

@author Denis R de Oliveira
@since 03/06/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA352()

Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 )	//"Cadastro de Participação Permanente em Coligadas ou Controladas"
oBrw:SetAlias('CGP')
oBrw:SetMenuDef('TAFA352') 
CGP->(DbSetOrder(2))
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

Local aFuncao := {{ "" , "TAF352Vld" , "2" } }
Local aRotina := {}

aRotina	:=	xFunMnuTAF( "TAFA352" , , aFuncao )


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

Local oStruCGP	:=	FWFormStruct( 1, "CGP" )
LocaL oModel		:=	MPFormModel():New( "TAFA352",,, { |oModel| SaveModel( oModel ) } )

lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

If lVldModel
	oStruCGP:SetProperty( "*", MODEL_FIELD_VALID, { || lVldModel } )
EndIf

oModel:AddFields( "MODEL_CGP",, oStruCGP )

//Define a chave única de gravação das informações
oModel:GetModel( "MODEL_CGP" ):SetPrimaryKey( { "CGP_PERIOD", "CGP_DTEVEN", "CGP_INDREL", "CGP_PAIS", "CGP_CNPJ" } )

Return( oModel )
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

Local oModel		:=	FWLoadModel( "TAFA352" )
Local oStruCGP	:=	FWFormStruct( 2, "CGP" )
Local oView		:=	FWFormView():New()

oStruCGP:RemoveField( "CGP_ID" )

//Ordenação manual pois UPDDISTR não altera X3_ORDEM
oStruCGP:SetProperty( "CGP_PERIOD", MVC_VIEW_ORDEM, "03" )
oStruCGP:SetProperty( "CGP_DTEVEN", MVC_VIEW_ORDEM, "04" )
oStruCGP:SetProperty( "CGP_INDREL", MVC_VIEW_ORDEM, "05" )
oStruCGP:SetProperty( "CGP_PAIS"  , MVC_VIEW_ORDEM, "06" )
oStruCGP:SetProperty( "CGP_DPAIS" , MVC_VIEW_ORDEM, "07" )
oStruCGP:SetProperty( "CGP_CNPJ"  , MVC_VIEW_ORDEM, "08" )
oStruCGP:SetProperty( "CGP_NOMEMP", MVC_VIEW_ORDEM, "09" )
oStruCGP:SetProperty( "CGP_VALREA", MVC_VIEW_ORDEM, "10" )
oStruCGP:SetProperty( "CGP_VALORI", MVC_VIEW_ORDEM, "11" )
oStruCGP:SetProperty( "CGP_PERTOT", MVC_VIEW_ORDEM, "12" )
oStruCGP:SetProperty( "CGP_PERVOT", MVC_VIEW_ORDEM, "13" )
oStruCGP:SetProperty( "CGP_RESPAT", MVC_VIEW_ORDEM, "14" )
oStruCGP:SetProperty( "CGP_DTAQUI", MVC_VIEW_ORDEM, "15" )
oStruCGP:SetProperty( "CGP_INDCAR", MVC_VIEW_ORDEM, "16" )
oStruCGP:SetProperty( "CGP_NUMCAR", MVC_VIEW_ORDEM, "17" )
oStruCGP:SetProperty( "CGP_NOMCAR", MVC_VIEW_ORDEM, "18" )
oStruCGP:SetProperty( "CGP_INDRFB", MVC_VIEW_ORDEM, "19" )
oStruCGP:SetProperty( "CGP_NUMRFB", MVC_VIEW_ORDEM, "20" )

/*----------------------------------------------------------------------------------
Esrutura da View
-------------------------------------------------------------------------------------*/
oView:SetModel( oModel )

oView:AddField( "VIEW_CGP", oStruCGP, "MODEL_CGP" )
oView:EnableTitleView( "VIEW_CGP", STR0001 ) //"Cadastro de Participação Permanente em Coligadas ou Controladas"

/*-----------------------------------------------------------------------------------
Estrutura do Folder
-------------------------------------------------------------------------------------*/
oView:CreateHorizontalBox( "PAINEL_PRINCIPAL", 100 )
oView:CreateFolder( "FOLDER_PRINCIPAL", "PAINEL_PRINCIPAL" )

/*-----------------------------------------------------------------------------------
Amarração para exibição das informações
-------------------------------------------------------------------------------------*/
oView:SetOwnerView( "VIEW_CGP", "PAINEL_PRINCIPAL" )

Return( oView )

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
		TAFAltStat( "CGP", " " )	
	
	EndIf

	FwFormCommit( oModel )
        

End Transaction
       

Return .T.
 
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Taf352Vld

@author Denis R. de Oliveira
@since 03/06/2014
@version 1.0
/*/                                                                                                                                          
//------------------------------------------------------------------------------------
Function TAF352Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro	:= {}
Local cPais		:= ""
Local cPaisCmx	:= ""
Local cFormTrb	:= ""

Default lJob := .F.

If CGP->CGP_STATUS $ ( " |1" )      

	//Valida o Periodo     
	If Empty(CGP->CGP_PERIOD)
		Aadd( aLogErro, {"CGP_PERIOD","000001","CGP", nRecno}) //STR0001 - Campo Inconsistente ou Vazio
	EndIf  

	//Valida o País
	If Empty( CGP->CGP_PAIS )
		aAdd( aLogErro, { "CGP_PAIS", "000001", "CGP", nRecno } ) //STR0001 - Campo Inconsistente ou Vazio
	Else
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := CGP->CGP_PAIS
		xVldECFTab( "C08", cChave, 3,, @aLogErro, { "CGP", "CGP_PAIS", nRecno } )

		If !Empty( C08->C08_PAISSX )
			If AllTrim( C08->C08_PAISSX ) == "105"
				If Empty( CGP->CGP_CNPJ )
					aAdd( aLogErro, { "CGP_CNPJ", "000001", "CGP", nRecno } ) //STR0001 - Campo Inconsistente ou Vazio
				EndIf
			Else
				If !Empty( CGP->CGP_CNPJ )
					aAdd( aLogErro, { "CGP_CNPJ", "000013", "CGP", nRecno } ) //STR0013 - O campo CNPJ deve ser nulo caso o país não seja Brasil.
				EndIf
			EndIf
		EndIf

	EndIf

	If !Empty( CGP->CGP_CNPJ )
		/*CNPJ - REGRA_CNPJ_DIFERENTE*/
		If AllTrim( SM0->M0_CGC ) == AllTrim( CGP->CGP_CNPJ )
			aAdd( aLogErro, { "CGP_CNPJ", "000192", "CGP", nRecno } ) //STR0192 - "O campo CNPJ deve ser diferente do cadastro de empresas (SM0)."
		EndIf

		/*CNPJ - REGRA_VALIDA_CNPJ*/
		If !CGC( CGP->CGP_CNPJ,, .F. )
			aAdd( aLogErro,{ "CGP_CNPJ", "000006", "CGP", nRecno } ) //STR0006 - CNPJ Inconsistente
		EndIf
	EndIf

	//Valida o Nome Empresarial    
	If Empty(CGP->CGP_NOMEMP)
		Aadd( aLogErro, {"CGP_NOMEMP","000001","CGP", nRecno}) //STR0001 - Campo Inconsistente ou Vazio
	EndIf  

	//Valida o Percentual sobre o Capital Total     
	If Empty(CGP->CGP_PERTOT)
		Aadd( aLogErro, {"CGP_PERTOT","000001","CGP", nRecno}) //STR0001 - Campo Inconsistente ou Vazio
	EndIf  
	
	//Valida o Percentual sobre o Percenutal sobre o Capital Votante
	If Empty(CGP->CGP_PERVOT)
		Aadd( aLogErro, {"CGP_PERVOT","000001","CGP", nRecno}) //STR0001 - Campo Inconsistente ou Vazio
	EndIf
	
	/*--------------------------------------*
	 | Validações conforme Layout Dez/14    |
	 | Responsável: Evandro dos S. Oliveira |
	 | Data: 05/02/2014					     |
	 *--------------------------------------*/ 
	If Empty(CGP->CGP_VALREA)
		Aadd( aLogErro, {"CGP_VALREA","000001","CGP", nRecno}) //STR0001 - Campo Inconsistente ou Vazio
	EndIf  
	
	If Empty(CGP->CGP_VALORI)
		Aadd( aLogErro, {"CGP_VALORI","000001","CGP", nRecno}) //STR0001 - Campo Inconsistente ou Vazio
	EndIf  
	
	If Empty(CGP->CGP_DTAQUI)
		Aadd( aLogErro, {"CGP_DTAQUI","000001","CGP", nRecno}) //STR0001 - Campo Inconsistente ou Vazio
	EndIf  
	
	cFormTrb := Posicione("CHD",1,xFilial("CHD")+TAFEcfPer(CGP->CGP_PERIOD),"CHD_FORTRB")
	
	If !Empty(AllTrim(cFormTrb))
		If cFormTrb $ '567' .And. !Empty(CGP->CGP_RESPAT)
			Aadd( aLogErro, {"CGP_RESPAT","000193","CGP", nRecno}) //STR0193 - "O Campo Res. Patrim. deve ser vazio quando a Forma de Tributação for Igual a 5-Presumido,6-Arbitrado,7-Presumido/Arbitrado"	
		EndIf	
	Else
		Aadd( aLogErro, {"CGP_PERIOD","000194","CGP", nRecno}) //STR0194 - "Período não encontrado na tabela de parâmetros ECF (CHD)"
	EndIf

	If Empty( CGP->CGP_INDCAR )
		aAdd( aLogErro, { "CGP_INDCAR", "000001", "CGP", nRecno } ) //STR0001 - Campo Inconsistente ou Vazio
	Else

		If CGP->CGP_INDCAR == "1" //Sim 
			/*REGRA_PREENCHER_IND_PROC_CART*/
			If Empty(CGP->CGP_NUMCAR)
				Aadd( aLogErro, {"CGP_NUMCAR","000183","CGP", nRecno}) //STR0183 - 'O Campo "Num Reg Cart" deve ser preenchido quando "Sum Cartorio" for igual a "1-Sim".' 
			EndIf
		
			/*REGRA_PREENCHER_IND_PROC_CART*/
			If Empty(CGP->CGP_NOMCAR)
				Aadd( aLogErro, {"CGP_NOMCAR","000185","CGP", nRecno}) //STR0185 - 'O Campo "Nome Cartor" deve ser preenchido quando "Sum Cartorio" for igual a "1-Sim".' 
			EndIf
		
		ElseIf CGP->CGP_INDCAR == "2" //Não
			/*REGRA_NAO_PREENCHER_IND_PROC_CART*/
			If !Empty(CGP->CGP_NUMCAR)
				Aadd( aLogErro, {"CGP_NUMCAR","000184","CGP", nRecno}) //STR0184 - 'O Campo "Num Reg Cart" não deve ser preenchido quando "Sum Cartorio" for igual a "2-Não".' 
			EndIf
		
			/*REGRA_NAO_PREENCHER_IND_PROC_CART*/
			If !Empty(CGP->CGP_NOMCAR)
				Aadd( aLogErro, {"CGP_NOMCAR","000186","CGP", nRecno}) //STR0186 - 'O Campo "Nome Cartor" não deve ser preenchido quando "Sum Cartorio" for igual a "2-Não".' 
			EndIf
		EndIf

	EndIf

	If Empty( CGP->CGP_INDRFB )
		aAdd( aLogErro, { "CGP_INDRFB", "000001", "CGP", nRecno } ) //STR0001 - Campo Inconsistente ou Vazio
	Else

		If CGP->CGP_INDRFB == "1" //Sim 
			/*REGRA_PREENCHER_IND_PROC_RFB*/
			If Empty(CGP->CGP_NUMRFB)
				Aadd( aLogErro, {"CGP_NUMRFB","000188","CGP", nRecno}) //STR0188 - 'O Campo "Num Processo" deve ser preenchido quando "Laudo RFB" for igual a "1-Sim".' 
			EndIf
		ElseIf CGP->CGP_INDRFB == "2" //Não
			/*REGRA_NAO_PREENCHER_IND_PROC_CART*/
			If !Empty(CGP->CGP_NUMRFB)
				Aadd( aLogErro, {"CGP_NUMRFB","000189","CGP", nRecno}) //STR0189 - 'O Campo "Num Processo" não deve ser preenchido quando "Laudo RFB" for igual a "2-Não".' 
			EndIf
		EndIf

	EndIf

	/*-------------------------------------*
	| Validações conforme Layout Mar/15	|
	| Responsável: Felipe C. Seolin			|
	| Data: 06/05/2015						|
	*-------------------------------------*/

	//Valida a Data do Evento
	If Empty( CGP->CGP_DTEVEN )
		aAdd( aLogErro, { "CGP_DTEVEN", "000001", "CGP", nRecno } ) //STR0001 - Campo Inconsistente ou Vazio
	EndIf

	//Valida o Indicador do Tipo de Relacionamento
	If Empty( CGP->CGP_INDREL )
		aAdd( aLogErro, { "CGP_INDREL", "000001", "CGP", nRecno } ) //STR0001 - Campo Inconsistente ou Vazio
	Else
		If !( CGP->CGP_INDREL $ "1|2|3|4|5" )
			aAdd( aLogErro, { "CGP_INDREL", "000002", "CGP", nRecno } ) //STR0002 - "Conteúdo do campo não condiz com as opções possíveis."
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
		RecLock("CGP",.F.)
		CGP->CGP_STATUS := "1"
		MsUnlock()
	Else
		RecLock("CGP",.F.)
		CGP->CGP_STATUS := "0"
		MsUnlock()
	EndIf	  	    	
	
Else
	
	AADD(aLogErro,{"CGP_ID","000017","CGP", nRecno})//STR0017 - Registro já validado.
	
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Não apresento o alert quando utilizo o JOB para validar³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lJob
	VldECFLog(aLogErro)
EndIf

Return(aLogErro) 