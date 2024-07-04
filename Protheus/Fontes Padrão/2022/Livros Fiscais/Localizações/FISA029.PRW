#INCLUDE "FISA029.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
                                                                               
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FISA029    ³ Autor ³ Camila Januário      ³ Data ³04/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Apuracao de impostos - Declaración Jurada ITBIS		      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FISA029()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                      								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Republica Dominicana 									  ³±± 
±±³          ³ 															  ³±±
±±           ³ Declaración Jurada ITBIS - Impuestos Sobre La Transferencia³±±
±±			 ³ de Bienes Industrializados y Servicios 					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  

Function FISA029()
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
Private cPerg	 := "FISA029"

aAdd(aSays,STR0002) //"Esta rotina tem a finalidade de efetuar a apuração dos impostos ISC calculados pelo sistema:" //"Esta rotina tem a finalidade de efetuar a apuração e apresentar a Declaracção Jurada ITBIS"
aAdd(aSays,STR0003) //"Apuração"
aAdd(aButtons,{5,.T.,{ || lPerg := Pergunte(cPerg,.T.) }})
aAdd(aButtons,{1,.T.,{ || nxOpc := 1,FechaBatch()      }})
aAdd(aButtons,{2,.T.,{ || nxOpc := 0,FechaBatch()      }})
FormBatch(cCadastro,aSays,aButtons)      

