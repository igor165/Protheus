#INCLUDE "FISR013.CH" 
#INCLUDE "PROTHEUS.CH"
#IFNDEF WINDOWS
#DEFINE PSAY SAY
#ENDIF
#DEFINE CHRCOMP If(aReturn[4]==1,15,18)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³FIRS013   ³ Autor ³ Rodrigo Zatt          ³ Data ³05/03/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressao da CFEM                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function Fisr013()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define Variaveis                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local Titulo    := OemToAnsi(STR0001)  //"Compensacao financeira pela exploracao de recursos minerais (CFEM)"
Local cDesc1    := OemToAnsi(STR0002)  //"Este programa ira emitir o relatório a Compensacao financeira "
Local cDesc2    := OemToAnsi(STR0003)  //"pela exploracao de recursos minerais (CFEM)."
Local cDesc3    := OemToAnsi("")
Local cString   := "SFT"
Local lDic      := .F.  		// Habilita/Desabilita Dicionario
Local lComp     := .T.  		// Habilita/Desabilita o Formato Comprimido/Expandido
Local lFiltro   := .T.  		// Habilita/Desabilita o Filtro
Local wnrel     := "FISR013" 	// Nome do Arquivo utiLizado no Spool
Local nomeprog  := "FISR013" 	// Nome do programa
Local aDadosSX1  := {}

Private Tamanho := "G" 		 // P/M/G
Private Limite  := 220 		 // 80/132/220
Private aOrdem  := {}  		 // Ordem do Relatorio
Private cPerg   := "FISR013" // Pergunta do Relatorio
Private aReturn := {STR0004, 1,STR0005, 1, 2, 1, "",1 }  //"Zebrado"###"Administracao"

Private lEnd    := .F.// Controle de cancelamento do relatorio
Private m_pag   := 1  // Contador de Paginas
Private nLastKey:= 0  // Controla o cancelamento da SetPrint e SetDefault

// Ajuste das perguntas 01 e 02 que foram criadas como tipo "Combo" na V12.
// Este trecho devera ser removido no release 12.1.20.
If FindFunction("ENGSX1N117")
	aAdd( aDadosSX1, { { 'FISR013', '01' }, { { 'X1_GSC', 'G', 'C' } } } )
	aAdd( aDadosSX1, { { 'FISR013', '02' }, { { 'X1_GSC', 'G', 'C' } } } )

	ENGSX1N117(aDadosSX1)
EndIf 
                     
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utiLizadas para parametros                            ³
//³ mv_par01 = Data Inicial											     ³
//³ mv_par02 = Data Final										 	     ³
//³ mv_par03 = Valor dos Tributos ICMS								     ³
//³ mv_par04 = Valor dos Tributos ISS                               ³
//³ mv_par05 = Valor dos Tributos PIS								     ³
//³ mv_par06 = Valor dos Tributos COFINS                            ³
//³ mv_par07 = Valor dos Tributos Outros                            ³
//³ mv_par08 = Considera frete em Entrada ou Saída                  ³
//³ mv_par09 = Tipo de Deducao dos Tributos		                   ³
//³ mv_par10 = Produtos Consumidos/Industrializados                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Envia para a SetPrint                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel:=SetPrint(cString,wnrel,cperg,@titulo,cDesc1,cDesc2,cDesc3,lDic,aOrdem,lComp,Tamanho,lFiltro)

If ( nLastKey==27 )
	dbSelectArea(cString)                       
	dbSetOrder(1)
	dbClearFilter()	                      
	Return
Endif
SetDefault(aReturn,cString)
If ( nLastKey==27 )
	dbSelectArea(cString)
	dbSetOrder(1)
	dbClearFilter()
	Return
Endif

RptStatus({|lEnd| nPagina := ImpDet(@lEnd,wnRel,cString,nomeprog,Titulo)},Titulo)


dbSelectArea(cString)
dbClearFilter()
Set Device To Screen
Set Printer To

If (aReturn[5] = 1)
	dbCommitAll()
	OurSpool(wnrel)
Endif
MS_FLUSH()

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³FIRS013   ³ Autor ³ Rodrigo Zatt          ³ Data ³05/03/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressao do Relatorio CFEM                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImpDet()

Local aLay	    	:= {}
Local aDadQ01 		:= {}
Local aDadQ01Mat	:= {}
Local aDadQ02 		:= {}
Local aRegra		:= {}
Local aQ4ConsInd	:= { 0 , 0 }
Local aDeducoes		:= { 0 , 0 , 0 , 0 , 0 , 0 }
Local cAliasSFT 	:= "SFT"
Local cAliasSB1 	:= "SB1"
Local cAliasSX5 	:= "SX5"
Local cArqInd   	:= " "
Local cInscr		:= " "
Local cCNPJ			:= " "
Local cIM			:= " "
Local cIndex		:= " "
Local cTipo			:= " "
Local cFiltroUsr	:= aReturn[7]
Local cChaveSFT 	:= " "
Local cDesOP    	:= " "
Local cDesProd  	:= " "
Local cCalcCfem   	:= " "
Local cTipoCfem   	:= " "
Local nPos			:= ""
Local cTES			:= ""
Local cQuery    	:= ""   
Local cCmpQry		:= ""
Local cChave    	:= ""
Local cFiltro   	:= ""
Local cAlsConInd	:= ""
Local cMvCfemTrf	:= GetNewPar( "MV_CFEMTRF" , "" )
Local dData			:= CToD("//")
Local dDataEmi  	:= CToD("//") 
Local dDataEnt  	:= CToD("//") 
Local Li        	:= 0                                               
Local nPagina   	:= 1
Local nI			:= 0
Local nX			:= 0
Local nPos1     	:= 0
Local nPos2     	:= 0
Local nTotal    	:= 0
Local nTotIcms  	:= 0
Local nTotPis   	:= 0
Local nTotCof   	:= 0 
Local nAliqu    	:= 0
Local nAliqCfem   	:= 0
Local nQ4Fat		:= 0
Local nQ4DT			:= 0
Local nQ4DS			:= 0
Local nQ4DTri		:= 0
Local nQ4Tra		:= 0
Local nQ4Seg		:= 0
Local nQ4Trib		:= 0
Local nQ4Aliq		:= 0
Local nQ4Trf		:= 0
Local nQ4ValCfem	:= 0
Local nAliqQ1  	:= 0 
Local nAliQSom 	:= 0
Local nTot			:= 0  
Local nIcmsTot		:= 0
Local nIssTot  	:= 0
Local nPisTot  	:= 0
Local nCofTot  	:= 0
Local nOutrTot		:= 0
Local nFSTot		:= 0
Local nValLiq		:= 0
Local nValPrdTrf	:= 0
Local nValPrdVen	:= 0
Local aStruSFT  	:= {}
Local aCamposSFT	:= {}
Local lQuery    	:= .F.
Local cMvCfemEnt	:= GetNewPar( "MV_CFEMENT" , "" )
Local cMvCfemSai	:= GetNewPar( "MV_CFEMSAI" , "" )
Local nValCFEMAP   := 0

dbSelectArea( "SFT" )
SFT->( dbSetOrder( 1 ) )
dbSelectArea( "SD1" )
SD1->( dbSetOrder( 1 ) )
dbSelectArea( "SF4" )
SF4->( dbSetOrder( 1 ) )
dbSelectArea( "SD2" )
SD2->( dbSetOrder( 3 ) )
dbSelectArea( "SX5" )
SX5->( dbSetOrder( 1 ) )
dbSelectArea( "SB1" )
SB1->( dbSetOrder( 1 ) )

