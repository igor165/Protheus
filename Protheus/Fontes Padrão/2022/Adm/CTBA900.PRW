#include "protheus.ch"
#include "ctba900.ch"
#include "apwizard.ch"

// 17/08/2009 -- Filial com mais de 2 caracteres

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CTBWIZCFG³ Autor ³ Joao Gonçalves de Oliveira ³ Data ³ 10/09/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Configurador de novas moedas no ambiente Contabilidade Gerencial³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTBWIZCFG - PARA EXECUCAO PELA TELA DE ABERTURA DO REMOTE       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ATUALIZACAO SIGACTB                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Main Function CTBWIZMOEDAS()
CTBWIZUPD()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CTBWIZCFG  ³ Autor ³ Joao Gonçalves de Oliveira ³ Data ³ 10/09/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ User Function de mesmo nome criada com  fins de compatibilidade   ³±±
±±³          ³ entre os binários                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTBWIZCFG  - Executada a partir da Main Fuction                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ATUALIZACAO SIGACTB                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function CTBWIZMOEDAS()
CTBWIZUPD()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CTBWIZUPD  ³ Autor ³ Joao Gonçalves de Oliveira ³ Data ³ 10/09/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Funcao executada a partir da User Funcion de mesmo nome para      ³±±
±±³          ³ fins de compatibilidade entre os binários                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTBWIZUPD  - Preparação para execução do Wizard.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ATUALIZACAO SIGACTB                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CTBWIZUPD()

PRIVATE	cArqEmp		:= "SigaMat.Emp"
PRIVATE	nModulo		:= 34
PRIVATE	__cInterNet	:= Nil
PRIVATE nNumeMoed 	:= 1
PRIVATE nMoedIni 	:= 0
PRIVATE cIdioMoed 	:= "Unico"
PRIVATE oMainWnd 
PRIVATE cUserName 	:= ""
PRIVATE oGetDados 
PRIVATE aSM0			:= {}
PRIVATE cMens := STR0002 + CRLF +; 	// "Esta rotina ira atualizar os dicionarios de dados"
STR0003 + CRLF +; 	// "para a utilizacao das novas funcionalidades do SIGACTB."
STR0004 + CRLF +; 	// "E importante realizar um bachup completo dos dicionarios e base de dados, "
STR0005 + CRLF +; 	// "antes da execução desta rotina."
STR0006 			// "Nao deve existir usuarios utilizando o sistema durante a atualizacao!"

PRIVATE cMessage
PRIVATE aArqUpd	 := {}
PRIVATE aREOPEN	 := {}
PRIVATE __lPyme  := .F.
PRIVATE oWizard

TCInternal(5,'*OFF') //-- Desliga Refresh no Lock do Top


Set Dele On
OpenSM0Excl()
aSM0 := AdmAbreSM0()

RpcSetType(3)
RpcSetEnv( aSM0[1][1], aSM0[1][2] )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica quantas moedas já existem no ambiente		³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF (nMoedIni := GETMAXMOED()) == 0
	Return .F.
