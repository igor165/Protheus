#include "protheus.ch"
#include "fina435.ch"

/*/{Protheus.doc} FINA435
Retorno de comunicação bancária a pagar - via Job.

@param   cParm01    Código da empresa.
@param   cParm02    Código da filial.

@author  Aldo Barbosa dos Santos
@since   31/05/2011
/*/
Function FINA435(cParm01, cParm02)

Local aParam 
Local nCntFor
Private cCadastro  := STR0001 // "Retorno Bancario Automatico (Pagar)"

Default cParm01 := ''
Default cParm02 := ''

If !empty(cParm01) .and. !empty(cParm02)
	aParam := {cParm01, cParm02}
ElseIf !empty(cParm01) .and. Valtype(cParm01) == "A"
	aParam := {cParm01[1], cParm01[2]}
Endif

ConOut("*** INÍCIO - " + Dtoc(Date()) + " " + Time() + " - " + cCadastro)

if Valtype(aParam) <> "A"
	ConOut("*** - " + STR0002) // "Processo pode ser executado apenas via Schedule"
Else
	// Executa apenas se for chamado pelo Schedule.
	// As variáveis abaixo são úteis para debug da rotina via execução normal.
	Private lExecJob := .T.
	Private aMsgSch  := {}
	Private aFA205R  := {}
	
	// Manter posicionado pois o FINA200 vai utilizar estas informações.
	RpcSetEnv(aParam[1], aParam[2], Nil, Nil, Nil, "FINA430")

	If  LockByName( "FINA435", .T., .T. )
		BatchProcess(cCadastro, cCadastro, "FA435JOB", {|| FA435JOB()}, {|| .F. })

		// Se o parâmetro não está definido, envia as mensagens para o console.
		If empty(GetMv("MV_RETMAIL",, "")) .and. Len(aMsgSch) > 0
			For nCntFor := 1 to Len(aMsgSch)
				ConOut(aMsgSch[nCntFor])
			Next
		Endif
	Else
		ConOut(STR0007+cFilant+STR0008) //"Retorno de pagamento da Filial " ## " está executando em outra thread "  
	EndIf

	RpcClearEnv()
Endif

ConOut("*** FIM - " + Dtoc(Date()) + " " + Time() + " - " + cCadastro)

Return

/*/{Protheus.doc} FA435JOB
Retorno de comunicação bancária a pagar - via Job.

@author  Aldo Barbosa dos Santos
@since   31/05/2011
/*/
Static Function FA435JOB()

