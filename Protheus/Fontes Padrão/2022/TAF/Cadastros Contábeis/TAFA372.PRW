#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA372.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA372
Cadastro MVC de Parâmetros de Abertura ECF

@author Denis R de Oliveira
@since 18/11/2014
@version 1.0
/*/
//------------------------------------------------------------------
Function TAFA372()

Local	oBrw	:= FWmBrowse():New() 

oBrw:SetDescription( STR0001 )	//"Cadastro de Parâmetros de Abertura ECF"
oBrw:SetAlias( 'CHD')
oBrw:SetMenuDef( 'TAFA372' ) 
CHD->(DbSetOrder(2))
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu
@author Denis R de Oliveira
@since 18/11/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {{ "" , "TAF372Vld" , "2" } }
Local aRotina := {}

aRotina	:=	xFunMnuTAF( "TAFA372" , , aFuncao )

Return( aRotina )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Denis R de Oliveira
@since 18/11/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruCHD 	:= 	FWFormStruct( 1, 'CHD' )
LocaL oModel 	:=  MPFormModel():New( 'TAFA372' , , , {|oModel| SaveModel( oModel ) } )  

lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )
	
If lVldModel
	oStruCHD:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel }) 		
EndIf

oModel:AddFields('MODEL_CHD' , /*cOwner*/, oStruCHD) 

//Define a chave única de gravação das informações
oModel:GetModel('MODEL_CHD'):SetPrimaryKey( {'CHD_PERINI','CHD_PERFIN'} ) 


Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Denis R de Oliveira
@since 18/11/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel 	:= 	FWLoadModel( 'TAFA372' )
Local oStruCHDa  	:= Nil// Cria a estrutura a ser usada na View
Local oStruCHDb  	:= Nil// Cria a estrutura a ser usada na View
Local oStruCHDc  	:= Nil// Cria a estrutura a ser usada na View
Local oStruCHDd	:= Nil// Cria a estrutura a ser usada na View
Local oStruCHDe	:= Nil// Cria a estrutura a ser usada na View
Local cGrpAba05	:= ""
Local oView 	:= 	FWFormView():New()


/*----------------------------------------------------------------------------------
Esrutura da View
-------------------------------------------------------------------------------------*/
oView:SetModel( oModel )


/*-----------------------------------------------------------------------------------
Estrutura da View de Abertura do Arquivo Digital e Identificação da Pessoa Jurídica
-------------------------------------------------------------------------------------*/
cGrpAba01 := "CHD_PERINI|CHD_PERFIN|CHD_INDINI|CHD_INDESP|CHD_PATCIS|CHD_DTSIT|CHD_TPECF|CHD_CODSCP|CHD_DCODSC|"

cCmpFil   := cGrpAba01
oStruCHDa := FwFormStruct( 2, "CHD",{ |x| AllTrim( x ) + "|" $ cCmpFil } ) 

/*-----------------------------------------------------------------------------------
Estrutura da View dos Parâmetros de Tributação
-------------------------------------------------------------------------------------*/
cGrpAba02 := "CHD_OPTREF|CHD_FORTRB|CHD_APIRCS|CHD_CODQUA|CHD_TRBPER|CHD_APUEST|CHD_TIPESC|CHD_TIPENT|CHD_DTIPEN|CHD_ATTRBI|CHD_APCSLI|CHD_RECREC|"

cCmpFil   := cGrpAba02
oStruCHDb := FwFormStruct( 2, "CHD",{ |x| AllTrim( x ) + "|" $ cCmpFil } )

/*-----------------------------------------------------------------------------------
Estrutura da View dos Parâmetros Complementares
-------------------------------------------------------------------------------------*/

cGrpAba03 := "CHD_QTDSCP|CHD_INDADM|CHD_INDPAC|CHD_INDOPE|CHD_INDOPV|CHD_INDPJE|CHD_INDPAE|CHD_INDATV|CHD_INDLUC|CHD_INDRED|CHD_INDFIN|CHD_INDPAG|CHD_INDREC|CHD_INDEXT|CHD_INDPGE|CHD_INDECO|CHD_INDROY|CHD_INDROP|CHD_INDREN|CHD_INDREM|CHD_INDINO|CHD_INDCAP|CHD_INDPJH|CHD_INDPOL|CHD_INDZON|CHD_INDARE|CHD_INDPAP|"

DBSelectArea( "CHD" )
If TAFColumnPos( "CHD_IDCSLL" ) 
	cGrpAba03 +=	"CHD_IDCSLL|"	
EndIF

If TAFColumnPos( "CHD_DEREX" )
	cGrpAba03 += "CHD_DEREX|"
EndIf

cCmpFil   := cGrpAba03
oStruCHDc := FwFormStruct( 2, "CHD",{ |x| AllTrim( x ) + "|" $ cCmpFil } ) 

If TAFColumnPos( "CHD_IDCSLL" ) 
	oStruCHDc:SetProperty( "CHD_IDCSLL", MVC_VIEW_ORDEM, "26" )	
EndIF

/*-----------------------------------------------------------------------------------
Estrutura da View dos Parametros de Identificação de Tipo de programa
-------------------------------------------------------------------------------------*/
cGrpAba04 := "CHD_IREPES|CHD_IRECAP|CHD_IPADIS|CHD_IPATVD|CHD_IREIDI|CHD_IREPEC|CHD_REICMP|CHD_REAERO|CHD_RECINE|CHD_RESSOL|CHD_RECOPA|CHD_HBFIFA|CHD_IRETID|CHD_RPNLBI|CHD_IDREIF|CHD_OLIMPI|"

cCmpFil   := cGrpAba04
oStruCHDd := FwFormStruct( 2, "CHD",{ |x| AllTrim( x ) + "|" $ cCmpFil } )

/*-----------------------------------------------------------------------------------
Estrutura da View dos Obsoletos
-------------------------------------------------------------------------------------*/
cGrpAba05 := "CHD_INDALQ|CHD_OPTRTT|CHD_DIFFCO|CHD_OPTPAE|CHD_INDDOA|CHD_INDVEN|CHD_INDEXP|"
cCmpFil   := cGrpAba05
oStruCHDe := FwFormStruct( 2, "CHD",{ |x| AllTrim( x ) + "|" $ cCmpFil } )


/*-----------------------------------------------------------------------------------------
Grupo de campos da Abertura do Arquivo Digital e Identificação da Pessoa Jurídica - 0000
-------------------------------------------------------------------------------------------*/
oStruCHDa:AddGroup( "GRP_ABA01", "", "", 1 )
oStruCHDa:SetProperty('*', MVC_VIEW_GROUP_NUMBER,"GRP_ABA01")

oStruCHDa:RemoveField('CHD_IDCODS')

/*-----------------------------------------------------------------------------------------
Grupo de campos dos Parâmetros de Tributação - 0010
-------------------------------------------------------------------------------------------*/
oStruCHDb:AddGroup( "GRP_ABA02", "", "", 1 ) 
oStruCHDb:SetProperty('*', MVC_VIEW_GROUP_NUMBER,"GRP_ABA02")

/*-----------------------------------------------------------------------------------------
Grupo de campos dos Parâmetros Complementares - 0020
-------------------------------------------------------------------------------------------*/
oStruCHDc:AddGroup( "GRP_ABA03", "", "", 1 ) 
oStruCHDc:SetProperty('*', MVC_VIEW_GROUP_NUMBER,"GRP_ABA03")

/*-----------------------------------------------------------------------------------------
Grupo de campos dos Parametros de Identificação de Tipo de programa 0021
-------------------------------------------------------------------------------------------*/
oStruCHDd:AddGroup( "GRP_ABA04", "", "", 1 ) 
oStruCHDd:SetProperty('*', MVC_VIEW_GROUP_NUMBER,"GRP_ABA04")

/*-----------------------------------------------------------------------------------------
Grupo de campos dos Obsoletos
-------------------------------------------------------------------------------------------*/
oStruCHDe:AddGroup( "GRP_ABA05", "", "", 1 )
oStruCHDe:SetProperty('*', MVC_VIEW_GROUP_NUMBER,"GRP_ABA05")

                                      
oView:AddField('VIEW_CHDa' , oStruCHDa, 'MODEL_CHD' ) //"Arquivo Digital e Identificação da Pessoa Jurídica"  
oView:AddField('VIEW_CHDb' , oStruCHDb, 'MODEL_CHD' ) //"Parâmetros de Tributação"  
oView:AddField('VIEW_CHDc' , oStruCHDc, 'MODEL_CHD' ) //"Parâmetros de Tributação"  
oView:AddField('VIEW_CHDd' , oStruCHDd, 'MODEL_CHD' ) //"Grupo de campos dos Parametros de Identificação de Tipo de programa 0021"
oView:AddField('VIEW_CHDe' , oStruCHDe, 'MODEL_CHD' ) //"Obsoletos"
/*-----------------------------------------------------------------------------------
Estrutura do Folder
-------------------------------------------------------------------------------------*/
oView:CreateHorizontalBox("PAINEL_PRINCIPAL",100)
oView:CreateFolder("FOLDER_PRINCIPAL","PAINEL_PRINCIPAL") // CHD - Parâmetros de Abertura ECF


//ABA1
oView:AddSheet( 'FOLDER_PRINCIPAL', 'ABA01',STR0002)//Arquivo Digital e Identificação da Pessoa Jurídica
oView:CreateHorizontalBox( 'ABA0000', 100,,, 'FOLDER_PRINCIPAL',  'ABA01' )
oView:SetOwnerView( 'VIEW_CHDa', 'ABA0000' )   

//ABA2
oView:AddSheet( 'FOLDER_PRINCIPAL', 'ABA02',STR0003 )//Parâmetros de Tributação
oView:CreateHorizontalBox( 'ABA0010', 100,,, 'FOLDER_PRINCIPAL',  'ABA02')         
oView:SetOwnerView( 'VIEW_CHDb', 'ABA0010' )   
      
//ABA3                                                                                                       
oView:AddSheet( 'FOLDER_PRINCIPAL', 'ABA03',STR0004)//Parâmetros Complementares
oView:CreateHorizontalBox( 'ABA0020', 100,,, 'FOLDER_PRINCIPAL',  'ABA03')
oView:SetOwnerView( 'VIEW_CHDc', 'ABA0020' )   

//ABA4                                                                                                       
oView:AddSheet( 'FOLDER_PRINCIPAL', 'ABA04',STR0005)//Parametros de Identificação de Tipo de programa
oView:CreateHorizontalBox( 'ABA0030', 100,,, 'FOLDER_PRINCIPAL',  'ABA04')
oView:SetOwnerView( 'VIEW_CHDd', 'ABA0030' )  

//Aba5
oView:AddSheet( 'FOLDER_PRINCIPAL', 'ABA05','Obsoletos')//Obsoletos
oView:CreateHorizontalBox( 'ABA0031', 100,,, 'FOLDER_PRINCIPAL',  'ABA05')
oView:SetOwnerView( 'VIEW_CHDe', 'ABA0031' )  

Return oView    

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Denis R. de Oliveira
@since 18/11/2014
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
		TAFAltStat( "CHD", " " )	
	
	EndIf

	FwFormCommit( oModel )
        

End Transaction
       

Return .T.
 
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} TAF372Vld

