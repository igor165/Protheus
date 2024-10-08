#Include "CTBR600.CH"
#Include "PROTHEUS.Ch"


// 17/08/2009 -- Filial com mais de 2 caracteres

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � Ctbr600	� Autor � Simone Mie Sato   	� Data � 09.12.02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Emissao dos lanc. gerados pela rotina de apurac. c/ cta pte���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � Ctbr600()    											  ���
�������������������������������������������������������������������������Ĵ��
���Retorno	 � Nenhum       											  ���
�������������������������������������������������������������������������Ĵ��
���Uso 	     � Generico     											  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Ctbr600()

CTBR600R4()

Return              

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � Ctbr600R4� Autor � Gustavo Henrique  	� Data � 01/09/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Emissao dos lanc. gerados pela rotina de apurac. c/ cta pte���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � Ctbr600R4()    											  ���
�������������������������������������������������������������������������Ĵ��
���Retorno	 � Nenhum       											  ���
�������������������������������������������������������������������������Ĵ��
���Uso 	     � Generico     											  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CTBR600R4()

Local aArea	:= GetArea()
Private NomeProg := "CTBR600"		// Utilizada na funcao CtCGCCabTR().

Private oTotDeb1
Private oTotCred1

oReport := ReportDef()

If !Empty( oReport:uParam )
	Pergunte( oReport:uParam, .F. )
EndIf	

oReport:PrintDialog()

RestArea(aArea)

Return


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor � Gustavo Henrique      � Data �01/09/06  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Esta funcao tem como objetivo definir as secoes, celulas,   ���
���          �totalizadores do relatorio que poderao ser configurados     ���
���          �pelo usuario.                                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �EXPO1: Objeto do relat�rio                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()

Local oBreak
Local oDifLanc   
Local oLote    
Local oReport

//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�                                                                        �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//��������������������������������������������������������������������������

//"Esse programa tem como objetivo imprimir uma relacao para conferencia "
//"dos lancamentos gerados pela ROTINA DE APURACAO DE LUCROS/PERDAS "
//"COM CONTA PONTE."
//"Lancamentos Gerados pela Apuracao de Lucros/Perdas com Conta Ponte"
oReport := TReport():New( "CTBR600", STR0004, "CTR600", { |oReport| ReportPrint(oReport) }, STR0001+STR0002+STR0003 )

oLote := TRSection():New( oReport, STR0017,{"CTZ"},, .F., .F. ) //"Lote"

TRCell():New( oLote, "CTZ_DATA"		, "CTZ", /*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)	
TRCell():New( oLote, "CTZ_LOTE"		, "CTZ", /*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)	
TRCell():New( oLote, "CTZ_SBLOTE"	, "CTZ", /*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oLote, "CTZ_DOC"		, "CTZ", /*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)

oDebCred := TRSection():New( oLote, STR0018,{"CTZ","CT1","CTT","CTD","CTH"},, .F., .F. ) //"Detalhe"

TRCell():New( oDebCred, "CTZ_LINHA" , "CTZ", /*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oDebCred, "CTZ_SEQLIN", "CTZ", /*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oDebCred, "CTZ_CONTA" , "CTZ", /*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oDebCred, "CTZ_CUSTO" , "CTZ", CtbSayApro("CTT"),/*Picture*/,/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oDebCred, "CTZ_ITEM"  , "CTZ", CtbSayApro("CTD"),/*Picture*/,/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oDebCred, "CTZ_CLVL"  , "CTZ", CtbSayApro("CTH"),/*Picture*/,/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oDebCred, "VLRDEB"    ,, STR0015,/*Picture*/,TamSX3("CTZ_VLRDEB")[1]/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oDebCred, "VLRCRD"    ,, STR0016,/*Picture*/,TamSX3("CTZ_VLRCRD")[1]/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)

oBreak		:= TRBreak():New(oDebCred, { || CTZ_LOTE + CTZ_SBLOTE + CTZ_DOC }, STR0010 )	// TOTAL

oTotDeb1	:= TRFunction():New(oDebCred:Cell("VLRDEB" ),"CALC_DEB","SUM",oBreak/*oBreak*/,/*cTitle*/,/*cPicture*/,{||CTZ_VLRDEB}/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)  
oTotCred1	:= TRFunction():New(oDebCred:Cell("VLRCRD"),"CALC_CRED","SUM",oBreak/*oBreak*/,/*cTitle*/,/*cPicture*/,{||CTZ_VLRCRD}/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)  

oTotDeb1:Disable()
oTotCred1:Disable()

TRFunction():New( oDebCred:Cell("VLRDEB"),"TOTAL_DEB", "ONPRINT", oBreak/*oBreak*/,/*cTitle*/, /*cPicture*/, MontaBlock("{ || ValorCTB(oTotDeb1:GetValue(),,,17,2,.F.,'','1',,,,,,.T.,.F.,.T.) }" ) /*uFormula*/, .F., .F.)
TRFunction():New( oDebCred:Cell("VLRCRD"),"TOTAL_CRED", "ONPRINT", oBreak/*oBreak*/,/*cTitle*/, /*cPicture*/, MontaBlock("{ || ValorCTB(oTotCred1:GetValue(),,,17,2,.F.,'','2',,,,,,.T.,.F.,.T.) }" ) /*uFormula*/, .F., .F.)

