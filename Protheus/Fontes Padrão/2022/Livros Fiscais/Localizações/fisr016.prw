#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "FISR016.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funci¢n ³ FISR016 ³ Autor ³ Felipe C. Seolin    ³ Data ³ 23/08/2010 ³   ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrip.³ Gera Relatório de Vendas para Venezuela                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso     ³ SIGAFIS                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³gSantacruz³DMINA-2452³Cambios realizados por Cesar Butista:Se habilita ³±±
±±³          ³          ³la funcionalidad para la generación de archivo   ³±±
±±³          ³          ³ Excel con los movimientos del reporte .         ³±±
±±³gSantacruz³DMINA-3190³Etiquetas comentadas. Agrupacion de registros por³±±
±±³          ³          ³codigo fiscal proveedor y factura.               ³±±
±±³          ³          ³Solo considera que hay un solo % de iva.         ³±±
±±³          ³          ³Se agrego columna de Gpo Tributario. a2_grptrib   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FISR016()
	Local clTitulo	:= STR0001//"Informe de Libro de Ventas Venezuela"
	Private opPrn	:= Nil
	Private aExcel := {}
	Private dFecIni	:=ctod("  /  /  ")
	Private dFecFin	:=ctod("  /  /  ")

	If Pergunte("FISR016",.T.)
		dFecIni	:=MV_PAR01 //Fecha inicial basada en los movimientos de la tabla SF3
		dFecFin	:=MV_PAR02 //Fecha final basada en los movimientos de la tabla SF3
		nImpPag :=MV_PAR03 //Validara si será impresa el número de página en el encabezado del reporte.
		nPagIni :=MV_PAR04 //Si el parámetro anterior esta con opción “SI” tomara el valor informado como el número de página inicial para el informe.
		cRuta   :=MV_PAR05 //Se debe informar el Root donde será grabado el archivo Excel generado por la rutina.
		If SubStr(dtos(dFecFin),1,6) == SubStr(dtos(dFecIni),1,6)
			opPrn := TmsPrinter():New(clTitulo)
			opPrn:SetPaperSize(12)
			opPrn:SetLandscape()
			opPrn:StartPage()
			FRELC()
			opPrn:EndPage()
			opPrn:Preview()
			opPrn:End()
			
			GenExcel(aExcel)
			
		Else
			MsgAlert(STR0002)
		EndIf
	EndIf
Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion   ³ FRELC ³ Autor  ³Felipe C. Seolin      ³ Data ³ 23/08/10   ³ ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrip.  ³ Cria estrutura do relatório de vendas.                      ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FISR016                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FRELC()
	Local olFont2	:= TFont():New("Perpetua",,8,,.T.,,,,,.F.)
	Local olFont3	:= TFont():New("Perpetua",,8,,.F.,,,,,.F.)
	Local clQuery	:= ""
	Local clLvroImp	:= clLvroRet := ""
	Local clNota	:= clSerie := clCli := clLoja := clEspec := ""
	Local nlBasZero	:= 0
	Local nlBasEX	:= nlIVAEX := nlRetEX := 0
	Local nlBasGen	:= nlIVAGen := nlRetGen := nlBasAdi := nlIVAAdi := nlRetAdi := nlBasRed := nlIVARed := nlRetRed := 0
	Local nlTotBas	:= nlTotIVA := nlTotRet := 0
	Local nlValCont	:= nlAliq0 := nlBasImp := nlAlqImp := nlValImp := nlValRet := 0
	Local nlContFol	:= nlAlqFol := nlBasFol := nlIVAFol := nlRetFol := 0
	Local nlI		:= 0
	Local nlPos		:= 0
	Local nlOper	:= 1
	Local nlLin		:= 675
	Local llFirst	:= .T.
	Local llFim		:= .F.
	Local alImp		:= {}
	Local alVal		:= {}
	Local alDados	:= Array(1,14)

	clQuery := "SELECT	SF3.* "
	clQuery += "	,A1_CGC "
	clQuery += "	,A1_NOME "
	clQuery += "	,A1_EST "
	clQuery += "	,A1_GRPTRIB "
	clQuery += "FROM " + RetSqlName("SF3") + " SF3 "

	clQuery += "INNER JOIN " + RetSqlName("SA1") + " SA1 "
	clQuery += "ON	A1_FILIAL = '" + xFilial("SA1") + "' "
	clQuery += "AND	SA1.D_E_L_E_T_ = '' "
	clQuery += "AND	A1_COD = F3_CLIEFOR "
	clQuery += "AND	A1_LOJA = F3_LOJA "
	
	clQuery += "WHERE	F3_FILIAL = '" + xFilial("SF3") + "' "
	clQuery += "AND	SF3.D_E_L_E_T_ = '' "
	clQuery += "AND	F3_TIPOMOV = 'V' "
	clQuery += "AND	F3_EMISSAO BETWEEN '" + dtos(dFecIni) + "' AND '" + dtos(dFecFin) + "' "

	clQuery += "ORDER BY	F3_NFISCAL "
	clQuery += "		,F3_SERIE "
	clQuery += "		,F3_CLIEFOR "
	clQuery += "		,F3_LOJA "
	clQuery += "		,F3_ESPECIE "

	TcQuery clQuery New Alias "LIVRO"
	TcSetField("LIVRO","D","LIVRO->F3_EMISSAO")

	If LIVRO->(EOF())
		FCABLVC(.T.)
		nlLin += 50
		opPrn:Say(nlLin,0055,STR0003,olFont3)//"Sin Movim. "
		llFim := .T.
	EndIf
	While LIVRO->(!EOF())
		alDados[1][1] := StrZero(nlOper,5)
		alDados[1][2] := SubStr(LIVRO->F3_EMISSAO,7,2) + "/" + SubStr(LIVRO->F3_EMISSAO,5,2) + "/" + SubStr(LIVRO->F3_EMISSAO,1,4)
		alDados[1][3] := LIVRO->A1_CGC
		alDados[1][4] := SubStr(LIVRO->A1_NOME,1,23)
		alDados[1][5] := ""
		If AllTrim(LIVRO->F3_ESPECIE) $ "NDE/NDC"
			alDados[1][6] := ""
			If AllTrim(LIVRO->F3_ESPECIE) $ "NDC"
				alDados[1][7] := GetSFP(LIVRO->F3_FILIAL,LIVRO->F3_SERIE,LIVRO->F3_NFISCAL,LIVRO->F3_ESPECIE)
			Else
				alDados[1][7] := Posicione("SF1",1,xFilial("SF1") + LIVRO->F3_NFISCAL + LIVRO->F3_SERIE + LIVRO->F3_CLIEFOR + LIVRO->F3_LOJA,"F1_FORMLIB")
			EndIf
			alDados[1][8] := LIVRO->F3_NFISCAL
			alDados[1][9] := ""
		ElseIf AllTrim(LIVRO->F3_ESPECIE) $ "NCE/NCC"
			alDados[1][6] := ""
			If AllTrim(LIVRO->F3_ESPECIE) $ "NCC"
				alDados[1][7] := GetSFP(LIVRO->F3_FILIAL,LIVRO->F3_SERIE,LIVRO->F3_NFISCAL,LIVRO->F3_ESPECIE)
			Else
				alDados[1][7] := Posicione("SF2",2,xFilial("SF2") + LIVRO->F3_CLIEFOR + LIVRO->F3_LOJA + LIVRO->F3_NFISCAL + LIVRO->F3_SERIE,"F2_FORMLIB")
			EndIf
			alDados[1][8] := ""
			alDados[1][9] := LIVRO->F3_NFISCAL
		Else	
			alDados[1][6] := LIVRO->F3_NFISCAL
			alDados[1][7] :=  Posicione("SF2",2,xFilial("SF2") + LIVRO->F3_CLIEFOR + LIVRO->F3_LOJA + LIVRO->F3_NFISCAL + LIVRO->F3_SERIE,"F2_FORMLIB")//GetSFP(LIVRO->F3_FILIAL,LIVRO->F3_SERIE,LIVRO->F3_NFISCAL,LIVRO->F3_ESPECIE)
			alDados[1][8] := ""
			alDados[1][9] := ""
		EndIf
		If AllTrim(LIVRO->F3_ESPECIE) == "NF"
			alDados[1][10] := "01"
		ElseIf AllTrim(LIVRO->F3_ESPECIE) $ "NCC/NCE/NDC/NDE"
			alDados[1][10] := "02"
		ElseIf !Empty(LIVRO->F3_DTCANC)
			alDados[1][10] := "03"
		Else
			alDados[1][10] := "04"
		EndIf
		If AllTrim(LIVRO->F3_ESPECIE) $ "NDE/NCC"
			alDados[1][11] := Posicione("SD1",1,xFilial("SD1") + LIVRO->F3_NFISCAL + LIVRO->F3_SERIE + LIVRO->F3_CLIEFOR + LIVRO->F3_LOJA,"D1_NFORI")
		ElseIf AllTrim(LIVRO->F3_ESPECIE) $ "NCE/NDC"
			alDados[1][11] := Posicione("SD2",3,xFilial("SD2") + LIVRO->F3_NFISCAL + LIVRO->F3_SERIE + LIVRO->F3_CLIEFOR + LIVRO->F3_LOJA,"D2_NFORI")
		Else
			alDados[1][11] := ""
		EndIf
		alDados[1][12] := ""
		If AllTrim(LIVRO->F3_TIPOMOV) == "V"
			alDados[1][13] := Posicione("SFE",8,xFilial("SFE") + LIVRO->F3_CLIEFOR + LIVRO->F3_LOJA + LIVRO->F3_NFISCAL + LIVRO->F3_SERIE,"FE_NROCERT")
		ElseIf AllTrim(LIVRO->F3_TIPOMOV) == "C"
			alDados[1][13] := Posicione("SFE",4,xFilial("SFE") + LIVRO->F3_CLIEFOR + LIVRO->F3_LOJA + LIVRO->F3_NFISCAL + LIVRO->F3_SERIE,"FE_NROCERT")
		EndIf
		alDados[1][14] :=LIVRO->A1_GRPTRIB
		clNota	:= LIVRO->F3_NFISCAL
		clSerie	:= LIVRO->F3_SERIE
		clCli	:= LIVRO->F3_CLIEFOR
		clLoja	:= LIVRO->F3_LOJA
		clEspec	:= LIVRO->F3_ESPECIE
		
		While clNota == LIVRO->F3_NFISCAL .and. clSerie == LIVRO->F3_SERIE .and. clCli == LIVRO->F3_CLIEFOR .and. clLoja == LIVRO->F3_LOJA .and. clEspec == LIVRO->F3_ESPECIE
		
			alImp := TesImpInf(LIVRO->F3_TES)
			clLvroImp := ""
			For nlI := 1 to Len(alImp)
				If SubStr(alImp[nlI][1],1,2) == "IV"
					clLvroImp := Posicione("SFB",1,xFilial("SFB") + alImp[nlI][1],"FB_CPOLVRO")
					Exit
				EndIf
			Next nlI
			
			//Base de IVA Exento
			If  LIVRO->F3_EXENTAS <> 0 .and. Empty(clLvroImp)
				nlPos := aScan(alVal,{|x| x[4] == 0})
						If nlPos > 0
							If AllTrim(LIVRO->F3_ESPECIE) $ "NDP/NCI/NF"
										alVal[nlPos][2] += LIVRO->F3_EXENTAS
										alVal[nlPos][1] += LIVRO->F3_VALMERC
							else
										alVal[nlPos][2] -= LIVRO->F3_EXENTAS 
										alVal[nlPos][1] -= LIVRO->F3_VALMERC
							endif	
						Else
							If AllTrim(LIVRO->F3_ESPECIE) $ "NDP/NCI/NF"
										nlAliq0 := LIVRO->F3_EXENTAS
										nlValCont := LIVRO->F3_VALMERC
							else
										nlAliq0 := LIVRO->F3_EXENTAS  * (-1)
										nlValCont := LIVRO->F3_VALMERC * (-1)
							endif	
						EndIf
			EndIf
			
			If !Empty(clLvroImp) .and. Empty(LIVRO->F3_DTCANC)
				nlPos := aScan(alVal,{|x| x[4] == &("LIVRO->F3_ALQIMP" + clLvroImp)})
				
				If nlPos > 0
					If AllTrim(LIVRO->F3_ESPECIE) $ "NCE/NDC/NF"
						alVal[nlPos][1] += LIVRO->F3_VALMERC
					Else
						alVal[nlPos][1] -= LIVRO->F3_VALMERC
					EndIf
				Else
					If AllTrim(LIVRO->F3_ESPECIE) $ "NCE/NDC/NF"
						nlValCont := LIVRO->F3_VALMERC
					Else
						nlValCont := LIVRO->F3_VALMERC * (-1)
					EndIf
				EndIf
					
			
			//bases
			    If &("LIVRO->F3_BASIMP" + clLvroImp) > 0 .and. &("LIVRO->F3_ALQIMP" + clLvroImp) <> 0
					If nlPos > 0
						If AllTrim(LIVRO->F3_ESPECIE) $ "NCE/NDC/NF"
							alVal[nlPos][3] += &("LIVRO->F3_BASIMP" + clLvroImp)
						Else
							alVal[nlPos][3] -= &("LIVRO->F3_BASIMP" + clLvroImp)
						EndIf
					Else
						If AllTrim(LIVRO->F3_ESPECIE) $ "NCE/NDC/NF"
							nlBasImp := &("LIVRO->F3_BASIMP" + clLvroImp)
						Else
							nlBasImp := &("LIVRO->F3_BASIMP" + clLvroImp) * (-1)
						EndIf
					EndIf
				
				EndIf
			//Importe de impuestos	
				If nlPos > 0
					If AllTrim(LIVRO->F3_ESPECIE) $ "NCE/NDC/NF"
						alVal[nlPos][5] += &("LIVRO->F3_VALIMP" + clLvroImp)
					Else
						alVal[nlPos][5] -= &("LIVRO->F3_VALIMP" + clLvroImp)
					EndIf
				Else
					nlAlqImp := &("LIVRO->F3_ALQIMP" + clLvroImp)
					If AllTrim(LIVRO->F3_ESPECIE) $ "NCE/NDC/NF"
						nlValImp := &("LIVRO->F3_VALIMP" + clLvroImp)
					Else
						nlValImp := &("LIVRO->F3_VALIMP" + clLvroImp) * (-1)
					EndIf
				EndIf
				
				For nlI := 1 to Len(alImp)
					If SubStr(alImp[nlI][1],1,2) == "RV"
						clLvroRet := Posicione("SFB",1,xFilial("SFB") + alImp[nlI][1],"FB_CPOLVRO")
						Exit
					Else
						clLvroRet := ""
					EndIf
				Next nlI
				If !Empty(clLvroRet)
					If nlPos > 0
						If AllTrim(LIVRO->F3_ESPECIE) $ "NCE/NDC/NF"
							alVal[nlPos][6] += &("LIVRO->F3_VALIMP" + clLvroRet)
						Else
							alVal[nlPos][6] -= &("LIVRO->F3_VALIMP" + clLvroRet)
						EndIf
					Else
						If AllTrim(LIVRO->F3_ESPECIE) $ "NCE/NDC/NF"
							nlValRet := &("LIVRO->F3_VALIMP" + clLvroRet)
						Else
							nlValRet := &("LIVRO->F3_VALIMP" + clLvroRet) * (-1)
						EndIf
					EndIf
				Else
					nlValRet := 0
				EndIf
			/*Else
				nlValCont := LIVRO->F3_VALMERC
				nlAliq0 := nlBasImp := nlAlqImp := nlValImp := nlValRet := 0*/
			EndIf
			If nlPos <= 0
				Aadd(alVal,{nlValCont+nlValImp,nlAliq0,nlBasImp,nlAlqImp,nlValImp,nlValRet})
			EndIf
			
			nlAliq0 := nlBasImp := nlAlqImp := nlValImp := nlValRet := 0
			
			
			 if  LIVRO->F3_EXENTAS<> 0
			
				
					If AllTrim(LIVRO->F3_ESPECIE) $ "NCE/NDC/NF"
						If LIVRO->F3_EXENTAS <> 0
							nlBasZero += LIVRO->F3_EXENTAS
						EndIf
					Else
						If LIVRO->F3_EXENTAS <> 0
							nlBasZero += LIVRO->F3_EXENTAS * (-1)
						EndIf
					EndIf
			endif	
				
			If !Empty(clLvroImp)	
				If AllTrim(LIVRO->A1_EST) == "EX"
					If AllTrim(LIVRO->F3_ESPECIE) $ "NCE/NDC/NF"
						nlBasEX += &("LIVRO->F3_BASIMP" + clLvroImp)
						nlIVAEX += &("LIVRO->F3_VALIMP" + clLvroImp)
						nlRetEX += &("LIVRO->F3_VALIMP" + clLvroRet)
					Else
						nlBasEX -= &("LIVRO->F3_BASIMP" + clLvroImp)
						nlIVAEX -= &("LIVRO->F3_VALIMP" + clLvroImp)
						nlRetEX -= &("LIVRO->F3_VALIMP" + clLvroRet)
					EndIf
				EndIf
				If AllTrim(LIVRO->A1_EST) <> "EX" .and. &("LIVRO->F3_ALQIMP" + clLvroImp) == 12
					If AllTrim(LIVRO->F3_ESPECIE) $ "NCE/NDC/NF"
						nlBasGen += &("LIVRO->F3_BASIMP" + clLvroImp)
						nlIVAGen += &("LIVRO->F3_VALIMP" + clLvroImp)
						nlRetGen += &("LIVRO->F3_VALIMP" + clLvroRet)
					Else
						nlBasGen -= &("LIVRO->F3_BASIMP" + clLvroImp)
						nlIVAGen -= &("LIVRO->F3_VALIMP" + clLvroImp)
						nlRetGen -= &("LIVRO->F3_VALIMP" + clLvroRet)
					EndIf
				ElseIf AllTrim(LIVRO->A1_EST) <> "EX" .and. &("LIVRO->F3_ALQIMP" + clLvroImp) == 22
					If AllTrim(LIVRO->F3_ESPECIE) $ "NCE/NDC/NF"
						nlBasAdi += &("LIVRO->F3_BASIMP" + clLvroImp)
						nlIVAAdi += &("LIVRO->F3_VALIMP" + clLvroImp)
						nlRetAdi += &("LIVRO->F3_VALIMP" + clLvroRet)
					Else
						nlBasAdi -= &("LIVRO->F3_BASIMP" + clLvroImp)
						nlIVAAdi -= &("LIVRO->F3_VALIMP" + clLvroImp)
						nlRetAdi -= &("LIVRO->F3_VALIMP" + clLvroRet)
					EndIf
				ElseIf AllTrim(LIVRO->A1_EST) <> "EX" .and. &("LIVRO->F3_ALQIMP" + clLvroImp) == 8
					If AllTrim(LIVRO->F3_ESPECIE) $ "NCE/NDC/NF"
						nlBasRed += &("LIVRO->F3_BASIMP" + clLvroImp)
						nlIVARed += &("LIVRO->F3_VALIMP" + clLvroImp)
						nlRetRed += &("LIVRO->F3_VALIMP" + clLvroRet)
					Else
						nlBasRed -= &("LIVRO->F3_BASIMP" + clLvroImp)
						nlIVARed -= &("LIVRO->F3_VALIMP" + clLvroImp)
						nlRetRed -= &("LIVRO->F3_VALIMP" + clLvroRet)
					EndIf
				EndIf
			EndIf
			LIVRO->(DBSkip())
		EndDo
		
		//Agrupa en un solo registro todos los valores obtenidos del documento
		alVal:=ASORT(alVal, , , { | x,y | x[4] < y[4] } ) //Ordena por codigo de impuestso
		if Len(alVal)>1
		   alVal2:={}
			For nlI := 1 to Len(alVal)
			    if nlI==1
					Aadd(alVal2,{alVal[nlI,1],alVal[nlI,2],alVal[nlI,3],alVal[nlI,4],alVal[nlI,5],alVal[nlI,6]})
				else
					alVal2[1,1]+=alVal[nlI,1]
					alVal2[1,2]+=alVal[nlI,2]
					alVal2[1,3]+=alVal[nlI,3]
					alVal2[1,4]:=alVal[nlI,4] //tasa
					alVal2[1,5]+=alVal[nlI,5]
					alVal2[1,6]+=alVal[nlI,6]
				endif	
			next
			alVal:=aclone(alVal2)
		endif
		
		For nlI := 1 to Len(alVal)
			nlLin += 50
			If llFirst
				FCABLVC(.T.)
				llFirst := .F.
			EndIf
			If nlLin > 2350
				nlLin += 50
				opPrn:Say(nlLin,0080,STR0059,olFont2) 
				opPrn:Say(nlLin,2200,FAliDir(nlContFol,"@E 999,999,999.99"),olFont2)
				opPrn:Say(nlLin,2370,FAliDir(nlAlqFol,"@E 999,999,999.99"),olFont2)
				opPrn:Say(nlLin,2540,FAliDir(nlBasFol,"@E 999,999,999.99"),olFont2)
				opPrn:Say(nlLin,2800,FAliDir(nlIVAFol,"@E 999,999,999.99"),olFont2)
				opPrn:Say(nlLin,2970,FAliDir(nlRetFol,"@E 999,999,999.99"),olFont2)
				opPrn:EndPage()
				opPrn:StartPage()
				FCABLVC(.T.)
				nlLin := 725
				opPrn:Say(nlLin,0080,STR0060,olFont2) 
				opPrn:Say(nlLin,2200,FAliDir(nlContFol,"@E 999,999,999.99"),olFont2)
				opPrn:Say(nlLin,2370,FAliDir(nlAlqFol,"@E 999,999,999.99"),olFont2)
				opPrn:Say(nlLin,2540,FAliDir(nlBasFol,"@E 999,999,999.99"),olFont2)
				opPrn:Say(nlLin,2800,FAliDir(nlIVAFol,"@E 999,999,999.99"),olFont2)
				opPrn:Say(nlLin,2970,FAliDir(nlRetFol,"@E 999,999,999.99"),olFont2) 
				nlLin += 80
			EndIf
			If nlI > 1
				alDados[1][1] := StrZero(nlOper,5)
			EndIf
			opPrn:Say(nlLin,0080,alDados[1][1],olFont3)
			opPrn:Say(nlLin,0165,alDados[1][2],olFont3)
			opPrn:Say(nlLin,0315,alDados[1][3],olFont3)
			opPrn:Say(nlLin,0560,alDados[1][4],olFont3)
			opPrn:Say(nlLin,0910,alDados[1][5],olFont3)
			opPrn:Say(nlLin,1060,alDados[1][6],olFont3)
			opPrn:Say(nlLin,1260,alDados[1][7],olFont3)
			opPrn:Say(nlLin,1460,alDados[1][8],olFont3)
			opPrn:Say(nlLin,1660,alDados[1][9],olFont3)
			opPrn:Say(nlLin,1860,alDados[1][10],olFont3)
			opPrn:Say(nlLin,2010,alDados[1][11],olFont3)
			opPrn:Say(nlLin,2200,FAliDir(alVal[nlI][1],"@E 999,999,999.99"),olFont3)
			opPrn:Say(nlLin,2370,FAliDir(alVal[nlI][2],"@E 999,999,999.99"),olFont3)
			opPrn:Say(nlLin,2540,FAliDir(alVal[nlI][3],"@E 999,999,999.99"),olFont3)
			opPrn:Say(nlLin,2630,FAliDir(alVal[nlI][4],"@R 999.99"),olFont3)
			opPrn:Say(nlLin,2800,FAliDir(alVal[nlI][5],"@E 999,999,999.99"),olFont3)
			opPrn:Say(nlLin,2970,FAliDir(alVal[nlI][6],"@E 999,999,999.99"),olFont3)
			opPrn:Say(nlLin,3150,alDados[1][12],olFont3)
			opPrn:Say(nlLin,3280,alDados[1][13],olFont3)
			opPrn:Say(nlLin,3450,alDados[1][14],olFont3)
			nlContFol += alVal[nlI][1]
			nlAlqFol += alVal[nlI][2]
			nlBasFol += alVal[nlI][3]
			nlIVAFol += alVal[nlI][5]
			nlRetFol += alVal[nlI][6]
			nlOper ++
			If LIVRO->(EOF())
				nlLin += 50
				opPrn:Say(nlLin,2200,FAliDir(nlContFol,"@E 999,999,999.99"),olFont2)
				opPrn:Say(nlLin,2370,FAliDir(nlAlqFol,"@E 999,999,999.99"),olFont2)
				opPrn:Say(nlLin,2540,FAliDir(nlBasFol,"@E 999,999,999.99"),olFont2)
				opPrn:Say(nlLin,2800,FAliDir(nlIVAFol,"@E 999,999,999.99"),olFont2)
				opPrn:Say(nlLin,2970,FAliDir(nlRetFol,"@E 999,999,999.99"),olFont2)
			EndIf
			
		
		Aadd(aExcel,{ alDados[1][1],alDados[1][2],alDados[1][3],alDados[1][4],alDados[1][5],alDados[1][6],clSerie, ;
		alDados[1][7],alDados[1][8],alDados[1][9],alDados[1][10],alDados[1][11],;
		alVal[nlI][1], alVal[nlI][2], alVal[nlI][3], alVal[nlI][4], alVal[nlI][5], alVal[nlI][6],alDados[1][13],alDados[1][14]})
	
	
		Next nlI
		nlAliq0 := nlBasImp := nlAlqImp := nlValImp := nlValRet := 0
		alDados := Array(1,14)
		alVal	:= {}
	EndDo
	If !llFim
		nlTotBas := nlBasZero + nlBasEX + nlBasGen + nlBasAdi + nlBasRed
		nlTotIVA := nlIVAEX + nlIVAGen + nlIVAAdi + nlIVARed
		nlTotRet := nlRetEX + nlRetGen + nlRetAdi + nlRetRed
		nlLin += 150
		If nlLin > 2350
			opPrn:EndPage()
			opPrn:StartPage()
			FCABLVC(.F.)
			nlLin := 600
		EndIf
		opPrn:Say(nlLin,2140,STR0004,olFont2)
		opPrn:Say(nlLin,2460,STR0005,olFont2)
		opPrn:Say(nlLin,2760,STR0006,olFont2)
		nlLin += 50
		If nlLin > 2350
			opPrn:EndPage()
			opPrn:StartPage()
			FCABLVC(.F.)
			nlLin := 600
		EndIf
		opPrn:Say(nlLin,1000,STR0007,olFont2)
		opPrn:Say(nlLin,2140,FAliDir(nlBasZero,"@E 999,999,999.99"),olFont3)
		opPrn:Say(nlLin,2450,FAliDir(0,"@E 999,999,999.99"),olFont3)
		opPrn:Say(nlLin,2730,FAliDir(0,"@E 999,999,999.99"),olFont3)
		nlLin += 50
		If nlLin > 2350
			opPrn:EndPage()
			opPrn:StartPage()
			FCABLVC(.F.)
			nlLin := 600
		EndIf
		opPrn:Say(nlLin,1000,STR0008,olFont2)
		opPrn:Say(nlLin,2140,FAliDir(nlBasEX,"@E 999,999,999.99"),olFont3)
		opPrn:Say(nlLin,2450,FAliDir(nlIVAEX,"@E 999,999,999.99"),olFont3)
		opPrn:Say(nlLin,2730,FAliDir(nlRetEX,"@E 999,999,999.99"),olFont3)
		nlLin += 50
		If nlLin > 2350
			opPrn:EndPage()
			opPrn:StartPage()
			FCABLVC(.F.)
			nlLin := 600
		EndIf
		opPrn:Say(nlLin,1000,STR0009,olFont2)
		opPrn:Say(nlLin,2140,FAliDir(nlBasGen,"@E 999,999,999.99"),olFont3)
		opPrn:Say(nlLin,2450,FAliDir(nlIVAGen,"@E 999,999,999.99"),olFont3)
		opPrn:Say(nlLin,2730,FAliDir(nlRetGen,"@E 999,999,999.99"),olFont3)
		nlLin += 50
		If nlLin > 2350
			opPrn:EndPage()
			opPrn:StartPage()
			FCABLVC(.F.)
			nlLin := 600
		EndIf
		opPrn:Say(nlLin,1000,STR0010,olFont2)
		opPrn:Say(nlLin,2140,FAliDir(nlBasAdi,"@E 999,999,999.99"),olFont3)
		opPrn:Say(nlLin,2450,FAliDir(nlIVAAdi,"@E 999,999,999.99"),olFont3)
		opPrn:Say(nlLin,2730,FAliDir(nlRetAdi,"@E 999,999,999.99"),olFont3)
		nlLin += 50
		If nlLin > 2350
			opPrn:EndPage()
			opPrn:StartPage()
			FCABLVC(.F.)
			nlLin := 600
		EndIf
		opPrn:Say(nlLin,1000,STR0011,olFont2)
		opPrn:Say(nlLin,2140,FAliDir(nlBasRed,"@E 999,999,999.99"),olFont3)
		opPrn:Say(nlLin,2450,FAliDir(nlIVARed,"@E 999,999,999.99"),olFont3)
		opPrn:Say(nlLin,2730,FAliDir(nlRetRed,"@E 999,999,999.99"),olFont3)
		nlLin += 50
		If nlLin > 2350
			opPrn:EndPage()
			opPrn:StartPage()
			FCABLVC(.F.)
			nlLin := 600
		EndIf
		opPrn:Say(nlLin,2140,FAliDir(nlTotBas,"@E 999,999,999.99"),olFont2)
		opPrn:Say(nlLin,2450,FAliDir(nlTotIVA,"@E 999,999,999.99"),olFont2)
		opPrn:Say(nlLin,2730,FAliDir(nlTotRet,"@E 999,999,999.99"),olFont2)
	EndIf
	LIVRO->(DBCloseArea())
	
		Aadd(aExcel,{ "","","","","","","", ;
		"","","","","","",;
		"", "","" , "", "", "",""})
			
		Aadd(aExcel,{ "","","","","","","", ;
		"","","","","",;
		nlContFol, nlAlqFol,nlBasFol , "", nlIVAFol, nlRetFol,"",""})
		
		
