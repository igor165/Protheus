#include 'protheus.ch'
#include 'parmtype.ch'
#include "xmlxfun.ch"
#include 'gpem92001.ch'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÄÄÄÄÄÄÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ±±
±±|Funcao    | GPEM920  | Autor | Matheus Bizutti.                  | Data | 22/11/16 |±±
±±|ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ|±±
±±|Descricao | GERA XML - AUDESP                                                      |±±
±±|ÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ|±±
±±|         ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                         |±±
±±|ÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ|±±
±±|Programador | Data     | BOPS      |  Motivo da Alteracao                          |±±
±±|ÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ|±±
±±|Claudinei S.|03/04/2017|MRH-8278   |Ajustada a leitura do pergunte 07, a geração da|±±
±±|            |          |           |tag responsavelPelaEntidade somente quando o   |±±
±±|            |          |           |campo SQ3->Q3_ADRESP estiver preenchido.       |±±
±±|Jônatas A.  |04/04/2017|MRH-8278   |Ajustes na geração dos dados p/ o Documento de |±±
±±|            |          |           |Quadro de pessoal.                             |±±
±±|Claudinei S.|04/04/2017|DPAG-263/  |Implementada a geração do XML 7 - Verbas       |±±
±±|            |          |DPAG-305   |Remuneratórias, Módulo 4 - Remunerações.       |±±
±±|Claudinei S.|06/04/2017|MRH-8677/  |Implementada a geração do XML 8 - Folha        |±±
±±|            |          |DPAG-307   |Ordinária, Módulo 4 - Remunerações.            |±±
±±|Claudinei S.|06/04/2017|MRH-8677/  |Implementada a geração do XML 9 - Pagamento da |±±
±±|            |          |DPAG-529   |Folha Ordinária, Módulo 4 - Remunerações.      |±±
±±|Jônatas A.  |06/04/2017|MRH-8677/  |Implementada a geração do XML 0 - Resumo Mensal|±±
±±|            |          |DPAG-425   |da Folha de Pagamento, módulo 4 fase III.      |±±
±±|Claudinei S.|10/05/2017|DRHPAG-1647|Implementada a geração do XML 0 - Resumo Mensal|±±
±±|            |          |DRHPAG-1646|da Folha de Pagamento, módulo 4 fase III.      |±±
±±|Claudinei S.|19/09/2017|DRHESOCP-904|Liberação de uso rotina somente se MV_AUDESP  |±±
±±|            |          |            |estiver ativo.                                |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/

Function GPEM920()

Local bProcesso		:= { |oSelf| GPM920Proc( oSelf ) }
Local cPerg			:= "GPM920"
Local cMsg			:= ""
Local cMsg1			:= ""
Local oProc			:= Nil
Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), {.T.,.F.})//Tratamento de acesso a dados pessoais
Local aFldRel		:= {"RA_NOME","RA_NOMECMP","RI6_NOME","RA_PIS","RA_CIC"}
Local lBlqAcesso	:= aOfusca[2] .And. !Empty( FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRel ) )
// - Variáveis para uso nas demais funções do programa.
Private cCadastro	:= OemToAnsi(STR0001) //AUDESP - Atos de Pessoal e Remunerações
Private nSavRec		:= RECNO()
Private aArray		:= {}
Private aCodFol		:= {}
Private cFilProc	:= "!!"
Private cVbNoValid	:= ""
Private nArq		:= ""

// - Variáveis utilizadas no tratamento de erros.
Private bErro		:= .F.			// - Controle dos Dados da Filial
Private aLog		:= {}			// - Log para impressao
Private aTotRegs	:= Array( 4 )	// - Controle do Total de Erros Encontrados
Private aTitle		:= {}			// - Controle do Relacionamento

cMsg := OemToAnsi(STR0026) 			//"Esta rotina pode ser utilizada somente por Órgãos Públicos do Estado de São Paulo, "
cMsg += OemToAnsi(STR0027) 			//" usuários do sistema Audesp -  Auditoria do Tribunal de Contas, e tem como objetivo gerar os arquivos XML,"
cMsg += OemToAnsi(STR0028) 			//" a serem exportados para o Audesp, com dados da Fase III -  Atos de Pessoal e Remunerações:" + CRLF
cMsg += OemToAnsi(STR0029) + CRLF	//"Módulos " + CRLF
cMsg += OemToAnsi(STR0030) + CRLF	//"1 – Atos Normativos" + CRLF
cMsg += OemToAnsi(STR0031) + CRLF	//"2 – Quadro de Pessoal" + CRLF
cMsg += OemToAnsi(STR0032) + CRLF	//"3 – Quadro Funcional" + CRLF
cMsg += OemToAnsi(STR0033) + CRLF	//"4 – Remunerações" + CRLF

If !SuperGetMv('MV_AUDESP',, .F.)
	Aviso(STR0023,STR0026+ CRLF + STR0027 + STR0028 + CRLF + CRLF + STR0038 ,{STR0025})	//ATENCAO"###"Esta rotina pode ser utilizada somente por Órgãos Públicos do Estado de São Paulo, "
	Return 																						//usuários do sistema Audesp -  Auditoria do Tribunal de Contas, e tem como objetivo gerar os arquivos XML,"
EndIf																								//a serem exportados para o Audesp, com dados da Fase III -  Atos de Pessoal e Remunerações:"
																									//Verifique o conteúdo do parâmetro MV_AUDESP.

If lBlqAcesso//Tratamento de acesso a Dados Sensíveis
	//"Dados Protegidos- Acesso Restrito: Este usuário não possui permissão de acesso aos dados dessa rotina. Saiba mais em {link documentação centralizadora}"
	Help(" ",1,aOfusca[3,1],,aOfusca[3,2],1,0)
	Return
EndIf

If Val(GetPvProfString( "GENERAL", "maxStringSize", "0", GetAdv97() )) < 2
	// "Para utilizar essa rotina sugerimos a configuração das chaves MaxStringSize e TopMemoMega no arquivo de configuração do TOTVS | Application Server - AppServer.ini."
	// "A configuração dessas chaves impede que, dependendo da quantidade de dados processados, ocorra o erro string size overflow."
	// "Para mais informações acesse a documentação clicando no botão abaixo." # "Documentação" # OK
	If Aviso(STR0023, STR0039 + CRLF + STR0040 + CRLF + CRLF + STR0041, {STR0042, STR0004}, 3) == 1
		OpenLink("https://tdn.totvs.com/x/oQCeCQ")
	EndIf
EndIf

// - Inicializa o Array com zeros.
aFill( aTotRegs, 0 )

// ------------------------------------------------------------
// - Colocar este trecho dentro de uma função que verifica
// - Se o compatibilizador da AUDESP foi executado.
// ------------------------------------------------------------
If CHKFILE("RS9")
	Pergunte( cPerg, .F. )

	tNewProcess():New( "GPEM920" , cCadastro , bProcesso , cMsg , "GPM920",,.T.,,,.T.,.T.  )

	If bErro
		Aviso( STR0002 , STR0003 , { STR0022 } )
		fMakeLog( aLog, aTitle,,, "XML_AUDESP_" + cEmpAnt +"_"+ dtos( dDataBase ), STR0005, "M", "P",, .F. )
	EndIf
Else
	Aviso(STR0023,STR0024,{STR0025})	//"ATENCAO"###"Para esta opção é preciso atualizar o dicionário de dados - AUDESP"###"Sair"
	Return
EndIf
Return( Nil )

/*/{Protheus.doc}Gpm920Proc()
 - Função responsável pelo processamento da rotina.

@author: 	Matheus Bizutti
@since:	 	22/11/2016
@version: 	1.0
/*/
Static Function Gpm920Proc( oProcess )

// - Variáveis de uso genérico
Local nI 		:= 0

// - Variáveis referentes ao XML
Local oXML 		:= Nil
Local cError 	:= ""
Local cWarning 	:= ""

// - Variáveis utilizadas para receber os dados do Pergunte.
Local cFilDe  	:= ""
Local cFilAte 	:= ""
Local cTpProc 	:= ""
Local cSource 	:= ""
Local cCodEnt 	:= ""
Local cCodMun 	:= ""
Local cExAno  	:= ""
Local cExMes	:= ""
Local cAnoMes	:= ""
Local cDtCompDe := ""
Local cDtCompAt := ""
Local cDataGer	:= ""
Local cSituac	:= ""
Local cCateg	:= ""
Local cTpXML	:= ""
Local cMsgReg	:= ""

/*/ ------------------------------------------
// - MV_PAR01 - Filial De ?                  ||
// - MV_PAR02 - Filial Ate ?     	         ||
// - MV_PAR03 - Tipo de Processamento		 ||
// - MV_PAR04 - Local de Gravacao   		 ||
// - MV_PAR05 - Codigo da Entidade			 ||
// - MV_PAR06 - Codigo do Municipio			 ||
// - MV_PAR07 - Exercicio (AnoMes)			 ||
// - MV_PAR08 - Mes e Ano de Competencia	 ||
// - MV_PAR09 - Data de Competência De?		 ||
// - MV_PAR10 - Data de Competência Ate?	 ||
// - MV_PAR11 - Data de Geracao			 	 ||
// - MV_PAR12 - Situacoes					 ||
// - MV_PAR13 - Categorias					 ||
// - MV_PAR14 - Tipos de XML				 ||
--------------------------------------------/*/

// - Obtém o valor do Pergunte.
cFilDe 		:= MV_PAR01
cFilAte 	:= MV_PAR02
cTpProc 	:= cValToChar(MV_PAR03)
cSource 	:= Alltrim(MV_PAR04)
cCodEnt 	:= MV_PAR05
cCodMun 	:= MV_PAR06
cExAno  	:= Substr(MV_PAR07,1,4)
cExMes  	:= Substr(MV_PAR07,5,2)
cAnoMes 	:= MV_PAR08
cDtCompDe	:= DToc(MV_PAR09)
cDtCompAt	:= DToc(MV_PAR10)
cDataGer	:= DToC(MV_PAR11)
cSituac 	:= MV_PAR12
cCateg 		:= MV_PAR13
cTpXML		:= Alltrim(MV_PAR14)

oProcess:SetRegua1(6)
oProcess:SaveLog(STR0006)

For nI := 0 To 9 Step 1

	cMsgReg := ""

	If cValtoChar(nI) $ cTpXML .And. nI == 0
		nArq	:= MSFCREATE(cSource + "_Remuneracao.xml",0)
		FWrite(nArq,criaXMLTp0(cFilDe,cFilAte,cTpProc,cSource,cCodEnt,cCodMun,cExAno,cAnoMes,cDtCompDe,cDtCompAt,cDataGer,cSituac,cCateg,cTpXML))
		FClose(nArq)
		cMsgReg :=  ": " + STR0007 + Alltrim(Str(nI)) + " - " + STR0037
	Elseif cValtoChar(nI) $ cTpXML .And. nI == 1
		nArq	:= MSFCREATE(cSource + "_AtosNormativos.xml",0)
		FWrite(nArq,criaXMLTp1(cFilDe,cFilAte,cTpProc,cSource,cCodEnt,cCodMun,cExAno,cAnoMes,cDtCompDe,cDtCompAt,cDataGer,cSituac,cCateg,cTpXML))
		FClose(nArq)
		cMsgReg :=  ": " + STR0007 + Alltrim(Str(nI)) + " - " + STR0008

	Elseif cValtoChar(nI) $ cTpXML .And. nI == 2
		nArq	:= MSFCREATE(cSource + "_AgentePublico.xml",0)
		FWrite(nArq,criaXMLTp2(cFilDe,cFilAte,cTpProc,cSource,cCodEnt,cCodMun,cExAno,cAnoMes,cDtCompDe,cDtCompAt,cDataGer,cSituac,cCateg,cTpXML))
		FClose(nArq)
		cMsgReg :=  ": " + STR0007 + Alltrim(Str(nI)) + " - " + STR0009

	Elseif cValtoChar(nI) $ cTpXML .And. nI == 3
		nArq	:= MSFCREATE(cSource + "_Cargos.xml",0)
		FWrite(nArq,criaXMLTp3(cFilDe,cFilAte,cTpProc,cSource,cCodEnt,cCodMun,cExAno,cAnoMes,cDtCompDe,cDtCompAt,cDataGer,cSituac,cCateg,cTpXML))
		FClose(nArq)
		cMsgReg :=  ": " + STR0007 + Alltrim(Str(nI)) + " - " + STR0010

	Elseif cValtoChar(nI) $ cTpXML .And. nI == 4
		nArq	:= MSFCREATE(cSource + "_Funcao.xml",0)
		FWrite(nArq,criaXMLTp4(cFilDe,cFilAte,cTpProc,cSource,cCodEnt,cCodMun,cExAno,cAnoMes,cDtCompDe,cDtCompAt,cDataGer,cSituac,cCateg,cTpXML))
		FClose(nArq)
		cMsgReg :=  ": " + STR0007 + Alltrim(Str(nI)) + " - " + STR0011

	Elseif cValtoChar(nI) $ cTpXML .And. nI == 5
		nArq	:= MSFCREATE(cSource + "_Lotacoes.xml",0)
		FWrite(nArq,criaXMLTp5(cFilDe,cFilAte,cTpProc,cSource,cCodEnt,cCodMun,cExAno,cAnoMes,cDtCompDe,cDtCompAt,cDataGer,cSituac,cCateg,cTpXML))
		FClose(nArq)
		cMsgReg :=  ": " + STR0007 + Alltrim(Str(nI)) + " - " + STR0012

	Elseif cValtoChar(nI) $ cTpXML .And. nI == 6
		nArq	:= MSFCREATE(cSource + "_QuadroPessoal.xml",0)
		FWrite(nArq,criaXMLTp6(cFilDe,cFilAte,cTpProc,cSource,cCodEnt,cCodMun,cExAno,cExMes,cAnoMes,cDtCompDe,cDtCompAt,cDataGer,cSituac,cCateg,cTpXML))
		FClose(nArq)
		cMsgReg :=  ": " + STR0007 + Alltrim(Str(nI)) + " - " + STR0013

	Elseif cValtoChar(nI) $ cTpXML .And. nI == 7

		If SRV->( ColumnPos("RV_CODREMU"))== 0
			Aviso(STR0002,"7 - Verbas Remuneratórias" + CRLF + STR0024,{"OK"}) //"Atencao"# "7 - Verbas Remuneratórias Para esta opção é preciso atualizar o dicionário de dados - AUDESP"
		Else
			nArq	:= MSFCREATE(cSource + "_VerbasRemuneratorias.xml",0)
			FWrite(nArq,criaXMLTp7(cFilDe,cFilAte,cTpProc,cSource,cCodEnt,cCodMun,cExAno,cExMes,cAnoMes,cDtCompDe,cDtCompAt,cDataGer,cSituac,cCateg,cTpXML))
			FClose(nArq)
			cMsgReg :=  ": " + STR0007 + Alltrim(Str(nI)) + " - " + STR0034
		Endif
	Elseif cValtoChar(nI) $ cTpXML .And. nI == 8
		If RS9->( ColumnPos("RS9_MUNLOT"))== 0
			Aviso(STR0002,"8 - Folha Ordinária" + CRLF + STR0024,{"OK"}) //"Atencao"# "8 - Folha Ordinária Para esta opção é preciso atualizar o dicionário de dados - AUDESP"
		Else
			nArq	:= MSFCREATE(cSource + "_FolhaOrdinaria.xml",0)
			FWrite(nArq,criaXMLTp8(cFilDe,cFilAte,cTpProc,cSource,cCodEnt,cCodMun,cExAno,cExMes,cAnoMes,cDtCompDe,cDtCompAt,cDataGer,cSituac,cCateg,cTpXML))
			FClose(nArq)
			cMsgReg :=  ": " + STR0007 + Alltrim(Str(nI)) + " - " + STR0035
		Endif
	Elseif cValtoChar(nI) $ cTpXML .And. nI == 9
		If RS9->( ColumnPos("RS9_MUNLOT"))== 0
			Aviso(STR0002,"9 - Pagamento da Folha Ordinária" + CRLF + STR0024,{"OK"}) //"Atencao"# "8 - Pagamento da Folha Ordinária Para esta opção é preciso atualizar o dicionário de dados - AUDESP"
		Else
			nArq	:= MSFCREATE(cSource + "_PagamentoFolhaOrdinaria.xml",0)
			FWrite(nArq,criaXMLTp9(cFilDe,cFilAte,cTpProc,cSource,cCodEnt,cCodMun,cExAno,cExMes,cAnoMes,cDtCompDe,cDtCompAt,cDataGer,cSituac,cCateg,cTpXML))
			FClose(nArq)

			cMsgReg :=  ": " + STR0007 + Alltrim(Str(nI)) + " - " + STR0036
		Endif
	EndIf

	oProcess:IncRegua1(STR0014 + cMsgReg)

Next nI

