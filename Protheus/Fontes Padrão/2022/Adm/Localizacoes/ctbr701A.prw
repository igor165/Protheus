#Include "ctbr701A.ch"
#Include "protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ CTBR701A	³ Autor ³ Marcelo Akama			³ Data ³ 17-09-2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Estado de Cambios en el Patrimonio Neto						³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico														³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³±±
±±³Programador ³Data    ³ BOPS     ³ Motivo da Alteracao                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³±±
±±³              ³        ³          ³                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function Ctbr701A()

Private cProg     := "CTBR701A"
Private cPerg     := "CTR701"
Private aItems    := {}
Private aSetOfBook:= {}
Private oReport
Private oSection1
Private oSection2
Private aColumnas :={}
Private aRet := {}
Private aCab:={}
Private aFieldSM0 := {"M0_NOME", "M0_FILIAL", "M0_CGC" , "M0_NOMECOM"}
Private aDatosEmp := IIf (cVersao <> "11" ,FWSM0Util():GetSM0Data(cEmpAnt, cFilAnt, aFieldSM0),"")

//Verifica si los informes personalizables están disponibles
If TRepInUse()
	If Pergunte(cPerg,.T.)
		oReport:=ReportDef()
		oReport:PrintDialog()
	EndIf
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡…o	 ³ ReportDef³ Autor ³ Marcelo Akama			 ³ Data ³ 17/09/10 ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡…o ³															   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Retorno	 ³ Nenhum													   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Parametros³ Nenhum													   ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function ReportDef()

Local cTitulo := STR0001 //"ESTADO DE CAMBIOS EN EL PATRIMONIO NETO"
Local cDescri := STR0002+Chr(10)+Chr(13)+STR0003 //"Este programa imprimira el Estado de Cambios en el Patrimonio Neto"##"Se imprimira de acuerdo con los Param. solicitados por el usuario."
Local bReport := { |oReport|	ReportPrint( oReport ) }

aSetOfBook:= CTBSetOf(mv_par04)

If ValType(mv_par08)=="N" .And. (mv_par08 == 1)
	cTitulo := CTBNomeVis( aSetOfBook[5] )
EndIf

oReport  := TReport():New(cProg, cTitulo, cPerg , bReport, cDescri,.T.,,.F.)
oReport:SetCustomText( {|| CustHeader(oReport, cTitulo, mv_par02, mv_par05) } )
oReport:ParamReadOnly()
oSection1:= TRSection():New(oReport  ,OemToAnsi(""),{"",""})
oSection2:= TRSection():New(oReport  ,OemToAnsi(""),{"",""})

oSection1:SetPageBreak(.F.)
oSection1:SetLineBreak(.F.)
oSection1:SetHeaderPage(.F.)
oSection1:SetTotalInLine(.F.)
oSection1:SetHeaderSection(.F.)
oSection2:SetHeaderSection(.F.)

Return oReport

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡…o	 ³ ReportPrint³ Autor ³ Marcelo Akama		 ³ Data ³ 17/09/10 ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡…o ³															   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Retorno	 ³ Nenhum													   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Parametros³ Nenhum													   ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportPrint(oReport)
Local x			:= 1
Local y			:= 1
Local cAlign
Local oFntReg
Local oFntBld

If (mv_par08 == 1)
	oReport:SetTitle( CTBNomeVis( aSetOfBook[5] ) )
EndIf  

If Empty(aSetOfBook[5])
	ApMsgAlert(STR0013) //"Plan de Gestión no asociado al libro. ¡Verifique la configuración elegida del libro! "
	Return .F.
Endif

aItems := CriaArray()

