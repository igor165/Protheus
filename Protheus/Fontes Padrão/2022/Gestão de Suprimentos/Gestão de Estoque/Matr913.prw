#INCLUDE "MATR913.CH"
#DEFINE CHRCOMP If(aReturn[4]==1,15,18)

#DEFINE TPR_POS 1
#DEFINE TPC_POS 2
#DEFINE TSC_POS 3
#DEFINE TRC_POS 4
#DEFINE TRS_POS 5
#DEFINE TRB_POS 6
#DEFINE MVN_POS 7
#DEFINE TMM_POS 8
#DEFINE TMT_POS 9
#DEFINE TMA_POS 10
#DEFINE MVI_POS 11
#DEFINE TRA_POS 12
#DEFINE TRI_POS 13
#DEFINE AMZ_POS 14
#DEFINE TER_POS 15
#DEFINE TNF_POS 16
#DEFINE NFI_POS 17
#DEFINE TUP_POS 18
#DEFINE TUF_POS 19
#DEFINE TUC_POS 20
#DEFINE TFB_POS 21
#DEFINE TTN_POS 22
#DEFINE TCC_POS 23
#DEFINE TTM_POS 24 

#DEFINE ALIAS_POS 3
  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ MATR913  ³ Autor ³ Eduardo Ju	        ³ Data ³ 02.06.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Mapas de Controle de Produtos Quimicos                      ³±±
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
*/
Function Matr913()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿               
//³Define Variaveis                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local Titulo  := STR0001 //"Mapas de Controle de Produtos Quimicos"             
Local cDesc1  := STR0002 //"Este programa ira imprimir o Controle e Fiscalizacao"  
Local cDesc2  := STR0003 //"sobre Produtos Quimicos que possam ser utilizados   "  
Local cDesc3  := STR0004 //"como materia-prima"                                   

Local cAlias  := "SD1"  // Alias utilizado na Filtragem
Local lDic    := .F. 	// Habilita/Desabilita Dicionario
Local lComp   := .F. 	// Habilita/Desabilita o Formato Comprimido/Expandido
Local lFiltro := .F. 	// Habilita/Desabilita o Filtro
Local wnrel   := "MATR913"  // Nome do Arquivo utilizado no Spool
Local nomeprog:= "MATR913"  // nome do programa

Private Tamanho := "G" // P/M/G
Private Limite  := 220 // 80/132/220
Private aOrdem  := {}  // Ordem do Relatorio
Private cPerg   := "MTR913"  // Pergunta do Relatorio
Private aReturn := { STR0005, 1,STR0006, 1, 2, 1, "",1 } //"Zebrado"###"Administracao"
						//[1] Reservado para Formulario
						//[2] Reservado para N§ de Vias
						//[3] Destinatario
						//[4] Formato => 1-Comprimido 2-Normal
						//[5] Midia   => 1-Disco 2-Impressora
						//[6] Porta ou Arquivo 1-LPT1... 4-COM1...
						//[7] Expressao do Filtro
						//[8] Ordem a ser selecionada
						//[9]..[10]..[n] Campos a Processar (se houver)

Private lEnd     := .F. // Controle de cancelamento do relatorio
Private nPagina  := 1   // Contador de Paginas
Private nLastKey := 0   // Controla o cancelamento da SetPrint e SetDefault
Private nModelo := 0

If DtoS(dDataBase) >= '20190901'
	MATR913R4()
	Return .T.
EndIf

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variaveis utilizadas para parametros    		³
//³mv_par01		// Data Inicial?                ³
//³mv_par02		// Data Final?                  ³
//³mv_par03		// Do Grupo?                    ³
//³mv_par04		// Ate o Grupo?                 ³
//³mv_par05		// Nome do Responsavel?         ³
//³mv_par06		// CPF do Responsavel?          ³
//³mv_par07		// RG/Org. Exp. do Responsavel? ³
//³mv_par08		// UF do Responsavel?           ³
//³mv_par09   	// CLF?                     	³
//³mv_par10   	// Atividade?               	³
//³mv_par11   	// Observacao?              	³
//³mv_par12   	// Modelo do Mapa?          	³
//³				1- Anexo XI-A               	³
//³				2- Anexo XI-B               	³
//³				3- Anexo XI-C               	³
//³				4- Anexo XI-D               	³
//³				5- Anexo XI-E               	³
//³mv_par13   	// Imprime Anexo XI-G ?     	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
Pergunte(cPerg,.F.)      

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Envia para a SetPrinter                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel:=SetPrint(cAlias,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,lDic,aOrdem,lComp,Tamanho,lFiltro)
If ( nLastKey==27 )
	dbSelectArea(cAlias)
	dbSetOrder(1)
	dbClearFilter()
	Return
Endif
SetDefault(aReturn,cAlias)
If ( nLastKey==27 )
	dbSelectArea(cAlias)
	dbSetOrder(1)
	dbClearFilter()
	Return
Endif

RptStatus({|lEnd| ImpDet(@lEnd,wnRel,cAlias,nomeprog,Titulo)},Titulo)