//********************
//Parametros FISA029 
//********************
//MV_PAR01 - Periodo
//MV_PAR02 - Arquivo de Periodo Anterior
//MV_PAR03 - Arquivo de Configuracao
//MV_PAR04 - Arquivo de Destino
//MV_PAR05 - Diretorio
//MV_PAR06 - E-mail
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
±±³Fun‡…o    ³ImpITBIS  ³ Autor ³ Camila Januário 		³ Data ³04/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera o conteúdo das linhas da apuração - Declaración Jurada³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ImpITBIS()                                                 ³±±
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
Function ImpITBIS(aDadGer)

	Local n1:= 0  //total de operaciones del periodo
	Local n2:= 0  //ingresos por exportaciones
	Local n3:= 0  //ingresos por venta en republica dominicana de bienes o servicios exentos
	Local n4:= 0  //total ingresos por operaciones no gravadas (sumar casilla 2+3) 
	Local n5:= 0  //ingresos por operaciones gravadas (restar casillas 1-4)
	Local n6:= 0  //itbis cobrado (16% a la casilla 5)
    Local n7:= 0  //itbis pagado en compras locales
	Local n8:= 0  //itbis pagado por servicios deducibles
	Local n9:= 0  //itbis pagado en importaciones
	Local n10:= 0 //total itbis pagado (sumar casillas 7+8+9)
	Local n11:= 0 //impuesto a pagar (si el valor de las casillas 6-10 es positivo)
	Local n12:= 0 //saldo a favor (si el valor de las casillas 6-10 es negativo)
	Local n13 := 0 //saldos compensables autorizados (otros impuestos)
	Local n14 := 0 //saldo a favor anterior
	Local n15 := 0 //pagos computables por retenciones (norma no 8-04)
	Local n16 := 0 //pagos computables por otras retenciones (norma no 2-05)
	Local n17 := 0 //otros pagos computables a cuentas
	Local n18 := 0 //diferencia a pagar (si el valor de las casillas 11-13-14-15-16-17 es Positivo)
	Local n19 := 0 //nuevo saldo a favor (si el valor de las casillas 11-13-14-15-16-17 es Negativo) ó (12+13+14+15+16+17)
	Local n20 := 0 //recargos
	Local n21 := 0 //interes indemnizatorio
	Local n22 := 0 //sanciones
	Local n23 := 0 //total a pagar (sumar casillas 18+20+21+22)
	Local n24 := 0 //servicios sujetos a retencion personas fisicas y entidades no lucrativas
	Local n25 := 0 //servicios sujetos a retencion sociedades
	Local n26 := 0 //servicios sujetos a retencion sociedades sujetas (norma no 2-05)
	Local n27 := 0 //bienes o servicios sujetos a retencion a contribuyentes acogidos al PST
	Local n28 := 0 //bienes sujetos a retencion proveedores informales (norma 08-2010)
	Local n29 := 0 //itbis retenido por servicios sujetos a retencion personas físicas y entidades no lucrativas (16% casilla 24)
	Local n30 := 0 //itbis retenido por servicios sujetos a retencion sociedades (16% casilla 25)
	Local n31 := 0 //itbis retenido por servicios sujetos a retencion soiceideades (16% casilla 26 por 0.30 norma 2-05)
	Local n32 := 0 //itbis retenido a contribuyentes acogidos al PST (16% casilla 27)
	Local n33 := 0 //itbis retenido por bienes sujetos a rentecion proeveedores informales (16% casilla 28 por 0.75 norma 08-2010)
	Local n34 := 0 //impuesto a pagar (sumar casillas 29+30+31+32+33)
	Local n35 := 0 //saldo a favor anterior (itbis retenido)
	Local n36 := 0 //pagos computables a cuenta (itbis retenido)
	Local n37 := 0 //diferencia a pagar (si el valor de las casillas 24-35-36 es positivo)
	Local n38 := 0 //nuevo saldo a favor (si el valor de las casillas 34-35-36 es negativo)
	Local n39 := 0 //recargos ***retencoes
	Local n40 := 0 //interes indemnizatorio ***retencoes
	Local n41 := 0 //sanciones ***retencoes
	Local n42 := 0 //total a pagar (sumar casillas 37+39+40+41)
	Local n43 := 0	
	
	Local cQueryF3 := ""
	Local cUFCliFor	:= ""      
	Local cArqAnt	:= "" 
	Local lArqAnt	:= .F.
	Local alImposto	:= {}
	Local nlRtAc	:= 0
	Local llMDados 	:= .F.
	Local clLivro	:= ""
	Private cNomTxt := "" 
	Private cImpDesc:= ""
	Private	apTabApu:= {}	

	cNomTxt:= MV_PAR01+"-"+Alltrim(MV_PAR04)+"-"+cEmpAnt+cFilAnt+"."+"IT1"	

	lArqAnt		:=Iif(!Empty(MV_PAR02),.T.,.F.)
	cArqAnt		:=Alltrim(MV_PAR02)	
	
   	If Empty(MV_PAR01)
   		MsgAlert(STR0004)   		 //"Informar o período AAAAMM"
   		Return Nil
   	EndIf
   	
   	If Empty(MV_PAR03)
   		MsgAlert(STR0005) //"Informar o arquivo de configuração DGIIITBS"
   		Return Nil   	
   	EndIf
   	
   	If Empty(MV_PAR05)
   		MsgAlert(STR0006) //"Informar o diretório de geração do arquivo"
   		Return Nil   	
   	EndIf
   	 	
   	
   	cQueryF3 += "SELECT DISTINCT "
   	cQueryF3 += "SF3.*, A2_COD, A2_LOJA, A2_TIPO, A2_EST, A1_COD, A1_LOJA, A1_TIPO, A1_EST "
   	cQueryF3 += "FROM "+RetSqlName("SF3")+ " SF3 "
   	cQueryF3 += "LEFT JOIN "+RetSqlName("SA2")+ " SA2 ON "
   	cQueryF3 += "A2_COD = F3_CLIEFOR "
   	cQueryF3 += "AND A2_LOJA = F3_LOJA "
   	cQueryF3 += "AND A2_FILIAL = '"+xFilial("SA2")+"' "
   	cQueryF3 += "AND SA2.D_E_L_E_T_ = ''"
   	cQueryF3 += "LEFT JOIN "+RetSqlName("SA1")+ " SA1 ON "
   	cQueryF3 += "A1_COD = F3_CLIEFOR "
   	cQueryF3 += "AND A1_LOJA = F3_LOJA "
   	cQueryF3 += "AND A1_FILIAL = '"+xFilial("SA1")+"' "
   	cQueryF3 += "AND SA1.D_E_L_E_T_ = '' "
   	cQueryF3 += "WHERE F3_EMISSAO LIKE '%"+SubStr(mv_par01,1,6)+"__' "
   	cQueryF3 += "AND SF3.D_E_L_E_T_ = '' " 	
   
   	
   	If Select("QUERYSF3")>0
		DbSelectArea("QUERYSF3")
		QUERYSF3->(DbCloseArea())
	Endif
				                              
	TcQuery cQueryF3 New Alias "QUERYSF3"	
		
	DbSelectArea("QUERYSF3")
	Do While QUERYSF3->(!Eof())
	                            //"NF|NDC|NCE|NDI|NCP"
		
		//VENDAS E COMPRAS - CALCULO DE ITBIS  
		
		If Alltrim(QUERYSF3->F3_ESPECIE) == "NF" .AND. (QUERYSF3->F3_BASIMP1) > 0 
						
			If (QUERYSF3->F3_TIPOMOV) == "V" 
				n1 += QUERYSF3->F3_BASIMP1
						
				If (QUERYSF3->F3_EXENTAS) > 0 
			  		If (QUERYSF3->A1_EST) == "EX"
			   			n2 += QUERYSF3->F3_EXENTAS	
			  		Else
				  		n3 += QUERYSF3->F3_EXENTAS
					EndIF					   		
				EndIf
			Else
				If (QUERYSF3->A2_EST) <> "EX"
					n7 += QUERYSF3->F3_VALIMP1	
				Else
				    n9 += QUERYSF3->F3_VALIMP1	
				EndIF							   					
			EndIf
		    
	    EndIf
	    
	    If Alltrim(QUERYSF3->F3_ESPECIE) $ "NDC|NCE" .AND. (QUERYSF3->F3_BASIMP1) > 0 
	    	
	    	n1 += QUERYSF3->F3_BASIMP1
			
			If (QUERYSF3->F3_EXENTAS) > 0 
				If (QUERYSF3->A1_EST) == "EX"
		   			n2 += QUERYSF3->F3_EXENTAS
		  		Else
				  	n3 += QUERYSF3->F3_EXENTAS	
		  		EndIF					   		
			EndIf	
		EndIf
		
	    If Alltrim(QUERYSF3->F3_ESPECIE) $ "NDI|NCP" .AND. (QUERYSF3->F3_BASIMP1) > 0 
	    	
	    	n1 -= QUERYSF3->F3_BASIMP1
			
			If (QUERYSF3->F3_EXENTAS) > 0 
				If (QUERYSF3->A1_EST) == "EX"
		   			n2 += QUERYSF3->F3_EXENTAS
		  		Else
				  	n3 += QUERYSF3->F3_EXENTAS	
		  		EndIF					   		
			EndIf	
		EndIf
		
		If Alltrim(QUERYSF3->F3_ESPECIE) $ "NCI|NDP" .AND. (QUERYSF3->F3_BASIMP1) > 0 
	    	
	    	If (QUERYSF3->A2_EST) <> "EX"
				n7 += QUERYSF3->F3_VALIMP1	
			Else
			    n9 += QUERYSF3->F3_VALIMP1	
			EndIf	
		EndIf
		
		If Alltrim(QUERYSF3->F3_ESPECIE) $ "NCC|NDE" .AND. (QUERYSF3->F3_BASIMP1) > 0 
	    	
	    	If (QUERYSF3->A2_EST) <> "EX"
				n7 += QUERYSF3->F3_VALIMP1	
			Else
			    n9 += QUERYSF3->F3_VALIMP1	
			EndIf	
		EndIf
				
	    //COMPRAS COM RETENCAO DE ITBIS
	    
	    If (QUERYSF3->F3_VALIMP3) > 0		
	    	
	    	If (QUERYSF3->A2_TIPO) $ "1|3"  //física ou não lucrativa
	    		n24 += QUERYSF3->F3_BASIMP3	
	    	Else
	       		n25 += QUERYSF3->F3_BASIMP3	
	    	EndIf	    				
		EndIf		
								
		QUERYSF3->(DbSkip())		
    EndDo 
   		
   	n8 := IIF(Val(aDadGer[1,1])>0,Val(aDadGer[1,1]),0) //itbis pagado por servicios
   	n13:= IIF(Val(aDadGer[1,2])>0,Val(aDadGer[1,2]),0) //saldos compensabeles autorizados    	
   	n15:= IIF(Val(aDadGer[1,3])>0,Val(aDadGer[1,3]),0) //pagos computables por retenciones
   	n16:= IIF(Val(aDadGer[1,4])>0,Val(aDadGer[1,4]),0) //pagos computables por otras retenciones
   	n17:= IIF(Val(aDadGer[1,5])>0,Val(aDadGer[1,5]),0) //otros pagos computables a cuentas
   	n20:= IIF(Val(aDadGer[1,6])>0,Val(aDadGer[1,6]),0) //recargos
   	n21:= IIF(Val(aDadGer[1,7])>0,Val(aDadGer[1,7]),0) //interes indemnizatorio
   	n22:= IIF(Val(aDadGer[1,8])>0,Val(aDadGer[1,8]),0) //sanciones       
    n26:= IIF(Val(aDadGer[1,9])>0,Val(aDadGer[1,9]),0) //servicios sujetos a retención sociedades sujetas
    n27:= IIF(Val(aDadGer[1,10])>0,Val(aDadGer[1,10]),0) //contribuyentes alcogidos pst
   	n28:= IIF(Val(aDadGer[1,11])>0,Val(aDadGer[1,11]),0) //bienes o servicios sujetos a retención proveedores informales 
   	n36:= IIF(Val(aDadGer[1,12])>0,Val(aDadGer[1,12]),0)//pagos computables a cuentas itbis retenido   		
   	n39:= IIF(Val(aDadGer[1,13])>0,Val(aDadGer[1,13]),0)//recargos retenc.
   	n40:= IIF(Val(aDadGer[1,14])>0,Val(aDadGer[1,14]),0) //interés indemnizatorio retenc.
   	n41:= IIF(Val(aDadGer[1,15])>0,Val(aDadGer[1,15]),0)//sanciones retec.  
    
    n14:= IIF(Val(aDadGer[1,16])>0,Val(aDadGer[1,16]),FPerAnt(cArqAnt,"19")) //saldo a favor anterior, caso digitado   
    n35 := IIF(Val(aDadGer[1,17])>0,Val(aDadGer[1,17]),FPerAnt(cArqAnt,"38"))  // saldo a favor retenção, caso digitado
    
        
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄe 
   	//³Soma os últimos montantes a pagar das linhas de apuração³
   	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄe
		
	n4 := n2+n3
	n5 := n1-n4
	n6 := (n5*16)/100 //cobrado
	n10 := n7+n8+n9
		
	If (n6-n10) > 0
		n11 := n6-n10
	Else
		n12 := n6-n10
	EndIf
		
	If (n11-n13-n14-n15-n16-n17) > 0
		n18 := n11-n13-n14-n15-n16-n17
	Else
		If (n11-n13-n14-n15-n16-n17) < 0 
			n19 := n11-n13-n14-n15-n16-n17	
		EndIf
		If (n12+n13+n14+n15+n16+n17) < 0 
			n19 := n12+n13+n14+n15+n16+n17
		EndIf		
	EndIf
		
	n23 := n18+n20+n21+n22		
	n29 := (n24*16)/100		
	n30 := (n25*16)/100
	n31 := (((n26*16)/100)*(30/100))
	n32 := (n27*16)/100
	n33 := (((n28*16)/100)*(75/100))
	n34 := n29+n30+n31+n32+n33
	
	If (n34-n35-n36) > 0
		n37 := n34-n35-n36
	Else
		n38 := n34-n35-n36
	EndIf
		
	n42 := n37+n39+n40+n41
	n43 := n23+n42		
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega o array com o conteúdo das linhas da apuração³
   	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   		 
   	aAdd(apTabApu,{"01"   ,STR0007,n1	,.F.}) //"Total de Operaciones" //"Total de Operacoes do Periodo"
   	aAdd(apTabApu,{"02"   ,STR0008,n2	,.F.}) //"Ingresos Gravados" //"Ingressos por Exportaciones"
   	aAdd(apTabApu,{"03"   ,STR0009,n3	,.F.}) //"Impuestos a Pagar" //"Ingressos por Venda na Republica Dominicana de Bens ou Serviços Exentos"
	aAdd(apTabApu,{"04"   ,STR0010,n4	,.F.}) //"Saldos Compensables Autorizados" //"Total Ingressos por Operações não Gravadas (somar lacuna 2+3) "
	aAdd(apTabApu,{"05"   ,STR0011,n5	,.F.}) //"Saldo a Favor Anterior" //"Ingressos por Operacões Gravadas (restar lacunas 1-4)"
   	aAdd(apTabApu,{"06"   ,STR0012,n6	,.F.}) //"Pagos Computables a Cuentas" //"ITBIS Cobrado (16% a lacuna 5)"
   	aAdd(apTabApu,{"07"   ,STR0013,n7	,.F.}) //"Diferencia a pagar (si el valor de las casillas 3-4-5-6 es positivo)" //"ITBIS Pago em Compras Locais"
	aAdd(apTabApu,{"08"   ,STR0014,n8	,.F.})  //"Nuevo Saldo a Favor (si el valor de las casillas 3-4-5-6 es negativo)" //"ITBIS Pago por Serviços Dedutíveis"
	aAdd(apTabApu,{"09"   ,STR0015,n9	,.F.}) //"Recargos" //"ITBIS Pago em Importaciones"
   	aAdd(apTabApu,{"10"   ,STR0016,n10	,.F.}) //"Interés Indemnizatorio" //"Total ITBIS pagos (somar lacunas 7+8+9)"
   	aAdd(apTabApu,{"11"   ,STR0017,n11	,.F.}) //"Sanciones" //"Imposto a pagar (se o valor das lacunas 6-10 é positivo)"
	aAdd(apTabApu,{"12"   ,STR0018,n12	,.F.}) //"Total a Pagar" //"Saldo a Favor (se o valor das lacunas 6-10 é negativo)"
	aAdd(apTabApu,{"13"   ,STR0019,n13	,.F.}) //"Total de Operaciones" //"Saldos Compensáveis Autorizados (outros impostos)"
   	aAdd(apTabApu,{"14"   ,STR0020,n14	,.F.}) //"Ingresos Gravados" //"Saldo a Favor Anterior"
   	aAdd(apTabApu,{"15"   ,STR0021,n15	,.F.}) //"Impuestos a Pagar" //"Pagamentos Computáveis por Retenções (norma no 8-04)"
	aAdd(apTabApu,{"16"   ,STR0022,n16	,.F.}) //"Saldos Compensables Autorizados" //"Pagamentos Computáveis por outras Retenções (norma no 2-05)"
	aAdd(apTabApu,{"17"   ,STR0023,n17	,.F.}) //"Saldo a Favor Anterior" //"Outros Pagamentos Computáveis a contas"
   	aAdd(apTabApu,{"18"   ,STR0024,n18	,.F.}) //"Pagos Computables a Cuentas" //"Diferença a Pagar (se o valor das lacunas 11-13-14-15-16-17 é Positivo)"
   	aAdd(apTabApu,{"19"   ,STR0025,n19	,.F.}) //"Diferencia a pagar (si el valor de las casillas 3-4-5-6 es positivo)" //"Novo Saldo a Favor (se o valor das lacunas 11-13-14-15-16-17 es Negativo)ou(12+13+14+15+16+17)"
	aAdd(apTabApu,{"20"   ,STR0026,n20	,.F.})  //"Nuevo Saldo a Favor (si el valor de las casillas 3-4-5-6 es negativo)" //"Recargos"
	aAdd(apTabApu,{"21"   ,STR0027,n21	,.F.}) //"Recargos" //"Interesse Indenizatório"
   	aAdd(apTabApu,{"22"   ,STR0028,n22	,.F.}) //"Interés Indemnizatorio" //"Sanções"
   	aAdd(apTabApu,{"23"   ,STR0029,n23	,.F.}) //"Sanciones" //"Total a Pagar (somar as lacunas 18+20+21+22)"
	aAdd(apTabApu,{"24"   ,STR0030,n24	,.F.}) //"Total a Pagar" //"Serviços Sujeitos a Retenção de Pessoas Físicas e Entidades não lucrativas"
	aAdd(apTabApu,{"25"   ,STR0031,n25	,.F.}) //"Total de Operaciones"		 //"Serviços Sujeitos a Retenção Sociedades"
   	aAdd(apTabApu,{"26"   ,STR0032,n26	,.F.}) //"Ingresos Gravados" //"Serviços Sujeitos a Retenção Sociedades Sujeitas (norma no 2-05)"
   	aAdd(apTabApu,{"27"   ,STR0033,n27	,.F.}) //"Impuestos a Pagar" //"Bens ou Serviços Sujeitos a Retenção a Contribuientes Acolhidos do PST"
	aAdd(apTabApu,{"28"   ,STR0034,n28	,.F.}) //"Saldos Compensables Autorizados" //"Bens Sujeitos a Retenção Proveedores Informales (norma 08-2010)"
	aAdd(apTabApu,{"29"   ,STR0035,n29	,.F.}) //"Saldo a Favor Anterior" //"ITBIS Retido por Serviços Sujeitos a Retenção Pessoas Físicas e Entidades não Lucrativas (16% lacuna 24)"
   	aAdd(apTabApu,{"30"   ,STR0036,n30	,.F.}) //"Pagos Computables a Cuentas" //"ITBIS Retido por Serviços Sujeitos a Retenção Sociedades (16% lacuna 25)"
   	aAdd(apTabApu,{"31"   ,STR0037,n31	,.F.}) //"Diferencia a pagar (si el valor de las casillas 3-4-5-6 es positivo)" //"ITBIS Retido por Serviços Sujeitos a Retenção Sociedades (16% lacuna 26 por 0.30 norma 2-05)"
	aAdd(apTabApu,{"32"   ,STR0038,n32	,.F.})  //"Nuevo Saldo a Favor (si el valor de las casillas 3-4-5-6 es negativo)" //"ITBIS Retido a Contribuintes Acolhidos do PST (16% lacuna 27)"
	aAdd(apTabApu,{"33"   ,STR0039,n33	,.F.}) //"Recargos" //"ITBIS Retido por Bens Sujeitos a Retenção Fornecedores Informais (16% lacuna 28 por 0.75 norma 08-2010)"
   	aAdd(apTabApu,{"34"   ,STR0040,n34	,.F.}) //"Interés Indemnizatorio" //"Imposto a Pagar (somar lacunas 29+30+31+32+33)"
   	aAdd(apTabApu,{"35"   ,STR0041,n35	,.F.}) //"Sanciones" //"Saldo a Favor Anterior (ITBIS Retido)"
	aAdd(apTabApu,{"36"   ,STR0042,n36	,.F.}) //"Total a Pagar" //"Pagamentos Computáveis a Conta (ITBIS Retido)"
	aAdd(apTabApu,{"37"   ,STR0043,n37	,.F.}) //"Total de Operaciones" //"Diferença a Pagar (se o valor das lacunas 34-35-36 é positivo)"
   	aAdd(apTabApu,{"38"   ,STR0044,n38	,.F.}) //"Ingresos Gravados" //"Novo Saldo a Favor (se o valor das lacunas 34-35-36 é negativo)"
   	aAdd(apTabApu,{"39"   ,STR0026,n39	,.F.}) //"Impuestos a Pagar" //"Recargos"
	aAdd(apTabApu,{"40"   ,STR0027,n40	,.F.}) //"Saldos Compensables Autorizados" //"Interesse Indenizatório"
	aAdd(apTabApu,{"41"   ,STR0028,n41	,.F.}) //"Saldo a Favor Anterior" //"Sanções"
   	aAdd(apTabApu,{"42"   ,STR0045,n42	,.F.}) //"Pagos Computables a Cuentas" //"Total a Pagar (somar as lacunas 37+39+40+41)"
   	aAdd(apTabApu,{"43"   ,STR0046,n43	,.F.}) //"Diferencia a pagar (si el valor de las casillas 3-4-5-6 es positivo)" //"TOTAL GERAL (SOMAR LACUNAS 23+42)"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gera relatório de conferencia dos dados ³
   	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   	  
	FRConfITB()                         

   	If !llMDados 			
		MsgRun(STR0022,,{|| CriarArq(cNomTxt,apTabApu) })//"Gerando Arquivo apuração de imposto..."	 //"Gerando Arquivo apuração de imposto..."
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
	
	clNome := cpDir + cArq + ".IT1"
	
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
			Alert(STR0023) //"Erro na abertura do arquivo da apuração anterior. "
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
Static Function CriarArq(cArq,aImp)
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

	If nHdl > 0
		fClose(nHdl)
	Endif
