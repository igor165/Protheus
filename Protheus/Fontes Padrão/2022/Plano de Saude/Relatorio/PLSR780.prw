#include "protheus.ch"
#include "fileio.ch"
#define CRLF Chr(13)+Chr(10)

Static lAutoSt := .F.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CONFSIB   �Autor  �Timoteo Bega        � Data �  14/04/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Processamento do arquivo de confer�ncia do SIB enviado pela ���
���          �ANS trimestralmente.                                        ���
���          �Atualiza CCO ( BA1_CODCCO )                                 ���
���          �Gera relat�rio de cr�ticas do arquivo enviado               ���
�������������������������������������������������������������������������͹��
���Uso       � Plano de Saude                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PLSR780(lAuto)
//��������������������������������������������������������������Ŀ
//�             Define Vari�veis                                 �
//����������������������������������������������������������������
Local wnrel   	:= "PLSR780"			// Nome do Arquivo utilizado no Spool
Local Titulo 	:= "Cr�ticas do arquivo de confer�ncia do SIB"
Local cDesc1 	:= "Relat�rio das Cr�ticas enviadas pelo arquivo de confer�ncia do SIB."
Local cDesc2 	:= "A emissao ocorrer� baseada nos par�metros do relat�rio."
Local cDesc3 	:= ""
Local nomeprog	:= "PLSR780.PRW"		// Nome do programa
Local cString 	:= ""					// Alias utilizado na Filtragem
Local lDic    	:= .F.					// Habilita/Desabilita Dicion�rio
Local lComp   	:= .F.					// Habilita/Desabilita o Formato Comprimido/Expandido
Local lFiltro 	:= .F.					// Habilita/Desabilita o Filtro

Default lauto := .F.

Private Tamanho := "M"					// P/M/G
Private Limite  := 132					// 80/132/220
Private aReturn := { "Zebrado",;		// [1] Reservado para Formul�rio
1,;				// [2] Reservado para N� de Vias
"Administrador",;	// [3] Destinat�rio
2,;				// [4] Formato => 1-Comprimido 2-Normal
1,;	    		// [5] Midia   => 1-Disco 2-Impressora
1,;				// [6] Porta ou Arquivo 1-LPT1... 4-COM1...
"",;				// [7] Expressao do Filtro
1 } 				// [8] Ordem a ser selecionada
// [9]..[10]..[n] Campos a Processar (se houver)
Private m_pag   := 1					// Contador de Paginas
Private nLastKey:= 0					// Controla o cancelamento da SetPrint e SetDefault
Private cPerg   := "PLR780"			// Pergunta do Relat�rio
Private aOrdem  := {}					// Ordem do Relat�rio

lAutoSt := lauto

//��������������������������������������������������������������������������Ŀ
//� Verifica se campos novos ja foram criados                                �
//����������������������������������������������������������������������������
If  BA1->(FieldPos("BA1_INCANS")) == 0 .Or. ;
	BA1->(FieldPos("BA1_EXCANS")) == 0 .Or. ;
	BA1->(FieldPos("BA1_ENVANS")) == 0 .Or. ;
	BA1->(FieldPos("BA1_CODCCO")) == 0 .Or. ;
	BRP->(FieldPos("BRP_CODSIB")) == 0 .Or. ;
	BQC->(FieldPos("BQC_CNPJ"))   == 0
	if !lauto
		msgalert("Campos necess�rios a esta rotina n�o encontrados: BA1_INCANS, BA1_ENVANS, BRP_CODSIB, BQC_CNPJ","Campos inexistentes")
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ImprArqSIB�Autor  �Timoteo Bega        � Data �  14/04/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Fun��o de impress�o dos dados.                              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Plano de Saude                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ImprArqSIB(lEnd,wnrel,cString,nomeprog,Titulo)
//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para Impressao Do Cabecalho e Rodape    �
//����������������������������������������������������������������
Local nLi		:= 0			// Linha a ser impressa
Local nMax		:= 58			// Maximo de linhas suportada pelo Relat�rio
Local cbCont	:= 0			// Numero de Registros Processados
Local cbText	:= SPACE(10)	// Mensagem do Rodape
Local cCabec1	:= ""			// Label dos itens
Local cCabec2	:= "" 			// Label dos itens
//�������������������������������������������������������Ŀ
//�Declaracao de variaveis especificas para este Relat�rio�
//���������������������������������������������������������
//Local cQuery	:= ""					// Armazena a expressao da query para top
Local nQtd		:= 0					// Contador de registros processados
Local cNomArq	:= ""					// Nome do arquivo temporario de trabalho
Local cCamTxt	:= AllTrim(Mv_Par01)	// Caminho do arquivo texto a ser analisado
Local aStru		:= {}					// Estrutura do arquivo temporario
Local aErros	:= {}					// Armazena todos os erros e Cr�ticas
Local aDados	:= {}					// Dados do beneficiario que possui Cr�ticas
Local cCampo	:= ""					// Nome do campo de aStru
Local nCampo	:= 0					// Valor do campo de aStru
Local cDados	:= ""					// String da Cr�tica
Local nHdlArq	:= NIL 					// Handle do arquivo de destino do Relat�rio
Local bEscBe	:= .F.					// Testa se escreveu nome e matricula do beneficiario
Local nDados	:= 0					// Indice da matriz a ser impressa
Local oTempTRB

