// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 006    º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "ofinjd05.ch"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | OFINJD05   | Autor | Luis Delorme          | Data | 05/08/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Parts Surplus Returns - John Deere                           |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFINJD05()
//
Local cDesc1  := STR0001
Local cDesc2  := STR0002
Local cDesc3  := STR0003
Local aSay := {}
Local aButton := {}


Private aIntCab1 := {} // Cabeçalhos da função FGX_VISINT
Private aIntIte1 := {} // Itens da função FGX_VISINT

Private aIntCab3 := {} // Cabeçalhos da função FGX_VISINT
Private aIntIte3 := {} // Itens da função FGX_VISINT
Private aIntIte31 := {} // complemento do vetor


Private cTitulo := STR0004 
Private cPerg  := "ONJD05"  
Private cNomRel := "OFINJD05"

Private lErro := .f.  	    // Se houve erro, não move arquivo gerado
Private cArquivo			// Nome do Arquivo a ser importado
Private aLinhasRel := {}	// Linhas que serão apresentadas no relatorio
//
aAdd(aIntCab1,{STR0014,"C",45,"@!"})
aAdd(aIntCab1,{STR0015,"N",30, "@E 999,999,999.99"})
//
aAdd(aIntCab3,{STR0016,"C",45,"@!"})
aAdd(aIntCab3,{STR0017,"C",90,"@!"})
aAdd(aIntCab3,{STR0015,"N",30,"@E 999,999,999.99"})
aAdd(aIntCab3,{STR0018,"N",90,"@E 9999999999"})

CriaSX1()
//
aAdd( aSay, cDesc1 ) // Um para cada cDescN
aAdd( aSay, cDesc2 ) // Um para cada cDescN
aAdd( aSay, cDesc3 ) // Um para cada cDescN
//
nOpc := 0
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
if !lErro
//	RptStatus({|lEnd| ImprimeRel(@lEnd) },STR0005, STR0007, .T. )
endif
//
return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | ExportArq  | Autor | Luis Delorme          | Data | 05/08/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Realiza a exportação dos dados para o arquivo texto/XML      |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function ExportArq()
//
Local nCntFor := 0
Local nCntForF := 0
Local aVetNome := {}
Local aVetTam := {}
Local aVetData := {}
Local aVetHora := {}
// 
Local aLayout1 := {}
//       
if !Pergunte(cPerg,.T. )
	Return(.f.)
Endif	

aAdd(aLayout1, { "C",  1, 0, 1  } ) // tipo
aAdd(aLayout1, { "C",  2, 0, 2  } ) // main account
aAdd(aLayout1, { "C",  2, 0, 4  } ) // source account
aAdd(aLayout1, { "C",  4, 0, 6  } ) // main account 2
aAdd(aLayout1, { "C",  2, 0, 10 } ) // system code
aAdd(aLayout1, { "C",  2, 0, 12 } ) // filler
aAdd(aLayout1, { "C",  6, 0, 14 } ) // reference numer
aAdd(aLayout1, { "C",  2, 0, 20 } ) // filler
aAdd(aLayout1, { "C",  1, 0, 22 } ) // type record
aAdd(aLayout1, { "C",  4, 0, 23 } ) // source account 
aAdd(aLayout1, { "C", 22, 0, 27 } ) // filler
aAdd(aLayout1, { "C",  7, 0, 49 } ) // quantity
aAdd(aLayout1, { "C", 12, 0, 56 } ) // part number
aAdd(aLayout1, { "C",  6, 0, 68 } ) // bin location
aAdd(aLayout1, { "C",  3, 0, 74 } ) // return frequency
aAdd(aLayout1, { "C",  3, 0, 77 } ) // filler
aAdd(aLayout1, { "C",  1, 0, 80 } ) // H-ID


