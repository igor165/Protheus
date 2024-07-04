#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA469.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA469
Cadastro MVC para atender o evento S-2400 - Cadastro de Benefícios Previdenciários - RPPS

@author denis.oliveira
@since 06/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA469()

Private oBrw := FWmBrowse():New()

//Função que indica se o ambiente é válido para o eSocial 2.3
If TafAtualizado()

	oBrw:SetDescription(STR0001) //"Cadastro de Benefícios Previdenciários - RPPS"
	oBrw:SetAlias("T5T")
	oBrw:SetMenuDef("TAFA469")

	If FindFunction('TAFSetFilter')
		oBrw:SetFilterDefault(TAFBrwSetFilter("T5T","TAFA469","S-2400"))
	Else
		oBrw:SetFilterDefault( "T5T_ATIVO == '1'" ) //Filtro para que apenas os registros ativos sejam exibidos (1 = Ativo, 2 = Inativo)
	EndIf

	oBrw:AddLegend( "T5T_EVENTO == 'I' ", "GREEN" , STR0006 ) //"Registro Incluído"
	oBrw:AddLegend( "T5T_EVENTO == 'A' ", "YELLOW", STR0007 ) //"Registro Alterado"
	oBrw:AddLegend( "T5T_EVENTO == 'E' ", "RED"   , STR0008 ) //"Registro Excluído"
	
	oBrw:Activate()

EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author denis.oliveira
@since 06/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao  
Local aRotina  

aFuncao := {}
aRotina := {}

If FindFunction('TafXmlRet')
	Aadd( aFuncao, { "" , "TafxmlRet('TAF469Xml','2400','T5T')" , "1" } )
Else 
	Aadd( aFuncao, { "" , "TAF469Xml" , "1" } )
EndIf

Aadd( aFuncao, { "" , "xFunHisAlt( 'T5T' , 'TAFA469' )", "3"} )
Aadd( aFuncao, { "" , "TAFXmlLote( 'T5T', 'S-2400' , 'evtCdBenPrRP' , 'TAF469Xml',, oBrw )" , "5" } )
Aadd( aFuncao, { "" , "xFunAltRec( 'T5T' )" , "10" } )

lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If lMenuDif
	ADD OPTION aRotina Title STR0009 Action 'VIEWDEF.TAFA469' OPERATION 2 ACCESS 0 //"Visualizar"
Else
	aRotina	:=	xFunMnuTAF( "TAFA469" , , aFuncao)
EndIf

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author denis.oliveira
@since 06/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruT5T 	 
Local oModel		 

oStruT5T  := FwFormStruct(1,"T5T")
oModel    := MPFormModel():New("TAFA469",,,{|oModel| SaveModel(oModel)})

lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

If lVldModel
	oStruT5T:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
EndIf

//Remoção do GetSX8Num quando se tratar da Exclusão de um Evento Transmitido.
//Necessário para não incrementar ID que não será utilizado.
If Upper( ProcName( 2 ) ) == Upper( "GerarExclusao" )
	oStruT5T:SetProperty( "T5T_ID", MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "" ) )
EndIf

oModel:AddFields("MODEL_T5T",/*cOwner*/,oStruT5T)

oModel:GetModel("MODEL_T5T"):SetPrimaryKey({"T5T_FILIAL","T5T_ID","T5T_VERSAO","T5T_CPF"})
	
