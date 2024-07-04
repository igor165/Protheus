// …ÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕÕª
// ∫ Versao ∫ 7      ∫
// »ÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕÕº
#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "OFIXI014.CH"   

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|FunÁ„o    | OFIXI014   | Autor | Thiago                | Data | 18/02/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|DescriÁ„o | ImportaÁ„o EDI referentes ao assunto	ESTOQUE	INTEGRADO DE	|##
##|          | PE«AS.		 							 			        |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFIXI014()
//
Local cDesc1  := STR0001
Local cDesc2  := STR0002



Local cDesc3  := STR0003
Local aSay := {}
Local aButton := {}

Private cTitulo := STR0004
Private cPerg := "OXI014" 	
Private lErro := .f.  	    // Se houve erro, n„o move arquivo gerado
Private cArquivo			// Nome do Arquivo a ser importado
Private aLayCK6011 := {}
Private aVetEIP  := {}

//
CriaSX1()
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
RptStatus( {|lEnd| ExportArq(@lEnd)},"",STR0005)
//
RptStatus({|lEnd| ImprimeRel(@lEnd) },STR0006, STR0007, .T. )
//
return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|FunÁ„o    | ExportArq  | Autor | Thiago                | Data | 11/12/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|DescriÁ„o | Exporta arquivo.										        |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function ExportArq()
Local cQryAliasSB2 := "SQLSB2"   
Local aVetNome := {}
Local aVetTam := {}
Local aVetData := {}
Local aVetHora := {}  
Local aLayEIP  := {}
Local i := 0

aAdd(aLayEIP, { "N", 5, 0,  1} )     // CÛdigo Concession·rio
aAdd(aLayEIP, { "C",22, 0,  6} )     // Part Number (CÛdigo da PeÁa)
aAdd(aLayEIP, { "N", 8, 0, 28} )     // Quantidade
aAdd(aLayEIP, { "N", 8, 0, 36} )     // Data (ddmmaaa) da geraÁ„o do arquivo
aAdd(aLayEIP, { "N", 7, 0, 44} )     // PreÁo da PeÁa
aAdd(aLayEIP, { "C", 1, 0, 51} )     // Flag
aAdd(aLayEIP, { "C", 9, 0, 52} )     // Reservado (Preencher com espaÁos)


//
//#############################################################################
//# Tenta abrir o arquivo texto                                               #
//#############################################################################
cArquivo := "EIP"+strzero(MV_PAR03,5)+".TXT"
//
if aDir( Alltrim(MV_PAR01)+cArquivo ,aVetNome,aVetTam,aVetData,aVetHora) > 0
	if !MsgYesNo(STR0008,STR0009)
		lErro := .t.
		return
	endif
endif
//
nHnd := FCREATE(Alltrim(MV_PAR01)+Alltrim(cArquivo),0)


cQryAliasSF2 := GetNextAlias()

// CK6011 - AUTOSERVICE - ROTINA DE CONSIST NCIA

cQuery := "SELECT SB1.B1_CODITE,SB2.B2_QATU,SB1.B1_PRV1,SB2.B2_COD,SB2.B2_LOCAL "
cQuery += " FROM " + RetSQLName("SB2" ) + " SB2 "  
cQuery += " INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.B1_COD = SB2.B2_COD AND SB1.D_E_L_E_T_ = ' ' "
cQuery += " WHERE SB2.B2_FILIAL = '" + xFilial("SB2") + "' AND SB2.B2_QATU > 0 AND SB1.B1_COD = SB2.B2_COD AND "
if !Empty(substr(mv_par04,1,TamSX3("B2_LOCAL")[1]))   
	cLocal := mv_par04
	cQuery += "SB2.B2_LOCAL IN ("
    For i := 1 to Len(mv_par04)
		nPos := AT("/",cLocal)
		nPos1 := nPos
		if nPos > 0
			nPos -= 1
		Else
			nPos := Len(cLocal)
		Endif
		cLocal1 := alltrim(Substr(cLocal,1,nPos))
		if Empty(cLocal1)
		   Exit
		Endif     
		if Empty(alltrim(substr(cLocal,nPos+2,TamSX3("B2_LOCAL")[1])))
			cQuery += "'"+cLocal1+"'"
		Else
			cQuery += "'"+cLocal1+"',"
		Endif	
		cLocal := alltrim(substr(cLocal,nPos+2,Len(cLocal)))
    Next	
	cQuery += ") AND "
Endif
if !Empty(substr(mv_par02,1,TamSX3("B1_GRUPO")[1]))   
	cGrp := mv_par02
	cQuery += "SB1.B1_GRUPO IN ("
    For i := 1 to Len(mv_par02)
		nPos := AT("/",cGrp)
		nPos1 := nPos
		if nPos > 0
			nPos -= 1
		Else
			nPos := Len(cGrp)
		Endif
		cGrpIte := alltrim(Substr(cGrp,1,nPos))
		if Empty(cGrpIte)
		   Exit
		Endif     
		if Empty(alltrim(substr(cGrp,nPos+2,TamSX3("B1_GRUPO")[1])))
			cQuery += "'"+cGrpIte+"'"
		Else
			cQuery += "'"+cGrpIte+"',"
		Endif	
		cGrp := alltrim(substr(cGrp,nPos+2,Len(cGrp)))
    Next	
	cQuery += ") AND "
Endif
cQuery += "SB2.D_E_L_E_T_ = ' '"

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAliasSB2, .F., .T. )
//
nTotReg := Contar(cQryAliasSF2, "!Eof()")
//
SetRegua(nTotReg)
                                                  
