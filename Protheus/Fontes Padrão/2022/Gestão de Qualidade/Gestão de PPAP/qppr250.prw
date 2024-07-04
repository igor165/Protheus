#INCLUDE "QPPR250.CH"
#INCLUDE "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � QPPR250  � Autor � Robson Ramiro A. Olive� Data � 23.09.02 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Checklist APQP A1                                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QPPR250(void)                                              ���
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

Function QPPR250(lBrow,cPecaAuto,cJPEG)

Local oPrint
Local lPergunte := .F.
Local cFiltro	:= ""
Local aArea		:= GetArea()
Local cStartPath 	:= GetSrvProfString("Startpath","")
Local lPriED250R   := GetMV("MV_QAPQPED",.T.,"1") == '1' // Define se o APQP deve ser feito na primeira ou segunda edi��o 1 - Primeira Edi��o 2 - Segunda Edi��o
Local nNrespR      := 0
Private cPecaRev 	:= ""
Private cEspecie	:= "PPA250"
Private nTamLin 	:= 38 // Tamanho da linha do texto

Default lBrow 		:= .F.
Default cPecaAuto	:= ""
Default cJPEG       := ""   

nNrespR := QPPA250CE()  //Verifica pelo numro de NResp em qual modelo foi feio o APQP
DbSelectArea("QKQ")
		DbSetOrder(1)
		cFiltro := 'QKQ_NPERG == "01"'
		Set Filter To &cFiltro




If Right(cStartPath,1) <> "\"
	cStartPath += "\"
Endif

If !Empty(cPecaAuto)
	cPecaRev := cPecaAuto
Endif

oPrint := TMSPrinter():New(STR0001) //"Checklist APQP A1"

oPrint:SetLandscape()

If Empty(cPecaAuto)
	If AllTrim(FunName()) == "QPPA250"
		cPecaRev := Iif(!lBrow,M->QKQ_PECA + M->QKQ_REV, QKQ->QKQ_PECA + QKQ->QKQ_REV)
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

DbSelectArea("QKQ")

cFiltro := DbFilter()

If !Empty(cFiltro)
	Set Filter To
Endif

DbSetOrder(1)
If DbSeek(xFilial()+cPecaRev)
       

nNrespR := QPPA250CE()  //Verifica pelo numro de NResp em qual modelo foi feio o APQP


	If Empty(cPecaAuto)
		MsgRun(STR0002,"",{|| CursorWait(), Iif(nNrespR == 8 ,MontRel(oPrint),MontRED(oPrint) ) ,CursorArrow()}) //"Gerando Visualizacao, Aguarde..."
	Else
		Iif(nNrespR == 8 ,MontRel(oPrint),MontRED(oPrint) )
	Endif

	If lPergunte .and. mv_par03 == 1 .or. !Empty(cPecaAuto)
		If !Empty(cJPEG)
			oPrint:SaveAllAsJPEG(cStartPath+cJPEG,1120,855,140)
		Else 
			oPrint:Print()
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
���Funcao    � MontRel � Autor � Robson Ramiro A. Olive� Data � 23.09.02 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Checklist APQP A1                                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MotaRel(ExpO1)                                             ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto oPrint                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPR250                                                    ���
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


aAdd( aPerg,{ 	"01", 	STR0003,; 	//"O SFMEA e/ou DFMEA foi preparado utilizando o manual"
						STR0004,; 	//"de referencia Analise de Modo e Efeitos de Falha"
						STR0005 }) 	//"Potencial(FMEA) da Chrysler, Ford e General Motors ?"

aAdd( aPerg,{ 	"02", 	STR0006,; //"Foram analisados criticamente dados historicos de"
						STR0007,; //"campanhas e garantia ?"
						Space(50)})

aAdd( aPerg,{ 	"03", STR0008,; //"Outros DFMEA's de pecas similares foram considerados ?"
				Space(50), Space(50) })

