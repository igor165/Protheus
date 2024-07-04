#INCLUDE "rwmake.ch"
#include "PROTHEUS.CH"
#include "HSPAHR53.CH"
#include "TOPCONN.CH"
#INCLUDE "REPORT.CH

/*
#define STR0001 "Este programa tem como objetivo imprimir "
#define STR0002 "Extratos de emprestimos por Hospital de acordo com os parametros informados pelo usuario."
#define STR0003 "Extratos de Emprestimos x Hospital"
#define STR0004 "Zebrado"
#define STR0005 "Estoque"
#define STR0006 "*** CANCELADO PELO OPERADOR ***"
#define STR0007 "                                                                                    Q  u  a  n  t  i  d  a  d  e"
#define STR0008 " Codigo            Descricao do Produto                              Data / Hora       Entrada         Saida    "
#define STR0009 "Hospital: "
#define STR0010 "Tipo de Emprestimo: "
#define STR0011 "ATENCAO!"
#define STR0012 "Nao ha dados para impressao."
#define STR0013 "ENTRADAS"
#define STR0014 "SAIDAS"
*/

//0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
//0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         
//                                                                                                    1                                                                                                   2                   
//****************************************************************************************************************
//                                                                                    Q  u  a  n  t  i  d  a  d  e
// Codigo            Descricao do Produto                              Data / Hora       Entrada         Saida
//****************************************************************************************************************

//Hospital: 123456789012345678901234567890123456789012345    							 Tipo de Emprestimo: ENTRADAS
// 123456789012345   123456789012345678901234567890123456789012345   99/99/99  99:99   999,999.9999   999,999.9999
//                                                                   99/99/99  99:99   999,999.9999   999,999.9999
//                                                                   99/99/99  99:99   999,999.9999   999,999.9999

//Hospital: 123456789012345678901234567890123456789012345    							 Tipo de Emprestimo: SAIDAS
// 123456789012345   123456789012345678901234567890123456789012345   99/99/99  99:99   999,999.9999   999,999.9999
//                                                                   99/99/99  99:99   999,999.9999   999,999.9999
//                                                                   99/99/99  99:99   999,999.9999   999,999.9999

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHR53  ºAutor  ³Antonio Marco       º Data ³  07/11/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Extrato de Emprestimo x Hospital                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Gestao Hospitalar                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function HSPAHR53()
Local Titulo     := STR0003 //"Extratos de Emprestimos x Hospital"
Local cDesc1     := STR0001 //"Este programa tem como objetivo imprimir "
Local cDesc2     := STR0002 //"Extratos de emprestimos por Hospital de acordo com os parametros informados pelo usuario."
Local cDesc3     := ""
Local aOrd       := {}

Local Cabec1     := STR0007 //"                                                                           Q  u  a  n  t  i  d  a  d  e         "
Local Cabec2     := STR0008 //"  Codigo            Descricao do Produto                             Emprestada     Devolvida        Saldo      "
Local nLin       := 80
Private lVerif   := .F.
Private NomeRel  := "HSPAHR53" // Coloque aqui o nome do programa para impressao no cabecalho
Private cPerg    := "HSPR53"
Private Tamanho  := "M"
Private Limite   := 132        // 80/132/220 

Private aReturn  := {STR0004, 1, STR0005, 1, 2, 1, "", 1} //"Zebrado"###"Estoque"
Private nFormato := 18

Private nLastKey := 0

Private m_pag    := 1

Private wnrel    := "HSPAHR53" // Coloque aqui o nome do arquivo usado para impressao em disco

Private cCODIMP := ""
Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao

// auxiliares
Private cHospI
Private cHospF
Private dDataI
Private dDataF
Private nTipEmp
Private cSql
Private aTipEmp := {STR0013, STR0014}     

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PARAMETROS                                                             ³
//³ MV_PAR01 : Do Hospital ?                                               ³
//³ MV_PAR02 : Ao Hospital ?                                               ³
//³ MV_PAR03 : Da data ?                                                   ³
//³ MV_PAR04 : Ate a data ?                                                ³
//³ MV_PAR05 : Tipos de Emprestimo ? 1 - Entradas / 2 - Saidas / 3 - Ambos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If FindFunction("TRepInUse") .And. TRepInUse() 
	lVerif := .T.
