#INCLUDE "QPPR320.CH"
#INCLUDE "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � QPPR320  � Autor � Robson Ramiro A. Olive� Data � 03.10.02 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Checklist APQP A8                                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QPPR320(void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � PPAP                                                       ���
�������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ���
�������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function QPPR320(lBrow,cPecaAuto,cJPEG)

Local oPrint
Local lPergunte := .F.
Local cFiltro	:= ""
Local aArea		:= GetArea()
Local cStartPath 	:= GetSrvProfString("Startpath","")
Local lPriED320R   := GetMV("MV_QAPQPED",.T.,"1") == '1' // Define se o APQP deve ser feito na primeira ou segunda edi��o 1 - Primeira Edi��o 2 - Segunda Edi��o
Local nNrespR      := 0

Private cPecaRev 	:= ""
Private cEspecie	:= "PPA320"
Private nTamLin 	:= 38 // Tamanho da linha do texto

Default lBrow 		:= .F.
Default cPecaAuto	:= ""
Default cJPEG       := ""          

nNrespR := QPPA320CE()  //Verifica pelo numro de NResp em qual modelo foi feio o APQP
DbSelectArea("QKX")
		DbSetOrder(1)
		cFiltro := 'QKX_NPERG == "01"'
		Set Filter To &cFiltro


If Right(cStartPath,1) <> "\"
	cStartPath += "\"
Endif

If !Empty(cPecaAuto)
	cPecaRev := cPecaAuto
Endif

oPrint := TMSPrinter():New(STR0001) //"Checklist APQP A8"

oPrint:SetLandscape()

If Empty(cPecaAuto)
	If AllTrim(FunName()) == "QPPA320"
		cPecaRev := Iif(!lBrow,M->QKX_PECA + M->QKX_REV, QKX->QKX_PECA + QKX->QKX_REV)
	Else
		lPergunte := Pergunte("PPR180",.T.)

		If lPergunte
			cPecaRev := mv_par01 + mv_par02	
		Else
			Return Nil
		Endif
	Endif
Endif

DbSelectArea("QK1")
DbSetOrder(1)
DbSeek(xFilial()+cPecaRev)

DbSelectArea("QKX")

cFiltro := DbFilter()

If !Empty(cFiltro)
	Set Filter To
Endif

DbSetOrder(1)
If DbSeek(xFilial()+cPecaRev)

nNrespR := QPPA320CE()  //Verifica pelo numro de NResp em qual modelo foi feio o APQP

	If Empty(cPecaAuto)
		MsgRun(STR0002,"",{|| CursorWait(), Iif(nNrespR == 10 ,MontRel(oPrint),MontRED(oPrint)) ,CursorArrow()}) //"Gerando Visualizacao, Aguarde..."
	Else
		Iif(nNrespR == 10 ,MontRel(oPrint),MontRED(oPrint))     //Primeira ou segunda Edi��o APQP (10 -Primeira, 12 -Segunda)
	Endif

	If lPergunte .and. mv_par03 == 1 .or. !Empty(cPecaAuto)
		If !Empty(cJPEG)
			oPrint:SaveAllAsJPEG(cStartPath+cJPEG,1120,855,140)
		Else 
			oPrint:Print()   //Imprime an Impressora padr�o
		EndIF
	Else
		oPrint:Preview()  		// Visualiza antes de imprimir
	Endif
Endif

If !Empty(cFiltro)
	Set Filter To &cFiltro
Endif

If !lPergunte
	RestArea(aArea)
Endif

Return Nil

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � MontRel � Autor � Robson Ramiro A. Olive� Data � 03.10.02 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Checklist APQP A8                                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MontRel(ExpO1)--> Primeira Edi��o APQP                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto oPrint                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPR320                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function MontRel(oPrint)

Local lin, nPos
Local i 		:= 1
Local cTexto	:= ""
Local aPerg		:= {}
Local cPrepor	:= ""

Private oFont16, oFont08, oFont10, oFontCou08

oFont16		:= TFont():New("Arial",16,16,,.F.,,,,.T.,.F.)
oFont08		:= TFont():New("Arial",08,08,,.F.,,,,.T.,.F.)
oFont10		:= TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
oFontCou08	:= TFont():New("Courier New",08,08,,.F.,,,,.T.,.F.)


