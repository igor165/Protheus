// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 008    º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"  
#include "OFINJD08.CH"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | OFINJD08   | Autor | Luis Delorme          | Data | 19/08/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | DPMXFER - Importação de Transferência de Peças               |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFINJD08()
//
Local cDesc1  := STR0001
Local cDesc2  := STR0002
Local cDesc3  := STR0003
Local aSay := {}
Local aButton := {}

Private cTitulo := STR0004
Private cPerg 	:= "ONJD08"
Private cNomRel := "OFINJD08"
Private aTudo   := {}
Private cHora   := ""

Private cArquivo			// Nome do Arquivo a ser importado
Private aArquivos := {}		// Vetor de arquivos (para processamento múltiplo)
Private aLinErros := {}		// Linhas que serão apresentadas no relatorio de erros

Private cErrorXML := ""
Private cWarnXML := ""

Private cTProc := "TXT"		// TODO - Indica se o arquivo é texto plano ('TXT') ou XML ('XML')
Private lAbort := .t.

Private aIntCab := {} // Cabeçalhos da função FGX_VISINT
Private aIntIte := {} // Itens da função FGX_VISINT
//
Private cGruFor := "04"
//
CriaSX1()
//
aAdd( aSay, cDesc1 )
aAdd( aSay, cDesc2 )
aAdd( aSay, cDesc3 )
//
aAdd( aButton, { 5, .T., {|| Pergunte(cPerg,.T. )    }} )
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
			FGX_VISINT(cNomRel , cTitulo , aIntCab , aIntIte , .f. )
		endif
		//
	endif
enddo
//
return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | ImportArq  | Autor | Luis Delorme          | Data | 16/08/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Importa arquivo texto com os Pedidos de Peça                 |##
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
Local nCntFor, nCntFil, nCntFil2
Local aLayout := {}
Local aLayoutH := {}

Private dDatPed := ctod("  /  /  ")
cNumRef := ""
//
if cTProc == "TXT"
	aAdd(aLayoutH, { "C", 6, 0, 1, STR0023 } ) //  "Código Dealer"
	aAdd(aLayoutH, { "C", 30, 0, 1, STR0023 } ) //  "Código Dealer"	
	aAdd(aLayout, { "C", 18, 0, 1, STR0020 } )
	aAdd(aLayout, { "N", 6,  0, 19, STR0021 } )
	aAdd(aLayout, { "D", 10, 0, 25, STR0022 } )
	aAdd(aLayout, { "C", 8,  0, 33, STR0023 } )
	aAdd(aLayout, { "C", 6,  0, 39, STR0024 } )
	aAdd(aLayout, { "C", 10, 0, 49, STR0025 } )
	aAdd(aLayout, { "C", 6,  0, 55, STR0026 } )
	aAdd(aLayout, { "C", 10, 0, 65, STR0027 } )
	//
	aAdd(aIntCab,{aLayout[1,5],aLayout[1,1],45,"@!"})
	aAdd(aIntCab,{aLayout[2,5],aLayout[2,1],55,"@E 999.99"})
	aAdd(aIntCab,{aLayout[3,5],aLayout[3,1],55,"@D"})
	aAdd(aIntCab,{aLayout[4,5],aLayout[4,1],55,"@!"})
	aAdd(aIntCab,{aLayout[5,5],aLayout[5,1],55,"@!"})
	aAdd(aIntCab,{aLayout[6,5],aLayout[6,1],55,"@!"})
	aAdd(aIntCab,{aLayout[7,5],aLayout[7,1],55,"@!"})
endif
//
// PROCESSAMENTO DOS ARQUIVOS
//
// Para realizar processamentos múltiplos deve-se popular o vetor aArquivos.
// Para processamentos de um só arquivo pode-se usar o cGetFile
//
// Usando GetFile:
aVetNome := {}
aVetTam := {}
aVetData := {}
aVetHora := {}

aDir( Alltrim(MV_PAR03)+"JD2DLR_DPMXFER*.*" ,aVetNome,aVetTam,aVetData,aVetHora)

if Len(aVetNome) == 0
	MsgStop(STR0034)
	return .f.
endif

Asort(aVetNome,,,{|x,y| x  > y})

