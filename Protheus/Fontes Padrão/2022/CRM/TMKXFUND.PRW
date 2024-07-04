#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMKXFUND.CH"
#INCLUDE "PARMTYPE.CH" 

//cPeriod
#DEFINE DIARY		"D"
#DEFINE WEEKLY		"W"
#DEFINE MONTHLY 	"M"
#DEFINE YEARLY		"Y"

//nOpc
#DEFINE VIEW	00
#DEFINE DELETE  01
#DEFINE INSERT  02
#DEFINE UPDATE  03

Static lVisuOrc  := .F.		// Flag que indica se o orcamento foi visualizado

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TkHistLoj ºAutor  ³Rafael M Quadrotti  º Data ³  05/21/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Dialog com os orcamentos e pedidos gerados a partir do      º±±
±±º          ³Sigaloja                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpC1 : Codigo do cliente                                  º±±
±±º          ³ ExpC2 : Codigo do Produto                                  º±±
±±º          ³ ExpC3 : Tipo de operacao                                   º±±
±±º          ³ ExpL1 : Flag de visualizacao do orcamento                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 -Call Center                                           º±±
±±³Analista  ³Data    ³Versao³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcelo K ³04/12/02³609   ³-O total do rodape nao esta sendo somado    ³±±
±±³Rafael Q. ³10/12/02³609   ³-Alterada validacao para p/ carregar a variá³±±
±±³          ³        ³      ³vel cMoeda.                                 ³±±
±±³Mauro Sano³04/10/07³130141³-Criado parametro para vreificar se o orca  ³±±
±±³          ³        ³      ³mento do loja foi visualizado e fazer no    ³±±
±±³          ³        ³      ³LOJA701 a inicializacao do MaFisIni.        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TkHistLoj(cCliente,cProduto,cTip, lVisualizou)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Definicao das Variaveis.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aArea 	:= GetArea()			// Salva a area anterior 
Local aAlias	:= {}  					// Auxiliar para manipular as tabelas 
Local oDlg		:= Nil					// Tela
Local cCadastro := STR0001 				// "Consulta de orcamentos SigaLoja"
Local cCgc		:= RetTitle("A1_CGC")	// Armazena titulo CGC
Local cMoeda    := IIf(SA1->A1_MOEDALC > 0, AllTrim(Transform(SA1->A1_MOEDALC,"99")), SuperGetMv("MV_MCUSTO"))	
Local aSavAhead := If(Type("aHeader")=="A",aHeader,{})		// Auxiliar do aHeader	
Local aSavAcol  := If(Type("aCols")=="A",aCols,{})			// Auxiliar do aCols
Local nSavN     := If(Type("aCols")=="A",n,0)				// Auxiliar que armazena a posicao do aCols					
Local cColor    := CLR_BLUE									// Cor da janela
Local nCasas 	:= SuperGetMv("MV_CENT")					// Numero de casas decimais
Local lRet		:= .F.										// Retorno da funcao	
Local aPDFields	:= {"A1_NOME","A1_CGC","A1_TEL","A1_LC","A1_METR","A1_RISCO","A1_CHQDEVO","A3_NOME"}

Default lVisualizou := .F.									// Flag que armazena se o orcamento foi visualizado ou nao

FATPDLoad(Nil, Nil, aPDFields)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa a Static com o recebido como parametro.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lVisuOrc := lVisualizou                           

cTip 	:= If( cTip == NIL, "1", cTip ) 
cMoeda 	:= " "+Pad(Getmv("MV_SIMB"+cMoeda),4)

If Empty( cCliente )
	Help(" ",1,"SEM CLIENT" )
	Return(lRet)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem da tela.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DEFINE MSDIALOG oDlg FROM	09,0 TO 28,80 TITLE cCadastro OF oMainWnd
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Dados do Cliente.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 001,002 TO 043, 267 OF oDlg	PIXEL
	
	@ 004,005 SAY STR0002    	SIZE 025,07  OF oDlg PIXEL //"Codigo"
	@ 012,004 SAY SA1->A1_COD   SIZE 070,09  COLOR cColor OF oDlg PIXEL
	
	@ 004,077 SAY STR0003    	SIZE 020,07  OF oDlg PIXEL //"Loja"
	@ 012,077 SAY SA1->A1_LOJA  SIZE 021,09  COLOR cColor OF oDlg PIXEL
	
	@ 004,100 SAY STR0004    	SIZE 025,07  OF oDlg PIXEL //"Nome"
	@ 012,100 SAY FATPDObfuscate(SA1->A1_NOME,"A1_NOME")	SIZE 150,09  COLOR cColor OF oDlg  PIXEL
	
	@ 023,005 SAY cCGC       	SIZE 025,07  OF oDlg PIXEL
	@ 030,004 SAY FATPDObfuscate(Transform(SA1->A1_CGC, PesqPict("SA1","A1_CGC")),"A1_CGC") SIZE 070,09 COLOR cColor  OF oDlg PIXEL
	
	@ 023,077 SAY STR0005    	SIZE 025,07  OF oDlg PIXEL //"Telefone"
	@ 030,077 SAY FATPDObfuscate(Transform(SA1->A1_TEL, PesqPict("SA1","A1_TEL")),"A1_TEL") SIZE 060,09 COLOR cColor  OF oDlg PIXEL
	
	@ 023,141 SAY RetTitle("A1_VENCLC") SIZE 035,07  OF oDlg PIXEL
	@ 030,141 SAY SA1->A1_VENCLC        SIZE 060,09  COLOR cColor OF oDlg PIXEL
	
	@ 023,206 SAY STR0006   SIZE 035,07  OF oDlg PIXEL //"Vendedor"
	@ 030,206 SAY SA1->A1_VEND  	     SIZE 053,09  COLOR cColor OF oDlg PIXEL
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Itens da tela.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 045,002 TO 107, 267 OF oDlg	PIXEL
	
	@ 051,005 SAY STR0009        	SIZE 042,07 OF oDlg PIXEL //"Saldo Atual"
	@ 049,058 SAY SA1->A1_SALDUP    SIZE 053,09 PICTURE Tm(SA1->A1_SALDUP,15,nCasas) COLOR cColor  OF oDlg PIXEL
	
	@ 062,005 SAY STR0010+cMoeda 	SIZE 047,07 OF oDlg PIXEL //"Maior Compra"
	@ 060,058 SAY SA1->A1_MCOMPRA   SIZE 053,09 PICTURE Tm(SA1->A1_MCOMPRA,15,nCasas) COLOR cColor  OF oDlg PIXEL
	
	@ 073,005 SAY STR0011+cMoeda 	SIZE 047,07 OF oDlg PIXEL //"Maior Saldo "
	@ 071,058 SAY SA1->A1_MSALDO    SIZE 053,09 PICTURE Tm(SA1->A1_MSALDO,15,nCasas)  COLOR cColor  OF oDlg PIXEL
	
	@ 085,005 SAY STR0012+cMoeda 	SIZE 052,07 OF oDlg PIXEL //"Saldo Atual em "
	@ 083,058 SAY SA1->A1_SALDUPM   SIZE 053,09 PICTURE Tm(SA1->A1_SALDUPM,15,nCasas) COLOR cColor   OF oDlg PIXEL
	
	@ 096,005 SAY STR0013        	SIZE 047,07 OF oDlg PIXEL //"Limite Cr‚dito"
	@ 094,058 SAY FATPDObfuscate(SA1->A1_LC,"A1_LC")	SIZE 053,09 PICTURE Tm(SA1->A1_LC,15,nCasas)  COLOR cColor OF oDlg PIXEL
	
	@ 051,152 SAY STR0014         	SIZE 047,07 OF oDlg PIXEL //"Primeira Compra"
	@ 049,206 SAY SA1->A1_PRICOM    SIZE 053,09  COLOR cColor OF oDlg PIXEL
	
	@ 062,152 SAY STR0015         	SIZE 047,7 OF oDlg PIXEL //"Ultima Compra"
	@ 060,206 SAY SA1->A1_ULTCOM    SIZE 053,09  COLOR cColor OF oDlg PIXEL
	
	@ 073,152 SAY STR0016         	SIZE 047,07 OF oDlg PIXEL //"Maior Atraso"
	@ 071,206 SAY SA1->A1_MATR      SIZE 053,09 PICTURE "@9" COLOR cColor OF oDlg PIXEL
	
	@ 085,152 SAY STR0017         	SIZE 047,07 OF oDlg PIXEL //"Media de Atraso"
	@ 083,206 SAY FATPDObfuscate(SA1->A1_METR,"A1_METR")	SIZE 053,09 PICTURE "@9"  COLOR cColor OF oDlg PIXEL
	
	@ 096,152 SAY STR0018         	SIZE 047,07 OF oDlg PIXEL //"Grau de Risco"
	@ 094,206 SAY FATPDObfuscate(SA1->A1_RISCO,"A1_RISCO")	SIZE 053,09  COLOR cColor OF oDlg PIXEL
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Rodape.     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 115,002 TO 139, 114 OF oDlg	PIXEL
	@ 109,002 SAY STR0019  SIZE 061,07 OF oDlg PIXEL //"Cheques Devolvidos"
	@ 109,121 SAY STR0020  SIZE 061,07 OF oDlg PIXEL //"Titulos Protestados"
	
	@ 115,121 TO 139, 267 OF oDlg	PIXEL
	@ 118,005 SAY STR0021  SIZE 034,07 OF oDlg PIXEL //"Quantidade"
	@ 118,045 SAY STR0022  SIZE 066,07 OF oDlg PIXEL //"Ultimo Devolvido"
	@ 118,126 SAY STR0021  SIZE 034,07 OF oDlg PIXEL //"Quantidade"
	@ 118,163 SAY STR0023  SIZE 063,07 OF oDlg PIXEL //"Ultimo Protesto"
	
	@ 126,006 SAY FATPDObfuscate(SA1->A1_CHQDEVO,"A1_CHQDEVO")	SIZE 024,08  COLOR cColor OF oDlg PIXEL
	@ 126,045 SAY SA1->A1_DTULCHQ     SIZE 034,08  COLOR cColor OF oDlg PIXEL
	@ 126,126 SAY FATPDObfuscate(SA1->A1_TITPROT,"A1_TITPROT")     SIZE 024,08  COLOR cColor OF oDlg PIXEL
	@ 126,163 SAY SA1->A1_DTULTIT     SIZE 034,08  COLOR cColor OF oDlg PIXEL
	
	@ 003,272 BUTTON STR0024 SIZE 40,12 FONT oDlg:oFont ACTION (lRet:= .T.,TkBrowse(1,@aAlias,.T.)) OF oDlg PIXEL //Orcamentos
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³O botao de consulta por Produto e valido somente para as rotinas de Telemarketing e Televendas      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (nFolder <> 3) 
	 	IF(cTip <> "3") //Para CRM  "3" = Telecobranca
			@ 020,272 BUTTON STR0045 SIZE 40,12 FONT oDlg:oFont ACTION (lRet:= .T.,TkBrowse(2,@aAlias,.T.,cProduto)) OF oDlg PIXEL //produto
        Endif
    Endif

	@ 043,272 BUTTON STR0055 SIZE 40,12 FONT oDlg:oFont ACTION (Lj010Brow({'SA1'},Recno())) OF oDlg PIXEL //"Tit Aberto"
	
	@ 130,272 BUTTON STR0025 SIZE 40,12 FONT oDlg:oFont ACTION (lRet:= .F.,oDlg:End()) OF oDlg PIXEL //"Sair"

	FATPDLogUser("TKHISTLOJ")  

