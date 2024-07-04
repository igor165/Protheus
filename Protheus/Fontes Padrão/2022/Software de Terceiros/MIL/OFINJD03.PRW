// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 008    º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "protheus.ch"
#include "OFINJD03.ch"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OFINJD03   | Autor |  Luis Delorme         | Data | 23/07/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Exportação do arquivo LOCATOR da John Deere (JDPoint)        |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFINJD03()
// Variaveis da ParamBox
Local aSay    := {}
Local aButton := {}
Local nOpc    := 0
//
Local cDesc1  := STR0001
Local cDesc2  := STR0002
//
Private cTitulo := STR0003
//
Private lNewGrpDPM := (SBM->(FieldPos('BM_VAIDPM')) > 0)
Private cPerg := "OFINJD03"
Private overde   := LoadBitmap( GetResources(), "BR_verde")
Private overmelho:= LoadBitmap( GetResources(), "BR_vermelho")
Private cLog
PRIVATE nQtd
Private lRetorna := .t.
//
CriaSX1()
//
aAdd( aSay, cDesc1 )
aAdd( aSay, cDesc2 )
//
aAdd( aButton, { 5, .T., {|| Pergunte(cPerg,.T. )    }} )
aAdd( aButton, { 1, .T., {|| nOpc := 1, FechaBatch() }} )
aAdd( aButton, { 2, .T., {|| FechaBatch()            }} )
//
Pergunte(cPerg,.f.)
//
FormBatch( cTitulo, aSay, aButton )
//
If nOpc <> 1
	Return
Endif
//#############################################################################
//# Chama a rotina de exportação                                              #
//#############################################################################
RptStatus( {|lEnd| RunProc(@lEnd)}, STR0004,STR0005, .T. )
//
Return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | RunProc    | Autor |  Luis Delorme         | Data | 23/07/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Exportação da arquivo da JD contendo as informações de esto- |##
##|          | que (LOCATOR)                                                |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function RunProc(lEnd)
Local aVetNome := {}
Local aVetTam := {}
Local aVetData := {}
Local aVetHora := {}

Local nCntFor
local lVaiTudo
//
// le o cabeçalho do arquivo
//
cMes := "JAN"
cMes := IIF(Month(ddatabase)==2,"FEB",cMes)
cMes := IIF(Month(ddatabase)==3,"MAR",cMes)
cMes := IIF(Month(ddatabase)==4,"APR",cMes)
cMes := IIF(Month(ddatabase)==5,"MAY",cMes)
cMes := IIF(Month(ddatabase)==6,"JUN",cMes)
cMes := IIF(Month(ddatabase)==7,"JUL",cMes)
cMes := IIF(Month(ddatabase)==8,"AUG",cMes)
cMes := IIF(Month(ddatabase)==9,"SEP",cMes)
cMes := IIF(Month(ddatabase)==10,"OCT",cMes)
cMes := IIF(Month(ddatabase)==11,"NOV",cMes)
cMes := IIF(Month(ddatabase)==12,"DEC",cMes)
// DLR2JD_09JUN2014_093206.DAT
cTimeArq := SUBS(time(),1,2) + SUBS(time(),4,2) + SUBS(time(),7,2)
cArquivo := ;
"DLR2JD_" + ;
strzero(DAY(ddatabase),2) + ;
cMes + ;
STR(Year(ddatabase),4) + "_" + ;
cTimeArq + ".DAT"

if aDir( lower(Alltrim(MV_PAR01))+cArquivo ,aVetNome,aVetTam,aVetData,aVetHora) > 0
	if !MsgYesNo(STR0006,STR0004)
		lErro := .t.
		return
	endif
endif	
//
nHnd := FCREATE(lower(Alltrim(MV_PAR01))+Alltrim(cArquivo),0)
//
aVetCods := {}
//
If lNewGrpDPM
	cGrupos := "(SELECT BM_GRUPO FROM "+RetSqlName('SBM')+" WHERE BM_FILIAL = '"+xFilial('SBM')+"' AND BM_VAIDPM = '1' AND D_E_L_E_T_ = ' ')"
Else
	cGrupos := Alltrim(MV_PAR02)
	if !Empty(cGrupos)
		while AT("/",cGrupos) > 0
			nChar := AT("/",cGrupos)
			cGrupos := Left(cGrupos,nChar-1)+"','"+Subs(cGrupos,nChar+1)
		enddo
		cGrupos := "('"+cGrupos+"')"
	endif
