#Include "Protheus.ch"
#Include "font.ch"
#Include "colors.ch"
#Include "RSPA150.CH"
#INCLUDE "APWIZARD.CH"

#DEFINE CR  CHR(13)+CHR(10)
Static lRspAltLeg	:= ExistBlock("RSPALTLEG")
Static cAliasTRX	:= ""
Static nCountMsg	:= 0
Static oTmpTRP
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ RSPA150  ³ Autor ³ Cristina Ogura              ³ Data ³  03.02.98  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Agenda os candidatos para os processos                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA150                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS       ³  Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia Car.³29/07/14³TQENN4      ³Incluido o fonte da 11 para a 12 e efetuada ³±±
±±³            ³        ³            ³a limpeza.                                  ³±±
±±³Emerson Camp³21/08/14³TQENN4      ³Não permitir torcar o alias setado por outro³±±
±±³            ³        ³            ³Pois o obj oLbx se perde, por já estar      ³±±
±±³            ³        ³            ³carregado com um Alias                      ³±±
±±³Alberto M.  ³14/11/14³TQZDAP      ³Alteracao de Type para ValType, pois se tra ³±±
±±³            ³        ³            ³tava de uma variavel static(func Rs150Cria) ³±±
±±³Joao Balbino³27/08/15³TTFFQF      ³Ajuste para utilizar a porta indicada no    ³±±
±±³            ³        ³            ³MV_RELSERV na função SendMail               ³±±
±±³Renan Borges³25/11/15³TTQ270      ³Ajuste no cadastro de vagas para não permi- ³±±
±±³            ³        ³            ³tir a exclusão de agendas que possuam testes³±±
±±³            ³        ³            ³realizados.                                 ³±±
±±³Raquel Hager³21/06/16³TVCRXH      ³Criação do PE RS050SEL.                     ³±±
±±³Raquel Hager³22/06/16³TVCRXH      ³Ajuste nos parametros do PE RS050SEL.       ³±±
±±³Raquel Hager³05/07/16³TVNSPC      ³Criação do PE RS150CDT.                     ³±±
±±³M. Silveira ³26/04/17³DRHPONTP-293³Ajuste em Rs150Escol p/ verificar o modo de ³±±
±±³            ³        ³            ³acesso da SQG e trazer o nome corretamente. ³±±
±±³M. Silveira ³26/04/17³DRHPONTP-293³Ajuste em Rs150List p/ impedir a manutencao ³±±
±±³            ³        ³            ³da agenda pela opcao 'Candidato' quando ja  ³±±
±±³            ³        ³            ³existir agenda cadastrada para a vaga.      ³±±
±±³Willian U.  ³05/06/17³DRHPONTP-566³Réplica DRHPONTP-510 - Ajuste em Rs150RecAC ³±±
±±³            ³        ³            ³P/ gravar corretamente o campo QD_FILIAL.   ³±±
±±³Isabel N.   ³07/06/17³DRHPONTP-836³Ajuste em Rs150List p/ nao desposicionar    ³±±
±±³            ³       -DRHPONTP-567 ³a tabela SQS quando vier do RSPA090.		  ³±±
±±³-réplica das issues:-DRHPONTP-580 ³Ajuste em Rs150List p/ carregar as variaveis³±±
±±³            ³       -DRHPONTP-396 ³cProc e cDProc.							  ³±±
±±³            ³       -DRHPONTP-787 ³Ajuste em Rs150List() p/permitir uso do PE  ³±±
±±³            ³        ³            ³RS150CDT ao agendar da pesquisa por vaga.   ³±±
±±|Renan Borges|21/06/17|DRHPONTP-   |Ajuste para que ao aprovar uma solicitação  ³±±
±±|            |        |1028        |de vaga interna, para uma vaga de filial di-³±±
±±|            |        |            |ferente da do funcionário que esta solicitan³±±
±±|            |        |            |do, seja gravado a agenda corretamente.     ³±±
±±|M. Silveira |22/06/17|DRHPONTP-924|Ajustes na funcao Rs150List() p/ considerar ³±±
±±|            |        |            |a filial da vaga na aprovacao.              ³±±
±±|Isabel N.   |07/07/17|DRHPONTP-1001|Ajuste p/gravar info na SQD antes dos memos³±±
±±|            |        |            |p/ter filial da agenda ao chamar MSMM.      ³±±
±±|Oswaldo L   |10/08/17|DRHPONTP-1487|Não deixar registro antigo "sujeira" na SQD³±±
±±|            |        |DRHPONTP-1502|Localizar campo recno pelo indice          ³±±
±±|Oswaldo L.  |31/08/17|DHRPONTP-    |Ajuste permitir gerar csv novas pesqui     ³±±
±±|            |        |1485         |sas. Mas abrir antigos PES também. SOYUZ   ³±±
±±|Oswaldo L.  |31/08/17|DHRPONTP-    |Ajuste oArqTRBTmp referente a ultima libera³±±
±±|            |        |1485         |cao, ao final testamos se difere de Nil    ³±±
±±|            |        |             |Ajuste msg de erro invocada em tela        ³±±
±±|            |        |             |Ajuste nomes das extensões de arquivos     ³±±
±±|Oswaldo L.  |31/10/17|DHRPAG-7555  |Considerar novas tabelas RT0\RT1           ³±±
±±|            |        |             |Ainda manter tratativas de ctree no fonte  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function RSPA150()
Local aCores		:= {}
Local aIndexSQG		:= {}
Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F., {"",""} }) //[1]Acesso; [2]Ofusca; [3]Mensagem
Local aFldRel		:= {"RA_NOME","QG_NOME","QG_EMAIL","QG_RG"}
Local cCpartSQS		:= ""
Local cCpartSQD		:= ""

Private lBlqAcesso	:= aOfusca[2] .And. !Empty( FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRel ) )
Private cBlqCV		:= SuperGetMv("MV_BLQCV",,"1")
Private lNvTab		:= TabNovaDic()
Private aRotina		:= MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina
Private cCadastro	:= OemToAnsi(STR0006) //"Agendar por "
Private cFiltroSQG	:= ""
Private aNoFields	:= {}
Private cFiltraSQG	:= ""
Private nTamaCols	:= 0	//Qtde de linhas do aCols
Private lRs050Sel	:= ExistBlock("RS050SEL")
Private cFilKey    	:= ""

If FWModeAccess("SQG",1) + FWModeAccess("SQG",2) + FWModeAccess("SQG",3) == "CCC"
	cFilKey := xFilial("SQD")
Else
	cFilKey := xFilial("SQD", SQG->QG_FILIAL)
EndIf

//--------------- Verificação de Compartilhamento das tabelas 
// SQS - Vagas
// SQD - Agenda

//Modo de compartilhamento da tabela SQS
cCpartSQS := FWModeAccess("SQS", 1)
cCpartSQS += FWModeAccess("SQS", 2)
cCpartSQS += FWModeAccess("SQS", 3)

//Modo de compartilhamento da tabela SQD
cCpartSQD := FWModeAccess("SQD", 1)
cCpartSQD += FWModeAccess("SQD", 2)
cCpartSQD += FWModeAccess("SQD", 3)

// Verifica se as tabelas estao com o mesmo modo de compartilhamento
If (cCpartSQD != cCpartSQS)
	Help( , , 'HELP', , OemToAnsi(STR0119), 1, 0 )  //"Verifique o compartilhamento das tabelas SQS e SQD. O compartilhamento dessas tabelas devem ser idênticos."
	Return
EndIf
//---------------

IF SQG->(Columnpos("QG_ACTRSP")) > 0
	cFiltroSQG := "QG_ACTRSP <> '1' " //1- sem aceite e 2-com aceite
ENDIF

IF cBlqCV == '2'
	if !empty(cFiltroSQG)
		cFiltroSQG += " .and. QG_ACEITE == '2' " //1=Sem aceite; 2=Aceite vigente gravado
	else
		cFiltroSQG += " QG_ACEITE == '2' " //1=Sem aceite; 2=Aceite vigente gravado
	ENDIF
ENDIF


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³DOCRSP:                                                    	 ³
//³ 	As cores definidas na mBrowse depende do campo QG_SITUAC.³
//³   Foram definidas da seguinte maneira:                  	 ³
//³   001 - VERDE         005 - LARANJA                     	 ³
//³   002 - VERMELHO      006 - MARROM                      	 ³
//³   003 - AMARELO       007 - PINK                        	 ³
//³   004 - CINZA         e acima de 007 - PRETO            	 ³
//³   					  FUN - AZUL				          	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCores  := { 	{ "SQG->QG_SITUAC=='001'.Or. Empty(SQG->QG_SITUAC)",'BR_VERDE' },;
					{ "SQG->QG_SITUAC=='002'",'DISABLE' 	},;
					{ "SQG->QG_SITUAC=='003'",'BR_AMARELO' 	},;
					{ "SQG->QG_SITUAC=='004'",'BR_CINZA' 	},;
					{ "SQG->QG_SITUAC=='005'",'BR_LARANJA' 	},;
					{ "SQG->QG_SITUAC=='006'",'BR_MARROM' 	},;
					{ "SQG->QG_SITUAC=='007'",'BR_PINK' 	},;
					{ "SQG->QG_SITUAC=='FUN'",'BR_AZUL' 	},;
					{ "Val(SQG->QG_SITUAC) ==008",'BR_PRETO'} }

If ( lRspAltLeg )
	aCores := ExecBlock("RSPALTLEG" , .F. , .F. , {aCores})
EndIf

//Tratamento de acesso a Dados Sensíveis
If lBlqAcesso
	//"Dados Protegidos- Acesso Restrito: Este usuário não possui permissão de acesso aos dados dessa rotina. Saiba mais em {link documentação centralizadora}"
	Help(" ",1,aOfusca[3,1],,aOfusca[3,2],1,0)
	Return
EndIf

IF SQG->(Columnpos("QG_ACTRSP")) > 0
	cFiltraSQG := "SQG->QG_ACTRSP <> '1' " //1- sem aceite e 2-com aceite
ENDIF

IF cBlqCV == '2'
	if !empty(cFiltraSQG)
		cFiltraSQG += " .and. SQG->QG_ACEITE == '2' " //1=Sem aceite; 2=Aceite vigente gravado
	else
		cFiltraSQG += " SQG->QG_ACEITE == '2' " //1=Sem aceite; 2=Aceite vigente gravado
	ENDIF
ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada para criar filtro para a tabela SQS                                ³
//³Variaveis que podem ser Usadas                                                      ³
//³cFiltraSQS = Filtro da tabela  									                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("RSP150FT")
   ExecBlock("RSP150FT",.F.,.F.)
Endif

FilBrowse("SQG",@aIndexSQG,@cFiltraSQG)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE 						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SQG")
dbSetOrder(1)

mBrowse( 6, 1, 22, 75, "SQG" ,,,,,, aCores)

dbSelectArea("SQG")
dbSetOrder(1)

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Deleta o filtro utilizando a funcao FilBrowse                     	 ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
EndFilBrw( "SQG" , aIndexSQG )

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Rs150Cons³ Autor ³ Cristina Ogura        ³ Data ³ 03.02.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Agenda por Pesquisa								          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias := Alias em uso                                     ³±±
±±³          ³ nReg   := Registro posicionado                             ³±±
±±³          ³ nOpcx  := Opcao selecionada                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Rs150Cons(cAlias,nReg,nOpcx)
Rs150List(1,nOpcx)
Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Rs150Data³ Autor ³ Cristina Ogura        ³ Data ³ 03.02.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Agenda por Data									          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias := Alias em uso                                     ³±±
±±³          ³ nReg   := Registro posicionado                             ³±±
±±³          ³ nOpcx  := Opcao selecionada                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Rs150Data(cAlias,nReg,nOpcx)
Rs150List(2,nOpcx)
Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Rs150Cand³ Autor ³ Cristina Ogura        ³ Data ³ 03.02.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Agenda por Candidato								          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias := Alias em uso                                     ³±±
±±³          ³ nReg   := Registro posicionado                             ³±±
±±³          ³ nOpcx  := Opcao selecionada                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Rs150Cand(cAlias,nReg,nOpcx)

nTamaCols:= 0

Rs150List(3,nOpcx)
Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Rs150Vaga³ Autor ³ Cristina Ogura        ³ Data ³ 03.02.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Agenda por Vaga									          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias := Alias em uso                                     ³±±
±±³          ³ nReg   := Registro posicionado                             ³±±
±±³          ³ nOpcx  := Opcao selecionada                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Rs150Vaga(cAlias,nReg,nOpcx)
Rs150List(4,nOpcx)
Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Rs150Func³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 03.02.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Agenda por Funcionario							          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias := Alias em uso                                     ³±±
±±³          ³ nReg   := Registro posicionado                             ³±±
±±³          ³ nOpcx  := Opcao selecionada                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Rs150Func(cAlias,nReg,nOpcx)
Rs150List(5,nOpcx)
Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Rs150Cole³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 30.05.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Agenda Coletiva									          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias := Alias em uso                                     ³±±
±±³          ³ nReg   := Registro posicionado                             ³±±
±±³          ³ nOpcx  := Opcao selecionada                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Rs150Cole(cAlias,nReg,nOpcx)

Local aSays 	:= {}
Local aButtons	:= {}
Local nOpca		:= 0

AADD(aSays,OemToAnsi(STR0049) )  //"Este programa permite a Agenda de Candidatos de forma coletiva."
AADD(aSays,OemToAnsi(STR0050) )  //'Utilize o filtro atraves do botão "Filtrar" abaixo.'

AADD(aButtons, {17,.T.,{|| cFiltroSQG := BuildExpr("SQG",,cFiltroSQG)}} ) //Filtro
AADD(aButtons, { 1,.T.,{|o| nOpca := 1,FechaBatch()}} )
AADD(aButtons, { 2,.T.,{|o| nOpca := 0,FechaBatch()}} )

FormBatch( cCadastro, aSays, aButtons )

If nOpca == 1
	Rs150List(6,nOpcx)
EndIf

Return Nil

/*ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Rs150Wiza³ Autor ³ Eduardo Ju            ³ Data ³ 17.11.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Agenda Coletiva									          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias := Alias em uso                                     ³±±
±±³          ³ nReg   := Registro posicionado                             ³±±
±±³          ³ nOpcx  := Opcao selecionada                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Rs150Wiza(cAlias,nReg,nOpcx)

Local aTexto    := {}
Local oWizard
Local aListCab	:= {}
Local oSelCand, oEmail, oSelAll
Local lEmail 	:= .F.
Local lSelCand 	:= .F.
Local lSelAll	:= .F.
Local lSendEmail:= .F.
Local nOpcSub	:= 2.00
Local oRadio

//Variaveis da FillGetdados
Local bSeekWhile:= {|| }
Local nSqdOrd	:= 1

Local cFilSQG := ''

Private oDlg,oLbx,oPanel
Private cFilSqs
Private aHeader		:= {}
Private aCols  		:= {}
Private cAuxVaga	:= ""
Private aInfo		:= {}
Private aCampos		:= {}
Private oNo			:= LoadBitmap( GetResources(), "LBNO" )
Private oOk			:= LoadBitmap( GetResources(), "LBTIK" )
Private lEnviaMail 	:= .T.
Private cEstou		:= ""
Private aSvGetd		:= {}
Private cArqTemp	:= ""

Private cFiltroAux	:= ""


IF SQG->(Columnpos("QG_ACTRSP")) > 0
	cFilSQG := "QG_ACTRSP <> '1' " //1- sem aceite e 2-com aceite
ENDIF

IF cBlqCV == '2'
	if !empty(cFilSQG)
		cFilSQG += " .and. QG_ACEITE == '2' " //1=Sem aceite; 2=Aceite vigente gravado
	else
		cFilSQG += " QG_ACEITE == '2' " //1=Sem aceite; 2=Aceite vigente gravado
	ENDIF
ENDIF


aadd(aTexto,{})
aTexto[1] := STR0059 + CRLF		//"Esta rotina permite a geração automática da agenda do(s) Processo(s) Seletivo(s) para os candidatos."
aTexto[1] += CRLF + STR0060 	//"O próximo passo será a definição do Processo Seletivo."
aadd(aTexto,"")
aTexto[2] := CRLF + STR0070 + CRLF	//"O(s) Processo(s) Seletivo(s) serão gravados para os candidatos selecionados."
aTexto[2] += CRLF + STR0090			//"Selecione uma das opções abaixo para tratamento de informações pré-existentes:
aTexto[2] += CRLF + CRLF + CRLF + CRLF + CRLF + CRLF + STR0072			//"Clique em Finalizar para Gravação do Agendamento Coletivo."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem da Interface do Wizard                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE WIZARD oWizard ;
	TITLE STR0061 /*"Assistente para Agendamento Coletivo"*/;
	HEADER STR0027 /*"Atenção"*/;
	MESSAGE STR0062/*"Siga atentamente os passos para a preparação do Agendamento Coletivo dos Candidatos para o Processo Seletivo"*/;
	TEXT aTexto[1] ;
	NEXT    {||.T.} ;
	FINISH  {||.T.}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ 1 - Painel de Definicao dos Processos Seletivos ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CREATE PANEL oWizard  ;
		HEADER STR0063 /*"Processo Seletivo"*/;
		MESSAGE STR0064/*"Selecione o(s) Processo(s) Seletivo(s)"*/	;
		BACK   {|| .T.} ;
		NEXT   {|| aCols,If(Rs150TudOk(),(DbSelectArea("SQG"),.T.),.F.)} ;
		FINISH {|| .T.} ;
		PANEL

		oPanel:=oWizard:GetPanel(2)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Array com os campos que nao serao mostrados na getdados ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aNoFields:= {"QD_CURRIC","QD_NOME"}
		inclui 	:= .T.
		bSeekWhile	:= {||SQD->QD_FILIAL }
		cChave	:= Replicate("!", FWGETTAMFILIAL)

		//==> Cria aHeader e aCols para WalkThru
		FillGetDados(3						,; //1-nOpcx - número correspondente à operação a ser executada, exemplo: 3 - inclusão, 4 alteração e etc;
					 "SQD"					,; //2-cAlias - area a ser utilizada;
					 nSqdOrd				,; //3-nOrder - ordem correspondente a chave de indice para preencher o  acols;
					 cChave					,; //4-cSeekKey - chave utilizada no posicionamento da area para preencher o acols;
					 bSeekWhile				,; //5-bSeekWhile - bloco contendo a expressão a ser comparada com cSeekKey na condição  do While.
					 NIL					,; //6-uSeekFor - pode ser utilizados de duas maneiras:1- bloco-de-código, condição a ser utilizado para executar o Loop no While;2º - array bi-dimensional contendo N.. condições, em que o 1º elemento é o bloco condicional, o 2º é bloco a ser executado se verdadeiro e o 3º é bloco a ser executado se falso, exemplo {{bCondicao1, bTrue1, bFalse1}, {bCondicao2, bTrue2, bFalse2}.. bCondicaoN, bTrueN, bFalseN};
					 aNoFields				,; //7-aNoFields - array contendo os campos que não estarão no aHeader;
					 NIL					,; //8-aYesFields - array contendo somente os campos que estarão no aHeader;
					 NIL					,; //9-lOnlyYes - se verdadeiro, exibe apenas os campos de usuário;
					 NIL					,; //10-cQuery - query a ser executada para preencher o acols(Obs. Nao pode haver MEMO);
					 NIL					,; //11-bMontCols - bloco contendo função especifica para preencher o aCols; Exmplo:{|| MontaAcols(cAlias)}
					 NIL					,; //12-lEmpty – Caso True ( default é false ), inicializa o aCols com somente uma linha em branco ( como exemplo na inclusão).
					 NIL					,; //13-aHeaderAux, eh Caso necessite tratar o aheader e acols como variáveis locais ( várias getdados por exemplo; uso da MSNewgetdados )
					 NIL					)  //14-aColsAux eh Caso necessite tratar o aheader e acols como variáveis locais ( várias getdados por exemplo; uso da MSNewgetdados )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Controle da Getdados  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oGet:= MSGetDados():New(10,10,130,280,nOpcx,"Rs150linOk","Rs150TudOk",,.T.,,1,,300,,,,,oPanel)
		oGet:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Agendamento Coletivo  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nQual := 6

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ 2 - Painel Filtro dos Candidatos ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


	CREATE PANEL oWizard  ;
		HEADER STR0065 /*"Filtro"*/;
		MESSAGE STR0066 /*"Filtre os candidatos para o(s) Processo(s) Seletivo(s)"*/	;
		BACK   {|| .T.} ;
		NEXT   {|| (cAliasTRX)->(__dbZap()),Processa({||aListCab:= Rs150Next()}),.T.} ;
		FINISH {|| .T.} ;
		PANEL

		oPanel:=oWizard:GetPanel(3)

		BuildExpr("SQG",,@cFilSQG,.T., , oPanel)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ 3 - Painel de Selecao dos Candidatos ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CREATE PANEL oWizard  ;
		HEADER STR0067 /*"Candidatos"*/;
		MESSAGE STR0068 /*"Selecione os candidatos para o(s) Processo(s) Seletivo(s)"*/	;
		BACK   {|| .T.} ;
		NEXT   {|| If(Rs150LstOk(),.T.,.F.)} ;
		FINISH {|| .T.} ;
		PANEL

		oPanel:=oWizard:GetPanel(4)

		cAuxVaga := IIF(cAuxVaga==Nil,Space(06),cAuxVaga)

		aListCab:= Rs150First()

		oLbx :=  TWBrowse():New(10,10,130,280,,aListCab,,oPanel,,,,,,,,,,,,.T.,,.T.,,.F.,,)
        oLbx:bLine:= {|| Rs150Line()}

	   	oLbx:Align:= CONTROL_ALIGN_ALLCLIENT
		oLbx:bLdblclick	:= {|| Rs150Clk()}

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Definicao do Mini-Painel para o Check-Box contido no Painel  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		@00,00 MSPANEL oTmpPanel SIZE 130,10 OF oPanel
		oTmpPanel:Align := CONTROL_ALIGN_BOTTOM

	 	@  	02,001 CHECKBOX oSelAll VAR lSelAll	PROMPT OemtoAnsi(STR0088) SIZE 70,08 OF oTmpPanel PIXEL;	//"Marca/Desmarca Todos"
			ON CLICK ( If(lSelAll,Rs150Select(.T.),Rs150Select(.F.)) )

	 	@  	02,112 CHECKBOX oSelCand VAR lSelCand	PROMPT OemtoAnsi(STR0046) SIZE 70,08 OF oTmpPanel PIXEL;	//"Inverte seleção"
			ON CLICK ( Rs150Invert() )

		@   02,200 CHECKBOX oEmail VAR lEmail 	PROMPT OemtoAnsi(STR0057) SIZE 70,08	OF oTmpPanel PIXEL;		//" Enviar E-mail "
		ON CLICK ( If(lEmail,lSendEmail := .T., lSendEmail := .F.) )


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ 4 - Resumo da Agenda             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CREATE PANEL oWizard  ;
		HEADER STR0027 /*"Atenção"*/;
		MESSAGE STR0073 /*"Gravação do Agendamento Coletivo"*/ ;
		BACK   {|| .T.} ;
		NEXT   {|| .T. } ;
		FINISH {|| Processa({||Rs150RecAC(lSendEmail,nOpcSub)},OemToAnsi(STR0041)) /*"Aguarde... Gravando dados"*/,.T.} ;
		PANEL

		oPanel:=oWizard:GetPanel(5)
		@ 010,010 GET aTexto[2] MEMO SIZE 270, 116 READONLY PIXEL OF oPanel

		@ 050,020	RADIO oRadio VAR nOpcSub ITEMS 	OemToAnsi(STR0091)	,;			//"Substituir a agenda (todas as vagas/processos)."
													OemToAnsi(STR0092)	 ;			//"Substituir a agenda para  as vagas."
					SIZE 200,040 OF oPanel PIXEL


