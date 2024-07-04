// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 005    º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "ofinjd04.ch"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | OFINJD04   | Autor | Luis Delorme          | Data | 05/08/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Integração John Deere - Authorized Part Returns              |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFINJD04()
//
Local cDesc1  := STR0001
Local cDesc2  := STR0002
Local cDesc3  := STR0003
Local aSay := {}
Local aButton := {}
Local nCurArq := 0

Private cTitulo := STR0004
Private cPerg 	:= ""
Private cNomRel := "OFINJD04"

Private cArquivo			// Nome do Arquivo a ser importado
Private aArquivos := {}		// Vetor de arquivos (para processamento múltiplo)
Private aLinErros := {}		// Linhas que serão apresentadas no relatorio de erros

Private cErrorXML := ""
Private cWarnXML := ""

Private cTProc := "XML"
Private lAbort := .t.

Private aIntCab := {} // Cabeçalhos da função FGX_VISINT
Private aIntIte := {} // Itens da função FGX_VISINT
aAdd(aIntCab,{STR0020, "C",45,"@!"})
aAdd(aIntCab,{STR0021,"C",300,"@!"}) 
aAdd(aIntCab,{STR0022, "N",45,"@!"})
aAdd(aIntCab,{STR0023,"N", 45, "@E 999,999,999.99"})
//
CriaSX1()
//
aAdd( aSay, cDesc1 ) 
aAdd( aSay, cDesc2 ) 
aAdd( aSay, cDesc3 ) 
//
// aAdd( aButton, { 5, .T., {|| Pergunte(cPerg,.T. )    }} )
aAdd( aButton, { 1, .T., {|| nOpc := 1, FechaBatch() }} )
aAdd( aButton, { 2, .T., {|| FechaBatch()            }} )
//
while lAbort
	//
	lAbort := .f.
	nOpc := 0
	//
	FormBatch( cTitulo, aSay, aButton )
	//
	If nOpc <> 1
		Return
	Endif
	//
	Pergunte(cPerg,.f.)
	//
	RptStatus( {|lEnd| ImportArq(@lEnd)},STR0005,STR0006)
	//
	if !lAbort
		if Len(aLinErros) > 0
			RptStatus({|lEnd| ImprimeRel(@lEnd) },STR0005, STR0007, .T. )
		else
			If FGX_VISINT(cNomRel , cTitulo , aIntCab , aIntIte , .f. ) == 1
				if MsgYesNo(STR0024,STR0012)
					If !CriaOrcRec()
						Return
					Endif
				endif
				nPos = Len(cArquivo)
				while nPos != 0 .and. Subs(cArquivo,nPos,1) != "\" 
					nPos--
				enddo
				cDir := Subs(cArquivo,1,nPos)
				cArq := Subs(cArquivo,nPos+1)
				for nCurArq := 1 to Len(aArquivos)
					cArquivo := Alltrim(aArquivos[nCurArq])
					Copy File &(cArquivo) to &(cDir + "SALVA\" + cArq)
					Dele File &(cArquivo)
				next
			Endif
		endif
		//
	endif
enddo
//
Return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | ImportArq  | Autor |                       | Data |          |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição |                                                              |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function ImportArq()
//
Local nCurArq
//
Local aVetNome := {}
Local aVetTam := {}
Local aVetData := {}
Local aVetHora := {}
// 
Local aLayout := {}
//
// 
// PROCESSAMENTO DOS ARQUIVOS
//
// Para realizar processamentos múltiplos deve-se popular o vetor aArquivos. 
// Para processamentos de um só arquivo pode-se usar o cGetFile
//
// Usando GetFile:
nOpGtFl := 0 // GETF_RETDIRECTORY
cMacroxa := 'cArquivo := cGetFile("*.xml", "'+STR0008+'",0," ",.F., 0  ,.T. )' // TODO - Verificar parâmetros do cGetFile
&(cMacroxa)

aAdd(aArquivos,cArquivo)
//
// Laço em cada arquivo
for nCurArq := 1 to Len(aArquivos)
	// pega o próximo arquivo
	cArquivo := Alltrim(aArquivos[nCurArq])
	// Se o usuário clicar no X no cGetFile então cArquivo fica vazio e devemos abortar o processo
	nPos = Len(cArquivo)
	if nPos = 0
		aArquivos := {}		// Vetor de arquivos (para processamento múltiplo)
		lAbort = .t.
		return
	endif
	// verifica existência do arquivo somente para garantia
	if !File(cArquivo)
		aAdd(aLinErros,STR0009 + cArquivo + STR0010)
		loop
	endif
	// extrai  diretório e verifica se ele já foi processado e está no salva
	while nPos != 0 .and. Subs(cArquivo,nPos,1) != "\" 
		nPos--
	enddo
	cDir := Subs(cArquivo,1,nPos)
	cArq := Subs(cArquivo,nPos+1)
	if aDir( cDir + "SALVA\" + cArq , aVetNome, aVetTam, aVetData, aVetHora) > 0
		if !MsgYesNo(STR0009+cArquivo+STR0011,STR0012)
			loop
		endif
	endif	
	//
	oXml := XmlParserFile( cArquivo, "_", @cErrorXML, @cWarnXML )	
	if Empty(cErrorXML)
		GrvInfo(oXml)
	else
		aAdd(aLinErros, cArquivo + STR0015)
	endif
next
//#############################################################################
//# Move o arquivo para o diretorio SALVA                                     #
//#############################################################################
if Len(aLinErros) == 0
//	for nCurArq := 1 to Len(aArquivos)
//		cArquivo := Alltrim(aArquivos[nCurArq])
//		Copy File &(cArquivo) to &(cDir + "SALVA\" + cArq)
//		Dele File &(cArquivo)
//	next
else
	MsgInfo(STR0016,STR0012)
	return
endif
//
return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡…o    | ImprimeRel | Autor | Luis Delorme          | Data | 17/03/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡…o | Processa o resultado da importação                           |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function GrvInfo(oXml)
Local nCntFor 
//
// Realizar as atualizações necessárias a partir das informações extraídas
// fazer verificações de erro e atualizar o vetor aIntIte ou aLinErros conforme
// o caso
//
// oXML:_Document:_account:Text
// oXML:_Document:_date:Text
// oXML:_Document:_returnauthorization:_returnId:text
/*
oXML:_Document:_returnauthorization:_items:_Itemdetail[1]:_authorizedQty:Text
oXML:_Document:_returnauthorization:_items:_Itemdetail[1]:_cofinsamountpereach:Text
oXML:_Document:_returnauthorization:_items:_Itemdetail[1]:_harmonized:Text
oXML:_Document:_returnauthorization:_items:_Itemdetail[1]:_icmsamountpereach:Text
oXML:_Document:_returnauthorization:_items:_Itemdetail[1]:_linenumber:Text
oXML:_Document:_returnauthorization:_items:_Itemdetail[1]:_moveorder:Text
oXML:_Document:_returnauthorization:_items:_Itemdetail[1]:_packlistkey:Text
oXML:_Document:_returnauthorization:_items:_Itemdetail[1]:_pisamountpereach:Text
oXML:_Document:_returnauthorization:_items:_Itemdetail[1]:_withholdingcofinsamountpereach:Text
oXML:_Document:_returnauthorization:_items:_Itemdetail[1]:_withholdingpisamountpereach:Text
*/
if type("oXML:_Document:_returnauthorization:_items:_Itemdetail[1]") <> "U"
	for nCntFor := 1 to Len(oXML:_Document:_returnauthorization:_items:_Itemdetail)  
	
		cCodProd := oXML:_Document:_returnauthorization:_items:_Itemdetail[nCntFor]:_part:Text
		cStr := oXML:_Document:_returnauthorization:_items:_Itemdetail[nCntFor]:_authorizedQty:Text
		while AT(",",cSTR) > 0
			nChar := AT(",",cSTR)
			cStr := Left(cSTR,nChar-1)+"."+Subs(cSTR,nChar+1)
		enddo
		nAutQuant := val(cStr)
		cStr:= oXML:_Document:_returnauthorization:_items:_Itemdetail[nCntFor]:_ibdp:Text
		while AT(",",cSTR) > 0
			nChar := AT(",",cSTR)
			cStr := Left(cSTR,nChar-1)+"."+Subs(cSTR,nChar+1)
		enddo
		nIBDP := val(cStr)
		cQryAl001 := GetNextAlias()
		cQuery := "SELECT B1_DESC "
		cQuery += "FROM " + RetSQLName("SB1") + " SB1 "
		cQuery += " WHERE B1_FILIAL = '" + xFilial("SB1") + "'" 
		cQuery += " AND B1_CODFAB = '"+cCodProd+"'" 
		cQuery += " AND SB1.D_E_L_E_T_=' '"
		//
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAl001, .F., .T. )
		cB1Desc := ""
		if !(cQryAl001)->(eof())
			cB1Desc := (cQryAl001)->(B1_DESC)
		endif
		(cQryAl001)->(dbCloseArea())
		aInfo := {}
		aAdd(aInfo,cCodProd)
		aAdd(aInfo,cB1Desc)
		aAdd(aInfo,nAutQuant)
		aAdd(aInfo,nIBDP)
		//
		aAdd(aIntIte,aInfo)
	next
Else
	cCodProd := oXML:_Document:_returnauthorization:_items:_Itemdetail:_part:Text
	cStr := oXML:_Document:_returnauthorization:_items:_Itemdetail:_authorizedQty:Text
	while AT(",",cSTR) > 0
		nChar := AT(",",cSTR)
		cStr := Left(cSTR,nChar-1)+"."+Subs(cSTR,nChar+1)
	enddo
	nAutQuant := val(cStr)
	cStr:= oXML:_Document:_returnauthorization:_items:_Itemdetail:_ibdp:Text
	while AT(",",cSTR) > 0
		nChar := AT(",",cSTR)
		cStr := Left(cSTR,nChar-1)+"."+Subs(cSTR,nChar+1)
	enddo
	nIBDP := val(cStr)
	cQryAl001 := GetNextAlias()
	cQuery := "SELECT B1_DESC "
	cQuery += "FROM " + RetSQLName("SB1") + " SB1 "
	cQuery += " WHERE B1_FILIAL = '" + xFilial("SB1") + "'" 
	cQuery += " AND B1_CODFAB = '"+cCodProd+"'" 
	cQuery += " AND SB1.D_E_L_E_T_=' '"
	//
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAl001, .F., .T. )
	cB1Desc := ""
	if !(cQryAl001)->(eof())
		cB1Desc := (cQryAl001)->(B1_DESC)
	endif
	(cQryAl001)->(dbCloseArea())
	aInfo := {}
	aAdd(aInfo,cCodProd)
	aAdd(aInfo,cB1Desc)
	aAdd(aInfo,nAutQuant)
	aAdd(aInfo,nIBDP)
	//
	aAdd(aIntIte,aInfo)