@author Denis R. de Oliveira
@since 18/11/2014
@version 1.0
/*/                                                                                                                                          
//------------------------------------------------------------------------------------
Function TAF372Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro	:= {}
Local cCodScp		:= ""
Local cTrimestre	:= ""
Local nI			:=	0
Local nPos			:=	0
Local cOpcIndEsp	:= ''
Local cOpcIndIni	:= ''
Local lOk			:=	.T.
Local nAnoECF		:= Year(CHD->CHD_PERINI)

Default lJob := .F.

If CHD->CHD_STATUS $ ( " |1" )   

	//Código do tipo de entidade
	cTipEnt := Posicione("CH0",1,xFilial("CH0")+CHD->CHD_IDTIPE,"CH0_CODIGO")   

	//ABA01 - Arquivo Digital e Identificação da Pessoa Jurídica - 0000  
	If Empty(CHD->CHD_PERINI)
		Aadd( aLogErro, {"CHD_PERINI", "000001", "CHD", nRecno}) //STR0001 - "Campo Inconsistente ou Vazio"
	EndIf
	
	If Empty(CHD->CHD_PERFIN)
		Aadd( aLogErro, {"CHD_PERFIN", "000001", "CHD", nRecno}) //STR0001 - "Campo Inconsistente ou Vazio"
	EndIf
	
	If Empty(CHD->CHD_INDINI)
		Aadd(aLogErro,{"CHD_INDINI","000001","CHD",nRecno}) //STR0001 - "Campo inconsistente ou vazio." 		
	Else
		cOpcIndEsp	:= "0|1|2|3|4"
		If nAnoECF >= 2015 
			//A partir do ano base 2015 a opção 3-Resultante de Transformação foi removida do layout
			cOpcIndEsp	:= "0|1|2|4"
		EndIF	
		If !(CHD->CHD_INDINI $ cOpcIndEsp)
			aAdd(aLogErro,{"CHD_INDINI","000002","CHD", nRecno }) //STR0002 "Conteúdo do campo não condiz com as opções possíveis." 
		EndIf
	EndIf	
	
	If Empty(CHD->CHD_INDESP)
		Aadd(aLogErro,{"CHD_INDESP","000001","CHD",nRecno}) //STR0001 - "Campo inconsistente ou vazio." 		
	Else
		cOpcIndIni	:= "0|1|2|3|4|5|6|7|8|9"
		If nAnoEcf >= 2015
			//A partir do ano de 2015 a opção 7-Transfmorção foi removida do layout
			cOpcIndIni	:= "0|1|2|3|4|5|6|8|9"
		EndIF				
		If !(CHD->CHD_INDESP $ cOpcIndIni)               
			aAdd(aLogErro,{"CHD_INDESP","000002","CHD", nRecno }) //STR0002 "Conteúdo do campo não condiz com as opções possíveis." 
		EndIf
	EndIf	
	
	If Empty(CHD->CHD_TPECF)
		Aadd(aLogErro,{"CHD_TPECF","000001","CHD",nRecno}) //STR0001 - "Campo inconsistente ou vazio." 		
	Else
		If !(CHD->CHD_TPECF $ "0|1|2")               
			aAdd(aLogErro,{"CHD_TPECF","000002","CHD", nRecno }) //STR0002 "Conteúdo do campo não condiz com as opções possíveis." 
		EndIf
	EndIf	
		
	//ABA02 - Parâmetros de Tributação - 0010
	
	If Empty(CHD->CHD_OPTREF)
		Aadd(aLogErro,{"CHD_OPTREF","000001","CHD",nRecno}) //STR0001 - "Campo inconsistente ou vazio." 		
	Else
		If !(CHD->CHD_OPTREF $ "1|2")               
			aAdd(aLogErro,{"CHD_OPTREF","000002","CHD", nRecno }) //STR0002 "Conteúdo do campo não condiz com as opções possíveis." 
		EndIf
	EndIf	
	
	If Empty(CHD->CHD_OPTPAE)
		Aadd(aLogErro,{"CHD_OPTPAE","000001","CHD",nRecno}) //STR0001 - "Campo inconsistente ou vazio." 		
	Else
		If !(CHD->CHD_OPTPAE $ "1|2")               
			aAdd(aLogErro,{"CHD_OPTPAE","000002","CHD", nRecno }) //STR0002 "Conteúdo do campo não condiz com as opções possíveis." 
		EndIf
	EndIf	
	
	If Empty(CHD->CHD_FORTRB)
		Aadd(aLogErro,{"CHD_FORTRB","000001","CHD",nRecno}) //STR0001 - "Campo inconsistente ou vazio." 		
	Else
		If !(CHD->CHD_FORTRB $ "1|2|3|4|5|6|7|8|9")               
			aAdd(aLogErro,{"CHD_FORTRB","000002","CHD", nRecno }) //STR0002 "Conteúdo do campo não condiz com as opções possíveis." 
		EndIf
	EndIf	
	
	If ! Empty(CHD->CHD_APIRCS)
		If !(CHD->CHD_APIRCS $ "1|2")               
			aAdd(aLogErro,{"CHD_APIRCS","000002","CHD", nRecno }) //STR0002 "Conteúdo do campo não condiz com as opções possíveis." 
		EndIf
	EndIf	
	
	If ! Empty(CHD->CHD_CODQUA)
		If !(CHD->CHD_CODQUA $ "01|02|03")               
			aAdd(aLogErro,{"CHD_CODQUA","000002","CHD", nRecno }) //STR0002 "Conteúdo do campo não condiz com as opções possíveis." 
		EndIf
	EndIf	
	
	If ! Empty(CHD->CHD_TIPESC)
		If !(CHD->CHD_TIPESC $ "1|2")               
			aAdd(aLogErro,{"CHD_TIPESC","000002","CHD", nRecno }) //STR0002 "Conteúdo do campo não condiz com as opções possíveis." 
		EndIf
	EndIf	
	
	If ! Empty(CHD->CHD_IDTIPE)
		cChave := CHD->CHD_IDTIPE
		xVldECFTab("CH0",cChave,1,,@aLogErro,{ "CHD","CHD_TIPENT", nRecno})
	EndIf
	
	If ! Empty(CHD->CHD_ATTRBI)
		If !(CHD->CHD_ATTRBI $ "1|2|3")               
			aAdd(aLogErro,{"CHD_ATTRBI","000002","CHD", nRecno }) //STR0002 "Conteúdo do campo não condiz com as opções possíveis." 
		EndIf
	EndIf	
	
	If ! Empty(CHD->CHD_APCSLI)
		If !(CHD->CHD_APCSLI $ "1|2|3")               
			aAdd(aLogErro,{"CHD_APCSLI","000002","CHD", nRecno }) //STR0002 "Conteúdo do campo não condiz com as opções possíveis." 
		EndIf
	EndIf	
	
	If Empty(CHD->CHD_OPTRTT)
		Aadd(aLogErro,{"CHD_OPTRTT","000001","CHD",nRecno}) //STR0001 - "Campo inconsistente ou vazio." 		
	Else
		If !(CHD->CHD_OPTRTT $ "1|2")               
			aAdd(aLogErro,{"CHD_OPTRTT","000002","CHD", nRecno }) //STR0002 "Conteúdo do campo não condiz com as opções possíveis." 
		EndIf
	EndIf		

	//ABA03 - Parâmetros Complementares - 0020
	DBSelectArea( "CHD" )
	If TAFColumnPos( "CHD_IDCSLL" )
		//Faz validações do campo com as opções novas
		If Empty(CHD->CHD_IDCSLL)
			Aadd(aLogErro,{"CHD_IDCSLL","000001","CHD",nRecno}) //STR0001 - "Campo inconsistente ou vazio."
		ElseIf !(CHD->CHD_IDCSLL $ "1|2|3")               
			aAdd(aLogErro,{"CHD_IDCSLL","000002","CHD", nRecno }) //STR0002 "Conteúdo do campo não condiz com as opções possíveis."
		EndIF	
	
	Else
		//Faz validação do campos antigo
		If Empty(CHD->CHD_INDALQ)
			Aadd(aLogErro,{"CHD_INDALQ","000001","CHD",nRecno}) //STR0001 - "Campo inconsistente ou vazio."
		ElseIf !(CHD->CHD_INDALQ $ "1|2")               
			aAdd(aLogErro,{"CHD_INDALQ","000002","CHD", nRecno }) //STR0002 "Conteúdo do campo não condiz com as opções possíveis."
		EndIF	
	EndIF
	
	If Empty(CHD->CHD_INDADM)
		Aadd(aLogErro,{"CHD_INDADM","000001","CHD",nRecno}) //STR0001 - "Campo inconsistente ou vazio." 		
	Else
		If !(CHD->CHD_INDADM $ "1|2")               
			aAdd(aLogErro,{"CHD_INDADM","000002","CHD", nRecno }) //STR0002 "Conteúdo do campo não condiz com as opções possíveis." 
		EndIf
	EndIf	
	
	If Empty(CHD->CHD_INDPAC)
		Aadd(aLogErro,{"CHD_INDPAC","000001","CHD",nRecno}) //STR0001 - "Campo inconsistente ou vazio." 		
	Else
		If !(CHD->CHD_INDPAC $ "1|2")               
			aAdd(aLogErro,{"CHD_INDPAC","000002","CHD", nRecno }) //STR0002 "Conteúdo do campo não condiz com as opções possíveis." 
		EndIf
	EndIf	

	If Empty(CHD->CHD_INDOPE)
		Aadd(aLogErro,{"CHD_INDOPE","000001","CHD",nRecno}) //STR0001 - "Campo inconsistente ou vazio." 		
	Else
		If !(CHD->CHD_INDOPE $ "1|2")               
			aAdd(aLogErro,{"CHD_INDOPE","000002","CHD", nRecno }) //STR0002 "Conteúdo do campo não condiz com as opções possíveis." 
		EndIf
	EndIf	
	
	If Empty(CHD->CHD_INDOPV)
		Aadd(aLogErro,{"CHD_INDOPV","000001","CHD",nRecno}) //STR0001 - "Campo inconsistente ou vazio." 		
	Else
		If !(CHD->CHD_INDOPV $ "1|2")               
			aAdd(aLogErro,{"CHD_INDOPV","000002","CHD", nRecno }) //STR0002 "Conteúdo do campo não condiz com as opções possíveis." 
		EndIf
	EndIf	
	
	If Empty(CHD->CHD_INDPJE)
		Aadd(aLogErro,{"CHD_INDPJE","000001","CHD",nRecno}) //STR0001 - "Campo inconsistente ou vazio." 		
	Else
		If !(CHD->CHD_INDPJE $ "1|2")               
			aAdd(aLogErro,{"CHD_INDPJE","000002","CHD", nRecno }) //STR0002 "Conteúdo do campo não condiz com as opções possíveis." 
		EndIf
	EndIf	
	
	If Empty(CHD->CHD_INDPAE)
		Aadd(aLogErro,{"CHD_INDPAE","000001","CHD",nRecno}) //STR0001 - "Campo inconsistente ou vazio." 		
	Else
		If !(CHD->CHD_INDPAE $ "1|2")               
			aAdd(aLogErro,{"CHD_INDPAE","000002","CHD", nRecno }) //STR0002 "Conteúdo do campo não condiz com as opções possíveis." 
		EndIf
		/*If CHD->CHD_INDPAE == '1' 
			If CHD->CHD_INDEXT == '2' // Implementar um seek Y590
				aAdd(aLogErro,{"CHD_INDPAE","000000","CHD", nRecno }) //Se 0020.IND_PART_EXT é igual a “S” (Sim) e 0020.IND_ATIV_EXT é igual a “N” (Não), se o registro Y590 (Deve gerar um aviso)
			EndIf
			If CHD->CHD_INDPAG == '2'
				aAdd(aLogErro,{"CHD_INDPAE","000000","CHD", nRecno }) //Se 0020.IND_PART_EXT é igual a “S” (Sim) e 0020.IND_ATIV_EXT é igual a “N” (Não), se o registro Y590 (Deve gerar um aviso)
			EndIf 			
		EndIf*/
	EndIf	

	If Empty(CHD->CHD_INDATV)
		Aadd(aLogErro,{"CHD_INDATV","000001","CHD",nRecno}) //STR0001 - "Campo inconsistente ou vazio." 		
	Else
		If !(CHD->CHD_INDATV $ "1|2")               
			aAdd(aLogErro,{"CHD_INDATV","000002","CHD", nRecno }) //STR0002 "Conteúdo do campo não condiz com as opções possíveis." 
		EndIf
	EndIf	

	If Empty(CHD->CHD_INDLUC)
		Aadd(aLogErro,{"CHD_INDLUC","000001","CHD",nRecno}) //STR0001 - "Campo inconsistente ou vazio." 		
	Else
		If !(CHD->CHD_INDLUC $ "1|2")               
			aAdd(aLogErro,{"CHD_INDLUC","000002","CHD", nRecno }) //STR0002 "Conteúdo do campo não condiz com as opções possíveis." 
		EndIf
	EndIf	

	If Empty(CHD->CHD_INDRED)
		Aadd(aLogErro,{"CHD_INDRED","000001","CHD",nRecno}) //STR0001 - "Campo inconsistente ou vazio." 		
	Else
		If !(CHD->CHD_INDRED $ "1|2")               
			aAdd(aLogErro,{"CHD_INDRED","000002","CHD", nRecno }) //STR0002 "Conteúdo do campo não condiz com as opções possíveis." 
		EndIf
	EndIf	

	If Empty(CHD->CHD_INDFIN)
		Aadd(aLogErro,{"CHD_INDFIN","000001","CHD",nRecno}) //STR0001 - "Campo inconsistente ou vazio." 		
	Else
		If !(CHD->CHD_INDFIN $ "1|2")               
			aAdd(aLogErro,{"CHD_INDFIN","000002","CHD", nRecno }) //STR0002 "Conteúdo do campo não condiz com as opções possíveis." 
		EndIf
	EndIf	
	
	If Empty(CHD->CHD_INDDOA)
		Aadd(aLogErro,{"CHD_INDDOA","000001","CHD",nRecno}) //STR0001 - "Campo inconsistente ou vazio." 		
	Else
		If !(CHD->CHD_INDDOA $ "1|2")               
			aAdd(aLogErro,{"CHD_INDDOA","000002","CHD", nRecno }) //STR0002 "Conteúdo do campo não condiz com as opções possíveis." 
		EndIf
	EndIf	
	
	If Empty(CHD->CHD_INDPAG)
		Aadd(aLogErro,{"CHD_INDPAG","000001","CHD",nRecno}) //STR0001 - "Campo inconsistente ou vazio." 		
	Else
		If !(CHD->CHD_INDPAG $ "1|2")               
			aAdd(aLogErro,{"CHD_INDPAG","000002","CHD", nRecno }) //STR0002 "Conteúdo do campo não condiz com as opções possíveis." 
		EndIf
	EndIf			

	If Empty(CHD->CHD_INDVEN)
		Aadd(aLogErro,{"CHD_INDVEN","000001","CHD",nRecno}) //STR0001 - "Campo inconsistente ou vazio." 		
	Else
		If !(CHD->CHD_INDVEN $ "1|2")               
			aAdd(aLogErro,{"CHD_INDVEN","000002","CHD", nRecno }) //STR0002 "Conteúdo do campo não condiz com as opções possíveis." 
		EndIf
	EndIf		
		
	If Empty(CHD->CHD_INDREC)
		Aadd(aLogErro,{"CHD_INDREC","000001","CHD",nRecno}) //STR0001 - "Campo inconsistente ou vazio." 		
	Else
		If !(CHD->CHD_INDREC $ "1|2")               
			aAdd(aLogErro,{"CHD_INDREC","000002","CHD", nRecno }) //STR0002 "Conteúdo do campo não condiz com as opções possíveis." 
		EndIf
	EndIf	
	
	If Empty(CHD->CHD_INDEXT)
		Aadd(aLogErro,{"CHD_INDEXT","000001","CHD",nRecno}) //STR0001 - "Campo inconsistente ou vazio." 		
	Else
		If !(CHD->CHD_INDEXT $ "1|2")               
			aAdd(aLogErro,{"CHD_INDEXT","000002","CHD", nRecno }) //STR0002 "Conteúdo do campo não condiz com as opções possíveis." 
		EndIf
	EndIf	
	
	If Empty(CHD->CHD_INDEXP)
		Aadd(aLogErro,{"CHD_INDEXP","000001","CHD",nRecno}) //STR0001 - "Campo inconsistente ou vazio." 		
	Else
		If !(CHD->CHD_INDEXP $ "1|2")               
			aAdd(aLogErro,{"CHD_INDEXP","000002","CHD", nRecno }) //STR0002 "Conteúdo do campo não condiz com as opções possíveis." 
		EndIf
	EndIf	

	If Empty(CHD->CHD_INDPGE)
		Aadd(aLogErro,{"CHD_INDPGE","000001","CHD",nRecno}) //STR0001 - "Campo inconsistente ou vazio." 		
	Else
		If !(CHD->CHD_INDPGE $ "1|2")               
			aAdd(aLogErro,{"CHD_INDPGE","000002","CHD", nRecno }) //STR0002 "Conteúdo do campo não condiz com as opções possíveis." 
		EndIf
	EndIf	
	
	If Empty(CHD->CHD_INDECO)
		Aadd(aLogErro,{"CHD_INDECO","000001","CHD",nRecno}) //STR0001 - "Campo inconsistente ou vazio." 		
	Else
		If !(CHD->CHD_INDECO $ "1|2")               
			aAdd(aLogErro,{"CHD_INDECO","000002","CHD", nRecno }) //STR0002 "Conteúdo do campo não condiz com as opções possíveis." 
		EndIf
	EndIf	
	
	If Empty(CHD->CHD_INDROY)
		Aadd(aLogErro,{"CHD_INDROY","000001","CHD",nRecno}) //STR0001 - "Campo inconsistente ou vazio." 		
	Else
		If !(CHD->CHD_INDROY $ "1|2")               
			aAdd(aLogErro,{"CHD_INDROY","000002","CHD", nRecno }) //STR0002 "Conteúdo do campo não condiz com as opções possíveis." 
		EndIf
	EndIf	
	
	If Empty(CHD->CHD_INDROP)
		Aadd(aLogErro,{"CHD_INDROP","000001","CHD",nRecno}) //STR0001 - "Campo inconsistente ou vazio." 		
	Else
		If !(CHD->CHD_INDROP $ "1|2")               
			aAdd(aLogErro,{"CHD_INDROP","000002","CHD", nRecno }) //STR0002 "Conteúdo do campo não condiz com as opções possíveis." 
		EndIf
	EndIf	

	If Empty(CHD->CHD_INDREN)
		Aadd(aLogErro,{"CHD_INDREN","000001","CHD",nRecno}) //STR0001 - "Campo inconsistente ou vazio." 		
	Else
		If !(CHD->CHD_INDREN $ "1|2")               
			aAdd(aLogErro,{"CHD_INDREN","000002","CHD", nRecno }) //STR0002 "Conteúdo do campo não condiz com as opções possíveis." 
		EndIf
	EndIf	

	If Empty(CHD->CHD_INDREM)
		Aadd(aLogErro,{"CHD_INDREM","000001","CHD",nRecno}) //STR0001 - "Campo inconsistente ou vazio." 		
	Else
		If !(CHD->CHD_INDREM $ "1|2")               
			aAdd(aLogErro,{"CHD_INDREM","000002","CHD", nRecno }) //STR0002 "Conteúdo do campo não condiz com as opções possíveis." 
		EndIf
	EndIf	

	If Empty(CHD->CHD_INDINO)
		Aadd(aLogErro,{"CHD_INDINO","000001","CHD",nRecno}) //STR0001 - "Campo inconsistente ou vazio." 		
	Else
		If !(CHD->CHD_INDINO $ "1|2")               
			aAdd(aLogErro,{"CHD_INDINO","000002","CHD", nRecno }) //STR0002 "Conteúdo do campo não condiz com as opções possíveis." 
		EndIf
	EndIf	

	If Empty(CHD->CHD_INDCAP)
		Aadd(aLogErro,{"CHD_INDCAP","000001","CHD",nRecno}) //STR0001 - "Campo inconsistente ou vazio." 		
	Else
		If !(CHD->CHD_INDCAP $ "1|2")               
			aAdd(aLogErro,{"CHD_INDCAP","000002","CHD", nRecno }) //STR0002 "Conteúdo do campo não condiz com as opções possíveis." 
		EndIf
	EndIf	
	
	If Empty(CHD->CHD_INDPJH)
		Aadd(aLogErro,{"CHD_INDPJH","000001","CHD",nRecno}) //STR0001 - "Campo inconsistente ou vazio." 		
	Else
		If !(CHD->CHD_INDPJH $ "1|2")               
			aAdd(aLogErro,{"CHD_INDPJH","000002","CHD", nRecno }) //STR0002 "Conteúdo do campo não condiz com as opções possíveis." 
		EndIf
	EndIf	
	
	If Empty(CHD->CHD_INDPOL)
		Aadd(aLogErro,{"CHD_INDPOL","000001","CHD",nRecno}) //STR0001 - "Campo inconsistente ou vazio." 		
	Else
		If !(CHD->CHD_INDPOL $ "1|2")               
			aAdd(aLogErro,{"CHD_INDPOL","000002","CHD", nRecno }) //STR0002 "Conteúdo do campo não condiz com as opções possíveis." 
		EndIf
	EndIf				
	
	If Empty(CHD->CHD_INDZON)
		Aadd(aLogErro,{"CHD_INDZON","000001","CHD",nRecno}) //STR0001 - "Campo inconsistente ou vazio." 		
	Else
		If !(CHD->CHD_INDZON $ "1|2")               
			aAdd(aLogErro,{"CHD_INDZON","000002","CHD", nRecno }) //STR0002 "Conteúdo do campo não condiz com as opções possíveis." 
		EndIf
	EndIf	
	
	If Empty(CHD->CHD_INDARE)
		Aadd(aLogErro,{"CHD_INDARE","000001","CHD",nRecno}) //STR0001 - "Campo inconsistente ou vazio." 		
	Else
		If !(CHD->CHD_INDARE $ "1|2")               
			aAdd(aLogErro,{"CHD_INDARE","000002","CHD", nRecno }) //STR0002 "Conteúdo do campo não condiz com as opções possíveis." 
		EndIf
	EndIf	

	If Empty( CHD->CHD_DEREX )
		aAdd( aLogErro, { "CHD_DEREX", "000001", "CHD", nRecno } ) //STR0001 - "Campo inconsistente ou vazio."
	Else
		If !( CHD->CHD_DEREX $ "1|2" )
			aAdd( aLogErro,{ "CHD_DEREX", "000002", "CHD", nRecno } ) //STR0002 - "Conteúdo do campo não condiz com as opções possíveis."
		EndIf
	EndIf

	//REGRAS ESPECIFICAS - ABA01 - Arquivo Digital e Identificação da Pessoa Jurídica - 0000  
	
	//REGRA_PAT_REMAN_CIS_OBRIGATORIO
	If CHD->CHD_INDESP == "6"
		If Empty(CHD->CHD_PATCIS) 
			Aadd(aLogErro,{"CHD_PATCIS","000041","CHD",nRecno}) //STR0041 - "Se o campo Indicador de Situação Especial for igual a "6" (Cisão Parcial), o campo deve ser preenchido obrigatoriamente." 		
		EndIf
	EndIf	
	
	//REGRA_NAO_PREENCHER_SIT_ESP_CISAO_PARCIAL
	If CHD->CHD_INDESP <> "6"
		If ! Empty(CHD->CHD_PATCIS) 
			Aadd(aLogErro,{"CHD_PATCIS","000042","CHD",nRecno}) //STR0042 - "Se o campo Indicador de Situação Especial for diferente de "6" (Cisão Parcial), o campo deve está em branco." 		
		EndIf
	EndIf	
	
	//REGRA_DT_SIT_OBRIGATORIO
	If CHD->CHD_INDESP <> "0"
		If Empty(CHD->CHD_DTSIT) 
			Aadd(aLogErro,{"CHD_DTSIT","000043","CHD",nRecno}) //STR0043 - "Se o campo Indicador de Situação Especial for preenchido, o campo deve ser preenchido obrigatoriamente." 		
		EndIf
	EndIf	
	
	//REGRA_NAO_PREENCHER_SIT_ESP_NORMAL
	If CHD->CHD_INDESP == "0"
		If ! Empty(CHD->CHD_DTSIT) 
			Aadd(aLogErro,{"CHD_DTSIT","000044","CHD",nRecno}) //STR0044 - "Se o campo Indicador de Situação Especial for igual a "0" (Normal = sem situação especial no período), o campo deve está em branco." 		
		EndIf
	EndIf
	
	//REGRA_DATA_MINIMA
	If DTOS(CHD->CHD_PERINI) < "20140101"
		Aadd(aLogErro,{"CHD_PERINI","000045","CHD",nRecno}) //STR0045 - "A data de Período Inicial deve ser maior que 01/01/2014." 		
	EndIf	
	
	//REGRA_DATA_INI_MAIOR
	If CHD->CHD_PERINI > CHD->CHD_PERFIN
		aAdd( aLogErro,{ "CHD_PERINI","000033","CHD", nRecno } ) //STR0033 - "A data de período final deve ser maior ou igual a data de período inicial."
	EndIf	
	
	//REGRA_ANO_DIFERENTE
	If YEAR(CHD->CHD_PERINI) <> YEAR(CHD->CHD_PERFIN)
		aAdd( aLogErro,{ "CHD_PERINI","000046","CHD", nRecno } ) //STR0046 - "O ano informado no período final dever ser igual ao ano informado no período inicial."
	EndIf	
	
	//REGRA_DT_FINAL_ESCRITURACAO
	If CHD->CHD_INDESP == "0"
		If ! DAY(CHD->CHD_PERFIN) == 31 .OR. ! MONTH(CHD->CHD_PERFIN) == 12
			Aadd(aLogErro,{"CHD_PERFIN","000047","CHD",nRecno}) //STR0047 - "Se o campo Indicador de Situação Especial for igual a "0" (Normal), o dia e o mês no Período Final deve ser igual a 31/12." 		
		EndIf
	EndIf
	
	//REGRA_EVENTO_ACONTECIMENTO
	If CHD->CHD_INDESP == "1" .OR. CHD->CHD_INDESP == "2" .OR. CHD->CHD_INDESP == "3" .OR. CHD->CHD_INDESP == "4" .OR. CHD->CHD_INDESP == "5" .OR. CHD->CHD_INDESP == "6"
		If !(CHD->CHD_PERFIN == CHD->CHD_DTSIT)
			Aadd(aLogErro,{"CHD_PERFIN","000048","CHD",nRecno}) //STR0048 - "Se o campo Indicador de Situação Especial for igual a "1"(Extinção),"2"(Fusão),"3"(Incorporação/Incorporada),"4"(Incorporação/Incorporadora),"5"(Cisão Total) ou "6"(Cisão Parcial), o Período Final deve ser igual a Data da Situação Especial." 		
		EndIf
	ElseIf CHD->CHD_INDESP == "7" .OR. CHD->CHD_INDESP == "8" .OR. CHD->CHD_INDESP == "9"
		If !(CHD->CHD_PERFIN == (CHD->CHD_DTSIT-1))
			Aadd(aLogErro,{"CHD_PERFIN","000049","CHD",nRecno}) //STR0049 - "Se o campo Indicador de Situação Especial for igual a "7"(Transformação),"8"(Desenquadramento de Imune e Isenta ou "9"(Inclusão no SimplesNacional), o Período Final deve ser igual a Data da Situação Especial - 1." 		
		EndIf
	EndIf
	
	//REGRA_SCP_OBRIGATORIO
	If CHD->CHD_TPECF == "2" 
		If Empty(CHD->CHD_IDCODS)
			Aadd(aLogErro,{"CHD_CODSCP","000050","CHD",nRecno}) //STR0050 - "Se o campo Tipo da ECF for igual a "2" (ECF da SCP), o campo deve ser preenchido obrigatoriamente." 		
		Else
			cCodScp:= Posicione("CUW",3,xFilial("CUW") + CHD->CHD_IDCODS + "1","CUW_CODSCP")
			//REGRA_VALIDA_TAM_SCP
			If ! Empty(CHD->CHD_IDCODS) .And. Len(Alltrim(cCodScp)) <> 14
				Aadd(aLogErro,{"CHD_CODSCP","000052","CHD",nRecno}) //STR0052 - "O código da SCP deve conter exatamente 14 números." 		
			EndIf
		Endif
	EndIf
	
	//REGRA_SCP_NAO_PREENCHER
	If CHD->CHD_TPECF <> "2" .And. !Empty(CHD->CHD_IDCODS)
		Aadd(aLogErro,{"CHD_CODSCP","000051","CHD",nRecno}) //STR0051 - "Se o campo Tipo da ECF for igual a "0" (ECF de empresa não participante de SCP como sócio ostensivo) ou "1" (ECF de empresa participante de SCP como sócio ostensivo), o campo não deve ser preenchido." 		
	EndIf
	
	//REGRAS ESPECIFICAS - ABA02 - Parâmetros de Tributação - 0010 
	
	//REGRA_FORMA_APUR_VALIDA
	If CHD->CHD_APIRCS == "A"
		If !(CHD->CHD_FORTRB == "1" .OR. CHD->CHD_FORTRB == "2" .OR. (CHD->CHD_FORTRB == "3" .AND. CHD->CHD_OPTREF == "1") .OR. (CHD->CHD_FORTRB == "4" .AND. CHD->CHD_OPTREF == "1"))
			Aadd(aLogErro,{"CHD_APIRCS","000062","CHD",nRecno}) //STR0062 - "Se o campo Período de Apuração do IRPJ e CSLL igual a  2-'A' (Anual), a Forma de Tributação do Lucro deve ser igual a '1' (Lucro Real), '2' (Lucro Real/Arbitrado) ou '3' (Lucro Presumido/Real), '4' (Lucro Presumido/Real/Arbitrado) com o Indicador de Optante pelo Refis igual '1'-Sim" 		
		EndIf
	ElseIf	CHD->CHD_APIRCS == "T" 
		If CHD->CHD_FORTRB == "8" .OR. CHD->CHD_FORTRB == "9" 
			Aadd(aLogErro,{"CHD_APIRCS","000063","CHD",nRecno}) //STR0063 - "Se o campo Período de Apuração do IRPJ e CSLL igual a 1-'T' (Trimestral), a Forma de Tributação do Lucro deve ser igual a '1' (Lucro Real), '2' (LucroReal/Arbitrado), '3' (Lucro Presumido/Real), '4' (Lucro Presumido/Real/Arbitrado), '5' (Lucro Presumido), '6' (Lucro Arbitrado) ou '7' (Lucro Presumido/Arbitrado)."	
		EndIf
	EndIf
	
	//REGRA_COD_QUALIF_PJ
	If CHD->CHD_FORTRB == "3" .OR. CHD->CHD_FORTRB == "4" .OR. CHD->CHD_FORTRB == "5" .OR. CHD->CHD_FORTRB == "7" 
		If CHD->CHD_CODQUA <> "01"
			Aadd(aLogErro,{"CHD_CODQUA","000064","CHD",nRecno}) //STR0064 - "Se o campo Forma de Tributação do Lucro for igual a '3' (Lucro Presumido/Real) ou '4' (Lucro/Presumido/Real/Arbitrado) ou '5' (Lucro Presumido) ou '7' (Lucro Presumido/Arbitrado), a Qualificação da Pessoa Jurídica deve ser igual a '01' (PJ em geral).		
		EndIf
	EndIf
	
	//REGRA_NAO_PREENCHER_IMUNE
	If CHD->CHD_FORTRB == "8" .or. CHD->CHD_FORTRB == "9"
		If !Empty( CHD->CHD_TRBPER )
			aAdd( aLogErro, { "CHD_TRBPER", "000065", "CHD", nRecno } ) //STR0065 - "Se o campo 'Forma Trib' for igual a '8 - Imune IRPJ' ou '9 - Isento IPRJ', o campo 'Trib Per' não deve ser preenchido."
		EndIf
	EndIf

	//REGRA_TRIBUT_INVALIDA
	If CHD->CHD_FORTRB == "1"

		For nI := 1 to Len( CHD->CHD_TRBPER )
			If !SubStr( CHD->CHD_TRBPER, nI, 1 ) $ "0|R"
				aAdd( aLogErro, { "CHD_TRBPER", "000066", "CHD", nRecno } ) //STR0066 - "Se o campo 'Forma Trib' for igual a '1 - Luc Real', o campo 'Trib Per' deve ser preenchido com '0' ou 'R'."
				Exit
			EndIf
		Next nI

	ElseIf CHD->CHD_FORTRB == "2"

		For nI := 1 to Len( CHD->CHD_TRBPER )
			If !SubStr( CHD->CHD_TRBPER, nI, 1 ) $ "0|R|A"
				aAdd( aLogErro, { "CHD_TRBPER", "000067", "CHD", nRecno } ) //STR0067 - "Se o campo 'Forma Trib' for igual a '2 - Luc Real/Arb', o campo 'Trib Per' deve ser preenchido com '0', 'R' ou 'A'."
				Exit
			EndIf
		Next nI

	ElseIf CHD->CHD_FORTRB == "3" .and. CHD->CHD_OPTREF == "2"

		For nI := 1 to Len( CHD->CHD_TRBPER )
			If !SubStr( CHD->CHD_TRBPER, nI, 1 ) $ "0|P|R"
				aAdd( aLogErro, { "CHD_TRBPER", "000068", "CHD", nRecno } ) //STR0068 - "Se o campo 'Forma Trib' for igual a '3 - Luc Pres/Real' e 'Optante Refi' igual '2 - Não', o campo 'Trib Per' deve ser preenchido com '0', 'P' ou 'R'."
				Exit
			EndIf
		Next nI

	ElseIf CHD->CHD_FORTRB == "3" .and. CHD->CHD_OPTREF == "1" .and. CHD->CHD_APIRCS == "2"

		For nI := 1 to Len( CHD->CHD_TRBPER )
			If !SubStr( CHD->CHD_TRBPER, nI, 1 ) $ "0|E|P"
				aAdd( aLogErro, { "CHD_TRBPER", "000069", "CHD", nRecno } ) //STR0069 - "Se o campo 'Forma Trib' for igual a '3 - Luc Pres/Real', 'Optante Refi' igual '1 - Sim' e 'Apur IRPJ/CS' igual a '2 - Anual', o campo 'Trib Per' deve ser preenchido com '0', 'E' ou 'P'."
				Exit
			EndIf
		Next nI

	ElseIf CHD->CHD_FORTRB == "3" .and. CHD->CHD_OPTREF == "1" .and. CHD->CHD_APIRCS == "1"

		For nI := 1 to Len( CHD->CHD_TRBPER )
			If !SubStr( CHD->CHD_TRBPER, nI, 1 ) $ "0|R|P"
				aAdd( aLogErro, { "CHD_TRBPER", "000070", "CHD", nRecno } ) //STR0070 - "Se o campo 'Forma Trib' for igual a '3 - Luc Pres/Real', 'Optante Refi' igual '1 - Sim' e 'Apur IRPJ/CS' igual a '1 - Trimestral', o campo 'Trib Per' deve ser preenchido com '0', 'R' ou 'P'."
				Exit
			EndIf
		Next nI

	ElseIf CHD->CHD_FORTRB == "4" .and. CHD->CHD_OPTREF == "2"

		For nI := 1 to Len( CHD->CHD_TRBPER )
			If !SubStr( CHD->CHD_TRBPER, nI, 1 ) $ "0|A|P|R"
				aAdd( aLogErro, { "CHD_TRBPER", "000071", "CHD", nRecno } ) //STR0071 - "Se o campo 'Forma Trib' for igual a '4 - Luc Pres/Real/Arb' e 'Optante Refi' igual '2 - Não', o campo 'Trib Per' deve ser preenchido com '0', 'A', 'P' ou 'R'."
				Exit
			EndIf
		Next nI

	ElseIf CHD->CHD_FORTRB == "4" .and. CHD->CHD_OPTREF == "1" .and. CHD->CHD_APIRCS == "2"

		For nI := 1 to Len( CHD->CHD_TRBPER )
			If !SubStr( CHD->CHD_TRBPER, nI, 1 ) $ "0|A|E|P"
				aAdd( aLogErro, { "CHD_TRBPER", "000072", "CHD", nRecno } ) //STR0072 - "Se o campo 'Forma Trib' for igual a '4 - Luc Pres/Real/Arb', 'Optante Refi' igual '1 - Sim' e 'Apur IRPJ/CS' igual a '2 - Anual', o campo 'Trib Per' deve ser preenchido com '0', 'A', 'E' ou 'P'."
				Exit
			EndIf
		Next nI

	ElseIf CHD->CHD_FORTRB == "4" .and. CHD->CHD_OPTREF == "1" .and. CHD->CHD_APIRCS == "1"

		For nI := 1 to Len( CHD->CHD_TRBPER )
			If !SubStr( CHD->CHD_TRBPER, nI, 1 ) $ "0|A|R|P"
				aAdd( aLogErro, { "CHD_TRBPER", "000073", "CHD", nRecno } ) //STR0073 - "Se o campo 'Forma Trib' for igual a '4 - Luc Pres/Real/Arb', 'Optante Refi' igual '1 - Sim' e 'Apur IRPJ/CS' igual a '1 - Trimestral', o campo 'Trib Per' deve ser preenchido com '0', 'A', 'R' ou 'P'."
				Exit
			EndIf
		Next nI

	ElseIf CHD->CHD_FORTRB == "5"

		For nI := 1 to Len( CHD->CHD_TRBPER )
			If !SubStr( CHD->CHD_TRBPER, nI, 1 ) $ "0|P"
				aAdd( aLogErro, { "CHD_TRBPER", "000074", "CHD", nRecno } ) //STR0074 - "Se o campo 'Forma Trib' for igual a '5 - Luc Pres', o campo 'Trib Per' deve ser preenchido com '0' ou 'P'."
				Exit
			EndIf
		Next nI

	ElseIf CHD->CHD_FORTRB == "6"

		For nI := 1 to Len( CHD->CHD_TRBPER )
			If !SubStr( CHD->CHD_TRBPER, nI, 1 ) $ "0|A"
				aAdd( aLogErro, { "CHD_TRBPER", "000075", "CHD", nRecno } ) //STR0075 - "Se o campo 'Forma Trib' for igual a '6 - Luc Arb', o campo 'Trib Per' deve ser preenchido com '0' ou 'A'."
				Exit
			EndIf
		Next nI

	ElseIf CHD->CHD_FORTRB == "7"

		For nI := 1 to Len( CHD->CHD_TRBPER )
			If !SubStr( CHD->CHD_TRBPER, nI, 1 ) $ "0|A|P"
				aAdd( aLogErro, { "CHD_TRBPER", "000076", "CHD", nRecno } ) //STR0076 - "Se o campo 'Forma Trib' for igual a '7 - Luc Pres/Arb', o campo 'Trib Per' deve ser preenchido com '0', 'A' ou 'P'."
				Exit
			EndIf
		Next nI

	ElseIf CHD->CHD_FORTRB == "8"

		If !Empty( CHD->CHD_TRBPER )
			aAdd( aLogErro, { "CHD_TRBPER", "000077", "CHD", nRecno } ) //STR0077 - "Se o campo 'Forma Trib' for igual a '8 - Imune IRPJ', o campo 'Trib Per' não deve ser preenchido."
		EndIf

	ElseIf CHD->CHD_FORTRB == "9"

		If !Empty( CHD->CHD_TRBPER )
			aAdd( aLogErro, { "CHD_TRBPER", "000078", "CHD", nRecno } ) //STR0078 - "Se o campo 'Forma Trib' for igual a '9 - Isento IRPJ', o campo 'Trib Per' não deve ser preenchido."
		EndIf

	EndIf

	//REGRA_TRIBUT_PER_R_E
	If "R" $ CHD->CHD_TRBPER .and. "E" $ CHD->CHD_TRBPER
		aAdd( aLogErro, { "CHD_TRBPER", "000236", "CHD", nRecno } ) //STR0236 - "Os valores 'R' e 'E' não devem aparecer simultaneamente em 'Trib Per'."
	EndIf

	//REGRA_PRESUMIDO_PRIMEIRO
	If "P" $ CHD->CHD_TRBPER .and. ( "R" $ CHD->CHD_TRBPER .or. "E" $ CHD->CHD_TRBPER )
		For nI := 1 to Len( CHD->CHD_TRBPER )
			If SubStr( CHD->CHD_TRBPER, nI, 1 ) == "P"
				If ( "R" $ CHD->CHD_TRBPER .and. At( "R", CHD->CHD_TRBPER ) < nI ) .or. ( "E" $ CHD->CHD_TRBPER .and. At( "E", CHD->CHD_TRBPER ) < nI )
					aAdd( aLogErro, { "CHD_TRBPER", "000237", "CHD", nRecno } ) //STR0237 - "O valor 'P' deve aparecer primeiro quando existir 'R', 'E' ou 'P' em 'Trib Per'."
					Exit
				EndIf
			EndIf 
		Next nI
	EndIf

	//REGRA_FORMA_TRIB_EXISTENTE
	If CHD->CHD_FORTRB == "2"

		If !( "R" $ CHD->CHD_TRBPER ) .and. !( "A" $ CHD->CHD_TRBPER )
			aAdd( aLogErro, { "CHD_TRBPER", "000079", "CHD", nRecno } ) //STR0079 - "Se o campo 'Forma Trib' for igual a '2 - Luc Real/Arb', o campo 'Trib Per' deve possuir 'R' ou 'A'."
		EndIf

	ElseIf CHD->CHD_FORTRB == "3"

		If !( "P" $ CHD->CHD_TRBPER ) .and. !( "R" $ CHD->CHD_TRBPER )
			aAdd( aLogErro, { "CHD_TRBPER", "000080", "CHD", nRecno } ) //STR0080 - "Se o campo 'Forma Trib' for igual a '3 - Luc Pres/Real', o campo 'Trib Per' deve possuir 'P' ou 'R'."
		EndIf

	ElseIf CHD->CHD_FORTRB == "4"

		If !( "P" $ CHD->CHD_TRBPER ) .and. !( "R" $ CHD->CHD_TRBPER ) .and. !( "A" $ CHD->CHD_TRBPER )
			aAdd( aLogErro, { "CHD_TRBPER", "000081", "CHD", nRecno } ) //STR0081 - "Se o campo 'Forma Trib' for igual a '4 - Luc Pres/Real/Arb', o campo 'Trib Per' deve possuir 'P', 'R' ou 'A'."
		EndIf

	ElseIf CHD->CHD_FORTRB == "7"

		If !( "P" $ CHD->CHD_TRBPER ) .and. !( "A" $ CHD->CHD_TRBPER )
			aAdd( aLogErro, { "CHD_TRBPER", "000082", "CHD", nRecno } ) //STR0082 - "Se o campo 'Forma Trib' for igual a '7 - Luc Pres/Arb', o campo 'Trib Per' deve possuir 'P' ou 'A'."
		EndIf

	EndIf

	//REGRA_FORM_TRIB_FORA_PERIODO
	If !Empty( CHD->CHD_PERINI ) .and. !Empty( CHD->CHD_PERFIN )
		cTrimestre := SubStr( DToS( CHD->CHD_PERINI ), 5, 2 )

		If cTrimestre $ "01|02|03"
			nPos := 0
		ElseIf cTrimestre $ "04|05|06"
			nPos := 1
		ElseIf cTrimestre $ "07|08|09"
			nPos := 2
		ElseIf cTrimestre $ "10|11|12"
			nPos := 3
		EndIf

		For nI := 1 to nPos
			If !SubStr( CHD->CHD_TRBPER, nI, 1 ) $ "0"
				aAdd( aLogErro, { "CHD_TRBPER", "000238", "CHD", nRecno } ) //STR0238 - "Os trimestres fora do período de escrituração devem ser preenchidos com '0' em 'Trib Per'."
				lOk := .F.
				Exit
			EndIf
		Next nI

		If lOk
			cTrimestre := SubStr( DToS( CHD->CHD_PERFIN ), 5, 2 )

			If cTrimestre $ "01|02|03"
				nPos := 2
			ElseIf cTrimestre $ "04|05|06"
				nPos := 3
			ElseIf cTrimestre $ "07|08|09"
				nPos := 4
			ElseIf cTrimestre $ "10|11|12"
				nPos := 5
			EndIf

			For nI := nPos to Len( CHD->CHD_TRBPER )
				If !SubStr( CHD->CHD_TRBPER, nI, 1 ) $ "0"
					aAdd( aLogErro, { "CHD_TRBPER", "000238", "CHD", nRecno } ) //STR0238 - "Os trimestres fora do período de escrituração devem ser preenchidos com '0' em 'Trib Per'."
					Exit
				EndIf
			Next nPos
		EndIf
	EndIf

	//REGRA_FORMA_TRIB_PER_OBRIGATORIO
	If CHD->CHD_FORTRB <> "8" .and. CHD->CHD_FORTRB <> "9"
		If Empty( CHD->CHD_TRBPER )
			aAdd( aLogErro, { "CHD_TRBPER", "000239", "CHD", nRecno } ) //STR0239 - "O campo 'Trib Per' deve estar preenchido quando 'Forma Trib' for diferente de '8 - Imune IRPJ' ou '9 - Isento IRPJ'."
		EndIf
	EndIf

	//REGRA_MES_BAL_RED_OBRIGATORIO
	If CHD->CHD_APIRCS == "A"
		If Empty(CHD->CHD_APUEST)
			Aadd(aLogErro,{"CHD_APUEST","000083","CHD",nRecno}) //STR0083 - "Se o campo Período de Apuração do IRPJ e CSLL for igual a 2-'A' (Anual), o campo deve ser preenchido obrigatoriamente." 		
		EndIf
	EndIf
	
	//REGRA_NAO_PREENCHER_TRIMESTRAL
	If CHD->CHD_APIRCS == "T"
		If ! Empty(CHD->CHD_APUEST)
			Aadd(aLogErro,{"CHD_APUEST","000084","CHD",nRecno}) //STR0084 - "Se o campo Período de Apuração do IRPJ e CSLL for igual a 1-'T' (Trimestre), o campo não deve ser preenchido." 		
		EndIf
	EndIf	
	
	/*//REGRA_MES_BAL_RED_INVALIDO
	If ! SUBSTR(CHD->CHD_TRBPER, 1, 1) $ "R|E" .OR. ! SUBSTR(CHD->CHD_TRBPER, 2, 1) $ "R|E" .OR. ! SUBSTR(CHD->CHD_TRBPER, 3, 1) $ "R|E" .OR. ! SUBSTR(CHD->CHD_TRBPER, 4, 1) $ "R|E"
		If !CHD->CHD_APUEST $ "000000000000"
			Aadd(aLogErro,{"CHD_APUEST","000085","CHD",nRecno}) //STR0085 - "Se o campo Forma de Tributação no Período for diferente de 'R' ou 'E', o campo Indicação da Forma de Apuração da Estimativa deve ser preenchido com '0'.		
		EndIf
	ElseIf SUBSTR(CHD->CHD_TRBPER, 1, 1) $ "R|E" .OR. SUBSTR(CHD->CHD_TRBPER, 2, 1) $ "R|E" .OR. SUBSTR(CHD->CHD_TRBPER, 3, 1) $ "R|E" .OR. SUBSTR(CHD->CHD_TRBPER, 4, 1) $ "R|E"
		If ! SUBSTR(CHD->CHD_APUEST, 1, 1) $ "0|E|B" .OR. ! SUBSTR(CHD->CHD_APUEST, 2, 1) $ "0|E|B" .OR. ! SUBSTR(CHD->CHD_APUEST, 3, 1) $ "0|E|B" .OR. ! SUBSTR(CHD->CHD_APUEST, 4, 1) $ "0|E|B" .OR. ! SUBSTR(CHD->CHD_APUEST, 5, 1) $ "0|E|B" .OR. ! SUBSTR(CHD->CHD_APUEST, 6, 1) $ "0|E|B" ;
			.OR. ! SUBSTR(CHD->CHD_APUEST, 7, 1) $ "0|E|B" .OR. ! SUBSTR(CHD->CHD_APUEST, 8, 1) $ "0|E|B" .OR. ! SUBSTR(CHD->CHD_APUEST, 9, 1) $ "0|E|B" .OR. ! SUBSTR(CHD->CHD_APUEST, 10, 1) $ "0|E|B" .OR. ! SUBSTR(CHD->CHD_APUEST, 11, 1) $ "0|E|B" .OR. ! SUBSTR(CHD->CHD_APUEST, 12, 1) $ "0|E|B"
				Aadd(aLogErro,{"CHD_APUEST","000086","CHD",nRecno}) //STR0086 - "Se o campo Forma de Tributação no Período for igual a 'R' ou 'E', o campo Indicação da Forma de Apuração da Estimativa deve ser preenchido com '0', 'E' ou 'B'.		
		EndIf 	
	EndIf*/
		
   	//REGRA_NAO_PREENCHER_IMUNE
	If CHD->CHD_FORTRB == "8" .OR. CHD->CHD_FORTRB == "9" 
		If ! Empty(CHD->CHD_APUEST)
			Aadd(aLogErro,{"CHD_APUEST","000065","CHD",nRecno}) //STR0065 - "Se o campo Forma de Tributação do Lucro for igual a '8' (Imune de IRPJ) ou '9' (Isento do IPRJ), o campo não deve ser preenchido.		
		EndIf
	EndIf
      
   //REGRA_PREENCHER_TIP_ESC
   	If CHD->CHD_FORTRB == "3" .OR. CHD->CHD_FORTRB == "4" .OR. CHD->CHD_FORTRB == "5" .OR. CHD->CHD_FORTRB == "7" .OR. CHD->CHD_FORTRB == "8" .OR. CHD->CHD_FORTRB == "9" 
		If Empty(CHD->CHD_TIPESC)
			Aadd(aLogErro,{"CHD_TIPESC","000087","CHD",nRecno}) //STR0087 - "Se o campo Forma de Tributação do Lucro for igual a '3' (Lucro Presumido/Real), '4' (Lucro/Presumido/Real/Arbitrado), '5' (Lucro Presumido), '7' (Lucro Presumido/Arbitrado), '8' (Imune de IRPJ) ou '9' (Isento do IPRJ), o campo deve ser preenchido obrigatoriamente." 		
		EndIf
	EndIf
	
   //REGRA_PREENCHER_IMUNE
   	If CHD->CHD_FORTRB == "8" .OR. CHD->CHD_FORTRB == "9" 
		If Empty(cTipEnt)
			Aadd(aLogErro,{"CHD_TIPENT","000088","CHD",nRecno}) //STR0088 - "Se o campo Forma de Tributação do Lucro for igual a '8' (Imune de IRPJ) ou '9' (Isento do IPRJ), o campo deve ser preenchido obrigatoriamente.		
		EndIf
	EndIf
   
   //REGRA_PREENCHER_IMUNE
   If CHD->CHD_FORTRB == "8" .OR. CHD->CHD_FORTRB == "9" 
		If Empty(CHD->CHD_ATTRBI)
			Aadd(aLogErro,{"CHD_ATTRBI","000088","CHD",nRecno}) //STR0088 - "Se o campo Forma de Tributação do Lucro for igual a '8' (Imune de IRPJ) ou '9' (Isento do IPRJ), o campo deve ser preenchido obrigatoriamente.		
		EndIf
	EndIf
   
   //REGRA_APUR_IGUAL
    If CHD->CHD_APCSLI <> "3"
		If ! CHD->CHD_ATTRBI == CHD->CHD_APCSLI 
			Aadd(aLogErro,{"CHD_ATTRBI","000089","CHD",nRecno}) //STR0089 - "Se o campo Atividade Tributada pelo IRPJ e CSLL para Imunes ou Isentas for igual a 3-'D'(Desobrigado), o campo Atividade Tributada pelo IRPJ e CSLL para Imunes ou Isentas deve ser igual ao campo Apuração da CSLL para Imunes e Isentas.		
		EndIf
	EndIf
   
   //REGRA_PREENCHER_IMUNE
   If CHD->CHD_FORTRB == "8" .OR. CHD->CHD_FORTRB == "9" 
		If Empty(CHD->CHD_APCSLI)
			Aadd(aLogErro,{"CHD_APCSLI","000088","CHD",nRecno}) //STR0088 - "Se o campo Forma de Tributação do Lucro for igual a '8' (Imune de IRPJ) ou '9' (Isento do IPRJ), o campo deve ser preenchido obrigatoriamente.		
		ElseIf CHD->CHD_APCSLI == '3' .AND. !Empty(CHD->CHD_IDCSLL)
			Aadd(aLogErro,{"CHD_IDCSLL","000262","CHD",nRecno}) //STR0262 - "Se o campo Forma de Tributação do Lucro for igual a '8' (Imune de IRPJ) ou '9' (Isento do IPRJ) e o campo Apur CSLL Imunes/Isentas for igual a '3' (Desobrigada), o campo não pode ser preenchido, obrigatoriamente deve estar em branco. 
		EndIF
	EndIf
   
   //REGRA_NAO_OPT_RTT - 20/07/2015 - Desabilitada no manual de Novembro 2014
   /*If CHD->CHD_FORTRB == "6" .OR. CHD->CHD_FORTRB == "8" .OR. CHD->CHD_FORTRB == "9" 
		If CHD->CHD_OPTRTT <> "2"
			Aadd(aLogErro,{"CHD_OPTRTT","000090","CHD",nRecno}) //STR0090 - "Se o campo Forma de Tributação do Lucro for igual a '6' (Lucro Arbitrado), '8' (Imune de IRPJ) ou '9' (Isento do IPRJ), o campo deve ser preenchido com 2-Não."
		EndIf
	EndIf*/

	//REGRA_PREENCHER_OPT_EXT_RTT
	If Empty(CHD->CHD_DIFFCO)
		If CHD->CHD_OPTRTT == "1"
			aAdd( aLogErro, { "CHD_DIFFCO", "000235", "CHD", nRecno } ) //STR0235 - "O campo Dif FCONT deve estar preenchido quando o campo Op Ext RTT for igual a '1 - Sim'."
		EndIf
	Elseif !(CHD->CHD_DIFFCO $ "1|2")               
		aAdd(aLogErro,{"CHD_DIFFCO","000002","CHD", nRecno }) //STR0002 "Conteúdo do campo não condiz com as opções possíveis." 
	EndIf
	//REGRAS ESPECIFICAS - ABA03 - Parâmetros Complementares - 0020
   
   //REGRA_SCP_NAO_PREENCHER_QTD
   	If (CHD->CHD_TPECF == "0" .OR. CHD->CHD_TPECF == "2") .And. CHD->CHD_QTDSCP > 0
		Aadd(aLogErro,{"CHD_QTDSCP","000091","CHD",nRecno}) //STR0091 - "Se o campo Tipo da ECF for igual a '0' (ECF de empresa não participante de SCP como sócio ostensivo) ou '2' (ECF da SCP), o campo não deve ser preenchido." 		
	EndIf
	
   //REGRA_SCP_OBRIGATORIO_QTD
  	If CHD->CHD_TPECF == "1" .and. CHD->CHD_QTDSCP == 0
		Aadd(aLogErro,{"CHD_QTDSCP","000092","CHD",nRecno}) //STR0092 - "Se o campo Tipo da ECF for igual a '1' (ECF de empresa participante de SCP como sócio ostensivo), o campo deve ser preenchido obrigatoriamente." 		
	EndIf
   
   //REGRA_PREENCHIMENTO_IND_ADM_FUN_CLU
   If CHD->CHD_FORTRB == "8" .OR. (cTipEnt <> "06" .AND. cTipEnt <> "11" .AND. cTipEnt <> "12")
		If Empty(CHD->CHD_INDADM)
			Aadd(aLogErro,{"CHD_INDADM","000093","CHD",nRecno}) //STR0093 - "Se o campo Forma de Tributação do Lucro for igual a '8' (Imune de IRPJ) ou o Tipo de Entidade é diferente de '06' (Entidade Fechada de Previdência Complementar), '11' (Associação de Poupança e Empréstimo) e '12'(Entidade Aberta de Previdência Complementar Sem Fins Lucrativos), o campo deve ser preenchido obrigatoriamente."		
		EndIf
	EndIf
   
   //REGRA_PREENCHIMENTO_ATIV_13
   If cTipEnt == "13"
		If CHD->CHD_INDPAC <> "2"
			Aadd(aLogErro,{"CHD_INDPAC","000094","CHD",nRecno}) //STR0094 - "Se o campo Tipo de Entidade for igual a '13' (Fifa e Entidades Relacionadas), o campo Participações em Consórcios de Empresas deve ser igual a 2-Não."		
		EndIf
	EndIf
   
   //REGRA_PREENCHIMENTO_IMUNE_ISENTA
   If CHD->CHD_FORTRB == "8" .OR. CHD->CHD_FORTRB == "9" 
		If CHD->CHD_INDOPE <> "2"
			Aadd(aLogErro,{"CHD_INDOPE","000095","CHD",nRecno}) //STR0095 - "Se o campo Forma de Tributação do Lucro for igual a '8' (Imune de IRPJ) ou '9' (Isento do IPRJ), o campo Operações com o Exterior deve ser igual a 2-Não."		
		EndIf
	EndIf
   
   //REGRA_PREENCHIMENTO_IND_OP_VINC
   	If CHD->CHD_INDOPE == "2"
		If CHD->CHD_INDOPV <> "2"
			Aadd(aLogErro,{"CHD_INDOPV","000096","CHD",nRecno}) //STR0096 - "Se o campo Operações com o Exterior for igual a 2-Não, o campo Operações com Pessoa Vinculada/Interposta Pessoa/País com Tributação Favorecida também deve ser igual a 2-Não."		
		EndIf
	EndIf
   
   //REGRA_PREENCHIMENTO_IND_OP_VINC
   If CHD->CHD_INDOPE == "2"
		If CHD->CHD_INDPJE <> "2"
			Aadd(aLogErro,{"CHD_INDPJE","000097","CHD",nRecno}) //STR0097 - "Se o campo Operações com o Exterior for igual a 2-Não, o campo PJ Enquadrada nos artigos 48 ou 49 da IN RFB no 1.312/2012 também deve ser igual a 2-Não."		
		EndIf
	EndIf
   
   //REGRA_PREENCHIMENTO_IND_PART_EXT
   If CHD->CHD_FORTRB == "8" .OR. CHD->CHD_FORTRB == "9" 
		If CHD->CHD_INDPAE <> "2"
			Aadd(aLogErro,{"CHD_INDPAE","000098","CHD",nRecno}) //STR0098 - "Se o campo Forma de Tributação do Lucro for igual a '8' (Imune de IRPJ) ou '9' (Isento do IPRJ), o campo Participações no Exterior deve ser igual a 2-Não."		
		EndIf
	ElseIf	(CHD->CHD_FORTRB == "5" .OR. CHD->CHD_FORTRB == "7") .AND. CHD->CHD_OPTREF == "2"
		If CHD->CHD_INDPAE <> "2"
			Aadd(aLogErro,{"CHD_INDPAE","000099","CHD",nRecno}) //STR0099 - "Se o campo Forma de Tributação do Lucro for igual a '5' (Lucro Presumido) ou '7' (Lucro Presumido/Arbitrado) e Indicador de Optante pelo Refis igual a 2-Não, o campo Participações no Exterior deve ser igual a 2-Não."			
		EndIf
	EndIf
   
   //REGRA_PREENCHIMENTO_IND_ATIV_RURAL
   If nAnoECF == 2014 //Regra foi excluída a partir de 2015
	   If  CHD->CHD_CODQUA <> "01" .OR. (CHD->CHD_FORTRB <> "1" .AND. CHD->CHD_FORTRB <> "2" .AND. CHD->CHD_FORTRB <> "3" .AND. CHD->CHD_FORTRB <> "4")
			If CHD->CHD_INDATV <> "2"
				Aadd(aLogErro,{"CHD_INDATV","000100","CHD",nRecno}) //STR0100 - "Se o campo Qualificação da Pessoa Jurídica for diferente de '00' (PJ em Geral) e a Forma de Tributação do Lucro for diferente de '1' (Lucro Real), '2' (Lucro Real/Arbitrado), '3' (Lucro Presumido/Real) ou '4' (Lucro Presumido/Real/Arbitrado), o campo Atividade Rural deve ser igual a 2-Não."		
			EndIf
	   EndIf
	EndIF
   
   //REGRA_PREENCHIMENTO_IND_LUC_EXP
   If  CHD->CHD_CODQUA <> "01" .OR. (CHD->CHD_FORTRB <> "1" .AND. CHD->CHD_FORTRB <> "2" .AND. CHD->CHD_FORTRB <> "3" .AND. CHD->CHD_FORTRB <> "4")
		If CHD->CHD_INDLUC <> "2"
			Aadd(aLogErro,{"CHD_INDLUC","000101","CHD",nRecno}) //STR0101 - "Se o campo Qualificação da Pessoa Jurídica for diferente de '00' (PJ em Geral) e a Forma de Tributação do Lucro for diferente de '1' (Lucro Real), '2' (Lucro Real/Arbitrado), '3' (Lucro Presumido/Real) ou '4' (Lucro Presumido/Real/Arbitrado), o campo Lucro da Exploração deve ser igual a 2-Não."		
		EndIf
   EndIf
      
   //REGRA_PREENCHIMENTO_IND_RED_ISEN
   If CHD->CHD_OPTREF <> "1" .OR. CHD->CHD_CODQUA <> "01" .OR. (CHD->CHD_FORTRB <> "5" .AND. CHD->CHD_FORTRB <> "7")
		If CHD->CHD_INDRED <> "2"
			Aadd(aLogErro,{"CHD_INDRED","000102","CHD",nRecno}) //STR0102 - "Se o campo Indicador de Optante pelo Refis for diferente de 1-Sim ou a Qualificação da Pessoa Jurídica for diferente de '00' (PJ em Geral) ou a Forma de Tributação do Lucro for diferente de '5' (Lucro Presumido) ou '7' (Lucro Presumido/Arbitrado), o campo Isenção e Redução do Imposto para Lucro Presumido deve ser igual a 2-Não."		
		EndIf
   EndIf
   
   //REGRA_PREENCHIMENTO_IND_FIN
   If CHD->CHD_FORTRB <> "1" .AND. CHD->CHD_FORTRB <> "2" .AND. CHD->CHD_FORTRB <> "3" .AND. CHD->CHD_FORTRB <> "4"
   		If CHD->CHD_INDFIN <> "2"
			Aadd(aLogErro,{"CHD_INDFIN","000103","CHD",nRecno}) //STR0103 - "Se o campo Forma de Tributação do Lucro for diferente de '1' (Lucro Real), '2' (Lucro Real/Arbitrado), '3' (Lucro Presumido/Real) ou '4' (Lucro Presumido/Real/Arbitrado), o campo FINOR/FINAM/FUNRES deve ser igual a 2-Não."		
		EndIf
   EndIf
    
   //REGRA_PREENCHIMENTO_IMUNE_ISENTA
   If CHD->CHD_FORTRB == "8" .OR. CHD->CHD_FORTRB == "9" 
		If CHD->CHD_INDDOA <> "2"
			Aadd(aLogErro,{"CHD_INDDOA","000104","CHD",nRecno}) //STR0104 - "Se o campo Forma de Tributação do Lucro for igual a '8' (Imune de IRPJ) ou '9' (Isento do IPRJ), o campo Doações a Campanhas Eleitorais deve ser igual a 2-Não."		
		EndIf
	EndIf
   
   //REGRA_PREENCHIMENTO_ATIV_13
   If cTipEnt == "13"
		If CHD->CHD_INDPAG <> "2"
			Aadd(aLogErro,{"CHD_INDPAG","000105","CHD",nRecno}) //STR0105 - "Se o campo Tipo de Entidade for igual a '13' (Fifa e Entidades Relacionadas), o campo Participação Permanente em Coligadas ou Controladas deve ser igual a 2-Não."		
		EndIf
	EndIf
   
   //REGRA_PREENCHIMENTO_IMUNE_ISENTA
   If CHD->CHD_FORTRB == "8" .OR. CHD->CHD_FORTRB == "9" 
		If CHD->CHD_INDVEN <> "2"
			Aadd(aLogErro,{"CHD_INDVEN","000106","CHD",nRecno}) //STR0106 - "Se o campo Forma de Tributação do Lucro for igual a '8' (Imune de IRPJ) ou '9' (Isento do IPRJ), o campo Vendas a Empresa Comercial Exportadora deve ser igual a 2-Não."		
		EndIf
	EndIf
   
   //REGRA_PREENCHIMENTO_PJ
   If CHD->CHD_CODQUA <> "01"
		If CHD->CHD_INDVEN <> "2"
			Aadd(aLogErro,{"CHD_INDVEN","000107","CHD",nRecno}) //STR0107 - "Se o campo Qualificação da Pessoa Jurídica for diferente de '00' (PJ em Geral), o campo Vendas a Empresa Comercial Exportadora deve ser igual a 2-Não."		
		EndIf
   EndIf
   
   //REGRA_PREENCHIMENTO_ATIV_13
   If cTipEnt == "13"
		If CHD->CHD_INDREC <> "2"
			Aadd(aLogErro,{"CHD_INDREC","000108","CHD",nRecno}) //STR0108 - "Se o campo Tipo de Entidade for igual a '13' (Fifa e Entidades Relacionadas), o campo Rendimentos do Exterior ou de Não Residentes deve ser igual a 2-Não."		
		EndIf
	EndIf
   
   //REGRA_PREENCHIMENTO_ATIV_13
   If cTipEnt == "13"
		If CHD->CHD_INDEXT <> "2"
			Aadd(aLogErro,{"CHD_INDEXT","000109","CHD",nRecno}) //STR0109 - "Se o campo Tipo de Entidade for igual a '13' (Fifa e Entidades Relacionadas), o campo Ativos no Exterior deve ser igual a 2-Não."		
		EndIf
	EndIf
     
   //REGRA_PREENCHIMENTO_PJ
   If CHD->CHD_CODQUA <> "01"
		If CHD->CHD_INDEXT <> "2"
			Aadd(aLogErro,{"CHD_INDEXT","000110","CHD",nRecno}) //STR0110 - "Se o campo Qualificação da Pessoa Jurídica for diferente de '00' (PJ em Geral), o campo Ativos no Exterior deve ser igual a 2-Não."		
		EndIf
   EndIf
   
   //REGRA_PREENCHIMENTO_IMUNE_ISENTA
   If CHD->CHD_FORTRB == "8" .OR. CHD->CHD_FORTRB == "9" 
		If CHD->CHD_INDEXP <> "2"
			Aadd(aLogErro,{"CHD_INDEXP","000111","CHD",nRecno}) //STR0111 - "Se o campo Forma de Tributação do Lucro for igual a '8' (Imune de IRPJ) ou '9' (Isento do IPRJ), o campo PJ Comercial Exportadora deve ser igual a 2-Não."		
		EndIf
	EndIf
   
   //REGRA_PREENCHIMENTO_PJ_00
   If CHD->CHD_CODQUA <> "01"
		If CHD->CHD_INDEXP <> "2"
			Aadd(aLogErro,{"CHD_INDEXP","000112","CHD",nRecno}) //STR0112 - "Se o campo Qualificação da Pessoa Jurídica for diferente de '00' (PJ em Geral), o campo PJ Comercial Exportadora deve ser igual a 2-Não."		
		EndIf
   EndIf
   
   //REGRA_PREENCHIMENTO_ATIV_13
   If cTipEnt == "13"
		If CHD->CHD_INDPGE <> "2"
			Aadd(aLogErro,{"CHD_INDPGE","000113","CHD",nRecno}) //STR0113 - "Se o campo Tipo de Entidade for igual a '13' (Fifa e Entidades Relacionadas), o campo Pagamentos ao Exterior ou a Não Residentes deve ser igual a 2-Não."		
		EndIf
	EndIf
   
   //REGRA_PREENCHIMENTO_ATIV_13
   If cTipEnt == "13"
		If CHD->CHD_INDECO <> "2"
			Aadd(aLogErro,{"CHD_INDECO","000114","CHD",nRecno}) //STR0114 - "Se o campo Tipo de Entidade for igual a '13' (Fifa e Entidades Relacionadas), o campo Comércio Eletrônico e Tecnologia da Informação deve ser igual a 2-Não."		
		EndIf
	EndIf
   
   //REGRA_PREENCHIMENTO_ATIV_13
   If cTipEnt == "13"
		If CHD->CHD_INDROY <> "2"
			Aadd(aLogErro,{"CHD_INDROY","000115","CHD",nRecno}) //STR0115 - "Se o campo Tipo de Entidade for igual a '13' (Fifa e Entidades Relacionadas), o campo Royalties Recebidos do Brasil e do Exterior deve ser igual a 2-Não."		
		EndIf
	EndIf
   
   //REGRA_PREENCHIMENTO_ATIV_13
   If cTipEnt == "13"
		If CHD->CHD_INDROP <> "2"
			Aadd(aLogErro,{"CHD_INDROP","000116","CHD",nRecno}) //STR0116 - "Se o campo Tipo de Entidade for igual a '13' (Fifa e Entidades Relacionadas), o campo Royalties Pagos a Beneficiários do Brasil e do Exterior deve ser igual a 2-Não."		
		EndIf
	EndIf
   
   //REGRA_PREENCHIMENTO_ATIV_13
   If cTipEnt == "13"
		If CHD->CHD_INDREN <> "2"
			Aadd(aLogErro,{"CHD_INDREN","000117","CHD",nRecno}) //STR0117 - "Se o campo Tipo de Entidade for igual a '13' (Fifa e Entidades Relacionadas), o campo Rendimentos Relativos a Serviços, Juros e Dividendos Recebidos do Brasil e do Exterior deve ser igual a 2-Não."		
		EndIf
	EndIf
   
   //REGRA_PREENCHIMENTO_ATIV_13
   If cTipEnt == "13"
		If CHD->CHD_INDREM <> "2"
			Aadd(aLogErro,{"CHD_INDREM","000118","CHD",nRecno}) //STR0118 - "Se o campo Tipo de Entidade for igual a '13' (Fifa e Entidades Relacionadas), o campo Pagamentos ou Remessas a Título de Serviços, Juros e Dividendos a Beneficiários do Brasil e do Exterior deve ser igual a 2-Não."		
		EndIf
	EndIf
   
   //REGRA_PREENCHIMENTO_IMUNE_ISENTA
   If CHD->CHD_FORTRB == "8" .OR. CHD->CHD_FORTRB == "9" 
		If CHD->CHD_INDINO <> "2"
			Aadd(aLogErro,{"CHD_INDINO","000119","CHD",nRecno}) //STR0119 - "Se o campo Forma de Tributação do Lucro for igual a '8' (Imune de IRPJ) ou '9' (Isento do IPRJ), o campo Inovação Tecnológica e Desenvolvimento Tecnológico deve ser igual a 2-Não."		
		EndIf
	EndIf
   
   //REGRA_PREENCHIMENTO_IMUNE_ISENTA
   If CHD->CHD_FORTRB == "8" .OR. CHD->CHD_FORTRB == "9" 
		If CHD->CHD_INDCAP <> "2"
			Aadd(aLogErro,{"CHD_INDCAP","000120","CHD",nRecno}) //STR0120 - "Se o campo Forma de Tributação do Lucro for igual a '8' (Imune de IRPJ) ou '9' (Isento do IPRJ), o campo Capacitação de Informática e Inclusão Digital deve ser igual a 2-Não."		
		EndIf
	EndIf
   
   //REGRA_PREENCHIMENTO_IMUNE_ISENTA
   If CHD->CHD_FORTRB == "8" .OR. CHD->CHD_FORTRB == "9" 
		If CHD->CHD_INDPJH <> "2"
			Aadd(aLogErro,{"CHD_INDPJH","000121","CHD",nRecno}) //STR0121 - "Se o campo Forma de Tributação do Lucro for igual a '8' (Imune de IRPJ) ou '9' (Isento do IPRJ), o campo PJ Habilitada deve ser igual a 2-Não."		
		EndIf
	EndIf
   
   //REGRA_PREENCHIMENTO_IMUNE_ISENTA
   If CHD->CHD_FORTRB == "8" .OR. CHD->CHD_FORTRB == "9" 
		If CHD->CHD_INDPOL <> "2"
			Aadd(aLogErro,{"CHD_INDPOL","000122","CHD",nRecno}) //STR0122 - "Se o campo Forma de Tributação do Lucro for igual a '8' (Imune de IRPJ) ou '9' (Isento do IPRJ), o campo Pólo Industrial de Manaus e Amazônia Ocidental deve ser igual a 2-Não."		
		EndIf
	EndIf
   
   //REGRA_PREENCHIMENTO_IMUNE_ISENTA
   If CHD->CHD_FORTRB == "8" .OR. CHD->CHD_FORTRB == "9" 
		If CHD->CHD_INDZON <> "2"
			Aadd(aLogErro,{"CHD_INDZON","000123","CHD",nRecno}) //STR0123 - "Se o campo Forma de Tributação do Lucro for igual a '8' (Imune de IRPJ) ou '9' (Isento do IPRJ), o campo Zonas de Processamento de Exportação deve ser igual a 2-Não."		
		EndIf
	EndIf
   
   //REGRA_PREENCHIMENTO_IMUNE_ISENTA
   If CHD->CHD_FORTRB == "8" .OR. CHD->CHD_FORTRB == "9" 
		If CHD->CHD_INDARE <> "2"
			Aadd(aLogErro,{"CHD_INDARE","000125","CHD",nRecno}) //STR0125 - "Se o campo Forma de Tributação do Lucro for igual a '8' (Imune de IRPJ) ou '9' (Isento do IPRJ), o campo Áreas de Livre Comércio deve ser igual a 2-Não."		
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
		RecLock("CHD",.F.)
		CHD->CHD_STATUS := "1"
		MsUnlock()
	Else
		RecLock("CHD",.F.)
		CHD->CHD_STATUS := "0"
		MsUnlock()
	EndIf	  	    
	
	