aAdd( aPerg,{ 	"04", 	STR0009,; //"O SFMEA e/ou DFMEA identifica as Caracteristica"
						STR0010,; //"Especiais ?"
						Space(50) })

aAdd( aPerg,{	"05", 	STR0011,; //"As caracteristicas de projeto que afetam os modos de"
						STR0012,; //"falha de alta prioridade de risco foram identificas ?"
						Space(50) })

aAdd( aPerg,{ 	"06", 	STR0013,; //"Foram designadas acoes corretivas apropriadas para"
						STR0014,; //"os numeros de prioridade de risco elevado ?"
						Space(50) })

aAdd( aPerg,{ 	"07", 	STR0013,; //"Foram designadas acoes corretivas apropriadas para"
						STR0015,; //"os numeros de severidade elevada ?"
						Space(50) })

aAdd( aPerg,{ 	"08", 	STR0016,; //"As Prioridades de risco elevado foram revistas apos as"
						STR0017,; //"acoes corretivas completadas e verificadas ?"
						Space(50) })


Cabec1ED(oPrint,i)  	// Funcao que monta o cabecalho
lin := 280

DbSelectArea("QKQ")
DbSetOrder(1)
DbSeek(xFilial()+cPecaRev)

Do While !Eof() .and. QKQ->QKQ_PECA+QKQ->QKQ_REV == cPecaRev

	cTexto 	:= ""
	nPos	:= 0
	
	If lin > 2200
		i++
		oPrint:EndPage() 		// Finaliza a pagina
		Cabec1ED(oPrint,i)  	// Funcao que monta o cabecalho
		lin := 280
	Endif
	
	lin += 40

	nPos := aScan(aPerg, {|x| x[1] == QKQ->QKQ_NPERG })
	
	cTexto := AllTrim(Subs(QO_Rectxt(QKQ->QKQ_CHAVE,cEspecie+QKQ->QKQ_NPERG,1, nTamLin,"QKO"),1,152))

	cTexto := StrTran(cTexto,Chr(13)+Chr(10))
	
	oPrint:Say(lin,0050,Str(Val(QKQ->QKQ_NPERG),2),oFontCou08)

	oPrint:Say(lin		,0150,aPerg[nPos,2],oFontCou08)
	oPrint:Say(lin+40	,0150,aPerg[nPos,3],oFontCou08)
	oPrint:Say(lin+80	,0150,aPerg[nPos,4],oFontCou08)
    
	If QKQ->QKQ_RPOSTA == "1"
		oPrint:Say(lin,1220,"X",oFont08)
	Else
		oPrint:Say(lin,1320,"X",oFont08)
	Endif
	
	oPrint:Say(lin		,1400,Subs(cTexto,001,38),oFontCou08)
	oPrint:Say(lin+40	,1400,Subs(cTexto,039,38),oFontCou08)
	oPrint:Say(lin+80	,1400,Subs(cTexto,077,38),oFontCou08)
	oPrint:Say(lin+120	,1400,Subs(cTexto,115,38),oFontCou08)
	
	oPrint:Say(lin,2100,Posicione("QAA",1,QKQ->QKQ_FILRES+QKQ->QKQ_RESP,"QAA_NOME"),oFontCou08)
	oPrint:Say(lin,2800,DtoC(QKQ->QKQ_DTPREV),oFontCou08)

	lin += 160
	oPrint:Line( lin, 30, lin, 3000 )   	// horizontal

	If lin > 2220
		i++
		oPrint:EndPage() 		// Finaliza a pagina
		Cabec1ED(oPrint,i)  	// Funcao que monta o cabecalho
		lin := 280
	Endif

	cPrepor := QKQ->QKQ_PREPOR

	DbSelectArea("QKQ")
	DbSkip()

Enddo

oPrint:Say(2360,2100,STR0018,oFont08) //"Preparado Por"
oPrint:Say(2360,2500,cPrepor,oFont08)