ACTIVATE WIZARD oWizard CENTERED

dbSelectArea(cAliasTRX)
dbCloseArea()

If oTmpTRP <> Nil
	oTmpTRP:Delete()
	Freeobj(oTmpTRP)
EndIf

Return .T.


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Rs150List³ Autor ³ Cristina Ogura        ³ Data ³ 03.02.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta os aheaders, acols e listbox das agendas em branco   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nAux   := Opcao de selecao do arotina                      ³±±
±±³          ³ cAlias := Alias do mbrowse                                 ³±±
±±³          ³ nReg   := Registro do mbrowse                              ³±±
±±³          ³ nOpcx  := Opcao selecionada                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Rs150List(nAux,nOpcx,cAuxVaga,cFilSqs)
Local oDlg, oGroup
Local cSay		:= ""
Local cDescric	:= ""
Local cChave	:= ""
Local nOpca		:= 0
Local cVaga 	:= Space(TamSx3("QS_VAGA")[1])
Local cProc		:= Space(TamSx3("QE_PROCESS")[1])
Local cDvaga 	:= ""
Local cDProc 	:= ""
Local cVaga3    := ""
Local nX		:= 0
Local cCpos		:= GetNewPar("MV_RSPAGEN","")	//Criar Parametro
Local aCpos		:= &("{"+CCPOS+"}")
Local aListCab	:= {}
Local lRS150CDT := ExistBlock("RS150CDT")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis para Dimensionar Tela		                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aAdv1Size		:= {}
Local aInfo1AdvSize	:= {}
Local aObj1Size		:= {}
Local aObj1Coords 	:= {}
Local aAdv2Size		:= {}
Local aInfo2AdvSize	:= {}
Local aObj2Size		:= {}
Local aObj2Coords 	:= {}
Local aAdv3Size		:= {}
Local aInfo3AdvSize	:= {}
Local aObj3Size		:= {}
Local aObj3Coords 	:= {}
Local aAdv4Size		:= {}
Local aInfo4AdvSize	:= {}
Local aObj4Size		:= {}
Local aObj4Coords 	:= {}
Local aAdv5Size		:= {}
Local aInfo5AdvSize	:= {}
Local aObj5Size		:= {}
Local aObj5Coords 	:= {}
Local nAGEMAIL		:= GetNewPar("MV_AGEMAIL", 0)
//Variaveis da FillGetdados
Local bSeekWhile	:= {|| }
Local nSqdOrd		:= 3
Local aHeaderAux	:={}
Local aColsAux		:={}

Local lNewAuxVaga	:= .F.

Private nPosRec		:= 0
Private oGet, oLbx, oSay
Private aSvGetd		:= {}
Private nQual		:= nAux

Private cRsVar		:= ""
Private cEstou		:= ""
Private cRsAuxVar	:= ""
Private aFuncs		:= {}
Private aSvGetCand	:= {}
Private aListCand	:= {}
Private aInfo 		:= {}
Private aCampos		:= {}
Private aButtons	:= {}
Private nInclu		:= 0
Private aOldCols    := {}
Private oNo			:= LoadBitmap( GetResources(), "LBNO" )
Private oOk			:= LoadBitmap( GetResources(), "LBTIK" )
Private lEnviaMail 	:= .T.

DEFAULT cFilSqs := Nil

//Rotina proveniente do TCFA040 nao esta com aRotina carregado
If IsInCallStack("TCFA040")
	Private aRotina := MenuDef()
	oReturn	:=	Nil
EndIf

If Type("cFilKey") == "U"
	Private cFilKey := ""
	If FWModeAccess("SQG",1) + FWModeAccess("SQG",2) + FWModeAccess("SQG",3) == "CCC"
		cFilKey := xFilial("SQD")
	Else
		cFilKey := xFilial("SQD", SQG->QG_FILIAL)
	EndIf
EndIf

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize		:= MsAdvSize()
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
aAdd( aObjCoords , { 000 , 010 , .T. , .F. } )
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

aAdv1Size    := aClone(aObjSize[2])
aInfo1AdvSize    := { aAdv1Size[2] , aAdv1Size[1] , aAdv1Size[4] , aAdv1Size[3] , 5 , 5 }
aAdd( aObj1Coords , { 050 , 000 , .T. , .T., .T. } )
aAdd( aObj1Coords , { 002 , 000 , .F. , .T. } )
aAdd( aObj1Coords , { 050 , 000 , .T. , .T. } )
aObj1Size := MsObjSize( aInfo1AdvSize , aObj1Coords, , .T. )

aAdv2Size    := aClone(aObj1Size[3])
aInfo2AdvSize    := { aAdv2Size[2] , aAdv2Size[1] , aAdv2Size[4] , aAdv2Size[3] , 5 , 5 }
aAdd( aObj2Coords , { 000 , 010 , .T. , .F. } )
aAdd( aObj2Coords , { 000 , 000 , .T. , .T. } )
aObj2Size := MsObjSize( aInfo2AdvSize , aObj2Coords )

aAdv3Size    := aClone(aObjSize[2])
aInfo3AdvSize    := { aAdv3Size[2] , aAdv3Size[1] , aAdv3Size[4] , aAdv3Size[3] , 5 , 5 }
aAdd( aObj3Coords , { 000 , 050 , .T. , .T. } )
aAdd( aObj3Coords , { 000 , 002 , .T. , .F. } )
aAdd( aObj3Coords , { 000 , 050 , .T. , .T. } )
aObj3Size := MsObjSize( aInfo3AdvSize , aObj3Coords )

aAdv4Size    := aClone(aObj3Size[1])
aInfo4AdvSize    := { aAdv4Size[2] , aAdv4Size[1] , aAdv4Size[4] , aAdv4Size[3] , 5 , 5 }
aAdd( aObj4Coords , { 000 , 005 , .T. , .F. } )
aAdd( aObj4Coords , { 000 , 000 , .T. , .T., .T. } )
aObj4Size := MsObjSize( aInfo4AdvSize , aObj4Coords )

aAdv5Size		:= MsAdvSize( , .T., 100)
aInfo5AdvSize	:= { aAdv5Size[1] , aAdv5Size[2] , aAdv5Size[3] , aAdv5Size[4] , 5 , 5 }
aAdd( aObj5Coords , { 000 , 020 , .T. , .F. } )
aAdd( aObj5Coords , { 000 , 010 , .T. , .F. } )
aAdd( aObj5Coords , { 000 , 010 , .T. , .F. } )
aAdd( aObj5Coords , { 000 , 000 , .T. , .T. } )
aObj5Size		:= MsObjSize( aInfo5AdvSize , aObj5Coords )

// Obter campos definidos pelo usuario para mostrar na Agenda.
dbSelectArea("SX3")
dbSetOrder(2)

For nx := 1 To Len(aCpos)
	If Left(aCpos[nx],3) == "QG_" .And. dbSeek(aCpos[nx])
		Aadd( aInfo, {	aCpos[nx],;							//Campo
			 			AllTrim(Upper(X3Titulo())),;		//Titulo
			 			X3_TIPO,;							//Tipo
			 			X3_TAMANHO,;						//Tamanho
			 			X3_DECIMAL} ) 						//Decimal
	EndIf
Next nx

//Inclui Check-box
If nQual == 6 .Or. nQual == 7	//Coletivo e Atraves da Pesquisa
	Aadd( aInfo, { "TRX_CHECK","","L",1,0 } )
EndIf

cAuxVaga := IIF(cAuxVaga==Nil,Space(06),cAuxVaga)

inclui:= .t.

Rs150Cria(nQual)

// Array com os campos que nao serao mostrados na getdados
If nQual == 3
	aNoFields:= {"QD_CURRIC","QD_NOME","QD_VAGA","QD_DVAGA"}
Else
	aNoFields:= {"QD_CURRIC","QD_NOME"}
EndIf

//Monta o aCols vazio
If nQual == 3 			// Por candidato

	aListCand	:= {}
	cVaga3		:= ""

	If FWModeAccess("SQG",1) + FWModeAccess("SQG",2) + FWModeAccess("SQG",3) == "CCC"
		cFilKey := xFilial("SQD")
	Else
		cFilKey := xFilial("SQD", SQG->QG_FILIAL)
	EndIf

	dbSelectArea("SQD") //Agenda do Candidato
	dbSetOrder(2)
	dbSeek(cFilKey +SQG->QG_CURRIC)
	While !Eof() .And. (cFilKey == SQD->QD_FILIAL  )  .and.  ( SQD->QD_CURRIC == SQG->QG_CURRIC )

		If cVaga3 != SQD->QD_VAGA

       		cVaga3 := SQD->QD_VAGA

       		If Ascan(aListCand,{|x| x[1] == cVaga3}) == 0

				dbSelectArea("SQS") //Vagas
				dbSetOrder(1)
				dbSeek(xFilial("SQS")+SQD->QD_VAGA)

				Aadd(aListCand,{SQD->QD_VAGA, Left(SQS->QS_DESCRIC,30), STR( SQS->QS_NRVAGA - SQS->QS_VAGAFEC, 3) } )

			EndIf
	    EndIf

	    dbSelectArea("SQD")
		dbSkip()
	EndDo
	//Rotina proveniente do TCFA040 nao esta com aRotina carregado
	If IsInCallStack("TCFA040") .AND. !Empty(cAuxVaga)
		lNewAuxVaga	 := .T.
		If Len(aListCand) == 0
		   	dbSelectArea("SQS") //Vagas
			dbSetOrder(1)
			cFilSqs := If(cFilSqs == Nil, xFilial("SQS"), cFilSqs)
			dbSeek(cFilSqs+cAuxVaga)
			Aadd(aListCand,{SQS->QS_VAGA, Left(SQS->QS_DESCRIC,30), STR( SQS->QS_NRVAGA - SQS->QS_VAGAFEC, 3) } )

		Else
	   		If Ascan(aListCand,{|x| x[1] == cAuxVaga}) == 0

			   	dbSelectArea("SQS") //Vagas
				dbSetOrder(1)
				dbSeek(xFilial("SQS")+cAuxVaga)

				Aadd(aListCand,{SQS->QS_VAGA, Left(SQS->QS_DESCRIC,30), STR( SQS->QS_NRVAGA - SQS->QS_VAGAFEC, 3) } )

				//Rs150Novo(xFilial("SQS"), { Space(6), Space(30), 0 }, @cSay, cAuxVaga)
			EndIf
		EndIf
	EndIf

	If Len(aListCand) == 0
		Aadd(aListCand, { Space(6), Space(30), 0 })
	EndIf

	inclui	:= .F.
	bSeekWhile	:= {|| SQD->QD_FILIAL+SQD->QD_VAGA+SQD->QD_CURRIC }

	For nX := 1 To Len(aListCand)

		cChave	:= cFilKey + aListCand[nX,1] + SQG->QG_CURRIC
		//Ins - Fillgetdados
		aHeaderAux	:={}
		aColsAux	:={}

		//==> Cria aHeader e aCols para WalkThru
		FillGetDados(4						,; //1-nOpcx - número correspondente à operação a ser executada, exemplo: 3 - inclusão, 4 alteração e etc;
					 "SQD"					,; //2-cAlias - area a ser utilizada;
					 nSqdOrd				,; //3-nOrder - ordem correspondente a chave de indice para preencher o  acols;
					 cChave					,; //4-cSeekKey - chave utilizada no posicionamento da area para preencher o acols;
					 bSeekWhile				,; //5-bSeekWhile - bloco contendo a expressão a ser comparada com cSeekKey na condição  do While.
					 NIL					,; //6-uSeekFor - pode ser utilizados de duas maneiras:1- bloco-de-código, condição a ser utilizado para executar o Loop no While;2º - array bi-dimensional contendo N.. condições, em que o 1º elemento é o bloco condicional, o 2º é bloco a ser executado se verdadeiro e o 3º é bloco a ser executado se falso, exemplo {{bCondicao1, bTrue1, bFalse1}, {bCondicao2, bTrue2, bFalse2}.. bCondicaoN, bTrueN, bFalseN};
					 aNoFields				,; //7-aNoFields - array contendo os campos que não estarão no aHeader;
					 NIL					,; //8-aYesFields - array contendo somente os campos que estarão no aHeader;
					 NIL					,; //9-lOnlyYes - se verdadeiro, exibe apenas os campos de usuário;
					 NIL					,; //10-cQuery - query a ser executada para preencher o acols(Obs. Nao pode haver MEMO);
					 NIL					,; //11-bMontCols - bloco contendo função especifica para preencher o aCols; Exmplo:{|| MontaAcols(cAlias)}
					 NIL					,; //12-lEmpty – Caso True ( default é false ), inicializa o aCols com somente uma linha em branco ( como exemplo na inclusão).
					 aHeaderAux				,; //13-aHeaderAux, eh Caso necessite tratar o aheader e acols como variáveis locais ( várias getdados por exemplo; uso da MSNewgetdados )
					 aColsAux				)  //14-aColsAux eh Caso necessite tratar o aheader e acols como variáveis locais ( várias getdados por exemplo; uso da MSNewgetdados )
		Aadd(aOldCols, aclone(aColsAux) )
		//ainda não precisamos de aOldCols pois aColsAux é limpo adiante
		If aListCand[nx,1] == SQS->QS_VAGA .AND. !Empty(SQS->QS_PROCESS) .AND. Empty(aColsAux[1,1])
	   		Aadd(aSvGetCand,{cFilKey +aListCand[nx,1],Rs150AuxSQE(cAuxVaga,SQG->QG_CURRIC,SQS->QS_PROCESS, @aHeaderAux)})
		Else
			Aadd(aSvGetCand,{cFilKey +aListCand[nx,1],aColsAux})
		EndIf

	Next

	cChave	:=cFilKey + aListCand[1,1] + SQG->QG_CURRIC

	dbSelectArea(cAliasTRX)
	RecLock(cAliasTRX,.T.)
		TRX_NOME	:= SQG->QG_NOME
		TRX_CURRIC	:= SQG->QG_CURRIC
		TRX_FILIAL	:= cFilKey
	MsUnlock()

Else
	inclui 	:= .t.
	bSeekWhile	:= {||SQD->QD_FILIAL}
	cChave	:= Replicate("!", FWGETTAMFILIAL)
	nSqdOrd	:= 1
EndIf

aHeaderAux	:={}
aColsAux	:={}

//==> Cria aHeader e aCols para WalkThru
FillGetDados(4						,; //1-nOpcx - número correspondente à operação a ser executada, exemplo: 3 - inclusão, 4 alteração e etc;
			 "SQD"					,; //2-cAlias - area a ser utilizada;
			 nSqdOrd				,; //3-nOrder - ordem correspondente a chave de indice para preencher o  acols;
			 cChave					,; //4-cSeekKey - chave utilizada no posicionamento da area para preencher o acols;
			 bSeekWhile				,; //5-bSeekWhile - bloco contendo a expressão a ser comparada com cSeekKey na condição  do While.
			 NIL					,; //6-uSeekFor - pode ser utilizados de duas maneiras:1- bloco-de-código, condição a ser utilizado para executar o Loop no While;2º - array bi-dimensional contendo N.. condições, em que o 1º elemento é o bloco condicional, o 2º é bloco a ser executado se verdadeiro e o 3º é bloco a ser executado se falso, exemplo {{bCondicao1, bTrue1, bFalse1}, {bCondicao2, bTrue2, bFalse2}.. bCondicaoN, bTrueN, bFalseN};
			 aNoFields				,; //7-aNoFields - array contendo os campos que não estarão no aHeader;
			 NIL					,; //8-aYesFields - array contendo somente os campos que estarão no aHeader;
			 NIL					,; //9-lOnlyYes - se verdadeiro, exibe apenas os campos de usuário;
			 NIL					,; //10-cQuery - query a ser executada para preencher o acols(Obs. Nao pode haver MEMO);
			 NIL					,; //11-bMontCols - bloco contendo função especifica para preencher o aCols; Exmplo:{|| MontaAcols(cAlias)}
			 NIL					,; //12-lEmpty – Caso True ( default é false ), inicializa o aCols com somente uma linha em branco ( como exemplo na inclusão).
			 NIL					,; //13-aHeaderAux, eh Caso necessite tratar o aheader e acols como variáveis locais ( várias getdados por exemplo; uso da MSNewgetdados )
			 NIL					)  //14-aColsAux eh Caso necessite tratar o aheader e acols como variáveis locais ( várias getdados por exemplo; uso da MSNewgetdados )

inclui:= .f.

dbSelectArea("SQS")
If FunName() != "RSPA090" //quando vier da rotina Efetuar Pesquisa já está posicionado na vaga alvo.
	dbGoTop()
EndIf

dbSelectArea("SQE")
dbGoTop()

If nQual == 3  .Or. nQual == 5 //Candidato / Funcionario
	If Len(aCols)==1 .And. Empty(aCols[1][1]) .and. Empty(cAuxVaga) 

		If nOpcx == 7	// Exclusao
			dbSelectArea("SQD") //Agenda do Candidato
			dbSetOrder(2)
			dbSeek(cFilKey +SQG->QG_CURRIC)
			
			Rs150Dele() 
			
			dbSelectArea(cAliasTRX)
			dbCloseArea()

			If oTmpTRP <> Nil
				oTmpTRP:Delete()
				Freeobj(oTmpTRP)
			EndIf

			Return .T.
		EndIf

		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Monta as Dimensoes dos Objetos         					   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAdvSize5		:= MsAdvSize( , .T., 100)
		aInfoAdvSize5	:= { aAdvSize5[1] , aAdvSize5[2] , aAdvSize5[3] , aAdvSize5[4] , 5 , 5 }
		aAdd( aObjCoords5 , { 000 , 020 , .T. , .F. } )
		aAdd( aObjCoords5 , { 000 , 010 , .T. , .F. } )
		aAdd( aObjCoords5 , { 000 , 010 , .T. , .F. } )
		aAdd( aObjCoords5 , { 000 , 000 , .T. , .T. } )
		aObjSize5	:= MsObjSize( aInfoAdvSize5 , aObjCoords5 ) */

		SETAPILHA()
		DEFINE FONT oFont NAME "Arial Negrito"  SIZE 10, -11
		DEFINE MSDIALOG oDlg  FROM aAdv5Size[7],0 TO aAdv5Size[6],aAdv5Size[5] TITLE OemToAnsi(STR0011) PIXEL//"Pesquisa dos candidatos por: "

			@ aObj5Size[2,1],aObj5Size[2,2]	SAY OemtoAnsi(STR0036) PIXEL		//"Vaga: "
			If IsInCallStack("TCFA040")
				cDescri	:= FDesc("SQS", cAuxVaga, "QS_DESCRIC",,cFilSqs)
				Rs150DVag(cAuxVaga,@cProc,@cDVaga,cFilSqs)
				Rs150DPro(cProc,@cDProc)
				@ aObj5Size[2,1],aObj5Size[2,2]+40 MSGET cVaga	 VAR cAuxVaga PIXEL SIZE 10,7 READONLY HASBUTTON
				@ aObj5Size[2,1],aObj5Size[2,2]+90 MSGET cDVaga VAR cDescri WHEN .F. PIXEL  SIZE 100,7
			Else
				@ aObj5Size[2,1],aObj5Size[2,2]+40 MSGET cVaga	 F3 "SQS" VALID Rs150DVag(cVaga,@cProc,@cDVaga) PIXEL SIZE 10,7 HASBUTTON
				@ aObj5Size[2,1],aObj5Size[2,2]+90 MSGET cDVaga WHEN .F. PIXEL  SIZE 100,7
			EndIf

			@ aObj5Size[3,1],aObj5Size[3,2]	SAY OemtoAnsi(STR0023) PIXEL		//"Processo: "
			@ aObj5Size[3,1],aObj5Size[3,2]+40 MSGET cProc	 F3 "SQE" VALID Rs150DPro(cProc,@cDProc) PIXEL SIZE 10,7 HASBUTTON
			@ aObj5Size[3,1],aObj5Size[3,2]+90 MSGET cDProc WHEN .F. PIXEL  SIZE 100,7

		ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg, {|| nOpca:= 1,oDlg:End() },{||nOpca:=2,oDlg:End()})) CENTERED
		SETAPILHA()

		If !IsInCallStack("TCFA040")
			cAuxVaga 	:= cVaga
		Else
			cVaga 		:= cAuxVaga
		EndIf

		If nOpca == 2

			dbSelectArea(cAliasTRX)
			dbCloseArea()

			If oTmpTRP <> Nil
				oTmpTRP:Delete()
				Freeobj(oTmpTRP)
			EndIf

			Return Nil

		ElseIf Empty(cVaga)
			Aviso(STR0027, STR0035,{"Ok"})	//"Atencao"###"O Codigo da Vaga deve ser informado."

			dbSelectArea(cAliasTRX)
			dbCloseArea()

			If oTmpTRP <> Nil
				oTmpTRP:Delete()
				Freeobj(oTmpTRP)
			EndIf

			Return Nil
		EndIf
	EndIf
EndIf

//P.E para permitir validações na seleção do funcionário para uma determinada vaga e/ou processo.
If nQual == 3 .Or. (funname() == "RSPA090" .And. nQual == 7)
	If lRs150Cdt
		If !( ExecBlock("RS150CDT", .F., .F., {cAuxVaga, cProc}) )

			(cAliasTRX)->( DbCloseArea() )
			If oTmpTRP <> Nil
				oTmpTRP:Delete()
				Freeobj(oTmpTRP)
			EndIf

			Return

		EndIf
	EndIf
EndIf

// Montar o aCols conforme o processo que esta na vaga caso o candidato esteja sem processo seletivo
If Len(aCols)=1 .And. Empty(aCols[1][1]) .And. (!Empty(cProc).and.!Empty(cDProc))
	Rs150SQE(cAuxVaga,SQG->QG_CURRIC,cProc)
EndIf

dbSelectArea(cAliasTRX)
dbGotop()

SETAPILHA()

