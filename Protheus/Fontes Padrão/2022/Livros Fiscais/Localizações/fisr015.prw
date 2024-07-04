#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "FISR015.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funci¢n ³ FISR015 ³ Autor ³ Felipe C. Seolin    ³ Data ³ 23/08/2010 ³   ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrip.³ Gera Relatório de Compras para Venezuela                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso     ³ SIGAFIS                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³gSantacruz³DMINA-2452³Cambios realizados por Cesar Butista:Se habilita ³±±
±±³          ³          ³la funcionalidad para la generación de archivo   ³±±
±±³          ³          ³ Excel con los movimientos del reporte .         ³±±
±±³gSantacruz³DMINA-3190³Etiquetas comentadas. Agrupacion de registros por³±±
±±³          ³          ³codigo fiscal provvedor y factura.               ³±±
±±³          ³          ³Solo considera que hay un solo % de iva.         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FISR015
	Local clTitulo	:= STR0001	//"Informe de Libro de Compras Venezuela"
	Private opPrn	:= Nil
	Private aExcel 	:= {}
	Private dFecIni	:=ctod("  /  /  ")
	Private dFecFin	:=ctod("  /  /  ")
	Private nImpPag	:=0
	Private nPagIni	:=0
	Private cRuta	:=''


	If Pergunte("FISR015",.T.)
		dFecIni	:=	MV_PAR01 //Fecha inicial basada en los movimientos de la tabla SF3
		dFecFin	:=	MV_PAR02 //Fecha final basada en los movimientos de la tabla SF3
		nImpPag :=	MV_PAR03 //Validara si será impresa el número de página en el encabezado del reporte.
		nPagIni :=	MV_PAR04 //Si el parámetro anterior esta con opción “SI” tomara el valor informado como el número de página inicial para el informe.
		cRuta   :=	MV_PAR05 //Se debe informar el Root donde será grabado el archivo Excel generado por la rutina.
		
		If SubStr(dtos(dFecFin),1,6) == SubStr(dtos(dFecIni),1,6)
			opPrn := TmsPrinter():New(clTitulo)
			opPrn:SetPaperSize(9)
			opPrn:SetLandscape()
			opPrn:StartPage()
			FRELC()
			opPrn:EndPage()
			opPrn:Preview()
			opPrn:End()
			
			GenExcel(aExcel)
			
		Else
			MsgAlert(STR0063)//"Informe Fch. Inicial y Final de mismo Mes y Ano."
		EndIf
	EndIf
Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  FRELC         ºAutor  ³ Felipe C. Seolin     ³ Data ³23/08/10 ³º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Crias estrutura do relatório de Compras.                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFIS                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FRELC()
	Local olFont2	:= TFont():New("Perpetua",,8,,.T.,,,,,.F.)
	Local olFont3	:= TFont():New("Perpetua",,8,,.F.,,,,,.F.)
	Local clQuery	:= ""
	Local clLvroImp	:= clLvroRet := ""
	Local clNota	:= clSerie := clCli := clLoja := clEspec := ""
	Local nlBasZero	:= nlRetZero := 0
	Local nlBasGenEX:= nlIVAGenEX := nlRetGenEX := nlBasAdiEX := nlIVAAdiEX := nlRetAdiEX := nlBasRedEX := nlIVARedEX := nlRetRedEX := 0
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
	Local alDados	:= Array(1,18)
	Local dFecRet := CTOD("  /  /  ")
	Local cFecRet := ""
	
	clQuery := "SELECT	SF3.* "
	clQuery += "	,A2_CGC "
	clQuery += "	,A2_NOME "
	clQuery += "	,A2_TPESSOA "
	clQuery += "	,A2_EST "
	clQuery += "FROM " + RetSqlName("SF3") + " SF3 "

	clQuery += "INNER JOIN " + RetSqlName("SA2") + " SA2 "
	clQuery += "ON	A2_FILIAL = '" + xFilial("SA2") + "' "
	clQuery += "AND	SA2.D_E_L_E_T_ = '' "
	clQuery += "AND	A2_COD = F3_CLIEFOR "
	clQuery += "AND	A2_LOJA = F3_LOJA "

	clQuery += "WHERE	F3_FILIAL = '" + xFilial("SF3") + "' "
	clQuery += "AND	SF3.D_E_L_E_T_ = '' "
	clQuery += "AND	F3_TIPOMOV = 'C' "
	clQuery += "AND	F3_EMISSAO BETWEEN '" + dtos(dFecIni) + "' AND '" + dtos(dFecFin) + "' "

	clQuery += "ORDER BY	F3_NFISCAL,F3_SERIE,F3_CLIEFOR ,F3_LOJA ,F3_ESPECIE "

	TcQuery clQuery New Alias "LIVRO"
	TcSetField("LIVRO","D","LIVRO->F3_EMISSAO")

	If LIVRO->(EOF())
		FCABLVC(.T.)
		nlLin += 50
		opPrn:Say(nlLin,0055,STR0064,olFont3) //"Sin Movim. "
		llFim := .T.
	EndIf
	While LIVRO->(!EOF())
		alDados[1][1] := StrZero(nlOper,5)
		alDados[1][2] := SubStr(LIVRO->F3_EMISSAO,7,2) + "/" + SubStr(LIVRO->F3_EMISSAO,5,2) + "/" + SubStr(LIVRO->F3_EMISSAO,1,4)
		alDados[1][3] := Transform(LIVRO->A2_CGC,PesqPict("SA2","A2_CGC"))
		alDados[1][4] := SubStr(LIVRO->A2_NOME,1,15)
		If AllTrim(LIVRO->A2_TPESSOA) $ "PJD/PNR/SR/ND/NR"
			alDados[1][5] := LIVRO->A2_TPESSOA
		Else
			alDados[1][5] := ""
		EndIf
		dFecRet := CTOD("  /  /  ")
		cFecRet := ""
		
		If AllTrim(LIVRO->F3_TIPOMOV) == "V"
			alDados[1][6] := Posicione("SFE",8,xFilial("SFE") + LIVRO->F3_CLIEFOR + LIVRO->F3_LOJA + LIVRO->F3_NFISCAL + LIVRO->F3_SERIE,"FE_NROCERT")
			dFecRet       := Posicione("SFE",8,xFilial("SFE") + LIVRO->F3_CLIEFOR + LIVRO->F3_LOJA + LIVRO->F3_NFISCAL + LIVRO->F3_SERIE,"FE_EMISSAO")
			cFecRet := SubStr(dtos(dFecRet),7,2) + "/" + SubStr(dtos(dFecRet),5,2) + "/" + SubStr(dtos(dFecRet),1,4)
			cFecRet := IIF(AllTrim(cFecRet) == "/  /"," ",cFecRet)
		ElseIf AllTrim(LIVRO->F3_TIPOMOV) == "C"
			alDados[1][6] := Posicione("SFE",4,xFilial("SFE") + LIVRO->F3_CLIEFOR + LIVRO->F3_LOJA + LIVRO->F3_NFISCAL + LIVRO->F3_SERIE,"FE_NROCERT")
			dFecRet       := Posicione("SFE",4,xFilial("SFE") + LIVRO->F3_CLIEFOR + LIVRO->F3_LOJA + LIVRO->F3_NFISCAL + LIVRO->F3_SERIE,"FE_EMISSAO")
			cFecRet := SubStr(dtos(dFecRet),7,2) + "/" + SubStr(dtos(dFecRet),5,2) + "/" + SubStr(dtos(dFecRet),1,4)
			cFecRet := IIF(AllTrim(cFecRet) == "/  /"," ",cFecRet)
		EndIf
		alDados[1][7] := ""
		alDados[1][8] := ""
		alDados[1][9] := ""
		If AllTrim(LIVRO->F3_ESPECIE) $ "NDI/NDP"
			alDados[1][10] := ""
			If AllTrim(LIVRO->F3_ESPECIE) $ "NDI"
				alDados[1][11] := GetSFP(LIVRO->F3_FILIAL,LIVRO->F3_SERIE,LIVRO->F3_NFISCAL,LIVRO->F3_ESPECIE)
			Else
				alDados[1][11] := Posicione("SF1",1,xFilial("SF1") + LIVRO->F3_NFISCAL + LIVRO->F3_SERIE + LIVRO->F3_CLIEFOR + LIVRO->F3_LOJA,"F1_FORMLIB")
			EndIf
			alDados[1][12] := LIVRO->F3_NFISCAL
			alDados[1][13] := ""
		ElseIf AllTrim(LIVRO->F3_ESPECIE) $ "NCI/NCP"
			alDados[1][10] := ""
			If AllTrim(LIVRO->F3_ESPECIE) $ "NCI"
				alDados[1][11] := GetSFP(LIVRO->F3_FILIAL,LIVRO->F3_SERIE,LIVRO->F3_NFISCAL,LIVRO->F3_ESPECIE)
			Else
				alDados[1][11] := Posicione("SF2",2,xFilial("SF2") + LIVRO->F3_CLIEFOR + LIVRO->F3_LOJA + LIVRO->F3_NFISCAL + LIVRO->F3_SERIE,"F2_FORMLIB")
			EndIf
			alDados[1][12] := ""
			alDados[1][13] := LIVRO->F3_NFISCAL
		Else		
			alDados[1][10] := LIVRO->F3_NFISCAL
			alDados[1][11] := Posicione("SF1",1,xFilial("SF1") + LIVRO->F3_NFISCAL + LIVRO->F3_SERIE + LIVRO->F3_CLIEFOR + LIVRO->F3_LOJA,"F1_FORMLIB")
			alDados[1][12] := ""
			alDados[1][13] := ""
		EndIf
		If AllTrim(LIVRO->F3_ESPECIE) == "NF"
			alDados[1][14] := "01"
		ElseIf AllTrim(LIVRO->F3_ESPECIE) $ "NCI/NCP/NDI/NDP"
			alDados[1][14] := "02"
		ElseIf !Empty(LIVRO->F3_DTCANC)
			alDados[1][14] := "03"
		Else
			alDados[1][14] := "04"
		EndIf
		If AllTrim(LIVRO->F3_ESPECIE) $ "NDP/NCI"
			alDados[1][15] := Posicione("SD1",1,xFilial("SD1") + LIVRO->F3_NFISCAL + LIVRO->F3_SERIE + LIVRO->F3_CLIEFOR + LIVRO->F3_LOJA,"D1_NFORI")
		ElseIf AllTrim(LIVRO->F3_ESPECIE) $ "NCP/NDI"
			alDados[1][15] := Posicione("SD2",3,xFilial("SD2") + LIVRO->F3_NFISCAL + LIVRO->F3_SERIE + LIVRO->F3_CLIEFOR + LIVRO->F3_LOJA,"D2_NFORI")
		Else
			alDados[1][15] := ""
		EndIf
		alDados[1][16] := ""
		alDados[1][17] := ""
		If AllTrim(LIVRO->A2_EST) == "EX"
			alDados[1][18] := "IM"
		Else
			alDados[1][18] := "CN"
		EndIf
		clNota	:= LIVRO->F3_NFISCAL
		clSerie	:= LIVRO->F3_SERIE
		clCli	:= LIVRO->F3_CLIEFOR
		clLoja	:= LIVRO->F3_LOJA
		clEspec	:= LIVRO->F3_ESPECIE
		
		//Barre la tabla SF3 del mismo documento fiscal y proveedor
		While clNota == LIVRO->F3_NFISCAL .and. clSerie == LIVRO->F3_SERIE .and. clCli == LIVRO->F3_CLIEFOR .and. clLoja == LIVRO->F3_LOJA .and. clEspec == LIVRO->F3_ESPECIE
			alImp := TesImpInf(LIVRO->F3_TES)
			clLvroImp := ""
			//Extrae el codigo de libro fiscal que sea de IVA
			For nlI := 1 to Len(alImp)
				If SubStr(alImp[nlI][1],1,2) == "IV"
					clLvroImp := Posicione("SFB",1,xFilial("SFB") + alImp[nlI][1],"FB_CPOLVRO")
					Exit
				Else
					clLvroImp := ""
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
			
			If !Empty(clLvroImp) .and. Empty(LIVRO->F3_DTCANC)//Si hay codigo de libro fiscal y no es un movimiento cancelado
				
					nlPos := aScan(alVal,{|x| x[4] == &("LIVRO->F3_ALQIMP" + clLvroImp)})//Guarda en el arreglo agrupando por porcentaje de impuesto
					
				//total compras
					If nlPos > 0
						If AllTrim(LIVRO->F3_ESPECIE) $ "NDP/NCI/NF"
							alVal[nlPos][1] += LIVRO->F3_VALMERC
						Else
							alVal[nlPos][1] -= LIVRO->F3_VALMERC
						EndIf
					Else
						If AllTrim(LIVRO->F3_ESPECIE) $ "NDP/NCI/NF"
							nlValCont := LIVRO->F3_VALMERC
						Else
							nlValCont := LIVRO->F3_VALMERC * (-1)
						EndIf
					EndIf
				
				//Base de IVA Exento
					If &("LIVRO->F3_ALQIMP" + clLvroImp) == 0 .and. LIVRO->F3_EXENTAS <> 0 //SI IVA CERO
						If nlPos > 0
							If AllTrim(LIVRO->F3_ESPECIE) $ "NDP/NCI/NF"
					
										alVal[nlPos][2] += LIVRO->F3_EXENTAS
					
							else
					
										alVal[nlPos][2] -= LIVRO->F3_EXENTAS 
					
							endif	
						Else
							If AllTrim(LIVRO->F3_ESPECIE) $ "NDP/NCI/NF"
					
										nlAliq0 := LIVRO->F3_EXENTAS
					
							else
					
										nlAliq0 := LIVRO->F3_EXENTAS  * (-1)
					
							endif	
						EndIf
					EndIf
					
				//Importe de Bases
					If &("LIVRO->F3_BASIMP" + clLvroImp) > 0 .and. &("LIVRO->F3_ALQIMP" + clLvroImp) <> 0
						If nlPos > 0
							If AllTrim(LIVRO->F3_ESPECIE) $ "NDP/NCI/NF"
								alVal[nlPos][3] += &("LIVRO->F3_BASIMP" + clLvroImp)
							Else
								alVal[nlPos][3] -= &("LIVRO->F3_BASIMP" + clLvroImp)
							EndIf
						Else
							If AllTrim(LIVRO->F3_ESPECIE) $ "NDP/NCI/NF"
								nlBasImp := &("LIVRO->F3_BASIMP" + clLvroImp)
							Else
								nlBasImp := &("LIVRO->F3_BASIMP" + clLvroImp) * (-1)
							EndIf
						EndIf
					EndIf
				
				//Importe de Impuestos 
					If nlPos > 0
						If AllTrim(LIVRO->F3_ESPECIE) $ "NDP/NCI/NF"
							alVal[nlPos][5] += &("LIVRO->F3_VALIMP" + clLvroImp)
						Else
							alVal[nlPos][5] -= &("LIVRO->F3_VALIMP" + clLvroImp)
						EndIf
					Else
						nlAlqImp := &("LIVRO->F3_ALQIMP" + clLvroImp)
						If AllTrim(LIVRO->F3_ESPECIE) $ "NDP/NCI/NF"
							nlValImp := &("LIVRO->F3_VALIMP" + clLvroImp)
						Else
							nlValImp := &("LIVRO->F3_VALIMP" + clLvroImp) * (-1)
						EndIf
					EndIf
				
				
				
				//Extrae el codigo de libro fiscal que sea de Retencion de IVA	
					For nlI := 1 to Len(alImp)
						If SubStr(alImp[nlI][1],1,2) == "RV"
							clLvroRet := Posicione("SFB",1,xFilial("SFB") + alImp[nlI][1],"FB_CPOLVRO")
							Exit
						Else
							clLvroRet := ""
						EndIf
					Next nlI
					
				//IVA retenido por el vendedor	
					If !Empty(clLvroRet)
						If nlPos > 0
							If AllTrim(LIVRO->F3_ESPECIE) $ "NDP/NCI/NF"
								alVal[nlPos][6] += &("LIVRO->F3_VALIMP" + clLvroRet)
							Else
								alVal[nlPos][6] -= &("LIVRO->F3_VALIMP" + clLvroRet)
							EndIf
						Else
							If AllTrim(LIVRO->F3_ESPECIE) $ "NDP/NCI/NF"
								nlValRet := &("LIVRO->F3_VALIMP" + clLvroRet)
							Else
								nlValRet := &("LIVRO->F3_VALIMP" + clLvroRet) * (-1)
							EndIf
						EndIf
					Else
						nlValRet := 0
					EndIf
			EndIf
			
			If nlPos <= 0 //Genera registros en el arreglo
				Aadd(alVal,{nlValCont+nlValImp,nlAliq0,nlBasImp,nlAlqImp,nlValImp,nlValRet})
			EndIf
			//Inicializa variable 
			nlValCont:= nlAliq0 := nlBasImp := nlAlqImp := nlValImp := nlValRet := 0
			
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
		
		
			If !Empty(clLvroImp) //Para los totales de pie de pagina
				
				If AllTrim(LIVRO->A2_EST) == "EX" .and. &("LIVRO->F3_ALQIMP" + clLvroImp) == 12
					If AllTrim(LIVRO->F3_ESPECIE) $ "NDP/NCI/NF"
						nlBasGenEX += &("LIVRO->F3_BASIMP" + clLvroImp)
						nlIVAGenEX += &("LIVRO->F3_VALIMP" + clLvroImp)
						nlRetGenEX += &("LIVRO->F3_VALIMP" + clLvroRet)
					Else
						nlBasGenEX -= &("LIVRO->F3_BASIMP" + clLvroImp)
						nlIVAGenEX -= &("LIVRO->F3_VALIMP" + clLvroImp)
						nlRetGenEX -= &("LIVRO->F3_VALIMP" + clLvroRet)
					EndIf
				ElseIf AllTrim(LIVRO->A2_EST) == "EX" .and. &("LIVRO->F3_ALQIMP" + clLvroImp) == 22
					If AllTrim(LIVRO->F3_ESPECIE) $ "NDP/NCI/NF"
						nlBasAdiEX += &("LIVRO->F3_BASIMP" + clLvroImp)
						nlIVAAdiEX += &("LIVRO->F3_VALIMP" + clLvroImp)
						nlRetAdiEX += &("LIVRO->F3_VALIMP" + clLvroRet)
					Else
						nlBasAdiEX -= &("LIVRO->F3_BASIMP" + clLvroImp)
						nlIVAAdiEX -= &("LIVRO->F3_VALIMP" + clLvroImp)
						nlRetAdiEX -= &("LIVRO->F3_VALIMP" + clLvroRet)
					EndIf
				ElseIf AllTrim(LIVRO->A2_EST) == "EX" .and. &("LIVRO->F3_ALQIMP" + clLvroImp) == 8
					If AllTrim(LIVRO->F3_ESPECIE) $ "NDP/NCI/NF"
						nlBasRedEX += &("LIVRO->F3_BASIMP" + clLvroImp)
						nlIVARedEX += &("LIVRO->F3_VALIMP" + clLvroImp)
						nlRetRedEX += &("LIVRO->F3_VALIMP" + clLvroRet)
					Else
						nlBasRedEX -= &("LIVRO->F3_BASIMP" + clLvroImp)
						nlIVARedEX -= &("LIVRO->F3_VALIMP" + clLvroImp)
						nlRetRedEX -= &("LIVRO->F3_VALIMP" + clLvroRet)
					EndIf
				EndIf
				If AllTrim(LIVRO->A2_EST) <> "EX" .and. &("LIVRO->F3_ALQIMP" + clLvroImp) == 12
					If AllTrim(LIVRO->F3_ESPECIE) $ "NDP/NCI/NF"
						nlBasGen += &("LIVRO->F3_BASIMP" + clLvroImp)
						nlIVAGen += &("LIVRO->F3_VALIMP" + clLvroImp)
						nlRetGen += &("LIVRO->F3_VALIMP" + clLvroRet)
					Else
						nlBasGen -= &("LIVRO->F3_BASIMP" + clLvroImp)
						nlIVAGen -= &("LIVRO->F3_VALIMP" + clLvroImp)
						nlRetGen -= &("LIVRO->F3_VALIMP" + clLvroRet)
					EndIf
				ElseIf AllTrim(LIVRO->A2_EST) <> "EX" .and. &("LIVRO->F3_ALQIMP" + clLvroImp) == 22
					If AllTrim(LIVRO->F3_ESPECIE) $ "NDP/NCI/NF"
						nlBasAdi += &("LIVRO->F3_BASIMP" + clLvroImp)
						nlIVAAdi += &("LIVRO->F3_VALIMP" + clLvroImp)
						nlRetAdi += &("LIVRO->F3_VALIMP" + clLvroRet)
					Else
						nlBasAdi -= &("LIVRO->F3_BASIMP" + clLvroImp)
						nlIVAAdi -= &("LIVRO->F3_VALIMP" + clLvroImp)
						nlRetAdi -= &("LIVRO->F3_VALIMP" + clLvroRet)
					EndIf
				ElseIf AllTrim(LIVRO->A2_EST) <> "EX" .and. &("LIVRO->F3_ALQIMP" + clLvroImp) == 8
					If AllTrim(LIVRO->F3_ESPECIE) $ "NDP/NCI/NF"
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
		
		//Imprime
		For nlI := 1 to Len(alVal)
			nlLin += 50
			If llFirst
				FCABLVC(.T.)
				llFirst := .F.
			EndIf
			If nlLin > 2220 //Imprime subtotales  antes de cambiar de pagina
				nlLin += 50                                                          
				opPrn:Say(nlLin,0080,STR0066,olFont2) // "Total de la pagina"
				opPrn:Say(nlLin,2180,FAliDir(nlContFol,"@E 999,999,999.99"),olFont2)
				opPrn:Say(nlLin,2330,FAliDir(nlAlqFol,"@E 999,999,999.99"),olFont2)
				opPrn:Say(nlLin,2530,FAliDir(nlBasFol,"@E 999,999,999.99"),olFont2)
				opPrn:Say(nlLin,2830,FAliDir(nlIVAFol,"@E 999,999,999.99"),olFont2)
				opPrn:Say(nlLin,3010,FAliDir(nlRetFol,"@E 999,999,999.99"),olFont2)
				opPrn:Say(nlLin,3190,FAliDir(0,"@E 999,999,999.99"),olFont2)
				opPrn:EndPage()
				opPrn:StartPage()
				FCABLVC(.T.) //Imprime encabezado
				nlLin := 725
				opPrn:Say(nlLin,0080,STR0067,olFont2) //"Transf. de valores de la pagina anterior"
				opPrn:Say(nlLin,2180,FAliDir(nlContFol,"@E 999,999,999.99"),olFont2)
				opPrn:Say(nlLin,2330,FAliDir(nlAlqFol,"@E 999,999,999.99"),olFont2)
				opPrn:Say(nlLin,2530,FAliDir(nlBasFol,"@E 999,999,999.99"),olFont2)
				opPrn:Say(nlLin,2830,FAliDir(nlIVAFol,"@E 999,999,999.99"),olFont2)
				opPrn:Say(nlLin,3010,FAliDir(nlRetFol,"@E 999,999,999.99"),olFont2)
				opPrn:Say(nlLin,3190,FAliDir(0,"@E 999,999,999.99"),olFont2)
				nlLin += 80
	
			EndIf
			If nlI > 1
				alDados[1][1] := StrZero(nlOper,5)
			EndIf
			//Imprime detalle
			opPrn:Say(nlLin,0060,alDados[1][1],olFont3)
			opPrn:Say(nlLin,0145,alDados[1][2],olFont3)
			opPrn:Say(nlLin,0295,alDados[1][3],olFont3)
			opPrn:Say(nlLin,0470,alDados[1][4],olFont3)
			opPrn:Say(nlLin,0750,alDados[1][5],olFont3)
			opPrn:Say(nlLin,0825,alDados[1][6],olFont3)
			opPrn:Say(nlLin,0990,alDados[1][7],olFont3)
			opPrn:Say(nlLin,1090,alDados[1][8],olFont3)
			opPrn:Say(nlLin,1190,alDados[1][9],olFont3)
			opPrn:Say(nlLin,1265,alDados[1][10],olFont3)
			opPrn:Say(nlLin,1440,alDados[1][11],olFont3)
			opPrn:Say(nlLin,1565,alDados[1][12],olFont3)
			opPrn:Say(nlLin,1758,alDados[1][13],olFont3)
			opPrn:Say(nlLin,1940,alDados[1][14],olFont3)
			opPrn:Say(nlLin,2000,alDados[1][15],olFont3)
			opPrn:Say(nlLin,2120,FAliDir(alVal[nlI][1],"@E 999,999,999.99"),olFont3)//total compras incluyendo iva
			opPrn:Say(nlLin,2270,FAliDir(alVal[nlI][2],"@E 999,999,999.99"),olFont3)//compras sin derecho a credito IVA
			opPrn:Say(nlLin,2470,FAliDir(alVal[nlI][3],"@E 999,999,999.99"),olFont3)//Base Impuestos
			opPrn:Say(nlLin,2590,FAliDir(alVal[nlI][4],"@R 999.99")        ,olFont3)//%Alic
			opPrn:Say(nlLin,2770,FAliDir(alVal[nlI][5],"@E 999,999,999.99"),olFont3)//Impuestos IVA
			opPrn:Say(nlLin,2950,FAliDir(alVal[nlI][6],"@E 999,999,999.99"),olFont3)//IVA retenido por el vendedor
			opPrn:Say(nlLin,3130,alDados[1][16],olFont3)
			opPrn:Say(nlLin,3230,alDados[1][17],olFont3)
			opPrn:Say(nlLin,3330,alDados[1][18],olFont3)
			nlContFol += alVal[nlI][1]
			nlAlqFol += alVal[nlI][2]
			nlBasFol += alVal[nlI][3]
			nlIVAFol += alVal[nlI][5]
			nlRetFol += alVal[nlI][6]
			nlOper ++
			If LIVRO->(EOF()) //Imrrime subtotal por fin de archivo
				nlLin += 50
				opPrn:Say(nlLin,2120,FAliDir(nlContFol,"@E 999,999,999.99"),olFont2)
				opPrn:Say(nlLin,2270,FAliDir(nlAlqFol,"@E 999,999,999.99"),olFont2)
				opPrn:Say(nlLin,2470,FAliDir(nlBasFol,"@E 999,999,999.99"),olFont2)
				opPrn:Say(nlLin,2770,FAliDir(nlIVAFol,"@E 999,999,999.99"),olFont2)
				opPrn:Say(nlLin,2950,FAliDir(nlRetFol,"@E 999,999,999.99"),olFont2)
				opPrn:Say(nlLin,3130,FAliDir(0,"@E 999,999,999.99"),olFont2)
			EndIf

			//Datos para el archivo de Excel
			Aadd(aExcel,{ alDados[1][1],alDados[1][2],alDados[1][3],alDados[1][4],alDados[1][6],cFecRet, ;
			alDados[1][10],alDados[1][11],alDados[1][12],alDados[1][13],alDados[1][14],alDados[1][15],;
			alVal[nlI][1], alVal[nlI][2], alVal[nlI][3], alVal[nlI][4], alVal[nlI][5], alVal[nlI][6],alDados[1][16]})
		Next nlI
		alDados := Array(1,18)
		alVal	:= {}
	EndDo //Finaliza barrido del Qry

		
	If !llFim //Imprime total general
		nlTotBas := nlBasZero + nlBasGenEX + nlBasAdiEX + nlBasRedEX + nlBasGen + nlBasAdi + nlBasRed
		nlTotIVA := nlIVAGenEX + nlIVAAdiEX + nlIVARedEX + nlIVAGen + nlIVAAdi + nlIVARed
		nlTotRet := nlRetZero + nlRetGenEX + nlRetAdiEX + nlRetRedEX + nlRetGen + nlRetAdi + nlRetRed
		nlLin += 150
		If nlLin > 2350
			opPrn:EndPage()
			opPrn:StartPage()
			nlLin := 150
		EndIf
		opPrn:Say(nlLin,2140,STR0052,olFont2)
		opPrn:Say(nlLin,2460,STR0053,olFont2)
		opPrn:Say(nlLin,2760,STR0054,olFont2)
		opPrn:Say(nlLin,3030,STR0055,olFont2)
		nlLin += 50
		If nlLin > 2350
			opPrn:EndPage()
			opPrn:StartPage()
			nlLin := 150
		EndIf
		opPrn:Say(nlLin,1000,STR0056,olFont2) //"Total Compras Exentas y/o sin derecho a Credito Fiscal"
		opPrn:Say(nlLin,2140,FAliDir(nlBasZero,"@E 999,999,999.99"),olFont3)
		opPrn:Say(nlLin,2450,FAliDir(0,"@E 999,999,999.99"),olFont3)
		opPrn:Say(nlLin,2730,FAliDir(nlRetZero,"@E 999,999,999.99"),olFont3)
		opPrn:Say(nlLin,3090,FAliDir(0,"@E 999,999,999.99"),olFont3)
		nlLin += 50
		If nlLin > 2350
			opPrn:EndPage()
			opPrn:StartPage()
			FCABLVC(.F.)
			nlLin := 600
		EndIf
		opPrn:Say(nlLin,1000,STR0057,olFont2)//"Total Compras Import. Afectadas solamente por alicuota gral."
		opPrn:Say(nlLin,2140,FAliDir(nlBasGenEX,"@E 999,999,999.99"),olFont3)
		opPrn:Say(nlLin,2450,FAliDir(nlIVAGenEX,"@E 999,999,999.99"),olFont3)
		opPrn:Say(nlLin,2730,FAliDir(nlRetGenEX,"@E 999,999,999.99"),olFont3)
		opPrn:Say(nlLin,3090,FAliDir(0,"@E 999,999,999.99"),olFont3)
		nlLin += 50
		If nlLin > 2350
			opPrn:EndPage()
			opPrn:StartPage()
			FCABLVC(.F.)
			nlLin := 600
		EndIf
		opPrn:Say(nlLin,1000,STR0058,olFont2) //"Total Compras Import. Afectadas por alicuota gral. + adicional"
		opPrn:Say(nlLin,2140,FAliDir(nlBasAdiEX,"@E 999,999,999.99"),olFont3)
		opPrn:Say(nlLin,2450,FAliDir(nlIVAAdiEX,"@E 999,999,999.99"),olFont3)
		opPrn:Say(nlLin,2730,FAliDir(nlRetAdiEX,"@E 999,999,999.99"),olFont3)
		opPrn:Say(nlLin,3090,FAliDir(0,"@E 999,999,999.99"),olFont3)
		nlLin += 50
		If nlLin > 2350
			opPrn:EndPage()
			opPrn:StartPage()
			FCABLVC(.F.)
			nlLin := 600
		EndIf
		opPrn:Say(nlLin,1000,STR0059,olFont2)//"Total Compras Import. Afectadas por alicuota reducida"
		opPrn:Say(nlLin,2140,FAliDir(nlBasRedEX,"@E 999,999,999.99"),olFont3)
		opPrn:Say(nlLin,2450,FAliDir(nlIVARedEX,"@E 999,999,999.99"),olFont3)
		opPrn:Say(nlLin,2730,FAliDir(nlRetRedEX,"@E 999,999,999.99"),olFont3)
		opPrn:Say(nlLin,3090,FAliDir(0,"@E 999,999,999.99"),olFont3)
		nlLin += 50
		If nlLin > 2350
			opPrn:EndPage()
			opPrn:StartPage()
			FCABLVC(.F.)
			nlLin := 600
		EndIf
		opPrn:Say(nlLin,1000,STR0060,olFont2)//"Total Compras Inter Afectadas solamente por alicuota gral."
		opPrn:Say(nlLin,2140,FAliDir(nlBasGen,"@E 999,999,999.99"),olFont3)
		opPrn:Say(nlLin,2450,FAliDir(nlIVAGen,"@E 999,999,999.99"),olFont3)
		opPrn:Say(nlLin,2730,FAliDir(nlRetGen,"@E 999,999,999.99"),olFont3)
		opPrn:Say(nlLin,3090,FAliDir(0,"@E 999,999,999.99"),olFont3)
		nlLin += 50
		If nlLin > 2350
			opPrn:EndPage()
			opPrn:StartPage()
			FCABLVC(.F.)
			nlLin := 600
		EndIf
		opPrn:Say(nlLin,1000,STR0061,olFont2)// "Total Compras Inter. Afectadas por alicuota gral. + adicional"
		opPrn:Say(nlLin,2140,FAliDir(nlBasAdi,"@E 999,999,999.99"),olFont3)
		opPrn:Say(nlLin,2450,FAliDir(nlIVAAdi,"@E 999,999,999.99"),olFont3)
		opPrn:Say(nlLin,2730,FAliDir(nlRetAdi,"@E 999,999,999.99"),olFont3)
		opPrn:Say(nlLin,3090,FAliDir(0,"@E 999,999,999.99"),olFont3)
		nlLin += 50
		If nlLin > 2350
			opPrn:EndPage()
			opPrn:StartPage()
			FCABLVC(.F.)
			nlLin := 600
		EndIf
		opPrn:Say(nlLin,1000,STR0062,olFont2)//"Total Compras Inter. Afectadas por alicuota reducida"
		opPrn:Say(nlLin,2140,FAliDir(nlBasRed,"@E 999,999,999.99"),olFont3)
		opPrn:Say(nlLin,2450,FAliDir(nlIVARed,"@E 999,999,999.99"),olFont3)
		opPrn:Say(nlLin,2730,FAliDir(nlRetRed,"@E 999,999,999.99"),olFont3)
		opPrn:Say(nlLin,3090,FAliDir(0,"@E 999,999,999.99"),olFont3)
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
		opPrn:Say(nlLin,3090,FAliDir(0,"@E 999,999,999.99"),olFont2)
	EndIf
	LIVRO->(DBCloseArea())
	
	Aadd(aExcel,{ "","","","","","", ;
		"","","","","","",;
		"", "","" , "", "", "",""})
			
	Aadd(aExcel,{ "","","","","","", ;
		"","","","","","",;
		nlContFol, nlAlqFol,nlBasFol , "", nlIVAFol, nlRetFol,""})

