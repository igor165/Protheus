#INCLUDE "ATFR3311.ch"
#INCLUDE "PROTHEUS.CH" 
#INCLUDE "COLORS.CH" 
  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออปฑฑ
ฑฑบ Programa ณ ATFR3317 บ Autor ณ Elton C 			 บ Data ณ  29/11/10    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออนฑฑ
ฑฑบ Desc.    ณ Mapa Fiscal modelo 33.11                                    บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ATFR3311() 

Local aSaveArea		:= GetArea()
Local cPerg			:= "ATR3311"

Private cMoedATF	:= ""
Private cExerc		:= ""
Private oRelATF

//Parametros de perguntas para o relatorio
//+-----------------------------------------------------+
//| mv_par01 - Exercicio ? 								|
//| mv_par02 - Data de   ? 								|
//| mv_par03 - Data Ate  ?                              |
//| mv_par04 - Imprime Abatidos ? 33.17 		        |
//+-----------------------------------------------------+

If Pergunte(cPerg,.T.)                
	cMoedATF := GetMV("MV_ATFMOED")
	oRelATF	:= tNewMsprinter():New(STR0001 + " - " + STR0002 + "33.11") //"MAPA"###"MODELO" //"MAPA"###"MODELO"
	oRelATF:SetLandscape()
	If VldATFR3311()
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

Local nTotCol5   	:= 0
Local nTotCol6		:= 0
Local nTotCol9		:= 0
Local nTotCol11		:= 0
Local nTotCol12		:= 0
Local nTotCol13		:= 0
Local nTotCol15		:= 0

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
		nCol6		:= (cArqTemp)->COL6 + nCol5
		nCol7		:= Iif((cArqTemp)->N1_ESTUSO == 'S',(cArqTemp)->COL7, "" )
		nCol8		:= (cArqTemp)->COL8
		nCol9		:= (cArqTemp)->COL9
		nCol10		:= (cArqTemp)->COL10
		nCol11		:= (cArqTemp)->COL11
		nCol12		:= nCol9 + nCol11
		nCol13		:= nCol6 - nCol12
		nCol14		:= (cArqTemp)->COL14
      
		oRelATF:Say(960+nContLinha,070,cCol1,oFont06) // Codigo do grupo de Bens - Coluna 1
		oRelATF:Say(960+nContLinha,300,cCol2,oFont06) // Descri็ใo do grupo de Bens - Coluna 2
		oRelATF:Say(960+nContLinha,1070,transform(nCol3,"9999"),oFont06) // Ano de Aquisi็ใo - Coluna 3
		oRelATF:Say(960+nContLinha,1195,transform(nCol4,"9999"),oFont06) // Ano de inicio da utiliza็ใo - Coluna 4
		oRelATF:Say(960+nContLinha,1320,transform(nCol5,"@E 999,999,999,999.99"),oFont06) //  - De Aquisi็ใo, produ็ใo ou da ultima reavalia็ใo efetuda - Coluna 5
		oRelATF:Say(960+nContLinha,1545,transform(nCol6,"@E 999,999,999,999.99"),oFont06) // - De Reavalia็ใo 31/98 - Coluna 6
		oRelATF:Say(960+nContLinha,1770,transform(nCol7,"@E 999" ),oFont06) // - Anos de utilizadade - Coluna 7
		oRelATF:Say(960+nContLinha,1895,transform(nCol8,"@E 999.99"),oFont06) // - Taxa media - Coluna 8
		oRelATF:Say(960+nContLinha,2020,transform(nCol9,"@E 999,999,999,999.99"),oFont06) // - de exercicios anteriores - Coluna 9
		oRelATF:Say(960+nContLinha,2245,transform(nCol10,"@E 999.99"),oFont06) // - Taxa - Coluna 10
		oRelATF:Say(960+nContLinha,2370,transform(nCol11,"@E 999,999,999,999.99"),oFont06) // - Valores - Coluna 11
		oRelATF:Say(960+nContLinha,2595,transform(nCol12,"@E 999,999,999,999.99"),oFont06) // - Acumuladas - Coluna 12
		oRelATF:Say(960+nContLinha,2820,transform(nCol13,"@E 999,999,999,999.99"),oFont06) // - Ativo imobilizado - Coluna 13
		oRelATF:Say(960+nContLinha,3045,transform(nCol14,"@E 999.99"),oFont06) // - Taxa acumulada - Coluna 14
		
		//Totalizadores por paginas
		nTotCol5   	+= nCol5
		nTotCol6	+= nCol6
		nTotCol9	+= nCol9
		nTotCol11	+= nCol11
		nTotCol12	+= nCol12
		nTotCol13	+= nCol13
		nTotCol15	+= nCol11
		
		
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
		oRelATF:Say(2250,1320,transform(nTotCol5,"@E 999,999,999,999.99"),oFont06)//1- Total Coluna 5
		oRelATF:Say(2250,1545,transform(nTotCol6,"@E 999,999,999,999.99"),oFont06)//2- Total Coluna 6
		oRelATF:Say(2250,2020,transform(nTotCol9,"@E 999,999,999,999.99"),oFont06)//3- Total Coluna 9
		oRelATF:Say(2250,2370,transform(nTotCol11,"@E 999,999,999,999.99"),oFont06)//4- Total Coluna 11
		oRelATF:Say(2250,2595,transform(nTotCol12,"@E 999,999,999,999.99"),oFont06)//5- Total Coluna 12
		oRelATF:Say(2250,2820,transform(nTotCol13,"@E 999,999,999,999.99"),oFont06)//6- Total Coluna 13

		If lFimRel
			oRelATF:Say(2350,2820,transform(nTotCol15,"@E 999,999,999,999.99"),oFont06)//7- Total Coluna k(11)
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
ฑฑบ Desc.    ณ Impressao do layout		                                   บฑฑ
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
oRelATF :Say(235-nLinAlt,1486-nLinDir,STR0006,oFont06,2100,,,2)  //"ao abrigo do Decreto-Lei nบ 49/91, de 25 de Janeiro"
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
oRelATF :Say(300-nLinAlt,2840-nLinDir,"33.11",oFont28N)