If !oProcess:lEnd
	Aviso(STR0016, STR0015 , {STR0022})
	oProcess:SaveLog(STR0015)
Else
	Aviso(STR0016, STR0017, {STR0022})
	oProcess:SaveLog(STR0015)
EndIf

Return( Nil )

/*/{Protheus.doc}FDAudesp()
 - Função responsável por carregar o diretório onde será gravado o arquivo XML.

@author: 	Matheus Bizutti
@since:	 	22/11/2016
@version: 	1.0
/*/
Function FDAudesp()

Local mvRet := Alltrim(ReadVar())
Local cFile := ""
Local oWnd 	:= Nil
Local lRet	:= .T.

oWnd 	:= GetWndDefault()
cFile 	:= cGetFile(STR0018,OemToAnsi(STR0019),,,,nOR( GETF_MULTISELECT,GETF_LOCALFLOPPY, GETF_LOCALHARD, GETF_NETWORKDRIVE ) )

If Empty(cFile)
	lRet := .F.
Endif

cDrive := Alltrim(Upper(cFile))

&mvRet := cFile

If oWnd != Nil
	GetdRefresh()
EndIf

Return( lRet )


/*/{Protheus.doc}AudXML()
- Função responsável pela carga dos tipos de XML da AUDESP.

@author: 	Matheus Bizutti
@since:	 	22/11/2016
@version: 	1.0
/*/
Function AudXML(l1Elem,lTipoRet)

Local cTitulo:=""
Local MvPar
Local MvParDef:=""

Private aTipos:={}

l1Elem := If (l1Elem = Nil , .F. , .T.)

DEFAULT lTipoRet := .T.

cAlias := Alias() 					 	// - Salva Alias Anterior

IF lTipoRet
	MvPar := &(Alltrim(ReadVar()))		 // - Carrega Nome da Variavel do Get em Questao
	mvRet := Alltrim(ReadVar())			 // - Iguala Nome da Variavel ao Nome variavel de Retorno
EndIF

// - Array com os tipos de XML disponíveis.
aTipos := {;
			"1 - " + 'Atos Normativos',;
			"2 - " + 'Agente Público',;
			"3 - " + 'Cargos',;
			"4 - " + 'Funções',;
			"5 - " + 'Lotações Agentes Públicos',;
			"6 - " + 'Quadro de Pessoal',;
			"7 - " + 'Verbas Remuneratórias',;
			"8 - " + 'Folha Ordinária',;
			"9 - " + 'Pagamento da Folha Ordinária',;
			"0 - " + 'Resumo da Folha';
		}

MvParDef :="1234567890" // - Valor Default
cTitulo := STR0020

IF lTipoRet
	IF f_Opcoes(@MvPar,cTitulo,aTipos,MvParDef,12,49,l1Elem)  // - Chama funcao f_Opcoes
		&MvRet := mvpar 									  // - Devolve Resultado
	EndIF
EndIF

dbSelectArea(cAlias) // - Retorna o Alias

Return( IF( lTipoRet , .T. , MvParDef ) )

/*/{Protheus.doc}criaXMLTp1()
- Função responsável por gerar o XML para o tipo 1 - Atos Normativos.

@author: 	Matheus Bizutti
@since:	 	22/11/2016
@version: 	1.0
/*/
Static Function criaXMLTp1(cFilDe,cFilAte,cTpProc,cSource,cCodEnt,cCodMun,cExAno,cAnoMes,cDtCompDe,cDtCompAt,cDataGer,cSituac,cCateg,cTpXML)

Local cEstrut 	:= ""
Local cMesRI5 	:= ""
Local cAnoRI5 	:= ""
Local cMesAux 	:= ""
Local cAnoAux 	:= ""
Local cTipDoc	:= ""
Local cNumDoc	:= ""
Local cArqTemp  := ""
Local cIndTemp  := ""
Local cRetText  := ""
Local nInd	  	:= 1
Local oTSmpEdit := Nil // Irá remover o HTML do campo RI6->RI6_TXTHIS
Local oTSmp2	:= Nil

// - Valida os valores passados como parâmetro para a função.
DEFAULT cFilDe 		:= MV_PAR01
DEFAULT cFilAte 	:= MV_PAR02
DEFAULT cTpProc 	:= cValToChar(MV_PAR03)
DEFAULT cSource 	:= Alltrim(MV_PAR04)
DEFAULT cCodEnt 	:= MV_PAR05
DEFAULT cCodMun 	:= MV_PAR06
DEFAULT cExAno  	:= Substr(MV_PAR07,1,4)
DEFAULT cAnoMes 	:= MV_PAR08
DEFAULT cDtCompDe	:= DToc(MV_PAR09)
DEFAULT cDtCompAt	:= DToc(MV_PAR10)
DEFAULT cDataGer	:= DToC(MV_PAR11)
DEFAULT cSituac 	:= Alltrim(MV_PAR12)
DEFAULT cCateg 		:= Alltrim(MV_PAR13)
DEFAULT cTpXML		:= Alltrim(MV_PAR14)

// - Exemplo para o tipo 1
cEstrut := '<?xml version="1.0" encoding="ISO-8859-1"?>' +CHR(10)
cEstrut += '<an:AtosNormativos xmlns:gen="http://www.tce.sp.gov.br/audesp/xml/generico" '  +CHR(10)
cEstrut += 'xmlns:an="http://www.tce.sp.gov.br/audesp/xml/atosnormativos" '
cEstrut += 'xmlns:ap="http://www.tce.sp.gov.br/audesp/xml/atospessoal" '
cEstrut += 'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
cEstrut += 'xsi:schemaLocation="http://www.tce.sp.gov.br/audesp/xml/atosnormativos ../atosnormativos/AUDESP_ATOSNORMATIVOS_' + cExAno + '_A.XSD"> '
cEstrut +=  "<an:Descritor>" +CHR(10)
cEstrut += 		"<gen:AnoExercicio>"
cEstrut += 			cExAno
cEstrut += 		"</gen:AnoExercicio>" +CHR(10)
cEstrut	+= 		"<gen:TipoDocumento>"
cEstrut +=			"Atos Normativos"
cEstrut += 		"</gen:TipoDocumento>" +CHR(10)
cEstrut += 		"<gen:Entidade>"
cEstrut += 			cCodent
cEstrut += 		"</gen:Entidade>" +CHR(10)
cEstrut +=		"<gen:Municipio>"
cEstrut +=			cCodMun
cEstrut += 		"</gen:Municipio>" +CHR(10)
cEstrut +=		"<gen:DataCriacaoXML>"
cEstrut += 			Substr(cDataGer,7,4) + "-" + Substr(cDataGer,4,2) + "-" + Substr(cDataGer,1,2)
cEstrut +=		"</gen:DataCriacaoXML>" +CHR(10)
cEstrut +=  "</an:Descritor>" +CHR(10)
cEstrut +=  "<an:ListaAtosNormativos>" +CHR(10)

cMesAux := Substr(cAnoMes,1,2)
cAnoAux	:= SubStr(cAnoMes,3,4)

DbSelectArea("RI5")
RI5->(DbSetOrder(nInd))
RI5->(DbGoTop())

DBSelectArea("RI6")
cArqTemp := CriaTrab(NIL,.F.)
cIndTemp := ( "RI6_FILIAL+RI6_ANO+RI6_NUMDOC+RI6_TIPDOC" )
IndRegua( 'RI6', cArqTemp, cIndTemp )

While RI5->(!Eof()) .And. RI5->RI5_FILIAL <= cFilAte

	cMesRI5 := Substr(DTOC(RI5->RI5_DTAPUB),4,2)
	cAnoRI5 := Substr(DTOC(RI5->RI5_DTAPUB),7,4)

	cTipDoc := RI5->RI5_TIPDOC
	cNumDoc := RI5->RI5_NUMDOC

	// ------------------------------------------------------------------
	// - Caso a carga seja MENSAL, deverá respeitar ano e mês informados.
	// ------------------------------------------------------------------
	If cTpProc == "2" .And. (cMesRI5 != cMesAux .Or. cAnoRI5 != cAnoAux)
		RI5->(DbSkip())
		Loop
	EndIf

	// ------------------------------------------------------------
	// - A Partir do registro que está sendo processado
	// - é efetuada a busca na RI6 dos registros com mesmo mês e ano
	// - aos que foram informados em tela, através do pergunte -
	// - Mês e Ano de Competência
	// - (MV_PAR08).
	// ------------------------------------------------------------

	If RI6->(DbSeek(RI5->RI5_FILIAL+RI5->RI5_ANO+RI5->RI5_NUMDOC+RI5->RI5_TIPDOC))

		oTSmp2 := TSimpleEditor():Create( )
		oTSmp2:Load(RI6->RI6_TXTHIS) // - Carrega o conteúdo gerado pelo editor em HTML.
		oTSmp2:TextFormat(2) // - Transforma para texto puro.
		cRetText := oTSmp2:RetText() // - Captura o texto.

		cEstrut +=	  "<an:AtoNormativo>" +CHR(10)
		cEstrut +=		 "<an:numeroDoAto>"
		cEstrut +=		 	Alltrim(RI6->RI6_NUMDOC)
		cEstrut +=		 "</an:numeroDoAto>" +CHR(10)
		cEstrut +=		 "<an:anoDoAto>"
		cEstrut +=		 	RI6->RI6_ANO
		cEstrut +=		 "</an:anoDoAto>" +CHR(10)
		cEstrut +=		 "<an:tipoDeNorma>"
		cEstrut +=		 	RI6->RI6_TIPDOC
		cEstrut +=		 "</an:tipoDeNorma>" +CHR(10)
		cEstrut +=		 "<an:descricao>"
		cEstrut +=		 	cRetText // - (cAliasQry)->RI6_TXTHIS
		cEstrut +=		 "</an:descricao>" +CHR(10)
		cEstrut +=		 "<an:dataPublicacao>"
		cEstrut +=		 	Substr(DToS(RI5->RI5_DTAPUB),1,4) + "-" + Substr(DToS(RI5->RI5_DTAPUB),5,2) + "-" + Substr(DToS(RI5->RI5_DTAPUB),7,2)
		cEstrut +=		 "</an:dataPublicacao>" +CHR(10)
		cEstrut +=		 "<an:dataVigencia>"
		cEstrut +=			Substr(DToS(RI6->RI6_DTEFEI),1,4) + "-" + Substr(DToS(RI6->RI6_DTEFEI),5,2) + "-" + Substr(DToS(RI6->RI6_DTEFEI),7,2)
		cEstrut +=		 "</an:dataVigencia>" +CHR(10)
		cEstrut +=	  "</an:AtoNormativo>" +CHR(10)

		While RI6->(!Eof())

			// - --------------------------------------------------------------------------
			// - Transformar o conteúdo do editor que vem em HTML para texto puro.
			// - Criar o objeto dentro do laço, pois a classe não possui DESTROY.
			// - Mais detalhes visualizar: http://tdn.totvs.com/display/tec/TSimpleEditor
			// - --------------------------------------------------------------------------

			oTSmpEdit := TSimpleEditor():Create( )
			oTSmpEdit:Load(RI6->RI6_TXTHIS) // - Carrega o conteúdo gerado pelo editor em HTML.
			oTSmpEdit:TextFormat(2) // - Transforma para texto puro.
			cRetText := oTSmpEdit:RetText() // - Captura o texto.

			cEstrut +=	  "<an:AtoNormativo>" +CHR(10)
			cEstrut +=		 "<an:numeroDoAto>"
			cEstrut +=		 	Alltrim(RI6->RI6_NUMDOC)
			cEstrut +=		 "</an:numeroDoAto>" +CHR(10)
			cEstrut +=		 "<an:anoDoAto>"
			cEstrut +=		 	RI6->RI6_ANO
			cEstrut +=		 "</an:anoDoAto>" +CHR(10)
			cEstrut +=		 "<an:tipoDeNorma>"
			cEstrut +=		 	RI6->RI6_TIPDOC
			cEstrut +=		 "</an:tipoDeNorma>" +CHR(10)
			cEstrut +=		 "<an:descricao>"
			cEstrut +=		 	Alltrim(cRetText)
			cEstrut +=		 "</an:descricao>" +CHR(10)
			cEstrut +=		 "<an:dataPublicacao>"
			cEstrut +=		 	Substr(DToS(RI5->RI5_DTAPUB),1,4) + "-" + Substr(DToS(RI5->RI5_DTAPUB),5,2) + "-" + Substr(DToS(RI5->RI5_DTAPUB),7,2)
			cEstrut +=		 "</an:dataPublicacao>" +CHR(10)
			cEstrut +=		 "<an:dataVigencia>"
			cEstrut +=		 	Substr(DToS(RI6->RI6_DTEFEI),1,4) + "-" + Substr(DToS(RI6->RI6_DTEFEI),5,2) + "-" + Substr(DToS(RI6->RI6_DTEFEI),7,2)
			cEstrut +=		 "</an:dataVigencia>" +CHR(10)
			cEstrut +=	  "</an:AtoNormativo>" +CHR(10)

			oTSmpEdit := Nil

			RI6->(DbSkip())

		EndDo

	EndIf

	RI5->(DbSkip())

EndDo

cEstrut +=  "</an:ListaAtosNormativos>" +CHR(10)
cEstrut += "</an:AtosNormativos>"


Return( cEstrut )

/*/{Protheus.doc}criaXMLTp2()
Função responsável por gerar o XML para o tipo 2 - Agente Público
@author: 	Matheus Bizutti
@since:	 	22/11/2016
@version: 	1.0
/*/
Static Function criaXMLTp2(cFilDe,cFilAte,cTpProc,cSource,cCodEnt,cCodMun,cExAno,cAnoMes,cDtCompDe,cDtCompAt,cDataGer,cSituac,cCateg,cTpXML)

Local cEstrut := ""

Local cMesAux := ""
Local cAnoAux	:= ""

// - Valida os valores passados como parâmetro para a função.
DEFAULT cFilDe 		:= MV_PAR01
DEFAULT cFilAte 	:= MV_PAR02
DEFAULT cTpProc 	:= cValToChar(MV_PAR03)
DEFAULT cSource 	:= Alltrim(MV_PAR04)
DEFAULT cCodEnt 	:= MV_PAR05
DEFAULT cCodMun 	:= MV_PAR06
DEFAULT cExAno  	:= Substr(MV_PAR07,1,4)
DEFAULT cAnoMes 	:= MV_PAR08
DEFAULT cDtCompDe	:= DToc(MV_PAR09)
DEFAULT cDtCompAt	:= DToc(MV_PAR10)
DEFAULT cDataGer	:= DToC(MV_PAR11)
DEFAULT cSituac 	:= MV_PAR12
DEFAULT cCateg 	:= Alltrim(MV_PAR13)
DEFAULT cTpXML	:= Alltrim(MV_PAR14)

cMesAux := Substr(cAnoMes,1,2)
cAnoAux	:= SubStr(cAnoMes,3,4)

cEstrut := '<?xml version="1.0" encoding="ISO-8859-1"?>' +CHR(10)
cEstrut += "<ag:AgentesPublicos xmlns:gen='http://www.tce.sp.gov.br/audesp/xml/generico' "+CHR(10)
cEstrut += "xmlns:ap='http://www.tce.sp.gov.br/audesp/xml/atospessoal' "+CHR(10)
cEstrut += "xmlns:ag='http://www.tce.sp.gov.br/audesp/xml/quadrofuncional-agentepublico' "+CHR(10)
cEstrut += "xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' "+CHR(10)
cEstrut += "xsi:schemaLocation='http://www.tce.sp.gov.br/audesp/xml/quadrofuncional-agentepublico ../quadrofuncional/AUDESP_AGENTEPUBLICO_" + cExAno + "_A.XSD'> "

cEstrut += "<ag:Descritor>"
cEstrut += 		"<gen:AnoExercicio>"
cEstrut += 			cExAno
cEstrut += 		"</gen:AnoExercicio>"
cEstrut	+= 		"<gen:TipoDocumento>"
cEstrut +=			"Agente Público"
cEstrut += 		"</gen:TipoDocumento>"
cEstrut += 		"<gen:Entidade>"
cEstrut += 			cCodent
cEstrut += 		"</gen:Entidade>"
cEstrut +=		"<gen:Municipio>"
cEstrut +=			cCodMun
cEstrut += 		"</gen:Municipio>"
cEstrut +=		"<gen:DataCriacaoXML>"
cEstrut += 			Substr(cDataGer,7,4) + "-" + Substr(cDataGer,4,2) + "-" + Substr(cDataGer,1,2)
cEstrut +=		"</gen:DataCriacaoXML>"
cEstrut += 	"</ag:Descritor>"

DbSelectArea("RS9")
RS9->(DbSetOrder(1))
RS9->(DbGoTop())