Else
	
	AADD(aLogErro,{"CHD_ID","000017","CHD", nRecno})//STR0017 - Registro já validado.
	
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Não apresento o alert quando utilizo o JOB para validar³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lJob
	VldECFLog(aLogErro)
EndIf


Return(aLogErro)

/*/{Protheus.doc} TAF372Init
Função para tratamentos dos incios padrões do cadastro
@author david.costa
@since 17/07/2017
@version 1.0
@return ${cRet}, ${cRet}
@example
TAF372Init()
/*/Function TAF372Init(cCampo)

Local cRet			:= ""
Local cIdFilial		:= ""
Local cIdCuW		:= ""
Local cNomScp		:= "" 
Local cContCmp		:= ""
Local cRetCScp      := ""
Local cRetDScp      := ""

Default cCampo		:= ReadVar()

INCLUI := Iif( Type( "INCLUI" ) == "U", .F., INCLUI ) 
cContCmp := Iif(INCLUI ," ",FwFldGEt("CHD_IDCODS"))

If "CHD_DCODSC" $ cCampo
	If !Empty( cContCmp )
		cIdFilial := AllTrim( iIf( Len( AllTrim( cContCmp ) ) == 12, SubStr( cContCmp, 7, 12 ), cContCmp ) )		
		if len(cIdFilial) == 14 .and. CGC(cIdFilial) //Priorizacao por cnpj informado no CUW_CNPJ
			cRetDScp := TafScpCNPJ(cIdFilial, "CHD_DCODSC")
		endif
		if !empty( cRetDScp )
			cRet  := cRetDScp
		else
			// cIdCuW := Posicione( "CUW", 1, xFilial("CUW") + cIdFilial, "CUW_CODSCP" ) 
			CUW->(DbSetOrder(1))
			if CUW->(DbSeek(xFilial('CUW')+cIdFilial))
				cIdCuW := CUW->CUW_CODSCP 
				cNomScp := CUW->CUW_NOMSCP 
			endif 
			if !empty(cIdCuW)
				cIdFilial := AllTrim( iIf( Len( AllTrim(cIdCuW ) ) == 12, SubStr( cIdCuW, 7, 12 ), cIdCuW ) )
				cRet := Posicione( "C1E", 2, xFilial("C1E") + cIdFilial, "C1E_NOME" )
			elseIf !empty(cNomScp)
				cRet := CUW->CUW_NOMSCP   
			endif
		endif
	EndIf
