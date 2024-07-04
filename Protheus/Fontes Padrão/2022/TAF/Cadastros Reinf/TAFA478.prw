#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA478.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA478
Cadastro MVC do R-2020 - Reten��o Contribui��o Previdenci�ria - Servi�os Prestados

@author Vitor Siqueira			
@since 15/01/2018
@version 1.0

/*/
//-------------------------------------------------------------------

Function TAFA478()

If TAFAlsInDic( "T9Z" ) .And. AllTrim( GetSx3Cache( "CMN_INDAPU", "X3_BROWSE" ) ) == 'N'
	BrowseDef()
Else
	Aviso( STR0010, TafAmbInvMsg(), { STR0011 }, 3 ) //##"Dicion�rio Incompat�vel" ##"Encerrar"
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Funcao generica MVC com as opcoes de menu

@author Vitor Siqueira			
@since 15/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aFuncao as array
Local aRotina as array

aFuncao := {}
aRotina := {}

aAdd( aFuncao, { "", "TAF478Xml", "1" } )
aAdd( aFuncao, { "", "xFunNewHis( 'CMN', 'TAFA478' )", "3" } )
aAdd( aFuncao, { "", "TAFXmlLote( 'CMN', 'R-2020', 'ServPrest', 'TAF478Xml', 5, oBrw)", "5" } )

lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )


If lMenuDif
	ADD OPTION aRotina Title "Visualizar" Action 'VIEWDEF.TAFA478' OPERATION 2 ACCESS 0
Else
	aRotina := TAFMenuReinf( "TAFA478", aFuncao )
EndIf

Return (aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Vitor Siqueira			
@since 15/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruCMN  as object
Local oStruCRO  as object
Local oStruT9Y  as object
Local oStruT9Z  as object
Local oStruV0A  as object
Local oModel	as object

oStruCMN  :=  FWFormStruct( 1, 'CMN' )
oStruCRO  :=  FWFormStruct( 1, 'CRO' )
oStruT9Y  :=  FWFormStruct( 1, 'T9Y' )
oStruT9Z  :=  FWFormStruct( 1, 'T9Z' )
oStruV0A  :=  FWFormStruct( 1, 'V0A' )
oModel    :=  MPFormModel():New( 'TAFA478' , , , {|oModel| SaveModel( oModel ) })

//CMN � Ret. Contrib. Prev. - Servi�os Prestados
oModel:AddFields('MODEL_CMN', /*cOwner*/, oStruCMN)
oModel:GetModel( "MODEL_CMN" ):SetPrimaryKey( { "CMN_PERAPU" } )

//CRO � Detalhamento das notas fiscais
oModel:AddGrid('MODEL_CRO', 'MODEL_CMN', oStruCRO)
oModel:GetModel('MODEL_CRO'):SetUniqueLine({'CRO_SERIE', 'CRO_NUMDOC', 'CRO_NUMFAT'})
oModel:GetModel('MODEL_CRO'):SetMaxLine(9999) 

//T9Y � Inf. Servi�os constantes da Nota Fiscal
oModel:AddGrid('MODEL_T9Y', 'MODEL_CRO', oStruT9Y)
oModel:GetModel('MODEL_T9Y'):SetUniqueLine({'T9Y_TPSERV'})
oModel:GetModel('MODEL_T9Y'):SetMaxLine(9) 

//T9Z � Inf. Proc. de contribui��o previdenci�ria
oModel:AddGrid('MODEL_T9Z', 'MODEL_T9Y', oStruT9Z)
oModel:GetModel('MODEL_T9Z'):SetOptional(.T.)
oModel:GetModel('MODEL_T9Z'):SetUniqueLine({'T9Z_IDPROC', 'T9Z_CODSUS'})
oModel:GetModel('MODEL_T9Z'):SetMaxLine(50) 

//Inf. Proc. de contribui��o previdenci�ria adicional
oModel:AddGrid('MODEL_V0A', 'MODEL_T9Y', oStruV0A)
oModel:GetModel('MODEL_V0A'):SetOptional(.T.)
oModel:GetModel('MODEL_V0A'):SetUniqueLine({'V0A_IDPROC', 'V0A_CODSUS'})
oModel:GetModel('MODEL_V0A'):SetMaxLine(50)

