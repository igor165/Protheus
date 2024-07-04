#Include "FINA565.CH"
#include "PROTHEUS.CH"
#include "FWMVCDEF.CH"
#INCLUDE "FILEIO.CH"

Static lFWCodFil := FindFunction("FWCodFil")

/** {Protheus.doc} 
Rotina de Romaneio de Compra utilizada para entradas de cargas onde a emissão do documento
do Romaneio é obrigatório. Esta rotina permite a atualização do saldo fisico, porem quando
uma nota fiscal acompanhar o mesmo deve atualizar tambem o saldo fiscal
//
@param: 	Nil
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGA360LIQ(cCtrato , cItFix , cCPagto , cTpo , cNaturez , cPrefix , nxMoeda , nVroPag , dDtVencto , cForDe, cLjaDe, cForPara , cLjaPara,cBco,cAg,cConta,cQuery,oGridNKK,xTpLiq,nAcrescLq,ndecresLq )

// -- Variaveis Local --
Local    nX			:= 1
Local 	 lContinua	:= .t.
Local    nCount		:= 0
Local    nVrLqdAux	:= 0
Local 	 aSaveLines := FWSaveRows() 		// Salva a posição de todos os Grids 

//--- Inicio Vars da Rotina Fina565 ---
Local aTamBco 	:= TamSx3("E2_BCOCHQ")
Local aTamAge 	:= TamSx3("E2_AGECHQ")
Local aTamCta 	:= TamSx3("E2_CTACHQ")
Local aTam		:= TamSx3("E2_NUM")

Local nTamTit	:= TamSX3("E2_PREFIXO")[1]+TamSX3("E2_NUM")[1]+TamSX3("E2_PARCELA")[1]+TamSX3("E2_TIPO")[1]
Local nTamChave	:= TamSX3("E2_FILIAL")[1]+TamSX3("E2_FORNECE")[1]+TamSX3("E2_LOJA")[1]+nTamTit

Private cLote
Private aDiario 		:= {}
Private cCodDiario	:= ""

Private aCampos 	 := {	{"MARCA"   	,"C", 2,0},;
							{"FILIAL"	,"C",If(lFWCodFil,FWGETTAMFILIAL,TamSX3("E2_FILIAL")[1]),0},;		// GESTAO
							{"TITULO"	,"C",nTamTit+3,0},;
							{"MOEDAO"	,"N", 2,0},;			//Moeda do Titulo
							{"CTMOED"	,"N",10,4},;			//Moeda do Titulo
							{"VALORI"	,"N",15,2},;			//Valor original do titulo 		
							{"ABATIM"	,"N",15,2},;
							{"BAIXADO"	,"N",15,2},;
							{"VALCVT"	,"N",15,2},;			//Valor convertido para a moeda escolhida
							{"JUROS"	,"N",15,2},;
							{"VACESS" , "N", 15,2},;  
							{"VLMULTA"	,"N",15,2},;
							{"DESCON"	,"N",15,2},;
							{"VALLIQ"	,"N",15,2},;
							{"EMISSAO"	,"D",08,0},;
							{"VENCTO"	,"D",08,0},;
							{"ACRESC"	,"N",15,2},;
							{"DECRESC"	,"N",15,2},;
							{"CHAVE"	,"C",nTamChave,0},;
							{"CHAVE2"	,"C",nTamChave,0},;
							{"E2_REC" , "N", 15,0}}
													
Private nUsado2	 := 0
Private dBaixa	  :=dDataBase

Private cParc565  := ""

Private cFornece 		:= Criavar ("E2_FORNECE",.F.)
Private cLoja   		:= Criavar ("E2_LOJA",.F.)

Private cFornDE 		:= cForDe
Private cLojaDE 		:= cLjaDe
Private cFornAte		:= cForDe
Private cLojaAte		:= cLjaDe
Private cNomeForn 	:= CriaVar ("E2_NOMFOR")

Private nMoeda 	  	:= nxMoeda//1

Private nQtdTit   	:= 0
Private nValorMax 	:= 0				// valor maximo de liquidacao (digitado)
Private nValorDe  	:= 0 			   // valor inicial dos titulos
Private nValorAte 	:=  9999999999.99 // Valor final dos titulos

Private nValorLiq 	:= nVrOPag //0				// valor da liquidacao ap¢s mBrowse

Private nNroParc  	:= 0				// numero de parcelas digitadas
Private cCondicao 	:= Space(3)		// numero de parcelas automaticas


Private cNatureza 	:=  cNaturez //Criavar ("E2_NATUREZ")

Private aHeader   	:= {}
Private aCols  		:= {}
Private cMarca  	  	:= GetMark()

Private cTipo	 	 := cTpo//Criavar ("E2_TIPO")
Private nJuros    := 0							
// --- Fim Vars da Rotina Fina565 ---

//-- SomaAbat Cria o Alias __SE2 --//
SomaAbat("","","","P")

// -- cQuery vem da Chamada da Rotina no OGA360 (Seu formato deve ser o formato q a FINA565 Exige --//
cAliasSE2 := GetNextAlias()
cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasSE2,.F.,.T.)	
//--- Fim Selecionando Registros de Acordo com a Fixação e Ctrato ---

TRB := sTaticcall(FINA565 , Fa565Gerarq, aCampos )		// --- Gera arQuivo Temporario  da Função do FINA565							---//
Fa565Repl(TRB,cAliasSE2)								// --- Carrega o TRB com os Dados da Consulta(Fa565Repl stá no FINA565	--- //
	
// --- Inicio Marcando todos os Registros do TRB --- // ( Baseado na A565Inverte do FINA565 )
 

SE2->(DbSetOrder(1))
IF ! xTpLiq = '1' // Forma Utilizada Para Liq. os Tits. Anteriormente. em um Momento no futuro Pode-se retirar o q Está no if. e Deixar somente o Conteudo do Else

	nValor	:= 0
	DbSelectArea("TRB")
	TRB->( DBGOTOP() )
	While ! TRB->( Eof() )
		SE2->(MSSeek(TRB->CHAVE))
		If SE2->( MsRLock() ) .and. SE2->E2_SALDO > 0
			RecLock("TRB")
			Replace MARCA With cMarca
			TRB->(MsUnlock())
			nValor 	+= TRB->VALLIQ
			nQtdTit	++
			IF nValor >= nVrOpag // Marca Titulos enquanto o Vr. dos tits. Selec. é menor que o Vr. da OPAGTO + 1 Titulo (q será baixado Parcial)
			   Exit
			EndIF
		Endif
		TRB->(dbSkip())
	EndDo

Else   // Forma Atual de Seleção Dos Tits. Para Liquidação
	//--Posiciono o TRB no Inicio
    lContinua 	:= .t.
    aTravados := {}   //Conterá Recnos Travados para Destrava-los Caso Algo Ocorra
    
    aSaveLines := FWSaveRows() 		// Salva a posição de todos os Grids
	For nX:= 1 To oGridNKK:Length() Step 1
	    
	    oGridNKK:GoLine( nX )
	    
	    IF oGridNKK:IsDeleted()
	       Loop
	    EndIF
	    // Vr. do Titulo a Liquidar = Vr. fixado a Liquidar + Vr. do Frete + Vr. Seguro + Vr. Despesa //
		nVrLqdAux := oGridNKK:GetValue('NKK_VRLQDF') + oGridNKK:GetValue('NKK_FRELQD') + oGridNKK:GetValue('NKK_SEGLQD') + oGridNKK:GetValue('NKK_DSPLQD')
		
		//Como n. Posso Acrescer ou decrescer no titulo e somente na Liquidação entao o vr. a liquidar entao:
		// Se tenho q decrescer -> Tenho q Adicionar no Vr. a Liquidar para no final lançar o decrescimo na liquidação de forma acumulada um unico
		// 		decrescimo de todos os titulos;
		// Se tenho q Acrescer	-> Tenho q Decrescer no Vr. a Liquidar para no Final Lancar o acrescimo  na Liquidacao de forma acumulada um unico
		//      Acrescimo.
		
		nVrLqdAux += oGridNKK:GetValue('NKK_DECRES') - oGridNKK:GetValue('NKK_ACRESC')
		
		//Encontrando o Recno do Titulo
		nRecnoTIT := 0
		nRecnoTIT := OG360RgTIT( oGridNKK:GetValue('NKK_TABLQD'), oGridNKK:GetValue('NKK_CPOTIT'),oGridNKK:GetValue('NKK_CHVTIT')  )
			
		SE2->( DbGoto( nRecnoTit ) ) 
		IF nRecnoTIT  == 0
			cMensagem := 'Titulo não encontrado. O título selecionado pode ter sido exlcuido por outro processo. Titulo/Parcela:' + '[' + SE2->E2_NUM + '/' + SE2->E2_PARCELA + ']'
//			    n. dar mensagem aqui para evitar q registros fique travados enquanto o usuaro n. sair da tela
///				Help( ,, 'Ajuda',, cMensagem'Titulo nãop encontrado. O título selecionado pode ter sido exlcuido por outro processo. Titulo/Parcela:' + '[' + SE2->E2_NUM + '/' + SE2->E2_PARCELA + ']' , 1, 0,) //"HELP"##Titulo está sendo atualizado por outro processo. Aguarde e tente novamente;Titulo/Parcela:' + '[' +SE2->E2_NUM + "/" E2_PARCELA + ']'
			lContinua:= .f.
			Exit
		EndIF
		IF lContinua .and.  SE2->E2_SALDO <  nVrLqdAux
			cAux := '[' + SE2->E2_NUM + '/' + SE2->E2_PARCELA + '/' + SE2->E2_PREFIXO + '/' + SE2->E2_FORNECE + '-' + SE2->E2_LOJA + ']'
			cMensagem := 'Sld.Titulo está menor que o Vr. a ser Lqdado na OP/OR informado na Aba Entregas. Titulo pode ter sido baixado por outro processo. Clique em Refresh TitS/Entregas. em ações do Browse de Entregas e tente confirmar novamente.Pref/Tít/Parc/Forn: '
			cMensagem += cAux
				/*n. dar mensagem aqui para evitar q registros fique travados enquanto o usuaro n. sair da tela				 
				Help( ,, 'Ajuda',, 'Saldo do Titulo está menor do que o Vr. a ser Liquidado pela OP/OR informado na Aba Entregas. Titulo pode ter sido baixado por outro processo. Clique em Refresh TitS/Entregas. em ações do Browse de Entregas e tente confirmar novamente.Pref/Tít/Parc/Forn: ' + cAux , 1, 0,) //"HELP"##Titulo está sendo atualizado por outro processo. Aguarde e tente novamente;Titulo/Parcela:' + '[' +SE2->E2_NUM + "/" E2_PARCELA + ']' */	        
			lContinua := .f. 
			Exit
		EndIF
		
		If lContinua    // Se titulo foi encontrado e o Vr. é suficiente para Baixar o q preciso marco para liquidar
			While (.t.)
				IF SE2->( MsRLock() )    // Se Travar
					aAdd(aTravados,SE2->( Recno() ))   // aRRay auxiliar Caso precise destravalos
					IF TRB->(DBSEEK( SE2->(E2_FILIAL + E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO + E2_FORNECE + E2_LOJA) ))
						RecLock("TRB")
						Replace MARCA 		With cMarca
						Replace VALLIQ		With nVrLqdAux 
						TRB->(MsUnlock())
						nQtdTit	++
						Exit
					Else
						Final('Erro: Titulo não encontrado no sistema')
					EndIF
				Else   //Senao conseguiu travar
					For nCount := 1 to 10	// tento nos proximos 10 segundos locar o registro
						Sleep( 1000 )  // Espera 1 segundo
					nExt nCount
					IF nCount >= 10  // Infelizmente esperei 10 segundos mas n. foi possivel locar o registro
						cAux := '[' + SE2->E2_PREFIXO + '/' + SE2->E2_NUM + '/' + SE2->E2_PARCELA + '/' +  SE2->E2_FORNECE + '-' + SE2->E2_LOJA + ']'
						cMensagem := 'Título está sendo atualizado por outro processo; Agurde e tente novamente. Pref/Tit/Parc/For:'
						cMensagem += cAux
						lContinua := .f.
						Exit
					EndIF
				EndIF
			EndDo   
		EndIF

		IF !lContinua
			Exit
		EndIF
	nExt NX
	FWRestRows( aSaveLines ) //Restaura a posição anterior dos Grids
	
	IF ! lContinua // Algo Está errado ( Tit. n. pode ser locado, Nao encontrado, ou saldo unsuficiente)
	   DisarmTransaction()   //a Transação foi Aberta no OGA360, tenho q desarmar Para utilizar o MSRUNLOCK()
	   For nX := 1 to Len(aTravados)  // Tenho q destravar os Registros, ou ficaram todos travados 
	   		SE2->(DbGoto( aTravados[nx]) )
	   		MSRUNLOCK()
	   neXt nx
	   
		Help( ,, 'Ajuda',, cMensagem , 1, 0,)
	   
	   Return(.f.)
	EndIF
