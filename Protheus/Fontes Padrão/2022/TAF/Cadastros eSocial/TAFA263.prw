#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA263.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA263
Aviso Prévio (S-2250)

@author Anderson Costa
@since 10/09/2013
@version 1.0
/*/ 
//------------------------------------------------------------------
Function TAFA263()

	Local aOnlyFields := {'CM8_FILIAL', 'CM8_ID', 'CM8_DTAVIS', 'CM8_DTRABA', 'CM8_NOMEV', 'CM8_CPFV', 'CM8_NISV', 'CM8_MATV'}

	Private oBrw      := FWmBrowse():New()

	If FindFunction("TAFDesEven")
		TAFDesEven()
	EndIf

	If !ViewEvent('S-2250') .And. FindFunction("FilCpfNome") .And. GetSx3Cache("CM8_CPFV","X3_CONTEXT") == "V" .AND. !FwIsInCallStack("TAFPNFUNC") .AND. !FwIsInCallStack("TAFMONTES")
		
		TafNewBrowse( "S-2250","CM8_DTAVIS",,2, STR0001, aOnlyFields, 3, 2 ) //Aviso Prévio
		
	Else

		// Função que indica se o ambiente é válido para o eSocial 2.3
		If TafAtualizado()
		
			oBrw:SetDescription(STR0001) //Aviso Prévio
			oBrw:SetAlias( 'CM8')
			oBrw:SetMenuDef( 'TAFA263' )
			oBrw:SetCacheView(.F.)
			oBrw:DisableDetails()
		
			If FindFunction('TAFSetFilter')
				oBrw:SetFilterDefault(TAFBrwSetFilter("CM8","TAFA263","S-2250"))
			Else
				oBrw:SetFilterDefault( "CM8_ATIVO == '1'" ) //Filtro para que apenas os registros ativos sejam exibidos ( 1=Ativo, 2=Inativo )
			EndIf
		
			TafLegend(3,"CM8",@oBrw)
			
			oBrw:Activate() 
		
		EndIf
		
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Anderson Costa
@since 10/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aFuncao := {}
	Local aRotina := {} 
	Local aRotAvi := Nil

	If  !ViewEvent('S-2250') .AND. FindFunction("FilCpfNome") .AND. GetSx3Cache("C91_CPFV","X3_CONTEXT") == "V" .AND. !FwIsInCallStack("TAFPNFUNC") .AND. !FwIsInCallStack("TAFMONTES")

		aRotAvi := Array(2,4)

		aRotAvi[1] := {"Retificar / Alterar Evento", "xTafAlt('CM8', 0 , 1)", 0, 4}	
		aRotAvi[2] := {"Cancelar Aviso Prévio"	   , "xTafAlt('CM8', 0 , 3)", 0, 4}

		ADD OPTION aRotina TITLE "Visualizar" ACTION 'VIEWDEF.TAFA263' 	OPERATION 2 ACCESS 0 //'Visualizar'
		ADD OPTION aRotina TITLE "Incluir"    ACTION 'VIEWDEF.TAFA263' 	OPERATION 3 ACCESS 0 //'Incluir'
		ADD OPTION aRotina TITLE "Alterar"    ACTION aRotAvi			OPERATION 4 ACCESS 0 //'Alterar'
		ADD OPTION aRotina TITLE "Imprimir"	  ACTION 'VIEWDEF.TAFA263' 	OPERATION 8 ACCESS 0 //'Imprimir'

	Else

		Aadd( aFuncao, { "" , "TAF263Xml" , "1" } )
			
		//Chamo a Browse do Histórico
		If FindFunction( "xNewHisAlt" ) 
			Aadd( aFuncao, { "" , "xNewHisAlt( 'CM8', 'TAFA263' )" , "3" } )
		Else
			Aadd( aFuncao, { "" , "xFunHisAlt( 'CM8', 'TAFA263' )" , "3" } )
		EndIf
		
		Aadd( aFuncao, { "" , "TAFXmlLote( 'CM8', 'S-2250' , 'evtAvPrevio' , 'TAF263Xml' )" , "5" } )
		Aadd( aFuncao, { "" , "xFunAltRec( 'CM8' )" , "10" } )
		
		lMenuDif := Iif( ValType( "lMenuDif" ) == "U", .F., lMenuDif )
		
		If lMenuDif .Or. ViewEvent('S-2250')
			ADD OPTION aRotina Title "Visualizar" Action 'VIEWDEF.TAFA263' OPERATION 2 ACCESS 0
			
			// Menu dos extemporâneos
			If !ViewEvent('S-2250') .AND. FindFunction( "xNewHisAlt" ) .AND. FindFunction( "xTafExtmp" ) .And. xTafExtmp()
				aRotina	:= xMnuExtmp( "TAFA263", "CM8" )
			EndIf
		Else
			aRotina	:=	xFunMnuTAF( "TAFA263" , , aFuncao, ,STR0002,/*STR0003*/,STR0004) //"Retificar Evento" "Alterar Motivo" "Cancelar Aviso Prévio"
		EndIf

	EndIf

