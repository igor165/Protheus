#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA576.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA576
Cadastro MVC do R 2055 Aquisição de produção rural

@author Denis Souza / Rafael Leme / Karen Honda
@since 21/02/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA576()

Private cIndOpe := '0' //Varivel utilizada na consulta padrão para o documento fiscal ( TAFA062 )

If TAFAlsInDic( "V5S" )
	BrowseDef()
Else
	Aviso( STR0001, TafAmbInvMsg(), { STR0002 }, 3 ) //##"Dicionário Incompatível"##"Encerrar"
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Denis Souza / Rafael Leme / Karen Honda
@since 21/02/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao 	as array
Local aRotina 	as array

aFuncao  := {}
aRotina  := {}

lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If lMenuDif 
	ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.TAFA576' OPERATION 2 ACCESS 0	 //##"Visualizar"
	//ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.TAFA576' OPERATION 3 ACCESS 0 //##"Incluir"
	//ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.TAFA576' OPERATION 4 ACCESS 0 //##"Alterar"
	//ADD OPTION aRotina Title STR0006 Action 'VIEWDEF.TAFA576' OPERATION 5 ACCESS 0 //##"Excluir"

Else
	aAdd( aFuncao, { "", "TAF576Xml", "1" } )
	aAdd( aFuncao, { "", "xFunNewHis( 'V5S', 'TAF576' )", "3" } )
	aAdd( aFuncao, { "", "TAFXmlLote( 'V5S', 'R-2055', 'AqProd', 'TAF576Xml', 5, oBrw)", "5" } )
	aRotina := TAFMenuReinf( "TAFA576", aFuncao, .T. ) 
EndIf

