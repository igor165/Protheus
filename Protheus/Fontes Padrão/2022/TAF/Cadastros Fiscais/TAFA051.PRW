#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA051.CH"
static lCallMenu	:=  .T. //Iif(Alltrim(FunDesc()) $ "Tabela de Processo|Tabla de Proceso|Process Table", .T., .F. ) // Verifica se foi chamado pelo menu do esocial
static lReinf		:=  .F. // Verifica se foi escolhida a visualização para Reinf

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA051
Cadastro MVC - T001AB, Processos Referenciados

@author Mauro A. Goncalves
@since 18/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA051()

Local  cTitulo	:= ""
Local  oBrw		:=	FWmBrowse():New()
Local  nRetorno	:= 0

//#STR0018 "1 - eSocial"    
//#STR0019 "2 - FIscal" 
//#STR0020 "Qual tabela de processos deseja acessar?"  
//#STR0021 "Ao clicar na opção '1 - eSocial', apenas estarão disponíveis os processos referentes ao eSocial e ao clicar na opção '2 - Fiscal', apenas estarão disponíveis processos referentes ao fiscal."
nRetorno := Aviso(STR0020,STR0023+STR0024,{STR0018,STR0019,STR0022},3) 

If nRetorno == 1
	cTitulo := " " + STR0018
	lCallMenu := .T.
ElseIf nRetorno == 3
	cTitulo := " " + STR0022
	lReinf := .T.
	lCallMenu := .F.
Else
	cTitulo := " " + STR0019
	lReinf := .F.
	lCallMenu := .F.
EndIf

 If lCallMenu .AND. TAFAlsInDic("T5L")

	oBrw:SetDescription( STR0001 + cTitulo) //Tabela de processos	
	oBrw:SetAlias( 'C1G')
	oBrw:SetMenuDef( 'TAFA051' )
	oBrw:SetFilterDefault( "C1G_ATIVO == '1' .AND. C1G_ESOCIA == '1' .Or. (C1G_EVENTO == 'E' .And. C1G_STATUS = '4' .And. C1G_ATIVO = '2' .And. C1G_ESOCIA == '1')" ) //Filtro para que apenas os registros ativos sejam exibidos ( 1=Ativo, 2=Inativo )
	oBrw:SetOnlyFields( { 'C1G_ID', 'C1G_NUMPRO','C1G_TPPROC','C1G_DTINI'} )
	
	oBrw:AddLegend( "C1G_EVENTO == 'I' ", "GREEN" , STR0006 ) //"Registro Incluído"
	oBrw:AddLegend( "C1G_EVENTO == 'A' ", "YELLOW", STR0007 ) //"Registro Alterado"
	oBrw:AddLegend( "C1G_EVENTO == 'E' .And. C1G_STATUS <> '4' ", "RED"   , STR0008 ) //"Registro excluído não transmitido"
	oBrw:AddLegend( "C1G_EVENTO == 'E' .And. C1G_STATUS == '4' .And. C1G_ATIVO = '2' ", "BLACK"   , STR0025 ) //"Registro excluído transmitido"
	
	oBrw:Activate()
	
Else
	
	//Entrando pelo menu do ECF
	oBrw:SetDescription( STR0001 + cTitulo ) //Tabela de processos	
	oBrw:SetAlias('C1G')
	oBrw:SetMenuDef( 'TAFA051' )
	oBrw:SetFilterDefault( "C1G_ESOCIA == ' '")  //Ajuste 29/03/2017
	oBrw:Activate()	
EndIf

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu
@author Denis R de Oliveira
@since 17/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {}
Local aRotina := {}

If lCallMenu
	If FindFunction('TafXmlRet')
		Aadd( aFuncao, { "" , "TafxmlRet('TAF051Xml','1070','C1G')" , "1" } )
	Else
		Aadd( aFuncao, { "" , "TAF051Xml" , "1" } )
	EndIf
	Aadd( aFuncao, { "" , "xFunHisAlt( 'C1G', 'TAFA051',,,,'TAF051XML','1070' )" , "3" } )
	aAdd( aFuncao, { "" , "TAFXmlLote( 'C1G', 'S-1070' , 'evtTabProcesso' , 'TAF051Xml' )" , "5" } )
	Aadd( aFuncao, { "" , "xFunAltRec( 'C1G' )" , "10" } )

	lMenuDIf := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDIf )
	
	If lMenuDif
		ADD OPTION aRotina Title STR0009 Action 'VIEWDEF.TAFA051' OPERATION 2 ACCESS 0 //"Visualizar"
	Else
		aRotina	:=	xFunMnuTAF( "TAFA051" , , aFuncao,,,,,lCallMenu)
	EndIf
Else
	Aadd( aFuncao, { "" , "Taf051Vld" , "2" } )
	aRotina	:=	xFunMnuTAF( "TAFA051" , , aFuncao,,,,,lCallMenu )
EndIf


Return( aRotina )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Mauro A. Goncalves
@since 18/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC1G 	  := FWFormStruct( 1, 'C1G' )
Local oStruT5L    := Nil
Local oModel 	  := MPFormModel():New( 'TAFA051' , , , {|oModel| SaveModel( oModel ) } )
Local lGrv	      := .F.
Local lEsocial    := .F. //Variavel para verificar se view foi chamada por alguma consulta padrão do esocial
Local nCnt		  := 1
Local aEvtEsocial := {}

//Verifica se quem chamou foi o TAFAINTEG
// -> Incluido validação da função JURA162 pois, em testes de integração online com o produto
// jurídico identificamos que a função isInCallStack() não está "encontrando" todas as funções
// da pilha de chamada, retorna .T. somente para a função de origem do processo.
If isInCallStack("TAFAINTEG") .or. isInCallStack("JURA162") .Or. IsInCallStack("TAFPREPINT")
	lGrv := .T.
EndIf

If isInCallStack("TAFTICKET")
	lEsocial := .T.
Else
	//Verifica se alguma consulta padrão de dentro de algum evento do eSocial esta usando o Model
	aEvtEsocial := TAFRotinas(,,.T.,2)
	While nCnt <= Len(aEvtEsocial) .AND. lEsocial <> .T.
		If isInCallStack(aEvtEsocial[nCnt][1]) .AND. aEvtEsocial[nCnt][1] <> "TAFA051"
			lEsocial := .T.
		EndIf
		nCnt++
	EndDo
EndIf

oStruT5L :=  FWFormStruct( 1, 'T5L' )
oStruT5L:SetProperty("T5L_INDDEC" ,MODEL_FIELD_OBRIGAT,.F.)
oStruT5L:SetProperty("T5L_INDDEP" ,MODEL_FIELD_OBRIGAT,.F.)
oStruT5L:SetProperty("T5L_DTDEC"  ,MODEL_FIELD_OBRIGAT,.F.)
If (lCallMenu .OR. lGrv .OR. lEsocial) .AND. TAFAlsInDic("T5L")
	oModel:AddFields('MODEL_C1G', /*cOwner*/, oStruC1G)
	oModel:AddGrid("MODEL_T5L","MODEL_C1G",oStruT5L)
	oModel:GetModel("MODEL_T5L"):SetOptional(.T.)
	oModel:GetModel("MODEL_T5L"):SetUniqueLine({"T5L_CODSUS"})	
	
	oModel:SetRelation("MODEL_T5L",{ {"T5L_FILIAL","xFilial('T5L')"}, {"T5L_ID","C1G_ID"}, {"T5L_VERSAO","C1G_VERSAO"} },T5L->(IndexKey(1)) )
	
	oModel:GetModel('MODEL_C1G'):SetPrimaryKey({'C1G_FILIAL', 'C1G_ID', 'C1G_VERSAO'})	

ElseIf lReinf

	oModel:AddFields('MODEL_C1G', /*cOwner*/, oStruC1G)
	oModel:AddGrid("MODEL_T5L","MODEL_C1G",oStruT5L)
	oModel:GetModel("MODEL_T5L"):SetOptional(.T.)
	oModel:GetModel("MODEL_T5L"):SetUniqueLine({"T5L_CODSUS"})	
	
	oModel:SetRelation("MODEL_T5L",{ {"T5L_FILIAL","xFilial('T5L')"}, {"T5L_ID","C1G_ID"}, {"T5L_VERSAO","C1G_VERSAO"} },T5L->(IndexKey(1)) )
	
	oModel:GetModel('MODEL_C1G'):SetPrimaryKey({'C1G_FILIAL', 'C1G_ID', 'C1G_VERSAO'})	