If !lAutoSt .AND. !File(cCamTxt) // Verifica se o arquivo de confer�ncia indicado existe
	MsgStop("Arquivo "+cCamTxt+" n�o encontrado.")
	Return(.F.)
Endif

If !lAutoSt .and. File(Lower(AllTrim(Mv_Par02))) // Testa se o arquivo de log existe
	If !FErase(Lower(AllTrim(Mv_Par02))) == 0 // Tenta apagar o arquivo de log encontrado
		MsgStop("N�o foi possivel apagar o arquivo: "+AllTrim(Mv_Par02))
		Return(.F.)
	EndIf
EndIf

If !lAutoSt .AND. (nHdlArq := FCreate(Lower(AllTrim(Mv_Par02)),FC_NORMAL)) == -1 // Tenta criar o arquivo de log
	MsgStop("Arquivo "+Lower(AllTrim(Mv_Par02))+" n�o pode ser criado.")
	Return(.F.)
EndIf

if !lAutoSt
	FWrite(nHdlArq,"Data: "+Dtoc(Date())+Space(104)+"Hora: "+Time()+CRLF)
	FWrite(nHdlArq,"Titulo do Relat�rio: Cr�ticas do arquivo de confer�ncia do SIB"+CRLF)
	FWrite(nHdlArq,"Descri��o: Relat�rio das Cr�ticas enviadas pelo arquivo de confer�ncia do SIB."+CRLF+CRLF)
endif

// Definicao do layout do arquivo de confer�ncia a ser lido
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

