#INCLUDE "PROTHEUS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RSPXTEST.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ RSPXTEST ³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 03/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotinas para Realizacao de Avaliacoes.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RSPXTEST()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia Car.³06/08/14³TQENRX³Incluido o fonte da 11 para a 12 e efetua-³±±
±±³            ³        ³      ³da a limpeza.                             ³±±
±±³Renan Borges³05/01/15³TREMH6³Ajuste para montagem de avaliações de     ³±±
±±³            ³        ³      ³acordo com a quantidade de questões, pré- ³±±
±±³            ³        ³      ³determinada pelo tamanho do campo QQ_ITEM.³±± 
±±³Renan Borges³08/07/15³TRTYGK³Ajuste na função RSPXLIST para que o siste³±±
±±³            ³        ³      ³ma verifique se a montagem das questoes   ³±±
±±³            ³        ³      ³passa do limite do campo QO_PONTOS        ³±± 
±±³Matheus M.  ³24/10/16³TVPAJV³Ajuste no preenchimento das questões para ³±± 
±±³            ³        ³      ³avaliações com modelo.			          ³±± 
±±³Oswaldo L.  ³03/04/17³DRHPONTP-9  ³Projeto cTree                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ RspxCapa ³ Autor ³ Cristina Ogura        ³ Data ³ 25.08.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta os dados da Avaliacao a ser realizada.		          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RspxCapa()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function RspxCapa()
Local oDlgCapa, oBtn1
Local nx	:= 0
Local lRet	:= .F. 
Local nTipo	:= 1     
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaração de arrays para dimensionar tela		                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}  

Local aAdv1Size		:= {}
Local aInfo1AdvSize	:= {}
Local aObj1Size		:= {}
Local aObj1Coords	:= {}

Local aAdv2Size		:= {}
Local aInfo2AdvSize	:= {}
Local aObj2Size		:= {}
Local aObj2Coords	:= {}

Local aGDCoord		:= {}

Private oMemo    := Nil
Private oPerg01
Private cPergMemo	:= ""
Private oSeq
Private cSequenc 	:= ""
Private nSeq		:= 0
               
For nx := 1 To Len(aListBox)
                       
	If cModulo == "TRM"       
	       
		nTipo := IIf(aListBox[nx][5] == Nil, 1, aListBox[nx][5])	
	EndIf

	RspxHora() //Inicializa Tempo inicial
	
	nSeq    	:= 0
	nSeqAnt 	:= 1
	cPergMemo	:= ""
	aAltern		:={}
	Final		:={}
	aRad		:={}
	nRadio 		:= 0
	nListBox	:= nx
	
    RspxPreenche(nTipo)
    
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Monta as Dimensoes dos Objetos         					   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	aAdvSize		:= {}
	aInfoAdvSize	:= {}
	aObjSize		:= {}
	aObjCoords		:= {}  
	
	aAdv1Size		:= {}
	aInfo1AdvSize	:= {}
	aObj1Size		:= {}
	aObj1Coords		:= {}
	
	aAdv2Size		:= {}
	aInfo2AdvSize	:= {}
	aObj2Size		:= {}
	aObj2Coords		:= {}
	
	aAdvSize		:= MsAdvSize(.F.,.T.,100)
	aAdvSize[3]		:= aAdvSize[3]*0.6		//Coluna Final Area Trabalho
	aAdvSize[5]		:= aAdvSize[5]*0.6		//Coluna Final Dialogo
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }					 
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )   
	aAdd( aObjCoords , { 000 , 030 , .T. , .F. } )
	aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )
	
	aAdv1Size		:= aClone(aObjSize[1])
	aInfo1AdvSize	:= { aAdv1Size[2] , aAdv1Size[1] , aAdv1Size[4] , aAdv1Size[3] , 5 , 5 }					 
	aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )		//1-Espaco
	aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )   
	aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )
	aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )
	aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )		//5-Espaco
	aObj1Size	:= MsObjSize( aInfo1AdvSize , aObj1Coords )

	aAdv2Size		:= aClone(aObj1Size[1])
	aInfo2AdvSize	:= { aAdv2Size[2] , aAdv2Size[1] , aAdv2Size[4] , aAdv2Size[3] , 5 , 5 }					 
	aAdd( aObj2Coords , { 000 , 000 , .T. , .T. } )	
	aAdd( aObj2Coords , { 070 , 000 , .F. , .T. } )	
	aAdd( aObj2Coords , { 000 , 000 , .T. , .T. } )   
	aObj2Size	:= MsObjSize( aInfo2AdvSize , aObj2Coords,,.T. )

	
	DEFINE FONT oFont 	NAME "Arial" SIZE 0,-11 BOLD
	DEFINE MSDIALOG oDlgCapa TITLE OemtoAnsi(STR0004) From aAdvSize[7],0 To aAdvSize[6],aAdvSize[5] PIXEL  //"Inicio da Avaliacao"
        
		@ aObjSize[1,1],aObjSize[1,2] GROUP TO aObjSize[1,3],aObjSize[1,4] LABEL "" OF oDlgCapa PIXEL 
		
		@ aObj1Size[2,1],aObj2Size[1,2] 	SAY OemtoAnsi(STR0005) + Substr(aListBox[nListBox][1],1,30); //"Avaliacao:  "
					OF oDlgCapa PIXEL FONT oFont COLOR CLR_BLUE
		@ aObj1Size[3,1],aObj2Size[1,2]  SAY OemtoAnsi(STR0006) + aListBox[nListBox][3];              //"Duracao: "
					OF oDlgCapa PIXEL FONT oFont COLOR CLR_BLUE		
		@ aObj1Size[4,1],aObj2Size[1,2]  SAY OemtoAnsi(STR0007) + aListBox[nListBox][2];              //"Qtde Questoes:  "
					OF oDlgCapa PIXEL FONT oFont COLOR CLR_BLUE

		oTBrowseButton := TBrowseButton():New( aObjSize[2,1],aObj2Size[2,2],OemtoAnsi(STR0008),oDlgCapa,;
		 {||lRet:=.T.,RspxTeste(aListBox[nListBox][3]),oDlgCapa:End()},75,20,,,.F.,.T.)
		

	ACTIVATE MSDIALOG oDlgCapa VALID lRet CENTERED
	
Next nx

RspxFinal()

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ RspxTeste³ Autor ³ Cristina Ogura        ³ Data ³ 25.08.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao que controla Avaliacoes realizadas.				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RspxTeste()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function RspxTeste(cDuracao)
Local oDlgTeste
Local oScrolMemo
Local oCol
Local oCol2
Local oBtn1
Local oBtn2
Local oBtn3
Local oBtn4
Local lRet		:= .F.
Local cTitulo 	:= OemtoAnsi(STR0005) + aListBox[nListBox][1] //"Avaliacao:  "
Local cTempo	:= aListBox[nListBox][3]
Local bBlock
Local lTimer 	:= .T.  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaração de arrays para dimensionar tela		                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}

Local aAdv1Size		:= {}
Local aInfo1AdvSize	:= {}
Local aObj1Size		:= {}
Local aObj1Coords	:= {} 

Local aAdv11Size	:= {}
Local aInfo11AdvSize:= {}
Local aObj11Size	:= {}
Local aObj11Coords	:= {}  

Local aAdv12Size	:= {}
Local aInfo12AdvSize:= {}
Local aObj12Size	:= {}
Local aObj12Coords	:= {}

Local aAdv2Size		:= {}
Local aInfo2AdvSize	:= {}
Local aObj2Size		:= {}
Local aObj2Coords	:= {}

Local aAdv21Size	:= {}
Local aInfo21AdvSize:= {}
Local aObj21Size	:= {}
Local aObj21Coords	:= {} 

Local aAdv22Size	:= {}
Local aInfo22AdvSize:= {}
Local aObj22Size	:= {}
Local aObj22Coords	:= {}

Local aAdv23Size	:= {}
Local aInfo23AdvSize:= {}
Local aObj23Size	:= {}
Local aObj23Coords	:= {}

Local aGDCoord1		:= {}

Private oTimer, oHora 

If nOpMenu == 2 
	Private oPercen
	Private nPercen	:= 0 
EndIf	

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize		:= MsAdvSize(.F.)
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }					 
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )		//1-Coluna1 - Pergunta Resposta
aAdd( aObjCoords , { 060 , 000 , .F. , .T. } )		//2-Coluna2 - Navegacao
aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords,,.T. )

//Divisao em linhas da Coluna1 - Pergunta Resposta 
aAdv1Size		:= aClone(aObjSize[1])
aInfo1AdvSize	:= { aAdv1Size[2] , aAdv1Size[1] , aAdv1Size[4] , aAdv1Size[3] , 5 , 5 }					 
aAdd( aObj1Coords , { 000 , 090 , .T. , .F. } )		//1-Pergunta
aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )		//2-Resposta
aObj1Size	:= MsObjSize( aInfo1AdvSize , aObj1Coords )   

