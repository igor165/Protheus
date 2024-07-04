// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 07     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#Include "Protheus.ch"
#Include "VEIVC150.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ VEIVC150 ³ Autor ³ Thiago Aprile             ³ Data ³ 20/11/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Consulta Situacao dos Veiculos                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIVC150()
#IFDEF TOP
	Local ni := 0
	Local aSM0     := {}
	Private nQtdVir := 0
	Private nQtdEst := 0
	Private nQtdVen := 0
	Private nQtdTrt := 0
	Private nQtdRem := 0
	Private nQtdCom := 0
	Private nQtdTra := 0
	Private nQtdRes := 0
	Private lImprimir := .t.
	Private aQtds   := {}
	Private cCodMar := space(len(VV1->VV1_CODMAR))
	Private cGruVei := space(len(VV2->VV2_GRUMOD))
	Private cModVei := space(len(VV1->VV1_MODVEI))
	aSM0 := FWArrFilAtu(cEmpAnt,cFilAnt) // Filial Origem (Filial logada)
	If !FS_VERBASE() // Verifica a existencia dos arquivos envolvidos na Consulta
		MsgAlert(STR0004+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0006+" "+aSM0[1],STR0005 )
		Return
	EndIf
	FS_LEVANT(0)
	DEFINE MSDIALOG oAvaVei FROM 000,000 TO 030,100 TITLE (STR0001+" - "+Alltrim(aSM0[7])) OF oMainWnd
	@ 217,003 SAY STR0010 SIZE 25,06 OF oAvaVei PIXEL COLOR CLR_RED	//Virtual:
	@ 217,027 SAY nQtdVir SIZE 25,06 OF oAvaVei PIXEL COLOR CLR_BLUE
	@ 217,043 SAY STR0011 SIZE 25,06 OF oAvaVei PIXEL COLOR CLR_RED	//Estoque:
	@ 217,070 SAY nQtdEst SIZE 25,06 OF oAvaVei PIXEL COLOR CLR_BLUE
	@ 217,087 SAY STR0012 SIZE 25,06 OF oAvaVei PIXEL COLOR CLR_RED	//Vendido:
	@ 217,114 SAY nQtdVen SIZE 25,06 OF oAvaVei PIXEL COLOR CLR_BLUE
	@ 217,130 SAY STR0013 SIZE 30,06 OF oAvaVei PIXEL COLOR CLR_RED	//Em transito:
	@ 217,161 SAY nQtdTrt SIZE 25,06 OF oAvaVei PIXEL COLOR CLR_BLUE
	@ 217,173 SAY STR0014 SIZE 25,06 OF oAvaVei PIXEL COLOR CLR_RED	//Remessa:
	@ 217,203 SAY nQtdRem SIZE 25,06 OF oAvaVei PIXEL COLOR CLR_BLUE
	@ 217,219 SAY STR0015 SIZE 30,06 OF oAvaVei PIXEL COLOR CLR_RED	//Consignado:
	@ 217,252 SAY nQtdCom SIZE 25,06 OF oAvaVei PIXEL COLOR CLR_BLUE
	@ 217,266 SAY STR0016 SIZE 30,06 OF oAvaVei PIXEL COLOR CLR_RED	//Transferido:
	@ 217,299 SAY nQtdTra SIZE 25,06 OF oAvaVei PIXEL COLOR CLR_BLUE
	@ 217,322 SAY STR0017 SIZE 30,06 OF oAvaVei PIXEL COLOR CLR_RED	//Reservado:
	@ 217,352 SAY nQtdRes SIZE 25,06 OF oAvaVei PIXEL COLOR CLR_BLUE
	@ 017,001 LISTBOX oLbQtds FIELDS HEADER OemToAnsi(STR0018),OemToAnsi(STR0019) COLSIZES 30,250 SIZE 394,195 OF oAvaVei PIXEL	//Qtdade # Marca/Modelo
	oLbQtds:SetArray(aQtds)
	oLbQtds:bLine := { || {FG_AlinVlrs(Transform(aQtds[oLbQtds:nAt,3],"@E 999,999,999")),substr(aQtds[oLbQtds:nAt,2],4,100)}}
	@ 000,001 TO 016,245 LABEL STR0020 OF oAvaVei PIXEL					//Filtrar
	@ 006,007 SAY STR0021 SIZE 25,06 OF oAvaVei PIXEL COLOR CLR_BLUE		//Marca:
	@ 005,025 MSGET oCodMar VAR cCodMar F3 "VE1" VALID(FS_VALID("VE1").and.FS_REFRIMP(.F.)) SIZE 20,06 OF oAvaVei PIXEL COLOR CLR_BLUE
	@ 006,060 SAY STR0022 SIZE 25,06 OF oAvaVei PIXEL COLOR CLR_BLUE		//Grupo:
	@ 005,078 MSGET oGruVei VAR cGruVei F3 "VVR" VALID(FS_VALID("VVR").and.FS_REFRIMP(.F.)) SIZE 40,06 OF oAvaVei PIXEL COLOR CLR_BLUE
	@ 006,126 SAY STR0023 SIZE 25,06 OF oAvaVei PIXEL COLOR CLR_BLUE		//Modelo:
	@ 005,146 MSGET oModVei VAR cModVei F3 "VV2" VALID(FS_VALID("VV2").and.FS_REFRIMP(.F.)) SIZE 68,06 OF oAvaVei PIXEL COLOR CLR_BLUE
	@ 005,222 BUTTON oOk PROMPT STR0024 OF oAvaVei SIZE 18,10 PIXEL ACTION Processa( {|| FS_LEVANT(1) } )	//< OK >
	@ 005,297 BUTTON oImpr PROMPT STR0025 OF oAvaVei SIZE 45,10 PIXEL ACTION FS_IMPRIMIR() WHEN lImprimir	//Imprimir
	@ 005,349 BUTTON oSair PROMPT STR0026 OF oAvaVei SIZE 45,10 PIXEL ACTION oAvaVei:End()						//<<<  S A I R  >>>
	ACTIVATE MSDIALOG oAvaVei CENTER
