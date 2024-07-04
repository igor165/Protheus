#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA477.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA477
Cadastro MVC de Solicitação de Totalização para Pagamento em Contingência - S-1295
 
@author Denis R. de Oliveira
@since 16/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA477()

	Private oBrw := Nil

	If FindFunction("TAFDesEven")
		TAFDesEven()
	EndIf

	If TafAtualizado()
		oBrw := FWmBrowse():New()

		oBrw:SetDescription( STR0001 )	//"Solicitação de Totalização para Pagamento em Contingência"
		oBrw:SetAlias( 'T72')
		oBrw:SetMenuDef( 'TAFA477' )	
	
		If FindFunction('TAFSetFilter')
			oBrw:SetFilterDefault(TAFBrwSetFilter("T72","TAFA477","S-1295"))
		Else
			oBrw:SetFilterDefault( "T72_ATIVO == '1'" )
		EndIf

		TafLegend(2,"T72",@oBrw)

		oBrw:Activate()
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Funcao generica MVC com as opcoes de menu

@author Denis R. de Oliveira
@since 16/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aFuncao := {}
	Local aRotina := {}

	Aadd( aFuncao, { "" , "TafxmlRet('TAF477Xml','1295','T72')" 								, "1" } )
	Aadd( aFuncao, { "" , "xFunHisAlt( 'T72', 'TAFA477' ,,,, 'TAF477XML','1295'  )" 			, "3" } )
	Aadd( aFuncao, { "" , "TAFXmlLote( 'T72', 'S-1295' , 'evtTotConting' , 'TAF477Xml',, oBrw )", "5" } )
	Aadd( aFuncao, { "" , "xFunAltRec( 'T72' )" 												, "10" } )

	lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

	If lMenuDif .Or. ViewEvent('S-1295')
		ADD OPTION aRotina Title STR0002 Action "VIEWDEF.TAFA477" OPERATION 2 ACCESS 0 //"Visualizar"
	Else
		aRotina := xFunMnuTAF( "TAFA477" , , aFuncao)
	EndIf

Return( aRotina )