Return( aRotina )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Anderson Costa
@since 10/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oStruCM8   := FWFormStruct( 1, 'CM8' )
	Local oModel     := MPFormModel():New('TAFA263', , , {|oModel| SaveModel(oModel)})

	If Type("cOperEvnt") <> "U"

		If cOperEvnt == '1' .And. CM8->CM8_EVENTO == "I"

			oStrucm8:SetProperty( "CM8_TRABAL",MODEL_FIELD_WHEN,{|| .F. })
			oStrucm8:SetProperty( "CM8_DTCANC",MODEL_FIELD_WHEN,{|| .F. })
			oStrucm8:SetProperty( "CM8_MOTCAN",MODEL_FIELD_WHEN,{|| .F. })

		ElseIf (cOperEvnt == '3' .And. CM8->CM8_STATUS == "4" .And. CM8->CM8_EVENTO <> "F") .Or. (cOperEvnt == '1' .And. CM8->CM8_EVENTO == "F")

			oStrucm8:SetProperty( "CM8_TRABAL",MODEL_FIELD_WHEN,{|| .F. })
			oStrucm8:SetProperty( "CM8_DTAVIS",MODEL_FIELD_WHEN,{|| .F. })
			oStrucm8:SetProperty( "CM8_DTAFAS",MODEL_FIELD_WHEN,{|| .F. })
			oStrucm8:SetProperty( "CM8_TPAVIS",MODEL_FIELD_WHEN,{|| .F. })
			oStrucm8:SetProperty( "CM8_DTCANC",MODEL_FIELD_WHEN,{|| .T. })
			oStrucm8:SetProperty( "CM8_MOTCAN",MODEL_FIELD_WHEN,{|| .T. })

		EndIf

	Else

		oStrucm8:SetProperty( "CM8_DTCANC",MODEL_FIELD_WHEN,{|| .F. })
		oStrucm8:SetProperty( "CM8_MOTCAN",MODEL_FIELD_WHEN,{|| .F. })

	EndIf

	//Remoção do GetSX8Num quando se tratar da Exclusão de um Evento Transmitido.
	//Necessário para não incrementar ID que não será utilizado.
	If Upper( ProcName( 2 ) ) == Upper( "GerarExclusao" )
		oStruCM8:SetProperty( "CM8_ID", MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "" ) )
	EndIf

	oModel:AddFields('MODEL_CM8', /*cOwner*/, oStruCM8)

	oModel:GetModel('MODEL_CM8'):SetPrimaryKey({'CM8_FILIAL', 'CM8_ID', 'CM8_VERSAO'})

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Anderson Costa
@since 10/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel   := FWLoadModel( 'TAFA263' )
	Local oStruCM8 := Nil//FWFormStruct( 2, 'CM8' )
	Local oView    := FWFormView():New()

	Local cCmpFil	:= ""
	Local cGrpTra1 	:= ""
	Local cGrpTra2	:= ""
	Local cGrpTra3	:= ""
	Local aCmpGrp 	:= {}
	Local nI		:= 0

	oView:SetModel( oModel )

	cGrpTra1 := "CM8_TRABAL|CM8_DTRABA|CM8_DTAVIS|CM8_DTAFAS|CM8_TPAVIS|CM8_OBSERV|CM8_DTCANC|CM8_MOTCAN|"

	cGrpTra2 := "CM8_PROTUL|"
	If TafColumnPos("CM8_DTRANS")
		cGrpTra3 := "CM8_DINSIS|CM8_DTRANS|CM8_HTRANS|CM8_DTRECP|CM8_HRRECP|"
	EndIf

	cCmpFil := cGrpTra1 + cGrpTra2 + cGrpTra3

	oStruCM8 := FwFormStruct( 2, "CM8",{ |x| AllTrim( x ) + "|" $ cCmpFil } )

	If FindFunction("TafAjustRecibo")
		TafAjustRecibo(oStruCM8,"CM8")
	EndIf

	If TafColumnPos("CM8_DTRANS")
		oStruCM8:AddGroup( "GRP_TRABALHADOR_01", TafNmFolder("recibo",1), "", 1 ) //Recibo da última Transmissão
		oStruCM8:AddGroup( "GRP_TRABALHADOR_02", TafNmFolder("recibo",2), "", 1 ) //Informações de Controle eSocial

		oStruCM8:SetProperty(Strtran(cGrpTra2,"|",""),MVC_VIEW_GROUP_NUMBER,"GRP_TRABALHADOR_01")
		
		aCmpGrp := StrToKArr(cGrpTra3,"|")
		For nI := 1 to Len(aCmpGrp)
			oStruCM8:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_TRABALHADOR_02")
		Next nI
	EndIf

	oView:AddField( 'VIEW_CM8', oStruCM8, 'MODEL_CM8' )
	oView:EnableTitleView( 'VIEW_CM8', STR0001)     //"Aviso Prévio e Cancelamento de Aviso Prévio"
											
	oView:CreateHorizontalBox( 'FIELDSCM8', 100)  

	oView:SetOwnerView( 'VIEW_CM8', 'FIELDSCM8' )

	xFunRmFStr(oStruCM8, 'CM8')//Retira campos de controle da visualização da tela

	If TafColumnPos( "CM8_LOGOPE" )
		oStruCM8:RemoveField( "CM8_LOGOPE" )
	EndIf