//Para uso TmultiGet - Pergunta
aAdv11Size		:= aClone(aObj1Size[1])
aInfo11AdvSize	:= { aAdv11Size[2] , aAdv11Size[1] , aAdv11Size[4] , aAdv11Size[3] , 5 , 5 }					 
aAdd( aObj11Coords , { 000 , 000 , .T. , .T. , .T.} )		//2-Resposta
aObj11Size	:= MsObjSize( aInfo11AdvSize , aObj11Coords )

//Para uso TmultiGet - Respost
aAdv12Size		:= aClone(aObj1Size[2])
aInfo12AdvSize	:= { aAdv12Size[2] , aAdv12Size[1] , aAdv12Size[4] , aAdv12Size[3] , 5 , 5 }					 
aAdd( aObj12Coords , { 000 , 000 , .T. , .T. , .T. } )		//2-Resposta
aObj12Size	:= MsObjSize( aInfo12AdvSize , aObj12Coords )

//Divisao em linhas da Coluna2 - Navegacao
aAdv2Size		:= aClone(aObjSize[2])
aInfo2AdvSize	:= { aAdv2Size[2] , aAdv2Size[1] , aAdv2Size[4] , aAdv2Size[3] , 5 , 5 }					 
aAdd( aObj2Coords , { 000 , 090 , .T. , .F. } )		//1-Total Perguntas/Duracao
aAdd( aObj2Coords , { 000 , 000 , .T. , .T. } )		//2-Navegacao
aObj2Size	:= MsObjSize( aInfo2AdvSize , aObj2Coords )

//Divisao em linhas da Linha 1-Total Perguntas/Duracao
aAdv21Size		:= aClone(aObj2Size[1])
aInfo21AdvSize	:= { aAdv21Size[2] , aAdv21Size[1] , aAdv21Size[4] , aAdv21Size[3] , 5 , 5 }					 
aAdd( aObj21Coords , { 000 , 000 , .T. , .T. } )		//1-Total Perguntas
aAdd( aObj21Coords , { 000 , 000 , .T. , .T. } )		//2-Duracao
aAdd( aObj21Coords , { 000 , 000 , .T. , .T. } )		//3-Total Acertos
aObj21Size	:= MsObjSize( aInfo21AdvSize , aObj21Coords )

//Divisao em linhas da Linha 2-Navegacao
aAdv22Size		:= aClone(aObj2Size[2])
aInfo22AdvSize	:= { aAdv22Size[2] , aAdv22Size[1] , aAdv22Size[4] , aAdv22Size[3] , 5 , 5 }					 
aAdd( aObj22Coords , { 000 , 015 , .T. , .F. } )		//1-Bt Proximo-Anterior
aAdd( aObj22Coords , { 000 , 015 , .T. , .F. } )		//2-Pergunta
aAdd( aObj22Coords , { 000 , 015 , .T. , .F. } )		//3-OK
aAdd( aObj22Coords , { 000 , 000 , .T. , .T. } )		//Resto do Espaco	
aObj22Size	:= MsObjSize( aInfo22AdvSize , aObj22Coords )  

//Divisao em Colunas da Linha 1-Bt Proximo-Anterior
aAdv23Size		:= aClone(aObj22Size[1])
aInfo23AdvSize	:= { aAdv23Size[2] , aAdv23Size[1] , aAdv23Size[4] , aAdv23Size[3] , 5 , 5 }					 
aAdd( aObj23Coords , { 000 , 000 , .T. , .T. } )		//1-Bt Anterior
aAdd( aObj23Coords , { 000 , 000 , .T. , .T. } )		//3-Bt Proximo
aObj23Size	:= MsObjSize( aInfo23AdvSize , aObj23Coords,,.T. )

DEFINE FONT oFont   NAME "Arial" SIZE 0,-11 BOLD
DEFINE MSDIALOG oDlgTeste TITLE OemtoAnsi(cTitulo) From aAdvSize[7],0 To aAdvSize[6],aAdvSize[5] PIXEL 

 	DEFINE 	TIMER oTimer	INTERVAL 1000;
			ACTION Iif(!RspxHora(oHora,@cTempo),;
				(Iif(cModulo=="RSP",Rsp130Sair(cTempo),Trm190Sair(cTempo)),;
				lRet:=.T.,oDlgTeste:End()),) OF oDlgTeste

	If cDuracao != "00:00:00"
		lTimer := .T.		
	Else
		lTimer := .F.	
	EndIf
 
	@ aObj1Size[1,1],aObj1Size[1,2] GROUP oGroup TO aObj1Size[1,3],aObj1Size[1,4] LABEL OemtoAnsi(STR0009) OF oDlgTeste PIXEL COLOR CLR_BLACK //" Pergunta "
	oGroup:oFont:= oFont

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caixa de dialogo para Visualizacao da Pergunta (memo).			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	oPerg01:= tMultiget():New(aObj11Size[1,1]+5,aObj11Size[1,2],{|u|if(Pcount()>0,cPergMemo:=u,cPergMemo)}; 
		,oDlgTeste,aObj11Size[1,3],aObj11Size[1,4]-5,,,,,,.T.,,,,,,.T.)

	oPerg01:oFont 		:= oFont 
	oPerg01:bRClicked 	:= {||AllwaysTrue()}

	@ aObj21Size[1,1],aObj21Size[1,2] GROUP oGroup TO aObj21Size[1,3],aObj21Size[1,4] LABEL "" OF oDlgTeste PIXEL COLOR CLR_BLACK
	oGroup:oFont:= oFont

	@ aObj21Size[1,1]+7, aObj21Size[1,2]+5 SAY oSeq VAR cSequenc SIZE 30,7 OF oDlgTeste PIXEL FONT oFont COLOR CLR_BLUE //" de "
		
	@ aObj21Size[2,1],aObj21Size[2,2] GROUP oGroup TO aObj21Size[2,3],aObj21Size[2,4] LABEL OemtoAnsi(STR0011) OF oDlgTeste PIXEL COLOR CLR_BLACK //" Duracao "
	oGroup:oFont:= oFont

	@ aObj21Size[2,1]+10,aObj21Size[2,2]+5 SAY oHora VAR cTempo	SIZE 22,7 OF oDlgTeste PIXEL FONT oFont COLOR CLR_BLUE		
	
    If nOpMenu == 2
		@ aObj21Size[3,1],aObj21Size[3,2] GROUP oGroup TO aObj21Size[3,3],aObj21Size[3,4] LABEL OemtoAnsi(STR0026) OF oDlgTeste PIXEL COLOR CLR_BLACK
   		oGroup:oFont:= oFont
 		@ aObj21Size[3,1]+10,aObj21Size[3,2]+5 GET oPercen VAR nPercen PICTURE "999.99"  WHEN .F. SIZE  15,5 PIXEL OF oGroup 
 	EndIf	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  Alternativas de Multipla escolha - Checkbox.			  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	oCol:= TcColumn():New("")	// 1a Coluna
	oCol:lNoLite	:= .T.
	oCol:bClrFore 	:= {|| CLR_BLUE}
	oCol:bClrBack 	:= {|| CLR_HGRAY}
	oCol:nWidth 	:= 10
	oCol:lBitmap 	:= .T.

	@ aObj1Size[2,1],aObj1Size[2,2] GROUP oGroup TO aObj1Size[2,3],aObj1Size[2,4] LABEL OemtoAnsi(STR0012) OF oDlgTeste PIXEL COLOR CLR_BLACK //" Resposta "
	oGroup:oFont:= oFont

	oBrw13	:= TSBrowse():New(aObj12Size[1,1]+5,aObj12Size[1,2],aObj12Size[1,3],aObj12Size[1,4]-5,oDlgTeste,,16,oFont,1)
	oBrw13:AddColumn(oCol)   
	
	If nOpMenu <> 2
		oBrw13:bLDblClick := {|| RspxClique()} 
	EndIf	
	
	oCol2:= TcColumn():New("")	// 2a Coluna
	oCol2:lNoLite 	:= .T.
	oCol2:bClrFore 	:= {|| CLR_BLUE}
	oCol2:bClrBack 	:= {|| CLR_HGRAY}
	oCol2:nWidth 	:= 999

	oBrw13:AddColumn(oCol2)
	oBrw13:SetArray(aAltern)
	oBrw13:Hide()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ 				Botoes.		 			   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
		@ aObj23Size[2,1]*2,aObj23Size[2,2]*2 	BTNBMP oBtn1 NAME "NEXT"   SIZE 25,25;	//"Proximo"   
			  	ACTION ( RspxGrava(1),;
					   	 RspxPergunta(),;
					     RspxRefresh(),;
					 	 RspxAltern(cTitulo,cTempo,oBtn1, oBtn2, oBtn3, oBtn4, aObj12Size[1], aGdCoord1)),;
					  OF oDlgTeste PIXEL
	oBtn1:cToolTip:= OemtoAnsi(STR0013) //"Proxima questao"
		
  		@ aObj23Size[1,1]*2,aObj23Size[1,2]*2 	BTNBMP oBtn2 NAME "PREV"   SIZE 25,25;	//"Anterior"
				ACTION (RspxGrava(2),;
					  RspxPergunta(),;
					  RspxRefresh(),;
					  RspxAltern(cTitulo,cTempo,oBtn1, oBtn2, oBtn3, oBtn4, aObj12Size[1], aGdCoord1));
					  OF oDlgTeste PIXEL
	oBtn2:cToolTip:= OemtoAnsi(STR0014) //"Questao anterior"
		
		@ aObj22Size[2,1]*2,aObj22Size[2,2]*2 	BTNBMP oBtn3 NAME "S4WB063N"   	SIZE 72,30;	//"Ir Para"
				ACTION (RspxGrava(3),;
				     RspxGo(),;
					 RspxPergunta(),;  
					 RspxRefresh(),;
				  	 RspxAltern(cTitulo,cTempo,oBtn1, oBtn2, oBtn3, oBtn4, aObj12Size[1], aGdCoord1));
					 OF oDlgTeste PIXEL
	oBtn3:cToolTip:= OemtoAnsi(STR0015) //"Ir para uma questao"
	
		@ aObj22Size[3,1]*2,aObj22Size[3,2]*2 	BTNBMP oBtn4 NAME "S4WB018N"	SIZE 72,30;	//"Sair"
				ACTION IF(msgYesNo(OemtoAnsi(STR0016),	OemtoAnsi(STR0017)),; //"Voce deseja realmente sair desta Avaliacao ?"###"Atencao"
						(oTimer:DeActivate(),RspxGrava(3),Iif(cModulo=="RSP",Rsp130Sair(cTempo),Trm190Sair(cTempo)),lRet:= .T.,oDlgTeste:End()),);
						 OF oDlgTeste PIXEL 
	oBtn4:cToolTip:= OemtoAnsi(STR0018) //"Sair da Avaliacao"

