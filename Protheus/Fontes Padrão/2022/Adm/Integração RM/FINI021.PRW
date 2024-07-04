#Include "Protheus.ch"
#Include "FINI021.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Fini020   ºAutor  ³Alberto Deviciente  º Data ³ 24/Nov/2009 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³listagem dos alunos pertencentes as NFs selecionadas        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Financeiro - NF-e Educacional com Integracao RM            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fini021(cAlias, nReg)
Local cString:= "FRJ"
Local aOrd	 := {} 
Local Titulo := STR0001		//"Lista de ALUNOS X NF"
Local cDesc1 := STR0002		//"Listagem de Notas Fiscais geradas por Aluno/Responsável"
Local cDesc2 := ""
Local Tamanho:= "G"

Private cArqTmp := ""
Private aReturn := { "Zebrado", 1,"Administracao", 2, 2, 1, "",1 } // "Zebrado" ### "Administracao"

Private wnrel   := "FRJ020Rel"
Private nomeprog:= "FRJ020Rel"
Private nLastKey:= 0
m_pag:= 1
if FRJ->FRJ_STATUS == '1' 
	//Atencao/Este processo não está efetivado. Somente processos efetivados podem emitir este relatório."
	Aviso(STR0018,STR0020, {STR0019} ) //"Somente processos que possuem todas as Notas Fiscais geradas podem emitir este relatório."
	Return( NIL )
endif

dbSelectArea( "FRJ" )
wnrel := SetPrint(cString,wnrel,"",@titulo,cDesc1,cDesc2," ",.F.,aOrd,,Tamanho)

If nLastKey == 27
	Set Filter To
	Return
EndIf

SetDefault(aReturn,cString)

If nLastKey == 27
	Set Filter To
	Return
EndIf

// Chamada da rotina de armazenamento de dados...
Processa({||F021RelRun() })


// Chamada da rotina de impressao do relat¢rio...
RptStatus({|lEnd|F021ImpRel(aOrd,"", "", Titulo,cDesc1, cDesc2, Tamanho )})


Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³F020ImpRelºAutor  ³ Alberto Deviciente º Data ³ 24/Nov/2009 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Imprime o relatorio apos a query generica realizada.        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Financeiro - NF-e Educacional com Integracao RM            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function F021ImpRel( aOrd, Cabec1, Cabec2, Titulo, cDesc1, cDesc2, Tamanho )
Local nLin		:= 8
Local nValTot	:= 0
Local nTotAlu	:= 0
Local nValGerTot:= 0
Local nTotGerAlu:= 0
Local cNomCli 	:= ""
Local cRaAnterior:= ""
Local nTotReg 	:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o cabecalho³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Cabec1 := STR0010 + Replicate(" ",5)
Cabec1 += STR0011 + Replicate(" ",5)
Cabec1 += STR0012 + Replicate(" ",5)
Cabec1 += STR0013 + Replicate(" ",5)
Cabec1 += STR0014 + Replicate(" ",16)
Cabec1 += STR0015 + Replicate(" ",32)
Cabec1 += STR0016 + Replicate(" ",5)
Cabec1 += STR0017 

Cabec( Titulo,Cabec1, Cabec2, NomeProg, Tamanho, If(aReturn[4]==1,15,18) )

QRYREL->( dbEval( {|| nTotReg++ } ) )
QRYREL->( DbGoTop() )

SetRegua(nTotReg)