EndIf
//
cMainAcc := Left(MV_PAR03+SPACE(6),6)
cSourAcc := Left(GetNewPar("MV_MIL0005","")+SPACE(6),6)
cM12 := Left(cMainAcc,2)
cM36 := Right(cSourAcc,4)
cS12 := Left(cMainAcc,2)
cS36 := Right(cSourAcc,4)
//
cQryAl001 := GetNextAlias()
cQuery := "SELECT B2_QATU, B1_COD, B1_CODFAB, B1_CODITE, B1_GRUPO, B1_DESC, B5_PREAJUS, B5_PREBASE,  B1_QE , B2_LOCAL "
cQuery += "FROM " + RetSqlName("SB1") + " SB1 INNER JOIN " + RetSQLName("SB2") + " SB2 ON "
cQuery += "    ( B2_FILIAL = '" + xFilial("SB2") + "'" 
cQuery += "      AND B1_COD = B2_COD" 
If MV_PAR04 == 1
	cQuery += "      AND B2_LOCAL = '"+MV_PAR05+"'" 
EndIf
cQuery += "      AND B2_QATU > 0" 	
cQuery += "      AND SB2.D_E_L_E_T_=' '"
cQuery += "    )  LEFT OUTER JOIN " + RetSQLName("SB5") + " SB5 ON "
cQuery += "    ( B5_FILIAL = '" + xFilial("SB5") + "'" 
cQuery += "      AND B5_COD = B1_COD "
cQuery += "      AND SB5.D_E_L_E_T_=' '"
cQuery += "    ) "
cQuery += " WHERE B1_FILIAL ='" + xFilial("SB1") + "'"
cQuery += IF(!Empty(cGrupos), "      AND B1_GRUPO IN " +cGrupos ,"")
cQuery += "     AND SB1.D_E_L_E_T_=' '"
//
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAl001, .F., .T. )
//
fwrite(nHnd,;
"Z" + ;
cM12 + ;
cS12 + ;
cM36 + ;
"Q0" + ;
space(10) + ;
"P" + ;
cS36 + ;
STRZERO(YEAR(ddatabase),4) + ;
STRZERO(MONTH(ddatabase),2) + ;
STRZERO(DAY(ddatabase),2) + ;
SPACE(46)+CHR(13)+CHR(10))
//
while !(cQryAl001)->(eof())
	//
	If MV_PAR04 <> 1
		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+(cQryAl001)->( B1_COD )))
		If (cQryAl001)->( B2_LOCAL ) <> FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")
			(cQryAl001)->(dbSkip())
      		Loop
		EndIf
	endif
	//
	lSemPreco := .f.
	if  Empty((cQryAl001)->(B5_PREAJUS))  .or.  Empty((cQryAl001)->(B5_PREBASE))
		lSemPreco := .t.
	endif
	cStr :=	"Z" // 1
	cStr +=	cM12 // 2
	cStr +=	cS12 // 4
	cStr +=	cM36 // 6
	cStr +=	"Q2" //10
	cStr +=	STRZERO((cQryAl001)->(B2_QATU),5) // 12
	cStr +=	" " // 17
	cStr +=	"  " // 18
	cStr +=	"  " // 20
	cStr +=	"P"	 // 22
	cStr +=	cS36 // 23
	cStr +=	Left(Alltrim((cQryAl001)->(B1_CODITE))+SPACE(12),12)  // 27
	if lSemPreco
		cStr +=	"L000"
	else
		cStr +=	 (cQryAl001)->(B5_PREBASE) // 39
		cStr +=	STRZERO(abs((cQryAl001)->(B5_PREAJUS)) % 100 , 2)  // 40
		cStr +=	IIF( (cQryAl001)->(B5_PREAJUS) < 0,"M",STRZERO( INT( (cQryAl001)->(B5_PREAJUS) /100),1) ) // 42
	endif
	cStr +=	" " // 43
	cStr +=	" " // 44
	cStr +=	STRZERO((cQryAl001)->(B1_QE),5) // 45
	cStr +=	" "  // 50
	cStr +=	"  " // 51
	cStr +=	"  "  // 53
	cStr +=	"     "
	cStr +=	" "// 60
	cStr +=	dtos(ddatabase) // 61
	cStr +=	cTimeArq // 69
	cStr +=	IIF(lSemPreco," ","Y") // 75
	cStr +=	space(5) // 76
	//
	fwrite(nHnd,cSTR+CHR(13)+CHR(10))

	(cQryAl001)->(DBSkip())
