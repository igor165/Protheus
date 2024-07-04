#include "protheus.ch"
#include "fileio.ch"
#define CRLF Chr(13)+Chr(10)

Static lAutoSt := .F.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CONFSIB   ºAutor  ³Timoteo Bega        º Data ³  14/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Processamento do arquivo de conferência do SIB enviado pela º±±
±±º          ³ANS trimestralmente.                                        º±±
±±º          ³Atualiza CCO ( BA1_CODCCO )                                 º±±
±±º          ³Gera relatório de críticas do arquivo enviado               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Plano de Saude                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSR780(lAuto)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³             Define Variáveis                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local wnrel   	:= "PLSR780"			// Nome do Arquivo utilizado no Spool
Local Titulo 	:= "Críticas do arquivo de conferência do SIB"
Local cDesc1 	:= "Relatório das Críticas enviadas pelo arquivo de conferência do SIB."
Local cDesc2 	:= "A emissao ocorrerá baseada nos parâmetros do relatório."
Local cDesc3 	:= ""
Local nomeprog	:= "PLSR780.PRW"		// Nome do programa
Local cString 	:= ""					// Alias utilizado na Filtragem
Local lDic    	:= .F.					// Habilita/Desabilita Dicionário
Local lComp   	:= .F.					// Habilita/Desabilita o Formato Comprimido/Expandido
Local lFiltro 	:= .F.					// Habilita/Desabilita o Filtro

Default lauto := .F.

Private Tamanho := "M"					// P/M/G
Private Limite  := 132					// 80/132/220
Private aReturn := { "Zebrado",;		// [1] Reservado para Formulário
1,;				// [2] Reservado para N§ de Vias
"Administrador",;	// [3] Destinatário
2,;				// [4] Formato => 1-Comprimido 2-Normal
1,;	    		// [5] Midia   => 1-Disco 2-Impressora
1,;				// [6] Porta ou Arquivo 1-LPT1... 4-COM1...
"",;				// [7] Expressao do Filtro
1 } 				// [8] Ordem a ser selecionada
// [9]..[10]..[n] Campos a Processar (se houver)
Private m_pag   := 1					// Contador de Paginas
Private nLastKey:= 0					// Controla o cancelamento da SetPrint e SetDefault
Private cPerg   := "PLR780"			// Pergunta do Relatório
Private aOrdem  := {}					// Ordem do Relatório

lAutoSt := lauto

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se campos novos ja foram criados                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  BA1->(FieldPos("BA1_INCANS")) == 0 .Or. ;
	BA1->(FieldPos("BA1_EXCANS")) == 0 .Or. ;
	BA1->(FieldPos("BA1_ENVANS")) == 0 .Or. ;
	BA1->(FieldPos("BA1_CODCCO")) == 0 .Or. ;
	BRP->(FieldPos("BRP_CODSIB")) == 0 .Or. ;
	BQC->(FieldPos("BQC_CNPJ"))   == 0
	if !lauto
		msgalert("Campos necessários a esta rotina não encontrados: BA1_INCANS, BA1_ENVANS, BRP_CODSIB, BQC_CNPJ","Campos inexistentes")
	endif
	Return()
Endif

Pergunte(cPerg, .F.)

if !lauto
	wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,lDic,aOrdem,lComp,Tamanho,lFiltro)
endif

If !lauto .AND. (nLastKey == 27)
	Return(.F.)
Endif

if !lauto
	SetDefault(aReturn,cString)
endif

If !lauto .ANd. (nLastKey == 27)
	Return(.F.)
Endif

if !lauto
	RptStatus({|lEnd| ImprArqSIB(@lEnd,wnRel,cString,nomeprog,Titulo)},Titulo)
else
	ImprArqSIB(.F.,"wnRel",cString,nomeprog,Titulo)
