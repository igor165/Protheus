#INCLUDE "ATFR3310.ch"
#INCLUDE "PROTHEUS.CH" 
#INCLUDE "COLORS.CH" 
 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออปฑฑ
ฑฑบ Programa ณ ATFR3310  บ Autor ณ Elton C 			 บ Data ณ  29/11/10    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออนฑฑ
ฑฑบ Desc.    ณ Mapa Fiscal modelo 33.10                                    บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿

Cristian - 18/Jan

Ajuste para transformar o mapa 33.8 em 33.10
*/
Function ATFR3310() 

Local aSaveArea		:= GetArea()
Local cPerg			:= "ATR3310"

Private cMoedATF	:= ""
Private cExerc		:= ""
Private oRelATF

//Parametros de perguntas para o relatorio
//+-----------------------------------------------------+
//| mv_par01 - Exercicio ? 								|
//| mv_par02 - Data de   ? 								|
//| mv_par03 - Data Ate  ?                              |
//| mv_par04 - Imprime Abatidos ? 33.10	                |
//+-----------------------------------------------------+

If Pergunte(cPerg,.T.)                
	cMoedATF := GetMV("MV_ATFMOED")
	oRelATF	:= tNewMsprinter():New(STR0001 + " - " + STR0002 + "33.10") //"MAPA"###"MODELO" //"MAPA"###"MODELO"
	oRelATF:SetLandscape()
	If VldATFR3310()
		ImpRelATF()
		oRelATF:Preview()
	EndIf
Endif 

RestArea(aSaveArea)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออปฑฑ
ฑฑบ Programa ณImpRelATF บ Autor ณ Elton C.			 บ Data ณ  29/11/10    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออนฑฑ
ฑฑบ Desc.    ณ Impressao do relatorio                                      บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ImpRelATF()

Local aSaveArea		:= GetArea()
Local lFimRel 		:= .F.
Local lBemAbatido	:= Iif(MV_PAR04 == 1, .T., .F.)
Local nContLinha	:= 0        
Local nContPagina	:= 0 
Local cArqTemp		:= ""
Local cCol1			:= ""
Local cCol2			:= ""
Local nCol3			:= 0
Local nCol4			:= 0
Local nCol5			:= 0
Local nCol6			:= 0
Local nCol7			:= 0
Local nCol8			:= 0

Local nCol9			:= 0
Local nCol10		:= 0
Local nCol11		:= 0
Local nCol12		:= 0
Local nCol13		:= 0
Local nCol14		:= 0
Local nCol15		:= 0
Local nCol16		:= 0

Local nTotCol5   	:= 0
Local nTotCol6   	:= 0
Local nTotCol7   	:= 0
Local nTotCol8		:= 0
Local nTotCol10		:= 0
Local nTotCol12		:= 0
Local nTotCol13		:= 0
Local nTotCol14		:= 0
Local nTotCol15		:= 0
//Local nTotCol16		:= 0

Private oFont05		:= TFont():New("Arial",05,05,,.F.,,,,.T.,.F.)
Private oFont08		:= TFont():New("Arial",07,07,,.F.,,,,.T.,.F.)
Private oFont06		:= TFont():New("Arial",06,06,,.F.,,,,.T.,.F.)
Private oFont10		:= TFont():New("Arial",8.5,8.5,,.F.,,,,.T.,.F.)
Private oFont10n	:= TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
Private oFont08n	:= TFont():New("Arial",08,08,,.T.,,,,.T.,.F.)
Private oFont11		:= TFont():New("Arial",11,11,,.F.,,,,.T.,.F.)
Private oFont12		:= TFont():New("Arial",12,12,,.F.,,,,.T.,.F.)
Private oFont13		:= TFont():New("Arial",13,13,,.F.,,,,.T.,.F.)
Private oFont14		:= TFont():New("Arial",14,14,,.F.,,,,.T.,.F.)
Private oFont14a	:= TFont():New("Arial",18,14,,.F.,,,,.T.,.F.)
Private oFont12N	:= TFont():New("Arial",12,12,,.T.,,,,.T.,.F.)
Private oFont16N	:= TFont():New("Arial",16,16,,.T.,,,,.T.,.F.)
Private oFont24		:= TFont():New("Arial",24,24,,.F.,,,,.T.,.F.)
Private oFont24N	:= TFont():New("Arial",24,24,,.T.,,,,.T.,.F.) 
Private oFont28N	:= TFont():New("Arial",28,28,,.T.,,,,.T.,.F.)
Private nLinDir	:= 0
Private nLinAlt	:= 0
Private oBrR := TBrush():New(,RGB(228,224,224),,)		//mesma cor usada no bitmap SOMBRA250.bmp

/*
Preenchimento do cabe็alho
*/ 
ImpLayout()//monta o layout do cabe็alho e colunas do relatorio
CabecDados(lBemAbatido) 

