// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 04     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#INCLUDE "OFIOR710.ch"
#include "protheus.ch"

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Vinicius Gati
    @since  12/08/2015
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "007398_1"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIOR710 ³ Autor ³ Thiago                ³ Data ³ 23/12/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Relatório de Pecas SEM contagem             			  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOR710

Local cAlias := "SB1"
Local cQuery := ""

Private nLin := 1
Private aPag := 1

//Variaveis padrao de relatorio
Private cDesc1   := STR0001 // Pecas sem contagem
Private cCabec1  := ""
Private cDesc2   := ""
Private cDesc3   := ""
Private cCabec2  := ""
Private aReturn  := { STR0002, 1,STR0003, 2, 2, 1, "",1 } //"Zebrado"###"Administracao"
Private cTamanho := "P"           // P/M/G
Private Limite   := 80           // 80/132/220
Private cTitulo  := STR0001 // Pecas sem contagem
Private cNomProg := "OFIOR710"
Private cNomeRel := "OFIOR710"
Private nLastKey := 0
Private nCaracter:= 15
Private cPerg    := "OFR710"

ValidPerg()

cNomeRel := SetPrint(cAlias,cNomeRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.f.,,,cTamanho)

if nlastkey == 27
	return
Endif
PERGUNTE(cPerg,.F.)

SetDefault(aReturn,cAlias)

RptStatus({|lEnd| ImprRel(@lEnd,cNomeRel,cAlias)},cTitulo)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ImprRel  ºAutor  ³ Thiago             º Data ³  23/12/16    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImprRel(lEnd,wNRel,cAlias)
Local lSBZ        := ( SuperGetMV("MV_ARQPROD",.F.,"SB1") == "SBZ" )
Local cFilSBM     := xFilial("SBM")
Local cFilSB1     := xFilial("SB1")
Local cFilSB2     := xFilial("SB2")
Local cFilSB5     := xFilial("SB5")
Local cFilSBF     := xFilial("SBF")
Local cFilSBZ     := IIf(lSBZ,xFilial("SBZ"),"")
Local cAliSB1     := "SQLSB1"
Local cNamSB1     := RetSqlName("SB1")
Local cNamSBM     := RetSqlName("SBM")
Local cNamSB2     := RetSqlName("SB2")
Local cNamSB5     := RetSqlName("SB5")
Local cNamSBF     := RetSqlName("SBF")
Local cNamSBZ     := IIf(lSBZ,RetSqlName("SBZ"),"")
Local lLocSoSBZ   := ( lSBZ .and. GetNewPar("MV_MIL0096","S") == "N" ) // A locação da peça também deve ser considerada na tabela SB5 quando o parâmetro MV_ARQPROD estiver configurado com SBZ? ( S=Considera / N=Não Considera )
Local lEnderecado := ( GetMv("MV_LOCALIZ") == "S" ) // Trabalha com estoque Enderecado ?
Local cPictQTD    := SX3->(x3Picture("B2_QATU"))
m_pag := 1

cCabec1 := STR0013+" "+Transform(MV_PAR09,"@D") // Pecas sem contagem desde
cCabec2 := STR0004 // "Arm Localização           Produto                         Qtd Estoque Ult.Contag"

set print to &cNomeRel
set print on
set device to print

nLin := Cabec(cTitulo,cCabec1,cCabec2,cNomProg, cTamanho,nCaracter)+1

cMV_PAR03 := IIf(!Empty(MV_PAR03),FormatIN(Alltrim(MV_PAR03),"/"),"")
cMV_PAR04 := IIf(!Empty(MV_PAR04),FormatIN(Alltrim(MV_PAR04),"/"),"")
cMV_PAR05 := IIf(!Empty(MV_PAR05),FormatIN(Alltrim(MV_PAR05),"/"),"")
cMV_PAR08 := IIf(!Empty(MV_PAR08),FormatIN(Alltrim(MV_PAR08),"/"),"")

cNAlias := "TEMP."
cQuery := " SELECT * FROM ( SELECT COALESCE(SB2.B2_LOCAL, ' ') c1, " 
If lEnderecado
	cQuery += " CASE "
	cQuery += 	" WHEN SB1.B1_LOCALIZ = 'S' THEN COALESCE( SBF.BF_LOCALIZ , ' ' ) "
	If lLocSoSBZ // Trabalha somente com a LOCACAO no SBZ ?
		cQuery += 	" ELSE COALESCE(SBZ.BZ_LOCALI2,' ') "
	Else
		If lSBZ
			cQuery += 	" ELSE COALESCE(SBZ.BZ_LOCALI2,SB5.B5_LOCALI2,' ') "
		Else
			cQuery += 	" ELSE COALESCE(SB5.B5_LOCALI2,' ') "
		EndIf
	EndIf
	cQuery += " END LOCALIZACAO, "
Else
	If lLocSoSBZ // Trabalha somente com a LOCACAO no SBZ ?
		cQuery += 	" COALESCE(SBZ.BZ_LOCALI2,' ') LOCALIZACAO, "
	Else
		If lSBZ
			cQuery += 	" COALESCE(SBZ.BZ_LOCALI2,SB5.B5_LOCALI2,' ') LOCALIZACAO, "
		Else
			cQuery += 	" COALESCE(SB5.B5_LOCALI2,' ') LOCALIZACAO, "
		EndIf
	EndIf