Else
	oModel:AddFields('MODEL_C1G', /*cOwner*/, oStruC1G)
	oModel:GetModel( 'MODEL_C1G' ):SetPrimaryKey( { "C1G_NUMPRO", "C1G_INDPRO" } )
EndIf

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Mauro A. Goncalves
@since 18/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA051' )
Local 	oStruC1G 	:= 	FWFormStruct( 2, 'C1G' )
Local 	oStruC1Gb	:=	Nil
Local 	oStruT5L  	:=	Nil 
Local 	oView 		:=	FWFormView():New()
Local   lEsocial    := .F. //Variavel para verificar se view foi chamada por alguma consulta padrão do esocial
Local 	nCnt		:= 1
Local   aEvtEsocial := {}
Local   nTam		:= 100

oView:SetModel( oModel )

// Campos do folder
cCmpFil   := "C1G_ID|C1G_NUMPRO|C1G_TPPROC|C1G_VARA|"

If isInCallStack("TAFTICKET")
	lEsocial := .T.
Else
	aEvtEsocial := TAFRotinas(,,.T.,2)
	While nCnt <= Len(aEvtEsocial) .AND. lEsocial <> .T.
		If isInCallStack(aEvtEsocial[nCnt][1]) .AND. aEvtEsocial[nCnt][1] <> "TAFA051"
			lEsocial := .T.
			Exit
		EndIf
		nCnt++
	EndDo
EndIf

If lCallMenu .OR. lEsocial .Or. lReinf
	oStruT5L := FWFormStruct( 2, 'T5L' )
EndIf

If lCallMenu .OR. lEsocial
	cCmpFil	+= "C1G_UFVARA|C1G_DUFVAR|C1G_CODMUN|C1G_DCODMU|C1G_DTINI|C1G_DTFIN|"
	cCmpFil   	+= "C1G_INDAUT|C1G_INDMAT|C1G_DIMATE|"
	If TafLayESoc("02_04_02")
		cCmpFil+= "C1G_OBS|"
	EndIf
ElseIf lReinf
	cCmpFil	+= "C1G_INDAUT|C1G_UFVARA|C1G_DUFVAR|C1G_CODMUN|C1G_DCODMU|C1G_DTINI|C1G_DTFIN|"
	cCmpFil	+= "C1G_INDPRO|C1G_DESCRI|C1G_SECJUD|C1G_ACAJUD|C1G_DACJUD|C1G_DECJUD|C1G_DTSENT|"
	cCmpFil   	+= "C1G_INRCFE|C1G_DINRCF|C1G_DTADM|C1G_EPROCC|"
Else
	cCmpFil	+= "C1G_INDPRO|C1G_DESCRI|C1G_SECJUD|C1G_ACAJUD|C1G_DACJUD|C1G_DECJUD|C1G_DTSENT|"
	cCmpFil   	+= "C1G_INRCFE|C1G_DINRCF|C1G_DTADM|C1G_EPROCC|"
EndIf

oStruC1G  := FwFormStruct(2,"C1G",{|x| AllTrim(x) + "|" $ cCmpFil } ) //Campos do folder Informacoes 

If lCallMenu .OR. lEsocial
	// Campos do folder do número do ultimo protocolo
	cCmpFil   := 'C1G_PROTUL|'
	oStruC1Gb := FwFormStruct( 2, 'C1G', {|x| AllTrim( x ) + "|" $ cCmpFil } )

	If FindFunction("TafAjustRecibo")
		TafAjustRecibo(oStruC1Gb,"C1G")
	EndIf

	oView:AddField( 'VIEW_C1Gb' , oStruC1Gb, 'MODEL_C1G' )
	If FindFunction("TafNmFolder")
		oView:EnableTitleView( 'VIEW_C1Gb', TafNmFolder("recibo",1) ) // "Recibo da última Transmissão"  
	EndIf
	
	nTam := 60
	
	oStruC1G:SetProperty("C1G_DTINI" 	,MVC_VIEW_ORDEM ,"03")
	oStruC1G:SetProperty("C1G_DTFIN" 	,MVC_VIEW_ORDEM ,"04")
	oStruC1G:SetProperty("C1G_NUMPRO" 	,MVC_VIEW_ORDEM ,"05")
	oStruC1G:SetProperty("C1G_TPPROC" 	,MVC_VIEW_ORDEM ,"06")
	oStruC1G:SetProperty("C1G_VARA" 	,MVC_VIEW_ORDEM ,"07")
	oStruC1G:SetProperty("C1G_UFVARA" 	,MVC_VIEW_ORDEM ,"08")
	oStruC1G:SetProperty("C1G_DUFVAR" 	,MVC_VIEW_ORDEM ,"09")
	oStruC1G:SetProperty("C1G_CODMUN" 	,MVC_VIEW_ORDEM ,"10")
	oStruC1G:SetProperty("C1G_DCODMU" 	,MVC_VIEW_ORDEM ,"11")
	oStruC1G:SetProperty("C1G_INDAUT" 	,MVC_VIEW_ORDEM ,"12")
ElseIf lReinf
	nTam := 60

	oStruC1G:SetProperty("C1G_NUMPRO" 	,MVC_VIEW_ORDEM ,"03")
	oStruC1G:SetProperty("C1G_DTINI" 	,MVC_VIEW_ORDEM ,"04")
	oStruC1G:SetProperty("C1G_DTFIN" 	,MVC_VIEW_ORDEM ,"05")
	oStruC1G:SetProperty("C1G_TPPROC" 	,MVC_VIEW_ORDEM ,"06")
	oStruC1G:SetProperty("C1G_INDPRO" 	,MVC_VIEW_ORDEM ,"08")	
	oStruC1G:SetProperty("C1G_DESCRI" 	,MVC_VIEW_ORDEM ,"09")
	oStruC1G:SetProperty("C1G_VARA" 	,MVC_VIEW_ORDEM ,"10")
	oStruC1G:SetProperty("C1G_SECJUD" 	,MVC_VIEW_ORDEM ,"11")
	oStruC1G:SetProperty("C1G_UFVARA" 	,MVC_VIEW_ORDEM ,"12")
	oStruC1G:SetProperty("C1G_DUFVAR" 	,MVC_VIEW_ORDEM ,"13")
	oStruC1G:SetProperty("C1G_CODMUN" 	,MVC_VIEW_ORDEM ,"14")
	oStruC1G:SetProperty("C1G_DCODMU" 	,MVC_VIEW_ORDEM ,"15")
	oStruC1G:SetProperty("C1G_ACAJUD" 	,MVC_VIEW_ORDEM ,"16")
	oStruC1G:SetProperty("C1G_DACJUD" 	,MVC_VIEW_ORDEM ,"17")
	oStruC1G:SetProperty("C1G_DECJUD" 	,MVC_VIEW_ORDEM ,"18")
	oStruC1G:SetProperty("C1G_INRCFE" 	,MVC_VIEW_ORDEM ,"19")
	oStruC1G:SetProperty("C1G_DINRCF" 	,MVC_VIEW_ORDEM ,"20")
	oStruC1G:SetProperty("C1G_DTSENT" 	,MVC_VIEW_ORDEM ,"21")
	oStruC1G:SetProperty("C1G_INDAUT" 	,MVC_VIEW_ORDEM ,"22")
	oStruC1G:SetProperty("C1G_DTADM" 	,MVC_VIEW_ORDEM ,"23")
	oStruC1G:SetProperty("C1G_EPROCC" 	,MVC_VIEW_ORDEM ,"24")
EndIf

oView:AddField( 'VIEW_C1G'  , oStruC1G,  'MODEL_C1G' )

oView:CreateHorizontalBox( 'PAINEL', nTam ) 

oView:CreateFolder( 'FOLDER_SUPERIOR', 'PAINEL' )
oView:AddSheet( "FOLDER_SUPERIOR", "ABA01", STR0001 ) //"Processos Referenciados
oView:CreateHorizontalBox( 'PAINEL_01', 100,,, 'FOLDER_SUPERIOR', 'ABA01' )