//------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Denis R. de Oliveira
@since 16/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oStruT72 := FWFormStruct( 1, 'T72' )
	LocaL oModel   := MPFormModel():New( 'TAFA477',,,{|oModel| SaveModel( oModel ) } )  

	// Adiciona ao modelo um componente de formulário
	oModel:AddFields("MODEL_T72",/*cOwner*/,oStruT72)
	oModel:GetModel("MODEL_T72"):SetPrimaryKey({"T72_FILIAL","T72_ID","T72_VERSAO"})

	oStruT72:SetProperty( 'T72_IDRESP', MODEL_FIELD_OBRIGAT , .T. )

Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Denis R. de Oliveira
@since 16/08/2017
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

	Local oModel    := FWLoadModel( 'TAFA477' )
	Local oStruT72a := Nil
	Local oStruT72b := Nil
	Local oStruT72c := Nil
	Local oStruT72d := Nil
	Local oView     := FWFormView():New()
	Local cCmpFil   := ""
	Local nI        := 0
	Local aCmpGrp   := {}
	Local cGrpCom1  := ""
	Local cGrpCom2  := ""
	Local cGrpCom3  := ""

	oView:SetModel( oModel )

	//"Informações de Apuração"
	cGrpCom1  := 'T72_ID|T72_VERSAO|T72_VERANT|T72_PROTPN|T72_EVENTO|T72_ATIVO|T72_INDAPU|T72_PERAPU|'
	cCmpFil   := cGrpCom1 
	oStruT72a := FwFormStruct( 2, 'T72', {|x| AllTrim( x ) + "|" $ cCmpFil } )

	//"Responsável pelas informações"
	cGrpCom2 := 'T72_IDRESP|T72_DESCRE|'
	cCmpFil   := cGrpCom2
	oStruT72b := FwFormStruct( 2, 'T72', {|x| AllTrim( x ) + "|" $ cCmpFil } )

	//"Protocolo de Transmissão"
	cGrpCom3 := 'T72_PROTUL|'
	cCmpFil   := cGrpCom3
	oStruT72c := FwFormStruct( 2, 'T72', {|x| AllTrim( x ) + "|" $ cCmpFil } )

	If TafColumnPos("T72_DTRANS")
		cCmpFil := 'T72_DINSIS|T72_DTRANS|T72_HTRANS|T72_DTRECP|T72_HRRECP|'
		oStruT72d := FwFormStruct( 2, 'T72', {|x| AllTrim( x ) + "|" $ cCmpFil } )
	EndIf

	/*--------------------------------------------------------------------------------------------
			Grupo de campos da Solicitação de Totalização para Pagamento em Contingência
	---------------------------------------------------------------------------------------------*/

	oStruT72a:AddGroup( "GRP_APURACAO", STR0003, "", 1 ) //Informações de Apuração 

	aCmpGrp := StrToKArr(cGrpCom1,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruT72a:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_APURACAO")
	Next nI

	oStruT72b:AddGroup( "GRP_RESPONSAVEL", STR0004, "", 1 ) //Responsável pelas Informações

	aCmpGrp := StrToKArr(cGrpCom2,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruT72b:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_RESPONSAVEL")
	Next nI

	If FindFunction('TafAjustRecibo')
		TafAjustRecibo(oStruT72c,"T72")
	EndIf 
	/*--------------------------------------------------------------------------------------------
											Esrutura da View
	---------------------------------------------------------------------------------------------*/

	oView:AddField( 'VIEW_T72a', oStruT72a, 'MODEL_T72' )
	oView:AddField( 'VIEW_T72b', oStruT72b, 'MODEL_T72' )
	oView:AddField( 'VIEW_T72c', oStruT72c, 'MODEL_T72' )

	If TafColumnPos("T72_PROTUL")
		oView:EnableTitleView( 'VIEW_T72c', TafNmFolder("recibo",1) ) // "Recibo da última Transmissão"  
	EndIf 
	
	If TafColumnPos("T72_DTRANS")
		oView:AddField( 'VIEW_T72d', oStruT72d, 'MODEL_T72' )
		oView:EnableTitleView( 'VIEW_T72d', TafNmFolder("recibo",2) ) 
	EndIf
	/*--------------------------------------------------------------------------------------------
										Estrutura do Folder
	---------------------------------------------------------------------------------------------*/

	oView:CreateHorizontalBox("PAINEL_SUPERIOR",100)
	oView:CreateFolder("FOLDER_SUPERIOR","PAINEL_SUPERIOR")

	oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA01', STR0001 )   //"Solicitação de Totalização para Pagamento em Contingência"

	If FindFunction('TafNmFolder')
		oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA02', TafNmFolder("recibo") )   //"Numero do Recibo"
	Else
		oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA02', STR0005 )   //"Protocolo de Transmissão"
	EndIf 

	oView:CreateHorizontalBox( 'T72a',  035,,, 'FOLDER_SUPERIOR', 'ABA01' )
	oView:CreateHorizontalBox( 'T72b',  065,,, 'FOLDER_SUPERIOR', 'ABA01' )
	If TafColumnPos("T72_DTRANS")
		oView:CreateHorizontalBox( 'T72c',  20,,, 'FOLDER_SUPERIOR', 'ABA02' )
		oView:CreateHorizontalBox( 'T72d',  80,,, 'FOLDER_SUPERIOR', 'ABA02' )
	Else
		oView:CreateHorizontalBox( 'T72c',  100,,, 'FOLDER_SUPERIOR', 'ABA02' )
	EndIf

	oView:SetOwnerView( "VIEW_T72a", "T72a")
	oView:SetOwnerView( "VIEW_T72b", "T72b")
	oView:SetOwnerView( "VIEW_T72c", "T72c")
	If TafColumnPos("T72_DTRANS")
		oView:SetOwnerView( "VIEW_T72d", "T72d")
	EndIf

	lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

	oStruT72a:RemoveField( "T72_ID" )

	If !lMenuDif
		xFunRmFStr(@oStruT72a, 'T72')
		xFunRmFStr(@oStruT72b, 'T72')
	EndIf

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo
	
@Param  oModel -> Modelo de dados

@Return .T.

@author Denis R. de Oliveira
@since 16/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )
	
	Local cVerAnt    := ""
	Local cProtocolo := ""
	Local cVersao    := ""
	Local cChvRegAnt := ""
	Local cEvento    := ""
	Local cLogOpeAnt := ""
	Local nOperation := oModel:GetOperation()
	Local nI         := 0
	Local aGrava     := {}
	Local oModelT72  := Nil
	Local lRetorno   := .T.

	Begin Transaction

		//Inclusao Manual do Evento
		If nOperation == MODEL_OPERATION_INSERT

			oModel:LoadValue( "MODEL_T72", "T72_VERSAO", xFunGetVer() )

			If Findfunction("TAFAltMan")
				TAFAltMan( 3 , 'Save' , oModel, 'MODEL_T72', 'T72_LOGOPE' , '2', '' )
			EndIf

			FwFormCommit( oModel )

		//Alteração Manual do Evento
		ElseIf nOperation == MODEL_OPERATION_UPDATE 

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Seek para posicionar no registro antes de realizar as validacoes,³
			//³visto que quando nao esta pocisionado nao eh possivel analisar   ³
			//³os campos nao usados como _STATUS                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//Posicionando no registro para que nao ocorra erros duranteo processo de validação
			T72->( DbSetOrder( 4 ) )
			If T72->( MsSeek( xFilial( 'T72' ) + T72->T72_ID + '1' ) )	

				//Verifica se o evento ja foi trasmitido ao RET
				If T72->T72_STATUS $ ( "4" )	

					//Carrego a Estrutura dos Models a serem gravados
					oModelT72 := oModel:GetModel( "MODEL_T72" )		
					
					//Guardo as informações do registro corrente para rastro do registro
					cVerAnt		:= oModelT72:GetValue( "T72_VERSAO" )
					cProtocolo	:= oModelT72:GetValue( "T72_PROTUL" )
					cEvento		:= oModelT72:GetValue( "T72_EVENTO" )

					If TafColumnPos( "T72_LOGOPE" )
						cLogOpeAnt := oModelT72:GetValue( "T72_LOGOPE" )
					EndIf

					//Armazeno as informações correntes do cadastro( Depois da alteração do Usuário )			
					For nI := 1 to Len( oModelT72:aDataModel[ 1 ] )
						Aadd( aGrava, { oModelT72:aDataModel[ 1, nI, 1 ], oModelT72:aDataModel[ 1, nI, 2 ] } )
					Next nI
		
					/*---------------------------------------------------------- 
					Seto o campo como Inativo e gravo a versao do novo registro
					no registro anterior                                       
							
					ATENCAO -> A alteracao destes campos deve sempre estar     
					abaixo do Loop do For, pois devem substituir as informacoes
					que foram armazenadas no Loop acima 
					-----------------------------------------------------------*/                        
					FAltRegAnt( "T72", "2" )
		
					/*----------------------------------------------------------
					Apos deixar o registro corrente como inativo eu seto a 
					operação de inclusão para o novo registro
					-----------------------------------------------------------*/
					oModel:DeActivate()
					oModel:SetOperation( 3 )
					oModel:Activate()
		
					/*----------------------------------------------------------
					Neste momento eu realizo a gravação de um novo registro idêntico
					ao original, apenas com as alterações nos campos modificados
					pelo usuário no cadastro
					-----------------------------------------------------------*/			
					For nI := 1 to Len( aGrava )
						oModel:LoadValue( "MODEL_T72", aGrava[ nI, 1 ], aGrava[ nI, 2 ] )
					Next nI

					//Necessário Abaixo do For Nao Retirar
					If Findfunction("TAFAltMan")
						TAFAltMan( 4 , 'Save' , oModel, 'MODEL_T72', 'T72_LOGOPE' , '' , cLogOpeAnt )
					EndIf

					//Busco a nova versao do registro
					cVersao := xFunGetVer()
		
					/*---------------------------------------------------------
					ATENCAO -> A alteracao destes campos deve sempre estar     
					abaixo do Loop do For, pois devem substituir as informacoes
					que foram armazenadas no Loop acima                        
					-----------------------------------------------------------*/
					oModel:LoadValue( "MODEL_T72", "T72_VERSAO", cVersao )
					oModel:LoadValue( "MODEL_T72", "T72_VERANT", cVerAnt )
					oModel:LoadValue( "MODEL_T72", "T72_PROTPN", cProtocolo )
					oModel:LoadValue( "MODEL_T72", "T72_PROTUL", "" )
					oModel:LoadValue( "MODEL_T72", "T72_EVENTO", "A" )
					// Tratamento para limpar o ID unico do xml
					cAliasPai := "T72"

					If TAFColumnPos( cAliasPai+"_XMLID" )
						oModel:LoadValue( 'MODEL_'+cAliasPai, cAliasPai+'_XMLID', "" )
					EndIf
					
					FwFormCommit( oModel )
					TAFAltStat( 'T72', " " )  

				ElseIf	T72->T72_STATUS == "2"    

					TAFMsgVldOp(oModel,"2")//"Registro não pode ser alterado. Aguardando processo da transmissão."
					lRetorno:= .F.

				ElseIf T72->T72_STATUS == "6"   

					TAFMsgVldOp(oModel,"6")//"Registro não pode ser alterado. Aguardando proc. Transm. evento de Exclusão S-3000"
					lRetorno:= .F.

				Elseif T72->T72_STATUS == "7"

					TAFMsgVldOp(oModel,"7") //"Registro não pode ser alterado, pois o evento já se encontra na base do RET"  
					lRetorno:= .F.

				Else
				
					//Alteração Sem Transmissão
					If TafColumnPos( "T72_LOGOPE" )
						cLogOpeAnt := T72->T72_LOGOPE
					EndIf

					If Findfunction("TAFAltMan")
						TAFAltMan( 4 , 'Save' , oModel, 'MODEL_T72', 'T72_LOGOPE' , '' , cLogOpeAnt )
					EndIf

					FwFormCommit( oModel )
					TAFAltStat( 'T72', " " )  
				EndIf
			EndIf
		
		//Exclusão Manual do Evento
		ElseIf nOperation == MODEL_OPERATION_DELETE	  

			cChvRegAnt := T72->(T72_ID + T72_VERANT)              
												
			TAFAltStat( 'T72', " " )
			FwFormCommit( oModel )				
			
			If T72->T72_EVENTO == "A" .Or. T72->T72_EVENTO == "E"
				TAFRastro( 'T72', 1, cChvRegAnt, .T. , , IIF(Type("oBrw") == "U", Nil, oBrw) )
			EndIf

		EndIf
		
	End Transaction

Return ( lRetorno )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF477Grv
@type			function
@description	Função de gravação para atender o registro S-1295.
@author			Denis R. de Oliveira
@since			16/08/2017
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
Function TAF477Grv( cLayout, nOpc, cFilEv, oXML, cOwner, cFilTran, cPredeces, nTafRecno, cComplem, cGrpTran, cEmpOriGrp, cFilOriGrp, cXmlID )

	Local cCmpsNoUpd   := "|T72_FILIAL|T72_ID|T72_VERSAO|T72_VERANT|T72_PROTUL|T72_PROTPN|T72_EVENTO|T72_STATUS|T72_ATIVO|"
	Local cCabec       := "/eSocial/evtTotConting"
	Local cPeriodo     := ""
	Local cChave       := ""
	Local cInconMsg    := ""
	Local cCodEvent    := Posicione( "C8E", 2, xFilial( "C8E" ) + "S-" + cLayout, "C8E->C8E_ID" )
	Local cLogOpeAnt   := ""
	Local nSeqErrGrv   := 0
	Local nI           := 0
	Local lRet         := .F.
	Local aIncons      := {}
	Local aRules       := {}
	Local aChave       := {}
	Local oModel       := Nil

	Private lVldModel  := .T. //Caso a chamada seja via integração, seto a variável de controle de validação como .T.
	Private oDados     := oXML

	Default cLayout    := "1295"
	Default nOpc       := 1
	Default cFilEv     := ""
	Default oXML       := Nil
	Default cOwner     := ""
	Default cFilTran   := ""
	Default cPredeces  := ""
	Default nTafRecno  := 0
	Default cComplem   := ""
	Default cGrpTran   := ""
	Default cEmpOriGrp := ""
	Default cFilOriGrp := ""
	Default cXmlID     := ""

	//Periodo
	cPeriodo	:= FTafGetVal( cCabec + "/ideEvento/perApur", "C", .F., @aIncons, .F. )

	Aadd( aChave, {"C", "T72_INDAPU", FTafGetVal( cCabec + "/ideEvento/indApuracao", "C", .F., @aIncons, .F. )  , .T.} ) 
	cChave := Padr( aChave[ 1, 3 ], Tamsx3( aChave[ 1, 2 ])[1])
			
	If At("-", cPeriodo) > 0
		Aadd( aChave, {"C", "T72_PERAPU", StrTran(cPeriodo, "-", "" ),.T.} )
		cChave += Padr( aChave[ 2, 3 ], Tamsx3( aChave[ 2, 2 ])[1])	
	Else
		Aadd( aChave, {"C", "T72_PERAPU", cPeriodo  , .T.} ) 
		cChave += Padr( aChave[ 2, 3 ], Tamsx3( aChave[ 2, 2 ])[1])		
	EndIf

	Begin Transaction
		
		//Funcao para validar se a operacao desejada pode ser realizada
		If FTafVldOpe( "T72", 2, @nOpc, cFilEv, @aIncons, aChave, @oModel, "TAFA477", cCmpsNoUpd , , , , )      

			If TafColumnPos( "T72_LOGOPE" )
				cLogOpeAnt := T72->T72_LOGOPE
			endif

			//Carrego array com os campos De/Para de gravacao das informacoes ( Cadastrais )
			aRules := TAF477Rul( cCabec, @cInconMsg, @nSeqErrGrv, @aIncons, cCodEvent, cOwner )			
					
			//Quando se tratar de uma Exclusao direta apenas preciso realizar
			//o Commit(), nao eh necessaria nenhuma manutencao nas informacoes
			If nOpc <> 5
			
				oModel:LoadValue( "MODEL_T72", "T72_FILIAL", T72->T72_FILIAL )

				If TAFColumnPos( "T72_XMLID" )
					oModel:LoadValue( "MODEL_T72", "T72_XMLID", cXmlID )
				EndIf

				//Rodo o aRules para gravar as informacoes
				For nI := 1 to Len( aRules )
					oModel:LoadValue( "MODEL_T72", aRules[ nI, 01 ], FTafGetVal( aRules[ nI, 02 ], aRules[nI, 03], aRules[nI, 04], @aIncons, .F. ) )
				Next nI	

				If Findfunction("TAFAltMan")
					if nOpc == 3
						TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_T72', 'T72_LOGOPE' , '1', '' )
					elseif nOpc == 4
						TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_T72', 'T72_LOGOPE' , '', cLogOpeAnt )
					EndIf
				EndIf
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Efetiva a operacao desejada³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty(aIncons) .And. Empty(aIncons)
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

	//Zerando os arrays e os Objetos utilizados no processamento
	aSize( aRules, 0 )
	aRules := Nil

	aSize( aChave, 0 )
	aChave := Nil

	oModel := Nil

Return { lRet, aIncons }

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF477Rul
Regras para gravacao das informacoes de trabalhador do cadastro dos registros S1295

@Param
aRull  - Regras para a gravacao das informacoes

@Return
aRull - Array com as regras do cadastro para integração

@author Denis R. de Oliveira
@since 16/08/2017
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF477Rul( cCabec, cInconMsg, nSeqErrGrv, aIncons, cCodEvent, cOwner )

	Local aRull        := {}
	Local aInfComp     := {}
	Local cPeriodo     := ""

	Default cCabec     := ""
	Default cInconMsg  := ""
	Default nSeqErrGrv := 0
	Default aIncons    := {}
	Default cCodEvent  := ""
	Default cOwner     := ""

	//**********************************
	//eSocial/evtTotConting/ideEvento/
	//**********************************	
	If TafXNode( oDados, cCodEvent, cOwner, ("/eSocial/evtTotConting/ideEvento/indApuracao") )
		Aadd( aRull, { "T72_INDAPU", cCabec + "/ideEvento/indApuracao", 		"C",  .F. } )		//indApuracao
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner, ("/eSocial/evtTotConting/ideEvento/perApur") )
		cPeriodo 	:= FTafGetVal(cCabec + "/ideEvento/perApur", "C", .F.,, .F. )
		
		If At("-", cPeriodo) > 0
			Aadd( aRull, {"T72_PERAPU", StrTran(cPeriodo, "-", "" ) ,"C",.T.} )	
		Else
			Aadd( aRull, {"T72_PERAPU", cPeriodo ,"C", .T.} )		
		EndIf
	EndIf

	//**********************************
	//eSocial/evtTotConting/ideRespInf/
	//**********************************	
	//Inclui em aInfComp informações que devem ser utilizadas quando for necessario incluir novo contabilista
	Aadd( aInfComp , { 'C2J_NOME' , FTafGetVal( cCabec + "/ideRespInf/nmResp"		, "C", .F., @aIncons, .T.)})
	Aadd( aInfComp , { 'C2J_FONE' , FTafGetVal( cCabec + "/ideRespInf/telefone"	, "C", .F., @aIncons, .T.)})
	Aadd( aInfComp , { 'C2J_EMAIL', FTafGetVal( cCabec + "/ideRespInf/email"		, "C", .F., @aIncons, .F.)})

	If TafXNode( oDados, cCodEvent, cOwner, (cCabec + "/ideRespInf/cpfResp") )	
		Aadd( aRull, { "T72_IDRESP", FGetIdInt( "cpfResp" , "" , cCabec + "/ideRespInf/cpfResp" , , , aInfComp , @cInconMsg , @nSeqErrGrv ) , "C" , .T. } )
	EndIf