oModel:SetRelation("MODEL_CRO",{ {"CRO_FILIAL","xFilial('CRO')"}, {"CRO_ID","CMN_ID"}, {"CRO_VERSAO","CMN_VERSAO"}} , CRO->(IndexKey(1)) )
oModel:SetRelation("MODEL_T9Y",{ {"T9Y_FILIAL","xFilial('T9Y')"}, {"T9Y_ID","CMN_ID"}, {"T9Y_VERSAO","CMN_VERSAO"}  , {"T9Y_SERIE" ,"CRO_SERIE"} , {"T9Y_NUMDOC","CRO_NUMDOC"} , {"T9Y_NUMFAT","CRO_NUMFAT"}}, T9Y->(IndexKey(1)) )
oModel:SetRelation("MODEL_T9Z",{ {"T9Z_FILIAL","xFilial('T9Z')"}, {"T9Z_ID","CMN_ID"}, {"T9Z_VERSAO","CMN_VERSAO"}} , T9Z->(IndexKey(1)))
oModel:SetRelation('MODEL_V0A',{ {'V0A_FILIAL',"xFilial('V0A')"}, {'V0A_ID','CMN_ID'}, {'V0A_VERSAO','CMN_VERSAO'}} , V0A->(IndexKey(1)))

Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Vitor Siqueira			
@since 15/01/2018
@version 1.0
/*/
//---------------------------------------------------------------------

Static Function ViewDef()

Local oModel   	as object
Local oStruCMNa	as object
Local oStruCMNb	as object
Local oStruCRO	as object
Local oStruT9Y	as object
Local oStruT9Z	as object
Local oStruV0A	as object
Local oView		as object
Local cCmpFil  	as char
Local nI        as numeric
Local aCmpGrp   as array
Local cGrpCom1, cGrpCom2, cGrpCom3 as char

oModel   	:= FWLoadModel( 'TAFA478' )
oStruCMNa	:= Nil
oStruCMNb	:= Nil
oStruCRO	:= FWFormStruct( 2, 'CRO' )
oStruT9Y	:= FWFormStruct( 2, 'T9Y' )
oStruT9Z	:= FWFormStruct( 2, 'T9Z' )
oStruV0A  	:= FWFormStruct( 2, 'V0A' )
oView		:= FWFormView():New()
cCmpFil  	:= ''
nI        	:= 0
aCmpGrp   	:= {}
cGrpCom1  	:= ""
cGrpCom2  	:= ""
cGrpCom3	:= ""

oView:SetModel( oModel )
oView:SetContinuousForm(.T.)

//Identifica��o do Estabelecimento
cGrpCom1  := 'CMN_VERSAO|CMN_VERANT|CMN_PROTPN|CMN_EVENTO|CMN_ATIVO|CMN_PERAPU|CMN_IDESTA|CMN_DESTAB|CMN_TPNUOB|CMN_DOBRA|CMN_TPINSC|CMN_NRINSC|'
cGrpCom2  := 'CMN_NRINST|CMN_TPINST|CMN_INDOBR|CMN_VLRBRU|CMN_VLRBRE|CMN_VLRPRI|CMN_VLRADI|CMN_VLRNPR|CMN_VLRNAD|'
cCmpFil   := cGrpCom1 + cGrpCom2
oStruCMNa := FwFormStruct( 2, 'CMN', {|x| AllTrim( x ) + "|" $ cCmpFil } )

//"Protocolo de Transmiss�o"
cGrpCom3 := 'CMN_PROTUL|'
cCmpFil   := cGrpCom3
oStruCMNb := FwFormStruct( 2, 'CMN', {|x| AllTrim( x ) + "|" $ cCmpFil } )

//Ordena��o de campos na tela
oStruCRO:SetProperty( "CRO_CHVNF" , MVC_VIEW_ORDEM	, "04"	)
oStruCRO:SetProperty( "CRO_NUMDOC", MVC_VIEW_ORDEM	, "06"	)
oStruCRO:SetProperty( "CRO_NUMFAT", MVC_VIEW_ORDEM	, "07"	)
oStruCRO:SetProperty( "CRO_SERIE" , MVC_VIEW_ORDEM	, "08"	)
oStruCRO:SetProperty( "CRO_DTEMIS", MVC_VIEW_ORDEM	, "09"	)
oStruCRO:SetProperty( "CRO_VLRBRU", MVC_VIEW_ORDEM	, "10"	)
oStruCRO:SetProperty( "CRO_OBSERV", MVC_VIEW_ORDEM	, "11"	)

/*-----------------------------------------------------------------------------------
			      Grupo de campos da Comercializa��o de Produ��o	
-------------------------------------------------------------------------------------*/

oStruCMNa:AddGroup( "GRP_COMERCIALIZACAO_01", STR0002, "", 1 ) //Identifica��o do Estabelecimento
oStruCMNa:AddGroup( "GRP_COMERCIALIZACAO_02", STR0003, "", 1 ) //Identifica��o do tomador de servi�os

aCmpGrp := StrToKArr(cGrpCom1,"|")
For nI := 1 to Len(aCmpGrp)
	oStruCMNa:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_COMERCIALIZACAO_01")
Next nI

aCmpGrp := StrToKArr(cGrpCom2,"|")
For nI := 1 to Len(aCmpGrp)
	oStruCMNa:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_COMERCIALIZACAO_02")
Next nI
	
/*--------------------------------------------------------------------------------------------
									Esrutura da View
---------------------------------------------------------------------------------------------*/

oView:AddField( "VIEW_CMNa", oStruCMNa, "MODEL_CMN" )
oView:AddField( "VIEW_CMNb", oStruCMNb, "MODEL_CMN" )
oView:AddGrid ( "VIEW_CRO", oStruCRO, "MODEL_CRO" )
oView:AddGrid ( "VIEW_T9Y", oStruT9Y, "MODEL_T9Y" )
oView:EnableTitleView("MODEL_T9Y",STR0006) //"Tipos de servi�o"
oView:AddGrid ( "VIEW_T9Z", oStruT9Z, "MODEL_T9Z" )
oView:AddGrid ( "VIEW_V0A", oStruV0A, 'MODEL_V0A' )