//Colunas sem reparti็๕es (Linha Vertical) 
oRelATF :Box(520-nLinAlt,50-nLinDir,2200-nLinAlt,3150-nLinDir) 
oRelATF :line(940-nLinAlt,50-nLinDir,940-nLinAlt,3150-nLinDir)	//horiz
 
oRelATF :line(520-nLinAlt,280-nLinDir,2200-nLinAlt,280-nLinDir)     //1
oRelATF :line(520-nLinAlt,1050-nLinDir,2200-nLinAlt,1050-nLinDir)   //2 
oRelATF :line(520-nLinAlt,1300-nLinDir,2200-nLinAlt,1300-nLinDir)   //3 
oRelATF :line(520-nLinAlt,1750-nLinDir,2200-nLinAlt,1750-nLinDir)   //4 
oRelATF :line(520-nLinAlt,1875-nLinDir,2200-nLinAlt,1875-nLinDir)   //5 
oRelATF :line(520-nLinAlt,2000-nLinDir,2200-nLinAlt,2000-nLinDir)   //6 
oRelATF :line(520-nLinAlt,2800-nLinDir,2200-nLinAlt,2800-nLinDir)   //7 
oRelATF :line(520-nLinAlt,3025-nLinDir,2200-nLinAlt,3025-nLinDir)   //8 

//Colunas com reparti็๕es (Linha horizontal)
oRelATF :line(590-nLinAlt,1050-nLinDir,590-nLinAlt,1750-nLinDir)	//1
oRelATF :line(590-nLinAlt,2000-nLinDir,590-nLinAlt,2800-nLinDir)	//2
oRelATF :line(660-nLinAlt,2225-nLinDir,660-nLinAlt,2575-nLinDir)	//3

// Coluna com reparti็๕es (Linha Vertical)
oRelATF :line(590-nLinAlt,1175-nLinDir,2200-nLinAlt,1175-nLinDir)   //1 
oRelATF :line(590-nLinAlt,1525-nLinDir,2200-nLinAlt,1525-nLinDir)   //2   
oRelATF :line(590-nLinAlt,2225-nLinDir,2200-nLinAlt,2225-nLinDir)   //3   
oRelATF :line(660-nLinAlt,2350-nLinDir,2200-nLinAlt,2350-nLinDir)   //4   
oRelATF :line(590-nLinAlt,2575-nLinDir,2200-nLinAlt,2575-nLinDir)   //5    

