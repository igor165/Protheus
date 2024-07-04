#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA494.CH"
#INCLUDE "TOPCONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA494

Cadastro do Evento R-1000 da Reinf - Informações do Contribuinte.

@author Henrique Pereira
@since 31/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA494()

If TAFAlsInDic( "T9U" ) .and. TAFAlsInDic( "T9W" )
	BrowseDef()
Else
	Aviso( STR0002, TafAmbInvMsg(), { STR0003 }, 3 ) //##"Dicionário Incompativel" ##"Encerrar"
EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Henrique Pereira
@since 31/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao	as array
Local aRotina	as array

aFuncao	:=	{}
aRotina	:=	{}

aAdd( aFuncao, { "", "TAF494Xml", "1" } )
aAdd( aFuncao, { "", "xFunNewHis( 'T9U', 'TAFA494' )", "3" } )
aAdd( aFuncao, { "", "TAFXmlLote( 'T9U', 'R-1000', 'InfoContri', 'TAF494Xml', 5, oBrowse)", "5" } )
aAdd( aFuncao, { "",  "TAF494Exc()"	  , "6" } )
aAdd( aFuncao, { "",  "TAF494Exc(.t.)", "9" } )

lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If lMenuDif
	ADD OPTION aRotina TITLE STR0012 ACTION "VIEWDEF.TAFA494" OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0020 ACTION "TAF494Xml()" OPERATION 2 ACCESS 0 //"Exportar Xml Reinf"
	ADD OPTION aRotina TITLE STR0021 ACTION "TAFXmlLote( 'T9U', 'R-1000', 'InfoContri', 'TAF494Xml', 5, oBrowse)" OPERATION 2 ACCESS 0//"Exportar Xml em Lote"
Else
	aRotina := TAFMenuReinf( "TAFA494", aFuncao )
EndIf

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Henrique Pereira
@since 22/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruT9U	as object
Local oStruT9W	as object
Local oModel		as object

oStruT9U	:=	FWFormStruct( 1, "T9U" )
oStruT9W	:=	FWFormStruct( 1, "T9W" )
oModel		:=	MPFormModel():New( 'TAFA494' , , , {|oModel| SaveModel( oModel ) })

oModel:AddFields( "MODEL_T9U", /*cOwner*/, oStruT9U )
oModel:GetModel( "MODEL_T9U" ):SetPrimaryKey( { "T9U_TPINSC", "T9U_NRINSC" } )

oModel:AddGrid( "MODEL_T9W", "MODEL_T9U", oStruT9W )
oModel:GetModel( "MODEL_T9W" ):SetOptional( .T. )
oModel:GetModel( "MODEL_T9W" ):SetUniqueLine( { "T9W_SHCNPJ" } )

oModel:SetRelation( "MODEL_T9W", { { "T9W_FILIAL", "xFilial('T9W')" }, { "T9W_ID", "T9U_ID" }, { "T9W_VERSAO", "T9U_VERSAO" } }, T9W->( IndexKey( 1 ) ) )

Return( oModel )

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Henrique Pereira
@since 31/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel		as object
Local oView		as object
Local oStruT9Ua	as object
Local oStruT9Ub	as object
Local oStruT9Uc	as object
Local oStruT9Ud	as object
Local oStruT9Ue	as object
Local oStruT9W	as object

oModel		:=	FWLoadModel( "TAFA494" )
oStruT9Ua	:=	Nil
oStruT9Ub	:=	Nil
oStruT9Uc	:=	Nil //Informações de Contato
oStruT9Ud	:=	Nil //Informações de orgãos Públicos Estaduais e Municipais relativas a Ente Federativo Responssável - EFR
oStruT9Ue	:=	Nil
oStruT9W	:=	FWFormStruct( 2, "T9W" ) //Informações da(s) Empresa(s) Desenvolvedora(s) da(s) aplicaçõo(ções) que gera(m) os arquivos transmitidos para o ambiente nacional da EFD-Reinf.

