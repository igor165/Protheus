#INCLUDE 'Protheus.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณKPIEstoqueบAutor  ณAndre Anjos		 บ Data ณ  04/11/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao para criacao de um arquivo de trabalho com alguns   บฑฑ
ฑฑบ          ณ indicadores do modulo de estoque.                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ nTipo: 1- Estoque Mensal									  บฑฑ
ฑฑบ			 ณ 		  2- Estoque Diario									  บฑฑ
ฑฑบ			 ณ 		  3- Saldo Estoque Diario							  บฑฑ
ฑฑบ			 ณ dDataIni: data inicial para busca dos movimentos.		  บฑฑ
ฑฑบ			 ณ dDataIni: data final para busca dos movimentos.		  	  บฑฑ
ฑฑบ			 ณ lIgnoreZero: Considerar produto sem saldo ou movimenta็ใo?	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno	 ณ cAliasInd: alias criado para o arquivo temporario.		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Diverso                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function KPIEstoque(nTipo,dDataIni,dDataFim,cFiltraFil, lIgnoreZero )
Local aArea       := GetArea() 
Local aCampos     := {}
Local aSaldoIni   := {}
Local aSaldoFim   := {}
Local cAliasInd   := GetNextAlias()
Local aStruSB2    := SB2->(dbStruct())
Local cArqTRB     := ""
Local cFilSB2	  := ""
Local cQuery      := ""
Local cAliasTop   := ""
Local nX	      := 0
Local nPeriodos	  := 0
Local aEntradas   := {0,0}
Local aSaidas     := {0,0,0}
Local nQtdeConR   := 0
Local nCustConR   := 0
Local nSalPedi	  := 0
Local cCCusto     := CriaVar("D3_CC",.F.)
Local dDataRef    := dDataIni
Local aQTamSX3    := TamSX3("B2_QATU")
Local aVTamSX3    := TamSX3("B2_VATU1")
Local aSTamSX3    := TamSX3("B2_SALPEDI")
Local cSubstr     := If("SQL" $ TCGetDB(),"SUBSTRING","SUBSTR")
Local cNameSB1    := RetSQLName("SB1")
Local cNameSB2    := RetSQLName("SB2")
Local cNameSD1    := RetSQLName("SD1")
Local cNameSD2    := RetSQLName("SD2")
Local cNameSD3    := RetSQLName("SD3")
Local cNameSF4    := RetSQLName("SF4")
Local cNameSC1    := RetSQLName("SC1")
Local cNameSC2    := RetSQLName("SC2")
Local cNameSC7    := RetSQLName("SC7")
Local cLayout1    := FWSM0Layout(,1) 
Local cLayout2    := FWSM0Layout(,2)
Local cSizeFilial := FWSizeFilial()
Local cModeSF4_1  := FWModeAccess("SF4",1)
Local cModeSF4_2  := FWModeAccess("SF4",2)
Local cModeSF4_3  := FWModeAccess("SF4",3)
Local cModeSB1_1  := FWModeAccess("SB1",1)
Local cModeSB1_2  := FWModeAccess("SB1",2)
Local cModeSB1_3  := FWModeAccess("SB1",3)
Local cModeSB2_1  := FWModeAccess("SB2",1)
Local cModeSB2_2  := FWModeAccess("SB2",2)
Local cModeSB2_3  := FWModeAccess("SB2",3)
Local cModeSD1_1  := FWModeAccess("SD1",1)
Local cModeSD1_2  := FWModeAccess("SD1",2)
Local cModeSD1_3  := FWModeAccess("SD1",3)
Local cModeSD2_1  := FWModeAccess("SD2",1)
Local cModeSD2_2  := FWModeAccess("SD2",2)
Local cModeSD2_3  := FWModeAccess("SD2",3)
Local cModeSD3_1  := FWModeAccess("SD3",1)
Local cModeSD3_2  := FWModeAccess("SD3",2)
Local cModeSD3_3  := FWModeAccess("SD3",3)
Local cModeSC1_1  := FWModeAccess("SC1",1)
Local cModeSC1_2  := FWModeAccess("SC1",2)
Local cModeSC1_3  := FWModeAccess("SC1",3)
Local cModeSC2_1  := FWModeAccess("SC2",1)
Local cModeSC2_2  := FWModeAccess("SC2",2)
Local cModeSC2_3  := FWModeAccess("SC2",3)
Local cModeSC7_1  := FWModeAccess("SC7",1)
Local cModeSC7_2  := FWModeAccess("SC7",2)
Local cModeSC7_3  := FWModeAccess("SC7",3)

Default nTipo      	:= 1
Default dDataIni   	:= dDatabase
Default dDataFim   	:= dDatabase
Default cFiltraFil 	:= cFilAnt
Default dDataRef   	:= dDataBase
Default lIgnoreZero 	:= .F. 

aAdd(aCampos,{"EMPRESA"		,"C",cSizeFilial			,0})	//Empresa e filial
aAdd(aCampos,{"ITEM"		,"C",TamSX3("B1_COD")[1]	,0})	//Produto
aAdd(aCampos,{"DEPOSITO"	,"C",TamSX3("B1_LOCPAD")[1],0})	//Deposito (Armazem)
aAdd(aCampos,{"UM"			,"C",TamSX3("B1_UM")[1]		,0})	//Unidade de Medida
aAdd(aCampos,{"CCUSTO"		,"C",TamSX3("CTT_CUSTO")[1],0}) 	//Centro de custo (fora de uso)
aAdd(aCampos,{"DATAMOV"		,"D",8						,0})	//Data
aAdd(aCampos,{"MOEDA"		,"C",1						,0})	//Moeda
aAdd(aCampos,{"FAMMAT"		,"C",TamSX3("B1_TIPO")[1]	,0})	//Familia meterial
aAdd(aCampos,{"FAMCOM"		,"C",TamSX3("ACV_CATEGO")[1],0})	//Familia comercial
aAdd(aCampos,{"GRUPO"		,"C",TamSX3("B1_GRUPO")[1]	,0})	//Grupo de estoque

