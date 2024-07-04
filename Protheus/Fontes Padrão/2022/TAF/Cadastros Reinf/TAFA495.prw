#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA495.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA495
Cadastro MVC - T001AB, Processos Referenciados

@author Roberto Souza
@since 30/01/2018

@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA495()

If TAFAlsInDic( "T9V" )
	BrowseDef()
Else
	Aviso( "TAF", STR0021, { "OK" }, 2 )
EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Roberto Souza
@since 30/01/2018

@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao	as array
Local aRotina	as array

aFuncao	:=	{}
aRotina	:=	{}

aAdd( aFuncao, { "", "TAF495Xml", "1" } )
aAdd( aFuncao, { "", "xFunNewHis( 'T9V', 'TAFA495' )", "3" } )
aAdd( aFuncao, { "", "TAFXmlLote( 'T9V', 'R-1070', 'TabProcesso', 'TAF495Xml', 5, oBrowse)", "5" } )
aAdd( aFuncao, { "", "TAF495Exc()", "6" } )
aAdd( aFuncao, { "", "TAF495Exc(.t.)", "9" } )

lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If lMenuDif
	ADD OPTION aRotina TITLE STR0009 ACTION "VIEWDEF.TAFA495" OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0032 ACTION "TAF495Xml()" OPERATION 2 ACCESS 0 //"Exportar Xml Reinf"
	ADD OPTION aRotina TITLE STR0033 ACTION "TAFXmlLote( 'T9V', 'R-1070', 'TabProcesso', 'TAF495Xml', 5, oBrowse)" OPERATION 2 ACCESS 0 //"Exportar Xml em Lote"	
Else
	aRotina := TAFMenuReinf( "TAFA495", aFuncao )
EndIf

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Roberto Souza
@since 30/01/2018

@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
    Local oStruT9V 	  as object
    Local oStruT9X    as object
    Local oModel 	  as object


    oStruT9V 	:= FWFormStruct( 1, 'T9V' )
    oStruT9X    := FWFormStruct( 1, 'T9X' )
	oModel		:= MPFormModel():New( 'TAFA495' , , , {|oModel| SaveModel( oModel ) })


	oModel:AddFields('MODEL_T9V', /*cOwner*/, oStruT9V)
	oModel:AddGrid("MODEL_T9X","MODEL_T9V",oStruT9X)
	oModel:GetModel("MODEL_T9X"):SetOptional(.T.)
	oModel:GetModel("MODEL_T9X"):SetUniqueLine({"T9X_CODSUS"})	
	
	oModel:SetRelation("MODEL_T9X",{ {"T9X_FILIAL","xFilial('T9X')"}, {"T9X_ID","T9V_ID"}, {"T9X_VERSAO","T9V_VERSAO"} },T9X->(IndexKey(1)) )
	
	oModel:GetModel('MODEL_T9V'):SetPrimaryKey({'T9V_FILIAL', 'T9V_ID', 'T9V_VERSAO'})	

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Roberto Souza
@since 30/01/2018

