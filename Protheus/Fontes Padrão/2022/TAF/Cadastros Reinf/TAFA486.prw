#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA486.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA486
Cadastro MVC do R-2010 - Reten��o Contribui��o Previdenci�ria - Servi�os Tomados

@author Vitor Siqueira			
@since 15/01/2018
@version 1.0

/*/
//-------------------------------------------------------------------

Function TAFA486()

If TAFAlsInDic( "T95" )
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

aAdd( aFuncao, { "", "TAF486Xml", "1" } )
aAdd( aFuncao, { "", "xFunNewHis( 'T95', 'TAFA486' )", "3" } )
aAdd( aFuncao, { "", "TAFXmlLote( 'T95', 'R-2010', 'ServTom', 'TAF486Xml', 5, oBrw)", "5" } )

lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If lMenuDif
	ADD OPTION aRotina Title "Visualizar"       Action 'VIEWDEF.TAFA486' OPERATION 2 ACCESS 0
Else
	aRotina := TAFMenuReinf( "TAFA486", aFuncao )
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
Local oStruT95  as object
Local oStruT96  as object
Local oStruT97  as object
Local oStruT98  as object
Local oStruT99  as object
Local oModel	as object

oStruT95  :=  FWFormStruct( 1, 'T95' )
oStruT96  :=  FWFormStruct( 1, 'T96' )
oStruT97  :=  FWFormStruct( 1, 'T97' )
oStruT98  :=  FWFormStruct( 1, 'T98' )
oStruT99  :=  FWFormStruct( 1, 'T99' )
oModel    :=  MPFormModel():New( 'TAFA486' , , , {|oModel| SaveModel( oModel ) })

//T95 � Ret. Contrib. Prev. - Servi�os Tomados
oModel:AddFields('MODEL_T95', /*cOwner*/, oStruT95)
oModel:GetModel( "MODEL_T95" ):SetPrimaryKey( { "T95_PERAPU" } )

//T96 � Detalhamento das notas fiscais
oModel:AddGrid('MODEL_T96', 'MODEL_T95', oStruT96)
oModel:GetModel('MODEL_T96'):SetUniqueLine({'T96_SERIE', 'T96_NUMDOC', 'T96_NUMFAT'})
oModel:GetModel('MODEL_T96'):SetMaxLine(9999) 

//T97 � Inf. Servi�os constantes da Nota Fiscal
oModel:AddGrid('MODEL_T97', 'MODEL_T96', oStruT97)
oModel:GetModel('MODEL_T97'):SetUniqueLine({'T97_TPSERV'})
oModel:GetModel('MODEL_T97'):SetMaxLine(9) 

//T98 � Inf. Proc. de contribui��o previdenci�ria
oModel:AddGrid('MODEL_T98', 'MODEL_T97', oStruT98)
oModel:GetModel('MODEL_T98'):SetOptional(.T.)
oModel:GetModel('MODEL_T98'):SetUniqueLine({'T98_IDPROC', 'T98_CODSUS'})
oModel:GetModel('MODEL_T98'):SetMaxLine(50) 

//Inf. Proc. de contribui��o previdenci�ria adicional
oModel:AddGrid('MODEL_T99', 'MODEL_T97', oStruT99)
oModel:GetModel('MODEL_T99'):SetOptional(.T.)
oModel:GetModel('MODEL_T99'):SetUniqueLine({'T99_IDPROC', 'T99_CODSUS'})
oModel:GetModel('MODEL_T99'):SetMaxLine(50)

oModel:SetRelation("MODEL_T96",{ {"T96_FILIAL","xFilial('T96')"}, {"T96_ID","T95_ID"}, {"T96_VERSAO","T95_VERSAO"}} , T96->(IndexKey(1)) )
oModel:SetRelation("MODEL_T97",{ {"T97_FILIAL","xFilial('T97')"}, {"T97_ID","T95_ID"}, {"T97_VERSAO","T95_VERSAO"}  , {"T97_SERIE" ,"T96_SERIE"} , {"T97_NUMDOC","T96_NUMDOC"}, {"T97_NUMFAT","T96_NUMFAT"}}, T97->(IndexKey(1)) )
oModel:SetRelation("MODEL_T98",{ {"T98_FILIAL","xFilial('T98')"}, {"T98_ID","T95_ID"}, {"T98_VERSAO","T95_VERSAO"}} , T98->(IndexKey(1)))
oModel:SetRelation('MODEL_T99',{ {'T99_FILIAL',"xFilial('T99')"}, {'T99_ID','T95_ID'}, {'T99_VERSAO','T95_VERSAO'}} , T99->(IndexKey(1)))

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
Local oStruT95a	as object
Local oStruT95b	as object
Local oStruT96	as object
Local oStruT97	as object
Local oStruT98	as object
Local oStruT99	as object
Local oView		as object
Local cCmpFil  	as char
Local nI        as numeric
Local aCmpGrp   as array
Local cGrpCom1, cGrpCom2, cGrpCom3 as char