#ENDIF
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ FS_VALID ³ Autor ³ Thiago Aprile             ³ Data ³ 20/11/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Validacao no campo grupo e modelo do veiculo                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VALID(cTp)
Local lRet := .f.
If cTp == "VE1"
	If !Empty(cCodMar)
		DbSelectArea("VE1")
		DbSetOrder(1)
		If DbSeek(xFilial("VE1")+cCodMar)
			lRet := .t.
		EndIf
	Else
		lRet := .t.
	EndIf
ElseIf cTp == "VVR"
	If !Empty(cGruVei)
		DbSelectArea("VVR")
		DbSetOrder(2)
		If DbSeek(xFilial("VVR")+cCodMar+cGruVei)
			lRet := .t.
		EndIf
	Else
		lRet := .t.
	EndIf
ElseIf cTp == "VV2"
	If !Empty(cModVei)
		DbSelectArea("VV2")
		DbSetOrder(1)
		If DbSeek(xFilial("VV2")+cCodMar+cModVei)
			lRet := .t.
		EndIf
	Else
		lRet := .t.
	EndIf
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ FS_LEVANT³ Autor ³ Thiago Aprile             ³ Data ³ 20/11/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Levantamento do veiculo.							                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_LEVANT(nx)
Local cQuery  := ""
Local cQAlVV1 := "SQLVV1VV2"
Local ni      := 0
Local cVV1_SITVEI := space(len(VV1->VV1_SITVEI))
Local cVV1_STATUS := space(len(VV1->VV1_STATUS))
aQtds := {}
nQtdVir := 0
nQtdEst := 0
nQtdVen := 0
nQtdTrt := 0
nQtdRem := 0
nQtdCom := 0
nQtdTra := 0
nQtdRes := 0
cQuery := "SELECT VV1.VV1_SITVEI , VV1.VV1_CODMAR , VV2.VV2_DESMOD , COUNT(*) AS QTD FROM "+RetSqlName("VV1")+" VV1 , "+RetSqlName("VV2")+" VV2 WHERE "
cQuery += "( VV1.VV1_SITVEI<>'"+cVV1_SITVEI+"' OR VV1.VV1_STATUS<>'"+cVV1_STATUS+"' ) AND VV1.VV1_CODMAR=VV2.VV2_CODMAR AND VV1.VV1_MODVEI=VV2.VV2_MODVEI AND VV1.D_E_L_E_T_=' ' AND VV2.D_E_L_E_T_=' '"
if !Empty(cCodMar)
	cQuery += " AND VV1.VV1_CODMAR='"+cCodMar+"'"