dbSeek( cFilDe, .T. )

	cEstrut += 	"<ag:ListaAgentePublico>"

	While RS9->(!Eof()) .And. RS9->RS9_FILIAL <= cFilAte
		aArea		:= GetArea()
		DbSelectArea("SRA")
		SRA->(DbSetOrder(1))
		if SRA->(dbSeek(RS9->RS9_FILIAL+RS9->RS9_MAT))
			if ( SRA->RA_SITFOLH $ cSituac ) .and. (SRA->RA_CATFUNC $ cCateg ) .And.;
				(cTpProc == "1" .And. AvalSRA(cTod(cDtCompDe), cTod(cDtCompAt)) ) .Or. ;
				(cTpProc == "2" .And. (SUBSTR(DTOC(SRA->RA_ADMISSA),4,2) == cMesAux .and. SUBSTR(DTOC(SRA->RA_admissa),7,4) == cAnoAux))
				cEstrut += 	"<ag:AgentePublico>"
				cEstrut += 	"<ag:nome>"
				if !empty(SRA->RA_NOMECMP)
					cEstrut += 	alltrim(SRA->RA_NOMECMP)
				Else
					cEstrut += 	alltrim(SRA->RA_NOME)
				endif
				cEstrut += 	"</ag:nome>"

				cEstrut += 	"<ag:cpf Tipo='02'>"
				cEstrut += 	"<gen:Numero>"
				cEstrut +=     SRA->RA_CIC
				cEstrut += 	"</gen:Numero>"
				cEstrut +="	</ag:cpf>"

				cEstrut += 	"<ag:pis_pasep>"
				cEstrut +=     alltrim(SRA->RA_PIS)
				cEstrut += 	"</ag:pis_pasep>"

				cEstrut += 	"<ag:dataNascimento>"
				cEstrut +=     subsTR(DTOC(SRA->RA_NASC),7,4)+"-"+subsTR(DTOC(SRA->RA_NASC),4,2)+"-"+subsTR(DTOC(SRA->RA_NASC),1,2)
				cEstrut += 	"</ag:dataNascimento>"

				cEstrut += 	"<ag:sexo>"
				if SRA->RA_SEXO == "M"
					cEstrut +=     "1"
				else
					cEstrut +=     "2"
				Endif
				cEstrut += 	"</ag:sexo>"

				cEstrut += 	"<ag:nacionalidade>"
				If SRA->RA_NACIONA == "10" .or. SRA->RA_NACIONA == "20"
					cEstrut += SUBSTR(SRA->RA_NACIONA,1,1)
				Else
					cEstrut +=     "3"
				EndIf
				cEstrut += 	"</ag:nacionalidade>"

				cEstrut +=    "<ag:escolaridade>"
				cEstrut += alltrim(RS9->RS9_APESC)
				cEstrut +=    "</ag:escolaridade>"

				cEstrut +=    "<ag:especialidade>"
				cEstrut += alltrim(RS9->RS9_APESP)
				cEstrut +=    "</ag:especialidade>"

				cEstrut += 	"</ag:AgentePublico>"
			Endif
		Endif
		RestArea( aArea )
		RS9->(DbSkip())
	Enddo
	cEstrut += 	"</ag:ListaAgentePublico>"
	cEstrut += "</ag:AgentesPublicos>

Return( cEstrut )

/*/{Protheus.doc}criaXMLTp3()
- Função responsável por gerar o XML para o tipo 3 - Cargos

@author: 	Matheus Bizutti
@since:	 	22/11/2016
@version: 	1.0
/*/
Static Function criaXMLTp3(cFilDe,cFilAte,cTpProc,cSource,cCodEnt,cCodMun,cExAno,cAnoMes,cDtCompDe,cDtCompAt,cDataGer,cSituac,cCateg,cTpXML)

Local cEstrut 		:= ""
Local cEstrutC		:= ""
Local cEstrutV		:= ""
Local cMesAux 		:= ""
Local cAnoAux 		:= ""
Local cDiaRS8		:= ""
Local cMesRS8 		:= ""
Local cAnoRS8 		:= ""
Local nInd 	  		:= 1
Local aArea   		:= GetArea()
Local cAliasQry		:= GetNextAlias()
Local cAliasQryTp2	:= GetNextAlias()
Local cCargo		:= ""
Local cCargoAux		:= ""

// - Valida os valores passados como parâmetro para a função.
DEFAULT cFilDe 		:= MV_PAR01
DEFAULT cFilAte 	:= MV_PAR02
DEFAULT cTpProc 	:= cValToChar(MV_PAR03)
DEFAULT cSource 	:= Alltrim(MV_PAR04)
DEFAULT cCodEnt 	:= MV_PAR05
DEFAULT cCodMun 	:= MV_PAR06
DEFAULT cExAno  	:= Substr(MV_PAR07,1,4)
DEFAULT cAnoMes 	:= MV_PAR08
DEFAULT cDtCompDe	:= DToc(MV_PAR09)
DEFAULT cDtCompAt	:= DToc(MV_PAR10)
DEFAULT cDataGer	:= DToC(MV_PAR11)
DEFAULT cSituac 	:= Alltrim(MV_PAR12)
DEFAULT cCateg 		:= Alltrim(MV_PAR13)
DEFAULT cTpXML		:= Alltrim(MV_PAR14)

// - Exemplo para o tipo 3
cEstrut := '<?xml version="1.0" encoding="ISO-8859-1"?>' +CHR(10)
cEstrut += "<qpc:Cargos xmlns:gen='http://www.tce.sp.gov.br/audesp/xml/generico' " +CHR(10)
cEstrut += "xmlns:qpc='http://www.tce.sp.gov.br/audesp/xml/quadropessoal-cargos' " +CHR(10)
cEstrut += "xmlns:ap='http://www.tce.sp.gov.br/audesp/xml/atospessoal' " +CHR(10)
cEstrut += "xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' " +CHR(10)
cEstrut += "xsi:schemaLocation='http://www.tce.sp.gov.br/audesp/xml/quadropessoal-cargos ../quadropessoal/AUDESP_CARGO_" + cExAno + "_A.XSD'> "+CHR(10)
cEstrut += "<qpc:Descritor>"+CHR(10)
cEstrut += 		"<gen:AnoExercicio>"
cEstrut += 			cExAno
cEstrut += 		"</gen:AnoExercicio>"+CHR(10)
cEstrut	+= 		"<gen:TipoDocumento>"
cEstrut +=			"Cargos"
cEstrut += 		"</gen:TipoDocumento>"+CHR(10)
cEstrut += 		"<gen:Entidade>"
cEstrut += 			ALLTRIM(cCodent)
cEstrut += 		"</gen:Entidade>"+CHR(10)
cEstrut +=		"<gen:Municipio>"
cEstrut +=			ALLTRIM(cCodMun)
cEstrut += 		"</gen:Municipio>"+CHR(10)
cEstrut +=		"<gen:DataCriacaoXML>"
cEstrut += 			Substr(cDataGer,7,4) + "-" + Substr(cDataGer,4,2) + "-" + Substr(cDataGer,1,2)
cEstrut +=		"</gen:DataCriacaoXML>"+CHR(10)
cEstrut += 	"</qpc:Descritor>"+CHR(10)

cMesAux := Substr(cAnoMes,1,2)
cAnoAux	:= SubStr(cAnoMes,3,4)

DbSelectArea("SQ3")
SQ3->(DbSetOrder(nInd))
SQ3->(DbGoTop())

If cTpProc == "1"

	While SQ3->(!Eof()) .And. SQ3->Q3_FILIAL <= cFilAte

		cEstrutC += 		"<qpc:Cargo>"+CHR(10)
		cEstrutC +=			"<qpc:codigoCargo>"
		cEstrutC +=				ALLTRIM(SQ3->Q3_CARGO)
		cEstrutC +=			"</qpc:codigoCargo>"+CHR(10)
		cEstrutC +=			"<qpc:nomeCargo>"
		cEstrutC +=				ALLTRIM(SQ3->Q3_DESCSUM)
		cEstrutC +=			"</qpc:nomeCargo>"+CHR(10)
		cEstrutC +=			"<qpc:tipoCargo>"
		cEstrutC +=				ALLTRIM(SQ3->Q3_ADTPCAR)
		cEstrutC +=			"</qpc:tipoCargo>"+CHR(10)
		cEstrutC +=			"<qpc:regimeJuridico>"
		cEstrutC +=				ALLTRIM(SQ3->Q3_ADTPJU)
		cEstrutC +=			"</qpc:regimeJuridico>"+CHR(10)
		cEstrutC +=			"<qpc:escolaridade>"
		cEstrutC +=				ALLTRIM(SQ3->Q3_ADTPESC)
		cEstrutC +=			"</qpc:escolaridade>"+CHR(10)
		cEstrutC +=			"<qpc:exercicioAtividade>"
		cEstrutC +=				ALLTRIM(SQ3->Q3_ADATIV)
		cEstrutC +=			"</qpc:exercicioAtividade>"+CHR(10)
		cEstrutC +=			"<qpc:formaProvimento>"
		cEstrutC +=				ALLTRIM(SQ3->Q3_ADTPROV)
		cEstrutC +=			"</qpc:formaProvimento>"+CHR(10)
		cEstrutC +=			"<qpc:totalHorasTrabalho>"
		cEstrutC +=				cValToChar(SQ3->Q3_ADHORAS)
		cEstrutC +=			"</qpc:totalHorasTrabalho>"+CHR(10)
		cEstrutC +=			"<qpc:cargoPolitico>"
		cEstrutC +=			"</qpc:cargoPolitico>" +CHR(10)
		If !Empty(SQ3->Q3_ADRESP)
			cEstrutC +=			"<qpc:responsavelPelaEntidade>"
			cEstrutC +=				"<qpc:Vigencia>"
			cEstrutC +=					"<qpc:dataInicial>"
			cEstrutC += 						Substr(Dtos(SQ3->Q3_ADRESP),1,4) + "-" + Substr(Dtos(SQ3->Q3_ADRESP),5,2) + "-" + Substr(Dtos(SQ3->Q3_ADRESP),7,2)
			cEstrutC += 					"</qpc:dataInicial>"
			cEstrutC +=				"</qpc:Vigencia>"
			cEstrutC +=			"</qpc:responsavelPelaEntidade>"+CHR(10)
		EndIf
		cEstrutC += 		"</qpc:Cargo>"

		// --------------------------------------------------
		// - Gera o Histórico referente ao cargo que estará
		// - percorrendo.
		// --------------------------------------------------

		cCargo := SQ3->Q3_CARGO

		BeginSql alias cAliasQry
			SELECT * FROM %table:RS8% RS8
				WHERE RS8.RS8_FILIAL >= %exp:cFilDe% 	AND
				 	  RS8.RS8_FILIAL <= %exp:cFilAte%	AND
					  RS8.RS8_ADCCAR = %exp:cCargo% 	AND
					  RS8.%notDel%
			    EndSQL

		// ------------------------------------------------------------
		// - A Partir do cargo que está sendo processado
		// - é efetuada a busca na RS8 - Histórico de Movimentação
		// - dos registros com mesmo mês e ano aos que foram informados
		// - em tela, através do pergunte - Mês e Ano de Competência
		// - (MV_PAR08).
		// ------------------------------------------------------------
		While (cAliasQry)->(!Eof())

			cEstrutV +=		"<qpc:HistoricoVaga>"+CHR(10)
			cEstrutV +=			"<qpc:codigoCargo>"
			cEstrutV +=				ALLTRIM(cCargo)
			cEstrutV +=			"</qpc:codigoCargo>"+CHR(10)
			cEstrutV +=			"<qpc:tipoAlteracao>"
			cEstrutV +=				ALLTRIM((cAliasQry)->RS8_ADDTMO)
			cEstrutV +=			"</qpc:tipoAlteracao>"	+CHR(10)
			cEstrutV +=			"<qpc:quantidadeVagas>"
			cEstrutV +=				cValToChar((cAliasQry)->RS8_ADQTDE)
			cEstrutV +=			"</qpc:quantidadeVagas>"
			cEstrutV +=			"<qpc:data>"
			cEstrutV +=				Substr((cAliasQry)->RS8_ADDTMV,1,4) + "-" + Substr((cAliasQry)->RS8_ADDTMV,5,2) + "-" + Substr((cAliasQry)->RS8_ADDTMV,7,8)
			cEstrutV +=			"</qpc:data>"+CHR(10)
			cEstrutV +=			"<qpc:fundamentoLegal>" +CHR(10)
			cEstrutV +=				"<qpc:numeroDoAto>"
			cEstrutV +=					Alltrim((cAliasQry)->RS8_ADATO)
			cEstrutV +=				"</qpc:numeroDoAto>"+CHR(10)
			cEstrutV +=				"<qpc:anoDoAto>"
			cEstrutV +=					(cAliasQry)->RS8_ADANO
			cEstrutV +=				"</qpc:anoDoAto>"+CHR(10)
			cEstrutV +=				"<qpc:tipoDeNorma>"
			cEstrutV +=					(cAliasQry)->RS8_ADTPNOR
			cEstrutV +=				"</qpc:tipoDeNorma>"
			cEstrutV +=			"</qpc:fundamentoLegal>"+CHR(10)
			cEstrutV +=		"</qpc:HistoricoVaga>"+CHR(10)

			(cAliasQry)->(DbSkip())

		EndDo

		(cAliasQry)->(DbCloseArea())

		SQ3->(DbSkip())

	EndDo
