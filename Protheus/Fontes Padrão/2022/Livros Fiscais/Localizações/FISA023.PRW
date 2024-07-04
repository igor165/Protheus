#INCLUDE "TopConn.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "FISA023.CH"                                                                                
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FISA023    ³ Autor ³ Tiago Bizan          ³ Data ³02/08/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Apuracao de impostos Venezuela     	    			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FISA023()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                      								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Apuracao de impostos                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FISA023()
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
Private cPerg	 := "FISA023"

aAdd(aSays,STR0002)//"Esta rotina tem a finalidade de efetuar a apuração dos impostos calculados pelo sistema:"
aAdd(aSays,STR0003)//"Imposto sobre Valor Agregado (IVA/IVC/RV0/RV1)."  
aAdd(aSays,STR0004)//"" 
aAdd(aButtons,{5,.T.,{ || lPerg := Pergunte(cPerg,.T.) }})
aAdd(aButtons,{1,.T.,{ || nxOpc := 1,FechaBatch()      }})
aAdd(aButtons,{2,.T.,{ || nxOpc := 0,FechaBatch()      }})

If !IsBlind()
	FormBatch(cCadastro,aSays,aButtons) 
EndIf

//*****************************************************************
//Parametros FISA018 - VENEZUELA
//*****************************************************************
//MV_PAR01 - Data Inicial
//MV_PAR02 - Data Final
//MV_PAR03 - Gera Titulo
//MV_PAR04 - Data Limite para Pagamento
//MV_PAR05 - Arquivo do Periodo Anterior
//MV_PAR06 - Inst. Normativa
//MV_PAR07 - Arquivo Destino
//MV_PAR08 - Diretorio
//*****************************************************************