aAdd( aPerg,{	"01", STR0003,;	//" A metodoligia do plano de controle referenciada na"
				STR0004,; 		//" Secao 6 foi utilizada na preparacao do plano de controle ?"
				Space(50) })

aAdd( aPerg,{	"02", STR0005,;	//" Todas as preocupacoes conhecidas do cliente foram"
				STR0006,; 		//" identificadas para facilitar a selecao de caracteristicas"
				STR0007 }) 		//" especiais de produto/processo ?"

aAdd( aPerg,{	"03", STR0008,;	//" Todas as caracteristicas especiais do produto/processo"
				STR0009,;		//" estao incluidas no plano de controle ?"
				Space(50) })

aAdd( aPerg,{	"04", STR0010,;	//" Foram usados SFMEA, DFMEA e PFMEA para preparar"
				STR0011,; 		//" o plano de controle ?"
				Space(50) })

aAdd( aPerg,{	"05", STR0012,;	//" Todas as especificacoes de material que necessitam de"
				STR0013,; 		//" inspecao foram identificadas ?"
				Space(50) })

aAdd( aPerg,{	"06", STR0014,;	//" O plano de controle indica o recebimento (material e"
				STR0015,; 		//" componente) atraves de processamento/montagem,"
				STR0016 }) 		//" incluindo embalagem ?"

aAdd( aPerg,{	"07", STR0017,;	//" Os requisitos de teste de engenharia foram"
				STR0018,; 		//" identificados ?"
				Space(50) })

aAdd( aPerg,{	"08", STR0019,;	//" Dispositivos de medicao e equipamentos de teste estao"
				STR0020,; 		//" disponiveis conforme requerido pelo plano de controle ?"
				Space(50) })

aAdd( aPerg,{	"09", STR0021,;	//" Se necessario, o cliente aprovou o plano de controle ?"
				Space(50), Space(50) })

aAdd( aPerg,{	"10", STR0022,;	//" Os Metodos de medicao sao compativeis entre"
				STR0023,; 		//" fornecedor e cliente ?"
				Space(50) })


Cabec1ED(oPrint,i)  	// Funcao que monta o cabecalho da Primeira Edi��o APQP
lin := 280

DbSelectArea("QKX")
DbSetOrder(1)
DbSeek(xFilial()+cPecaRev)

Do While !Eof() .and. QKX->QKX_PECA+QKX->QKX_REV == cPecaRev

	cTexto 	:= ""
	nPos	:= 0
	
	If lin > 2200 .or. (QKX->QKX_NPERG $ "09" .and. lin <> 280)
		i++
		oPrint:EndPage() 		// Finaliza a pagina
		Cabec1ED(oPrint,i)  	// Funcao que monta o cabecalho
		lin := 280
	Endif
	
	lin += 40

	nPos := aScan(aPerg, {|x| x[1] == QKX->QKX_NPERG })

	cTexto := AllTrim(Subs(QO_Rectxt(QKX->QKX_CHAVE,cEspecie+QKX->QKX_NPERG,1, nTamLin,"QKO"),1,152))

	cTexto := StrTran(cTexto,Chr(13)+Chr(10))

	oPrint:Say(lin,0050,Str(Val(QKX->QKX_NPERG),2),oFontCou08)

	oPrint:Say(lin		,0150,aPerg[nPos,2],oFontCou08)
	oPrint:Say(lin+40	,0150,aPerg[nPos,3],oFontCou08)
	oPrint:Say(lin+80	,0150,aPerg[nPos,4],oFontCou08)
    
	If QKX->QKX_RPOSTA == "1"
		oPrint:Say(lin,1220,"X",oFont08)
	Else
		oPrint:Say(lin,1320,"X",oFont08)
	Endif
	
	oPrint:Say(lin		,1400,Subs(cTexto,001,38),oFontCou08)
	oPrint:Say(lin+40	,1400,Subs(cTexto,039,38),oFontCou08)
	oPrint:Say(lin+80	,1400,Subs(cTexto,077,38),oFontCou08)
	oPrint:Say(lin+120	,1400,Subs(cTexto,115,38),oFontCou08)
	
	oPrint:Say(lin,2100,Posicione("QAA",1,QKX->QKX_FILRES+QKX->QKX_RESP,"QAA_NOME"),oFontCou08)
	oPrint:Say(lin,2800,DtoC(QKX->QKX_DTPREV),oFontCou08)

	lin += 160
	oPrint:Line( lin, 30, lin, 3000 )   	// horizontal

	If lin > 2220
		i++
		oPrint:EndPage() 		// Finaliza a pagina
		Cabec1ED(oPrint,i)  	// Funcao que monta o cabecalho
		lin := 280
	Endif

	cPrepor := QKX->QKX_PREPOR

	DbSelectArea("QKX")
	DbSkip()

