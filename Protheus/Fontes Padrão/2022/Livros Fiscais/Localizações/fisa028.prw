#INCLUDE "fisa028.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
                                                                            
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FISA028   ³ Autor ³ Paulo Augusto        ³ Data ³19/04/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Apuracao de impostos ISC - DSS   	    			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FISA028()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                      								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Republica Dominicana 									  ³±± 
±±³          ³ 															  ³±±
±±           ³ Declaración y/o pago del impuesto selectivo a los          ³±±
±±			 ³ servicios de seguros - DSS                 				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  

Function FISA028()
Local 	aArea	 := GetArea()
Local 	cCadastro:= STR0001//"Apuração de impostos"
Local 	aSays	 := {}
Local 	aButtons := {}
Local 	aProcFil := {}
Local 	aTrab	 := {}
Local 	nx   	 := 0 
Local 	nxOpc	 := 0 
Local 	lPerg	 := .F.
Local	cNorma   := ""
Local	cDest    := ""
Private	cpDir    := ""
Private cPerg	 := "FISA028"

aAdd(aSays,STR0001)//"Esta rotina tem a finalidade de efetuar a apuração dos impostos ISC calculados pelo sistema:" //"Esta rotina tem a finalidade de efetuar a apuração dos impostos ISC calculados pelo sistema:"
//aAdd(aSays,STR0003)//"Imposto sobre Valor Agregado (IVA/IVC/RV0/RV1)."  

aAdd(aButtons,{5,.T.,{ || lPerg := Pergunte(cPerg,.T.) }})
aAdd(aButtons,{1,.T.,{ || nxOpc := 1,FechaBatch()      }})
aAdd(aButtons,{2,.T.,{ || nxOpc := 0,FechaBatch()      }})
FormBatch(cCadastro,aSays,aButtons)      

//********************
//Parametros FISA028 
//********************
//MV_PAR01 - Periodo
//MV_PAR02 - Arquivo de Periodo Anterior
//MV_PAR03 - Arquivo de Configuracao
//MV_PAR04 - Arquivo de Destino
//MV_PAR05 - Diretorio
//MV_PAR06 - Gera Titulo?
//MV_PAR07 - Data Venc. Titulo?
//MV_PAR08 - E-mail
//********************

If nxOpc == 1
	If !lPerg
		lPerg := Pergunte(cPerg,.T.)
	Endif 
	If lPerg
		cNorma		:= AllTrim(MV_PAR03) + ".INI"
		cpDir		:= alltrim(MV_PAR05)
		cDirRec		:= cpDir	 	    
		aProcFil	:= {.F.,cFilAnt}
		
		DbSelectArea("SX3")
		DbSetOrder(1)
		Processa({||ProcNorma(cNorma,cDest,cDirRec,aProcFil,@aTrab)})
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ferase no array aTrab                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		For nX := 1 to Len(aTrab)
			Ferase(AllTrim(aTrab[nX][1]))
		Next
		DbSelectArea("SF3")
		DbSetOrder(1)
	EndIF
Endif
RestArea(aArea)
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ImpDSS     ³ Autor ³ Paulo Augusto 		³ Data ³26/04/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera o conteúdo das linhas da apuração IST01               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ImpDSS()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum       	         								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aArray                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Rep. Dominicana                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                      
Function ImpDSS(aDadGer)
	//Conceitos - Quantidade
	Local nq1:= 0 //Vida Coletiva
	Local nq2:= 0 //Vida Individual
	Local nq3:= 0 //Saude
	Local nq4:= 0 //Acidente Pessoal e Saude
	Local nq5:= 0 //Incendios e Aliados
	Local nq6:= 0 //Naves maritimas e aereas
    Local nq7:= 0 //transporte de carga
	Local nq8:= 0 //Veiculo de motor
	Local nq9:= 0 //Agricolqas pecuarias
	Local nq10:= 0 //FInanças
	Local nq11:= 0 //Outors seguros
	Local nq12:= 0 //total a pagar (sumar casillas 1 a 11)
    // Conceitos Valores
	Local n1:= 0 //Vida Coletiva
	Local n2:= 0 //Vida Individual
	Local n3:= 0 //Saude
	Local n4:= 0 //Acidente Pessoal e Saude
	Local n5:= 0 //Incendios e Aliados
	Local n6:= 0 //Naves maritimas e aereas
    Local n7:= 0 //transporte de carga
	Local n8:= 0 //Veiculo de motor
	Local n9:= 0 //Agricolqas pecuarias
	Local n10:= 0 //FInanças
	Local n11:= 0 //Outors seguros
	Local n12:= 0 //total a pagar (sumar casillas 1 a 11)
