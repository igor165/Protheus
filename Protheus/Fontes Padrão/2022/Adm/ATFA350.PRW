#Include 'Protheus.CH'
#Include 'ATFA350.CH'
#Include "ApWizard.ch"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDEFINES DE NOPC DA ROTINAณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
#DEFINE VISUALIZAR		2
#DEFINE INCLUIR			3
#DEFINE ALTERAR			4
#DEFINE REVISAR			5
#DEFINE EXCLUIR			5

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPosicao do Array com as perguntas da simula็ใoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
#DEFINE CODIGO					1
#DEFINE REVISAO				2
#DEFINE PERIODO_INICIAL		3
#DEFINE QTD_PERIODOS			4
#DEFINE BASE_MOD				5
#DEFINE FILIAL_DE				6
#DEFINE FILIAL_ATE			7
#DEFINE TIPO_BEM				8
#DEFINE TIPO_ATIV				9
#DEFINE TIPO_SALD				10

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPosi็ใo do Array aBase com os valores do Bemณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
#DEFINE DEPRECIACAO_ACUMULADA		 1
#DEFINE CORRECAO_DA_DEPRECIACAO	 	 2
#DEFINE VALOR_ORIGINAL 				 3
#DEFINE CORRECAO_ACUMULADA			 4
#DEFINE VALOR_DA_AMPLIACAO			 5
#DEFINE TAXA_DE_DEPRECIACAO		 	 6 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPosi็ใo do Array aBem com os dados do Bemณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
#DEFINE BEM_FILIAL			1
#DEFINE BEM_BASE				2
#DEFINE BEM_ITEM				3
#DEFINE BEM_TIPO				4
#DEFINE BEM_SEQ				5
#DEFINE BEM_SEQREAV			6
#DEFINE BEM_CCDEPR			7
#DEFINE BEM_CCCDEP			8
#DEFINE BEM_SUBCCDE			9
#DEFINE BEM_CLVL				10
#DEFINE BEM_AQUISIC			11
#DEFINE BEM_DINDEPR			12
#DEFINE BEM_PATRIM			13
#DEFINE BEM_BAIXA				14
#DEFINE BEM_TPDEPR			15
#DEFINE BEM_VMXDEPR			16
#DEFINE BEM_PERDEPR			17
#DEFINE BEM_VLSALV1			18
#DEFINE BEM_PRODMES			19
#DEFINE BEM_PRODANO			20
#DEFINE BEM_CODIND			21
#DEFINE BEM_TPSALDO			22

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFlag de Bem Real e Bem de Modificacao de simulacao ณ 
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
#DEFINE BEM_REAL				'R'
#DEFINE BEM_MODIFICACAO		'M'

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPosicao do array para controle do processamento MultThreadณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
#DEFINE ARQUIVO		 		1
#DEFINE MARCA		 			2
#DEFINE QTD_REGISTROS		3
#DEFINE REC_MIN				4
#DEFINE REC_MAX				5

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFlag de processamento escrito no arquivo de controle ณ
//ณde threads                                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
#DEFINE OK		 		"OK"
#DEFINE ERRO		 	"ERRO"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณTipos de Acao de    Modificacaoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
#DEFINE DIVIDIR	 	"1"
#DEFINE INFORMAR	 	"2"
#DEFINE REPLICAR	 	"3"


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณTipo de Modifica็ใoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
#DEFINE AQUISICAO	"1"
#DEFINE BAIXA	 	"2"

//********************************
// Controle de multiplas moedas  *
//********************************
Static lMultMoed := .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณATFA350   บAutor  ณ Evaldo V. Batista  บ Data ณ  29/09/2008 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Manutencao de Simulacao e projecao de depreciacao          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/                                        
Function ATFA350()
Local aCores   		:= Af350Leg(.T.)
Local nNumProc		    := GetMv("MV_A350THR", .F., 1 )

Private cCadastro 	:= STR0011
Private aRotina 		:= MenuDef()
Private cMarca 		:= GetMark()
Private aTmpTabs		:= {}
Private aMarks		    := {}
Private aPanels		:= {}
Private cMoedaAtf 	:= GetMV("MV_ATFMOED")
Private aIndexCab		:= {}
Private oFolder		:= Nil
Private aGetD 		    := Nil	
Private cPerg			:= "AF350S"

ChkFile("SNQ")
ChkFile("SNR")
ChkFile("SNS")
ChkFile("SNN")

If nNumProc < 1 .or. nNumProc > 15
	Help(" ",1,"ATFA350THREAD",,STR0086+CTRL+STR0087+CTRL+STR0088+CTRL+STR0089,1,0) //"O parโmetro MV_A350THR estแ definido com" //" valor fora da faixa permitida (entre 1 "//"e 15 threads), serแ considerado o valor "// "padrใo de 1 thread"
	nNumProc := 1
EndIf	

Pergunte(cPerg,.F.)
SetKey( VK_F12, { || Pergunte(cPerg,.T.) })

dbSelectArea('SNQ') // Simula็ใo de Deprecia็ใo
SNQ->( dbSetOrder( 1 ) ) // Filial + C๓digo da Simula็ใo + Revisใo da Simula็ใo

mBrowse(,,,,"SNQ",,,,,,aCores)                                                  

Return

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFun็๕es                  ณ
//ณTela de cadastro e Wizardณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAf350Inc  บAutor  ณ Evaldo V. Batista  บ Data ณ  29/09/2008 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Consulta, Cadastro e Alteracao de Simulacoes               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function Af350Inc(cAlias, nReg, nOpc) 
Local oWizard 	:= Nil
Local aPBox1		:= {} 
Local aPBox2		:= {}
Local nOpcRot		:= 0
LOCAL nSaveSx8Len	:= GetSx8Len()
Local aRet2		:= {If( nOpc == INCLUIR, 1, If(SNQ->NQ_STATUS$'1/2',2,1) )}
Local cCodSim		:= If( nOpc == INCLUIR, GetSxeNum('SNQ','NQ_CODIGO'), SNQ->NQ_CODIGO ) 
Local cRevSim		:= If( nOpc == INCLUIR, '0001', If( nOpc == REVISAR, AF350GetRev( SNQ->NQ_CODIGO ) , SNQ->NQ_REVISAO) ) 
Local cBaseMod		:= If( nOpc == INCLUIR, cCodSim + cRevSim, SNQ->NQ_BASMOD )
Local cFilDe		:= If( nOpc == INCLUIR, cFilAnt, SNQ->NQ_FILDE )
Local cFilAte		:= If( nOpc == INCLUIR, cFilAnt, SNQ->NQ_FILATE )
Local lTpBem		:= .T.
Local cTpBem		:= "1"
Local lTpAtivo	:= .T.
Local nTpAtivo	:= 0
Local lTpSaldo	:= .T.
Local cTpSaldo	:= ""
Local aTitles		:= {} //'Totais do Rateio'###'Detalhes dos Impostos'###'Descri็ใo Extendida'
Local aPages		:= {}
Local nOldOpc		:= nOpc
Local nA			:= 0
Local nOpcGet		:= 0
Local aHeader		:= {}
Local aCols		:= {}

// Respostas da perguntas do 1 parambox (Parametros Gerais)
Private aRetPer := {}
Private aCombo  := {STR0113,STR0114,STR0115} 	// Lista de opcoes para selecao do tipo de bem para simulacao: 'Real'###'Planejado'###'Ambos'
Private aCmbTpAt:= {STR0117,STR0118}

If lTpAtivo .AND. lTpSaldo
	aRetPer := ARRAY(10)
Else
	aRetPer := ARRAY(8)
EndIf

/*
 * Verifica็ใo da exist๊ncia do campo do tipo de ativo da tabela de Simula็ใo de Deprecia็ใo
 */
If lTpBem
	cTpBem:= If( nOpc == INCLUIR, "1", SNQ->NQ_TIPBEM)
EndIf

/*
 * Verifica็ใo da exist๊ncia do campo do tipo de ativo da tabela de Simula็ใo de Deprecia็ใo
 */
If lTpAtivo
	nTpAtivo := If( nOpc == INCLUIR, 1, SNQ->NQ_TPATIVO)
EndIf

/*
 * Verifica็ใo da exist๊ncia do campo do tipo de saldo contแbil da tabela de Simula็ใo de Deprecia็ใo
 */
If lTpSaldo
	cTpSaldo := If( nOpc == INCLUIR, "1", SNQ->NQ_TPSALDO)
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ[ฟ
//ณVerifica se o usuario concorda que o lan็amento aglutinadoณ
//ณquebre em n documentos por causa do processamento         ณ
//ณmultithread                                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ[ู
If nOpc <> VISUALIZAR .And. !Af350VlAgl()
	Return()
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณIncializa็ใo dos array de resposta do paramboxณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aRetPer[CODIGO] 				:= Space(TamSx3('NQ_CODIGO')[1])				
aRetPer[REVISAO] 				:= Space(TamSx3('NQ_REVISAO')[1])
aRetPer[PERIODO_INICIAL] 	:= CtoD('')
aRetPer[QTD_PERIODOS] 		:= 1
aRetPer[BASE_MOD] 			:= Space(TamSx3('NS_CBASE')[1])
aRetPer[FILIAL_DE] 			:= Space(TamSx3('NQ_FILDE')[1])
aRetPer[FILIAL_ATE] 			:= Space(TamSx3('NQ_FILATE')[1])

If lTpBem
	aRetPer[TIPO_BEM] 		:= If(INCLUI,aCombo[1],aCombo[VAL(SNQ->NQ_TIPBEM)])
EndIf

If lTpAtivo
	aRetPer[TIPO_ATIV	] 		:= If(INCLUI,aCmbTpAt[1],aCmbTpAt[VAL(SNQ->NQ_TPATIVO)])
EndIf

If lTpSaldo			
	aRetPer[TIPO_SALD	] 		:= If(INCLUI,"1",SNQ->NQ_TPSALDO)
EndIf			

If SNQ->NQ_STATUS = '3' .and. nOpc == ALTERAR
	Help(" ",1,"ATFA350NOALT",, STR0078,1,0) //"Nใo ้ permitido alterar um item jแ processado!"
	Return( .F. ) 
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMontagem do acols da get de modificadoresณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aHeader := CriaHeader(nil,'NR_CODIGO/NR_REVISAO',aHeader,'SNR')
aCols   := CriaAcols(aHeader,'SNR',1,xFilial('SNR')+SNQ->( NQ_CODIGO+NQ_REVISAO ),nOpc,aCols,'NR_NRITEM','NR_FILIAL+NR_CODIGO+NR_REVISAO')

//Wizard 1: Parametros: //Codigo, Revisao, Data Inicial, Quantidade de Periodos
//Wizard 2: Grupo de Bens
//Wizard 3: Entidades de Filtro
//Wizard 4: Cadastro de Modificadores
//Wizard 5: Radio de Tipo de processamento. 1=Gravar e Processar; 2=Somente Gravar;
//Primeira pagina do Wizard
aAdd(aPBox1,{ 1,	STR0017,	Space(TamSx3('NQ_CODIGO')[1]),	"@!",    "",								  "SNQ","INCLUI",			   			50	,.T.}) //"Codigo"
aAdd(aPBox1,{ 1,	STR0018,	Space(TamSx3('NQ_REVISAO')[1]),	"@!",    "",							   	  "",   "INCLUI",			   			50	,.T.}) //"Revisใo"
aAdd(aPBox1,{ 1,	STR0019,	CtoD(''),						"@D",    "",								  "",   ".F.",							50	,.T.}) //"Perํodo Inicial"
aAdd(aPBox1,{ 1,	STR0020,	1,								"@E 999","",								  "",   If(nOpc==VISUALIZAR,".F.",""),	50	,.T.}) //"Perํodos a Processar"
aAdd(aPBox1,{ 1,	STR0098,	Space(TamSx3('NS_CBASE')[1]),	"@!",	 "ExistChav('SN1',MV_PAR05,1)",		  "",   If(nOpc==VISUALIZAR,".F.",""),	50	,.T.}) //"Codigo do Bem Modificador"
aAdd(aPBox1,{ 1,	STR0099,	Space(TamSx3('NQ_FILDE')[1]),	"@!",	 "VAZIO(MV_PAR06).OR.FWFilExist(cEmpAnt,MV_PAR06)","SM0_01",If(nOpc==VISUALIZAR,".F.",""),	50	,.T.}) //"Filial De"
aAdd(aPBox1,{ 1,	STR0100,	Space(TamSx3('NQ_FILATE')[1]),	"@!",	 "FWFilExist(cEmpAnt,MV_PAR07)","SM0_01",If(nOpc==VISUALIZAR,".F.",""),	50	,.T.}) //"Filial Ate"
aAdd(aPBox1,{ 2,	STR0112,    1,aCombo ,50						,    ""																,.T.}) //"Considera Bens"###'Real'###'Planejado'###'Ambos'

If lTpAtivo
	aAdd(aPBox1,{ 2,	STR0116,    1, aCmbTpAt ,50						,    ""																,.T.}) // "Tipo de Ativo"
EndIf

If lTpSaldo 
	aAdd(aPBox1,{ 1,	STR0119,	Space(TamSx3('N3_TPSALDO')[1]),	"@!",    "VldTpSald(MV_PAR10)",	 "SLD","INCLUI",			   			50	,.T.}) // "Tipo de Saldo"
EndIf

aRetPer[CODIGO]   	:= cCodSim
aRetPer[REVISAO]  	:= cRevSim
aRetPer[BASE_MOD] 	:= cBaseMod
aRetPer[FILIAL_DE] 	:= cFilDe
aRetPer[FILIAL_ATE]	:= cFilAte

If lTpBem
	aRetPer[TIPO_BEM	] 		:= If(INCLUI,aCombo[1],aCombo[VAL(SNQ->NQ_TIPBEM)])
EndIf

If lTpAtivo
	aRetPer[TIPO_ATIV	] 		:= If(INCLUI,aCmbTpAt[1],aCmbTpAt[VAL(SNQ->NQ_TPATIVO)])
EndIf

If lTpSaldo			
	aRetPer[TIPO_SALD	] 		:= cTpSaldo
EndIf	

MV_PAR05 := cBaseMod 
MV_PAR06 := cFilDe 
MV_PAR07 := cFilAte

If lTpBem
	MV_PAR08 := If(INCLUI,aCombo[1],aCombo[VAL(SNQ->NQ_TIPBEM)])
EndIf

If lTpAtivo	
	MV_PAR09 := If(INCLUI,aCmbTpAt[1],aCmbTpAt[VAL(SNQ->NQ_TPATIVO)])
EndIf

If lTpSaldo
	MV_PAR10 := cTpSaldo
EndIf

aRetPer[PERIODO_INICIAL] := GetMv('MV_ULTDEPR')
If nOpc == INCLUIR
	aRetPer[QTD_PERIODOS] := 1
Else
	aRetPer[QTD_PERIODOS] := SNQ->NQ_QTDMES
EndIf
 
//Ultima pagina do Wizard
aAdd(aPBox2,{3,STR0014,2,{STR0015,STR0016},50,"",.T.})  //"Simular Agora"###"Sim"###"Nใo"

aMarks 	:= {}
aTmpTabs	:= {}

DEFINE WIZARD oWizard TITLE STR0021 ; //"Simula็ใo e Proje็ใo de Deprecia็ใo"
       HEADER STR0022 ; 	//"Parametriza็ใo da Simula็ใo e Proje็ใo de Deprecia็ใo"
       MESSAGE STR0023 ; 	//"Parโmetros Iniciais..."
       TEXT STR0024 + ;		//"Esta rotina define os parโmetros necessarios para a simula็ใo"
       		STR0025 + ;		//"e Proje็ใo de Deprecia็ใo."
       		CRLF +; 
       		STR0026 + ;		//"Informe todos os parโmetros corretamente e defina como serแ o"
       		STR0027 + ; 	//"processamento que pode ser executado ao final dos  parโmetros"
       		STR0028; 		//"ou deixado para execu็ใo posterior."
       NEXT {||.T.} ;
       FINISH {|| .T. } ;
       PANEL

	//Segunda Pagina 
   CREATE PANEL oWizard ;
          HEADER STR0029; 	//"Informe Parโmetros Iniciais" ;
          MESSAGE STR0030; 	//"Todos os Campos Sใo Obrigat๓rios" ;
          BACK {|| .T. } ;
          NEXT {|| af350VldPar(aRetPer, nOpc) } ;
          FINISH {|| .T. } ;
          PANEL
	//Terceira Pagina
   CREATE PANEL oWizard ;
          HEADER STR0031;  //"Entidades" ;
          MESSAGE STR0032; //"Selecione as Entidades de Bens para simula็ใo" ;
          BACK {|| .T. } ;
          NEXT {|| .T. } ;
          FINISH {|| .T. } ;
          PANEL
	//Quarta Pagina
   CREATE PANEL oWizard ;
          HEADER STR0033; 	//"Cadastro de Modificadores" ;
          MESSAGE STR0034; 	//"Informe os Modificadores de Deprecia็ใo" ;
          BACK {|| .T. } ;                                          
          NEXT {|| Af350ModNe(nOpc) } ;
          FINISH {|| .T. } ;
          PANEL
If nOpc <> VISUALIZAR
	//Quinta Pagina
   CREATE PANEL oWizard ;
          HEADER STR0035; 	//"Processamento..." ;
          MESSAGE STR0036; 	//"Informe o que deseja fazer." ;
          BACK {|| .T. } ;
          NEXT {|| .T. } ;
          FINISH {|| nOpcRot := 1 , Af350GrvWz(aRetPer, aRet2, nOpc) } ;
          PANEL
EndIf

ParamBox(aPBox1,STR0037,@aRetPer,,,,,,oWizard:GetPanel(2)) //"Parโmetros..."

oFolder := TFolder():New(0,0,aTitles,aPages,oWizard:GetPanel(3),,,, .T., .T.,30,30,)
oFolder:Align 		:= CONTROL_ALIGN_ALLCLIENT
oFolder:nOption 	:= 1

aCpoBrw := {}
aAdd( aCpoBrw,  { "NG_OK",, 		"", "" } ) 
aAdd( aCpoBrw,  { "NG_GRUPO",40, 	"", "" } ) 
aAdd( aCpoBrw,  { "NG_DESCRIC",40, 	"", "" } ) 
MsgRun( STR0039, STR0038, {|| aAdd( aTmpTabs, ADMSQLMARK('SNG', @oFolder, aCpoBrw, STR0120, nOpc, SNQ->NQ_GRPBENS,MV_PAR01 == 2 )) } )  //'Coletando Grupos '###'Aguarde...' // "Grupo Bens"

aCpoBrw := {}
aAdd( aCpoBrw,  { "CT1_OK",, 		"", "" } ) 
aAdd( aCpoBrw,  { "CT1_CONTA",40, 	"", "" } ) 
aAdd( aCpoBrw,  { "CT1_DESC01",40, 	"", "" } ) 
MsgRun( STR0040, STR0038, {|| aAdd( aTmpTabs, ADMSQLMARK('CT1', @oFolder, aCpoBrw, STR0121, nOpc, SNQ->NQ_CCDEPR,MV_PAR01 == 2)) } )  //'Coletando Contas '###'Aguarde...' // "Conta Deprecia็ใo"

aCpoBrw := {}
aAdd( aCpoBrw,  { "CTT_OK",, 		"", "" } ) 
aAdd( aCpoBrw,  { "CTT_CUSTO",40, 	"", "" } ) 
aAdd( aCpoBrw,  { "CTT_DESC01",40, 	"", "" } ) 
MsgRun( STR0041, STR0038, {|| aAdd( aTmpTabs, ADMSQLMARK('CTT', @oFolder, aCpoBrw, STR0122, nOpc, SNQ->NQ_CCCDEP,MV_PAR01 == 2 )) } ) //'Coletando Centros de Custo '###'Aguarde...' // "Centro de Custo"

aCpoBrw := {}
aAdd( aCpoBrw,  { "CTD_OK",, 		"", "" } ) 
aAdd( aCpoBrw,  { "CTD_ITEM",40, 	"", "" } ) 
aAdd( aCpoBrw,  { "CTD_DESC01",40, 	"", "" } ) 
MsgRun( STR0042, STR0038, {|| aAdd( aTmpTabs, ADMSQLMARK('CTD', @oFolder, aCpoBrw, STR0123, nOpc, SNQ->NQ_SUBCCDE,MV_PAR01 == 2 )) } ) //'Coletando Itens Contabeis '###'Aguarde...' //  "Itens Contabeis"

aCpoBrw := {}
aAdd( aCpoBrw,  { "CTH_OK",, 		"", "" } ) 
aAdd( aCpoBrw,  { "CTH_CLVL",40,	"", "" } ) 
aAdd( aCpoBrw,  { "CTH_DESC01",40, 	"", "" } ) 
MsgRun( STR0043, STR0038, {|| aAdd( aTmpTabs, ADMSQLMARK('CTH', @oFolder, aCpoBrw, STR0124, nOpc, SNQ->NQ_CLVLCDE,MV_PAR01 == 2 )) } )  //'Coletando Classes de Valor '###'Aguarde...' //  "Classe de Valor"


If nOpc <> VISUALIZAR 
	oFolder:bSetOption 	:= {|nPasta| aEval(oFolder:aDialogs[nPasta]:aControls, {|x| x:Refresh() }), aMarks[nPasta, 1]:oBrowse:SetFocus(), aMarks[nPasta,1]:oBrowse:Refresh() } 
	ParamBox(aPBox2,STR0044,@aRet2,,,,,,oWizard:GetPanel(5)) //"Processamento..."
EndIf

If nOpc == INCLUIR .Or. nOpc == ALTERAR 
	nOpcGet	:= GD_INSERT+GD_UPDATE+GD_DELETE
Else
	nOpcGet	:= 0
EndIf

oGetD:= MsNewGetDados():New(001,001,090,090,nOpcGet,"Af350LinOk(" + cTpBem + ")","Af350TudOk","+NR_NRITEM",/*aCpoHead*/,/*freeze*/,120,/*fieldok*/,/*superdel*/,/*delok*/,oWizard:GetPanel(4),aHeader,aCols)
oGetD:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

ACTIVATE WIZARD oWizard CENTERED

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฐ
//ณRetorna a numera็ใo caso o usuแrio nใo confirmeณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
If nOpcRot == 0 .And. nOpc == INCLUIR 
	While GetSx8Len() > nSaveSx8Len
		RollBackSx8()
	End
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณApaga as tabelas temporariasณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nA := 1 To Len( aTmpTabs ) 
	(aTmpTabs[nA])->( dbCloseArea() ) 
	MsErase(aTmpTabs[nA])
Next nA

Return                                                                                                      


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF350GetRevบAutor ณAlvaro Camillo Neto บ Data ณ  13/05/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna o pr๓ximo c๓digo de revisใo da simula็ใo           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA350                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF350GetRev( cCod ) 
Local aArea := GetArea()
Local cRev	:= "0000"
Local cQuery:= ""
Local cTab	:= AF350NextAlias()

If Select(cTab) > 0
	(cTab)->(dbCloseArea())
EndIf

cQuery += " SELECT NQ_REVISAO FROM " + RetSQLTab("SNQ")
cQuery += " WHERE NQ_CODIGO = '" + cCod +"' AND "
cQuery += RetSQLCond("SNQ")
cQuery += "ORDER BY NQ_REVISAO DESC "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cTab, .F., .T.)