oDebCred:SetTotalInLine(.F.)
oDebCred:SetHeaderPage(.T.)

Return oReport

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrint� Autor �Gustavo Henrique      � Data �01/09/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Imprime o relatorio definido pelo usuario de acordo com as  ���
���          �secoes/celulas criadas na funcao ReportDef definida acima.  ���
���          �Nesta funcao deve ser criada a query das secoes se SQL ou   ���
���          �definido o relacionamento e filtros das tabelas em CodeBase.���
�������������������������������������������������������������������������Ĵ��
���Retorno   �EXPO1: Objeto do relat�rio                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ReportPrint( oReport )

Local oLote 	:= oReport:Section(1)      
Local oDebCred	:= oReport:Section(1):Section(1)

Local cAlias  	:= ""    
Local cFiltro	:= ""
                                       
Local nTamCred	:= TamSX3("CTZ_VLRCRD")[1]
Local nDecCred := TamSX3("CTZ_VLRCRD")[2]
Local nTamDeb	:= TamSX3("CTZ_VLRDEB")[1]
Local nDecDeb  := TamSX3("CTZ_VLRDEB")[2]

Pergunte( "CTR600",.F.)

#IFNDEF TOP
	            
	cAlias := "CTZ"
	
	dbSelectArea( cAlias )
	dbSetOrder(1)

   MakeAdvplExpr("CTR600")
	
	cFiltro := " DtoS( CTZ->CTZ_DATA ) = '"+ DtoS(mv_par01)	+ "' .And. "
	cFiltro += " CTZ->CTZ_LOTE >= '"			+ mv_par02			+ "' .And. "
	cFiltro += " CTZ->CTZ_LOTE <= '" 		+ mv_par03			+ "' .And. "
	cFiltro += " CTZ->CTZ_SBLOTE >= '" 		+ mv_par04			+ "' .And. "
	cFiltro += " CTZ->CTZ_SBLOTE <=	'" 	+ mv_par05			+ "' .And. "
	cFiltro += " CTZ->CTZ_DOC >= '" 	   	+ mv_par06			+ "' .And. "
	cFiltro += " CTZ->CTZ_DOC <= '"			+ mv_par07			+ "' .And. "
	cFiltro += " CTZ->CTZ_TPSALD = '"		+ mv_par09			+ "' .And. "
	cFiltro += " CTZ->CTZ_MOEDLC = '"		+ mv_par08			+ "' "
                                                    
	oLote:SetFilter(cFiltro,IndexKey())
                                     
	oDebCred:SetRelation({|| xFilial("CTZ")+(cAlias)->(DtoS(CTZ_DATA)+CTZ_LOTE+CTZ_SBLOTE+CTZ_DOC) },"CTZ",1,.T.)
	oDebCred:SetParentFilter({|cParam| (cAlias)->(DtoS(CTZ_DATA)+CTZ_LOTE+CTZ_SBLOTE+CTZ_DOC) == cParam},{|| (cAlias)->(DtoS(CTZ_DATA)+CTZ_LOTE+CTZ_SBLOTE+CTZ_DOC) })

	TRPosition():New( oDebCred, "CT1", 1, {|| xFilial("CT1") + CTZ->CTZ_CONTA })
	TRPosition():New( oDebCred, "CTT", 1, {|| xFilial("CTT") + CTZ->CTZ_CUSTO })
	TRPosition():New( oDebCred, "CTD", 1, {|| xFilial("CTD") + CTZ->CTZ_ITEM  })
	TRPosition():New( oDebCred, "CTH", 1, {|| xFilial("CTH") + CTZ->CTZ_CLVL  })

	oDebCred:Cell("CTZ_CONTA"):SetBlock( { || If( mv_par10 == 2, CT1->CT1_RES, CTZ_CONTA ) } )
	oDebCred:Cell("CTZ_CUSTO"):SetBlock( { || If( mv_par11 == 2, CTT->CTT_RES, CTZ_CUSTO ) } )
	oDebCred:Cell("CTZ_ITEM" ):SetBlock( { || If( mv_par12 == 2, CTD->CTD_RES, CTZ_ITEM  ) } )
	oDebCred:Cell("CTZ_CLVL" ):SetBlock( { || If( mv_par13 == 2, CTH->CTH_RES, CTZ_CLVL  ) } )
	
	CTZ->( dbGoTop() )

