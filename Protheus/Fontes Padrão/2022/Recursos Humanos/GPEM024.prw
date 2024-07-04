#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEM024.CH"
#INCLUDE "SCOPECNT.CH"

#DEFINE TAMIMP 120

Static 	aTLogr
Static 	aLogrNum
Static 	aInfo
Static 	aPaisCNIS 	:= {}
Static  aPaisC		:= {}
Static 	aOrgExp		:= {}
Static  aCodUF		:= {}
Static 	cAliasSRA	:= ""
Static	cFilCentra	:= ""
Static 	lAnt2010T	:= .F.
Static 	dDataEmis	:= CtoD("//")

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    	  ³ GPEM024    ³ Autor ³ Alessandro Santos        v.I ³ Data ³ 06/12/13 ³±±
±±³             ³            ³       ³ Claudinei Soares         v.II  ³ Data ³ 08/09/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao 	  ³ CNIS                           									    ³±±
±±³             ³ Rotina para exportar informacoes de funcionarios e gerar arquivo txt  ³±±
±±³             ³ para geracao ou confirmacao do numero do PIS, conforme os parametros  ³±±
±±³             ³ informados pelo usuario. 											    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   	  ³ GPEM024()                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      	  ³ Generico (DOS e Windows)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.               		    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador  ³ Data     ³ FNC            ³  Motivo da Alteracao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Raquel Hager ³11/08/2014³ TQHIID         ³Inclusao de fonte na Versao 12.		    ³±±
±±³Claudinei S. ³09/09/2014³ TQAHGM         ³Novo pergunte para filial centralizadora.  ³±±
±±³             ³          ³                ³Incluido o botao Filtrar, tratamento para  ³±±
±±³             ³          ³                ³Estado Civil = M (Uniao Estavel) adicionado³±±
±±³             ³          ³                ³Log para Func. gerados e Multiplo Vinculo. ³±±
±±³Claudinei S. ³01/12/2014³ TQAHGM         ³Ajustada a rotina conforme os leiautes 13 e³±±
±±³             ³          ³                ³14, Alterado o nome do arquivo, ajustadas  ³±±
±±³             ³          ³                ³as mensagens do log de ocorrencias, correta³±±
±±³             ³          ³                ³gravacao dos campos tipo numerico.         ³±±
±±³             ³          ³                ³Ajustada a geracao do campo secao eleitoral³±±
±±³             ³          ³                ³e a geracao do arquivo retificador.        ³±±
±±³Wagner Mobile³22/01/2015³TQAHGM          ³Compatibilização com a versão 11 validada  ³±±
±±³Claudinei S. ³25/03/2015³TQAHGM          ³Correta geracao da matricula das certidoes ³±±
±±³             ³          ³                ³civis geradas a partir de 2010, caso nome  ³±±
±±³             ³          ³                ³da mae ou pai nao seja informado gerar     ³±±
±±³             ³          ³                ³Ignorada ou Ignorado e nao Ignorado(a)     ³±±
±±³Mariana M.   ³25/05/2015³TSGBL0          ³Incluido o codigo 98 - DETRAN dos orgaos   ³±±
±±³             ³          ³                ³emissores para que seja gerado no CNIS		³±±
±±³Christiane V³02/07/2015³  TSMUY2         ³Adaptações para versão 2.0 do eSocial      ³±±
±±³Claudinei S. ³30/09/2015³TTBXO8          ³Tratamento para o novo tamanho do campo da ³±±
±±³             ³          ³                ³matricula da certidao na SRA (RA_MATCERT) o³±±
±±³             ³          ³                ³tamanho do campo foi alterado de 8 para 32 ³±±
±±³             ³          ³                ³caso tenha sido preenchido com 8 realizar o³±±
±±³             ³          ³                ³tratamento anterior (Pegar a matricula em 8³±±
±±³             ³          ³                ³campos) caso tenha 32 utilizar o proprio   ³±±
±±³             ³          ³                ³campo.                                     ³±±
±±³Claudinei S. ³15/10/2015³TTOW41          ³Incluida opcao para geracao do arquivo na  ³±±
±±³             ³          ³                ³na estrutura completa.                     ³±±
±±³Claudinei S. ³30/10/2015³TTOW41          ³Removida a chamada para a funcao FGP24SX1()³±±
±±³             ³          ³                ³havia sido inserida para testes e nao foi  ³±±
±±³             ³          ³                ³removida.                                  ³±±
±±³Renan Borges ³28/12/2016³MRH-1173        ³Ajuste para a inclusão do código externo 11³±±
±±³             ³          ³                ³ referente ao órgão emissor Instituto de   ³±±
±±³             ³          ³                ³Identificação Felix Pacheco.               ³±±
±±³Paulo O.		³09/05/2017³DRHPAG-1357     ³Ajuste para a listar discos removiveis     ³±±
±±³Inzonha		³          ³                ³como local para geração do arquivo		    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GPEM024()

Local aSays		   	:= {}
Local aButtons	   	:= {}
Local cPerg        	:= "GPEM024"
Local nOpcA		  	:= 0.00
Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F., {"",""} }) //[1]Acesso; [2]Ofusca; [3]Mensagem
Local aMsg			:= aOfusca[3]
Local aFldRel		:= {"RA_CIC", "RA_PIS", "RA_NOMECMP", "RA_NOME", "RA_SEXO", "RA_RACACOR", "RA_ESTCIVI", "RA_GRINRAI", "RA_LIVCERT", "RA_FOLCERT", "RA_NASC", "RA_NATURAL", "RA_CPAISOR", "RA_MAE",	;
						"RA_PAI", "RA_NUMCP", "RA_SERCP", "RA_UFCP", "RA_NUMEPAS", "RA_DEMIPAS", "RA_EMISPAS", "RA_DVALPAS", "RA_CODPAIS", "RA_NUMRIC", "RA_EMISRIC", "RA_DEXPRIC", "RA_RG", "RA_DTRGEXP",;
						"RA_CODIGO", "RA_HABILIT", "RA_RESEXT", "RA_LOGRTP", "RA_LOGRDSC", "RA_LOGRNUM", "RA_COMPLEM", "RA_BAIRRO", "RA_CEP", "RA_CODMUN", "RA_CODMUNN", "RA_ESTADO", "RA_MUNICIP",		;
						"RA_TELEFON", "RA_DDDFONE", "RA_NUMCELU", "RA_DDDCELU", "RA_DATCHEG", "RA_DATNATU", "RA_BRNASEX", "RA_TITULOE", "RA_ZONASEC", "RA_EMAIL", "RA_ADMISSA", "RA_DEMISSA", "RA_VIEMRAI",;
						"RA_RGEXP", "RA_CDMUCER", "RA_NACIONA", "RA_SECAO", "RA_RGUF", "RA_COMPLRG", "RA_DTCPEXP", "RA_TIPENDE", "RA_ENDEREC", "RA_NUMENDE", "RA_NUMNATU", "RA_UFRIC", "RA_CDMURIC",	;
						"RA_CPOSTAL", "RA_CEPCXPO", "RA_CODFUNC", "RA_CARGO", "RA_SALARIO", "RA_CATFUNC", "RA_MATCERT",	"RA_UFCERT", "RA_CARCERT", "RA_EMICERT", "RA_TIPCERT", "RA_UFPAS", "RA_CC",		;
						"RA_TPLIVRO", "RA_OCORREN", "RA_SERVENT", "RA_CODACER", "RA_REGCIVI"}
Local lBlqAcesso	:= aOfusca[2] .And. !Empty( FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRel ) )

Private aArea		:= GetArea()
Private aAreaSRA	:= SRA->( GetArea() )
Private cCadastro 	:= OemToAnsi(STR0002) //"CNIS"

Private cSraFilter	:= ""
Private aRetFiltro	:= {}
Private aFilterExp	:= {}