ACTIVATE MSDIALOG oDlgTeste VALID lRet ON INIT ( Iif(lTimer,oTimer:Activate(),oTimer:DeActivate()) , RspxAltern(cTitulo,cTempo,oBtn1, oBtn2, oBtn3, oBtn4, aObj12Size[1], aGdCoord1)) CENTERED

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ RspxList ³ Autor ³ Cristina Ogura        ³ Data ³ 25.08.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Preenche o aListBox com os dados da Avaliacao, questao e   ³±±
±±³          ³ duracao da Avaliacao.                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RspxList(ExpC1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ ExpC1 - codigo da Avaliacao                                ³±±
±±³			 ³ ExpN1 - Tipo: 1-Avaliacao  2-Modelo(Gerar Teste aleatorio) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function RspxList(cTeste,nTipo)
Local aSaveArea := GetArea()
Local nCont		:= 0
Local cNomeTeste:= ""
Local cDuracao	:= ""
Local l1Vez		:= .T.
Local aTest		:= {"","",""}
Local nPontos 	:= 0
Local nLimValor	:= Val( Replicate( "9", ( TamSx3("QO_PONTOS")[1] - ( TamSx3("QO_PONTOS")[2] + 1 ) ) ) + "." + Replicate("9",TamSx3("QO_PONTOS")[2]))
Local aQuest		:= {}
Local n			:= 0

If !Empty(cTeste)
	nTipo := If(nTipo == Nil, 1, nTipo)                              

	If nTipo == 1	//Avaliacao
		dbSelectArea("SQQ")
		dbSetOrder(1)
		dbSeek(xFilial("SQQ")+cTeste)
		While !Eof() .And. xFilial("SQQ")+cTeste ==;
							 SQQ->QQ_FILIAL+SQQ->QQ_TESTE
			If l1Vez					 
				cNomeTeste	:= SQQ->QQ_DESCRIC					 
				cDuracao  	:= SQQ->QQ_DURACAO
				l1Vez 		:= .F.
			EndIf	
			Aadd(aQuest,SQQ->QQ_QUESTAO)	
			nCont++					 
			dbSkip()
		EndDo						 
		For n:= 1 to len(aQuest)
			dbSelectArea("SQO") 
			dbSetOrder(1) 
			If dbSeek(xFilial("SQO")+aQuest[n])
				nPontos+= SQO->QO_PONTOS
				If nPontos > nLimValor
					MsgAlert(STR0028+STR0029+cTeste)
					Exit
				EndIf
			EndIf
		Next
		If nPontos > nLimValor
			aTest		:= {"","",""}
		Else
			aTest := {cNomeTeste,STR(nCont),cDuracao}
		EndIf						 

	Else 			//Modelo

		aTest := RspxGera(cTeste)

	EndIf
EndIf
	
RestArea(aSaveArea)

Return aTest

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ RspxPreenche  ³ Autor ³ Cristina Ogura   ³ Data ³ 25.08.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza o arquivo de TRB com os dados da Avaliacao.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RspxPreenche()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nTipo (1-Avaliacao  	2-Modelo)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function RspxPreenche(nTipo)
Local aSaveArea := GetArea()
Local nQtResp 	:= 0
Local cAlias	:= "" 
Local cQuest	:= "" 

// Preencho apenas uma Avaliacao no arquivo

RspDelTRB()		//Apagar TRB, pois em Ctree nao pode utilizar ZAP em arquivo com campo Memo
RspCriaTRB()   	//Recriar arquivo temporario

nSeq:= 1

If nTipo == 1
	cAlias := "SQQ"
	cQuest := "SQQ->QQ_QUESTAO"
Else
	cAlias := "TRC"            
	cQuest := "TRC->TRC_QUESTA"
EndIf

dbSelectArea(cAlias)
dbSetOrder(1)
If dbSeek(xFilial("SQQ")+aListBox[nListBox][4])
	While !Eof() .And. xFilial("SQQ")+aListBox[nListBox][4] ==;
		Iif(nTipo == 1,SQQ->QQ_FILIAL + SQQ->QQ_TESTE, TRC->TRC_FILIAL + TRC->TRC_TESTE)
							 
		// Questoes					 
		dbSelectArea("SQO")
		dbSetOrder(1)
		If dbSeek(xFilial("SQO")+&cQuest)
		
			If Empty( SQO->QO_ESCALA )	//Busca no Cadastro de Alternativas (SQP)
			
				dbSelectArea("SQP")
				dbSetOrder(1)
			 
				// Apuracao de numero maximo de respostas (alternativas)
				nQtResp := 0
				If dbSeek(xFilial("SQP")+&cQuest)
					While !Eof() .And. xFilial("SQP")+&cQuest ==;
										 SQP->QP_FILIAL+SQP->QP_QUESTAO	
						If SQP->QP_PERCENT > 0
							nQtResp ++
						EndIf 
						dbSkip()
					EndDo
	            EndIf                        
            
				If dbSeek(xFilial("SQP")+&cQuest)
					While !Eof() .And. xFilial("SQP")+&cQuest ==;
								 SQP->QP_FILIAL+SQP->QP_QUESTAO	
						RecLock("TRB",.T.)
							TRB->TRB_SEQ 		:= IIf(nTipo == 1,SQQ->QQ_ITEM,	TRC->TRC_ITEM)
							TRB->TRB_TESTE 		:= IIf(nTipo == 1,SQQ->QQ_TESTE,	TRC->TRC_TESTE)
							TRB->TRB_QUESTAO 	:= SQO->QO_QUESTAO
							TRB->TRB_TOPICO  	:= SQO->QO_TOPICO
							TRB->TRB_DQUESTAO	:= SQO->QO_QUEST
							TRB->TRB_ALTERNA 	:= SQP->QP_ALTERNA
							TRB->TRB_DALTERNA 	:= SQP->QP_DESCRIC
							TRB->TRB_PERCENTO 	:= SQP->QP_PERCENT
							TRB->TRB_RESPOSTA 	:= 1
							TRB->TRB_TIPOBJ		:= SQO->QO_TIPOOBJ
							TRB->TRB_QTRESP		:= nQtResp
							TRB->TRB_TIPO		:= IIf(nTipo == 1,SQQ->QQ_TIPO, TRC->TRC_TIPO)						
						MsUnlock()	       
						
						If SQO->QO_TIPOOBJ = "3" // Memo grava apenas um registro
							exit
						EndIf
												
						dbSelectArea("SQP")
						dbSetOrder(1)
						dbSkip()
					EndDo
					
				ElseIf SQO->QO_TIPOOBJ == "3"	//Nao tiver alternativa e tipo = Memo
					RecLock("TRB",.T.)
						TRB->TRB_SEQ 		:= IIf(nTipo == 1,SQQ->QQ_ITEM,	TRC->TRC_ITEM)
						TRB->TRB_TESTE 		:= IIf(nTipo == 1,SQQ->QQ_TESTE,	TRC->TRC_TESTE)
						TRB->TRB_QUESTAO 	:= SQO->QO_QUESTAO
						TRB->TRB_TOPICO   	:= SQO->QO_TOPICO
						TRB->TRB_DQUESTAO 	:= SQO->QO_QUEST
						TRB->TRB_ALTERNA 	:= "00"
						TRB->TRB_DALTERNA 	:= Space(250)
						TRB->TRB_PERCENTO 	:= 0
						TRB->TRB_RESPOSTA 	:= 3                
						TRB->TRB_TIPOBJ		:= SQO->QO_TIPOOBJ
						TRB->TRB_QTRESP		:= 0           
						TRB->TRB_TIPO		:= IIf(nTipo == 1,SQQ->QQ_TIPO, TRC->TRC_TIPO)						
					MsUnlock()		
				EndIf
			Else	// Utilizando Escala (RBK/RBL)
			
				dbSelectArea("RBL") 
				dbSetOrder(1)
			 
				// Apuracao de numero maximo de respostas (alternativas)
				nQtResp := 0
				If dbSeek(xFilial("RBL")+SQO->QO_ESCALA)
					While !Eof() .And. xFilial("RBL")+SQO->QO_ESCALA ==;
										 RBL->RBL_FILIAL+RBL->RBL_ESCALA
						If RBL->RBL_VALOR > 0
							nQtResp ++
						EndIf 
						dbSkip()
					EndDo
	            EndIf                        
            
				If dbSeek(xFilial("RBL")+SQO->QO_ESCALA)
					While !Eof() .And. xFilial("RBL")+SQO->QO_ESCALA ==;
								 RBL->RBL_FILIAL+RBL->RBL_ESCALA	
						RecLock("TRB",.T.)
							TRB->TRB_SEQ 		:= IIf(nTipo == 1,SQQ->QQ_ITEM,	TRC->TRC_ITEM)
							TRB->TRB_TESTE 		:= IIf(nTipo == 1,SQQ->QQ_TESTE,	TRC->TRC_TESTE)
							TRB->TRB_QUESTAO 	:= SQO->QO_QUESTAO
							TRB->TRB_TOPICO  	:= SQO->QO_TOPICO
							TRB->TRB_DQUESTAO	:= SQO->QO_QUEST
							TRB->TRB_ALTERNA 	:= RBL->RBL_ITEM
							TRB->TRB_DALTERNA 	:= RBL->RBL_DESCRI
							TRB->TRB_PERCENTO 	:= RBL->RBL_VALOR
							TRB->TRB_RESPOSTA 	:= 1
							TRB->TRB_TIPOBJ		:= SQO->QO_TIPOOBJ
							TRB->TRB_QTRESP		:= nQtResp
							TRB->TRB_TIPO		:= IIf(nTipo == 1,SQQ->QQ_TIPO, TRC->TRC_TIPO)						
						MsUnlock()	       
						
						If SQO->QO_TIPOOBJ = "3" // Memo grava apenas um registro
							exit
						EndIf
												
						dbSelectArea("RBL") 
						dbSetOrder(1)
						dbSkip()
					EndDo
				Else
					RecLock("TRB",.T.)
						TRB->TRB_SEQ 		:= IIf(nTipo == 1,SQQ->QQ_ITEM,	TRC->TRC_ITEM)
						TRB->TRB_TESTE 		:= IIf(nTipo == 1,SQQ->QQ_TESTE,	TRC->TRC_TESTE)
						TRB->TRB_QUESTAO 	:= SQO->QO_QUESTAO
						TRB->TRB_TOPICO   	:= SQO->QO_TOPICO
						TRB->TRB_DQUESTAO 	:= SQO->QO_QUEST
						TRB->TRB_ALTERNA 	:= "00"
						TRB->TRB_DALTERNA 	:= Space(250)
						TRB->TRB_PERCENTO 	:= 0
						TRB->TRB_RESPOSTA 	:= 3                
						TRB->TRB_TIPOBJ		:= SQO->QO_TIPOOBJ
						TRB->TRB_QTRESP		:= 0           
						TRB->TRB_TIPO		:= IIf(nTipo == 1,SQQ->QQ_TIPO, TRC->TRC_TIPO)						
					MsUnlock()		
				EndIf					
			EndIf
		EndIf
			
		dbSelectArea(cAlias)	
		dbSkip()					 
	EndDo						 
EndIf

RspxPergunta()

RestArea(aSaveArea)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ RspxHora ³ Autor ³ Cristina Ogura        ³ Data ³ 25.08.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao que controla o tempo de duracao da Avaliacao.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RspxHora(ExpO1, ExpC1)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto de controle do tempo                        ³±±
±±³          ³ ExpC1 = Tempo                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function RspxHora(oHora,cTime)

Local lRet		:= .T.
Local cTimeFim	:= ""
Local cTimeDif	:= ""
                
Static cTimeIni 
Static cTimeOld
Static dDataIni

If Pcount() == 0
	cTimeIni := cTimeOld := dDataIni := Nil
Else
	cTimeOld := If(cTimeOld == Nil,cTime, cTimeOld)
	cTimeIni := If(cTimeIni == Nil,Time(),cTimeIni)
	dDataIni := If(dDataIni == Nil,MsDate(),dDataIni) 
	cTimeFim := Time()

	If dDataIni != MsDate() 
		dDataIni := MsDate()
		cTimeIni := cTimeFim
		cTimeOld := cTime
	EndIf
		
	cTimeDif := ElapTime(cTimeIni,cTimeFim)
	
	If cTimeDif >= cTimeOld
		cTime 	:= "00:00:00"
		lRet 	:= .F.
	Else
		cTime 	:= ElapTime(cTimeDif,cTimeOld)
    EndIf
	oHora:Refresh()
	
EndIf              

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ RspxPergunta  ³ Autor ³ Cristina Ogura   ³ Data ³ 25.08.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao que controla a pergunta a ser mostrada na tela      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RspxPergunta()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function RspxPergunta()
Local cTeste		:= aListBox[nListBox][4]
Local aSaveArea 	:= GetArea()
Local cPesq			:= "" 
Local nTamSeq		:= aCampos[AScan(aCampos,{ |x| x[1] == "TRB_SEQ" })][3]
Local cSeq			:= StrZero(nSeq,nTamSeq)

Private cAltern 	:= ""
Private cTipQuest	:= "" 

dbSelectArea("TRB")
dbSetOrder(1)
cPesq := Iif(cModulo == "TRM",Padr(cTeste,4), cTeste)
If dbSeek(cPesq+cSeq)
	cPergMemo := TRB->TRB_DQUESTAO
EndIf	

cSequenc := StrZero(nSeq,nTamSeq)+OemtoAnsi(STR0010)+StrZero(Val(Alltrim(aListBox[nListBox][2])),nTamSeq)

If nOpMenu == 2
	nPercen	 := 0 
EndIf	

cAltern	 := TRB->TRB_ALTERNA 
cTipQuest:= TRB->TRB_TIPOBJ  
		
RestArea(aSaveArea)

Return(cPesq+cSeq)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ RspxAltern ³ Autor ³ Cristina Ogura      ³ Data ³ 25.08.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao que controla as alternativas a ser mostrada na tela ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RspxAltern()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function RspxAltern(cTitulo,cTempo,oBtn1, oBtn2, oBtn3, oBtn4, aGdCoord, aGdCoord1)
Local cTeste	:= aListBox[nListBox][4]
Local nTamSeq		:= aCampos[AScan(aCampos,{ |x| x[1] == "TRB_SEQ" })][3]
Local cSeq			:= StrZero(nSeq,nTamSeq)
Local aSaveArea := GetArea()
Local nLinha 	:= nLinha2 := 1
Local cTipoObj 	:= ""
Local oDlg, oDlgMemo, Obt1
Local cPesq       
Static cObjAnt  



aAltern	:= {} 
aRad	:= {}

dbSelectArea("TRB")
TRB->(dbSetOrderas(1))                                          
cPesq := Iif(cModulo == "TRM",Padr(cTeste,4), cTeste)
If TRB->(dbSeek(cPesq+cSeq))
	While !TRB->(Eof()) .And. cPesq+cSeq == TRB->TRB_TESTE+TRB->TRB_SEQ
		cTipoObj 	:= TRB->TRB_TIPOBJ   
		cObjAnt 	:= Iif(cObjAnt == Nil,cTipoObj, cObjAnt)
			                    
		If cTipoObj == "1"		//Check
			If TRB->TRB_RESPOSTA == 2							// Marcou
				Aadd(aAltern,{oOk, TRB->TRB_DALTERNA})
			ElseIf TRB->TRB_RESPOSTA == 1 						// Nao Marcou
				Aadd(aAltern,{oNO, TRB->TRB_DALTERNA})
			EndIf	
			
		ElseIf cTipoObj == "2" .Or. cTipoObj == "4"	// Radio
			Aadd(aAltern, Alltrim(TRB->TRB_DALTERNA))  
			Aadd(aRad, Iif(TRB->TRB_RESPOSTA == 2, 2, 1))
								
		ElseIf cTipoObj == "3"	// Memo
			Aadd(aAltern,{oNO,TRB->TRB_MEMO}) 
			cMemo := Rtrim(TRB->TRB_MEMO)
		EndIf               

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Determina o maior tamanho de linha para definir padrao para as alternativas. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nLinha2 := 1 + (Int(Len(Alltrim(TRB->TRB_DALTERNA)) / 75))
		If nLinha2 > nLinha
			nLinha := nLinha2
		EndIf
		
		TRB->(dbSkip())
	EndDo	
EndIf

If cObjAnt == "1" 		// Objeto anterior = Check
	Iif(oBrw13:lVisible,oBrw13:Hide(),)
	
ElseIf cObjAnt == "2" .Or. cObjAnt == "4"	// Objeto anterior = Radio
	Iif(oRadio != Nil, Iif(oRadio:lVisible,oRadio:Hide(),),)
	Iif(oScroll != Nil, Iif(oScroll:lVisible,oScroll:Hide(),),)

	If oRadio != Nil
		Release Objects oRadio                                    
	EndIf
	If oScroll != Nil
		Release Objects oScroll
	EndIf

ElseIf cObjAnt == "3" 	// Objeto anterior = Memo
	Iif(oScroll != Nil, Iif(oScroll:lVisible,oScroll:Hide(),),)
	
	If oScroll != Nil
		Release Objects oScroll
	EndIf
	
EndIf              

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza objetos atuais ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpMenu == 2
	oPercen:bWhen:={|| .F.}
	oPercen:Refresh()
EndIf	   

If cTipoObj == "1"	// Check 

	If nOpMenu == 2
		nPercen:=RspUpdPercen(cTipoObj,aAltern,cPesq+cSeq)
		oPercen:Refresh()
	EndIf	

	oBrw13:SetArray(aAltern)
	oBrw13:nFreeze := 1   
	oBrw13:nLinhas := nLinha		 
	oBrw13:Show() 
	
	If nOpMenu == 2  
		oBrw13:bLDblClick := {|| RspxClique(), nPercen:=RspUpdPercen(cTipoObj,aAltern,cPesq+cSeq),oPercen:Refresh()} 
	EndIf	 
	
	oBrw13:Refresh()

ElseIf cTipoObj == "2" .Or. cTipoObj == "4"	// Radio

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ O objeto oRadio esta sendo recriado a cada vez que e' exibido devido nao ³
	//³ atualizar o seu conteudo .												 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Janela tipo Radio - 1 alternativa correta. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	
	nRadio 	:= Ascan(aRad, {|x| x == 2})    
	   
	If nOpMenu == 2
    	nPercen:=RspUpdPercen(cTipoObj,nRadio,cPesq+cSeq)
    	oPercen:Refresh()
    EndIf	  
    
	bBlock 	:= { |x| If(ValType(x)=='U', nRadio , nRadio := x ) } 
 	oRadio 	:= TRadMenu():New( aGdCoord[1]+5,aGdCoord[2], aAltern, bBlock, oScroll,,,,,,,,aGdCoord[3],aGdCoord[4]-5,,,,.T.) 

 	If nOpMenu == 2
		oRadio	:bChange := {|| nPercen:=RspUpdPercen(cTipoObj,oRadio:nOption,cPesq+cSeq),oPercen:Refresh()}
	EndIf	
	
	nRadio 	:= oRadio:nOption
	oRadio	:oFont:= oFont
    oRadio	:Show()   
	
ElseIf cTipoObj == "3"	// Memo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caixa de dialogo para Visualizacao (memo).						 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpMenu == 2
		nPercen:=RspUpdPercen(cTipoObj,00,cPesq+cSeq)
		oPercen:bWhen:={|| .T.}
		oPercen:Refresh()
	EndIf	

	If oMemo == Nil
		oMemo:= tMultiget():New(aGdCoord[1]+5,aGdCoord[2],{|u|if(Pcount()>0,cMemo:=u,cMemo)}; 
			,oDlg,aGdCoord[3],aGdCoord[4]-5,,,,,,.T.,,,,,,.F.)

		oMemo:oFont 	:= oFont 
		oMemo:bRClicked	:= {||AllwaysTrue()}
	else
		oMemo:lActive := .T.
		oMemo:lVisible:= .T.
		oMemo:Refresh()
	EndIf
EndIf

RestArea(aSaveArea)

cObjAnt := cTipoObj
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ RspxGrava³ Autor ³ Cristina Ogura        ³ Data ³ 25.08.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava no TRB a resposta selecionada e controla as perguntas³±±
±±³          ³ da Avaliacao.                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RspxGrava(ExpN1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 := controla o botao pressionado                      ³±±
±±³          ³ 1 - Proximo                                                ³±±
±±³          ³ 2 - Anterior                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function RspxGrava(nAnda)
Local aSaveArea := GetArea()
Local cTeste	:= aListBox[nListBox][4]
Local nTamSeq		:= aCampos[AScan(aCampos,{ |x| x[1] == "TRB_SEQ" })][3]
Local cSeq			:= StrZero(nSeq,nTamSeq)
Local nTipo		:= 0
Local nCont		:= 0    
Local cPesq		:= ""

If oMemo != Nil                        
	oMemo:lActive := .F.
	oMemo:lVisible:= .F.
EndIf

dbSelectArea("TRB")
TRB->(dbSetOrder(1))
cPesq := Iif(cModulo == "TRM",Padr(cTeste,4), cTeste)
If TRB->(dbSeek(cPesq+cSeq))
	While !TRB->(Eof()) .And. cPesq+cSeq ==;
					 TRB->(TRB_TESTE+TRB_SEQ)

		nCont++        
		
        If TRB->TRB_TIPOBJ == "1"
		    nTipo := Iif(aAltern[nCont][1] == oOk, 2, 1)
		
        ElseIf TRB->TRB_TIPOBJ == "2" .Or. TRB->TRB_TIPOBJ == "4"
        	nTipo := Iif(nCont == nRadio, 2, 1)

        ElseIf TRB->TRB_TIPOBJ == "3"
			nTipo := 3 
		EndIf	

		If RecLock("TRB",.F.)
			TRB->TRB_RESPOSTA := nTipo			// Marcado   
			
			If TRB->TRB_TIPOBJ == "3"
 				TRB->TRB_MEMO := cMemo
				cMemo := ""   
 				If nOpMenu == 2
 					TRB->TRB_PERCENTO := nPercen  
 				EndIf	
 			EndIf
		
			TRB->(MsUnlock())
		EndIf	
		TRB->(dbSkip())
	EndDo
	nRadio := 0
EndIf

nSeqAnt := nSeq
If nAnda == 1		// Proximo
	nSeq++
	If nSeq > Val(aListBox[nListBox][2])
		Help("",1,"RspxUltima")					// Ultima questao
		nSeq--
	EndIf
ElseIf nAnda == 2	// Anterior
	nSeq--
	If nSeq <= 0
		Help("",1,"RspxPrimei")				// Primeira questao
		nSeq++
	EndIf
EndIf 
	
RestArea(aSaveArea)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ RspxGo   ³ Autor ³ Cristina Ogura        ³ Data ³ 25.08.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao que controla para qual pergunta candidato deseja ir ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RspxGo()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function RspxGo()
Local oDlgGo
Local oFont
Local cPergunta	:= Space(03)
Local nOpca		:= 0
Local lRet		:= .F.
Local bSet15
Local bSet24

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaração de arrays para dimensionar tela	                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}

Local aAdv1Size		:= {}
Local aInfo1AdvSize	:= {}
Local aObj1Size		:= {}
Local aObj1Coords	:= {}

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

aAdvSize		:= MsAdvSize(,.T.,100)
aAdvSize[3]		:= aAdvSize[3]*0.6		//Coluna Final Area Trabalho
aAdvSize[5]		:= aAdvSize[5]*0.6		//Coluna Final Dialogo
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }					 
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )   
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )   
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )   
aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )

aAdv1Size		:= aClone(aObjSize[2])
aInfo1AdvSize	:= { aAdv1Size[2] , aAdv1Size[1] , aAdv1Size[4] , aAdv1Size[3] , 5 , 5 }					 
aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )   
aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )   
aAdd( aObj1Coords , { 040 , 000 , .F. , .T. } )   
aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )   
aObj1Size	:= MsObjSize( aInfo1AdvSize , aObj1Coords,,.T. )

DEFINE FONT oFont 	NAME "Arial" SIZE 0,-11 BOLD
DEFINE MSDIALOG oDlgGo TITLE "" From aAdvSize[7],0 To aAdvSize[6],aAdvSize[5] PIXEL
    bSet15 := {|| lRet:= .T.,nOpca:=1,oDlgGo:End()}
    bSet24 := {|| lRet:= .T.,oDlgGo:End()}

	@ aObjSize[1,1],aObjSize[1,2] GROUP TO aObjSize[3,3],aObjSize[3,4] LABEL "" OF oDlgGo PIXEL     
	@ aObj1Size[2,1],aObj1Size[2,2] SAY OemtoAnsi(STR0019)  	OF oDlgGo PIXEL FONT oFont COLOR CLR_BLUE //"Ir para: "
	@ aObj1Size[3,1],aObj1Size[3,2] MSGET cPergunta PICTURE "999";
									VALID RspxIr(cPergunta);
									SIZE 20,10 OF oDlgGo PIXEL 
   