aAdd(aArquivos,Alltrim(MV_PAR03)+aVetNome[1])
//
// Laço em cada arquivo
for nCurArq := 1 to Len(aArquivos)
	// pega o próximo arquivo
	cArquivo := Alltrim(aArquivos[nCurArq])
	// Se o usuário clicar no X no cGetFile então cArquivo fica vazio e devemos abortar o processo
	nPos = Len(cArquivo)
	if nPos = 0
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
	// Processamento para Arquivos TXT planos
	FT_FUse( cArquivo )
	//
	FT_FGotop()
	if FT_FEof()
		aAdd(aLinErros,STR0009 + cArquivo + STR0013)
		loop
	endif
	//
	nTotRec := FT_FLastRec()
	SetRegua(nTotRec)
	//
	nLinhArq := 0
	While !FT_FEof()
		//
		cStr := FT_FReadLN()
		nLinhArq++
		//
		IncRegua()
		// Informações extraídas da linha do arquivo de importação ficam no vetor aInfo
		if Left(cStr,6) != "TRNSFR"
			aInfo := ExtraiEDI(aLayout,cStr)
			cHora := aInfo[4]
			dDatPed := aInfo[3]
			// Trabalhar com aInfo gravando as informações
			if Empty(aInfo)
				aAdd(aLinErros, cArquivo + STR0014 + Alltrim(STR(nLinhArq) ))
			else
				GrvInfo(aInfo)
			endif
		else
			aInfo := ExtraiEDI(aLayoutH,cStr)
			cNumRef := aInfo[2]
		endif
		FT_FSkip()
	EndDo
	//
	FT_FUse()
next

aFilis := {}
DBSelectArea("SX6")
DBSetOrder(1)
DBGoTop()
while !eof()
	if Alltrim(SX6->X6_VAR) == "MV_MIL0005"
		aAdd(aFilis,{SX6->X6_FIL, SX6->X6_CONTEUD})
	endif
	DBSkip()
enddo
//
cFilAntOld := cFilAnt
Asort(aTudo,,,{|x,y| x[7]+x[5]  < y[7]+y[5]}) 
aInfoFil := FWLoadSM0()
BEGIN TRANSACTION
if Len(aTudo) > 0
	if SFJ->(FieldPos("FJ_DATVAL")) <> 0
		cQrySFJ := GetNextAlias()
		cQuery := "SELECT R_E_C_N_O_ RECSFJ FROM "+RetSqlName("SFJ")
		cQuery += " WHERE FJ_FILIAL ='" + xFilial("SFJ") + "' AND FJ_ORIPED='2' AND"
		cQuery += " FJ_SOLICIT = ' ' AND D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQrySFJ, .F., .T. )
		while !((cQrySFJ)->(eof()))
			DBSelectArea("VSJ")		
			DBGoto((cQrySFJ)->(RECSFJ))
			RecLock("SFJ",.f.)
			SFJ->FJ_DATVAL := ctod("  /  /  ")
			msunlock()
			(cQrySFJ)->(DBSkip())
		enddo
		(cQrySFJ)->(dbCloseArea())
	endif