cArqTemp := GeraDados(lBemAbatido)//Nome do arquivo temporario que contem os dados
/*
Preenchimento dos dados apresentados nas colunas 
*/  
While !((cArqTemp)->(Eof()))
  
		cCol1		:= SUBSTR((cArqTemp)->COL1,1,1)+" | "+SUBSTR((cArqTemp)->COL1,2,1)+" | "+SUBSTR((cArqTemp)->COL1,3,1)+" | "+SUBSTR((cArqTemp)->COL1,4,1)
		cCol2		:= AllTrim((cArqTemp)->COL2) + ' (' + AllTrim((cArqTemp)->COL17) + ')'
		nCol3		:= Year(STOD((cArqTemp)->COL3))
		nCol4		:= Year(STOD((cArqTemp)->COL4))
		nCol5		:= (cArqTemp)->COL5
		nCol6       := (cArqTemp)->COL6 + nCol5
		nCol7       := (cArqTemp)->COL7 + nCol6
		nCol8		:= (cArqTemp)->COL8 + nCol7
		
		dInDepr		:= STOD( (cArqTemp)->COL3 )
		nDecorrido	:= 0
		While ((cArqTemp)->N1_ESTUSO == "S" ) .AND. ( dInDepr > CTOD("31/12/1985") ) .AND. ( dInDepr <= STOD((cArqTemp)->N3_FIMDEPR) )
			nDecorrido++
			If Month(dInDepr) == 12
				nMesAux  := 1
				nAnoAux  := ( Year(dInDepr) + 1 )
			Else
				nMesAux  := ( Month(dInDepr) + 1 )
				nAnoAux  := Year( dInDepr )
			EndIf
			
			dInDepr  := STOD( StrZero(nAnoAux,4)+StrZero(nMesAux,2)+"01" )
		EndDo

		nCol9		:= Iif((cArqTemp)->N1_ESTUSO == 'S',(cArqTemp)->COL9, "" )
		nCol10		:= (cArqTemp)->COL10
		nCol11		:= (cArqTemp)->COL11
		nCol12		:= (cArqTemp)->COL12
		nCol13		:= nCol10 + nCol12
		nCol14		:= nCol8 - nCol13
		//	nCol15		:= Iif(((cArqTemp)->COL6 <> 0) .Or. ((cArqTemp)->COL5 <> 0) , nCol5 * (nCol9 / 100),0)
		// se o bem nใo estiver totalmente depreciado, entao o valor da coluna 15 deve ser proporcional ao que foi depreciado no ano
		nCol15		:= IIF( nCol12 <> 0, ( nCol12 /  nCol8 )  * nCol5 , 0  )
		nCol16		:= (cArqTemp)->COL16
         
		oRelATF:Say(960+nContLinha,070,cCol1,oFont06) // Codigo do grupo de Bens - Coluna 1
		oRelATF:Say(960+nContLinha,300,cCol2,oFont06) // Descri็ใo do grupo de Bens - Coluna 2
		oRelATF:Say(960+nContLinha,845,transform(nCol3,"9999"),oFont06) // Ano de Aquisi็ใo - Coluna 3
		oRelATF:Say(960+nContLinha,970,transform(nCol4,"9999"),oFont06) // Ano de inicio da utiliza็ใo - Coluna 4
		oRelATF:Say(960+nContLinha,1055,transform(nCol5,"@E 999,999,999,999.99"),oFont06) //  - De Aquisi็ใo, produ็ใo ou da ultima reavalia็ใo efetuda - Coluna 5
		oRelATF:Say(960+nContLinha,1235,transform(nCol6,"@E 999,999,999,999.99"),oFont06) //  - Dec Lei 126/77 - coluna 06
		oRelATF:Say(960+nContLinha,1410,transform(nCol7,"@E 999,999,999,999.99"),oFont06) //  - dec lei 430/78, 24/82, 219/82 ...... - coluna 07
		oRelATF:Say(960+nContLinha,1560,transform(nCol8,"@E 999,999,999,999.99"),oFont06) // - De Reavalia็ใo 111/88 -  Coluna 8
		oRelATF:Say(960+nContLinha,1770,transform(nCol9,"@E 999" ),oFont06) // - Anos de utilizadade - Coluna 7                  
		oRelATF:Say(960+nContLinha,1845,transform(nCol10,"@E 999,999,999,999.99"),oFont06) // - de exercicios anteriores - Coluna 10
		oRelATF:Say(960+nContLinha,2040,transform(nCol11,"@E 999.99"),oFont06) // - Taxa - Coluna 11
		oRelATF:Say(960+nContLinha,2165,transform(nCol12,"@E 999,999,999,999.99"),oFont06) // - Valores - Coluna 12
		oRelATF:Say(960+nContLinha,2390,transform(nCol13,"@E 999,999,999,999.99"),oFont06) // - Acumuladas - Coluna 13
		oRelATF:Say(960+nContLinha,2615,transform(nCol14,"@E 999,999,999,999.99"),oFont06) // - Ativo imobilizado (liquido) - Coluna 14
		oRelATF:Say(960+nContLinha,3045,transform(nCol16,"@E 999.99"),oFont06) // - Taxa acumulada - Coluna 16
	 
		//Totalizadores por paginas
		nTotCol5   	+= nCol5
		nTotCol6   	+= nCol6
		nTotCol7   	+= nCol7
		nTotCol8	+= nCol8
		nTotCol10   += nCol10
		nTotCol12	+= nCol12
		nTotCol13   += nCol13
		nTotCol14	+= nCol14
		nTotCol15	+= nCol15		
		
		(cArqTemp)->(DbSkip())

		nContLinha += 40 //contador para pular linhas 
		nContPagina++ // Contador para pular a pagina e imprimir o valor a total
	
	/*
	Imprime o rodape
	*/	
 	If nContPagina > 30 .Or. (cArqTemp)->(Eof())
		If (cArqTemp)->(Eof())
			lFimRel:= .T.
			ImpRodap1(lFimRel)
		Else
			lFimRel:= .F.
			ImpRodap1(lFimRel)
		EndIf                      
		
        //Imprime os totalizadores
		//Totalizadores por paginas 
		oRelATF:Say(2250,1055,transform(nTotCol5,"@E 999,999,999,999.99"),oFont06)//1- Total Coluna 5
		oRelATF:Say(2250,1235,transform(nTotCol6,"@E 999,999,999,999.99"),oFont06)//1- Total Coluna 6
		oRelATF:Say(2250,1410,transform(nTotCol7,"@E 999,999,999,999.99"),oFont06)//1- Total Coluna 7
		oRelATF:Say(2250,1560,transform(nTotCol8,"@E 999,999,999,999.99"),oFont06)//2- Total Coluna 8
		oRelATF:Say(2250,1845,transform(nTotCol10,"@E 999,999,999,999.99"),oFont06)//3- Total Coluna 10
		oRelATF:Say(2250,2145,transform(nTotCol12,"@E 999,999,999,999.99"),oFont06)//3- Total Coluna 12
		oRelATF:Say(2250,2370,transform(nTotCol13,"@E 999,999,999,999.99"),oFont06)//4- Total Coluna 13
		oRelATF:Say(2250,2595,transform(nTotCol14,"@E 999,999,999,999.99"),oFont06)//4- Total Coluna 14
		oRelATF:Say(2250,2820,transform(nTotCol15,"@E 999,999,999,999.99"),oFont06)//6- Total Coluna 15  

		If lFimRel
			oRelATF:Say(2350,2820,transform(nTotCol12 - nTotCol15,"@E 999,999,999,999.99"),oFont06)//Total Coluna k(11)
		Else 
			nContLinha 	:= 0
			nContPagina := 0
			oRelATF:EndPage() 
			oRelATF:StartPage()
			ImpLayout()
			CabecDados(lBemAbatido) 
		EndIf
	EndIf
EndDo

oRelATF:EndPage() 
RestArea(aSaveArea) 
Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออปฑฑ
ฑฑบ Programa ณCabecDadosบ Autor ณ Elton C.			 บ Data ณ  30/11/10    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออนฑฑ
ฑฑบ Desc.    ณ Impressao do cabecalho                                      บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CabecDados(lBemAbat) 

Local aSaveArea		:= GetArea()
Local aDadosEmp 	:= {}
Local aAuxString	:= {} 
Local nI			:= 0
Local nLinhaAux		:= 0 

Default lBemAbat 	:= .F.  

aDadosEmp := DadosEmp() //Dados da empresa

If lBemAbat
	oRelATF:Say(452,1446,STR0003,oFont06,2100,,,2) //P //"BENS ABATIDOS NO EXERCอCIO"
EndIf
//Se o nome da empresa for maior que 43, entใo a String serแ quebrada e impressa em 2 LINHAS no maximo
If Len(aDadosEmp[1]) > 50
	nLinhaAux := 0
	aAuxString := ATFBrkStr(aDadosEmp[1],50,2)	
    For nI := 1 To Len(aAuxString)
    	oRelATF :Say(195+nLinhaAux,220,aAuxString[nI],oFont06)//Nome da Empresa   
    	nLinhaAux +=  40
    Next
