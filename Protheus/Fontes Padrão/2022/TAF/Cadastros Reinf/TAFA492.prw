#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA492.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA492
Cadastro MVC de Comercialização da Produção por 
Produtor Rural PJ/Agroindústria R-2050
 
@author Leonardo Kichitaro
@since 31/10/2017
@version 1.0
/*/
//---------------------------------------------------------------------
Function TAFA492()

// Função que indica se o ambiente é válido para o eSocial 2.3
If TAFAlsInDic( "V1D" )
	BrowseDef()
Else
	Aviso( STR0007, TafAmbInvMsg(), { STR0008 }, 3 ) //##"Dicionário Incompatível" ##"Encerrar"
EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Leonardo Kichitaro
@since 31/10/2017
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao as array
Local aRotina as array

aFuncao := {}
aRotina := {}

aAdd( aFuncao, { "", "TAF492Xml", "1" } )
aAdd( aFuncao, { "", "xFunNewHis( 'V1D', 'TAFA492' )", "3" } )
aAdd( aFuncao, { "", "TAFXmlLote( 'V1D', 'R-2050', 'ComProd', 'TAF492Xml', 5, oBrw)", "5" } )

lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )


If lMenuDif
	ADD OPTION aRotina Title "Visualizar" Action 'VIEWDEF.TAFA492' OPERATION 2 ACCESS 0
Else
	aRotina := TAFMenuReinf( "TAFA492", aFuncao )
EndIf

Return (aRotina )

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Leonardo Kichitaro
@since 31/10/2017
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

Local oStruV1D  as object
Local oStruV1E  as object
Local oStruV1F  as object
Local oModel    as object

oStruV1D  :=  FWFormStruct( 1, 'V1D' )
oStruV1E  :=  FWFormStruct( 1, 'V1E' )
oStruV1F  :=  FWFormStruct( 1, 'V1F' )
oModel    :=  MPFormModel():New( 'TAFA492' , , , {|oModel| SaveModel( oModel ) })

//V1D – Producao Produt.Rural PJ/Agroi
oModel:AddFields('MODEL_V1D', /*cOwner*/, oStruV1D)
oModel:GetModel('MODEL_V1D'):SetPrimaryKey({'V1D_PERAPU' ,'V1D_TPINSC', 'V1D_NRINSC'})

//V1E – Vl.total Receita Bruta
oModel:AddGrid('MODEL_V1E', 'MODEL_V1D', oStruV1E)
oModel:GetModel('MODEL_V1E'):SetUniqueLine({'V1E_IDCOM'})
oModel:GetModel('MODEL_V1E'):SetMaxLine(4)     

//V1F – Proces.Judi.decisao/sent.favo.
oModel:AddGrid('MODEL_V1F', 'MODEL_V1E', oStruV1F)
oModel:GetModel('MODEL_V1F'):SetOptional(.T.)
oModel:GetModel('MODEL_V1F'):SetUniqueLine({'V1F_TPPROC', 'V1F_NRPROC', 'V1F_CODSUS'})
oModel:GetModel('MODEL_V1F'):SetMaxLine(50)

oModel:SetRelation('MODEL_V1E', {{'V1E_FILIAL' , 'xFilial( "V1E" )'}, {'V1E_ID' , 'V1D_ID'}, {'V1E_VERSAO' , 'V1D_VERSAO'}}, V1E->(IndexKey(1)))
oModel:SetRelation('MODEL_V1F', {{'V1F_FILIAL' , 'xFilial( "V1F" )'}, {'V1F_ID' , 'V1D_ID'}, {'V1F_VERSAO' , 'V1D_VERSAO'}, {'V1F_IDCOM' , 'V1E_IDCOM'}}, V1F->(IndexKey(1)))

Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Leonardo Kichitaro
@since 31/10/2017
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

Local oView		as Object
Local oModel		as Object
Local oStruV1D_1	as Object
Local oStruV1E_2	as Object
Local oStruV1F	as Object
Local aCmpGrp   	as array
Local cCmpFil		as char
Local cGrpCom1	as char
Local cGrpCom2	as char
Local cGrpCom3	as char
Local nI			as numeric