Enddo

oPrint:Say(2360,2100,STR0024,oFont08) //"Preparado Por"
oPrint:Say(2360,2500,cPrepor,oFont08)

Return Nil


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � Cabec1ED� Autor � Robson Ramiro A. Olive� Data � 03.10.02 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Checklist APQP A8                                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Cabec1ED(ExpO1,ExpN1)--> Primeira Edi��o APQP              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto oPrint                                      ���
���          � ExpN1 = Contador de paginas                                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPR320                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function Cabec1ED(oPrint,i)

Local cFileLogo  	:= "LGRL"+SM0->M0_CODIGO+FWCodFil()+".BMP" // Empresa+Filial
Local nTotPag		:= 2

If !File(cFileLogo)
	cFileLogo := "LGRL" + SM0->M0_CODIGO+".BMP" // Empresa
Endif

oPrint:StartPage() 		// Inicia uma nova pagina

oPrint:SayBitmap(05,0005, cFileLogo,328,82)             // Tem que estar abaixo do RootPath
oPrint:SayBitmap(05,2800, "Logo.bmp",237,58) 

oPrint:Say(050,1000,STR0025,oFont16) //" A-8 LISTA DE VERIFICACAO DO PLANO DE CONTROLE"

oPrint:Say(160,040,STR0026,oFont08) //"Numero da Peca Interno ou do Cliente"
oPrint:Say(160,600,QK1->QK1_PECA,oFontCou08)

// Box 
oPrint:Box( 200, 30, 2220, 3000 )
               
oPrint:Say(220,0550,STR0027,oFont08) //"Pergunta"
oPrint:Say(220,1210,STR0028,oFont08) //"Sim"
oPrint:Say(220,1310,STR0029,oFont08) //"Nao"
oPrint:Say(220,1550,STR0030,oFont08) //"Cometarios / Acao Requerida"
oPrint:Say(220,2300,STR0031,oFont08) //"Pessoa Responsavel"
oPrint:Say(220,2800,STR0032,oFont08) //"Data Prevista"

oPrint:Line( 280, 30, 280, 3000 )   	// horizontal

oPrint:Line( 200, 0140, 2220, 0140 )	// vertical
oPrint:Line( 200, 1190, 2220, 1190 )	// vertical
oPrint:Line( 200, 1290, 2220, 1290 )	// vertical
oPrint:Line( 200, 1390, 2220, 1390 )	// vertical
oPrint:Line( 200, 2090, 2220, 2090 )	// vertical
oPrint:Line( 200, 2790, 2220, 2790 )	// vertical

oPrint:Say(2240,2100,STR0033,oFont08) //"Data de Revisao"
oPrint:Say(2240,2500,DtoC(QKX->QKX_DTREVI),oFont08)
oPrint:Say(2280,2500,STR0034+Str(i,2)+STR0035+Str(nTotPag,2),oFont08) //"Pagina "###" de "

Return Nil



/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � MontRED � Autor � Robson Ramiro A. Olive� Data � 03.10.02 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Checklist APQP A8                                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MontRED(ExpO1)--> Segunda Edi��o APQP                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto oPrint                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPR320                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function MontRED(oPrint)

Local lin, nPos
Local i 		:= 1
Local cTexto	:= ""
Local aPerg		:= {}
Local cPrepor	:= ""

Private oFont16, oFont08, oFont10, oFontCou08

oFont16		:= TFont():New("Arial",16,16,,.F.,,,,.T.,.F.)
oFont08		:= TFont():New("Arial",08,08,,.F.,,,,.T.,.F.)
oFont10		:= TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
oFontCou08	:= TFont():New("Courier New",08,08,,.F.,,,,.T.,.F.)


aAdd( aPerg,{	"01", STR0039,;	//"A metodologia do plano de controle descrita "
				STR0040,; 		//"no Capitulo 6 do manual APQP foi utilizada no "
				STR0041 })      //"desenvolvimento do plano de Controle?"