Else

	While SQ3->(!Eof()) .And. SQ3->Q3_FILIAL <= cFilAte

		cCargo 		:= SQ3->Q3_CARGO

		BeginSql alias cAliasQryTp2
			SELECT * FROM %table:RS8% RS8
				WHERE RS8.RS8_FILIAL >= %exp:cFilDe% 	AND
				 	  RS8.RS8_FILIAL <= %exp:cFilAte%	AND
					  RS8.RS8_ADCCAR = %exp:cCargo% 	AND
					  RS8.%notDel%
			    EndSQL

		While (cAliasQryTp2)->(!Eof())

			// -----------------------------------------------------------
			// - MONTA A DATA DO CARGO QUE ESTÁ SENDO LIDO.
			// -----------------------------------------------------------
			cDiaRS8	:= SubStr((cAliasQryTp2)->RS8_ADDTMV,7,2)
			cMesRS8 := SubStr((cAliasQryTp2)->RS8_ADDTMV,5,2)
			cAnoRS8 := SubStr((cAliasQryTp2)->RS8_ADDTMV,1,4)

			// -----------------------------------------------------------
			// - Valida as datas para não gerar error.log.
			// -----------------------------------------------------------
			If !Empty(CToD(cDiaRS8+"/"+cMesRS8+"/"+cAnoRS8)) .And. !Empty(CToD(cDtCompDe)) .And. !Empty(CToD(cDiaRS8+"/"+cMesRS8+"/"+cAnoRS8)) .And. !Empty(CTod(cDtCompAt))

				// -----------------------------------------------------------
				// - Consiste período entre a data de competência informada.
				// -----------------------------------------------------------
				If CToD(cDiaRS8+"/"+cMesRS8+"/"+cAnoRS8) >= CToD(cDtCompDe) .And. CToD(cDiaRS8+"/"+cMesRS8+"/"+cAnoRS8) <= CTod(cDtCompAt)

					// -----------------------------------------------------------
					// - DETALHES DO CARGO.
					// -----------------------------------------------------------
					If cCargoAux != SQ3->Q3_CARGO
						cEstrutC += 		"<qpc:Cargo>"
						cEstrutC +=			"<qpc:codigoCargo>"
						cEstrutC +=				SQ3->Q3_CARGO
						cEstrutC +=			"</qpc:codigoCargo>"+CHR(10)
						cEstrutC +=			"<qpc:nomeCargo>"
						cEstrutC +=				SQ3->Q3_DESCSUM
						cEstrutC +=			"</qpc:nomeCargo>"+CHR(10)
						cEstrutC +=			"<qpc:tipoCargo>"
						cEstrutC +=				SQ3->Q3_ADTPCAR
						cEstrutC +=			"</qpc:tipoCargo>"
						cEstrutC +=			"<qpc:regimeJuridico>"
						cEstrutC +=				SQ3->Q3_ADTPJU
						cEstrutC +=			"</qpc:regimeJuridico>"+CHR(10)
						cEstrutC +=			"<qpc:escolaridade>"
						cEstrutC +=				SQ3->Q3_ADTPESC
						cEstrutC +=			"</qpc:escolaridade>"+CHR(10)
						cEstrutC +=			"<qpc:exercicioAtividade>"
						cEstrutC +=				SQ3->Q3_ADATIV
						cEstrutC +=			"</qpc:exercicioAtividade>"+CHR(10)
						cEstrutC +=			"<qpc:formaProvimento>"
						cEstrutC +=				SQ3->Q3_ADTPROV
						cEstrutC +=			"</qpc:formaProvimento>"+CHR(10)
						cEstrutC +=			"<qpc:totalHorasTrabalho>"
						cEstrutC +=				cValToChar(SQ3->Q3_ADHORAS)
						cEstrutC +=			"</qpc:totalHorasTrabalho>"+CHR(10)
						cEstrutC +=			"<qpc:responsavelPelaEntidade>"+CHR(10)
						cEstrutC +=				"<qpc:Vigencia>"+CHR(10)
						cEstrutC +=					"<qpc:dataInicial>"
						cEstrutC += 						Substr(Dtos(SQ3->Q3_ADRESP),1,4) + "-" + Substr(Dtos(SQ3->Q3_ADRESP),5,2) + "-" + Substr(Dtos(SQ3->Q3_ADRESP),7,2)
						cEstrutC += 					"</qpc:dataInicial>"+CHR(10)
						cEstrutC +=				"</qpc:Vigencia>"+CHR(10)
						cEstrutC +=			"</qpc:responsavelPelaEntidade>"+CHR(10)
						cEstrutC += 		"</qpc:Cargo>"+CHR(10)

					EndIf

					// - Alimenta a variável para não imprimir dois cabeçalhos do mesmo cargo.
					cCargoAux := SQ3->Q3_CARGO

					// -----------------------------------------------------------
					// - HISTÓRICO DA VAGA.
					// -----------------------------------------------------------
					cEstrutV +=		"<qpc:HistoricoVaga>"+CHR(10)
					cEstrutV +=			"<qpc:codigoCargo>"
					cEstrutV +=				alltrim(cCargo)
					cEstrutV +=			"</qpc:codigoCargo>"+CHR(10)
					cEstrutV +=			"<qpc:tipoAlteracao>"
					cEstrutV +=				alltrim((cAliasQryTp2)->RS8_ADDTMO)
					cEstrutV +=			"</qpc:tipoAlteracao>"+CHR(10)
					cEstrutV +=			"<qpc:quantidadeVagas>"
					cEstrutV +=				cValToChar((cAliasQryTp2)->RS8_ADQTDE)
					cEstrutV +=			"</qpc:quantidadeVagas>"+CHR(10)
					cEstrutV +=			"<qpc:data>"
					cEstrutV +=			Substr((cAliasQryTp2)->RS8_ADDTMV,1,4) + "-" + Substr((cAliasQryTp2)->RS8_ADDTMV,5,2) + "-" + Substr((cAliasQryTp2)->RS8_ADDTMV,7,2)
					cEstrutV +=			"</qpc:data>"
					cEstrutV +=			"<qpc:fundamentoLegal>" +CHR(10)
					cEstrutV +=				"<qpc:numeroDoAto>"
					cEstrutV +=					Alltrim((cAliasQryTp2)->RS8_ADATO)
					cEstrutV +=				"</qpc:numeroDoAto>"+CHR(10)
					cEstrutV +=				"<qpc:anoDoAto>"
					cEstrutV +=					(cAliasQryTp2)->RS8_ADANO
					cEstrutV +=				"</qpc:anoDoAto>"+CHR(10)
					cEstrutV +=				"<qpc:tipoDeNorma>"
					cEstrutV +=					alltrim((cAliasQryTp2)->RS8_ADTPNOR)
					cEstrutV +=				"</qpc:tipoDeNorma>"+CHR(10)
					cEstrutV +=			"</qpc:fundamentoLegal>"	+CHR(10)
					cEstrutV +=		"</qpc:HistoricoVaga>"+CHR(10)

				EndIf

			EndIf

			(cAliasQryTp2)->(DbSkip())

		EndDo

		(cAliasQryTp2)->(DbCloseArea())

		SQ3->(DbSkip())
	EndDo

EndIf

// - Corpo do XML.
cEstrut += 	"<qpc:ListaCargos>"
cEstrut += 		cEstrutC
cEstrut += 	"</qpc:ListaCargos>"+CHR(10)
cEstrut += 	"<qpc:ListaHistoricoVagas>"
cEstrut += 		cEstrutV
cEstrut += 	"</qpc:ListaHistoricoVagas>"+CHR(10)
cEstrut += "</qpc:Cargos>"

RestArea(aArea)

Return( cEstrut )

/*/{Protheus.doc}criaXMLTp4()
- Função responsável por gerar o XML para o tipo 4 - Funções

@author: 	Matheus Bizutti
@since:	 	22/11/2016
@version: 	1.0
/*/
Static Function criaXMLTp4(cFilDe,cFilAte,cTpProc,cSource,cCodEnt,cCodMun,cExAno,cAnoMes,cDtCompDe,cDtCompAt,cDataGer,cSituac,cCateg,cTpXML)

Local cEstrut := ""
Local cMesAux := ""
Local cAnoAux := ""
Local cMesSRJ := ""
Local cAnoSRJ := ""
Local nInd 	  := 1
Local aArea   := GetArea()

// - Valida os valores passados como parâmetro para a função.
DEFAULT cFilDe 		:= MV_PAR01
DEFAULT cFilAte 	:= MV_PAR02
DEFAULT cTpProc 	:= cValToChar(MV_PAR03)
DEFAULT cSource 	:= Alltrim(MV_PAR04)
DEFAULT cCodEnt 	:= MV_PAR05
DEFAULT cCodMun 	:= MV_PAR06
DEFAULT cExAno  	:= Substr(MV_PAR07,1,4)
DEFAULT cAnoMes 	:= MV_PAR08
DEFAULT cDtCompDe	:= DToc(MV_PAR09)
DEFAULT cDtCompAt	:= DToc(MV_PAR10)
DEFAULT cDataGer	:= DToC(MV_PAR11)
DEFAULT cSituac 	:= Alltrim(MV_PAR12)
DEFAULT cCateg 		:= Alltrim(MV_PAR13)
DEFAULT cTpXML		:= Alltrim(MV_PAR14)

// - Exemplo para o tipo 4
cEstrut := '<?xml version="1.0" encoding="ISO-8859-1"?>' +CHR(10)
cEstrut += "<qpf:Funcoes xmlns:qpf='http://www.tce.sp.gov.br/audesp/xml/quadropessoal-funcoes' "+CHR(10)
cEstrut += "xmlns:gen='http://www.tce.sp.gov.br/audesp/xml/generico' "+CHR(10)
cEstrut += "xmlns:ap='http://www.tce.sp.gov.br/audesp/xml/atospessoal' "+CHR(10)
cEstrut += "xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' "+CHR(10)
cEstrut += "xsi:schemaLocation='http://www.tce.sp.gov.br/audesp/xml/quadropessoal-funcoes ../quadropessoal/AUDESP_FUNCAO_" + cExAno + "_A.XSD'>" + CHR(10)
cEstrut += "<qpf:Descritor>"+CHR(10)
cEstrut += 		"<gen:AnoExercicio>"
cEstrut += 			cExAno
cEstrut += 		"</gen:AnoExercicio>"+CHR(10)
cEstrut += 		"<gen:TipoDocumento>"
cEstrut +=			"Funções"
cEstrut += 		"</gen:TipoDocumento>"+CHR(10)
cEstrut += 		"<gen:Entidade>"
cEstrut += 			cCodent
cEstrut += 		"</gen:Entidade>"+CHR(10)
cEstrut +=		"<gen:Municipio>"
cEstrut +=			cCodMun
cEstrut += 		"</gen:Municipio>"+CHR(10)
cEstrut +=		"<gen:DataCriacaoXML>"
cEstrut += 			Substr(cDataGer,7,4) + "-" + Substr(cDataGer,4,2) + "-" + Substr(cDataGer,1,2)
cEstrut +=		"</gen:DataCriacaoXML>"+CHR(10)
cEstrut += 	"</qpf:Descritor>"+CHR(10)
cEstrut += 	"<qpf:ListaFuncoes>"+CHR(10)

cMesAux := Substr(cAnoMes,1,2)
cAnoAux	:= SubStr(cAnoMes,3,4)

DbSelectArea("SRJ")
SRJ->(DbSetOrder(nInd))
SRJ->(DbGoTop())

While SRJ->(!Eof()) .And. SRJ->RJ_FILIAL <= cFilAte

	cMesSRJ := Substr(DTOC(SRJ->RJ_ADDATA),4,2)
	cAnoSRJ := Substr(DTOC(SRJ->RJ_ADDATA),7,4)

	// ------------------------------------------------------------------
	// - Caso o Tipo de Processamente seja períodico, só deverão ser
	// - geradas no .XML as funções alteradas/criadas no mesmo mês/ano
	// - indicado em tela, através do pergunte - Mês e Ano de Competência
	// - (MV_PAR08).
	// ------------------------------------------------------------------
	If cTpProc == "2" .And. (cMesSRJ != cMesAux .Or. cAnoSRJ != cAnoAux)
		SRJ->(DbSkip())
		Loop
	EndIf

	cEstrut += "<qpf:Funcao>"+CHR(10)
	cEstrut += 		"<qpf:codigoFuncao>"
	cEstrut +=  		Alltrim(SRJ->RJ_FUNCAO)
	cEstrut += 		"</qpf:codigoFuncao>"+CHR(10)
	cEstrut +=		"<qpf:nomeFuncao>"
	cEstrut +=			Alltrim(SRJ->RJ_DESC)
	cEstrut +=		"</qpf:nomeFuncao>"+CHR(10)
	cEstrut +=		"<qpf:tipoFuncao>"
	cEstrut +=			Alltrim(SRJ->RJ_ADTPFUN)
	cEstrut +=		"</qpf:tipoFuncao>"+CHR(10)
	cEstrut +=		"<qpf:regimeJuridico>"
	cEstrut +=			Alltrim(SRJ->RJ_ADTPJU)
	cEstrut +=		"</qpf:regimeJuridico>"+CHR(10)
	cEstrut +=		"<qpf:escolaridade>"
	cEstrut +=			Alltrim(SRJ->RJ_ADTPESC)
	cEstrut +=		"</qpf:escolaridade>"+CHR(10)
	cEstrut +=		"<qpf:exercicioAtividade>"
	cEstrut +=			Alltrim(SRJ->RJ_ADATIV)
	cEstrut +=		"</qpf:exercicioAtividade>"+CHR(10)
	cEstrut +=		"<qpf:formaProvimento>"
	cEstrut +=			Alltrim(SRJ->RJ_ADTPROV)
	cEstrut +=		"</qpf:formaProvimento>"+CHR(10)
	cEstrut +=		"<qpf:totalHorasTrabalho>"
	cEstrut +=			cValToChar(SRJ->RJ_ADHORAS)
	cEstrut +=		"</qpf:totalHorasTrabalho>"+CHR(10)
	cEstrut += "</qpf:Funcao>"+CHR(10)

	SRJ->(DbSkip())

EndDo

cEstrut +=  "</qpf:ListaFuncoes>"+CHR(10)

cEstrut += "</qpf:Funcoes>"+CHR(10)
RestArea(aArea)

Return( cEstrut )

/*/{Protheus.doc}criaXMLTp5()
- Função responsável por gerar o XML para o tipo 5 - Lotações Agentes Públicos

@author: 	Matheus Bizutti
@since:	 	22/11/2016
@version: 	1.0
/*/
Static Function criaXMLTp5(cFilDe,cFilAte,cTpProc,cSource,cCodEnt,cCodMun,cExAno,cAnoMes,cDtCompDe,cDtCompAt,cDataGer,cSituac,cCateg,cTpXML)

Local cEstrut  		:= ""
Local cEstrutL		:= ""
Local cEstrutH		:= ""
Local cCTTCodMun	:= ""
Local cCTTNome		:= ""
Local cAliasQry		:= GetNextAlias()
Local cArqTemp		:= ""
Local cIndiTemp		:= ""
Local cSitAfast		:= ""
Local lExp			:= .F.
Local cSitQuery		:= ""
Local cCatQuery		:= ""
// - Valida os valores passados como parâmetro para a função.
DEFAULT cFilDe 		:= MV_PAR01
DEFAULT cFilAte 	:= MV_PAR02
DEFAULT cTpProc 	:= cValToChar(MV_PAR03)
DEFAULT cSource 	:= Alltrim(MV_PAR04)
DEFAULT cCodEnt 	:= MV_PAR05
DEFAULT cCodMun 	:= MV_PAR06
DEFAULT cExAno  	:= Substr(MV_PAR07,1,4)
DEFAULT cAnoMes 	:= MV_PAR08
DEFAULT cDtCompDe	:= DToS(MV_PAR09)
DEFAULT cDtCompAt	:= DToS(MV_PAR10)
DEFAULT cDataGer	:= DToS(MV_PAR11)
DEFAULT cSituac 	:= Alltrim(MV_PAR12)
DEFAULT cCateg 		:= Alltrim(MV_PAR13)
DEFAULT cTpXML		:= Alltrim(MV_PAR14)

cDtCompDe := DTOS(MV_PAR09)
cDtCompAt := DTOS(MV_PAR10)

cSitQuery := Upper("%" + fSqlIN( cSituac, 1 ) + "%")
cCatQuery := Upper("%" + fSqlIN( cCateg, 1 ) + "%")

// - Exemplo para o tipo 5
cEstrut := '<?xml version="1.0" encoding="ISO-8859-1"?>' +CHR(10)
cEstrut += "<LotacaoAgentePublico xmlns:gen='http://www.tce.sp.gov.br/audesp/xml/generico' "+CHR(10)
cEstrut += "xmlns:ap='http://www.tce.sp.gov.br/audesp/xml/atospessoal' "+CHR(10)
cEstrut += "xmlns:qpla='http://www.tce.sp.gov.br/audesp/xml/quadrofuncional-lotacaoagentepublico' "+CHR(10)
cEstrut += "xmlns='http://www.tce.sp.gov.br/audesp/xml/quadrofuncional-lotacaoagentepublico' "+CHR(10)
cEstrut += "xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' "+CHR(10)
cEstrut += "xsi:schemaLocation='http://www.tce.sp.gov.br/audesp/xml/quadrofuncional-lotacaoagentepublico ../quadrofuncional/AUDESP_LOTACAOAGENTEPUBLICO_" + cExAno + "_A.XSD'> " + CHR(10)
cEstrut += "<Descritor>" +CHR(10)
cEstrut += 		"<gen:AnoExercicio>"
cEstrut += 			cExAno
cEstrut += 		"</gen:AnoExercicio>"+CHR(10)
cEstrut	+= 		"<gen:TipoDocumento>"
cEstrut +=			"Lotação Agente Público"
cEstrut += 		"</gen:TipoDocumento>"+CHR(10)
cEstrut += 		"<gen:Entidade>"
cEstrut += 			Alltrim(cCodent)
cEstrut += 		"</gen:Entidade>"+CHR(10)
cEstrut +=		"<gen:Municipio>"
cEstrut +=			cCodMun
cEstrut += 		"</gen:Municipio>"+CHR(10)
cEstrut +=		"<gen:DataCriacaoXML>"
cEstrut += 			Substr(cDataGer,7,4) + "-" + Substr(cDataGer,4,2) + "-" + Substr(cDataGer,1,2)
cEstrut +=		"</gen:DataCriacaoXML>"+CHR(10)
cEstrut += 	"</Descritor>"+CHR(10)

BeginSQL Alias cAliasQry
	SELECT * FROM %table:RS9% RS9
			 INNER JOIN %table:SRA% SRA
			 ON RS9.RS9_FILIAL = SRA.RA_FILIAL AND RS9.RS9_MAT = SRA.RA_MAT
			 WHERE RS9.RS9_FILIAL >= %exp:cFilDe% AND RS9.RS9_FILIAL <= %exp:cFilAte% AND
			 SRA.RA_SITFOLH IN (%exp:cSitQuery%) AND SRA.RA_CATFUNC IN (%exp:cCatQuery%) AND
			 RS9.%notDel% AND
			 SRA.%notDel%
EndSQL

DBSelectArea("SR8")
cArqTemp := CriaTrab(NIL,.F.)
cIndTemp := ( "R8_FILIAL+R8_MAT" )
IndRegua( 'SR8', cArqTemp, cIndTemp )