@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
    Local 	oModel 		:= 	FWLoadModel( 'TAFA495' )
    Local 	oStruT9V 	:= 	Nil
    Local 	oStruT9Vb	:=	Nil
    Local 	oStruT9X  	:=	Nil 
    Local 	oView 		:=	FWFormView():New()
    Local   nTam		:= 100

    oView:SetModel( oModel )

    // Campos do folder
    cCmpFil   := "T9X_CODSUS|T9X_IDSUSP|T9X_CIDSUS|T9X_DIDSUS|T9X_DTDECI|T9X_INDDEP|"
    oStruT9X  := FWFormStruct( 2, "T9X",{|x| AllTrim(x) + "|" $ cCmpFil } )

    cCmpFil	  := "T9V_TPPROC|T9V_NUMPRO|T9V_DTINI|T9V_DTFIN|T9V_INDAUD|T9V_IDUFVA|T9V_CDUFVA|"
    cCmpFil	  += "T9V_DSUFVA|T9V_IDMUNI|T9V_CDMUNI|T9V_DSMUNI|T9V_IDVARA|"
    oStruT9V  := FwFormStruct( 2, "T9V",{|x| AllTrim(x) + "|" $ cCmpFil } ) //Campos do folder Informacoes 

    // Campos do folder do número do ultimo protocolo
    cCmpFil   := 'T9V_PROTUL|'
    oStruT9Vb := FwFormStruct( 2, "T9V", {|x| AllTrim( x ) + "|" $ cCmpFil } )

    nTam := 60
    nPosV := 0

    oStruT9V:SetProperty("T9V_TPPROC" 	,MVC_VIEW_ORDEM ,StrZero(nPosV++,2))
    oStruT9V:SetProperty("T9V_NUMPRO" 	,MVC_VIEW_ORDEM ,StrZero(nPosV++,2))
    oStruT9V:SetProperty("T9V_DTINI" 	,MVC_VIEW_ORDEM ,StrZero(nPosV++,2))
    oStruT9V:SetProperty("T9V_DTFIN" 	,MVC_VIEW_ORDEM ,StrZero(nPosV++,2))
    oStruT9V:SetProperty("T9V_INDAUD" 	,MVC_VIEW_ORDEM ,StrZero(nPosV++,2))
    oStruT9V:SetProperty("T9V_IDUFVA" 	,MVC_VIEW_ORDEM ,StrZero(nPosV++,2))
    oStruT9V:SetProperty("T9V_CDUFVA" 	,MVC_VIEW_ORDEM ,StrZero(nPosV++,2))
    oStruT9V:SetProperty("T9V_DSUFVA" 	,MVC_VIEW_ORDEM ,StrZero(nPosV++,2))
    oStruT9V:SetProperty("T9V_IDMUNI" 	,MVC_VIEW_ORDEM ,StrZero(nPosV++,2))
    oStruT9V:SetProperty("T9V_CDMUNI" 	,MVC_VIEW_ORDEM ,StrZero(nPosV++,2))
    oStruT9V:SetProperty("T9V_DSMUNI" 	,MVC_VIEW_ORDEM ,StrZero(nPosV++,2))
    oStruT9V:SetProperty("T9V_IDVARA" 	,MVC_VIEW_ORDEM ,StrZero(nPosV++,2))

    oView:AddField( 'VIEW_T9V'  , oStruT9V,  'MODEL_T9V' )
    oView:AddField( "VIEW_T9Vb" , oStruT9Vb, "MODEL_T9V" )

    oView:CreateHorizontalBox( 'PAINEL', nTam ) 

    oView:CreateFolder( 'FOLDER_SUPERIOR', 'PAINEL' )
    oView:AddSheet( "FOLDER_SUPERIOR", "ABA01", STR0001 )
    oView:CreateHorizontalBox( 'PAINEL_01', 100,,, 'FOLDER_SUPERIOR', 'ABA01' )

    oView:AddGrid("VIEW_T9X",oStruT9X,"MODEL_T9X")
    oView:EnableTitleView("VIEW_T9X",STR0014)
    oView:CreateHorizontalBox("T9X",40)

    oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA02', STR0012 )
    oView:CreateHorizontalBox( 'PAINEL_02', 100,,, 'FOLDER_SUPERIOR', 'ABA02' )

    oView:SetOwnerView( 'VIEW_T9Vb' , 'PAINEL_02')	
    oView:SetOwnerView( 'VIEW_T9V'  , 'PAINEL_01')
    oView:SetOwnerView( 'VIEW_T9X'  , 'T9X')

    lMenuDIf := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDIf )

    If !lMenuDif
        xFunRmFStr(@oStruT9V, 'T9V')
        xFunRmFStr(@oStruT9X, 'T9X')
    EndIf