oFntReg := TFont():New(oReport:cFontBody,0,(oReport:nFontBody+2)*(-1),,.F.,,,,.F. /*Italic*/,.F. /*Underline*/)
oFntBld := TFont():New(oReport:cFontBody,0,(oReport:nFontBody+2)*(-1),,.T.,,,,.F. /*Italic*/,.F. /*Underline*/)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Crea la sección, el encabezado y el totalizador              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aItems) > 0
	For x:=1 To Len(aItems[1])
		nTam := 0
		cAlign := "LEFT"
		For y := 1 to Len(aItems)
			If ValType(aItems[y][x])=='N'
				cAlign := "RIGHT"
				If nTam < 35
					nTam := 35
				EndIf
			Else
				If nTam < Len(alltrim(aItems[y][x]))
					nTam := Len(alltrim(aItems[y][x]))
				EndIf
			EndIf
		Next y
		TRCell():New(oSection1,aItems[1][x],"",aItems[1][x],,nTam,.F.,,cAlign,.T.,cAlign,,,x>1/*AutoSize*/,CLR_WHITE,CLR_BLACK) 
		oSection1:Cell(oSection1:aCell[x]:cName):SetValue(alltrim(aItems[1][x]))
		oSection1:Cell(oSection1:aCell[x]:cName):oFontBody := oFntBld
	Next x
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Elimina la primera línea para no imprimir de nuevo como item ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aDel(aItems,1)
	aSize(aItems,Len(aItems)-1)
EndIf