If nxOpc == 1
	If !lPerg
		lPerg := Pergunte(cPerg,.T.)
	Endif 
	If lPerg
		cNorma		:= AllTrim(MV_PAR06) + ".INI"
		cpDir		:= alltrim(MV_PAR08)
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
±±³Fun‡…o    ³FQImposto  ³ Autor ³ Tiago Bizan     		³ Data ³08/08/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impostos IVA			                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FQImposto()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum       	         								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aArray                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Impostos de Compra                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FQImpto(aDadGer)
	Local nAlqIVA:=nBasIVA:=nVlrIVA:=0
	Local nAlqRV:=nBasRV:=nVlrRV:=0	
	Local nCampo48:=0
	Local n40:=n41:=n42:=n43:=n442:=n452:=n443:=n453:=n46:=n47:=n48:=n80:=n49:=0
	Local n30:=n31:=n32:=n312:=n322:=n313:=n323:=n33:=n34:=n332:=n342:=n333:=0 
	Local n343:=n35:=n36:=n70:=n37:=n71:=n20:=n21:=n81:=n38:=n82:=n39:=0 
	Local n53:=n60:=n78:=n54:=n66:=n72:=n73:=n74:=n55:=n67:=n56:=n39:=n90:=n22:=n24:=n51:=0 
	Local cQuery	:= ""                                           
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
	
	cNomTxt:="A"+GravaData(MV_PAR01,.F.,1)+GravaData(MV_PAR02,.F.,1)+cEmpAnt+cFilAnt+"."+"IV" 
	lGerTit		:=Iif(MV_PAR03==1,.T.,.F.)
	lArqAnt		:=Iif(!Empty(MV_PAR05),.T.,.F.)
	cArqAnt		:=Alltrim(MV_PAR05)
	
	If File(cpDir+cNomTxt) .and. ApMsgYesNo(STR0005)//"Este periodo ja foi apurado. Deseja refazer?" 
		MsgRun(STR0006,,{|| lExclTit := ApurTXT(substr(cNomTxt,1,17))}) //"Cancelando apuração anterior..." 
		If !lExclTit
			ApMsgStop(STR0007,STR0035) //"O titulo já foi baixado.Apenas será possível excluir o título gerado e baixado anteriormente se for estornado."
			Return nil
		Endif			
	Else
		If File(cpDir+cNomTxt) 
			MsgRun(STR0008,,{|| lExclTit := FMApur(substr(cNomTxt,1,17))})//"Gerando Relatório de Conferencia"			
			If lExclTit 
				llMDados := .T.
			Else
				Return Nil
			EndIF
		EndIF
	EndIF		

	If !llMDados 
		cQuery := ""
		cQuery += " SELECT DISTINCT "
		cQuery += " SF3.*,F4_ATUATF, FC_IMPOSTO "
		cQuery += " FROM " +RetSqlName("SF3")+" SF3"
		cQuery += " INNER JOIN " +RetSqlName("SF4")+" SF4 ON "
		cQuery += " F4_FILIAL = '"+xFilial("SF4")+"' "
		cQuery += " AND F4_CODIGO=F3_TES "
		cQuery += " AND SF4.D_E_L_E_T_='' "
		cQuery += " INNER JOIN " +RetSqlName("SFC")+" SFC ON "
		cQuery += " FC_FILIAL = '"+xFilial("SFC")+"' "
		cQuery += " AND FC_TES=F3_TES "  
		cQuery += " AND SFC.D_E_L_E_T_=''  "
		cQuery += " AND FC_IMPOSTO IN ('IVA','IVC','RV0','RV1') "	
		cQuery += " WHERE SF3.D_E_L_E_T_='' "
		cQuery += " AND F3_FILIAL = '"+xFilial("SF3")+"' "
		cQuery += " AND F3_EMISSAO BETWEEN '"+Dtos(MV_PAR01)+"' AND '"+Dtos(MV_PAR02)+"' "	
		cQuery += " ORDER BY F3_TIPOMOV, F3_EMISSAO, F3_CLIEFOR, F3_LOJA, F3_NFISCAL, F3_SERIE ,F3_TES "
		
		If Select("IMPOSTO")>0
			DbSelectArea("IMPOSTO")
			IMPOSTO->(DbCloseArea())
		Endif
				                              
		TcQuery cQuery New Alias "IMPOSTO"	
		
		DbSelectArea("IMPOSTO")
		Do While IMPOSTO->(!Eof())
			cUFCliFor:=""   
			nAlqIVA:=nBasIVA:=nVlrIVA:=0
			

			clLivro := ""
			clLivro := Posicione("SFB",1,xFilial("SFB")+IMPOSTO->FC_IMPOSTO,"FB_CPOLVRO")				
			
			DbSelectArea("SFB")
			SFB->(DbSetOrder(1))
			If SFB->(DbSeek(xFilial("SFB")+AvKey(IMPOSTO->FC_IMPOSTO,"FB_CODIGO")))
				If Alltrim(IMPOSTO->FC_IMPOSTO)=="IVA" .OR. Alltrim(IMPOSTO->FC_IMPOSTO)=="IVC"
					nAlqIVA:=&("IMPOSTO->F3_ALQIMP"+Alltrim(SFB->FB_CPOLVRO))
					nBasIVA:=&("IMPOSTO->F3_BASIMP"+Alltrim(SFB->FB_CPOLVRO))
					nVlrIVA:=&("IMPOSTO->F3_VALIMP"+Alltrim(SFB->FB_CPOLVRO))				
				ElseIf Alltrim(IMPOSTO->FC_IMPOSTO)=="RV0" .or. Alltrim(IMPOSTO->FC_IMPOSTO)=="RV1"
					nAlqRV:=&("IMPOSTO->F3_ALQIMP"+Alltrim(SFB->FB_CPOLVRO))
					nBasRV:=&("IMPOSTO->F3_BASIMP"+Alltrim(SFB->FB_CPOLVRO))
					nVlrRV:=&("IMPOSTO->F3_VALIMP"+Alltrim(SFB->FB_CPOLVRO))
				Endif	
			Else
				If Alltrim(IMPOSTO->FC_IMPOSTO)=="IVA" .OR. Alltrim(IMPOSTO->FC_IMPOSTO)=="IVC"
					nAlqIVA:=IMPOSTO->F3_ALQIMP1
					nBasIVA:=IMPOSTO->F3_BASIMP1
					nVlrIVA:=IMPOSTO->F3_VALIMP1
				ElseIf Alltrim(IMPOSTO->FC_IMPOSTO)=="RV0"
					nAlqRV:=IMPOSTO->F3_ALQIMP2
					nBasRV:=IMPOSTO->F3_BASIMP2
					nVlrRV:=IMPOSTO->F3_VALIMP2
				ElseIf Alltrim(IMPOSTO->FC_IMPOSTO)=="RV1"
					nAlqRV:=IMPOSTO->F3_ALQIMP3
					nBasRV:=IMPOSTO->F3_BASIMP3
					nVlrRV:=IMPOSTO->F3_VALIMP3
			    Endif
			Endif	
	
			alImposto := {}
			aadd(alImposto,Posicione("SFB",1,xFilial("SFB")+IMPOSTO->FC_IMPOSTO,"FB_ALIQ"))
			aadd(alImposto,Posicione("SFB",1,xFilial("SFB")+IMPOSTO->FC_IMPOSTO,"FB_ALIQRD"))
			aadd(alImposto,Posicione("SFB",1,xFilial("SFB")+IMPOSTO->FC_IMPOSTO,"FB_ALIQAD"))			

			If IMPOSTO->F3_TIPOMOV=="V"
				If Alltrim(IMPOSTO->F3_ESPECIE)$"NCC|NDE"
					nVlrIVA := (-1) * nVlrIVA
					nBasIVA:=  (-1) *  nBasIVA
				
				EndIF
				cUFCliFor:=Posicione("SA1",1,xFilial("SA1")+IMPOSTO->F3_CLIEFOR+IMPOSTO->F3_LOJA,"A1_EST")
				//********************************************************************************
				//Débitos Fiscales
				//********************************************************************************
			    
			   	//Ventas Internas no gravadas: - Vendas gravadas comn alíquota com 12% ou 10% ou 22% que não tem direito a crédito
				If IMPOSTO->F3_TIPOMOV == "V" .And. IMPOSTO->F3_EXENTAS > 0 .And. alltrim(cUFCliFor) <> "EX"
					n40+=IMPOSTO->F3_EXENTAS
				Endif
				//Ventas Exportacion: - Vendas gravadas com alíquota 0%.
				If ( &("IMPOSTO->F3_BASIMP"+clLivro) > 0 .OR. IMPOSTO->F3_EXENTAS > 0) .And. IMPOSTO->F3_TIPOMOV == "V" .And. alltrim(cUFCliFor) == "EX"
					n41+=nBasIVA
				Endif
				//Base Imponible: - Vendas gravadas com alíquota de 12%.
				If &("IMPOSTO->F3_BASIMP"+clLivro) > 0 .And. IMPOSTO->F3_TIPOMOV == "V" .And. alltrim(cUFCliFor) <> "EX" .And. IMPOSTO->F3_TPALIQ == "G"
					n42+=nBasIVA
				Endif
				//Debito Fiscal: - Vendas gravadas com alíquota de 12%.
				If &("IMPOSTO->F3_VALIMP"+clLivro) >0 .And. IMPOSTO->F3_TIPOMOV == "V" .And. alltrim(cUFCliFor)<>"EX" .And. IMPOSTO->F3_TPALIQ == "G"
					n43+=nVlrIVA
				Endif
				//Base Imponible: - Vendas gravadas com alíquota 10%.
				If &("IMPOSTO->F3_BASIMP"+clLivro) > 0 .And. IMPOSTO->F3_TIPOMOV == "V" .And. alltrim(cUFCliFor)<>"EX" .And. IMPOSTO->F3_TPALIQ == "A"
					n442+= (nBasIVA)
				Endif
								
				//Debito Fiscal: - Vendas Gravadas com alíquota 10%.
				If &("IMPOSTO->F3_VALIMP"+clLivro) >0 .and. IMPOSTO->F3_TIPOMOV == "V" .and. alltrim(cUFCliFor)<>"EX" .And. IMPOSTO->F3_TPALIQ == "A"
					n452+= (nVlrIVA)
				Endif			
				
				//Base Imponible: - Vendas gravadas com alíquota de 8%.
				If &("IMPOSTO->F3_BASIMP"+clLivro) > 0 .And. IMPOSTO->F3_TIPOMOV == "V" .And. alltrim(cUFCliFor)<>"EX" .And. IMPOSTO->F3_TPALIQ == "R"
					n443+=nBasIVA
				Endif
				
				//Debito Fiscal: - Vendas gravadas com alíquota de 8%.
				If &("IMPOSTO->F3_VALIMP"+clLivro) > 0 .And. IMPOSTO->F3_TIPOMOV == "V" .And. alltrim(cUFCliFor)<>"EX" .And. IMPOSTO->F3_TPALIQ == "R"
					n453+=nVlrIVA
				Endif				
				
		       	//Autoliquidación
	            //Retenciones de periodo: - Retenções de IVA que tenha sido efetuadas no periodo.
				If IMPOSTO->F3_TIPOMOV == "V" .And. &("IMPOSTO->F3_VALIMP"+clLivro) > 0 .and. (IMPOSTO->FC_IMPOSTO=='RV0' .or. IMPOSTO->FC_IMPOSTO=="RV1")
					n66+=&("IMPOSTO->F3_VALIMP"+clLivro)
				EndIF
							
			ElseIf IMPOSTO->F3_TIPOMOV=="C"	
				DbSelectArea("SA2")
				SA2->(DbSetOrder(1))
				If DbSeek(xFilial("SA2")+AvKey(IMPOSTO->F3_CLIEFOR,"A2_COD")+AvKey(IMPOSTO->F3_LOJA,"A2_LOJA"))
					cUFCliFor:=SA2->A2_EST
				Endif	
				
				if Alltrim(IMPOSTO->F3_ESPECIE)$"NDI|NCP"
					nVlrIVA := (-1) * nVlrIVA
					nBasIVA:=  (-1) * nBasIVA
				EndIF
				
				//********************************************************************************
				//Creditos Fiscales
				//********************************************************************************
				
				//Compras no Gravadas y /o sin. Direcao a Credito Fiscal: Vendas gravadas com aliquotas 12% ou 10% ou 8% que não dão direito a credito.
				If IMPOSTO->F3_TIPOMOV == "C" .And. IMPOSTO->F3_EXENTAS > 0 .And. alltrim(cUFCliFor)<>"EX"
					n30+=IMPOSTO->F3_EXENTAS
				Endif	
				//Importaciones gravadas por alicuota general: Compras gravadas com alíquota 12%.
				If &("IMPOSTO->F3_BASIMP"+clLivro)>0 .And. IMPOSTO->F3_TIPOMOV == "C" .And. alltrim(cUFCliFor)=="EX" .And. IMPOSTO->F3_TPALIQ == "G"
					n31+=nBasIVA
				Endif	                                                                         
				//Importaciones gravadas por alicuota general: Compras gravadas com alíquota 12%.
				If &("IMPOSTO->F3_VALIMP"+clLivro)>0 .And. IMPOSTO->F3_TIPOMOV == "C" .And. alltrim(cUFCliFor)=="EX" .And. IMPOSTO->F3_TPALIQ == "G"
					n32+=nVlrIVA
				Endif  
				//Importaciones gravadas por alicuota general: Compras gravadas com alíquota 10%.
				If &("IMPOSTO->F3_BASIMP"+clLivro)>0 .And. IMPOSTO->F3_TIPOMOV == "C" .And. alltrim(cUFCliFor)=="EX" .And. IMPOSTO->F3_TPALIQ == "A"
					n312+=nBasIVA
				Endif  
				//Importaciones gravadas por alicuota general: Compras gravadas com alíquota 10%.
				If &("IMPOSTO->F3_VALIMP"+clLivro)>0 .And. IMPOSTO->F3_TIPOMOV == "C" .And. alltrim(cUFCliFor)=="EX" .And. IMPOSTO->F3_TPALIQ == "A"
					n322+=nVlrIVA
				Endif  
				//Importaciones gravadas por alicuota general: Compras gravadas com alíquota 8%.
				If &("IMPOSTO->F3_BASIMP"+clLivro)>0 .And. IMPOSTO->F3_TIPOMOV == "C" .And. alltrim(cUFCliFor)=="EX" .And. IMPOSTO->F3_TPALIQ == "R"
					n313+=nBasIVA
				Endif  				
				//Importaciones gravadas por alicuota general: Compras gravadas com alíquota 8%.
				If &("IMPOSTO->F3_VALIMP"+clLivro)>0 .And. IMPOSTO->F3_TIPOMOV == "C" .And. alltrim(cUFCliFor)=="EX" .And. IMPOSTO->F3_TPALIQ == "R"
					n323+=nVlrIVA
				Endif
				//Compras Internas Gravadas a solo por alicuota general de 12%: - Compras Gravadas com aliquota de 12%  							
				If &("IMPOSTO->F3_BASIMP"+clLivro)>0 .And. IMPOSTO->F3_TIPOMOV == "C" .And. alltrim(cUFCliFor)<>"EX" .And. IMPOSTO->F3_TPALIQ == "G"
					n33+=nBasIVA
				Endif
				//Compras Internas Gravadas a solo por alicuota general de 12%: - Compras Gravadas com aliquota de 12%  							
				If &("IMPOSTO->F3_VALIMP"+clLivro)>0 .And. IMPOSTO->F3_TIPOMOV == "C" .And. alltrim(cUFCliFor)<>"EX" .And. IMPOSTO->F3_TPALIQ == "G"
					n34+=nVlrIVA
				Endif				
				//Compras Internas Gravadas a solo por alicuota general de 10%: - Compras Gravadas com aliquota de 10%  							
				If &("IMPOSTO->F3_BASIMP"+clLivro)>0 .And. IMPOSTO->F3_TIPOMOV == "C" .And. alltrim(cUFCliFor)<>"EX" .And. IMPOSTO->F3_TPALIQ == "A"
					n332+=nBasIVA
				Endif				
				//Compras Internas Gravadas a solo por alicuota general de 10%: - Compras Gravadas com aliquota de 10%  							
				If &("IMPOSTO->F3_VALIMP"+clLivro)>0 .And. IMPOSTO->F3_TIPOMOV == "C" .And. alltrim(cUFCliFor)<>"EX" .And. IMPOSTO->F3_TPALIQ == "A"
					n342+=nVlrIVA
				Endif				
				//Compras Internas Gravadas a solo por alicuota reducida: - Compras Gravadas com aliquota de 8%
				If &("IMPOSTO->F3_BASIMP"+clLivro)>0 .And. IMPOSTO->F3_TIPOMOV == "C" .And. alltrim(cUFCliFor)<>"EX" .And. IMPOSTO->F3_TPALIQ == "R"
					n333+=nBasIVA
				Endif			 
				//Compras Internas Gravadas a solo por alicuota reducida: - Compras Gravadas com aliquota de 8%  							
				If &("IMPOSTO->F3_VALIMP"+clLivro)>0 .And. IMPOSTO->F3_TIPOMOV == "C" .And. alltrim(cUFCliFor)<>"EX" .And. IMPOSTO->F3_TPALIQ == "R"
					n343+=(nVlrIVA)
				Endif
		    EndIF    
			IMPOSTO->(DbSkip())
		End
	
		//********************************************************************************
		//Totalizadores dos Debitos Fiscales
		//********************************************************************************	
		
		//Total de Debitos Fiscales para efectos de determinacion. Base Imponible:
		n46:=n40+n41+n42+n442+n443
			
		//Ajustes a los debitos fiscales de periodos anteriores
		If lArqAnt
			//Imposto a apurar do período anterior
			nCampo48:=FPerAnt(cArqAnt,"047")
			if nCampo48 <= n47
				n48 := nCampo48 
			EndIF
		Endif 
		
		//Total de Debitos Fiscales para efectos de determinacion. Debito Fiscal:
		n47:=n43+n452+n453+n48
	 
		//Será informado um parametro para informar este valor
		If !Empty(aDadGer[1,1])
			n80:=val(aDadGer[1,1])
		Endif				
		 
		//Total de Debitos Fiscales
		n49:= n48 + n80 + n47
		
		//********************************************************************************
		//Totalizadores dos Creditos Fiscales
		//********************************************************************************	
		
		//Total Compras y Creditos Fiscales de Periodo
		n35:=n30+n31+n33+n332+n333
		//Total Compras y Creditos Fiscales de Periodo
		n36:=n32+n322+n323+n34+n342+n343
		//Credito fiscal totalmente dedutivel
		If !Empty(aDadGer[1,2])
			n70:=val(aDadGer[1,2])
		Endif
		//Credito fiscal producto de la aplicacion del porcentaje de la prorrota
		n37:=(n36-n70)*((n46-n40)/n46)
		//Total dos creditos deducibles
		n71:=n70+n37
		//Excedente Creditos Fiscales del Mês anterior				
		If lArqAnt
			//Imposto a apurar do período anterior
			n20:=FPerAnt(cArqAnt,"060")	
		Endif
		//Reintegro Solicitado
		If !empty(aDadGer[1,3])
			n21:=val(aDadGer[1,3])
		EndIF
		//Reintegro Solicitado			
		If !empty(aDadGer[1,4])
			n81:=val(aDadGer[1,4])
		EndIF            
		//Ajuste a los Creditos Fiscales de Periodos Anteriores
		If SubSTR(IMPOSTO->F3_EMISSAO,5,2) < SubSTR(IMPOSTO->F3_ENTRADA,5,2) .And. &("IMPOSTO->F3_VALIMP"+clLivro)>0 .And. IMPOSTO->F3_TIPOMOV == "C" 
			n38:=nVlrIVA
		EndIF
		//Certificados de Débitos Fiscales Exonerados
		If !empty(aDadGer[1,7])
			n82:=val(aDadGer[1,7])
		EndIF
		//Total creditos fiscales
		n39:=n20+n38+n71+n21+n81+n82	
		
		//********************************************************************************
		//Autoliquidación
		//********************************************************************************
		
		//Total Cuota Tributaria Del Periodo
		If (n49-n39) > 0
			n53:=(n49-n39)
		EndIF
		//Excedente Fiscal para o mês seguinte
		If (n47-n39) < 0
			n60:=(-1)*(n47-n39)//grava valor positivo
		EndIF
	    //SubTotal
	    n78:=n53+n22+n51-n60
	    //Retenciones acumuladas por descontar
		If lArqAnt
			//Imposto a apurar do período anterior
			nlRtAc:=FPerAnt(cArqAnt,"060")
			If (nlRtAc - n66 - n53) > 0 
				n54:=nlRtAc - n66 - n53
			EndIF
		Endif
	
		//Creditos Adquiridos por Cesíon de retenciones
		If !empty(aDadGer[1,5])
			n72:=val(aDadGer[1,5])
		EndIF
		//Recuperación de retenciones solicitadas
		If !empty(aDadGer[1,6])
			n73:=val(aDadGer[1,6])
		EndIF
		//Total de retenciones
		n74:= n54+n66+n72+n73
		//Retenciones suportadas descontadas em esta declaracion
		If n54+n66 <= n53
			n55:=n54+n66
		EndIF
		//Saldo de retenciones de IVA no Aplicado
		n67:=(n54+n66)-n55
		//Sub-Total impuesto a pagar
		n56:=n53-n55
		//Total a pagar
		n90:=n56
	                                       
		aAdd(apTabApu,{"040"   ,STR0017  ,n40	,.F.}) //"Ventas Internas no gravadas: - Vendas gravadas comn alíquota com 12% ou 10% ou 22% que não tem direito a crédito"
		aAdd(apTabApu,{"041"   ,STR0018  ,n41   ,.F.}) //"Ventas Exportacion: - Vendas gravadas com alíquota 0%."
		aAdd(apTabApu,{"042"   ,STR0019  ,n42   ,.F.}) //"Base Imponible: - Vendas gravadas com alíquota de 12%"
		aAdd(apTabApu,{"043"   ,STR0019  ,n43   ,.F.}) //"Debito Fiscal: - Vendas gravadas com alíquota de 12%."
		aAdd(apTabApu,{"442"   ,STR0020  ,n442  ,.F.}) //"Base Imponible: - Vendas gravadas com alíquota 10%."
		aAdd(apTabApu,{"452"   ,STR0020  ,n452  ,.F.}) //"Debito Fiscal: - Vendas Gravadas com alíquota 10%."
		aAdd(apTabApu,{"443"   ,STR0021  ,n443	,.F.}) //"Base Imponible: - Vendas gravadas com alíquota de 8%."
		aAdd(apTabApu,{"453"   ,STR0021  ,n453  ,.F.}) //"Debito Fiscal: - Vendas gravadas com alíquota de 8%."
		aAdd(apTabApu,{"046"   ,STR0022  ,n46    ,.F.}) //"Total de Debitos Fiscales para efectos de determinacion. Base Imponible:"
		aAdd(apTabApu,{"047"   ,STR0022  ,n47    ,.F.}) //"Total de Debitos Fiscales para efectos de determinacion. Debito Fiscal:"
		aAdd(apTabApu,{"048"   ,STR0023  ,n48     ,.F.}) //"Ajustes a los debitos fiscales de periodos anteriores"
		aAdd(apTabApu,{"080"   ,STR0024  ,n80     ,.F.}) //"Será informado um parametro para informar este valor"
		aAdd(apTabApu,{"049"   ,STR0025  ,n49     ,.F.}) //"Total de Debitos Fiscales"
		aAdd(apTabApu,{"030"   ,STR0026  ,n30     ,.F.}) //"Compras no Gravadas y /o sin Derecho a Crédito Fiscal."
		aAdd(apTabApu,{"031"   ,STR0027  ,n31     ,.F.}) //"Importaciones gravadas por alicuota general: Compras gravadas com alíquota 12%."
		aAdd(apTabApu,{"032"   ,STR0027  ,n32     ,.F.}) //"Importaciones gravadas por alicuota general: Compras gravadas com alíquota 12%."
		aAdd(apTabApu,{"312"   ,STR0028  ,n312    ,.F.}) //"Importaciones gravadas por alicuota general: Compras gravadas com alíquota 10%."
		aAdd(apTabApu,{"322"   ,STR0028  ,n322    ,.F.}) //"Importaciones gravadas por alicuota general: Compras gravadas com alíquota 10%."
		aAdd(apTabApu,{"313"   ,STR0029  ,n313    ,.F.}) //"Importaciones gravadas por alicuota general: Compras gravadas com alíquota 8%."
		aAdd(apTabApu,{"323"   ,STR0029  ,n323    ,.F.}) //"Importaciones gravadas por alicuota general: Compras gravadas com alíquota 8%."
		aAdd(apTabApu,{"033"   ,STR0030  ,n33     ,.F.}) //"Compras Internas Gravadas a solo por alicuota general de 12%: - Compras Gravadas com aliquota de 12%"
		aAdd(apTabApu,{"034"   ,STR0030  ,n34     ,.F.}) //"Compras Internas Gravadas a solo por alicuota general de 12%: - Compras Gravadas com aliquota de 12% "
		aAdd(apTabApu,{"332"   ,STR0031  ,n332    ,.F.}) //"Compras Internas Gravadas a solo por alicuota general de 10%: - Compras Gravadas com aliquota de 10% "
		aAdd(apTabApu,{"342"   ,STR0031  ,n342    ,.F.}) //"Compras Internas Gravadas a solo por alicuota general de 10%: - Compras Gravadas com aliquota de 10%"	
		aAdd(apTabApu,{"333"   ,STR0032  ,n333    ,.F.}) //"Compras Internas Gravadas a solo por alicuota reducida: - Compras Gravadas com aliquota de 8%	
		aAdd(apTabApu,{"343"   ,STR0032  ,n343    ,.F.}) //"Compras Internas Gravadas a solo por alicuota reducida: - Compras Gravadas com aliquota de 8%
		aAdd(apTabApu,{"035"   ,STR0033  ,n35     ,.F.}) //"Total Compras y Creditos Fiscales de Periodo"
		aAdd(apTabApu,{"036"   ,STR0033  ,n36     ,.F.}) //"Total Compras y Creditos Fiscales de Periodo"	
		aAdd(apTabApu,{"070"   ,STR0034  ,n70     ,.F.}) //"Credito fiscal totalmente dedutivel"
		aAdd(apTabApu,{"037"   ,STR0035  ,n37     ,.F.}) //"Credito fiscal producto de la aplicacion del porcentaje de la prorrata"
		aAdd(apTabApu,{"071"   ,STR0036  ,n71     ,.F.}) //"Total dos creditos deducibles"
		aAdd(apTabApu,{"020"   ,STR0037  ,n20     ,.F.}) //"Excedente Creditos Fiscales del Mês anterior"	
		aAdd(apTabApu,{"021"   ,STR0038  ,n21     ,.F.}) //"Reintegro Solicitado"	
		aAdd(apTabApu,{"081"   ,STR0039  ,n81     ,.F.}) //"Reintegro Solicitado"
		aAdd(apTabApu,{"038"   ,STR0040  ,n38     ,.F.}) //"Ajuste a los Creditos Fiscales de Periodos Anteriores"
		aAdd(apTabApu,{"082"   ,STR0041  ,n82     ,.F.}) //"Certificados de Débitos Fiscales Exonerados"				
		aAdd(apTabApu,{"039"   ,STR0042  ,n39     ,.F.}) //"Total creditos fiscales
		aAdd(apTabApu,{"053"   ,STR0043  ,n53     ,.F.}) //"Total Cuota Tributaria Del Periodo"	
		aAdd(apTabApu,{"060"   ,STR0044  ,n60     ,.F.}) //"Excedente Fiscal para o mês seguinte"	
		aAdd(apTabApu,{"078"   ,STR0048  ,n78     ,.F.}) //"SubTotal"
		aAdd(apTabApu,{"054"   ,STR0049  ,n54     ,.F.}) //"Retenciones acumuladas por descontar"	
		aAdd(apTabApu,{"066"   ,STR0050  ,n66     ,.F.}) //"Retenciones de periodo: - Retenções de IVA que tenha sido efetuadas no periodo."	
		aAdd(apTabApu,{"072"   ,STR0051  ,n72     ,.F.}) //"Creditos Adquiridos por Cesíon de retenciones"		
		aAdd(apTabApu,{"073"   ,STR0052  ,n73     ,.F.}) //"Recuperación de retenciones solicitadas"
		aAdd(apTabApu,{"074"   ,STR0053  ,n74     ,.F.}) //"Total de retenciones"	
		aAdd(apTabApu,{"055"   ,STR0054  ,n55     ,.F.}) //"Retenciones suportadas descontadas em esta declaracion"
		aAdd(apTabApu,{"067"   ,STR0055  ,n67     ,.F.}) //"Saldo de retenciones de IVA no Aplicado"
		aAdd(apTabApu,{"056"   ,STR0056  ,n56     ,.F.}) //"Sub-Total impuesto a pagar"
		aAdd(apTabApu,{"090"   ,STR0064  ,n90     ,.F.}) //"Total a pagar"		
	EndIF

	FRConf() //Geração do Relatorio de Conferencia das Informações                                   

	If !llMDados 	
		If lGerTit
			MsgRun(STR0013,,{|| IIf(n90>0,aTitulos := GrvTitLoc(n90),Nil) }) //"Gerando titulo de apuração..." //mudar n90
		Endif
		
		MsgRun(STR0014,,{|| CriarArq(cNomTxt,apTabApu,aTitulos) })//"Gerando Arquivo apuração de imposto..."	
	EndIf	
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FPerant   ³ Autor ³ Tiago Bizan           ³ Data ³02/08/2010³±±
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
±±³ Uso      ³ Impostos			                                          ³±±
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
	
	
	clNome := cpDir + cArq + ".iv"
	
	If !Empty(cArq)
		If FT_FUSE(clNome) <> -1
			FT_FGOTOP()
			If File(clNome)
				While !FT_FEOF()
					cBuffer := FT_FREADLN()
					If Substr(cBuffer,9,3) == cCod
						clAux := StrTran(Substr(cBuffer,127,17),".","")						
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

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CriarArq  ³ Autor ³ Tiago Bizan           ³ Data ³05/08/2010³±±
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
±±³ Uso      ³ TXT  				                                      ³±±
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
±±³Fun‡…o    FMApur   ³ Autor ³ Tiago Bizan             ³ Data ³02/08/2010³±±
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
±±³ Uso      ³ Impostos			                                          ³±±
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
	clNome := cpDir + cNomArq + ".iv" 	
	
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
±±³Fun‡…o    ³ApurTXT   ³ Autor ³ Tiago Bizan           ³ Data ³11/08/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Excluir o titulo de apuração para o governo.				  ³±±	
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ApurTXT() 		                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum								  					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRet- Se .T. Foi excluido. Se .F. não foi possivel excluir ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ler o TXT			                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/         
Static Function ApurTXT(cNomArq,cEsc)
	Local   lRet        := .T.
	Local   cBuffer     := ""
	Local   aDadosSE2   := {}
	Local	clNome		:= "" 
	Private lMsErroAuto := .F.
	
	clNome := cpDir + cNomArq + ".iv" 
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
±±³Função    FRConf() ³ Autor ³ Tiago Bizan             ³ Data ³16/08/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Função que cria o objeto do TMSPRINTER e chama as funções  ³±±
±±³ 		 | de impressão do cabeçalho e do corpo do relatorio		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FRConf()				                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum						                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Impostos			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function FRConf()
    Private clTitulo 	:= STR0065 //"Relatório de Conferência de Informações"
   	Private opFont1		:= TFont():New("Garamond",,20,,.T.,,,,,.F.)
	Private opFont2  	:= TFont():New("Perpetua",,12,,.T.,,,,,.F.)
	Private opFont3  	:= TFont():New("Perpetua",,12,,.F.,,,,,.F.)
	Private opFont4  	:= TFont():New("Perpetua",,11,,.F.,,,,,.F.)
    
	oPrn := TmsPrinter():New(clTitulo)
	oPrn:SetPaperSize(9)
	oPrn:SetPortrait()
	oPrn:StartPage()

	FCRConf()
    FIRConf()
       
	oPrn:EndPage()
	oPrn:Preview()
	oPrn:End()
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    FCRConf() ³ Autor ³ Tiago Bizan            ³ Data ³16/08/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Função que faz a impressão do cabeçalho					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FCRConf()				                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum						                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Impostos			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function FCRConf()

 	oPrn:Box(0020,0020,0100,2355)
	oPrn:Say(0022,750,clTitulo,opFont1)
	oPrn:Box(0120,1900,0280,2355)
	oPrn:Say(0125,1920,STR0066,opFont2)//"Periodo de Imposicion"
	oPrn:Line(0180,1900,0180,2355)
	oPrn:Say(0185,1950,STR0067,opFont3)//"MES"
	oPrn:Say(0185,2200,STR0068,opFont3)//"AÑO"
	oPrn:Line(0230,1900,0230,2355)	
	oPrn:Say(0235,1950,SubSTR(dtos(MV_PAR01),5,2),opFont3)
	oPrn:Say(0235,2200,SubSTR(dtos(MV_PAR01),1,4),opFont3)
	oPrn:Line(0180,2100,0280,2100)
	
	oPrn:Box(0300,0020,0450,2355)
	oPrn:Say(0305,0025,STR0069,opFont3)//"SI ESTA ES UNA DECLARACION SUSTITUTIVA O COMPLEMENTARIA, Nº FECHA"
	oPrn:Say(0305,1920,STR0070,opFont2)//"FECHA"
	oPrn:Say(0305,2060,dtoc(dDataBase),opFont3)	
	oPrn:Line(0350,0020,0350,2355)
	oPrn:Say(0355,0025,STR0071,opFont2)//"A - DADOS DEL CONTRIBUYENTE"
	oPrn:Say(0355,1920,STR0072,opFont2)//"Nº RIF"
	oPrn:Say(0355,2060,SM0->M0_CGC,opFont3)
	oPrn:Line(0400,0020,0400,2355)
	oPrn:Say(0405,0025,SM0->M0_NOMECOM,opFont3)
	oPrn:Say(0405,1920,STR0073,opFont2)//"Nº NIT"
	oPrn:Line(0300,1900,0450,1900)
	
	oPrn:Box(0480,0020,0580,2355)
	oPrn:Say(0485,0025,STR0074,opFont2)//"DATOS DEL APODERADO O REPRESENTANTE LEGAL"
	oPrn:Line(0530,0020,0530,2355)
	oPrn:Say(0535,1920,STR0072,opFont2)
	oPrn:Line(0530,1900,0580,1900)
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    FIRConf() ³ Autor ³ Tiago Bizan            ³ Data ³16/08/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Função que faz a impressão dos registros					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FIRConf()				                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum						                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Impostos			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FIRConf()
  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  DÉBITOS FISCALES                                        		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	

	oPrn:Box(0600,0020,2000,2355)
	oPrn:Say(0605,0025,STR0008,opFont2)//"Débitos Fiscales" 
	oPrn:Say(0605,1570,STR0075,opFont2)//"BASE IMPONIBLE"
	oPrn:Say(0605,1980,STR0076,opFont2)//"DÉBITO FISCALE"	
	oPrn:Line(0650,0020,0650,2355)
	//LINHA VERTICAL	
	oPrn:Line(0650,0070,1100,0070)
	oPrn:Line(0600,1565,0950,1565)
	oPrn:Line(0650,1650,0950,1650)
	oPrn:Line(0600,1975,1100,1975)
	oPrn:Line(0750,2055,1100,2055)

	oPrn:Say(0655,0025,"1",opFont3)
	oPrn:Say(0655,0075,STR0017,opFont3)                       	
	oPrn:Say(0655,1690,AliDir(apTabApu[1,3],"@E 999,999,999.99"),opFont3)	
	oPrn:Say(0655,1570,"40",opFont3)
	oPrn:Line(0700,0020,0700,1975)	
	
	oPrn:Say(0705,0025,"2",opFont3)
	oPrn:Say(0705,0075,STR0018,opFont3)                     
	oPrn:Say(0705,1690,AliDir(apTabApu[2,3],"@E 999,999,999.99"),opFont3)
	oPrn:Say(0705,1570,"41",opFont3)
	oPrn:Line(0750,0020,0750,2355)
	
	oPrn:Say(0755,0025,"3",opFont3)
	oPrn:Say(0755,0075,STR0019,opFont3)                      
	oPrn:Say(0755,1690,AliDir(apTabApu[3,3],"@E 999,999,999.99"),opFont3)
	oPrn:Say(0755,1570,"42",opFont3)
	oPrn:Say(0755,2060,AliDir(apTabApu[4,3],"@E 999,999,999.99"),opFont3)
	oPrn:Say(0755,1980,"43",opFont3)
	oPrn:Line(0800,0020,0800,2355)
	
	oPrn:Say(0805,0025,"4",opFont3)
	oPrn:Say(0805,0075,STR0020,opFont3)                       
	oPrn:Say(0805,1690,AliDir(apTabApu[5,3],"@E 999,999,999.99"),opFont3)
	oPrn:Say(0805,1570,"442",opFont3)
	oPrn:Say(0805,2060,AliDir(apTabApu[6,3],"@E 999,999,999.99"),opFont3)
	oPrn:Say(0805,1980,"452",opFont3)
	oPrn:Line(0850,0020,0850,2355)		
	
	oPrn:Say(0855,0025,"5",opFont3)
	oPrn:Say(0855,0075,STR0021,opFont3)                       
	oPrn:Say(0855,1690,AliDir(apTabApu[7,3],"@E 999,999,999.99"),opFont3)
	oPrn:Say(0855,1570,"443",opFont3)
	oPrn:Say(0855,2060,AliDir(apTabApu[8,3],"@E 999,999,999.99"),opFont3)
	oPrn:Say(0855,1980,"453",opFont3)
	oPrn:Line(0900,0020,0900,2355)
	
	oPrn:Say(0905,0025,"6",opFont3)	
	oPrn:Say(0905,0075,STR0022,opFont3)                  
	oPrn:Say(0905,1690,AliDir(apTabApu[9,3],"@E 999,999,999.99"),opFont3)
	oPrn:Say(0905,1570,"46",opFont3)
	oPrn:Say(0905,2060,AliDir(apTabApu[10,3],"@E 999,999,999.99"),opFont3)
	oPrn:Say(0905,1980,"47",opFont3)
	oPrn:Line(0950,0020,0950,2355)          
	
	oPrn:Say(0955,0025,"7",opFont3)	
	oPrn:Say(0955,0075,STR0023,opFont3)                    
	oPrn:Say(0955,2060,AliDir(apTabApu[11,3],"@E 999,999,999.99"),opFont3)
	oPrn:Say(0955,1980,"48",opFont3)
	oPrn:Line(1000,0020,1000,2355)		
	
	oPrn:Say(1005,0025,"8",opFont3)
	oPrn:Say(1005,0075,STR0024,opFont3)                   
	oPrn:Say(1005,2060,AliDir(apTabApu[12,3],"@E 999,999,999.99"),opFont3)
	oPrn:Say(1005,1980,"80",opFont3)
	oPrn:Line(1050,0020,1050,2355)
	
	oPrn:Say(1055,0025,"9",opFont3)	
	oPrn:Say(1055,0075,STR0025,opFont2)                      
	oPrn:Say(1055,2060,AliDir(apTabApu[13,3],"@E 999,999,999.99"),opFont3)
	oPrn:Say(1055,1980,"49",opFont3)
	oPrn:Line(1100,0020,1100,2355)  
	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  CRÉDITOS FISCALES                                        		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		

	oPrn:Say(1105,0025,STR0009,opFont2)//Créditos Fiscales 
	oPrn:Say(1105,1570,STR0075,opFont2)//"BASE IMPONIBLE"
	oPrn:Say(1105,1980,STR0077,opFont2)//"CRÉDITO FISCALE"	
	oPrn:Line(1150,0020,1150,2355)
   	//LINHA VERTICAL	
	oPrn:Line(1150,0070,2000,0070)
	oPrn:Line(1100,1565,1550,1565)
	oPrn:Line(1150,1650,1550,1650)
	oPrn:Line(1100,1975,2000,1975)
	oPrn:Line(1200,2055,2000,2055)	
	
  	oPrn:Say(1155,0025,"10",opFont3)
  	oPrn:Say(1155,0075,STR0026,opFont3) 
  	oPrn:Say(1155,1690, AliDir(apTabApu[14,3],"@E 999,999,999.99"),opFont3)
  	oPrn:Say(1155,1570,"30",opFont3)	                        
	oPrn:Line(1200,0020,1200,2355)  
   
	oPrn:Say(1205,0025,"11",opFont3)
	oPrn:Say(1205,0075,STR0027,opFont3)                         
	oPrn:Say(1205,1690, AliDir(apTabApu[15,3],"@E 999,999,999.99"),opFont3)
	oPrn:Say(1205,1570,"31",opFont3)                                         
	oPrn:Say(1205,2060, AliDir(apTabApu[16,3],"@E 999,999,999.99"),opFont3)
	oPrn:Say(1205,1980,"32",opFont3)
	oPrn:Line(1250,0020,1250,2355)
	 
	oPrn:Say(1255,0025,"12",opFont3)
	oPrn:Say(1255,0075,STR0028,opFont3)                         
	oPrn:Say(1255,1690, AliDir(apTabApu[17,3],"@E 999,999,999.99"),opFont3)
	oPrn:Say(1255,1570,"312",opFont3)         
	oPrn:Say(1255,2060, AliDir(apTabApu[18,3],"@E 999,999,999.99"),opFont3)
	oPrn:Say(1255,1980,"322",opFont3)		
	oPrn:Line(1300,0020,1300,2355) 
	
	oPrn:Say(1305,0025,"13",opFont3)
	oPrn:Say(1305,0075,STR0029,opFont3)                         
	oPrn:Say(1305,1690, AliDir(apTabApu[19,3],"@E 999,999,999.99"),opFont3)
	oPrn:Say(1305,1570,"313",opFont3)         
	oPrn:Say(1305,2060, AliDir(apTabApu[20,3],"@E 999,999,999.99"),opFont3)
	oPrn:Say(1305,1980,"323",opFont3)
	oPrn:Line(1350,0020,1350,2355) 
	
	oPrn:Say(1355,0025,"14",opFont3)
	oPrn:Say(1355,0075,STR0030,opFont3)                         
	oPrn:Say(1355,1690, AliDir(apTabApu[21,3],"@E 999,999,999.99"),opFont3)
	oPrn:Say(1355,1570,"33",opFont3)          
	oPrn:Say(1355,2060, AliDir(apTabApu[22,3],"@E 999,999,999.99"),opFont3)
	oPrn:Say(1355,1980,"34",opFont3)
	oPrn:Line(1400,0020,1400,2355) 
	
	oPrn:Say(1405,0025,"15",opFont3)
	oPrn:Say(1405,0075,STR0031,opFont3)                         
	oPrn:Say(1405,1690, AliDir(apTabApu[23,3],"@E 999,999,999.99"),opFont3)
	oPrn:Say(1405,1570,"332",opFont3)         
	oPrn:Say(1405,2060, AliDir(apTabApu[24,3],"@E 999,999,999.99"),opFont3)
	oPrn:Say(1405,1980,"342",opFont3)
	oPrn:Line(1450,0020,1450,2355) 
	
	oPrn:Say(1455,0025,"16",opFont3)
	oPrn:Say(1455,0075,STR0032,opFont3)                         
	oPrn:Say(1455,1690, AliDir(apTabApu[25,3],"@E 999,999,999.99"),opFont3)
	oPrn:Say(1455,1570,"333",opFont3)         
	oPrn:Say(1455,2060, AliDir(apTabApu[26,3],"@E 999,999,999.99"),opFont3)
	oPrn:Say(1455,1980,"343",opFont3)
	oPrn:Line(1500,0020,1500,2355) 
	
	oPrn:Say(1505,0025,"17",opFont3)
	oPrn:Say(1505,0075,STR0033,opFont3)                         
	oPrn:Say(1505,1690, AliDir(apTabApu[27,3],"@E 999,999,999.99"),opFont3)
	oPrn:Say(1505,1570,"35",opFont3)          
	oPrn:Say(1505,2060, AliDir(apTabApu[28,3],"@E 999,999,999.99"),opFont3)
	oPrn:Say(1505,1980,"36",opFont3)
	oPrn:Line(1550,0020,1550,2355) 
	 
  	oPrn:Say(1555,0025,"18",opFont3)
  	oPrn:Say(1555,0075,STR0024,opFont3) 
  	oPrn:Say(1555,2060,AliDir(apTabApu[29,3],"@E 999,999,999.99"),opFont3)
  	oPrn:Say(1555,1980,"70",opFont3)	                        
	oPrn:Line(1600,0020,1600,2355)
	
  	oPrn:Say(1605,0025,"19",opFont3)
  	oPrn:Say(1605,0075,STR0035,opFont3) 
  	oPrn:Say(1605,2060, AliDir(apTabApu[30,3],"@E 999,999,999.99"),opFont3)
  	oPrn:Say(1605,1980,"37",opFont3)	                        
	oPrn:Line(1650,0020,1650,2355)                   
	
  	oPrn:Say(1655,0025,"20",opFont3)
  	oPrn:Say(1655,0075,STR0036,opFont3) 
  	oPrn:Say(1655,2060, AliDir(apTabApu[31,3],"@E 999,999,999.99"),opFont3)
  	oPrn:Say(1655,1980,"71",opFont3)	                        
	oPrn:Line(1700,0020,1700,2355)  
	
  	oPrn:Say(1700,0025,"21",opFont3)
  	oPrn:Say(1700,0075,STR0037,opFont3) 
  	oPrn:Say(1700,2060, AliDir(apTabApu[32,3],"@E 999,999,999.99"),opFont3)
  	oPrn:Say(1700,1980,"20",opFont3)	                        
	oPrn:Line(1750,0020,1750,2355)  
	
  	oPrn:Say(1755,0025,"22",opFont3)
  	oPrn:Say(1755,0075,STR0038,opFont3) 
  	oPrn:Say(1755,2060, AliDir(apTabApu[33,3],"@E 999,999,999.99"),opFont3)
  	oPrn:Say(1755,1980,"21",opFont3)	                        
	oPrn:Line(1800,0020,1800,2355)  
	
  	oPrn:Say(1805,0025,"23",opFont3)
  	oPrn:Say(1805,0075,STR0039,opFont3) 
  	oPrn:Say(1805,2060, AliDir(apTabApu[34,3],"@E 999,999,999.99"),opFont3)
  	oPrn:Say(1805,1980,"81",opFont3)	                        
	oPrn:Line(1850,0020,1850,2355)  
	
  	oPrn:Say(1855,0025,"24",opFont3)
  	oPrn:Say(1855,0075,STR0040,opFont3) 
  	oPrn:Say(1855,2060, AliDir(apTabApu[35,3],"@E 999,999,999.99"),opFont3)
  	oPrn:Say(1855,1980,"38",opFont3)	                        
	oPrn:Line(1900,0020,1900,2355)  
	
  	oPrn:Say(1905,0025,"25",opFont3)
  	oPrn:Say(1905,0075,STR0041,opFont3) 
  	oPrn:Say(1905,2060, AliDir(apTabApu[36,3],"@E 999,999,999.99"),opFont3)
  	oPrn:Say(1905,1980,"82",opFont3)	                        
	oPrn:Line(1950,0020,1950,2355)  
	
  	oPrn:Say(1955,0025,"26",opFont3)
  	oPrn:Say(1955,0075,STR0042,opFont2) 
  	oPrn:Say(1955,2060, AliDir(apTabApu[37,3],"@E 999,999,999.99"),opFont3)
  	oPrn:Say(1955,1980,"39",opFont3)	                        
	oPrn:Line(2000,0020,2000,2355)  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  AUTOLIQUIDACION                                        		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    
   	oPrn:Box(2030,0020,3180,2355)
   	oPrn:Say(2035,0025,STR0010,opFont2)//"Autoliquidación"
   	oPrn:Line(2080,0020,2080,2355)   		
	oPrn:Line(2080,0070,3180,0070)//LINHA VERTICAL
	   	
  	oPrn:Say(2085,0025,"27",opFont3)
  	oPrn:Say(2085,0075,STR0043,opFont3) 
  	oPrn:Say(2085,2060, AliDir(apTabApu[38,3],"@E 999,999,999.99"),opFont3)
  	oPrn:Say(2085,1980,"53",opFont3)
	oPrn:Line(2080,1975,3180,1975)
	oPrn:Line(2080,2055,3180,2055)	
	oPrn:Line(2130,0020,2130,2355)  
	
	oPrn:Say(2135,0025,"28",opFont3)
  	oPrn:Say(2135,0075,STR0044,opFont3) 	                        
  	oPrn:Say(2135,2060,AliDir(apTabApu[39,3],"@E 999,999,999.99"),opFont3)
  	oPrn:Say(2135,1980,"60",opFont3)
	oPrn:Line(2180,0020,2180,2355)  
	
	oPrn:Say(2185,0025,"29",opFont3)
  	oPrn:Say(2185,0075,STR0045,opFont3) 	                        
	oPrn:Line(2180,1565,2330,1565)
	oPrn:Line(2180,1650,2330,1650)            
	oPrn:Say(2185,1690,AliDir(0.00,"@E 999,999,999.99"),opFont3)
  	oPrn:Say(2185,1570,"22",opFont3)
	oPrn:Line(2230,0020,2230,2355)  
	
	oPrn:Say(2235,0025,"30",opFont3)
  	oPrn:Say(2235,0075,STR0046,opFont3) 	                        
  	oPrn:Say(2235,1690,AliDir(0.00,"@E 999,999,999.99"),opFont3)
  	oPrn:Say(2235,1570,"51",opFont3)
	oPrn:Line(2280,0020,2280,2355)  
	
	oPrn:Say(2285,0025,"31",opFont3)
  	oPrn:Say(2285,0075,STR0047,opFont3) 	                        
  	oPrn:Say(2285,1690,AliDir(0.00,"@E 999,999,999.99"),opFont3)
  	oPrn:Say(2285,1570,"24",opFont3)
	oPrn:Line(2330,0020,2330,2355)  
	
	oPrn:Say(2335,0025,"32",opFont3)
  	oPrn:Say(2335,0075,STR0048,opFont3) 
	oPrn:Line(2330,1975,2380,1975)
	oPrn:Line(2330,2055,2380,2055)	          
	oPrn:Say(2335,2060, AliDir(apTabApu[40,3],"@E 999,999,999.99"),opFont3)           
  	oPrn:Say(2335,1980,"78",opFont3)
	oPrn:Line(2380,0020,2380,2355)  
	
	oPrn:Say(2385,0025,"33",opFont3)
  	oPrn:Say(2385,0075,STR0049,opFont3) 	                        
	oPrn:Line(2380,1565,2630,1565)
	oPrn:Line(2380,1650,2630,1650)            
	oPrn:Say(2385,1690, AliDir(apTabApu[41,3],"@E 999,999,999.99"),opFont3)
  	oPrn:Say(2385,1570,"54",opFont3)
	oPrn:Line(2430,0020,2430,2355)  
	
	oPrn:Say(2435,0025,"34",opFont3)
  	oPrn:Say(2435,0075,STR0050,opFont3) 	                        
  	oPrn:Say(2435,1690, AliDir(apTabApu[42,3],"@E 999,999,999.99"),opFont3)
	oPrn:Say(2435,1570,"66",opFont3)
	oPrn:Line(2480,0020,2480,2355)  
	
	oPrn:Say(2485,0025,"35",opFont3)
  	oPrn:Say(2485,0075,STR0051,opFont3) 	                        
  	oPrn:Say(2485,1690, AliDir(apTabApu[43,3],"@E 999,999,999.99"),opFont3)
  	oPrn:Say(2485,1570,"72",opFont3)
	oPrn:Line(2530,0020,2530,2355)  
	
	oPrn:Say(2535,0025,"36",opFont3)
  	oPrn:Say(2535,0075,STR0052,opFont4) 	                        
  	oPrn:Say(2535,1690,AliDir(apTabApu[44,3],"@E 999,999,999.99"),opFont3)
  	oPrn:Say(2535,1570,"73",opFont3)
	oPrn:Line(2580,0020,2580,2355)  
	
	oPrn:Say(2585,0025,"37",opFont3)
  	oPrn:Say(2585,0075,STR0053,opFont3) 	                        
  	oPrn:Say(2585,1690,AliDir(apTabApu[45,3],"@E 999,999,999.99"),opFont3)
  	oPrn:Say(2585,1570,"74",opFont3)
	oPrn:Line(2630,0020,2630,2355)  
	
	oPrn:Say(2635,0025,"38",opFont3)
  	oPrn:Say(2635,0075,STR0054,opFont3) 	                        
  	oPrn:Line(2630,1975,2680,1975)
  	oPrn:Line(2630,2055,2680,2055)            
  	oPrn:Say(2635,2060,AliDir(apTabApu[46,3],"@E 999,999,999.99"),opFont3)
  	oPrn:Say(2635,1980,"55",opFont3)
	oPrn:Line(2680,0020,2680,2355)  
	
	oPrn:Say(2685,0025,"39",opFont3)
  	oPrn:Say(2685,0075,STR0055,opFont3) 	                        
	oPrn:Line(2680,1565,2730,1565)
	oPrn:Line(2680,1650,2730,1650)            
	oPrn:Say(2685,1690,AliDir(apTabApu[47,3],"@E 999,999,999.99"),opFont3)
  	oPrn:Say(2685,1570,"67",opFont3)
	oPrn:Line(2730,0020,2730,2355)  
	
	oPrn:Say(2735,0025,"40",opFont3)
  	oPrn:Say(2735,0075,STR0056,opFont3) 	                        
	oPrn:Line(2730,1975,2780,1975)
	oPrn:Line(2730,2055,2780,2055)            
	oPrn:Say(2735,2060,AliDir(apTabApu[48,3],"@E 999,999,999.99"),opFont3)
	oPrn:Say(2735,1980,"56",opFont3)	
	oPrn:Line(2780,0020,2780,2355)  
	
	oPrn:Say(2785,0025,"41",opFont3)
  	oPrn:Say(2785,0075,STR0057,opFont3) 	                        
	oPrn:Line(2780,1565,3030,1565)
	oPrn:Line(2780,1650,3030,1650)            
	oPrn:Say(2785,1690,AliDir(0.00,"@E 999,999,999.99"),opFont3)
  	oPrn:Say(2785,1570,"57",opFont3)
	oPrn:Line(2830,0020,2830,2355)  
	
	oPrn:Say(2835,0025,"42",opFont3)
  	oPrn:Say(2835,0075,STR0058,opFont3) 	                        
  	oPrn:Say(2835,1690,AliDir(0.00,"@E 999,999,999.99"),opFont3)
  	oPrn:Say(2835,1570,"68",opFont3)
	oPrn:Line(2880,0020,2880,2355)  
	
	oPrn:Say(2885,0025,"43",opFont3)
	oPrn:Say(2885,0075,STR0059,opFont3) 	                        
	oPrn:Say(2885,1690,AliDir(0.00,"@E 999,999,999.99"),opFont3)
	oPrn:Say(2885,1570,"75",opFont3)
	oPrn:Line(2930,0020,2930,2355)  
	
	oPrn:Say(2935,0025,"44",opFont3)
	oPrn:Say(2935,0075,STR0060,opFont4) 	                        
	oPrn:Say(2935,1690,AliDir(0.00,"@E 999,999,999.99"),opFont3)
	oPrn:Say(2935,1570,"76",opFont3)
	oPrn:Line(2980,0020,2980,2355)  
	
	oPrn:Say(2985,0025,"45",opFont3)
  	oPrn:Say(2985,0075,STR0061,opFont3) 	                        
  	oPrn:Say(2985,1690,AliDir(0.00,"@E 999,999,999.99"),opFont3)
  	oPrn:Say(2985,1570,"77",opFont3)
	oPrn:Line(3030,0020,3030,2355)	 
	
	oPrn:Say(3035,0025,"46",opFont3)
  	oPrn:Say(3035,0075,STR0062,opFont3) 	                        
  	oPrn:Line(3030,1975,3080,1975)
  	oPrn:Line(3030,2055,3080,2055)            
  	oPrn:Say(3035,2060,AliDir(0.00,"@E 999,999,999.99"),opFont3)
  	oPrn:Say(3035,1980,"58",opFont3)
	oPrn:Line(3080,0020,3080,2355)  
	
	oPrn:Say(3085,0025,"47",opFont3)
  	oPrn:Say(3085,0075,STR0063,opFont3) 	                        
	oPrn:Line(3080,1565,3130,1565)
	oPrn:Line(3080,1650,3130,1650)            
	oPrn:Say(3085,1690,AliDir(0.00,"@E 999,999,999.99"),opFont3)
  	oPrn:Say(3085,1570,"69",opFont3)
	oPrn:Line(3130,0020,3130,2355)  
	
	oPrn:Say(3135,0025,"48",opFont3)
  	oPrn:Say(3135,0075,STR0064,opFont2) 	                        
  	oPrn:Line(3130,1975,3180,1975)
  	oPrn:Line(3130,2055,3180,2055)            
  	oPrn:Say(3135,2060,AliDir(apTabApu[49,3],"@E 999,999,999.99"),opFont3)
  	oPrn:Say(3135,1980,"90",opFont3)
  
Return() 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    AliDir()³ Autor ³ Tiago Bizan ³			  Data ³16/08/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Função que faz a impressão dos registros					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AliDir(nVlr,cPicture)	                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nVlr: valor a ser alinhado  cPicture: picture do valor     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cRet: valor alinhado a direita							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Impostos			                                          ³±±
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