oModel		:= FWLoadModel("TAFA492")
oStruV1D_1	:= Nil
oStruV1D_2	:= Nil
oStruV1E	:= FWFormStruct( 2, "V1E" )
oStruV1F	:= FWFormStruct( 2, "V1F" )
oView		:= FWFormView():New()
nI			:= 0
aCmpGrp		:= {}
cCmpFil		:= ""
cGrpCom1	:= ""
cGrpCom2	:= ""
cGrpCom3	:= ""

oView:SetModel(oModel)
oView:SetContinuousForm(.T.)

//Identificação do Estabelecimento
cGrpCom1  := 'V1D_VERSAO|V1D_VERANT|V1D_PROTPN|V1D_EVENTO|V1D_ATIVO|V1D_PERAPU|'
cGrpCom2  := 'V1D_TPINSC|V1D_NRINSC|V1D_VRECBT|V1D_VCPAPU|V1D_VRAAPU|V1D_VSEAPU|V1D_VCPSUS|V1D_VRASUS|V1D_VSESUS|'
cCmpFil   := cGrpCom1 + cGrpCom2
oStruV1D_1 := FwFormStruct( 2, 'V1D', {|x| AllTrim( x ) + "|" $ cCmpFil } )

//"Protocolo de Transmissão"
cGrpCom3 := 'V1D_PROTUL|'
cCmpFil   := cGrpCom3
oStruV1D_2 := FwFormStruct( 2, 'V1D', {|x| AllTrim( x ) + "|" $ cCmpFil } )

/*--------------------------------------------------------------------------------------------
			      					Grupo de campos 	
---------------------------------------------------------------------------------------------*/

oStruV1D_1:AddGroup( "GRP_ESTAB_01", STR0010, "", 1 ) //Informações de Identificação do Evento 

aCmpGrp := StrToKArr(cGrpCom1,"|")
For nI := 1 to Len(aCmpGrp)
	oStruV1D_1:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_ESTAB_01")
Next nI

oStruV1D_1:AddGroup( "GRP_ESTAB_02", STR0002, "", 1 ) //"Identificação do Estabelecimento" 

aCmpGrp := StrToKArr(cGrpCom2,"|")
For nI := 1 to Len(aCmpGrp)
	oStruV1D_1:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_ESTAB_02")
Next nI


/*--------------------------------------------------------------------------------------------
									Esrutura da View
---------------------------------------------------------------------------------------------*/

oView:AddField( "VIEW_V1D_1", oStruV1D_1, "MODEL_V1D" )
oView:AddField( "VIEW_V1D_2", oStruV1D_2, "MODEL_V1D" )
oView:AddGrid ( "VIEW_V1E", oStruV1E, "MODEL_V1E" )
oView:AddGrid ( "VIEW_V1F", oStruV1F, "MODEL_V1F" )

oView:EnableTitleView("MODEL_V1F",STR0004) //"Processos Administrativos/Judiciais"

/*-----------------------------------------------------------------------------------
								Estrutura do Folder
-------------------------------------------------------------------------------------*/
oView:CreateHorizontalBox("PAINEL_PRINCIPAL",100)
oView:CreateFolder("FOLDER_PRINCIPAL","PAINEL_PRINCIPAL")

//////////////////////////////////////////////////////////////////////////////////

oView:AddSheet("FOLDER_PRINCIPAL","ABA01",STR0001) //"Comercialização da Produção por Produtor Rural PJ/Agroindústria"
oView:CreateHorizontalBox("V1D_1",20,,,"FOLDER_PRINCIPAL","ABA01") 

oView:CreateHorizontalBox("PAINEL_TPCOM",10,,,"FOLDER_PRINCIPAL","ABA01")
oView:CreateFolder( 'FOLDER_TPCOM', 'PAINEL_TPCOM' )

