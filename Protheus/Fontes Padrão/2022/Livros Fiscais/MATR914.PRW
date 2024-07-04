#INCLUDE "Matr914.ch"
#INCLUDE "FIVEWIN.CH"
#INCLUDE "rwmake.CH"
  
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MATR914   ³ Autor ³ Thiago Galvao Silveira   ³ Data ³ 25.07.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Registro de Apuracao do ISS 									 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³MATR914                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Danilo Calil ³12/09/07³131472³ Executa as funcoes genericas do fonte     ³±±
±±³              ³        ³      ³ MATXRMP para apresentacao das informaco   ³±±
±±³              ³        ³      ³ do Mapa Resumo, quando a pergunta "Impr   ³±±
±±³              ³        ³      ³ me Mapa Resumo" igual a "Sim" e o para-   ³±±
±±³              ³        ³      ³ metro MV_LJLVFIS = 2.                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function Matr914

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento para Gestão Corporativa                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
Local nPosFil		:= 0
Local nForFilial	:= 0
Private lAglFil		:= .F.
Private lSelFil		:= .F.   
Private aFilsCalc	:= {}
Private aFilAtiv	:= {}
Private cFilSF2		:= ''
Private cFilSF3		:= ''
Private cFilBack	:= cFilAnt

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Demais Variaveis                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
aArea	:= GetArea()
titulo	:=	STR0001 //"Registro de Apuracao do ISS"
cDesc1	:=	STR0002 //"Este relatório ira imprimir os Registro de Apuraçãao referentes a Imposto Sobre "
cDesc2	:=	STR0003 //"Servicos de Qualquer Natureza, conforme o periodo informado."
cDesc3	:=	""
aReturn  :=	{ STR0004, 1,STR0005, 2, 2, 1, "",1 } //"Zebrado"###"Administracao"
nomeprog :=	"MATR914"
cPerg    :=	"MTR914"
nLastKey :=	0
Limite   := 132
Tamanho  :=	"M"      

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cString  :=	"SF3"
Titulo   :=	STR0006 //"REGISTRO DE APURAÇÃO DO ISS - IMPOSTO SOBRE SERVICOS DE QUALQUER NATUREZA"
cabec1   :=	""
cabec2   :=	""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01             // Ano                                  ³
//³ mv_par02             // Mes                                  ³
//³ mv_par03             // Livro Selecionado                    ³
//³ mv_par04             // Apuracao                             ³
//³ mv_par05             // Quebra por CFOP ou Aliquota          ³
//³ mv_par06             // Num Guia Rec Imp Propr.              ³
//³ mv_par07             // Data da Guia Rec                     ³
//³ mv_par08             // Banco                                ³
//³ mv_par09             // Num Guia Rec Imp Ret                 ³
//³ mv_par10             // Quebra por CFOP ou Aliquota          ³
//³ mv_par11             // Banco                                ³
//³ ...                                                          ³
//³ mv_par23             // Seleciona Filial? S/N                ³
//³ mv_par24             // Aglutina por CNPJ? S/N               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//Verifica o Modo de Impressao
// 1 - Retrato
// 2 - Paisagem
If mv_par18 == 1
	Tamanho:= "M" ; Limite:= 132
Else
	Tamanho:= "G" ; Limite:= 220
Endif

wnrel	:=	"MATR914"   // nome default do relatorio em disco
wnrel	:=	SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,Tamanho)

nPagina	:=	0

If nLastKey == 27
	dbClearFilter()
	cFilAnt	:= cFilBack
	Return
Endif
SetDefault(aReturn,cString)
If nLastKey == 27
	dbClearFilter()
	cFilAnt	:= cFilBack
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressao de Termo / Livro                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	Case mv_par14==1 ; lImpLivro:=.T. ; lImpTermos:=.F.
	Case mv_par14==2 ; lImpLivro:=.T. ; lImpTermos:=.T.
	Case mv_par14==3 ; lImpLivro:=.F. ; lImpTermos:=.T.
EndCase     
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recebe filtro definido pelo usuario                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPagina	:=	MV_PAR12
cFilterUser	:=	aReturn[7]

// Variáveis para gestão corporativa 
lSelFil		:= ( mv_par23 == 1 ) 
lAglFil		:= ( mv_par24 == 1 )  
aFilsCalc	:= MatFilCalc( lSelFil, , , (lSelFil .and. lAglFil), , 4 )

If Empty(aFilsCalc)
	cFilAnt	:= cFilBack
	Return
EndIf

// Se Seleciona Filiais, guarda as filiais dos arquivos para uso posterior
If lSelFil
	For nForFilial := 1 to Len( aFilsCalc )
		If aFilsCalc[ nForFilial, 1 ]
			cFilAnt := aFilsCalc[ nForFilial, 2 ]
			aAdd( aFilAtiv, { cFilAnt, xFilial('SF3'), xFilial('SF2'), xFilial('SA1'), xFilial('SA2') } )
		EndIf
	Next

	// Se aglutina filiais, monta a string conforme as filiais de cada tabela envolvida
		cFilAnt	:= aFilAtiv[1,1]
		For nPosFil := 1 to Len(aFilAtiv)
			cFilSF2	+= IIf(nPosFil==1,"('","'")+aFilAtiv[nPosFil,3]+IIf(nPosFil==Len(aFilAtiv),"')","',")	
			cFilSF3	+= IIf(nPosFil==1,"('","'")+aFilAtiv[nPosFil,2]+IIf(nPosFil==Len(aFilAtiv),"')","',")
		Next

// Se não seleciona Filiais, não irá aglutinar CNPJ
Else
	aAdd( aFilAtiv, { cFilAnt, xFilial('SF3'), xFilial('SF2'), xFilial('SA1'), xFilial('SA2') } )
	cFilSF1	:= "('"+aFilAtiv[1,3]+"')"
	cFilSF3	:= "('"+aFilAtiv[1,2]+"')" 
EndIf

//Verifica o Modo de Impressao apos Filtro do Usuario
// 1 - Retrato
// 2 - Paisagem
If mv_par18 == 1
	Tamanho:= "M" ; Limite:= 132
Else
	Tamanho:= "G" ; Limite:= 220
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa relatorio                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lImpLivro
   RptStatus({|lEnd| ImpRel(@lEnd,wnRel,cString,Tamanho, nPagina)},titulo)
ElseIf lImpTermos .and. !lImpLivro	// Impressao somente dos Termos
	If !lAglFil
		SM0->(dbSetOrder(1))
		For nForFilial := 1 to Len(aFilAtiv)
			cFilAnt	:= aFilAtiv[nForFilial,1]
			SM0->(dbSeek(cEmpAnt+cFilAnt))
			R914ImpTerm(cPerg)
		Next	
	Else
		R914ImpTerm(cPerg)
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura Ambiente                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aReturn[5] == 1
	Set Printer TO
	dbCommitAll()
	Ourspool(wnrel)
Endif

cFilAnt	:= cFilBack
RestArea(aArea)
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ImpRel()    ³ Autor ³ Thiago Galvao      ³ Data ³25/07/03  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao do Registro de Apuracao de ISS                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR914()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ImpRel(lEnd,wnRel,cString,Tamanho, nPagina)       

Local aLay      	:= Array(35)
Local aMapaResumo	:= {}
Local aGravaMapRes	:= {}
Local aCposTemp		:= {}
Local aImprime  	:= {{"","",0,"","",0,0,"","",0,0,"","",0,0,0,0,0}}          
Local aRetem    	:= {}   
Local aCupom		:= {}   
Local aPonto		:= {}

Local cAliasSF3 	:= "SF3"
Local cAliasR01 	:= "R01"
Local cAlias    	:= ""
Local cMes      	:= ""                                                    
Local cImp      	:= "IS"                                                  
Local cNrLivro  	:= mv_par03
Local cBancoPr  	:= mv_par08
Local cBancoRet		:= mv_par11
Local cArqApur		:= ""
Local cDia			:= ""
Local cIssApur  	:= ""
Local cObslin1  	:= ""
Local cObslin2  	:= ""
Local cObslin3  	:= ""
Local cObslin4  	:= ""
Local cDiaApur  	:= ""
Local cEntSai		:= ""
Local cRecISS		:= ""
Local cArqBkpQry	:= 	""
Local cArqTmpMP		:= 	""
Local cMsgCan       := ""    
Local cSerPar		:= GetNewPar("MV_MT914SR","")
Local cNFIni		:= ""
Local cNFFim		:= ""
Local cChav 		:= ""
Local cNFCupom 		:= ""
Local cSerCupom		:= ""

Local dDataPr   	:= mv_par07
Local dDataRet  	:= mv_par10

Local lQuery    	:= .F.
Local lQuebra		:= If(mv_par05 == 1,.T.,.F.)
Local lCond	    	:= .F.
Local lRodape		:= .F.
Local lDecendial	:= .F. 
Local lQuinzenal	:= .F.
Local lMensal   	:= .F.
Local lMapResumo	:= IIF((SuperGetMV("MV_LJLVFIS",,1) == 2) .AND. mv_par17 == 1,.T.,.F.)
Local lHouveMov		:= .F.
Local lProc 		:= .F.
local lIsenta 		:= .F.

Local nLin      	:= 0
Local nMes	    	:= mv_par01
Local nAno	    	:= mv_par02
Local nApuracao 	:= mv_par04
Local nNumGPr   	:= mv_par06
Local nNumGRet		:= mv_par09
local nValDoc		:= 0.00
local nValDocA		:= 0.00
local nValDocC		:= 0.00
local nValDocD		:= 0.00
local nValDocAD		:= 0.00
local nValDocIs		:= 0.00
local nValEntRt		:= 0.00
Local nBaseCalc 	:= 0.00
local nImpIncid 	:= 0.00
local nNumNota  	:= 0
local nSerie    	:= 0
local nValIsen  	:= 0.00
Local nAliquota 	:= 0
Local nCont 		:= 0
Local nLinObs   	:= 1
Local nContr		:= 1
Local nFeixe		:= 0
Local nX 			:= 0    
Local nAliq1 		:= 0
Local nAliq2 		:= 0
Local nPos			:= 0
Local nPos1 		:= 0
Local nY			:= 0
Local nValDoc1		:= 0.00 //Aliquota 1 
Local nValDoc2		:= 0.00 //Aliquota 2
Local nValAliq1 	:= 0.00
Local nValAliq2 	:= 0.00
Local nBsCalc		:= 0.00
Local nImposto		:= 0.00
Local nImp1			:= 0.00
Local nImp2			:= 0.00
Local nBsAliq1		:= 0.00
Local nBsAliq2		:= 0.00
Local nValDoc1A 	:= 0
Local nValDoc2A 	:= 0
Local nValDocIA 	:= 0    
Local nAliqPar		:= SuperGetMv("MV_ALIQISS") 
Local nAliqBusca	:= 0    
Local nAliqRet  	:= ""
Local nBasRet   	:= ""   
Local nDeduz    	:= ""  
Local nPosCup		:= 0  
Local nImprVal 		:= 0
Local nImprBr  		:= 0
Local nImprImp 		:= 0    
Local nNFCupom 		:= 0
Local nForFilial	:= 0 
Local nPosFil		:= 0
Local lTipoICM		:= GetNewPar("MV_914ICM",.F.)
Local  cSerieNf     := SerieNfId('SF3',3,'F3_SERIE') // Variavel para adquirir valores
Private aDatas		:= DetDatas(nMes,nAno,nApuracao,1)
Private dDtIni		:= aDatas[1]
Private dDtFim		:= aDatas[2]

