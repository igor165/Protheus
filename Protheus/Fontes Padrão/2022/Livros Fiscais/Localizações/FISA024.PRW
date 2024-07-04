#INCLUDE "FISA024.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
                                                                               
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FISA024    ³ Autor ³ Camila Januário      ³ Data ³19/04/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Apuracao de impostos ISC - IST01   	    			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FISA024()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                      								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Republica Dominicana 									  ³±± 
±±³          ³ 															  ³±±
±±           ³ Declaración y/o pago del impuesto selectivo a las          ³±±
±±			 ³ telecomunicaciones IST                      				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  

Function FISA024()
Local 	aArea	 := GetArea()
Local 	cCadastro:= STR0001 //"Apuração de Impostos"
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
Private cPerg	 := "FISA024"

aAdd(aSays,STR0002) //"Esta rotina tem a finalidade de efetuar a apuração dos impostos ISC:"
aAdd(aSays,STR0003)  //"Apuração"
aAdd(aButtons,{5,.T.,{ || lPerg := Pergunte(cPerg,.T.) }})
aAdd(aButtons,{1,.T.,{ || nxOpc := 1,FechaBatch()      }})
aAdd(aButtons,{2,.T.,{ || nxOpc := 0,FechaBatch()      }})
FormBatch(cCadastro,aSays,aButtons)      