If !lBlqAcesso
	Pergunte(cPerg, .F.)

	AAdd( aFilterExp , { "FILTRO_ALS" , "SRA"     	, .T. } )			 /* Retorne os Filtros que contenham os Alias Abaixo */
	AAdd( aFilterExp , { "FILTRO_PRG" , FunName() 	, NIL , NIL    } )  /* Que Estejam Definidos para a Função */

	aAdd(aSays,OemToAnsi(STR0017))			//"Geração de Arquivo txt para realizar Cadastramento CNIS ou Confirmação do Número"
	aAdd(aSays,OemToAnsi(STR0018))			//"do PIS."
	aAdd(aSays,OemToAnsi(STR0019))			//"Se qualquer um dos campos CPF, Nome, data de nascimento do trabalhador ou NIS(PIS)."
	aAdd(aSays,OemToAnsi(STR0033))			//"Não estiverem preenchidos (no caso do PIS somente se for confirmação do número),"
	aAdd(aSays,OemToAnsi(STR0034))			//"os registros do mesmo não serão gerados."

	aAdd(aButtons, { 17,.T.,{|| aRetFiltro := FilterBuildExpr( aFilterExp ) } } )
	aAdd(aButtons, { 15,.T.,{|| GPM024LOG() } } )	//"Log de ocorrencias CNIS"
	aAdd(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
	aAdd(aButtons, { 1,.T.,{|o| nOpcA := 1,IF(gpconfOK(),FechaBatch(),nOpcA:=0) }} )
	aAdd(aButtons, { 2,.T.,{|o| FechaBatch() }} )
	FormBatch( cCadastro, aSays, aButtons )

	IF nOpcA == 1
		Processa({|lEnd| fGp24Pro(cPerg),STR0002})  //"CNIS"
	EndIF
Else
	Help(" ",1,aMsg[1],,aMsg[2],1,0)
Endif

//Restaura os Dados de Entrada
RestArea( aAreaSRA )
RestArea( aArea )
Return( NIL )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Funcao    ³ fGp24Pro		³Autor³  Alessandro Santos³ Data ³06/12/2013³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descricao ³Processo de exportacao para txt e gravacao do arquivo.      ³
³          ³O controle dos campos que serao gravados sera pelo array    ³
³          ³aCposTxt, caso seja necessario incluir novos campos         ³
³          ³adicionar nesse array.                                      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									  ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEM024                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina															  ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									  ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

Static Function fGp24Pro(cPerg)

Local cLin 	  	:= ""
Local cEOL     	:= CHR(13) + CHR(10)
Local nOpca    	:= MV_PAR10 //Opcao de Processamento
Local nHdl     	:= Nil
Local nY			:= 0
Local nI       	:= 0
Local nX       	:= 0
Local aTitle		:= {}
Local aInfoAll  	:= {}
Local aFilArq		:= {}
Local aLogProc 	:= {}
Local aCposTxt 	:= {"RA_CIC", "RA_PIS", "RA_NOMECMP", "RA_NASC"}

cFilCentra := MV_PAR17

If nOpca == 1 //Geracao de arquivo txt
	Aadd( aLogProc,OemToAnsi(STR0008))  //"Inicio do processamento"
	Aadd( aLogProc,{} )
EndIf

//Efetua validacoes
If !fGp24Vld(nOpca, @nHdl, aCposTxt)
	Return()
EndIf

//Busca informacoes
fGp24Info(@aInfoAll, aCposTxt, aLogProc, @aFilArq)

For nY := 1 To Len(aInfoAll)
	If nOpca == 1 //Geracao de arquivo txt
		//Cria o Arquivo de Saida
		fInfo(@aInfo,aFilArq[nY][1])
		cNomeArq:= fGp24NmArq(.T.,aFilArq[nY][1])
	   	Ferase(cNomeArq)
		nHdl := fCreate( cNomeArq )

		Aadd(aTitle, OemToAnsi(STR0016)) //"Log de Ocorrencias - CNIS"
		Aadd( aLogProc,{})

		If nHdl == -1
			Aadd( aLogProc,OemToAnsi(STR0003) + " - " +  OemToAnsi(STR0004)) //"Não foi possivel criar o arquivo de saída"##"Favor verificar parametros"
			Aadd( aLogProc,{} )
			Return(.F.)
		EndIf

		If Len(aInfoAll[nY]) > 0
			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Gravacao do registro   									   ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

			//Loop para geracao do arquivo
			For nI := 1 To Len(aInfoAll[nY])
				//Prepara buffer para receber os dados
				cLin := ""

				//Busca todos os campos para geracao do arquivo
				For nX := 1 To Len(aCposTxt)
					cLin += aInfoAll[nY,nI,nX]
				Next nX

				//Grava o buffer no arquivo de saida
				cLin += cEOL

				//Efetua gravacao
				fWrite(nHdl, cLin, Len(cLin))
			Next nI
			Aadd( aLogProc,OemToAnsi(STR0030) + " - " + cNomeArq) //"Arquivo CNIS gerado"
			Aadd( aLogProc,{} )
		Else
			Aadd( aLogProc,OemToAnsi(STR0028)) //"Não existem informações para geração de arquivo"
			Aadd( aLogProc,{} )
		EndIf

		//Encerramento
		fClose(nHdl)
		nHdl := 0
		cLin := ""

	Else //Impressao do Log
		Aadd(aTitle, OemToAnsi(STR0027)) //"Impressão de Logs Gerados de acordo com os parâmetros informados"
		Aadd( aLogProc,{})
	EndIf
Next nY

If Len(aLogProc) > 0 //Imprime Log
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Apresenta o Log                                         ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	If Len(aLogProc) == 1
		Aadd( aLogProc,OemToAnsi(STR0038))	//"Não foram encontradas divergências"
	Endif

	fMakeLog({aLogProc}, aTitle, Nil, Nil, cPerg, OemToAnsi(STR0016), "M", "P",, .F.) //"Log de Ocorrencias - CNIS"
ELSE
	If nOpca == 1 //Geracao de arquivo txt
		msgAlert(STR0026) //'Fim de Processamento'
	Else
		MsgAlert(OemToAnsi(STR0025)) //"Não existem informações para serem impressas, verifique os parâmetros de impressão"
	Endif

ENDIF

Return()

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Funcao    ³ fGp24Vld       ³Autor³  Alessandro Santos³ Data ³06/12/2013³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descricao ³Validacoes para geracao do arquivo txt ou impressao de incon³
³          ³cistencias.                                                 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									  ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEM024                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >                                 ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

Static Function fGp24Vld(nOpca, nHdl, aCposTxt, cArqTxt)

Local nI      	:= 0
Local lNivelSRA	:= .T.

//Validacao do nivel do usuario, caso nao seja suficiente nao entra no processo
For nI := 1 To Len(aCposTxt)
	If !CpoChkNivel(aCposTxt[nI])
		lNivelSRA := .F.
	EndIf
Next nI

//Campo SRA_NOME verificado a parte pois utilizado somente se RA_NOMECMP vazio, portando nao pode estar no array aCposTxt
If !CpoChkNivel("RA_NOME")
	lNivelSRA := .F.
EndIf

If nOpca == 1 .And. !lNivelSRA //Geracao de arquivo txt porem sem permissao de acesso a tabela SRA
	Aadd(aTitle, OemToAnsi(STR0021) + " - " +  OemToAnsi(STR0022)) //"Nível do usuário não permite acessar a rotina"##"Consulte o administrador do sistema"
	Aadd( aLogProc,{} )
	Return(.F.)
ElseIf nOpca == 2 .And. !lNivelSRA //Impressao de Inconsistencias porem sem permissao de acesso a tabela SRA
	MsgAlert(OemToAnsi(STR0021) + " - " +  OemToAnsi(STR0022))

	Return(.F.)
EndIf

Return(.T.)

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Funcao    ³ fGp24Info      ³Autor³  Alessandro Santos³ Data ³06/12/2013³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descricao ³Busca informacoes dos funcionarios e verifica a existencia  ³
³          ³de inconsistencias conforme parametros informados.          ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									  ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEM024                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina															  ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									  ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

Static Function fGp24Info(aInfoAll, aCposTxt, aLogProc, aFilArq)
Local aArea		 := GetArea()
Local aInfoSRA	 := {}
Local aLogGera	 := {}
Local aLogMultV	 := {}
Local aEnd 		 := {}
Local aInfoCompl := {}
Local cItem		 := " - "
Local cCFilial	 := ""
Local cCFilAnt	 := ""
Local cCatQuery  := ""
Local cSitQuery  := ""
Local cMsgErro   := ""
Local cLogGera	 := ""
Local cLogMultV	 := ""
Local cWhere	 := ""
Local cCodOri	 := "000000000000000001"
Local cCodCmp	 := ""
Local cDataAux	 := ""
Local cNISRet	 := Replicate("0",11)
Local cRetorno	 := Replicate("0",4)
Local cFilDe2	 := MV_PAR01 //Filial De sem o tratamento para query
Local cFilDe     := If(Empty(MV_PAR01),"''", MV_PAR01) //Filial De
Local cFilAte    := If(Empty(MV_PAR02),"''", MV_PAR02) //Filial Ate
Local cMatDe     := If(Empty(MV_PAR03),"''", MV_PAR03) //Matricula De
Local cMatAte    := If(Empty(MV_PAR04),"''", MV_PAR04) //Matricula Ate
Local cCCDe      := If(Empty(MV_PAR05),"''", MV_PAR05) //Centro de Custo De
Local cCCAte     := If(Empty(MV_PAR06),"''", MV_PAR06) //Centro de Custo Ate
Local cCategoria := MV_PAR07 //Categoria
Local cSituacao  := MV_PAR08 //Situacao
Local nTipoCarga := MV_PAR11 //Tipo de Carga (Cadastramento/Qualificacao)
Local cNISAtend	 := MV_PAR15 //NIS do Atendente (Responsavel pelo cadastramento)
Local cCPFAtend	 := MV_PAR16 //CPF do Atendente (Responsavel pelo cadastramento)
Local cTpRemes	 := If(MV_PAR12 == 1, "O","R")
Local lCompleta	 := If(MV_PAR18 == 2, .T.,.F.) //Tipo de estrutura(Completa = .T. ou Simplificada = .F.)
Local cFilCompl	 := MV_PAR19 //Empresa/Filial Responsável pelas informações
Local nOrdFisic  := 1
Local nSeqReg00	 := 0
Local nSeqReg02	 := 0
Local nSeqReg02C := 0
Local nSeqReg98	 := 0
Local nSeqReg99	 := 0
Local nGera		 := 0
Local nTam		 := 0
Local nContFil 	 := 0    //contador de filiais geradas, utilizada na estrutura completa.
Local nCntVersao := 0
Local lPrimeira	 := .T.
Local lGeraComp	 := .T. //Se ira gerar os registros da estrutura completa.
Local lUltima	 := .F.
Local dData

Local cVArq 	:= ""
Local cOrg		:= ""
Local cFilNoExec:= ""
Local cUltFil	:= ""

Set(4,"dd/mm/yyyy")

SX3->(dbSetOrder(2)) //Indice por campo

//Busca informacoes dos usuarios
cAliasSRA := "QSRA"

//Verifica se alias esta em uso
If (Select(cAliasSRA) > 0)
   (cAliasSRA)->(dbCloseArea())
EndIf

//Tratamento categorias
If Empty(cCategoria)
   cCatQuery := "'" + "*" + "'"
Else
   cCatQuery := Upper("" + fSqlIN(cCategoria, 1) + "")
EndIf

//Tratamento situacoes
If Empty(cSituacao)
   cSitQuery := "'" + " " + "'"
Else
   cSitQuery := Upper("" + fSqlIN(cSituacao, 1) + "")
EndIf

cWhere += " SRA.RA_FILIAL BETWEEN  "+ "'"+cFilDe+"'" + " AND "+ "'"+cFilAte+"'""
cWhere += " AND SRA.RA_MAT BETWEEN "+ "'"+cMatDe+"'" + " AND "+ "'"+cMatAte+"'""
cWhere += " AND SRA.RA_CC BETWEEN " + "'"+cCCDe +"'" + " AND "+ "'"+cCCAte+ "'""
cWhere += " AND SRA.RA_CATFUNC IN ("+ cCatQuery+ ") "
cWhere += " AND SRA.RA_SITFOLH IN ("+ cSitQuery+ ") "
cWhere += " AND SRA.RA_NASC <> ''"
cWhere += " AND SRA.D_E_L_E_T_ = ' ' "
cWhere := "% " + cWhere + " %"

//Sempre que alterar esta query, a query abaixo (count), tb devera ser alterada.
BeginSql alias cAliasSRA
   SELECT RA_FILIAL, RA_MAT, RA_CIC, RA_PIS, RA_NOMECMP, RA_NOME, RA_SEXO, RA_RACACOR, RA_ESTCIVI,
	  RA_GRINRAI, RA_LIVCERT, RA_FOLCERT, RA_NASC, RA_NATURAL, RA_CPAISOR, RA_MAE, RA_PAI,
	  RA_NUMCP, RA_SERCP, RA_UFCP, RA_NUMEPAS, RA_DEMIPAS, RA_EMISPAS, RA_DVALPAS, RA_CODPAIS,
	  RA_NUMRIC, RA_EMISRIC, RA_DEXPRIC, RA_RG, RA_DTRGEXP, RA_CODIGO, RA_HABILIT, RA_RESEXT,
	  RA_LOGRTP, RA_LOGRDSC, RA_LOGRNUM, RA_COMPLEM, RA_BAIRRO, RA_CEP, RA_CODMUN, RA_CODMUNN,
	  RA_ESTADO, RA_MUNICIP, RA_TELEFON, RA_DDDFONE, RA_NUMCELU, RA_DDDCELU, RA_DATCHEG,
	  RA_DATNATU, RA_BRNASEX, RA_TITULOE, RA_ZONASEC, RA_EMAIL, RA_ADMISSA, RA_DEMISSA,
	  RA_VIEMRAI, RA_RGEXP, RA_CDMUCER, RA_NACIONA, RA_SECAO, RA_RGUF, RA_COMPLRG, RA_DTCPEXP,
	  RA_TIPENDE, RA_ENDEREC, RA_NUMENDE, RA_NUMNATU, RA_UFRIC, RA_CDMURIC, RA_CPOSTAL,
	  RA_CEPCXPO, RA_CODFUNC, RA_CARGO, RA_SALARIO, RA_CATFUNC, RA_MATCERT,	RA_UFCERT,
	  RA_CARCERT, RA_EMICERT, RA_TIPCERT, RA_UFPAS, RA_CC, RA_TPLIVRO, RA_OCORREN, RA_SERVENT,
	  RA_CODACER, RA_REGCIVI
     FROM %table:SRA% SRA
    WHERE %exp:cWhere%
    ORDER BY SRA.RA_FILIAL, SRA.RA_MAT
EndSql

dbSelectArea(cAliasSRA)

//Layout do Arquivo de Saida
ProcRegua((cAliasSRA)->(RecCount()))


If Empty(cFilDe2).OR. Alltrim(cFilDe2) $ "AA/00"
	cCFilial:= (cAliasSRA)->RA_FILIAL
Else
	cCFilial:= cFilDe2
EndIf

If lCompleta
	If !fInfo(@aInfoCompl,SubStr(cFilCompl,3),SubStr(cFilCompl,1,2))
		Help( ,, OemToAnsi(STR0005),, OemToAnsi(STR0088), 1, 0 ) //"Atenção" ## "Filial Responsável não encontrada."
		Return .F.
	EndIf
Endif

If !Empty(cFilCentra)
	fInfo(@aInfo,cFilCentra)
Else
	fInfo(@aInfo,cCFilial)
Endif

//Posicionamento do primeiro registro e Loop Principal
While (cAliasSRA)->(!Eof())
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Posiciona na tabela SRA - Fisica                    	 	   	³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	dbSelectArea("SRA")
	dbSetOrder(RetOrder("SRA", "RA_FILIAL+RA_MAT"))
	dbSeek((cAliasSRA)->(RA_FILIAL+RA_MAT),.F.)
	cSraFilter	:= GpFltAlsGet( aRetFiltro , "SRA" )
	If !Empty( cSraFilter )
		If !( &( cSraFilter ) )
			(cAliasSRA)->(dbSkip())
			Loop
		EndIf
	EndIf

	If (cAliasSRA)->RA_FILIAL != cUltFil
		cUltFil := (cAliasSRA)->RA_FILIAL
		If !(cAliasSRA)->( (cAliasSRA)->RA_FILIAL $ fValidFil() )
			cFilNoExec += (cAliasSRA)->RA_FILIAL + "/"
			(cAliasSRA)->(dbSkip())
			Loop
		EndIf
	ElseIf (cAliasSRA)->RA_FILIAL $ cFilNoExec
		(cAliasSRA)->(dbSkip())
		Loop
	EndIf

	//IncProc para melhor performance
	IncProc(OemToAnsi(STR0009) + "  " + (cAliasSRA)->RA_FILIAL + " - " + (cAliasSRA)->RA_MAT + " - " + (cAliasSRA)->RA_NOME)//"Gerando o registro de:"

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Validacoes do funcionario  								   		³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
    cMsgErro := "" //Limpa variavel que armazena erros

	//CPF
	If Empty((cAliasSRA)->RA_CIC)
		cMsgErro += cItem + OemToAnsi(STR0012)//"CPF esta vazio"
		cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0012)) - Len(cItem))
	EndIf

	//PIS
	If nTipoCarga == 2
		If Empty((cAliasSRA)->RA_PIS) .And. !(cAliasSRA)->RA_CATFUNC $ "E/G"
			cMsgErro += cItem + OemToAnsi(STR0013)//"PIS está vazio e funcionário não é estagiário"
			cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0013)) - Len(cItem))
		EndIf
	Else
		If !Empty((cAliasSRA)->RA_PIS)
			cMsgErro += cItem + OemToAnsi(STR0037)//"PIS está preenchido e foi selecionada a opção de Cadastramento"
 			cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0037)) - Len(cItem))
		Endif
	Endif

	//Nome Completo e Nome
	If Empty((cAliasSRA)->RA_NOMECMP) .And. Empty((cAliasSRA)->RA_NOME)
		cMsgErro += cItem + OemToAnsi(STR0014)//"Nome completo e Nome estão vazios"
		cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0014)) - Len(cItem))
	EndIf

	//Estado de Nascimento
	If (cAliasSRA)->RA_NACIONA == "10" .And. Empty((cAliasSRA)->RA_NATURAL)
		cMsgErro += cItem + OemToAnsi(STR0041)//"Funcionario e Brasileiro Nato e o Estado de Nascimento nao foi preenchido"
		cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0041)) - Len(cItem))
	Endif

	//Municipio de Nascimento
	If (cAliasSRA)->RA_NACIONA == "10" .And. Empty((cAliasSRA)->RA_CODMUNN)
		cMsgErro += cItem + OemToAnsi(STR0042)//"Funcionario e Brasileiro Nato e o Municipio de Nascimento nao foi preenchido"
		cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0042)) - Len(cItem))
	Endif

	//Pais de Origem
	If (cAliasSRA)->RA_BRNASEX == "1" .And. Empty((cAliasSRA)->RA_CPAISOR)
		cMsgErro += cItem + OemToAnsi(STR0043)//"Funcionario e Brasileiro Nascido no Exterior e o pais de origem nao foi preenchido"
		cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0043)) - Len(cItem))
	Endif

	//Data de Chegada
	If (cAliasSRA)->RA_NACIONA != "10" .And. Empty((cAliasSRA)->RA_DATCHEG)
		cMsgErro += cItem + OemToAnsi(STR0044)//"Funcionario e Estrangeiro e a data de chegada ao Brasil nao foi preenchida"
		cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0044)) - Len(cItem))
	Endif

	//Portaria da Naturalizacao
	If (cAliasSRA)->RA_NACIONA == "20" .AND. Empty((cAliasSRA)->RA_NUMNATU)
		cMsgErro += cItem + OemToAnsi(STR0045)//"Funcionario e naturalizado Brasileiro e a Portaria da Naturalizacao nao foi preenchida"
		cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0045)) - Len(cItem))
	Endif

	//Data da Naturalizacao
	If (cAliasSRA)->RA_NACIONA == "20" .AND. Empty((cAliasSRA)->RA_DATNATU)
		cMsgErro += cItem + OemToAnsi(STR0046)//"Funcionario e naturalizado Brasileiro e a Data da Naturalizacao nao foi preenchida"
		cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0046)) - Len(cItem))
	Endif

	//Titulo de Eleitor
	If !Empty((cAliasSRA)->RA_TITULOE)
		If Empty((cAliasSRA)->RA_ZONASEC)
			cMsgErro += cItem + OemToAnsi(STR0047)//"Titulo de eleitor foi informado mas a zona eleitoral nao foi preenchida."
			cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0047)) - Len(cItem))
		Endif
		If Empty((cAliasSRA)->RA_SECAO)
			cMsgErro += cItem + OemToAnsi(STR0048)//"Titulo de eleitor foi informado mas a secao nao foi preenchida."
			cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0048)) - Len(cItem))
		Endif
	Endif

	//Carteira de Identidade
	If (!Empty((cAliasSRA)->RA_RG) .AND. fGP24Org((cAliasSRA)->RA_RGEXP) != "82")
		If Empty((cAliasSRA)->RA_RGEXP)
			cMsgErro += cItem + OemToAnsi(STR0049)//"Carteira de Identidade foi informada mas o Orgao Expeditor esta vazio"
			cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0049)) - Len(cItem))
		Endif
		If Empty((cAliasSRA)->RA_RGUF)
			cMsgErro += cItem + OemToAnsi(STR0050)//"Carteira de Identidade foi informada mas a UF Expeditora esta vazia"
			cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0050)) - Len(cItem))
		Endif
		If Empty((cAliasSRA)->RA_DTRGEXP)
			cMsgErro += cItem + OemToAnsi(STR0051)//"Carteira de Identidade foi informada mas a Data de Emissao esta vazia"
			cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0051)) - Len(cItem))
		Endif
	Endif

	//Carteira de Trabalho
    If Empty((cAliasSRA)->RA_NUMCP)
		cMsgErro += cItem + OemToAnsi(STR0052)//"Numero da Carteira Profissional nao foi informada"
		cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0052)) - Len(cItem))
    Endif
    	If Empty((cAliasSRA)->RA_SERCP)
		cMsgErro += cItem + OemToAnsi(STR0053)//"Serie da Carteria Profissional nao foi informada"
		cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0053)) - Len(cItem))
    Endif
    	If Empty((cAliasSRA)->RA_UFCP)
		cMsgErro += cItem + OemToAnsi(STR0054)//"Unidade Federativa da Carteira Profissional nao foi informada"
		cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0054)) - Len(cItem))
    Endif
    	If Empty((cAliasSRA)->RA_DTCPEXP)
		cMsgErro += cItem + OemToAnsi(STR0055)//"Data de expedicao da Carteria Profissional nao foi informada"
		cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0055)) - Len(cItem))
    Endif

	//Certidao Civil
	If !Empty((cAliasSRA)->RA_TIPCERT)
		If Empty((cAliasSRA)->RA_EMICERT)
			cMsgErro += cItem + OemToAnsi(STR0060)//"A Data de emissao da Certidao nao foi preenchida"
			cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0060)) - Len(cItem))
		Else
			dDataEmis := SToD((cAliasSRA)->RA_EMICERT)
			lAnt2010T := dDataEmis < CtoD("01/01/2010")
		Endif
		If ( ((cAliasSRA)->RA_TIPCERT) == '4' ) //Obrigatorio apenas para 98-Obito
			If Empty((cAliasSRA)->RA_MATCERT)
				cMsgErro += cItem + OemToAnsi(STR0056)//"O Termo da Certidao nao foi preenchido"
				cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0056)) - Len(cItem))
			Endif
			If Empty((cAliasSRA)->RA_LIVCERT)
				cMsgErro += cItem + OemToAnsi(STR0057)//"O Livro da Certidao nao foi preenchido"
				cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0057)) - Len(cItem))
			Endif
			If Empty((cAliasSRA)->RA_FOLCERT)
				cMsgErro += cItem + OemToAnsi(STR0058)//"A Folha da Certidao nao foi preenchida"
				cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0058)) - Len(cItem))
			Endif
		ElseIf !lAnt2010T
			If LEN( AllTrim((cAliasSRA)->RA_MATCERT)) < 32 .AND.(Empty((cAliasSRA)->RA_MATCERT) .OR. Empty((cAliasSRA)->RA_SERVENT) .OR. Empty((cAliasSRA)->RA_CODACER) ;
			.OR. Empty((cAliasSRA)->RA_REGCIVI) .OR. Empty((cAliasSRA)->RA_TPLIVRO))
				cMsgErro += cItem + OemToAnsi(STR0059)//"A Matricula da Certidao nao foi preenchida"
				cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0059)) - Len(cItem))
			Endif
		Endif
		If Empty((cAliasSRA)->RA_CDMUCER)
			cMsgErro += cItem + OemToAnsi(STR0061)//"O Codigo do Municipio da Certidao nao foi preenchido"
			cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0061)) - Len(cItem))
		Endif
		If Empty((cAliasSRA)->RA_UFCERT)
			cMsgErro += cItem + OemToAnsi(STR0062)//"A UF do Municipio da Certidao nao foi preenchida"
			cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0062)) - Len(cItem))
		Endif
		If Empty((cAliasSRA)->RA_CARCERT)
			cMsgErro += cItem + OemToAnsi(STR0063)//"O Nome do Cartorio da Certidao nao foi preenchido"
			cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0063)) - Len(cItem))
		Endif
	Endif

	//Passaporte
	If (!Empty((cAliasSRA)->RA_NUMEPAS))
		If Empty((cAliasSRA)->RA_DEMIPAS)
			cMsgErro += cItem + OemToAnsi(STR0064)//"A data de emissao do passaporte nao foi informada"
			cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0064)) - Len(cItem))
		Endif
		If Empty((cAliasSRA)->RA_EMISPAS)
			cMsgErro += cItem + OemToAnsi(STR0065)//"O orgao emissor do passaporte nao foi informado"
			cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0065)) - Len(cItem))
		Endif
		If(AllTrim(fGP24EmPas((cAliasSRA)->RA_EMISPAS))) == "44"
			If Empty((cAliasSRA)->RA_UFPAS)
				cMsgErro += cItem + OemToAnsi(STR0066)//"A UF de emissao do passaporte nao foi informada"
				cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0066)) - Len(cItem))
			Endif
		Endif
		If Empty((cAliasSRA)->RA_DVALPAS)
			cMsgErro += cItem + OemToAnsi(STR0067)//"A data de validade do passaporte nao foi informada"
			cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0067)) - Len(cItem))
		Endif
		If Empty((cAliasSRA)->RA_CODPAIS)
			cMsgErro += cItem + OemToAnsi(STR0068)//"O pais emissor do passaporte nao foi informado"
			cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0068)) - Len(cItem))
		Endif
	Endif

	//Telefone
	If !Empty((cAliasSRA)->RA_DDDFONE) .OR. !Empty((cAliasSRA)->RA_TELEFON)
		If Empty((cAliasSRA)->RA_DDDFONE)
			cMsgErro += cItem + OemToAnsi(STR0069)//"O DDD do telefone nao foi informado"
			cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0069)) - Len(cItem))
		Endif
		If Empty((cAliasSRA)->RA_TELEFON)
			cMsgErro += cItem + OemToAnsi(STR0070)//"O Numero do telefone nao foi informado"
			cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0070)) - Len(cItem))
		Endif
	Elseif !Empty((cAliasSRA)->RA_DDDCELU) .OR. !Empty((cAliasSRA)->RA_NUMCELU)
		If Empty((cAliasSRA)->RA_DDDCELU)
			cMsgErro += cItem + OemToAnsi(STR0071)//"O DDD do telefone celular nao foi informado"
			cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0071)) - Len(cItem))
		Endif
		If Empty((cAliasSRA)->RA_NUMCELU)
			cMsgErro += cItem + OemToAnsi(STR0072)//"O Numero do telefone celular nao foi informado"
			cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0072)) - Len(cItem))
		Endif
	EndIf

	//Endereco
	If !Empty((cAliasSRA)->RA_LOGRTP) .OR. !Empty((cAliasSRA)->RA_LOGRDSC) .OR. !Empty((cAliasSRA)->RA_LOGRNUM);
	.OR. !Empty((cAliasSRA)->RA_ENDEREC) .OR. !Empty((cAliasSRA)->RA_NUMENDE) .OR. !Empty((cAliasSRA)->RA_CEP);
	.OR. !Empty((cAliasSRA)->RA_TIPENDE)
		aEnd := fGP24end((cAliasSRA)->RA_LOGRTP,(cAliasSRA)->RA_LOGRDSC, (cAliasSRA)->RA_LOGRNUM,(cAliasSRA)->RA_ENDEREC,(cAliasSRA)->RA_NUMENDE)
		If Empty((cAliasSRA)->RA_TIPENDE)
			cMsgErro += cItem + OemToAnsi(STR0073)//"O Tipo do endereco nao foi informado"
			cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0073)) - Len(cItem))
		Endif
		If Empty((cAliasSRA)->RA_CEP)
			cMsgErro += cItem + OemToAnsi(STR0074)//"O CEP do endereco nao foi informado"
			cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0074)) - Len(cItem))
		Endif
		If Empty(aEnd[1])
			cMsgErro += cItem + OemToAnsi(STR0075)//"O tipo do logradouro nao foi informado"
			cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0075)) - Len(cItem))
		Endif
		If Empty(aEnd[2])
			cMsgErro += cItem + OemToAnsi(STR0076)//"O logradouro nao foi informado"
			cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0076)) - Len(cItem))
		Endif
		If Empty(aEnd[3])
			cMsgErro += cItem + OemToAnsi(STR0077)//"A sigla da posicao determinante nao foi informada"
			cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0077)) - Len(cItem))
		Endif
		If Empty(aEnd[4])
			cMsgErro += cItem + OemToAnsi(STR0078)//"A posicao determinante nao foi informada"
			cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0078)) - Len(cItem))
		Endif
		If Empty((cAliasSRA)->RA_BAIRRO)
			cMsgErro += cItem + OemToAnsi(STR0079)//"O CEP do endereco nao foi informado"
			cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0079)) - Len(cItem))
		Endif
		If Empty((cAliasSRA)->RA_ESTADO)
			cMsgErro += cItem + OemToAnsi(STR0080)//"A UF do endereco nao foi informada"
			cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0080)) - Len(cItem))
		Endif
		If Empty((cAliasSRA)->RA_CODMUN)
			cMsgErro += cItem + OemToAnsi(STR0081)//"O Municipio do endereco nao foi informado"
			cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0081)) - Len(cItem))
		Endif
		aEnd := {}
	Endif
	If !Empty((cAliasSRA)->RA_CPOSTAL) .OR. !Empty((cAliasSRA)->RA_CEPCXPO)
		If Empty((cAliasSRA)->RA_CPOSTAL)
			cMsgErro += cItem + OemToAnsi(STR0082)//"O numero da caixa postal nao foi informado"
			cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0082)) - Len(cItem))
		Endif
		If Empty((cAliasSRA)->RA_CEPCXPO)
			cMsgErro += cItem + OemToAnsi(STR0083)//"O CEP da caixa postal nao foi informado"
			cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0083)) - Len(cItem))
		Endif
	Endif

	//Dados do Vinculo
	If aInfo[15] == 1
		If Empty(aInfo[27])
			cMsgErro += cItem + OemToAnsi(STR0084)//"O numero do CEI nao foi informado"
			cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0084)) - Len(cItem))
		Endif
	ElseIf aInfo[15] == 2
		If Empty(aInfo[8])
			cMsgErro += cItem + OemToAnsi(STR0085)//"O numero do CNPJ nao foi informado"
			cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0085)) - Len(cItem))
		Endif
	Endif
	If Empty((cAliasSRA)->RA_ADMISSA)
		cMsgErro += cItem + OemToAnsi(STR0086)//"A data de Admissao do funcionario nao foi informada"
		cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0086)) - Len(cItem))
	Endif

 	If Empty(cMsgErro) //Adiciona informacoes no array

		If cCFilial != (cAliasSRA)->RA_FILIAL
			If !lCompleta .and. Empty(cFilCentra)
		        aAdd(aFilArq,{cCFilial})
			    cVArq:= fGp24NmArq(.F.,cCFilial)
				aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+'99999999999'+'99'+STRZERO(nSeqReg99++, 3),'0908','00','00'+cVArq+space(180-len(cVArq))+space(32)+cNISRet+cRetorno  } )
				aAdd( aInfoSRA, {STRZERO(nOrdFisic, 11)+cCodOri+'99999999999'+'99'+STRZERO(nSeqReg99++, 3),'0912','00','00'+strzero(nOrdFisic,9,0)+space(171)+space(32)+cNISRet+cRetorno  } )
				aAdd(aInfoAll,aInfoSRA)
				aInfoSRA:= {}
				cCFilAnt := cCFilial
				cCFilial := (cAliasSRA)->RA_FILIAL
				fInfo(@aInfo,cCFilial)
				nOrdFisic := 1
				lUltima := .T.

				//Tipo de Registro 00 - Header Geral
				aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+"00000000000"+'00'+STRZERO(nSeqReg00++, 3),'0900','00',"00"+ "C"+SPACE(179)+SPACE(32)+cNISRet+cRetorno  } )
				aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+"00000000000"+'00'+STRZERO(nSeqReg00++, 3),'0829','00',"00"+ If(aInfo[15] == 1,aInfo[27]+SPACE(180-LEN(aInfo[27])),aInfo[8]+SPACE(180-LEN(aInfo[8])))+space(32)+cNISRet+cRetorno  } )
				aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+"00000000000"+'00'+STRZERO(nSeqReg00++, 3),'0313','00','00'+ aInfo[3]+sPACE(180-LEN(aInfo[3]))+space(32)+cNISRet+cRetorno  } )
				aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+"00000000000"+'00'+STRZERO(nSeqReg00++, 3),'0413','00','00'+ cTpRemes+space(180-len(cTpRemes))+space(32)+cNISRet+cRetorno  } )
				aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+"00000000000"+'00'+STRZERO(nSeqReg00++, 3),'0903','00',"00"+ Day2Str(date())+  Month2Str(date()) + Year2Str(date())+space(172)+space(32)+cNISRet+cRetorno  } )
				aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+"00000000000"+'00'+STRZERO(nSeqReg00++, 3),'0913','00',"00"+ "0013"+space(176)+space(32)+cNISRet+cRetorno  } )
			ElseIf lCompleta
				aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+"99999999999"+'98'+STRZERO(nSeqReg98++, 3),'0378','00',"00"+ aInfo[8]+SPACE(180-LEN(aInfo[8]))+space(32)+cNISRet+cRetorno  } )
				nSeqReg02C += 2
				aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+'99999999999'+'98'+STRZERO(nSeqReg98, 3),'0912','00','00'+strzero(nSeqReg02C,9,0)+space(180-len(AllTrim(strzero(nSeqReg02C,9,0))) )+space(32)+cNISRet+cRetorno  } )
				nSeqReg02C:= 0
				cCFilial := (cAliasSRA)->RA_FILIAL
				fInfo(@aInfo,cCFilial)
				nContFil++

				//Tipo de Registro 01 - Header Parcial
			If !Empty(aInfo[8])
				aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+"00000000000"+'01'+STRZERO(nSeqReg00++, 3),'0378','00',"00"+ aInfo[8]+SPACE(180-LEN(aInfo[8]))+space(32)+cNISRet+cRetorno  } )
				nSeqReg02C += 1
			Endif
			If !Empty(aInfo[27])
				aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+"00000000000"+'01'+STRZERO(nSeqReg00++, 3),'0379','00',"00"+ If(!Empty(aInfo[27]),aInfo[27],Replicate("0",12)+SPACE(168))+space(32)+cNISRet+cRetorno  } )
				nSeqReg02C += 1
			Endif
			aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+"00000000000"+'01'+STRZERO(nSeqReg00++, 3),'0104','00','00'+ aInfo[3]+sPACE(180-LEN(aInfo[3]))+space(32)+cNISRet+cRetorno  } )
			nSeqReg02C += 1
		Endif


	Endif

		//Busca todos os campos para geracao do arquivo
	   	cNIS:= If (nTipoCarga == 1, Replicate("0",11),fGP24str((cAliasSRA)->RA_PIS,,11))
	   	nSeqReg00 := 0
		nSeqReg02 := 0
		nSeqReg99 := 0
		nSeqReg98 := 0

		If lPrimeira
			If lCompleta
				//Tipo de Registro 00 - Header Geral
				aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+"00000000000"+'00'+STRZERO(nSeqReg00++, 3),'0900','00',"00"+ "C"+space(179)+space(32)+cNISRet+cRetorno  } )
				aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+"00000000000"+'00'+STRZERO(nSeqReg00++, 3),'0829','00',"00"+ If(aInfoCompl[15] == 1,aInfoCompl[27]+SPACE(180-LEN(aInfoCompl[27])),aInfoCompl[8]+SPACE(180-LEN(aInfoCompl[8])))+space(32)+cNISRet+cRetorno  } )
				aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+"00000000000"+'00'+STRZERO(nSeqReg00++, 3),'0313','00',"00"+ aInfoCompl[3]+space(180-len(aInfoCompl[3]))+space(32)+cNISRet+cRetorno  } )
				aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+"00000000000"+'00'+STRZERO(nSeqReg00++, 3),'0413','00',"00"+ cTpRemes+space(179)+space(32)+cNISRet+cRetorno  } )
				aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+"00000000000"+'00'+STRZERO(nSeqReg00++, 3),'0903','00',"00"+ Day2Str(date())+  Month2Str(date()) + Year2Str(date())+space(172)+space(32)+cNISRet+cRetorno  } )
				aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+"00000000000"+'00'+STRZERO(nSeqReg00++, 3),'0913','00',"00"+ "0003"+space(176)+space(32)+cNISRet+cRetorno  } )

				//Tipo de Registro 01 - Header Parcial
				If !Empty(aInfo[8])
					aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+"00000000000"+'01'+STRZERO(nSeqReg00++, 3),'0378','00',"00"+ aInfo[8]+SPACE(180-LEN(aInfo[8]))+space(32)+cNISRet+cRetorno  } )
					nSeqReg02C += 1
				Endif
				If !Empty(aInfo[27])
					aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+"00000000000"+'01'+STRZERO(nSeqReg00++, 3),'0379','00',"00"+ If(!Empty(aInfo[27]),aInfo[27],Replicate("0",12)+SPACE(168))+space(32)+cNISRet+cRetorno  } )
					nSeqReg02C += 1
				Endif
					aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+"00000000000"+'01'+STRZERO(nSeqReg00++, 3),'0104','00','00'+ aInfo[3]+sPACE(180-LEN(aInfo[3]))+space(32)+cNISRet+cRetorno  } )

				nSeqReg02C += 1
			Else
				//Tipo de Registro 00 - Header Geral
				aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+"00000000000"+'00'+STRZERO(nSeqReg00++, 3),'0900','00',"00"+ "C"+space(179)+space(32)+cNISRet+cRetorno  } )
				aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+"00000000000"+'00'+STRZERO(nSeqReg00++, 3),'0829','00',"00"+ If(aInfo[15] == 1,aInfo[27]+SPACE(180-LEN(aInfo[27])),aInfo[8]+SPACE(180-LEN(aInfo[8])))+space(32)+cNISRet+cRetorno  } )
				aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+"00000000000"+'00'+STRZERO(nSeqReg00++, 3),'0313','00',"00"+ aInfo[3]+space(180-len(aInfo[3]))+space(32)+cNISRet+cRetorno  } )
				aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+"00000000000"+'00'+STRZERO(nSeqReg00++, 3),'0413','00',"00"+ cTpRemes+space(179)+space(32)+cNISRet+cRetorno  } )
				aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+"00000000000"+'00'+STRZERO(nSeqReg00++, 3),'0903','00',"00"+ Day2Str(date())+  Month2Str(date()) + Year2Str(date())+space(172)+space(32)+cNISRet+cRetorno  } )
				aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+"00000000000"+'00'+STRZERO(nSeqReg00++, 3),'0913','00',"00"+ "0013"+space(176)+space(32)+cNISRet+cRetorno  } )

			Endif
			lPrimeira := .F.
		Endif

		//Tipo de Registro 02
		aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0902','00',"00"+"I"+space(179)+space(32)+cNISRet+cRetorno } )
		nSeqReg02C++
		//Enviar o PIS ou o CPF do atendente e nao os 2 ao mesmo tempo.
		If !Empty(cNISAtend)
			aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0418','00',"00"+STRZERO(VAL(cNISAtend),11,0)+space(180-len(STRZERO(VAL(cNISAtend),11,0)))+space(32)+cNISRet+cRetorno } )
			nSeqReg02C++
		ElseIf !Empty(cCPFAtend)
			aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0419','00',"00"+STRZERO(VAL(cCPFAtend),11,0)+space(180-len(STRZERO(VAL(cCPFAtend),11,0)))+space(32)+cNISRet+cRetorno } )
			nSeqReg02C++
		Endif
		aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0195','00',"00"+ fGP24str((cAliasSRA)->RA_NOMECMP, (cAliasSRA)->RA_NOME, 180)+space(32)+cNISRet+cRetorno } )
		aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0197','00',"00"+ substr((cAliasSRA)->RA_NASC,7,2)+  substr((cAliasSRA)->RA_NASC,5,2) + substr((cAliasSRA)->RA_NASC,1,4)+space(172)+space(32)+cNISRet+cRetorno  } )
		aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0200','00',"00"+ fGP24str((cAliasSRA)->RA_MAE,,180,.F.,.T.,,"M")+space(32)+cNISRet+cRetorno } ) //Se vazio preeenchera com ignorada
		aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0199','00',"00"+ fGP24str((cAliasSRA)->RA_PAI,,180,.F.,.T.,,"P")+space(32)+cNISRet+cRetorno } ) //Se vazio preeenchera com ignorado
		nSeqReg02C+=4
		If (cAliasSRA)->RA_NACIONA == "10" .AND. !Empty((cAliasSRA)->RA_NATURAL) .AND. !Empty((cAliasSRA)->RA_CODMUNN)
			aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0390','00',"00"+ Gp024CodUF((cAliasSRA)->RA_NATURAL)+(cAliasSRA)->RA_CODMUNN+space(180-len((cAliasSRA)->RA_NATURAL+(cAliasSRA)->RA_CODMUNN))+space(32)+cNISRet+cRetorno  } )
			nSeqReg02C++
		Endif

		aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0201','00',"00"+ fGP24str((cAliasSRA)->RA_SEXO,,180)+space(32)+cNISRet+cRetorno} )
		nSeqReg02C++
		If !Empty(fGP24Raca((cAliasSRA)->RA_RACACOR))
			aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0206','00',"00"+ fGP24Raca((cAliasSRA)->RA_RACACOR)+space(32)+cNISRet+cRetorno} )
			nSeqReg02C++
		Endif

		If !Empty(fGP24Niv((cAliasSRA)->RA_GRINRAI))
			aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0008','00',"00"+ fGP24Niv((cAliasSRA)->RA_GRINRAI)+space(32)+cNISRet+cRetorno} )
			nSeqReg02C++
		Endif

		If !Empty(fGP24Civ((cAliasSRA)->RA_ESTCIVI))
			aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0389','00',"00"+ fGP24Civ((cAliasSRA)->RA_ESTCIVI)+space(32)+cNISRet+cRetorno} )
			nSeqReg02C++
		Endif

		aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0386','00',"00"+ fGP24Nac((cAliasSRA)->RA_NACIONA, ,(cAliasSRA)->RA_CPAISOR)+space(32)+cNISRet+cRetorno} )
		aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0386','01',"00"+ fGP24Nac((cAliasSRA)->RA_NACIONA, (cAliasSRA)->RA_BRNASEX, (cAliasSRA)->RA_CPAISOR,.T.)+space(32)+cNISRet+cRetorno} )
      	nSeqReg02C+=2
      	If (cAliasSRA)->RA_BRNASEX == "1"
			aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0387','00',"00"+ fGP24Nac((cAliasSRA)->RA_NACIONA, (cAliasSRA)->RA_BRNASEX, (cAliasSRA)->RA_CPAISOR,.F.,.T.)+space(32)+cNISRet+cRetorno} ) //ira tratar pais de origem
			nSeqReg02C++
		Endif
		aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0370','00',"00"+ STRZERO(VAL((cAliasSRA)->RA_CIC),11,0)+space(180-len(STRZERO(VAL((cAliasSRA)->RA_CIC),11,0)))+space(32)+cNISRet+cRetorno })
		//Titulo de Eleitor
		If !Empty((cAliasSRA)->RA_TITULOE) .AND. !Empty((cAliasSRA)->RA_ZONASEC) .AND. !Empty((cAliasSRA)->RA_SECAO)
			aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0371','00',"00"+ STRZERO(VAL((cAliasSRA)->RA_TITULOE),13,0)+space(180-len(STRZERO(VAL((cAliasSRA)->RA_TITULOE),13,0)))+space(32)+cNISRet+cRetorno } )
			aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0371','01',"00"+ STRZERO(VAL(substr((cAliasSRA)->RA_ZONASEC,1,4)),4,0)+space(180-len(STRZERO(VAL(substr((cAliasSRA)->RA_ZONASEC,1,4)),4,0)))+space(32)+cNISRet+cRetorno } )
			aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0371','02',"00"+ STRZERO(VAL((cAliasSRA)->RA_SECAO),4,0)+space(180-len(STRZERO(VAL((cAliasSRA)->RA_SECAO),4,0)))+space(32)+cNISRet+cRetorno } )
			nSeqReg02C+=3
		Endif

		//Carteira de Identidade
		If (!Empty((cAliasSRA)->RA_RG) .AND. !Empty((cAliasSRA)->RA_RGUF) .AND. !Empty((cAliasSRA)->RA_DTRGEXP) .AND. !Empty((cAliasSRA)->RA_RGEXP)) .OR. (!Empty((cAliasSRA)->RA_RG) .AND. fGP24Org((cAliasSRA)->RA_RGEXP) == "82")
			aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0372','00',"00"+ fGP24Ident((cAliasSRA)->RA_RG)+space(32)+cNISRet+cRetorno } )
			aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0372','01',"00"+ fGP24str((cAliasSRA)->RA_COMPLRG,,180)+space(32)+cNISRet+cRetorno } )
			aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0372','02',"00"+ fGP24str((cAliasSRA)->RA_RGUF,, 180)+space(32)+cNISRet+cRetorno } )
			aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0372','03',"00"+ substr((cAliasSRA)->RA_DTRGEXP,7,2)+  substr((cAliasSRA)->RA_DTRGEXP,5,2) + substr((cAliasSRA)->RA_DTRGEXP,1,4)+space(172)+space(32)+cNISRet+cRetorno  } )
			aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0372','04',"00"+ fGP24Org((cAliasSRA)->RA_RGEXP)+space(32)+cNISRet+cRetorno  } )
			nSeqReg02C+=5
		Endif

		//Carteira de Trabalho
		aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0373','00',"00"+ STRZERO(VAL((cAliasSRA)->RA_NUMCP),7,0)+space(180-len(STRZERO(VAL((cAliasSRA)->RA_NUMCP),7,0)))+space(32)+cNISRet+cRetorno } )
		aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0373','01',"00"+ STRZERO(VAL((cAliasSRA)->RA_SERCP),5,0)+space(180-len(STRZERO(VAL((cAliasSRA)->RA_SERCP),5,0)))+space(32)+cNISRet+cRetorno } )
		aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0373','02',"00"+ fGP24str((cAliasSRA)->RA_UFCP,, 180)+space(32)+cNISRet+cRetorno } )
       aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0373','03',"00"+ substr((cAliasSRA)->RA_DTCPEXP,7,2)+  substr((cAliasSRA)->RA_DTCPEXP,5,2) + substr((cAliasSRA)->RA_DTCPEXP,1,4)+space(172)+space(32)+cNISRet+cRetorno})
	   nSeqReg02C+=4
		//Certidao Civil
		If !Empty((cAliasSRA)->RA_TIPCERT)
			cCodCmp := fGp24Cert((cAliasSRA)->RA_TIPCERT, .T.)
		Endif
  		If !Empty((cAliasSRA)->RA_TIPCERT) .AND. !Empty((cAliasSRA)->RA_EMICERT) .AND. !Empty((cAliasSRA)->RA_MATCERT) .AND. !Empty((cAliasSRA)->RA_CDMUCER) .AND. !Empty((cAliasSRA)->RA_UFCERT) .AND. !Empty((cAliasSRA)->RA_CARCERT)

			aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),cCodCmp,'00',"00"+ fGP24Cert((cAliasSRA)->RA_TIPCERT)+space(210)+cNISRet+cRetorno   })
			aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),cCodCmp,'01',"00"+ substr((cAliasSRA)->RA_EMICERT,7,2)+  substr((cAliasSRA)->RA_EMICERT,5,2) + substr((cAliasSRA)->RA_EMICERT,1,4)+space(172)+space(32)+cNISRet+cRetorno   })
			aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),cCodCmp,'02',"00"+ fGP24Termo()+space(180-len(fGP24Termo()))+space(32)+cNISRet+cRetorno } )
			aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),cCodCmp,'03',"00"+ Gp024CodUF((cAliasSRA)->RA_UFCERT)+fGP24str((cAliasSRA)->RA_CDMUCER,,178)+space(32)+cNISRet+cRetorno } )
			aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),cCodCmp,'04',"00"+ fGP24str((cAliasSRA)->RA_UFCERT,,180) +space(32)+cNISRet+cRetorno })
			aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),cCodCmp,'05',"00"+ fGP24str((cAliasSRA)->RA_CARCERT,, 180)+space(32)+cNISRet+cRetorno } )
 			nSeqReg02C+=6
			dData := SToD((cAliasSRA)->RA_EMICERT)
			If dData  < CtoD("01/01/2010") .OR. ((cAliasSRA)->RA_TIPCERT) == "4"
				aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),cCodCmp,'06',"00"+ fGP24str((cAliasSRA)->RA_LIVCERT,, 180)+space(32)+cNISRet+cRetorno } )
				aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),cCodCmp,'07',"00"+ fGP24str((cAliasSRA)->RA_FOLCERT,, 180)+space(32)+cNISRet+cRetorno } )
				nSeqReg02C+=2
			EndIf
		Endif

		//Passaporte
		If (!Empty((cAliasSRA)->RA_NUMEPAS) .AND. !Empty((cAliasSRA)->RA_DEMIPAS) .AND. !Empty((cAliasSRA)->RA_EMISPAS) .AND. !Empty((cAliasSRA)->RA_DVALPAS) .AND. !Empty((cAliasSRA)->RA_CODPAIS))
			aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0377','00',"00"+ fGP24str((cAliasSRA)->RA_NUMEPAS,, 180)+space(32)+cNISRet+cRetorno } )
			If (fGP24EmPas((cAliasSRA)->RA_EMISPAS)) != "82"
				aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0377','01',"00"+ fGP24str((cAliasSRA)->RA_UFPAS,, 180)+space(32)+cNISRet+cRetorno } )
				nSeqReg02C++
			Endif
			aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0377','02',"00"+ substr((cAliasSRA)->RA_DEMIPAS,7,2)+  substr((cAliasSRA)->RA_DEMIPAS,5,2) + substr((cAliasSRA)->RA_DEMIPAS,1,4)+space(172)+space(32)+cNISRet+cRetorno  } )
			aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0377','03',"00"+ fGP24EmPas((cAliasSRA)->RA_EMISPAS)+space(32)+cNISRet+cRetorno  } )
			aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0377','04',"00"+ substr((cAliasSRA)->RA_DVALPAS,7,2)+  substr((cAliasSRA)->RA_DVALPAS,5,2) + substr((cAliasSRA)->RA_DVALPAS,1,4)+space(172)+space(32)+cNISRet+cRetorno  } )
			aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0377','05',"00"+ fGP24Nac(, ,(cAliasSRA)->RA_CODPAIS , , ,.T.)+space(32)+cNISRet+cRetorno  } )
			nSeqReg02C+=4
		Endif

		//Estrangeiro
		If !(cAliasSRA)->RA_NACIONA $ "10" .AND. !Empty((cAliasSRA)->RA_DATCHEG)
			aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0391','00',"00"+ substr((cAliasSRA)->RA_DATCHEG,7,2)+  substr((cAliasSRA)->RA_DATCHEG,5,2) + substr((cAliasSRA)->RA_DATCHEG,1,4)+space(172)+space(32)+cNISRet+cRetorno  } )
			nSeqReg02C++
		EndIf

		If (cAliasSRA)->RA_NACIONA == "20" .AND. !Empty((cAliasSRA)->RA_NUMNATU) .AND. !Empty((cAliasSRA)->RA_DATNATU)
			aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0401','00',"00"+ STRZERO(VAL((cAliasSRA)->RA_NUMNATU),16,0)+space(180-len(STRZERO(VAL((cAliasSRA)->RA_NUMNATU),16,0)))+space(32)+cNISRet+cRetorno  } )
			aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0815','00',"00"+substr((cAliasSRA)->RA_DATNATU,7,2)+  substr((cAliasSRA)->RA_DATNATU,5,2) + substr((cAliasSRA)->RA_DATNATU,1,4)+space(172)+space(32)+cNISRet+cRetorno  } )
			nSeqReg02C+=2
		EndIf

		// No leiaute de versao 12(CEF) nao constam mais os codigos de campo para o RIC como constavam no leiaute versao 9
		// A geracao dos campos do RIC ficara comentada pois possivelmente ocorreu algum engano no leiaute versao 12.

		//Registro de Identidade Civil
		/*
 		If !Empty((cAliasSRA)->RA_NUMRIC) .AND. !Empty((cAliasSRA)->RA_EMISRIC) .AND. !Empty(RA_UFRIC) .AND. !Empty((cAliasSRA)->RA_CDMURIC) .AND. !Empty((cAliasSRA)->RA_DEXPRIC)
			aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0416','00',"00"+ fGP24str((cAliasSRA)->RA_NUMRIC,, 180)+space(32)+cNISRet+cRetorno  } )
			aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0416','01',"00"+ fGP24Org((cAliasSRA)->RA_EMISRIC)+space(32)+cNISRet+cRetorno  } )
			aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0416','02',"00"+ ((cAliasSRA)->RA_UFRIC+ (cAliasSRA)->RA_CDMURIC)+SPACE(173)+space(32)+cNISRet+cRetorno  } )
			aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0416','03',"00"+ substr((cAliasSRA)->RA_DEXPRIC,7,2)+  substr((cAliasSRA)->RA_DEXPRIC,5,2) + substr((cAliasSRA)->RA_DEXPRIC,1,4)+space(172)+space(32)+cNISRet+cRetorno  } )
   		EndIf
		*/

		//Telefone
		If !Empty((cAliasSRA)->RA_DDDFONE) .AND. !Empty((cAliasSRA)->RA_TELEFON)
			aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0809','00',"00"+ STRZERO(VAL((cAliasSRA)->RA_DDDFONE),3,0)+space(180-len(STRZERO(VAL((cAliasSRA)->RA_DDDFONE),3,0)))+space(32)+cNISRet+cRetorno })
			aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0809','01',"00"+ STRZERO(VAL(fGP24Fone((cAliasSRA)->RA_TELEFON)),9,0)+space(180-len(STRZERO(VAL((cAliasSRA)->RA_TELEFON),9,0)))+space(32)+cNISRet+cRetorno  } )  //Numero
			aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0809','02',"00"+ "1"+SPACE(179)+space(32)+cNISRet+cRetorno  } )  //Tipo (1=Residencial, 7=Celular)
			nSeqReg02C+=3
		Elseif !Empty((cAliasSRA)->RA_DDDCELU) .AND. !Empty((cAliasSRA)->RA_NUMCELU)
			aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0809','00',"00"+ STRZERO(VAL((cAliasSRA)->RA_DDDCELU),3,0)+space(180-len(STRZERO(VAL((cAliasSRA)->RA_DDDCELU),3,0)))+space(32)+cNISRet+cRetorno }) //DDD
			aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0809','01',"00"+ STRZERO(VAL(fGP24Fone((cAliasSRA)->RA_NUMCELU)),9,0)+space(180-len(STRZERO(VAL((cAliasSRA)->RA_NUMCELU),9,0)))+space(32)+cNISRet+cRetorno  } ) //Numero
			aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0809','02',"00"+ "7" +space(179)+space(32)+cNISRet+cRetorno  } )  //Tipo (1=Residencial, 7=Celular)
			nSeqReg02C+=3
		EndIf

		//E-mail
		If !Empty((cAliasSRA)->RA_EMAIL)
			aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0810','00',"00"+ fGP24str((cAliasSRA)->RA_EMAIL, , 180)+space(32)+cNISRet+cRetorno  } )
			nSeqReg02C++
		Endif

		//Endereco
		aEndereco := fGP24end((cAliasSRA)->RA_LOGRTP,(cAliasSRA)->RA_LOGRDSC, (cAliasSRA)->RA_LOGRNUM,(cAliasSRA)->RA_ENDEREC,(cAliasSRA)->RA_NUMENDE)
		aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0911','00',"00"+ fGP24str((cAliasSRA)->RA_CEP,, 180)+space(32)+cNISRet+cRetorno } ) //Esta numerico, mas CEP tem hifen
		aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0911','01',"00"+ IIf((cAliasSRA)->RA_TIPENDE == '2' .OR. EMPTY((cAliasSRA)->RA_TIPENDE),'1','3')+space(179)+space(32)+cNISRet+cRetorno } )
		nSeqReg02C+=2
		If len(aEndereco[1])<>0
			aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0911','02',"00"+ aEndereco[1]+space(180-len(aEndereco[1]))+space(32)+cNISRet+cRetorno } )
			nSeqReg02C++
		Endif
		If len(aEndereco[2])<>0
			aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0911','03',"00"+ aEndereco[2]+space(180-len(aEndereco[2]))+space(32)+cNISRet+cRetorno } )
			nSeqReg02C++
		Endif
		If len(aEndereco[3])<>0
			aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0911','04',"00"+ aEndereco[3]+space(180-len(aEndereco[3]))+space(32)+cNISRet+cRetorno } )
			nSeqReg02C++
		Endif
		If len(aEndereco[4])<>0
			aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0911','05',"00"+ aEndereco[4]+space(180-len(aEndereco[4]))+space(32)+cNISRet+cRetorno } )
			nSeqReg02C++
		Endif
		aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0911','06',"00"+ fGP24str((cAliasSRA)->RA_COMPLEM,,180)+space(32)+cNISRet+cRetorno } )
		nSeqReg02C++
		If !empty((cAliasSRA)->RA_BAIRRO)
			aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0911','07',"00"+ fGP24str((cAliasSRA)->RA_BAIRRO,,180)+space(32)+cNISRet+cRetorno } )
			nSeqReg02C++
		Endif
		If !Empty((cAliasSRA)->RA_ESTADO) .and. !Empty((cAliasSRA)->RA_CODMUN)
			aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0911','08',"00"+ (Gp024CodUF((cAliasSRA)->RA_ESTADO)+(cAliasSRA)->RA_CODMUN)+space(173)+space(32)+cNISRet+cRetorno } )
			nSeqReg02C++
		Endif
		//Caixa Postal
		If !Empty((cAliasSRA)->RA_CPOSTAL) .AND. !Empty((cAliasSRA)->RA_CEPCXPO)
			aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0938','00',"00"+ STRZERO(VAL((cAliasSRA)->RA_CPOSTAL),15,0)+space(180-len(STRZERO(VAL((cAliasSRA)->RA_CPOSTAL),15,0)))+space(32)+cNISRet+cRetorno  } )
			aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0938','01',"00"+ fGP24str((cAliasSRA)->RA_CEPCXPO,, 180)+space(32)+cNISRet+cRetorno  } )
        	nSeqReg02C+=2
        Endif

		//Dados do Vinculo
		aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0292','00',"00"+ If(aInfo[15] == 1,"60","59")+space(178)+space(32)+cNISRet+cRetorno  } )
		aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0292','01',"00"+ If(aInfo[15] == 1,STRZERO(VAL(aInfo[27]),14,0)+space(180-Len(STRZERO(VAL(aInfo[27]),14,0))),STRZERO(VAL(aInfo[8]),14,0)+space(180-Len(STRZERO(VAL(aInfo[8]),14,0))))+space(32)+cNISRet+cRetorno  } )
		aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+cNIS+'02'+STRZERO(nSeqReg02++, 3),'0292','02',"00"+substr((cAliasSRA)->RA_ADMISSA,7,2)+  substr((cAliasSRA)->RA_ADMISSA,5,2) + substr((cAliasSRA)->RA_ADMISSA,1,4)+space(172)+space(32)+cNISRet+cRetorno  } )
 		nSeqReg02C+=3

 		//Tratamento para funcionarios multiplos vinculos
 		If (cAliasSRA)->RA_OCORREN $ "05/06/07/08"
			cLogMultV 	:= 	DToC(dDataBase) + " - " + AllTrim((cAliasSRA)->RA_FILIAL) + " - "
			cLogMultV	+= 	Alltrim((cAliasSRA)->RA_CIC) + " - " + AllTrim((cAliasSRA)->RA_MAT) + " - " + AllTrim((cAliasSRA)->RA_NOME)
			//Tratamento para tamanho do Log de funcionarios gerados no arquivo com multiplos vinculos.
	 		If Len(cLogMultV) <= TAMIMP
	 			aAdd(aLogMultV, cLogMultV)
	 		Else
	 			aAdd(aLogMultV, Subs(cLogMultV, 1, TAMIMP))
	 			aAdd(aLogMultV, Subs(cLogMultV, TAMIMP + 1, Len(cLogMultV) - TAMIMP))
	 		EndIf
		Endif

 		//Tratamento para funcionarios gerados no arquivo - LOG
 		cLogGera	:= 	DToC(dDataBase) + " - " + AllTrim((cAliasSRA)->RA_FILIAL) + " - "
 		cLogGera	+= 	AllTrim((cAliasSRA)->RA_MAT) + " - " + AllTrim((cAliasSRA)->RA_NOME)

		//Tratamento para tamanho do Log de funcionarios gerados no arquivo.
 		If Len(cLogGera) <= TAMIMP
 			aAdd(aLogGera, cLogGera)
 		Else
 			aAdd(aLogGera, Subs(cLogGera, 1, TAMIMP))
 			aAdd(aLogGera, Subs(cLogGera, TAMIMP + 1, Len(cLogGera) - TAMIMP))
 		EndIf
	Else //Adiciona Registro no Log
		cMsgAux := DToC(dDataBase) + " - " + AllTrim((cAliasSRA)->RA_FILIAL) + " - "
		cMsgAux += AllTrim((cAliasSRA)->RA_MAT) + " - " + AllTrim((cAliasSRA)->RA_NOME) + " : "
		cMsgAux += space(TAMIMP - Len(cMsgAux))
        cMsgAux += cMsgErro
		cMsgErro := cMsgAux

		//Tratamento para tamanho do Log
		If Len(cMsgErro) <= TAMIMP
			aAdd(aLogProc, cMsgErro)
		Else
			aAdd(aLogProc, Subs(cMsgErro, 1, TAMIMP))
			For nTam:= 1 to Int(Len(cMsgErro)/TAMIMP)
				aAdd(aLogProc, Subs(cMsgErro, TAMIMP * nTam + 1, TAMIMP))
			Next nTam
		EndIf
    EndIf

	(cAliasSRA)->(dbSkip())