EndIF


// --- Fim Marcando todos os Requisitos do TRB 			--- //

// --- Inicio Criando o Aheadar do GetDados da Fina565 	--- //
	Aadd(aHeader,{"PREFIXO"		,"E2_PREFIXO"	,"!!!"					,3				,0	,"AllWaysTrue()"	,"û","C","SE2" } )  //"PREFIXO "
	Aadd(aHeader,{"TIPO"		,"E2_TIPO"		,"@!"					,3				,0	,"FA565TIPO()"		,"û","C","SE2" } )  //"TIPO" 
	Aadd(aHeader,{"BCO"			,"E2_BCOCHQ"	,"@!"					,aTamBco[1]		,0	,"AllWaysTrue()"	,"û","C","SE2" } )  //"BCO. "
	Aadd(aHeader,{"AGENCIA"		,"E2_AGECHQ"	,"@!"					,aTamAge[1]		,0	,"AllwaysTrue()"	,"û","C","SE2" } )  //"AGENCIA"
	Aadd(aHeader,{"CONTA"		,"E2_CTACHQ"	,"@!"					,aTamCta[1]		,0	,"AllwaysTrue()"	,"û","C","SE2" } )  //"CONTA"
	Aadd(aHeader,{"NRCHEQUE"	,"E2_NUM"		,"@!"					,aTam[1]		,0	,"a565NumChq()"		,"û","C","SE2" } )  //"NRO. CHEQUE"
	Aadd(aHeader,{"DATABOA"		,"E2_VENCTO"	," "					,8				,0	,"a565DataOK()"		,"û","D","SE2" } )  //"DATA BOA"
	Aadd(aHeader,{"VALOR"		,"E2_VLCRUZ"	,"@E 9999,999,999.99"	,14				,2	,"A565Valor()"		,"û","N","SE2" } )	//"VALOR"
	Aadd(aHeader,{"ACRESC."		,"E2_ACRESC"	,"@E 999,999.99"		,10				,2	,"A565Valor()"		,"û","N","SE2" } ) 	//"ACRESCIIMOS"
	Aadd(aHeader,{"DECRESC."	,"E2_DECRESC"	,"@E 999,999.99"		,10				,2	,"A565Valor()"		,"û","N","SE2" } )	//"DECRESCIMOS"
	Aadd(aHeader,{"VR.TOTAL"	,"E2_VALOR"		,"@E 9999,999,999.99"	,14				,2	,"AllwaysTrue()"	,"û","N","SE2" } ) 	//"VALOR TOTAL"
// --- Fim Criando o Aheadar do GetDados da Fina565 --- //

//--Vars. somente para quardar a Posicao das cols Do Aheader --//
nPosPrefix 	:= 01
nPosTipo	:= 02
nPosBco		:= 03
nPosAgencia	:= 04
nPosCta		:= 05
nPosChq		:= 06
nPosDtBoa	:= 07
nPosVr		:= 08
nPosAcr		:= 09
nPosDec		:= 10
nPosTotal		:= 11
//--Fim Vars. somente para quardar a Posicao das cols Do Aheader --//


nUsado2 := Len(aHeader)
aCols   := Array( 1 , ( nUsado2 + 1) )  //-- Criando o Acols  de Acordo com o Array do Fina565 //


// -- Encontrando o Nr. da Liquidacao q será gerado 		--- //
cLiquid	:= Soma1(GetMv("MV_NUMLIQP"),6)

While !MayIUseCode( "E2_NUMLIQP"+cLiquid )	//--- Verifica se esta na memoria, sendo usado 	---//
	cLiquid := Soma1(cLiquid)			 		//--- Busca o proximo numero disponivel 			---//
EndDo
// -- Fim Encontrando  Nr. da Liquidacao q será gerado 	--- //

//-- Atribuindo Vrs. as Variaveis de Get fora do Grid  --- //
cNatureza	:= cNaturez
cFornDE  	:= cForDe
cLojaDE 	:= cLjaDe
cFornAte  	:= cForDe
cLojaAte  	:= cLjaDe
nValorLiq 	:= nvropag
cTipo		:= cTpo
cfornece 	:= cForPara
__cLojaAGR	:= cLjaPara
cNomeForn  :=  Posicione("SA2",1,FwxFilial("SA2")+cFornece +__cLojaAGR,"SA2->A2_NOME")   

//-- Atribuindo Vrs. as Vars do Grid --- //

aCols[1,nPosPrefix	]	:= cPrefix
aCols[1,nPosTipo	]	:= cTpo
aCols[1,nPosBco		]	:= cBco
aCols[1,nPosAgencia	]	:= cAg
aCols[1,nPosCta		] 	:= cConta
aCols[1,nPosChq		] 	:= cLiquid 	// -- Eh isso mesmo o Nr. do Chq. será o Nr. da Liquidação --- //
aCols[1,nPosDtBoa	] 	:= dDtVencto
aCols[1,nPosVr		] 	:= nVrOpag
aCols[1,nPosAcr		]	:= nAcrescLq
aCols[1,nPosDec		]	:= ndecresLq
acols[1,nUsado2+1	] 	:= .f.  		//Não deletado


/* Não rolou chamar a validação é necessario mais tempo de analise , no momneot n. temos //
lTdoOK := a565TudoOK() // --- Valida o Acols funcao do FINA565 --//
IF ! lTdoOk
 rETURN ( .F. )
EndIF
*/


//--- Recupera o nr. do Lote Contabil --- //
LoteCont( "FIN" )


// --- Ajustando Vars do Pergunte  da FINA565 --- //
Pergunte("FIN565",.F.)
    	
// --- Chamando a Função Padrão para Gerar a --- // 
StaticCall (FINA565 , a565Grava , aHeader , aCols )

/*/
----------------------------------------------------------*
! Atualiza Parametro de Ultimo Numero de Liquidacao       !
! Somente se nao existir o ponto de entrada, pois o mesmo !
! ja atualiza o parametro                                 !
*---------------------------------------------------------*
/*/	

If GetMv("MV_NUMLIQP") < cLiquid
	PUTMV("MV_NUMLIQP",cLiquid)
Endif

// -- Fecando o TRB / a Query---//
Trb->( DbCloseArea() )
(cAliasSe2)->( DbCloseArea() )

Return(.t.)


/** {Protheus.doc} OGA360LIQC
Rotina de Cancelamento de Liquidação ( Clone da FA565CAN a rotina foi copiada do fonte atual em 15/01/2015)
Somente Alterado para n. permitir alterar o Nr. da liQuidação
Para identificar as alterações procure pro:
// Agronegocios Retirado
e
// Agronegocios Incluido
Em caso de necessidade de copiar a função novamente pasta garantir que as linhas da tela estejam comentadas
essa função será utilizada enquando a equipe responsavel por essa função n. inclui forma automatica de exec
utar esta rotina

//
@param: 	Nil
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		SIGAAGR - Originação de Grãos
*/
// Agronegocios Retirado Function FA565CAN( cAlias, cCampo, nOpcx )
Function OGA360LIQC( cAlias, cCampo, nOpcx )		// Agronegocios Incluido
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis 											 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cArquivo
Local nTotal	:= 0
Local nHdlPrv	:= 0
Local nOpcT		:= 0
Local nTitulos	:= 0
Local nParcelas	:= 0
Local cIndex	:= ""
Local cNewLiq
Local cDadosSE2
Local cDadosSe5
Local lHeadProva:= .F.
Local lPadraoE2	:= VerPadrao("515")  // Exclusao de conta a PAGAR
Local cPadrao
Local lContabilizou := .F.
Local lDigita 	:= .T.
Local lAglutina := .T.
Local lCtBaixa 	:= .F.
Local lFin565e2 := ExistBlock("FIN565E2")
Local lAcreDecre:= .F.
Local nAcresc 	:= 0
Local nDecresc 	:= 0
Local aFlagCTB	:= {}
Local lAtuSldNat  := FindFunction("AtuSldNat") .AND. AliasInDic("FIV") .AND. AliasInDic("FIW")
Local cFilOrig :=  Space(TamSX3("E5_FILORIG")[1])
Local lF565E5  :=ExistBlock("F565E5")
Local cValPadrao := Type("nValPadrao")

/* GESTAO - inicio */
Local nMoedaCus	:= 0
Local aDadosSE5	:= {}
/* GESTAO - fim */


Private cLiqCan := CriaVar("E2_NUM" , .F.) 
Private cCodDiario:= ""
Private cLote			// Agronegocios
Private aDiario := {}	// Agronegocios

// Zerar variaveis para contabilizar os impostos da lei 10925.
VALOR5 := 0
VALOR6 := 0
VALOR7 := 0                   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se data do movimento n„o ‚ menor que data limite de ³
//³ movimentacao no financeiro    										  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !DtMovFin()
	Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o numero do Lote 									 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//Substituido o acesso direto a tabela SX5 - SONARQUBE
cLote := Substr(FWGetSX5("09", "FIN   ")[1][4],1,2)

If Empty(SE2->E2_NUMLIQ)
	cLiqCan := SuperGetMV("MV_NUMLIQP")
Else
	cLiqCan := SE2->E2_NUMLIQ
EndIf

nValor		:= 0
nValPag		:= 0
nTitulos 	:= 0
nParcelas	:= 0
nOpcT 		:= 0

//verifica se existem os capos de valores de acrescimo e decrescimo no SE5
If SE5->(FieldPos("E5_VLACRES")) > 0 .and. SE5->(FieldPos("E5_VLDECRE")) > 0
	lAcreDecre := .T.
Endif

aSize := MSADVSIZE()


// --- Ajustando Vars do Pergunte  da FINA565 --- Agronegocios Incluido//
Pergunte("FIN565",.F.)						// Agronegocios Incluido

//--- Recupera o nr. do Lote Contabil --- //
LoteCont( "FIN" )

lokAgr:= sTaticcall(FINA565, Fa565OK2 )	// Agronegocios Incluido
IF lOkAgr										// Agronegocios Incluido
   nOpct := 1									// Agronegocios Incluido
Else											// Agronegocios Incluido
 nOpct := 0									// Agronegocios Incluido
EndIF   										// Agronegocios Incluido

	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva a Area atual do SE2                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SE2")
nOrdemSe2 	:= IndexOrd()
nRegSE2 	:= Recno()
nRecSe5		:= SE5->(Recno())

If Existblock("F565CANC")
	nOpct := Execblock("F565CANC" ,.F.,.F.)
Endif

If nOpct == 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleciona os registros a serem processados no cancelamento³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If A565Filtra(cLiqCan)
		cFilialAtu := cFilAnt
		nMoedaCus:= Val(GetMv("MV_MCUSTO"))
		dbSelectArea("TRB")
		DbGoTop()		
		DbSelectArea("SE2")
		DbGoTop()
		While TRB->(!Eof())
     		SE2->(dbGoto(TRB->CHAVE))
     		TRB->(dbSkip())
			DbSelectArea("SE2")
      	
			cDadosSe2 := SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)
			cDadosSe5 := SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)
			
			/* GESTAO - inicio */
			#IFDEF TOP
				aDadosSE5 := {SE2->E2_FILORIG,SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_FORNECE,SE2->E2_LOJA}
			#ENDIF
			/* GESTAO - fim */

			//Movimento dos titulos geradores de liquidacao
			If ( Empty(SE2->E2_NUMLIQ) .And.;
				 (Empty(SE2->E2_BCOCHQ) .and. !(SE2->E2_TIPO $ MV_CPNEG))) .or. ;
				  SE2->E2_STATUS == "R" 
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Se for um titulo que gerou a liquidacao, desfaz o processo³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nTotAbat := 0
				nJuros	:= 0
				nDescont := 0
				
				/* GESTAO - inicio */
				cFilAnt := SE2->E2_FILORIG
				/* GESTAO - fim */

				dbSelectArea("SE2")
				nTotAbat := SomaAbat(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,"P",SE2->E2_MOEDA,dDataBase,SE2->E2_FORNECE,SE2->E2_LOJA)

				/* GESTAO - inicio */
				cFilAnt := cFilialAtu 
				/* GESTAO - fim */
				
				dbSelectArea("SE5")
				SE5->(dbSetOrder(7))
              
                //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                //Ponto de entrada para tratamento do titulo gerado pela   ³ 
				//liquidacao antes do cancelamento.                        ³  
   				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				IF lF565E5
      				ExecBlock("F565E5", .F., .F.)
				Endif    

				If SE5->( MsSeek(xFilial("SE5")+cDadosSE5))

					While !Eof() .and. xFilial("SE5") == SE5->E5_FILIAL .and. ;
						SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA) == cDadosSE5

						If SE5->E5_SITUACA == "C" .or. cLiqCan != Alltrim(E5_DOCUMEN) .or. ;
							SE5->E5_MOTBX != "LIQ" .or. !(SE5->E5_TIPODOC $ "DC#JR#BA") .Or.;
							SE5->E5_RECPAG != "P" .Or. !(SE5->E5_FILORIG == SE2->E2_FILORIG)
							dbSKip()
							Loop
						EndIf

						// Verifica movimentacao de AVP
						If FindFunction( "FAVPValTit" )
							FAVPValTit( "SE2", SE5->( RecNo() ) )
						EndIf

						If SE5->E5_TIPODOC == "DC"
							nDescont := SE5->E5_VALOR
						ElseIf  SE5->E5_TIPODOC == "JR"
							nJuros := SE5->E5_VALOR
						Elseif  SE5->E5_TIPODOC == "BA"
							nValPag  := SE5->E5_VALOR
							nValorM2 := SE5->E5_VLMOED2
							nRecSE5  := SE5->( recno() )
							lCtBaixa := If("S"$SE5->E5_LA,.T.,lCtBaixa)
							If lAcreDecre
								nAcresc := SE5->E5_VLACRES
								nDecresc := SE5->E5_VLDECRE
							Endif
						EndIf
						RecLock("SE5")
						Replace E5_SITUACA with "C"
						Replace E5_FILORIG with cFilOrig
						
						
						If ( FindFunction( "UsaSeqCor" ) .And. UsaSeqCor() ) 
							AADD(aDiario,{"SE5",SE5->(recno()),cCodDiario,"E5_NODIA","E5_DIACTB"}) 
			   		endif
			   		
						dbSkip()
					End
				Endif

				SE5->( dbGoTo( nRecSE5 ) )

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se foi utilizada taxa contratada para moeda > 1          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SE2->E2_MOEDA > 1 .and. Round(NoRound(xMoeda(nValPag,1,SE2->E2_MOEDA,SE5->E5_DATA,3),3),2) != SE5->E5_VLMOED2
					nTxMoeda := SE5->E5_VALOR / SE5->E5_VLMOED2
				Else
					nTxMoeda := RecMoeda(SE5->E5_DATA,SE2->E2_MOEDA)
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Caso moeda == 1 a funcao RecMoeda iguala nTxMoeda = 0. Iguala-se   ³
				//³nTxMoeda = 1 p/ evitar problema c/ calculos de abatimento e outros.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				
				/* GESTAO - inicio */
				cFilAnt := SE2->E2_FILORIG
				/* GESTAO - fim */
				
				nTxMoeda := IIF(nTxMoeda == 0 , 1 , nTxMoeda)
				DbSelectArea("SE2")
				DbSetOrder(1)
				MsSeek(xFilial("SE2") + cDadosSE2)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Gera backup dos valores da baixa (para cancelamento baixa parcial)³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nSe2ValLiq  := SE2->E2_VALLIQ
				nSe2Descont := SE2->E2_DESCONT
				nSe2Juros   := SE2->E2_JUROS
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Grava novos valores do cancelamento da baixa parcial              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				RecLock("SE2")
				SE2->E2_VALLIQ  := nValPag
				SE2->E2_DESCONT := nDescont
				SE2->E2_JUROS   := nJuros
				MsUnlock()
				DbSetOrder(1)

				If SE2->E2_MOEDA > 1				
	            	nTotAbat := nTotAbat * NoRound(nTxMoeda,5)
	   			Endif
	   		
				ABATIMENTO 		 := nTotAbat
				
				/* GESTAO - inicio
				Atualiza o saldo dos fornecedores */
				DbSelectArea("SA2")
				DbSetOrder(1)
				If MsSeek(xFilial("SA2")+SE2->(E2_FORNECE+E2_LOJA))
					RecLock( "SA2" )
					If SE2->E2_MOEDA > 1
						If(cValPadrao == "U")
							nValPadrao := 0
						endif	
											
						nValPag := Round(NoRound(xMoeda(nValPadrao,1,SE2->E2_MOEDA,dDataBase,3),3),2)
						nValPag := Round(NoRound(xMoeda(nValPadrao,SE2->E2_MOEDA,1,SE2->E2_EMISSAO,3),3),2)
					Endif
					IF SE2->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG
						SA2->A2_SALDUP  += nValPag
						SA2->A2_SALDUPM += xMoeda(nValPag,1,nMoedaCus,SE2->E2_EMISSAO)
      				Else
						SA2->A2_SALDUP  += nValPag
						SA2->A2_SALDUPM += xMoeda(nValPag,1,nMoedaCus,SE2->E2_EMISSAO)
					Endif
					MsUnlock()
					
					If (nValPag == 0) //atualiza a variável com a o valor real de pagto para que volte o status real do título na SE2. 
						nValPag  := SE5->E5_VALOR
					EndIf					
				Endif
				/* GESTAO - fim */
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Gera lan‡amento contabil de estorno                               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				
				/* GESTAO - inicio */
				cFilAnt := cFilialAtu
				/* GESTAO - fim */
				
				cPadrao:="531"    //cancelamento de baixa
				lPadrao:=VerPadrao(cPadrao)
								
				DbSelectArea("SE2")
				If !lHeadProva .and. lPadrao
					nHdlPrv := HeadProva( cLote,;
					                      "FINA565",;
					                      Substr( cUsuario, 7, 6 ),;
					                      @cArquivo )

					lHeadProva := .T.
				EndIf
				If lPadrao .and. lCtBaixa
					nTotal += DetProva( nHdlPrv,;
					                    cPadrao,;
					                    "FINA565",;
					                    cLote,;
					                    /*nLinha*/,;
					                    /*lExecuta*/,;
					                    /*cCriterio*/,;
					                    /*lRateio*/,;
					                    /*cChaveBusca*/,;
					                    /*aCT5*/,;
					                    /*lPosiciona*/,;
					                    @aFlagCTB,;
					                    /*aTabRecOri*/,;
					                    /*aDadosProva*/ )
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Grava valores anteriores da contabilizacao do canc da baixa parcial³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				
				/* GESTAO - inicio */
				cFilAnt := SE2->E2_FILORIG
				/* GESTAO - fim */
				
				RecLock("SE2")
				SE2->E2_VALLIQ  := nSE2ValLiq
				SE2->E2_DESCONT := nSe2Descont
				SE2->E2_JUROS   := nSe2Juros
				MsUnlock()
				DbSetOrder(1)

				nSalvRec := Recno()
				
				If lAtuSldNat
					AtuSldNat(SE2->E2_NATUREZ, SE2->E2_VENCREA, SE2->E2_MOEDA, "2", "P", SE2->E2_VALOR,SE2->E2_VLCRUZ, "+",,FunName(),"SE2",SE2->(Recno()),0)
				Endif
		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se h  abatimentos para voltar a carteira                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nTotAbat > 0 .and. SE2->E2_SALDO == 0
					SE2->(DbSetOrder(6))
					If MsSeek(xFilial("SE2")+SE2->(E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+SE2->E2_PARCELA))
						cTitAnt := SE2->(E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+SE2->E2_PARCELA)
						While !Eof() .and. cTitAnt == SE2->(E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+SE2->E2_PARCELA)
							If !(SE2->E2_TIPO $ MVABATIM)
								dbSkip()
								Loop
							Endif
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Volta t¡tulo para carteira                                       ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							Reclock("SE2", .F.)
							SE2->E2_BAIXA   := Ctod(" /  /  ")
							SE2->E2_SALDO	 := SE2->E2_VALOR
							SE2->E2_DESCONT := 0
							SE2->E2_JUROS   := 0
							SE2->E2_MULTA   := 0
							SE2->E2_CORREC  := 0
							SE2->E2_VALLIQ  := 0
							SE2->E2_LOTE    := Space(Len(E2_LOTE))
							SE2->E2_STATUS  := "A"
							msUnLock()
							If lAtuSldNat
								AtuSldNat(SE2->E2_NATUREZ, SE2->E2_VENCREA, SE2->E2_MOEDA, "2", "P", SE2->E2_VALOR,SE2->E2_VLCRUZ, "-",,FunName(),"SE2",SE2->(Recno()),0)
							Endif
							dbSkip()
						End
					Endif
					SE2->(DbSetOrder(1))
				Endif
				dbGoTo( nSalvRec )

				IF SE2->E2_MOEDA == 1
					nValor := SE2->E2_SALDO+(nValPag-nJuros+nDescont+IIF(SE2->E2_SALDO==0,nTotAbat,0))
				Else					
					nValor := SE2->E2_SALDO+((nValPag-nJuros+nDescont+IIF(SE2->E2_SALDO==0,nTotAbat,0)) / nTxMoeda)
					//Corrige possiveis erros de arredondamento
					If ABS(Round(SE2->E2_VALOR - nValor,2)) == 0.01         
						nValor := SE2->E2_VALOR
					Endif
				Endif

				RecLock("SE2",.F.)
				SE2->E2_SALDO	  := nValor
				SE2->E2_MOVIMEN  := dDataBase
				SE2->E2_TIPOLIQ  := Space(3)
				If lAcreDecre
					SE2->E2_SDACRES  := Round(NoRound(xMoeda(nAcresc,1,SE2->E2_MOEDA,SE5->E5_DATA,3,nTxMoeda),3),2)
					SE2->E2_SDDECRE  := Round(NoRound(xMoeda(nDecresc,1,SE2->E2_MOEDA,SE5->E5_DATA,3,nTxMoeda),3),2)
				Else
					SE2->E2_SDACRES  := SE2->E2_ACRESC 
					SE2->E2_SDDECRE  := SE2->E2_DECRESC		
				Endif
				SE2->E2_STATUS	  := "A"
				IF STR(SE2->E2_SALDO,17,2) == STR(SE2->E2_VALOR,17,2)
					SE2->E2_VALLIQ	:= 0				
					SE2->E2_BAIXA	  := Ctod("//")
				Endif
				MsUnlock()

				// Cancelamento do rastreamento(FI7/FI8)
				FINRSTDEL("SE2",cDadosSe5,,aDadosSE5, SE2->E2_FILORIG)				          

			ElseIf (SE2->E2_NUMLIQ = cLiqCan 	.or. ;
					SE2->E2_TIPO $ MV_CPNEG)	.and.;
					SE2->E2_STATUS != "R"
				
				/* GESTAO - inicio */
				cFilAnt := cFilialAtu
				DbSelectArea("SA2")
				DbSetOrder(1)
				If MsSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA)
					RecLock( "SA2" )
					If (SE2->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG+"/"+MVABATIM)
						SA2->A2_SALDUP  += Round(NoRound(xMoeda(SE2->E2_SALDO,SE2->E2_MOEDA,1,SE2->E2_EMISSAO,3),3),2)
						SA2->A2_SALDUPM += Round(NoRound(xMoeda(SE2->E2_SALDO,SE2->E2_MOEDA,nMoedaCus,SE2->E2_EMISSAO,3),3),2)
					Else
						SA2->A2_SALDUP  -= Round(NoRound(xMoeda(SE2->E2_SALDO,SE2->E2_MOEDA,1,SE2->E2_EMISSAO,3),3),2)
						SA2->A2_SALDUPM -= Round(NoRound(xMoeda(SE2->E2_SALDO,SE2->E2_MOEDA,nMoedaCus,SE2->E2_EMISSAO,3),3),2)
					EndIf
					MsUnlock()
				Endif
				/* GESTAO - fim */
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Se for uma parcela da liquidacao contabiliza o    ³
				//³ cancelamento e deleta.                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cPadrao := "515"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Posiciona o SE2 pois o arquivo de trabalgo pode ser resul-³
				//³ tado de uma Query.                                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("SE2")
				DbSetOrder(1)
				MsSeek(xFilial("SE2") + cDadosSE2)

				lContabilizou := Iif(SubStr(SE2->E2_LA,1,1)=="S",.T.,.F.)
				If !lHeadProva .and. lPadraoE2
					nHdlPrv := HeadProva( cLote,;
					                      "FINA565",;
					                      Substr( cUsuario, 7, 6 ),;
					                      @cArquivo )

					lHeadProva := .T.
				EndIf
				If lPadraoE2 .and. lContabilizou
					nTotal += DetProva( nHdlPrv,;
					                    cPadrao,;
					                    "FINA565",;
					                    cLote,;
					                    /*nLinha*/,;
					                    /*lExecuta*/,;
					                    /*cCriterio*/,;
					                    /*lRateio*/,;
					                    /*cChaveBusca*/,;
					                    /*aCT5*/,;
					                    /*lPosiciona*/,;
					                    @aFlagCTB,;
					                    /*aTabRecOri*/,;
					                    /*aDadosProva*/ )
				EndIf

				If lFin565e2
					Execblock("FIN565E2",.F.,.F.)
				Endif
            
	            If lAtuSldNat
					AtuSldNat(SE2->E2_NATUREZ, SE2->E2_VENCREA, SE2->E2_MOEDA, "2", "P", SE2->E2_VALOR,SE2->E2_VLCRUZ, "-",,FunName(),"SE2",SE2->(Recno()),0)
				Endif
				//apaga documentos
				If SE2->( FieldPos( "E2_TEMDOCS" ) ) > 0 .AND. SE2->E2_TEMDOCS == "1" .AND. FindFunction( "CN062ApagDocs" )
					CN062ApagDocs()
				EndIf
				
				DbSetOrder(1)
				RecLock("SE2",.F.)
				DbDelete()
				MsUnlock()

			EndIf
			cFilAnt := cFilialAtu
		End
		/* GESTAO - inicio */
		cFilAnt := cFilialAtu
		/* GESTAO - fim */
		If nTotal > 0
			RodaProva(  nHdlPrv,;
						nTotal )
						
			lDigita	:=IIF(mv_par02==1,.T.,.F.)
			lAglutina:=IIF(mv_par03==1,.T.,.F.)
			cA100Incl( cArquivo,;
			           nHdlPrv,;
			           3,;
			           cLote,;
			           lDigita,;
			           lAglutina,;
			           /*cOnLine*/,;
			           /*dData*/,;
			           /*dReproc*/,;
			           @aFlagCTB,;
			           /*aDadosProva*/,;
			           aDiario )
			aFlagCTB := {}  // Limpa o coteudo apos a efetivacao do lancamento
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Volta Ultimo Numero do Parametro de Liquidacao          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cNewLiq := GetMV("MV_NUMLIQP")
		If cNewLiq == cLiqCan
			PUTMV("MV_NUMLIQP",Tira1(SUBSTR(cNewLiq,1,6)))
		EndIf
		
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a area do SE2                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Select("TRB") > 0
	DbSelectArea("TRB")
	DbCloseArea()
Endif

DbSelectArea("SE2")
RetIndex("SE2")
Set Filter to

DbSelectArea("SE2")
DbSetOrder(nOrdemSE2)
DbGoToP()
fErase (cIndex+OrdBagExt())
cIndex := ""

Return (.T.)