Do Case
Case nTipo == 1
	aAdd(aCampos,{"QEREAL","N",aQTamSX3[1],aQTamSX3[2]})	//Qtde consumo real
	aAdd(aCampos,{"VEPREV","N",aVTamSX3[1],aVTamSX3[2]})	//Valor consumo previsto
	aAdd(aCampos,{"VEREAL","N",aVTamSX3[1],aVTamSX3[2]})	//Valor consumo real
	aAdd(aCampos,{"VESEGU","N",aVTamSX3[1],aVTamSX3[2]})	//Valor estoque seguranca
	aAdd(aCampos,{"QEPREV","N",aQTamSX3[1],aQTamSX3[2]})	//Qtde consumo previsto
	aAdd(aCampos,{"QINISD","N",aQTamSX3[1],aQTamSX3[2]})	//Qtde inicial
	aAdd(aCampos,{"QFINSD","N",aQTamSX3[1],aQTamSX3[2]})	//Qtde final
	aAdd(aCampos,{"VINISD","N",aVTamSX3[1],aVTamSX3[2]})	//Valor inicial	
	aAdd(aCampos,{"VFINSD","N",aVTamSX3[1],aVTamSX3[2]})	//Valor final
	aAdd(aCampos,{"QSDMED","N",aVTamSX3[1],aVTamSX3[2]})	//Saldo medio
	aAdd(aCampos,{"VSDMED","N",aVTamSX3[1],aVTamSX3[2]}) 	//Valor medio
	nPeriodos := ((Year(dDataFim) - Year(dDataIni)) * 12) + (Month(dDataFim) - Month(dDataIni)) + 1
Case nTipo == 2
	aAdd(aCampos,{"QENTRA","N",aQTamSX3[1],aQTamSX3[2]})	//Qtde entrada
	aAdd(aCampos,{"QSAIDA","N",aQTamSX3[1],aQTamSX3[2]})	//Qtde saida
	aAdd(aCampos,{"VENTRA","N",aVTamSX3[1],aVTamSX3[2]})	//Valor entrada
	aAdd(aCampos,{"VSAIDA","N",aVTamSX3[1],aVTamSX3[2]})	//Valor saida
	aAdd(aCampos,{"QSDMED","N",aVTamSX3[1],aVTamSX3[2]})	//Saldo medio
	aAdd(aCampos,{"QSAIAC","N",aVTamSX3[1],aVTamSX3[2]})	//Qtde saida acumulada
	aAdd(aCampos,{"VSDMED","N",aVTamSX3[1],aVTamSX3[2]}) 	//Valor medio
	aAdd(aCampos,{"QINISD","N",aQTamSX3[1],aQTamSX3[2]})	//Qtde inicial	
	aAdd(aCampos,{"VMATES","N",aVTamSX3[1],aVTamSX3[2]})	//Valor total em estoque
	nPeriodos := Iif( ( dDataFim - dDataIni ) == 0, 1, ( dDataFim - dDataIni ) )
Case nTipo == 3
	aAdd(aCampos,{"QINISD","N",aQTamSX3[1],aQTamSX3[2]})	//Qtde inicial
	aAdd(aCampos,{"QFINSD","N",aQTamSX3[1],aQTamSX3[2]})	//Qtde final
	aAdd(aCampos,{"VINISD","N",aVTamSX3[1],aVTamSX3[2]})	//Valor inicial	
	aAdd(aCampos,{"VFINSD","N",aVTamSX3[1],aVTamSX3[2]})	//Valor final
	nPeriodos := Iif( ( dDataFim - dDataIni ) == 0, 1, ( dDataFim - dDataIni ) )
EndCase

FWOpenTemp(cAliasInd,aCampos,@cArqTRB,.T.)
IndRegua(cAliasInd,cArqTRB,"EMPRESA+ITEM+DEPOSITO+DTOS(DATAMOV)+MOEDA")

If !Empty(cFiltraFil)
	If cModeSB2_3 == "E"
		cFilSB2 := cFiltraFil
	ElseIf cModeSB2_2 == "E"
		cFilSB2 := PadR(Substr(cFiltraFil,1,Len(cLayout1) +Len(cLayout2)),cSizeFilial)
	ElseIf cModeSB2_1 == "E"
		cFilSB2 := PadR(Substr(cFiltraFil,1,Len(cLayout1)),cSizeFilial)
	Else
		cFilSB2 := Space(cSizeFilial)
	EndIf
EndIf

SB1->(dbSetOrder(1))
SB2->(dbSetOrder(1))
ACV->(dbSetOrder(5))

If !Empty(cFiltraFil)
	SB2->(MsSeek(cFilSB2))
Else
	SB2->(dbGoTop())
EndIf

cAliasTop := GetNextAlias()
If Select(cAliasTop) > 0
  (cAliasTop)->(dbCloseArea())
EndIf
cQuery := "SELECT B2_FILIAL, B2_COD, B2_LOCAL, B2_CM1, B1_UM, B1_FILIAL, B1_TIPO, B1_GRUPO, B1_COD, B1_ESTFOR  "
cQuery +=   "FROM " + cNameSB2 +" SB2 "
cQuery +=   "JOIN " + cNameSB1 +" SB1 ON "
If !Empty(cFiltraFil)
	If cModeSB1_3 == "E"
		cQuery += "SB1.B1_FILIAL = '" + cFiltraFil + "' AND "
	ElseIf cModeSB1_2 == "E"
		cQuery += "SB1.B1_FILIAL = '" + PadR(Substr(cFiltraFil,1,Len(cLayout1) +Len(cLayout2)),cSizeFilial)  + "' AND "
	ElseIf cModeSB1_1 == "E"
		cQuery += "SB1.B1_FILIAL = '" + PadR(Substr(cFiltraFil,1,Len(cLayout1)),cSizeFilial) + "' AND "
	Else
		cQuery += "SB1.B1_FILIAL = '" + Space(cSizeFilial) + "' AND "
	EndIf
EndIf
cQuery +=         "SB1.B1_COD = SB2.B2_COD "
cQuery +=         "AND SB1.D_E_L_E_T_ = ' ' "
cQuery += "WHERE "
If !Empty(cFiltraFil)
	If cModeSB2_3 == "E"
		cQuery += "SB2.B2_FILIAL = '" +cFiltraFil + "' AND "
	ElseIf cModeSB2_2 == "E"
		cQuery += "SB2.B2_FILIAL = '" +PadR(Substr(cFiltraFil,1,Len(cLayout1)+Len(cLayout2)),cSizeFilial)  + "' AND "
	ElseIf cModeSB2_1 == "E"
		cQuery += "SB2.B2_FILIAL = '" +PadR(Substr(cFiltraFil,1,Len(cLayout1)),cSizeFilial) + "' AND "
	Else
		cQuery += "SB2.B2_FILIAL = '" +Space(cSizeFilial) + "' AND "
	EndIf