/*-----------------------------------------------------------------------------------
								Estrutura do Folder
-------------------------------------------------------------------------------------*/
oView:CreateHorizontalBox("PAINEL_PRINCIPAL",100)
oView:CreateFolder("FOLDER_PRINCIPAL","PAINEL_PRINCIPAL")

//////////////////////////////////////////////////////////////////////////////////

oView:AddSheet("FOLDER_PRINCIPAL","ABA01",STR0001) //"Ret. Contrib. Prev. - Servi�os Prestados"
oView:CreateHorizontalBox("CMNa",20,,,"FOLDER_PRINCIPAL","ABA01") 

oView:CreateHorizontalBox("PAINEL_TPCOM",10,,,"FOLDER_PRINCIPAL","ABA01")
oView:CreateFolder( 'FOLDER_TPCOM', 'PAINEL_TPCOM' )

oView:AddSheet( 'FOLDER_TPCOM', 'ABA01', STR0004 ) //"Detalhamento das Notas Fiscais"
oView:CreateHorizontalBox ( 'CRO', 50,,, 'FOLDER_TPCOM'  , 'ABA01' )
oView:CreateHorizontalBox ( 'T9Y', 50,,, 'FOLDER_TPCOM'  , 'ABA01' )

oView:AddSheet( 'FOLDER_TPCOM', 'ABA02', STR0007 ) //"Processos n�o ret. de contrib. prev."
oView:CreateHorizontalBox ( 'T9Z', 50,,, 'FOLDER_TPCOM'  , 'ABA02' )

oView:AddSheet( 'FOLDER_TPCOM', 'ABA03', STR0008 ) //"Processos n�o ret. de contrib. prev. adic"
oView:CreateHorizontalBox ( 'V0A', 50,,, 'FOLDER_TPCOM'  , 'ABA03' )

oView:AddSheet("FOLDER_PRINCIPAL","ABA02",STR0005)//"Recibo de Transmiss�o" 
oView:CreateHorizontalBox("CMNb",100,,,"FOLDER_PRINCIPAL","ABA02")

//////////////////////////////////////////////////////////////////////////////////

/*-----------------------------------------------------------------------------------
							Amarra��o para exibi��o das informa��es
-------------------------------------------------------------------------------------*/

oView:SetOwnerView( "VIEW_CMNa", "CMNa")
oView:SetOwnerView( "VIEW_CMNb", "CMNb")
oView:SetOwnerView( "VIEW_CRO",  "CRO" )
oView:SetOwnerView( "VIEW_T9Y",  "T9Y" )
oView:SetOwnerView( "VIEW_T9Z",  "T9Z" )
oView:SetOwnerView( "VIEW_V0A",  "V0A" )

lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If !lMenuDif
	xFunRmFStr(@oStruCMNa,"CMN")
EndIf

oStruT9Z:RemoveField('T9Z_IDSUSP')
oStruCRO:RemoveField('CRO_IDFAT')
oStruV0A:RemoveField('V0A_IDSUSP')

Return (oView)

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao para valida��o de grava��o do modelo

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
/*/{Protheus.doc} TAF478Xml
Retorna o Xml do Registro Posicionado 
	
@author Vitor Siqueira			
@since 15/01/2018
@version 1.0

@Param:
lJob - Informa se foi chamado por Job

@return
cXml - Estrutura do Xml do Layout S-2020
/*/
//-------------------------------------------------------------------
Function TAF478Xml(cAlias,nRecno,nOpc,lJob)
Local cXml    	as char
Local cLayout 	as char
Local cReg    	as char
Local cPeriodo	as char
Local cNumDoc   as char
Local cNameXSD	as char

Default lJob 	:= .F.
Default cAlias 	:= "CMN"
Default nRecno	:= 1
Default nOpc	:= 1

cLayout		:=	"2020"
cXml		:=	""
cReg		:=	"ServPrest"
cPeriodo	:=	SubStr( CMN->CMN_PERAPU, 3, 4 ) + "-" + SubStr( CMN->CMN_PERAPU, 1, 2 )
cNumDoc		:=	""
cNameXSD 	:= 'PrestadorServicos'

DBSelectArea("CRO")  
CRO->(DBSetOrder(1))

DBSelectArea("T9Y")  
T9Y->(DBSetOrder(1))

DBSelectArea("T9Z") 
T9Z->(DBSetOrder(1))

DBSelectArea("V0A")  
V0A->(DBSetOrder(1))