#IFDEF TOP
  
    If TcSrvType()<>"AS/400"
    
		aAdd(aCamposSFT,"FT_FILIAL")
		aAdd(aCamposSFT,"FT_ENTRADA")	    
		aAdd(aCamposSFT,"FT_EMISSAO")
		aAdd(aCamposSFT,"FT_NFISCAL")
		aAdd(aCamposSFT,"FT_SERIE")
		aAdd(aCamposSFT,"FT_CLIEFOR")
		aAdd(aCamposSFT,"FT_LOJA")
		aAdd(aCamposSFT,"FT_CFOP")
		aAdd(aCamposSFT,"FT_PRODUTO")   
		aAdd(aCamposSFT,"FT_VALCONT")
		aAdd(aCamposSFT,"FT_VALICM")
		aAdd(aCamposSFT,"FT_VALPIS")
		aAdd(aCamposSFT,"FT_VALCOF")
		aAdd(aCamposSFT,"FT_DTCANC")
		aAdd(aCamposSFT,"FT_OBSERV")
		aAdd(aCamposSFT,"FT_ITEM")
		aAdd(aCamposSFT,"FT_TIPOMOV")
		aAdd(aCamposSFT,"FT_TIPO")		   	    
		aAdd(aCamposSFT,"FT_FRETE")		   	    
		aAdd(aCamposSFT,"FT_SEGURO")		   	    
		aAdd(aCamposSFT,"FT_ICMSRET")
		aAdd(aCamposSFT,"FT_QUANT")
		aAdd(aCamposSFT,"FT_POSIPI")

    	aStruSFT  := SFT->(MTRCFEMStr(aCamposSFT,@cCmpQry))
    	SFT->(dbCloseArea())

		lQuery		:=	.T.
		cAliasSFT	:=	GetNextAlias()
		cAliasSB1	:=	cAliasSFT
		cAliasSX5	:=	cAliasSFT
		
		cQuery		:= "SELECT " + cCmpQry + ", X5_DESCRI, B1_CFEM, B1_CFEMA, B1_CFEMS, B1_DESC "
		
		cQuery		+= "FROM " + RetSqlName( "SFT" ) + " SFT "
		cQuery		+= "JOIN " + RetSqlName( "SB1" ) + " SB1 ON SB1.B1_FILIAL = '" + xFilial( "SB1" ) + "' AND SB1.B1_COD = SFT.FT_PRODUTO AND SB1.B1_CFEM = '1' AND SB1.D_E_L_E_T_ = ' ' "
		cQuery		+= "JOIN " + RetSqlName( "SX5" ) + " SX5 ON SX5.X5_FILIAL = '" + xFilial( "SX5" ) + "' AND SX5.X5_TABELA = '13' AND SX5.X5_CHAVE = SFT.FT_CFOP AND SX5.D_E_L_E_T_ = ' ' "
	
		cQuery		+= "WHERE "
		cQuery		+= "FT_FILIAL	=	'" + xFilial("SFT") + "'	AND "
		cQuery		+= "FT_EMISSAO	>=	'" + DToS(mv_par01) + "'	AND "
		cQuery		+= "FT_EMISSAO	<=	'" + DToS(mv_par02) + "'	AND "
		cQuery		+= "FT_DTCANC		= 	'' 						AND "
		cQuery		+= "FT_OBSERV NOT LIKE '%CANCELAD%' 			AND "
		cQuery      += "FT_TIPO NOT IN ('B','D') AND "
		cQuery		+= "SFT.D_E_L_E_T_ = ' ' "
		
		cQuery		+= "ORDER BY FT_EMISSAO,FT_NFISCAL,FT_CLIEFOR,FT_LOJA"
	
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSFT,.T.,.T.)
	
		For nX := 1 To len(aStruSFT)
			If aStruSFT[nX][2] <> "C" 
				TcSetField(cAliasSFT,aStruSFT[nX][1],aStruSFT[nX][2],aStruSFT[nX][3],aStruSFT[nX][4])
			EndIf
		Next nX
	
		dbSelectArea(cAliasSFT)	
	Else

#ENDIF
		cArqInd	:=	CriaTrab(NIL,.F.)
		cChave	:=	"DTOS(FT_EMISSAO)+FT_SERIE+FT_NFISCAL+FT_TIPO+FT_CLIEFOR+FT_LOJA"
		cFiltro :=  "FT_FILIAL == '" + xFilial("SFT") + "' .And. "
		cFiltro	+=	"DtoS(FT_EMISSAO) >= '" + DtoS(mv_par01) + "' .And. DtoS(FT_EMISSAO) <= '" + DtoS(mv_par02) + "' .And. "
		cFiltro +=  "Empty(FT_DTCANC) .And. !('CANCELAD'$FT_OBSERV) "

	
		IndRegua(cAliasSFT,cArqInd,cChave,,cFiltro,STR0006)  //"Selecionando Registros..."
		#IFNDEF TOP
			DbSetIndex(cArqInd+OrdBagExt())
		#ENDIF                
		(cAliasSFT)->(dbGotop())
		SetRegua(LastRec())

#IFDEF TOP
	Endif    
#ENDIF

// Layout
If MV_PAR08 == 1 //Entrada
	aLay := RetLayout()
Else
	aLay := LayOutExt()
EndIf

dbSelectArea(cAliasSFT)
SetRegua(LastRec())
(cAliasSFT)->(DbGoTop())
                
cChaveSFT := (cAliasSFT)->(FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_ITEM+FT_CLIEFOR+FT_LOJA+FT_CFOP)