ACTIVATE MSDIALOG oDlgGo ON INIT EnchoiceBar( oDlgGo , bSet15 , bSet24 , Nil , Nil ) CENTERED  

If nOpca == 1			//Confirma
	nSeq	:= Val(cPergunta)	  
EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ RspxIr   ³ Autor ³ Cristina Ogura        ³ Data ³ 25.08.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica a pergunta digitada pelo candidato                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RSPXIR	                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function RspxIr(cPerg)

If (Val(cPerg) <= 0) .Or. (Val(cPerg) > Val(aListBox[nListBox][2]))
	Help("",1,"RspxPerg")		// Pergunta esta vazio ou quantidade de questoes nao existe.
	Return .F.
EndIf	

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ RspxRefresh ³ Autor ³ Cristina Ogura     ³ Data ³ 25.08.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Refresh nos objetos da dialog                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RspxRefresh(ExpO1,ExpO2,ExpO3,ExpO4,ExpO5,ExpO6)           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 := Objeto de controle da pergunta                    ³±±
±±³          ³ ExpO2 := Objeto de controle da pergunta                    ³±±
±±³          ³ ExpO3 := Objeto de controle da pergunta                    ³±±
±±³          ³ ExpO4 := Objeto de controle do nr da pergunta              ³±±
±±³          ³ ExpO5 := Objeto de controle do total da pergunta           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function RspxRefresh()