DEFINE FONT oFont NAME "Arial Negrito" SIZE 0, -11
DEFINE MSDIALOG oDlg  FROM	aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] TITLE OemToAnsi(STR0011) PIXEL //"Pesquisa dos candidatos por: "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Por pesquisa ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nQual == 1
	cRsVar 	:= Space(15)

	@ aObjSize[1,1], aObjSize[1,2] 	SAY OemtoAnsi(STR0013) PIXEL  SIZE 25,7		//"Pesquisa: "
	@ aObjSize[1,1], aObjSize[1,2]+35 	MSGET cRsVar VALID Rs150Proc1(@cSay,cAuxVaga,cProc)  PIXEL 	SIZE 50,7
	@ aObjSize[1,1], aObjSize[1,2]+90 	SAY OemtoAnsi(STR0014) SIZE 200,7 PIXEL		//"<ENTER para selecionar o Arquivo da Pesquisa>"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Por data	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nQual == 2
	cRsVar		:= CtoD("  /  /  ")
	cRsAuxVar	:= Iif(cRsAuxVar == "", cRsVar,cRsAuxVar)

	@ aObjSize[1,1], aObjSize[1,2] 	SAY OemtoAnsi(STR0015) PICTURE "@D" PIXEL   SIZE 150,7		//"Pesquisar os Candidatos por Data: "
	@ aObjSize[1,1], aObjSize[1,2]+110 MSGET cRsVar	VALID Rs150Proc1(@cSay)	PIXEL HASBUTTON

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Por candidato ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nQual == 3
	cRsVar 	:= SQG->QG_CURRIC
	cDescric:= SQG->QG_NOME

	@ aObjSize[1,1], aObjSize[1,2] 	SAY OemtoAnsi(STR0016) PIXEL		//"Cod.Curriculo: "
	@ aObjSize[1,1], aObjSize[1,2]+40 	MSGET cRsVar   WHEN .F. PIXEL  SIZE 10,7
	@ aObjSize[1,1], aObjSize[1,2]+73 	MSGET cDescric WHEN .F. PIXEL 	SIZE 200,7

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Por vaga	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nQual == 4
	cRsVar 	:= Space(06)
	cDescric:= Space(30)
	@ aObjSize[1,1], aObjSize[1,2] 	SAY OemtoAnsi(STR0017) PIXEL  SIZE 150,7	//"Pesquisar os Candidatos por Vaga: "
	@ aObjSize[1,1], aObjSize[1,2]+110 MSGET cRsVar	F3 "SQS" VALID Rs150DVaga(@cDescric,cRsVar) .And. Rs150Proc1(@cSay) PIXEL SIZE 10,7 HASBUTTON
	@ aObjSize[1,1], aObjSize[1,2]+145 MSGET cDescric WHEN .F. PIXEL SIZE 100,7

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Por funcionario ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nQual == 5
	cSay := STR0025		//"Funcionario"
	Processa( {|| Rs150Escol(@cSay,cAuxVaga,cProc)} )
	If Len(aCols) == 0

		// Montar aCols em Branco
		inclui	:= .F.
		bSeekWhile	:= {||SQD->QD_FILIAL+SQD->QD_CURRIC}
		cChave	:= Replicate("!", FWGETTAMFILIAL)
		nSqdOrd	:= 2

		//==> Cria aHeader e aCols para WalkThru
		FillGetDados(3						,; //1-nOpcx - número correspondente à operação a ser executada, exemplo: 3 - inclusão, 4 alteração e etc;
					 "SQD"					,; //2-cAlias - area a ser utilizada;
					 nSqdOrd				,; //3-nOrder - ordem correspondente a chave de indice para preencher o  acols;
					 cChave					,; //4-cSeekKey - chave utilizada no posicionamento da area para preencher o acols;
					 bSeekWhile				,; //5-bSeekWhile - bloco contendo a expressão a ser comparada com cSeekKey na condição  do While.
					 NIL					,; //6-uSeekFor - pode ser utilizados de duas maneiras:1- bloco-de-código, condição a ser utilizado para executar o Loop no While;2º - array bi-dimensional contendo N.. condições, em que o 1º elemento é o bloco condicional, o 2º é bloco a ser executado se verdadeiro e o 3º é bloco a ser executado se falso, exemplo {{bCondicao1, bTrue1, bFalse1}, {bCondicao2, bTrue2, bFalse2}.. bCondicaoN, bTrueN, bFalseN};
					 aNoFields				,; //7-aNoFields - array contendo os campos que não estarão no aHeader;
					 NIL					,; //8-aYesFields - array contendo somente os campos que estarão no aHeader;
					 NIL					,; //9-lOnlyYes - se verdadeiro, exibe apenas os campos de usuário;
					 NIL					,; //10-cQuery - query a ser executada para preencher o acols(Obs. Nao pode haver MEMO);
					 NIL					,; //11-bMontCols - bloco contendo função especifica para preencher o aCols; Exmplo:{|| MontaAcols(cAlias)}
					 NIL					,; //12-lEmpty – Caso True ( default é false ), inicializa o aCols com somente uma linha em branco ( como exemplo na inclusão).
					 NIL					,; //13-aHeaderAux, eh Caso necessite tratar o aheader e acols como variáveis locais ( várias getdados por exemplo; uso da MSNewgetdados )
					 NIL					)  //14-aColsAux eh Caso necessite tratar o aheader e acols como variáveis locais ( várias getdados por exemplo; uso da MSNewgetdados )

	EndIf

	If Len(aCols) == 1 .And. Empty(aCols[1][1])
		Rs150AdVaga(.T.)
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Coletivo	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nQual == 6 .Or. nQual == 7

	Rs150Proc1(@cSay, cAuxVaga)

EndIf

If nQual != 3	//Diferente de Candidato

   	@ aObj1Size[3,1],aObj1Size[3,2] 	GROUP oGroup TO aObj1Size[3,3],aObj1Size[3,4] OF oDlg PIXEL
	@ aObj2Size[1,1],aObj2Size[1,2] 	SAY OemtoAnsi(STR0021) OF oDlg PIXEL		//"Nome: "
	@ aObj2Size[1,1],aObj2Size[1,2]+20 SAY oSay PROMPT cSay OF oDlg PIXEL SIZE 115,7

    If nQual == 6 .Or. nQual == 7
	    aListCab := { 	"",;						//Check-box
	    				OemtoAnsi(STR0018),;		//"NOME"
						OemtoAnsi(STR0019),;		//"CURRIC"
						OemtoAnsi(STR0020)}			//"FILIAL"

    Else
        aListCab := { 	OemtoAnsi(STR0018),;		//"NOME"
	  					OemtoAnsi(STR0019),;		//"CURRIC"
						OemtoAnsi(STR0020)}			//"FILIAL"

    EndIf

   If nQual <> 6
		Aadd( aListCab, STR0030 )	//"VAGA"
	EndIf

	For nx := 1 to Len(aInfo)
		Aadd( aListCab, aInfo[nx][2] )
	Next nx

	oLbx :=  TWBrowse():New(aObj1Size[1,1],aObj1Size[1,2],aObj1Size[1,3],aObj1Size[1,4],;
      			{|| Rs150Line()}, aListCab, ,oDlg , , , ,;
      			{||(Rs150Muda((cAliasTRX)->TRX_FILIAL,(cAliasTRX)->TRX_CURRIC,(cAliasTRX)->TRX_NOME,@cSay,cAuxVaga,cProc))}, , , , , , , , , ,.T. )

	oLbx:bLdblclick	:= {|| Rs150Clk()}

	// Controle da Getdados
	oGet:= MSGetDados():New(aObj2Size[2,1],aObj2Size[2,2],aObj2Size[2,3],aObj2Size[2,4],4,"Rs150linOk","Rs150TudOk",,.T.,,1,,300,,,,,oDlg)
	oGet:oBrowse:bAdd := {|| Rs150AdVaga(.F.)}

	//Agendamento coletivo
	If nQual == 6  .Or. nQual == 7
		Aadd( aButtons, { "GROUP"	,{ || Rs150Copia() }, OemToAnsi(STR0043),OemToAnsi(STR0044) } )  //"Copiar Agenda"###"Copiar"
		Aadd( aButtons, { "CHECKED"	,{ || Rs150Invert() },OemToAnsi(STR0046),OemToAnsi(STR0047)} ) //"Inverte seleção"###"Inverte"
	EndIf

Else	//Candidato
	// Listbox de Vagas concorridas pelo Candidato
   	@ aObj3Size[1,1],aObj3Size[1,2] GROUP oGroup TO aObj3Size[1,3],aObj3Size[1,4] OF oDlg PIXEL
	@ aObj4Size[1,1],aObj4Size[1,2] SAY OemtoAnsi(STR0033) OF oDlg PIXEL	//"VAGAS CONCORRIDAS PELO CANDIDATO"

    aListCab := {		OemtoAnsi(STR0030),;		//"VAGA"
						OemtoAnsi(STR0031),;		//"DESCRICAO"
						OemtoAnsi(STR0032) }		//"No.VAGAS"

    oLbx := RDListBox(aObj4Size[2,1],aObj4Size[2,2],aObj4Size[2,3],aObj4Size[2,4], aListCand, aListCab,,,,,.T.)

	oLbx:bChange	:= {|| ( Rs150MudVaga( (cAliasTRX)->TRX_FILIAL, aListCand[oLbx:nAt], @cSay, cAuxVaga, cProc), oLbx:Refresh() ) }

	oLbx:bLine:= {||{ 	aListCand[oLbx:nAt,1],;
						aListCand[oLbx:nAt,2],;
				   		aListCand[oLbx:nAt,3]}}

	// Controle da Getdados
	@ aObj3Size[3,1],aObj3Size[3,2] GROUP oGroup TO aObj3Size[3,3],aObj3Size[3,4] OF oDlg PIXEL
	@ aObj3Size[3,1]+5,aObj3Size[3,2]+5 SAY oSay PROMPT OemtoAnsi(STR0030)+": "+cSay OF oDlg PIXEL SIZE 115,7	//"VAGA"

	oGet:= MSGetDados():New(aObj3Size[3,1]+15,aObj3Size[3,2]+5,aObj3Size[3,3]-5,aObj3Size[3,4]-5,nOpcx,"Rs150linOk","Rs150TudOk",,.T.,,1,,300,,,,"fVldDelaCols",oDlg)

	If nOpcx != 7  .AND. !IsInCallStack("TCFA040")	// # Exclusao ### Inclusão nao deve ocorrer qdo proveniente da tela de atend de solicitacao do portal
		Aadd( aButtons, { "bmpincluir"	, { || Rs150Novo((cAliasTRX)->TRX_FILIAL, { Space(6), Space(30), 0 }, @cSay) }, OemToAnsi(STR0034),OemToAnsi(STR0037) } )  //"Incluir nova Agenda"
		nInclu++
	EndIf
EndIf

If ExistBlock("RS150ML")
	Aadd( aButtons, { "BMPPOST"	,{ || ExecBlock("RS150ML",.F.,.F.,{1}) },OemToAnsi(STR0057),OemToAnsi(STR0058)} ) //"Enviar e-mail"###"e-mail"
Else
	Aadd( aButtons, { "BMPPOST"	,{ || Rs150Email(1) },OemToAnsi(STR0057),OemToAnsi(STR0058)} ) //"Enviar e-mail"###"e-mail"
Endif

If ExistBlock("RS150BT")
	ExecBlock("RS150BT",.F.,.F.)
Endif

//Posiciona no novo registro
If lNewAuxVaga
	oLbx:nAt:= Len(aListCand)
	oLbx:SetArray(aListCand)
	oLbx:bLine	:= {||{	aListCand[oLbx:nAt,1],;
						aListCand[oLbx:nAt,2],;
				   		aListCand[oLbx:nAt,3]}}
	oLbx:Refresh()
EndIf

ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg, {|| If(oGet:TudoOk(),(nOpca:= 1,oDlg:End()),)}, {||nOpca:=2,oDlg:End()},, aButtons)) CENTERED

SETAPILHA()

If nOpca == 1
	If nOpcx != 7	// # Exclusao
		Processa({||Rs150Grava()},OemToAnsi(STR0041)) //"Aguarde... Gravando dados"

        If IsInCallStack("TCFA040")
			//Utilizado no fonte TCFA040 para saber se foi gerado Agenda para o candidato
        	oReturn	:= 0
        EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Envia e-mail de confirmação de reserva de Treinamento para funcionario. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lEnviaMail

			If nAgeMail != 0
				If nAgeMail == 2 .Or. ( nAgeMail == 1 .And. MsgYesNo( OemToAnsi(STR0051)) )
			   		If ExistBlock("RS150ML")
					 	ExecBlock("RS150ML",.F.,.F.,{2})
					Else
						Rs150Email(2)
					Endif
				EndIf
			EndIf

		EndIf

	Else
		Rs150Dele()
	EndIf
EndIf

dbSelectArea(cAliasTRX)
dbCloseArea()

If oTmpTRP <> Nil
	oTmpTRP:Delete()
	Freeobj(oTmpTRP)
EndIf

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Rs150Escol³ Autor ³ Cristina Ogura        ³ Data ³ 03.02.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta os aheaders, acols e listbox das agendas com os dados ³±±
±±³          ³do get, conforme a opcao selecionada.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cSay   := Armazena o codigo e nome do candidato            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Rs150Escol(cSay,cAuxVaga,cProc)
Local cFile			:= ""
Local cCurric		:= ""
Local aOK			:= {}
Local nAnt			:= 0
Local nX			:= 0
Local nY			:= 0
Local nPosVaga		:= GdFieldPos("QD_VAGA")
Local nPosDVaga		:= GdFieldPos("QD_DVAGA")
Local cFilSQD		:= xFilial("SQD")
Local cDtVaga		:= Iif(Type("cRsVar") == "D", DtoS(cRsVar), "")
Local cAuxFil		:= cFilKey
Local nRec			:= 0
Local lArqLocal		:= .F.
Local cPathSrv		:= ""
Local cArquivo		:= ""
Local cArqFPT		:= ""
Local cArqSrv		:= ""
Local cArqSrvFPT	:= ""
Local cRDD			:= __LocalDriver

Local nRecAux		:= SQG->(RECNO())

Private cExt		:= ""
Private cCsvFile	:= ""
Private oArqTRBTmp	:= Nil
Private cNomeTab	:= ""

aSvGetd	:= {}
cEstou  := ""

dbSelectArea(cAliasTRX)
dbCloseArea()
If oTmpTRP <> Nil
	oTmpTRP:Delete()
	Freeobj(oTmpTRP)
EndIf

Rs150Cria(nQual)