If lCallMenu .OR. lEsocial
	
	oView:AddGrid("VIEW_T5L",oStruT5L,"MODEL_T5L")
	oView:EnableTitleView("VIEW_T5L",STR0014) //"Horários de Intervalo"
	oView:CreateHorizontalBox("T5L",40)
	
	If FindFunction("TafNmFolder")
		oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA02', TafNmFolder("recibo") )   //"Numero do Recibo"
	Else
		oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA02', STR0012 )//"Protocolo de Ultima Transmissão
	EndIf 
	
	oView:CreateHorizontalBox( 'PAINEL_02', 100,,, 'FOLDER_SUPERIOR', 'ABA02' )

	oView:SetOwnerView( 'VIEW_C1Gb' , 'PAINEL_02')	
	oView:SetOwnerView( 'VIEW_C1G'  , 'PAINEL_01')
	oView:SetOwnerView( 'VIEW_T5L'  , 'T5L')

ElseIf lReinf
	oView:AddGrid("VIEW_T5L",oStruT5L,"MODEL_T5L")
	oView:EnableTitleView("VIEW_T5L",STR0014) //"Horários de Intervalo"
	oView:CreateHorizontalBox("T5L",40)
	
//	oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA02', STR0012 )//"Protocolo de Ultima Transmissão
//	oView:CreateHorizontalBox( 'PAINEL_02', 100,,, 'FOLDER_SUPERIOR', 'ABA02' )
	
//	oView:SetOwnerView( 'VIEW_C1Gb' , 'PAINEL_02')	
	oView:SetOwnerView( 'VIEW_C1G'  , 'PAINEL_01')
	oView:SetOwnerView( 'VIEW_T5L'  , 'T5L')

Else
	oView:SetOwnerView( 'VIEW_C1G'  , 'PAINEL_01')
EndIf

///Tratamento para que alguns campos de controle interno não sejam exibidos na tela
lMenuDIf := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDIf )

If !lMenuDif
	xFunRmFStr(@oStruC1G, 'C1G')
EndIf

If TafColumnPos( "C1G_LOGOPE" )
	oStruC1G:RemoveField( "C1G_LOGOPE")
EndIf

Return oView 

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Denis R. de Oliveira
@since 17/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel(oModel)

Local cLogOpe		as character
Local cLogOpeAnt	as character

Local cVerAnt    	:= ""  
Local cProtocolo 	:= ""
Local cVersao    	:= ""
Local cEvento	 	:= ""  
Local cChvRegAnt 	:= ""
Local nOperation 	:= oModel:GetOperation()
Local nlI, nlY   	:= 0  
Local nT5L	     	:= 0
Local nCnt		 	:= 1 
Local aGrava     	:= {}
Local aGravaT5L 	:= {}
Local oModelC1G  	:= Nil
Local oModelT5L		:= Nil
Local lRetorno   	:= .T.
Local lEsocial   	:= .F. //Variavel para verificar se view foi chamada por alguma consulta padrão do esocial
Local aEvtEsocial	:= {}

cLogOpe    := ""
cLogOpeAnt := ""

If isInCallStack("TAFTICKET")
	lEsocial := .T.
Else
	aEvtEsocial := TAFRotinas(,,.T.,2)
	While nCnt <= Len(aEvtEsocial) .AND. lEsocial <> .T.
		If isInCallStack(aEvtEsocial[nCnt][1]) .AND. aEvtEsocial[nCnt][1] <> "TAFA051"
			lEsocial := .T.
			Exit
		EndIf
		nCnt++
	EndDo
EndIf