EndIf
cQuery +=          "SB2.D_E_L_E_T_ = ' ' "
cQuery += "ORDER BY B2_FILIAL,B2_COD,B2_LOCAL"

dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasTop,.F.,.T.)

For nX := 1 To Len(aStruSB2)
	If aStruSB2[nX][2]<>"C" .And. FieldPos(aStruSB2[nX][1])<>0
		TcSetField(cAliasTop,aStruSB2[nX][1],aStruSB2[nX][2],aStruSB2[nX][3],aStruSB2[nX][4])
	EndIf
Next nX

While !(cAliasTop)->(EOF()) .And. If(Empty(cFiltraFil),.T.,(cAliasTop)->B2_FILIAL == cFilSB2)
	If !IsProdMOD((cAliasTop)->B2_COD,.T.)
		ACV->(MsSeek(xFilial("ACV")+(cAliasTop)->B2_COD))
		dDataIni := dDataRef
		For nX := 1 to nPeriodos
			//-- Para o primeiro periodo, calcula saldo e cria alias com os totalizadores por periodo
			If nX == 1			
				aSaldoIni := CalcEst((cAliasTop)->B2_COD,(cAliasTop)->B2_LOCAL,dDataIni,(cAliasTop)->B2_FILIAL)
				cAliasEnt := Entradas(nTipo,dDataIni,dDataFim,cFiltraFil,(cAliasTop)->B2_COD,(cAliasTop)->B2_LOCAL,cSubstr,cSizeFilial,cLayout1,cLayout2,cNameSD1,cNameSD3,cNameSF4,aQTamSX3,aVTamSX3,cModeSF4_1,cModeSF4_2,cModeSF4_3,cModeSD1_1,cModeSD1_2,cModeSD1_3,cModeSD3_1,cModeSD3_2,cModeSD3_3)
				cAliasSai := Saidas(nTipo,dDataIni,dDataFim,dDataRef,cFiltraFil,(cAliasTop)->B2_COD,(cAliasTop)->B2_LOCAL,cSubstr,cSizeFilial,cLayout1,cLayout2,cNameSD2,cNameSD3,cNameSF4,aQTamSX3,aVTamSX3,cModeSF4_1,cModeSF4_2,cModeSF4_3,cModeSD2_1,cModeSD2_2,cModeSD2_3,cModeSD3_1,cModeSD3_2,cModeSD3_3)
			EndIf

			If nTipo == 1
				If Month(dDataIni) == 12
					dDataIni := SToD(Substr(DToS(dDataIni),1,6) + "01")
					dDataFim := SToD(Str(Year(dDataIni)+1,4) + "0101") - 1
				Else
					dDataIni := SToD(Substr(DToS(dDataIni),1,6) + "01")
					dDataFim := SToD(Str(Year(dDataIni),4) + Str(Month(dDataIni)+1,2) + "01") - 1
				EndIf
			ElseIf nX > 1
				dDataFim := ++dDataIni
			Else
				dDataFim := dDataIni
			EndIf
			
			aEntradas := {0,0}
			aSaidas   := {0,0,0}
			nQtdeConR := 0
			nCustConR := 0
		
			//-- Posiciona entradas no periodo correspondente
			While !(cAliasEnt)->(EOF()) .And. If(nTipo == 1,Substr(DToS(dDataIni),1,6),DToS(dDataIni)) > (cAliasEnt)->PERIODO
				(cAliasEnt)->(dbSkip())
			End
			
			//-- Posiciona saidas no periodo correspondente
			While !(cAliasSai)->(EOF()) .And. If(nTipo == 1,Substr(DToS(dDataIni),1,6),DToS(dDataIni)) > (cAliasSai)->PERIODO
				(cAliasSai)->(dbSkip())
			End
			
			aSaldoFim := aClone(aSaldoIni)
			While (cAliasEnt)->PERIODO == If(nTipo == 1,Substr(DToS(dDataIni),1,6),DToS(dDataIni))
				aSaldoFim[1] += (cAliasEnt)->QUANT
				aSaldoFim[2] += (cAliasEnt)->CUSTO1
				aSaldoFim[3] += (cAliasEnt)->CUSTO2
				aSaldoFim[4] += (cAliasEnt)->CUSTO3
				aSaldoFim[5] += (cAliasEnt)->CUSTO4
				aSaldoFim[6] += (cAliasEnt)->CUSTO5
				
				aEntradas[1] += (cAliasEnt)->QUANT
				aEntradas[2] += (cAliasEnt)->CUSTO1
								
				nQtdeConR -= (cAliasEnt)->QTDEDEV
				nCustConR -= (cAliasEnt)->CUSTDEV
				
				(cAliasEnt)->(dbSkip())
			End
			
			While (cAliasSai)->PERIODO == If(nTipo == 1,Substr(DToS(dDataIni),1,6),DToS(dDataIni))
				aSaldoFim[1] -= (cAliasSai)->QUANT
				aSaldoFim[2] -= (cAliasSai)->CUSTO1
				aSaldoFim[3] -= (cAliasSai)->CUSTO2
				aSaldoFim[4] -= (cAliasSai)->CUSTO3
				aSaldoFim[5] -= (cAliasSai)->CUSTO4
				aSaldoFim[6] -= (cAliasSai)->CUSTO5
				
				aSaidas[1] += (cAliasSai)->QUANT
				aSaidas[2] += (cAliasSai)->CUSTO1
				aSaidas[3] += (cAliasSai)->SAIDAACUM
				
				nQtdeConR += (cAliasSai)->QUANT - (cAliasSai)->QTDEDEV
				nCustConR += (cAliasSai)->CUSTO1 - (cAliasSai)->CUSTDEV
				
				(cAliasSai)->(dbSkip())
			End
			
			//-- Verifica se produtos sem saldo ou movimenta็ใo devem ser considerados. 		
			If ( lIgnoreZero ) 
				//-- Ignora produtos sem saldo ou movimenta็ใo. 	
				If 	( nTipo == 2 ) 			.And.;
				 	( aEntradas[1] == 0 ) 	.And.;
				  	( aEntradas[2] == 0 ) 	.And.;
				   	( aSaidas[1] == 0 ) 		.And.;
				   	( aSaidas[2] == 0 ) 		.And.;
				   	( aSaidas[3] == 0 ) 		.And.;
				   	( aSaldoIni[1] == 0 )	.And.;
				   	( aSaldoFim[2] == 0 )
				   			
					Loop 
				ElseIf ( nTipo == 3 ) 		 .And.;
				 		( aSaldoIni[1] == 0 ) .And.;
				  		( aSaldoIni[2] == 0 ) .And.;
				   		( aSaldoFim[1] == 0 ) .And.;
				    	( aSaldoFim[2] == 0 )

					Loop
				EndIf 
			EndIf 		
				
			//-- Grava as informa็๕es no arquivo temporแrio. 						
			RecLock(cAliasInd,.T.)
			
			(cAliasInd)->EMPRESA 	:= (cAliasTop)->B2_FILIAL
			(cAliasInd)->ITEM			:= (cAliasTop)->B2_COD
			(cAliasInd)->DEPOSITO	:= (cAliasTop)->B2_LOCAL
			(cAliasInd)->UM			:= (cAliasTop)->B1_UM
			(cAliasInd)->CCUSTO		:= cCCusto
			(cAliasInd)->DATAMOV		:= dDataFim
			(cAliasInd)->FAMMAT		:= (cAliasTop)->B1_TIPO
			(cAliasInd)->FAMCOM		:= ACV->ACV_CATEGO
			(cAliasInd)->GRUPO		:= (cAliasTop)->B1_GRUPO
			
			Do Case
			Case nTipo == 1
				nSalPedi := EntradasP(cFiltraFil,dDataFim,cSizeFilial,(cAliasTop)->B2_COD,(cAliasTop)->B2_LOCAL,aSTamSX3,cLayout1,cLayout2,cNameSC1,cNameSC2,cNameSC7,cModeSC1_1,cModeSC1_2,cModeSC1_3,cModeSC2_1,cModeSC2_2,cModeSC2_3,cModeSC7_1,cModeSC7_2,cModeSC7_3)
				(cAliasInd)->QEREAL	:= nQtdeConR
				(cAliasInd)->VEPREV	:= nSalPedi * (cAliasTop)->B2_CM1
				(cAliasInd)->VEREAL	:= nCustConR
				(cAliasInd)->VESEGU	:= CalcEstSeg(RetFldProd((cAliasTop)->B1_COD,"B1_ESTFOR",cAliasTop)) * (aSaldoIni[2] + aSaldoFim[2]) / 2
				(cAliasInd)->QEPREV	:= nSalPedi
				(cAliasInd)->QINISD	:= aSaldoIni[1]
				(cAliasInd)->QFINSD	:= aSaldoFim[1]
				(cAliasInd)->VINISD	:= aSaldoIni[2]
				(cAliasInd)->VFINSD	:= aSaldoFim[2]
				(cAliasInd)->QSDMED	:= (aSaldoIni[1] + aSaldoFim[1]) / 2
				(cAliasInd)->VSDMED	:= (aSaldoIni[2] + aSaldoFim[2]) / 2
			Case nTipo == 2
				(cAliasInd)->QENTRA	:= aEntradas[1]
				(cAliasInd)->QSAIDA	:= aSaidas[1]
				(cAliasInd)->VENTRA	:= aEntradas[2]
				(cAliasInd)->VSAIDA	:= aSaidas[2]
				(cAliasInd)->QSAIAC	:= aSaidas[3]
				(cAliasInd)->QSDMED	:= (aSaldoIni[1] + aSaldoFim[1]) / 2
				(cAliasInd)->VSDMED	:= (aSaldoIni[2] + aSaldoFim[2]) / 2
				(cAliasInd)->QINISD	:= aSaldoIni[1]
				(cAliasInd)->VMATES 	:= aSaldoFim[2]
			Case nTipo == 3
				(cAliasInd)->QINISD	:= aSaldoIni[1]
				(cAliasInd)->VINISD	:= aSaldoIni[2]
				(cAliasInd)->QFINSD	:= aSaldoFim[1]
				(cAliasInd)->VFINSD	:= aSaldoFim[2]
			EndCase
			
			(cAliasInd)->(MsUnLock())
			
			//-- O saldo inicial do proximo periodo torna-se o inicial deste
			aSaldoIni := aClone(aSaldoFim)
			
			//-- Se mensal, vira o mes
			If nTipo == 1
				dDataIni := dDataFim + 1
			EndIf
		Next nX
		If Type("cAliasEnt") <> "U" .And. Select(cAliasEnt) > 0 
			(cAliasEnt)->(dbCloseArea())
		EndIf
		If Type("cAliasSai") <> "U" .And. Select(cAliasSai) > 0	
			(cAliasSai)->(dbCloseArea())
		EndIf	
	EndIf
	dbSelectArea(cAliasTop)
	(cAliasTop)->(dbSkip())