While (cAliasQry)->(!Eof())

	lExp := .F.


	If SR8->(DbSeek(xFilial("RS9") + (cAliasQry)->RS9_MAT))

		If ( DTOS(SR8->R8_DATAINI) >= cDtCompDe .And. ( Empty(DTOS(SR8->R8_DATAFIM)) .Or. (DTOS(SR8->R8_DATAFIM) <= cDtCompAt) ) ) .Or. ;
			 DTOS(SR8->R8_DATAFIM) >= cDtCompDe .And. DTOS(SR8->R8_DATAFIM) <= cDtCompAt

			 lExp := .T.

		EndIf

	EndIf

	If ( (cAliasQry)->RA_DEMISSA >= cDtCompDe .And. (cAliasQry)->RA_DEMISSA <= cDtCompAt );
		 .Or. ( (cAliasQry)->RA_ADMISSA >= cDtCompDe .And. (cAliasQry)->RA_ADMISSA <= cDtCompAt ) .Or. lExp

		// - Trecho referente a lotação do agente público.
		cEstrutL 	+= "<LotacaoAgentePublico>"+CHR(10)
		cEstrutL 	+= 	"<cpf Tipo='02'>"+CHR(10)
		cEstrutL 	+= 		"<gen:Numero>"
		cEstrutL 	+=     		Alltrim((cAliasQry)->RA_CIC)
		cEstrutL 	+= 		"</gen:Numero>" +CHR(10)
		cEstrutL 	+=		"</cpf>"+CHR(10)

		cEstrutL 	+= 		"<dataLotacao>"
		cEstrutL	+=     		Substr((cAliasQry)->RA_ADMISSA ,1,4) + "-" + Substr((cAliasQry)->RA_ADMISSA ,5,2) + "-" + Substr((cAliasQry)->RA_ADMISSA ,7,2)
		cEstrutL	+= 		"</dataLotacao>" +CHR(10)


		cEstrutL	+= 		"<exercicioAtividade>"

		// - Posicionar na CTT.
		DbSelectArea("CTT")
		CTT->(DbSetOrder(1))

		If CTT->( dbSeek(xFilial("CTT")+(cAliasQry)->RA_CC))
			cEstrutL 	+=  Alltrim((cAliasQry)->RS9_APATIV)
			cCTTCodMun  := 	cCodMun
			cCTTNome  := 	Alltrim(CTT->CTT_DESC01)
		Else
			cEstrutL 	+=  "2"
		Endif

		cEstrutL	 	+= "</exercicioAtividade>"+CHR(10)

		cEstrutL	 	+= "<codigoMunicipioCargo>"
		cEstrutL	 	+= 		cCTTCodMun
		cEstrutL	 	+= "</codigoMunicipioCargo>"+CHR(10)

		cEstrutL	 	+= "<codigoEntidadeCargo>"
		cEstrutL	 	+=    	cCodEnt
		cEstrutL	 	+= "</codigoEntidadeCargo>"+CHR(10)

		cEstrutL	 	+= "<codigoCargo>"
		cEstrutL	 	+=    Alltrim((cAliasQry)->RA_CARGO)
		cEstrutL	 	+= "</codigoCargo>"+CHR(10)

		cEstrutL	 	+= "<cargoRemunerado>"
		cEstrutL	 	+=    ""
		cEstrutL	 	+= "</cargoRemunerado>"+CHR(10)

		cEstrutL	 	+= "<unidadeLotacao>"
		cEstrutL	 	+=    cCTTNome
		cEstrutL	 	+= "</unidadeLotacao>"+CHR(10)

		cEstrutL	 	+= "<funcaoGoverno>"
		cEstrutL	 	+=   strzero(VAL((cAliasQry)->RS9_APFUN),2)
		cEstrutL	 	+= "</funcaoGoverno>"+CHR(10)

		cEstrutL	 	+= "<formaProvimento>"
		cEstrutL	 	+=    (cAliasQry)->RS9_APFPRO
		cEstrutL	 	+= "</formaProvimento>"+CHR(10)

		cEstrutL	 	+= "<dataExercicio>"
		cEstrutL	 	+=   Substr((cAliasQry)->RS9_APEXER,1,4) + "-" + Substr((cAliasQry)->RS9_APEXER,5,2) + "-" + Substr((cAliasQry)->RS9_APEXER,7,2)
		cEstrutL	 	+= "</dataExercicio>"+CHR(10)

		cEstrutL 		+= "</LotacaoAgentePublico>" +CHR(10)


		If ( (cAliasQry)->RA_ADMISSA >= cDtCompDe .And. (cAliasQry)->RA_ADMISSA <= cDtCompAt )
			// - Trecho referente ao histórico da lotação.
			cEstrutH += "<HistoricoLotacaoAgentePublico>"+CHR(10)

			cEstrutH += "<cpf Tipo='02'>"+CHR(10)
            cEstrutH += 	"<gen:Numero>"
            cEstrutH += 		Alltrim((cAliasQry)->RA_CIC)
            cEstrutH += 	"</gen:Numero>" +CHR(10)
            cEstrutH += "</cpf>" +CHR(10)
            cEstrutH += "<dataExercicio>"
			cEstrutH +=		Substr((cAliasQry)->RS9_APEXER,1,4) + "-" + Substr((cAliasQry)->RS9_APEXER,5,2) + "-" + Substr((cAliasQry)->RS9_APEXER,7,2)
			cEstrutH += "</dataExercicio>"+CHR(10)
			cEstrutH += "<dataLotacao>"
			cEstrutH +=		Substr((cAliasQry)->RA_ADMISSA ,1,4) + "-" + Substr((cAliasQry)->RA_ADMISSA ,5,2) + "-" + Substr((cAliasQry)->RA_ADMISSA ,7,2)
			cEstrutH += "</dataLotacao>" +CHR(10)
            cEstrutH += "<codigoMunicipioCargo>"
            cEstrutH +=  	cCTTCodMun
            cEstrutH += "</codigoMunicipioCargo>" +CHR(10)
            cEstrutH += "<codigoEntidadeCargo>"
            cEstrutH += 	cCodEnt
            cEstrutH += "</codigoEntidadeCargo>" +CHR(10)
            cEstrutH += "<codigoCargo>"
            cEstrutH += 	(cAliasQry)->RA_CODFUNC
            cEstrutH += "</codigoCargo>" +CHR(10)
            cEstrutH += "<dataHistoricoLotacao>"
            cEstrutH +=		Substr((cAliasQry)->RA_ADMISSA ,1,4) + "-" + Substr((cAliasQry)->RA_ADMISSA ,5,2) + "-" + Substr((cAliasQry)->RA_ADMISSA ,7,2)
            cEstrutH += "</dataHistoricoLotacao>" +CHR(10)
            cEstrutH += "<situacao>"
            cEstrutH += 	"1"
            cEstrutH +=  "</situacao>" +CHR(10) // - <!-- ATIVO. -->

            cEstrutH += "</HistoricoLotacaoAgentePublico>"+CHR(10)

		 ElseIf Select( "SR8" ) > 0 .And. SR8->R8_TPEFD == "21" .And. SR8->R8_TIPO = "P" .And. SR8->R8_DURACAO >= 15

			cEstrutH += "<HistoricoLotacaoAgentePublico>"+CHR(10)
			cEstrutH += "<cpf Tipo='02'>" +CHR(10)
            cEstrutH += 	"<gen:Numero>"
            cEstrutH +=			Alltrim((cAliasQry)->RA_CIC)
            cEstrutH +=  	"</gen:Numero>" +CHR(10)
            cEstrutH += "</cpf>" +CHR(10)
            cEstrutH += "<dataExercicio>"
			cEstrutH +=		Substr((cAliasQry)->RS9_APEXER,1,4) + "-" + Substr((cAliasQry)->RS9_APEXER,5,2) + "-" + Substr((cAliasQry)->RS9_APEXER,7,2)
			cEstrutH += "</dataExercicio>" +CHR(10)
			cEstrutH += "<dataLotacao>"
			cEstrutH +=		Substr((cAliasQry)->RA_ADMISSA ,1,4) + "-" + Substr((cAliasQry)->RA_ADMISSA ,5,2) + "-" + Substr((cAliasQry)->RA_ADMISSA ,7,2)
			cEstrutH += "</dataLotacao>" +CHR(10)
            cEstrutH += "<codigoMunicipioCargo>"
            cEstrutH +=  	cCTTCodMun
            cEstrutH += "</codigoMunicipioCargo>" +CHR(10)
            cEstrutH += "<codigoEntidadeCargo>"
            cEstrutH += 	cCodEnt
            cEstrutH += "</codigoEntidadeCargo>"  +CHR(10)
            cEstrutH += "<codigoCargo>"
            cEstrutH += 	(cAliasQry)->RA_CODFUN
            cEstrutH += "</codigoCargo>" +CHR(10)
            cEstrutH += "<dataHistoricoLotacao>"
            cEstrutH +=		Substr(DTOS(SR8->R8_DATAFIM) ,1,4) + "-" + Substr(DTOS(SR8->R8_DATAFIM) ,5,2) + "-" + Substr(DTOS(SR8->R8_DATAFIM) ,7,2)
            cEstrutH += "</dataHistoricoLotacao>"  +CHR(10)
            cEstrutH += "<situacao>"
            cEstrutH += 	"1"
            cEstrutH += "</situacao>" +CHR(10) // - <!-- ATIVO. -->

            cEstrutH += "</HistoricoLotacaoAgentePublico>"+CHR(10)

         Else

         	Do Case

				Case SR8->R8_TPEFD == "21"
					 cSitAfast := "10" //Licença sem vencimento

				Case SR8->R8_TIPO = "P" .And. SR8->R8_DURACAO >= 15
					cSitAfast := "11" //Licença saúde superior a 15 dias

				Case (cAliasQry)->RA_RESCRAI == "70"
					 cSitAfast := "2" //Aposentado

				Case (cAliasQry)->RA_RESCRAI == "23"
					 cSitAfast := "7" //Exonerado

				Case (cAliasQry)->RA_RESCRAI == "26"
					 cSitAfast := "6" //Encerramento de Lotação

				Case (cAliasQry)->RA_RESCRAI $ "09||10"
					 cSitAfast := "8" //Falecido

				Case (cAliasQry)->RA_RESCRAI == "21"
					 cSitAfast := "12" //Reformado

				Case (cAliasQry)->RA_RESCRAI == "22"
					 cSitAfast := "13" //Transferido para Reserva

				Otherwise
					 cSitAfast := "5" //Demitido
			EndCase

			cEstrutH := "<HistoricoLotacaoAgentePublico>"+CHR(10)
			cEstrutH += "<cpf Tipo='02'>" +CHR(10)
            cEstrutH += 	"<gen:Numero>"
            cEstrutH += 		Alltrim((cAliasQry)->RA_CIC)
            cEstrutH += 	"</gen:Numero>" +CHR(10)
            cEstrutH += "</cpf>" +CHR(10)
            cEstrutH += "<dataExercicio>"
			cEstrutH +=		Substr((cAliasQry)->RS9_APEXER,1,4) + "-" + Substr((cAliasQry)->RS9_APEXER,5,2) + "-" + Substr((cAliasQry)->RS9_APEXER,7,2)
			cEstrutH += "</dataExercicio>" +CHR(10)
			cEstrutH += "<dataLotacao>"
			cEstrutH +=		Substr((cAliasQry)->RA_ADMISSA ,1,4) + "-" + Substr((cAliasQry)->RA_ADMISSA ,5,2) + "-" + Substr((cAliasQry)->RA_ADMISSA ,7,2)
			cEstrutH += "</dataLotacao>" +CHR(10)
            cEstrutH += "<codigoMunicipioCargo>"
            cEstrutH += 	cCTTCodMun
            cEstrutH += "</codigoMunicipioCargo>"  +CHR(10)
            cEstrutH += "<codigoEntidadeCargo>"
            cEstrutH += 	cCodEnt
            cEstrutH += "</codigoEntidadeCargo>"  +CHR(10)
            cEstrutH += "<codigoCargo>"
            cEstrutH += 	(cAliasQry)->RA_CODFUNC
            cEstrutH += "</codigoCargo>" +CHR(10)
            cEstrutH += "<dataHistoricoLotacao>"
            cEstrutH +=		Substr((cAliasQry)->RA_ADMISSA ,1,4) + "-" + Substr((cAliasQry)->RA_ADMISSA ,5,2) + "-" + Substr((cAliasQry)->RA_ADMISSA ,7,2)
            cEstrutH += "</dataHistoricoLotacao>"  +CHR(10)
            cEstrutH += "<situacao>"
            cEstrutH +=  	cSitAfast
            cEstrutH += "</situacao>" +CHR(10)

			cEstrutH += "</HistoricoLotacaoAgentePublico>"+CHR(10)

		EndIf
		CTT->(DbCloseArea())
	EndIf

	(cAliasQry)->(DbSkip())

EndDo

(cAliasQry)->(DbCloseArea())

// - Corpo do XML.
cEstrut += 	"<ListaLotacaoAgentePublico>"+CHR(10)
cEstrut += 		cEstrutL
cEstrut += 	"</ListaLotacaoAgentePublico>"+CHR(10)
cEstrut += 	"<ListaHistoricoLotacaoAgentePublico>" +CHR(10)
cEstrut += 		cEstrutH
cEstrut += 	"</ListaHistoricoLotacaoAgentePublico>" +CHR(10)
cEstrut +=  "</LotacaoAgentePublico>"

Return( cEstrut )


Function VldDtComp(dData1, dData2)

Local lRet := .T.

DEFAULT dData1 := MV_PAR09
DEFAULt dData2 := MV_PAR10

If dData1 > dData2
	Aviso( STR0002, STR0021, { STR0022 } )
	//MsgInfo("A data de término da competência deve ser menor que a data inicial.")
	lRet := .F.
EndIf

Return( lRet )


/*/{Protheus.doc}criaXMLTp6()
- Função responsável por gerar o XML para o tipo 6 - Quadro de Pessoal

@author: 	Marcia Moura
@since:	 	28/11/2016
@version: 	1.0
/*/
Static Function criaXMLTp6(cFilDe,cFilAte,cTpProc,cSource,cCodEnt,cCodMun,cExAno,cExMes,cAnoMes,cDtCompDe,cDtCompAt,cDataGer,cSituac,cCateg,cTpXML)

Local cEstrut 		:= ""
Local cEstrutC		:= ""
Local cEstrutV		:= ""
Local cMesAux 		:= ""
Local cAnoAux 		:= ""
Local cDiaRCL		:= ""
Local cMesRCL	 	:= ""
Local cAnoRCL 		:= ""
Local nInd 	  		:= 1
Local aArea   		:= GetArea()
Local cCargo		:= ""
Local cCargoAux		:= ""
Local cQtTot		:= ""
Local nQtTot		:=0
Local cQtPrv		:= ""
Local nQtPrv		:=0
Local cQtNPrv		:= ""
Local nQtNPrv		:=0

// - Valida os valores passados como parâmetro para a função.
DEFAULT cFilDe 		:= MV_PAR01
DEFAULT cFilAte 	:= MV_PAR02
DEFAULT cTpProc 	:= cValToChar(MV_PAR03)
DEFAULT cSource 	:= Alltrim(MV_PAR04)
DEFAULT cCodEnt 	:= MV_PAR05
DEFAULT cCodMun 	:= MV_PAR06
DEFAULT cExAno  	:= Substr(MV_PAR07,1,4)
DEFAULT cExMes  	:= Substr(MV_PAR07,5,2)
DEFAULT cAnoMes 	:= MV_PAR08
DEFAULT cDtCompDe	:= DToc(MV_PAR09)
DEFAULT cDtCompAt	:= DToc(MV_PAR10)
DEFAULT cDataGer	:= DToC(MV_PAR11)
DEFAULT cSituac 	:= Alltrim(MV_PAR12)
DEFAULT cCateg 		:= Alltrim(MV_PAR13)
DEFAULT cTpXML		:= Alltrim(MV_PAR14)

// - Exemplo para o tipo 6
cEstrut := '<?xml version="1.0" encoding="ISO-8859-1"?>' +CHR(10)
cEstrut += "<qp:QuadroPessoal xmlns:qp='http://www.tce.sp.gov.br/audesp/xml/quadropessoal' " +CHR(10)
cEstrut += "xmlns:gen='http://www.tce.sp.gov.br/audesp/xml/generico' " +CHR(10)
cEstrut += "xmlns:ap='http://www.tce.sp.gov.br/audesp/xml/atospessoal' " +CHR(10)
cEstrut += "xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' " +CHR(10)
cEstrut += "xsi:schemaLocation='http://www.tce.sp.gov.br/audesp/xml/quadropessoal ../quadropessoal/AUDESP_QUADROPESSOAL_" + cExAno + "_A.XSD'> " + CHR(10)

cEstrut += "<qp:Descritor>" +CHR(10)
cEstrut += 		"<gen:AnoExercicio>"
cEstrut += 			cExAno
cEstrut += 		"</gen:AnoExercicio>" +CHR(10)
cEstrut	+= 		"<gen:TipoDocumento>"
cEstrut +=			"Quadro de Pessoal"
cEstrut += 		"</gen:TipoDocumento>" +CHR(10)
cEstrut += 		"<gen:Entidade>"
cEstrut += 			cCodent
cEstrut += 		"</gen:Entidade>" +CHR(10)
cEstrut +=		"<gen:Municipio>"
cEstrut +=			cCodMun
cEstrut += 		"</gen:Municipio>" +CHR(10)
cEstrut +=		"<gen:DataCriacaoXML>"
cEstrut += 			Substr(cDataGer,7,4) + "-" + Substr(cDataGer,4,2) + "-" + Substr(cDataGer,1,2)
cEstrut +=		"</gen:DataCriacaoXML>" +CHR(10)
cEstrut +=		"<gen:MesExercicio>"
cEstrut += 			Alltrim(Str(Val(cExMes)))
cEstrut +=		"</gen:MesExercicio>" +CHR(10)
cEstrut += 	"</qp:Descritor>" +CHR(10)