Begin Transaction 
	
	If nOperation == MODEL_OPERATION_INSERT

	TafAjustID( "C1G", oModel)

		oModel:LoadValue( 'MODEL_C1G', 'C1G_VERSAO', xFunGetVer() )

		If Findfunction("TAFAltMan")
			TAFAltMan( 3 , 'Save' , oModel, 'MODEL_C1G', 'C1G_LOGOPE' , '2', '' )
		endif

		If lCallMenu .OR. lEsocial
			oModel:LoadValue( 'MODEL_C1G', 'C1G_ESOCIA', '1' ) 
		EndIf
		FwFormCommit( oModel )  
		
	ElseIf nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_DELETE 

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Seek para posicionar no registro antes de realizar as validacoes,³
		//³visto que quando nao esta pocisionado nao eh possivel analisar   ³
		//³os campos nao usados como _STATUS                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    C1G->( DbSetOrder( 8 ) )
	    If C1G->( MsSeek( xFilial( 'C1G' ) + C1G_ID + '1' ) )
	    	    	    
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se o registro ja foi transmitido³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    If C1G->C1G_STATUS == "4" .And. C1G_LOGOPE <> "A"
				
				If nOperation == MODEL_OPERATION_DELETE 
					oModel:DeActivate()
					oModel:SetOperation( 4 ) 	
					oModel:Activate()
		     	EndIf
		        
				oModelC1G := oModel:GetModel( 'MODEL_C1G' ) 
				oModelT5L := oModel:GetModel( "MODEL_T5L" )    
										
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Busco a versao anterior do registro para gravacao do rastro³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cVerAnt    := oModelC1G:GetValue( "C1G_VERSAO" )				
				cProtocolo := oModelC1G:GetValue( "C1G_PROTUL" )				
				cEvento    := oModelC1G:GetValue( "C1G_EVENTO" )

				If TafColumnPos( "C1G_LOGOPE" )
					cLogOpeAnt := oModelC1G:GetValue( "C1G_LOGOPE" )
				endif

				If nOperation == MODEL_OPERATION_DELETE .And. cEvento == "E" 
					// Não é possível excluir um evento de exclusão já transmitido
					TAFMsgVldOp(oModel,"4")
					lRetorno := .F.
				Else		
				
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Neste momento eu gravo as informacoes que foram carregadas       ³
					//³na tela, pois neste momento o usuario ja fez as modificacoes que ³
					//³precisava e as mesmas estao armazenadas em memoria, ou seja,     ³
					//³nao devem ser consideradas neste momento                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nlI := 1 To 1
						For nlY := 1 To Len( oModelC1G:aDataModel[ nlI ] )			
							Aadd( aGrava, { oModelC1G:aDataModel[ nlI, nlY, 1 ], oModelC1G:aDataModel[ nlI, nlY, 2 ] } )
						Next
					Next
					
					If !oModel:GetModel( 'MODEL_T5L' ):IsEmpty()
						For nT5L := 1 To oModel:GetModel( 'MODEL_T5L' ):Length()
							oModel:GetModel( 'MODEL_T5L' ):GoLine(nT5L)
							If !oModel:GetModel( 'MODEL_T5L' ):IsDeleted()
								aAdd (aGravaT5L ,{oModelT5L:GetValue('T5L_INDDEC');
												, oModelT5L:GetValue('T5L_DTDEC');
												, oModelT5L:GetValue('T5L_INDDEP');
												, oModelT5L:GetValue('T5L_CODSUS')} )
							EndIf
						Next nT5L
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Seto o campo como Inativo e gravo a versao do novo registro³
					//³no registro anterior                                       ³
					//|                                                           |
					//|ATENCAO -> A alteracao destes campos deve sempre estar     |
					//|abaixo do Loop do For, pois devem substituir as informacoes|
					//|que foram armazenadas no Loop acima                        |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					FAltRegAnt( 'C1G', '2', .F. )      						
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Neste momento eu gravo as informacoes que foram carregadas       ³
					//³na tela, pois neste momento o usuario ja fez as modificacoes que ³
					//³precisava e as mesmas estao armazenadas em memoria, ou seja,     ³
					//³nao devem ser consideradas neste momento                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
					For nlI := 1 To Len( aGrava )	
						oModel:LoadValue( 'MODEL_C1G', aGrava[ nlI, 1 ], C1G->&( aGrava[ nlI, 1 ] ) )
					Next                 
					       				
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Neste momento eu preciso setar a operacao do model³
					//³como Inclusao                                     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					oModel:DeActivate()
					oModel:SetOperation( 3 ) 	
					oModel:Activate()		
									
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Neste momento eu realizo a inclusao do novo registro ja³
					//³contemplando as informacoes alteradas pelo usuario     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nlI := 1 To Len( aGrava )	
						oModel:LoadValue( 'MODEL_C1G', aGrava[ nlI, 1 ], aGrava[ nlI, 2 ] )
					Next

					//Necessário Abaixo do For Nao Retirar
					If Findfunction("TAFAltMan")
						TAFAltMan( 4 , 'Save' , oModel, 'MODEL_C1G', 'C1G_LOGOPE' , '' , cLogOpeAnt )
					endif

					For nT5L := 1 To Len( aGravaT5L )
						If nT5L > 1
							oModel:GetModel( 'MODEL_T5L' ):AddLine()
						EndIf

						oModel:LoadValue( "MODEL_T5L", "T5L_INDDEC", aGravaT5L[nT5L][1] )
						oModel:LoadValue( "MODEL_T5L", "T5L_DTDEC",  aGravaT5L[nT5L][2] )
						oModel:LoadValue( "MODEL_T5L", "T5L_INDDEP", aGravaT5L[nT5L][3] )
						oModel:LoadValue( "MODEL_T5L", "T5L_CODSUS", aGravaT5L[nT5L][4] )

		        	Next nT5L     
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Busco a versao que sera gravada³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cVersao := xFunGetVer()		 
					                                   
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿		
					//|ATENCAO -> A alteracao destes campos deve sempre estar     |
					//|abaixo do Loop do For, pois devem substituir as informacoes|
					//|que foram armazenadas no Loop acima                        |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		                                                                      				         
					oModel:LoadValue( 'MODEL_C1G', 'C1G_VERSAO', cVersao )  
					oModel:LoadValue( 'MODEL_C1G', 'C1G_VERANT', cVerAnt )									          				    
					oModel:LoadValue( 'MODEL_C1G', 'C1G_PROTPN', cProtocolo )									          						
					oModel:LoadValue( 'MODEL_C1G', 'C1G_PROTUL', "" )
					// Tratamento para limpar o ID unico do xml
					cAliasPai := "C1G"
					If TAFColumnPos( cAliasPai+"_XMLID" )
						oModel:LoadValue( 'MODEL_'+cAliasPai, cAliasPai+'_XMLID', "" )
					EndIf

					If nOperation == MODEL_OPERATION_DELETE 		
						oModel:LoadValue( 'MODEL_C1G', 'C1G_EVENTO', "E" )                                               		                    		
					ElseIf cEvento == "E"
						oModel:LoadValue( 'MODEL_C1G', 'C1G_EVENTO', "I" )
					Else
						oModel:LoadValue( 'MODEL_C1G', 'C1G_EVENTO', "A" )     
					EndIf                                          		                    
					
					If FindFunction("TafEndGRV") .And. TafAlt1070()
						TafEndGRV( "C1G", "C1G_PROCID", "", C1G->(Recno()) )
					EndIf

					FwFormCommit( oModel )
			
				EndIf
			
			Elseif C1G->C1G_STATUS == "2"
				//Não é possível alterar um registro com aguardando validação
				TAFMsgVldOp(oModel,"2")
				lRetorno := .F.
			
			Else         
				cChvRegAnt := C1G->C1G_ID + C1G->C1G_VERANT             

				If TafColumnPos( "C1G_LOGOPE" )
					cLogOpeAnt := C1G->C1G_LOGOPE
				endif

				If C1G->C1G_EVENTO == "E"
					If nOperation == MODEL_OPERATION_DELETE
						If Aviso( xValStrEr("000754"), xValStrEr("000755"), { xValStrEr("000756"), xValStrEr("000757") }, 1 ) == 2 //##"Registro Excluído" ##"O Evento de exclusão não foi transmitido. Deseja realmente exclui-lo ou manter o evento de exclusão para transmissão posterior ?" ##"Excuir" ##"Manter"
							cChvRegAnt := ""
						EndIf		
					Else
	                	oModel:LoadValue( "MODEL_C1G", "C1G_EVENTO", "A" )
	                EndIf			
				EndIf
				
				If !Empty( cChvRegAnt )
					TAFAltStat( 'C1G', " " )
					
					If nOperation == MODEL_OPERATION_UPDATE .And. Findfunction("TAFAltMan")
						TAFAltMan( 4 , 'Save' , oModel, 'MODEL_C1G', 'C1G_LOGOPE' , '' , cLogOpeAnt )
					EndIf

					If FindFunction("TafEndGRV") .And. TafAlt1070()
						TafAtuPrId( "C1G" ) //Apaga T9V de acordo com o procId da C1G
						TafEndGRV( "C1G", "C1G_PROCID", "", C1G->(Recno()) )
					EndIf

					FwFormCommit( oModel )				
					If nOperation == MODEL_OPERATION_DELETE
						If C1G->C1G_EVENTO == "A" .Or. C1G->C1G_EVENTO == "E"
							TAFRastro( 'C1G', 3, cChvRegAnt, .T. )
						EndIf
					EndIf
				EndIf
			EndIf
		
		Elseif TafIndexInDic("C1G", 'B', .T.)

			C1G->( DbSetOrder( 11 ) )
	    	If C1G->( MsSeek( xFilial( 'C1G' ) + FwFldGet('C1G_ID')+ 'E42' ) ) 

				If nOperation == MODEL_OPERATION_DELETE 
					// Não é possível excluir um evento de exclusão já transmitido
					TAFMsgVldOp(oModel,"4")
					lRetorno := .F.
				EndIf				

			EndIF

		EndIf      
	EndIf      
			
End Transaction 

Return( lRetorno )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF051Xml
Funcao de geracao do XML para atender o registro S-1070
Quando a rotina for chamada o registro deve estar posicionado

@Param:

@Return:
cXml - Estrutura do Xml do Layout S-1070
lRemEmp - Exclusivo do Evento S-1000
cSeqXml - Numero sequencial para composição da chave ID do XML

@author Vitor Siqueira
@since 10/06/2016
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF051Xml(cAlias,nRecno,nOpc,lJob,lRemEmp,cSeqXml)

Local cXml       	:= ""
Local cLayout    	:= "1070"
Local cEvento    	:= ""
Local cReg		 	:= "TabProcesso"
Local cDtIni     	:= ""    
Local cDtFin     	:= ""	  
Local cDtIniAtu  	:= "" 
Local cDtFinAtu  	:= ""
Local cId 	     	:= ""
Local cVerAnt	 	:= ""
Local uFVara		:= ""
Local cCodMun		:= ""
Local nRecnoSM0		:= SM0->(Recno())

Default cSeqXml := ""

cDtIniAtu  := Iif(!Empty(C1G->C1G_DTINI),Substr(C1G->C1G_DTINI,3,4) + "-" + Substr(C1G->C1G_DTINI,1,2),"") //Faço o IIf pois se a data estiver vazia a string recebia '  -  -   '
cDtFinAtu  := Iif(!Empty(C1G->C1G_DTFIN),Substr(C1G->C1G_DTFIN,3,4) + "-" + Substr(C1G->C1G_DTFIN,1,2),"")