EndDo

//Se algum funcionario foi gerado no arquivo adiciona no log.
If Len(aLogGera) > 0
	Aadd( aLogProc,{})
	Aadd( aLogProc, OemToAnsi(STR0039))
	Aadd( aLogProc,{})
	For nGera = 1 to Len(aLogGera)
		aAdd(aLogProc,aLogGera[nGera])
	Next nGera
Endif

If Len(aLogMultV) > 0
	Aadd( aLogProc,{})
	Aadd( aLogProc, OemToAnsi(STR0039) + " " + OemToAnsi(STR0040) )
	Aadd( aLogProc,{})
	For nGera = 1 to Len(aLogMultV)
		aAdd(aLogProc,aLogMultV[nGera])
	Next nGera
Endif

If cCFilial != cFilAnt .OR. !lUltima
	If !Empty(cFilCentra)
		cCFilial := cFilCentra
		cVArq:= fGp24NmArq(.F.,cCFilial)
	ElseIf cCFilial != cFilAnt .And. !lCompleta
		nCntVersao++
    	cVArq:= fGp24NmArq(.F.,cCFilial,.T.,nCntVersao)
	Else
		cVArq:= fGp24NmArq(.F.,cCFilial)
	Endif
	If lCompleta
		aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+"99999999999"+'98'+STRZERO(nSeqReg98++, 3),'0378','00',"00"+ aInfo[8]+SPACE(180-LEN(aInfo[8]))+space(32)+cNISRet+cRetorno  } )
		nSeqReg02C += 2
		aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+'99999999999'+'98'+STRZERO(nSeqReg98++, 3),'0912','00','00'+strzero(nSeqReg02C,9,0)+space(180-len(AllTrim(strzero(nSeqReg02C,9,0))) )+space(32)+cNISRet+cRetorno  } )
    	nSeqReg02C:= 0
		nContFil++
	Endif

	If lCompleta
		aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+'99999999999'+'98'+STRZERO(nSeqReg98++, 3),'0420','00',"00"+STRZERO(nContFil,9,0) +space(180-len(AllTrim(STRZERO(nContFil ,9,0))) ) +space(32)+cNISRet+cRetorno  } )
	Endif
	aAdd( aInfoSRA, {STRZERO(nOrdFisic++, 11)+cCodOri+'99999999999'+'99'+STRZERO(nSeqReg99++, 3),'0908','00',"00"+cVArq+space(180-len(cVArq))+space(32)+cNISRet+cRetorno  } )
	aAdd( aInfoSRA, {STRZERO(nOrdFisic, 11)+cCodOri+'99999999999'+'99'+STRZERO(nSeqReg99++, 3),'0912','00',"00"+strzero(nOrdFisic,9,0)+space(180-len(AllTrim(strzero(nOrdFisic,9,0))) ) +space(32)+cNISRet+cRetorno  } )
    aAdd(aFilArq,{cCFilial})
	aAdd(aInfoAll,aInfoSRA)
