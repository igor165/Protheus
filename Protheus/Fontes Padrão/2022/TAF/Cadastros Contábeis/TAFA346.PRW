#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA346.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA346
Cadastro MVC de Identificação de Sócios ou Titular

@author Paulo Vilas Boas 
@since 26/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA346()

Local	oBrw	:= FWmBrowse():New()

dbSelectArea("CGM")
CGM->(DbSetOrder(2))
oBrw:SetDescription( STR0001 )	//Identificação de Sócios ou Titular
oBrw:SetAlias( 'CGM')
oBrw:SetMenuDef( 'TAFA346' )

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

Local aFuncao := {{ "" , "TAF346Vld" , "2" } }
Local aRotina := {}

aRotina	:=	xFunMnuTAF( "TAFA346" , , aFuncao )

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

Local oStruCGM := FWFormStruct( 1, 'CGM' )
LocaL oModel 	:=  MPFormModel():New( 'TAFA346' , , , {|oModel| SaveModel( oModel ) } )  


lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )
	
If lVldModel
	oStruCGM:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel }) 		
EndIf

oModel:AddFields('MODEL_CGM' , /*cOwner*/, oStruCGM) 

//Define a chave única de gravação das informações
oModel:GetModel('MODEL_CGM'):SetPrimaryKey( { /*'CGM_PERIOD',*/'CGM_INCSOC','CGM_PAIS','CGM_QUASOC','CGM_CPFCNP'} ) 
             

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

Local oModel 	:= 	FWLoadModel( 'TAFA346' )
Local oStruCGM:= 	FWFormStruct( 2, 'CGM' )
Local oView 	:= 	FWFormView():New()


/*----------------------------------------------------------------------------------
Esrutura da View
-------------------------------------------------------------------------------------*/
oView:SetModel( oModel ) 

oStruCGM:RemoveField('CGM_ID')
oStruCGM:RemoveField('CGM_IDQUAL')
oStruCGM:SetProperty('CGM_CPFCNP',MVC_VIEW_PVAR ,{||IIf(FWFLDGET('CGM_QUASOC') == "1","@R 999.999.999-99%C","@R 99.999.999/9999-99%C")})
                                       
oView:AddField('VIEW_CGM' , oStruCGM,  'MODEL_CGM' ) 
oView:EnableTitleView( 'VIEW_CGM', STR0001 ) //'Identificação de Sócios ou Titular'

/*-----------------------------------------------------------------------------------
Estrutura do Folder
-------------------------------------------------------------------------------------*/
oView:CreateHorizontalBox("PAINEL_PRINCIPAL",100)
oView:CreateFolder("FOLDER_PRINCIPAL","PAINEL_PRINCIPAL")

/*-----------------------------------------------------------------------------------
Amarração para exibição das informações
-------------------------------------------------------------------------------------*/
oView:SetOwnerView( 'VIEW_CGM', 'PAINEL_PRINCIPAL' )   

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
		TAFAltStat( "CGM", " " )	
	
	EndIf

	FwFormCommit( oModel )
        

End Transaction
       

Return .T.
 
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Taf346Vld