cQryAl001 := GetNextAlias()
cQuery := "SELECT VS1_NUMORC, VS1_VTOTNF "
cQuery += " FROM " + RetSQLName("VS1") + " VS1 "
cQuery += " WHERE VS1_FILIAL = '" + xFilial("VS1") + "'" 
cQuery += " AND VS1_CLIFAT =  '"+MV_PAR02+"' AND VS1_LOJA =  '"+MV_PAR03+"' AND VS1.VS1_STATUS = '0' AND VS1_TIPORC = '1'"
cQuery += " AND VS1.D_E_L_E_T_=' ' "
//
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAl001, .F., .T. )
cB1Desc := ""
while !(cQryAl001)->(eof())
	aAdd(aIntIte1,{(cQryAl001)->VS1_NUMORC, (cQryAl001)->VS1_VTOTNF})
	(cQryAl001)->(dbskip())
enddo
(cQryAl001)->(dbCloseArea())

if Len(aIntIte1) == 0 
	MsgStop(STR0027)
	Return(.f.)
Endif	

nRet := FGX_VISINT(cNomRel , cTitulo , aIntCab1 , aIntIte1 , .f. )


if nRet == 0 .or. nRet ==  2
	lErro := .t.
	return .f.
endif


cNumOrc := ""

lNenhum := .t.
for nCntFor := 1 to Len(aIntIte1)
	if aIntIte1[nCntFor,1]
		lNenhum := .f.
	endif
next

if lNenhum
	lErro := .t.
	return
endif

//#############################################################################
//# Tenta abrir o arquivo texto                                               #
//#############################################################################
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

cArquivo := ;
       "DLR2JD_" + ;
strzero(DAY(ddatabase),2) + ;
cMes + ;
STR(Year(ddatabase),4) + "_" + ;
SUBS(time(),1,2) + SUBS(time(),4,2) + SUBS(time(),7,2) + ".DAT"
//
if aDir( lower(Alltrim(MV_PAR01))+cArquivo ,aVetNome,aVetTam,aVetData,aVetHora) > 0
	if !MsgYesNo(STR0008,STR0009)
		lErro := .t.
		return
	endif
endif	
//
nLinhArq := 0
//
aLinhas := {}
//
for nCntForF := 1 to Len(aIntIte1)
	if aIntIte1[nCntForF,1]
		cNumOrc := aIntIte1[nCntForF,2]
		DbSelectArea("VS3")
		DBSetOrder(1) //VS3_FILIAL+VS3_NUMORC+VS3_SEQUEN
		DBSeek(xFilial("VS3") + cNumOrc )
		//
		While  !eof() .and. xFilial("VS3") + cNumOrc == VS3->VS3_FILIAL + VS3->VS3_NUMORC
			//
			DBSelectArea("SB1")
			DBSetOrder(7)
			if DBSeek(xFilial("SB1") + VS3->VS3_GRUITE + VS3->VS3_CODITE)
			    
				nPos := aScan(aIntIte3,{|x| AllTrim(x[1])==Alltrim(SB1->B1_CODITE)})
				if nPos > 0 
					aIntIte3[nPos,3] += VS3->VS3_VALTOT
					aIntIte3[nPos,4] += VS3->VS3_QTDITE
				else
					aAdd(aIntIte3,{SB1->B1_CODITE, SB1->B1_DESC, VS3->VS3_VALTOT, VS3->VS3_QTDITE  })
					aAdd(aIntIte31,SB1->B1_CODFAB)
				endif
			endif
			DBSelectArea("VS3")
			DBSkip()
		Enddo
	endif
next
//
nRet := 0
if !Empty(aIntIte3)
	nRet := FGX_VISINT(cNomRel , cTitulo , aIntCab3 , aIntIte3 , .f. )
endif

if nRet == 0 .or. nRet ==  2
	lErro := .t.
	return .f.
endif

lNenhum := .t.
for nCntFor := 1 to Len(aIntIte3)
	if aIntIte3[nCntFor,1]
		lNenhum := .f.
	endif
next

if lNenhum
	lErro := .t.
	return .t.
endif