endif

Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ImprArqSIBºAutor  ³Timoteo Bega        º Data ³  14/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função de impressão dos dados.                              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Plano de Saude                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImprArqSIB(lEnd,wnrel,cString,nomeprog,Titulo)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao Do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nLi		:= 0			// Linha a ser impressa
Local nMax		:= 58			// Maximo de linhas suportada pelo Relatório
Local cbCont	:= 0			// Numero de Registros Processados
Local cbText	:= SPACE(10)	// Mensagem do Rodape
Local cCabec1	:= ""			// Label dos itens
Local cCabec2	:= "" 			// Label dos itens
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Declaracao de variaveis especificas para este Relatório³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Local cQuery	:= ""					// Armazena a expressao da query para top
Local nQtd		:= 0					// Contador de registros processados
Local cNomArq	:= ""					// Nome do arquivo temporario de trabalho
Local cCamTxt	:= AllTrim(Mv_Par01)	// Caminho do arquivo texto a ser analisado
Local aStru		:= {}					// Estrutura do arquivo temporario
Local aErros	:= {}					// Armazena todos os erros e Críticas
Local aDados	:= {}					// Dados do beneficiario que possui Críticas
Local cCampo	:= ""					// Nome do campo de aStru
Local nCampo	:= 0					// Valor do campo de aStru
Local cDados	:= ""					// String da Crítica
Local nHdlArq	:= NIL 					// Handle do arquivo de destino do Relatório
Local bEscBe	:= .F.					// Testa se escreveu nome e matricula do beneficiario
Local nDados	:= 0					// Indice da matriz a ser impressa
Local oTempTRB

If !lAutoSt .AND. !File(cCamTxt) // Verifica se o arquivo de conferência indicado existe
	MsgStop("Arquivo "+cCamTxt+" não encontrado.")
	Return(.F.)
Endif

If !lAutoSt .and. File(Lower(AllTrim(Mv_Par02))) // Testa se o arquivo de log existe
	If !FErase(Lower(AllTrim(Mv_Par02))) == 0 // Tenta apagar o arquivo de log encontrado
		MsgStop("Não foi possivel apagar o arquivo: "+AllTrim(Mv_Par02))
		Return(.F.)
	EndIf
EndIf

If !lAutoSt .AND. (nHdlArq := FCreate(Lower(AllTrim(Mv_Par02)),FC_NORMAL)) == -1 // Tenta criar o arquivo de log
	MsgStop("Arquivo "+Lower(AllTrim(Mv_Par02))+" não pode ser criado.")
	Return(.F.)
EndIf

if !lAutoSt
	FWrite(nHdlArq,"Data: "+Dtoc(Date())+Space(104)+"Hora: "+Time()+CRLF)
	FWrite(nHdlArq,"Titulo do Relatório: Críticas do arquivo de conferência do SIB"+CRLF)
	FWrite(nHdlArq,"Descrição: Relatório das Críticas enviadas pelo arquivo de conferência do SIB."+CRLF+CRLF)
endif