If (cTab)->(!EOF())
	cRev := Soma1( (cTab)->NQ_REVISAO )
EndIf 

(cTab)->(dbCloseArea())
RestArea(aArea)

Return cRev
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณMenuDef   ณ Autor ณ Evaldo V. Batista     ณ Data ณ29/09/2008ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Utilizacao de menu Funcional                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณArray com opcoes da rotina.                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณParametros do array a Rotina:                               ณฑฑ
ฑฑณ          ณ1. Nome a aparecer no cabecalho                             ณฑฑ
ฑฑณ          ณ2. Nome da Rotina associada                                 ณฑฑ
ฑฑณ          ณ3. Reservado                                                ณฑฑ
ฑฑณ          ณ4. Tipo de Transao a ser efetuada:                        ณฑฑ
ฑฑณ          ณ	  1 - Pesquisa e Posiciona em um Banco de Dados           ณฑฑ
ฑฑณ          ณ    2 - Simplesmente Mostra os Campos                       ณฑฑ
ฑฑณ          ณ    3 - Inclui registros no Bancos de Dados                 ณฑฑ
ฑฑณ          ณ    4 - Altera o registro corrente                          ณฑฑ
ฑฑณ          ณ    5 - Remove o registro corrente do Banco de Dados        ณฑฑ
ฑฑณ          ณ5. Nivel de acesso                                          ณฑฑ
ฑฑณ          ณ6. Habilita Menu Funcional                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ   DATA   ณ Programador   ณManutencao efetuada                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ               ณ                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function MenuDef()
Private aRotina :=  { 	{ STR0001,	"AxPesqui", 	1, 1},; 			//'Pesquisar'
						{ STR0002,	"AF350Inc", 	2, VISUALIZAR},; 	//'Visualizar'
						{ STR0003,	"AF350Inc", 	3, INCLUIR},; 		//'Incluir'
						{ STR0010,	"AF350Inc", 	4, ALTERAR},;		//'Alterar'
						{ STR0004,	"AF350Inc", 	4, REVISAR},;		//'Criar Revisao'
						{ STR0005,	"Af350GrvEx",	5, EXCLUIR},; 		//'Excluir'
						{ STR0097,	"A350OffCtb",	5, 2},; 	   		//"Contabilizar"
						{ STR0006,	"AF350Leg", 	2, 2} }   			//"Legenda"
Return(aRotina)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณA410LegendณAutor  ณ Eduardo Riera         ณ Data ณ13.09.2000 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณDemonstra a legenda das cores da mbrowse                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณNenhum                                                       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณNenhum                                                       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณEsta rotina monta uma dialog com a descricao das cores da    ณฑฑ
ฑฑณ          ณMbrowse.                                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณAtivo Fixo                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function Af350Leg(lRetCor)
Local aRet		:= {}
Local aCores := {	{"BR_BRANCO",	"NQ_STATUS = '1'", STR0007},;  //"Pendente de processamento"
					{"BR_AMARELO",	"NQ_STATUS = '2'", STR0008},;	//"Alterado - pendente de processamento"
					{"ENABLE",		"NQ_STATUS = '3'", STR0009} } 	//"Processado"

DEFAULT lRetCor := .F. 
If ValType(lRetCor) <> 'L'; lRetCor := .F.; EndIf
If lRetCor
	aEval( aCores, {|x|  Aadd( aRet, {x[2],x[1]} ) } ) 
Else
	aEval( aCores, {|x|  Aadd( aRet, {x[1],x[3]} ) } ) 
	BrwLegenda(cCadastro,STR0125,aRet) // "Legenda"
	aRet := Nil
EndIf