oPerg01:Refresh()
oSeq:Refresh()
oHora:Refresh()

If nOpMenu == 2
	oPercen:Refresh()
EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ RspxClique ³ Autor ³ Cristina Ogura      ³ Data ³ 26.10.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Clique nas alternativas para marcar/desmarcar              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RspxClique()		                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 							                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function RspxClique()  
Local nQtResp 	:= 0
Local cTeste	:= aListBox[nListBox][4]
Local nTamSeq		:= aCampos[AScan(aCampos,{ |x| x[1] == "TRB_SEQ" })][3]
Local cSeq			:= StrZero(nSeq,nTamSeq)
Local cPesq		:= ""

            
cPesq := Iif(cModulo == "TRM",Padr(cTeste,4), cTeste)
dbSelectArea("TRB")
dbSetOrder(1)
dbSeek(cPesq+cSeq)

If aAltern[oBrw13:nAt][1] == oOK
	aAltern[oBrw13:nAt][1] := oNo
Else     
	Aeval(aAltern,{|x| If(x[1] == oOk ,nQtResp++,) })                
	
	If nQtResp >= TRB->TRB_QTRESP
		Aviso("Aviso","Ultrapassou o Numero maximo de Respostas",{"Ok"})
	Else
		aAltern[oBrw13:nAt][1] := oOk
	EndIf	
EndIf
oBrw13:Refresh()

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ RspxFinal³ Autor ³ Cristina Ogura        ³ Data ³ 26.10.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calculando o tempo que levou para executar a Avaliacao.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RspxFinal()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico		                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function RspxFinal()
Local oFont, oDlg, oLbx, oBtn1
Local cVar	:= ""
Local i		:= ""
Local lRet	:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaração de arrays para dimensionar tela		                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {} 

Local aAdv1Size		:= {}
Local aInfo1AdvSize	:= {}
Local aObj1Size		:= {}
Local aObj1Coords	:= {}

aAdvSize		:= MsAdvSize(.F.,.T.,380)
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }					 
aAdd( aObjCoords , { 000 , 000 , .T. , .T. , .T. } )   
aAdd( aObjCoords , { 000 , 030 , .T. , .F. } )   
aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )

aAdv1Size		:= aClone(aObjSize[2])
aInfo1AdvSize	:= { aAdv1Size[2] , aAdv1Size[1] , aAdv1Size[4] , aAdv1Size[3] , 5 , 5 }					 
aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )	
aAdd( aObj1Coords , { 095 , 000 , .F. , .T. } )	
aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )   
aObj1Size	:= MsObjSize( aInfo1AdvSize , aObj1Coords,,.T. )

For i:=1 To Len(aFinal)
	aFinal[i][4] := RspxCalcTemp(aFinal[i][3], aFinal[i][4])
Next i

DEFINE FONT oFont 	NAME "Arial Negrito" SIZE 0,-11
DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0020) From aAdvSize[7], 0 To aAdvSize[6], aAdvSize[5] OF oMainWnd PIXEL//"Resultado da Avaliacao"

	@ aObjSize[1,1],aObjSize[1,2] LISTBOX oLbx VAR cVar ;
			  FIELDS HEADERS 	OemtoAnsi(STR0001),;          	//"Avaliacao"
								OemtoAnsi(STR0002),;           //"Qtde Questoes"
								OemtoAnsi(STR0021),;           //"Qtde Resolvida"
								OemtoAnsi(STR0003),;           //"Duracao"
								OemtoAnsi(STR0022) SIZE aObjSize[1,3],aObjSize[1,4] PIXEL//"Tempo realizado"
	oLbx:SetArray(aFinal)
	oLbx:bLine := { || {aFinal[oLbx:nAt,1],aFinal[oLbx:nAt,2],aFinal[oLbx:nAt,5],aFinal[oLbx:nAt,3],aFinal[oLbx:nAt,4]}}
			 
	oBtn1 := TBrowseButton():New( aObj1Size[2,1],aObj1Size[2,2],OemtoAnsi(STR0023),oDlg,;
			{||lRet:=.T.,oDlg:End()},95,20,,,.F.,.T.)				 

ACTIVATE MSDIALOG oDlg VALID lRet CENTERED

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ RspxCalcTemp  ³ Autor ³ Cristina Ogura   ³ Data ³ 26.10.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calcula o tempo de intervalo entre dois tempos             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RspxCalcTemp(ExpC1,ExpC2)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 := Tempo Inicial                                     ³±±
±±³          ³ ExpC2 := Tempo Final                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function RspxCalcTemp(cIni, cFim)

Local nTempo	:= 0
Local nTempo1	:= 0
Local nTempo2	:= 0
Local nHora		:= 0
Local nMin		:= 0
Local nSeg		:= 0

nTempo1:= (Val(Substr(cIni,1,2)) * 3600) +;		
			 (Val(Substr(cIni,4,2)) * 60) +;			
			  Val(Substr(cIni,7,2)) 
				  
nTempo2:= (Val(Substr(cFim,1,2)) * 3600) +;			
			 (Val(Substr(cFim,4,2)) * 60) +;
			  Val(Substr(cFim,7,2))
				 
nTempo	:= nTempo1 - nTempo2			 
nHora 	:= Int(nTempo/3600)
nMin	:= Int(Mod(nTempo,3600)/60)			 
nSeg	:= Int(Mod(Mod(nTempo,3600),60))			 
	
Return ( StrZero(nHora,2)+":"+StrZero(nMin,2)+":"+StrZero(nSeg,2) )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ RspxGera  ³ Autor ³ Emerson Grassi Rocha ³ Data ³ 29/06/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera modelos de Avaliac. que sera executado pelo candidato.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RS200Gera(ExpC1,ExpN1,ExpN2)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RspxGera(cCod)

Local cTeste	:= cCod
Local cItem		:= "00"
Local cQuestao	:= ""
Local nItem		:= 0
Local nQuest	:= 0
Local nMaximo	:= 0
Local nAleat	:= 0
Local nx		:= 0
Local nz		:= 0
Local aQuest	:= {}
Local aQueAleat	:= {}
Local aQueAtu	:= {}
Local lGrava	:= .F.
Local aRet 		:= {}
Local cNomeTest := ""
Local cDuracao	:= ""

dbSelectArea("SQW")
dbSetOrder(1)
If dbSeek(xFilial("SQW")+cCod)
	While !Eof() .And. (xFilial("SQW")+cCod) == (xFilial("SQW")+SQW->QW_MODELO)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica quantidade de Questoes de acordo com as especificacoes do Modelo. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuestao  	:= ""
		nMaximo 	:= 0
		nAleat    	:= 0
		nx        	:= 0
		nQuest 		:= 0
		aQuest 		:= {}
		aQueAtu 	:= {}
		aQueAleat 	:= {}
		cNomeTest	:= SQW->QW_DESCRIC
		cDuracao	:= SQW->QW_DURACAO
		
		dbSelectArea("SQO")
		dbSetOrder(2)
		dbSeek(xFilial("SQO")+SQW->QW_TIPO+SQW->QW_AREA+SQW->QW_TOPICO )
		While xFilial("SQO")+SQW->QW_TIPO+SQW->QW_AREA+SQW->QW_TOPICO  ==;
			xFilial("SQO")+SQO->QO_TIPO+SQO->QO_AREA+SQO->QO_TOPICO
			If SQO->QO_NIVEL >= SQW->QW_NIVELDE  .And. SQO->QO_NIVEL <= SQW->QW_NIVELAT
				Aadd(aQuest,Val(QO_QUESTAO))
				nQuest++
			EndIf
			dbSkip()
		EndDo
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se no arquivo tiver mais questoes que o solicitado, busca aleatoriamente.  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		dbSelectArea("SQW")
		If nQuest > SQW->QW_FREQ
			aQueAleat 	:= {}
			For nx := 1 to QW_FREQ
				While .T.
                                       
					nAleat := Int(TrmAleat(nQuest))
					If nAleat > 0 .And. Ascan(aQueAleat,{|x| x == nAleat }) == 0
						Aadd(aQueAleat,nAleat)
						Exit
					EndIf
				EndDo
			Next nx
			
			For nx := 1 to Len(aQueAleat)
				Aadd(aQueAtu,aQuest[aQueAleat[nx]])
			Next nx
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se no arquivo nao tiver questoes suficientes, utiliza apenas as existentes.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Else
			aQueAtu := Aclone(aQuest)
		EndIf
		
		For nx := 1 to Len(aQueAtu)
			
			nItem++
			cItem 	:= StrZero(nItem,2)
			cQuestao:= StrZero(aQueAtu[nx],3)
			
			RecLock("TRC",.T.,.T.)
				TRC->TRC_FILIAL	:= xFilial("SQQ")
				TRC->TRC_TESTE	:= cTeste
				TRC->TRC_DESCRI	:= cNomeTest
				TRC->TRC_ITEM	:= cItem
				TRC->TRC_QUESTA	:= cQuestao
				TRC->TRC_AREA	:= SQW->QW_AREA
				TRC->TRC_TOPICO	:= SQW->QW_TOPICO
				TRC->TRC_DURACA	:= cDuracao
				TRC->TRC_TIPO	:= SQW->QW_TIPO
			MsUnlock()
			
			lGrava := .T.
		Next nx
		
		dbSelectArea("SQW")
		dbSkip()
	EndDo
	
	aRet := {cNomeTest,STR(nItem),cDuracao}