// Definicao do layout do arquivo de conferência a ser lido
// Fonte: ANS - IN35 - Anexo I de instrucoes para atualizar os dados do SIB
Aadd(aStru,{"SEQUEN","N",07,0}) // 01
Aadd(aStru,{"ATINAT","N",01,0}) // 02
Aadd(aStru,{"MOTINC","N",02,0}) // 03
Aadd(aStru,{"CODCCO","N",10,0}) // 04
Aadd(aStru,{"DGVCC0","N",02,0}) // 05
Aadd(aStru,{"CODBEN","C",30,0}) // 06
Aadd(aStru,{"NOMUSR","C",70,0}) // 07
Aadd(aStru,{"DTANAS","N",08,0}) // 08
Aadd(aStru,{"SEXUSU","N",01,0}) // 09
Aadd(aStru,{"CPFUSU","C",11,0}) // 10
Aadd(aStru,{"CODTIT","C",30,0}) // 11
Aadd(aStru,{"PISPAS","N",11,0}) // 12
Aadd(aStru,{"NOMMAE","C",70,0}) // 13
Aadd(aStru,{"CNSUSR","C",15,0}) // 14
Aadd(aStru,{"NUMRGU","C",30,0}) // 15
Aadd(aStru,{"ORGRGU","C",30,0}) // 16
Aadd(aStru,{"PAISCI","N",03,0}) // 17
Aadd(aStru,{"NUMANS","N",09,0}) // 18
Aadd(aStru,{"CODPLA","C",30,0}) // 19
Aadd(aStru,{"PLANPO","C",09,0}) // 20
Aadd(aStru,{"DTAINC","C",08,0}) // 21
Aadd(aStru,{"VINCUL","N",02,0}) // 22
Aadd(aStru,{"COBTMP","C",01,0}) // 23
Aadd(aStru,{"COBPRC","N",01,0}) // 24
Aadd(aStru,{"DTAMIG","N",08,0}) // 25
Aadd(aStru,{"CNPJTU","N",14,0}) // 26
Aadd(aStru,{"CEIUSR","N",14,0}) // 27
Aadd(aStru,{"LOGRAD","C",50,0}) // 28
Aadd(aStru,{"NUMEND","C",05,0}) // 29
Aadd(aStru,{"COMPLE","C",15,0}) // 30
Aadd(aStru,{"BAIRRO","C",30,0}) // 31
Aadd(aStru,{"CODMUN","N",07,0}) // 32
Aadd(aStru,{"UNIFED","C",02,0}) // 33
Aadd(aStru,{"INDMOR","N",01,0}) // 34
Aadd(aStru,{"CEPUSR","N",08,0}) // 35
Aadd(aStru,{"DTACAN","N",08,0}) // 36
Aadd(aStru,{"MOTCAN","N",02,0}) // 37
Aadd(aStru,{"DTAREI","N",08,0}) // 38
Aadd(aStru,{"DTULAT","N",08,0}) // 39
Aadd(aStru,{"MOTALT","N",02,0}) // 40
Aadd(aStru,{"DTAANS","N",08,0}) // 41
Aadd(aStru,{"DTAEXC","N",08,0}) // 42
Aadd(aStru,{"DTULRE","N",08,0}) // 43
Aadd(aStru,{"RESANS","C",29,0}) // 44
Aadd(aStru,{"STNOME","N",01,0}) // 45
Aadd(aStru,{"STDTNA","N",01,0}) // 46
Aadd(aStru,{"STSEXO","N",01,0}) // 47
Aadd(aStru,{"STCPFB","N",01,0}) // 48
Aadd(aStru,{"STCDBN","N",01,0}) // 49
Aadd(aStru,{"STPISP","N",01,0}) // 50
Aadd(aStru,{"STNMMA","N",01,0}) // 51
Aadd(aStru,{"SITCNS","N",01,0}) // 52
Aadd(aStru,{"SITRGB","N",01,0}) // 53
Aadd(aStru,{"STORGE","N",01,0}) // 54
Aadd(aStru,{"STPAIS","N",01,0}) // 55
Aadd(aStru,{"STCDPL","N",01,0}) // 56
Aadd(aStru,{"STPLOP","N",01,0}) // 57
Aadd(aStru,{"STPLAN","N",01,0}) // 58
Aadd(aStru,{"STDTAD","N",01,0}) // 59
Aadd(aStru,{"STVINC","N",01,0}) // 60
Aadd(aStru,{"STCOBT","N",01,0}) // 61
Aadd(aStru,{"STEXPR","N",01,0}) // 62
Aadd(aStru,{"STDTAP","N",01,0}) // 63
Aadd(aStru,{"STCNPJ","N",01,0}) // 64
Aadd(aStru,{"STCEIU","N",01,0}) // 65
Aadd(aStru,{"STCDMU","N",01,0}) // 66
Aadd(aStru,{"STUNFE","N",01,0}) // 67
Aadd(aStru,{"STRESI","N",01,0}) // 68
Aadd(aStru,{"STCEPU","N",01,0}) // 69
Aadd(aStru,{"STDTCA","N",01,0}) // 70
Aadd(aStru,{"STMOTC","N",01,0}) // 71
Aadd(aStru,{"STDTRE","N",01,0}) // 72
Aadd(aStru,{"STMTAL","N",01,0}) // 73
Aadd(aStru,{"RESAN2","C",14,0}) // 74