Return()



static function GenExcel(aExcel)

Local oExcel    	:= FWMSEXCEL():New()
Local cFile     	:= AllTrim(cRuta) //__RelDir  //Grabar en la ruta configurada en el spool
Local aAreaExel 	:= GetArea()
Local nloop:=0

If !ExistDir(cFile)
		//#"Atencion" ##"No se encontro la carpeta SPOOL en el servidor, el archivo se creara en la ruta : " ##"OK"
	Aviso("Atencion","No se encontro la carpeta SPOOL en el servidor, el archivo se creara en la ruta : "+GetClientDir(),{"OK"})

	cFile:= GetClientDir()+"Libro_Compras"+".xls"  //Grabar en la ruta del smartclient (cuando el path no exista)
Else
	cFile +="Libro_Compras"+".xls" //+".xlsx"
Endif

oExcel:CFRCOLORHEADER := "#000000"
oExcel:CFRCOLORTITLE  := "#000000"
oExcel:CBGCOLORHEADER := "#FFFFFF"
oExcel:CBGCOLORLINE   := "#FFFFFF"
oExcel:CBGCOLOR2LINE  := "#FFFFFF"

If  !Empty(aExcel)
		
		oExcel:AddworkSheet(STR0014) //"Compras"
		
		For nloop := 0 to len(aExcel)

			   If  nloop==0     //Titulos
				    	//Titulo de tabla
				    	oExcel:AddTable (STR0014,STR0001) //"Compras" //"Informe de Libro de Compras Venezuela"

				    	//Titulo de columnas

					   	oExcel:AddColumn(STR0014,STR0001,STR0018,1,1)							//1 "Compras" # "Informe de Libro de Compras Venezuela" #"Oper"
						oExcel:AddColumn(STR0014,STR0001,STR0009+" "+STR0024,1,1)					//2 "Compras" # "Informe de Libro de Compras Venezuela"#"Fecha"
						oExcel:AddColumn(STR0014,STR0001,STR0002,1,1) 							//3 "Compras" # "Informe de Libro de Compras Venezuela"#"R.I.F.: "
						oExcel:AddColumn(STR0014,STR0001,STR0011+" "+STR0036,1,1) 					//4"Compras" # "Informe de Libro de Compras Venezuela" #"Nombre o"
						oExcel:AddColumn(STR0014,STR0001,STR0013+" "+STR0038,1,1) 					//5 "Compras" # "Informe de Libro de Compras Venezuela"#"Numero"
						oExcel:AddColumn(STR0014,STR0001,"Fecha de Aplicacion Retención",1,1)  //6
						oExcel:AddColumn(STR0014,STR0001,STR0013+" "+STR0023+" "+STR0024,1,1) 			//7 "Compras" # "Informe de Libro de Compras Venezuela"#"Numero"
						oExcel:AddColumn(STR0014,STR0001,STR0022+" "+STR0024,1,1) 			//8"Compras" # "Informe de Libro de Compras Venezuela" #"Nº Control" #"de Factura"
						oExcel:AddColumn(STR0014,STR0001,STR0013+" "+STR0041,1,1) 					//9 "Compras" # "Informe de Libro de Compras Venezuela"#"Numero" # "ND"
						oExcel:AddColumn(STR0014,STR0001,STR0013+" "+STR0042,1,1) 					//10 "Compras" # "Informe de Libro de Compras Venezuela"#"Numero" # "NC"
						oExcel:AddColumn(STR0014,STR0001,STR0012+" "+STR0023+" "+STR0043,1,1) 			//11 "Compras" # "Informe de Libro de Compras Venezuela"#"de" #"Tran"
						oExcel:AddColumn(STR0014,STR0001,STR0013+" "+STR0024+" "+STR0044,1,1) 			//12 "Compras" # "Informe de Libro de Compras Venezuela"#"de Factura" #"Afectada"
						oExcel:AddColumn(STR0014,STR0001,STR0007+" "+STR0014+" "+STR0025+" "+STR0045,1,1) 	//13 "Compras" # "Informe de Libro de Compras Venezuela"
						oExcel:AddColumn(STR0014,STR0001,STR0014+" "+STR0015+" "+STR0026+" "+STR0046,1,1) 	//14 "Compras" # "Informe de Libro de Compras Venezuela"
						oExcel:AddColumn(STR0014,STR0001,STR0027+" "+STR0029,1,1) 					//15 "Compras" # "Informe de Libro de Compras Venezuela"
						oExcel:AddColumn(STR0014,STR0001,STR0028+" "+STR0047,1,1) 					//16 "Compras" # "Informe de Libro de Compras Venezuela"
						oExcel:AddColumn(STR0014,STR0001,STR0029+" "+STR0008,1,1) 					//17 "Compras" # "Informe de Libro de Compras Venezuela"
						oExcel:AddColumn(STR0014,STR0001,STR0008+" "+STR0016+" "+STR0030+" "+STR0048,1,1) 	//18 "Compras" # "Informe de Libro de Compras Venezuela"
						oExcel:AddColumn(STR0014,STR0001,STR0008+" "+STR0016+" "+STR0049,1,1) 			//19 "Compras" # "Informe de Libro de Compras Venezuela" "IVA" "Retenido" "a Terc.)"

						
				Else
					    oExcel:AddRow(STR0014,STR0001,aExcel[nloop])//  "Compras"    "Informe de Libro de Compras Venezuela"
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  FCABLVC       ºAutor  ³ Felipe C. Seolin     ³ Data ³23/08/10 ³º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria cabeçalho para relatório de Compras.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Parametros³ llCol : Imprime cabaçalho ou não                             ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFIS                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
	opPrn:Say(nlLin,0050,STR0002 + SM0->M0_CGC,olFont3) //"R.I.F.: "
	nlLin += 100
	opPrn:Say(nlLin,0050,STR0003 + SM0->M0_ENDCOB + SM0->M0_CIDCOB,olFont3)  //"Direccion Fiscal: "
	nlLin += 100
	opPrn:Say(nlLin,1050,STR0004,olFont2) //"Libro de Compras"
	nlLin += 50
	opPrn:Say(nlLin,1050,STR0005 + MesExtenso(Month(dFecIni)) + STR0006 + AllTrim(Str(Ano(dFecIni))),olFont3) //"Mes de " ## " Ano "
	nlLin += 150
	If llCol
		opPrn:FillRect({nlLin - 150,2435,nlLin,2950},olBrush)
		opPrn:Box(nlLin - 150,2435,nlLin,2950)
		opPrn:Say(nlLin - 100,2450,STR0032,olFont2)
		opPrn:Say(nlLin - 50,2450,STR0065,olFont2)	
		opPrn:FillRect({nlLin,0050,nlLin + 200,3390},olBrush)
		opPrn:Box(nlLin,0050,nlLin + 200,3390)
		opPrn:Line(nlLin,0135,nlLin + 200,0135)
		opPrn:Line(nlLin,0285,nlLin + 200,0285)
		opPrn:Line(nlLin,0465,nlLin + 200,0465)
		opPrn:Line(nlLin,0740,nlLin + 200,0740)
		opPrn:Line(nlLin,0815,nlLin + 200,0815)
		opPrn:Line(nlLin,1000,nlLin + 200,1000)
		opPrn:Line(nlLin,1070,nlLin + 200,1070)
		opPrn:Line(nlLin,1160,nlLin + 200,1160)
		opPrn:Line(nlLin,1265,nlLin + 200,1265)
		opPrn:Line(nlLin,1435,nlLin + 200,1435)
		opPrn:Line(nlLin,1578,nlLin + 200,1578)
		opPrn:Line(nlLin,1740,nlLin + 200,1740)
		opPrn:Line(nlLin,1930,nlLin + 200,1930)
		opPrn:Line(nlLin,1995,nlLin + 200,1995)
		opPrn:Line(nlLin,2125,nlLin + 200,2125)
		opPrn:Line(nlLin,2295,nlLin + 200,2295)
		opPrn:Line(nlLin,2435,nlLin + 200,2435)
		opPrn:Line(nlLin,2660,nlLin + 200,2660)
		opPrn:Line(nlLin,2760,nlLin + 200,2760)
		opPrn:Line(nlLin,2950,nlLin + 200,2950)
		opPrn:Line(nlLin,3120,nlLin + 200,3120)
		opPrn:Line(nlLin,3220,nlLin + 200,3220)
		opPrn:Line(nlLin,3320,nlLin + 200,3320)
		opPrn:Say(nlLin,2140,STR0007,olFont2) //"Total"
		opPrn:Say(nlLin,2300,STR0014,olFont2)//"Compras"
		opPrn:Say(nlLin,2960,STR0008,olFont2)//"IVA"
		nlLin += 50
		opPrn:Say(nlLin,0145,STR0009,olFont2)// "Fecha"
		opPrn:Say(nlLin,1005,STR0010,olFont2)//"Num"
		opPrn:Say(nlLin,1075,STR0010,olFont2)//"Num"
		opPrn:Say(nlLin,1935,STR0012,olFont2)//"Tipo"
		opPrn:Say(nlLin,2000,STR0013,olFont2)//"Numero"
		opPrn:Say(nlLin,2140,STR0014,olFont2)//"Compras"
		opPrn:Say(nlLin,2300,STR0015,olFont2)//"sin"
		opPrn:Say(nlLin,2960,STR0016,olFont2)//"Retenido"
		opPrn:Say(nlLin,3130,STR0008,olFont2)//"IVA"
		opPrn:Say(nlLin,3230,STR0017,olFont2)//"Antic."
		opPrn:Say(nlLin,3330,STR0012,olFont2)//"Tipo"
		nlLin += 50
		opPrn:Say(nlLin,0060,STR0018,olFont2)//"Oper"
		opPrn:Say(nlLin,0145,STR0019,olFont2)//"de"
		opPrn:Say(nlLin,0470,STR0011,olFont2)//"Nombre o"
		opPrn:Say(nlLin,0750,STR0012,olFont2)//"Tipo"
		opPrn:Say(nlLin,0825,STR0013,olFont2)// "Numero"
		opPrn:Say(nlLin,1005,STR0020,olFont2)//"Plan."
		opPrn:Say(nlLin,1075,STR0021,olFont2)//"Exped."
		opPrn:Say(nlLin,1165,STR0009,olFont2)//"Fecha"
		opPrn:Say(nlLin,1440,STR0022,olFont2)// "Nº Control"
		opPrn:Say(nlLin,1290,STR0013,olFont2)//"Numero"
		opPrn:Say(nlLin,1590,STR0013,olFont2)//"Numero"
		opPrn:Say(nlLin,1745,STR0013,olFont2)//"Numero"
		opPrn:Say(nlLin,1935,STR0023,olFont2)//"de"
		opPrn:Say(nlLin,2000,STR0024,olFont2)//"de Factura"
		opPrn:Say(nlLin,2140,STR0025,olFont2)//"Incluyendo"
		opPrn:Say(nlLin,2300,STR0026,olFont2)//"derecho a"
		opPrn:Say(nlLin,2440,STR0027,olFont2)//"Base"
		opPrn:Say(nlLin,2670,STR0028,olFont2)//"%"
		opPrn:Say(nlLin,2800,STR0029,olFont2)//"Impuesto"
		opPrn:Say(nlLin,2960,STR0030 ,olFont2)//"(al"
		opPrn:Say(nlLin,3130,STR0016,olFont2)//"Retenido"
		opPrn:Say(nlLin,3230,STR0031,olFont2)//"de IVA"
		opPrn:Say(nlLin,3330,STR0023,olFont2)//"de"
		nlLin += 50
		opPrn:Say(nlLin,0060,STR0033,olFont2)//"Nº"
		opPrn:Say(nlLin,0145,STR0034,olFont2)//"Factura"
		opPrn:Say(nlLin,0350,STR0035,olFont2)//"RIF"
		opPrn:Say(nlLin,0470,STR0036,olFont2)//"Razon Social"
		opPrn:Say(nlLin,0750,STR0037,olFont2)//"Prov."
		opPrn:Say(nlLin,0825,STR0038,olFont2)//"Comprobante"
		opPrn:Say(nlLin,1005,STR0039,olFont2)//"Imp."
		opPrn:Say(nlLin,1075,STR0039,olFont2)//"Imp."
		opPrn:Say(nlLin,1165,STR0040,olFont2)//"Import."
		opPrn:Say(nlLin,1285,STR0024,olFont2)//"de Factura"
		opPrn:Say(nlLin,1440,STR0024,olFont2)//"de Factura"
		opPrn:Say(nlLin,1590,STR0041,olFont2)//"ND"
		opPrn:Say(nlLin,1745,STR0042,olFont2)//"NC"
		opPrn:Say(nlLin,1935,STR0043,olFont2)//"Tran"
		opPrn:Say(nlLin,2000,STR0044,olFont2)//"Afectada"
		opPrn:Say(nlLin,2140,STR0045,olFont2)//"el IVA"
		opPrn:Say(nlLin,2300,STR0046,olFont2)// "Credito IVA"
		opPrn:Say(nlLin,2440,STR0029,olFont2)//"Impuesto"
		opPrn:Say(nlLin,2670,STR0047,olFont2)//"Alic."
		opPrn:Say(nlLin,2800,STR0008,olFont2)//"IVA"
		opPrn:Say(nlLin,2960,STR0048,olFont2)//"vendedor)"
		opPrn:Say(nlLin,3130,STR0049,olFont2)//"a Terc.)"
		opPrn:Say(nlLin,3230,STR0050,olFont2)//"(imp)"
		opPrn:Say(nlLin,3330,STR0051,olFont2)//"Con"
	EndIf
Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  FAliDir        ºAutor  ³ Felipe C. Seolin    ³ Data ³23/08/10 ³º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria máscara de acordo com o valor e alinhado à direita.     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Parametros³ nlVlr : Valor à ser alinhado                                 ³±±
±±³          ³ clPicture : Máscara do valor.                                ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Retorno   ³ clRet : Caracter alinhado à direita.                         ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFIS                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
±±ºPrograma  GetSFP        ºAutor  ³ Felipe C. Seolin     ³ Data ³10/08/10 ³º±±
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
±±ºUso       ³ VENRIVA.INI                                                  º±±
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