cMesAux := Substr(cAnoMes,1,2)
cAnoAux	:= SubStr(cAnoMes,3,4)

DbSelectArea("RCL")
RCL->(DbSetOrder(5))
RCL->(DbGoTop())

If cTpProc == "1" .or. cTpProc == "2"

	cCargoAux := RCL->RCL_CARGO
	cEstrut += 	"<qp:ListaQuadroPessoal>" +CHR(10)

	While RCL->(!Eof())

		If RCL->RCL_FILIAL >= cFilDe .And. RCL->RCL_FILIAL <= cFilAte

			cCargo := RCL->RCL_CARGO
			// --------------------------------------------------------
			// - Efetua a Totalização
			// - E após haver a troca de Cargo é gerado o corpo do XML.
			// --------------------------------------------------------
			If cCargoAux == cCargo
				nQtTot =+ RCL->RCL_NPOSTO
				nQtPrv =+ RCL->RCL_OPOSTO
			Else
				If !Empty( cCargoAux )
					fImpCargo(@cEstrut,cCargoAux,nQtTot,nQtPrv,cCodMun,cCodEnt)
				EndIf

				cCargoAux := RCL->RCL_CARGO
				nQtPrv := 0
				nQtTot := 0
			Endif

		EndIf

			RCL->(DbSkip())
	EndDo

	If !Empty( cCargoAux )
		fImpCargo(@cEstrut,cCargoAux,nQtTot,nQtPrv,cCodMun,cCodEnt)
	EndIf

	cEstrut += 	"</qp:ListaQuadroPessoal>" +CHR(10)
EndIf

cEstrut += "</qp:QuadroPessoal>" +CHR(10)

RestArea(aArea)

Return( cEstrut )

/*/{Protheus.doc}fImpCargo()
- Função responsável por gerar o detalhe do XML para o tipo 6 - Quadro de Pessoal

@author: 	Jônatas Alves
@since:	 	04/04/2017
@version: 	1.0
/*/
Static Function fImpCargo(cEstrut,cCargoAux,nQtTot,nQtPrv,cCodMun,cCodEnt)

DEFAULT cEstrut		:= ""
DEFAULT cCargoAux	:= ""
DEFAULT nQtTot		:= 0
DEFAULT nQtPrv		:= 0

If nQtTot > 0

	cEstrut += 		"<qp:QuadroPessoal>" +CHR(10)

	cEstrut	+= 			"<qp:codigoMunicipioCargo>"
	cEstrut	+= 				cCodMun
	cEstrut	+= 			"</qp:codigoMunicipioCargo>"+CHR(10)

	cEstrut	+= 			"<qp:codigoEntidadeCargo>"
	cEstrut	+=    			cCodEnt
	cEstrut	+= 			"</qp:codigoEntidadeCargo>"+CHR(10)

	cEstrut +=			"<qp:codigoCargo>"
	cEstrut +=				cCargoAux
	cEstrut +=			"</qp:codigoCargo>" +CHR(10)

	cEstrut +=			"<qp:quantidadeTotalVagas>"
	cEstrut +=				Alltrim(Str(nQtTot))
	cEstrut +=			"</qp:quantidadeTotalVagas>" +CHR(10)

	cEstrut +=			"<qp:quantidadeVagasProvidas>"
	cEstrut +=				Alltrim(Str(nQtPrv,3))
	cEstrut +=			"</qp:quantidadeVagasProvidas>" +CHR(10)

	cEstrut +=			"<qp:quantidadeVagasNaoProvidas>"
	cEstrut +=				Alltrim(Str(Max(nQtTot-nQtPrv,0)))
	cEstrut +=			"</qp:quantidadeVagasNaoProvidas>" +CHR(10)

	cEstrut += 		"</qp:QuadroPessoal>" +CHR(10)
EndIf

Return
/*/{Protheus.doc}criaXMLTp7()
- Função responsável por gerar o XML para o tipo 7 - Verbas Remuneratórias

@author: 	Claudinei Soares
@since:	27/03/2017
@version: 	1.0
/*/
Static Function criaXMLTp7(cFilDe,cFilAte,cTpProc,cSource,cCodEnt,cCodMun,cExAno,cExMes,cAnoMes,cDtCompDe,cDtCompAt,cDataGer,cSituac,cCateg,cTpXML)

Local cEstrut 		:= ""
Local aArea   		:= GetArea()
Local cTeto			:= ""

// - Valida os valores passados como parâmetro para a função.
DEFAULT cFilDe 	:= MV_PAR01
DEFAULT cFilAte 	:= MV_PAR02
DEFAULT cTpProc 	:= cValToChar(MV_PAR03)
DEFAULT cCodEnt 	:= MV_PAR05
DEFAULT cCodMun 	:= MV_PAR06
DEFAULT cExAno  	:= Substr(MV_PAR07,1,4)
DEFAULT cExMes  	:= Substr(MV_PAR07,5,2)
DEFAULT cDataGer	:= DToC(MV_PAR11)
DEFAULT cTpXML	:= Alltrim(MV_PAR14)

// - Exemplo para o tipo 7
cEstrut := '<?xml version="1.0" encoding="ISO-8859-1"?>' +CHR(10)
cEstrut += "<cap:CadastroVerbasRemuneratorias xmlns:gen='http://www.tce.sp.gov.br/audesp/xml/generico' " +CHR(10)
cEstrut += "xmlns:ap='http://www.tce.sp.gov.br/audesp/xml/atospessoal' " +CHR(10)
cEstrut += "xmlns:aux='http://www.tce.sp.gov.br/audesp/xml/auxiliar' " +CHR(10)
cEstrut += "xmlns:cap='http://www.tce.sp.gov.br/audesp/xml/remuneracao' " +CHR(10)
cEstrut += "xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' " +CHR(10)
cEstrut += "xsi:schemaLocation='http://www.tce.sp.gov.br/audesp/xml/remuneracao ../verbasremuneratorias/AUDESP_VERBAS_REMUNERATORIAS_" + cExAno + "_A.XSD'> " + CHR(10)


cEstrut += "<cap:Descritor>" +CHR(10)
cEstrut += 		"<gen:AnoExercicio>"
cEstrut += 			AllTrim(cExAno)
cEstrut += 		"</gen:AnoExercicio>" +CHR(10)
cEstrut += 		"<gen:TipoDocumento>"
cEstrut +=			"Cadastro de Verbas Remuneratórias"
cEstrut += 		"</gen:TipoDocumento>" +CHR(10)
cEstrut += 		"<gen:Entidade>"
cEstrut += 			AllTrim(cCodent)
cEstrut += 		"</gen:Entidade>" +CHR(10)
cEstrut +=		"<gen:Municipio>"
cEstrut +=			AllTrim(cCodMun)
cEstrut += 		"</gen:Municipio>" +CHR(10)
cEstrut +=		"<gen:DataCriacaoXML>"
cEstrut += 			Substr(cDataGer,7,4) + "-" + Substr(cDataGer,4,2) + "-" + Substr(cDataGer,1,2)
cEstrut +=		"</gen:DataCriacaoXML>" +CHR(10)
cEstrut += 	"</cap:Descritor>" +CHR(10)

DbSelectArea("SRV")
SRV->(DbSetOrder(1))
SRV->(DbGoTop())

If cTpProc == "1" .or. cTpProc == "2"

	If !Empty(SRV->RV_FILIAL)
		dbSeek( cFilDe, .T. )
	Endif

	While SRV->(!Eof()) .And. (SRV->RV_FILIAL >= cFilDe .Or. Empty(SRV->RV_FILIAL) ) .And. SRV->RV_FILIAL <= cFilAte

		If Empty(SRV->RV_CODREMU)
			SRV->(DbSkip())
			Loop
		Endif

		cTeto := If(Empty(SRV->RV_BSEREMT), "3", Alltrim(SRV->RV_BSEREMT) )

		cEstrut +=		"<cap:VerbasRemuneratorias>" + CHR(10)
		cEstrut +=       	"<cap:Codigo>"
		cEstrut +=				AllTrim(SRV->RV_COD)
		cEstrut +=			"</cap:Codigo>" + CHR(10)
		cEstrut +=			"<cap:Nome>"
		cEstrut +=				AllTrim(SRV->RV_DESC)
		cEstrut +=			"</cap:Nome>" + CHR(10)
		cEstrut +=			"<cap:EntraNoCalculoDoTetoConstitucional>"
		cEstrut +=				cTeto
		cEstrut +=			"</cap:EntraNoCalculoDoTetoConstitucional>" + CHR(10)
		cEstrut +=		"</cap:VerbasRemuneratorias>" + CHR(10)

		SRV->(DbSkip())

	EndDo

EndIf

cEstrut += "</cap:CadastroVerbasRemuneratorias>" + CHR(10)

RestArea(aArea)

Return( cEstrut )