Return Nil


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � Cabecalho� Autor � Robson Ramiro A. Olive� Data � 23.09.02 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Checklist APQP A1                                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Cabecalho(ExpO1,ExpN1)                                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto oPrint                                      ���
���          � ExpN1 = Contador de paginas                                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPR250                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function Cabec1ED(oPrint,i)

Local cFileLogo  	:= "LGRL"+SM0->M0_CODIGO+FWCodFil()+".BMP" // Empresa+Filial
Local nTotPag		:= 1

If !File(cFileLogo)
	cFileLogo := "LGRL" + SM0->M0_CODIGO+".BMP" // Empresa
Endif

oPrint:StartPage() 		// Inicia uma nova pagina

oPrint:SayBitmap(05,0005, cFileLogo,328,82)             // Tem que estar abaixo do RootPath
oPrint:SayBitmap(05,2800, "Logo.bmp",237,58) 

oPrint:Say(050,1000,STR0019,oFont16) //" A-1 LISTA DE VERIFICACAO DE FMEA DE PROJETO"

oPrint:Say(160,040,STR0020,oFont08) //"Numero da Peca Interno ou do Cliente"
oPrint:Say(160,600,QK1->QK1_PECA,oFontCou08)

// Box 
oPrint:Box( 200, 30, 2220, 3000 )
               
oPrint:Say(220,0550,STR0021,oFont08) //"Pergunta"
oPrint:Say(220,1210,STR0022,oFont08) //"Sim"
oPrint:Say(220,1310,STR0023,oFont08) //"Nao"
oPrint:Say(220,1550,STR0024,oFont08) //"Cometarios / Acao Requerida"
oPrint:Say(220,2300,STR0025,oFont08) //"Pessoa Responsavel"
oPrint:Say(220,2800,STR0026,oFont08) //"Data Prevista"

oPrint:Line( 280, 30, 280, 3000 )   	// horizontal

oPrint:Line( 200, 0140, 2220, 0140 )	// vertical
oPrint:Line( 200, 1190, 2220, 1190 )	// vertical
oPrint:Line( 200, 1290, 2220, 1290 )	// vertical
oPrint:Line( 200, 1390, 2220, 1390 )	// vertical
oPrint:Line( 200, 2090, 2220, 2090 )	// vertical
oPrint:Line( 200, 2790, 2220, 2790 )	// vertical

oPrint:Say(2240,2100,STR0027,oFont08) //"Data de Revisao"
oPrint:Say(2240,2500,DtoC(QKQ->QKQ_DTREVI),oFont08)
oPrint:Say(2280,2500,STR0028+Str(i,2)+STR0029+Str(nTotPag,2),oFont08) //"Pagina "###" de "

Return Nil
                        


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � MontRED � Autor � Klaus Daniel Lopes Cabral Data � 23.09.02 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Checklist APQP A1                                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MontaRED(ExpO1)                                             ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto oPrint                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPR250                                                    ���
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
oFontCou08	:= TFont():New("Courier New",06,06,,.F.,,,,.T.,.F.)


aAdd( aPerg,{ 	"01", 	STR0034,; 	//"A DFMEA foi preparada utilizando-se o manual de refer�ncia de"
						STR0035,;   //"An�lise de Modo e Efeitos de Falha Potencial (FMEA) da "
						STR0036})   // "Chrysler, Ford e General Motors e requisitos do Cliente?"


aAdd( aPerg,{ 	"02", 	STR0006,;   //"Foram analisados criticamente dados historicos de"
						STR0007,;   //"campanhas e garantia ?"
						Space(50)})

aAdd( aPerg,{ 	"03", 	STR0038,;		//"As Melhores Pr�ticas e li��es aprendidas de DFMEA's"
                      	STR0039,;     //"similares foram consideradas?"
				 		Space(50) })

aAdd( aPerg,{ 	"04", 	STR0040,;   //"A DFMEA identifica as Caracteristicas Especiais?"
						Space(50),;
						Space(50) })
						
						