End
If Select(cAliasTop)>0
	(cAliasTop)->(dbCloseArea())
EndIf
RestArea(aArea)
Return cAliasInd

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ Entradas บAutor  ณ Andre Anjos        บ Data ณ  05/11/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao que alimenta o array recebido como parametro com    บฑฑ
ฑฑบ          ณ os dados das entradas do dia.                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ dDataIni: data inicio para busca dos dados.				  บฑฑ
ฑฑบ			 ณ dDataFim: data fim para busca dos dados.					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ IndicEST                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Entradas(nTipo,dDataIni,dDataFim,cFiltraFil,cProduto,cLocal,cSubstr,cSizeFilial,cLayout1,cLayout2,cNameSD1,cNameSD3,cNameSF4,aQTamSX3,aVTamSX3,cModeSF4_1,cModeSF4_2,cModeSF4_3,cModeSD1_1,cModeSD1_2,cModeSD1_3,cModeSD3_1,cModeSD3_2,cModeSD3_3)
Local cQuery    := ''
Local cAliasTRB := GetNextAlias()
Local lRemInt   := SuperGetMv("MV_REMINT",.F.,.F.)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Processa entradas por NF conforme regras existentes na CalcEst ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cQuery := "SELECT "
cQuery += IIf(nTipo==1,cSubstr+"(SD1.D1_DTDIGIT,1,6) AS PERIODO,","SD1.D1_DTDIGIT AS PERIODO,")
cQuery +=           "SUM(SD1.D1_QUANT)  AS QUANT , SUM(SD1.D1_CUSTO)  AS CUSTO1, "
cQuery +=           "SUM(SD1.D1_CUSTO2) AS CUSTO2, SUM(SD1.D1_CUSTO3) AS CUSTO3, "
cQuery +=           "SUM(SD1.D1_CUSTO4) AS CUSTO4, SUM(SD1.D1_CUSTO5) AS CUSTO5, "
cQuery +=           "CASE SD1.D1_TIPO WHEN 'D' THEN SUM(SD1.D1_QUANT) ELSE 0 END AS QTDEDEV, "
cQuery +=           "CASE SD1.D1_TIPO WHEN 'D' THEN SUM(SD1.D1_CUSTO) ELSE 0 END AS CUSTDEV "
cQuery +=   "FROM " + cNameSD1 +" SD1 "
cQuery +=   "JOIN " + cNameSF4 +" SF4 ON "
If !Empty(cFiltraFil)
	If cModeSF4_3 == "E"
		cQuery += "SF4.F4_FILIAL = '" + cFiltraFil + "' AND "
	ElseIf cModeSF4_2 == "E"
		cQuery += "SF4.F4_FILIAL = '" + PadR(Substr(cFiltraFil,1,Len(cLayout1) +Len(cLayout2)),cSizeFilial)  + "' AND "
	ElseIf cModeSF4_1 == "E"
		cQuery += "SF4.F4_FILIAL = '" + PadR(Substr(cFiltraFil,1,Len(cLayout1)),cSizeFilial) + "' AND "
	Else
		cQuery += "SF4.F4_FILIAL = '" + Space(cSizeFilial) + "' AND "
	EndIf