cCmpFil := "T9U_TPINSC|T9U_NRINSC|T9U_DTINI|T9U_DTFIN|"
oStruT9Ua := FWFormStruct( 2, "T9U", { |x| AllTrim( x ) + "|" $ cCmpFil } )

cCmpFil := "T9U_CLAFIS|T9U_CCLAFI|T9U_DCLAFI|T9U_INDECD|T9U_IDCPRB|T9U_INDACR|T9U_INDSPJ|"
oStruT9Ub := FWFormStruct( 2, "T9U", { |x| AllTrim( x ) + "|" $ cCmpFil } )

cCmpFil := "T9U_NOMCTT|T9U_CPFCTT|T9U_FONFIX|T9U_FONCEL|T9U_EMAIL|"
oStruT9Uc := FWFormStruct( 2, "T9U", { |x| AllTrim( x ) + "|" $ cCmpFil } )

cCmpFil := "T9U_INDEFR|T9U_EFRCNP|"
oStruT9Ud := FWFormStruct( 2, "T9U", { |x| AllTrim( x ) + "|" $ cCmpFil } )

cCmpFil := "T9U_PROTUL|"
oStruT9Ue := FWFormStruct( 2, "T9U", { |x| AllTrim( x ) + "|" $ cCmpFil } )

cCmpFil := ""

oView := FWFormView():New()

oView:SetModel( oModel )

oView:AddField( "VIEW_T9Ua", oStruT9Ua, "MODEL_T9U" )
oView:EnableTitleView( "VIEW_T9Ua", STR0004 ) //"Informações de Identificaçõo do Contribuinte"

oView:AddField( "VIEW_T9Ub", oStruT9Ub, "MODEL_T9U" )
oView:EnableTitleView( "VIEW_T9Ub", 'R-1000 ' + STR0001 ) //"Informações do Contribuinte"

oView:AddField( "VIEW_T9Uc", oStruT9Uc, "MODEL_T9U" )
oView:EnableTitleView( "VIEW_T9Uc", STR0005 ) //"Informações de Contato"

oView:AddField( "VIEW_T9Ud", oStruT9Ud, "MODEL_T9U" )
oView:EnableTitleView( "VIEW_T9Ud", STR0006 ) //"Informações da Administração Pública relativas a Ente Federativo Responsável - EFR"

oView:AddField( "VIEW_T9Ue", oStruT9Ue, "MODEL_T9U" )
oView:EnableTitleView( "VIEW_T9Ue", STR0007 ) //"Recibo de Transmissão"

oView:AddGrid( "VIEW_T9W", oStruT9W, "MODEL_T9W" )
oView:EnableTitleView( "VIEW_T9W", STR0008 ) //"Informações da(s) Empresa(s) Desenvolvedora(s) da(s) aplicaçõo(sáes) que gera(m) os arquivos transmitidos para o ambiente nacional da EFD-Reinf."

/*-----------------------------------------------------------------------------------
								Estrutura do Folder
-------------------------------------------------------------------------------------*/

oView:CreateHorizontalBox( "PAINEL_SUPERIOR", 100 )
oView:CreateFolder( "FOLDER_SUPERIOR", "PAINEL_SUPERIOR" )
oView:AddSheet( "FOLDER_SUPERIOR", "ABA01", 'R-1000 ' + STR0001 ) //"Informações do Contribuinte"
oView:AddSheet( "FOLDER_SUPERIOR", "ABA02", STR0007 ) //"Recibo de Transmissão"

oView:CreateHorizontalBox( "FIELDST9Ua", 15,,, "FOLDER_SUPERIOR", "ABA01" )
oView:CreateHorizontalBox( "FIELDST9Ub", 25,,, "FOLDER_SUPERIOR", "ABA01" )
oView:CreateHorizontalBox( "FIELDST9Uc", 20,,, "FOLDER_SUPERIOR", "ABA01" )
oView:CreateHorizontalBox( "FIELDST9Ud", 15,,, "FOLDER_SUPERIOR", "ABA01" )
oView:CreateHorizontalBox( "FIELDST9Ue", 15,,, "FOLDER_SUPERIOR", "ABA02" )
oView:CreateHorizontalBox( "FIELDST9W", 25,,, "FOLDER_SUPERIOR", "ABA01" )

