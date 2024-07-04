// …ÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕÕª
// ∫ Versao ∫ 03     ∫
// »ÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕÕº

#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "OFIXN051.ch"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|FunÁ„o    | OFIXN051   | Autor | Luis Delorme          | Data | 28/08/14 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|DescriÁ„o | ExportaÁ„o do DFA John Deere                                 |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFIXN051()
// 
Local cDesc1  := STR0001
Local cDesc2  := STR0002
Local cDesc3  := STR0003
Local aSay := {}
Local aButton := {}

Private cTitulo := STR0004
Private cPerg := "OXN051" 	
Private lErro := .f.  	    // Se houve erro, n„o move arquivo gerado
Private cArquivo			// Nome do Arquivo a ser importado
Private aLinhasRel := {}	// Linhas que ser„o apresentadas no relatorio
Private cLinha

//
// Validacao de Licencas DMS
//
If !OFValLicenca():ValidaLicencaDMS()
	Return
EndIf

//
//CriaSX1()
//
aAdd( aSay, cDesc1 ) // Um para cada cDescN
aAdd( aSay, cDesc2 ) // Um para cada cDescN
aAdd( aSay, cDesc3 ) // Um para cada cDescN
//
nOpc := 0
aAdd( aButton, { 5, .T., {|| Pergunte(cPerg,.T. )    }} )
aAdd( aButton, { 1, .T., {|| nOpc := 1, FechaBatch() }} )
aAdd( aButton, { 2, .T., {|| FechaBatch()            }} )
//
FormBatch( cTitulo, aSay, aButton )
//
If nOpc <> 1
	Return
Endif
//
Pergunte(cPerg,.f.)
//
RptStatus( {|lEnd| ExportArq(@lEnd)},STR0005,STR0006)
//
return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|FunÁ„o    | ExportArq  | Autor | Luis Delorme          | Data | 28/08/14 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|DescriÁ„o | ExportaÁ„o do Arquivo                                        |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function ExportArq()
//
Local aVetNome := {}
Local aVetTam  := {}
Local aVetData := {}
Local aVetHora := {}
Local aFilExec := {}
Local nFilExec := 0
Local cBkpFil  := cFilAnt
Local cDiretor := lower(Alltrim(MV_PAR01))
Local cArquivo := Alltrim(MV_PAR02)
// 
Do Case
	Case MV_PAR05 == 1 // Filial Logada
		aFilExec := OX0520141_SelecionarFiliais( .f. , cFilAnt , .t. , MV_PAR03 ) // Parametros: ( Nao Mostra Tela , Filial Logada , Seleciona linhas     , Codigo DEF )
	Case MV_PAR05 == 2 // Selecionar Filiais
		aFilExec := OX0520141_SelecionarFiliais( .t. , ""      , .f. , MV_PAR03 ) // Parametros: ( Mostra Tela     ,               , Nao Seleciona linhas , Codigo DEF )
	Case MV_PAR05 == 3 // Todas Filiais
		aFilExec := OX0520141_SelecionarFiliais( .f. , ""      , .t. , MV_PAR03 ) // Parametros: ( Nao Mostra Tela ,               , Seleciona linhas     , Codigo DEF )
EndCase
If len(aFilExec) == 0
	Return .f.
EndIf
//
//#############################################################################
//# Tenta abrir o arquivo texto                                               #
//#############################################################################
if aDir( cDiretor+cArquivo ,aVetNome,aVetTam,aVetData,aVetHora) > 0
	if !MsgYesNo(STR0007,STR0008)
		lErro := .t.
		return
	endif
endif	

nHnd := FCREATE(cDiretor+cArquivo,0)
If FERROR() != 0 .And. nHnd < 0
	cMsg := OemToAnsi(STR0014) + STR(fError(),2) //"Erro na abertura do arquivo de exportacao: "
	MSGSTOP(cMsg)
	Return .f.