// Definicao das Cr�ticas do arquivo de confer�ncia a ser lido
// Fonte: ANS - IN35 - Anexo I de instrucoes para atualizar os dados do SIB
Aadd( aErros, { "BA1_NOMUSR", "45 - Nome inv�lido", "", "", "", "" } )
Aadd( aErros, { "BA1_DATNAS", "46 - Data de nascimento menor que 01/01/1902", "46 - Data de nascimento maior que data de compet�ncia do envio do SIB", "46 - Data de nascimento maior que data de ades�o ao plano", "", "" } )
Aadd( aErros, { "BA1_SEXO", "47 - C�digo do sexo diferente de 1 e de 3", "", "", "", "" } )
Aadd( aErros, { "BA1_CPFUSR", "48 - CPF preenchido e inv�lido", "48 - CPF n�o preenchido", "", "", "" } )
Aadd( aErros, { "BA1_MATVID", "49 - C�digo preenchido e inv�lido (C�digo do benefici�rio titular n�o existe no Cadastro de Benefici�rios da ANS)", "49 - C�digo n�o preenchido", "", "", "" } )
Aadd( aErros, { "BA1_PISPAS", "50 - PIS/PASEP preenchido e inv�lido", "50 - PIS/PASEP n�o preenchido", "", "", "" } )
Aadd( aErros, { "BA1_MAE",	"51 - Nome da m�e preenchido e inv�lido", "51 - Nome da m�e n�o preenchido", "", "", "" } )
Aadd( aErros, { "BTS_NRCRNA",	"52 - CNS preenchido e inv�lido", "52 - CNS n�o preenchido", "", "", "" } )
Aadd( aErros, { "BA1_DRGUSR", "53 - Carteira de identidade n�o preenchida", "", "", "", "" } )
Aadd( aErros, { "BA1_ORGEM", "54 - Orgao emissor da carteira de identidade n�o preenchido", "", "", "", "" } )
Aadd( aErros, { "BTS_CDPAIS",	"55 - C�digo do pais emissor da carteira de identidade n�o preenchido", "", "", "", "" } )
Aadd( aErros, { "BI3_SUSEP",	"56 - N�mero do C�digo do plano existe na tabela de planos (RPS) e n�o pertence a operadora", "56 - N�mero do C�digo do plano n�o existe na tabela de planos (RPS)", "56 - N�mero do C�digo de plano existe na tabela de planos (RPS), pertence a operadora e est� cancelado, por�m o benefici�rio est� ativo", "56 - N�mero do C�digo do plano n�o preenchido", "" } )
Aadd( aErros, { "BI3_SUSEP", "57 - C�digo do plano n�o existe na tabela de planos (SCPA)", "57 - C�digo do plano n�o preenchido", "", "", "" } )
Aadd( aErros, { "BA1_PLPOR", "58 - C�digo do plano preenchido e n�o existe na tabela de planos (RPS)", "58 - C�digo do plano n�o preenchido", "", "", "" } )
Aadd( aErros, { "BA1_DATINC",	"59 - Data de ades�o menor que 01/01/1940", "59 - Data de ades�o maior que data de cancelamento", "59 - Data de adesao menor que data de nascimento", "", "" } )
Aadd( aErros, { "BRP_CODSIB",	"60 - V�nculo do benefici�rio n�o preenchido", "", "", "", "" } )
Aadd( aErros, { "",	"61 - Indica��o de existencia de Cobertura Parcial Tempor�ria n�o preenchida", "", "", "", "" } )
Aadd( aErros, { "",	"62 - Indica��o de �ntens de procedimentos exclu�dos da cobertura n�o preenchida", "", "", "", "" } )
Aadd( aErros, { "",	"63 - Data preenchida e (data < 01/01/2000 ou data < data de adesao)", "63 - Data n�o preenchida", "", "", "" } )
Aadd( aErros, { "BQC_CNPJ",	"64 - CNPJ preenchido � inv�lido", "64 - CNPJ n�o preenchido", "", "", "" } )
Aadd( aErros, { "A1_CEINSS", "65 - CEI preenchido e cont�m caracteres n�o num�ricos", "65 - CEI n�o preenchido", "", "", "" } )
Aadd( aErros, { "BA1_MUNICI",	"66 - C�digo do munic�pio preenchido e inv�lido", "66 - C�digo do munic�pio n�o preenchido", "", "", "" } )
Aadd( aErros, { "BA1_ESTADO",	"67 - Unidade da Federa��o preenchida e inv�lida", "67 - Unidade da Federa��o n�o preenchida", "", "", "" } )
Aadd( aErros, { "",	"68 - Indica��o se a residencia do benefici�rio � no Brasil ou no exterior preenchida � inv�lida", "68 - Indica��o se a resid�ncia do benefici�rio � no Brasil ou no exterior n�o preenchida", "", "", "" } )
Aadd( aErros, { "BTS_CEPUSR",	"69 - CEP preenchido e inv�lido", "69 - CEP n�o preenchido", "", "", "" } )
Aadd( aErros, { "BA1_DATBLO",	"70 - Data de cancelamento posterior a data de compet�ncia do envio do SIB/ANS", "70 - data de cancelamento igual a 30/12/1899 e o benefici�rio est� ativo", "70 - data de cancelamento anterior a data de ades�o ao plano", "70 - data de cancelamento posterior a data de reinclus�o e o benefici�rio est� ativo;", "70 - Data de cancelamento n�o preenchida e o benefici�rio est� inativo" } )
Aadd( aErros, { "BA1_MOTBLO",	"71 - C�digo do motivo de cancelamento preenchido e inv�lido", "71 - C�digo do motivo de cancelamento n�o preenchido", "", "", "" } )
Aadd( aErros, { "BA1_DATALT",	"72 - Data de reinclus�o n�o preenchida e a data de cancelamento est� preenchida e o benefici�rio est� ativo", "", "", "", "" } )
Aadd( aErros, { "",	"73 - C�digo do motivo de altera��o preenchido � inv�lido", "73 - C�digo do motivo de altera��o n�o preenchido", "", "", "" } )

//--< Cria��o do objeto FWTemporaryTable >---
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
	
	IncRegua("Total de benefici�rios " + AllTrim(Str(nQtd++)) )
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
			FWrite(nHdlArq,"-> Aviso   : Matr�cula " + AllTrim(TMPTRAB->CODBEN) + " n�o encontrado na base de dados." + CRLF)
			Aadd(aDados,"-> Aviso   : Matr�cula " + AllTrim(TMPTRAB->CODBEN) + " n�o encontrado na base de dados.")
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
				FWrite(nHdlArq,"-> Cr�tica : 04 - C�digo de Controle Operacional atualizado - BA1_CODCCO" + CRLF )
				Aadd(aDados,"-> Cr�tica : 04 - C�digo de Controle Operacional atualizado - BA1_CODCCO")
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
					FWrite(nHdlArq,"-> Cr�tica : " + AllTrim(aErros[nIndCam-44][nCampo+1]) + " - " + AllTrim(aErros[nIndCam-44][1]) + CRLF )
					Aadd(aDados,"-> Cr�tica : " + AllTrim(aErros[nIndCam-44][nCampo+1]) + " - " + AllTrim(aErros[nIndCam-44][1]) )					
				Else					
					FWrite(nHdlArq,"-> Cr�tica : " + AllTrim(aErros[nIndCam-44][nCampo+1]) + CRLF )
					Aadd(aDados,"-> Cr�tica : " + AllTrim(aErros[nIndCam-44][nCampo+1]) )					
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
	
	If nLi > nMax // Salto de P�gina. Neste caso o formulario tem 58 linhas...
		nLi := 1
		TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
	Endif
	
Next nDados

If nLi == 0
	TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
	@ nLi+1,000 PSay "N�o h� informa��es para imprimir este relat�rio"
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