Return(oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Funcao generica MVC do View

@return oView - Objeto da View MVC

@author denis.oliveira
@since 06/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel   	:= FwLoadModel("TAFA469")	 
Local oStruT5T	:= Nil	 
Local oStruT5Ta := Nil	 
Local oStruT5Tb := Nil	 
Local oStruT5Tc := Nil	 
Local oStruT5Td := Nil	 
Local oStruT5Te	:= Nil
Local oView		:= FwFormView():New()		 

Local cCmpFil   := ""	 


/*-------------------------------------------
		     Esrutura da View
---------------------------------------------*/
oView:SetModel(oModel)


cCmpFil	:= 'T5T_ID|T5T_VERSAO|T5T_CPF|T5T_NOME|'
oStruT5T	:= FwFormStruct( 2, 'T5T', {|x| AllTrim( x ) + "|" $ cCmpFil } ) //Campos do folder Cabeçalho

cCmpFil	:= 'T5T_DTNASC|T5T_CODPAI|T5T_DCODPA|T5T_CODUF|T5T_DCODUF|T5T_CODMUN|T5T_DCODMU|T5T_PAINAC|T5T_DPAINA|T5T_NOMMAE|T5T_NOMPAI|'
oStruT5Ta	:= FwFormStruct( 2, 'T5T', {|x| AllTrim( x ) + "|" $ cCmpFil } ) //Campos do folder Dados Nascimento

cCmpFil	:= 'T5T_PAIS|T5T_DPAIS|T5T_TPLOGR|T5T_DTPLOG|T5T_LOGRAD|T5T_NRLOG|T5T_COMLOG|T5T_BAIRRO|T5T_UF|T5T_DUF|T5T_MUN|T5T_DMUN|T5T_CEP|T5T_NOMCID|T5T_CXPOST|'
oStruT5Tb	:= FwFormStruct( 2, 'T5T', {|x| AllTrim( x ) + "|" $ cCmpFil } ) //Campos do folder Endereço

cCmpFil	:= 'T5T_TPPLRP|T5T_TPBENE|T5T_DTPBEN|T5T_NUMBEN|T5T_DTINIB|T5T_VLRBEN|T5T_IDQUOT|T5T_CPFINS|T5T_DTFIMB|T5T_MTVFIM|T5T_DMTVFI|'
oStruT5Tc	:= FwFormStruct( 2, 'T5T', {|x| AllTrim( x ) + "|" $ cCmpFil } ) //Campos do folder Informações Beneficio

cCmpFil 	:= 'T5T_PROTUL|'
oStruT5Td	:= FwFormStruct( 2, 'T5T', {|x| AllTrim( x ) + "|" $ cCmpFil } ) //Campos do folder Protocolo de Transmissão

If TafColumnPos("T5T_DTRANS")
	cCmpFil :=	"T5T_DINSIS|T5T_DTRANS|T5T_HTRANS|T5T_DTRECP|T5T_HRRECP|"
	oStruT5Te	:= FwFormStruct( 2, 'T5T', {|x| AllTrim( x ) + "|" $ cCmpFil } )
EndIf

If FindFunction("TafAjustRecibo")
	TafAjustRecibo(oStruT5Td,"T5T")
EndIf

oView:AddField( 'VIEW_T5T' , oStruT5T,  'MODEL_T5T' )
oView:AddField( 'VIEW_T5Ta', oStruT5Ta, 'MODEL_T5T' )
oView:AddField( 'VIEW_T5Tb', oStruT5Tb, 'MODEL_T5T' )
oView:AddField( 'VIEW_T5Tc', oStruT5Tc, 'MODEL_T5T' )
oView:AddField( 'VIEW_T5Td', oStruT5Td, 'MODEL_T5T' )

If TafColumnPos("T5T_PROTUL")
	oView:EnableTitleView( 'VIEW_T5Td', TafNmFolder("recibo",1) ) // "Recibo da última Transmissão"  
EndIf 
If TafColumnPos("T5T_DTRANS")
	oView:AddField( 'VIEW_T5Te', oStruT5Te, 'MODEL_T5T' )
	oView:EnableTitleView( 'VIEW_T5Te', TafNmFolder("recibo",2) )
EndIf

/*-----------------------------------------
		   Estrutura do Folder
-------------------------------------------*/
oView:CreateHorizontalBox( 'MAIN', 100 ) 
oView:CreateFolder("FOLDER_MAIN","MAIN") 

oView:AddSheet("FOLDER_MAIN","ABA01",STR0001)	//"Cadastro de Benefícios Previdenciários - RPPS"
oView:CreateHorizontalBox( 'FIELDSCABEC',30,,,"FOLDER_MAIN","ABA01") //Cabeçalho
oView:CreateHorizontalBox( 'FIELDSABAS' ,70,,,"FOLDER_MAIN","ABA01") //Abas

If FindFunction("TafNmFolder")
	oView:AddSheet('FOLDER_MAIN', "ABA02", TafNmFolder("recibo") )   //"Numero do Recibo"
Else
	oView:AddSheet("FOLDER_MAIN","ABA02" ,STR0012)	//"Protocolo de Transmissão"
EndIf

If TafColumnPos("T5T_DTRANS")
	oView:CreateHorizontalBox( 'FIELDSPROT' ,20,,,"FOLDER_MAIN","ABA02")
	oView:CreateHorizontalBox( 'PAINEL_T5Te' ,80,,,"FOLDER_MAIN","ABA02")
Else
	oView:CreateHorizontalBox( 'FIELDSPROT' ,100,,,"FOLDER_MAIN","ABA02")
EndIf

oView:EnableTitleView("VIEW_T5T", STR0013)	//"Dados do Beneficiário"
//----------------------------------------------------------------------
oView:CreateFolder("FOLDER_ABAS","FIELDSABAS") 

oView:AddSheet("FOLDER_ABAS","ABA01",STR0014)	//"Dados Nascimento"
oView:CreateHorizontalBox("PAINEL_T5Ta",100,,,"FOLDER_ABAS","ABA01")

oView:AddSheet("FOLDER_ABAS","ABA02",STR0015)	//"Endereço"
oView:CreateHorizontalBox("PAINEL_T5Tb",100,,,"FOLDER_ABAS","ABA02")

oView:AddSheet("FOLDER_ABAS","ABA03",STR0016)	//"Informações Benefício"
oView:CreateHorizontalBox("PAINEL_T5Tc",100,,,"FOLDER_ABAS","ABA03")

/*-----------------------------------------
  Amarração para exibição das informações
-------------------------------------------*/
oView:SetOwnerView( 'VIEW_T5T' , 'FIELDSCABEC' )
oView:SetOwnerView( 'VIEW_T5Td', 'FIELDSPROT'  ) 
oView:SetOwnerView( 'VIEW_T5Ta', 'PAINEL_T5Ta' ) 
oView:SetOwnerView( 'VIEW_T5Tb', 'PAINEL_T5Tb' ) 
oView:SetOwnerView( 'VIEW_T5Tc', 'PAINEL_T5Tc' )
If TafColumnPos("T5T_DTRANS")
	oView:SetOwnerView( 'VIEW_T5Te', 'PAINEL_T5Te' )
EndIf

/*-----------------------------------------------------------------------------------
Esconde campos de controle interno
-------------------------------------------------------------------------------------*/
lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If !lMenuDif
	xFunRmFStr(@oStruT5T,"T5T")
EndIf

Return(oView)

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@Param  oModel -> Modelo de dados

@Return .T.

@Author denis.oliveira
@Since 06/08/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

Local cVerAnt		 
Local cProtocolo	 
Local cEvento		 
Local cVersao		 
Local cChvRegAnt	 
Local cLogOpe		 
Local cLogOpeAnt	 

Local nOperation	 
Local nT5T			 

Local aGrava		 
Local oModelT5T	 
Local lRetorno	 

Default oModel	:= Nil

cVerAnt		:= ""
cProtocolo		:= ""
cEvento		:= ""
cVersao		:= ""
cChvRegAnt		:= ""
cLogOpe    	:= ""
cLogOpeAnt 	:= ""

nOperation		:= oModel:GetOperation()
nT5T			:= 0

aGrava			:= {}
oModelT5T		:= Nil
lRetorno		:= .T.

Begin Transaction

	If nOperation == MODEL_OPERATION_INSERT
	
		TafAjustID( "T5T", oModel)
					
		oModel:LoadValue( "MODEL_T5T", "T5T_VERSAO" , xFunGetVer() )

		If Findfunction("TAFAltMan")
			TAFAltMan( 3 , 'Save' , oModel, 'MODEL_T5T', 'T5T_LOGOPE' , '2', '' )
		Endif

		FwFormCommit( oModel )

	ElseIf nOperation == MODEL_OPERATION_UPDATE .or. nOperation == MODEL_OPERATION_DELETE

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Seek para posicionar no registro antes de realizar as validacoes,³
		//³visto que quando nao esta posicionado nao eh possivel analisar   ³
		//³os campos nao usados como _STATUS                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		T5T->( DbSetOrder( 3 ) )
		If T5T->( MsSeek( xFilial( 'T5T' ) + FwFldGet('T5T_ID') + '1' ) )
	    
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se o registro ja foi transmitido³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If T5T->T5T_STATUS == "4"
	
				oModelT5T := oModel:GetModel( "MODEL_T5T" )
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Busco a versao anterior do registro para gravacao do rastro³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cVerAnt    := oModelT5T:GetValue( "T5T_VERSAO" )
				cProtocolo := oModelT5T:GetValue( "T5T_PROTUL" )
				cEvento    := oModelT5T:GetValue( "T5T_EVENTO" )

				If TafColumnPos( "T5T_LOGOPE" )
					cLogOpeAnt := oModelT5T:GetValue( "T5T_LOGOPE" )
				endif

				If nOperation == MODEL_OPERATION_DELETE .And. cEvento == "E"
					// Não é possível excluir um evento de exclusão já transmitido
					TAFMsgVldOp(oModel,"4")
					lRetorno := .F.
				Else
	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Neste momento eu gravo as informacoes que foram carregadas na tela³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nT5T := 1 to Len( oModelT5T:aDataModel[ 1 ] )
						aAdd( aGrava, { oModelT5T:aDataModel[ 1, nT5T, 1 ], oModelT5T:aDataModel[ 1, nT5T, 2 ] } )
					Next nT5T

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Seto o campo como Inativo e gravo a versao do novo registro³
					//³no registro anterior                                       ³
					//|                                                           |
					//|ATENCAO -> A alteracao destes campos deve sempre estar     |
					//|abaixo do Loop do For, pois devem substituir as informacoes|
					//|que foram armazenadas no Loop acima                        |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					FAltRegAnt( 'T5T', '2' )
		
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Neste momento eu preciso setar a operacao do model como Inclusao³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					oModel:DeActivate()
					oModel:SetOperation( 3 )
					oModel:Activate()
			
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Neste momento eu realizo a inclusao do novo registro ja³
					//³contemplando as informacoes alteradas pelo usuario     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nT5T := 1 to Len( aGrava )
						oModel:LoadValue( "MODEL_T5T", aGrava[ nT5T, 1 ], aGrava[ nT5T, 2 ] )
					Next nT5T

					//Necessário Abaixo do For Nao Retirar
					If Findfunction("TAFAltMan")
						TAFAltMan( 4 , 'Save' , oModel, 'MODEL_T5T', 'T5T_LOGOPE' , '' , cLogOpeAnt )
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
					oModel:LoadValue( "MODEL_T5T", "T5T_VERSAO", cVersao )
					oModel:LoadValue( "MODEL_T5T", "T5T_VERANT", cVerAnt )
					oModel:LoadValue( "MODEL_T5T", "T5T_PROTPN", cProtocolo )
					oModel:LoadValue( "MODEL_T5T", "T5T_PROTUL", "" )
					// Tratamento para limpar o ID unico do xml
					cAliasPai := "T5T"
					If TAFColumnPos( cAliasPai+"_XMLID" )
						oModel:LoadValue( 'MODEL_'+cAliasPai, cAliasPai+'_XMLID', "" )
					EndIf
					
					If nOperation == MODEL_OPERATION_DELETE
						oModel:LoadValue( 'MODEL_T5T', 'T5T_EVENTO', "E" )
					ElseIf cEvento == "E"
						oModel:LoadValue( 'MODEL_T5T', 'T5T_EVENTO', "I" )
					Else
						oModel:LoadValue( 'MODEL_T5T', 'T5T_EVENTO', "A" )
					EndIf
					FwFormCommit( oModel )
					
				EndIf
			
			Elseif T5T->T5T_STATUS == "2"
				
				TAFMsgVldOp( oModel, "2" ) //Não é possível alterar um registro com aguardando validação
				lRetorno := .F.
			
			ElseIf T5T->T5T_STATUS == "6"
			
				TAFMsgVldOp( oModel, "6" ) //"Registro não pode ser alterado. Aguardando processo de transmissão do evento de Exclusão S-3000"
				lRetorno := .F.
			
			ElseIf T5T->T5T_STATUS == "7"
			
				TAFMsgVldOp( oModel, "7" ) //"Registro não pode ser alterado, pois o evento de exclusão já se encontra na base do RET"
				lRetorno := .F.
			
			Else

				If TafColumnPos( "T5T_LOGOPE" )
					cLogOpeAnt := T5T->T5T_LOGOPE
				endif

				TAFAltStat( "T5T", " " )

				If nOperation == MODEL_OPERATION_UPDATE .And. Findfunction("TAFAltMan")
					TAFAltMan( 4 , 'Save' , oModel, 'MODEL_T5T', 'T5T_LOGOPE' , '' , cLogOpeAnt )
				EndIf

				FwFormCommit( oModel )

				cChvRegAnt	:=	T5T->( T5T_ID + T5T_VERANT )
				
				If !Empty( cChvRegAnt )
	
				//Caso a operacao seja uma exclusao
			
					If nOperation == MODEL_OPERATION_DELETE
						//Funcao para setar o registro anterior como Ativo
						TAFRastro( "T5T", 1, cChvRegAnt, .T., , IIF(Type ("oBrw") == "U", Nil, oBrw ) )
					EndIf
				EndIf
			EndIf
			
		Else
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Caso o registro nao tenha sido transmitido ainda, gravo sua chave³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cChvRegAnt	:=	T5T->( T5T_ID + T5T_VERANT )
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³No caso de um evento de Exclusao deve-se perguntar ao usuario se ele realmente deseja realizar a exclusao.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If T5T->T5T_EVENTO == "E"
				If nOperation == MODEL_OPERATION_DELETE
					If Aviso( xValStrEr("000754"), xValStrEr("000755"), { xValStrEr("000756"), xValStrEr("000757") }, 1 ) == 2 //##"Registro Excluído" ##"O Evento de exclusão não foi transmitido. Deseja realmente exclui-lo ou manter o evento de exclusão para transmissão posterior ?" ##"Excuir" ##"Manter"
						cChvRegAnt := ""
					EndIf
				Else
					oModel:LoadValue( "MODEL_T5T", "T5T_EVENTO", "A" )
				EndIf
			EndIf
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Executo a operacao escolhida³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty( cChvRegAnt )
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Funcao responsavel por setar o Status do registro para Branco³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				TAFAltStat( "T5T", " " )
				FwFormCommit( oModel )
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Caso a operacao seja uma exclusao...³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nOperation == MODEL_OPERATION_DELETE
					//Funcao para setar o registro anterior como Ativo
					TAFRastro( "T5T", 1, cChvRegAnt, .T., , IIF(Type("oBrw") == "U", Nil, oBrw) )
				EndIf
	
			EndIf
	
		EndIf
			
	EndIf

End Transaction

Return( lRetorno )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF469Grv
Funcao de gravacao para atender o evento S-2400 (Cadastro de Benefícios Previdenciários - RPPS)

@Parametros:
cLayout 	- Nome do Layout que esta sendo enviado, existem situacoes onde o mesmo fonte
           	  alimenta mais de um regsitro do E-Social, para estes casos serao necessarios
              tratamentos de acordo com o layout que esta sendo enviado.
nOpc   		- Opcao a ser realizada ( 3 = Inclusao, 4 = Alteracao, 5 = Exclusao )
cFilEv 		- Filial do ERP, de onde as informacoes deverao ser importadas
oXML   		- Objeto com as informacoes a serem manutenidas ( Outras Integracoes )

@Return
lRet		- Variavel que indica se a importacao foi realizada, ou seja, se as
              informacoes foram gravadas no banco de dados
aIncons	- Array com as inconsistencias encontradas durante a importacao

@author denis.oliveira
@since 06/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAF469Grv( cLayout, nOpc, cFilEv, oXML, cOwner, cFilTran, cPredeces, nTafRecno, cComplem, cGrpTran, cEmpOriGrp, cFilOriGrp, cXmlID )

Local cCabec     	 
Local cCmpsNoUpd 	 
Local cValorXml	 
Local cInconMsg  	 
Local cAlias		 
Local cChave		 
Local cCodEvent  	 
Local cLogOpeAnt 	 

Local nIndChv    	 
Local nIndIDVer  	 
Local nlI        	 
Local nSeqErrGrv 	 

Local lRet       	 

Local aIncons    	 
Local aRules     	 
Local aChave     	 

Local oModel   	 

Private lVldModel	  //Caso a chamada seja via integracao seto a variavel de controle de validacao como .T.
Private oDados   	 

Default cLayout  	:= ""
Default nOpc 	 	:= 1 			
Default cFilEv   	:= ""			
Default oXML	 	:= Nil 	
Default cOwner		:= ""
Default cFilTran	:=	""
Default cPredeces	:=	""
Default nTafRecno	:=	0
Default cComplem	:=	""
Default cGrpTran	:=	""
Default cEmpOriGrp	:=	""
Default cFilOriGrp	:=	""
Default cXmlID		:=	""


cCabec     	:= "/eSocial/evtCdBenPrRP"
cCmpsNoUpd 	:= "|T5T_FILIAL|T5T_ID|T5T_VERSAO|T5T_VERANT|T5T_PROTUL|T5T_PROTPN|T5T_EVENTO|T5T_STATUS|T5T_ATIVO|"
cValorXml		:= ""
cInconMsg  	:= ""
cAlias			:= "T5T"
cChave			:= ""
cCodEvent  	:= Posicione("C8E",2,xFilial("C8E")+"S-"+cLayout,"C8E->C8E_ID")
cLogOpeAnt 	:= ""

nIndChv    	:= 2
nIndIDVer  	:= 1
nlI        	:= 0
nSeqErrGrv 	:= 0

lRet       	:= .F.

aIncons    	:= {}
aRules     	:= {}
aChave     	:= {}

oModel   		:= Nil 

lVldModel		:= .T.
oDados 		:= oXML


Aadd( aChave, { "C", "T5T_CPF", cCabec + "/ideBenef/cpfBenef", .F. } )
	
//Verificar se o codigo foi informado para a chave ( Obrigatorio ser informado )
cChave := FTafGetVal( aChave[1,3], 'C', .F., @aIncons, .F., '', '' )

("T5T")->( DbSetOrder( 2 ) )
If ("T5T")->( MsSeek( xFilial("T5T") + cChave + '1' ) )
	If !T5T->T5T_STATUS $ ( "2|4|6" )
		nOpc := 4
	EndIf
EndIf

Begin Transaction		
									
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Funcao para validar se a operacao desejada pode ser realizada³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If FTafVldOpe( "T5T", nIndChv, @nOpc, cFilEv, @aIncons, aChave, @oModel, "TAFA469", cCmpsNoUpd, nIndIDVer )

		If TafColumnPos( "T5T_LOGOPE" )
			cLogOpeAnt := T5T->T5T_LOGOPE
		endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Quando se tratar de uma Exclusao direta apenas preciso realizar ³
		//³o Commit(), nao eh necessaria nenhuma manutencao nas informacoes³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nOpc <> 5 

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Carrego array com os campos De/Para de gravacao das informacoes³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aRules := TAF469Rul( @cInconMsg, @nSeqErrGrv, @oModel, cCodEvent, cOwner )

		   	oModel:LoadValue( "MODEL_T5T", "T5T_FILIAL", T5T->T5T_FILIAL )

			If TAFColumnPos( "T5T_XMLID" )
				oModel:LoadValue( "MODEL_T5T", "T5T_XMLID", cXmlID )
			EndIf
            			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Rodo o aRules para gravar as informacoes³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nlI := 1 To Len( aRules )                 					
			 	cValorXml := FTafGetVal( aRules[ nlI, 02 ], aRules[nlI, 03], aRules[nlI, 04], @aIncons, .F., , aRules[ nlI, 01 ] )
			 	oModel:LoadValue( "MODEL_T5T", aRules[ nlI, 01 ], cValorXml )
			Next	

			If Findfunction("TAFAltMan")
				if nOpc == 3
					TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_T5T', 'T5T_LOGOPE' , '1', '' )
				elseif nOpc == 4
					TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_T5T', 'T5T_LOGOPE' , '', cLogOpeAnt )
				EndIf
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Zerando os arrays e os Objetos utilizados no processamento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize( aRules, 0 ) 
aRules     := Nil

aSize( aChave, 0 ) 
aChave     := Nil

Return { lRet, aIncons }

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF469Rul
Regras para gravacao das informacoes do registro S-2400 do E-Social

@Param
cTagOper - Tag de indicacao da operacao

@Return
aRull - Regras para a gravacao das informacoes

@author denis.oliveira
@since 06/08/2017
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function TAF469Rul( cInconMsg, nSeqErrGrv, oModel, cCodEvent, cOwner )

Local aRull  
Local cCabec  

Default cInconMsg		:= ""
Default nSeqErrGrv	:= 0
Default oModel		:= Nil
Default cCodEvent		:= ""
Default cOwner		:= ""

aRull  := {}
cCabec := "/eSocial/evtCdBenPrRP"

//-- ideBenef
If TafXNode( oDados , cCodEvent, cOwner, ( cCabec + "/ideBenef/cpfBenef"))
	aAdd( aRull, { "T5T_CPF", cCabec + "/ideBenef/cpfBenef", "C", .F. } ) //cpfBenef
EndIf

If TafXNode( oDados , cCodEvent, cOwner, ( cCabec + "/ideBenef/nmBenefic"))
	aAdd( aRull, { "T5T_NOME", cCabec + "/ideBenef/nmBenefic", "C", .F. } ) //nmBenefic
EndIf

//-- dadosBenef
//dadosNasc
If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/ideBenef/dadosBenef/dadosNasc/dtNascto"))
	aAdd( aRull, { "T5T_DTNASC", cCabec + "/ideBenef/dadosBenef/dadosNasc/dtNascto", "D", .F. } ) //dtNascto
EndIf

If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/ideBenef/dadosBenef/dadosNasc/uf")) .OR. TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/ideBenef/dadosBenef/dadosNasc/codMunic")) 
	aAdd( aRull, { "T5T_CODMUN", FGetIdInt( "uf", "codMunic", cCabec + "/ideBenef/dadosBenef/dadosNasc/uf",;
	                                        cCabec + "/ideBenef/dadosBenef/dadosNasc/codMunic",,,@cInconMsg, @nSeqErrGrv ), "C", .T.} ) //codMunic	
