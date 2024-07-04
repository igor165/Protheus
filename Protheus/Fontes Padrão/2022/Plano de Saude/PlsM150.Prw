#INCLUDE "protheus.ch"
#INCLUDE "plsm150.ch"
 
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё PLSM150  Ё Autor Ё Cesar Valadao         Ё Data Ё 05/05/04 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Calculo da Programacao de Comissoes                        Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё PLSM150()                                                  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё SIGAPLS                                                    Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Alteracoes desde sua construcao inicial                               Ё╠╠
╠╠цддддддддддбддддддбдддддддддддддбддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Data     Ё BOPS Ё Programador Ё Breve Descricao                       Ё╠╠
╠╠цддддддддддеддддддедддддддддддддеддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё 19/05/06 Ё99557 Ё Sandro H.   Ё Inclusao Regras Composicao Base de    Ё╠╠
╠╠Ё          Ё      Ё             Ё Calculo das Comissoes                 Ё╠╠
╠╠юддддддддддаддддддадддддддддддддаддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

// Cabecalho da Meta da Comissao
#DEFINE M_TAM_ARRAY			 9				// Numero de elementos do array
#DEFINE M_CODINT			 1
#DEFINE M_CODEQU			 2
#DEFINE M_CODVEN			 3
#DEFINE M_TIPPLA			 4
#DEFINE M_TIPINC			 5
#DEFINE M_CODPRO			 6
#DEFINE M_IDMETA			 7
#DEFINE M_META				 8
#DEFINE M_REAL				 9

// Regras para Composicao da Base de Calculo das Comissoes
#DEFINE BC_TAM_ARRAY		 8				// Numero de elementos do array
#DEFINE BC_CODEQU			 1
#DEFINE BC_VLDINI			 2
#DEFINE BC_VLDFIM			 3
#DEFINE BC_GRUCOM			 4
#DEFINE BC_CODPRO			 5
#DEFINE BC_ID_VEN			 6
#DEFINE BC_CODVEN			 7
#DEFINE BC_SEQ    			 8

// Cabecalho da Regra de Calculo da Comissao
#DEFINE R_TAM_ARRAY			19				// Numero de elementos do array
#DEFINE R_CODINT			 1
#DEFINE R_TIPO  			 2   // ags tratar tipo
#DEFINE R_CODEQU			 3
#DEFINE R_CODVEN			 4
#DEFINE R_TIPPLA			 5
#DEFINE R_TIPINC			 6
#DEFINE R_GRUCOM			 7
#DEFINE R_CODPRO			 8
#DEFINE R_CODEMP			 9
#DEFINE R_CONEMP			10
#DEFINE R_SUBCON			11
#DEFINE R_TIPCOB			12
#DEFINE R_CODMUN			13  // AGS TRATAR COD.MUN.
#DEFINE R_FORCAL			14
#DEFINE R_TIPFOR			15
#DEFINE R_SEQ				16
#DEFINE R_ITENS				17
#DEFINE R_ORDEM 			18
#DEFINE R_RECNO     		19

// Itens da Regra de Calculo da Comissao
#DEFINE RI_TAM_ARRAY		16				// Numero de elementos do array
#DEFINE RI_METADE			 1
#DEFINE RI_METAAT			 2
#DEFINE RI_IDMETA			 3
#DEFINE RI_QTDDE			 4
#DEFINE RI_QTDATE			 5
#DEFINE RI_PERCON			 6
#DEFINE RI_VALCON			 7
#DEFINE RI_BENEF 			 8  // AGS TRATAR BENEF
#DEFINE RI_POSMET   		 9
#DEFINE RI_SEQBXN   		10
#DEFINE RI_META     		11
#DEFINE RI_REAL     		12
#DEFINE RI_SINIST   		13
#DEFINE RI_NIVSIN   		14
#DEFINE RI_SINIDE   		15
#DEFINE RI_SINIAT   		16

// Usuarios
#DEFINE US_TAM_ARRAY		21				// Numero de elementos do array
#DEFINE US_TIPPLA			 1
#DEFINE US_CODEMP			 2
#DEFINE US_MATRIC			 3
#DEFINE US_TIPREG			 4
#DEFINE US_DIGITO			 5
#DEFINE US_NOMUSR			 6
#DEFINE US_CONEMP			 7
#DEFINE US_NUMCON			 8
#DEFINE US_VERCON			 9
#DEFINE US_SUBCON			10
#DEFINE US_VERSUB			11
#DEFINE US_GRUCOM			12
#DEFINE US_CODPLA			13
#DEFINE US_VERSAO			14
#DEFINE US_TIPINC			15
#DEFINE US_TIPCOB			16
#DEFINE US_CODMUN			17   // AGS TRATAR COD.MUN.
#DEFINE US_REGRA			18
#DEFINE US_META				19
#DEFINE US_REGRBC			20
#DEFINE US_DATINC			21

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Funcao principal                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Function PLSM150()

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicializa variaveis                                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Local nOpca 		:= 0
Local aSays 		:= {}, aButtons := {}
Local nLog
Local aLogLista     := {}
Private cCadastro 	:= Fundesc() //"Calculo da ProgramaГЦo de ComissУes"
Private cPerg     	:= "PLM150"
Private aLog     		:= {}
Private lCalSom2Ven	:=	.F.//Indica se a comissao que sera calculada sera somente para o vendedor assistente.
private lMultCalc	:= GETNEWPAR("MV_PLMLTCM", .F. )

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta texto para janela de processamento                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
AADD(aSays,STR0002) //"Efetua o calculo da programaГЦo para pagamento de comissУes, "
AADD(aSays,STR0003) //"conforme parametros informados."
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta botoes para janela de processamento                                Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
AADD(aButtons, { 1,.T.,{|| nOpca:= 1, If( ConaOk(), FechaBatch(), nOpca:=0 ) }} )
AADD(aButtons, { 2,.T.,{|| FechaBatch() }} )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Exibe janela de processamento                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
FormBatch( cCadastro, aSays, aButtons,, 160 )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Processa calculo                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If  nOpca == 1
	msAguarde( {|| Pls150Calc() }, STR0004,"", .T.) //"Calculando ProgramaГЦo de ComissУes ..."
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica se existe log de ocorrencias                                    Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If  len(aLog) > 0
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta novo log somente com o que de fato precisa ser analisado           Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	For nLog := 1 to len(aLog)
		If  ! empty(aLog[nLog,4])
			Do Case
				Case aLog[nLog,4] == "1"        // nao encontrou regra para o usuario
					If  aLog[nLog,7] == "1"     // pessoa fisica - procura pela familia
						BXO->(dbSetOrder(1))
						cChave := aLog[nLog,5]
					Else                        // pessoa juridica - procura pelo subcontrato
						BXO->(dbSetOrder(2))
						cChave := aLog[nLog,6]
					Endif
					If  BXO->(msSeek(xFilial("BXO")+cChave))
						Loop
					Endif
				Case aLog[nLog,4] == "2"        // nao encontrou regra para a familia
					BXO->(dbSetOrder(1))       // pessoa fisica - procura pela familia
					cChave := aLog[nLog,5]
					If  BXO->(msSeek(xFilial("BXO")+cChave))
						Loop
					Endif
				Case aLog[nLog,4] == "3"        // nao encontrou regra para o subcontrato
					BXO->(dbSetOrder(2))       // pessoa fisica - procura pelo subcontrato
					cChave := aLog[nLog,6]
					If  BXO->(msSeek(xFilial("BXO")+cChave))
						Loop
					Endif
			EndCase
		Endif
		aadd(aLogLista,{aLog[nLog,1],aLog[nLog,2],aLog[nLog,3]})
	Next
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifica se existe log a ser exibido                                     Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If  len(aLogLista) > 0
		PLSCRIGEN(aLogLista,{{STR0005,"@!",70},{STR0006,"@!",80},{STR0007,"@!",200}},STR0008,nil,nil) //"Identificacao"###"Conteudo"###"Mensagem"###"Calculo da ProgramaГЦo para Pagamento de ComissУes - Log de Ocorrencias"
	Endif
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim do programa                                                          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    ЁPLS150CALCЁ Autor Ё Cesar Valadao         Ё Data Ё 05/05/04 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Calcula comissoes                                          Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё PLS150CALC()                                               Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Static Function PLS150CALC(lAutomacao)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicializa variaveis                                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Local i
Local l101
Local l102
Local l103
Local lCODVE2 := BA1->(FieldPos("BA1_CODVE2")) > 0 .And. BQC->(FieldPos("BQC_CODVE2")) > 0
Local lEquipe := .F.
Private j, nTamRegra, nTamUsuario
Private cQuery, cSQLExec, lAchou
Private aMeta, aRegra, aUsuario, aRegrBC, aEquipe
Private nVend, aVend := {}									// Vendedores que efetuaram venda no periodo informado
Private lAchouMeta  // ags
Private lSEQBXS := BXO->(FieldPos("BXO_SEQBXS")) > 0

Default lAutomacao := .F.
//зддддддддддддддддддддддддддддддд©
//Ё MV_PAR01 - Mes Base Movimento Ё
//Ё MV_PAR02 - Ano Base Movimento Ё
//Ё MV_PAR03 - Operadora          Ё
//Ё MV_PAR04 - Empresa de         Ё
//Ё MV_PAR05 - Empresa Ate        Ё
//Ё MV_PAR06 - Contrato De        Ё
//Ё MV_PAR07 - Contrato Ate       Ё
//Ё MV_PAR08 - Sub-Contrato De    Ё
//Ё MV_PAR09 - Sub-Contrato Ate   Ё
//Ё MV_PAR10 - Vendedor De        Ё
//Ё MV_PAR11 - Vendedor Ate       Ё
//Ё MV_PAR12 - Equipe De          Ё
//Ё MV_PAR13 - Equipe Ate         Ё
//Ё MV_PAR14 - Processamento      Ё
//Ё MV_PAR15 - Mes Sinistralidade Ё
//Ё MV_PAR16 - % Sinistralidade   Ё
//Ё MV_PAR19 - Cons. Mes/Ano acimaЁ
//юддддддддддддддддддддддддддддддды
Pergunte(cPerg,.F.)
cMes    := mv_par01
cAno    := mv_par02
cOper   := mv_par03
cEmpDe  := mv_par04
cEmpAte := mv_par05
cConDe  := mv_par06
cConAte := mv_par07
cSubDe  := mv_par08
cSubAte := mv_par09
cVenDe  := mv_par10
cVenAte := mv_par11
cEquDe  := mv_par12
cEquAte := mv_par13
nProc   := mv_par14
nMesSin := mv_par15
nPerSin := mv_par16
dDatDe  := mv_par17
dDatAte := mv_par18

nMes    := val(cMes) - nMesSin
nAno    := val(cAno)
If  nMes < 1
	nMes := 12 + nMes
	nAno := nAno - 1
Endif
csMes := strzero(nMes,2)
csAno := strzero(nAno,4)
If  nProc <> 1 .and. ;
	nProc <> 2
	msgalert(STR0009) // "Tipo de processamento invalido - escolha Calculo ou Descalculo"
	Return()
Endif
lCalSom2Ven	:=	.F.
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Query para verificar se ja houve calculo                                   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
dbSelectArea("BXO")
dbSelectArea("BXP")
dbSelectArea("BXQ")
cQuery := " SELECT COUNT(*) COUNT "
cQuery += "   FROM " + RetSQLName("BXO") + " BXO"
cQuery += "  WHERE BXO.BXO_FILIAL =  '"  + xFilial("BXO") + "'"
cQuery += "    AND BXO.BXO_CODINT =  '"  + cOper          + "'"
cQuery += "    AND BXO.BXO_CODEMP >= '"  + cEmpDe         + "'"
cQuery += "    AND BXO.BXO_CODEMP <= '"  + cEmpAte        + "'"
cQuery += "    AND BXO.BXO_NUMCON >= '"  + cConDe         + "'"
cQuery += "    AND BXO.BXO_NUMCON <= '"  + cConAte        + "'"
cQuery += "    AND BXO.BXO_SUBCON >= '"  + cSubDe         + "'"
cQuery += "    AND BXO.BXO_SUBCON <= '"  + cSubAte        + "'"
cQuery += "    AND BXO.BXO_CODVEN >= '"  + cVenDe         + "'"
cQuery += "    AND BXO.BXO_CODVEN <= '"  + cVenAte        + "'"
cQuery += "    AND BXO.BXO_CODEQU >= '"  + cEquDe         + "'"
cQuery += "    AND BXO.BXO_CODEQU <= '"  + cEquAte        + "'"
cQuery += "    AND BXO.BXO_ANO    =  '"  + cAno           + "'"
cQuery += "    AND BXO.BXO_MES    =  '"  + cMes           + "'"
cQuery += "    AND BXO.D_E_L_E_T_ = ' '"

cQuery := ChangeQuery(cQuery) 
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"BXOTMP",.F.,.T.) 

if !(lMultCalc)
	nQtdReg:= BXOTMP->COUNT
else
	if nProc==1
		nQtdReg := 0
	else
		nQtdReg := BXOTMP->COUNT
	endif