If C1G->C1G_EVENTO $ "I|A"

	If C1G->C1G_EVENTO == "A"
		cEvento := "alteracao"

		cId := C1G->C1G_ID 
		cVerAnt := C1G->C1G_VERANT
		
		BeginSql alias 'C1GTEMP'
			SELECT C1G.C1G_DTINI,C1G.C1G_DTFIN
			FROM %table:C1G% C1G
			WHERE C1G.C1G_FILIAL= %xfilial:C1G% AND
			C1G.C1G_ID = %exp:cId% AND C1G.C1G_VERSAO = %exp:cVerAnt% AND 
			C1G.%notDel%
		EndSql  
		cDtIni := Iif(!Empty(('C1GTEMP')->C1G_DTINI),Substr(('C1GTEMP')->C1G_DTINI,3,4) + "-" + Substr(('C1GTEMP')->C1G_DTINI,1,2),"")
		cDtFin := Iif(!Empty(('C1GTEMP')->C1G_DTFIN),Substr(('C1GTEMP')->C1G_DTFIN,3,4) + "-" + Substr(('C1GTEMP')->C1G_DTFIN,1,2),"")

		('C1GTEMP')->( DbCloseArea() )
	Else
		cEvento := "inclusao"
		cDtIni  := Iif(!Empty(C1G->C1G_DTINI),Substr(C1G->C1G_DTINI,3,4) + "-" + Substr(C1G->C1G_DTINI,1,2),"") //Faço o IIf pois se a data estiver vazia a string recebia '  -  -   '
		cDtFin  := Iif(!Empty(C1G->C1G_DTFIN),Substr(C1G->C1G_DTFIN,3,4) + "-" + Substr(C1G->C1G_DTFIN,1,2),"")
	EndIf
	
	cXml +=			"<infoProcesso>"
	cXml +=				"<" + cEvento + ">"
	cXml +=					"<ideProcesso>"
	cXml += 						xTafTag("tpProc"		,Iif(C1G->C1G_TPPROC == "1", "2", Iif(C1G->C1G_TPPROC == "2", "1", C1G->C1G_TPPROC ) ) )
	cXml += 						xTafTag("nrProc"		,C1G->C1G_NUMPRO)
	cXml +=						xTafTag("iniValid"	,cDtIni)
	cXml +=						xTafTag("fimValid"	,cDtFin,,.T.)	
	cXml +=					"</ideProcesso>"
	cXml +=					"<dadosProc>"
	cXml +=						xTafTag("indAutoria",C1G->C1G_INDAUT,,.T.)
	cXml +=						xTafTag("indMatProc",CValToChar( Val(POSICIONE("LE7",3,xFilial("LE7")+C1G->C1G_INDMAT,"LE7_CODIGO"))) )
	If TafLayESoc("02_04_02")
		cXml +=					xTafTag("observacao",C1G->C1G_OBS,,.T.)	
	EndIf
	
	uFVara		:= Posicione("C09",3, xFilial("C09")+C1G->C1G_UFVARA,"C09_UF")
	cCodMun	:= Posicione("C07",3, xFilial("C07")+C1G->C1G_CODMUN,"C07_CODIGO")
	If !Empty(cCodMun)
		cCodMun :=  AllTrim(C09->C09_CODIGO) + cCodMun
	EndIf
	
	
	xTafTagGroup("dadosProcJud"	,{{"ufVara"	,uFVara				,,.F.};
								 	, {"codMunic"	,cCodMun				,,.F.};
								 	, {"idVara"	,C1G->C1G_VARA 		,,.F.}};
									,@cXml)	
	
	("T5L")->( DbSetOrder( 1 ) )
	("T5L")->( DbSeek ( xFilial("T5L")+C1G->C1G_ID+C1G->C1G_VERSAO) )
	//Laço para geração dos registros filhos
	While T5L->( !Eof()) .And. (xFilial("T5L")+C1G->C1G_ID+C1G->C1G_VERSAO == xFilial("T5L")+T5L->T5L_ID+T5L->T5L_VERSAO)
		cXml +=					"<infoSusp>"
		cXml +=						xTafTag("codSusp"		,T5L->T5L_CODSUS,,.F.)	
		cXml +=						xTafTag("indSusp"		,POSICIONE("C8S",1, xFilial("C8S")+T5L->T5L_INDDEC,"C8S_CODIGO"),,.F.)
		cXml +=						xTafTag("dtDecisao"	,T5L->T5L_DTDEC,,.F.)
		cXml +=						xTafTag("indDeposito",xFunTrcSN(T5L->T5L_INDDEP,1),,.F.)
		cXml +=					"</infoSusp>"	
		T5L->( dbSkip() )
	EndDo
	
	cXml +=					"</dadosProc>"
	
	If C1G->C1G_EVENTO == "A"
		If TafAtDtVld("C1G", C1G->C1G_ID, C1G->C1G_DTINI, C1G->C1G_DTFIN, C1G->C1G_VERANT, .T.)
			cXml +=			"<novaValidade>"
			cXml +=				TafGetDtTab(C1G->C1G_DTINI,C1G->C1G_DTFIN)
			cXml +=			"</novaValidade>"
		EndIf
	EndIf

	cXml +=				"</" + cEvento + ">"
	cXml +=			"</infoProcesso>"

ElseIf C1G->C1G_EVENTO == "E"
	cXml +=		"<infoProcesso>"
	cXml +=			"<exclusao>"
	cXml +=				"<ideProcesso>"
	cXml += 					xTafTag("tpProc",Iif(C1G->C1G_TPPROC == "1", "2", Iif(C1G->C1G_TPPROC == "2", "1", C1G->C1G_TPPROC)))
	cXml += 					xTafTag("nrProc",C1G->C1G_NUMPRO)
	cXml +=					TafGetDtTab(C1G->C1G_DTINI,C1G->C1G_DTFIN)
	cXml +=				"</ideProcesso>
	cXml +=			"</exclusao>"
	cXml +=		"</infoProcesso>"

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Estrutura do cabecalho³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nRecnoSM0 > 0
	SM0->(dbGoto(nRecnoSM0))
endif
cXml := xTafCabXml(cXml,"C1G", cLayout,cReg,,cSeqXml)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa gravacao do registro³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lJob
	xTafGerXml(cXml,cLayout)
EndIf

Return(cXml)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Taf051Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacões caso seja necessario gerar um XML

lJob - Informa se foi chamado por Job

@return .T.

@author Denis R. de Oliveira
@since 18/02/2014
@version 1.0
/*/                                                                                                                                          
//------------------------------------------------------------------------------------
Function TAF051Vld(cAlias,nRecno,nOpc,lJob,lEsocial)

Local aLogErro	:= {} 
Local cChave		:= ""

Default lJob 		:= .F.
Default lEsocial	:= .T.

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C1G->( Recno() )

If !lCallMenu

	If C1G->C1G_STATUS $ ( " |1" )
		
		//------------------------
		// Validações do ECF
		//------------------------
			
		//Valida o Numero do Processo
		If Empty(C1G->C1G_NUMPRO)
			Aadd( aLogErro, { "C1G_NUMPRO", "000010", "C1G", nRecno } ) //000010 - Campo Inconsistente ou Vazio
		EndIf
						
		//Acao Judicial
		If !Empty(C1G->C1G_ACAJUD)			
			//Chave de busca na tabela FILHO ou Consulta padrao
			cChave := C1G->C1G_ACAJUD
			xValRegTab("C18",cChave,3,,@aLogErro,, { "C1G", "C1G_ACAJUD", nRecno } ) 		
		EndIf
		
		//Nat. Acao Rec. Federal
		If !Empty(C1G->C1G_INRCFE)
			//Chave de busca na tabela FILHO ou Consulta padrao
			cChave := C1G->C1G_INRCFE
			xValRegTab("C19",cChave,3,,@aLogErro,, {"C1G", "C1G_INRCFE", nRecno } )
		EndIf
			
		//Atualizo o status do registro
		If Len(aLogErro)>0
			//Utilizo RecLock, pois o SETVALUE somente funciona em campos Usados
			RecLock("C1G",.F.)
				C1G->C1G_STATUS := "1"
			C1G->( MsUnlock() )
		Else
			RecLock("C1G",.F.)
				C1G->C1G_STATUS := "0"
			C1G->( MsUnlock() )
		EndIf

	Else	
		AADD(aLogErro,{"C1G_ID","000305", "C1G", nRecno })//Registros que já foram transmitidos ao Fisco, não podem ser validados
	EndIf

	//Não apresento o alert quando utilizo o JOB para validar
	If !lJob
		xValLogEr(aLogErro)
	EndIf
EndIf 

Return(aLogErro)

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF051Grv
@type			function
@description	Função de gravação para atender o registro S-1070.
@author			Vitor Siqueira
@since			09/06/2016
@version		1.0
@param			cLayout		-	Nome do Layout que está sendo enviado
@param			nOpc		-	Opção a ser realizada ( 3 = Inclusão, 4 = Alteração, 5 = Exclusão )
@param			cFilEv		-	Filial do ERP para onde as informações deverão ser importadas
@param			oXML		-	Objeto com as informações a serem manutenidas ( Outras Integrações )
@param			cOwner
@param			cFilTran
@param			cPredeces
@param			nTafRecno
@param			cComplem
@param			cGrpTran
@param			cEmpOriGrp
@param			cFilOriGrp
@param			cXmlID		-	Atributo Id, único para o XML do eSocial. Utilizado para importação de dados de clientes migrando para o TAF
@return			lRet		-	Variável que indica se a importação foi realizada, ou seja, se as informações foram gravadas no banco de dados
@param			aIncons		-	Array com as inconsistências encontradas durante a importação
/*/
//-------------------------------------------------------------------
Function TAF051Grv( cLayout, nOpc, cFilEv, oXML, cOwner, cFilTran, cPredeces, nTafRecno, cComplem, cGrpTran, cEmpOriGrp, cFilOriGrp, cXmlID )