Return oView 

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
/*/{Protheus.doc} TAF495Xml
Funcao de geracao do XML para atender o registro S-1070
Quando a rotina for chamada o registro deve estar posicionado

@Param:

@Return:
cXml - Estrutura do Xml do Layout R-1070

@author Roberto Souza
@since 30/01/2018

@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF495Xml(cAlias,nRecno,nOpc,lJob)

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
	Local cIdVara       := ""
	Local cVsReinf      := SuperGetMv( "MV_TAFVLRE", .F., "1_03_02" )
	Local lVSup13       := IIf( "1_03" $ AllTrim( cVsReinf ), .F., .T. )
	Local cNameXSD		:= "TabProcesso"

    cDtIniAtu	:= Iif(!Empty(T9V->T9V_DTINI),Substr(T9V->T9V_DTINI,3,4) + "-" + Substr(T9V->T9V_DTINI,1,2),"") //Faço o IIf pois se a data estiver vazia a string recebia '  -  -   '
    cDtFinAtu	:= Iif(!Empty(T9V->T9V_DTFIN),Substr(T9V->T9V_DTFIN,3,4) + "-" + Substr(T9V->T9V_DTFIN,1,2),"")

    If T9V->T9V_EVENTO $ "I|A"

         If T9V->T9V_EVENTO == "A"
            cEvento := "alteracao"

            cId := T9V->T9V_ID 
            cVerAnt := T9V->T9V_VERANT
            
            BeginSql alias 'T9VTEMP'
                SELECT T9V.T9V_DTINI,T9V.T9V_DTFIN
                FROM %table:T9V% T9V
                WHERE T9V.T9V_FILIAL= %xfilial:T9V% AND
                T9V.T9V_ID = %exp:cId% AND T9V.T9V_VERSAO = %exp:cVerAnt% AND 
                T9V.%notDel%
            EndSql  
            cDtIni := Iif(!Empty(('T9VTEMP')->T9V_DTINI),Substr(('T9VTEMP')->T9V_DTINI,3,4) + "-" + Substr(('T9VTEMP')->T9V_DTINI,1,2),"")
            cDtFin := Iif(!Empty(('T9VTEMP')->T9V_DTFIN),Substr(('T9VTEMP')->T9V_DTFIN,3,4) + "-" + Substr(('T9VTEMP')->T9V_DTFIN,1,2),"")

            ('T9VTEMP')->( DbCloseArea() )
        Else
            cEvento := "inclusao"
            cDtIni  := Iif(!Empty(T9V->T9V_DTINI),Substr(T9V->T9V_DTINI,3,4) + "-" + Substr(T9V->T9V_DTINI,1,2),"") //Faço o IIf pois se a data estiver vazia a string recebia '  -  -   '
            cDtFin  := Iif(!Empty(T9V->T9V_DTFIN),Substr(T9V->T9V_DTFIN,3,4) + "-" + Substr(T9V->T9V_DTFIN,1,2),"")
        EndIf
        
        cXml +=			"<infoProcesso>"
        cXml +=				"<" + cEvento + ">"
        cXml +=					"<ideProcesso>"
        cXml += 					xTafTag("tpProc"	,T9V->T9V_TPPROC)
        cXml += 					xTafTag("nrProc"	,T9V->T9V_NUMPRO)
        cXml +=						xTafTag("iniValid"	,cDtIni)
        cXml +=						xTafTag("fimValid"	,cDtFin,,.T.)	
        cXml +=						xTafTag("indAutoria",T9V->T9V_INDAUD,,.F.)

        ("T9X")->( DbSetOrder( 1 ) )
        ("T9X")->( DbSeek ( T9V->T9V_FILIAL+T9V->T9V_ID+T9V->T9V_VERSAO) )

        While T9X->( !Eof()) .And. (T9V->T9V_FILIAL+T9V->T9V_ID+T9V->T9V_VERSAO == T9X->T9X_FILIAL+T9X->T9X_ID+T9X->T9X_VERSAO)
            cXml +=					"<infoSusp>"
            cXml +=						xTafTag("codSusp"		,T9X->T9X_CODSUS,,.F.)	
            cXml +=						xTafTag("indSusp"		,T9X->T9X_CIDSUS,,.F.)
            cXml +=						xTafTag("dtDecisao"	    ,T9X->T9X_DTDECI,,.F.)
            cXml +=						xTafTag("indDeposito",xFunTrcSN(T9X->T9X_INDDEP,1),,.F.)
            cXml +=					"</infoSusp>"	
            T9X->( dbSkip() )
        EndDo
        cUfVara := Posicione("C09",3,xFilial("C09")+T9V->T9V_IDUFVA,"C09_CODIGO")
	
        If T9V->T9V_TPPROC == "2"
            If lVSup13
            	cIdVara := Padl( AllTrim( T9V->T9V_IDVARA ), TamSx3("T9V_IDVARA")[1], "0" )
            Else
				cIdVara := Substr(AllTrim(T9V->T9V_IDVARA),1,2)
            EndIf
                    
            xTafTagGroup("dadosProcJud"	,{	{"ufVara"	,T9V->T9V_CDUFVA					,,.F.},;
                                            	{"codMunic"	,cUfVara+T9V->T9V_CDMUNI		,,.F.},;
                                            	{"idVara"	,cIdVara 							,,.F.}},;
                                            @cXml)	
        EndIf

        cXml +=					"</ideProcesso>"
        
        If T9V->T9V_EVENTO == "A"
        	If TAFAtDtVld( "T9V", T9V->T9V_ID, T9V->T9V_DTINI, T9V->T9V_DTFIN, T9V->T9V_VERANT, .T. )
        		cXml += 		"<novaValidade>"
        		cXml += 			TAFGetDtTab( T9V->T9V_DTINI, T9V->T9V_DTFIN )
        		cXml += 		"</novaValidade>"
        	EndIf
        EndIf

        cXml +=				"</" + cEvento + ">"
        cXml +=			"</infoProcesso>"

    ElseIf T9V->T9V_EVENTO == "E"
        cXml +=		"<infoProcesso>"
        cXml +=			"<exclusao>"
        cXml +=				"<ideProcesso>"
        cXml += 				xTafTag("tpProc",T9V->T9V_TPPROC)
        cXml += 				xTafTag("nrProc",T9V->T9V_NUMPRO)
        cXml +=					TAFGetDtTab( T9V->T9V_DTINI, T9V->T9V_DTFIN )
        cXml +=				"</ideProcesso>
        cXml +=			"</exclusao>"
        cXml +=		"</infoProcesso>"

    EndIf

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³Estrutura do cabecalho³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    cXml := TAFXmlReinf( cXml, "T9V", cLayout, cReg, ,, cNameXSD)

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³Executa gravacao do registro³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If !lJob
        xTafGerXml( cXml, cLayout,,,,,,"R-" )        
    EndIf

Return(cXml)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Taf495Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacões caso seja necessario gerar um XML

lJob - Informa se foi chamado por Job

@return .T.

@author Roberto Souza
@since 30/01/2018

@version 1.0
/*/                                                                                                                                          
//------------------------------------------------------------------------------------
Function TAF495Vld(cAlias,nRecno,nOpc,lJob)
    Local aLogErro	:= {} 

    Default lJob 		:= .F.

    //Garanto que o Recno seja da tabela referente ao cadastro principal
    nRecno := T9V->( Recno() )

    If T9V->T9V_STATUS $ ( " |1" )

    Else	
        AADD(aLogErro,{"T9V_ID","000305", "T9V", nRecno })//Registros que já foram transmitidos ao Fisco, não podem ser validados
    EndIf

    //Não apresento o alert quando utilizo o JOB para validar
    If !lJob
        xValLogEr(aLogErro)
    EndIf