endif
BXOTMP->(dbCloseArea())
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Novo Calculo   e   Ja Tem Calculo Realizado                                Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If  nProc == 1 .and. nQtdReg > 0  .and. !(lMultCalc)
	If !lAutomacao
		Aviso(STR0011, STR0012, {"Ok"}) //"ProgramaГЦo de ComissУes"###"NЦo serА possМvel realizar novo cАlculo, pois jА existe programaГЦo calculada para os parametros informados. Selecione DescАlculo ou Reprocessar."
	EndIf
	Return()
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Cancelamento de Calculo                                                    Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If  nProc == 2  // Quer cancelar calculo
	If  nQtdReg == 0 // Nao Tem Calculo Realizado
		If !lAutomacao
			Aviso(STR0011, STR0013, {"Ok"}) //"ProgramaГЦo de ComissУes"###"NЦo И possМvel fazer o descАlculo, pois nЦo hА programaГЦo calculada para os parametros informados."
		EndIf
		Return()
	Else
		cQuery := " SELECT COUNT(*) COUNT "
		cQuery += "   FROM " + RetSQLName("BXO") + " BXO," + RetSQLName("BXQ") + " BXQ"
		cQuery += "  WHERE BXO.BXO_FILIAL =  '"  + xFilial("BXO") + "'"
		cQuery += "    AND BXO.BXO_CODINT =  '"  + cOper          + "'"
		cQuery += "    AND BXO.BXO_CODEMP >= '"  + cEmpDe         + "'"
		cQuery += "    AND BXO.BXO_CODEMP <= '"  + cEmpAte        + "'"
		cQuery += "    AND BXO.BXO_NUMCON >= '"  + cConDe         + "'"
		cQuery += "    AND BXO.BXO_NUMCON <= '"  + cConAte        + "'"
		cQuery += "    AND BXO.BXO_SUBCON >= '"  + cSubDe         + "'"
		cQuery += "    AND BXO.BXO_SUBCON <= '"  + cSubAte        + "'"
		cQuery += "    AND BXO.BXO_CODVEN >= '"  + cVenDe         + "'"
		cQuery += "    AND BXO.BXO_CODVEN <= '"  + cVenAte        + "'"
		cQuery += "    AND BXO.BXO_CODEQU >= '"  + cEquDe         + "'"
		cQuery += "    AND BXO.BXO_CODEQU <= '"  + cEquAte        + "'"
		cQuery += "    AND BXO.BXO_ANO    =  '"  + cAno           + "'"
		cQuery += "    AND BXO.BXO_MES    =  '"  + cMes           + "'"
		cQuery += "    AND BXO.D_E_L_E_T_ = ' '"
		cQuery += "    AND BXQ.BXQ_FILIAL =  '"  + xFilial("BXQ") + "'"
		cQuery += "    AND BXQ.BXQ_CODINT =  BXO.BXO_CODINT "
		cQuery += "    AND BXQ.BXQ_CODEMP =  BXO.BXO_CODEMP "
		cQuery += "    AND BXQ.BXQ_NUMCON =  BXO.BXO_NUMCON "
		cQuery += "    AND BXQ.BXQ_SUBCON =  BXO.BXO_SUBCON "
		cQuery += "    AND BXQ.BXQ_CODVEN =  BXO.BXO_CODVEN "
		cQuery += "    AND BXQ.BXQ_CODEQU =  BXO.BXO_CODEQU "
		cQuery += "    AND BXQ.BXQ_ANO    =  BXO.BXO_ANO    "
		cQuery += "    AND BXQ.BXQ_MES    =  BXO.BXO_MES    "
		cQuery += "    AND BXQ.D_E_L_E_T_ = ' '"
		
		cQuery := ChangeQuery(cQuery) 
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"BXOTMP",.F.,.T.) 

		nQtdReg := BXOTMP->COUNT

		BXOTMP->(dbCloseArea())
		If !lMultCalc
			If  nQtdReg > 0 // Tem Programacao Calculada COM Comissao Ja Calculada
				If !lAutomacao
					Aviso(STR0011, STR0014, {"Ok"}) //"ProgramaГЦo de ComissУes"###"NЦo И possМvel fazer o descАlculo, pois jА existe comissЦo calculada para os parametros informados."
				EndIf
				Return()
			Endif
		Endif
	Endif
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica se deve excluir comissoes calculadas                              Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If  nProc == 2
	If lAutomacao .Or. Aviso(STR0011, STR0015, {STR0016, STR0017}) == 1 //"ProgramaГЦo de ComissУes"###"Todas as programaГУes para pagamento de comissУes, de acordo com os parametros informados, serЦo apagadas."###"Confirma"###"Cancelar"
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Efetuando a exclusao dos itens do calculo da comissao (Itens)     Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		dbSelectArea("BXO")
		dbSelectArea("BXP")
		If !lMultCalc
			cSQLExec := "SELECT R_E_C_N_O_ RECBXP FROM " + RetSqlName("BXP") + " BXP " 
			cSQLExec += "  WHERE BXP_FILIAL = '" + xFilial("BXP") + "'"
			cSQLExec += "    AND BXP_SEQBXO IN"
			cSQLExec += "        (SELECT BXO_SEQ FROM " + RetSqlName("BXO") + " BXO "
			cSQLExec += "         WHERE BXO.BXO_FILIAL =  '"  + xFilial("BXO") + "'"
			cSQLExec += "           AND BXO.BXO_CODINT =  '"  + cOper          + "'"
			cSQLExec += "           AND BXO.BXO_CODEMP >= '"  + cEmpDe         + "'"
			cSQLExec += "           AND BXO.BXO_CODEMP <= '"  + cEmpAte        + "'"
			cSQLExec += "           AND BXO.BXO_NUMCON >= '"  + cConDe         + "'"
			cSQLExec += "           AND BXO.BXO_NUMCON <= '"  + cConAte        + "'"
			cSQLExec += "           AND BXO.BXO_SUBCON >= '"  + cSubDe         + "'"
			cSQLExec += "           AND BXO.BXO_SUBCON <= '"  + cSubAte        + "'"
			cSQLExec += "           AND BXO.BXO_CODVEN >= '"  + cVenDe         + "'"
			cSQLExec += "           AND BXO.BXO_CODVEN <= '"  + cVenAte        + "'"
			cSQLExec += "           AND BXO.BXO_CODEQU >= '"  + cEquDe         + "'"
			cSQLExec += "           AND BXO.BXO_CODEQU <= '"  + cEquAte        + "'"
			cSQLExec += "           AND BXO.BXO_ANO    =  '"  + cAno           + "'"
			cSQLExec += "           AND BXO.BXO_MES    =  '"  + cMes           + "'"
			cSQLExec += "           AND BXO.D_E_L_E_T_ = ' ' )" 
			cSQLExec += "           AND BXP.D_E_L_E_T_ = ' '" 

			cSQLExec := ChangeQuery(cSQLExec)
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQLExec),"TMPBXP",.F.,.T.) 
			
			TMPBXP->(DbGoTop())
			Do While ! TMPBXP->(Eof())
				BXP->(DbGoTo(TMPBXP->RECBXP))
				RecLock("BXP", .F.)
				BXP->(DbDelete())
				BXP->(MsUnlock())
				TMPBXP->(DbSkip())
			EndDo
			TMPBXP->(DbCloseArea())
			TCRefresh("BXP")
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Efetuando a exclusao do calculo da comissao (Cabecalho) Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			cSQLExec := "SELECT R_E_C_N_O_ RECBXO FROM " + RetSqlName("BXO")
			cSQLExec += "  WHERE BXO_FILIAL =  '"  + xFilial("BXO") + "'"
			cSQLExec += "    AND BXO_CODINT =  '"  + cOper          + "'"
			cSQLExec += "    AND BXO_CODEMP >= '"  + cEmpDe         + "'"
			cSQLExec += "    AND BXO_CODEMP <= '"  + cEmpAte        + "'"
			cSQLExec += "    AND BXO_NUMCON >= '"  + cConDe         + "'"
			cSQLExec += "    AND BXO_NUMCON <= '"  + cConAte        + "'"
			cSQLExec += "    AND BXO_SUBCON >= '"  + cSubDe         + "'"
			cSQLExec += "    AND BXO_SUBCON <= '"  + cSubAte        + "'"
			cSQLExec += "    AND BXO_CODVEN >= '"  + cVenDe         + "'"
			cSQLExec += "    AND BXO_CODVEN <= '"  + cVenAte        + "'"
			cSQLExec += "    AND BXO_CODEQU >= '"  + cEquDe         + "'"
			cSQLExec += "    AND BXO_CODEQU <= '"  + cEquAte        + "'"
			cSQLExec += "    AND BXO_ANO    =  '"  + cAno           + "'"
			cSQLExec += "    AND BXO_MES    =  '"  + cMes           + "'"
			cSQLExec += "    AND " + RetSqlName("BXO")+".D_E_L_E_T_ = ' '" 

			cSQLExec := ChangeQuery(cSQLExec)
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQLExec),"TMPBXO",.F.,.T.) 

			TMPBXO->(DbGoTop())
			Do While ! TMPBXO->(Eof())
				BXO->(DbGoTo(TMPBXO->RECBXO))
				RecLock("BXO", .F.)
				BXO->(DbDelete())
				BXO->(MsUnlock())
				TMPBXO->(DbSkip())
			EndDo
			TMPBXO->(DbCloseArea())
			TCRefresh("BXO")
		Else
			CSQLEXEC := "SELECT R_E_C_N_O_ RECBXO FROM "+RETSQLNAME("BXO")+" BXO"
			CSQLEXEC += "  WHERE BXO.BXO_FILIAL =  '"+XFILIAL("BXO")+"'"
			CSQLEXEC += "    AND BXO.BXO_CODINT =  '"+COPER+"'"
			CSQLEXEC += "    AND BXO.BXO_CODEMP >= '"+CEMPDE+"'"
			CSQLEXEC += "    AND BXO.BXO_CODEMP <= '"+CEMPATE+"'"
			CSQLEXEC += "    AND BXO.BXO_NUMCON >= '"+CCONDE+"'"
			CSQLEXEC += "    AND BXO.BXO_NUMCON <= '"+CCONATE+"'"
			CSQLEXEC += "    AND BXO.BXO_SUBCON >= '"+CSUBDE+"'"
			CSQLEXEC += "    AND BXO.BXO_SUBCON <= '"+CSUBATE+"'"
			CSQLEXEC += "    AND BXO.BXO_CODVEN >= '"+CVENDE+"'"
			CSQLEXEC += "    AND BXO.BXO_CODVEN <= '"+CVENATE+"'"
			CSQLEXEC += "    AND BXO.BXO_CODEQU >= '"+CEQUDE+"'"
			CSQLEXEC += "    AND BXO.BXO_CODEQU <= '"+CEQUATE+"'"
			CSQLEXEC += "    AND BXO.BXO_ANO    =  '"+CANO+"'"
			CSQLEXEC += "    AND BXO.BXO_MES    =  '"+CMES+"'"
			CSQLEXEC += "    AND BXO.D_E_L_E_T_ = ' ' "
			CSQLEXEC += " 	 AND (SELECT COUNT(*) COUNT "
			CSQLEXEC += "    FROM "+RETSQLNAME("BXQ")+" BXQ"
			CSQLEXEC += "    WHERE BXQ.BXQ_FILIAL =  '"+XFILIAL("BXQ")+"'"
			CSQLEXEC += "    AND BXQ.BXQ_CODINT =  BXO.BXO_CODINT "
			CSQLEXEC += "    AND BXQ.BXQ_CODEMP =  BXO.BXO_CODEMP "
			CSQLEXEC += "    AND BXQ.BXQ_NUMCON =  BXO.BXO_NUMCON "
			CSQLEXEC += "    AND BXQ.BXQ_SUBCON = BXO.BXO_SUBCON  "
			CSQLEXEC += "    AND BXQ.BXQ_CODVEN = BXO.BXO_CODVEN "
			CSQLEXEC += "    AND BXQ.BXQ_CODEQU = BXO.BXO_CODEQU "
			CSQLEXEC += "    AND BXQ.BXQ_ANO    =  BXO.BXO_ANO   "
			CSQLEXEC += "    AND BXQ.BXQ_MES    =  BXO.BXO_MES   "
			CSQLEXEC += "    AND BXQ.D_E_L_E_T_ = ' ') = 0 "

			CSQLEXEC := ChangeQuery(CSQLEXEC) 
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,CSQLEXEC),"TMPBXO",.F.,.T.) 

			TMPBXO->(dbgotop())
			BXP->(dbsetorder(1))
			while .not. (TMPBXO->(eof()))
				BXO->(dbgoto(TMPBXO->RECBXO))
				if BXP->(dbseek(XFILIAL("BXP")+BXO->BXO_SEQ))
					while .not. (eof()) .and. BXP->BXP_SEQBXO=BXO->BXO_SEQ
						RECLOCK("BXP", .F. )
						BXP->(dbdelete())
						BXP->(MSUNLOCK())
						BXP->(dbskip())
					enddo
				endif
				RECLOCK("BXO", .F. )
				BXO->(dbdelete())
				BXO->(MSUNLOCK())
				TMPBXO->(dbskip())
			enddo
			TMPBXO->(dbclosearea())
		Endif
	Endif
	Return
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё                                                                          Ё
//Ё Identifica as formas de calculo a serem processadas                      Ё
//Ё                                                                          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lAutomacao
	msProcTxt(STR0018) //"Identificando as formas de calculo a serem processadas"
EndIf
l101 := .F.
l102 := .F.
l103 := .F.
BXJ->(dbSetOrder(1))
BXJ->(MsSeek(xFilial("BXJ")+cOper))
While ! BXJ->(EOF()) .And. BXJ->BXJ_FILIAL == xFilial("BXJ") ;
	.And. BXJ->BXJ_CODINT == cOper
	If (Empty(BXJ->BXJ_CODVEN) .Or. (BXJ->BXJ_CODVEN >= cVenDe .and. BXJ->BXJ_CODVEN <= cVenAte)) .and. ;
		( Empty(BXJ->BXJ_CODEQU) .Or. (BXJ->BXJ_CODEQU >= cEquDe .and. BXJ->BXJ_CODEQU <= cEquAte)) .and. ;
		IIf(Empty(BXJ->BXJ_VLDINI), .T., BXJ->BXJ_VLDINI <= dDatAte) .and. ;
		IIf(Empty(BXJ->BXJ_VLDFIM), .T., BXJ->BXJ_VLDFIM >= dDatAte)

		If  BXJ->BXJ_FORCAL == "101" ; l101 := .T. ; Endif
		If  BXJ->BXJ_FORCAL == "102" ; l102 := .T. ; Endif
		If  BXJ->BXJ_FORCAL == "103" ; l103 := .T. ; Endif
	Endif
	BXJ->(dbSkip())
End
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё                                                                          Ё
//Ё Monta o array de metas                                                   Ё
//Ё                                                                          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lAutomacao
	msProcTxt(STR0019) //"Carregando metas de vendas"
EndIf
aMeta := {}
cQuery := "SELECT * FROM "+RetSQLName("BXN")+" WHERE "
cQuery += " BXN_FILIAL = '"  + xFilial("BXN") + "' AND "
cQuery += " BXN_CODINT = '"  + cOper + "' AND "
cQuery += " BXN_ANO = '"  + cAno + "' AND "
cQuery += " D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY BXN_CODEQU, BXN_CODVEN DESC, BXN_TIPPLA, BXN_TIPINC DESC, BXN_CODPRO"

cQuery := ChangeQuery(cQuery) 
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"BXNTMP",.F.,.T.) 

While ! BXNTMP->(EOF())
	If  BXNTMP->BXN_TIPO $ "23"  // 1-Vendas 2-Comissao 3-Ambas
		AAdd(aMeta, Array(M_TAM_ARRAY))
		i := Len(aMeta)
		aMeta[i][M_CODINT] := BXNTMP->BXN_CODINT
		aMeta[i][M_CODEQU] := BXNTMP->BXN_CODEQU
		aMeta[i][M_CODVEN] := BXNTMP->BXN_CODVEN
		aMeta[i][M_TIPPLA] := BXNTMP->BXN_TIPPLA
		aMeta[i][M_TIPINC] := BXNTMP->BXN_TIPINC
		aMeta[i][M_CODPRO] := BXNTMP->BXN_CODPRO
		aMeta[i][M_IDMETA] := BXNTMP->BXN_SEQ
		aMeta[i][M_META  ] := &("BXNTMP->BXN_Q"+cMes)
		aMeta[i][M_REAL  ] := 0
	Endif
	BXNTMP->(dbSkip())
End
BXNTMP->(dbCloseArea())
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta vetor com equipes                                                    Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aEquipe := {}
BXL->(DbSetOrder(1))
BXM->(DbSetOrder(1))
BXL->(MsSeek(xFilial("BXL")))
Do While ! BXL->(Eof()) .And. BXL->BXL_FILIAL == xFilial("BXL")
	If  BXL->BXL_VLDINI <= dDatAte .And. ;
		(Empty(BXL->BXL_VLDFIM) .Or. BXL->BXL_VLDFIM >= dDatAte)
		BXM->(MsSeek(xFilial("BXM")+BXL->BXL_SEQ))
		Do While ! BXM->(Eof()) .And. BXM->BXM_FILIAL == xFilial("BXM") .And. ;
			BXM->BXM_SEQBXL == BXL->BXL_SEQ
			aAdd(aEquipe, { BXL->BXL_CODEQU, BXM->BXM_CODVEN, BXM->BXM_ID_VEN })
			BXM->(DbSkip())
		EndDo
	EndIf
	BXL->(DbSkip())
EndDo
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё                                                                          Ё
//Ё Seleciona novos usuarios incluidos no periodo informado e totaliza metas Ё
//Ё                                                                          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If  len(aMeta) > 0
	cQuery := "SELECT BG9.BG9_TIPO, BA1.BA1_CODINT, BA1.BA1_CODEMP, BA1.BA1_MATRIC, BA1.BA1_TIPREG, BA1.BA1_DIGITO "
	cQuery += ", BA1.BA1_NOMUSR, BA1.BA1_CONEMP, BA1.BA1_CODMUN, BA1.BA1_TIPINC "
	cQuery += ", BA1.BA1_CONEMP, BA1.BA1_VERCON, BA1.BA1_SUBCON, BA1.BA1_VERSUB "
	cQuery += ", BA1.BA1_CODPLA, BA1.BA1_VERSAO, BA3.BA3_CODPLA, BA3.BA3_VERSAO, BA3.BA3_TIPOUS "
  cQuery += ", BA1.BA1_TIPINC, BA1.BA1_CODINT, BA1.BA1_CODVEN, BA1.BA1_EQUIPE, BA1.BA1_DATINC "
	cQuery += "FROM "+RetSQLName("BA1")+" BA1, "+RetSQLName("BG9")+" BG9, "+RetSQLName("BA3")+" BA3"
	cQuery += "  WHERE BA1.BA1_CODINT = BA3.BA3_CODINT"
	cQuery += "    AND BA1.BA1_CODINT = BG9.BG9_CODINT"
	cQuery += "    AND BA1.BA1_CODEMP = BA3.BA3_CODEMP"
	cQuery += "    AND BA1.BA1_CODEMP = BG9.BG9_CODIGO"
	cQuery += "    AND BA1.BA1_MATRIC = BA3.BA3_MATRIC"
	cQuery += "    AND BA1.BA1_FILIAL = '"  + xFilial("BA1") + "'"
	cQuery += "    AND BA3.BA3_FILIAL = '"  + xFilial("BA3") + "'"
	cQuery += "    AND BG9.BG9_FILIAL = '"  + xFilial("BG9") + "'"
	cQuery += "    AND BA1.BA1_DATINC >= '" + DToS(dDatDe)  + "'"
	cQuery += "    AND BA1.BA1_DATINC <= '" + DToS(dDatAte)  + "'"
	cQuery += "    AND BA1.BA1_CODINT = '"  + cOper          + "'"
	cQuery += "    AND BG9.BG9_CODINT = '"  + cOper          + "'"
	cQuery += "    AND BA1.D_E_L_E_T_ = ' '"
	cQuery += "    AND BA3.D_E_L_E_T_ = ' '"
	cQuery += "    AND BG9.D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY BA1.BA1_CODPLA, BA3.BA3_CODPLA"

	If !lAutomacao
		msProcTxt(STR0020) //"Selecionando usuarios para determinar % de cumprimento da meta de vendas"
	EndIf
	
	cQuery := ChangeQuery(cQuery) 
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"BA1TMP",.F.,.T.) 

	BI3->(dbSetOrder(1))
	While !BA1TMP->(EOF())
		If !lAutomacao
			msProcTxt(STR0021 + BA1TMP->BA1_NOMUSR) //"Processando usuario (metas) "
		EndIf
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Posiciona BI3-Produto                                               Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If  ! empty(BA1TMP->BA1_CODPLA)
			cCodPro := BA1TMP->BA1_CODPLA
			cVersao := BA1TMP->BA1_VERSAO
		Else
			cCodPro := BA1TMP->BA3_CODPLA
			cVersao := BA1TMP->BA3_VERSAO
		Endif
		If  BI3->BI3_FILIAL+BI3->BI3_CODINT   +BI3->BI3_CODIGO+BI3->BI3_VERSAO <> ;
			xFilial("BI3") +BA1TMP->BA1_CODINT+cCodPro        +cVersao
			If  ! BI3->(MsSeek(xFilial("BI3")+BA1TMP->BA1_CODINT+cCodPro+cVersao))
				aadd(aLog,{STR0022,;
				cCodPro+"/"+cVersao,;
				STR0023,;
				"",;
				"",;
				"",;
				""}) //"Produto/Versao"###"Produto nao encontrado"
			Endif
		Endif
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Localiza a meta em que este usuario se encaixa                      Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		lAchou   := .F.
		nTamMeta := Len(aMeta)
		For i := 1 to nTamMeta
			If  ! Empty(aMeta[i][M_CODEQU]) .And. aMeta[i][M_CODEQU] != BA1TMP->BA1_EQUIPE
				Loop
			EndIf
			If  ! Empty(aMeta[i][M_CODVEN]) .And. aMeta[i][M_CODVEN] != BA1TMP->BA1_CODVEN
				Loop
			EndIf
			If  ! Empty(aMeta[i][M_TIPPLA]) .And. aMeta[i][M_TIPPLA] != BA1TMP->BA3_TIPOUS
				Loop
			EndIf
			If  ! Empty(aMeta[i][M_TIPINC]) .And. aMeta[i][M_TIPINC] != BA1TMP->BA1_TIPINC
				Loop
			EndIf
			If  ! Empty(aMeta[i][M_CODPRO]) .And. aMeta[i][M_CODPRO] != cCodPro
				Loop
			EndIf
			lAchou := .T.
			aMeta[i][M_REAL]++ 	// Acumula a quantidade de USUARIOS que enquadraram nesta meta
			Exit
		Next
		If  ! lAchou
			aadd(aLog,{STR0024,;
			cOper+"."+BA1TMP->BA1_CODEMP+"."+BA1TMP->BA1_MATRIC+"."+BA1TMP->BA1_TIPREG+"-"+BA1TMP->BA1_DIGITO,;
			STR0025,;
			"",;
			"",;
			"",;
			""}) //"Usuario"###"Usuario nao se encaixou em nenhuma meta cadastrada"
		Endif
		BA1TMP->(dbSkip())
	End
	BA1TMP->(dbCloseArea())
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё                                                                            Ё
//Ё Seleciona os vendedores e/ou equipe que realizaram vendas no periodo       Ё
//Ё                                                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cQuery := "SELECT DISTINCT BA1.BA1_CODVEN CODVEN, BA1.BA1_EQUIPE EQUIPE, BA1.BA1_DATINC DATINC "
If lCODVE2
	cQuery += ", BA1.BA1_CODVE2 CODVE2"