EndIf
If !Pergunte(cPerg, .T.)
Return()
EndIf 

// formato(orientacao) do relatorio (Retrato / Paisagem)
nFormato := If(aReturn[4] == 1, 15, 18)

// query p/ selecao dos dados
cHospI  := MV_PAR01 //Do Hospital ?
cHospF  := MV_PAR02 //Ao Hospital ?
dDataI  := MV_PAR03 //Da data ?
dDataF  := MV_PAR04 //Ate a data ?
nTipEmp := MV_PAR05 //Tipos de Emprestimo ? 1 - Entradas / 2 - Saidas / 3 - Ambos

nMaxLin := HS_MaxLin(cCODIMP)
nLin := nMaxLin * 2 

If lVerif
	pergunte("HSPR53",.F.)
	oReport := ReportDef() 
	oReport:PrintDialog() 
Else
wnrel := SetPrint("", NomeRel, cPerg, @titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .F., Tamanho, , .T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn, "")

If nLastKey == 27
   Return
Endif
Endif          
cSql := "SELECT"
cSql +=  " SB1.B1_DESC B1_DESC,"
cSql +=  " GFF.GFF_NOMHOS GFF_NOMHOS, GFG.GFG_TIPEMP GFG_TIPEMP,"
cSql +=  " GFG.GFG_DATEMP GFG_DATEMP, GFI.GFI_PROEMP GFI_PROEMP,"
cSql +=  " GFI.GFI_TIPMOV GFI_TIPMOV, GFI.GFI_QTDMOV GFI_QTDMOV,"
cSql +=  " GFI.GFI_DATMOV GFI_DATMOV, GFI.GFI_HORMOV GFI_HORMOV "
cSql += "FROM " + RetSQLName("GFI") + " GFI "
cSql += "JOIN " + RetSQLName("GFG") + " GFG ON GFG.GFG_SEQEMP = GFI.GFI_SEQEMP AND GFG.D_E_L_E_T_ <> '*' AND GFG.GFG_FILIAL = '" + xFilial("GFG") + "' "
cSql += "JOIN " + RetSQLName("GFF") + " GFF ON GFF.GFF_CODHOS = GFG.GFG_CODHOS AND GFF.D_E_L_E_T_ <> '*' AND GFF.GFF_FILIAL = '" + xFilial("GFF") + "' "
cSql += "JOIN " + RetSQLName("SB1") + " SB1 ON SB1.B1_COD = GFI.GFI_PROEMP AND SB1.D_E_L_E_T_ <> '*' AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
cSql += "WHERE "
cSql +=  "GFI.GFI_FILIAL = '" + xFilial("GFI") + "' AND GFI.D_E_L_E_T_ <> '*' AND "
cSql +=  "GFI.GFI_DATMOV BETWEEN '" + DTOS(dDataI) + "' AND '" + DTOS(dDataF) + "' AND "
cSql +=  "GFG.GFG_CODHOS BETWEEN '" + cHospI + "' AND '" + cHospF + "' "//linha anterior
if nTipEmp < 3
	cSql += "AND " //final da linha anterior
	cSql += "GFG.GFG_TIPEMP = '" + STR(nTipEmp - 1, 1) + "' "
Endif
cSql += "ORDER BY "
cSql +=  "GFF.GFF_NOMHOS, GFG.GFG_TIPEMP, SB1.B1_DESC, GFI.GFI_TIPMOV, GFI.GFI_DATMOV, GFI.GFI_HORMOV"

TCQUERY cSql NEW ALIAS "QRY"
dbSelectArea("QRY")
dbGoTop()

if !Eof()
	RptStatus({|| FS_R53(Titulo, Cabec1, Cabec2, nLin)})
Else
	HS_MsgInf(STR0012, STR0011, STR0015)//"Nao ha dados para impressao."###"Atencao"###"Verifique a seleção"
Endif

dbCloseArea()

Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_R53    ºAutor  ³Antonio Marco       º Data ³  07/11/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Impressao                                                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Gestao Hospitalar                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_R53(Titulo, Cabec1, Cabec2, nLin)
Local cNomHos
Local cTipEmp
Local cProEmp