Return(aRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAf350GrvWzบAutor  ณ Evaldo V. Batista  บ Data ณ  10/02/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava as Informacoes do Wizard                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function Af350GrvWz(aRetPer, aRet2, nOpc)
Local lGrava	:= .F.
Local nPosItem 	:= aScan( oGetD:aHeader, {|x| Upper(AllTrim(x[2])) == 'NR_NRITEM' } ) 
Local nPosFilBem	:= aScan( oGetD:aHeader , {|x| Upper(AllTrim(x[2])) == 'NR_FILBEM' } )
Local lTpBem		:= .T.
Local lTpAtivo	:=  .T.
Local lTpSaldo	:=  .T.

Local nA, nB	:= 0
Local lRet		:= .T.
Local lCont		:= .T.

If nOpc == INCLUIR
	RecLock( 'SNQ', .T. ) 
	lGrava := .T.
ElseIf nOpc == ALTERAR
	RecLock( 'SNQ', .F. ) 
	lGrava := .T.
ElseIf nOpc == REVISAR
	RecLock( 'SNQ', .T. ) 
	lGrava := .T.
EndIf
                                                                              
If lGrava 
	SNQ->NQ_FILIAL 	:= xFilial('SNQ')
	SNQ->NQ_CODIGO 	:= aRetPer[CODIGO]
	SNQ->NQ_REVISAO	:= aRetPer[REVISAO]
	SNQ->NQ_DATAINI	:= aRetPer[PERIODO_INICIAL]
	SNQ->NQ_QTDMES 	:= aRetPer[QTD_PERIODOS]
	SNQ->NQ_BASMOD	:= aRetPer[BASE_MOD]
	SNQ->NQ_FILDE		:= aRetPer[FILIAL_DE]
	SNQ->NQ_FILATE	:= aRetPer[FILIAL_ATE]
	SNQ->NQ_GRPBENS	:= Af350ForIn(aMarks[1,6],	"NG_GRUPO",		"NG_OK  <> ' '"	)
	SNQ->NQ_CCDEPR 	:= Af350ForIn(aMarks[2,6],	"CT1_CONTA",	"CT1_OK <> ' '"	)
	SNQ->NQ_CCCDEP 	:= Af350ForIn(aMarks[3,6],	"CTT_CUSTO",	"CTT_OK <> ' '"	)
	SNQ->NQ_SUBCCDE	:= Af350ForIn(aMarks[4,6],	"CTD_ITEM",		"CTD_OK <> ' '"	)
	SNQ->NQ_CLVLCDE	:= Af350ForIn(aMarks[5,6],	"CTH_CLVL",		"CTH_OK <> ' '"	)
	If nOpc == INCLUIR .or. nOpc == REVISAR
		SNQ->NQ_STATUS 	:= '1' //Cadastrado (Pendente de Processamento) 
	Else
		SNQ->NQ_STATUS 	:= '2' //Alterado (pendente de Processamento)
	EndIf
	
	/*
	 * Se existir o campo de tipo de bem na tabela de Simula็ใo de Deprecia็ใo, o mesmo ้ gravado
	 */
	If lTpBem
		SNQ->NQ_TIPBEM := CVALTOCHAR(aScan(aCombo,aRetPer[TIPO_BEM]))
	EndIf
	
	/*
	 * Se existir o campo de tipo de ativo na tabela de Simula็ใo de Deprecia็ใo, o mesmo ้ gravado
	 */
	If lTpAtivo
		SNQ->NQ_TPATIVO := CVALTOCHAR(aScan(aCmbTpAt,aRetPer[TIPO_ATIV]))
	EndIf
	
	/*
	 * Se existir o campo de tipo de saldo contแbil na tabela de Simula็ใo de Deprecia็ใo, o mesmo ้ gravado
	 */
	If lTpSaldo			
		SNQ->NQ_TPSALDO := aRetPer[TIPO_SALD]
	EndIf
		
	SNQ->( MsUnLock() )
	
	If Len(oGetD:aCols) > 0
		SNR->( dbSetOrder( 1 ) ) //NR_FILIAL+NR_CODIGO+NR_REVISAO+NR_NRITEM
		For nA := 1 To Len(oGetD:aCols)
			If !oGetD:aCols[nA,Len(oGetD:aCols[nA])] .And. !Empty(oGetD:aCols[nA,nPosFilBem])
				If SNR->( dbSeek( xFilial('SNR')+aRetPer[CODIGO]+aRetPer[REVISAO]+oGetD:aCols[nA, nPosItem], .F.) )
					RecLock('SNR', .F.) 
				Else
					RecLock('SNR', .T.) 
			    EndIf
				SNR->(FieldPut(FieldPos('NR_FILIAL'), 	xFilial('SNR') )) 
				SNR->(FieldPut(FieldPos('NR_CODIGO'), 	aRetPer[CODIGO] )) 
				SNR->(FieldPut(FieldPos('NR_REVISAO'), aRetPer[REVISAO] )) 
			    For nB := 1 To Len( oGetD:aHeader ) 
					If AllTrim(Upper(oGetD:aHeader[nB,2])) == 'NR_FILIAL'
						SNR->(FieldPut(FieldPos(oGetD:aHeader[nB,2]), xFilial('SNR') )) 
					ElseIf AllTrim(Upper(oGetD:aHeader[nB,2])) == 'NR_CODIGO'
						SNR->(FieldPut(FieldPos(oGetD:aHeader[nB,2]), aRetPer[CODIGO] )) 
					ElseIf AllTrim(Upper(oGetD:aHeader[nB,2])) == 'NR_REVISAO'
						SNR->(FieldPut(FieldPos(oGetD:aHeader[nB,2]), aRetPer[REVISAO] )) 
					Else
						SNR->(FieldPut(FieldPos(oGetD:aHeader[nB,2]), oGetD:aCols[nA, nB])) 
			        EndIf
			    Next nB
			    SNR->( MsUnLock() ) 
			Else //Item Deletado
				If SNR->( dbSeek( xFilial('SNR')+aRetPer[CODIGO]+aRetPer[REVISAO]+oGetD:aCols[nA, nPosItem], .F.) )
					RecLock('SNR', .F.) 
					SNR->( dbDelete() ) 
					SNR->( MsUnLock() ) 
				EndIf 
		    EndIf
	    Next nA
	EndIf
	If nOpc == INCLUIR
		ConfirmSx8()
	EndIf
ElseIf nOpc == INCLUIR
	RollBackSx8()
EndIf

If aRet2[1] == 1
	MsgRun( STR0038,STR0038, {|| Af350Proc(aRetPer) } )	
EndIf

Return( lRet ) 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAf350GrvExบAutor  ณ Evaldo V. Batista  บ Data ณ  10/02/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava a Exclusao da Simulacao                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function Af350GrvEx(aRetPer, aRet2, nOpc)
Local cCod 			:= SNQ->NQ_CODIGO
Local cRev 			:= SNQ->NQ_REVISAO
Local cUpdate		:= "" 
Local lContabiliza	:= .F.
Local lAglutina		:= .F.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ[ฟ
//ณVerifica se o usuario concorda que o lan็amento aglutinadoณ
//ณquebre em n documentos por causa do processamento         ณ
//ณmultithread                                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ[ู
If !Af350VlAgl()
	Return()
EndIf


If AxDeleta('SNQ',SNQ->( RECNO() ), nOpc ) == 2
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ[ฟ
	//ณRealiza a contabiliza็ใo dos estornos dos ณ
	//ณmovimentos de simula็ใo                   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ[ู
	Pergunte(cPerg,.F.)
	lContabiliza	:= MV_PAR02 == 1
	lAglutina		:= MV_PAR03 == 1
	If lContabiliza 
		AF350MCtb(cCod,cRev,cCod,cRev,lAglutina,.F.)
	EndIf
	
	Begin Transaction 	
	//Exclusao dos modificadores
	SNR->( dbSetOrder( 1 ) ) //NR_FILIAL+NR_CODIGO+NR_REVISAO+NR_NRITEM
	If SNR->( dbSeek( xFilial('SNR')+cCod+cRev, .T. ) ) 	
		While !SNR->( Eof() ) .and. xFilial('SNR')+cCod+cRev == SNR->(NR_FILIAL+NR_CODIGO+NR_REVISAO) 
			//EXCLUI OS MODIFICADORES
			RecLock('SNR', .F. )
			SNR->( dbDelete() ) 
			SNR->( MsUnLock() ) 
			SNR->( dbSkip() ) 
		EndDo
    EndIf
	
	//Exclusao dos movimentos de simulacao
	//Via Update pois as filiais dos movimentos dependem da filial do Bem a ser depreciado
	cUpdate := " UPDATE "+ RetSQLName("SNS") 
	cUpdate += " SET D_E_L_E_T_ = '*' "
	cUpdate += " WHERE "
	cUpdate += " NS_CODIGO = '"+cCod+"' AND "
	cUpdate += " NS_REVISAO = '"+cRev+"'"
	TcSqlExec(cUpdate)	
	End Transaction
EndIF
 

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณaf350LinOkบAutor  ณ Evaldo V. Batista  บ Data ณ  10/06/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Validacao da Linha da GetDados de Cadastro de Modificadoresบฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA350                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function Af350LinOk()
Local lRet 		:= .T.
Local n			:= oGetD:nAt
Local nPosNumIt	:= aScan( oGetD:aHeader , {|x| Upper(AllTrim(x[2])) == 'NR_NRITEM' } ) 
Local nPosFilBem	:= aScan( oGetD:aHeader , {|x| Upper(AllTrim(x[2])) == 'NR_FILBEM' } ) 
Local nPosTx01 	:= aScan( oGetD:aHeader , {|x| Upper(AllTrim(x[2])) == 'NR_TXDEPR1' } ) 
Local nPosVl01 	:= aScan( oGetD:aHeader , {|x| Upper(AllTrim(x[2])) == 'NR_VLRMOD1' } ) 
Local nPosTxAtv	:= aScan( oGetD:aHeader , {|x| Upper(AllTrim(x[2])) == 'NR_TXDEPR'+cMoedaAtf } ) 
Local nPosVlAtv	:= aScan( oGetD:aHeader , {|x| Upper(AllTrim(x[2])) == 'NR_VLRMOD'+cMoedaAtf } ) 

Local nPosCta 	:= aScan( oGetD:aHeader , {|x| Upper(AllTrim(x[2])) == 'NR_CCDEPR' } ) 
Local nPosCc 		:= aScan( oGetD:aHeader , {|x| Upper(AllTrim(x[2])) == 'NR_CCCDEP' } ) 
Local nPosItem 	:= aScan( oGetD:aHeader , {|x| Upper(AllTrim(x[2])) == 'NR_SUBCCDE' } ) 
Local nPosClVl 	:= aScan( oGetD:aHeader , {|x| Upper(AllTrim(x[2])) == 'NR_CLVLCDE' } ) 

Local nPosTpMod	:= aScan( oGetD:aHeader , {|x| Upper(AllTrim(x[2])) == 'NR_TPMOD' } ) 
Local nPosAcMod	:= aScan( oGetD:aHeader , {|x| Upper(AllTrim(x[2])) == 'NR_ACMOD' } ) 
Local nPosNPeri	:= aScan( oGetD:aHeader , {|x| Upper(AllTrim(x[2])) == 'NR_NPERIOD' } )

Local nPosTpDep	:= aScan( oGetD:aHeader , {|x| Upper(AllTrim(x[2])) == 'NR_TPDEPR' 	} ) // M้todo de Deprecia็ใo
Local nPosPerDp	:= aScan( oGetD:aHeader , {|x| Upper(AllTrim(x[2])) == 'NR_PERDEPR'	} ) // Perํodos a Depreciar
Local nPosVxMDp	:= aScan( oGetD:aHeader , {|x| Upper(AllTrim(x[2])) == 'NR_VMXDEPR'	} ) // Valor Mแximo a Depreciar
Local nPosVlSal	:= aScan( oGetD:aHeader , {|x| Upper(AllTrim(x[2])) == 'NR_VLSALV1'	} ) // Valor de Salvamento
Local nPosPrEst	:= aScan( oGetD:aHeader , {|x| Upper(AllTrim(x[2])) == 'NR_PRODANO'	} ) // Produ็ใo Estimada
Local nPosPrPer	:= aScan( oGetD:aHeader , {|x| Upper(AllTrim(x[2])) == 'NR_PRODMES'	} ) // Produ็ใo do Perํodo
Local nPosCodIn	:= aScan( oGetD:aHeader , {|x| Upper(AllTrim(x[2])) == 'NR_CODIND'		} ) // C๓digo do อndice de Deprecia็ใo

Local nPos		:= aScan( oGetD:aCols, {|nPos| 	nPos[nPosTpMod]	== oGetD:aCols[n, nPosTpMod] .and.; 
											nPos[nPosAcMod]	== oGetD:aCols[n, nPosAcMod] .and.; 
											nPos[nPosNPeri]	== oGetD:aCols[n, nPosNPeri] .and.; 
											nPos[nPosCta] 	== oGetD:aCols[n, nPosCta] .and.; 
											nPos[nPosCc] 	== oGetD:aCols[n, nPosCc] .and.; 
											nPos[nPosItem] 	== oGetD:aCols[n, nPosItem] .and.;
											nPos[nPosFilBem]== oGetD:aCols[n, nPosFilBem] .and.; 
											nPos[nPosClVl] 	== oGetD:aCols[n, nPosClVl] .and.; 
											!nPos[Len(nPos)]  } )
Local nTipAtivo	:= aScan(aCmbTpAt,aRetPer[TIPO_ATIV])

If !oGetD:aCols[n, Len( oGetD:aCols[n] ) ]

	/*
	 * Se็ใo de valida็๕es de acordo com o m้todo de deprecia็ใo informado na linha do Grid.
	 */
	If lRet .AND. nTipAtivo == 1 // Ativos Fiscal
		/*
		 * Se os bens forem fiscais, s๓ serใo permitidos os m้todos de deprecia็ใo Linear e Linear com Valor Mแximo de Deprecia็ใo
		 */
		If !(oGetD:aCols[nPos,nPosTpDep] $ "1|7")
			lRet := .F.
			Help(" ",1,"ATFA350TPDEPR",,STR0131 + CRLF + STR0132 + oGetD:aCols[nPos,nPosNumIt],1,0) // "Para bens do tipo Fiscal s๓ ้ possํvel efetuar a simula็ใo de deprecia็ใo com os m้todos de deprecia็ใo linear e deprecia็ใo linear com valor mแximo de deprecia็ใo." //"Verifique a linha nบ "
		EndIf
	EndIf
	
	/*
	 * Valida็๕es se o m้todo de deprecia็ใo for linear ou linear com valor mแximo de deprecia็ใo
	 */
	If lRet .And. nPosTpDep > 0
		If oGetD:aCols[nPos,nPosTpDep] == "7"
			If oGetD:aCols[nPos,nPosTx01] <= 0.00
				lRet := .F.
				Help(" ",1,"ATFA350TXDEP",,STR0051+CRLF+STR0053,1,0) //"ษ Obrigat๓rio o preenchimento da taxa "###"de deprecia็ใo na Moeda 1"
			EndIf
			
			If lRet .AND. oGetD:aCols[nPos,nPosVxMDp] <= 0.00
				lRet := .F.
				Help(" ",1,"ATFA350MXDEPR",,STR0133,1,0) // "ษ Obrigat๓rio o preenchimento do valor mแximo de deprecia็ใo."
			EndIf
			
			If lRet .AND. oGetD:aCols[nPos,nPosVxMDp] >= oGetD:aCols[nPos,nPosVl01]
				lRet := .F.
				Help(" ",1,"ATFA350MXDPRVL",,STR0134,1,0) // "O valor mแximo de deprecia็ใo deve ser menor que o valor original do bem."
			EndIf			
		ElseIf oGetD:aCols[nPos,nPosTpDep] == "2"
			If EMPTY(oGetD:aCols[nPos,nPosPerDp])
				lRet := .F.
				Help(" ",1,"ATFA350PERDEPR",,STR0138,1,0) // "ษ obrigat๓rio o preenchimento do perํodo de deprecia็ใo."
			EndIf
			
			If lRet .AND. oGetD:aCols[nPos,nPosVlSal] <= 0.00
				lRet := .F.
				Help(" ",1,"ATFA350VLSALV",,STR0135,1,0) // "ษ obrigat๓rio o preenchimento do valor de salvamento."
			EndIf	
		
		ElseIf oGetD:aCols[nPos,nPosTpDep] $ "4|5"
			If oGetD:aCols[nPos,nPosPrEst] <= 0.00
				lRet := .F.
				Help(" ",1,"ATFA350PRDEST",,STR0136,1,0) // "ษ obrigat๓rio o preenchimento do conte๚do de produ็ใo estimada."
			EndIf
			
			If lRet .AND. oGetD:aCols[nPos,nPosPrPer] <= 0.00
				lRet := .F.
				Help(" ",1,"ATFA350PRDPER",,STR0137,1,0) // "ษ obrigat๓rio o preenchimento do conte๚do de produ็ใo do perํodo."
			EndIf		
		ElseIf oGetD:aCols[nPos,nPosTpDep] ="6"
			If EMPTY(oGetD:aCols[nPos,nPosPerDp])
				lRet := .F.
				Help(" ",1,"ATFA350PERDEPR",,STR0138,1,0) // "ษ obrigat๓rio o preenchimento do perํodo de deprecia็ใo."
			EndIf
		
		ElseIf oGetD:aCols[nPos,nPosTpDep] == "A"
			If EMPTY(oGetD:aCols[nPos,nPosCodIn])
				lRet := .F.
				Help(" ",1,"ATFA350CODIND",,STR0139,1,0) // "ษ obrigat๓rio o preenchimento do c๓digo do ํndice de deprecia็ใo."
			EndIf
		EndIf
	EndIf  
	

	If 	nPosTpDep > 0 .And. nPosTpMod > 0 
		If nPosTx01 > 0 
			If lRet .and. Empty( oGetD:aCols[n, nPosTx01] ) .And. oGetD:aCols[n, nPosTpMod] == AQUISICAO .AND. oGetD:aCols[nPos,nPosTpDep] $ "17"
				lRet := .F.	
				Help(" ",1,"ATFA350TXDEP",,STR0051+CRLF+STR0053,1,0) //"ษ Obrigat๓rio o preenchimento da taxa "###"de deprecia็ใo na Moeda 1"
			EndIf
		EndIf
		
		If nPosTxAtv > 0
			If lRet .and. Empty( oGetD:aCols[n, nPosTxAtv] ) .And. oGetD:aCols[n, nPosTpMod] == AQUISICAO  .AND. oGetD:aCols[nPos,nPosTpDep] $ "17"
				lRet := .F.
				Help(" ",1,"ATFA350TXDEP",,STR0054+CRLF+STR0055+cMoedaAtf+")",1,0)//"ษ Obrigat๓rio o preenchimento da taxa "###"de deprecia็ใo na Moeda do Ativo Fixo ("
			EndIf
		EndIf
	EndIf
		
	If nPosVl01>0
		If lRet .and. Empty( oGetD:aCols[n, nPosVl01] ) 
			lRet := .F.
			Help(" ",1,"ATFA350MVALOR",,STR0056+CRLF+STR0057,1,0) //"ษ Obrigat๓rio o preenchimento "###"do Valor na Moeda 1"
		EndIf
	EndIf
	
	If nPosVlAtv>0
		If lRet .and. Empty( oGetD:aCols[n, nPosVlAtv] ) 
			lRet := .F.
			Help(" ",1,"ATFA350MVALOR",,STR0058+CRLF+STR0059+cMoedaAtf+")",1,0) //"ษ Obrigat๓rio o preenchimento "###"do Valor na Moeda do Ativo Fixo ("
		EndIf
	EndIf
	
	//Verifica se o numero de periodo estแ no Range Correto
	If  nPosNPeri > 0
		If lRet .and. oGetD:aCols[n, nPosNPeri] > aRetPer[QTD_PERIODOS] 
			lRet := .F.
			Help(" ",1,"ATFA350MPERIO",,STR0103+CRLF+STR0104,1,0) //"O periodo do bem ้ superior"###"ao da simula็ใo"
		EndIf
	EndIf
	//Verifica se a filial do Bem estแ no Range Correto
	If nPosFilBem > 0
		If lRet .and.  ( oGetD:aCols[n, nPosFilBem] <  aRetPer[FILIAL_DE] .Or. oGetD:aCols[n, nPosFilBem] >  aRetPer[FILIAL_ATE] )
			lRet := .F.
			Help(" ",1,"ATFA350MFILIA",,STR0105+CRLF+STR0106+cMoedaAtf+")",1,0) //"A filial do bem nao esta"###"no intervalo selecionado"
		EndIf
	EndIf
	
	//Verificar Duplicados
	If lRet .and. nPos>0 .and. nPos <> N .And. nPosNumIt > 0
		lRet := .F.
		Help(" ",1,"AF350DUPLIC",,STR0060+oGetD:aCols[nPos,nPosNumIt]+CRLF+STR0061,1,0) //"O Modificador de n๚mero: "###" ้ igual ao item atual"
	EndIf
    
    // Verificar a conta contabil
	If nPosCta > 0
		If lRet .and.  Empty(oGetD:aCols[n, nPosCta])
			lRet := .F.
			Help(" ",1,"AF350CTADP",,STR0141,1,0) //"ษ obrigat๓rio o preenchimento da Conta Contแbil."
		EndIf
	EndIf
    
EndIf	
Return( lRet ) 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAf350TudOkบAutor  ณ Evaldo V. Batista  บ Data ณ  10/06/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Validacao da Linha da GetDados de Cadastro de Modificadoresบฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA350                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function Af350TudOk() 
Local lRet := .T.

Return( lRet ) 


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAf350EntDeบAutor  ณ Evaldo V. Batista  บ Data ณ  10/06/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Validacao dos itens de Entidade Contabil                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA350                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function Af350EntDe()
Local lRet 		:= .T.
Local nPosCta 	:= aScan( oGetD:aHeader , {|x| Upper(AllTrim(x[2])) == 'NR_CCDEPR' } ) 
Local nPosCc 		:= aScan( oGetD:aHeader , {|x| Upper(AllTrim(x[2])) == 'NR_CCCDEP' } ) 
Local nPosItem 	:= aScan( oGetD:aHeader , {|x| Upper(AllTrim(x[2])) == 'NR_SUBCCDE' } ) 
Local nPosClVl 	:= aScan( oGetD:aHeader , {|x| Upper(AllTrim(x[2])) == 'NR_CLVLCDE' } ) 
Local cValidV		:= ReadVar()

//Validacao da Entidade
Do Case
	Case cValidV == 'M->NR_CCDEPR' //Conta
		If !Ctb105Cta()
			lRet := .F.
		EndIf
	Case cValidV == 'M->NR_CCCDEP' //Centro de Custo
		If !Ctb105CC() 
			lRet := .F.
		EndIf
	Case cValidV == 'M->NR_SUBCCDE' //Item Contabil
		If !Ctb105Item()
			lRet := .F.
		EndIf
	Case cValidV == 'M->NR_CLVLCDE' //Classe de Valor
		If !Ctb105ClVl()
			lRet := .F.
		EndIf
EndCase	

Return( lRet ) 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAf350ModNeบAutor  ณ Evaldo V. Batista  บ Data ณ  10/06/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Confirma Cadastro de Modificadores ?                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA350                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function Af350ModNe(nOpc)
Local lRet := .F.
Local nPosCta 	:= aScan( oGetD:aHeader , {|x| Upper(AllTrim(x[2])) == 'NR_CCDEPR' } ) 
Local nPos		:= aScan( oGetD:aCols, {|nPos|	!Empty( nPos[nPosCta] ) .and.; 
											!nPos[Len(nPos)]  } ) 
If nOpc <> VISUALIZAR 
	If nPos == 0 
		lRet := MsgNoYes(STR0062+CRLF+STR0063+CRLF+STR0064, STR0065) //'Nใo foram informados modificadores para o '###"processamento, confirma processamento "###"sem modificador?"###'Sem Moficadores'
	Elseif Af350LinOk()
		lRet := MsgYesNo(STR0066+STR0067, STR0068) //'Confirma o Cadastro dos modificadores informados ?'###'Confirma Modificadores'
	EndIf
EndIf
Return(lRet) 



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAf350ForInบAutor  ณMicrosiga           บ Data ณ  10/11/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function Af350ForIn(cTab,cCpo,cCond)
Local cTxtIn 	:= ""
Local cQuery 	:= ""
Local cAliasTmp	:= AF350NextAlias() 
Local aGetArea	:= GetArea()

cQuery := "SELECT "+cCpo
cQuery += " 	FROM "+cTab 
cQuery += " 	WHERE "+cCond

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., 'TOPCONN', TcGenQry(,, cQuery), cAliasTmp, .F., .F. ) 

dbSelectArea( cAliasTmp ) 

(cAliasTmp)->( dbEval( {|| cTxtIn += FieldGet(FieldPos(cCpo))+"','" } ) ) 
If !Empty(cTxtIn) 
	cTxtIn := "('"+SubStr(cTxtIn, 1, Len(cTxtIn)-3)+"')"
Else
	cTxtIn := ""
EndIf

(cAliasTmp)->( dbCloseArea() ) 

RestArea(aGetArea)
Return(cTxtIn)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณaf350VldParบAutor ณMicrosiga           บ Data ณ  10/17/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida็ใo dos parametros do 1 wizard                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function af350VldPar(aRetPer, nOpc)
Local lRet := .T.

SNQ->( dbSetOrder( 1 ) ) //NQ_FILIAL+NQ_CODIGO+NQ_REVISAO
If nOpc == INCLUIR .and. SNQ->( MsSeek(  xFilial('SNQ')+aRetPer[CODIGO]+aRetPer[REVISAO]  ) )
	//Inclusao e registro ja existe
	lRet := .F.
	Help(" ",1,"AF350JaExist",,STR0080+CRLF+STR0081,1,0) //"Nใo ้ possivel gerar esta simula็ใo"###" pois a mesma jแ existe"
EndIf

If lRet .and. EMPTY(aRetPer[CODIGO])
	lRet := .F.
	Help(" ",1,"AF350Codigo",,STR0082+CRLF+STR0083,1,0) //"ษ obrigatorio o preenchimento "###"do c๓digo da Simula็ใo"
EndIf

If lRet .and. EMPTY(aRetPer[REVISAO]) 
	lRet := .F.
	Help(" ",1,"AF350Revisa",,STR0084+CRLF+STR0085,1,0) //"ษ obrigatorio o preenchimento da Revisao da Simula็ใo"
EndIf

Return(lRet)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPROCESSAMENTO DA SIMULAวรOณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAf250Proc บAutor  ณ Evaldo V. Batista  บ Data ณ  10/17/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Iniciando Processamento para Mult Thread                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA350                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function af350Proc(aRetPer)
Local nA			:= 0
Local nMes			:= Month(aRetPer[PERIODO_INICIAL])
Local nAno			:= Year(aRetPer[PERIODO_INICIAL])
Local dDataSimu				
Local nQtdPer		:= aRetPer[QTD_PERIODOS]
Local aArea		:= GetArea()
Local aDatasSimu	:= {}
Local cCodigo		:= aRetPer[CODIGO]
Local cRevisao		:= aRetPer[REVISAO]
Local cBaseMod		:= aRetPer[BASE_MOD]
Local lRet			:= .T.
Local nNumProc   	:= GetMv("MV_A350THR", .F., 1 )
Local lContabiliza:= .F.
Local lAglutina	:= .F.
Local cFilde		:= aRetPer[FILIAL_DE]
Local cFilAte		:= aRetPer[FILIAL_ATE]
Local cTpSaldo		:= aRetPer[TIPO_SALD]
Local nTipBem		:= aScan(aCombo,aRetPer[TIPO_BEM])
Local nTpAtivo		:= aScan(aCmbTpAt,aRetPer[TIPO_ATIV])

SNQ->(dbSetOrder(1)) //NQ_FILIAL+NQ_CODIGO+NQ_REVISAO
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCalcula o periodo final da deprecia็ใoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aAdd(aDatasSimu,aRetPer[PERIODO_INICIAL])
For nA := 1 To nQtdPer
	nMes++
	If nMes > 12
		nMes := 1
		nAno++
	EndIf
	dDataSimu := LastDate(CtoD('01/'+StrZero(nMes,2)+'/'+StrZero(nAno,4)))
	aAdd(aDatasSimu,dDataSimu)
Next nA

lRet := A350MSim(aDatasSimu,cCodigo,cRevisao,nNumProc,cBaseMod,cFilDe,cFilAte,nTipBem,nTpAtivo,cTpSaldo)	

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGrava o status do processamentoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If SNQ->(MsSeek(xFilial("SNQ") + cCodigo + cRevisao )) .And. lRet
	RecLock("SNQ",.F.)
		SNQ->NQ_STATUS 	:= '3' //"Processado"
	MsUnlock() 
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณRealiza a contabiliza็ใo dos movimentos de simula็ใoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Pergunte(cPerg,.F.)
	lContabiliza	:= MV_PAR02 == 1
	lAglutina		:= MV_PAR03 == 1
	
	If lContabiliza 
		AF350MCtb(cCodigo,cRevisao,cCodigo,cRevisao,lAglutina)
	EndIf 
EndIf                         

RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA350MSim  บAutor  ณAlvaro Camillo Neto บ Data ณ  02/02/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza o preparo e o controle do processamento multi threadบฑฑ
ฑฑบ          ณda rotina                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA350                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A350MSim(aDatasSimu,cCodigo,cRevisao,nNumProc,cBaseMod,cFilDe,cFilAte,nTipBem,nTpAtivo,cTpSaldo)	
Local lRet   	:= .T.
Local nX	 	:= 0
Local aProcs 	:= {}                                          
Local cDirSem   := "\Semaforo\"
Local cRaizNome	:= 'ATFA350Proc'
Local cNomeArq	:= ""
Local cMarca	:= ""
Local aArea		:= GetArea()
Local nTotalReg	:= 0 // Total de Registros
Local nRegAProc	:= 0 // Registros a processar
Local nRegJProc	:= 0 // Total de registros jแ processados
Local cQuery	:= ""
Local cTabMult	:= AF350NextAlias() // Tabela para o processamento multi thread
Local aStruSQL	:= {} 
Local nMoeda	:= 0
Local cMoeda	:= ""
Local cSelect	:= ""
//********************************
// Controle de multiplas moedas  *
//********************************
Local __nQuantas := If(lMultMoed,AtfMoedas(),5)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCria a pasta do semaforo caso nใo existaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !ExistDir(cDirSem)
	MontaDir(cDirSem)
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDados Bแsicos do Bemณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
AADD(aStruSQL,{"N3_FILIAL"	,"C",TAMSX3("N3_FILIAL")[1]		,00})
AADD(aStruSQL,{"N3_CBASE" 	,"C",TAMSX3("N3_CBASE")[1]		,00})
AADD(aStruSQL,{"N3_ITEM"	,"C",TAMSX3("N3_ITEM")[1]		,00})
AADD(aStruSQL,{"N3_TIPO"	,"C",TAMSX3("N3_TIPO")[1]		,00})
AADD(aStruSQL,{"N3_BAIXA"	,"C",TAMSX3("N3_BAIXA")[1]		,00})
AADD(aStruSQL,{"N3_SEQ"		,"C",TAMSX3("N3_SEQ")[1]			,00})
AADD(aStruSQL,{"N3_OK" 	   	,"C",TAMSX3("N3_OK")[1]			,00})
AADD(aStruSQL,{"N3_SEQREAV"	,"C",TAMSX3("N3_SEQREAV")[1]	,00})
AADD(aStruSQL,{"N3_CCDEPR" 	,"C",TAMSX3("N3_CCDEPR")[1]		,00})
AADD(aStruSQL,{"N3_CCCDEP" 	,"C",TAMSX3("N3_CCCDEP")[1]		,00})
AADD(aStruSQL,{"N3_SUBCCDE"	,"C",TAMSX3("N3_SUBCCDE")[1]	,00})
AADD(aStruSQL,{"N3_CLVL" 	,"C",TAMSX3("N3_CLVL")[1]		,00})
AADD(aStruSQL,{"N3_AQUISIC"	,"D",TAMSX3("N3_AQUISIC")[1]	,00})
AADD(aStruSQL,{"N3_DINDEPR"	,"D",TAMSX3("N3_DINDEPR")[1]	,00})
AADD(aStruSQL,{"N3_TPSALDO"	,"C",TAMSX3("N3_TPSALDO")[1]	,00})
AADD(aStruSQL,{"N3_TPDEPR"	,"C",TAMSX3("N3_TPDEPR")[1]		,00})
AADD(aStruSQL,{"N3_VMXDEPR"	,"N",TAMSX3("N3_VMXDEPR")[1]	,TAMSX3("N3_VMXDEPR")[2]})
AADD(aStruSQL,{"N3_PERDEPR"	,"N",TAMSX3("N3_PERDEPR")[1]	,00})
AADD(aStruSQL,{"N3_VLSALV1"	,"N",TAMSX3("N3_VLSALV1")[1]	,TAMSX3("N3_VLSALV1")[2]})
AADD(aStruSQL,{"N3_PRODMES"	,"N",TAMSX3("N3_PRODMES")[1]	,TAMSX3("N3_PRODMES")[2]})
AADD(aStruSQL,{"N3_PRODANO"	,"N",TAMSX3("N3_PRODANO")[1]	,TAMSX3("N3_PRODANO")[2]})
AADD(aStruSQL,{"N3_CODIND"	,"C",TAMSX3("N3_CODIND")[1]	,00})
AADD(aStruSQL,{"N1_PATRIM"	,"C",TAMSX3("N1_PATRIM")[1]		,00})
AADD(aStruSQL,{"N3RECNO" 	,"N",08,00})
AADD(aStruSQL,{"N3FLAG" 	,"C",01,00})

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณValores do Bemณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
// ********************************
// Controle de multiplas moedas  *
// ********************************

For nMoeda := 1 to __nQuantas
	cMoeda := cValtoChar(nMoeda)
	If nMoeda>9
		AADD(aStruSQL,{"N3_VRDAC" 	+ cMoeda 	,"N",TAMSX3( "N3_VRDAC" + cMoeda )[1],TAMSX3( "N3_VRDAC"	+ cMoeda )[2]} )
		AADD(aStruSQL,{"N3_VORIG" 	+ cMoeda	,"N",TAMSX3( "N3_VORIG"  + cMoeda )[1],TAMSX3("N3_VORIG"	+ cMoeda )[2]} )
		AADD(aStruSQL,{"N3_AMPLI" 	+ cMoeda	,"N",TAMSX3( "N3_AMPLI" + cMoeda )[1],TAMSX3( "N3_AMPLI"	+ cMoeda )[2]} )
		AADD(aStruSQL,{"N3_TXDEP"	+ cMoeda 	,"N",TAMSX3( "N3_TXDEP" + cMoeda )[1],TAMSX3( "N3_TXDEP"	+ cMoeda )[2]} )
	Else
		AADD(aStruSQL,{"N3_VRDACM" 	+ cMoeda 	,"N",TAMSX3( "N3_VRDACM" + cMoeda )[1],TAMSX3( "N3_VRDACM"	+ cMoeda )[2]} )
		AADD(aStruSQL,{"N3_VORIG" 	+ cMoeda	,"N",TAMSX3( "N3_VORIG"  + cMoeda )[1],TAMSX3( "N3_VORIG"	+ cMoeda )[2]} )
		AADD(aStruSQL,{"N3_AMPLIA" 	+ cMoeda	,"N",TAMSX3( "N3_AMPLIA" + cMoeda )[1],TAMSX3( "N3_AMPLIA"	+ cMoeda )[2]} )
		AADD(aStruSQL,{"N3_TXDEPR"	+ cMoeda 	,"N",TAMSX3( "N3_TXDEPR" + cMoeda )[1],TAMSX3( "N3_TXDEPR"	+ cMoeda )[2]} )
	EndIf
Next nX


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCaptura a query  para os registrosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta a Clausula da SELECTณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nX := 1 to Len(aStruSQL)
	If !(aStruSQL[nX][1] $ 'N3RECNO/N3FLAG')
		cSelect += " "+aStruSQL[nX][1]+" ,"
	EndIf
Next nX
cSelect +=  " SN3.R_E_C_N_O_ N3RECNO, '"+BEM_REAL+"' N3FLAG " 

cQuery := SelBemDep(aTail(aDatasSimu),cSelect,cFilDe,cFilAte,nTpAtivo,cTpSaldo) 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCria tabela temporaria com base na SN3 para armazenar os dados da simulacao a serem tratados ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
MsErase(cTabMult)
MsCreate(cTabMult, aStruSQL, 'TOPCONN' ) 

dbUseArea( .T., 'TOPCONN', cTabMult, cTabMult, .T., .F. ) 
dbSelectArea( cTabMult ) 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCaptura a informacoes referentes aos Bens Reais ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nTipBem == 1 .Or. nTipBem == 3  	// 1=Real 2=Planejado 3=Ambos	

	cQuery := SelBemDep(aTail(aDatasSimu),cSelect,cFilDe,cFilAte,nTpAtivo,cTpSaldo) 

	SqlToTrb(cQuery, aStruSQL, cTabMult)

EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCaptura a informacoes referentes aos Bens Planejados ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nTipBem == 2	 .Or.  nTipBem == 3  // 1=Real 2=Planejado 3=Ambos
	SelPlnDep(aTail(aDatasSimu),cTabMult,cFilDe,cFilAte,__nQuantas) 
EndIf

If (cTabMult)->(!EOF())
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณRealiza a grava็ใo dos bens modificadores ณ
	//ณde simula็ใo na tabela temporaria         ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	A350ModTab(cTabMult,cCodigo,cRevisao,aDatasSimu,cBaseMod,nTpAtivo,cTpSaldo)
	
	(cTabMult)->(dbGoTop())
	(cTabMult)->(dbEval({|| nTotalReg++ }))
	(cTabMult)->(dbGoTop())
	
	If nTotalReg < nNumProc
		aProcs := Array(1)	
	Else
		aProcs := Array(nNumProc)
	EndIf 
	                         
	If Len(aProcs) > 1 // MultiThread
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณRealiza o calculos das quantidades de registrosณ
		//ณque cada thread irแ processar e                ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		For nX := 1 to Len(aProcs) 
			cNomeArq 	:= cDirSem + cRaizNome +cEmpAnt + cFilAnt +cValtoChar(nX) + '.lck' 
			cMarca		:= GetMark()
			nRegAProc	:= IIf( nX == Len(aProcs), nTotalReg-nRegJProc, Int(nTotalReg / nNumProc) )
			nRegJProc	+= nRegAProc 
			aProcs[nX]	:= {cNomeArq ,cMarca,nRegAProc,0,0}
		Next nX
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณRealiza o Update dos campos de flag setando quais registrosณ
		//ณcada thread irแ processar.                                 ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		A350FlagTab(cTabMult,aProcs,'N3RECNO',"N3_OK")
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณInicializa as Threadsณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		For nX := 1 to Len(aProcs)
			StartJob("A350JOBSIM",GetEnvServer(),.F.,cEmpAnt,cFilAnt,aProcs[nX][MARCA],aProcs[nX][ARQUIVO],cTabMult,aDatasSimu,cCodigo,cRevisao,cValToChar(nX),aStruSQL)		
		Next nX
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณRealiza o controle das Threadsณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		Sleep(3000)
		lRet := AF350Monitor(aProcs) 
	Else
		lRet := A350SSim(cTabMult,aDatasSimu,cCodigo,cRevisao) 
	EndIf
Else
	Help(" ",1,"ATFA350NOREC",,STR0091,1,0) //"Nใo ha registros a serem processados"
	If Len(oGetD:aCols) >= 1 .AND. !EMPTY(oGetD:aCols[1][2])
		Help(" ",1,"ATFA350NOMOD",,STR0140,1,0) // "Para utilizar os modificadores, sใo necessแrio registros de bens para serem processados."
	EndIf	
	lRet := .F.
EndIf                         

(cTabMult)->( dbCloseArea() )
MsErase(cTabMult)
RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSelBemDep บAutor  ณAlvaro Camillo Neto บ Data ณ  28/01/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza a sele็ao dos registros a serem processados pela    บฑฑ
ฑฑบ          ณsimula็ใo                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA350                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function SelBemDep(dLastDate,cSelect,cFilDe,cFilAte,nTpAtivo,cTpSaldo) 
Local cQuery 		:= ""
Local nPosSNG		:= aScan( aMarks, {|x| Upper(AllTrim(x[4])) == 'SNG' } ) 
Local nPosCT1		:= aScan( aMarks, {|x| Upper(AllTrim(x[4])) == 'CT1' } ) 
Local nPosCTT		:= aScan( aMarks, {|x| Upper(AllTrim(x[4])) == 'CTT' } ) 
Local nPosCTD		:= aScan( aMarks, {|x| Upper(AllTrim(x[4])) == 'CTD' } ) 
Local nPosCTH  	:= aScan( aMarks, {|x| Upper(AllTrim(x[4])) == 'CTH' } ) 
Local cTipos      := ""
Local ltAtivo     := .T.

Default cSelect		:= ""


If Empty(cSelect)
	cQuery += " SELECT SN3.N3_FILIAL,SN3.N3_CBASE,SN3.N3_ITEM,SN3.N3_TIPO,SN3.N3_BAIXA,SN3.N3_SEQ,SN3.N3_OK, SN3.R_E_C_N_O_ N3RECNO "+ CRLF
	cQuery += " SN1.N1_PATRIM "+ CRLF
Else
	cQuery += " SELECT " + cSelect + CRLF
EndIf
cQuery += " 	FROM "+RetSqlTab("SN1")+" "+ CRLF
cQuery += " 		INNER JOIN "+RetSqlTab("SN3")+" ON SN3.D_E_L_E_T_ = ' ' "+ CRLF
cQuery += " 									AND SN3.N3_FILIAL	= SN1.N1_FILIAL "+ CRLF
cQuery += " 									AND SN3.N3_CBASE	= SN1.N1_CBASE "+ CRLF
cQuery += " 									AND SN3.N3_ITEM		= SN1.N1_ITEM "+ CRLF
cQuery += " 									AND SN3.N3_FIMDEPR	= ' ' "+ CRLF
cQuery += " 									AND SN3.N3_BAIXA	<> '1' "+ CRLF
/*
 * Filtro de Tipos de Ativos
 */
If nTpAtivo == 1 // Bens Fiscais
	cTipos := ATFXTpBem(1)+"/"+ATFXTpBem(3)
ElseIf nTpAtivo == 2 // Bens Gerenciais
	cTipos := ATFXTpBem(2)
EndIf

If nTpAtivo == 1 .Or. nTpAtivo == 2 
	cQuery += " AND SN3.N3_TIPO	IN " + FormatIn(cTipos,"/") + CRLF
EndIf
/*
 * Filtro por Tipo de Saldo
 */
If ltAtivo .AND.  CVALTOCHAR(cTpSaldo) != "*"
	cQuery += " 								AND SN3.N3_TPSALDO = '" + CVALTOCHAR(cTpSaldo) + "' "+ CRLF
EndIf

If AF350Marc(aMarks[nPosSNG,6],"SNG") 
	cQuery += " 		INNER JOIN "+aMarks[nPosSNG,6]+" SNG ON SNG.NG_OK <> ' ' "+ CRLF
	cQuery += " 									AND SN1.N1_GRUPO = SNG.NG_GRUPO "+ CRLF
EndIf
If AF350Marc(aMarks[nPosCT1,6],"CT1") 
	cQuery += " 		INNER JOIN "+aMarks[nPosCT1,6]+" CT1 ON CT1_OK <> ' ' "     + CRLF                  
	cQuery += " 									AND SN3.N3_CCONTAB	= CT1_CONTA	"+ CRLF
EndIf
If AF350Marc(aMarks[nPosCTT,6],"CTT") 
	cQuery += " 		INNER JOIN "+aMarks[nPosCTT,6]+" CTT ON CTT_OK <> ' ' "+ CRLF
	cQuery += " 									AND SN3.N3_CCUSTO = CTT_CUSTO "+ CRLF
EndIF
If AF350Marc(aMarks[nPosCTD,6],"CTD") 
	cQuery += " 		INNER JOIN "+aMarks[nPosCTD,6]+" CTD ON CTD_OK <> ' ' "+ CRLF
	cQuery += " 									AND SN3.N3_SUBCTA = CTD_ITEM "+ CRLF
EndIf
If AF350Marc(aMarks[nPosCTH,6],"CTH") 
	cQuery += " 		INNER JOIN "+aMarks[nPosCTH,6]+" CTH ON CTH_OK <> ' ' "+ CRLF
	cQuery += " 									AND SN3.N3_CLVL = CTH_CLVL " + CRLF
EndIf
cQuery += " 	WHERE "+ CRLF
cQuery += " 		SN1.N1_DTBLOQ < '"+DtoS(dLastDate)+"' AND "+ CRLF
cQuery += " 		SN1.N1_PATRIM IN ('N','I','D','O','T') AND "+ CRLF
cQuery += "			SN1.N1_FILIAL BETWEEN '"+xFilial("SN1",cFilDe)+"' AND '"+xFilial("SN1",cFilAte)+"'  AND " + CRLF
cQuery += "			SN1.D_E_L_E_T_ = ' ' AND "  + CRLF
cQuery += "			SN3.D_E_L_E_T_ = ' '  "  + CRLF
cQuery += " ORDER BY N3RECNO "  + CRLF

Return cQuery

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA350ModTabบAutor  ณAlvaro Camillo Neto บ Data ณ  05/02/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza a grava็ใo dos bens modificadores                  บฑฑ
ฑฑบ          ณ de simula็ใo na tabela temporaria                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA350                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/    
Static Function A350ModTab(cTabMult,cCodigo,cRevisao,aDatasSimu,cBaseMod,nTpAtivo,cTpSaldo)
Local aArea		:= GetArea()
Local aAreaSNR	:= SNR->(GetArea())
Local nLastRec	:= 0
Local nMoeda		:= 0
Local cMoeda		:= ""
Local cItem		:= "0000"
Local nQtdPer		:= Len(aDatasSimu)
Local nPeriodo	:= 0
//********************************
// Controle de multiplas moedas  *
//********************************
Local __nQuantas  := If(lMultMoed,AtfMoedas(),5)
Local aValorOri	:= Array(__nQuantas)
Local nValorOri	:= 0

SNR->(dbSetOrder(1)) //NR_FILIAL+NR_CODIGO+NR_REVISAO+NR_ITEM
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณUltimo Recno da queryณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
(cTabMult)->(dbGoBottom())
nLastRec := (cTabMult)->N3RECNO 
(cTabMult)->(dbGoTop())

If SNR->(MsSeek( xFilial('SNR') + cCodigo + cRevisao )) 	
	While SNR->(!EOF()) .And. SNR->(NR_FILIAL+NR_CODIGO+NR_REVISAO) == xFilial('SNR') + cCodigo + cRevisao 
        
		Afill(aValorOri,0)	
  		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณGrava os Bens de Modificacao de Simulacaoณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	    For nPeriodo := 2 to nQtdPer // O primeiro periodo ้ o de saldos somente para bens reais 
		    If SNR->NR_ACMOD == INFORMAR .And. nPeriodo != SNR->NR_NPERIOD + 1  
		    	Loop
		    EndIf
		    
		    nLastRec++
		    cItem := Soma1(cItem)
		    RecLock(cTabMult,.T.)
			(cTabMult)->N3_FILIAL	:= SNR->NR_FILBEM
			(cTabMult)->N3_CBASE		:= cBaseMod
			(cTabMult)->N3_ITEM	   	:= cItem
		    If nTpAtivo == 1 // Bens Fiscais
				(cTabMult)->N3_TIPO	:= '01'
		    ElseIf nTpAtivo == 2 // Bens Gerenciais
				(cTabMult)->N3_TIPO	:= '10'
		    EndIf
		    
		    If cTpSaldo != "*"
				(cTabMult)->N3_TPSALDO := "1"
		    Else 
				(cTabMult)->N3_TPSALDO := cTpSaldo
		    EndIf
		    		    
			(cTabMult)->N3_BAIXA		:= IIF(SNR->NR_TPMOD == AQUISICAO, '0','1')
			(cTabMult)->N3_SEQ		:= '01'
			(cTabMult)->N3_SEQREAV	:= '  '
			(cTabMult)->N3_CCDEPR  	:= SNR->NR_CCDEPR
			(cTabMult)->N3_CCCDEP  	:= SNR->NR_CCCDEP
			(cTabMult)->N3_SUBCCDE 	:= SNR->NR_SUBCCDE
			(cTabMult)->N3_CLVL		:= SNR->NR_CLVLCDE
			(cTabMult)->N3_AQUISIC	:= aDatasSimu[nPeriodo]
			(cTabMult)->N3_DINDEPR	:= LastDay(aDatasSimu[nPeriodo])
			(cTabMult)->N1_PATRIM	:= 'N'
			(cTabMult)->N3_TPDEPR := SNR->NR_TPDEPR
			(cTabMult)->N3_VMXDEPR := SNR->NR_VMXDEPR
			(cTabMult)->N3_PERDEPR := SNR->NR_PERDEPR
			(cTabMult)->N3_VLSALV1 := SNR->NR_VLSALV1
			(cTabMult)->N3_PRODMES := SNR->NR_PRODMES
			(cTabMult)->N3_PRODANO := SNR->NR_PRODANO
			(cTabMult)->N3_CODIND := SNR->NR_CODIND
			(cTabMult)->N3RECNO		:= nLastRec
			(cTabMult)->N3FLAG		:= BEM_MODIFICACAO			    

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณCalcula os valoresณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			//********************************
			// Controle de multiplas moedas  *
			//********************************
		    For nMoeda := 1 to __nQuantas
		    	cMoeda := cValtoChar(nMoeda)
		    	
		    	If SNR->NR_ACMOD == DIVIDIR 
			    	nValorOri := Round(SNR->&(If(nMoeda>9,"NR_VLRMO","NR_VLRMOD") + cMoeda) / (nQtdPer - 1) , X3Decimal("N3_VORIG"+cMoeda) )
				Else
					nValorOri := SNR->&(If(nMoeda>9,"NR_VLRMO","NR_VLRMOD") + cMoeda) 
		    	EndIf
		    	
		    	// Caso seja baixa a cada mes o valor sera acumulado
		    	IF SNR->NR_TPMOD == BAIXA
		    		aValorOri[nMoeda] += nValorOri 
		    	Else
		    		aValorOri[nMoeda] := nValorOri
		    	EndIf 
		
		    Next nMoeda
			
			//ฺฤฤฤฤฤฤฤฟ
			//ณGrava os valoresณ
			//ภฤฤฤฤฤฤฤู 
			//********************************
			// Controle de multiplas moedas  *
			//********************************
		    For nMoeda := 1 to __nQuantas
		    	cMoeda := cValtoChar(nMoeda)	
		   		If nMoeda>9
			   		(cTabMult)->&("N3_VRDAC"	+ cMoeda) := 0	
			   		(cTabMult)->&("N3_VORIG" 	+ cMoeda) := aValorOri[nMoeda]
					(cTabMult)->&("N3_AMPLI"	+ cMoeda) := 0	
					(cTabMult)->&("N3_TXDEP"	+ cMoeda) := SNR->&("NR_TXDEP" + cMoeda)
		   		Else	   		
			   		(cTabMult)->&("N3_VRDACM"	+ cMoeda) := 0	
			   		(cTabMult)->&("N3_VORIG" 	+ cMoeda) := aValorOri[nMoeda]
					(cTabMult)->&("N3_AMPLIA"	+ cMoeda) := 0	
					(cTabMult)->&("N3_TXDEPR"	+ cMoeda) := SNR->&("NR_TXDEPR" + cMoeda)
				EndIf
		    Next nMoeda
		    
		    MsUnLock()
		    
	    Next nPeriodo
	    
		SNR->(dbSkip())
	End 
EndIf

RestArea(aAreaSNR)
RestArea(aArea)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF350Marc บAutor  ณAlvaro Camillo Neto บ Data ณ  16/12/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza a checagem da tabela temporaria gerada pela ADMXFUN บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA350                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF350Marc(cTabela,cAlias)
Local lRet := .T.
Local aArea:= GetArea()
Local cTab := AF350NextAlias()
Local cQuery := ""
Local cCampo := PrefixoCpo( cAlias )+"_OK"
If Select(cTab) > 0
	(cTab)->(dbCloseArea())
EndIf

cQuery += " SELECT COUNT(*) CONTOK "
cQuery += " FROM " +cTabela
cQuery += " WHERE "+ cCampo + " <> '' "
cQuery := ChangeQuery(cQuery)
 
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRealiza a queryณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Select(cTab) > 0
	(cTab)->(dbCloseArea())
EndIf
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cTab, .F., .T.)
lRet := !Empty((cTab)->CONTOK)
 
(cTab)->(dbCloseArea())

RestArea(aArea)
Return lRet 



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA350SSim  บAutor  ณAlvaro Camillo Neto บ Data ณ  02/02/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza o processamento da simula็ใo da deprecia็ใo         บฑฑ
ฑฑบ          ณEm uma thread (Single)                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA350                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A350SSim(cTab,aDatasSimu,cCodigo,cRevisao)
Local lRet 	   		:= .T.
Local aArea	   		:= GetArea()
Local nA	   		:= 0
Local aBases   		:= {}
Local aDeprec		:= {}
Local cChaveSN3		:= ""
Local lBemReal		:= .T.
Local aBens			:= {}
Local cTipoMov		:= ""
Local nIndSNS		:= 0

If fIndSNS(@nIndSNS)
	While (cTab)->(!Eof())
			If (cTab)->N3FLAG == BEM_REAL
				cChaveSN3 := (cTab)->(N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ)
				lBemReal := .T.
			Else
				lBemReal := .F.
				cChaveSN3:= ""	
			EndIf
			aBases  := Af350MonBas(cTab,cChaveSN3)
			aBens	:= Af350MonBem(cTab)

			Begin Transaction 
				For nA:= 1 to Len(aDatasSimu)
					If nA == 1 // 1 Periodo ้ o saldo atual
						If lBemReal 
							cTipoMov := '0'
							//********************************
							// Controle de multiplas moedas  *
							//********************************
							aDeprec  := If(lMultMoed,AtfMultMoe(,,{|x| 0}), {0,0,0,0,0} )
						Else
							Loop
						EndIf
					Else
						aDeprec := AF350Calc(cChaveSN3,aDatasSimu[nA],aBases,aBens,lBemReal)
						cTipoMov:= IIF(lBemReal,'1','2')
					EndIf
					
					If Empty(aDeprec)
						//********************************
						// Controle de multiplas moedas  *
						//********************************
						aDeprec  := If(lMultMoed,AtfMultMoe(,,{|x| 0}), {0,0,0,0,0} )
					EndIf
					AF350GrvSNS(aDatasSimu[nA],@aBases ,aDeprec ,cCodigo ,cRevisao ,cTipoMov ,aBens,lBemReal,(cTab)->N3_TPSALDO,nIndSNS)
				Next nA
			End Transaction	
		(cTab)->(dbSkip())
	End
Else
	Help(,,"SEMINDSNS",,STR0142,1,0,,,,,,{STR0143})
	lRet := .F.
EndIf

RestArea(aArea)
Return lRet


Static Function fIndSNS(nIndSNS)

Local lRet  	:= .F.
Local aASIX		:= SIX->(GetArea())
Local cAliasSNS := 'SNS'

DbSelectArea("SIX")
SIX->(DbSetOrder(1))
SIX->(Dbseek(cAliasSNS))

While !SIX->(Eof()) .And. SIX->INDICE == cAliasSNS
	If Alltrim(SIX->CHAVE) == "NS_FILIAL+NS_CODIGO+NS_REVISAO+DTOS(NS_DATA)+NS_TPMOV+NS_CBASE+NS_ITEM+NS_TIPO+NS_SEQ"
		lRet := .T.
		nIndSNS := Val(SIX->ORDEM)
		Exit
	EndIf

	SIX->(dbSkip())
EndDo

SIX->(RestArea(aASIX))

Return lRet

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณAf050MonBas ณ Autor ณ Claudio D. de Souza   ณ Data ณ 16/02/04 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Monta as bases para calculo de depreciacao de itens baixados ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ ATFA050                                                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Af350MonBas(cAlias,cChaveSN3)
Local aArea		:= GetArea()
Local aBases 	:= {}
Local nPercBaix	:= 0
Local nX		:= 0
Local aAux		:= {}
//********************************
// Controle de multiplas moedas  *
//********************************
Local __nQuantas := If(lMultMoed,AtfMoedas(),5)

nPercBaix := GetAdvFval("SN3","N3_PERCBAI",cChaveSN3, 3 )

nPercBaix := IIF(!Empty(nPercBaix) ,nPercBaix, 1 )
//********************************
// Controle de multiplas moedas  *
//********************************
For nX := 1 To __nQuantas
	aAux := Array(6)
	aAux[DEPRECIACAO_ACUMULADA] 	:= (cAlias)->&(If(nX>9,"N3_VRDAC","N3_VRDACM")+cValToChar(nX))/nPercBaix 
	aAux[CORRECAO_DA_DEPRECIACAO] 	:= 0
	aAux[VALOR_ORIGINAL] 			:= (cAlias)->&("N3_VORIG"+cValToChar(nX))/nPercBaix	 
	aAux[CORRECAO_ACUMULADA] 		:= 0 
	aAux[VALOR_DA_AMPLIACAO] 		:= (cAlias)->&(If(nX>9,"N3_AMPLI","N3_AMPLIA")+cValToChar(nX))/nPercBaix 
	aAux[TAXA_DE_DEPRECIACAO] 		:= (cAlias)->&(If(nX>9,"N3_TXDEP","N3_TXDEPR")+cValToChar(nX))
    aAdd(aBases,aAux)
    aAux := {}
Next nX


RestArea(aArea)
Return aBases

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAf350MonBemบAutor ณMicrosiga           บ Data ณ  02/05/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta o vetor com as informa็๕es cadastrais do Bem          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA350                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Af350MonBem(cAlias)
Local aBens := Array(22)
Local aArea := GetArea()

aBens[BEM_FILIAL]	:=(cAlias)->N3_FILIAL
aBens[BEM_BASE]		:=(cAlias)->N3_CBASE
aBens[BEM_ITEM]		:=(cAlias)->N3_ITEM
aBens[BEM_TIPO]		:=(cAlias)->N3_TIPO
aBens[BEM_SEQ]		:=(cAlias)->N3_SEQ	
aBens[BEM_SEQREAV]	:=(cAlias)->N3_SEQREAV
aBens[BEM_CCDEPR]	:=(cAlias)->N3_CCDEPR
aBens[BEM_CCCDEP]	:=(cAlias)->N3_CCCDEP
aBens[BEM_SUBCCDE]	:=(cAlias)->N3_SUBCCDE
aBens[BEM_CLVL]		:=(cAlias)->N3_CLVL
aBens[BEM_AQUISIC]	:=(cAlias)->N3_AQUISIC
aBens[BEM_DINDEPR]	:=(cAlias)->N3_DINDEPR
aBens[BEM_PATRIM]	:=(cAlias)->N1_PATRIM
aBens[BEM_BAIXA]	:=(cAlias)->N3_BAIXA
aBens[BEM_TPDEPR]	:=(cAlias)->N3_TPDEPR
aBens[BEM_VMXDEPR]	:=(cAlias)->N3_VMXDEPR
aBens[BEM_PERDEPR]	:=(cAlias)->N3_PERDEPR
aBens[BEM_VLSALV1]	:=(cAlias)->N3_VLSALV1
aBens[BEM_PRODMES]	:=(cAlias)->N3_PRODMES
aBens[BEM_PRODANO]	:=(cAlias)->N3_PRODANO
aBens[BEM_CODIND]	:=(cAlias)->N3_CODIND
aBens[BEM_TPSALDO]	:=(cAlias)->N3_TPSALDO

RestArea(aArea)
Return aBens


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF350GrvSNSบAutor ณAlvaro Camillo Neto บ Data ณ  30/01/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza a grava็ใo da tabela de movimenta็ใo SNS que simula บฑฑ
ฑฑบ          ณas movimenta็๕s da SN4                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF350GrvSNS(dSimulacao,aBases,aDeprec ,cCodigo ,cRevisao ,cTipoMov ,aBens,lBemReal,cTpSaldo,nIndSNS) 
Local aArea 	:= GetArea()
Local lGrava	:= .T.
Local cOcorr	:= ""
Local nMoeda	:= 0 
Local cIdMov	:= ""
Local cMoeda	:= ""
Local nValorMov	:= 0
Local cTipoGer := ATFXTpBem(2)
//********************************
// Controle de multiplas moedas  *
//********************************
Local __nQuantas := If(lMultMoed,AtfMoedas(),5)

Default cTipoMov := '1'
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณOrdena็ใo das tabelas envolvidasณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
SNS->(dbSetOrder(nIndSNS))

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRealiza a soma nas depeciacoes acumuladas do aBase ณ
//ณpara o calculo da p๓rxima simula็ใo                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

//********************************
// Controle de multiplas moedas  *
//********************************
For nMoeda := 1 to __nQuantas
	aBases[nMoeda][DEPRECIACAO_ACUMULADA] += aDeprec[nMoeda] 
Next nMoeda
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณEscolhe o tipo de movimenta็ใoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Do Case
	Case aBens[BEM_TIPO] == "07"
		cOcorr := "10"
	Case aBens[BEM_TIPO] == "08"
		cOcorr := "12"
	Case aBens[BEM_TIPO] == "09"
		cOcorr := "11"
	Case Alltrim(aBens[BEM_TIPO]) $ Alltrim(cTipoGer)
		cOcorr := "20" // Deprecia็ใo Gerencial
	OtherWise
		cOcorr := "06" 
EndCase

If aBens[BEM_BAIXA] == '1'
	cOcorr := "05" 
EndIf                  
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se atualiza ou grava um novo registroณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
lGrava := !(SNS->(MsSeek( SN3->N3_FILIAL + cCodigo + cRevisao + dToS(dSimulacao) + cTipoMov + aBens[BEM_BASE] + aBens[BEM_ITEM] +aBens[BEM_TIPO] + aBens[BEM_SEQ] )) )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSeleciona o Identificador do movimentoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lGrava
	cIdMov := GetSxENum("SNS", "NS_IDMOVTO",,1)
Else
	cIdMov := SNS->NS_IDMOVTO 
EndIf
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Inicia lancamento no PCO                                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
PcoIniLan("000374") 
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRealiza a grava็ใo do Movimentoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RecLock("SNS" , lGrava)
	SNS->NS_FILIAL	:= aBens[BEM_FILIAL]
	SNS->NS_CODIGO	:= cCodigo 
	SNS->NS_REVISAO	:= cRevisao 
	SNS->NS_IDMOVTO	:= cIdMov
	SNS->NS_DATA		:= dSimulacao    
	SNS->NS_TPMOV		:= cTipoMov  
	SNS->NS_CBASE		:= aBens[BEM_BASE]  
	SNS->NS_ITEM		:= aBens[BEM_ITEM]  
	SNS->NS_TIPO		:= aBens[BEM_TIPO]   
	SNS->NS_SEQ		:= aBens[BEM_SEQ]   
	SNS->NS_SEQREAV	:= aBens[BEM_SEQREAV] 
	SNS->NS_OCORR		:= cOcorr  
	SNS->NS_TIPOCNT	:= "4"
	SNS->NS_CONTA		:= aBens[BEM_CCDEPR]  
	SNS->NS_CCUSTO	:= aBens[BEM_CCCDEP] 
	SNS->NS_SUBCTA	:= aBens[BEM_SUBCCDE]
	SNS->NS_CLVL		:= aBens[BEM_CLVL]
	SNS->NS_TPSALDO	:= cTpSaldo
	SNS->NS_TPDEPR	:= aBens[BEM_TPDEPR]
	
	//********************************
	// Controle de multiplas moedas  *
	//********************************
	For nMoeda := 1 to __nQuantas
		cMoeda 		:= cValtoChar(nMoeda)
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤmฟ
		//ณCaso seja o mes da baixa do bem   ณ
		//ณmodificador o movimento ้ negativoณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤmู		
		If !lBemReal .And. aBens[BEM_BAIXA] == '1'
			If aBens[BEM_AQUISIC] == dSimulacao 
				nValorMov   := aBases[nMoeda][VALOR_ORIGINAL] * (-1) 
		    Else
		    	nValorMov   := 0
		    EndIf
		Else
			nValorMov   := aDeprec[nMoeda] 
		EndIf
		
		If nMoeda>9
			SNS->&("NS_TXDEP" + cMoeda ) := aBases[nMoeda][TAXA_DE_DEPRECIACAO]
			SNS->&("NS_VLRBA" + cMoeda ) := aBases[nMoeda][VALOR_ORIGINAL] 
			SNS->&("NS_VLRAC" + cMoeda ) := aBases[nMoeda][DEPRECIACAO_ACUMULADA] 
			SNS->&("NS_VLRMO" + cMoeda ) := nValorMov 
		Else
			SNS->&("NS_TXDEPR" + cMoeda ) := aBases[nMoeda][TAXA_DE_DEPRECIACAO]
			SNS->&("NS_VLRBAS" + cMoeda ) := aBases[nMoeda][VALOR_ORIGINAL] 
			SNS->&("NS_VLRACM" + cMoeda ) := aBases[nMoeda][DEPRECIACAO_ACUMULADA] 
			SNS->&("NS_VLRMOV" + cMoeda ) := nValorMov 
		EndIf
	Next nMoeda	
MsUnlock()
ConfirmSX8()
If SNS->NS_TPMOV == '2' .AND. SNS->NS_OCORR == "06"      	// <MODIFICADOR DE AQUISICAO>
	PcoDetLan("000374","02","ATFA350")
ElseIf SNS->NS_TPMOV == '2' .AND. SNS->NS_OCORR == "05"  	// <MODIFICADOR DE BAIXA>
	PcoDetLan("000374","03","ATFA350")
Else // Movimento de Bem Real
	PcoDetLan("000374","01","ATFA350")
EndIf                       

PcoFinLan("000374")

RestArea(aArea)
Return


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCalculo da Deprecia็ใoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF350Calc บAutor  ณAlvaro Camillo Neto บ Data ณ  28/01/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCalculo da deprecia็ใo de um bem em um dado periodo         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA350                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF350Calc(cChaveSN3,dSimulacao,aBases,aBens,lBemReal)
Local aDepre	:= {}
Local cMoedaAtf := GetMV( "MV_ATFMOEDA" ) 
Local lAtfa350 	:= ExistBlock("AF050CAL")
Local aArea 	:= GetArea()
Local aDepreBai	:= {}
Local aAreaSN3  := SN3->(GetArea())
Local aAreaSN4  := SN4->(GetArea())
Local nI		:= 0
Local lRet := .T.
//ฺฤฤฤฤฤฤฤฤฤฤฟ
//ณParametrosณ
//ภฤฤฤฤฤฤฤฤฤฤู
Default dSimulacao 	:= dDataBase
Default aBases 		:= {}
Default lBemReal 	:= .T.
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณOrdena็ใo das tabelas envolvidasณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
SN3->(dbSetOrder(1))	//N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ
SN4->(dbSetOrder(1))	//N4_FILIAL+N4_CBASE+N4_ITEM+N4_TIPO+N4_DATA+N4_OCORR+N4_SEQ

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe o bem for real irแ buscar no SN3 as informa็๕es pertinentesณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lBemReal 
	SN3->(MsSeek(cChaveSN3))
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณValida se o bem jแ foi baixadoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lBemReal 
	If lRet .And. Val(SN3->N3_BAIXA) != 0  .AND. (Month(SN3->N3_DTBAIXA) < Month(dSimulacao)) .and. (Year(SN3->N3_DTBAIXA) <= Year(dSimulacao) )
		//********************************
		// Controle de multiplas moedas  *
		//********************************
		aDepre  := If(lMultMoed,AtfMultMoe(,,{|x| 0}), {0,0,0,0,0} )
	EndIf
Else
	If aBens[BEM_BAIXA] == '1'
		//********************************
		// Controle de multiplas moedas  *
		//********************************
		aDepre  := If(lMultMoed,AtfMultMoe(,,{|x| 0}), {0,0,0,0,0} )
	EndIf
EndIf

If lRet .And. Empty(aDepre) 
	If lBemReal .And. Val(SN3->N3_BAIXA) != 0 // Item Baixado e real
		// Calcula a depreciacao para itens baixados, apenas uma vez.
		If SN3->N3_NOVO == "1" // Item gerado pela baixa do ATFA035
			// Encontra a baixa no SN4, para encontrar a proporcao baixada e efetuar o calculo
			// da depreciacao da baixa.
			SN4->(MsSeek(xFilial("SN4")+SN3->(N3_CBASE+N3_ITEM+N3_TIPO+DTOS(N3_DTBAIXA)+"01"+N3_SEQ)))
			aDepreBai := CalcDepre(	SN3->N3_DTBAIXA,;
										SN3->N3_DTBAIXA,;
										SN3->N3_DINDEPR,;
										SN3->N3_TIPO   ,;
										aBases			,;
										cMoedaAtf		,;
										SN4->N4_QUANTD	,; // Qtde. Baixada
										SN3->N3_QUANTD	,; // Qtde. Original na data da baixa
										.F.			,;
										0 		,;
										cPatrim)
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณAdequa็ใo do vetor, retirando os valores de corre็ใo monetแriaณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			For nI := 1 to Len(aDepreBai[1])
				aAdd(aDepre,aDepreBai[1][nI])
			Next nI
		Endif
	Else
		 aDepre := A50CalBem(cChaveSN3,dSimulacao,aBases,lBemReal,aBens) 
	EndIf
	
	If lAtfa350
		Execblock("AF350CAL",.F.,.F.)
	Endif
EndIf
	

RestArea(aAreaSN4)
RestArea(aAreaSN3)
RestArea(aArea)
Return aDepre

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA50CalBem บAutor  ณAlvaro Camillo Neto บ Data ณ  28/01/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza o calculo da depreciacao de um Bem comum            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA350                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A50CalBem(cChaveSN3,dSimulacao,aBases,lBemReal,aBens)
Local aDepre	:= {}
Local aTaxaMes  := {} 
Local nMesCalc	:= 0
Local aArea		:= GetArea()
Local aAreaSN3	:= SN3->(GetArea())
Local dBloqueio

Default lBemReal := .T.

If lBemReal 
	SN3->(dbSetorder(1))
	SN3->(MsSeek(cChaveSN3))
	AtfBloqueio(SN3->(N3_CBASE + N3_ITEM), @(dBloqueio := Ctod("")))
Else
	dBloqueio := Ctod("")
EndIf

If ! Empty(dBloqueio) .And. Left(Dtos(dBloqueio), 6) > Left(Dtos(dSimulacao), 6)
	//********************************
	// Controle de multiplas moedas  *
	//********************************
	aDepre  := If(lMultMoed,AtfMultMoe(,,{|x| 0}), {0,0,0,0,0} )
Endif

If cPaisLoc == "ARG" .And. Alltrim(str(Year(dSimulacao)))+Alltrim(Strzero(Month(dSimulacao),2)) >=;
					 Alltrim(str(Year(aBens[BEM_AQUISIC])))+Alltrim(Strzero(Month(aBens[BEM_AQUISIC]),2))					 
 	nMesCalc := A350MesArg(aBases[ 1 ][TAXA_DE_DEPRECIACAO],dSimulacao,aBens[BEM_DINDEPR])
EndIf

If cPaisLoc = 'ARG' .and. nMesCalc <= 0
	//********************************
	// Controle de multiplas moedas  *
	//********************************
	aDepre  := If(lMultMoed,AtfMultMoe(,,{|x| 0}), {0,0,0,0,0} )
Endif

If Empty(aDepre) 
	aTaxaMes := A350TxMensal(cChaveSN3,aBases,dSimulacao,dBloqueio,lBemReal,aBens[BEM_DINDEPR],aBens)
	aDepre := A350DepMensal(cChaveSN3,dSimulacao,aTaxaMes,nMesCalc,aBases,lBemReal,aBens[BEM_DINDEPR],aBens)
EndIf
	
RestArea(aAreaSN3)
RestArea(aArea)

Return aDepre

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA350MesArgบAutor  ณAlvaro Camillo Neto บ Data ณ  28/01/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCalcula o O nro de meses em que o Ativo est'a sendo depreciadoบฑฑ
ฑฑบ          ณpara a regra argentina                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA350                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A350MesArg(nTxDeprec1,dDataAtual,dInDepr)
Local nMesCalc
Local dDataAux
Local nAnoAux
Local nNroMeses
   
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ nNroMeses -> nro Total de meses em que o Ativo ser'a depreicado    ณ
//ณ nMesCalc  -> O nro de meses em que o Ativo est'a sendo depreciado  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nNroMeses := Int((100/nTxDeprec1)) * 12
nNroMeses := nNroMeses + Mod(100,nTxDeprec1)
   
dDataAux := SubStr(Dtos(dInDepr), 1, 6)
nMesCalc := 0
While (dDataAux <= Substr(Dtos(dDataAtual), 1, 6) )
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Ano de inicio de depreciacao e o mesmo que ano da database         ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	nMesCalc := nMesCalc + 1
	nMesAux  := If( Val(Substr(dDataAux, 5, 2)) = 12, 0, Val(Substr(dDataAux, 5, 2)) )
	nAnoAux  := If( Val(Substr(dDataAux, 5, 2)) = 12, Val(Substr(dDataAux, 1, 4)) + 1, Val(Substr(dDataAux, 1, 4)))
	dDataAux := StrZero(nAnoAux,4)+StrZero(nMesAux+1,2)
EndDo
nMesCalc := nNroMeses - nMesCalc + 1
 	
Return nMesCalc

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA350TxMensalบAutorณAlvaro Camillo Neto บ Data ณ  29/01/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCalculo da Taxa Mensal do bem                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA350                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A350TxMensal(cChaveSN3,aBases,dAtual,dBloqueio,lBemReal,dIndep,aBem)
Local aTaxaMes		:= {}
Local aArea			:= GetArea()
Local aAreaSN3		:= SN3->(GetArea())
Local nDiasParcial	:= 0
Local nI				:= 0
Local lMesCheio		:= SuperGetMv("MV_TIPDEPR",,"0") == "1" // Mes Cheio
Local cConsab			:= ""
Local cCalcDep		:= GETMV("MV_CALCDEP",.T.,'0') // Determina a forma de calculo da deprecia็ใo 0 = Mensal ou 1 = Anual
Local nContTaxa		:= 0
Local nTaxa			:= 0
Local nFator			:= 0
Local nTaxaMes		:= 0
Local nFatorMes		:= 0

Default lBemReal	:= .T.

SN3->(dbSetOrder(1)) // Filial + C๓digo Base + Item + Tipo + Baixa + Sequ๊ncia  

If lBemReal
	SN3->(MsSeek(cChaveSN3))
EndIf

If lBemReal 
	cConsab := GetAdvFVal("SN1","N1_CONSAB",SN3->(N3_FILIAL+N3_CBASE+N3_ITEM),1)
Else
	cConsab := '1'
EndIf 

If cPaisLoc == "ARG"
	If cConsab == '1'
		lMesCheio := .T.
	EndIf
EndIf

For nI := 1 to Len(aBases)
	AADD(aTaxaMes,aBases[nI][TAXA_DE_DEPRECIACAO])
Next nI

/*
 * Defini็ใo das taxas de depreci็ใo de acordo com o m้todo de deprecia็ใo escolhido na simula็ใo
 */
If aBem[BEM_TPDEPR] 		== "2"	// M้todo de Deprecia็ใo Redu็ใo de Saldos
	ATFCalcRS(aBem[BEM_VLSALV1], aBases[1][VALOR_ORIGINAL], aBem[BEM_PERDEPR], aBases[1][DEPRECIACAO_ACUMULADA], @aTaxaMes)
ElseIf aBem[BEM_TPDEPR] $ "4|5"	// M้todo de Deprecia็ใo Unidades Produzidas e Horas Trabalhadas
	ATFCalcVR(aBem[BEM_PRODMES],aBem[BEM_PRODANO], @aTaxaMes)
ElseIf aBem[BEM_TPDEPR] 	== "6"	// M้todo de Deprecia็ใo Soma dos Dํgitos
	ATFCalcSD(dAtual, dIndep, aBem[BEM_PERDEPR], cCalcDep, @aTaxaMes)
ElseIf aBem[BEM_TPDEPR] 	== "A"	// M้todo de Deprecia็ใo por อndice
	ATFCalcIn(@aTaxaMes,aBem[BEM_CODIND] , dAtual )
ElseIf aBem[BEM_TPDEPR] 	$ "1|7 "// M้todo de Deprecia็ใo Linear e M้todo Linear com Valor Mแximo
	ATFCalcQC(cCalcDep, @aTaxaMes)
EndIf

If cPaisLoc <> "ARG"
	For nContTaxa := 1 to Len(aTaxaMes)
		nTaxa := aTaxaMes[nContTaxa]
	
		If cCalcDep == '0' // Mensal
			If aBem[BEM_TPDEPR] == "0" .And. MesAnoAtf(dIndep) == MesAnoAtf(dAtual) .And. !lMesCheio
				nFator := ( LastDay(dAtual) - dIndep + 1 ) / Day(LastDay(dAtual))
			Else
				nFator := 1
			EndIf
			aTaxaMes[nContTaxa] :=  nTaxa * nFator
		ElseIf cCalcDep == '1' // Anual
			nTaxaMes := nTaxa / 12
			If Year(dIndep) == Year(dAtual) .And. !lMesCheio
				nFatorMes	:= IIf( aBem[BEM_TPDEPR] $ "4|5", 1, ( LastDay(dIndep) - dIndep + 1 ) / Day(LastDay(dIndep)) )
				nFator 	:= ( Month(dAtual) - Month(dIndep) ) / 12
			Else
				nFatorMes	:= 0
				nFator		:= 1
			EndIf
			aTaxaMes[nContTaxa] := (nTaxa * nFator) + (nTaxaMes * nFatorMes)
		EndIf
	Next nContTaxa
Else 
	If MESANOAtf(dIndep) == MesAnoAtf(dAtual) .and. Day(dIndep) > 1 .And. !lMesCheio
		If cConsab == "1"
			nDiasParcial := (LastDay(dAtual) - FirstDay(dAtual)) + 1
		Else
			nDiasParcial := Day(LastDay(dAtual)) - Day(dIndep) + 1
		EndIf	
		For ni := 1 to 5
			aTaxaMes[ni] := aTaxaMes[ni] * ( nDiasParcial /  Day(LastDay(dAtual)) )
		Next ni
	Endif
EndIf	

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica se o campo N3_DEPREC esta' ou nao em uso. Se estiver, significa  ณ
//ณ que deve-se usar o calculo da depreciacao do tipo "Safra Fundada", da     ณ
//ณ Usina Cerradinho.                                                         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If  lBemReal .and. !Empty( SN3->N3_DEPREC ) 
	aTaxaMes[1] := ( CalcTaxa( SN3->N3_DEPREC ) / 12) / 100
	aTaxaMes[2] := aTaxaMes[1]
	aTaxaMes[3] := aTaxaMes[1]
	aTaxaMes[4] := aTaxaMes[1]
	aTaxaMes[5] := aTaxaMes[1]
Endif

RestArea(aAreaSN3)
RestArea(aArea)
Return aTaxaMes

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA350DepMensalบAutorณAlvaro Camillo Netoบ Data ณ  29/01/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCalcula a deprecia็ใo mensal do bem                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA350                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A350DepMensal(cChaveSN3,dAtual,aTaxaMes,nMesCalc,aBases,lBemReal,dIndep,aBem)
Local aDeprec  		:= Array(Len(aTaxaMes))
Local nDiferenca 	:= 0
Local nDeprAcum		:= 0
Local aArea			:= GetArea()
Local aAreaSN3		:= SN3->(GetArea())
Local nMoeda		:= 0 
Local cMoeda		:= ""
Local nAceleracao	:= 0
Local nBaseCalc		:= 0
Local lIndCalc		:= .F. // อndice de deprecia็ใo informado
Local nMoedaVMax	:= Iif(Val(GetMv("MV_ATFMDMX",.F.," "))>0, Val(GetMv("MV_ATFMDMX")), Val(cMoedaAtf))
Local nVlrOriSal    := 0

Default nMesCalc	:= 0 
Default lBemReal	:= .T.
Default cChaveSN3	:= ""
Default aBem		:= {}


SN3->(dbSetOrder(1)) // Filial + C๓digo Base + Item + Baixa + Sequ๊ncia

If lBemReal
	SN3->(MSSeek(cChaveSN3))  
EndIf 

/*
 * Verifica็ใo se o m้todo de deprecia็ใo ้ por ํndice, entใo efetuar a busca da informa็ใo se o ํndice de deprecia็ใo ้ informado ou calculado
 */
If aBem[BEM_TPDEPR] == "A"
	DbSelectArea("FNI")
	FNI->(DbSetOrder(1))
	If FNI->(DbSeek(XFILIAL("FNI") + aBem[BEM_CODIND] ))
		lIndCalc := FNI->FNI_TIPO == "2" // อndice de deprecia็ใo calculado
	EndIf
	RestArea(aAreaSN3)
EndIf

//Encontra a Propor็ใo para calculo do M้todo de Deprecia็ใo de Linear com Valor Mแximo de Deprecia็ใo
If aBem[BEM_TPDEPR] == "7"	
	nPropDepr := aBem[BEM_VMXDEPR] / ( aBases[nMoedaVMax][VALOR_ORIGINAL] + aBases[nMoedaVMax][VALOR_DA_AMPLIACAO] ) 
ElseIf aBem[BEM_TPDEPR] == "2" 
	nPropDepr := aBem[BEM_VLSALV1] / (aBases[1][VALOR_ORIGINAL] + aBases[1][VALOR_DA_AMPLIACAO])
EndIf

If dIndep <= dAtual
	For nMoeda := 1 to Len(aTaxaMes)
	    cMoeda := cValtoChar(nMoeda)
		If !Empty(aTaxaMes[ nMoeda ])
			nAceleracao	:= IIF(lBemReal,GetSldAcel(cMoeda), 0)
			nDeprAcum 		:= ( aBases[nMoeda][DEPRECIACAO_ACUMULADA] + nAceleracao  )
			If Abs( nDeprAcum ) < Abs(aBases[nMoeda][VALOR_ORIGINAL]) + aBases[nMoeda][VALOR_DA_AMPLIACAO]
				/*
				 * Tratamento de Base de Cแlculo de acordo com m้todo de deprecia็ใo utilizado
				 */
				If aBem[BEM_TPDEPR] == "2"		// M้todo de Deprecia็ใo de Redu็ใo de Saldos
					nBaseCalc := Abs(aBases[nMoeda][VALOR_ORIGINAL] - aBases[nMoeda][DEPRECIACAO_ACUMULADA])
					nVlrOriSal := aBases[nMoeda][VALOR_ORIGINAL]  - ( aBases[nMoeda][VALOR_ORIGINAL]  * nPropDepr )
				ElseIf aBem[BEM_TPDEPR] == "7"	// M้todo de Deprecia็ใo de Linear com Valor Mแximo de Deprecia็ใo
					nBaseCalc := aBases[nMoeda][VALOR_ORIGINAL] * nPropDepr
				ElseIf aBem[BEM_TPDEPR] == "A"	// M้todo de Deprecia็ใo por อndice
					nBaseCalc := aBases[nMoeda][VALOR_ORIGINAL] 
					nVlrOriSal := aBases[nMoeda][VALOR_ORIGINAL] 
					If lIndCalc // Se for อndice de deprecia็ใo calculado
						nBaseCalc -= aBases[nMoeda][DEPRECIACAO_ACUMULADA]
					EndIf						
				Else
					nBaseCalc := aBases[nMoeda][VALOR_ORIGINAL]
				EndIf
				
				aDeprec[nMoeda]  := Round( ( nBaseCalc + aBases[nMoeda][VALOR_DA_AMPLIACAO] ) * aTaxaMes[ nMoeda ], X3Decimal("N3_VORIG"+cMoeda)) 		
				
				// Verifica se o valor da cota eh maior do que o valor residual.
				If aBem[BEM_TPDEPR] == "2"
					nDiferenca := Abs(nVlrOriSal) - (Abs(aDeprec[nMoeda]) + Abs(aBases[nMoeda][DEPRECIACAO_ACUMULADA]+ aBases[nMoeda][CORRECAO_DA_DEPRECIACAO]))
				ElseIf lIndCalc
					nDiferenca := Abs(nVlrOriSal) - (Abs(aDeprec[nMoeda]) + Abs(aBases[nMoeda][DEPRECIACAO_ACUMULADA]+ aBases[nMoeda][CORRECAO_DA_DEPRECIACAO]))
				Else
					nDiferenca := Abs(nBaseCalc) - (Abs(aDeprec[nMoeda]) + Abs(aBases[nMoeda][DEPRECIACAO_ACUMULADA]+ aBases[nMoeda][CORRECAO_DA_DEPRECIACAO]))
				EndIf

				If aBem[BEM_TPDEPR] == "7"
					nCusto	:=  aBases[nMoeda][VALOR_ORIGINAL] * nPropDepr
				Else
					nCusto	:= aBases[nMoeda][VALOR_ORIGINAL]+aBases[nMoeda][CORRECAO_ACUMULADA]+aBases[nMoeda][VALOR_DA_AMPLIACAO]
				Endif

				// Residuo inferior a 1 (uma) unidade monetaria sera adicionado a cota atual.
				If lIndCalc .And. Round( nDiferenca, X3Decimal("N3_VORIG"+cMoeda) ) <= 0.99 
					aDeprec[nMoeda] := nVlrOriSal - aBases[nMoeda][DEPRECIACAO_ACUMULADA] + aBases[1][CORRECAO_DA_DEPRECIACAO]
				ElseIf aBem[BEM_TPDEPR] != "2" .And. Round( nDiferenca, X3Decimal("N3_VORIG"+cMoeda) ) <= 0.99
					aDeprec[nMoeda]:= nCusto - aBases[nMoeda][DEPRECIACAO_ACUMULADA] + aBases[1][CORRECAO_DA_DEPRECIACAO]
				ElseIf aBem[BEM_TPDEPR] == "2" .And. Round( nDiferenca, X3Decimal("N3_VORIG"+cMoeda) ) <= 0.99
					aDeprec[nMoeda] := nVlrOriSal - aBases[nMoeda][DEPRECIACAO_ACUMULADA] + aBases[1][CORRECAO_DA_DEPRECIACAO]
				Endif
			Else
				aDeprec[nMoeda]  := 0 	
			Endif
		Else
			aDeprec[nMoeda]  := 0 
		Endif					
	Next nMoeda

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณTratamento especifico para Argentinaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If cPaisLoc == 'ARG'
		If Abs(aBases[1][DEPRECIACAO_ACUMULADA] ) < Abs( aBases[1][VALOR_ORIGINAL]+ aBases[1][VALOR_DA_AMPLIACAO] )
			aDeprec[1]  := Round(aBases[1][VALOR_ORIGINAL]+ aBases[1][VALOR_DA_AMPLIACAO] * aTaxaMes[ 1 ], X3Decimal("N3_VORIG1"))
			nDiferenca := Abs( aBases[1][VALOR_ORIGINAL] + aBases[1][VALOR_DA_AMPLIACAO] ) - (aDeprec[1] + Abs( aBases[1][DEPRECIACAO_ACUMULADA] ) )
			If nMesCalc == 1
				aDeprec[1]  := Abs( aBases[1][VALOR_ORIGINAL]+ aBases[1][VALOR_DA_AMPLIACAO] )-Abs( aBases[1][DEPRECIACAO_ACUMULADA] )
			Endif
		EndIf
	EndIf
	

	// Verifico se existem os campos que controlam depreciacao acelerada
	If lBemReal
		// Verifica se a deprecia็ใo acelerada foi calculada dentro do mes, pois depreciacoes aceleradas
		// de outros meses ja foi subtraida.
		If Left(DTOS(SN3->N3_DTACELE),6) == Left(DTOS(dAtual),6)
			For nMoeda := 1 to 5
				// Subtrai o valor da deprecia็ใo acelerada, para nใo duplicar a deprecia็ใo do bem.
				aDeprec[nMoeda] := aDeprec[nMoeda] * (((dAtual - SN3->N3_DTACELE)) / Day(dAtual)) 
				// Ajusta para depreciacao nao ficar negativa em virtude da depreciacao acelerada ser
				// maior que a depreciacao do mes.
				aDeprec[nMoeda] := Max(aDeprec[nMoeda] ,0)
			Next nMoeda
		Endif
	EndIf	
Else
	aFill(aDeprec,0)	
Endif

RestArea(aAreaSN3) 
RestArea(aArea)
Return aDeprec


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFun็๕es da Contabiliza็ใoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA350OffCtbบAutor  ณAlvaro Camillo Neto บ Data ณ  11/02/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Contabiliza็ใo OffLine dos movimentos de simula็ใo de      บฑฑ
ฑฑบ          ณ deprecia็ใo                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA350                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A350OffCtb()
Local nOpcA 	:= 0
Local cPerg 	:= "AF350C"
Local cArqPar	:= ""
 
Private cCadastro 	:= STR0093 //"Contabiliza็ใo de Simula็ใo Depreciacao"
Private aSay 		:= {}
Private aButton 	:= {}
Private oProcess  	:= Nil

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ[ฟ
//ณVerifica se o usuario concorda que o lan็amento aglutinadoณ
//ณquebre em n documentos por causa do processamento         ณ
//ณmultithread                                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ[ู
If !Af350VlAgl()
	Return()
EndIf

cArqPar := Sv020Mem()		//funcao do ctba020, salva os valores atuais dos parametros MV_PAR??

Pergunte(cPerg,.F.)

aAdd( aSay, STR0094 )// "Esta rotina tem como objetivo a contabilizacao" 
aAdd( aSay, STR0095 )// "dos movimentos de simula็ใo de deprecia็ใo " 
aAdd( aSay, STR0096 )// "gerados pela rotina" 


aAdd( aButton, { 5,.T.,{|| Pergunte(cPerg,.T.)}})
aAdd( aButton, { 1,.T.,{|| nOpca := 1 ,FechaBatch()}})
aAdd( aButton, { 2,.T.,{|| FechaBatch() }} )

FormBatch( cCadastro, aSay, aButton )

If nOpcA == 1 
	MsgRun( STR0038,STR0038, {|| AF350MCtb( MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04,MV_PAR05 == 1 ) } )
Endif

Sv020Mem(cArqPar)		//restaura os valores atuais dos parametros MV_PAR??
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF350MCtb บAutor  ณAlvaro Camillo Neto บ Data ณ  09/02/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo responsavel pela contabiliza็ใo dos movimentos       บฑฑ
ฑฑบ          ณda simula็ใo multi thread (MULTI)                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA350                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF350MCtb(cCodDe,cRevDe,cCodAte,cRevAte,lAglutina,lNormal)
Local cQuery	 := ""
Local aStrutSNS	 := {}
Local nX	 	:= 0
Local aProcs 	:= {}                                          
Local cDirSem   := "\Semaforo\"
Local cRaizNome	:= 'ATFA350Ctb'
Local cNomeArq	:= ""
Local cMarca	:= ""
Local aArea		:= GetArea()
Local nTotalReg	:= 0 // Total de Registros
Local nRegAProc	:= 0 // Registros a processar
Local nRegJProc	:= 0 // Total de registros jแ processados
Local cTabCtb	:= AF350NextAlias() // Tabela para o processamento multi thread
Local nNumProc 	:= GetMv("MV_A350THR", .F., 1 )
Local lCtbInTran := .F.
Local cTabMono	:= AF350NextAlias()

Default lNormal := .T.

lCtbInTran := CTBINTRAN(1,.F.)

If lCtbInTran 
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCria a pasta do semaforo caso nใo existaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !ExistDir(cDirSem)
		MontaDir(cDirSem)
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDados Bแsicos do Bemณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	AADD(aStrutSNS,{"NS_FILIAL" 	,"C",TAMSX3("NS_FILIAL")[1]	,00})
	AADD(aStrutSNS,{"NS_CODIGO" 	,"C",TAMSX3("NS_CODIGO")[1]	,00})
	AADD(aStrutSNS,{"NS_REVISAO" 	,"C",TAMSX3("NS_REVISAO")[1],00})
	AADD(aStrutSNS,{"NS_IDMOVTO" 	,"C",TAMSX3("NS_IDMOVTO")[1],00})
	AADD(aStrutSNS,{"NSRECNO" 		,"N",08,00})
	AADD(aStrutSNS,{"NSMARCA" 		,"C",TAMSX3("N3_OK")[1]	,00})
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณFiltra os registros e popula a tabela temporariaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cQuery := " SELECT "
	For nX := 1 to Len(aStrutSNS)
		If !(aStrutSNS[nX][1] $ "NSMARCA/NSRECNO" )
			cQuery += " "+aStrutSNS[nX][1]+" ,"
		EndIf
	Next nX
	cQuery +=  " SNS.R_E_C_N_O_ NSRECNO, '   ' NSMARCA " 
	cQuery +=  " FROM " + RetSqlTab("SNS")
	cQuery +=  " WHERE " 
	cQuery +=  " NS_CODIGO   BETWEEN '"+cCodDe+"' AND '"+cCodAte+"' "
	cQuery +=  " AND NS_REVISAO  BETWEEN '"+cRevDe+"' AND '"+cRevAte+"' "
	If lNormal
		cQuery +=  " AND NS_DCONTAB = ' ' "
	Else 
		cQuery +=  " AND NS_DCONTAB <> ' ' "
	EndIf
	cQuery +=  " AND SNS.D_E_L_E_T_ = ' ' "
	cQuery +=  " ORDER BY NSRECNO "
	
	
	MsErase(cTabCtb)
	MsCreate(cTabCtb, aStrutSNS, 'TOPCONN' ) 

	dbUseArea( .T., 'TOPCONN', cTabCtb, cTabCtb, .T., .F. ) 
	dbSelectArea( cTabCtb ) 
	SqlToTrb(cQuery, aStrutSNS, cTabCtb)
	
	If (cTabCtb)->(!EOF())
		(cTabCtb)->(dbGoTop())
		(cTabCtb)->(dbEval({|| nTotalReg++ }))
		(cTabCtb)->(dbGoTop())

		If nTotalReg < nNumProc
			aProcs := Array(1)	
		Else
			aProcs := Array(nNumProc)
		EndIf 
	                         
		If Len(aProcs) > 1 // MultiThread
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณRealiza o calculos das quantidades de registrosณ
			//ณque cada thread irแ processar                  ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			For nX := 1 to Len(aProcs) 
				cNomeArq 	:= cDirSem + cRaizNome +cEmpAnt + cFilAnt +cValtoChar(nX) + '.lck' 
				cMarca		:= GetMark()
				nRegAProc	:= IIf( nX == Len(aProcs), nTotalReg-nRegJProc, Int(nTotalReg / nNumProc) )
				nRegJProc	+= nRegAProc 
				aProcs[nX]	:= {cNomeArq ,cMarca,nRegAProc,0,0}
			Next nX
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณRealiza o Update dos campos de flag setando quais registrosณ
			//ณcada thread irแ processar.                                 ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			A350FlagTab(cTabCtb,aProcs,"NSRECNO","NSMARCA")
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณInicializa as Threadsณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			For nX := 1 to Len(aProcs)
				StartJob("A350JOBCTB",GetEnvServer(),.F.,cEmpAnt,cFilAnt,aProcs[nX][MARCA],aProcs[nX][ARQUIVO],cTabCtb,lAglutina,cValToChar(nX),aStrutSNS,lNormal)		
			Next nX
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณRealiza o controle das Threadsณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			Sleep(3000)
			lRet := AF350Monitor(aProcs) 
		Else
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณRealiza uma query sobre os registros da tabelaณ
			//ณtemporaria para ordernar na forma correta     ณ
			//ณNS_FILIAL + NS_CODIGO + NS_REVISAO            ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			cQuery := " SELECT "
			For nX := 1 to Len(aStrutSNS)
				cQuery += " "+aStrutSNS[nX][1]+" ,"
			Next nX
			cQuery := Left(cQuery,Len(cQuery)-1)
			cQuery +=" FROM "+cTabCtb+" SNS "
			cQuery +=" ORDER BY NS_FILIAL,NS_CODIGO,NS_REVISAO " 
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cTabMono, .F., .T.)
			
			lRet := A350SCtb(cTabMono,lAglutina,lNormal) 
			(cTabMono)->( dbCloseArea() )
		EndIf
	Else
		// Se nao hแ registros na simula็ใo para contabilizara alerta ao usuario
		// Quando for a esclusao esse alerta nao eh necessario
		if lNormal
			Help(" ",1,"ATFA350NoRec",,STR0091,1,0) //"Nใo ha registros a serem processados"
			lRet := .F.
		endif	
	EndIf                         
	
	(cTabCtb)->( dbCloseArea() )
	MsErase(cTabCtb)
EndIf
	
RestArea(aArea)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA350SCtb  บAutor  ณAlvaro Camillo Neto บ Data ณ  09/02/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza a contabiliza็ใo do registro em uma thread          บฑฑ
ฑฑบ          ณ(Single)                                                    บฑฑ
ฑฑบ          ณO alias passado deve estar ordenado como                    บฑฑ
ฑฑบ          ณNS_FILIAL+NS_CODIGO+NS_REVISAO para o correto procesamento  บฑฑ	
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA350                                          	      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A350SCtb(cTabCtb,lAglutina,lNormal) 
Local aArea 	:= GetArea()
Local aAreaSNS   := SNS->(GetArea())
Local lRet	:= .T.
Local aPadraoReal:= {"890","892"} // Simula็ao de Bens reais
Local aPadraoMod := {"891","893"} // Simula็ao de Modificadores
Local cPadrao	 := ""
Local lPadrao	 := .F.
Local lPadraoReal:= .F.
Local lPadraoMod := .F.
Local cLoteAtf   := LoteCont("ATF")
Local lPrim		 := .T.
Local cChave	 := ""
Local nPosTipo	 := 0

Private cArquivo := ""
Private nHdlPrv	 := 0
Private nTotal	 := 0

Default lNormal := .T.

nPosTipo := IIF(lNormal,1,2)

lPadraoReal:= VerPadrao(aPadraoReal[nPosTipo])
lPadraoMod := VerPadrao(aPadraoMod[nPosTipo])

SNS->(dbSetOrder(1)) 	//NS_FILIAL+NS_CODIGO+NS_REVISAO+NS_IDMOVTO

(cTabCtb)->(dbGotop())

cChave := (cTabCtb)->(NS_FILIAL+NS_CODIGO+NS_REVISAO)

While (cTabCtb)->(!EOF())	
	
    SNS->(MsSeek((cTabCtb)->(NS_FILIAL+NS_CODIGO+NS_REVISAO+NS_IDMOVTO)))

	If SNS->NS_TPMOV == '2' // Movimento de Modificador
		cPadrao := aPadraoMod[nPosTipo]
		lPadrao	:= lPadraoMod
	Else // Movimento de Bem Real
		cPadrao := aPadraoReal[nPosTipo]
		lPadrao	:= lPadraoReal			
	EndIf
	
	If lPadrao   // Se existe o Lacto padrao
		If lPrim
			nHdlPrv := HeadProva(cLoteAtf,"ATFA350",Substr(cUsuario,7,6),@cArquivo)
			lPrim := .F.
		Endif
		nTotal += DetProva(nHdlPrv,cPadrao,"ATFA350",cLoteAtf)
		RecLock("SNS",.F.)
			SNS->NS_DCONTAB = dDataBase
		MsUnlock()
	Endif
	(cTabCtb)->(dbSkip())	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVerifica a quebra de filial e Revisaoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If (cTabCtb)->(EOF()) .Or. cChave != (cTabCtb)->(NS_FILIAL+NS_CODIGO+NS_REVISAO)
		If nTotal > 0
			RodaProva(nHdlPrv,nTotal)
			cA100Incl( cArquivo, nHdlPrv , 3 , cLoteAtf, .F. , lAglutina) 
		EndIf
		lPrim    := .T.
    	cArquivo := ""
		nHdlPrv	 := 0
		nTotal	 := 0
		cChave   := (cTabCtb)->(NS_FILIAL+NS_CODIGO+NS_REVISAO)
	EndIf
End 

RestArea(aAreaSNS)
RestArea(aArea)
Return lRet
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFun็oes acessorias para o processamento MultiThreadณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA350FlagTabบAutor ณAlvaro Camillo Neto บ Data ณ  02/02/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza o Update dos campos de flag setando quais registros บฑฑ
ฑฑบ          ณcada thread irแ processar.                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA350                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A350FlagTab(cTabMult,aProcs,cCpoRecno,cCpoFlag)
Local aArea		:= GetArea()
Local nRecMin   := 0
Local nRecMax   := 0
Local nX		:= 0
Local nCount	:= 0
Local cQuery	:= ""

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDescobre o Recno Mแximo e Minimo de cada ณ
//ณintervalo                                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
(cTabMult)->(dbGoTop())
For nX := 1 to Len(aProcs)
	nRecMin := (cTabMult)->&(cCpoRecno) 
	nCount	:= 0 
	While (cTabMult)->(!EOF())
	    nRecMax := (cTabMult)->&(cCpoRecno) 
		(cTabMult)->(dbSkip())
		nCount++
		If nCount >= aProcs[nX][QTD_REGISTROS] .Or. (cTabMult)->(EOF()) 
			aProcs[nX][REC_MIN] := nRecMin
			aProcs[nX][REC_MAX]	:= nRecMax
			Exit
		EndIf 	 
	End
Next nX

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRealiza o Updateณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nX := 1 to Len(aProcs)
	cQuery := " UPDATE "+cTabMult+" SET "+cCpoFlag+" = '"+	aProcs[nX][MARCA]+"'  "
	cQuery += " WHERE "+cCpoRecno+" BETWEEN "+cValtoChar(aProcs[nX][REC_MIN])+ " AND " +cValtoChar(aProcs[nX][REC_MAX])
	TCSQLExec(cQuery) 
Next nX 

RestArea(aArea)
Return 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF350MonitorบAutorณAlvaro Camillo Neto บ Data ณ  03/02/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo responsavel por monitorar as threads de processamen บฑฑ
ฑฑบ          ณ to                                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA350                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF350Monitor(aProcs)
Local lRet			:= .T.
Local nX			:= 0
Local aConcluido	:= {} 
Local nHandle		:= 0
Local cMsg			:= ""

While .T.
    For nX := 1 to Len(aProcs)
    	nHandle := a350Lock(aProcs[nX][ARQUIVO])
    	If  nHandle >= 0
    		fClose(nHandle) 
    		If aScan(aConcluido,{|aItem| aItem[3] == aProcs[nX][MARCA]} ) == 0      
    			AADD(aConcluido, { nHandle, aProcs[nX][ARQUIVO], aProcs[nX][MARCA]})
    		EndIf
    	EndIf		 
    Next nX
    
    If Len(aConcluido) >= Len(aProcs) 
    	Exit
    EndIF
    Sleep(5000)
End

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se todas a threads foram processadas corretamenteณ
//ณlibera o recurso e apaga o arquivo                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nX := 1 to Len(aConcluido)
	FT_FUse(aConcluido[nX][2])
	FT_FGoTop()
	cMsg := FT_FReadLn()
	FT_FUse()
	fErase(aConcluido[nX][2])
	If lRet .And. ALLTRIM(cMsg) != OK
		lRet := .F. 
	EndIf
Next nX
 
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA350JOBSIMบAutor  ณAlvaro Camillo Neto บ Data ณ  03/02/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณJob respnsavel por subir o ambiente e processar a simulacao บฑฑ
ฑฑบ          ณde seus registros                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA350                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A350JOBSIM(cEmpX,cFilX,cMarca,cFileLck,cTabMaster,aDatasSimu,cCodigo,cRevisao,cId,aStruSQL)
Local nHandle	 := 0
Local cTabJob	 := ""
Local cQuery	 := ""
Local nX		 := 0 
Local lRet		 := .T.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAbre o arquivo de Lock parao controle externo das threadsณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nHandle := a350Lock(cFileLck)

//Seta job para nao consumir licensas
RpcSetType(3)
// Seta job para empresa filial desejada
RpcSetEnv( cEmpX, cFilX,,,'ATF')

Conout(STR0126 + cCodigo + STR0127 + cRevisao + STR0128 + cId + STR0129 + TIME()) // "Processando Simulacao da deprecia็ใo do Codigo:" // " Revisใo:" // " Thread: " // " as "

cTabJob	 := AF350NextAlias()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta a query dos registros a serem processadosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cQuery += " SELECT "
For nX := 1 to Len(aStruSQL)
	cQuery += " "+aStruSQL[nX][1]+"  ,"
Next nX
cQuery := Left(cQuery,Len(cQuery)-1)
cQuery +=" FROM "+cTabMaster+" SN3 "
cQuery +=" WHERE N3_OK = '"+cMarca+"'" 
cQuery := ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cTabJob, .F., .T.)