Return(aLogErro)

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF495Valid
@type			function
@description	Função com validação das regras de inclusão e alteração
@description	de eventos de tabelas daReinf ( VldEvTab ), para o cadastro
@description	de Tabela de Processos Administrativos/Judiciais.
@author			Felipe C. Seolin
@since			07/03/2018
@version		1.0
@return			lRet	-	Indica se a operação é válida
/*/
//---------------------------------------------------------------------
Function TAF495Valid()

Local cCampo	as char
Local lRet		as logical 

cCampo	:=	SubStr( ReadVar(), At( ">", ReadVar() ) + 1 )
lRet	:=	.T.

If cCampo == "T9V_TPPROC"
	lRet := VldEvTab( "T9V", 2, M->T9V_TPPROC + FWFldGet( "T9V_NUMPRO" ), FWFldGet( "T9V_DTINI" ), FWFldGet( "T9V_DTFIN" ), 1,,,, 5 )
ElseIf cCampo == "T9V_NUMPRO"
	lRet := VldEvTab( "T9V", 2, FWFldGet( "T9V_TPPROC" ) + M->T9V_NUMPRO, FWFldGet( "T9V_DTINI" ), FWFldGet( "T9V_DTFIN" ), 1,,,, 5 )
ElseIf cCampo == "T9V_DTINI"
	lRet := VldEvTab( "T9V", 2, FWFldGet( "T9V_TPPROC" ) + FWFldGet( "T9V_NUMPRO" ), M->T9V_DTINI, FWFldGet( "T9V_DTFIN" ), 1,,,, 5 )
ElseIf cCampo == "T9V_DTFIN"
	lRet := VldEvTab( "T9V", 2, FWFldGet( "T9V_TPPROC" ) + FWFldGet( "T9V_NUMPRO" ), FWFldGet( "T9V_DTINI" ), M->T9V_DTFIN, 1,,,, 5 )
EndIf

Return( lRet )

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

	oBrowse:SetDescription( STR0001 )
	oBrowse:SetAlias( "T9V" )
	oBrowse:SetMenuDef( "TAFA495" )
	oBrowse:SetFilterDefault( "T9V_ATIVO == '1'" )

	//DbSelectArea("T9V")
	//Set Filter TO &("T9V_ATIVO == '1'")
	
	oBrowse:SetOnlyFields( { "T9V_ID", "T9V_NUMPRO", "T9V_TPPROC", "T9V_DTINI", "T9V_DTFIN" } )

	If FindFunction("TAFLegReinf")
		TAFLegReinf( "T9V", oBrowse)
	Else
		oBrowse:AddLegend( "T9V_EVENTO == 'I' ", "GREEN"	, STR0006 ) //"Registro Incluído"
		oBrowse:AddLegend( "T9V_EVENTO == 'A' ", "YELLOW"	, STR0007 ) //"Registro Alterado"
		oBrowse:AddLegend( "T9V_EVENTO == 'E' ", "RED"		, STR0008 ) //"Registro Excluído"
	EndIf

    oBrowse:Activate()

Return( oBrowse )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF495Exc
Funcao que gera a exclusão do evento

@param lDesfaz - Se .t. desfaz exclusão, senão exclui o evento.

@Return .T.

@author Henrique Pereira	
@since 02/02/2018
@Version 1.0
/*/
//-------------------------------------------------------------------
Function TAF495Exc(lDesfaz)