Local nCol

SetRegua(QRY->(RecCount()))

While !Eof()
	If nLin > nMaxLin
		nLin 			:= Cabec(Titulo, Cabec1, Cabec2, NomeRel, Tamanho, nFormato)
		cNomHos := '*'
		cTipEmp := '*'       
		cProEmp := '*'
	Endif

	If LastKey() == 27 .OR. nLastKey == 27
		@ nLin,000 PSAY STR0006 //"*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif

	// quebra
	If QRY->GFF_NOMHOS != cNomHos .OR. QRY->GFG_TIPEMP != cTipEmp
		@ ++nLin,000 PSAY STR0009 + QRY->GFF_NOMHOS
		@ nLin++,067 PSAY STR0010 + aTipEmp[Val(QRY->GFG_TIPEMP) + 1]
		cNomHos := QRY->GFF_NOMHOS                         
		cTipEmp := QRY->GFG_TIPEMP
		cProEmp := '*'
	Endif

//0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
//0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         
//                                                                                                    1                                                                                                   2                   
//Hospital: 123456789012345678901234567890123456789012345    							 Tipo de Emprestimo: ENTRADAS
// 123456789012345   123456789012345678901234567890123456789012345   99/99/99  99:99   999,999.9999   999,999.9999
//                                                                   99/99/99  99:99   999,999.9999   999,999.9999
//                                                                   99/99/99  99:99   999,999.9999   999,999.9999

	If QRY->GFI_PROEMP != cProEmp
		@ nLin,001 PSAY QRY->GFI_PROEMP
		@ nLin,019 PSAY QRY->B1_DESC
		cProEmp := QRY->GFI_PROEMP
	Endif

	@ nLin,067 PSAY DTOC(STOD(QRY->GFI_DATMOV))
	@ nLin,077 PSAY QRY->GFI_HORMOV PICTURE PesqPict("GFI", "GFI_HORMOV")

	nCol := 85
	If QRY->GFI_TIPMOV == '1'
		nCol := 100
	Endif
	
	@ nLin,nCol PSAY QRY->GFI_QTDMOV PICTURE "@E 999,999.9999"

	nLin++
	
	IncRegua()
 DbSkip()
Enddo

If aReturn[5] == 1
	dbCommitAll()
	Set Printer To
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return(Nil)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³REPORTDEF ³ Autor ³ Giuvany Ribeiro       ³ Data ³ 24/09/09 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportDef()
Local oReport 
Local oSection1, oSection2, oSection3
Local oCell
Local oTotaliz1, oTotaliz2

	oReport := TReport():New("HSPAHR53",STR0003,"HSPR53",{|oReport| RACIMP(oReport)}, STR0004 + " " + STR0005 + " " + STR0003)

	//oReport:SetLandscape()         // Imprimir relatorio em formato paisagem
	oReport:SetPortrait()          // Imprimir relatorio em formato retrato

	oSection1 := TRSection():New(oReport,STR0016,{"GFF","GFG"})                 //"Hospital"
	oSection1:SetHeaderBreak(.F.)
	oSection1:SetHeaderPage(.T.)
	oCell := TRCell():New(oSection1,"GFF_NOMHOS","GFF",STR0016)                   //"Hospital"
	oCell := TRCell():New(oSection1,"cTipo","QRYRAC",STR0017,, 40,,{|| cTipo :=  iif(("QRYRAC")->GFG_TIPEMP='0' ,STR0013, STR0014)   }) //"Tipo de Emprestimo"   
	
	oSection2 := TRSection():New(oSection1,STR0018,{"SB1"})                        //"Produto"
	oSection2:SetReadOnly(.F.)
	oSection2:Hide()
	oCell := TRCell():New(oSection2,"B1_UM","SB1",)     

	oSection3 := TRSection():New(oSection2,STR0019,{"SB1","GFI"})   //"Dados Adicionais dos Produtos"
	oSection3:SetHeaderBreak(.F.)
	oSection3:SetHeaderPage(.T.)
	oCell := TRCell():New(oSection3,"GFI_PROEMP","GFI",STR0020)                        //"Cod. Produto"
	oCell := TRCell():New(oSection3,"B1_DESC","SB1",STR0021)                           //"Descricao Produto" 
	oCell := TRCell():New(oSection3,"GFI_DATMOV","GFI",STR0022)                      //"Data."
	oCell := TRCell():New(oSection3,"GFI_HORMOV","GFI",STR0023)                      //Hora
	oCell := TRCell():New(oSection3,"cPront","QRYRAC",STR0024,, 10,,{|| cPront :=  PadL(TRANSFORM(IIF(("QRYRAC")->GFI_TIPMOV='0', ("QRYRAC")->GFI_QTDMOV, 0), "@E 99,999.9999"), 11)  }) //"Qtd Entrada"   
	oCell := TRCell():New(oSection3,"cPront","QRYRAC",STR0025,, 10,,{|| cPront :=  PadL(TRANSFORM(IIF(("QRYRAC")->GFI_TIPMOV='1', ("QRYRAC")->GFI_QTDMOV, 0), "@E 99,999.9999"), 11)  }) //"Qtd Saida"   
 