Return nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    FRConfITB() ³ Autor ³ Camila Januário     ³ Data ³26/04/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Função que cria o objeto do TMSPRINTER e chama as funções  ³±±
±±³ 		 | de impressão do cabeçalho e do corpo do relatorio		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FRConfITB()			                                      ³±±
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

Static Function FRConfITB()
    Private clTitulo 	:= STR0026 //"Relatório de Conferência de Informações"
	Private opFont1		:= TFont():New("Arial",,9,,.T.,,,,,.F.) //titulos 
	Private opFont2  	:= TFont():New("Arial",,8,,.T.,,,,,.F.) //descritivos
	Private opFont3  	:= TFont():New("Arial",,8,,.F.,,,,,.F.) // valores	
	Private opFont4  	:= TFont():New("Georgia",,23,,.F.,,,,,.F.) //DGII
	Private opFont5  	:= TFont():New("Georgia",,12,,.F.,,,,,.F.) //DIRECCION GENERAL DE IMPUESTOS INTERNOS
	Private opFont6  	:= TFont():New("Georgia",,12,,.F.,,,,,.F.) //DECLARACION Y/O PAGO DEL IMPUESTO
	Private opFont7  	:= TFont():New("Arial",,8,,.F.,,,,,.F.) //SUBTITULOS IIA, IIB	
	
	Bold := opFont7:Bold
	    
	oPrn := TmsPrinter():New(clTitulo)
	oPrn:SetPaperSize(9)	
	oPrn:SetLandscape()
	oPrn:StartPage()
    
	CabecITB()
	ImpRegITB()
       
	oPrn:EndPage()
	oPrn:Preview()
	oPrn:End()
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    CabecITB() ³ Autor ³ Camila Januário       ³ Data ³19/04/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Função que faz a impressão do cabeçalho					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CabecITB()				                                  ³±±
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