Return()

static function GenExcel(aExcel)

	Local oExcel    	:= FWMSEXCEL():New()
	Local cFile     	:= AllTrim(cRuta) //__RelDir  //Grabar en la ruta configurada en el spool
	Local aAreaExel 	:= GetArea()
	Local  nloop := 0
		If !ExistDir(cFile)
			//#"Atencion" ##"No se encontro la carpeta SPOOL en el servidor, el archivo se creara en la ruta : " ##"OK"
			Aviso("Atencion","No se encontro la carpeta SPOOL en el servidor, el archivo se creara en la ruta : "+GetClientDir(),{"OK"})

			cFile:= GetClientDir()+"Libro_ventas"+".xls"  //Grabar en la ruta del smartclient (cuando el path no exista)
		Else
			cFile +="Libro_ventas"+".xls" //+".xlsx"
		Endif

		oExcel:CFRCOLORHEADER := "#000000"
		oExcel:CFRCOLORTITLE  := "#000000"
		oExcel:CBGCOLORHEADER := "#FFFFFF"
		oExcel:CBGCOLORLINE   := "#FFFFFF"
		oExcel:CBGCOLOR2LINE  := "#FFFFFF"
		
		//oExcel:AddworkSheet(STR0014) // "Conceptos"

		If  !Empty(aExcel)
		
		oExcel:AddworkSheet(STR0014) // "Conceptos"
		
				For nloop := 0 to len(aExcel)

				    If  nloop==0     //Titulos
				    	//Titulo de tabla
				    	oExcel:AddTable (STR0014,STR0001) //"Reporte libro de compras"

				    	//Titulo de columnas
				    	//AddColumn(< cWorkSheet >, < cTable >, < cColumn >, < nAlign >, < nFormat >, < lTotal >)
					   	oExcel:AddColumn(STR0014,STR0001,STR0029+STR0044,1,1)							//1
						oExcel:AddColumn(STR0014,STR0001,STR0023+" "+STR0030+" "+STR0045 ,1,1)					//2
						oExcel:AddColumn(STR0014,STR0001,STR0046,1,1) 							//3
						oExcel:AddColumn(STR0014,STR0001,STR0031+" "+STR0047,1,1) 					//4
						oExcel:AddColumn(STR0014,STR0001,STR0019+" "+STR0024+" "+STR0030+" "+STR0048,1,1) 					//5
						oExcel:AddColumn(STR0014,STR0001,STR0025+" "+STR0035,1,1)  //6
						oExcel:AddColumn(STR0014,STR0001,"Serie",1,1)  //6
						oExcel:AddColumn(STR0014,STR0001,STR0025+" "+STR0033+" "+STR0035,1,1) 			//7
						oExcel:AddColumn(STR0014,STR0001,STR0025+" "+STR0034+" "+STR0050,1,1) 			//8
						oExcel:AddColumn(STR0014,STR0001,STR0025+" "+STR0034+" "+STR0051,1,1) 					//9
						oExcel:AddColumn(STR0014,STR0001,STR0026+" "+STR0032+" "+STR0052,1,1) 					//10
						oExcel:AddColumn(STR0014,STR0001,STR0025+" "+STR0035+" "+STR0053,1,1) 			//11
						oExcel:AddColumn(STR0014,STR0001,STR0020+" "+STR0021+" "+STR0036+" "+STR0054,1,1) 			//12
						oExcel:AddColumn(STR0014,STR0001,STR0021+" "+STR0027+" "+STR0037+" "+STR0055,1,1) 	//13
						oExcel:AddColumn(STR0014,STR0001,STR0038+" "+STR0040,1,1) 	//14
						oExcel:AddColumn(STR0014,STR0001,STR0039+" "+STR0056,1,1) 					//15
						oExcel:AddColumn(STR0014,STR0001,STR0040+" "+STR0054,1,1) 					//16
						oExcel:AddColumn(STR0014,STR0001,STR0054+" "+STR0028+" "+STR0041+" "+STR0057,1,1) 					//17
						oExcel:AddColumn(STR0014,STR0001,STR0043+" "+STR0058,1,1) 	//18
						oExcel:AddColumn(STR0014,STR0001,"Grupo"+" "+"Tributario",1,1) 	//19
	

						
					Else
					    oExcel:AddRow(STR0014,STR0001,aExcel[nloop])
			    	Endif
				Next
			oExcel:Activate()
			oExcel:GetXMLFile(cFile)
				If File(cFile)
					Aviso("Atención","Archivo generado con éxito en la ruta: "+cFile,{"OK"})   //"Atención","Archivo generado con éxito en la ruta: ","OK"
				Else
					Aviso("Atención","No se creo el archivo, verifique los parámetros!!",{"OK"})   //"Atención","No se creo el archivo, verifique los parámetros!!","OK"
				Endif
		
		Else
				Aviso("Atención","No se encontraron registros con los parámetros seleccionados.",{"OK"}) //"No se encontraron registros con los parámetros seleccionados."
		Endif
	RestArea(aAreaExel)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion   ³ FCABLVC ³ Autor  ³Felipe C. Seolin    ³ Data ³ 23/08/10   ³ ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrip.  ³ Cria cabeçalho para relatório de vendas.                    ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ llCol : Imprime ou não colunas de título                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FISR016                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FCABLVC(llCol)
	Local olFont1	:= TFont():New("Garamond",,20,,.T.,,,,,.F.)
	Local olFont2	:= TFont():New("Perpetua",,8,,.T.,,,,,.F.)
	Local olFont3	:= TFont():New("Perpetua",,8,,.F.,,,,,.F.)
	Local olBrush	:= TBrush():New(,CLR_GRAY)
	Local nlLin		:= 5

	opPrn:Say(nlLin,0050,SM0->M0_NOMECOM,olFont1)
	nlLin += 70
	If nImpPag == 1
		opPrn:Say(nlLin,0050,AllTrim(Str(nPagIni)),olFont3)
		nPagIni ++
	EndIf
	nlLin += 50
	opPrn:Say(nlLin,0050,STR0012 + SM0->M0_CGC,olFont3)
	nlLin += 100
	opPrn:Say(nlLin,0050,STR0013 + SM0->M0_ENDCOB + SM0->M0_CIDCOB,olFont3)
	nlLin += 100
	opPrn:Say(nlLin,1050,STR0014,olFont2)
	nlLin += 50
	opPrn:Say(nlLin,1050,STR0015 + MesExtenso(Month(dFecIni)) + STR0016 + AllTrim(Str(Ano(dFecIni))),olFont3)
	nlLin += 150
	If llCol
		opPrn:FillRect({nlLin - 150,2540,nlLin,2970},olBrush)  //Llenado de color gris
		
		opPrn:Box(nlLin - 150,2540,nlLin,2970) //Cajas
		opPrn:Say(nlLin - 100,2560,STR0017,olFont2)// "VENTAS INTERNAS O"
		opPrn:Say(nlLin - 50,2560,STR0018,olFont2)//"EXPORTAC. CALCULADAS"
			
		opPrn:FillRect({nlLin,0060,nlLin + 200,3600},olBrush) //Llenado de color gris
		
		//Dibuja las rayyas verticales que separan cada columna
		
		opPrn:Box(nlLin,0060,nlLin + 200,3600)
		opPrn:Line(nlLin,0155,nlLin + 200,0155)
		opPrn:Line(nlLin,0305,nlLin + 200,0305)
		opPrn:Line(nlLin,0550,nlLin + 200,0550)
		opPrn:Line(nlLin,0900,nlLin + 200,0900)
		opPrn:Line(nlLin,1050,nlLin + 200,1050)
		opPrn:Line(nlLin,1250,nlLin + 200,1250)
		opPrn:Line(nlLin,1450,nlLin + 200,1450)
		opPrn:Line(nlLin,1650,nlLin + 200,1650)
		opPrn:Line(nlLin,1850,nlLin + 200,1850)
		opPrn:Line(nlLin,2000,nlLin + 200,2000)
		opPrn:Line(nlLin,2200,nlLin + 200,2200)
		opPrn:Line(nlLin,2370,nlLin + 200,2370)
		opPrn:Line(nlLin,2540,nlLin + 200,2540)
		opPrn:Line(nlLin,2710,nlLin + 200,2710)
		opPrn:Line(nlLin,2800,nlLin + 200,2800)
		opPrn:Line(nlLin,2970,nlLin + 200,2970)
		opPrn:Line(nlLin,3140,nlLin + 200,3140)
		opPrn:Line(nlLin,3270,nlLin + 200,3270)
		opPrn:Line(nlLin,3410,nlLin + 200,3410)
		
		opPrn:Say(nlLin,0910,STR0019,olFont2)
		opPrn:Say(nlLin,2210,STR0020,olFont2)
		opPrn:Say(nlLin,2380,STR0021,olFont2)
		opPrn:Say(nlLin,2980,STR0022,olFont2) //"IVA"
		nlLin += 50
		opPrn:Say(nlLin,0165,STR0023,olFont2)
		opPrn:Say(nlLin,0910,STR0024,olFont2)
		opPrn:Say(nlLin,1260,STR0025,olFont2)
		opPrn:Say(nlLin,1460,STR0025,olFont2)
		opPrn:Say(nlLin,1660,STR0025,olFont2)
		opPrn:Say(nlLin,1860,STR0026,olFont2)
		opPrn:Say(nlLin,2010,STR0025,olFont2)
		opPrn:Say(nlLin,2210,STR0021,olFont2)
		opPrn:Say(nlLin,2380,STR0027,olFont2)
		opPrn:Say(nlLin,2980,STR0028,olFont2)//"Reten."
		nlLin += 50
		opPrn:Say(nlLin,0080,STR0029,olFont2)
		opPrn:Say(nlLin,0165,STR0030,olFont2)
		opPrn:Say(nlLin,0560,STR0031,olFont2)
		opPrn:Say(nlLin,0910,STR0032,olFont2)
		opPrn:Say(nlLin,1060,STR0025,olFont2)
		opPrn:Say(nlLin,1260,STR0033,olFont2)
		opPrn:Say(nlLin,1460,STR0034,olFont2)
		opPrn:Say(nlLin,1660,STR0034,olFont2)
		opPrn:Say(nlLin,1860,STR0032,olFont2)
		opPrn:Say(nlLin,2010,STR0035,olFont2)
		opPrn:Say(nlLin,2210,STR0036,olFont2)
		opPrn:Say(nlLin,2380,STR0037,olFont2)
		opPrn:Say(nlLin,2550,STR0038,olFont2)
		opPrn:Say(nlLin,2720,STR0039,olFont2)
		opPrn:Say(nlLin,2810,STR0040,olFont2)
		opPrn:Say(nlLin,2980,STR0041,olFont2)
		opPrn:Say(nlLin,3150,STR0042,olFont2)
		opPrn:Say(nlLin,3280,STR0043,olFont2)//"Numero de"
		opPrn:Say(nlLin,3450,"Grupo",olFont2)
		nlLin += 50
		opPrn:Say(nlLin,0080,STR0044,olFont2)
		opPrn:Say(nlLin,0165,STR0045,olFont2)
		opPrn:Say(nlLin,0345,STR0046,olFont2)
		opPrn:Say(nlLin,0560,STR0047,olFont2)
		opPrn:Say(nlLin,0910,STR0048,olFont2)
		opPrn:Say(nlLin,1060,STR0049,olFont2)
		opPrn:Say(nlLin,1260,STR0049,olFont2)
		opPrn:Say(nlLin,1460,STR0050,olFont2)
		opPrn:Say(nlLin,1660,STR0051,olFont2)
		opPrn:Say(nlLin,1860,STR0052,olFont2)
		opPrn:Say(nlLin,2010,STR0053,olFont2)
		opPrn:Say(nlLin,2210,STR0054,olFont2)
		opPrn:Say(nlLin,2380,STR0055,olFont2)
		opPrn:Say(nlLin,2550,STR0040,olFont2)//"Impuest"
		opPrn:Say(nlLin,2720,STR0056,olFont2)//"(Alic."
		opPrn:Say(nlLin,2810,STR0022,olFont2)//"IVA"
		opPrn:Say(nlLin,2980,STR0057,olFont2)//"comprador)"
		opPrn:Say(nlLin,3150,STR0022,olFont2)//"IVA"
		opPrn:Say(nlLin,3280,STR0058,olFont2)//"Comprobante"
		opPrn:Say(nlLin,3450,"tributario" ,olFont2)
	EndIf
Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion   ³ FAliDir ³ Autor  ³Felipe C. Seolin    ³ Data ³ 23/08/10   ³ ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrip.  ³ Cria máscara de acordo com o valor e alinhado à direita.   ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nlVlr : Valor a ser impresseo                              ³±±
±±³          ³ clPicture : Máscara do valor.                              ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Retorno   ³ clRet : Caracter alinhado à direita.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FISR016                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FAliDir(nlVlr,clPicture)
	Local clRet := ""

	If Len(AllTrim(Str(Int(nlVlr)))) == 9
		clRet := PADL(" ",1," ") + AllTrim(Transform(nlVlr,clPicture))
	ElseIf Len(AllTrim(Str(Int(nlVlr)))) == 8
		clRet := PADL(" ",3," ") + AllTrim(Transform(nlVlr,clPicture))
	ElseIf Len(AllTrim(Str(Int(nlVlr)))) == 7
		clRet := PADL(" ",5," ") + AllTrim(Transform(nlVlr,clPicture))
	ElseIf Len(AllTrim(Str(Int(nlVlr)))) == 6
		clRet := PADL(" ",8," ") + AllTrim(Transform(nlVlr,clPicture))
	ElseIf Len(AllTrim(Str(Int(nlVlr)))) == 5
		clRet := PADL(" ",10," ") + AllTrim(Transform(nlVlr,clPicture))
	ElseIf Len(AllTrim(Str(Int(nlVlr)))) == 4
		clRet := PADL(" ",12," ") + AllTrim(Transform(nlVlr,clPicture))
	ElseIf Len(AllTrim(Str(Int(nlVlr)))) == 3
		clRet := PADL(" ",15," ") + AllTrim(Transform(nlVlr,clPicture))
	ElseIf Len(AllTrim(Str(Int(nlVlr)))) == 2
		clRet := PADL(" ",17," ") + AllTrim(Transform(nlVlr,clPicture))
	ElseIf Len(AllTrim(Str(Int(nlVlr)))) == 1
		clRet := PADL(" ",19," ") + AllTrim(Transform(nlVlr,clPicture))
	Endif