EndIf
cQuery +=             "SF4.F4_CODIGO = SD1.D1_TES "
cQuery +=         "AND SF4.F4_ESTOQUE = 'S' "
cQuery +=         "AND SF4.D_E_L_E_T_ = ' ' "
cQuery += "WHERE "
If !Empty(cFiltraFil)
	If cModeSD1_3 == "E"
		cQuery += "SD1.D1_FILIAL = '" +cFiltraFil + "' AND "
	ElseIf cModeSD1_2 == "E"
		cQuery += "SD1.D1_FILIAL = '" +PadR(Substr(cFiltraFil,1,Len(cLayout1)+Len(cLayout2)),cSizeFilial)  + "' AND "
	ElseIf cModeSD1_1 == "E"
		cQuery += "SD1.D1_FILIAL = '" +PadR(Substr(cFiltraFil,1,Len(cLayout1)),cSizeFilial) + "' AND "
	Else
		cQuery += "SD1.D1_FILIAL = '" +Space(cSizeFilial) + "' AND "
	EndIf
EndIf
cQuery +=              "SD1.D1_COD   = '" + BIXVldCondition( cProduto ) + "' "
cQuery +=          "AND SD1.D1_LOCAL = '" + BIXVldCondition( cLocal )     + "' "
cQuery +=          "AND SD1.D1_DTDIGIT BETWEEN '"      + DToS(dDataIni) +"' AND '" + DToS(dDataFim) +"' "
cQuery +=          "AND SD1.D1_ORIGLAN <> 'LF' "
cQuery +=          "AND SD1.D_E_L_E_T_ = ' ' "
If cPaisLoc != "BRA"
	//-- Desconsiderar notas de remito e notas geradas pelo EIC com excecao da nota de FOB.		
	cQuery +=      "AND SD1.D1_REMITO = ' ' AND SD1.D1_TIPO_NF NOT IN ('6','7','8','9','A','B'"
	If lRemInt
		//-- Desconsiderar notas de entrada tipo 10 quando o cliente utilizar o 
		//-- conceito de remito interno com importacao (SIGAEIC) 
		cQuery +=       ",'5') AND SD1.D1_CONHEC = ' ' AND SD1.D1_TIPODOC <> '10' "
	Else
		cQuery +=       ") "
	EndIf
EndIf
If nTipo == 1
	cQuery += "GROUP BY "+ cSubstr + "(SD1.D1_DTDIGIT,1,6), SD1.D1_TIPO "
Else
	cQuery += "GROUP BY SD1.D1_DTDIGIT, SD1.D1_TIPO "
EndIf

cQuery += "UNION "

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Processa entradas por movimentos internos conforme regras existentes na CalcEst	ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cQuery += "SELECT "
cQuery += IIf(nTipo==1,cSubstr + "(SD3.D3_EMISSAO,1,6) AS PERIODO,","SD3.D3_EMISSAO AS PERIODO,")
cQuery +=          "SUM(SD3.D3_QUANT)  AS QUANT , SUM(SD3.D3_CUSTO1) AS CUSTO1, "
cQuery +=          "SUM(SD3.D3_CUSTO2) AS CUSTO2, SUM(SD3.D3_CUSTO3) AS CUSTO3, "
cQuery +=          "SUM(SD3.D3_CUSTO4) AS CUSTO4, SUM(SD3.D3_CUSTO5) AS CUSTO5, "
cQuery +=          "0 AS QTDEDEV, 0 AS CUSTDEV "
cQuery +=    "FROM " +cNameSD3 +" SD3 "
cQuery +=  "WHERE "
If !Empty(cFiltraFil)
	If cModeSD3_3 == "E"
		cQuery += "SD3.D3_FILIAL = '" +cFiltraFil +"' AND "
	ElseIf cModeSD3_2 == "E"
		cQuery += "SD3.D3_FILIAL = '" +PadR(Substr(cFiltraFil,1,Len(cLayout1)+Len(cLayout2)),cSizeFilial)  +"' AND "
	ElseIf cModeSD3_1 == "E"
		cQuery += "SD3.D3_FILIAL = '" +PadR(Substr(cFiltraFil,1,Len(cLayout1)),cSizeFilial) +"' AND "
	Else
		cQuery += "SD3.D3_FILIAL = '" +Space(cSizeFilial) +"' AND "
	EndIf
EndIf
cQuery +=             "SD3.D3_COD   = '" + BIXVldCondition( cProduto ) + "' "
cQuery +=         "AND SD3.D3_LOCAL = '" + BIXVldCondition( cLocal ) + "' "
cQuery +=         "AND SD3.D3_EMISSAO BETWEEN '"      + DToS(dDataIni) +"' AND '" +DToS(dDataFim) + "' "
cQuery +=         "AND SD3.D3_ESTORNO <> 'S' "
cQuery +=         "AND SD3.D3_TM < '500' "
cQuery +=         "AND SD3.D_E_L_E_T_ = ' ' "
If nTipo == 1
	cQuery += "GROUP BY " + cSubstr + "(SD3.D3_EMISSAO,1,6) "