//********************
//Parametros FISA024 
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
±±³Fun‡…o    ³ImpIST01  ³ Autor ³ Camila Januário 		³ Data ³26/04/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera o conteúdo das linhas da apuração IST01               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ImpIST01()                                                 ³±±
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
Function ImpIST01(aDadGer)

	Local n1:= 0 //Total de Operaciones
	Local n2:= 0 //Ingresos Gravados
	Local n3:= 0 //Impuesto a Pagar (Aplicar el 10% a la casilla 2)
	Local n4:= 0 //saldos compensables autorizados
	Local n5:= 0 //saldo a favor anterior 
	Local n6:= 0 //pagos computables a cuentas
    Local n7:= 0 //diferencia a pagar (si el valor de las casillas 3-4-5-6 es positivo
	Local n8:= 0 //nuevo saldo a favor (si el valor de las casillas 3-4-5-6 es negativo	
	Local n9:= 0 //recargos
	Local n10:= 0 //interés indemnizatorio
	Local n11:= 0 //sanciones
	Local n12:= 0 //total a pagar (sumar casillas 7+9+10+11)
	
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
	
   	If File(cpDir+cNomTxt) .and. ApMsgYesNo(STR0004) //"Periodo ja apurado. Deseja refazer?"
		MsgRun(STR0005,,{|| lExclTit := DelTitApur(cNomTxt)})  //"Cancelando apuracao anterior"
		If !lExclTit			
			ApMsgStop(STR0006,STR0007) //"O titulo já foi baixado.Apenas será possível excluir o título gerado e baixado anteriormente se for estornado." //"Titulo ja foi baixado"###"Apenas será possível excluir o título gerado e baixado anteriormente se for estornado"
			Return nil
		Endif			
	Else
		If File(cpDir+cNomTxt) 
			MsgRun(STR0008,,{|| lExclTit := FMApur(substr(cNomTxt,1,17))})//"Gerando Relatório de Conferencia"			 //"Gerando Relatorio Conferencia"
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
		cQuerySD2 += "SD2.*, B1_COD, B1_CONISC, CCR_CONCEP, CCR_APUR, F2_ESPECIE "
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
		cQuerySD2 += "WHERE CCR_APUR = '1' "
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
				nTotSD2 -= TOTSD2->D2_TOTAL
				nIngSD2 -= TOTSD2->D2_VALIMP2
			Else
				nTotSD2 += TOTSD2->D2_TOTAL
				nIngSD2 += TOTSD2->D2_VALIMP2
			EndIf				
			TOTSD2->(DbSkip())		
        EndDo
        
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄe 
   		//³Seleciona os itens de entrada de acordo com o produto, conceito e tipo de apuração ( IST )    ³
   		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄe
        
        cQuerySD1 += "SELECT DISTINCT "
		cQuerySD1 += "SD1.*, B1_COD, B1_CONISC, CCR_CONCEP, CCR_APUR, F1_ESPECIE "
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
		cQuerySD1 += "WHERE CCR_APUR = '1' "
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
				nTotSD1 -= TOTSD1->D1_TOTAL
				nIngSD1 -= TOTSD1->D1_VALIMP2
			Else
				nTotSD1 += TOTSD1->D1_TOTAL
				nIngSD1 += TOTSD1->D1_VALIMP2
			EndIf
			TOTSD1->(DbSkip())		
        EndDo
        
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄe 
   		//³Faz a soma e subtração das linhas da apuração   ³
   		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄe
        
        n1 := nTotSD2+nTotSD1       
        n2 := nIngSD2+nIngSD1
                
        n3 := (n2*10)/100
        
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄe 
   		//³Carregar valores informativos do wizard  ³
   		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄe
                
        n4 := Val(aDadGer[1,1]) 
        
        If Val(aDadGer[1,2]) > 0
            n5:= Val(aDadGer[1,2]) 	
        Else
        	n5 := FPerAnt(cArqAnt,"08")       
        EndIf       
        //n5 := IIF(Empty(aDadGer[1,2]),FPerAnt(cArqAnt,"05"),Val(aDadGer[1,2]))        
        n6 := Val(aDadGer[1,3])                
        n9 := Val(aDadGer[1,4])
        n10 := Val(aDadGer[1,5])
        n11 := Val(aDadGer[1,6])
        
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄe 
   		//³Soma os últimos montantes a pagar das linhas de apuração³
   		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄe
		
		If (n3-n4-n5-n6) > 0
			n7 := n3-n4-n5-n6
		Else	  
			n8 := n3-n4-n5-n6
		EndIF	
		
		n12 := n7+n9+n10+n11		
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Carrega o array com o conteúdo das linhas da apuração³
   		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   		 
   		aAdd(apTabApu,{"01"   ,STR0009,n1	,.F.}) //"Total de Operaciones"
   		aAdd(apTabApu,{"02"   ,STR0010,n2	,.F.}) //"Ingresos Gravados"
   		aAdd(apTabApu,{"03"   ,STR0011,n3	,.F.}) //"Impuestos a Pagar"
		aAdd(apTabApu,{"04"   ,STR0012,n4	,.F.}) //"Saldos Compensables Autorizados"
		aAdd(apTabApu,{"05"   ,STR0013,n5	,.F.}) //"Saldo a Favor Anterior"
   		aAdd(apTabApu,{"06"   ,STR0014,n6	,.F.}) //"Pagos Computables a Cuentas"
   		aAdd(apTabApu,{"07"   ,STR0015,n7	,.F.}) //"Diferencia a pagar (si el valor de las casillas 3-4-5-6 es positivo)"
		aAdd(apTabApu,{"08"   ,STR0016,n8	,.F.})  //"Nuevo Saldo a Favor (si el valor de las casillas 3-4-5-6 es negativo)"
		aAdd(apTabApu,{"09"   ,STR0017,n9	,.F.}) //"Recargos"
   		aAdd(apTabApu,{"10"   ,STR0018,n10	,.F.}) //"Interés Indemnizatorio"
   		aAdd(apTabApu,{"11"   ,STR0019,n11	,.F.}) //"Sanciones"
		aAdd(apTabApu,{"12"   ,STR0020,n12	,.F.}) //"Total a Pagar"
   		
	EndIF
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gera relatório de conferencia dos dados ³
   	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	FRConfIST()                         

   	If !llMDados 	
		If lGerTit
			MsgRun(STR0021,,{|| IIf(n12>0,aTitulos := GrvTitLoc(n12),Nil) }) //"Gerando titulo de apuração..." // //"Gerando titulo de apuração..."
		Endif
		
		MsgRun(STR0022,,{|| CriarArq(cNomTxt,apTabApu,aTitulos) })//"Gerando Arquivo apuração de imposto..."	 //"Gerando Arquivo apuração de imposto..."
	EndIf	
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FPerant   ³ Autor ³ Camila Januário       ³ Data ³02/08/2010³±±
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
			Alert(STR0023) //"Erro na abertura do arquivo da apuração anterior"
			Return Nil		
		EndIf	  
	Endif
