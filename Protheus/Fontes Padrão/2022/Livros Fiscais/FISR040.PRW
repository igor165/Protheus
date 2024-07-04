#INCLUDE "PROTHEUS.CH"
#INCLUDE "FISR040.CH"
#INCLUDE "REPORT.CH" 

//-------------------------------------------------------------------
/*/{Protheus.doc} FISR040

Relatorio de conferencia - Desenvolve (incentivo fiscal)

@return	Nil

@author Luccas Curcio
@since 16/04/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function FISR040()
Local oReport
Private	cArqInd		:=	""
Private	cArqInd2	:=	""
Private	cArqInd3	:=	""
Private	cArqInd4	:=	""
Private	cArqTemp	:=	""
Private	cArqTemp2	:=	""
Private	cArqTemp3	:=	""
Private	aWizard		:=	{}
    
If TRepInUse() //verifica se relatorios personalizaveis esta disponivel	
   	
   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Interface de impressao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If R040IniRot()
		
		//Criacao da tabela temporaria utlizada no relatorio
		R040CriaTrb()

		oReport	:= ReportDef()
		oReport:PrintDialog()
		
		//Limpeza de arquivos temporarios
		If Select( 'REL040' ) > 0
			REL040->(DbCloseArea())
		Endif
		If Select( 'TOT040' ) > 0
			TOT040->(DbCloseArea())
		Endif
		If Select( 'OBS040' ) > 0
			OBS040->(DbCloseArea())
		Endif
		
		FErase(cArqTemp+GetDBExtension())
		FErase(cArqTemp+OrdBagExt())
		FErase(cArqInd+OrdBagExt())
		FErase(cArqInd2+OrdBagExt())    
		
	Endif
Else
	Alert( STR0001 )
Endif

Return    

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef

Impressao do relatorio

@return Nil

@author Luccas Curcio
@since 16/04/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ReportDef()
Local oReport
Local oRelat
Local oRepTot
Local oObserv

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³                                                                        ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport := TReport():New("FISR040","DESENVOLVE - BA","FISR040", {|oReport| ReportPrint(oReport)},"DESENVOLVE - "+GetNewPar("MV_ESTADO"))
oReport:SetTotalInLine(.F.)

Pergunte("FISR040",.F.) 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da secao utilizada pelo relatorio                               ³
//³                                                                        ³
//³TRSection():New                                                         ³
//³ExpO1 : Objeto TReport que a secao pertence                             ³
//³ExpC2 : Descricao da seçao                                              ³
//³ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   ³
//³        sera considerada como principal para a seção.                   ³
//³ExpA4 : Array com as Ordens do relatório                                ³
//³ExpL5 : Carrega campos do SX3 como celulas                              ³
//³        Default : False                                                 ³
//³ExpL6 : Carrega ordens do Sindex                                        ³
//³        Default : False                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da celulas da secao do relatorio                                ³
//³                                                                        ³
//³TRCell():New                                                            ³
//³ExpO1 : Objeto TSection que a secao pertence                            ³
//³ExpC2 : Nome da celula do relatório. O SX3 será consultado              ³
//³ExpC3 : Nome da tabela de referencia da celula                          ³
//³ExpC4 : Titulo da celula                                                ³
//³        Default : X3Titulo()                                            ³
//³ExpC5 : Picture                                                         ³
//³        Default : X3_PICTURE                                            ³
//³ExpC6 : Tamanho                                                         ³
//³        Default : X3_TAMANHO                                            ³
//³ExpL7 : Informe se o tamanho esta em pixel                              ³
//³        Default : False                                                 ³
//³ExpB8 : Bloco de código para impressao.                                 ³
//³        Default : ExpC2                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
   
//Secao Relatorio                 
oRelat:=TRSection():New(oReport,"DESENVOLVE",{ 'REL040' },/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)    //Método construtor da classe TRSection
oRelat:SetPageBreak(.T.)  //Define se salta a página na quebra de seção         

TRCell():New(oRelat,"TIPO"		, 'REL040' ,"Tipo"			,/*cPicture*/			,10,/*lPixel*/,/*{|| code-block de impressao }*/)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Apenas se Analitico	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Substr(aWizard[1][1] , 1 , 1 ) == "2"
	TRCell():New(oRelat,"DOC"		, 'REL040' ,"Documento"		,/*cPicture*/	,20	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oRelat,"SERIE"		, 'REL040' ,"Série"			,/*cPicture*/	,10	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oRelat,"CLIFOR"	, 'REL040' ,"Código Clie/For"	,/*cPicture*/	,20	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oRelat,"LOJA"		, 'REL040' ,"Loja"			,/*cPicture*/	,10	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oRelat,"PRODUTO"	, 'REL040' ,"Produto"			,/*cPicture*/	,40	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oRelat,"NCM"		, 'REL040' ,"NCM"				,/*cPicture*/	,15	,/*lPixel*/,/*{|| code-block de impressao }*/)