Local cPerg	:= "AFI430"
Local aVetPar // vetor das perguntas
Local cQuery  // query de bancos que serao executados automaticamente
Local cAlias  // alias temporario dos banco que serao executados
Local cBarra := If(IsSrvUnix(), "/", "\")
Local nA

Local aArq
Local cArquivo
Local cDirArq
Local cDirBkp

Local cPathArq := ""
Local cPathBkp := ""

Local lDirInc  := .F.
Local cDirInc  := ""

SEE->(dbsetorder(1))  // EE_FILIAL, EE_CODIGO, EE_AGENCIA, EE_CONTA, EE_SUBCTA.

lDirInc	:= SEE->(ColumnPos("EE_INCPAG")) > 0

// Lê as perguntas do FINA430 que serão modificadas de acordo com os novos campos da tabela de bancos.
// Pergunte(cPergunta,lAsk,cTitle,lOnlyView,oDlg,lUseProf,aPerg,lBreakLine,lHasHelp)
Pergunte(cPerg, .F., Nil, Nil, Nil, .F.)

// Seleciona todas as contas que estão programadas para recebimento automático.
cQuery := "SELECT R_E_C_N_O_ REGSEE "
cQuery += "FROM " + RetSqlName("SEE") + " SEE "
cQuery += "WHERE EE_FILIAL = '" + xFilial("SEE") + "' "
cQuery += "AND EE_RETAUT IN ('2', '3') " // 1.recebimento; 2.pagamento; 3.ambos
cQuery += "AND EE_DIRPAG <> ' ' " // Somente contas com diretório preenchido.
cQuery += "AND SEE.D_E_L_E_T_ = ' ' "
cQuery += "ORDER BY EE_DIRREC"

cAlias := MPSysOpenQuery(ChangeQuery(cQuery))

Do While (cAlias)->(!Eof())
	// Mantém posicionado pois o FINA430 vai utilizar estas informações.
	SEE->(dbGoto((cAlias)->REGSEE))

	// Verifica se todos os parâmetros necessários foram preechindos e grava no log.
	If !FA205ERRO()

		// Perguntas do FINA430
		// MV_PAR01: Mostra Lanc. Contab  ? Sim Nao
		// MV_PAR02: Aglutina Lanc. Contab? Sim Nao
		// MV_PAR03: Arquivo de Entrada   ?
		// MV_PAR04: Arquivo de Config    ?
		// MV_PAR05: Banco                ?
		// MV_PAR06: Agencia              ?
		// MV_PAR07: Conta                ?
		// MV_PAR08: SubConta             ?
		// MV_PAR09: Contabiliza          ?
		// MV_PAR10: Padrao Cnab          ? Modelo1 Modelo 2
		// MV_PAR11: Processa filiais     ? Modelo1 Modelo 2

		// Atualiza o pergunte do FINA200 de acordo com a tabela de bancos
		aVetPar := {{'mv_par01', 2					},; // 01	Mostra Lanc Contab ?
					{'mv_par02', Val(SEE->EE_AGLCTB)},; // 02	Aglut Lancamentos ?
					{'mv_par03', SEE->EE_DIRPAG		},; // 03	Arquivo de Entrada ?
					{'mv_par04', SEE->EE_CFGPAG		},; // 04	Arquivo de Config ?
					{'mv_par05', SEE->EE_CODIGO		},; // 05	Codigo do Banco ?
					{'mv_par06', SEE->EE_AGENCIA	},; // 06	Codigo da Agencia ?
					{'mv_par07', SEE->EE_CONTA		},; // 07	Codigo da Conta ?
					{'mv_par08', SEE->EE_SUBCTA		},; // 08	Codigo da Sub-Conta ?
					{'mv_par09', 2					},; // 09	Contabiliza On Line ?
					{'mv_par10', Val(SEE->EE_CNABPG)},; // 10	Configuracao CNAB ?
					{'mv_par11', Val(SEE->EE_PROCFL)},; // 11	Processa Filial?
					{'mv_par12', 2					}}  // 12	Considera Multiplas naturezas ?

		// le os arquivos do diretorio configurado
		cDirArq := Alltrim(SEE->EE_DIRPAG)
		cDirBkp := Alltrim(SEE->EE_BKPPAG)

		// Verifica se os diretórios estão com a barra no final.
		If right(cDirArq, 1) <> cBarra
			cDirArq += cBarra
		Endif
		If !empty(cDirBkp) .and. right(cDirBkp, 1) <> cBarra
			cDirBkp += cBarra
		Endif

		// Lê os arquivos a serem processados.
		aArq := Directory(cDirArq + "*." + AllTrim(SEE->EE_EXTEN) + "*")
		If Empty(aArq) .and. AllTrim(cDirArq) == cBarra
			aArq    := Directory("*." + AllTrim(SEE->EE_EXTEN) + "*")
			cDirArq := ""
		Endif

		For nA := 1 to Len(aArq)
			// Armazena o nome do arquivo nos parâmetros.
			cArquivo := aArq[nA, 1]
			aVetPar[3, 2] := cDirArq + cArquivo

			// Atualiza o pergunte do FINR650.
			aVet650 := {{'mv_par01', cDirArq + cArquivo},;	// 01 Arquivo de Entrada ?
						{'mv_par02', SEE->EE_CFGPAG},;		// 02 Arquivo de Config ?
						{'mv_par03', SEE->EE_CODIGO},;		// 03 Codigo do Banco ?
						{'mv_par04', SEE->EE_AGENCIA},;		// 04 Codigo da Agencia ?
						{'mv_par05', SEE->EE_CONTA},;		// 05 Codigo da Conta ?
						{'mv_par06', SEE->EE_SUBCTA},;		// 06 Codigo da SubConta ?
						{'mv_par07', 2},;					// 07 Carteira ?  1=Receber;2=Pagar
						{'mv_par08', Val(SEE->EE_CNABPG)}}	// 08 Configuracao CNAB ?

			// Controle de mensagens de erro.
			aMsgSch := {}

			// Controle de titulos baixados utilizado no fina430
			aFA205R := {}

			// Executa a consistência antes de executar o recebimento.
			FINR650(aVet650)

			// Executa o programa de recebimento.
			FINA430(nil, aVetPar)

			// Envia e-mail (FINA205) das mensagens de erro
			FA205MAIL(STR0001, cDirArq + cArquivo, aMsgSch) // "Retorno Bancario Automatico (Pagar)"

			If lDirInc
				cDirInc := Alltrim(SEE->EE_INCPAG)
			EndIf

			If Len(aMsgSch) == 0
				If !Empty(cDirBkp)
					cPathArq := cDirArq + cArquivo
					cPathBkp := cDirBkp + cArquivo
					If !_CopyFile(cPathArq, cPathBkp) //copia o arquivo para o diretorio de backup
						ConOut(STR0003 + cPathArq + STR0004 + cDirBkp) // "Não foi possível copiar o arquivo " # " para o diretório "
					Else
						// Exclui o arquivo processado.
						If FErase(cPathArq) < 0
							ConOut(STR0005 + cPathArq) // "Não foi possível excluir o arquivo "
							ConOut("fErase: " + STR0006 + cValToChar(FError()))  // "Erro "
						EndIf
					EndIf
				EndIf
			Else
				If lDirInc
					cPathArq := cDirArq + cArquivo
					cPathInc := cDirInc + cArquivo		
					If !_CopyFile(cPathArq, cPathInc) //copia o arquivo para o diretorio de Inconsistencia.
						ConOut(STR0003 + cPathArq + STR0004 + cDirInc) // "Não foi possível copiar o arquivo " # " para o diretório "
					Else
						FErase(cPathArq)
					EndIf	
				EndIf
			EndIf
		Next nA
	EndIf

	(cAlias)->(DbSkip())
EndDo

(cAlias)->(DbCloseArea())

Return