Local cLogOpeAnt	:=	""
Local cCmpsNoUpd	:=	"|C1G_FILIAL|C1G_ID|C1G_VERSAO|C1G_DTINI|C1G_DTFIN|C1G_VERANT|C1G_PROTPN|C1G_EVENTO|C1G_STATUS|C1G_ATIVO|C1G_ESOCIA|C1G_INDDEC|C1G_DINDDE|C1G_DTDEC|C1G_INDDEP|C1G_PROCID"
Local cCabec		:=	"/eSocial/evtTabProcesso/infoProcesso"
Local cValChv		:=	""
Local cNewDtIni		:=	""
Local cNewDtFin		:=	""
Local cInconMsg		:=	""
Local cAux			:=	""
Local cChave		:=	""
Local cPerIni		:=	""
Local cPerFin		:=	""
Local cPerIniOri	:=	""
Local cCodEvent		:=	""
Local cAliasQry     :=  ""
Local nIndex		:=	5 //Inicializado com o índice completo da aplicação
Local nIndIDVer		:=	1
Local nlI			:=	0
Local nT5L			:=	0
Local nJ			:=	0
Local nSeqErrGrv	:=	0
Local nTamProc		:=	TamSX3( "C1G_TPPROC" )[1]
Local nTamNum		:=	TamSX3( "C1G_NUMPRO" )[1]
Local lRet			:=	.F.
Local aIncons		:=	{}
Local aRules		:=	{}
Local aChave		:=	{}
Local aNewData		:=	{ Nil, Nil }
Local oModel		:=	Nil
Local lNewValid		:= .F.
Local lNt1519       := FindFunction("TafNT1519") .And. TafNT1519() //Indica se está em vigor a NT 15/2019
Local lIncAuto      := .F. // Indica quando o número de processo foi incluso no TAF via inclusão automática, ou seja, quando enviado por outro evento.

Private lVldModel	:=	.T. //Caso a chamada seja via integração, seto a variável de controle de validação como .T.
Private oDados		:=	Nil

Default cLayout		:=	""
Default nOpc		:=	1
Default cFilEv		:=	""
Default oXML		:=	Nil
Default cOwner		:=	""
Default cFilTran	:=	""
Default cPredeces	:=	""
Default nTafRecno	:=	0
Default cComplem	:=	""
Default cGrpTran	:=	""
Default cEmpOriGrp	:=	""
Default cFilOriGrp	:=	""
Default cXmlID		:=	""

cCodEvent := Posicione( "C8E", 2, xFilial( "C8E" ) + "S-" + cLayout, "C8E->C8E_ID" )