(cQryAliasSB2)->(DBGoTop())

While  !(cQryAliasSB2)->(Eof())

	nAno := Year(ddatabase)
	nMes := Month(ddatabase)
	nDia := Day(ddatabase)
	nData = nDia * 1000000 + nMes * 10000 + nAno
    
	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek(xFilial("SB1")+(cQryAliasSB2)->B2_COD)
	
	aValores := {MV_PAR03,(cQryAliasSB2)->B1_CODITE,;
	(cQryAliasSB2)->B2_QATU,nData,;
    (cQryAliasSB2)->B1_PRV1*100,"",""}

	aAdd(aVetEIP,{SB1->B1_GRUPO,SB1->B1_CODITE,SB1->B1_DESC,(cQryAliasSB2)->B2_QATU,(cQryAliasSB2)->B1_PRV1,(cQryAliasSB2)->B2_LOCAL} )
		
	cLinha := MontaEDI(aLayEIP,aValores)
    
	fwrite(nHnd,cLinha)

   dbSelectArea(cQryAliasSB2)
   (cQryAliasSB2)->(dbSkip())
   
Enddo   
(cQryAliasSB2)->(dbCloseArea())

fClose(nHnd)

MsgInfo(STR0010,STR0009)

return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|FunáÖo    | ImprimeRel | Autor | Luis Delorme          | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|DescriáÖo | Imprime o resultado da importaÁ„o                           |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function ImprimeRel()

Local nCntFor

Local cDesc1  := STR0004 
Local cDesc2  := "" 
Local cDesc3  := ""

Private cString  := "VV1" // TODO
Private Tamanho  := "M"
Private aReturn  := { STR0011,2,STR0012,2,2,1,"",1 }
Private wnrel    := "ESTINTPE«AS" // TODO
Private NomeProg := "ESTINTPE«AS" // TODO
Private nLastKey := 0
Private Limite   := 80
Private Titulo   := STR0013
Private nTipo    := 0
Private cbCont   := 0
Private cbTxt    := " "
Private Li       := 80
Private m_pag    := 1
Private aOrd     := {}
Private Cabec1   := " "  // TODO
Private Cabec2   := " "  // TODO
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
li := 1
li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
li++
@ Li++, 1 PSay STR0014  
for nCntFor = 1 to Len(aVetEIP)
	
	If Li > 55
		li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		li++
	Endif
	// 
	@ Li++, 1   PSay aVetEIP[nCntFor,1]+" "+aVetEIP[nCntFor,2]+" "+aVetEIP[nCntFor,3]+"      "+aVetEIP[nCntFor,6]+"     "+transform(aVetEIP[nCntFor,4],"99999")+"  "+transform(aVetEIP[nCntFor,5],"@E 999,999,999.99")
	//+-------------------------------------------------------------------------------
	//| Se teclar ESC, sair
	//+-------------------------------------------------------------------------------
	If nLastKey == 27
		@ Li++ , 1 psay STR0015
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
##|FunÁ„o    | OFIXN003   | Autor |  Luis Delorme         | Data | 30/05/11 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|DescriÁ„o | Monta layout.                                                |##
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
		ncValor = STRZERO(Round(aInfo[nCntFor] * (10 ^ nDecimal),0),nTamanho)
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
##|FunÁ„o    | CriaSX1	  | Autor | Thiago                | Data | 18/02/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|DescriÁ„o | Criacao das perguntes.								        |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
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

dbSelectArea("SX1")

aEstrut:= { "X1_GRUPO"  ,"X1_ORDEM","X1_PERGUNT","X1_PERSPA","X1_PERENG" ,"X1_VARIAVL","X1_TIPO" ,"X1_TAMANHO","X1_DECIMAL","X1_PRESEL"	,;
"X1_GSC"    ,"X1_VALID","X1_VAR01"  ,"X1_DEF01" ,"X1_DEFSPA1","X1_DEFENG1","X1_CNT01","X1_VAR02"  ,"X1_DEF02"  ,"X1_DEFSPA2"	,;
"X1_DEFENG2","X1_CNT02","X1_VAR03"  ,"X1_DEF03" ,"X1_DEFSPA3","X1_DEFENG3","X1_CNT03","X1_VAR04"  ,"X1_DEF04"  ,"X1_DEFSPA4"	,;
"X1_DEFENG4","X1_CNT04","X1_VAR05"  ,"X1_DEF05" ,"X1_DEFSPA5","X1_DEFENG5","X1_CNT05","X1_F3"     ,"X1_GRPSXG" ,"X1_PYME" ,"X1_GRPSXG" ,"X1_HELP","X1_PICTURE"}


aAdd(aSX1,{cPerg,"01",STR0016,"","","MV_CH1","C",99,0,0,"G","!Vazio().or.(Mv_Par01:=cGetFile('Arquivos |*.*','',,,,"+AllTrim(Str(nOpcGetFil))+"))","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","",""})
aAdd(aSX1,{cPerg,"02",STR0017,"","","MV_CH2","C",80,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","S","","","!!!!/!!!!/!!!!/!!!!/!!!!/!!!!/!!!!/!!!!/"})
aAdd(aSX1,{cPerg,"03",STR0018,"","","MV_CH3","N",5 ,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","","S","","","99999"})
aAdd(aSX1,{cPerg,"04",STR0021,"","","MV_CH4","C",99,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","","S","","","!!/!!/!!/!!/!!/!!/!!/!!/"})

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
			IncProc(STR0020)
		EndIf
	EndIf
Next i

return