Else 
	oRelATF :Say(195,240,aDadosEmp[1],oFont06)//Nome da Empresa   
EndIF
oRelATF :Say(347,960,MV_PAR01,oFont06) //Exercicio
oRelATF :Say(443,700,DTOC(MV_PAR02),oFont06) //Periodo tributa็ใo De:
oRelATF :Say(443,910,DTOC(MV_PAR03),oFont06) //Periodo tributa็ใo a
oRelATF :Say(183,2270,SUBSTR(aDadosEmp[2],1,9),oFont06) // Numero de identifica็ใo fiscal

//Se o tamanho da Atividade Principal for maior que 26, entใo a String serแ quebrada e impressa em 2 LINHAS NO MAXIMO
If Len(aDadosEmp[3]) > 50
	nLinhaAux := 0
	aAuxString := ATFBrkStr(aDadosEmp[3],50,2)	
    For nI := 1 To Len(aAuxString)
		oRelATF :Say(273+nLinhaAux,2150,aAuxString[nI],oFont06) // Atividade principal
    	nLinhaAux +=  40
    Next
Else
	oRelATF :Say(273,2150,aDadosEmp[3],oFont06) // Atividade principal
EndIf	

oRelATF :Say(435,2470,aDadosEmp[4],oFont06) // Codigo Cae