Else
	cQuery += "GROUP BY SD3.D3_EMISSAO "
EndIf
cQuery += "ORDER BY PERIODO"

dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasTRB,.F.,.T.)

TCSetField(cAliasTRB,"QUANT" ,"N",aQTamSX3[1],aQTamSX3[2])
TCSetField(cAliasTRB,"CUSTO1","N",aVTamSX3[1],aVTamSX3[2])
TCSetField(cAliasTRB,"CUSTO2","N",aVTamSX3[1],aVTamSX3[2])
TCSetField(cAliasTRB,"CUSTO3","N",aVTamSX3[1],aVTamSX3[2])
TCSetField(cAliasTRB,"CUSTO4","N",aVTamSX3[1],aVTamSX3[2])
TCSetField(cAliasTRB,"CUSTO5","N",aVTamSX3[1],aVTamSX3[2])

Return cAliasTRB

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ Saidas   บAutor  ณ Andre Anjos        บ Data ณ  05/11/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao que alimenta o array recebido como parametro com    บฑฑ
ฑฑบ          ณ os dados das saidas do dia.                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ dDataIni: data inicio para busca dos dados.				  บฑฑ
ฑฑบ			 ณ dDataFim: data fim para busca dos dados.					  บฑฑ
ฑฑบ			 ณ dDataRef: data inicio para acumular as saidas			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ IndicEST                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Saidas(nTipo,dDataIni,dDataFim,dDataRef,cFiltraFil,cProduto,cLocal,cSubstr,cSizeFilial,cLayout1,cLayout2,cNameSD2,cNameSD3,cNameSF4,aQTamSX3,aVTamSX3,cModeSF4_1,cModeSF4_2,cModeSF4_3,cModeSD2_1,cModeSD2_2,cModeSD2_3,cModeSD3_1,cModeSD3_2,cModeSD3_3)
Local cQuery    := ''
Local cFilSD2	:= ''
Local cFilSD3	:= ''
Local cFilSF4	:= ''
Local cAliasTRB := GetNextAlias()

Default dDataRef := dDataIni

If !Empty(cFiltraFil)
	//-- Resolve filial da SD2
	If 	cModeSD2_3 == "E"
		cFilSD2 := cFiltraFil
	ElseIf 	cModeSD2_2 == "E"
		cFilSD2 := PadR(Substr(cFiltraFil,1,Len(cLayout1) +Len(cLayout2)),cSizeFilial)
	ElseIf 	cModeSD2_1 == "E"
		cFilSD2 := PadR(Substr(cFiltraFil,1,Len(cLayout1)),cSizeFilial)
	Else
		cFilSD2 := Space(cSizeFilial)
	EndIf
	
	//-- Resolve filial da SD3
	If cModeSD3_3 == "E"
		cFilSD3 := cFiltraFil
	ElseIf cModeSD3_2 == "E"
		cFilSD3 := PadR(Substr(cFiltraFil,1,Len(cLayout1) +Len(cLayout2)),cSizeFilial)
	ElseIf cModeSD3_1 == "E"
		cFilSD3 := PadR(Substr(cFiltraFil,1,Len(cLayout1)),cSizeFilial)
	Else
		cFilSD3 := Space(cSizeFilial)
	EndIf
	
	If cModeSF4_3 == "E"
		cFilSF4 := cFiltraFil
	ElseIf cModeSF4_2 == "E"
		cFilSF4 := PadR(Substr(cFiltraFil,1,Len(cLayout1) +Len(cLayout2)),cSizeFilial)
	ElseIf cModeSF4_1 == "E"
		cFilSF4 := PadR(Substr(cFiltraFil,1,Len(cLayout1)),cSizeFilial)
	Else
		cFilSF4 := Space(cSizeFilial)
	EndIf
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Processa saidas por NF conforme regras existentes na CalcEst ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cQuery := "SELECT "
If nTipo == 1
	cQuery += cSubstr + "(SD2.D2_EMISSAO,1,6) AS PERIODO, "
Else
	cQuery += "SD2.D2_EMISSAO AS PERIODO, "
EndIf
cQuery +=     "SUM(SD2.D2_QUANT)  AS QUANT , SUM(SD2.D2_CUSTO1) AS CUSTO1, "
cQuery +=     "SUM(SD2.D2_CUSTO2) AS CUSTO2, SUM(SD2.D2_CUSTO3) AS CUSTO3, "
cQuery +=     "SUM(SD2.D2_CUSTO4) AS CUSTO4, SUM(SD2.D2_CUSTO5) AS CUSTO5, "

//-- Subquery para saidas acumuladas ate a data
cQuery += "( SELECT SUM(SD2TMP.D2_QUANT) "
cQuery +=     "FROM " + cNameSD2 +" SD2TMP "
cQuery +=     "JOIN " + cNameSF4 +" SF4TMP ON "
If !Empty(cFiltraFil)
	cQuery +=         "SF4TMP.F4_FILIAL = '" +cFilSF4 +"' AND "
EndIf
cQuery +=             "SF4TMP.F4_CODIGO  = SD2TMP.D2_TES "
cQuery +=         "AND SF4TMP.F4_ESTOQUE = 'S' "
cQuery +=         "AND SF4TMP.D_E_L_E_T_ = ' ' "

cQuery +=     "WHERE "

If !Empty(cFiltraFil)
	cQuery +=         "SD2TMP.D2_FILIAL = '" + cFilSD2 +"' AND "
EndIf
cQuery +=             "SD2TMP.D2_COD = '" + BIXVldCondition( cProduto )  + "' "
cQuery +=         "AND SD2TMP.D2_LOCAL = '"    + BIXVldCondition( cLocal ) + "' "
cQuery +=         "AND SD2TMP.D2_EMISSAO >= '" + DToS(dDataRef) + "' "
If nTipo == 1
	cQuery +=     "AND " + cSubstr + "(SD2TMP.D2_EMISSAO,1,6) < " +  cSubstr + "(SD2.D2_EMISSAO,1,6) "
Else
	cQuery +=     "AND SD2TMP.D2_EMISSAO < SD2.D2_EMISSAO "