//Descri็ใo das colunas (cabe็alho das colunas)
aPalavras := ATFBrkStr(STR0018,20,5)	 //"C๓digo de acordo com as tabelas anexas ao Decreto Regulamentar n.บ 2/90, de 12 de Janeiro"
oRelATF:Say(700-nLinAlt,165-nLinDir,aPalavras[1],oFont06,620,,,2) 
oRelATF:Say(740-nLinAlt,165-nLinDir,aPalavras[2],oFont06,620,,,2)
oRelATF:Say(780-nLinAlt,165-nLinDir,aPalavras[3],oFont06,620,,,2)
oRelATF:Say(820-nLinAlt,165-nLinDir,aPalavras[4],oFont06,620,,,2)
oRelATF:Say(860-nLinAlt,165-nLinDir,aPalavras[5],oFont06,620,,,2)

oRelATF:Say(700-nLinAlt,380-nLinDir,STR0019,oFont08)  //"Descri็ใo dos  elementos do activo imobilizado corp๓reo"

oRelATF:Say(560-nLinAlt,1160-nLinDir,STR0020,oFont08)  //"Ano"

aPalavras := ATFBrkStr(STR0021,5,2)	 //"Aquisi- ็ใo"
oRelATF:Say(700-nLinAlt,1120-nLinDir,aPalavras[1],oFont08,620,,,2) 
oRelATF:Say(740-nLinAlt,1120-nLinDir,aPalavras[2],oFont08,620,,,2) 

aPalavras := ATFBrkStr(STR0022,5,4)	 //"Inicio de utili- za็ใo"
oRelATF:Say(700-nLinAlt,1235-nLinDir,aPalavras[1],oFont08,620,,,2) 
oRelATF:Say(740-nLinAlt,1235-nLinDir,aPalavras[2],oFont08,620,,,2) 
oRelATF:Say(780-nLinAlt,1235-nLinDir,aPalavras[3],oFont08,620,,,2)
oRelATF:Say(820-nLinAlt,1235-nLinDir,aPalavras[4],oFont08,620,,,2)

oRelATF:Say(560-nLinAlt,1520-nLinDir,STR0023,oFont08,620,,,2)  //"Valores do activo imobilizado"

aPalavras := ATFBrkStr(STR0024,20,5)	 //"De aquisi็ใo, produ็ใo ou da ๚ltima reavalia็ใo efetuada"
oRelATF:Say(700-nLinAlt,1405-nLinDir,aPalavras[1],oFont08,620,,,2) 
oRelATF:Say(740-nLinAlt,1405-nLinDir,aPalavras[2],oFont08,620,,,2) 
oRelATF:Say(780-nLinAlt,1405-nLinDir,aPalavras[3],oFont08,620,,,2) 
oRelATF:Say(820-nLinAlt,1405-nLinDir,aPalavras[4],oFont08,620,,,2) 

aPalavras := ATFBrkStr(STR0025,20,3)	 //"De reavalia็ใo ao abrigo do Dec.-Lei nบ 49/91"
oRelATF:Say(700-nLinAlt,1630-nLinDir,aPalavras[1],oFont08,620,,,2) 
oRelATF:Say(740-nLinAlt,1630-nLinDir,aPalavras[2],oFont08,620,,,2)
oRelATF:Say(780-nLinAlt,1630-nLinDir,aPalavras[3],oFont08,620,,,2)

aPalavras := ATFBrkStr(STR0026,5,8)	 //"N๚mero de anos de utilidade esperada"
oRelATF:Say(620-nLinAlt,1810-nLinDir,aPalavras[1],oFont08,620,,,2) 
oRelATF:Say(660-nLinAlt,1810-nLinDir,aPalavras[2],oFont08,620,,,2) 
oRelATF:Say(700-nLinAlt,1810-nLinDir,aPalavras[3],oFont08,620,,,2)
oRelATF:Say(740-nLinAlt,1810-nLinDir,aPalavras[4],oFont08,620,,,2)
oRelATF:Say(780-nLinAlt,1810-nLinDir,aPalavras[5],oFont08,620,,,2)
oRelATF:Say(820-nLinAlt,1810-nLinDir,aPalavras[6],oFont08,620,,,2) 