oModel   	:= FWLoadModel( 'TAFA486' )
oStruT95a	:= Nil
oStruT95b	:= Nil
oStruT96	:= FWFormStruct( 2, 'T96' )
oStruT97	:= FWFormStruct( 2, 'T97' )
oStruT98	:= FWFormStruct( 2, 'T98' )
oStruT99  	:= FWFormStruct( 2, 'T99' )
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
cGrpCom1  := 'T95_VERSAO|T95_VERANT|T95_PROTPN|T95_EVENTO|T95_ATIVO|T95_PERAPU|T95_IDESTA|T95_DESTAB|T95_TPNUOB|T95_DOBRA|T95_TPINSC|T95_NRINSC|T95_INDOBR|'
cGrpCom2  := 'T95_CODPAR|T95_DPARTI|T95_CNPJPR|T95_VLRBRU|T95_VLRBRE|T95_VLRPRI|T95_VLRADI|T95_VLRNPR|T95_VLRNAD|T95_INDCPR|'
cCmpFil   := cGrpCom1 + cGrpCom2
oStruT95a := FwFormStruct( 2, 'T95', {|x| AllTrim( x ) + "|" $ cCmpFil } )

//"Protocolo de Transmiss�o"
cGrpCom3 := 'T95_PROTUL|'
cCmpFil   := cGrpCom3
oStruT95b := FwFormStruct( 2, 'T95', {|x| AllTrim( x ) + "|" $ cCmpFil } )

/*-----------------------------------------------------------------------------------
			      Grupo de campos da Comercializa��o de Produ��o	
-------------------------------------------------------------------------------------*/

oStruT95a:AddGroup( "GRP_COMERCIALIZACAO_01", STR0002, "", 1 ) //Identifica��o do Estabelecimento
oStruT95a:AddGroup( "GRP_COMERCIALIZACAO_02", STR0003, "", 1 ) //Identifica��o do prestador de servi�os

aCmpGrp := StrToKArr(cGrpCom1,"|")
For nI := 1 to Len(aCmpGrp)
	oStruT95a:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_COMERCIALIZACAO_01")
Next nI

aCmpGrp := StrToKArr(cGrpCom2,"|")
For nI := 1 to Len(aCmpGrp)
	oStruT95a:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_COMERCIALIZACAO_02")
Next nI
	
/*--------------------------------------------------------------------------------------------
									Esrutura da View
---------------------------------------------------------------------------------------------*/

oView:AddField( "VIEW_T95a", oStruT95a, "MODEL_T95" )
oView:AddField( "VIEW_T95b", oStruT95b, "MODEL_T95" )
oView:AddGrid ( "VIEW_T96", oStruT96, "MODEL_T96" )
oView:AddGrid ( "VIEW_T97", oStruT97, "MODEL_T97" )
oView:EnableTitleView("MODEL_T97",STR0006) //"Tipos de servi�o"
oView:AddGrid ( "VIEW_T98", oStruT98, "MODEL_T98" )
oView:AddGrid ( "VIEW_T99", oStruT99, 'MODEL_T99' )


/*-----------------------------------------------------------------------------------
								Estrutura do Folder
-------------------------------------------------------------------------------------*/
oView:CreateHorizontalBox("PAINEL_PRINCIPAL",100)
oView:CreateFolder("FOLDER_PRINCIPAL","PAINEL_PRINCIPAL")

//////////////////////////////////////////////////////////////////////////////////

oView:AddSheet("FOLDER_PRINCIPAL","ABA01",STR0001) //"Ret. Contrib. Prev. - Servi�os Tomados"
oView:CreateHorizontalBox("T95a",20,,,"FOLDER_PRINCIPAL","ABA01") 

oView:CreateHorizontalBox("PAINEL_TPCOM",10,,,"FOLDER_PRINCIPAL","ABA01")
oView:CreateFolder( 'FOLDER_TPCOM', 'PAINEL_TPCOM' )

