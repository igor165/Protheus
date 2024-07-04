#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA349.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA349
Cadastro MVC de Rend.Dirig.Cons.Socios-Titular

@author Paulo Vilas Boas 
@since 26/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA349()

Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 )	//Rend.Dirig.Cons.Socios-Titular
oBrw:SetAlias( 'CEM')
oBrw:SetMenuDef( 'TAFA349' )
CEM->(DbSetOrder(2))
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

Local aFuncao := {{ "" , "TAF349Vld" , "2" } }
Local aRotina := {}

aRotina	:=	xFunMnuTAF( "TAFA349" , , aFuncao )

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

Local oStruCEM := FWFormStruct( 1, 'CEM' )
LocaL oModel 	:=  MPFormModel():New( 'TAFA349' , , , {|oModel| SaveModel( oModel ) } )  


lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )
	
If lVldModel
	oStruCEM:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel }) 		
EndIf

oModel:AddFields('MODEL_CEM' , /*cOwner*/, oStruCEM) 

//Define a chave única de gravação das informações
oModel:GetModel('MODEL_CEM'):SetPrimaryKey( { 'CEM_PAIS','CEM_PESSOA','CEM_NOMEMP','CEM_IDQUAL'} ) 

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

Local oModel 	:= 	FWLoadModel( 'TAFA349' )
Local oStruCEM:= 	FWFormStruct( 2, 'CEM' )
Local oView 	:= 	FWFormView():New()


/*----------------------------------------------------------------------------------
Esrutura da View
-------------------------------------------------------------------------------------*/
oView:SetModel( oModel ) 

oStruCEM:RemoveField('CEM_ID')
oStruCEM:RemoveField('CEM_IDQUAL')
oStruCEM:SetProperty('CEM_CNPJ',MVC_VIEW_PVAR ,{||IIf(FWFLDGET('CEM_PESSOA') == "1","@R 999.999.999-99%C","@R 99.999.999/9999-99%C")})
                              
oView:AddField('VIEW_CEM' , oStruCEM,  'MODEL_CEM' ) 
oView:EnableTitleView( 'VIEW_CEM', STR0001 ) //'Identificação de Sócios ou Titular'

/*-----------------------------------------------------------------------------------
Estrutura do Folder
-------------------------------------------------------------------------------------*/
oView:CreateHorizontalBox("PAINEL_PRINCIPAL",100)
oView:CreateFolder("FOLDER_PRINCIPAL","PAINEL_PRINCIPAL")

/*-----------------------------------------------------------------------------------
Amarração para exibição das informações
-------------------------------------------------------------------------------------*/
oView:SetOwnerView( 'VIEW_CEM', 'PAINEL_PRINCIPAL' )   

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
		TAFAltStat( "CEM", " " )	
	
	EndIf

	FwFormCommit( oModel )
        

End Transaction
       

Return .T.
 
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Taf349Vld