EndIf

If "CHD_CODSCP" $ cCampo
	If !INCLUI .and. !Empty( cContCmp )
		cRet := AllTrim( iIf( Len( AllTrim( cContCmp ) ) == 12, SubStr( cContCmp, 7, 12 ), cContCmp ) )
		if len(cRet) == 14 .and. CGC(cRet)
			cRetCScp := TafScpCNPJ(cRet, "CHD_CODSCP")
		endif
		if !empty( cRetCScp )
			cRet  := cRetCScp
		endif
	EndIf
EndIf

Return( cRet )

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} TafScpCNPJ
Criado funcao para verificar se o CNPJ existe na CUW, 
ja que nao existe um indice para CNPJ

@author Denis Souza
@since 27/09/2021
@version 1.0
/*/                                                                                                                                          
//------------------------------------------------------------------------------------
Function TafScpCNPJ( cCNPJ, cCmp )

	Local cQry 	  := GetNextAlias()
	Local cWhere  := "CUW.D_E_L_E_T_ = ' '"
	Local cRet    := ""
	Local cOrder  := "CUW.R_E_C_N_O_ DESC "
	Default cCNPJ := ""
	Default cCmp  := ""

	if !Empty(cCNPJ)
		cWhere += " AND CUW.CUW_CNPJ = '" + cCNPJ + "' "
	endif

	if cCmp == "CHD_DCODSC"
		cCmp := "CUW.CUW_NOMSCP"
	elseIf cCmp == "CHD_CODSCP"
		cCmp := "CUW.CUW_CODSCP"
	endif

	if "CUW" $ cCmp
		cCmp   := "%" + cCmp   + "%"
		cWhere := "%" + cWhere + "%"
		cOrder := "%" + cOrder + "%"
		BEGINSQL ALIAS cQry
			SELECT %Exp:cCmp% NMCMP
			FROM %Table:CUW% CUW
			WHERE %Exp:cWhere%
			ORDER BY %Exp:cOrder%
		ENDSQL
		While !(cQry)->(Eof())
			cRet := Alltrim( (cQry)->NMCMP )
			exit
		EndDo
		(cQry)->(DbCloseArea())
	endif

Return cRet