Return( aRull )

//-------------------------------------------------------------------	
/*/{Protheus.doc} TAF477Xml
Retorna o Xml do Registro Posicionado 
	
@author Denis R. de Oliveira
@since 16/08/2017
@version 1.0
		
@Param:
lJob - Informa se foi chamado por Job

@return
cXml - Estrutura do Xml do Layout S-1295

/*/
//-------------------------------------------------------------------
Function TAF477Xml(cAlias,nRecno,nOpc,lJob,lAutomato,cFile)

	Local cXml        := ""
	Local cLayout     := "1295"
	Local cReg        := "TotConting"
	Local aMensal     := {}
	Local lXmlVLd     := IIF(FindFunction( 'TafXmlVLD' ),TafXmlVLD( 'TAF477XML' ),.T.)

	Default lJob      := .F.
	Default cAlias    := "T72"
	Default nRecno    := 1
	Default nOpc      := 1
	Default lAutomato := .F.
	Default cFile     := ""

	//ideEvento
	AADD(aMensal,T72->T72_INDAPU)

	If lXmlVLd	

		If Len(Alltrim(T72->T72_PERAPU)) <= 4
			AADD(aMensal,T72->T72_PERAPU)
		Else
			AADD(aMensal,substr(T72->T72_PERAPU, 1, 4) + '-' + substr(T72->T72_PERAPU, 5, 2) )
		EndIf
				
		//ideRespInf		
		C2J->( DbSetOrder( 5 ) )
		If C2J->( MsSeek ( xFilial( "C2J" )+T72->( T72_IDRESP ) ) )
			cXml +=	"<ideRespInf>"
			cXml +=		xTafTag("nmResp" 		, C2J->C2J_NOME , , .F. )
			cXml +=		xTafTag("cpfResp"		, C2J->C2J_CPF , , .F.  )
			cXml +=		xTafTag("telefone"	, AllTrim(C2J->C2J_DDD) + StrTran(C2J->C2J_FONE,"-","") , , .F. )
			cXml +=		xTafTag("email"		, C2J->C2J_EMAIL , , .T. )
			cXml +=	"</ideRespInf>"   
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		// Estrutura do cabecalho³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		cXml := xTafCabXml(cXml,"T72",cLayout,cReg,aMensal)
			
		T72->(DbCloseArea())
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Executa gravacao do registro³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		If !lJob
			If lAutomato
				xTafGerXml( cXml, cLayout,,, .F.,, @cFile )
			Else
				xTafGerXml( cXml, cLayout )
			EndIf
		EndIf

	EndIf