oView:AddSheet( 'FOLDER_TPCOM', 'ABA01', STR0004 ) //"Detalhamento das Notas Fiscais"
oView:CreateHorizontalBox ( 'T96', 50,,, 'FOLDER_TPCOM'  , 'ABA01' )
oView:CreateHorizontalBox ( 'T97', 50,,, 'FOLDER_TPCOM'  , 'ABA01' )

oView:AddSheet( 'FOLDER_TPCOM', 'ABA02', STR0007 ) //"Processos n�o ret. de contrib. prev."
oView:CreateHorizontalBox ( 'T98', 50,,, 'FOLDER_TPCOM'  , 'ABA02' )

oView:AddSheet( 'FOLDER_TPCOM', 'ABA03', STR0008 ) //"Processos n�o ret. de contrib. prev. adic"
oView:CreateHorizontalBox ( 'T99', 50,,, 'FOLDER_TPCOM'  , 'ABA03' )

oView:AddSheet("FOLDER_PRINCIPAL","ABA02",STR0005)//"Recibo de Transmiss�o" 
oView:CreateHorizontalBox("T95b",100,,,"FOLDER_PRINCIPAL","ABA02")

//////////////////////////////////////////////////////////////////////////////////

/*-----------------------------------------------------------------------------------
							Amarra��o para exibi��o das informa��es
-------------------------------------------------------------------------------------*/

oView:SetOwnerView( "VIEW_T95a", "T95a")
oView:SetOwnerView( "VIEW_T95b", "T95b")
oView:SetOwnerView( "VIEW_T96",  "T96" )
oView:SetOwnerView( "VIEW_T97",  "T97" )
oView:SetOwnerView( "VIEW_T98",  "T98" )
oView:SetOwnerView( "VIEW_T99",  "T99" )

lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If !lMenuDif
	xFunRmFStr(@oStruT95a,"T95")
EndIf

oStruT96:RemoveField('T96_IDFAT')
oStruT98:RemoveField('T98_IDSUSP')
oStruT99:RemoveField('T99_IDSUSP')

Return (oView)

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao para validação de gravação do modelo

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
/*/{Protheus.doc} TAF486Xml
Retorna o Xml do Registro Posicionado 
	
@author Vitor Siqueira			
@since 15/01/2018
@version 1.0

@Param:
lJob - Informa se foi chamado por Job

@return
cXml - Estrutura do Xml do Layout S-2010
/*/
//-------------------------------------------------------------------
Function TAF486Xml(cAlias,nRecno,nOpc,lJob)
Local cXml    	as char
Local cLayout 	as char
Local cReg    	as char
Local cPeriodo	as char
Local cNumDoc	as char
Local cNameXSD  as char

Default lJob 	:= .F.
Default cAlias 	:= "T95"
Default nRecno	:= 1
Default nOpc	:= 1

cLayout 	:= "2010"
cXml    	:= ""
cReg    	:= "ServTom" 
cPeriodo	:= Substr(T95->T95_PERAPU,3) + "-" + Substr(T95->T95_PERAPU,1,2) 
cNumDoc		:= ""
cNameXSD	:= 'TomadorServicos'

DBSelectArea("T96")  
T96->(DBSetOrder(1))

DBSelectArea("T97")  
T97->(DBSetOrder(1))

DBSelectArea("T98") 
T98->(DBSetOrder(1))

DBSelectArea("T99")  
T99->(DBSetOrder(1))

cXml +=		"<infoServTom>"	
cXml +=			"<ideEstabObra>"	
cXml +=				xTafTag("tpInscEstab",T95->T95_TPINSC)
cXml +=				xTafTag("nrInscEstab",T95->T95_NRINSC)
cXml +=				xTafTag("indObra"	 ,T95->T95_INDOBR) 
cXml += 			"<idePrestServ>"
cXml +=					xTafTag("cnpjPrestador"	 	 ,T95->T95_CNPJPR) 
cXml +=					xTafTag("vlrTotalBruto"	 	 , StrTran(Alltrim((TRANSFORM(T95->T95_VLRBRU, "@E 9,999,999,999,999.99"))),"." ,""))
cXml +=					xTafTag("vlrTotalBaseRet"	 , StrTran(Alltrim((TRANSFORM(T95->T95_VLRBRE, "@E 9,999,999,999,999.99"))),"." ,""))
cXml +=					xTafTag("vlrTotalRetPrinc"	 , StrTran(Alltrim((TRANSFORM(T95->T95_VLRPRI, "@E 9,999,999,999,999.99"))),"." ,""))
cXml +=					xTafTag("vlrTotalRetAdic"	 , StrTran(Alltrim((TRANSFORM(T95->T95_VLRADI, "@E 9,999,999,999,999.99"))),"." ,""))  
cXml +=					xTafTag("vlrTotalNRetPrinc"	 , StrTran(Alltrim((TRANSFORM(T95->T95_VLRNPR, "@E 9,999,999,999,999.99"))),"." ,""))  	
cXml +=					xTafTag("vlrTotalNRetAdic"	 , StrTran(Alltrim((TRANSFORM(T95->T95_VLRNAD, "@E 9,999,999,999,999.99"))),"." ,"")) 
cXml +=					xTafTag("indCPRB"	 		 ,T95->T95_INDCPR)  

