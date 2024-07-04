#INCLUDE "PROTHEUS.CH"
#INCLUDE "QEPXFUN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ QEPXFUN  ³ Autor ³ Equipe Quality        ³ Data ³ 06/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotinas comuns aos modulos do SIGAQIE e SIGAQIP.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³			ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data	³ BOPS ³  Motivo da Alteracao 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³			   ³ 		³      ³ 										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ QepAdmAne³ Autor ³ Cleber Souza          ³ Data ³ 07/06/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Administra os arquivos anexos.               			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QepAdmAne(EXPC1,EXPN1)									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Nome do Arquivo Anexo.   				 	      ³±±
±±³			 ³ EXPN2 = 1 - Inclui										  ³±±
±±³			 ³ 		   2 - Exclui										  ³±±
±±³			 ³ EXPC3 = Nome do Alias do Programa.   					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ EXPC1 - Arquivo Anexo									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAQIE													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QepAdmAne(cArqTMP,nOpc,cAlias)
Local   cQPathTrm   := Alltrim(Alltrim(QDOPATH()[3]))
Local   cDelAnexo   := Alltrim(GetMv("MV_QDELFNC")) // "Apagar Documentos Anexos no Diretorio Temporario"
Local   cQPathDoc   := IIF(cAlias == "QIE",Alltrim(GetMv("MV_QIEDOC")),Alltrim(GetMv("MV_QIPDOC")))
Local   nPos        := 0
Local   cArqAnexo   := " "

If !Right( cQPathTrm,1 ) == "\"
	cQPathTrm := cQPathTrm + "\"
Endif

If !Right( cQPathDoc,1 ) == "\"
	cQPathDoc := cQPathDoc + "\"
Endif

If nOpc == 1 //Inclui
	cArqAnexo:= Substr(cAlias,2,2)+StrZero(Val(QA_SEQU(Substr(cAlias,2,2),10,"N","")),10)      
	
	nPos  := RAT(".",cArqTmp)
    cArqAnexo := cArqAnexo + Substr(cArqTmp,nPos,(Len(Alltrim(cArqTmp))+1)-nPos)

	//Copia TMP para o nome correto. 
	If File(cQPathTrm+cArqTmp)
		__CopyFile(cQPathTrm + cArqTmp,cQPathTrm + cArqAnexo)
		If !File(cQPathTrm + cArqAnexo)
			Help(" ",1,"QEPNAOCOP")
			Return(cArqAnexo)
		Endif				
	EndIf	
                                
	If cDelAnexo == "1"	
		FErase(cQPathTrm+cArqTmp)
	EndIf

	//Copia para o Server
	If !CpyT2S(cQPathTrm + cArqAnexo,cQPathDoc,.T.)
		Help(" ",1,"QEPNAOCOP")
		Return(cArqAnexo)
	Endif

ElseIf nOpc == 2  //Exclui
    
	//Apaga o arquivo no servidor
	If File(cQPathDoc+Alltrim(cArqTmp))
		FErase(cQPathDoc+Alltrim(cArqTmp))
    EndIf
	                             
	//Verifica se existe local e apaga.
	If File(cQPathTrm+Alltrim(cArqTmp))
		FErase(cQPathTrm+Alltrim(cArqTmp))
    EndIf
EndIf

Return(cArqAnexo)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CalcHora  ³ Autor ³ Marcelo Pimentel      ³ Data ³ 06.10.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna o numero de horas.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³QIPA010()                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CalcHora(nHrIni,nHrFim,cLimite,lVrfHrNeg)
Local nVar		:= 0
Local nInt		:= 0
Local nDec		:= 0
Local cResult	:= 0
Local nPosTmpI	:= At(":",nHrIni)
Local nPosTmpF	:= At(":",nHrFim)

Default lVrfHrNeg := .F.

nIni := (Val(Left(nHrIni,nPosTmpI-1)) * 60) + Val(Right(AllTrim(nHrIni),2))
nFim := (Val(Left(nHrFim,nPosTmpF-1)) * 60) + Val(Right(AllTrim(nHrFim),2))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Limite Inferior ou Carregando Ensaio da Especificacao Inferior/Superior.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cLimite == "I"
	nFim := Val(StrTran(Str(nFim),"-",""))
	nVar := nIni - nFim
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso o hora final seja menor que a Incial, o sinal devera ser negativo.   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lVrfHrNeg
		If nFim < nIni
			If At("-",Str(nVar)) == 0
				nVar:= -nVar
			EndIf
		EndIf
	EndIf