aRegra := {}  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calculo da Compensacao atraves de Documentos Fiscai emitidos no Periodo: Consulta a tabela SFT para processar o Livro Fiscal do periodo	³
//³ e calcular - atraves da aliquota informada em cada produto - o valor da compensacao. Valores considerados para venda dos produtos e/ou	³
//³ transferencias realizadas.																												³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While (cAliasSFT)->(!Eof()) .And. cChaveSFT == (cAliasSFT)->(FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_ITEM+FT_CLIEFOR+FT_LOJA+FT_CFOP)  
   		 
	    //Filtro Usuario
	    If !Empty(cFiltroUsr) .And. !(&((cAliasSFT)->(cFiltroUsr)))
	    	(cAliasSFT)->(DbSkip())
	    	cChaveSFT := (cAliasSFT)->(FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_ITEM+FT_CLIEFOR+FT_LOJA+FT_CFOP)
	    	Loop
	    EndIf		 
	    
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Identifica o codigo do TES do item	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	  	If (cAliasSFT)->FT_TIPOMOV == "E"
			If SD1->(MsSeek(xFilial("SD1")+(cAliasSFT)->(FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA+FT_PRODUTO+FT_ITEM)))
				cTES := SD1->D1_TES
			EndIf
	  	ElseIf (cAliasSFT)->FT_TIPOMOV == "S"
			If SD2->(MsSeek(xFilial("SD2")+(cAliasSFT)->(FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA+FT_PRODUTO+FT_ITEM)))
				cTES := SD2->D2_TES
			EndIf
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o TES da operacao gera duplicata	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	 	If (SF4->(MsSeek(xFilial("SF4")+cTES)) .And. SF4->F4_DUPLIC <> "S" .And. !(Alltrim((cAliasSFT)->FT_CFOP) $ cMvCfemTrf) .And. !AllTrim((cAliasSFT)->FT_CFOP) $ cMvCfemEnt) .Or. Alltrim((cAliasSFT)->FT_CFOP) $ cMvCfemSai
			(cAliasSFT)->(DbSkip())
			cChaveSFT := (cAliasSFT)->(FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_ITEM+FT_CLIEFOR+FT_LOJA+FT_CFOP)
		 	Loop
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atribui as datas de Entrada e Emissao			³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dDataEmi := ( cAliasSFT )->FT_EMISSAO
		dDataEnt := ( cAliasSFT )->FT_ENTRADA
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Quando estiver em ambiente DBF, preciso posicionar as tabelas SB1 e SX5 para consultar informacoes do Produto e	³
		//³ descricao da operacao.																							³
		//³ Caso seja TOP, essas informacoes ja foram retornadas pela query (JOIN com SB1 e SX5).							³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
		If !lQuery
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Identifica a descricao da Operacao (SX5)		³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                    
			If SX5->( MsSeek( xFilial( "SX5" ) + "13" + ( cAliasSFT )->FT_CFOP ) )
				cDesOP := SubStr(Alltrim(SX5->X5_DESCRI),1,32)
			Endif 
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Informacoes do Produto: Gera CFEM; Tipo; Aliquota	³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SB1->( MsSeek( xFilial( "SB1" ) + ( cAliasSFT )->FT_PRODUTO ) )
				cDesProd	:=	SubStr( Alltrim( SB1->B1_DESC ) , 1 , 30 )
				cCalcCfem	:=	SB1->B1_CFEM                                    
				cTipoCfem	:=	SB1->B1_CFEMS                                    
				nAliqQ1		:=	SB1->B1_CFEMA	//Analisar necessidade da variavel nAliqQ1
				nAliqCfem	:=	SB1->B1_CFEMA
			Endif                		  	
		  	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Considera filtro do usuario                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty( cCalcCfem ) .Or. cCalcCfem <> "1" 
				(cAliasSFT)->(dbSkip())
				cChaveSFT := (cAliasSFT)->(FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_ITEM+FT_CLIEFOR+FT_LOJA+FT_CFOP)
				Loop
			Endif
		
		Else
			cDesOP		:=	SubStr( Alltrim( ( cAliasSX5 )->X5_DESCRI ) , 1 , 28 )
			cDesProd	:=	SubStr( Alltrim( ( cAliasSB1 )->B1_DESC ) , 1 , 30 )
			cCalcCfem	:=	( cAliasSB1 )->B1_CFEM
			cTipoCfem	:=	( cAliasSB1 )->B1_CFEMS
			nAliqQ1		:=	( cAliasSB1 )->B1_CFEMA
			nAliqCfem	:=	( cAliasSB1 )->B1_CFEMA
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Condicao utilizada para identificar como os valores do produto serao aplicados a base de calculo da compensacao							³
		//³ Quando se tratar de saida e produto configurado como CFEM Receita, entrara na base de Calculo											³
		//³ Quando se tratar de entrada e produto configurado como CFEM Deducao, sera deduzido da Base de Calculo (dependendo da configuracao SX1)	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Left((cAliasSFT)->FT_CFOP,1) $ "567" .And. cTipoCfem $ "1"
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Tratamento ao utilizar o parametro MV_CFEMTRF: Ao preencher este parametro com os CFOP's considerados como	³
			//³ transferencia, o valor que ira compor a base de calculo da compensacao nao sera o valor da transferencia	³
			//³ da nota fiscal, sera buscada o valor de custo medio do periodo. Serao desconsiderados as demais deducoes.	³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Alltrim( ( cAliasSFT )->FT_CFOP ) $ cMvCfemTrf .And. ( cAliasSFT )->FT_TIPOMOV == "S" .And. !( cAliasSFT )->FT_TIPOMOV $ "DB"
				nValPrdTrf	:=	CFEMTransf( ( cAliasSFT )->FT_PRODUTO , SD2->D2_LOCAL , MV_PAR01 , MV_PAR02 , ( cAliasSFT )->FT_QUANT )
				nValLiq		:=	nValPrdTrf
			
			Else
				aDeducoes[ 1 ]	:=	Iif( ( cAliasSFT )->FT_TIPO == "S" , ( cAliasSFT )->FT_VALICM , 0 )	// Valor de ISS
				aDeducoes[ 2 ]	:=	Iif( ( cAliasSFT )->FT_TIPO == "S" , 0 , ( cAliasSFT )->FT_VALICM )
				aDeducoes[ 3 ]	:=	( cAliasSFT )->FT_VALPIS
				aDeducoes[ 4 ]	:=	( cAliasSFT )->FT_VALCOF
				aDeducoes[ 5 ]	:=	( cAliasSFT )->FT_FRETE
				aDeducoes[ 6 ]	:=	( cAliasSFT )->FT_SEGURO
				nValPrdVen		:=	( cAliasSFT )->FT_VALCONT
				nValLiq			:=	( cAliasSFT )->( FT_VALCONT - ( aDeducoes[ 1 ]+aDeducoes[ 2 ]+aDeducoes[ 3 ]+aDeducoes[ 4 ]+aDeducoes[ 5 ]+aDeducoes[ 6 ] ) )
			Endif
			
			nPos1 := aScan( aDadQ01 , { |x| x[ 13 ] == cChaveSFT } )
			
			If nPos1 > 0
				aDadQ01[ nPos1 , 07 ]	+=	( cAliasSFT )->FT_VALCONT
				aDadQ01[ nPos1 , 08 ]	+=	aDeducoes[ 2 ]
				aDadQ01[ nPos1 , 09 ]	+=	aDeducoes[ 1 ]
				aDadQ01[ nPos1 , 10 ]	+=	aDeducoes[ 3 ]
				aDadQ01[ nPos1 , 11 ]	+=	aDeducoes[ 4 ]
				aDadQ01[ nPos1 , 15 ]	+=	aDeducoes[ 5 ]
				aDadQ01[ nPos1 , 16 ]	+=	aDeducoes[ 6 ]
				aDadQ01[ nPos1 , 17 ]	+=	nValLiq
				aDadQ01[ nPos1 , 19 ]	+=	(cAliasSFT)->FT_QUANT
			
			Else 
				aAdd(	aDadQ01	, {	(cAliasSFT)->FT_NFISCAL	,;	// 01 - numero da nota
									dDataEmi				,;	// 02 - data emissao
									dDataEnt				,;	// 03 - data entrada
									cDesOP					,;	// 04 - desc. da operacao
									cDesProd				,;	// 05 - desc. do produto
									nAliqCfem				,;	// 06 - aliq. produto
									nValPrdVen				,;	// 07 - Valor total do produto (VENDA)
									aDeducoes[ 2 ]			,;	// 08 - Valor do ICMS
									aDeducoes[ 1 ]			,;	// 09 - Valor do ISS
									aDeducoes[ 3 ]			,;	// 10 - Valor do Pis
									aDeducoes[ 4 ]			,;	// 11 - Valor do Cofins
									(cAliasSFT)->FT_CFOP	,;	// 12 - CFOP
									cChaveSFT				,;	// 13 - chave do array															
									nAliqQ1					,;	// 14 - Aliquota	
									aDeducoes[ 5 ]		 	,;	// 15 - Frete
									aDeducoes[ 6 ]		 	,;	// 16 - Seguro
									nValLiq					,;	// 17 - Valor Liquido
									nValPrdTrf				,; // 18 - Valor total do produto (TRANSFERENCIA)
									(cAliasSFT)->FT_QUANT})    // 19 - Quantidade do item
			Endif	
			
			
			
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Adiciona o valor de frete e seguro para MV_PAR08 = 2 - Nota de Saida	³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If MV_PAR08 == 2
				nQ4Tra += (cAliasSFT)->FT_FRETE
				nQ4Seg += (cAliasSFT)->FT_SEGURO
			EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Condicao utilizada para identificar como os valores do produto serao aplicados a base de calculo da compensacao							³
		//³ Quando se tratar de saida e produto configurado como CFEM Receita, entrara na base de Calculo											³
		//³ Quando se tratar de entrada e produto configurado como CFEM Deducao, sera deduzido da Base de Calculo (dependendo da configuracao SX1)	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Elseif Left( ( cAliasSFT )->FT_CFOP , 1 ) $ "123" .And. cTipoCfem $ "23"
	    	
	    	nPos2 := Ascan(aDadQ02,{|x|x[07]==cChaveSFT})
			
			If nPos2 > 0
				aDadQ02[nPos2,3] +=(cAliasSFT)->FT_VALCONT
			
			Else
				aAdd(	aDadQ02 , {	( cAliasSFT )->FT_NFISCAL	,;	// 01 - numero da nota
							  		dDataEmi					,;	// 02 - data emissao
							  		dDataEnt					,;	// 03 - data entrada
							  		cDesProd					,;	// 04 - desc. do produto
							  		( cAliasSFT )->FT_VALCONT	,;	// 05 - Valor total do produto						  	
							  		( cAliasSFT )->FT_CFOP		,;	// 06 - CFOP
							  		cTipoCfem					,;	// 07 - Deduzão seguro = 2 transporte = 3
							  		cChaveSFT					})	// 08 - Chave do array
			EndIf
		
	    Endif                 
	    
		SD1->(DBSETORDER(19))	// D1_FILIAL+D1_NFORI+D1_SERIORI+D1_FORNECE+D1_LOJA
		If SD1->(MsSeek(xFilial("SD1")+ (cAliasSFT)->FT_NFISCAL + (cAliasSFT)->FT_SERIE + (cAliasSFT)->FT_CLIEFOR + (cAliasSFT)->FT_LOJA))
			While SD1->(!Eof()) .And. xFilial("SD1") + (cAliasSFT)->FT_NFISCAL + (cAliasSFT)->FT_SERIE + (cAliasSFT)->FT_CLIEFOR + (cAliasSFT)->FT_LOJA == SD1->(D1_FILIAL+D1_NFORI+D1_SERIORI+D1_FORNECE+D1_LOJA)
				nPos1 := aScan( aDadQ01 , { |x| x[ 13 ] == cChaveSFT } )
				If Padl(Alltrim((cAliasSFT)->FT_ITEM), 4, "0") == SD1->D1_ITEM
					aDadQ01[nPos1][07] -= SD1->D1_TOTAL
					aDadQ01[nPos1][08] -= SD1->D1_VALICM    //ICMS
					aDadQ01[nPos1][10] -= SD1->D1_VALIMP6	//PIS
					aDadQ01[nPos1][11] -= SD1->D1_VALIMP5	//COFINS
					aDadQ01[nPos1][09] -= SD1->D1_VALISS 	//ISS
					aDadQ01[nPos1][19] -= SD1->D1_QUANT
					aDadQ01[nPos1][17] := aDadQ01[nPos1][07] - aDadQ01[nPos1][08] - aDadQ01[nPos1][10] - aDadQ01[nPos1][11] - aDadQ01[nPos1][09]
					Exit
				EndIf
				SD1->(DbSkip())
			EndDo
		EndIf                                               
					
 		(cAliasSFT)->(dbSkip())	
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Reseta as variaveis de calculo, com excecao das totalizadoras		³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aDeducoes	:=	{ 0 , 0 , 0 , 0 , 0 , 0 }
		nValPrdTrf	:=	0
		nValPrdVen	:=	0
		nValLiq		:=	0
		cChaveSFT	:=	(cAliasSFT)->(FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_ITEM+FT_CLIEFOR+FT_LOJA+FT_CFOP)	
			
 		