enddo

fClose(nHnd)
iif (IsSrvUnix(),CHMOD( lower(Alltrim(MV_PAR01))+Alltrim(cArquivo) , 666,,.f. ),CHMOD( lower(Alltrim(MV_PAR01))+Alltrim(cArquivo) , 2,,.f. ))
FRenameEx(lower(Alltrim(MV_PAR01))+Alltrim(cArquivo),UPPER(Alltrim(MV_PAR01)+Alltrim(cArquivo)))

DBSelectArea("SB1")
DBSetOrder(1)
MsgInfo(STR0017,STR0004)
//
Return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | CriaSX1    | Autor |  Luis Delorme         | Data | 30/05/11 |##
##+----------+------------+-------+-----------------------+------+----------+##
###############################################################################
===============================================================================
*/
Static Function CriaSX1()
Local aSX1    := {}
Local aEstrut := {}
Local i       := 0
Local j       := 0
Local lSX1	  := .F.
Local nOpcGetFil := GETF_LOCALHARD + GETF_NETWORKDRIVE + GETF_RETDIRECTORY

aEstrut:= { "X1_GRUPO"  ,"X1_ORDEM","X1_PERGUNT","X1_PERSPA","X1_PERENG" ,"X1_VARIAVL","X1_TIPO" ,"X1_TAMANHO","X1_DECIMAL","X1_PRESEL"	,;
"X1_GSC"    ,"X1_VALID","X1_VAR01"  ,"X1_DEF01" ,"X1_DEFSPA1","X1_DEFENG1","X1_CNT01","X1_VAR02"  ,"X1_DEF02"  ,"X1_DEFSPA2"	,;
"X1_DEFENG2","X1_CNT02","X1_VAR03"  ,"X1_DEF03" ,"X1_DEFSPA3","X1_DEFENG3","X1_CNT03","X1_VAR04"  ,"X1_DEF04"  ,"X1_DEFSPA4"	,;
"X1_DEFENG4","X1_CNT04","X1_VAR05"  ,"X1_DEF05" ,"X1_DEFSPA5","X1_DEFENG5","X1_CNT05","X1_F3"     ,"X1_GRPSXG" ,"X1_PYME"}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ aAdd a Pergunta                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
          
aAdd(aSX1,{cPerg,"01",STR0023,"","","MV_CH1","C",99,0,0,"G","!Vazio() .or.(Mv_Par01:=cGetFile('*.*','',,,,"+AllTrim(Str(nOpcGetFil))+"))","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""	  ,"S"})
aAdd(aSX1,{cPerg,"02",STR0024,"","","MV_CH2","C",99,0,0,"G","",                                                                          "mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","S"})
aAdd(aSX1,{cPerg,"03",STR0030,"","","MV_CH3","C",6,0,0,"G","",                                                                          "mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","","S"})
aAdd(aSX1,{cPerg,"04",STR0031,"","","MV_CH4","N",1,0,0,"C","",                                                                          "mv_par04","Parâmetro","","","","","Padrão da Peça","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aSX1,{cPerg,"05",STR0032,"","","MV_CH5","C",2,0,0,"G","",                                                                          "mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","","","S"})

ProcRegua(Len(aSX1))

dbSelectArea("SX1")
dbSetOrder(1)
For i:= 1 To Len(aSX1)
	If !Empty(aSX1[i][1])
		If !dbSeek(Left(Alltrim(aSX1[i,1])+SPACE(100),Len(SX1->X1_GRUPO))+aSX1[i,2])
			lSX1 := .T.
			RecLock("SX1",.T.)
			For j:=1 To Len(aSX1[i])
				If !Empty(FieldName(FieldPos(aEstrut[j])))
					FieldPut(FieldPos(aEstrut[j]),aSX1[i,j])
				EndIf
			Next j
			dbCommit()
			MsUnLock()
		EndIf
	EndIf
Next i

return
