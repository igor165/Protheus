#INCLUDE "mdtr505.ch"
#Include "Protheus.ch"  

#DEFINE _nVERSAO 2 //Versao do fonte
/*/   
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    � MDTR690  � Autor � Jackson Machado		  � Data �08/06/2011 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Ficha de Controle de Inspecao dos Conjuntos Hidr�ulicos     ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAMDT                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function MDTR505()
//�����������������������������������������������������������������������Ŀ
//� Armazena variaveis p/ devolucao (NGRIGHTCLICK) 				  		  	  �
//�������������������������������������������������������������������������
Local aNGBEGINPRM := NGBEGINPRM(_nVERSAO)

//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
Local aArea := GetArea()
LOCAL cF3CC := "SI3001"  //SI3 apenas do cliente

PRIVATE nomeprog := "MDTR505"
PRIVATE titulo   := STR0001  //"Ficha de Controle de Inspe��o dos Conjuntos Hidr�ulicos"
PRIVATE cPerg    := "MDT505    "
PRIVATE nSizeSI3 := If((TAMSX3("I3_CUSTO")[1]) < 1,9,(TAMSX3("I3_CUSTO")[1]))
PRIVATE cAliasCC := "SI3"
PRIVATE cCliMdtps := " "

/*------------------------------------------------
//PERGUNTAS PADRAO									|
MDT690    �01      �De  Conjunto Hidr�ulico  ?	|
MDT690    �02      �Ate Conjunto Hidr�ulico  ?	|
MDT690    �03      �De  Centro de Custo      ?	|
MDT690    �04      �Ate Centro de Custo      ?	|
MDT690    �05      �De  Data Inspecao   ?			|
MDT690    �06      �Ate Data Inspecao   ?			|
MDT690    �07      �Situa��o da Ordem    ?		|
--------------------------------------------------*/

If Alltrim(GETMV("MV_MCONTAB")) == "CTB"
	cAliasCC := "CTT"
	cF3CC := "CTT001"  //CTT apenas do cliente				
	nSizeSI3 := If((TAMSX3("CTT_CUSTO")[1]) < 1,9,(TAMSX3("CTT_CUSTO")[1]))
Endif

If Pergunte(cPerg,.T.,titulo)
		Processa({|lEND| MDTA505IMP()},STR0019) //"Processando..."
Endif

RestArea(aArea) 

//�����������������������������������������������������������������������Ŀ
//� Devolve variaveis armazenadas (NGRIGHTCLICK)                          �
//�������������������������������������������������������������������������
NGRETURNPRM(aNGBEGINPRM)

Return

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �MDTA505IMP� Autor � Jackson Machado		  � Data �08/06/2011 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de impressao                                          ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAMDT                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function MDTA505IMP()

	cSeekExt := xFilial('TKS')+Mv_par01
	cWhilExt := "xFilial('TKS') == TKS->TKS_FILIAL .AND. TKS->TKS_CODCJN <= Mv_par02"
	cCondExt := "TKS->TKS_CCCJN >= Mv_par03 .and. TKS->TKS_CCCJN <= Mv_par04"
	nIndiExt := 1
	
	oPrint01 := TMSPrinter():New( OemToAnsi(titulo))
	oPrint01:SetPortrait() 	//Retrato
	oPrint01:Setup() 		//Configuracao
	
	dbSelectArea("TKS")
	dbSetOrder(nIndiExt)
	dbSeek(cSeekExt,.T.)
	ProcRegua(LastRec())
	While !eof() .and. &(cWhilExt)
		IncProc()
		If &(cCondExt)
			MDT505Ficha(mv_par05,mv_par06)
		Endif
	
		dbSelectArea("TKS")
		dbSkip()
	End
oPrint01:Preview()


Return

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �MDT505Ficha Autor � Jackson Machado		  � Data �08/06/2011 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Impressao do Cabecalho da Ficha de Controle de Inspecao      ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAMDT                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function MDT505Ficha(dDeData,dAteDate,cNmCli)

Local nFor  := 0   // Contador
Local nCont := 0   // Contador
Local n     := 1 //Vari�vel de controle das inspe��es

Private nLinTemp  := 0
Private cNomeCli  := cNmCli
Private aOrdens	:= {}
Private aInspecao := {}
//Vari�vel de incremento de p�gina
Private nPag := 1