Endif
	//
return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡…o    | ImprimeRel | Autor | Luis Delorme          | Data | 27/03/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡…o | Imprime o relatório de erros                                 |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function ImprimeRel()

Local nCntFor

Local cDesc1  := STR0019
Local cDesc2  := ""
Local cDesc3  := ""

Private cString  := ""
Private Tamanho  := "M"
Private aReturn  := { "Zebrado",2,"Administracao",2,2,1,"",1 }
Private wnrel    := "ERROSEDI" // TODO
Private NomeProg := "ERROSEDI" // TODO
Private nLastKey := 0
Private Limite   := 132
Private Titulo   := cTitulo+" ("+cArquivo+")"+" - " + dtoc(ddatabase)
Private nTipo    := 0
Private cbCont   := 0
Private cbTxt    := " "
Private Li       := 80
Private m_pag    := 1
Private aOrd     := {}
Private Cabec1   := " "
Private Cabec2   := " "
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
for nCntFor = 1 to Len(aLinErros)
	
	If Li > 55
		li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		li++
	Endif
	//
	@ Li++, 1   PSay aLinErros[nCntFor]
	//+-------------------------------------------------------------------------------
	//| Se teclar ESC, sair
	//+-------------------------------------------------------------------------------
	If nLastKey == 27
		@ Li++ , 1 psay STR0017
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
//aAdd(aSX1,{cPerg,"01","Parâmetro 1","","","MV_CH1","C",40,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S"})
//aAdd(aSX1,{cPerg,"02","Parâmetro 2","","","MV_CH2","C",40,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S"})
//aAdd(aSX1,{cPerg,"03","Parâmetro 3","","","MV_CH3","C",40,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S"})