TRCell():New(oSection2,"LEFT"    ,"","",,50,.F.,,"CENTER",,"CENTER",,,.T.)
TRCell():New(oSection2,"GERENTE" ,"","",,50,.F.,,"CENTER",,"CENTER")
TRCell():New(oSection2,"MID"     ,"","",,20,.F.,,"CENTER",,"CENTER")
TRCell():New(oSection2,"CONTADOR","","",,50,.F.,,"CENTER",,"CENTER")
TRCell():New(oSection2,"RIGHT"   ,"","",,50,.F.,,"CENTER",,"CENTER",,,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa la impresión                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:SetMeter(Len(aItems))
oSection1:Init()

oSection1:PrintLine()

oReport:ThinLine()

For x:=1 To Len(aItems)-1
	If oReport:Cancel()
		x:=Len(aItems)
	EndIf

	For y:=1 To Len(aItems[x])
		If ValType(aItems[x][y])='N'
			oSection1:Cell(oSection1:aCell[y]:cName):SetValue( ValorCTB(aItems[x][y],,,14,02,.T.,"@E 999,999,999.99","1",,,,,,mv_par06==1,.F.) )
		Else
			oSection1:Cell(oSection1:aCell[y]:cName):SetValue(alltrim(aItems[x][y]))
		EndIf
		If x = Len(aItems) .Or. (mv_par03==2 .And. x = 1 .And. y = 1) 
			oSection1:Cell(oSection1:aCell[y]:cName):oFontBody := oFntBld
		Else
			oSection1:Cell(oSection1:aCell[y]:cName):oFontBody := oFntReg
		EndIf
	Next y
	oSection1:PrintLine()
	oReport:IncMeter()
Next x     

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprimir mensaje si no hay registros para imprimir           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If Len(aItems) == 0
	oReport:PrintText(STR0004)//"No hay datos por mostrarse"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza la sección de impresión                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1:Finish()

oSection2:Cell("GERENTE"):SetValue(STR0011) // "GERENTE"
oSection2:Cell("GERENTE"):SetBorder("TOP")
oSection2:Cell("CONTADOR"):SetValue(STR0012) // "CONTADOR"
oSection2:Cell("CONTADOR"):SetBorder("TOP")
oReport:SkipLine(5)
oSection2:Init()
oSection2:PrintLine()
oSection2:Finish()

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡…o	 ³ CriaArray³ Autor ³ Marcelo Akama			 ³ Data ³ 20/09/10 ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡…o ³															   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Retorno	 ³ Nenhum                                                      ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Parametros³ Nenhum                                                      ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CriaArray()        
Local aArea		:= GetArea()
Local aAreaCTS	:= CTS->(GetArea())
Local nX		:= 0
Local nY		:= 0
Local nI
Local cTrim 	:= "%LTRIM%"
Local cIsNull 	:= '%COALESCE%'
Local nA 		:= 1
Local nPos 		:= 0
Local aSubT 	:= {}
Local nValor 	:= 0
Local aTotal 	:= {{}}
Local aTotalF 	:= {{}}
Local nTotal 	:= 0
Local cAliasQry := ""

If Alltrim(Upper(TcGetDB()))=='INFORMIX'
	cTrim := '%TRIM%"
EndIf

If Alltrim(Upper(TcGetDB()))=='ORACLE'
	cTrim := '%NVL%'
EndIf

dbSelectArea("CTS")
CTS->(DbSetOrder(1))
If CTS->(DbSeek(xFilial("CTS")+aSetOfBook[5]))
	Do While !CTS->(Eof())
		If  AScan(aCab, {|x| x[1] == CTS->CTS_CONTAG}) == 0 .And. CTS->CTS_CODPLA == aSetOfBook[5] 
			AADD(aCab, {CTS->CTS_CONTAG, CTS->CTS_DESCCG,CTS->CTS_CLASSE,CTS->CTS_IDENT,CTS_CTASUP})
		EndIf
		CTS->(DbSkip())
	Enddo
EndIf

cAliasqry := GetNextAlias()


BeginSql Alias cAliasQry

SELECT
	   CTS_CONTAG,
	   CT2_LP,
	   sum(VALOR) VALOR,
	   CTS_ORDEM, 
	   CTS_FORMUL 
	   
FROM (
		SELECT CTS.CTS_CONTAG, CT2.CT2_LP, CT2.CT2_VALOR*-1 VALOR ,CTS_ORDEM, CTS_FORMUL 
		
		FROM %table:CTS% CTS INNER JOIN %table:CT2% CT2 ON CT2.%NotDel%
			AND CT2.CT2_FILIAL = %xFilial:CT2%
			AND CT2.CT2_DATA between %Exp:DTOS(mv_par01)% AND %Exp:DTOS(mv_par02)%
			AND CT2.CT2_MOEDLC = %Exp:mv_par05%
			AND CT2.CT2_TPSALD = %Exp:mv_par07% 
			AND ltrim (CT2.CT2_LP) <> ''
			AND CT2.CT2_DC IN ('1','3')
			AND ( CT2.CT2_DEBITO between CTS.CTS_CT1INI and CTS.CTS_CT1FIM or %Exp:cTrim% (CTS.CTS_CT1FIM) = '' )
			AND ( CT2.CT2_CCD    between CTS.CTS_CTTINI and CTS.CTS_CTTFIM or %Exp:cTrim% (CTS.CTS_CTTFIM) = '' ) 
			AND ( CT2.CT2_ITEMD  between CTS.CTS_CTDINI and CTS.CTS_CTDFIM or %Exp:cTrim% (CTS.CTS_CTDFIM) = '' ) 
			AND ( CT2.CT2_CLVLDB between CTS.CTS_CTHINI and CTS.CTS_CTHFIM or %Exp:cTrim% (CTS.CTS_CTHFIM) = '' )
			
		WHERE CTS.%NotDel%
			AND CTS.CTS_FILIAL = %xFilial:CTS%
			AND CTS.CTS_CODPLA = %Exp:aSetOfBook[5]%
			AND CTS.CTS_CLASSE = '2'
			AND CTS_CONTAG BETWEEN '4D0201' AND '4D0299'
			
		UNION ALL
			SELECT CTS.CTS_CONTAG, CT2.CT2_LP, CT2.CT2_VALOR VALOR, CTS_ORDEM, CTS_FORMUL
			FROM %table:CTS% CTS
			INNER JOIN %table:CT2% CT2 ON CT2.%NotDel%
				AND CT2.CT2_FILIAL = %xFilial:CT2%
				AND CT2.CT2_DATA between %Exp:DTOS(mv_par01)% AND %Exp:DTOS(mv_par02)%
				AND CT2.CT2_MOEDLC = %Exp:mv_par05%
				AND CT2.CT2_TPSALD = %Exp:mv_par07% 
				AND ltrim (CT2.CT2_LP) <> ''
				AND CT2.CT2_DC IN ('2','3')
				AND ( CT2.CT2_CREDIT between CTS.CTS_CT1INI and CTS.CTS_CT1FIM or %Exp:cTrim% (CTS.CTS_CT1FIM) = '' )
				AND ( CT2.CT2_CCC    between CTS.CTS_CTTINI and CTS.CTS_CTTFIM or %Exp:cTrim% (CTS.CTS_CTTFIM) = '' )
				AND ( CT2.CT2_ITEMC  between CTS.CTS_CTDINI and CTS.CTS_CTDFIM or %Exp:cTrim% (CTS.CTS_CTDFIM) = '' )
				AND ( CT2.CT2_CLVLCR between CTS.CTS_CTHINI and CTS.CTS_CTHFIM or %Exp:cTrim% (CTS.CTS_CTHFIM) = '' )
			WHERE CTS.%NotDel%
				AND CTS.CTS_FILIAL = %xFilial:CTS%
				AND CTS.CTS_CODPLA = %Exp:aSetOfBook[5]%
				AND CTS.CTS_CLASSE = '2'
				AND CTS_CONTAG BETWEEN '4D0201' AND '4D0299'
				
		UNION ALL
			SELECT CTS.CTS_CONTAG, '' CT2_LP, %Exp:cIsNull% (CT2.CT2_VALOR,0)*-1 VALOR, CTS_ORDEM, CTS_FORMUL
			FROM %table:CTS% CTS
			LEFT OUTER JOIN %table:CT2% CT2 ON CT2.%NotDel%
				AND CT2.CT2_FILIAL = %xFilial:CT2%
				AND CT2.CT2_DATA between %Exp:DTOS(mv_par01)% AND %Exp:DTOS(mv_par02)%
				AND CT2.CT2_MOEDLC = %Exp:mv_par05%
				AND CT2.CT2_TPSALD = %Exp:mv_par07%
				AND LTRIM (CT2.CT2_LP) <> ''
				AND CT2.CT2_DC IN ('1','3')
				AND ( CT2.CT2_DEBITO between CTS.CTS_CT1INI and CTS.CTS_CT1FIM or %Exp:cTrim% (CTS.CTS_CT1FIM) = '' )
				AND ( CT2.CT2_CCD    between CTS.CTS_CTTINI and CTS.CTS_CTTFIM or %Exp:cTrim% (CTS.CTS_CTTFIM) = '' )
				AND ( CT2.CT2_ITEMD	between CTS.CTS_CTDINI and CTS.CTS_CTDFIM or %Exp:cTrim% (CTS.CTS_CTDFIM) = '' )
				AND ( CT2.CT2_CLVLDB between CTS.CTS_CTHINI and CTS.CTS_CTHFIM or %Exp:cTrim% (CTS.CTS_CTHFIM) = '' )
			WHERE CTS.%NotDel% AND CTS.CTS_FILIAL = %xFilial:CTS%
				AND CTS.CTS_CODPLA = %Exp:aSetOfBook[5]%
				AND CTS.CTS_CLASSE = '2'
				AND CTS_CONTAG BETWEEN '4D0101' AND '4D0199'
				
		UNION ALL	
			SELECT  CTS.CTS_CONTAG, '' CT2_LP, %Exp:cIsNull% (CT2.CT2_VALOR,0) VALOR , CTS_ORDEM, CTS_FORMUL
			FROM %table:CTS% CTS
			LEFT OUTER JOIN %table:CT2% CT2 ON CT2.%NotDel%
				AND CT2.CT2_FILIAL = %xFilial:CT2%
				AND CT2.CT2_DATA between %Exp:DTOS(mv_par01)% AND %Exp:DTOS(mv_par02)%
				AND CT2.CT2_MOEDLC = %Exp:mv_par05%
				AND CT2.CT2_TPSALD = %Exp:mv_par07%
				AND LTRIM (CT2.CT2_LP) <> ''
				AND CT2.CT2_DC IN ('2','3')
				AND ( CT2.CT2_CREDIT between CTS.CTS_CT1INI and CTS.CTS_CT1FIM or %Exp:cTrim% (CTS.CTS_CT1FIM) = '' )
				AND ( CT2.CT2_CCC    between CTS.CTS_CTTINI and CTS.CTS_CTTFIM or %Exp:cTrim% (CTS.CTS_CTTFIM) = '' )
				AND ( CT2.CT2_ITEMC  between CTS.CTS_CTDINI and CTS.CTS_CTDFIM or %Exp:cTrim% (CTS.CTS_CTDFIM) = '' )
				AND ( CT2.CT2_CLVLCR between CTS.CTS_CTHINI and CTS.CTS_CTHFIM or %Exp:cTrim% (CTS.CTS_CTHFIM) = '' )
			WHERE CTS.%NotDel% AND CTS.CTS_FILIAL = %xFilial:CTS%
				AND CTS.CTS_CODPLA = %Exp:aSetOfBook[5]%
				AND CTS.CTS_CLASSE = '2'
				AND CTS_CONTAG BETWEEN '4D0101' AND '4D0199'
				
				) A
				
				GROUP BY CT2_LP, CTS_ORDEM, CTS_CONTAG, CTS_FORMUL 
				ORDER BY CT2_LP, CTS_ORDEM, CTS_CONTAG, CTS_FORMUL 
				
EndSql


DbSelectArea(cAliasQry)

If !(cAliasQry)->(Eof())

	For nA := 1 to 11
		AADD(aRet, Array( len(aCab) + 2 ))
		nY := Len(aRet)
		For nX := 2 to Len(aRet[nY])
			aRet[nY][nX] := 0
		Next
	Next
	
	Do While !(cAliasQry)->(Eof())
		If AllTrim((cAliasQry)->CTS_FORMUL)!= ""
			nY := Val(ALLTRIM((cAliasQry)->CTS_FORMUL))
			nX := AScan(aCab, {|x| x[1] == (cAliasQry)->CTS_CONTAG})
			If nX > 0 
				aRet[nY][nX+1] += (cAliasQry)->VALOR
				aRet[nY][len(aRet[nY])] += (cAliasQry)->VALOR
			EndIf
		Endif
	
	(cAliasQry)->(DbSkip())
	Enddo
	(cAliasQry)->(dbCloseArea())
	
	// Adiciona línea de Total
	AADD(aRet, Array( len(aCab) + 2 ))
	nY := Len(aRet)
	aRet[nY][1] := STR0024 //"Resultado Neto del Ejercicio"
	For nX := 2 to Len(aRet[nY])
		aRet[nY][nX] := 0
		For nI := 1 to nY-1
			aRet[nY][nX] += aRet[nI][nX]	
		Next
	Next


	// Adiciona encabezado
	AADD(aRet, nil)
	AINS(aRet, 1)
	aRet[1] := Array( len(aCab) + 2 )
	For nX := 1 to Len(aCab)
		aRet[1][nX+1] := aCab[nX][2]
		For nI := 2 to Len(aRet)
			If AllTrim(aCab[nX][3]) == "2" .And. AllTrim(aCab[nX][4]) == "5"
				aRet[nI][nX+1] := "" 
			EndIf
		Next 		
	Next
	
	For nI :=2 to nY
		aSubT:={}
		For nX:=2 to Len(aCab)
			If AllTrim(aCab[nX][3]) == "2" .And. AllTrim(aCab[nX][4]) != "5"
				//Sumarización a cuentas Superior
				nPos := AScan(aSubT, {|x| AllTrim(x[1]) == AllTrim(aCab[nX][5])})
				nValor := aRet[nI][nX+1]
				If nPos == 0 
					Aadd(aSubT,{AllTrim(aCab[nX][5]),nValor,AllTrim(aCab[nX][1])})
				Else
					aSubT[nPos][2] += nValor
				EndIf				
			Endif
		Next
		AADD(aTotal,aSubT)
	Next
	
	aColumnas := {STR0007,STR0014,STR0015,STR0016,STR0017,STR0018,STR0019,STR0020,STR0021,STR0022,STR0023,STR0024}
	For nY:=2 to Len(aColumnas)
		aRet[nY][1] := aColumnas[nY]
		//Acomoda Subtotales a Cuentas Superior
		For nPos :=1 to Len(aTotal[nY])
			nX := AScan(aCab, {|x| AllTrim(x[1]) == aTotal[nY][nPos][1]})
			If 	nX > 0
				aRet[nY][nX+1] := aTotal[nY][nPos][2]
			EndIf
		Next
	Next
	
	//Sumariza los Totales para cuentas tipo ident 3
	For nI :=2 to nY-1
		aSubT:={}
		For nX:=2 to Len(aCab)
			If AllTrim(aCab[nX][3]) == "1" .And. AllTrim(aCab[nX][4]) == "3"
				nPos := AScan(aSubT, {|x| AllTrim(x[1]) == AllTrim(aCab[nX][5])})
				nValor := aRet[nI][nX+1]
				If nPos == 0 
					Aadd(aSubT,{AllTrim(aCab[nX][5]),nValor,AllTrim(aCab[nX][1])})
				Else
				 	If AllTrim(aCab[nX][5])!= "" 
				 		aSubT[nPos][2] := aSubT[nPos][2] + nValor
					Else
						aSubT[nPos][2] += 0 
					EndIf
				EndIf	
			Endif
		Next
		AADD(aTotalF,aSubT)
	Next

   //Acomoda Totales a Cuentas Superior
	For nY:=2 to Len(aColumnas)
		For nPos :=1 to Len(aTotalF[nY])
			nX := AScan(aCab, {|x| AllTrim(x[1]) == aTotalF[nY][nPos][1]})
			If 	nX > 0
				aRet[nY][nX+1] := aTotalF[nY][nPos][2]
			EndIf
		Next
	Next
	
	//Actualiza columna 12 de las Cuentas Superior
	For nX:=2 to Len(aCab)
		If AllTrim(aCab[nX][3]) == "1" .And. AllTrim(aCab[nX][4]) == "3"
			nTotal:=0
			For nY:=2 to Len(aColumnas)
				If 	nY == Len(aColumnas)
					aRet[nY+1][nX+1] := nTotal
				Else
					nTotal := aRet[nY][nX+1] + nTotal
				EndIf
			Next
		Endif
	Next
	

	aRet[1][1] := aColumnas[1] // "Cuenta"
	aRet[1][len(aRet[1])] := STR0008 // "Total"

	If mv_par03==1
		aRet := PivotTable(aRet)
	EndIf
Else
	If Len(aCab) == 0
	ApMsgAlert(STR0014) //"Capital"
	EndIf
EndIf


RestArea(aAreaCTS)
RestArea(aArea)
If MV_PAR09 == 1           
	IF MSGYESNO(STR0025) //"¿Deseea generar archivo txt?"
	   Processa({|| GerArq(AllTrim(MV_PAR10),aRet,aCab)},,STR0026) // Generando archivo...
	Endif   
EndIf
Return(aRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡…o	 ³ CustHeader³ Autor ³ Marcelo Akama		 ³ Data ³ 22/09/10 ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡…o ³															   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Retorno	 ³ Nenhum                                                      ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Parametros³ Nenhum                                                      ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CustHeader(oReport, cTitulo, dData, cMoeda)
Local cChar		:= chr(160)  // carácter falso para la alineación del encabezado
Local cTitMoeda := Alltrim(GETMV("MV_MOEDAP"+Alltrim(Str(val(cMoeda)))))
Local cNmEmp	:= ""

DEFAULT dData    := cTod('  /  /  ')

If cVersao == "11"
	If SM0->(Eof())                                
		SM0->( MsSeek( cEmpAnt + cFilAnt , .T. ))
	Endif
	cNmEmp	:= AllTrim( SM0->M0_NOMECOM )
Else
	cNmEmp	:= aDatosEmp[4][2]
EndIf

RptFolha := GetNewPar( "MV_CTBPAG" , RptFolha )

aCabec := {	"__LOGOEMP__" + "         " + cChar + "         " + cNmEmp + "         " + cChar + "         " + RptFolha+ TRANSFORM(oReport:Page(),'999999'),; 
			"SIGA /" + cProg + "/v." + cVersao + "         " + cChar + AllTrim(cTitulo) + "         " + cChar + RptDtRef + " " + DTOC(dDataBase),;
			RptHora + " " + time() + cChar + "         " + STR0009 + " " + DTOC(dData) + "         " + cChar + RptEmiss + " " + Dtoc(date()),;
			cChar + "         " + "(" + STR0010 + " " + cTitMoeda + ")" + "         " + cChar }

Return aCabec


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao     ³ GerArq   ³ Autor ³ Véronica Flores     ³ Data ³ 10.05.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao  ³ 3.19 - LIBRO DE INVENTARIOS Y BALANCES                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³ cDir - Diretorio de criacao do arquivo.                    ³±±
±±³            ³ cArq - Nome do arquivo com extensao do arquivo.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno    ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³ Fiscal Peru                  - Arquivo Magnetico           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GerArq(cDir,aItems,aCab)

Local nHdl  	:= 0
Local cLin  	:= ""
Local cSep  	:= "|"
Local nCont 	:= 0
Local cArq  	:= ""
Local nMes 		:=  Month(MV_PAR02)
Local cDateFmt 	:= SET(_SET_DATEFORMAT)
Local nX
Local nY
Local cRUC	  	:= Trim(IIf (cVersao <> "11" ,aDatosEmp[3][2],SM0->M0_CGC))


FOR nCont:=LEN(ALLTRIM(cDir)) TO 1 STEP -1
	IF SUBSTR(cDir,nCont,1)=='\'
		cDir:=Substr(cDir,1,nCont)
		EXIT
	ENDIF	
NEXT
 
cArq += "LE"                                  // Fixo  'LE'
cArq +=  AllTrim(cRUC)                 // Ruc
cArq +=  AllTrim(Str(Year(MV_PAR02)))         // Ano
cArq +=  AllTrim(Strzero(Month(MV_PAR02),2))  // Mes
cArq +=  AllTrim(Strzero(Day(MV_PAR02),2))    // Dia
cArq += "031900" 						      // Fixo '031900'
                           
//Código de Oportunidad
If nMes == 12
	cArq += "01"	
ElseIf nMes == 1
	cArq += "02"
ElseIf nMes == 6
	cArq += "04"
Else
	cArq += "07"
EndIf                         
cArq += "1"
cArq += "1"
cArq += "1"
cArq += "1"
cArq += ".TXT" // Extensao

nHdl := fCreate(cDir+cArq)
If nHdl <= 0
	ApMsgStop(STR0027) //"No se pudo generar el archivo"
Else

	For nX:=2 To Len(aRet)-1
	    If  aCab[nX-1][4] != '5' 
		cLin := ""
		
		//01 - Periodo
		cLin += SubStr(DTOS(mv_par02),1,8)
		cLin += cSep
		
		//02 - Código del cátalogo
			cLin += "09"
			cLin += cSep
		
		//03 - Código Rubro Financiero
		cLin += AllTrim(aCab[nX-1][1])
		cLin += cSep
		
		For nY:=1 To Len(aRet[nX])
			nSubtotal := 0
			If ValType(aRet[nX][nY])='N'
				If nY == 11 //  Resultado Neto del Ejercicio 
					cLin += AllTrim(Transform(aRet[nX][13] - aRet[nX][11]   ,"@E 999999999.99"))
					cLin += cSep
				ElseIf nY == 12 // Excedente de Revaluación
					cLin += AllTrim(Transform(aRet[nX][nY-1],"@E 999999999.99"))
					cLin += cSep
				Else
					nSubtotal += aRet[nX][nY]
					cLin += AllTrim(Transform(aRet[nX][nY],"@E 999999999.99"))
					cLin += cSep
				EndIf
			EndIf
		Next nY
		
		//14- Indica el Estado de Operación
		cLin += "1"	
		cLin += cSep
		cLin += chr(13)+chr(10)
		
		fWrite(nHdl,cLin)
		EndIf
	Next nX    
	SET(_SET_DATEFORMAT,cDateFmt)
	fClose(nHdl)
	MsgAlert(STR0028) //"Archivo generado correctamente"
	
EndIf

Return Nil