aAdd( aPerg,{	"02", STR0042,;	//"Todos os controles identificados na PFMEA foram "
				STR0043,; 		//"inclusos no plano de controle?"
				Space(50) }) 	

aAdd( aPerg,{	"03", STR0008,;	//" Todas as caracteristicas especiais do produto/processo"
				STR0009,;		//" estao incluidas no plano de controle ?"
				Space(50) })

aAdd( aPerg,{	"04", STR0044,;  //"Foram usadas DFMEA e PFMEA para preparar o "
				STR0045,; 	//"plano de controle ?"
				Space(50) })

aAdd( aPerg,{	"05", STR0012,;	//" Todas as especificacoes de material que necessitam de"
				STR0013,; 		//" inspecao foram identificadas ?"
				Space(50) })

aAdd( aPerg,{	"06", STR0014,;	//" O plano de controle indica o recebimento (material e"
				STR0015,; 		//" componente) atraves de processamento/montagem,"
				STR0016 }) 		//" incluindo embalagem ?"

aAdd( aPerg,{	"07", STR0046,;	//"Os requisitos de teste de desempenho de engenharia"
				STR0047,; 		//"e requisitos dimensionais foram identificados ? "
				Space(50) })

aAdd( aPerg,{	"08", STR0019,;	//" Dispositivos de medicao e equipamentos de teste estao"
				STR0020,; 		//" disponiveis conforme requerido pelo plano de controle ?"
				Space(50) })

aAdd( aPerg,{	"09", STR0021,;	//" Se necessario, o cliente aprovou o plano de controle ?"
				Space(50), Space(50) })

aAdd( aPerg,{	"10", STR0048,;	//"A Metodologia e compatibilidade dos dispositivos de"
				STR0049,; 		//"medi��o s�o apropriadas para atender aos requisitos"
				STR0050 })      //"do cliente?"
				
aAdd( aPerg,{	"11", STR0051,; //"A an�lise dos sistemas de medi��o foi concluida de "	
				STR0052,; 		//"acordo com os requisitos do cliente?"
				Space(50) })      
				
aAdd( aPerg,{	"12", STR0053,;	//"Os tamanhos das amostras foram baseadas nas normas da"
				STR0036,; 	   //"industria, tabelas estat�sticas do plano de amostragem"  
				STR0037 })      //"ou em outros metodos de controle de processo?" 
				


Cabec2ED(oPrint,i)  	// Funcao que monta o cabecalho da Primeira Edi��o APQP
lin := 280

DbSelectArea("QKX")
DbSetOrder(1)
DbSeek(xFilial()+cPecaRev)

Do While !Eof() .and. QKX->QKX_PECA+QKX->QKX_REV == cPecaRev

	cTexto 	:= ""
	nPos	:= 0
	
	If lin > 2200 .or. (QKX->QKX_NPERG $ "09" .and. lin <> 280)
		i++
		oPrint:EndPage() 		// Finaliza a pagina
		Cabec2ED(oPrint,i)  	// Funcao que monta o cabecalho
		lin := 280
	Endif
	
	lin += 40

	nPos := aScan(aPerg, {|x| x[1] == QKX->QKX_NPERG })

	cTexto := AllTrim(Subs(QO_Rectxt(QKX->QKX_CHAVE,cEspecie+QKX->QKX_NPERG,1, nTamLin,"QKO"),1,152))

	cTexto := StrTran(cTexto,Chr(13)+Chr(10))

	oPrint:Say(lin,0050,Str(Val(QKX->QKX_NPERG),2),oFontCou08)

	oPrint:Say(lin		,0150,aPerg[nPos,2],oFontCou08)
	oPrint:Say(lin+40	,0150,aPerg[nPos,3],oFontCou08)
	oPrint:Say(lin+80	,0150,aPerg[nPos,4],oFontCou08)
    
	//Consist�ncia para verificar onde Marca o "X" no relatorio//
	If QKX->QKX_RPOSTA == "1"
		oPrint:Say(lin,1120,"X",oFont08)             //Se o valor   for igua a 1, Cria na coluna 1120
		Elseif QKX->QKX_RPOSTA == "2" 
			oPrint:Say(lin,1220,"X",oFont08)        //Se o valor  for igua a 2, Cria na coluna 1120
		Else
			oPrint:Say(lin,1338,"X",oFont08)        //Se o valor  for igua a 3, Cria na coluna 1120
	Endif 
	
	oPrint:Say(lin		,1400,Subs(cTexto,001,38),oFontCou08)
	oPrint:Say(lin+40	,1400,Subs(cTexto,039,38),oFontCou08)
	oPrint:Say(lin+80	,1400,Subs(cTexto,077,38),oFontCou08)
	oPrint:Say(lin+120	,1400,Subs(cTexto,115,38),oFontCou08)
	
	oPrint:Say(lin,2100,Posicione("QAA",1,QKX->QKX_FILRES+QKX->QKX_RESP,"QAA_NOME"),oFontCou08)
	oPrint:Say(lin,2800,DtoC(QKX->QKX_DTPREV),oFontCou08)

	lin += 160
	oPrint:Line( lin, 30, lin, 3000 )   	// horizontal

	If lin > 2220
		i++
		oPrint:EndPage() 		// Finaliza a pagina
		Cabec2ED(oPrint,i)  	// Funcao que monta o cabecalho
		lin := 280
	Endif

	cPrepor := QKX->QKX_PREPOR

	DbSelectArea("QKX")
	DbSkip()