If(TAFAlsInDic("T5L"))
	
	oDados := oXML	
	
	If nOpc == 3
		cTagOper := "/inclusao"	
	ElseIf nOpc == 4
		cTagOper := "/alteracao"	
	ElseIf nOpc == 5	
		cTagOper := "/exclusao"
	EndIf

	//Verificar se o Tipo de Inscrição foi informado para a chave ( Obrigatório ser informado )
	cValChv := FTAFGetVal( cCabec + cTagOper + "/ideProcesso/tpProc", "C", .F., @aIncons, .F., "", "" )
	
	If !Empty( cValChv )
		//De-Para do Manual do eSocial com o campo do TAF.
		//Inverto os códigos para atender o layout do eSocial
		If !Empty( cValChv )
			If Alltrim(cValChv) == "1"
				cValChv := "2"
			ElseIf Alltrim(cValChv) == "2"
				cValChv := "1"
			Else
				cValChv := cValChv
			EndIf
		else 	
			aAdd( aIncons, "Campo tpProc é obrigatório e não foi informado." )
		EndIf

		aAdd( aChave, { "C", "C1G_TPPROC", cValChv, .T. } )
		nIndex := 9 //C1G_FILIAL+C1G_TPPROC+C1G_NUMPRO+C1G_ATIVO
			
		cChave += Padr(cValChv, nTamProc)
	EndIf

	//Verificar se o numero de inscricao foi informado para a chave( Obrigatorio ser informado )
	cValChv := FTafGetVal( cCabec + cTagOper + '/ideProcesso/nrProc', 'C', .F., @aIncons, .F., '', '' )
	If !Empty( cValChv )
		Aadd( aChave, { "C", "C1G_NUMPRO", cValChv, .T. } )
		nIndex := 9 //C1G_FILIAL+C1G_TPPROC+C1G_NUMPRO+C1G_ATIVO
		
		cChave += Padr(cValChv, nTamNum)

		If lNt1519 .And. nOpc == 3 //Verifico se houve inclusão automática desse número de processo.
			cAliasQry := GetNextAlias()

			BeginSql Alias cAliasQry
				SELECT *
				FROM %table:C1G% C1G
				WHERE C1G.C1G_FILIAL = %xFilial:C1G%
				AND C1G.C1G_NUMPRO   = %Exp:AllTrim(cValChv)%
				AND C1G.C1G_LOGOPE   = 'A'
				AND C1G.C1G_STATUS   = '4'
				AND C1G.C1G_ATIVO    = '1'
				AND C1G.%notDel%
			EndSql

			DbSelectArea(cAliasQry)
			(cAliasQry)->(DbGoTop())

			If (cAliasQry)->(!Eof())
				lIncAuto := .T.
				cChave   := Padr(cValChv, nTamNum)
				nIndex   := 1 //C1G_FILIAL+C1G_NUMPRO+C1G_INDPRO
			EndIf

			(cAliasQry)->(DbCloseArea())
		EndIf
	EndIf
	
	//Verificar se a data inicial foi informado para a chave( Se nao informado sera adotada a database internamente )
	cValChv := FTafGetVal( cCabec + cTagOper + '/ideProcesso/iniValid', 'C', .F., @aIncons, .F., '', '' )
	cValChv := StrTran( cValChv, "-", "" )
	cValChv := Substr(cValChv, 5, 2) + Substr(cValChv, 1,4) 
	If !Empty( cValChv )
		Aadd( aChave, { "C", "C1G_DTINI", cValChv, .T. } )
		nIndex 	:= 10 //C1G_FILIAL+C1G_TPPROC+C1G_NUMPRO+C1G_DTINI+C1G_ATIVO
		cPerIni 	:= cValChv
		cPerIniOri	:= cValChv                                                                                                 
	EndIf
	
	//Verificar se a data final foi informado para a chave( Se nao informado sera adotado vazio )
	cValChv := FTafGetVal( cCabec + cTagOper + '/ideProcesso/fimValid', 'C', .F., @aIncons, .F., '', '' )
	cValChv := StrTran( cValChv, "-", "" )
	cValChv := Substr(cValChv, 5, 2) + Substr(cValChv, 1,4) 
	If !Empty( cValChv )
		Aadd( aChave, { "C", "C1G_DTFIN", cValChv, .T.} )
		nIndex	:= 5 //C1G_FILIAL+C1G_TPPROC+C1G_NUMPRO+C1G_DTINI+C1G_DTFIN+C1G_ATIVO
		cPerFin:= cValChv                                                                                    	
	EndIf
	
	If nOpc == 4
		If oDados:XPathHasNode( cCabec + cTagOper + "/novaValidade/iniValid", 'C', .F., @aIncons, .F., '', ''  )
			cNewDtIni 	:= StrTran(FTafGetVal( cCabec + cTagOper + "/novaValidade/iniValid", 'C', .F., @aIncons, .F., '', '' ) , "-", "" ) 
			cNewDtIni 	:= Substr(cNewDtIni, 5, 2) + Substr(cNewDtIni, 1,4) 
			aNewData[1]	:= cNewDtIni
			cPerIni 	:= cNewDtIni
			lNewValid	:= .T.
		EndIf
		
		If oDados:XPathHasNode( cCabec + cTagOper + "/novaValidade/fimValid", 'C', .F., @aIncons, .F., '', ''  )
			cNewDtFin := StrTran(FTafGetVal( cCabec + cTagOper + "/novaValidade/fimValid", 'C', .F., @aIncons, .F., '', '' ) , "-", "" )
			cNewDtFin := Substr(cNewDtFin, 5, 2) + Substr(cNewDtFin, 1,4)
			aNewData[2] := cNewDtFin			
			cPerFin 	:= cNewDtFin
			lNewValid	:= .T.
		EndIf
	EndIf

	//Valida as regras da nova validade
	If Empty(aIncons)
		//valida se é inclusão (3), sendo inclusão é realizada a alteração do indice para garantir unicidade do numpro no eSocial desconsiderando o REINF
		IF nOpc == 3 .AND. TafIndexInDic("C1G", 13, .F.) .AND. TafIndexInDic("C1G", 14, .F.)
			VldEvTab( "C1G", IIF(lIncAuto,1,14), cChave, cPerIni, cPerFin, 2, nOpc, @aIncons, cPerIniOri,2, '1' ) 
			Aadd( aChave, { "C", "C1G_ESOCIA", cValChv, .T.} )
			
			IF nIndex == 5 
				nIndex := 13
			elseif nIndex := 10 
				nIndex := 14
			endif
		else
			VldEvTab( "C1G", IIF(lIncAuto,1,10), cChave, cPerIni, cPerFin, 2, nOpc, @aIncons, cPerIniOri,2,, lNewValid ) 
		endif
	EndIf
	
	If Empty(aIncons)	
	
		Begin Transaction	
			
			//Funcao para validar se a operacao desejada pode ser realizada
			If FTafVldOpe( "C1G", nIndex, @nOpc, cFilEv, @aIncons, aChave, @oModel, "TAFA051", cCmpsNoUpd, nIndIDVer, .T., aNewData )

				If TafColumnPos( "C1G_LOGOPE" )
					cLogOpeAnt := C1G->C1G_LOGOPE

				endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Quando se tratar de uma Exclusao direta apenas preciso realizar ³
				//³o Commit(), nao eh necessaria nenhuma manutencao nas informacoes³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nOpc <> 5
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Carrego array com os campos De/Para de gravacao das informacoes³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aRules := TAF051Rul( cTagOper, @cInconMsg, @nSeqErrGrv, cCodEvent, cOwner )								                
						 
					oModel:LoadValue( "MODEL_C1G", "C1G_ESOCIA", "1" )	 
				   	oModel:LoadValue( "MODEL_C1G", "C1G_FILIAL", C1G->C1G_FILIAL )															

					If TAFColumnPos( "C1G_XMLID" )
						oModel:LoadValue( "MODEL_C1G", "C1G_XMLID", cXmlID )
					EndIf

				   	//Rodo o aRules para gravar as informações
				   	For nlI := 1 to Len( aRules )
				   		If aRules[nlI,01] <> "C1G_TPPROC"
				   			oModel:LoadValue( "MODEL_C1G", aRules[nlI,01], FTAFGetVal( aRules[nlI,02], aRules[nlI,03], aRules[nlI,04], @aIncons, .F.,, aRules[nlI,01] ) )
				   		Else
				   			//De-Para do Manual do eSocial com o campo do TAF.
				   			cAux := FTAFGetVal( aRules[nlI,02], aRules[nlI,03], aRules[nlI,04], @aIncons, .F.,, aRules[nlI,01] )
	
								If !Empty( cAux )
									If Alltrim(cAux) == "1"
										cAux := "2"
									ElseIf Alltrim(cAux) == "2"
										cAux := "1"
									Else
										cAux := cAux
									EndIf	
								EndIf
				   				oModel:LoadValue( "MODEL_C1G", aRules[nlI,01], cAux )
					   		EndIf
				   	Next nlI

					If Findfunction("TAFAltMan")
						if nOpc == 3
							TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_C1G', 'C1G_LOGOPE' , '1', '' )
						elseif nOpc == 4
							TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_C1G', 'C1G_LOGOPE' , '', cLogOpeAnt )
						EndIf
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Quando se trata de uma alteracao deleto todas as linhas do Grid³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If (nOpc == 4) 
						For nJ := 1 to oModel:GetModel( 'MODEL_T5L' ):Length()
							oModel:GetModel( 'MODEL_T5L' ):GoLine(nJ)
							oModel:GetModel( 'MODEL_T5L' ):DeleteLine()
						Next nJ
					EndIf	
					
					/* Esse layout, possui registros 'filhos'(horarioIntervalo). Então faço o controle para salvar
				 	a quantidade de nós que estiverem no xml para os 'filhos'.*/
				 	nT5L := 1
					While oDados:XPathHasNode(cCabec + cTagOper + "/dadosProc/infoSusp[" + CVALTOCHAR(nT5L) + "]"  )
						If (nT5L > 1) .Or. (nOpc == 4)			
							// é necessário atribuir LVALID para que permita o addline();
				          	oModel:GetModel( "MODEL_T5L" ):LVALID := .T.            			
							oModel:GetModel( "MODEL_T5L" ):AddLine()
						EndIf
											
						If oDados:XPathHasNode(cCabec + cTagOper + "/dadosProc/infoSusp[" + CVALTOCHAR(nT5L) + "]/codSusp")
							oModel:LoadValue( "MODEL_T5L", "T5L_CODSUS", FTafGetVal(cCabec + cTagOper + "/dadosProc/infoSusp[" + CVALTOCHAR(nT5L) + "]/codSusp"   , "C", .F., @aIncons, .F.))
						EndIf
											
						If oDados:XPathHasNode(cCabec + cTagOper + "/dadosProc/infoSusp[" + CVALTOCHAR(nT5L) + "]/indSusp")
							oModel:LoadValue( "MODEL_T5L", "T5L_INDDEC", FGetIdInt( "indSusp", "", cCabec + cTagOper + "/dadosProc/infoSusp[" + CVALTOCHAR(nT5L) + "]/indSusp",,,,@cInconMsg, @nSeqErrGrv))
						EndIf
											
						If oDados:XPathHasNode(cCabec + cTagOper + "/dadosProc/infoSusp[" + CVALTOCHAR(nT5L) + "]/dtDecisao")
							oModel:LoadValue( "MODEL_T5L", "T5L_DTDEC", FTafGetVal( cCabec + cTagOper + "/dadosProc/infoSusp[" + CVALTOCHAR(nT5L) + "]/dtDecisao" , "D", .F., @aIncons, .F.))
						EndIF					
						
						If oDados:XPathHasNode(cCabec + cTagOper + "/dadosProc/infoSusp[" + CVALTOCHAR(nT5L) + "]/indDeposito")					
							oModel:LoadValue( "MODEL_T5L", "T5L_INDDEP", xFunTrcSN( TAFExisTag( cCabec + cTagOper + "/dadosProc/infoSusp[" + CVALTOCHAR(nT5L) + "]/indDeposito" ),2))
						EndIf
						
						nT5L := nT5L + 1
					EndDo
								        							
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Efetiva a operacao desejada³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Empty(cInconMsg)			
					If TafFormCommit( oModel )
						Aadd(aIncons, "ERRO19")
					Else
						lRet := .T.
					EndIf	 
				Else			
					Aadd(aIncons, cInconMsg)		
					DisarmTransaction()
				EndIf						 			   
			    
			    oModel:DeActivate()
				If FindFunction('TafClearModel')
					TafClearModel(oModel)
				EndIf	    								 				
			EndIf                                                                           	
		
		End Transaction 
		
	EndIf
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Zerando os arrays e os Objetos utilizados no processamento³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aSize( aRules, 0 ) 
	aRules     := Nil
	
	aSize( aChave, 0 ) 
	aChave     := Nil    
	
EndIf

Return { lRet, aIncons } 

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF051Rul           

Regras para gravacao das informacoes do registro S-1070 do E-Social

@Param
nOper      - Operacao a ser realizada ( 3 = Inclusao / 4 = Alteracao / 5 = Exclusao )

@Return	
aRull  - Regras para a gravacao das informacoes


@author Vitor Siqueira
@since 09/06/2016
@version 1.0