// Liquidacao

	Local n13:= 0 //Isentas
    Local n14:= 0 //Operacoes gravadas
	Local n15:= 0 //Imposto a pagar (linha 14 *16%)
	Local n16:= 0 //Saldo periodo anterior
	Local n17:= 0 //Saldo Compensavel Autorizado
	Local n18:= 0 //Pagtos Computaveis a Conta
	Local n19:= 0 //Diferenca a pagar( se 15-16-17-19 >0)
	Local n20:= 0 //Diferenca a favor( se 15-16-17-19 <0)

	Local nTotSD2 := 0
	Local nIngSD2 := 0
	Local nTotSD1 := 0
	Local nIngSD1 := 0
	Local cQuerySD2	:= ""
	Local cQuerySD1	:= ""                                                                                      
	Local cUFCliFor	:= ""      
	Local cArqAnt	:= "" 
	Local lArqAnt	:= .F.
	Local lGerTit   := .F.
	Local lExclTit	:= .T.
	Local alImposto	:= {}
	Local nlRtAc	:= 0
	Local llMDados 	:= .F.
	Local clLivro	:= ""
	Local nX:=1
	Private cNomTxt := "" 
	Private cImpDesc:= ""
	Private aTitulos:= {}
	Private	apTabApu:= {}	

	cNomTxt:= MV_PAR01+"-"+Alltrim(MV_PAR04)+"-"+cEmpAnt+cFilAnt+"."+"IST"
	
	lGerTit		:=Iif(MV_PAR06==1,.T.,.F.)
	lArqAnt		:=Iif(!Empty(MV_PAR02),.T.,.F.)
	cArqAnt		:=Alltrim(MV_PAR02)	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄD¿
	//³Valida e verifica apuração e título de apuração anterior³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄDÙ*/
	
   	If File(cpDir+cNomTxt) .and. ApMsgYesNo(STR0002) //"Periodo ja apurado. Deseja refazer?"
		MsgRun(STR0003,,{|| lExclTit := DelTitApur(cNomTxt)})  //"Cancelando apuracao anterior"
		If !lExclTit
			ApMsgStop(STR0004,STR0004)  //"Tit ja foi baixado"###"Tit Ja foi baixado"
			Return nil
		Endif			
	Else
		If File(cpDir+cNomTxt) 
			MsgRun(STR0005,,{|| lExclTit := FMApur(substr(cNomTxt,1,17))})//"Gerando Relatório de Conferencia"			 //"Gerando Relatorio Conf"
			If lExclTit 
			   	llMDados := .T.   
			Else
				Return Nil
			EndIF
		EndIF
	EndIF   	
	    
	If !llMDados
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄe 
   		//³Seleciona os itens de saída de acordo com o produto, conceito e tipo de apuração ( IST )    ³
   		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄe 
	    
		cQuerySD2 += "SELECT DISTINCT "
		cQuerySD2 += "SD2.*, B1_COD, B1_CONISC, CCR_CONCEP, CCR_APUR,CCR_GAPUR, F2_ESPECIE "
		cQuerySD2 += "FROM "+RetSqlName("SD2")+ " SD2 "
		cQuerySD2 += "INNER JOIN " +RetSqlName("SB1")+" SB1 ON "
		cQuerySD2 += "B1_FILIAL = '"+xFilial("SB1")+"'" 
		cQuerySD2 += "AND B1_COD = D2_COD "
		CQuerySD2 += "AND SB1.D_E_L_E_T_ ='' "
		cQuerySD2 += "INNER JOIN "+RetSqlName("CCR")+" CCR ON " 
		cQuerySD2 += "CCR_FILIAL = '"+xFilial("SB1")+"' "
		cQuerySD2 += "AND CCR_CONCEP = B1_CONISC "
		cQuerySD2 += "AND CCR.D_E_L_E_T_ = '' "
		cQuerySD2 += "INNER JOIN "+RetSqlName("SF2")+" SF2 ON " 
		cQuerySD2 += "F2_FILIAL = '"+xFilial("SF2")+"' "
		cQuerySD2 += "AND F2_DOC = D2_DOC "
		CQuerySD2 += "AND SF2.D_E_L_E_T_ ='' "		
		cQuerySD2 += "WHERE CCR_APUR = '2' "
		cQuerySD2 += "AND D2_DTDIGIT LIKE '%"+SubStr(mv_par01,1,6)+"__'"
		cQuerySD2 += "AND F2_ESPECIE IN ('NF','NDC','NCE','NDI','NCP') "	
		
		If Select("TOTSD2")>0
			DbSelectArea("TOTSD2")
			TOTSD2->(DbCloseArea())
		Endif
				                              
		TcQuery cQuerySD2 New Alias "TOTSD2"	
		
		DbSelectArea("TOTSD2")
		Do While TOTSD2->(!Eof()) 
		
			If AllTrim(TOTSD2->F2_ESPECIE) $ "NDI|NCP"
				DO CASE
					Case TOTSD2->CCR_GAPUR==1
					    n1:=n1-TOTSD2->D2_VALIMP2 
					    nq1:=nq1-TOTSD2->D2_QUANT
					Case TOTSD2->CCR_GAPUR==2
					    n2:=n2-TOTSD2->D2_VALIMP2 
					    nq2:=nq2-TOTSD2->D2_QUANT
					Case TOTSD2->CCR_GAPUR==3
			    		n3:=n3-TOTSD2->D2_VALIMP2 
			    		nq3:=nq3-TOTSD2->D2_QUANT
					Case TOTSD2->CCR_GAPUR==4
						n4:=n4-TOTSD2->D2_VALIMP2 
			    		nq4:=nq4-TOTSD2->D2_QUANT
					Case TOTSD2->CCR_GAPUR==5
						n5:=n5-TOTSD2->D2_VALIMP2 
			    		nq5:=nq5-TOTSD2->D2_QUANT
					Case TOTSD2->CCR_GAPUR==6
						n6:=n6-TOTSD2->D2_VALIMP2 
			    		nq6:=nq6-TOTSD2->D2_QUANT
					Case TOTSD2->CCR_GAPUR==7
						n7:=n7-TOTSD2->D2_VALIMP2 
					    nq7:=nq7-TOTSD2->D2_QUANT
					Case TOTSD2->CCR_GAPUR==8
					    n8:=n8-TOTSD2->D2_VALIMP2 
					    nq8:=nq8-TOTSD2->D2_QUANT
					Case TOTSD2->CCR_GAPUR==9 
					    n9:=n9-TOTSD2->D2_VALIMP2 
			    		nq9:=nq9-TOTSD2->D2_QUANT
					Case TOTSD2->CCR_GAPUR==10
						n10:=n10-TOTSD2->D2_VALIMP2 
			    		nq10:=nq10-TOTSD2->D2_QUANT
					Case TOTSD2->CCR_GAPUR==11
					    n11:=n11-TOTSD2->D2_VALIMP2 
			    		nq11:=nq11-TOTSD2->D2_QUANT
				ENDCASE
			Else
				DO CASE
					Case TOTSD2->CCR_GAPUR==1
					    n1:=n1+TOTSD2->D2_VALIMP2 
					    nq1:=nq1+TOTSD2->D2_QUANT
					Case TOTSD2->CCR_GAPUR==2
					    n2:=n2+TOTSD2->D2_VALIMP2 
					    nq2:=nq2+TOTSD2->D2_QUANT
					Case TOTSD2->CCR_GAPUR==3
			    		n3:=n3+TOTSD2->D2_VALIMP2 
			    		nq3:=nq3+TOTSD2->D2_QUANT
					Case TOTSD2->CCR_GAPUR==4
						n4:=n4+TOTSD2->D2_VALIMP2 
			    		nq4:=nq4+TOTSD2->D2_QUANT
					Case TOTSD2->CCR_GAPUR==5
						n5:=n5+TOTSD2->D2_VALIMP2 
			    		nq5:=nq5+TOTSD2->D2_QUANT
					Case TOTSD2->CCR_GAPUR==6
						n6:=n6+TOTSD2->D2_VALIMP2 
			    		nq6:=nq6+TOTSD2->D2_QUANT
					Case TOTSD2->CCR_GAPUR==7
						n7:=n7+TOTSD2->D2_VALIMP2 
					    nq7:=nq7+TOTSD2->D2_QUANT
					Case TOTSD2->CCR_GAPUR==8
					    n8:=n8+TOTSD2->D2_VALIMP2 
					    nq8:=nq8+TOTSD2->D2_QUANT
					Case TOTSD2->CCR_GAPUR==9 
					    n9:=n9+TOTSD2->D2_VALIMP2 
			    		nq9:=nq9+TOTSD2->D2_QUANT
					Case TOTSD2->CCR_GAPUR==10
						n10:=n10+TOTSD2->D2_VALIMP2 
			    		nq10:=nq10+TOTSD2->D2_QUANT
					Case TOTSD2->CCR_GAPUR==11
					    n11:=n11+TOTSD2->D2_VALIMP2 
			    		nq11:=nq11+TOTSD2->D2_QUANT
				ENDCASE
			EndIf
			TOTSD2->(DbSkip())		
        EndDo
        
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄe 
   		//³Seleciona os itens de entrada de acordo com o produto, conceito e tipo de apuração ( IST )    ³
   		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄe
        
        cQuerySD1 += "SELECT DISTINCT "
		cQuerySD1 += "SD1.*, B1_COD, B1_CONISC, CCR_CONCEP, CCR_APUR,CCR_GAPUR, F1_ESPECIE "
		cQuerySD1 += "FROM "+RetSqlName("SD1")+ " SD1 "
		cQuerySD1 += "INNER JOIN " +RetSqlName("SB1")+" SB1 ON "
		cQuerySD1 += "B1_FILIAL = '"+xFilial("SB1")+"'" 
		cQuerySD1 += "AND B1_COD = D1_COD "
		CQuerySD1 += "AND SB1.D_E_L_E_T_ ='' "
		cQuerySD1 += "INNER JOIN "+RetSqlName("CCR")+" CCR ON " 
		cQuerySD1 += "CCR_FILIAL = '"+xFilial("SB1")+"' "
		cQuerySD1 += "AND CCR_CONCEP = B1_CONISC "
		cQuerySD1 += "AND CCR.D_E_L_E_T_ = '' "
		cQuerySD1 += "INNER JOIN "+RetSqlName("SF1")+" SF1 ON " 
		cQuerySD1 += "F1_FILIAL = '"+xFilial("SF1")+"' "
		cQuerySD1 += "AND F1_DOC = D1_DOC "
		CQuerySD1 += "AND SF1.D_E_L_E_T_ ='' "		
		cQuerySD1 += "WHERE CCR_APUR = '2' "
		cQuerySD1 += "AND D1_EMISSAO LIKE '%"+SubStr(mv_par01,1,6)+"__'"
		cQuerySD1 += "AND F1_ESPECIE IN ('NF','NCC','NDE','NCI','NDP') "       

        If Select("TOTSD1")>0
			DbSelectArea("TOTSD1")
	   		TOTSD1->(DbCloseArea())
		Endif
				                              
		TcQuery cQuerySD1 New Alias "TOTSD1"	
		
		DbSelectArea("TOTSD1")
		Do While TOTSD1->(!Eof())
		
			If AllTrim(TOTSD1->F1_ESPECIE) $ "NCC|NDE"
				DO CASE
					Case TOTSD1->CCR_GAPUR==1
					    n1:=n1-TOTSD1->D1_VALIMP2 
					    nq1:=nq1-TOTSD1->D1_QUANT
					Case TOTSD1->CCR_GAPUR==2
					    n2:=n2-TOTSD1->D1_VALIMP2 
					    nq2:=nq2-TOTSD1->D2_QUANT
					Case TOTSD1->CCR_GAPUR==3
			    		n3:=n3-TOTSD1->D1_VALIMP2 
			    		nq3:=nq3-TOTSD1->D1_QUANT
					Case TOTSD1->CCR_GAPUR==4
						n4:=n4-TOTSD1->D1_VALIMP2 
			    		nq4:=nq4-TOTSD1->D1_QUANT
					Case TOTSD1->CCR_GAPUR==5
						n5:=n5-TOTSD1->D1_VALIMP2 
			    		nq5:=nq5-TOTSD1->D1_QUANT
					Case TOTSD1->CCR_GAPUR==6
						n6:=n6-TOTSD1->D1_VALIMP2 
			    		nq6:=nq6-TOTSD1->D1_QUANT
					Case TOTSD1->CCR_GAPUR==7
						n7:=n7-TOTSD1->D1_VALIMP2 
					    nq7:=nq7-TOTSD1->D1_QUANT
					Case TOTSD1->CCR_GAPUR==8
					    n8:=n8-TOTSD1->D1_VALIMP2 
					    nq8:=nq8-TOTSD1->D1_QUANT
					Case TOTSD1->CCR_GAPUR==9 
					    n9:=n9-TOTSD1->D1_VALIMP2 
			    		nq9:=nq9-TOTSD1->D1_QUANT
					Case TOTSD1->CCR_GAPUR==10
						n10:=n10-TOTSD1->D1_VALIMP2 
			    		nq10:=nq10-TOTSD1->D1_QUANT
					Case TOTSD1->CCR_GAPUR==11
					    n11:=n11-TOTSD1->D1_VALIMP2 
			    		nq11:=nq11-TOTSD1->D1_QUANT
				ENDCASE
			Else
				DO CASE
					Case TOTSD1->CCR_GAPUR==1
					    n1:=n1+TOTSD1->D1_VALIMP2 
					    nq1:=nq1+TOTSD1->D1_QUANT
					Case TOTSD1->CCR_GAPUR==2
					    n2:=n2+TOTSD1->D1_VALIMP2 
					    nq2:=nq2+TOTSD1->D1_QUANT
					Case TOTSD1->CCR_GAPUR==3
			    		n3:=n3+TOTSD1->D1_VALIMP2 
			    		nq3:=nq3+TOTSD1->D1_QUANT
					Case TOTSD1->CCR_GAPUR==4
						n4:=n4+TOTSD1->D1_VALIMP2 
			    		nq4:=nq4+TOTSD1->D1_QUANT
					Case TOTSD1->CCR_GAPUR==5
						n5:=n5+TOTSD1->D1_VALIMP2 
			    		nq5:=nq5+TOTSD1->D1_QUANT
					Case TOTSD1->CCR_GAPUR==6
						n6:=n6+TOTSD1->D1_VALIMP2 
			    		nq6:=nq6+TOTSD1->D1_QUANT
					Case TOTSD1->CCR_GAPUR==7
						n7:=n7+TOTSD1->D1_VALIMP2 
					    nq7:=nq7+TOTSD1->D1_QUANT
					Case TOTSD1->CCR_GAPUR==8
					    n8:=n8+TOTSD1->D1_VALIMP2 
					    nq8:=nq8+TOTSD1->D1_QUANT
					Case TOTSD1->CCR_GAPUR==9 
					    n9:=n9+TOTSD1->D1_VALIMP2 
			    		nq9:=nq9+TOTSD1->D1_QUANT
					Case TOTSD1->CCR_GAPUR==10
						n10:=n10+TOTSD1->D1_VALIMP2 
			    		nq10:=nq10+TOTSD1->D1_QUANT
					Case TOTSD1->CCR_GAPUR==11
					    n11:=n11+TOTSD1->D1_VALIMP2 
			    		nq11:=nq11+TOTSD1->D1_QUANT
				ENDCASE
			EndIf
			TOTSD1->(DbSkip())		
        EndDo
        
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄe 
   		//³Faz a soma e subtração das linhas da apuração   ³
   		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄe
        
      	n12 := n1+n2+n3+n4+n5+n6+n7+n8+n9+n10+n11
      	nq12 := nq1+nq2+nq3+nq4+nq5+nq6+nq7+nq8+nq9+nq10+nq11
        n13:= Val(aDadGer[1][1])
        n14:= n12 - n13
        n15:= n14 * (16/100)
        n16:= FPerAnt(cArqAnt,"20")
        If Val(aDadGer[1][2]) >0
	        n16:= Val(aDadGer[1][2])
        EndIf
        
		n17:= Val(aDadGer[1][3])
		n18:= Val(aDadGer[1][4])
		nValor:=n15-n16-n17-n18
		If nValor >0
			n19:=nValor  
			n20:=0
		Else      
			n19:=0
			n20:=nValor*(-1)
		EndIf	
			
        n21:=Val(aDadGer[1][5])
        n22:=Val(aDadGer[1][6])        
        n23:=Val(aDadGer[1][7])        
		n24:=n19+n21+n22+n23
   		 
   		aAdd(apTabApu,{"1."   ,STR0006  							 	,nq1	,n1	,.F.}) //"Vida Coletiva(+) "
   		aAdd(apTabApu,{"2."   ,STR0007     							,nq2,	n2	,.F.}) //"Vida Individual(+) "
   		aAdd(apTabApu,{"3."   ,STR0008     										,nq3	,n3	,.F.}) //"Saude(+) "
		aAdd(apTabApu,{"4."   ,STR0009						,nq4	,n4	,.F.}) //"Acidentes pessoais e saude(+) "
		aAdd(apTabApu,{"5."   ,STR0010  							,nq5	,n5	,.F.}) //"Incendios e Aliados(+) "
   		aAdd(apTabApu,{"6."   ,STR0011    					,nq6	,n6	,.F.}) //"Naves Maritimas e Aereas(+) "
   		aAdd(apTabApu,{"7."   ,STR0012 							,nq7	,n7	,.F.}) //"Transporte de carga(+) "
		aAdd(apTabApu,{"8."   ,STR0013								,nq8	,n8	,.F.})  //"Veiculo de motor(+) "
		aAdd(apTabApu,{"9."   ,STR0014  	 						,nq9	,n9	,.F.}) //"Agricolas Pecuarias(+) "
   		aAdd(apTabApu,{"10."   ,STR0015 										,nq10	,n10,.F.}) //"Financas(+) "
   		aAdd(apTabApu,{"11."   ,STR0016     							,nq11	,n11,.F.}) //"Outros Seguros(+) "
		aAdd(apTabApu,{"12."   ,STR0017				,nq12	,n12,.F.})		   		  //"Total das Operacoes(Soma 1 ao 11) "
		
		//lIQUIDACAO
		
   		aAdd(apTabApu,{"13."   ,STR0018  								,0,	n13,.F.}) //"Operacoes Isentas "
   		aAdd(apTabApu,{"14."   ,STR0019     							,0	,n14,.F.}) //"Operacoes Gravadas "
   		aAdd(apTabApu,{"15."   ,STR0020,0	,n15,.F.}) //"Imposto a Pagar (aplicar taxa de 16% do campo 14) "
		aAdd(apTabApu,{"16."   ,STR0021							,0	,n16,.F.}) //"Saldo anterior a favor "
		aAdd(apTabApu,{"17."   ,STR0022,0	,n17,.F.}) //"Saldo Compensavel autorizado (Outros Impostos)(-) "
   		aAdd(apTabApu,{"18."   ,STR0023    				,0	,n18,.F.}) //"Pagtos computados em conta(-) "
   		aAdd(apTabApu,{"19."   ,STR0024 		,0	,n19,.F.}) //"Diferenca a Pagar ( Linhas:15-16-17-18 >0) "
		aAdd(apTabApu,{"20."   ,STR0025 		,0	,n20,.F.})  //"Novo saldo a Favor( Linhas:15-16-17-18 >0) "
		aAdd(apTabApu,{"21."   ,STR0026  	 									,0	,n21,.F.}) //"Recargo(+) "
   		aAdd(apTabApu,{"22."   ,STR0027 							,0	,n22,.F.}) //"Juros Indenizatorio(+) "
   		aAdd(apTabApu,{"23."   ,STR0028     									,0	,n23,.F.}) //"Sancoes(+) "
   		aAdd(apTabApu,{"24."   ,STR0029 	,0	,n24,.F.})		 //"Total a Pagar ( Somas das linhas 19+21+22+23) "
   		
	EndIF
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gera relatório de conferencia dos dados ³
   	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	FRConfDSS()                         

   	If !llMDados 	
		If lGerTit
			MsgRun(STR0030,,{|| IIf(n24>0,aTitulos := GrvTitLoc(n24),Nil) }) //"Gerando titulo de apuração..." // //"Gerando titulo de apuração..."
		Endif
		MsgRun(STR0031,,{|| CriarArq(cNomTxt,apTabApu,aTitulos) })//"Gerando Arquivo apuração de imposto..."	 //"Gerando Arquivo apuração de imposto..."
	EndIf	
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FPerant   ³ Autor ³ Paulo Augusto         ³ Data ³02/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Função que busca o resultado do Periodo anterior indicado  ³±±
±±³ 		 | no paramentro por meio do Codigo     	    			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FPerant(cod)		                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum						                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ nResultado - Resultado do Arquivo Anterior                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Rep. Dominicana	                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FPerAnt(cArq,cCod)	
	Local cBuffer	:=""
	Local nResAnt	:=0
	Local clNome	:=""
	Local clAux		:=""
	Default cArq	:=""
	Default cCod	:=""
	
	
	clNome := cpDir + cArq + ".IST"
	
	If !Empty(cArq)
		If FT_FUSE(clNome) <> -1
			FT_FGOTOP()
			If File(clNome)
				While !FT_FEOF()
					cBuffer := FT_FREADLN()
					If Substr(cBuffer,9,2) == cCod
						clAux := StrTran(Substr(cBuffer,127,17),"","")						
						nResAnt := val(StrTran(clAux,",","."))
						Exit
					EndIf
					FT_FSKIP()
				EndDo                                         
			EndIf
			FT_FUSE()
		Else
			Alert(STR0012)//"Erro na abertura do arquivo da apuração anterior"
			Return Nil		
		EndIf	  
	Endif