Return clRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  GetSFP        ºAutor  ³ Felipe C. Seolin     ³ Data ³23/08/10 ³º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Busca valor de espécie da tabela SFP                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Parametros³ clFilial : Filial do Sistema                                 ³±±
±±³          ³ clSerie : Série da Nota Fiscal                               ³±±
±±³          ³ clNFis : Número do documento                                 ³±±
±±³          ³ clEsp : Espécie da Nota Fiscal                               ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Retorno   ³ clAut : Número da autorização na tabela SFP                  ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFIS                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GetSFP(clFilial,clSerie,clNFis,clEsp)
	Local clQuery	:= ""
	Local clAut		:= ""
	Local clAlias	:= Alias()
	Local nlOrder	:= IndexOrd()
	Local nlReg		:= Recno()
	Local nlEsp		:= 0
	Local alEspec := {{"1","NF"},{"2","NCC"},{"3","NDC"},{"4","NDI"},{"5","NCI"},{"6","RTS"}}

	nlEsp := alEspec[aScan(alEspec,{|x| x[2] == AllTrim(clEsp)})][1]

	clQuery := "SELECT FP_NUMAUT AUT "
	clQuery += "FROM " + RetSqlName("SFP") + " SFP "
	clQuery += "WHERE	FP_FILIAL = '" + xFilial("SFP") + "' "
	clQuery += "AND		SFP.D_E_L_E_T_ = '' "
	clQuery += "AND		FP_FILUSO = '" + clFilial + "' "
	clQuery += "AND		FP_SERIE = '" + clSerie + "' "
	clQuery += "AND		FP_ESPECIE = '" + nlEsp + "' "
	clQuery += "AND		'" + clNFis + "' BETWEEN FP_NUMINI AND FP_NUMFIM "

	TcQuery clQuery New Alias "TRBSFP"

	clAut := TRBSFP->AUT

	TRBSFP->(DBCloseArea())
	DBSelectArea(clAlias)
	DBSetOrder(nlOrder)
	DBGoTo(nlReg)
Return(clAut)
