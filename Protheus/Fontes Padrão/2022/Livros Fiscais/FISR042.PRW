#INCLUDE "PROTHEUS.CH"
#INCLUDE "FISR042.CH"
#INCLUDE "REPORT.CH" 

//-------------------------------------------------------------------
/*/{Protheus.doc} FISR042

Relatorio de conferencia - Termo de Acordo Credito Presumido ES (incentivo fiscal)

@return	Nil

@author Luccas Curcio
@since 14/07/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function FISR042()
Local	oReport
Local	aMVFisCP	:=	&(GetNewPar("MV_FISCPES","{}") )
Private	cArqInd		:=	""
Private	cArqTemp	:=	""
Private	aWizard		:=	{}

If ValType(aMVFisCP) == "A" .And. Len(aMVFisCP) > 1
	If ValType(aMVFisCP[2]) <> "N"
		Alert ( STR0003 )	//"Preencher o parametro MV_FISCPES corretamente."
		Return
	EndIf	
Else
	Alert ( STR0003 )	//"Preencher o parametro MV_FISCPES corretamente."
	Return	
Endif
	
If TRepInUse()		//Verifica se relatorios personalizaveis esta disponivel	
	    
	oReport	:= ReportDef()
	oReport:PrintDialog()
	
	If Select("IVS") > 0
		IVS->(DbCloseArea())
	Endif
	FErase(cArqTemp+GetDBExtension())
	FErase(cArqTemp+OrdBagExt())
	FErase(cArqInd+OrdBagExt())

Else
	
	Alert( STR0001 )	//"Rotina disponível apenas em TReport (Relatório Personalizável)."

Endif

Return    

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef

Impressao do relatorio

@return Nil

@author Luccas Curcio
@since 14/07/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ReportDef()
Local	oReport
Local	oRelat

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
oReport := TReport():New("FISR042","Termo de Acordo - ES","FISR042", {|oReport| ReportPrint(oReport)},"Termo de Acordo - ES")
oReport:SetTotalInLine(.F.)

Pergunte("FISR042",.F.) 
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
oRelat:=TRSection():New(oReport,"TERMO DE ACORDO - ES" ,{"IVS"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)    //Método construtor da classe TRSection
oRelat:SetPageBreak(.T.)  //Define se salta a página na quebra de seção         

TRCell():New(oRelat,"TIPO"		,"IVS","Tipo"				,/*cPicture*/		,30,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRelat,"DOC"		,"IVS","Documento"			,/*cPicture*/		,25,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRelat,"SERIE"		,"IVS","Série"				,/*cPicture*/		,15,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRelat,"CLIFOR"	,"IVS","Código Cli/For"		,/*cPicture*/		,20,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRelat,"LOJA"		,"IVS","Loja"				,/*cPicture*/		,15,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRelat,"ITEM"		,"IVS","Item"				,/*cPicture*/		,04,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRelat,"PRODUTO"	,"IVS","Produto"			,/*cPicture*/		,30,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRelat,"VALICM"	,"IVS","Valor ICMS"			,"@E 999,999,999.99",25,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRelat,"VALCRD"	,"IVS","Valor Crédito"		,"@E 999,999,999.99",25,/*lPixel*/,/*{|| code-block de impressao }*/)

Return oReport

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint

Impressao do relatorio

@return Nil

@author Luccas Curcio
@since 14/07/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport)
Local oRelat	:= oReport:Section(1) 

R042GetQry()
 
oReport:SkipLine(10) 

oBreakFil := TRBreak():New(oRelat,oRelat:Cell("TIPO"),"Total do Crédito/Estorno",.F.) // "Total Fornecedor   
TRFunction():New(oRelat:Cell("VALCRD"),Nil,"SUM",oBreakFil,"","@E 999,999,999.99",/*uFormula*/,.F.,.F.,.F.)       


oRelat:Print()

Return         