EndIf

If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/ideBenef/dadosBenef/dadosNasc/uf"))
	aAdd( aRull, { "T5T_CODUF", FGetIdInt( "uf", "",cCabec + "/ideBenef/dadosBenef/dadosNasc/uf",,,,@cInconMsg, @nSeqErrGrv), "C", .T. } ) //uf
EndIf

If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/ideBenef/dadosBenef/dadosNasc/paisNascto"))
	aAdd( aRull, { "T5T_CODPAI", FGetIdInt( "paisNascto", "", cCabec + "/ideBenef/dadosBenef/dadosNasc/paisNascto",,,,@cInconMsg, @nSeqErrGrv), "C", .T.} ) //paisNascto
EndIf

If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/ideBenef/dadosBenef/dadosNasc/paisNac"))
	aAdd( aRull, { "T5T_PAINAC", FGetIdInt( "paisNac", "", cCabec + "/ideBenef/dadosBenef/dadosNasc/paisNac",,,,@cInconMsg, @nSeqErrGrv), "C", .T.} ) //paisNac
EndIf

If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/ideBenef/dadosBenef/dadosNasc/nmMae"))
	aAdd( aRull, { "T5T_NOMMAE", cCabec + "/ideBenef/dadosBenef/dadosNasc/nmMae", "C", .F. } ) //nmMae