ENDIF


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Painel 1 - Tela inicial do Wizard 		            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oWizard := APWizard():New(STR0008/*<chTitle>*/,; // "Configuração de Moedas"
STR0010/*<chMsg>*/, ""/*<cTitle>*/, ; // "Essa ferramenta irá efetuar a manutenção nos campos e parâmetros para as novas configurações"
cMens + CRLF + STR0013, ; // "Você deverá escolher o número de moedas que serão incluídas e a partir de qual será efetuada a inclusão"
{||.T.} /*<bNext>*/ ,;
{||.T.}/*<bFinish>*/,;
.F./*<.lPanel.>*/, , , /*<.lNoFirst.>*/)
//{||.T.}/*<bNext>*/ ,;

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Painel 2 - Definição das Novas Moedas               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oWizard:NewPanel(STR0008/*<chTitle>*/,; //"Configuração de Moedas"
STR0014/*<chMsg>*/,; // "Assistente para configuração de novas moedas no sistema"
{||.T.}/*<bBack>*/,;
{||CTBWZVLP2()} /*<bNext>*/ ,;
{||.T.}/*<bFinish>*/,;
.T./*<.lPanel.>*/ ,;
{|| GetNumMoed()}/*<bExecute>*/)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Painel 3 - Descrição das Novas Moedas               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oWizard:NewPanel(STR0008/*<chTitle>*/,;
STR0014/*<chMsg>*/,;
{||.T.}/*<bBack>*/,;
{||CTBWZVLP3()} /*<bNext>*/ ,;
{||.T.}/*<bFinish>*/,;
.T./*<.lPanel.>*/ ,;
{|| GetDescMoed() }/*<bExecute>*/)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Painel 4 - Acompanhamento do Processo               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oWizard:NewPanel(STR0015/*<chTitle>*/,;
""/*<chMsg>*/,;                                                       
`{||.F.} /*<bBack>*/,;
{||.F.}/*<bNext>*/ ,;
{||.T.}/*<bFinish>*/,;
.T./*<.lPanel.>*/ ,;
{| lEnd| CTBWIZREGU(@lEnd)}/*<bExecute>*/)


oWizard:Activate( .T./*<.lCenter.>*/,;
{||.T.}/*<bValid>*/,;
{||.T.}/*<bInit>*/,;
{||.T.}/*<bWhen>*/)

Return(.F.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao    ³CTBWIZPROC³ Autor ³ Eduardo Nunes Cirqueira ³ Data ³ 10/09/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descrição ³ Funcao  de processamento da gravacao dos arquivos             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ ATUALIZACAO SIGACTB                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CTBWizProc(lEnd)
Local cTexto   := ''
Local cFile    := ""
Local cMask    := STR0009 //"Arquivos Texto (*.TXT) |*.txt|"
Local nRecno   := 0
Local nX       := 0
Local nRecAtu
Local lAbriu
Local oPanel := oWizard:oMPanel[oWizard:nPanel]
Local nContFil	:= 0
Local aEmpGrp := {}

//Fechamento do ambiente aberto no inicio do processo
RpcClearEnv()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Abre os arquivos das empresas³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nContFil := 1 to Len(aSM0)
	If aScan( aEmpGrp , aSM0[nContFil][SM0_GRPEMP] ) == 0
		aAdd( aEmpGrp , aSM0[nContFil][SM0_GRPEMP] )
		RpcSetType(3)
		RpcSetEnv(aSM0[nContFil][SM0_GRPEMP], aSM0[nContFil][SM0_CODFIL])
		RpcClearEnv()
		OpenSm0Excl()
	EndIf
Next nContFil

aSize( aEmpGrp , 0 )
aEmpGrp := Nil
aEmpGrp := {}
oProcess:SetRegua1(Len(aSM0))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Realiza as alterações nos dicionários de dados³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nContFil := 1 to Len(aSM0)
	If aScan( aEmpGrp , aSM0[nContFil][SM0_GRPEMP] ) == 0
		aAdd( aEmpGrp , aSM0[nContFil][SM0_GRPEMP] )
		aArqUpd  := {}
		RpcSetType(3)
		RpcSetEnv(aSM0[nContFil][SM0_GRPEMP], aSM0[nContFil][SM0_CODFIL])
		
		cTexto += Replicate("-",128)+CRLF
		cTexto += STR0011+aSM0[nContFil][SM0_GRPEMP]+"/"+STR0012+aSM0[nContFil][SM0_CODFIL]+"-"+aSM0[nContFil][SM0_NOME]+CRLF //"Empresa : "###" Filial : "
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza o dicionario de dados.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cTexto += CTBWizSX3()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza os parametros.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cTexto += CTBWizSX6()		
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza os parametros.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cTexto += CTBWizSXG()		
		
		__SetX31Mode(.F.)
		For nX := 1 To Len(aArqUpd)
			lAbriu := .F.
			IncProc(STR0028+aArqUpd[nx]+"]") //"Atualizando estruturas. Aguarde... ["
			If Select(aArqUpd[nx])>0
				lAbriu := .T.
				dbSelecTArea(aArqUpd[nx])
				dbCloseArea()
			EndIf
			X31UpdTable(aArqUpd[nx])
			If __GetX31Error()
				Alert(__GetX31Trace())
				Aviso(STR0001,STR0023+ aArqUpd[nx] + STR0024,{STR0025},2) //"Atencao!"###"Ocorreu um erro desconhecido durante a atualizacao da tabela : "###". Verifique a integridade do dicionario e da tabela."###"Continuar"
				cTexto += STR0026+aArqUpd[nx] +CRLF //"Ocorreu um erro desconhecido durante a atualizacao da estrutura da tabela : "
				
			ElseIf ! lAbriu
				dbSelectArea(aArqUpd[nx])
				dbCloseArea()
			EndIf
		Next nX
		
		RpcClearEnv()
		OpenSm0Excl()
	EndIf
	oProcess:IncRegua1(STR0011 + aSM0[nContFil][SM0_GRPEMP] + "/"+ STR0012 + aSM0[nContFil][SM0_CODFIL]) 
Next nContFil

RpcSetEnv(aSM0[1][SM0_GRPEMP], aSM0[1][SM0_CODFIL],,,,, { "AE1" })

cTexto     := STR0027+CRLF+cTexto	//	"Log da atualizacao "
__cFileLog := MemoWrite(Criatrab(,.f.)+".LOG",cTexto)

DEFINE FONT oFont NAME "Mono AS" SIZE 5,12   //6,15
@ 5,5 GET oMemo  VAR cTexto MEMO SIZE 280,130 OF oPanel PIXEL
oMemo:bRClicked := {||AllwaysTrue()}
oMemo:oFont:=oFont
DEFINE SBUTTON FROM 122,250 TYPE 13 ACTION (cFile:=cGetFile(cMask,""),If(cFile="",.t.,MemoWrite(cFile,cTexto))) ENABLE OF oPanel PIXEL //Salva e Apaga //"Salvar Como..."

aSize( aEmpGrp , 0 )
aEmpGrp := Nil

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CTBWizSX3 ³ Autor ³ Eduardo Nunes Cirqueira ³ Data ³ 10/09/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao  de processamento da gravacao do SX3                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ATUALIZACAO SIGACTB                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CTBWizSX3()

//	X3_ARQUIVO X3_ORDEM   X3_CAMPO   X3_TIPO    X3_TAMANHO X3_DECIMAL X3_TITULO  X3_TITSPA  X3_TITENG
//  X3_DESCRIC X3_DESCSPA X3_DESCENG X3_PICTURE X3_VALID   X3_USADO   X3_RELACAO X3_F3      X3_NIVEL
//  X3_RESERV  X3_CHECK   X3_TRIGGER X3_PROPRI  X3_BROWSE  X3_VISUAL  X3_CONTEXT X3_OBRIGAT X3_VLDUSER
//  X3_CBOX    X3_CBOXSPA X3_CBOXENG X3_PICTVAR X3_WHEN    X3_INIBRW  X3_GRPSXG  X3_FOLDER

Local aSX3      := {}
Local aEstrut   := {} 
Local aSX31 	:= {}
Local aSX32 	:= {}
Local aSX3Copia := {} 
Local aSX3Field := {}
Local aHelpPor	:= {}
Local aHelpEng	:= {}
Local aHelpEsp	:= {}
Local i         := 0
Local j         := 0
Local lSX3	    := .F.
Local cTexto    := ''
Local cAlias    := ''
Local cUltCpo   := ''
Local nOrdSX3   := SX3->( IndexOrd() )
Local lFormul
Local lAmarra
Local nContEstr := 1
Local nContItem := 1
Local nContCols := 1
Local nContMoed := 1
Local aCampos   := {}
Local aColsGet	:= ACLONE(oGetDados:aCols)
Local nTamCpo	:= 0
Local uAux		:= NIL		// Tipo indefinido para multiproposito.
 
Local lInDB		:= MPDicInDB()
 

aEstrut := { "X3_ARQUIVO","X3_ORDEM"  ,"X3_CAMPO"  ,"X3_TIPO"   ,"X3_TAMANHO","X3_DECIMAL","X3_TITULO" ,"X3_TITSPA" ,"X3_TITENG" ,;
"X3_DESCRIC","X3_DESCSPA","X3_DESCENG","X3_PICTURE","X3_VALID"  ,"X3_USADO"  ,"X3_RELACAO","X3_F3"     ,"X3_NIVEL"  ,;
"X3_RESERV" ,"X3_CHECK"  ,"X3_TRIGGER","X3_PROPRI" ,"X3_BROWSE" ,"X3_VISUAL" ,"X3_CONTEXT","X3_OBRIGAT","X3_VLDUSER",;
"X3_CBOX"   ,"X3_CBOXSPA","X3_CBOXENG","X3_PICTVAR","X3_WHEN"   ,"X3_INIBRW" ,"X3_GRPSXG" ,"X3_FOLDER" ,"X3_PYME"	  }

/* Identificando os campos do SX3 na matriz aEstrut
01-X3_ARQUIVO  02-X3_ORDEM	  03-X3_CAMPO    04-X3_TIPO     05-X3_TAMANHO  06-X3_DECIMAL  07-X3_TITULO  08-X3_TITSPA
09-X3_TITENG   10-X3_DESCRIC  11-X3_DESCSPA  12-X3_DESCENG  13-X3_PICTURE  14-X3_VALID    15-X3_USADO   16-X3_RELACAO
17-X3_F3       18-X3_NIVEL    19-X3_RESERV   20-X3_CHECK    21-X3_TRIGGER  22-X3_PROPRI   23-X3_BROWSE  24-X3_VISUAL
25-X3_CONTEXT  26-X3_OBRIGAT  27-X3_VLDUSER  28-X3_CBOX     29-X3_CBOXSPA  30-X3_CBOXENG  31-X3_PICTVAR 32-X3_WHEN
33-X3_INIBRW   34-X3_GRPSXG   35-X3_FOLDER   36-X3_PYME
*/

// Campos a serem aumentados
Aadd(aSX3Field,"CT2_CONVER")
Aadd(aSX3Field,"CT2_MOEDAS")
Aadd(aSX3Field,"CT5_MOEDAS")
Aadd(aSX3Field,"CT9_MOEDAS")
Aadd(aSX3Field,"CT9_CRITER")
Aadd(aSX3Field,"CTK_MOEDAS")
Aadd(aSX3Field,"CVK_MOEDAS")

// Campos do SX3 a terem copiados os conteúdos e serem criados 
AADD(aSX3Copia,"M2_MOEDA2")
AADD(aSX3Copia,"M2_TXMOED2")
AADD(aSX3Copia,"CT1_DESC02")
AADD(aSX3Copia,"CT1_CVD02")
AADD(aSX3Copia,"CT1_CVC02")
AADD(aSX3Copia,"CT2_VLR02")
AADD(aSX3Copia,"CT2_VALR02")
AADD(aSX3Copia,"CT2_DTTX02")
AADD(aSX3Copia,"CT2_TAXA02")
AADD(aSX3Copia,"CT5_VLR02" )
AADD(aSX3Copia,"CTD_DESC02")
AADD(aSX3Copia,"CTH_DESC02")
AADD(aSX3Copia,"CTK_VLR02")
AADD(aSX3Copia,"CTT_DESC02")
AADD(aSX3Copia,"CV3_VLR02")
AADD(aSX3Copia,"CVK_VLR02")

//*******************************
//  Campo do modulo Ativo Fixo  *
//*******************************
AADD(aSX3Copia,"N3_VORIG2")
AADD(aSX3Copia,"N3_TXDEPR2")
AADD(aSX3Copia,"N3_VRCBAL2")
AADD(aSX3Copia,"N3_VRDBAL2")
AADD(aSX3Copia,"N3_VRCMES2")
AADD(aSX3Copia,"N3_VRDMES2")
AADD(aSX3Copia,"N3_VRCACM2")
AADD(aSX3Copia,"N3_VRDACM2")
AADD(aSX3Copia,"N3_INDICE2")
AADD(aSX3Copia,"N3_VRCDM2")
AADD(aSX3Copia,"N3_VRCDB2")
AADD(aSX3Copia,"N3_VRCDA2")
AADD(aSX3Copia,"N3_AMPLIA2")
AADD(aSX3Copia,"N3_VLACEL2")
AADD(aSX3Copia,"N4_VLROC2")
AADD(aSX3Copia,"N5_VALOR2")
AADD(aSX3Copia,"N6_VALOR2")
AADD(aSX3Copia,"NA_VALOR2")
AADD(aSX3Copia,"NC_VALOR2")
AADD(aSX3Copia,"NG_TXDEPR2")
AADD(aSX3Copia,"NR_TXDEPR2")
AADD(aSX3Copia,"NR_VLRMOD2")
AADD(aSX3Copia,"NS_TXDEPR2")
AADD(aSX3Copia,"NS_VLRBAS2")
AADD(aSX3Copia,"NS_VLRACM2")
AADD(aSX3Copia,"NS_VLRMOV2")
AADD(aSX3Copia,"NT_MOEDA2")
AADD(aSX3Copia,"NN_TXDEPR2")
AADD(aSX3Copia,"NN_VORIG2")
AADD(aSX3Copia,"FNG_TXDEP2")



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gera vetores com as informações dos campos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SX3->( DbSetOrder(2) )
nTamCpo := Val(aColsGet[Len(aColsGet),1])
For nContItem := 1 to Len(aSX3Field)
	SX3->( DbSeek(aSX3Field[nContItem]) )		
	CTBX3Field(aSX3Field[nContItem], "X3_TAMANHO", nTamCpo) 
	CTBX3Field(aSX3Field[nContItem], "X3_GRPSXG", "029")  // Alterar grupo de campo
Next		

For nContCols := 1 to Len(aColsGet)

	SX3->( DbSetOrder(2) )
	For nContItem := 1 to Len( aSX3Copia )                                                           
		SX3->( DbSeek(aSX3Copia[nContItem]) )   
		aCampos := {}
		
		For nContEstr := 1 to Len(aEstrut)
      
			cEstrut := "SX3->" + aEstrut[nContEstr]										
			If AllTrim(aEstrut[nContEstr]) $"X3_CAMPO,X3_DESCENG,X3_DESCSPA,X3_DESCRIC,X3_TITULO,X3_TITSPA,X3_TITENG"
							
				cConteudo := &cEstrut
				If 'X3_CAMPO'	$ cEstrut 
					If 'M2_TXMOED2' $ cConteudo 
						If Val(aColsGet[nContCols,1]) > 9
							cConteudo := 'M2_TXMOE' + aColsGet[nContCols,1]
						Else
							cConteudo := 'M2_TXMOED' + aColsGet[nContCols,1]
						EndIf
					ElseIf 'M2_MOEDA2' $ cConteudo 
						cConteudo := 'M2_MOEDA' + aColsGet[nContCols,1]
					ElseIf cConteudo>= "N1_" .and. cConteudo<="NZ_" .or. cConteudo = "FNG_"
						//***********************
						// Campos do Ativo Fixo *
						//***********************
						cConteudo := ALLTRIM(cConteudo)
						If Val(aColsGet[nContCols,1]) > 9 .and. Len(cConteudo)==10
							cConteudo := SubStr(cConteudo,1,Len(cConteudo)-2) + aColsGet[nContCols,1]
						Else
							cConteudo := SubStr(cConteudo,1,Len(cConteudo)-1) + aColsGet[nContCols,1]
						EndIf
					Else
						cConteudo := StrTran( cConteudo, '02', STRZERO(VAL(aColsGet[nContCols,1]),2)  )
					EndIf
				Else
					cConteudo := CT900Desc(cEstrut,cConteudo,aColsGet[nContCols,1])
				EndIf				
			ElseIF AllTrim(aEstrut[nContEstr])  $ "X3_RESERV;X3_USADO"
				
				 If  AllTrim(aEstrut[nContEstr])  == 	 "X3_USADO"
					If lInDB
						cConteudo := FWConvBin( &cEstrut )
					Else	
						cConteudo :=    &cEstrut
					EndIF
				Else
					If lInDB
						cConteudo := FWConvRese( &cEstrut )
					Else
						cConteudo :=    &cEstrut
					EndIF
				EndIF	
			ELSE 
				cConteudo := &cEstrut
				If (AllTrim(aEstrut[nContEstr]) == "X3_VALID") 
					// Indice do campo atual
					uAux := STRZERO(VAL(aColsGet[nContCols,1]),2)
					// Efetua a troca do conteudo
					If		("M->CT2_VALR02" $ cConteudo)
						cConteudo := StrTran(cConteudo,"CT2_VALR02","CT2_VALR"+uAux)
					ElseIf	("M->CT2_DTTX02" $ cConteudo)
						cConteudo := StrTran(cConteudo,"CT2_DTTX02","CT2_DTTX"+uAux)
					EndIf
				EndIf
			EndIf			
			aAdd(aCampos,cConteudo)
		Next			             
		aAdd( aSx3,aCampos)
	
	Next nContItem                                    
	
Next nContCols	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Identifica ordem correta para inclusão dos campos no SX3³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nContItem := 1 to Len(aSX3)
	aSX3[nContItem,2] := ProxSX3(aSX3[nContItem,1],aSX3[nContItem,3])
Next	

oProcess:SetRegua2(Len(aSX3))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza dicionário de dados³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nContItem := 1 To Len(aSX3)
		
	cNomeCamp := AllTrim(aSX3[nContItem,3])
	
	If ! dbSeek(cNomeCamp)
		lSX3	:= .T.
		If ! (aSX3[nContItem,1] $ cAlias)
			cAlias += aSX3[nContItem,1]+"/"
			If Ascan(aArqUpd,aSX3[nContItem,1]) == 0
				aAdd(aArqUpd,aSX3[nContItem,1])
			EndIf
		EndIf
		
		RecLock("SX3",.T.)
		For nContEstr :=1 To Len(aSX3[nContEstr])
		
			If FieldPos(aEstrut[nContEstr])>0
				FieldPut(FieldPos(aEstrut[nContEstr]),aSX3[nContItem,nContEstr])
			EndIf
			
		Next nContEstr
		dbCommit()
		MsUnLock()
		oProcess:IncRegua2(STR0033)	
	EndIf		
	
Next nContItem

If lSX3
	cTexto := STR0035+cAlias+CRLF //'Tabelas atualizadas : '
EndIf

Return cTexto


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CT900Desc ºAutor  ³Alvaro Camillo Neto º Data ³  20/05/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Realiza o tratamento da String de descrição, trocando       º±±
±±º          ³o numero pelo corrente e abreviando quando necessario       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA900                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CT900Desc(cCampo,cConteudo,cNovoCont)
Local aDic	  		:= {}
Local nLenCampo	:= Len(&cCampo)
Local nLenConteudo:= 0
Local nX				:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega o dicionario de palavras e suas abreviações³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aDic,{"Taxa","Tx"})
aAdd(aDic,{"Moeda","M."})
aAdd(aDic,{"Moneda","M."})
aAdd(aDic,{"Mond","M."})
aAdd(aDic,{"Moed","M."})
aAdd(aDic,{"Inflacao","Inf."})
aAdd(aDic,{"Inflacion","Inf."})
aAdd(aDic,{"Moned","M."})
aAdd(aDic,{"Conv.","C."})
aAdd(aDic,{"Proj.","P."})
aAdd(aDic,{"Depr.","Dp."})
aAdd(aDic,{"Ampliac.","Ampl."})
aAdd(aDic,{"Valor","Vlr."})
aAdd(aDic,{"Depr","Dp."})
aAdd(aDic,{"Dp. ","Dp."})
aAdd(aDic,{"Movim. ","Movim."})
aAdd(aDic,{"Ampliacao","Ampliac."})
aAdd(aDic,{"Tasa","Ts"})
aAdd(aDic,{"Vlr.Movim.M","Vlr.Mov.M"})
aAdd(aDic,{"Value","Val"})
aAdd(aDic,{"Val. ","Val"})
aAdd(aDic,{"Dep.Cur","Dep.C"})
aAdd(aDic,{"Projected","Proj."})
aAdd(aDic,{"Ampliacion","Ampliac."})
aAdd(aDic,{"Original Value Currency","Original Value Curr."})



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Realiza a troca do 02 pelo numero do campo da nova moeda³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cConteudo := ALLTRIM(StrTran(cConteudo,"0"	,''))
cConteudo := ALLTRIM(StrTran(cConteudo,"2"	,cNovoCont))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Realiza as abreviações caso necessário³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLenConteudo:= Len(Alltrim(cConteudo))

If nLenConteudo > nLenCampo
	For nX := 1 to Len(aDic)
		cConteudo := ALLTRIM(StrTran(cConteudo,aDic[nX][1],aDic[nX][2]))
		nLenConteudo:= Len(Alltrim(cConteudo))
		If nLenConteudo <= nLenCampo
			Exit
		EndIf
	Next nX
EndIf 


Return cConteudo	 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CTBWIZSX6³ Autor ³ Joao Gonçalves de Oliveira ³ Data ³ 10/09/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Funcao de processamento da gravação do SX6                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTBWIZSX6                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ATUALIZACAO SIGACTB                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function CTBWIZSX6()
//  X6_FIL   X6_VAR     X6_TIPO    X6_DESCRIC X6_DSCSPA  X6_DSCENG  X6_DESC1 X6_DSCSPA1 X6_DSCENG1
//  X6_DESC2 X6_DSCSPA2 X6_DSCENG2 X6_CONTEUD X6_CONTSPA X6_CONTENG X6_PROPRI

Local aSX6   		:= {}
Local aSX6Copia 	:= {}
Local aEstrut		:= {}
Local i      		:= 0
Local j      		:= 0
Local lSX6	 		:= .F.
Local cTexto 		:= ''
Local cAlias 		:= ''
Local aCampos 		:= {}
Local nContEstr 	:= 1
Local nContCols 	:= 1
Local nContItem 	:= 1
Local cEstrut 		:= ""
Local aColsGet 	:= ACLONE(oGetDados:aCols)
Local aHeaderGet	:= ACLONE(oGetDados:aHeader)
Local nTamFilial:= CtbTamSXG("033",2)

Local nPosMoeda	:= ASCAN(aHeaderGet,{|x| ALLTRIM(x[2]) == "cMoeda"})
Local nPosSimb		:= ASCAN(aHeaderGet,{|x| ALLTRIM(x[2]) == "cSimbolo"})
Local nPosNomePrt	:= ASCAN(aHeaderGet,{|x| ALLTRIM(x[2]) == "cNomePort"})
Local nPosPlrPrt	:= ASCAN(aHeaderGet,{|x| ALLTRIM(x[2]) == "cPlurPort"})
Local nPosNomeEng	:= ASCAN(aHeaderGet,{|x| ALLTRIM(x[2]) == "cNomeEngl"})
Local nPosPlrEng	:= ASCAN(aHeaderGet,{|x| ALLTRIM(x[2]) == "cPlurEngl"})
Local nPosNomeSpa	:= ASCAN(aHeaderGet,{|x| ALLTRIM(x[2]) == "cNomeSpan"})
Local nPosPlrSpa	:= ASCAN(aHeaderGet,{|x| ALLTRIM(x[2]) == "cPlurSpan"})

If (cPaisLoc == "BRA")
	aEstrut:= { "X6_FIL","X6_VAR","X6_TIPO","X6_DESCRIC","X6_DSCSPA","X6_DSCENG","X6_DESC1","X6_DSCSPA1","X6_DSCENG1",;
	"X6_DESC2","X6_DSCSPA2","X6_DSCENG2","X6_CONTEUD","X6_CONTSPA","X6_CONTENG","X6_PROPRI","X6_PYME"}
Else
	aEstrut:= { "X6_FIL","X6_VAR","X6_TIPO","X6_DESCRIC","X6_DSCSPA","X6_DSCENG","X6_DESC1","X6_DSCSPA1","X6_DSCENG1",;
	"X6_DESC2","X6_DSCSPA2","X6_DSCENG2","X6_CONTEUD","X6_CONTSPA","X6_CONTENG","X6_PROPRI","X6_PYME"}
EndIf             

aSX6Copia := {"MV_MOEDA2","MV_MOEDAP2","MV_SIMB2","MV_CENT2"}	

SX6->(dbSetOrder(1))
For nContCols := 1 to Len(aColsGet)

	For nContItem := 1 to Len( aSX6Copia )

		SX6->( DbSeek( Space(nTamFilial) + aSX6Copia[nContItem]) )
   
		aCampos := {}
		For nContEstr := 1 to Len(aEstrut)
		   
			cEstrut := "SX6->" + aEstrut[nContEstr]										
			cConteudo := &cEstrut
			
			If AllTrim(aEstrut[nContEstr]) $" X6_VAR,X6_DESCRIC,X6_DSCSPA,X6_DSCENG,X6_DESC1,X6_DSCSPA1,X6_DSCENG1"
				cConteudo := &cEstrut
				If Val( aColsGet[nContCols,1] ) > 9
					cConteudo := StrTran( cConteudo, 'MV_MOEDAP', 'MV_MOEDP' ) 
				EndIf

				cConteudo := StrTran(cConteudo,"2",aColsGet[nContCols,1])

			ElseIf AllTrim(aEstrut[nContEstr])$"X6_CONTEUD,X6_CONTSPA,X6_CONTENG"
				
				If cIdioMoed == "Unico"
	
					Do Case
						Case "MV_MOEDAP" $ SX6->X6_VAR
							cConteudo := aColsGet[nContCols,nPosPlrPrt]
						Case "MV_SIMB" $ SX6->X6_VAR
							cConteudo := aColsGet[nContCols,nPosSimb]
						Case "MV_MOEDA" $ SX6->X6_VAR
							cConteudo := aColsGet[nContCols,nPosNomePrt]
					EndCase

    			ElseIf AllTrim(aEstrut[nContEstr]) == "X6_CONTSPA"
    			
	   				Do Case
						Case "MV_MOEDAP" $ SX6->X6_VAR
							cConteudo := aColsGet[nContCols,nPosPlrSpa]
						Case "MV_SIMB" $ SX6->X6_VAR
							cConteudo := aColsGet[nContCols,nPosSimb]
						Case "MV_MOEDA" $ SX6->X6_VAR
							cConteudo := aColsGet[nContCols,nPosNomeSpa]
					EndCase
    			
    			ElseIf AllTrim(aEstrut[nContEstr]) == "X6_CONTENG"

	   				Do Case
						Case "MV_MOEDAP" $ SX6->X6_VAR
							cConteudo := aColsGet[nContCols,nPosPlrEng]
						Case "MV_SIMB" $ SX6->X6_VAR
							cConteudo := aColsGet[nContCols,nPosSimb]
						Case "MV_MOEDA" $ SX6->X6_VAR
							cConteudo := aColsGet[nContCols,nPosNomeEng]
					EndCase
    			
    			Endif

            Endif

			aAdd(aCampos,cConteudo)
		Next		
		aAdd( aSx6,aCampos)
	Next	
Next                                     

SX6->(dbSetOrder(1))
		
oProcess:SetRegua2(Len(aSX6))

dbSelectArea("SX6")
dbSetOrder(1)
For i:= 1 To Len(aSX6)
	If !Empty(aSX6[i][2])
		If !dbSeek(aSX6[i,1]+aSX6[i,2])
			lSX6	:= .T.
			If !(aSX6[i,2]$cAlias)
				cAlias += aSX6[i,2]+"/"
			EndIf
			RecLock("SX6",.T.)
			For j:=1 To Len(aSX6[i])
				If !Empty(FieldName(FieldPos(aEstrut[j])))
					FieldPut(FieldPos(aEstrut[j]),aSX6[i,j])
				EndIf
			Next j
			
			dbCommit()
			MsUnLock()
		
			oProcess:IncRegua2(STR0037)	
		EndIf
	EndIf
Next i

If lSX6
	cTexto := STR0038+cAlias+CRLF //'Incluidos novos parametros. Verifique as suas configuracoes e funcionalidades : '
EndIf

Return cTexto

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CTBWIZSXG ³ Autor ³ Eduardo Nunes Cirqueira ³ Data ³ 10/09/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Funcao  de processamento da gravacao do SXG                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ATUALIZACAO SIGACTB                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CTBWIZSXG()
//INDICE ORDEM CHAVE DESCRICAO DESCSPA DESCENG PROPRI F3 NICKNAME
Local cTexto := ''
Local lSXG   := .F.
Local lNew   := .F.
Local aSXG   := {}
Local aEstrut:= {}
Local i      := 0
Local j      := 0
Local cAlias := ''
Local cOrdem := "029"  // Alterar para ordem correta

aEstrut := {"XG_GRUPO","XG_DESCRI","XG_DESSPA","XG_DESENG","XG_SIZEMAX","XG_SIZEMIN","XG_SIZE","XG_PICTURE"}

aSXG := {}

// Grupo de Campos
Aadd(aSXG,{cOrdem,"Conversão de Moedas","Conversión de Monedas","Currencies Convertion",5,9,5,"@!"}) //Conversão de Moedas###Conversión de Monedas###Currencies Convertion"

ProcRegua(Len(aSXG))

oProcess:SetRegua1(Len(aSXG))

dbSelectArea("SXG")
dbSetOrder(1)

For i:= 1 To Len(aSXG)

	If !Empty(aSXG[i,1])
	
		If !dbSeek(aSXG[i,1])
			lNew:= .T.
		Else
			lNew:= .F.
		EndIf
		
		If lNew 
			lSXG := .T.			
		
			RecLock("SXG",lNew)
			
			For j:=1 To Len(aSXG[i])				

				If FieldPos(aEstrut[j])>0
					
					If AllTrim(aEstrut[j]) == "XG_SIZE"
						aSXG[i,j] += nNumeMoed
					EndIf						
					
					FieldPut(FieldPos(aEstrut[j]),aSXG[i,j])
				EndIf
			
			Next j
			dbCommit()
			MsUnLock()
		EndIf
		
		oProcess:IncRegua2(STR0052) 
	EndIf
Next i

If lSXG
	cTexto += STR0016+cAlias+CRLF  // Grupos de Campos Atualizados
EndIf

Return cTexto

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GetNumMoed ºAutor³Joao Gonçalves de Oliveira º Data ³ 10/09/08      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescrição ³ Monta gets para informação do número, moeda inicial e tipo          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ GetNumMoed()                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParâmetros³                                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTB - Contabilidade Gerencial                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Expa1 - Vetor com informaçoes de número, moeda inicial e tipo       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GetNumMoed()

Local oPanel
Local aIdioMoed 	:= {"Unico","Todos"}
Local nMaxMoed		:= GETMAXMOED()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gets com os dados para definição das moedas                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPanel := oWizard:oMPanel[oWizard:nPanel]
oSayNMoe := TSay():New( 005, 008,{|| STR0017},oPanel,,,.F.,.F.,.F.,.T.,,,,, .F.,.F.,.F.,.F.,.F.) //"Total de Moedas a serem criadas:"
oSayMoed := TSay():New( 035, 008,{|| STR0018},oPanel,,,.F.,.F.,.F.,.T.,,,,,.F.,.F.,.F.,.F.,.F.)  //"Numeração da Primeira Coluna a ser criada:"
oSayMoed := TSay():New( 065, 008,{|| STR0019},oPanel,,,.F.,.F.,.F.,.T.,,,,,.F.,.F.,.F.,.F.,.F.)  //"Definir Descrição da moeda em qual idioma:"

oGetNMoe := TGet():New( 020, 008,{|u| If(PCount() > 0,nNumeMoed := u,nNumeMoed)},oPanel,020,,'@e 99',{|| VldNumMoed(nNumeMoed,nMaxMoed) },,,,.F.,,.T.,,.F.,{|| .T. },.F.,.F., ,   ,.F.,,"nNumeMoed",,,,)
oGetMoed := TGet():New( 050, 008,{|u| If(PCount() > 0,nMoedIni := u,nMoedIni)},oPanel,020,,'@ 99',{|| .T. },,,,.F.,,.T.,,.F.,{|| .F.},.F.,.F., ,.F.,.F.,,"nMoedIni",,,,)

oCombMoed:= TComboBox():New( 080,008,{|u| if( Pcount( )>0, cIdioMoed:= u, cIdioMoed) },aIdioMoed,030,010,oPanel,,,,,,.T.)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GetDescMoedºAutor³Joao Gonçalves de Oliveira º Data ³ 11/09/2008    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescrição ³ Monta grid para informação das descrições dos idiomas das moedas    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ GetDescMoed()                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParâmetros³ Expa1 - Vetor com informaçoes de número, moeda inicial e tipo       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTB - Contabilidade Gerencial                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function GetDescMoed()

Local nContItem := 1
Local oPanel 	:= oWizard:oMPanel[oWizard:nPanel]
Local nMoedNew  := nMoedIni

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta grid para informativo das descrições por moeda                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aHeader 	:= {}
Local aCols 	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aHeader,{ STR0030,"cMoeda"  ,"!!" ,02,0,".F.","û","C","  ","  "})
Aadd(aHeader,{ STR0031,"cSimbolo","@!",10,0,"NaoVazio()","û","C","   ","   "})

If cIdioMoed == "Unico"	
	Aadd(aHeader,{ STR0032 ,"cNomePort" ,"@!",10,0,"NaoVazio()","û","C"," ", ""}) //Nome
	Aadd(aHeader,{ STR0034 ,"cPlurPort" ,"@!",10,0,"NaoVazio()","û","C"," "," "}) //Plural
Else	
	Aadd(aHeader,{ STR0040 ,"cNomePort"	,"@!",10,0,"NaoVazio()","û","C"," ", ""}) //Nome Port.
	Aadd(aHeader,{ STR0041 ,"cPlurPort"	,"@!",10,0,"NaoVazio()","û","C"," "," "}) //Plural Port.
	
	Aadd(aHeader,{ STR0044 ,"cNomeEngl"	,"@!",10,0,"NaoVazio()","û","C"," ", ""})  //Nome Engl.
	Aadd(aHeader,{ STR0045 ,"cPlurEngl"	,"@!",10,0,"NaoVazio()","û","C"," "," "})  //Plural Engl.

	Aadd(aHeader,{ STR0050 ,"cNomeSpan"	,"@!",10,0,"NaoVazio()","û","C"," ", ""}) //Nome Span.
	Aadd(aHeader,{ STR0051 ,"cPlurSpan"	,"@!",10,0,"NaoVazio()","û","C"," "," "})  //Plural Span.
EndIf

For nContItem := 1 to nNumeMoed

	If cIdioMoed == "Unico"
		If nMoedNew > 9 
			aAdd(aCols,{StrZero(nMoedNew,2,0),Space(10),Space(10),Space(10),Space(12),Space(25),.F.})		
		Else
			aAdd(aCols,{StrZero(nMoedNew,1,0),Space(10),Space(10),Space(10),Space(12),Space(25),.F.})		
		EndIF
	Else
		If nMoedNew > 9 
			aAdd(aCols,{StrZero(nMoedNew,2,0),Space(10),Space(10),Space(10),Space(12),Space(25),Space(10),Space(10),;
			 Space(12),Space(25),Space(10),Space(10),Space(12),Space(25),.F.})
		Else
			aAdd(aCols,{StrZero(nMoedNew,1,0),Space(10),Space(10),Space(10),Space(12),Space(25),Space(10),Space(10),;
			 Space(12),Space(25),Space(10),Space(10),Space(12),Space(25),.F.})
		EndIF
	EndIf			 				
		
	nMoedNew ++ 

Next	nContItem
DbSelectArea("SX3")
oGetDados := MsNewGetDados():New(005,008,105,255,GD_UPDATE, ,,,,,,,,,oPanel,aHeader,aCols)
oGetDados:SetEditLine(.F.)
SX3->(dbCloseArea())

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CTBWZVLP2 ³ Autor ³ Arnaldo Raymundo Junior ³ Data ³ 10/09/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Validacao dos dados inicias para parametrizacao de moedas    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ATUALIZACAO SIGACTB                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CTBWZVLP2()
Local lRet	:= .T.
Local nMoedaMax := 99 - (nMoedIni - 1) 

If nMoedIni > nMoedaMax
	MSGINFO(STR0056+AllTrim(Str(99-nMoedIni,0))+STR0059,STR0021) //"A parametrização excede o limite de 09 moedas configuráveis no sistema!" # "CTBWizard - Moedas"
	lRet := .F.
ELSEIF nNumeMoed > nMoedaMax
	MSGINFO(STR0056+AllTrim(Str(99-nMoedIni,0))+STR0059,STR0021) //"A parametrização excede o limite de 09 moedas configuráveis no sistema!" # "CTBWizard - Moedas"
	lRet := .F.
ENDIF

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CTBWZVLP3 ³ Autor ³ Arnaldo Raymundo Junior ³ Data ³ 10/09/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Validacao do grid de moedas a serem incluidas                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ATUALIZACAO SIGACTB                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CTBWZVLP3()
Local lRet 		:= .T.
Local aColsGet	:= ACLONE(oGetDados:aCols)
Local aHeaderGet:= ACLONE(oGetDados:aHeader)
Local nX,nY		:= 0

For nX := 1 to Len(aColsGet)
	For nY := 1 to Len(aHeaderGet)
		IF Empty(aColsGet[nX,nY])
			MSGINFO(STR0022,STR0021) //Existem campos obrigatórios não preenchidos # CTBWizard - Moedas
			lRet := .F.
			Exit
		ENDIF	
	Next nY
	If !lRet
		Exit
	ENdIf 
Next nX

IF lRet
	lRet := MSGYESNO(STR0020,STR0021) //Confirma a parametrização das novas moedas # CTBWizard - Moedas
ENDIF

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ProxSX3  ³ Autor ³ --------------------- ³ Data ³ 10/09/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna a próxima ordem disponivel no SX3 para o ALIAS     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ATUALIZACAO SIGAATF                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ProxSX3(cAlias,cCpo)
Local aArea 	:= GetArea()
Local aAreaSX3 	:= SX3->(GetArea())
Local nOrdem	:= 0
Local nPosOrdem	:= 0

Static aOrdem	:= {}

Default cCpo	:= ""

IF !Empty(cCpo)
	SX3->(DbSetOrder(2))
	IF SX3->(MsSeek(cCpo))
		nOrdem := Val(RetAsc(SX3->X3_ORDEM,3,.F.))
	ENDIF
ENDIF

IF Empty(cCpo) .OR. nOrdem == 0

	IF (nPosOrdem := aScan(aOrdem, {|aLinha| aLinha[1] == cAlias})) == 0
	
		SX3->(dbSetOrder(1))
		SX3->(MsSeek(cAlias))
		WHILE SX3->(!EOF()) .AND. SX3->X3_ARQUIVO == cAlias
			nOrdem++
			SX3->(dbSkip())
		END	
		nOrdem++
		AADD(aOrdem,{cAlias,nOrdem})
	
	ELSE
    	aOrdem[nPosOrdem][2]++
    	nOrdem := aOrdem[nPosOrdem][2]
    ENDIF

ENDIF

RestArea(aAreaSX3)
RestArea(aArea)
Return RetAsc(Str(nOrdem),2,.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBWIZREGUºAutor  ³Microsiga           º Data ³  19/05/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Realiza o controle do obejto process da rotina              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CTBWIZREGU
Private oProcess
// Executa o processamento dos arquivos
oProcess:=	MsNewProcess():New( {|lEnd| CTBWIZPROC(oProcess) } )
oProcess:Activate()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CTBX3FIELD³ Autor ³ Joao Gonçalves de Oliveira ³ Data ³ 10/09/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza um determinado campo do SX3                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cField      - campo do Protheus a ser atualizado                ³±±
±±³          ³ cSX3Field   - campo do SX3 a ser atualizado                     ³±±
±±³          ³ cNewValue   - novo valor a ser gravado                          ³±±
±±³          ³ cTestValue  - valor de teste                                    ³±±
±±³          ³ bBlockValue - bloco de teste (opcional - nao implementado)      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaCTB                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function CTBX3Field(cField, cSX3Field, cNewValue, cTestValue, bBlockValue)
Local aAreaSX3 := SX3->(GetArea())
Local lRet := .F.
Local nFieldPos := 0

dbSelectArea("SX3")
SX3->(dbSetOrder(2))

// se o campo nao existe no SX3
If !SX3->(dbSeek(cField))
	RestArea(aAreaSX3)
	Return lRet		
EndIf

// se o campo do SX3 nao existe
nFieldPos := SX3->(FieldPos(cSX3Field))

If nFieldPos == 0
	RestArea(aAreaSX3)
	Return lRet
EndIf

If bBlockValue == Nil

	// teste por valor
	If cTestValue == Nil
	
		// se o teste nao existe altera o valor
		RecLock("SX3", .F.)
	 	SX3->(FieldPut(nFieldPos, cNewValue))
		MsUnlock()

		RestArea(aAreaSX3)
		lRet := .T.
	Else

		// se o teste existe, testa e altera o valor  		
		If AllTrim(Upper(cTestValue)) == AllTrim(Upper(SX3->(FieldGet(nFieldPos))))
			RecLock("SX3", .F.)
		 	SX3->(FieldPut(nFieldPos, cNewValue))
			MsUnlock()
			RestArea(aAreaSX3)							
			lRet := .T.
	  	EndIf
	EndIf
Else

	// teste por bloco - nao implementado
	RestArea(aAreaSX3)
	Return lRet
EndIf

RestArea(aAreaSX3)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GETMAXMOED³ Autor ³ Arnaldo Raymundo Junior ³ Data ³ 10/09/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Retorna a partir de qual moeda poderá ser realizada a criacao³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ATUALIZACAO SIGACTB                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION GETMAXMOED()

LOCAL nMoedIni		:= 0
LOCAL nLoop 		:= 0
LOCAL nMoedaMax 	:= 0
Local lOpen			:= .T.
Local lFWCodFilSM0 	:= FindFunction( "FWCodFil" )
Local nTamFilial	:= IIf( lFWCodFilSM0, FWGETTAMFILIAL, 2 )

DbSelectArea("SX6")
DbSetOrder(1)
DbSeek( Space( nTamFilial ) + "MV_MOEDA", .T. )
WHILE SX6->(!EOF()) .AND. SUBSTR(ALLTRIM(SX6->X6_VAR),1,8) == "MV_MOEDA" .AND. nMoedIni <= 99

	IF VAL(SUBSTR(SX6->X6_VAR,9,2)) > 0
		nMoedIni := VAL(SUBSTR(SX6->X6_VAR,9,2))
		If nMoedIni > nMoedaMax
			nMoedaMax := nMoedIni 	
		EndIf
	ELSE
		EXIT
	ENDIF
		
	SX6->(DbSkip())
END

IF nMoedaMax == 0
	Aviso( STR0001, STR0058 , {STR0047}, 2)		//"Atencao!"###"Nao foi possivel a abertura da tabela de empresas de forma exclusiva!"###"Finalizar"	
ENDIF
	
nMoedaMax++
	
RETURN nMoedaMax



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VldNumMoed  ³ Autor ³ Evaldo Vagner Batista   ³ Data ³09/03/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao do numero de moedas a serem configuradas             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ATUALIZACAO SIGACTB                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function VldNumMoed(nNum, nMoedIni)
Local lRet := .T.                
Local nMoedaMax := 99 - (nMoedIni - 1) 

If nNum > nMoedaMax
	lRet := .F.
	Aviso(STR0001,STR0060 + AllTrim(Str(nMoedaMax,0)) + STR0061,{STR0025},2) //'O número máximo de moedas permitidas no momento é de: ' ### ' moedas. Ajuste o número'
ElseIf Empty(nNum)
	lRet := .F.
	Aviso(STR0001,STR0062,{STR0025},2) //"É necessário informar pelo menos uma moeda!"
EndIf			
			
Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AdmAbreSM0³ Autor ³ Orizio                ³ Data ³ 22/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna um array com as informacoes das filias das empresas ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AdmAbreSM0()
Local aArea			:= SM0->( GetArea() )
Local aAux			:= {}
Local aRetSM0		:= {}
Local lFWLoadSM0	:= FindFunction( "FWLoadSM0" )
Local lFWCodFilSM0 	:= FindFunction( "FWCodFil" )

If lFWLoadSM0
	aRetSM0	:= FWLoadSM0()
Else
	DbSelectArea( "SM0" )
	SM0->( DbGoTop() )
	While SM0->( !Eof() )
		aAux := { 	SM0->M0_CODIGO,;
					IIf( lFWCodFilSM0, FWGETCODFILIAL, SM0->M0_CODFIL ),;
					"",;
					"",;
					"",;
					SM0->M0_NOME,;
					SM0->M0_FILIAL }

		aAdd( aRetSM0, aClone( aAux ) )
		SM0->( DbSkip() )
	End
EndIf

RestArea( aArea )
Return aRetSM0

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³TamSXG ³ Autor ³ Alvaro Camillo Neto  	³ Data ³ 14/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Função que retorna tamanho do campo                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Geral                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtbTamSXG(cGrupo,nTamPad)
Local nSize := 0

DbSelectArea("SXG")
DbSetOrder(1)

IF DbSeek(cGrupo)
	nSize := SXG->XG_SIZE
Else
	nSize := nTamPad
Endif

Return nSize