endif
For nCntFil := 1 to Len(aFilis)
	For nCntFil2 := 1 to Len(aFilis)
		lPrim := .t.
		//
		cFilAnt := aFilis[nCntFil,1]
		cFiliDest := aFilis[nCntFil,1]
		cFiliOrig := aFilis[nCntFil2,1]
		//	
		if cFiliOrig == cFiliDest
			loop
		endif
		nPosOrig := aScan(aInfoFil,{|x| Alltrim(x[1])+Alltrim(x[2]) == Alltrim(SM0->M0_CODIGO)+Alltrim(cFiliOrig) } )
		//
		if Len(aTudo) > 0
			for nCntFor := 1 to Len(aTudo)
				if STRZERO(VAL(aTudo[nCntFor,5]),6) == STRZERO(VAL(aFilis[nCntFil2,2]),6) .and. STRZERO(VAL(aTudo[nCntFor,7]),6) == STRZERO(VAL(aFilis[nCntFil,2]),6) 
					if lPrim
						DBSelectArea("SA2")
						DBSetOrder(3)
						if !DBSeek(xFilial("SA2") + aInfoFil[nPosOrig,18] )
							MsgInfo("Filial CNPJ " + aInfoFil[nPosOrig,18] + " não possui cadastro na tabela de Fornecedores.")
							DisarmTransaction()
							return .f.
						endif
						DBSelectArea("SFJ")
						reclock("SFJ",.t.)
						SFJ->FJ_FILIAL  := xFilial("SFJ")
						SFJ->FJ_CODIGO  := CriaVar("FJ_CODIGO",.T.)
						SFJ->FJ_DATREF  := dDatPed
						SFJ->FJ_DIASSUG := 1
						SFJ->FJ_COND := MV_PAR01
						SFJ->FJ_TIPGER := "3"
						SFJ->FJ_ORIPED := "2"
						SFJ->FJ_FORNECE := SA2->A2_COD
						SFJ->FJ_LOJA := SA2->A2_LOJA
						SFJ->FJ_FILENT := xFilial("SFJ")
						if SFJ->(FieldPos("FJ_DATVAL")) <> 0
							SFJ->FJ_DATVAL := CriaVar("FJ_DATVAL")
						endif
						if SFJ->(FieldPos("FJ_HORPED")) <> 0
							SFJ->FJ_HORPED := Left(cHora,5) 
						endif
						if SFJ->(FieldPos("FJ_FILORC")) <> 0
							SFJ->FJ_FILORC := aFilis[nCntFil2,1]
						endif
						if SFJ->(FieldPos("FJ_FORMUL")) <> 0
							SFJ->FJ_FORMUL := MV_PAR02
						endif
						msunlock()    
						ConfirmSX8()
						lPrim := .f.
					endif
					cQryAl001 := GetNextAlias()
					cQuery := "SELECT B1_COD, B1_UM, B1_QE "
					cQuery += "FROM " + RetSQLName("SB1") + " SB1 "
					cQuery += " WHERE B1_FILIAL = '" + xFilial("SB1") + "'"
					cQuery += " AND B1_CODFAB = '"+aTudo[nCntFor,1]+"'"
					cQuery += " AND SB1.D_E_L_E_T_=' '"
					//
					dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAl001, .F., .T. )
					cB1Cod := ""
					if !(cQryAl001)->(eof())
						//
						DBSelectArea("SB1")
						DBSetOrder(1)
						DBSeek(xFilial("SB1")+(cQryAl001)->(B1_COD))
						DBSelectArea("SB5")               
						DBSetOrder(1)
						DBSeek(xFilial("SB5")+(cQryAl001)->(B1_COD))
						DBSelectArea("SB2")               						
						DBSetOrder(1)
						DBSeek(xFilial("SB2")+(cQryAl001)->(B1_COD)+FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD"))
						//
						RecLock("SDF",.T.)
						SDF->DF_FILIAL  := xFilial("SFJ")
						SDF->DF_CODIGO  := SFJ->FJ_CODIGO
						SDF->DF_PRODUTO := (cQryAl001)->(B1_COD)
						SDF->DF_QTDSUG := aTudo[nCntFor,2]
						SDF->DF_QTDINF := aTudo[nCntFor,2]
						SDF->DF_VLRTOT := FG_FORMULA(MV_PAR02) *  aTudo[nCntFor,2]
						SDF->DF_QE := (cQryAl001)->(B1_QE)
						msunlock()
						if SFJ->(FieldPos("FJ_VALTOT")) <> 0
							reclock("SFJ",.f.)
							SFJ->FJ_VALTOT += SDF->DF_VLRTOT
							msunlock()
						endif				
					endif
					(cQryAl001)->(dbCloseArea())
					//
				endif
			next
		endif
		//
	next
next
END TRANSACTION
cFilAnt := cFilAntOld
//
//#############################################################################
//# Move o arquivo para o diretorio SALVA                                     #
//#############################################################################
if Len(aLinErros) == 0
	OJD19LOG("DPMXFER", STR0031)

	DBSelectArea("SX1")
	if DBSeek(Left("ONJD06"+space(100),Len(SX1->X1_GRUPO))+"06")
		reclock("SX1",.f.)
		SX1->X1_CNT01 := cNumRef
		SX1->X1_CNT02 := cNumRef
		SX1->X1_CNT03 := cNumRef
		SX1->X1_CNT04 := cNumRef
		msunlock()
	endif
	aDir( Alltrim(MV_PAR03)+"JD2DLR_DPMXFER*.*" ,aVetNome,aVetTam,aVetData,aVetHora)
	for nCurArq := 1 to Len(aVetNome)
		cArquivo := Alltrim(MV_PAR03)+Alltrim(aVetNome[nCurArq])
		Copy File &(cArquivo) to &(cDir + "SALVA\" + aVetNome[nCurArq])
		Dele File &(cArquivo)
	next 
	if EMPTY( STRTRAN(cHora, "/", "") )
		MsgInfo(STR0036) // Nenhuma Transferência a importar
	else
		MsgInfo(STR0035+dtoc(dDatPed) + " - " + cHora)
	endif
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
Static Function GrvInfo(aInfo)
//
	aAdd(aTudo, aInfo)
	aItem := {}
	//
	aAdd(aItem,	aInfo[1])
	aAdd(aItem,	aInfo[2])
	aAdd(aItem,	aInfo[3])
	aAdd(aItem,	aInfo[4])
	aAdd(aItem,	aInfo[5])
	aAdd(aItem,	aInfo[6])
	aAdd(aItem,	aInfo[7])
	//
	aAdd(aIntIte,aItem)
	//
return                                                                                                  '
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³ ExtraiEDI º Autor ³ Luis Delorme             º Data ³ 26/03/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao³ Monta vetores a partir de uma descrição de layout e da linha deº±±
±±º         ³ importação EDI                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno ³ aRet - Valores extraídos da linha                              º±±
±±º         ³        Se der erro o vetor retorna {}                          º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro³ aLayout[n,1] = Tipo do campo ([D]ata,[C]aracter ou [N]umerico) º±±
±±º         ³ aLayout[n,2] = Tamanho do Campo                                º±±
±±º         ³ aLayout[n,3] = Quantidade de Decimais do Campo                 º±±
±±º         ³ aLayout[n,4] = Posição Inicial do Campo na Linha               º±±
±±º         ³                                                                º±±
±±º         ³ cLinhaEDI    = Linha para extração das informações             º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º                                                                          º±±
±±º  EXEMPLO DE PREENCHIMENTO DOS VETORES                                    º±±
±±º                                                                          º±±
±±º  aAdd(aLayout,{"C",10,0,1})                                              º±±
±±º  aAdd(aLayout,{"C",20,0,11})                                             º±±
±±º  aAdd(aLayout,{"N",5,2,31})                                              º±±
±±º  aAdd(aLayout,{"N",4,0,36})                                              º±±
±±º                        1         2         3                             º±±
±±º               123456789012345678901234567890'123456789                    º±±
±±º  cLinhaEDI = "Jose SilvaVendedor Externo    123121234                    º±±
±±º                                                                          º±±
±±º  No caso acima o retorno seria:                                          º±±
±±º  aRet[1] - "Jose Silva"                                                  º±±
±±º  aRet[2] - "Vendedor Externo"                                            º±±
±±º  aRet[3] - 123,12                                                        º±±
±±º  aRet[4] - 1234                                                          º±±
±±º                                                                          º±±
±±º                                                                          º±±
±±º                                                                          º±±
±±º                                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function ExtraiEDI(aLayout, cLinhaEDI)
Local aRet := {}
Local nCntFor, nCntFor2
cLinhaEDI := cLinhaEDI + chr(9)
for nCntFor := 1 to Len(aLayout)
	//
	cTipo := aLayout[nCntFor,1]
	nTamanho := aLayout[nCntFor,2]
	nDecimal := aLayout[nCntFor,3]
	nPosIni := aLayout[nCntFor,4]
	//
	nPos := AT(chr(9),cLinhaEDI)
	cStrTexto := Subs(cLinhaEDI,1,nPos-1)
	cLinhaEDI := Subs(cLinhaEDI,nPos+1)
	//	if nPosIni + nTamanho - 1 > Len(cLinhaEDI)
	//		return {}
	//	endif
	//	cStrTexto := Subs(cLinhaEDI,nPosIni,nTamanho)
	ncValor := ""
	if Alltrim(cTipo) == "N"
		for nCntFor2 := 1 to Len(cStrTexto)
			if !(Subs(cStrTexto,nCntFor2,1)$"0123456789 ")
				return {}
			endif
		next
		ncValor = VAL(cStrTexto) / (10 ^ nDecimal)
	elseif Alltrim(cTipo) == "D"
		if stod(cStrTexto) == stod("  /  /  ")
			return {}
		endif
		ncValor := stod(cStrTexto)
	else
		ncValor := cStrTexto
	endif
	aAdd(aRet, ncValor)
next

return aRet

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
aAdd(aSX1,{cPerg,"01",STR0029,"","","MV_CH1","C",3,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SE4","","S"})
aAdd(aSX1,{cPerg,"02",STR0030,"","","MV_CH2","C",6,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","EG2","","S"})
aAdd(aSX1,{cPerg,"03",STR0033,"","","MV_CH3","C",99,0,0,"G","Mv_Par03:=cGetFile('Diretorio','',,,,"+AllTrim(Str(nOpcGetFil))+")","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","",""	  ,"S"})
                                                                                                                                                               

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