Endif

//Fecha alias que esta em uso
If (Select(cAliasSRA) > 0)
	(cAliasSRA)->(dbCloseArea())
EndIf

RestArea(aArea)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GetDire  ºAutor  ³ Claudinei Soares   º Data ³ 26/06/2014  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Usado no Pergunte para indicar o diretorio a ser gerado o  º±±
±±º          ³ arquivo texto.                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEM024                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GetDire()

Local mvRet	:=Alltrim(ReadVar())
Local cFile

oWnd	:= GetWndDefault()
cFile	:= cGetFile("Arquivo Texto","Gerar no Diretório:",,"C:\",.T.,GETF_LOCALHARD + GETF_RETDIRECTORY + GETF_LOCALFLOPPY) ////"Arquivo Texto"###"Gerar no Diretorio"

If Empty(cFile)
	Return(.F.)
Endif

cDrive := Alltrim(Upper(cFile))

&mvRet := cFile

If oWnd != Nil
	GetdRefresh()
EndIf

Return( .T. )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fGP24str  ³ Autor ³ Glaucia M.            | Data ³ 24/06/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³fGP24str(cCampo1,cCampo2,nTam,lNumero,lIgnora,lNome,cMaePai)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCampo1                                                    ³±±
±±³          ³ cCampo2                                                    ³±±
±±³          ³ nTam                                                       ³±±
±±³          ³ lNumero                                                    ³±±
±±³          ³ lIgnora                                                    ³±±
±±³          ³ lNome                                                      ³±±
±±³          ³ cMaePai                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEM024                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function fGP24str(cCampo1, cCampo2, nTam, lNumero, lIgnora, lNome, cMaePai)

Private cStr		:= ""
DEFAULT cCampo2 	:= ""
DEFAULT lNumero 	:= .F.
DEFAULT lIgnora 	:= .F.
DEFAULT lNome	:= .F.
DEFAULT cMaePai	:= ""

cStr:= IIf (!(Empty(cCampo1)),ALLTRIM(cCampo1),ALLTRIM(cCampo2))

If cStr == "" .AND. lIgnora
	If cMaePai == "M"
		cStr:= "IGNORADA"
	ElseIf cMaePai == "P"
		cStr:= "IGNORADO"
	Endif
Else
	cValCpo:= GP24Val(cStr,lNumero)
EndIf

nTamStr := len(cStr)
cStr:= cStr + space(nTam-nTamStr)

Return (cStr)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GP24Val   ³ Autor ³ Glaucia M.            | Data ³ 24/06/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fGP24Val(cConteudo,lNum)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cConteudo                                                  ³±±
±±³          ³ lNum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEM024                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function GP24Val(cConteudo,lNum)

Local cNum	:= alltrim(cStr)
Local cAux  	:= ""
Local lRet 	:= .T.
Local i		:= 1

If lNum
	For i:= 1 To len(cNum)
		cAux := Right(left(cNum,i),1)
		lRet := IsDigit(cStr)
		If !lRet
		  	Exit
		EndIf
	Next i
Else
Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fGP24NmArq³ Autor ³ Claudinei Soares      | Data ³ 27/06/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Gerar o nome do arquivo.   	              				    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fGP24NmArq()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEM024                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function fGP24NmArq(lValida,cFilArq, lIncVersao, nVersao)

Local aArea1	:= GetArea()
Local cFilCh	:= ""
Local cRotiCh	:="GPEM024     "
Local cDataCh	:= ""
Local cNomeArq 	:= ""
Local cNomeExt 	:= ""
Local cNomeSJ4	:= ""
Local cPreArq	:= ""
Local cIniArq 	:= ""
Local cMesArq 	:= ""
Local cAnoArq 	:= ""
Local cDataArq 	:= ""
Local cDirArq   := Alltrim(MV_PAR09) //Diretorio onde o arquivo sera gravado
Local lRetific	:= MV_PAR12 == 2
Local dDtRemes	:= CtoD("//")
Local nVerArq	:= If(lRetific,If(MV_PAR14 == Nil, 00, VAL(MV_PAR14)),00) //Se for retificadora pega a versao do pergunte.
Local nV		:= 0

Default lValida := .F.
Default cFilArq := ""
Default lIncVersao	:= .F.
Default nVersao		:= 0

cFilCh := cFilArq

dDtRemes := If(lRetific,If(Empty(MV_PAR13), DATE(), MV_PAR13),DATE())

//Inicio
cIniArq:= "CADASTRONIS."

//Montar a data no formato AAMMDD
cDiaArq	:=PADL(Alltrim(STR(Day(dDtRemes))),2,"0")
cMesArq	:=PADL(Alltrim(STR(Month(dDtRemes))),2,"0")
cAnoArq	:=SUBSTR(Alltrim(STR(Year(dDtRemes))),3,2)
cDataArq:= ("D"+cAnoArq+cMesArq+cDiaArq)

//Monta a data para o SJ4
cAnoArq2 :=SUBSTR(Alltrim(STR(Year(dDtRemes))),1,4)
cDataCh  :=(cAnoArq2+cMesArq+cDiaArq)

//Monta o nome do arquivo
cPreArq :=(cIniArq+cDataArq+".S")

cVerCh:= PADL(Alltrim(STR(nVerArq)),2,"0")

If !lRetific
	//Obtem a versao do arquivo na tabela SJ4 - Arquivos Magneticos
	dbSelectArea("SJ4")
	dbSetOrder(2)

	If SJ4->(dbseek(cRotiCh+cDataCh))
		For nV:= 0 To 99
			cVerCh:= PADL(Alltrim(STR(nV)),2,"0")
			nVerArq:= nV
			If !SJ4->(dbseek(cRotiCh+cDataCh+cVerCh))
				nV := 99
	        Endif
	   Next nV
	Endif
	If lIncVersao
		cVerCh := PADL(Alltrim(STR(VAL(cVerCh)+ nVersao)),2,"0")
	Endif
	cNomeArq:=(cPreArq+cVerCh)
Else
	If lIncVersao
		cVerCh := PADL(Alltrim(STR(VAL(cVerCh)+ nVersao)),2,"0")
	Endif
	cNomeArq:=(cPreArq+cVerCh)
	fErase(cNomeArq)
	cVerCh:= PADL(Alltrim(STR(nVerArq)),2,"0")
Endif

If lValida
	cNomeExt:=(cDirArq+cNomeArq+".TXT")
	cNomeSJ4:= cNomeArq
	cNomeArq := cNomeExt

	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Grava os dados do arquivo gerado na tabela SJ4			   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
	dbSelectArea("SJ4")
	dbSetOrder(2)
	If lRetific
		If SJ4->(dbseek(cRotiCh+cDataCh+cVerCh))
			RECLOCK("SJ4", .F.)
			SJ4->J4_FILIAL	:= cFilCh
			SJ4->J4_ROTINA	:= cRotiCh
	 		SJ4->J4_DATA	:= dDtRemes
			SJ4->J4_VERSAO	:= cVerCh
			SJ4->J4_LOCAL	:= cDirArq
			SJ4->J4_NOMARQ	:= cNomeSJ4
			SJ4->( MsUnLock() )
		Else
			RECLOCK("SJ4", .T.)
			SJ4->J4_FILIAL	:= cFilCh
			SJ4->J4_ROTINA	:= cRotiCh
	 		SJ4->J4_DATA	:= dDtRemes
			SJ4->J4_VERSAO	:= cVerCh
			SJ4->J4_LOCAL	:= cDirArq
			SJ4->J4_NOMARQ	:= cNomeSJ4
			SJ4->( MsUnLock() )
		Endif
	Else
		If RECLOCK("SJ4", .T.)
			SJ4->J4_FILIAL	:= cFilCh
			SJ4->J4_ROTINA	:= cRotiCh
	 		SJ4->J4_DATA	:= dDtRemes
			SJ4->J4_VERSAO	:= cVerCh
			SJ4->J4_LOCAL	:= cDirArq
			SJ4->J4_NOMARQ	:= cNomeSJ4
			SJ4->( MsUnLock() )
		Endif
	Endif
Endif

RestArea( aArea1 )

Return cNomeArq
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fGP24Raca ³ Autor ³ Claudinei Soares      | Data ³ 24/06/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retornar a Raca/Cor de acordo com o CNIS.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fGP24Raca(cRacaCor)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cRacaCor  = RA_RACACOR - Raca/Cor.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEM024                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function fGP24Raca(cRacaCor)

Local	cCor		:= space(180)
Default	cRacaCor 	:= ""

If cRacaCor == "1"
	cCor:= "05" + space(178)
ElseIf cRacaCor == "2"
	cCor:= "01" + space(178)
ElseIf cRacaCor == "4"
	cCor:= "02" + space(178)
ElseIf cRacaCor == "6"
	cCor:= "04" + space(178)
ElseIf cRacaCor == "8"
	cCor:= "03" + space(178)
Else
	cCor := space(180)
Endif

Return cCor

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fGP24Niv  ³ Autor ³ Claudinei Soares      | Data ³ 24/06/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retornar o Grau de Instrucao de acordo o CNIS.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fGP24Niv(cNiv)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cNiv  = RA_GRINRAI - Grau de Instrucao.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEM024                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function fGP24Niv(cNiv)

Local	cNivel		:= ""
Default cNiv 	:= "00"

If cNiv == "10"
	cNivel := "01"
ElseIf cNiv == "20"
	cNivel := "02"
ElseIf cNiv == "25"
	cNivel := "03"
ElseIf cNiv == "30"
	cNivel := "04"
ElseIf cNiv == "35"
	cNivel := "05"
ElseIf cNiv == "40"
	cNivel := "06"
ElseIf cNiv == "45"
	cNivel := "07"
ElseIf cNiv == "50"
	cNivel := "08"
ElseIf cNiv == "55"
	cNivel := "09"
ElseIf cNiv == "85"
	cNivel := "10"
ElseIf cNiv == "65"
	cNivel := "11"
ElseIf cNiv == "75" .OR. cNiv == "95"
	cNivel := "12"
Else
	cNivel := "00"
Endif

cNivel := cNivel + space(178)

Return cNivel

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fGP24Civ  ³ Autor ³ Claudinei Soares      | Data ³ 24/06/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retornar o Estado Civil de acordo com o CNIS.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fGP24Civ(cCiv)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCiv  = RA_ESTCIVI - Estado Civil.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEM024                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function fGP24Civ(cCiv)

Local	cCivil	:= ""
Default cCiv := ""

If cCiv == "S"
	cCivil := "01"
ElseIf cCiv == "C"
	cCivil := "02"
ElseIf cCiv == "D"
	cCivil := "03"
ElseIf cCiv == "Q"
	cCivil := "04"
ElseIf cCiv == "V"
	cCivil := "05"
ElseIf cCiv == "M"
	cCivil := "06"
Else
	cCivil := "00"
Endif

cCivil := cCivil + space(178)

Return cCivil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fGP24Cert ³ Autor ³ Claudinei Soares      | Data ³ 24/06/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retornar o codigo da Certidao Civil ou o Codigo do Campo.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fGP24Cert(cTipCert)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cTipCert  = Tipo do Certificado.                           ³±±
±±³          ³ lCodCampo = Se retornara o codigo do campo.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEM024                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function fGP24Cert(cTipCert,lCodCampo)

Local 	cTpCertif	:= ""
Default cTipCert 	:= ""
Default lCodCampo	:= .F.

If lCodCampo
	If Alltrim(cTipCert) == "1" // Nascimento
		cTpCertif := "0374"
	Elseif Alltrim(cTipCert) == "2" // Casamento
		cTpCertif := "0375"
	Elseif Alltrim(cTipCert) == "3" // Indio
		cTpCertif := "0866"
	Elseif Alltrim(cTipCert) == "4"	// Obito
		cTpCertif := "0376"
	Else
		cTipCertf := " "
	Endif
Else
	If Alltrim(cTipCert) == "1"
		cTpCertif	:= "91"
	Elseif Alltrim(cTipCert) == "2"
		cTpCertif	:= "92"
	Elseif Alltrim(cTipCert) == "3"
		cTpCertif := "95"
	Elseif Alltrim(cTipCert) == "4"
		cTpCertif := "98"
	Else
		cTpCertif := "  "
	Endif
Endif

Return cTpCertif

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fGP24EmPas³ Autor ³ Claudinei Soares      | Data ³ 24/06/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retornar o codigo de emissao do passaporte.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fGP24EmPas(cEmisPas)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cEmisPas  = RA_EMISPAS - Emissao do Passaporte.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEM024                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function fGP24EmPas(cEmisPas)

Local 	cEmPas		:= ""
Default cEmisPas	:= ""

If Alltrim(cEmisPas) $ "PF|DPF|POLICIA|FEDERAL|POLICIA FEDERAL"
	cEmPas := "44"
Else
	cEmPas := "82"
Endif

cEmPas := cEmPas + space(178)

Return cEmPas

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fGP24Nac  ³ Autor ³ Claudinei Soares      | Data ³ 24/06/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retornar a Nacionalidade ou o Detalhamento da Nacionalidade.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fGP24Nac(cCampo1,cCampo2,cCampo3,lDetNacio,lPais,lPaisPas) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCampo1   = RA_NACIONA - Nacionalidade conforme a SX5      ³±±
±±³          ³ cCampo2   = RA_BRNASEX - Brasileiro nascido no exterior    ³±±
±±³          ³ cCampo3   = Pais de origem conforme a tabela CCH     	    ³±±
±±³          ³ lDetNacio = Se ira retornar o detalhamento da nacionalidade³±±
±±³          ³ 				(1=Brasileiro; 2=Brasileiro Naturalizado;	    ³±±
±±³          ³ 				 3=Brasileiro nascido no exterior).           ³±±
±±³          ³ lPais     = Determina se ira retornar o pais de origem.    ³±±
±±³          ³ lPaisPas  = Determina se ira retornar o pais do passaporte.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEM024                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function fGP24Nac(cCampo1,cCampo2,cCampo3,lDetNacio,lPais,lPaisPas)

Local 	cCodPais		:= ""
Local	cDetNac		:= ""

Default cCampo1		:= ""
Default cCampo2 		:= ""
Default cCampo3 		:= ""
Default lDetNacio	:= .F.
Default lPais		:= .F.
Default lPaisPas		:= .F.

If Len(aPaisCNIS) == 0
	aPaisC:= fGP24CPais()
Endif

If cCampo1 == "10"
	cCodPais 	:= cCampo1
	cDetNac	:= "1"
ElseIf cCampo1 == "20" .OR. lPais
	If cCampo1 == "20"
		cCodPais := "10"
	Else
		cCodPais := cCampo1
	Endif
	cDetNac := "2"
Else
	cCodPais := cCampo1
	cDetNac := "0"
EndIf

If cCampo2 == "1"
	cDetNac := "3"
	If lPais
		nPosPais := aScan(aPaisC, { |x| x[3] == cCampo3})
		If nPosPais > 0
			cCodPais := aPaisC[nPosPais][1]
		Endif
	Endif
Endif

If lPaisPas
	nPosPais := aScan(aPaisC, { |x| x[3] == cCampo3})
	If nPosPais > 0
		cCodPais := aPaisC[nPosPais][1]
	Endif
Endif

cCodPais := STRZERO(Val(cCodPais),4,0)

If lDetNacio
	cCodPais := cDetNac
Endif

cCodPais := cCodPais + space(180-len(cCodPais))

Return cCodPais

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fGP24Org  ³ Autor ³ Claudinei Soares      | Data ³ 24/06/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retornar o Orgao Expeditor conforme o anexo VIII do CNIS.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fGP24Org(cOExped)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cOExped.                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEM024                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function fGP24Org(cOExped)

Local cOrgExp   := ""
Local nPosOrg	:= 0
Default cOExped := ""

If Len(aOrgExp) == 0
	aAdd( aOrgExp,{"10"	,"SSP"			,"SECRETARIA DE SEGURANCA PUBLICA"				 		})
	aAdd( aOrgExp,{"11"	,"IIFP"			,"INSTITUTO DE IDENTIFICAÇÃO FELIX PACHECO"	 			})
	aAdd( aOrgExP,{"20"	,"TRE"			,"TRIBUNAL REGIONAL ELEITORAL"							})
	aAdd( aOrgExp,{"21"	,"EXT"			,"EXTERIOR"												})
	aAdd( aOrgExp,{"30"	,"DRT"			,"DELEGACIA REGIONAL DO TRABALHO"						})
	aAdd( aOrgExp,{"40"	,"M"			,"MILITAR MINISTERIOS MILITARES"						})
	aAdd( aOrgExp,{"41"	,"MIN"			,"AER MINISTERIO DA AERONAUTICA"						})
	aAdd( aOrgExp,{"42"	,"MIN"			,"EXER MINISTERIO DO EXERCITO"							})
	aAdd( aOrgExp,{"43"	,"MIN"			,"MAR MINISTERIO DA MARINHA"							})
	aAdd( aOrgExp,{"44"	,"DPF"			,"DEPARTAMENTO DE POLICIA FEDERAL"						})
	aAdd( aOrgExp,{"56"	,"INSS"			,"INSTITUTO NACIONAL DE SEGURIDADE SOCIAL"				})
	aAdd( aOrgExp,{"57"	,"SRF"			,"SECRETARIA DA RECEITA FEDERAL"						})
	aAdd( aOrgExp,{"60"	,"CLASSISTAS"	,"ORGAOS CLASSISTAS"									})
	aAdd( aOrgExp,{"61"	,"CRA"			,"CONSELHO REGIONAL DE ADMINISTRACAO"					})
	aAdd( aOrgExp,{"62"	,"CRAS"			,"CONSELHO REGIONAL DE ASSISTENCIA SOCIAL"				})
	aAdd( aOrgExp,{"63"	,"CRB"			,"CONSELHO REGIONAL DE BIBLIOTECONOMIA"					})
	aAdd( aOrgExp,{"64"	,"CRC"			,"CONSELHO REGIONAL DE CONTABILIDADE"					})
	aAdd( aOrgExp,{"65"	,"CRECI"		,"CONSELHO REGIONAL DE CORRETORES DE IMOVEIS"			})
	aAdd( aOrgExp,{"66"	,"COREN"		,"CONSELHO REGIONAL DE ENFERMAGEM"			 			})
	aAdd( aOrgExp,{"67"	,"CREA"			,"CONSELHO REGIONAL DE ENGENHARIA, ARQUITETURA E AGR"	})
	aAdd( aOrgExp,{"68"	,"CONRE"		,"CONSELHO REGIONAL DE ESTATISTICA"						})
	aAdd( aOrgExp,{"69"	,"CRF"			,"CONSELHO REGIONAL DE FARMACIA"						})
	aAdd( aOrgExp,{"70"	,"CREFITO"		,"CONSELHO REGIONAL DE FISIOTERAPIA E TERAPIA OCUPAC"	})
	aAdd( aOrgExp,{"71"	,"CRM"			,"CONSELHO REGIONAL DE MEDICINA"						})
	aAdd( aOrgExp,{"72"	,"CRMV"			,"CONSELHO REGIONAL DE MEDICINA VETERINARIA"			})
	aAdd( aOrgExp,{"73"	,"OMB"			,"ORDEM DOS MUSICOS DO BRASIL"							})
	aAdd( aOrgExp,{"74"	,"CRN"			,"CONSELHO REGIONAL DE NUTRICAO"						})
	aAdd( aOrgExp,{"75"	,"CRO"			,"CONSELHO REGIONAL DE ODONTOLOGIA"						})
	aAdd( aOrgExp,{"76"	,"CONRERP"		,"CONSELHO REGIONAL DE RELACOES PUBLICAS"				})
	aAdd( aOrgExp,{"77"	,"CRP"			,"CONSELHO REGIONAL DE PSICOLOGIA"						})
	aAdd( aOrgExp,{"78"	,"CRQ"			,"CONSELHO REGIONAL DE QUIMICA"							})
	aAdd( aOrgExp,{"79"	,"CORE"			,"CONSELHO REGIONAL DE REPRESENTANTES COMERCIAIS"		})
	aAdd( aOrgExp,{"80"	,"OAB"			,"ORDEM DOS ADVOGADOS DO BRASIL"						})
	aAdd( aOrgExp,{"81"	,"OE"			,"OUTROS EMISSORES"										})
	aAdd( aOrgExp,{"82"	,"DOC"			,"ESTR DOCUMENTO DE ESTRANGEIRO"						})
	aAdd( aOrgExp,{"83"	,"CRE"			,"CONSELHO REGIONAL DE ECONOMIA"						})
	aAdd( aOrgExp,{"91"	,"REG CIVIL"	,"CARTORIO DE REGISTRO CIVIL E DAS PESSOAS NATURAIS"	})
	aAdd( aOrgExp,{"98"	,"DETRAN"		,"DEPARTAMENTO NACIONAL DE TRANSITO"	})
Endif

nPosOrg := aScan(aOrgExp, { |x| x[2] $ cOExped})
If nPosOrg > 0
	cOrgExp := aOrgExp[nPosOrg][1]
Endif

cOrgExp := cOrgExp + space(178)

Return cOrgExp

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³fGP24Termo³ Autor ³ Claudinei Soares      | Data ³ 24/06/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna o Termo/Matricula da Certidao Civil.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fGP24Cert()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nao aplica                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ GPEM024									                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function fGP24Termo()

Local cTermoMat 	:= ""  //Numero da Matricula ou Termo
Local cTermoAux 	:= ""	//Numero da Matricula ou Termo
Local cIdCart		:= ""	//Identificacao do cartorio, RA_SERVENT 1 ao 6 digito da matricula
Local cCodAcer	:= ""	//Codigo do acervo, RA_CODACER 7 ao 8 digito da matricula
Local cRegCiv		:= ""	//Registro Civil, RA_REGCIV 9 ao 10 digito da matricula
Local cAnoCert	:= ""	//Ano do campo RA_EMICERT 11 ao 14 digito da matricula
Local cTpLivro	:= ""	//Tipo de Certidao RA_TPLIVRO 15 digito da matricula
Local cLivCert	:= ""	//Numero do Livro, RA_LIVCERT 16 ao 20 digito da matricula (campo possui tamanho 8 so utiliza 5)
Local cFolCert	:= ""	//Numero da Folha, RA_FOLCERT 21 ao 23 digito da matricula (campo possui tamanho 4 so utiliza 3)
Local cMatCert	:= ""	//Numero do Termo, RA_MATCERT 24 ao 30 digito da matricula (campo possui tamanho 8 so utiliza 7)
Local cMatT		:= ""  //Matricula sem o DV
Local cMatCalc	:= ""	//Matricula calculada ja com o DV


//Variaveis utilizadas para calcular o digito verificador
Local nXMat		:= 0
Local nYMat		:= 0
Local nWMat		:= 0
Local nKMat		:= 0

Local nDig1Mat	:= 0	//Primeiro DV do MOD 11
Local nDig2Mat	:= 0	//Segundo DV do MOD 11

Local nMat01 := nMat02 := nMat03 := nMat04 := nMat05 := nMat06 := nMat07 := nMat08 := nMat09 := nMat10 := 0
Local nMat11 := nMat12 := nMat13 := nMat14 := nMat15 := nMat16 := nMat17 := nMat18 := nMat19 := nMat20 := 0
Local nMat21 := nMat22 := nMat23 := nMat24 := nMat25 := nMat26 := nMat27 := nMat28 := nMat29 := nMat30 := 0

//Se o tipo de certidao tiver sido emitida antes de 01/01/2010 OU for Certidao de Obito
//devera ser enviado o termo (8 posicoes) e não a matricula (32 posicoes).
If lAnt2010T

	//TERMO - NUMERICO 8
	cTermoMat:= STRZERO(VAL((cAliasSRA)->RA_MATCERT),8,0)+space(180-len(STRZERO(VAL((cAliasSRA)->RA_MATCERT),8,0)))

ElseIf LEN( AllTrim((cAliasSRA)->RA_MATCERT)) > 31

	cTermoAux	:= (cAliasSRA)->RA_MATCERT
	//MATRICULA - 32 - * STRZERO so funciona corretamente ate 16 caracteres.
	cTermoMat 	:= fGP24str(cTermoAux,, 180)

Else

	cIdCart	:= STRZERO(VAL( (cAliasSRA)->RA_SERVENT ) ,6,0)
	cCodAcer	:= STRZERO(VAL( (cAliasSRA)->RA_CODACER ) ,2,0)
	cRegCiv	:= STRZERO(VAL( (cAliasSRA)->RA_REGCIVI ) ,2,0)
	cAnoCert	:= STRZERO(VAL(  STR(Year(dDataEmis))   ) ,4,0)
	cTpLivro	:= STRZERO(VAL( (cAliasSRA)->RA_TPLIVRO ) ,1,0)

	cLivCert	:= PadR((cAliasSRA)->RA_LIVCERT,5)
	cFolCert	:= PadR((cAliasSRA)->RA_FOLCERT,3)
	cMatCert  	:= PadR((cAliasSRA)->RA_MATCERT,7)

	cMatT:= cIdCart + cCodAcer + cRegCiv + cAnoCert + cTpLivro + cLivCert + cFolCert + cMatCert

	nMat01  := Val(SubStr(cMatT,01,01))
	nMat02  := Val(SubStr(cMatT,02,01))
	nMat03  := Val(SubStr(cMatT,03,01))
	nMat04  := Val(SubStr(cMatT,04,01))
	nMat05  := Val(SubStr(cMatT,05,01))
	nMat06  := Val(SubStr(cMatT,06,01))
	nMat07  := Val(SubStr(cMatT,07,01))
	nMat08  := Val(SubStr(cMatT,08,01))
	nMat09  := Val(SubStr(cMatT,09,01))
	nMat10  := Val(SubStr(cMatT,10,01))
	nMat11  := Val(SubStr(cMatT,11,01))
	nMat12  := Val(SubStr(cMatT,12,01))
	nMat13  := Val(SubStr(cMatT,13,01))
	nMat14  := Val(SubStr(cMatT,14,01))
	nMat15  := Val(SubStr(cMatT,15,01))
	nMat16  := Val(SubStr(cMatT,16,01))
	nMat17  := Val(SubStr(cMatT,17,01))
	nMat18  := Val(SubStr(cMatT,18,01))
	nMat19  := Val(SubStr(cMatT,19,01))
	nMat20  := Val(SubStr(cMatT,20,01))
	nMat21  := Val(SubStr(cMatT,21,01))
	nMat22  := Val(SubStr(cMatT,22,01))
	nMat23  := Val(SubStr(cMatT,23,01))
	nMat24  := Val(SubStr(cMatT,24,01))
	nMat25  := Val(SubStr(cMatT,25,01))
	nMat26  := Val(SubStr(cMatT,26,01))
	nMat27  := Val(SubStr(cMatT,27,01))
	nMat28  := Val(SubStr(cMatT,28,01))
	nMat29  := Val(SubStr(cMatT,29,01))
	nMat30  := Val(SubStr(cMatT,30,01))

	// Consistencia do 1§ Numero do Digito
	nXMAt := (nMat01 * 2)  + (nMat02 * 3) + (nMat03 * 4) + (nMat04 * 5)  + (nMat05 * 6) + (nMat06 * 7) + (nMat07 * 8) + (nMat08 * 9)
	nXMat += (nMat09 * 10) + (nMat10 * 0) + (nMat11 * 1) + (nMat12 * 2)  + (nMat13 * 3) + (nMat14 * 4) + (nMat15 * 5) + (nMat16 * 6)
	nXMat += (nMat17 * 7)  + (nMat18 * 8) + (nMat19 * 9) + (nMat20 * 10) + (nMat21 * 0) + (nMat22 * 1) + (nMat23 * 2) + (nMat24 * 3)
	nXMat += (nMat25 * 4)  + (nMat26 * 5) + (nMat27 * 6) + (nMat28 * 7)  + (nMat29 * 8) + (nMat30 * 9)

	nYMat := Int( nXMat / 11 )
	nWMat := nYMat * 11
	nKMat := nXMat - nWMat

	//Se o resultado for 10 o digito devera ser 1
	If nKMat == 10
		nDig1Mat := 1
	Else
		nDig1Mat := nKMat
	Endif

	// Consistencia do 2§ Numero do Digito
	nXMAt := (nMat01 * 1) + (nMat02 * 2)  + (nMat03 * 3) + (nMat04 * 4) + (nMat05 * 5)  + (nMat06 * 6) + (nMat07 * 7) + (nMat08 *  8)
	nXMat += (nMat09 * 9) + (nMat10 * 10) + (nMat11 * 0) + (nMat12 * 1) + (nMat13 * 2)  + (nMat14 * 3) + (nMat15 * 4) + (nMat16 *  5)
	nXMat += (nMat17 * 6) + (nMat18 * 7)  + (nMat19 * 8) + (nMat20 * 9) + (nMat21 * 10) + (nMat22 * 0) + (nMat23 * 1) + (nMat24 *  2)
	nXMat += (nMat25 * 3) + (nMat26 * 4)  + (nMat27 * 5) + (nMat28 * 6) + (nMat29 * 7)  + (nMat30 * 8) + (nDig1Mat * 9)

	nYMat = Int( nXMat / 11 )
	nWMat = nYMat * 11
	nKMat = nXMat - nWMat

	//Se o resultado for 10 o digito devera ser 1
	If nKMat == 10
		nDig2Mat := 1
	Else
		nDig2Mat := nKMat
	Endif

	cMatCalc:= cMatT + alltrim(STR(nDig1Mat)) + alltrim(STR(nDig2Mat))

	cTermoMat := cMatCalc

Endif

Return cTermoMat

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fGP24Fone ³ Autor ³ Claudinei Soares      | Data ³ 24/06/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Remove o "-" do numero de telefone.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fGP24Fone()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cFone = Numero do telefone                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEM024                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function fGP24Fone(cFone)

Local 	cTel 		:= ""
Default cFone 	:= ""

cTel:= fGP24str(StrTran(cFone, "-",""),, 180)

Return cTel

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³fGP24Ident³ Autor ³ Claudinei Soares      | Data ³ 15/12/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Remove a mascara da Carteira de Identidade.          		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fGP24Ident()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cIdent = Numero da Identidade                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ GPEM024									                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function fGP24Ident(cIdent)

Local 	cRG 	:= ""
Default cIdent 	:= ""

cRG:= fGP24str(StrTran(StrTran(StrTran(cIdent,"-",""),"/",""),".",""),, 180 )

Return cRG

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³fGP24End  ³ Autor ³ Claudinei Soares      | Data ³ 25/06/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Preenche o array aEndereco, com os campos de endereco       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fGP24End()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ GPEM024									                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function fGP24End(cTipLog, cDescLog, cNumLog, cEnderec, cNumende)
	  //Campos da SRA - (LOGRTP , LOGRDSC , LOGRNUM , ENDEREC , NUMENDE)

//Array aEnder
//aEnder[1] = Tipo do Logradouro
//aEnder[2] = Descricao do Logradouro
//aEnder[3] = Descricao da Posicao Determinante
//aEnder[4] = Sigla Posicao Determinante

Local	cPosDet	:= ""
Local	x			:= 0
Local 	aEnder		:= {"","","",""}
Local	aEndereco	:= {"","","",""}
Local	aPosDet		:= {"NUM","KM","LOTE","CASA","BLOCO","OUTRO"}
Default cTipLog	:= ""
Default cDescLog	:= ""
Default cNumLog	:= ""
Default cEnderec	:= ""
Default cNumende	:= ""

If Empty(cTipLog)
	aEnder:= fGP24Carga(cEnderec, cNumende)
	For x:= 1 to 6
		If aPosDet[x] $ UPPER(aEnder[4])
			cPosDet:= aPosDet[x]
			Exit
		Elseif AllTrim(aEnder[4]) $ ","
			cPosDet:= APosDet[1]
			Exit
		Else
			cPosDet:= APosDet[6]
		Endif
	Next x
Else
	For x:= 1 to 6
		If aPosDet[x] $ UPPER(cNumLog)
			cPosDet:= aPosDet[x]
			Exit
		ElseIf isDigit(cNumLog)
			cPosDet:= aPosDet[1]
			Exit
		Else
			cPosDet:= aPosDet[6]
		Endif
	Next x
	aEnder[1] := cTipLog
	aEnder[2] := cDescLog
	aEnder[3] := cNumLog
Endif

	aEndereco[1] := aEnder[1]
	aEndereco[2] := aEnder[2]
	aEndereco[3] := cPosDet
	aEndereco[4] := AllTrim(StrTran(aEnder[3],cPosDet))

Return aEndereco

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fCargaLogr³ Autor ³ Glaucia M.            ³ Data ³ 14/08/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Realiza carga das tabelas Logradouros (S54 e S55) e obtem   ³±±
±±³          ³o cod tipo logradouro, descricao tipo logradouro, logradouro³±±
±±³          ³e numero logradouro, usando o conteudo dos campos RA_ENDEREC³±±
±±³          ³e RA_NUMENDE.  eSocial                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fCargaLogr(cRA_ENDERE,cRA_NUMENDE)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                   	 	    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ P11                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function fGP24Carga(cRA_ENDERE,cRA_NUMENDE)
Local aArea		:= GetArea()
Local x			:= 0
Local y			:= 0
Local nPos1		:= 0
Local nPos2		:= 0
Local cTipoLogr	:=""
Local cDescLogr	:=""
Local cNumLogr	:=""
Local cLogrNum	:=""
Local aLogr		:={}
Local cEnd, cNum
Local aRet:= {"","","",""}

If Valtype(aTLogr) != "A"
	aTLogr		:={}

	dbSelectArea("RCC")
	dbSetOrder(1)
	MsSeek(xFilial("RCC")+"S054")
	While !Eof() .AND. RCC->RCC_FILIAL+RCC_CODIGO == xFilial("RCC")+"S054"
		aLogr:= {}
		Aadd(aLogr, {Alltrim(Substr(RCC->RCC_CONTEU,5,20))})
		nPriPos := At("|", Alltrim(Substr(RCC->RCC_CONTEU,0,len(RCC->RCC_CONTEU))) )
		cEnd	:= Substr(RCC->RCC_CONTEU,nPriPos,len(RCC->RCC_CONTEU))
		While len(cEnd)> 0
			nPos1	:=	At("|", Substr(cEnd,1,len(cEnd)) )
			nPos2	:=  At("|", Substr(cEnd,nPos1+1,len(cEnd)) )
			If nPos2 == 0
				cEnd:= ""
			Else
				Aadd(aLogr, {Substr(cEnd,nPos1+1,nPos2-1)})
				cEnd	:= Substr(cEnd,nPos1+nPos2,len(cEnd))
			Endif
		End
		Aadd (aTLogr,aLogr)
		dBSkip()
	End
EndIf

If Valtype(aLogrNum) != "A"
	aLogrNum:={}
	cNum := fDescRCC("S055","01",1,2,38,67)
	While len(cNum)> 0
		nPos1	:=	At("|", Substr(cNum,1,len(cNum)) )
		nPos2	:=  At("|", Substr(cNum,nPos1+1,len(cNum)) )
		If nPos2 == 0
			cNum:= ""
		Else
			Aadd(aLogrNum, {Substr(cNum,nPos1+1,nPos2-1)})
			cNum	:= Substr(cNum,nPos1+nPos2,len(cNum))
		Endif
	End
EndIf

If !empty(cRA_ENDERE)
	For x:=1 to len(aTLogr)
		For y:=1 to len(aTLogr[x])
			If at(UPPER(aTLogr[x,y,1]),cRA_ENDERE) == 1
				cTipoLogr:= aTLogr[x,1,1]
				cDescLogr:=ALLTRIM(SUBSTR(cRA_ENDERE,LEN(aTLogr[x,y,1])+1,LEN(cRA_ENDERE)))
				exit
			Endif
		Next y
	Next x
EndIf

If !empty(cRA_NUMENDE)
	cNumLogr :=cRA_NUMENDE
	cLogrNum :=cRA_NUMENDE
Else
	If !empty(cDescLogr)
		For x:=1 to len(aLogrNum)
			nPos1:= Rat(UPPER(aLogrNum[x,1]),cDescLogr)
			If (nPos1 > 1)
				cNumLogr:= ALLTRIM(SUBSTR(cDescLogr,nPos1+len(aLogrNum[x,1]),len(cDescLogr)))
				cDescLogr:= SUBSTR(cDescLogr,0,nPos1-1)
				cLogrNum:=aLogrNum[x,1]
				Exit
			EndIf
		Next x
	Endif
EndIf

If cDescLogr == ""
	cDescLogr:= cRA_ENDERE
EndIf

 aRet:={fDescRCC("S054",cTipoLogr,5,20,1,4),cDescLogr,cNumLogr,cLogrNum}

RestArea(aArea)
Return(aRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fGP24CPais³ Autor ³ Claudinei Soares      | Data ³ 24/06/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Carregar a tabela de Paises do CNIS.               		    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fGP24CPais()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nao aplica.                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEM024                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function fGP24CPais()

//Carrega o array aPaisCNIS com os codigos dos paises do Anexo V - Tabela de Paises do CNIS e da tabela CCH (Banco Central).
//				Tabela do CNIS 										-	Tabela CCH
//				COD.				PAIS							-	COD.					PAIS
aAdd( aPaisCNIS,{"170"	,"ABISSINIA (ATUAL ETIOPIA)"				,""			,""										})
aAdd( aPaisCNIS,{"171"	,"ACORES"									,""			,""										})
aAdd( aPaisCNIS,{"172"	,"AFAR FRANCES (ATUAL DJIBUTI)"				,"07838"	,"DJIBUTI"								})
aAdd( aPaisCNIS,{"241"	,"AFEGANISTAO"								,"00132"	,"AFEGANISTAO"							})
aAdd( aPaisCNIS,{"173"	,"AFRICA DO SUL, REPUBLICA DA"				,"07560"	,"AFRICA DO SUL"						})
aAdd( aPaisCNIS,{"215"	,"AFRICANA, PRACAS NORTE"					,""			,""						   				})
aAdd( aPaisCNIS,{"218"	,"AFRICANA, REPUBLICA CENTRAL"				,"06408"	,"REPUBLICA CENTRO-AFRICANA"			})
aAdd( aPaisCNIS,{"216"	,"AFRICANO, PROTETOR DO SUDOESTE" 			,""			,""										})
aAdd( aPaisCNIS,{"93"	,"ALBANIA"					   				,"00175"	,"ALBANIA, REPUBLICA DA"				})
aAdd( aPaisCNIS,{"30"	,"ALEMANHA"									,"00230"	,"ALEMANHA"								})
aAdd( aPaisCNIS,{"174"	,"ALTO VOLTA (ATUAL BURKINA FASSO)"	  		,"00310"	,"BURKINA FASO"							})
aAdd( aPaisCNIS,{"94"	,"ANDORRA"									,"00370"	,"ANDORRA"								})
aAdd( aPaisCNIS,{"175"	,"ANGOLA"				 					,"00400"	,"ANGOLA"					   			})
aAdd( aPaisCNIS,{"28"	,"ANTIGUA E BARBUDA"						,"00434"	,"ANTIGUA E BARBUDA"  					})
aAdd( aPaisCNIS,{"29"	,"ANTILHAS HOLANDESAS"	 					,"00477"	,"ANTILHAS HOLANDESAS"					})
aAdd( aPaisCNIS,{"57"	,"ANTILHAS, ESTADOS ASSOCIADOS DAS"			,""			,""										})
aAdd( aPaisCNIS,{"339"	,"APATRIDA"									,""			,""										})
aAdd( aPaisCNIS,{"251"	,"ARABES UNIDOS, EMIRADOS"					,""			,""										})
aAdd( aPaisCNIS,{"242"	,"ARABIA SAUDITA"							,"00531"	,"ARABIA SAUDITA"						})
aAdd( aPaisCNIS,{"176"	,"ARGELIA"									,"00590"	,"ARGELIA"								})
aAdd( aPaisCNIS,{"21"	,"ARGENTINA"								,"00639"	,"ARGENTINA"							})
aAdd( aPaisCNIS,{"337"	,"ARGENTINO, ANTARTICO"						,""			,""										})
aAdd( aPaisCNIS,{"347"	,"ARMENIA"									,"00647"	,"ARMENIA, REPUBLICA DA"				})
aAdd( aPaisCNIS,{"33"	,"ARUBA"									,"00655"	,"ARUBA"								})
aAdd( aPaisCNIS,{"198"	,"ASCENSAO E TRISTAO DA CUNHA, ILHAS"		,""			,""										})
aAdd( aPaisCNIS,{"287"	,"ASHMORE E CARTIER"						,""			,""										})
aAdd( aPaisCNIS,{"288"	,"AUSTRALIA"								,"00698"	,"AUSTRALIA"							})
aAdd( aPaisCNIS,{"335"	,"AUSTRALIA, TERRITORIO ANTARTICO DA"		,""			,""										})
aAdd( aPaisCNIS,{"95"	,"AUSTRIA"									,"00728"	,"AUSTRIA"								})
aAdd( aPaisCNIS,{"138"	,"AZERBAIJAO"	 							,"00736"	,"AZERBAIJAO, REPUBLICA DO"				})
aAdd( aPaisCNIS,{"40"	,"BAHAMAS, COMUNIDADE DAS"					,"00779"	,"BAHAMAS, ILHAS"						})
aAdd( aPaisCNIS,{"243"	,"BAHRAIN"									,"00809"	,"BAHREIN, ILHAS"						})
aAdd( aPaisCNIS,{"293"	,"BAKER, ILHAS"								,""			,""										})
aAdd( aPaisCNIS,{"107"	,"BALEARES, ILHAS"							,""			,""										})
aAdd( aPaisCNIS,{"342"	,"BANGLADESH"								,"00817"	,"BANGLADESH"							})
aAdd( aPaisCNIS,{"44"	,"BARBADOS"		 							,"00833"	,"BARBADOS"								})
aAdd( aPaisCNIS,{"139"	,"BASHKISTA"								,""			,""										})
aAdd( aPaisCNIS,{"177"	,"BECHUANA (ATUAL BTSUANA)"					,""			,""										})
aAdd( aPaisCNIS,{"31"	,"BELGICA"		  							,"00876"	,"BELGICA"								})
aAdd( aPaisCNIS,{"46"	,"BELIZE"		 							,"00884"	,"BELIZE"								})
aAdd( aPaisCNIS,{"178"	,"BENIN"									,"02291"	,"BENIN"			  					})
aAdd( aPaisCNIS,{"83"	,"BERMUDAS"		 							,"00906"	,"BERMUDAS"								})
aAdd( aPaisCNIS,{"246"	,"BHUTAN"		 							,"01198"	,"BUTAO"								})
aAdd( aPaisCNIS,{"140"	,"BIELORRUSSIA, REPUBLICA (ATUAL BELARUS)"	,"00850"	,"BELARUS, REPUBLICA DA"				})
aAdd( aPaisCNIS,{"244"	,"BIRMANIA"									,""			,""										})
aAdd( aPaisCNIS,{"289"	,"BISMARK, ARQUIPELAGO DE"					,""			,""										})
aAdd( aPaisCNIS,{"22"	,"BOLIVIA"									,"00973"	,"BOLIVIA"								})
aAdd( aPaisCNIS,{"134"	,"BOSNIA HERZEGOVINA"	   					,"00981"	,"BOSNIA-HERZEGOVINA (REPUBLICA DA)"	})
aAdd( aPaisCNIS,{"179"	,"BOTSWANA"				   					,"01015"	,"BOTSUANA"								})
aAdd( aPaisCNIS,{"10"	,"BRASIL"									,"01058"	,"BRASIL"								})
aAdd( aPaisCNIS,{"333"	,"BRITANICO, TERRITORIO ANTARTICO"			,""			,""										})
aAdd( aPaisCNIS,{"245"	,"BRUNEI"				 					,"01082"	,"BRUNEI"								})
aAdd( aPaisCNIS,{"96"	,"BULGARIA"									,"01112"	,"BULGARIA, REPUBLICA DA"				})
aAdd( aPaisCNIS,{"238"	,"BURKINA FASSO"							,"00310"	,"BURKINA FASO"							})
aAdd( aPaisCNIS,{"180"	,"BURUNDI"									,"01155"	,"BURUNDI"								})
aAdd( aPaisCNIS,{"141"	,"BURYAT"									,""			,""										})
aAdd( aPaisCNIS,{"343"	,"CABO VERDE"								,"01279"	,"CABO VERDE, REPUBLICA DE"				})
aAdd( aPaisCNIS,{"181"	,"CAMAROES"									,"01457"	,"CAMAROES"								})
aAdd( aPaisCNIS,{"261"	,"CAMBOJA (KMER)"							,"01414"	,"CAMBOJA"								})
aAdd( aPaisCNIS,{"34"	,"CANADA"									,"01490"	,"CANADA"								})
aAdd( aPaisCNIS,{"109"	,"CANAL, ILHAS DO"							,""			,""										})
aAdd( aPaisCNIS,{"199"	,"CANARIAS, ILHAS"							,"01511"	,"CANARIAS, ILHAS"						})
aAdd( aPaisCNIS,{"294"	,"CANTAO E ENDERBURG, ILHAS"				,""			,""										})
aAdd( aPaisCNIS,{"142"	,"CARELIA"									,""			,""										})
aAdd( aPaisCNIS,{"295"	,"CAROLINAS, ILHAS"							,""			,""		   								})
aAdd( aPaisCNIS,{"143"	,"CASAQUISTAO"								,"01538"	,"CAZAQUISTAO, REPUBLICA DO"			})
aAdd( aPaisCNIS,{"247"	,"CATAR"									,"01546"	,"CATAR"								})
aAdd( aPaisCNIS,{"248"	,"CEILAO (ATUAL SRI-LANKA)"					,"07501"	,"SRI LANKA"							})
aAdd( aPaisCNIS,{"182"	,"CEUTA E MELILLA"							,""			,""										})
aAdd( aPaisCNIS,{"183"	,"CHADE"									,"07889"	,"CHADE"								})
aAdd( aPaisCNIS,{"144"	,"CHECHEN INGUSTH"							,""			,""										})
aAdd( aPaisCNIS,{"23"	,"CHILE"									,"01589"	,"CHILE"								})
aAdd( aPaisCNIS,{"336"	,"CHILENO, ANTARTICO"						,""			,""										})
aAdd( aPaisCNIS,{"42"	,"CHINA"									,"01600"	,"CHINA, REPUBLICA POPULAR"				})
aAdd( aPaisCNIS,{"97"	,"CHIPRE"									,"01635"	,"CHIPRE"								})
aAdd( aPaisCNIS,{"297"	,"CHRISTMAS, ILHAS"							,"05118"	,"CHRISTMAS,ILHA (NAVIDAD)"				})
aAdd( aPaisCNIS,{"145"	,"CHUVASH"									,""			,""										})
aAdd( aPaisCNIS,{"328"	,"COCOS, TERRITORIO DE"						,"01651"	,"COCOS(KEELING),ILHAS"					})
aAdd( aPaisCNIS,{"26"	,"COLOMBIA"									,"01694"	,"COLOMBIA"								})
aAdd( aPaisCNIS,{"184"	,"COMOROS, ILHAS"							,"01732"	,"COMORES, ILHAS"						})
aAdd( aPaisCNIS,{"185"	,"CONGO"									,"01775"	,"CONGO"								})
aAdd( aPaisCNIS,{"290"	,"COOK, ILHAS"								,"01830"	,"COOK, ILHAS"							})
aAdd( aPaisCNIS,{"43"	,"COREIA"									,"01872"	,"COREIA, REP.POP.DEMOCRATICA"			})
aAdd( aPaisCNIS,{"43"	,"COREIA"									,"01902"	,"COREIA, REPUBLICA DA"					})
aAdd( aPaisCNIS,{"108"	,"COSMOLEDO, ILHAS"							,""			,""										})
aAdd( aPaisCNIS,{"186"	,"COSTA DO MARFIM"							,"01937"	,"COSTA DO MARFIM"						})
aAdd( aPaisCNIS,{"51"	,"COSTA RICA"								,"01961"	,"COSTA RICA"							})
aAdd( aPaisCNIS,{"250"	,"COVEITE (ATUAL KUWAIT)"					,"01988"	,"COVEITE"								})
aAdd( aPaisCNIS,{"130"	,"CROACIA"									,"01953"	,"CROACIA (REPUBLICA DA)"				})
aAdd( aPaisCNIS,{"52"	,"CUBA"							  			,"01996"	,"CUBA"									})
aAdd( aPaisCNIS,{"53"	,"CURACAO"									,""			,""										})
aAdd( aPaisCNIS,{"146"	,"DAGESTA"									,""			,""										})
aAdd( aPaisCNIS,{"187"	,"DAOME (ATUAL BENIN)"						,""			,""										})
aAdd( aPaisCNIS,{"98"	,"DINAMARCA"		  						,"02321"	,"DINAMARCA"							})
aAdd( aPaisCNIS,{"188"	,"DJIBUTI"									,"07838"	,"DJIBUTI"								})
aAdd( aPaisCNIS,{"54"	,"DOMINICANA, COMUNIDADE"					,""			,""										})
aAdd( aPaisCNIS,{"55"	,"DOMINICANA, REPUBLICA (OU SAO DOMINGOS)"	,"06475"	,"REPUBLICA DOMINICANA"					})
aAdd( aPaisCNIS,{"189"	,"EGITO, REBUPLICA ARABE DO"				,"02402"	,"EGITO"								})
aAdd( aPaisCNIS,{"99"	,"EIRE"										,"03751"	,"IRLANDA"								})
aAdd( aPaisCNIS,{"56"	,"EL SALVADOR, REPUBLICA DE"				,"06874"	,"EL SALVADOR"							})
aAdd( aPaisCNIS,{"27"	,"EQUADOR"									,"02399"	,"EQUADOR"								})
aAdd( aPaisCNIS,{"100"	,"ESCOCIA"									,"06289"	,"REINO UNIDO"							})
aAdd( aPaisCNIS,{"136"	,"ESLOVAQUIA"								,"02470"	,"ESLOVACA, REPUBLICA"					})
aAdd( aPaisCNIS,{"132"	,"ESLOVENIA"								,"02461"	,"ESLOVENIA, REPUBLICA DA"				})
aAdd( aPaisCNIS,{"35"	,"ESPANHA"									,"02453"	,"ESPANHA"								})
aAdd( aPaisCNIS,{"147"	,"ESTONIA"									,"02518"	,"ESTONIA, REPUBLICA DA"				})
aAdd( aPaisCNIS,{"190"	,"ETIOPIA (ATUAL ERITEA)"					,"02437"	,"ERITREIA"								})
aAdd( aPaisCNIS,{"36"	,"EUA"				   						,"02496"	,"ESTADOS UNIDOS"						})
aAdd( aPaisCNIS,{"58"	,"FALKLANDS, ILHAS"	  						,"02550"	,"FALKLAND (ILHAS MALVINAS)"			})
aAdd( aPaisCNIS,{"101"	,"FEROES, ILHAS"	  						,"02593"	,"FEROE, ILHAS"							})
aAdd( aPaisCNIS,{"291"	,"FIJI, REPUBLICA DE"						,"08702"	,"FIJI"									})
aAdd( aPaisCNIS,{"252"	,"FILIPINAS"	  							,"02674"	,"FILIPINAS"							})
aAdd( aPaisCNIS,{"102"	,"FINLANDIA"	 							,"02712"	,"FINLANDIA"							})
aAdd( aPaisCNIS,{"37"	,"FRANCA"	 								,"02755"	,"FRANCA"								})
aAdd( aPaisCNIS,{"334"	,"FRANCESA, ANTARTICA"						,""			,""										})
aAdd( aPaisCNIS,{"191"	,"GABAO, REPUBLICA DO"						,"02810"	,"GABAO"								})
aAdd( aPaisCNIS,{"192"	,"GAMBIA"			 						,"02852"	,"GAMBIA"								})
aAdd( aPaisCNIS,{"193"	,"GANA"										,"02895"	,"GANA"									})
aAdd( aPaisCNIS,{"194"	,"GAZA"										,""			,""										})
aAdd( aPaisCNIS,{"148"	,"GEORGIA"			  						,"02917"	,"GEORGIA, REPUBLICA DA"				})
aAdd( aPaisCNIS,{"103"	,"GIBRALTAR"								,"02933"	,"GIBRALTAR"							})
aAdd( aPaisCNIS,{"298"	,"GILBERT, ILHAS (ATUAL KIRIBATI)"			,""			,""										})
aAdd( aPaisCNIS,{"149"	,"GORNO ALTAI"								,""			,""			  							})
aAdd( aPaisCNIS,{"32"	,"GRA BRETANHA"		   						,"06289"	,"REINO UNIDO"							})
aAdd( aPaisCNIS,{"59"	,"GRANADA"	   								,"02976"	,"GRANADA"								})
aAdd( aPaisCNIS,{"104"	,"GRECIA"									,"03018"	,"GRECIA" 								})
aAdd( aPaisCNIS,{"84"	,"GROELANDIA GRL"							,"03050"	,"GROENLANDIA"							})
aAdd( aPaisCNIS,{"60"	,"GUADALUPE, ILHAS"							,"03093"	,"GUADALUPE"							})
aAdd( aPaisCNIS,{"292"	,"GUAN"										,"03131"	,"GUAM"									})
aAdd( aPaisCNIS,{"61"	,"GUATEMALA"								,"03174"	,"GUATEMALA"	  						})
aAdd( aPaisCNIS,{"87"	,"GUIANA FRANCESA"							,"03255"	,"GUIANA FRANCESA"						})
aAdd( aPaisCNIS,{"88"	,"GUIANA, REPUBLICA"						,"03379"	,"GUIANA"								})
aAdd( aPaisCNIS,{"195"	,"GUINE"									,"03298"	,"GUINE"								})
aAdd( aPaisCNIS,{"344"	,"GUINE BISSAU"								,"03344"	,"GUINE-BISSAU"	  						})
aAdd( aPaisCNIS,{"196"	,"GUINE EQUATORIAL"							,"03310"	,"GUINE-EQUATORIAL"						})
aAdd( aPaisCNIS,{"62"	,"HAITI, REPUBLICA DO"						,"03417"	,"HAITI"								})
aAdd( aPaisCNIS,{"105"	,"HOLANDA (OU PAISES BAIXOS)"				,"05738"	,"PAISES BAIXOS (HOLANDA)"				})
aAdd( aPaisCNIS,{"64"	,"HONDURAS"									,"03450"	,"HONDURAS"								})
aAdd( aPaisCNIS,{"63"	,"HONDURAS BRITANICAS"						,""			,""										})
aAdd( aPaisCNIS,{"253"	,"HONG-KONG (CHINA)"						,"03514"	,"HONG KONG"							})
aAdd( aPaisCNIS,{"299"	,"HOWLAND E JARVIS, ILHAS"					,""			,""										})
aAdd( aPaisCNIS,{"106"	,"HUNGRIA"									,"03557"	,"HUNGRIA, REPUBLICA DA"				})
aAdd( aPaisCNIS,{"254"	,"IEMEN"									,"03573"	,"IEMEN"								})
aAdd( aPaisCNIS,{"345"	,"IEMEN DO SUL"								,""			,""										})
aAdd( aPaisCNIS,{"255"	,"INDIA"									,"03611"	,"INDIA"								})
aAdd( aPaisCNIS,{"256"	,"INDONESIA"								,"03654"	,"INDONESIA"							})
aAdd( aPaisCNIS,{"197"	,"INFNI"									,""			,""										})
aAdd( aPaisCNIS,{"110"	,"INGLATERRA"								,"06289"	,"REINO UNIDO"							})
aAdd( aPaisCNIS,{"257"	,"IRA"										,"03727"	,"IRA, REPUBLICA ISLAMICA DO"			})
aAdd( aPaisCNIS,{"258"	,"IRAQUE"									,"03697"	,"IRAQUE"								})
aAdd( aPaisCNIS,{"112"	,"IRLANDA"									,"03751"	,"IRLANDA"								})
aAdd( aPaisCNIS,{"111"	,"IRLANDA DO NORTE"							,"06289"	,"REINO UNIDO"							})
aAdd( aPaisCNIS,{"113"	,"ISLANDIA"									,"03794"	,"ISLANDIA"								})
aAdd( aPaisCNIS,{"259"	,"ISRAEL"									,"03832"	,"ISRAEL"								})
aAdd( aPaisCNIS,{"39"	,"ITALIA"									,"03867"	,"ITALIA"								})
aAdd( aPaisCNIS,{"114"	,"IUGUSLAVIA"								,""			,""										})
aAdd( aPaisCNIS,{"66"	,"JAMAICA"									,"03913"	,"JAMAICA"								})
aAdd( aPaisCNIS,{"41"	,"JAPAO"									,"03999"	,"JAPAO"								})
aAdd( aPaisCNIS,{"300"	,"JOHNSTON E SAND, ILHAS"					,"03964"	,"JOHNSTON, ILHAS"						})
aAdd( aPaisCNIS,{"260"	,"JORDANIA"									,"04030"	,"JORDANIA"								})
aAdd( aPaisCNIS,{"150"	,"KABARDINO BALKAR"							,""			,""										})
aAdd( aPaisCNIS,{"312"	,"KALIMATAN"								,""			,""										})
aAdd( aPaisCNIS,{"151"	,"KALMIR"									,""			,""										})
aAdd( aPaisCNIS,{"346"	,"KARA KALPAK"								,""			,""										})
aAdd( aPaisCNIS,{"152"	,"KARACHAEVOCHERKESS"						,""			,""										})
aAdd( aPaisCNIS,{"153"	,"KHAKASS"									,""			,""										})
aAdd( aPaisCNIS,{"301"	,"KINGMAN REEF, ILHAS"						,""			,""										})
aAdd( aPaisCNIS,{"154"	,"KOMI"										,""			,""										})
aAdd( aPaisCNIS,{"262"	,"KUWAIT"									,""			,""										})
aAdd( aPaisCNIS,{"263"	,"LAOS"										,"04200"	,"LAOS, REP.POP.DEMOCR.DO"				})
aAdd( aPaisCNIS,{"200"	,"LESOTO"									,"04260"	,"LESOTO"								})
aAdd( aPaisCNIS,{"155"	,"LETONIA"									,"04278"	,"LETONIA, REPUBLICA DA"				})
aAdd( aPaisCNIS,{"264"	,"LIBANO"									,"04316"	,"LIBANO"	 			 				})
aAdd( aPaisCNIS,{"201"	,"LIBERIA"									,"04340"	,"LIBERIA" 		  						})
aAdd( aPaisCNIS,{"202"	,"LIBIA"									,"04383"	,"LIBIA"		 						})
aAdd( aPaisCNIS,{"115"	,"LIECHTENSTEIN"							,"04405"	,"LIECHTENSTEIN" 						})
aAdd( aPaisCNIS,{"313"	,"LINHA, ILHAS"								,""			,""				 	 					})
aAdd( aPaisCNIS,{"156"	,"LITUANIA"									,"04421"	,"LITUANIA, REPUBLICA DA"				})
aAdd( aPaisCNIS,{"116"	,"LUXEMBURGO"								,"04456"	,"LUXEMBURGO"	  						})
aAdd( aPaisCNIS,{"265"	,"MACAU (CHINA)"							,"04472"	,"MACAU"								})
aAdd( aPaisCNIS,{"305"	,"MACDONAL E HEARD, ILHAS"					,""			,""			  							})
aAdd( aPaisCNIS,{"133"	,"MACEDONIA, REPUBLICA DA"					,"04499"	,"MACEDONIA, ANT.REP.IUGOSLAVA"			})
aAdd( aPaisCNIS,{"302"	,"MACQUAIRE, ILHAS"							,""			,""										})
aAdd( aPaisCNIS,{"205"	,"MADAGASCAR"								,"04502"	,"MADAGASCAR"							})
aAdd( aPaisCNIS,{"203"	,"MADEIRA"									,"04525"	,"MADEIRA, ILHA DA"						})
aAdd( aPaisCNIS,{"266"	,"MALASIA"									,"04553"	,"MALASIA"								})
aAdd( aPaisCNIS,{"204"	,"MALAWI (OU MALAUI)"						,"04588"	,"MALAVI"								})
aAdd( aPaisCNIS,{"267"	,"MALDIVAS, ILHAS"							,"04618"	,"MALDIVAS"								})
aAdd( aPaisCNIS,{"206"	,"MALI"										,"04642"	,"MALI"									})
aAdd( aPaisCNIS,{"120"	,"MALTA, REPUBLICA DE"						,"04677"	,"MALTA"								})
aAdd( aPaisCNIS,{"67"	,"MALVINAS, ILHAS"							,"02550"	,"FALKLAND (ILHAS MALVINAS)"			})
aAdd( aPaisCNIS,{"117"	,"MAN, ILHAS DE"							,"03595"	,"MAN, ILHA DE"							})
aAdd( aPaisCNIS,{"285"	,"MANAHIKI, ARQUIPELAGO"					,""			,""										})
aAdd( aPaisCNIS,{"157"	,"MARI"										,""			,""										})
aAdd( aPaisCNIS,{"303"	,"MARIANAS, ILHAS"							,"04723"	,"MARIANAS DO NORTE"					})
aAdd( aPaisCNIS,{"207"	,"MARROCOS"									,"04740"	,"MARROCOS"								})
aAdd( aPaisCNIS,{"304"	,"MARSHALL, ILHAS"							,"04766"	,"MARSHALL,ILHAS"						})
aAdd( aPaisCNIS,{"68"	,"MARTINICA"								,"04774"	,"MARTINICA"							})
aAdd( aPaisCNIS,{"268"	,"MASCATE"									,""			,""										})
aAdd( aPaisCNIS,{"208"	,"MAURICIO"									,"04855"	,"MAURICIO"								})
aAdd( aPaisCNIS,{"209"	,"MAURITANIA"								,"04880"	,"MAURITANIA"							})
aAdd( aPaisCNIS,{"85"	,"MEXICO"									,"04936"	,"MEXICO"								})
aAdd( aPaisCNIS,{"284"	,"MIANMAR"									,"00930"	,"MIANMAR (BIRMANIA)"					})
aAdd( aPaisCNIS,{"286"	,"MIDWAY, ILHAS"							,"04901"	,"MIDWAY, ILHAS"						})
aAdd( aPaisCNIS,{"69"	,"MILHOS, ILHAS"							,""			,""										})
aAdd( aPaisCNIS,{"210"	,"MOCAMBIQUE"								,"05053"	,"MOCAMBIQUE"							})
aAdd( aPaisCNIS,{"158"	,"MODAVIA"				  					,"04944"	,"MOLDAVIA, REPUBLICA DA"				})
aAdd( aPaisCNIS,{"118"	,"MONACO"									,"04952"	,"MONACO"								})
aAdd( aPaisCNIS,{"269"	,"MONGOLIA"									,"04979"	,"MONGOLIA"								})
aAdd( aPaisCNIS,{"70"	,"MONTE SERRAT"								,"05010"	,"MONTSERRAT,ILHAS"						})
aAdd( aPaisCNIS,{"137"	,"MONTENEGRO"								,"04985"	,"MONTENEGRO"							})
aAdd( aPaisCNIS,{"240"	,"NAMIBIA"									,"05070"	,"NAMIBIA"						 		})
aAdd( aPaisCNIS,{"314"	,"NAURU"									,"05088"	,"NAURU"			 	 				})
aAdd( aPaisCNIS,{"270"	,"NEPAL"									,"05177"	,"NEPAL"				 				})
aAdd( aPaisCNIS,{"211"	,"NGUANE"									,""			,""										})
aAdd( aPaisCNIS,{"71"	,"NICARAGUA"								,"05215"	,"NICARAGUA"							})
aAdd( aPaisCNIS,{"306"	,"NIEU, ILHAS"								,"05312"	,"NIUE,ILHA"							})
aAdd( aPaisCNIS,{"212"	,"NIGER, REPUBLICA DO"						,"05258"	,"NIGER"								})
aAdd( aPaisCNIS,{"213"	,"NIGERIA"					 				,"05282"	,"NIGERIA"								})
aAdd( aPaisCNIS,{"307"	,"NORFOLK, ILHAS"							,"05355"	,"NORFOLK,ILHA"							})
aAdd( aPaisCNIS,{"119"	,"NORUEGA"									,"05380"	,"NORUEGA"								})
aAdd( aPaisCNIS,{"338"	,"NORUEGES, ANTARTICO"						,""			,""										})
aAdd( aPaisCNIS,{"315"	,"NOVA CALEDONIA, ILHAS"					,"05428"	,"NOVA CALEDONIA"						})
aAdd( aPaisCNIS,{"316"	,"NOVA GUINE"								,""			,""										})
aAdd( aPaisCNIS,{"317"	,"NOVA ZELANDIA"							,"05487"	,"NOVA ZELANDIA"						})
aAdd( aPaisCNIS,{"318"	,"NOVAS HEBRIDAS, ILHAS (EX VANUATU)"		,""			,""										})
aAdd( aPaisCNIS,{"231"	,"OCEANO INDICO, TERRITORIO BRITANICO"		,""			,""										})
aAdd( aPaisCNIS,{"271"	,"OMAN"										,"05568"	,"OMA"									})
aAdd( aPaisCNIS,{"159"	,"OSSETIA SETENTRIONAL"						,""			,""										})
aAdd( aPaisCNIS,{"296"	,"PACIFICO, ILHAS DO"						,""			,""										})
aAdd( aPaisCNIS,{"121"	,"PAIS DE GALES"							,"06289"	,"REINO UNIDO"							})
aAdd( aPaisCNIS,{"122"	,"PAISES BAIXOS (OU HOLANDA)"				,"05738"	,"PAISES BAIXOS (HOLANDA)"				})
aAdd( aPaisCNIS,{"308"	,"PALAU, ILHAS"								,"05754"	,"PALAU"								})
aAdd( aPaisCNIS,{"272"	,"PALESTINA"								,""			,""										})
aAdd( aPaisCNIS,{"72"	,"PANAMA"									,"05800"	,"PANAMA"								})
aAdd( aPaisCNIS,{"73"	,"PANAMA, ZONA DO CANAL"					,""			,""										})
aAdd( aPaisCNIS,{"214"	,"PAPUA NOVA GUINE"							,"05452"	,"PAPUA NOVA GUINE"						})
aAdd( aPaisCNIS,{"319"	,"PAPUA, TERRITORIO DE"						,""			,""										})
aAdd( aPaisCNIS,{"273"	,"PAQUISTAO"								,"05762"	,"PAQUISTAO"							})
aAdd( aPaisCNIS,{"24"	,"PARAGUAI"									,"05860"	,"PARAGUAI"								})
aAdd( aPaisCNIS,{"320"	,"PASCOA, ILHAS"							,""			,""										})
aAdd( aPaisCNIS,{"89"	,"PERU"										,"05894"	,"PERU"									})
aAdd( aPaisCNIS,{"321"	,"PITCAIRIN, ILHAS"							,"05932"	,"PITCAIRN,ILHA"						})
aAdd( aPaisCNIS,{"322"	,"POLINESIA FRANCESA"						,"05991"	,"POLINESIA FRANCESA"					})
aAdd( aPaisCNIS,{"123"	,"POLONIA"	 								,"06033"	,"POLONIA, REPUBLICA DA"				})
aAdd( aPaisCNIS,{"74"	,"PORTO RICO"								,"06114"	,"PORTO RICO"	   						})
aAdd( aPaisCNIS,{"45"	,"PORTUGAL"									,"06076"	,"PORTUGAL"		   						})
aAdd( aPaisCNIS,{"217"	,"QUENIA (ATUAL NIGER)"						,"06238"	,"QUENIA"		   						})
aAdd( aPaisCNIS,{"160"	,"QUIRQUISTAO"				 				,"06254"	,"QUIRGUIZ, REPUBLICA"					})
aAdd( aPaisCNIS,{"75"	,"QUITASUENO"								,""			,""										})
aAdd( aPaisCNIS,{"219"	,"REUNIAO"									,"06602"	,"REUNIAO, ILHA"						})
aAdd( aPaisCNIS,{"220"	,"RODESIA (ATUAL ZIMBABWE)"					,"06653"	,"ZIMBABUE"								})
aAdd( aPaisCNIS,{"124"	,"ROMENIA"									,"06700"	,"ROMENIA"								})
aAdd( aPaisCNIS,{"76"	,"RONCADOR"									,""			,""										})
aAdd( aPaisCNIS,{"340"	,"ROSS, DEPENDENCIA DE (NOVA ZELANDIA)"		,""			,""										})
aAdd( aPaisCNIS,{"221"	,"RUANDA"									,"06750"	,"RUANDA"								})
aAdd( aPaisCNIS,{"274"	,"RUIQUIU, ILHAS"							,""			,""										})
aAdd( aPaisCNIS,{"348"	,"RUSSIA"					 				,"06769"	,"RUSSIA, FEDERACAO DA"					})
aAdd( aPaisCNIS,{"222"	,"SAARA ESPANHOL"			 				,"06858"	,"SAARA OCIDENTAL"						})
aAdd( aPaisCNIS,{"323"	,"SABAH"									,""			,""										})
aAdd( aPaisCNIS,{"86"	,"SAINT PIERRE ET MIQUELON"					,""			,""										})
aAdd( aPaisCNIS,{"309"	,"SALOMAO, ILHAS"							,"06777"	,"SALOMAO, ILHAS"						})
aAdd( aPaisCNIS,{"324"	,"SAMOA AMERICANA (OU SAMOA ORIENTAL)"		,"06912"	,"SAMOA AMERICANA"						})
aAdd( aPaisCNIS,{"325"	,"SAMOA OCIDENTAL"							,"06904"	,"SAMOA"								})
aAdd( aPaisCNIS,{"326"	,"SANTA CRUZ, ILHAS"						,""			,""										})
aAdd( aPaisCNIS,{"223"	,"SANTA HELENA"								,"07102"	,"SANTA HELENA"							})
aAdd( aPaisCNIS,{"77"	,"SANTA LUCIA"								,"07153"	,"SANTA LUCIA"							})
aAdd( aPaisCNIS,{"78"	,"SAO CRISTOVAO (E NEVIS)"					,"06955"	,"SAO CRISTOVAO E NEVES,ILHAS"			})
aAdd( aPaisCNIS,{"125"	,"SAO MARINHO"								,"06971"	,"SAN MARINO"	   						})
aAdd( aPaisCNIS,{"224"	,"SAO TOME E PRINCIPE"						,""			,""										})
aAdd( aPaisCNIS,{"79"	,"SAO VICENTE (E GRANADINAS)"				,""			,""										})
aAdd( aPaisCNIS,{"327"	,"SARAWAK"									,""			,""										})
aAdd( aPaisCNIS,{"349"	,"SENEGAL"									,"07285"	,"SENEGAL"								})
aAdd( aPaisCNIS,{"276"	,"SEQUIN"									,""			,""										})
aAdd( aPaisCNIS,{"226"	,"SERRA LEOA"								,"07358"	,"SERRA LEOA"							})
aAdd( aPaisCNIS,{"65"	,"SERRANAS, ILHAS"							,""			,""										})
aAdd( aPaisCNIS,{"131"	,"SERVIA"									,"07370"	,"SERVIA"								})
aAdd( aPaisCNIS,{"225"	,"SEYCHELLES"								,"07315"	,"SEYCHELLES"							})
aAdd( aPaisCNIS,{"275"	,"SINGAPURA (OU CINGAPURA)"					,"07412"	,"CINGAPURA"							})
aAdd( aPaisCNIS,{"277"	,"SIRIA"									,"07447"	,"SIRIA, REPUBLICA ARABE DA"			})
aAdd( aPaisCNIS,{"227"	,"SOMALIA, REPUBLICA"						,"07480"	,"SOMALIA"								})
aAdd( aPaisCNIS,{"278"	,"SRI-LANKA"								,"07501"	,"SRI LANKA"							})
aAdd( aPaisCNIS,{"228"	,"SUAZILANDIA"								,"07544"	,"SUAZILANDIA"							})
aAdd( aPaisCNIS,{"229"	,"SUDAO" 									,"07595"	,"SUDAO"								})
aAdd( aPaisCNIS,{"126"	,"SUECIA"									,"07641"	,"SUECIA"								})
aAdd( aPaisCNIS,{"38"	,"SUICA"									,"07676"	,"SUICA"								})
aAdd( aPaisCNIS,{"90"	,"SURINAME"									,"07706"	,"SURINAME"								})
aAdd( aPaisCNIS,{"127"	,"SVALBARD E JAN MAYER, ILHAS"				,""			,""										})
aAdd( aPaisCNIS,{"161"	,"TADJIQUISTAO"								,"07722"	,"TADJIQUISTAO, REPUBLICA DO"			})
aAdd( aPaisCNIS,{"279"	,"TAILANDIA"								,"07765"	,"TAILANDIA"							})
aAdd( aPaisCNIS,{"249"	,"TAIWAN (CHINA)"							,"01619"	,"FORMOSA (TAIWAN)"						})
aAdd( aPaisCNIS,{"230"	,"TANGANICA"								,""			,""										})
aAdd( aPaisCNIS,{"350"	,"TANZANIA"									,"07803"	,"TANZANIA, REP.UNIDA DA"				})
aAdd( aPaisCNIS,{"162"	,"TARTARIA"									,""			,""										})
aAdd( aPaisCNIS,{"135"	,"TCHECA, REPUBLICA (EX TCHECOSLOVAQUIA)"	,"07919"	,"TCHECA, REPUBLICA"					})
aAdd( aPaisCNIS,{"128"	,"TCHECOSLOVAQUIA (ATUAL TCHECA)"			,"07919"	,"TCHECA, REPUBLICA"					})
aAdd( aPaisCNIS,{"341"	,"TERRAS AUSTRAIS"							,""			,""										})
aAdd( aPaisCNIS,{"329"	,"TIMOR (OU TIMOR LESTE)"					,"07951"	,"TIMOR LESTE"							})
aAdd( aPaisCNIS,{"233"	,"TOGO"										,"08001"	,"TOGO"									})
aAdd( aPaisCNIS,{"330"	,"TONGAS"									,"08109"	,"TONGA"								})
aAdd( aPaisCNIS,{"310"	,"TORKELAU, ILHAS"							,"08052"	,"TOQUELAU,ILHAS"						})
aAdd( aPaisCNIS,{"232"	,"TRANSKEI"									,""			,""										})
aAdd( aPaisCNIS,{"280"	,"TREGUA, ESTADO"							,""			,""										})
aAdd( aPaisCNIS,{"91"	,"TRINIDAD E TOBAGO"						,"08150"	,"TRINIDAD E TOBAGO"					})
aAdd( aPaisCNIS,{"234"	,"TUNISIA"									,"08206"	,"TUNISIA"								})
aAdd( aPaisCNIS,{"80"	,"TURCA, ILHAS"								,"08230"	,"TURCAS E CAICOS,ILHAS"				})
aAdd( aPaisCNIS,{"163"	,"TURCOMENISTAO (OU TURMOMENIA)"			,"08249"	,"TURCOMENISTAO, REPUBLICA DO"			})
aAdd( aPaisCNIS,{"47"	,"TURKS E CAICOS, ILHAS"					,""			,""										})
aAdd( aPaisCNIS,{"281"	,"TURQUIA"									,"08273"	,"TURQUIA"								})
aAdd( aPaisCNIS,{"331"	,"TUVALU"									,"08281"	,"TUVALU"								})
aAdd( aPaisCNIS,{"164"	,"TUVIN"									,""			,""										})
aAdd( aPaisCNIS,{"165"	,"UCRANIA"									,"08311"	,"UCRANIA"								})
aAdd( aPaisCNIS,{"166"	,"UDMURT"									,""			,""										})
aAdd( aPaisCNIS,{"235"	,"UGANDA UGA"				  				,"08338"	,"UGANDA"								})
aAdd( aPaisCNIS,{"167"	,"UNIAO SOVIETICA"							,""			,""			 							})
aAdd( aPaisCNIS,{"25"	,"URUGUAI"									,"08451"	,"URUGUAI"								})
aAdd( aPaisCNIS,{"168"	,"USBEQUISTAO"								,"08478"	,"UZBEQUISTAO, REPUBLICA DO"			})
aAdd( aPaisCNIS,{"129"	,"VATICANO, ESTADO DA CIDADE DO"			,"08486"	,"VATICANO, EST.DA CIDADE DO"			})
aAdd( aPaisCNIS,{"92"	,"VENEZUELA"								,"08508"	,"VENEZUELA"							})
aAdd( aPaisCNIS,{"282"	,"VIETNA DO NORTE"							,"08583"	,"VIETNA"								})
aAdd( aPaisCNIS,{"283"	,"VIETNA DO SUL"							,"08583"	,"VIETNA"								})
aAdd( aPaisCNIS,{"82"	,"VIRGENS AMERICANS, ILHAS"					,"08664"	,"VIRGENS,ILHAS (E.U.A.)"				})
aAdd( aPaisCNIS,{"81"	,"VIRGENS BRITANICAS, ILHAS"				,"08630"	,"VIRGENS,ILHAS (BRITANICAS)"			})
aAdd( aPaisCNIS,{"311"	,"WAKE, ILHAS"								,"08737"	,"WAKE, ILHA"							})
aAdd( aPaisCNIS,{"332"	,"WALLIS E FUTUNA, ILHAS"					,""			,""										})
aAdd( aPaisCNIS,{"169"	,"YAKUT"									,""			,""										})
aAdd( aPaisCNIS,{"236"	,"ZAIRE (ATUAL REPUBLICA DEMOCRATICA DO C)"	,"08885"	,"CONGO, REPUBLICA DEMOCRATICA DO"		})
aAdd( aPaisCNIS,{"237"	,"ZAMBIA"									,"08907"	,"ZAMBIA"								})
aAdd( aPaisCNIS,{"239"	,"ZIMBABWE"									,"06653"	,"ZIMBABUE"								})

Return aPaisCNIS

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o      ³fGPM24LOG ³ Autor   ³ Claudinei Soares                ³ Data ³ 08/08/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o   ³ Log de geracao dos arquivos CNIS                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe     ³ fGPM24LOG()                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³ Generico                                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GPM024LOG()

Local aArea			:= GetArea()
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords		:= {}

Local lMarcar     	:= .F.

Local nOpca			:= 0
Local oPanelUp
Local oTela
Local oPanelDown
Local oGroup
Local oFont

Private cAliasMark 	:= "SJ4"
Private cRotina		:= "GPEM024"
Private cFilSJ4		:= Space( GetSx3Cache( "J4_FILIAL", "X3_TAMANHO" ) ) 	// Filial
Private dDataGera 	:= CtoD("//")											// Data de Geracao
Private cVersao		:= Space( GetSx3Cache( "J4_VERSAO", "X3_TAMANHO" ) ) 	// Versao do Arquivo
Private lFilComp		:= Empty(xFilial("SJ4"))
Private oMark
Private oDlg

DbSelectArea(cAliasMark)
SET FILTER TO ALLTRIM(J4_ROTINA)  == "GPEM024"

aAdvSize	:= MsAdvSize( .F.,.F.,370)
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 15 }
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )

Define MsDialog oDlg FROM 0, 0 To 500, 1000 Title STR0035 Pixel

// Cria o container onde serão colocados os paineis
oTela     := FWFormContainer():New( oDlg )
cIdCab	  := oTela:CreateHorizontalBox( 13 )
cIdGrid   := oTela:CreateHorizontalBox( 80 )

oTela:Activate( oDlg, .F. )

//Cria os paineis onde serao colocados os browses
oPanelUp  	:= oTela:GeTPanel( cIdCab )
oPanelDown  := oTela:GeTPanel( cIdGrid )

	@ 0 , aObjSize[1,2]	GROUP oGroup TO 26,aObjSize[1,4]*0.83 LABEL OemToAnsi(STR0036) OF oPanelUp PIXEL	//"Selecione os filtros"
	oGroup:oFont:=oFont

 	@ aObjSize[1,1]*0.5	, aObjSize[1,2]+2		SAY   OemToAnsi(GetSx3Cache("J4_FILIAL", "X3_TITULO")) SIZE 038,007 OF oPanelUp PIXEL
	@ (aObjSize[1,1]*0.5)+6, aObjSize[1,2]+2	MSGET cFilSJ4 SIZE 010,007	OF oPanelUp F3 "XM0" PIXEL WHEN .T. VALID Gp024VldGrid()

	@ aObjSize[1,1]*0.5	, aObjSize[1,2]+80 	SAY   OemToAnsi(GetSx3Cache("J4_DATA", "X3_TITULO")) SIZE 038,007 OF oPanelUp PIXEL
	@ (aObjSize[1,1]*0.5)+6, aObjSize[1,2]+80	MSGET dDataGera SIZE 040,007	OF oPanelUp PIXEL WHEN .T. VALID Gp024VldGrid()

	@ aObjSize[1,1]*0.5	, aObjSize[1,2]+170		SAY   OemToAnsi(GetSx3Cache("J4_VERSAO", "X3_TITULO")) SIZE 038,007 OF oPanelUp PIXEL
	@ (aObjSize[1,1]*0.5)+6, aObjSize[1,2]+170	MSGET cVersao SIZE 010,007	OF oPanelUp PIXEL WHEN .T. VALID Gp024VldGrid()