Return(.T.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ ImpDet   ³ Autor ³ Eduardo Ju            ³ Data ³02.06.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Controle de Fluxo do Relatorio.                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ImpDet(lEnd,wnrel,cAlias,nomeprog,Titulo)

Local aTRBs		:= {}

Local cPerg		:= "MAPAS"
Local cGrpDe    := ""
Local cGrpAte   := ""
Local cProdDe	:= ""
Local cProdAte	:= ""
Local cCPF      := ""
Local cRG       := ""
Local cCLF      := ""
Local cAtividade:= ""                                  
Local cObs      := ""

Local dDtIni	:= cTod("//")
Local dDtFim	:= cTod("//")

Local li  		:= 100 // Contador de Linhas
Local lImp		:= .F. // Indica se algo foi impresso

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recebe os valores dos Parametros                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dDtIni		:= mv_par01
dDtFim		:= mv_par02
cGrpDe 		:= mv_par03
cGrpAte		:= mv_par04
cProdDe		:= ""
cProdAte	:= Replicate("Z",TamSX3("B1_COD")[01])
cCPF      	:= mv_par06
cRG       	:= Alltrim(mv_par07)+"-"+mv_par08
cCLF      	:= mv_par09
cAtividade	:= mv_par10
cObs      	:= mv_par11
cRespon		:= mv_par05
nImpAnXI     := mv_par13                                                          

// Modelo a ser impresso
If nImpAnXI == 1       
	nModelo := mv_par12
Else //Anexo XI-G
	nModelo := 6
Endif	

If !(Pergunte(cPerg,.T.))
	Return (.F.)
EndIf

If nModelo == 1	
	cProdDe := mv_par16
	cProdAte := mv_par17	
EndIf     

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gera arquivos temporarios                                               ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTRBs := MapasArqs(dDtIni,dDtFim)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gera arquivos de estoque                                                ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MapasEst(1,dDtIni,dDtFim,cGrpDe,cGrpAte,cProdDe,cProdAte)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processa Entradas                                                       ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MapasMov("E",.T.,dDtIni,dDtFim,cGrpDe,cGrpAte,cProdDe,cProdAte)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processa Saidas                                                         ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MapasMov("S",.T.,dDtIni,dDtFim,cGrpDe,cGrpAte,cProdDe,cProdAte)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processa Outras Informacoes                                             ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MapasMov("O",.T.,dDtIni,dDtFim,cGrpDe,cGrpAte,cProdDe,cProdAte)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exclui arquivos de estoque gerados                                      ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MapasEst(2,dDtIni,dDtFim,cGrpDe,cGrpAte,cProdDe,cProdAte)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa relatorio conforme modelo selecionado pelo Usuario   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//RptStatus({|lEnd| R913Impr(@lEnd,wnRel,cAlias,Tamanho,nModelo,cCPF,cRG,cCLF,cAtividade,cObs,cRespon)},titulo)  
R913Impr(@lEnd,wnRel,cAlias,Tamanho,nModelo,cCPF,cRG,cCLF,cAtividade,cObs,cRespon)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exclui arquivos temporarios criados                                     ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MapasDel(aTRBs)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura Ambiente                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Set Device To Screen
Set Printer To
If ( aReturn[5] = 1 )
	dbCommitAll()
	OurSpool(wnrel)
Endif
MS_FLUSH()
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³R913Impr  ³ Autor ³ Mary C. Hergert       ³ Data ³09/01/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Imprime os anexos do relatorio de Produtos Quimicos Contro- ³±±
±±³          ³lados atraves dos temporarios carregados no fonte Mapas.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpL1 = Controle de interrupcao pelo usuario                ³±±
±±³          ³ExpC2 = Nome do arquivo em spool                            ³±±
±±³          ³ExpC3 = Alias principal                                     ³±±
±±³          ³ExpC4 = Tamenho do relatorio (PMG)                          ³±±
±±³          ³ExpN5 = Modelo escolhido nas perguntas da rotina            ³±±
±±³          ³ExpC6 = CPF do responsavel pela empresa                     ³±±
±±³          ³ExpC7 = RG do responsavel pela empresa                      ³±±
±±³          ³ExpC8 = Numero do cetificado de licenca de funcionamento    ³±±
±±³          ³ExpC9 = Atividade principal da empresa                      ³±±
±±³          ³ExpCa = Observacoes gerais a serem impressas                ³±±   
±±³          ³ExpCb = Responsavel pelas informacoes                       ³±±   
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Matr913                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function R913Impr(lEnd,wnRel,cAlias,Tamanho,nModelo,cCPF,cRG,cCLF,cAtividade,cObs,cRespon) 

Local aL		:= Array(121)
Local aDados	:= Array(28)

Local cGrupo	:= ""
Local cMesAno	:= ""
Local cCPFCGC 	:= ""
Local cCliefor	:= ""
Local cCGCTransp:= ""
Local cDia		:= ""
Local cPais		:= ""
Local cES		:= ""

Local nLin		:= 0
Local aImprime  :={}   
Local nPos		:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprime Anexo XI-A³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nModelo == 1
   dbSelectArea("TPF")
   TPF->(DBSetOrder(2)) 
   dbSelectArea("TSP")
   TSP->(DBSetOrder(1))  
	
	aL := Array(121)
	R913LayOut(aL)
	dbSelectArea("TPR")
	TPR->(dbGotop())
	SetRegua(TPR->(LastRec()))
	
	While !TPR->(Eof()) .And. !lEnd

		IncRegua()
		If Interrupcao(@lEnd)
			Loop
		Endif
                                                                                                             
		cGrupo := TPR->GRUPO
		cMesAno:= Strzero(Month(TPR->EMISS),2)+"/"+Strzero(Year(TPR->EMISS),4)
		
		If nLin==0
			R913Cabec(aL,@nLin,@nPagina,cMesAno,cCLF,cGrupo,cAtividade)	
		Endif                  
	  
		aDados[01] := Transform(TPR->NCM,"@R 9999.99.99")
		aDados[02] := SubStr(TPR->DESCR_PROD,1,30)
		aDados[03] := Transform(TPR->CONCENT,"@R 999.99")
	   	aDados[04] := Transform(TPR->DENSID,"@R 999.99")
		aDados[05] := TPR->QT_EST_ANT
		aDados[06] := TPR->QT_PRODUZ
		aDados[07] := TPR->QT_TRANSF  
		aDados[08] := TPR->QT_UTILIZ    
		aDados[09] := TPR->QT_COMPRAS 
		aDados[10] := TPR->QT_VENDAS  
		aDados[11] := TPR->QT_RECICLA 
		aDados[12] := TPR->QT_REAPROV
		aDados[13] := TPR->QT_IMPORT
		aDados[14] := TPR->QT_EXPORT 
		aDados[15] := TPR->QT_PERDAS   
		aDados[16] := TPR->QT_EVAPORA  
		aDados[17] := TPR->QT_ENT_DIV   
		aDados[18] := TPR->QT_SAI_DIV 
		aDados[19] := TPR->QT_EST_ATU   
		aDados[20] := TPR->UN	
		
		FmtLin({},aL[17],,,@nLin) 
		FmtLin({aDados[1],aDados[2],aDados[3],aDados[4]},aL[18],,,@nLin)
		FmtLin({},aL[19],,,@nLin) 
		FmtLin({aDados[5],aDados[6],aDados[7],aDados[8]},aL[20],,,@nLin)
		FmtLin({},aL[21],,,@nLin) 
		FmtLin({aDados[9],aDados[10],aDados[11],aDados[12]},aL[22],,,@nLin)
		FmtLin({},aL[23],,,@nLin) 	
		FmtLin({aDados[13],aDados[14],aDados[15],aDados[16]},aL[24],,,@nLin)
		FmtLin({},aL[25],,,@nLin) 
		FmtLin({aDados[17],aDados[18],aDados[19],aDados[20]},aL[26],,,@nLin)
		FmtLin({},aL[27],,,@nLin)
  
		If TPF->(MsSeek(TPR->COD_PROD))  
			Do While !TPF->(Eof()).And. Alltrim(TPF->CODIGO) == Alltrim(TPR->CODPESQ)
			      aDados[21]:= Transform(TPF->NCM,"@R 9999.99.99") // NCM Prod Final
			      aDados[22]:= TPF->CODPESQ   						// Prod Final
			      aDados[23]:= TPF->QTDE   							// Quantidade
			      aDados[24]:= Transform(TPF->DENSID,"@R 999.99") 	// Densidade
			      aDados[25]:= TPF->UN        					    // Unidade   			      
			      If nLin >= 69 
					R913Cabec(aL,@nLin,@nPagina,cMesAno,cCLF,cGrupo,cAtividade)	 
				  EndIf		
				//Imprime
				 FmtLin({aDados[21],aDados[22],aDados[23],aDados[24],aDados[25]},aL[28],,,@nLin)
			     If TSP->(MsSeek(TPF->CODPESQ))
				     Do While !TSP->(Eof()) .And. TSP->CODPESQ == TPF->CODPESQ .And. TPF->CODIGO == TPR->CODPESQ     				     
				          nPos:= Ascan(aImprime,{|x| x==TSP->CODIGO})
				          IF  nPos == 0   
						      aDados[26]:= Transform(TSP->NCM,"@R 9999.99.99")      //NCM Substancia
						      aDados[27]:= SubStr(TSP->DESCR_PROD,1,30)             //Descricao Substancia
						      aDados[28]:= Transform(TSP->CONCENT,"@R 999.99")      //Concentracao
						      //Imprime
						      FmtLin({},al[30],,,@nLin)	  
						      FmtLin({aDados[26], aDados[27], aDados[28]},al[31],,,@nLin)
						      FmtLin({},al[32],,,@nLin)        					              
						      AADD(aImprime,TSP->CODIGO)
						   Endif   
					  	TSP->(dbSkip())          
				      EndDo
				      aImprime:= {}     
			      EndIf  
			   TPF->(DbSkip())
			EndDo
		EndIf    
		TPR->(dbSkip())
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime Rodape do Relatorio                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If TPR->(Eof())
			If nLin >= 69 
				R913Cabec(aL,@nLin,@nPagina,cMesAno,cCLF,cGrupo,cAtividade)
				FmtLin({},aL[34],,,@nLin)
				FmtLin({},aL[35],,,@nLin)
				FmtLin({cObs,cRespon,cCPF},aL[36],,,@nLin)
				FmtLin({},aL[37],,,@nLin)
				FmtLin({},aL[38],,,@nLin)
				FmtLin({cRg},aL[39],,,@nLin)
				FmtLin({},aL[40],,,@nLin)
				nPagina++
			Else
				FmtLin({},aL[34],,,@nLin)
				FmtLin({},aL[35],,,@nLin)
				FmtLin({cObs,cRespon,cCPF},aL[36],,,@nLin)
				FmtLin({},aL[37],,,@nLin)
				FmtLin({},aL[38],,,@nLin)
				FmtLin({cRg},aL[39],,,@nLin)
				FmtLin({},aL[40],,,@nLin)
				nPagina++ 	 
			EndIf		
		Endif
		If nLin > 58
			FmtLin({},al[33],,,@nLin)
			nLin:= 0
		EndIf		
	EndDo 

Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprime Anexo XI-B³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nModelo == 2

	aL := Array(121)
	R913LayOut(aL)
	dbSelectArea("TMV")
	TMV->(dbGotop())
	SetRegua(TMV->(LastRec()))
	While !TMV->(Eof()) .And. !lEnd
	
		IncRegua()
		If Interrupcao(@lEnd)
			Loop
		Endif
		
		cGrupo 		:= TMV->GRUPO
		cMesAno		:= Strzero(Month(TMV->EMISS),2)+"/"+Strzero(Year(TMV->EMISS),4)
		cCPFCGC 	:= Transform(TMV->CNPJ_CF,PicPesFJ(Iif(Len(Alltrim(TMV->CNPJ_CF)) < 14,"F","J")))
		cCliefor	:= TMV->CLIEFOR
		cCGCTransp 	:= Transform(TMV->CNPJ_T,PicPesFJ(Iif(Len(alltrim(TMV->CNPJ_T)) < 14,"F","J")))
		cDia		:= Strzero(Day(TMV->EMISS),2)

		If nLin==0
			R913Cabec(aL,@nLin,@nPagina,cMesAno,cDia,cCPFCGC,cCliefor)	
		Endif                  
	  
		aDados[01] 	:= cDia
		aDados[02] 	:= TMV->CFOP
		aDados[03] 	:= Transform(TMV->NCM,"@R 9999.99.99")
		aDados[04] 	:= SubStr(TMV->DESCR_PROD,1,30)
	   	aDados[05] 	:= Transform(TMV->CONCENT,"@R 999.99")
		aDados[06] 	:= Transform(TMV->QTDE,"@R 99999999.99")
	   	aDados[07] 	:= SubStr(TMV->UN,1,2)
		aDados[08] 	:= SubStr(TMV->NFISCAL,1,TamSX3("F2_DOC")[1]) 
	   	aDados[09]	:= cCPFCGC
		aDados[10]	:= cCGCTransp
		
		FmtLin(@aDados,aL[45],,,@nLin)
		
		TMV->(dbSkip())
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime Rodape do Relatorio                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		If TMV->(Eof())
			If nLin >= 51 
				FmtLin({},aL[46],,,@nLin)
				R913Cabec(aL,@nLin,@nPagina,cMesAno,cDia,cCPFCGC,cCliefor)
				FmtLin({},aL[47],,,@nLin)
				FmtLin({},aL[48],,,@nLin)
				FmtLin({},aL[49],,,@nLin) 
				FmtLin({cObs,cRespon,cCPF},aL[50],,,@nLin)
				FmtLin({},aL[51],,,@nLin)
				FmtLin({},aL[52],,,@nLin)
				FmtLin({cRg},aL[53],,,@nLin)
				FmtLin({},aL[54],,,@nLin)
				nPagina++
			Else
				FmtLin({},aL[46],,,@nLin)
				FmtLin({},aL[47],,,@nLin)
				FmtLin({},aL[48],,,@nLin)
				FmtLin({},aL[49],,,@nLin) 
				FmtLin({cObs,cRespon,cCPF},aL[50],,,@nLin)
				FmtLin({},aL[51],,,@nLin)
				FmtLin({},aL[52],,,@nLin)
				FmtLin({cRg},aL[53],,,@nLin)
				FmtLin({},aL[54],,,@nLin)
				nPagina++
			EndIf				
		Endif
		If nLin > 58
			FmtLin({},aL[46],,,@nLin)
			nLin:= 0
		EndIf		
	EndDo

Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprime Anexo XI-C³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nModelo == 3

	aL := Array(121)
	R913LayOut(aL)
	dbSelectArea("TIE")
	TIE->(dbGotop())
	SetRegua(TIE->(LastRec()))

	While !TIE->(Eof()) .And. !lEnd

		IncRegua()
		If Interrupcao(@lEnd)
			Loop
		Endif
	
		cMesAno		:= Strzero(Month(TIE->EMISS),2)+"/"+Strzero(Year(TIE->EMISS),4)
		cCGCTransp 	:= Transform(TIE->CNPJ_T,PicPesFJ(Iif(Len(alltrim(TIE->CNPJ_T)) < 14,"F","J")))
		cIE 		:= TIE->IMP_EXP
		cLiRe		:= TIE->LI_RE
			
		// Verifica o nome do pais
		SYA->(dbSetOrder(1))
		SYA->(MsSeek(xFilial("SYA")+TIE->PAIS))
		cPais := SYA->YA_DESCR
			
		If nLin==0
			R913Cabec(aL,@nLin,@nPagina,cMesAno,cIE,cLiRe,cCGCTransp)	
		Endif                  
	  
		aDados[01] := TIE->IMP_EXP
		aDados[02] := Transform(TIE->NCM,"@R 9999.99.99")
		aDados[03] := SubStr(TIE->DESCR_PROD,1,30)
	   	aDados[04] := Transform(TIE->CONCENT,"@R 999.99")
		aDados[05] := Transform(TIE->QTDE,"@R 99999999.99")
	   	aDados[06] := SubStr(TIE->UN,1,2)
	   	aDados[07] := TIE->LI_RE
		aDados[08] := SubStr(TIE->NFISCAL,1,TamSX3("F2_DOC")[1])
		aDados[09] := SubStr(TIE->NOME_IE,1,40)
	   	aDados[10] := SubStr(cPais,1,25)
		aDados[11] := cCGCTransp
		
		FmtLin(@aDados,aL[64],,,@nLin)
		
		TIE->(dbSkip())
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime Rodape do Relatorio                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If TIE->(Eof())
			If nLin >= 51
				FmtLin({},aL[65],,,@nLin)
				R913Cabec(aL,@nLin,@nPagina,cMesAno,cIE,cLiRe,cCGCTransp)
				FmtLin({},aL[66],,,@nLin)
				FmtLin({},aL[67],,,@nLin)
				FmtLin({},aL[68],,,@nLin) 
				FmtLin({cObs,cRespon,cCPF},aL[69],,,@nLin)
				FmtLin({},aL[70],,,@nLin)
				FmtLin({},aL[71],,,@nLin)
				FmtLin({cRg},aL[72],,,@nLin)
				FmtLin({},aL[73],,,@nLin)
				nPagina++
			Else
				FmtLin({},aL[65],,,@nLin)
				FmtLin({},aL[66],,,@nLin)
				FmtLin({},aL[67],,,@nLin)
				FmtLin({},aL[68],,,@nLin) 
				FmtLin({cObs,cRespon,cCPF},aL[69],,,@nLin)
				FmtLin({},aL[70],,,@nLin)
				FmtLin({},aL[71],,,@nLin)
				FmtLin({cRg},aL[72],,,@nLin)
				FmtLin({},aL[73],,,@nLin)
				nPagina++	
			EndIf		
		Endif
		If nLin > 58
			FmtLin({},aL[65],,,@nLin)
			nLin:= 0
		EndIf		
	EndDo

Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprime Anexo XI-D³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nModelo == 4

	aL := Array(121)
	R913LayOut(aL)
	dbSelectArea("TAM")
	TAM->(dbGotop())
	SetRegua(TAM->(LastRec()))
	
	While !TAM->(Eof()) .And. !lEnd

		IncRegua()
		If Interrupcao(@lEnd)
			Loop
		Endif

		cMesAno	:= Strzero(Month(TAM->EMISS),2)+"/"+Strzero(Year(TAM->EMISS),4)
		cCPFCGC	:= Transform(TAM->CNPJ,PicPesFJ(Iif(Len(Alltrim(TAM->CNPJ)) < 14,"F","J")))		
		
		If nLin==0
			R913Cabec(aL,@nLin,@nPagina,cMesAno)	
		Endif                  
			
		aDados[1] := Transform(TAM->NCM,"@R 9999.99.99")
		aDados[2] := SubStr(TAM->DESCR_PROD,1,30)
	   	aDados[3] := Transform(TAM->CONCENT,"@R 999.99") 
	   	aDados[4] := SubStr(TAM->UN,1,2)
	   	aDados[5] := TAM->QT_EST_ANT
	   	aDados[6] := TAM->QT_EST_ATU
		aDados[7] := cCPFCGC
		
		FmtLin(@aDados,aL[83],,,@nLin)
		
		TAM->(dbSkip())
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime Rodape do Relatorio                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Eof()
			If nLin >= 51
				FmtLin({},aL[84],,,@nLin)
				R913Cabec(aL,@nLin,@nPagina,cMesAno)
				FmtLin({},aL[85],,,@nLin)
				FmtLin({},aL[86],,,@nLin)
				FmtLin({},aL[87],,,@nLin) 
				FmtLin({cObs,cRespon,cCPF},aL[88],,,@nLin)
				FmtLin({},aL[89],,,@nLin)
				FmtLin({},aL[90],,,@nLin)
				FmtLin({cRg},aL[91],,,@nLin)
				FmtLin({},aL[92],,,@nLin)
				nPagina++
			Else
				FmtLin({},aL[84],,,@nLin)
				FmtLin({},aL[85],,,@nLin)
				FmtLin({},aL[86],,,@nLin)
				FmtLin({},aL[87],,,@nLin) 
				FmtLin({cObs,cRespon,cCPF},aL[88],,,@nLin)
				FmtLin({},aL[89],,,@nLin)
				FmtLin({},aL[90],,,@nLin)
				FmtLin({cRg},aL[91],,,@nLin)
				FmtLin({},aL[92],,,@nLin)
				nPagina++
			EndIf				
		Endif
		If nLin > 58
			FmtLin({},aL[84],,,@nLin)
			nLin:= 0
		EndIf		
	EndDo
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprime Anexo XI-E³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nModelo == 5

	aL := Array(121)
	R913LayOut(aL)
	dbSelectArea("TMA")
	TMA->(dbGotop())
	SetRegua(TMA->(LastRec()))
	
	While !TMA->(Eof()) .And. !lEnd
	
		IncRegua()
		If Interrupcao(@lEnd)
			Loop
		Endif
	
		cMesAno		:= Strzero(Month(TMA->EMISS),2)+"/"+Strzero(Year(TMA->EMISS),4)
		cCPFCGC		:= Transform(TMA->CNPJ,PicPesFJ(Iif(Len(Alltrim(TMA->CNPJ)) < 14,"F","J")))		
		cCGCTransp 	:= Transform(TMA->CNPJ_T,PicPesFJ(Iif(Len(alltrim(TMA->CNPJ_T)) < 14,"F","J")))
		cES 		:= TMA->E_S 
		cClieFor	:= SubStr(TMA->CLIEFOR,1,18)
	
		If nLin==0
			R913Cabec(aL,@nLin,@nPagina,cMesAno,cES,cCPFCGC,cCliefor)	
		Endif                  
	  
		aDados[01] := TMA->DIA
		aDados[02] := cES
		aDados[03] := Transform(TMA->NCM,"@R 9999.99.99")
		aDados[04] := SubStr(TMA->RAZSOC,1,30)
	   	aDados[05] := Transform(TMA->CONCENT,"@R 999.99")
		aDados[06] := Transform(TMA->QTDE,"@R 99999999.99")
	   	aDados[07] := SubStr(TMA->UN,1,2)
		aDados[08] := SubStr(TMA->NFISCAL,1,TamSX3("F2_DOC")[1])
	   	aDados[09] := cCPFCGC
		aDados[10] := cCGCTransp
		
		FmtLin(@aDados,aL[102],,,@nLin)
		
		TMA->(dbSkip())
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime Rodape do Relatorio                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If TMA->(Eof())
			If nLin >= 51
				FmtLin({},aL[103],,,@nLin)
				R913Cabec(aL,@nLin,@nPagina,cMesAno,cES,cCPFCGC,cCliefor)
				FmtLin({},aL[104],,,@nLin)
				FmtLin({},aL[105],,,@nLin)
				FmtLin({},aL[106],,,@nLin) 
				FmtLin({cObs,cRespon,cCPF},aL[107],,,@nLin)
				FmtLin({},aL[108],,,@nLin)
				FmtLin({},aL[109],,,@nLin)
				FmtLin({cRg},aL[110],,,@nLin)
				FmtLin({},aL[111],,,@nLin)
				nPagina++
			Else
				FmtLin({},aL[103],,,@nLin)
				FmtLin({},aL[104],,,@nLin)
				FmtLin({},aL[105],,,@nLin)
				FmtLin({},aL[106],,,@nLin) 
				FmtLin({cObs,cRespon,cCPF},aL[107],,,@nLin)
				FmtLin({},aL[108],,,@nLin)
				FmtLin({},aL[109],,,@nLin)
				FmtLin({cRg},aL[110],,,@nLin)
				FmtLin({},aL[111],,,@nLin)
				nPagina++
			Endif		
		Endif
		If nLin > 58
			FmtLin({},aL[103],,,@nLin)
			nLin:= 0
		EndIf		
	EndDo
	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprime Anexo XI-G³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nModelo == 6

	aL := Array(130)
	R913LayOut(aL)

	dbSelectArea("TRE")
	TRE->(dbGotop())
	SetRegua(TRE->(LastRec()))
	
	While !TRE->(Eof()) .And. !lEnd
	
		IncRegua()
	
		If Interrupcao(@lEnd)
			Loop
		Endif
	
		cMesAno		:= Strzero(Month(TRE->EMISS),2)+"/"+Strzero(Year(TRE->EMISS),4)
		cCPFCGC		:= Transform(TRE->CNPJ_CF,PicPesFJ(Iif(Len(Alltrim(TRE->CNPJ_CF)) < 14,"F","J")))		
		cES 		:= TRE->E_S 
		cClieFor	:= SubStr(TRE->CLIEFOR,1,18)
	
		If nLin==0
			R913Cabec(aL,@nLin,@nPagina,cMesAno,cES,cCPFCGC,cCliefor)	
		Endif                  
	  
		aDados[1] := Transform(TRE->NCM,"@R 9999.99.99")
		aDados[2] := Left(TRE->DESCR_PROD,30)
		aDados[3] := Transform(TRE->CONCENT,"@R 999.99")
	    aDados[4] := Left(TRE->UN,2)
		aDados[5] := Transform(TRE->QTDE,"@R 99999999.99")
	    aDados[6] := TRE->DESTINA
		
		FmtLin(@aDados,aL[121],,,@nLin)
		FmtLin({},aL[122],,,@nLin)
			
		TRE->(dbSkip())
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime Rodape do Relatorio                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If TRE->(Eof())
			If nLin >= 51
				R913Cabec(aL,@nLin,@nPagina,cMesAno,cES,cCPFCGC,cCliefor)
				FmtLin({},aL[123],,,@nLin)
				FmtLin({},aL[124],,,@nLin)
				FmtLin({},aL[125],,,@nLin) 
				FmtLin({cObs},aL[126],,,@nLin)
				FmtLin({},aL[127],,,@nLin)
				FmtLin({},aL[128],,,@nLin)
				FmtLin({},aL[129],,,@nLin)
				FmtLin({},aL[130],,,@nLin)
				nPagina++
			Else
				FmtLin({},aL[123],,,@nLin)
				FmtLin({},aL[124],,,@nLin)
				FmtLin({},aL[125],,,@nLin) 
				FmtLin({cObs},aL[126],,,@nLin)
				FmtLin({},aL[127],,,@nLin)
				FmtLin({},aL[128],,,@nLin)
				FmtLin({},aL[129],,,@nLin)
				FmtLin({},aL[130],,,@nLin)
				nPagina++
			Endif		
		Endif
		If nLin > 58
			nLin:= 0
		EndIf		
	EndDo
Endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ R913LayOut   ³Autor ³ Eduardo Ju           ³Data³ 02.06.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Armazena LayOut Mapa de Movimentacao de Produtos Quimicos  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR913                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function R913LayOut(aL)

//           1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
// 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
         
If nImpAnXI = 1
	If nModelo = 1 //Anexo XI-A
		al[01]:= STR0008 //"                                                                                   Mapa de Controle Geral de Produtos Quimicos                                                                               Pag.: #### "
		al[02]:= STR0009 //"                                                                                                                                                                                                                        "              
		al[03]:= STR0010 //"+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
		al[04]:= STR0011 //"|                                                                                                 1 - Dados da Empresa                                                                                                 |" 
		al[05]:= STR0012 //"+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+-------------------+"
		al[06]:= STR0013 //"|Razao Social: ########################################################                                                                                                                            |Mes/Ano: #######   |"
		al[07]:= STR0014 //"+----------------------------------------------------------------------------------------------------+---------------------------------------------------------------------------------------------+-------------------+"
		al[08]:= STR0015 //"|CNPJ: #################                                                                             |CLF: #######                                                                                 |Grupo: #######     |"
		al[09]:= STR0016 //"+----------------------------------------------------------------------------------------------------+---------------------------------------------------------------------------------------------+-------------------+"
		al[10]:= STR0017 //"|Atividade: ########################################                                                                                                                                               |CNAE: #######      |"	
		al[11]:= STR0018 //"+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+-------------------+"
		al[12]:= STR0019 //"                                                                                                                                                                                                                        "              
		al[13]:= STR0020 //"+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
		al[14]:= STR0021 //"|                                                                                             2 - Demonstrativo Geral                                                                                                  |" 
		al[15]:= STR0022 //"+------------------------------------------------------+------------------------------------------------------+------------------------------------------------------+-------------------------------------------------+"
		al[16]:= STR0023 //"                                                                                                                                                                                                                        "              
		al[17]:= STR0024 //"+------------------------------------------------------+------------------------------------------------------+------------------------------------------------------+-------------------------------------------------+"
		al[18]:= STR0025 //"|Codigo: ##########                                    |Nome: ##############################                  |Concentracao em %: #####                              |Densidade: #####                                 |"
		al[19]:= STR0026 //"+------------------------------------------------------+------------------------------------------------------+------------------------------------------------------+-------------------------------------------------+"
		al[20]:= STR0027 //"|Estoque Anterior:                   ################# |Producao:                           ################# |Transformacao:                      ################# |Utilizacao:                    ################# |"
		al[21]:= STR0028 //"+------------------------------------------------------+------------------------------------------------------+------------------------------------------------------+-------------------------------------------------+"
		al[22]:= STR0029 //"|Compras:                            ################# |Vendas:                             ################# |Reciclagem:                         ################# |Reaproveitamento:              ################# |"
		al[23]:= STR0030 //"+------------------------------------------------------+------------------------------------------------------+------------------------------------------------------+-------------------------------------------------+"
		al[24]:= STR0031 //"|Importacao:                         ################# |Exportacao:                         ################# |Perdas:                             ################# |Evaporacao:                    ################# |"
		al[25]:= STR0032 //"+------------------------------------------------------+------------------------------------------------------+------------------------------------------------------+-------------------------------------------------+"				
		al[26]:= STR0033 //"|Entradas Diversas:                  ################# |Saidas Diveras:                     ################# |Estoque Atual:                      ################# |Unidade: ##                                      |"
		al[27]:= STR0034 //"+------------------------------------------------------+------------------------------------------------------+------------------------------------------------------+-------------------------------------------------+"		         
		al[28]:= STR0035 //"|Cod.NCM.: ##########                                  | Prod.Final: ##############################           | Qtde:  #################                             | Densidade:  #####             Unidade: #####    |"
		al[29]:= STR0036 //"+------------------------------------------------------+------------------------------------------------------+------------------------------------------------------+-------------------------------------------------+"		         
		al[30]:= STR0139 //"|    Cod.NCM.Substancia:           Nome Do Produto:                                                             Concentracao em %:                                                                                     |"
		al[31]:= STR0140 //"|      ##########                     ##############################                                                     #####                                                                                         |"
		al[32]:= STR0141 //"+------------------------------------------------------+------------------------------------------------------+------------------------------------------------------+-------------------------------------------------+"		         
		al[33]:= STR0142 //"                                                                                                                                                                                                                        "              		
		al[34]:= STR0143 //"+--------------------------------------------------------------------------------------------------+------------------------------------------------------------------------+------------------------------------------+"
		al[35]:= STR0037 //"|Observacao                                                                                        |Nome do Responsavel                                                     |CPF                                       |"
		al[36]:= STR0038 //"|#####################################################################                             |########################################                                |##############                            |"
		al[37]:= STR0039 //"|                                                                                                  +------------------------------------------------------------------------+------------------------------------------+
		al[38]:= STR0040 //"|                                                                                                  |Assinatura                                                              |Identidade                                |"
		al[39]:= STR0041 //"|                                                                                                  |                                                                        |#################                         |"
		al[40]:= STR0042 //"+--------------------------------------------------------------------------------------------------+------------------------------------------------------------------------+------------------------------------------+"
	ElseIf nModelo = 2 //Anexo XI-B							
	  	al[36] := STR0043 //"                                                                                     Mapa de Movimentacao de Produtos Quimicos                                                                               Pag.: #### "
		al[37] := STR0044 //"                                                                                                                                                                                                                        "
		al[38] := STR0045 //"+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------+------------------------+-----------------+"
		al[39] := STR0046 //"|Razao Social: ########################################################                                                                                                     |CNPJ: ################# |Mes/Ano: ####### |"
		al[40] := STR0047 //"+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------+------------------------+-----------------+"
		al[41] := STR0048 //"                                                                                                                                                                                                                        "
		al[42] := STR0049 //"+----+-------+-----------+-------------------------------+---------------+-----------------+-------+----------+-------------------+-----------------------------------------+------------------------------------------+"
		al[43] := STR0050 //"|Dia | CFOP  |Codigo NCM |Produto Quimico Controlado     |Concentracao(%)|    Quantidade   | Unid. |N. Fiscal |   CNPJ/CGC        |       Fornecedor ou Adquirente          |             Transportadora               |"   
		al[44] := STR0051 //"+----+-------+-----------+-------------------------------+---------------+-----------------+-------+----------+-------------------+-----------------------------------------+------------------------------------------+"
		al[45] := STR0052 //"| ## |###### |########## |############################## |         ##### | ############### |  ##   | ######   |###################|######################################## |########################################  |"
		al[46] := STR0053 //"+----+-------+-----------+-------------------------------+---------------+-----------------+-------+----------+-------------------+-----------------------------------------+------------------------------------------+"
		al[47] := STR0054 //"                                                                                                                                                                                                                        "
		al[48] := STR0055 //"+--------------------------------------------------------------------------------------------------+------------------------------------------------------------------------+------------------------------------------+"
		al[49] := STR0056 //"|Observacao                                                                                        |Nome do Responsavel                                                     |CPF                                       |"
		al[50] := STR0057 //"|#####################################################################                             |########################################                                |##############                            |"
		al[51] := STR0058 //"|                                                                                                  +------------------------------------------------------------------------+------------------------------------------+
		al[52] := STR0059 //"|                                                                                                  |Assinatura                                                              |Identidade                                |"
		al[53] := STR0060 //"|                                                                                                  |                                                                        |#################                         |"
		al[54] := STR0061 //"+--------------------------------------------------------------------------------------------------+------------------------------------------------------------------------+------------------------------------------+"
	ElseIf nModelo = 3 //Anexo XI-C   
		al[55] := STR0062 //"                                                                          Mapa de Controle de Importacao e Exportacao de Produtos Quimicos                                                                   Pag.: #### "
		al[56] := STR0063 //"                                                                                                                                                                                                                        "
		al[57] := STR0064 //"+------------------------------------------------------------------------------------------------------------------------------------------------------------------------+-------------------------+-------------------+"
		al[58] := STR0065 //"|Razao Social: ########################################################                                                                                                  |CNPJ: #################  |Mes/Ano: #######   |"
		al[59] := STR0066 //"+------------------------------------------------------------------------------------------------------------------------------------------------------------------------+-------------------------+-------------------+"
		al[60] := STR0067 //"                                                                                                                                                                                                                        "
		al[61] := STR0068 //"+----+-----------+-------------------------------+---------------+-----------------+-------+----------+----------+-------------------------------------------------------+-------------------------+-------------------+"
		al[62] := STR0069 //"|I/E |Codigo NCM |Produto Quimico Controlado     |Concentracao(%)|    Quantidade   | Unid. |L.I /R.E  |N. Fiscal |   Nome do Importador ou Exportador                    | Pais                    |CNPJ Transportadora|"   
		al[63] := STR0070 //"+----+-----------+-------------------------------+---------------+-----------------+-------+----------+----------+-------------------------------------------------------+-------------------------+-------------------+"
		al[64] := STR0071 //"| ## |########## |############################## |         ##### | ############### |  ##   | ######   | #####    |########################################               |#########################|###################|"
		al[65] := STR0072 //"+----+-----------+-------------------------------+---------------+-----------------+-------+----------+----------+-------------------------------------------------------+-------------------------+-------------------+"
		al[66] := STR0073 //"                                                                                                                                                                                                                        "
		al[67] := STR0074 //"+--------------------------------------------------------------------------------------------------+---------------------------------------------------------------------+---------------------------------------------+"
		al[68] := STR0075 //"|Observacao                                                                                        |Nome do Responsavel                                                  |CPF                                          |"
		al[69] := STR0076 //"|#####################################################################                             |########################################                             |##############                               |"
		al[70] := STR0077 //"|                                                                                                  +---------------------------------------------------------------------+---------------------------------------------+
		al[71] := STR0078 //"|                                                                                                  |Assinatura                                                           |Identidade                                   |"
		al[72] := STR0079 //"|                                                                                                  |                                                                     |#################                            |"
		al[73] := STR0080 //"+--------------------------------------------------------------------------------------------------+---------------------------------------------------------------------+---------------------------------------------+"                                       
	ElseIf nModelo = 4 //Anexo XI-D
		al[74] := STR0081 //"                                                              Mapa de Controle de Armazenagem de Produtos Quimicos                                                  Pag.: #### "
		al[75] := STR0082 //"                                                                                                                                                                               "
		al[76] := STR0083 //"+-------------------------------------------------------------------------------------------------------------------------------+-------------------------+-------------------+"
		al[77] := STR0084 //"|Razao Social: ########################################################                                                         |CNPJ: #################  |Mes/Ano: #######   |"
		al[78] := STR0085 //"+-------------------------------------------------------------------------------------------------------------------------------+-------------------------+-------------------+"
		al[79] := STR0086 //"                                                                                                                                                                               "
		al[80] := STR0087 //"+-----------+--------------------------------------+---------------+-----------------+-------+-------------------+---------------------+--------------------------------------+"
		al[81] := STR0088 //"|Codigo NCM |Produto Quimico Controlado            |Concentracao(%)|    Quantidade   | Unid. |Estoque Anterior   |Estoque Atual        | Proprietario do Produto (CNPJ ou CPF)|"   
		al[82] := STR0089 //"+-----------+--------------------------------------+---------------+-----------------+-------+-------------------+---------------------+--------------------------------------+"
		al[83] := STR0090 //"|########## |##############################        |         ##### | ############### |  ##   | ################# |  ################## |         ###################          |"
		al[84] := STR0091 //"+-----------+--------------------------------------+---------------+-----------------+-------+-------------------+---------------------+--------------------------------------+"
		al[85] := STR0092 //"                                                                                                                                                                               "
		al[86] := STR0093 //"+-----------------------------------------------------------------------------+--------------------------------------------------------+--------------------------------------+"
		al[87] := STR0094 //"|Observacao                                                                   |Nome do Responsavel                                     |CPF                                   |"
		al[88] := STR0095 //"|#####################################################################        |########################################                |##############                        |"
		al[89] := STR0096 //"|                                                                             +--------------------------------------------------------+--------------------------------------+
		al[90] := STR0097 //"|                                                                             |Assinatura                                              |Identidade                            |"
		al[91] := STR0098 //"|                                                                             |                                                        |#################                     |"
		al[92] := STR0099 //"+-----------------------------------------------------------------------------+--------------------------------------------------------+--------------------------------------+"
	ElseIf nModelo = 5 // Anexo XI-E
		al[93]:= STR0100 //"                                                                                     Mapa de Movimentacao de Armazenagem de Produtos Quimicos                                                                Pag.: #### "
		al[94]:= STR0101 //"                                                                                                                                                                                                                        "
		al[95]:= STR0102 //"+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------+------------------------+-----------------+"
		al[96]:= STR0103 //"|Razao Social: ########################################################                                                                                                     |CNPJ: ################# |Mes/Ano: ####### |"
		al[97]:= STR0104 //"+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------+------------------------+-----------------+"
		al[98]:= STR0105 //"                                                                                                                                                                                                                        "
		al[99]:= STR0106 //"+----+-------+-----------+-------------------------------+---------------+-----------------+-------+----------+-------------------+-----------------------------------------+------------------------------------------+"
		al[100]:= STR0107 //"|Dia | E/S   |Codigo NCM |Produto Quimico Controlado     |Concentracao(%)|    Quantidade   | Unid. |N. Fiscal |   CNPJ/CGC        |       Proprietario do Produto           |             Transportadora               |"   
		al[101]:= STR0108 //"+----+-------+-----------+-------------------------------+---------------+-----------------+-------+----------+-------------------+-----------------------------------------+------------------------------------------+"
		al[102]:= STR0109 //"| ## |###### |########## |############################## |         ##### | ############### |  ##   | ######   |###################|######################################## |########################################  |"
		al[103]:= STR0110 //"+----+-------+-----------+-------------------------------+---------------+-----------------+-------+----------+-------------------+-----------------------------------------+------------------------------------------+"
		al[104]:= STR0111 //"                                                                                                                                                                                                                        "
		al[105]:= STR0112 //"+--------------------------------------------------------------------------------------------------+------------------------------------------------------------------------+------------------------------------------+"
		al[106]:= STR0113 //"|Observacao                                                                                        |Nome do Responsavel                                                     |CPF                                       |"
		al[107]:= STR0114 //"|#####################################################################                             |########################################                                |##############                            |"
		al[108]:= STR0115 //"|                                                                                                  +------------------------------------------------------------------------+------------------------------------------+
		al[109]:= STR0116 //"|                                                                                                  |Assinatura                                                              |Identidade                                |"
		al[110]:= STR0117 //"|                                                                                                  |                                                                        |#################                         |"
		al[111]:= STR0118 //"+--------------------------------------------------------------------------------------------------+------------------------------------------------------------------------+------------------------------------------+"
	EndIf
Else //Anexo XI-G
	al[112] := STR0120 //"                                                          Mapa de Controle de Residuos contendo Produtos Quimicos Controlados                                       Pag.: #### "
	al[113] := STR0121 //"                                                                                                                                                                               "
	al[114] := STR0122 //"+-------------------------------------------------------------------------------------------------------------------------------+-------------------------+-------------------+"
	al[115] := STR0123 //"|Razao Social: ########################################################                                                         |CNPJ: #################  |Mes/Ano: #######   |"
	al[116] := STR0124 //"+-------------------------------------------------------------------------------------------------------------------------------+-------------------------+-------------------+"
	al[117] := STR0125 //"                                                                                                                                                                               "
	al[118] := STR0126 //"+-----------+--------------------------------------+---------------+-------+-----------------+--------------------------------------------------------------------------------+"
	al[119] := STR0127 //"|Codigo NCM |Substancia Controlada Presente        |Concentracao(%)| Unid. |   Quantidade    |  Destinacao                                                                    |"   
	al[120] := STR0128 //"+-----------+--------------------------------------+---------------+-------+-----------------+--------------------------------------------------------------------------------+"
	al[121] := STR0129 //"|########## |##############################        |        ###### |  ##   | ############### |  #########################                                                     |"
	al[122] := STR0130 //"+-----------+--------------------------------------+---------------+-------+-----------------+--------------------------------------------------------------------------------+"
	al[123] := STR0131 //"                                                                                                                                                                               "
	al[124] := STR0132 //"+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	al[125] := STR0133 //"|Observacao                                                                                                                                                                   |"
	al[126] := STR0134 //"|#####################################################################                                                                                                        |"
	al[127] := STR0135 //"|                                                                                                                                                                             |"
	al[128] := STR0136 //"|                                                                                                                                                                             |"
	al[129] := STR0137 //"|                                                                                                                                                                             |"
	al[130] := STR0138 //"+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
Endif

Return (Nil) 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ R913Cabec    ³Autor ³ Eduardo Ju           ³Data³ 02.06.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime cabecalho do relatorio                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR913                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function R913Cabec(aL,nLin,nPagina,cMesAno,cCLF,cGrupo,cAtividade,cdia,cCPFCGC,cCliefor,cIE,cLiRe,cCGCTransp,cES)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime caracter de controle de largura de impressao         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLin:=0
@ nLin++,0 Psay AvalImp(220)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime cabecalho do relatorio                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nImpAnXI == 1 //Anexo XI-G
	If nModelo == 1 //Anexo XI-A
		FmtLin({Transform(nPagina++,"@R 9999")},aL[01],,,@nLin)  
		FmtLin({},aL[02],,,@nLin)
		FmtLin({},aL[03],,,@nLin)
		FmtLin({},aL[04],,,@nLin)
		FmtLIn({},al[05],,,@nLin)
		FmtLin({SM0->M0_NOMECOM,cMesAno},aL[06],,,@nLin)
		FmtLIn({},al[07],,,@nLin)                                                                                      
		FmtLin({Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"),cCLF,cGrupo},aL[08],,,@nlin) 
		FmtLIn({},al[09],,,@nLin)   
		FmtLin({cAtividade,SM0->M0_CNAE},aL[10],,,@nLin)
		FmtLin({},aL[11],,,@nLin)
		FmtLin({},aL[12],,,@nLin)
		FmtLin({},aL[13],,,@nLin)
		FmtLin({},aL[14],,,@nLin)
		FmtLin({},aL[15],,,@nLin) 
		FmtLin({},aL[16],,,@nLin)  
	ElseIf nModelo == 2 //Anexo XI-B
		FmtLin({Transform(nPagina++,"@R 9999")},aL[36],,,@nLin)  
		FmtLin({},aL[37],,,@nLin)
		FmtLin({},aL[38],,,@nLin)
		FmtLin({SM0->M0_NOMECOM,Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"),cMesAno},aL[39],,,@nLin)                                                                                      
		FmtLin({},aL[40],,,@nLin)
		FmtLin({},aL[41],,,@nLin)
		FmtLin({},aL[42],,,@nLin)
		FmtLin({},aL[43],,,@nLin)
		FmtLin({},aL[44],,,@nLin)  
	ElseIf nModelo == 3 //Anexo XI-C
		FmtLin({Transform(nPagina++,"@R 9999")},aL[55],,,@nLin)  
		FmtLin({},aL[56],,,@nLin)
		FmtLin({},aL[57],,,@nLin)
		FmtLin({SM0->M0_NOMECOM,Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"),cMesAno},aL[58],,,@nLin)                                                                                      
		FmtLin({},aL[59],,,@nLin)
		FmtLin({},aL[60],,,@nLin)
		FmtLin({},aL[61],,,@nLin)
		FmtLin({},aL[62],,,@nLin)
		FmtLin({},aL[63],,,@nLin) 
	ElseIf nModelo == 4 //Anexo XI-D
		FmtLin({Transform(nPagina++,"@R 9999")},aL[74],,,@nLin)  
		FmtLin({},aL[75],,,@nLin)
		FmtLin({},aL[76],,,@nLin)
		FmtLin({SM0->M0_NOMECOM,Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"),cMesAno},aL[77],,,@nLin)                                                                                      
		FmtLin({},aL[78],,,@nLin)
		FmtLin({},aL[79],,,@nLin)
		FmtLin({},aL[80],,,@nLin)
		FmtLin({},aL[81],,,@nLin)
		FmtLin({},aL[82],,,@nLin)
	ElseIf nModelo == 5 //Anexo XI-E
		FmtLin({Transform(nPagina++,"@R 9999")},aL[93],,,@nLin)  
		FmtLin({},aL[94],,,@nLin)
		FmtLin({},aL[95],,,@nLin)
		FmtLin({SM0->M0_NOMECOM,Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"),cMesAno},aL[96],,,@nLin)                                                                                      
		FmtLin({},aL[97],,,@nLin)
		FmtLin({},aL[98],,,@nLin)
		FmtLin({},aL[99],,,@nLin)
		FmtLin({},aL[100],,,@nLin)
		FmtLin({},aL[101],,,@nLin) 	 	 	
	EndIf
Else
	FmtLin({Transform(nPagina++,"@R 9999")},aL[112],,,@nLin)  
	FmtLin({},aL[113],,,@nLin)
	FmtLin({},aL[114],,,@nLin)
	FmtLin({SM0->M0_NOMECOM,Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"),cMesAno},aL[115],,,@nLin)                                                                                      
	FmtLin({},aL[116],,,@nLin)
	FmtLin({},aL[117],,,@nLin)
	FmtLin({},aL[118],,,@nLin)
	FmtLin({},aL[119],,,@nLin)
	FmtLin({},aL[120],,,@nLin) 	 	 	
Endif

Return (nil)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ R913TMSB ³ Autor ³Eduardo de Souza       ³ Data ³ 04/04/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Armazenamento e Tratamento dos dados para o Layout B       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ R913TMSB()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR913                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
/*Static Function R913TMSB(cMesAno)

Local cQuery    := ""
Local cAliasQry := GetNextAlias()
Local aAreaSM0  := SM0->(GetArea())

cQuery := " SELECT TIPO, POSIPI, EMISSAO, PRODUTO, QTDVOL, CODEMB, DOCTO, CGC, FILORI, CODPRO, CFOP, MAX(CONCENT) CONCENT "
cQuery += "   FROM (
cQuery += " SELECT 'E' TIPO         , B1_POSIPI POSIPI , DTC_DATENT EMISSAO, B1_DESC    PRODUTO, "
cQuery += "       DTC_QTDVOL QTDVOL, DTC_CODEMB CODEMB , DTC_NUMNFC DOCTO  , "
cQuery += "       A1_CGC CGC        , DTC_FILORI FILORI, DTC_CODPRO CODPRO "
cQuery += "     ,DTC_CF CFOP "
cQuery += "     ,B5_CONCENT CONCENT "
cQuery += "   FROM " + RetSqlName("DTC") + " DTC "
cQuery += "   JOIN " + RetSqlName("SB1") + " SB1 "
cQuery += "     ON  B1_FILIAL = '" + xFilial("SB1") + "' "
cQuery += "     AND B1_COD    = DTC_CODPRO "
cQuery += "     AND SB1.D_E_L_E_T_ = ' ' "
cQuery += "   LEFT JOIN " + RetSqlName("SB5") + " SB5 "
cQuery += "     ON  B5_FILIAL = '" + xFilial("SB5") + "' "
cQuery += "     AND B5_COD    = B1_COD "
cQuery += "     AND SB5.D_E_L_E_T_ = ' ' "
cQuery += "   JOIN " + RetSqlName("SA1") + " SA1 "
cQuery += "     ON  A1_FILIAL = '" + xFilial("SA1") + "' "
cQuery += "     AND A1_COD    = DTC_CLIREM  "
cQuery += "     AND A1_LOJA   = DTC_LOJREM "
cQuery += "     AND SA1.D_E_L_E_T_ = ' ' "
cQuery += "   WHERE DTC_FILIAL = '" + xFilial("DTC") + "' "
cQuery += "     AND DTC_DATENT BETWEEN '" + DToS(mv_par01) + "' AND '" + DToS(mv_par02) + "' "
cQuery += "     AND DTC.D_E_L_E_T_ = ' ' "
cQuery += " UNION ALL "
cQuery += " SELECT 'S' TIPO         , B1_POSIPI POSIPI , DT6_DATEMI EMISSAO, B1_DESC    PRODUTO, "
cQuery += "       DT6_QTDVOL QTDVOL, DTC_CODEMB CODEMB , DT6_DOC    DOCTO  , "
cQuery += "       A1_CGC CGC        , DTC_FILORI FILORI, DTC_CODPRO CODPRO , D2_CF CFOP "
cQuery += "     ,B5_CONCENT CONCENT "
cQuery += "   FROM " + RetSqlName("DTC") + " DTC "
cQuery += "   JOIN " + RetSqlName("SB1") + " SB1 "
cQuery += "     ON  B1_FILIAL = '" + xFilial("SB1") + "' "
cQuery += "     AND B1_COD    = DTC_CODPRO "
cQuery += "     AND SB1.D_E_L_E_T_ = ' ' "
cQuery += "   LEFT JOIN " + RetSqlName("SB5") + " SB5 "
cQuery += "     ON  B5_FILIAL = '" + xFilial("SB5") + "' "
cQuery += "     AND B5_COD    = B1_COD "
cQuery += "     AND SB5.D_E_L_E_T_ = ' ' "
cQuery += "   JOIN " + RetSqlName("DT6") + " DT6 "
cQuery += "     ON  DT6_FILIAL = '" + xFilial("DT6") + "' "
cQuery += "     AND DT6_FILDOC = DTC_FILDOC "
cQuery += "     AND DT6_DOC    = DTC_DOC "
cQuery += "     AND DT6_SERIE  = DTC_SERIE "
cQuery += "     AND DT6_DATEMI BETWEEN '" + DToS(mv_par01) + "' AND '" + DToS(mv_par02) + "' "
cQuery += "     AND DT6.D_E_L_E_T_ = ' ' "
cQuery += "   JOIN " + RetSqlName("DUI") + " DUI "
cQuery += "     ON  DUI_FILIAL = '" + xFilial("DUI") + "' "
cQuery += "     AND DUI_DOCTMS = DT6_DOCTMS "
cQuery += "     AND DUI.D_E_L_E_T_ = ' ' "
cQuery += "   JOIN " + RetSqlName("SD2") + " SD2 "
cQuery += "     ON  D2_FILIAL = DT6_FILDOC "
cQuery += "     AND D2_DOC     = DT6_DOC "
cQuery += "     AND D2_SERIE   = DT6_SERIE "
cQuery += "     AND D2_CLIENTE = DT6_CLIDEV "
cQuery += "     AND D2_LOJA    = DT6_LOJDEV " 
cQuery += "     AND D2_COD     = DUI_CODPRO "
cQuery += "     AND SD2.D_E_L_E_T_ = ' ' "
cQuery += "   JOIN " + RetSqlName("SA1") + " SA1 "
cQuery += "     ON  A1_FILIAL = '" + xFilial("SA1") + "' "
cQuery += "     AND A1_COD    = DTC_CLIDES  "
cQuery += "     AND A1_LOJA   = DTC_LOJDES "
cQuery += "     AND SA1.D_E_L_E_T_ = ' ' "
cQuery += "   WHERE DTC_FILIAL = '" + xFilial("DTC") + "' "
cQuery += "     AND DTC_DOC <> ' ' "
cQuery += "     AND DTC_SERIE <> 'PED' "
cQuery += "     AND DTC.D_E_L_E_T_ = ' ' ) QUERY "
cQuery += " GROUP BY TIPO, POSIPI, EMISSAO, PRODUTO, QTDVOL, CODEMB, DOCTO, CGC, FILORI, CODPRO, CFOP "
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

TcSetField(cAliasQry,"EMISSAO" ,"D",8,0)
TcSetField(cAliasQry,"CONCENT" ,"N",TamSx3("B5_CONCENT")[1],TamSx3("B5_CONCENT")[2])
TcSetField(cAliasQry,"QTDVOL"  ,"N",TamSx3("DTC_QTDVOL")[1],TamSx3("DTC_QTDVOL")[2])

While (cAliasQry)->(!Eof())
	If Empty(cMesAno)
		cMesAno:= Strzero(month((cAliasQry)->EMISSAO),2)+"/"+Strzero(year((cAliasQry)->EMISSAO),4)
	EndIf
	dbSelectArea("TRB")
	RecLock("TRB",.T.)   
	Replace EMISSAO   with Strzero(day((cAliasQry)->EMISSAO),2)
	Replace CFOP      with (cAliasQry)->CFOP
	Replace CODPROD	with (cAliasQry)->CODPRO
	Replace NCM		   with (cAliasQry)->POSIPI
	Replace PRODUTO 	with (cAliasQry)->PRODUTO
	Replace CONCEN    with (cAliasQry)->CONCENT
	Replace QTDE      with (cAliasQry)->QTDVOL
	Replace UNID      with (cAliasQry)->CODEMB
	Replace CPFCGC    with Transform((cAliasQry)->CGC,PicPesFJ(IIF(Len(alltrim((cAliasQry)->CGC))<14,"F","J")))
	Replace NFISCAL   with (cAliasQry)->DOCTO
	Replace CLIEFOR   with Transform((cAliasQry)->CGC,PicPesFJ(IIF(Len(alltrim((cAliasQry)->CGC))<14,"F","J")))
	Replace TRANSP    with Transform(Posicione("SM0",1,cEmpAnt+(cAliasQry)->FILORI,"M0_CGC"),PesqPict("SA1","A1_CGC"))
	MsUnlock()
	(cAliasQry)->(DbSkip())
EndDo

(cAliasQry)->(DbCloseArea())

RestArea( aAreaSM0 )

Return
*/

Function MATR913R4()

	Local oReport := Nil
 
	oReport := ReportDef()
	oReport:PrintDialog()

Return
 
Static Function ReportDef()
	
	Local oReport := NIL
	Local oSectionPR := NIL
	Local oSectionPC := NIL
	Local oSectionSC := NIL
	Local oSectionRC := NIL
	Local oSectionRS := NIL
	Local oSectionRB := NIL
	Local oSectioMVN := NIL
	Local oSectiMVN2 := NIL
	Local oSectionMM := NIL
	Local oSectionMT := NIL
	Local oSectionMA := NIL
	Local oSectioMA2 := NIL
	Local oSectioMVI := NIL
	Local oSectiMVI2 := NIL
	Local oSectioTRA := NIL
	Local oSectioTRI := NIL
	Local oSectioAMZ := NIL
	Local oSectiAMZ2 := NIL
	Local oSectioTER := NIL
	Local oSectiTER2 := NIL
	Local oSectionNF := NIL
	Local oSectioNFI := NIL
	Local oSectionUP := NIL
	Local oSectionUF := NIL
	Local oSectioUF2 := NIL
	Local oSectionUC := NIL
	Local oSectionFB := NIL
	Local oSectionTN := NIL
	Local oSectioTN2 := NIL
	Local oSectionCC := NIL
	Local oSectionTM := NIL
 
	oReport := TReport():New('MATR913',STR0144,'MTR913V2',{|oReport| PrintReport(oReport)}) // "Mapas de Controle de Produtos Químicos"
	oReport:SetTotalInLine(.F.)
	oReport:ShowHeader()
 
	// SEÇÃO DG

	oSectionPR := TRSection():New(oReport)
	oSectionPR:SetTotalInLine(.F.)
 
	TRCell():New(oSectionPR,"TIPO",,STR0145,,2) // "Tipo"
	TRCell():New(oSectionPR,"COD",,STR0146,,TamSX3("B1_COD")[1]) // "Cód. Produto"
	TRCell():New(oSectionPR,"CODNCM",,STR0147,,11) // "Cód. NCM"
	TRCell():New(oSectionPR,"NOMECOM",,STR0148,,70) // "Nome Comerc."
	TRCell():New(oSectionPR,"CONCENT",,STR0149,"@E 999",3) // "Concent."
	TRCell():New(oSectionPR,"DENSID",,STR0150,"@E 99.99",5) // "Densid."

	oSectionPC := TRSection():New(oReport)
	oSectionPC:SetTotalInLine(.F.)
 
	TRCell():New(oSectionPC,"TIPO",,STR0145,,2) // "Tipo"
	TRCell():New(oSectionPC,"COD",,STR0146,,TamSX3("B1_COD")[1])
	TRCell():New(oSectionPC,"NCMCOM",,STR0147,,10)
	TRCell():New(oSectionPC,"NOMECOM",,STR0148,,70)
	TRCell():New(oSectionPC,"DENSID",,STR0150,"@E 99.99",5)

	oSectionSC := TRSection():New(oReport)
	oSectionSC:SetTotalInLine(.F.)
 
	TRCell():New(oSectionSC,"TIPO",,STR0145,,2) // "Tipo"
	TRCell():New(oSectionSC,"COD",,STR0146,,TamSX3("B1_COD")[1])
	TRCell():New(oSectionSC,"CODNCM",,STR0147,,11)
	TRCell():New(oSectionSC,"CONCENT",,STR0149,"@E 99",2)

	oSectionRC := TRSection():New(oReport)
	oSectionRC:SetTotalInLine(.F.)
 
	TRCell():New(oSectionRC,"TIPO",,STR0145,,2) // "Tipo"
	TRCell():New(oSectionRC,"COD",,STR0146,,TamSX3("B1_COD")[1])
	TRCell():New(oSectionRC,"CODNCM",,STR0147,,11)
	TRCell():New(oSectionRC,"NOMECOM",,STR0148,,70)
	TRCell():New(oSectionRC,"CONCENT",,STR0149,"@E 999",3)
	TRCell():New(oSectionRC,"DENSID",,STR0150,"@E 99.99",5)

	oSectionRS := TRSection():New(oReport)
	oSectionRS:SetTotalInLine(.F.)
 
	TRCell():New(oSectionRS,"TIPO",,STR0145,,2) // "Tipo"
	TRCell():New(oSectionRS,"COD",,STR0146,,TamSX3("B1_COD")[1])
	TRCell():New(oSectionRS,"NCMCOM",,STR0147,,10)
	TRCell():New(oSectionRS,"NOMECOM",,STR0148,,70)
	TRCell():New(oSectionRS,"DENSID",,STR0150,"@E 99.99",5)

	oSectionRB := TRSection():New(oReport)
	oSectionRB:SetTotalInLine(.F.)
 
	TRCell():New(oSectionRB,"TIPO",,STR0145,,2) // "Tipo"
	TRCell():New(oSectionRB,"COD",,STR0146,,TamSX3("B1_COD")[1])
	TRCell():New(oSectionRB,"CODNCM",,STR0147,,11)
	TRCell():New(oSectionRB,"CONCENT",,STR0149,"@E 99",2)

	// SEÇÃO MVN

	oSectioMVN := TRSection():New(oReport)
	oSectioMVN:SetTotalInLine(.F.)
 
	TRCell():New(oSectioMVN,"TIPO",,STR0145,,3) // "Tipo"
	TRCell():New(oSectioMVN,"NUMDOC",,STR0151,,TamSX3("F1_DOC")[1]+TamSX3("F1_SERIE")[1]+1) // "NF"
	TRCell():New(oSectioMVN,"CLIFOR",,STR0152,,TamSX3("F1_FORNECE")[1]+TamSx3("F1_LOJA")[1]+1) // "Cli/For"
	TRCell():New(oSectioMVN,"ENTSAI",,STR0153,,1) // "E/S"
	TRCell():New(oSectioMVN,"OPERACAO",,STR0154,,2) // "Operação"

	oSectiMVN2 := TRSection():New(oReport)
	oSectiMVN2:SetTotalInLine(.F.)

	// Seção criada para fins de layout
	TRCell():New(oSectiMVN2,"CNPJ",,STR0155,,14) // "CGC Cli/For"
	TRCell():New(oSectiMVN2,"RAZAOSOC",,STR0156,,69) // "Nome Cli/For"
	TRCell():New(oSectiMVN2,"NUMERONF",,STR0157,,10) // "Número NF"
	TRCell():New(oSectiMVN2,"EMISSAONF",,STR0158,,10) // "Emissão"
	TRCell():New(oSectiMVN2,"ARMAZENAG",,STR0159,,1) // "Armazenagem"
	TRCell():New(oSectiMVN2,"TRANSPORT",,STR0160,,1) // "Transporte"

	oSectionMM := TRSection():New(oReport)
	oSectionMM:SetTotalInLine(.F.)
 
	TRCell():New(oSectionMM,"TIPO",,STR0145,,2) // "Tipo"
	TRCell():New(oSectionMM,"COD",,STR0146,,TamSX3("B1_COD")[1])
	TRCell():New(oSectionMM,"CODNCM",,STR0147,,13)
	TRCell():New(oSectionMM,"CONCENT",,STR0149,"@E 999",3)
	TRCell():New(oSectionMM,"DENSID",,STR0150,"@E 99.99",5)
	TRCell():New(oSectionMM,"QUANT",,STR0161,"@E 999,999,999.999",13) // "Quant."
	TRCell():New(oSectionMM,"UM",,STR0162,,1) // "U.M."

	oSectionMT := TRSection():New(oReport)
	oSectionMT:SetTotalInLine(.F.)
 
	TRCell():New(oSectionMT,"TIPO",,STR0145,,2) // "Tipo"
	TRCell():New(oSectionMT,"CNPJ",,STR0163,,14) // "CGC Transp."
	TRCell():New(oSectionMT,"RAZSOC",,STR0164,,70) // "Nome Transp."

	oSectionMA := TRSection():New(oReport)
	oSectionMA:SetTotalInLine(.F.)

	TRCell():New(oSectionMA,"TIPO",,STR0145,,2) // "Tipo"
	TRCell():New(oSectionMA,"CNPJ",,STR0191,,14) // "CGC Armaz."
	TRCell():New(oSectionMA,"RAZSOC",,STR0192,,70) // "Nome Armaz."
	
	oSectioMA2 := TRSection():New(oReport)
	oSectioMA2:SetTotalInLine(.F.)

	// Seção criada para fins de layout
	TRCell():New(oSectioMA2,"ENDERECO",,STR0193,,70) // "Endereço"
	TRCell():New(oSectioMA2,"CEP",,STR0194,,10) // "C.E.P"
	TRCell():New(oSectioMA2,"NUMERO",,STR0195,,5) // "Número"
	TRCell():New(oSectioMA2,"COMP",,STR0196,,20) // "Complemento"
	TRCell():New(oSectioMA2,"BAIRRO",,STR0197,,30) // "Bairro"
	TRCell():New(oSectioMA2,"UF",,STR0198,,2) // "Estado"
	TRCell():New(oSectioMA2,"CODMUNIC",,STR0199,,7) // "Município"

	// SEÇÃO MVI

	oSectioMVI := TRSection():New(oReport)
	oSectioMVI:SetTotalInLine(.F.)
 
	TRCell():New(oSectioMVI,"TIPO",,STR0145,,3) // "Tipo"
	TRCell():New(oSectioMVI,"NUMDOC",,STR0151,,TamSX3("F1_DOC")[1]+TamSX3("F1_SERIE")[1]+1) // "NF"
	TRCell():New(oSectioMVI,"CLIFOR",,STR0152,,TamSX3("F1_FORNECE")[1]+TamSx3("F1_LOJA")[1]+1) // "Cli/For"
	TRCell():New(oSectioMVI,"OPERACAO",,STR0154,,1) // "Operação"
	TRCell():New(oSectioMVI,"PAIS",,STR0200,,3) // "País"
	TRCell():New(oSectioMVI,"RAZAOSOC",,STR0156,,69) // "Nome Cli/For"
	TRCell():New(oSectioMVI,"LIRE",,STR0201,,12) // "L.I/R.E"

	oSectiMVI2 := TRSection():New(oReport)
	oSectiMVI2:SetTotalInLine(.F.)

	// Seção criada para fins de layout
	TRCell():New(oSectiMVI2,"RESTEMB",,STR0202,,10) // "Restrição Emb."
	TRCell():New(oSectiMVI2,"CONHECEMB",,STR0203,,10) // "Conhec. Emb."
	TRCell():New(oSectiMVI2,"DUE",,STR0204,,15) // "D.U.E"
	TRCell():New(oSectiMVI2,"DTDUE",,STR0205,,10) // "Data D.U.E"
	TRCell():New(oSectiMVI2,"DI",,STR0206,,12) // "D.I"
	TRCell():New(oSectiMVI2,"DTDI",,STR0207,,10) // "Data D.I"
	TRCell():New(oSectiMVI2,"ARMAZENAGE",,STR0159,,1) // "Armazenagem"
	TRCell():New(oSectiMVI2,"TRANSPORT",,STR0160,,1) // "Transporte"
	TRCell():New(oSectiMVI2,"ENTREGA",,STR0208,,1) // "Entrega"

	oSectioTRA := TRSection():New(oReport)
	oSectioTRA:SetTotalInLine(.F.)

	TRCell():New(oSectioTRA,"TIPO",,STR0145,,3) // "Tipo"
	TRCell():New(oSectioTRA,"CNPJ",,STR0163,,14) // "CGC Transp."
	TRCell():New(oSectioTRA,"RAZAOSOC",,STR0164,,70) // "Nome Transp."

	oSectioTRI := TRSection():New(oReport)
	oSectioTRI:SetTotalInLine(.F.)

	TRCell():New(oSectioTRI,"TIPO",,STR0145,,3) // "Tipo"
	TRCell():New(oSectioTRI,"RAZAOSOC",,STR0164,,70) // "Nome Transp."

	oSectioAMZ := TRSection():New(oReport)
	oSectioAMZ:SetTotalInLine(.F.)

	TRCell():New(oSectioAMZ,"TIPO",,STR0145,,3) // "Tipo"
	TRCell():New(oSectioAMZ,"CNPJ",,STR0191,,14) // "CGC Armaz."
	TRCell():New(oSectioAMZ,"RAZSOC",,STR0192,,70) // "Nome Armaz."
	
	oSectiAMZ2 := TRSection():New(oReport)
	oSectiAMZ2:SetTotalInLine(.F.)

	// Seção criada para fins de layout
	TRCell():New(oSectiAMZ2,"ENDERECO",,STR0193,,70) // "Endereço"
	TRCell():New(oSectiAMZ2,"CEP",,STR0194,,10) // "C.E.P"
	TRCell():New(oSectiAMZ2,"NUMERO",,STR0195,,5) // "Número"
	TRCell():New(oSectiAMZ2,"COMP",,STR0196,,20) // "Complemento"
	TRCell():New(oSectiAMZ2,"BAIRRO",,STR0197,,30) // "Bairro"
	TRCell():New(oSectiAMZ2,"UF",,STR0198,,2) // "Estado"
	TRCell():New(oSectiAMZ2,"CODMUNIC",,STR0199,,7) // "Município"

	oSectioTER := TRSection():New(oReport)
	oSectioTER:SetTotalInLine(.F.)

	TRCell():New(oSectioTER,"TIPO",,STR0145,,3) // "Tipo"
	TRCell():New(oSectioTER,"CNPJ",,STR0191,,14) // "CGC Armaz."
	TRCell():New(oSectioTER,"RAZSOC",,STR0192,,70) // "Nome Armaz."
	
	oSectiTER2 := TRSection():New(oReport)
	oSectiTER2:SetTotalInLine(.F.)

	// Seção criada para fins de layout
	TRCell():New(oSectiTER2,"ENDERECO",,STR0193,,70) // "Endereço"
	TRCell():New(oSectiTER2,"CEP",,STR0194,,10) // "C.E.P"
	TRCell():New(oSectiTER2,"NUMERO",,STR0195,,5) // "Número"
	TRCell():New(oSectiTER2,"COMP",,STR0196,,20) // "Complemento"
	TRCell():New(oSectiTER2,"BAIRRO",,STR0197,,30) // "Bairro"
	TRCell():New(oSectiTER2,"UF",,STR0198,,2) // "Estado"
	TRCell():New(oSectiTER2,"CODMUNIC",,STR0199,,7) // "Município"

	oSectionNF := TRSection():New(oReport)
	oSectionNF:SetTotalInLine(.F.)

	TRCell():New(oSectionNF,"TIPO",,STR0145,,2) // "Tipo"
	TRCell():New(oSectionNF,"NUMERONF",,STR0157,,14) // "Número NF"
	TRCell():New(oSectionNF,"EMISSAONF",,STR0158,,70) // "Emissão"
	TRCell():New(oSectionNF,"ENTSAI",,STR0154,,70) // "Operação"

	oSectioNFI := TRSection():New(oReport)
	oSectioNFI:SetTotalInLine(.F.)
 
	TRCell():New(oSectioNFI,"COD",,STR0146,,TamSX3("B1_COD")[1])
	TRCell():New(oSectioNFI,"CODNCM",,STR0147,,13)
	TRCell():New(oSectioNFI,"CONCENT",,STR0149,"@E 999",3)
	TRCell():New(oSectioNFI,"DENSID",,STR0150,"@E 99.99",5)
	TRCell():New(oSectioNFI,"QUANT",,STR0161,"@E 999,999,999.999",13) // "Quant."
	TRCell():New(oSectioNFI,"UM",,STR0162,,1) // "U.M."

	// Seção UP

	oSectionUP := TRSection():New(oReport)
	oSectionUP:SetTotalInLine(.F.)

	TRCell():New(oSectionUP,"TIPO",,STR0145,,2) // "Tipo"
	TRCell():New(oSectionUP,"COD",,STR0165,,TamSX3("B1_COD")[1]) // "Cód. Consumnido"
	TRCell():New(oSectionUP,"CODNCM",,STR0147,,13)
	TRCell():New(oSectionUP,"CONCENT",,STR0149,"@E 999",3)
	TRCell():New(oSectionUP,"DENSID",,STR0150,"@E 99.99",5)
	TRCell():New(oSectionUP,"QUANT",,STR0161,"@E 999,999,999.999",13)
	TRCell():New(oSectionUP,"UM",,STR0162,,1)

	oSectionUF := TRSection():New(oReport)
	oSectionUF:SetTotalInLine(.F.)

	TRCell():New(oSectionUF,"TIPO",,STR0145,,2) // "Tipo"
	TRCell():New(oSectionUF,"COD",,STR0166,,TamSX3("B1_COD")[1]) // "Cód. Produzido"
	TRCell():New(oSectionUF,"CODNCM",,STR0147,,13)
	TRCell():New(oSectionUF,"CONCENT",,STR0149,"@E 999",3)
	TRCell():New(oSectionUF,"DENSID",,STR0150,"@E 99.99",5)
	TRCell():New(oSectionUF,"QUANT",,STR0161,"@E 999,999,999.999",13)
	TRCell():New(oSectionUF,"UM",,STR0162,,1)
	TRCell():New(oSectionUF,"EMISSAO",,STR0167,,10) // "Data da Prod."

	// Seção criada para exibir a descrição da produção separadamente da seção anterior para fins de layout
	oSectioUF2 := TRSection():New(oReport)
	oSectioUF2:SetTotalInLine(.F.)
	TRCell():New(oSectioUF2,"DESCPROD",,'Descrição da Produção',,200)

	// Seção UC

	oSectionUC := TRSection():New(oReport)
	oSectionUC:SetTotalInLine(.F.)

	TRCell():New(oSectionUC,"TIPO",,STR0145,,2) // "Tipo"
	TRCell():New(oSectionUC,"COD",,STR0146,,TamSX3("B1_COD")[1])
	TRCell():New(oSectionUC,"CODNCM",,STR0147,,13)
	TRCell():New(oSectionUC,"CONCENT",,STR0149,"@E 999",3)
	TRCell():New(oSectionUC,"DENSID",,STR0150,"@E 99.99",5)
	TRCell():New(oSectionUC,"QUANT",,STR0161,"@E 999,999,999.999",13)
	TRCell():New(oSectionUC,"UM",,STR0162,,1)
	TRCell():New(oSectionUC,"CODCONSUMO",,STR0168,,1) // "Cod.Consumo"
	TRCell():New(oSectionUC,"OBSERVACAO",,STR0169,,62) // "Obs"
	TRCell():New(oSectionUC,"EMISSAO",,STR0170,,10) // "Data do Consumo"

	// Seção FB

	oSectionFB := TRSection():New(oReport)
	oSectionFB:SetTotalInLine(.F.)

	TRCell():New(oSectionFB,"TIPO",,STR0145,,2) // "Tipo"
	TRCell():New(oSectionFB,"COD",,STR0146,,TamSX3("B1_COD")[1])
	TRCell():New(oSectionFB,"CODNCM",,STR0147,,13)
	TRCell():New(oSectionFB,"CONCENT",,STR0149,"@E 999",3)
	TRCell():New(oSectionFB,"DENSID",,STR0150,"@E 99.99",5)
	TRCell():New(oSectionFB,"QUANT",,STR0161,"@E 999,999,999.999",13)
	TRCell():New(oSectionFB,"UM",,STR0162,,1)
	TRCell():New(oSectionFB,"EMISSAO",,STR0171,,10) // "Data da Fabricação"

	// Seção TN

	oSectionTN := TRSection():New(oReport)
	oSectionTN:SetTotalInLine(.F.)

	TRCell():New(oSectionTN,"TIPO",,STR0145,,3) // "Tipo"
	TRCell():New(oSectionTN,"NUMDOC",,STR0151,,TamSX3("F1_DOC")[1]+TamSX3("F1_SERIE")[1]+1)
	TRCell():New(oSectionTN,"CLIFOR",,STR0172,,TamSX3("F1_FORNECE")[1]+TamSx3("F1_LOJA")[1]+1) // "Contrat."
	TRCell():New(oSectionTN,"CGCCONTRAT",,STR0173,,14) // "CGC Contrat."
	TRCell():New(oSectionTN,"NOMECONTRA",,STR0174,,70) // "Nome Contrat."

	oSectioTN2 := TRSection():New(oReport)
	oSectioTN2:SetTotalInLine(.F.)

	// Seção criada para fins de layout
	TRCell():New(oSectioTN2,"NUMERONF",,STR0157,,10)
	TRCell():New(oSectioTN2,"EMISSAONF",,STR0158,,10)
	TRCell():New(oSectioTN2,"CGCORIGEM",,STR0175,,14) // "CGC Origem"
	TRCell():New(oSectioTN2,"NOMEORIGEM",,STR0176,,70) // "Nome Origem"
	TRCell():New(oSectioTN2,"RETIRADA",,STR0177,,1) // "Retirada"
	TRCell():New(oSectioTN2,"ENTREGA",,STR0178,,1) // "Entrega"

	oSectionCC := TRSection():New(oReport)
	oSectionCC:SetTotalInLine(.F.)

	TRCell():New(oSectionCC,"TIPO",,STR0145,,2) // "Tipo"
	TRCell():New(oSectionCC,"NUMCC",,STR0179,,9) // "Núm.CC"
	TRCell():New(oSectionCC,"DATACC",,STR0180,,10) // "Data CC"
	TRCell():New(oSectionCC,"DATARECEB",,STR0181,,10) // "Data do Receb."
	TRCell():New(oSectionCC,"RESPRECEB",,STR0182,,70) // "Respons.Receb." 
	TRCell():New(oSectionCC,"MODALTRANS",,STR0183,,8) // "Modal"

	oSectionTM := TRSection():New(oReport)
	oSectionTM:SetTotalInLine(.F.)

	TRCell():New(oSectionTM,"TIPO",,STR0145,,2) // "Tipo"
	TRCell():New(oSectionTM,"COD",,STR0146,,TamSX3("B1_COD")[1])
	TRCell():New(oSectionTM,"CODNCM",,STR0147,,13)
	TRCell():New(oSectionTM,"CONCENT",,STR0149,"@E 999",3)
	TRCell():New(oSectionTM,"DENSID",,STR0150,"@E 99.99",5)
	TRCell():New(oSectionTM,"QUANT",,STR0161,"@E 999,999,999.999",13)
	TRCell():New(oSectionTM,"UM",,STR0162,,1)

Return (oReport)
 
Static Function PrintReport(oReport)
	
	Local dDataDe := Nil
	Local oMapasPF := Nil
	Local dDataAte := Nil
	Local cChave := ""
    Local cProdDe := ""
    Local cProdAte := ""
	Local cGrupoDe := ""
	Local cGrupoAte := ""
	Local cChaveAtu := ""
	Local cChaveAnt := ""
	Local cAliasTPR := ""
	Local cAliasTPC := ""
	Local cAliasTSC := ""
	Local cAliasTRC := ""
	Local cAliasTRS := ""
	Local cAliasTRB := ""
	Local cAliasMVN := ""
	Local cAliasTMM := ""
	Local cAliasTMT := ""
	Local cAliasTMA := ""
	Local cAliasMVI := ""
	Local cAliasTRA := ""
	Local cAliasTRI := ""
	Local cAliasAMZ := ""
	Local cAliasTER := ""
	Local cAliasTNF := ""
	Local cAliasNFI := ""
	Local cAliasTUP := ""
	Local cAliasTUF := ""
	Local cAliasTUC := ""
	Local cAliasTTN := ""
	Local cAliasTCC := ""
	Local cAliasTTM := ""
	Local cDeclMapas := ""
	Local aFil := FWArrFilAtu()
	Local oSectionPR := oReport:Section(01)
	Local oSectionPC := oReport:Section(02)
	Local oSectionSC := oReport:Section(03)
	Local oSectionRC := oReport:Section(04)
	Local oSectionRS := oReport:Section(05)
	Local oSectionRB := oReport:Section(06)
	Local oSectioMVN := oReport:Section(07)
	Local oSectiMVN2 := oReport:Section(08)
	Local oSectionMM := oReport:Section(09)
	Local oSectionMT := oReport:Section(10)
	Local oSectionMA := oReport:Section(11)
	Local oSectioMA2 := oReport:Section(12)
	Local oSectioMVI := oReport:Section(13)
	Local oSectiMVI2 := oReport:Section(14)
	Local oSectioTRA := oReport:Section(15)
	Local oSectioTRI := oReport:Section(16)
	Local oSectioAMZ := oReport:Section(17)
	Local oSectiAMZ2 := oReport:Section(18)
	Local oSectioTER := oReport:Section(19)
	Local oSectiTER2 := oReport:Section(20)
	Local oSectionNF := oReport:Section(21)
	Local oSectioNFI := oReport:Section(22)
	Local oSectionUP := oReport:Section(23)
	Local oSectionUF := oReport:Section(24)
	Local oSectioUF2 := oReport:Section(25)
	Local oSectionUC := oReport:Section(26)
	Local oSectionFB := oReport:Section(27)
	Local oSectionTN := oReport:Section(28)
	Local oSectioTN2 := oReport:Section(29)
	Local oSectionCC := oReport:Section(30)
	Local oSectionTM := oReport:Section(31)

	Pergunte(oReport:uParam,.F.)

	If ValType(mv_par01) != "D" .Or. ValType(mv_par02) != "D" .Or. ValType(mv_par03) != "C" .Or. ValType(mv_par04) != "C" .Or. ValType(mv_par05) != "C" .Or. ValType(mv_par06) != "C" .Or. ValType(mv_par07) != "C"
		Help(,,"ERRCONFIG",,STR0184,1,0) // "Foram encontradas configurações conflitantes e por isso a impressão será cancelada. Verifique as configurações do Grupo de Perguntas MTR913V2 e tente novamente."
		oReport:CancelPrint()
		Return
	EndIf

	oReport:SetMeter(8)

	dDataDe := mv_par01
	dDataAte := mv_par02
	cGrupoDe := mv_par03
    cGrupoAte := mv_par04
    cProdDe := mv_par05
    cProdAte := mv_par06
	cDeclMapas := mv_par07

	oReport:IncMeter(1)

	oMapasPF := MAPASPF():New(dDataDe, dDataAte, cGrupoDe, cGrupoAte, cProdDe, cProdAte, 2, aFil[18], cDeclMapas)

	If !oMapasPF:lConfigOk
        Return
    EndIf

	oReport:IncMeter(1)

	oReport:ThinLine()
	oReport:PrintText("")
	oReport:PrtCenter(STR0185) // "S E Ç Ã O  D G :  D E S C R I Ç Ã O  G E R A L"
	oReport:PrintText("")
	oReport:PrintText("")
	oReport:ThinLine()
	oReport:PrintText("")
	oReport:PrintText("")

	cAliasTPR := oMapasPF:aTrab[TPR_POS][ALIAS_POS]

	If oMapasPF:lMvAglut
        (cAliasTPR)->(DbSetOrder(1))
    Else
        (cAliasTPR)->(DbSetOrder(2))
    EndIf

	(cAliasTPR)->(dbGoTop())

	oSectionPR:Init()
	oSectionPR:SetHeaderSection(.T.)

	// Subseção PR
	While !(cAliasTPR)->(EoF())

		oSectionPR:Cell("TIPO"):SetValue((cAliasTPR)->TIPO)
		If !oMapasPF:lMvAglut // Com a aglutinação ativa, não faz sentido exibir o código do produto
			oSectionPR:Cell("COD"):SetValue((cAliasTPR)->COD)
		EndIf
		oSectionPR:Cell("CODNCM"):SetValue((cAliasTPR)->CODNCM)
		oSectionPR:Cell("NOMECOM"):SetValue((cAliasTPR)->NOMECOM)
		oSectionPR:Cell("CONCENT"):SetValue((cAliasTPR)->CONCENT)
		oSectionPR:Cell("DENSID"):SetValue((cAliasTPR)->DENSID)

		oSectionPR:PrintLine()

		(cAliasTPR)->(dbSkip())

	End

	oSectionPR:Finish()

	cAliasTPC := oMapasPF:aTrab[TPC_POS][ALIAS_POS]
	cAliasTSC := oMapasPF:aTrab[TSC_POS][ALIAS_POS]

	(cAliasTPC)->(dbSetOrder(1))
	(cAliasTPC)->(dbGoTop())

	If oMapasPF:lMvAglut
        (cAliasTSC)->(DbSetOrder(1))
    Else
        (cAliasTSC)->(DbSetOrder(2))
    EndIf

	(cAliasTSC)->(dbGoTop())

	// Subseção PC
	While !(cAliasTPC)->(EoF())

		oSectionPC:Init()
		oSectionPC:SetHeaderSection(.T.)

		oSectionPC:Cell("TIPO"):SetValue((cAliasTPC)->TIPO)
		If !oMapasPF:lMvAglut // Se a aglutinação estiver ativa, não faz sentido exibir o código do produto
			oSectionPC:Cell("COD"):SetValue((cAliasTPC)->COD)
		EndIf
		oSectionPC:Cell("NCMCOM"):SetValue((cAliasTPC)->NCMCOM)
		oSectionPC:Cell("NOMECOM"):SetValue((cAliasTPC)->NOMECOM)
		oSectionPC:Cell("DENSID"):SetValue((cAliasTPC)->DENSID)

		oSectionPC:PrintLine()

		oSectionPC:Finish()

		oSectionSC:Init()
		oSectionSC:SetHeaderSection(.T.)

		// Subseção SC
		While (cAliasTPC)->COD == (cAliasTSC)->CODPAI

			oSectionSC:Cell("TIPO"):SetValue((cAliasTSC)->TIPO)
			If !oMapasPF:lMvAglut // Se a aglutinação estiver ativa, não faz sentido exibir o código do produto
				oSectionSC:Cell("COD"):SetValue((cAliasTSC)->COD)
			EndIf
			oSectionSC:Cell("CODNCM"):SetValue((cAliasTSC)->CODNCM)
			oSectionSC:Cell("CONCENT"):SetValue((cAliasTSC)->CONCENT)

			oSectionSC:PrintLine()

            (cAliasTSC)->(DbSkip())

        End 

		oSectionSC:Finish()

		(cAliasTPC)->(dbSkip())

	End

	cAliasTRC := oMapasPF:aTrab[TRC_POS][ALIAS_POS]

	If oMapasPF:lMvAglut
        (cAliasTRC)->(DbSetOrder(1))
    Else
        (cAliasTRC)->(DbSetOrder(2))
    EndIf

	(cAliasTRC)->(dbGoTop())

	oSectionRC:Init()
	oSectionRC:SetHeaderSection(.T.)

	// Subseção RC
	While !(cAliasTRC)->(EoF())

		oSectionRC:Cell("TIPO"):SetValue((cAliasTRC)->TIPO)
		If !oMapasPF:lMvAglut // Se a aglutinação estiver ativa, não faz sentido exibir o código do produto
			oSectionRC:Cell("COD"):SetValue((cAliasTRC)->COD)
		EndIf
		oSectionRC:Cell("CODNCM"):SetValue((cAliasTRC)->CODNCM)
		oSectionRC:Cell("NOMECOM"):SetValue((cAliasTRC)->NOMECOM)
		oSectionRC:Cell("CONCENT"):SetValue((cAliasTRC)->CONCENT)
		oSectionRC:Cell("DENSID"):SetValue((cAliasTRC)->DENSID)

		oSectionRC:PrintLine()

		(cAliasTRC)->(dbSkip())

	End

	oSectionRC:Finish()

	cAliasTRS := oMapasPF:aTrab[TRS_POS][ALIAS_POS]
	cAliasTRB := oMapasPF:aTrab[TRB_POS][ALIAS_POS]

	(cAliasTRS)->(dbSetOrder(1))
	(cAliasTRS)->(dbGoTop())

    If oMapasPF:lMvAglut   
        (cAliasTRB)->(DbSetOrder(1))
    Else
        (cAliasTRB)->(DbSetOrder(2))
    EndIf

	(cAliasTRB)->(dbGoTop())

	// Subseção RS
	While !(cAliasTRS)->(EoF())

		oSectionRS:Init()
		oSectionRS:SetHeaderSection(.T.)

		oSectionRS:Cell("TIPO"):SetValue((cAliasTRS)->TIPO)
		If !oMapasPF:lMvAglut // Se a aglutinação estiver ativa, não faz sentido exibir o código do produto
			oSectionRS:Cell("COD"):SetValue((cAliasTRS)->COD)
		EndIf
		oSectionRS:Cell("NCMCOM"):SetValue((cAliasTRS)->NCMCOM)
		oSectionRS:Cell("NOMECOM"):SetValue((cAliasTRS)->NOMECOM)
		oSectionRS:Cell("DENSID"):SetValue((cAliasTRS)->DENSID)

		oSectionRS:PrintLine()

		oSectionRS:Finish()

		oSectionRB:Init()
		oSectionRB:SetHeaderSection(.T.)

		// Subseção RB
		While (cAliasTRS)->COD == (cAliasTRB)->CODPAI

			oSectionRB:Cell("TIPO"):SetValue((cAliasTRB)->TIPO)
			If !oMapasPF:lMvAglut // Se a aglutinação estiver ativa, não faz sentido exibir o código do produto
				oSectionRB:Cell("COD"):SetValue((cAliasTRB)->COD)
			EndIf
			oSectionRB:Cell("CODNCM"):SetValue((cAliasTRB)->CODNCM)
			oSectionRB:Cell("CONCENT"):SetValue((cAliasTRB)->CONCENT)

			oSectionRB:PrintLine()

            (cAliasTRB)->(DbSkip())

        End 

		oSectionRB:Finish()

		(cAliasTRS)->(dbSkip())

	End

	oReport:EndPage()

	oReport:IncMeter(1)

	oReport:ThinLine()
	oReport:PrintText("")
	oReport:PrtCenter(STR0186) // "S E Ç Ã O  M V N :  M O V I M E T A Ç Õ E S  N A C I O N A I S"
	oReport:PrintText("")
	oReport:PrintText("")
	oReport:ThinLine()
	oReport:PrintText("")
	oReport:PrintText("")

	cAliasMVN := oMapasPF:aTrab[MVN_POS][ALIAS_POS]
	cAliasTMM := oMapasPF:aTrab[TMM_POS][ALIAS_POS]
	cAliasTMT := oMapasPF:aTrab[TMT_POS][ALIAS_POS]
	cAliasTMA := oMapasPF:aTrab[TMA_POS][ALIAS_POS]

	(cAliasMVN)->(dbSetOrder(1))
	(cAliasMVN)->(dbGoTop())

    If oMapasPF:lMvAglut
        (cAliasTMM)->(DbSetOrder(2))
    Else
        (cAliasTMM)->(DbSetOrder(1))
    EndIf

	(cAliasTMM)->(dbGoTop())

	(cAliasTMT)->(dbSetOrder(1))
	(cAliasTMT)->(dbGoTop())

	(cAliasTMA)->(dbSetOrder(1))
	(cAliasTMA)->(dbGoTop())

	// Seção MVN
	While !(cAliasMVN)->(EoF())

		oSectioMVN:Init()
		oSectioMVN:SetHeaderSection(.T.)

		oSectioMVN:Cell("TIPO"):SetValue((cAliasMVN)->TIPO)
		oSectioMVN:Cell("NUMDOC"):SetValue(Alltrim((cAliasMVN)->NUMDOC) + "-" + Alltrim((cAliasMVN)->SERIE))
		oSectioMVN:Cell("CLIFOR"):SetValue((cAliasMVN)->CLIFOR + "-" + (cAliasMVN)->LOJA)
		oSectioMVN:Cell("ENTSAI"):SetValue((cAliasMVN)->ENTSAI)
		oSectioMVN:Cell("OPERACAO"):SetValue((cAliasMVN)->OPERACAO)

		oSectioMVN:PrintLine()

		oSectioMVN:Finish()

		oSectiMVN2:Init()
		oSectiMVN2:SetHeaderSection(.T.)

		oSectiMVN2:Cell("CNPJ"):SetValue((cAliasMVN)->CNPJ)
		oSectiMVN2:Cell("RAZAOSOC"):SetValue((cAliasMVN)->RAZAOSOC)
		oSectiMVN2:Cell("NUMERONF"):SetValue((cAliasMVN)->NUMERONF)
		oSectiMVN2:Cell("EMISSAONF"):SetValue((cAliasMVN)->EMISSAONF)
		oSectiMVN2:Cell("ARMAZENAG"):SetValue((cAliasMVN)->ARMAZENAG)
		oSectiMVN2:Cell("TRANSPORT"):SetValue((cAliasMVN)->TRANSPORT)

		oSectiMVN2:PrintLine()

		oSectiMVN2:Finish()

		cChave := (cAliasMVN)->NUMDOC + (cAliasMVN)->SERIE + (cAliasMVN)->CLIFOR + (cAliasMVN)->LOJA + (cAliasMVN)->ENTSAI + (cAliasMVN)->OPERACAO

		oSectionMM:Init()
		oSectionMM:SetHeaderSection(.T.)

        // Subseção MM
        While (cAliasTMM)->NUMDOC + (cAliasTMM)->SERIE + (cAliasTMM)->CLIFOR + (cAliasTMM)->LOJA + (cAliasTMM)->ENTSAI + (cAliasTMM)->OPERACAO == cChave

            oSectionMM:Cell("TIPO"):SetValue((cAliasTMM)->TIPO)
			If !oMapasPF:lMvAglut // Se a aglutinação estiver ativa, não faz sentido exibir o código do produto
				oSectionMM:Cell("COD"):SetValue((cAliasTMM)->COD)
			EndIf
			oSectionMM:Cell("CODNCM"):SetValue((cAliasTMM)->CODNCM)
			
			// O campo de Concentração só deve ser preenchido quando o Produto NÃO for composto
			If Left((cAliasTMM)->CODNCM, 2) $ "PR/RC"
				oSectionMM:Cell("CONCENT"):SetValue((cAliasTMM)->CONCENT)
			Else
				oSectionMM:Cell("CONCENT"):SetValue("")
			EndIf

			oSectionMM:Cell("DENSID"):SetValue((cAliasTMM)->DENSID)
			oSectionMM:Cell("QUANT"):SetValue((cAliasTMM)->QUANT)
			oSectionMM:Cell("UM"):SetValue((cAliasTMM)->UM)

			oSectionMM:PrintLine()

            (cAliasTMM)->(DbSkip())

        End

		oSectionMM:Finish()

		oSectionMT:Init() 
		oSectionMT:SetHeaderSection(.T.)

		// Subseção MT
        While (cAliasTMT)->NUMDOC + (cAliasTMT)->SERIE + (cAliasTMT)->CLIFOR + (cAliasTMT)->LOJA + (cAliasTMT)->ENTSAI + (cAliasTMT)->OPERACAO == cChave

            oSectionMT:Cell("TIPO"):SetValue((cAliasTMT)->TIPO)
			oSectionMT:Cell("CNPJ"):SetValue((cAliasTMT)->CNPJ)
			oSectionMT:Cell("RAZSOC"):SetValue((cAliasTMT)->RAZSOC)

			oSectionMT:PrintLine()

            (cAliasTMT)->(DbSkip())

        End

		oSectionMT:Finish()
		
		// Subseção MA
		While (cAliasTMA)->NUMDOC + (cAliasTMA)->SERIE + (cAliasTMA)->CLIFOR + (cAliasTMA)->LOJA + (cAliasTMA)->ENTSAI + (cAliasTMA)->OPERACAO == cChave

			oSectionMA:Init()
			oSectionMA:SetHeaderSection(.T.)

            oSectionMA:Cell("TIPO"):SetValue((cAliasTMA)->TIPO)
			oSectionMA:Cell("CNPJ"):SetValue((cAliasTMA)->CNPJ)
			oSectionMA:Cell("RAZSOC"):SetValue((cAliasTMA)->RAZSOC)

			oSectionMA:PrintLine()

			oSectionMA:Finish()

			oSectioMA2:Init()
			oSectioMA2:SetHeaderSection(.T.)

			oSectioMA2:Cell("ENDERECO"):SetValue((cAliasTMA)->ENDERECO)
			oSectioMA2:Cell("CEP"):SetValue((cAliasTMA)->CEP)
			oSectioMA2:Cell("NUMERO"):SetValue((cAliasTMA)->NUMERO)
			oSectioMA2:Cell("COMP"):SetValue((cAliasTMA)->COMP)
			oSectioMA2:Cell("BAIRRO"):SetValue((cAliasTMA)->BAIRRO)
			oSectioMA2:Cell("UF"):SetValue((cAliasTMA)->UF)
			oSectioMA2:Cell("CODMUNIC"):SetValue((cAliasTMA)->CODMUNIC)

			oSectioMA2:PrintLine()

			oSectioMA2:Finish()

            (cAliasTMA)->(DbSkip())

        End

		(cAliasMVN)->(dbSkip())

	End

	oReport:EndPage()

	oReport:IncMeter(1)

	oReport:ThinLine()
	oReport:PrintText("")
	oReport:PrtCenter(STR0209) // "S E Ç Ã O  M V I :  M O V I M E N T A Ç Õ E S  I N T E R N A C I O N A I S"
	oReport:PrintText("")
	oReport:PrintText("")
	oReport:ThinLine()
	oReport:PrintText("")
	oReport:PrintText("")

	cAliasMVI := oMapasPF:aTrab[MVI_POS][ALIAS_POS]
	cAliasTRA := oMapasPF:aTrab[TRA_POS][ALIAS_POS]
	cAliasTRI := oMapasPF:aTrab[TRI_POS][ALIAS_POS]
	cAliasAMZ := oMapasPF:aTrab[AMZ_POS][ALIAS_POS]
	cAliasTER := oMapasPF:aTrab[TER_POS][ALIAS_POS]
	cAliasTNF := oMapasPF:aTrab[TNF_POS][ALIAS_POS]
	cAliasNFI := oMapasPF:aTrab[NFI_POS][ALIAS_POS]

	(cAliasMVI)->(dbSetOrder(1))
	(cAliasMVI)->(dbGoTop())

	(cAliasTRA)->(dbSetOrder(1))
	(cAliasTRA)->(dbGoTop())

	(cAliasTRI)->(dbSetOrder(1))
	(cAliasTRI)->(dbGoTop())

	(cAliasAMZ)->(dbSetOrder(1))
	(cAliasAMZ)->(dbGoTop())

	(cAliasTER)->(dbSetOrder(1))
	(cAliasTER)->(dbGoTop())

	(cAliasTNF)->(dbSetOrder(1))
	(cAliasTNF)->(dbGoTop())

	If oMapasPF:lMvAglut
        (cAliasNFI)->(dbSetOrder(2))
    Else
        (cAliasNFI)->(dbSetOrder(1))
    EndIf
	(cAliasNFI)->(dbGoTop())

	//Seção MVI
	While !(cAliasMVI)->(EoF())

		oSectioMVI:Init()
		oSectioMVI:SetHeaderSection(.T.)

		oSectioMVI:Cell("TIPO"):SetValue((cAliasMVI)->TIPO)
		oSectioMVI:Cell("NUMDOC"):SetValue(Alltrim((cAliasMVI)->NUMDOC) + "-" + Alltrim((cAliasMVI)->SERIE))
		oSectioMVI:Cell("CLIFOR"):SetValue((cAliasMVI)->CLIFOR + "-" + (cAliasMVI)->LOJA)
		oSectioMVI:Cell("OPERACAO"):SetValue((cAliasMVI)->OPERACAO)
		oSectioMVI:Cell("PAIS"):SetValue((cAliasMVI)->PAIS)
		oSectioMVI:Cell("RAZAOSOC"):SetValue((cAliasMVI)->RAZAOSOC)
		oSectioMVI:Cell("LIRE"):SetValue((cAliasMVI)->LIRE)

		oSectioMVI:PrintLine()

		oSectioMVI:Finish()

		oSectiMVI2:Init()
		oSectiMVI2:SetHeaderSection(.T.)

		oSectiMVI2:Cell("RESTEMB"):SetValue((cAliasMVI)->RESTEMB)
		oSectiMVI2:Cell("CONHECEMB"):SetValue((cAliasMVI)->CONHECEMB)
		oSectiMVI2:Cell("DUE"):SetValue((cAliasMVI)->DUE)
		oSectiMVI2:Cell("DTDUE"):SetValue((cAliasMVI)->DTDUE)
		oSectiMVI2:Cell("DI"):SetValue((cAliasMVI)->DI)
		oSectiMVI2:Cell("DTDI"):SetValue((cAliasMVI)->DTDI)
		oSectiMVI2:Cell("ARMAZENAGE"):SetValue((cAliasMVI)->ARMAZENAGE)
		oSectiMVI2:Cell("TRANSPORT"):SetValue((cAliasMVI)->TRANSPORT)
		oSectiMVI2:Cell("ENTREGA"):SetValue((cAliasMVI)->ENTREGA)

		oSectiMVI2:PrintLine()

		oSectiMVI2:Finish()

		cChave := (cAliasMVI)->NUMDOC + (cAliasMVI)->SERIE + (cAliasMVI)->CLIFOR + (cAliasMVI)->LOJA + (cAliasMVI)->OPERACAO + (cAliasMVI)->LIRE

		oSectioTRA:Init()
		oSectioTRA:SetHeaderSection(.T.)

		// Subseção TRA
        While (cAliasTRA)->NUMDOC + (cAliasTRA)->SERIE + (cAliasTRA)->CLIFOR + (cAliasTRA)->LOJA + (cAliasTRA)->OPERACAO + (cAliasTRA)->LIRE == cChave

            oSectioTRA:Cell("TIPO"):SetValue((cAliasTRA)->TIPO)
			oSectioTRA:Cell("CNPJ"):SetValue((cAliasTRA)->CNPJ)
			oSectioTRA:Cell("RAZAOSOC"):SetValue((cAliasTRA)->RAZAOSOC)

			oSectioTRA:PrintLine()

            (cAliasTRA)->(DbSkip())

        End

		oSectioTRA:Finish()

		oSectioTRI:Init()
		oSectioTRI:SetHeaderSection(.T.)

		// Subseção TRI
        While (cAliasTRI)->NUMDOC + (cAliasTRI)->SERIE + (cAliasTRI)->CLIFOR + (cAliasTRI)->LOJA + (cAliasTRI)->OPERACAO + (cAliasTRI)->LIRE == cChave

            oSectioTRI:Cell("TIPO"):SetValue((cAliasTRI)->TIPO)
			oSectioTRI:Cell("RAZAOSOC"):SetValue((cAliasTRI)->RAZAOSOC)

			oSectioTRI:PrintLine()

            (cAliasTRI)->(DbSkip())

        End

		oSectioTRI:Finish()

		// Subseção AMZ
		While (cAliasAMZ)->NUMDOC + (cAliasAMZ)->SERIE + (cAliasAMZ)->CLIFOR + (cAliasAMZ)->LOJA + (cAliasAMZ)->OPERACAO + (cAliasAMZ)->LIRE == cChave

			oSectioAMZ:Init()
			oSectioAMZ:SetHeaderSection(.T.)

            oSectioAMZ:Cell("TIPO"):SetValue((cAliasAMZ)->TIPO)
			oSectioAMZ:Cell("CNPJ"):SetValue((cAliasAMZ)->CNPJ)
			oSectioAMZ:Cell("RAZSOC"):SetValue((cAliasAMZ)->RAZSOC)

			oSectioAMZ:PrintLine()

			oSectioAMZ:Finish()

			oSectiAMZ2:Init()
			oSectiAMZ2:SetHeaderSection(.T.)

			oSectiAMZ2:Cell("ENDERECO"):SetValue((cAliasAMZ)->ENDERECO)
			oSectiAMZ2:Cell("CEP"):SetValue((cAliasAMZ)->CEP)
			oSectiAMZ2:Cell("NUMERO"):SetValue((cAliasAMZ)->NUMERO)
			oSectiAMZ2:Cell("COMP"):SetValue((cAliasAMZ)->COMP)
			oSectiAMZ2:Cell("BAIRRO"):SetValue((cAliasAMZ)->BAIRRO)
			oSectiAMZ2:Cell("UF"):SetValue((cAliasAMZ)->UF)
			oSectiAMZ2:Cell("CODMUNIC"):SetValue((cAliasAMZ)->CODMUNIC)

			oSectiAMZ2:PrintLine()

			oSectiAMZ2:Finish()

            (cAliasAMZ)->(DbSkip())

        End

		// Subseção TER
		While (cAliasTER)->NUMDOC + (cAliasTER)->SERIE + (cAliasTER)->CLIFOR + (cAliasTER)->LOJA + (cAliasTER)->OPERACAO + (cAliasTER)->LIRE == cChave

			oSectioTER:Init()
			oSectioTER:SetHeaderSection(.T.)

            oSectioTER:Cell("TIPO"):SetValue((cAliasTER)->TIPO)
			oSectioTER:Cell("CNPJ"):SetValue((cAliasTER)->CNPJ)
			oSectioTER:Cell("RAZSOC"):SetValue((cAliasTER)->RAZSOC)

			oSectioTER:PrintLine()

			oSectioTER:Finish()

			oSectiTER2:Init()
			oSectiTER2:SetHeaderSection(.T.)

			oSectiTER2:Cell("ENDERECO"):SetValue((cAliasTER)->ENDERECO)
			oSectiTER2:Cell("CEP"):SetValue((cAliasTER)->CEP)
			oSectiTER2:Cell("NUMERO"):SetValue((cAliasTER)->NUMERO)
			oSectiTER2:Cell("COMP"):SetValue((cAliasTER)->COMP)
			oSectiTER2:Cell("BAIRRO"):SetValue((cAliasTER)->BAIRRO)
			oSectiTER2:Cell("UF"):SetValue((cAliasTER)->UF)
			oSectiTER2:Cell("CODMUNIC"):SetValue((cAliasTER)->CODMUNIC)

			oSectiTER2:PrintLine()

			oSectiTER2:Finish()

            (cAliasTER)->(DbSkip())

        End

		oSectionNF:Init()
		oSectionNF:SetHeaderSection(.T.)

		// Subseção NF
        While (cAliasTNF)->NUMDOC + (cAliasTNF)->SERIE + (cAliasTNF)->CLIFOR + (cAliasTNF)->LOJA + (cAliasTNF)->OPERACAO + (cAliasTNF)->LIRE == cChave

            oSectionNF:Cell("TIPO"):SetValue((cAliasTNF)->TIPO)
			oSectionNF:Cell("NUMERONF"):SetValue((cAliasTNF)->NUMERONF)
			oSectionNF:Cell("EMISSAONF"):SetValue((cAliasTNF)->EMISSAONF)
			oSectionNF:Cell("ENTSAI"):SetValue((cAliasTNF)->ENTSAI)

			oSectionNF:PrintLine()

            (cAliasTNF)->(DbSkip())

        End

		oSectionNF:Finish()

		oSectioNFI:Init()
		oSectioNFI:SetHeaderSection(.T.)

        // Subseção NFI - Continuação
        While (cAliasNFI)->NUMDOC + (cAliasNFI)->SERIE + (cAliasNFI)->CLIFOR + (cAliasNFI)->LOJA + (cAliasNFI)->OPERACAO + (cAliasNFI)->LIRE == cChave

			If !oMapasPF:lMvAglut // Se a aglutinação estiver ativa, não faz sentido exibir o código do produto
				oSectioNFI:Cell("COD"):SetValue((cAliasNFI)->COD)
			EndIf
			oSectioNFI:Cell("CODNCM"):SetValue((cAliasNFI)->CODNCM)
			
			// O campo de Concentração só deve ser preenchido quando o Produto NÃO for composto
			If Left((cAliasNFI)->CODNCM, 2) $ "PR/RC"
				oSectioNFI:Cell("CONCENT"):SetValue((cAliasNFI)->CONCENT)
			Else
				oSectioNFI:Cell("CONCENT"):SetValue("")
			EndIf

			oSectioNFI:Cell("DENSID"):SetValue((cAliasNFI)->DENSID)
			oSectioNFI:Cell("QUANT"):SetValue((cAliasNFI)->QUANT)
			oSectioNFI:Cell("UM"):SetValue((cAliasNFI)->UM)

			oSectioNFI:PrintLine()

            (cAliasNFI)->(DbSkip())

        End

		oSectioNFI:Finish()

		(cAliasMVI)->(dbSkip())

	End

	oReport:EndPage()

	oReport:IncMeter(1)

	oReport:ThinLine()
	oReport:PrintText("")
	oReport:PrtCenter(STR0187) // "S E Ç Ã O  U P :  U T I L I Z A Ç Ã O  P A R A  P R O D U Ç Ã O"
	oReport:PrintText("")
	oReport:PrintText("")
	oReport:ThinLine()
	oReport:PrintText("")
	oReport:PrintText("")

	cAliasTUP := oMapasPF:aTrab[TUP_POS][ALIAS_POS]
	cAliasTUF := oMapasPF:aTrab[TUF_POS][ALIAS_POS]

	If oMapasPF:lMvAglut

		(cAliasTUP)->(dbSetOrder(3))
		(cAliasTUP)->(dbGoTop())

		(cAliasTUF)->(dbSetOrder(3))
		(cAliasTUF)->(dbGoTop())

		cChaveAnt := DtoS((cAliasTUP)->EMISSAO) + (cAliasTUP)->CODNCMPAI + StrZero((cAliasTUP)->CONCENTPAI, 3) + StrZero((cAliasTUP)->DENSIDPAI) + Iif(Empty((cAliasTUP)->UMPAI), " ", (cAliasTUP)->UMPAI) + (cAliasTUP)->TM

	Else

		(cAliasTUP)->(dbSetOrder(2))
		(cAliasTUP)->(dbGoTop())

		(cAliasTUF)->(dbSetOrder(2))
		(cAliasTUF)->(dbGoTop())

		cChaveAnt := DtoS((cAliasTUP)->EMISSAO) + (cAliasTUP)->NUMSEQ     

	EndIf

	oSectionUP:Init() 
	oSectionUP:SetHeaderSection(.T.)

	While !(cAliasTUP)->(EoF())

		// Impressão UP
		oSectionUP:Cell("TIPO"):SetValue((cAliasTUP)->TIPO)
		If !oMapasPF:lMvAglut // Se a aglutinação estiver ativa, não faz sentido exibir o código do produto
			oSectionUP:Cell("COD"):SetValue((cAliasTUP)->COD)
		EndIf
		oSectionUP:Cell("CODNCM"):SetValue((cAliasTUP)->CODNCM)

		// O campo de Concentração só deve ser preenchido quando o Produto NÃO for composto
		If Left((cAliasTUP)->CODNCM, 2) $ "PR/RC"
			oSectionUP:Cell("CONCENT"):SetValue((cAliasTUP)->CONCENT)
		Else
			oSectionUP:Cell("CONCENT"):SetValue("")
		EndIf

		oSectionUP:Cell("DENSID"):SetValue((cAliasTUP)->DENSID)
		oSectionUP:Cell("QUANT"):SetValue((cAliasTUP)->QUANT)
		oSectionUP:Cell("UM"):SetValue((cAliasTUP)->UM)

		oSectionUP:PrintLine()

        (cAliasTUP)->(DbSkip())

        If !(cAliasTUP)->(EoF())
            
            If oMapasPF:lMvAglut
                cChaveAtu := DtoS((cAliasTUP)->EMISSAO) + (cAliasTUP)->CODNCMPAI + StrZero((cAliasTUP)->CONCENTPAI, 3) + StrZero((cAliasTUP)->DENSIDPAI) + Iif(Empty((cAliasTUP)->UMPAI), " ", (cAliasTUP)->UMPAI) + (cAliasTUP)->TM
            Else
                cChaveAtu := DtoS((cAliasTUP)->EMISSAO) + (cAliasTUP)->NUMSEQ
            EndIf
        
        EndIf
        
        If ((cAliasTUP)->(EoF()) .Or. cChaveAtu != cChaveAnt) .And. !(cAliasTUF)->(EoF())

			oSectionUP:Finish()

            // Impressão UF
			oSectionUF:Init()
			oSectionUF:SetHeaderSection(.T.) 

			oSectionUF:Cell("TIPO"):SetValue((cAliasTUF)->TIPO)
			If !oMapasPF:lMvAglut // Se a aglutinação estiver ativa, não faz sentido exibir o código do produto
				oSectionUF:Cell("COD"):SetValue((cAliasTUF)->COD)
			EndIf
			oSectionUF:Cell("CODNCM"):SetValue((cAliasTUF)->CODNCM)

			// O campo de Concentração só deve ser preenchido quando o Produto NÃO for composto
			If Left((cAliasTUF)->CODNCM, 2) $ "PR/RC"
				oSectionUF:Cell("CONCENT"):SetValue((cAliasTUF)->CONCENT)
			Else
				oSectionUF:Cell("CONCENT"):SetValue("")
			EndIf

			oSectionUF:Cell("DENSID"):SetValue((cAliasTUF)->DENSID)
			oSectionUF:Cell("QUANT"):SetValue((cAliasTUF)->QUANT)
			oSectionUF:Cell("UM"):SetValue((cAliasTUF)->UM)
			oSectionUF:Cell("EMISSAO"):SetValue((cAliasTUF)->EMISSAO)

			oSectionUF:PrintLine()

			oSectionUF:Finish()

			oSectioUF2:Init()
			oSectioUF2:SetHeaderSection(.T.) 

			oSectioUF2:Cell("DESCPROD"):SetValue((cAliasTUF)->DESCPROD)
			
			oSectioUF2:PrintLine()
			oSectioUF2:Finish()

            (cAliasTUF)->(dbSkip())

			oSectionUP:Init()
			oSectionUP:SetHeaderSection(.T.) 

        EndIf

        cChaveAnt := cChaveAtu

    End

	oSectionUP:Finish()

	oReport:EndPage()

	oReport:IncMeter(1)

	oReport:ThinLine()
	oReport:PrintText("")
	oReport:PrtCenter(STR0188) // "S E Ç Ã O  U C :  C O N S U M O S"
	oReport:PrintText("")
	oReport:PrintText("")
	oReport:ThinLine()
	oReport:PrintText("")
	oReport:PrintText("")

	cAliasTUC := oMapasPF:aTrab[TUC_POS][ALIAS_POS]

	If oMapasPF:lMvAglut
        (cAliasTUC)->(dbSetOrder(1))
    Else
        (cAliasTUC)->(dbSetOrder(2))
    Endif

	(cAliasTUC)->(dbGoTop())

	oSectionUC:Init()
	oSectionUC:SetHeaderSection(.T.) 

	While !(cAliasTUC)->(EoF())

		oSectionUC:Cell("TIPO"):SetValue((cAliasTUC)->TIPO)
		If !oMapasPF:lMvAglut // Se a aglutinação estiver ativa, não faz sentido exibir o código do produto
			oSectionUC:Cell("COD"):SetValue((cAliasTUC)->COD)
		EndIf
		oSectionUC:Cell("CODNCM"):SetValue((cAliasTUC)->CODNCM)
		
		// O campo de Concentração só deve ser preenchido quando o Produto NÃO for composto
		If Left((cAliasTUC)->CODNCM, 2) $ "PR/RC"
			oSectionUC:Cell("CONCENT"):SetValue((cAliasTUC)->CONCENT)
		Else
			oSectionUC:Cell("CONCENT"):SetValue("")
		EndIf

		oSectionUC:Cell("DENSID"):SetValue((cAliasTUC)->DENSID)
		oSectionUC:Cell("QUANT"):SetValue((cAliasTUC)->QUANT)
		oSectionUC:Cell("UM"):SetValue((cAliasTUC)->UM)
		oSectionUC:Cell("CODCONSUMO"):SetValue((cAliasTUC)->CODCONSUMO)
		oSectionUC:Cell("OBSERVACAO"):SetValue((cAliasTUC)->OBSERVACAO)
		oSectionUC:Cell("EMISSAO"):SetValue((cAliasTUC)->EMISSAO)

		oSectionUC:PrintLine()

        (cAliasTUC)->(dbSkip())

    End

	oSectionUC:Finish()

	oReport:EndPage()

	oReport:IncMeter(1)

	oReport:ThinLine()
	oReport:PrintText("")
	oReport:PrtCenter(STR0189) // "S E Ç Ã O  F B :  F A B R I C A Ç Ã O"
	oReport:PrintText("")
	oReport:PrintText("")
	oReport:ThinLine()
	oReport:PrintText("")
	oReport:PrintText("")

	cAliasTFB := oMapasPF:aTrab[TFB_POS][ALIAS_POS]

	If oMapasPF:lMvAglut
        (cAliasTFB)->(dbSetOrder(1))
    Else
        (cAliasTFB)->(dbSetOrder(2))
    Endif

	(cAliasTFB)->(dbGoTop())

	oSectionFB:Init()
	oSectionFB:SetHeaderSection(.T.) 

	While !(cAliasTFB)->(EoF())

        oSectionFB:Cell("TIPO"):SetValue((cAliasTFB)->TIPO)
		If !oMapasPF:lMvAglut // Se a aglutinação estiver ativa, não faz sentido exibir o código do produto
			oSectionFB:Cell("COD"):SetValue((cAliasTFB)->COD)
		EndIf
		oSectionFB:Cell("CODNCM"):SetValue((cAliasTFB)->CODNCM)
		
		// O campo de Concentração só deve ser preenchido quando o Produto NÃO for composto
		If Left((cAliasTFB)->CODNCM, 2) $ "PR/RC"
			oSectionFB:Cell("CONCENT"):SetValue((cAliasTFB)->CONCENT)
		Else
			oSectionFB:Cell("CONCENT"):SetValue("")
		EndIf

		oSectionFB:Cell("DENSID"):SetValue((cAliasTFB)->DENSID)
		oSectionFB:Cell("QUANT"):SetValue((cAliasTFB)->QUANT)
		oSectionFB:Cell("UM"):SetValue((cAliasTFB)->UM)
		oSectionFB:Cell("EMISSAO"):SetValue((cAliasTFB)->EMISSAO)

		oSectionFB:PrintLine()

        (cAliasTFB)->(dbSkip())

    End

	oSectionFB:Finish()

	oReport:EndPage()

	oReport:IncMeter(1)

	oReport:ThinLine()
	oReport:PrintText("")
	oReport:PrtCenter(STR0190) // "S E Ç Ã O  T N :  T R A N S P O R T E  N A C I O N A L"
	oReport:PrintText("")
	oReport:PrintText("")
	oReport:ThinLine()
	oReport:PrintText("")
	oReport:PrintText("")

	cAliasTTN := oMapasPF:aTrab[TTN_POS][ALIAS_POS]
	cAliasTCC := oMapasPF:aTrab[TCC_POS][ALIAS_POS]
	cAliasTTM := oMapasPF:aTrab[TTM_POS][ALIAS_POS]

	(cAliasTTN)->(dbSetOrder(1))
	(cAliasTTN)->(dbGoTop())

	(cAliasTCC)->(dbSetOrder(1))
	(cAliasTCC)->(dbGoTop())

	If oMapasPF:lMvAglut
        (cAliasTTM)->(dbSetOrder(2))
    Else
        (cAliasTTM)->(dbSetOrder(1))
    EndIf

	(cAliasTTM)->(dbGoTop())

	While !(cAliasTTN)->(EoF())

		cChave := (cAliasTTN)->NUMDOC + (cAliasTTN)->SERIE + (cAliasTTN)->CLIFOR + (cAliasTTN)->LOJA + (cAliasTTN)->ENTSAI

		oSectionTN:Init()
		oSectionTN:SetHeaderSection(.T.) 

		oSectionTN:Cell("TIPO"):SetValue((cAliasTTN)->TIPO)
		oSectionTN:Cell("NUMDOC"):SetValue(Alltrim((cAliasTTN)->NUMDOC) + "-" + Alltrim((cAliasTTN)->SERIE))
		oSectionTN:Cell("CLIFOR"):SetValue((cAliasTTN)->CLIFOR + "-" + (cAliasTTN)->LOJA)
		oSectionTN:Cell("CGCCONTRAT"):SetValue((cAliasTTN)->CGCCONTRAT)
		oSectionTN:Cell("NOMECONTRA"):SetValue((cAliasTTN)->NOMECONTRA)
		
		oSectionTN:PrintLine()

		oSectionTN:Finish()

		oSectioTN2:Init()
		oSectioTN2:SetHeaderSection(.T.) 

		oSectioTN2:Cell("NUMERONF"):SetValue((cAliasTTN)->NUMERONF)
		oSectioTN2:Cell("EMISSAONF"):SetValue((cAliasTTN)->EMISSAONF)
		oSectioTN2:Cell("CGCORIGEM"):SetValue((cAliasTTN)->CGCORIGEM)
		oSectioTN2:Cell("NOMEORIGEM"):SetValue((cAliasTTN)->NOMEORIGEM)
		oSectioTN2:Cell("RETIRADA"):SetValue((cAliasTTN)->RETIRADA)
		oSectioTN2:Cell("ENTREGA"):SetValue((cAliasTTN)->ENTREGA)

		oSectioTN2:PrintLine()

		oSectioTN2:Finish()

		oSectionCC:Init()
		oSectionCC:SetHeaderSection(.T.) 

		While (cAliasTCC)->NUMDOC + (cAliasTCC)->SERIE + (cAliasTCC)->CLIFOR + (cAliasTCC)->LOJA + (cAliasTCC)->ENTSAI == cChave

            oSectionCC:Cell("TIPO"):SetValue((cAliasTCC)->TIPO)
			oSectionCC:Cell("NUMCC"):SetValue((cAliasTCC)->NUMCC)
			oSectionCC:Cell("DATACC"):SetValue((cAliasTCC)->DATACC)
			oSectionCC:Cell("DATARECEB"):SetValue((cAliasTCC)->DATARECEB)
			oSectionCC:Cell("RESPRECEB"):SetValue((cAliasTCC)->RESPRECEB)
			oSectionCC:Cell("MODALTRANS"):SetValue((cAliasTCC)->MODALTRANS)

			oSectionCC:PrintLine()

            (cAliasTCC)->(dbSkip())

        End

		oSectionCC:Finish()

		oSectionTM:Init()
		oSectionTM:SetHeaderSection(.T.) 

		While (cAliasTTM)->NUMDOC + (cAliasTTM)->SERIE + (cAliasTTM)->CLIFOR + (cAliasTTM)->LOJA + (cAliasTTM)->ENTSAI == cChave

            oSectionTM:Cell("TIPO"):SetValue((cAliasTTM)->TIPO)
			If !oMapasPF:lMvAglut // Se a aglutinação estiver ativa, não faz sentido exibir o código do produto
				oSectionTM:Cell("COD"):SetValue((cAliasTTM)->COD)
			EndIf
			oSectionTM:Cell("CODNCM"):SetValue((cAliasTTM)->CODNCM)
			
			// O campo de Concentração só deve ser preenchido quando o Produto NÃO for composto
			If Left((cAliasTTM)->CODNCM, 2) $ "PR/RC"
				oSectionTM:Cell("CONCENT"):SetValue((cAliasTTM)->CONCENT)
			Else
				oSectionTM:Cell("CONCENT"):SetValue("")
			EndIf

			oSectionTM:Cell("DENSID"):SetValue((cAliasTTM)->DENSID)
			oSectionTM:Cell("QUANT"):SetValue((cAliasTTM)->QUANT)
			oSectionTM:Cell("UM"):SetValue((cAliasTTM)->UM)

			oSectionTM:PrintLine()

            (cAliasTTM)->(dbSkip())

        End

		oSectionTM:Finish()

        (cAliasTTN)->(dbSkip())

    End

	oMapasPF:Destructor()

	FreeObj(oMapasPF)

Return