//Vari�vel para controle de linhas
Private nOldLin := 0

	dbSelectArea("TLD")
	dbSetOrder(2)
    If dbSeek(xFilial("TLD")+TKS->TKS_CODCJN)
      While !Eof() .and. TLD->TLD_FILIAL+TLD->TLD_CODEXT == xFilial("TLD")+TKS->TKS_CODCJN
      	If TLD->TLD_DTPREV < mv_par05 .or. TLD->TLD_DTPREV > mv_par06
      		dbSelectArea("TLD")
				dbSkip()
				Loop
      	Endif
      	
		If mv_par07 <> 3
			If Val(TLD->TLD_SITUAC) <> mv_par07
				dbSelectArea("TLD")
				dbSkip()
				Loop
			Endif
		Endif
		
		If mv_par07 == 3
			If TLD->TLD_SITUAC == "3"
				dbSelectArea("TLD")
				dbSkip()
				Loop
			Endif
		Endif
        
		If TLD->TLD_CATEGO == "1"
			dbSelectArea("TLD")
			dbSkip()
			Loop
		Endif
		
		aAdd(aOrdens,{TLD->TLD_ORDEM,TLD->TLD_PLANO,TKS->TKS_CODCJN,TKS->TKS_DESCJN,TKS->TKS_LOCCJN,TLD->TLD_SITUAC})
		aAdd(aInspecao,{})
		nX := 1
		dbSelectArea("TK5")
		dbSetOrder(1)
		If dbSeek(xFilial("TK5")+TLD->TLD_ORDEM)
			While !Eof() .And. TK5->TK5_ORDEM == TLD->TLD_ORDEM
				dbSelectArea("TK4")
				dbSetOrder(1)
				If dbSeek(xFilial("TK4")+TK5->TK5_EVENTO)
					aAdd(aInspecao[n],{TK5->TK5_EVENTO,TK4->TK4_DESCRI,TK5->TK5_REALIZ})//Incluindo posi��es de >= 6 com as inspe��es
				Endif
				dbSelectArea("TK5")
				dbSkip()
			End
		Endif
		n++
		dbSelectArea("TLD")
		dbSkip()
		End

    Endif
	
	oFont12n    := TFont():New("VERDANA",12,12,,.T.,,,,.F.,.F.)
	oFont11     := TFont():New("VERDANA",11,11,,.F.,,,,.F.,.F.)
	oFont11n    := TFont():New("VERDANA",11,11,,.T.,,,,.F.,.F.)
	oFont12     := TFont():New("VERDANA",12,12,,.F.,,,,.F.,.F.)
	oFont10     := TFont():New("VERDANA",10,10,,.F.,,,,.F.,.F.)
	
	nLin := 510
	For nCont := 1 To Len(aOrdens)
		nPag := 1
		oPrint01:StartPage()	//Inicia Pagina
	
		MDTR505PAG(.F.,nCont)  
		SomaLinha(160)
		nOldLin := nLin
		nLinTemp := nLin+20
		For nFor := 1 To Len(aInspecao[nCont]) // Seleciona apenas as inspe��es no array ( >=6 )
			oPrint01:Say(nLinTemp,250,aInspecao[nCont][nFor][1]+" - "+Upper(aInspecao[nCont][nFor][2]),oFont11)
			If aOrdens[nCont][6] == "2"
				If aInspecao[nCont][nFor][3] == "1"
					oPrint01:Say(nLinTemp,1750,"X",oFont12)
				Else
					oPrint01:Say(nLinTemp,2100,"X",oFont12)	
				Endif
			Endif
			nLinTemp += 100
			oPrint01:line(nLinTemp-20,200,nLinTemp-20,2300)		// Linha Horizontal que separa as respostas
			Somalinha(100,nCont)
		Next nFor
		If Len(aInspecao[nCont])%24 == 0 
			nLen := Len(aInspecao[nCont])/24
		Else
			nLen := Int(Len(aInspecao[nCont])/24)+1
		Endif
		// 670 pixels e' o valor onde inicia a impressao dos eventos
		// Quando a pagina e' finalizada pela funcao SomaLinha(), a varialvel nLin recebe +160,
		// portanto primeiro deve atribuir os 160 que seriam recebidos no rodape' para depois
		// terminar a pagina
		oPrint01:line(670,1580,nLin,1580)		// Linha Vertical que isola 'Sim'
		oPrint01:line(670,1950,nLin,1950)		// Linha Vertical que isola 'Nao'
		oPrint01:Box(160,200,nLin,2300)			// Box que contem o relatorio
		oPrint01:Say(3090,1200,STR0020+AllTrim(Str(nLen))+STR0021+AllTrim(Str(nLen)),oFont11,,,,2) //"P�gina "###" de "
		oPrint01:EndPage()
		nLin := 510
	Next nCont


Return NIL
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �MDTR505PAG�Autor  �Jackson Machado	  � Data �  08/06/2011 ���
�������������������������������������������������������������������������͹��
���Desc.     � Pula de pagina.                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MDTR505                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MDTR505PAG(lQuebra,nCont)
Default lQuebra := .F.
Default nCont := 1

