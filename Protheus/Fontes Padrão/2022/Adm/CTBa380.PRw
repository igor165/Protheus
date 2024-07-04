#INCLUDE "ctba380.ch"
#Include "PROTHEUS.Ch"


// 17/08/2009 -- Filial com mais de 2 caracteres

Static aFormBatch:={}
Static _oCTBA350

// TRADUÇÃO RELEASE P10 1.2 - 21/07/08
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CTBA380  ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 22.04.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calculo da Variacao Monetaria                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTBA380(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTBA380(lAutomato)

Local nOpca := 0
Local aSays := {}, aButtons := {}	
Local aCols	:= {}

Local lCC	:= .T.
Local lIT	:= .T.
Local lCL	:= .T.

Private cCadastro := STR0001 //"Calculo da Variacao Monetaria"

Default lAutomato := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01 // Data de Apuracao                                 ³
//³ mv_par02 // Numero do Lote			                         ³
//³ mv_par03 // Numero do SubLote		                         ³
//³ mv_par04 // Numero do Documento                              ³
//³ mv_par05 // Cod. Historico Padrao                            ³
//³ mv_par06 // Da Conta  		        						 ³
//³ mv_par07 // Ate a Conta                             		 ³
//³ mv_par08 // Moedas        			                         ³
//³ mv_par09 // Qual Moeda?                                      ³
//³ mv_par10 // Tipo de Saldo 				                     ³
//³ mv_par11 // Desmembra Lcto ?  			                     ³
//³ mv_par12 // Considera Criterio - Moeda / Plano de Contas     ³
//³ mv_par13 // Considera Centro de Custo               				                     ³
//³ mv_par14 // Considera Item Contábil                   			                     ³
//³ mv_par15 // Considera Classe de Valor                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Pergunte("CTB380",.f.)

If CTBMovSaldo("CTT")
	dbSelectArea("CTT")
EndIf
If CTBMovSaldo("CTD")
	dbSelectArea("CTD")
EndIf
If CTBMovSaldo("CTH")
	dbSelectArea("CTH")
EndIf

Ct380Moedas(aCols)
        
AADD(aSays, STR0002) //"O programa objetiva apurar a diferenca cambial (Variacao Monetaria) das moedas fortes."
AADD(aSays, STR0003) //"O Criterio de conversao e informado no cadastro da propria moeda, podendo ser"
AADD(aSays, STR0004) //"confirmado na rotina de acordo com os parametros. Os criterios existentes sao :"
AADD(aSays, STR0005) //"Medio - a taxa simples entre as cotacoes diarias do periodo."
AADD(aSays, STR0006) //"Mensal - a taxa do ultimo dia do mes ou do periodo contabil."
AADD(aSays, STR0007) //"Diario - taxa no dia do efetivo lancamento contabil."
AADD(aSays, STR0008) //"Informado - taxa a ser utilizada e informada."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o log de processamento                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ProcLogIni( aButtons )

AADD(aButtons, { 5,.T., 	{|| (Pergunte("CTB380",.T. ),Ct380Moedas(aCols), .T.) } } )
AADD(aButtons, { 18,.T., 	{|| Ct380StMdas(aCols) }, STR0014} ) //"Criterios das moedas"
AADD(aButtons, { 1,.T., 	{|| nOpca:= 1, If( ConaOk(),FechaBatch(), nOpca:=0 ) }} )
AADD(aButtons, { 2,.T., 	{|| FechaBatch() }} )

If !lAutomato
	FormBatch( cCadastro, aSays, aButtons )
Else
	nOpca:= 1
Endif

IF nOpca == 1
	If !CTBSerialI("CTBPROC","OFF")
		Return
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o log de processamento   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcLogAtu("INICIO")

	Processa({|lEnd| Ct380Proc(aCols,lCC,lIT,lCL)})

	CTBSerialF("CTBPROC","OFF")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o log de processamento   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcLogAtu("FIM")

Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ca380Proc ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 22.04.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Recalculo valor lanc moeda forte                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ca380Proc()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CONA380                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ct380Proc(aCols,lCC,lIT,lCL)

Local cHistorico 	:= ""
Local cLinha 		:= "001"
Local cSeqLan  		:= "000"
Local cDoc			:= ""
Local cTipo			:= ""
Local cMoeda		:= ""
Local cEmpOri		:= cEmpAnt
Local cFilOri		:= cFilAnt
Local cBloq			:= ""
Local cNumManLin 	:= CtbSoma1Li()		//Conteudo do parametro MV_NUMMAN convertido.
Local cAlias		:= ""
Local cFiltro		:= ""
Local cIndex		:= ""
Local cOrder		:= ""
                                                                                 
Local bHistorico                 

Local aValorLanc	:= {}

Local nSaldo, nSal1C, nSalMd, nCols, nCol
Local nInicio, nFim
Local CTF_LOCK		:= 0
Local nValorLanc	:= 0
Local nValor		:= 0
Local nIndex		:= 0
Local nGrava

//Variavel lFirst criada para verificar se eh a primeira vez que esta incluindo o 
//lancam. contabil. Se for a primeira vez (.T.),ira trazer 001 na linha. Se nao for 
//a primeira vez e for para repetir o lancamento anterior, ira atualizar a linha 
Local lFirst 		:= .T. 
Local lRet 			:= .F.
Local lAtSldBase	:= Iif(GetMv("MV_ATUSAL")== "S",.T.,.F.)                     
Local cCriter, nTaxa := 0, aColsOri, aMedias := CtbMedias(mv_par01)
Local __lCusto		:= .T. //CtbMovSaldo("CTT") .and. mv_par13 == 1 .and. lCC
Local __lItem	  	:= .T. //CtbMovSaldo("CTD") .and. mv_par14 == 1 .and. lIT
Local __lCLVL	  	:= .T. //CtbMovSaldo("CTH") .and. mv_par15 == 1 .and. lCL
Local aDatas		:= {}
Local dDataIni		:= CTOD("  /  /  ")
Local dDataFim		:= CTOD("  /  /  ")
Local lPodeGrv		:= .F.
Local aCampos		:={}

Local cArqTMP		:= ""
Local cContaRed		:= ""
Local cContaVM		:= ""
Local cCustoRed		:= ""
Local cCustoVM		:= ""
Local cItemRed		:= ""
Local cItemVM		:= ""
Local cClVlRed		:= ""
Local cClVLVM		:= ""
Local cOrdem		:= "1"

Local cFilCT1		:= ""
Local cFilCTT		:= ""
Local cFilCTD		:= ""
Local cFilCTH		:= ""

DEFAULT lCC := .F.
DEFAULT lIT := .F.
DEFAULT lCL	:= .F.

__lCusto	:= CtbMovSaldo("CTT") .and. mv_par13 == 1 .and. lCC
__lItem	  	:= CtbMovSaldo("CTD") .and. mv_par14 == 1 .and. lIT
__lCLVL	  	:= CtbMovSaldo("CTH") .and. mv_par15 == 1 .and. lCL

// Sub-Lote somente eh informado se estiver em branco
mv_par03 := If(Empty(GetMV("MV_SUBLOTE")), mv_par03, GetMV("MV_SUBLOTE"))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Antes de iniciar o processamento, verifico os parametros ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
Case Empty(mv_par01) // Data de referencia nao preenchida.
	Help(" ",1,"NOCTBDTLP")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o log de processamento com o erro  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcLogAtu("ERRO","NOCTBDTLP",Ap5GetHelp("NOCTBDTLP"))

Case Empty(mv_par02)	// Lote nao preenchido
	Help(" ",1,"NOCT280LOT")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o log de processamento com o erro  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcLogAtu("ERRO","NOCT280LOT",Ap5GetHelp("NOCT280LOT"))

Case Empty(mv_par03) // Sub Lote nao preenchido
	Help(" ",1,"NOCTSUBLOT")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o log de processamento com o erro  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcLogAtu("ERRO","NOCTSUBLOT",Ap5GetHelp("NOCTSUBLOT"))

Case Empty(mv_par04)	// Documento nao preenchido.
	Help(" ",1,"NOCT280DOC")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o log de processamento com o erro  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcLogAtu("ERRO","NOCT280DOC",Ap5GetHelp("NOCT280DOC"))

Case Empty(mv_par05) // Historico Padrao nao preenchido
	Help(" ",1,"CTHPVAZIO")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o log de processamento com o erro  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcLogAtu("ERRO","CTHPVAZIO",Ap5GetHelp("CTHPVAZIO"))

Case Empty(mv_par06) .And. Empty(mv_par07)// Rateio inicial e final nao preenchidos. 	
	Help(" ",1,"NOCT280RT")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o log de processamento com o erro  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcLogAtu("ERRO","NOCT280RT",Ap5GetHelp("NOCT280RT"))

Case (mv_par08 == 2 .And. Empty(mv_par09)) .Or. Len(aCols) = 0 // Moeda especifica nao preenchida
	Help(" ",1,"NOCTMOEDA")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o log de processamento com o erro  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcLogAtu("ERRO","NOCTMOEDA",Ap5GetHelp("NOCTMOEDA"))

Case Empty(mv_par10) // Tipo de saldo nao preenchido
	Help(" ",1,"NO280TPSLD")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o log de processamento com o erro  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcLogAtu("ERRO","NO280TPSLD",Ap5GetHelp("NO280TPSLD"))

OtherWise
	lRet := .T.	
EndCase	

If lRet	//Verificar se o calendario esta aberto
	lRet	:= CtbValiDt(1,mv_par01,,mv_par10)
EndIf

If lRet // Parametros validos, posiciona o CT8 (Historico padrao)
	dbSelectArea("CT8")
	dbSetOrder(1)
	If !dbSeek(xFilial("CT8")+mv_par05)
		//Historico Padrao nao existe no cadastro.
		Help(" ",1,"CT280NOHP")	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza o log de processamento com o erro  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ProcLogAtu("ERRO","CT280NOHP",Ap5GetHelp("CT280NOHP"))

		lRet := .F.
	Else
		cHistorico := ""
		If CT8->CT8_IDENT == 'C'
			cHistorico := Left(CT8->CT8_DESC,32)
			// Bloco para retornar a conta origem no historico
			bHistorico := {	||	Alltrim(cHistorico) + " " + StrZero(Month(mv_par01),2)+"/"+;
								StrZero(Year(mv_par01),4) } 
		Else
		    lRet	:= .F.  
		    Help(" ",1,"CT280NOHIS")	//Nao eh permitido escolher historico inteligente.		    

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza o log de processamento com o erro  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ProcLogAtu("ERRO","CT280NOHIS",Ap5GetHelp("CT280NOHIS"))
			
		Endif	
	Endif                               		
Endif	                                

If lRet	                   
	// Se for moeda especifica e se a moeda for '01'. 
	If mv_par08 == 2 .And. mv_par09 == '01'
		lRet  := .F.
		cMensagem	:= STR0017	//"Moeda nao podera ser '01'
		MsgAlert(cMensagem)
	EndIf
EndIf

If ! lRet
	Return
Endif

CTP->(DbSetOrder(1))

dbSelectArea("CT1")
dbSetOrder(1)
cFilCT1   := xFilial("CT1")
dbSelectArea("CTT")
dbSetOrder(1)
cFilCTT	  := xFilial("CTT")
dbSelectArea("CTD")
dbSetOrder(1)
cFilCTD   := xFilial("CTD")
dbSelectArea("CTH")
dbSetOrder(1)
cFilCTH	  := xFilial("CTH")

DbSelectArea("CTO")
dbSeek(xFilial()+"01",.T.)

aColsOri := Aclone(aCols)
///////////////////////////////////////////////////////////////////////////////////////
aCampos := {}
//aAdd( aCampos, { SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO,SX3->X3_DECIMAL } )
aAdd( aCampos, { "CONTA", "C", TamSX3("CT1_CONTA")[1],0 } )
aAdd( aCampos, { "CUSTO", "C", TamSX3("CTT_CUSTO")[1],0 } )
aAdd( aCampos, { "ITEM" , "C", TamSX3("CTD_ITEM")[1] ,0 } )
aAdd( aCampos, { "CLVL" , "C", TamSX3("CTH_CLVL")[1] ,0 } )
aAdd( aCampos, { "ORDEM", "C", 1                     ,0 } )
aAdd( aCampos, { "TABELA","C", 3                     ,0 } )
For nCols := 1 to Len(aCols)
	aAdd( aCampos, { "VLR"+aCols[nCols][1], "N", 17                    ,2 } )
Next

If _oCTBA350 <> Nil
	_oCTBA350:Delete()
	_oCTBA350 := Nil
Endif

_oCTBA350 := FWTemporaryTable():New( "TMP" )  
_oCTBA350:SetFields(aCampos) 
_oCTBA350:AddIndex("1", {"CONTA","ORDEM","CUSTO","ITEM","CLVL"})

//------------------
//Criação da tabela temporaria
//------------------
_oCTBA350:Create()  

dbSelectArea( "TMP" )
dbSetOrder(1)

///////////////////////////////////////////////////////////////////////////////////////
cAlias	:= "QRYTMP"

cQuery := " SELECT CQ1_CONTA CONTA ,'' CUSTO,'' ITEM,'' CLVL, '4' ORDEM, 'CQ1' TABELA " 
cQuery += " FROM "+RetSqlName("CQ1")+" CQ1, "+RetSqlName("CT1")+" CT1 "
cQuery += " WHERE CQ1.CQ1_FILIAL = '"+xFilial("CQ1")+"' "
cQuery += " AND CQ1.CQ1_CONTA BETWEEN '"+mv_par06+"' AND '"+mv_par07+"' "
If mv_par08 == 2
	cQuery += " AND CQ1_MOEDA IN ('01','"+mv_par09+"') "
EndIf
cQuery += " AND CQ1_DATA <= '"+DTOS(mv_par01)+"' "
cQuery += " AND CQ1_TPSALD = '"+mv_par10+"' "
cQuery += " AND CQ1.D_E_L_E_T_ = '' "
cQuery += " AND CT1.CT1_FILIAL = '"+xFilial("CT1")+"' "
cQuery += " AND CT1.CT1_CONTA = CQ1.CQ1_CONTA "
cQuery += " AND CT1.CT1_CLASSE = '2' AND CT1.CT1_CTAVM <> '' "
cQuery += " AND CT1.D_E_L_E_T_ = '' "
cQuery += " GROUP BY CQ1_CONTA"

If __lCusto 
	cQuery += " UNION "
	cQuery += " SELECT CQ3_CONTA CONTA ,CQ3_CCUSTO CUSTO,'' ITEM,'' CLVL, '3' ORDEM, 'CQ3' TABELA "
	cQuery += " FROM "+RetSqlName("CQ3")+" CQ3, "+RetSqlName("CTT")+" CTT, "+RetSqlName("CT1")+" CT1 "
	cQuery += " WHERE CQ3.CQ3_FILIAL = '"+xFilial("CQ3")+"' "
	cQuery += " AND CQ3.CQ3_CONTA BETWEEN '"+mv_par06+"' AND '"+mv_par07+"' "
	If mv_par08 == 2
		cQuery += " AND CQ3_MOEDA IN ('01','"+mv_par09+"') "
	EndIf
	cQuery += " AND CQ3_DATA <= '"+DTOS(mv_par01)+"' "
	cQuery += " AND CQ3_TPSALD = '"+mv_par10+"' "
	cQuery += " AND CQ3.D_E_L_E_T_ = '' "
	cQuery += " AND CTT.CTT_FILIAL = '"+xFilial("CTT")+"' "
	cQuery += " AND CTT.CTT_CUSTO = CQ3.CQ3_CCUSTO "
	cQuery += " AND CTT.CTT_CLASSE = '2' AND CTT.CTT_CCVM <> '' "
	cQuery += " AND CTT.D_E_L_E_T_ = '' "
	cQuery += " AND CT1.CT1_FILIAL = '"+xFilial("CT1")+"' "
	cQuery += " AND CT1.CT1_CONTA = CQ3.CQ3_CONTA "
	cQuery += " AND CT1.CT1_CLASSE = '2' AND CT1.CT1_CTAVM <> '' "
	cQuery += " AND CT1.D_E_L_E_T_ = '' "
	cQuery += " GROUP BY CQ3_CONTA,CQ3_CCUSTO " 
EndIf
If __lItem
	cQuery += " UNION "
	cQuery += " SELECT CQ5_CONTA CONTA ,CQ5_CCUSTO CUSTO,CQ5_ITEM ITEM,'' CLVL,'2' ORDEM, 'CQ5' TABELA " 
	cQuery += " FROM "+RetSqlName("CQ5")+" CQ5, "+RetSqlName("CTD")+" CTD, "+RetSqlName("CTT")+" CTT, "+RetSqlName("CT1")+" CT1 "
	cQuery += " WHERE CQ5.CQ5_FILIAL = '"+xFilial("CQ5")+"' "
	cQuery += " AND CQ5.CQ5_CONTA BETWEEN '"+mv_par06+"' AND '"+mv_par07+"' "
	If mv_par08 == 2
		cQuery += " AND CQ5_MOEDA IN ('01','"+mv_par09+"') "
	EndIf
	cQuery += " AND CQ5_DATA <= '"+DTOS(mv_par01)+"' "
	cQuery += " AND CQ5_TPSALD = '"+mv_par10+"' "
	cQuery += " AND CQ5.D_E_L_E_T_ = '' "
	cQuery += " AND CTD.CTD_FILIAL = '"+xFilial("CTD")+"' "
	cQuery += " AND CTD.CTD_ITEM = CQ5.CQ5_ITEM "
	cQuery += " AND CTD.CTD_CLASSE = '2' AND CTD.CTD_ITVM <> '' "
	cQuery += " AND CTD.D_E_L_E_T_ = '' "
	cQuery += " AND CTT.CTT_FILIAL = '"+xFilial("CTT")+"' "
	cQuery += " AND CTT.CTT_CUSTO = CQ5.CQ5_CCUSTO "
	cQuery += " AND CTT.CTT_CLASSE = '2' AND CTT.CTT_CCVM <> '' "
	cQuery += " AND CTT.D_E_L_E_T_ = '' "
	cQuery += " AND CT1.CT1_FILIAL = '"+xFilial("CT1")+"' "
	cQuery += " AND CT1.CT1_CONTA = CQ5.CQ5_CONTA "
	cQuery += " AND CT1.CT1_CLASSE = '2' AND CT1.CT1_CTAVM <> '' "
	cQuery += " AND CT1.D_E_L_E_T_ = '' "
	cQuery += " GROUP BY CQ5_CONTA,CQ5_CCUSTO,CQ5_ITEM" 
EndIf
If __lClvl
	cQuery += " UNION "
	cQuery += " SELECT CQ7_CONTA CONTA ,CQ7_CCUSTO CUSTO,CQ7_ITEM ITEM,CQ7_CLVL CLVL,'1' ORDEM, 'CQ7' TABELA " 
	cQuery += " FROM "+RetSqlName("CQ7")+" CQ7, "+RetSqlName("CTH")+" CTH, "+RetSqlName("CTD")+" CTD, "+RetSqlName("CTT")+" CTT, "+RetSqlName("CT1")+" CT1 "
	cQuery += " WHERE CQ7.CQ7_FILIAL = '"+xFilial("CQ7")+"' "
	cQuery += " AND CQ7.CQ7_CONTA BETWEEN '"+mv_par06+"' AND '"+mv_par07+"' "
	If mv_par08 == 2
		cQuery += " AND CQ7_MOEDA IN ('01','"+mv_par09+"') "
	EndIf
	cQuery += " AND CQ7_DATA <= '"+DTOS(mv_par01)+"' "
	cQuery += " AND CQ7_TPSALD = '"+mv_par10+"' "
	cQuery += " AND CQ7.D_E_L_E_T_ = '' "
	cQuery += " AND CTH.CTH_FILIAL = '"+xFilial("CTH")+"' "
	cQuery += " AND CTH.CTH_CLVL = CQ7.CQ7_CLVL "
	cQuery += " AND CTH.CTH_CLASSE = '2' AND CTH.CTH_CLVM <> '' "
	cQuery += " AND CTH.D_E_L_E_T_ = '' "
	cQuery += " AND CTD.CTD_FILIAL = '"+xFilial("CTD")+"' "
	cQuery += " AND CTD.CTD_ITEM = CQ7.CQ7_ITEM "
	cQuery += " AND CTD.CTD_CLASSE = '2' AND CTD.CTD_ITVM <> '' "
	cQuery += " AND CTD.D_E_L_E_T_ = ''  "
	cQuery += " AND CTT.CTT_FILIAL = '"+xFilial("CTT")+"' "
	cQuery += " AND CTT.CTT_CUSTO = CQ7.CQ7_CCUSTO "
	cQuery += " AND CTT.CTT_CLASSE = '2' AND CTT.CTT_CCVM <> '' "
	cQuery += " AND CTT.D_E_L_E_T_ = '' "
	cQuery += " AND CT1.CT1_FILIAL = '"+xFilial("CT1")+"' "
	cQuery += " AND CT1.CT1_CONTA = CQ7.CQ7_CONTA "
	cQuery += " AND CT1.CT1_CLASSE = '2' AND CT1.CT1_CTAVM <> '' "
	cQuery += " AND CT1.D_E_L_E_T_ = ''  "
	cQuery += " GROUP BY CQ7_CONTA,CQ7_CCUSTO, CQ7_ITEM,CQ7_CLVL " 
EndIf

cQuery += " ORDER BY CONTA,ORDEM,CUSTO,ITEM,CLVL "

cQuery := ChangeQuery(cQuery)

If Select("QRYTMP") > 0
	dbSelectArea("QRYTMP")
	dbCloseArea()
EndIf

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRYTMP",.T.,.T.)						

dbSelectArea("QRYTMP")				

/*
Completa a array de moedas */
CTO->(DbGoBottom())
aColsTmp := Array(Val(CTO->CTO_MOEDA) - 1)
Afill(aColsTmp,{})
If Len(aColsTmp) > Len(aCols)
	For nCol := 1 To Len(aCols)
		aColsTmp[Val(aCols[nCol,1]) - 1] := aClone(aCols[nCol])
	Next
	aCols := Aclone(aColsTmp)
Endif
	
/*-*/
cContaAtu := ""
cCustoAtu := ""
cItemAtu  := ""
cClvlAtu  := ""
// Adiciono a Moeda 1 pois eh necessario para o laco de gravacao na funcao GravaLanc
// e Depois ordeno a matriz
DbSelectArea(cAlias)
dbGoTop()
While (cAlias)->(!Eof())
            
	nInicio := If(mv_par08 = 1, 2, Val(mv_par09))               	
	
	nFim := nInicio
	
	If cContaAtu <> (cAlias)->CONTA
		CT1->(dbSeek(cFilCT1+(cAlias)->CONTA),.T.)
		cContaAtu := (cAlias)->CONTA
	EndIf    
	If __lCusto .and. cCustoAtu <> (cAlias)->(CUSTO)
		CTT->(dbSeek(cFilCTT+(cAlias)->CUSTO),.T.)
		cCustoAtu := (cAlias)->CUSTO
	EndIf
	If __lItem .and. cItemAtu <> (cAlias)->(ITEM)
		CTD->(dbSeek(cFilCTD+(cAlias)->ITEM),.T.)
		cItemAtu := (cAlias)->ITEM
	EndIf
	If __lClVl .and. cClVlAtu <> (cAlias)->(CLVL)
		CTH->(dbSeek(cFilCTH+(cAlias)->CLVL),.T.)
		cClVlAtu := (cAlias)->CLVL
	EndIf
			
	For nGrava := 1 To If(mv_par11 = 1, 2, 1)	
		For nCol := nInicio To nFim
			nCols	:= nCol-1	  //Para pegar a posicao correta do Acols
			cMoeda	:= aCols[nCols][1]

			If mv_par12 = 2
				If CT1->CT1_NORMAL = "1"
					cCriter := &("CT1->CT1_CVD" + cMoeda)
					IF cCriter != "A"
						If cCriter = "1" .And. CTP->(DbSeek(xFilial()+DTOS(mv_par01)+cMoeda))
							nTaxa := CTP->CTP_TAXA
						ElseIf cCriter $ "2/8"
							nTaxa := aMedias[nCols+1]
						ElseIf cCriter $ "3/7"
							aDatas 	:= CTBPeriodos(cMoeda,mv_par01,,, .F. )		// Retorna data inicial e final
						dbSelectArea("CTP")
						dbSetOrder(1)
							If MsSeek(xFilial()+DTOS(aDatas[1][2])+cMoeda)
								cBloq := If(cBloq = Nil, CTP->CTP_BLOQ, cBloq)
								If  cBloq <> "1"	// Moeda não bloqueada
								nTaxa := CTP->CTP_TAXA
								EndIf
							EndIf
							dbSelectArea(cAlias)
						Endif
						If cCriter <> "4" .And. nTaxa <> 0
							aCols[nCols][2] := cCriter
							aCols[nCols][6] := nTaxa
						Else
							aCols[nCols][2] := aColsOri[nCols][2]
							aCols[nCols][6] := aColsOri[nCols][6]
						Endif
					Endif
				Else
					cCriter := &("CT1->CT1_CVC" + cMoeda)
					IF cCriter != "A"
						If cCriter = "1" .And. CTP->(DbSeek(xFilial()+DTOS(mv_par01)+cMoeda))
							nTaxa := CTP->CTP_TAXA
						ElseIf cCriter $ "2/8"
							nTaxa := aMedias[nCols+1]
						ElseIf cCriter $ "3/7" 
							aDatas 	:= CTBPeriodos(cMoeda,mv_par01,,, .F. )		// Retorna data inicial e final	
							dbSelectArea("CTP")
							dbSetOrder(1)                                            
							If MsSeek(xFilial()+DTOS(aDatas[1][2])+cMoeda)
								cBloq := If(cBloq = Nil, CTP->CTP_BLOQ, cBloq)
								If cBloq <> "1"	// Moeda não bloqueada
									nTaxa := CTP->CTP_TAXA 
								EndIf
							EndIf	
							dbSelectArea(cAlias)
						Endif
						If cCriter <> "4" .And. nTaxa <> 0
							aCols[nCols][2] := cCriter
							aCols[nCols][6] := nTaxa
						Else
							aCols[nCols][2] := aColsOri[nCols][2]
							aCols[nCols][6] := aColsOri[nCols][6]
						Endif
					EndIf
				EndIf		
			Endif
	 		
			//Se utilizar criterio de conversao medio, calcula pelo movimento do periodo.
			If cCriter == "8"                       	
				aDatas 	:= CTBPeriodos("01",mv_par01,,, .F. )		// Retorna data inicial e final
				dDataIni:= aDatas[1][1]
				dDataFim:= aDatas[1][2]		
				If __lClVl .and. (cAlias)->TABELA == "CQ7"
					nSaldo := MovClass((cAlias)->CONTA,(cAlias)->CUSTO,(cAlias)->ITEM,(cAlias)->CLVL,dDataIni,dDataFim,"01",mv_par10,3)
				ElseIf __lItem .and. (cAlias)->TABELA == "CQ5"
					nSaldo := MovItem((cAlias)->CONTA,(cAlias)->CUSTO,(cAlias)->ITEM,dDataIni,dDataFim,"01",mv_par10,3)
				ElseIf __lCusto .and. (cAlias)->TABELA == "CQ3"
					nSaldo := MovCusto((cAlias)->CONTA,(cAlias)->CUSTO,dDataIni,dDataFim,"01",mv_par10,3)
				Else
					nSaldo := MovConta((cAlias)->CONTA,dDataIni,dDataFim,"01",mv_par10,3)
				EndIf
			Else	
				If  __lClvl .and. (cAlias)->TABELA == "CQ7"
					nSaldo := SaldoCTI((cAlias)->CONTA,(cAlias)->CUSTO,(cAlias)->ITEM,(cAlias)->CLVL,mv_par01,"01",mv_par10)[1]
				ElseIf __lItem .and. (cAlias)->TABELA == "CQ5"
					nSaldo := SaldoCT4((cAlias)->CONTA,(cAlias)->CUSTO,(cAlias)->ITEM,mv_par01,"01",mv_par10)[1]
				ElseIf __lCusto .and.  (cAlias)->TABELA == "CQ3"
					nSaldo := SaldoCT3((cAlias)->CONTA,(cAlias)->CUSTO,mv_par01,"01",mv_par10)[1]
				Else
					nSaldo := SaldoCt7((cAlias)->CONTA,mv_par01,"01",MV_PAR10)[1]
				EndIf
			EndIf
	
			nSal1C := Round(NoRound(nSaldo / aCols[nCols][6], 3),2)
			
			If cCriter == "8"     
				aDatas 	:= CTBPeriodos(aCols[nCols][1],mv_par01,,, .F. )		// Retorna data inicial e final
				dDataIni:= aDatas[1][1]
				dDataFim:= aDatas[1][2]		
			
				
				If  __lClvl .and. (cAlias)->TABELA == "CQ7"
					nSalMd := MovClass((cAlias)->CONTA,(cAlias)->CUSTO,(cAlias)->ITEM,(cAlias)->CLVL,dDataIni,dDataFim,aCols[nCols][1],mv_par10,3)
				ElseIf __lItem .and.  (cAlias)->TABELA == "CQ5"
					nSalMd := MovItem((cAlias)->CONTA,(cAlias)->CUSTO,(cAlias)->ITEM,dDataIni,dDataFim,aCols[nCols][1],mv_par10,3)
				ElseIf  __lCusto .and. (cAlias)->TABELA == "CQ3"
					nSalMd := MovCusto((cAlias)->CONTA,(cAlias)->CUSTO,dDataIni,dDataFim,aCols[nCols][1],mv_par10,3)
				Else
					nSalMd := MovConta((cAlias)->CONTA,dDataIni,dDataFim,aCols[nCols][1],mv_par10,3)
				EndIf
			Else			
				If  __lClVl .and. (cAlias)->TABELA == "CQ7"
					nSalMd := SaldoCTI((cAlias)->CONTA,(cAlias)->CUSTO,(cAlias)->ITEM,(cAlias)->CLVL,mv_par01,aCols[nCols][1],mv_par10)[1]
				ElseIf  __lItem .and. (cAlias)->TABELA == "CQ5"
					nSalMd := SaldoCT4((cAlias)->CONTA,(cAlias)->CUSTO,(cAlias)->ITEM,mv_par01,aCols[nCols][1],mv_par10)[1]
				ElseIf  __lCusto .and. (cAlias)->TABELA == "CQ3"
					nSalMd := SaldoCT3((cAlias)->CONTA,(cAlias)->CUSTO,mv_par01,aCols[nCols][1],mv_par10)[1]
				Else
					nSalMd := SaldoCt7((cAlias)->CONTA,mv_par01,aCols[nCols][1],MV_PAR10)[1]
				EndIf
			EndIf
			
			If 	(nGrava == 1 .And. (aCols[nCols][8] .And. aCols[nCols][6] > 0 .And.;
				(nSal1C <> nSalMd))) .Or. nGrava == 2
		
				nValorLanc := nSalMd - nSal1C
				
				cOrdem := (cAlias)->(ORDEM)
				If  (__lCusto .or. __lItem .or. __lCusto) .and. cOrdem > "1"
					nValJaLanc := 0	
					nRecTMP:= (cAlias)->(Recno())
					TMP->(dbSeek(cContaAtu+"1",.T.))
					While !Eof() .and. TMP->CONTA = cContaAtu .and. TMP->ORDEM < cOrdem
						If cOrdem == "2"		/// Processamento do Item Contabil
							If cCLVLAtu == TMP->CLVL
								nValJaLanc += &("TMP->VLR"+cMoeda)
							EndIf
						ElseIf cOrdem == "3"		/// Processamento do Centro de Custo
							If cITEMAtu == TMP->ITEM
								nValJaLanc += &("TMP->VLR"+cMoeda)
							EndIf
						ElseIf cOrdem == "1"
							nValJaLanc += &("TMP->VLR"+cMoeda)
						EndIf					
						TMP->(dbSkip())
					EndDo
					nValorLanc := nValorLanc - nValJaLanc
					TMP->(dbGoTo(nRecTMP))
				EndIf							    
		
				If nGrava	== 1
					AADD(aValorLanc,nValorLanc)
				EndIf

				If nGrava == 1		
					aCols[nCols][3] := Abs(nValorLanc)
				ElseIf nGrava == 2  
					If mv_par08 == 2                       //Se for Moeda especifica, a matriz aValorLanc so tera um elemento
						aCols[nCols][3] := Abs(aValorLanc[1])									
					Else						
						aCols[nCols][3] := Abs(aValorLanc[nCol-1])				
					EndIf
				EndIf
				aCols[nCols][4] := "1"

				If !Empty(CT1->CT1_CTARED)
					cContaRed := CT1->CT1_CTARED
				Else
					cContaRed := CT1->CT1_CONTA
				Endif
				cContaVM	:= CT1->CT1_CTAVM
				
				If __lCusto
					If !Empty(CTT->CTT_CCRED)
						cCustoRed := CTT->CTT_CCRED
					Else
						cCustoRed := CTT->CTT_CUSTO
					Endif
					cCustoVM  := CTT->CTT_CCVM
				Else
					cCustoVM  := ""
					cCustoRed := ""
				EndIf
				
				If __lItem
					If !Empty(CTD->CTD_ITRED)
						cItemRed := CTD->CTD_ITRED
					Else
						cItemRed := CTD->CTD_ITEM
					Endif
					cItemVM  := CTD->CTD_ITVM
				Else
					cItemVM  := ""
					cItemRed := ""				
				EndIf
				
				If __lClvl
					If !Empty(CTH->CTH_CLRED)
						cClVlRed := CTH->CTH_CLRED
					Else
						cClVlRed := CTH->CTH_CLVL
					Endif
					cClVlVM  := CTH->CTH_CLVM
				Else
					cClVlVM  := ""
					cClVlRed := ""				
				EndIf
				
			Else               
				If mv_par11 == 1 .And. nGrava == 1 
					AADD(aValorLanc,0)				
				EndIf				
			Endif

			If aCols[Val(cMoeda)-1][3] <> 0            

				aTravas := {}

				IF !Empty(CT1->CT1_CTAVM)
				   AADD(aTravas,CT1->CT1_CTAVM)
				Endif
				IF !Empty(cContaRed)
				   AADD(aTravas,cContaRed)
				Endif
				
				/// VERIFICA SE O SEMAFORO DE CONTAS PERMITE GRAVAÇÃO DOS LANÇAMENTOS/SALDOS
				If CtbCanGrv(aTravas,@lAtSldBase)

					BEGIN TRANSACTION
		
					If nCol == nInicio	//So ira criar novo documento se for a primeira moeda. 
					  	If lFirst .Or. cLinha > cNumManLin
							Do While !ProxDoc(mv_par01,mv_par02,mv_par03,@cDoc,@CTF_LOCK)
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Caso o N§ do Doc estourou, incrementa o lote         ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								cLote := CtbInc_Lot(cLote, cModulo)

							Enddo
							lFirst := .F.
							cLinha	:= "001"
						Endif		   	  			
					EndIf
					
					If Empty(cDoc)
						cDoc := "000001"	
					EndIf
			
					cSeqLan := Soma1(cSeqLan)
			            	
		           	cTipo  := If(mv_par11 = 1 .And. nGrava = 1, "1", If(nGrava = 2, "2", "3"))				                			
		
					If nGrava == 2 
						If mv_par08 == 2 //Se for moeda especifica
							nValorLanc	:= aValorLanc[1]				
						Else	
							nValorLanc	:= aValorLanc[nCol-1]
						EndIf
					EndIf	
		
					If nValorLanc < 0 
		  					If nCol = nInicio .And. ((nGrava = 1 .And. cTipo $ "1/3") .Or. (nGrava = 2 .And. cTipo $ '2/3'))
							//Grava lancamento zerado na moeda 01
							GravaLanc(	mv_par01,mv_par02,mv_par03,cDoc,cLinha,cTipo,'01',mv_par05,;
							cContaVM,cContaRed,;
							cCustoVM,cCustoRed,;
							cItemVM,cItemRed,;
							cClVlVM,cClVlRed,0.00,Eval(bHistorico),;
							mv_par10,cLinha,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,, "CTBA380")							
						EndIf
					
			  			GravaLanc(	mv_par01,mv_par02,mv_par03,cDoc,cLinha,cTipo,cMoeda,mv_par05,;
									cContaVM,cContaRed,;
									cCustoVM,cCustoRed,;
									cItemVM,cItemRed,;
									cClvlVM,cClVlRed,0.00,Eval(bHistorico),;
		  							mv_par10,cLinha,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,, "CTBA380")

						cLinha := Soma1(cLinha)

					Else 
						If nCol = nInicio .And. ((nGrava = 1 .And. cTipo $ "1/3") .Or. (nGrava = 2 .And. cTipo $ '2/3'))												
							//Grava lancamento zerado na moeda 01
							GravaLanc(	mv_par01,mv_par02,mv_par03,cDoc,cLinha,cTipo,'01',mv_par05,;
							cContaRed,cContaVM,;
							cCustoRed,cCustoVM,;
							cItemRed,cItemVM,;
							cClVlRed,cClVLVM,0.00,Eval(bHistorico),;
							mv_par10,cLinha,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,, "CTBA380")
						EndIf						
		  					   
						GravaLanc(	mv_par01,mv_par02,mv_par03,cDoc,cLinha,cTipo,cMoeda,mv_par05,;
							cContaRed,cContaVM,;
							cCustoRed,cCustoVM,;
							cItemRed,cItemVM,;
							cClVlRed,cClVLVM,0.00,Eval(bHistorico),;
							mv_par10,cLinha,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,, "CTBA380")
							
							cLinha := Soma1(cLinha)
								  	
					Endif         
	                
					///////////////////////////////////////////////////////////////////////////////////////
					/// GRAVA NO TMP PARA ABATER DO PRÓXIMO NIVEL
					///////////////////////////////////////////////////////////////////////////////////////
					If __lCusto .or. __lItem .or. __lClVl
						If TMP->(!dbSeek((cAlias)->(CONTA+cOrdem+CUSTO+ITEM+CLVL),.F.))											
							RecLock("TMP",.T.)
							CONTA := (cAlias)->CONTA
							CUSTO := (cAlias)->CUSTO
							ITEM  := (cAlias)->ITEM
							CLVL  := (cAlias)->CLVL
							ORDEM := cOrdem
						Else
							RecLock("TMP",.F.)
							&("VLR"+cMoeda) := nValorLanc
						EndIf
						TMP->(MsUnlock())							
					EndIf
					///////////////////////////////////////////////////////////////////////////////////////		
							
					cSeqLan := CT2->CT2_SEQLAN // Sequencia do lancamento  
		
					If cMoeda = '01'
						nValor	:= CT2->CT2_VALOR
					Else
						nValor	:= CtbVlrMoed(CT2->CT2_DATA,CT2->CT2_LOTE,CT2->CT2_SBLOTE,CT2->CT2_DOC,CT2->CT2_LINHA,CT2->CT2_TPSALD,cMoeda,CT2->CT2_EMPORI,CT2->CT2_FILORI) 				
					EndIf		
							
					CtbGravSaldo(	CT2->CT2_LOTE,CT2->CT2_SBLOTE,CT2->CT2_DOC,;
									CT2->CT2_DATA,cTipo,cMoeda,;
									CT2->CT2_DEBITO,CT2->CT2_CREDIT,;
									CT2->CT2_CCD,CT2->CT2_CCC,CT2->CT2_ITEMD,CT2->CT2_ITEMC,;
			 						CT2->CT2_CLVLDB,CT2->CT2_CLVLCR,nValor,;
			 						CT2->CT2_TPSALD,3,"","","","","","","","",0," ",;
		 							" ", "  ",  __lCusto,__lItem,__lClVL, 0.00,,,,,,,,,,,,,"+"/*cOperacao*/)					
					END TRANSACTION
                EndIf
	     		
				aCols[nCols][3] := 0.00
				aCols[nCols][4] := "2"
			EndIf
		Next	
	Next
	aValorLanc	:= {}
	DbSelectArea(cAlias)
	DbSkip()
EndDo

If CTF_LOCK > 0					/// LIBERA O REGISTRO NO CTF COM A NUMERCAO DO DOC FINAL
	dbSelectArea("CTF")
	dbGoTo(CTF_LOCK)
	CtbDestrava(mv_par01,mv_par02,mv_par03,cDoc,@CTF_LOCK)			
Endif

dbSelectArea(cAlias)
dbCloseArea()

If _oCTBA350 <> Nil
	_oCTBA350:Delete()
	_oCTBA350 := Nil
Endif

If Select("TMP") > 0
	TMP->(dbCloseArea())
EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Ct380Moedas ³ Autor ³ Wagner Mobile Costa ³ Data ³ 22.04.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega Array com as moedas para calculo de variacao       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ct380Moedas(aCols,cMoeda)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.					                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Ctba380    			                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array a ser preenchida com moedas para calculo     ³±±
±±³          ³ ExpC1 = Moeda especifica a ser recarregado aCols           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function Ct380Moedas(aCols, cMoeda)

Local aMedias	:= CtbMedias(mv_par01)
Local nTaxa		:= 0
Local nPosMoeda	:= 0
Local lAddCols	:= (Len(aCols) == 0)
Local cCriter	:= ""
Local cBloq		:= ""

dbSelectArea("CTO")
dbSetOrder(1)
If cMoeda = Nil
	dbSeek(xFilial())
Else
	dbSeek(xFilial()+cMoeda,.T.)
Endif
CTP->(DbSetOrder(1))

While !Eof() .And. xFilial() == CTO->CTO_FILIAL

    If CTO->CTO_MOEDA = "01"
    	DbSkip()
    	Loop
    Endif
    
	nTaxa 	:= 0.00
	If lAddCols
		cCriter := CTO->CTO_CRITER
	Else
		nPosMoeda := Ascan(aCols,{|colmoeda| colmoeda[1] == CTO->CTO_MOEDA})
		If nPosMoeda > 0
			cCriter := aCols[nPosMoeda][2]
		Else
			lAddCols := .T.
			cCriter := CTO->CTO_CRITER
		Endif
	Endif
	
	If cCriter = "1" .And. CTP->(DbSeek(xFilial()+DTOS(mv_par01)+CTO->CTO_MOEDA))
		nTaxa := CTP->CTP_TAXA
	ElseIf cCriter = "2"
		nTaxa := aMedias[Val(CTO->CTO_MOEDA)]
	ElseIf cCriter = "3" 
		aDatas 	:= CTBPeriodos(CTO->CTO_MOEDA,mv_par01,,, .F. )		// Retorna data inicial e final	
		dbSelectArea("CTP")
		dbSetOrder(1)                                            
		If MsSeek(xFilial()+DTOS(aDatas[1][2])+CTO->CTO_MOEDA)
			cBloq := If(cBloq = Nil, CTP->CTP_BLOQ, cBloq)
			If  cBloq <> "1"	// Moeda não bloqueada
				nTaxa := CTP->CTP_TAXA 
			EndIf
		EndIf	                
		dbSelectArea("CTO")
	ElseIf cCriter = "4"
		nTaxa := If(lAddCols, CTO->CTO_TXINF, aCols[nPosMoeda][6])
	Endif

	If lAddCols
		AADD(aCols, { CTO->CTO_MOEDA, CTO->CTO_CRITER, 0.00, "2", CTO->CTO_BLOQ,nTaxa, CTO->CTO_DESC, CTO->CTO_MOEDA <> "01" } )

	Else
		aCols[nPosMoeda][6] := nTaxa
	Endif
	
	If cMoeda <> Nil
		Exit
	Endif
	
	DbSkip()
EndDo

If cMoeda = Nil .And. Len(aCols) = 0
	DbSelectArea("CTO")
	dbSeek(xFilial()+"01",.T.)
	AADD(aCols, { "01", " ", 0.00, "2", "1", 0.00, CTO->CTO_DESC, .F. } )
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Ct380StMdas ³ Autor ³ Wagner Mobile Costa ³ Data ³ 22.04.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Edita status das moedas para calculo de variacao       	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ct380StMdas(aCols)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.					                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Ctba380    			                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array com as moedas a serem calculadas             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function Ct380StMdas(aCols)

Local nLeftLbx 	:= 05
Local oOk	  	:= LoadBitmap( GetResources(), "LBOK" )	
Local oNo	  	:= LoadBitmap( GetResources(), "LBNO" )
Local nUsado	:= 7
Local cPict		:= PesqPict("CTO","CTO_TXPRJ",TamSx3("CTO_TXPRJ")[1])
Local aColsAux  := {}
Local lC380VldTx := ExistBlock("C380VLDTX")

DEFINE MSDIALOG oDlg FROM 70,1 TO 220,480 TITLE STR0009 Pixel //"Moedas para calculo de variacao"

@ 12,nLeftLbx 	LISTBOX oLbx VAR cVar Fields;
				HEADER "", STR0010, STR0011, STR0012; //"Moeda"###"Criterio"###"Taxa"
				SIZE	((oDlg:nRight - oDlg:nLeft) / 2) - nLeftLbx - 8,;
				 		((oDlg:nBottom - oDlg:nTop) / 2) - 25;
				OF oDlg PIXEL NOSCROLL

oLbx:SetArray(aCols)
oLbx:bLine := { || {	If(	aCols[oLbx:nAt,nUsado + 1],oOk,oNo),;
							aCols[oLbx:nAt,7], aCols[oLbx:nAt,2],;
						Transform(aCols[oLbx:nAt,6],cPict) } }
						
oLbx:bLDblClick := {|| EditVariacao(@oLbx,@aCols,cPict),oLbx:GoRight(),oLbx:GoLeft()}
oLbx:Align := CONTROL_ALIGN_ALLCLIENT


ACTIVATE 	MSDIALOG oDlg Centered;
			ON INIT EnchoiceBar(oDlg,	{|| oDlg:End() },;		// Botao confirma
							  			{||oDlg:End() },,;		// Botao cancelar
					{ 	{ "DBG06"	, { || (aEval(oLbx:aArray, {|e| e[nUsado + 1] :=;
										    ! e[nUsado + 1] }),oLbx:Refresh()) }, STR0013, STR0015  } }) //"Inverte selecao"
										    
aColsAux := AClone(aCols) //Realizo a cópia do aCols no aColsAux
If lC380VldTx
	aCols := ExecBlock("C380VLDTX", .F., .F.,{aCols})
	If ValType(aCols) <> "A" //Valida o retorno do usuário
		aCols :=  AClone(aColsAux)  //Se o retorno do usuário não for valido retorno o conteúdo original do array
     EndIf
EndIf

Return .T.

Static Function EditVariacao(oLbx,aCols,cPicture)

Local nClick := 0, aCAtual := Aclone(aCols[oLbx:nAt])

nClick := oLbx:nAtCol(4)

If nClick <> 1
	aCols[oLbx:nAt][3] := aCols[oLbx:nAt][2]
	aCols[oLbx:nAt][4] := aCols[oLbx:nAt][6]

	lEditCell(@aCols,oLbx,"",3)
	oLbx:Refresh()

	If ! aCols[oLbx:nAt][3] $ "1234A"
		Help(" ",1,"ERRO_CRITE")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza o log de processamento com o erro  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ProcLogAtu("ERRO","ERRO_CRITE",Ap5GetHelp("ERRO_CRITE"))

		aCols[oLbx:nAt][3] := aCAtual[2]
	Endif
	
    If aCols[oLbx:nAt][3] = "4"		// Somente edita se for taxa informada
		lEditCell(@aCols,oLbx,cPicture,4)
	Endif

	aCols[oLbx:nAt][2] := aCols[oLbx:nAt][3]
	aCols[oLbx:nAt][6] := aCols[oLbx:nAt][4]

	aCols[oLbx:nAt][3] := aCAtual[3]
	aCols[oLbx:nAt][4] := aCAtual[4]
	
	Ct380Moedas(aCols, aCols[oLbx:nAt][1])
	
	oLbx:Refresh()
	oLbx:SetFocus()
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ FormBatch³ Autor ³ Juan Jose Pereira	    ³ Data ³ 04/12/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta tela generica para processo batch					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FormBatch( cTitle, aSays, aButtons, lOk, bValid )		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parƒmetros³ cTitle = Titulo da janela								  ³±±
±±³			 ³ aSays  = Array com Says 									  ³±±
±±³			 ³ aButtons = Array com bottoes								  ³±±
±±³			 ³ aButtons[i,1] = Tipo de botao 							  ³±±
±±³			 ³ aButtons[i,2] = Tipo de enabled							  ³±±
±±³			 ³ aButtons[i,3] = bAction 									  ³±±
±±³			 ³ aButtons[i,4] = Hint do Botao							  ³±±
±±³			 ³ bValid = Bloco de validacao do Form 						  ³±±
±±³			 ³ nAltura= Altura do Form em Pixel (Default 250)			  ³±±
±±³			 ³ nLargura = Largura do Form em Pixel (Default 520)		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
#DEFINE LARGURA_DO_SBUTTON 32

Static Function FormBatch( cTitle, aSays, aButtons, bValid, nAltura, nLargura )

Local nButtons:= Len(aButtons),;
nSays:= Len(aSays),;
oSay,;
i,nTop, nType, lEnabled, oFormPai, oFont, ;
nLarguraBox, nAlturaBox, nLarguraSay, cTextSay

DEFAULT aSays:={}, aButtons:={}
DEFAULT nAltura:= 250, nLargura:= 520

// Numero maximo de linhas //
If( nSays>7 )
	nSays:=7
EndIf

// Numero maximo de botoes //
If( nButtons>5 )
	nButtons:= 5
EndIf

oFormPai:= Atail(aFormBatch)
If( oFormPai==NIL )
	oFormPai:= oMainWnd
EndIf

DEFINE FONT oFont NAME "Arial" SIZE 0, -11

DEFINE MSDIALOG oDlg TITLE cTitle FROM 0,0 TO nAltura,nLargura OF oFormPai PIXEL

AADD(aFormBatch,oDlg)

nAlturaBox:= (nAltura-60)/2
nLarguraBox:= (nLargura-20)/2
@ 10,10 TO nAlturaBox,nLarguraBox OF oDlg PIXEL

//======================================================//
// monta says (bof)												 //
//======================================================//
nTop:=20

nLarguraSay:= nLarguraBox-30
for i:=1 to nSays
	cTextSay:= "{||'"+aSays[i]+"'}"
	oSay := TSay():New( nTop, 20, MontaBlock(cTextSay),oDlg,, oFont, .F., .F., .F., .T.,,, nLarguraSay, 10, .F., .F., .F., .F., .F. )
	nTop+= 10
next
//======================================================//
// monta says (eof)												 //
//======================================================//

//======================================================//
// monta bottoes(bof) 											 //
//======================================================//
nPosIni:= ((nLargura-20)/2) - (nButtons* LARGURA_DO_SBUTTON )
nAlturaButton:= nAlturaBox+10

for i:=1 to nButtons
	nType:= aButtons[i,1]
	lEnabled:= aButtons[i,2]
	
	DEFAULT lEnabled:= .T.
	
	If lEnabled
		If Len(aButtons[i]) > 3 .And. ValType(aButtons[i,4]) == "C"
			SButton():New( nAlturaButton, nPosIni, nType,aButtons[i,3],oDlg,.T.,aButtons[i,4])
		Else
			SButton():New( nAlturaButton, nPosIni, nType,aButtons[i,3],oDlg,.T.,,)
		Endif
	Else
		SButton():New( nAlturaButton, nPosIni, nType,,oDlg,.F.,,)
	EndIf
	
	nPosIni+= LARGURA_DO_SBUTTON
next
//======================================================//
// monta bottoes(bof) 											 //
//======================================================//
oDlg:Activate( ,,,.T.,bValid,,,, )

Return nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FechaBatch³ Autor ³ Juan Jose Pereira	    ³ Data ³ 04/12/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Fecha Ultima tela de batch 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FechaBatch()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FechaBatch()

Local oDlg:= Atail( aFormBatch )

oDlg:End()

ASize( aFormBatch,Len(aFormBatch)-1 )

Return nil        
