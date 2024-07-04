#INCLUDE "PROTHEUS.CH"
#INCLUDE "FISR041.CH"
#INCLUDE "REPORT.CH" 

//-------------------------------------------------------------------
/*/{Protheus.doc} FISR041

Relatorio de conferencia - Invest (incentivo fiscal)

@return	Nil

@author Luccas Curcio
@since 02/06/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function FISR041()
Local oReport
Private	cArqInd		:=	""
Private	cArqTemp	:=	""
Private	aWizard		:=	{}
    
If TRepInUse()		//	verifica se relatorios personalizaveis esta disponivel	
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Interface de impressao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If R041IniRot()
	
		oReport	:= ReportDef()
		oReport:PrintDialog()
		
		If Select("IVS") > 0
			IVS->(DbCloseArea())
		Endif
		FErase(cArqTemp+GetDBExtension())
		FErase(cArqTemp+OrdBagExt())
		FErase(cArqInd+OrdBagExt())
		
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
Local	oReport
Local	oRelat
Local	cCmpValIcm	:=	Iif( Substr(aWizard[1][1] , 1 , 1 ) == "1" , "Valor do ICMS ST" , "Valor do ICMS" )

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
oReport := TReport():New("FISR041","INVEST - ES","FISR041", {|oReport| ReportPrint(oReport)},"INVEST - ES")
oReport:SetTotalInLine(.F.)

Pergunte("FISR041",.F.) 
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
oRelat:=TRSection():New(oReport,"INVEST",{"IVS"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)    //Método construtor da classe TRSection
oRelat:SetPageBreak(.T.)  //Define se salta a página na quebra de seção         

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Apenas se Analitico	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TRCell():New(oRelat,"ID"		,"IVS","ID"					,/*cPicture*/		,1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRelat,"DOC"		,"IVS","Documento"			,/*cPicture*/		,25,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRelat,"SERIE"		,"IVS","Série"				,/*cPicture*/		,15,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRelat,"CLIFOR"	,"IVS","Código Clie/For"	,/*cPicture*/		,20,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRelat,"LOJA"		,"IVS","Loja"				,/*cPicture*/		,15,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRelat,"VALICM"	,"IVS",cCmpValIcm			,"@E 999,999,999.99",25,/*lPixel*/,/*{|| code-block de impressao }*/)

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

R041GetQry()                     
oReport:SkipLine(10) 

oReport:Section(1):Cell("ID"):Hide()

oBreakFil := TRBreak():New(oRelat,oRelat:Cell("ID"),"Total de ICMS",.F.) // "Total Fornecedor   
TRFunction():New(oRelat:Cell("VALICM"),Nil,"SUM",oBreakFil,"","@E 999,999,999.99",/*uFormula*/,.F.,.F.,.F.)       


oRelat:Print()

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
Static Function R041GetQry()    
Local	aTRB		:=	{}
Local	aCfop		:=	xApCfopDef("SAI_IE",.T.)
Local	cAliasQry	:=	GetNextAlias()
Local	cWhere		:=	""
Local	cGroup		:=	""
Local	cOrder		:=	""
Local	dDtIni		:=	Ctod('01/'+StrZero(mv_par01,2)+'/'+Substr(StrZero(mv_par02,4),3,2))
Local	dDtFim		:=	UltimoDia(dDtIni)

aTRB := R041CriaTrb()

cArqTemp := CriaTrab(aTRB)
dbUseArea(.T.,,cArqTemp,"IVS",.T.,.F.)

cArqInd  := CriaTrab(NIL,.F.)
IndRegua("IVS",cArqInd,"DOC+SERIE+CLIFOR+LOJA")    
dbClearIndex()
dbSelectArea("IVS")
dbSetIndex(cArqInd+OrdBagExt())
dbSetOrder(1)

aAdd(aTRB,{cArqTemp,"IVS"})

// ------------------
// Credito Presumido
// ------------------
If Substr(aWizard[1][1] , 1 , 1 ) == "1"

	cWhere	+=	"%SFT.FT_FILIAL = '" + xFilial( "SFT" ) + "' AND "
	cWhere	+=	"SFT.FT_ENTRADA >= '" + DToS( dDtIni ) + "' AND "
	cWhere	+=	"SFT.FT_ENTRADA <= '" + DToS( dDtFim ) + "' AND "
	cWhere	+=	"SFT.FT_CFOP IN "+aCfop[1]+" AND "
	cWhere	+=	"SFT.D_E_L_E_T_=' ' "
	
	cGroup	:=	"GROUP BY SFT.FT_NFISCAL, SFT.FT_SERIE, SFT.FT_CLIEFOR, SFT.FT_LOJA "
	cOrder	:=	"ORDER BY SFT.FT_NFISCAL, SFT.FT_SERIE, SFT.FT_CLIEFOR, SFT.FT_LOJA%"

	BeginSql Alias cAliasQry
	                
	    SELECT
			SFT.FT_NFISCAL NFISCAL, SFT.FT_SERIE SERIE, SFT.FT_CLIEFOR CLIEFOR, SFT.FT_LOJA LOJA, SUM(SFT.FT_VALICM) VALICM
	    FROM 
	        %Table:SFT% SFT
		WHERE
			%Exp:cWhere+cGroup+cOrder%
	EndSql	 

	DbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())
	
	While (cAliasQry)->(!Eof())
			
		DbSelectArea ("IVS")
		IVS->(dbSetOrder(1))
		IF !IVS->(MsSeek( (cAliasQry)->(NFISCAL+SERIE+CLIEFOR+LOJA) ) )
			Reclock("IVS",.T.)                  
			IVS->DOC		:= (cAliasQry)->NFISCAL
			IVS->SERIE		:= (cAliasQry)->SERIE
			IVS->CLIFOR		:= (cAliasQry)->CLIEFOR
			IVS->LOJA		:= (cAliasQry)->LOJA
			IVS->VALICM		:= (cAliasQry)->VALICM
			MsUnLock()	
		EndIf		
		(cAliasQry)->(dbSkip()) 
	End
	 	
 	(cAliasQry)->(DbCloseArea())