For nX := 1 to Len(aStruSQL)
	If aStruSQL[nX][2] <> "C"
		TcSetField(cTabJob ,aStruSQL[nX][1],aStruSQL[nX][2],aStruSQL[nX][3],aStruSQL[nX][4])
	EndIf
Next nX

(cTabJob)->(dbGotop())

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRealiza o processamentoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
lRet := A350SSim(cTabJob,aDatasSimu,cCodigo,cRevisao) 

a350UnLock(nHandle,lRet)
Conout(STR0126+ cCodigo + STR0127 + cRevisao + STR0128 + cId + STR0129 + TIME()) // "Processando Simulacao da deprecia็ใo do Codigo:" // " Revisใo:" // " Thread: " // " as "

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA350JOBCTBบAutor  ณAlvaro Camillo Neto บ Data ณ  09/02/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณJob respnsavel por subir o ambiente e processar a contabili บฑฑ
ฑฑบ          ณzacao dos movimentos de simula็ใo                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA350                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A350JOBCTB(cEmpX,cFilX,cMarca,cFileLck,cTabMaster,lAglutina,cId,aStrutSNS,lNormal)
Local nHandle	 := 0
Local cTabJob	 := ""
Local cQuery	 := ""
Local nX		 := 0 
Local lRet		 := .T.