SM0->(dbSetOrder(1))

For nForFilial := 1 to Len(aFilAtiv)
	
	cFilAnt	:= aFilAtiv[nForFilial,1]
	SM0->(dbSeek(cEmpAnt+cFilAnt))
	If !lAglFil
		nValDoc		:= 0.00
		nValDocA	:= 0.00
		nValDocC	:= 0.00
		nValDocD	:= 0.00
		nValDocAD	:= 0.00
		nValDocIs	:= 0.00
		nValEntRt	:= 0.00
		nBaseCalc 	:= 0.00
		nImpIncid 	:= 0.00
		nValIsen  	:= 0.00
		nAliquota 	:= 0
		nCont 		:= 0
		nLinObs   	:= 1
		nContr		:= 1
		nFeixe		:= 0
		nX 			:= 0    
		nAliq1 		:= 0
		nAliq2 		:= 0
		nPos		:= 0
		nPos1 		:= 0
		nY			:= 0
		nValDoc1	:= 0.00 //Aliquota 1 
		nValDoc2	:= 0.00 //Aliquota 2
		nValAliq1 	:= 0.00
		nValAliq2 	:= 0.00
		nBsCalc		:= 0.00
		nImposto	:= 0.00
		nImp1		:= 0.00
		nImp2		:= 0.00
		nBsAliq1	:= 0.00
		nBsAliq2	:= 0.00
		nValDoc1A 	:= 0
		nValDoc2A 	:= 0
		nValDocIA 	:= 0    
		nAliqPar	:= SuperGetMv("MV_ALIQISS") 
		nAliqBusca	:= 0    
		nImprVal 	:= 0
		nImprBr  	:= 0
		nImprImp 	:= 0    
		nNFCupom 	:= 0  
		nPagina		:=	MV_PAR12
		
		aMapaResumo	:= {}
		aGravaMapRes:= {}
		aCposTemp	:= {}
		aImprime  	:= {{"","",0,"","",0,0,"","",0,0,"","",0,0,0,0,0}}          
		aRetem    	:= {}   
		aCupom		:= {}   
		aPonto		:= {}
		cFilSF2	:= "('"+aFilAtiv[nForFilial,3]+"')"
		cFilSF3	:= "('"+aFilAtiv[nForFilial,2]+"')" 
		
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Nome do arquivo de apuracao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cArqApur := NmArqApur(cImp,nAno,nMes,nApuracao,1,cNrLivro)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa os pontos de entrada³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aPonto := R914Ponto(@nValDocD,@nAliqRet,@nBasRet,@nDeduz)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica os cupons fiscais e notas sobre cupom do periodo - apenas para o modo paisagem ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If mv_par18 == 2 .And. mv_par22 == 1
		aCupom := R914Cupom()
	Endif 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria Indice Condicional                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SF3")
	#IFDEF TOP
	
	lQuery 		:= .T.   
	cAliasSF3 	:= GetNextAlias() 
	aStru  		:= SF3->(dbStruct())
		cQuery 		:= "SELECT F3_FILIAL, F3_ALIQICM,F3_CFO,F3_BASEICM,F3_ISENICM,F3_OUTRICM,F3_VALCONT,F3_VALICM,F3_NFISCAL,"
		cQuery		+= "F3_CFO,F3_SERIE,F3_ENTRADA,F3_DTCANC,F3_OBSERV,F3_CLIEFOR,F3_LOJA,F3_CODISS,F3_TIPO, "                                             
		cQuery      += "F3_RECISS,"

	If lMapResumo
		cQuery += " F3_ESPECIE,F3_TIPO,F3_CODISS,F3_DTCANC, " 
 		aCposTemp := MaXRCposQry(cQuery + " F3_NFELETR") //Foi passado nesta função o campo F3_NFELETR antes do tratamento substring, para evitar quebra na extação dos campos
 	EndIf
	
	cQuery += cSerieNf +" F3_SDOC " 
	cQuery += ",substring(F3_NFELETR,1,9) F3_NFELETR"
	cQuery += "FROM "+RetSqlName("SF3")+" "
	cQuery += "WHERE F3_FILIAL IN "+cFilSF3+" AND "
	cQuery += "((F3_CFO >'5000' AND F3_TIPO not in ('B','D')) OR (F3_CFO <'5000' AND F3_TIPO in ('B','D'))) AND "
	cQuery += "F3_ENTRADA BETWEEN '"+Dtos(dDtIni)+"' AND '"+Dtos(dDtFim)+"' AND "
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Quando o parametro de series para notas conjugadas estiver preenchido,   ³
	//³seleciona todos os registros, mesmo os que nao ter servico, para montar a³
	//³numeracao de/ate com todos os documentos.                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If mv_par18 == 2 .And. !Empty(cSerPar)
		cQuery += cSerieNf+" IN " + FisxForm(cSerPar,"/") + " AND "
	ElseIf !lTipoICM
		cQuery	+=	" F3_TIPO = 'S' AND " 
	Endif               
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Identifica se imprime os cupons fiscais / mapa resumo³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lMapResumo .Or. (mv_par22 == 2 .And. mv_par17 == 2)
		cQuery	+=	"F3_ESPECIE <> 'CF' AND F3_ESPECIE <> 'ECF' AND "
	EndIf  
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Filtra o numero do livro se tiver no parametro³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !(cNrLivro == "*")
		cQuery	+=	" F3_NRLIVRO = '" + cNrLivro + "' AND "
	Endif     

   	cQuery += " D_E_L_E_T_=' ' "

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta o indice de acordo com a impressao - retrato/paisagem³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If lQuebra .And. mv_par18 == 1
		   cQuery += "ORDER BY F3_ALIQICM,F3_ENTRADA,F3_FILIAL,"+cSerieNf+",F3_NFISCAL"
	Else
		   cQuery += "ORDER BY F3_ENTRADA,F3_FILIAL,"+cSerieNf+",F3_NFISCAL"
	Endif
    
    cQuery := ChangeQuery(cQuery)
    
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF3,.T.,.T.)
	
	For nX := 1 To len(aStru)
		If aStru[nX][2] <> "C" .And. FieldPos(aStru[nX][1])<>0
		   TcSetField(cAliasSF3,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
		EndIf
	Next nX
		
	dbSelectArea(cAliasSF3)
	
	#Else

	nIndex	:=	RetIndex("SF3")
	cArqInd	:=	CriaTrab(NIL,.F.)
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta o indice de acordo com a impressao - retrato/paisagem³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If lQuebra .And. mv_par18 == 1
	   	cChave	:=	"STR(F3_ALIQICM)+DTOS(F3_ENTRADA)+F3_FILIAL+"+cSerieNf+"+F3_NFISCAL"
    Else
	   	cChave	:=	"DTOS(F3_ENTRADA)+F3_FILIAL+"+cSerieNf+"+F3_NFISCAL"
    Endif 	
    
	cFiltro :=  "F3_FILIAL $ '"+cFilSF3+"'"
	cFiltro	+=	" .AND. dtos(F3_ENTRADA) >='"+dtos(dDtIni)+"' .and. dtos(F3_ENTRADA)<='"+dtos(dDtFim)+"'"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Quando o parametro de series para notas conjugadas estiver preenchido,   ³
	//³seleciona todos os registros, mesmo os que nao ter servico, para montar a³
	//³numeracao de/ate com todos os documentos.                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If mv_par18 == 2 .And. !Empty(cSerPar)
		cFiltro	+=	".AND. Alltrim("+cSerieNf+") $ '" + cSerPar + "'"
	Else
		cFiltro	+=	".AND.F3_TIPO=='S'" 
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Identifica se imprime os cupons fiscais / mapa resumo³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lMapResumo .Or. (mv_par22 == 2 .And. mv_par17 == 2)
		cFiltro	+=	" .AND. Alltrim(F3_ESPECIE) <> 'CF' .AND. Alltrim(F3_ESPECIE) <> 'ECF' "
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Filtra o numero do livro se tiver no parametro³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !(cNrLivro=="*")
	   cFiltro	+=	".AND.F3_NRLIVRO=='"+cNrLivro+"'"
	Endif          
	
	IndRegua("SF3",cArqInd,cChave,,cFiltro,STR0007) //"Selecionando Registros..."
	dbGotop()
	
	#ENDIF

	SetRegua(LastRec())


	Do Case
		Case nApuracao==1 ; cDiaApur := "10" // Decendial
		Case nApuracao==2 ; cDiaApur := "15" // Quinzenal      
		Case nApuracao==3 ; cDiaApur := "31" // Mensal
	EndCase
	
	cMes := MesExtenso(Month(dDtIni))

	R914LayOut(@aLay)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento para apresentar os dados do Mapa Resumo³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lMapResumo
	
		If lQuebra .And. mv_par18 == 1
		     	cChave	:=	"STR(F3_ALIQICM)+DTOS(F3_ENTRADA)+F3_FILIAL+"+cSerieNf+"+F3_NFISCAL"
	    Else
		     	cChave	:=	"DTOS(F3_ENTRADA)+F3_FILIAL+"+cSerieNf+"+F3_NFISCAL"
	    Endif 	
		
		cArqBkpQry 		:= cAliasSf3
	
			// Processar para todas as filiais selecionadas
			If lAglFil
				For nPosFil := 1 to Len(aFilAtiv)
					cFilAnt	:= aFilAtiv[nPosFil,1]
					aMapaResumo		:= MaxRMapRes(dDtIni, dDtFim, aMapaResumo)
		aGravaMapRes	:= 	MaXRAgrupF3(/*cFilAnt*/,aMapaResumo,"MATR914")
				Next
				cFilAnt	:= cFilBack
			Else
				aMapaResumo		:= MaxRMapRes(dDtIni, dDtFim )
				aGravaMapRes	:= MaXRAgrupF3(/*cFilAnt*/,aMapaResumo,"MATR914")
			EndIf
		cArqTmpMP		:= 	MaXRExecArq(1)
			cAliasSf3		:= MaXRAddArq(	1, cArqTmpMP, cAliasSf3, aCposTemp, aGravaMapRes, cChave )
	
	EndIf

	// Posiciona arquivos para uso no loop
	SA1->(dbSetOrder(1))
	SA2->(dbSetOrder(2))
	SF2->(dbSetOrder(1))

	While !(cAliasSF3)->(Eof())
	    nAliquota := (cAliasSF3)->F3_ALIQICM
	    lCond     := IIF(lQuebra .And. mv_par18 == 1, nAliquota==(cAliasSF3)->F3_ALIQICM,.T.)	      
	    IncRegua()
		If Interrupcao(@lEnd)
		  	 Exit
		Endif
	
		While lCond .AND. !(cAliasSF3)->(Eof()) .AND. cDia <= cDiaApur 
      
	    	If mv_par18 == 1 //Retrato
	      		
		        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		        //³ Considera filtro do usuario                                  ³
	            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	         	If !Empty(cFilterUser).and.!(&cFilterUser)
				       (cAliasSF3)->(dbSkip())
			       Loop
		        Endif   
				
	   			nNumNota	:= ""
	           	nSerie   	:= ""
	           	nValIsen 	:= ""
	            cDia 		:= Substr(DTOS((cAliasSF3)->F3_ENTRADA),7,2)
				cEntSai 	:= Iif (Substr((cAliasSF3)->F3_CFO,1,1) < "5", "2", "1")
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Analisa retencao             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cRecISS := (cAliasSF3)->F3_RECISS
	            
	            If nLin==59
	               FmtLin(,aLay[13],,,@nLin)
	               nLin:= 0
	            EndIf
		        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		        //³ Imprime o Cabecalho                                          ³
		        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		        If ( nLin > 60 .Or. nLin == 0 )
		        	nFeixe++
		           Cab(cAliasSF3,@nLin,aLay,cMes,nMes,nAno,lQuebra,nAliquota, @nPagina, @nFeixe, @nAliq2)
		        EndIf
	            
				If cEntSai == "2" // Se NF de entrada
					If  Empty((cAliasSF3)->F3_DTCANC)
						FmtLin(,aLay[13],,,@nLin)       
					EndIf
		            If (cAliasSF3)->F3_ISENICM+(cAliasSF3)->F3_OUTRICM > 0
				        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				        //³ Campos de Valores Nao Tributados                             ³
			            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		               	If !Empty((cAliasSF3)->F3_NFELETR)
			  		   		nNumNota:= (cAliasSF3)->F3_NFELETR
		  				Else
			   		   		nNumNota:= (cAliasSF3)->F3_NFISCAL
		   				EndIf
		 	           	nSerie   	:= SerieNfId(cAliasSF3,2,'F3_SERIE')
		               	nValIsen 	:= (cAliasSF3)->F3_ISENICM+(cAliasSF3)->F3_OUTRICM
		               	nValDocC 	+= nValIsen
		               	nValDocIs	+= nValIsen
		               	nCont++
				        FmtLin({cDia,"","","",nNumNota,nSerie,nValIsen,""},aLay[14],,,@nLin)
			        Else
				        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				        //³ Campos de Valores Tributados                                 ³
			            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				        nValDoc := Iif((cAliasSF3)->F3_BASEICM+(cAliasSF3)->F3_ISENICM+(cAliasSF3)->F3_OUTRICM == 0,;
			    				(cAliasSF3)->F3_VALCONT,;  
								(cAliasSF3)->F3_BASEICM+(cAliasSF3)->F3_ISENICM+(cAliasSF3)->F3_OUTRICM)
							If  Empty((cAliasSF3)->F3_DTCANC)
			            		nValDocA	+= nValDoc
					    		nValDocAD	+= nValDoc   
    							nValDocD    += (cAliasSF3)->F3_VALICM
			            		nBaseCalc 	+= (cAliasSF3)->F3_BASEICM
			            		//If cRecIss $ "2N"
				            		nImpIncid 	+= (cAliasSF3)->F3_VALICM
				               // Endif
			            		nCont++
				        		FmtLin({cDia,Iif(!Empty((cAliasSF3)->F3_NFELETR),(cAliasSF3)->F3_NFELETR,(cAliasSF3)->F3_NFISCAL),SerieNfId(cAliasSF3,2,'F3_SERIE'),nValDoc,nNumNota,nSerie,nValIsen,Iif(!Empty((cAliasSF3)->F3_DTCANC),Alltrim((cAliasSF3)->F3_OBSERV),(cAliasSF3)->F3_VALICM)},aLay[14],,,@nLin)
				       		Else
					       		If Empty(cMsgCan)
					       		 	cMsgCan :="NF Cancelada:"
					       		 	cObslin1 += cMsgCan
					       		EndIf 	
					       			If  !Empty(cMsgCan)
					       				cObslin1 += Alltrim((cAliasSF3)->F3_NFISCAL)+"-"
					       			EndIf
					       	EndIf
		            EndIf                                                                                           					
				Else
					If  Empty((cAliasSF3)->F3_DTCANC)
						FmtLin(,aLay[13],,,@nLin)       
					EndIf
		            If (cAliasSF3)->F3_ISENICM+(cAliasSF3)->F3_OUTRICM > 0
				        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				        //³ Campos de Valores Nao Tributados                             ³
			            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		               	If !Empty((cAliasSF3)->F3_NFELETR)
			  		   		nNumNota:= (cAliasSF3)->F3_NFELETR
		  				else
			   		   		nNumNota:= (cAliasSF3)->F3_NFISCAL
		   				EndIf
		 	           	nSerie   	:= SerieNfId(cAliasSF3,2,'F3_SERIE')
		               	nValIsen 	:= (cAliasSF3)->F3_ISENICM+(cAliasSF3)->F3_OUTRICM
		               	nValDocC 	+= nValIsen
		               	nValDocIs	+= nValIsen
		               	nValDocD    += (cAliasSF3)->F3_VALICM
		               	nCont++
				        FmtLin({cDia,"","","",nNumNota,nSerie,nValIsen,""},aLay[14],,,@nLin)
			        Else
				        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				        //³ Campos de Valores Tributados                                 ³
			            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				        nValDoc := Iif((cAliasSF3)->F3_BASEICM+(cAliasSF3)->F3_ISENICM+(cAliasSF3)->F3_OUTRICM == 0,;
			    				(cAliasSF3)->F3_VALCONT,;  
								(cAliasSF3)->F3_BASEICM+(cAliasSF3)->F3_ISENICM+(cAliasSF3)->F3_OUTRICM)
							If  Empty((cAliasSF3)->F3_DTCANC) 
									If !(Empty((cAliasSF3)->F3_CODISS))
									nValDocA	+= nValDoc
						    		nValDocAD	+= nValDoc               
						    		nValDocD    += (cAliasSF3)->F3_VALICM
				            		nBaseCalc 	+= (cAliasSF3)->F3_BASEICM
				            		nImpIncid 	+= (cAliasSF3)->F3_VALICM
				            		nCont++
					        		FmtLin({cDia,Iif(!Empty((cAliasSF3)->F3_NFELETR),(cAliasSF3)->F3_NFELETR,(cAliasSF3)->F3_NFISCAL),SerieNfId(cAliasSF3,2,'F3_SERIE'),nValDoc,nNumNota,nSerie,nValIsen,Iif(!Empty((cAliasSF3)->F3_DTCANC),Alltrim((cAliasSF3)->F3_OBSERV),"")},aLay[14],,,@nLin)
					        		Else
										nValDocA	:= 0
										nValDocAD	:= 0
										nValDocD	:= 0
										nImpIncid	:= 0
										nBaseCalc	:= 0 
			               				nCont++
					        			FmtLin({cDia,Iif(!Empty((cAliasSF3)->F3_NFELETR),(cAliasSF3)->F3_NFELETR,(cAliasSF3)->F3_NFISCAL),SerieNfId(cAliasSF3,2,'F3_SERIE'),"","","","",""},aLay[14],,,@nLin)							
					       			EndIf
				       		Else                                                                 
					       		If Empty(cMsgCan)
					       		 	cMsgCan :="NF Cancelada:"
					       		 	cObslin1 += cMsgCan
					       		EndIf 	
					       			If  !Empty(cMsgCan)
					       				cObslin1 += Alltrim((cAliasSF3)->F3_NFISCAL)+"-"
					       			EndIf
					       	EndIf
		            EndIf                                                                                           
				EndIf
	      		
	            lHouveMov := .T.
	            
	            (cAliasSF3)->(DbSkip())
			    
			    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		        //³ Imprime o Total dos Valores por Dia                          ³
	            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	            If (cDia <> Substr(DTOS((cAliasSF3)->F3_ENTRADA),7,2)) .Or. (lQuebra .And. nAliquota <> (cAliasSF3)->F3_ALIQICM)
		            FmtLin(,aLay[13],,,@nLin)
			        FmtLin({cDia,STR0027,"",IIf(nValDocAD==0,"",nValDocAD),"","",IIf(nValDocIs==0,"",nValDocIs),IIf(nValEntRt==0,"",nValEntRt)},aLay[14],,,@nLin) // "TOTAL"
			        FmtLin(,aLay[13],,,@nLin)		
		            FmtLin({"","","","","","","",""},aLay[14],,,@nLin)
		           	nValDocAD := 0
			  		nValDocIs := 0
			  		nValEntRt := 0
		  		Endif
			    
	 	        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		        //³Imprime o Rodape                                              ³
	            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	            
	            If (lQuebra .AND. nAliquota <> (cAliasSF3)->F3_ALIQICM) .OR. (!lQuebra .AND. (cAliasSF3)->(Eof())) .OR. (cAliasSF3)->(Eof())
	            	Rod(cAliasSF3,@nLin,aLay,cMes,nMes,nAno,lQuebra,@nAliquota,@nPagina,@nFeixe,@nValDocA,@nValDocC,@nValDocD,;
		    			@nBaseCalc,@nImpIncid,nNumGPr,dDataPr,cBancoPr,nNumGRet,dDataRet,cBancoRet,cObslin1,;
	        			cObslin2,cObslin3,cObslin4,@nBsAliq2,@nImp2,@nValDocIs,aPonto)
	 				lRodape := .T.
	            EndIF
	            
	            lCond:= IIF(lQuebra,nAliquota==(cAliasSF3)->F3_ALIQICM,.T.)
		  Else 
		        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		        //³ Considera filtro do usuario                                  ³
	            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	         	If !Empty(cFilterUser).and.!(&cFilterUser)
			       dbSkip()
			       Loop
		        Endif
		        
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se eh uma nota sobre cupom e se a pergunta esta indicando  ³
				//³para nao imprimir cupom. Se sim, pega os valores do cupom, ja que a ³
				//³nota sobre cupom tem a escrituracao zerada.                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nPosCup := 0
				If mv_par18 == 2 .And. mv_par22 == 2
						// Posiciona no Cadastro de Cliente/Fornecedor
						nPosFil := aScan( aFilAtiv, { |x| x[2]== (cAliasSF3)->F3_FILIAL } )
						If SF2->(dbSeek(aFilAtiv[nPosFil,3]+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA)) .And.;
						!Empty(SF2->F2_NFCUPOM)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Posicoes do array aCupom:    ³
						//³[01]: (cAliasSF3)->F3_NFISCAL³
						//³[02]: (cAliasSF3)->F3_SERIE  ³
						//³[03]: (cAliasSF3)->F3_CLIEFOR³
						//³[04]: (cAliasSF3)->F3_LOJA   ³
						//³[05]: (cAliasSF3)->F3_BASEICM³
						//³[06]: (cAliasSF3)->F3_ISENICM³
						//³[07]: (cAliasSF3)->F3_OUTRICM³
						//³[08]: (cAliasSF3)->F3_VALCONT³
						//³[09]: (cAliasSF3)->F3_VALICM ³
						//³[10]: (cAliasSF3)->F3_ALIQICM³						
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                            
						nNFCupom := TamSx3("F2_DOC")[01]
						cNFCupom := SubStr(SF2->F2_NFCUPOM,1,nNFCupom)
						cSerCupom:= SubStr(SF2->F2_NFCUPOM,nNFCupom+1,Len(SF2->F2_NFCUPOM))
						nPosCup := aScan(aCupom,{|x| x[1] == cNFCupom;
									 .And. x[2] == cSerCupom;
									 .And. x[3] == (cAliasSF3)->F3_CLIEFOR;
									 .And. x[4] == (cAliasSF3)->F3_LOJA}) 
					Endif
				Endif
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Impressao em Modo Paisagem - Aglutina Nota Fiscal                 ³
				//³Somente soma o valor se o documento nao for cancelado e se        ³
				//³o registro nao for de produto, quando feita a opcao de se imprimir³
				//³tambem os movimentos que somente possuam produto.                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                If Empty((cAliasSF3)->F3_DTCANC) .And. !(Empty((cAliasSF3)->F3_CODISS))
                	// Quando for nota sobre cupom, busca os valores do array de cupons
                	If mv_par18 == 2 .And. mv_par22 == 2 .And. nPosCup > 0
						// Totalizadores
						nValDoc 	:= Iif(aCupom[nPosCup][05]+aCupom[nPosCup][06]+aCupom[nPosCup][07] == 0,;
	   			    			      	aCupom[nPosCup][08],;
									  	aCupom[nPosCup][05]+aCupom[nPosCup][06]+aCupom[nPosCup][07])
					  	nBsCalc 	:= aCupom[nPosCup][05]
	  					nImposto	:= aCupom[nPosCup][09]
	  					nAliqBusca 	:= aCupom[nPosCup][10]
                	Else
                		// Totalizadores
						nValDoc 	:= Iif((cAliasSF3)->F3_BASEICM+(cAliasSF3)->F3_ISENICM+(cAliasSF3)->F3_OUTRICM == 0,;
	   			    			      	(cAliasSF3)->F3_VALCONT,;
									  	(cAliasSF3)->F3_BASEICM+(cAliasSF3)->F3_ISENICM+(cAliasSF3)->F3_OUTRICM)
					  	nBsCalc 	:= (cAliasSF3)->F3_BASEICM
	  					nImposto	:= (cAliasSF3)->F3_VALICM
	  					nAliqBusca 	:= (cAliasSF3)->F3_ALIQICM
	  				Endif
                Else
      				nValDoc := 0
      				nBsCalc := 0
					nImposto:= 0
                Endif  
                
				//Valores a imprimir
				nImprVal := nValDoc
				nImprBr  := nBsCalc
				nImprImp := nImposto 

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se for uma nota fiscal de produto, busca a aliquota do parametro³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Empty((cAliasSF3)->F3_CODISS)         
					nAliqBusca := nAliqPar
				Endif

			    cDia 	:= Substr(DTOS((cAliasSF3)->F3_ENTRADA),7,2)
    			If !Empty((cAliasSF3)->F3_NFELETR)
			  		cNFIni := (cAliasSF3)->F3_NFELETR
			  		cNFFim := (cAliasSF3)->F3_NFELETR
				else
			   		cNFIni := (cAliasSF3)->F3_NFISCAL 
					cNFFim := (cAliasSF3)->F3_NFISCAL
		   		EndIf
				nPos 	:= Ascan(aImprime,{|x| x[1]==cDia .And. x[2]==SerieNfId(cAliasSF3,2,'F3_SERIE')})
				nPos1	:= 0
				cChav 	:= cDia + SerieNfId(cAliasSF3,2,'F3_SERIE')
				cEntSai := Iif (Substr((cAliasSF3)->F3_CFO,1,1) < "5", "2", "1")
			  
				If cEntSai == "1" // Processo somente as Notas Fiscais de Saida

					If nPos > 0

						lProc := .T.        
						
						Do While lProc
						
							If cChav <> aImprime[nPos][1] + aImprime[nPos][2]
								Exit
							Endif
							
							//Posicao Aliquota 1
							If nAliqBusca == nAliq1 .And. nAliqBusca <> 0 .OR. (nAliqBusca <> 0 .And. lIsenta .And. nAliq2 == 0)
								//Verifico se e sequencia da nota fiscal
								If (Soma1(Alltrim(aImprime[nPos][5]),1) == Alltrim((cAliasSF3)->F3_NFISCAL)) .Or. Empty(aImprime[nPos][5]) .Or. (Alltrim(aImprime[nPos][5]+aImprime[nPos][2])==Alltrim((cAliasSF3)->F3_NFISCAL+SerieNfId(cAliasSF3,2,'F3_SERIE')))
									If Empty(aImprime[nPos][5])
										// Altera a Nota Fiscal Inicial
										If !Empty((cAliasSF3)->F3_NFELETR)
											aImprime[nPos][4] := (cAliasSF3)->F3_NFELETR
										Else
											aImprime[nPos][4] := (cAliasSF3)->F3_NFISCAL 
										endif		
									Endif	
									// Altera a Nota Fiscal Final
									If !Empty((cAliasSF3)->F3_NFELETR)
										aImprime[nPos][5] := (cAliasSF3)->F3_NFELETR
									Else
								 		aImprime[nPos][5] := (cAliasSF3)->F3_NFISCAL
									endif		
									// Acumula o Valor
									aImprime[nPos][6] 	+= nImprVal
									aImprime[nPos][15] 	+= nImprBr
									aImprime[nPos][16] 	+= nImprImp
									lProc 	 := .F.                    
									lIsenta  := .F.
	   			        		    nAliq1	 := nAliqBusca
								Endif    
								                                                             
	                        //Posicao Aliquota 2
							Elseif nAliqBusca <> nAliq1  .And. nAliqBusca <> 0
								//Verifico se e sequencia da nota fiscal
								If (Soma1(Alltrim(aImprime[nPos][9]),1) == Alltrim((cAliasSF3)->F3_NFISCAL)) .Or. Empty(aImprime[nPos][9]) .Or. (Alltrim(aImprime[nPos][9]+aImprime[nPos][2])==Alltrim((cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE))
									If Empty(aImprime[nPos][9])
										// Altera a Nota Fiscal Inicial		
										If !Empty((cAliasSF3)->F3_NFELETR)
									   		aImprime[nPos][8] := (cAliasSF3)->F3_NFELETR
										Else
									 		aImprime[nPos][8] := (cAliasSF3)->F3_NFISCAL  
										endif
									Endif	
									// Altera a Nota Fiscal Final
									If !Empty((cAliasSF3)->F3_NFELETR)
										aImprime[nPos][9] := (cAliasSF3)->F3_NFELETR
									Else
								 		aImprime[nPos][9] := (cAliasSF3)->F3_NFISCAL
									endif
									// Acumula o Valor
									aImprime[nPos][10]	+= nImprVal
									aImprime[nPos][17] 	+= nImprBr
									aImprime[nPos][18] 	+= nImprImp
									lProc 	 := .F.
	   			        		    nAliq2	 := nAliqBusca
								Endif                                                                 
								
		                    //Posicao Isentas/Outras
		                    Elseif nAliqBusca == 0
								//Verifico se e sequencia da nota fiscal
								If (Soma1(Alltrim(aImprime[nPos][13]),1) == Alltrim((cAliasSF3)->F3_NFISCAL)) .Or. Empty(aImprime[nPos][13]) .Or. (Alltrim(aImprime[nPos][13]+aImprime[nPos][2])==Alltrim((cAliasSF3)->F3_NFISCAL+SerieNfId(cAliasSF3,2,'F3_SERIE')))
									If Empty(aImprime[nPos][13])	// Altera a Nota Fiscal Inicial
										If !Empty((cAliasSF3)->F3_NFELETR)
											aImprime[nPos][12] := (cAliasSF3)->F3_NFELETR
										Else
											aImprime[nPos][12] := (cAliasSF3)->F3_NFISCAL 
										endif										
									Endif
									// Altera a Nota Fiscal Final
									If !Empty((cAliasSF3)->F3_NFELETR)
										aImprime[nPos][13] := (cAliasSF3)->F3_NFELETR
									Else
										aImprime[nPos][13] := (cAliasSF3)->F3_NFISCAL 
									Endif		
									// Acumula o Valor
									aImprime[nPos][14] 	+= nImprVal
									lProc := .F.
									lIsenta := .T.
								Endif
							Else
								Exit
							Endif
							
			                If lProc
			                    //Localiza o proximo a partir da posicao que se encontra
				           		nPos  := Ascan(aImprime,{|x| x[1]==cDia .And. x[2]==SerieNfId(cAliasSF3,2,'F3_SERIE')},nPos+1)
				           		If nPos == 0 .Or. nPos1 == nPos
				           		   Exit
				           		Endif
				           		nPos1 := nPos
		        	        Endif
	
						Enddo
			        Endif 
	
			        If nPos == 0 .Or. lProc
			        	If nAliqBusca == 0 // Isenta
			        	    Aadd(aImprime,{cDia,SerieNfId(cAliasSF3,2,'F3_SERIE'),;
		    	    	    0,"","",0,; // Aliquota 1
		        		    0,"","",0,; // Aliquota 2
		        		    nAliqBusca,cNFIni,cNFFim,nValDoc,;//Isentas/Outras
		        		    0, 0, 0, 0})
		        		Elseif (nAliqBusca > 0 .And. nAliq1 == 0 ) .Or. (nAliq1 == nAliqBusca) //Tributada
			        	    Aadd(aImprime,{cDia,SerieNfId(cAliasSF3,2,'F3_SERIE'),;
		    	    	    nAliqBusca,cNFIni,cNFFim,nValDoc,; // Aliquota 1
		        		    0,"","",0,; // Aliquota 2
		        		    0,"","",0,; //Isentas/Outras
		        		    nBsCalc, nImposto, 0,0})
		        		    nAliq1:= nAliqBusca
		        		Elseif nAliqBusca > 0 .And. nAliq1 > 0 //Tributada
			        	    Aadd(aImprime,{cDia,SerieNfId(cAliasSF3,2,'F3_SERIE'),;
		    	    	    0,"","",0,; // Aliquota 1
		        		    nAliqBusca,cNFIni,cNFFim,nValDoc,; // Aliquota 2
		        		    0,"","",0,; //Isentas/Outras
		        		    0,0,nBsCalc, nImposto})         
		        		    nAliq2:= nAliqBusca
				        Endif
                    Endif        

				    If !Empty((cAliasSF3)->F3_DTCANC)
				    	If Empty(cMsgCan)
				    	 	cMsgCan :="NF Cancelada:"
				    	 	cObslin1 += cMsgCan
				    	EndIf
				    	If !Empty(cMsgCan)
				    		cObslin1 += Alltrim((cAliasSF3)->F3_NFISCAL)+"-"
				    	EndIf
		            Endif 
		        Endif
		           
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Analisa retencao             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cRecISS := (cAliasSF3)->F3_RECISS
		            
				If cEntSai == "2" .And. Empty((cAliasSF3)->F3_DTCANC) .And. !(Empty((cAliasSF3)->F3_CODISS)) // Se NF de entrada, nao cancelada e de servico
					If nPos > 0

						lProc := .T.        
						
						Do While lProc
						
							If cChav <> aImprime[nPos][1] + aImprime[nPos][2]
								Exit
							Endif
							
							//Posicao Aliquota 1
							If nAliqBusca == nAliq1 .And. nAliqBusca <> 0 .OR. (nAliqBusca <> 0 .And. lIsenta .And. nAliq2 == 0)
								//Verifico se e sequencia da nota fiscal
								If (Soma1(Alltrim(aImprime[nPos][5]),1) == Alltrim((cAliasSF3)->F3_NFISCAL)) .Or. Empty(aImprime[nPos][5]) .Or. (Alltrim(aImprime[nPos][5]+aImprime[nPos][2])==Alltrim((cAliasSF3)->F3_NFISCAL+SerieNfId(cAliasSF3,2,'F3_SERIE')))
									If Empty(aImprime[nPos][5])
										// Altera a Nota Fiscal Inicial
										If !Empty((cAliasSF3)->F3_NFELETR)
									   		aImprime[nPos][4]  := (cAliasSF3)->F3_NFELETR
										Else
											aImprime[nPos][4] := (cAliasSF3)->F3_NFISCAL  
										endif
									Endif	
									// Altera a Nota Fiscal Final
									If !Empty((cAliasSF3)->F3_NFELETR)
								   		aImprime[nPos][5]  := (cAliasSF3)->F3_NFELETR
									Else
										aImprime[nPos][5] := (cAliasSF3)->F3_NFISCAL  
									endif
									// Acumula o Valor
									aImprime[nPos][6] 	+= nImprVal
									aImprime[nPos][15] 	+= nImprBr
									aImprime[nPos][16] 	+= nImprImp
									lProc 	 := .F.                    
									lIsenta  := .F.
	   			        		    nAliq1	 := nAliqBusca
								Endif    
								                                                             
	                        //Posicao Aliquota 2
							Elseif nAliqBusca <> nAliq1  .And. nAliqBusca <> 0
								//Verifico se e sequencia da nota fiscal
								If (Soma1(Alltrim(aImprime[nPos][9]),1) == Alltrim((cAliasSF3)->F3_NFISCAL)) .Or. Empty(aImprime[nPos][9]) .Or. (Alltrim(aImprime[nPos][9]+aImprime[nPos][2])==Alltrim((cAliasSF3)->F3_NFISCAL+SerieNfId(cAliasSF3,2,'F3_SERIE')))
									If Empty(aImprime[nPos][9])
										// Altera a Nota Fiscal Inicial
										If !Empty((cAliasSF3)->F3_NFELETR)
									   		aImprime[nPos][8] := (cAliasSF3)->F3_NFELETR
										Else
											aImprime[nPos][8] := (cAliasSF3)->F3_NFISCAL
										endif
									Endif	
									// Altera a Nota Fiscal Final
									If !Empty((cAliasSF3)->F3_NFELETR)
								   		aImprime[nPos][9] := (cAliasSF3)->F3_NFELETR
									Else
										aImprime[nPos][9] := (cAliasSF3)->F3_NFISCAL
									endif
									// Acumula o Valor
									aImprime[nPos][10]	+= nImprVal
									aImprime[nPos][17] 	+= nImprBr
									aImprime[nPos][18] 	+= nImprImp
									lProc 	 := .F.
	   			        		    nAliq2	 := nAliqBusca
								Endif                                                                 
								
		                    //Posicao Isentas/Outras
		                    Elseif nAliqBusca == 0
								//Verifico se e sequencia da nota fiscal
								If (Soma1(Alltrim(aImprime[nPos][13]),1) == Alltrim((cAliasSF3)->F3_NFISCAL)) .Or. Empty(aImprime[nPos][13]) .Or. (Alltrim(aImprime[nPos][13]+aImprime[nPos][2])==Alltrim((cAliasSF3)->F3_NFISCAL+SerieNfId(cAliasSF3,2,'F3_SERIE')))
									If Empty(aImprime[nPos][13])
										// Altera a Nota Fiscal Inicial
										If !Empty((cAliasSF3)->F3_NFELETR)
											aImprime[nPos][12] := (cAliasSF3)->F3_NFELETR
										Else
											aImprime[nPos][12] := (cAliasSF3)->F3_NFISCAL 
										Endif		
									Endif
									// Altera a Nota Fiscal Final
									If !Empty((cAliasSF3)->F3_NFELETR)
										aImprime[nPos][13] := (cAliasSF3)->F3_NFELETR
									Else
										aImprime[nPos][13] := (cAliasSF3)->F3_NFISCAL 
									Endif	
									// Acumula o Valor
									aImprime[nPos][14] 	+= nImprVal
									lProc := .F.
									lIsenta := .T.
								Endif
							Else
								Exit
							Endif
							
			                If lProc
			                    //Localiza o proximo a partir da posicao que se encontra
				           		nPos  := Ascan(aImprime,{|x| x[1]==cDia .And. x[2]==SerieNfId(cAliasSF3,2,'F3_SERIE')},nPos+1)
				           		If nPos == 0 .Or. nPos1 == nPos
				           		   Exit
				           		Endif
				           		nPos1 := nPos
		        	        Endif
	
						Enddo
			        Endif 
	
			        If nPos == 0 .Or. lProc
			        	If nAliqBusca == 0 // Isenta
			        	    Aadd(aImprime,{cDia,SerieNfId(cAliasSF3,2,'F3_SERIE'),;
		    	    	    0,"","",0,; // Aliquota 1
		        		    0,"","",0,; // Aliquota 2
		        		    nAliqBusca,cNFIni,cNFFim,nValDoc,;//Isentas/Outras
		        		    0, 0, 0, 0})
		        		Elseif (nAliqBusca > 0 .And. nAliq1 == 0 ) .Or. (nAliq1 == nAliqBusca) //Tributada
			        	    Aadd(aImprime,{cDia,SerieNfId(cAliasSF3,2,'F3_SERIE'),;
		    	    	    nAliqBusca,cNFIni,cNFFim,nValDoc,; // Aliquota 1
		        		    0,"","",0,; // Aliquota 2
		        		    0,"","",0,; //Isentas/Outras
		        		    nBsCalc, nImposto, 0,0})
		        		    nAliq1:= nAliqBusca
		        		Elseif nAliqBusca > 0 .And. nAliq1 > 0 //Tributada
			        	    Aadd(aImprime,{cDia,SerieNfId(cAliasSF3,2,'F3_SERIE'),;
		    	    	    0,"","",0,; // Aliquota 1
		        		    nAliqBusca,cNFIni,cNFFim,nValDoc,; // Aliquota 2
		        		    0,"","",0,; //Isentas/Outras
		        		    0,0,nBsCalc, nImposto})         
		        		    nAliq2:= nAliqBusca
				        Endif
                    Endif        

				    If !Empty((cAliasSF3)->F3_DTCANC)
				    	If Empty(cMsgCan)
				    	 	cMsgCan :="NF Cancelada:"
				    	 	cObslin1 += cMsgCan
				    	EndIf
				    	If !Empty(cMsgCan)
				    		cObslin1 += Alltrim((cAliasSF3)->F3_NFISCAL)+"-"
				    	EndIf
		            Endif 					
				EndIf
				
	            lHouveMov := .T.
		            
	            (cAliasSF3)->(DbSkip())
	            
      	  Endif
      EndDo
      
	//Paisagem
	If mv_par18 == 2
					
		 For nY:= 2 To Len(aImprime)

		     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		     //³ Imprime o Cabecalho                                          ³
		     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		     If ( nLin > 55 .Or. nLin == 0 )
			   	nFeixe++
				 Cab(cAliasSF3,@nLin,aLay,cMes,nMes,nAno,lQuebra,nAliq1,@nPagina,@nFeixe,nAliq2)
		     EndIf

			 FmtLin(,aLay[13],,,@nLin)
			 FmtLin({aImprime[nY][1],Iif(!Empty(aImprime[nY][4]) .And. !Empty(aImprime[nY][5]),aImprime[nY][4]+" A "+aImprime[nY][5],""),Iif(!Empty(aImprime[nY][4]) .And. !Empty(aImprime[nY][5]),aImprime[nY][2],""), Iif(!Empty(aImprime[nY][4]) .And. !Empty(aImprime[nY][5]),aImprime[nY][6],""),;
					Iif(!Empty(aImprime[nY][8])  .And. !Empty(aImprime[nY][9]),aImprime[nY][8]+" A "+aImprime[nY][9],""),Iif(!Empty(aImprime[nY][8]) .And. !Empty(aImprime[nY][9]),aImprime[nY][2],""), Iif(!Empty(aImprime[nY][8]) .And. !Empty(aImprime[nY][9]),aImprime[nY][10],""),;
		            Iif(!Empty(aImprime[nY][12]) .And. !Empty(aImprime[nY][13]),aImprime[nY][12]+" A "+aImprime[nY][13],""),Iif(!Empty(aImprime[nY][12]) .And. !Empty(aImprime[nY][13]),aImprime[nY][2],""), Iif(!Empty(aImprime[nY][12]) .And. !Empty(aImprime[nY][13]),aImprime[nY][14],""),(aImprime[nY][16]+aImprime[nY][18])},aLay[14],,,@nLin)

			 nValDoc1A  += aImprime[nY][6]
			 nValDoc2A  += aImprime[nY][10]
			 nValDocIA  += aImprime[nY][14]
			
			 nValDoc1  += aImprime[nY][6]
			 nValDoc2  += aImprime[nY][10]
			 nValDocIs += aImprime[nY][14]
			
			 nBsAliq1  += aImprime[nY][15]
			 nImp1     += aImprime[nY][16]
			 nBsAliq2  += aImprime[nY][17]
			 nImp2     += aImprime[nY][18]
			 nValDocD  := (nImp1 + nImp2)
			
			 nCont++

		 Next
		       
         // Impressao conforme preenchimento da pergunta "Observacao"
         If !Empty(mv_par19)
	         cObslin1 += " / " + Upper(mv_par19)
	     Endif
	     
	     If !Empty(mv_par20)
	        cObslin1 += " " + Upper(mv_par20)
	     Endif

         If !Empty(mv_par21)
	         cObslin1 += " " + Upper(mv_par21)
	     Endif                               
		            
	     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	     //³ Imprime o Cabecalho - verifica se o rodape cabe na pagina    ³
	     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	     If ( nLin + 18 > 55 .Or. nLin == 0 )
		   	 nFeixe++
			 Cab(cAliasSF3,@nLin,aLay,cMes,nMes,nAno,lQuebra,nAliq1,@nPagina,@nFeixe,nAliq2)
	     EndIf

         //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		 //³Imprime o Rodape                                              ³
	     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	     If (lQuebra .AND. nAliquota <> (cAliasSF3)->F3_ALIQICM) .OR. (!lQuebra .AND. (cAliasSF3)->(Eof())) .OR. (cAliasSF3)->(Eof())
	       	Rod(cAliasSF3,@nLin,aLay,cMes,nMes,nAno,lQuebra,@nAliquota,@nPagina,@nFeixe,@nValDoc1,@nValDoc2,@nValDocD,;
		  		@nBsAliq1,@nImp1,nNumGPr,dDataPr,cBancoPr,nNumGRet,dDataRet,cBancoRet,cObslin1,;
	        	cObslin2,cObslin3,cObslin4,@nBsAliq2,@nImp2,@nValDocIs,aPonto)
	 			lRodape := .T.
         EndIF
		 
		 lCond:= IIF(lQuebra .And. mv_par18 == 1 ,nAliquota==(cAliasSF3)->F3_ALIQICM,.T.)

	Endif
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exclui o arquivo temporario³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lMapResumo
	MaXRExecArq(2,cArqTmpMP)
	cAliasSf3 := cArqBkpQry
	DbSelectArea(cAliasSF3)
EndIf		


If mv_par18 == 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprime o Rodape                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lRodape .And.(cAliasSF3)->(Eof()) .And. lHouveMov .And. nCont<>0
		Rod(cAliasSF3,@nLin,aLay,cMes,nMes,nAno,lQuebra,@nAliquota,@nPagina,@nFeixe,@nValDocA,@nValDocC,@nValDocD,;
			@nBaseCalc,@nImpIncid,nNumGPr,dDataPr,cBancoPr,nNumGRet,dDataRet,cBancoRet,cObslin1,;
			cObslin2,cObslin3,cObslin4,@nBsAliq2,@nImp2,@nValDocIs,aPonto)
	 	lRodape := .T.
	Endif
	
	// Sem movimentacao no periodo
	If !lHouveMov .Or. nCont==0
		Cab(cAliasSF3,@nLin,aLay,cMes,nMes,nAno,lQuebra,nAliquota,@npagina,@nFeixe,@nAliq2)

		If Empty(nDeduz) .And. Empty(nBasRet) 
			FmtLin(,aLay[13],,,@nLin)
			FmtLin(,aLay[34],,,@nLin)			
		Endif
	
	    While nLin <= 39
		    FmtLin(,aLay[13],,,@nLin)
		    FmtLin({,,,,,,,,,,},aLay[14],,,@nLin)
		EndDo
		
	    FmtLin(,aLay[15],,,@nLin)
		FmtLin({TransForm(nValDocA,"@e 999,999,999.99"),TransForm(nValDocC,"@e 999,999,999.99"),TransForm(nValDocD,"@e 999,999,999.99")},aLay[16],,,@nLin)
		FmtLin(,aLay[17],,,@nLin)
		FmtLin({nDeduz,nAliqRet,nBasRet},aLay[18],,,@nLin)
		FmtLin(,aLay[19],,,@nLin)
		FmtLin({TransForm(nBaseCalc,"@e 999,999,999.99")},aLay[20],,,@nLin)										
		FmtLin(,aLay[21],,,@nLin)
		FmtLin({nImpIncid,""},aLay[22],,,@nLin)
		FmtLin(,aLay[23],,,@nLin)
		FmtLin({nValDocA,nNumGPr,dDataPr},aLay[24],,,@nLin)
		FmtLin(,aLay[25],,,@nLin)
		FmtLin({nImpIncid,cBancoPr},aLay[26],,,@nLin)	
		FmtLin(,aLay[27],,,@nLin)
		FmtLin(,aLay[28],,,@nLin)
		FmtLin({Substr((cObslin1),001,72)},aLay[29],,,@nLin)
		FmtLin({Substr((cObslin1),073,72),nNumGRet,dDataRet},aLay[30],,,@nLin)
		FmtLin({Substr((cObslin1),145,72)},aLay[31],,,@nLin)
		FmtLin({Substr((cObslin1),217,72),cBancoRet},aLay[32],,,@nLin)
		FmtLin(,aLay[33],,,@nLin)
	Endif
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprime o Rodape                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lRodape .And.(cAliasSF3)->(Eof()) .And. lHouveMov .And. nCont<>0
		Rod(cAliasSF3,@nLin,aLay,cMes,nMes,nAno,lQuebra,@nAliquota,@nPagina,@nFeixe,@nValDoc1,@nValDoc2,@nValDocD,;
			@nBsAliq1,@nImp1,nNumGPr,dDataPr,cBancoPr,nNumGRet,dDataRet,cBancoRet,cObslin1,;
			cObslin2,cObslin3,cObslin4,@nBsAliq2,@nImp2,@nValDocIs,aPonto)
	 	lRodape := .T.
	Endif
	
	// Sem movimentacao no periodo
	If !lHouveMov .Or. nCont==0

		Cab(cAliasSF3,@nLin,aLay,cMes,nMes,nAno,lQuebra,nAliquota,@npagina,@nFeixe,@nAliq2)
	    
		If Empty(nDeduz) .And. Empty(nBasRet) 
			FmtLin(,aLay[13],,,@nLin)
			FmtLin(,aLay[34],,,@nLin)			
		Endif
	
	    While nLin <= 39
		    FmtLin(,aLay[13],,,@nLin)
		    FmtLin({,,,,,,,,,,},aLay[14],,,@nLin)
		EndDo
		
	    FmtLin(,aLay[15],,,@nLin)
		FmtLin({TransForm(nValDoc1,"@e 999,999,999.99"),TransForm(nValDoc2,"@e 999,999,999.99"),TransForm(nValDocIs,"@e 999,999,999.99"),TransForm(nValDocD,"@e 999,999,999.99")},aLay[16],,,@nLin)
		FmtLin(,aLay[17],,,@nLin)
		FmtLin({nDeduz,nAliqRet,nBasRet},aLay[18],,,@nLin)
		FmtLin(,aLay[19],,,@nLin)
		FmtLin({TransForm(nBsAliq1,"@e 999,999,999.99"),TransForm(nBsAliq2,"@e 999,999,999.99")},aLay[20],,,@nLin)
		FmtLin(,aLay[21],,,@nLin)
		FmtLin({TransForm(nImp1,"@e 999,999,999.99"),TransForm(nImp2,"@e 999,999,999.99")},aLay[22],,,@nLin)
		FmtLin(,aLay[23],,,@nLin)
		FmtLin({nValDoc1+nValDoc2,nNumGPr,dDataPr},aLay[24],,,@nLin)
		FmtLin(,aLay[25],,,@nLin)
		FmtLin({nImp1+nImp2,cBancoPr},aLay[26],,,@nLin)
		FmtLin(,aLay[27],,,@nLin)
		FmtLin(,aLay[28],,,@nLin)
		FmtLin({Substr((cObslin1),001,72)},aLay[29],,,@nLin)
		FmtLin({Substr((cObslin1),073,72),nNumGRet,dDataRet},aLay[30],,,@nLin)
		FmtLin({Substr((cObslin1),145,72)},aLay[31],,,@nLin)
		FmtLin({Substr((cObslin1),217,72),cBancoRet},aLay[32],,,@nLin)
		FmtLin(,aLay[33],,,@nLin)
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exclui as areas de trabalho                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

#IFDEF TOP 
	( cAliasSF3 )->( dbCloseArea() ) 
	dbSelectArea( "SF3" ) 
#ELSE 	
	FErase( cArqInd + OrdBagExt() ) 		
	RetIndex( "SF3" ) 
#ENDIF 	
                 
If lImpTermos .AND. !lEnd
	R914ImpTerm(cPerg)
EndIf
	If lAglFil
		Exit
	EndIf
	
Next

cFilAnt	:= cFilBack
Return( .T. ) 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ R914LayOut  ³ Autor ³ Thiago Galvao      ³ Data ³25/07/03  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ LayOut do Registro de Apuracao de ISS                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR914()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function R914LayOut(aLay)

If mv_par18 == 1
	aLay[01] := STR0008 //	" REGISTRO DE APURACAO DO ISS  RAZAO SOCIAL : ############################################### CNPJ : ################## Pagina : ####"
	aLay[02] := STR0009 //	"   IMPOSTO SOBRE SERVICOS     ENDERECO     : ############################################### Mes  : ##########            Ano : ####"
	aLay[03] := 			"+------+-------------------------------------------------------------------+---------------------------------+---------------------+"
	aLay[04] := STR0010 //	"| Ano  |                     MOVIMENTO ECONOMICO TRIBUTAVEL                |    MOVIMENTO ECONOMICO ISENTO   | SERVICOS EXECUTADOS |"
	aLay[05] := 			"+------+                                                                   |                                 |                     |"
	aLay[06] := STR0011 //	"| #### |                                                                   |         OU NAO TRIBUTAVEL       |  POR TERCEIROS COM  |"
	aLay[07] := 			"+------+-----------------+----------------+----------------+---------------+----------------+----------------+                     |"
	aLay[08] := STR0012	  //"| Mes  |  Notas Fiscais  | Aliquota ##### | Notas Fiscais  | Aliquota      |  Notas Fiscais |                | RETENCAO DO IMPOSTO |"
	aLay[09] := 			"+------+                 +----------------+                +---------------+                +----------------+                     |"
	aLay[10] := STR0013 //	"| ##   |    Emitidas     | Codigo Fiscal  |   Emitidas     | Codigo Fiscal |   Emitidas     | Codigo Fiscal  |                     |"
	aLay[11] := 			"+------+-----------+-----+----------------+--------+-------+---------------+---------+------+----------------+---------------------+"
	aLay[12] := STR0014  // "|      | Numero    |Serie| R$             | Numero | Serie | R$            | Numero  |Serie | R$             | R$                  |"
	aLay[13] := 			"+------+-----------+-----+----------------+--------+-------+---------------+---------+------+----------------+---------------------+"
	aLay[14] := 			"| ##   | ######### | ### | ############## |        |       |               |#########| ###  | ############## |    ##############   |"
	aLay[15] := 			"+------+-----------+-----+----------------+--------+-------+---------------+---------+------+----------------+---+-----------------+"
	aLay[16] := STR0015  // "|      |  SOMA     | (A) | ############## |  SOMA  |  (B)  |               |  SOMA   |  (C) | ############## |(D)| ##############  |"
	aLay[17] := 			"+------+-----------+-----+----------------+--------+-------+---------------+---------+------+----------------+---+-----------------+"
	aLay[18] := STR0016 //	"|       DEDUCOES         | ############## |          IMPOSTO RETIDO POR TERCEIROS - ALIQUOTA ######          |(G)| ##############  |"
	aLay[19] := 			"+------------------------+----------------+--------------------------------+---------------------------------+---+-----------------+"
	aLay[20] := STR0017 //	"|    BASE DE CALCULO     | ############## |                                |                  RECOLHIMENTOS                        |"
	aLay[21] := 			"+------------------+-----+----------------+------------+---+---------------+-------------------------------------------------------+"
	aLay[22] := STR0018 //	"| IMPOSTO INCIDENTE| (E) | ############## |            |(F)|               | IMPOSTO PROPRIO ( E + F )                             |"
	aLay[23] := 			"+------+-----------+-----+----------------+--------+---+---+---------------+-------------------------------------------------------+"
	aLay[24] := STR0019 //	"|TOTAIS| Movimento Economico Tributavel   |(A + B) |       | ##############| GUIA N : ##########               DE: ##/##/##        |"
	aLay[25] := 			"|------+----------------------------------+--------+-------+---------------+-------------------------------------------------------+"
	aLay[26] := STR0020 //	"|      | Imposto a Recolher               |(E + F) |       | ##############| BANCO  : #####################################        |"
	aLay[27] := 			"|------+----------------------------------+--------+-------+---------------+-------------------------------------------------------+"
	aLay[28] := STR0021 //	"|Observacoes:                                                              | IMPOSTO RETIDO POR TERCEIROS                          |"
	aLay[29] := STR0022 //	"| ######################################################################## +-------------------------------------------------------+"
	aLay[30] := STR0023 //	"| ######################################################################## | GUIA N: ##########                DE: ##/##/##        |"
	aLay[31] := STR0024 //	"| ######################################################################## +-------------------------------------------------------+"
	aLay[32] := STR0025 //	"| ######################################################################## | BANCO : ######################################        |"
	aLay[33] := 			"+--------------------------------------------------------------------------+-------------------------------------------------------+"
	aLay[34] := STR0026 //	"|       *** NAO HOUVE MOVIMENTO ***       |        |       |               |        |       |                |                     |"
Else
	aLay[01] := STR0028 //" REGISTRO DE APURACAO DO ISS  RAZAO SOCIAL : ###############################################                                          CNPJ : ################## Pagina : ####"
	aLay[02] := STR0029 //"   IMPOSTO SOBRE SERVICOS     ENDERECO     : ###############################################                                          Mes  : ##########            Ano : ####"
	aLay[03] :="+------+----------------------------------------------------------------------------------------------+------------------------------------------------+---------------------+"
	aLay[04] := STR0030 //"| Ano  |                     MOVIMENTO ECONOMICO TRIBUTAVEL                                           |    MOVIMENTO ECONOMICO ISENTO                  | SERVICOS EXECUTADOS |"
	aLay[05] :="+------+                                                                                              |                                                |                     |"
	aLay[06] := STR0031 //"| #### |                                                                                              |         OU NAO TRIBUTAVEL                      |  POR TERCEIROS COM  |"
	aLay[07] :="+------+-----------------------+----------------------+-----------------------+-----------------------+-----------------------+------------------------+                     |"
	aLay[08] := STR0032 //"| Mes  |    Notas Fiscais      | Aliquota #####       |     Notas Fiscais     | Aliquota #####        | Notas Fiscais         |                        | RETENCAO DO IMPOSTO |"
	aLay[09] :="+------+                       +----------------------+                       +-----------------------+                       +------------------------+                     |"
	aLay[10] := STR0033 //"| ##   |      Emitidas         | Codigo Fiscal        |      Emitidas         | Codigo Fiscal         |   Emitidas            | Codigo Fiscal          |                     |"
	aLay[11] :="+------+-----------------------+-----+----------------+-----------------------+-------+---------------+-----------------------+-------+----------------+---------------------+"
	aLay[12] := STR0034 //"|      | Numero                |Serie| R$             | Numero                | Serie | R$            | Numero                | Serie | R$             | R$                  |"
	aLay[13] :="+------+-----------------------+-----+----------------+-----------------------+-------+---------------+-----------------------+-------+----------------+---------------------+"
	aLay[14] := STR0035 //"| ##   | ##################### | ### | ############## | ##################### |  ###  | ##############| ##################### | ###   |  ##############|    ##############   |"
	aLay[15] :="+------+-----------------------+-----+----------------+-----------------------+-------+---------------+-----------------------+-------+----------------+---+-----------------+"
	aLay[16] := STR0036 //"|      |  SOMA                 | (A) | ############## |  SOMA                 |  (B)  | ##############|  SOMA                 |  (C)  |  ##############|(D)| ##############  |"
	aLay[17] :=           "+------+-----------------------+-----+----------------+-----------------------+-------+---------------+-----------------------+-------+----------------+---+-----------------+"
	aLay[18] := STR0037 //"|       DEDUCOES               |       ############## |                                                IMPOSTO RETIDO POR TERCEIROS - ALIQUOTA ######  |(G)| ##############  |"
	aLay[19] :=           "+------------------------------+----------------------+-----------------------------------------------+------------------------------------------------+---+-----------------+"
	aLay[20] := STR0038 //"|    BASE DE CALCULO           |       ############## |                                 ##############|                        RECOLHIMENTOS                                 |"
	aLay[21] :=           "+------------------------------+-----+----------------+---------------------------+---+---------------+----------------------------------------------------------------------+"
	aLay[22] := STR0039 //"| IMPOSTO INCIDENTE            | (E) | ############## |                           |(F)| ##############| IMPOSTO PROPRIO ( E + F )                                            |"
	aLay[23] :=           "+------+-----------------------+-----+----------------+--------+------------------+---+---------------+----------------------------------------------------------------------+"
	aLay[24] := STR0040 //"|TOTAIS| Movimento Economico Tributavel               |(A + B) |                      | ##############| GUIA N : ##########               DE: ##/##/##                       |"
	aLay[25] :=           "|------+----------------------------------------------+--------+----------------------+---------------+----------------------------------------------------------------------+"
	aLay[26] := STR0041 //"|      | Imposto a Recolher                           |(E + F) |                      | ##############| BANCO  : #####################################                       |"
	aLay[27] :=           "|------+----------------------------------------------+--------+----------------------+---------------+----------------------------------------------------------------------+"
	aLay[28] := STR0042 //"|Observacoes:                                                                                         | IMPOSTO RETIDO POR TERCEIROS                                         |"
	aLay[29] := STR0043 //"| ########################################################################                            +----------------------------------------------------------------------+"
	aLay[30] := STR0044 //"| ########################################################################                            | GUIA N: ##########                DE: ##/##/##                       |"
	aLay[31] := STR0045 //"| ########################################################################                            +----------------------------------------------------------------------+"
	aLay[32] := STR0046 //"| ########################################################################                            | BANCO : ######################################                       |"
	aLay[33] :="+-----------------------------------------------------------------------------------------------------+----------------------------------------------------------------------+"
	aLay[34] := STR0047 //"|       *** NAO HOUVE MOVIMENTO ***                   |                       |       |               |                       |       |                |                     |"
Endif
	
Return(.T.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Cab         ³ Autor ³ Thiago Galvao      ³ Data ³25/07/03  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina de Impressão do Cabecaçho do Reg de Apur de ISS     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR914()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function Cab(cAliasSF3,nLin,aLay,cMes,nMes,nAno,lQuebra,nAliquota, nPagina, nFeixe, nAliq2)

Default nAliq2 := 0

	If mv_par18 == 2 .And. nLin > 0
		FmtLin(,aLay[13],,,@nLin)
	Else
		If ( nLin == 60 )
    		FmtLin(,aLay[11],,,@nLin)
 		EndIf
 	Endif
 	
    nLin := 0
    @nLin,000 Psay aValImp(Limite)
    nLin++
    FmtLin({SM0->M0_NOMECOM,Transf(SM0->M0_CGC,"@R 99.999.999/9999-99"),StrZero(nPagina,4)},aLay[01],,,@nLin)
    FmtLin({SM0->M0_ENDENT,cMes,Alltrim(STRZERO(nAno,4))},aLay[02],,,@nLin)                      
    FmtLin(,aLay[03],,,@nLin)
    FmtLin(,aLay[04],,,@nLin)
    FmtLin(,aLay[05],,,@nLin)
    FmtLin({Alltrim(STRZERO(nAno,4))},aLay[06],,,@nLin)
    FmtLin(,aLay[07],,,@nLin)
    
    //Modo de Impressao: 1-Retrato ; 2-Paisagem
    If mv_par18 == 1
	    FmtLin({Iif(!lQuebra,"XXXXX",Transf(nAliquota,"@R 99.99"))},aLay[08],,,@nLin)
	Else
		FmtLin({Transf(nAliquota,"@R 99.99"),Transf(nAliq2,"@R 99.99")},aLay[08],,,@nLin)
	Endif
    
    FmtLin(,aLay[09],,,@nLin)
    FmtLin({Alltrim(STRZERO(nMes,2))},aLay[10],,,@nLin)   	
    FmtLin(,aLay[11],,,@nLin)
    FmtLin(,aLay[12],,,@nLin)
    //
	If (nFeixe==MV_PAR13)
		nPagina	:=	MV_PAR12
		nFeixe  :=	0
	Else
		nPagina++
	Endif
	
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Rod         ³ Autor ³ Luciana P. Munhoz  ³ Data ³30-06-2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina de Impressão do Rodapé do Reg de Apur de ISS        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR914()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Rod(cAliasSF3,nLin,aLay,cMes,nMes,nAno,lQuebra,nAliquota,nPagina,nFeixe,nValDocA,nValDocC,nValDocD,;
         nBaseCalc,nImpIncid,nNumGPr,dDataPr,cBancoPr,nNumGRet,dDataRet,cBancoRet,cObslin1,;
         cObslin2,cObslin3,cObslin4,nBsAliq2,nImp2,nValDocIs,aPonto)
         
Local nAliqRet 	  :=""
Local nBasRet     :=""   
Local nDeduz      :=""

Default nBsAliq2  :=0
Default nImp2     :=0
Default nValDocIs :=0                   
Default aPonto    :={}

If Len(aPonto) > 0
	nAliqRet    :=aPonto[01]
	nBasRet     :=aPonto[02]   
	nDeduz      :=aPonto[03]	
Endif

	While .T.
		While nLin <= 39
	    	FmtLin(,aLay[13],,,@nLin)
	        FmtLin({,,,,,,,,,,},aLay[14],,,@nLin)
		EndDo
	
		If nLin==41
			FmtLin(,aLay[15],,,@nLin)
	        If mv_par18 == 1
		        FmtLin({TransForm(nValDocA,"@e 999,999,999.99"),TransForm(nValDocC,"@e 999,999,999.99"),TransForm(nValDocD,"@e 999,999,999.99")},aLay[16],,,@nLin)
	        Else
		        FmtLin({TransForm(nValDocA,"@e 999,999,999.99"),TransForm(nValDocC,"@e 999,999,999.99"),TransForm(nValDocIs,"@e 999,999,999.99"),TransForm(nValDocD,"@e 999,999,999.99")},aLay[16],,,@nLin)
	        Endif
	        FmtLin(,aLay[17],,,@nLin)
	        FmtLin({nDeduz,nAliqRet,nBasRet},aLay[18],,,@nLin)
	        FmtLin(,aLay[19],,,@nLin)
            If mv_par18 == 1
		        FmtLin({TransForm(nBaseCalc,"@e 999,999,999.99")},aLay[20],,,@nLin)
		    Else
	    		FmtLin({TransForm(nBaseCalc,"@e 999,999,999.99"),TransForm(nBsAliq2,"@e 999,999,999.99")},aLay[20],,,@nLin)
		    Endif    
	        FmtLin(,aLay[21],,,@nLin)
            If mv_par18 == 1
		        FmtLin({nImpIncid,""},aLay[22],,,@nLin)
		    Else
			    FmtLin({TransForm(nImpIncid,"@e 999,999,999.99"),TransForm(nImp2,"@e 999,999,999.99")},aLay[22],,,@nLin)
		    Endif    
	        FmtLin(,aLay[23],,,@nLin)
	        If mv_par18 == 1
		        FmtLin({nValDocA,nNumGPr,dDataPr},aLay[24],,,@nLin)
		    Else
			    FmtLin({nValDocA+nValDocC,nNumGPr,dDataPr},aLay[24],,,@nLin)
		    Endif
	        FmtLin(,aLay[25],,,@nLin)
	        If mv_par18 == 1
		        FmtLin({nImpIncid,cBancoPr},aLay[26],,,@nLin)	
		    Else
			    FmtLin({nImpIncid+nImp2,cBancoPr},aLay[26],,,@nLin)	
		    Endif    
	        FmtLin(,aLay[27],,,@nLin)
	        FmtLin(,aLay[28],,,@nLin)
			FmtLin({Substr((cObslin1),001,72)},aLay[29],,,@nLin)
	  		FmtLin({Substr((cObslin1),073,72),nNumGRet,dDataRet},aLay[30],,,@nLin)
	    	FmtLin({Substr((cObslin1),145,72)},aLay[31],,,@nLin)
	     	FmtLin({Substr((cObslin1),217,72),cBancoRet},aLay[32],,,@nLin)
	      	FmtLin(,aLay[33],,,@nLin)			
	      	nAliquota := (cAliasSF3)->F3_ALIQICM
	      	Exit
	   	Else
	 		While nLin <= 58	 		
	        	FmtLin(,aLay[13],,,@nLin)
	         	FmtLin({,,,,,,,,,,},aLay[14],,,@nLin)		   
	   		EndDo                                               				        
	   	    FmtLin(,aLay[13],,,@nLin)
	        nLin := 0
	        @ nLin,000 Psay aValImp(Limite)
	        nFeixe++
			Cab(cAliasSF3,@nLin,aLay,cMes,nMes,nAno,lQuebra,nAliquota, @nPagina, @nFeixe)
		Endif
	EndDo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Reinicialização das Variaveis                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
	nLin      := 0
    nValdocA  := 0
    nValdocC  := 0
    nValdocD  := 0
    nBaseCalc := 0
    nImpIncid := 0
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ R914ImpTerm() ³ Autor ³ Juan Jose Pereira  ³ Data ³20/10/95³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime termos de Abertura e Encerramento                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR990, MATRISS                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function R914ImpTerm(cPerg)

Local cArqAbert	:=	GetNewPar("MV_MR914AB","")
Local cArqEncer	:=	GetNewPar("MV_MR914EN","")
Local aDriver 	:= 	ReadDriver()         

XFIS_IMPTERM(cArqAbert,cArqEncer,cPerg,aDriver[4])

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³R914Ponto ºAutor  ³Mary C. Hergert     º Data ³  07/23/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna os valores processados pelos pontos de entrada      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Matr914                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R914Ponto(nValDocD,nAliqRet,nBasRet,nDeduz)

Local aRetem	:= {}
Local aPonto	:= {"","",""}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada para verificar as retencoes³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("MT914RET")
	aRetem := ExecBlock("MT914RET",.F.,.F.)
	If Len(aRetem) >= 3
	 	nValDocD 	:= aRetem[01]
	 	nAliqRet 	:= Transform(aRetem[02],"@E 99.99")
	 	nBasRet		:= Transform(aRetem[03],"@e 999,999,999.99")
	 	aPonto[01]	:= nAliqRet
	 	aPonto[02]	:= nBasRet
	Endif
Endif 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada para verificar as deducoes ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("MT914DED")
	nDeduz := Transform(ExecBlock("MT914DED",.F.,.F.),"@e 999,999,999.99")
	aPonto[03]	:= nDeduz
Endif

Return aPonto

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³R914Cupom ºAutor  ³Mary C. Hergert     º Data ³  07/23/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna os valores processados nos cupons fiscais           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Matr914                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R914Cupom()

Local aCupom 	:= {}
Local cAliasSF3 := "SF3"

#IFDEF TOP
	Local cQuery 	:=""
	Local aStru		:= {}      
	Local nX		:= 0
#ELSE
	Local nIndex	:= 0
	Local cArqInd	:= ""
	Local cChave	:= ""
	Local cFiltro	:= ""
#ENDIF

SF2->(dbSetOrder(1))

SF3->(dbSetOrder(1))
ProcRegua(SF3->(LastRec()))

#IFDEF TOP
    If TcSrvType()<>"AS/400"
		cAliasSF3 	:= GetNextAlias() 
		aStru  		:= SF3->(dbStruct())
		cQuery 		:= "SELECT F3_FILIAL, F3_ALIQICM,F3_CFO,F3_BASEICM,F3_ISENICM,F3_OUTRICM,F3_VALCONT,F3_VALICM,F3_NFISCAL,
		cQuery 		+= "F3_SERIE,F3_ENTRADA,F3_DTCANC,F3_OBSERV,F3_CLIEFOR,F3_LOJA,F3_ALIQICM,"+SerieNfId('SF3',3,'F3_SERIE')+" F3_SDOC "
		cQuery 		+= "FROM "+RetSqlName("SF3")+" "
		cQuery 		+= "WHERE F3_FILIAL IN "+cFilSF3+" AND "    
		cQuery 		+= "F3_ESPECIE ='CF'  AND "
		cQuery 		+= "F3_ENTRADA BETWEEN '"+Dtos(dDtIni)+"' AND '"+Dtos(dDtFim)+"' AND "
	   	cQuery 		+= "D_E_L_E_T_=' ' "
		cQuery 		+= "ORDER BY F3_ENTRADA,"+SerieNfId('SF3',3,'F3_SERIE')+",F3_NFISCAL"
	    
	    cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF3,.T.,.T.)
		For nX := 1 To len(aStru)
			If aStru[nX][2] <> "C" .And. FieldPos(aStru[nX][1])<>0
			   TcSetField(cAliasSF3,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
			EndIf
		Next nX
		dbSelectArea(cAliasSF3)
	Else
#ENDIF
		nIndex	:=	RetIndex("SF3")
		cArqInd	:=	CriaTrab(NIL,.F.)
	  	cChave	:=	"DTOS(F3_ENTRADA)+"+SerieNfId('SF3',3,'F3_SERIE')+"+F3_NFISCAL"
		cFiltro :=  "F3_FILIAL $ "+cFilSF3+" .AND. "
		cFiltro	+=	"ALLTRIM(F3_ESPECIE)=='CF' .AND. " 
		cFiltro	+=	"dtos(F3_ENTRADA) >='"+dtos(dDtIni)+"' .and. dtos(F3_ENTRADA)<='"+dtos(dDtFim)+"'"
		IndRegua("SF3",cArqInd,cChave,,cFiltro,STR0007) //"Selecionando Registros..."
		dbGotop()
		
	    dbSelectArea(cAliasSF3)
	    ProcRegua(LastRec())
	    dbGoTop()

#IFDEF TOP
	Endif    
#ENDIF 
     
Do While !(cAliasSF3)->(Eof())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Apenas armazena os cupons em que foram emitidas as notas sobre cupom³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SF2->(dbSeek((cAliasSF3)->(F3_FILIAL+F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA))) .And.;
		!Empty(SF2->F2_NFCUPOM)
	    aAdd(aCupom,{(cAliasSF3)->F3_NFISCAL,;
	    SerieNfId(cAliasSF3,2,'F3_SERIE'),;
	    (cAliasSF3)->F3_CLIEFOR,;
	    (cAliasSF3)->F3_LOJA,;
	    (cAliasSF3)->F3_BASEICM,;
	    (cAliasSF3)->F3_ISENICM,;
	    (cAliasSF3)->F3_OUTRICM,;
	    (cAliasSF3)->F3_VALCONT,;
	    (cAliasSF3)->F3_VALICM,;
	    (cAliasSF3)->F3_ALIQICM})
	Endif

	(cAliasSF3)->(dbSkip())
Enddo

Return aCupom
