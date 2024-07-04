// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 010    º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "OFINJD07.ch"

// Bia como nao tem ci coloquei aqui mesmo fora de padrao
#define STR0045 "Loja"
#define STR0046 "Fornecedor e Loja não encontrados"
#define STR0047 "Fornecedor"
#define STR0048 "Cadastrar parâmetros marca para Fornecedor/Loja da Marca configurada."

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | OFINJD07   | Autor | Luis Delorme          | Data | 16/08/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | DPMORD - Importação de Informações de Pedidos de Peças       |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFINJD07()
//
Local cDesc1  := STR0001
Local cDesc2  := STR0002
Local cDesc3  := STR0003
Local aSay    := {}
Local aButton := {}

Private cTitulo := STR0004
Private cPerg 	:= "ONJD071"
Private cNomRel := "OFINJD07"
Private aTudo := {}
//
Private cGruFor := "04"

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
Local nCntFor, nCntFil
//
Local aLayout := {}
Local aLayoutH := {}
cNumRef := ""

if cTProc == "TXT"
	
	aAdd(aLayoutH, { "C", 6, 0, 1, STR0023 } ) //  "Código Dealer"
	aAdd(aLayoutH, { "C", 30, 0, 1, STR0023 } ) //  "Código Dealer"	
	
	aAdd(aLayout, { "C", 6, 0, 1, STR0023 } ) //  "Código Dealer"
	aAdd(aLayout, { "C", 10, 0, 4, STR0024 } ) //  "Armazém"
	aAdd(aLayout, { "C", 1, 0, 10, STR0025 } ) //  "Ativ. Pedido"
	aAdd(aLayout, { "D", 8, 0, 10, STR0026 } ) //  "Data"
	aAdd(aLayout, { "C", 8, 0, 10, STR0027 } )	// "Hora"
	aAdd(aLayout, { "C", 3, 0, 10, STR0028 } )	// "Tipo"
	aAdd(aLayout, { "N", 1, 0, 10, STR0029 } )	// "Origem"
	aAdd(aLayout, { "C", 17, 0, 10, STR0030 } )	// "Id. Linha"
	aAdd(aLayout, { "C", 18, 0, 10, STR0031 } )	// "Código da Peça"
	aAdd(aLayout, { "N", 6, 0, 10, STR0032 } )	// "Quantidade"
	aAdd(aLayout, { "C", 10, 0, 10, STR0033 } )	// "Código Pedido"
	aAdd(aLayout, { "C", 2, 0, 10, STR0034 } )	// "Termo Especial"
	aAdd(aLayout, { "C", 10, 0, 10, STR0035 } )	// "Data de Envio"
	aAdd(aLayout, { "C", 1, 0, 10, STR0036 } ) 	// "Ativ. Linha"
	//
	aAdd(aIntCab,{aLayout[1,5],aLayout[1,1],25,"@!"})
	aAdd(aIntCab,{aLayout[3,5],aLayout[3,1],55,"@!"})
	aAdd(aIntCab,{aLayout[4,5],aLayout[4,1],35,"@!"})
	aAdd(aIntCab,{aLayout[6,5],aLayout[6,1],35,"@!"})
	aAdd(aIntCab,{aLayout[7,5],aLayout[7,1],35,"@!"})
	aAdd(aIntCab,{aLayout[8,5],aLayout[8,1],35,"@!"})
	aAdd(aIntCab,{aLayout[9,5],aLayout[9,1],35,"@!"})
	aAdd(aIntCab,{aLayout[10,5],aLayout[10,1],35,"@E 999999"})
	aAdd(aIntCab,{aLayout[11,5],aLayout[11,1],35,"@!"})
endif
//
// PROCESSAMENTO DOS ARQUIVOS
//
// Para realizar processamentos múltiplos deve-se popular o vetor aArquivos.
// Para processamentos de um só arquivo pode-se usar o cGetFile
//
// Usando GetFile:
aVetNome := {}
aVetTam  := {}
aVetData := {}
aVetHora := {}

aDir( Alltrim(MV_PAR05)+"JD2DLR_DPMORD*.*" ,aVetNome,aVetTam,aVetData,aVetHora)

if Len(aVetNome) == 0
	MsgStop(STR0042)
	return .f.
endif

Asort(aVetNome,,,{|x,y| x  > y})

aAdd(aArquivos,Alltrim(MV_PAR05)+aVetNome[1])

///...