Default lNormal := .T.
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAbre o arquivo de Lock parao controle externo das threadsณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nHandle := a350Lock(cFileLck)

//Seta job para nao consumir licensas
RpcSetType(3)
// Seta job para empresa filial desejada
RpcSetEnv( cEmpX, cFilX,,,'ATF')

Conout(STR0130+cId) // "Processando Contabiliza็ใo da deprecia็ใo Thread: "

cTabJob	 := AF350NextAlias()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta a query dos registros a serem processadosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cQuery += " SELECT "
For nX := 1 to Len(aStrutSNS)
	cQuery += " "+aStrutSNS[nX][1]+" ,"
Next nX
cQuery := Left(cQuery,Len(cQuery)-1)
cQuery +=" FROM "+cTabMaster+" SNS "
cQuery +=" WHERE NSMARCA = '"+cMarca+"'"
cQuery +=" ORDER BY NS_FILIAL,NS_CODIGO,NS_REVISAO " 
cQuery := ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cTabJob, .F., .T.)

For nX := 1 to Len(aStrutSNS)
	If aStrutSNS[nX][2] <> "C"
		TcSetField(cTabJob ,aStrutSNS[nX][1],aStrutSNS[nX][2],aStrutSNS[nX][3],aStrutSNS[nX][4])
	EndIf