#ELSE	

	cAlias := GetNextAlias()

	oLote:BeginQuery()
	
	BeginSql Alias cAlias
		column CTZ_DATA as Date
		column CTZ_VLRDEB as Numeric(nTamDeb,nDecDeb)
		column CTZ_VLRCRD as Numeric(nTamCred,nDecCred)
		SELECT	CTZ.CTZ_FILIAL, CTZ.CTZ_DATA, CTZ.CTZ_LOTE, CTZ.CTZ_SBLOTE, CTZ.CTZ_DOC, CTZ.CTZ_TPSALD, CTZ.CTZ_EMPORI, CTZ.CTZ_FILORI, 
			    CTZ.CTZ_MOEDLC, CTZ.CTZ_LINHA, CTZ.CTZ_SEQLIN, CTZ.CTZ_CONTA, CTZ.CTZ_CUSTO, CTZ.CTZ_ITEM, CTZ.CTZ_CLVL, CTZ.CTZ_VLRDEB, 
			    CTZ.CTZ_VLRCRD, CT1.CT1_RES, CTT.CTT_RES, CTD.CTD_RES, CTH.CTH_RES
    	FROM %Table:CTZ% CTZ
		INNER JOIN %Table:CT1% CT1 ON
			    CT1.CT1_FILIAL = %xFilial:CT1%
			AND CT1.CT1_CONTA = CTZ.CTZ_CONTA
			AND CT1.%notDel%
		LEFT JOIN %Table:CTT% CTT ON
			    CTT.CTT_FILIAL = %xFilial:CTT%
			AND CTT.CTT_CUSTO = CTZ.CTZ_CUSTO
			AND CTT.%notDel%
		LEFT JOIN %Table:CTD% CTD ON
			    CTD.CTD_FILIAL = %xFilial:CTD%
			AND CTD.CTD_ITEM = CTZ.CTZ_ITEM
			AND CTD.%notDel%
		LEFT JOIN %Table:CTH% CTH ON
			    CTH.CTH_FILIAL = %xFilial:CTH%
			AND CTH.CTH_CLVL = CTZ.CTZ_CLVL
			AND CTH.%notDel%
		WHERE 
		   CTZ.CTZ_FILIAL	=	%xFilial:CTZ% 
			AND CTZ.CTZ_DATA	=	%exp:mv_par01%
			AND CTZ.CTZ_LOTE	>=	%exp:mv_par02%
			AND CTZ.CTZ_LOTE	<=	%exp:mv_par03%
			AND CTZ.CTZ_SBLOTE	>=	%exp:mv_par04%
			AND CTZ.CTZ_SBLOTE	<=	%exp:mv_par05%
			AND CTZ.CTZ_DOC		>=	%exp:mv_par06%
			AND CTZ.CTZ_DOC		<=	%exp:mv_par07%
			AND CTZ.CTZ_TPSALD	=	%exp:mv_par09%
			AND CTZ.CTZ_MOEDLC	=	%exp:mv_par08%		
			AND CTZ.%notDel%                        
		ORDER BY 
		    	CTZ.CTZ_FILIAL, CTZ.CTZ_DATA, CTZ.CTZ_LOTE, CTZ.CTZ_SBLOTE, CTZ.CTZ_DOC, CTZ.CTZ_TPSALD, 
		    	CTZ.CTZ_EMPORI, CTZ.CTZ_FILORI, CTZ.CTZ_MOEDLC, CTZ.CTZ_LINHA, CTZ.CTZ_SEQLIN
	EndSql

	oLote:EndQuery()

	oDebCred:SetParentQuery()
	oDebCred:SetParentFilter({|cParam| (cAlias)->(CTZ_LOTE+CTZ_SBLOTE+CTZ_DOC) >= cParam .And. (cAlias)->(CTZ_LOTE+CTZ_SBLOTE+CTZ_DOC) <= cParam},{|| (cAlias)->(CTZ_LOTE+CTZ_SBLOTE+CTZ_DOC)})

	oDebCred:Cell("CTZ_CONTA"):SetBlock( { || If( mv_par10 == 2, CT1_RES, CTZ_CONTA ) } )
	oDebCred:Cell("CTZ_CUSTO"):SetBlock( { || If( mv_par11 == 2, CTT_RES, CTZ_CUSTO ) } )
	oDebCred:Cell("CTZ_ITEM" ):SetBlock( { || If( mv_par12 == 2, CTD_RES, CTZ_ITEM  ) } )
	oDebCred:Cell("CTZ_CLVL" ):SetBlock( { || If( mv_par13 == 2, CTH_RES, CTZ_CLVL  ) } )
	
#ENDIF

oDebCred:Cell("VLRDEB"):SetBlock({ || ValorCTB((cAlias)->CTZ_VLRDEB,,,nTamDeb,nDecDeb,.F.,"","1",,.F.,,,,.T.,.F.,.T.) })
oDebCred:Cell("VLRCRD"):SetBlock({ || ValorCTB((cAlias)->CTZ_VLRCRD,,,nTamCred,nDecCred,.F.,"","2",,.F.,,,,.T.,.F.,.T.) })

oReport:SetCustomText( {|| CtCGCCabTR(,,,,,dDataBase,oReport:Title(),,,,,oReport) } )

oLote:Print()

Return