aPalavras := ATFBrkStr(STR0027,5,8)	 //"Taxa m้dia [alํnea b) do n.บ 2 do art. 4.บ ]"
oRelATF:Say(620-nLinAlt,1935-nLinDir,aPalavras[1],oFont08,620,,,2) 
oRelATF:Say(660-nLinAlt,1935-nLinDir,aPalavras[2],oFont08,620,,,2) 
oRelATF:Say(700-nLinAlt,1935-nLinDir,aPalavras[3],oFont08,620,,,2)
oRelATF:Say(740-nLinAlt,1935-nLinDir,aPalavras[4],oFont08,620,,,2)
oRelATF:Say(780-nLinAlt,1935-nLinDir,aPalavras[5],oFont08,620,,,2)
oRelATF:Say(820-nLinAlt,1935-nLinDir,aPalavras[6],oFont08,620,,,2)
oRelATF:Say(860-nLinAlt,1935-nLinDir,aPalavras[7],oFont08,620,,,2)
oRelATF:Say(900-nLinAlt,1935-nLinDir,aPalavras[8],oFont08,620,,,2)


oRelATF :Say(560-nLinAlt,2395-nLinDir,STR0028,oFont08,620,,,2)        //"Reintegra็๕es actualizadas corrigidas"

aPalavras := ATFBrkStr(STR0029,13,2)	 //"De exercํcios  anteriores "
oRelATF:Say(700-nLinAlt,2115-nLinDir,aPalavras[1],oFont08,620,,,2) 
oRelATF:Say(740-nLinAlt,2115-nLinDir,aPalavras[2],oFont08,620,,,2) 

oRelATF :Say(630-nLinAlt,2395-nLinDir,STR0030,oFont08,620,,,2)  //"Do exercํcio"

oRelATF :Say(700-nLinAlt,2285-nLinDir,STR0031,oFont08,620,,,2)  //"Taxa"

oRelATF :Say(700-nLinAlt,2460-nLinDir,STR0032,oFont08,620,,,2)  //"Valores"

oRelATF :Say(700-nLinAlt,2680-nLinDir,STR0033,oFont08,620,,,2)  //"Acumuladas"

aPalavras := ATFBrkStr(STR0034,18,2)	 //"Activo imobilizado (valores lํquidos)"
oRelATF :Say(700-nLinAlt,2915-nLinDir,aPalavras[1],oFont08,620,,,2) 
oRelATF :Say(740-nLinAlt,2915-nLinDir,aPalavras[2],oFont08,620,,,2)     

aPalavras := ATFBrkStr(STR0035,8,4)	 //"Taxas perdidas acumula-  das"
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
 
oRelATF:FillRect({2200,1300,2300,1750},oBrR)
oRelATF:FillRect({2200,2000,2300,2225},oBrR)
oRelATF:FillRect({2200,2350,2300,3025},oBrR)
 
oRelATF:Box(2200-nLinAlt,50-nLinDir,2300-nLinAlt,3150-nLinDir)
oRelATF:Say(2250-nLinAlt,500-nLinDir,STR0036,oFont08,620,,,2)  //"Total geral ou a transportar:"

// Coluna com reparti็๕es (Linha Vertical)
oRelATF:line(2200-nLinAlt,1300-nLinDir,2300-nLinAlt,1300-nLinDir)   //1
oRelATF:line(2200-nLinAlt,1525-nLinDir,2300-nLinAlt,1525-nLinDir)   //2
oRelATF:line(2200-nLinAlt,1750-nLinDir,2300-nLinAlt,1750-nLinDir)   //3
oRelATF:line(2200-nLinAlt,2000-nLinDir,2300-nLinAlt,2000-nLinDir)   //4
oRelATF:line(2200-nLinAlt,2225-nLinDir,2300-nLinAlt,2225-nLinDir)   //5
oRelATF:line(2200-nLinAlt,2350-nLinDir,2300-nLinAlt,2350-nLinDir)   //6
oRelATF:line(2200-nLinAlt,2575-nLinDir,2300-nLinAlt,2575-nLinDir)   //7
oRelATF:line(2200-nLinAlt,2800-nLinDir,2300-nLinAlt,2800-nLinDir)   //8
oRelATF:line(2200-nLinAlt,3025-nLinDir,2300-nLinAlt,3025-nLinDir)   //9

If lFimRel
	ImpRodap2()
EndIf