EndIf
//
For nFilExec := 1 to Len(aFilExec)

	If aFilExec[nFilExec,1]

		cFilAnt := aFilExec[nFilExec,2]
		//
		cQryAl001 := GetNextAlias()
		//
		cQuery := "SELECT VDC.VDC_FILIAL , VD9.VD9_CPODEF , SUM(VDC.VDC_VALOR) SUMVALOR"
		cQuery += "  FROM "+RetSQLName('VDC')+" VDC "
		cQuery += " INNER JOIN "+RetSQLName('VD9')+" VD9 "
		cQuery += "    ON ( VD9.VD9_FILIAL = '"+xFilial("VD9")+"' AND VD9.VD9_CODDEF = VDC.VDC_CODDEF AND VD9.VD9_CODCON = VDC.VDC_CODCON AND VD9.D_E_L_E_T_ = ' ' )"
		cQuery += " WHERE VDC.VDC_FILIAL = '"+xFilial("VDC")+"' "
		cQuery += "   AND VDC.VDC_CODDEF = '"+Alltrim(MV_PAR03)+"' "
		cQuery += "   AND VDC.VDC_DATA   = '"+DTOS(MV_PAR04)+"' "
		cQuery += "   AND VDC.D_E_L_E_T_ = ' ' "
		cQuery += " GROUP BY VDC.VDC_FILIAL , VD9.VD9_CPODEF"
		cQuery += " ORDER BY VDC.VDC_FILIAL , VD9.VD9_CPODEF"
		//
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAl001, .F., .T. )
		//
		while !((cQryAl001)->(eof()))
			//
			cLinha := Left(Alltrim((cQryAl001)->(VD9_CPODEF)),3) +;
			"00" +;
			Right(Alltrim((cQryAl001)->(VD9_CPODEF)),2) +;
			Right(Alltrim((cQryAl001)->(VDC_FILIAL)),2) +;
			";" +;
			Alltrim(STR((cQryAl001)->(SUMVALOR)))+CHR(13)+CHR(10)
			//
			If ExistBlock("OXN51AGF")
				ExecBlock("OXN51AGF",.f.,.f.)
			EndIf
			//
			fwrite(nHnd,cLinha)
			//
			(cQryAl001)->(DBSkip())
		enddo
		(cQryAl001)->(DbCloseArea())
		//
	EndIf
Next
//
cFilAnt := cBkpFil
//
fClose(nHnd)
iif (IsSrvUnix(),CHMOD( lower(cDiretor)+cArquivo , 666,,.f. ),CHMOD( lower(cDiretor)+cArquivo , 2,,.f. ))

//
if !lErro
	MsgInfo(STR0009,STR0008)
endif
//
return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|FunÁ„o    | CriaSX1    | Autor |  Luis Delorme         | Data | 29/10/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
###############################################################################
===============================================================================
Static Function CriaSX1()
Local aSX1    := {}
Local aEstrut := {}
Local i       := 0
Local j       := 0
Local lSX1	  := .F.

aEstrut:= { "X1_GRUPO"  ,"X1_ORDEM","X1_PERGUNT","X1_PERSPA","X1_PERENG" ,"X1_VARIAVL","X1_TIPO" ,"X1_TAMANHO","X1_DECIMAL","X1_PRESEL"	,;
"X1_GSC"    ,"X1_VALID","X1_VAR01"  ,"X1_DEF01" ,"X1_DEFSPA1","X1_DEFENG1","X1_CNT01","X1_VAR02"  ,"X1_DEF02"  ,"X1_DEFSPA2"	,;
"X1_DEFENG2","X1_CNT02","X1_VAR03"  ,"X1_DEF03" ,"X1_DEFSPA3","X1_DEFENG3","X1_CNT03","X1_VAR04"  ,"X1_DEF04"  ,"X1_DEFSPA4"	,;
"X1_DEFENG4","X1_CNT04","X1_VAR05"  ,"X1_DEF05" ,"X1_DEFSPA5","X1_DEFENG5","X1_CNT05","X1_F3"     ,"X1_GRPSXG" ,"X1_PYME"}

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ aAdd a Pergunta                                              ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

aAdd(aSX1,{cPerg,"01",STR0010,"","","MV_CH1","C",40,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S"}) // DiretÛrio ?
aAdd(aSX1,{cPerg,"02",STR0011,"","","MV_CH2","C",40,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S"}) // Nome do Arquivo ?
aAdd(aSX1,{cPerg,"03",STR0012,"","","MV_CH3","C", 6,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","VD7",""	,"S"}) // CÛdigo DFA?
aAdd(aSX1,{cPerg,"04",STR0013,"","","MV_CH4","D", 8,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S"}) // Data DFA?
aAdd(aSX1,{cPerg,"05","Filial?","","","MV_CH5","N", 1,0,0,"C","","mv_par05",'Filial Logada','Filial Logada','Filial Logada',"","",'Selec.Filiais','Selec.Filiais','Selec.Filiais',"","",'Todas Filiais','Todas Filiais','Todas Filiais',"","","","","","","","","","","","",""	,"S"}) // Filial?

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
			IncProc("")
		EndIf
	EndIf
Next i

return
*/