If nQual == 1 	// Por pesquisa (Arquivo)

	While .T.

		If lNvTab
			cNomeTab := TelaSelecao()

			If Empty(cNomeTab)
				MsgInfo( OemtoAnsi(STR0116) + "." + CRLF + OemToAnsi(STR0117) )	// "Nenhuma tabela localizada em sua Base de Dados.
				// Caso existam arquivos de pesquisa (extensões .RSP, .PES ou .CSV) a serem consultados, utilize a rotina RSPM003 para importação dos dados."
				Return .T.
			EndIf

			CriaTemp()
			exit

		Else
			cFile := cGetFile(STR0112,OemToAnsi(STR0007),0,,.T.,GETF_ONLYSERVER+GETF_LOCALFLOPPY) //"Selecione arquivo"
			If Empty(cFile)
				Return .T.
			EndIf
			If !File(cFile)
				MsgInfo(OemtoAnsi(STR0008)) //"Nao existe arquivo selecionado"
				cFile:=""
				Loop
			EndIf


			If  AT(".",cFile) # 0
				nPos := AT(".",cFile)-1
			Else
				nPos := Len(cFile)
				cFile := cFile+".PES"//o programa original sempre tenta abrir um PES qdo não acha o caracter ".". Mantivemos desta forma
			EndIf

			If Len(cFile) > 2
				cExt := substr( cFile, Len(cFile)-2,  Len(cFile))
			EndIf

			cFileFPT 	:= Substr(cFile,1,nPos)+".FPT"
			If ( nPos := At(':', cFile) ) > 0	// Drive Local
				lArqLocal := .T.

				IF !Empty ( AllTrim( cPathSrv := GetPvProfString( GetEnvServer(), "StartPath", "", GetADV97() ) ) )
					IF !( Subst( cPathSrv , 1 , 1 ) $ "\/" )
						cPathSrv := "\"+cPathSrv
					EndIF
					IF !( Subst( cPathSrv , -1	) $ "\/" )
						cPathSrv+= "\"
					EndIF

					cArquivo	:= cFile
					cArqFPT		:= cFileFPT
					If ( nPos := At(':', cArquivo) ) > 0
						cArquivo := SubS(cArquivo, nPos+1)
						cArqFPT	:= Subs(cArqFPT, nPos+1)
					EndIf
					Do While At('\', cArquivo) > 0 .Or. At('/', cArquivo)> 0
						If (nPos := At('\', cArquivo)) > 0 .Or. (nPos := At('/', cArquivo)) > 0
							cArquivo := SubS(cArquivo, nPos+1)
							cArqFPT	:= Subs(cArqFPT, nPos+1)
						EndIf
					EndDo

					cArqSrv := RetArq( cRDD , cPathSrv + cArquivo , .T. )
					CpyT2S( cFile , cPathSrv  , .F. )

		       		If File(cFileFPT)
						cArqSrvFPT 	:= RetArq( cRDD , cPathSrv + cArqFPT , .T. )
						CpyT2S( cFileFPT, cPathSrv, .F. )
					EndIf

					If File(cArqSrv)
						If Upper(cExt) == "CSV"
							cCsvFile := cArqSrv
						Else
							MsOpenDbf( .T. , cRDD , cArqSrv , "TRB" , .F. , .F. )
						EndIf

					Else
						MsgInfo(OemtoAnsi(STR0008))    //"Nao existe arquivo selecionado"
						Loop
					EndIF
				EndIf

			Else	// Servidor

				If Upper(cExt) == "CSV"
					cCsvFile := cFile
				Else
					dbUseArea(.T., cRDD, cFile,"TRB", .F., .F.)
				EndIf
			EndIf

			If NETERR()
				MsgInfo(OemtoAnsi(STR0009)) //"Arquivo esta sendo usado"
				cFile:=""
				Loop
			EndIf

			cRsVar := cFile

			If Upper(cExt) != "CSV"
				aOk:=DBSTRUCT()
				If aOk[1][1] # "CURRIC" .And. aOK[2][1] # "CURRIC"
					MsgInfo(OemtoAnsi(STR0010)) //"Este arquivo nao pertence a pesquisa"

					dbSelectArea("TRB")
					dbCloseArea()
					cFile:=""
					Loop
				EndIf
			Else
				LerCSV()
			EndIf

			Exit
		EndIf

	EndDo
EndIf

If nQual == 1 .Or. nQual == 7 // Por pesquisa (arquivo e resultado)

	dbSelectArea("TRB")
	dbGotop()
	ProcRegua(TRB->( RecCount() ))

	// Guarda o primeiro candidato para montar a getdados
	cSay := "Cod Curriculo: "+TRB->CURRIC+Space(02)+"Nome: "+(cAliasTRX)->TRX_NOME

	While !Eof()

		If nQual == 7 .And. !aLbx[TRB->( Recno() )][1]
			dbSkip()
			Loop
		EndIf

		IncProc(STR0016+": "+TRB->CURRIC)	//"Cod.Curriculo: "

		dbSelectArea(cAliasTRX)
		RecLock(cAliasTRX,.T.)
			(cAliasTRX)->TRX_FILIAL	:= cAuxFil
			(cAliasTRX)->TRX_NOME	:= TRB->NOME
			(cAliasTRX)->TRX_CURRIC	:= TRB->CURRIC
			If nQual <> 6
				(cAliasTRX)->TRX_VAGA	:= TRB->VAGA
			EndIf

			If nQual == 6 .Or. nQual == 7
				(cAliasTRX)->TRX_CHECK	:= .T.
			EndIf

			For nx := 1 to Len(aInfo)
				If aInfo[nx][1] != "TRX_CHECK"
					&( "(cAliasTRX)->"+(aInfo[nx][1]) ) := FDesc( "SQG", TRB->CURRIC, aInfo[nx][1] )
				EndIf
			Next nx

		MsUnlock()

		aHeaderAux	:={}
		aColsAux	:={}
		nSqdOrd		:= 3
		cChave		:= cAuxFil+(cAliasTRX)->TRX_VAGA+(cAliasTRX)->TRX_CURRIC
		bSeekWhile	:= {||SQD->QD_FILIAL+SQD->QD_VAGA+SQD->QD_CURRIC }

		//==> Cria aHeader e aCols para WalkThru
		FillGetDados(4						,; //1-nOpcx - número correspondente à operação a ser executada, exemplo: 3 - inclusão, 4 alteração e etc;
					 "SQD"					,; //2-cAlias - area a ser utilizada;
					 nSqdOrd				,; //3-nOrder - ordem correspondente a chave de indice para preencher o  acols;
					 cChave					,; //4-cSeekKey - chave utilizada no posicionamento da area para preencher o acols;
					 bSeekWhile				,; //5-bSeekWhile - bloco contendo a expressão a ser comparada com cSeekKey na condição  do While.
					 NIL					,; //6-uSeekFor - pode ser utilizados de duas maneiras:1- bloco-de-código, condição a ser utilizado para executar o Loop no While;2º - array bi-dimensional contendo N.. condições, em que o 1º elemento é o bloco condicional, o 2º é bloco a ser executado se verdadeiro e o 3º é bloco a ser executado se falso, exemplo {{bCondicao1, bTrue1, bFalse1}, {bCondicao2, bTrue2, bFalse2}.. bCondicaoN, bTrueN, bFalseN};
					 aNoFields				,; //7-aNoFields - array contendo os campos que não estarão no aHeader;
					 NIL					,; //8-aYesFields - array contendo somente os campos que estarão no aHeader;
					 NIL					,; //9-lOnlyYes - se verdadeiro, exibe apenas os campos de usuário;
					 NIL					,; //10-cQuery - query a ser executada para preencher o acols(Obs. Nao pode haver MEMO);
					 NIL					,; //11-bMontCols - bloco contendo função especifica para preencher o aCols; Exmplo:{|| MontaAcols(cAlias)}
					 NIL					,; //12-lEmpty – Caso True ( default é false ), inicializa o aCols com somente uma linha em branco ( como exemplo na inclusão).
					 aHeaderAux				,; //13-aHeaderAux, eh Caso necessite tratar o aheader e acols como variáveis locais ( várias getdados por exemplo; uso da MSNewgetdados )
					 aColsAux				)  //14-aColsAux eh Caso necessite tratar o aheader e acols como variáveis locais ( várias getdados por exemplo; uso da MSNewgetdados )
		Aadd(aOldCols, aclone(aColsAux) )
		If Len(aColsAux) == 1 .And. Empty(aColsAux[1][1])
			nPosVaga := GdFieldPos("QD_VAGA",aHeaderAux)
			If nPosVaga > 0
				aColsAux[1][nPosVaga] := (cAliasTRX)->TRX_VAGA
			EndIf
			nPosDVaga := GdFieldPos("QD_DVAGA",aHeaderAux)
			If nPosDVaga > 0
				Rs150DVag(cAuxVaga,"",@(aColsAux[1][nPosDVaga]))
			EndIf
		EndIf

		Aadd(aSvGetd,{cAuxFil+TRB->CURRIC,aColsAux})

		dbSelectArea("TRB")
		dbSkip()
	EndDo

	If nQual == 1
		dbSelectArea("TRB")
		dbCloseArea()

		If oArqTRBTmp <> Nil
			oArqTRBTmp:Delete()
			Freeobj(oArqTRBTmp)
		EndIf
	EndIf

	dbSelectArea(cAliasTRX)

ElseIf nQual == 2   	// Por Data
	cCurric :=""

	dbSelectArea("SQD")
	dbSetOrder(1)

	//Obter numero de registros desta data
	nRec := 0
	dbSeek(cFilSQD+cDtVaga)
	While !Eof() .And. cFilSQD+cDtVaga ==;
		SQD->QD_FILIAL+DTOS(SQD->QD_DATA)
		nRec++
		dbSkip()
	EndDo

	ProcRegua( nRec )

	If dbSeek(cFilSQD+cDtVaga)
		While !Eof() .And. cFilSQD+cDtVaga ==;
			SQD->QD_FILIAL+DTOS(SQD->QD_DATA)

			IncProc(STR0016+cCurric)	//Cod.Curriculo: "

			If cCurric # SQD->QD_CURRIC

				IF SQG->(DBSEEK( XFILIAL("SQG") + SQD->QD_CURRIC ))
					if (SQG->(Columnpos("QG_ACTRSP")) > 0 .and. SQG->QG_ACTRSP <> '1') .or. SQG->(Columnpos("QG_ACTRSP")) <= 0  //1- sem aceite e 2-com aceite
						if (cBlqCV <> "2" .or. (cBlqCV == "2" .and. SQG->QG_ACEITE == "2")) //1=Sem aceite; 2=Aceite vigente gravado

							nAnt 	 := RecNo()
							If FWModeAccess("SQG",1) + FWModeAccess("SQG",2) + FWModeAccess("SQG",3) == "CCC"
								cNome 	:= Rs150Nome(xFilial('SQG')+SQD->QD_CURRIC)
							Else
								cNome 	:= Rs150Nome(xFilial('SQG',SQD->QD_FILIAL)+SQD->QD_CURRIC)
							EndIf

							dbSelectArea(cAliasTRX)
							RecLock(cAliasTRX,.T.)
								(cAliasTRX)->TRX_NOME	:= cNome
								(cAliasTRX)->TRX_CURRIC	:= SQD->QD_CURRIC
								(cAliasTRX)->TRX_FILIAL	:= SQD->QD_FILIAL

								If nQual <> 6
									(cAliasTRX)->TRX_VAGA := SQD->QD_VAGA
								EndIf

								For nx := 1 to Len(aInfo)
									If aInfo[nx][1] != "TRX_CHECK"
										&( "(cAliasTRX)->"+(aInfo[nx][1]) ) := FDesc( "SQG", SQD->QD_CURRIC, aInfo[nx][1] )
									EndIf
								Next nx
							MsUnlock()

							aHeaderAux	:={}
							aColsAux	:={}
							nSqdOrd		:= 1
							cChave		:= cFilSQD+cDtVaga+SQD->QD_CURRIC
							bSeekWhile	:= {||SQD->QD_FILIAL+DTOS(SQD->QD_DATA)+SQD->QD_CURRIC }

							//==> Cria aHeader e aCols para WalkThru
							FillGetDados(4						,; //1-nOpcx - número correspondente à operação a ser executada, exemplo: 3 - inclusão, 4 alteração e etc;
										"SQD"					,; //2-cAlias - area a ser utilizada;
										nSqdOrd				,; //3-nOrder - ordem correspondente a chave de indice para preencher o  acols;
										cChave					,; //4-cSeekKey - chave utilizada no posicionamento da area para preencher o acols;
										bSeekWhile				,; //5-bSeekWhile - bloco contendo a expressão a ser comparada com cSeekKey na condição  do While.
										NIL					,; //6-uSeekFor - pode ser utilizados de duas maneiras:1- bloco-de-código, condição a ser utilizado para executar o Loop no While;2º - array bi-dimensional contendo N.. condições, em que o 1º elemento é o bloco condicional, o 2º é bloco a ser executado se verdadeiro e o 3º é bloco a ser executado se falso, exemplo {{bCondicao1, bTrue1, bFalse1}, {bCondicao2, bTrue2, bFalse2}.. bCondicaoN, bTrueN, bFalseN};
										aNoFields				,; //7-aNoFields - array contendo os campos que não estarão no aHeader;
										NIL					,; //8-aYesFields - array contendo somente os campos que estarão no aHeader;
										NIL					,; //9-lOnlyYes - se verdadeiro, exibe apenas os campos de usuário;
										NIL					,; //10-cQuery - query a ser executada para preencher o acols(Obs. Nao pode haver MEMO);
										NIL					,; //11-bMontCols - bloco contendo função especifica para preencher o aCols; Exmplo:{|| MontaAcols(cAlias)}
										NIL					,; //12-lEmpty – Caso True ( default é false ), inicializa o aCols com somente uma linha em branco ( como exemplo na inclusão).
										aHeaderAux				,; //13-aHeaderAux, eh Caso necessite tratar o aheader e acols como variáveis locais ( várias getdados por exemplo; uso da MSNewgetdados )
										aColsAux				)  //14-aColsAux eh Caso necessite tratar o aheader e acols como variáveis locais ( várias getdados por exemplo; uso da MSNewgetdados )

							dbSelectArea("SQD")
							dbGoto(nAnt)
							Aadd(aOldCols, aclone(aColsAux) )
							Aadd(aSvGetd,{SQD->QD_FILIAL+SQD->QD_CURRIC,aColsAux})

							cCurric := SQD->QD_CURRIC
						ENDIF
					ENDIF
				ENDIF
			SQG->(DBGOTO(nRecAux))
			EndIf

			dbSelectArea("SQD")
			dbSetOrder(1)
			dbSkip()
		EndDo
	Else
		Help("",1,"Rs150NDATA")		// Nao existe candidato nesta data
		Return .F.
	EndIf

ElseIf nQual == 4 // Por Data
	cCurric := ""
	nTamaCols:= 0

	dbSelectArea("SQD")
	dbSetOrder(3)

	//Obter numero de registros desta vaga
	nRec := 0
	dbSeek(cFilSQD+cRsVar)
	While !Eof() .And. cFilSQD+cRsVar == ;
		SQD->QD_FILIAL+SQD->QD_VAGA
		nRec++
		dbSkip()
	EndDo

	ProcRegua( nRec )

	If dbSeek(cFilSQD+cRsVar)
		While !Eof() .And. cFilSQD+cRsVar ==;
			SQD->QD_FILIAL+SQD->QD_VAGA

			IncProc(STR0016+cCurric)	//Cod.Curriculo: "

			If cCurric != SQD->QD_CURRIC
				IF SQG->(DBSEEK( XFILIAL("SQG") + SQD->QD_CURRIC ))
					if (SQG->(Columnpos("QG_ACTRSP")) > 0 .and. SQG->QG_ACTRSP <> '1') .or. SQG->(Columnpos("QG_ACTRSP")) <= 0  //1- sem aceite e 2-com aceite
						if (cBlqCV <> "2" .or. (cBlqCV == "2" .and. SQG->QG_ACEITE == "2")) //1=Sem aceite; 2=Aceite vigente gravado
							nAnt 	:= SQD->( RecNo() )
							If FWModeAccess("SQG",1) + FWModeAccess("SQG",2) + FWModeAccess("SQG",3) == "CCC"
								cNome 	:= Rs150Nome(xFilial('SQG')+SQD->QD_CURRIC)
							Else
								cNome 	:= Rs150Nome(xFilial('SQG',SQD->QD_FILIAL)+SQD->QD_CURRIC)
							EndIf
							dbSelectArea(cAliasTRX)
							RecLock(cAliasTRX,.T.)
								(cAliasTRX)->TRX_NOME	:= cNome
								(cAliasTRX)->TRX_CURRIC	:= SQD->QD_CURRIC
								(cAliasTRX)->TRX_FILIAL	:= SQD->QD_FILIAL

								If nQual <> 6
									(cAliasTRX)->TRX_VAGA := SQD->QD_VAGA
								EndIf

								For nx := 1 to Len(aInfo)
									If aInfo[nx][1] != "TRX_CHECK"
										&( "(cAliasTRX)->"+(aInfo[nx][1]) ) := FDesc( "SQG", SQD->QD_CURRIC, aInfo[nx][1] )
									EndIf
								Next nx

							MsUnlock()

							aHeaderAux	:={}
							aColsAux	:={}
							nSqdOrd		:= 3
							cChave		:= cFilSQD+cRsVar+SQD->QD_CURRIC
							bSeekWhile	:= {||SQD->QD_FILIAL+SQD->QD_VAGA+SQD->QD_CURRIC }

							//==> Cria aHeader e aCols para WalkThru
							FillGetDados(4						,; //1-nOpcx - número correspondente à operação a ser executada, exemplo: 3 - inclusão, 4 alteração e etc;
										"SQD"					,; //2-cAlias - area a ser utilizada;
										nSqdOrd				,; //3-nOrder - ordem correspondente a chave de indice para preencher o  acols;
										cChave					,; //4-cSeekKey - chave utilizada no posicionamento da area para preencher o acols;
										bSeekWhile				,; //5-bSeekWhile - bloco contendo a expressão a ser comparada com cSeekKey na condição  do While.
										NIL					,; //6-uSeekFor - pode ser utilizados de duas maneiras:1- bloco-de-código, condição a ser utilizado para executar o Loop no While;2º - array bi-dimensional contendo N.. condições, em que o 1º elemento é o bloco condicional, o 2º é bloco a ser executado se verdadeiro e o 3º é bloco a ser executado se falso, exemplo {{bCondicao1, bTrue1, bFalse1}, {bCondicao2, bTrue2, bFalse2}.. bCondicaoN, bTrueN, bFalseN};
										aNoFields				,; //7-aNoFields - array contendo os campos que não estarão no aHeader;
										NIL					,; //8-aYesFields - array contendo somente os campos que estarão no aHeader;
										NIL					,; //9-lOnlyYes - se verdadeiro, exibe apenas os campos de usuário;
										NIL					,; //10-cQuery - query a ser executada para preencher o acols(Obs. Nao pode haver MEMO);
										NIL					,; //11-bMontCols - bloco contendo função especifica para preencher o aCols; Exmplo:{|| MontaAcols(cAlias)}
										NIL					,; //12-lEmpty – Caso True ( default é false ), inicializa o aCols com somente uma linha em branco ( como exemplo na inclusão).
										aHeaderAux				,; //13-aHeaderAux, eh Caso necessite tratar o aheader e acols como variáveis locais ( várias getdados por exemplo; uso da MSNewgetdados )
										aColsAux				)  //14-aColsAux eh Caso necessite tratar o aheader e acols como variáveis locais ( várias getdados por exemplo; uso da MSNewgetdados )

							Aadd(aOldCols, aclone(aColsAux) )
							dbSelectArea("SQD")
							dbGoto(nAnt)

							Aadd(aSvGetd,{SQD->QD_FILIAL+SQD->QD_CURRIC,aColsAux})

							cCurric := SQD->QD_CURRIC
						ENDIF
					ENDIF
				EndIf
			ENDIF
			SQG->(DBGOTO(nRecAux))
			dbSelectArea("SQD")
			dbSetOrder(3)
			dbSkip()
		EndDo
	Else
		If SQS->( dbSeek(xFilial('SQS')+cRsVar))
	   		Help("",1,"RS150CAN")		// Nao existe candidato para esta vaga
	   		Return .F.
	   	Else
	   		Help("",1,"Rs150NVaga")		// A vaga nao esta cadastrada
	   		Return .F.
	 	Endif
	EndIf

ElseIf nQual == 5			// Funcionario

	RSPM002()	// Importa Funcionarios para Cad. Curriculos

	If Len(aFuncs) > 0

		ProcRegua( Len(aFuncs) )

		For nX := 1 to Len(aFuncs)

			IncProc()

			dbSelectArea(cAliasTRX)
			RecLock(cAliasTRX,.T.)
				(cAliasTRX)->TRX_FILIAL	:= cFilSQD
				(cAliasTRX)->TRX_CURRIC	:= aFuncs[nX][1]
				(cAliasTRX)->TRX_NOME	:= aFuncs[nX][2]

				If nQual <> 6
					(cAliasTRX)->TRX_VAGA := cAuxVaga
				EndIf

				For ny := 1 to Len(aInfo)
					&( "(cAliasTRX)->"+(aInfo[ny][1]) ) := FDesc( "SQG", aFuncs[nx][1], aInfo[ny][1] )
				Next ny

			MsUnlock()

			aHeaderAux	:={}
			aColsAux	:={}
			nSqdOrd		:= 2
			cChave		:= (cAliasTRX)->TRX_FILIAL+(cAliasTRX)->TRX_CURRIC
			bSeekWhile	:= {||SQD->QD_FILIAL+SQD->QD_CURRIC }

			//==> Cria aHeader e aCols para WalkThru
			FillGetDados(4						,; //1-nOpcx - número correspondente à operação a ser executada, exemplo: 3 - inclusão, 4 alteração e etc;
						 "SQD"					,; //2-cAlias - area a ser utilizada;
						 nSqdOrd				,; //3-nOrder - ordem correspondente a chave de indice para preencher o  acols;
						 cChave					,; //4-cSeekKey - chave utilizada no posicionamento da area para preencher o acols;
						 bSeekWhile				,; //5-bSeekWhile - bloco contendo a expressão a ser comparada com cSeekKey na condição  do While.
						 NIL					,; //6-uSeekFor - pode ser utilizados de duas maneiras:1- bloco-de-código, condição a ser utilizado para executar o Loop no While;2º - array bi-dimensional contendo N.. condições, em que o 1º elemento é o bloco condicional, o 2º é bloco a ser executado se verdadeiro e o 3º é bloco a ser executado se falso, exemplo {{bCondicao1, bTrue1, bFalse1}, {bCondicao2, bTrue2, bFalse2}.. bCondicaoN, bTrueN, bFalseN};
						 aNoFields				,; //7-aNoFields - array contendo os campos que não estarão no aHeader;
						 NIL					,; //8-aYesFields - array contendo somente os campos que estarão no aHeader;
						 NIL					,; //9-lOnlyYes - se verdadeiro, exibe apenas os campos de usuário;
						 NIL					,; //10-cQuery - query a ser executada para preencher o acols(Obs. Nao pode haver MEMO);
						 NIL					,; //11-bMontCols - bloco contendo função especifica para preencher o aCols; Exmplo:{|| MontaAcols(cAlias)}
						 NIL					,; //12-lEmpty – Caso True ( default é false ), inicializa o aCols com somente uma linha em branco ( como exemplo na inclusão).
						 aHeaderAux				,; //13-aHeaderAux, eh Caso necessite tratar o aheader e acols como variáveis locais ( várias getdados por exemplo; uso da MSNewgetdados )
						 aColsAux				)  //14-aColsAux eh Caso necessite tratar o aheader e acols como variáveis locais ( várias getdados por exemplo; uso da MSNewgetdados )
			Aadd(aOldCols, aclone(aColsAux) )
			Aadd(aSvGetd,{(cAliasTRX)->TRX_FILIAL+(cAliasTRX)->TRX_CURRIC,aColsAux})
		Next nX
	EndIf


ElseIf nQual == 6

	dbSelectArea("SQG")
	dbSetOrder(1)

	//Obter numero de registros desta vaga
	nRec := SQG->( RecCount() )

	ProcRegua( nRec )
	dbGotop()
	While !Eof()

		If !Empty(cFiltroSQG) .And. !(&cFiltroSQG)
			dbSkip()
			Loop
		EndIf

		IncProc(STR0016+SQG->QG_NOME)	//Cod.Curriculo: "

		dbSelectArea(cAliasTRX)
		RecLock(cAliasTRX,.T.)
			(cAliasTRX)->TRX_NOME	:= SQG->QG_NOME
			(cAliasTRX)->TRX_CURRIC	:= SQG->QG_CURRIC
			(cAliasTRX)->TRX_FILIAL	:= SQG->QG_FILIAL

			For nx := 1 to Len(aInfo)
				If aInfo[nx][1] != "TRX_CHECK"
					&( "(cAliasTRX)->"+(aInfo[nx][1]) ) := &( "SQG->"+(aInfo[nx][1]) )
				EndIf
			Next nx

		MsUnlock()

		aHeaderAux	:={}
		aColsAux	:={}
		nSqdOrd		:= 2
		cChave		:= cFilKey+SQG->QG_CURRIC
		bSeekWhile	:= {||SQD->QD_FILIAL+SQD->QD_CURRIC }

		//==> Cria aHeader e aCols para WalkThru
		FillGetDados(4						,; //1-nOpcx - número correspondente à operação a ser executada, exemplo: 3 - inclusão, 4 alteração e etc;
					 "SQD"					,; //2-cAlias - area a ser utilizada;
					 nSqdOrd				,; //3-nOrder - ordem correspondente a chave de indice para preencher o  acols;
					 cChave					,; //4-cSeekKey - chave utilizada no posicionamento da area para preencher o acols;
					 bSeekWhile				,; //5-bSeekWhile - bloco contendo a expressão a ser comparada com cSeekKey na condição  do While.
					 NIL					,; //6-uSeekFor - pode ser utilizados de duas maneiras:1- bloco-de-código, condição a ser utilizado para executar o Loop no While;2º - array bi-dimensional contendo N.. condições, em que o 1º elemento é o bloco condicional, o 2º é bloco a ser executado se verdadeiro e o 3º é bloco a ser executado se falso, exemplo {{bCondicao1, bTrue1, bFalse1}, {bCondicao2, bTrue2, bFalse2}.. bCondicaoN, bTrueN, bFalseN};
					 aNoFields				,; //7-aNoFields - array contendo os campos que não estarão no aHeader;
					 NIL					,; //8-aYesFields - array contendo somente os campos que estarão no aHeader;
					 NIL					,; //9-lOnlyYes - se verdadeiro, exibe apenas os campos de usuário;
					 NIL					,; //10-cQuery - query a ser executada para preencher o acols(Obs. Nao pode haver MEMO);
					 NIL					,; //11-bMontCols - bloco contendo função especifica para preencher o aCols; Exmplo:{|| MontaAcols(cAlias)}
					 NIL					,; //12-lEmpty – Caso True ( default é false ), inicializa o aCols com somente uma linha em branco ( como exemplo na inclusão).
					 aHeaderAux				,; //13-aHeaderAux, eh Caso necessite tratar o aheader e acols como variáveis locais ( várias getdados por exemplo; uso da MSNewgetdados )
					 aColsAux				)  //14-aColsAux eh Caso necessite tratar o aheader e acols como variáveis locais ( várias getdados por exemplo; uso da MSNewgetdados )
		Aadd(aOldCols, aclone(aColsAux) )

		Aadd(aSvGetd,{SQG->QG_FILIAL+SQG->QG_CURRIC,aColsAux})

		dbSelectArea("SQG")
		dbSetOrder(1)
		dbSkip()
	EndDo

	If (cAliasTRX)->( RecCount() ) == 0
		Aviso(OemToAnsi(STR0027), OemToAnsi(STR0048), {"Ok"})	//"Atencao"###"Nao foi encontrado nenhum candidato para o filtro informado."
		Return .F.
	EndIf
EndIf

dbSelectArea(cAliasTRX)
dbGotop()
cSay := (cAliasTRX)->TRX_CURRIC + " - " + (cAliasTRX)->TRX_NOME

If nQual == 1  //Pesquisa
	cAuxVaga	:= (cAliasTRX)->TRX_VAGA
EndIf

Rs150Muda((cAliasTRX)->TRX_FILIAL,(cAliasTRX)->TRX_CURRIC,(cAliasTRX)->TRX_NOME,@cSay,cAuxVaga,cProc)

If ValType(oSay) != "U"
	oSay:Refresh()
EndIf
If ValType(oGet) != "U"
	oGet:Refresh()
	oLbx:Refresh()
EndIf

cRsAuxVar := cRsVar

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Rs150Proc1   ³ Autor ³ Emerson Grassi     ³ Data ³ 13/05/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega agenda 								              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 					                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function Rs150Proc1(cSay,cAuxVaga,cProc)
Local lProc	:= .F.

Processa( {|| lProc := Rs150Escol(@cSay,cAuxVaga,cProc)} )

Return lProc

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Rs150Grava³ Autor ³ Cristina Ogura        ³ Data ³ 03.02.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Executa a gravacao dos campos dos arquivos selecionados    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Rs150Grava()
Local nPos0 		:= 0
Local nx			:= 0
Local ny			:= 0
Local ni			:= 0
Local nOrder		:= 0
Local nTamGetd		:= 0
Local cVar			:= ""
Local cAux			:= ""
Local cAuxFil		:= ""
Local cCurric		:= ""
Local cChave		:= ""
Local cFiltro		:= ""
Local nPosTest		:= GdFieldPos("QD_TESTE")
Local nPosData		:= GdFieldPos("QD_DATA")
Local nPosProc		:= GdFieldPos("QD_TPPROCE")
Local nPosVaga		:= GdFieldPos("QD_VAGA")
Local nPosResu		:= GdFieldPos("QD_RESULTA")
Local cVaga			:= ""
Local cDtVaga		:= Iif(Type("cRsVar") == "D", DtoS(cRsVar), "")
Local lAtuSQG		:= .F.
Local lIdenticas	:= .F.
Local lLinNova		:= .F.
Local lInicRecLock	:= .T.
Local nPosRecno		:= GdFieldPos("QD_REC_WT")
Local lRS150GV		:= ExistBlock("RS150GV")

lAtuSQG := MsgYesNo(OemToAnsi(STR0040)) 	// "Deseja atualizar Situacao dos Candidatos no Curriculo ?"

If nQual != 3 	// # de candidato
	// Grava os dados da getdados que estava posicionado
	If !Empty(cEstou)
		nPos0   := Ascan(aSvGetd,{|x| x[1] == cEstou})
		If nPos0 > 0
			aSvGetd[nPos0][2] := aClone(aCols)
		EndIf
	EndIf
	nTamGetd := Len(aSvGetd)

Else	//Candidato

	If !Empty(cEstou)
		nPos0   := Ascan(aSvGetCand,{|x| x[1] == cEstou})
		If nPos0 > 0
			aSvGetCand[nPos0][2] := aClone(aCols)
		EndIf
    EndIf
	nTamGetd := Len(aSvGetCand)

EndIf

ProcRegua(nTamGetd)

For ny := 1 To nTamGetd //Numero de Candidatos

	IncProc()

	If nQual != 3
		cAux	:= aSvGetd[ny][1]
		cAuxFil := Substr(aSvGetd[ny][1],1,FwGetTamFilial)
		cCurric := Substr(aSvGetd[ny][1],FwGetTamFilial+1,6)

		aCols 	:= aClone(aSvGetd[ny][2])

	Else	//Candidato
		cCurric := SQG->QG_CURRIC
		cAux	:= aSvGetCand[ny][1]
		cAuxFil := Substr(aSvGetCand[ny][1],1,FwGetTamFilial)
		cVaga   := Substr(aSvGetCand[ny][1],FwGetTamFilial+1,6)

		aCols 	:= aClone(aSvGetCand[ny][2])
	EndIf

	// Deletar as agendas do candidato

	If nQual == 1		// Pesquisa
		nOrder := 3
		cChave := cAuxFil+cCurric
		cFiltro:= "SQD->QD_FILIAL+SQD->QD_VAGA+SQD->QD_CURRIC"

	ElseIf nQual == 2	// Data
		nOrder := 1
		cChave := cAuxFil+cDtVaga+cCurric
		cFiltro:= "SQD->QD_FILIAL+DTOS(SQD->QD_DATA)+SQD->QD_CURRIC"

	ElseIf nQual == 3 	// Candidato
		nOrder := 3
		cChave := cAuxFil+cVaga+cCurric
		cFiltro:= "SQD->QD_FILIAL+SQD->QD_VAGA+SQD->QD_CURRIC"

	ElseIf nQual == 4 	// Vaga
		nOrder := 3
		cChave := cAuxFil+cRsVar+cCurric
		cFiltro:= "SQD->QD_FILIAL+SQD->QD_VAGA+SQD->QD_CURRIC"

	ElseIf nQual == 5 .Or. nQual == 6 .Or. nQual == 7	// Funcionario ou Coletivo
		nOrder := 2
		cChave := cAuxFil+cCurric
		cFiltro:= "SQD->QD_FILIAL+SQD->QD_CURRIC"
	EndIf

	dbSelectArea("SQD")
	dbSetOrder(nOrder)

	If nInclu > 0 .OR. ALTERA
		nInclu	:=	0
	EndIF

	For nx := 1 To Len(aCols)

		lLinNova := .T.

		If Len(aOldCols) > 0
			// Tratando-se de linha já existente no inicio da rotina
			// Estrutura do array aOldCols devido ao aClone sempre fica como:
			// aOldCols - array
			// aOldCols[1][1]
			// aOldCols[1][x] onde X é o número de linhas
		 	If Len(aOldCols[1]) >= nx
		 		If !Empty(aCols[nx][nPosRecno])  //existe recno
			 		lLinNova := .F.
					lIdenticas := fCompArray( aOldCols[ny][nx] , aCols[nx] )
				EndIf
			EndIf
		EndIf

		// Deletado .or. com data em branco nao grava
		If !aCols[nx][Len(aCols[nx])] .and. !Empty(aCols[nx][nPosData])

			lInicRecLock := .F.
			If lLinNova
				RecLock("SQD",.T.)
				lInicRecLock := .T.
			Else
				SQD->(DbGoTo( aCols[nx][nPosRecno]  ))/*Posiciona com base no Recno da Sqd, registrado no aCols */

				If SQD->(!Eof())  .And. !lIdenticas//se mudou algo, haverá necessidade de uodate
					RecLock("SQD",.F.)
					lInicRecLock := .T.
				EndIf
			EndIf

			If lInicRecLock
				SQD->QD_FILIAL := cAuxFil
				SQD->QD_CURRIC := cCurric

				If nQual == 3	//Candidato
					SQD->QD_VAGA := cVaga
				EndIf

				For ni = 1 to Len(aHeader)
						If aHeader[ni][10] # "V"
							cVar := Trim(aHeader[ni][2])
							&cVar. := aCols[nx][ni]
						ElseIf aHeader[ni][8] == "M"
							//Grava os Campos Memo
							MsUnlock()
							If AllTrim(aHeader[ni][2]) == "QD_OBSCAND"
								If !Empty(aCols[nx][ni])
									MsMm(SQD->QD_CODOBSC,NIL,NIL,aCols[nx][ni],1,NIL,NIL,"SQD","QD_CODOBSC")
								EndIf
							ElseIf AllTrim(aHeader[ni][2]) == "QD_OBSAVAL"
								If !Empty(aCols[nx][ni])
									MsMm(SQD->QD_CODOBSA,NIL,NIL,aCols[nx][ni],1,NIL,NIL,"SQD","QD_CODOBSA")
								EndIf
							EndIf
							RecLock("SQD",.F.)
						EndIf
				Next ni

				MsUnlock()
			EndIf

			dbSelectArea("SQG")
			dbSetOrder(1)
			If dbSeek(xFilial("SQG")+cCurric)

				RecLock("SQG",.F.)

				//Atualiza Situacao no SQG
				If lAtuSQG

					//Verifica data do Processo
					If SQG->QG_ULTDATA <= aCols[nx][nPosData] .And. !Empty(aCols[nx][nPosResu])

						SQG->QG_ULTDATA := aCols[nx][nPosData] 		//Ultima Data

						If !Empty(aCols[nx][nPosTest])	//Data do Teste
							SQG->QG_DTTESTE := aCols[nx][nPosData]
						EndIf

						SQG->QG_ULTVAGA := Iif( nQual == 3, cVaga, aCols[nx][nPosVaga] )
						SQG->QG_ULTETAP := aCols[nx][nPosProc]
					EndIf
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Ponto de Entrada para gravacao de campos no SQG para cada candidato agendado. ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lRS150GV
					ExecBlock("RS150GV",.F.,.F.)
				Endif
				SQG->( MsUnlock() )

			EndIf

		Else
			If !lLinNova
				SQD->(DbGoTo( aCols[nx][nPosRecno]  ))/*Posiciona com base no Recno da Sqd, registrado no aCols */

				If SQD->(!Eof())
					RecLock("SQD",.F.)
					SQD->(DbDelete())
					MsUnLock()
				EndIf
			EndIf
		EndIf

		dbSelectArea("SQD")
		dbSetOrder(nOrder)
	Next nx
Next ny

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Rs150LinOK ³ Autor ³Cristina Ogura       ³ Data ³ 06.03.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao da linha OK                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Rs150LinOk()
Local nPosData 	:= GdFieldPos("QD_DATA")
Local nPosHora 	:= GdFieldPos("QD_HORA")
Local nPosFRes 	:= ''
Local nPosmRes 	:= ''
Local nPosVaga 	:= 0
Local nPosProc 	:= GdFieldPos("QD_TPPROCE")
Local nUsa	   	:= If (Len(aCols)>0,Len(aCols[n]),0)
Local nx		:= 0
Local lMsg 		:= .F.

If nQual <> 3
	nPosVaga 	:= GdFieldPos("QD_VAGA")
EndIf

If nUsa == 0
	Return .F.
EndIf

If  aCols[n,nUsa] == .F. .And.;
	nPosData > 0 .And. nPosHora >0 .And. nPosProc > 0

	If (!Empty(aCols[n,nPosData]) .Or. !Empty(aCols[n,nPosProc]) .Or. (nPosVaga > 0 .And. !Empty(aCols[n,nPosVaga])) ).Or.;
		(nQual == 6 ) //Agenda Coletiva
		lMsg:=.T.
	EndIf

	If lMsg .And. (Empty(aCols[n,nPosData]) .Or. Empty(aCols[n,nPosProc]) .Or. ( nPosVaga > 0 .And. Empty(aCols[n,nPosVaga]) ))
		Help("",1, "Rs150Vazio")	// Existe algum campo vazio, verifique os campos,
		Return .F.					// data, hora, vaga e tp de processo
	EndIf

	For nx := 1 To Len(aCols)
		If 	( (nQual == 3) .Or. ( nPosVaga > 0 .And. aCols[nx,nPosVaga]==aCols[n,nPosVaga] )) .And. ;
			aCols[nx,nPosHora]==aCols[n,nPosHora] .And. ;
			aCols[nx,nPosProc]==aCols[n,nPosProc] .And. ;
			aCols[nx,nPosData]==aCols[n,nPosData] .And.;
			nx # n .And. aCols[nx,nUsa]== .F.
			Help(" ",1,"RS150JAEXI")		// Ja existe um processo para este candidato
			Return .F.						// nesta data.
		Endif
	Next nx

	If nQual == 4  //Por vaga
		SQD->(dbSetOrder(3))
		SQD->(dbSeek(xFilial("SQD")+aCols[n,nPosVaga] ))
	EndIf
EndIf

nPosFRes 	:= GdFieldPos("QD_FILPROC")
nPosmRes 	:= GdFieldPos("QD_MATPROC")
If Empty(aCols[n,nPosMRes]) .AND. !Empty(aCols[n,nPosFRes])
	aCols[n,nPosFRes] := ''
ElseIf !Empty(aCols[n,nPosMRes]) .AND. Empty(aCols[n,nPosFRes])
	aCols[n,nPosFRes] := SRA->RA_FILIAL
EndIf

//Nao retirar. Está em uso por causa do walkthru
nTamaCols:= Len(aCols)

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Rs150TudOK ³ Autor ³Emerson Grassi Rocha ³ Data ³ 21/03/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para verificar toda getdados.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Rs150TudOk()
Local aSaveArea	:= GetArea()
Local lRet 		:= .F.
Local nTamSvGC	:= 0
Local nSGC		:= 0
Local nTamCols	:= 0
Local nA		:= 0
Local nX		:= 0
Local nPosData 	:= GdFieldPos("QD_DATA")
Local nPosHora 	:= GdFieldPos("QD_HORA")
Local nPosProc 	:= GdFieldPos("QD_TPPROCE")
Local nDel	   	:= 0
Local nPosFRes 	:= ''
Local nPosmRes 	:= ''


	lRet	:= Rs150LinOK()

	//Valida se o aCols da Agenda está com os campos principais preenchidos para o candidato
	//Utilizado para a rotina de atend a solicitações do portal TCFA040
	If IsInCallStack("TCFA040") .AND. nQual == 3
		nTamSvGC	:= Len(aSvGetCand)
		//Se for o primeiro já foi validado pelo aCols do Rs150LinOk
		If nTamSvGC > 1
			Rs150MudVaga( (cAliasTRX)->TRX_FILIAL, aListCand[oLbx:nAt])
			For nSGC := 1 To nTamSvGC
				nTamCols	:= Len(aSvGetCand[nSGC,2])

				For nA := 1 To nTamCols
					nDel := aSvGetCand[nSGC,2,nA]
					If (Empty(aSvGetCand[nSGC,2,nA,nPosData]) .OR.;
						  Empty(aSvGetCand[nSGC,2,nA,nPosHora]) .OR.;
					 	    Empty(aSvGetCand[nSGC,2,nA,nPosProc])) .AND.;
					 	    	aSvGetCand[nSGC,2,nA,nDel] == .F.
						Help("",1, "Rs150Vazio")	// Existe algum campo vazio, verifique os campos,
						lRet	:= .F.				// data, hora, vaga e tp de processo
					EndIf
				Next nA
			Next nSGC
		EndIf
	EndIf

	For nX := 1 To Len(aCols)
		nPosFRes 	:= GdFieldPos("QD_FILPROC")
		nPosmRes 	:= GdFieldPos("QD_MATPROC")
		If !Empty(aCols[nX,nPosMRes]) .AND. Empty(aCols[nX,nPosFRes])
			Alert(STR0102) //"Selecione a matricula do responsável através da opção F3, para que a filial da matricula do responsável seja inserida corretamente."
			lRet	:= .F.
		EndIf

		If !Empty(aCols[nX,nPosMRes]) .AND. !Empty(aCols[nX,nPosFRes])
			dbSelectArea("SRA")
			dbSetOrder(1)
			If !dbSeek(aCols[nX,nPosFRes]+aCols[nX,nPosMRes])
				Alert(STR0103) //"A filial e matricula não foi localizada. Selecione a matricula do responsável através da opção F3, para que a filial da matricula seja inserida corretamente."
				lRet	:= .F.
			EndIf
		EndIf
	Next nX
   RestArea(aSaveArea)
Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Rs150LstOK ³ Autor ³Leandro Drumond      ³ Data ³ 06.03.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao da linha OK do ListBox                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Rs150LstOk()

Local lOk := .F.

dbSelectArea(cAliasTRX)
dbGotop()

While !(cAliasTRX)->(Eof())
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se algum candidato foi selecionado ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If !(cAliasTRX)->TRX_CHECK
       (cAliasTRX)->(dbSkip())
       Loop
    EndIf

    lOk := .T.
    Exit
EndDo

If !lOk
	Aviso(OemToAnsi(STR0027),OemtoAnsi(STR0084),{"OK"})	//"Atenção"#"Não foram selecionados candidatos para o Agendamento Coletivo"
	dbGoTop()
EndIf

Return lOk

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Rs150Muda³ Autor ³ Cristina Ogura        ³ Data ³ 03.02.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Controla a mudanca de campos no listbox                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cFil   := Filial                                           ³±±
±±³          ³ cCurric:= Codigo do curriculo                              ³±±
±±³          ³ cNome  := Nome do candidato                                ³±±
±±³          ³ cSay   := Texto contendo codigo do curriculo e nome        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Rs150Muda(cFil,cCurric,cNome,cSay,cAuxVaga,cProc)
Local nPos0	:= 0
Local nPos1 := 0

If !Empty(cEstou)
	nPos0   := Ascan(aSvGetd,{|x| x[1] == cEstou})
	If nPos0 > 0
		aSvGetd[nPos0][2] := aClone(aCols)
	EndIf
EndIf

cSay   	:= cCurric + " - " + cNome
nPos1  	:= Ascan(aSvGetd,{|x| x[1] == cFil+cCurric})

If nPos1  # 0
	aCols	:= aClone(aSvGetd[nPos1][2])
EndIf

n := 1

cEstou := cFil+cCurric

// Montar o aCols conforme o processo que esta na vaga
If Len(aCols)=1 .And. Empty(aCols[1][1]) .And. (!Empty(cAuxVaga).or. !Empty(cProc))
	Rs150SQE(cAuxVaga,cCurric,cProc)
EndIf

If (ValType(oSay) != "U")
	oSay:Refresh()
EndIf
If ValType(oGet) != "U"
	oGet:ForceRefresh()
EndIf

Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Rs150Nome³ Autor ³ Cristina Ogura        ³ Data ³ 03.02.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o nome do candidato                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cChave   := Chave para seek com codigo do candidato        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Rs150Nome(cChave)
Local aSaveArea := GetArea()
Local cRet		:= Space(30)

dbSelectArea("SQG")
dbSetOrder(1)
If dbSeek(cChave)
	cRet := SQG->QG_NOME
EndIf

RestArea(aSaveArea)

Return cRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Rs150Desc³ Autor ³ Cristina Ogura        ³ Data ³ 03.02.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao que atualiza os campos virtuais no SX3              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nEscol := pode ser 1-Vaga 2-Processo 3-Resultado 4-Teste   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Rs150Desc(nEscol)
Local aSaveArea	:= GetArea()
Local cDesc		:= ""
Local cAux		:= &(ReadVar())
Local nPos		:= 0

If nEscol == 1				// Vaga
	nPos := GdFieldPos("QD_DVAGA")

	dbSelectArea("SQS")
	dbSetOrder(1)
	If !dbSeek(xFilial("SQS")+cAux)
		Help("",1,"Rs150NVaga")		// Nao existe esta vaga cadastrado. Verifique.
		RestArea(aSaveArea)
		Return .F.
	Else
		cDesc := SQS->QS_DESCRIC
	EndIf

ElseIf nEscol == 4			// Teste
	nPos := GdFieldPos("QD_DESCRIC")

	If Empty(cAux)
		cDesc := ""
	Else
		dbSelectArea("SQQ")
		dbSetOrder(1)
		If !dbSeek(xFilial("SQQ")+cAux)
			Help("",1,"Rs150NTest")		// Nao existe este teste cadastrado. Verifique.
			RestArea(aSaveArea)
			Return .F.
		Else
			cDesc := SQQ->QQ_DESCRIC
		EndIf
	EndIf

Else
	If nEscol == 2
		nPos:= GdFieldPos("QD_DTPPROC")
		cAux := "R9"+cAux
	Else
		nPos:= GdFieldPos("QD_DRESULT")
		cAux := "RA"+cAux
	EndIf

	dbSelectArea("SX5")
	If dbSeek(xFilial("SX5")+cAux)
		cDesc := Substr(SX5->X5_DESCRI,1,50)
	EndIf
EndIf

aCols[n][nPos] := cDesc

RestArea(aSaveArea)

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Rs150Cria³ Autor ³ Cristina Ogura        ³ Data ³ 03.02.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria o arquivo temporario do listbox                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Rs150Cria(nQual)

Local nx := 0
If ValType("cAliasTRX") == "U" .Or. Empty(cAliasTRX)
	cAliasTRX	:= GetNextAlias()
EndIf

//Se possuir alguma área em uso com esse nome encerra para não gerar erro
If Select(cAliasTRX) > 0
	(cAliasTRX)->( DbCloseArea() )
EndIf


If oTmpTRP <> Nil
	oTmpTRP:Delete()
	Freeobj(oTmpTRP)

EndIf

If nQual == 6
	aAdd(aCampos,{"TRX_NOME"		,"C",30	,0})
	aAdd(aCampos,{"TRX_CURRIC"	,"C",6	,0})
	aAdd(aCampos,{"TRX_FILIAL"	,"C",FWGETTAMFILIAL ,0})
Else
   //Observei que quando o fonte rspa090 dispara a opção do menu acoes relacionadas "Agendar" o sistema pode passar mais de uma vez no trecho abaixo. Como não posso limpar aCampos,
   //evito criar campo em duplicidade dele, o que ocasionava errlog

   If Ascan(aCampos,{|x| x[1] == "TRX_NOME"}) == 0
   		aAdd(aCampos,{"TRX_NOME"		,"C",30	,0})
   EndIf

   If Ascan(aCampos,{|x| x[1] == "TRX_CURRIC"}) == 0
   		aAdd(aCampos,{"TRX_CURRIC"	,"C",6	,0})
   EndIf

   If Ascan(aCampos,{|x| x[1] == "TRX_FILIAL"}) == 0
   		aAdd(aCampos,{"TRX_FILIAL"	,"C",FWGETTAMFILIAL ,0})
   EndIf

   If Ascan(aCampos,{|x| x[1] == "TRX_VAGA"}) == 0
   		aAdd(aCampos,{"TRX_VAGA"		,"C",6	,0})
   EndIf
EndIf

For nx := 1 To Len(aInfo)
 	If Ascan(aCampos,{|x| x[1] == aInfo[nx][1]}) == 0
 		Aadd(aCampos, {aInfo[nx][1], aInfo[nx][3], aInfo[nx][4], aInfo[nx][5]})
	EndIf
Next nx
oTmpTRP := FWTemporaryTable():New(cAliasTRX)
oTmpTrp:SetFields(aCampos)
oTmpTRP:AddIndex( "I01", {"TRX_NOME"} )

oTmpTRP:Create()
dbSelectArea(cAliasTRX)
Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Rs150List³ Autor ³ Cristina Ogura        ³ Data ³ 03.02.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza a descricao da vaga                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cDescric := Descricao da vaga                              ³±±
±±³          ³ cVaga    := Codigo da vaga                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Rs150DVaga(cDescric,cVaga)
Local aSaveArea	:= GetArea()

dbSelectArea("SQS")
dbSetOrder(1)
If dbSeek(xFilial("SQS")+cVaga)
	cDescric:= SQS->QS_DESCRIC
EndIf

RestArea(aSaveArea)

Return .T.


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Rs150Ver ³ Autor ³ Cristina Ogura        ³ Data ³ 03.02.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica na getdados a data e vaga, conforme opcao aRotina ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nEscol   := 1-Data 2-Vaga		 	  	                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Rs150Ver(nEscol)
Local cAux := &(ReadVar())

If nQual == 2 .And. nEscol==1					// Por data
	If cRsVar # cAux
		Help("",1,"Rs150Data")		// Data diferente da pesquisa.
		Return .F.
	EndIf
ElseIf nQual == 4 .And. nEscol == 2
	If cRsVar # cAux
		Help("",1,"Rs150Vaga")		// Vaga diferente da pesquisa.
		Return .F.
	EndIf
EndIf
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ Rs150SQE    ³ Autor ³Emerson Grassi Rocha³ Data ³ 09.08.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta Processo Seletivo de acordo com a Vaga.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ RSPA150       ³											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Rs150SQE(cAuxVaga,cCurric,cProcesso)
Local aSaveArea	:= GetArea()
Local cDescri	:= ""
Local nUsado 	:= Len(aHeader)
Local nACols 	:= 0
Local nCntFor 	:= 0
Local aAuxCols	:= {}

cProcesso:= Iif(cProcesso==Nil,"",cProcesso)
cAuxVaga := Iif(cAuxVaga ==Nil,"",cAuxVaga)

inclui := .t.

If !Empty(cAuxVaga)
	dbSelectArea("SQS")
	dbSetOrder(1)
	If dbSeek(xFilial("SQS")+cAuxVaga)
		If Empty(cProcesso)
			cProcesso := SQS->QS_PROCESS
		EndIf
		cDescri   := SQS->QS_DESCRIC
	EndIf
EndIf

dbSelectArea("SQE") //Processo seletivo
dbSetOrder(1)
If dbSeek(xFilial("SQE")+cProcesso)
	aAuxCols := {}
	While !Eof() .And. xFilial("SQE")+cProcesso ==;
		SQE->QE_FILIAL+SQE->QE_PROCESS

		Aadd(aAuxCols,Array(nUsado+1))
		nAcols := Len(aAuxCols)
		For nCntFor := 1 To Len(aHeader)
			If Alltrim(aHeader[nCntFor][2]) = "QD_CURRIC"
				aAuxCols[nAcols][nCntFor] := cCurric
			ElseIf Alltrim(aHeader[nCntFor][2]) = "QD_VAGA"
				aAuxCols[nAcols][nCntFor] := cAuxVaga
			ElseIf Alltrim(aHeader[nCntFor][2]) = "QD_DVAGA"
				aAuxCols[nAcols][nCntFor] := cDescri
			ElseIf Alltrim(aHeader[nCntFor][2]) = "QD_TPPROCE"
				aAuxCols[nAcols][nCntFor] := SQE->QE_TPPROCE
			ElseIf Alltrim(aHeader[nCntFor][2]) = "QD_DTPPROC"
				dbSelectArea("SX5")
				If dbSeek(xFilial("SX5")+"R9"+SQE->QE_TPPROCE)
					aAuxCols[nAcols][nCntFor] := X5Descri()
				EndIf
			ElseIf Alltrim(aHeader[nCntFor][2]) = "QD_TESTE"
				aAuxCols[nAcols][nCntFor] := SQE->QE_TESTE
			ElseIf Alltrim(aHeader[nCntFor][2]) = "QD_DESCRIC"
				dbSelectArea("SQQ")
				dbSetOrder(1)
				If dbSeek(xFilial("SQQ")+SQE->QE_TESTE)
					aAuxCols[nAcols][nCntFor] := SQQ->QQ_DESCRIC
				EndIf
			ElseIf Alltrim(aHeader[nCntFor][2]) <> "QD_ALI_WT"	;
					.AND. Alltrim(aHeader[nCntFor][2]) <> "QD_REC_WT"
				aAuxCols[nAcols][nCntFor] := CriaVar(aHeader[nCntFor][2],.T.)
			EndIf
		Next nCntFor
		aAuxCols[nAcols][nUsado+1] := .F.
		dbSelectArea("SQE")
		dbSkip()
	EndDo
	aCols := aClone(aAuxCols)
EndIf

inclui:= .F.

RestArea(aSaveArea)

Return .T.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ Rs150SQE    ³ Autor ³Emerson Grassi Rocha³ Data ³ 09.08.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta Processo Seletivo de acordo com a Vaga.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ RSPA150       ³											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Rs150AuxSQE(cAuxVaga,cCurric,cProcesso,aHeaderAux)
Local aSaveArea	:= GetArea()
Local cDescri	:= ""
Local nUsado 	:= Len(aHeaderAux)
Local nACols 	:= 0
Local nCntFor 	:= 0
Local aAuxCols	:= {}

cProcesso:= Iif(cProcesso==Nil,"",cProcesso)
cAuxVaga := Iif(cAuxVaga ==Nil,"",cAuxVaga)

inclui := .t.

If !Empty(cAuxVaga)
	dbSelectArea("SQS")
	dbSetOrder(1)
	If dbSeek(xFilial("SQS")+cAuxVaga)
		If Empty(cProcesso)
			cProcesso := SQS->QS_PROCESS
		EndIf
		cDescri   := SQS->QS_DESCRIC
	EndIf
EndIf

dbSelectArea("SQE") //Processo seletivo
dbSetOrder(1)
If dbSeek(xFilial("SQE")+cProcesso)
	aAuxCols := {}
	While !Eof() .And. xFilial("SQE")+cProcesso ==;
		SQE->QE_FILIAL+SQE->QE_PROCESS

		Aadd(aAuxCols,Array(nUsado+1))
		nAcols := Len(aAuxCols)
		For nCntFor := 1 To Len(aHeaderAux)
			If Alltrim(aHeaderAux[nCntFor][2]) = "QD_CURRIC"
				aAuxCols[nAcols][nCntFor] := cCurric
			ElseIf Alltrim(aHeaderAux[nCntFor][2]) = "QD_VAGA"
				aAuxCols[nAcols][nCntFor] := cAuxVaga
			ElseIf Alltrim(aHeaderAux[nCntFor][2]) = "QD_DVAGA"
				aAuxCols[nAcols][nCntFor] := cDescri
			ElseIf Alltrim(aHeaderAux[nCntFor][2]) = "QD_TPPROCE"
				aAuxCols[nAcols][nCntFor] := SQE->QE_TPPROCE
			ElseIf Alltrim(aHeaderAux[nCntFor][2]) = "QD_DTPPROC"
				dbSelectArea("SX5")
				If dbSeek(xFilial("SX5")+"R9"+SQE->QE_TPPROCE)
					aAuxCols[nAcols][nCntFor] := X5Descri()
				EndIf
			ElseIf Alltrim(aHeaderAux[nCntFor][2]) = "QD_TESTE"
				aAuxCols[nAcols][nCntFor] := SQE->QE_TESTE
			ElseIf Alltrim(aHeaderAux[nCntFor][2]) = "QD_DESCRIC"
				dbSelectArea("SQQ")
				dbSetOrder(1)
				If dbSeek(xFilial("SQQ")+SQE->QE_TESTE)
					aAuxCols[nAcols][nCntFor] := SQQ->QQ_DESCRIC
				EndIf
			ElseIf Alltrim(aHeaderAux[nCntFor][2]) <> "QD_ALI_WT"	;
					.AND. Alltrim(aHeaderAux[nCntFor][2]) <> "QD_REC_WT"
				aAuxCols[nAcols][nCntFor] := CriaVar(aHeaderAux[nCntFor][2],.T.)
			EndIf
		Next nCntFor
		aAuxCols[nAcols][nUsado+1] := .F.
		dbSelectArea("SQE")
		dbSkip()
	EndDo
	//aCols := aClone(aAuxCols)
EndIf

inclui:= .F.

RestArea(aSaveArea)

Return aAuxCols

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ Rs150Relac  ³ Autor ³ Cristina Ogura	  	³ Data ³ 12.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao executada no X3_RELACAO para atualizar as descricoes³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ RSPA090       ³											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Rs150Relac(cAlias, cCpoRet, cCodPesq)
Local nPos		:= 0
Local cConteudo := 0
Local cRet		:= ""
Local cSX5		:= ""

nPos := GdFieldPos(cCodPesq)
If nPos > 0
	cConteudo := aCols[Len(aCols),nPos]
EndIf

If Substr(cAlias,1,1) == "X"
	cSX5 := Substr(cAlias,2,2)
	cRet := TrmDesc("SX5",cSX5+cConteudo,"SX5->X5_DESCRI")
Else
	If "VAGA" $ AllTrim(cCodPesq)
		cRet := TrmDesc(cAlias,cConteudo,"SQS->QS_DESCRIC")
	ElseIf "TESTE" $ Alltrim(cCodPesq)
		cRet := TrmDesc(cAlias,cConteudo,"SQQ->QQ_DESCRIC")
	EndIf
EndIf

Return(cRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ Rs150DVag   ³ Autor ³Emerson Grassi Rocha³ Data ³ 09.08.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Descricao da Vaga / Descricao Processo					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ RSPA150       ³											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Rs150DVag(cVaga,cProc,cDVaga,cFilSqs)

Local lRet := .T.

DEFAULT cFilSqs := Nil

DbSelectArea("SQS")
dbSetOrder(1)
cFilSqs := If( cFilSqs==Nil, xfilial("SQS"), cFilSqs )
If(dbSeek(cFilSqs+cVaga))
	If SQS->QS_NRVAGA <= SQS->QS_VAGAFEC
		Aviso(OemToAnsi(STR0027),OemToAnsi(STR0038),{"OK"} ) //"Atencao"#"A vaga ja foi preenchida"
		lRet := .F.
	ElseIf Empty(cProc)
		cProc := SQS->QS_PROCESS
	EndIf
	cDVaga:= SQS->QS_DESCRIC
Else
	Aviso(OemToAnsi(STR0027),OemToAnsi(STR0039),{"OK"}) //"Atencao","Vaga nao cadastrada"
	lRet := .F.
EndIf

Return lRet


//-----------------------------
Function Rs150DPro(cProc,cDProc)

DbSelectArea("SQE")
dbSetOrder(1)
If(dbSeek(xfilial("SQE")+cProc))
	cDProc := SQE->QE_DESCRIC
EndIf
Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Rs150Dele ³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 19/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exclusao de Agenda.									      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function Rs150Dele()

Local cAuxFil	:= SQG->QG_FILIAL //Substr(cEstou,1,FwGetTamFilial)
Local cCurric	:= SQG->QG_CURRIC
Local cChave	:= cAuxFil+cCurric
Local cFiltro	:= "SQD->QD_FILIAL+SQD->QD_CURRIC"

If FWModeAccess("SQG",1) + FWModeAccess("SQG",2) + FWModeAccess("SQG",3) == "CCC"
	cChave := xFilial('SQD') + cCurric
EndIf

dbSelectArea("SQD")
dbSetOrder(2)
dbSeek(cChave)

IF Eof()
	Aviso(STR0027, STR0028,{"Ok"})
	return .T.
ENDIF

Aviso(STR0027, STR0106,{"Ok"}) //"Somente serão excluídos registros cujos processos não foram iniciados."

While !Eof() .And. &cFiltro == cChave
	If !( fVldExclu() )
		Begin Transaction
			RecLock("SQD",.F.)
				dbDelete()
			MsUnlock()
			AtuRH3()
		End Transaction
	EndIf
	dbSkip()
EndDo

MsgAlert(STR0118)

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Rs150MudVaga ³ Autor ³ Emerson Grassi     ³ Data ³ 03.02.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Controla a mudanca de campos no listbox                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 					                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function Rs150MudVaga(cFil,aList,cSay,cAuxVaga,cProc)
Local nI		:= 0
Local nTamLC	:= 0
Local nPos1 	:= 0
Local lRegExist	:= .F.

If !Empty(cEstou) .And. Len(aCols) > 0

	nPos1   := Ascan(aSvGetCand,{|x| x[1] == cEstou})
	If nPos1 > 0 .AND. !Empty(aCols[1,1])
		aSvGetCand[nPos1][2] := aClone(aCols)
	EndIf
EndIf

nPos1  	:= Ascan(aSvGetCand,{|x| x[1] == cFil+aList[1]})

If nPos1 != 0
	aCols	:= aClone(aSvGetCand[nPos1][2])
Else
	Aadd(aSvGetCand,{cFilKey+aList[1],aCols})
EndIf

// Montar o aCols conforme o processo que esta na vaga
If ( nPos1 == 0 .Or. ( Len(aListCand) == 1 .And. Empty(aCols[1][1]) ) ) .And. (!Empty(cAuxVaga).or. !Empty(cProc))
	Rs150SQE(cAuxVaga,SQG->QG_CURRIC,cProc)

	If !Empty(cAuxVaga)
		dbSelectArea("SQS")
		dbSetOrder(1)
		If IsInCallStack("TCFA040") .Or. dbSeek(cFil+cAuxVaga)

			//Atualiza array da Agenda
			aSvGetCand[Len(aSvGetCand)][1] := cFilKey+cAuxVaga
			aSvGetCand[Len(aSvGetCand)][2] := Aclone(aCols)

			// Atualiza ListBox de Vagas
			If Len(aListCand) == 1 .And. Empty(aListCand[1][1])
				aListCand[1] := { cAuxVaga, Left(SQS->QS_DESCRIC,30), STR( SQS->QS_NRVAGA - SQS->QS_VAGAFEC, 3) }
			Else
				nTamLC	:= Len(aListCand)

				For nI := 1 To nTamLC
					If AllTrim(aListCand[nI,1]) == cAuxVaga
						lRegExist	:= .T.
					EndIf
				Next nI

				//Evita de repetir no list a mesma vaga, isso ocorre quando o aCols ainda não foi carregado
				If !lRegExist
					Aadd(aListCand, { cAuxVaga, Left(SQS->QS_DESCRIC,30), STR( SQS->QS_NRVAGA - SQS->QS_VAGAFEC, 3) })
				EndIf
			EndIf

			oLbx:nAt:= Len(aListCand)
			oLbx:SetArray(aListCand)
			oLbx:bLine	:= {||{	aListCand[oLbx:nAt,1],;
								aListCand[oLbx:nAt,2],;
						   		aListCand[oLbx:nAt,3]}}
			oLbx:Refresh()
		EndIf
    EndIf
EndIf

n 		:= 1
cEstou 	:= cFil+aListCand[oLbx:nAt,1]
cSay 	:= aListCand[oLbx:nAt,1]+" - "+aListCand[oLbx:nAt,2]

If (ValType(oSay) != "U")
	oSay:Refresh()
EndIf
If ValType(oGet) != "U"
	oGet:oBrowse:Refresh()
	oGet:ForceRefresh()
EndIf

Return Nil


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Rs150Novo    ³ Autor ³ Emerson Grassi     ³ Data ³ 25/06/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inclui nova agenda para o Candidato.	                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 					                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function Rs150Novo(cFil,aList, cSay)

// Entrada de Dados
Local cVaga 	:= Space(TamSx3("QS_VAGA")[1])
Local cProc		:= Space(TamSx3("QE_PROCESS")[1])
Local cDvaga 	:= ""
Local cDProc 	:= ""
Local nOpca		:= 0

// Montagem de Acols
Local cChave	:= ""
Local nSqdOrd	:= 3
Local aNoFields	:= {"QD_CURRIC","QD_NOME","QD_VAGA","QD_DVAGA"}
Local bSeekWhile:= {||SQD->QD_FILIAL+SQD->QD_VAGA+SQD->QD_CURRIC}

// Objetos da Janela
Local oFont
Local oDlg
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaração de arrays para dimensionar tela		                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize		:= MsAdvSize( , .T., 100)
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
aAdd( aObjCoords , { 000 , 020 , .T. , .F. } )
aAdd( aObjCoords , { 000 , 010 , .T. , .F. } )
aAdd( aObjCoords , { 000 , 010 , .T. , .F. } )
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )

SETAPILHA()
DEFINE FONT oFont NAME "Arial Negrito"  SIZE 10, -11
DEFINE MSDIALOG oDlg  FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] TITLE OemToAnsi(STR0011) PIXEL//"Pesquisa dos candidatos por: "

@ aObjSize[2,1],aObjSize[2,2] 		SAY OemtoAnsi(STR0036) PIXEL		//"Vaga: "
@ aObjSize[2,1],aObjSize[2,2]+40 	MSGET cVaga	 F3 "SQS" VALID Rs150DVag(cVaga,@cProc,@cDVaga) PIXEL SIZE 10,7 HASBUTTON
@ aObjSize[2,1],aObjSize[2,2]+90 	MSGET cDVaga  WHEN .F. PIXEL  SIZE 100,7

@ aObjSize[3,1],aObjSize[3,2] 		SAY OemtoAnsi(STR0023) PIXEL		//"Processo: "
@ aObjSize[3,1],aObjSize[3,2]+40 	MSGET cProc	 F3 "SQE" VALID Rs150DPro(cProc,@cDProc) PIXEL SIZE 10,7 HASBUTTON
@ aObjSize[3,1],aObjSize[3,2]+90 	MSGET cDProc  WHEN .F. PIXEL  SIZE 100,7

ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg, {|| nOpca:= 1,oDlg:End() },{||nOpca:=2,oDlg:End()}))
SETAPILHA()