EndIf

If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/ideBenef/dadosBenef/dadosNasc/nmPai"))
	aAdd( aRull, { "T5T_NOMPAI", cCabec + "/ideBenef/dadosBenef/dadosNasc/nmPai", "C", .F. } ) //nmPai
EndIf		

//-- endereco
//brasil
If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/ideBenef/dadosBenef/endereco/brasil/tpLograd"))
	aAdd( aRull, { "T5T_TPLOGR", FGetIdInt( "tpLograd", "", cCabec + "/ideBenef/dadosBenef/endereco/brasil/tpLograd",,,,@cInconMsg, @nSeqErrGrv ), "C", .T. } ) //tpLograd"
	oModel:LoadValue( "MODEL_T5T", "T5T_PAIS", "000001" ) //Gravo o país como Brasil
EndIf	

If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/ideBenef/dadosBenef/endereco/brasil/dscLograd"))
	aAdd( aRull, { "T5T_LOGRAD", cCabec + "/ideBenef/dadosBenef/endereco/brasil/dscLograd", "C", .F. } ) //dscLograd
EndIf	

If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/ideBenef/dadosBenef/endereco/brasil/nrLograd"))
	aAdd( aRull, { "T5T_NRLOG", cCabec + "/ideBenef/dadosBenef/endereco/brasil/nrLograd", "C", .F. } ) //nrLograd
