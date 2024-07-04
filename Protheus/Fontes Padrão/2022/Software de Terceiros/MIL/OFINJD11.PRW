// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 002    º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"   
#include "OFINJD11.CH"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | OFINJD11   | Autor | Luis Delorme          | Data | 26/08/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição |DPMSCHED - Importação de Informações de Agendam. de Extrações |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFINJD11()
//
Local cDesc1  := STR0001
Local cDesc2  := STR0002
Local cDesc3  := STR0003
Local aSay := {}
Local aButton := {}

Private cTitulo := STR0004
Private cPerg 	:= "" 
Private cNomRel := "OFINJD11"


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
=============================================================================== \                             
*/
Static Function ImportArq()
//
Local nCurArq, nCntFor
//
Local aVetNome := {}
Local aVetTam := {}
Local aVetData := {}
Local aVetHora := {}
// 
Local aLayout := {}
//
if cTProc == "TXT"
	aAdd(aLayout, { "C", 2, 0, 1, " " } ) // "Type of Extract"} )
	aAdd(aLayout, { "C", 3,  0, 3, " " } ) // "Day of Week 1"} )
	aAdd(aLayout, { "C", 4, 0, 6, " " } ) // "Time of Day 1" } )
	aAdd(aLayout, { "C", 3,  0, 10, " " } ) // "Day of Week 2"} )
	aAdd(aLayout, { "C", 4, 0, 13, " " } ) // "Time of Day 2" } )
	aAdd(aLayout, { "C", 3,  0, 17, " " } ) // "Day of Week 3"} )
	aAdd(aLayout, { "C", 4, 0, 20, " " } ) // "Time of Day 3" } )
	aAdd(aLayout, { "C", 3,  0, 24, " " } ) // "Day of Week 4"} )
	aAdd(aLayout, { "C", 4, 0, 27, " " } ) // "Time of Day 4" } )
	aAdd(aLayout, { "C", 3,  0, 31, " " } ) // "Day of Week 5"} )
	aAdd(aLayout, { "C", 4, 0, 34, " " } ) // "Time of Day 5" } )
	aAdd(aLayout, { "C", 3,  0, 38, " " } ) // "Day of Week 6"} )
	aAdd(aLayout, { "C", 4, 0, 41, " " } ) // "Time of Day 6" } )
	aAdd(aLayout, { "C", 3,  0, 45, " " } ) // "Day of Week 7"} )
	aAdd(aLayout, { "C", 4, 0, 48, " " } ) // "Time of Day 7" } )
	aAdd(aLayout, { "C", 3,  0, 52, " " } ) // "Day of Week 8"} )
	aAdd(aLayout, { "C", 4, 0, 55, " " } ) // "Time of Day 8" } )
	//
	aAdd(aIntCab,{STR0020,aLayout[1,1],45,"@!"})
	aAdd(aIntCab,{STR0021,aLayout[2,1],55,"@!"})
	aAdd(aIntCab,{STR0022,aLayout[3,1],55,"@!"})
endif
// 
// PROCESSAMENTO DOS ARQUIVOS
//
// Para realizar processamentos múltiplos deve-se popular o vetor aArquivos. 
// Para processamentos de um só arquivo pode-se usar o cGetFile
//
// Usando GetFile:
cArquivo := cGetFile( "JD2DLR_DPMSCHED*.*" , STR0008, 1, , .F., ,.T., .T. ) // TODO - Verificar parâmetros do cGetFile
aAdd(aArquivos,cArquivo)
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
		aInfo := ExtraiEDI(aLayout,cStr)
		// Trabalhar com aInfo gravando as informações
		if Empty(aInfo)
			aAdd(aLinErros, cArquivo + STR0014 + Alltrim(STR(nLinhArq) ))
		else
			GrvInfo(aInfo)
		endif
		FT_FSkip()
	EndDo
	//
	FT_FUse()
next
//
DBSelectArea("VQ5")
If TCCanOpen(RetSqlName("VQ5"))
	cString := "DELETE FROM " + RetSqlName("VQ5")
	TCSqlExec(cString)
endif
//
lCriaIni := .f.
for nCntFor := 1 to Len(aIntIte)
	if Alltrim(aIntIte[nCntFor,1]) != "D"
		lCriaIni := .t.
	endif
	cDia :="T"
	cDia := IIF(Alltrim(aIntIte[nCntFor,2]) == STR0023,"D",cDia)
	cDia := IIF(Alltrim(aIntIte[nCntFor,2]) == STR0024,"2",cDia)
	cDia := IIF(Alltrim(aIntIte[nCntFor,2]) == STR0025,"3",cDia)
	cDia := IIF(Alltrim(aIntIte[nCntFor,2]) == STR0026,"4",cDia)
	cDia := IIF(Alltrim(aIntIte[nCntFor,2]) == STR0027,"5",cDia)
	cDia := IIF(Alltrim(aIntIte[nCntFor,2]) == STR0028,"6",cDia)
	cDia := IIF(Alltrim(aIntIte[nCntFor,2]) == STR0029,"S",cDia)
	//
	reclock("VQ5",.t.)
	VQ5->VQ5_FILIAL := xFilial("VQ5")
	VQ5->VQ5_CODIGO := STRZERO(nCntFor,6)
	VQ5->VQ5_DIA := cDia
	VQ5->VQ5_HORA := Left(aIntIte[nCntFor,3],2)+Right(aIntIte[nCntFor,3],2)
	VQ5->VQ5_TIPO := "D"
	msunlock()
	//