If nOpca == 2
	Return Nil

ElseIf Empty(cVaga)
	Aviso(STR0027, STR0035,{"Ok"})	//"Atencao"###"O Codigo da Vaga deve ser informado."
	Return Nil
EndIf

If !Empty(cVaga)
	nPos2:= Ascan(aListCand,{|x| x[1] == cVaga})
	If nPos2 > 0
		Aviso(STR0104, STR0105,{"Ok"})	//"Atencao - Vaga ja cadastrada"
		Return Nil
	EndIf
EndIf

cChave 	:= SQS->QS_FILIAL + cVaga + SQG->QG_CURRIC

If !Empty(cEstou)
	nPos1   := Ascan(aSvGetCand,{|x| x[1] == cEstou})
	If nPos1 > 0
		aSvGetCand[nPos1][2] := aClone(aCols)
	EndIf
EndIf

If cEstou != SQS->QS_FILIAL+cVaga
	aCols	:= {}
EndIf

nPos1 := Ascan(aSvGetCand,{|x| x[1] == cFilKey+cVaga })

aHeader := {}
If  nPos1 == 0

	//==> Cria aHeader e aCols para WalkThru
	FillGetDados(3						,; //1-nOpcx - número correspondente à operação a ser executada, exemplo: 3 - inclusão, 4 alteração e etc;
				 "SQD"					,; //2-cAlias - area a ser utilizada;
				 nSqdOrd				,; //3-nOrder - ordem correspondente a chave de indice para preencher o  acols;
				 cChave					,; //4-cSeekKey - chave utilizada no posicionamento da area para preencher o acols;
				 bSeekWhile				,; //5-bSeekWhile - bloco contendo a expressão a ser comparada com cSeekKey na condição  do While.
				 NIL					,; //6-uSeekFor - pode ser utilizados de duas maneiras:1- bloco-de-código, condição a ser utilizado para executar o Loop no While;2º - array bi-dimensional contendo N.. condições, em que o 1º elemento é o bloco condicional, o 2º é bloco a ser executado se verdadeiro e o 3º é bloco a ser executado se falso, exemplo {{bCondicao1, bTrue1, bFalse1}, {bCondicao2, bTrue2, bFalse2}.. bCondicaoN, bTrueN, bFalseN};
				 aNoFields				,; //7-aNoFields - array contendo os campos que não estarão no aHeader;
				 NIL					,; //8-aYesFields - array contendo somente os campos que estarão no aHeader;
				 NIL					,; //9-lOnlyYes - se verdadeiro, exibe apenas os campos de usuário;
				 NIL					,; //10-cQuery - query a ser executada para preencher o acols(Obs. Nao pode haver MEMO);
				 NIL					,; //11-bMontCols - bloco contendo função especifica para preencher o aCols; Exmplo:{|| MontaAcols(cAlias)}
				 NIL					,; //12-lEmpty – Caso True ( default é false ), inicializa o aCols com somente uma linha em branco ( como exemplo na inclusão).
				 NIL					,; //13-aHeaderAux, eh Caso necessite tratar o aheader e acols como variáveis locais ( várias getdados por exemplo; uso da MSNewgetdados )
				 NIL					)  //14-aColsAux eh Caso necessite tratar o aheader e acols como variáveis locais ( várias getdados por exemplo; uso da MSNewgetdados )