EndIf	

If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/ideBenef/dadosBenef/endereco/brasil/complemento"))
	aAdd( aRull, { "T5T_COMLOG", cCabec + "/ideBenef/dadosBenef/endereco/brasil/complemento", "C", .F. } ) //complemento
EndIf	

If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/ideBenef/dadosBenef/endereco/brasil/bairro"))
	aAdd( aRull, { "T5T_BAIRRO", cCabec + "/ideBenef/dadosBenef/endereco/brasil/bairro", "C", .F. } ) //bairro
EndIf	

If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/ideBenef/dadosBenef/endereco/brasil/cep"))
	aAdd( aRull, { "T5T_CEP", cCabec + "/ideBenef/dadosBenef/endereco/brasil/cep", "C", .F. } ) //cep
EndIf	

If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/ideBenef/dadosBenef/endereco/brasil/uf")) .OR. TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/ideBenef/dadosBenef/endereco/brasil/codMunic"))	
	aAdd( aRull, { "T5T_MUN", FGetIdInt( "uf", "codMunic", cCabec + "/ideBenef/dadosBenef/endereco/brasil/uf",;
	                                        cCabec + "/ideBenef/dadosBenef/endereco/brasil/codMunic",,,@cInconMsg, @nSeqErrGrv ), "C", .T.} ) //codMunic
EndIf	

If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/ideBenef/dadosBenef/endereco/brasil/uf"))
	aAdd( aRull, { "T5T_UF", FGetIdInt( "uf", "",cCabec + "/ideBenef/dadosBenef/endereco/brasil/uf",,,,@cInconMsg, @nSeqErrGrv), "C", .T. } ) //uf
EndIf	 

//exterior
If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/ideBenef/dadosBenef/endereco/exterior/paisResid"))
	aAdd( aRull, { "T5T_PAIS", FGetIdInt( "paisResid", "", cCabec + "/ideBenef/dadosBenef/endereco/exterior/paisResid",,,,@cInconMsg, @nSeqErrGrv), "C", .T.} ) //paisResid
EndIf	