cXml +=		"<infoServPrest>"	
cXml +=			"<ideEstabPrest>"	
cXml +=				xTafTag("tpInscEstabPrest",CMN->CMN_TPINSC)
cXml +=				xTafTag("nrInscEstabPrest",CMN->CMN_NRINSC)
cXml += 			"<ideTomador>"
cXml +=					xTafTag("tpInscTomador"		 ,CMN->CMN_TPINST)
cXml +=					xTafTag("nrInscTomador"		 ,CMN->CMN_NRINST)
cXml +=					xTafTag("indObra"	 		 ,CMN->CMN_INDOBR) 
cXml +=					xTafTag("vlrTotalBruto"	 	 ,StrTran(Alltrim((TRANSFORM(CMN->CMN_VLRBRU, "@E 9,999,999,999,999.99"))),"." ,""))
cXml +=					xTafTag("vlrTotalBaseRet"	 ,StrTran(Alltrim((TRANSFORM(CMN->CMN_VLRBRE, "@E 9,999,999,999,999.99"))),"." ,""))
cXml +=					xTafTag("vlrTotalRetPrinc"	 ,StrTran(Alltrim((TRANSFORM(CMN->CMN_VLRPRI, "@E 9,999,999,999,999.99"))),"." ,""))
cXml +=					xTafTag("vlrTotalRetAdic"	 ,StrTran(Alltrim((TRANSFORM(CMN->CMN_VLRADI, "@E 9,999,999,999,999.99"))),"." ,""))  
cXml +=					xTafTag("vlrTotalNRetPrinc"	 ,StrTran(Alltrim((TRANSFORM(CMN->CMN_VLRNPR, "@E 9,999,999,999,999.99"))),"." ,""))  	
cXml +=					xTafTag("vlrTotalNRetAdic"	 ,StrTran(Alltrim((TRANSFORM(CMN->CMN_VLRNAD, "@E 9,999,999,999,999.99"))),"." ,"")) 

If CRO->( MsSeek( xFilial( "CRO" ) + CMN->( CMN_ID + CMN_VERSAO) ) )	
	While CRO->(!Eof()) .And. CRO->( CRO_FILIAL + CRO_ID + CRO_VERSAO) == CMN->( CMN_FILIAL + CMN_ID + CMN_VERSAO)
		
		If !Empty(CRO->CRO_NUMDOC)
			cNumDoc := CRO->CRO_NUMDOC
		Else
			cNumDoc := CRO->CRO_NUMFAT
		EndIf
		
		cXml +=			"<nfs>"
		cXml +=				xTafTag("serie"			,CRO->CRO_SERIE )
		cXml +=				xTafTag("numDocto"		,cNumDoc)
		cXml +=				xTafTag("dtEmissaoNF"	,CRO->CRO_DTEMIS)
		cXml +=				xTafTag("vlrBruto"		,StrTran(Alltrim((TRANSFORM(CRO->CRO_VLRBRU, "@E 9,999,999,999,999.99"))),"." ,"")) 
		cXml +=				xTafTag("obs"			,CRO->CRO_OBSERV,,.T.)
		
		If T9Y->( MsSeek( xFilial( "T9Y" ) + CRO->( CRO_ID + CRO_VERSAO + CRO_SERIE + CRO_NUMDOC + CRO_NUMFAT) ) )	
			While T9Y->(!Eof()) .And. T9Y->( T9Y_FILIAL + T9Y_ID + T9Y_VERSAO + T9Y_SERIE + T9Y_NUMDOC + T9Y_NUMFAT) == CRO->( CRO_FILIAL + CRO_ID + CRO_VERSAO + CRO_SERIE + CRO_NUMDOC + CRO_NUMFAT)
				cXml += 	"<infoTpServ>"
				cXml +=			xTafTag("tpServico"				,T9Y->T9Y_CODSER )
				cXml +=			xTafTag("vlrBaseRet"			,StrTran(Alltrim((TRANSFORM(T9Y->T9Y_VLRBAS, "@E 9,999,999,999,999.99"))),"." ,"") ) 
				cXml +=			xTafTag("vlrRetencao"			,StrTran(Alltrim((TRANSFORM(T9Y->T9Y_VLRRET, "@E 9,999,999,999,999.99"))),"." ,"") ) 
				cXml +=			xTafTag("vlrRetSub"				,StrTran(Alltrim((TRANSFORM(T9Y->T9Y_VLRRSU, "@E 9,999,999,999,999.99"))),"." ,"") , ,.T.) 
				cXml +=			xTafTag("vlrNRetPrinc"			,StrTran(Alltrim((TRANSFORM(T9Y->T9Y_VLRNPR, "@E 9,999,999,999,999.99"))),"." ,"") , ,.T.) 
				cXml +=			xTafTag("vlrServicos15"			,StrTran(Alltrim((TRANSFORM(T9Y->T9Y_VLRS15, "@E 9,999,999,999,999.99"))),"." ,"") , ,.T.) 
				cXml +=			xTafTag("vlrServicos20"			,StrTran(Alltrim((TRANSFORM(T9Y->T9Y_VLRS20, "@E 9,999,999,999,999.99"))),"." ,"") , ,.T.) 
				cXml +=			xTafTag("vlrServicos25"			,StrTran(Alltrim((TRANSFORM(T9Y->T9Y_VLRS25, "@E 9,999,999,999,999.99"))),"." ,"") , ,.T.) 
				cXml +=			xTafTag("vlrAdicional"			,StrTran(Alltrim((TRANSFORM(T9Y->T9Y_VLRADI, "@E 9,999,999,999,999.99"))),"." ,"") , ,.T.) 
				cXml +=			xTafTag("vlrNRetAdic"			,StrTran(Alltrim((TRANSFORM(T9Y->T9Y_VLRNRE, "@E 9,999,999,999,999.99"))),"." ,"") , ,.T.) 
				cXml += 	"</infoTpServ>"			
				T9Y->( DbSkip() )								
			EndDo
		EndIf
		
		cXml +=			"</nfs>"
		cNumDoc := ""
		CRO->( DbSkip() )								
	EndDo
