#Include "ctbr700.ch"
#Include "Protheus.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡…o	 ³ Ctbr700  ³ Autor ³ Felipe Aurélio de Melo ³ Data ³ 17.12.08 ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡…o ³                                                             ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Retorno	 ³ Nenhum                                                      ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Parametros³ Nenhum                                                      ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctbr700A()

Private cProg     := "CTBR700A"
Private cPerg     := "CTR700"
Private aRetor    := {}
Private aEstru    := {}
Private aItens    := {}
Private aCtbMoeda := {}
Private aSetOfBook:= {}
Private oReport
Private oSection1
Private oSection2
Private cRetSX5SL := ""
Private NomeProg := cProg
Private dFechaFin := CtoD("")

Pergunte(cPerg,.T.)
oReport:=ReportDef()
oReport:PrintDialog()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡…o	 ³ ReportDef³ Autor ³ Felipe Aurélio de Melo ³ Data ³ 18.12.08 ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡…o ³                                                             ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Retorno	 ³ Nenhum                                                      ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Parametros³ Nenhum                                                      ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function ReportDef()

Local aSelFil := {}
Local aOrd    := {STR0001,STR0002,STR0003}//"Padrao"###"Crescente"###"Decrescente"
Local cTitulo := STR0004//"DEMONSTRATIVO GERENCIAL MODELO 2"
Local cDescri := STR0005+Chr(10)+Chr(13)+STR0006//"Este programa ira imprimir o Demonstrativo Gerencial Modelo 2"##"Será impresso de acordo com os parametros solicitados pelo usuario."
Local bReport := { |oReport|	ReportPrint( oReport, aSelFil ) }

Local aSetOfBook:= CTBSetOf(mv_par07)

If !Empty(MV_PAR18) .And. (mv_par18 == 1) .And. (Len( aSelFil ) <= 0)
	aSelFil := AdmGetFil()
EndIf

If ValType(mv_par17)=="N" .And. (mv_par17 == 1)
	cTitulo := CTBNomeVis( aSetOfBook[5] )
EndIf

oReport  	:= TReport():New(cProg, cTitulo, cPerg , bReport, cDescri,.T.,,.F.)
oReport		:SetCustomText( {|| CtCGCCabTR(,,,,,dDataBase,cTitulo,,,,,oReport,,,,,,,,,,dFechaFin) } )
oReport		:ParamReadOnly()
oSection1	:= TRSection():New(oReport  ,OemToAnsi(""),{"",""},aOrd)
oSection2	:= TRSection():New(oReport  ,OemToAnsi(""),{"",""},aOrd)

oSection1:SetPageBreak(.F.)
oSection1:SetLineBreak(.F.)
oSection1:SetHeaderPage(.F.)
oSection1:SetTotalInLine(.F.)
oSection1:SetHeaderSection(.F.)

Return oReport

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡…o	 ³ ReportDef³ Autor ³ Felipe Aurélio de Melo ³ Data ³ 18.12.08 ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡…o ³                                                             ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Retorno	 ³ Nenhum                                                      ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Parametros³ Nenhum                                                      ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function ReportPrint(oReport,aSelFil)

Local x         := 1
Local y         := 1
Local nTot      := 0
Local nOrdRpt   := 0
Local nPosCbc   := 0
Local cValCtb   := ""
Local lPTable   := mv_par03 == 1
Local lTotLin   := mv_par16 == 1
Local lSldZro   := mv_par11 == 1
Local aMeses    := {OemToAnsi(STR0043),OemToAnsi(STR0044),OemToAnsi(STR0045),OemToAnsi(STR0046),OemToAnsi(STR0047),OemToAnsi(STR0048),;  //"Jan"###"Fev"###"Mar"###"Abr"###"Mai"###"Jun"
                    OemToAnsi(STR0049),OemToAnsi(STR0050),OemToAnsi(STR0051),OemToAnsi(STR0052),OemToAnsi(STR0053),OemToAnsi(STR0054)}
Local nMes		:= 0
Local nMesPos	:= 0
Local cMes		:= ""
local cAno		:= ""
Local nPeriodo 	:= 0
Local nItens	:= 0

Local lColDbCr		:= .T.
Local lCharSinal	:= .F.
Default aSelFil := {}
Private aFechas := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define tamanho da fonte de acordo com a quantidade de colunas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (MV_PAR05) > 0 .And. (MV_PAR05) <= 6
	oReport:nFontBody := 8