/*/                        	
//-------------------------------------------------------------------
Static Function TAF051Rul( cTagOper, cInconMsg, nSeqErrGrv, cCodEvent, cOwner )

Local aRull    := {}
Local cCabec   := "/eSocial/evtTabProcesso/infoProcesso"

Default cTagOper		:= ""
Default cInconMsg		:= ""
Default nSeqErrGrv	:= 0
Default cCodEvent		:= ""
Default cOwner		:= ""

If TafXNode( oDados, cCodEvent, cOwner, (cCabec + cTagOper + "/ideProcesso/tpProc"))
	Aadd( aRull, { "C1G_TPPROC", cCabec + cTagOper + "/ideProcesso/tpProc", "C", .F. } )
EndIf

If TafXNode( oDados, cCodEvent, cOwner, (cCabec + cTagOper + "/ideProcesso/nrProc"))
	Aadd( aRull, { "C1G_NUMPRO", cCabec + cTagOper + "/ideProcesso/nrProc", "C", .F. } )
Endif

If TafXNode( oDados, cCodEvent, cOwner, (cCabec + cTagOper + "/dadosProc/indAutoria"))
	Aadd( aRull, { "C1G_INDAUT", cCabec + cTagOper + "/dadosProc/indAutoria", "C", .F. } )
Endif

If TafXNode( oDados, cCodEvent, cOwner, (cCabec + cTagOper + "/dadosProc/indMatProc"))
	Aadd( aRull, { "C1G_INDMAT", FGetIdInt("indMatProc","",cCabec + cTagOper + "/dadosProc/indMatProc",,,,@cInconMsg, @nSeqErrGrv), "C", .T.} )
EndIf

If TafLayESoc("02_04_02")
	If TafXNode( oDados, cCodEvent, cOwner, (cCabec + cTagOper + "/dadosProc/observacao"))
		Aadd( aRull, { "C1G_OBS", cCabec + cTagOper + "/dadosProc/observacao", "C", .F. } ) 			    
	EndIf
EndIf

If TafXNode( oDados, cCodEvent, cOwner, (cCabec + cTagOper + "/dadosProc/dadosProcJud/idVara"))
	Aadd( aRull, { "C1G_VARA", cCabec + cTagOper + "/dadosProc/dadosProcJud/idVara", "C", .F. } )
EndIf

If TafXNode( oDados, cCodEvent, cOwner, (cCabec + cTagOper + "/dadosProc/dadosProcJud/ufVara"))
	aAdd( aRull, { "C1G_UFVARA", FGetIdInt( "ufVara", "", "/eSocial/evtTabProcesso/infoProcesso" + cTagOper + "/dadosProc/dadosProcJud/ufVara",,,,@cInconMsg, @nSeqErrGrv), "C", .T. } )
EndIf

If TafXNode( oDados, cCodEvent, cOwner, ("/eSocial/evtTabProcesso/infoProcesso" + cTagOper + "/dadosProc/dadosProcJud/codMunic"))
	aAdd( aRull, { "C1G_CODMUN", FGetIdInt( "codMunic", "uf", cCabec + cTagOper + "/dadosProc/dadosProcJud/ufVara",;
		"/eSocial/evtTabProcesso/infoProcesso" + cTagOper + "/dadosProc/dadosProcJud/codMunic",,,@cInconMsg, @nSeqErrGrv), "C", .T. } )
EndIf

Return( aRull )

//-------------------------------------------------------------------
/*/{Protheus.doc} VldChvProc           
Função que chama a validação das regras inclusão e alteração de eventos de tabelas 
do e-social (VldEvTab), ou a validação de chave única (XFUNVldUni) para a rotina
de processos administrativos/judiciais.

@Param
cCampo		- Campo posicionado na tela

@author Denis R. de Oliveira
@since 28/12/2017
@version 1.0

/*/                        	
//-------------------------------------------------------------------
Function VldChvProc( cCampo )

Local lRet as logical 
Local cEsocial := ""
Local nIndice := ""
Default cCampo := ""

lRet := .T.
	
If lCallMenu 
	nIndice := 13
	if !TafIndexInDic("C1G", nIndice, .F.)
		nIndice := 5
	EndIf
	cEsocial := "1"
	
	If cCampo == "C1G_TPPROC" 
		lRet	:= VldEvTab("C1G",nIndice,M->C1G_TPPROC+FWFLDGET("C1G_NUMPRO"),FWFLDGET("C1G_DTINI"),FWFLDGET("C1G_DTFIN"),1,/*nOper*/, /*aIncons*/, /*cPerIniXML*/, 2, cEsocial)     
	ElseIf cCampo == "C1G_NUMPRO"  
		lRet 	:= VldEvTab("C1G",nIndice,FWFLDGET("C1G_TPPROC")+M->C1G_NUMPRO,FWFLDGET("C1G_DTINI"),FWFLDGET("C1G_DTFIN"),1,/*nOper*/, /*aIncons*/, /*cPerIniXML*/, 2, cEsocial)     
	ElseIf cCampo == "C1G_DTINI" 
		lRet	:= VldEvTab("C1G",nIndice,FWFLDGET("C1G_TPPROC")+FWFLDGET("C1G_NUMPRO"),M->C1G_DTINI,FWFLDGET("C1G_DTFIN"),1,/*nOper*/, /*aIncons*/, /*cPerIniXML*/, 2, cEsocial)      
	ElseIf cCampo == "C1G_DTFIN" 
		lRet	:= VldEvTab("C1G",nIndice,FWFLDGET("C1G_TPPROC")+FWFLDGET("C1G_NUMPRO"),FWFLDGET("C1G_DTINI"),M->C1G_DTFIN,1,/*nOper*/, /*aIncons*/, /*cPerIniXML*/, 2, cEsocial)             
	EndIf
	
Else
	nIndice := 12
	if !TafIndexInDic("C1G", nIndice, .F.)
		nIndice := 10
	EndIf


	If cCampo == "C1G_NUMPRO" 
		lRet	:= XFUNVldUni("C1G",nIndice,Padr(cEsocial,TamSX3("C1G_ESOCIA")[1])+M->C1G_NUMPRO+FWFLDGET("C1G_INDPRO"))
	ElseIf cCampo == "C1G_INDPRO"  
		lRet	:= XFUNVldUni("C1G",nIndice,Padr(cEsocial,TamSX3("C1G_ESOCIA")[1])+FWFLDGET("C1G_NUMPRO")+M->C1G_INDPRO)     
	EndIf
	
EndIf
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TafCpoEsoc
Indica se um campo pertencente ao escopo do eSocial foi alterado

@Param
@Return lRet

@author Fabio V Santana
@since 23/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function TafAlt1070()

	Local oModel    	as object
	Local oModelC1G 	as object
	Local oModelT5L    	as object
	Local nX			as numeric
	Local nPos			as numeric
	Local lRet 			as logical
	Local aAltReinf		as array
	Local aCampos 		as array

	oModel    	:= FWModelActive()
	oModelC1G 	:= oModel:GetModel( 'MODEL_C1G' )
	nX			:= 0
	nPos		:= 0
	lret 		:= .F.
	aAltReinf	:= {}

	If FindFunction("TafR1070Cpo")
		aInfo		:= TafR1070Cpo()
		aCampos 	:= aInfo[02]

		For Nx := 1 To Len( aCampos )
			cCampo := AllTrim( aCampos[Nx] )
			If Substr(cCampo,1,3) == 'C1G' .And. TafColumnPos( cCampo )

				uVal1 := &(M->cCampo)
				uVal2 := oModelC1G:GetValue( cCampo )

				If uVal1 <> uVal2
					lRet := .T.
					AADD( aAltReinf, { cCampo, AllToChar( uVal1 ) , AllToChar( uVal2 ) })
				EndIf
			EndIf
		Next
	Else
		lRet := .T.
	EndIf

	If !lRet
		oModelT5L := oModel:GetModel( 'MODEL_T5L' )
		if valtype( oModelT5L ) <> "U" 
			For nX := 1 To oModelT5L:Length()
				oModelT5L:GoLine(nX)
				If oModelT5L:IsUpdated(nX) .Or. oModelT5L:IsDeleted(nX)
					lRet := .T.
				EndIf
			Next
		endif
	Endif
Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF425Cbox
@type			function
@description	Construtor de combobox para casos onde o tamanho das
@description	opções ultrapassa o limite permitido no AtuSX.
@author			Felipe C. Seolin
@since			27/09/2018
@version		1.0
@param			cCampo	-	Campo para referência do combobox
@return			cString	-	String formatada no padrão do combobox
/*/
//---------------------------------------------------------------------
Function TAF051Cbox()

Local cString := ""

cString := "1=Inclusão via Integração;"
cString += "2=Inclusão Manual;"
cString += "3=Inclusão via Integração + Alteração via Integração;"
cString += "4=Inclusão via Integração + Alteração Manual;"
cString += "5=Inclusão Manual + Alteração via Integração;"
cString += "6=Inclusão Manual + Alteração Manual;"
cString += "A=Inclusão Automática"

Return( cString )