Return nResAnt

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CriarArq  ³ Autor ³ Paulo Augusto         ³ Data ³26/04/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera o arquivo TXT com os valores que constam na getdados  ³±±
±±³          ³ e no array do Titulo                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CriarArq 		                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum								  					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum										              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Rep. Dominicana		                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CriarArq(cArq,aImp,aTit)
	Local cCRLF		:= Chr(13)+Chr(10)
	Local nHdl		:= 0
	Local nlCont	:= 0
	Local cLinha	:= ""
	
	nHdl := fCreate(cpDir+cArq)
	If nHdl <= 0
		ApMsgStop(STR0015) // "Ocorreu um erro ao criar o arquivo"
	Endif  
	
	nlCont := 0
	For nlCont := 1 to Len(aImp)
		cLinha := "IMP"							+ Space(5) // Clausula que indica a linha
		cLinha += aImp[nlCont][1]				+ Space(5) // Codigo de linha 
		cLinha += Padr(aImp[nlCont][2],105)		+ Space(5) // Descrição da linha
		cLinha += Transform(aImp[nlCont][4],"@E 999,999,999.99")	+ Space(5) // Valor da linha
		cLinha += cCRLF
		
		fWrite(nHdl,cLinha)
	Next nlCont
	
	If Len(aTit) > 0
		cLinha := "TIT"				+ Space(5) // Clausula que indica o tipo de linha
		cLinha += Padr(aTit[1],10)	+ Space(5) // Prefixo
		cLinha += Padr(aTit[2],20)	+ Space(5) // Numero
		cLinha += Padr(aTit[3],5)	+ Space(5) // Parcela
		cLinha += Padr(aTit[4],5)	+ Space(5) // Tipo
		cLinha += Padr(aTit[5],10)	+ Space(5) // Fornecedor
		cLinha += Padr(aTit[6],5)	+ Space(5) // Loja
		cLinha += Transform(aTit[8],"@E 999,999,999.99") + Space(5) // Valor do Imposto
		cLinha += cCRLF
		
		fWrite(nHdl,cLinha)
	Endif
	If nHdl > 0
		fClose(nHdl)
	Endif