next
if lCriaIni
	reclock("VQ5",.t.)
	VQ5->VQ5_FILIAL := xFilial("VQ5")
	VQ5->VQ5_CODIGO := STRZERO(0,6)
	msunlock()
endif
//
//#############################################################################
//# Move o arquivo para o diretorio SALVA                                     #
//#############################################################################
if Len(aLinErros) == 0
	OJD19LOG("DPMSCHED", STR0030)
	for nCurArq := 1 to Len(aArquivos)
		cArquivo := Alltrim(aArquivos[nCurArq])
		Copy File &(cArquivo) to &(cDir + "SALVA\" + cArq)
		Dele File &(cArquivo)
	next
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
Function ONJD11CWF()

DBSelectArea("VQ5")
DBSetOrder(1)
DBSeek(xFilial("VQ5"))
if eof() 
	return
endif

if Val(VQ5->VQ5_CODIGO) == 0
	reclock("VQ5",.f.,.t.)
	dbdelete()
	msunlock()
	OFINJD06(.t., "I")
	return
endif

dDOW := DOW(DDATABASE)

cDow := ""
cDow := IIF(dDow == 1,"D",cDow)
cDow := IIF(dDow == 2,"2",cDow)
cDow := IIF(dDow == 3,"3",cDow)
cDow := IIF(dDow == 4,"4",cDow)
cDow := IIF(dDow == 5,"5",cDow)
cDow := IIF(dDow == 6,"6",cDow)
cDow := IIF(dDow == 7,"S",cDow)

cTimeAtu := Left(Time(),2) + Subs(Time(),4,2)

while xFilial("VQ5") == VQ5->VQ5_FILIAL
	if (cDow == VQ5->VQ5_DIA .or. VQ5->VQ5_DIA == "T") .and. VQ5->VQ5_DIAULT != ddatabase .and. cTimeAtu > VQ5->VQ5_HORA
		reclock("VQ5",.f.)
		VQ5->VQ5_DIAULT := ddatabase
		msunlock()
		OFINJD06(.t., "D")
		return
	endif
	DBSkip()
enddo

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
Local nCntFor

cTipo := aInfo[1]
for nCntFor := 2 to 16 step 2
	if aInfo[nCntFor] $ "All|Su |M  |T  |W  |Th |F  |S  "
		cDia :="TODOS"
		cDia := IIF(Alltrim(aInfo[nCntFor])=="Su",STR0023,cDia)
		cDia := IIF(Alltrim(aInfo[nCntFor])=="M",STR0024,cDia)
		cDia := IIF(Alltrim(aInfo[nCntFor])=="T",STR0025,cDia)
		cDia := IIF(Alltrim(aInfo[nCntFor])=="W",STR0026,cDia)
		cDia := IIF(Alltrim(aInfo[nCntFor])=="Th",STR0027,cDia)
		cDia := IIF(Alltrim(aInfo[nCntFor])=="F",STR0028,cDia)
		cDia := IIF(Alltrim(aInfo[nCntFor])=="S",STR0029,cDia)
		aAdd(aIntIte,{cTipo,cDia, Left(aInfo[nCntFor + 1],2)+":"+Right(aInfo[nCntFor + 1],2)})
	endif
next
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

cLinhaEDI := cLinhaEDI + space(1000)

for nCntFor = 1 to Len(aLayout)
	//
	cTipo := aLayout[nCntFor,1]
	nTamanho := aLayout[nCntFor,2]
	nDecimal := aLayout[nCntFor,3]
	nPosIni := aLayout[nCntFor,4]
	//
	if nPosIni + nTamanho - 1 > Len(cLinhaEDI)
		return {}
	endif
	cStrTexto := Subs(cLinhaEDI,nPosIni,nTamanho)
	ncValor := ""
	if Alltrim(cTipo) == "N"
		for nCntFor2 := 1 to Len(cStrTexto)
			if !(Subs(cStrTexto,nCntFor2,1)$"0123456789 ")
				return {}
			endif
		next
		ncValor = VAL(cStrTexto) / (10 ^ nDecimal)
	elseif Alltrim(cTipo) == "D"
		cStrTexto := Left(cStrTexto,2)+"/"+subs(cStrTexto,3,2)+"/"+Right(cStrTexto,4)
		if ctod(cStrTexto) == ctod("  /  /  ")
			return {}
		endif
		ncValor := ctod(cStrTexto)
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
// aAdd(aSX1,{cPerg,"01","Parâmetro 1","","","MV_CH1","C",40,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S"})
// aAdd(aSX1,{cPerg,"02","Parâmetro 2","","","MV_CH2","C",40,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S"})
// aAdd(aSX1,{cPerg,"03","Parâmetro 3","","","MV_CH3","C",40,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S"})

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