oView:SetOwnerView( "VIEW_T9Ua", "FIELDST9Ua" )
oView:SetOwnerView( "VIEW_T9Ub", "FIELDST9Ub" )
oView:SetOwnerView( "VIEW_T9Uc", "FIELDST9Uc" )
oView:SetOwnerView( "VIEW_T9Ud", "FIELDST9Ud" )
oView:SetOwnerView( "VIEW_T9Ue", "FIELDST9Ue" )
oView:SetOwnerView( "VIEW_T9W", "FIELDST9W" )

xFunRmFStr( @oStruT9Ua, "T9U" )

oStruT9W:RemoveField( "T9W_ID" )
oStruT9W:RemoveField( "T9W_VERSAO" )

Return( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao para validação de gravaçõo do modelo

@Param  oModel -> Modelo de dados

@Return .T.

@Author Roberto Souza
@Since 02/04/2018
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

	Local nOperation 	as numeric
	Local lRetorno		as logical

	nOperation 			:= oModel:GetOperation()
	lRetorno			:= .T.
	
	FWFormCommit( oModel )

Return( lRetorno )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF494Xml
Funcao de geracao do XML para atender o registro S-1010
Quando a rotina for chamada o registro deve estar posicionado

@Param:

@Return:
cXml - Estrutura do Xml do Layout S-1000

@author Leandro Prado
@since 20/09/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF494Xml(cAlias,nRecno,nOpc,lJob, lRemContri, lApi)
Local cXml		:= ""
Local cLayout	:= "1000"
Local cEvento	:= ""
Local cReg		:= "InfoContri"
Local cRegName	:= "InfoContribuinte"
Local cDtIni	:= ""
Local cDtFin	:= ""
Local cId		:= ""
Local cVerAnt	:= ""
Local lLGPDperm := .T.
Local cTpInscr := ""

Default lRemContri := .F.
Default lApi	   := .F.

lLGPDperm := TafFisLGPD( "TAFA494" )

If lLGPDperm .or. lApi

	If T9U->T9U_EVENTO $ "I|A"
		
		cTpinscr := T9U->T9U_TPINSC
		
		If T9U->T9U_EVENTO == "A"
			cEvento := "alteracao"

			cId := T9U->T9U_ID 
			cVerAnt := T9U->T9U_VERANT
			
			BeginSql alias 'T9UTEMP'
				SELECT T9U.T9U_DTINI,T9U.T9U_DTFIN
				FROM %table:T9U% T9U
				WHERE T9U.T9U_FILIAL= %xfilial:T9U% AND
				T9U.T9U_ID = %exp:cId% AND T9U.T9U_VERSAO = %exp:cVerAnt% AND 
				T9U.%notDel%
			EndSql  

			cDtIni := Iif(!Empty(('T9UTEMP')->T9U_DTINI),Substr(('T9UTEMP')->T9U_DTINI,3,4) + "-" + Substr(('T9UTEMP')->T9U_DTINI,1,2),"")
			cDtFin := Iif(!Empty(('T9UTEMP')->T9U_DTFIN),Substr(('T9UTEMP')->T9U_DTFIN,3,4) + "-" + Substr(('T9UTEMP')->T9U_DTFIN,1,2),"")

			('T9UTEMP')->( DbCloseArea() )
			
		Else

			cEvento := "inclusao"
			cDtIni  := Iif(!Empty(T9U->T9U_DTINI),Substr(T9U->T9U_DTINI,3,4) + "-" + Substr(T9U->T9U_DTINI,1,2),"") //Faço o Iif pois se a data estiver vazia a string recebia '-'
			cDtFin  := Iif(!Empty(T9U->T9U_DTFIN),Substr(T9U->T9U_DTFIN,3,4) + "-" + Substr(T9U->T9U_DTFIN,1,2),"")
		EndIf

		cXml +=			"<infoContri>"
		cXml +=				"<" + cEvento + ">"
		cXml +=					"<idePeriodo>"	
		cXml +=						xTafTag("iniValid",cDtIni)
		cXml +=						xTafTag("fimValid",cDtFin,,.T.)		
		cXml +=					"</idePeriodo>"
		cXml +=					"<infoCadastro>"
		If !lRemContri
			cXml +=					xTafTag("classTrib"		 	,T9U->T9U_CCLAFI)
		Else 
			cXml +=					xTafTag("classTrib"		 	,"00")
		EndIf
		cXml +=						xTafTag("indEscrituracao"	,T9U->T9U_INDECD)
		cXml +=						xTafTag("indDesoneracao"	,T9U->T9U_IDCPRB)
		cXml +=						xTafTag("indAcordoIsenMulta",T9U->T9U_INDACR)
		If cTpInscr !='2' //Tag indSitPJ só deve ser enviada para Pessoa Jurídica.
			cXml +=						xTafTag("indSitPJ"			,T9U->T9U_INDSPJ)
		Endif
		cXml +=						"<contato>"
		cXml +=							xTafTag("nmCtt"		,T9U->T9U_NOMCTT)
		cXml +=							xTafTag("cpfCtt"	,T9U->T9U_CPFCTT)
		cXml +=							xTafTag("foneFixo"	,T9U->T9U_FONFIX)
		cXml +=							xTafTag("foneCel"	,T9U->T9U_FONCEL,,.T.)
		cXml +=							xTafTag("email"		,T9U->T9U_EMAIL)	
		cXml +=						"</contato>"

		("T9W")->( DbSetOrder( 1 ) )
		("T9W")->( DbSeek ( xFilial("T9W")+T9U->T9U_ID+T9U->T9U_VERSAO) )
		
		//Laço para geraçõo dos registros filhos
		While T9W->( !Eof()) .And. (xFilial("T9W")+T9U->T9U_ID+T9U->T9U_VERSAO == xFilial("T9W")+T9W->T9W_ID+T9W->T9W_VERSAO)
				
			cXml +=					"<softHouse>"
			cXml +=						xTafTag("cnpjSoftHouse"	,T9W->T9W_SHCNPJ)
			cXml +=						xTafTag("nmRazao"		,T9W->T9W_SHNOME)
			cXml +=						xTafTag("nmCont"		,T9W->T9W_SHCONT)
			cXml +=						xTafTag("telefone"		,T9W->T9W_SHTEL,,.T.)
			cXml +=						xTafTag("email"			,T9W->T9W_EMAIL)
			cXml +=					"</softHouse>"	
			
			T9W->( dbSkip() )
		EndDo

		xTAFTagGroup( "infoEFR"	, {	{ "ideEFR", xFunTrcSN( T9U->T9U_INDEFR, 1 ),, .F. };
								, 	{ "cnpjEFR", T9U->T9U_EFRCNP,, .T. } };
					, @cXml )

		cXml +=					"</infoCadastro>"

		If T9U->T9U_EVENTO == "A" .And. TafAtDtVld("T9U", T9U->T9U_ID, T9U->T9U_DTINI, T9U->T9U_DTFIN, T9U->T9U_VERANT, .T.)		

			cXml +=				"<novaValidade>"		
			cXml +=					TAFGetDtTab(T9U->T9U_DTINI,T9U->T9U_DTFIN)
			cXml +=				"</novaValidade>"     		
		EndIf

		cXml +=				"</" + cEvento + ">"
		cXml +=			"</infoContri>"

	ElseIf T9U->T9U_EVENTO == "E"

		cXml +=			"<infoContri>"
		cXml +=				"<exclusao>"
		cXml +=					"<idePeriodo>"
		cXml += 					TAFGetDtTab(T9U->T9U_DTINI,T9U->T9U_DTFIN)
		cXml +=					"</idePeriodo>"
		cXml +=				"</exclusao>"
		cXml +=			"</infoContri>"
	EndIf

	//Estrutura do cabeçalho
	cXml :=  TAFXmlReinf( cXml, "T9U", cLayout, cReg, SubStr( T9U->T9U_DTINI, 1, 4 ) + "-" + SubStr( T9U->T9U_DTINI, 5, 2 ), , cRegName, lRemContri)

	//Executa gravaçõo do registro
	If !lJob
		xTafGerXml( cXml, cLayout,,,,,, "R-" )
	EndIf
EndIf

Return(cXml)

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF494Exc
Funcao que gera a exclusão do evento

@param lDesfaz - Se .t. desfaz exclusão, sem excluir o evento.

@Return .T.

@author Henrique Pereira	
@since 02/02/2018
@Version 1.0
/*/
//-------------------------------------------------------------------
Function TAF494Exc(lDesfaz)

Local cVerAnt    	as character
Local cProtocolo 	as character
Local cVersao    	as character
Local cChvRegAnt 	as character
Local cEvento	 	as character
Local nlI			as numeric
Local nlY			as numeric
Local nRecno 		as numeric

Local aGrava     	as array
Local oModelT9U  	as object
Local oModel		as object

Default lDesfaz := .f.

cVerAnt   	:= ""
cProtocolo	:= ""
cVersao   	:= ""
cChvRegAnt	:= ""
cEvento	:= ""
cAlias		:= alias()
cProcId	:= ( cAlias )->&( cAlias + "_PROCID" ) 
oModel		:= FWLoadModel( 'TAFA494' ) 

nlI			:= 0
nlY   		:= 0
nRecno 	:= recno()

aGrava    	:= {}
oModelT9U 	:= Nil
Begin Transaction
	if !lDesfaz
		if 	( cAlias )->&( cAlias + '_EVENTO' ) == 'E'
			MsGinfo(STR0022) //Para o evento selecionado use a opcao 'Desfazer Exclusao'.
		elseIf ( cAlias )->&( cAlias + "_STATUS" ) == "4" .And.  ( cAlias )->&( cAlias + "_EVENTO" ) <> "E"
			If ApMsgNoYes(STR0013) //O Evento a ser excluído está transmitido ao governo  e autorizado, o mesmo será desativado e será gerado um novo registro de Exclusão que deverá ser transmitido. Deseja prosseguir?
							
				oModel:SetOperation( 4 )
				oModel:Activate()			
			
				//Posiciona o item
				("T9U")->( DBGoTo( nRecno ) )
			
				oModelT9U := oModel:GetModel( 'MODEL_T9U' )
			
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Busco a versao anterior do registro para gravacao do rastro³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cVerAnt    	:= oModelT9U:GetValue( "T9U_VERSAO" )
				cProtocolo 	:= oModelT9U:GetValue( "T9U_PROTUL" )
				cEvento		:= oModelT9U:GetValue( "T9U_EVENTO" )
			
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Neste momento eu gravo as informacoes que foram carregadas       ³
	//³na tela, pois neste momento o usuario ja fez as modificacoes que ³
	//³precisava e as mesmas estao armazenadas em memoria, ou seja,     ³
	//³nao devem ser consideradas neste momento                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nlI := 1 To 1
					For nlY := 1 To Len( oModelT9U:aDataModel[ nlI ] )
						Aadd( aGrava, { oModelT9U:aDataModel[ nlI, nlY, 1 ], oModelT9U:aDataModel[ nlI, nlY, 2 ] } )
					Next
				Next
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Seto o campo como Inativo e gravo a versao do novo registro³
				//³no registro anterior                                       ³
				//|                                                           |
				//|ATENCAO -> A alteracao destes campos deve sempre estar     |
				//|abaixo do Loop do For, pois devem substituir as informacoes|
				//|que foram armazenadas no Loop acima                        |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
				FAltRegAnt( 'T9U', '2' )
			
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
					oModel:LoadValue( 'MODEL_T9U', aGrava[ nlI, 1 ], aGrava[ nlI, 2 ] )
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
				oModel:LoadValue( 'MODEL_T9U', 'T9U_VERSAO', cVersao )
				oModel:LoadValue( 'MODEL_T9U', 'T9U_VERANT', cVerAnt )
				oModel:LoadValue( 'MODEL_T9U', 'T9U_PROTPN', cProtocolo )
				oModel:LoadValue( 'MODEL_T9U', 'T9U_PROTUL', "" )
			
				/*---------------------------------------------------------
				Tratamento para que caso o Evento Anterior fosse de exclusão
				seta-se o novo evento como uma "nova inclusão", caso contrário o
				evento passará a ser uma alteração
				-----------------------------------------------------------*/
				oModel:LoadValue( "MODEL_T9U", "T9U_EVENTO", "E" )
				oModel:LoadValue( "MODEL_T9U", "T9U_ATIVO" , "1" )
				oModel:LoadValue( "MODEL_T9U", "T9U_XMLID", " "  )

				//Gravo
				FwFormCommit( oModel )

				//Gravo o mesmo _PROCID do registro inativado
				TafEndGRV( "T9U","T9U_PROCID", cProcId, T9U->(Recno())  )
			EndIf
		ElseIf ( cAlias )->&( cAlias + "_EVENTO" ) == "I"
			If ( cAlias )->&( cAlias + "_STATUS" ) $ "2|6"
				Aviso( "Atenção",STR0024, { "Fechar" }, 2 ) //##"Não será possivel realizar a exclusão de um evento que está aguardando o retorno do RET." ##"Fechar"
			Else
				If ApMsgNoYes(STR0014)//O Evento a ser excluído ainda não foi transmitido ao governo, o mesmo será apagado permanentemente da base. Deseja prosseguir?
					cIdDel := T9U->T9U_PROCID
					oModelT9U := oModel:GetModel( 'MODEL_T9U' )
					oModel:SetOperation( MODEL_OPERATION_DELETE )
					oModel:Activate()	

					cQryExc := "SELECT R_E_C_N_O_, C1E_ID FROM "+RetSqlName("C1E")+ " WHERE D_E_L_E_T_ = ' ' AND C1E_PROCID ='"+cIdDel+"'"
					aIdDel := TafQryarr( cQryExc )
					
					For nlI := 1 To Len( aIdDel )
						TafEndGRV( "C1E","C1E_PROCID", "", aIdDel[nlI][01]  )
					Next
					FwFormCommit( oModel )
				EndIf
			EndIf
		ElseIf ( cAlias )->&( cAlias + "_EVENTO" ) == "A"
			If ( cAlias )->&( cAlias + "_STATUS" ) $ "2|6"
				Aviso( "Atenção",STR0024, { "Fechar" }, 2 ) //##"Não será possivel realizar a exclusão de um evento que está aguardando o retorno do RET." ##"Fechar"
			Else
				If ApMsgNoYes(STR0019) // O Evento a ser excluído é um evendo de alteraçõo ainda não transmitido ao governo, o mesmo sera deletado e o registro anterios restaurado. Deseja prosseguir? 
					cIdDel := T9U->T9U_PROCID
					oModelT9U := oModel:GetModel( 'MODEL_T9U' )
					oModel:SetOperation( MODEL_OPERATION_DELETE )
					oModel:Activate()	

					If T9U->(MsSeek(xFilial('T9U')+ oModelT9U:GetValue( "T9U_ID" ) + oModelT9U:GetValue( "T9U_VERANT" )))
						FAltRegAnt( 'T9U', '1' )
						MsGinfo(STR0016) //Registro restaurado!
					EndIf	

					cQryExc := "SELECT R_E_C_N_O_, C1E_ID FROM "+RetSqlName("C1E")+ " WHERE D_E_L_E_T_ = ' ' AND C1E_PROCID ='"+cIdDel+"'"
					aIdDel := TafQryarr( cQryExc )
					
					For nlI := 1 To Len( aIdDel )
						TafEndGRV( "C1E","C1E_PROCID", "", aIdDel[nlI][01]  )
					Next

					FwFormCommit( oModel )

				EndIf
			EndIf
		EndIf
	else
		If ( cAlias )->&( cAlias + "_EVENTO" ) == "E" .And. ( cAlias )->&( cAlias + "_STATUS" ) $ ' |0|1|3'
			If ApMsgNoYes(STR0015) //O Evento a ser excluído é um evento de exclusão ainda não transmitido ao governo, o mesmo será apagado da base e o registro anterior restaurado. Deseja prosseguir?
				oModelT9U := oModel:GetModel( 'MODEL_T9U' )
				oModel:SetOperation( MODEL_OPERATION_DELETE )
				oModel:Activate()	
				FwFormCommit( oModel )
				
				If T9U->(MsSeek(xFilial('T9U')+ oModelT9U:GetValue( "T9U_ID" ) + oModelT9U:GetValue( "T9U_VERANT" )))
					FAltRegAnt( 'T9U', '1' )
					MsGinfo(STR0016) //Registro restaurado!
				EndIf
				
			EndIf		
		ElseIf ( cAlias )->&( cAlias + "_EVENTO" ) == "E" .And. ( cAlias )->&( cAlias + "_STATUS" ) $ '6'
				MsGinfo(STR0017) //O Evento a ser excluído é um evento de exclusão jsá transmitido, porsám ainda não autorizado, a operaçõo desejada não poderá ser concluída antes que o retorno do governo esteja OK.
		ElseIf ( cAlias )->&( cAlias + "_EVENTO" ) == "E" .And. ( cAlias )->&( cAlias + "_STATUS" ) $ '7|4'
				MsGinfo(STR0018) //"O Evento a ser excluído é um evento de exclusão transmitido e autorizado, a operaçõo desejada não poderá ser concluída."
		else
			MsGinfo(STR0023) //Essa opcao deve ser usada somente para eventos de exclusao.
		endif	
	endif	

End Transaction
Return ( .T. )

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse definition

@author Roberto Souza
@since 23/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function BrowseDef()

Private oBrowse	as object 

oBrowse	:=	FWMBrowse():New()

If FunName() == "TAFXREINF"
	lMenuDif := Iif( Type( "lMenuDif" ) == "U", .T., lMenuDif ) 
EndIf

oBrowse:SetDescription( 'R-1000 ' + STR0001 ) //"Informações do Contribuinte"
oBrowse:SetAlias( "T9U" )
oBrowse:SetMenuDef( "TAFA494" )
oBrowse:SetFilterDefault( "T9U_ATIVO == '1'" )

//DbSelectArea("T9U")
//Set Filter TO &("T9U_ATIVO == '1'")

If FindFunction("TAFLegReinf")
	TAFLegReinf( "T9U", oBrowse)
Else
	oBrowse:AddLegend( "T9U_EVENTO == 'I' ", "GREEN"	, STR0009 ) //"Registro Incluído"
	oBrowse:AddLegend( "T9U_EVENTO == 'A' ", "YELLOW"	, STR0010 ) //"Registro Alterado"
	oBrowse:AddLegend( "T9U_EVENTO == 'E' ", "RED"		, STR0011 ) //"Registro excluído"
EndIf

oBrowse:Activate()

Return( oBrowse )



//---------------------------------------------------------------------
/*/{Protheus.doc} TAF494Init
@type			function
@description	Funçõo para atribuiçõo da propriedade de inicializaçõo padrão do campo.
@author			Felipe C. Seolin
@since			08/03/2018
@version		1.0
@return			cInit	-	Conteúdo da inicializaçõo padrão do campo
/*/
//---------------------------------------------------------------------
Function TAF494Init()

Local cCampo	as character
Local cInit	as character

cCampo	:=	SubStr( ReadVar(), At( ">", ReadVar() ) + 1 )
cInit	:=	""

If INCLUI
	If cCampo == "T9U_TPINSC"
		If SM0->M0_TPINSC == 1 //CEI
			cInit := ""
		ElseIf SM0->M0_TPINSC == 2 //CGC/CNPJ
			cInit := "1"
		ElseIf SM0->M0_TPINSC == 3 //CPF
			cInit := "2"
		ElseIf SM0->M0_TPINSC == 4 //INCRA
			cInit := ""
		EndIf
	ElseIf cCampo == "T9U_NRINSC"
		cInit := SM0->M0_CGC
	EndIf
EndIf

Return( cInit )