// Definicao das Críticas do arquivo de conferência a ser lido
// Fonte: ANS - IN35 - Anexo I de instrucoes para atualizar os dados do SIB
Aadd( aErros, { "BA1_NOMUSR", "45 - Nome inválido", "", "", "", "" } )
Aadd( aErros, { "BA1_DATNAS", "46 - Data de nascimento menor que 01/01/1902", "46 - Data de nascimento maior que data de competência do envio do SIB", "46 - Data de nascimento maior que data de adesão ao plano", "", "" } )
Aadd( aErros, { "BA1_SEXO", "47 - Código do sexo diferente de 1 e de 3", "", "", "", "" } )
Aadd( aErros, { "BA1_CPFUSR", "48 - CPF preenchido e inválido", "48 - CPF não preenchido", "", "", "" } )
Aadd( aErros, { "BA1_MATVID", "49 - Código preenchido e inválido (Código do beneficiário titular não existe no Cadastro de Beneficiários da ANS)", "49 - Código não preenchido", "", "", "" } )
Aadd( aErros, { "BA1_PISPAS", "50 - PIS/PASEP preenchido e inválido", "50 - PIS/PASEP não preenchido", "", "", "" } )
Aadd( aErros, { "BA1_MAE",	"51 - Nome da mãe preenchido e inválido", "51 - Nome da mãe não preenchido", "", "", "" } )
Aadd( aErros, { "BTS_NRCRNA",	"52 - CNS preenchido e inválido", "52 - CNS não preenchido", "", "", "" } )
Aadd( aErros, { "BA1_DRGUSR", "53 - Carteira de identidade não preenchida", "", "", "", "" } )
Aadd( aErros, { "BA1_ORGEM", "54 - Orgao emissor da carteira de identidade não preenchido", "", "", "", "" } )
Aadd( aErros, { "BTS_CDPAIS",	"55 - Código do pais emissor da carteira de identidade não preenchido", "", "", "", "" } )
Aadd( aErros, { "BI3_SUSEP",	"56 - Número do Código do plano existe na tabela de planos (RPS) e não pertence a operadora", "56 - Número do Código do plano não existe na tabela de planos (RPS)", "56 - Número do Código de plano existe na tabela de planos (RPS), pertence a operadora e está cancelado, porém o beneficiário está ativo", "56 - Número do Código do plano não preenchido", "" } )
Aadd( aErros, { "BI3_SUSEP", "57 - Código do plano não existe na tabela de planos (SCPA)", "57 - Código do plano não preenchido", "", "", "" } )
Aadd( aErros, { "BA1_PLPOR", "58 - Código do plano preenchido e não existe na tabela de planos (RPS)", "58 - Código do plano não preenchido", "", "", "" } )
Aadd( aErros, { "BA1_DATINC",	"59 - Data de adesão menor que 01/01/1940", "59 - Data de adesão maior que data de cancelamento", "59 - Data de adesao menor que data de nascimento", "", "" } )
Aadd( aErros, { "BRP_CODSIB",	"60 - Vínculo do beneficiário não preenchido", "", "", "", "" } )
Aadd( aErros, { "",	"61 - Indicação de existencia de Cobertura Parcial Temporária não preenchida", "", "", "", "" } )
Aadd( aErros, { "",	"62 - Indicação de íntens de procedimentos excluídos da cobertura não preenchida", "", "", "", "" } )
Aadd( aErros, { "",	"63 - Data preenchida e (data < 01/01/2000 ou data < data de adesao)", "63 - Data não preenchida", "", "", "" } )
Aadd( aErros, { "BQC_CNPJ",	"64 - CNPJ preenchido é inválido", "64 - CNPJ não preenchido", "", "", "" } )
Aadd( aErros, { "A1_CEINSS", "65 - CEI preenchido e contém caracteres não numéricos", "65 - CEI não preenchido", "", "", "" } )
Aadd( aErros, { "BA1_MUNICI",	"66 - Código do município preenchido e inválido", "66 - Código do município não preenchido", "", "", "" } )
Aadd( aErros, { "BA1_ESTADO",	"67 - Unidade da Federação preenchida e inválida", "67 - Unidade da Federação não preenchida", "", "", "" } )
Aadd( aErros, { "",	"68 - Indicação se a residencia do beneficiário é no Brasil ou no exterior preenchida é inválida", "68 - Indicação se a residência do beneficiário é no Brasil ou no exterior não preenchida", "", "", "" } )
Aadd( aErros, { "BTS_CEPUSR",	"69 - CEP preenchido e inválido", "69 - CEP não preenchido", "", "", "" } )
Aadd( aErros, { "BA1_DATBLO",	"70 - Data de cancelamento posterior a data de competência do envio do SIB/ANS", "70 - data de cancelamento igual a 30/12/1899 e o beneficiário está ativo", "70 - data de cancelamento anterior a data de adesão ao plano", "70 - data de cancelamento posterior a data de reinclusão e o beneficiário está ativo;", "70 - Data de cancelamento não preenchida e o beneficiário está inativo" } )
Aadd( aErros, { "BA1_MOTBLO",	"71 - Código do motivo de cancelamento preenchido e inválido", "71 - Código do motivo de cancelamento não preenchido", "", "", "" } )
Aadd( aErros, { "BA1_DATALT",	"72 - Data de reinclusão não preenchida e a data de cancelamento está preenchida e o beneficiário está ativo", "", "", "", "" } )
Aadd( aErros, { "",	"73 - Código do motivo de alteração preenchido é inválido", "73 - Código do motivo de alteração não preenchido", "", "", "" } )