oMark := FWMarkBrowse():New()

oMark:SetAlias(cAliasMark)

oMark:SetOnlyFields( { 'J4_DATA', 'J4_VERSAO', 'J4_LOCAL', 'J4_NOMARQ' } )

//Indica o container onde sera criado o browse
oMark:SetOwner(oPanelDown)

oMark:Activate()

ACTIVATE MSDIALOG oDlg CENTERED

If Select(cAliasMark) > 0
	DbSelectArea(cAliasMark)
	DbCloseArea()
EndIf

PgsShared()

RestArea( aArea )

Return( NIL )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Gp024VldGrid³ Autor ³ Leandro Drumond       ³ Data ³ 28/03/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valid da enchoice                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MenuDef()                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Gp024VldGrid()

Local cDataDig	 := DTOC(dDataGera)

DbSelectArea(cAliasMark)

If !Empty(cFilSJ4) .and. !Empty(dDataGera) .and. !Empty(cVersao)
	SET FILTER TO J4_FILIAL + Alltrim(J4_ROTINA) + DToc(J4_Data) + J4_VERSAO == cFilSJ4 + cRotina + cDataDig + cVersao
ElseIf !Empty(cFilSJ4) .and. !Empty(dDataGera) .and. Empty(cVersao)
	SET FILTER TO J4_FILIAL + Alltrim(J4_ROTINA) + DToc(J4_Data) == cFilSJ4 + cRotina + cDataDig