Next nX

(cTabJob)->(dbGotop())

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRealiza o processamentoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
lRet := A350SCtb(cTabJob,lAglutina,lNormal)

a350UnLock(nHandle,lRet)
Conout(STR0130+cId) // "Processando Contabiliza็ใo da deprecia็ใo Thread: "
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณA350Lock  ณ Autor ณAlvaro Camillo Neto    ณ Data ณ 03/02/09 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณCria arquivo para travar processos e garantir que sao unicosณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณATFA350                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function A350Lock(cFile)
Local nHJob := 0
	If File(cFile)
		nHJob := FOPEN(cFile,2)			
	Else
		nHJob := FCREATE(cFile)
	EndIf
Return nHJob

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณA350UnLockณ Autor ณAlvaro Camillo Neto    ณ Data ณ 03/02/09 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณEncerra a trava                                             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณATFA350                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function A350UnLock(nHandle,lOk)
Local cMsg := IIF(lOk,OK,ERRO)
FWRITE(nHandle,cMsg)
FCLOSE(nHandle) 
Return

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFun็๕es Genericasณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCriaHeaderบAutor  ณAlvaro Camillo Neto บ Data ณ  21/02/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria o Aheader da getdados                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GENERICO                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CriaHeader(cCampos,cExcessao,aHeader,cAlias)
Local aArea		:= GetArea()
Local cCombo		:= ""
Default aHeader 	:= {}
DEFAULT cCampos 	:= "" // Campos a serem conciderados
DEFAULT cExcessao	:= "" // Campos que nใo conciderados

