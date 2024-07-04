#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA324.CH"

//------------------------------------------------------------------------
/*/{Protheus.doc} TAFA324
Cadastro MVC - T093 - Identificação dos Períodos e Formas de Apuração do 
IRPJ e da CSLL das Empresas Imunes e Isentas

@author Paulo Sérgio V.B. SantanA
@since 19/05/2014
@version 1.0

/*/
//------------------------------------------------------------------------
Function TAFA324()
Local	oBrw		:=	FWmBrowse():New()
Local cTitulo := STR0001 //Identificação Apuração do IRPJ e da CSLL das Empresas Imunes e Isentas

dbSelectArea("CEY")
CEY->(DbSetOrder(2)) 
oBrw:SetDescription(cTitulo) 
						  
oBrw:SetAlias('CEY')
oBrw:SetMenuDef('TAFA324')
oBrw:SetCacheView(.F.)
oBrw:Activate()


Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Paulo Sérgio V.B. Santana
@since 19/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()  
Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf324Vld" , "2" } )

lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If lMenuDif
	ADD OPTION aRotina Title "Visualizar" Action 'VIEWDEF.TAFA324' OPERATION 2 ACCESS 0
Else
	aRotina	:=	xFunMnuTAF( "TAFA324" , , aFuncao)
EndIf                                     

Return( aRotina )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Paulo Sérgio V.B. Santana
@since 19/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()  

Local  oStruCEY := FWFormStruct( 1, 'CEY' )
Local  oStruCEZ := FWFormStruct( 1, 'CEZ' )
Local  oStruCFI := FWFormStruct( 1, 'CFI' )
Local  oStruCHG := FWFormStruct( 1, 'CHG' )
Local  oModel   :=  MpFormModel():New("TAFA324" , , , {|oModel| SaveModel( oModel ) } )