nHnd := FCREATE(lower(Alltrim(MV_PAR01))+Alltrim(cArquivo),0)
//
cMainAcc := Left(GetNewPar("MV_MIL0005","******")+SPACE(6),6)
cSourAcc := cMainAcc
cM12 := Left(cMainAcc,2)
cM36 := Right(cSourAcc,4)
cS12 := Left(cMainAcc,2)
cS36 := Right(cSourAcc,4)
//
for nCntFor := 1 to Len(aIntIte3)
	if aIntIte3[nCntFor,1]
		//	
  		nLinhArq++
		//
		aValores := {;
		"Z",;
		cM12,;// main account <<
		cS12,;// source account <<
		cM36,;// main account 2 <<
		"5K",;// system code
		" ",;// filler
		" ",;// reference number
		" ",;// filler
		"P",;// type record
		cS36,;// source account << 
		" ",;// filler
		strzero(aIntIte3[nCntFor,5],7),; // quantity 
		IIF(Empty(aIntIte31[nCntFor]),aIntIte3[nCntFor,2],aIntIte31[nCntFor]), ; // part number
		" ",;// bin location
		"JD",;// return frequency
		" ",;// filler
		" "}// H-ID
		//
		cLinha := MontaEDI(aLayout1,aValores)
		aAdd(aLinhas, cLinha)
		aAdd(aLinhasRel,LEFT(IIF(Empty(aIntIte31[nCntFor]),aIntIte3[nCntFor,2],aIntIte31[nCntFor])+SPACE(27),27)+STR0021+STRZERO(aIntIte3[nCntFor,5],8))
	endif

next

for nCntFor := 1 to Len(aLinhas)
	fwrite(nHnd,aLinhas[nCntFor])
next
//
fClose(nHnd)
iif (IsSrvUnix(),CHMOD( lower(Alltrim(MV_PAR01))+Alltrim(cArquivo) , 666,,.f. ),CHMOD( lower(Alltrim(MV_PAR01))+Alltrim(cArquivo) , 2,,.f. ))
FRenameEx(lower(Alltrim(MV_PAR01))+Alltrim(cArquivo),lower(Alltrim(MV_PAR01))+UPPER(Alltrim(cArquivo)))
//
if !lErro
	MsgInfo(STR0010,STR0009)
	if MsgYesNo(STR0028,STR0009)
		DBSelectArea("VS1")
		DBSetOrder(1)
		for nCntForF := 1 to Len(aIntIte1)
			DBSelectArea("VS3")
			DBSetOrder(1) //VS3_FILIAL+VS3_NUMORC+VS3_SEQUEN
			if DBSeek(xFilial("VS3") + aIntIte1[nCntForF,2] )
				//
				lVS3RESERV := .f.
				While  !eof() .and. xFilial("VS3") + aIntIte1[nCntForF,2] == VS3->VS3_FILIAL + VS3->VS3_NUMORC
					if VS3->VS3_RESERV = '1'
						lVS3RESERV := .t.
						exit
					endif
					DBSkip()
				enddo
				if lVS3RESERV
					MsgInfo(STR0029+chr(13)+chr(10)+chr(13)+chr(10)+aIntIte1[nCntForF,2],STR0009)
				else
					DbSelectArea("VS1")
					DBSetOrder(1) //VS1_FILIAL+VS1_NUMORC
					if DBSeek(xFilial("VS1") + aIntIte1[nCntForF,2] )
						reclock("VS1",.f.)
						VS1->VS1_STATUS := "C"
						msunlock()
						If ExistFunc("OA3700011_Grava_DTHR_Status_Orcamento")
							OA3700011_Grava_DTHR_Status_Orcamento( VS1->VS1_NUMORC , VS1->VS1_STATUS , STR0003 ) // Grava Data/Hora na Mudança de Status do Orçamento / JD - Parts Surplus Returns
						EndIf
					endif
				endif
			endif
		next
	endif