oView:AddSheet( 'FOLDER_TPCOM', 'ABA01', STR0003 ) //"Receita Bruta por "tipo" de comercialização"
oView:CreateHorizontalBox ( 'V1E', 50,,, 'FOLDER_TPCOM'  , 'ABA01' )
oView:CreateHorizontalBox ( 'V1F', 50,,, 'FOLDER_TPCOM'  , 'ABA01' )


oView:AddSheet("FOLDER_PRINCIPAL","ABA02", STR0005)//"Recibo de Transmissão" 
oView:CreateHorizontalBox("V1D_2",100,,,"FOLDER_PRINCIPAL","ABA02")

//////////////////////////////////////////////////////////////////////////////////

/*-----------------------------------------------------------------------------------
							Amarração para exibição das informações
-------------------------------------------------------------------------------------*/

oView:SetOwnerView( "VIEW_V1D_1", "V1D_1")
oView:SetOwnerView( "VIEW_V1D_2", "V1D_2")
oView:SetOwnerView( "VIEW_V1E",  "V1E" )
oView:SetOwnerView( "VIEW_V1F",  "V1F" )

lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If !lMenuDif
	xFunRmFStr(@oStruV1D_1,"V1D")
EndIf

oStruV1F:RemoveField('V1F_IDSUSP')

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Leonardo Kichitaro
@since 09/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel(oModel)

Local nOperation	as numeric
Local lRetorno		as logical

nOperation	:= oModel:GetOperation()
lRetorno	:= .T.

FwFormCommit( oModel )      

Return (lRetorno)

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF492Xml

Funcao de geracao do XML para atender o registro S-2260
Quando a rotina for chamada o registro deve estar posicionado

@Param:
cAlias - Alias da Tabela
nRecno - Recno do Registro corrente
nOpc   - Operacao a ser realizada
lJob   - Informa se foi chamado por Job

@Return:
cXml - Estrutura do Xml do Layout S-2260

@author Leonardo Kichitaro
@since 06/11/2017
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF492Xml(cAlias,nRecno,nOpc,lJob,lAutomato,cFile)

Local cXml    	as char
Local cLayout 	as char
Local cReg    	as char
Local cPeriodo	as char
Local cNameXSD 	as char

Default lJob 	:= .F.
Default cAlias 	:= "V1D"
Default nRecno	:= 1
Default nOpc	:= 1

cLayout		:=	"2050"
cXml		:=	""
cReg		:=	"ComProd"
cPeriodo	:=	SubStr( V1D->V1D_PERAPU, 3, 4 ) + "-" + SubStr( V1D->V1D_PERAPU, 1, 2 )
cNameXSD	:= 	"InfoProdRural"

DBSelectArea("V1E")  
V1E->(DBSetOrder(1))

DBSelectArea("V1F") 
V1F->(DBSetOrder(1))

cXml +=		"<infoComProd>"
cXml +=			"<ideEstab>"	
cXml +=				xTafTag("tpInscEstab"		,V1D->V1D_TPINSC)
cXml +=				xTafTag("nrInscEstab"		,V1D->V1D_NRINSC)
cXml +=				xTafTag("vlrRecBrutaTotal"	,TafFReinfNum(V1D->V1D_VRECBT))
cXml +=				xTafTag("vlrCPApur"			,TafFReinfNum(V1D->V1D_VCPAPU))
cXml +=				xTafTag("vlrRatApur"		,TafFReinfNum(V1D->V1D_VRAAPU))
cXml +=				xTafTag("vlrSenarApur"		,TafFReinfNum(V1D->V1D_VSEAPU))
cXml +=				xTafTag("vlrCPSuspTotal"	,TafFReinfNum(V1D->V1D_VCPSUS) , ,.T.) 
cXml +=				xTafTag("vlrRatSuspTotal"	,TafFReinfNum(V1D->V1D_VRASUS) , ,.T.) 
cXml +=				xTafTag("vlrSenarSuspTotal"	,TafFReinfNum(V1D->V1D_VSESUS) , ,.T.)