Return oView
//-------------------------------------------------------------------	
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo	

@author Evandro dos Santos Oliveira
@since 25/10/2013
@version 1.0
		
@param  oModel - Modelo de dados
@return .T.
/*/
//-------------------------------------------------------------------
Static Function SaveModel(oModel)

	Local oModelCM8   := Nil
	Local nOperation  := 0
	Local nI          := 0
	Local cLogOpeAnt  := ""
	Local cVerAnt     := ""
	Local cProtocolo  := ""
	Local cVersao     := ""
	Local cEvento     := ""
	Local cChvRegAnt  := ""
	Local aGrava      := {}
	Local lRetorno    := .T.

	Default oModel    := Nil

	oModelCM8	:= oModel:GetModel("MODEL_CM8") 

	nOperation	:= oModel:GetOperation()

	//Controle se o evento é extemporâneo
	lGoExtemp	:= Iif( ValType( "lGoExtemp" ) == "U", .F., lGoExtemp )

	Begin Transaction	
		
		If nOperation == MODEL_OPERATION_INSERT

			TafAjustID( "CM8", oModel)

			oModel:LoadValue( 'MODEL_CM8', 'CM8_VERSAO', xFunGetVer() )

			If Findfunction("TAFAltMan")
				TAFAltMan( 3 , 'Save' , oModel, 'MODEL_CM8', 'CM8_LOGOPE' , '2', '' )
			Endif

			FwFormCommit( oModel )

		ElseIf nOperation == MODEL_OPERATION_UPDATE

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Seek para posicionar no registro antes de realizar as validacoes,³
			//³visto que quando nao esta pocisionado nao eh possivel analisar   ³
			//³os campos nao usados como _STATUS                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			CM8->( DbSetOrder( 4 ) )
			If lGoExtemp .OR. CM8->( MsSeek( xFilial( 'CM8' ) + M->CM8_ID + '1' ) )
				
				If Type("cOperEvnt") <> "U"
					If cOperEvnt == '1'
						cEvento := CM8->CM8_EVENTO
					Else
						cEvento := "F" 
					EndIf
				EndIf

				If CM8->CM8_STATUS == "4" 
				
					oModelCM8 := oModel:GetModel( 'MODEL_CM8' )  
						
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Busco a versao anterior do registro para gravacao do rastro³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cVerAnt   	:= oModelCM8:GetValue( "CM8_VERSAO" )				
					cProtocolo	:= oModelCM8:GetValue( "CM8_PROTUL" )

					If TafColumnPos( "CM8_LOGOPE" )
						cLogOpeAnt := oModelCM8:GetValue( "CM8_LOGOPE" )
					endif

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Neste momento eu gravo as informacoes que foram carregadas    ³
					//³na tela, pois o usuario ja fez as modificacoes que precisava  ³
					//³mesmas estao armazenadas em memoria, ou seja, nao devem ser   ³
					//³consideradas agora.					                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nI := 1 to Len( oModelCM8:aDataModel[ 1 ] )
						Aadd( aGrava, { oModelCM8:aDataModel[ 1, nI, 1 ], oModelCM8:aDataModel[ 1, nI, 2 ] } )
					Next nI 
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Seto o campo como Inativo e gravo a versao do novo registro³
					//³no registro anterior                                       ³ 
					//|                                                           |
					//|ATENCAO -> A alteracao destes campos deve sempre estar     |
					//|abaixo do Loop do For, pois devem substituir as informacoes|
					//|que foram armazenadas no Loop acima                        |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					FAltRegAnt( 'CM8', '2' ) 
						
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
					For nI := 1 To Len( aGrava )	
						oModel:LoadValue( 'MODEL_CM8', aGrava[ nI, 1 ], aGrava[ nI, 2 ] )
					Next

					//Necessário Abaixo do For Nao Retirar
					If Findfunction("TAFAltMan")
						TAFAltMan( 4 , 'Save' , oModel, 'MODEL_CM8', 'CM8_LOGOPE' , '' , cLogOpeAnt )
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Busco a versao que sera gravada³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cVersao := xFunGetVer()	
						
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿		
					//|ATENCAO -> A alteracao destes campos deve sempre estar     |
					//|abaixo do Loop do For, pois devem substituir as informacoes|
					//|que foram armazenadas no Loop acima                        |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		                                                                      				         
					oModel:LoadValue( 'MODEL_CM8', 'CM8_VERSAO', cVersao )
					oModel:LoadValue( 'MODEL_CM8', 'CM8_VERANT', cVerAnt )
					oModel:LoadValue( 'MODEL_CM8', 'CM8_PROTPN', cProtocolo )
					oModel:LoadValue( 'MODEL_CM8', 'CM8_PROTUL', "" )
					
					// Tratamento para limpar o ID unico do xml
					cAliasPai := "CM8"
					If TAFColumnPos( cAliasPai+"_XMLID" )
						oModel:LoadValue( 'MODEL_'+cAliasPai, cAliasPai+'_XMLID', "" )
					EndIf
						
					If nOperation == MODEL_OPERATION_DELETE
						oModel:LoadValue( "MODEL_CM8", "CM8_EVENTO", "E" )
					Else
						If cEvento == "E"
							oModel:LoadValue( "MODEL_CM8", "CM8_EVENTO", "I" )
						ElseIf cEvento == "F"
							oModel:LoadValue( "MODEL_CM8", "CM8_EVENTO", "F" )
						Else
							oModel:LoadValue( "MODEL_CM8", "CM8_EVENTO", "A" )
						EndIf
					EndIf
					
				ElseIf CM8->CM8_STATUS == "2"
					TAFMsgVldOp( oModel, "2" )//"Registro não pode ser alterado. Aguardando processo da transmissão."
					lRetorno := .F.
					
				ElseIf CM8->CM8_STATUS == "6"
					TAFMsgVldOp( oModel, "6" )//"Registro não pode ser alterado. Aguardando processo de transmissão do evento de Exclusão S-3000"
					lRetorno := .F.
								
				ElseIf CM8->CM8_STATUS == "7"
					TAFMsgVldOp( oModel, "7" )//"Registro não pode ser alterado, pois o evento de exclusão já se encontra na base do RET"
					lRetorno := .F.

				Else
					//alteração sem transmissão
					If TafColumnPos( "CM8_LOGOPE" )
						cLogOpeAnt := CM8->CM8_LOGOPE
					endif
				EndIf 
				
				If lRetorno	
					//Gravo alteração para o Extemporâneo
					If lGoExtemp				
						TafGrvExt( oModel, 'MODEL_CM8', 'CM8' )	
					Endif	

					If Findfunction("TAFAltMan")
						TAFAltMan( 4 , 'Save' , oModel, 'MODEL_CM8', 'CM8_LOGOPE' , '' , cLogOpeAnt )
					EndIf

					FwFormCommit( oModel )
					TAFAltStat( "CM8", " " )
				EndIf
				
			EndIf
		
		//Exclusão Manual do Evento
		ElseIf nOperation == MODEL_OPERATION_DELETE	  

			cChvRegAnt := CM8->(CM8_ID + CM8_VERANT)              
											
			If !Empty( cChvRegAnt ) 
				TAFAltStat( 'CM8', " " )
				FwFormCommit( oModel )				
				If nOperation == MODEL_OPERATION_DELETE
					If CM8->CM8_EVENTO == "A" .Or. CM8->CM8_EVENTO == "E"
						TAFRastro( 'CM8', 1, cChvRegAnt, .T., , IIF(Type("oBrw") == "U", Nil, oBrw ) )
					EndIf
				EndIf
			Else
				oModel:DeActivate()
				oModel:SetOperation( 5 ) 	
				oModel:Activate()
				FwFormCommit( oModel )
			EndIf
			
		EndIf 

	End Transaction     

Return ( lRetorno )	

//-------------------------------------------------------------------	
/*/{Protheus.doc} TAF263Xml
Retorna o Xml do Registro Posicionado 
	