EndIf
cQuery +=         "AND SD2TMP.D_E_L_E_T_ = ' ' "
cQuery +=         "AND SD2TMP.D2_ORIGLAN <> 'LF' "
cQuery +=         "AND (SD2TMP.D2_REMITO = ' ' OR SD2TMP.D2_TPDCENV IN ('A','1')) ) AS SAIDAACUM, "

cQuery +=     "CASE SD2.D2_TIPO WHEN 'D' THEN SUM(SD2.D2_QUANT)  ELSE 0 END AS QTDEDEV, "

cQuery +=     "CASE SD2.D2_TIPO WHEN 'D' THEN SUM(SD2.D2_CUSTO1) ELSE 0 END AS CUSTDEV "

cQuery += "FROM " + cNameSD2 +" SD2 "
cQuery += "JOIN " + cNameSF4 +" SF4 ON "
cQuery +=             "SF4.F4_FILIAL = " +If(Empty(xFilial("SF4")),"'" +xFilial("SF4") +"' ","SD2.D2_FILIAL ")
cQuery +=         "AND SF4.F4_CODIGO = SD2.D2_TES "
cQuery +=         "AND SF4.F4_ESTOQUE = 'S' "
cQuery +=         "AND SF4.D_E_L_E_T_ = ' ' "

cQuery += "WHERE "

If !Empty(cFiltraFil)
	cQuery +=         "SD2.D2_FILIAL = '" +cFilSD2 +"' AND "
EndIf
cQuery +=             "SD2.D2_COD = '" + BIXVldCondition( cProduto ) + "' "
cQuery +=         "AND SD2.D2_LOCAL = '" + BIXVldCondition( cLocal ) + "' "
cQuery +=         "AND SD2.D2_EMISSAO BETWEEN '" + DToS(dDataIni) +"' AND '" +DToS(dDataFim) +"' "
cQuery +=         "AND SD2.D_E_L_E_T_ = ' ' "
cQuery +=         "AND SD2.D2_ORIGLAN <> 'LF' "
cQuery +=         "AND (SD2.D2_REMITO = ' ' OR SD2.D2_TPDCENV IN ('A','1')) "
If nTipo == 1
	cQuery += "GROUP BY " + cSubstr + "(SD2.D2_EMISSAO,1,6), SD2.D2_TIPO "
Else
	cQuery += "GROUP BY SD2.D2_EMISSAO, SD2.D2_TIPO "
EndIf

cQuery += "UNION "

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Processa saidas por movimentos internos conforme regras existentes na CalcEst	ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cQuery += "SELECT "
If nTipo == 1
	cQuery += cSubstr + "(SD3.D3_EMISSAO,1,6) AS PERIODO, "
Else
	cQuery +=     "SD3.D3_EMISSAO AS PERIODO, "
EndIf
cQuery +=         "SUM(SD3.D3_QUANT)  AS QUANT , SUM(SD3.D3_CUSTO1) AS CUSTO1, "
cQuery +=         "SUM(SD3.D3_CUSTO2) AS CUSTO2, SUM(SD3.D3_CUSTO3) AS CUSTO3, "
cQuery +=         "SUM(SD3.D3_CUSTO4) AS CUSTO4, SUM(SD3.D3_CUSTO5) AS CUSTO5, "

//-- Subquery para saidas acumuladas ate a data
cQuery += "(SELECT SUM(SD3TMP.D3_QUANT) FROM " + cNameSD3 +" SD3TMP "

cQuery += "WHERE "

If !Empty(cFiltraFil)
	cQuery +=     "SD3TMP.D3_FILIAL = '"   + cFilSD3 +"' AND "
EndIf
cQuery +=         "SD3TMP.D3_COD = '" + BIXVldCondition( cProduto ) + "' "
cQuery +=     "AND SD3TMP.D3_LOCAL = '" + BIXVldCondition( cLocal ) + "' "
cQuery +=     "AND SD3TMP.D3_EMISSAO >= '"+ DToS(dDataRef) + "' "
If nTipo == 1
	cQuery += "AND " + cSubstr + "(SD3TMP.D3_EMISSAO,1,6) < " + cSubstr + "(SD3.D3_EMISSAO,1,6) "
Else
	cQuery += "AND SD3TMP.D3_EMISSAO < SD3.D3_EMISSAO "
EndIf
cQuery +=     "AND SD3TMP.D_E_L_E_T_ = ' ' "
cQuery +=     "AND SD3TMP.D3_ESTORNO <> 'S' "
cQuery +=     "AND SD3TMP.D3_TM > '500' ) AS SAIDAACUM, "
cQuery +=   "0 AS QTDEDEV, 0 AS CUSTDEV "

cQuery += "FROM " + cNameSD3 +" SD3 "

cQuery += "WHERE "

If !Empty(cFiltraFil)
	cQuery += "SD3.D3_FILIAL = '" +cFilSD3 +"' AND "
EndIf
cQuery +=     "SD3.D3_COD = '" + BIXVldCondition( cProduto ) + "' "
cQuery += "AND SD3.D3_LOCAL = '" + BIXVldCondition( cLocal ) + "' "
cQuery += "AND SD3.D3_EMISSAO BETWEEN '"      + DToS(dDataIni) +"' AND '" +DToS(dDataFim) +"' "
cQuery += "AND SD3.D3_ESTORNO <> 'S' "
cQuery += "AND SD3.D3_TM > '500' "
cQuery += "AND SD3.D_E_L_E_T_ = ' ' "

If nTipo == 1
	cQuery += "GROUP BY " + cSubstr + "(SD3.D3_EMISSAO,1,6) "
Else
	cQuery += "GROUP BY SD3.D3_EMISSAO "
EndIf

cQuery += "ORDER BY PERIODO"

dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasTRB,.F.,.T.)

TCSetField(cAliasTRB,"QUANT"	,"N",aQTamSX3[1],aQTamSX3[2])
TCSetField(cAliasTRB,"CUSTO1"	,"N",aVTamSX3[1],aVTamSX3[2])
TCSetField(cAliasTRB,"CUSTO2"	,"N",aVTamSX3[1],aVTamSX3[2])
TCSetField(cAliasTRB,"CUSTO3"	,"N",aVTamSX3[1],aVTamSX3[2])
TCSetField(cAliasTRB,"CUSTO4"	,"N",aVTamSX3[1],aVTamSX3[2])
TCSetField(cAliasTRB,"CUSTO5"	,"N",aVTamSX3[1],aVTamSX3[2])
TCSetField(cAliasTRB,"SAIDAACUM","N",aQTamSX3[1],aQTamSX3[2])