EndIf	

If T9Z->( MsSeek( xFilial( "T9Z" ) + CMN->( CMN_ID + CMN_VERSAO) ) )	
	While T9Z->(!Eof()) .And. T9Z->( T9Z_FILIAL + T9Z_ID + T9Z_VERSAO) == CMN->( CMN_FILIAL + CMN_ID + CMN_VERSAO)
		//If CMN->CMN_VLRNPR > 0 .Or. T9Z->T9Z_CODSUS ="92"
			xTafTagGroup("infoProcRetPr" ,{ { "tpProcRetPrinc" ,T9Z->T9Z_TPPROC				 							   ,,.F. }; 
										 ,  { "nrProcRetPrinc" ,T9Z->T9Z_NUMPRO			                                   ,,.F. };
										 ,  { "codSuspPrinc"   ,T9Z->T9Z_CODSUS                                 		   ,,.T. };
										 ,  { "valorPrinc"     ,StrTran(Alltrim((TRANSFORM(T9Z->T9Z_VLRPRI, "@E 9,999,999,999,999.99"))),"." ,"")											   ,,.F. }};
										 ,  @cXml)
		//EndIf

		T9Z->( DbSkip() )								
	EndDo
EndIf	

If V0A->( MsSeek( xFilial( "V0A" ) + CMN->( CMN_ID + CMN_VERSAO) ) )	
	While V0A->(!Eof()) .And. V0A->( V0A_FILIAL + V0A_ID + V0A_VERSAO) == CMN->( CMN_FILIAL + CMN_ID + CMN_VERSAO)
		If CMN->CMN_VLRNPR > 0 .Or. V0A->V0A_CODSUS $ "92"
			xTafTagGroup("infoProcRetAd" ,{ { "tpProcRetAdic"  ,V0A->V0A_TPPROC				 							   ,,.F. }; 
										 ,  { "nrProcRetAdic"  ,V0A->V0A_NUMPRO			                                   ,,.F. };
										 ,  { "codSuspAdic"    ,V0A->V0A_CODSUS                                 		   ,,.T. };
										 ,  { "valorAdic"      ,StrTran(Alltrim((TRANSFORM(V0A->V0A_VLRADI, "@E 9,999,999,999,999.99"))),"." ,"")											   ,,.F. }};
										 ,  @cXml)
		EndIf

		V0A->( DbSkip() )								
	EndDo
EndIf	
	
cXml += 			"</ideTomador>"
cXml +=			"</ideEstabPrest>"	
cXml +=		"</infoServPrest>"

/*����������������������Ŀ
  �Estrutura do cabecalho�
  ������������������������*/
cXml := TAFXmlReinf( cXml, "CMN", cLayout, cReg, cPeriodo,, cNameXSD)


/*����������������������������Ŀ
  �Executa gravacao do registro�
  ������������������������������*/
If !lJob
	xTafGerXml(cXml,cLayout,,,,,,"R-" )
EndIf

	
Return(cXml)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} TAF478Vld