@author Evandro dos Santos Oliveira
@since 28/10/2013
@version 1.0
		
@Param:
lJob - Informa se foi chamado por Job
lRemEmp - Exclusivo do Evento S-1000
cSeqXml - Numero sequencial para composição da chave ID do XML

@return
cXml - Estrutura do Xml do Layout S-2250 
/*/
//-------------------------------------------------------------------
Function TAF263Xml(cAlias,nRecno,nOpc,lJob,lRemEmp,cSeqXml)

	Local cXml    	:= ""
	Local cLayout 	:= "2250"
	Local cReg    	:= "AvPrevio"
	Local cNISFunc  := ""
	Local cFilBkp   := cFilAnt
	Local lXmlVLd	:= IIF(FindFunction('TafXmlVLD'),TafXmlVLD('TAF263XML'),.T.)

	Default cAlias 	:= "CM8"
	Default nRecno	:= 1
	Default nOpc	:= 1
	Default lJob 	:= .F.
	Default cSeqXml := ""

	If lXmlVLd

		If IsInCallStack("TafNewBrowse") .And. ( CM8->CM8_FILIAL <> cFilAnt )
			cFilAnt := CM8->CM8_FILIAL
		EndIf

		DBSelectArea("C9V")  
		C9V->(DBSetOrder(2))

		C9V->(MsSeek(xFilial("CM8")+CM8->CM8_TRABAL+"1"))
		cNISFunc := TAF250Nis(C9V->C9V_FILIAL, C9V->C9V_ID, C9V->C9V_NIS, C91->C91_PERAPU,C9V->C9V_NOMEVE)

		If Empty(cNISFunc)
			cNISFunc := C9V->C9V_NIS
		EndIf 

		cXml +=	"<ideVinculo>"    
		cXml +=	   	xTafTag("cpfTrab"	, C9V->C9V_CPF	 )  
		cXml +=		xTafTag("nisTrab"	, cNISFunc		 )
		cXml +=		xTafTag("matricula"	, C9V->C9V_MATRIC)	
		cXml +=	"</ideVinculo>"

		cXml +=		"<infoAvPrevio>"

		If CM8->CM8_EVENTO <> "F"
			
			xTafTagGroup("detAvPrevio",;
						{{ "dtAvPrv"		,CM8->CM8_DTAVIS,,.F. },; 
						 { "dtPrevDeslig"	,CM8->CM8_DTAFAS,,.F. },;
						 { "tpAvPrevio"		,CM8->CM8_TPAVIS,,.F. },;
						 { "observacao"		,CM8->CM8_OBSERV,,.T. }},;
						@cXml )				

		Else

			xTafTagGroup("cancAvPrevio",;
						{{ "dtCancAvPrv"		,CM8->CM8_DTCANC,,.F. },; 
						 { "observacao"			,CM8->CM8_OBSERV,,.T. },;
						 { "mtvCancAvPrevio"	,CM8->CM8_MOTCAN,,.F. }},;
						@cXml )				
			
		EndIf

		cXml +=		"</infoAvPrevio>"
			
		/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Estrutura do cabecalho³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		cXml := xTafCabXml(cXml,"CM8",cLayout,cReg,,cSeqXml)

		/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Executa gravacao do registro³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		If !lJob
			xTafGerXml(cXml,cLayout)
		EndIf

		cFilAnt := cFilBkp

	EndIf
	
Return(cXml)
/*/{Protheus.doc} TAF263GrvGrv
	