Return cAliasTRB

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEntradasP บAutor  ณ Andre Anjos		 บ Data ณ  06/11/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Retorna o saldo de entradas previstas no mes.		      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cFiltraFil: codigo da filial.							  บฑฑ
ฑฑบ			 ณ dDataFim: ultimo dia do mes a ser considerado.			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno	 ณ nRet: quantidade de entrada prevista para o mes.			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ KPIEST													  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function EntradasP(cFiltraFil,dDataFim,cSizeFilial,cProduto,cLocal,aSTamSX3,cLayout1,cLayout2,cNameSC1,cNameSC2,cNameSC7,cModeSC1_1,cModeSC1_2,cModeSC1_3,cModeSC2_1,cModeSC2_2,cModeSC2_3,cModeSC7_1,cModeSC7_2,cModeSC7_3)
Local nRet     := 0
Local cQuery   := ""
Local cDataIni := Substr(DToS(dDataFim),1,6) + "01"
Local aArea	 	:= GetArea()

cQuery := "SELECT SUM(SALPEDI) SALPEDI FROM "
//-- Solicitacoes de compra em carteira
cQuery += "( SELECT SUM(SC1.C1_QUANT - SC1.C1_QUJE) SALPEDI "
cQuery +=     "FROM " +cNameSC1 + " SC1 "
cQuery +=    "WHERE "
If !Empty(cFiltraFil)
	If cModeSC1_3 == "E"
		cQuery += "SC1.C1_FILIAL = '" + cFiltraFil +"' AND "
	ElseIf cModeSC1_2 == "E"
		cQuery += "SC1.C1_FILIAL = '" + PadR(Substr(cFiltraFil,1,Len(cLayout1) +Len(cLayout2)),cSizeFilial)  +"' AND "
	ElseIf cModeSC1_1 == "E"
		cQuery += "SC1.C1_FILIAL = '" + PadR(Substr(cFiltraFil,1,Len(cLayout1)),cSizeFilial) +"' AND "
	Else
		cQuery += "SC1.C1_FILIAL = '" +Space(cSizeFilial) +"' AND "
	EndIf
EndIf
cQuery +=    " SC1.C1_PRODUTO = '" + BIXVldCondition( cProduto ) + "' "
cQuery += "AND SC1.C1_LOCAL = '" + BIXVldCondition( cLocal ) 	+ "' "
cQuery += "AND SC1.C1_DATPRF BETWEEN '"	+ cDataIni 		+ "' AND '" +DToS(dDataFim) +"' "
cQuery += "AND SC1.C1_RESIDUO <> 'S' "
cQuery += "AND SC1.D_E_L_E_T_ = ' ' "

cQuery += "UNION "

//-- Pedidos de compra em carteira
cQuery += "SELECT SUM(SC7.C7_QUANT - SC7.C7_QUJE) SALPEDI "
cQuery +=   "FROM " + cNameSC7 +" SC7 "
cQuery +=  "WHERE "
If !Empty(cFiltraFil)
	If cModeSC7_3 == "E"
		cQuery += "SC7.C7_FILIAL = '" +cFiltraFil +"' AND "
	ElseIf cModeSC7_2 == "E"
		cQuery += "SC7.C7_FILIAL = '" +PadR(Substr(cFiltraFil,1,Len(cLayout1)+Len(cLayout2)),cSizeFilial) + "' AND "
	ElseIf cModeSC7_1 == "E"
		cQuery += "SC7.C7_FILIAL = '" +PadR(Substr(cFiltraFil,1,Len(cLayout1)),cSizeFilial) + "' AND "
	Else
		cQuery += "SC7.C7_FILIAL = '" +Space(cSizeFilial) +"' AND "
	EndIf
EndIf
cQuery +=    " SC7.C7_PRODUTO = '" + BIXVldCondition( cProduto ) + "' "
cQuery += "AND SC7.C7_LOCAL = '" + BIXVldCondition( cLocal ) + "' "
cQuery += "AND SC7.C7_DATPRF BETWEEN '" + cDataIni      + "' AND '" +DToS(dDataFim) +"' "
cQuery += "AND SC7.C7_RESIDUO <> 'S' "
cQuery += "AND SC7.D_E_L_E_T_ = ' ' "

cQuery += "UNION "

//-- Ordens de producao em carteira
cQuery += "SELECT SUM(SC2.C2_QUANT - SC2.C2_QUJE) SALPEDI "
cQuery +=   "FROM " +cNameSC2 +" SC2 "
cQuery +=  "WHERE "
If !Empty(cFiltraFil)
	If cModeSC2_3 == "E"
		cQuery += "SC2.C2_FILIAL = '" + cFiltraFil +"' AND "
	ElseIf cModeSC2_2 == "E"
		cQuery += "SC2.C2_FILIAL = '" + PadR(Substr(cFiltraFil,1,Len(cLayout1) +Len(cLayout2)),cSizeFilial)  +"' AND "
	ElseIf cModeSC2_1 == "E"
		cQuery += "SC2.C2_FILIAL = '" + PadR(Substr(cFiltraFil,1,Len(cLayout1)),cSizeFilial) +"' AND "
	Else
		cQuery += "SC2.C2_FILIAL = '" + Space(cSizeFilial) +"' AND "
	EndIf
EndIf
cQuery +=    " SC2.C2_PRODUTO = '" + BIXVldCondition( cProduto ) + "' "
cQuery += "AND SC2.C2_LOCAL = '" + BIXVldCondition( cLocal ) + "' "
cQuery += "AND SC2.C2_DATPRF BETWEEN '"	+ cDataIni      + "' AND '" +DToS(dDataFim) +"' "
cQuery += "AND SC2.C2_DATRF = '" 		+ Space(8)      + "' "
cQuery += "AND SC2.D_E_L_E_T_ = ' ' ) SALPEDI "

dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),"SALPEDI",.F.,.T.)

TCSetField("SALPEDI","SALPEDI","N",aSTamSX3[1],aSTamSX3[2])

nRet := SALPEDI->SALPEDI

SALPEDI->(dbCloseArea())

RestArea(aArea)

Return nRet