If T96->( MsSeek( xFilial( "T96" ) + T95->( T95_ID + T95_VERSAO) ) )	
	While T96->(!Eof()) .And. T96->( T96_FILIAL + T96_ID + T96_VERSAO) == T95->( T95_FILIAL + T95_ID + T95_VERSAO)
		
		If !Empty(T96->T96_NUMDOC)
			cNumDoc := T96->T96_NUMDOC
		Else
			cNumDoc := T96->T96_NUMFAT
		EndIf
		
		cXml +=			"<nfs>"
		cXml +=				xTafTag("serie"			,T96->T96_SERIE )
		cXml +=				xTafTag("numDocto"		,cNumDoc)
		cXml +=				xTafTag("dtEmissaoNF"	,T96->T96_DTEMIS)
		cXml +=				xTafTag("vlrBruto"		,StrTran(Alltrim((TRANSFORM(T96->T96_VLBRUT, "@E 9,999,999,999,999.99"))),"." ,""))
		cXml +=				xTafTag("obs"			,T96->T96_OBSERV,,.T.)
		
		If T97->( MsSeek( xFilial( "T97" ) + T96->( T96_ID + T96_VERSAO + T96_SERIE + T96_NUMDOC + T96_NUMFAT) ) )	
			While T97->(!Eof()) .And. T97->( T97_FILIAL + T97_ID + T97_VERSAO + T97_SERIE + T97_NUMDOC + T97_NUMFAT) == T96->( T96_FILIAL + T96_ID + T96_VERSAO + T96_SERIE + T96_NUMDOC + T96_NUMFAT)
				cXml += 	"<infoTpServ>"
				cXml +=			xTafTag("tpServico"				,T97->T97_CODSER )
				cXml +=			xTafTag("vlrBaseRet"			, StrTran(Alltrim((TRANSFORM(T97->T97_VLRBAS, "@E 9,999,999,999,999.99"))),"." ,"") ) 
				cXml +=			xTafTag("vlrRetencao"			, StrTran(Alltrim((TRANSFORM(T97->T97_VLRRET, "@E 9,999,999,999,999.99"))),"." ,"") ) 
				cXml +=			xTafTag("vlrRetSub"				, StrTran(Alltrim((TRANSFORM(T97->T97_VLRRSU, "@E 9,999,999,999,999.99"))),"." ,"") , ,.T.) 
				cXml +=			xTafTag("vlrNRetPrinc"			, StrTran(Alltrim((TRANSFORM(T97->T97_VLRNPR, "@E 9,999,999,999,999.99"))),"." ,"") , ,.T.) 
				cXml +=			xTafTag("vlrServicos15"			, StrTran(Alltrim((TRANSFORM(T97->T97_VLRS15, "@E 9,999,999,999,999.99"))),"." ,"") , ,.T.) 
				cXml +=			xTafTag("vlrServicos20"			, StrTran(Alltrim((TRANSFORM(T97->T97_VLRS20, "@E 9,999,999,999,999.99"))),"." ,"") , ,.T.) 
				cXml +=			xTafTag("vlrServicos25"			, StrTran(Alltrim((TRANSFORM(T97->T97_VLRS25, "@E 9,999,999,999,999.99"))),"." ,"") , ,.T.) 
				cXml +=			xTafTag("vlrAdicional"			, StrTran(Alltrim((TRANSFORM(T97->T97_VLRADI, "@E 9,999,999,999,999.99"))),"." ,"") , ,.T.) 
				cXml +=			xTafTag("vlrNRetAdic"			, StrTran(Alltrim((TRANSFORM(T97->T97_VLRNRE, "@E 9,999,999,999,999.99"))),"." ,"") , ,.T.) 
				cXml += 	"</infoTpServ>"			
				T97->( DbSkip() )								
			EndDo
		EndIf
		
		cXml +=			"</nfs>"
		cNumDoc := ""
		T96->( DbSkip() )								
	EndDo