@author Evandro dos Santos Oliveira
@since 25/10/2013
@version 1.0
		
@parametros
cLayout - Nome do Layout que esta sendo enviado, existem situacoes onde o mesmo fonte
          alimenta mais de um regsitro do E-Social, para estes casos serao necessarios
          tratamentos de acordo com o layout que esta sendo enviado.
nOpc   -  Opcao a ser realizada ( 3 = Inclusao, 4 = Alteracao, 5 = Exclusao )
cFilEv -  Filial do ERP para onde as informacoes deverao ser importadas
oXML   -  Objeto com as informacoes a serem manutenidas ( Outras Integracoes )  

@Return    
lRet    - Variavel que indica se a importacao foi realizada, ou seja, se as 
		  informacoes foram gravadas no banco de dados
aIncons - Array com as inconsistencias encontradas durante a importacao 
/*/
//-------------------------------------------------------------------
Function TAF263Grv( cLayout, nOpc, cFilEv, oXML, cOwner , cFilTran, cPredeces, nTafRecno, cComplem, cGrpTran, cEmpOriGrp, cFilOriGrp, cXmlID )

	Local cLogOpeAnt   := ""
	Local cCmpsNoUpd   := "|CM8_FILIAL|CM8_ID|CM8_VERSAO|CM8_VERANT|CM8_PROTUL|CM8_PROTPN|CM8_EVENTO|CM8_STATUS|CM8_ATIVO|"
	Local cCabec       := "/eSocial/evtAvPrevio"
	Local cEvento      := ""
	Local cTagRecibo   := cCabec + "/ideEvento/nrRecibo"
	Local cIDFunc      := ""
	Local cInconMsg    := ""
	Local cEvenOrig    := ""
	Local cErro1       := "ERRO18"
	Local cErro2       := "000025"
	Local cCodEvent    := Posicione("C8E",2,xFilial("C8E")+"S-"+cLayout,"C8E->C8E_ID")
	Local nX           := 0
	Local nSeqErrGrv   := 0
	Local nIndChv      := 3
	Local aIncons      := {}
	Local aRules       := {}
	Local aChave       := {}
	Local oModel       := Nil
	Local lRet         := .F.
	Local lTransmit    := .F.
	Local nRecnoCM8    := 0
		
	Private oDados     := Nil
	Private lVldModel  := .T.

	Default cLayout    := ""
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

	oDados 		:= oXML

	If oDados:XPathHasNode( cTagRecibo )
		cIdFunc	:= FGetIdInt( "cpfTrab/Recibo", "matricula/Recibo", cTagRecibo,cTagRecibo,/*lIdChave*/,/*aInfComp*/,@cInconMsg, @nSeqErrGrv,"nrRecibo")
		//cDtAvis	:= Strtran( oDados:XPathGetNodeValue( cTagRecibo ),"-","" )
		//cDtAvis	:= substr(cDtAvis,42)
	Endif

	IF Empty(cIDFunc)
		cIdFunc	:= FGetIdInt( "cpfTrab"	, "matricula", cCabec +"/ideVinculo/cpfTrab", cCabec + "/ideVinculo/matricula",,,@cInconMsg, @nSeqErrGrv)
		//cDtAvis	:= FTafGetVal( cCabec + "/infoAvPrevio/detAvPrevio/dtAvPrv", 'C', .F., @aIncons, .F., '', '' )
		
		//cDtAvis	:= StrTran( cDtAvis, "-", "" )
	Endif

	//Caso ocorra problema alimento o array aincons
	If !empty(cInconMsg)
		Aadd( aIncons, cInconMsg )
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Chave do registro³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd( aChave, { "C", "CM8_TRABAL" , cIdFunc, .T.} ) 

	cChave	:= Padr( cIdFunc, Tamsx3( aChave[ 1, 2 ])[1] ) 

	//Verifica se o evento ja existe na base
	CM8->(DbSetOrder(nIndChv))
		If (CM8->(MsSeek(xFilial("CM8") + cChave + "1"))) 
			While (CM8->(!Eof()) .And. (CM8->CM8_FILIAL + CM8->CM8_TRABAL + CM8->CM8_ATIVO == xFilial("CM8") + cChave + "1")).And.Empty(CM8->CM8_DTCANC)
				nRecnoCM8 := CM8->(Recno())
						
				CM8->(DbSkip())
			Enddo

			CM8->(DbGoTo(nRecnoCM8))

			If !(Empty(nRecnoCM8))
					nOpc := 4
					lTransmit 	:= IIF(CM8->CM8_STATUS == '4',.T.,.F.) 
					cEvenOrig	:= CM8->CM8_EVENTO //Evento Anterior
			Endif
	Endif


	//Caso envie data de cancelamento alterar o nOpc para 1 para ele gerar o registro de cancelamento
	If oDados:XPathHasNode( cCabec +  "/infoAvPrevio/cancAvPrevio/dtCancAvPrv" )
		nOpc := 1
	EndIf

	If nOpc == 4 //Alteração

		If oDados:XPathHasNode( cCabec +  "/infoAvPrevio/detAvPrevio/dtAvPrv" )
			If lTransmit
				cEvento := "R"
			Else		
				If cEvenOrig == "I"
					cEvento := "I"
				Else
					Aadd( aIncons, cErro1 ) //"Não é possível integrar este evento, pois existe um 'Cancelamento' ativo para o Afastamento."   
				EndIf
			EndIf
		Else
			If lTransmit 
				cEvento := "R"
			Else
				If cEvenOrig == "F"
					cEvento := "F"
				Else
					Aadd( aIncons, cErro2 ) //"Não é permitido a integração deste evento, enquanto outro estiver pendente de transmissão."
				EndIf
			EndIf	 					
		EndIf	

	Else

		If oDados:XPathHasNode( cCabec +  "/infoAvPrevio/detAvPrevio/dtAvPrv" ) 
			cEvento := "I"
		Else
			cEvento := "F"
		EndIf

	EndIf	

	If nOpc <> 5
		
		Begin Transaction 
		
			If Empty(aIncons) .And. FTafVldOpe( "CM8", nIndChv, @nOpc, cFilEv, @aIncons, aChave, @oModel, "TAFA263", cCmpsNoUpd )

				If TafColumnPos( "CM8_LOGOPE" )
					cLogOpeAnt := CM8->CM8_LOGOPE
				EndIf

				/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                                                    
				³Carrego array com os campos De/Para de gravacao das informacoes  ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				aRules := TAF263Rul(cCabec, @cInconMsg, @nSeqErrGrv, lTransmit, @oModel, cCodEvent, cOwner )

				oModel:LoadValue( "MODEL_CM8", "CM8_FILIAL", xFilial("CM8") )															
				oModel:LoadValue( "MODEL_CM8", "CM8_EVENTO", cEvento )															

				If TAFColumnPos( "CM8_XMLID" )
					oModel:LoadValue( "MODEL_CM8", "CM8_XMLID", cXmlID )
				EndIf
				
				If (cEvento == "F")
					oModel:LoadValue( "MODEL_CM8", "CM8_DTAVIS",	CM8->CM8_DTAVIS)
					oModel:LoadValue( "MODEL_CM8", "CM8_DTAFAS",	CM8->CM8_DTAFAS)
					oModel:LoadValue( "MODEL_CM8", "CM8_TPAVIS",	CM8->CM8_TPAVIS)
				Endif
								
				/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³Rodo o aRules para gravar as informacoes³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				For nX := 1 To Len( aRules )  
					If	aRules[ nX, 01 ] == "CM8_OBSERV" 
						If	!Empty( FTafGetVal( aRules[ nX, 02 ], aRules[nX, 03], aRules[nX, 04], @aIncons, .F. ) )	           					
							oModel:LoadValue( "MODEL_CM8", aRules[ nX, 01 ], FTafGetVal( aRules[ nX, 02 ], aRules[nX, 03], aRules[nX, 04], @aIncons, .F. ) )
						Else
							If !Empty(CM8->CM8_OBSERV)
								oModel:LoadValue( "MODEL_CM8", "CM8_OBSERV",	CM8->CM8_OBSERV)
							EndIf
						EndIf
					Else
						oModel:LoadValue( "MODEL_CM8", aRules[ nX, 01 ], FTafGetVal( aRules[ nX, 02 ], aRules[nX, 03], aRules[nX, 04], @aIncons, .F. ) )
					EndIf
				Next

				If Findfunction("TAFAltMan")
					If nOpc == 3
						TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_CM8', 'CM8_LOGOPE' , '1', '' )
					ElseIf nOpc == 4
						TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_CM8', 'CM8_LOGOPE' , '', cLogOpeAnt )
					EndIf
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Efetiva a operacao desejada³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Empty(cInconMsg) .And. Empty(aIncons)
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

	//Caso envie data de cancelamento alterar o nOpc para 4 para retornar integração
	If oDados:XPathHasNode( cCabec +  "/infoAvPrevio/cancAvPrevio/dtCancAvPrv" )
		nOpc := 4
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Zerando os arrays e os Objetos utilizados no processamento³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aSize( aRules, 0 )
	aRules := Nil

	aSize( aChave, 0 )
	aChave := Nil