@author Paulo Vilas Boas Santana
@since 26/05/2014
@version 1.0
/*/                                                                                                                                          
//------------------------------------------------------------------------------------
Function TAF346Vld(cAlias,nRecno,nOpc,lJob)
Local cChave	:=	""
Local cPais		:=	""
Local cQualif	:=	""
Local aLogErro	:=	{}

Default lJob := .F.

If CGM->CGM_STATUS $ ( " |1" )      

	//Valida o Periodo do lancamento    
	/*If Empty(CGM->CGM_PERIOD)
		Aadd( aLogErro, {"CGM_PERIOD", "000001", "CGM", nRecno }) //000001 - Campo Inconsistente ou Vazio
	EndIf*/
	
	//Valida a Data de Inclusão no Quadro Societário  
	If Empty(CGM->CGM_INCSOC)
		Aadd( aLogErro, {"CGM_INCSOC", "000001", "CGM", nRecno }) //000001 - Campo Inconsistente ou Vazio
	EndIf
	
	//Valida o País
    If Empty(CGM->CGM_PAIS)
		Aadd( aLogErro, {"CGM_PAIS", "000001", "CGM", nRecno }) //STR0001 - Campo Inconsistente ou Vazio
    Else
    	//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := CGM->CGM_PAIS
		xVldECFTab("C08",cChave,3,,@aLogErro,{"CGM","CGM_PAIS",nRecno })
    EndIf
    
    //Valida o Nome/Nome Empresarial 
	If Empty(CGM->CGM_NOMEMP)
		Aadd( aLogErro, {"CGM_NOMEMP", "000001", "CGM", nRecno }) //000001 - Campo Inconsistente ou Vazio
	EndIf
		
	//Valida a Qualificação
    If Empty(CGM->CGM_IDQUAL)
		Aadd( aLogErro, {"CGM_IDQUAL", "000001", "CGM", nRecno }) //STR0001 - Campo Inconsistente ou Vazio
    Else
    	//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := CGM->CGM_IDQUAL
		xVldECFTab("CGN",cChave,1,,@aLogErro,{"CGM","CGM_IDQUAL",nRecno })
    EndIf
    
    //Valida o Indicador de Pessoa / Qualificação do Representante Legal
    If CGM->CGM_QUASOC == '2' // Pessoa física 
    	IF !CGM->CGM_QUALEG $(' |01|06')
			Aadd( aLogErro, {"CGM_QUALEG", "000029", "CGM", nRecno }) //000029 - Quando o 'Ind. Pessoa' for igual a '2-Pessoa Jurídica', as opções possiveis para este campo são '1-Procurador ou 6-Outros'  
		EndIf
	Elseif CGM->CGM_QUASOC == '1' // Pessoa jurídica
		IF !CGM->CGM_QUALEG $(' |01|02|03|04|05|06')
			Aadd( aLogErro, {"CGM_QUALEG", "000002", "CGM", nRecno }) //000002 - Conteúdo da informação não condiz com as opções possiveis'  
		EndIf
	Elseif CGM->CGM_QUASOC <> '3' // Fundo de investimento
		Aadd( aLogErro, {"CGM_QUASOC", "000002", "CGM", nRecno }) //STR0002 - Conteúdo do campo não condiz com as opções possiveis.	
	Endif
	
	//Valida o Percentual Total
	If Empty(CGM->CGM_PERTOT)
		Aadd( aLogErro, {"CGM_PERTOT", "000001", "CGM", nRecno }) //000001 - Campo Inconsistente ou Vazio
	EndIf
	
	//Valida o Percentual Votante
	If Empty(CGM->CGM_PERVOT)
		Aadd( aLogErro, {"CGM_PERVOT", "000001", "CGM", nRecno }) //000001 - Campo Inconsistente ou Vazio
	EndIf
	
	cPais	:=	Alltrim( Posicione( "C08" , 3 , xFilial( "C08" ) + CGM->CGM_PAIS , "C08_CODIGO" ) )
	cQualif	:=	AllTrim( Posicione( "CGN" , 1 , xFilial( "CGN" ) + CGM->CGM_IDQUAL , "CGN_CODIGO" ) )
	
	//Validacao de campos quando Pais = Brasil
	If Alltrim( cPais ) $ "105|01058"
		
		If Empty( CGM->CGM_CPFCNP )
			Aadd( aLogErro, {"CGM_CPFCNP","000001","CGM", nRecno}) //STR0001 - Campo Inconsistente ou Vazio
		Endif
		
		If ( CGM->CGM_QUASOC $ '1' )
			If !( cQualif $ '01|02|09' )
				aAdd( aLogErro , { "CGM_QUALIF" , "000140" , "CGM" , nRecno } ) //STR0140 - "Para registro de 'Pais' Brasil e 'Ind. Pessoa' igual a '1' (Pessoa Física) o código da 'Qualificação' deve ser 01, 02 ou 09"      
			Endif
			
			If !CGC( CGM->CGM_CPFCNP,,.F. ) .OR. LEN(Alltrim(CGM->CGM_CPFCNP)) <> 11
				Aadd( aLogErro, {"CGM_CPFCNP", "000006", "CGM", nRecno }) //000006 - "CPF/CNPJ inconsistente."
			Endif
			
		Elseif ( CGM->CGM_QUASOC $ '2' )
			If !( cQualif $ '03|04' ) 
				aAdd( aLogErro , { "CGM_QUALIF" , "000141" , "CGM" , nRecno } ) //STR0141 - "Para registro de 'Pais' Brasil e 'Ind. Pessoa' igual a '2' (Pessoa Jurídica) o código da 'Qualificação' deve ser 03 ou 04"  
			Endif
			
			If !CGC( CGM->CGM_CPFCNP,,.F. ) .OR. LEN(Alltrim(CGM->CGM_CPFCNP)) <> 14
				Aadd( aLogErro, {"CGM_CPFCNP", "000006", "CGM", nRecno }) //000006 - "CPF/CNPJ inconsistente."
			Endif			
			
		Endif
		
	//Validacao de campos quando Pais diferente de Brasil
	Else
				
		If ( CGM->CGM_QUASOC $ '1' )
			If !( cQualif $ '05|06' )  
				aAdd( aLogErro , { "CGM_QUALIF" , "000142" , "CGM" , nRecno } ) //STR0142 - "Para registro de 'Pais' diferente de Brasil e 'Ind. Pessoa' igual a '1' (Pessoa Física) o código da 'Qualificação' deve ser 05 ou 06"   
			Endif
			
			If !CGC( CGM->CGM_CPFCNP,,.F. ) .OR. LEN(Alltrim(CGM->CGM_CPFCNP)) <> 11
				Aadd( aLogErro, {"CGM_CPFCNP", "000006", "CGM", nRecno }) //000006 - "CPF/CNPJ inconsistente."
			Endif
			
		Elseif ( CGM->CGM_QUASOC $ '2' )
			If !( cQualif $ '07|08' ) 
				aAdd( aLogErro , { "CGM_QUALIF" , "000143" , "CGM" , nRecno } ) //STR0143 - "Para registro de 'Pais' diferente de Brasil e 'Ind. Pessoa' igual a '2' (Pessoa Jurídica) o código da 'Qualificação' deve ser 07 ou 08"  
			Endif
			
			If !CGC( CGM->CGM_CPFCNP,,.F. ) .OR. LEN(Alltrim(CGM->CGM_CPFCNP)) <> 14
				Aadd( aLogErro, {"CGM_CPFCNP", "000006", "CGM", nRecno }) //000006 - "CPF/CNPJ inconsistente."
			Endif
			
		Endif
	
	Endif
	
	If !Empty( CGM->CGM_CPFLEG )
		
		//Valida o CPF do representante legal
		If !CGC(CGM->CGM_CPFLEG,,.F.)
			Aadd( aLogErro, {"CGM_CPFLEG", "000006", "CGM", nRecno }) //000006 - "CPF/CNPJ inconsistente." 
		EndIf
		
		//Verifica se a qualificacao foi preenchida
		If Empty( CGM->CGM_QUALEG )
			aAdd( aLogErro, { "CGM_QUALEG", "000131", "CGM", nRecno } ) //STR0131 - "O campo 'Qual. Representante Legal' é obrigatório quando preenchido o 'CPF Representante Legal'."
		EndIf

	Else

		//Verifica se a qualificacao foi preenchida
		If !Empty( CGM->CGM_QUALEG )
			aAdd( aLogErro, { "CGM_QUALEG", "000222", "CGM", nRecno } ) //STR0222 - "O campo 'Qual. Representante Legal' não deve ser preenchido caso 'CPF Representante Legal' não seja preenchido."
		EndIf

	Endif
	
	//Validacoes do campo Qualificacao do Representante Legal
	If !Empty( CGM->CGM_QUALEG )
		If ( CGM->CGM_QUASOC $ '1' .And. !( CGM->CGM_QUALEG $ '01|02|03|04|05|06' ) ) .Or. ( CGM->CGM_QUASOC $ '2' .And. !( CGM->CGM_QUALEG $ '01|06' ) )
			aAdd( aLogErro , { "CGM_QUALEG" , "000001" , "CGM" , nRecno } ) //STR0001 - Campo Inconsistente ou Vazio
		Endif
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
		RecLock("CGM",.F.)
		CGM->CGM_STATUS := "1"
		MsUnlock()
	Else
		RecLock("CGM",.F.)
		CGM->CGM_STATUS := "0"
		MsUnlock()
	EndIf	  	    
	
	
Else
	
	AADD(aLogErro,{"CGM_ID","000017", "CGM", nRecno })//Registros válidos, não podem ser verificados novamente.
	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Não apresento o alert quando utilizo o JOB para validar³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lJob
	VldECFLog(aLogErro)
EndIf

Return(aLogErro)