ElseIf !Empty(cFilSJ4) .and. Empty(dDataGera) .and. !Empty(cVersao)
	SET FILTER TO J4_FILIAL + Alltrim(J4_ROTINA) + J4_VERSAO == cFilSJ4 + cRotina + cVersao
ElseIf !Empty(cFilSJ4) .and. Empty(dDataGera) .and. Empty(cVersao)
	SET FILTER TO J4_FILIAL + Alltrim(J4_ROTINA) == cFilSJ4 + cRotina
ElseIf Empty(cFilSJ4) .and. !Empty(dDataGera) .and. !Empty(cVersao)
	SET FILTER TO Alltrim(J4_ROTINA) + DToc(J4_Data) + J4_VERSAO  == cRotina + cDataDig + cVersao
ElseIf Empty(cFilSJ4) .and. !Empty(dDataGera) .and. Empty(cVersao)
	SET FILTER TO Alltrim(J4_ROTINA) + DToc(J4_Data) == cRotina + cDataDig
ElseIf Empty(cFilSJ4) .and. Empty(dDataGera) .and. !Empty(cVersao)
	SET FILTER TO Alltrim(J4_ROTINA) + J4_VERSAO  == cRotina + cVersao
ElseIf Empty(cFilSJ4) .and. Empty(dDataGera) .and. Empty(cVersao)
	SET FILTER TO Alltrim(J4_ROTINA)== cRotina