EndIf
cQuery += "   FROM "+RetSQLName("BA1")+" BA1"
cQuery += "  WHERE BA1.BA1_FILIAL = '"   + xFilial("BA1") + "'"
cQuery += "    AND BA1.BA1_DATINC >= '"  + DToS(dDatDe)  + "'"
cQuery += "    AND BA1.BA1_DATINC <= '"  + DToS(dDatAte)  + "'"
cQuery += "    AND BA1.BA1_CODINT = '"   + cOper          + "'"
cQuery += "    AND BA1.BA1_CODEMP >= '"  + cEmpDe         + "'"
cQuery += "    AND BA1.BA1_CODEMP <= '"  + cEmpAte        + "'"
cQuery += "    AND BA1.BA1_CONEMP >= '"  + cConDe         + "'"
cQuery += "    AND BA1.BA1_CONEMP <= '"  + cConAte        + "'"
cQuery += "    AND BA1.BA1_SUBCON >= '"  + cSubDe         + "'"
cQuery += "    AND BA1.BA1_SUBCON <= '"  + cSubAte        + "'"
If lCODVE2 .And. cVenDe == cVenAte
	cQuery += "    AND ( BA1.BA1_CODVEN = '" + cVenDe     + "'"
	cQuery += "    Or    BA1.BA1_CODVE2 = '" + cVenDe     + "')"
Else
	cQuery += "    AND BA1.BA1_CODVEN >= '"  + cVenDe      + "'"
	cQuery += "    AND BA1.BA1_CODVEN <= '"  + cVenAte     + "'"
EndIf
cQuery += "    AND BA1.BA1_EQUIPE >= '"  + cEquDe         + "'"
cQuery += "    AND BA1.BA1_EQUIPE <= '"  + cEquAte        + "'"
cQuery += "    AND (BA1.BA1_CODVEN <> '" + Space(TamSX3("BA1_CODVEN")[1])+"' OR BA1.BA1_EQUIPE <> '"+Space(TamSX3("BA1_EQUIPE")[1])+"')"
cQuery += "    AND BA1.D_E_L_E_T_ = ' ' "

cQuery += "UNION "
cQuery += "SELECT DISTINCT BQC.BQC_CODVEN CODVEN, BQC.BQC_EQUIPE EQUIPE, ' ' DATINC "
If lCODVE2
	cQuery += ", BQC.BQC_CODVE2 CODVE2 "
EndIf
cQuery += "   FROM "+RetSQLName("BA1")+" BA1,	"+RetSQLName("BQC")+" BQC "
cQuery += "  WHERE BA1.BA1_CODINT = BQC.BQC_CODINT "
cQuery += "    AND BA1.BA1_CODEMP = BQC.BQC_CODEMP "
cQuery += "    AND BA1.BA1_CONEMP = BQC.BQC_NUMCON "
cQuery += "    AND BA1.BA1_SUBCON = BQC.BQC_SUBCON "
cQuery += "    AND BA1.BA1_FILIAL = '"   + xFilial("BA1") + "'"
cQuery += "    AND BQC.BQC_FILIAL = '"   + xFilial("BQC") + "'"
cQuery += "    AND BA1.BA1_DATINC >= '"  + DToS(dDatDe)  + "'"
cQuery += "    AND BA1.BA1_DATINC <= '"  + DToS(dDatAte)  + "'"
cQuery += "    AND BA1.BA1_CODINT = '"   + cOper          + "'"
cQuery += "    AND BA1.BA1_CODEMP >= '"  + cEmpDe         + "'"
cQuery += "    AND BA1.BA1_CODEMP <= '"  + cEmpAte        + "'"
cQuery += "    AND BA1.BA1_CONEMP >= '"  + cConDe         + "'"
cQuery += "    AND BA1.BA1_CONEMP <= '"  + cConAte        + "'"
cQuery += "    AND BA1.BA1_SUBCON >= '"  + cSubDe         + "'"
cQuery += "    AND BA1.BA1_SUBCON <= '"  + cSubAte        + "'"
cQuery += "    AND ( BA1.BA1_CODVEN = ' '   AND BA1.BA1_CODVE2 = ' ' AND BA1.BA1_EQUIPE = ' ') "
If lCODVE2 .And. cVenDe == cVenAte
	cQuery += "    AND ( BQC.BQC_CODVEN = '" + cVenDe     + "'"
	cQuery += "    OR    BQC.BQC_CODVE2 = '" + cVenDe     + "')"
Else
	cQuery += "    AND BQC.BQC_CODVEN >= '"  + cVenDe      + "'"
	cQuery += "    AND BQC.BQC_CODVEN <= '"  + cVenAte     + "'"
EndIf
cQuery += "    AND BQC.BQC_EQUIPE >= '"  + cEquDe         + "'"
cQuery += "    AND BQC.BQC_EQUIPE <= '"  + cEquAte        + "'"
cQuery += "    AND (BQC.BQC_CODVEN <> '" + Space(TamSX3("BQC_CODVEN")[1])+"' OR BQC.BQC_EQUIPE <> '"+Space(TamSX3("BQC_EQUIPE")[1])+"')"
cQuery += "    AND BA1.D_E_L_E_T_ = ' ' "
cQuery += "    AND BQC.D_E_L_E_T_ = ' ' "

cQuery += "UNION "
cQuery += "SELECT DISTINCT BQC.BQC_CODVEN CODVEN, BQC.BQC_EQUIPE EQUIPE, ' ' DATINC "
If lCODVE2
	cQuery += ", BQC.BQC_CODVE2 CODVE2"
EndIf
cQuery += "   FROM "+RetSQLName("BQC")+" BQC"
cQuery += "  WHERE BQC.BQC_FILIAL = '"   + xFilial("BQC") + "'"
cQuery += "    AND BQC.BQC_DATCON >= '"  + DToS(dDatDe)  + "'"
cQuery += "    AND BQC.BQC_DATCON <= '"  + DToS(dDatAte)  + "'"
cQuery += "    AND BQC.BQC_CODINT = '"   + cOper          + "'"
cQuery += "    AND BQC.BQC_CODEMP >= '"  + cEmpDe         + "'"
cQuery += "    AND BQC.BQC_CODEMP <= '"  + cEmpAte        + "'"
cQuery += "    AND BQC.BQC_NUMCON >= '"  + cConDe         + "'"
cQuery += "    AND BQC.BQC_NUMCON <= '"  + cConAte        + "'"
cQuery += "    AND BQC.BQC_SUBCON >= '"  + cSubDe         + "'"
cQuery += "    AND BQC.BQC_SUBCON <= '"  + cSubAte        + "'"
cQuery += "    AND BQC.BQC_CODVEN >= '"  + cVenDe         + "'"
cQuery += "    AND BQC.BQC_CODVEN <= '"  + cVenAte        + "'"
cQuery += "    AND BQC.BQC_EQUIPE >= '"  + cEquDe         + "'"
cQuery += "    AND BQC.BQC_EQUIPE <= '"  + cEquAte        + "'"
cQuery += "    AND (BQC.BQC_CODVEN <> '" + Space(TamSX3("BQC_CODVEN")[1])+"' OR BQC.BQC_EQUIPE <> '"+Space(TamSX3("BQC_EQUIPE")[1])+"')"
cQuery += "    AND BQC.D_E_L_E_T_ = ' ' "
cQuery += "ORDER BY CODVEN, EQUIPE"
If !lAutomacao
	msProcTxt(STR0026) //"Selecionando equipes/vendedores que realizaram vendas por usuario no periodo"
EndIf

cQuery := ChangeQuery(cQuery) 
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"BA1TMP",.F.,.T.) 

If  BA1TMP->(EOF())
	BA1TMP->(dbCloseArea())
	If !lAutomacao
		Aviso(STR0011, STR0027, {"Ok"}) //"ProgramaГЦo de ComissУes"###"Com os parБmetros informados, nЦo foi possМvel localizar nenhum registro a ser processado."
	EndIf
	Return()
EndIf

While !BA1TMP->(EOF())
	//Esta selecionado somente um vendedor.
	If  lCODVE2 .And. cVenDe == cVenAte
		If BA1TMP->CODVEN == cVenDe
			AAdd(aVend, {BA1TMP->CODVEN, BA1TMP->EQUIPE,""})
		Else
			AAdd(aVend, {BA1TMP->CODVE2, BA1TMP->EQUIPE,""})
			lCalSom2Ven	:=	.T.
		EndIf
	Else
		AAdd(aVend, {BA1TMP->CODVEN, BA1TMP->EQUIPE, IIf(lCODVE2, BA1TMP->CODVE2, "")})
	EndIf

	cCodVend := BA1TMP->CODVEN
	cEquipe  := BA1TMP->EQUIPE
	// Se Nao informou Vendedor e Somente Equipe
	// e Nao tem regra de Equipe
	// PegarА regra de cada Vendedor da Equipe
	If Empty(cCodVend) .And. !Empty(cEquipe)
		//Verifica Se nao tem regra para Equipe
		cQuery := "SELECT * FROM "+RetSQLName("BXJ")+" WHERE "
		cQuery += " BXJ_FILIAL = '"  + xFilial("BXJ") + "' AND "
		cQuery += " BXJ_CODINT = '"  + cOper + "' AND "
		cQuery += " BXJ_TIPO = '3' AND "
		cQuery += " BXJ_CODEQU = '"  + cEquipe + "' AND "
		cQuery += " D_E_L_E_T_ = ' ' "
		
		cQuery := ChangeQuery(cQuery) 
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"BXJTMP",.F.,.T.) 

		If BXJTMP->(EOF())
			lEquipe:= .T.
			aVend := {}
			BXL->(dbSetOrder(1))
			BXL->(dbseek(xFilial("BXL")+cEquipe))
			If  BXL->BXL_VLDINI <= dDatAte .and. ;
				(empty(BXL->BXL_VLDFIM) .or. BXL->BXL_VLDFIM >= dDatAte)
				BXM->(dbseek(xFilial("BXM")+BXL->BXL_SEQ))
				While ! BXM->(eof()) .and. BXM->BXM_FILIAL == xFilial("BXM") .and. ;
					BXM->BXM_SEQBXL == BXL->BXL_SEQ
					aadd(aVend,{BXM->BXM_CODVEN,cEquipe,""})
					BXM->(dbSkip())
				End
			Endif
		Endif
		BXJTMP->(dbCloseArea())
	Endif
	BA1TMP->(dbSkip())
End
BA1TMP->(dbCloseArea())
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё                                                                            Ё
//Ё Processa comissao por usuario vendido                                      Ё
//Ё                                                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If  l101 .or. l102
	PLS150Usu(1,lEquipe,lAutomacao) // Vendedor 1
	If ! lCalSom2Ven
		PLS150Usu(3,lEquipe,lAutomacao) // Vendedor 2 (Assistente)
	EndIf
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё                                                                            Ё
//Ё Processa comissao por contrato vendido                                     Ё
//Ё                                                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If  l103
	PLS150BA3(1,lEquipe,lAutomacao) // Vendedor 1
	If ! lCalSom2Ven
		PLS150BA3(3,lEquipe,lAutomacao) // Vendedor 2 (Assistente)
	EndIf
	PLS150BQC(1,lEquipe,lAutomacao) // Vendedor 1
	If ! lCalSom2Ven
		PLS150BQC(3,lEquipe,lAutomacao) // Vendedor 2 (Assistente)
	EndIf
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da funcao                                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    ЁPLS150Usu Ё Autor Ё Cesar Valadao         Ё Data Ё 05/05/04 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Calcula comissoes por usuario vendido                      Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё PLS150Usu()                                                Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Static Function PLS150Usu(nVendUsu,lEquipe,lAutomacao)
Local nMeta,i,j,nVend

Local nInd
Local cID_Vend
Local nRegra
Local nRegrBC
Local cVendAnt
Local aRet
Local lGravaBXP
Local nQtdDe
Local nQtdAte
Local nPerCon
Local nValCon
Local cBenef

Local lSinist	:= .T.
Local nSinCalc	:= 0
Local nSiniDe	:= 0
Local nSiniAte	:= 0

Local cQuery      := ""
Local cLastOrdem  := ""
Local cBXOAntes   := ""
Local lBXK_SINIDE := BXK->(FieldPos("BXK_SINIDE")) > 0
Local lBXP_SINIST := BXP->(FieldPos("BXP_SINIST")) > 0
Local lPLS150P1   := ExistBlock("PLS150P1")
Local lPLS150P2   := ExistBlock("PLS150P2")
Local cEqpAnt	  :=''
Local aProgGeradas := {}
Local cChaveProgra := ""

Default lEquipe  := .F.
Default lAutomacao := .F.

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё                                                                            Ё
//Ё Processa cada vendedor/equipe selecionado                                  Ё
//Ё                                                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BXH->(dbSetOrder(1))
BXJ->(dbSetOrder(1))
BXK->(dbSetOrder(1))
BXN->(DbSetOrder(1))
aVend := ASort(aVend,,, { |x,y| 	x[2] < y[2] .And. x[1] < y[1] })