Endif
if !Empty(cGruVei)
	cQuery += " AND VV2.VV2_GRUMOD='"+cGruvei+"'"
Endif
if !Empty(cModVei)
	cQuery += " AND VV2.VV2_MODVEI='"+cModVei+"'"
Endif
cQuery += "GROUP BY VV1.VV1_SITVEI , VV1.VV1_CODMAR , VV2.VV2_DESMOD "
cQuery += "ORDER BY VV1.VV1_SITVEI , VV1.VV1_CODMAR , VV2.VV2_DESMOD "

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV1 , .F., .T. )
cSituac := "Inicio"
cSitVei := ""
Do While !( cQAlVV1 )->( Eof() )
	Do Case
		Case ( cQAlVV1 )->( VV1_SITVEI ) == "0"
			cSitVei := "0-"+ STR0027  //Estoque
			nQtdEst += ( cQAlVV1 )->( QTD )
		Case ( cQAlVV1 )->( VV1_SITVEI ) == "1"
			cSitVei := "1-"+ STR0028  //Vendido
			nQtdVen += ( cQAlVV1 )->( QTD )
		Case ( cQAlVV1 )->( VV1_SITVEI ) == "2"
			cSitVei := "2-"+ STR0029 //Em transito
			nQtdTrt += ( cQAlVV1 )->( QTD )
		Case ( cQAlVV1 )->( VV1_SITVEI ) == "3"
			cSitVei := "3-"+ STR0030    //Remessa
			nQtdRem += ( cQAlVV1 )->( QTD )
		Case ( cQAlVV1 )->( VV1_SITVEI ) == "4"
			cSitVei := "4-"+ STR0031 //Consignado
			nQtdCom += ( cQAlVV1 )->( QTD )
		Case ( cQAlVV1 )->( VV1_SITVEI ) == "5"
			cSitVei := "5-"+ STR0032 //Transferido
			nQtdTra += ( cQAlVV1 )->( QTD )
		Case ( cQAlVV1 )->( VV1_SITVEI ) == "6"
			cSitVei := "6-"+ STR0033 //Reservado
			nQtdRes += ( cQAlVV1 )->( QTD )
		OtherWise
			cSitVei := " -"+ STR0034 //Virtual
			nQtdVir += ( cQAlVV1 )->( QTD )
	EndCase
	if ( cQAlVV1 )->( VV1_SITVEI ) <> cSituac
		Aadd(aQtds,{left(cSitVei,1),"1"+cSitVei,( cQAlVV1 )->( QTD )}) // Totais
	Else
		ni := aScan(aQtds, {|x| x[1]+x[2] == left(cSitVei,1)+"1"+cSitVei })
		If ni > 0
			aQtds[ni,3] += ( cQAlVV1 )->( QTD ) // Soma Totais
		EndIf
	Endif
	Aadd(aQtds,{left(cSitVei,1),"2"+space(10)+( cQAlVV1 )->( VV1_CODMAR )+" "+( cQAlVV1 )->( VV2_DESMOD ) , ( cQAlVV1 )->( QTD ) })
	cSituac := ( cQAlVV1 )->( VV1_SITVEI )
	( cQAlVV1 )->( DbSkip() )
EndDo
( cQAlVV1 )->( dbCloseArea() )
if Len(aQtds) == 0
	aQtds := {{"","",0}}
Endif
FS_REFRIMP(.T.)
aSort(aQtds,1,,{|x,y| x[1]+x[2] < y[1]+y[2] })
If nx == 1
	oLbQtds:nAt := 1
	oLbQtds:SetArray(aQtds)
	oLbQtds:bLine := { || {FG_AlinVlrs(Transform(aQtds[oLbQtds:nAt,3],"@E 999,999,999")),substr(aQtds[oLbQtds:nAt,2],4,100)}}
	oLbQtds:SetFocus()
	oLbQtds:Refresh()