Return nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    FMApur     ³ Autor ³Paulo Augusto          ³ Data ³26/04/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Função que faz a leitura do TXT para mostrar o Relatorio   ³±±
±±³ 		 | de Conferencia					     	    			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FMApur(cNomArq)		                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum						                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRet - .T. :conseguiu ler o arquivo .F.:não leu o arquivo  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Rep. Dominicana	                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FMApur(cNomArq)

	Local cBuffer	:= ""
 	Local clNome	:= ""
	Local lRet		:= .T.
	Local clAux		:= ""
	Local nResAnt	:= 0
	clNome := cpDir + cNomArq + ".IST" 	
	
	IF FT_FUSE(clNome) <> -1
		FT_FGOTOP()
		Do While !FT_FEOF()
			cBuffer := FT_FREADLN()
			If Substr(cBuffer,1,3) == "IMP"			
				clAux := StrTran(Substr(cBuffer,127,17),".","")						
				nResAnt := val(StrTran(clAux,",","."))			
				aAdd(apTabApu,{	Substr(cBuffer,009,03)	,; 	// Codigo da linha
								Substr(cBuffer,017,50)	,; 	// Descricao da linha
							    nResAnt	,;// Valor da linha							
								.F.	})
			Endif
			FT_FSKIP()
		EndDo
		FT_FUSE()
	else
		Alert(STR0016)//"Erro na abertura do arquivo"
		lRet := .F.
	EndIF
	
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³DelTitApur³ Autor ³ Paulo Augusto         ³ Data ³26/04/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Excluir o titulo de apuração para o governo.				  ³±±	
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DelTitApur() 		                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum								  					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRet- Se .T. Foi excluido. Se .F. não foi possivel excluir ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Rep. Dominicana  	                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/         
Static Function DelTitApur(cNomArq,cEsc)
	Local   lRet        := .T.
	Local   cBuffer     := ""
	Local   aDadosSE2   := {}
	Local	clNome		:= "" 
	Private lMsErroAuto := .F.
	
	clNome := cpDir + cNomArq
	If FT_FUSE(clNome) <> -1
		FT_FGOTOP()
		Do While !FT_FEOF()
			cBuffer := FT_FREADLN()
			If Substr(cBuffer,1,3) == "TIT"
				DBSelectArea("SE2")
				SE2->(DBGoTop())
				SE2->(DBSetOrder(1))
				If DbSeek(xFilial("SE2")+Substr(cBuffer,09,TamSX3("E2_PREFIXO")[1])+Substr(cBuffer,24,TamSX3("E2_NUM")[1]))
					If SE2->E2_VALOR <> SE2->E2_SALDO //Já foi dado Baixa no Título				
						lRet := .F.
					Else	
						aAdd(aDadosSE2,{"E2_FILIAL" ,xFilial("SE2"),nil})
						aAdd(aDadosSE2,{"E2_PREFIXO",Substr(cBuffer,09,TamSX3("E2_PREFIXO")[1])	,nil})
						aAdd(aDadosSE2,{"E2_NUM"    ,Substr(cBuffer,24,TamSX3("E2_NUM")[1])		,nil})
						aAdd(aDadosSE2,{"E2_PARCELA",Substr(cBuffer,49,TamSX3("E2_PARCELA")[1])	,nil})
						aAdd(aDadosSE2,{"E2_TIPO"   ,Substr(cBuffer,59,TamSX3("E2_TIPO")[1])	,nil})
						aAdd(aDadosSE2,{"E2_FORNECE",Substr(cBuffer,69,TamSX3("E2_FORNECE")[1])	,nil})
						aAdd(aDadosSE2,{"E2_LOJA"   ,Substr(cBuffer,84,TamSX3("E2_LOJA")[1])	,nil})
							      
						DbSelectArea("SE2")
						SE2->(DbSetOrder(1))//E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA
						SE2->(DbGoTop())      
						If SE2->(DbSeek(xFilial("SE2")+AvKey(aDadosSE2[2][2],"E2_PREFIXO")+AvKey(aDadosSE2[3][2],"E2_NUM")+AvKey(aDadosSE2[4][2],"E2_PARCELA")+;
										AvKey(aDadosSE2[5][2],"E2_TIPO")+AvKey(aDadosSE2[6][2],"E2_FORNECE")+AvKey(aDadosSE2[7][2],"E2_LOJA")))
							MsExecAuto({|x,y,z| FINA050(x,y,z)},aDadosSE2,,5)
							If lMsErroAuto
				       			MostraErro()
				       			lRet := .F.
					  		Endif
						Endif                          
					EndIF
				Endif
			EndIF
			FT_FSKIP()
		EndDo
	Else
		Alert(STR0016)//"Erro na abertura do arquivo"
		Return Nil	
	EndIF
	FT_FUSE()
	
	If lRet
		fErase(cNomArq)
	Endif