EndDo		

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calculo da Compensacao atraves de Consumo e Industrializacao dos Produtos: Consulta a tabela SD3 para processar os Movimentos Internos	³
//³  do periodo e calcular - atraves da aliquota informada em cada produto - o valor da compensacao. 										³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If MV_PAR10 == 2
	
	cAlsConInd	:=	CFEMProd( MV_PAR01 , MV_PAR02 )

	While !( cAlsConInd )->( Eof( ) )
		
		cDesProd	:=	SubStr( Alltrim( ( cAlsConInd )->DESCRICAO ) , 1 , 30 )
		
		nPos1 := aScan( aDadQ01Mat , { |x| x[9] == ( cAlsConInd )->( PRODUTO + OP ) } )
				
		If nPos1 > 0
			aDadQ01Mat[ nPos1 , 06 ]	+=	( cAlsConInd )->QUANT
			aDadQ01Mat[ nPos1 , 07 ]	+=	( cAlsConInd )->VUNIT
			aDadQ01Mat[ nPos1 , 08 ]	+=	( cAlsConInd )->TOTAL
			
		Else 
			aAdd( aDadQ01Mat	, {	( cAlsConInd )->OP					,;	// 01 - Numero da OP
									( cAlsConInd )->EMISSAO				,;	// 02 - Data Emissao
									"Ordem de Produção"					,;	// 03 - Descricao da Operacao
									cDesProd							,;	// 04 - Descricao do Produto
									( cAlsConInd )->ALIQUOTA			,;	// 05 - Aliquota do Produto
									( cAlsConInd )->QUANT				,;	// 06 - Quantidade
									( cAlsConInd )->VUNIT				,;	// 07 - Custo Medio
									( cAlsConInd )->TOTAL				,;	// 08 - Custo Total
									( cAlsConInd )->( PRODUTO + OP )	,;  // 09 - Chave do array
									( cAlsConInd )->( PRODUTO )})		    // 10 - Cod. Produto
		Endif
		
		( cAlsConInd )->( dbSkip( ) )
	End
	
	(cAlsConInd)->( dbCloseArea( ) )

Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Impressao do cabecalho do relatorio		³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Mr948Cabec( @nPagina , @Li , dDataEmi , "SFT" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Impressao do Quadro 1: APURACAO DAS RECEITAS POR VENDA e APURACAO DAS RECEITAS POR CONSUMO/INDUSTRIALIZACAO		³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Quad01Imp( @nPagina , @Li , , @aDadQ01 , @nQ4Fat , @nAliqQ1 , @nAliQSom , @nQ4Trf , aDadQ01Mat , @aQ4ConsInd )                         

If MV_PAR08 == 1//Entrada
	Quad02Imp (@nPagina,@Li,,@aDadQ02,@nQ4Tra,@nQ4Seg)
EndIf

// -----------------------------------------------------
// Valores de tributos dos documentos fiscais alimentam
// as variaveis de deducao da base de calculo para CFEM
// -----------------------------------------------------
For nTot := 1 To Len( aDadQ01 )
	nIcmsTot += aDadQ01[ nTot ][ 08 ]
	nIssTot  += aDadQ01[ nTot ][ 09 ]
	nPisTot  += aDadQ01[ nTot ][ 10 ]
	nCofTot  += aDadQ01[ nTot ][ 11 ]
Next nTot
// -----------------------------------------------------
// Consolida os valores preenchidos manualmente no
// Pergunte da rotina
// -----------------------------------------------------
If MV_PAR09 == 1
	nIcmsTot	+=	MV_PAR03
	nIssTot		+=	MV_PAR04
	nPisTot		+=	MV_PAR05
	nCofTot		+=	MV_PAR06
	nOutrTot	+=	MV_PAR07
// -----------------------------------------------------
// Considera apenas os valores preenchidos manualmente no
// Pergunte da rotina
// -----------------------------------------------------
Elseif MV_PAR09 == 3
	nIcmsTot	:=	MV_PAR03
	nIssTot		:=	MV_PAR04
	nPisTot		:=	MV_PAR05
	nCofTot		:=	MV_PAR06
	nOutrTot	:=	MV_PAR07
Endif

nValCFEMAP := ValCFEMAP(aDadQ01, aQ4ConsInd)
Quad03Imp ( @Li , nIcmsTot , nIssTot , nPisTot , nCofTot , nOutrTot , @nQ4Trib )             
Quad04Imp ( @Li , @nQ4Fat , @nQ4Tra , @nQ4Seg , @nQ4Trib , @nQ4Aliq , @nAliQSom , nQ4Trf , aQ4ConsInd,nValCFEMAP )

If !lQuery
	RetIndex("SFT")	
	dbClearFilter()	
	Ferase(cArqInd+OrdBagExt())
Else
	dbSelectArea(cAliasSFT)
	dbCloseArea()
Endif
		
Return(nPagina)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³RetLayOut | Autor ³ Rodrigo Zatt          ³ Data ³05/03/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o LayOut a ser impresso                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Array com o LayOut                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum             	                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RetLayOut()

Local aLay := Array(52)

	aLay[01] := STR0007 //"+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	aLay[02] := STR0008 //"|                                                               REGISTRO DE COMPENSAÇÃO FINANCEIRA PELA EXPLORAÇÃO DE RECURSOS MINERAIS (CFEM)                                                                  FOLHA #### |"
	aLay[03] := STR0009 //"|                                                                                                                                                                                  COMPETÊNCIA:   ############   ANO: #### |" 
	aLay[04] := STR0010 //"| ########################################    Endereço : #############################    CNPJ : #################    I.E. : ###############    Inscrição Municipal : ##################                                   |"  
	aLay[05] := STR0011 //"|                                                                                                                                                                                                                          |"
  	aLay[06] := STR0012 //"|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|"
	aLay[07] := STR0013 //"| APURAÇÃO DAS RECEITAS - VENDAS                                                                                                                                                                                           |"
	aLay[08] := STR0014 //"|  NUMERO   |     DATA    | DESCRIÇÃO OPERAÇÃO                   | DESCRIÇÃO DO PRODUTO                   | ALIQ.  | VALOR TOTAL        | VALOR ICMS         | VALOR ISS         | VALOR PIS          | VALOR COFINS       |" 
	aLay[09] := STR0015 //"+-----------+-------------+--------------------------------------+----------------------------------------+--------+--------------------+--------------------+-------------------+--------------------+--------------------+"
	aLay[10] := STR0016 //"| ######### |  #########  | ###################################  | ###################################### | ###### |  ################  |  ################  | ################  |  ################  |  ################  |"
	aLay[11] := STR0017 //"+-----------+-------------+--------------------------------------+----------------------------------------+--------+--------------------+--------------------+-------------------+--------------------+--------------------+"
	aLay[12] := STR0018 //"|                                                                                                  TOTAL           |  ################  |  ################  |  ################ |  ################  |  ################  |"
	aLay[13] := STR0019 //"+------------------------------------------------------------------------------------------------------------------+--------------------+--------------------+-------------------+--------------------+--------------------+"

	aLay[14] := STR0020 //"+-----------------------------------------------------------------------------------------------------+"
	aLay[15] := STR0021 //"|  DEDUÇÃO DE TRANSPORTES                                                                             |"
    aLay[16] := STR0022 //"|                                                                                                     |"
    aLay[17] := STR0023 //"|  NUMERO   | DATA EMISSÃO | DATA ENTRADA | DESCRIÇÃO DO PRODUTO                   | VALOR TOTAL      |"
	aLay[18] := STR0024 //"+-----------+--------------+--------------+----------------------------------------+------------------+"
   	aLay[19] := STR0025 //"| ######### |  #########   |  #########   | ###################################### | ################ |"
	aLay[20] := STR0026 //"+-----------+--------------+--------------+----------------------------------------+------------------|"   	
	aLay[21] := STR0027 //"|                                                                        TOTAL     + ################ |"
	aLay[22] := STR0028 //"+----------------------------------------------------------------------------------+------------------|" 
    aLay[23] := STR0029 //"|  DEDUÇÃO DE SEGURO                                                                                  |"
    
  	aLay[24] := STR0030 //"+---------------------------------------+"
	aLay[25] := STR0031 //"| VALOR DOS TRIBUTOS                    |"
	aLay[26] := STR0032 //"|                                       |"
	aLay[27] := STR0033 //"| Valor de ICMS   : ##################  |"
	aLay[28] := STR0034 //"| Valor de ISS    : ##################  |"
	aLay[29] := STR0035 //"| Valor de PIS    : ##################  |"
	aLay[30] := STR0036 //"| Valor de Cofins : ##################  |"
	aLay[31] := STR0037 //"| Outros valores  : ##################  |"
	aLay[32] := STR0038 //"+---------------------------------------+"

	aLay[33] := STR0039 //"+-----------------------------------------------------------------------------------------------------+"
	aLay[34] := STR0040 //"| VALORES APURADOS DA COMPENSAÇÃO FINANCEIRA PELA EXPLORAÇÃO DE RECURSOS MINERAIS (CFEM)              |"
	aLay[35] := STR0041 //"|                                                                                                     |"
	aLay[36] := STR0042 //"| Valor bruto total das receitas de vendas de minérios :          ####################                |"
	aLay[37] := STR0043 //"| Valor total de transportes a deduzir :                          ####################                |"
	aLay[38] := STR0044 //"| Valor total de seguros a deduzir :                              ####################                |"
	aLay[39] := STR0045 //"| Valor total dos tributos/outros a deduzir :                     ####################                |"
	aLay[40] := STR0046 //"| Valor da CFEM apurada :                                         ####################                |"                                                                                                                                                                                                                            
 	aLay[41] := STR0047 //"+-----------------------------------------------------------------------------------------------------+"
 	
 	aLay[42] := STR0057	//"|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|"
	aLay[43] := STR0058	//"| APURAÇÃO DOS CONSUMOS/INDUSTRIALIZAÇÃO                                                                                                                                                            |"
	aLay[44] := STR0059	//"|  DOCUMENTO    |     DATA    | DESCRIÇÃO OPERAÇÃO                | COD. PRODUTO                   | DESCRIÇÃO DO PRODUTO         |  ALIQ.  |    QUANTIDADE   |   CUSTO MÉDIO   |   VALOR LÍQUIDO   |" 
	aLay[45] := STR0060	//"+---------------+-------------+-----------------------------------+--------------------------------+------------------------------+---------+-----------------+-----------------+-------------------|"
	aLay[46] := STR0061	//"| ############# |  #########  | ################################  | ############################## | ############################ | ######  |  #############  |  #############  |  ###############  |"
	aLay[47] := STR0062	//"+---------------+-------------+-----------------------------------+--------------------------------+------------------------------+---------+-----------------+-----------------+-------------------|"
	aLay[48] := STR0063	//"|                                                                                                                                     TOTAL |  #############  |                 |  ###############  |"
	aLay[49] := STR0064	//"+-------------------------------------------------------------------------------------------------------------------------------------------+-----------------+-----------------+-------------------|"

	aLay[50] := STR0054 //"| Valor Total de consumo/industrialização :                        ####################               |"
	aLay[51] := STR0055 //"| Valor Total das operações de transferência :                     ####################               |"
	aLay[52] := STR0056 //"| Valor Líquido - Base de Apuração da CFEM :                       ####################               |"
            

Return(aLay)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Mr948Cabec³ Autor ³ Rodrigo Zatt          ³ Data ³05/03/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Imprime o cabecalho do relatorio                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nPag     = Numero da Pagina a ser Impressa                  ³±±
±±³          ³dDataImp = Mes que esta sendo impresso                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Mr948Cabec(nPag,Li,dDataImp,cAlias)

Local aLay 		:= {}
Local cIM		:= SM0->M0_INSCM
Local cMesIncid	:= MesExtenso(Month(dDataImp))
Local cAno		:= Ltrim(Str(Year(dDataImp)))

If MV_PAR08 == 1 //Entrada
	aLay := RetLayout()
Else
	aLay := LayOutExt()
EndIf

If Empty( Alias() )
	DbSelectArea( cAlias )
Endif

Li      := 0

	FmtLin({},aLay[01],,,@Li)
	FmtLin({},aLay[05],,,@Li)
	FmtLin({StrZero(nPag,4)},aLay[02],,,@Li)
	FmtLin({cMesIncid,cAno},aLay[03],,,@Li)
	FmtLin({AllTrim(SM0->M0_NOMECOM),Substr(SM0->M0_ENDENT,1,26),Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"),SM0->M0_INSC,Iif(!Empty(cIM),cIM," ")},aLay[04],,,@Li)
	FmtLin({},aLay[05],,,@Li)
	FmtLin({},aLay[06],,,@Li)

nPag += 1
	
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Quad01Imp ³ Autor ³ Rodrigo Zatt          ³ Data ³05/03/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Imprime o cabecalho do relatorio                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nPag     = Numero da Pagina a ser Impressa                  ³±±
±±³          ³Li       = Linha de mpresso			                      ³±±
±±³          ³dDataImp = Mes que esta sendo impresso                      ³±±
±±³          ³aDados   = Array com dados a ser impresso                   ³±±
±±³          ³nQ4TotalFat = Valor total das faturamento                   ³±±
±±³          ³nAliqu   = Aliquota do Produto                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Quad01Imp( nPag , Li , dDataImp , aDados , nQ4TotFat , nAliqu , nAliqSom , nQ4TotTrf , aDadosMat , aQ4ConsInd )

Local aLay		:=	{}
Local nX		:=	0
Local nTotal	:=	0
Local nTotIcms	:=	0
Local nTotIss	:=	0
Local nTotPis	:=	0
Local nTotCof	:=	0  
Local nTotFS	:=	0
Local nTotVLiq	:=	0
Local nTotQuant:=	0

Default nQ4Totfat	:= 0
Default nAliqu	 	:= 0
Default nPag     	:= 0  
Default nAliqSom	:= 0
Default aQ4ConsInd	:= { 0 , 0 } 

@ Li,000 PSAY AvalImp(Limite)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ 					IMPRESSAO DOS DOCUMENTOS FISCAIS					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If MV_PAR08 == 1 //Entrada
	aLay := RetLayout()
Else
	aLay := LayOutExt()
EndIf

FmtLin({},aLay[07],,,@Li)
FmtLin({},aLay[08],,,@Li)
FmtLin({},aLay[09],,,@Li)

For nX := 1 to len(aDados)
	If ( Li > 60 )
		FmtLin({},aLay[11],,,@Li)

		Li := 0
		@ Li,000 PSAY aValImp(Limite)

		FmtLin({},aLay[01],,,@Li)
		FmtLin({StrZero(nPag,4)},aLay[02],,,@Li)
		nPag += 1
		FmtLin({},aLay[01],,,@Li)

		FmtLin({},aLay[06],,,@Li)
		FmtLin({},aLay[07],,,@Li)
		FmtLin({},aLay[08],,,@Li)
		FmtLin({},aLay[09],,,@Li)
	Endif

	FmtLin({aDados[nX][01],;
			aDados[nX][02],;
			aDados[nX][04],;
			aDados[nX][05],;
			Transform(aDados[nX][14],"@E 999.99"),;
			Transform(aDados[nX][19],"@E 99,999,999.99"),;
			aDados[nX][07] + aDados[nX][18],;
			aDados[nX][08],;
			Transform(aDados[nX][9],"@E 99,999,999.99"),;
			aDados[nX][10],;
			aDados[nX][11],;
			Transform(aDados[nX][15] + aDados[nX][16],"@E 99,999,999.99"),;
			aDados[nX][17]},;
			aLay[10],,,@Li)	

	//Totalizador quadro 01	
	nAliqu		:= aDados[nX][14]
	nAliqSom	:= aDados[nX][06]
	nTotal		+= aDados[nX][07] + aDados[nX][18]
	nQ4Totfat	+= aDados[nX][07] + aDados[nX][18]
	nTotIcms	+= aDados[nX][08]
	nTotIss		+= aDados[nX][09]
	nTotPis		+= aDados[nX][10]
	nTotCof		+= aDados[nX][11]
	nTotFS		+= Iif( MV_PAR08 == 2 , aDados[nX][15] + aDados[nX][16] , 0 )
	nTotVLiq	+= aDados[nX][17]
	nQ4TotTrf	+= aDados[nX][18]
	nTotQuant += aDados[nX][19]
Next

FmtLin({},aLay[11],,,@Li)
// Imprime Totalizador quadro 01
If MV_PAR08 == 2
	FmtLin( { Transform(nTotQuant,"@E 99,999,999.99") , nTotal , nTotIcms , Transform(nTotIss,"@E 99,999,999.99") , nTotPis , nTotCof , Transform(nTotFS,"@E 99,999,999.99") , nTotVLiq } , aLay[12] , , , @Li )
Else
	FmtLin( { Transform(nTotQuant,"@E 99,999,999.99") , nTotal , nTotIcms , Transform(nTotIss,"@E 99,999,999.99") , nTotPis , nTotCof, nTotVLiq } , aLay[12] , , , @Li )
Endif

FmtLin( {} , aLay[13] , , , @Li )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                     IMPRESSAO DOS INDUSTRIALIZADOS                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If MV_PAR10 == 2 .And. Len( aDadosMat ) > 0
	
	nTotQuant := 0

	FmtLin( {} , Iif( MV_PAR08 == 2 , aLay[35] , aLay[42] ) , , , @Li )
	FmtLin( {} , Iif( MV_PAR08 == 2 , aLay[36] , aLay[43] ) , , , @Li )
	FmtLin( {} , Iif( MV_PAR08 == 2 , aLay[37] , aLay[44] ) , , , @Li )
	FmtLin( {} , Iif( MV_PAR08 == 2 , aLay[38] , aLay[45] ) , , , @Li )
	
	For nX := 1 to len(aDadosMat)
		If ( Li > 60 )
			FmtLin( {} , Iif( MV_PAR08 == 2 , aLay[40] , aLay[47] ) , , , @Li )

			Li := 0
			@ Li,000 PSAY aValImp(Limite)

			FmtLin({},aLay[01],,,@Li)
			FmtLin({StrZero(nPag,4)},aLay[02],,,@Li)
			nPag += 1
			FmtLin({},aLay[01],,,@Li)

			FmtLin({},Iif( MV_PAR08 == 2 , aLay[35] , aLay[42] ),,,@Li)
			FmtLin({},Iif( MV_PAR08 == 2 , aLay[36] , aLay[43] ),,,@Li)
			FmtLin({},Iif( MV_PAR08 == 2 , aLay[37] , aLay[44] ),,,@Li)
			FmtLin({},Iif( MV_PAR08 == 2 , aLay[38] , aLay[45] ),,,@Li)

		Endif

		FmtLin({aDadosMat[nX][01],;
		aDadosMat[nX][02],;
		aDadosMat[nX][03],;
		aDadosMat[nX][04],;
		TransForm(aDadosMat[nX][05],"@E 999.99"),;
		aDadosMat[nX][06],;
		aDadosMat[nX][07],;
		aDadosMat[nX][08]},;
		Iif( MV_PAR08 == 2 , aLay[39] , aLay[46] ),,,@Li)

		nTotQuant		+=	aDadosMat[ nX , 06 ]
		aQ4ConsInd[1]	+=	aDadosMat[ nX , 08 ]
		aQ4ConsInd[2]	+=	aDadosMat[ nX , 08 ] * aDadosMat[ nX , 05 ] / 100

	Next

	FmtLin({},Iif( MV_PAR08 == 2 , aLay[40] , aLay[47] ),,,@Li)
	
	//Totalizador
	FmtLin( { nTotQuant , aQ4ConsInd[1] } , Iif( MV_PAR08 == 2 , aLay[41] , aLay[48] ) , , , @Li )

	FmtLin( {} , Iif( MV_PAR08 == 2 , aLay[42] , aLay[49] ) , , , @Li )

Endif

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Quad02Imp ³ Autor ³ Rodrigo Zatt          ³ Data ³05/03/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Imprime o cabecalho do relatorio                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nPag    = Numero da Pagina a ser Impressa                   ³±±
±±³          ³Li      = Linha da impressao                                ³±±
±±³          ³dDataImp= aMes que esta sendo impresso                      ³±±
±±³          ³aDados  = Array com dados a ser impresso                    ³±±
±±³          ³nTotalT = Total de Transporte                               ³±±
±±³          ³nTotalS = Total de Seguros                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Quad02Imp (nPag,Li,dDataImp,aDados,nTotalT,nTotalS)

Local aLay 		 := RetLayOut()
Local nX		 := 0

Default nTotalT	 := 0
Default nTotalS  := 0
Default nPag 	 := 0

@ Li,000 PSAY AvalImp(Limite)
    
	FmtLin({},aLay[14],,,@Li)
   	FmtLin({},aLay[15],,,@Li)
   	FmtLin({},aLay[16],,,@Li)
 	FmtLin({},aLay[17],,,@Li)
   	FmtLin({},aLay[18],,,@Li)
	For nX := 1 to len(aDados)
	    If aDados[nX][07] == "3"
			If ( Li > 60 )
				FmtLin({},aLay[14],,,@Li)
				Li := 0
				@ Li,000 PSAY aValImp(Limite)

		 		FmtLin({},aLay[01],,,@Li)
		 		FmtLin({StrZero(nPag,4)},aLay[02],,,@Li)
		 		nPag += 1
		 		FmtLin({},aLay[01],,,@Li)              

	        	FmtLin({},aLay[14],,,@Li)
			   	FmtLin({},aLay[15],,,@Li)
			   	FmtLin({},aLay[16],,,@Li)
			 	FmtLin({},aLay[17],,,@Li)
			   	FmtLin({},aLay[18],,,@Li)
			   
				FmtLin({aDados[nX][01],aDados[nX][02],aDados[nX][03],aDados[nX][04],aDados[nX][05]},aLay[19],,,@Li)	
				nTotalT   += aDados[nX][05] 
			Else
				FmtLin({aDados[nX][01],aDados[nX][02],aDados[nX][03],aDados[nX][04],aDados[nX][05]},aLay[19],,,@Li)	
				nTotalT   += aDados[nX][05] 
			EndIf		    	    
	    EndIf
	next
   
   	FmtLin({},aLay[20],,,@Li)
	FmtLin({nTotalT},aLay[21],,,@Li)   // Imprime Totalizador quadro 02 Deducao de Transporte.
	FmtLin({},aLay[22],,,@Li)

	FmtLin({},aLay[14],,,@Li)
   	FmtLin({},aLay[23],,,@Li)
   	FmtLin({},aLay[16],,,@Li)
 	FmtLin({},aLay[17],,,@Li)
   	FmtLin({},aLay[18],,,@Li)
	For nX := 1 to len(aDados)
	    If aDados[nX][07] == "2"
	    	If ( Li > 60 )
				FmtLin({},aLay[14],,,@Li)
				Li := 0
				@ Li,000 PSAY aValImp(Limite)
		       
				FmtLin({},aLay[01],,,@Li)
	   			FmtLin({StrZero(nPag,4)},aLay[02],,,@Li)
	   			FmtLin({},aLay[01],,,@Li)
	        	
	        	FmtLin({},aLay[14],,,@Li)
			   	FmtLin({},aLay[15],,,@Li)
			   	FmtLin({},aLay[16],,,@Li)
			 	FmtLin({},aLay[17],,,@Li)
			   	FmtLin({},aLay[18],,,@Li)

	    		FmtLin({aDados[nX][01],aDados[nX][02],aDados[nX][03],aDados[nX][04],aDados[nX][05]},aLay[19],,,@Li)	
				nTotalS   += aDados[nX][05]
	        Else
	    		FmtLin({aDados[nX][01],aDados[nX][02],aDados[nX][03],aDados[nX][04],aDados[nX][05]},aLay[19],,,@Li)	
				nTotalS   += aDados[nX][05]
			EndIf	    
	    EndIf
	next
   	FmtLin({},aLay[20],,,@Li)
	FmtLin({nTotalS},aLay[21],,,@Li)   // Imprime Totalizador quadro 02 Deducao de seguros.
	FmtLin({},aLay[22],,,@Li)	
	
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Quad03Imp ºAutor  ³Rodrigo Zatt        º Data ³ 05/03/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Imprime Quadro 03                                           º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºRetorno   ³Nenhum                                                      º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºParametros³Li       = Numero da linha que sera impresso                º±±
±±º          ³nIcms    = Valor Total referente a Icms                     º±±
±±º          ³nIss     = Valor Total referente a ISS                      º±±
±±º          ³nPis     = Valor Total referente a Pis                      º±±
±±º          ³nCofins  = Valor Total referente a Confins                  º±±
±±º          ³nOutr    = Valor Total referente a Outros tributos          º±±
±±º          ³nTotTrib = Valor total dos tributos                         º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Quad03Imp (Li,nIcms,nIss,nPis,nCofins,nOutr,nTotTrib)

Local aLay  		:= {}

Default nIcms 		:= 0
Default nIss 		:= 0
Default nPis 		:= 0
Default nCofins		:= 0
Default nOutr 		:= 0 
Default nTotTrib 	:= 0                                  
                       
If Li > 51
	Li := 0
EndIf	

@ Li,000 PSAY AvalImp(Limite)

If MV_PAR08 == 1 //Entrada
	aLay := RetLayout()
	FmtLin({},aLay[24],,,@Li)
	FmtLin({},aLay[25],,,@Li)
	FmtLin({},aLay[26],,,@Li)
	FmtLin({TransForm(nIcms,"@E 999,999,999,999.99")},aLay[27],,,@Li)
	FmtLin({TransForm(nIss,"@E 999,999,999,999.99")},aLay[28],,,@Li)
	FmtLin({TransForm(nPis,"@E 999,999,999,999.99")},aLay[29],,,@Li)
	FmtLin({TransForm(nCofins,"@E 999,999,999,999.99")},aLay[30],,,@Li)
	FmtLin({TransForm(nOutr,"@E 999,999,999,999.99")},aLay[31],,,@Li)
	FmtLin({},aLay[32],,,@Li)
Else
	aLay := LayOutExt()
	FmtLin({},aLay[14],,,@Li)
	FmtLin({},aLay[15],,,@Li)
	FmtLin({},aLay[16],,,@Li)
	FmtLin({TransForm(nIcms,"@E 999,999,999,999.99")},aLay[17],,,@Li)
	FmtLin({TransForm(nIss,"@E 999,999,999,999.99")},aLay[18],,,@Li)
	FmtLin({TransForm(nPis,"@E 999,999,999,999.99")},aLay[19],,,@Li)
	FmtLin({TransForm(nCofins,"@E 999,999,999,999.99")},aLay[20],,,@Li)
	FmtLin({TransForm(nOutr,"@E 999,999,999,999.99")},aLay[21],,,@Li)
	FmtLin({},aLay[22],,,@Li)
EndIf

nTotTrib := (nIcms+nIss+nPis+nCofins+nOutr)	

Return .T. 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Quad04Imp ºAutor  ³Rodrigo Zatt        º Data ³ 05/03/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Imprime Quadro 04                                           º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºRetorno   ³Nenhum                                                      º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºParametros³Li        = Numero da linha que sera impressa               º±±
±±º          ³nTotal    = Valor total do documento fiscal                 º±±
±±º          ³nTotIcms  = Valor Total referente a ICMS                    º±±
±±º          ³nTotIss   = Valor Total referente a ISS                     º±±
±±º          ³nTotPis   = Valor Total referente a PIS                     º±±
±±º          ³nTotCof   = Valor Total referente a Cofins                  º±±
±±º          ³nAliq     = Aliquota do Produto							  º±±
±±º			 ³nAliqSom  = Soma das Aliquotas para apurar o CFEM           º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/						  
Static Function Quad04Imp( Li , nVfatura , nVdedT , nVdedS , nVdedTrib , nAliq , nAliqSom , nValTrf , aQ4ConsInd,nValCFEMAP  )

Local aLay 		:= {}
Local nVBaseLiq		:= ( nVFatura - ( nVdedT + nVdedS + nVdedTrib ) ) + aQ4ConsInd[1]

Default nVfatura	:= 0
Default nVdedT		:= 0
Default nVdedS		:= 0
Default nVdedTrib	:= 0
Default nAliq		:= 0 
Default nAliqSom	:= 0
Default nValTrf		:= 0
Default aQ4ConsInd	:= 0                                
Default nValCFEMAP	:= 0

If Li > 51
	Li := 0
EndIf	

@ Li,000 PSAY AvalImp(Limite)

If MV_PAR08 == 1 //Entrada
	aLay := RetLayout()   
	
	FmtLin({},aLay[33],,,@Li)
	FmtLin({},aLay[34],,,@Li)
	FmtLin({},aLay[35],,,@Li)

	FmtLin({TransForm(nVfatura-nValTrf,"@E 9,999,999,999,999.99")},aLay[36],,,@Li)
	FmtLin({TransForm(nVdedT,"@E 9,999,999,999,999.99")},aLay[37],,,@Li)
	FmtLin({TransForm(nVdedS,"@E 9,999,999,999,999.99")},aLay[38],,,@Li)
	FmtLin({TransForm(nVdedTrib,"@E 9,999,999,999,999.99")},aLay[39],,,@Li)
	
	FmtLin({TransForm(aQ4ConsInd[1],"@E 9,999,999,999,999.99")},aLay[50],,,@Li)
	FmtLin({TransForm(nValTrf,"@E 9,999,999,999,999.99")},aLay[51],,,@Li)
	FmtLin({TransForm(nVBaseLiq,"@E 9,999,999,999,999.99")},aLay[52],,,@Li)
	
	//FmtLin({TransForm(((nVfatura-(nVdedT+nVdedS+nVdedTrib))*(nAliqSom/100)) + aQ4ConsInd[2] ,"@E 9,999,999,999,999.99")},aLay[40],,,@Li)
	FmtLin({TransForm(nValCFEMAP ,"@E 9,999,999,999,999.99")},aLay[40],,,@Li)
	FmtLin({},aLay[41],,,@Li) 
Else
	aLay := LayOutExt()
	
	FmtLin({},aLay[23],,,@Li)
	FmtLin({},aLay[24],,,@Li)
	FmtLin({},aLay[25],,,@Li)
	
	FmtLin({TransForm(nVfatura-nValTrf,"@E 9,999,999,999,999.99")},aLay[26],,,@Li)
	FmtLin({TransForm(nVdedT,"@E 9,999,999,999,999.99")},aLay[27],,,@Li)
	FmtLin({TransForm(nVdedS,"@E 9,999,999,999,999.99")},aLay[28],,,@Li)
	FmtLin({TransForm(nVdedTrib,"@E 9,999,999,999,999.99")},aLay[29],,,@Li)
	
	FmtLin({TransForm(aQ4ConsInd[1],"@E 9,999,999,999,999.99")},aLay[30],,,@Li)
	FmtLin({TransForm(nValTrf,"@E 9,999,999,999,999.99")},aLay[31],,,@Li)
	FmtLin({TransForm(nVBaseLiq,"@E 9,999,999,999,999.99")},aLay[32],,,@Li)
	
	//FmtLin({TransForm(((nVfatura-(nVdedT+nVdedS+nVdedTrib))*(nAliqSom/100)) + aQ4ConsInd[2] ,"@E 9,999,999,999,999.99")},aLay[33],,,@Li)
	FmtLin({TransForm(nValCFEMAP ,"@E 9,999,999,999,999.99")},aLay[33],,,@Li)
	
	FmtLin({},aLay[34],,,@Li) 
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MTRCFEMStrºAutor  ³Rodrigo Zatt        º Data ³  05/03/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Montar um array apenas com os campos utiLizados na query    º±±
±±º          ³para passagem na funcao TCSETFIELD                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Array com os campos da query                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³aCampos: campos a serem tratados na query                   º±±
±±º          ³cCmpQry: string contendo os campos para select na query     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³FISR013                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
#IFDEF TOP
Static Function MTRCFEMStr(aCampos,cCmpQry)

Local	aRet	:=	{}
Local	nX		:=	0
Local	aTamSxT	:=	{}

For nX := 1 To Len(aCampos)
	If(FieldPos(aCampos[nX])>0)
		aTamSxT := TamSX3(aCampos[nX])
		aAdd (aRet,{aCampos[nX],aTamSxT[3],aTamSxT[1],aTamSxT[2]})
		cCmpQry	+=	aCampos[nX]+", "
	EndIf
Next(nX)

If(Len(cCmpQry)>0)
	cCmpQry	:=	" " + SubStr(cCmpQry,1,Len(cCmpQry)-2) + " "
EndIf 
	
Return(aRet)
#ENDIF
  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CalcCfem ³ Autor ³Jorge Souza	        ³ Data ³06/09/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calcular o CFEM do componente do produto na estrutura       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±± Parametros³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function CalcCfem(aRegra,nPos,cCodPai)

Local aEstru 	:= {}  
Local cCodFilho := ""
Local aAreaSB1 	:= SB1-> (GetArea())
Local i 		:= 0            
Local nSoma		:= 0
Private nEstru 	:= 0
                                      		
aEstru := Estrut(cCodPai,1)

For i:=1 to Len(aEstru)
	cCodFilho := aEstru[i,3] 
	If Alltrim(cCodFilho)<> Alltrim(cCodPai)	
		If SB1->(MsSeek(xFilial("SB1")+cCodFilho)) .And. SB1->B1_CFEMA > 0	
			nSoma += SB1->B1_CFEMA	
		Endif
	Endif
Next	 

If nSoma > 0
	aRegra[nPos,2]:= nSoma
Endif

RestArea(aAreaSB1)
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} LayoutExt

Layout para quando o MV_PAR08 = 2-Saída ou seja, layout sem a exibicao de 
transportes e seguro e adicionando uma coluna de frete/seguro.

@sample			LayoutExt()

@param			Nil

@return		    aLayExt

@author		Thamara Villa Jacomo
@since			19/12/2013
@version		P11.8
/*/                                                              
//------------------------------------------------------------------------------

Static Function LayoutExt()

Local aLayExt := Array( 42 )

	aLayExt[01] := STR0007 //"+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	aLayExt[02] := STR0008 //"|                                                               REGISTRO DE COMPENSAÇÃO FINANCEIRA PELA EXPLORAÇÃO DE RECURSOS MINERAIS (CFEM)                                                                  FOLHA #### |"
	aLayExt[03] := STR0009 //"|                                                                                                                                                                                  COMPETÊNCIA:   ############   ANO: #### |" 
	aLayExt[04] := STR0010 //"| ########################################    Endereço : #############################    CNPJ : #################    I.E. : ###############    Inscrição Municipal : ##################                                   |"  
	aLayExt[05] := STR0011 //"|                                                                                                                                                                                                                          |"
  	aLayExt[06] := STR0012 //"|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|"
	aLayExt[07] := STR0013 //"| APURAÇÃO DAS RECEITAS - VENDAS                                                                                                                                                                                           |"
	aLayExt[08] := STR0048 //"|  NUMERO   |     DATA    | DESCRIÇÃO OPERAÇÃO                | DESCRIÇÃO DO PRODUTO         | ALIQ.  | VALOR TOTAL        | VALOR ICMS         | VALOR ISS      | VALOR PIS         | VALOR COFINS      | FRETE/SEGURO	 |" 
	aLayExt[09] := STR0049 //"+-----------+-------------+-----------------------------------+------------------------------+--------+--------------------+--------------------+----------------+-------------------+-------------------+-----------------|"
	aLayExt[10] := STR0050 //"| ######### |  #########  | ################################  | ############################ | ###### |  ###############  |  ################  | ############### |  ###############  |  ###############  | ############### |"
	aLayExt[11] := STR0051 //"+-----------+-------------+-----------------------------------+------------------------------+--------+-------------------+--------------------+-----------------+-------------------+-------------------+-----------------|"
	aLayExt[12] := STR0052 //"|                                                                                               TOTAL |  ###############  |  ################  | ############### |  ###############  |  ###############  | ############### |"
	aLayExt[13] := STR0053 //"+-----------------------------------------------------------------------------------------------------+-------------------+--------------------+-----------------+-------------------+-------------------+-----------------+"	
	
  	aLayExt[14] := STR0030 //"+---------------------------------------+"
	aLayExt[15] := STR0031 //"| VALOR DOS TRIBUTOS                    |"
	aLayExt[16] := STR0032 //"|                                       |"
	aLayExt[17] := STR0033 //"| Valor de ICMS   : ##################  |"
	aLayExt[18] := STR0034 //"| Valor de ISS    : ##################  |"
	aLayExt[19] := STR0035 //"| Valor de PIS    : ##################  |"
	aLayExt[20] := STR0036 //"| Valor de Cofins : ##################  |"
	aLayExt[21] := STR0037 //"| Outros valores  : ##################  |"
	aLayExt[22] := STR0038 //"+---------------------------------------+"

	aLayExt[23] := STR0039 //"+-----------------------------------------------------------------------------------------------------+"
	aLayExt[24] := STR0040 //"| VALORES APURADOS DA COMPENSAÇÃO FINANCEIRA PELA EXPLORAÇÃO DE RECURSOS MINERAIS (CFEM)              |"
	aLayExt[25] := STR0041 //"|                                                                                                     |"
	aLayExt[26] := STR0042 //"| Valor bruto total das receitas de vendas de minérios :          ####################                |"
	aLayExt[27] := STR0043 //"| Valor total de transportes a deduzir :                          ####################                |"
	aLayExt[28] := STR0044 //"| Valor total de seguros a deduzir :                              ####################                |"
	aLayExt[29] := STR0045 //"| Valor total dos tributos/outros a deduzir :                     ####################                |"
	aLayExt[30] := STR0054 //"| Valor Total de consumo/industrialização :                        ####################               |"
	aLayExt[31] := STR0055 //"| Valor Total das operações de transferência :                     ####################               |"
	aLayExt[32] := STR0056 //"| Valor Líquido - Base de Apuração da CFEM :                       ####################               |"
	aLayExt[33] := STR0046 //"| Valor da CFEM apurada :                                         ####################                |"                                                                                                                                                                                                                            
 	aLayExt[34] := STR0047 //"+-----------------------------------------------------------------------------------------------------+"
 	
 	aLayExt[35] := STR0057	//"|------------------------------------------------------------------------------------------------------------------------------------------------------------------|"
	aLayExt[36] := STR0058	//"| APURAÇÃO DOS CONSUMOS/INDUSTRIALIZAÇÃO                                                                                                                           |"
	aLayExt[37] := STR0059	//"|  DOCUMENTO    |     DATA    | DESCRIÇÃO OPERAÇÃO                | DESCRIÇÃO DO PRODUTO         |  ALIQ.  |    QUANTIDADE   |   CUSTO MÉDIO   |   VALOR LÍQUIDO   |" 
	aLayExt[38] := STR0060	//"+---------------+-------------+-----------------------------------+------------------------------+---------+-----------------+-----------------+-------------------|"
	aLayExt[39] := STR0061	//"| ############# |  #########  | ################################  | ############################ | ######  |  #############  |  #############  |  ###############  |"
	aLayExt[40] := STR0062	//"+---------------+-------------+-----------------------------------+------------------------------+---------+-----------------+-----------------+-------------------|"
	aLayExt[41] := STR0063	//"|                                                                                                    TOTAL |  #############  |                 |  ###############  |"
	aLayExt[42] := STR0064	//"+----------------------------------------------------------------------------------------------------------+-----------------+-----------------+-------------------|"

Return( aLayExt )

//-------------------------------------------------------------------
/*/{Protheus.doc} CFEMProd

Processa os produtos e OP's que serão considerados para a apuração
do CFEM do periodo selecionado.
	
@author Robson Sales de A. Ribeiro
@since 06/02/2014
@version 1.0
		
@param dInicio, data, (Data Inicial do Periodo)
@param dFinal , data, (Data Final do Periodo)

@return cAliasTb -> Alias com os registros selecionados do periodo
/*/
//-------------------------------------------------------------------
Function CFEMProd(dInicio,dFim)

Local cQuery		:= ""
Local cArqTRB		:= ""
Local cQryQt		:= ""
Local cQryTl		:= ""
Local aTam			:= {}
Local aCampos		:= {}
Local cAliasQy	:= GetNextAlias()
Local cAliasTb	:= GetNextAlias()
Local aAreaSB1	:= SB1->(GetArea())
Local aAreaSC2	:= SC2->(GetArea())

cQuery := "SELECT D3_COD AS PRODUTO, MIN(D3_EMISSAO) AS EMISSAO, D3_OP AS OP, "
cQryQt += "SUM(CASE WHEN D3_CF LIKE ('DE%') THEN (D3_QUANT*-1) WHEN D3_CF LIKE ('RE%') THEN (D3_QUANT) ELSE 0 END)"
cQryTl += "SUM(CASE WHEN D3_CF LIKE ('DE%') THEN (D3_CUSTO1*-1) WHEN D3_CF LIKE ('RE%') THEN (D3_CUSTO1) ELSE 0 END)"
cQuery += cQryQt+" AS QUANT, "+cQryTl+" AS TOTAL, "
cQuery += "("+cQryTl+"/"+cQryQt+")  AS VUNIT, B1_DESC,B1_CFEMA "
cQuery += "FROM "+RetSqlName("SD3")+" SD3 , "+RetSqlName("SB1")+" SB1 WHERE "
cQuery += "D3_FILIAL = '"+xFilial('SD3')+"' AND B1_FILIAL = '"+xFilial('SB1')+"' AND "
cQuery += "D3_COD = B1_COD AND D3_EMISSAO >= '"+DTOS(dInicio)+"' AND "
cQuery += "D3_EMISSAO <= '"+DTOS(dFim)+"' AND D3_OP <> ' ' AND "
cQuery += "D3_ESTORNO = ' ' AND B1_CFEM = '1' AND "
cQuery += "SUBSTRING (D3_CF,2,2) IN ('E0','E1') AND "
cQuery += "SB1.D_E_L_E_T_ = ' ' AND SD3.D_E_L_E_T_ = ' ' "
cQuery += "GROUP BY D3_OP, D3_COD,B1_DESC,B1_CFEMA ORDER BY  1,3"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQy,.F.,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o arquivo de Trabalho ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTam:= TamSX3("D3_COD")
Aadd(aCampos,{"PRODUTO","C",aTam[1],aTam[2]})

aTam:= TamSX3("D3_EMISSAO")
Aadd(aCampos,{"EMISSAO","D",aTam[1],aTam[2]})

aTam:= TamSX3("D3_OP")
Aadd(aCampos,{"OP","C",aTam[1],aTam[2]})

aTam:= TamSX3("D3_QUANT")
Aadd(aCampos,{"QUANT","N",aTam[1],aTam[2]})

aTam:= TamSX3("B2_CM1")
Aadd(aCampos,{"VUNIT","N",aTam[1],aTam[2]})

aTam:= TamSX3("D3_CUSTO1")
Aadd(aCampos,{"TOTAL","N",aTam[1],aTam[2]})

aTam:= TamSX3("B1_DESC")
Aadd(aCampos,{"DESCRICAO","C",aTam[1],aTam[2]})

aTam:= TamSX3("B1_CFEMA")
Aadd(aCampos,{"ALIQUOTA","N",aTam[1],aTam[2]})

cArqTRB := CriaTrab(aCampos,.T.)
DbUseArea(.T.,,cArqTRB,cAliasTb,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o Produto PAI da OP calcula CFEM, se calcular ³
//³ retira o registro da OP do arquivo temporario             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While !(cAliasQy)->(Eof())
	dbSelectArea("SC2")
	SC2->(dbsetorder(1))
	If SC2->(MsSeek(xFilial('SC2')+(cAliasQy)->OP))
		dbSelectArea("SB1")
		SB1->(dbsetorder(1))
		If SB1->(MsSeek(xFilial('SB1')+SC2->C2_PRODUTO))
			If SB1->B1_CFEM = '1'
				(cAliasQy)->(DbSkip())
				loop
			EndIf
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava o registro no arquivo de trabalho caso ³
	//³ o PAI da OP nao calcule CFEM                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RecLock(cAliasTb,.T.)
	(cAliasTb)->PRODUTO		:= (cAliasQy)->PRODUTO
	(cAliasTb)->EMISSAO		:= STOD((cAliasQy)->EMISSAO)
	(cAliasTb)->OP			:= (cAliasQy)->OP
	(cAliasTb)->QUANT		:= (cAliasQy)->QUANT
	(cAliasTb)->VUNIT		:= (cAliasQy)->VUNIT
	(cAliasTb)->TOTAL		:= (cAliasQy)->TOTAL
	(cAliasTb)->DESCRICAO	:= (cAliasQy)->B1_DESC
	(cAliasTb)->ALIQUOTA	:= (cAliasQy)->B1_CFEMA
	(cAliasTb)->(MsUnLock())
	(cAliasQy)->(DbSkip())
EndDo
		 	
(cAliasTb)->(dbgotop())
(cAliasQy)->(dbclosearea())
RestArea(aAreaSB1)
RestArea(aAreaSC2)

Return cAliasTb

//-------------------------------------------------------------------
/*/{Protheus.doc} CFEMTransf

Consulta o ultimo Custo Medio do produto de acordo com o periodo
processado.
	
@author Luccas Curcio
@since 17/02/2014
@version 1.0
		
@param	cProduto	->	Codigo do Produto
		cLocal		->	Armazem do Produto
		dDataIni	->	Data Inicial do Processamento
		dDataFim	->	Data Final do Processamento
		nQuant		->	Quantidade 

@return nValor * nQuant	->	Valor do Custo Medio multiplicado pela quantidade
/*/
//-------------------------------------------------------------------
Static Function CFEMTransf( cProduto , cLocal , dDataIni , dDataFim , nQuant )

Local	nValor		:=	0
Local	cQuery		:=	""
Local	cAliasSB9	:=	GetNextAlias()

cQuery	:=	"SELECT SB9.B9_CM1 "
cQuery	+=	"FROM " + RetSqlName( "SB9" ) + " SB9 "
cQuery	+=	"WHERE SB9.B9_FILIAL = '" + xFilial( "SB9" ) + "' AND SB9.B9_COD = '" + cProduto + "' AND "
cQuery	+=	"SB9.B9_DATA = ( SELECT MAX(SB91.B9_DATA) "
cQuery	+=	"FROM " + RetSqlName( "SB9" ) + " SB91 "
cQuery	+=	"WHERE SB91.B9_FILIAL = '" + xFilial( "SB9" ) + "' AND SB91.B9_COD = '" + cProduto + "' AND "
cQuery	+=	"SB91.B9_DATA >= '" + DToS( dDataIni ) + "' AND SB91.B9_DATA <= '" + DToS( dDataFim ) + "' AND "
cQuery	+=	"SB91.D_E_L_E_T_ = '' ) AND "
cQuery	+=	"SB9.D_E_L_E_T_ = '' "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSB9,.F.,.F.)

If !( cAliasSB9 )->( Eof( ) )
	nValor	:=	( cAliasSB9 )->B9_CM1
Endif

( cAliasSB9 )->( dbCloseArea( ) )

Return Round( nValor * nQuant , 2 )

//-------------------------------------------------------------------
/*/{Protheus.doc} ValCFEMAP

Calcula o Valor da CEFEM com base nas alíquota de cada produto.
Aglutino os valores com a mesma alíquota e aplico a porcentagem.

@author Rene Julian
@since 27/11/2015
@version 1.0

@param	aDadQ01	->	Dados extraidos da SFT


@return nValor Valor apurado da CFEM
/*/
//-------------------------------------------------------------------
Static Function ValCFEMAP( aDadQ01 , aQ4ConsInd )
Local nRet := 0
Local nX   := 0
Local aInfCFEM := {}
Local nPosAlq  := 0

If Len(aDadQ01) > 0
	For nX := 1 To Len(aDadQ01)
		If aDadQ01[nX][14] > 0 .And. aDadQ01[nX][17] > 0
			nPosAlq := aScan( aInfCFEM , { |x| x[ 1 ] == aDadQ01[nX][14] } )
			If nPosAlq > 0
				aInfCFEM[nPosAlq][2] += aDadQ01[nX][17]
			Else
				AAdd(aInfCFEM,{aDadQ01[nX][14],aDadQ01[nX][17]})
			EndIf
		EndIf
	Next nX
	If Len(aInfCFEM) > 0
		For nX := 1 To Len(aInfCFEM)
			nRet += (aInfCFEM[nX][2] + aQ4ConsInd[1]) * (aInfCFEM[nX][1] / 100)
		Next nX
	EndIf
EndIf

Return (Round(nRet,2))