ElseIf (MV_PAR05) >= 7 .And. (MV_PAR05) <= 09
	oReport:nFontBody := 6
Else
	oReport:nFontBody := 6
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Realiza validações dos parametros preenchidos e Cria TRB     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !VldPerg()
	Return(.F.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava registros do arquivo temporário num array              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aRetor := CriarArray(aSelFil)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Llena arreglos con rubros solo de totales                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lPTable
	// Renglones: Periodos, Columnas: Rubros(solo totales)
	aItens := Array( Len(aRetor[1]) , 0 )
	For x := 1 To Len(aRetor[1][1])
		If x == 1 .Or. (AllTrim(aRetor[2][x][3]) $ "|3|4|")
			For y := 1 To Len(aRetor[1])
				aAdd( aItens[y] , aRetor[1][y][x] )
			Next y
		EndIf
	Next x

	For x := 1 To Len(aRetor[2])
		If x == 1 .Or. (AllTrim(aRetor[2][x][3]) $ "|3|4|")
			aAdd( aEstru , aRetor[2][x] )
		EndIf
	Next x

Else
	// Renglones: Rubros(solo totales), Columnas: Periodos
	For x := 1 To Len(aRetor[1])
		If x == 1 .Or. (AllTrim(aRetor[2][x][3]) $ "|3|4|")
			aAdd( aItens , aRetor[1][x] )
			aAdd( aEstru , aRetor[2][x] )
		EndIf
	Next x

EndIf

If Len(aItens) > 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existe mais que 13 colunas e exclui caso exista  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For x:=1 To Len(aItens)
		If Len(aItens[x]) > 13
			aItens[x] := aSize(aItens[x],13)
		Else
			x := Len(aItens)
		EndIf
	Next x

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria mais uma coluna e totaliza por linha                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lTotLin
		For x:=1 To Len(aItens)
			aItens[x] := aSize(aItens[x],len(aItens[x])+1)
			If x == 1
				If lPTable
					aItens[x][Len(aItens[x])] := STR0007//"TOTAL POR LINHA"
				Else
					aItens[x][Len(aItens[x])] := STR0008//"TOTAIS"
				EndIf
			Else
				nTot := 0
				For y:=2 To Len(aItens[x])-1
					nTot += aItens[x][y]
				Next y
				aItens[x][Len(aItens[x])] := nTot
			EndIf
		Next x
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria seção, cabeçalho e totalizador                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	/*Alterando colunas do relatório(meses), para que as mesmas sejam apresentadas por extenso*/

	aItens[1][1] := (STR0055) // Atribui a primeira coluna o STR0055(CONSUMO EN LA PRODUCCION)

	nPeriodo:= CTB700PER()

	If Len(aItens) > 0
		If lPTable
			nItens	:= Len(aItens)
		Else
			nItens	:= Len(aItens[1])
		Endif

		If nItens > 13
			nItens	:= 13
		Endif

		nItens := Min(nItens, nPeriodo+1)

		For x := 1 To nItens
			If lPTable
				If x <= nPeriodo+1
					nMes 	:= Val(substring(aItens[x][1],6,2))
				Else
					nMes	:= nMesPos
				Endif

				nMesPos := nMes + 1
			Else
				If x <= nPeriodo+1
					nMes 	:= Val(substring(aItens[1][x],6,2))
				Else
					nMes	:= nMesPos
				Endif

				nMesPos	:= nMes + 1
			Endif

			If nMes > 0
				If  nPeriodo == 4 // calendario trimestral
				  	If MV_PAR04 == 2
				  		nMes := nMes
				  	Else
						nMes := if(nMes==1,3,nMes)
						nMes := if(nMes==4,6,nMes)
						nMes := if(nMes==7,9,nMes)
						nMes := if(nMes==10,12,nMes)
					Endif

				ElseIf nPeriodo == 6 // calendario bimestral
					If MV_PAR04 == 2
				  		nMes := nMes
				  	Else
						nMes := if(nMes==1,2,nMes)
						nMes := if(nMes==3,4,nMes)
						nMes := if(nMes==5,6,nMes)
						nMes := if(nMes==7,8,nMes)
						nMes := if(nMes==9,10,nMes)
						nMes := if(nMes==11,12,nMes)
					Endif
				Endif

				If lTotLin
					If x > 1 .and. (x <= Len(aItens) .or. x <= Len(aItens[1])-1 )
						cMes    := 	Substring(aMeses[nMes],1,3)
						If lPTable
							cAno			:= 	Substring(aItens[x][1],1,4)
							aItens[x][1] 	:= cMes+"/"+cAno
						Else
							cAno			:= 	Substring(aItens[1][x],1,4)
							aItens[1][x] 	:= cMes+"/"+cAno
						Endif
						aAdd( aFechas , cAno + StrZero(nMes,2) + "00" )
					Endif
				Else
					If x > 1 .and. (x <= Len(aItens) .or. x <= Len(aItens[1]) )
						cMes    := 	Substring(aMeses[nMes],1,3)
						If lPTable
							cAno			:= 	Substring(aItens[x][1],1,4)
							aItens[x][1] 	:= cMes+"/"+cAno
						Else
							cAno			:= 	Substring(aItens[1][x],1,4)
							aItens[1][x] 	:= cMes+"/"+cAno
						Endif
						aAdd( aFechas , cAno + StrZero(nMes,2) + "00" )
					Endif
				Endif
			Endif
		Next x
	EndIf

	For x:=1 To Len(aItens[1])
		If x == 1
			If lPTable
				TRCell():New(oSection1,aItens[1][x],"",Ctr700Qbr(aItens[1][x],17,3,.T.),,,,,"LEFT",,"LEFT",,,.T.,CLR_WHITE,CLR_BLACK)
				TRCell():New(oSection2,aItens[1][x],"",Ctr700Qbr(aItens[1][x],17,3,.T.),,,,,"LEFT",,"LEFT",,,.T.,CLR_WHITE,CLR_BLACK)
			Else
				TRCell():New(oSection1,aItens[1][x],"",aItens[1][x],,20,,,"LEFT",,"LEFT",,,,CLR_WHITE,CLR_BLACK)
				TRCell():New(oSection2,aItens[1][x],"",aItens[1][x],,20,,,"LEFT",,"LEFT",,,,CLR_WHITE,CLR_BLACK)
			EndIf
		Else
			If lPTable
				If x <= Len(aEstru) .And. !(AllTrim(aEstru[x][3]) $ "|3|4|")
					Loop
				EndIf
				TRCell():New(oSection1,aItens[1][x],"",Ctr700Qbr(aItens[1][x],17,3,.T.),/*"@E 999,999,999.99"*/,,,,"RIGHT",,"RIGHT",,,.T.,CLR_WHITE,CLR_BLACK)
				TRCell():New(oSection2,aItens[1][x],"",Ctr700Qbr(aItens[1][x],17,3,.T.),/*"@E 999,999,999.99"*/,,,,"RIGHT",,"RIGHT",,,.T.,CLR_WHITE,CLR_BLACK)
			Else
				TRCell():New(oSection1,aItens[1][x],"",aItens[1][x],/*"@E 999,999,999.99"*/,20,,,"RIGHT",,"RIGHT",,,.T.,CLR_WHITE,CLR_BLACK)
				TRCell():New(oSection2,aItens[1][x],"",aItens[1][x],/*"@E 999,999,999.99"*/,20,,,"RIGHT",,"RIGHT",,,.T.,CLR_WHITE,CLR_BLACK)
			EndIf
		EndIf
	Next x

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Remove primeira linha para não imprimir novamente como item  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aDel(aItens,1)
	aSize(aItens,Len(aItens)-1)

	aDel(aEstru,1)
	aSize(aEstru,Len(aEstru)-1)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ordena registros conforme definição do parametro do TReport  ³
	//³ 1=Padrão, 2=Crescente, 3=Decrescente                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nOrdRpt := oSection1:GetOrder()
	Do Case
		Case nOrdRpt == 2
			aSort(aItens,,,{|x,y| x[1] < y[1]})
		Case nOrdRpt == 3
			aSort(aItens,,,{|x,y| x[1] > y[1]})
	EndCase

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa impressão                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:SetMeter(Len(aItens))
	oSection1:Init()
	oSection2:Init()

	//Retirar Negrito
	oSection1:oReport:lBold     := .F.
	oSection1:oReport:oFontBody := TFont():New(oSection1:oReport:cFontBody,0,(oSection2:oReport:nFontBody+2)*(-1),,oSection1:oReport:lBold,,,,oSection1:oReport:lItalic,oSection1:oReport:lUnderline)

	// Primer linea de impresion, para generar el encabezado ejecuta CTBXREL -> CtCGCCabTR() para formato especifico
	// suponer que se ejecuta la rutina base CTBR700; solo para generar el encabezado
	SetFunName("CTBR700")
	oSection1:PrintLine()
	SetFunName("CTBR700A")

	//Deixar Negrito
	oSection2:oReport:lBold     := .T.
	oSection2:oReport:oFontBody := TFont():New(oSection2:oReport:cFontBody,0,(oSection2:oReport:nFontBody+2)*(-1),,oSection2:oReport:lBold,,,,oSection2:oReport:lItalic,oSection2:oReport:lUnderline)
	oSection2:PrintLine()

	For x:=1 To Len(aItens)
		If oReport:Cancel()
			x:=Len(aItens)
		EndIf

		If lPTable
			For y:=1 To Len(aItens[x])
				If y == 1
					//Imprime com negrito desativado
					oSection1:Cell(oSection1:aCell[y]:cName):SetValue(aItens[x][y])
				Else
					If !(AllTrim(aEstru[y-1][3]) $ "|3|4|")
						Loop
					EndIf

					//Imprime com negrito desativado
					nPosCbc := aScan(aEstru,{|x| Upper(Alltrim(x[1])) == Upper(AllTrim(oSection1:aCell[y]:cName))})
					If nPosCbc > 0
						cValCtb:=ValorCTB(aItens[x][y],,,14,02,.T.,"@E 99,999,999,999.99",aEstru[nPosCbc][4],,,,,,lSldZro,.F.,lColDbCr,lCharSinal)
					Else
						cValCtb:=ValorCTB(aItens[x][y],,,14,02,.T.,"@E 99,999,999,999.99","1",,,,,,lSldZro,.F.,lColDbCr,lCharSinal)
					EndIf
					oSection1:Cell(oSection1:aCell[y]:cName):SetValue(cValCtb)
				EndIf
			Next y
			oSection1:PrintLine()

		Else
			If !(AllTrim(aEstru[x][3]) $ "|3|4|")
				Loop
			EndIf

			For y:=1 To Len(aItens[x])

				//Alimenta as calulas da linha que será impressa
				Do Case
					Case AllTrim(aItens[x][1]) = "-"
						//Imprime uma linha a vai para o proximo registro a ser impresso
						oReport:ThinLine()
						oReport:SkipLine()
						y:=Len(aItens[x])

					Case AllTrim(aEstru[x][3]) < "5"
						If AllTrim(aEstru[x][3]) $ "|3|4|"
							If y == 1
								//Imprime com negrito ativado
								oSection2:Cell(oSection2:aCell[y]:cName):SetValue(aItens[x][y])
							Else
								//Imprime com negrito ativado
								cValCtb:=ValorCTB(aItens[x][y],,,14,02,.T.,"@E 99,999,999,999.99",aEstru[x][4],,,,,,lSldZro,.F.,lColDbCr,lCharSinal)
								oSection2:Cell(oSection2:aCell[y]:cName):SetValue(cValCtb)
							EndIf
						Else
							If y == 1
								//Imprime com negrito desativado
								oSection1:Cell(oSection1:aCell[y]:cName):SetValue(aItens[x][y])
							Else
								//Imprime com negrito desativado
								cValCtb:=ValorCTB(aItens[x][y],,,14,02,.T.,"@E 99,999,999,999.99",aEstru[x][4],,,,,,lSldZro,.F.,lColDbCr,lCharSinal)
								oSection1:Cell(oSection1:aCell[y]:cName):SetValue(cValCtb)
							EndIf
						EndIf
					Otherwise
						If y == 1
							//Imprime com negrito ativado
							oSection2:Cell(oSection2:aCell[y]:cName):SetValue(aItens[x][y])
						Else
							//Imprime nulo, logo não aparecerá valor na celula
							oSection2:Cell(oSection2:aCell[y]:cName):SetValue()
						EndIf
				EndCase
			Next y

			//Executa impressão da linha alimentada acima
			Do Case
				Case AllTrim(aItens[x][1]) = "-"
				//Não executa impressão da seção, pois foi
				//impresso pelo objeto principal

				Case AllTrim(aEstru[x][3]) < "5"
				//Executa impressão da seção em questão
					If AllTrim(aEstru[x][3]) $ "|3|4|"
						oSection2:PrintLine()
					Else
						oSection1:PrintLine()
					EndIf

				Otherwise
				//Executa impressão da seção em questão
					oSection2:PrintLine()
			EndCase

		EndIf

		oReport:IncMeter()
	Next x

	If MV_PAR19 == 1
		If MV_PAR03 == 1 .And. MV_PAR06 == 1 .AND. MV_PAR16 == 2
			If MSGYESNO(STR0056) // "¿Generar archivo TXT?"
				Processa({|| GerArq(AllTrim(MV_PAR20))},,STR0057) // "Archivo generado correctamente"
			EndIf
		Else
			If MSGYESNO(STR0056) // "¿Generar archivo TXT?"
				Alert(STR0058 + STR0059) // "Para la impresión del archivo TXT, las preguntas deben tener las siguientes configuraciones:" ## "Orientación de los períodos = En línea; Saldo del período = Mov. Período; Totalizar por línea = No"
			EndIf
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza seção de impressão                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSection1:Finish()
	oSection2:Finish()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime mensagem caso não tenha registros a serem impressos  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aItens) == 0
		oReport:PrintText(STR0009)//"Nao ha dados a serem exibidos"
	EndIf

EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ fTrataSlds³ Autor³ Felipe Aurelio de Melo³ Data ³ 14.10.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Tratamento do retorno do parametro                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ CTBR560R4                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGACTB                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function fTrataSlds()

Local cRet := ""

If mv_par13 = 1
	cRet := mv_par14
Else
	cRet := mv_par15
EndIf

Return(cRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡…o	 ³ CriarArray Autor ³ Felipe Aurélio de Melo ³ Data ³ 17.12.08 ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡…o ³                                                             ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Retorno	 ³ Nenhum                                                      ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Parametros³ Nenhum                                                      ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function CriarArray(aSelFil)

Local x       := 0
Local y       := 0
Local aRegs   := {}
Local aDtPer  := {}
Local lStsPrt := .T.
Local lPGSint := .T.
Local lImpMov := .T.
Local lSldZro := .T.
Local cSBook  := mv_par07
Local cMoeda  := mv_par08
Local cDscMd := IIf( Empty(mv_par12),mv_par08,mv_par12)
Local dDtIni  := StoD("")
Local dDtFim  := StoD("")
Local dDtLPs  := mv_par10
Local lPAntLP := mv_par09 == 1
Local lPTable := mv_par03 == 1
Local lMovPer := mv_par06 == 1
Local lConSld := mv_par13 == 1
Local cSaldos := fTrataSlds()

DEFAULT aSelFil := {}
//Deve usar calendario ou data de referencia
If mv_par04 == 1
	dbSelectArea("CTG")
	CTG->(DbSetOrder(1))
	If CTG->(DbSeek(xFilial("CTG")+mv_par01))
		While CTG->(!Eof() .And. xFilial("CTG")+mv_par01 = CTG_FILIAL+CTG_CALEND)
			If lPTable
				//Se tabela invertida não limitar quantidade de periodos
				aAdd(aDtPer,{CTG->CTG_DTINI,CTG->CTG_DTFIM})
			Else
				//Se tabela no formato original, não permitir mais que 12 colunas
				If Len(aDtPer) < 12
					aAdd(aDtPer,{CTG->CTG_DTINI,CTG->CTG_DTFIM})
				EndIf
			EndIf
			CTG->(DbSkip())
		End
	EndIf
Else
	For x:=0 To mv_par05-1
		dDtIni := FirstDay(mv_par02)
		dDtFim := LastDay(mv_par02)
		For y:=1 To x
			dDtIni := FirstDay(FirstDay(dDtIni)-1)
			dDtFim := LastDay(dDtIni)
		Next y

		If lPTable
			//Se tabela invertida não limitar quantidade de periodos
			aAdd(aDtPer,{dDtIni,dDtFim})
		Else
			//Se tabela no formato original, não permitir mais que 12 colunas
			If Len(aDtPer) < 12
				aAdd(aDtPer,{dDtIni,dDtFim})
			EndIf
		EndIf
	Next x
EndIf

//Ordenação crescente por padrão
aSort(aDtPer,,,{|x,y| x[1] < y[1]})

dFechaFin := aDtPer[Len(aDtPer)][2]

//Executa função conforme parametros
aRegs := GetSldVGerP(lStsPrt, oReport, aDtPer, lPTable, cSBook , cMoeda, cDscMd, lConSld, cSaldos, "", dDtLPs, lSldZro, lMovPer, lPGSint, lImpMov, lPAntLP, aSelFil)

Return(aRegs)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡…o	 ³ VldPerg  ³ Autor ³ Felipe Aurélio de Melo ³ Data ³ 18.12.08 ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡…o ³                                                             ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Retorno	 ³ Nenhum                                                      ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Parametros³ Nenhum                                                      ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function VldPerg()

Local x    :=  0
Local lRet := .T.

//Valida todos os parâmetros
For x:=1 To 16
	lRet := PrmCtbr700(StrZero(x,2),.T.)
	If !lRet
		x := 16
	EndIf
Next x

// Define nome do relatorio conforme cadastro do livros
If lRet
	oReport:SetTitle(aSetOfBook[10])
	If (mv_par17 == 1)
		oReport:SetTitle( CTBNomeVis( aSetOfBook[5] ) )
	EndIf
EndIf

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡…o	 ³ Ctr700Qbr³ Autor ³ Felipe Aurélio de Melo ³ Data ³ 17.12.08 ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡…o ³ Quebrar uma string em partes definidas via parametro        ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Retorno	 ³ cRet                                                        ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Parametros³ cStr = String que será quebrada com Chr(13)+Chr(10)         ³±
±±³Parametros³ nTam = Definição do tamanho da string por quebra            ³±
±±³Parametros³ nTol = Tolerancia para quebrar string quando achar espaço   ³±
±±³Parametros³ lSpc = Quebrar string quando achar espaço                   ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Ctr700Qbr(cStr,nTam,nTol,lSpc)

Local x      :=  0
Local nCnt   :=  0
Local cRet   := ""
Default cStr := ""
Default nTol :=  0
Default lSpc := .F.
Default nTam := Len(AllTrim(cStr))/2

cStr := AllTrim(cStr)

For x:=1 To Len(cStr)
	nCnt ++
	cRet += SubStr(cStr,x,1)
	Do Case
		Case  lSpc .And. nTol  = 0
			//Quebrar quando achar espeço só
			//funcionará quando informado tolerancia

		Case  lSpc .And. nTol != 0
			If nCnt >= nTam-nTol .And. nCnt <= nTam+nTol .And. SubStr(cStr,x,1) = " "
				nCnt := 0
				cRet += Chr(13)+Chr(10)
			ElseIf nTam+nTol = nCnt
				nCnt := 0
				cRet += Chr(13)+Chr(10)
			EndIf

		Case !lSpc .And. nCnt = nTam
			nCnt := 0
			cRet += Chr(13)+Chr(10)
	EndCase
Next x

Return(cRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao     ³ GerArq                                 ³ Data ³ 15.04.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao  ³ Gera o arquivo magnético                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³ cDir - Diretorio de criacao do arquivo.                    ³±±
±±³            ³ cArq - Nome do arquivo com extensao do arquivo.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno    ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³10.2 REGISTRO DE COSTOS - ELEMENTOS DEL COSTO MENSUAL        ±±
±±³            ³                                                             ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GerArq(cDir)

Local nHdl  := 0
Local cLin  := ""
Local cSep  := "|"
Local cArq  := ""
Local nCont := 0
Local X     := 1
Local Y     := 1
Local cValor		:= ""
Local lPTable		:= (mv_par03 == 1)
Local lTotLin		:= (mv_par16 == 1)


cArq += "LE"                          // Fixo  'LE'
cArq +=  AllTrim(SM0->M0_CGC)         // Ruc
cArq +=  StrZero(Year(dFechaFin),4)   // Ano
cArq += "00"                          // Mes
cArq += "00"                          // Fixo '00'
cArq += "100200"                      // Fixo '100200'
cArq += "00"                          // Fixo '00'
cArq += "1"
cArq += "1"
cArq += "1"
cArq += "1"
cArq += ".TXT" // Extensao

For nCont := Len(Alltrim(cDir)) To 1 Step -1
   If Substr(cDir,nCont,1) == '\'
      cDir := Substr(cDir,1,nCont)
      Exit
   EndIf
Next

nHdl := fCreate(cDir+cArq)

If nHdl <= 0
	ApMsgStop(STR0060) //"Error al Crear Archivo TXT."

Else
	If lPTable
		// aItens[x][1]					- Periodo
		// aItens[x][y]					- Movimiento/Saldo de cada rubro
		// aItens[x][Len(aItens[x])]	- Total periodo (mv_par16 == 1)
		// aEstru[y][1]					- _DESCCG
		// aEstru[y][2]					- _CLASSE; 1-Sintetica, 2-Analitica
		// aEstru[y][3]					- _IDENT; 1,2,3,4,5,...
		// aEstru[y][4]					- _NORMAL; 1-Debito, 2-Credito

		For X := 1 To Len(aItens)
			cLin := ""

			For Y := 2 To Len(aItens[X])
				If Y == Len(aItens[X]) .And. lTotLin
					// Columna de totales
					Loop
				EndIf

				If !(AllTrim(aEstru[Y-1][3]) $ "|3|4|")
					Loop
				EndIf

				//02 a 07 - Saldos
				cValor := AllTrim(Transform(aItens[X][Y],"@E 999999999999.99"))
				cLin += lTrim(cValor) + cSep
			Next Y

			If !Empty(cLin)
				//01 - Periodo
				cLin := aFechas[X] + cSep + cLin

				//08 - Estado operación
				cLin += "1"
				cLin += cSep

				cLin += CRLF
				fWrite(nHdl,cLin)
			EndIf
		Next X

	Else
		// aItens[y][1]					- Descripcion
		// aItens[y][x]					- Movimiento/Saldo de cada periodo
		// aItens[y][Len(aItens[x])]	- Total rubro (mv_par16 == 1)
		// aEstru[x][1]					- _DESCCG
		// aEstru[x][2]					- _CLASSE; 1-Sintetica, 2-Analitica
		// aEstru[x][3]					- _IDENT; 1,2,3,4,5,...
		// aEstru[x][4]					- _NORMAL; 1-Debito, 2-Credito

		For Y := 2 To Len(aItens[1])
			If Y == Len(aItens[1]) .And. lTotLin
				// Columna de totales
				Loop
			EndIf

			cLin := ""

			//01 - Periodo
			cLin += aFechas[Y-1]
			cLin += cSep

			For X := 1 To Len(aItens)
				If !(AllTrim(aEstru[X][3]) $ "|3|4|")
					Loop
				EndIf

				//02 a 07 
				cValor := AllTrim(Transform(aItens[X][Y],"@E 999999999999.99"))
				cLin += lTrim(cValor) + cSep
			Next X

			//08 - Estado operación
			cLin += "1"
			cLin += cSep

			cLin += CRLF
			fWrite(nHdl,cLin)
		Next Y

	EndIf

	fClose(nHdl)
	MsgAlert(STR0061) //"Archivo TXT generado con éxito."

EndIf

Return Nil

/*/{Protheus.doc} CTB700PER
//Query al calendario (CTG) para extraer la cantidad de periodos del calendario.

@author arodriguez
@since 28/04/2020
@version 1.0

@return nPeri // numero de periodos existentes en el calendario.
/*/



STATIC FUNCTION CTB700PER()
// Verifica o tipo de calendário CAMPO PERIODO
// 4  = Trimestral
// 6  = Bimestral
// 12 = Anual


Local cAliasqry	:= ""
Local aArea	   	:= GetArea()
Local nPeri 	:= 0

	cAliasqry := GetNextAlias()
	
	BeginSql Alias cAliasqry
		
		SELECT COUNT(*) AS PERIODO
		FROM %table:CTG% CTG 
		WHERE	CTG_FILIAL = (%exp:xFilial('CTG')%)
		AND	CTG_CALEND = (%exp:mv_par01%)
		AND	CTG.%notDel%
		
	EndSql

	dbSelectArea(cAliasqry)
	(cAliasqry)->(dbGotop())

	If (cAliasqry)->(!Eof())
		nPeri:=(cAliasqry)->PERIODO
	EndIf
	
	(cAliasqry)->(DBCloseArea())
	RestArea(aArea)
	
Return(nPeri)