Else
	If nPos1 != oLbx:nAt .And. aListCand[olBx:nAt][1] == cVaga
		Adel(aListCand, oLbx:nAt)
		aSize(aListCand,Len(aListCand)-1)
		oLbx:nAt := nPos1
	EndIf
	aList := Aclone(aListCand[olBx:nAt])
EndIf

Rs150MudVaga(cFil,aList,@cSay,cVaga,cProc)

Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Rs150AdVaga  ³ Autor ³ Emerson Grassi     ³ Data ³ 16/12/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Preenche o campo vaga com codigo de vaga da ListBox.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 					                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function Rs150AdVaga(lFirst)
Local nPosVaga := GdFieldPos("QD_VAGA")

If !lFirst
	Eval( {|| oGet:LCHGFIELD := .F., oGet:ADDLINE() } )
EndIf

If ValType(oGet) != "U"
	If nPosVaga > 0
		aCols[n,nPosVaga] := (cAliasTRX)->TRX_VAGA
	EndIf
EndIf

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Rs150Copia    ³ Autor ³Emerson Grassi    ³ Data ³ 30/05/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Copia Agenda do primeiro candidato para outros candidatos. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Rs150Copia()			                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Rs150Copia()

Local nRecTRX	:= (cAliasTRX)->( RecCount() )
Local nx		:= 0
Local nPos		:= 0
Local aSaveArea	:= GetArea()
Local nRecAtu	:= (cAliasTRX)->( Recno() )

If msgYesNo(STR0045) //"Confirma a copia de Agenda do primeiro candidato para os demais ?"
	For nx := 2 To nRecTRX
		(cAliasTRX)->( DbGoto(nx) )

		If (cAliasTRX)->TRX_CHECK //Candidato selecionado

			If nRecAtu == 1	//Utiliza conteudo do aCols
				aSvGetd[nx][2] := aClone(aCols)
			Else			//Utiliza conteudo do aSvGetd
				aSvGetd[nx][2] := aClone(aSvGetd[1][2])
			EndIf

		EndIf
	Next nx

	If !Empty(cEstou)
		nPos   := Ascan(aSvGetd,{|x| x[1] == cEstou})
		If nPos > 1
			aCols := aClone(aSvGetd[nPos][2])
		EndIf
	EndIf

	oGet:Refresh()
	oGet:oBrowse:Refresh()

EndIf

RestArea(aSaveArea)
Return(.T.)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Rs150Clk ³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 30/05/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao executada no ON CLICK do ListBox.	                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                           				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³RSPA090                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Rs150Clk()
Local lVldMrkPE		:= .T.

DEFAULT lRs050Sel 	:= ExistBlock("RS050SEL")

	If nQual == 6 .Or. nQual == 7

		If lRs050Sel
			lVldMrkPE := ExecBlock("RS050SEL", .F., .F., {cAliasTRX})
		EndIf

		If lVldMrkPE
			(cAliasTRX)->( RecLock(cAliasTRX,.F.) )
			(cAliasTRX)->TRX_CHECK := Iif( (cAliasTRX)->TRX_CHECK, .F., .T. )
			(cAliasTRX)->( MsUnlock() )
			oLbx:Refresh()
		EndIf

	EndIf

Return .T.


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Rs150Line³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 30/05/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta linha da List-box.					                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                           				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³RSPA090                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Rs150Line()

Local cListCpo 	:= ""
Local nx		:= 0


If nQual == 6 .Or. nQual == 7
	cListCpo += If((cAliasTRX)->TRX_CHECK, "oOk", "oNo")+","
EndIf

For nx := 1 To Len(aCampos)
  	If aCampos[nx][1] != "TRX_CHECK"
		cListCpo += "(cAliasTRX)->" + aCampos[nx][1]+","
	EndIf
Next nx
cListCpo := &( "{"+ ( Left(cListCpo,Len(cListCpo)-1) ) +"}" )

Return( cListCpo )


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Rs150Inver³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 30/05/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao executada na EnchoiceBar			                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                           				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³RSPA090 - Agenda coletiva                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Rs150Invert()
Local nx		:= 0
Local nRecTRX	:= (cAliasTRX)->( RecCount() )
Local aSaveArea	:= GetArea()
Local lVldMrkPE := .T.

	For nx := 1 To nRecTRX
		(cAliasTRX)->( DbGoto(nx) )

		If lRs050Sel
			lVldMrkPE := ExecBlock("RS050SEL", .F., .F., {cAliasTRX})
		EndIf

		If lVldMrkPE
			(cAliasTRX)->( RecLock(cAliasTRX,.F.) )
			(cAliasTRX)->TRX_CHECK := Iif( (cAliasTRX)->TRX_CHECK, .F., .T. )
			(cAliasTRX)->( MsUnlock() )
		EndIf

		If lRs050Sel
			lVldMrkPE := .F.
		EndIf

	Next nx

	dbSelectArea(cAliasTRX)
	dbGotop()

	oLbx:Refresh()

RestArea(aSaveArea)

Return .T.


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Rs150Email    ³ Autor ³Emerson Grassi    ³ Data ³ 01/06/06 ³±±
±±³          ³ Rs150Email    ³ Autor ³Leandro Drumond   ³ Data ³ 16/05/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Envia e-mail de Agenda para Candidatos.			   		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Rs150Email()		                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nTipo: 1-Botao 2-Automatico			                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Rs150Email(nTipo)

Local aSaveArea 	:= GetArea()

Private cMailConta	:= SuperGetMV("MV_EMCONTA")
Private cMailServer	:= SuperGetMv("MV_RELSERV")
Private cMailSenha	:= SuperGetMV("MV_EMSENHA")