Return( oReport )


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ RACImp   ³ Autor ³ Giuvany Ribeiro       ³ Data ³ 24/09/09 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RACIMP(oReport)
Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(1):Section(1)
Local oSection3 := oReport:Section(1):Section(1):Section(1)
Local cCond:=""
 //-- Transforma parametros Range em expressao SQL
	MakeSqlExpr(oReport:uParam)                      
 
	oSection1:BeginQuery()

	If nTipEmp < 3
				cCond := "%GFG_TIPEMP = '" + STR(nTipEmp - 1, 1) + "' %"
	Else
				cCond := "%GFG_TIPEMP <>'9999'%"
	EndIf


	BeginSql alias "QRYRAC"

	SELECT B1_DESC, GFF_NOMHOS, GFG_TIPEMP, GFG_DATEMP,GFI_PROEMP,GFI_TIPMOV,GFI_QTDMOV,GFI_DATMOV,GFI_HORMOV 
	FROM %table:GFI% GFI 
	JOIN  %table:GFG% GFG ON GFG.GFG_SEQEMP = GFI.GFI_SEQEMP AND GFG.%notDel% AND GFG.GFG_FILIAL = %xFilial:GFG%
	JOIN  %table:GFF% GFF ON GFF.GFF_CODHOS = GFG.GFG_CODHOS AND GFF.%notDel% AND GFF.GFF_FILIAL = %xFilial:GFF%
	JOIN  %table:SB1% SB1 ON SB1.B1_COD = GFI.GFI_PROEMP AND SB1.%notDel% AND SB1.B1_FILIAL = %xFilial:SB1%
	WHERE GFI.GFI_FILIAL = %xFilial:GFI%  AND GFI.%NotDel% 
	AND GFI.GFI_DATMOV BETWEEN %Exp:DTOS(dDataI)% AND %Exp:DTOS(dDataF)%  
	AND GFG.GFG_CODHOS BETWEEN %Exp:cHospI% AND %Exp:cHospF%   
	AND %Exp:cCond%
	ORDER BY GFF.GFF_NOMHOS, GFG.GFG_TIPEMP, SB1.B1_DESC, GFI.GFI_TIPMOV, GFI.GFI_DATMOV, GFI.GFI_HORMOV

	EndSql

	oSection1:EndQuery()
	oSection2:SetParentQuery()
	oSection2:SetParentFilter( {|P| ("QRYRAC")->GFF_NOMHOS + ("QRYRAC")->GFG_TIPEMP == P }, {|| ("QRYRAC")->GFF_NOMHOS + ("QRYRAC")->GFG_TIPEMP } )  // Quebra por Hospital
	oSection3:SetParentQuery()                                                                      
	oSection3:SetParentFilter( {|G| ("QRYRAC")->GFF_NOMHOS + ("QRYRAC")->GFG_TIPEMP +("QRYRAC")->GFI_TIPMOV  == G }, {|| ("QRYRAC")->GFF_NOMHOS + ("QRYRAC")->GFG_TIPEMP + ("QRYRAC")->GFI_TIPMOV} )  // Quebra por tipo emprestimo
	oSection1:Print() // processa as informacoes da tabela principal
	oReport:SetMeter(QRYRAC->(LastRec()))
                   
Return( NIL )