nTamVend := Len(aVend)
For nVend := 1 To nTamVend
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Se esta processando Assistentes e nao possui assistente, despreza      Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If nVendUsu == 3 .And. Empty(aVend[nVend][nVendUsu])
		Loop
	EndIf
	If (nVendUsu == 1 .And. aVend[nVend][1] == cVendAnt .And.  aVend[nVend][2] == cEqpAnt) .Or. ;
		(nVendUsu == 3 .And. aVend[nVend][1]+aVend[nVend][3] == cVendAnt)
		Loop
	EndIf
	cVendAnt := IIf(nVendUsu == 1, aVend[nVend][1], aVend[nVend][1]+aVend[nVend][3])
	cEqpAnt:= aVend[nVend][2]
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Carrega regras                                                         Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If !lAutomacao
		msProcTxt(STR0028 + aVend[nVend][2] + "/" + aVend[nVend][nVendUsu] + STR0029) //"Equipe/Vendedor "###" - Carregando regras"
	EndIf
	aRegra := {}
	cQuery := "SELECT * FROM "+RetSQLName("BXJ")+" WHERE "
	cQuery += " BXJ_FILIAL = '"  + xFilial("BXJ") + "' AND "
	cQuery += " BXJ_CODINT = '"  + cOper + "' AND "
	cQuery += " D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY BXJ_CODEQU, BXJ_CODVEN DESC, BXJ_TIPPLA, BXJ_TIPINC DESC, BXJ_CODPRO"

	cQuery := ChangeQuery(cQuery) 
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"BXJTMP",.F.,.T.) 

	While ! BXJTMP->(EOF())
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Localiza uma regra de acordo com o tipo do registro:                Ё
		//Ё Se tem somente VENDEDOR, o BXJ_TIPO sera = "1"                      Ё
		//Ё Se tem somente EQUIPE, o BXJ_TIPO sera = "2"                        Ё
		//Ё Se tem VENDEDOR e EQUIPE, o BXJ sera = "3"                          Ё
		//Ё Se o VENDEDOR esta em BRANCO, considera esta regra                  Ё
		//Ё a todos os VENDEDORES                                               Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If (Empty(BXJTMP->BXJ_CODVEN) .Or. BXJTMP->BXJ_CODVEN == aVend[nVend][nVendUsu]) .and. ;
			(Empty(BXJTMP->BXJ_CODEQU) .Or. BXJTMP->BXJ_CODEQU == aVend[nVend][2]) .and. ;
			BXJTMP->BXJ_FORCAL $ "101,102"

			BXJ->(Dbgoto(BXJTMP->R_E_C_N_O_))

			If !PLSINTVAL("BXJ","BXJ_VLDINI","BXJ_VLDFIM",ddatde) // Valida se a Dt.De esta no periodo
				// OU
				If !PLSINTVAL("BXJ","BXJ_VLDINI","BXJ_VLDFIM",ddatate) // Valida se a Dt.Ate esta no periodo
					BXJTMP->(Dbskip()) // Caso as datas nao esteja nenhum periodo
					Loop
				EndIf
			EndIf

			AAdd(aRegra, Array(R_TAM_ARRAY))
			i := Len(aRegra)
			aRegra[i][R_CODINT] := BXJTMP->BXJ_CODINT
			aRegra[i][R_TIPO  ] := BXJTMP->BXJ_TIPO
			aRegra[i][R_CODEQU] := BXJTMP->BXJ_CODEQU
			aRegra[i][R_CODVEN] := BXJTMP->BXJ_CODVEN
			aRegra[i][R_TIPPLA] := BXJTMP->BXJ_TIPPLA
			aRegra[i][R_TIPINC] := BXJTMP->BXJ_TIPINC
			aRegra[i][R_GRUCOM] := BXJTMP->BXJ_GRUCOM
			aRegra[i][R_CODPRO] := BXJTMP->BXJ_CODPRO
			aRegra[i][R_CODEMP] := BXJTMP->BXJ_CODEMP
			aRegra[i][R_CONEMP] := BXJTMP->BXJ_CONEMP
			aRegra[i][R_SUBCON] := BXJTMP->BXJ_SUBCON
			aRegra[i][R_TIPCOB] := BXJTMP->BXJ_TIPCOB
			aRegra[i][R_CODMUN] := BXJTMP->BXJ_CODMUN
			If BXH->(MsSeek(xFilial("BXH")+BXJTMP->BXJ_FORCAL))
				aRegra[i][R_FORCAL] := BXJTMP->BXJ_FORCAL
				aRegra[i][R_TIPFOR] := BXH->BXH_TIPFOR
			Else
				aRegra[i][R_FORCAL] := Space(Len(BXJTMP->BXJ_FORCAL))
				aRegra[i][R_TIPFOR] := Space(Len(BXH->BXH_TIPFOR))
				aadd(aLog,{STR0030,;
				BXJTMP->BXJ_FORCAL+"/"+BXJTMP->BXJ_SEQ,;
				STR0031,;
				"",;
				"",;
				"",;
				""}) //"Forma Calculo/Seq Regra"###"Forma de calculo nao encontrada"
			EndIf
			aRegra[i][R_SEQ  ] := BXJTMP->BXJ_SEQ
			aRegra[i][R_ITENS] := {}
			aRegra[i][R_ORDEM] := BXJTMP->BXJ_ORDEM
			aRegra[i][R_RECNO] := BXJTMP->R_E_C_N_O_

			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Monta os itens da regra                                        Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			BXK->(MsSeek(xFilial("BXK")+BXJTMP->BXJ_SEQ))
			While ! BXK->(EOF()) .And. BXK->BXK_FILIAL == xFilial("BXK") .And. BXK->BXK_SEQBXJ == BXJTMP->BXJ_SEQ
				AAdd(aRegra[i][R_ITENS], Array(RI_TAM_ARRAY))
				j := Len(aRegra[i][R_ITENS])
				aRegra[i][R_ITENS][j][RI_METADE] := BXK->BXK_METADE
				aRegra[i][R_ITENS][j][RI_METAAT] := BXK->BXK_METAAT
				aRegra[i][R_ITENS][j][RI_IDMETA] := BXK->BXK_IDMETA
				aRegra[i][R_ITENS][j][RI_QTDDE ] := BXK->BXK_QTDDE
				aRegra[i][R_ITENS][j][RI_QTDATE] := BXK->BXK_QTDATE
				aRegra[i][R_ITENS][j][RI_PERCON] := BXK->BXK_PERCON
				aRegra[i][R_ITENS][j][RI_VALCON] := BXK->BXK_VALCON
				aRegra[i][R_ITENS][j][RI_BENEF ] := BXK->BXK_BENEF
				aRegra[i][R_ITENS][j][RI_SINIST] := BXK->BXK_SINIST
				aRegra[i][R_ITENS][j][RI_NIVSIN] := BXK->BXK_NIVSIN
				If lBXK_SINIDE
					aRegra[i][R_ITENS][j][RI_SINIDE] := BXK->BXK_SINIDE
					aRegra[i][R_ITENS][j][RI_SINIAT] := BXK->BXK_SINIAT
				Else
					aRegra[i][R_ITENS][j][RI_SINIDE] := 0
					aRegra[i][R_ITENS][j][RI_SINIAT] := 0
				EndIf
				aRegra[i][R_ITENS][j][RI_POSMET] := 0
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Localiza a meta atrelada a esta regra                      Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If  BXK->BXK_METADE <> 0 .Or. BXK->BXK_METAAT <> 0
					lAchouMeta := .F.
					If  ! Empty(BXK->BXK_IDMETA)
						nMeta := AScan(aMeta, {|x| x[M_IDMETA] == BXK->BXK_IDMETA})
						If  nMeta > 0
							lAchouMeta := .T.
						Endif
					Else
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Caso nao exista o codigo da meta, localiza a meta pelo VENDEDOR e EQUIPE Ё
						//Ё comparando e localizando a meta que mais se adequa ao caso               Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						nTamMeta := Len(aMeta)
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё 1 - Procura uma meta identica a regra                                    Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						For nMeta := 1 To nTamMeta
							If  aMeta[nMeta][M_CODEQU] != aRegra[i][R_CODEQU]
								Loop
							EndIf
							If  aMeta[nMeta][M_CODVEN] != aRegra[i][R_CODVEN]
								Loop
							EndIf
							If  aMeta[nMeta][M_TIPPLA] != aRegra[i][R_TIPPLA]
								Loop
							EndIf
							If  aMeta[nMeta][M_TIPINC] != aRegra[i][R_TIPINC]
								Loop
							EndIf
							If  aMeta[nMeta][M_CODPRO] != aRegra[i][R_CODPRO]
								Loop
							EndIf
							lAchouMeta := .T.
							Exit
						Next
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё 2 - Procura uma meta que mais se pareca com a regra                      Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						If  ! lAchouMeta
							For nMeta := 1 To nTamMeta
								If !Empty(aMeta[nMeta][M_CODEQU]) .And. aMeta[nMeta][M_CODEQU] != aRegra[i][R_CODEQU]
									Loop
								EndIf
								If !Empty(aMeta[nMeta][M_CODVEN]) .And. aMeta[nMeta][M_CODVEN] != aRegra[i][R_CODVEN]
									Loop
								EndIf
								If !Empty(aMeta[nMeta][M_TIPPLA]) .And. aMeta[nMeta][M_TIPPLA] != aRegra[i][R_TIPPLA]
									Loop
								EndIf
								If !Empty(aMeta[nMeta][M_TIPINC]) .And. aMeta[nMeta][M_TIPINC] != aRegra[i][R_TIPINC]
									Loop
								EndIf
								If !Empty(aMeta[nMeta][M_CODPRO]) .And. aMeta[nMeta][M_CODPRO] != aRegra[i][R_CODPRO]
									Loop
								EndIf
								lAchouMeta := .T.
								Exit
							Next
						Endif
					EndIf
					If  ! lAchouMeta   // nMeta == 0
						aadd(aLog,{STR0032,;
						BXJTMP->BXJ_SEQ,;
						STR0033,;
						"",;
						"",;
						"",;
						""}) //"Seq Regra"###"A regra possui META DE/ATE preenchidos, mas nЦo foi localizado nenhuma meta no Cadastro de Metas"
					Else
						aRegra[i][R_ITENS][j][RI_POSMET] := nMeta
						aRegra[i][R_ITENS][j][RI_SEQBXN] := aMeta[nMeta][M_IDMETA]
						aRegra[i][R_ITENS][j][RI_META  ] := aMeta[nMeta][M_META  ]
						aRegra[i][R_ITENS][j][RI_REAL  ] := aMeta[nMeta][M_REAL  ]
					EndIf
				EndIf
				BXK->(dbSkip())
			End
		EndIf
		BXJTMP->(dbSkip())
	End
	BXJTMP->(dbCloseArea())
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifica se encontrou regra para o VENDEDOR E/OU EQUIPE                Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If  Len(aRegra) == 0
		aadd(aLog,{STR0034,;
		aVend[nVend][nVendUsu]+"/"+aVend[nVend][2],;
		STR0035,;
		"",;
		"",;
		"",;
		""}) //"Vendedor/Equipe"###"Vendedor/Equipe nЦo possui nenhuma regra cadastrada"
		Loop
	Endif

	If PLSALIASEX("BXS")
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Carrega regras de composicao da base de calculo das comissoes          Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		nInd := aScan(aEquipe, { |x| x[1]+x[2] == aVend[nVend][2]+aVend[nVend][nVendUsu] })
		If nInd > 0
			cID_VEND := aEquipe[nInd, 3]
		Else
			cID_VEND := ""
		EndIf
		If !lAutomacao
			msProcTxt(STR0036 + aVend[nVend][2] + "/" + aVend[nVend][nVendUsu] + "/" + cID_VEND+"-"+X3Combo("BXM_ID_VEND",cID_VEND) + STR0037) //"Equipe/Vendedor/ID Vend "###" - Carregando regras composicao base de calculo"
		EndIf
		aRegrBC := {}
		BXS->(DbSetOrder(1))
		BXS->(MsSeek(xFilial("BXS")+cOper))
		Do While ! BXS->(Eof()) .And. BXS->BXS_FILIAL == xFilial("BXS") ;
			.And. BXS->BXS_CODINT == cOper
			If (Empty(BXS->BXS_CODVEN) .Or. BXS->BXS_CODVEN == aVend[nVend][nVendUsu]) .And. ;
				(Empty(BXS->BXS_CODEQU) .Or. BXS->BXS_CODEQU == aVend[nVend][2]) .And. ;
				(Empty(BXS->BXS_ID_VEN) .Or. BXS->BXS_ID_VEN == cID_VEND)        .And. ;
				IIf(Empty(BXS->BXS_VLDINI), .T., BXS->BXS_VLDINI <= dDatAte)     .And. ;
				IIf(Empty(BXS->BXS_VLDFIM), .T., BXS->BXS_VLDFIM >= dDatAte)
				aAdd(aRegrBC, Array(BC_TAM_ARRAY))
				i := Len(aRegrBC)
				aRegrBC[i][BC_CODEQU] := BXS->BXS_CODEQU
				aRegrBC[i][BC_VLDINI] := BXS->BXS_VLDINI
				aRegrBC[i][BC_VLDFIM] := BXS->BXS_VLDFIM
				aRegrBC[i][BC_GRUCOM] := BXS->BXS_GRUCOM
				aRegrBC[i][BC_CODPRO] := BXS->BXS_CODPRO
				aRegrBC[i][BC_ID_VEN] := BXS->BXS_ID_VEN
				aRegrBC[i][BC_CODVEN] := BXS->BXS_CODVEN
				aRegrBC[i][BC_SEQ   ] := BXS->BXS_SEQ
			EndIf
			BXS->(dbSkip())
		EndDo
	Else
		aRegrBC := {}
	EndIf
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё                                                                        Ё
	//Ё Seleciona usuarios vendidos pelo vendedor/equipe                       Ё
	//Ё                                                                        Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cQuery := "SELECT BG9.BG9_TIPO, BA1.BA1_CODEMP, BA1.BA1_MATRIC, BA1.BA1_TIPREG, BA1.BA1_DIGITO, BA1.BA1_NOMUSR, BA1.BA1_CONEMP, BA1.BA1_CODMUN, BA1.BA1_TIPINC "
	cQuery += ", BA1.BA1_CONEMP, BA1.BA1_VERCON, BA1.BA1_SUBCON, BA1.BA1_VERSUB "
	cQuery += ", BA1.BA1_CODPLA BA1CODPLA, BA1.BA1_VERSAO, BA3.BA3_CODPLA BA3CODPLA, BA3.BA3_VERSAO "
	cQuery += ", BA1.BA1_TIPINC, BA1.BA1_CODINT, BA1.BA1_DATINC "
	cQuery += "FROM "+RetSQLName("BA1")+" BA1, "+RetSQLName("BG9")+" BG9, "+RetSQLName("BA3")+" BA3"
	cQuery += "  WHERE BA1.BA1_CODINT = BA3.BA3_CODINT"
	cQuery += "    AND BA1.BA1_CODINT = BG9.BG9_CODINT"
	cQuery += "    AND BA1.BA1_CODEMP = BA3.BA3_CODEMP"
	cQuery += "    AND BA1.BA1_CODEMP = BG9.BG9_CODIGO"
	cQuery += "    AND BA1.BA1_MATRIC = BA3.BA3_MATRIC"
	cQuery += "    AND BA1.BA1_FILIAL = '"  + xFilial("BA1")  + "'"
	cQuery += "    AND BA3.BA3_FILIAL = '"  + xFilial("BA3")  + "'"
	cQuery += "    AND BG9.BG9_FILIAL = '"  + xFilial("BG9")  + "'"
	cQuery += "    AND BA1.BA1_DATINC >= '" + DToS(dDatDe)   + "'"
	cQuery += "    AND BA1.BA1_DATINC <= '" + DToS(dDatAte)   + "'"
	cQuery += "    AND BA1.BA1_CODINT = '"  + cOper           + "'"
	cQuery += "    AND BG9.BG9_CODINT = '"  + cOper           + "'"
	cQuery += "    AND BA1.BA1_CODEMP >= '" + cEmpDe          + "'"
	cQuery += "    AND BA1.BA1_CODEMP <= '" + cEmpAte         + "'"
	cQuery += "    AND BA1.BA1_CONEMP >= '" + cConDe          + "'"
	cQuery += "    AND BA1.BA1_CONEMP <= '" + cConAte         + "'"
	cQuery += "    AND BA1.BA1_SUBCON >= '" + cSubDe          + "'"
	cQuery += "    AND BA1.BA1_SUBCON <= '" + cSubAte         + "'"
	//Tratamento para quando for calcular a comissao somente para um vendedor
	If lCalSom2Ven .And. cVenDe == cVenAte
		cQuery += "    AND BA1.BA1_CODVE2 = '"  + aVend[nVend][1] + "'"
	Else
		If !lEquipe
			cQuery += "    AND BA1.BA1_CODVEN = '"  + aVend[nVend][1] + "'"
		Endif
		If nVendUsu == 3
			cQuery += "    AND BA1.BA1_CODVE2 = '"  + aVend[nVend][3] + "'"
		EndIf
	EndIf
	cQuery += "    AND BA1.BA1_EQUIPE = '"  + aVend[nVend][2] + "'"
	cQuery += "    AND BA1.D_E_L_E_T_ = ' ' "
	cQuery += "    AND BA3.D_E_L_E_T_ = ' ' "
	cQuery += "    AND BG9.D_E_L_E_T_ = ' ' "

	cQuery += "    UNION "

	cQuery += " SELECT BG9.BG9_TIPO, BA1.BA1_CODEMP, BA1.BA1_MATRIC, BA1.BA1_TIPREG, BA1.BA1_DIGITO, BA1.BA1_NOMUSR, BA1.BA1_CONEMP, BA1.BA1_CODMUN, BA1.BA1_TIPINC "
	cQuery += ", BA1.BA1_CONEMP, BA1.BA1_VERCON, BA1.BA1_SUBCON, BA1.BA1_VERSUB "
	cQuery += ", BA1.BA1_CODPLA BA1CODPLA, BA1.BA1_VERSAO, BA3.BA3_CODPLA BA3CODPLA, BA3.BA3_VERSAO "
	cQuery += ", BA1.BA1_TIPINC, BA1.BA1_CODINT, BA1.BA1_DATINC "
	cQuery += " FROM "+RetSQLName("BA1")+" BA1, "+RetSQLName("BG9")+" BG9, "+RetSQLName("BA3")+" BA3, "+RetSQLName("BQC")+" BQC "
	cQuery += "  WHERE BA1.BA1_CODINT = BQC.BQC_CODINT "
	cQuery += "    AND BA1.BA1_CODEMP = BQC.BQC_CODEMP "
	cQuery += "    AND BA1.BA1_CONEMP = BQC.BQC_NUMCON "
	cQuery += "    AND BA1.BA1_SUBCON = BQC.BQC_SUBCON "
	cQuery += "    AND BA1.BA1_CODINT = BA3.BA3_CODINT "
	cQuery += "    AND BA1.BA1_CODINT = BG9.BG9_CODINT "
	cQuery += "    AND BA1.BA1_CODEMP = BA3.BA3_CODEMP "
	cQuery += "    AND BA1.BA1_CODEMP = BG9.BG9_CODIGO "
	cQuery += "    AND BA1.BA1_MATRIC = BA3.BA3_MATRIC "
	cQuery += "    AND BA1.BA1_FILIAL = '"  + xFilial("BA1")  + "'"
	cQuery += "    AND BA3.BA3_FILIAL = '"  + xFilial("BA3")  + "'"
	cQuery += "    AND BG9.BG9_FILIAL = '"  + xFilial("BG9")  + "'"
	cQuery += "    AND BQC.BQC_FILIAL = '"  + xFilial("BQC")  + "'"
	cQuery += "    AND BA1.BA1_DATINC >= '" + DToS(dDatDe)   + "'"
	cQuery += "    AND BA1.BA1_DATINC <= '" + DToS(dDatAte)   + "'"
	cQuery += "    AND BA1.BA1_CODINT = '"  + cOper           + "'"
	cQuery += "    AND BG9.BG9_CODINT = '"  + cOper           + "'"
	cQuery += "    AND BA1.BA1_CODEMP >= '" + cEmpDe          + "'"
	cQuery += "    AND BA1.BA1_CODEMP <= '" + cEmpAte         + "'"
	cQuery += "    AND BA1.BA1_CONEMP >= '" + cConDe          + "'"
	cQuery += "    AND BA1.BA1_CONEMP <= '" + cConAte         + "'"
	cQuery += "    AND BA1.BA1_SUBCON >= '" + cSubDe          + "'"
	cQuery += "    AND BA1.BA1_SUBCON <= '" + cSubAte         + "'"
	//Tratamento para quando for calcular a comissao somente para um vendedor
	If lCalSom2Ven .And. cVenDe == cVenAte
		cQuery += "    AND BQC.BQC_CODVE2 = '"  + aVend[nVend][1] + "'"
	Else
		If !lEquipe
			cQuery += "    AND BQC.BQC_CODVEN = '"  + aVend[nVend][1] + "'"
		Endif
		If nVendUsu == 3
			cQuery += "    AND BQC.BQC_CODVE2 = '"  + aVend[nVend][3] + "'"
		EndIf
	EndIf
	cQuery += "    AND BQC.BQC_EQUIPE = '"  + aVend[nVend][2] + "'"
	cQuery += "    AND BA1.BA1_CODVEN = ' ' "
	cQuery += "    AND BA1.BA1_CODVE2 = ' ' "
	cQuery += "    AND BA1.BA1_EQUIPE = ' ' "
	cQuery += "    AND BA1.D_E_L_E_T_ = ' ' "
	cQuery += "    AND BA3.D_E_L_E_T_ = ' ' "
	cQuery += "    AND BG9.D_E_L_E_T_ = ' ' "
	cQuery += "    AND BQC.D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY BA1CODPLA, BA3CODPLA"
	If !lAutomacao
		msProcTxt(STR0028 + aVend[nVend][2] + "/" + aVend[nVend][nVendUsu] + STR0038) //"Equipe/Vendedor "###" - Selecionando usuarios"
	EndIf
	
	cQuery := ChangeQuery(cQuery) 
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"BA1TMP",.F.,.T.) 

	aUsuario := {}
	While !BA1TMP->(EOF())
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Posiciona BI3-Produto                                               Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If  ! empty(BA1TMP->BA1CODPLA)
			cCodPro := BA1TMP->BA1CODPLA
			cVersao := BA1TMP->BA1_VERSAO
		Else
			cCodPro := BA1TMP->BA3CODPLA
			cVersao := BA1TMP->BA3_VERSAO
		Endif
		If  BI3->BI3_FILIAL+BI3->BI3_CODINT+BI3->BI3_CODIGO+BI3->BI3_VERSAO <> ;
			xFilial("BI3") +BA1TMP->BA1_CODINT+cCodPro+cVersao
			If ! BI3->(MsSeek(xFilial("BI3")+BA1TMP->BA1_CODINT+cCodPro+cVersao))
				aadd(aLog,{STR0022,;
				cCodPro+"/"+cVersao,;
				STR0039,;
				"",;
				"",;
				"",;
				""}) //"Produto/Versao"###"Produto/Versao nao encontrado"
				BA1TMP->(dbSkip())
				Loop
			Endif
		Endif
		AAdd(aUsuario, Array(US_TAM_ARRAY))
		i := Len(aUsuario)
		aUsuario[i][US_TIPPLA] := BA1TMP->BG9_TIPO
		aUsuario[i][US_CODEMP] := BA1TMP->BA1_CODEMP
		aUsuario[i][US_MATRIC] := BA1TMP->BA1_MATRIC
		aUsuario[i][US_TIPREG] := BA1TMP->BA1_TIPREG
		aUsuario[i][US_DIGITO] := BA1TMP->BA1_DIGITO
		aUsuario[i][US_NOMUSR] := BA1TMP->BA1_NOMUSR
		aUsuario[i][US_CONEMP] := BA1TMP->BA1_CONEMP
		aUsuario[i][US_NUMCON] := BA1TMP->BA1_CONEMP
		aUsuario[i][US_VERCON] := BA1TMP->BA1_VERCON
		aUsuario[i][US_SUBCON] := BA1TMP->BA1_SUBCON
		aUsuario[i][US_VERSUB] := BA1TMP->BA1_VERSUB
		aUsuario[i][US_GRUCOM] := BI3->BI3_GRUCOM
		aUsuario[i][US_CODPLA] := cCodPro
		aUsuario[i][US_VERSAO] := cVersao
		aUsuario[i][US_TIPINC] := BA1TMP->BA1_TIPINC
		If  BI3->BI3_MODPAG <> "1"
			aUsuario[i][US_TIPCOB] := "1" // Custo Operacional
		Else
			If  BI3->BI3_CPFM == "0"
				aUsuario[i][US_TIPCOB] := "2" // Pre-Pagamento
			Else
				aUsuario[i][US_TIPCOB] := "3" // Pre-Pagamento com Co-Participacao
			Endif
		Endif
		aUsuario[i][US_CODMUN] := BA1TMP->BA1_CODMUN   // TRATAR COD.MUN.
		aUsuario[i][US_REGRA ] := 0
		aUsuario[i][US_META  ] := 0
		aUsuario[i][US_REGRBC] := 0
		aUsuario[i][US_DATINC] := BA1TMP->BA1_DATINC
		BA1TMP->(dbSkip())
	End
	BA1TMP->(dbCloseArea())
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Identifica em que regra cada usuario se enquadra                       Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	nTamMeta   := Len(aMeta)
	nTamRegra  := Len(aRegra)
	nTamUsuari := Len(aUsuario)
	For j := 1 To nTamUsuario
		cLastOrdem := ""
		For i := 1 To nTamRegra
			BXJ->(Dbgoto(aRegra[I][R_RECNO]))
			If !Empty(aRegra[i][R_TIPPLA]) .And. aRegra[i][R_TIPPLA] != aUsuario[j][US_TIPPLA]
				Loop
			EndIf
			If !Empty(aRegra[i][R_TIPINC]) .And. aRegra[i][R_TIPINC] != aUsuario[j][US_TIPINC]
				Loop
			EndIf
			If !Empty(aRegra[i][R_GRUCOM]) .And. aRegra[i][R_GRUCOM] != aUsuario[j][US_GRUCOM]
				Loop
			EndIf
			If !Empty(aRegra[i][R_CODPRO]) .And. aRegra[i][R_CODPRO] != aUsuario[j][US_CODPLA]
				Loop
			EndIf
			If !Empty(aRegra[i][R_CODEMP]) .And. aRegra[i][R_CODEMP] != aUsuario[j][US_CODEMP]
				Loop
			EndIf
			If !Empty(aRegra[i][R_CONEMP]) .And. aRegra[i][R_CONEMP] != aUsuario[j][US_CONEMP]
				Loop
			EndIf
			If !Empty(aRegra[i][R_SUBCON]) .And. aRegra[i][R_SUBCON] != aUsuario[j][US_SUBCON]
				Loop
			EndIf
			If !Empty(aRegra[i][R_TIPCOB]) .And. aRegra[i][R_TIPCOB] != aUsuario[j][US_TIPCOB]
				Loop
			EndIf
			If !Empty(aRegra[i][R_CODMUN]) .And. aRegra[i][R_CODMUN] != aUsuario[j][US_CODMUN]
				Loop
			EndIf
			If !PLSINTVAL("BXJ","BXJ_VLDINI","BXJ_VLDFIM",STOD(aUsuario[J][US_DATINC]))
			 	Loop
			Endif

			If Empty(cLastOrdem) .Or. aRegra[i][R_ORDEM] < cLastOrdem
				aUsuario[j][US_REGRA] := i			// Indica que o usuario foi classificado na REGRA (i)
				cLastOrdem := aRegra[i][R_ORDEM]
			EndIf
		Next

		If  aUsuario[j][US_REGRA] == 0
			aadd(aLog,{STR0024,;
			cOper+"."+aUsuario[j][US_CODEMP]+"."+aUsuario[j][US_MATRIC]+"."+aUsuario[j][US_TIPREG]+"-"+aUsuario[j][US_DIGITO],;
			STR0040,;
			"1",;
			aVend[nVend][1]+cOper+aUsuario[j][US_CODEMP]+aUsuario[j][US_MATRIC],;
			aVend[nVend][1]+cOper+aUsuario[j][US_CODEMP]+aUsuario[j][US_NUMCON]+aUsuario[j][US_VERCON]+aUsuario[j][US_SUBCON]+aUsuario[j][US_VERSUB],;
			aUsuario[j][US_TIPPLA]}) //"Usuario"###"Usuario nЦo se encaixou em nenhuma REGRA cadastrada"
		EndIf
	Next

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Identifica em que regra de base de calculo cada usuario se enquadra    Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	nTamRegra  := Len(aRegrBC)
	nTamUsuari := Len(aUsuario)
	For j := 1 To nTamUsuario
		For i := 1 To nTamRegra
			If !Empty(aRegrBC[i][BC_GRUCOM]) .And. aRegrBC[i][BC_GRUCOM] != aUsuario[j][US_GRUCOM]
				Loop
			EndIf
			If !Empty(aRegrBC[i][BC_CODPRO]) .And. aRegrBC[i][BC_CODPRO] != aUsuario[j][US_CODPLA]
				Loop
			EndIf
			aUsuario[j][US_REGRBC] := i // Indica que o usuario foi classificado na REGRA COMPOSICAO BASE CALCULO (i)
			Exit
		Next i
	Next j

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Grava Programacao para Calculo de Comissoes                            Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	BEGIN TRANSACTION
		BXO->(dbSetOrder(1))
		For i := 1 To nTamUsuari
			If !lAutomacao
				msProcTxt(STR0028 + aVend[nVend][2] + "/" + aVend[nVend][nVendUsu] + STR0041 + aUsuario[i][US_CODEMP] + "." + aUsuario[i][US_MATRIC] + "." + aUsuario[i][US_TIPREG] + "." + aUsuario[i][US_DIGITO]) //"Equipe/Vendedor "###" - Gravando regras p/ usuario "
			EndIf
			nRegra  := aUsuario[i][US_REGRA]  // Indica qual a regra o usuario foi classificado
			nRegrBC := aUsuario[i][US_REGRBC] // Indica qual a regra composicao base calculo o usuario foi classificado
			If  nRegra == 0
				Loop
			Endif
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Verifica se ja existe a programacao de calculo                     Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			cChaveProgra := aVend[nVend][nVendUsu]+cOper+aUsuario[i][US_CODEMP]+aUsuario[i][US_MATRIC]+aUsuario[i][US_TIPREG]+aUsuario[i][US_DIGITO]

			If ExistPrCal(xFilial("BXO")+cChaveProgra,cAno,cMes)
				If CheckGrvProg(aProgGeradas, cChaveProgra)
					aadd(aLog,{STR0042,;
					aVend[nVend][nVendUsu]+" "+cOper+"."+aUsuario[i][US_CODEMP]+"."+aUsuario[i][US_MATRIC]+"."+aUsuario[i][US_TIPREG]+"."+aUsuario[i][US_DIGITO],;
					STR0043,;
					"",;
					"",;
					"",;
					""}) //"Vendedor/usuario"###"Ja existe programacao de calculo de comissao para este vendedor/usuario - verifique"
				EndIf				
			Else
				RecLock("BXO",.T.)
				BXO->BXO_FILIAL := xFilial("BXO")
				BXO->BXO_SEQ    := GetSX8Num("BXO","BXO_SEQ")
				BXO->BXO_ANO    := cAno
				BXO->BXO_MES    := cMes
				BXO->BXO_DATA   := dDataBase
				BXO->BXO_CODEQU := aVend[nVend][2]
				BXO->BXO_CODVEN := aVend[nVend][nVendUsu]
				BXO->BXO_CODINT := cOper
				BXO->BXO_CODEMP := aUsuario[i][US_CODEMP]
				BXO->BXO_MATRIC := aUsuario[i][US_MATRIC]
				BXO->BXO_TIPREG := aUsuario[i][US_TIPREG]
				BXO->BXO_DIGITO := aUsuario[i][US_DIGITO]
				BXO->BXO_NUMCON := aUsuario[i][US_NUMCON]
				BXO->BXO_VERCON := aUsuario[i][US_VERCON]
				BXO->BXO_SUBCON := aUsuario[i][US_SUBCON]
				BXO->BXO_VERSUB := aUsuario[i][US_VERSUB]
				BXO->BXO_SEQBXJ := aRegra[nRegra][R_SEQ]
				If lSEQBXS
					BXO->BXO_SEQBXS := IIf(nRegrBC == 0, "", aRegrBC[nRegrBC][BC_SEQ])
				EndIf
				BXO->(MsUnLock())
				ConfirmSX8()

				aAdd(aProgGeradas, BXO->(BXO_CODVEN+BXO_CODINT+BXO_CODEMP+BXO_MATRIC+BXO_TIPREG+BXO_DIGITO))
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Verifica todos os itens da regra e grava os que se enquadram       Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				nTamRegrIT := Len(aRegra[nRegra][R_ITENS])
				cBXOAntes  := ""
				For j := 1 To nTamRegrIT
					lMetaOk := .F.
					lSinist := .T.
					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Se esta regra possui meta, calcula e verifica se atingiu a meta Ё
					//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					If  aRegra[nRegra][R_ITENS][j][RI_METADE] <> 0 .Or. aRegra[nRegra][R_ITENS][j][RI_METAAT] <> 0
						If  aRegra[nRegra][R_ITENS][j][RI_POSMET] > 0
							nQtdMeta := If(aRegra[nRegra][R_ITENS][j][RI_META]==0,0.1,aRegra[nRegra][R_ITENS][j][RI_META]) // para evitar erro de divisao por zero
							nQtdReal := aRegra[nRegra][R_ITENS][j][RI_REAL]
							nResult  := NoRound((nQtdReal / nQtdMeta) * 100,0)
							If  nResult >= aRegra[nRegra][R_ITENS][j][RI_METADE] .And. ;
								nResult <= aRegra[nRegra][R_ITENS][j][RI_METAAT]
								lMetaOk := .T.
							EndIf
						Else
							aadd(aLog,{STR0024,;
							cOper+"."+aUsuario[i][US_CODEMP]+"."+aUsuario[i][US_MATRIC]+"."+aUsuario[i][US_TIPREG]+"-"+aUsuario[i][US_DIGITO],;
							STR0044,;
							"",;
							"",;
							"",;
							""}) //"Usuario"###"nЦo se encaixou em nenhuma META cadastrada - Gravou BXO sem BXP"
						Endif
					Else
						lMetaOk := .T.
					EndIf
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Verifica se a regra trata sinistralidade                       Ё
					//Ё Somente para pessoa juridica                                   Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					If  aUsuario[i][US_TIPPLA] == "2" .and. ;
						aRegra[nRegra][R_ITENS][j][RI_SINIST] == "1"
						
						csTipo   := aRegra[nRegra][R_ITENS][j][RI_NIVSIN]
						csCodOpe := cOper
						csCodEmp := aUsuario[i][US_CODEMP]
						csNumCon := aUsuario[i][US_NUMCON]
						csVerCon := aUsuario[i][US_VERCON]
						csSubCon := aUsuario[i][US_SUBCON]
						csVerSub := aUsuario[i][US_VERSUB]
						csMatric := ""
						csTipReg := ""
						aSinist := PLSRETRC(csTipo,csMes,csAno,csCodOpe,csCodEmp,csNumCon,csVerCon,csSubCon,csVerSub,csMatric,csTipReg)
						If  aSinist[2] > 0
							nSinCalc := (aSinist[1] / aSinist[2]) * 100
							nSiniDe  := aRegra[nRegra][R_ITENS][j][RI_SINIDE]
							nSiniAte := aRegra[nRegra][R_ITENS][j][RI_SINIAT]
							If nPerSin > 0
								If  nSinCalc > nPerSin
									lSinist := .F.
								Endif
							ElseIf lBXK_SINIDE
								If  !(nSinCalc >= nSiniDe .AND. nSinCalc <= nSiniAte)
									lSinist := .F.
								Endif
							EndIf
						Elseif aSinist[2] == 0 //se ele nao teve receita a sinistralidade eh infinita entao nao gera nada
							lSinist := .F.
						Endif
						
					Endif
					If  lMetaOk .and. lSinist
						lGravaBXP := .T.
						nQtdDe    := aRegra[nRegra][R_ITENS][j][RI_QTDDE ]
						nQtdAte   := aRegra[nRegra][R_ITENS][j][RI_QTDATE]
						nPerCon   := aRegra[nRegra][R_ITENS][j][RI_PERCON]
						nValCon   := aRegra[nRegra][R_ITENS][j][RI_VALCON]
						cBenef    := aRegra[nRegra][R_ITENS][j][RI_BENEF ]
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Ponto de entrada para customizar a comissao                    Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						If lPLS150P1
							aRet      := Execblock("PLS150P1",.F.,.F.,{nQtdDe,nQtdAte,nPerCon,nValCon,cBenef})
							lGravaBXP := aRet[1]
							nQtdDe    := aRet[2]
							nQtdAte   := aRet[3]
							nPerCon   := aRet[4]
							nValCon   := aRet[5]
							cBenef    := aRet[6]
						Endif
						If  lGravaBXP
							If cBXOAntes == BXO->BXO_SEQ
								aadd(aLog,{STR0050,;
									BXO->BXO_SEQ +"/"+ BXO->BXO_SEQBXJ,;
									STR0051,;
									"",;
									"",;
									"",;
									""}) //"ProgramaГЦo/Cod.Regra" # "AtenГЦo! Existem mais de uma regra vАlida para o beneficiАrio."
							EndIf
							cBXOAntes := BXO->BXO_SEQ
							
							RecLock("BXP", .T.)
							BXP->BXP_FILIAL := xFilial("BXP")
							BXP->BXP_SEQBXO := BXO->BXO_SEQ
							BXP->BXP_QTDDE  := nQtdDe
							BXP->BXP_QTDATE := nQtdAte
							BXP->BXP_PERCON := nPerCon
							BXP->BXP_VALCON := nValCon
							BXP->BXP_BENEF  := cBenef
							BXP->BXP_SEQBXN := aRegra[nRegra][R_ITENS][j][RI_SEQBXN]
							BXP->BXP_META   := aRegra[nRegra][R_ITENS][j][RI_META  ]
							BXP->BXP_REAL   := aRegra[nRegra][R_ITENS][j][RI_REAL  ]
							if lBXP_SINIST
	                    		 BXP->BXP_SINIST := aRegra[nRegra][R_ITENS][j][RI_SINIST]
	                     	endif
							BXP->(MsUnLock())
						Endif
						//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё PLS150P2 - Ponto de entrada apos a gravaГЦo do itens de Pagto Comissao (BXP)Ё
						//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

						If lPLS150P2
							ExecBlock("PLS150P2",.F.,.F.)
						Endif
					EndIf
				Next
			EndIf
		Next
	END TRANSACTION