@author Paulo Vilas Boas Santana
@since 26/05/2014
@version 1.0
/*/                                                                                                                                          
//------------------------------------------------------------------------------------
Function TAF349Vld(cAlias,nRecno,nOpc,lJob)
Local cChave	:=	""
Local cPais		:=	""
Local cQualif	:=	""
Local aLogErro	:=	{}

Default lJob := .F.

If CEM->CEM_STATUS $ ( " |1" )      

	//Valida o Periodo do lancamento    
	If Empty(CEM->CEM_PERIOD)
		Aadd( aLogErro, {"CEM_PERIOD", "000001", "CEM", nRecno }) //STR0001 - Campo Inconsistente ou Vazio
	EndIf
	
	//Valida o Código do País
	If Empty(CEM->CEM_PAIS)
		Aadd( aLogErro, {"CEM_PAIS", "000001", "CEM", nRecno }) //STR0001 - Campo Inconsistente ou Vazio
    Else
    	//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := CEM->CEM_PAIS
		xVldECFTab("C08",cChave,3,,@aLogErro,{"CEM","CEM_PAIS",nRecno })
    EndIf
    
   	//Valida a Pessoa Física/Jurídica 
    If Empty(CEM->CEM_PESSOA)
		Aadd( aLogErro, {"CEM_PESSOA", "000001", "CEM", nRecno }) //STR0001 - Campo Inconsistente ou Vazio
    ElseIf !CEM->CEM_PESSOA $ ('1|2')
    	Aadd( aLogErro, {"CEM_PESSOA", "000002", "CEM", nRecno }) //STR0002 - Conteúdo do campo não condiz
    EndIf
    
    //Valida o Nome/Nome Empresarial 
	If Empty(CEM->CEM_NOMEMP)
		Aadd( aLogErro, {"CEM_NOMEMP", "000001", "CGM", nRecno }) //000001 - Campo Inconsistente ou Vazio
	EndIf
	
	//Valida a Qualificação
    If Empty(CEM->CEM_IDQUAL)
		Aadd( aLogErro, {"CEM_IDQUAL", "000001", "CEM", nRecno }) //STR0001 - Campo Inconsistente ou Vazio
    Else
    	//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := CEM->CEM_IDQUAL
		xVldECFTab("CGN",cChave,1,,@aLogErro,{"CEM","CEM_IDQUAL",nRecno })
    EndIf
	
	//Valida o CNPJ  
	cPais:= Alltrim(Posicione("C08",3,xFilial("C08")+CEM->CEM_PAIS,"C08_CODIGO"))
	
	cQualif	:=	AllTrim( Posicione( "CGN" , 1 , xFilial( "CGN" ) + CEM->CEM_IDQUAL , "CGN_CODIGO" ) )	     
	
	If Alltrim( cPais ) $ "105|01058"
		
		If ( CEM->CEM_PESSOA $ '1' )  
			If !( cQualif $ '01|02|09|10|11|12|13|14|15|17' ) 
				aAdd( aLogErro , { "CEM_QUALIF" , "000136" , "CEM" , nRecno } ) //STR0001 - Campo Inconsistente ou Vazio
			Endif
			
			If !Empty(CEM->CEM_CNPJ) .and. (!CGC(CEM->CEM_CNPJ,,.F.) .OR. LEN(Alltrim(CEM->CEM_CNPJ)) <> 11)
				aAdd(aLogErro,{'CEM_CNPJ','000006','CEM',nRecno}) //STR0006 - CNPJ Inconsistente
			EndIf
					
		Elseif ( CEM->CEM_PESSOA $ '2')
			If !( cQualif $ '03|04' )
				aAdd( aLogErro , { "CEM_QUALIF" , "000137" , "CEM" , nRecno } ) //STR0001 - Campo Inconsistente ou Vazio
			Endif
			
			If !Empty(CEM->CEM_CNPJ) .and. (!CGC(CEM->CEM_CNPJ,,.F.) .OR. LEN(Alltrim(CEM->CEM_CNPJ)) <> 14)
				aAdd(aLogErro,{'CEM_CNPJ','000006','CEM',nRecno}) //STR0006 - CNPJ Inconsistente
			EndIf
			
		Endif
			
	Else
		
		If ( CEM->CEM_PESSOA $ '1' )
			If !( cQualif $ '05|06' ) 
				aAdd( aLogErro , { "CEM_QUALIF" , "000138" , "CEM" , nRecno } ) //STR0001 - Campo Inconsistente ou Vazio
			Endif
			
			If !Empty(CEM->CEM_CNPJ) .and. (!CGC(CEM->CEM_CNPJ,,.F.) .OR. LEN(Alltrim(CEM->CEM_CNPJ)) <> 11)
				aAdd(aLogErro,{'CEM_CNPJ','000006','CEM',nRecno}) //STR0006 - CNPJ Inconsistente
			EndIf
			
		Elseif ( CEM->CEM_PESSOA $ '2' )
			If !( cQualif $ '07|08' ) 
				aAdd( aLogErro , { "CEM_QUALIF" , "000139" , "CEM" , nRecno } ) //STR0001 - Campo Inconsistente ou Vazio
			Endif
			
			If !Empty(CEM->CEM_CNPJ) .and. (!CGC(CEM->CEM_CNPJ,,.F.) .OR. LEN(Alltrim(CEM->CEM_CNPJ)) <> 14)
				aAdd(aLogErro,{'CEM_CNPJ','000006','CEM',nRecno}) //STR0006 - CNPJ Inconsistente
			EndIf
			
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
		RecLock("CEM",.F.)
		CEM->CEM_STATUS := "1"
		MsUnlock()
	Else
		RecLock("CEM",.F.)
		CEM->CEM_STATUS := "0"
		MsUnlock()
	EndIf	  	    
	
	
Else
	
	AADD(aLogErro,{"CEM_ID","000017", "CEM", nRecno })//Registro já válidado
	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Não apresento o alert quando utilizo o JOB para validar³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lJob
	VldECFLog(aLogErro)
EndIf

Return(aLogErro)