//--< Criação do objeto FWTemporaryTable >---
oTempTRB := FWTemporaryTable():New( "TMPTRAB" )
oTempTRB:SetFields( aStru )
oTempTRB:AddIndex( "INDTRB",{ "CODBEN" } )
	
if( select( "TMPTRAB" ) > 0 )
	TMPTRAB->( dbCloseArea() )
endIf
	
oTempTRB:Create()

if lAutoSt
	return
endif
DbSelectArea("TMPTRAB")
APPEND FROM &cCamTxt SDF

TMPTRAB->( DbSetorder(1) )
TMPTRAB->( DbGoTop() )
SetRegua( TMPTRAB->( RecCount() ) )

While TMPTRAB->( !Eof() )
	
	IncRegua("Total de beneficiários " + AllTrim(Str(nQtd++)) )
	ProcessMessage()
	If lEnd
		@Prow()+1,000 PSay "CANCELADO PELO OPERADOR"
		Exit
	Endif
	
	If (TMPTRAB->ATINAT == 3 .AND. Mv_Par03 == 1) .Or. (TMPTRAB->ATINAT == 1 .AND. Mv_Par03 == 2)
		TMPTRAB->( DbSkip() )
		Loop
	EndIf
	
	bEscBe  := .F.
	nIndcam := 45
	dbSelectArea("BA1")
	BA1->(dbSetOrder(2))
	
	If Mv_Par04 == 1
		
		If !BA1->(MsSeek( xFilial("BA1")+AllTrim(TMPTRAB->CODBEN)))
			bEscBe := .T.
			FWrite(nHdlArq,"Mat. Benef.: " + AllTrim(AllTrim(TMPTRAB->CODBEN)) + "  -  Nome Benef.: " + AllTrim(TMPTRAB->NOMUSR) + CRLF)
			Aadd(aDados,"Mat. Benef.: " + AllTrim(AllTrim(TMPTRAB->CODBEN)) + "  -  Nome Benef.: " + AllTrim(TMPTRAB->NOMUSR))			
			FWrite(nHdlArq,"-> Aviso   : Matrícula " + AllTrim(TMPTRAB->CODBEN) + " não encontrado na base de dados." + CRLF)
			Aadd(aDados,"-> Aviso   : Matrícula " + AllTrim(TMPTRAB->CODBEN) + " não encontrado na base de dados.")
		EndIf
			
	EndIf

	If Mv_Par05 == 1 .And. BA1->(MsSeek( xFilial("BA1")+AllTrim(TMPTRAB->CODBEN)))				
			
		If ( Val(BA1->BA1_CODCCO) <> TMPTRAB->CODCCO )
				          
			Reclock("BA1",.F.)
			BA1->BA1_CODCCO := StrZero(TMPTRAB->CODCCO,10)
			MsUnlock()
				
			If !bEscBe
				bEscBe := .T.
				FWrite(nHdlArq,"Mat. Benef.: " + AllTrim(AllTrim(TMPTRAB->CODBEN)) + "  -  Nome Benef.: " + AllTrim(TMPTRAB->NOMUSR) + CRLF)
				Aadd(aDados,"Mat. Benef.: " + AllTrim(AllTrim(TMPTRAB->CODBEN)) + "  -  Nome Benef.: " + AllTrim(TMPTRAB->NOMUSR))				
				FWrite(nHdlArq,"-> Crítica : 04 - Código de Controle Operacional atualizado - BA1_CODCCO" + CRLF )
				Aadd(aDados,"-> Crítica : 04 - Código de Controle Operacional atualizado - BA1_CODCCO")
			EndIf

		EndIf
								
	EndIf		
	
	While nIndcam < 74
		
		If !Empty(aStru[nIndCam][1])
			
			cCampo := "TMPTRAB->"+aStru[nIndCam][1]
			nCampo := &(cCampo)
			
			If nCampo > 0
			
				If !bEscBe
					bEscBe := .T.
					FWrite(nHdlArq,"Mat. Benef.: " + AllTrim(AllTrim(TMPTRAB->CODBEN)) + "  -  Nome Benef.: " + AllTrim(TMPTRAB->NOMUSR) + CRLF)
					Aadd(aDados,"Mat. Benef.: " + AllTrim(AllTrim(TMPTRAB->CODBEN)) + "  -  Nome Benef.: " + AllTrim(TMPTRAB->NOMUSR))
				EndIf
				
				If !Empty(aErros[nIndCam-44][1])
					FWrite(nHdlArq,"-> Crítica : " + AllTrim(aErros[nIndCam-44][nCampo+1]) + " - " + AllTrim(aErros[nIndCam-44][1]) + CRLF )
					Aadd(aDados,"-> Crítica : " + AllTrim(aErros[nIndCam-44][nCampo+1]) + " - " + AllTrim(aErros[nIndCam-44][1]) )					
				Else					
					FWrite(nHdlArq,"-> Crítica : " + AllTrim(aErros[nIndCam-44][nCampo+1]) + CRLF )
					Aadd(aDados,"-> Crítica : " + AllTrim(aErros[nIndCam-44][nCampo+1]) )					
				EndIf
				
			EndIf
			
		EndIf
		
		nIndCam++
		
	EndDo
		
	If bEscBe
		Aadd(aDados,"")	
	EndIf
	
	cDados := ""
	FWrite(nHdlArq,CRLF)
	TMPTRAB->( DbSkip() )
	
EndDo

BA1->( dbCloseArea() )

if( select( "TMPTRAB" ) > 0 )
	oTempTRB:delete()
endIf


FClose(nHdlArq)

For nDados := 1 To Len(aDados) // Imprime os dados
	
	If Len(aDados) > 1
		TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		@ nLi,000		PSay aDados[nDados]
	Endif
	
	If nLi > nMax // Salto de Página. Neste caso o formulario tem 58 linhas...
		nLi := 1
		TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
	Endif
	
Next nDados

If nLi == 0
	TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
	@ nLi+1,000 PSay "Não há informações para imprimir este relatório"
Endif

Roda(cbCont,cbText,Tamanho)

Set Device To Screen
If ( aReturn[5] = 1 )
	Set Printer To
	dbCommitAll()
	OurSpool(wnrel)
Endif
MS_FLUSH()

Return(.T.)