EndIf	

If T98->( MsSeek( xFilial( "T98" ) + T95->( T95_ID + T95_VERSAO) ) )	
	While T98->(!Eof()) .And. T98->( T98_FILIAL + T98_ID + T98_VERSAO) == T95->( T95_FILIAL + T95_ID + T95_VERSAO)
	//	If T95->T95_VLRNPR > 0 .Or. T98->T98_CODSUS = "92"
			xTafTagGroup("infoProcRetPr" ,{ { "tpProcRetPrinc" ,T98->T98_TPPROC				 							   ,,.F. }; 
										 ,  { "nrProcRetPrinc" ,T98->T98_NUMPRO			                                   ,,.F. };
										 ,  { "codSuspPrinc"   ,T98->T98_CODSUS                                 		   ,,.T. };
										 ,  { "valorPrinc"     , StrTran(Alltrim((TRANSFORM(T98->T98_VLRPRI, "@E 9,999,999,999,999.99"))),"." ,"")			   ,,.F. }};
										 ,  @cXml)
	//	EndIf

		T98->( DbSkip() )								
	EndDo
EndIf	

If T99->( MsSeek( xFilial( "T99" ) + T95->( T95_ID + T95_VERSAO) ) )	
	While T99->(!Eof()) .And. T99->( T99_FILIAL + T99_ID + T99_VERSAO) == T95->( T95_FILIAL + T95_ID + T95_VERSAO)
		//If T95->T95_VLRNPR > 0 .Or. T99->T99_CODSUS $ "92"
			xTafTagGroup("infoProcRetAd" ,{ { "tpProcRetAdic"  ,T99->T99_TPPROC				 							   ,,.F. }; 
										 ,  { "nrProcRetAdic"  ,T99->T99_NUMPRO			                                   ,,.F. };
										 ,  { "codSuspAdic"    ,T99->T99_CODSUS                                 		   ,,.T. };
										 ,  { "valorAdic"      , StrTran(Alltrim((TRANSFORM(T99->T99_VLRADI, "@E 9,999,999,999,999.99"))),"." ,"")			   ,,.F. }};
										 ,  @cXml)
		//EndIf

		T99->( DbSkip() )								
	EndDo
EndIf	
	
cXml += 			"</idePrestServ>"
cXml +=			"</ideEstabObra>"	
cXml +=		"</infoServTom>"

/*����������������������Ŀ
  �Estrutura do cabecalho�
  ������������������������*/
cXml := TAFXmlReinf( cXml, "T95", cLayout, cReg, cPeriodo,, cNameXSD)


/*����������������������������Ŀ
  �Executa gravacao do registro�
  ������������������������������*/
If !lJob
	xTafGerXml(cXml,cLayout,,,,,,"R-" )
EndIf

	
Return(cXml)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} TAF486Vld