// --------------------
// Estorno de Credito
// --------------------
Else

	cTes	:=	xApGetIncent( "INV" , , , { 4 , &(GetNewPar("MV_INVETES","{}") ) , .T. } )[1]

	cWhere	+=	"%SFT.FT_FILIAL = '" + xFilial( "SFT" ) + "' AND "
	cWhere	+=	"SFT.FT_ENTRADA >= '" + DToS( dDtIni ) + "' AND "
	cWhere	+=	"SFT.FT_ENTRADA <= '" + DToS( dDtFim ) + "' AND "
	cWhere	+=	"SFT.D_E_L_E_T_=' ' "
	
	cGroup	:=	"GROUP BY SFT.FT_NFISCAL, SFT.FT_SERIE, SFT.FT_CLIEFOR, SFT.FT_LOJA "
	cOrder	:=	"ORDER BY SFT.FT_NFISCAL, SFT.FT_SERIE, SFT.FT_CLIEFOR, SFT.FT_LOJA%"

	BeginSql Alias cAliasQry
	                
	    SELECT
			SFT.FT_NFISCAL NFISCAL, SFT.FT_SERIE SERIE, SFT.FT_CLIEFOR CLIEFOR, SFT.FT_LOJA LOJA, SUM(SFT.FT_VALICM) VALICM
	    FROM 
	        %Table:SFT% SFT
	    JOIN
	    	%Table:SD2% SD2 ON SFT.FT_FILIAL = SD2.D2_FILIAL AND SFT.FT_NFISCAL = SD2.D2_DOC AND SFT.FT_SERIE = SD2.D2_SERIE AND SFT.FT_CLIEFOR = SD2.D2_CLIENTE AND SFT.FT_LOJA = SD2.D2_LOJA AND SFT.FT_ITEM = SD2.D2_ITEM AND SD2.%NotDel% AND SD2.D2_TES IN ( %Exp:cTes% )
		WHERE
			%Exp:cWhere+cGroup+cOrder%
	EndSql	 

	DbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())
	
 	While (cAliasQry)->(!Eof())
			
		DbSelectArea ("IVS")
		IVS->(dbSetOrder(1))
		IF !IVS->(MsSeek( (cAliasQry)->(NFISCAL+SERIE+CLIEFOR+LOJA) ) )
			Reclock("IVS",.T.)                  
			IVS->DOC		:= (cAliasQry)->NFISCAL
			IVS->SERIE		:= (cAliasQry)->SERIE
			IVS->CLIFOR		:= (cAliasQry)->CLIEFOR
			IVS->LOJA		:= (cAliasQry)->LOJA
			IVS->VALICM		:= (cAliasQry)->VALICM
			MsUnLock()	
		EndIf		
		(cAliasQry)->(dbSkip()) 
	End
	 	
 	(cAliasQry)->(DbCloseArea())
 	
 Endif

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
Static Function R041CriaTrb()
Local	aCampos	:=	{}

aCampos:={	{"DOC"		,"C",09,0},;
			{"SERIE"	,"C",03,0},;
			{"CLIFOR"	,"C",06,0},;
			{"LOJA"		,"C",02,0},;
			{"VALICM"	,"N",14,2} }

Return aCampos

//-------------------------------------------------------------------
/*/{Protheus.doc} R041IniRot

inicializa rotina

@return	

@author Luccas Curcio
@since 16/04/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function R041IniRot()
Local	aFirstTxt	:=	{}
Local	aGetParam	:=	{}
Local	cNameWiz	:=	"FSR041" + FWGETCODFILIAL

aAdd (aFirstTxt, "Relatório de Conferência do Incentivo Fiscal Desenvolve - BA")
aAdd (aFirstTxt, "")	
aAdd (aFirstTxt, "Preencha corretamente as perguntas para processamento da rotina.")
aAdd (aFirstTxt, "Informações necessárias para o Relatório de Conferência - Desenvolve - BA")

aAdd (aGetParam, {})
aAdd (aGetParam[1], "Preencha corretamente as informações solicitadas.")
aAdd (aGetParam[1], "Parâmetros para Processamento")
aAdd (aGetParam[1], {})

aAdd (aGetParam[1][3], {1,"Objetivo da Listagem",,,,,,})
aAdd (aGetParam[1][3], {3,,,,,{"1 - Crédito Presumido" , "2 - Estorno de Crédito" },,})

If xMagWizard (aFirstTxt, aGetParam, cNameWiz)
	xMagLeWiz(cNameWiz,@aWizard,.T.)
Endif

Return Len( aWizard ) > 0