If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/ideBenef/dadosBenef/endereco/exterior/dscLograd"))
	aAdd( aRull, { "T5T_LOGRAD", cCabec + "/ideBenef/dadosBenef/endereco/exterior/dscLograd", "C", .F. } ) //dscLograd
EndIf	

If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/ideBenef/dadosBenef/endereco/exterior/nrLograd"))
	aAdd( aRull, { "T5T_NRLOG" , cCabec + "/ideBenef/dadosBenef/endereco/exterior/nrLograd", "C", .F. } ) //nrLograd
EndIf

If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/ideBenef/dadosBenef/endereco/exterior/complemento"))
	aAdd( aRull, { "T5T_COMLOG", cCabec + "/ideBenef/dadosBenef/endereco/exterior/complemento", "C", .F. } ) //complemento
EndIf

If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/ideBenef/dadosBenef/endereco/exterior/bairro"))
	aAdd( aRull, { "T5T_BAIRRO", cCabec + "/ideBenef/dadosBenef/endereco/exterior/bairro", "C", .F. } ) //bairro
EndIf

If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/ideBenef/dadosBenef/endereco/exterior/nmCid"))
	aAdd( aRull, { "T5T_NOMCID", cCabec + "/ideBenef/dadosBenef/endereco/exterior/nmCid", "C", .F. } ) //nmCid
EndIf

If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/ideBenef/dadosBenef/endereco/exterior/codPostal"))
	aAdd( aRull, { "T5T_CXPOST", cCabec + "/ideBenef/dadosBenef/endereco/exterior/codPostal", "C", .F. } ) //codPostal
EndIf

//-- infoBeneficio
If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/infoBeneficio/tpPlanRP"))
	aAdd( aRull, { "T5T_TPPLRP", cCabec + "/infoBeneficio/tpPlanRP", "C", .F. } ) //tpPlanRP
EndIf

//-- iniBeneficio
If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/infoBeneficio/iniBeneficio/tpBenef"))
	aAdd( aRull, { "T5T_TPBENE", FGetIdInt( "tpBenef", "", cCabec + "/infoBeneficio/iniBeneficio/tpBenef",,,,@cInconMsg, @nSeqErrGrv),"C", .T.} ) //tpBenef
EndIf

If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/infoBeneficio/iniBeneficio/nrBenefic"))
	aAdd( aRull, { "T5T_NUMBEN", cCabec + "/infoBeneficio/iniBeneficio/nrBenefic", "C", .F. } ) //nrBenefic
EndIf

If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/infoBeneficio/iniBeneficio/dtIniBenef"))
	aAdd( aRull, { "T5T_DTINIB", cCabec + "/infoBeneficio/iniBeneficio/dtIniBenef", "D", .F. } ) //dtIniBenef
EndIf

If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/infoBeneficio/iniBeneficio/vrBenef"))
	aAdd( aRull, { "T5T_VLRBEN", cCabec + "/infoBeneficio/iniBeneficio/vrBenef", "N", .F. } ) //vrBenef
EndIf

//-- infoPenMorte
If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/infoBeneficio/iniBeneficio/infoPenMorte/idQuota"))
	aAdd( aRull, { "T5T_IDQUOT", cCabec + "/infoBeneficio/iniBeneficio/infoPenMorte/idQuota", "C", .F. } ) //idQuota
EndIf

If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/infoBeneficio/iniBeneficio/infoPenMorte/cpfInst"))
	aAdd( aRull, { "T5T_CPFINS", cCabec + "/infoBeneficio/iniBeneficio/infoPenMorte/cpfInst", "C", .F. } ) //cpfInst
EndIf

//-- altBeneficio
If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/infoBeneficio/altBeneficio/tpBenef"))
	aAdd( aRull, { "T5T_TPBENE", FGetIdInt( "tpBenef", "", cCabec + "/infoBeneficio/altBeneficio/tpBenef",,,,@cInconMsg, @nSeqErrGrv), "C", .T.} ) //tpBenef
EndIf

If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/infoBeneficio/altBeneficio/nrBenefic"))
	aAdd( aRull, { "T5T_NUMBEN", cCabec + "/infoBeneficio/altBeneficio/nrBenefic", "C", .F. } ) //nrBenefic
EndIf

If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/infoBeneficio/altBeneficio/dtIniBenef"))
	aAdd( aRull, { "T5T_DTINIB", cCabec + "/infoBeneficio/altBeneficio/dtIniBenef", "D", .F. } ) //dtIniBenef
EndIf

If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/infoBeneficio/altBeneficio/vrBenef"))
	aAdd( aRull, { "T5T_VLRBEN", cCabec + "/infoBeneficio/altBeneficio/vrBenef", "N", .F. } ) //vrBenef
EndIf

//-- infoPenMorte
If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/infoBeneficio/altBeneficio/infoPenMorte/idQuota"))
	aAdd( aRull, { "T5T_IDQUOT", cCabec + "/infoBeneficio/altBeneficio/infoPenMorte/idQuota", "C", .F. } ) //idQuota
EndIf

If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/infoBeneficio/altBeneficio/infoPenMorte/cpfInst"))	
	aAdd( aRull, { "T5T_CPFINS", cCabec + "/infoBeneficio/altBeneficio/infoPenMorte/cpfInst", "C", .F. } ) //cpfInst
EndIf

//-- fimBeneficio
If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/infoBeneficio/fimBeneficio/tpBenef"))
	aAdd( aRull, { "T5T_TPBENE", FGetIdInt( "tpBenef", "", cCabec + "/infoBeneficio/fimBeneficio/tpBenef",,,,@cInconMsg, @nSeqErrGrv), "C", .T.} ) //tpBenef
EndIf

If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/infoBeneficio/fimBeneficio/nrBenefic"))
	aAdd( aRull, { "T5T_NUMBEN", cCabec + "/infoBeneficio/fimBeneficio/nrBenefic", "C", .F. } ) //nrBenefic
EndIf

If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/infoBeneficio/fimBeneficio/dtFimBenef"))
	aAdd( aRull, { "T5T_DTFIMB", cCabec + "/infoBeneficio/fimBeneficio/dtFimBenef", "D", .F. } ) //dtIniBenef
EndIf

If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/infoBeneficio/fimBeneficio/mtvFim"))
	aAdd( aRull, { "T5T_MTVFIM", FGetIdInt( "mtvFim", "", cCabec + "/infoBeneficio/fimBeneficio/mtvFim",,,,@cInconMsg, @nSeqErrGrv), "C", .T.} ) //mtvFim