@author Vitor Siqueira			
@since 15/01/2018
@version 1.0
/*/                                                                                                                                          
//------------------------------------------------------------------------------------
Function TAF486Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro   as array
Local aDadosUtil as array
Local lValida    as logical   

Default lJob := .F.

aLogErro   := {}
aDadosUtil := {}
lValida    := T95->T95_STATUS $ ( " |1" )

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := T95->( Recno() )

If !lValida
	aAdd( aLogErro, { "T95_ID", "000305", "T95", nRecno } ) //Registros que j� foram transmitidos ao Fisco, n�o podem ser validados
Else
	
	
	//�������������������������������
	//�ATUALIZO O STATUS DO REGISTRO�
	//�1 = Registro Invalido        �
	//�0 = Registro Valido          �
	//�������������������������������
	cStatus := Iif( Len( aLogErro ) > 0, "1", "0" )
	Begin Transaction 
		If RecLock( "T95", .F. )
			T95->T95_STATUS := cStatus
			T95->( MsUnlock() )
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

Local oModelT95		as object
Local oModelT96		as object
Local oModelT97		as object
Local oModelT98		as object
Local oModelT99		as object
Local cVerAnt		as char
Local cRecibo		as char
Local cVersao		as char
Local nI			as numeric
Local nT96			as numeric
Local nT97			as numeric
Local nT97Add		as numeric
Local nT98			as numeric
Local nT99			as numeric
Local aGravaT95		as array
Local aGravaT96		as array
Local aGravaT97		as array
Local aGravaT98		as array
Local aGravaT99		as array

oModelT95	:=	Nil
oModelT96	:=	Nil
oModelT97	:=	Nil
oModelT98	:=	Nil
oModelT99	:=	Nil
cVerAnt		:=	""
cRecibo		:=	""
cVersao		:=	""
nI			:=	0
nT96		:=	0
nT97		:=	0
nT97Add		:=	0
nT98		:=	0
nT99		:=	0
aGravaT95	:=	{}
aGravaT96	:=	{}
aGravaT97	:=	{}
aGravaT98	:=	{}
aGravaT99	:=	{}

Begin Transaction

	DBSelectArea( "T95" )
	T95->( DBGoTo( nRecno ) )

	oModelT95 := oModel:GetModel( "MODEL_T95" )
	oModelT96 := oModel:GetModel( "MODEL_T96" )
	oModelT97 := oModel:GetModel( "MODEL_T97" )
	oModelT98 := oModel:GetModel( "MODEL_T98" )
	oModelT99 := oModel:GetModel( "MODEL_T99" )

	//************************************
	//Informa��es para grava��o do rastro
	//************************************
	cVerAnt := oModelT95:GetValue( "T95_VERSAO" )
	cRecibo := oModelT95:GetValue( "T95_PROTUL" )

	//****************************************************************************************************************
	//Armazeno as informa��es que foram modificadas na tela, para utiliza��o em opera��o de inclus�o de novo registro
	//****************************************************************************************************************
	For nI := 1 to Len( oModelT95:aDataModel[1] )
		aAdd( aGravaT95, { oModelT95:aDataModel[1,nI,1], oModelT95:aDataModel[1,nI,2] } )
	Next nI

	//T96
	If T96->( MsSeek( xFilial( "T96" ) + T95->( T95_ID + T95_VERSAO ) ) )

		For nT96 := 1 to oModel:GetModel( "MODEL_T96" ):Length()
			oModel:GetModel( "MODEL_T96" ):GoLine( nT96 )

			If !oModel:GetModel( "MODEL_T96" ):IsEmpty() .and. !oModel:GetModel( "MODEL_T96" ):IsDeleted()
				aAdd( aGravaT96, {	oModelT96:GetValue( "T96_CHVNF"  ),;
									oModelT96:GetValue( "T96_NUMFAT" ),;
									oModelT96:GetValue( "T96_IDFAT"  ),;
									oModelT96:GetValue( "T96_SERIE"  ),;
									oModelT96:GetValue( "T96_NUMDOC" ),;
									oModelT96:GetValue( "T96_DTEMIS" ),;
									oModelT96:GetValue( "T96_VLBRUT" ),;
									oModelT96:GetValue( "T96_OBSERV" ) } )

				//T97
				For nT97 := 1 to oModel:GetModel( "MODEL_T97" ):Length()
					oModel:GetModel( "MODEL_T97" ):GoLine( nT97 )
					If !oModel:GetModel( "MODEL_T97" ):IsEmpty() .and. !oModel:GetModel( "MODEL_T97" ):IsDeleted()
						aAdd( aGravaT97, {	oModelT96:GetValue( "T96_SERIE" ),; 
											oModelT96:GetValue( "T96_NUMDOC" ),;
											oModelT96:GetValue( "T96_NUMFAT" ),; 
											oModelT97:GetValue( "T97_TPSERV" ),;
											oModelT97:GetValue( "T97_CODSER" ),;
											oModelT97:GetValue( "T97_DTPSER" ),;
											oModelT97:GetValue( "T97_VLRBAS" ),;
											oModelT97:GetValue( "T97_VLRRET" ),;
											oModelT97:GetValue( "T97_VLRRSU" ),;
											oModelT97:GetValue( "T97_VLRNPR" ),;
											oModelT97:GetValue( "T97_VLRS15" ),;
											oModelT97:GetValue( "T97_VLRS20" ),;
											oModelT97:GetValue( "T97_VLRS25" ),;
											oModelT97:GetValue( "T97_VLRADI" ),;
											oModelT97:GetValue( "T97_VLRNRE" ) } )
					EndIf
				Next nT97
			EndIf
		Next nT96
	EndIf

	//T98
	If T98->( MsSeek( xFilial( "T98" ) + T95->( T95_ID + T95_VERSAO ) ) )

		For nT98 := 1 to oModel:GetModel( "MODEL_T98" ):Length()
			oModel:GetModel( "MODEL_T98" ):GoLine( nT98 )

			If !oModel:GetModel( "MODEL_T98" ):IsEmpty() .and. !oModel:GetModel( "MODEL_T98" ):IsDeleted()
				aAdd( aGravaT98, {	oModelT98:GetValue( "T98_IDPROC" ),;
									oModelT98:GetValue( "T98_TPPROC" ),;
									oModelT98:GetValue( "T98_NUMPRO" ),;
									oModelT98:GetValue( "T98_CODSUS" ),;
									oModelT98:GetValue( "T98_IDSUSP" ),;
									oModelT98:GetValue( "T98_VLRPRI" ) } )
			EndIf
		Next nT98
	EndIf
	
	//T99
	If T99->( MsSeek( xFilial( "T99" ) + T95->( T95_ID + T95_VERSAO ) ) )

		For nT99 := 1 to oModel:GetModel( "MODEL_T99" ):Length()
			oModel:GetModel( "MODEL_T99" ):GoLine( nT99 )
	
			If !oModel:GetModel( "MODEL_T99" ):IsEmpty() .and. !oModel:GetModel( "MODEL_T99" ):IsDeleted()
				aAdd( aGravaT99, {	oModelT99:GetValue( "T99_IDPROC" ),;
									oModelT99:GetValue( "T99_TPPROC" ),;
									oModelT99:GetValue( "T99_NUMPRO" ),;
									oModelT99:GetValue( "T99_CODSUS" ),;
									oModelT99:GetValue( "T99_IDSUSP" ),;
									oModelT99:GetValue( "T99_VLRADI" ) } )
			EndIf
		Next nT99
	EndIf
	
	//*****************************
	//Seto o registro como Inativo
	//*****************************
	FAltRegAnt( "T95", "2" )

	//**************************************
	//Opera��o de Inclus�o de novo registro
	//**************************************
	oModel:DeActivate()
	oModel:SetOperation( 3 )
	oModel:Activate()

	//********************************************************************************
	//Inclus�o do novo registro j� considerando as informa��es alteradas pelo usu�rio
	//********************************************************************************
	For nI := 1 to Len( aGravaT95 )
		oModel:LoadValue( "MODEL_T95", aGravaT95[nI,1], aGravaT95[nI,2] )
	Next nI

	//T96
	For nT96 := 1 to Len( aGravaT96 )

		oModel:GetModel( "MODEL_T96" ):LVALID := .T.

		If nT96 > 1
			oModel:GetModel( "MODEL_T96" ):AddLine()
		EndIf

		oModel:LoadValue( "MODEL_T96", "T96_CHVNF" , aGravaT96[nT96][1] )
		oModel:LoadValue( "MODEL_T96", "T96_NUMFAT", aGravaT96[nT96][2] )
		oModel:LoadValue( "MODEL_T96", "T96_IDFAT" , aGravaT96[nT96][3] )
		oModel:LoadValue( "MODEL_T96", "T96_SERIE" , aGravaT96[nT96][4] )
		oModel:LoadValue( "MODEL_T96", "T96_NUMDOC", aGravaT96[nT96][5] )
		oModel:LoadValue( "MODEL_T96", "T96_DTEMIS", aGravaT96[nT96][6] )
		oModel:LoadValue( "MODEL_T96", "T96_VLBRUT", aGravaT96[nT96][7] )
		oModel:LoadValue( "MODEL_T96", "T96_OBSERV", aGravaT96[nT96][8] )

		//T97
		nT97Add := 1
		For nT97 := 1 to Len( aGravaT97 )
			If aGravaT96[nT96][4] == aGravaT97[nT97][1]  .And. aGravaT96[nT96][5] == aGravaT97[nT97][2] .And. aGravaT96[nT96][2] == aGravaT97[nT97][3]

				oModel:GetModel( "MODEL_T97" ):LVALID := .T.

				If nT97Add > 1
					oModel:GetModel( "MODEL_T97" ):AddLine()
				EndIf
				

				oModel:LoadValue( "MODEL_T97", "T97_TPSERV", aGravaT97[nT97][4] )
				oModel:LoadValue( "MODEL_T97", "T97_CODSER", aGravaT97[nT97][5] )
				oModel:LoadValue( "MODEL_T97", "T97_DTPSER", aGravaT97[nT97][6] )
				oModel:LoadValue( "MODEL_T97", "T97_VLRBAS", aGravaT97[nT97][7] )
				oModel:LoadValue( "MODEL_T97", "T97_VLRRET", aGravaT97[nT97][8] )
				oModel:LoadValue( "MODEL_T97", "T97_VLRRSU", aGravaT97[nT97][9] )
				oModel:LoadValue( "MODEL_T97", "T97_VLRNPR", aGravaT97[nT97][10] )
				oModel:LoadValue( "MODEL_T97", "T97_VLRS15", aGravaT97[nT97][11] )
				oModel:LoadValue( "MODEL_T97", "T97_VLRS20", aGravaT97[nT97][12] )
				oModel:LoadValue( "MODEL_T97", "T97_VLRS25", aGravaT97[nT97][13] )
				oModel:LoadValue( "MODEL_T97", "T97_VLRADI", aGravaT97[nT97][14] )
				oModel:LoadValue( "MODEL_T97", "T97_VLRNRE", aGravaT97[nT97][15] )

				nT97Add ++
			EndIf
		Next nT97
	Next nT96
		
	For nT98 := 1 to Len( aGravaT98 )

		oModel:GetModel( "MODEL_T98" ):LVALID := .T.

		If nT96 > 1
			oModel:GetModel( "MODEL_T98" ):AddLine()
		EndIf

		oModel:LoadValue( "MODEL_T98", "T98_IDPROC", aGravaT98[nT98][1] )
		oModel:LoadValue( "MODEL_T98", "T98_TPPROC", aGravaT98[nT98][2] )
		oModel:LoadValue( "MODEL_T98", "T98_NUMPRO", aGravaT98[nT98][3] )
		oModel:LoadValue( "MODEL_T98", "T98_CODSUS", aGravaT98[nT98][4] )
		oModel:LoadValue( "MODEL_T98", "T98_IDSUSP", aGravaT98[nT98][5] )
		oModel:LoadValue( "MODEL_T98", "T98_VLRPRI", aGravaT98[nT98][6] )

	Next nT98
	
	For nT99 := 1 to Len( aGravaT99 )

		oModel:GetModel( "MODEL_T99" ):LVALID := .T.

		If nT96 > 1
			oModel:GetModel( "MODEL_T99" ):AddLine()
		EndIf

		oModel:LoadValue( "MODEL_T99", "T99_IDPROC", aGravaT99[nT99][1] )
		oModel:LoadValue( "MODEL_T99", "T99_TPPROC", aGravaT99[nT99][2] )
		oModel:LoadValue( "MODEL_T99", "T99_NUMPRO", aGravaT99[nT99][3] )
		oModel:LoadValue( "MODEL_T99", "T99_CODSUS", aGravaT99[nT99][4] )
		oModel:LoadValue( "MODEL_T99", "T99_IDSUSP", aGravaT99[nT99][5] )
		oModel:LoadValue( "MODEL_T99", "T99_VLRADI", aGravaT99[nT99][6] )

	Next nT99

	//*****************************************
	//Vers�o que ser� gravada no novo registro
	//*****************************************
	cVersao := xFunGetVer()

	//********************************************************************
	//ATEN��O
	//A altera��o destes campos devem sempre estar abaixo do loop do For,
	//pois devem substituir as informa��es que foram armazenadas acima
	//********************************************************************
	oModel:LoadValue( "MODEL_T95", "T95_VERSAO", cVersao )
	oModel:LoadValue( "MODEL_T95", "T95_VERANT", cVerAnt )
	oModel:LoadValue( "MODEL_T95", "T95_PROTPN", cRecibo )
	oModel:LoadValue( "MODEL_T95", "T95_PROTUL", "" )

	oModel:LoadValue( "MODEL_T95", "T95_EVENTO", "E" )
	oModel:LoadValue( "MODEL_T95", "T95_ATIVO", "1" )

	FWFormCommit( oModel )
	TAFAltStat( "T95", "6" ) 
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
	oBrw:SetDescription( "R-2010 - "+STR0001 )	//"Reten��o Contribui��o Previdenci�ria - Servi�os Tomados"
	oBrw:SetAlias( 'T95')
	oBrw:SetMenuDef( 'TAFA486' )	
	oBrw:SetFilterDefault( "T95_ATIVO == '1'" )

	//DbSelectArea("T95")
	//Set Filter TO &("T95_ATIVO == '1'")
	
	If FindFunction("TAFLegReinf")
		TAFLegReinf( "T95", oBrw)
	Else
		TafLegend(2,"T95",@oBrw)
	EndIf
	
    oBrw:Activate()

Return( oBrw )