ProcRegua(Len(aSX1))

dbSelectArea("SX1")
dbSetOrder(1)
For i:= 1 To Len(aSX1)
	If !Empty(aSX1[i][1])
		If !dbSeek(Left(Alltrim(aSX1[i,1])+SPACE(100),Len(SX1->X1_GRUPO))+aSX1[i,2])
			IncProc(STR0018)
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

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡…o    | CriaOrcRec | Autor | Manoel Filho          | Data | 06/05/14 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡…o | Cria Orçamento de Recompra                                   |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function CriaOrcRec()

Local cBx_ORIGEM := ""
Local aRet      := {}
Local aParamBox := {}
Local i         := 0
Local nNumItens := GetNewPar("MV_NUMITEN",999999)
Local nInicio   := 0
Local cTotOrc   := ""

Private cGruFor := "04" 										// Grupo de Formulas que podem ser utilizadas nos orcamentos

dbSelectArea("VS1")

aAdd(aParamBox,{1,RetTitle("VS1_CLIFAT"),Space(TamSX3("VS1_CLIFAT")[1]),"@!","JD04VLDCLI(MV_Par01)","SA1","",0,.T.}) // Cliente
aAdd(aParamBox,{1,RetTitle("VS1_LOJA")  ,Space(TamSX3("VS1_LOJA")  [1]),"@!","JD04VLDCLI(MV_Par01,MV_Par02)",""   ,"",0,.T.}) // Loja
aAdd(aParamBox,{1,RetTitle("VS3_CODSIT"),Space(TamSX3("VS3_CODSIT")[1]),"@!","JD04VLDSIT(MV_Par03)" ,"V09","",0,.T.}) // Código da Situação
aAdd(aParamBox,{1,RetTitle("VS3_OPER")  ,Space(TamSX3("VS3_OPER")  [1]),"@!","JD04VLDOPE(MV_Par04)" ,"DJ ","",0,.T.}) // Operação
aAdd(aParamBox,{1,RetTitle("VS3_GRUITE"),Space(TamSX3("VS3_GRUITE")[1]),"@!","Vazio() .or. JD04VLDGRU(MV_Par05)" ,"SBM","",0,.f.}) // Grupo 
aAdd(aParamBox,{1,RetTitle("VS3_FORMUL"),Space(TamSX3("VS3_FORMUL")[1]),"@!","JD04VLDFML(MV_Par06)" ,"VEG","",0,.T.}) // Fórmula
aAdd(aParamBox,{1,RetTitle("VS1_FORPAG"),Space(TamSX3("VS1_FORPAG")[1]),"@!","JD04VLDFPG(MV_Par07)" ,"SE4","",0,.T.}) // Forma de Pagamento
                            