Else
	aRet := {"","",""}
EndIf
Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ RspCriaTRB    ³ Autor ³Emerson Grassi    ³ Data ³ 14/05/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cria arquivo TRB									          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RspCriaTRB()		                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function RspCriaTRB()
Local aLsta := {"TRB_TESTE","TRB_SEQ"}
Local aLsIndices := {}

AAdd( aLsIndices, aLsta)

oTmpTRB := RhCriaTrab("TRB", aCampos, aLsIndices)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ RspDelTRB	 ³ Autor ³Emerson Grassi    ³ Data ³ 14/05/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Apaga arquivo TRB								          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RspDelTRB()		                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function RspDelTRB()

dbSelectArea("TRB")
dbCloseArea()

If oTmpTRB <> Nil
	oTmpTRB:Delete()
	Freeobj(oTmpTRB)
EndIf       
 
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Rsp130Sair³ Autor ³ Cristina Ogura        ³ Data ³ 25.08.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza os dados do SQR quando sair do teste              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Rsp130Sair()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA130  - Chamado pelo programa RSPXTEST.PRW              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Rsp130Sair(cTempo)

Local aSaveArea := GetArea()
Local nQtde		:= 0
Local cChave	:= ""
Local l1Vez		:= .T.
Local cDifer	:= ""
Local nPontos	:= 0
Local cVaga		:= ""

// Atualiza a Agenda como teste feito
dbSelectArea("SQD")
dbSetOrder(2)
If dbSeek(xFilial("SQD")+cCurric)
	While !Eof() .And. xFilial("SQD")+cCurric ==;
							 SQD->QD_FILIAL+SQD->QD_CURRIC
		If SQD->QD_OK # "S" .And.;
		   DtoS(dDataBase) == DtoS(SQD->QD_DATA) .And.;
			aListBox[nListBox][4] == SQD->QD_TESTE
			RecLock("SQD",.F.)
				SQD->QD_OK	:= "S"
			MsUnlock()	

			cVaga := QD_VAGA

			Exit
		EndIf	
		dbSkip()
	EndDo	
EndIf

// Apagar todos os dados dos teste 
dbSelectArea("SQR")
dbSetOrder1(1)
If dbSeek(xFilial("SQR")+cCurric+aListBox[nListBox][4])
	While !Eof() .And. xFilial("SQR")+cCurric+aListBox[nListBox][4] ==;
							 SQR->QR_FILIAL+SQR->QR_CURRIC+SQR->QR_TESTE
	    
		If ( SQR->QR_DATA == dDataBase ) //Apaga apenas se o teste for realizado na mesma data.
									 
			RecLock("SQR",.F.)
				DbDelete()									 
			MsUnlock()

			MSMM(QR_MRESPOS,,,,2,,,,,"RDY")			
				
		EndIf
		
		dbSkip()					 
	EndDo						 	
EndIf

cDifer := RspxCalcTemp(aFinal[nListBox][3], cTempo)

// Atualiza os dados do curriculo com o teste feito pelo candidato
dbSelectArea("TRB")
dbGotop()
While !Eof()

	If TRB->TRB_RESPOSTA == 2 .Or.;
		TRB->TRB_RESPOSTA == 3				// Marcado ou Memo	
		dbSelectArea("SQR")
		dbSetOrder(1)
		If !dbSeek(xFilial("SQR") + cCurric+aListBox[nListBox][4] + TRB->TRB_QUESTAO + TRB->TRB_ALTERNA)
			RecLock("SQR",.T.)
				SQR->QR_FILIAL 	:= xFilial("SQR")
				SQR->QR_CURRIC	:= cCurric
				SQR->QR_TESTE	:= TRB->TRB_TESTE
				SQR->QR_QUESTAO	:= TRB->TRB_QUESTAO
				SQR->QR_ALTERNA	:= TRB->TRB_ALTERNA	
				SQR->QR_TOPICO	:= TRB->TRB_TOPICO
				SQR->QR_RESULTA	:= TRB->TRB_PERCENTO
				SQR->QR_DURACAO := cDifer
           		SQR->QR_VAGA := cVaga
				SQR->QR_DATA := dDataBase             
			MsUnlock()
			
			If TRB->TRB_TIPOBJ == "3"			// Campo Memo
				MSMM(QR_MRESPOS,,, TRB->TRB_MEMO, 1,,, "SQR", "QR_MRESPOS", "RDY")		

				RecLock("SQR",.F.)
					SQR->QR_RESULTA	:= 0.00
				MsUnlock()
			EndIf	
			
			// Soma Pontos do Teste
			If SQR->QR_RESULTA > 0
				dbSelectArea("SQO")
				dbSetOrder(1)
				If dbSeek(cFilial+SQR->QR_QUESTAO)
					nPontos+= ((SQO->QO_PONTOS * SQR->QR_RESULTA) / 100)
				EndIf
			EndIf          

		EndIf
		
		// Chave para verificar as qtde de questoes feitas pelo candidato
		// Curric+Teste+Questoes
		If l1Vez
			cChave:=cCurric+TRB->TRB_TESTE+TRB->TRB_QUESTAO
			l1Vez:= .F.
			nQtde++
		EndIf
		
		If cChave # cCurric+TRB->TRB_TESTE+TRB->TRB_QUESTAO
			nQtde++
			cChave:=cCurric+TRB->TRB_TESTE+TRB->TRB_QUESTAO
		EndIf
	EndIf
	dbSelectArea("TRB")
	dbSkip()
EndDo            

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava Nota do Teste no Curriculo. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SQG")
dbSetOrder(1)
RecLock("SQG",.F.)
SQG->QG_NOTA	:= nPontos  
SQG->QG_DTTESTE	:= dDataBase 
MsUnlock()

aFinal[nListBox][4] := cTempo
aFinal[nListBox][5] := Str(nQtde)

RestArea(aSaveArea)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Trm190Sair³ Autor ³ Cristina Ogura        ³ Data ³ 25.08.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza os dados do RAI quando sair da Avaliacao.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Trm190Sair()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Trma190 - Chamado pelo programa RSPXTEST.PRW               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Trm190Sair(cTempo)

Local aSaveArea := GetArea()
Local nQtde		:= 0
Local cChave	:= ""
Local l1Vez		:= .T.
Local cDifer	:= "" 
Local cTipo		:= ""
Local lOk		:= .F.
Local nPontos	:= 0 
Local nEficac	:= 0
Local cFil		:= ""  
Local cCargo	:= ""
Local cCC		:= Space(9)

// Atualiza a Agenda como Avaliacao Realizada
dbSelectArea("RAJ")
dbSetOrder(1)
If dbSeek(xFilial("RAJ")+cCalend+cCurso+cTurma+cMat)
	While !Eof() .And. xFilial("RAJ")+cCalend+cCurso+cTurma+cMat ==;
				 RAJ->RAJ_FILIAL+RAJ->RAJ_CALEND+RAJ->RAJ_CURSO+RAJ->RAJ_TURMA+RAJ->RAJ_MAT
				 
		If nOpMenu == 1 .And. iIf(!Empty(RAJ->RAJ_DATAF),(DtoS(dDataBase) < DtoS(RAJ->RAJ_DATA) .Or.  DtoS(dDataBase) > DtoS(RAJ->RAJ_DATAF)),DtoS(dDataBase) < DtoS(RAJ->RAJ_DATA))	
			dbSkip()
			Loop
		EndIf
		
		If RAJ->RAJ_OK # "S" .And.	aListBox[nListBox][4] == If(Empty(RAJ->RAJ_TESTE), RAJ->RAJ_MODELO, RAJ->RAJ_TESTE)
			
			RecLock("RAJ",.F.)
				RAJ->RAJ_OK	:= "S"
			MsUnlock()	
			Exit
		EndIf	
		dbSkip()
	EndDo	