endif
//
return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡…o    | ImprimeRel | Autor | Luis Delorme          | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡…o | Imprime o resultado da importação                            |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
/*
Static Function ImprimeRel()

Local nCntFor

Local cDesc1  := ""
Local cDesc2  := ""
Local cDesc3  := ""

Private cString  := "VV1" // TODO
Private Tamanho  := "M"
Private aReturn  := { "Zebrado",2,"Administracao",2,2,1,"",1 }
Private wnrel    := "EXPORTEDI" // TODO
Private NomeProg := "EXPORTEDI" // TODO
Private nLastKey := 0
Private Limite   := 132
Private Titulo   := cTitulo+" ("+cArquivo+")"+" - " + dtoc(ddatabase)
Private nTipo    := 0
Private cbCont   := 0
Private cbTxt    := " "
Private Li       := 80
Private m_pag    := 1
Private aOrd     := {}
Private Cabec1   := STR0003 + " - " + cArquivo
Private Cabec2   := STR0022  // TODO
Private cPerg := ""
//+-------------------------------------------------------------------------------
//| Solicita ao usuario a parametrizacao do relatorio.
//+-------------------------------------------------------------------------------
wnrel := SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,.F.,.F.)
//+-------------------------------------------------------------------------------
//| Se teclar ESC, sair
//+-------------------------------------------------------------------------------
If nLastKey == 27
	Return
Endif
//+-------------------------------------------------------------------------------
//| Estabelece os padroes para impressao, conforme escolha do usuario
//+-------------------------------------------------------------------------------
SetDefault(aReturn,cString)
//+-------------------------------------------------------------------------------
//| Verificar se sera reduzido ou normal
//+-------------------------------------------------------------------------------
nTipo := Iif(aReturn[4] == 1, 15, 18)
//+-------------------------------------------------------------------------------
//| Se teclar ESC, sair
//+-------------------------------------------------------------------------------
If nLastKey == 27
	Return
Endif
//+-------------------------------------------------------------------------------
//| Chama funcao que processa os dados
//+-------------------------------------------------------------------------------
for nCntFor = 1 to Len(aLinhasRel)
	
	If Li > 55
		li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		li++
	Endif
	//
	@ Li++, 1   PSay aLinhasRel[nCntFor]
	//+-------------------------------------------------------------------------------
	//| Se teclar ESC, sair
	//+-------------------------------------------------------------------------------
	If nLastKey == 27
		@ Li++ , 1 psay STR0012
		exit
	Endif
next
//
If Li <> 80
	Roda(cbCont,cbTxt,Tamanho)
Endif
//
If aReturn[5] == 1
	Set Printer TO
	dbCommitAll()
	OurSpool(wnrel)
EndIf
//
Ms_Flush()
//
return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | MontaEDI   | Autor |  Luis Delorme         | Data | 30/05/11 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Faz a montagem da linha para montagem do aquivo texto        |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function MontaEDI(aLayout, aInfo)
Local nCntFor
Local cLinha := ""
for nCntFor = 1 to Len(aLayout)
	//
	cTipo := aLayout[nCntFor,1]
	nTamanho := aLayout[nCntFor,2]
	nDecimal := aLayout[nCntFor,3]
	nPosIni := aLayout[nCntFor,4]
	// 
	ncValor := ""
	if Alltrim(cTipo) == "N"
		if valType(aInfo[nCntFor]) == "C"
			aInfo[nCntFor] = val(aInfo[nCntFor])
		endif
		ncValor = Alltrim(STR(aInfo[nCntFor]))
	else
		ncValor := LEFT(aInfo[nCntFor]+SPACE(nTamanho),nTamanho)
	endif
	cLinha += ncValor
next
cLinha += CHR(13) + CHR(10)
return cLinha

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

aAdd(aSX1,{cPerg,"01",STR0019,"","","MV_CH1","C",99,0,0,"G","!Vazio() .or.(Mv_Par01:=cGetFile('*.*','',,,,"+AllTrim(Str(nOpcGetFil))+"))","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""	  ,"S"})
aAdd(aSX1,{cPerg,"02",STR0023,"","","MV_CH2","C",06,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SA1","","S"})
aAdd(aSX1,{cPerg,"03",STR0024,"","","MV_CH3","C",02,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","","S"})
//aAdd(aSX1,{cPerg,"04",STR0025,"","","MV_CH4","D",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","","S"})
//aAdd(aSX1,{cPerg,"05",STR0026,"","","MV_CH5","D",08,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","","","S"})

ProcRegua(Len(aSX1))

dbSelectArea("SX1")
dbSetOrder(1)
If dbSeek("ONJD05    02")
	if SX1->X1_PERGUNTE <> STR0023
		RecLock("SX1",.F.,.T.)
		dbdelete()
		MsUnlock()
	Endif
Endif		


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
			IncProc()
		EndIf
	EndIf
Next i

return