Local cVerAnt    	as character
Local cProtocolo 	as character
Local cVersao    	as character
Local cChvRegAnt 	as character
Local cEvento	 	as character
Local cQryExc		as character
Local nlI			as numeric
Local nlY			as numeric
Local nRecno 		as numeric

Local aGrava     	as array
Local aIdDel		as array
Local oModelT9V  	as object
Local oModel		as object

Default lDesfaz := .f.

cVerAnt   	:= ""
cProtocolo	:= ""
cVersao   	:= ""
cChvRegAnt	:= ""
cEvento	:= ""
cAlias		:= alias()
cProcId	:= ( cAlias )->&( cAlias + "_PROCID" ) 
oModel		:= FWLoadModel( 'TAFA495' ) 

nlI			:= 0
nlY   		:= 0
nRecno 	:= recno()

aGrava    	:= {}
oModelT9V 	:= Nil
Begin Transaction
	if !lDesfaz
		if 	( cAlias )->&( cAlias + '_EVENTO' ) == 'E'
			MsGinfo(STR0034) //Para o evento selecionado use a opçao 'Desfazer Exclusão'.
		elseIf ( cAlias )->&( cAlias + "_STATUS" ) == "4" .And.  ( cAlias )->&( cAlias + "_EVENTO" ) <> "E"
			If ApMsgNoYes(STR0025) //O Evento a ser excluído está transmitido ao governo  e autorizado, o mesmo será desativado e será gerado um novo registro de Exclusão que deverá ser transmitido. Deseja prosseguir?
					
				oModel:SetOperation( 4 )
				oModel:Activate()
				//Posiciona o item
				("T9V")->( DBGoTo( nRecno ) )
			
				oModelT9V := oModel:GetModel( 'MODEL_T9V' )
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Busco a versao anterior do registro para gravacao do rastro³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cVerAnt    	:= oModelT9V:GetValue( "T9V_VERSAO" )
				cProtocolo 	:= oModelT9V:GetValue( "T9V_PROTUL" )
				cEvento		:= oModelT9V:GetValue( "T9V_EVENTO" )
				cIdT9CC1G		:= oModelT9V:GetValue( "T9V_ID" ) 
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Neste momento eu gravo as informacoes que foram carregadas       ³
				//³na tela, pois neste momento o usuario ja fez as modificacoes que ³
				//³precisava e as mesmas estao armazenadas em memoria, ou seja,     ³
				//³nao devem ser consideradas neste momento                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				
				For nlI := 1 To 1
					For nlY := 1 To Len( oModelT9V:aDataModel[ nlI ] )
						Aadd( aGrava, { oModelT9V:aDataModel[ nlI, nlY, 1 ], oModelT9V:aDataModel[ nlI, nlY, 2 ] } )
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
				FAltRegAnt( 'T9V', '2' )
				
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
					oModel:LoadValue( 'MODEL_T9V', aGrava[ nlI, 1 ], aGrava[ nlI, 2 ] )
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
				oModel:LoadValue( 'MODEL_T9V', 'T9V_VERSAO', cVersao )
				oModel:LoadValue( 'MODEL_T9V', 'T9V_VERANT', cVerAnt )
				oModel:LoadValue( 'MODEL_T9V', 'T9V_PROTPN', cProtocolo )
				oModel:LoadValue( 'MODEL_T9V', 'T9V_PROTUL', "" )
			
				/*---------------------------------------------------------
				Tratamento para que caso o Evento Anterior fosse de exclusão
				seta-se o novo evento como uma "nova inclusão", caso contrário o
				evento passar a ser uma alteração
				-----------------------------------------------------------*/
				oModel:LoadValue( "MODEL_T9V", "T9V_EVENTO", "E" )
				oModel:LoadValue( "MODEL_T9V", "T9V_ATIVO" , "1" )
				oModel:LoadValue( "MODEL_T9V", "T9V_STATUS", " " )
				oModel:LoadValue( "MODEL_T9V", "T9V_XMLID", " " )
							
				//Gravo
				FwFormCommit( oModel )
				
				//Gravo o mesmo _PROCID do registro inativado
				TafEndGRV( "T9V","T9V_PROCID", cProcId, T9V->(Recno())  )
				
			EndIf			
		ElseIf ( cAlias )->&( cAlias + "_EVENTO" ) == "I"
			If ( cAlias )->&( cAlias + "_STATUS" ) $ "2|6"
				Aviso( "Atenção", "Não é possivel realizar a exclusão de um evento que está aguardando o retorno do Governo.", { "Fechar" }, 2 ) //##"Não é possivel realizar a exclusão de um evento que está aguardando o retorno do RET." ##"Fechar"
			Else
				If ApMsgNoYes(STR0026)//O Evento a ser excluído ainda não foi transmitido ao governo, o mesmo será apagado permanentemente da base. Deseja prosseguir?
					cIdDel := T9V->T9V_PROCID
					oModel:SetOperation( MODEL_OPERATION_DELETE ) 
					oModel:Activate()
					 
					cQryExc := "SELECT R_E_C_N_O_, C1G_ID FROM "+RetSqlName("C1G")+ " WHERE D_E_L_E_T_ = ' ' AND C1G_PROCID ='"+cIdDel+"'"
					aIdDel := TafQryarr( cQryExc )
					
					For nlI := 1 To Len( aIdDel )
						TafEndGRV( "C1G","C1G_PROCID", "", aIdDel[nlI][01]  )
					Next

					FwFormCommit( oModel ) 
				EndIf
			EndIf	
		ElseIf ( cAlias )->&( cAlias + "_EVENTO" ) == "A"
			If ( cAlias )->&( cAlias + "_STATUS" ) $ "2|6"
				Aviso( "Atenção", "Não é possivel realizar a exclusão de um evento que está aguardando o retorno do Governo.", { "Fechar" }, 2 ) //##"Não é possivel realizar a exclusão de um evento que está aguardando o retorno do RET." ##"Fechar"
			Else
				If ApMsgNoYes(STR0031)	// O Evento a ser excluído é um evendo de alteração ainda não transmitido ao governo, o mesmo sera deletado e o registro anterios restaurado. Deseja prosseguir? 
					cIdDel := T9V->T9V_PROCID
					oModelT9V := oModel:GetModel( 'MODEL_T9V' )
					oModel:SetOperation( MODEL_OPERATION_DELETE )
					oModel:Activate()

					If T9V->(MsSeek(xFilial('T9V')+ oModelT9V:GetValue( "T9V_ID" ) + oModelT9V:GetValue( "T9V_VERANT" )))
						FAltRegAnt( 'T9V', '1' )
						MsGinfo(STR0030) //Registro restaurado!
					EndIf
					
					cQryExc := "SELECT R_E_C_N_O_, C1G_ID FROM "+RetSqlName("C1G")+ " WHERE D_E_L_E_T_ = ' ' AND C1G_PROCID ='"+cIdDel+"'"
					aIdDel := TafQryarr( cQryExc )
					
					For nlI := 1 To Len( aIdDel )
						TafEndGRV( "C1G","C1G_PROCID", "", aIdDel[nlI][01]  )
					Next

					FwFormCommit( oModel )
					
				EndIf	
			EndIf	
		EndIf
	else
		If ( cAlias )->&( cAlias + "_EVENTO" ) == "E" .And. ( cAlias )->&( cAlias + "_STATUS" ) $ ' |0|1|3'
			If ApMsgNoYes(STR0027) //O Evento a ser excluído é um evento de exclusão ainda não transmitido ao governo, o mesmo será apagado da base e o registro anterior restaurado. Deseja prosseguir?
				oModelT9V := oModel:GetModel( 'MODEL_T9V' )
				oModel:SetOperation( MODEL_OPERATION_DELETE )
				oModel:Activate()	
				FwFormCommit( oModel )
				
				If T9V->(MsSeek(xFilial('T9V')+ oModelT9V:GetValue( "T9V_ID" ) + oModelT9V:GetValue( "T9V_VERANT" )))
					FAltRegAnt( 'T9V', '1' )
					MsGinfo(STR0030) //Registro restaurado!
				EndIf
			EndIf
		ElseIf ( cAlias )->&( cAlias + "_EVENTO" ) == "E" .And. ( cAlias )->&( cAlias + "_STATUS" ) $ '6'
				MsGinfo(STR0028) //O Evento a ser excluído é um evento de exclusão já transmitido, porém ainda não autorizado, a operação desejada não poderá ser concluída até que o retorno do governo esteja OK.
		ElseIf ( cAlias )->&( cAlias + "_EVENTO" ) == "E" .And. ( cAlias )->&( cAlias + "_STATUS" ) $ '7|4'
				MsGinfo(STR0029) //"O Evento a ser excluído é um evento de exclusão transmitido e autorizado, a operação desejada não poderá ser concluída."
		else
			MsGinfo(STR0035) //Essa opcao deve ser usada somente para eventos de exclusao.
		endif	
	endif	

End Transaction
Return ( .T. )		
								