Return { lRet, aIncons } 
//-------------------------------------------------------------------	
/*/{Protheus.doc} TAF263Rul
Regras para gravacao das informacoes do registro S-2250 do E-Social
	
@author Evandro dos Santos Oliveira
@since 25/10/2013
@version 1.0
		
@return
aRull  - Regras para a gravacao das informacoes
/*/
//-------------------------------------------------------------------
Function TAF263Rul( _cCabec, cInconMsg, nSeqErrGrv, lTransmit, oModel, cCodEvent, cOwner )

	Local aRull        := {}

	Default _cCabec    := ""
	Default cInconMsg  := ""
	Default nSeqErrGrv := 0
	Default lTransmit  := .F.
	Default oModel     := Nil
	Default cCodEvent  := ""
	Default cOwner     := ""

	aAdd( aRull, { "CM8_TRABAL", FGetIdInt( "cpfTrab","matricula",_cCabec +"/ideVinculo/cpfTrab",_cCabec + "/ideVinculo/matricula",,,@cInconMsg, @nSeqErrGrv), "C", .T. } ) //Id.Funcionário
	aAdd( aRull, { "CM8_OBSERV", _cCabec +  "/infoAvPrevio/detAvPrevio/observacao"		 	  	, "C", .F. } ) //Observacao
		
	If TafXNode( oDados , cCodEvent, cOwner, ( _cCabec +  "/infoAvPrevio/detAvPrevio/dtAvPrv"  ))
		aAdd( aRull, { "CM8_DTAVIS" 	, _cCabec +  "/infoAvPrevio/detAvPrevio/dtAvPrv"				   		, "D", .F. } ) //Data Aviso
	Endif	

	If TafXNode( oDados , cCodEvent, cOwner, (_cCabec +  "/infoAvPrevio/detAvPrevio/dtPrevDeslig"	))
		aAdd( aRull, { "CM8_DTAFAS" 	, _cCabec +  "/infoAvPrevio/detAvPrevio/dtPrevDeslig"			   	, "D", .F. } ) //Data Afastamento
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (_cCabec +  "/infoAvPrevio/detAvPrevio/tpAvPrevio"	))
		aAdd( aRull, { "CM8_TPAVIS" 	, _cCabec +  "/infoAvPrevio/detAvPrevio/tpAvPrevio"			 	  	, "C", .F. } ) //Tipo de Aviso
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (_cCabec +  "/infoAvPrevio/cancAvPrevio/dtCancAvPrv"))
		aAdd( aRull, { "CM8_DTCANC" 	, _cCabec +  "/infoAvPrevio/cancAvPrevio/dtCancAvPrv"		 	  	, "D", .F. } ) //dtCancAvPrv
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (_cCabec +  "/infoAvPrevio/cancAvPrevio/mtvCancAvPrevio" ))
		aAdd( aRull, { "CM8_MOTCAN" 	, _cCabec +  "/infoAvPrevio/cancAvPrevio/mtvCancAvPrevio" 	  		, "C", .F. } ) //mtvCancAvPrevio
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (_cCabec +  "/infoAvPrevio/cancAvPrevio/observacao" ))
		aAdd( aRull, { "CM8_OBSERV" , _cCabec +  "/infoAvPrevio/cancAvPrevio/observacao" 	  				, "C", .F. } ) //mtvCancAvPrevio
	EndIf