Return(cXml)

//-------------------------------------------------------------------
/*/{Protheus.doc} GerarEvtExc
Funcao que realiza a exclusão do registro e gera o evento S-3000.

@Param  oModel  -> Modelo de dados
@Param  nRecno  -> Numero do recno
@Param  lRotExc -> Variavel que controla se a function é chamada pelo TafIntegraESocial

@Return .T.

@Author Denis R. de Oliveira
@Since 16/08/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function GerarEvtExc( oModel, nRecno, lRotExc  )

	Local cVerAnt    := ""
	Local cProtocolo := ""
	Local cVersao    := ""
	Local cEvento    := ""
	Local nI         := 0
	Local aGrava     := {}
	Local oModelT72  := Nil

	Default oModel   := Nil
	Default nRecno   := 1
	Default lRotExc  := .F.

	Begin Transaction

		//Posiciona o item
		("T72")->( DBGoTo( nRecno ) )
						
		//Carrego a Estrutura dos Models a serem gravados
		oModelT72 := oModel:GetModel( "MODEL_T72" )			
					
		//Guardo as informações do registro corrente para rastro do registro
		cVerAnt     	:= oModelT72:GetValue( "T72_VERSAO" )
		cProtocolo		:= oModelT72:GetValue( "T72_PROTUL" )
		cEvento	  	:= oModelT72:GetValue( "T72_EVENTO" )
		
		//Armazeno as informações correntes do cadastro( Depois da alteração do Usuário )									
		For nI := 1 to Len( oModelT72:aDataModel[ 1 ] )
				Aadd( aGrava, { oModelT72:aDataModel[ 1, nI, 1 ], oModelT72:aDataModel[ 1, nI, 2 ] } )
		Next nI
		
		//---------------------------------------------------------- 
		//Seto o campo como Inativo e gravo a versao do novo registro
		//no registro anterior                                       
		//	          
		//ATENCAO -> A alteracao destes campos deve sempre estar     
		//abaixo do Loop do For, pois devem substituir as informacoes
		//que foram armazenadas no Loop acima 
		//-----------------------------------------------------------/                        
		FAltRegAnt( "T72", "2" )
		
		//----------------------------------------------------------
		//Apos deixar o registro corrente como inativo eu seto a 
		//operação de inclusão para o novo registro
		//-----------------------------------------------------------/
		oModel:DeActivate()
		oModel:SetOperation( 3 )
		oModel:Activate()
		
		//----------------------------------------------------------
		//Neste momento eu realizo a gravação de um novo registro idêntico
		//ao original, apenas com as alterações nos campos modificados
		//pelo usuário no cadastro
		//-----------------------------------------------------------/					
		For nI := 1 to Len( aGrava )
			oModel:LoadValue( "MODEL_T72", aGrava[ nI, 1 ], aGrava[ nI, 2 ] )
		Next nI        
									
		//Busco a nova versao do registro
		cVersao := xFunGetVer()
		
		//---------------------------------------------------------
		//ATENCAO -> A alteracao destes campos deve sempre estar     
		//abaixo do Loop do For, pois devem substituir as informacoes
		//que foram armazenadas no Loop acima                        
		//-----------------------------------------------------------/
		oModel:LoadValue( "MODEL_T72", "T72_VERSAO", cVersao )
		oModel:LoadValue( "MODEL_T72", "T72_VERANT", cVerAnt )
		oModel:LoadValue( "MODEL_T72", "T72_PROTPN", cProtocolo )
		
		//---------------------------------------------------------
		//Tratamento para que caso o Evento Anterior fosse de exclusão
		//seta-se o novo evento como uma "nova inclusão", caso contrário o
		//evento passar a ser uma alteração
		//-----------------------------------------------------------/
		oModel:LoadValue( "MODEL_T72", "T72_EVENTO", "E" )
		oModel:LoadValue( "MODEL_T72", "T72_ATIVO" , "1" )
			
		FwFormCommit( oModel )
		TAFAltStat( 'T72',"6" )
		
	End Transaction

Return ( .T. )