ACTIVATE MSDIALOG oDlg CENTERED

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura a Integridade dos Dados                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeader := aSavAHead
aCols   := aSavaCol
n       := nSavN

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Devolve para a variavel passada como parametro o estado³
//³da flag.                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lVisualizou := lVisuOrc 

FATPDUnload()
DbSelectArea("SA1")
RestArea(aArea)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³	Funcao	 ³	TkBrowse³Autor  ³Rafael M. Quadrotti    ³ Data ³22.05.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³ Pesquisa e exibe Orcamentos e Pedidos Feitos no SigaLoja   ³±±
±±³          ³ referentes ao cliente posicionado.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 : nOpcao                                             ³±±
±±³          ³         [1] Orcamentos                                     ³±±
±±³          ³         [2] Pedidos                                        ³±±
±±³          ³ ExpA2 : Alias a Serem Fechados.                            ³±±
±±³          ³ ExpL4 : Indica se os dados devem ser exibidos              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³25/04/06  ³Danilo Calil   ³Correcao da sintaxe da Query.               ³±±
±±³04/10/07  ³Mauro Sano     ³PMC: Passagem de 4 parametros por linha     ³±± 
±±³          ³BOPS 130141    ³PMC: Troca de GetMv para SuperGetMv         ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TkBrowse(nBrowse,aAlias,lExibe,cProduto)

Local aArea		:= GetArea()			// GetArea
Local aAreaSA1	:= SA1->(GetArea())		// GetArea do SA1
Local aAreaSL1	:= SL1->(GetArea())		// GetArea do SL1
Local aAreaSL2	:= SL2->(GetArea())		// GetArea do SL2
Local aStru		:= {}					// Strutura de arquivo
Local aQuery	:= {}					// Querys
Local aGet		:= {"",""}				// Array Get
Local oLbx		:= Nil					// Objeto
Local nCntList							// Contador para lista
Local aCampos	:= {}					// Array para armazenar campos
Local oDlg		:= Nil					// Objeto para Dialog
Local oBtn		:= Nil					// Objeto para Botao
Local bVisual							// Botao Visual
Local bWhile							// While
Local cAlias	:= ""					// Alias
Local cArquivo	:= ""					// Nome do arquivo
Local cCadastro	:= ""					// Armazena o nome da execusao	
Local cQry		:= ""					// Nome do arquivo - SL1
Local cChave	:= ""					// Chave
Local nCntFor	:= 0					// Contador de For
Local oTempTable:= NIL
Local cQuery    := ""
Local aPDCols	:= {}

Private aHeader := {} 

aAlias := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica qual botao foi executado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	Case (nBrowse == 1)
		 cCadastro	:= STR0046 //"Orcamentos X Faturamento"
		 cAlias		:= GetNextAlias()
		 bVisual		:= {|| TKVisuaSL1((cAlias)->XX_RECNO,nBrowse,cAlias) }

	Case (nBrowse == 2)
		 cCadastro	:= STR0047 //"Orcamentos X Produtos"
	 	 cAlias		:= GetNextAlias()
		 bVisual		:= {|| TKVisuaSL1((cAlias)->XX_RECNO,nBrowse,cAlias) }
    	 If Empty(cProduto)
    		Help(" ",1,"SEM PRODUT" )
    		Return .F.
         Endif 
EndCase

DbSelectArea("SX3")
DbSetOrder(2)