/*/{Protheus.doc}criaXMLTp8()
Função responsável por gerar o XML para o tipo 8 - Folha Ordinária
@author: 	Claudinei Soares
@since:	28/03/2017
@version: 	1.0
/*/
Static Function criaXMLTp8(cFilDe,cFilAte,cTpProc,cSource,cCodEnt,cCodMun,cExAno,cExMes,cAnoMes,cDtCompDe,cDtCompAt,cDataGer,cSitFunc,cCateg,cTpXML)

	Local cEstrut 	:= ""
	Local cSituac	:= ""
	Local cExDia	:= ""
	Local nAf		:= 0
	Local nXm		:= 0
	Local nPD		:= 0
	Local nFunGov	:= 0
	Local dDtPesq1	:= CTOD("//")
	Local dDtPesq2	:= CTOD("//")
	Local aArea   	:= GetArea()
	Local aDadosAg	:= {}
	Local aBuscaAf	:= {}
	Local aPdDet	:= {}
	Local aPdTot	:= {}
	Local cTagQtde	:= ""
	Local lFuncDem	:= .F.

	// - Valida os valores passados como parâmetro para a função.
	DEFAULT cFilDe 	:= MV_PAR01
	DEFAULT cFilAte := MV_PAR02
	DEFAULT cTpProc := cValToChar(MV_PAR03)
	DEFAULT cCodEnt := MV_PAR05
	DEFAULT cCodMun := MV_PAR06
	DEFAULT cExAno  := Substr(MV_PAR07, 1, 4)
	DEFAULT cExMes  := Substr(MV_PAR07, 5, 2)
	DEFAULT cDataGer := DToC(MV_PAR11)
	DEFAULT cTpXML 	:= Alltrim(MV_PAR14)
	DEFAULT cCateg 	:= Alltrim(MV_PAR13)
	DEFAULT cSitFunc := MV_PAR12

	// - Exemplo para o tipo 8
	cEstrut :='<?xml version="1.0" encoding="ISO-8859-1"?>' + CHR(10)
	cEstrut += '<foap:FolhaOrdinariaAgentePublico' + CHR(10)
	cEstrut +=    'xmlns:ap="http://www.tce.sp.gov.br/audesp/xml/atospessoal"' + CHR(10)
	cEstrut +=    'xmlns:aux="http://www.tce.sp.gov.br/audesp/xml/auxiliar"' + CHR(10)
	cEstrut +=    'xmlns:foap="http://www.tce.sp.gov.br/audesp/xml/remuneracao"' + CHR(10)
	cEstrut +=    'xmlns:gen="http://www.tce.sp.gov.br/audesp/xml/generico"' + CHR(10)
	cEstrut +=    'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"' + CHR(10)
	cEstrut +=    'xsi:schemaLocation="http://www.tce.sp.gov.br/audesp/xml/remuneracao ./folhaOrdinaria/AUDESP_FOLHA_ORDINARIA_AGENTE_PUBLICO_' + cExAno + '_A.XSD">' + CHR(10)

	cEstrut += "<foap:Descritor>" + CHR(10)
	cEstrut += 		"<gen:AnoExercicio>"
	cEstrut += 			AllTrim(cExAno)
	cEstrut += 		"</gen:AnoExercicio>" + CHR(10)
	cEstrut += 		"<gen:TipoDocumento>"
	cEstrut +=			"Folha Ordinária"
	cEstrut += 		"</gen:TipoDocumento>" + CHR(10)
	cEstrut += 		"<gen:Entidade>"
	cEstrut += 			AllTrim(cCodent)
	cEstrut += 		"</gen:Entidade>" + CHR(10)
	cEstrut +=		"<gen:Municipio>"
	cEstrut +=			AllTrim(cCodMun)
	cEstrut += 		"</gen:Municipio>" + CHR(10)
	cEstrut +=		"<gen:DataCriacaoXML>"
	cEstrut += 			Substr(cDataGer,7,4) + "-" + Substr(cDataGer,4,2) + "-" + Substr(cDataGer,1,2)
	cEstrut +=		"</gen:DataCriacaoXML>" + CHR(10)
	cEstrut +=		"<gen:MesExercicio>"
	cEstrut += 			Substr(cAnoMes,1,2)
	cEstrut +=		"</gen:MesExercicio>" + CHR(10)
	cEstrut += 	"</foap:Descritor>" + CHR(10)

	DbSelectArea("RS9")
	RS9->(DbSetOrder(1))
	RS9->(DbGoTop())

	If cTpProc == "1" .or. cTpProc == "2"

		If !Empty(RS9->RS9_FILIAL)
			dbSeek( cFilDe, .T. )
		Endif

		While RS9->(!Eof()) .And. (RS9->RS9_FILIAL >= cFilDe .Or. Empty(RS9->RS9_FILIAL) ) .And. RS9->RS9_FILIAL <= cFilAte

			//Posiciona no registro da SRA
			DbSelectArea("SRA")
			SRA->(DbSetOrder(1))
			If SRA->(dbSeek( RS9->RS9_FILIAL + RS9->RS9_MAT ) .And. (SRA->RA_SITFOLH $ cSitFunc ) .And. (SRA->RA_CATFUNC $ cCateg ));
				.And. Dtos(SRA->RA_ADMISSA) <= Dtos(Ctod(cDtCompAt))
				
				cSituac 	:= RS9->RS9_SITUAC
				lFuncDem	:= .F.

				//Guarda se o funcionário está demitido em competência anterior
				If SRA->RA_SITFOLH == "D" .And. ANOMES(SRA->RA_DEMISSA) < SUBSTR(cAnoMes,3,4) + SUBSTR(cAnoMes,1,2)
					lFuncDem := .T.
				EndIf

				//Se a situação não estiver preenchida ou preenchida como não informada no cadastro de agentes, busca da SRA.
				If Empty(cSituac) .Or. cSituac $ "0"

					cSituac := SRA->RA_SITFOLH

					//Se a situação for afastado chama função para ver o tipo de afastamento
					If cSituac == "A"

						/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						³ Verifica se o Funcionario esta Afastado                    ³
						ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
						dDtPesq1 := SRA->RA_ADMISSA
						cExDia := Alltrim(STR(f_UltDia(CTOD("01/" + cExMes + "/" + cExAno))))
						dDtPesq2 := CTOD(cExDia + "/" + cExMes + "/" + cExAno)

						/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						³ Carrega os Afastamentos do Funcionario                     ³
						ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
						If fChkAfas(SRA->RA_FILIAL,SRA->RA_MAT, dDtPesq2, @dDtPesq2,,,dDtPesq2,YearSum(dDtPesq2, 1))
							fRetAfas(dDtPesq1, YearSum(dDtPesq2, 1),,,,, @aBuscaAf)
						EndIf

						/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						³ Ordena o Array pelo Inicio do Afastamento                  ³
						ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
						aSort( aBuscaAf,,,{ |x,y| x[3] < y[3] } )

						If LEN(abuscaAf) > 0
							nAf := LEN(abuscaAf)
							If (aBuscaAf[nAf,4] >= dDtPesq2 .Or. Empty(aBuscaAf[nAf,4]))
								If aBuscaAf[nAf,16] $ "O1|P1" .And. (aBuscaAf[nAf,11] > 15 .Or. Empty(aBuscaAf[nAf,4]) )
									cSituac := "11"
								ElseIf aBuscaAf[nAf,16] $ "X"
									cSituac := "10"
								Else
									cSituac := "1"
								Endif
							Endif
						EndIf

						If cSituac == "A"
							cSituac := "1"
						Endif
					ElseIf cSituac == "D"
						cSituac := "5"
					EndIf

				// Se a situação estiver preenchida no cadastro de agentes, faz o de/para.
				ElseIf cSituac $ "ABCD"
					Do Case
						Case cSituac == "A"
							cSituac := "10"
						Case cSituac == "B"
							cSituac := "11"
						Case cSituac == "C"
							cSituac := "12"
						Case cSituac == "D"
							cSituac := "13"
					End Case
				Endif
				
				f920ValPag(RS9->RS9_FILIAL,RS9->RS9_MAT,@aPdTot,@aPdDet)

				If !lFuncDem .Or. (lFuncDem .And. (Len(aPdTot) > 0 .And. (aPdTot[1,1] + aPdTot[1,2] + aPdTot[1,3] > 0)))
					aAdd( aDadosAg, { SRA->RA_CIC, SRA->RA_NOME, RS9->RS9_MUNLOT, RS9->RS9_ENTLOT, RS9->RS9_CARGOP, RS9->RS9_APFUN, If(SRA->RA_CATFUNC $ "E|G", "1", "2"), cSituac, RS9->RS9_REGJUR, RS9->RS9_AUTETO, RS9->RS9_NUPROC, aPdTot[1,1], aPdTot[1,2], aPdTot[1,3], SRA->RA_FILIAL, SRA->RA_MAT, SRA->RA_CARGO, SRA->RA_CODFUNC} )
				EndIf
			EndIf

			RS9->(DbSkip())

		EndDo

		For nXm := 1 To Len(aDadosAg)
			cEstrut += "<foap:IdentificacaoAgentePublico>"+CHR(10)
			cEstrut +=		'<ap:CPF Tipo="02">'+CHR(10)
			cEstrut +=			"<gen:Numero>"
			cEstrut +=				AllTrim(aDadosAg[nXm,1])
			cEstrut +=			"</gen:Numero>"+CHR(10)
			cEstrut +=		'</ap:CPF>'+CHR(10)
			cEstrut +=		"<ap:Nome>"
			cEstrut +=			AllTrim(aDadosAg[nXm,2])
			cEstrut +=		"</ap:Nome>"+CHR(10)
			cEstrut +=		"<ap:MunicipioLotacao>"
			cEstrut +=			AllTrim(aDadosAg[nXm,3])
			cEstrut +=		"</ap:MunicipioLotacao>"+CHR(10)
			cEstrut +=		"<ap:EntidadeLotacao>"
			cEstrut +=			AllTrim(aDadosAg[nXm,4])
			cEstrut +=		"</ap:EntidadeLotacao>"+CHR(10)
			cEstrut +=		"<ap:CargoPolitico>"
			cEstrut +=			AllTrim(aDadosAg[nXm,5])
			cEstrut +=		"</ap:CargoPolitico>"+CHR(10)
			cEstrut +=		"<ap:FuncaoGoverno>"
			If Empty(aDadosAg[nXm,6])
				cEstrut +=			"00"
			Else
				nFunGov := VAL(aDadosAg[nXm,6])
				cEstrut +=			STRZERO(nFunGov,2,0)
			Endif
			cEstrut +=		"</ap:FuncaoGoverno>"+CHR(10)
			cEstrut +=		"<ap:Estagiario>"
			cEstrut +=			AllTrim(aDadosAg[nXm,7])
			cEstrut +=		"</ap:Estagiario>"+CHR(10)

			If (!Empty(aDadosAg[nXm,17]))
				cEstrut +=		"<ap:CodigoCargo>"
				cEstrut +=			AllTrim(aDadosAg[nXm,17])
				cEstrut +=		"</ap:CodigoCargo>"+CHR(10)
			Else
				cEstrut +=		"<ap:CodigoFuncao>"
				cEstrut +=			AllTrim(aDadosAg[nXm,18])
				cEstrut +=		"</ap:CodigoFuncao>"+CHR(10)
			Endif

			cEstrut +=		"<ap:Situacao>"
			cEstrut +=			AllTrim(aDadosAg[nXm,8])
			cEstrut +=		"</ap:Situacao>"+CHR(10)
			cEstrut +=		"<ap:RegimeJuridico>"
			cEstrut +=			AllTrim(aDadosAg[nXm,9])
			cEstrut +=		"</ap:RegimeJuridico>"+CHR(10)
			cEstrut +=		"<ap:PossuiAutorizRecebAcimaTeto>"
			cEstrut +=			AllTrim(aDadosAg[nXm,10])
			cEstrut +=		"</ap:PossuiAutorizRecebAcimaTeto>"+CHR(10)
			cEstrut +=		"<ap:NumeroProcessoJudicial>"
			If Empty(aDadosAg[nXm,11])
				cEstrut +=			"0"
			Else
				cEstrut +=			AllTrim(aDadosAg[nXm,11])
			Endif
			cEstrut +=		"</ap:NumeroProcessoJudicial>"+CHR(10)
			cEstrut +=		"<foap:Valores>"+CHR(10)
			cEstrut +=			"<foap:totalGeralDaRemuneracaoBruta>"
			cEstrut +=				AllTrim(STR(aDadosAg[nXm,12]))
			cEstrut +=			"</foap:totalGeralDaRemuneracaoBruta>"+CHR(10)
			cEstrut +=			"<foap:totalGeralDeDescontos>"
			cEstrut +=				AllTrim(STR(aDadosAg[nXm,13]))
			cEstrut +=			"</foap:totalGeralDeDescontos>"+CHR(10)
			cEstrut +=			"<foap:totalGeralDaRemuneracaoLiquida>"
			cEstrut +=				AllTrim(STR(aDadosAg[nXm,14]))
			cEstrut +=			"</foap:totalGeralDaRemuneracaoLiquida>"+CHR(10)
			For nPd := 1 To Len(aPdDet)
				If aPdDet[nPd,6]+aPdDet[nPd,7] == aDadosAg[nXm,15]+aDadosAg[nXm,16]
					cEstrut +=			"<foap:Verbas>"+CHR(10)
					cEstrut +=				"<foap:MunicipioVerbaRemuneratoria>"
					cEstrut +=					AllTrim(cCodMun)
					cEstrut +=				"</foap:MunicipioVerbaRemuneratoria>"+CHR(10)
					cEstrut +=				"<foap:EntidadeVerbaRemuneratoria>"
					cEstrut +=					AllTrim(cCodent)
					cEstrut +=				"</foap:EntidadeVerbaRemuneratoria>"+CHR(10)
					cEstrut +=				"<foap:CodigoVerbaRemuneratoria>"
					cEstrut +=					aPdDet[nPd,1]
					cEstrut +=				"</foap:CodigoVerbaRemuneratoria>"+CHR(10)
					cEstrut +=				"<foap:Valor>"
					cEstrut +=					AllTrim(STR(aPdDet[nPd,2]))
					cEstrut +=				"</foap:Valor>"+CHR(10)
					cEstrut +=				"<foap:Natureza>"
					cEstrut +=					aPdDet[nPd,3]
					cEstrut +=				"</foap:Natureza>"+CHR(10)
					cEstrut +=				"<foap:Especie>"
					cEstrut +=					aPdDet[nPd,4]
					cEstrut +=				"</foap:Especie>"+CHR(10)
					cEstrut +=				"<foap:TipoVerbaRemuneratoria>"+CHR(10)
					cEstrut +=				"<foap:CodigoTipoVerbaRemuneratoria>"
					cEstrut +=					aPdDet[nPd,5]
					cEstrut +=				"</foap:CodigoTipoVerbaRemuneratoria>"+CHR(10)
					cEstrut +=				"</foap:TipoVerbaRemuneratoria>"+CHR(10)
					If aPdDet[nPd,5] $ '107|123|124'
						Do Case
							Case aPdDet[nPd,5] == '107'
								cTagQtde := "QuantidadeHorasExtras>"
							Case aPdDet[nPd,5] == '123'
								cTagQtde := "QuantidadeDiasFerias>"
							Case aPdDet[nPd,5] == '124'
								cTagQtde := "QuantidadeDiasLicencaPremio>"
						EndCase
						cEstrut +=			"<foap:" + cTagQtde + cValToChar(aPdDet[nPd,8]) + "</foap:" + cTagQtde + CHR(10)
					EndIf
					cEstrut +=			"</foap:Verbas>"+CHR(10)
				Endif

			Next nPd

			cEstrut +=			"</foap:Valores>"+CHR(10)
			cEstrut += "</foap:IdentificacaoAgentePublico>"+CHR(10)
		Next nXm
	EndIf

	cEstrut += "</foap:FolhaOrdinariaAgentePublico>"
	RestArea(aArea)

Return( cEstrut )

/*/{Protheus.doc}criaXMLTp9()
Função responsável por gerar o XML para o tipo 9 - Pagamento da Folha Ordinária
@author: Claudinei Soares
@since: 06/04/2017
@version: 1.0
/*/
Static Function criaXMLTp9(cFilDe,cFilAte,cTpProc,cSource,cCodEnt,cCodMun,cExAno,cExMes,cAnoMes,cDtCompDe,cDtCompAt,cDataGer,cSituac,cCateg,cTpXML)

	Local cEstrut 	:= ""
	Local nXm		:= 0
	Local aArea   	:= GetArea()
	Local aDadosAg	:= {}
	Local aPdDet	:= {}
	Local aPdTot	:= {}

	// - Valida os valores passados como parâmetro para a função.
	DEFAULT cFilDe 		:= MV_PAR01
	DEFAULT cFilAte 	:= MV_PAR02
	DEFAULT cTpProc 	:= cValToChar(MV_PAR03)
	DEFAULT cCodEnt 	:= MV_PAR05
	DEFAULT cCodMun 	:= MV_PAR06
	DEFAULT cExAno  	:= Substr(MV_PAR07, 1, 4)
	DEFAULT cExMes  	:= Substr(MV_PAR07, 5, 2)
	DEFAULT cDataGer	:= DToC(MV_PAR11)
	DEFAULT cTpXML		:= Alltrim(MV_PAR14)
	DEFAULT cSitFunc 	:= MV_PAR12
	DEFAULT cCateg 		:= Alltrim(MV_PAR13)

	// - Exemplo para o tipo 8
	cEstrut :='<?xml version="1.0" encoding="ISO-8859-1"?>' + CHR(10)
	cEstrut += '<pfo:PagamentoFolhaOrdinariaAgentePublico' + CHR(10)
	cEstrut +=    'xmlns:ap="http://www.tce.sp.gov.br/audesp/xml/atospessoal"' + CHR(10)
	cEstrut +=    'xmlns:gen="http://www.tce.sp.gov.br/audesp/xml/generico"' + CHR(10)
	cEstrut +=    'xmlns:pfo="http://www.tce.sp.gov.br/audesp/xml/remuneracao"' + CHR(10)
	cEstrut +=    'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"' + CHR(10)
	cEstrut +=    'xsi:schemaLocation="http://www.tce.sp.gov.br/audesp/xml/remuneracao ./folhaOrdinaria/AUDESP_PAGAMENTO_FOLHA_ORDINARIA_AGENTE_PUBLICO_' + cExAno + '_A.XSD">' + CHR(10)

	cEstrut += "<pfo:Descritor>" + CHR(10)
	cEstrut += 		"<gen:AnoExercicio>"
	cEstrut += 			AllTrim(cExAno)
	cEstrut += 		"</gen:AnoExercicio>" + CHR(10)
	cEstrut += 		"<gen:TipoDocumento>"
	cEstrut +=			"Pagamento de Folha Ordinária"
	cEstrut += 		"</gen:TipoDocumento>" + CHR(10)
	cEstrut += 		"<gen:Entidade>"
	cEstrut += 			AllTrim(cCodent)
	cEstrut += 		"</gen:Entidade>" + CHR(10)
	cEstrut +=		"<gen:Municipio>"
	cEstrut +=			AllTrim(cCodMun)
	cEstrut += 		"</gen:Municipio>" + CHR(10)
	cEstrut +=		"<gen:DataCriacaoXML>"
	cEstrut += 			Substr(cDataGer,7,4) + "-" + Substr(cDataGer,4,2) + "-" + Substr(cDataGer,1,2)
	cEstrut +=		"</gen:DataCriacaoXML>" + CHR(10)
	cEstrut +=		"<gen:MesExercicio>"
	cEstrut += 			Substr(cAnoMes,1,2)
	cEstrut +=		"</gen:MesExercicio>" + CHR(10)
	cEstrut += "</pfo:Descritor>" + CHR(10)

	cEstrut += "<pfo:AnoPagamento>"
	cEstrut += 			AllTrim(cExAno)
	cEstrut += "</pfo:AnoPagamento>" + CHR(10)
	cEstrut += "<pfo:MesPagamento>"
	cEstrut += 			AllTrim(cExMes)
	cEstrut += "</pfo:MesPagamento>" + CHR(10)

	DbSelectArea("RS9")
	RS9->(DbSetOrder(1))
	RS9->(DbGoTop())

	If cTpProc == "1" .or. cTpProc == "2"

		If !Empty(RS9->RS9_FILIAL)
			dbSeek( cFilDe, .T. )
		Endif

		While RS9->(!Eof()) .And. (RS9->RS9_FILIAL >= cFilDe .Or. Empty(RS9->RS9_FILIAL) ) .And. RS9->RS9_FILIAL <= cFilAte

			//Posiciona no registro da SRA
			DbSelectArea("SRA")
			SRA->(DbSetOrder(1))
			If SRA->(dbSeek( RS9->RS9_FILIAL + RS9->RS9_MAT ) .And. (RA_SITFOLH $ cSituac ) .And. (RA_CATFUNC $ cCateg ));
				.And. Dtos(SRA->RA_ADMISSA) <= Dtos(Ctod(cDtCompAt))

				f920ValPag(RS9->RS9_FILIAL, RS9->RS9_MAT, @aPdTot, @aPdDet)

				aAdd( aDadosAg, { SRA->RA_CIC, RS9->RS9_MUNLOT, RS9->RS9_ENTLOT, SubStr(SRA->RA_BCDEPSA,1,3), SubStr(SRA->RA_BCDEPSA,4,5),SRA->RA_CTDEPSA, aPdTot[1,3], SRA->RA_FILIAL, SRA->RA_MAT} )
			EndIf

			RS9->(DbSkip())

		EndDo

		For nXm := 1 To Len(aDadosAg)
			cEstrut += "<pfo:IdentificacaoAgentePublico>"+CHR(10)
			cEstrut +=		'<pfo:CPF Tipo="02">'+CHR(10)
			cEstrut +=			"<gen:Numero>"
			cEstrut +=				AllTrim(aDadosAg[nXm,1])
			cEstrut +=			"</gen:Numero>"+CHR(10)
			cEstrut +=		'</pfo:CPF>'+CHR(10)
			cEstrut +=		"<pfo:MunicipioLotacao>"
			cEstrut +=			AllTrim(aDadosAg[nXm,2])
			cEstrut +=		"</pfo:MunicipioLotacao>"+CHR(10)
			cEstrut +=		"<pfo:EntidadeLotacao>"
			cEstrut +=			AllTrim(aDadosAg[nXm,3])
			cEstrut +=		"</pfo:EntidadeLotacao>"+CHR(10)
			cEstrut +=		"<pfo:formaPagamento>"
			cEstrut +=			"1"
			cEstrut +=		"</pfo:formaPagamento>"+CHR(10)
			cEstrut +=		"<pfo:numeroBanco>"
			If Empty(aDadosAg[nXm,4])
				cEstrut +=			"0"
			Else
				cEstrut +=			AllTrim(aDadosAg[nXm,4])
			EndIf
			cEstrut +=		"</pfo:numeroBanco>"+CHR(10)
			cEstrut +=		"<pfo:agencia>"
			If Empty(aDadosAg[nXm,5])
				cEstrut +=			"0"
			Else
				cEstrut +=			AllTrim(aDadosAg[nXm,5])
			EndIf
			cEstrut +=		"</pfo:agencia>"+CHR(10)
			cEstrut +=		"<pfo:ContaCorrente>"
			If Empty(aDadosAg[nXm,6])
				cEstrut +=			"0"
			Else
				cEstrut +=			AllTrim(aDadosAg[nXm,6])
			EndIf
			cEstrut +=		"</pfo:ContaCorrente>"+CHR(10)
			cEstrut +=			"<pfo:Valores>"+CHR(10)
			cEstrut +=				"<pfo:valorPagoContaCorrente>"
			cEstrut +=					AllTrim(STR(aDadosAg[nXm,7]))
			cEstrut +=				"</pfo:valorPagoContaCorrente>"+CHR(10)
			cEstrut +=				"<pfo:valorPagoOutrasFormas>"
			cEstrut +=					"0.00"
			cEstrut +=				"</pfo:valorPagoOutrasFormas>"+CHR(10)
			cEstrut +=			"</pfo:Valores>"+CHR(10)
			cEstrut += "</pfo:IdentificacaoAgentePublico>"+CHR(10)
		Next nXm
	EndIf

	cEstrut += "</pfo:PagamentoFolhaOrdinariaAgentePublico>"
	RestArea(aArea)