Return (aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC
@author Denis Souza / Rafael Leme / Karen Honda
@since 21/02/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruV5S  as object
Local oStruV5T  as object
Local oStruV5U  as object
Local oStruV5V  as object
Local oModel	as object

oStruV5S := FWFormStruct( 1, 'V5S' )
oStruV5T := FWFormStruct( 1, 'V5T' )
oStruV5U := FWFormStruct( 1, 'V5U' )
oStruV5V := FWFormStruct( 1, 'V5V' )

oModel   := MPFormModel():New( 'TAFA576' , , , {|oModel| SaveModel( oModel ) })

//V5S - Aquisição de Produção Rural
oModel:AddFields('MODEL_V5S', /*cOwner*/, oStruV5S )
oModel:GetModel( "MODEL_V5S" ):SetPrimaryKey( { 'V5S_PERAPU' } )

//V5T - Detalhes da aquisição de produção rural
oModel:AddGrid('MODEL_V5T', 'MODEL_V5S', oStruV5T )
oModel:GetModel('MODEL_V5T'):SetUniqueLine( {'V5T_IDAQUI'} )
oModel:GetModel('MODEL_V5T'):SetMaxLine(6)

//V5U - Inf. Processos Relacionados Aquisição Prod. Rural
oModel:AddGrid('MODEL_V5U', 'MODEL_V5T', oStruV5U )
oModel:GetModel('MODEL_V5U'):SetOptional(.T.) //0-50
oModel:GetModel('MODEL_V5U'):SetUniqueLine( {'V5U_IDPROC', 'V5U_CODSUS'} )
oModel:GetModel('MODEL_V5U'):SetMaxLine(50)

//V5V - Detalhes NFs Aquisição Rural
oModel:AddGrid('MODEL_V5V', 'MODEL_V5T', oStruV5V )
oModel:GetModel('MODEL_V5V'):SetOptional(.T.)
oModel:GetModel('MODEL_V5V'):SetUniqueLine( {'V5V_CHVNF','V5V_IDFAT'} )

oModel:SetRelation("MODEL_V5T",{ {"V5T_FILIAL","xFilial('V5T')"}, {"V5T_ID","V5S_ID"}, {"V5T_VERSAO","V5S_VERSAO"}} , V5T->(IndexKey(1)) )
oModel:SetRelation("MODEL_V5U",{ {"V5U_FILIAL","xFilial('V5U')"}, {"V5U_ID","V5S_ID"}, {"V5U_VERSAO","V5S_VERSAO"}  , {"V5U_IDAQUI" ,"V5T_IDAQUI"}}, V5U->(IndexKey(1)) )
oModel:SetRelation("MODEL_V5V",{ {"V5V_FILIAL","xFilial('V5V')"}, {"V5V_ID","V5S_ID"}, {"V5V_VERSAO","V5S_VERSAO"}  , {"V5V_IDAQUI" ,"V5T_IDAQUI"}}, V5V->(IndexKey(1)) )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC da viewDef

@return oView - Objeto da view MVC
@author Denis Souza / Rafael Leme / Karen Honda
@since 21/02/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel   	as object
Local oStruV5Sa	as object
Local oStruV5Sb	as object
Local oStruV5T	as object
Local oStruV5U	as object
Local oStruV5V	as object
Local oView		as object
Local cCmpFil  	as char
Local nI        as numeric
Local aCmpGrp   as array
Local cGrpCom1, cGrpCom2, cGrpCom3 as char

oModel   	:= FWLoadModel( 'TAFA576' )
oStruV5Sa	:= FWFormStruct( 2, 'V5S' )
oStruV5Sb	:= FWFormStruct( 2, 'V5S' )
oStruV5T	:= FWFormStruct( 2, 'V5T' )
oStruV5U	:= FWFormStruct( 2, 'V5U' )
oStruV5V  	:= FWFormStruct( 2, 'V5V' )
oView		:= FWFormView():New()
cCmpFil  	:= ''
nI        	:= 0
aCmpGrp   	:= {}
cGrpCom1  	:= ""
cGrpCom2  	:= ""
cGrpCom3	:= ""

oView:SetModel( oModel )
oView:SetContinuousForm(.T.)

cGrpCom1  := 'V5S_VERSAO|V5S_VERANT|V5S_PROTPN|V5S_EVENTO|V5S_ATIVO|V5S_PERAPU|V5S_IDESTA|V5S_DESTAB|V5S_TPINSC|V5S_NRINSC|'
cGrpCom2  := 'V5S_TPINSP|V5S_NRINSP|V5S_INDCP|V5S_CODPAR|V5S_DPARTI|'
cCmpFil   := cGrpCom1 + cGrpCom2
oStruV5Sa := FwFormStruct( 2, 'V5S', {|x| AllTrim( x ) + "|" $ cCmpFil } )

//"Protocolo de Transmissão"
cGrpCom3 := 'V5S_PROTUL|'
cCmpFil   := cGrpCom3
oStruV5Sb := FwFormStruct( 2, 'V5S', {|x| AllTrim( x ) + "|" $ cCmpFil } )

// Grupo de campos
oStruV5Sa:AddGroup( "GRP_COMERCIALIZACAO_01", STR0007, "", 1 ) //##"Identificação do Estabelecimento Adquirente"
oStruV5Sa:AddGroup( "GRP_COMERCIALIZACAO_02", STR0008, "", 1 ) //##"Identificação do Produtor Rural"

aCmpGrp := StrToKArr(cGrpCom1,"|")
For nI := 1 to Len(aCmpGrp)
	oStruV5Sa:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_COMERCIALIZACAO_01")
Next nI

aCmpGrp := StrToKArr(cGrpCom2,"|")
For nI := 1 to Len(aCmpGrp)
	oStruV5Sa:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_COMERCIALIZACAO_02")
Next nI

oView:AddField( "VIEW_V5Sa", oStruV5Sa, "MODEL_V5S" )
oView:AddField( "VIEW_V5Sb", oStruV5Sb, "MODEL_V5S" )
oView:AddGrid ( "VIEW_V5T" , oStruV5T , "MODEL_V5T" )
oView:AddGrid ( "VIEW_V5U" , oStruV5U , "MODEL_V5U" )
oView:AddGrid ( "VIEW_V5V" , oStruV5V , "MODEL_V5V" )

/*-----------------------------------------------------------------------------------
								Estrutura do Folder
-------------------------------------------------------------------------------------*/
oView:CreateHorizontalBox("PAINEL_PRINCIPAL",100)
oView:CreateFolder("FOLDER_PRINCIPAL","PAINEL_PRINCIPAL")

//Folder Estabelecimento
oView:AddSheet("FOLDER_PRINCIPAL","ABA01",STR0009 ) //##"Aquisição de Produção Rural"
oView:CreateHorizontalBox("V5Sa",10,,,"FOLDER_PRINCIPAL","ABA01")

oView:CreateHorizontalBox("PAINEL_INDAQUIS",50,,,"FOLDER_PRINCIPAL","ABA01")
oView:CreateFolder( 'FOLDER_INDAQUIS', 'PAINEL_INDAQUIS' )
oView:AddSheet("FOLDER_INDAQUIS","ABA01",STR0010 ) //##"Detalhes da aquisição"
oView:CreateHorizontalBox( 'V5T', 100,,, 'FOLDER_INDAQUIS',"ABA01"  )

oView:CreateHorizontalBox("PAINEL_PROCNFS",40,,,"FOLDER_PRINCIPAL","ABA01")
oView:CreateFolder( 'FOLDER_PROCNFS', 'PAINEL_PROCNFS' )
oView:AddSheet("FOLDER_PROCNFS","ABA01",STR0011 ) //##"Processos Relacionados Aquisição Prod. Rural"
oView:CreateHorizontalBox( 'V5U', 100,,, 'FOLDER_PROCNFS'  , 'ABA01' )
oView:AddSheet("FOLDER_PROCNFS","ABA02",STR0012 ) //##"Notas fiscais ref. Aquisição Prod. Rural"
oView:CreateHorizontalBox( 'V5V', 100,,, 'FOLDER_PROCNFS'  , 'ABA02' )

//Folder Recibo de Transmissão
oView:AddSheet("FOLDER_PRINCIPAL","ABA02",STR0013 ) //##"Recibo de Transmissão"
oView:CreateHorizontalBox("V5Sb",100,,,"FOLDER_PRINCIPAL","ABA02")

oView:SetOwnerView( "VIEW_V5Sa", "V5Sa")
oView:SetOwnerView( "VIEW_V5Sb", "V5Sb")
oView:SetOwnerView( "VIEW_V5T",  "V5T" )
oView:SetOwnerView( "VIEW_V5U",  "V5U" )
oView:SetOwnerView( "VIEW_V5V",  "V5V" )

lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If !lMenuDif
	xFunRmFStr(@oStruV5Sa,"V5S")
EndIf

//oStruV5Sa:RemoveField('V5V_IDPART')
oStruV5U:RemoveField('V5U_IDSUSP')
oStruV5V:RemoveField('V5V_IDFAT')

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse definition

@author Denis Souza / Rafael Leme / Karen Honda
@since 22/01/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function BrowseDef()

    Private oBrw  as object

    oBrw := FWmBrowse():New()
    oBrw:SetDescription( STR0014 ) //##"R-2055 - Aquisição de Produção Rural"
    oBrw:SetAlias( 'V5S')
    oBrw:SetMenuDef( 'TAFA576' )
    oBrw:SetFilterDefault( "V5S_ATIVO == '1'" )

    If FindFunction("TAFLegReinf")
        TAFLegReinf( "V5S", oBrw)
    Else
        TafLegend(2,"V5S",@oBrw)
    EndIf

    oBrw:Activate()

Return( oBrw )

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao para validação de gravação do Modelo

@Param  oModel -> Modelo de dados
@Return .T.
@Author Denis Souza / Rafael Leme / Karen Honda
@Since 22/01/2021
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

	Local nOperation 	as numeric
	Local lRetorno		as logical

	nOperation := oModel:GetOperation()
	lRetorno   := .T.

	FWFormCommit( oModel )

Return( lRetorno )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF576Xml
Função responsável pela geração do XML do evento R-2055

@param cAlias -> Alias atual
@param nRecno -> Recno posicionado
@param nOpc   -> Opção selecionada - não utilizado
@param lJob   -> Execução por job

@author Wesley Pinheiro
@since 02/02/2021

/*/
//-------------------------------------------------------------------
Function TAF576Xml( cAlias, nRecno, nOpc, lJob )

	Local cXml      := ""
	Local cLayout   := "2055"
	Local cReg	    := "AqProd" //Registro Campo evtAqProd
	Local cChaveV5S := ""
	Local cChaveV5U := ""
	Local cNameXSD	:= Iif(alltrim(StrTran(SuperGetMv('MV_TAFVLRE',.F.,'1_03_00') ,'_','')) >= '10500','2055AquisicaoProdRural','AquisicaoProdRural') 

	Default lJob :=	.F.

	DBSelectArea( "V5T" )
	V5T->( DBSetOrder( 1 ) ) // V5T_FILIAL + V5T_ID + V5T_VERSAO + V5T_IDAQUI

	DBSelectArea( "V5U" )
	V5U->( DBSetOrder( 1 ) ) // V5U_FILIAL + V5U_ID + V5U_VERSAO + V5U_IDAQUI + V5U_IDPROC + V5U_IDSUSP

	// V5S - Aquisição de Produção Rural
	cXml += "<infoAquisProd>"
	cXml += "<ideEstabAdquir>"

	cXml += xTafTag( "tpInscAdq", V5S->V5S_TPINSC )
	cXml += xTafTag( "nrInscAdq", V5S->V5S_NRINSC )

	cXml += "<ideProdutor>"

	cXml += xTafTag( "tpInscProd" , V5S->V5S_TPINSP )
	cXml += xTafTag( "nrInscProd" , V5S->V5S_NRINSP )

	If V5S->V5S_INDCP == "2"
		cXml += xTafTag( "indOpcCP", "S" )
	EndIf

	cChaveV5S := V5S->( V5S_ID + V5S_VERSAO )

	If V5T->( DbSeek( xFilial( "V5T" ) + cChaveV5S ) )

		While V5T->( !Eof( ) ) .and. ( V5T->( V5T_FILIAL + V5T_ID + V5T_VERSAO ) == xFilial( "V5T" ) + cChaveV5S )

			// V5T - Detalhes Aquisição Prod Rural
			cXml += "<detAquis>"

			cXml += xTafTag( "indAquis"    , V5T->V5T_IDAQUI )
			cXml += xTafTag( "vlrBruto"	   , TafFReinfNum( V5T->V5T_VBRTPR ) )
			cXml += xTafTag( "vlrCPDescPR" , TafFReinfNum( V5T->V5T_VCPPR  ) )
			cXml += xTafTag( "vlrRatDescPR", TafFReinfNum( V5T->V5T_VRATPR ) )
			cXml += xTafTag( "vlrSenarDesc", TafFReinfNum( V5T->V5T_VSENPR ) )

			cChaveV5U := cChaveV5S + V5T->V5T_IDAQUI

			If V5U->( DbSeek( xFilial( "V5U" ) + cChaveV5U ) )

				While V5U->( !Eof( ) ) .and. ( V5U->( V5U_FILIAL + V5U_ID + V5U_VERSAO + V5U_IDAQUI ) == xFilial( "V5U" ) + cChaveV5U )

					// V5U - Inf.Processos Aquis.Prod.Rural	
					cXml += "<infoProcJud>"
					cXml += xTafTag( "nrProcJud"   , V5U->V5U_NUMPRO )
					cXml += xTafTag( "codSusp"     , V5U->V5U_CODSUS,, .T. )

					If ( V5U->V5U_VCPSUS > 0 )
						cXml += xTafTag( "vlrCPNRet"   , TafFReinfNum( V5U->V5U_VCPSUS ) )
					EndIf

					if ( V5U->V5U_VRASUS > 0 )
						cXml += xTafTag( "vlrRatNRet"  , TafFReinfNum( V5U->V5U_VRASUS ) )
					endIf

					if ( V5U->V5U_VSESUS > 0 )
						cXml += xTafTag( "vlrSenarNRet", TafFReinfNum( V5U->V5U_VSESUS ) )
					endIf

					cXml += "</infoProcJud>"

					V5U->( DbSkip( ) )

				EndDo

			EndIf

			cXml += "</detAquis>"

			V5T->( DbSkip( ) )

		EndDo

	EndIf
	
	cXml += "</ideProdutor>"

	cXml += "</ideEstabAdquir>"
	cXml += "</infoAquisProd>"

	V5T->( DBCloseArea( ) )
	V5U->( DBCloseArea( ) )

	/*---------------------------------------------------------------------------------------------
	Nome do schema:
		evt2055AquisicaoProdRural-v1_05_00.xsd
	Propriedades no schema:
		xmlns="http://www.reinf.esocial.gov.br/schemas/evt2055AquisicaoProdRural/v1_05_00"
		targetNamespace="http://www.reinf.esocial.gov.br/schemas/evt2055AquisicaoProdRural/v1_05_00"
	----------------------------------------------------------------------------------------------*/
	cXml := TAFXmlReinf( cXml, "V5S", cLayout, cReg, SubStr( V5S->V5S_PERAPU, 3, 4 ) + "-" + SubStr( V5S->V5S_PERAPU, 1, 2 )  ,, cNameXSD )

	If !lJob
		xTafGerXml( cXml, cLayout,,,,,, "R-" )
	EndIf

Return( cXml )


/*/{Protheus.doc} GerarEvtExc
Funcao que gera a exclusão do evento

@Param  oModel  -> Modelo de dados
@Param  nRecno  -> Numero do recno
@Param  lRotExc -> Variavel que controla se a function é chamada pelo TafIntegraESocial

@Return .T.

@author Wesley Matos
@since 19/02/2021
@Version 1.0
/*/
//-------------------------------------------------------------------


Static Function GerarEvtExc( oModel, nRecno, lRotExc )

Local oModelV5S		as object
Local oModelV5T		as object
Local oModelV5U		as object
Local oModelV5V		as object

Local cVerAnt		as char
Local cRecibo		as char
Local cVersao		as char
Local nI			as numeric
Local nV5V			as numeric
Local nV5T			as numeric
Local nV5U			as numeric
Local nV5TAdd		as numeric
Local nV5VAdd		as numeric
Local nV5UAdd		as numeric
Local nT9Z			as numeric

Local aGravaV5S		as array
Local aGravaV5T		as array
Local aGravaV5U		as array
Local aGravaV5V		as array

oModelV5S	:=	Nil
oModelV5T	:=	Nil
oModelV5U	:=	Nil
oModelV5V	:=	Nil

cVerAnt		:=	''
cRecibo		:=	''
cVersao		:=	''
nI			:=	0
nV5T		:=	0
nV5V		:=	0
nV5TAdd		:=	0
nV5VAdd		:=	0
nV5UAdd		:=	0
nT9Z		:=	0

aGravaV5S	:=	{}
aGravaV5T	:=	{}
aGravaV5U	:=	{}
aGravaV5V	:=	{}

Begin Transaction

	DBSelectArea( "V5S" )
	V5S->( DBGoTo( nRecno ) )

	oModelV5S	:= oModel:GetModel("MODEL_V5S")
	oModelV5T	:= oModel:GetModel("MODEL_V5T")
	oModelV5U	:= oModel:GetModel("MODEL_V5U")
	oModelV5V	:= oModel:GetModel("MODEL_V5V")
	
	//************************************
	//Informações para gravação do rastro
	//************************************
	cVerAnt := oModelV5S:GetValue( "V5S_VERSAO" )
	cRecibo := oModelV5S:GetValue( "V5S_PROTUL" )

	//****************************************************************************************************************
	//Armazeno as informações que foram modificadas na tela, para utilização em operação de inclusão de novo registro
	//****************************************************************************************************************
	For nI := 1 to Len( oModelV5S:aDataModel[1] )
		aAdd( aGravaV5S, { oModelV5S:aDataModel[1,nI,1], oModelV5S:aDataModel[1,nI,2] } )
	Next nI
	
	//V5T
	If V5T->( MsSeek( xFilial( "V5T" ) + V5S->( V5S_ID + V5S_VERSAO) ) )
	
		For nV5T := 1 to oModel:GetModel( "MODEL_V5T" ):Length()
			oModel:GetModel( "MODEL_V5T" ):GoLine( nV5T )

			If !oModel:GetModel( "MODEL_V5T" ):IsEmpty() .and. !oModel:GetModel( "MODEL_V5T" ):IsDeleted()
				aAdd( aGravaV5T, {	oModelV5T:GetValue( "V5T_IDAQUI"  ),;
									oModelV5T:GetValue( "V5T_VBRTPR"  ),;
									oModelV5T:GetValue( "V5T_VCPPR"   ),;
									oModelV5T:GetValue( "V5T_VRATPR"  ),;
									oModelV5T:GetValue( "V5T_VSENPR"  ) } )

				//V5V
				If V5V->( MsSeek( xFilial( "V5V" ) + V5S->( V5S_ID + V5S_VERSAO) + V5T->V5T_IDAQUI) ) 
					For nV5V := 1 to oModel:GetModel( "MODEL_V5V" ):Length()
						oModel:GetModel( "MODEL_V5V" ):GoLine( nV5V)

						If !oModel:GetModel( "MODEL_V5V" ):IsEmpty() .and. !oModel:GetModel( "MODEL_V5V" ):IsDeleted()
							aAdd( aGravaV5V, {	oModelV5T:GetValue( "V5T_IDAQUI" ),;
												oModelV5V:GetValue( "V5V_CHVNF"  ),;
												oModelV5V:GetValue( "V5V_SERIE"  ),;
												oModelV5V:GetValue( "V5V_NUMDOC" ),;
												oModelV5V:GetValue( "V5V_NUMFAT" ),;
												oModelV5V:GetValue( "V5V_IDFAT"  ),;
												oModelV5V:GetValue( "V5V_DTEMIS" ),;
												oModelV5V:GetValue( "V5V_VBRTPR" ),;
												oModelV5V:GetValue( "V5V_VCPPR"  ),;
												oModelV5V:GetValue( "V5V_VRATPR" ),; 
												oModelV5V:GetValue( "V5V_VSENPR" ),;
												oModelV5V:GetValue( "V5V_VCPSUS" ),;
												oModelV5V:GetValue( "V5V_VRASUS" ),;
												oModelV5V:GetValue( "V5V_VSESUS" )} )
													
						EndIf
					Next nV5V
				EndIf

				//V5U
				If V5U->( MsSeek( xFilial( "V5U" ) + V5T->( V5T_ID + V5T_VERSAO) + V5T->V5T_IDAQUI ) ) 

					For nV5U := 1 to oModel:GetModel( "MODEL_V5U" ):Length()
						oModel:GetModel( "MODEL_V5U" ):GoLine( nV5U )

						If !oModel:GetModel( "MODEL_V5U" ):IsEmpty() .and. !oModel:GetModel( "MODEL_V5U" ):IsDeleted()
							aAdd( aGravaV5U, {	oModelV5T:GetValue( "V5T_IDAQUI" ),;
												oModelV5U:GetValue( "V5U_IDPROC" ),;
												oModelV5U:GetValue( "V5U_NUMPRO" ),;
												oModelV5U:GetValue( "V5U_CODSUS" ),;
												oModelV5U:GetValue( "V5U_VCPSUS" ),;
												oModelV5U:GetValue( "V5U_VRASUS" ),;
												oModelV5U:GetValue( "V5U_VSESUS" ),;
												oModelV5U:GetValue( "V5U_IDSUSP" )} )
						EndIf
					Next nV5U
				EndIf
			EndIf		
		Next nV5T		
	EndIf
	

	//*****************************
	//Seto o registro como Inativo
	//*****************************
	FAltRegAnt( "V5S", "2" )

	//**************************************
	//Operação de Inclusão de novo registro
	//**************************************
	oModel:DeActivate()
	oModel:SetOperation( 3 )
	oModel:Activate()

	//********************************************************************************
	//Inclusão do novo registro já considerando as informações alteradas pelo usuário
	//********************************************************************************
	For nI := 1 to Len( aGravaV5S )
		oModel:LoadValue( "MODEL_V5S", aGravaV5S[nI,1], aGravaV5S[nI,2] )
	Next nI

	//V5T
	nV5TAdd := 1
	For nV5T := 1 to Len( aGravaV5T )
		
		oModel:GetModel( "MODEL_V5T" ):LVALID := .T.

		If nV5TAdd > 1
			oModel:GetModel( "MODEL_V5T" ):AddLine()
		EndIf
			
		oModel:LoadValue( "MODEL_V5T", "V5T_IDAQUI", aGravaV5T[nV5T][1] )
		oModel:LoadValue( "MODEL_V5T", "V5T_VBRTPR", aGravaV5T[nV5T][2] )
		oModel:LoadValue( "MODEL_V5T", "V5T_VCPPR",  aGravaV5T[nV5T][3] )
		oModel:LoadValue( "MODEL_V5T", "V5T_VRATPR", aGravaV5T[nV5T][4] )
		oModel:LoadValue( "MODEL_V5T", "V5T_VSENPR", aGravaV5T[nV5T][5] )

		nV5TAdd ++

		//V5V
		nV5VAdd := 1

		For nV5V := 1 to Len( aGravaV5V )

			If aGravaV5V[nV5V][1] == aGravaV5T[nV5T][1]
					
				oModel:GetModel( "MODEL_V5V" ):LVALID := .T.

				If nV5VAdd > 1
					oModel:GetModel( "MODEL_V5V" ):AddLine()
				EndIf
					
				oModel:LoadValue( "MODEL_V5V", "V5V_CHVNF" ,  aGravaV5V[nV5V][2] )
				oModel:LoadValue( "MODEL_V5V", "V5V_SERIE" ,  aGravaV5V[nV5V][3] )
				oModel:LoadValue( "MODEL_V5V", "V5V_NUMDOC" , aGravaV5V[nV5V][4] )
				oModel:LoadValue( "MODEL_V5V", "V5V_NUMFAT" , aGravaV5V[nV5V][5] )
				oModel:LoadValue( "MODEL_V5V", "V5V_IDFAT" ,  aGravaV5V[nV5V][6] )
				oModel:LoadValue( "MODEL_V5V", "V5V_DTEMIS" , aGravaV5V[nV5V][7] )
				oModel:LoadValue( "MODEL_V5V", "V5V_VBRTPR" , aGravaV5V[nV5V][8] )
				oModel:LoadValue( "MODEL_V5V", "V5V_VCPPR" ,  aGravaV5V[nV5V][9] )
				oModel:LoadValue( "MODEL_V5V", "V5V_VRATPR" , aGravaV5V[nV5V][10] )
				oModel:LoadValue( "MODEL_V5V", "V5V_VSENPR" , aGravaV5V[nV5V][11] )
				oModel:LoadValue( "MODEL_V5V", "V5V_VCPSUS" , aGravaV5V[nV5V][12] )
				oModel:LoadValue( "MODEL_V5V", "V5V_VRASUS" , aGravaV5V[nV5V][13] )
				oModel:LoadValue( "MODEL_V5V", "V5V_VSESUS" , aGravaV5V[nV5V][14] )

				nV5VAdd++

			EndIf
		Next nV5V
			
		//V5U
		nV5UAdd := 1

		For nV5U := 1 to Len( aGravaV5U )

			If aGravaV5U[nV5U][1] == aGravaV5T[nV5T][1]

				oModel:GetModel( "MODEL_V5U" ):LVALID := .T.

				If nV5UAdd > 1
					oModel:GetModel( "MODEL_V5U" ):AddLine()
				EndIf

				oModel:LoadValue( "MODEL_V5U", "V5U_IDPROC" ,  aGravaV5U[nV5U][2] )
				oModel:LoadValue( "MODEL_V5U", "V5U_NUMPRO" ,  aGravaV5U[nV5U][3] )
				oModel:LoadValue( "MODEL_V5U", "V5U_CODSUS" ,  aGravaV5U[nV5U][4] )
				oModel:LoadValue( "MODEL_V5U", "V5U_VCPSUS" ,  aGravaV5U[nV5U][5] )
				oModel:LoadValue( "MODEL_V5U", "V5U_VRASUS" ,  aGravaV5U[nV5U][6] )
				oModel:LoadValue( "MODEL_V5U", "V5U_VSESUS" ,  aGravaV5U[nV5U][7] )
				oModel:LoadValue( "MODEL_V5U", "V5U_IDSUSP" ,  aGravaV5U[nV5U][8] )

				nV5UAdd++
			EndIf
		Next nV5U
	Next nV5T

	//*****************************************
	//Versão que será gravada no novo registro
	//*****************************************
	cVersao := xFunGetVer()

	//********************************************************************
	//ATENÇÃO
	//A alteração destes campos devem sempre estar abaixo do loop do For,
	//pois devem substituir as informações que foram armazenadas acima
	//********************************************************************
	oModel:LoadValue( "MODEL_V5S", "V5S_VERSAO", cVersao )
	oModel:LoadValue( "MODEL_V5S", "V5S_VERANT", cVerAnt )
	oModel:LoadValue( "MODEL_V5S", "V5S_PROTPN", cRecibo )
	oModel:LoadValue( "MODEL_V5S", "V5S_PROTUL", "" )

	oModel:LoadValue( "MODEL_V5S", "V5S_EVENTO", "E" )
	oModel:LoadValue( "MODEL_V5S", "V5S_ATIVO", "1" )

	FWFormCommit( oModel )
	TAFAltStat( "V5S", "6" ) 

End Transaction

Return( .T. )