If lQuebra
	// 2400 pixels e' onde o ultimo evento e' impresso
	oPrint01:Box(160,200,nLin,2300)			// Box que contem o relatorio
	oPrint01:line(670,1580,nLin,1580)		// Linha Vertical que isola 'Sim'
	oPrint01:line(670,1950,nLin,1950)		// Linha Vertical que isola 'Nao'
	If Len(aInspecao[nCont])%24 == 0 
		oPrint01:Say(nLinTemp,1200,STR0020+AllTrim(Str(nPag))+STR0021+AllTrim(Str(Len(aInspecao[nCont])/24)),oFont11,,,,2) //"P�gina "###" de "
	Else
		oPrint01:Say(nLinTemp,1200,STR0020+AllTrim(Str(nPag))+STR0021+AllTrim(Str(Int(Len(aInspecao[nCont])/24)+1)),oFont11,,,,2) //"P�gina "###" de "
	Endif
	//Vari�vel de incremento de p�gina
	nPag++
	//Reestabelece par�metros de linha
	nLin := nOldLin
	nLinTemp := nLin+20
	// Encerra a pagina atual
	oPrint01:EndPage()
	// Comeca uma nova pagina
	oPrint01:StartPage()
EndIf
cLogo := NGLocLogo()
If !Empty(cLogo)
	oPrint01:SayBitMap(180,230,cLogo,300,150)
Endif
oPrint01:Say(250,1250,Upper(STR0022),oFont12n,,,,2) //"FICHA DE CONTROLE DE INSPE��O"
// Prepara a nova pagina com o cabecalho
oPrint01:line(350,200,350,2300)		// Linha Horizontal que corta o Cabecalho
oPrint01:line(430,200,430,2300)		// Linha Horizontal que corta 'Cj. Hidr�ulic' 
oPrint01:line(510,200,510,2300)		// Linha Horizontal que corta 'Local'
oPrint01:line(510,1230,590,1230)		// Linha Vertical que separa 'O.S.' e 'Plano'
oPrint01:line(590,200,590,2300)		// Linha Horizontal que corta 'O.S.' e 'Plano'
oPrint01:line(590,1580,670,1580)		// Linha Vertical que isola 'Sim'
oPrint01:line(590,1950,670,1950)		// Linha Vertical que isola 'Nao'
oPrint01:line(670,200,670,2300)		// Linha Horizontal que corta o 'Atividades'

oPrint01:Say(360,210,STR0024,oFont11n)  //"Cj. Hidr�ulico:"
oPrint01:Say(365,600,AllTrim(aOrdens[nCont][3])+" - "+aOrdens[nCont][4],oFont10)

oPrint01:Say(440,210,STR0025,oFont11n)  //"Local:"
oPrint01:Say(445,600,aOrdens[nCont][5],oFont10)

oPrint01:Say(520,210,STR0026,oFont11n)  //"Ordem:"
oPrint01:Say(525,380,aOrdens[nCont][1],oFont10)
oPrint01:Say(520,1240,STR0027,oFont11n)  //"Plano:"
oPrint01:Say(525,1380,aOrdens[nCont][2],oFont10)

oPrint01:Say(600,800,STR0028,oFont11n) //"Atividades"
oPrint01:Say(600,1730,STR0029,oFont11n) //"Sim"
oPrint01:Say(600,2080,STR0030,oFont11n)  //"N�o"
	
Return .T.
/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��� Fun��o   � SomaLinha� Autor � Jackson Machado       � Data � 08/06/11 ���
�������������������������������������������������������������������������Ĵ��
��� Descri��o� Incrementa Linha e Controla Salto de Pagina                ���
�������������������������������������������������������������������������Ĵ��
��� Sintaxe  � SomaLinha()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MDTR505                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
/*/
Static Function Somalinha(linhas,nCont)

Default linhas := 80

nLin += linhas
If nLin > 3060
	If ValType(nCont) == "N"                               
		MDTR505PAG(.T.,nCont)
	Endif
EndIf	

Return
/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��� Fun��o   �R505DATAIN� Autor � Jackson Machado       � Data � 08/06/11 ���
�������������������������������������������������������������������������Ĵ��
��� Descri��o� Valida data inicial.							              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MDTR505                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
/*/
Function R505DATAIN(dData,dFim)

If Empty(dData)
	Help(" ",1,"DEDATAINVA")
	Return .F.
Endif

If !Empty(dFim) .and. dData > dFim
	Help(" ",1,"DATAINVALI")
 	Return .F.
Endif

Return .T.