Return(aRull)

//-------------------------------------------------------------------
/*/{Protheus.doc} GerarEvtExc
Funcao que gera a exclusão do evento (S-3000)

@Param  oModel  -> Modelo de dados
@Param  nRecno  -> Numero do recno

@Return .T.

@Author Vitor Henrique Ferreira
@Since 30/06/2015
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function GerarEvtExc( oModel, nRecno, lRotExc )

	Local oModelCM8  := Nil
	Local cVerAnt    := ""
	Local cProtocolo := ""
	Local cVersao    := ""
	Local cEvento    := ""
	Local nI         := 0
	Local aGrava     := {}

	Default oModel   := Nil
	Default nRecno   := 1
	Default lRotExc  := .F.

	oModelCM8	:= oModel:GetModel("MODEL_CM8") 

	//Controle se o evento é extemporâneo
	lGoExtemp	:= Iif( ValType( "lGoExtemp" ) == "U", .F., lGoExtemp )

	dbSelectArea("CM8")
	("CM8")->( DBGoTo( nRecno ) )

	Begin Transaction	
		
		oModelCM8 := oModel:GetModel( 'MODEL_CM8' )  
							
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busco a versao anterior do registro para gravacao do rastro³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cVerAnt   	:= oModelCM8:GetValue( "CM8_VERSAO" )				
		cProtocolo	:= oModelCM8:GetValue( "CM8_PROTUL" )
		cEvento		:= oModelCM8:GetValue( "CM8_EVENTO" )   
							
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Neste momento eu gravo as informacoes que foram carregadas    ³
		//³na tela, pois o usuario ja fez as modificacoes que precisava  ³
		//³mesmas estao armazenadas em memoria, ou seja, nao devem ser   ³
		//³consideradas agora.					                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nI := 1 to Len( oModelCM8:aDataModel[ 1 ] )
			Aadd( aGrava, { oModelCM8:aDataModel[ 1, nI, 1 ], oModelCM8:aDataModel[ 1, nI, 2 ] } )
		Next nI 
					
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Seto o campo como Inativo e gravo a versao do novo registro³
		//³no registro anterior                                       ³ 
		//|                                                           |
		//|ATENCAO -> A alteracao destes campos deve sempre estar     |
		//|abaixo do Loop do For, pois devem substituir as informacoes|
		//|que foram armazenadas no Loop acima                        |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		FAltRegAnt( 'CM8', '2' ) 
							
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
		For nI := 1 To Len( aGrava )	
			oModel:LoadValue( 'MODEL_CM8', aGrava[ nI, 1 ], aGrava[ nI, 2 ] )
		Next        
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busco a versao que sera gravada³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cVersao := xFunGetVer()	
							
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿		
		//|ATENCAO -> A alteracao destes campos deve sempre estar     |
		//|abaixo do Loop do For, pois devem substituir as informacoes|
		//|que foram armazenadas no Loop acima                        |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		                                                                      				         
		oModel:LoadValue( 'MODEL_CM8', 'CM8_VERSAO', cVersao )
		oModel:LoadValue( 'MODEL_CM8', 'CM8_VERANT', cVerAnt )
		oModel:LoadValue( 'MODEL_CM8', 'CM8_PROTPN', cProtocolo )
		oModel:LoadValue( 'MODEL_CM8', 'CM8_PROTUL', "" )
		
		oModel:LoadValue( 'MODEL_CM8', 'CM8_EVENTO', "E" )
		oModel:LoadValue( 'MODEL_CM8', 'CM8_ATIVO', "1" )

		//Gravo alteração para o Extemporâneo
		If lGoExtemp
			TafGrvExt( oModel, 'MODEL_CM8', 'CM8' )	
		EndIf

		FwFormCommit( oModel )
		TAFAltStat( 'CM8',"6" )
					
	End Transaction       

Return .T.

//--------------------------------------------------------------------
/*/{Protheus.doc} SetCssButton

Cria objeto TButton utilizando CSS

@author Eduardo Sukeda
@since 22/03/2019
@version 1.0

@param cTamFonte - Tamanho da Fonte
@param cFontColor - Cor da Fonte
@param cBackColor - Cor de Fundo do Botão
@param cBorderColor - Cor da Borda

@return cCss
/*/
//--------------------------------------------------------------------
Static Function SetCssButton(cTamFonte,cFontColor,cBackColor,cBorderColor)

	Local cCSS := ""

	cCSS := "QPushButton{ background-color: " + cBackColor + "; "
	cCSS += "border: none; "
	cCSS += "font: bold; "
	cCSS += "color: " + cFontColor + ";" 
	cCSS += "padding: 2px 5px;" 
	cCSS += "text-align: center; "
	cCSS += "text-decoration: none; "
	cCSS += "display: inline-block; "
	cCSS += "font-size: " + cTamFonte + "px; "
	cCSS += "border: 1px solid " + cBorderColor + "; "
	cCSS += "border-radius: 3px "
	cCSS += "}"

Return cCSS