Endif
TRCell():New(oRelat,"CFOP"		, 'REL040' ,"CFOP"				,/*cPicture*/			,8	,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRelat,"CFDESC"	, 'REL040' ,"Descrição"			,/*cPicture*/			,52	,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRelat,"VALICM"	, 'REL040' ,"Valor do ICMS"		,"@E 999,999,999.99"	,20	,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRelat,"VALCOM"	, 'REL040' ,"ICMS Complementar"	,"@E 999,999,999.99"	,20	,/*lPixel*/,/*{|| code-block de impressao }*/)


oRepTot:=TRSection():New(oReport,"TOTAL",{ 'TOT040' },/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)    //Método construtor da classe TRSection
oRepTot:SetPageBreak(.T.)  //Define se salta a página na quebra de seção     

TRCell():New(oRepTot,"CNVP"		, 'TOT040' 	,"CNVP"		,"@E 999,999,999.99"	,20	,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRepTot,"DNVP"		, 'TOT040' 	,"DNVP"		,"@E 999,999,999.99"	,20	,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRepTot,"FATOR"	, 'TOT040' 	,"AMP"		,"@E 99.99"				,20	,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRepTot,"REFLEXO"	, 'TOT040' 	,"Reflexo"	,/*cPicture*/			,70	,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRepTot,"TOTAL"	, 'TOT040' 	,"Total"	,"@E 999,999,999.99"	,20	,/*lPixel*/,/*{|| code-block de impressao }*/)

oObserv:=TRSection():New(oReport,"OBS",{ 'OBS040' },/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)    //Método construtor da classe TRSection
oObserv:SetPageBreak(.T.)  //Define se salta a página na quebra de seção

TRCell():New(oObserv,"OBSERV"		, 'OBS040' 	,"Observação"		,"@!"		,200	,/*lPixel*/,/*{|| code-block de impressao }*/)

Return oReport

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint

Impressao do relatorio

@return Nil

@author Luccas Curcio
@since 16/04/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport)
Local oRelat	:= oReport:Section(1) 
Local oRepTot	:= oReport:Section(2)
Local oObserv	:= oReport:Section(3)

R040GetQry()                     
oReport:SkipLine(10) 

//Se analitico, faco quebras
//If Substr(aWizard[1][1] , 1 , 1 ) == "2"
oBreakFil := TRBreak():New(oRelat,oRelat:Cell("TIPO"),"Total do Incentivo",.F.) // "Total do Incentivo"
TRFunction():New(oRelat:Cell("VALICM"),Nil,"SUM",oBreakFil,"","@E 999,999,999.99",/*uFormula*/,.F.,.F.,.F.)       
TRFunction():New(oRelat:Cell("VALCOM"),Nil,"SUM",oBreakFil,"","@E 999,999,999.99",/*uFormula*/,.F.,.F.,.F.)
//Endif

oRelat:Print()
oRepTot:Print()
oObserv:Print()

Return         