Return lRet 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    FRConfDSS()³ Autor ³ Paulo Augusto         ³ Data ³26/04/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Função que cria o objeto do TMSPRINTER e chama as funções  ³±±
±±³ 		 | de impressão do cabeçalho e do corpo do relatorio		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FRConfDSS()			                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum						                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Rep. Dominicana	                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function FRConfDSS()
    Private clTitulo 	:= STR0032	 //"Relatório de Conferência de Informações"
	Private opFont1		:= TFont():New("Calibri",,8,,.T.,,,,,.F.) //titulos II Operaciones, III Penalidades, IV Monto
	Private opFont2  	:= TFont():New("Arial",,8,,.T.,,,,,.F.) //descritivos
	Private opFont3  	:= TFont():New("Arial",,8,,.F.,,,,,.F.) // valores
	Private opFont4  	:= TFont():New("Georgia",,23,,.F.,,,,,.F.) //DGII
	Private opFont5  	:= TFont():New("Georgia",,10,,.F.,,,,,.F.) //DIRECCION GENERAL DE IMPUESTOS INTERNOS
	Private opFont6  	:= TFont():New("Georgia",,10,,.F.,,,,,.F.) //DECLARACION Y/O PAGO DEL IMPUESTO
	    
	oPrn := TmsPrinter():New(clTitulo)
	oPrn:SetPaperSize(9)
	oPrn:SetPortrait()
	oPrn:StartPage()
    
	CabecDSS()
	ImpRegDSS()
       
	oPrn:EndPage()
	oPrn:Preview()
	oPrn:End()
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    CabecDSS() ³ Autor ³ Paulo Augusto         ³ Data ³19/04/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Função que faz a impressão do cabeçalho					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CabecDSS()				                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum						                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Rep. Dominicana                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function CabecDSS()

	oPrn:Say(0100,0025,"DGII",opFont4)
	oPrn:Say(0090,0280,STR0033,opFont5) //"DIRECAO GERAL DE IMPOSTOS INTERNOS"
	oPrn:Say(0160,0280,STR0034,opFont6) //"DECLARACAO JURADA Y/O PAGO PARA OS SERVICOS DE SEGUROS "
	oPrn:Say(0100,2150,"DSS",opFont4)
	 
	
	oPrn:Box(0300,0020,0250,2355)//450	

	oPrn:Say(0255,0025,STR0035,opFont1)//"I-DATOS GENERALES //"I. JURAMENTO"
	
	oPrn:Say(0305,0025,STR0036,opFont2) //"RETIFICATORIA: NAO"
	
	oPrn:Say(0305,0355,STR0037,opFont2)  //"Periodo"
	oPrn:Say(0305,0485,MV_PAR01,opFont3) 
	
	oPrn:Say(0355,0025,STR0038,opFont2) //"RNC:"
	oPrn:Say(0355,0105,SM0->M0_CGC,opFont3)
	
	oPrn:Say(0355,0355,STR0039,opFont2) //"Razón Social:"
	oPrn:Say(0355,0585,SM0->M0_NOME,opFont3)	
	
	oPrn:Say(0405,0025,STR0040,opFont2) //"Nombre Comercial:"
	oPrn:Say(0405,0355,SM0->M0_NOMECOM,opFont3)
	
	oPrn:Say(0455,0025,STR0041,opFont2) //"Teléfono:"
	oPrn:Say(0455,0185,SM0->M0_TEL,opFont3)
	
	oPrn:Say(0455,0455,STR0042,opFont2) //"Fax:"
	oPrn:Say(0455,0585,SM0->M0_TEL,opFont3)
	
	//oPrn:Say(0455,0650,STR0043,opFont2) //"Correo Electronico:"
	//oPrn:Say(0455,0950,"--------",opFont3) //mv-par	
	
	oPrn:Box(0505,0020,0250,2355)  
	
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ImpRegIST  ³ Autor ³ Paulo Augusto         ³ Data ³26/04/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Função que faz a impressão dos registros					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ImpRegDSS()				                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum						                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Rep. Dominicana		                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpRegDSS()
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³II. OPERACIONES³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		
	oPrn:Box(0540,0020,0615,2355)
	oPrn:Say(0545,0025,STR0044,opFont1) //"II. CONCEITOS"
	oPrn:Say(0545,1400,STR0045,opFont1) //"QUANTIDADE"
	oPrn:Say(0545,2000,STR0046,opFont1) //"VALOR TOTAL"
   	oPrn:Box(0615,0020,2000,2355)
   	
   	oPrn:Say(0655,0025,apTabApu[1,1]+apTabApu[1,2],opFont1)
	oPrn:Say(0655,1550,AliDir(apTabApu[1,3],"@E 999,999,999.99"),opFont3)                      	
	oPrn:Say(0655,2130,AliDir(apTabApu[1,4],"@E 999,999,999.99"),opFont3)
	oPrn:Line(0700,0020,0700,2355)	 
	
   	oPrn:Say(0715,0025,apTabApu[2,1]+apTabApu[2,2],opFont1)
	oPrn:Say(0715,1550,AliDir(apTabApu[2,3],"@E 999,999,999.99"),opFont3)
	oPrn:Say(0715,2130,AliDir(apTabApu[2,4],"@E 999,999,999.99"),opFont3)
	oPrn:Line(0760,0020,0760,2355)
	
	oPrn:Say(0775,0025,apTabApu[3,1]+apTabApu[3,2],opFont1)
	oPrn:Say(0775,1550,AliDir(apTabApu[3,3],"@E 999,999,999.99"),opFont3)
	oPrn:Say(0775,2130,AliDir(apTabApu[3,4],"@E 999,999,999.99"),opFont3)
	oPrn:Line(0820,0020,0820,2355)


	oPrn:Say(0835,0025,apTabApu[4,1]+apTabApu[4,2],opFont1)
	oPrn:Say(0835,1550,AliDir(apTabApu[4,3],"@E 999,999,999.99"),opFont3)
	oPrn:Say(0835,2130,AliDir(apTabApu[4,4],"@E 999,999,999.99"),opFont3)
	oPrn:Line(0880,0020,0880,2355)

	
	oPrn:Say(0905,0025,apTabApu[5,1]+apTabApu[5,2],opFont1)
	oPrn:Say(0905,1550,AliDir(apTabApu[5,3],"@E 999,999,999.99"),opFont3)
	oPrn:Say(0905,2130,AliDir(apTabApu[5,4],"@E 999,999,999.99"),opFont3)
	oPrn:Line(0950,0020,0950,2355)	

	oPrn:Say(0965,0025,apTabApu[6,1]+apTabApu[6,2],opFont1)
	oPrn:Say(0965,1550,AliDir(apTabApu[6,3],"@E 999,999,999.99"),opFont3)
	oPrn:Say(0965,2130,AliDir(apTabApu[6,4],"@E 999,999,999.99"),opFont3)
	oPrn:Line(1010,0020,1010,2355)	

	oPrn:Say(1025,0025,apTabApu[7,1]+apTabApu[7,2],opFont1)
	oPrn:Say(1025,1550,AliDir(apTabApu[7,3],"@E 999,999,999.99"),opFont3)
	oPrn:Say(1025,2130,AliDir(apTabApu[7,4],"@E 999,999,999.99"),opFont3)
	oPrn:Line(1070,0020,1070,2355)		

	oPrn:Say(1085,0025,apTabApu[8,1]+apTabApu[8,2],opFont1)
	oPrn:Say(1085,1550,AliDir(apTabApu[8,3],"@E 999,999,999.99"),opFont3)
	oPrn:Say(1085,2130,AliDir(apTabApu[8,4],"@E 999,999,999.99"),opFont3)
	oPrn:Line(1130,0020,1130,2355)


	oPrn:Say(1145,0025,apTabApu[9,1]+apTabApu[9,2],opFont1)
	oPrn:Say(1145,1550,AliDir(apTabApu[9,3],"@E 999,999,999.99"),opFont3)
	oPrn:Say(1145,2130,AliDir(apTabApu[9,4],"@E 999,999,999.99"),opFont3)
	oPrn:Line(1190,0020,1190,2355)

	oPrn:Say(1205,0025,apTabApu[10,1]+apTabApu[10,2],opFont1)
	oPrn:Say(1205,1550,AliDir(apTabApu[10,3],"@E 999,999,999.99"),opFont3)
	oPrn:Say(1205,2130,AliDir(apTabApu[10,4],"@E 999,999,999.99"),opFont3)
	oPrn:Line(1250,0020,1250,2355)
	
	
	oPrn:Say(1265,0025,apTabApu[11,1]+apTabApu[11,2],opFont1)
	oPrn:Say(1265,1550,AliDir(apTabApu[11,3],"@E 999,999,999.99"),opFont3)
	oPrn:Say(1265,2130,AliDir(apTabApu[11,4],"@E 999,999,999.99"),opFont3)
	oPrn:Line(1310,0020,1310,2355)
	
	oPrn:Say(1325,0025,apTabApu[12,1]+apTabApu[12,2],opFont1)
	oPrn:Say(1325,1550,AliDir(apTabApu[12,3],"@E 999,999,999.99"),opFont3)
	oPrn:Say(1325,2130,AliDir(apTabApu[12,4],"@E 999,999,999.99"),opFont3)
	oPrn:Line(1370,0020,1370,2355)
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³II. LIQUIDACAO     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	      
	oPrn:Box(1385,0020,1445,2355)
	oPrn:Say(1390,0025,STR0047,opFont1) //"II. LIQUIDACAO"

	oPrn:Say(1455,0025,apTabApu[13,1]+apTabApu[13,2],opFont1)
	oPrn:Say(1455,2130,AliDir(apTabApu[13,4],"@E 999,999,999.99"),opFont3)
	oPrn:Line(1500,0020,1500,2355)
	                              
                       
	oPrn:Say(1515,0025,apTabApu[14,1]+apTabApu[14,2],opFont1)
	oPrn:Say(1515,2130,AliDir(apTabApu[14,4],"@E 999,999,999.99"),opFont3)
	oPrn:Line(1560,0020,1560,2355)
	
	oPrn:Say(1575,0025,apTabApu[15,1]+apTabApu[15,2],opFont1)
	oPrn:Say(1575,2130,AliDir(apTabApu[15,4],"@E 999,999,999.99"),opFont3)
	oPrn:Line(1620,0020,1620,2355)
	
	oPrn:Say(1635,0025,apTabApu[16,1]+apTabApu[16,2],opFont1)
	oPrn:Say(1635,2130,AliDir(apTabApu[16,4],"@E 999,999,999.99"),opFont3)
	oPrn:Line(1680,0020,1680,2355)
	
	oPrn:Say(1695,0025,apTabApu[17,1]+apTabApu[17,2],opFont1)
	oPrn:Say(1695,2130,AliDir(apTabApu[17,4],"@E 999,999,999.99"),opFont3)
	oPrn:Line(1740,0020,1740,2355)
	
	oPrn:Say(1765,0025,apTabApu[18,1]+apTabApu[18,2],opFont1)
	oPrn:Say(1765,2130,AliDir(apTabApu[18,4],"@E 999,999,999.99"),opFont3)
	oPrn:Line(1820,0020,1820,2355)
	
	oPrn:Say(1835,0025,apTabApu[19,1]+apTabApu[19,2],opFont1)
	oPrn:Say(1835,2130,AliDir(apTabApu[19,4],"@E 999,999,999.99"),opFont3)
	oPrn:Line(1870,0020,1870,2355)	                        
	
	oPrn:Say(1885,0025,apTabApu[20,1]+apTabApu[20,2],opFont1)
	oPrn:Say(1885,2130,AliDir(apTabApu[20,4],"@E 999,999,999.99"),opFont3)
	oPrn:Line(1930,0020,1930,2355)	                        
	

	oPrn:Box(1945,0020,2230,2355)
	oPrn:Say(1960,0025,STR0048,opFont1) //"IV. PENALIDADE"
		
	oPrn:Say(2015,0025,apTabApu[21,1]+apTabApu[21,2],opFont1)
	oPrn:Say(2015,2130,AliDir(apTabApu[21,4],"@E 999,999,999.99"),opFont3)
	oPrn:Line(2060,0020,2060,2355)
	                              
                       
	oPrn:Say(2075,0025,apTabApu[22,1]+apTabApu[22,2],opFont1)
	oPrn:Say(2075,2130,AliDir(apTabApu[22,4],"@E 999,999,999.99"),opFont3)
	oPrn:Line(2110,0020,2110,2355)
	
	oPrn:Say(2125,0025,apTabApu[23,1]+apTabApu[23,2],opFont1)
	oPrn:Say(2125,2130,AliDir(apTabApu[23,4],"@E 999,999,999.99"),opFont3)
	oPrn:Line(2170,0020,2170,2355)

	oPrn:Say(2185,0025,apTabApu[24,1]+apTabApu[24,2],opFont1)
	oPrn:Say(2185,2130,AliDir(apTabApu[24,4],"@E 999,999,999.99"),opFont3)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³     JURAMENTO       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	
	oPrn:Box(2350,0020,2410,2355)
	oPrn:Say(2365,1130,STR0049,opFont1)  //"JURAMENTO"
	
	oPrn:Say(2420,0025,STR0050,opFont1) //"Declaro bajo la fe de juramento que los datos consignados en la presente declaración son correctos y completos y que no he omitido ni falseado dato alguno que"
	oPrn:Say(2460,0025,STR0051,opFont1) //"la misma deba contener siendo todo su contenido la fiel expresión de verdad"
		