SX3->(dbSetOrder(1))
SX3->(dbSeek(cAlias))
While SX3->(!EOF()) .And.  SX3->X3_ARQUIVO == cAlias
	If (X3USO(SX3->X3_USADO) .Or. ( AllTrim(SX3->X3_CAMPO) $ Alltrim(cCampos) )) .AND. (cNivel >= SX3->X3_NIVEL) .AND. !(AllTrim(SX3->X3_CAMPO) $ Alltrim(cExcessao))
		cCombo := If("#" $ SX3->X3_CBOX,&(SUBSTR(SX3->X3_CBOX,2)),SX3->X3_CBOX)
		aAdd( aHeader, { AlLTrim( X3Titulo() ), ; // 01 - Titulo
		SX3->X3_CAMPO		, ;							// 02 - Campo
		SX3->X3_Picture	, ;							// 03 - Picture
		SX3->X3_TAMANHO	, ;							// 04 - Tamanho
		SX3->X3_DECIMAL	, ;							// 05 - Decimal
		SX3->X3_Valid  	, ;							// 06 - Valid
		SX3->X3_USADO  	, ;							// 07 - Usado
		SX3->X3_TIPO   	, ;							// 08 - Tipo
		SX3->X3_F3		   	, ;							// 09 - F3
		SX3->X3_CONTEXT  	, ;       					// 10 - Contexto
		cCombo				, ;							// 11 - ComboBox
		SX3->X3_RELACAO    } )   					// 12 - Relacao
	Endif
	SX3->(dbSkip())