//-------------------------------------------------------------------
/*/{Protheus.doc} R042GetQry

Cria arquivos da rotina (TRB, indices) e executa query

@return	Nil

@author Luccas Curcio
@since 14/07/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function R042GetQry()    
Local	aTRB		:=	{}
Local	nPMvInterN	:=	&(GetNewPar("MV_FISCPES","{}") )[2]
Local	nPMvInterE	:=	&(GetNewPar("MV_FISCPES","{}") )[3]
Local	cAliasD1D2	:=	""
Local	cAliasQry	:=	GetNextAlias()
Local	cAliasQry2	:=	GetNextAlias()
Local	cWhere		:=	""
Local	cGroup		:=	""
Local	cOrder		:=	""
Local	dDtIni		:=	Ctod('01/'+StrZero(mv_par01,2)+'/'+Substr(StrZero(mv_par02,4),3,2))
Local	dDtFim		:=	UltimoDia(dDtIni)

aTRB := R042CriaTrb()

cArqTemp := CriaTrab(aTRB)
dbUseArea(.T.,,cArqTemp,"IVS",.T.,.F.)

cArqInd  := CriaTrab(NIL,.F.)
IndRegua("IVS",cArqInd,"TIPO+DOC+SERIE+CLIFOR+LOJA")    
dbClearIndex()
dbSelectArea("IVS")
dbSetIndex(cArqInd+OrdBagExt())
dbSetOrder(1)

aAdd(aTRB,{cArqTemp,"IVS"})

//------------------------------------------------------------------------

cWhere	:=	"%SFT.FT_FILIAL = '" + xFilial( "SFT" ) + "' AND "
cWhere	+=	"SFT.FT_ENTRADA >= '" + DToS( dDtIni ) + "' AND "
cWhere	+=	"SFT.FT_ENTRADA <= '" + DToS( dDtFim ) + "' AND "
cWhere	+=	"SUBSTRING( SFT.FT_CFOP , 1 , 1 ) IN ( '5','6' ) AND "
cWhere	+=	"SFT.D_E_L_E_T_ = ' '%"

BeginSql Alias cAliasQry
                
    SELECT
		SFT.FT_TIPOMOV TIPOMOV,
		SFT.FT_NFISCAL NFISCAL,
		SFT.FT_SERIE SERIE,
		SFT.FT_CLIEFOR CLIEFOR,
		SFT.FT_LOJA LOJA,
		SFT.FT_ITEM ITEM,
		SFT.FT_PRODUTO PRODUTO,
		SFT.FT_CFOP CFOP,
		SFT.FT_TIPO TIPO,
		SFT.FT_VALICM VALICM,
		SF4.F4_ESCRDPR ESCRDPR
    FROM 
        %Table:SFT% SFT
    JOIN
    	%Table:SD2% SD2 ON SFT.FT_FILIAL = SD2.D2_FILIAL AND SFT.FT_NFISCAL = SD2.D2_DOC AND SFT.FT_SERIE = SD2.D2_SERIE AND SFT.FT_CLIEFOR = SD2.D2_CLIENTE AND SFT.FT_LOJA = SD2.D2_LOJA AND SFT.FT_ITEM = SD2.D2_ITEM AND SD2.%NotDel%
    JOIN
    	%Table:SF4% SF4 ON SD2.D2_TES = SF4.F4_CODIGO AND SF4.%NotDel% AND SF4.F4_ESCRDPR IN ( '1' , 'S' )
    WHERE
		%Exp:cWhere%
EndSql	 

DbSelectArea(cAliasQry)
(cAliasQry)->(DbGoTop())

While (cAliasQry)->(!Eof())

	DbSelectArea ("IVS")
	IVS->(dbSetOrder(1))
	
	If !IVS->(MsSeek( (cAliasQry)->(NFISCAL+SERIE+CLIEFOR+LOJA) ) )
		Reclock("IVS",.T.)
		IVS->TIPO		:=	XR42GetDesc( (cAliasQry)->CFOP )
		IVS->DOC		:= (cAliasQry)->NFISCAL
		IVS->SERIE		:= (cAliasQry)->SERIE
		IVS->CLIFOR		:= (cAliasQry)->CLIEFOR
		IVS->ITEM		:= (cAliasQry)->ITEM
		IVS->PRODUTO	:= (cAliasQry)->PRODUTO
		IVS->LOJA		:= (cAliasQry)->LOJA
		IVS->VALICM		:= (cAliasQry)->VALICM
		IVS->VALCRD		:= ( (cAliasQry)->VALICM * Iif( SubStr( IVS->TIPO,1,1 ) $ "3" , nPMvInterN , nPMvInterE ) ) / 100
		MsUnLock()
	Endif
	
	(cAliasQry)->(dbSkip()) 
End
 	
(cAliasQry)->(DbCloseArea())

//------------------------------------------------------------------------

cWhere	:=	"%SFT.FT_FILIAL = '" + xFilial( "SFT" ) + "' AND "
cWhere	+=	"SFT.FT_ENTRADA >= '" + DToS( dDtIni ) + "' AND "
cWhere	+=	"SFT.FT_ENTRADA <= '" + DToS( dDtFim ) + "' AND "
cWhere	+=	"SUBSTRING( SFT.FT_CFOP , 1 , 1 ) IN ( '1','2' ) AND "
cWhere	+=	"SFT.FT_TIPO IN ( 'D' ) AND "
cWhere	+=	"SFT.D_E_L_E_T_ = ' '%"

BeginSql Alias cAliasQry2
                
    SELECT
		SFT.FT_TIPOMOV TIPOMOV,
		SFT.FT_NFISCAL NFISCAL,
		SFT.FT_SERIE SERIE,
		SFT.FT_CLIEFOR CLIEFOR,
		SFT.FT_LOJA LOJA,
		SFT.FT_ITEM ITEM,
		SFT.FT_PRODUTO PRODUTO,
		SFT.FT_CFOP CFOP,
		SFT.FT_TIPO TIPO,
		SFT.FT_VALICM VALICM,
		SF4.F4_ESCRDPR ESCRDPR
    FROM 
        %Table:SFT% SFT
    JOIN
    	%Table:SD1% SD1 ON SFT.FT_FILIAL = SD1.D1_FILIAL AND SFT.FT_NFISCAL = SD1.D1_DOC AND SFT.FT_SERIE = SD1.D1_SERIE AND SFT.FT_CLIEFOR = SD1.D1_FORNECE AND SFT.FT_LOJA = SD1.D1_LOJA AND SFT.FT_ITEM = SD1.D1_ITEM AND SD1.%NotDel%
    JOIN
    	%Table:SF4% SF4 ON SD1.D1_TES = SF4.F4_CODIGO AND SF4.%NotDel% AND SF4.F4_ESCRDPR IN ( '1' , 'S' )
    WHERE
		%Exp:cWhere%
EndSql	 

DbSelectArea(cAliasQry2)
(cAliasQry2)->(DbGoTop())

While (cAliasQry2)->(!Eof())

	DbSelectArea ("IVS")
	IVS->(dbSetOrder(1))
	
	If !IVS->(MsSeek( (cAliasQry2)->(NFISCAL+SERIE+CLIEFOR+LOJA) ) )
		Reclock("IVS",.T.)
		IVS->TIPO		:=	XR42GetDesc( (cAliasQry2)->CFOP )
		IVS->DOC		:= (cAliasQry2)->NFISCAL
		IVS->SERIE		:= (cAliasQry2)->SERIE
		IVS->CLIFOR		:= (cAliasQry2)->CLIEFOR
		IVS->ITEM		:= (cAliasQry2)->ITEM
		IVS->PRODUTO	:= (cAliasQry2)->PRODUTO
		IVS->LOJA		:= (cAliasQry2)->LOJA
		IVS->VALICM		:= (cAliasQry2)->VALICM
		IVS->VALCRD		:= ( (cAliasQry2)->VALICM * Iif( SubStr( IVS->TIPO,1,1 ) $ "1" , nPMvInterN , nPMvInterE ) ) / 100
		MsUnLock()
	Endif
	
	(cAliasQry2)->(dbSkip()) 
End
 	
(cAliasQry2)->(DbCloseArea())

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} R042CriaTrb

Retorna arquivo de trabalho - TRB

@return	aCampos

@author Luccas Curcio
@since 14/07/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function R042CriaTrb()
Local	aCampos	:=	{}

aCampos:={	{"TIPO"		,"C",25,0},;
			{"DOC"		,"C",09,0},;
			{"SERIE"	,"C",03,0},;
			{"CLIFOR"	,"C",06,0},;
			{"LOJA"		,"C",02,0},;
			{"ITEM"		,"C",04,0},;
			{"PRODUTO"	,"C",30,0},;
			{"VALICM"	,"N",14,2},;
			{"VALCRD"	,"N",14,2} }

Return aCampos

//-------------------------------------------------------------------
/*/{Protheus.doc}  XR42GetDesc

Retorna descricao do registro no relatorio

@param	cCfop	->	CFOP da operacao que esta sendo verificada

@return	cRet	->	Descricao para o registro

@author Luccas Curcio
@since 14/07/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function XR42GetDesc ( cCfop )
Local cRet	:=	""

If SubStr( cCfop , 1 , 1 ) $ "1"
	cRet	:=	"1.Estorno - Interno"
Elseif SubStr( cCfop , 1 , 1 ) $ "2"
	cRet	:=	"2.Estorno - Interestadual"
Elseif SubStr( cCfop , 1 , 1 ) $ "5"
	cRet	:=	"3.Crédito - Interno"
Elseif SubStr( cCfop , 1 , 1 ) $ "6"
	cRet	:=	"4.Crédito - Interestadual"
Endif

Return cRet