RestArea(aSaveArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออปฑฑ
ฑฑบ Programa ณImpLayout บ Autor ณ Elton C.			 บ Data ณ  30/11/10    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออนฑฑ
ฑฑบ Desc.    ณ Impressao do Layout	                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ImpLayout() 

Local aSaveArea	:= GetArea()
Local aPalavras	:= {}

oRelATF :STARTPAGE()

//Cabe็alho do relatorio
oRelATF :Box(120-nLinAlt,1070-nLinDir,500-nLinAlt,50-nLinDir)
oRelATF :Say(100-nLinAlt,1490-nLinDir,STR0004,oFont12N,2100,,,2)  //"MAPA DE REINTEGRAวีES"
oRelATF :Say(190-nLinAlt,1486-nLinDir,STR0005,oFont06,2100,,,2)  //"Elementos do activo imobilizado corp๓reo reavaliados"
oRelATF :Say(235-nLinAlt,1486-nLinDir,STR0006,oFont06,2100,,,2)  //"ao abrigo do Decreto-Lei nบ 264/92, de 24 de Novembro"
oRelATF :Say(325-nLinAlt,1486-nLinDir,STR0007,oFont08,2100,,,2)  //"TOTALMENTE REINTEGRADOS"
oRelATF :Say(370-nLinAlt,1486-nLinDir,STR0008,oFont06,2100,,,2)   //"na data a que se reporta a reavalia็ใo"
oRelATF :Say(458-nLinAlt,1416-nLinDir,"(a)___________________________________________________",oFont06,2100,,,2)
oRelATF :Say(180-nLinAlt,110-nLinDir,STR0009,oFont11)  //"Firma: "
oRelATF :Say(330-nLinAlt,730-nLinDir,STR0010,oFont11)  //"Exercํcio de: "
oRelATF :Say(430-nLinAlt,90-nLinDir,STR0011,oFont11) //"PERอODO DE TRIBUTAวรO"
oRelATF :Say(430-nLinAlt,620-nLinDir,STR0012,oFont11)    //"De"
oRelATF :Say(430-nLinAlt,840-nLinDir,STR0013,oFont11)          //"a"
oRelATF :Box(120-nLinAlt,1900-nLinDir,500-nLinAlt,2720-nLinDir)
oRelATF :Say(180-nLinAlt,1910-nLinDir,STR0014,oFont08) //"N๚mero de identifica็ใo fiscal:"
oRelATF :Say(270-nLinAlt,1910-nLinDir,STR0015,oFont08) //"Actividade principal:"
oRelATF :Say(430-nLinAlt,2310-nLinDir,STR0016,oFont08) //"C๓digo CAE: "
oRelATF :Box(120-nLinAlt,2750-nLinDir,500-nLinAlt,3150-nLinDir) 
oRelATF :Say(200-nLinAlt,2960-nLinDir,STR0017,oFont16N,2100,,,2)  //"M O D E L O"
oRelATF :Say(300-nLinAlt,2840-nLinDir,"33.10",oFont28N)

//Colunas sem reparti็๕es (Linha Vertical) 
oRelATF :Box(520-nLinAlt,50-nLinDir,2200-nLinAlt,3150-nLinDir) 
oRelATF :line(940-nLinAlt,50-nLinDir,940-nLinAlt,3150-nLinDir)	//horiz
 
oRelATF :line(520-nLinAlt,280-nLinDir,2200-nLinAlt,280-nLinDir)     //1
oRelATF :line(520-nLinAlt,825-nLinDir,2200-nLinAlt,825-nLinDir)     //2 
oRelATF :line(520-nLinAlt,1055-nLinDir,2200-nLinAlt,1055-nLinDir)   //3 
oRelATF :line(520-nLinAlt,1725-nLinDir,2200-nLinAlt,1725-nLinDir)   //4 
oRelATF :line(520-nLinAlt,1825-nLinDir,2200-nLinAlt,1825-nLinDir)   //5 
oRelATF :line(520-nLinAlt,2575-nLinDir,2200-nLinAlt,2575-nLinDir)   //6
oRelATF :line(520-nLinAlt,2800-nLinDir,2200-nLinAlt,2800-nLinDir)   //7 
oRelATF :line(520-nLinAlt,3025-nLinDir,2200-nLinAlt,3025-nLinDir)   //8 

//Colunas com reparti็๕es (Linha horizontal)
oRelATF :line(590-nLinAlt,825-nLinDir,590-nLinAlt,1725-nLinDir)	    //1
oRelATF :line(660-nLinAlt,1235-nLinDir,660-nLinAlt,1725-nLinDir)	//2
oRelATF :line(590-nLinAlt,1825-nLinDir,590-nLinAlt,2575-nLinDir)	//3
oRelATF :line(660-nLinAlt,2000-nLinDir,660-nLinAlt,2350-nLinDir)	//4

// Coluna com reparti็๕es (Linha Vertical)
oRelATF :line(590-nLinAlt,945-nLinDir,2200-nLinAlt,945-nLinDir)   	//1 
oRelATF :line(590-nLinAlt,1235-nLinDir,2200-nLinAlt,1235-nLinDir)   //2 
oRelATF :line(660-nLinAlt,1410-nLinDir,2200-nLinAlt,1410-nLinDir)   //3 
oRelATF :line(660-nLinAlt,1560-nLinDir,2200-nLinAlt,1560-nLinDir)   //4
oRelATF :line(590-nLinAlt,2000-nLinDir,2200-nLinAlt,2000-nLinDir)   //5
oRelATF :line(660-nLinAlt,2125-nLinDir,2200-nLinAlt,2125-nLinDir)   //6
oRelATF :line(590-nLinAlt,2350-nLinDir,2200-nLinAlt,2350-nLinDir)   //7

//Descri็ใo das colunas (cabe็alho das colunas)
aPalavras := ATFBrkStr(STR0018,20,5)	 //"C๓digo de acordo com as tabelas anexas ao Decreto Regul."
oRelATF:Say(700-nLinAlt,165-nLinDir,aPalavras[1],oFont06,620,,,2) 
oRelATF:Say(740-nLinAlt,165-nLinDir,aPalavras[2],oFont06,620,,,2)
oRelATF:Say(780-nLinAlt,165-nLinDir,aPalavras[3],oFont06,620,,,2)
oRelATF:Say(820-nLinAlt,165-nLinDir,aPalavras[4],oFont06,620,,,2)
oRelATF:Say(860-nLinAlt,165-nLinDir,aPalavras[5],oFont06,620,,,2)  

aPalavras := ATFBrkStr(STR0019,40,2)	 //"Descri็ใo dos  elementos do activo imobilizado corp๓reo"
oRelATF :Say(700-nLinAlt,520-nLinDir,aPalavras[1],oFont08,620,,,2) 
oRelATF :Say(740-nLinAlt,520-nLinDir,aPalavras[2],oFont08,620,,,2)

oRelATF:Say(560-nLinAlt,925-nLinDir,STR0020,oFont08)  //"Ano"

aPalavras := ATFBrkStr(STR0021,5,2)	 //"Aquisi- ็ใo"
oRelATF:Say(700-nLinAlt,895-nLinDir,aPalavras[1],oFont08,620,,,2) 
oRelATF:Say(740-nLinAlt,895-nLinDir,aPalavras[2],oFont08,620,,,2) 

aPalavras := ATFBrkStr(STR0022,5,4)	 //"Inicio de utili- za็ใo"
oRelATF:Say(700-nLinAlt,1005-nLinDir,aPalavras[1],oFont08,620,,,2) 
oRelATF:Say(740-nLinAlt,1005-nLinDir,aPalavras[2],oFont08,620,,,2) 
oRelATF:Say(780-nLinAlt,1005-nLinDir,aPalavras[3],oFont08,620,,,2)
oRelATF:Say(820-nLinAlt,1005-nLinDir,aPalavras[4],oFont08,620,,,2)

oRelATF:Say(560-nLinAlt,1430-nLinDir,STR0023,oFont08,620,,,2)  //"Valores do activo imobilizado"

aPalavras := ATFBrkStr(STR0024,15,7)	 //"De aquisi็ใo ou outros valores contabilisticos, nos termos do no. 2 do artigo 2o. do Dec.Lei 118-B/86"
oRelATF:Say(620-nLinAlt,1150-nLinDir,aPalavras[1],oFont08,620,,,2) 
oRelATF:Say(660-nLinAlt,1150-nLinDir,aPalavras[2],oFont08,620,,,2) 
oRelATF:Say(700-nLinAlt,1150-nLinDir,aPalavras[3],oFont08,620,,,2) 
oRelATF:Say(740-nLinAlt,1150-nLinDir,aPalavras[4],oFont08,620,,,2) 
oRelATF:Say(780-nLinAlt,1150-nLinDir,aPalavras[5],oFont08,620,,,2) 
oRelATF:Say(820-nLinAlt,1150-nLinDir,aPalavras[6],oFont08,620,,,2) 
oRelATF:Say(860-nLinAlt,1150-nLinDir,aPalavras[7],oFont08,620,,,2) 

aPalavras := ATFBrkStr(STR0025,15,3)	 //"Dec.-Lei nบ 126/77 ou Portaria 20.258"
oRelATF:Say(700-nLinAlt,1325-nLinDir,aPalavras[1],oFont06,620,,,2) 
oRelATF:Say(740-nLinAlt,1325-nLinDir,aPalavras[2],oFont06,620,,,2)
oRelATF:Say(780-nLinAlt,1325-nLinDir,aPalavras[3],oFont06,620,,,2)
//oRelATF:Say(820-nLinAlt,1325-nLinDir,aPalavras[4],oFont06,620,,,2)
//oRelATF:Say(860-nLinAlt,1405-nLinDir,aPalavras[5],oFont06,620,,,2)

oRelATF:Say(630-nLinAlt,1500-nLinDir,STR0026,oFont08,620,,,2)  //"Da reavalia็ใo"

aPalavras := ATFBrkStr(STR0027,18,6)	 //"Dec.-Lei 430/78 ou Dec.-Lei 24/82 ou Dec.-Lei 219/82 ou Dec.-Lei 143/84 ou Dec.-Lei 399G/84 ou Dec.-Lei 278/85"
oRelATF:Say(700-nLinAlt,1490-nLinDir,aPalavras[1],oFont05,620,,,2) 
oRelATF:Say(730-nLinAlt,1490-nLinDir,aPalavras[2],oFont05,620,,,2)
oRelATF:Say(760-nLinAlt,1490-nLinDir,aPalavras[3],oFont05,620,,,2)
oRelATF:Say(790-nLinAlt,1490-nLinDir,aPalavras[4],oFont05,620,,,2)
oRelATF:Say(820-nLinAlt,1490-nLinDir,aPalavras[5],oFont05,620,,,2)
oRelATF:Say(850-nLinAlt,1490-nLinDir,aPalavras[6],oFont05,620,,,2)

aPalavras := ATFBrkStr(STR0028,15,2) //"Dec.-Lei nบ 118-B/86"
oRelATF:Say(700-nLinAlt,1640-nLinDir,aPalavras[1],oFont06,620,,,2)  
oRelATF:Say(740-nLinAlt,1640-nLinDir,aPalavras[2],oFont06,620,,,2)

aPalavras := ATFBrkStr(STR0029,5,2) //"Nr de Anos"
oRelATF:Say(700-nLinAlt,1775-nLinDir,aPalavras[1],oFont08,620,,,2)
oRelATF:Say(740-nLinAlt,1775-nLinDir,aPalavras[2],oFont08,620,,,2)


aPalavras := ATFBrkStr(STR0030,10,3)	 //"De exercํcios anteriores"
oRelATF:Say(700-nLinAlt,1910-nLinDir,aPalavras[1],oFont08,620,,,2) 
oRelATF:Say(740-nLinAlt,1910-nLinDir,aPalavras[2],oFont08,620,,,2) 
oRelATF:Say(780-nLinAlt,1910-nLinDir,aPalavras[3],oFont08,620,,,2)

oRelATF:Say(560-nLinAlt,2100-nLinDir,STR0031,oFont08,620,,,2)        //"Reintegra็๕es actualizadas"

oRelATF:Say(740-nLinAlt,2080-nLinDir,STR0035,oFont08,620,,,2)  //"Taxas"

oRelATF:Say(740-nLinAlt,2215-nLinDir,STR0032,oFont08,620,,,2) // "Valores"

oRelATF:Say(740-nLinAlt,2450-nLinDir,STR0033,oFont08,620,,,2)  //"Acumuladas"

oRelATF :Say(630-nLinAlt,2150-nLinDir,STR0039,oFont08,620,,,2)  //"Do exercํcio"

aPalavras := ATFBrkStr(STR0034,15,4)	 //"Activo imobilizado (valores lํquidos)"
oRelATF :Say(700-nLinAlt,2685-nLinDir,aPalavras[1],oFont08,620,,,2)
oRelATF :Say(740-nLinAlt,2685-nLinDir,aPalavras[2],oFont08,620,,,2)
oRelATF :Say(780-nLinAlt,2685-nLinDir,aPalavras[3],oFont08,620,,,2)
oRelATF :Say(820-nLinAlt,2685-nLinDir,aPalavras[4],oFont08,620,,,2)

aPalavras := ATFBrkStr(STR0037,18,5)	 //"Reintegra็๕es contidas na coluna (12) que sใo custos na totalidade"
oRelATF :Say(660-nLinAlt,2915-nLinDir,aPalavras[1],oFont08,620,,,2) 
oRelATF :Say(700-nLinAlt,2915-nLinDir,aPalavras[2],oFont08,620,,,2) 
oRelATF :Say(740-nLinAlt,2915-nLinDir,aPalavras[3],oFont08,620,,,2)     
oRelATF :Say(780-nLinAlt,2915-nLinDir,aPalavras[4],oFont08,620,,,2)     
oRelATF :Say(820-nLinAlt,2915-nLinDir,aPalavras[5],oFont08,620,,,2)     

aPalavras := ATFBrkStr(STR0038,8,4)	 //"Taxas perdidas acumula-  das"
oRelATF :Say(700-nLinAlt,3085-nLinDir,aPalavras[1],oFont08,620,,,2) 
oRelATF :Say(740-nLinAlt,3085-nLinDir,aPalavras[2],oFont08,620,,,2)   
oRelATF :Say(780-nLinAlt,3085-nLinDir,aPalavras[3],oFont08,620,,,2)   
oRelATF :Say(820-nLinAlt,3085-nLinDir,aPalavras[4],oFont08,620,,,2)   

RestArea(aSaveArea)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออปฑฑ
ฑฑบ Programa ณImpRodap1 บ Autor ณ Elton C.			 บ Data ณ  30/11/10    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออนฑฑ
ฑฑบ Desc.    ณ Impressao do rodape por pagina                              บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ImpRodap1(lFimRel)

Local aSaveArea	:= GetArea()
Default lFimRel := .F.
 
oRelATF:FillRect({2200,1055,2300,1725},oBrR)
//oRelATF:FillRect({2200,1560,2300,1725},oBrR)
oRelATF:FillRect({2200,1825,2300,2000},oBrR)
oRelATF:FillRect({2200,2125,2300,3025},oBrR)
 
oRelATF:Box(2200-nLinAlt,50-nLinDir,2300-nLinAlt,3150-nLinDir)
oRelATF:Say(2250-nLinAlt,500-nLinDir,STR0036,oFont08,620,,,2)  //"Total geral ou a transportar:"

// Coluna com reparti็๕es (Linha Vertical)
oRelATF:line(2200-nLinAlt,1055-nLinDir,2300-nLinAlt,1055-nLinDir)   //1
oRelATF:line(2200-nLinAlt,1235-nLinDir,2300-nLinAlt,1235-nLinDir)   //2
oRelATF:line(2200-nLinAlt,1410-nLinDir,2300-nLinAlt,1410-nLinDir)   //3
oRelATF:line(2200-nLinAlt,1560-nLinDir,2300-nLinAlt,1560-nLinDir)   //4
oRelATF:line(2200-nLinAlt,1725-nLinDir,2300-nLinAlt,1725-nLinDir)   //5
oRelATF:line(2200-nLinAlt,1825-nLinDir,2300-nLinAlt,1825-nLinDir)   //6   
oRelATF:line(2200-nLinAlt,2000-nLinDir,2300-nLinAlt,2000-nLinDir)   //7
oRelATF:line(2200-nLinAlt,2125-nLinDir,2300-nLinAlt,2125-nLinDir)   //8
oRelATF:line(2200-nLinAlt,2350-nLinDir,2300-nLinAlt,2350-nLinDir)   //9
oRelATF:line(2200-nLinAlt,2575-nLinDir,2300-nLinAlt,2575-nLinDir)   //10
oRelATF:line(2200-nLinAlt,2800-nLinDir,2300-nLinAlt,2800-nLinDir)   //11
oRelATF:line(2200-nLinAlt,3025-nLinDir,2300-nLinAlt,3025-nLinDir)   //12

If lFimRel
	ImpRodap2()
EndIf

RestArea(aSaveArea)
return
      
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบ Programa ณImpRodap2 บ Autor ณ Elton C.			 บ Data ณ  30/11/10      บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบ Desc.    ณ Impressao do rodape no final do relatorio (soma da coluna 11) บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ImpRodap2()

Local aSaveArea	:= GetArea()

oRelATF:FillRect({2300,2800,2400,3025},oBrR) 

oRelATF:Box(2300-nLinAlt,50-nLinDir,2400-nLinAlt,3150-nLinDir)
oRelATF:Say(2350-nLinAlt,500-nLinDir,STR0040,oFont08,620,,,2) //"Aumento das reintegra็๕es resultantes da reavalia็ใo: "

oRelATF:line(2300-nLinAlt,2800-nLinDir,2400-nLinAlt,2800-nLinDir)   //1
oRelATF:line(2300-nLinAlt,3025-nLinDir,2400-nLinAlt,3025-nLinDir)   //2    

RestArea(aSaveArea)
return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบ Programa ณDadosEmp  บ Autor ณ Elton C.	 		 บ Data ณ  30/11/10      บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบ Desc.    ณ Retorna os dados da empresa posicionada						 บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DadosEmp()
Local aSaveArea	:= GetArea()
Local aDadosEmp	:= {}

DbSelectArea("SM0")
DbSetOrder(1)
DbSeek(cEmpAnt+cFilAnt)
Aadd(aDadosEmp,ALLTRIM(SM0->M0_NOMECOM)) // Nome da Empresa
Aadd(aDadosEmp, SUBSTR(SM0->M0_CGC,1,9)) // Identifica็ใo Fiscal
Aadd(aDadosEmp, ALLTRIM(SM0->M0_DSCCNA) ) // Atividade principal	
Aadd(aDadosEmp, ALLTRIM(SM0->M0_COD_ATV) ) // Codigo Cae

                               
RestArea(aSaveArea)
Return aDadosEmp


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVldATFR3310  บAutor  ณElton C.          บFecha ณ  30/11/10   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida as perguntas do relatorio                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP 	                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VldATFR3310()

Local aSaveArea	:= GetArea()
Local lRet := .T.

If Empty(MV_PAR01)
	lRet := .F.
	Help(" ",1,"NOEXEC",,STR0042,1,0)	 //"Exercํcio nใo preenchido "
ElseIf Empty(MV_PAR02)
	lRet := .F.
	Help(" ",1,"NOPERIODIN",,STR0043,1,0)	 //"Perํodo inicial de tributa็ใo nใo preenchido"
ElseIf Empty(MV_PAR03)	
	lRet := .F.
	Help(" ",1,"NOPERIODFN",,STR0044,1,0)	 //"Perํodo final de tributa็ใo nใo preenchido "
EndIf

If Alltrim(Str(Year(MV_PAR02))) != Alltrim(MV_PAR01) 
	lRet := .F.
	Help(" ",1,"PERIODINC",,STR0045,1,0)	 //"Informe o perํodo de acordo com o exercํcio"
EndIf

RestArea(aSaveArea)
Return lRet     


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGeraDados บAutor  ณElton C.            บFecha ณ  30/11/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณBusca as informa็๕es do relatorio                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP 	                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GeraDados(lItemBaixado)

Local aSaveArea		:= GetArea()
Local cQuery		:= ""
Local cArq			:= ""

Default lItemBaixado 	:= .F.

cArq := GetNextAlias()	
		
cQuery := "SELECT N1_FILIAL, N1_GRUPO COL1, RTRIM(LTRIM(N1_DESCRIC)) COL2, RTRIM(LTRIM(N1_CBASE)) COL17, N1_AQUISIC COL3, N1_PRZDEPR COL9,N1_ESTUSO, "+Chr(13)
cQuery += "N3_FILIAL, N3_DINDEPR COL4, "+Chr(13)

// De exercicios anteriores
cQuery += " ( SELECT SUM(N4_VLROC1) "+Chr(13)
cQuery += " FROM " + RetSqlName("SN4") + " N4SUB1 "+Chr(13)
cQuery += " WHERE N4SUB1.D_E_L_E_T_ = ' ' "+Chr(13)
cQuery += " AND N4SUB1.N4_FILIAL = N1.N1_FILIAL "+Chr(13)
cQuery += " AND N4SUB1.N4_CBASE = N1.N1_CBASE "+Chr(13)
cQuery += " AND N4SUB1.N4_ITEM = N1.N1_ITEM "+Chr(13)
cQuery += " AND N4_DATA <= '" + DTOS(MV_PAR02) + "'"+Chr(13)
cQuery += " AND N4_OCORR IN ('06','07') " +Chr(13)
cQuery += " AND N4_TIPOCNT IN ('2','4') ) COL10, " +Chr(13)

// Taxa do Exercicio
cQuery += " N3_TXDEPR1 COL11, "+Chr(13)

// Valor Do exercicio
cQuery += " ( SELECT SUM(N4_VLROC1) "+Chr(13)
cQuery += " FROM " + RetSqlName("SN4") + " N4SUB1 "+Chr(13)
cQuery += " WHERE N4SUB1.D_E_L_E_T_ = ' ' "+Chr(13)
cQuery += " AND N4SUB1.N4_FILIAL = N1.N1_FILIAL "+Chr(13)
cQuery += " AND N4SUB1.N4_CBASE = N1.N1_CBASE "+Chr(13)
cQuery += " AND N4SUB1.N4_ITEM = N1.N1_ITEM "+Chr(13)
cQuery += " AND N4SUB1.N4_DATA BETWEEN '"+DTOS(MV_PAR02)+"' AND '"+DTOS(MV_PAR03)+"' "+Chr(13)
cQuery += " AND N4_OCORR IN ('06','07') " +Chr(13)
cQuery += " AND N4_TIPOCNT IN ('2','4') ) COL12, " +Chr(13)

cQuery += "(SELECT SUM(N3_VORIG1) FROM "+RetSqlName("SN3")+" N3SUB1 "+Chr(13)
cQuery += " WHERE N3SUB1.D_E_L_E_T_ = ' ' "+Chr(13)
cQuery += " AND N3SUB1.N3_FILIAL = N1.N1_FILIAL "+Chr(13)

If lItemBaixado
	cQuery += " AND N3SUB1.N3_BAIXA = '1' "+Chr(13)
	cQuery += " AND N3SUB1.N3_DTBAIXA BETWEEN '"+DTOS(MV_PAR02)+"' AND '"+DTOS(MV_PAR03)+"' "+Chr(13)
Else
	cQuery += " AND N3SUB1.N3_BAIXA != '1' "+Chr(13)
EndIf

cQuery += " AND N3SUB1.N3_CBASE = N1.N1_CBASE "+Chr(13)
cQuery += " AND N3SUB1.N3_ITEM = N1.N1_ITEM "+Chr(13)
cQuery += " AND N3SUB1.N3_FIMDEPR > '19871231' " +Chr(13)
cQuery += " AND N3SUB1.N3_TIPREAV NOT IN ('PT-77-126', 'PT-78-403','PT-82-024','PT-82-219','PT-84-143','PT-84-388','PT-85-278', 'PT-86-118', 'PT-88-111') " +Chr(13)
cQuery += " AND N3SUB1.N3_TIPO IN('01','02') "+Chr(13)
cQuery += " )  COL5, "+Chr(13)

cQuery += "(SELECT N3_VORIG1 FROM "+RetSqlName("SN3")+" N3SUB2 "+Chr(13)
cQuery += "	WHERE N3SUB2.D_E_L_E_T_ = ' '"+Chr(13)
cQuery += "	AND N3SUB2.N3_FILIAL = N1.N1_FILIAL "+Chr(13)

If lItemBaixado
	cQuery += " AND N3SUB2.N3_BAIXA = '1' "+Chr(13)
	cQuery += " AND N3SUB2.N3_DTBAIXA BETWEEN '"+DTOS(MV_PAR02)+"' AND '"+DTOS(MV_PAR03)+"' "+Chr(13)
Else
	cQuery += " AND N3SUB2.N3_BAIXA != '1' "+Chr(13)
EndIf

cQuery += "	AND N3SUB2.N3_CBASE = N1.N1_CBASE "+Chr(13)
cQuery += "	AND N3SUB2.N3_ITEM = N1.N1_ITEM  "+Chr(13)
cQuery += "	AND N3SUB2.N3_TIPO = '02' "+Chr(13)
cQuery += "	AND N3SUB2.N3_FIMDEPR > '19871231' "+Chr(13)
cQuery += "	AND N3SUB2.N3_TIPREAV = 'PT-88-111' "+Chr(13)
cQuery += "	AND N3SUB2.N3_SEQ = (SELECT MAX(N3_SEQ) FROM "+ RetSqlName("SN3")+" N3SUBSUB2 WHERE N3_FILIAL = N1_FILIAL "+Chr(13)
cQuery += "					AND N3SUBSUB2.D_E_L_E_T_ = ' ' "+Chr(13)

If lItemBaixado
	cQuery += " 			AND N3SUBSUB2.N3_BAIXA = '1' "+Chr(13)
	cQuery += "             AND N3SUBSUB2.N3_DTBAIXA BETWEEN '"+DTOS(MV_PAR02)+"' AND '"+DTOS(MV_PAR03)+"' "+Chr(13)
Else
	cQuery += " 			AND N3SUBSUB2.N3_BAIXA != '1' "+Chr(13)
EndIf

cQuery += " 				AND N3SUBSUB2.N3_CBASE = N1.N1_CBASE "+Chr(13)
cQuery += " 				AND N3SUBSUB2.N3_ITEM = N1.N1_ITEM  "+Chr(13)
cQuery += " 				AND N3SUBSUB2.N3_TIPO = '02' "+Chr(13)
cQuery += "					AND N3SUBSUB2.N3_FIMDEPR > '19871231' "+Chr(13)
cQuery += " 				AND N3SUBSUB2.N3_TIPREAV = 'PT-88-111' "+Chr(13)
cQuery += "					) "+Chr(13)
cQuery += "	) COL8, "    +Chr(13)


cQuery += "( (1/((SELECT N3_TXDEPR1 FROM "+ RetSqlName("SN3")+" N3SUB3 "+Chr(13)
cQuery += " WHERE N3SUB3.D_E_L_E_T_ = ' '  "+Chr(13)
cQuery += " AND N3SUB3.N3_FILIAL = N1.N1_FILIAL  "+Chr(13)

If lItemBaixado
	cQuery += " AND N3SUB3.N3_BAIXA = '1' "+Chr(13)
	cQuery += " AND N3SUB3.N3_DTBAIXA BETWEEN '"+DTOS(MV_PAR02)+"' AND '"+DTOS(MV_PAR03)+"' "+Chr(13)
Else
	cQuery += " AND N3SUB3.N3_BAIXA != '1' "+Chr(13)
EndIf

cQuery += " AND N3SUB3.N3_CBASE = N1.N1_CBASE "+Chr(13)
cQuery += " AND N3SUB3.N3_ITEM = N1.N1_ITEM "+Chr(13)
cQuery += "	AND N3SUB3.N3_FIMDEPR > '19871231' "+Chr(13)
cQuery += " AND N3SUB3.N3_TIPO = '01') + (SELECT N3_TXDEPR1 FROM "+RetSqlName("SN3")+" N3SUBSUB3 "+Chr(13)
cQuery += "				WHERE N3SUBSUB3.D_E_L_E_T_ = ' ' "+Chr(13)
cQuery += "				AND N3SUBSUB3.N3_FILIAL = N1.N1_FILIAL  "+Chr(13)

If lItemBaixado
	cQuery += " 		AND N3SUBSUB3.N3_BAIXA = '1' "+Chr(13)
	cQuery += "         AND N3SUBSUB3.N3_DTBAIXA BETWEEN '"+DTOS(MV_PAR02)+"' AND '"+DTOS(MV_PAR03)+"' "+Chr(13)
Else
	cQuery += " 		AND N3SUBSUB3.N3_BAIXA != '1' "+Chr(13)
EndIf

cQuery += "				AND N3SUBSUB3.N3_CBASE = N1.N1_CBASE "+Chr(13)
cQuery += "				AND N3SUBSUB3.N3_ITEM = N1.N1_ITEM "+Chr(13)
cQuery += "				AND N3SUBSUB3.N3_TIPO = '02' "+Chr(13)
cQuery += "				AND N3SUBSUB3.N3_FIMDEPR > '19871231' " +Chr(13)
cQuery += "				AND N3SUBSUB3.N3_SEQ = (SELECT MAX(N3_SEQ) FROM "+ RetSqlName("SN3")+" N3SUBSUBSUB3 "+Chr(13)
cQuery += "										WHERE N3SUBSUBSUB3.N3_FILIAL = N1.N1_FILIAL " +Chr(13)
cQuery += "										AND N3SUBSUBSUB3.D_E_L_E_T_ = ' ' "+Chr(13)

If lItemBaixado
	cQuery += " 								AND N3SUBSUBSUB3.N3_BAIXA = '1' "+Chr(13)
	cQuery += "                                 AND N3SUBSUBSUB3.N3_DTBAIXA BETWEEN '"+DTOS(MV_PAR02)+"' AND '"+DTOS(MV_PAR03)+"' "+Chr(13)
Else
	cQuery += " 								AND N3SUBSUBSUB3.N3_BAIXA != '1' "+Chr(13)
EndIf

cQuery += "										AND N3SUBSUBSUB3.N3_CBASE = N1.N1_CBASE "+Chr(13)
cQuery += "										AND N3SUBSUBSUB3.N3_ITEM = N1.N1_ITEM "+Chr(13)
cQuery += "										AND N3SUBSUBSUB3.N3_FIMDEPR > '19871231' "+Chr(13)
cQuery += "										AND N3SUBSUBSUB3.N3_TIPO = '02' "+Chr(13)
cQuery += "								) "+Chr(13)
cQuery += "					)))*100	 "+Chr(13)
cQuery += " )  COL8xx, "+Chr(13)

cQuery += " (SELECT (((100/N3_TXDEPR1)-(100/NG_TXDEPR1))* N3_TXDEPR1) TXPERDA FROM "+ RetSqlName("SN3")+" N3SUB4 "+Chr(13)
cQuery += " WHERE N3SUB4.D_E_L_E_T_ = ' ' "+Chr(13)
cQuery += " AND N3SUB4.N3_FILIAL = N1.N1_FILIAL "+Chr(13)

If lItemBaixado
	cQuery += " AND N3SUB4.N3_BAIXA = '1' "+Chr(13)
	cQuery += " AND N3SUB4.N3_DTBAIXA BETWEEN '"+DTOS(MV_PAR02)+"' AND '"+DTOS(MV_PAR03)+"' "+Chr(13)
Else
	cQuery += " AND N3SUB4.N3_BAIXA != '1' "+Chr(13)
EndIf

cQuery += " AND N3SUB4.N3_CBASE = N1.N1_CBASE "+Chr(13)
cQuery += " AND N3SUB4.N3_ITEM = N1.N1_ITEM "+Chr(13)
cQuery += " AND N3SUB4.N3_FIMDEPR > '19871231' "+Chr(13)
cQuery += " AND N3SUB4.N3_TIPO = '01' "+Chr(13)
cQuery += " AND N3SUB4.N3_TXDEPR1 < NG.NG_TXDEPR1 "+Chr(13)
cQuery += " )  COL16, "+Chr(13)

// coluna 06 - das reavalia็๕es anteriores -> dec lei 'PT-77-126'
cQuery += "(SELECT SUM(N3_VORIG1) FROM "+ RetSqlName("SN3")+" N3SUB2 "+Chr(13)
cQuery += " WHERE N3SUB2.D_E_L_E_T_ = ' ' "+Chr(13)
cQuery += "	AND N3SUB2.N3_FILIAL = N1.N1_FILIAL "+Chr(13)

If lItemBaixado
	cQuery += " AND N3SUB2.N3_BAIXA = '1' "+Chr(13)
	cQuery += " AND N3SUB2.N3_DTBAIXA BETWEEN '"+DTOS(MV_PAR02)+"' AND '"+DTOS(MV_PAR03)+"' "+Chr(13)
Else
	cQuery += " AND N3SUB2.N3_BAIXA <> '1' "+Chr(13)
EndIf

cQuery += " AND N3SUB2.N3_CBASE = N1.N1_CBASE "+Chr(13)
cQuery += " AND N3SUB2.N3_ITEM = N1.N1_ITEM  "+Chr(13)
//		cQuery += "	AND ((N3SUB2.N3_FIMDEPR = '') OR (N3SUB2.N3_FIMDEPR >= '19971231'))  "
cQuery += "	AND N3SUB2.N3_TIPO = '02' "+Chr(13)
cQuery += " AND N3SUB2.N3_TIPREAV IN('PT-77-126') "+Chr(13)
cQuery += "	) COL6, "+Chr(13)

// coluna 07 - das reavalia็๕es anteriores -> dec lei 'PT-78-403','PT-82-024','PT-82-219','PT-84-143','PT-84-388','PT-85-278'
cQuery += "(SELECT SUM(N3_VORIG1) FROM "+ RetSqlName("SN3")+" N3SUB2 "+Chr(13)
cQuery += " WHERE N3SUB2.D_E_L_E_T_ = ' ' "+Chr(13)
cQuery += "	AND N3SUB2.N3_FILIAL = N1.N1_FILIAL "+Chr(13)

If lItemBaixado
	cQuery += " AND N3SUB2.N3_BAIXA = '1' "+Chr(13)
	cQuery += " AND N3SUB2.N3_DTBAIXA BETWEEN '"+DTOS(MV_PAR02)+"' AND '"+DTOS(MV_PAR03)+"' "+Chr(13)
Else
	cQuery += " AND N3SUB2.N3_BAIXA <> '1' "+Chr(13)
EndIf

cQuery += " AND N3SUB2.N3_CBASE = N1.N1_CBASE "+Chr(13)
cQuery += " AND N3SUB2.N3_ITEM = N1.N1_ITEM  "+Chr(13)
//		cQuery += "	AND ((N3SUB2.N3_FIMDEPR = '') OR (N3SUB2.N3_FIMDEPR >= '19971231'))  "
cQuery += "	AND N3SUB2.N3_TIPO = '02' "+Chr(13)
cQuery += " AND N3SUB2.N3_TIPREAV IN('PT-78-403','PT-82-024','PT-82-219','PT-84-143','PT-84-388','PT-85-278') "+Chr(13)
cQuery += "	) COL7," +Chr(13)

cQuery += " NG_GRUPO,NG_TXDEPR1 FROM "+ RetSqlName("SN1")+" N1 , " +RetSqlName("SN3")+" N3, "+RetSqlName("SNG")+ " NG "+Chr(13)
cQuery += "	WHERE N1.N1_FILIAL = '"+xFilial("SN1")+"' "+Chr(13)
cQuery += "	AND N3.N3_FILIAL = N1.N1_FILIAL "+Chr(13)
cQuery += "	AND N1.D_E_L_E_T_ = ' ' "+Chr(13)
cQuery += "	AND N3.D_E_L_E_T_ = ' ' "+Chr(13)
cQuery += "	AND NG.D_E_L_E_T_ = ' ' "+Chr(13)

If lItemBaixado
	cQuery += " AND N3.N3_BAIXA = '1' "+Chr(13)
	cQuery += " AND N3.N3_DTBAIXA BETWEEN '"+DTOS(MV_PAR02)+"' AND '"+DTOS(MV_PAR03)+"' "+Chr(13)
Else
	cQuery += " AND N3.N3_BAIXA != '1' "+Chr(13)
EndIf

cQuery += "	AND N3.N3_CBASE = N1.N1_CBASE "+Chr(13)
cQuery += "	AND N3.N3_ITEM = N1.N1_ITEM "+Chr(13)
cQuery += "	AND N3.N3_TIPO = '01' "+Chr(13)
cQuery += "	AND N3_FIMDEPR > '19871231' AND N3.N3_FIMDEPR <> '' "+Chr(13)
cQuery += "	AND NG.NG_FILIAL = N1.N1_FILIAL "+Chr(13)
cQuery += "	AND NG.NG_GRUPO = N1.N1_GRUPO "   +Chr(13)
cQuery += " AND EXISTS(SELECT N3_TIPREAV FROM "+RetSqlName("SN3")+" N3N3 "+Chr(13)
cQuery += "				WHERE N3N3.D_E_L_E_T_ = ' ' "+Chr(13)
cQuery += "				AND N3N3.N3_FILIAL = N1.N1_FILIAL "+Chr(13)

If lItemBaixado
	cQuery += " 		AND N3N3.N3_BAIXA = '1' "+Chr(13)
	cQuery += "         AND N3N3.N3_DTBAIXA BETWEEN '"+DTOS(MV_PAR02)+"' AND '"+DTOS(MV_PAR03)+"' "+Chr(13)
Else
	cQuery += " 		AND N3N3.N3_BAIXA <> '1' "+Chr(13)
EndIf

cQuery += "				AND N3N3.N3_CBASE = N1.N1_CBASE " +Chr(13)
cQuery += "				AND N3N3.N3_ITEM = N1.N1_ITEM "+Chr(13)
cQuery += "				AND N3.N3_FIMDEPR <> '' "+Chr(13)
cQuery += "				AND N3.N3_FIMDEPR > '19871231' "+Chr(13)
cQuery += " 			AND N3N3.N3_TIPREAV = 'PT-88-111' "+Chr(13)
cQuery += " 			)"  +Chr(13)

cQuery += " ORDER BY N1.N1_GRUPO , N1.N1_AQUISIC, N3.N3_DINDEPR "+Chr(13)
MemoWrite('atfr3310_2.Sql', cQuery )

cQuery := ChangeQuery(cQuery)

If ( Select ( cArq ) <> 0 )
	dbSelectArea ( cArq )
	dbCloseArea ()
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cArq,.T.,.F.)   

TcSetField(cArq,"COL5" ,"N",TamSX3("N3_VORIG1")[1],TamSX3("N3_VORIG1")[2])   
TcSetField(cArq,"COL10" ,"N",TamSX3("N4_VLROC1")[1],TamSX3("N4_VLROC1")[2])  
TcSetField(cArq,"COL12" ,"N",TamSX3("N4_VLROC1")[1],TamSX3("N4_VLROC1")[2])  




RestArea(aSaveArea)
Return(cArq) 