Else
	SET FILTER TO Alltrim(J4_ROTINA) == "GPEM024"
EndIf

oMark:Refresh(.T.)

Return .T.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Gp024CodUF  ³ Autor ³ Claudinei Soares      ³ Data ³ 30/10/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ De/Para do Codigo da Unidade Federativa com a Sigla.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MenuDef()                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Gp024CodUF(cSiglaUF)

Local 	cCodUF		:= ""
Local 	nPosUF		:= 0
Default cSiglaUF	:= ""

If Len(aCodUF) == 0
	aAdd( aCodUF,{"11"	,"RO"	,"RONDÔNIA"				})
	aAdd( aCodUF,{"12"	,"AC"	,"ACRE"					})
	aAdd( aCodUF,{"13"	,"AM"	,"AMAZONAS"				})
	aAdd( aCodUF,{"14"	,"RR"	,"RORAIMA"					})
	aAdd( aCodUF,{"15"	,"PA"	,"PARÁ"					})
	aAdd( aCodUF,{"16"	,"AP"	,"AMAPÁ"					})
	aAdd( aCodUF,{"17"	,"TO"	,"TOCANTINS"				})
	aAdd( aCodUF,{"21"	,"MA"	,"MARANHÃO"				})
	aAdd( aCodUF,{"22"	,"PI"	,"PIAUÍ"					})
	aAdd( aCodUF,{"23"	,"CE"	,"CEARÁ"					})
	aAdd( aCodUF,{"24"	,"RN"	,"RIO GRANDE NO NORTE"	})
	aAdd( aCodUF,{"25"	,"PB"	,"PARAÍBA"					})
	aAdd( aCodUF,{"26"	,"PE"	,"PERNAMBUCO"				})
	aAdd( aCodUF,{"27"	,"AL"	,"ALAGOAS"					})
	aAdd( aCodUF,{"28"	,"SE"	,"SERGIPE"					})
	aAdd( aCodUF,{"29"	,"BA"	,"BAHIA"					})
	aAdd( aCodUF,{"31"	,"MG"	,"MINAS GERAIS"			})
	aAdd( aCodUF,{"32"	,"ES"	,"ESPÍRITO SANTO"			})
	aAdd( aCodUF,{"33"	,"RJ"	,"RIO DE JANEIRO"			})
	aAdd( aCodUF,{"35"	,"SP"	,"SÃO PAULO"				})
	aAdd( aCodUF,{"41"	,"PR"	,"PARANÁ"					})
	aAdd( aCodUF,{"42"	,"SC"	,"SANTA CATARINA"			})
	aAdd( aCodUF,{"43"	,"RS"	,"RIO GRANDE DO SUL"		})
	aAdd( aCodUF,{"50"	,"MS"	,"MATO GROSSO DO SUL"	})
	aAdd( aCodUF,{"51"	,"MT"	,"MATOGROSSO"				})
	aAdd( aCodUF,{"52"	,"GO"	,"GOIÁS"					})
	aAdd( aCodUF,{"53"	,"DF"	,"DISTRITO FEDERAL"		})
Endif

nPosUF := aScan(aCodUF, { |x| x[2] $ cSiglaUF})
If nPosUF > 0
	cCodUF := aCodUF[nPosUF][1]
Endif

Return cCodUF