EndIf
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ FS_REFRIMP³ Autor ³ Thiago Aprile            ³ Data ³ 20/11/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ WHEN do Botao Imprimir.							                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_REFRIMP(lTipo)
lImprimir := lTipo
//oImpr:Refresh()
return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ FS_REFRIMP³ Autor ³ Thiago Aprile            ³ Data ³ 20/11/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ // Verifica Base de Dados (Erro com Falta de Tabelas).          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VERBASE()
Local cQuery  := ""
Local cQAlias := "SQLERRO"
Local lOk     := .t.
Local cEmpSALVA:= cEmpAnt
Local cFilSALVA:= cFilAnt
Local aSM0     := {}
Private bBlock := ErrorBlock()
Private bErro  := ErrorBlock( { |e| lOk := .f. } )
aSM0 := FWArrFilAtu(cEmpAnt,cFilAnt) // Filial Origem (Filial logada)
cEmpAnt := aSM0[1]
cFilAnt := aSM0[2]
cQuery := "SELECT VV1.VV1_CHAINT FROM "+RetSqlName("VV1")+" VV1 WHERE VV1.VV1_CHAINT='1'"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
( cQAlias )->( dbCloseArea() )
cQuery := "SELECT VV2.VV2_CODMAR FROM "+RetSqlName("VV2")+" VV2 WHERE VV2.VV2_CODMAR='1'"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
( cQAlias )->( dbCloseArea() )
ErrorBlock(bBlock)
cEmpAnt := cEmpSALVA
cFilAnt := cFilSALVA
Return(lOk)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ FS_REFRIMP³ Autor ³ Thiago Aprile            ³ Data ³ 20/11/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Imprimir															           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_IMPRIMIR()
Local ni := 0
Local aSM0     := {}
Private cDesc1 := ""
Private cDesc2 := ""
Private cDesc3 := ""
Private tamanho:= "P"
Private limite := 80
Private cString:= "VV1"
aSM0 := FWArrFilAtu(cEmpAnt,cFilAnt) // Filial Origem (Filial logada)
Private titulo := (STR0001+" - "+Alltrim(aSM0[7]))
Private cabec1 := STR0021 +" "+cCodMar+"  "+ STR0022 +" "+cGruVei+"  "+ STR0023 +" "+cModVei //Marca:  Grupo:  Modelo:
Private cabec2 := STR0035 //      Qtdes         Marca/Modelo"
Private aReturn:= {"",1,"",1,2,1,"",1}
Private nomeprog:= "VEIVC150"
Private nLastKey:= 0
nomeprog := SetPrint(cString,nomeprog,nil,titulo,cDesc1,cDesc2,cDesc3,.F.,,,tamanho)
If nLastKey == 27
	Return
EndIf
SetDefault(aReturn,cString)
nLin  := 0
m_pag := 1
Set Printer to &nomeprog
Set Printer On
Set Device  to Printer
nLin := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15) + 1
@nLin++, 005 pSay "***************************"
@nLin++, 005 pSay STR0036 +transform(nQtdVir,"@E 999,999,999")+" *"  //Virtual:
@nLin++, 005 pSay STR0037 +transform(nQtdEst,"@E 999,999,999")+" *"  //Estoque:
@nLin++, 005 pSay STR0038 +transform(nQtdVen,"@E 999,999,999")+" *"  //Vendido
@nLin++, 005 pSay STR0043 +transform(nQtdTrt,"@E 999,999,999")+" *"  //Em transito:
@nLin++, 005 pSay STR0039 +transform(nQtdRem,"@E 999,999,999")+" *"  //Remessa:
@nLin++, 005 pSay STR0040 +transform(nQtdCom,"@E 999,999,999")+" *"  //Consignado:
@nLin++, 005 pSay STR0041 +transform(nQtdTra,"@E 999,999,999")+" *"  //Transferido:
@nLin++, 005 pSay STR0042 +transform(nQtdRes,"@E 999,999,999")+" *"  //Reservado:
@nLin++, 005 pSay "***************************"
nLin += 2
For ni := 1 to len(aQtds)
	If nLin >= 60
		nLin := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15) + 1
	EndIf
	If left(aQtds[ni,2],1)=="1"
		nLin++
	EndIf
	@nLin++, 001 pSay left(Transform(aQtds[ni,3],"@E 999,999,999")+" "+substr(aQtds[ni,2],4,68),78)
Next
Set Printer to
Set Device to Screen
If aReturn[5] == 1
	OurSpool( nomeprog )
EndIf
MS_Flush()
Return