If nTipo == 1
	If !MsgYesNo( OemToAnsi(STR0051))
		Return Nil
	Else
		lEnviaMail := .F.
	EndIf
EndIf

If Empty(cMailServer)
	Help(" ",1,"SEMSMTP")//"O Servidor de SMTP nao foi configurado !!!" ,"Atencao"
	Return
EndIf

If Empty(cMailConta)
	Help(" ",1,"SEMCONTA")//"A Conta do email nao foi configurado !!!" ,"Atencao"
	Return
EndIf

If Empty(cMailSenha)
	Help(" ",1,"SEMSENHA")	//"A Senha do email nao foi configurado !!!" ,"Atencao"
	Return
EndIf

MsgRun( OemToAnsi(STR0052),"",;	//"Aguarde. Enviando Email..."
			{|| Sendmail()})

RestArea(aSaveArea)

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ SendMail    ³ Autor ³Leandro Drumond     ³ Data ³ 16/05/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Envia o e-mail para os destinatarios cadastrados.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 					                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function SendMail()

Local aSvCols		:= aClone(aCols)

Local cAssunto		:= STR0053	//"Agenda de Processo seletivo"
Local cMensagem		:= ""
Local cEmail		:= ""
Local cMsgErro		:= ""
Local cMailConta	:= SuperGetMV("MV_EMCONTA")
Local cUsuario		:= SubStr(cMailConta,1,At("@",cMailConta)-1)
Local cMailServer	:= AllTrim(SuperGetMv("MV_RELSERV"))
Local cMailSenha	:= SuperGetMV("MV_EMSENHA")
Local nMailPort		:= 0
Local nAt				:= At(":",cMailServer)

Local lMailAuth		:= SuperGetMV("MV_RHAUTEN",,.F.)
Local lUseSSL		:= SuperGetMV("MV_RELSSL",,.F.)
Local lUseTLS		:= SuperGetMV("MV_RELTLS",,.F.)

Local nX			:= 0
Local nY			:= 0
Local nErro			:= 0
Local nTamGetD 		:= Iif( nQual == 3, 1, Len(aSvGetD) )
Local nPosProc		:= GdFieldPos("QD_TPPROCE")
Local nPosData		:= GdFieldPos("QD_DATA")
Local nPosHora		:= GdFieldPos("QD_HORA")

Private oMail, oMessage

ProcRegua(nTamGetD)

oMail := TMailManager():New()

oMail:SetUseSSL(lUseSSL)

oMail:SetUseTLS(lUseTLS)

// Tratamento para usar a porta quando informada no mailserver
If nAt > 0
	nMailPort 		:= VAL(SUBSTR(ALLTRIM(cMailServer),At(":",cMailServer)+ 1,Len(ALLTRIM(cMailServer)) - nAt))
	cMailServer	:= SUBSTR(ALLTRIM(cMailServer),1,At(":",cMailServer)-1)
	oMail:Init("", cMailServer, cMailConta, cMailSenha,,nMailPort)
Else
	oMail:Init("", cMailServer, cMailConta, cMailSenha)
EndIF

nErro := oMail:SMTPConnect()

If nErro != 0
	cMsgErro := oMail:GetErrorString(nErro)
	Aviso(OemToAnsi(STR0027),OemToAnsi(STR0101) + CHR(13) + cMsgErro ,{"Ok"})	//"Atencao"###"Falha na conexão com servidor de e-mail"
	Return Nil
EndIf

If lMailAuth

	// try with account and pass
	nErro := oMail:SMTPAuth(cMailConta, cMailSenha)
	If nErro != 0

		// try with user and pass
		nErro := oMail:SMTPAuth(cUsuario, cMailSenha)
		If nErro != 0
			Aviso(OemToAnsi(STR0027),OemToAnsi(STR0101) + CHR(13) + oMail:GetErrorString(nErro) ,{"Ok"})	//"Atencao"###"Falha na conexão com servidor de e-mail"
			Return Nil
		Else
			conout("[AUTH] SUCEEDED TRY with USER() and PASS()")
		EndIf
	Else
		conout("[AUTH] SUCEEDED TRY with ACCOUNT and PASS")
	EndIf
EndIf

oMessage := TMailMessage():New()

For ny := 1 To nTamGetD //Numero de Candidatos

	IncProc()

	(cAliasTRX)->(dbGoto(ny))

	dbSelectArea("SQG")
	dbSetOrder(1)
	dbSeek(xFilial("SQG")+(cAliasTRX)->TRX_CURRIC)
	cEmail	:= SQG->QG_EMAIL

	If Empty(cEmail)
		Aviso(OemToAnsi(STR0027),OemToAnsi(STR0077+ ": " + (cAliasTRX)->TRX_NOME),{"Ok"})	//"Atencao"###"Nao foi informado o email do destinatario "
		Loop
	EndIf

	If (nQual == 6 .Or. nQual == 7) .And. !(cAliasTRX)->TRX_CHECK
		Loop
	EndIf

	If nQual != 3 //Candidato
		aCols 	:= aClone(aSvGetd[ny][2])
	EndIf

	//Lay-out do e-mail
	cMensagem := '<html><title>'+cAssunto+'</title><body>'
	cMensagem += '<table borderColor="#0099cc" height="29" cellSpacing="1" width="645" borderColorLight="#0099cc" border=1>'
	cMensagem += '<tr><td borderColor="#0099cc" borderColorLight="#0099cc" align="left" width="606"'
	cMensagem += 'borderColorDark=v bgColor="#0099cc" height="1">'
	cMensagem += '<p align="center"><FONT face="Arial" color="#ffffff" size="4">'
	cMensagem += '<b>'+OemToAnsi(cAssunto)+'</b></font></p></td></tr>'
	cMensagem += '<tr><td align="left" width="606" height="32"><b><FONT face="Arial" color="#0099cc" size="2">' + OemtoAnsi(STR0004) +": "+ '</FONT></b><FONT face="Arial" color="#666666" size="2">' + (cAliasTRX)->TRX_NOME + '</FONT><br></td>'

	cMensagem += '<tr><td>'
	cMensagem += '<table width="100%"  border="1" cellspacing="2" cellpadding="2">'
	cMensagem += '<tr>'
	cMensagem += '<td><b><FONT face="Arial" color="#0099cc" size="2">'+ STR0054 + '</FONT></b></td>'
	cMensagem += '<td><b><FONT face="Arial" color="#0099cc" size="2">'+ STR0055 + '</FONT></b></td>'
	cMensagem += '<td><b><FONT face="Arial" color="#0099cc" size="2">'+ STR0056 + '</FONT></b></td>'
	cMensagem += '</tr>'

	For nx := 1 To Len(aCols)
		cMensagem += '<tr>'
		cMensagem += '<td><FONT face="Arial" color="#666666" size="2">&nbsp;' + FDesc("SX5", "R9"+aCols[nx][nPosProc], "X5_DESCRI") + '</FONT></td>'
		cMensagem += '<td><FONT face="Arial" color="#666666" size="2">&nbsp;' + Dtoc(aCols[nx][nPosData]) + '</FONT></td>'
		cMensagem += '<td><FONT face="Arial" color="#666666" size="2">&nbsp;' + aCols[nx][nPosHora] + '</FONT></td>'
		cMensagem += '</tr>'
	Next nx

	cMensagem += '</table></td></tr>'
	cMensagem += +'</table></body></html>'
    //---

	//Limpa o objeto
	oMessage:Clear()
	//Popula com os dados de envio
	oMessage:cFrom 		:= cMailConta
	oMessage:cTo 		:= cEmail
	oMessage:cCc 		:= ""
	oMessage:cBcc 		:= ""
	oMessage:cSubject 	:= cAssunto
	oMessage:cBody 		:= cMensagem

	//Envia o e-mail
	nErro := oMessage:Send( oMail )

	If !(nErro == 0)
		cMsgErro := oMail:GetErrorString(nErro)
		Aviso(OemToAnsi(STR0027),"Falha no envio do e-mail. Erro retornado: " + CHR(13) + cMsgErro,{"OK"})
	EndIf

Next nY

//Desconecta do servidor
oMail:SmtpDisconnect()

If nQual != 3 //Candidato
	aCols := Aclone(aSvCols)
EndIf

Return Nil

/*ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Rs150First  ³ Autor ³ Eduardo Ju         ³ Data ³ 27.11.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria o arquivo temporario do listbox                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Rs150First()

Local nI 		:= 0
Local cCpos		:= GetNewPar("MV_RSPAGEN","")	//Criar Parametro
Local aCpos		:= &("{"+cCpos+"}")
Local aListCab	:= {"",;						//Check-box
	    			OemtoAnsi(STR0018),;		//"NOME"
					OemtoAnsi(STR0019),;		//"CURRIC"
					OemtoAnsi(STR0020)}			//"FILIAL"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Obter campos definidos pelo usuario para mostrar na Agenda ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder(2)
For nI := 1 To Len(aCpos)
	If Left(aCpos[nI],3) == "QG_" .And. dbSeek(aCpos[nI])
		Aadd( aInfo, {	aCpos[nI],;							//Campo
			 		  	AllTrim(Upper(X3Titulo())),;		//Titulo
			 			X3_TIPO,;							//Tipo
			 			X3_TAMANHO,;						//Tamanho
			 			X3_DECIMAL} ) 						//Decimal
	EndIf
Next nI

For nI := 1 to Len(aInfo)
	Aadd( aListCab, aInfo[nI][2] )
Next nI
Aadd( aInfo,{ "TRX_CHECK","","L",1,0} )	//Inclui Check-box

Rs150Cria(nQual)

dbSelectArea(cAliasTRX)
dbGotop()

Return(aListCab)

/*ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Rs150Next   ³ Autor ³ Eduardo Ju         ³ Data ³ 27.11.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria o arquivo temporario do listbox                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Rs150Next()

Local nx		:= 0
Local aListCab	:= {"",;						//Check-box
	    			OemtoAnsi(STR0018),;		//"NOME"
					OemtoAnsi(STR0019),;		//"CURRIC"
					OemtoAnsi(STR0020)}			//"FILIAL"
Local nCount	:= 0
Local nLimite	:= 0

aSvGetd	:= {}

dbSelectArea("SQG")
dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Obter numero de registros desta vaga ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nRec := SQG->( RecCount() )


ProcRegua(0)

dbGotop()
While !Eof()

	nlimite:=Len(aSvGetd)/10

    If (nCount == 0) .or. ( nCount >  nlimite )
		IncProc(STR0016+SQG->QG_NOME)	//Cod.Curriculo: "
        nCount:= 0
    Endif



  	If !Empty(cFiltroSQG) .And. !(&cFiltroSQG)
		dbSkip()
		Loop
	EndIf
	If (Len(aSvGetd))> 31999
		MsgInfo(OemtoAnsi(		STR0096+CRLF+; //"Quantidade de Curriculos nao suportada"
								STR0097+CRLF+; //Serao exibidos somente os 32000 curriculos iniciais".
								STR0098+CRLF;  //"Aplique um filtro mais restritivo".
							);
				)

		Exit
	Endif

    nCount++

	dbSelectArea(cAliasTRX)
	RecLock(cAliasTRX,.T.)
		(cAliasTRX)->TRX_NOME   := SQG->QG_NOME
		(cAliasTRX)->TRX_CURRIC := SQG->QG_CURRIC
		(cAliasTRX)->TRX_FILIAL := SQG->QG_FILIAL

		For nx := 1 to Len(aInfo)
			If aInfo[nx][1] != "TRX_CHECK"
				&( "(cAliasTRX)->"+(aInfo[nx][1]) ) := &( "SQG->"+(aInfo[nx][1]) )
			EndIf
		Next nx

	MsUnlock()

    Aadd(aSvGetd,{SQG->QG_FILIAL+SQG->QG_CURRIC,aCols})

	dbSelectArea("SQG")
	dbSetOrder(1)
	dbSkip()
EndDo

If (cAliasTRX)->( RecCount() ) == 0
	Aviso(OemToAnsi(STR0027), OemToAnsi(STR0048), {"Ok"})	//"Atencao"###"Nao foi encontrado nenhum candidato para o filtro informado."
	Return .F.
EndIf

dbSelectArea(cAliasTRX)
dbGotop()

Return(aListCab)

/*ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Rs150RecAC³ Autor ³ Eduardo Ju            ³ Data ³ 29.11.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gravacao da Agenda Coletiva                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA150 - Agendamento Coletivo pela Rotina Agenda          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Rs150RecAC(lSendEmail,nOpcSub)

Local nx		:= 0
Local ni		:= 0
Local nOrder	:= RetOrdem( "SQD", "QD_FILIAL+QD_CURRIC" )
Local nOrderAux := RetOrder( "SQD", "QD_FILIAL+QD_VAGA+QD_CURRIC" )
Local cChave	:= ""
Local nPosData	:= GdFieldPos("QD_DATA")
Local nPosVaga  := GdFieldPos("QD_VAGA")
Local nPosProc  := GdFieldPos("QD_TPPROCE")
Local nCont		:= 0

DEFAULT nOpcSub := 1

dbSelectArea(cAliasTRX)
dbGotop()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega Regua Processamento	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ProcRegua((cAliasTRX)->(RecCount()))

//Ordena aCols por codigo de vaga + processo
aSort(aCols,,,{|x,y| x[nPosVaga]+x[nPosProc] < y[nPosVaga]+y[nPosProc]})

While !(cAliasTRX)->(Eof())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Move Regua Processamento   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    IncProc(STR0069)	//"Gravando Agenda..."

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o candidato foi selecionado ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If !(cAliasTRX)->TRX_CHECK
       (cAliasTRX)->(dbSkip())
       Loop
    EndIf

    nCont++
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Deletar as agendas do candidato  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cChave := cFilKey+(cAliasTRX)->TRX_CURRIC
	dbSelectArea("SQD")
	dbSetOrder(nOrder)
	dbSeek(cChave)

	//Apaga todos os registros da agenda do candidato
	If nOpcSub == 1
		While !Eof() .And.Eval({|| SQD->QD_FILIAL+SQD->QD_CURRIC}) == cChave
			RecLock("SQD",.F.)
				dbDelete()
			MsUnlock()
			dbSkip()
		EndDo
	EndIf

	cVagaAux := aCols[1][nPosVaga]
	For nx := 1 To Len(aCols)
		// Deletado .or. com data em branco nao grava
		If !aCols[nx][Len(aCols[nx])] .and. !Empty(aCols[nx][nPosData])
			//Se for para deletar somente os registros referentes a vaga do candidato
			If nOpcSub == 2 .AND. (nX == 1 .OR. cVagaAux != aCols[nX][nPosVaga])
				cChave := cFilKey+aCols[nX][nPosVaga]+(cAliasTRX)->TRX_CURRIC
				dbSetOrder(nOrderAux)
				dbSeek(cChave)
				While !Eof() .And.Eval({|| SQD->QD_FILIAL+SQD->QD_VAGA+SQD->QD_CURRIC}) == cChave
					//Se processo tiver sido finalizado, nao apaga.
					If SQD->QD_OK != "S"
						RecLock("SQD",.F.)
							dbDelete()
						MsUnlock()
					EndIf
					dbSkip()
				EndDo
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Gravacao dos campos do Header no SQG  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RecLock("SQD",.T.)
			For ni = 1 to Len(aHeader)
				If aHeader[ni][10] <> "V"
					SQD->(FieldPut(FieldPos(aHeader[nI][2]),aCols[nX][nI]))
				EndIf
			Next ni
			SQD->QD_FILIAL := cFilKey
			SQD->QD_CURRIC := (cAliasTRX)->TRX_CURRIC
			MsUnlock()
		EndIf

		dbSelectArea("SQD")
		dbSetOrder(nOrder)
		cVagaAux := aCols[nX][nPosVaga]
	Next nx

	dbSelectArea(cAliasTRX)
	dbSkip()
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Enviar E-mail             	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lSendEmail
	Rs150WizaMail()
EndIf

If nCont <> 0
	Aviso(OemToAnsi(STR0085),OemToAnsi(STR0086)+Space(1)+ Alltrim(Str(nCont))+Space(1)+OemToAnsi(STR0087),{"OK"})	//#"Gravação Concluída"#"Foram gravados X"#"candidatos para o Agendamento Coletivo"
Else
	Aviso(OemToAnsi(STR0027),OemtoAnsi(STR0084),{"OK"})	//"Atenção"#"Não foram selecionados candidatos para o Agendamento Coletivo"
EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Rs150Select   ³ Autor ³Eduardo Ju        ³ Data ³ 06/12/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³DescricaO ³ Seleciona Todos                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Rs150Select(lTodos)                                        ³±±
±±³          ³            lTodos         .T. Seleciona Todos Candidatos.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Rs150Select(lTodos)
Local aSaveArea	:= GetArea()
Local lVldMrkPE	:= .T.

	(cAliasTRX)->(dbGotop())
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega Regua Processamento	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcRegua((cAliasTRX)->(RecCount()))

	While !(cAliasTRX)->(Eof())

		If lRs050Sel
			lVldMrkPE := ExecBlock("RS050SEL", .F., .F., {cAliasTRX})
		EndIf

		If lVldMrkPE
			(cAliasTRX)->( RecLock(cAliasTRX,.F.) )
			(cAliasTRX)->TRX_CHECK := IIF(lTodos,.T.,.F.)
			(cAliasTRX)->(MsUnlock())
		EndIf

		If lRs050Sel
			lVldMrkPE := .F.
		EndIf

	   (cAliasTRX)->(dbSkip())
	EndDo


	(cAliasTRX)->( dbGotop() )

	oLbx:Refresh()

RestArea(aSaveArea)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Rs150WizaMail ³ Autor ³Eduardo Ju        ³ Data ³ 06/12/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Envia e-mail da Agenda para Candidatos.			   		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Rs150WizaMail()                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Rs150WizaMail()

Local cAssunto		:= STR0053	//"Agenda de Processo seletivo"
Local cMensagem		:= ""
Local cEmail		:= ""
Local nX			:= 0
Local nP			:= 0
Local nErro			:= 0
Local nPosProc		:= GdFieldPos("QD_TPPROCE")
Local nPosData		:= GdFieldPos("QD_DATA")
Local nPosHora		:= GdFieldPos("QD_HORA")
Local nPosVaga 		:= GdFieldPos("QD_VAGA")
Local nPosDVaga 	:= GdFieldPos("QD_DVAGA")
Local aLogTitle		:= {}
Local aLog			:= {}
Local aError		:={	STR0074 ,;	//"O Servidor de SMTP nao foi configurado"
						STR0075 ,;	//"A Conta do e-mail não foi configurada"
						STR0076 ,;	//"A Senha do e-mail não foi configurada"
						STR0077 ,;	//"Não foi informado o e-mail do destinatário"
						STR0078 }	//"Erro no envio de e-mail."
Local cTitulo		:= OemToAnsi(STR0082) //"Log Ocorrências - Agendamento Coletivo (Envia E-mail)"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Arquivo Log: Definicao do Processo Seletivo	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aLog ,OemToAnsi(STR0054) + Space(14) + OemToAnsi(STR0089) + Space(34) + OemToAnsi(STR0055) + Space(5) + OemToAnsi(STR0056))	//Item do Processo#Data"Horário
For nP := 1 To Len(aCols)
	aAdd(aLog ,PadR(FDesc("SX5", "R9"+aCols[nP][nPosProc], "X5_DESCRI"),30)+Space(1)+aCols[nP][nPosVaga]+ Space(1) + PadR(aCols[nP][nPosDVaga],31) + Dtoc(aCols[nP][nPosData])+ Space(1) + aCols[nP][nPosHora])
Next nP

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Arquivo Log: Candidatos  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aLog ,"")
aAdd(aLog ,OemToAnsi(STR0004)+Space(30)+OemToAnsi(STR0083)+Space(22)+OemToAnsi(STR0079))	//"Candidato"#"Telefone"#"Status do Envio por-Email"

dbSelectArea(cAliasTRX)
dbGotop()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega Regua Processamento	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ProcRegua((cAliasTRX)->(RecCount()))

While !(cAliasTRX)->(Eof())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Move Regua Processamento   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    IncProc(STR0080)	//"Preparando e-mail para envio..."
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o candidato foi selecionado ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If !(cAliasTRX)->TRX_CHECK
       (cAliasTRX)->(dbSkip())
       Loop
    EndIf
	dbSelectArea("SQG")
	dbSetOrder(1)
	dbSeek(xFilial("SQG")+(cAliasTRX)->TRX_CURRIC)
	cEmail	:= SQG->QG_EMAIL

	cMensagem := '<html><title>'+cAssunto+'</title><body>'
	cMensagem += '<table borderColor="#0099cc" height="29" cellSpacing="1" width="645" borderColorLight="#0099cc" border=1>'
	cMensagem += '<tr><td borderColor="#0099cc" borderColorLight="#0099cc" align="left" width="606"'
	cMensagem += 'borderColorDark=v bgColor="#0099cc" height="1">'
	cMensagem += '<p align="center"><FONT face="Arial" color="#ffffff" size="4">'
	cMensagem += '<b>'+OemToAnsi(cAssunto)+'</b></font></p></td></tr>'
	cMensagem += '<tr><td align="left" width="606" height="32"><b><FONT face="Arial" color="#0099cc" size="2">' + OemtoAnsi(STR0004) +": "+ '</FONT></b><FONT face="Arial" color="#666666" size="2">' + (cAliasTRX)->TRX_NOME + '</FONT><br></td>'

	cMensagem += '<tr><td>'
	cMensagem += '<table width="100%"  border="1" cellspacing="2" cellpadding="2">'
	cMensagem += '<tr>'
	cMensagem += '<td><b><FONT face="Arial" color="#0099cc" size="2">'+ STR0054 + '</FONT></b></td>'
	cMensagem += '<td><b><FONT face="Arial" color="#0099cc" size="2">'+ STR0055 + '</FONT></b></td>'
	cMensagem += '<td><b><FONT face="Arial" color="#0099cc" size="2">'+ STR0056 + '</FONT></b></td>'
	cMensagem += '</tr>'

	For nx := 1 To Len(aCols)
		cMensagem += '<tr>'
		cMensagem += '<td><FONT face="Arial" color="#666666" size="2">&nbsp;' + FDesc("SX5", "R9"+aCols[nx][nPosProc], "X5_DESCRI") + '</FONT></td>'
		cMensagem += '<td><FONT face="Arial" color="#666666" size="2">&nbsp;' + Dtoc(aCols[nx][nPosData]) + '</FONT></td>'
		cMensagem += '<td><FONT face="Arial" color="#666666" size="2">&nbsp;' + aCols[nx][nPosHora] + '</FONT></td>'
		cMensagem += '</tr>'
	Next nx

	cMensagem += '</table></td></tr>'
	cMensagem += +'</table></body></html>'

	MsgRun( OemToAnsi(STR0052),"",;	//"Aguarde. Enviando Email..."
			{||nErro := Rh_Email(cEmail,,cAssunto,cMensagem)})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Arquivo Log: Detalhes   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aLog,(cAliasTRX)->TRX_CURRIC+Space(1)+PadR((cAliasTRX)->TRX_NOME,30)+Space(2)+If(!Empty(SQG->QG_FONE),PadR(SQG->QG_FONE,20),Space(20))+Space(5)+Space(5)+If(nErro == 0,STR0081,aError[nErro]))//"E-mail enviado com Sucesso"

	(cAliasTRX)->(dbSkip())
EndDo

If Len(aLog) > 1
	FMakeLog( { aLog } , aLogTitle , , NIL , NIL , cTitulo,"M","P",,.F. )
EndIf

Return

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ MenuDef		³Autor³  Luiz Gustavo     ³ Data ³09/01/2007³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Isola opcoes de menu para que as opcoes da rotina possam    ³
³          ³ser lidas pelas bibliotecas Framework da Versao 9.12 .      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³RSPA150                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

Static Function MenuDef()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa 	 ³
//³ ----------- Elementos contidos por dimensao ------------	 ³
//³ 1. Nome a aparecer no cabecalho 							 ³
//³ 2. Nome da Rotina associada 								 ³
//³ 3. Usado pela rotina										 ³
//³ 4. Tipo de Transa‡„o a ser efetuada 						 ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados			 ³
//³    2 - Simplesmente Mostra os Campos						 ³
//³    3 - Inclui registros no Bancos de Dados					 ³
//³    4 - Altera o registro corrente							 ³
//³    5 - Remove o registro corrente do Banco de Dados 		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aRotina := {	{ STR0001,"AxPesqui" , 0 , 1,,.F.},;		//"Pesquisar"
						{ STR0004,"Rs150Cand", 0 , 4},;		//"Candidato"
						{ STR0002,"Rs150Cons", 0 , 4},; 	//"Pes&quisa"
						{ STR0003,"Rs150Data", 0 , 4},; 	//"Cons.por &Data"
						{ STR0005,"Rs150Vaga", 0 , 4},;		//"Cons.por &Vaga"
						{ STR0025,"Rs150Func", 0 , 3},;		//"Funcionario"
						{ STR0026,"Rs150Cand", 0 , 5},;		//"Exclusao"
						{ STR0024,"Rsp010Leg", 0 , 3,,.F.},;		//"Legenda"
					   	{ STR0042,"Rs150Wiza", 0 , 4}}		//"Agend.Coletiva"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada para incluir outras opcoes no Menu.                                ³
//³Variaveis que podem ser Usadas                                                      ³
//³aRotina = Opcoes menu 												               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("RSP150ME")
   ExecBlock("RSP150ME",.F.,.F.)
Endif

Return aRotina

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Rs150DTProc³ Autor ³ Eduardo Ju           ³ Data ³ 19.10.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Conteudo do Inicializador Padrao do campo QD_DTPROC.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³RSPA150                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Rs150DTProc()

Local aSaveArea := GetArea()
Local cDTProc	:= ""

If !Inclui
	cDTProc := FDESC("XR9","R9"+SQD->QD_TPPROCE,"X5_DESCRI")
EndIf

RestArea(aSaveArea)

Return cDTProc

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Rs150Descri³ Autor ³ Eduardo Ju           ³ Data ³ 22.10.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Conteudo do Inicializador Padrao do campo QD_DESCRIC.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³RSPA150                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Rs150Descri()

Local aSaveArea := GetArea()
Local cDescri	:= ""

If !Inclui
	cDescri := FDESC("SQQ",SQD->QD_TESTE,"QQ_DESCRIC")
EndIf

RestArea(aSaveArea)

Return cDescri

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Rs150Dresul³ Autor ³ Eduardo Ju           ³ Data ³ 22.10.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Conteudo do Inicializador Padrao do campo QD_DRESULT.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³RSPA150                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Rs150Dresul()

Local aSaveArea := GetArea()
Local cDresult	:= ""

If !Inclui
	cDresult := FDESC("XRA","RA"+SQD->QD_RESULTA,"X5_DESCRI")
EndIf

RestArea(aSaveArea)

Return cDresult

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fVldExclu	 ³ Autor ³ Luis Artuso          ³ Data ³19.10.15  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se e' possivel excluir um registro                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³RSPA150	                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function fVldExclu()

	Local lRet	:=	.F.

	//Se preenchidos: QD_TESTE e QD_RESULTA ou QD_TESTE e QD_OK, nao permite a exclusão do agendamento.

	lRet	:=	( ((!Empty(SQD->(QD_TESTE))) .AND. (!Empty(SQD->(QD_RESULTA)))) .OR. ;
				((!Empty(SQD->(QD_TESTE))) .AND. (!Empty(SQD->(QD_OK)))) )

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fVldDelaCols ³ Autor ³ Luis Artuso         ³ Data ³22.10.15³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se e' possivel excluir um registro do aCols.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³RSPA150	                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function fVldDelaCols()

	Local nPosTest 	:= GdFieldPos("QD_TESTE")
	Local nPosResu	:= GdFieldPos("QD_RESULTA")
	Local nPosOk	:= GdFieldPos("QD_OK")

	Local lExiste	:= .F.
	Local lApaga	:= .F.

	lExiste	:=	( ((!Empty(aCols[n,nPosTest])) .AND. (!Empty(aCols[n,nPosResu]))) .OR. ;
				( (!Empty(aCols[n,nPosTest])) .AND. (!Empty(aCols[n,nPosOk])) ) )


	If ( lExiste )

		/*Adicionado o seguinte tratamento variavel 'nCountMsg'. Ao executar a validacao, o metodo e' chamado duas vezes por rotinas do framework.
		Como um aviso deve ser emitido se nao puder excluir o registro, cria-se a variavel nCountMsg como Static para ficar visivel durante a
		execucao do codigo. Na primeira vez que efetuar a validacao, exibe o aviso, acumula-se o contador das demais validacoes para garantir
		que o aviso seja mostrado apenas uma vez.
		*/
		nCountMsg++

		If nCountMsg > 2
			nCountMsg	:= 1
		EndIf

		If (nCountMsg == 1)
			MsgAlert(STR0107) //"Este registro não pode ser excluído."
		EndIf

	Else

		lApaga	:= .T.

	EndIf