Static Function CabecITB()

	oPrn:Say(0100,0025,"DGII",opFont4)
	oPrn:Say(0090,0280,STR0047,opFont5)  //"DIRECCION GENERAL DE IMPUESTOS INTERNOS"
	oPrn:Say(0160,0280,STR0048,opFont6)  //"DECLARACIÓN Y/O PAGO DEL IMPUESTO SOBRE LAS TRANSFERENCIAS DE BIENES INDUSTRIALIZADOS Y SERVICIOS"
	oPrn:Say(0100,3150,"IT-1",opFont4)
	 
	
	oPrn:Box(0300,0020,0250,3315)//450	

	oPrn:Say(0255,0025,STR0096,opFont1)//"I-DATOS GENERALES //"I. DATOS GENERALES" //"I. DADOS GERAIS"
	
	oPrn:Say(0305,0025,STR0097,opFont2) //"Rectificativa: NO" //"RECTIFICATIVA: NO"
	
	oPrn:Say(0305,0355,STR0098,opFont2)  //"Periodo" //"Periodo:"
	oPrn:Say(0305,0485,MV_PAR01,opFont3) 
	
	oPrn:Say(0355,0025,STR0099,opFont2) //"RNC:" //"RNC:"
	oPrn:Say(0355,0105,SM0->M0_CGC,opFont3)
	
	oPrn:Say(0355,0355,STR0100,opFont2) //"Razón Social:" //"Razão Social"
	oPrn:Say(0355,0585,SM0->M0_NOME,opFont3)	
	
	oPrn:Say(0405,0025,STR0101,opFont2) //"Nombre Comercial:" //"Nome Comercial"
	oPrn:Say(0405,0355,SM0->M0_NOMECOM,opFont3)
	
	oPrn:Say(0455,0025,STR0102,opFont2) //"Teléfono:" //"Telefone"
	oPrn:Say(0455,0185,SM0->M0_TEL,opFont3)
	
	oPrn:Say(0455,0455,STR0103,opFont2) //"Fax:" //"FAX: "
	oPrn:Say(0455,0585,SM0->M0_TEL,opFont3)
	
	oPrn:Say(0455,0850,STR0104,opFont2) //"Correo Electronico:" //"Correio Eletrônico"
	oPrn:Say(0455,1180,MV_PAR06,opFont3) //mv-par	
	
	oPrn:Box(0505,0020,0250,3315)  
	
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ImpRegITB ³ Autor ³ Camila Januário        ³ Data ³26/04/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Função que faz a impressão dos registros					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ImpRegITB()				                                  ³±±
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
Static Function ImpRegITB()