Do Case
	Case (nBrowse == 1)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Adiciona Campos que serao visualizados do SL1.                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If DbSeek("L1_FILIAL")
			aadd(aStru ,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aadd(aQuery,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		Endif
		
		If DbSeek("L1_CLIENTE")
			aadd(aStru ,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aadd(aQuery,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		Endif
		
		If DbSeek("L1_LOJA")
			aadd(aStru ,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aadd(aQuery,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		Endif
		
		If DbSeek("L1_NUM")
			aadd(aHeader,{ ALLTRIM(X3Titulo()),SX3->X3_CAMPO,	SX3->X3_PICTURE,	SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,	SX3->X3_VALID,	SX3->X3_USADO,		SX3->X3_TIPO,;
							SX3->X3_ARQUIVO,	SX3->X3_CONTEXT } )
			aadd(aStru ,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aadd(aQuery,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		Endif
		
		If DbSeek("L1_EMISSAO")
			aadd(aHeader,{ ALLTRIM(X3Titulo()),SX3->X3_CAMPO,	SX3->X3_PICTURE,	SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,	SX3->X3_VALID,	SX3->X3_USADO,		SX3->X3_TIPO,;
							SX3->X3_ARQUIVO,	SX3->X3_CONTEXT } )
			aadd(aStru ,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aadd(aQuery,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		Endif
		
		If DbSeek("L1_HORA")
			aadd(aHeader,{ ALLTRIM(X3Titulo()),SX3->X3_CAMPO,	SX3->X3_PICTURE,	SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,	SX3->X3_VALID,	SX3->X3_USADO,		SX3->X3_TIPO,;
							SX3->X3_ARQUIVO,	SX3->X3_CONTEXT } )
			aadd(aStru ,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aadd(aQuery,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		Endif
		
		If DbSeek("L1_VEND")
			aadd(aHeader,{ ALLTRIM(X3Titulo()),SX3->X3_CAMPO,	SX3->X3_PICTURE,	SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,	SX3->X3_VALID,	SX3->X3_USADO,	SX3->X3_TIPO,;
							SX3->X3_ARQUIVO,	SX3->X3_CONTEXT } )
			aadd(aStru ,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aadd(aQuery,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		Endif
		
		If DbSeek("L1_VLRTOT")
			aadd(aHeader,{ ALLTRIM(X3Titulo()),SX3->X3_CAMPO,	SX3->X3_PICTURE,	SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,	SX3->X3_VALID,	SX3->X3_USADO,		SX3->X3_TIPO,;
							SX3->X3_ARQUIVO,	SX3->X3_CONTEXT } )
			aadd(aStru ,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aadd(aQuery,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		Endif
		
		If DbSeek("L1_DESCONT")
			aadd(aHeader,{ ALLTRIM(X3Titulo()),SX3->X3_CAMPO,	SX3->X3_PICTURE,	SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,	SX3->X3_VALID,	SX3->X3_USADO,		SX3->X3_TIPO,;
							SX3->X3_ARQUIVO,	SX3->X3_CONTEXT } )
			aadd(aStru ,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aadd(aQuery,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		Endif
		
		If DbSeek("L1_DESCNF")
			aadd(aHeader,{ ALLTRIM(X3Titulo()),SX3->X3_CAMPO,	SX3->X3_PICTURE,	SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,	SX3->X3_VALID,	SX3->X3_USADO,	SX3->X3_TIPO,;
							SX3->X3_ARQUIVO,	SX3->X3_CONTEXT } )
			aadd(aStru ,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aadd(aQuery,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		Endif
		
		If DbSeek("L1_DOC")
			aadd(aHeader,{ ALLTRIM(X3Titulo()),SX3->X3_CAMPO,	SX3->X3_PICTURE,	SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,	SX3->X3_VALID,	SX3->X3_USADO,		SX3->X3_TIPO,;
							SX3->X3_ARQUIVO,	SX3->X3_CONTEXT } )
			aadd(aStru ,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aadd(aQuery,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		Endif
						
		If DbSeek("L1_SERIE")
			aadd(aHeader,{ ALLTRIM(X3Titulo()),SX3->X3_CAMPO,	SX3->X3_PICTURE,	SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,	SX3->X3_VALID,	SX3->X3_USADO,		SX3->X3_TIPO,;
							SX3->X3_ARQUIVO,	SX3->X3_CONTEXT } )
			aadd(aStru ,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aadd(aQuery,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		Endif
		
		If DbSeek("L1_DTLIM")
			aadd(aHeader,{ ALLTRIM(X3Titulo()),SX3->X3_CAMPO,	SX3->X3_PICTURE,	SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,	SX3->X3_VALID,	SX3->X3_USADO,		SX3->X3_TIPO,;
							SX3->X3_ARQUIVO,	SX3->X3_CONTEXT } )
			aadd(aStru ,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aadd(aQuery,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		Endif
		
		If DbSeek("L1_CONDPG")
			aadd(aHeader,{ ALLTRIM(X3Titulo()),SX3->X3_CAMPO,	SX3->X3_PICTURE,	SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,	SX3->X3_VALID,	SX3->X3_USADO,		SX3->X3_TIPO,;
							SX3->X3_ARQUIVO,	SX3->X3_CONTEXT } )
			aadd(aStru ,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aadd(aQuery,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		Endif
		
		If DbSeek("L1_EMISNF")
			aadd(aHeader,{ ALLTRIM(X3Titulo()),SX3->X3_CAMPO,	SX3->X3_PICTURE,	SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,	SX3->X3_VALID,	SX3->X3_USADO,		SX3->X3_TIPO,;
							SX3->X3_ARQUIVO,	SX3->X3_CONTEXT } )
			aadd(aStru ,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aadd(aQuery,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		Endif
		
		aadd(aStru,{"XX_RECNO","N",12,0})
		
		SX3->(DbSetOrder(1))
		
	
		//-------------------------------------------------------------------
		// Instancia tabela temporária.  
		//-------------------------------------------------------------------
		
		oTempTable	:= FWTemporaryTable():New( cAlias)
		
		
		//-------------------------------------------------------------------
		// Atribui o  os índices.  
		//-------------------------------------------------------------------
		oTempTable:SetFields( aStru )

		oTempTable:AddIndex("1",{"L1_FILIAL","L1_CLIENTE","L1_LOJA","L1_EMISSAO"})

		//------------------
		//Criação da tabela
		//------------------
		oTempTable:Create()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Seleciona os campos a serem visualizados posteriormente.                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nCntFor :=1 To Len(aStru)
			If (ALLTRIM(aStru[nCntFor][1])=="L1_FILIAL")  .OR. ;
			   (ALLTRIM(aStru[nCntFor][1])=="L1_CLIENTE") .OR. ;
			   (ALLTRIM(aStru[nCntFor][1])=="L1_LOJA")
				Loop
			Else
				Aadd (aCampos,{aStru[nCntFor][1]})
			Endif
		Next nCntFor
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Executa a pesquisa     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQry := "SL1"
		
	
		cQuery := ""
		aEval(aQuery,{|x| cQuery += ","+ALLTRIM(x[1])})
		cQuery := "SELECT "+SubStr(cQuery,2)
		cQuery +=         ",SL1.R_E_C_N_O_ SL1RECNO "
		cQuery += "FROM "+RetSqlName("SL1")+" SL1 "
		cQuery += "WHERE SL1.L1_FILIAL='"+xFilial("SL1")+"' AND "
		cQuery +=		  "SL1.L1_CLIENTE='"+SA1->A1_COD+"' AND "
		cQuery +=		  "SL1.L1_LOJA='"+SA1->A1_LOJA+"' AND "
		cQuery +=		  "SL1.D_E_L_E_T_<>'*'"
		
		cQuery := ChangeQuery(cQuery)
		cQry   := cArquivo+"A"
		
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cQry,.T.,.T.)
		
		aEval(aQuery,{|x| If(x[2]<>"C",TcSetField(cQry,x[1],x[2],x[3],x[4]),Nil)})
	
		DbSelectArea(cQry)
		
		While (cQry)->( !Eof() )
			
			DbSelectArea(cAlias)
			DbSetOrder(1)
			cChave := (cQry)->(L1_FILIAL)+(cQry)->(L1_NUM)
			If ( !DbSeek(cChave) )
				
				RecLock(cAlias,.T.)
			Else
				RecLock(cAlias,.F.)
			Endif
			
			For nCntFor := 1 To Len(aStru)
				
				Do Case
					Case ( ALLTRIM(aStru[nCntFor][1])=="XX_RECNO" )
					
						(cAlias)->XX_RECNO := (cQry)->SL1RECNO
					
					OtherWise
						(cAlias)->(FieldPut(nCntFor,(cQry)->(FieldGet(FieldPos(aStru[nCntFor][1])))))
				EndCase
			Next nCntFor
			
			
			(cAlias)->(MsUnLock())
		
			(cQry)->(DbSkip())
		End
		
	
		
		(cQry)->(DbCloseArea())
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Totais da Consulta                                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aGet[1] := 0
		aGet[2] := 0
		DbSelectArea(cAlias)
		(cAlias)->(DbSeek(xFilial("SL1")))
		While (cAlias)->(!EOF())
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Vlr. Total. 	    	  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aGet[2] += L1_VLRTOT
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Totais dos Orcamentos  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty(L1_DOC)
				aGet[1] += L1_VLRTOT
			Endif
			 
			DbSkip()
		End                                                      
		aGet[1] := TransForm(aGet[1],Tm(aGet[1],16,2))
		aGet[2] := TransForm(aGet[2],Tm(aGet[2],16,2))
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Exibe os dados Gerados                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( lExibe )  
			DbSelectArea(cAlias)
			If (cAlias)->(DbSeek(xFilial("SL1")))
				
				DEFINE MSDIALOG oDlg FROM	09,0 TO 28,80 TITLE cCadastro OF oMainWnd
			
					@ 001,002 TO 029,267 OF oDlg	PIXEL
		    	
					@ 004,005 SAY STR0007 SIZE 028,07  OF oDlg PIXEL //"CLIENTE"
					@ 012,005 SAY SA1->A1_COD        SIZE 060,09  COLOR CLR_BLUE OF oDlg PIXEL
		
					@ 004,040 SAY STR0008 SIZE 020,07  OF oDlg PIXEL //"Loja"
					@ 012,040 SAY SA1->A1_LOJA       SIZE 021,09  COLOR CLR_BLUE OF oDlg PIXEL
		
					@ 004,080 SAY STR0004 SIZE 025,07  OF oDlg PIXEL //"Nome"
					@ 012,080 SAY  FATPDObfuscate(SA1->A1_NOME,"A1_NOME") SIZE 165,09  COLOR CLR_BLUE OF oDlg PIXEL
			
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Estrutura do arquivo de trabalho³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					//("L1_FILIAL")
					//("L1_CLIENTE")
					//("L1_LOJA")
					//("L1_NUM")
					//("L1_EMISSAO")
					//("L1_HORA")
					//("L1_VEND")
					//("L1_VLRTOT")
					//("L1_DESCONT")		  
					//("L1_DESCNF")		
					//("L1_DOC")
					//("L1_SERIE")
					//("L1_DTLIM")
					//("L1_CONDPG")	
					//("L1_EMISNF")
					//("XX_RECNO")               
					
					@35,02 LISTBOX oLbx VAR nCntList;
						FIELDS ;
							TkStatusSL1(IIF(ALLTRIM(&(cAlias + "->(L1_DOC)")) = "","1","2"))				,;
							&(cAlias + "->(L1_NUM)")            											,;
							DTOC(&(cAlias + "->(L1_EMISSAO)")) 												,;
							&(cAlias + "->(L1_HORA)")   													,;
							Posicione("SA3",1,xFilial("SA3") + &(cAlias + "->(L1_VEND)"),"A3_NOME")			,;
							Transform(&(cAlias + "->(L1_DESCONT)"),Tm(&(cAlias + "->(L1_DESCONT)"),15,2)) 	,;
							&(cAlias + "->(L1_DESCNF)")										            	,;
							Transform(&(cAlias + "->(L1_VLRTOT)"),Tm(&(cAlias + "->(L1_VLRTOT)"),15,2))     ,;
							&(cAlias + "->(L1_DOC)") 											            ,;
							SerieNFID(cAlias, 2, "L1_SERIE")												,;
							DTOC(&(cAlias + "->(L1_DTLIM)"))  												,;
							Posicione("SE4",1,xFilial("SE4") + &(cAlias + "->(L1_CONDPG)"),"E4_DESCRI")		,;
							DTOC(&(cAlias + "->(L1_EMISNF)"))									   			;
						HEADER ;              
					 		""		,;
					 		STR0034 ,; //"N. Orcamento"
						 	STR0035 ,; //"Emissao "
						 	STR0048 ,; //"Hora"
						 	STR0006 ,; //"Vendedor"
					 		STR0049 ,; //"Vlr. Desconto"
					 		STR0050 ,; //"% Desconto"
					 		STR0036 ,; //"Total"
							STR0037 ,; //"N.Fiscal"
							STR0038 ,; //"Serie"
							STR0051 ,; //"Validade Orc."
							STR0052 ,; //"Cond. Pagto."			
							STR0039 ; //"Data de emissao"	
						ALIAS cAlias SIZE 306,90 OF oDlg PIXEL ;
						SELECT  &(cAlias + "->(L1_FILIAL + L1_CLIENTE + L1_LOJA)");                                                         
						FOR 	&(cAlias + "->(L1_FILIAL + L1_CLIENTE + L1_LOJA)");
						TO  	&(cAlias + "->(L1_FILIAL + L1_CLIENTE + L1_LOJA)")

						aPDCols := {"","","","","A3_NOME","","","","","","","",""}

						If FATPDActive() .And. FTPDUse(.T.)
							oLbx:aObfuscatedCols := FATPDColObfuscate(aPDCols)
						EndIf

						oLbx:Refresh()
						
		    
        			@ 126,005 SAY STR0041 SIZE 080,07 OF oDlg PIXEL  //"Totais de orcamentos"
					If cPaisLoc == "BRA"
						@ 126,040 SAY aGet[1] SIZE 060,07 OF oDlg PIXEL
					Else
						@ 126,060 SAY aGet[1] SIZE 060,07 OF oDlg PIXEL
					Endif
		
					@ 126,210 SAY  STR0026 SIZE 025,07 OF oDlg PIXEL //"Vlr. Total"
					@ 126,230 SAY aGet[2] SIZE 060,07 OF oDlg PIXEL

					DEFINE SBUTTON 			FROM 005,280 TYPE 1  ENABLE OF oDlg ACTION ( oDlg:End() )
					
					DEFINE SBUTTON oBtn 	FROM 020,280 TYPE 15 ENABLE OF oDlg
					
					oBtn:lAutDisable := .F.
					If ( bVisual <> Nil )
						oBtn:bAction := bVisual
					Else
						oBtn:SetDisable(.T.)
					Endif

				ACTIVATE MSDIALOG oDlg
		    Else
			   Help(" ",1,"REGNOIS")
			Endif				
	
		Else
			Help(" ",1,"REGNOIS")	
		Endif

	
	Case (nBrowse == 2)
	    
	    If DbSeek("L2_FILIAL")
			aadd(aStru ,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aadd(aQuery,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		Endif
		
		If DbSeek("L2_NUM")
			aadd(aHeader,{ ALLTRIM(X3Titulo()),SX3->X3_CAMPO,	SX3->X3_PICTURE,	SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,	SX3->X3_VALID,	SX3->X3_USADO,		SX3->X3_TIPO,;
							SX3->X3_ARQUIVO,	SX3->X3_CONTEXT } )
			aadd(aStru ,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aadd(aQuery,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		Endif
		
		If DbSeek("L2_PRODUTO")
			aadd(aHeader,{ ALLTRIM(X3Titulo()),SX3->X3_CAMPO,	SX3->X3_PICTURE,	SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,	SX3->X3_VALID,	SX3->X3_USADO,		SX3->X3_TIPO,;
							SX3->X3_ARQUIVO,	SX3->X3_CONTEXT } )
			aadd(aStru ,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aadd(aQuery,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		Endif

		If DbSeek("L2_DESCRI")
			aadd(aHeader,{ ALLTRIM(X3Titulo()),SX3->X3_CAMPO,	SX3->X3_PICTURE,	SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,	SX3->X3_VALID,	SX3->X3_USADO,		SX3->X3_TIPO,;
							SX3->X3_ARQUIVO,	SX3->X3_CONTEXT } )
			aadd(aStru ,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aadd(aQuery,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		Endif
		
		If DbSeek("L2_EMISSAO")
			aadd(aHeader,{ ALLTRIM(X3Titulo()),SX3->X3_CAMPO,	SX3->X3_PICTURE,	SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,	SX3->X3_VALID,	SX3->X3_USADO,		SX3->X3_TIPO,;
							SX3->X3_ARQUIVO,	SX3->X3_CONTEXT } )
			aadd(aStru ,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aadd(aQuery,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		Endif
		
		If DbSeek("L2_VEND")
			aadd(aHeader,{ ALLTRIM(X3Titulo()),SX3->X3_CAMPO,	SX3->X3_PICTURE,	SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,	SX3->X3_VALID,	SX3->X3_USADO,		SX3->X3_TIPO,;
							SX3->X3_ARQUIVO,	SX3->X3_CONTEXT } )
			aadd(aStru ,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aadd(aQuery,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		Endif
		
		If DbSeek("L2_VRUNIT")
			aadd(aHeader,{ ALLTRIM(X3Titulo()),SX3->X3_CAMPO,	SX3->X3_PICTURE,	SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,	SX3->X3_VALID,	SX3->X3_USADO,		SX3->X3_TIPO,;
							SX3->X3_ARQUIVO,	SX3->X3_CONTEXT } )
			aadd(aStru ,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aadd(aQuery,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		Endif

		If DbSeek("L2_QUANT")
			aadd(aHeader,{ ALLTRIM(X3Titulo()),SX3->X3_CAMPO,	SX3->X3_PICTURE,	SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,	SX3->X3_VALID,	SX3->X3_USADO,		SX3->X3_TIPO,;
							SX3->X3_ARQUIVO,	SX3->X3_CONTEXT } )
			aadd(aStru ,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aadd(aQuery,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		Endif

		If DbSeek("L2_VLRITEM")
			aadd(aHeader,{ ALLTRIM(X3Titulo()),SX3->X3_CAMPO,	SX3->X3_PICTURE,	SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,	SX3->X3_VALID,	SX3->X3_USADO,		SX3->X3_TIPO,;
							SX3->X3_ARQUIVO,	SX3->X3_CONTEXT } )
			aadd(aStru ,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aadd(aQuery,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		Endif
		
		If DbSeek("L2_UM")
			aadd(aHeader,{ ALLTRIM(X3Titulo()),SX3->X3_CAMPO,	SX3->X3_PICTURE,	SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,	SX3->X3_VALID,	SX3->X3_USADO,		SX3->X3_TIPO,;
							SX3->X3_ARQUIVO,	SX3->X3_CONTEXT } )
			aadd(aStru ,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aadd(aQuery,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		Endif
				
		If DbSeek("L2_DESC")                                                                      
			aadd(aHeader,{ ALLTRIM(X3Titulo()),SX3->X3_CAMPO,	SX3->X3_PICTURE,	SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,	SX3->X3_VALID,	SX3->X3_USADO,		SX3->X3_TIPO,;
							SX3->X3_ARQUIVO,	SX3->X3_CONTEXT } )
			aadd(aStru ,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aadd(aQuery,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		Endif
		
		If DbSeek("L2_VALDESC")
			aadd(aHeader,{ ALLTRIM(X3Titulo()),SX3->X3_CAMPO,	SX3->X3_PICTURE,	SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,	SX3->X3_VALID,	SX3->X3_USADO,		SX3->X3_TIPO,;
							SX3->X3_ARQUIVO,	SX3->X3_CONTEXT } )
			aadd(aStru ,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aadd(aQuery,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		Endif

		If DbSeek("L2_TES")
			aadd(aHeader,{ ALLTRIM(X3Titulo()),SX3->X3_CAMPO,	SX3->X3_PICTURE,	SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,	SX3->X3_VALID,	SX3->X3_USADO,		SX3->X3_TIPO,;
							SX3->X3_ARQUIVO,	SX3->X3_CONTEXT } )
			aadd(aStru ,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aadd(aQuery,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		Endif
		
		If DbSeek("L2_DOC")
			aadd(aHeader,{ ALLTRIM(X3Titulo()),SX3->X3_CAMPO,	SX3->X3_PICTURE,	SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,	SX3->X3_VALID,	SX3->X3_USADO,		SX3->X3_TIPO,;
							SX3->X3_ARQUIVO,	SX3->X3_CONTEXT } )
			aadd(aStru ,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aadd(aQuery,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		Endif

		If DbSeek("L2_SERIE")
			aadd(aHeader,{ ALLTRIM(X3Titulo()),SX3->X3_CAMPO,	SX3->X3_PICTURE,	SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,	SX3->X3_VALID,	SX3->X3_USADO,		SX3->X3_TIPO,;
							SX3->X3_ARQUIVO,	SX3->X3_CONTEXT } )
			aadd(aStru ,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aadd(aQuery,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		Endif

		If DbSeek("L2_TABELA")
			aadd(aHeader,{ ALLTRIM(X3Titulo()),SX3->X3_CAMPO,	SX3->X3_PICTURE,	SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,	SX3->X3_VALID,	SX3->X3_USADO,		SX3->X3_TIPO,;
							SX3->X3_ARQUIVO,	SX3->X3_CONTEXT } )
			aadd(aStru ,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aadd(aQuery,{ALLTRIM(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		Endif

		aadd(aStru,{"XX_CLIENTE","C",6,0})
		aadd(aStru,{"XX_LOJA","C",2,0})
		aadd(aStru,{"XX_NOME","C",40,0})
		aadd(aStru,{"XX_RECNO","N",12,0})
		
		SX3->(DbSetOrder(1))
		
	
		//-------------------------------------------------------------------
		// Instancia tabela temporária.  
		//-------------------------------------------------------------------
		
		oTempTable	:= FWTemporaryTable():New( cAlias)
		
		
		//-------------------------------------------------------------------
		// Atribui o  os índices.  
		//-------------------------------------------------------------------
		oTempTable:SetFields( aStru )

		oTempTable:AddIndex("1",{"L2_FILIAL","L2_PRODUTO","L2_EMISSAO"})

		//------------------
		//Criação da tabela
		//------------------
		oTempTable:Create()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Seleciona os campos a serem visualizados posteriormente.                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nCntFor :=1 To Len(aStru)
			If (ALLTRIM(aStru[nCntFor][1])=="L2_FILIAL")  
			  	Loop
			Else
				Aadd (aCampos,{aStru[nCntFor][1]})
			Endif
		Next nCntFor
	    
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Executa a pesquisa     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQry := "SL2"
			


		cQuery := ""
		aEval(aQuery,{|x| cQuery +=","+ALLTRIM(x[1])})
		cQuery := "SELECT "+SubStr(cQuery,2)
		cQuery +=         ",SL2.R_E_C_N_O_ SL2RECNO "
		cQuery += "FROM "+RetSqlName("SL2")+" SL2 "
		cQuery += "WHERE SL2.L2_FILIAL='"+xFilial("SL2")+"' AND "
		cQuery +=        "SL2.L2_PRODUTO='"+cProduto+"' AND "
		cQuery +=        "SL2.D_E_L_E_T_<>'*'"
		cQuery := ChangeQuery(cQuery)
		cQry   := cArquivo+"A"
			
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cQry,.T.,.T.)
			
		aEval(aQuery,{|x| If(x[2]<>"C",TcSetField(cQry,x[1],x[2],x[3],x[4]),Nil)})

		
		DbSelectArea(cQry)
		
		While (cQry)->( !Eof() )
				
		    RecLock(cAlias,.T.)
				
			For nCntFor := 1 To Len(aStru)
				
				Do Case
					Case ( ALLTRIM(aStru[nCntFor][1])=="XX_RECNO" )
				
						(cAlias)->XX_RECNO := (cQry)->SL2RECNO
					
					
					Case ( ALLTRIM(aStru[nCntFor][1])=="XX_CLIENTE")
						 (cAlias)->XX_CLIENTE := Posicione("SL1",1,xFilial("SL1")+(cAlias)->L2_NUM,"L1_CLIENTE")

					Case ( ALLTRIM(aStru[nCntFor][1])=="XX_LOJA")
						 (cAlias)->XX_LOJA	  := Posicione("SL1",1,xFilial("SL1")+(cAlias)->L2_NUM,"L1_LOJA")

					Case ( ALLTRIM(aStru[nCntFor][1])=="XX_NOME")
						 (cAlias)->XX_NOME 	  := Posicione("SA1",1,xFilial("SA1")+(cAlias)->XX_CLIENTE+(cAlias)->XX_LOJA,"A1_NOME")
					
					Otherwise	
                         
	 					(cAlias)->(FieldPut(nCntFor,(cQry)->(FieldGet(FieldPos(aStru[nCntFor][1])))))

				EndCase


			Next nCntFor
				
			DbSelectArea(cAlias)
			MsUnLock()  
			
			DbSelectArea(cQry)
			DbSkip()
		End
			
		
		DbSelectArea(cQry)
		DbCloseArea()
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Totais da Consulta                                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aGet[1] := 0
		aGet[2] := 0

		DbSelectArea(cAlias)
		DbSeek(xFilial("SL1"))
		While !EOF()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Vlr. Total. 	    	  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aGet[2] += L2_VLRITEM
				
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Totais dos Orcamentos  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty(L2_DOC)
				aGet[1] += L2_VLRITEM
			Endif
				 
			DbSkip()
		End                                                      
		aGet[1] := TransForm(aGet[1],Tm(aGet[1],16,2))
		aGet[2] := TransForm(aGet[2],Tm(aGet[2],16,2))
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Exibe os dados Gerados                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( lExibe )  
			DbSelectArea(cAlias)
			If DbSeek(xFilial("SL2"))
				
				DEFINE MSDIALOG oDlg FROM	09,0 TO 28,80 TITLE cCadastro OF oMainWnd
			        
					@ 001,002 TO 029,267 OF oDlg	PIXEL
			    	
					@ 004,005 SAY STR0002 SIZE 028,07  OF oDlg PIXEL //"Codigo"
					@ 012,005 SAY SB1->B1_COD        SIZE 060,09  COLOR CLR_BLUE OF oDlg PIXEL
			
					@ 004,070 SAY STR0045 SIZE 020,07  OF oDlg PIXEL //"Produto"
					@ 012,070 SAY SB1->B1_DESC       SIZE 150,09  COLOR CLR_BLUE OF oDlg PIXEL
							  
					@35,02 LISTBOX oLbx VAR nCntList ; 
												FIELDS ;
							TkStatusSL1(IIF(ALLTRIM(&(cAlias + "->(L2_DOC)")) = "","1","2"))				,;
							&(cAlias + "->(L2_NUM)")         												,;
							&(cAlias + "->(XX_CLIENTE)")      												,;
							&(cAlias + "->(XX_LOJA)")         												,;
							&(cAlias + "->(XX_NOME)")         												,;
							Posicione("SA3",1,xFilial("SA3")+&(cAlias + "->(L2_VEND)"),"A3_NOME")			,;
							DTOC(&(cAlias + "->(L2_EMISSAO)")) 												,;
						    Transform(&(cAlias + "->(L2_VRUNIT)") ,Tm(&(cAlias + "->(L2_VRUNIT)") ,15,2)) 	,; 
						    &(cAlias + "->(L2_QUANT)")         												,;
						    Transform(&(cAlias + "->(L2_VLRITEM)"),Tm(&(cAlias + "->(L2_VLRITEM)"),15,2)) 	,; 
							&(cAlias + "->(L2_UM)")            												,;
							&(cAlias + "->(L2_DESC)")          												,;
							Transform(&(cAlias + "->(L2_VALDESC)"),Tm(&(cAlias + "->(L2_VALDESC)"),15,2)) 	,; 
							&(cAlias + "->(L2_TES)")           												,;
							&(cAlias + "->(L2_DOC)")          												,;
							SerieNFID(cAlias, 2, "L2_SERIE")												,;
							&(cAlias + "->(L2_TABELA)")        												 ;
						HEADER ;              
					 		""		,;
					 		STR0034 ,; //"N. Orcamento"	 
					 		STR0007 ,; // "Cliente "
					 		STR0003 ,; //"Loja"
					 		STR0004 ,; //"Nome"
					 		STR0006 ,; //"Vendedor"
					 		STR0039 ,; //"Data de emissao"       
					 		STR0042 ,; //"Vlr. Unit." 
					 		STR0021 ,; //"Quantidade"
					 		STR0043 ,; //"Vlr. item"
					 		STR0044 ,; //"Un. de Medida"
					 		STR0050 ,; //% desconto
					 		STR0049 ,; //"Vlr. Desconto"		
					 		STR0053 ,; //"TES"
					 		STR0037 ,; //"N. Fiscal"
					 		STR0038 ,; //"Serie"
					 		STR0054 ;  //"Tabela"
						SIZE 306,90 OF oDlg PIXEL ;
						ALIAS cAlias; 
				 		SELECT	&(cAlias + "->(L2_FILIAL + L2_PRODUTO )"); 
						FOR 	&(cAlias + "->(L2_FILIAL + L2_PRODUTO )");
						TO 		&(cAlias + "->(L2_FILIAL + L2_PRODUTO )") 
						aPDCols := {"","","","","A1_NOME","A3_NOME","","","","","","","","","","",""}

						If FATPDActive() .And. FTPDUse(.T.)
							oLbx:aObfuscatedCols := FATPDColObfuscate(aPDCols)
						EndIf
						
						oLbx:Refresh()
			    
	        		@ 126,005 SAY STR0041 SIZE 080,07 OF oDlg PIXEL  //"Totais de orcamentos"
	        		If cPaisLoc == "BRA"
						@ 126,040 SAY aGet[1] SIZE 060,07 OF oDlg PIXEL
					Else 
						@ 126,060 SAY aGet[1] SIZE 060,07 OF oDlg PIXEL
					Endif
					@ 126,210 SAY STR0026 SIZE 025,07 OF oDlg PIXEL //"Vlr. Total"
					@ 126,230 SAY aGet[2] SIZE 060,07 OF oDlg PIXEL
	
					DEFINE SBUTTON 			FROM 005,280 TYPE 1  ENABLE OF oDlg ACTION ( oDlg:End() )
					
					DEFINE SBUTTON oBtn 	FROM 020,280 TYPE 15 ENABLE OF oDlg
					oBtn:lAutDisable := .F.
					If ( bVisual <> Nil )
						oBtn:bAction := bVisual
					Else
						oBtn:SetDisable(.T.)
					Endif

				ACTIVATE MSDIALOG oDlg
				
			Else
				Help(" ",1,"REGNOIS")	
			Endif	
		Else
			Help(" ",1,"REGNOIS")	
		Endif
			
EndCase

If( valtype(oTempTable) == "O")
	oTempTable:Delete()
	freeObj(oTempTable)
	oTempTable := nil
EndIf

///aEval(aAlias,{|x| (x[1])->(DbCloseArea()),Ferase(x[2]+GetDbExtension()),Ferase(x[2]+OrDbagExt())})
RestArea(aAreaSA1)
RestArea(aAreaSL1)
RestArea(aAreaSL2)
RestArea(aArea)

Return(aHeader)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TKVisuaSL1ºAutor  ³Rafael M Quadrotti  º Data ³  05/25/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Visualiza o item selecionado. (SL1/SL2)                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºMauro Sano³04/10/07³Criada flag para verificar se o orcamento foi      º±±
±±º          ³        ³visualizado.                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TKVisuaSL1(nRecno,nBrowse,cAlias)

Local aArea 		:= GetArea()				
Local aAreaSL1 		:= SL1->(GetArea())
Local aAreaSL2 		:= SL2->(GetArea())
Local aSavAhead		:= aHeader
Local aSavAcol 		:= aCols
Local nSavN    		:= n
Local aPos      	:= {14,01,114,315}
Local aAC       	:= {STR0007,STR0008 } 						//"Abandona","Confirma"
Local oEnchoice		:= Nil
Local oDlg			:= Nil
Local oGet			:= Nil
Local aCampos   	:= {}
Local aPosicoes 	:= {}
Local nCont			:= 0 
Local lVenAssist	:= If(IsInCallStack("LOJA701"),.T.,.F.)		//Se eh Venda Assistida 
Local lVenDireta	:= If(IsInCallStack("FATA701"),.T.,.F.)		//Se for Venda Direta
  

Private aHeader	:= {}
Private aCols	:= {}
Private nUsado	:= 0

n:= 1
bCampo := {|nCPO| Field(nCPO) }

DbSelectarea("SL1")

If (nBrowse == 1 )
	SL1->(MsGoto(nRecno))
ElseIf(nBrowse == 2 )
   DbSelectarea("SL1")
   DbSetorder(1)
   If DbSeek(xFilial("SL1")+(cAlias)->L2_NUM)
	   nRecno := SL1->(Recno())
   Endif		   
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se a funcao original for a venda assistida chama a funcao de visuali-³
//³ zacao da LOJA701 e nao precisa forcar a montagem da tela (como na    ³
//³ Venda Balcao)                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lVenAssist .or. lVenDireta
	Lj7Venda("SL1", nRecno, 2)  
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Visualizou o orcamento. Seta a Static como .T.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lVisuOrc := .T.    
	
Else
	For nCont := 1 TO FCount()
		M->&(EVAL(bCampo,nCont)) := FieldGet(nCont)
	Next nCont

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega o array aPosicoes para que n„o	  ³
	//³ haja conflito na ordem dos campos no SX3  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TkLojPos(aCampos,@aPosicoes)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega Acols para inclusao   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TkLojaCols()
	
	DbSelectarea("SL1")
	
	DEFINE MSDIALOG oDlg TITLE STR0024 FROM  15,1 TO 400,630 PIXEL OF oMainWnd //"Orcamentos"
	
		Zero()
		
		oEnchoice:= MsMGet():New("SL1", nRecno, 2, aAC,"AC","",,aPos,,,,,,,,,.T.)
		
		oGet:= MSGetDados():New(119,1,185,315,2,,"AlwaysTrue","",.T.)
		oGet:oBrowse:bDelete:={ || aCols[n,Len(Acols[n])]:=!aCols[n,Len(Acols[n])],AlwaysTrue(),oGet:oBrowse:Refresh(.F.)}
		
	ACTIVATE MSDIALOG oDlg ON INIT (LChoiceBar(oDlg)) CENTER;
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Restaura a Integridade dos Dados                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHeader := aSavAHead
	aCols   := aSavACol
	N       := nSavN

Endif
	
RestArea(aAreaSL1)
RestArea(aAreaSL2)
RestArea(aArea)
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³TkLojPos	³ Autor ³ Rafael M.Quadrotti    ³ Data ³16/04/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica posicao das colunas.  				              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso 	 ³TkHistLoj    				 								  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function TkLojPos(aCampos,aPosicoes)


AADD(aPosicoes,{"L2_PRODUTO" ,Ascan(aCampos,"L2_PRODUTO" )})	 	//1  CODIGO DO PRODUTO
AADD(aPosicoes,{"L2_ITEM"    ,Ascan(aCampos,"L2_ITEM"    )})	 	//2  ITEM
AADD(aPosicoes,{"L2_DESCRI"  ,Ascan(aCampos,"L2_DESCRI"  )})	 	//3  DESCRICAO
AADD(aPosicoes,{"L2_QUANT"   ,Ascan(aCampos,"L2_QUANT"   )})	 	//4	 QUANTIDADE
AADD(aPosicoes,{"L2_VRUNIT"  ,Ascan(aCampos,"L2_VRUNIT"  )})	    //5  VALOR UNITARIO
AADD(aPosicoes,{"L2_VLRITEM" ,Ascan(aCampos,"L2_VLRITEM" )}) 	    //6  VLR .ITEM
AADD(aPosicoes,{"L2_DOC"     ,Ascan(aCampos,"L2_DOC"     )})	  	//7  NOTA
AADD(aPosicoes,{"L2_SERIE"   ,Ascan(aCampos,"L2_SERIE"   )})	  	//8  SERIE
AADD(aPosicoes,{"L2_VEND"    ,Ascan(aCampos,"L2_VEND"    )})	  	//9 VENDEDOR

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³TkLojaCols³ Autor ³ Rafael M.Quadrotti    ³ Data ³16/04/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Monta aCols                   				              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso 	 ³TkHistLoj    				 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³31/01/2007³ Conrado Q.    ³Bops 115810: Montagem do aCols e aHeader    ³±±
±±³          ³               ³através da rotina FillGetDados.             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TkLojaCols()
	Local cSeek		:= ""			// Seek para montagem do aCols
	Local cWhile	:= ""			// While para montagem do aCols
	Local aYesFields:= {}			// Campos que irão entrar na seleção

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Montagem aHeader, aCols³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	cSeek := xFilial("SL2")+SL1->L1_NUM
	cWhile:= "SL2->L2_FILIAL+SL2->L2_NUM"
	
	aYesFields	:= {	"L2_PRODUTO", "L2_ITEM"		, "L2_DESCRI"	, "L2_QUANT"	,;
						"L2_VRUNIT"	, "L2_VLRITEM"	, "L2_DOC"		, "L2_SERIE"	,;
						"L2_VEN"	}

	If Len(aHeader) == 0 .AND. Len(aCols) == 0
		FillGetDados(	2				,"SL2"			,1				,cSeek				,;
		   				{|| &cWhile }	,{|| .T. }		,/*aNoFields*/	,aYesFields			,; 
		   				/*lOnlyYes*/	,/*cQuery*/		,/*bMontCols*/	,/*lEmpty*/			,;
		   				/*aHeaderAux*/	,/*aColsAux*/	,/*bAfterCols*/	,/*bBeforeCols*/	)

	Endif

Return .T.
/*/                            
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³LchoiceBar³ Autor ³Rafael M Quadrotti     ³ Data ³25/05/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Mostra a EnchoiceBar na tela 							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso 	 ³ Ap6   					 						     	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function LChoiceBar(oDlg)
Local oBar
Local aBtn := Array(8)

DEFINE BUTTONBAR oBar 3D TOP OF oDlg

DEFINE BUTTON aBtn[1]  RESOURCE "S4WB005N" OF oBar TOOLTIP STR0027 	ACTION aBtn[1]:cDefaultAct := "COPY" 	//"Copiar"
DEFINE BUTTON aBtn[2]  RESOURCE "S4WB006N" OF oBar TOOLTIP STR0028	ACTION aBtn[2]:cDefaultAct := "CUT" 	//"Recortar"
DEFINE BUTTON aBtn[3]  RESOURCE "S4WB007N" OF oBar TOOLTIP STR0029	ACTION aBtn[3]:cDefaultAct := "PASTE" 	//"Colar"
DEFINE BUTTON aBtn[4]  RESOURCE "S4WB008N" OF oBar TOOLTIP STR0030  GROUP ACTION Calculadora() 				//"Calculadora..."
DEFINE BUTTON aBtn[5]  RESOURCE "S4WB009N" OF oBar TOOLTIP STR0031	ACTION Agenda()					      	//"Agenda..."
DEFINE BUTTON aBtn[6]  RESOURCE "S4WB010N" OF oBar TOOLTIP STR0032  ACTION OurSpool()   					//"Gerenciador de Impressao..."
DEFINE BUTTON aBtn[7]  RESOURCE "S4WB016N" OF oBar TOOLTIP STR0033  GROUP ACTION HelProg(.t.) 				//"Help de Programa..."
DEFINE BUTTON aBtn[8]  RESOURCE "OK"       OF oBar TOOLTIP STR0025  ACTION oDlg:End()                     	//"Sair"

Return(.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡„o    ³TkStatusSL1³ Autor ³Luis Marcelo Kotaki	 ³ Data ³18/07/00  ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡„o ³Devolve se o orcamento foi faturado ou nao (pago)            ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Uso	     ³SIGATMK                                     	 	      	   ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TkStatusSL1(cStatus)

Local oOk:= LoaDbitmap( GetResources(), "br_verde" )
Local oNo:= LoaDbitmap( GetResources(), "br_vermelho" )
Local oRet
Local cAliasOld := Alias()

If cStatus == "1"
   oRet := oOk
Else
   oRet := oNo
Endif	

DbSelectarea(cAliasOld)
Return(oRet)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TkVldContatoºAutor³Armando M. Tessaroliº Data ³  10/11/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida se o contato esta devidamente amarrado com a entidadeº±±
±±º          ³informada no atendimento.                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³03/09/2012³ Paulo F.      ³Efetuado validação para não deixar utilizar ³±±
±±³          ³               ³um contato que estaje bloqueado ou inativo  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß  
*/
Function TkVldContato(cAlias, cCodEnt)

Local lRet		:= .T.
Local cChave	:= &(ReadVar())
Local aArea		:= GetArea()

Default cAlias	:= ""
Default cCodEnt	:= ""

If Type("nFolder") <> "U" .And. nFolder == 2 .And. Type("M->UA_CODCONT") <> "U"
   cChave	:= M->UA_CODCONT
Endif	

If !Empty(cChave)
	DbSelectarea("AC8")
	DbSetOrder(1)		// AC8_FILIAL+AC8_CODCON+AC8_ENTIDA+AC8_FILENT+AC8_CODENT
	If !DbSeek(xFilial("AC8") + cChave + cAlias + xFilial(cAlias) + cCodEnt)
		lRet := .F.
		Help(" ",1,"NCONTATO")
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o contato não esta bloqueado.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectarea("SU5")
		DbSetOrder(1)	// U5_FILIAL+U5_CODCONT  
		If DbSeek(xFilial("SU5") + cChave) 
			lRet := RegistroOk("SU5") 
			If lRet .And. U5_ATIVO == "2"
				Help(" ",1,"REGBLOQ")
				lRet:= .F.			
			EndIf	
		EndIf
	Endif		
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza o nome do contato no rodape da tela de atendimento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	cContHist:= TkDadosContato(SU5->U5_CODCONT,0)
	If Type("lTk271Auto") != "U" .And. !lTk271Auto
		oContHist:Refresh()
	Endif	
Endif

RestArea(aArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TmkRecorr ºAutor  ³Vendas CRM          º Data ³  26/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Tela para definicao da recorrencia de chamados do service   º±±
±±º          ³desk                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpD1 - Data atual                                          º±±
±±º          ³ExpC2 - String de configuracao da recorrencia               º±±
±±º          ³ExpN3 - Modo de edicao das configuracoes                    º±±
±±º          ³ExpL4 - (Referencia) Indica se a config. deve ser excluida  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGATMK                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TmkRecorr( dDate, cPeriod, nOpc, lExclude  )

Local aPanels	:= {}
Local aWeek		:= { .F., .F., .F., .F., .F., .F., .F. }
Local aMonths	:= {}

Local cDay		:= ""
Local cRet		:= ""
Local cYMonth	:= ""

Local lSubmit	:= .F.

Local nDDay		:= 1
Local nMDay		:= 1
Local nPeriod	:= 1
Local nYDay		:= 1
Local nX		:= 0 
Local nAntec	:= 0

Local oDDay		:= Nil
Local oDEvery	:= Nil
Local oDEach	:= Nil
Local oDlg		:= Nil
Local oFWLayer	:= Nil
Local oMDay		:= Nil
Local oPFreq	:= Nil
Local oPAntec	:= Nil
Local oPeriod	:= Nil
Local oYDay		:= Nil
Local oYMonth 	:= Nil
Local oExclude	:= Nil      
Local oSubmit	:= Nil
Local oCancel	:= Nil

PARAMTYPE 00 VAR dDate		AS DATE
PARAMTYPE 01 VAR cPeriod	AS CHARACTER
PARAMTYPE 02 VAR nOpc		AS NUMERIC   

aMonths := {"1="+STR0056, "2="+STR0057,"3="+STR0058, ; //"Janeiro"###"Fevereiro"###"Março"
			"4="+STR0059, "5="+STR0060,"6="+STR0061, ; //"Abril"###"Maio"###"Junho"
			"7="+STR0062, "8="+STR0063,"9="+STR0064,; //"Julho"###"Agosto"###"Setembro"
			"10="+STR0065,"11="+STR0066, "12="+STR0067 }//"Outubro"###"Novembro"###"Dezembro"

If ( Empty( cPeriod ) .AND. nOpc == VIEW )
	MsgAlert( STR0068, STR0069 )   //"Não existe recorrência cadastrada para esse agendamento."###"Atenção"
	Return cPeriod
EndIf

If !Empty(cPeriod)
	Do Case
		Case Subs( cPeriod, 1, 1 ) == DIARY
			If ( nAt := At( "Day", cPeriod ) + 4)  > 0
				// Busca a cada quantos dias
				If Len(Subs( cPeriod, nAt, 3 )) <> 0
					nDDay := Val(Subs( cPeriod, nAt, 3 ))
				EndIf
			EndIf
			nPeriod := 1
		Case Subs( cPeriod, 1, 1 ) == WEEKLY
			aWeek := {}
			For nX := 1 To 7
				If Subs( cPeriod, nX, 1 ) != ")"
					aAdd( aWeek, &( Subs( cPeriod, 3+(nX-1)*3, 3 ) ) )
				Else
					Exit
				EndIf
			Next nX
			nPeriod := 2
		Case Subs( cPeriod, 1, 1 ) == MONTHLY
			// Busca a cada quantos dias
			cDay := ""
			nAt := At( "Day", cPeriod ) + 4
			For nX := nAt To Len(cPeriod)
				If Subs( cPeriod, nX, 1 ) != ")"
					cDay += Subs( cPeriod, nX, 1 )
				Else
					Exit
				EndIf
			Next
			nMDay := Val( cDay )
			nPeriod := 3
		Case Subs( cPeriod, 1, 1 ) == YEARLY
			// Busca a cada quantos dias
			cDay := ""
			nAt := At( "Day", cPeriod ) + 4
			For nX := nAt To Len(cPeriod)
				If Subs( cPeriod, nX, 1 ) != ")"
					cDay += Subs( cPeriod, nX, 1 )
				Else
					Exit
				EndIf
			Next
			nYDay := Val( cDay )
			cYMonth := ""
			nAt := At( "Month", cPeriod ) + 6
			For nX := nAt To Len(cPeriod)
				If Subs( cPeriod, nX, 1 ) != ")"
					cYMonth += Subs( cPeriod, nX, 1 )
				Else
					Exit
				EndIf
			Next
			nPeriod := 4

	EndCase

	nAt := At( "Advance", cPeriod ) + 8
	If Len(Subs( cPeriod, nAt, 3 )) <> 0
		nAntec := Val(Subs( cPeriod, nAt, 3 ))
	EndIf

EndIf

DEFINE MSDIALOG oDlg TITLE STR0070 FROM 000,000 TO 270,550 PIXEL  //"Recorrência do chamado"

	oFWLayer := FWLayer():new()
	oFWLayer:init( oDlg,, FlatMode() )

	oFWLayer:addLine("LINHA1", 85, .F.) 
	oFWLayer:addCollumn( "Sched", 100, .F., "LINHA1" )
	oFWLayer:addWindow( "Sched", "Freq", STR0071, 60, .F., .T., {||}, "LINHA1" ) //"Frequência"
	oFWLayer:addWindow( "Sched", "Antec", STR0072, 40, .F., .T., {||}, "LINHA1" ) //"Antecedência"
	
	oPFreq  := oFWLayer:getWinPanel( "Sched", "Freq","LINHA1" )
	oPFreq:readClientCoors()  
	
	oPAntec := oFWLayer:getWinPanel( "Sched", "Antec","LINHA1" )
	oPAntec:readClientCoors()

	@ 005,010 RADIO oPeriod VAR nPeriod ITEMS STR0073,STR0074,STR0075,STR0076 SIZE 045,000 OF oPFreq PIXEL //"Diário"###"Semanal"###"Mensal"###"Anual"
	oPeriod:bChange := {|| updatePanels( nPeriod, aPanels  ) }
	oPeriod:bWhen := {|| nOpc == INSERT .OR. nOpc == UPDATE }

	// Diario
	aAdd( aPanels, TBitmap():New( 002, 055, 210, 042, "x.png",,, oPFreq,,,, .T.,,,,, .T.,, ) )
	
	@ 006,005 SAY STR0077 SIZE 029,010 OF aPanels[1] PIXEL //"A cada"      

	@ 004,030 GET oDDay VAR nDDay PICTURE "@E 999" OF aPanels[1] SIZE 020,009 PIXEL
	oDDay:bWhen := {|| nOpc == INSERT .OR. nOpc == UPDATE }

	@ 006,050 SAY STR0078 SIZE 020,010 OF aPanels[1] PIXEL //" dia(s)"

	// Semanal
	aAdd( aPanels, TBitmap():New( 002, 055, 210, 042, "x.png",,, oPFreq,,,, .T.,,,,, .T.,, ) )
	@ 005,005 SAY STR0079 SIZE 050,010 OF aPanels[2] PIXEL //"Todo(a)"
	
	@ 015,007 CHECKBOX aWeek[1] PROMPT STR0080 SIZE 050,010 OF aPanels[2] WHEN {|| nOpc == INSERT .OR. nOpc == UPDATE } PIXEL //"domingo"
	@ 015,060 CHECKBOX aWeek[2] PROMPT STR0081 SIZE 050,010 OF aPanels[2] WHEN {|| nOpc == INSERT .OR. nOpc == UPDATE } PIXEL //"segunda-feira"
	@ 015,113 CHECKBOX aWeek[3] PROMPT STR0082 SIZE 050,010 OF aPanels[2] WHEN {|| nOpc == INSERT .OR. nOpc == UPDATE } PIXEL //"terça-feira"
	@ 015,160 CHECKBOX aWeek[4] PROMPT STR0083 SIZE 050,010 OF aPanels[2] WHEN {|| nOpc == INSERT .OR. nOpc == UPDATE } PIXEL //"quarta-feira"
	@ 030,007 CHECKBOX aWeek[5] PROMPT STR0084 SIZE 050,010 OF aPanels[2] WHEN {|| nOpc == INSERT .OR. nOpc == UPDATE } PIXEL //"quinta-feira"
	@ 030,060 CHECKBOX aWeek[6] PROMPT STR0085 SIZE 050,010 OF aPanels[2] WHEN {|| nOpc == INSERT .OR. nOpc == UPDATE } PIXEL //"sexta-feira"
	@ 030,113 CHECKBOX aWeek[7] PROMPT STR0086 SIZE 050,010 OF aPanels[2] WHEN {|| nOpc == INSERT .OR. nOpc == UPDATE } PIXEL //"sábado"

	// Mensal
	aAdd( aPanels, TBitmap():New( 002, 055, 210, 042, "x.png",,, oPFreq,,,, .T.,,,,, .T.,, ) )
	@ 006,005 SAY STR0087 SIZE 025,010 OF aPanels[3] PIXEL //"Dia"

	@ 004,020 GET oMDay VAR nMDay PICTURE "@E 99" SIZE 020,009 OF aPanels[3] PIXEL VALID (nMDay <= 31)
	oMDay:bWhen := {|| nOpc == INSERT .OR. nOpc == UPDATE }

	@ 006,042 SAY STR0088 SIZE 050,010 OF aPanels[3] PIXEL //"de cada mês"

	// Anual
	aAdd( aPanels, TBitmap():New( 002, 055, 210, 042, "x.png",,, oPFreq,,,, .T.,,,,, .T.,, ) )
	@ 006,005 SAY STR0089 SIZE 030,010 OF aPanels[4] PIXEL //"A cada dia"

	@ 004,033 GET oYDay VAR nYDay PICTURE "@E 99" SIZE 020,009 OF aPanels[4] PIXEL VALID VldDate(dDate,nYDay,cYMonth)
	oYDay:bWhen := {|| nOpc == INSERT .OR. nOpc == UPDATE }

	@ 006,055 SAY STR0090 SIZE 010,010 OF aPanels[4] PIXEL //"de"
	
	@ 004,065 COMBOBOX oYMonth VAR cYMonth ITEMS aMonths SIZE 050,012 OF aPanels[4] PIXEL VALID VldDate(dDate,nYDay,cYMonth)
	oYMonth:bWhen := {|| nOpc == INSERT .OR. nOpc == UPDATE }
	
	// Atualiza todos os paineis		
	updatePanels( nPeriod, aPanels )

	// Antecedencia
	@ 005,010 SAY STR0091 SIZE 070,010 OF oPAntec PIXEL //"Gerar este chamado com"
	@ 003,076 GET nAntec SIZE 010,009 PICTURE "999" OF oPAntec PIXEL VALID (nAntec >= 0 .AND. nAntec <= 365) WHEN (nOpc == INSERT .OR. nOpc == UPDATE )
	@ 005,100 SAY STR0092 SIZE 070,010 OF oPAntec PIXEL		 //"dia(s) de atecedência" 
	
	@ 119,110 BUTTON oExclude PROMPT STR0093 OF oDlg SIZE 050,012 ACTION( lExclude := MsgYesNo(STR0094), oDlg:End() ) PIXEL MESSAGE STR0095 //"Excluir Rec."###"Confirma o cancelamento da recorrência deste chamado?"###"Cancela a recorrência deste chamado"
	
	@ 119,165 BUTTON oSubmit PROMPT STR0096 OF oDlg SIZE 050,012 ACTION( lSubmit := .T., oDlg:End() ) PIXEL //"Confirmar"
	oSubmit:bWhen := {|| nOpc == INSERT .OR. nOpc == UPDATE }

	If GetVersao(.F.) == "11"
		oSubmit:SetCSS( FWGetCSS( CSS_BUTTON_FOCAL ) )
	EndIf

	@ 119,220 BUTTON oCancel PROMPT STR0097 OF oDlg SIZE 050,012 ACTION( lSubmit := .F., oDlg:End() ) PIXEL //"Cancelar"

ACTIVATE DIALOG oDlg CENTERED

If lSubmit

	Do Case
		Case nPeriod == 1		// Diario
			cRet := DIARY+"("
				cRet += "Day(" + StrZero(nDDay,3) + ");"
		Case nPeriod == 2		// Semanal
			cRet := WEEKLY+"("
				For nX := 1 To Len(aWeek)
					cRet += If( aWeek[nX], ".T.", ".F." )
				Next nX
		Case nPeriod == 3		// Mensal
			cRet := MONTHLY+"("
				cRet += "Day(" + AllTrim(Str(nMDay)) + ");"
		Case nPeriod == 4		// Anual
			cRet := YEARLY+"("
				cRet += "Day(" + AllTrim(Str(nYDay)) + ");"
				cRet += "Month(" + cYMonth + ");"
	EndCase

	cRet += ");"
	
	// Antecedência
	cRet += "Advance(" + StrZero(nAntec,3) + ");"

Else
	cRet := cPeriod
EndIf

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³updatePanelsºAutor  ³Vendas CRM        º Data ³  26/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza os paineis da tela com base no tipo de recorrencia º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpN1 - Numero do painel selecionado                        º±±
±±º          ³ExpA2 - Array de objetos de painel                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMXFUND                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function updatePanels( nPeriod, aPanels )

Local nX := 0

For nX := 1 To Len(aPanels)
	If nX == nPeriod
		aPanels[nX]:show()
	Else
		aPanels[nX]:hide()
	EndIf
Next nX

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VldDate   ºAutor  ³Vendas CRM          º Data ³  26/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida se a data informada trata-se de uma data real        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpD1 - Data de referencia para o ano                       º±±
±±º          ³ExpN2 - Dia a ser validado                                  º±±
±±º          ³ExpC3 - Mes a ser validado                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKXFUND                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldDate(dDate,nYDay,cYMonth)
Local cDate	:= cValToChar(nYDay)+"/"+cYMonth+"/"+cValToChar(Year(dDate))
Return !Empty(CtoD(cDate))  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TkRecorrenºAutor  ³Vendas CRM          º Data ³  26/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³JOB para geracao de chamados recorrentes                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpA1 - Array com codigo da empresa e filial para execucao  º±±
±±º          ³ExpC2 - Codigo de um unico chamado para processamento       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGATMK                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Main Function TkRecorren(aEmpFil,cSingleCall)

Local cStrRec	:= ""
Local cDay		:= "" 
Local cFil		:= "" 
Local cYMonth	:= ""
Local cFilterADE:= ""

Local nDDay		:= 0 
Local nMDay		:= 0
Local nX		:= 0  
Local nPeriod	:= 0  
Local nYDay		:= 0 
Local nAt		:= 0 
Local nAntec	:= 0
Local nDifData	:= 0  
Local nInterval	:= 0
Local nYMonth	:= 0

Local aWeek		:= {}
Local aDatas	:= {}
Local aArea		:= {}
Local aAreaADE	:= {}

Local dDataAtu	:= Date() 
Local dRefDate	:= Nil
Local dLastRec	:= Nil 

Local lEnvOpen	:= .T. 
Local lUseLock	:= .T.

Local bWhile	:= Nil

Default cSingleCall	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Abre a empresa passada via parametro³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Select("SM0") == 0
	lEnvOpen	:= .F.
	RpcSetType(3)
	RpcSetEnv(aEmpFil[1],aEmpFil[2],,,'TMK')
Else
	aArea	:= GetArea()
	aAreaADE:= ADE->(GetArea())
EndIf

cFil   		:= xFilial("ADE")
cFilterADE	:= ADE->(DbFilter())

DbSelectArea("ADE")

If !Empty(cFilterADE)
	ADE->(DbClearFilter())
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se deve toda a base deve ser processada ou apenas um unico chamado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cSingleCall)
	ADE->(DbSetOrder(24)) //ADE_FILIAL+ADE_RECORR
	ADE->(DbSeek(cFil + "1"))
	bWhile := {|| !ADE->(Eof()) .AND. ADE->ADE_FILIAL == cFil .AND. ADE->ADE_RECORR == "1" }
Else
	ADE->(DbSetOrder(1)) //ADE_FILIAL+ADE_CODIGO
	ADE->(DbSeek(cFil + cSingleCall))
	bWhile := {||!ADE->(Eof()) .AND. ADE->ADE_FILIAL == cFil .AND. ADE->ADE_CODIGO == cSingleCall }
	lUseLock := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se for executada via job, executa LockByName para que apenas uma³
//³instancia gere os chamados sem interferencia de outra           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (lUseLock .AND. LockByName("TKRECORRENCIA",.T.,.T.,.T.)) .OR. !lUseLock
	
	While Eval(bWhile)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Analisa o tipo de recorrencia³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cStrRec 	:= AllTrim(ADE->ADE_STRREC)  
		aDatas		:= {}
		
		Do Case
			Case Subs( cStrRec, 1, 1 ) == DIARY
				If ( nAt := At( "Day", cStrRec ) + 4)  > 0
					If Len(Subs( cStrRec, nAt, 3 )) <> 0
						nDDay := Val(Subs( cStrRec, nAt, 3 ))
					EndIf
				EndIf	
				nPeriod := 1	
			Case Subs( cStrRec, 1, 1 ) == WEEKLY
				aWeek := {}
				For nX := 1 To 7
					If Subs( cStrRec, nX, 1 ) != ")"
						aAdd( aWeek, &( Subs( cStrRec, 3+(nX-1)*3, 3 ) ) )
					Else
						Exit
					EndIf
				Next nX	
				nPeriod := 2	
			Case Subs( cStrRec, 1, 1 ) == MONTHLY
				// Busca a cada quantos dias
				cDay := ""
				nAt := At( "Day", cStrRec ) + 4
				For nX := nAt To Len(cStrRec)
					If Subs( cStrRec, nX, 1 ) != ")"
						cDay += Subs( cStrRec, nX, 1 )
					Else
						Exit
					EndIf
				Next
				nMDay := Val( cDay )	
				nPeriod := 3	
			Case Subs( cStrRec, 1, 1 ) == YEARLY
				// Busca a cada quantos dias
				cDay := ""
				nAt := At( "Day", cStrRec ) + 4
				For nX := nAt To Len(cStrRec)
					If Subs( cStrRec, nX, 1 ) != ")"
						cDay += Subs( cStrRec, nX, 1 )
					Else
						Exit
					EndIf
				Next
				nYDay := Val( cDay )
				cYMonth := ""
				nAt := At( "Month", cStrRec ) + 6
				For nX := nAt To Len(cStrRec)
					If Subs( cStrRec, nX, 1 ) != ")"
						cYMonth += Subs( cStrRec, nX, 1 )
					Else
						Exit
					EndIf
				Next
				nYMonth := Val(cYMonth)
				nPeriod := 4	
		EndCase
	
		nAt := At( "Advance", cStrRec ) + 8

		If Len(Subs( cStrRec, nAt, 3 )) <> 0
			nAntec := Val(Subs( cStrRec, nAt, 3 ))
		EndIf
			                           
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Analisa quando deve ser gerado o proximo chamado³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Do Case      
	
			//ÚÄÄÄÄÄÄ¿
			//³Diario³
			//ÀÄÄÄÄÄÄÙ
			Case nPeriod == 1 	
				//Localiza o chamado mais proximo da data atual
				dLastRec := GetLastRec(ADE->ADE_CODIGO,dDataAtu)				
				If Empty(dLastRec)
					//Primeira execucao
					AAdd(aDatas,dDataAtu)
					dRefDate := dDataAtu
				Else
					//Verifica se deve ser gerada uma nova recorrencia
					dRefDate  := dLastRec
					nDifData  := dDataAtu - dRefDate
					If nDifData == nDDay 
						AAdd(aDatas,dDataAtu)
					EndIf
				EndIf					
				//Calcula data dos proximos chamados
				If nAntec > 0 
					//Incorpora os dias desde a ultima recorrencia para somar na antecedencia
					nAntec += nDifData
					For nX := 1 to nAntec
						dRefDate := dRefDate + 1
						nInterval++
						If nDDay == nInterval
					   		AAdd(aDatas,dRefDate)
							nInterval := 0
						EndIf
					Next nX
				EndIf	        
			//ÚÄÄÄÄÄÄÄ¿
			//³Semanal³
			//ÀÄÄÄÄÄÄÄÙ
			Case nPeriod == 2				
				//Gera o chamado do dia
				If aWeek[DoW(dDataAtu)]
					AAdd(aDatas,dDataAtu)
				EndIf 				
				//Calcula data dos proximos chamados
				If nAntec > 0
					dRefDate := dDataAtu
					For nX := 1 to nAntec
						dRefDate := dRefDate + 1
						If aWeek[DoW(dRefDate)]
					   		AAdd(aDatas,dRefDate)
						EndIf
					Next nX
				EndIf			
			//ÚÄÄÄÄÄÄ¿
			//³Mensal³
			//ÀÄÄÄÄÄÄÙ
			Case nPeriod == 3				
				//Gera o chamado do dia
				If Day(dDataAtu) == nMDay
					AAdd(aDatas,dDataAtu)
				EndIf	
				//Calcula data dos proximos chamados
				If nAntec > 0
					dRefDate := dDataAtu
					For nX := 1 to nAntec
						dRefDate := dRefDate + 1
						If Day(dRefDate) == nMDay
					   		AAdd(aDatas,dRefDate)
						EndIf
					Next nX
				EndIf	
			//ÚÄÄÄÄÄ¿
			//³Anual³
			//ÀÄÄÄÄÄÙ 
			Case nPeriod == 4				
				If Day(dDataAtu) == nYDay .AND. Month(dDataAtu) == nYMonth
					AAdd(aDatas,dDataAtu)
				EndIf			
				//Calcula data dos proximos chamados
				If nAntec > 0
					dRefDate := dDataAtu
					For nX := 1 to nAntec
						dRefDate := dRefDate + 1
						If Day(dRefDate) == nYDay .AND. Month(dRefDate) == nYMonth
					   		AAdd(aDatas,dRefDate)
						EndIf
					Next nX
				EndIf				
		EndCase
		
		//Gera o chamados recorrentes 
		For nX := 1 to Len(aDatas)
			GenRecurrence(ADE->ADE_CODIGO,aDatas[nX])
		Next nX
		
		ADE->(DbSkip())
	End  

	If lUseLock
		UnLockByName("TKRECORRENCIA",.T.,.T.,.T.)
	EndIf

EndIf    

If !lEnvOpen
	RpcClearEnv()
Else
	If !Empty(cFilterADE)
		DbSelectArea("ADE")
		Set Filter To &cFilterADE
	EndIf
	RestArea(aAreaADE)
	RestArea(aArea)
EndIf

Return Nil    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GetLastRecºAutor  ³Vendas CRM          º Data ³  19/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna a data do chamado recorrente anterior mais proximo  º±±
±±º          ³da data passada via parametro(inclusive a mesma)            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 - Codigo do chamado pai                               º±±
±±º          ³ExpD2 - Data de referencia                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGATMK                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GetLastRec(cCodPai,dDate)

Local aArea		:= GetArea()
Local aAreaADE	:= ADE->(GetArea())
Local dSchedDate:= CtoD("") 

DbSelectArea("ADE")
DbSetOrder(25)//ADE_FILIAL+ADE_CHORRC+ADE_DATA
DbSeek(xFilial("ADE")+cCodPai+DtoS(dDate),.T.)

If ADE->ADE_FILIAL == xFilial("ADE") .AND. ADE->ADE_CHORRC == cCodPai .AND. ADE->ADE_DATA == dDate
	//Mesma data
	dSchedDate := ADE->ADE_DATA
Else
	//Pega a data anterior, pois estara posicionado na proxima (indice crescente)
	While !Bof() .AND. ADE->ADE_FILIAL == xFilial("ADE") .AND. ADE->ADE_CHORRC == cCodPai .AND. ADE->ADE_DATA > dDate
		DbSkip(-1)
	End
	If ADE->ADE_FILIAL == xFilial("ADE") .AND. ADE->ADE_CHORRC == cCodPai .AND.  ADE->ADE_DATA < dDate
		dSchedDate := ADE->ADE_DATA 
	EndIf
EndIf	

RestArea(aAreaADE)
RestArea(aArea)

Return dSchedDate

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GenRecurrenceºAutor  ³Vendas CRM       º Data ³  19/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gera o chamado recorrente na data especificada              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 - Codigo do chamado a ser copiado                     º±±
±±º          ³ExpD2 - Data em que o chamado deve ser gerado               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GenRecurrence(cCallCode,dDateRef)

Local aArea		:= GetArea()
Local aAreaADE  := ADE->(GetArea())
Local dDateBkp	:= dDataBase
Local lRet		:= .T.
Local aCab		:= {}
Local aItens	:= {}
Local nPData	:= 0
Local cNewCall	:= ""

dDataBase := dDateRef

DbSelectArea("ADE")
DbSetOrder(25) //ADE_FILIAL+ADE_CHORRC+ADE_DATA

If !DbSeek(xFilial("ADE") + cCallCode + DtoS(dDateRef))

	DbSetOrder(1)
	DbSeek(xFilial("ADE")+cCallCode)

	If Tk510Copia(cCallCode,@aCab,@aItens,.T.,STR0098) //"Recorrência automática do chamado"
		
		AAdd(aCab,{"ADE_CHORRC",cCallCode,Nil})
		
		If (nPData := aScan(aCab,{|x| AllTrim(x[1]) == "ADE_DATA"})) > 0
			aCab[nPData][2] := dDateRef 
		Else
			AAdd(aCab,{"ADE_DATA",dDateRef,Nil})
		EndIf     

		lRet := TMKA503A(aCab,{aItens},3,@cNewCall)
		
	EndIf

EndIf

dDataBase := dDateBkp
RestArea(aAreaADE)
RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TkDelRec  ºAutor  ³Vendas CRM          º Data ³  23/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Apaga os chamados recorrentes a partir de uma data          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 - Codigo do chamado modelo                            º±±
±±º          ³ExpD2 - Data de referencia para exclusao dos chamados       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKXFUND                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TkDelRec(cCode,dDate)

Local aArea		:= GetArea()
Local aAreaADE	:= ADE->(GetArea()) 
Local cFilADE	:= xFilial("ADE")
Local cFilADF	:= xFilial("ADF")
Local aADFDel	:= {}
Local aADEDel	:= {}
Local nX		:= 0 
Local cFilterADE:= ADE->(DbFilter())

DbSelectArea("ADF")
DbSetOrder(1)

If !Empty(cFilterADE)
	ADE->(DbClearFilter())
EndIf

DbSelectArea("ADE")
DbSetOrder(25)//ADE_FILIAL+ADE_CHORRC+ADE_DATA
DbSeek(cFilADE + cCode + DtoS(dDate),.T.)

While !ADE->(Eof()) .AND. ADE->ADE_FILIAL == cFilADE .AND. ADE->ADE_CHORRC == cCode .AND. ADE->ADE_DATA >= dDate
	If ADE->ADE_STATUS <> "3"
		AAdd(aADEDel,ADE->(Recno()))
		ADF->(DbSeek(cFilADF+ADE->ADE_CODIGO))
		While !ADF->(Eof()) .AND. ADF->ADF_CODIGO == ADE->ADE_CODIGO
			AAdd(aADFDel,ADF->(Recno()))
			ADF->(DbSkip())
		End
	EndIf
	ADE->(DbSkip())
End

Begin Transaction   

	DbSelectArea("ADF")
	For nX := 1 to Len(aADFDel)
		DbGoTo(aADFDel[nX])
		RecLock("ADF",.F.)
		DbDelete()
		MsUnlock()
	Next nX
	
	DbSelectArea("ADE")
	For nX := 1 to Len(aADEDel)
		DbGoTo(aADEDel[nX])
		RecLock("ADE",.F.)
		DbDelete()
		MsUnlock()
	Next nX

End Transaction

If !Empty(cFilterADE)
	DbSelectArea("ADE")
	Set Filter To &cFilterADE
EndIf 

RestArea(aAreaADE)
RestArea(aArea)

Return Nil

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLoad
    @description
    Inicializa variaveis com lista de campos que devem ser ofuscados de acordo com usuario.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cUser, Caractere, Nome do usuário utilizado para validar se possui acesso ao 
        dados protegido.
    @param aAlias, Array, Array com todos os Alias que serão verificados.
    @param aFields, Array, Array com todos os Campos que serão verificados, utilizado 
        apenas se parametro aAlias estiver vazio.
    @param cSource, Caractere, Nome do recurso para gerenciar os dados protegidos.
    
    @return cSource, Caractere, Retorna nome do recurso que foi adicionado na pilha.
    @example FATPDLoad("ADMIN", {"SA1","SU5"}, {"A1_CGC"})
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDLoad(cUser, aAlias, aFields, cSource)
	Local cPDSource := ""

	If FATPDActive()
		cPDSource := FTPDLoad(cUser, aAlias, aFields, cSource)
	EndIf

Return cPDSource

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDUnload
    @description
    Finaliza o gerenciamento dos campos com proteção de dados.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cSource, Caractere, Remove da pilha apenas o recurso que foi carregado.
    @return return, Nulo
    @example FATPDUnload("XXXA010") 
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDUnload(cSource)    

    If FATPDActive()
		FTPDUnload(cSource)    
    EndIf

Return Nil

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDColObfuscate
    @description
    Verifica se a coluna de um grid deve ser ofuscado, tendo como base uma lista de
    campos, esta função deve utilizada somente após a inicialização das variaveis 
    atravez da função FATPDLoad.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cField, Caractere, Campo que sera validado
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.

    @return lObfuscate, Lógico, Retorna se o campo será ofuscado.
    @example FATPDIsObfuscate({"A1_COD","A1_NOME","A1_CGC"})
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDColObfuscate(aFields, cSource)  
    
	Local aPDColObf	:= {}

    If FATPDActive()
		aPDColObf := FTPDColObfuscate(aFields, cSource)  
    EndIf 

Return aPDColObf  

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDObfuscate
    @description
    Realiza ofuscamento de uma variavel ou de um campo protegido.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @sample FATPDObfuscate("999999999","U5_CEL")
    @author Squad CRM & Faturamento
    @since 04/12/2019
    @version P12
    @param xValue, (caracter,numerico,data), Valor que sera ofuscado.
    @param cField, caracter , Campo que sera verificado.
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado

    @return xValue, retorna o valor ofuscado.
/*/
//-----------------------------------------------------------------------------
Static Function FATPDObfuscate(xValue, cField, cSource, lLoad)
    
    If FATPDActive()
		xValue := FTPDObfuscate(xValue, cField, cSource, lLoad)
    EndIf

Return xValue   

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLogUser
    @description
    Realiza o log dos dados acessados, de acordo com as informações enviadas, 
    quando a regra de auditoria de rotinas com campos sensíveis ou pessoais estiver habilitada
	Remover essa função quando não houver releases menor que 12.1.27

   @type  Function
    @sample FATPDLogUser(cFunction, nOpc)
    @author Squad CRM & Faturamento
    @since 06/01/2020
    @version P12
    @param cFunction, Caracter, Rotina que será utilizada no log das tabelas
    @param nOpc, Numerico, Opção atribuída a função em execução - Default=0

    @return lRet, Logico, Retorna se o log dos dados foi executado. 
    Caso o log esteja desligado ou a melhoria não esteja aplicada, também retorna falso.

/*/
//-----------------------------------------------------------------------------
Static Function FATPDLogUser(cFunction, nOpc)

	Local lRet := .F.

	If FATPDActive()
		lRet := FTPDLogUser(cFunction, nOpc)
	EndIf 

Return lRet  

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Função que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive