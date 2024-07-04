#include "ctba277.ch"
#include "protheus.ch"

// 17/08/2009 -- Filial com mais de 2 caracteres

Static aCodRat := Nil
Static nTamCod := Nil
Static aCodCTQ := Nil
STATIC __cCodCTQ	:= ''	      
//AMARRACAO PARA BOLETIM TECNICO - FNC: 00000005765-2008-912 
//AMARRACAO PARA BOLETIM TECNICO - FNC: 00000029121-2010
     
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Ctba277 ³ Autor ³ Eduardo Nunes Cirqueira ³ Data ³ 19/07/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Cadastramento de Amarracoes de Grupos de Rateios            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB - Manutenção de Rateios Off-Line                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctba277()

Local aCampos 		:= {}
Local aCores  		:= {}

Private cAlias	  := "CW2"
Private cCadastro := STR0001 								//	"Amarracao de Grupos de Rateios"
Private lCTQ_MSBLQL	:= IIF(CTQ->(FieldPos("CTQ_MSBLQL")) > 0,.T.,.F.)
Private lCTQ_STATUS  := IIF(CTQ->(FieldPos("CTQ_STATUS")) > 0,.T.,.F.)

Private aRotina   := MenuDef()

If ! lCTQ_STATUS
	ShowHelpDlg("CTQSTATUS", {STR0045,STR0046},5,{STR0047,STR0048},5)   //"O campo CTQ_STATUS não está disponível "##"no dicionário de dados."}##{"Executar o compatibilizador UPDCTB com "##"data igual ou superior a 28/07/2008"
	Return
EndIf

AADD(aCores,{"CW2_STATUS == '1'","BR_BRANCO"}) 	  //Pendente
AADD(aCores,{"CW2_STATUS == '2'","BR_AMARELO"})  //Alterado
AADD(aCores,{"CW2_STATUS == '3'","BR_VERDE"})    //Gerado
AADD(aCores,{"CW2_STATUS == '4'","BR_PRETO"})    //Bloqueado

DbSelectArea(cAlias)
DbSetOrder(1)
mBrowse(6,1,22,75,cAlias,aCampos,,,,,aCores)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Ctb277LEGº Autor ³ Arnaldo R. Junior  º Data ³  19/07/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Legenda para o cadastro de amarracao de grupos de rateio   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CONTABILIDADE GERENCIAL - MANUTENCAO DE RATEIOS OFF-LINE   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ctb277LEG()

Local aLegenda	:= 	{}

AADD(aLegenda,{"BR_BRANCO"	   , STR0016})		//	"Pendente"
AADD(aLegenda,{"BR_AMARELO"	, STR0017})		//	"Alterado"
AADD(aLegenda,{"BR_VERDE"		, STR0018})		//	"Gerado"
AADD(aLegenda,{"BR_PRETO"  	, STR0044})		//	"Bloqueado"

BrwLegenda(cCadastro, STR0008, aLegenda)

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Ctb277PES³ Autor ³ Claudio D. de Souza   ³ Data ³ 01/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Pesquisa com filtro                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTB277PES()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA277                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb277Pes()
AxPesqui()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ Ctb277Cad ³ Autor ³ Eduardo Nunes Cirqueira ³ Data ³ 19/07/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Programa de inclusao de Grupos de Rateios                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Ctb277Cad(cAlias,nReg,nOpc)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias = Alias do arquivo                                     ³±±
±±³          ³ nReg   = Numero do registro                                   ³±±
±±³          ³ nOpc  = Opcao selecionada                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ctba277                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb277Cad(cAlias,nReg,nOpc)

Local aSaveArea  := GetArea()
Local nOpca		 := 0
Local i
Local lAlterou   := .F.
Local cAmarra
Local aCamposCW2 := CW2->( DbStruct() )
Local aAltera    := {}

Private _lCW2_ORICOMB := .F.
Private _lCW2_DSTCOMB := .F.

dbSelectArea("CW2")
dbSetOrder(1)                                        

If nOpc == 3		//	Inclusao
	nOpca := AxInclui(cAlias, nReg, nOpc,,,, "Ctb277TOk()")

ElseIf nOpc == 4	//	Alteracao
	// Guardando o conteudo dos campos antes da tela de Alteracao
	For i := 1 to Len(aCamposCW2)
		Aadd( aAltera,CW2->&(aCamposCW2[i][1]) )
	Next
	
	nOpca := AxAltera(cAlias, nReg, nOpc,,,,,"Ctb277TOk()",,,,,,.T.)

	If nOpca == 1	//	Botao OK na Alteracao
	
		// Se o Status da Amarracao esta como 3-Gerado		
		If CW2->CW2_STATUS <> "2"

			// Verficando se o usuario alterou algum campo
			For i := 1 to Len(aCamposCW2)
				lAlterou := ( CW2->&(aCamposCW2[i][1]) <> aAltera[i] )
				If lAlterou
					Exit
				EndIf
			Next
			
			// Se alterou, mudar o Status para "2-Alterado"
			If lAlterou
				RecLock("CW2",.F.)
				CW2->CW2_STATUS := "2"		//	Amarracao Alterada
				CW2->( MsUnlock() )
			EndIf
		EndIf
	EndIf
		
ElseIf nOpc == 5	//	Exclusao
	cAmarra := CW2->CW2_CODIGO
	If MsgYesNo(STR0009+STR0010)	//	"Deseja excluir os Rateios gerados a partir desta Amarracao?"
		nOpca := AxDeleta(cAlias, nReg, nOpc)
		If nOpca == 2	//	Confirmou a Exclusao
			MsgRun(STR0040,STR0041,{|| Ctb277DelCTQ(cAmarra)}) //"Excluindo rateios off-lines vinculados..."#"Exclusão de rateios off-line"
		EndIf
	EndIf
EndIf

RestArea(aSaveArea)

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³Ctb277GerCTQ³ Autor ³ Eduardo Nunes Cirqueira ³ Data ³ 19/07/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Funcao para Geracao dos Rateios                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Ctb277GerCTQ(cAlias,nReg,nOpc)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias = Alias do arquivo                                      ³±±
±±³          ³ nReg   = Numero do registro                                    ³±±
±±³          ³ nOpc   = Opcao selecionada                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ctba277                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb277GerCTQ(lDireto,aParam)

Local nX		:= 0

Default lDireto := .F.
Default aParam	:= {}

//CONOUTR("PONTO 00: INICIANDO PROCESSO DE GERACAO DE RATEIOS | ",.F.,"CTBA277")
IF ValType(nTamCod) == "U"
	nTamCod := TAMSX3("CTQ_RATEIO")[1]
Endif

IF lDireto
	Pergunte("CTB277",.F.)	
	For nX := 1 to Len(aParam)
		&("MV_PAR"+STRZERO(nX,2)) := aParam[nX]
	Next nX
	lPergunte := .T.
ELSE
	lPergunte := Pergunte("CTB277",.T.)
ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros						³
//³ mv_par01		// Amarracao Inicial                        ³
//³ mv_par02		// Amarracao Final        				 	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

IF lPergunte .And. IIF(!lDireto,MsgYesNo(STR0011),.T.)	// "Confirma geracao dos Rateios Off-Line?"	

	// Tratamento para abrir o CTQ de forma exclusiva
	// Devido a reserva de códigos de rateio
	IF !MA280FLock("CTQ")
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Fecha CTQ e reabre de forma compartilhada   ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("CTQ")
		dbCloseArea()
		DbSelectArea("CTQ")
		Return .T.

	ELSE

		MsgRun(STR0042, STR0043,{|| Ctb277PrcCTQ()}) //"Recriando rateios com base nos cadastros de amarrações..."#"Atualizando cadastro de rateios off-line"
		DbSelectArea("CTQ")
		dbCloseArea()
		DbSelectArea("CTQ")

	ENDIF

ENDIF  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada para Gravação de Dados Adicionais                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 If ExistBlock("CT77GRV")
	ExecBlock("CT77GRV",.F.,.F.)
 Endif

//CONOUTR("PONTO 00: FINALIZADO PROCESSO DE GERACAO DE RATEIOS | ",.F.,"CTBA277")
RETURN .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Ctb277PrcCTQ³ Autor ³ ARNALDO RAYMUNDO JR.  ³ Data ³ 21/07/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualizacao do cadastro de rateios off-line conforme a para- ³±±
±±³          ³ metrizacao do cadastro de amarracoes.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA277                      								³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ctb277PrcCTQ()

Local aSaveArea 	:= GetArea()
Local cFilCTQ		:= xFilial("CTQ")
Local aStruCTQ		:= CTQ->(DbStruct())
Local aPrefCTQ		:= {"CT","CC","IT","CL"}

Local aOrigem		:= {}
Local aDestino		:= {}
Local aRateios  	:= {}

Local lPergunte 	:= .F.
Local lInclui   	:= .T.
Local lAchouAm  	:= .F.

Local cProxRat  	:= ""
Local cCodCTQ		:= ""

Local nOrigem		:= 0
Local nDestino		:= 0
Local lUsaFormula 	:= .F.
Local lUsaFator		:= .F.
Local nX			:= 0
Local nTamCTQ		:= TAMSX3("CTQ_RATEIO")[1]
Local bBlock
Local xResult
Local cMV_CTBHRAT := CT270HRAT()

CTB277ADDCOD()

// Pegando o ultimo codigo utilizado para o caso de precisar incluir um novo
CTQ->(DbGoBottom())
cProxRat := CTQ->CTQ_RATEIO
CTQ->( DbSetOrder(2) )	//	"CTQ_FILIAL + CTQ_AMARRA + CTQ_RATEIO + CTQ_SEQUEN"

dbSelectArea("CW1")
dbSetOrder(1)

dbSelectArea("CW2")
dbSetOrder(1)

CW2->( DbSeek(xFilial("CW2")+mv_par01+"1",.T.) )

While !CW2->(Eof()) 						.And.;
       CW2->CW2_FILIAL == xFilial("CW2")	.And.;
       CW2->CW2_CODIGO <= mv_par02

	// Gerar Rateios somente para amarracoes com Status "1-Pendente" ou "2-Alterada"
	If (MV_PAR03 == 1 .AND. !(CW2->CW2_STATUS $ "12")) .OR. CW2->CW2_STATUS == "4"
		CW2->(DbSkip())
		Loop	
	EndIf

	aOrigem   := {}
	aDestino  := {}
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o array com a combinação das entidades para origem dos saldos do CTQ	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    Ctb277COMBINA(@aOrigem,1)
	
	If Len( aOrigem ) > 0
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta o array com a combinação das entidades para destino dos saldos do CTQ	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Ctb277COMBINA(@aDestino,2)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicia controle de transacao para o processamento            	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BEGIN TRANSACTION
		If Len( aDestino ) > 0
			
			// Verificando se já existe Rateio para esta amarracao. Se existir, excluir para gerar novo.
			// Utilizara os mesmos codigos
			CTQ->( DbSeek(cFilCTQ+CW2->CW2_CODIGO) )
			While !CTQ->(EOF()) .And. CTQ->CTQ_FILIAL == xFilial("CTQ") .And. CTQ->CTQ_AMARRA == CW2->CW2_CODIGO
				
				If Len(aRateios) == 0
	
					Aadd( aRateios,{CTQ->CTQ_RATEIO,CTQ->CTQ_DESC,CTQ->CTQ_TIPO} )
				ElseIf 	Ascan( aRateios,{|x| x[1] == CTQ->CTQ_RATEIO } ) == 0
	
					Aadd( aRateios,{CTQ->CTQ_RATEIO,CTQ->CTQ_DESC,CTQ->CTQ_TIPO} )
					// Atualizando Historico de Rateio (CV9)
					If cMV_CTBHRAT != "0" 
						CtbHistRat( CTQ->CTQ_RATEIO,,,,, "CTBA277", "CTQ" )
					Endif
				EndIf

				RecLock("CTQ",.F.)
				CTQ->(DbDelete())
				CTQ->(MsUnLock())
				CTQ->(DbSkip())

			EndDo

			// A cada linha do Grupo de Origem juntar todas as linhas do Grupo de Destino, formando assim,
			// um novo Rateio Off-Line
			//CONOUTR("PONTO 01: INICIANDO PROCESSO DE GRAVACAO DE RATEIOS | ",.F.,"CTBA277")
			
			For nOrigem := 1 to Len(aOrigem)
				
				//CONOUTR("PONTO 02: GRAVANDO RATEIOS PARA ORIGEM "+STRZERO(nOrigem,6)+"-"+STRZERO(Len(aOrigem),6),.F.,"CTBA277")
				
				If nOrigem <= Len(aRateios)
					
					cProxRat := aRateios[nOrigem,1]

					// Garante que o codigo não está em uso, devido a alteracao na estrutura dos grupos.
					CTQ->( DbSetOrder(1) )
					While CTQ->( DbSeek(cFilCTQ+cProxRat) )
						cProxRat := CT277Soma1(CTQ->CTQ_RATEIO,.F.)
					EndDo
					CTQ->( DbSetOrder(2) )
				Else
					// Procurando um codigo ainda nao utilizado para o rateio
					cProxRat := CT277Soma1(cProxRat,.F.)
					CTQ->( DbSetOrder(1) )
					While CTQ->( DbSeek(cFilCTQ+cProxRat) )
						cProxRat := CT277Soma1(CTQ->CTQ_RATEIO,.F.)
					EndDo
					CTQ->( DbSetOrder(2) )
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Controle da utilizacao de formula para o fator do CTQ (CW2_FORMUL)         	³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				lUsaFormula  := .F.
				lUsaFator	 := .F.
				cCodCTQ		 := ""
				
				For nDestino := 1 to Len(aDestino)

					//CONOUTR("PONTO 03: GRAVANDO LINHA DE DETALHE DE RATEIO: "+STRZERO(nDestino,6)+"-"+STRZERO(Len(aDestino),6)+" | ",.F.,"CTBA277")
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza primeiro o ALIAS M-> para ter os campos disponiveis para formulas 	³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					RegToMemory("CTQ",.T.)

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza os campos de cabeçalho neste ponto para disponibilizar as informações  ³
					//³ para uso nas fórmulas. Como o codigo do rateio pode possuir formulas, ele será  |
					//³	tratado juntamente com os demais campos de formulas								|
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

					M->CTQ_FILIAL 	:= cFilCTQ
					M->CTQ_SEQUEN 	:= StrZero(nDestino,3)
					M->CTQ_PERBAS 	:= aOrigem[nOrigem,5]
                        
					M->CTQ_AMARRA 	:= CW2->CW2_CODIGO
					M->CTQ_TIPO		:= CW2->CW2_TIPO
					M->CTQ_INTERC	:= CW2->CW2_INTERC
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Inicialmente gera o rateio como não bloqueado                	³
					//³ Status será atualizado na validacao do percentual do rateio		³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					M->CTQ_STATUS	:= "1"
					M->CTQ_MSBLQL	:= "2" 

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Apesar da funcao Ctb277COMBINA ser utilizada tanto para array   ³
					//³ de origem quanto para destino, nao foi disponibilizada a opcao  ³
					//³ de formula para os campos de origens.                          	³
					//³ M->CTQ_xxORI -> aOrigem[x,y]                                   	³						
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nX := 1 to Len(aPrefCTQ)
						&("M->CTQ_"+aPrefCTQ[nX]+"ORI")  	:= aOrigem[nOrigem,nX]
					Next nX

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza campos de partida com base na formula do campo      	³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					//M->CTQ_CTPAR  	:= &(CW2->CW2_CT1PAR)
					IF !EMPTY(CW2->CW2_CT1PAR)	.AND. ExistCpo('CT1',CW2->CW2_CT1PAR,1,,.F.)
						M->CTQ_CTPAR := CW2->CW2_CT1PAR
					ELSEIF !EMPTY(CW2->CW2_CT1PAF) 
						bBlock := ErrorBlock( { |e| ChecErro(e) } )
						BEGIN SEQUENCE
							xResult := &(CW2->CW2_CT1PAF)
						RECOVER
							xResult := ""
						END SEQUENCE
						ErrorBlock(bBlock)
			   			M->CTQ_CTPAR := IIF(ValType(xResult) == "C",xResult,"")
			   		ELSE
			   			M->CTQ_CTPAR := ""
			   		ENDIF
		
					//M->CTQ_CCPAR  	:= &(CW2->CW2_CTTPAR)
					IF !EMPTY(CW2->CW2_CTTPAR) .AND. ExistCpo('CTT',CW2->CW2_CTTPAR,1,,.F.)
						M->CTQ_CCPAR := CW2->CW2_CTTPAR
					ELSEIF !EMPTY (CW2->CW2_CTTPAF)												
						bBlock := ErrorBlock( { |e| ChecErro(e) } )
						BEGIN SEQUENCE
							xResult := &(CW2->CW2_CTTPAF)
						RECOVER
							xResult := ""
						END SEQUENCE
						ErrorBlock(bBlock)
						M->CTQ_CCPAR := IIF(ValType(xResult) == "C",xResult,"")
                    ELSE
			   			M->CTQ_CCPAR := ""
			   		ENDIF
                    
                    //M->CTQ_ITPAR  	:= &(CW2->CW2_CTDPAR)
					IF !EMPTY(CW2->CW2_CTDPAR) .AND. ExistCpo('CTD',CW2->CW2_CTDPAR,1,,.F.)
						M->CTQ_ITPAR := CW2->CW2_CTDPAR
					ELSEIF !EMPTY (CW2->CW2_CTDPAF)												
						bBlock := ErrorBlock( { |e| ChecErro(e) } )
						BEGIN SEQUENCE
							xResult := &(CW2->CW2_CTDPAF)
						RECOVER
							xResult := ""
						END SEQUENCE
						ErrorBlock(bBlock)
						M->CTQ_ITPAR := IIF(ValType(xResult) == "C",xResult,"")
					ELSE                
						M->CTQ_ITPAR := ""
					ENDIF

					//M->CTQ_CLPAR  	:= &(CW2->CW2_CTHPAR)
					IF !EMPTY(CW2->CW2_CTHPAR) .AND. ExistCpo('CTH',CW2->CW2_CTHPAR,1,,.F.)
						M->CTQ_CLPAR := CW2->CW2_CTHPAR
					ELSEIF !EMPTY (CW2->CW2_CTHPAF)												
						bBlock := ErrorBlock( { |e| ChecErro(e) } )
						BEGIN SEQUENCE
							xResult := &(CW2->CW2_CTHPAF)
						RECOVER
							xResult := ""
						END SEQUENCE
						ErrorBlock(bBlock)
						M->CTQ_CLPAR := IIF(ValType(xResult) == "C",xResult,"")
					ELSE                
						M->CTQ_CLPAR := ""
					ENDIF
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza campos de destino com base na formula do campo      	³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nX := 1 to Len(aPrefCTQ)
						IF aDestino[nDestino][nX] == "FORMULA"
							
							//&("M->CTQ_"+aPrefCTQ[nX]+"CPAR") 	:= &(aDestino[nDestino][7][nX])
							bBlock := ErrorBlock( { |e| ChecErro(e) } )
							BEGIN SEQUENCE
								xResult := &(aDestino[nDestino][7][nX])
							RECOVER
								xResult := ""
							END SEQUENCE
							ErrorBlock(bBlock)
							&("M->CTQ_"+aPrefCTQ[nX]+"CPAR")	:= IIF(ValType(xResult) == "C",xResult,"")
							
						ELSE
							&("M->CTQ_"+aPrefCTQ[nX]+"CPAR") 	:= aDestino[nDestino,nX]
						ENDIF
					Next nX

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza campos de controle da linha de destino do rateio    	³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					M->CTQ_PERCEN 	:= aDestino[nDestino,5]
					
					IF CTQ->(FieldPos("CTQ_FORMUL")) > 0
						M->CTQ_FORMUL	:= CW2->CW2_FORMUL
					ENDIF

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza fatores com base na formula da linha do rateio      	³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					IF !EMPTY(CW2->CW2_FORMUL)
						M->CTQ_VALOR	:= Ctb277CalcF(CW2->CW2_FORMUL)
						lUsaFormula		:= .T.
					ELSE
						M->CTQ_VALOR	:= aDestino[nDestino,6]
						lUsaFator 		:= IIF(M->CTQ_VALOR > 0,.T.,lUsaFator)
					ENDIF

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Trata o codigo do rateio neste ponto para permitir consultar demais campos      ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					
					//CONOUTR("PONTO 04: AVALIAR CODIGO DO RATEIO: "+STRZERO(nDestino,6)+"-"+STRZERO(Len(aDestino),6),.F.,"CTBA277")
					
					IF EMPTY(cCodCTQ)
					
						//CONOUTR("PONTO 04.1: GERANDO CODIGO DO RATEIO: "+STRZERO(nDestino,6)+"-"+STRZERO(Len(aDestino),6),.F.,"CTBA277")
					
						IF EMPTY(CW2->CW2_CODCTQ)
							cCodCTQ := cProxRat
						ELSE

							bBlock := ErrorBlock( { |e| ChecErro(e) } )
							BEGIN SEQUENCE
								xResult := &(CW2->CW2_CODCTQ)
							RECOVER
								xResult := ""
							END SEQUENCE
							ErrorBlock(bBlock)
							cCodCTQ := IIF(ValType(xResult) == "C",xResult,"")

							IF LEN(ALLTRIM(cCodCTQ)) > nTamCTQ
								cCodCTQ := cProxRat
							ELSE
								cCodCTQ := CTB277VlCod(@cProxRat,cCodCTQ)
							ENDIF
						
						ENDIF
						M->CTQ_RATEIO 	:= cCodCTQ
					ELSE
						M->CTQ_RATEIO 	:= cCodCTQ
					ENDIF

					//CONOUTR("PONTO 04: DEFINIDO CODIGO DO RATEIO: "+STRZERO(nDestino,6)+"-"+STRZERO(Len(aDestino),6),.F.,"CTBA277")

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza descricao do rateio neste ponto para permitir consultar demais campos  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					//M->CTQ_DESC   	:= &(CW2->CW2_DSCCTQ)
					bBlock := ErrorBlock( { |e| ChecErro(e) } )
					BEGIN SEQUENCE
						xResult := &(CW2->CW2_DSCCTQ)
					RECOVER
						xResult := ""
					END SEQUENCE
					ErrorBlock(bBlock)
					M->CTQ_DESC := IIF(ValType(xResult) == "C",xResult,"")

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza o arquivo CTQ com as variaveis de memoria           	³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					RecLock("CTQ",.T.)						
						For nX := 1 to Len(aStruCTQ)
							CTQ->&(aStruCTQ[nX][1]) := M->&(aStruCTQ[nX][1])
						Next nX						
					CTQ->(MsUnLock())

					//CONOUTR("PONTO 03: TERMINO LINHA DE DETALHE DE RATEIO: "+STRZERO(nDestino,6)+"-"+STRZERO(Len(aDestino),6),.F.,"CTBA277")
				Next
		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza percentuaus com base na formula de fator da linha do rateio          ³
				//³ Somente se atualizado por formula, pois a Ctb277COMBINA ja efetua o tratamento³
				//³ pelos arrays                                                                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				IF lUsaFormula .OR. lUsaFator
					Ct270CTQPer(cFilCTQ, "CTQ", cCodCTQ)
				ENDIF

			Next
		
			//CONOUTR("PONTO 01: FINALIZADO PROCESSO DE GRAVACAO DE RATEIOS | ",.F.,"CTBA277")
		
		Endif

		// Atualizando o Status da Amarracao para 3-Gerado
		RecLock("CW2",.F.)
		CW2->CW2_STATUS := "3"	//	3-Gerado
		CW2->(MsUnLock())
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Finaliza controle de transacao para o processamento          	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		END TRANSACTION
		
	EndIf

	CW2->(DbSkip())

EndDo

dbSelectArea("CTQ")
DbClearFilter()
DbSetOrder(1)
__cCodCTQ	:= ''

RestArea(aSaveArea)
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Ctb277TOK ³ Autor ³ Eduardo Nunes Cirqueira ³ Data ³ 19/07/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida a Inclusao e a Alteracao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctb277TOK()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRet                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA277                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nOpc = Opcao selecionada                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb277TOk()
Local lOk 		:= .T.
Local aCposPart := {"CW2_CT1PAR","CW2_CTTPAR","CW2_CTDPAR","CW2_CTHPAR"}
Local aCposParf := {"CW2_CT1PAF","CW2_CTTPAF","CW2_CTDPAF","CW2_CTHPAF"}
Local aCposOri 	:= {"CW2_ORIGEM","CW2_CTTORI","CW2_CTDORI","CW2_CTHORI"}
Local aCposDest	:= {"CW2_DESTIN","CW2_CTTDES","CW2_CTDDES","CW2_CTHDES"}
Local aCposForm := {"CW2_CT1DEF","CW2_CTTDEF","CW2_CTDDEF","CW2_CTHDEF"}
Local cStringF	:= ""
Local cStringD	:= ""
Local nX		:= 0
Local lUsaGrpDst:= .F.
                    
// Se todas as entidades de partida estiverem em branco
For nX := 1 to Len(aCposPart)
	cStringF += &("M->"+aCposPart[nX])
Next nX
// Se todos os campos fórmula de partida estiverem em branco
For nX := 1 to Len(aCposParF)
	cStringF += &("M->"+aCposParF[nX])
Next nX
If Empty(cStringF)
	Help("CTBA277",1,"HELP","Ctb277Entid", STR0019+CRLF+STR0020	,1,0) //"Preencher ao menos uma Entidade Contábil "#"de contra-partida"
	lOk := .F.
EndIf

// Se todos os grupos e todas as formulas estiverem em branco
If lOk

	For nX := 1 to Len(aCposForm)
		cStringF += &("M->"+aCposForm[nX])
	Next nX

	For nX := 1 to Len(aCposDest)
		cStringD += &("M->"+aCposDest[nX])
	Next nX

	If Empty(cStringF+cStringD)
		Help("CTBA277",1,"HELP","Ctb277Formula", STR0021+CRLF+STR0022,1,0) //"Preencher ao menos um grupo ou uma formula "#"de destino."
		lOk := .F.
	EndIf

Endif
                                            
// Verificar na tabela CW1 se os Grupos foram informados corretamente em relacao
// ao seu Tipo (Origem e Destino)
If lOk 
	CW1->( DbSetOrder(1) )

	For nX := 1 to Len(aCposOri)
		If CW1->( DbSeek(xFilial("CW1")+&("M->"+aCposOri[nX]) )) .AND. CW1->CW1_TIPO <> "1"		//	1-Origem
			Help("CTBA277",1,"HELP","Ctb277Origem",	STR0023+CRLF+STR0024+aCposOri[nX]+STR0025,1,0) //"Grupo Origem incorreto."#"O grupo "#" é do tipo Destino."
			lOk := .F.
			Exit
		EndIf
	Next nX
	
    If lOk
		For nX := 1 to Len(aCposDest)
			IF CW1->( DbSeek(xFilial("CW1")+&("M->"+aCposDest[nX]) )) .AND. CW1->CW1_TIPO <> "2"		//	1-Destino
				Help("CTBA277",1,"HELP","Ctb277Destino", STR0026+CRLF+STR0024+aCposOri[nX]+STR0025,1,0) //"Grupo Destino incorreto."#"O grupo "#" é do tipo Destino."
				lOk := .F.
				Exit
			EndIf
		Next nX
	EndIf

EndIf

// Verificar se obrigatorio o preenchimento do campo Formula do fator de destino
// Este campo sera obrigatorio se nao forem informados grupos de destino
If lOk .AND. Empty(M->CW2_FORMUL)
	For nX := 1 to Len(aCposDest)
		IF !Empty(&("M->"+aCposDest[nX]))
			lUsaGrpDst := .T.			
			Exit
		EndIf
	Next nX
	
	If !lUsaGrpDst
		Help("CTBA277",1,"HELP","Ctb277Fator",STR0027+CRLF+STR0028,1,0) //"Necessario informar a fórmula do fator, "#"pois não foram informados grupos destino"
		lOk := .F.
	Endif                                                                                          
Endif

Return lOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ctb277DelCTQ ºAutor ³ Eduardo Nunes Cirqueira º Data ³ 06/08/07 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Apagar os rateios (CTQ) que foram gerados a partir dessa       º±±
±±º          ³ amarracao.                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA277                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cAmarra   = Codigo da Amarracao deletada                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ctb277DelCTQ(cAmarra)
Local aSaveArea := GetArea()

CTQ->( DbSetOrder(2) )
CTQ->( DbSeek(xFilial("CTQ")+cAmarra) )

While !CTQ->( EOF() ) .And. CTQ->CTQ_AMARRA == cAmarra
	RecLock("CTQ",.F.)
	CTQ->( DbDelete() )
	CTQ->( MsUnlock() )
	
	CTQ->( DbSkip() )
EndDo
CTQ->( DbSetOrder(1) )

RestArea(aSaveArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Ctb277VldGr ºAutor ³ Arnaldo Raymundo Jr.    º Data ³ 28/01/08 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida o preenchimento dos campos de grupos de rateio origem   º±±
±±º          ³ e destino.                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA277                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ctb277VldGr(cTipoCpo,cCodEnt,cOrigDest)
LOCAL aArea := GetArea()
LOCAL lRet := .T.

IF !Empty(cCodEnt)

	DO CASE
		CASE cTipoCpo == "1/5"
			cEntidade := STR0049  //"Conta contabil ou Combinado."
		CASE cTipoCpo == "2"
			cEntidade := STR0050  //"Centro de custo."
		CASE cTipoCpo == "3"
			cEntidade := STR0051  //"Item contabil."			
		CASE cTipoCpo == "4"
			cEntidade := STR0052  //"Classe de valor."
	ENDCASE

	CW1->(DbSetOrder(1))
	CW1->(MsSeek(xFilial("CW1")+cCodEnt))
	IF !(CW1->CW1_ENTID $ cTipoCpo)
		Help("CTBA277",1,"HELP","Ctb277TipoE", STR0029+CRLF+STR0030+CRLF+STR0031+cEntidade,1,0) //"O grupo de rateios informado nao possui o tipo "#"de entidade adequado para o campo."#"Selecione um grupo de rateios do tipo: "
		lRet := .F.
	ENDIF
	
	IF lRet .AND. CW1->CW1_TIPO != cOrigDest
		Help("CTBA277",1,"HELP","Ctb277TipoG", STR0032+CRLF+STR0033+CRLF+STR0034+IIF(cOrigDest=="1",STR0035,STR0036),1,0)
			//"O grupo de rateios informado nao possui o tipo "#"de entidade adequado para o campo."#"Selecione um grupo de rateios do tipo: "
			//"Origem"#"Destino"
		lRet := .F.                             
	ENDIF

	If lRet .AND. CW1->CW1_STATUS == "2"
		Help("CTBA277",1,"HELP","Ctb277Bloq",IIF(cOrigDest=="1",STR0023,STR0026)+CRLF+STR0024+CW1->CW1_CODIGO+STR0054,1,0) //"Grupo (Destino ou Origem) incorreto."#"O grupo "#" está bloqueado."
		lRet := .F.  
	EndIf
 
	// ATUALIZA AS VARIAVEIS DE CONTROLE NECESSARIAS PARA PERMITIR OU NAO O PREENCHIMENTO DOS DEMAIS CAMPOS
	// DE GRUPOS OU FORMULAS
	IF CW1->CW1_ENTID == "5" .AND. cTipoCpo == "1" // COMBINADO
		_lCW2_ORICOMB := IIF(cOrigDest != "1" ,_lCW2_ORICOMB, .T.)
		_lCW2_DSTCOMB := IIF(cOrigDest != "2" ,_lCW2_DSTCOMB, .T.)
	ELSEIF CW1->CW1_ENTID == "1" .AND. cTipoCpo == "1" // SIMPLES
		_lCW2_ORICOMB := IIF(cOrigDest != "1" ,_lCW2_ORICOMB, .F.)
		_lCW2_DSTCOMB := IIF(cOrigDest != "2" ,_lCW2_DSTCOMB, .F.)
	ENDIF

ENDIF

RestArea(aArea)
RETURN lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ctb277CombinaºAutor ³ Arnaldo Raymundo Jr.    º Data ³ 28/01/08 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gera o array contendo a estrutura de entidades combinadas para º±±
±±º          ³ formacao dos rateios.                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA277                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ctb277Combina(aRateios,nTipo)

LOCAL lRet 	:= .T.
LOCAL nX	:= 0
LOCAL cGrupoCW2 := ""

LOCAL aRatCT1 	:= {}
LOCAL aRatCTT  	:= {}
LOCAL aRatCTD 	:= {}
LOCAL aRatCTH  	:= {}
LOCAL aNiveis	:= {}

LOCAL aCposEnt	:= {}
LOCAL aCposForm	:= {}
LOCAL cTpEntid	:= ""

LOCAL lTemConta	:= .F.
LOCAL lTemCusto	:= .F.
LOCAL lTemItem	:= .F.
LOCAL lTemCLVL	:= .F.
LOCAL lGrupoBloq := .F.

IF nTipo == 1 // ORIGEM

	aCposEnt	:= {"CW2_ORIGEM","CW2_CTTORI","CW2_CTDORI","CW2_CTHORI"}
	aCposForm	:= {}


ELSE // DESTINO

	aCposEnt	:= {"CW2_DESTIN","CW2_CTTDES","CW2_CTDDES","CW2_CTHDES"}
	aCposForm	:= {"CW2_CT1DEF","CW2_CTTDEF","CW2_CTDDEF","CW2_CTHDEF"}

ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta os array com os itens de origem para cada grupo de entidade contabil	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

For nX := 1 to Len(aCposEnt)
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Avalia primeiro a formula antes de avaliar o cadastro de grupos             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF Len(aCposForm) > 0
		cGrupoCW2 := &("CW2->"+aCposForm[nX])
	ELSE
		cGrupoCW2 := ""
	ENDIF
	
	IF !Empty(cGrupoCW2)

		DO CASE
			                
			CASE nX == 1 // FORMULA NA CONTA CONTABIL
				cTpEntid := "1"
				Aadd( aRatCT1, {"FORMULA","","","",0,0,{cGrupoCW2,"","",""}} )
			CASE nX == 2 // FORMULA NO CENTRO DE CUSTO
				cTpEntid := "2"
				Aadd( aRatCTT, {"","FORMULA","","",0,0,{"",cGrupoCW2,"",""}} )
			CASE nX == 3 // FORMULA NO ITEM CONTABIL
				cTpEntid := "3"
				Aadd( aRatCTD, {"","","FORMULA","",0,0,{"","",cGrupoCW2,""}} )
			CASE nX == 4 // FORMULA NA CLASSE DE VALOR
				cTpEntid := "4"
				Aadd( aRatCTH, {"","","","FORMULA",0,0,{"","","",cGrupoCW2}} )
		ENDCASE	

	ELSE
	
		cGrupoCW2 := &("CW2->"+aCposEnt[nX])
		
		IF CW1->( DbSeek(xFilial("CW1")+cGrupoCW2) )
			If CW1->CW1_STATUS == "2"  
				Help("CTBA277",1,"HELP","Ctb277Bloq",STR0001+": "+CW2->CW2_CODIGO+CRLF+STR0024+cGrupoCW2+STR0054,1,0,,,,,,{STR0056}) //"Amarracao de Grupos de Rateio"# "O grupo "#" está bloqueado." #"Corrija o status do grupo na rotina CTBA276"
				lGrupoBloq := .T.
				Exit
			Else
				cTpEntid := CW1->CW1_ENTID
				
				While !CW1->(Eof()) 				.And.;
					CW1->CW1_FILIAL == xFilial("CW1")	.And.;
					CW1->CW1_CODIGO == cGrupoCW2
				
					DO CASE
																					
						CASE cTpEntid == "1" // SOMENTE CONTAS CONTABEIS
							Aadd( aRatCT1, {CW1->CW1_CONTA,"","","",CW1->CW1_PERCEN,CW1->CW1_FATOR,{"","","",""}} )
						CASE cTpEntid == "2" // SOMENTE CENTOS DE CUSTO
							Aadd( aRatCTT, {"",CW1->CW1_CCUSTO,"","",CW1->CW1_PERCEN,CW1->CW1_FATOR,{"","","",""}} )
						CASE cTpEntid == "3" // SOMENTE ITEM CONTABIL
							Aadd( aRatCTD, {"","",CW1->CW1_ITEM,"",CW1->CW1_PERCEN,CW1->CW1_FATOR,{"","","",""}} )
						CASE cTpEntid == "4" // SOMENTE CLASSE DE VALOR
							Aadd( aRatCTH, {"","","",CW1->CW1_CLVL,CW1->CW1_PERCEN,CW1->CW1_FATOR,{"","","",""}} )
						CASE cTpEntid == "5" // COMBINADO 
							Aadd( aRateios, {CW1->CW1_CONTA,CW1->CW1_CCUSTO,CW1->CW1_ITEM,CW1->CW1_CLVL,CW1->CW1_PERCEN,CW1->CW1_FATOR,{"","","",""}} )
							
					ENDCASE
					
					CW1->( DbSkip() )
				EndDo
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Caso seja a combinacao dos grupos de rateio de destino e os mesmos utilizem ³
				//³ apenas percentuais, serão gerados os fatores equivalentes.                  ³
				//| Para grupos de entidades combinadas não é necessário este tratamento		|
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				IF nTipo == 2
					DO CASE
						CASE cTpEntid == "1" .AND. Len(aRatCT1) > 0// SOMENTE CONTAS CONTABEIS
							Ctb277ConvPF(@aRatCT1)
						CASE cTpEntid == "2"  .AND. Len(aRatCTT) > 0// SOMENTE CENTOS DE CUSTO
							Ctb277ConvPF(@aRatCTT)
						CASE cTpEntid == "3"  .AND. Len(aRatCTD) > 0// SOMENTE ITEM CONTABIL
							Ctb277ConvPF(@aRatCTD)
						CASE cTpEntid == "4"  .AND. Len(aRatCTH) > 0// SOMENTE CLASSE DE VALOR
							Ctb277ConvPF(@aRatCTH)
					ENDCASE
				ENDIF
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Se for um grupo de rateio "combinado", nao considera os demais.             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				IF cTpEntid == "5"
					Exit
				ENDIF
			ENDIF
	    ENDIF

	  ENDIF
Next nX

If !lGrupoBloq
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis de controle da utilização de entidades                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lTemConta	:= Len(aRatCT1) > 0
	lTemCusto	:= Len(aRatCTT) > 0
	lTemItem	:= Len(aRatCTD) > 0
	lTemCLVL	:= Len(aRatCTH) > 0


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se for um grupo de rateio "combinado", o array aRateios ja esta montado.    ³
	//³ Caso contrario sera montada uma matriz combinando os array intermediarios.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF cTpEntid != "5" .AND. (lTemConta .OR. lTemCusto .OR. lTemItem .OR. lTemCLVL)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta primeiro nivel da origem. O Percentual base e considerado com base    ³
		//| no percentual deste nivel.													|
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF lTemConta
			AADD(aNiveis,1)	
			For nX := 1 to Len(aRatCT1)
				AADD(aRateios,{aRatCT1[nX][1],aRatCT1[nX][2],aRatCT1[nX][3],aRatCT1[nX][4],aRatCT1[nX][5],aRatCT1[nX][6],aRatCT1[nX][7]})
			Next nX
				
		ELSEIF lTemCusto
			AADD(aNiveis,2)    
			For nX := 1 to Len(aRatCTT)
				AADD(aRateios,{aRatCTT[nX][1],aRatCTT[nX][2],aRatCTT[nX][3],aRatCTT[nX][4],aRatCTT[nX][5],aRatCTT[nX][6],aRatCTT[nX][7]})
			Next nX
		
		ELSEIF lTemItem
			AADD(aNiveis,3)
			For nX := 1 to Len(aRatCTD)
				AADD(aRateios,{aRatCTD[nX][1],aRatCTD[nX][2],aRatCTD[nX][3],aRatCTD[nX][4],aRatCTD[nX][5],aRatCTD[nX][6],aRatCTD[nX][7]})
			Next nX
		
		ELSEIF lTemCLVL
			AADD(aNiveis,4)
			For nX := 1 to Len(aRatCTH)
				AADD(aRateios,{aRatCTH[nX][1],aRatCTH[nX][2],aRatCTH[nX][3],aRatCTH[nX][4],aRatCTH[nX][5],aRatCTH[nX][6],aRatCTH[nX][7]})
			Next nX
				
		ENDIF	

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta segundo nivel da origem, dependendo dos arrays disponiveis e da entida³
		//| de utilizada no primeiro nivel.												|
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DO CASE
			CASE aNiveis[1] == 1
					
				IF lTemCusto
					Ctb277Matriz(@aRateios,aRatCTT,aNiveis,1,2)
					AADD(aNiveis,2)    
				ELSEIF lTemItem
					Ctb277Matriz(@aRateios,aRatCTD,aNiveis,1,3)
					AADD(aNiveis,3)
				ELSEIF lTemCLVL
					Ctb277Matriz(@aRateios,aRatCTH,aNiveis,1,4)
					AADD(aNiveis,4)
				ELSE
					AADD(aNiveis,0) // Nao existem entidades neste nivel
				ENDIF

			CASE aNiveis[1] == 2

				IF lTemItem
					Ctb277Matriz(@aRateios,aRatCTD,aNiveis,1,3)
					AADD(aNiveis,3)
				ELSEIF lTemCLVL
					Ctb277Matriz(@aRateios,aRatCTH,aNiveis,1,4)
					AADD(aNiveis,4)
				ELSE
					AADD(aNiveis,0) // Nao existem entidades neste nivel
				ENDIF		
			
			CASE aNiveis[1] == 3
			
				IF lTemCLVL
					Ctb277Matriz(@aRateios,aRatCTH,aNiveis,1,4)
					AADD(aNiveis,4)
				ELSE
					AADD(aNiveis,0) // Nao existem entidades neste nivel
				ENDIF
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se o primeiro nivel possuir a classe de valor, o array já esta montado.     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			CASE aNiveis[1] == 4
				RETURN lRet
		ENDCASE

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta terceiro nivel da origem, dependendo dos arrays disponiveis e da      ³
		//| entidade utilizada no segundo nivel. 										|
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DO CASE
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se o segundo nivel nao possuir entidade, o array ja esta montado.           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			CASE aNiveis[2] == 2

				IF lTemItem
					Ctb277Matriz(@aRateios,aRatCTD,aNiveis,2,3)
					AADD(aNiveis,3)
				ELSEIF lTemCLVL
					Ctb277Matriz(@aRateios,aRatCTH,aNiveis,2,4)
					AADD(aNiveis,4)
				ELSE
					AADD(aNiveis,0) // Nao existem entidades neste nivel
				ENDIF

			CASE aNiveis[2] == 3

				IF lTemCLVL
					Ctb277Matriz(@aRateios,aRatCTH,aNiveis,2,4)
					AADD(aNiveis,4)
				ELSE
					AADD(aNiveis,0) // Nao existem entidades neste nivel
				ENDIF		

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se o segundo nivel possuir a classe de valor, o array ja esta montado.      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			CASE aNiveis[2] == 4
				RETURN lRet

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se o primeiro nivel possuir a classe de valor, o array já esta montado.     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			CASE aNiveis[2] == 0
				RETURN lRet
		ENDCASE

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta quarto   nivel da origem, dependendo dos arrays disponiveis e da      ³
		//| entidade utilizada no segundo nivel. 										|
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DO CASE
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se terceiro  nivel nao possuir entidade, o array ja esta montado.           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			CASE aNiveis[3] == 3

				IF lTemCLVL
					Ctb277Matriz(@aRateios,aRatCTH,aNiveis,3,4)
					AADD(aNiveis,4)
				ELSE
					AADD(aNiveis,0) // Nao existem entidades neste nivel
				ENDIF

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se o terceiro nivel possuir a classe de valor, o array já esta montado.     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			CASE aNiveis[3] == 0
				RETURN lRet
			ENDCASE

	ENDIF
Else
	aRateios := {}
ENDIF

RETURN lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ctb277ConvPF ºAutor ³ Arnaldo Raymundo Jr.    º Data ³ 28/01/08 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Converte os percentuais dos rateios para fatores, caso o array º±±
±±º          ³ possua apenas percentuais.                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA277                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ctb277ConvPF(aRateios)

Local nTotLinhas	:= 0
Local aTamSX3		:= TAMSX3("CTQ_VALOR")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o grupo de rateios utiliza fatores - posição 6 de cada linha    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF aScan(aRateios,{|aLinha| aLinha[6] != 0}) == 0
	nTotLinhas := Len(aRateios)
	aEval(aRateios, {|aLinha| aLinha[6] := Round(NoRound(nTotLinhas*(aLinha[5]/100),aTamSX3[2]+1),aTamSX3[2])})
ENDIF

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Ctb277MatrizºAutor ³ Arnaldo Raymundo Jr.    º Data ³ 28/01/08 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gera a matriz combinando o array de base atual com o array     º±±
±±º          ³ intermediario, respeitando o nivel e a entidade.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA277                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ctb277Matriz(aRateios,aItensComb,aNiveis,nNivelAtu,nEntComb)

LOCAL lRet 		 		:= .T.
LOCAL aRateiosTMP 		:= {}
LOCAL nX, nY, nZ, nW	:= 0 
LOCAL nLinhas			:= 0
LOCAL nSumFator			:= 0
LOCAL aTamPerc			:= TAMSX3("CW1_PERCEN")
LOCAL nTotRat			:= 0
LOCAL nDifPerc			:= 0

FOR nX := 1 To Len(aRateios)

	FOR nY := 1 To Len(aItensComb)
	
		Aadd( aRateiosTMP, {"","","","",0,0,{"","","",""}} )
		nLinhas++
		
		FOR nZ := 1 To 4
		
			IF nZ == nEntComb  // Se for a entidade com que a Base sera combinada
				aRateiosTMP[nLinhas][nZ] := aItensComb[nY][nEntComb]
			ELSEIF Len(aNiveis) >= nZ
				
				FOR nW := 1 TO Len(aNiveis)

					aRateiosTMP[nLinhas][aNiveis[nW]]		:= aRateios[nX][nW]		 
				    aRateiosTMP[nLinhas][7][aNiveis[nW]]	:= aRateios[nX][7][nW]
				    
				NEXT nW
			
			ENDIF
		
		NEXT Nz		
				
		If aItensComb[nY][5] != 0
			aRateiosTMP[nLinhas][5] := aItensComb[nY][5]
		Elseif aRateios[nX][5] != 0
			aRateiosTMP[nLinhas][5] := aRateios[nX][5]
		EndIf			
		
		If aItensComb[nY][6] != 0 
			aRateiosTMP[nLinhas][6] := aItensComb[nY][6]
		Elseif aRateios[nX][6] != 0
			aRateiosTMP[nLinhas][6] := aRateios[nX][6]
		EndIf	
		aRateiosTMP[nLinhas][7][nEntComb] := aItensComb[nY][7][nEntComb]
	
	NEXT nY

NEXT nX

aRateios := ACLONE(aRateiosTMP)
// Recalcula o percentual com base nos fatores:
// 1. Totaliza o fator
aEval(aRateios,{|aLinha| nSumFator += aLinha[6]})
// 2. Se a soma dos fatores for diferente de zero
IF nSumFator <> 0
	nX := 0
	
	aEval(aRateios,{|aLinha| nX++, aRateios[nX][5] := 	Round(NoRound((aLinha[6]/nSumFator)*100,aTamPerc[2]+1),aTamPerc[2])})
	
	// Captura o total do percentual do rateio
	nX := 0
	aEval(aRateios,{|aLinha| nX++, nTotRat += aRateios[nX][5] })

	// AJUSTA O PERCENTUAL PARA 100% CASO HAJA DIFERENÇA
	// REALIZA O AJUSTE SEMPRE NA ULTIMA LINHA CUJO O PERCENTUAL SUPORTE A DIFERENÇA
	If nTotRat <> 100
		nDifPerc := 100 - nTotRat
			For nX := Len(aRateios) to 1 STEP -1
				If aRateios[nX][5] > ABS(nDifPerc)
					aRateios[nX][5] += nDifPerc
					nTotRat += nDifPerc
					Exit
				EndIf
			Next nX
	EndIf
	
ENDIF

RETURN lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Ctb277CalcF ºAutor ³ Arnaldo Raymundo Jr.    º Data ³ 28/01/08 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calcula o fatora da linha de rateio através da formula definidaº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA277                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ctb277CalcF(cFormula)

Local bBlock 	:= ErrorBlock( { |e| ChecErro(e) } )
Local lValid	:= .T.
Local nFator	:= 0

If !Empty(cFormula)
		
	BEGIN SEQUENCE
		nFaTor 	:= &(cFormula)
	RECOVER
		lValid	:= .F.
		nFator 	:=	0
	END SEQUENCE
	ErrorBlock(bBlock)
	
	If lValid
		If Valtype(nFator) <> "N"
			nFator	:=	0
		Endif		
	Endif

Endif

Return nFator

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Ctb277Form³ Autor ³ ARNALDO R. JUNIOR     ³ Data ³ 28/01/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se a formula digitada esta OK                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctb277Form() / DERIVADA DA CTB080FORM()                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA277 / VALIDACAO DO CADASTRO DE AMARRACAO DE RATEIOS    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Tipo do retorno desejado                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ctb277Form(cTipoRet,cForm,cAlias)

LOCAL lRet 		:= .T.
LOCAL xResult
LOCAL bBlock

DEFAULT cTipoRet := ""
DEFAULT cForm	 :=&(ReadVar())
DEFAULT cAlias	 := ALIAS()

// TRATAMENTO PARA PERMITIR O USO DOS CAMPOS DO CTQ NAS FORMULAS
IF cAlias != "CTQ"
	RegToMemory("CTQ",.T.)
ENDIF

lRet := Ctb080Form()

If lRet

	bBlock := ErrorBlock( { |e| ChecErro(e) } )
	BEGIN SEQUENCE
		xResult := &cForm
	RECOVER
		lRet := .F.
	END SEQUENCE
	ErrorBlock(bBlock)

	IF lRet .AND. Valtype(xResult) <> cTipoRet
		HELP("CTBA277",1,"HELP","TIPO_INCORRETO",STR0037+CRLF+STR0038+Valtype(xResult)+")"+CRLF+STR0039+cTipoRet+")"+CRLF,1,0)
		    //"Retorno da fórmula incoerente."#"Retorno da fórumla:("#"Retorno válido:("
		 lRet := .F.
	ENDIF
Endif
RETURN lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ --------------------- ³ Data ³ -------- ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados         ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()

LOCAL aRotina 	:= {}
LOCAL aCtb277BUT:= {}
LOCAL nX		:= 0

AADD(aRotina, {STR0002, "Ctb277Pes" 		, 0, 1})	//	"Pesquisar"
AADD(aRotina, {STR0003, "AxVisual" 			, 0, 2})	//	"Visualizar"
AADD(aRotina, {STR0004, "Ctb277Cad"			, 0, 3})	//	"Incluir"
AADD(aRotina, {STR0005, "Ctb277Cad"			, 0, 4})	//	"Alterar"
AADD(aRotina, {STR0006, "Ctb277Cad"			, 0, 5})	//	"Excluir"
AADD(aRotina, {STR0007, "Ctb277GerCTQ()"	, 0, 3})	//	"Gerar Rateio"
AADD(aRotina, {STR0008, "Ctb277Leg" 		, 0, 2})	//	"Legenda"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PONTO DE ENTRADA PARA ADICAO DE ITENS NO AROTINA                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF ExistBlock("Ctb277BUT")
	aCtb277BUT := ExecBlock("Ctb277BUT",.F.,.F.,aRotina)
	
	IF ValType(aCtb277BUT) == "A" .AND. Len(aCtb277BUT) > 0
		FOR nX := 1 to len(aCtb277BUT)
			aAdd(aRotina,aCtb277BUT[nX])
		NEXT
	ENDIF
ENDIF

Return(aRotina)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Ctb277Inc ³ Autor ³ ARNALDO R. JUNIOR     ³ Data ³ 28/01/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Controle o incremento do codigo de rateios                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctb277Inc(cSeqRat)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cString --> próximo codigo de uma dada sequencia de rateios³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA277 / Incremento do codigo de rateio automatico        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cSeqRat --> codigo da sequencia de rateios                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ctb277Inc(cSeqRat)

Local cCodRat := ""
Local nPosCod := 0

//CONOUTR("PONTO 04.1.1: INCREMENTANDO CODIGO DO RATEIO: "+cSeqRat,.F.,"CTBA277")


IF ValType(aCodRat) == "U"
	aCodRat := {}
Endif

IF ValType(nTamCod) == "U"
	nTamCod := TAMSX3("CTQ_RATEIO")[1]
Endif

IF Len(cSeqRat) > nTamCod
	cSeqRat := ""
ENDIF

IF (nPosCod := aScan(aCodRat,{|x| x[1] == cSeqRat})) == 0
	cCodRat := cSeqRat+STRZERO(1,nTamCod-Len(cSeqRat))
	AADD(aCodRat,{cSeqRat,cCodRat})
ELSE
	cCodRat := CT277Soma1(aCodRat[nPosCod][2],.F.)
	aCodRat[nPosCod][2] := cCodRat
ENDIF

//CONOUTR("PONTO 04.1.1: INCREMENTADO CODIGO DO RATEIO: "+cSeqRat,.F.,"CTBA277")

Return cCodRat

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTB277VlCod³ Autor ³ ARNALDO R. JUNIOR    ³ Data ³ 28/01/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida o codigo sugerido para o rateio                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTB277VlCod(cCodCTQ)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum --> variavel cCodCTQ passada como referência        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA277 / Incremento do codigo de rateio automatico        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCodCTQ --> codigo do rateio a ser validado                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

// Garante que o codigo não está em uso, devido a alteracao na estrutura dos grupos.
Static Function CTB277VlCod(cProxRat, cCodCTQ)
Local cReturn := ""

CTQ->( DbSetOrder(1) )

If !( cCodCTQ $ __cCodCTQ )
	
	__cCodCTQ += cCodCTQ+"|"
	
	If CTQ->( MsSeek(M->CTQ_FILIAL+cCodCTQ) )
		While CTQ->( MsSeek(M->CTQ_FILIAL+cProxRat) )
			cProxRat := CT277Soma1(cProxRat,.F.)
		EndDo
		cReturn := cProxRat
	Else
		cReturn := cCodCTQ
	Endif
	
Else

	While CTQ->( MsSeek(M->CTQ_FILIAL+cProxRat) )
		cProxRat := CT277Soma1(cProxRat,.F.)
	EndDo
	
	cReturn := cProxRat

Endif

CTQ->( DbSetOrder(2) )

Return cReturn


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTB277ADDCOD³ Autor ³ ARNALDO R. JUNIOR   ³ Data ³ 28/01/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta arrays com os codigos de rateio existentes no CTQ    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTB277ADDCOD()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum --> variavel aCodCTQ existe como STATIC             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA277 / Incremento do codigo de rateio automatico        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CTB277ADDCOD()

Local cQuery 	:= ""
Local cAliasQry := "CTQQRY"

IF ValType(aCodCTQ) == "U"  
	aCodCTQ := {}
ENDIF

cQuery := "SELECT DISTINCT(CTQ_RATEIO) FROM "+RetSqlName("CTQ")+" CTQ WHERE "
cQuery += "CTQ.CTQ_FILIAL = '"+xFilial("CTQ")+"'AND "
cQuery += "CTQ.D_E_L_E_T_ = '' "
cQuery += "ORDER BY CTQ_RATEIO"

IF Select(cAliasQry) > 0   
	dbSelectArea(cAliasQry)
	dbCloseArea()
ENDIF

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)
DbSelectArea(cAliasQry)
DbGoTop()
While (cAliasQry)->(!EOF())
	AADD(aCodCTQ,(cAliasQry)->CTQ_RATEIO)
	__LastRat := (cAliasQry)->CTQ_RATEIO	
	(cAliasQry)->(DbSkip())
End

IF Select(cAliasQry) > 0   
	dbSelectArea(cAliasQry)
	dbCloseArea()
ENDIF

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CT277Soma1  ³ Autor ³ ARNALDO R. JUNIOR   ³ Data ³ 28/01/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua o Soma1() sem adicionar caracteres ao final         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CT277Soma1()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA277 / Incremento do codigo de rateio automatico        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function CT277Soma1(cSoma, lCompleteSUM)
Local ni
Local cRet := ""
Local cB
Local cX := Replicate ("9", Len(cSoma))

Default lCompleteSUM := .F.

For ni:= 1 to len(cSoma)
    cB := Upper(Subs(cSoma,ni,1))
    IF !(cB$"0123456789ABCDEFGHIJKLMNOPQRSTUWXYZ")
       cRet += "0"
    Else
       cRet += Subs(cSoma,ni,1)
    Endif
Next     
cSoma := cRet

// Executa a numeração normal ate 99999..99
If IsNum(cSoma) .and. cSoma < cX .and. !lCompleteSUM
   Return StrZero(Val(cSoma)+1,Len(cSoma),0)
Endif

cRet := ""
For ni := len(cSoma) to 1 Step -1
 cB := Subs(cSoma,ni,1)
 IF cB == "9"
    cB := "0"
	 cret := cB + cRet
 Else
    cb := Chr(ASC(cb)+1)
    cRet := cB + cret 
    EXIT
 Endif         
Next                 
cRet := Subs(cSoma,1,Len(cSoma)-Len(cret)) + cRet
Return cRet

Static Function IsNum(cCheck)
Local ni
For  ni := 1 to Len(cCheck)
     If !Subs(cCheck,ni,1)$"0123456789"
        Return .F.
     Endif
Next
Return .T.