Enddo

oPrint:Say(2360,2100,STR0024,oFont08) //"Preparado Por"
oPrint:Say(2360,2500,cPrepor,oFont08)

Return Nil


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � Cabec2ED� Autor � Robson Ramiro A. Olive� Data � 03.10.02 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Checklist APQP A8                                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Cabec2ED(ExpO1,ExpN1)--> Segunda Edi��o APQP              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto oPrint                                      ���
���          � ExpN1 = Contador de paginas                                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPR320                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function Cabec2ED(oPrint,i)

Local cFileLogo  	:= "LGRL"+SM0->M0_CODIGO+FWCodFil()+".BMP" // Empresa+Filial
Local nTotPag		:= 2

If !File(cFileLogo)
	cFileLogo := "LGRL" + SM0->M0_CODIGO+".BMP" // Empresa
Endif

oPrint:StartPage() 		// Inicia uma nova pagina

oPrint:SayBitmap(05,0005, cFileLogo,328,82)             // Tem que estar abaixo do RootPath
oPrint:SayBitmap(05,2800, "Logo.bmp",237,58) 

oPrint:Say(050,1000,STR0025,oFont16) //" A-8 LISTA DE VERIFICACAO DO PLANO DE CONTROLE"

oPrint:Say(160,040,STR0026,oFont08) //"Numero da Peca Interno ou do Cliente"
oPrint:Say(160,600,QK1->QK1_PECA,oFontCou08)

// Box 
oPrint:Box( 200, 30, 2220, 3000 )
               
oPrint:Say(220,0550,STR0027,oFont08) //"Pergunta"
oPrint:Say(220,1100,STR0028,oFont08) //"Sim"
oPrint:Say(220,1200,STR0029,oFont08) //"Nao"
oPrint:Say(220,1320,STR0038,oFont08) //"N/a"
oPrint:Say(220,1550,STR0030,oFont08) //"Cometarios / Acao Requerida"
oPrint:Say(220,2300,STR0031,oFont08) //"Pessoa Responsavel"
oPrint:Say(220,2800,STR0032,oFont08) //"Data Prevista"

oPrint:Line( 280, 30, 280, 3000 )   	// horizontal

oPrint:Line( 200, 0140, 2220, 0140 )	// vertical
oPrint:Line( 200, 1080, 2220, 1080 )	// vertical
oPrint:Line( 200, 1180, 2220, 1180 )	// vertical
oPrint:Line( 200, 1285, 2220, 1285 )	// vertical   //(nova linha para a divisao do n/a )//
oPrint:Line( 200, 1390, 2220, 1390 )	// vertical
oPrint:Line( 200, 2090, 2220, 2090 )	// vertical
oPrint:Line( 200, 2790, 2220, 2790 )	// vertical

oPrint:Say(2240,2100,STR0033,oFont08) //"Data de Revisao"
oPrint:Say(2240,2500,DtoC(QKX->QKX_DTREVI),oFont08)
oPrint:Say(2280,2500,STR0034+Str(i,2)+STR0035+Str(nTotPag,2),oFont08) //"Pagina "###" de "

Return Nil