If V1E->( MsSeek( xFilial( "V1E" ) +V1D->( V1D_ID + V1D_VERSAO) ) )	
	While V1E->(!Eof()) .And. V1E->( V1E_FILIAL + V1E_ID + V1E_VERSAO ) == V1D->( V1D_FILIAL + V1D_ID + V1D_VERSAO )
		
		cXml +=			"<tipoCom>"
		cXml +=				xTafTag("indCom"		,V1E->V1E_IDCOM )
		cXml +=				xTafTag("vlrRecBruta"	,TafFReinfNum(V1E->V1E_VRECBR))
		
		If V1F->( MsSeek( xFilial( "V1F" ) + V1E->( V1E_ID + V1E_VERSAO + V1E_IDCOM ) ) )	
			While V1F->(!Eof()) .And. V1F->( V1F_FILIAL + V1F_ID + V1F_VERSAO + V1F_IDCOM ) == V1E->( V1E_FILIAL + V1E_ID + V1E_VERSAO + V1E_IDCOM )
				xTafTagGroup("infoProc"  		 ,{ { "tpProc"		,V1F->V1F_TPPROC				    ,,.F. }; 
										 		 ,  { "nrProc"		,V1F->V1F_NRPROC				    ,,.F. };
										 		 ,	{ "codSusp"		,V1F->V1F_CODSUS 					,,.T. };
				   	  		 			 		 ,  { "vlrCPSusp"	,TafFReinfNum(V1F->V1F_VCPSUS)  	,,.T. };
				   	  		 			 		 ,  { "vlrRatSusp"	,TafFReinfNum(V1F->V1F_VRASUS)  	,,.T. };
				   	  		 			 		 ,  { "vlrSenarSusp",TafFReinfNum(V1F->V1F_VSESUS) 	    ,,.T. }};	
				   	  		 			 		 ,  @cXml)
				
								
				V1F->( DbSkip() )
			EndDo
		EndIf

		cXml +=			"</tipoCom>"

		V1E->( DbSkip() )
	EndDo
EndIf

cXml +=			"</ideEstab>"
cXml +=		"</infoComProd>"

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Estrutura do cabecalho³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
cXml := TAFXmlReinf( cXml, "V1D", cLayout, cReg, cPeriodo,, cNameXSD)

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Executa gravacao do registro³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If !lJob
	xTafGerXml(cXml,cLayout,,,,,,"R-" )
EndIf

Return(cXml)

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF492Vld
Validacao dos dados do registro posicionado, verificando inconsistencias
nas informacos caso seja necessario gerar um XML

@Param:
cAlias - Alias da Tabela
nRecno - Recno do Registro corrente
nOpc   - Operacao a ser realizada
lJob   - Job / Aplicacao

@Return:

@author Leonardo Kichitaro
@since 06/11/2017
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF492Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro   as array
Local aDadosUtil as array
Local lValida    as logical   

Default lJob := .F.

aLogErro   := {}
aDadosUtil := {}
lValida    := V1D->V1D_STATUS $ ( " |1" )

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := V1D->( Recno() )

If !lValida
	aAdd( aLogErro, { "V1D_ID", "000305", "V1D", nRecno } ) //Registros que já foram transmitidos ao Fisco, não podem ser validados
Else
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ATUALIZO O STATUS DO REGISTRO³
	//³1 = Registro Invalido        ³
	//³0 = Registro Valido          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cStatus := Iif( Len( aLogErro ) > 0, "1", "0" )
	Begin Transaction 
		If RecLock( "V1D", .F. )
			V1D->V1D_STATUS := cStatus
			V1D->( MsUnlock() )
		EndIf
	End Transaction 
	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Nao apresento o alert quando utilizo o JOB para validar³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lJob
	xValLogEr( aLogErro )
EndIf

Return(aLogErro)