Return() 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    AliDir()   ³ Autor ³ Paulo Augusto ³	      Data ³26/04/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Função que faz a impressão dos registros					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AliDir(nVlr,cPicture)	                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nVlr: valor a ser alinhado  cPicture: picture do valor     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cRet: valor alinhado a direita							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Rep. Dominicana	                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function AliDir(nVlr,cPicture)
	Local cRet:=""
	
	If Len(Alltrim(Str(Int(nVlr))))==9                    
		cRet:=PADL(" ",1," ")+alltrim(Transform(nVlr,cPicture))
	ElseIf Len(Alltrim(Str(Int(nVlr))))==8                    
		cRet:=PADL(" ",3," ")+alltrim(Transform(nVlr,cPicture))
	ElseIf Len(Alltrim(Str(Int(nVlr))))==7                    
		cRet:=PADL(" ",5," ")+alltrim(Transform(nVlr,cPicture))
	ElseIf Len(Alltrim(Str(Int(nVlr))))==6                    
		cRet:=PADL(" ",8," ")+alltrim(Transform(nVlr,cPicture))
	ElseIf Len(Alltrim(Str(Int(nVlr))))==5                     
		cRet:=PADL(" ",10," ")+alltrim(Transform(nVlr,cPicture))
	ElseIf Len(Alltrim(Str(Int(nVlr))))==4                       
		cRet:=PADL(" ",12," ")+alltrim(Transform(nVlr,cPicture))
	ElseIf Len(Alltrim(Str(Int(nVlr))))==3                    
		cRet:=PADL(" ",15," ")+alltrim(Transform(nVlr,cPicture))
	ElseIf Len(Alltrim(Str(Int(nVlr))))==2               
		cRet:=PADL(" ",17," ")+alltrim(Transform(nVlr,cPicture))
	ElseIf Len(Alltrim(Str(Int(nVlr))))==1         
		cRet:=PADL(" ",19," ")+alltrim(Transform(nVlr,cPicture))
	Endif 
Return cRet