aAdd( aPerg,{	"05", 	STR0041,;   //"5-As Caracteristicas de repasse (gloss�rio) foram"
						STR0042,;   //"identificadas e analisadas criticamente com os"
						STR0043 })   //"fornecedores afetados quanto ao alinhamento da FMEA ?"
						
						

aAdd( aPerg,{ 	"06", 	STR0045,;   //"As Caracter�sticas especiais designadas pelo cliente ou "
						STR0046,;   //"organiza��o foram analisadas criticamente com os"
						STR0047})   //"fornecedores afetados para assegurar o Alinhamento da FMEA ?"
						
						 

aAdd( aPerg,{ 	"07", 	STR0049,; //"As caracter�sticas de projeto que afetam os modos de"
						STR0050,; //"falha de prioridade de risco elevado foram identificadas?"
						Space(50) })

aAdd( aPerg,{ 	"08", 	STR0048,; //"Foram designadas a��es corretivas apropriadas para"
   						STR0044,; //"os numeros de prioridade de risco elevado?"
   						Space(50) }) 
						
						
aAdd( aPerg,{ 	"09", 	STR0032,; //"Foram designadas a��es corretivas apropriadas para"  
						STR0037,; //"os numeros de severidade elevada?"
						Space(50) })   
						                                                                    
aAdd( aPerg,{ 	"10", 	STR0030,; //"As prioridades de risco foram revistas ap�s as"
   						STR0031,; //"a��es corretivas serem conclu�das e verificadas?"
   						Space(50)}) //"Foram designadas a��es corretivas apropriadas para"  
 





Cabec2ED(oPrint,i)  	// Funcao que monta o cabecalho
lin := 282

DbSelectArea("QKQ")
DbSetOrder(1)
DbSeek(xFilial()+cPecaRev)

Do While !Eof() .and. QKQ->QKQ_PECA+QKQ->QKQ_REV == cPecaRev

	cTexto 	:= ""
	nPos	:= 0
	
	If lin > 2370
		i++
		oPrint:EndPage() 		// Finaliza a pagina
		Cabec2ED(oPrint,i)  	// Funcao que monta o cabecalho
		lin := 280
	Endif
	
	lin += 40

	nPos := aScan(aPerg, {|x| x[1] == QKQ->QKQ_NPERG })
	
	cTexto := AllTrim(Subs(QO_Rectxt(QKQ->QKQ_CHAVE,cEspecie+QKQ->QKQ_NPERG,1, nTamLin,"QKO"),1,152))

	cTexto := StrTran(cTexto,Chr(13)+Chr(10))
	
	oPrint:Say(lin,0050,Str(Val(QKQ->QKQ_NPERG),2),oFontCou08)

	oPrint:Say(lin		,0150,aPerg[nPos,2],oFontCou08)
	oPrint:Say(lin+40	,0150,aPerg[nPos,3],oFontCou08)
	oPrint:Say(lin+80	,0150,aPerg[nPos,4],oFontCou08)
	
        
    //Consist�ncia para verificar onde Marca o "X" no relatorio//
	If QKQ->QKQ_RPOSTA == "1"
		oPrint:Say(lin,1120,"X",oFont08)             //Se o valor de QKQ_RPOSTA for igua a 1, Cria na coluna 1120
		Elseif QKQ->QKQ_RPOSTA == "2" 
			oPrint:Say(lin,1220,"X",oFont08)        //Se o valor de QKQ_RPOSTA for igua a 2, Cria na coluna 1120
		Else
			oPrint:Say(lin,1338,"X",oFont08)        //Se o valor de QKQ_RPOSTA for igua a 3, Cria na coluna 1120
	Endif 

	
	oPrint:Say(lin		,1400,Subs(cTexto,001,38),oFontCou08)
	oPrint:Say(lin+40	,1400,Subs(cTexto,039,38),oFontCou08)
	oPrint:Say(lin+80	,1400,Subs(cTexto,077,38),oFontCou08)
	oPrint:Say(lin+120	,1400,Subs(cTexto,115,38),oFontCou08)
	
	oPrint:Say(lin,2100,Posicione("QAA",1,QKQ->QKQ_FILRES+QKQ->QKQ_RESP,"QAA_NOME"),oFontCou08)
	oPrint:Say(lin,2800,DtoC(QKQ->QKQ_DTPREV),oFontCou08)

	lin += 160
	oPrint:Line( lin, 30, lin, 3000 )   	// Linha horizontal no termino de cada campo

	If lin > 2400
		i++
		oPrint:EndPage() 		// Finaliza a pagina
		Cabec2ED(oPrint,i)  	// Funcao que monta o cabecalho
		lin := 280
	Endif

	cPrepor := QKQ->QKQ_PREPOR

	DbSelectArea("QKQ")
	DbSkip()