Return nResAnt

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CriarArq  ³ Autor ³ Camila Januário       ³ Data ³26/04/2011³±±
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
		ApMsgStop(STR0024) // "Ocorreu um erro ao criar o arquivo" //"Ocorreu erro ao criar o arquivo"
	Endif  
	
	nlCont := 0
	For nlCont := 1 to Len(aImp)
		cLinha := "IMP"							+ Space(5) // Clausula que indica a linha
		cLinha += aImp[nlCont][1]				+ Space(5) // Codigo de linha 
		cLinha += Padr(aImp[nlCont][2],105)		+ Space(5) // Descrição da linha
		cLinha += Transform(aImp[nlCont][3],"@E 999,999,999.99")	+ Space(5) // Valor da linha
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
±±³Fun‡…o    FMApur   ³ Autor ³ Camila Januário         ³ Data ³26/04/2011³±±
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
		Alert(STR0025)//"Erro na abertura do arquivo" /
		lRet := .F.
	EndIF
	
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ DelTitApur   ³ Autor ³ Camila Januário   ³ Data ³26/04/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Excluir o titulo de apuração para o governo.				  ³±±	
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DelTitApur() 		                                       ³±±
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
		Alert(STR0025) //"Erro na abertura do arquivo"
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
±±³Função    FRConfIST() ³ Autor ³ Camila Januário     ³ Data ³26/04/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Função que cria o objeto do TMSPRINTER e chama as funções  ³±±
±±³ 		 | de impressão do cabeçalho e do corpo do relatorio		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FRConfIST()			                                      ³±±
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

Static Function FRConfIST()
    Private clTitulo 	:= STR0026 //"Relatório de Conferência de Informações"
	Private opFont1		:= TFont():New("Calibri",,8,,.T.,,,,,.F.) //titulos II Operaciones, III Penalidades, IV Monto
	Private opFont2  	:= TFont():New("Arial",,8,,.T.,,,,,.F.) //descritivos
	Private opFont3  	:= TFont():New("Arial",,8,,.F.,,,,,.F.) // valores
	Private opFont4  	:= TFont():New("Georgia",,23,,.F.,,,,,.F.) //DGII
	Private opFont5  	:= TFont():New("Georgia",,12,,.F.,,,,,.F.) //DIRECCION GENERAL DE IMPUESTOS INTERNOS
	Private opFont6  	:= TFont():New("Georgia",,12,,.F.,,,,,.F.) //DECLARACION Y/O PAGO DEL IMPUESTO
	    
	oPrn := TmsPrinter():New(clTitulo)
	oPrn:SetPaperSize(9)
	oPrn:SetPortrait()
	oPrn:StartPage()
    
	CabecIST()
	ImpRegIST()
       
	oPrn:EndPage()
	oPrn:Preview()
	oPrn:End()
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    CabecIST() ³ Autor ³ Camila Januário       ³ Data ³19/04/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Função que faz a impressão do cabeçalho					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CabecIST()				                                  ³±±
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