Else
	nVar := nIni + nFim
EndIf

nInt := Int(nVar / 60)
nDec := Mod(nVar , 60)

cResult := StrZero(nInt,Iif(Len(Alltrim(Str(nInt)))==1,2,Len(Alltrim(Str(nInt)))))+":"+StrZero(nDec,2)

Return(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QA_Def5429³ Autor ³ Marcos Cesar          ³ Data ³05.08.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calcula o Indice de Defeitos baseado na Norma NBR-5429.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ExpN1 := QA_Def5429(ExpA1,ExpN1,ExpN2,ExpN3)                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 == Array com as medicoes.                             ³±±
±±³          ³ExpN1 == Limite inferior com tolerancia.                    ³±±
±±³          ³ExpN2 == Limite superior com tolerancia.                    ³±±
±±³          ³ExpC1 == Codigo da Norma (Plano).                           ³±±
±±³          ³ExpN3 == Tamanho da Amostra.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpA1[1] = Media											  ³±±
±±³			 ³     [2] = Desvio Padrao									  ³±±
±±³			 ³     [3] = PI												  ³±±
±±³			 ³     [4] = PS												  ³±±
±±³			 ³     [5] = PI+PS											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QA_Def5429(aMedicao,nLimInf,nLimSup,cPlano,nTamAmostra)
Local aMediaDV := {}
Local nIndQS   := 0
Local nIndQI   := 0
Local nIndDef  := 0                   
Local nPI      := 0
Local nPS      := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula a Media e o Desvio Padrao. Retorno :                            ³
//³                                                                         ³
//³ aMediaDV[1] : Media                                                     ³
//³ aMediaDV[2] : Desvio Padrao                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aMediaDV := QA_CalcDV(aMedicao)

If nLimInf > 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula o QI.                                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nIndQI := (aMediaDV[1] - nLimInf) / aMediaDV[2]
	nIndQI := Round(nIndQI,2)
	
	If nIndQI > 3.89
		nPI := 0
	ElseIf nIndQI < (3.89*-1)
		nPI := 100
	Else
		QA1->(dbSetOrder(1))
		QA1->(dbSeek(xFilial("QA1") + cPlano + Str(nTamAmostra,4) + Transform(Abs(nIndQI), "@E 99.99"), .T.))
		If nIndQI < 0
			nPI := Round(100-QA1->QA1_VLREPD,2)
		Else
			nPI := QA1->QA1_VLREPD
		EndIf
	EndIf
EndIF

If nLimSup > 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula o QS.                                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nIndQS := (nLimSup - aMediaDV[1]) / aMediaDV[2]
	nIndQS := Round(nIndQS,2)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pesquisa o Arquivo QA1 com o valor do QI.                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nIndQS > 3.89
		nPS := 0
	ElseIf nIndQS < (3.89*-1)
		nPS := 100
	Else
		QA1->(dbSetOrder(1))
		QA1->(dbSeek(xFilial("QA1") + cPlano + Str(nTamAmostra,4) + Transform(Abs(nIndQS), "@E 99.99"), .T.))
		If nIndQS < 0
			nPS := Round(100-QA1->QA1_VLREPD,2)
		Else
			nPS := QA1->QA1_VLREPD
		EndIf
	EndIf
EndIf

nTamAmostra := If(nTamAmostra>140,140,nTamAmostra)
	
nIndDef  := (nPI+nPS)
aRetorno := {aMediaDV[1],aMediaDV[2],nPI,nPS,nIndDef}  
Return(aRetorno) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QEP_RetAmostra³ Autor ³ Paulo Emidio de Barros³ Data ³22/08/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Define a amostragem a ser aplicada de acordo com a selecao do  ³±±
±±³		     ³ Plano de Amostragem                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QEP_RetAmostra(cTipAmo,cPlaAmo,cNivel,cNQA,cTamAmo,cCpoAmo,;   ³±±
±±³			 ³ 				  lSeparaPlano)	  								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Tipo do Plano de Amostragem							  ³±±
±±³			 ³ EXPC2 = Plano de Amostragem									  ³±±
±±³			 ³ EXPC3 = Nivel do Plano de Amostragem						      ³±±
±±³			 ³ EXPC4 = NQA													  ³±±
±±³			 ³ EXPC5 = Tamanho da Amostra									  ³±±
±±³			 ³ EXPC6 = Campo que define o Tamanho da Amostra				  ³±±
±±³			 ³ EXPL1 = Indica se as Amostragens definidas no Plano Interno se-³±±
±±³			 ³         rao separadas.										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPA1 = Amostragens definidas no Plano						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Generico														  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                              
Function QEP_RetAmostra(cTipAmo,cPlaAmo,cNivel,cNQA,cTamAmo,cCpoAmo,lSeparaPlano)
Local aAreaAnt   := GetArea()
Local aRetorno   := {}
Local cNorma     := ' '
Local cSequencia := ' '
Local cTipo      := ' '                     
Local cCodAmo    := ' '
Local nAmostra1  := 0
Local nAceite1   := 0
Local nRejeite1  := 0
Local nAmostra2  := 0
Local nAceite2   := 0
Local nRejeite2  := 0
Local cAmostra   := " "
Local aPlaInt1   := {} //Amostragem Simples
Local aPlaInt2   := {} //Amostragem Dupla
Local cTamFor    := " "  
Local nTamAmo    := 0
                
cNorma := QA_Plano(cTipAmo)

lSeparaPlano := If(lSeparaPlano==NIL,.F.,lSeparaPlano)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica tipo de Inspecao a ser aplicada de acordo c/ o Plano ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (cTipAmo == '1') .Or. (cTipAmo == 'N') .Or. ; //NBR5426 
   (cTipAmo == '3') .Or. (cTipAmo == 'I')        //Plano Interno
	cTipo := If(Right(cPlaAmo,1)=="A","AT",If(Right(cPlaAmo,1)=="N","NO","SE"))
ElseIf (cTipAmo == '2') .Or. (cTipAmo == 'Z') .Or.; //Zero Defeito (QS9000)
	   (cTipAmo == '4') .Or. (cTipAmo == 'T')       //Plano Texto	
	cTipo := "QS"
ElseIf (cTipAmo == '5') .Or. (cTipAmo == 'B') //NBR5429
	cTipo := If(AllTrim(cPlaAmo)=="A","AT",If(AllTrim(cPlaAmo)=="N","NO","SE"))
EndIf
        
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona o Codigo das Amostras de acordo com o Plano        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAmostra := Str(SuperVal(cTamAmo),8)
cNivel   := If(cPlaAmo=="QS",cPlaAmo,cNivel) //Verifica se o Plano e Zero Defeito

dbSelectArea("QA6")
dbSetOrder(2)
dbSeek(xFilial("QA6")+cNorma+cNivel+cAmostra,.T.)
If !Eof()
	cCodAmo := QA6_CODAMO
EndIf
   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define a sequencia para que na amostragem dupla, seja retorna-³
//³das as sequencias 1 e 2.										 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSequencia := If(Left(cPlaAmo,1)<>'D','0','1')

dbSelectArea("QA7") 
dbSetOrder(3)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Realiza o tratamento para a Amostragem definida no Plano In- ³
//³ terno.														 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (cTipAmo == "3") .Or. (cTipAmo == "I") //Plano Interno

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ aRetorno [x,1] = ACEITE 1                                    ³
	//³          [x,2] = REJEITE 1                                   ³
	//³ 		 [x,3] = AMOSTRA 1 									 ³
	//³          [x,4] = ACEITE 2 									 ³
	//³ 		 [x,5] = REJEITE 2									 ³
	//³ 		 [x,6] = AMOSTRA 2									 ³
	//³          [x,7] = SEQUENCIA									 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aRetorno := {}

	dbseek(xFilial("QA7")+cNorma+cNQA+cCodAmo)
	While !Eof() .And. QA7_FILIAL==xFilial("QA7") .And. QA7_PLANO==cNorma .And. QA7_NQA==cNQA .And. QA7_CODAMO==cCodAmo

        Aadd(aRetorno,Array(7))
        
		If Empty(QA7_NO_FOR)
			nTamAmo := If(QA7_NO_AMO>SuperVal(cTamAmo),SuperVal(cTamAmo),QA7_NO_AMO) 
		Else       
			cTamFor := QA7->QA7_NO_FOR
			If !Empty(cTamFor) .And. !Empty(cTamAmo)
				cTamFor := AllTrim(StrTran(cTamFor,"#Tam.Lote#",cTamAmo))
				nTamAmo := &(cTamFor)                                    
			Else	
				nTamAmo := 0
			EndIf          
		EndIf	               
		
		//Armazena por sequencia, o Aceite e o Rejeite das Amostragens Simples 
		aRetorno[Len(aRetorno),1] := QA7_NO_ACE //Aceite 1
		aRetorno[Len(aRetorno),2] := QA7_NO_REJ //Rejeite 1
		aRetorno[Len(aRetorno),3] := nTamAmo    //Tamanho da Amostra 1	
		
		If Empty(QA7_SE_FOR)        
			nTamAmo := If(QA7_SE_AMO>SuperVal(cTamAmo),SuperVal(cTamAmo),QA7_SE_AMO)
	    Else         
			cTamFor := QA7->QA7_SE_FOR
			If !Empty(cTamFor) .And. !Empty(cTamAmo)
				cTamFor := AllTrim(StrTran(cTamFor,"#Tam.Lote#",cTamAmo))
				nTamAmo := &(cTamFor)
			Else          
				nTamAmo := 0
			EndIf	
	    EndIf    

		//Armazena por sequencia, o Aceite e o Rejeite das Amostragens Duplas
		aRetorno[Len(aRetorno),4] := QA7_SE_ACE //Aceite 2
		aRetorno[Len(aRetorno),5] := QA7_SE_REJ //Rejeite 2
		aRetorno[Len(aRetorno),6] := nTamAmo    //Tamanho da Amostra 2	
		aRetorno[Len(aRetorno),7] := QA7_SEQUE  //Sequencia
		
		dbSelectArea("QA7")
		dbSkip()
		
	EndDo
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Formata o retorno do vetor para os Planos de Amostragens do  ³
	//³ Tipo Interno, devolvendo os mesmos em dois vetores, sendo:	 ³
	//³ x[1] = Sequencia											 ³
	//³      = Aceite 1												 ³
	//³      = Rejeite 1											 ³
	//³      = Tamanho da Amostra 1									 ³
	//³ x[2] = Sequencia											 ³
	//³      = Aceite 2												 ³
	//³      = Rejeite 2											 ³
	//³      = Tamanho a Amostra 2									 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If Len(aRetorno) == 0  //Verifica se o vetor nao esta definido com as Amostragens
    	Aadd(aRetorno,Afill(Array(7),0))
	    aRetorno[Len(aRetorno),7]:= " "
	EndIf        
	
	If lSeparaPlano
		Aeval(aRetorno,{|x,y|Aadd(aPlaInt1,{x[7],x[1],x[2],x[3]}),Aadd(aPlaInt2,{x[7],x[4],x[5],x[6]})})
		aRetorno := {aClone(aPlaInt1),aClone(aPlaInt2)}
	EndIf
		                                             
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona o Tamanho das Amostras de acordo com o Codigo      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Else                               
	aRetorno := Afill(Array(6),0)
	
	dbseek(xFilial("QA7")+cNorma+cNQA+cCodAmo+cSequencia)
	If !Eof()
	
	    //Verifica se o Plano e QS-9000
	 	If cTipo == "QS"
			nAceite1  := 0
			nRejeite1 := 1
		Else		
			nAceite1  := &("QA7_"+cTipo+"_ACE")
			nRejeite1 := &("QA7_"+cTipo+"_REJ")
		EndIf                           
		nAmostra1 := &("QA7_"+cTipo+"_AMO")
		nAmostra1 := If(nAmostra1>SuperVal(cTamAmo),SuperVal(cTamAmo),nAmostra1)
		    
		//Caso a Amostragem seja dupla, considera a segunda Sequencia
		If cSequencia == '1'      
			dbSkip() //Considera a sequencia 2
		
			nAceite2  := &("QA7_"+cTipo+"_ACE")
		   	nRejeite2 := &("QA7_"+cTipo+"_REJ")
			nAmostra2 := &("QA7_"+cTipo+"_AMO")
			nAmostra2 := If(nAmostra2> SuperVal(cTamAmo),SuperVal(cTamAmo),nAmostra2)
		
		EndIf
		aRetorno[1] := nAmostra1 //Amostra 1
		aRetorno[2] := nAceite1  //Aceite  1
		aRetorno[3] := nRejeite1 //Rejeite 1
		aRetorno[4] := nAmostra2 //Amostra 2
		aRetorno[5] := nAceite2  //Aceite  2
		aRetorno[6] := nRejeite2 //Rejeite 2
	EndIf
EndIf

RestArea(aAreaAnt)
Return(aRetorno)      