Next
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da funcao                                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return()

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    ЁPLS150BA3 Ё Autor Ё Angelo Sperandio      Ё Data Ё 21/07/04 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Calcula comissoes por contrato PF vendido                  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё PLS150BA3()                                                Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Static Function PLS150BA3(nVendUsu,lEquipe,lAutomacao)
Local nMeta,i,j,nVend
Local cQuery := ""
Local nInd
Local cID_VEND
Local nRegra
Local nRegrBC
Local cVendAnt
Local lBXK_SINIDE := BXP->(FieldPos("BXK_SINIDE")) > 0
Local cTipReg	:= GetNewPar("MV_PLCDTGP","00")
Local aProgGeradas := {}
Local cChaveProgra := ""


Default lEquipe := .F.
Default lAutomacao := .F.
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё                                                                            Ё
//Ё Processa cada vendedor/equipe selecionado                                  Ё
//Ё                                                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BXH->(dbSetOrder(1))
BXJ->(dbSetOrder(1))
BXK->(dbSetOrder(1))
BXN->(DbSetOrder(1))
nTamVend := Len(aVend)
For nVend := 1 To nTamVend
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Se esta processando Assistentes e nao possui assistente, despreza      Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If nVendUsu == 3 .And. Empty(aVend[nVend][nVendUsu])
		Loop
	EndIf
	If (nVendUsu == 1 .And. aVend[nVend][1] == cVendAnt) .Or. ;
		(nVendUsu == 3 .And. aVend[nVend][1]+aVend[nVend][3] == cVendAnt)
		Loop
	EndIf
	cVendAnt := IIf(nVendUsu == 1, aVend[nVend][1], aVend[nVend][1]+aVend[nVend][3])
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Carrega regras                                                         Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If !lAutomacao
		msProcTxt(STR0028 + aVend[nVend][2] + "/" + aVend[nVend][nVendUsu] + STR0029) //"Equipe/Vendedor "###" - Carregando regras"
	EndIf
	aRegra := {}

	cQuery := "SELECT * FROM "+RetSQLName("BXJ")+" WHERE "
	cQuery += " BXJ_FILIAL = '"  + xFilial("BXJ") + "' AND "
	cQuery += " BXJ_CODINT = '"  + cOper + "' AND "
	cQuery += " D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY BXJ_CODEQU, BXJ_CODVEN DESC, BXJ_TIPPLA, BXJ_TIPINC DESC, BXJ_CODPRO"
	
	cQuery := ChangeQuery(cQuery) 
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"BXJTMP",.F.,.T.) 

	While ! BXJTMP->(EOF())
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Localiza uma regra de acordo com o tipo do registro:                Ё
		//Ё Se tem somente VENDEDOR, o BXJ_TIPO sera = "1"                      Ё
		//Ё Se tem somente EQUIPE, o BXJ_TIPO sera = "2"                        Ё
		//Ё Se tem VENDEDOR e EQUIPE, o BXJ sera = "3"                          Ё
		//Ё Se o VENDEDOR esta em BRANCO, considera esta regra                  Ё
		//Ё a todos os VENDEDORES                                               Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If (Empty(BXJTMP->BXJ_CODVEN) .Or. BXJTMP->BXJ_CODVEN == aVend[nVend][nVendUsu]) .and. ;
			(Empty(BXJTMP->BXJ_CODEQU) .Or. BXJTMP->BXJ_CODEQU == aVend[nVend][2]) .and. ;
			BXJTMP->BXJ_FORCAL $ "103"

			BXJ->(Dbgoto(BXJTMP->R_E_C_N_O_))
   		If !PLSINTVAL("BXJ","BXJ_VLDINI","BXJ_VLDFIM",ddatde,ddatde,ddatate)
   			BXJTMP->(Dbskip())
	   		Loop
   		Endif
			AAdd(aRegra, Array(R_TAM_ARRAY))
			i := Len(aRegra)
			aRegra[i][R_CODINT] := BXJTMP->BXJ_CODINT
			aRegra[i][R_TIPO  ] := BXJTMP->BXJ_TIPO
			aRegra[i][R_CODEQU] := BXJTMP->BXJ_CODEQU
			aRegra[i][R_CODVEN] := BXJTMP->BXJ_CODVEN
			aRegra[i][R_TIPPLA] := BXJTMP->BXJ_TIPPLA
			aRegra[i][R_TIPINC] := BXJTMP->BXJ_TIPINC
			aRegra[i][R_GRUCOM] := BXJTMP->BXJ_GRUCOM
			aRegra[i][R_CODPRO] := BXJTMP->BXJ_CODPRO
			aRegra[i][R_CODEMP] := BXJTMP->BXJ_CODEMP
			aRegra[i][R_CONEMP] := BXJTMP->BXJ_CONEMP
			aRegra[i][R_SUBCON] := BXJTMP->BXJ_SUBCON
			aRegra[i][R_TIPCOB] := BXJTMP->BXJ_TIPCOB
			aRegra[i][R_CODMUN] := BXJTMP->BXJ_CODMUN
			If BXH->(MsSeek(xFilial("BXH")+BXJTMP->BXJ_FORCAL))
				aRegra[i][R_FORCAL] := BXJTMP->BXJ_FORCAL
				aRegra[i][R_TIPFOR] := BXH->BXH_TIPFOR
			Else
				aRegra[i][R_FORCAL] := Space(Len(BXJTMP->BXJ_FORCAL))
				aRegra[i][R_TIPFOR] := Space(Len(BXH->BXH_TIPFOR))
				aadd(aLog,{STR0030,;
				BXJTMP->BXJ_FORCAL+"/"+BXJTMP->BXJ_SEQ,;
				STR0031,;
				"",;
				"",;
				"",;
				""}) //"Forma Calculo/Seq Regra"###"Forma de calculo nao encontrada"
			EndIf
			aRegra[i][R_SEQ   ] := BXJTMP->BXJ_SEQ
			aRegra[i][R_ITENS ] := {}
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Monta os itens da regra                                        Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			BXK->(MsSeek(xFilial("BXK")+BXJTMP->BXJ_SEQ))
			While ! BXK->(EOF()) .And. BXK->BXK_FILIAL == xFilial("BXK") .And. BXK->BXK_SEQBXJ == BXJTMP->BXJ_SEQ
				AAdd(aRegra[i][R_ITENS], Array(RI_TAM_ARRAY))
				j := Len(aRegra[i][R_ITENS])
				aRegra[i][R_ITENS][j][RI_METADE] := BXK->BXK_METADE
				aRegra[i][R_ITENS][j][RI_METAAT] := BXK->BXK_METAAT
				aRegra[i][R_ITENS][j][RI_IDMETA] := BXK->BXK_IDMETA
				aRegra[i][R_ITENS][j][RI_QTDDE ] := BXK->BXK_QTDDE
				aRegra[i][R_ITENS][j][RI_QTDATE] := BXK->BXK_QTDATE
				aRegra[i][R_ITENS][j][RI_PERCON] := BXK->BXK_PERCON
				aRegra[i][R_ITENS][j][RI_VALCON] := BXK->BXK_VALCON
				aRegra[i][R_ITENS][j][RI_BENEF ] := BXK->BXK_BENEF
				aRegra[i][R_ITENS][j][RI_SINIST] := BXK->BXK_SINIST
				aRegra[i][R_ITENS][j][RI_NIVSIN] := BXK->BXK_NIVSIN
				If lBXK_SINIDE
					aRegra[i][R_ITENS][j][RI_SINIDE] := BXK->BXK_SINIDE
					aRegra[i][R_ITENS][j][RI_SINIAT] := BXK->BXK_SINIAT
				Else
					aRegra[i][R_ITENS][j][RI_SINIDE] := 0
					aRegra[i][R_ITENS][j][RI_SINIAT] := 0
				EndIf
				aRegra[i][R_ITENS][j][RI_POSMET] := 0
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Localiza a meta atrelada a esta regra                      Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If  BXK->BXK_METADE <> 0 .Or. BXK->BXK_METAAT <> 0
					lAchouMeta := .F.
					If  ! Empty(BXK->BXK_IDMETA)
						nMeta := AScan(aMeta, {|x| x[M_IDMETA] == BXK->BXK_IDMETA})
						If  nMeta > 0
							lAchouMeta := .T.
						Endif
					Else
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Caso nao exista o codigo da meta, localiza a meta pelo VENDEDOR e EQUIPE Ё
						//Ё comparando e localizando a meta que mais se adequa ao caso               Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						nTamMeta := Len(aMeta)
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё 1 - Procura uma meta identica a regra                                    Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						For nMeta := 1 To nTamMeta
							If  aMeta[nMeta][M_CODEQU] != aRegra[i][R_CODEQU]
								Loop
							EndIf
							If  aMeta[nMeta][M_CODVEN] != aRegra[i][R_CODVEN]
								Loop
							EndIf
							If  aMeta[nMeta][M_TIPPLA] != aRegra[i][R_TIPPLA]
								Loop
							EndIf
							If  aMeta[nMeta][M_TIPINC] != aRegra[i][R_TIPINC]
								Loop
							EndIf
							If  aMeta[nMeta][M_CODPRO] != aRegra[i][R_CODPRO]
								Loop
							EndIf
							lAchouMeta := .T.
							Exit
						Next
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё 2 - Procura uma meta que mais se pareca com a regra                      Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						If  ! lAchouMeta
							For nMeta := 1 To nTamMeta
								If !Empty(aMeta[nMeta][M_CODEQU]) .And. aMeta[nMeta][M_CODEQU] != aRegra[i][R_CODEQU]
									Loop
								EndIf
								If !Empty(aMeta[nMeta][M_CODVEN]) .And. aMeta[nMeta][M_CODVEN] != aRegra[i][R_CODVEN]
									Loop
								EndIf
								If !Empty(aMeta[nMeta][M_TIPPLA]) .And. aMeta[nMeta][M_TIPPLA] != aRegra[i][R_TIPPLA]
									Loop
								EndIf
								If !Empty(aMeta[nMeta][M_TIPINC]) .And. aMeta[nMeta][M_TIPINC] != aRegra[i][R_TIPINC]
									Loop
								EndIf
								If !Empty(aMeta[nMeta][M_CODPRO]) .And. aMeta[nMeta][M_CODPRO] != aRegra[i][R_CODPRO]
									Loop
								EndIf
								lAchouMeta := .T.
								Exit
							Next
						Endif
					EndIf
					If  ! lAchouMeta   // nMeta == 0
						aadd(aLog,{STR0032,;
						BXJ->BXJ_SEQ,;
						STR0033,;
						"",;
						"",;
						"",;
						""}) //"Seq Regra"###"A regra possui META DE/ATE preenchidos, mas nЦo foi localizado nenhuma meta no Cadastro de Metas"
					Else
						aRegra[i][R_ITENS][j][RI_POSMET] := nMeta
						aRegra[i][R_ITENS][j][RI_SEQBXN] := aMeta[nMeta][M_IDMETA]
						aRegra[i][R_ITENS][j][RI_META  ] := aMeta[nMeta][M_META  ]
						aRegra[i][R_ITENS][j][RI_REAL  ] := aMeta[nMeta][M_REAL  ]
					EndIf
				EndIf
				BXK->(dbSkip())
			End
		EndIf
		BXJTMP->(dbSkip())
	End
	BXJTMP->(dbCloseArea())
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifica se encontrou regra para o VENDEDOR E/OU EQUIPE                Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If  Len(aRegra) == 0
		aadd(aLog,{STR0034,;
		aVend[nVend][nVendUsu]+"/"+aVend[nVend][2],;
		STR0035,;
		"",;
		"",;
		"",;
		""}) //"Vendedor/Equipe"###"Vendedor/Equipe nЦo possui nenhuma regra cadastrada"
		Loop
	Endif

	If PLSALIASEX("BXS")
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Carrega regras de composicao da base de calculo das comissoes          Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		nInd := aScan(aEquipe, { |x| x[1]+x[2]+x[3] == aVend[nVend][2]+aVend[nVend][nVendUsu]+BXS->BXS_ID_VEN })
		If nInd > 0
			cID_VEND := aEquipe[nInd, 3]
		Else
			cID_VEND := ""
		EndIf
		If !lAutomacao
			msProcTxt(STR0036 + aVend[nVend][2] + "/" + aVend[nVend][nVendUsu] + "/" + cID_VEND+"-"+X3Combo("BXM_ID_VEND",cID_VEND) + STR0037) //"Equipe/Vendedor/ID Vend "###" - Carregando regras composicao base de calculo"
		EndIf
		aRegrBC := {}
		BXS->(DbSetOrder(1))
		BXS->(MsSeek(xFilial("BXS")+cOper))
		Do While ! BXS->(Eof()) .And. BXS->BXS_FILIAL == xFilial("BXS") ;
			.And. BXS->BXS_CODINT == cOper
			If (Empty(BXS->BXS_CODVEN) .Or. BXS->BXS_CODVEN == aVend[nVend][nVendUsu]) .And. ;
				(Empty(BXS->BXS_CODEQU) .Or. BXS->BXS_CODEQU == aVend[nVend][2]) .And. ;
				(Empty(BXS->BXS_ID_VEN) .Or. BXS->BXS_ID_VEN == cID_VEND)        .And. ;
				IIf(Empty(BXS->BXS_VLDINI), .T., BXS->BXS_VLDINI <= dDatAte)     .And. ;
				IIf(Empty(BXS->BXS_VLDFIM), .T., BXS->BXS_VLDFIM >= dDatAte)

				aAdd(aRegrBC, Array(BC_TAM_ARRAY))
				i := Len(aRegrBC)
				aRegrBC[i][BC_CODEQU] := BXS->BXS_CODEQU
				aRegrBC[i][BC_VLDINI] := BXS->BXS_VLDINI
				aRegrBC[i][BC_VLDFIM] := BXS->BXS_VLDFIM
				aRegrBC[i][BC_GRUCOM] := BXS->BXS_GRUCOM
				aRegrBC[i][BC_CODPRO] := BXS->BXS_CODPRO
				aRegrBC[i][BC_ID_VEN] := BXS->BXS_ID_VEN
				aRegrBC[i][BC_CODVEN] := BXS->BXS_CODVEN
				aRegrBC[i][BC_SEQ   ] := BXS->BXS_SEQ
			EndIf
			BXS->(dbSkip())
		EndDo
	Else
		aRegrBC := {}
	EndIf
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё                                                                        Ё
	//Ё Seleciona contratos vendidos pelo vendedor/equipe                      Ё
	//Ё                                                                        Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cQuery := "SELECT BG9.BG9_TIPO, BA1.BA1_CODEMP, BA1.BA1_MATRIC, BA1.BA1_TIPREG, BA1.BA1_DIGITO "
	cQuery += ", BA1.BA1_NOMUSR, BA1.BA1_CONEMP, BA1.BA1_CODMUN, BA1.BA1_TIPINC "
	cQuery += ", BA1.BA1_CONEMP, BA1.BA1_VERCON, BA1.BA1_SUBCON, BA1.BA1_VERSUB "
	cQuery += ", BA1.BA1_CODPLA, BA1.BA1_VERSAO, BA3.BA3_CODPLA, BA3.BA3_VERSAO "
	cQuery += ", BA1.BA1_TIPINC, BA1.BA1_CODINT, BA1.BA1_DATINC "
	cQuery += "FROM "+RetSQLName("BA1")+" BA1, "+RetSQLName("BG9")+" BG9, "+RetSQLName("BA3")+" BA3"
	cQuery += "  WHERE BA1.BA1_CODINT = BA3.BA3_CODINT"
	cQuery += "    AND BA1.BA1_CODINT = BG9.BG9_CODINT"
	cQuery += "    AND BA1.BA1_CODEMP = BA3.BA3_CODEMP"
	cQuery += "    AND BA1.BA1_CODEMP = BG9.BG9_CODIGO"
	cQuery += "    AND BA1.BA1_MATRIC = BA3.BA3_MATRIC"
	cQuery += "    AND BA1.BA1_TIPREG = '"+cTipReg+"'"  // somente o titular
	cQuery += "    AND BG9.BG9_TIPO   = '1'"   // somente PF
	cQuery += "    AND BA1.BA1_FILIAL = '"  + xFilial("BA1")  + "'"
	cQuery += "    AND BA3.BA3_FILIAL = '"  + xFilial("BA3")  + "'"
	cQuery += "    AND BG9.BG9_FILIAL = '"  + xFilial("BG9")  + "'"
	cQuery += "    AND BA1.BA1_DATINC >= '" + DToS(dDatDe)   + "'"
	cQuery += "    AND BA1.BA1_DATINC <= '" + DToS(dDatAte)   + "'"
	cQuery += "    AND BA1.BA1_CODINT = '"  + cOper           + "'"
	cQuery += "    AND BG9.BG9_CODINT = '"  + cOper           + "'"
	cQuery += "    AND BA1.BA1_CODEMP >= '" + cEmpDe          + "'"
	cQuery += "    AND BA1.BA1_CODEMP <= '" + cEmpAte         + "'"
	cQuery += "    AND BA1.BA1_CONEMP >= '" + cConDe          + "'"
	cQuery += "    AND BA1.BA1_CONEMP <= '" + cConAte         + "'"
	cQuery += "    AND BA1.BA1_SUBCON >= '" + cSubDe          + "'"
	cQuery += "    AND BA1.BA1_SUBCON <= '" + cSubAte         + "'"
	//Tratamento para quando for calcular a comissao somente para um vendedor
	If lCalSom2Ven .And. cVenDe == cVenAte
		cQuery += "    AND BA1.BA1_CODVE2 = '"  + aVend[nVend][1] + "'"
	Else
		If !lEquipe
			cQuery += "    AND BA1.BA1_CODVEN = '"  + aVend[nVend][1] + "'"
		Endif
		If nVendUsu == 3
			cQuery += "    AND BA1.BA1_CODVE2 = '"  + aVend[nVend][3] + "'"
		EndIf
	EndIf
	cQuery += "    AND BA1.BA1_EQUIPE = '"  + aVend[nVend][2] + "'"
	cQuery += "    AND BA1.D_E_L_E_T_ = ' ' "
	cQuery += "    AND BA3.D_E_L_E_T_ = ' ' "
	cQuery += "    AND BG9.D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY BA1.BA1_CODPLA, BA3.BA3_CODPLA"
	If !lAutomacao
		msProcTxt(STR0028 + aVend[nVend][2] + "/" + aVend[nVend][nVendUsu] + STR0038) //"Equipe/Vendedor "###" - Selecionando usuarios"
	EndIf
	cQuery := ChangeQuery(cQuery) 
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"BA1TMP",.F.,.T.) 

	aUsuario := {}
	While !BA1TMP->(EOF())
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Posiciona BI3-Produto                                               Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If  ! empty(BA1TMP->BA1_CODPLA)
			cCodPro := BA1TMP->BA1_CODPLA
			cVersao := BA1TMP->BA1_VERSAO
		Else
			cCodPro := BA1TMP->BA3_CODPLA
			cVersao := BA1TMP->BA3_VERSAO
		Endif
		If  BI3->BI3_FILIAL+BI3->BI3_CODINT   +BI3->BI3_CODIGO+BI3->BI3_VERSAO <> ;
			xFilial("BI3") +BA1TMP->BA1_CODINT+cCodPro        +cVersao
			If ! BI3->(MsSeek(xFilial("BI3")+BA1TMP->BA1_CODINT+cCodPro+cVersao))
				aadd(aLog,{STR0022,;
				cCodPro+"/"+cVersao,;
				STR0039,;
				"",;
				"",;
				"",;
				""}) //"Produto/Versao"###"Produto/Versao nao encontrado"
				BA1TMP->(dbSkip())
				Loop
			Endif
		Endif
		AAdd(aUsuario, Array(US_TAM_ARRAY))
		i := Len(aUsuario)
		aUsuario[i][US_TIPPLA] := BA1TMP->BG9_TIPO
		aUsuario[i][US_CODEMP] := BA1TMP->BA1_CODEMP
		aUsuario[i][US_MATRIC] := BA1TMP->BA1_MATRIC
		aUsuario[i][US_TIPREG] := BA1TMP->BA1_TIPREG
		aUsuario[i][US_DIGITO] := BA1TMP->BA1_DIGITO
		aUsuario[i][US_NOMUSR] := BA1TMP->BA1_NOMUSR
		aUsuario[i][US_CONEMP] := BA1TMP->BA1_CONEMP
		aUsuario[i][US_NUMCON] := BA1TMP->BA1_CONEMP
		aUsuario[i][US_VERCON] := BA1TMP->BA1_VERCON
		aUsuario[i][US_SUBCON] := BA1TMP->BA1_SUBCON
		aUsuario[i][US_VERSUB] := BA1TMP->BA1_VERSUB
		aUsuario[i][US_GRUCOM] := BI3->BI3_GRUCOM
		aUsuario[i][US_CODPLA] := cCodPro
		aUsuario[i][US_VERSAO] := cVersao
		aUsuario[i][US_TIPINC] := BA1TMP->BA1_TIPINC
		If  BI3->BI3_MODPAG <> "1"
			aUsuario[i][US_TIPCOB] := "1" // Custo Operacional
		Else
			If  BI3->BI3_CPFM == "0"
				aUsuario[i][US_TIPCOB] := "2" // Pre-Pagamento
			Else
				aUsuario[i][US_TIPCOB] := "3" // Pre-Pagamento com Co-Participacao
			Endif
		Endif
		aUsuario[i][US_CODMUN] := BA1TMP->BA1_CODMUN   // TRATAR COD.MUN.
		aUsuario[i][US_REGRA ] := 0
		aUsuario[i][US_META  ] := 0
		aUsuario[i][US_REGRBC] := 0
		BA1TMP->(dbSkip())
	End
	BA1TMP->(dbCloseArea())
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Identifica em que regra cada usuario se enquadra                       Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	nTamMeta   := Len(aMeta)
	nTamRegra  := Len(aRegra)
	nTamUsuari := Len(aUsuario)
	For j := 1 To nTamUsuario
		For i := 1 To nTamRegra
			If !Empty(aRegra[i][R_TIPPLA]) .And. aRegra[i][R_TIPPLA] != aUsuario[j][US_TIPPLA]
				Loop
			EndIf
			If !Empty(aRegra[i][R_TIPINC]) .And. aRegra[i][R_TIPINC] != aUsuario[j][US_TIPINC]
				Loop
			EndIf
			If !Empty(aRegra[i][R_GRUCOM]) .And. aRegra[i][R_GRUCOM] != aUsuario[j][US_GRUCOM]
				Loop
			EndIf
			If !Empty(aRegra[i][R_CODPRO]) .And. aRegra[i][R_CODPRO] != aUsuario[j][US_CODPLA]
				Loop
			EndIf
			If !Empty(aRegra[i][R_CODEMP]) .And. aRegra[i][R_CODEMP] != aUsuario[j][US_CODEMP]
				Loop
			EndIf
			If !Empty(aRegra[i][R_CONEMP]) .And. aRegra[i][R_CONEMP] != aUsuario[j][US_CONEMP]
				Loop
			EndIf
			If !Empty(aRegra[i][R_SUBCON]) .And. aRegra[i][R_SUBCON] != aUsuario[j][US_SUBCON]
				Loop
			EndIf
			If !Empty(aRegra[i][R_TIPCOB]) .And. aRegra[i][R_TIPCOB] != aUsuario[j][US_TIPCOB]
				Loop
			EndIf
			If !Empty(aRegra[i][R_CODMUN]) .And. aRegra[i][R_CODMUN] != aUsuario[j][US_CODMUN]
				Loop
			EndIf
			aUsuario[j][US_REGRA] := i			// Indica que o usuario foi classificado na REGRA (i)
			Exit
		Next
		If  aUsuario[j][US_REGRA] == 0
			aadd(aLog,{STR0024,;
			cOper+"."+aUsuario[j][US_CODEMP]+"."+aUsuario[j][US_MATRIC]+"."+aUsuario[j][US_TIPREG]+"-"+aUsuario[j][US_DIGITO],;
			STR0040,;
			"2",;
			aVend[nVend][1]+cOper+aUsuario[j][US_CODEMP]+aUsuario[j][US_MATRIC],;
			aVend[nVend][1]+cOper+aUsuario[j][US_CODEMP]+aUsuario[j][US_NUMCON]+aUsuario[j][US_VERCON]+aUsuario[j][US_SUBCON]+aUsuario[j][US_VERSUB],;
			""}) //"Usuario"###"Usuario nЦo se encaixou em nenhuma REGRA cadastrada"
		EndIf
	Next

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Identifica em que regra cada usuario se enquadra                       Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	nTamRegra  := Len(aRegrBC)
	nTamUsuari := Len(aUsuario)
	For j := 1 To nTamUsuario
		For i := 1 To nTamRegra
			If !Empty(aRegrBC[i][BC_GRUCOM]) .And. aRegrBC[i][BC_GRUCOM] != aUsuario[j][US_GRUCOM]
				Loop
			EndIf
			If !Empty(aRegrBC[i][BC_CODPRO]) .And. aRegrBC[i][BC_CODPRO] != aUsuario[j][US_CODPLA]
				Loop
			EndIf
			aUsuario[j][US_REGRBC] := i // Indica que o usuario foi classificado na REGRA COMPOSICAO BASE CALCULO (i)
			Exit
		Next i
	Next j

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Grava Programacao para Calculo de Comissoes                            Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	BEGIN TRANSACTION
		BXO->(dbSetOrder(1))
		For i := 1 To nTamUsuari
			If !lAutomacao
				msProcTxt(STR0028 + aVend[nVend][2] + "/" + aVend[nVend][nVendUsu] + STR0041 + aUsuario[i][US_CODEMP] + "." + aUsuario[i][US_MATRIC] + "." + aUsuario[i][US_TIPREG] + "." + aUsuario[i][US_DIGITO]) //"Equipe/Vendedor "###" - Gravando regras p/ usuario "
			EndIf
			nRegra  := aUsuario[i][US_REGRA]  // Indica qual a regra o usuario foi classificado
			nRegrBC := aUsuario[i][US_REGRBC] // Indica qual a regra composicao base calculo o usuario foi classificado
			If  nRegra == 0
				Loop
			Endif
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Verifica se ha existe a programacao de calculo                     Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			cChaveProgra := aVend[nVend][nVendUsu]+cOper+aUsuario[i][US_CODEMP]+aUsuario[i][US_MATRIC]+aUsuario[i][US_TIPREG]+aUsuario[i][US_DIGITO]

			If  BXO->(MsSeek(xFilial("BXO")+cChaveProgra))
				If CheckGrvProg(aProgGeradas, cChaveProgra)
					aadd(aLog,{STR0042,;
					aVend[nVend][nVendUsu]+" "+cOper+"."+aUsuario[i][US_CODEMP]+"."+aUsuario[i][US_MATRIC]+"."+aUsuario[i][US_TIPREG]+"."+aUsuario[i][US_DIGITO],;
					STR0043,;
					"",;
					"",;
					"",;
					""}) //"Vendedor/usuario"###"Ja existe programacao de calculo de comissao para este vendedor/usuario - verifique"
				EndIf
			Else
				RecLock("BXO",.T.)
				BXO->BXO_FILIAL := xFilial("BXO")
				BXO->BXO_SEQ    := GetSX8Num("BXO","BXO_SEQ")
				BXO->BXO_ANO    := cAno
				BXO->BXO_MES    := cMes
				BXO->BXO_DATA   := dDataBase
				BXO->BXO_CODEQU := aVend[nVend][2]
				BXO->BXO_CODVEN := aVend[nVend][nVendUsu]
				BXO->BXO_CODINT := cOper
				BXO->BXO_CODEMP := aUsuario[i][US_CODEMP]
				BXO->BXO_MATRIC := aUsuario[i][US_MATRIC]
				BXO->BXO_TIPREG := aUsuario[i][US_TIPREG]
				BXO->BXO_DIGITO := aUsuario[i][US_DIGITO]
				BXO->BXO_NUMCON := aUsuario[i][US_NUMCON]
				BXO->BXO_VERCON := aUsuario[i][US_VERCON]
				BXO->BXO_SUBCON := aUsuario[i][US_SUBCON]
				BXO->BXO_VERSUB := aUsuario[i][US_VERSUB]
				BXO->BXO_SEQBXJ := aRegra[nRegra][R_SEQ]
				If lSEQBXS
					BXO->BXO_SEQBXS := IIf(nRegrBC == 0, "", aRegrBC[nRegrBC][BC_SEQ])
				EndIf
				BXO->(MsUnLock())
				ConfirmSX8()

				aAdd(aProgGeradas, BXO->(BXO_CODVEN+BXO_CODINT+BXO_CODEMP+BXO_MATRIC+BXO_TIPREG+BXO_DIGITO))
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Verifica todos os itens da regra e grava os que se enquadram       Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				nTamRegrIT := Len(aRegra[nRegra][R_ITENS])
				For j := 1 To nTamRegrIT
					lMetaOk := .F.
					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Se esta regra possui meta, calcula e verifica se atingiu a meta Ё
					//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					If  aRegra[nRegra][R_ITENS][j][RI_METADE] <> 0 .Or. aRegra[nRegra][R_ITENS][j][RI_METAAT] <> 0
						If  aRegra[nRegra][R_ITENS][j][RI_POSMET] > 0
							nQtdMeta := If(aRegra[nRegra][R_ITENS][j][RI_META]==0,0.1,aRegra[nRegra][R_ITENS][j][RI_META]) // para evitar erro de divisao por zero
							nQtdReal := aRegra[nRegra][R_ITENS][j][RI_REAL]
							nResult  := NoRound((nQtdReal / nQtdMeta) * 100,0)
							If  nResult >= aRegra[nRegra][R_ITENS][j][RI_METADE] .And. ;
								nResult <= aRegra[nRegra][R_ITENS][j][RI_METAAT]
								lMetaOk := .T.
							EndIf
						Else
							aadd(aLog,{STR0024,;
							cOper+"."+aUsuario[i][US_CODEMP]+"."+aUsuario[i][US_MATRIC]+"."+aUsuario[i][US_TIPREG]+"-"+aUsuario[i][US_DIGITO],;
							STR0044,;
							"",;
							"",;
							"",;
							""}) //"Usuario"###"nЦo se encaixou em nenhuma META cadastrada - Gravou BXO sem BXP"
						Endif
					Else
						lMetaOk := .T.
					EndIf
					If  lMetaOk
						RecLock("BXP", .T.)
						BXP->BXP_FILIAL := xFilial("BXP")
						BXP->BXP_SEQBXO := BXO->BXO_SEQ
						BXP->BXP_QTDDE  := aRegra[nRegra][R_ITENS][j][RI_QTDDE ]
						BXP->BXP_QTDATE := aRegra[nRegra][R_ITENS][j][RI_QTDATE]
						BXP->BXP_PERCON := aRegra[nRegra][R_ITENS][j][RI_PERCON]
						BXP->BXP_VALCON := aRegra[nRegra][R_ITENS][j][RI_VALCON]
						BXP->BXP_BENEF  := aRegra[nRegra][R_ITENS][j][RI_BENEF ]
						BXP->BXP_SEQBXN := aRegra[nRegra][R_ITENS][j][RI_SEQBXN]
						BXP->BXP_META   := aRegra[nRegra][R_ITENS][j][RI_META  ]
						BXP->BXP_REAL   := aRegra[nRegra][R_ITENS][j][RI_REAL  ]
						BXP->(MsUnLock())
					EndIf
				Next
			Endif
		Next
	END TRANSACTION