Static Function CabecIST()

	oPrn:Say(0100,0025,"DGII",opFont4)
	oPrn:Say(0090,0280,STR0027,opFont5) //"DIRECCION GENERAL DE IMPUESTOS INTERNOS"
	oPrn:Say(0160,0280,STR0028,opFont6) //"DECLARACIÓN Y/O PAGO DEL IMPUESTO SELECTIVO A LAS TELECOMUNICACIONES"
	oPrn:Say(0100,2065,"IST-01",opFont4)
	 
	
	oPrn:Box(0300,0020,0250,2355)//450	

	oPrn:Say(0255,0025,STR0029,opFont1)//"I-DATOS GENERALES //"I. DATOS GENERALES"
	
	oPrn:Say(0305,0025,STR0030,opFont2) //"Rectificativa: NO"
	
	oPrn:Say(0305,0355,STR0031,opFont2)  //"Periodo"
	oPrn:Say(0305,0485,MV_PAR01,opFont3) 
	
	oPrn:Say(0355,0025,STR0032,opFont2) //"RNC:"
	oPrn:Say(0355,0105,SM0->M0_CGC,opFont3)
	
	oPrn:Say(0355,0355,STR0033,opFont2) //"Razón Social:"
	oPrn:Say(0355,0585,SM0->M0_NOME,opFont3)	
	
	oPrn:Say(0405,0025,STR0034,opFont2) //"Nombre Comercial:"
	oPrn:Say(0405,0355,SM0->M0_NOMECOM,opFont3)
	
	oPrn:Say(0455,0025,STR0035,opFont2) //"Teléfono:"
	oPrn:Say(0455,0185,SM0->M0_TEL,opFont3)
	
	oPrn:Say(0455,0455,STR0036,opFont2) //"Fax:"
	oPrn:Say(0455,0585,SM0->M0_TEL,opFont3)
	
	//oPrn:Say(0455,0850,STR0037,opFont2) //"Correo Electronico:"
	//oPrn:Say(0455,1180,MV_PAR06,opFont3) //mv-par	
	
	oPrn:Box(0505,0020,0250,2355)  
	
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ImpRegIST ³ Autor ³ Camila Januário        ³ Data ³26/04/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Função que faz a impressão dos registros					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ImpRegIST()				                                  ³±±
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
Static Function ImpRegIST()
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³II. OPERACIONES³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		
	oPrn:Box(0540,0020,0600,2355)
	oPrn:Say(0545,0025,STR0038,opFont1) //"II. OPERACIONES"

   	oPrn:Box(0600,0020,2000,2355)
   	
   	oPrn:Say(0655,0025,"1.",opFont1)
	oPrn:Say(0655,0075,STR0009,opFont1)                       	 //"Total de Operaciones"
	oPrn:Say(0655,1900,"=",opFont1)	
	oPrn:Say(0655,2130,AliDir(Round(apTabApu[1,3],2),"@E 999,999,999.99"),opFont3)
	oPrn:Line(0700,0020,0700,2355)	 
	
   	oPrn:Say(0715,0025,"2.",opFont1)
	oPrn:Say(0715,0075,STR0010,opFont1)                       	 //"Ingresos Gravados"
	oPrn:Say(0715,1900,"+",opFont1)	
	oPrn:Say(0715,2130,AliDir(Round(apTabApu[2,3],2),"@E 999,999,999.99"),opFont3)
	oPrn:Line(0760,0020,0760,2355)
	
	oPrn:Say(0775,0025,"3.",opFont1)
	oPrn:Say(0775,0075,STR0039,opFont1)                       	 //"Impuestos a Pagar (aplicar el 10% a la casilla 2)"
	oPrn:Say(0775,1900,"=",opFont1)	
	oPrn:Say(0775,2130,AliDir(Round(apTabApu[3,3],2),"@E 999,999,999.99"),opFont3)
	oPrn:Line(0820,0020,0820,2355)
	
	oPrn:Say(0835,0025,"4.",opFont1)
	oPrn:Say(0835,0075,STR0040,opFont1)                       	 //"Saldos Compensables Autorizado (Otros Impuestos)"
	oPrn:Say(0835,1900,"-",opFont1)	
	oPrn:Say(0835,2130,AliDir(Round(apTabApu[4,3],2),"@E 999,999,999.99"),opFont3)
	oPrn:Line(0880,0020,0880,2355)
	
	oPrn:Say(0905,0025,"5.",opFont1)
	oPrn:Say(0905,0075,STR0013,opFont1)                       	 //"Saldo a Favor Anterior"
	oPrn:Say(0905,1900,"-",opFont1)	
	oPrn:Say(0905,2130,AliDir(Round(apTabApu[5,3],2),"@E 999,999,999.99"),opFont3)
	oPrn:Line(0950,0020,0950,2355)
	
	oPrn:Say(0965,0025,"6.",opFont1)
	oPrn:Say(0965,0075,STR0014,opFont1)                       	 //"Pagos Computables a Cuentas"
	oPrn:Say(0965,1900,"-",opFont1)	
	oPrn:Say(0965,2130,AliDir(Round(apTabApu[6,3],2),"@E 999,999,999.99"),opFont3)
	oPrn:Line(1010,0020,1010,2355)
	
	oPrn:Say(1025,0025,"7.",opFont1)
	oPrn:Say(1025,0075,STR0015,opFont1)                       	 //"Diferencia a Pagar (Si el valor de las casillas 3-4-5-6 es Positivo)"
	oPrn:Say(1025,1900,"=",opFont1)	
	oPrn:Say(1025,2130,AliDir(Round(apTabApu[7,3],2),"@E 999,999,999.99"),opFont3)
	oPrn:Line(1070,0020,1070,2355)
	
	oPrn:Say(1085,0025,"8.",opFont1)
	oPrn:Say(1085,0075,STR0041,opFont1)                       	 //"Diferencia a Pagar Si el valor de las casillas 3-4-5-6 es Negativo)"
	oPrn:Say(1085,1900,"=",opFont1)	
	oPrn:Say(1085,2130,AliDir(Round(apTabApu[8,3],2),"@E 999,999,999.99"),opFont3)
	oPrn:Line(1130,0020,1130,2355)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³III. PENALIDADES³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	
	oPrn:Box(1185,0020,1245,2355)
	oPrn:Say(1190,0025,STR0042,opFont1) //"III. PENALIDADES"
	
	oPrn:Say(1285,0025,"9.",opFont1)
	oPrn:Say(1285,0075,STR0043,opFont1)                       	 //"Reacargo"
	oPrn:Say(1285,1900,"+",opFont1)	
	oPrn:Say(1285,2130,AliDir(Round(apTabApu[9,3],2),"@E 999,999,999.99"),opFont3)
	oPrn:Line(1330,0020,1330,2355)
	
	oPrn:Say(1345,0025,"10.",opFont1)
	oPrn:Say(1345,0075,STR0044,opFont1)                       	 //"Interes Indemnizatorio"
	oPrn:Say(1345,1900,"+",opFont1)	
	oPrn:Say(1345,2130,AliDir(Round(apTabApu[10,3],2),"@E 999,999,999.99"),opFont3)
	oPrn:Line(1390,0020,1390,2355)
	
	oPrn:Say(1405,0025,"11.",opFont1)
	oPrn:Say(1405,0075,STR0019,opFont1)                       	 //"Sanciones"
	oPrn:Say(1405,1900,"+",opFont1)	
	oPrn:Say(1405,2130,AliDir(Round(apTabApu[11,3],2),"@E 999,999,999.99"),opFont3)
	oPrn:Line(1450,0020,1450,2355)
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³IV. MONTO A PAGAR³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ 
	
	oPrn:Box(1505,0020,1565,2355)
	oPrn:Say(1510,0025,STR0045,opFont1) //"IV. MONTO A PAGAR"
	
	oPrn:Say(1600,0025,"12.",opFont1)
	oPrn:Say(1600,0075,STR0020,opFont1)                       	 //"Total a Pagar"
	oPrn:Say(1600,1900,"=",opFont1)	
	oPrn:Say(1600,2130,AliDir(Round(apTabApu[12,3],2),"@E 999,999,999.99"),opFont3)
	oPrn:Line(1645,0020,1645,2355)	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³     JURAMENTO       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	
	oPrn:Box(1680,0020,1740,2355)
	oPrn:Say(1685,1130,STR0046,opFont1)  //"JURAMENTO"
	
	oPrn:Say(1775,0025,STR0047,opFont1) //"Declaro bajo la fe de juramento que los datos consignados en la presente declaración son correctos y completos y que no he omitido ni falseado dato alguno que"
	oPrn:Say(1835,0025,STR0048,opFont1) //"la misma deba contener siendo todo su contenido la fiel expresión de verdad"
			
Return() 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    AliDir()³ Autor ³ Camila Januário ³	      Data ³26/04/2011³±±
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