oSql := DMS_SqlHelper():New()
if FM_SQL(" SELECT COALESCE(count(*),0) as COUNT FROM "+oSql:Nolock('VE4')+" WHERE VE4_CODFOR = '"+MV_PAR06+"' AND VE4_LOJFOR = '"+MV_PAR07+"' AND VE4.VE4_PREFAB = '"+MV_PAR01+"' AND VE4.D_E_L_E_T_ = ' ' ") == 0
	ALERT(STR0048) // 'Cadastrar parâmetros marca para Fornecedor/Loja da Marca configurada.'
	return
EndIf


//
// Laço em cada arquivo
//
BEGIN TRANSACTION
//

for nCurArq := 1 to Len(aArquivos)
	// pega o próximo arquivo
	cArquivo := Alltrim(aArquivos[nCurArq])
	// Se o usuário clicar no X no cGetFile então cArquivo fica vazio e devemos abortar o processo
	nPos = Len(cArquivo)
	if nPos = 0
		lAbort = .t.
		DisarmTransaction()
		return
	endif
	// verifica existência do arquivo somente para garantia
	if !File(cArquivo)
		aAdd(aLinErros,STR0009 + cArquivo + STR0010)
		loop
	endif
	// extrai  diretório e verifica se ele já foi processado e está no salva
	while nPos != 0 .and. Subs(cArquivo,nPos,1) != ALLTRIM(" \ ")
		nPos--
	enddo
	cDir := Subs(cArquivo,1,nPos)
	cArq := Subs(cArquivo,nPos+1)
	if aDir( cDir + ALLTRIM("SALVA\ ") + cArq , aVetNome, aVetTam, aVetData, aVetHora) > 0
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
	//                                         '
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
		if Left(cStr,5) != "ORDER"
			aInfo := ExtraiEDI(aLayout,cStr)
			cHora := aInfo[5]
			dDatPed := aInfo[4]
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
lProcessou := .f.
For nCntFil := 1 to Len(aFilis)
	aSugest := {}
	aPedido := {}	
	cFilAnt := aFilis[nCntFil,1]
	For nCntFor := 1 to Len(aTudo)
		if STRZERO(VAL(aTudo[nCntFor,1]),6) == STRZERO(VAL(GetNewPar("MV_MIL0005","0")),6)
			if Alltrim(aTudo[nCntFor,3]) == "S"
				lProcessou := .T.
				aAdd(aSugest,aTudo[nCntFor])
			else
				lProcessou := .T.
				aAdd(aPedido,aTudo[nCntFor])
			endif
		endif
	next
	//
	//
	cCont := 1
	Asort(aPedido,,,{|x,y| x[9]  < y[9]} )
	cNumero := CriaVar("C7_NUM",.T.)
	if ! SA2->(dbSeek(xFilial("SA2") + MV_PAR06 + MV_PAR07))
		MsgStop(STR0046) // "Fornecedor e Loja não encontrados"
		DisarmTransaction()
		return .f.
	EndIf

	aCab:={{"C7_NUM"     ,cNumero  	        ,Nil},; // Numero do Pedido
		{"C7_EMISSAO"    ,dDataBase         ,Nil},; // Data de Emissao
		{"C7_FORNECE"    ,MV_PAR06          ,Nil},; // Fornecedor
		{"C7_LOJA"       ,MV_PAR07          ,Nil},; // Loja do Fornecedor
		{"C7_COND"       ,MV_PAR02          ,Nil},; // Condicao de pagamento
		{"C7_CONTATO"    ,"               " ,Nil},; // Contato
		{"C7_FILENT"     ,xFilial("SD2")    ,Nil}} // Filial Entrega
	aItem := {}
	
	For nCntFor := 1 to Len(aPedido)
		//
		cQryAl001 := GetNextAlias()
		//
		cQuery := "SELECT B1_COD, B1_UM  "
		cQuery += "FROM " + RetSQLName("SB1") + " SB1 "
		cQuery += " WHERE B1_FILIAL = '" + xFilial("SB1") + "'"
		cQuery += " AND B1_CODFAB = '"+aPedido[nCntFor,9]+"'"
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
			//
			cB1Cod := (cQryAl001)->(B1_COD)
			aadd(aItem,{{"C7_ITEM"   , cCont               ,Nil},; //Numero do Item
			{"C7_PRODUTO", cB1Cod                 		   ,Nil},; //Codigo do Produto
			{"C7_UM"     , (cQryAl001)->(B1_UM)                      ,Nil},; //Unidade de Medida
			{"C7_QUANT"  , aPedido[nCntFor,10]                  ,Nil},; //Quantidade
			{"C7_PRECO"  , FG_FORMULA(MV_PAR03), Nil},; //Preco
			{"C7_DATPRF" , dDataBase                       ,Nil},; //Data De Entrega
			{"C7_FLUXO"  , "S"                             ,Nil},; //Fluxo de Caixa (S/N)
			{"C7_PEDFAB" , aPedido[nCntFor,11]             ,Nil},; //Pedido Fabrica
			{"C7_LOCAL"  , FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD") ,Nil}}) //Localizacao
			cCont++
		else
			MsgStop(STR0038 + " " +Alltrim(aPedido[nCntFor,9]) + " " + STR0039)
			DisarmTransaction()
			return .f.
		EndIf
		(cQryAl001)->(dbCloseArea())
	next
	//
	if Len(aPedido) > 0
		lMsErroAuto := .f.
		MSExecAuto({|v,x,y,z| MATA120(v,x,y,z)},1,aCab,aItem,3)
		If lMsErroAuto
			DisarmTransaction()
			MostraErro()
			Return .f.
		EndIf
		//
	endif
	//
	Pergunte(cPerg,.f. )
	//
	//
	if Len(aSugest) > 0
		//
		if SFJ->(FieldPos("FJ_DATVAL")) <> 0
			cQrySFJ := GetNextAlias()
			cQuery := "SELECT R_E_C_N_O_ RECSFJ FROM "+RetSqlName("SFJ")
			cQuery += " WHERE FJ_FILIAL ='" + xFilial("SFJ") + "' AND FJ_TIPPRC='1' AND"
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
		DBSelectArea("VSJ")
		RecLock("SFJ",.T.)
		SFJ->FJ_FILIAL  := xFilial("SFJ")
		SFJ->FJ_CODIGO  := CriaVar("FJ_CODIGO",.T.)
		SFJ->FJ_DATREF  := dDataBase
		SFJ->FJ_DIASSUG := 1
		SFJ->FJ_COND := MV_PAR02
		SFJ->FJ_TIPGER := "2"
		SFJ->FJ_ORIPED := "1"
		SFJ->FJ_FORNECE := MV_PAR06
		SFJ->FJ_LOJA := MV_PAR07
		SFJ->FJ_FILENT := xFilial("SFJ")
		if SFJ->(FieldPos("FJ_TIPPED")) <> 0
			SFJ->FJ_TIPPED := MV_PAR04
		endif
		if SFJ->(FieldPos("FJ_DATVAL")) <> 0
			SFJ->FJ_DATVAL := CriaVar("FJ_DATVAL")
		endif
		if SFJ->(FieldPos("FJ_HORPED")) <> 0
			SFJ->FJ_HORPED := Left(cHora,5) 
		endif
		if SFJ->(FieldPos("FJ_FORMUL")) <> 0
			SFJ->FJ_FORMUL := MV_PAR03
		endif
		msunlock()
		//
		ConfirmSX8()
	endif
	//
	For nCntFor := 1 to Len(aSugest)
		cQryAl001 := GetNextAlias()
		cQuery := "SELECT B1_COD, B1_UM, B1_QE, B1_CODITE "
		cQuery += "FROM " + RetSQLName("SB1") + " SB1 "
		cQuery += " WHERE B1_FILIAL = '" + xFilial("SB1") + "'"
		cQuery += " AND (B1_CODFAB = '"+aSugest[nCntFor,9]+"' OR B1_CODITE = '"+aSugest[nCntFor,9]+"')"
		cQuery += " AND SB1.D_E_L_E_T_ = ' ' "
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
			//
			RecLock("SDF",.T.)
			SDF->DF_FILIAL  := xFilial("SFJ")
			SDF->DF_CODIGO  := SFJ->FJ_CODIGO
			SDF->DF_PRODUTO := (cQryAl001)->(B1_COD)
			SDF->DF_QTDSUG := aSugest[nCntFor,10]
			SDF->DF_QTDINF := aSugest[nCntFor,10]
			SDF->DF_VLRTOT := FG_FORMULA(MV_PAR03) *  aSugest[nCntFor,10]
			SDF->DF_QE := (cQryAl001)->(B1_QE)
			msunlock()
			if SFJ->(FieldPos("FJ_VALTOT")) <> 0
				reclock("SFJ",.f.)
				SFJ->FJ_VALTOT += SDF->DF_VLRTOT
				msunlock()
			endif				
			//
		endif
		//
		(cQryAl001)->(dbCloseArea())
		//
	next
	//
	If EMPTY(alias())
		dbSelectArea("SB1") // erro alias nao existe, as vezes dava close em cima sem dar dbselectarea
	EndIf
	ConfirmSX8()
next
//

END TRANSACTION
//
cFilAnt := cFilAntOld
//
//#############################################################################
//# Move o arquivo para o diretorio SALVA                                     #
//#############################################################################
if  lProcessou
	if Len(aLinErros) == 0 
		OJD19LOG("DPMORD", STR0037)
		cNumPedMV  := " "
		For nCntFor := 1 to Len(aIntIte)
			if cNumPedMV < aIntIte[ nCntFor,11]
				cNumPedMV := aIntIte[nCntFor,11]
			endif
		next
		DBSelectArea("SX1")
		if DBSeek(Left("ONJD06"+space(100),Len(SX1->X1_GRUPO))+"05")
			reclock("SX1",.f.)
			SX1->X1_CNT01 := cNumRef
			SX1->X1_CNT02 := cNumRef
			SX1->X1_CNT03 := cNumRef
			SX1->X1_CNT04 := cNumRef
			msunlock()
		endif
		aDir( Alltrim(MV_PAR05)+"JD2DLR_DPMORD*.*" ,aVetNome,aVetTam,aVetData,aVetHora)
		for nCurArq := 1 to Len(aVetNome)
			cArquivo := Alltrim(MV_PAR05)+Alltrim(aVetNome[nCurArq])
			Copy File &(cArquivo) to &(cDir + AllTrim("SALVA\ ") + aVetNome[nCurArq])
			Dele File &(cArquivo)
		next 
		MsgInfo(STR0043+dtoc(dDatPed) + " - " + cHora)
	else
		MsgInfo(STR0016,STR0012)
	endif
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
//
if Alltrim(aInfo[1]) == Alltrim(SM0->M0_SEQUENC)
	aItem := {}
	aAdd(aItem,	aInfo[1])
	aAdd(aItem,	aInfo[3])
	aAdd(aItem,	aInfo[4])
	aAdd(aItem,	aInfo[6])
	aAdd(aItem,	aInfo[7])
	aAdd(aItem,	aInfo[8])
	aAdd(aItem,	aInfo[9])
	aAdd(aItem,	aInfo[10])
	aAdd(aItem,	aInfo[11])
	//
	aAdd(aIntIte,aItem)
	//
endif
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
±±º               123456789012345678901234567890123456789                    º±±
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
##|Função    | ONJD07VPED | Autor |  Luis Delorme         | Data | 30/05/11 |##
##+----------+------------+-------+-----------------------+------+----------+##
###############################################################################
===============================================================================
*/
Function ONJD07VPED()
VEJ->(DBSetOrder(1))
VEJ->(DBSeek(xFilial("VEJ")+MV_PAR01+MV_PAR04))
if VEJ->VEJ_PEDEDI != "SO"
	MsgInfo(STR0044)
	return .f.
endif
return .t.

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
//marca
aAdd(aSX1,{cPerg,"01",STR0020,"","","MV_CH1","C",3,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","VE1","","S"})
aAdd(aSX1,{cPerg,"03",STR0021,"","","MV_CH2","C",3,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SE4","","S"})
aAdd(aSX1,{cPerg,"04",STR0022,"","","MV_CH3","C",6,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","EG2","","S"})
aAdd(aSX1,{cPerg,"05",STR0040,"","","MV_CH4","C",2,0,0,"G","ONJD07VPED()","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","VEJPED","","S"})
aAdd(aSX1,{cPerg,"06",STR0041,"","","MV_CH5","C",99,0,0,"G","Mv_Par05:=cGetFile('Diretorio','',,,,"+AllTrim(Str(nOpcGetFil))+")","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","",""	  ,"S"})
//fornecedor
aAdd(aSX1,{cPerg,"07",STR0047,"","","MV_CH6","C",TAMSX3('A2_COD' )[1],0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","SA2","","S"})
//loja
aAdd(aSX1,{cPerg,"08",STR0045,"","","MV_CH7","C",TAMSX3('A2_LOJA')[1],0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","","","S"})
ProcRegua(Len(aSX1))
//
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
//
return