Next
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da funcao                                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return()

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    ЁPLS150BQC Ё Autor Ё Angelo Sperandio      Ё Data Ё 21/07/04 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Calcula comissoes por contrato PJ vendido                  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё PLS150BQC()                                                Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Static Function PLS150BQC(nVendUsu, lEquipe,lAutomacao)
Local i,j,nVend
Local cVendAnt
Default lEquipe := .F.
Default lAutomacao := .F.
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё                                                                            Ё
//Ё Processa cada vendedor/equipe selecionado                                  Ё
//Ё                                                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nTamVend := Len(aVend)
For nVend := 1 To nTamVend
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Se esta processando Assistentes e nao possui assistente, despreza      Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If nVendUsu == 3 .And. Empty(aVend[nVend][nVendUsu])
		Loop
	EndIf
	If (nVendUsu == 1 .And. aVend[nVend][1] == cVendAnt) .Or. ;
		(nVendUsu == 3 .And. aVend[nVend][1]+aVend[nVend][3] == cVendAnt)
		Loop
	EndIf
	cVendAnt := IIf(nVendUsu == 1, aVend[nVend][1], aVend[nVend][1]+aVend[nVend][3])
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifica se encontrou regra para o VENDEDOR E/OU EQUIPE                Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	//	If  Len(aRegra) == 0
	//      aadd(aLog,{"Vendedor/Equipe",aVend[nVend][nVendUsu]+"/"+aVend[nVend][2],"Vendedor/Equipe nЦo possui nenhuma regra cadastrada"})
	//		Loop
	//	Endif
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё                                                                        Ё
	//Ё Seleciona contratos vendidos pelo vendedor/equipe                      Ё
	//Ё                                                                        Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cQuery := "SELECT BQC.BQC_CODINT, BQC.BQC_CODEMP "
	cQuery += "     , BQC.BQC_NUMCON, BQC.BQC_VERCON, BQC.BQC_SUBCON, BQC.BQC_VERSUB "
	cQuery += "     , BQC.BQC_CODMUN, BG9.BG9_TIPO "
	cQuery += "FROM "+RetSQLName("BG9")+" BG9, "+RetSQLName("BQC")+" BQC"
	cQuery += "  WHERE BQC.BQC_CODINT = BG9.BG9_CODINT"
	cQuery += "    AND BQC.BQC_CODEMP = BG9.BG9_CODIGO"
	cQuery += "    AND BG9.BG9_TIPO   = '2'"   // somente PJ
	cQuery += "    AND BQC.BQC_FILIAL = '"  + xFilial("BQC")  + "'"
	cQuery += "    AND BG9.BG9_FILIAL = '"  + xFilial("BG9")  + "'"
	cQuery += "    AND BQC.BQC_DATCON >= '" + DToS(dDatDe)   + "'"
	cQuery += "    AND BQC.BQC_DATCON <= '" + DToS(dDatAte)   + "'"
	cQuery += "    AND BQC.BQC_CODINT = '"  + cOper           + "'"
	cQuery += "    AND BG9.BG9_CODINT = '"  + cOper           + "'"
	cQuery += "    AND BQC.BQC_CODEMP >= '" + cEmpDe          + "'"
	cQuery += "    AND BQC.BQC_CODEMP <= '" + cEmpAte         + "'"
	cQuery += "    AND BQC.BQC_NUMCON >= '" + cConDe          + "'"
	cQuery += "    AND BQC.BQC_NUMCON <= '" + cConAte         + "'"
	cQuery += "    AND BQC.BQC_SUBCON >= '" + cSubDe          + "'"
	cQuery += "    AND BQC.BQC_SUBCON <= '" + cSubAte         + "'"
	If lCalSom2Ven .And. cVenDe == cVenAte
		cQuery += "    AND BA1.BA1_CODVE2 = '"  + aVend[nVend][1] + "'"
	Else
		If !lEquipe
			cQuery += "    AND BQC.BQC_CODVEN = '"  + aVend[nVend][1] + "'"
		Endif
		If nVendUsu == 3
			cQuery += "    AND BQC.BQC_CODVE2 = '"  + aVend[nVend][3] + "'"
		EndIf
	EndIf
	cQuery += "    AND BQC.BQC_EQUIPE = '"  + aVend[nVend][2] + "'"
	cQuery += "    AND BQC.D_E_L_E_T_ = ' '"
	cQuery += "    AND BG9.D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY BQC.BQC_CODINT, BQC.BQC_CODEMP, BQC.BQC_NUMCON, BQC.BQC_SUBCON"
	If !lAutomacao
		msProcTxt(STR0028 + aVend[nVend][2] + "/" + aVend[nVend][nVendUsu] + STR0038) //"Equipe/Vendedor "###" - Selecionando usuarios"
	EndIf
	
	cQuery := ChangeQuery(cQuery) 
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"BQCTMP",.F.,.T.) 

	aUsuario := {}
	While !BQCTMP->(EOF())
		AAdd(aUsuario, Array(US_TAM_ARRAY))
		i := Len(aUsuario)
		aUsuario[i][US_TIPPLA] := BQCTMP->BG9_TIPO
		aUsuario[i][US_CODEMP] := BQCTMP->BQC_CODEMP
		aUsuario[i][US_MATRIC] := ""
		aUsuario[i][US_TIPREG] := ""
		aUsuario[i][US_DIGITO] := ""
		aUsuario[i][US_NOMUSR] := ""
		aUsuario[i][US_CONEMP] := BQCTMP->BQC_NUMCON
		aUsuario[i][US_NUMCON] := BQCTMP->BQC_NUMCON
		aUsuario[i][US_VERCON] := BQCTMP->BQC_VERCON
		aUsuario[i][US_SUBCON] := BQCTMP->BQC_SUBCON
		aUsuario[i][US_VERSUB] := BQCTMP->BQC_VERSUB
		aUsuario[i][US_GRUCOM] := ""
		aUsuario[i][US_CODPLA] := ""
		aUsuario[i][US_VERSAO] := ""
		aUsuario[i][US_TIPINC] := ""
		aUsuario[i][US_TIPCOB] := ""
		aUsuario[i][US_CODMUN] := BQCTMP->BQC_CODMUN
		aUsuario[i][US_REGRA ] := 0
		aUsuario[i][US_META  ] := 0
		aUsuario[i][US_REGRBC] := 0
		BQCTMP->(dbSkip())
	End
	BQCTMP->(dbCloseArea())
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Identifica em que regra cada subcontrato se enquadra                   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	nTamMeta   := Len(aMeta)
	nTamRegra  := Len(aRegra)
	nTamUsuari := Len(aUsuario)
	For j := 1 To nTamUsuario
		For i := 1 To nTamRegra
			If !Empty(aRegra[i][R_TIPPLA]) .And. aRegra[i][R_TIPPLA] != aUsuario[j][US_TIPPLA]
				Loop
			EndIf
			//			If !Empty(aRegra[i][R_TIPINC]) .And. aRegra[i][R_TIPINC] != aUsuario[j][US_TIPINC]
			//				Loop
			//			EndIf
			//			If !Empty(aRegra[i][R_GRUCOM]) .And. aRegra[i][R_GRUCOM] != aUsuario[j][US_GRUCOM]
			// 				Loop
			// 			EndIf
			//			If !Empty(aRegra[i][R_CODPRO]) .And. aRegra[i][R_CODPRO] != aUsuario[j][US_CODPLA]
			//				Loop
			//			EndIf
			If !Empty(aRegra[i][R_CODEMP]) .And. aRegra[i][R_CODEMP] != aUsuario[j][US_CODEMP]
				Loop
			EndIf
			If !Empty(aRegra[i][R_CONEMP]) .And. aRegra[i][R_CONEMP] != aUsuario[j][US_CONEMP]
				Loop
			EndIf
			If !Empty(aRegra[i][R_SUBCON]) .And. aRegra[i][R_SUBCON] != aUsuario[j][US_SUBCON]
				Loop
			EndIf
			// 			If !Empty(aRegra[i][R_TIPCOB]) .And. aRegra[i][R_TIPCOB] != aUsuario[j][US_TIPCOB]
			// 				Loop
			// 			EndIf
			If !Empty(aRegra[i][R_CODMUN]) .And. aRegra[i][R_CODMUN] != aUsuario[j][US_CODMUN]
				Loop
			EndIf
			aUsuario[j][US_REGRA] := i			// Indica que o usuario foi classificado na REGRA (i)
			Exit
		Next
		If  aUsuario[j][US_REGRA] == 0
			aadd(aLog,{STR0045,;
			cOper+"."+aUsuario[j][US_CODEMP]+"."+aUsuario[j][US_NUMCON]+"."+aUsuario[j][US_VERCON]+"."+aUsuario[j][US_SUBCON]+"."+aUsuario[j][US_VERSUB],;
			STR0046,;
			"3",;
			"",;
			aVend[nVend][1]+cOper+aUsuario[j][US_CODEMP]+aUsuario[j][US_NUMCON]+aUsuario[j][US_VERCON]+aUsuario[j][US_SUBCON]+aUsuario[j][US_VERSUB],;
			""}) //"Subcontrato"###"Subcontrato nЦo se encaixou em nenhuma REGRA cadastrada"
		EndIf
	Next

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Identifica em que regra cada usuario se enquadra                       Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	nTamRegra  := Len(aRegrBC)
	nTamUsuari := Len(aUsuario)
	For j := 1 To nTamUsuario
		For i := 1 To nTamRegra
			If !Empty(aRegrBC[i][BC_GRUCOM]) .And. aRegrBC[i][BC_GRUCOM] != aUsuario[j][US_GRUCOM]
				Loop
			EndIf
			If !Empty(aRegrBC[i][BC_CODPRO]) .And. aRegrBC[i][BC_CODPRO] != aUsuario[j][US_CODPLA]
				Loop
			EndIf
			aUsuario[j][US_REGRBC] := i	// Indica que o usuario foi classificado na REGRA COMPOSICAO BASE CALCULO (i)
			Exit
		Next i
	Next j

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Grava Programacao para Calculo de Comissoes                            Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	BEGIN TRANSACTION
		BXO->(dbSetOrder(2))
		For i := 1 To nTamUsuari
			If !lAutomacao
				msProcTxt(STR0028 + aVend[nVend][2] + "/" + aVend[nVend][nVendUsu] + STR0047 + aUsuario[i][US_CODEMP] + "." + aUsuario[i][US_CONEMP] + "." + aUsuario[i][US_SUBCON]) //"Equipe/Vendedor "###" - Gravando regras p/ subcontrato "
			EndIf
			nRegra  := aUsuario[i][US_REGRA]  // Indica qual a regra o usuario foi classificado
			nRegrBC := aUsuario[i][US_REGRBC] // Indica qual a regra composicao base calculo o usuario foi classificado
			If  nRegra == 0
				Loop
			Endif
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Verifica se ha existe a programacao de calculo                     Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If  BXO->(MsSeek(xFilial("BXO")+aVend[nVend][nVendUsu]+cOper+aUsuario[i][US_CODEMP]+aUsuario[i][US_NUMCON]+aUsuario[i][US_VERCON]+aUsuario[i][US_SUBCON]+aUsuario[i][US_VERSUB]))
				aadd(aLog,{STR0048,;
				aVend[nVend][nVendUsu]+" "+cOper+"."+aUsuario[i][US_CODEMP]+"."+aUsuario[i][US_NUMCON]+"."+aUsuario[i][US_VERCON]+"."+aUsuario[i][US_SUBCON]+"."+aUsuario[i][US_VERSUB],;
				STR0049,;
				"",;
				"",;
				"",;
				""}) //"Vendedor/contrato"###"Ja existe programacao de calculo de comissao para este vendedor/contrato - verifique"
			Else
				RecLock("BXO",.T.)
				BXO->BXO_FILIAL := xFilial("BXO")
				BXO->BXO_SEQ    := GetSX8Num("BXO","BXO_SEQ")
				BXO->BXO_ANO    := cAno
				BXO->BXO_MES    := cMes
				BXO->BXO_DATA   := dDataBase
				BXO->BXO_CODEQU := aVend[nVend][2]
				BXO->BXO_CODVEN := aVend[nVend][nVendUsu]
				BXO->BXO_CODINT := cOper
				BXO->BXO_CODEMP := aUsuario[i][US_CODEMP]
				BXO->BXO_MATRIC := aUsuario[i][US_MATRIC]
				BXO->BXO_TIPREG := aUsuario[i][US_TIPREG]
				BXO->BXO_DIGITO := aUsuario[i][US_DIGITO]
				BXO->BXO_NUMCON := aUsuario[i][US_NUMCON]
				BXO->BXO_VERCON := aUsuario[i][US_VERCON]
				BXO->BXO_SUBCON := aUsuario[i][US_SUBCON]
				BXO->BXO_VERSUB := aUsuario[i][US_VERSUB]
				BXO->BXO_SEQBXJ := aRegra[nRegra][R_SEQ]
				If lSEQBXS
					BXO->BXO_SEQBXS := IIf(nRegrBC == 0, "", aRegrBC[nRegrBC][BC_SEQ])
				EndIf
				BXO->(MsUnLock())
				ConfirmSX8()
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Verifica todos os itens da regra e grava os que se enquadram       Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				nTamRegrIT := Len(aRegra[nRegra][R_ITENS])
				For j := 1 To nTamRegrIT
					lMetaOk := .F.
					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Se esta regra possui meta, calcula e verifica se atingiu a meta Ё
					//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					If  aRegra[nRegra][R_ITENS][j][RI_METADE] <> 0 .Or. aRegra[nRegra][R_ITENS][j][RI_METAAT] <> 0
						If  aRegra[nRegra][R_ITENS][j][RI_POSMET] > 0
							nQtdMeta := If(aRegra[nRegra][R_ITENS][j][RI_META]==0,0.1,aRegra[nRegra][R_ITENS][j][RI_META]) // para evitar erro de divisao por zero
							nQtdReal := aRegra[nRegra][R_ITENS][j][RI_REAL]
							nResult  := NoRound((nQtdReal / nQtdMeta) * 100,0)
							If  nResult >= aRegra[nRegra][R_ITENS][j][RI_METADE] .And. ;
								nResult <= aRegra[nRegra][R_ITENS][j][RI_METAAT]
								lMetaOk := .T.
							EndIf
						Else
							aadd(aLog,{STR0045,;
							cOper+"."+aUsuario[i][US_CODEMP]+"."+aUsuario[i][US_NUMCON]+"."+aUsuario[i][US_VERCON]+"."+aUsuario[i][US_SUBCON]+"."+aUsuario[i][US_VERSUB],;
							STR0010,;
							"",;
							"",;
							"",;
							""}) //"Subcontrato"###"Subcontrato nЦo se encaixou em nenhuma META cadastrada - Gravou BXO sem BXP"
						Endif
					Else
						lMetaOk := .T.
					EndIf
					If  lMetaOk
						RecLock("BXP", .T.)
						BXP->BXP_FILIAL := xFilial("BXP")
						BXP->BXP_SEQBXO := BXO->BXO_SEQ
						BXP->BXP_QTDDE  := aRegra[nRegra][R_ITENS][j][RI_QTDDE ]
						BXP->BXP_QTDATE := aRegra[nRegra][R_ITENS][j][RI_QTDATE]
						BXP->BXP_PERCON := aRegra[nRegra][R_ITENS][j][RI_PERCON]
						BXP->BXP_VALCON := aRegra[nRegra][R_ITENS][j][RI_VALCON]
						BXP->BXP_BENEF  := aRegra[nRegra][R_ITENS][j][RI_BENEF ]
						BXP->BXP_SEQBXN := aRegra[nRegra][R_ITENS][j][RI_SEQBXN]
						BXP->BXP_META   := aRegra[nRegra][R_ITENS][j][RI_META  ]
						BXP->BXP_REAL   := aRegra[nRegra][R_ITENS][j][RI_REAL  ]
						BXP->(MsUnLock())
					EndIf
				Next
			Endif
		Next
	END TRANSACTION