EndIf


Return( aRull )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF469Xml
Funcao de geracao do XML para atender o registro S-2400
Quando a rotina for chamada o registro deve estar posicionado

@Param:
cAlias - Alias da Tabela
nRecno - Recno do Registro corrente
nOpc   - Operacao a ser realizada
lJob   - Informa se foi chamado por Job
lRemEmp - Exclusivo do Evento S-1000
cSeqXml - Numero sequencial para composição da chave ID do XML

@Return:
cXml - Estrutura do Xml do Layout S-2400

@author denis.oliveira
@since 06/08/2017
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF469Xml(cAlias,nRecno,nOpc,lJob,lRemEmp,cSeqXml)

Local cXml     	 
Local cLayout  	 
Local cReg     	 
Local cXmlPenMor	 
Local cId      	 
Local cVerAnt  

Local aAreaT5T 	 
Local lXmlVLd	:= IIF(FindFunction('TafXmlVLD'),TafXmlVLD('TAF469XML'),.T.)

Default cAlias	:= ""
Default nRecno	:= 0
Default nOpc	:= 1
Default lJob	:= .F.
Default cSeqXml := ""

cXml     	:= ""
cLayout  	:= "2400"
cReg     	:= "CdBenPrRP"
cXmlPenMor	:= ""
cId      	:= ""
cVerAnt  	:= ""

aAreaT5T 	:= {}

//-- Abro as tabelas
DBSelectArea( "C09" )
C09->( DBSetOrder( 3 ))

DBSelectArea( "C08" )
C08->( DBSetOrder( 3 ))

DBSelectArea( "C07" )
C07->(DBSetOrder( 3 ))

DBSelectArea( "C06" )
C06->( DBSetOrder( 3 ))

DBSelectArea( "T5G" )
T5G->( DBSetOrder( 1 ))

DBSelectArea( "T5H" )
T5H->(DBSetOrder( 1 ))


If lXmlVLd
	//*******************
	//-- ideBenef
	//*******************
	cXml +=	"<ideBenef>"
	cXml +=		xTafTag("cpfBenef"	,T5T->T5T_CPF)
	cXml +=		xTafTag("nmBenefic"	,T5T->T5T_NOME)
	//*******************
	//-- dadosBenef
	//*******************
	cXml +=		"<dadosBenef>"
	//*******************
	//-- dadosNasc
	//*******************
	cXml +=			"<dadosNasc>"
	cXml +=				xTafTag("dtNascto" 	,T5T->T5T_DTNASC)
	cXml +=				xTafTag("codMunic"	,Posicione("C09",3,xFilial("C09")+T5T->T5T_CODUF,"C09_CODIGO") + Posicione("C07",3, xFilial("C07")+T5T->T5T_CODMUN,"C07_CODIGO"),,.T.)
	cXml +=				xTafTag("uf" 			,Posicione("C09",3,xFilial("C09")+T5T->T5T_CODUF,"C09_UF"),,.T.)
	cXml +=				xTafTag("paisNascto"	,Posicione("C08",3,xFilial("C08")+T5T->T5T_CODPAI,"C08_PAISSX"))
	cXml +=				xTafTag("paisNac" 	,Posicione("C08",3,xFilial("C08")+T5T->T5T_PAINAC,"C08_PAISSX"))
	cXml +=				xTafTag("nmMae"		,T5T->T5T_NOMMAE,,.T.)
	cXml +=				xTafTag("nmPai" 		,T5T->T5T_NOMPAI,,.T.)
	cXml +=			"</dadosNasc>"
	//*******************
	//-- endereco
	//*******************
	cXml +=			"<endereco>"

	//-- Busca o País 
	cPais := Posicione("C08",3,xFilial("C08")+T5T->T5T_PAIS, "C08_PAISSX")

	If !Empty(cPais)
		
		If Alltrim(cPais) == "105"
		
		//*******************
		// brasil
		//*******************
			cXml +=			"<brasil>"
			cXml +=				xTafTag("tpLograd" 	,Posicione("C06",3,xFilial("C06")+T5T->T5T_TPLOGR,"C06_CESOCI"))
			cXml +=				xTafTag("dscLograd"	,T5T->T5T_LOGRAD) 
			cXml +=				xTafTag("nrLograd"	,T5T->T5T_NRLOG)
			cXml +=				xTafTag("complemento",T5T->T5T_COMLOG,,.T.)
			cXml +=				xTafTag("bairro" 		,T5T->T5T_BAIRRO,,.T.)
			cXml +=				xTafTag("cep"			,T5T->T5T_CEP)
			cXml +=				xTafTag("codMunic"	,Posicione("C09",3,xFilial("C09")+T5T->T5T_UF,"C09_CODIGO") + Posicione("C07",3, xFilial("C07")+T5T->T5T_MUN,"C07_CODIGO"))
			cXml +=				xTafTag("uf"			,Posicione("C09",3,xFilial("C09")+T5T->T5T_UF,"C09_UF"))
			cXml +=			"</brasil>"
		Else
		//*******************
		// exterior
		//*******************
			cXml +=			"<exterior>"
			cXml +=				xTafTag("paisResid" 	,Posicione("C08",3,xFilial("C08")+T5T->T5T_PAIS,"C08_PAISSX"))
			cXml +=				xTafTag("dscLograd"	,T5T->T5T_LOGRAD)
			cXml +=				xTafTag("nrLograd"	,T5T->T5T_NRLOG)
			cXml +=				xTafTag("complemento",T5T->T5T_COMLOG,,.T.)
			cXml +=				xTafTag("bairro"	 	,T5T->T5T_BAIRRO,,.T.)
			cXml +=				xTafTag("nmCid"		,T5T->T5T_NOMCID)
			cXml +=				xTafTag("codPostal"	,T5T->T5T_CXPOST,,.T.)
			cXml +=			"</exterior>"
		EndIf

	EndIf

	cXml +=					"</endereco>"

	cXml +=				"</dadosBenef>"

	cXml +=			"</ideBenef>"
	//*******************
	//-- infoBeneficio
	//*******************
	cXml +=			"<infoBeneficio>"
	cXml +=				xTafTag("tpPlanRP"	,T5T->T5T_TPPLRP)

	If T5T->T5T_EVENTO == "I"
		
		xTafTagGroup("infoPenMorte"	, {{"idQuota",T5T->T5T_IDQUOT,,.F.};
										,  {"cpfInst",T5T->T5T_CPFINS,,.F.}};
										, @cXmlPenMor)
		
		xTafTagGroup("iniBeneficio"	,{{"tpBenef",   Posicione("T5G",1,xFilial("T5G")+T5T->T5T_TPBENE,"T5G_CODIGO"),,.F.};
										, {"nrBenefic", T5T->T5T_NUMBEN,,.F.};
										, {"dtIniBenef",T5T->T5T_DTINIB,,.F.};
										, {"vrBenef",	  T5T->T5T_VLRBEN,,.F.}};
										, @cXml, {{"infoPenMorte",cXmlPenMor,0}})


	ElseIf T5T->T5T_EVENTO == "A" .AND. ( Empty(T5T->T5T_DTFIMB) .OR. Empty(T5T->T5T_MTVFIM) )

			
		xTafTagGroup("infoPenMorte"	, {{"idQuota",T5T->T5T_IDQUOT,,.F.};
										,  {"cpfInst",T5T->T5T_CPFINS,,.F.}};
										, @cXmlPenMor)
		
		xTafTagGroup("altBeneficio"	,{{"tpBenef",   Posicione("T5G",1,xFilial("T5G")+T5T->T5T_TPBENE,"T5G_CODIGO"),,.F.};
										, {"nrBenefic", T5T->T5T_NUMBEN,,.F.};
										, {"dtIniBenef",T5T->T5T_DTINIB,,.F.};
										, {"vrBenef",	  T5T->T5T_VLRBEN,,.F.}};
										, @cXml, {{"infoPenMorte",cXmlPenMor,0}})
			
		
	Else
		
		xTafTagGroup("fimBeneficio"	,{{"tpBenef",   Posicione("T5G",1,xFilial("T5G")+T5T->T5T_TPBENE,"T5G_CODIGO"),,.F.};
										, {"nrBenefic", T5T->T5T_NUMBEN,,.F.};
										, {"dtFimBenef",T5T->T5T_DTFIMB,,.F.};
										, {"mtvFim",	  Posicione("T5H",1,xFilial("T5H")+T5T->T5T_MTVFIM,"T5H_CODIGO"),,.F.}};
										, @cXml )
	EndIf

	cXml +=			"</infoBeneficio>"


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Estrutura do cabecalho³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cXml := xTafCabXml(cXml,"T5T",cLayout,cReg,,cSeqXml)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa gravacao do registro³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lJob
		xTafGerXml(cXml,cLayout)
	EndIf