//-------------------------------------------------------------------
/*/{Protheus.doc} GerarEvtExc
Funcao que gera a exclusão do evento

@Param  oModel  -> Modelo de dados
@Param  nRecno  -> Numero do recno
@Param  lRotExc -> Variavel que controla se a function é chamada pelo TafIntegraESocial

@Return .T.

@author Leonardo Kichitaro
@since 29/06/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function GerarEvtExc( oModel, nRecno, lRotExc )

Local oModelV1D		as object
Local oModelV1E		as object
Local oModelV1F		as object
Local cVerAnt		as char
Local cRecibo		as char
Local cVersao		as char
Local nI			as numeric
Local nV1E			as numeric
Local nV1F			as numeric
Local nV1FAdd		as numeric
Local nT9Z			as numeric
Local aGravaV1D		as array
Local aGravaV1E		as array
Local aGravaV1F		as array

oModelV1D	:=	Nil
oModelV1E	:=	Nil
oModelV1F	:=	Nil
cVerAnt		:=	""
cRecibo		:=	""
cVersao		:=	""
nI			:=	0
nV1E		:=	0
nV1F		:=	0
nV1FAdd		:=	0
nT9Z		:=	0
aGravaV1D	:=	{}
aGravaV1E	:=	{}
aGravaV1F	:=	{}

Begin Transaction

	DBSelectArea( "V1D" )
	V1D->( DBGoTo( nRecno ) )

	oModelV1D := oModel:GetModel( "MODEL_V1D" )
	oModelV1E := oModel:GetModel( "MODEL_V1E" )
	oModelV1F := oModel:GetModel( "MODEL_V1F" )

	//************************************
	//Informações para gravação do rastro
	//************************************
	cVerAnt := oModelV1D:GetValue( "V1D_VERSAO" )
	cRecibo := oModelV1D:GetValue( "V1D_PROTUL" )

	//****************************************************************************************************************
	//Armazeno as informações que foram modificadas na tela, para utilização em operação de inclusão de novo registro
	//****************************************************************************************************************
	For nI := 1 to Len( oModelV1D:aDataModel[1] )
		aAdd( aGravaV1D, { oModelV1D:aDataModel[1,nI,1], oModelV1D:aDataModel[1,nI,2] } )
	Next nI

	//V1E
	If V1E->( MsSeek( xFilial( "V1E" ) + V1D->( V1D_ID + V1D_VERSAO ) ) )

		For nV1E := 1 to oModel:GetModel( "MODEL_V1E" ):Length()
			oModel:GetModel( "MODEL_V1E" ):GoLine( nV1E )

			If !oModel:GetModel( "MODEL_V1E" ):IsEmpty() .and. !oModel:GetModel( "MODEL_V1E" ):IsDeleted()
				aAdd( aGravaV1E, {	oModelV1E:GetValue( "V1E_IDCOM"  ),;
									oModelV1E:GetValue( "V1E_VRECBR" ) } )

				//V1F
				If V1F->( MsSeek( xFilial( "V1F" ) + V1E->( V1E_ID + V1E_VERSAO + V1E_IDCOM ) ) )

					For nV1F := 1 to oModel:GetModel( "MODEL_V1F" ):Length()
						oModel:GetModel( "MODEL_V1F" ):GoLine( nV1F )

						If !oModel:GetModel( "MODEL_V1F" ):IsEmpty() .and. !oModel:GetModel( "MODEL_V1F" ):IsDeleted()
							aAdd( aGravaV1F, {	oModelV1E:GetValue( "V1E_IDCOM" ),;
												oModelV1F:GetValue( "V1F_TPPROC" ),;
												oModelV1F:GetValue( "V1F_NRPROC" ),;
												oModelV1F:GetValue( "V1F_CODSUS" ),;
												oModelV1F:GetValue( "V1F_VCPSUS" ),;
												oModelV1F:GetValue( "V1F_VRASUS" ),;
												oModelV1F:GetValue( "V1F_VSESUS" ) } )
						EndIf
					Next nV1F
				EndIf
			EndIf
		Next nV1E
	EndIf
	
	//*****************************
	//Seto o registro como Inativo
	//*****************************
	FAltRegAnt( "V1D", "2" )

	//**************************************
	//Operação de Inclusão de novo registro
	//**************************************
	oModel:DeActivate()
	oModel:SetOperation( 3 )
	oModel:Activate()

	//********************************************************************************
	//Inclusão do novo registro já considerando as informações alteradas pelo usuário
	//********************************************************************************
	For nI := 1 to Len( aGravaV1D )
		oModel:LoadValue( "MODEL_V1D", aGravaV1D[nI,1], aGravaV1D[nI,2] )
	Next nI

	//V1E
	For nV1E := 1 to Len( aGravaV1E )

		oModel:GetModel( "MODEL_V1E" ):LVALID := .T.

		If nV1E > 1
			oModel:GetModel( "MODEL_V1E" ):AddLine()
		EndIf

		oModel:LoadValue( "MODEL_V1E", "V1E_IDCOM" , aGravaV1E[nV1E][1] )
		oModel:LoadValue( "MODEL_V1E", "V1E_VRECBR", aGravaV1E[nV1E][2] )

		//V1F
		nV1FAdd := 1
		For nV1F := 1 to Len( aGravaV1F )
			If aGravaV1E[nV1E][1] == aGravaV1F[nV1F][1]

				oModel:GetModel( "MODEL_V1F" ):LVALID := .T.

				If nV1FAdd > 1
					oModel:GetModel( "MODEL_V1F" ):AddLine()
				EndIf
				

				oModel:LoadValue( "MODEL_V1F", "V1F_TPPROC", aGravaV1F[nV1F][2] )
				oModel:LoadValue( "MODEL_V1F", "V1F_NRPROC", aGravaV1F[nV1F][3] )
				oModel:LoadValue( "MODEL_V1F", "V1F_CODSUS", aGravaV1F[nV1F][4] )
				oModel:LoadValue( "MODEL_V1F", "V1F_VCPSUS", aGravaV1F[nV1F][5] )
				oModel:LoadValue( "MODEL_V1F", "V1F_VRASUS", aGravaV1F[nV1F][6] )
				oModel:LoadValue( "MODEL_V1F", "V1F_VSESUS", aGravaV1F[nV1F][7] )

				nV1FAdd ++
			EndIf
		Next nT9Y
	Next nV1E
	
	//*****************************************
	//Versão que será gravada no novo registro
	//*****************************************
	cVersao := xFunGetVer()

	//********************************************************************
	//ATENÇÃO
	//A alteração destes campos devem sempre estar abaixo do loop do For,
	//pois devem substituir as informações que foram armazenadas acima
	//********************************************************************
	oModel:LoadValue( "MODEL_V1D", "V1D_VERSAO", cVersao )
	oModel:LoadValue( "MODEL_V1D", "V1D_VERANT", cVerAnt )
	oModel:LoadValue( "MODEL_V1D", "V1D_PROTPN", cRecibo )
	oModel:LoadValue( "MODEL_V1D", "V1D_PROTUL", "" )

	oModel:LoadValue( "MODEL_V1D", "V1D_EVENTO", "E" )
	oModel:LoadValue( "MODEL_V1D", "V1D_ATIVO", "1" )

	FWFormCommit( oModel )
	TAFAltStat( "V1D", "6" ) 

End Transaction

Return( .T. )

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse definition

@author Roberto Souza
@since 23/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function BrowseDef()
	Private oBrw  as object
	
	If FunName() == "TAFXREINF"
		lMenuDif := Iif( Type( "lMenuDif" ) == "U", .T., lMenuDif ) 
	EndIf

    oBrw := FWmBrowse():New()	

	oBrw:SetDescription( "R-2050 - " + STR0001)	//"Comercialização da Produção por Produtor Rural PJ/Agroindústria"
	oBrw:SetAlias( 'V1D')
	oBrw:SetMenuDef( 'TAFA492' )	
	oBrw:SetFilterDefault( "V1D_ATIVO == '1'" )
	
	//DbSelectArea("V1D")
	//Set Filter TO &("V1D_ATIVO == '1'")
	
	If FindFunction("TAFLegReinf")
		TAFLegReinf( "V1D", oBrw)
	Else
		TafLegend(2,"V1D",@oBrw)
	EndIf
	oBrw:Activate()
	
Return( oBrw )