If !ParamBox(aParamBox,"",@aRet,,,,,,,,.f.) 
	Return .f.
EndIf

dbSelectArea("SA1")
dbSetOrder(1)
MsSeek(xFilial("SA1")+aRet[1]+aRet[2])

dbSelectArea("SB1")
dbSetOrder(1)
		
dbSelectArea("SB2")
dbSetOrder(1)

Begin Transaction
	
For i:= 1 to Len(aIntIte)
	
    If !aIntIte[i,1]
    	Loop
    Endif                
	    
	If nInicio == 0

		cNumOrc := GetSXENum("VS1","VS1_NUMORC")
		ConfirmSx8()
		cTotOrc += cNumOrc + " / "
		dbSelectArea("VS1")
		Reclock("VS1",.t.)
		VS1->VS1_FILIAL := xFilial("VS1")
		VS1->VS1_TIPORC := "1"
		VS1->VS1_NUMORC := cNumOrc      
		VS1->VS1_DATORC := dDataBase 
		VS1->VS1_HORORC := CriaVar("VS1_HORORC")
		VS1->VS1_DATVAL := dDataBase+GetNewPar("MV_DTLIMIT",0)
		VS1->VS1_CLIFAT := aRet[1]
		VS1->VS1_LOJA   := aRet[2]
		VS1->VS1_TIPCLI := SA1->A1_TIPO
		VS1->VS1_FORPAG := aRet[7]
		VS1->VS1_NCLIFT := SA1->A1_NOME
		VS1->VS1_CODVEN := CriaVar("VS1_CODVEN")
		VS1->VS1_STATUS := "0"
		VS1->VS1_RETPEC := "2"
		MsUnlock()

		If ExistFunc("OA3700011_Grava_DTHR_Status_Orcamento")
			OA3700011_Grava_DTHR_Status_Orcamento( VS1->VS1_NUMORC , VS1->VS1_STATUS , STR0003+" - "+STR0004 ) // Grava Data/Hora na Mudança de Status do Orçamento / John Deere / Authorized Part Returns
		EndIf
		
	Endif	

	dbSelectArea("VS3")
	Reclock("VS3",.t.)
	VS3->VS3_FILIAL := xFilial("VS3")
	VS3->VS3_NUMORC := cNumOrc
	SB1->(dbSeek(xFilial("SB1")+aIntIte[i,2]))
	SB2->(dbSeek(xFilial("SB2")+SB1->B1_COD))
	VS3->VS3_SEQUEN := strzero(i,3)
	If !Empty(aRet[5])                      
		VS3->VS3_GRUITE := aRet[5]
	Else
		VS3->VS3_GRUITE := SB1->B1_GRUPO
	Endif
	VS3->VS3_CODITE := SB1->B1_CODITE 
	VS3->VS3_QTDITE := aIntIte[i,4]
	VS3->VS3_CODSIT := aRet[3]
	If !Empty(aRet[4])
		VS3->VS3_OPER   := aRet[4]
		VS3->VS3_CODTES := MaTesInt(2,aRet[4],VS1->VS1_CLIFAT,VS1->VS1_LOJA,"C",SB1->B1_COD)
	Else
		VS3->VS3_CODTES := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_TS")
	Endif
	VS3->VS3_LOCAL := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")
	VS3->VS3_VALPEC := aIntIte[i,5]
	VS3->VS3_VALTOT := aIntIte[i,5] * aIntIte[i,4]
	VS3->VS3_FORMUL := aRet[6]
	VS3->VS3_CENCUS := SB1->B1_CC
	VS3->VS3_CONTA  := SB1->B1_CONTA
	VS3->VS3_ITEMCT := SB1->B1_ITEMCC
	VS3->VS3_CLVL   := SB1->B1_CLVL