End
RestArea(aArea)
Return(aHeader)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCriaAcols บAutor  ณAlvaro Camillo Neto บ Data ณ  21/02/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFunc๕a que cria Acols                                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณaHeader : aHeader aonde o aCOls serแ baseado                บฑฑ
ฑฑบ          ณcAlias  : Alias da tabela                                   บฑฑ
ฑฑบ          ณnIndice : Indice da tabela que sera usado para              บฑฑ
ฑฑบ          ณcComp   : Informacao dos Campos para ser comparado no While บฑฑ
ฑฑบ          ณnOpc    : Op็ใo do Cadastro                                 บฑฑ
ฑฑบ          ณaCols   : Opcional caso queira iniciar com algum elemento   บฑฑ
ฑฑบ          ณcCPO_ITEM: Opcional Campo de item a ser inicializado com '001'ฑฑ
ฑฑบ          ณcINDICE : Chave de compara็ใo da tabela de item             บฑฑ
ฑฑบ          ณcCPOMemo: Opcional Nome do campo de c๓digo do MEMO          บฑฑ
ฑฑบ          ณcMemo   : Nome do campo memo virtual                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GENERICO                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CriaAcols(aHeader,cAlias,nIndice,cComp,nOpc,aCols,cCPO_ITEM,cINDICE,cCPOMemo,cMemo)
Local nX			:= 0
Local nCols		      := 0
Local aArea			:= GetArea()
DEFAULT cCPO_ITEM		:= ""
DEFAULT cCPOMemo		:= ""
DEFAULT cMemo		:= ""

IF nOpc == INCLUIR
	aAdd(aCols,Array(Len(aHeader)+1))
	For nX := 1 To Len(aHeader)
		If Alltrim(aHeader[nX][2]) == cCPO_ITEM
			aCols[1][nX] := STRZERO(1,TamSX3(cCPO_ITEM)[1])
		Else
			aCols[1][nX] := CriaVar(aHeader[nX][2])
		EndIF
	Next nX
	aCols[1][Len(aHeader)+1] := .F.
Else
	(cAlias)->(dbSetOrder(nIndice))
	(cAlias)->(dbSeek(cComp))
	While (cAlias)->(!Eof()) .And. ALLTRIM((cAlias)->(&(cINDICE))) == ALLTRIM(cComp)
		aAdd(aCols,Array(Len(aHeader)+1))
		nCols ++
		For nX := 1 To Len(aHeader)
			If ( aHeader[nX][10] != "V")
				aCols[nCols][nX] := (cAlias)->(FieldGet(FieldPos(aHeader[nX][2])))
			ElseIf (aHeader[nX][8] == "M") // Campo Memo
				aCols[nCols][nX] := MSMM((cAlias)->(&(cCPOMemo)), TamSX3(cMemo)[1] )  
			Else
				aCols[nCols][nX] := CriaVar(aHeader[nX][2],.T.)
			Endif
		Next nX
		aCols[nCols][Len(aHeader)+1] := .F.
		(cAlias)->(dbSkip())
	End
EndIf
RestArea(aArea)
Return(aCols)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF350NextAliasบAutorณAlvaro Camillo Neto บ Data ณ  14/05/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณProte็ใo para retornar o pr๓ximo alias disponivel no Banco  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF350NextAlias()
Local cNextAlias := ""
Local aArea := GetArea()

While .T.
	cNextAlias := GetNextAlias()
	If !TCCanOpen(cNextAlias) .And. Select(cNextAlias) == 0
		Exit                                              
	EndIf	
EndDo 

RestArea(aArea)
Return cNextAlias


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAf350VlAglบAutor  ณAlvaro Camillo Neto บ Data ณ  14/05/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se o usuario concorda que o lan็amento aglutinado  นฑฑ
ฑฑบ          ณquebre em n documentos por causa do processamento			  นฑฑ
ฑฑบ          ณmultithread                                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA350                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Af350VlAgl()
Local lRet := .T.
Local nProc:= GetMv("MV_A350THR", .F., 1 ) 

Pergunte(cPerg,.F.)
If  nProc > 1 .And. MV_PAR02 == 1 .And. MV_PAR03 == 1 
	lRet := MsgYesNo( STR0107 + cValtoChar(nProc) + STR0108 +CRLF+ STR0109 +cValtoChar(nProc)+ STR0110 +CRLF+ STR0111 )
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunao    ณSelPlnDep  ณ Autor ณ Marco Aurelio - Mano    ณ Data ณ05/08/10  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao ณSeleciona registros a serem processados pela simulacao quando  ณฑฑ
ฑฑณ          ณreferentes ao tipo de bem "Planejado".                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณSelPlnDep(ExpD1,ExpC1,ExpC2,ExpcC3,ExpN1)                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณExpD1 = Data referente ao ultimo dia do periodo selecionado    ณฑฑ
ฑฑณ          ณExpC1 = Alias da tabela temporaria                             ณฑฑ
ฑฑณ          ณExpC2 = Codigo da Filial De para filtro                        ณฑฑ
ฑฑณ          ณExpC3 = Codigo da Filial Ate para filtro                       ณฑฑ
ฑฑณ          ณExpN1 = Quantidade de moedas a serem consideradas              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ SIGAATF                                                       ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/             
Static Function SelPlnDep(dLastDate,cAlias,cFilDe,cFilAte,nQtdMoed) 
Local nPosSNG	:= aScan( aMarks, {|x| Upper(AllTrim(x[4])) == 'SNG' } ) 
Local nPosCT1	:= aScan( aMarks, {|x| Upper(AllTrim(x[4])) == 'CT1' } ) 
Local nPosCTT	:= aScan( aMarks, {|x| Upper(AllTrim(x[4])) == 'CTT' } ) 
Local nPosCTD	:= aScan( aMarks, {|x| Upper(AllTrim(x[4])) == 'CTD' } ) 
Local nPosCTH  	:= aScan( aMarks, {|x| Upper(AllTrim(x[4])) == 'CTH' } ) 
Local cMoeda	:= ""
Local cColsSNN	:= ""	
Local cQuery    := ""
Local nInd      := ""
Local cNewAlias := GetNextAlias()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณColunas a serem filtradas da tabela SNN(Bem Planejado) ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cColsSNN := "NN_FILIAL, NN_CODIGO, NN_ITEM, NN_CCDEPR, NN_CCCDEP, NN_SUBCCDE, NN_AQUISIC, "

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณValores de Bens Planejados - Controle de multiplas moedas ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nInd := 1 TO nQtdMoed

	cMoeda := cValtoChar(nInd)

	If nInd>9
		cColsSNN += "NN_VORIG" + cMoeda + ", "
		cColsSNN += "NN_TXDEP" + cMoeda + ", "
	Else
		cColsSNN += "NN_VORIG"  + cMoeda + ", "
		cColsSNN += "NN_TXDEPR"	+ cMoeda + ", "
	EndIf

Next 

cColsSNN := Substr(cColsSNN,1,RAT(",",cColsSNN)-1)


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta query para selecionar bens planejados ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cQuery := "SELECT "+cColsSNN

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณTabela base do filtro ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cQuery += " FROM "  
cQuery += RetSqlName("SNN") + " SNN "

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRelaciona por Grupo de Ativos parametros selecionados ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If AF350Marc(aMarks[nPosSNG,6],"SNG") 
	cQuery += "	INNER JOIN "+aMarks[nPosSNG,6]+" SNG ON SNG.NG_OK <> ' ' "+ CRLF
	cQuery += "	AND NN_GRUPO = NG_GRUPO "+ CRLF
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRelaciona por Conta Contabil do Ativo conforme parametros selecionados ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If AF350Marc(aMarks[nPosCT1,6],"CT1") 
	cQuery += "	INNER JOIN "+aMarks[nPosCT1,6]+" CT1 ON CT1_OK <> ' ' "     + CRLF                  
	cQuery += " AND NN_CCONTAB	= CT1_CONTA	"+ CRLF
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRelaciona por Centro de Custo do Ativo conforme parametros selecionados ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If AF350Marc(aMarks[nPosCTT,6],"CTT") 
	cQuery += " INNER JOIN "+aMarks[nPosCTT,6]+" CTT ON CTT_OK <> ' ' "+ CRLF
	cQuery += " AND NN_CUSTBEM = CTT_CUSTO "+ CRLF
EndIF

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRelaciona por Item Contabil do Ativo conforme parametros selecionados ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If AF350Marc(aMarks[nPosCTD,6],"CTD") 
	cQuery += " INNER JOIN "+aMarks[nPosCTD,6]+" CTD ON CTD_OK <> ' ' "+ CRLF
	cQuery += " AND NN_SUBCCON = CTD_ITEM "+ CRLF
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRelaciona por Classe de Valor do Ativo conforme parametros selecionados ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If AF350Marc(aMarks[nPosCTH,6],"CTH") 
	cQuery += " INNER JOIN "+aMarks[nPosCTH,6]+" CTH ON CTH_OK <> ' ' "+ CRLF
	cQuery += " AND NN_CLVLCON = CTH_CLVL " + CRLF
EndIf

cQuery += "WHERE "+ CRLF
cQuery += "NN_FILIAL BETWEEN '"+xFilial("SNN",cFilDe)+"' AND '"+xFilial("SNN",cFilAte)+"'  AND " + CRLF
cQuery += "SNN.D_E_L_E_T_ = ' '"  + CRLF


cQuery := ChangeQuery(cQuery)

DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cNewAlias,.T.,.T.)

aStru := dbStruct()
     
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCompatibiliza estrutura de campos tipo Data e Numerico ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

SX3->(DbSetOrder(2))

For nInd:=1 TO Len(aStru)
	If SX3->(DbSeek(aStru[nInd][1])) .And. SX3->X3_TIPO <> "C" 
		TCSetField(cNewAlias,SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_TAMANHO, SX3->X3_DECIMAL)
	Endif
Next

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAtualiza tabela temporaria de simulacao da depreciacao ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Do While !(cNewAlias)->(EOF())  

	RecLock(cAlias,.t.)
	
	For nInd:=1 To (cNewAlias)->(FCount())    
		cCpoGrv := StrTran((cNewAlias)->(FieldName(nInd)),"NN_","N3_")
		cCpoGrv := Iif("CODIGO"$cCpoGrv,"N3_CBASE",cCpoGrv)
		(cAlias)->(&cCpoGrv):=(cNewAlias)->(FieldGet(nInd))	
	Next
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCampo com valor fixo quando Bem Planejado ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	(cAlias)->N3_TIPO := "01" 
	(cAlias)->N3FLAG := BEM_MODIFICACAO

	(cAlias)->(MsUnLock())
	(cNewAlias)->(dbSkip())
		
EndDo 

(cNewAlias)->(dbCloseArea())  

Return cQuery

// -------------------------------------------------------------------
/*/ {Protheus.doc} ATFA350
Fun็ใo de modo de edi็ใo dos campos do grid de Modificadores da Simula็ใo
de Deprecia็ใo.
Utilizados nos campos X3_WHEN da Tabela SNS - Movimentos da Simula็ใo

@return lRet	Valor booleano se verdadeiro para campo liberado, falso para bloqueado
@author marylly.araujo
@since 19/12/2012
@version MP11
/*/
// -------------------------------------------------------------------
Function AF350VldCpo()
Local lRet 		:= .T.
Local cCpoAtual	:= SUBSTR(AllTrim(ReadVar()),4) // Removendo o M-> do ponteiro da variแvel de mem๓ria
Local cTipDrpAt	:= ""
/*
 * Configura็ใo dos campos de acordo com o m้todo de deprecia็ใo selecionado
 */
If cCpoAtual == 'NR_TPDEPR'
    if (GDFieldGet('NR_TPMOD') = '2')// Campo de Tipo de Deprecisใo ้ desabilitado na Baixa
		lRet := .F.
	else	
		cTipDrpAt := &(ReadVar())
		If cTipDrpAt != "7"
			GdFieldPut('NR_VMXDEPR',0,oGetD:nAt)
		EndIf
	
		If !(cTipDrpAt $ "2|6") 
			GdFieldPut('NR_PERDEPR',0,oGetD:nAt)
		EndIf
	
		If !(cTipDrpAt $ "4|5") 
			GdFieldPut('NR_PRODANO',0,oGetD:nAt)
			GdFieldPut('NR_PRODMES',0,oGetD:nAt)
		EndIf
	
		If cTipDrpAt != "2"
			GdFieldPut('NR_VLSALV1',0,oGetD:nAt)
		EndIf
	
		If cTipDrpAt $ "2|4|5|6|A"
			GdFieldPut('NR_TXDEPR1',0,oGetD:nAt)
			GdFieldPut('NR_TXDEPR2',0,oGetD:nAt)
			GdFieldPut('NR_TXDEPR3',0,oGetD:nAt)
			GdFieldPut('NR_TXDEPR4',0,oGetD:nAt)
			GdFieldPut('NR_TXDEPR5',0,oGetD:nAt)
		EndIf
	
		If cTipDrpAt != "A"
			GdFieldPut('NR_CODIND',Space(TamSX3("NR_CODIND")[1]),oGetD:nAt)
		EndIf
	endif	
EndIf

/*
 * Se o m้todo de deprecia็ใo for 
 */
If cCpoAtual == 'NR_PERDEPR'
	If !(GDFieldGet('NR_TPDEPR') $ '2|6')
		lRet := .F.
	EndIf
ElseIf cCpoAtual == 'NR_VLSALV1'
	If GDFieldGet('NR_TPDEPR') != '2'
		lRet := .F.
	EndIf
ElseIf cCpoAtual $ 'NR_PRODANO|NR_PRODMES'
	If !(GDFieldGet('NR_TPDEPR') $ '4|5')
		lRet := .F.
	EndIf
ElseIf cCpoAtual == 'NR_VMXDEPR'
	If GDFieldGet('NR_TPDEPR') != '7'
		lRet := .F.
	EndIf
ElseIf AllTrim(cCpoAtual) $ 'NR_TXDEPR1|NR_TXDEPR2|NR_TXDEPR3|NR_TXDEPR4|NR_TXDEPR5'
	If AllTrim(GDFieldGet('NR_TPDEPR')) == 'A'
		lRet := .F.
	EndIf
ElseIf cCpoAtual == 'NR_CODIND'
	If GDFieldGet('NR_TPDEPR') != 'A'
		lRet := .F.
	EndIf
EndIf

Return lRet