//-------------------------------------------------------------------
/*/{Protheus.doc} R040GetQry

Cria arquivos da rotina (TRB, indices) e executa query

@return	Nil

@author Luccas Curcio
@since 16/04/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function R040GetQry()    
//Local	aTRB		:=	{}
Local	aCfop		:=	xApCfopDef("DES",.T.)                      
Local	cAliasQry	:=	GetNextAlias()
Local	cWhere		:=	""
Local	cGroup		:=	""
Local	cOrder		:=	""
Local	cFrom		:=	""
Local	dDtIni		:=	Ctod('01/'+StrZero(mv_par01,2)+'/'+Substr(StrZero(mv_par02,4),3,2))
Local	dDtFim		:=	UltimoDia(dDtIni)
//Local	aMvDes		:=	&( GetNewPar( 'MV_DESENV' , '{}' ) )
Local	cTipo		:=	""
Local	nTotCNVP	:=	0
Local	nTotDNVP	:=	0
Local	cReflexo	:=	""
Local	nTotal		:=	""
Local	aRetFator	:=	{}
Local	nX			:=	0
Local	nFator		:=	0
Local	cCfInd		:=	GetNewPar( "MV_DSVIND" , "" )

cArqInd  := CriaTrab(NIL,.F.)
IndRegua( 'REL040' ,cArqInd,"TIPO+CFOP")
cArqInd2  := CriaTrab(NIL,.F.)
IndRegua( 'REL040' ,cArqInd2,"TIPO+CFOP+DOC+SERIE+CLIFOR+LOJA+PRODUTO")
dbClearIndex()
dbSelectArea( 'REL040' )
dbSetIndex(cArqInd+OrdBagExt())
dbSetIndex(cArqInd2+OrdBagExt())
dbSetOrder(1)

if FindFunction('getFatorDesenvolveBA')
	aRetFator		:=	getFatorDesenvolveBA( mv_par01 , mv_par02 , .T. )
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Sintetico	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Substr(aWizard[1][1] , 1 , 1 ) == "1"

	cWhere	+=	"%SFT.FT_FILIAL = '" + xFilial( "SFT" ) + "' AND "
	cWhere	+=	"SFT.FT_ENTRADA >= '" + DToS( dDtIni ) + "' AND "
	cWhere	+=	"SFT.FT_ENTRADA <= '" + DToS( dDtFim ) + "' AND "
	cWhere	+=	"( SFT.FT_CFOP IN " + aCfop[1] + " OR  SFT.FT_CFOP IN " + aCfop[2] + " ) AND "
	cWhere	+=	"SFT.FT_DTCANC = '' AND "
	cWhere	+=	"SFT.FT_TIPO <> 'S' AND "
	cWhere	+=	"SFT.D_E_L_E_T_=' ' "
	
	cOrder	:=	"ORDER BY SFT.FT_CFOP%"
	
	cFrom	+=	"%" + RetSqlName( "SFT" ) + " SFT "
	cFrom	+=	"JOIN " + RetSqlName( "SX5" ) + " SX5 ON "
	cFrom	+=	"	SX5.X5_TABELA = '13' AND "
	cFrom	+=	"	SX5.X5_CHAVE = SFT.FT_CFOP "
	cFrom	+=	"LEFT JOIN " + RetSqlName( "SB5" ) + " SB5 ON "
	cFrom	+=	"	SB5.B5_FILIAL = '" + xFilial( "SB5" ) + "' AND "
	cFrom	+=	"	SB5.B5_COD = SFT.FT_PRODUTO AND "
	cFrom	+=	"	SB5.D_E_L_E_T_ = '' %"

	BeginSql Alias cAliasQry
	                
	    SELECT
			SFT.FT_VALICM VALICM , SFT.FT_ICMSCOM ICMSCOM , SFT.FT_CFOP CFOP , SX5.X5_DESCRI CFDESC , SB5.B5_PROJDES PROJDES
	    FROM 
	    	%Exp:cFrom%
		WHERE
			%Exp:cWhere+cGroup+cOrder%
	EndSql	 

	dbSelectArea( cAliasQry )
	( cAliasQry )->( dbGoTop() )
	
	dbSelectArea( 'REL040' )
	REL040->( dbSetOrder(1) )
	
	 	While ( cAliasQry )->( !eof() )
			
			If ( ( cAliasQry )->( PROJDES <> '1' .Or. ( PROJDES == "1" .And. CFOP $ "5910|5911|6910|6911|1910|1911|2910|2911" ) ) )
				
				cTipo	:=	Iif( AllTrim( ( cAliasQry )->CFOP ) $ aCfop[1] , 'CNVP' , 'DNVP' )
				
				If cTipo == 'CNVP'
					nTotCNVP	+=	( cAliasQry )->( VALICM )
					nTotDNVP	+=	( cAliasQry )->( ICMSCOM )
				Elseif cTipo == 'DNVP'
					nTotDNVP	+=	( cAliasQry )->( VALICM + ICMSCOM )
				Endif
				
				If REL040->(MsSeek( cTipo + ( cAliasQry )->CFOP ) )
					Reclock( 'REL040' , .F. )
					REL040->VALICM		+=	( cAliasQry )->VALICM
					REL040->VALCOM		+=	( cAliasQry )->ICMSCOM
					MsUnLock()
				Else
				   	Reclock( 'REL040' , .T. )                  
					REL040->TIPO		:=	cTipo
					REL040->CFOP		:=	( cAliasQry )->CFOP
					REL040->VALICM		:=	( cAliasQry )->VALICM
					REL040->VALCOM		:=	( cAliasQry )->ICMSCOM
					REL040->CFDESC		:=	( cAliasQry )->CFDESC
					MsUnLock()	
				EndIf
			Endif
				
			( cAliasQry )->(dbSkip())
	 	EndDo
	 	
	( cAliasQry )->(DbCloseArea())
	
	for nX := 1 To Len( aRetFator )
 	
 		Reclock( 'REL040' , .T. )                  
		REL040->TIPO		:=	'CNVP'
		REL040->CFOP		:=	aRetFator[ nX ][ 4 ]
		REL040->VALICM		:=	aRetFator[ nX ][ 2 ]
		REL040->VALCOM		:=	0
		REL040->CFDESC		:=	aRetFator[ nX ][ 5 ]
		MsUnLock()
		
		nTotCNVP	+=	aRetFator[ nX ][ 2 ]
		
		Reclock( 'REL040' , .T. )                  
		REL040->TIPO		:=	'DNVP'
		REL040->CFOP		:=	aRetFator[ nX ][ 4 ]
		REL040->VALICM		:=	aRetFator[ nX ][ 1 ]
		REL040->VALCOM		:=	0
		REL040->CFDESC		:=	aRetFator[ nX ][ 5 ]
		MsUnLock()
		
		nTotDNVP	+=	aRetFator[ nX ][ 1 ]
		
		nFator	:=	aRetFator[ nX ][ 3 ]
 	
 	next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Analitico	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
Else

	cWhere	+=	"%SFT.FT_FILIAL = '" + xFilial( "SFT" ) + "' AND "
	cWhere	+=	"SFT.FT_ENTRADA >= '" + DToS( dDtIni ) + "' AND "
	cWhere	+=	"SFT.FT_ENTRADA <= '" + DToS( dDtFim ) + "' AND "
	cWhere	+=	"( SFT.FT_CFOP IN " + aCfop[1] + " OR  SFT.FT_CFOP IN " + aCfop[2] + " ) AND "
	cWhere	+=	"SFT.FT_DTCANC = '' AND "
	cWhere	+=	"SFT.D_E_L_E_T_=' ' "
	
	cOrder	:=	"ORDER BY SFT.FT_CFOP, SFT.FT_NFISCAL, SFT.FT_SERIE, SFT.FT_CLIEFOR, SFT.FT_LOJA, SFT.FT_PRODUTO%"
	
	cFrom	+=	"%" + RetSqlName( "SFT" ) + " SFT "
	cFrom	+=	"JOIN " + RetSqlName( "SX5" ) + " SX5 ON "
	cFrom	+=	"	SX5.X5_TABELA = '13' AND "
	cFrom	+=	"	SX5.X5_CHAVE = SFT.FT_CFOP "
	cFrom	+=	"JOIN " + RetSqlName( "SB1" ) + " SB1 ON "
	cFrom	+=	"	SB1.B1_FILIAL = '" + xFilial( "SB1" ) + "' AND "
	cFrom	+=	"	SB1.B1_COD = SFT.FT_PRODUTO AND "
	cFrom	+=	"	SB1.D_E_L_E_T_ = '' "
	cFrom	+=	"LEFT JOIN " + RetSqlName( "SB5" ) + " SB5 ON "
	cFrom	+=	"	SB5.B5_FILIAL = '" + xFilial( "SB5" ) + "' AND "
	cFrom	+=	"	SB5.B5_COD = SFT.FT_PRODUTO AND "
	cFrom	+=	"	SB5.D_E_L_E_T_ = '' %"

	BeginSql Alias cAliasQry
	                
	    SELECT
			SFT.FT_CFOP CFOP,
			SFT.FT_VALICM VALICM,
			SFT.FT_ICMSCOM ICMSCOM,
			SFT.FT_NFISCAL DOC,
			SFT.FT_SERIE SERIE,
			SFT.FT_CLIEFOR CLIFOR,
			SFT.FT_LOJA LOJA,
			SFT.FT_PRODUTO PRODUTO,
			SB1.B1_DESC DESPRODUTO,
			SB1.B1_POSIPI NCM,
			SX5.X5_DESCRI CFDESC,
			SB5.B5_PROJDES PROJDES
	    FROM 
	    	%Exp:cFrom%
	    WHERE
			%Exp:cWhere+cOrder%
	EndSql	 

	dbSelectArea( cAliasQry )
	( cAliasQry )->( dbGoTop() )
	
	dbSelectArea( 'REL040' )
	REL040->( dbSetOrder( 2 ) )
	
 	While ( cAliasQry )->( !eof() )
 	
 		cTipo	:=	Iif( AllTrim( ( cAliasQry )->CFOP ) $ aCfop[1] , 'CNVP' , 'DNVP' )
 		
 		If ( ( cAliasQry )->( PROJDES <> '1' .Or. ( PROJDES == "1" .And. CFOP $ "5910|5911|6910|6911|1910|1911|2910|2911" ) ) )
		
 			If cTipo == 'CNVP'
				nTotCNVP	+=	( cAliasQry )->( VALICM )
				nTotDNVP	+=	( cAliasQry )->( ICMSCOM )
			Elseif cTipo == 'DNVP'
				nTotDNVP	+=	( cAliasQry )->( VALICM + ICMSCOM )
			Endif
			
			IF !REL040->(MsSeek( cTipo+( cAliasQry )->( CFOP + DOC + SERIE + CLIFOR + LOJA + PRODUTO ) ) )
			   	Reclock( 'REL040' , .T. )                  
				REL040->TIPO		:=	cTipo
				REL040->DOC			:=	( cAliasQry )->DOC
				REL040->SERIE		:=	( cAliasQry )->SERIE
				REL040->CLIFOR		:=	( cAliasQry )->CLIFOR
				REL040->LOJA		:=	( cAliasQry )->LOJA
				REL040->CFOP		:=	( cAliasQry )->CFOP
				REL040->VALICM		:=	( cAliasQry )->VALICM
				REL040->VALCOM		:=	( cAliasQry )->ICMSCOM
				REL040->CFDESC		:=	( cAliasQry )->CFDESC
				REL040->PRODUTO		:=	( cAliasQry )->DESPRODUTO
				REL040->NCM			:=	( cAliasQry )->NCM
				MsUnLock()
			EndIf
		Endif
		
		( cAliasQry )->( dbSkip() ) 
 	EndDo
	 	
 	( cAliasQry )->( dbCloseArea() )
 	
 	for nX := 1 To Len( aRetFator )
 	
 		Reclock( 'REL040' , .T. )                  
		REL040->TIPO		:= 'CNVP'
		REL040->DOC			:= 'CONSOLIDADO'
		REL040->SERIE		:= ''
		REL040->CLIFOR		:= ''
		REL040->LOJA		:= ''
		REL040->CFOP		:= aRetFator[ nX ][ 4 ]
		REL040->VALICM		:= aRetFator[ nX ][ 2 ]
		REL040->VALCOM		:=	0
		REL040->CFDESC		:= aRetFator[ nX ][ 5 ]
		REL040->PRODUTO		:= ''
		REL040->NCM			:= ''
		MsUnLock()
		
		nTotCNVP	+=	aRetFator[ nX ][ 2 ]
		
		Reclock( 'REL040' , .T. )                  
		REL040->TIPO		:= 'DNVP'
		REL040->DOC			:= 'CONSOLIDADO'
		REL040->SERIE		:= ''
		REL040->CLIFOR		:= ''
		REL040->LOJA		:= ''
		REL040->CFOP		:= aRetFator[ nX ][ 4 ]
		REL040->VALICM		:= aRetFator[ nX ][ 1 ]
		REL040->VALCOM		:=	0
		REL040->CFDESC		:= aRetFator[ nX ][ 5 ]
		REL040->PRODUTO		:= ''
		REL040->NCM			:= ''
		MsUnLock()
		
		nTotDNVP	+=	aRetFator[ nX ][ 1 ]
		
		nFator	:=	aRetFator[ nX ][ 3 ]
 	
 	next nX
 	
Endif

cArqInd3  := CriaTrab(NIL,.F.)
IndRegua( 'TOT040' ,cArqInd3,"CNVP+DNVP+TOTAL")
dbSelectArea( 'TOT040' )
dbSetIndex(cArqInd3+OrdBagExt())
dbSetOrder(1)

If nTotDNVP > nTotCNVP
	cReflexo := "O Total deverá ser acrescido ao Saldo da Apuração de ICMS"
	nTotal :=	nTotDNVP - nTotCNVP
Else
	cReflexo := "O Total deverá ser deduzido do Saldo da Apuração de ICMS"
	nTotal :=	nTotCNVP - nTotDNVP
Endif

recLock( 'TOT040'  , .T. )
TOT040->CNVP	:=	nTotCNVP
TOT040->DNVP	:=	nTotDNVP
TOT040->FATOR	:=	nFator
TOT040->REFLEXO	:=	cReflexo
TOT040->TOTAL	:=	nTotal
msUnLock()

cArqInd4  := CriaTrab(NIL,.F.)
IndRegua( 'OBS040' ,cArqInd4,"OBSERV")
dbSelectArea( 'OBS040' )
dbSetIndex(cArqInd4+OrdBagExt())
dbSetOrder(1)

recLock( 'OBS040' , .T. )
OBS040->OBSERV	:=	"Os CFOP's: " + cCfInd + " realizam o cálculo do DNVP e CNVP de acordo com o Fator (AMP) encontrado."
msUnLock()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} R040CriaTrb

Retorna arquivo de trabalho - TRB

@return	aCampos

@author Luccas Curcio
@since 16/04/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function R040CriaTrb()
Local	aCampos	:=	{}

aCampos:={	{"TIPO"     ,"C",04,0},;
			{"CFOP"     ,"C",05,0},;
			{"VALICM"	,"N",14,2},;
			{"VALCOM"	,"N",14,2},;
			{"CFDESC"	,"C",50,0},;
			{"DOC"		,"C",09,0},;
			{"SERIE"	,"C",03,0},;
			{"CLIFOR"	,"C",06,0},;
			{"LOJA"		,"C",02,0},;
			{"PRODUTO"	,"C",TamSx3("B1_DESC")[1],0},;
			{"NCM"		,"C",08,0}}
			
cArqTemp := CriaTrab( aCampos )
dbUseArea( .T. , , cArqTemp , 'REL040' , .T. , .F. )

aCampos:={	{"CNVP"		,"N",14,2},;
			{"DNVP"		,"N",14,2},;
			{"FATOR"	,"N",5,2},;
			{"REFLEXO"	,"C",90,0},;
			{"TOTAL"	,"N",14,2} }
			
cArqTemp2 := CriaTrab( aCampos )
dbUseArea( .T. , , cArqTemp2 , 'TOT040' , .T. , .F. )

aCampos:={	{"OBSERV"	,"C",200,0} }
			
cArqTemp3 := CriaTrab( aCampos )
dbUseArea( .T. , , cArqTemp3 , 'OBS040' , .T. , .F. )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} R040IniRot

inicializa rotina

@return	

@author Luccas Curcio
@since 16/04/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function R040IniRot()
Local	aFirstTxt	:=	{}
Local	aGetParam	:=	{}
Local	cNameWiz	:=	'FSR040' + FWGETCODFILIAL
Local	lRet		:=	.T.
Local	cMvEstado	:=	GetNewPar("MV_ESTADO","")


aAdd (aFirstTxt, "Relatório de Conferência do Incentivo Fiscal Desenvolve - BA")
aAdd (aFirstTxt, "")	
aAdd (aFirstTxt, "Preencha corretamente as perguntas para processamento da rotina.")
aAdd (aFirstTxt, "Informações necessárias para o Relatório de Conferência - Desenvolve - BA")

aAdd (aGetParam, {})
aAdd (aGetParam[1], "Preencha corretamente as informações solicitadas.")
aAdd (aGetParam[1], "Parâmetros para Processamento")
aAdd (aGetParam[1], {})

aAdd (aGetParam[1][3], {1,"Modelo do Relatório",,,,,,})
aAdd (aGetParam[1][3], {3,,,,,{"1 - Sintético" , "2 - Analítico" },,})

If xMagWizard (aFirstTxt, aGetParam, cNameWiz)
	xMagLeWiz(cNameWiz,@aWizard,.T.)
Endif

lRet	:=	Len( aWizard ) > 0

If Empty( &( GetNewPar( 'MV_DESENV' , '{}' ) ) )
	Alert( "O parâmetro MV_DESENV deve ser preenchido com as informações do Incentivo Fiscal." )
	lRet	:=	.F.
Endif

If SB5->( ColumnPos( "B5_PROJDES" ) ) == 0
	Alert( "O campo B5_PROJDES deve ser criado no Dicionário de Dados." )
	lRet	:=	.F.
Endif

If AllTrim(cMvEstado) <> "BA"
	Alert( "O relatório só deve ser executado para estabelecimento localizado no estado da Bahia ( MV_ESTADO = BA )." )
	lRet	:=	.F.
Endif

Return lRet