Return( cEstrut )

/*/{Protheus.doc}f920ValPag(cFilRS9, cMatRS9, @aPdTot, @aPdDet)
- Função responsável por buscar os valores e as verbas remuneratórias

@author: 	Claudinei Soares
@since:	05/04/2017
@version: 	1.0
@param: 	cFilial	, caractere	, filial do Agente público
@param: 	cMatricula	, caractere	, matrícula do Agente público

/*/

Static Function f920ValPag(cFilRS9, cMatRS9, aPdTot, aPdDet)

Local cEstrut 	:= ""
Local cMesAux 	:= ""
Local cAnoAux 	:= ""
Local aArea   	:= GetArea()
Local cAliasTmp	:= GetNextAlias()
Local cOrder 		:= ""
Local cSRVFil		:= ""
Local cExAno		:= ""
Local cExMes		:= ""
Local cPerRef		:= ""
Local nLiqPD		:= 0
Local nDescPD		:= 0
Local nTotPD		:= 0

DEFAULT aPdDet	:= {}
DEFAULT aPdTot	:= {}

cExMes := Substr(MV_PAR07,5,2)
cPerRef := (Substr(MV_PAR08,3,4)+Substr(MV_PAR08,1,2))

cSRVFil		:= xFilial("SRV", SRA->RA_FILIAL)
cOrder		:= "%SRD.RD_PD, SRD.RD_VALOR, SRV.RV_TIPOCOD, SRV.RV_ORIGEM, SRV.RV_CODREMU, SRA.RA_FILIAL, SRA.RA_MAT%"

aPdTot	:= {}

BeginSql alias cAliasTmp
	SELECT DISTINCT SRD.RD_PD, SRD.RD_VALOR, SRV.RV_ORIGEM, SRV.RV_TIPOCOD, SRV.RV_CODREMU, SRA.RA_FILIAL, SRA.RA_MAT, SRD.RD_HORAS
	FROM %table:SRA% SRA, %table:RS9% RS9, %table:SRV% SRV, %table:SRD% SRD
		 WHERE SRA.RA_FILIAL  = %exp:cFilRS9%
		   AND SRA.RA_MAT     = 	%exp:cMatRS9%
		   AND SRA.RA_FILIAL	 = RS9.RS9_FILIAL
		   AND SRA.RA_MAT		 = RS9.RS9_MAT
		   AND SRA.RA_FILIAL	 = SRD.RD_FILIAL
		   AND SRA.RA_MAT		 = SRD.RD_MAT
		   AND SRV.RV_TIPOCOD IN ('1','2')
		   AND SRV.RV_COD 	 = SRD.RD_PD
		   AND SRD.RD_PERIODO = %exp:cPerRef%
		   AND SRV.RV_CODREMU <> ''
		   AND SRA.%notDel%
		   AND RS9.%notDel%
		   AND SRD.%notDel%
		   AND SRV.%notDel%
	ORDER BY %exp:cOrder%
EndSql


While (cAliasTmp)->(!Eof())

		If (cAliasTmp)->RV_TIPOCOD == "1"
			nTotPD += (cAliasTmp)->RD_VALOR
		ElseIF (cAliasTmp)->RV_TIPOCOD == "2"
			nDescPD += (cAliasTmp)->RD_VALOR
		Endif

		aAdd( aPdDet, { (cAliasTmp)->RD_PD, (cAliasTmp)->RD_VALOR, (cAliasTmp)->RV_ORIGEM, Iif((cAliasTmp)->RV_TIPOCOD == "2", "1", "2"), (cAliasTmp)->RV_CODREMU,(cAliasTmp)->RA_FILIAL, (cAliasTmp)->RA_MAT, (cAliasTmp)->RD_HORAS} )

	(cAliasTmp)->(dbSkip())
EndDo

(cAliasTmp)->(DbCloseArea())

nLiqPd := (nTotPD - nDescPD)

aAdd( aPdTot, { nTotPd, nDescPd, nLiqPd } )

Return( Nil )

/*/{Protheus.doc}criaXMLTp0()
- Função responsável por gerar o XML para o tipo 0 - Resumo Mensal da Folha de Pagamento

@author: 	Jônatas Alves
@since:	 	04/04/2017
@version: 	1.0
/*/
Static Function criaXMLTp0(cFilDe,cFilAte,cTpProc,cSource,cCodEnt,cCodMun,cExAno,cAnoMes,cDtCompDe,cDtCompAt,cDataGer,cSituac,cCateg,cTpXML)

Local cEstrut 		:= ""
Local cMesAux 		:= ""
Local cAnoAux 		:= ""
Local cAliasTmp		:= GetNextAlias()
Local cOrder 		:= ""
local cSitQuery		:= ""
local cCatQuery		:= ""
Local cSRVFil		:= ""
Local cSRVJoin		:= ""
Local cChave		:= ""
Local cChaveAnt		:= ""
Local cExMes		:= ""
Local cINSSJub		:= ""
Local aArea   		:= GetArea()
Local aEncarg		:= Array(7)
Local nReg			:= 0
Local cPerRef		:= ""

DEFAULT cFilDe		:= MV_PAR01
DEFAULT cFilAte 	:= MV_PAR02
DEFAULT cTpProc 	:= cValToChar(MV_PAR03)
DEFAULT cCodEnt 	:= MV_PAR05
DEFAULT cCodMun 	:= MV_PAR06
DEFAULT cExAno  	:= Substr(MV_PAR07,1,4)
DEFAULT cAnoMes 	:= MV_PAR08
DEFAULT cDataGer	:= DToC(MV_PAR11)
DEFAULT cTpXML		:= Alltrim(MV_PAR14)

cExMes := Substr(MV_PAR07,5,2)
cPerRef := (Substr(MV_PAR08,3,4)+Substr(MV_PAR08,1,2))


// - Exemplo para o tipo 6
cEstrut := '<?xml version="1.0" encoding="ISO-8859-1"?>' +CHR(10)
cEstrut += "<rem:ResumoMensalFolhaPagamento  " +CHR(10)
cEstrut += " xmlns:gen='http://www.tce.sp.gov.br/audesp/xml/generico' " +CHR(10)
cEstrut += " xmlns:ap='http://www.tce.sp.gov.br/audesp/xml/atospessoal' " +CHR(10)
cEstrut += " xmlns:aux='http://www.tce.sp.gov.br/audesp/xml/auxiliar' " +CHR(10)
cEstrut += " xmlns:rem='http://www.tce.sp.gov.br/audesp/xml/remuneracao' " +CHR(10)
cEstrut += " xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' " +CHR(10)
cEstrut += " xsi:schemaLocation='http://www.tce.sp.gov.br/audesp/xml/remuneracao ../remuneracao/AUDESP_RESUMO_MENSAL_FOLHA_PAGAMENTO_" + cExAno + "_A.XSD'> " +CHR(10)

cEstrut += Space(4) +	"<rem:Descritor>" + CHR(10)

cEstrut += Space(12) +		"<gen:AnoExercicio>"
cEstrut += 					cExAno
cEstrut += 					"</gen:AnoExercicio>" + CHR(10)

cEstrut	+= Space(12) +		"<gen:TipoDocumento>"
cEstrut +=					"Resumo Mensal da Folha de Pagamento"
cEstrut += 					"</gen:TipoDocumento>" + CHR(10)

cEstrut += Space(12) +		"<gen:Entidade>"
cEstrut += 					cCodent
cEstrut += 					"</gen:Entidade>" + CHR(10)

cEstrut += Space(12) +		"<gen:Municipio>"
cEstrut +=					cCodMun
cEstrut += 					"</gen:Municipio>" + CHR(10)

cEstrut += Space(12) +		"<gen:DataCriacaoXML>"
cEstrut +=					Substr(cDataGer,7,4) + "-" + Substr(cDataGer,4,2) + "-" + Substr(cDataGer,1,2)
cEstrut +=					"</gen:DataCriacaoXML>" + CHR(10)

cEstrut += Space(12) +		"<gen:MesExercicio>"
cEstrut += 					Alltrim(Str(Val(cExMes)))
cEstrut +=					"</gen:MesExercicio>" + CHR(10)

cEstrut += Space(4) +	"</rem:Descritor>" + CHR(10)

cSRVFil		:= xFilial("SRV", SRA->RA_FILIAL)
cSRVJoin	:= "% " + FWJoinFilial("SRV", "SRA") + " %"
cOrder		:= "%RS9.RS9_MUNLOT, RS9.RS9_ENTLOT, SRV.RV_INSSJUB%"

// Modifica variaveis para a Query
For nReg:=1 to Len(cSituac)
	cSitQuery += "'"+Subs(cSituac,nReg,1)+"'"
	If ( nReg+1 ) <= Len(cSituac)
		cSitQuery += ","
	EndIf
Next nReg
cSitQuery := If( Empty( cSitQuery ), "' '", cSitQuery )
cSitQuery := "%" + cSitQuery + "%"

For nReg:=1 to Len(cCateg)
	cCatQuery += "'"+Subs(cCateg,nReg,1)+"'"
	If ( nReg+1 ) <= Len(cCateg)
		cCatQuery += ","
	EndIf
Next nReg
cCatQuery := If( Empty( cCatQuery ), "' '", cCatQuery )
cCatQuery := "%" + cCatQuery + "%"

BeginSql alias cAliasTmp
	SELECT RS9.RS9_MUNLOT, RS9.RS9_ENTLOT, SUM(SRD.RD_VALOR) RD_VALOR, SRV.RV_INSSJUB
	FROM %table:SRA% SRA, %table:RS9% RS9, %table:SRV% SRV, %table:SRD% SRD
	WHERE      SRA.RA_FILIAL BETWEEN %exp:cFilDe%   AND %exp:cFilAte%
		   AND SRA.RA_SITFOLH IN (%exp:Upper(cSitQuery)%)
		   AND SRA.RA_CATFUNC IN (%exp:Upper(cCatQuery)%)
		   AND SRA.RA_FILIAL	= RS9.RS9_FILIAL
		   AND SRA.RA_MAT		= RS9.RS9_MAT
		   AND SRA.RA_FILIAL	= SRD.RD_FILIAL
		   AND SRA.RA_MAT		= SRD.RD_MAT
		   AND SRV.RV_INSSJUB IN ('0','1','2','3','4')
		   AND SRD.RD_PD		= SRV.RV_COD
		   AND SRD.RD_PERIODO	= %exp:cPerRef%
		   AND SRA.%notDel%
		   AND RS9.%notDel%
		   AND SRD.%notDel%
		   AND SRV.%notDel%
	GROUP BY %exp:cOrder%
	ORDER BY %exp:cOrder%
EndSql

dbSelectArea(cAliasTmp)
(cAliasTmp)->(dbGoTop())

cChaveAnt := (cAliasTmp)->(RS9_MUNLOT + RS9_ENTLOT)

// Varre alias temporário com as informações de Contrib. Prev.
// e FGTS vinculadas à chave Município Lot. + Entidade Lot.(funcionário)
While (cAliasTmp)->(!Eof())

	cINSSJub	:= (cAliasTmp)->RV_INSSJUB
	cChave		:= (cAliasTmp)->(RS9_MUNLOT + RS9_ENTLOT)
	// --------------------------------------------------------
	// - Gera item do XML
	// --------------------------------------------------------
	If cChaveAnt == cChave
		aEncarg[Val(cINSSJub)+3] := Alltrim(Transform((cAliasTmp)->RD_VALOR,"@R 999999999.99"))
		aEncarg[1] := (cAliasTmp)->RS9_MUNLOT
		aEncarg[2] := (cAliasTmp)->RS9_ENTLOT
	Else
		If !Empty(aEncarg[1]) .And. !Empty(aEncarg[2])
			fImpResumo(@cEstrut,aEncarg[1],aEncarg[2],aEncarg[3],aEncarg[4],aEncarg[5],aEncarg[6],aEncarg[7])
		EndIf
		aEncarg := Array(7)
		aEncarg[Val(cINSSJub)+3] := Alltrim(Transform((cAliasTmp)->RD_VALOR,"@R 999999999.99"))
		aEncarg[1] := (cAliasTmp)->RS9_MUNLOT
		aEncarg[2] := (cAliasTmp)->RS9_ENTLOT
		cChaveAnt := (cAliasTmp)->(RS9_MUNLOT + RS9_ENTLOT)
	Endif

	(cAliasTmp)->(dbSkip())
EndDo

(cAliasTmp)->(dbCloseArea())

// Imprime último elemento
If !Empty(aEncarg[1]) .And. !Empty(aEncarg[2])
	fImpResumo(@cEstrut,aEncarg[1],aEncarg[2],aEncarg[3],aEncarg[4],aEncarg[5],aEncarg[6],aEncarg[7])
EndIf

cEstrut += "</rem:ResumoMensalFolhaPagamento>" +CHR(10)

RestArea(aArea)

Return( cEstrut )

/*/{Protheus.doc}fImpResumo()
- Função responsável por gerar o detalhe do XML para o tipo 6 - Quadro de Pessoal

@author: 	Jônatas Alves
@since:	 	04/04/2017
@version: 	1.0
/*/
Static Function fImpResumo(cEstrut,cRS9MunLot,cRS9EntLot,cValFGTS,cValCPGAP,cValCPPAP,cValCPGAnP,cValCPPAnP)

DEFAULT cEstrut		:= ""
DEFAULT cRS9MunLot	:= ""
DEFAULT cRS9EntLot	:= ""
DEFAULT cValFGTS	:= "0.00"
DEFAULT cValCPGAP	:= "0.00"
DEFAULT cValCPPAP	:= "0.00"
DEFAULT cValCPGAnP	:= "0.00"
DEFAULT cValCPPAnP	:= "0.00"

// Trata valor padrão dos encargos
If cValFGTS == Nil .Or. Empty(cValFGTS)
	cValFGTS := "0.00"
EndIf

If cValCPGAP == Nil .Or. Empty(cValCPGAP)
	cValCPGAP := "0.00"
EndIf

If cValCPPAP == Nil .Or. Empty(cValCPPAP)
	cValCPPAP := "0.00"
EndIf

If cValCPGAnP == Nil .Or. Empty(cValCPGAnP)
	cValCPGAnP := "0.00"
EndIf

If cValCPPAnP == Nil .Or. Empty(cValCPPAnP)
	cValCPPAnP := "0.00"
EndIf

// Monta layout
cEstrut += Space(4) +	"<rem:ListaResumoFolhaPagamento>" + CHR(10)

cEstrut += Space(8) +		"<rem:MunicipioEntidadeLotacao>" + CHR(10)

cEstrut += Space(12) +			"<gen:codigoMunicipio>"
cEstrut +=						cRS9MunLot
cEstrut +=						"</gen:codigoMunicipio>" + CHR(10)

cEstrut += Space(12) +			"<gen:codigoEntidade>"
cEstrut +=						cRS9EntLot
cEstrut +=						"</gen:codigoEntidade>" + CHR(10)

cEstrut += Space(8) +		"</rem:MunicipioEntidadeLotacao>" + CHR(10)

cEstrut += Space(8) +		"<rem:VlFGTS>"
cEstrut +=					cValFGTS
cEstrut +=					"</rem:VlFGTS>" + CHR(10)

cEstrut += Space(8) +		"<rem:VlContribPrevGeralAgPolitico>"
cEstrut +=					cValCPGAP
cEstrut +=					"</rem:VlContribPrevGeralAgPolitico>" + CHR(10)

cEstrut += Space(8) +		"<rem:VlContribPrevProprioAgPolitico>"
cEstrut +=					cValCPPAP
cEstrut +=					"</rem:VlContribPrevProprioAgPolitico>" + CHR(10)

cEstrut += Space(8) +		"<rem:VlContribPrevGeralAgNaoPolitico>"
cEstrut +=					cValCPGAnP
cEstrut +=					"</rem:VlContribPrevGeralAgNaoPolitico>" + CHR(10)

cEstrut += Space(8) +		"<rem:VlContribPrevProprioAgNaoPolitico>"
cEstrut +=					cValCPPAnP
cEstrut +=					"</rem:VlContribPrevProprioAgNaoPolitico>" + CHR(10)

cEstrut += Space(4) +	"</rem:ListaResumoFolhaPagamento>" + CHR(10)

Return


/*/{Protheus.doc} AvalSRA
Avalia se um registro deve ser incluído no XML da carga inicial
@author Cícero Alves
@since 28/08/2019
@param DtCompDe, Data, Data inicial para o processamento
@param DtCompAt, Data, Data final para o processamento
/*/
Static Function AvalSRA(DtCompDe, DtCompAt)

	lValido := .T.

	If SRA->((!Empty(RA_DEMISSA) .And. RA_DEMISSA < DtCompDe) .Or. (RA_ADMISSA > DtCompAt) )
		lValido := .F.
	EndIf

Return lValido