while QRYREL->( !eof() )
	
	IncRegua()
	
	if nLin > 56
		@ nLin,000 PSAY __PrtThinLine()
		nLin++
		@ nLin, 28 psay PadL( STR0003 + Transform( nValTot, "@E 999,999,999.99" ), 37 ) //"Valor Total: "
		@ nLin, 86 psay PadL( STR0004 + Transform( nTotAlu, "@E 99,999.99" ), 37 ) //"Total de alunos: "
		nLin++
		@ nLin,000 PSAY __PrtThinLine()
		nLin++
		@ ++nLin, 000 psay PadL( STR0005 , 132 ) //continua...
		nLin := 8
		Cabec( Titulo,Cabec1, Cabec2, NomeProg, Tamanho, If(aReturn[4]==1,15,18) )
		@ nLin++, 000 psay STR0006 //...continuação
		nLin++
		
		nTotGerAlu += nTotAlu
		nValGerTot += nValTot
		
		nValTot := 0
		nTotAlu := 0
	endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o cancelamento pelo usuario...                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lAbortPrint
	   @nLin,00 PSAY STR0007 //"*** CANCELADO PELO OPERADOR ***"
	   Exit
	Endif
	
	// Zera contador de paginas para cara NF
	//m_pag := 1
	
	nValTot += QRYREL->VALOR
	
	if QRYREL->RA <> cRaAnterior
		nTotAlu++
		cRaAnterior := QRYREL->RA
	endif
	
    cNomCli := Posicione("SA1",1,xFilial("SA1")+QRYREL->FRK_CLIENT, "A1_NOME")
	
	/*      10        20        30        40        50        60        70        80        90       100       110       120       130       140       150       160
	123456789/123456789/123456789/123456789/123456789/123456789/123456789/123456789/123456789/123456789/123456789/123456789/123456789/123456789/123456789/123456789/12
	Nota Fiscal     Serie     Data de Emissão     Valor da Nota     RA                         Nome                                         Resp/Cliente     Nome
	*/
	
	@ nLin, 000 psay Left( QRYREL->FRK_CHAVE1, 15 ) 											//Nota Fiscal
	@ nLin, 017 psay Left( QRYREL->FRK_CHAVE2, 10 ) 											//Serie
	@ nLin, 027 psay Transform( sTod(QRYREL->FRK_DTFAT), PesqPict("FRJ","FRJ_DTSIMU") ) 		//Data de Emissao
	@ nLin, 045 psay Transform(Round(QRYREL->VALOR,2), PesqPict("FRK","FRK_VALOR"))			//Valor da Nota
	@ nLin, 064 psay Left( QRYREL->RA, 20 ) 													//RA
	@ nLin, 091 psay Left( FI020NmAlu(SM0->M0_CODIGO,QRYREL->RA), 40 ) 						//Nome do Aluno
	@ nLin, 136 psay Left( QRYREL->FRK_CLIENT, 10 ) 											//Cod. Cliente / Responsavel
	@ nLin, 153 psay Left( cNomCli, 40 ) 														//Nome do Cliente / Responsavel
	nLin++
	
	QRYREL->( dbSkip() )
end

if nTotGerAlu == 0
	nTotGerAlu := nTotAlu
endif

if nValGerTot == 0
	nValGerTot := nValTot
endif

nLin++
@ nLin,000 PSAY __PrtThinLine()
nLin++
@ nLin, 22 psay PadL(STR0008 + Transform( nValGerTot, "@E 999,999,999.99" ), 37 ) //"Valor Total Geral: "
@ nLin, 80 psay PadL(STR0009 + Transform( nTotGerAlu, "@E 99,999,999" ), 37 ) //"Total Geral de Alunos: "
nLin++
@ nLin,000 PSAY __PrtThinLine()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza a execucao do relatorio...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SET DEVICE TO SCREEN

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se impressao em disco, chama o gerenciador de impressao...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

QRYREL->( dbCloseArea() )
dbSelectArea("FRJ")

Return( NIL )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³F020RelRunºAutor  ³ Alberto Deviciente º Data ³ 24/Nov/2009 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Processa o relatorio de Notas x Alunos                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Financeiro - NF-e Educacional com Integracao RM            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function F021RelRun()
Local cQuery	:= ""

dbSelectArea("FRK")

cQuery := "SELECT FRK_NOTA FRK_CHAVE1, FRK_SERIE FRK_CHAVE2, FRK_DTFAT, FRK_NUMRA RA, FRK_CLIENT, SUM(FRK_VALOR) VALOR "
cQuery += "  from " +RetSQLName("FRK")
cQuery += " where FRK_FILIAL = '"+xFilial("FRK")+"'"
cQuery += "   and FRK_NUMPRO = '"+FRJ->FRJ_NUMPRO+"'"
cQuery += "   and FRK_NOTA  <> ' '" 
cQuery += "   and D_E_L_E_T_ = ' '"
cQuery += " GROUP BY FRK_NOTA, FRK_SERIE, FRK_DTFAT, FRK_NUMRA, FRK_CLIENT"
cQuery += " ORDER BY FRK_CHAVE1, FRK_CHAVE2, FRK_DTFAT, FRK_NUMRA, FRK_CLIENT"
cQuery := ChangeQuery(cQuery)
dbUseArea(.T., "TopConn", TCGenQry(,,cQuery), "QRYREL", .F., .F.)

Return