oStruCFI:SetProperty( "CFI_CODIGO", MODEL_FIELD_VALID , ;
{ |oModel| Iif( oModel:GetId() == "MODEL_CFIa", xFunVldCmp( "CH6", 2, PadR( "U180", TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CFI_CODIGO" ) ),;
xFunVldCmp( "CH6", 2, PadR( "U182", TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CFI_CODIGO" )  ) ) } )

oStruCFI:AddTrigger( "CFI_CODIGO", "CFI_DESCRI",, ;
{ |oModel| Iif( oModel:GetId() == "MODEL_CFIa", Posicione( "CH6", 2, xFilial( "CH6" ) + PadR( "U180", TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CFI_CODIGO" ), "CH6_DESCRI" ),;
Posicione( "CH6", 2, xFilial( "CH6" ) + PadR( "U182", TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CFI_CODIGO" ), "CH6_DESCRI" ))})

oStruCFI:AddTrigger( "CFI_CODIGO", "CFI_IDCODC",, ;
{ |oModel| Iif( oModel:GetId() == "MODEL_CFIa", Posicione( "CH6", 2, xFilial( "CH6" ) + PadR( "U180", TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CFI_CODIGO" ), "CH6_ID" ),;
Posicione( "CH6", 2, xFilial( "CH6" ) + PadR( "U182", TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CFI_CODIGO" ), "CH6_ID" ))})

lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )
	
If lVldModel
	oStruCEY:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel }) 		
EndIf

oStruCFI:SetProperty( 'CFI_REGECF' , MODEL_FIELD_INIT ,{| oModel | Iif(oModel:Getid()=='MODEL_CFIa',"01","02")})

oModel:AddFields( 'MODEL_CEY', /*cOwner*/, oStruCEY )
oModel:GetModel( 'MODEL_CEY' ):SetPrimaryKey( { "CEY_DTINI","CEY_DTFIN","CEY_IDPERA" } )
	
oModel:AddGrid('MODEL_CEZ', 'MODEL_CEY',oStruCEZ )
oModel:GetModel('MODEL_CEZ'):SetOptional( .T. )
oModel:GetModel('MODEL_CEZ'):SetUniqueLine( { "CEZ_IDCODC" } )

oModel:AddGrid('MODEL_CFIa', 'MODEL_CEZ',oStruCFI )
oModel:GetModel('MODEL_CFIa'):SetOptional( .T. )
oModel:GetModel('MODEL_CFIa'):SetLoadFilter( { { 'CFI_REGECF', "'01'" } } )
oModel:GetModel('MODEL_CFIa'):SetUniqueLine( { "CFI_REGECF","CFI_IDCODC" } )

oModel:AddGrid('MODEL_CFIb', 'MODEL_CEZ',oStruCFI )
oModel:GetModel('MODEL_CFIb'):SetOptional( .T. )
oModel:GetModel('MODEL_CFIb'):SetLoadFilter( { { 'CFI_REGECF', "'02'" } } )
oModel:GetModel('MODEL_CFIb'):SetUniqueLine( { "CFI_REGECF","CFI_IDCODC" } )       

oModel:AddGrid('MODEL_CHG', 'MODEL_CEZ',oStruCHG )
oModel:GetModel('MODEL_CHG'):SetOptional( .T. )
oModel:GetModel('MODEL_CHG'):SetUniqueLine( { "CHG_TABECF","CHG_IDCODC" } )       

//Relacionamento das Grids
oModel:SetRelation( 'MODEL_CEZ'  , { { 'CEZ_FILIAL', 'xFilial( "CEZ" )' } , {'CEZ_ID','CEY_ID'}}, CEZ->( IndexKey( 1 ) ) ) 
oModel:SetRelation( 'MODEL_CFIa' , { { 'CFI_FILIAL', 'xFilial( "CFI" )' } , {'CFI_ID','CEY_ID'}}, CFI->( IndexKey( 1 ) ) )                                                                                       
oModel:SetRelation( 'MODEL_CFIb' , { { 'CFI_FILIAL', 'xFilial( "CFI" )' } , {'CFI_ID','CEY_ID'}}, CFI->( IndexKey( 1 ) ) )    
oModel:SetRelation( 'MODEL_CHG' , { { 'CHG_FILIAL', 'xFilial( "CHG" )' } , {'CHG_ID','CEY_ID'}}, CHG->( IndexKey( 1 ) ) )    
Return ( oModel )

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Paulo Sérgio V.B. Santana
@since 19/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel		:=	FWLoadModel( "TAFA324" )
Local oStruCEY	:=	FWFormStruct( 2, "CEY" )
Local oStruCEZ	:=	FWFormStruct( 2, "CEZ" )
Local oStruCHG	:=	FWFormStruct( 2, "CHG" )
Local oStruCFIa	:=	FWFormStruct( 2, "CFI" )
Local oStruCFIb	:=	FWFormStruct( 2, "CFI" )
Local oView		:=	FWFormView():New()

oView:SetModel( oModel )

oStruCFIa:SetProperty( "CFI_CODIGO", MVC_VIEW_LOOKUP, "CH6A" )
oStruCFIb:SetProperty( "CFI_CODIGO", MVC_VIEW_LOOKUP, "CH6B" )

oView:AddField( "VIEW_CEY", oStruCEY, "MODEL_CEY" )

oView:AddGrid( "VIEW_CEZ", oStruCEZ, "MODEL_CEZ" )
oView:AddGrid( "VIEW_CHG", oStruCHG, "MODEL_CHG" )
oView:AddGrid( "VIEW_CFIa", oStruCFIa, "MODEL_CFIa" )
oView:AddGrid( "VIEW_CFIb", oStruCFIb, "MODEL_CFIb" )

oView:EnableTitleView( "VIEW_CEY" )

oView:CreateHorizontalBox( "FIELDSCEY", 30 )
oView:CreateHorizontalBox( "PANFOLDER1", 70 )

oView:CreateFolder( "FOLDER1", "PANFOLDER1" )

oView:AddSheet( "FOLDER1", "F1ABA1", oView:GetModel( "MODEL_CEZ" ):GetDescription() )
oView:AddSheet( "FOLDER1", "F1ABA2", oView:GetModel( "MODEL_CHG" ):GetDescription() )
oView:AddSheet( "FOLDER1", "F1ABA3", oView:GetModel( "MODEL_CFIa" ):GetDescription() )

oView:SetOwnerView( "VIEW_CEY", "FIELDSCEY" )

//ABA1
oView:CreateHorizontalBox( "AGRIDCEZ", 100,,, "FOLDER1", "F1ABA1" )
oView:SetOwnerView( "VIEW_CEZ", "AGRIDCEZ" )

//ABA2
oView:CreateHorizontalBox( "AGRIDCHG", 100,,, "FOLDER1", "F1ABA2" )
oView:SetOwnerView( "VIEW_CHG", "AGRIDCHG" )

//ABA3
oView:CreateHorizontalBox( "PAINEL_FOLDER1", 100,,, "FOLDER1", "F1ABA3" )

oView:CreateFolder( "FOLDER2", "PAINEL_FOLDER1" )

oView:AddSheet( "FOLDER2", "ABA01", STR0003 ) //Cálculo do IRPJ das Empresas Imunes e Isentas
oView:CreateHorizontalBox( "AGRIDCFIA", 100,,, "FOLDER2", "ABA01" )
oView:SetOwnerView( "VIEW_CFIa", "AGRIDCFIA" )

oView:AddSheet( "FOLDER2", "ABA02", STR0004 ) //Cálculo da CSLL das Empresas Imunes e Isentas
oView:CreateHorizontalBox( "AGRIDCFIB", 100,,, "FOLDER2", "ABA02" )
oView:SetOwnerView( "VIEW_CFIb", "AGRIDCFIB" )

/* 
	Layout 5 do ECF incluiu dois campos para o Bloco U100 - Balanço Patrimonial:
	VAL_CTA_REF_DEB ( CEZ_VLRTD - Total débitos ) e VAL_CTA_REF_CRED ( CEZ_VLRTC - Total Créditos )  
	No layout da ECF os campos citatos acima campos são apresentados antes dos campos abaixo
*/
oStruCEZ:SetProperty( "CEZ_SALFIN", MVC_VIEW_ORDEM, "13" )
oStruCEZ:SetProperty( "CEZ_INDFIN", MVC_VIEW_ORDEM, "14" )

oStruCEY:RemoveField( "CEY_ID" )
oStruCEY:RemoveField( "CEY_IDPERA" )
oStruCEZ:RemoveField( "CEZ_IDCODC" )
oStruCHG:RemoveField( "CHG_IDCODC" )
oStruCFIa:RemoveField( "CFI_REGECF" )
oStruCFIa:RemoveField( "CFI_IDCODC" )
oStruCFIb:RemoveField( "CFI_REGECF" )
oStruCFIb:RemoveField( "CFI_IDCODC" )

If TAFColumnPos( "CFI_ORIGEM" )
	oStruCFIa:RemoveField( "CFI_ORIGEM" )
	oStruCFIb:RemoveField( "CFI_ORIGEM" )
EndIf

Return( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@Param  oModel -> Modelo de dados

@Return .T.

@Author Paulo Sérgio Santana
@Since 24/09/2013
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )
Local 	nOperation 	:= 	oModel:GetOperation()  
Begin Transaction

	If nOperation == MODEL_OPERATION_UPDATE
		TAFAltStat( 'CEY', " " ) //Limpa o Status do Registro, tornando possível nova validação.   		
	Endif
	FwFormCommit( oModel )
	
End Transaction

Return ( .T. )
                  
//-------------------------------------------------------------------
/*/ {Protheus.doc} Taf324Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacos 

@Param
cAlias -> Alias da Tabela
nRecno -> Recno do Registro corrente
nOpc   -> Operacao a ser realizada
lJob   -> Job / Aplicacao

@return ( T. )

@author Paulo Santana
@since 14/05/2014
@version 1.0
/*/                                                                                                                                          

//-------------------------------------------------------------------
Function Taf324Vld( cAlias, nRecno, nOpc, lJob )

Local cChave   := ""
Local aLogErro := {}
Local cIdTpCnt := ""
Local cTipCont := ""
Local cPerApur := ""
Local nSALINIA := 0
Local nSALINIP := 0
Local nSALFINA := 0
Local nSALFINP := 0

Default lJob := .F.

If !CEY->CEY_STATUS $ ( " |1" )
	AADD(aLogErro,{ "CEY_ID", "000017", "CEY", nRecno }) //Registro já validado
Else
	
	//Valida a data de saldo inicial
	If Empty(CEY->CEY_DTINI)
		Aadd( aLogErro, {"CEY_DTINI", "000003", "CEY", nRecno}) //STR0003 - Data inconsistente ou vazia.	
	EndIf
	
	//Valida a data de saldo final
	If Empty(CEY->CEY_DTFIN)
		Aadd( aLogErro, {"CEY_DTFIN", "000003", "CEY", nRecno}) //STR0003 - Data inconsistente ou vazia.
	EndIf  
		
	//Valida o Periodo de apuração
	If Empty(CEY->CEY_IDPERA)
		Aadd( aLogErro, {"CEY_PERAPU", "000001","CEY", nRecno}) //STR0001 - Campo Inconsistente ou Vazio
    Else 
    	//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := CEY->CEY_IDPERA
		xVldECFTab("CAH",cChave,1,,@aLogErro,{"CEY","CEY_PERAPU",nRecno })
	EndIf
		
	//Valida as Datas de Inicio e Final
	If ! Empty(CEY->CEY_DTINI) .And. ! Empty(CEY->CEY_DTFIN)
		If CEY->CEY_DTFIN < CEY->CEY_DTINI 
			Aadd( aLogErro, {"CEY_DTFIN", "000032", "CEY", nRecno}) //STR0032 - A data de saldo final dever ser maior ou igual a data de saldo inicial.
		EndIf
	EndIf
	
	//VALIDA_PERIODO
	xVldECFReg( cAlias,"VALIDA_PERIODO_TRIMESTRAL", @aLogErro,{CEY->CEY_DTINI,CEY->CEY_DTFIN,CEY->CEY_IDPERA,,.T.})
	
	cPerApur:= Alltrim(Posicione("CAH",1,xFilial("CAH")+CEY->CEY_IDPERA,"CAH_CODIGO"))
		
	//------------------------------------------//
	//* Valida a Grid Balanço Patrimonial       *//
	//------------------------------------------//
	dbSelectArea("CEZ")
	CEZ->(dbSetORder(1))
	If CEZ->(MsSeek(xFilial("CEZ") + CEY->CEY_ID))
		cId:=CEZ->CEZ_ID
		While (!CEZ->(Eof()) .And. cId==CEZ->CEZ_ID)
			
			//Valida a Tabela Registro ECF           
			If Empty(CEZ->CEZ_TABECF)
	   			Aadd( aLogErro, {"CEZ_TABECF", "000001", "CEY", nRecno}) //STR0001 - Campo Inconsistente ou Vazio
			Else
				If !(CEZ->CEZ_TABECF $ ("1|2|3|4|5"))
					AADD(aLogErro,{"CEZ_TABECF","000002","CEY", nRecno}) //STR0002 - "Conteúdo do campo não condiz com as opções possíveis" 
				EndIf	
				
			EndIf 
			
			//Valida o Código da Conta
   			If Empty(CEZ->CEZ_IDCODC)
	   			Aadd( aLogErro, {"CEZ_CODCTA", "000001", "CEY", nRecno}) //STR0001 - Campo Inconsistente ou Vazio
			Else
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := CEZ->CEZ_IDCODC 
				xVldECFTab("CHA",cChave,1,,@aLogErro,{ "CEY","CEZ_CODCTA", nRecno})
			EndIf  
			
			//Valida o Saldo Inicial            
			If Empty(CEZ->CEZ_SALINI)
	   			Aadd( aLogErro, {"CEZ_SALINI", "000001", "CEY", nRecno}) //STR0001 - Campo Inconsistente ou Vazio
			EndIf  
			
			//Valida o Ind. Saldo Inicial       
			If Empty(CEZ->CEZ_INDINI)
	   			Aadd( aLogErro, {"CEZ_INDINI", "000001", "CEY", nRecno}) //STR0001 - Campo Inconsistente ou Vazio
			Else
				If !(CEZ->CEZ_INDINI $ ("1|2"))
					AADD(aLogErro,{"CEZ_INDINI","000002","CEY", nRecno}) //STR0002 - "Conteúdo do campo não condiz com as opções possíveis" 
				EndIf	
				
			EndIf 
			
			//Valida o Saldo Final              
			If Empty(CEZ->CEZ_SALFIN)
	   			Aadd( aLogErro, {"CEZ_SALFIN", "000001", "CEY", nRecno}) //STR0001 - Campo Inconsistente ou Vazio
			EndIf  
			
			//Valida o Ind. Saldo Final         
			If Empty(CEZ->CEZ_INDFIN)
	   			Aadd( aLogErro, {"CEZ_INDFIN", "000001", "CEY", nRecno}) //STR0001 - Campo Inconsistente ou Vazio 
	   		Else
	   			If !(CEZ->CEZ_INDFIN $ ("1|2"))
					AADD(aLogErro,{"CEZ_INDFIN","000002","CEY", nRecno}) //STR0002 - "Conteúdo do campo não condiz com as opções possíveis" 
				EndIf		
			EndIf
			
			cIdTpCnt := Posicione("CHA",1,xFilial("CHA")+CEZ->CEZ_IDCODC	,"CHA_CODNAT") 
			cTipCont := Posicione("C2R",3,xFilial("C2R")+cIdTpCnt		 	,"C2R_CODIGO") 

			//Somatório do valor do saldo inicial	
			//Se situação do saldo final for devedor, subtrai. Senão, soma.			
			If cTipCont=='01'
				If CEZ->CEZ_INDINI == '1'
					nSALINIA -= CEZ->CEZ_SALINI
				Else
					nSALINIA += CEZ->CEZ_SALINI
				EndIf
			ElseIf cTipCont=='02'
				If CEZ->CEZ_INDINI == '1'
					nSALINIP -= CEZ->CEZ_SALINI
				Else
					nSALINIP += CEZ->CEZ_SALINI
				EndIf
			EndIf		
		
			//Somatório do valor do saldo final	
			//Se situação do saldo final for devedor, subtrai. Senão, soma.			
			If cTipCont=='01'
				If CEZ->CEZ_INDFIN == '1'
					nSALFINA -= CEZ->CEZ_SALFIN
				Else
					nSALFINA += CEZ->CEZ_SALFIN
				EndIf
			ElseIf cTipCont=='02'
				If CEZ->CEZ_INDFIN == '1'
					nSALFINP -= CEZ->CEZ_SALFIN
				Else
					nSALFINP += CEZ->CEZ_SALFIN
				EndIf
			EndIf
			
			CEZ->(dbSkip())
			
		Enddo
		
	Endif
	
	//----------------------------------------------//                                                                            
	//* Valida a Grid Registros Genéricos - Bloco U *//
	//----------------------------------------------//
	dbSelectArea("CFI")
	CFI->(dbSetORder(1))
	If CFI->(MsSeek(xFilial("CFI") + CEY->CEY_ID))
		cId:=CFI->CFI_ID
		While (!CFI->(Eof()) .And. cId==CFI->CFI_ID)
			
			//Valida o Código          
			If Empty(CFI->CFI_IDCODC)
	   			Aadd( aLogErro, {"CFI_CODIGO", "000001", "CEY", nRecno}) //STR0001 - Campo Inconsistente ou Vazio
			Else
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := CFI->CFI_IDCODC
				xVldECFTab("CH6",cChave,1,,@aLogErro,{ "CEY","CFI_CODIGO", nRecno})
			EndIf  
			
			CFI->(dbSkip())
			
		Enddo
		
	Endif
	
	dbSelectArea("CHG")
	CHG->(dbSetORder(1))
	If CHG->(MsSeek(xFilial("CHG") + CHG->CHG_ID))
		cId:=CHG->CHG_ID
		While (!CHG->(Eof()) .And. cId==CHG->CHG_ID)
			
			//Valida o Código          
			If Empty(CHG->CHG_IDCODC)
	   			Aadd( aLogErro, {"CHG_CODIGO", "000001", "CEY", nRecno}) //STR0001 - Campo Inconsistente ou Vazio
			Else
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := CHG->CHG_IDCODC
				xVldECFTab("CHA",cChave,1,,@aLogErro,{ "CEY","CHG_CODIGO", nRecno})
			EndIf  
			
			CHG->(dbSkip())
			
		Enddo
		
	Endif
	
	//REGRA_BALANCO_SALDO_FINAL
	If ( nSALFINA + nSALFINP ) <> 0
		If  cPerAPur == "T04"
			AADD(aLogErro,{"CEZ_SALFIN","000162","CEY",nRecno}) //STR0161 - "Saldo do Ativo deve ser Igual ao Passivo (soma dos campos 'Saldo Ini' e 'Saldo Fin' devem ser iguais de acordo com a natureza) para o periodo T01"
		EndIf
	EndIf		
	
	//REGRA_BALANCO_SALDO_INICIAL
	If ( nSALINIA + nSALINIP ) <> 0
		If cPerAPur == "T01"
			AADD(aLogErro,{"CEZ_SALINI","000161","CEY",nRecno}) //STR0162 - "Saldo do Ativo deve ser Igual ao Passivo (soma dos campos 'Saldo Ini' e 'Saldo Fin' devem ser iguais de acordo com a natureza) para o periodo T04"
		EndIf
	EndIf	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ATUALIZO O STATUS DO REGISTRO³
	//³1 = Registro Invalido        ³
	//³0 = Registro Valido          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len( aLogErro ) > 0
		RecLock( "CEY", .F. )
		CEY->CEY_STATUS := "1"
		MsUnlock()
	Else
		RecLock( "CEY", .F. )
		CEY->CEY_STATUS := "0"
		MsUnlock()
	EndIf
	
EndIf

	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Não apresento o alert quando utilizo o JOB para validar³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lJob
	VldECFLog( aLogErro )
EndIf	

Return(aLogErro)