Return lApaga





/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LerCSV        ºAutor  ³Oswaldo L.   º Data ³ 30/08/2017     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ler CSV escolhido. A geração de CSV passou a ser feita apos º±±
±±º          ³Proj.Soyuz com autorização do frame                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function LerCSV ()
Local aLstRegs    := {}
Local cSeparador  := ";"
Local nLinha      := 0
Local nCont       := 1
Local aLstIndices := {}
Local aCampos     := {}
Local cGrvCampo   := ''
Private aEstru    := {}
Private aCSVCabec := {}

FT_FUse( cCsvFile )//Abre o Arquivo
FT_FGoTop()

while !FT_FEof()
	nLinha += 1

    If nLinha == 1//cabeçalho
    	aCSVCabec :=  Separa( Substr(FT_FReadLn(),1,Len(FT_FReadLn())) ,cSeparador )
    	CriaTempDoCSV()//cria temporario
    Else
    	If oArqTRBTmp <> Nil //insere dados do CSV no temporário
    		aLstRegs :=  Separa( Substr(FT_FReadLn(),1,Len(FT_FReadLn())) ,cSeparador )

    		If Len(aLstRegs) > 0

    			dbselectarea('TRB')

	    		Reclock('TRB',.T.)
		    	For nCont := 1 to Len(aEstru)
					cGrvCampo     := "TRB->("  + AllTrim(aEstru[nCont][1]) + ")"

					If aEstru[nCont][2] $ "L"
						If aLstRegs[nCont] == "0"
							&cGrvCampo    := .F.
						Else
							&cGrvCampo    := .T.
						EndIf
					End

					If aEstru[nCont][2] $ "D"
						&cGrvCampo    := ctod(aLstRegs[nCont])
					EndIf

					If !(aEstru[nCont][2] $ "L|D")

						If (aEstru[nCont][2]) == "N"
							nCont := nCont
							&cGrvCampo    := Val(aLstRegs[nCont])
						Else
							&cGrvCampo    := aLstRegs[nCont]
						EndIf

					EndIf
				Next
		    	MsUnLock()
	    	EndIf
    	EndIf
    EndIf

    FT_FSkip()
End

FT_FUse()

return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CriaTempDoCSV ºAutor  ³Oswaldo L.   º Data ³ 30/08/2017     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cria temporaria com base no CSV lido                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static function CriaTempDoCSV()
Local nCOnt   := 1
Local i
Local aCampos := {}

For nCont := 1 to Len(aCSVCabec)

	dbSelectArea("SX3")
	dbSetOrder(2)
	If !(aCSVCabec[nCont] $ "SEL|CURRIC|NOME|FONE|VAGA") ; //arquivos da rspa090 tem estes campos sempre fixos no inicio
		.And. dbSeek(aCSVCabec[nCont])
		Aadd(aCampos,{	aCSVCabec[nCont],;
						SX3->X3_TAMANHO,;
						SX3->X3_DECIMAL,;
						SX3->X3_TIPO})
	EndIf
Next

If Len(aCSVCabec) > 0
	// Campos fixos do Arquivo
	aEstru:={}
	Aadd(aEstru, { "SEL"	,"L",01, 0 } )
	Aadd(aEstru, { "CURRIC" ,"C",06, 0 } )
	Aadd(aEstru, { "NOME" 	,"C",40, 0 } )
	Aadd(aEstru, { "FONE"	,"C",40, 0 } )
	Aadd(aEstru, { "VAGA"	,"C",06, 0 } )


	// Campos diferentes de Memo
	For i:=1 To Len(aCampos)
		If aCampos[i][4] != "M"	.and. !("RS6_" $ aCampos[i][1])	//Separar memos para adicionar no final, devido Linux colocar memos por ultimo no arquivo Temporario TRB
			cCampo := AllTrim(aCampos[i][1])
			If Ascan(aEstru,{|x| AllTrim(x[1]) == cCampo}) == 0
				Aadd(aEstru,{cCampo ,aCampos[i][4],aCampos[i][2],aCampos[i][3]})

			EndIf
		EndIf
	Next i

	// Campos Memos
	For i:=1 To Len(aCampos)
		If aCampos[i][4] == "M" .and. !("RS6_" $ aCampos[i][1])	//Separar memos para adicionar no final, devido Linux colocar memos por ultimo no arquivo Temporario TRB
			cCampo := AllTrim(aCampos[i][1])
			If Ascan(aEstru,{|x| AllTrim(x[1]) == cCampo}) == 0
				Aadd(aEstru,{cCampo ,aCampos[i][4],aCampos[i][2],aCampos[i][3]})

			EndIf
		EndIf
	Next i

    aLstIndices := {}

    AAdd( aLstIndices, {"CURRIC"})
    AAdd( aLstIndices, {"NOME"})
    oArqTRBTmp := RhCriaTrab('TRB', aEstru, aLstIndices)
    TRB->(DbSetOrder(1))
EndIf

return




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CriaTemp ºAutor  ³Oswaldo L.   º Data ³ 30/08/2017     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cria temporaria com base no arq lido                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ RSPA150                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static function CriaTemp()
Local nCont      := 1
Local i          := 0
Local cCampo     := ""
Local cCabecalho := ""
Local cItemReg   := ""
Local aCampos    := {}
Local aCabec     := {}
Local aItem      := {}
Local cGrvCampo  := ""
Local aEstru     := {}
Local aLstIndices:= {}

aEstru:={}

dbSelectArea('RT1')
RT1->(DbSetOrder(1))
RT1->(DbSeek( Fwxfilial('RT1') + "RSPA090   " + cNomeTab  + "S"  ))

If RT1->(!Eof()) .And. AllTrim(RT1->(RT1_FILIAL+RT1_TELA+RT1_PERG + "S")) == AllTrim(Fwxfilial('RT1') + "RSPA090   " + cNomeTab + "S")

	cCabecalho := RHMSMM(RT1->RT1_CODM,,,,  ,,,,,,, 'RT1')
	aCabec     := StrTokArr(cCabecalho,";")

	If Len(aCabec) > 0

		// Campos fixos do Arquivo
		Aadd(aEstru, { "SEL"	,"L",01, 0 } )
		Aadd(aEstru, { "CURRIC" ,"C",06, 0 } )
		Aadd(aEstru, { "NOME" 	,"C",40, 0 } )
		Aadd(aEstru, { "FONE"	,"C",40, 0 } )
		Aadd(aEstru, { "VAGA"	,"C",06, 0 } )

		For nCont := 1 to Len(aCabec)

			dbSelectArea("SX3")
			dbSetOrder(2)
			If !(aCabec[nCont] $ "SEL|CURRIC|NOME|FONE|VAGA") ; //arquivos da rspa090 tem estes campos sempre fixos no inicio
				.And. dbSeek(aCabec[nCont])
				Aadd(aCampos,{	aCabec[nCont],;
								SX3->X3_TAMANHO,;
								SX3->X3_DECIMAL,;
								SX3->X3_TIPO})
			EndIf
		Next

		// Campos diferentes de Memo
		For i := 1 To Len(aCampos)
			If aCampos[i][4] != "M"	.and. !("RS6_" $ aCampos[i][1])	//Separar memos para adicionar no final, devido Linux colocar memos por ultimo no arquivo Temporario TRB
				cCampo := AllTrim(aCampos[i][1])
				If Ascan(aEstru,{|x| AllTrim(x[1]) == cCampo}) == 0
					Aadd(aEstru,{cCampo ,aCampos[i][4],aCampos[i][2],aCampos[i][3]})
				EndIf
			EndIf
		Next i

		// Campos Memos
		For i := 1 To Len(aCampos)
			If aCampos[i][4] == "M" .and. !("RS6_" $ aCampos[i][1])	//Separar memos para adicionar no final, devido Linux colocar memos por ultimo no arquivo Temporario TRB
				cCampo := AllTrim(aCampos[i][1])
				If Ascan(aEstru,{|x| AllTrim(x[1]) == cCampo}) == 0
					Aadd(aEstru,{cCampo ,aCampos[i][4],aCampos[i][2],aCampos[i][3]})
				EndIf
			EndIf
		Next i

	    aLstIndices := {}

	    AAdd( aLstIndices, {"CURRIC"})
	    AAdd( aLstIndices, {"NOME"})

	    oArqTRBTmp := RhCriaTrab('TRB', aEstru, aLstIndices)
	    TRB->(DbSetOrder(1))

	    If oArqTRBTmp != Nil
			dbSelectArea('RT1')
			RT1->(DbSetOrder(1))
			RT1->(DbSeek( Fwxfilial('RT1') + "RSPA090   " + cNomeTab  + "N"  ))

			While RT1->(!Eof()) .And. AllTrim(RT1->(RT1_FILIAL+RT1_TELA+RT1_PERG+RT1_HEAD) ) == AllTrim(Fwxfilial('RT1') + "RSPA090   " + cNomeTab + "N")

				cItemReg := RHMSMM(RT1->RT1_CODM,,,,  ,,,,,,, 'RT1')

				aItem    := StrTokArr2(cItemReg,";",.T.)

				//==========================
				dbselectarea('TRB')

	    		Reclock('TRB',.T.)

		    	For nCont := 1 to Len(aEstru)
					cGrvCampo     := "TRB->("  + AllTrim(aEstru[nCont][1]) + ")"

					If aEstru[nCont][2] $ "L"
						If aItem[nCont] == "0"
							&cGrvCampo    := .F.
						Else
							&cGrvCampo    := .T.
						EndIf
					End

					If aEstru[nCont][2] $ "D"
						&cGrvCampo    := ctod(aItem[nCont])
					EndIf

					If !(aEstru[nCont][2] $ "L|D")

						If (aEstru[nCont][2]) == "N"
							&cGrvCampo    := Val(aItem[nCont])
						Else
							&cGrvCampo    := aItem[nCont]
						EndIf

					EndIf
				Next

		    	MsUnLock()

				//===========================
				RT1->(DbSkip())
			End
		EndIf
	EndIf
EndIf

return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ TelaSelecao ºAutor  ³Oswaldo L                   ³  19/10/17    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡…o ³ Selecao da tabela existente                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³                                                                 ³±±
±±³          ³                                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA150                                                         ³±±
±±ÌÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

static function TelaSelecao ()
Local oDlgSel
Local cGet1    := space(TamSx3("RT1_PERG")[1])
Local lMantem  := .T.
Local lRet     := .F.
Local lIniciar := .T.
Local aPesquisa	:= {}
Local nPesq		:= 0
Local cvar		:= ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaração de arrays para dimensionar tela		             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local cRT1Alias     := GetNextAlias()


While lMantem

	If lIniciar
		lIniciar := .F.

		BeginSql Alias cRT1Alias
			  SELECT DISTINCT(RT1.RT1_PERG)  FROM 	%table:RT1% RT1
		       WHERE RT1.RT1_FILIAL  = %Exp:(Fwxfilial('RT1'))%
				 AND RT1.RT1_TELA    = 'RSPA090   '
				 AND RT1.%NotDel%
				 ORDER BY RT1.RT1_PERG
		EndSql

		While (cRT1Alias)->(!Eof())
			Aadd(aPesquisa, (cRT1Alias)->(RT1_PERG)  )//SQU->QU_CODIGO+" - "+SQU->QU_DESCRIC)

			(cRT1Alias)->(dbSkip())
		EndDo

		(cRT1Alias)->(dbCloseArea())

		If Len(aPesquisa) == 0
			Return .F.
		EndIf
	EndIf

	aAdvSize		:= MsAdvSize( , .T., 390)
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
	aAdd( aObjCoords , { 000 , 000 , .T. , .T., .T. } )
	aObjSize	    := MsObjSize( aInfoAdvSize , aObjCoords )

	SETAPILHA()
	DEFINE MSDIALOG oDlgSel TITLE OemtoAnsi(STR0114) FROM aAdvSize[7],0 To aAdvSize[6],aAdvSize[5]  PIXEL//"Selecione uma pesquisa"

			@ aObjSize[1,1],aObjSize[1,2] LISTBOX oPesquisa VAR cVar FIELDS HEADER OemtoAnsi(STR0113)  OF oDlgSel PIXEL SIZE aObjSize[1,3],aObjSize[1,4]-15; //"Pesquisas:"
			ON CHANGE (nPesq:=oPesquisa:nAt) ON DBLCLICK (lRet := .T.,oDlgSel:End())
			oPesquisa:SetArray(aPesquisa)
		  	oPesquisa:bLine := { || {aPesquisa[oPesquisa:nAt]}}

	ACTIVATE MSDIALOG oDlgSel ON INIT EnchoiceBar(oDlgSel, {|| lRet:= .T., oDlgSel:End()  },{|| lRet:=.F. ,oDlgSel:End()} ) CENTERED
	SETAPILHA()

	If nPesq > 0
		cGet1 := aPesquisa[nPesq]
	Else
		cGet1 := ''
	EndIf

	If lRet
		If Empty(cGet1)
			MsgInfo(OemtoAnsi(STR0115))

			lRet := .F.
		Else
			cTabEmUso  := cGet1
			lMantem := .F.
		EndIf
	Else
		lMantem := .F.
	EndIf
End

return cGet1

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ TabNovaDic ³ Autor ³ Oswaldo L      ³ Data ³ 03.10.17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Testa existência da tabela no dicionario                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³           Esta rotina cria a tabela, por isto ela nao existe no banco ³±±
±±³           neste ponto ainda. Entao, verificamos pelo dicionario.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static function TabNovaDic ()
Local lRet := .F.

If TCCanOpen(  RETSQLNAME("RT1")   )
	lRet := .T.
EndIf

return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} function AtuRH3
Funcao para verificar se existem registros na RH3 e a exclusao caso exista
@author  Gisele Nuncherino
@since   15/10/2020
/*/
//-------------------------------------------------------------------
static Function AtuRH3()

Local cQuery 	:= ''
Local lProc		:= .F.
Local cMsgEmail	:= ''
Local nErro		:= 0
Local cSqsFil	:= Nil

cQuery := "SELECT RH3.R_E_C_N_O_ AS RH3REC, RH3_FILIAL, RH3_CODIGO FROM " + RetSqlName("RH3") + " RH3 "
cQuery += "INNER JOIN " + RetSqlName("RH4") + " RH4 ON RH4_FILIAL = RH3_FILIAL AND "
cQuery += "RH4_CODIGO = RH3_CODIGO "
cQuery += "WHERE "
cQuery += "    RH4_CAMPO = 'QG_CURRIC'  AND RH4_VALNOV = '" + SQD->QD_CURRIC + "' " 
cQuery += "AND RH3_STATUS = '4'      "
cQuery += "AND RH3.D_E_L_E_T_ = '' "
cQuery += "AND RH4.D_E_L_E_T_ = '' "

cQuery := ChangeQuery(cQuery)
		
DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), "QRH3")

wHILE !QRH3->(EOF())
	RH3->(DBGOTO(QRH3->RH3REC))

	DbSelectArea("RH4")
	RH4->(DbSetOrder(1))
	IF RH4->(dbSeek(RH3->RH3_FILIAL + RH3->RH3_CODIGO))
		While RH4->(!Eof())
			lProc := .F.
			If (Alltrim(RH4->RH4_CAMPO) == "TMP_VAGA")
				cSqsFil := If(cSqsFil == Nil, xFilial("SQS"), cSqsFil)
				IF AllTrim(RH4->RH4_VALNOV) <> SQD->QD_VAGA
					lProc := .F.
				Else
					lProc := .T.
					DbSelectArea("SQS")
					SQS->(DbSetOrder(1))
					SQS->(dbSeek(cSqsFil+AllTrim(RH4->RH4_VALNOV)))
				ENDIF
				exit
			ELSE
				lProc := .F.
			EndIf
			RH4->(dbSkip())
		EndDo
	ENDIF
	If lProc
		RecLock("RH3", .F.)
			RH3->RH3_STATUS := '3' //REPROVADO
			RH3->RH3_DTATEN	:= dDataBase

			//Questiona se deseja enviar email de reprovacao
			If !Empty(SQS->QS_MSGREP) .AND. !Empty(SQG->QG_EMAIL)
				If MsgYesNo(OemToAnsi(STR0120)) //"Deseja enviar email informando a reprovação?"
					cMsgEmail	:= RHMSMM( Fdesc("RDG",SQS->QS_MSGREP,"RDG_CODMEM"),,,,,,,,,,,"RDG" )

					MsgRun( OemToAnsi(STR0121),"",;	//"Aguarde. Enviando Email..."
								{||nErro := RH_Email(Lower(Alltrim(SQG->QG_EMAIL)),'',OemToAnsi(STR0121),cMsgEmail,'','')})
					If nErro != 0
						RH_ErroMail(nErro)
					EndIf

				EndIf
			EndIf
		RH3->(MsUnLock())
		EXIT
	EndIf
	QRH3->(dbSkip())
EndDo

QRH3->(DbCloseArea())

return
