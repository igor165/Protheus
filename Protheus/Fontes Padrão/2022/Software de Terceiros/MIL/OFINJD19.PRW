// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 002    º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"

#define STR0001 "Consulta de LOG de importação/exportação"
#define STR0002 "de processos de integração John Deere"
#define STR0003 "John Deere versão 2013"
#define STR0004 "Consulta de LOG de importação/exportação John Deere"
#define STR0005 "Atualizando Perguntas (SX1)..."
#define STR0006 "Data Inicial"
#define STR0007 "Data Final"	
#define STR0008 "Data"
#define STR0009 "Assunto"
#define STR0010 "Hora"
#define STR0011 "Observação"
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | OFINJD19   | Autor | Luis Delorme          | Data | 19/08/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Consulta LOG de Integração John Deere                        |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFINJD19()
//
Local cDesc1  := STR0001
Local cDesc2  := STR0002
Local cDesc3  := STR0003
Local aSay := {}
Local aButton := {}

Private cTitulo := STR0004
Private cPerg 	:= "ONJD19"
Private cNomRel := "OFINJD19"

Private aIntCab := {} // Cabeçalhos da função FGX_VISINT
Private aIntIte := {} // Itens da função FGX_VISINT
//
CriaSX1()
//
aAdd( aSay, cDesc1 )
aAdd( aSay, cDesc2 )
aAdd( aSay, cDesc3 )

Pergunte(cPerg,.f. )

DBSelectArea("SX1")
DBSetOrder(1)
DBSeek(Left(cPerg+space(100),Len(SX1->X1_GRUPO))+"01")  
if found()
	reclock("SX1",.f.)
	SX1->X1_CNT01 := dtos(ddatabase)
	SX1->X1_CNT02 := dtos(ddatabase)
	SX1->X1_CNT03 := dtos(ddatabase)
	SX1->X1_CNT04 := dtos(ddatabase)
	msunlock()
endif
DBSeek(Left(cPerg+space(100),Len(SX1->X1_GRUPO))+"02")
if found()
	reclock("SX1",.f.)
	SX1->X1_CNT01 := dtos(ddatabase)
	SX1->X1_CNT02 := dtos(ddatabase)
	SX1->X1_CNT03 := dtos(ddatabase)
	SX1->X1_CNT04 := dtos(ddatabase)
	msunlock()
endif	
//
aAdd( aButton, { 5, .T., {|| Pergunte(cPerg,.T. )    }} )
aAdd( aButton, { 1, .T., {|| nOpc := 1, FechaBatch() }} )
aAdd( aButton, { 2, .T., {|| FechaBatch()            }} )
//
FormBatch( cTitulo, aSay, aButton )
//
cQryAl001 := GetNextAlias()
cQuery := "SELECT VQ6_DATA, VQ6_TIPO, VQ6_HORA, VQ6_OBS FROM " + RetSqlName("VQ6") + " VQ6 "
cQuery += " WHERE VQ6_FILIAL ='" + xFilial("VQ6") + "'"
cQuery += "     AND VQ6_DATA >= '" + dtos(MV_PAR01) + "'"
cQuery += "     AND VQ6_DATA <= '" + dtos(MV_PAR02) + "'"
cQuery += "     AND VQ6.D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY VQ6_DATA, VQ6_TIPO "
//
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAl001, .F., .T. )
aVetCods := {}
//
nQtd := 0       
//
aIntCab := {}
//
aAdd(aIntCab,{STR0008,"D",45,"@D"})
aAdd(aIntCab,{STR0009,"C",55,"@!"})
aAdd(aIntCab,{STR0010,"C",55,"@!"})
aAdd(aIntCab,{STR0011,"C",200,"@!"})
//
while !(cQryAl001)->(eof())
	//
	aAdd(aIntIte,{ stod((cQryAl001)->(VQ6_DATA)),(cQryAl001)->(VQ6_TIPO), (cQryAl001)->(VQ6_HORA), (cQryAl001)->(VQ6_OBS) } )
	(cQryAl001)->(DBSkip())
enddo
//
(cQryAl001)->(DBCloseArea())
//
FGX_VISINT(cNomRel , cTitulo , aIntCab , aIntIte , .f. )
//
return 

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | OJD19LOG   | Autor |  Luis Delorme         | Data | 30/05/11 |##
##+----------+------------+-------+-----------------------+------+----------+##
##+ Descric  | Gravação de LOG de Integração                                +##
##+----------+------------+-------+-----------------------+------+----------+##
###############################################################################
===============================================================================
*/
Function OJD19LOG(cTipo, cOBS)

If TCCanOpen(RetSqlName("VQ6"))
	DBSelectArea("VQ6")
	reclock("VQ6",.t.)
	VQ6_FILIAL := xFilial("VQ6")
	VQ6_CODIGO := GetSXENum("VQ6","VQ6_CODIGO")
	VQ6_TIPO := cTipo
	VQ6_DATA := ddatabase
	VQ6_HORA := time()
	VQ6_OBS := cOBS
	msunlock()
	ConfirmSX8()
endif

return

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

if cPerg == ""
	return
endif

aEstrut:= { "X1_GRUPO"  ,"X1_ORDEM","X1_PERGUNT","X1_PERSPA","X1_PERENG" ,"X1_VARIAVL","X1_TIPO" ,"X1_TAMANHO","X1_DECIMAL","X1_PRESEL"	,;
"X1_GSC"    ,"X1_VALID","X1_VAR01"  ,"X1_DEF01" ,"X1_DEFSPA1","X1_DEFENG1","X1_CNT01","X1_VAR02"  ,"X1_DEF02"  ,"X1_DEFSPA2"	,;
"X1_DEFENG2","X1_CNT02","X1_VAR03"  ,"X1_DEF03" ,"X1_DEFSPA3","X1_DEFENG3","X1_CNT03","X1_VAR04"  ,"X1_DEF04"  ,"X1_DEFSPA4"	,;
"X1_DEFENG4","X1_CNT04","X1_VAR05"  ,"X1_DEF05" ,"X1_DEFSPA5","X1_DEFENG5","X1_CNT05","X1_F3"     ,"X1_GRPSXG" ,"X1_PYME"}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ aAdd a Pergunta                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// TODO
aAdd(aSX1,{cPerg,"01",STR0006,"","","MV_CH1","D",8,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","S"})
aAdd(aSX1,{cPerg,"02",STR0007,"","","MV_CH2","D",8,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","S"})

ProcRegua(Len(aSX1))

dbSelectArea("SX1")
dbSetOrder(1)
For i:= 1 To Len(aSX1)
	If !Empty(aSX1[i][1])
		If !dbSeek(Left(Alltrim(aSX1[i,1])+SPACE(100),Len(SX1->X1_GRUPO))+aSX1[i,2])
			IncProc(STR0005)
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