@author Vitor Siqueira			
@since 15/01/2018
@version 1.0
/*/                                                                                                                                          
//------------------------------------------------------------------------------------
Function TAF478Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro   as array
Local aDadosUtil as array
Local lValida    as logical   

Default lJob := .F.

aLogErro   := {}
aDadosUtil := {}
lValida    := CMN->CMN_STATUS $ ( " |1" )

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := CMN->( Recno() )

If !lValida
	aAdd( aLogErro, { "CMN_ID", "000305", "CMN", nRecno } ) //Registros que j� foram transmitidos ao Fisco, n�o podem ser validados
Else
	
	
	//�������������������������������
	//�ATUALIZO O STATUS DO REGISTRO�
	//�1 = Registro Invalido        �
	//�0 = Registro Valido          �
	//�������������������������������
	cStatus := Iif( Len( aLogErro ) > 0, "1", "0" )
	Begin Transaction 
		If RecLock( "CMN", .F. )
			CMN->CMN_STATUS := cStatus
			CMN->( MsUnlock() )
		EndIf
	End Transaction 
	
EndIf

//�������������������������������������������������������Ŀ
//�Nao apresento o alert quando utilizo o JOB para validar�
//���������������������������������������������������������
If !lJob
	xValLogEr( aLogErro )
EndIf

Return(aLogErro)

//---------------------------------------------------------------------
/*/{Protheus.doc} GerarEvtExc
@type			function
@description	Fun��o com o objetivo de gerar o Evento de Exclus�o.
@author			Vitor Henrique Ferreira
@since			07/02/2018
@version		1.0
@param			oModel	-	Modelo de dados
@param			nRecno	-	N�mero do registro
@param			lRotExc	-	Vari�vel que controla se a function � chamada pelo TafIntegraESocial
/*/
//---------------------------------------------------------------------
Static Function GerarEvtExc( oModel, nRecno, lRotExc )

Local oModelCMN		as object
Local oModelCRO		as object
Local oModelT9Y		as object
Local oModelT9Z		as object
Local oModelV0A		as object
Local cVerAnt		as char
Local cRecibo		as char
Local cVersao		as char
Local nI			as numeric
Local nCRO			as numeric
Local nT9Y			as numeric
Local nT9YAdd		as numeric
Local nT9Z			as numeric
Local nV0A			as numeric
Local aGravaCMN		as array
Local aGravaCRO		as array
Local aGravaT9Y		as array
Local aGravaT9Z		as array
Local aGravaV0A		as array

oModelCMN	:=	Nil
oModelCRO	:=	Nil
oModelT9Y	:=	Nil
oModelT9Z	:=	Nil
oModelV0A	:=	Nil
cVerAnt		:=	""
cRecibo		:=	""
cVersao		:=	""
nI			:=	0
nCRO		:=	0
nT9Y		:=	0
nT9YAdd		:=	0
nT9Z		:=	0
nV0A		:=	0
aGravaCMN	:=	{}
aGravaCRO	:=	{}
aGravaT9Y	:=	{}
aGravaT9Z	:=	{}
aGravaV0A	:=	{}

Begin Transaction

	DBSelectArea( "CMN" )
	CMN->( DBGoTo( nRecno ) )

	oModelCMN := oModel:GetModel( "MODEL_CMN" )
	oModelCRO := oModel:GetModel( "MODEL_CRO" )
	oModelT9Y := oModel:GetModel( "MODEL_T9Y" )
	oModelT9Z := oModel:GetModel( "MODEL_T9Z" )
	oModelV0A := oModel:GetModel( "MODEL_V0A" )

	//************************************
	//Informa��es para grava��o do rastro
	//************************************
	cVerAnt := oModelCMN:GetValue( "CMN_VERSAO" )
	cRecibo := oModelCMN:GetValue( "CMN_PROTUL" )

	//****************************************************************************************************************
	//Armazeno as informa��es que foram modificadas na tela, para utiliza��o em opera��o de inclus�o de novo registro
	//****************************************************************************************************************
	For nI := 1 to Len( oModelCMN:aDataModel[1] )
		aAdd( aGravaCMN, { oModelCMN:aDataModel[1,nI,1], oModelCMN:aDataModel[1,nI,2] } )
	Next nI

	//CRO
	If CRO->( MsSeek( xFilial( "CRO" ) + CMN->( CMN_ID + CMN_VERSAO ) ) )

		For nCRO := 1 to oModel:GetModel( "MODEL_CRO" ):Length()
			oModel:GetModel( "MODEL_CRO" ):GoLine( nCRO )

			If !oModel:GetModel( "MODEL_CRO" ):IsEmpty() .and. !oModel:GetModel( "MODEL_CRO" ):IsDeleted()
				aAdd( aGravaCRO, {	oModelCRO:GetValue( "CRO_CHVNF"  ),;
									oModelCRO:GetValue( "CRO_NUMFAT" ),;
									oModelCRO:GetValue( "CRO_IDFAT"  ),;
									oModelCRO:GetValue( "CRO_SERIE"  ),;
									oModelCRO:GetValue( "CRO_NUMDOC" ),;
									oModelCRO:GetValue( "CRO_DTEMIS" ),;
									oModelCRO:GetValue( "CRO_VLRBRU" ),;
									oModelCRO:GetValue( "CRO_OBSERV" ) } )

				//T9Y
				For nT9Y := 1 to oModel:GetModel( "MODEL_T9Y" ):Length()
					oModel:GetModel( "MODEL_T9Y" ):GoLine( nT9Y )
					If !oModel:GetModel( "MODEL_T9Y" ):IsEmpty() .and. !oModel:GetModel( "MODEL_T9Y" ):IsDeleted()
						aAdd( aGravaT9Y, {	oModelCRO:GetValue( "CRO_SERIE" ),; 
											oModelCRO:GetValue( "CRO_NUMDOC" ),;
											oModelCRO:GetValue( "CRO_NUMFAT" ),; 
											oModelT9Y:GetValue( "T9Y_TPSERV" ),;
											oModelT9Y:GetValue( "T9Y_CODSER" ),;
											oModelT9Y:GetValue( "T9Y_DTPSER" ),;
											oModelT9Y:GetValue( "T9Y_VLRBAS" ),;
											oModelT9Y:GetValue( "T9Y_VLRRET" ),;
											oModelT9Y:GetValue( "T9Y_VLRRSU" ),;
											oModelT9Y:GetValue( "T9Y_VLRNPR" ),;
											oModelT9Y:GetValue( "T9Y_VLRS15" ),;
											oModelT9Y:GetValue( "T9Y_VLRS20" ),;
											oModelT9Y:GetValue( "T9Y_VLRS25" ),;
											oModelT9Y:GetValue( "T9Y_VLRADI" ),;
											oModelT9Y:GetValue( "T9Y_VLRNRE" ) } )
					EndIf
				Next nT9Y
			EndIf
		Next nCRO
	EndIf

	//T9Z
	If T9Z->( MsSeek( xFilial( "T9Z" ) + CMN->( CMN_ID + CMN_VERSAO ) ) )

		For nT9Z := 1 to oModel:GetModel( "MODEL_T9Z" ):Length()
			oModel:GetModel( "MODEL_T9Z" ):GoLine( nT9Z )

			If !oModel:GetModel( "MODEL_T9Z" ):IsEmpty() .and. !oModel:GetModel( "MODEL_T9Z" ):IsDeleted()
				aAdd( aGravaT9Z, {	oModelT9Z:GetValue( "T9Z_IDPROC" ),;
									oModelT9Z:GetValue( "T9Z_TPPROC" ),;
									oModelT9Z:GetValue( "T9Z_NUMPRO" ),;
									oModelT9Z:GetValue( "T9Z_CODSUS" ),;
									oModelT9Z:GetValue( "T9Z_IDSUSP" ),;
									oModelT9Z:GetValue( "T9Z_VLRPRI" ) } )
			EndIf
		Next nT9Z
	EndIf
	
	//V0A
	If V0A->( MsSeek( xFilial( "V0A" ) + CMN->( CMN_ID + CMN_VERSAO ) ) )

		For nV0A := 1 to oModel:GetModel( "MODEL_V0A" ):Length()
			oModel:GetModel( "MODEL_V0A" ):GoLine( nV0A )
	
			If !oModel:GetModel( "MODEL_V0A" ):IsEmpty() .and. !oModel:GetModel( "MODEL_V0A" ):IsDeleted()
				aAdd( aGravaV0A, {	oModelV0A:GetValue( "V0A_IDPROC" ),;
									oModelV0A:GetValue( "V0A_TPPROC" ),;
									oModelV0A:GetValue( "V0A_NUMPRO" ),;
									oModelV0A:GetValue( "V0A_CODSUS" ),;
									oModelV0A:GetValue( "V0A_IDSUSP" ),;
									oModelV0A:GetValue( "V0A_VLRADI" ) } )
			EndIf
		Next nV0A
	EndIf
	
	//*****************************
	//Seto o registro como Inativo
	//*****************************
	FAltRegAnt( "CMN", "2" )

	//**************************************
	//Opera��o de Inclus�o de novo registro
	//**************************************
	oModel:DeActivate()
	oModel:SetOperation( 3 )
	oModel:Activate()

	//********************************************************************************
	//Inclus�o do novo registro j� considerando as informa��es alteradas pelo usu�rio
	//********************************************************************************
	For nI := 1 to Len( aGravaCMN )
		oModel:LoadValue( "MODEL_CMN", aGravaCMN[nI,1], aGravaCMN[nI,2] )
	Next nI

	//CRO
	For nCRO := 1 to Len( aGravaCRO )

		oModel:GetModel( "MODEL_CRO" ):LVALID := .T.

		If nCRO > 1
			oModel:GetModel( "MODEL_CRO" ):AddLine()
		EndIf

		oModel:LoadValue( "MODEL_CRO", "CRO_CHVNF" , aGravaCRO[nCRO][1] )
		oModel:LoadValue( "MODEL_CRO", "CRO_NUMFAT", aGravaCRO[nCRO][2] )
		oModel:LoadValue( "MODEL_CRO", "CRO_IDFAT" , aGravaCRO[nCRO][3] )
		oModel:LoadValue( "MODEL_CRO", "CRO_SERIE" , aGravaCRO[nCRO][4] )
		oModel:LoadValue( "MODEL_CRO", "CRO_NUMDOC", aGravaCRO[nCRO][5] )
		oModel:LoadValue( "MODEL_CRO", "CRO_DTEMIS", aGravaCRO[nCRO][6] )
		oModel:LoadValue( "MODEL_CRO", "CRO_VLRBRU", aGravaCRO[nCRO][7] )
		oModel:LoadValue( "MODEL_CRO", "CRO_OBSERV", aGravaCRO[nCRO][8] )

		//T9Y
		nT9YAdd := 1
		For nT9Y := 1 to Len( aGravaT9Y )
			If aGravaCRO[nCRO][4] == aGravaT9Y[nT9Y][1]  .And. aGravaCRO[nCRO][5] == aGravaT9Y[nT9Y][2] .And. aGravaCRO[nCRO][2] == aGravaT9Y[nT9Y][3]

				oModel:GetModel( "MODEL_T9Y" ):LVALID := .T.

				If nT9YAdd > 1
					oModel:GetModel( "MODEL_T9Y" ):AddLine()
				EndIf
				

				oModel:LoadValue( "MODEL_T9Y", "T9Y_TPSERV", aGravaT9Y[nT9Y][4] )
				oModel:LoadValue( "MODEL_T9Y", "T9Y_CODSER", aGravaT9Y[nT9Y][5] )
				oModel:LoadValue( "MODEL_T9Y", "T9Y_DTPSER", aGravaT9Y[nT9Y][6] )
				oModel:LoadValue( "MODEL_T9Y", "T9Y_VLRBAS", aGravaT9Y[nT9Y][7] )
				oModel:LoadValue( "MODEL_T9Y", "T9Y_VLRRET", aGravaT9Y[nT9Y][8] )
				oModel:LoadValue( "MODEL_T9Y", "T9Y_VLRRSU", aGravaT9Y[nT9Y][9] )
				oModel:LoadValue( "MODEL_T9Y", "T9Y_VLRNPR", aGravaT9Y[nT9Y][10] )
				oModel:LoadValue( "MODEL_T9Y", "T9Y_VLRS15", aGravaT9Y[nT9Y][11] )
				oModel:LoadValue( "MODEL_T9Y", "T9Y_VLRS20", aGravaT9Y[nT9Y][12] )
				oModel:LoadValue( "MODEL_T9Y", "T9Y_VLRS25", aGravaT9Y[nT9Y][13] )
				oModel:LoadValue( "MODEL_T9Y", "T9Y_VLRADI", aGravaT9Y[nT9Y][14] )
				oModel:LoadValue( "MODEL_T9Y", "T9Y_VLRNRE", aGravaT9Y[nT9Y][15] )

				nT9YAdd ++
			EndIf
		Next nT9Y
	Next nCRO
		
	For nT9Z := 1 to Len( aGravaT9Z )

		oModel:GetModel( "MODEL_T9Z" ):LVALID := .T.

		If nCRO > 1
			oModel:GetModel( "MODEL_T9Z" ):AddLine()
		EndIf

		oModel:LoadValue( "MODEL_T9Z", "T9Z_IDPROC", aGravaT9Z[nT9Z][1] )
		oModel:LoadValue( "MODEL_T9Z", "T9Z_TPPROC", aGravaT9Z[nT9Z][2] )
		oModel:LoadValue( "MODEL_T9Z", "T9Z_NUMPRO", aGravaT9Z[nT9Z][3] )
		oModel:LoadValue( "MODEL_T9Z", "T9Z_CODSUS", aGravaT9Z[nT9Z][4] )
		oModel:LoadValue( "MODEL_T9Z", "T9Z_IDSUSP", aGravaT9Z[nT9Z][5] )
		oModel:LoadValue( "MODEL_T9Z", "T9Z_VLRPRI", aGravaT9Z[nT9Z][6] )

	Next nT9Z
	
	For nV0A := 1 to Len( aGravaV0A )

		oModel:GetModel( "MODEL_V0A" ):LVALID := .T.

		If nCRO > 1
			oModel:GetModel( "MODEL_V0A" ):AddLine()
		EndIf

		oModel:LoadValue( "MODEL_V0A", "V0A_IDPROC", aGravaV0A[nV0A][1] )
		oModel:LoadValue( "MODEL_V0A", "V0A_TPPROC", aGravaV0A[nV0A][2] )
		oModel:LoadValue( "MODEL_V0A", "V0A_NUMPRO", aGravaV0A[nV0A][3] )
		oModel:LoadValue( "MODEL_V0A", "V0A_CODSUS", aGravaV0A[nV0A][4] )
		oModel:LoadValue( "MODEL_V0A", "V0A_IDSUSP", aGravaV0A[nV0A][5] )
		oModel:LoadValue( "MODEL_V0A", "V0A_VLRADI", aGravaV0A[nV0A][6] )

	Next nV0A

	//*****************************************
	//Vers�o que ser� gravada no novo registro
	//*****************************************
	cVersao := xFunGetVer()

	//********************************************************************
	//ATEN��O
	//A altera��o destes campos devem sempre estar abaixo do loop do For,
	//pois devem substituir as informações que foram armazenadas acima
	//********************************************************************
	oModel:LoadValue( "MODEL_CMN", "CMN_VERSAO", cVersao )
	oModel:LoadValue( "MODEL_CMN", "CMN_VERANT", cVerAnt )
	oModel:LoadValue( "MODEL_CMN", "CMN_PROTPN", cRecibo )
	oModel:LoadValue( "MODEL_CMN", "CMN_PROTUL", "" )

	oModel:LoadValue( "MODEL_CMN", "CMN_EVENTO", "E" )
	oModel:LoadValue( "MODEL_CMN", "CMN_ATIVO", "1" )

	FWFormCommit( oModel )
	TAFAltStat( "CMN", "6" )

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
	oBrw:SetDescription( "R-2020 - "+STR0001 )	//"Retenção Contribuição Previdenciária - Serviços Prestados"
	oBrw:SetAlias( 'CMN')
	oBrw:SetMenuDef( 'TAFA478' )	
	oBrw:SetFilterDefault( "CMN_ATIVO == '1'" )

	//DbSelectArea("CMN")
	//Set Filter TO &("CMN_ATIVO == '1'")
	
	If FindFunction("TAFLegReinf")
		TAFLegReinf( "CMN", oBrw)
	Else
		TafLegend(2,"CMN",@oBrw)
	EndIf
	oBrw:Activate()
	
Return( oBrw )