EndIf
Return(cXml)


//-------------------------------------------------------------------
/*/{Protheus.doc} GerarEvtExc
Funcao que gera a exclusão do evento (S-3000)

@Param  oModel  -> Modelo de dados
@Param  nRecno  -> Numero do recno
@Param  lRotExc -> Variavel que controla se a function é chamada pelo TafIntegraESocial

@Return .T.

@author denis.oliveira
@since 06/08/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function GerarEvtExc( oModel, nRecno, lRotExc )

Local cVerAnt    	  
Local cProtocolo 	 
Local cVersao    	 
Local cEvento	 	 
Local cId		 	 

Local nlY        	 
Local nlI			 

Local aCampos    	 
Local aGrava     	 
Local aGravaT5T  	 

Local oModelT5T  	 

Local lRetorno	 

Default oModel	:= Nil
Default nRecno	:= 0
Default lRotExc	:= .F.

cVerAnt   	:= ""
cProtocolo	:= ""
cVersao   	:= ""
cEvento	:= ""
cId		 	:= ""

nlY       	:= 0
nlI			:= 0

aCampos	:= {}
aGrava		:= {}
aGravaT5T	:= {}

oModelT5T 	:= Nil

lRetorno	:= .T.

Begin Transaction

	//Posiciona o item
	("T5T")->( DBGoTo( nRecno ) )
	
	oModelT5T := oModel:GetModel( 'MODEL_T5T' )       
										
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Busco a versao anterior do registro para gravacao do rastro³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cVerAnt   	:= oModelT5T:GetValue( "T5T_VERSAO" )				
	cProtocolo	:= oModelT5T:GetValue( "T5T_PROTUL" )
	cEvento	:= oModelT5T:GetValue( "T5T_EVENTO" )		
	
	       		        						
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Neste momento eu gravo as informacoes que foram carregadas       ³
	//³na tela, pois neste momento o usuario ja fez as modificacoes que ³
	//³precisava e as mesmas estao armazenadas em memoria, ou seja,     ³
	//³nao devem ser consideradas neste momento                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nlI := 1 To 1
		For nlY := 1 To Len( oModelT5T:aDataModel[ nlI ] )			
			Aadd( aGrava, { oModelT5T:aDataModel[ nlI, nlY, 1 ], oModelT5T:aDataModel[ nlI, nlY, 2 ] } )									
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
	FAltRegAnt( 'T5T', '2' )   

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
		oModel:LoadValue( 'MODEL_T5T', aGrava[ nlI, 1 ], aGrava[ nlI, 2 ] )
	Next        
						         
	//Busco a nova versao do registro
	cVersao := xFunGetVer()
	
	/*---------------------------------------------------------
	ATENCAO -> A alteracao destes campos deve sempre estar     
	abaixo do Loop do For, pois devem substituir as informacoes
	que foram armazenadas no Loop acima                        
	-----------------------------------------------------------*/
	oModel:LoadValue( "MODEL_T5T", "T5T_VERSAO", cVersao )
	oModel:LoadValue( "MODEL_T5T", "T5T_VERANT", cVerAnt )
	oModel:LoadValue( "MODEL_T5T", "T5T_PROTPN", cProtocolo )
	
	
	/*---------------------------------------------------------
	Tratamento para que caso o Evento Anterior fosse de exclusão
	seta-se o novo evento como uma "nova inclusão", caso contrário o
	evento passar a ser uma alteração
	-----------------------------------------------------------*/
	oModel:LoadValue( "MODEL_T5T", "T5T_EVENTO", "E" )
	oModel:LoadValue( "MODEL_T5T", "T5T_ATIVO" , "1" )
		
	//Gravo	
	FwFormCommit( oModel )
	TAFAltStat( 'T5T',"6" )

End Transaction

Return ( .T. )