Next
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da funcao                                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return()

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё ExistPrCal Ё Autor Ё Totvs			    Ё Data Ё 11/12/12 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Verifica se ja existe a programacao de calculo             Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё ExistPrCal(cChave)                                         Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Static Function ExistPrCal(cChave,cAno,cMes)

Local lRet		:= .F.
Local lAchou	:= BXO->(MsSeek(cChave))
Local aAreaBXO	:= BXO->(GetArea())

If lAchou

	While ! BXO->(Eof()) .And. BXO->(&(BXO->(IndexKey()))) == cChave
		If MV_PAR19 = 1
			If AllTrim(BXO->(BXO_ANO)) + AllTrim(BXO->(BXO_MES)) == AllTrim(cAno) + AllTrim(cMes)
				lRet := .T.
				Exit
			EndIf
		Else
			lRet := .T.
			Exit
		Endif

		BXO->(DbSkip())

	Enddo

EndIf

RestArea(aAreaBXO)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} CheckGrvProg
Verifica se a programaГЦo da comissЦo jА constava na base de dados
antes do processamente.

@author Vinicius Queiros Teixeira
@since 28/09/2021
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function CheckGrvProg(aProgGeradas, cChaveBusca)

	Local lRetorno := .T.

	Default aProgGeradas := {}
	Default cChaveBusca := ""

	If Len(aProgGeradas) > 0

		If aScan(aProgGeradas, {|x| Alltrim(x) == Alltrim(cChaveBusca) }) > 0
			lRetorno := .F.
		EndIf

	EndIf

Return lRetorno