Enddo

oPrint:Say(2390,2100,STR0018,oFont08) //"Preparado Por"
oPrint:Say(2390,2500,cPrepor,oFont08)

Return Nil


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � Cabec2ED� Autor � Klaus DAniel L C Data � 23.09.02 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Checklist APQP A1                                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Cabec2ED(ExpO1,ExpN1)                                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto oPrint                                      ���
���          � ExpN1 = Contador de paginas                                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPR250                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function Cabec2ED(oPrint,i)

Local cFileLogo  	:= "LGRL"+SM0->M0_CODIGO+FWCodFil()+".BMP" // Empresa+Filial
Local nTotPag		:= 1

If !File(cFileLogo)
	cFileLogo := "LGRL" + SM0->M0_CODIGO+".BMP" // Empresa
Endif

oPrint:StartPage() 		// Inicia uma nova pagina

oPrint:SayBitmap(05,0005, cFileLogo,328,82)             // Tem que estar abaixo do RootPath
oPrint:SayBitmap(05,2800, "Logo.bmp",237,58) 

oPrint:Say(050,1000,STR0019,oFont16) //" A-1 LISTA DE VERIFICACAO DE FMEA DE PROJETO"

oPrint:Say(160,040,STR0020,oFont08) //"Numero da Peca Interno ou do Cliente"
oPrint:Say(160,600,QK1->QK1_PECA,oFontCou08)

// Box 
oPrint:Box( 200, 30, 2240, 3000 )
               
oPrint:Say(220,0550,STR0021,oFont08) //"Pergunta"
oPrint:Say(220,1100,STR0022,oFont08) //"Sim"
oPrint:Say(220,1200,STR0023,oFont08) //"Nao"
oPrint:Say(220,1320,STR0033,oFont08) //"N/a"
oPrint:Say(220,1550,STR0024,oFont08) //"Cometarios / Acao Requerida"
oPrint:Say(220,2300,STR0025,oFont08) //"Pessoa Responsavel"
oPrint:Say(220,2800,STR0026,oFont08) //"Data Prevista"

oPrint:Line( 315, 30, 315, 3000 )   	// horizontal

oPrint:Line( 200, 0140, 2240, 0140 )	// vertical
oPrint:Line( 200, 1080, 2240, 1080 )	// vertical
oPrint:Line( 200, 1180, 2240, 1180 )	// vertical
oPrint:Line( 200, 1285, 2240, 1285 )	// vertical   //(nova linha para a divisao do n/a )//
oPrint:Line( 200, 1390, 2240, 1390 )	// vertical
oPrint:Line( 200, 2090, 2240, 2090 )	// vertical
oPrint:Line( 200, 2790, 2240, 2790 )	// vertical  


oPrint:Say(2290,2100,STR0027,oFont08) //"Data de Revisao"
oPrint:Say(2290,2500,DtoC(QKQ->QKQ_DTREVI),oFont08)
oPrint:Say(2330,2500,STR0028+Str(i,2)+STR0029+Str(nTotPag,2),oFont08) //"Pagina "###" de "

Return Nil