RestArea(aSaveArea)
return
      
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบ Programa ณImpRodap2 บ Autor ณ Cristina Barroso   บ Data ณ  04/09/09      บฑฑ
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
oRelATF:Say(2350-nLinAlt,500-nLinDir,STR0037,oFont08,620,,,2) //"Aumento das reintegra็๕es resultantes da reavalia็ใo: "

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
ฑฑบPrograma  ณVldATFR3311 บAutor  ณElton C.          บFecha ณ  30/11/10   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida as perguntas do relatorio                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP 	                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VldATFR3311()

Local aSaveArea	:= GetArea()
Local lRet := .T.

If Empty(MV_PAR01)
	lRet := .F.
	Help(" ",1,"NOEXEC",,STR0038,1,0)	 //"Exercํcio nใo preenchido "
ElseIf Empty(MV_PAR02)
	lRet := .F.
	Help(" ",1,"NOPERIODIN",,STR0039,1,0)	 //"Perํodo inicial de tributa็ใo nใo preenchido"
ElseIf Empty(MV_PAR03)	
	lRet := .F.
	Help(" ",1,"NOPERIODFN",,STR0040,1,0)	 //"Perํodo final de tributa็ใo nใo preenchido "
EndIf

If Alltrim(Str(Year(MV_PAR02))) != Alltrim(MV_PAR01) 
	lRet := .F.
	Help(" ",1,"PERIODINC",,STR0041,1,0)	 //"Informe o perํodo de acordo com o exercํcio"
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
			
	cQuery := "SELECT N1_FILIAL, N1_GRUPO COL1, RTRIM(LTRIM(N1_DESCRIC)) COL2, RTRIM(LTRIM(N1_CBASE)) COL17, N1_AQUISIC COL3, N1_PRZDEPR COL7,N1_ESTUSO, "+Chr(13)
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
	cQuery += " AND N4_TIPOCNT IN ('2','4') ) COL9, " +Chr(13)
	
	// Taxa do Exercicio
	cQuery += " N3_TXDEPR1 COL10, "+Chr(13)
	
	// Valor Do exercicio
	cQuery += " ( SELECT SUM(N4_VLROC1) "+Chr(13)
	cQuery += " FROM " + RetSqlName("SN4") + " N4SUB1 "+Chr(13)
	cQuery += " WHERE N4SUB1.D_E_L_E_T_ = ' ' "+Chr(13)
	cQuery += " AND N4SUB1.N4_FILIAL = N1.N1_FILIAL "+Chr(13)
	cQuery += " AND N4SUB1.N4_CBASE = N1.N1_CBASE "+Chr(13)
	cQuery += " AND N4SUB1.N4_ITEM = N1.N1_ITEM "+Chr(13)
	cQuery += " AND N4SUB1.N4_DATA BETWEEN '"+DTOS(MV_PAR02)+"' AND '"+DTOS(MV_PAR03)+"' "+Chr(13)
	cQuery += " AND N4_OCORR IN ('06','07') " +Chr(13)
	cQuery += " AND N4_TIPOCNT IN ('2','4') ) COL11, " +Chr(13)
	
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
	cQuery += " AND N3SUB1.N3_FIMDEPR <= '19910125' " +Chr(13)
	cQuery += " AND N3SUB1.N3_TIPO IN('01','02') "+Chr(13)
	cQuery += "	AND N3SUB1.N3_TIPREAV NOT IN ( 'PT-91-049') "+Chr(13)
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
	cQuery += "	AND N3SUB2.N3_FIMDEPR <= '19910125' "+Chr(13)
	cQuery += "	AND N3SUB2.N3_TIPREAV = 'PT-91-049' "+Chr(13)
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
	cQuery += "					AND N3SUBSUB2.N3_FIMDEPR <= '19910125'"+Chr(13) 
	cQuery += " 				AND N3SUBSUB2.N3_TIPREAV = 'PT-91-049' "+Chr(13)
	cQuery += "					) "+Chr(13)
	cQuery += "	) COL6, "    +Chr(13)
	
	
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
	cQuery += "	AND N3SUB3.N3_FIMDEPR <= '19910125' "+Chr(13)
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
	cQuery += "				AND N3SUBSUB3.N3_FIMDEPR <= '19910125' "+Chr(13)
	cQuery += "				AND N3SUBSUB3.N3_SEQ = (SELECT MAX(N3_SEQ) FROM "+ RetSqlName("SN3")+" N3SUBSUBSUB3 "+Chr(13)
	cQuery += "										WHERE N3SUBSUBSUB3.N3_FILIAL = N1.N1_FILIAL "+Chr(13)
	cQuery += "										AND N3SUBSUBSUB3.D_E_L_E_T_ = ' ' "+Chr(13)

	If lItemBaixado
		cQuery += " 								AND N3SUBSUBSUB3.N3_BAIXA = '1' "+Chr(13)
		cQuery += "                                 AND N3SUBSUBSUB3.N3_DTBAIXA BETWEEN '"+DTOS(MV_PAR02)+"' AND '"+DTOS(MV_PAR03)+"' "+Chr(13)
	Else
		cQuery += " 								AND N3SUBSUBSUB3.N3_BAIXA != '1' "+Chr(13)
	EndIf
	
	cQuery += "										AND N3SUBSUBSUB3.N3_CBASE = N1.N1_CBASE "+Chr(13)
	cQuery += "										AND N3SUBSUBSUB3.N3_ITEM = N1.N1_ITEM "+Chr(13)
	cQuery += "										AND N3SUBSUBSUB3.N3_FIMDEPR <= '19910125'" +Chr(13)
	cQuery += "										AND N3SUBSUBSUB3.N3_TIPO = '02' "+Chr(13)
	cQuery += "								) "+Chr(13)
	cQuery += "					)))*100	 "+Chr(13)
	cQuery += " )  COL8, "+Chr(13)

	cQuery += " (SELECT (((100/N3_TXDEPR1)-(100/NG_TXDEPR1))* N3_TXDEPR1) TXPERDA FROM "+ RetSqlName("SN3")+" N3SUB4 "+Chr(13)
	cQuery += " WHERE N3SUB4.D_E_L_E_T_ = ' ' "+Chr(13)
	cQuery += " AND N3SUB4.N3_FILIAL = N1.N1_FILIAL "+Chr(13)

	If lItemBaixado
		cQuery += " AND N3SUB4.N3_BAIXA = '1' "+Chr(13)
		cQuery += " AND N3SUB4.N3_DTBAIXA BETWEEN '"+DTOS(MV_PAR02)+"' AND '"+DTOS(MV_PAR03)+"' "+Chr(13)
	Else
		cQuery += " AND N3SUB4.N3_BAIXA != '1' "+Chr(13)
	EndIf

	cQuery += " AND N3SUB4.N3_TIPO = '01' "+Chr(13)
	cQuery += " AND N3SUB4.N3_CBASE = N1.N1_CBASE "+Chr(13)
	cQuery += " AND N3SUB4.N3_ITEM = N1.N1_ITEM "+Chr(13)
	cQuery += " AND N3SUB4.N3_FIMDEPR <= '19910125' "+Chr(13)
	cQuery += " AND N3SUB4.N3_TIPO = '01' "+Chr(13)
	cQuery += " AND N3SUB4.N3_TXDEPR1 > 0 "+Chr(13)
	cQuery += " AND NG.NG_TXDEPR1 > 0 "+Chr(13)
	cQuery += " AND N3SUB4.N3_TXDEPR1 < NG.NG_TXDEPR1 "+Chr(13)
	cQuery += " )  COL14, "+Chr(13)

	
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
	cQuery += "	AND N3_FIMDEPR <= '19910125' AND N3.N3_FIMDEPR <> '' "+Chr(13)
	cQuery += "	AND NG.NG_FILIAL = N1.N1_FILIAL "+Chr(13)
	cQuery += "	AND NG.NG_GRUPO = N1.N1_GRUPO " +Chr(13)
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
	cQuery += "				AND N3.N3_FIMDEPR <= '19910125' "+Chr(13)
	cQuery += " 			AND N3N3.N3_TIPREAV = 'PT-91-049' "+Chr(13)
	cQuery += " 			)"  +Chr(13)
	
	cQuery += " ORDER BY N1.N1_GRUPO , N1.N1_AQUISIC, N3.N3_DINDEPR"+Chr(13)
	MemoWrite( 'ATFR3311.sql', cQuery )
	cQuery := ChangeQuery(cQuery)
	
	If ( Select ( cArq ) <> 0 )
		dbSelectArea ( cArq )
		dbCloseArea ()
	Endif
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cArq,.T.,.F.)

	RestArea(aSaveArea)
Return(cArq) 