EndIf
    
// Grava status de Avaliacao Eficacia no Calendario
If aListBox[nListBox][5] == 1 

	dbSelectArea("SQQ")
	dbSetOrder(1)
	dbSeek(xFilial("SQQ")+aListBox[nListBox][4]) 
	cTipo := SQQ->QQ_TIPO
Else	

	dbSelectArea("SQW")
	dbSetOrder(1)	
	dbSeek(xFilial("SQW")+aListBox[nListBox][4])
	cTipo := SQW->QW_TIPO
Endif
	
If cTipo == "EFI"
         
	dbSelectArea("RAJ") 
	dbSetOrder(1)
	dbSeek(xFilial("RAJ")+cCalend+cCurso+cTurma)
	While !Eof() .And. cCalend+cCurso+cTurma == ;
						RAJ->RAJ_CALEND+RAJ->RAJ_CURSO+RAJ->RAJ_TURMA

	  	If aListBox[nListBox][5] == 1 
	  		If TrmDesc("SQQ",RAJ->RAJ_TESTE,"QQ_TIPO") != "EFI"
		  		dbSkip()
		  		Loop
		  	EndIf
	  	Else
			If TrmDesc("SQW",RAJ->RAJ_MODELO,"QW_TIPO") != "EFI"
		  		dbSkip()
		  		Loop
		  	EndIf	  	
	  	EndIf
	  	        
		If RAJ->RAJ_OK == "S"
			lOk := .T.
		Else
			lOk := .F.
			Exit			
		EndIf
	
		dbSkip()
	EndDo    
	If lOk 
	
		dbSelectArea("RA2")
		dbSetOrder(1)
		If dbSeek(xFilial("RA2")+cCalend+cCurso+cTurma)
			RecLock("RA2",.F.)
				RA2->RA2_EFICAC	:= "A" 	//Avaliado
			MsUnlock()	
		EndIf
	EndIf
EndIf
	
// Apagar todos os dados das Avaliacoes
dbSelectArea("RAI")
dbSetOrder1(1)
If dbSeek(xFilial("RAI")+cCalend+cCurso+cTurma+cMat+Padr(aListBox[nListBox][4],4))
	While !Eof() .And. xFilial("RAI")+cCalend+cCurso+cTurma+cMat+Padr(aListBox[nListBox][4],4) ==;
				 RAI->RAI_FILIAL+RAI->RAI_CALEND+RAI->RAI_CURSO+RAI->RAI_TURMA+RAI->RAI_MAT+RAI->RAI_TESTE
							 
		RecLock("RAI",.F.,.T.)
			DbDelete()									 
		MsUnlock()
		MSMM(RAI_MRESPO,,,,2,,,,,"RDY")
				
		dbSkip()					 
	EndDo						 	
EndIf

cDifer := RspxCalcTemp(aFinal[nListBox][3], cTempo)

// Atualiza os dados da Avaliacao Realizada.
dbSelectArea("TRB")
dbGotop()
While !Eof()

	If TRB->TRB_RESPOSTA == 2 .Or.	TRB->TRB_RESPOSTA == 3		// Marcado ou Memo	
		dbSelectArea("RAI")
		dbSetOrder(1)
		If	!dbSeek(xFilial("RAI")+cCalend+cCurso+cTurma+cMat+Padr(aListBox[nListBox][4],4)+TRB->TRB_QUESTAO+TRB->TRB_ALTERNA)
			RecLock("RAI",.T.)
				RAI->RAI_FILIAL := xFilial("RAI")
				RAI->RAI_CALEND	:= cCalend
				RAI->RAI_CURSO	:= cCurso
				RAI->RAI_TURMA	:= cTurma
				RAI->RAI_MAT	:= cMat
				RAI->RAI_TESTE	:= TRB->TRB_TESTE
				RAI->RAI_QUESTA	:= TRB->TRB_QUESTAO
				RAI->RAI_ALTERN	:= TRB->TRB_ALTERNA	
				RAI->RAI_RESULT	:= TRB->TRB_PERCENTO
				RAI->RAI_DURACA	:= cDifer
				RAI->RAI_TIPO	:= TRB->TRB_TIPO
				RAI->RAI_QUEM	:= Iif(nOpMenu == 1, "1","2")
				RAI->RAI_MATAVA	:= cMatAva
			MsUnlock()
			If TRB->TRB_TIPOBJ == "3"			// Campo Memo
				MSMM(RAI_MRESPO,,,TRB->TRB_MEMO,1,,,"RAI","RAI_MRESPO","RDY")		
				RecLock("RAI",.F.)     
				
					If nOpMenu <> 2
						RAI->RAI_RESULT	:= 0.00    
					Else	
						RAI->RAI_RESULT	:= TRB->TRB_PERCENTO
					EndIf	   
					
				MsUnlock()
			EndIf	
		EndIf

		// Soma Pontos do Teste
		If cTipo == "EFI"
			If RAI->RAI_RESULT > 0
			
				dbSelectArea("SQO")
				dbSetOrder(1)
				If dbSeek(cFilial+RAI->RAI_QUESTA)
					nPontos += ((SQO->QO_PONTOS * RAI->RAI_RESULT) / 100)
				EndIf
			EndIf          
		EndIf
			
		// Chave para verificar as qtde de questoes feitas pelo candidato
		// Matricula+Avaliacao+Questoes
		If l1Vez
			cChave:=cCalend+cMat+TRB->TRB_TESTE+TRB->TRB_QUESTAO
			l1Vez:= .F.
			nQtde++
		EndIf
		
		If cChave # cCalend+cMat+TRB->TRB_TESTE+TRB->TRB_QUESTAO
			nQtde++
			cChave:=cCalend+cMat+TRB->TRB_TESTE+TRB->TRB_QUESTAO
		EndIf
	EndIf
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ 		Ponto de Entrada Apos Gravacao do Cargo 				  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Este ponto de Entrada sera executado apos a gravacao de cada	  ³
	//³ registro do RAI com base no arquivo temporario TRB.				  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF ExistBlock("TR190DG")
		ExecBlock("TR190DG",.F.,.F.)
	EndIF

	dbSelectArea("TRB")
	dbSkip()
EndDo
         
// Grava Pontuacao de Eficacia no Curso do Funcionario   
If nPontos > 0
    
    dbSelectArea("SRA")
    dbSetOrder(1)
    dbSeek(xFilial("SRA")+cMat)
    cCargo 	:= fGetCargo(SRA->RA_MAT)	
	cCC		:= SRA->RA_CC
		              
	dbSelectArea("SQ3")
	dbSetOrder(1)
	cFil := xFilial("SQ3", RAI->RAI_FILIAL)	
	If dbSeek(cFil+cCargo+cCC)
		cChave 	:= cCargo+cCC 
	Else
		cChave	:= cCargo+Space(TamSX3("RA_CC")[1])
	EndIf
		              
	dbSelectArea("RA5")
	dbSetOrder(2)   
	cFil 	:= xFilial("RA5", RAI->RAI_FILIAL)	
	nEficac	:= 0
	
	If dbSeek(cFil+cChave)
		nEficac := RA5->RA5_EFICAC
	EndIf

	cEficac	:= Iif(nPontos >= nEficac, "1", "2")	// Sim/Nao
			
	dbSelectArea("RA4")
	dbSetOrder(3)
	If dbSeek(xFilial("RA4")+cCalend+cCurso+cTurma+cMat)
		RecLock("RA4",.F.)
			RA4->RA4_EFICAC	:= nPontos 
			RA4->RA4_EFICSN	:= cEficac
		MsUnlock()
	EndIf   
	     
	dbSelectArea("RA4")
	dbSetOrder(1)
EndIf

aFinal[nListBox][4] := cTempo
aFinal[nListBox][5] := Str(nQtde)

RestArea(aSaveArea)

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³RspUpdPercen³ Autor ³ Eduardo Ju          ³ Data ³ 19.12.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza o percentual correspondente a alternativa         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RspUpdPercen()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Trma190 - Chamado pelo programa RSPXTEST.PRW               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function RspUpdPercen(cTipoObj,xOption,cKey)
Local nOp		:=1
Local nPercen	:=0 

default cTipoObj 	:=0
default cKey		:=""

dbSelectArea("TRB")
dbSetOrder(1)
MsSeek(cKey)
While !TRB->(Eof()) .And. cKey == TRB->TRB_TESTE+TRB->TRB_SEQ
	If cTipoObj == "3"	//Questao Dissertativa
			nPercen:=TRB->TRB_PERCENTO 
	ElseIf cTipoObj == "1" //Check - Multipla Escolha
			nPercen+=If(xOption[nOp,1]:cName=="LBOK",TRB->TRB_PERCENTO,0)
	ElseIf cTipoObj == "2" //Questao Unica Escolha
	   If nOp==xOption   
			nPercen:=TRB->TRB_PERCENTO 
			Exit
	  EndIf	
	Endif
	TRB->(dbSkip())
	nOp++
End

Return nPercen
