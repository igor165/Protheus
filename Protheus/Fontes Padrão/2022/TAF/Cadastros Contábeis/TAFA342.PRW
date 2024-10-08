#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA342.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA342
Cadastro MVC de Vendas Com. Expe. c/ Fim Espec.

@author Paulo Vilas Boas 
@since 26/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA342()

Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 )	//"Vendas Com. Exp. c/ Fim Espec."
oBrw:SetAlias( 'CGI')
oBrw:SetMenuDef( 'TAFA342' )
CGI->(DbSetOrder(2))
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

Local aFuncao := {{ "" , "TAF342Vld" , "2" } }
Local aRotina := {}

aRotina	:=	xFunMnuTAF( "TAFA342" , , aFuncao )

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

Local oStruCGI := FWFormStruct( 1, 'CGI' )
LocaL oModel 	:=  MPFormModel():New( 'TAFA342' , , , {|oModel| SaveModel( oModel ) } )  


lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )
	
If lVldModel
	oStruCGI:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel }) 		
EndIf

oModel:AddFields('MODEL_CGI' , /*cOwner*/, oStruCGI) 

//Define a chave �nica de grava��o das informa��es
oModel:GetModel('MODEL_CGI'):SetPrimaryKey( { 'CGI_PERIOD','CGI_CNPJ','CGI_CODNCM'} ) 
             

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

Local oModel 	:= 	FWLoadModel( 'TAFA342' )
Local oStruCGI:= 	FWFormStruct( 2, 'CGI' )
Local oView 	:= 	FWFormView():New()


/*----------------------------------------------------------------------------------
Esrutura da View
-------------------------------------------------------------------------------------*/
oView:SetModel( oModel ) 

oStruCGI:RemoveField('CGI_ID')
                                       
oView:AddField('VIEW_CGI' , oStruCGI,  'MODEL_CGI' ) 
oView:EnableTitleView( 'VIEW_CGI', STR0001 ) //"Vendas Com. Exp. c/ Fim Espec." 

/*-----------------------------------------------------------------------------------
Estrutura do Folder
-------------------------------------------------------------------------------------*/
oView:CreateHorizontalBox("PAINEL_PRINCIPAL",100)
oView:CreateFolder("FOLDER_PRINCIPAL","PAINEL_PRINCIPAL")

/*-----------------------------------------------------------------------------------
Amarra��o para exibi��o das informa��es
-------------------------------------------------------------------------------------*/
oView:SetOwnerView( 'VIEW_CGI', 'PAINEL_PRINCIPAL' )   

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
	
		//�������������������������������������������������������������Ŀ
		//�Funcao responsavel por setar o Status do registro para Branco�
		//���������������������������������������������������������������
		TAFAltStat( "CGI", " " )	
	
	EndIf

	FwFormCommit( oModel )
        

End Transaction
       

Return .T.
 
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Taf342Vld

@author Paulo Vilas Boas Santana
@since 26/05/2014
@version 1.0
/*/                                                                                                                                          
//------------------------------------------------------------------------------------
Function TAF342Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro	:= {}
Local cBlc0CNPJ  	:= Iif( RetPessoa( SM0->M0_CGC ) == "J", SM0->M0_CGC, "" )

Default lJob := .F.

If CGI->CGI_STATUS $ ( " |1" )      

	//Valida o Periodo do lancamento    
	If Empty(CGI->CGI_PERIOD)
		Aadd( aLogErro, {"CGI_PERIOD", "000001", "CGI", nRecno }) //000001 - Campo Inconsistente ou Vazio
	EndIf
	
	//Valida o CNPJ
	If Empty(CGI->CGI_CNPJ)
		Aadd( aLogErro, {"CGI_CNPJ", "000001", "CGI", nRecno }) //000010 - Campo Inconsistente ou Vazio
	Else
		If !CGC(CGI->CGI_CNPJ,,.F.)
			Aadd( aLogErro, {"CGI_CNPJ", "000006", "CGI", nRecno }) //000006 - "CPF/CNPJ inconsistente." 
		EndIf
		
		//REGRA_CNPJ_DIFERENTE
		If CGI->CGI_CNPJ == cBlc0CNPJ
			Aadd( aLogErro, {"CGI_CNPJ", "000163", "CGI", nRecno }) //STR0163 - "O valor do campo deve ser diferente do CNPJ do declarante."
		EndIf
	EndIf
	
	//Valida o C�digo NCM 
	If Empty(CGI->CGI_CODNCM)
		Aadd( aLogErro, {"CGI_CODNCM", "000001", "CGI", nRecno }) //000001 - Campo Inconsistente ou Vazio
    Else
    	//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := CGI->CGI_CODNCM
		xVldECFTab("C0A",cChave,3,,@aLogErro,{"CGI","CGI_CODNCM",nRecno })
    EndIf
	
	//Valida o Valor da Venda   
	If Empty(CGI->CGI_VLVEND)
		Aadd( aLogErro, {"CGI_VLVEND", "000001", "CGI", nRecno }) //000001 - Campo Inconsistente ou Vazio
	EndIf
	
	
	//�������������������������������
	//�ATUALIZO O STATUS DO REGISTRO�
	//�1 = Registro Invalido        �
	//�0 = Registro Valido          �
	//�������������������������������
	If Len(aLogErro)>0
		//������������������������������������������������������������������Ŀ
		//�Utilizo RecLock, pois o SETVALUE somente funciona em campos USADOS�
		//��������������������������������������������������������������������
		RecLock("CGI",.F.)
		CGI->CGI_STATUS := "1"
		MsUnlock()
	Else
		RecLock("CGI",.F.)
		CGI->CGI_STATUS := "0"
		MsUnlock()
	EndIf	  	    
	
	
Else
	
	AADD(aLogErro,{"CGI_ID","000017", "CGI", nRecno })//Registro j� validado
	
EndIf

//�������������������������������������������������������Ŀ
//�N�o apresento o alert quando utilizo o JOB para validar�
//���������������������������������������������������������
If !lJob
	VldECFLog(aLogErro)
EndIf

Return(aLogErro)