EndIf
cQuery += " SB1.B1_GRUPO c2, SB1.B1_CODITE c3, SB2.B2_QATU c4, SB2.B2_DINVENT c5 "
cQuery += " FROM "+cNamSB1+" SB1 "
cQuery += " JOIN "+cNamSBM+" SBM ON (SBM.BM_FILIAL='"+cFilSBM+"' AND SBM.BM_GRUPO=SB1.B1_GRUPO AND SBM.BM_TIPGRU NOT IN ('4','7') AND SBM.D_E_L_E_T_=' ') " // Nao mostrar SB1 de 4-SERVICOS e 7-VEICULOS
cQuery += " JOIN "+cNamSB2+" SB2 ON (SB2.B2_FILIAL='"+cFilSB2+"' AND SB2.B2_COD=SB1.B1_COD AND SB2.D_E_L_E_T_=' ') "
If lSBZ
	cQuery += "LEFT JOIN "+cNamSBZ+" SBZ ON (SBZ.BZ_FILIAL='"+cFilSBZ+"' AND SBZ.BZ_COD=SB1.B1_COD AND SBZ.D_E_L_E_T_=' ') "
EndIf
cQuery += "LEFT JOIN "+cNamSB5+" SB5 ON (SB5.B5_FILIAL='"+cFilSB5+"' AND SB5.B5_COD=SB1.B1_COD AND SB5.D_E_L_E_T_=' ') "
If lEnderecado // Estoque esta Enderecado //
	cQuery += "LEFT JOIN "+cNamSBF+" SBF ON (SBF.BF_FILIAL='"+cFilSBF+"' AND SB1.B1_COD=SBF.BF_PRODUTO AND SBF.BF_LOCAL=SB2.B2_LOCAL AND SBF.D_E_L_E_T_=' ') "
EndIf
cQuery += "WHERE SB1.B1_FILIAL='"+cFilSB1+"' AND SB1.D_E_L_E_T_=' ' "
If !Empty(cMV_PAR04)
	cQuery += "AND SB1.B1_GRUPO IN " + cMV_PAR04 + " "
EndIf
If !Empty(MV_PAR05)
	cQuery += "AND SB1.B1_GRUPO NOT IN " + cMV_PAR05 + " "
EndIf
cQuery += "AND SB2.B2_LOCAL>='"+MV_PAR01+"' AND SB2.B2_LOCAL<='"+MV_PAR02+"' "
If !Empty(MV_PAR09)
	cQuery += "AND SB2.B2_DINVENT < '" + DTOS(MV_PAR09) + "'  "
Else
	cQuery += "AND SB2.B2_DINVENT = ' ' "
EndIf
If !Empty(cMV_PAR03)
	cQuery += "AND SB2.B2_LOCAL NOT IN " + cMV_PAR03 + " "
EndIf 
cQuery += "AND SB2.B2_QATU <> 0 "
cQuery += ") TEMP "
cQuery += "WHERE TEMP.LOCALIZACAO>='"+IIf(!Empty(MV_PAR06),MV_PAR06,space(len(SB5->B5_LOCALI2)-1)+"0")+"' AND TEMP.LOCALIZACAO<='"+MV_PAR07+"' "
if !Empty(cMV_PAR08)
	cQuery += "AND TEMP.LOCALIZACAO NOT IN "+cMV_PAR08+""
Endif
cQuery += "ORDER BY TEMP.c1 , TEMP.LOCALIZACAO , TEMP.c2 , TEMP.c3 "
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliSB1, .F., .T. ) 
Do While !( cAliSB1 )->( Eof() ) 
	If nLin >= 60                                                            
		nLin := cabec(ctitulo,cCabec1,cCabec2,cNomProg,ctamanho,nCaracter) + 1  
	EndIf
	@nLin++ , 00 Psay 	left(( cAliSB1 )->(c1)+space(3),3)+" "+;
						left(( cAliSB1 )->(LOCALIZACAO)+space(21),21)+" "+;
						left(( cAliSB1 )->(c2)+" "+( cAliSB1 )->(c3)+space(27),27)+" "+;
						right(space(15)+Transform(( cAliSB1 )->(c4),cPictQTD),15)+" "+;
						Transform(stod(( cAliSB1 )->(c5)),"@D")
	dbSelectArea(cAliSB1)
	( cAliSB1 )->(dbSkip())
Enddo
( cAliSB1 )->(dbCloseArea())

Eject

Set Printer to
Set device to Screen

MS_FLUSH()

If aReturn[5] == 1
	OurSpool(cNomeRel)
EndIf

return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValidPerg ºAutor  ³ Thiago             º Data ³  23/12/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validacao de pergunte para o relatorio                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ValidPerg()

Local i:=0, j:=0

_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,Len(SX1->X1_GRUPO))
aRegs :={}

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
aAdd(aRegs,{cPerg,"01",STR0005,"","","mv_ch1","C",TamSX3("B2_LOCAL")[1],0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","NNR","",""})
aAdd(aRegs,{cPerg,"02",STR0006,"","","mv_ch2","C",TamSX3("B2_LOCAL")[1],0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","NNR","",""})
aAdd(aRegs,{cPerg,"03",STR0007,"","","mv_ch3","C",50,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"04",STR0008,"","","mv_ch4","C",50,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"05",STR0009,"","","mv_ch5","C",50,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"06",STR0010,"","","mv_ch6","C",TamSX3("B5_LOCALI2")[1],0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"07",STR0011,"","","mv_ch7","C",TamSX3("B5_LOCALI2")[1],0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"08",STR0012,"","","mv_ch8","C",50,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"09",STR0013,"","","mv_ch9","D",8,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

For i:=1 to Len(aRegs)
	if !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.t.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
		dbCommit()
	Endif
Next
dbSelectArea(_sAlias)

Return