Local nLine := 655
Local nSay := 625
Local nPosValor1 := 1270 // valores no quadro 1
Local nPosValor2 := 3085 // valores no quadro 2
Local nPosSinal2 := 3000 // sinais do quadro 2
Local nPosSinal1 := 1200 // sinais do quadro 1
Local nLimDir1 := 1500  //limite direito quadro 1
Local nLimDir2 := 3315 //limite esquerdo quadro 2
Local nTamSay := 40  //tamanho entre says
Local nTamLine := 40 //tamanho entre lines
Local nItem1 := 025  //itens do quadro 1
Local nDescr1 := 075 //descricao do quadro 1
Local nItem2 := 1570 //item do quadro 2
Local nDescr2 := 1620 //descricao do quadro 2
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³II. INGRESOS POR OPERACIONES³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		
	oPrn:Box(0540,0020,0600,nLimDir1)
	oPrn:Say(0545,0025,STR0049,opFont1) //"II. INGRESOS POR OPERACIONES" //"II. INGRESOS POR OPERACIONES"

   	oPrn:Box(0600,0020,2000,nLimDir1)
   	
   	oPrn:Say(nSay,nItem1,"1.",opFont3)
	oPrn:Say(nSay,nDescr1,STR0050,opFont3)                       	 //"Total de Operaciones del Periodo"
	oPrn:Say(nSay,nPosSinal1,"+",opFont1)	
	oPrn:Say(nSay,nPosValor1,AliDir(Round(apTabApu[1,3],2),"@E 999,999,999.99"),opFont3)
	
	oPrn:Line(nLine,nItem1-5,nLine,nLimDir1)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³II A. NO GRAVADAS
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	
	oPrn:Say(nSay+=nTamSay,nItem1,STR0051,opFont7) //"II.A   NO GRAVADAS"
	oPrn:Line(nLine+=nTamLine,nItem1-5,nLine,nLimDir1)		 
	
	oPrn:Say(nSay+=nTamSay,nItem1,"2.",opFont3)
	oPrn:Say(nSay,nDescr1,STR0052,opFont3)                       	 //"Ingresos por Exportaciones"
	oPrn:Say(nSay,nPosSinal1,"+",opFont1)	
	oPrn:Say(nSay,nPosValor1,AliDir(Round(apTabApu[2,3],2),"@E 999,999,999.99"),opFont3)
	
	oPrn:Line(nLine+=nTamLine,nItem1-5,nLine,nLimDir1)	
	
	oPrn:Say(nSay+=nTamSay,nItem1,"3.",opFont3)
	oPrn:Say(nSay,nDescr1,STR0053,opFont3)                       	 //"Ingresos por Venta en Republica Dominicana de Bienes o Servicios Exentos"
	oPrn:Say(nSay,nPosSinal1,"+",opFont1)	
	oPrn:Say(nSay,nPosValor1,AliDir(Round(apTabApu[3,3],2),"@E 999,999,999.99"),opFont3)
	
	oPrn:Line(nLine+=nTamLine,nItem1-5,nLine,nLimDir1)
	
	oPrn:Say(nSay+=nTamSay,nItem1,"4.",opFont3)
	oPrn:Say(nSay,nDescr1,STR0054,opFont3)                       	 //"Total Ingresos Por Operaciones no Gravadas (sumar casilla 2+3)"
	oPrn:Say(nSay,nPosSinal1,"=",opFont1)	
	oPrn:Say(nSay,nPosValor1,AliDir(Round(apTabApu[4,3],2),"@E 999,999,999.99"),opFont3)	
	
	oPrn:Line(nLine+=nTamLine,nItem1-5,nLine,nLimDir1)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³II B. GRAVADAS
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	
	oPrn:Say(nSay+=nTamSay,nItem1,STR0055,opFont7) //"II.B  GRAVADAS"
	oPrn:Line(nLine+=nTamLine,nItem1-5,nLine,nLimDir1)		 	
	
	oPrn:Say(nSay+=nTamSay,nItem1,"5.",opFont3)
	oPrn:Say(nSay,nDescr1,STR0056,opFont3)                       	 //"Ingresos por Operaciones Gravadas"
	oPrn:Say(nSay,nPosSinal1,"=",opFont1)	
	oPrn:Say(nSay,nPosValor1,AliDir(Round(apTabApu[5,3],2),"@E 999,999,999.99"),opFont3)	 
	
	oPrn:Line(nLine+=nTamLine,nItem1-5,nLine,nLimDir1)
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³III. LIQUIDACIONES³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	
	nSay+= 50 //pula os subtopicos II, III, etc
	nLine+= 55//pula os subtopicos II, III, etc	
	
	oPrn:Box(nSay+30,0020,0600,nLimDir1)
	oPrn:Say(nSay+=nTamSay,nItem1,STR0057,opFont1)                	 //"III. LIQUIDACIONES"
		
	oPrn:Line(nLine+=nTamLine,nItem1-5,nLine,nLimDir1)
	
	oPrn:Say(nSay+=nTamSay,nItem1,"6.",opFont3)
	oPrn:Say(nSay,nDescr1,STR0058,opFont3)                       	 //"ITBIS Cobrado (16% a la casilla 5)"
	oPrn:Say(nSay,nPosSinal1,"=",opFont1)	
	oPrn:Say(nSay,nPosValor1,AliDir(Round(apTabApu[6,3],2),"@E 999,999,999.99"),opFont3)	 
	
	oPrn:Line(nLine+=nTamLine,nItem1-5,nLine,nLimDir1)	
	
	oPrn:Say(nSay+=nTamSay,nItem1,"7.",opFont3)
	oPrn:Say(nSay,nDescr1,STR0059,opFont3)                       	 //"ITBIS Pagado en Compras Locales "
	oPrn:Say(nSay,nPosSinal1,"+",opFont1)	
	oPrn:Say(nSay,nPosValor1,AliDir(Round(apTabApu[7,3],2),"@E 999,999,999.99"),opFont3)	 
	
	oPrn:Line(nLine+=nTamLine,nItem1-5,nLine,nLimDir1)
		
	oPrn:Say(nSay+=nTamSay,nItem1,"8.",opFont3)
	oPrn:Say(nSay,nDescr1,STR0060,opFont3)                       	 //"ITBIS Pagado por Servicios Deducibles"
	oPrn:Say(nSay,nPosSinal1,"+",opFont1)	
	oPrn:Say(nSay,nPosValor1,AliDir(Round(apTabApu[8,3],2),"@E 999,999,999.99"),opFont3)	 
	
	oPrn:Line(nLine+=nTamLine,nItem1-5,nLine,nLimDir1)	

	oPrn:Say(nSay+=nTamSay,nItem1,"9.",opFont3)
	oPrn:Say(nSay,nDescr1,STR0061,opFont3)                       	 //"ITBIS Pagado en Importaciones"
	oPrn:Say(nSay,nPosSinal1,"+",opFont1)	
	oPrn:Say(nSay,nPosValor1,AliDir(Round(apTabApu[9,3],2),"@E 999,999,999.99"),opFont3)	 
	
	oPrn:Line(nLine+=nTamLine,nItem1-5,nLine,nLimDir1)	

	oPrn:Say(nSay+=nTamSay,nItem1,"10.",opFont3)
	oPrn:Say(nSay,nDescr1,STR0062,opFont3)                       	 //"Total ITBIS pagado (sumar casillas 7+8+9)"
	oPrn:Say(nSay,nPosSinal1,"=",opFont1)	
	oPrn:Say(nSay,nPosValor1,AliDir(Round(apTabApu[10,3],2),"@E 999,999,999.99"),opFont3)	 
	
	oPrn:Line(nLine+=nTamLine,nItem1-5,nLine,nLimDir1)
	
	oPrn:Say(nSay+=nTamSay,nItem1,"11.",opFont3)
	oPrn:Say(nSay,nDescr1,STR0063,opFont3)                       	 //"Impuesto a Pagar (si el valor de las casillas 6-10 es Positivo)"
	oPrn:Say(nSay,nPosSinal1,"=",opFont1)	
	oPrn:Say(nSay,nPosValor1,AliDir(Round(apTabApu[11,3],2),"@E 999,999,999.99"),opFont3)	 
	
	oPrn:Line(nLine+=nTamLine,nItem1-5,nLine,nLimDir1)
	
	oPrn:Say(nSay+=nTamSay,nItem1,"12.",opFont3)
	oPrn:Say(nSay,nDescr1,STR0064,opFont3)                       	 //"Saldo a Favor (si el valor de las casillas 6-10 es Negativo)"
	oPrn:Say(nSay,nPosSinal1,"=",opFont1)	
	oPrn:Say(nSay,nPosValor1,AliDir(Round(apTabApu[12,3],2),"@E 999,999,999.99"),opFont3)	 
	
	oPrn:Line(nLine+=nTamLine,nItem1-5,nLine,nLimDir1)
	
	oPrn:Say(nSay+=nTamSay,nItem1,"13.",opFont3)
	oPrn:Say(nSay,nDescr1,STR0065,opFont3)                       	 //"Saldos Compensables Autorizados (Otros Impuestos)"
	oPrn:Say(nSay,nPosSinal1,"-",opFont1)	
	oPrn:Say(nSay,nPosValor1,AliDir(Round(apTabApu[13,3],2),"@E 999,999,999.99"),opFont3)	 
	
	oPrn:Line(nLine+=nTamLine,nItem1-5,nLine,nLimDir1)
	
	oPrn:Say(nSay+=nTamSay,nItem1,"14.",opFont3)
	oPrn:Say(nSay,nDescr1,STR0020,opFont3)                       	 //"Saldo a Favor Anterior"
	oPrn:Say(nSay,nPosSinal1,"-",opFont1)	
	oPrn:Say(nSay,nPosValor1,AliDir(Round(apTabApu[14,3],2),"@E 999,999,999.99"),opFont3)	 
	
	oPrn:Line(nLine+=nTamLine,nItem1-5,nLine,nLimDir1)
	
	oPrn:Say(nSay+=nTamSay,nItem1,"15.",opFont3)
	oPrn:Say(nSay,nDescr1,STR0066,opFont3)                       	 //"Pagos Computables por Retenciones (Norma No 8-04)"
	oPrn:Say(nSay,nPosSinal1,"-",opFont1)	
	oPrn:Say(nSay,nPosValor1,AliDir(Round(apTabApu[15,3],2),"@E 999,999,999.99"),opFont3)	 
	
	oPrn:Line(nLine+=nTamLine,nItem1-5,nLine,nLimDir1)
	
	oPrn:Say(nSay+=nTamSay,nItem1,"16.",opFont3)
	oPrn:Say(nSay,nDescr1,STR0067,opFont3)                       	 //"Pagos Computables por Otras Retenciones (Norma No 2-05)"
	oPrn:Say(nSay,nPosSinal1,"-",opFont1)	
	oPrn:Say(nSay,nPosValor1,AliDir(Round(apTabApu[16,3],2),"@E 999,999,999.99"),opFont3)	 
	
	oPrn:Line(nLine+=nTamLine,nItem1-5,nLine,nLimDir1)
	
	oPrn:Say(nSay+=nTamSay,nItem1,"17.",opFont3)
	oPrn:Say(nSay,nDescr1,STR0068,opFont3)                       	 //"Otros Pagos Computables a Cuentas"
	oPrn:Say(nSay,nPosSinal1,"-",opFont1)	
	oPrn:Say(nSay,nPosValor1,AliDir(Round(apTabApu[17,3],2),"@E 999,999,999.99"),opFont3)	 
	
	oPrn:Line(nLine+=nTamLine,nItem1-5,nLine,nLimDir1)
	
	oPrn:Say(nSay+=nTamSay,nItem1,"18.",opFont3)
	oPrn:Say(nSay,nDescr1,STR0069,opFont3)                       	 //"Diferencia a Pagar (si el valor de las casillas 11-13-14-15-16-17 es Positivo)"
	oPrn:Say(nSay,nPosSinal1,"=",opFont1)	
	oPrn:Say(nSay,nPosValor1,AliDir(Round(apTabApu[18,3],2),"@E 999,999,999.99"),opFont3)	 
	
	oPrn:Line(nLine+=nTamLine,nItem1-5,nLine,nLimDir1)
	
	oPrn:Say(nSay+=nTamSay,nItem1,"19.",opFont3)
	oPrn:Say(nSay,nDescr1,STR0070,opFont3)                       	 //"Nuevo Saldo a Favor (11-13-14-15-16-17 es Negativo ó 12+13+14+15+16+17)"
	oPrn:Say(nSay,nPosSinal1,"=",opFont1)	
	oPrn:Say(nSay,nPosValor1,AliDir(Round(apTabApu[19,3],2),"@E 999,999,999.99"),opFont3)	 
	
	oPrn:Line(nLine+=nTamLine,nItem1-5,nLine,nLimDir1)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³IV. PENALIDADES
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	
	nSay+= 50 //pula os subtopicos II, III, etc
	nLine+= 55//pula os subtopicos II, III, etc	
	
	oPrn:Box(nSay+30,0020,0600,nLimDir1)
	oPrn:Say(nSay+=nTamSay,nItem1,STR0071,opFont1)                       //"IV. PENALIDADES"
	
	oPrn:Line(nLine+=nTamLine,nItem1-5,nLine,nLimDir1)
	
	oPrn:Say(nSay+=nTamSay,nItem1,"20.",opFont3)
	oPrn:Say(nSay,nDescr1,STR0026,opFont3)                       	 //"Recargos"
	oPrn:Say(nSay,nPosSinal1,"+",opFont1)	
	oPrn:Say(nSay,nPosValor1,AliDir(Round(apTabApu[20,3],2),"@E 999,999,999.99"),opFont3)	 
	
	oPrn:Line(nLine+=nTamLine,nItem1-5,nLine,nLimDir1)
	
	oPrn:Say(nSay+=nTamSay,nItem1,"21.",opFont3)
	oPrn:Say(nSay,nDescr1,STR0072,opFont3)                       	 //"Interés Indemnizatorio"
	oPrn:Say(nSay,nPosSinal1,"+",opFont1)	
	oPrn:Say(nSay,nPosValor1,AliDir(Round(apTabApu[21,3],2),"@E 999,999,999.99"),opFont3)	 
	
	oPrn:Line(nLine+=nTamLine,nItem1-5,nLine,nLimDir1)	

	oPrn:Say(nSay+=nTamSay,nItem1,"22.",opFont3)
	oPrn:Say(nSay,nDescr1,STR0073,opFont3)                       	 //"Sanciones"
	oPrn:Say(nSay,nPosSinal1,"+",opFont1)	
	oPrn:Say(nSay,nPosValor1,AliDir(Round(apTabApu[22,3],2),"@E 999,999,999.99"),opFont3)	 
	
	oPrn:Line(nLine+=nTamLine,nItem1-5,nLine,nLimDir1)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³V. MONTO A PAGAR
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	
	nSay+= 55 //pula os subtopicos II, III, etc
	nLine+= 55//pula os subtopicos II, III, etc	
	
	oPrn:Box(nSay+30,0020,0600,nLimDir1)
	oPrn:Say(nSay+=nTamSay,nItem1,STR0074,opFont1)                       //"V. MONTO A PAGAR"
	
	oPrn:Line(nLine+=nTamLine,nItem1-5,nLine,nLimDir1)
	
	oPrn:Say(nSay+=nTamSay,nItem1,"23.",opFont3)
	oPrn:Say(nSay,nDescr1,STR0075,opFont3)                       	 //"Total a Pagar (sumar casillas 18+20+21+22)"
	oPrn:Say(nSay,nPosSinal1,"=",opFont1)	
	oPrn:Say(nSay,nPosValor1,AliDir(Round(apTabApu[23,3],2),"@E 999,999,999.99"),opFont3)	 
	
	oPrn:Line(nLine+=nTamLine,nItem1-5,nLine,nLimDir1)
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³A. ITBIS RETENIDO              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	
	nLine := 655
	nSay := 625	
		
	oPrn:Box(0540,1565,0600,nLimDir2)
	oPrn:Say(0545,nItem2,STR0076,opFont1)  //"A. ITBIS RETENIDO"

   	oPrn:Box(0600,1565,1800,nLimDir2)
   	
   	oPrn:Say(nSay,nItem2,"24.",opFont3)
	oPrn:Say(nSay,nDescr2,STR0077,opFont3)                       	 //"Servicios sujetos a retención personas físicas y entidades no lucrativas"
	oPrn:Say(nSay,nPosSinal2,"=",opFont1)	
	oPrn:Say(nSay,nPosValor2,AliDir(Round(apTabApu[24,3],2),"@E 999,999,999.99"),opFont3)
	
	oPrn:Line(nLine,nItem2-5,nLine,nLimDir2)
	
	oPrn:Say(nSay+=nTamSay,nItem2,"25.",opFont3)
	oPrn:Say(nSay,nDescr2,STR0078,opFont3)                       	 //"Servicios sujetos a retención Sociedades"
	oPrn:Say(nSay,nPosSinal2,"=",opFont1)	
	oPrn:Say(nSay,nPosValor2,AliDir(Round(apTabApu[25,3],2),"@E 999,999,999.99"),opFont3)	 
	
	oPrn:Line(nLine+=nTamLine,nItem2-5,nLine,nLimDir2)
	
	oPrn:Say(nSay+=nTamSay,nItem2,"26.",opFont3)
	oPrn:Say(nSay,nDescr2,STR0079,opFont3)                       	 //"Servicioes sujetos a retención Sociedades Sujetas (Norma No.2-05)"
	oPrn:Say(nSay,nPosSinal2,"=",opFont1)	
	oPrn:Say(nSay,nPosValor2,AliDir(Round(apTabApu[26,3],2),"@E 999,999,999.99"),opFont3)	 
	
	oPrn:Line(nLine+=nTamLine,nItem2-5,nLine,nLimDir2)
	
	oPrn:Say(nSay+=nTamSay,nItem2,"27.",opFont3)
	oPrn:Say(nSay,nDescr2,STR0080,opFont3)                       	 //"Bienes o servicios sujetos a retención a contribuyentes acogidos al PST"
	oPrn:Say(nSay,nPosSinal2,"=",opFont1)	
	oPrn:Say(nSay,nPosValor2,AliDir(Round(apTabApu[27,3],2),"@E 999,999,999.99"),opFont3)	 
	
	oPrn:Line(nLine+=nTamLine,nItem2-5,nLine,nLimDir2)
	
	oPrn:Say(nSay+=nTamSay,nItem2,"28.",opFont3)
	oPrn:Say(nSay,nDescr2,STR0081,opFont3)                       	 //"Bienes sujetos a retención proveedores informales (Norma 08-2010)"
	oPrn:Say(nSay,nPosSinal2,"=",opFont1)	
	oPrn:Say(nSay,nPosValor2,AliDir(Round(apTabApu[28,3],2),"@E 999,999,999.99"),opFont3)	 
	
	oPrn:Line(nLine+=nTamLine,nItem2-5,nLine,nLimDir2)
	
	oPrn:Say(nSay+=nTamSay,nItem2,"29.",opFont3)
	oPrn:Say(nSay,nDescr2,STR0082,opFont3)                       	 //"ITBIS retenido por servicios sujetos a retención personas físicas y entidades no lucrativas (16% casilla 24)"
	oPrn:Say(nSay,nPosSinal2,"+",opFont1)	
	oPrn:Say(nSay,nPosValor2,AliDir(Round(apTabApu[29,3],2),"@E 999,999,999.99"),opFont3)	 
	
	oPrn:Line(nLine+=nTamLine,nItem2-5,nLine,nLimDir2)
	
	oPrn:Say(nSay+=nTamSay,nItem2,"30.",opFont3)
	oPrn:Say(nSay,nDescr2,STR0083,opFont3)                       	 //"ITBIS retenido por servicios sujetos a retención Sociedades (16% casilla 25)"
	oPrn:Say(nSay,nPosSinal2,"+",opFont1)	
	oPrn:Say(nSay,nPosValor2,AliDir(Round(apTabApu[30,3],2),"@E 999,999,999.99"),opFont3)	 
	
	oPrn:Line(nLine+=nTamLine,nItem2-5,nLine,nLimDir2)	
		
	oPrn:Say(nSay+=nTamSay,nItem2,"31.",opFont3)
	oPrn:Say(nSay,nDescr2,STR0084,opFont3)                       	 //"ITBIS retenido por servicios sujetos a retención Sociedades (16% casilla 26 por 0.30 Norma 2-05)"
	oPrn:Say(nSay,nPosSinal2,"+",opFont1)	
	oPrn:Say(nSay,nPosValor2,AliDir(Round(apTabApu[31,3],2),"@E 999,999,999.99"),opFont3)	 
	
	oPrn:Line(nLine+=nTamLine,nItem2-5,nLine,nLimDir2)
	
	oPrn:Say(nSay+=nTamSay,nItem2,"32.",opFont3)
	oPrn:Say(nSay,nDescr2,STR0085,opFont3)                       	 //"ITBIS retenido a contribuyentes acogidos al PST (16% casilla 27)"
	oPrn:Say(nSay,nPosSinal2,"+",opFont1)	
	oPrn:Say(nSay,nPosValor2,AliDir(Round(apTabApu[32,3],2),"@E 999,999,999.99"),opFont3)	 
	
	oPrn:Line(nLine+=nTamLine,nItem2-2,nLine,nLimDir2)
	
	oPrn:Say(nSay+=nTamSay,nItem2,"33.",opFont3)
	oPrn:Say(nSay,nDescr2,STR0086,opFont3)                       	 //"ITBIS retenido por bienes sujetos a retención proveedores informales (16% casilla 28 por 0.75 norma 08-2010)"
	oPrn:Say(nSay,nPosSinal2,"+",opFont1)	
	oPrn:Say(nSay,nPosValor2,AliDir(Round(apTabApu[33,3],2),"@E 999,999,999.99"),opFont3)	 
	
	oPrn:Line(nLine+=nTamLine,nItem2-5,nLine,nLimDir2)
	
	oPrn:Say(nSay+=nTamSay,nItem2,"34.",opFont3)
	oPrn:Say(nSay,nDescr2,STR0087,opFont3)                       	 //"Impuesto a Pagar (sumar casillas 29+30+31+32+33)"
	oPrn:Say(nSay,nPosSinal2,"=",opFont1)	
	oPrn:Say(nSay,nPosValor2,AliDir(Round(apTabApu[34,3],2),"@E 999,999,999.99"),opFont3)	 
	
	oPrn:Line(nLine+=nTamLine,nItem2-5,nLine,nLimDir2)
	
	oPrn:Say(nSay+=nTamSay,nItem2,"35.",opFont3)
	oPrn:Say(nSay,ndescr2,STR0088,opFont3)                       	 //"Saldo a Favor Anterior (ITBIS retenido)"
	oPrn:Say(nSay,nPosSinal2,"-",opFont1)	
	oPrn:Say(nSay,nPosValor2,AliDir(Round(apTabApu[35,3],2),"@E 999,999,999.99"),opFont3)	 
	
	oPrn:Line(nLine+=nTamLine,nItem2-5,nLine,nLimDir2)
	
	oPrn:Say(nSay+=nTamSay,nItem2,"36.",opFont3)
	oPrn:Say(nSay,nDescr2,STR0089,opFont3)                       	 //"Pagos Computables a Cuenta (ITBIS retenido)"
	oPrn:Say(nSay,nPosSinal2,"-",opFont1)	
	oPrn:Say(nSay,nPosValor2,AliDir(Round(apTabApu[36,3],2),"@E 999,999,999.99"),opFont3)	 
	
	oPrn:Line(nLine+=nTamLine,nItem2-5,nLine,nLimDir2)
	
	oPrn:Say(nSay+=nTamSay,nItem2,"37.",opFont3)
	oPrn:Say(nSay,nDescr2,STR0090,opFont3)                       	 //"Diferencia a pagar (si el valor de las casillas 34-35-36 es positivo)"
	oPrn:Say(nSay,nPosSinal2,"=",opFont1)	
	oPrn:Say(nSay,nPosValor2,AliDir(Round(apTabApu[37,3],2),"@E 999,999,999.99"),opFont3)	 
	
	oPrn:Line(nLine+=nTamLine,nItem2-5,nLine,nLimDir2)
		
	oPrn:Say(nSay+=nTamSay,nItem2,"38.",opFont3)
	oPrn:Say(nSay,nDescr2,STR0091,opFont3)                       	 //"Nuevo Saldo a Favor (si el valor de las casillas 34-35-36 es negativo)"
	oPrn:Say(nSay,nPosSinal2,"=",opFont1)	
	oPrn:Say(nSay,nPosValor2,AliDir(Round(apTabApu[38,3],2),"@E 999,999,999.99"),opFont3)	 
	
	oPrn:Line(nLine+=nTamLine,nItem2-5,nLine,nLimDir2)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³B. PENALIDADES
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	
	nSay+= 55 //pula os subtopicos II, III, etc
	nLine+= 55//pula os subtopicos II, III, etc	
	
	oPrn:Box(nSay+30,1565,0600,nLimDir2)
	oPrn:Say(nSay+=nTamSay,nItem2,STR0095,opFont1)                       //"B. PENALIDADES"
	
	oPrn:Line(nLine+=nTamLine,nItem2-5,nLine,nLimDir2)
	
	oPrn:Say(nSay+=nTamSay,nItem2,"39.",opFont3)
	oPrn:Say(nSay,nDescr2,STR0026,opFont3)                       	 //"Recargos"
	oPrn:Say(nSay,nPosSinal2,"+",opFont1)	
	oPrn:Say(nSay,nPosValor2,AliDir(Round(apTabApu[39,3],2),"@E 999,999,999.99"),opFont3)	 
	
	oPrn:Line(nLine+=nTamLine,nItem2-5,nLine,nLimDir2)
	
	oPrn:Say(nSay+=nTamSay,nItem2,"40.",opFont3)
	oPrn:Say(nSay,nDescr2,STR0072,opFont3)                       	 //"Interés Indemnizatorio"
	oPrn:Say(nSay,nPosSinal2,"+",opFont1)	
	oPrn:Say(nSay,nPosValor2,AliDir(Round(apTabApu[40,3],2),"@E 999,999,999.99"),opFont3)	 
	
	oPrn:Line(nLine+=nTamLine,nItem2-5,nLine,nLimDir2)
		
	oPrn:Say(nSay+=nTamSay,nItem2,"41.",opFont3)
	oPrn:Say(nSay,nDescr2,STR0073,opFont3)                       	 //"Sanciones"
	oPrn:Say(nSay,nPosSinal2,"+",opFont1)	
	oPrn:Say(nSay,nPosValor2,AliDir(Round(apTabApu[41,3],2),"@E 999,999,999.99"),opFont3)	 
	
	oPrn:Line(nLine+=nTamLine,nItem2-5,nLine,nLimDir2)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³C. MONTO A PAGAR
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	
	nSay+= 55 //pula os subtopicos II, III, etc
	nLine+= 55//pula os subtopicos II, III, etc	
	
	oPrn:Box(nSay+30,1565,0600,nLimDir2)
	oPrn:Say(nSay+=nTamSay,nItem2,STR0092,opFont1) //"C. MONTO A PAGAR"
	
	oPrn:Line(nLine+=nTamLine,nItem2-5,nLine,nLimDir2)
	
	oPrn:Say(nSay+=nTamSay,nItem2,"42.",opFont3)
	oPrn:Say(nSay,nDescr2,STR0093,opFont3)                       	 //"Total a pagar (sumar casillas 37+39+40+41)"
	oPrn:Say(nSay,nPosSinal2,"=",opFont1)	
	oPrn:Say(nSay,nPosValor2,AliDir(Round(apTabApu[42,3],2),"@E 999,999,999.99"),opFont3)	 
	
	oPrn:Line(nLine+=nTamLine,nItem2-5,nLine,nLimDir2)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³43. TOTAL GENERAL
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	
	nSay+= 70 //pula os subtopicos II, III, etc
	nLine+= 70 //pula os subtopicos II, III, etc	
	
	oPrn:Box(nSay+30,1565,0600,nLimDir2)
	oPrn:Say(nSay+=nTamSay,nItem2,"43.",opFont3)
	oPrn:Say(nSay,nDescr2,STR0094,opFont3)                       	 //"TOTAL GENERAL (SUMAR CASILLAS 23+42)"
	oPrn:Say(nSay,nPosSinal2,"=",opFont1)	
	oPrn:Say(nSay,nPosValor2,AliDir(Round(apTabApu[43,3],2),"@E 999,999,999.99"),opFont3)	
	
	oPrn:Line(nLine+=nTamLine,nItem2-5,nLine,nLimDir2) 	
	
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