MsUnlock()

	cBx_ORIGEM := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_ORIGEM")
	if VS3->(FieldPos("VS3_SITTRI")) > 0
		if !Empty(cBx_ORIGEM) .and. !Empty(VS3->VS3_CODTES)
			SF4->(dbSeek(xFilial("SF4")+VS3->VS3_CODTES))
			if !Empty(SF4->F4_SITTRIB)
				reclock("VS3",.f.)
				VS3->VS3_SITTRI := Left(cBx_ORIGEM,1) + SF4->F4_SITTRIB
				msunlock()
			endif
		endif
	endif


	nInicio ++
	If nInicio == nNumItens
		ninicio := 0                       
	Endif       
	
Next       

End transaction

MsgInfo(STR0025+Subs(cTotOrc,1,Len(cTotOrc)-3)+STR0026)

Return .t.


/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡…o    |JD04VLDCLI  | Autor | Manoel Filho          | Data | 06/05/14 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡…o | Valida Cliente e Loja                                        |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function JD04VLDCLI(cPar1,cPar2)

Default cPar2 := ""

DbselectArea("SA1")
DbSetOrder(1)
If !Dbseek(xFilial("SA1")+cPar1+cPar2)
	MsgStop(STR0027)	
	Return .f.
Endif

Return .t.

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡…o    |JD04VLDSIT  | Autor | Manoel Filho          | Data | 06/05/14 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡…o | Valida Situação		                                        |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function JD04VLDSIT(cPar)

Return ExistCpo("V09",cPar)
// Return ExistCpo("SX5","V0"+cPar)

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡…o    |JD04VLDOPE  | Autor | Manoel Filho          | Data | 06/05/14 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡…o | Valida Operação		                                        |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function JD04VLDOPE(cPar)

Return ExistCpo("SX5","DJ"+cPar) 

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡…o    |JD04VLDGRP  | Autor | Manoel Filho          | Data | 06/05/14 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡…o | Valida Grupo da Peça                                         |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function JD04VLDGRU(cPar)

Return ExistCpo("SBM",cPar)

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡…o    |JD04VLDFML  | Autor | Manoel Filho          | Data | 06/05/14 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡…o | Valida Fórmula de Preço da Peça                              |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function JD04VLDFML(cPar)

Return OFP8600016_VerificacaoFormula(cPar)

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡…o    |JD04VLDFPG  | Autor | Manoel Filho          | Data | 06/05/14 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡…o | Valida Forma de Pagamento                                    |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function JD04VLDFPG(cPar)

Return ExistCpo("SE4",cPar)

