#INCLUDE "FISA051.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "FILEIO.CH"

Static TagNotas	:= "listaNotasFiscais"
Static TagChv	:= "chaveNFe"
Static TagPri	:= "arquivoNotasDeclararAutodesembaraco"
Static TagNumIt	:= "numItens"
Static TagProd	:= "produto"
Static TagItem	:= "numItemNFe"
Static TagPrFor	:= "codProdutoNFe"
Static TagDesFor:= "descProduto"
Static TagItVal	:= "valorItemNFe"
Static TagItEAN	:= "codEAN"
Static TagItNCM := "codNCM"
Static TagAno	:= "anoApresentacao"
Static TagMes	:= "mesApresentacao"
Static UFSSE	:= "RS/SC/PR/SP/RJ/ES/MG"
Static UFCodSSE	:= "43/42/41/35/33/32/31"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FISA051  บAutor  ณCaio Martins        บ Data ณ 10/08/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ          ณ FUNวรO PRINCIPAL DA DIA - Declara็ใo de Interna็ใo AM      บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Importarแ um arquivo xml para comparar com a movimenta็ใo  บฑฑ
ฑฑบ          ณ mensal e irแ gerar um outro arquivo XML com o resultado    บฑฑ
ฑฑบ          ณ da compara็ใo.                                             บฑฑ
ฑฑบ          ณ vide exemplo de arquivo importado no final desde fonte     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FISA051()

Local	lCancel		:= .F.
Local	lWiz		:= .T.
Local   lGerou		:= .F.
Local	cNomWiz		:=	"FISA051"        
local	cFileDest	:= ""
Local 	cLib
Local	nRetType	:= 0

nRetType := GetRemoteType( @cLib )
QOut( cLib ) 

If !(CriaWizard(cNomWiz))
	MsgAlert(STR0001) //Nใo foi possํvel gerar o arquivo!//'Nใo foi possํvel gerar o arquivo!'
	lWiz	:= .F.
EndIf

If lWiz
	Processa({|| ProcDIA(@cFileDest, @lCancel, cNomWiz, @lGerou)},,,.T.)

	If lCancel
		ApMsgStop(STR0002) //'Cancelado pelo usuแrio'
	Else
		If lGerou
			IF	nRetType == 5 //"HTML" $ cLib
				nRetCpy := CPYS2TW(cFileDest)
				If nRetCpy == 0
					FErase (cFileDest)
		   		EndIf
				MsgInfo(STR0003+" "+STR0004)//'Arquivo gerado com sucesso!' 
			ELSE
				MsgInfo(STR0003+cFileDest+STR0004)//'Arquivo '//' gerado com sucesso!' 
			ENDIF
		Else
			MsgAlert(STR0005)//'Nใo foi possํvel gerar o arquivo!'
		EndIf
	EndIf
EndIf
                                                        
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCriaWizardบAutor  ณCaio Martins        บ Data ณ 10/08/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria wizard para a geracao do arquivo, com dados iniciais  บฑฑ
ฑฑบ          ณ informados pelo usuแrio.                                   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑณParametros| cNomWiz -> Nome para a Wizard.                             ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CriaWizard(cNomWiz)	
	
Local	aTxtApre	:=	{}
Local	aPaineis	:=	{}
Local	cTitObj1	:=	""
Local	cTitObj2	:=	""	
Local	lRet		:=	.T.
Local	aItens		:=	{}
Local	cLib		:=	""
Local	nRetType	:= 0

nRetType := GetRemoteType( @cLib )
QOut( cLib )
//
aAdd (aTxtApre, STR0006)//'DIA-Declara็ใo de Interna็ใo do Amazonas'
aAdd (aTxtApre, STR0007)//'Preencha corretamente as informa็๕es solicitadas'
aAdd (aTxtApre, "")
aAdd (aTxtApre, STR0008)//'Informe os dados necessแrios para a correta gera็ใo da obriga็ใo fiscal'
	
//ฺฤฤฤฤฤฤฤฤฟ
//ณPainel 0ณ
//ภฤฤฤฤฤฤฤฤู	
aAdd (aPaineis, {})
nPos	:=	Len (aPaineis)
aAdd (aPaineis[nPos], STR0009)//'Preencha corretamente as informa็๕es solicitadas'
aAdd (aPaineis[nPos], STR0010)//'Informa็๕es gerais'
aAdd (aPaineis[nPos], {})
//
cTitObj1	:=	STR0011 ;							 			cTitObj2	:=	STR0012 //Data de - Data Ate //'Data Inicial'//'Data Final'
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
//
aAdd (aPaineis[nPos][3], {2,,,3,,,,});							aAdd (aPaineis[nPos][3], {2,,,3,,,,}) 
//
aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})

cTitObj1	:=	STR0013 ;			   							cTitObj2	:=	STR0014   //Diretorio do Arquivo Destino / Nome arquivo Destino//'Diretorio do Arquivo da SEFAZ'//'Nome arquivo da SEFAZ'
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
//
cTitObj1	:=	Replicate ("X", 150	);							cTitObj2	:=	Replicate ("X", 50)
aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,150,,nRetType==5});	aAdd (aPaineis[nPos][3], {2,,IIF(nRetType==5,"",cTitObj2),1,,,,50})

aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})


cTitObj1	:= STR0015 ;										cTitObj2	:=	STR0016   //Diretorio do Arquivo Destino / Nome arquivo Destino//'Diretorio do Arquivo Destino'//'Nome do Arquivo Destino'
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
//
cTitObj1	:=	Replicate ("X", 50);							cTitObj2	:=	Replicate ("X", 20)
aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,50});				aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,20})

aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})

cTitObj1	:= "Versใo";										cTitObj2	:=	"Localizado na ZFM ?"
aAdd (aPaineis[nPos][3], {1, cTitObj1,1,,,,,});					aAdd (aPaineis[nPos][3], {1,cTitObj2,,,,,,})
//
cTitObj1	:=	Replicate ("X", 4);								AADD(aItens,"S-Sim")
																AADD(aItens,"N-Nao")

aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,4});					aAdd (aPaineis[nPos][3], {3,,"X",1,,aItens,,})

aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})

//ฺฤฤฤฤฤฤฤฤฟ
//ณPainel 1ณ
//ภฤฤฤฤฤฤฤฤู
aAdd (aPaineis, {})
nPos	:=	Len (aPaineis)
aAdd (aPaineis[nPos], STR0017) //Identifica็ใo do Contribuinte//'Preencha corretamente as informa็๕es solicitadas'
aAdd (aPaineis[nPos], STR0018 ) //'Identifica็ใo do Responsแvel'
aAdd (aPaineis[nPos], {})
//
cTitObj1	:=	STR0019//'Nome'
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {0,"",,,,,,})
//
cTitObj1	:=	Replicate ("X", 40)
aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,40});				aAdd (aPaineis[nPos][3], {0,"",,,,,,})
//
aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
//
cTitObj1	:=	STR0020//'Fone'
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {0,"",,,,,,})
//
cTitObj1	:=	Replicate ("X", 10)
aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,10});				aAdd (aPaineis[nPos][3], {0,"",,,,,,})
//
aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
//
cTitObj1	:=	STR0021//'E-Mail'
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {0,"",,,,,,})
//
cTitObj1	:=	Replicate ("X", 50)
aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,50});				aAdd (aPaineis[nPos][3], {0,"",,,,,,})
//
aAdd (aPaineis[nPos][3], {1,"",,,,,,});							aAdd (aPaineis[nPos][3], {1,"",,,,,,})


lRet	:=	xMagWizard (aTxtApre, aPaineis, cNomWiz)

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ProcDIA  บAutor  ณCaio Martins        บ Data ณ 10/08/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ          ณ Fun็ใo de processamento da DIA                             บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Importarแ um arquivo xml para comparar com a movimenta็ใo  บฑฑ
ฑฑบ          ณ mensal e irแ gerar um outro arquivo XML com o resultado    บฑฑ
ฑฑบ          ณ da compara็ใo.                                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ProcDIA(cFileDest,lCancel,cNomWiz,lGerou)

//Informa็๕es da Wizard
Local aWizard		:= {}
Local dDataDe		:= CToD("//")
Local dDataAte		:= CToD("//")
Local cDirOri		:= ""
Local cArqOri		:= ""
Local cDirDest		:= ""
Local cArqDest		:= ""

// Variแveis de Controle
Local lReconhece	:= .F.

//Contadores
Local nX			:= 0
Local nY			:= 0
Local nZ			:= 0

//Objetos
Local oXml			:= NIL

// Tags filhas
Local aAux			:= {}
Local aNf			:= {}
Local aXmlItem		:= {}

// Controle de arquivos temporแrios
Local cAliasCab		:= ""
Local cAliasDet		:= ""
Local aArq			:= {}

// Variแveis auxiliares
Local cError		:= ""
Local cWarning		:= ""
Local cAno			:= ""
Local cAnoMes       := ""
Local cMes			:= ""
Local cEspecie      := ""               //Especie Nota Fiscal
Local cNotas		:= ""
Local cChave		:= ""
Local cItem			:= ""
Local cNumItem		:= ""
Local cProdFor		:= ""
Local cValitem		:= ""
Local cCodTrib		:= ""
Local nMult			:= 0
Local cProd			:= ""
Local cFor			:= ""
Local cLoja			:= ""
Local cNCM			:= ""
Local cEAN			:= ""
Local cNCMEAN		:= ""
local cIndi			:= ""
Local aItensNf		:= {}
Local lOk			:= .T.
Local lZFM			:= .F.
Local lOrdem		:= SD1->(FieldPos( "D1_ORDDIA" ))>0
Local cLib
Local cDrive
Local cDir
Local cNArq
Local cExt
Local nRetType		:= 0

nRetType := GetRemoteType( @cLib )
QOut( cLib )     
/*
Estrutura:

-	Crio os arquivos temporแrios para posteriormente gerar os arquivos;
-	Fitro a SF1 com as Notas do perํodo gravo no TRB como se a NF estivesse sendo informada pelo contribuinte,;
	ou seja, como se nใo estivesse no Arquivo da SEFAZ
-	Abro o arquivo XML informado da Wizard e o leio criando um Obj XML (XML Manager) 
-	Navego por todo o XML e procuro cada Chave de NF do XML no TRB e caso nใo encontre procuro diretamente na SF1, SEM filtrar o perํodo, vou marcando no TRB quando encontrar a NF,;
	sinalizando que a NF do XML estแ no ERP, caso nใo encontrar gravo (Reclock( .T.)) no TRB informando que nใo consta no ERP
-	Gerar GetDados com as Notas para que seja possํvel alterar o que for necessแrio
-	Ao confirmar gerar Xml com base no TRB
*/

If (!xMagLeWiz (cNomWiz, @aWizard, .T.))
	lOk := .F.	
EndIf

If lOk
	// Usar o array aWizard
	dDataDe		:=	SToD(aWizard[1][1])	// Data inicio do perํodo
	dDataAte	:=	SToD(aWizard[1][2])	// Data final do perํodo
	IF	nRetType == 5 //"HTML" $ cLib
		SplitPath( Alltrim(aWizard[1][3]), @cDrive, @cDir, @cNArq, @cExt )
		cDirOri := cDrive + cDir
		cArqOri := cNArq + cExt
		cDirDest	:= 	GetSrvProfString("startpath","")	// Diret๓rio Destino
	ELSE
		cDirOri		:= 	Alltrim(aWizard[1][3])	// Diret๓rio Origem
		cArqOri		:= 	Alltrim(aWizard[1][4])	// Arquivo Origem
		cDirDest	:= 	Alltrim(aWizard[1][5])	// Diret๓rio Destino
	ENDIF
	
	cArqDest	:= 	Alltrim(aWizard[1][6])	// Arquivo Destino
	lZFM		:=  SubStr(aWizard[1][8],1,1)=="S"
	cAnoMes 	:= AnoMes(dDataDe)
	cFileDest	:= cDirDest+cArqDest

	If !File(cDirOri+cArqOri)
		Alert(STR0022+ cDirOri+cArqOri +STR0023 )//'Arquivo '//' nใo encontrado!'
		lOk := .F.
	EndIf

EndIf
If lOk
	// Deve copiar o arquivo de origem para o servidor, pois o obj tXmlManager 
	// nใo consegue efetura o parse de um arquivo no Client

	IF	nRetType == 5 //"HTML" $ cLib
		msg:= "Em fun็ใo do acesso ao sistema ser via SmartClient HTML, o caminho informado para salvar o arquivo serแ desconsiderado, e serแ processado conforme configura็ใo do navegador." //FISMSG("HTML")
		msgAlert(msg)
		__copyfile(Alltrim(aWizard[1][3]),"arquivonotasdeclararautodesembaraco.xml")
	ELSE
		CpyT2S(cDirOri+cArqOri, GetSrvProfString("startpath","") )
	ENDIF
	
	
	FError()
	// Abaixo aguardo a c๓pia do arquivo ser concluํda
	SLEEP(10000)
	// Cria o obj XML
	oXml := tXmlManager():NEW()
    If File(GetSrvProfString("startpath","")+cArqOri)
		If !oXml:ParseFile(GetSrvProfString("startpath","")+cArqOri)
			cError := oXml:Error()
			cWarning := oXml:Warning()
			Alert(STR0024+CRLF + oXml:Error() + CRLF + oXml:Warning())//'Erro ao ler o arquivo informado!'
			lOk := .F.
		EndIf
	Else
		Alert('Falha ao copiar arquivo para o servidor!')
		lOk := .F.
	EndIf

EndIf
If lOk
	// Verifico se se trata do mesmo layout (vide layout exemplo no final do fonte)
	If oXml:cName <> TagPri
		Alert(STR0025)//'Arquivo com layout inesperado!'
		lOk := .F.
	EndIf
EndIf
If lOk
	//Criando os arquivos temporแrios para cabe็alho e detalhe
	TempDIA(1, @cAliasCab, @cAliasDet, @aArq)
	
	//Abrindo tabelas
	DbSelectArea("SA2")
	SA2->(DbSetOrder(3)) 		// FILIAL+CGC
	DbSelectArea("SA5")
	SA5->(DbSetOrder(14))       // FILIAL+FORNECEDOR+LOJA+PRODUTO_NO_FORNECEDOR
	DbSelectArea("SB5")
	SB5->(DbSetOrder(1))
	DbSelectArea("SD1")
	SD1->(DbSetOrder(1))
	DbSelectArea("SFT")
	SFT->(DbSetOrder(1))
	DbSelectArea("SF1")
	SF1->(DbSetOrder(1))

EndIf

If lOk
	
	DbSelectArea(cAliasCab)
	(cAliasCab)->(DbSetOrder(1))
	DbSelectArea(cAliasDet)
	(cAliasDet)->(DbSetOrder(1))
	
	Begin Transaction
	
	// Busco todas as notas de entrada com data no perํodo e carrego no TRB
	CarregaTRB(cAliasCab,cAliasDet,dDataDe,dDataAte,lZFM)
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ€
	//ณCome็o a trabalhar com o XML                     ณ
	//ณ                                                 ณ
	//ณPara detalhes do layout esperado vide exemplo ao ณ
	//ณfinal deste fonte                                ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ€
	//Abaixo escolho o novo indice da SF1: FILIAL + CHAVE da NFe
	SF1->(DbSetOrder(8))
	
	// Abaixo indo at้ o segundo nํvel do XML
	aAux	:= oXml:XPathGetChildArray("/*/*")
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ  O m้todo XPathGetChildArray retorna um array com os n๓s filhos            ณ
	//ณ a partir do caminho de uma TAG que deverแ ser passado como parโmetro       ณ
	//ณ Parโmetro:                                                                 ณ
	//ณ Caminho de uma TAG no array no formato especํfico onde cada "/*" significa ณ
	//ณ um nํvel                                                                   ณ
	//ณ                                                                            ณ
	//ณ Retorno:                                                                   ณ
	//ณ Array bidimendional com as TAGs filhas da TAG passada, onde cada           ณ
	//ณ linha do ARRAY ้ um array representando a TAG e tendo a seguinte estrutura:ณ
	//ณ [1] - Nome da TAG                                                          ณ
	//ณ [2] - Caminho da TAG                                                       ณ
	//ณ [3] - Valor da TAG                                                         ณ
	//ณ                                                                            ณ
	//ณ Para mais detalhes vide documenta็ใo no TDN                                ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	// Procuro o filho que cont้m as Notas Fiscais
	For nX := 1 to Len(aAux)
		Do Case
			Case aAux[nX][1] == TagAno
				cAno	:= aAux[nX][3]
		 	Case aAux[nX][1] == TagMes
				cMes	:= aAux[nX][3]
			Case aAux[nX][1] == TagNotas
				cNotas := aAux[nX][2]  // Para as notas nใo posso apenas pegar o valor, mas preciso pegar o caminho
				Exit
			EndCase
	Next aAux
	
	aAux	:= oXml:XPathGetChildArray(cNotas)
	
	// Passando pelo Array com todas as Notas
	For nX:= 1 to len(aAux)
	
		lReconhece 	:= .F.
		cChave		:= ""
		aItensNf 	:= {}
		nNumItens	:= 0
	    cItem		:= ""
	    cProdFor	:= ""
	    cFor		:= ""
	    cLoja		:= ""
	    cNCM		:= ""
	    cEAN		:= ""
		
	    // Busca as Tags da Nota (chave, numero de itens...)
		aNf	:= oXml:XPathGetChildArray(aAux[nX][2])
	
		// Abaixo passo pelo XML verificando TAG a TAG
		For nY := 1 to Len(aNf) 
			Do Case
				Case aNf[nY][1] == TagChv
			    	cChave 		:= Alltrim(aNf[nY][3])
		    	    // Se encontro a NF no TRB significa que ela existe no ERP
				    If (cAliasCab)->(MsSeek(cChave))
						lReconhece := .T.
				    EndIf
				Case aNf[nY][1] == TagNumIt
					cNumItem 	:=	aNf[nY][3]  // N๚mero de itens do documento
				Case aNf[nY][1] == TagProd
	
					// Caso seja a TAG de um item ้ necessแrio ir um nํvel baixo como no exemplo:
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณ	<produto>                                     ณ
					//ณ		<numItemNFe>2</numItemNFe>                ณ
					//ณ		<codProdutoNFe>1235</codProdutoNFe>       ณ
					//ณ		<descProduto>Produto 123</descProduto>    ณ
					//ณ 	<valorItemNFe>1234.80</valorItemNFe>  	  ณ
					//ณ </produto                             		  ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					// a fun็ใo XPathGetChildArray retornarแ um array com a cada TAG filha da TAG <produto>
					// onde a primeira posi็ใo ้ o nome da TAG a segunda ้ o caminho e a terceira ้ a informa็ใo
	
					aXMLItem	:= oXml:XPathGetChildArray(aNf[nY][2])
				    For nZ := 1 to Len(aXMLItem)
			    		Do Case
							Case aXMLItem[nZ][1] == TagItem
						    	cItem 		:=	aXMLItem[nZ][3]
							Case aXMLItem[nZ][1] == TagPrFor
								cProdFor 	:=	aXMLItem[nZ][3] 
							Case aXMLItem[nZ][1] == TagItEAN
								cEAN		:= 	aXMLItem[nZ][3]
							Case aXMLItem[nZ][1] == TagItNCM
								cNCM		:= 	aXMLItem[nZ][3]
							Case aXMLItem[nZ][1] == TagItVal
								cValItem	:=  AllTrim(Str(Val(aXMLItem[nZ][3]),,2))
						EndCase
				    Next nZ
			 		// adicino as informa็๕es capturadas do XML no array 
			 		// para gravar no TRB posteriormente
			 		aadd(aItensNf,{cItem,cProdFor,cEAN,cNCM,cValItem})
			EndCase
			//Sai do Loop caso encontre a NF no ERP, pois nesse caso nใo precisarei das outras informa็๕es do XML
			If lReconhece
				Exit
			EndIf
		Next nY	

   	    cNCM		:= ""
	    cEAN		:= ""
	
	    // Se encontro a NF no TRB significa que ela existe no ERP
	    If lReconhece
	    	RecLock(cAliasCab, .F.)
	    	(cAliasCab)->CAB_RECON	:= "S"
	   		(cAliasCab)->CAB_INFO	:= "N"
	    	MsUnlock()
        
		ElseIf SF1->(MsSeek(xFilial("SF1")+cChave)) 
			// Ainda que nใo exista no TRB devo verificar se nใo existe na SF1 em qualquer outro perํodo
			// Nesse caso carrego as informa็๕es das tabelas SF1 e SFT no TRB
	 		lReconhece := .T.
	 		nNumItens := 0
	 		cIndi		:= "0"
			cNCMEAN		:= "0"
	 		//Terei que informar no arquivo temporแrio mesmo que nใo encontre a NF no SF1
			If SFT->(MsSeek( xFilial("SFT")+"E"+SF1->F1_SERIE+SF1->F1_DOC+SF1->F1_FORNECE+SF1->F1_LOJA ))

		    	Do While SFT->(!Eof() .And. FT_FILIAL==xFilial("SFT") .And. FT_TIPOMOV=="E" .And.  FT_SERIE==SF1->F1_SERIE  .And.;
		    			 FT_NFISCAL==SF1->F1_DOC .And. FT_CLIEFOR==SF1->F1_FORNECE .And. FT_LOJA==SF1->F1_LOJA )

			        SD1->(MsSeek(xFilial("SD1")+SFT->FT_NFISCAL+SFT->FT_SERIE+SFT->FT_CLIEFOR+SFT->FT_LOJA+SFT->FT_PRODUTO+SFT->FT_ITEM) )

			        cEspecie := ""
					cEspecie :=	AModNot( SFT->FT_ESPECIE )
					If !(cEspecie $ "08/10/57")            // CTR/CA/CTE

			    	    If SB5->(MsSeek( xFilial("SB5")+SFT->FT_PRODUTO ) )
			    	    	cCodTrib := SB5->B5_CODTRAM
							If lZFM
								If SFT->FT_ESTADO$UFSSE  // Proveniente do Sul ou Sudeste
						    		nMult := SB5->B5_ZFMULTS
						    	Else
						    		nMult := SB5->B5_ZFMULTO
						    	EndIf						
							Else
								If SFT->FT_ESTADO$UFSSE  // Proveniente do Sul ou Sudeste
						    		nMult := SB5->B5_AMMULTS
						    	Else
						    		nMult := SB5->B5_AMMULTO
						    	EndIf
					    	EndIf
			    	    Else
			    	    	cCodTrib 	:= ""
			    	    	nMult 		:= 0
			    	    EndIf
			    	    
			    	    If SB1->(MsSeek(xFilial("SB1")+SFT->FT_PRODUTO))
							If !Empty(Alltrim(SB1->B1_POSIPI))
							    cIndi	:= "1"
						  		cNCMEAN	:= Alltrim(SB1->B1_POSIPI)
							ElseIf Val(SB1->B1_CODBAR)>0
								cIndi	:= "2"
							  	cNCMEAN	:= StrZero(Val(SB1->B1_CODBAR))
							Else
								cIndi	:= "0"
		    	    			cNCMEAN	:= "0"
							EndIf
			    	    Else
			    	    	cIndi	:= "0"
			    	    	cNCMEAN	:= "0"
			    	    EndIf
			    	    
					   	If !Empty(Alltrim(SFT->FT_PDIA)) .And. ((SFT->FT_PDIA) > cAnoMes)  
		  					cCodTrib := "N013"		
						EndIf


						If lOrdem .And. !Empty(SD1->D1_ORDDIA) .And. (cAliasDet)->( MsSeek(cChave+SD1->D1_ORDDIA))
	        				RecLock(cAliasDet, .F.)

						Else
							nNumItens++
				    	    RecLock (cAliasDet, .T.)
			    			(cAliasDet)->DET_CHAVE 	:= cChave
			    			If lOrdem .And. !Empty(SD1->D1_ORDDIA)
		    					(cAliasDet)->DET_ITEM	:= SD1->D1_ORDDIA
		    				Else
		    					(cAliasDet)->DET_ITEM	:= SFT->FT_ITEM
		    				EndIf
			    			(cAliasDet)->DET_PRODF	:= ""
				    	    (cAliasDet)->DET_PROD	:= SFT->FT_PRODUTO
			    	    	(cAliasDet)->DET_INDI	:= cIndi
					  		(cAliasDet)->DET_COD	:= cNCMEAN
				    	    (cAliasDet)->DET_TRIB	:= cCodTrib
				    	    (cAliasDet)->DET_MULT	:= AllTrim(Str( nMult   ,,2))
                        EndIf
			    	    (cAliasDet)->DET_BCAL	:= AllTrim(Str(Val((cAliasDet)->DET_BCAL) + (SFT->FT_TOTAL - SFT->FT_DESCONT + SFT->FT_FRETE),,2))
			    	    (cAliasDet)->DET_IMPO	:= AllTrim(Str(Val((cAliasDet)->DET_IMPO) + ((SFT->FT_TOTAL - SFT->FT_DESCONT + SFT->FT_FRETE)*(nMult/100)),,2))
			    	    MsUnlock()
	
						If Empty(Alltrim(SFT->FT_PDIA))
							RecLock("SFT",.F.)
							SFT->FT_PDIA := cAnoMes 
	  						MsUnlock()
						EndIf
				    
			        EndIf
		    	    SFT->(DbSkip()) 
		    	EndDo
	        EndIf

	   	   	RecLock(cAliasCab, .T.)
		    (cAliasCab)->CAB_CHAVE := cChave
		    (cAliasCab)->CAB_RECON	:= "S"
	   		(cAliasCab)->CAB_INFO	:= "N"
	    	(cAliasCab)->CAB_NUM	:= SF1->F1_DOC
	    	(cAliasCab)->CAB_SER	:= SerieNfId("SF1",2,"F1_SERIE")
	    	(cAliasCab)->CAB_FOR	:= SF1->F1_FORNECE
	    	(cAliasCab)->CAB_LOJA	:= SF1->F1_LOJA
			(cAliasCab)->CAB_NITEM	:= Alltrim(Str(nNumItens))
	    	(cAliasCab)->CAB_DTE	:= SF1->F1_DTDIGIT
	    	(cAliasCab)->CAB_DTEMI	:= SF1->F1_EMISSAO
		    MsUnlock()
	    	
	    Else
	    	// Terei que informar no arquivo temporแrio mesmo que nใo encontre a NF no ERP (SF1)
	    	// Se nใo encontrou a NF no Protheus irei carregar apenas as informa็๕es do XML no TRB
	    	If SA2->(MsSeek(xFilial("SA2")+SUBSTR(cChave,7,14)))
            	cFor 	:= SA2->A2_COD
            	cLoja   := SA2->A2_LOJA
      		Else
            	cFor 	:= ""
            	cLoja   := ""
   	        EndIf

			For nY := 1 to Len(aItensNf)	            
				cProd 		:= ""
				cCodTrib 	:= ""
				nMult		:= 0
				cNCMEAN		:= "0"
				cIndi		:= "0"
                If !Empty(cFor)
					If SA5->(MsSeek(xFilial("SA5")+cFor+cLoja+PADR(aItensNf[nY][2],TamSX3("A5_CODPRF")[1])))
						If SB1->(MsSeek(xFilial("SB1")+SA5->A5_PRODUTO))
							cProd := SA5->A5_PRODUTO
							If SB5->(MsSeek( xFilial("SB5")+cProd))
				    	    	cCodTrib := SB5->B5_CODTRAM
				    	    	If lZFM
					    	    	If SUBSTR(cChave,1,2)$UFCodSSE  // Proveniente do Sul ou Sudeste
							    		nMult := SB5->B5_ZFMULTS
							    	Else
							    		nMult := SB5->B5_ZFMULTO
							    	EndIf
						    	Else
					    	    	If SUBSTR(cChave,1,2)$UFCodSSE  // Proveniente do Sul ou Sudeste
							    		nMult := SB5->B5_AMMULTS
							    	Else
							    		nMult := SB5->B5_AMMULTO
							    	EndIf
						    	EndIf
				    		Else
				    	    	cCodTrib 	:= ""
				    	    	nMult 		:= 0
				    	    EndIf

							// Abaixo a id้ia ้ somente preencher o c๓digo somente quando
							// estiver em branco no XML da SEFAZ ou quando estiver diferente do Protheus
							// conforme orientea็ใo do Manual t้cnico. OBS: somente ้ possํvel informar um dos c๓digos, NCM ou EAN
							If !Empty(aItensNf[nY][4])
								cIndi	:= "1"
								cNCMEAN	:= aItensNf[nY][4]
								If aItensNf[nY][4]<>Alltrim(SB1->B1_POSIPI)								
							  		cNCMEAN	:= SB1->B1_POSIPI
						  		EndIf
							ElseIf !Empty(aItensNf[nY][3])
								cIndi	:= "2"
								cNCMEAN	:= aItensNf[nY][3]
								If aItensNf[nY][3]<>StrZero(Val(SB1->B1_CODBAR))								
							  		cNCMEAN	:= StrZero(Val(SB1->B1_CODBAR))
						  		EndIf
							ElseIf !Empty(Alltrim(SB1->B1_POSIPI))
							    cIndi	:= "1"
						  		cNCMEAN	:= Alltrim(SB1->B1_POSIPI)
							ElseIf Val(SB1->B1_CODBAR)>0
								cIndi	:= "2"
							  	cNCMEAN	:= StrZero(Val(SB1->B1_CODBAR))
							EndIf
						EndIf
					EndIf
	            EndIf

				RecLock(cAliasDet, .T.)
				(cAliasDet)->DET_CHAVE 	:= cChave
				(cAliasDet)->DET_ITEM	:= aItensNf[nY][1]
				(cAliasDet)->DET_PRODF	:= aItensNf[nY][2]
		  	    (cAliasDet)->DET_PROD	:= Alltrim(cProd)
		   	    (cAliasDet)->DET_INDI	:= cIndi
		   	    (cAliasDet)->DET_COD	:= cNCMEAN
		   	    (cAliasDet)->DET_TRIB	:= Alltrim(cCodTrib)
		   	    (cAliasDet)->DET_BCAL	:= aItensNf[nY][5]
				(cAliasDet)->DET_MULT	:= AllTrim(Str( nMult ,,2))
	    	    (cAliasDet)->DET_IMPO	:= AllTrim(Str( Val(aItensNf[nY][5])*(nMult/100) ,,2))	
		   	    MsUnlock()
	   	    
	   	    Next nY
	
	        //Terei que informar no arquivo temporแrio mesmo que nใo encontre a NF no SF1
	   	   	RecLock(cAliasCab, .T.)
		    (cAliasCab)->CAB_CHAVE := cChave
		    (cAliasCab)->CAB_RECON	:= "N"
	   		(cAliasCab)->CAB_INFO	:= "N"
	    	(cAliasCab)->CAB_NUM	:= SUBSTR(cChave,26,9)
	    	(cAliasCab)->CAB_SER	:= SUBSTR(cChave,23,3)
	    	(cAliasCab)->CAB_FOR	:= cFor
	    	(cAliasCab)->CAB_LOJA	:= cLoja
			(cAliasCab)->CAB_NITEM	:= Alltrim(Str(Val(aItensNf[Len(aItensNf)][1])))
	    	(cAliasCab)->CAB_DTE	:= CToD ("//")
	    	(cAliasCab)->CAB_DTEMI	:= CToD ("//")
		    MsUnlock()
	    
	    EndIf
	    
	Next nX
	
	End transaction
	
	If MontaTela( cAliasCab )
		//Montando o XML
		nHandle := FCREATE(cFileDest)
		
		If nHandle = -1   
			Alert('Erro ao criar arquivo:' + Str(Ferror()))
			lGerou := .F.
		Else 
			GeraXml(nHandle, cAliasCab, cAliasDet, cAno, cMes, aWizard)
			FClose(nHandle) 
			If File(Alltrim(cFileDest))
				lGerou := .T.
			EndIf
		EndIf   
	Else
		lCancel := .T.
	EndIf
	TempDIA(2, @cAliasCab, @cAliasDet, @aArq)
EndIf

Return
         
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณInformaNF บAutor  ณCaio Martins        บ Data ณ 10/08/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria wizard para a geracao do arquivo, com dados iniciais  บฑฑ
ฑฑบ          ณ informados pelo usuแrio.                                   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑณParametros| cNomWiz -> Nome para a Wizard.                             ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CarregaTRB(cAliasCab, cAliasDet, dDataDe, dDataAte, lZFM)
Local lTop		:= .F.
Local cAliasF1	:= "SF1"
Local cAliasFT	:= "SFT"
Local cAliasD1	:= "SD1"
Local cAliasB1	:= "SB1"
Local cIndex	:= ""
Local nIndex	:= 0
Local cFiltro	:= ""
Local cCampos	:= ""
Local aDocAnt	:= {"",;			//Chave
					"",;			//Numero
					"",;			//Serie
					"",;			//Fornecedor
					"",;			//Loja
					CToD("//"),;	//DataEntrada
					CToD("//"),;	//DataEmissao
					0}				//Num Itens
					
Local cCodTrib	:= ""
Local nMult		:= ""
Local lOrdem	:= SD1->(FieldPos( "D1_ORDDIA" ))>0
Local cOrder	:= ""
Local cTipoDB	:= AllTrim(Upper(TcGetDb()))	// Tipo do banco de dados
Local cFTChvnfe := ""							// Variแvel para ajustar a query quando o banco for ORACLE

Default lZFM := .F.

DbSelectArea(cAliasD1)
(cAliasD1)->(DbSetOrder(1))
DbSelectArea(cAliasF1)
(cAliasF1)->(DbSetOrder(1))
DbSelectArea(cAliasFT)
(cAliasFT)->(DbSetOrder(1))
#IFDEF TOP
    If (TcSrvType ()<>"AS/400")
		lTop 	:= .T. 
	
		cAliasFT := GetNextAlias()

		cCampos := "%"
		If lOrdem
			cCampos += " , SD1.D1_ORDDIA "
		EndIf
		
		If SerieNfId("SF1",3,"F1_SERIE") == "F1_SDOC"
			cCampos += ", SF1.F1_SDOC"
		EndIf
		
		cCampos += "%"
		
		cOrder := "%ORDER BY SF1.F1_CHVNFE "
		If lOrdem
			cOrder += " , SD1.D1_ORDDIA , SFT.FT_ITEM "
		Else
			cOrder += " , SFT.FT_ITEM "
		EndIf
		cOrder += "%"
		
		//Verifica se ้ banco Oracle para evitar que d๊ erro nesse banco
		If cTipoDB == "ORACLE"
			cFTChvnfe := "%SUBSTR(SFT.FT_CHVNFE,1,2)%"
		Else
			cFTChvnfe := "%SUBSTRING(SFT.FT_CHVNFE,1,2)%"			
		EndIf

		BeginSql Alias cAliasFT
			
			COLUMN FT_ENTRADA AS DATE
			COLUMN F1_DTDIGIT AS DATE
			COLUMN F1_EMISSAO AS DATE
			
			SELECT			    
				SFT.FT_NFISCAL, SFT.FT_SERIE, SFT.FT_CLIEFOR, SFT.FT_LOJA, SFT.FT_ITEM, SFT.FT_TOTAL, SFT.FT_DESCONT, SFT.FT_ESTADO, 
				SFT.FT_ESPECIE, SFT.R_E_C_N_O_ FTRECNO, SB1.B1_COD, SB1.B1_POSIPI, SB1.B1_CODBAR,SF1.F1_CHVNFE, SF1.F1_DOC, SF1.F1_SERIE, 
				SF1.F1_FORNECE, SF1.F1_LOJA, SF1.F1_DTDIGIT, SF1.F1_EMISSAO, SFT.FT_PDIA,
				SD1.D1_DOC, SD1.D1_ITEM, SFT.FT_FRETE
				%Exp:cCampos%
			FROM 
				%Table:SFT% SFT
				LEFT JOIN %Table:SB1% SB1 ON(SB1.B1_FILIAL=%xFilial:SB1%  AND SB1.B1_COD=SFT.FT_PRODUTO AND SB1.%NotDel%)
				LEFT JOIN %Table:SF1% SF1 ON(SF1.F1_FILIAL=%xFilial:SF1%  AND SF1.F1_DOC=SFT.FT_NFISCAL AND SF1.F1_SERIE=SFT.FT_SERIE AND SF1.F1_FORNECE=SFT.FT_CLIEFOR AND SF1.F1_LOJA=SFT.FT_LOJA AND SF1.%NotDel%)
				LEFT JOIN %Table:SD1% SD1 ON(SD1.D1_FILIAL=%xFilial:SD1%  AND SD1.D1_DOC=SFT.FT_NFISCAL AND SD1.D1_SERIE=SFT.FT_SERIE AND SD1.D1_FORNECE=SFT.FT_CLIEFOR AND SD1.D1_LOJA=SFT.FT_LOJA AND SD1.D1_ITEM=SFT.FT_ITEM AND SD1.%NotDel%)
			WHERE 					
				SFT.FT_FILIAL=%xFilial:SFT% 				AND 
				SFT.FT_TIPOMOV 	= 'E'		 				AND
				%Exp:cFTChvnfe% <> '13'						AND
				SFT.FT_ENTRADA  >= %Exp:DToS (dDataDe)%	    AND
				SFT.FT_ENTRADA  <= %Exp:DToS (dDataAte)% 	AND
				SFT.FT_CFOP 	>= '2000'	 				AND
       			SFT.FT_CFOP 	<  '3000'	 				AND
				SFT.FT_FORMUL 	<> 'S'						AND  
				SF1.F1_CHVNFE   <> ' '						AND
				SFT.%NotDel%

				%Exp:cOrder%
		EndSql

	Else
#ENDIF
	cIndex	:= CriaTrab(NIL,.F.)
    cFiltro	:= 'FT_FILIAL=="'+xFilial("SFT")+'" .And. '
   	cFiltro += 'FT_TIPOMOV=="E" .And. SUBSTR(FT_CHVNFE,1,2) <> "13" .And. DToS(FT_ENTRADA)>="'+DToS(dDataDe)+'" .And. DToS(FT_ENTRADA)<="'+DToS(dDataAte)+'" .And.'
	cFiltro	+= 'FT_CFOP>="2000" .And. FT_CFOP<"3000"'
	
    IndRegua(cAliasFT, cIndex, SFT->(IndexKey()),, cFiltro)
    nIndex := RetIndex(cAliasFT)

	#IFNDEF TOP
		DbSetIndex(cIndex+OrdBagExt())
	#ENDIF
	
	DbSelectArea(cAliasFT)
    DbSetOrder(nIndex+1)
    (cAliasFT)->(dbGoTop())
#IFDEF TOP
	Endif
#ENDIF  

DbSelectArea(cAliasFT)

If lTop
	cAliasB1 := cAliasF1 := cAliasD1 := cAliasFT
Else
	DbSelectArea(cAliasF1)	
	DbSelectArea(cAliasD1)
	DbSelectArea(cAliasB1)
EndIf
// Loop no resultado do Select para carregar o TRB.
// Inicialmente gravo todas as notas como se elas nใo estivessesm no XML da SEFAZ
// Posteriomente ao ler o XML irei alterar essa informa็ใo caso necessแrio

Do While (cAliasFT)->( !Eof() )
	cAnoMes := AnoMes(dDataDe)
	cEspecie := ""
	cEspecie :=	AModNot( (cAliasFT)->FT_ESPECIE )
	If !(cEspecie $ "08/10/57")            // CTR/CA/CTE
	    
		If !lTop
			If (cAliasF1)->(MsSeek(xFilial("SF1")+(cAliasFT)->FT_NFISCAL+(cAliasFT)->FT_SERIE+(cAliasFT)->FT_CLIEFOR+(cAliasFT)->FT_LOJA))
				If Empty((cAliasF1)->F1_CHVNFE)
					(cAliasFT)->(DbSkip())
					Loop
				EndIf
				(cAliasB1)->(MsSeek(xFilial("SB1")+(cAliasFT)->FT_PRODUTO))
				(cAliasD1)->(MsSeek(xFilial("SD1")+(cAliasFT)->FT_NFISCAL+(cAliasFT)->FT_SERIE+(cAliasFT)->FT_CLIEFOR+(cAliasFT)->FT_LOJA+(cAliasFT)->FT_PRODUTO+(cAliasFT)->FT_ITEM))
			Else
				(cAliasFT)->(DbSkip())
				Loop
			EndIf
		EndIf
	    
	    If aDocAnt[1]<>(cAliasF1)->F1_CHVNFE
	    
	    	If !Empty(aDocAnt[1])
		   		RecLock(cAliasCab, .T.)
				(cAliasCab)->CAB_CHAVE 	:= aDocAnt[1]
			    (cAliasCab)->CAB_RECON	:= "N"
				(cAliasCab)->CAB_INFO	:= "S"
			    (cAliasCab)->CAB_NUM	:= aDocAnt[2]
			    (cAliasCab)->CAB_SER	:= aDocAnt[3]
			    (cAliasCab)->CAB_FOR	:= aDocAnt[4]
			    (cAliasCab)->CAB_LOJA	:= aDocAnt[5]
				// Gravo a Data de ENTRADA, pois o arquivo se trata de Notas que entraram na UF em um determinado perํodo
			    (cAliasCab)->CAB_DTE	:= aDocAnt[6]
			    (cAliasCab)->CAB_DTEMI	:= aDocAnt[7]
			    (cAliasCab)->CAB_NITEM	:= Alltrim(STR(aDocAnt[8]))
				MsUnlock()
	    	EndIf
	    
	    	aDocAnt[1]	:= (cAliasF1)->F1_CHVNFE 	//Chave
	    	aDocAnt[2]	:= (cAliasF1)->F1_DOC 		//Numero
	    	aDocAnt[3]	:= SerieNfId(cAliasF1,2,"F1_SERIE") 	//Serie 
	    	aDocAnt[4]	:= (cAliasF1)->F1_FORNECE 	//Fornecedor
	    	aDocAnt[5]	:= (cAliasF1)->F1_LOJA 		//Loja
	    	aDocAnt[6]	:= (cAliasF1)->F1_DTDIGIT 	//Data Entrada
	    	aDocAnt[7]	:= (cAliasF1)->F1_EMISSAO 	//Data Emissao
	    	aDocAnt[8]	:= 0
	   	EndIf
		
		If SB5->(MsSeek(xFilial("SB5")+(cAliasB1)->B1_COD ) )
	    	cCodTrib := SB5->B5_CODTRAM
	        If lZFM
		        If (cAliasFT)->FT_ESTADO$UFSSE  // Proveniente do Sul ou Sudeste
		    		nMult := SB5->B5_ZFMULTS
		    	Else
		    		nMult := SB5->B5_ZFMULTO
		    	EndIf
	        Else
		        If (cAliasFT)->FT_ESTADO$UFSSE  // Proveniente do Sul ou Sudeste
		    		nMult := SB5->B5_AMMULTS
		    	Else
		    		nMult := SB5->B5_AMMULTO
		    	EndIf
	    	EndIf
		Else
	      	cCodTrib 	:= ""
	      	nMult 		:= 0
	    EndIf
	    
	
		If lOrdem .And. !Empty((cAliasD1)->D1_ORDDIA) .And. (cAliasDet)->( MsSeek((cAliasF1)->F1_CHVNFE+(cAliasD1)->D1_ORDDIA)) 
	        RecLock(cAliasDet, .F.)

		Else
			aDocAnt[8]++  //Contando os itens
			
			RecLock(cAliasDet, .T.)
			(cAliasDet)->DET_CHAVE 	:= (cAliasF1)->F1_CHVNFE
			
			If lOrdem .And. !Empty((cAliasD1)->D1_ORDDIA)
				(cAliasDet)->DET_ITEM	:= (cAliasD1)->D1_ORDDIA
			Else
				(cAliasDet)->DET_ITEM	:= (cAliasFT)->FT_ITEM
			EndIf
			
			(cAliasDet)->DET_PRODF	:= ""
			(cAliasDet)->DET_PROD	:= (cAliasB1)->B1_COD
			If !Empty((cAliasB1)->B1_POSIPI)
				(cAliasDet)->DET_INDI	:= "1"
		  		(cAliasDet)->DET_COD	:= (cAliasB1)->B1_POSIPI
			ElseIf !Empty((cAliasB1)->B1_CODBAR)
				(cAliasDet)->DET_INDI	:= "2"
		  		(cAliasDet)->DET_COD	:= StrZero(Val((cAliasB1)->B1_CODBAR))
		  	Else
		  		(cAliasDet)->DET_INDI	:= "0"
		  		(cAliasDet)->DET_COD	:= "0"
			EndIf
		  	
		   	If !Empty(Alltrim((cAliasFT)->FT_PDIA)) .And. (((cAliasFT)->FT_PDIA) <> cAnoMes)  
		  		cCodTrib := "N013"		
		  	EndIf
		  	
		  	(cAliasDet)->DET_TRIB	:= Alltrim(cCodTrib)
		  	(cAliasDet)->DET_MULT	:= AllTrim(Str( nMult ,,2))
	  	EndIf
		(cAliasDet)->DET_BCAL	:= AllTrim(Str(Val((cAliasDet)->DET_BCAL)+((cAliasFT)->FT_TOTAL - (cAliasFT)->FT_DESCONT + (cAliasFT)->FT_FRETE),,2))
	  	(cAliasDet)->DET_IMPO	:= AllTrim(Str(Val((cAliasDet)->DET_IMPO)+(((cAliasFT)->FT_TOTAL - (cAliasFT)->FT_DESCONT + (cAliasFT)->FT_FRETE)*(nMult/100)),,2 ))
	  	MsUnlock()

  		If Empty(Alltrim((cAliasFT)->FT_PDIA))
  		 	SFT->(DBGOTO((cAliasFT)->FTRECNO))
  	      	RecLock("SFT",.F.)
			SFT->FT_PDIA := cAnoMes 
		   	MsUnlock()
		EndIf
	EndIf	 
	(cAliasFT)->( DbSkip() )
EndDo

//gravando o ๚ltimo CAB
If !Empty(aDocAnt[1])
	RecLock(cAliasCab, .T.)
	(cAliasCab)->CAB_CHAVE 	:= aDocAnt[1]
    (cAliasCab)->CAB_RECON	:= "N"
	(cAliasCab)->CAB_INFO	:= "S"
    (cAliasCab)->CAB_NUM	:= aDocAnt[2]
   	(cAliasCab)->CAB_SER	:= aDocAnt[3]
    (cAliasCab)->CAB_FOR	:= aDocAnt[4]
    (cAliasCab)->CAB_LOJA	:= aDocAnt[5]
	// Gravo a Data de ENTRADA, pois o arquivo se trata de Notas que entraram na UF em um determinado perํodo
    (cAliasCab)->CAB_DTE	:= aDocAnt[6]
    (cAliasCab)->CAB_DTEMI	:= aDocAnt[7]
    (cAliasCab)->CAB_NITEM	:= Alltrim(STR(aDocAnt[8]))
	MsUnlock()
EndIf

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGeraXml   บAutor  ณCaio Martins        บ Data ณ 10/08/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria wizard para a geracao do arquivo, com dados iniciais  บฑฑ
ฑฑบ          ณ informados pelo usuแrio.                                   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑณParametros| cNomWiz -> Nome para a Wizard.                             ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GeraXml(nHandle, cAliasCab, cAliasDet, cAno, cMes, aWizard)
Local nQtdNF	:= 0
Local cVersao	:= Alltrim(aWizard[1][7])
Local cNome		:= aWizard[2][1]
Local cFone		:= aWizard[2][2]
Local cEmail	:= aWizard[2][3]


DbSelectArea("SM0")  
SM0->(dbSeek(cEmpAnt+cFilAnt))


FWrite(nHandle, '<?xml version="1.0" encoding="UTF-8"?>')

FWrite(nHandle, '<enviDeclaracaoAutodesembaraco xsi:schemaLocation="http://www.sefaz.am.gov.br/autodesembaraco enviDeclaracaoMensalAuto_v1.00.xsd " xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.sefaz.am.gov.br/autodesembaraco">')
FWrite(nHandle, '<infDeclaracaoMensal versao="'+Alltrim(cVersao)+'">' )
FWrite(nHandle, '<ieContribuinteDeclarante>'+RetInscEmp(Alltrim(SM0->M0_INSC))+'</ieContribuinteDeclarante>' )
FWrite(nHandle, '<anoApresentacao>'+cAno+'</anoApresentacao>' )
FWrite(nHandle, '<mesApresentacao>'+cMes+'</mesApresentacao>' )
FWrite(nHandle, '<nomeResponsavel>'+cNome+'</nomeResponsavel>' )
FWrite(nHandle, '<foneResponsavel>'+cFone+'</foneResponsavel>' )
FWrite(nHandle, '<emailResponsavel>'+cEmail	+'</emailResponsavel>' )
FWrite(nHandle, '<listaNotasFiscais>' )
nQtdNF := NotasFis(nHandle, cAliasCab, cAliasDet)
FWrite(nHandle, '</listaNotasFiscais>' )
FWrite(nHandle, '<numNotasArquivo>'+Alltrim(Str(nQtdNF))+'</numNotasArquivo>' )
FWrite(nHandle, '</infDeclaracaoMensal>' )
FWrite(nHandle, '</enviDeclaracaoAutodesembaraco>' )

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNotasFis  บAutor  ณCaio Martins        บ Data ณ 10/08/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria wizard para a geracao do arquivo, com dados iniciais  บฑฑ
ฑฑบ          ณ informados pelo usuแrio.                                   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑณParametros| cNomWiz -> Nome para a Wizard.                             ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function NotasFis(nHandle, cAliasCab, cAliasDet)
Local nQtdNF 	:= 0
Local cNItem 	:= ""
Local lItens 	:= .F.
Local cDtEmiss	:= ""
Local nItens	:= 0


(cAliasCab)->( DbGoTop() ) 
(cAliasDet)->( DbGoTop() )

Do While (cAliasCab)->( !Eof() )
	nQtdNF++
	If !Empty((cAliasCab)->CAB_DTEMI)
		cDtEmiss	:=  Alltrim(DtoS((cAliasCab)->CAB_DTEMI))
		cDtEmiss	:=  SubStr(cDtEmiss,1,4)+"-"+SubStr(cDtEmiss,5,2)+"-"+SubStr(cDtEmiss,7,2)
	Else 
		cDtEmiss	:= ""
	EndIf
	
	FWrite(nHandle, '<notaFiscal numOrdemNota="'+Alltrim(Str(nQtdNF))+'">' )
	FWrite(nHandle, '<chaveNFe>'+ (cAliasCab)->CAB_CHAVE  +'</chaveNFe>' )
	
	If !Empty(cDtEmiss)
		FWrite(nHandle, '<dataEmissaoNFe>'+ cDtEmiss +'</dataEmissaoNFe>' )
	EndIf
	
	FWrite(nHandle, '<reconheceNFe>'+ (cAliasCab)->CAB_RECON +'</reconheceNFe>' )
	FWrite(nHandle, '<nfeInformadaPeloContribuinte>'+ (cAliasCab)->CAB_INFO +'</nfeInformadaPeloContribuinte>' )
	

    If (cAliasCab)->CAB_RECON =="N" .And. (cAliasCab)->CAB_INFO =="N"
	    cNItem	:= "0"	
	    lItens	:= .F.
    Else
    	cNItem 	:= (cAliasCab)->CAB_NITEM
    	lItens	:= .T.
    EndIf

	FWrite(nHandle, '<numItens>'+Alltrim(cNItem)+'</numItens>' )
	
	If lItens
	    //posiciono no primeiro Item
	    (cAliasDet)->(MsSeek((cAliasCab)->CAB_CHAVE))
		nItens	:= 1
		Do While (cAliasDet)->( !Eof() .And. DET_CHAVE==(cAliasCab)->CAB_CHAVE )
			FWrite(nHandle, '<produto>' )
			FWrite(nHandle, '<numItemNFe>'+Alltrim(STR(nItens))+'</numItemNFe>' )
			FWrite(nHandle, '<codInternoProduto>'+ Alltrim(NoAcento(AnsiToOem(AllTrim((cAliasDet)->DET_PROD ))))+'</codInternoProduto>' )
			FWrite(nHandle, '<indiceCodGeralProduto>'+Alltrim((cAliasDet)->DET_INDI)+'</indiceCodGeralProduto>' )
			FWrite(nHandle, '<codGeralProduto>'+Alltrim(NoAcento(AnsiToOem(AllTrim((cAliasDet)->DET_COD ))))+'</codGeralProduto>' )
			FWrite(nHandle, '<codTipoTributacao>'+Alltrim((cAliasDet)->DET_TRIB)+'</codTipoTributacao>' )
			FWrite(nHandle, '<valorBaseCalculoItem>'+Alltrim((cAliasDet)->DET_BCAL)+'</valorBaseCalculoItem>' )
			FWrite(nHandle, '<valorMultiplicador>'+Alltrim((cAliasDet)->DET_MULT)+'</valorMultiplicador>' )
			FWrite(nHandle, '<valorImpostoDeclarado>'+Alltrim((cAliasDet)->DET_IMPO)+'</valorImpostoDeclarado>' )
			FWrite(nHandle, '<prodAcabado>00</prodAcabado>' )
			FWrite(nHandle, '</produto>' )
			(cAliasDet)->( DbSkip() )
			nItens++
		EndDo
    EndIf

	FWrite(nHandle, '</notaFiscal>' )
	(cAliasCab)->(DbSkip())
EndDo

Return nQtdNF

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMontaTela บAutor  ณCaio Martins        บ Data ณ 10/08/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria wizard para a geracao do arquivo, com dados iniciais  บฑฑ
ฑฑบ          ณ informados pelo usuแrio.                                   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑณParametros| cNomWiz -> Nome para a Wizard.                             ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MontaTela( cAliasCab )
Local oDlg		:= NIL
Local cTitulo	:= STR0026//'DIA - Declara็ใo de Interna็ใo no Amazonas'
Local cTxt		:= STR0027//'Compara็ใo entre documentos do XML da SEFAZ x Notas Fiscais de Entrada'
Local lRet		:= .T.
Local aSize		:=  MsAdvSize(.T.)
Local aObjects	:= {}
Local aInfo		:= {}
Local aPosObj	:= {}
Local nX		:= 0
Local aButtons	:= {}

PRIVATE aHeader	:= {}
PRIVATE aCols	:= {}
PRIVATE aRotina := {	{ OemToAnsi("Pesq")			,"RETT"  	,0,1},;	 //"Pesquisar"
						{ OemToAnsi("Alter")		,"RETT"		,0,2},;	 //"Visual"
						{ OemToAnsi("Inclui")		,"RETT"		,0,3},;	 //"Incluir"
						{ OemToAnsi("Alter")		,"RETT"		,0,4},;  //"Alterar"
						{ OemToAnsi("Alter")		,"RETT"		,0,5} }  //"Exclusao"

//Montando o aHeader
AADD(aHeader,{STR0028		,"CAB_CHAVE"		,"@!"					,45,0,".t." ,"" ,"C"," "," " })//"Chave"
AADD(aHeader,{STR0029		,"CAB_RECON"		,"@!"					,01,0,"VldF51Rec()" ,"" ,"C"," "," " })//"Reconhece"
AADD(aHeader,{STR0030		,"CAB_INFO"			,"@!"					,01,0,".t." ,"" ,"C"," "," " })//"Informado"
AADD(aHeader,{STR0031		,"CAB_NUM"			,"@!"					,09,0,".t." ,"" ,"C"," "," " })//"N๚mero"
AADD(aHeader,{STR0032		,"CAB_SER"			,"!!!"					,03,0,".t." ,"" ,"C"," "," " })//"S้rie"
AADD(aHeader,{STR0033		,"CAB_FOR"			,"@!"					,07,0,".t." ,"" ,"C"," "," " })//"Fornecedor"
AADD(aHeader,{STR0034		,"CAB_LOJA"			,"@!"					,04,0,".t." ,"" ,"C"," "," " })//"Loja"
AADD(aHeader,{STR0035		,"CAB_DTE"			,"@!"					,08,0,".t." ,"" ,"D"," "," " })//"Entrada"


(cAliasCab)->(DbSetOrder(1))
(cAliasCab)->(DbGoTop())
// Montando o aCols
(cAliasCab)->(DbGoTop())
Do While (cAliasCab)->( !Eof() )
	Aadd(aCols,{"|"+(cAliasCab)->CAB_CHAVE, (cAliasCab)->CAB_RECON, (cAliasCab)->CAB_INFO, (cAliasCab)->CAB_NUM , (cAliasCab)->CAB_SER,;
				(cAliasCab)->CAB_FOR ,	(cAliasCab)->CAB_LOJA, (cAliasCab)->CAB_DTE , .F.})
	(cAliasCab)->(DbSkip())
EndDo
(cAliasCab)->(DbGoTop())

If RemoteType() == 1
	aAdd(aButtons,{PmsBExcel()[1],{|| DlgToExcel({{"GETDADOS","",aHeader,aCols}}),"AllwaysTrue"},PmsBExcel()[2],PmsBExcel()[3]})
EndIf

//Verificando a posi็ใo do Obj
AAdd( aObjects, { 100, 100, .T., .T. } )
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

//Criando a Tela
DEFINE MSDIALOG oDlg TITLE cTitulo FROM aSize[7],0 TO aSize[6],aSize[5] PIXEL

TSay():New(aPosObj[1][1],aPosObj[1][2],{|| cTxt },oDlg,,,,,,.T.,,,340,10,,,,.T.,,.T.)

							// < nTop>         < nLeft>       < nBottom>     < nRight>  < nOpc> [cLinhaOk]      [cTudoOk]  [cIniCpos][ lDeleta][ aAlter][nFreeze][lEmpty][nMax]   [cFieldOk]      [cSuperDel]     [uPar]   [cDelOk]   [oWnd][lUseFreeze][cTela]
oGetDados := MsGetDados():New(aPosObj[1][1]+10, aPosObj[1][2], aPosObj[1][3], aPosObj[1][4], 4, "Fis51LnOk" ,  "AllwaysTrue",    "",   .T.,   {"CAB_RECON"},     ,  .F.  , Len(aCols),  "AllwaysTrue",   "AllwaysTrue",      ,  "AllwaysTrue", oDlg)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lRet:=.T.,oDlg:End()},{||lRet:=.F.,oDlg:End()},,aButtons) CENTERED

If lRet
	//Gravando o TRB
	For nX := 1 to Len(aCols)		
		If (cAliascab)->(MsSeek(Alltrim( SubStr(aCols[nX][1],2,44) )))
			If aCols[nX][Len(aCols[nX])]
				RecLock(cAliascab, .F. )
				(cAliascab)->(dbDelete())
				MsUnlock()
		    ElseIf (cAliascab)->CAB_RECON<>aCols[nX][2]
				RecLock(cAliascab, .F. )
				(cAliascab)->CAB_RECON:= aCols[nX][2]
				MsUnlock()
			EndIf
		EndIf
	Next nX
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFis51LnOk บAutor  ณCaio Martins        บ Data ณ 10/08/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se a linha editada estแ conforme                  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Fis51LnOk()
Local lRet := .T.

If Empty(aCols[n][1]) .And. !aCols[n][Len(aCols[n])]
	Alert(STR0036)//'Nใo ้ possํvel incluir Notas Fiscais'
	lRet := .F.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVldF51Rec บAutor  ณCaio Martins        บ Data ณ 10/08/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valid do campo CAB_RECON do aHeader                        บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VldF51Rec()
Local lRet := .T.
Local cDig := &( ReadVar() )

If cDig$"SNZC"
	If  cDig <> aCols[n][2]
		lRet := MsgYesNo(STR0037)//'Deseja alterar o reconhecimento da NF?'
	EndIf
Else
	lRet := .F.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTempDIA   บAutor  ณCaio Martins        บ Data ณ 10/08/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria wizard para a geracao do arquivo, com dados iniciais  บฑฑ
ฑฑบ          ณ informados pelo usuแrio.                                   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑณParametros| cNomWiz -> Nome para a Wizard.                             ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function TempDIA(nTipo, cAliasCab, cAliasDet, aArq)
Local	aCmpCab	:=	{}
Local	aCmpDet	:=	{}
Local	cArqCab	:=	""
Local	cArqCab1:=	""
Local	cArqDet	:=	""
Local	nI		:=	0

If (nTipo==1)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณTRB CABEวALHO  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cAliasCab	:=	"CAB"
	aAdd (aCmpCab, {"CAB_CHAVE",	"C", 	044,	0})
	aAdd (aCmpCab, {"CAB_RECON",	"C", 	001,	0})
	aAdd (aCmpCab, {"CAB_INFO",		"C", 	001,	0})
	aAdd (aCmpCab, {"CAB_NUM",		"C", 	009,	0})
	aAdd (aCmpCab, {"CAB_SER",		"C", 	TamSx3("D1_SERIE")[1],	0})
	aAdd (aCmpCab, {"CAB_FOR",		"C", 	007,	0})
	aAdd (aCmpCab, {"CAB_LOJA",		"C", 	004,	0})
	aAdd (aCmpCab, {"CAB_DTE", 		"D", 	008,	0})
	aAdd (aCmpCab, {"CAB_DTEMI", 	"D", 	008,	0})
	aAdd (aCmpCab, {"CAB_NITEM", 	"C", 	005,	0})

	cArqCab	:=	CriaTrab(aCmpCab)
	DbUseArea (.T., __LocalDriver, cArqCab, cAliasCab)
	IndRegua(cAliasCab, cArqCab, "CAB_CHAVE")
 	aAdd (aArq, {cAliasCab, cArqCab}) 

	cArqCab1 := CriaTrab(Nil,.F.)
	IndRegua(cAliasCab,cArqCab1,"CAB_RECON+CAB_INFO")
	dbClearIndex()
 	
 	dbSelectArea(cAliasCab)
	dbSetIndex(cArqCab+OrdBagExt())
	dbSetIndex(cArqCab1+OrdBagExt())
	dbSetOrder(1)
 	

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณTRB CABEวALHO  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cAliasDet	:=	"DET"
	// Campos necessแrios por causa do layout do arquivo importado
	aAdd (aCmpDet, {"DET_CHAVE",	"C", 	044,	0})
	aAdd (aCmpDet, {"DET_ITEM",		"C", 	003,	0})
	aAdd (aCmpDet, {"DET_PRODF",	"C", 	001,	0})
	aAdd (aCmpDet, {"DET_EAN",		"C", 	003,	0})
	aAdd (aCmpDet, {"DET_NCM",		"C", 	007,	0})
	aAdd (aCmpDet, {"DET_VALOR", 	"D", 	008,	0})
	// Campos necessแrios para gera็ใo da declara็ใo
	aAdd (aCmpDet, {"DET_PROD", 	"C", 	030,	0})
	aAdd (aCmpDet, {"DET_INDI", 	"C", 	001,	0})
	aAdd (aCmpDet, {"DET_COD", 		"C", 	020,	0})
	aAdd (aCmpDet, {"DET_TRIB",		"C", 	004,	0})
	aAdd (aCmpDet, {"DET_BCAL",		"C", 	020,	0})
	aAdd (aCmpDet, {"DET_MULT",		"C", 	020,	0})
	aAdd (aCmpDet, {"DET_IMPO",		"C", 	020,	0})

	cArqDet	:=	CriaTrab(aCmpDet)
	DbUseArea (.T., __LocalDriver, cArqDet, cAliasDet)
	IndRegua(cAliasDet, cArqDet, "DET_CHAVE+DET_ITEM")
    aAdd (aArq, {cAliasDet, cArqDet})

Else
	For nI := 1 To Len(aArq)
		DbSelectArea(aArq[nI][1])
		(aArq[nI][1])->(DbCloseArea())
		Ferase(aArq[nI][2]+GetDBExtension())
		Ferase(aArq[nI][2]+OrdBagExt())	
	Next nI
EndIf

Return

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ                  Abaixo segue um exemplo de XML que serแ importado para comparar com as Notas de Entrada no Protheus                        ณ
//ณ                                                                                                                                             ณ
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ	-<arquivoNotasDeclararAutodesembaraco xsi:schemaLocation="http://www.sefaz.am.gov.br/autodesembaraco arquivoNotasDeclararAuto_v1.00.xsd "   ณ
//ณ xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.sefaz.am.gov.br/autodesembaraco"> 									ณ
//ณ 	<infNotasDeclarar versao="01">                                                                                                          ณ
//ณ			<ieContribuinteDeclarante>040000001</ieContribuinteDeclarante>                                                                      ณ
//ณ 		<anoApresentacao>2012</anoApresentacao>                                                                                             ณ
//ณ			<mesApresentacao>01</mesApresentacao>                                                                                               ณ
//ณ			-<listaNotasFiscais> -                                                                                                              ณ
//ณ				<notaFiscal numOrdemNota="1">                                                                                                   ณ
//ณ					<chaveNFe>35100623452452345243549458749027400187480970</chaveNFe>                                                           ณ
//ณ					<numItens>3</numItens>                                                                                                      ณ
//ณ					-<produto>                                                                                                                  ณ
//ณ						<numItemNFe>1</numItemNFe>                                                                                              ณ
//ณ						<codProdutoNFe>1234</codProdutoNFe>                                                                                     ณ
//ณ						<descProduto>Produto ABC</descProduto>                                                                                  ณ
//ณ						<codEAN>78935253425782</codEAN>                                                                                         ณ
//ณ						<codNCM>12333464</codNCM>                                                                                               ณ
//ณ						<valorItemNFe>548.32</valorItemNFe>                                                                                     ณ
//ณ					</produto>                                                                                                                  ณ
//ณ					-<produto>                                                                                                                  ณ
//ณ						<numItemNFe>2</numItemNFe>                                                                                              ณ
//ณ						<codProdutoNFe>1235</codProdutoNFe>                                                                                     ณ
//ณ						<descProduto>Produto 123</descProduto>                                                                                  ณ
//ณ						<codEAN>78954367823867</codEAN>                                                                                         ณ
//ณ						<codNCM>12333421</codNCM>                                                                                               ณ
//ณ						<valorItemNFe>1234.80</valorItemNFe>                                                                                    ณ
//ณ					</produto>                                                                                                                  ณ
//ณ					-<produto>                                                                                                                  ณ
//ณ						<numItemNFe>3</numItemNFe>                                                                                              ณ
//ณ						<codProdutoNFe>12346</codProdutoNFe>                                                                                    ณ
//ณ						<descProduto>Produto XYZ</descProduto>                                                                                  ณ
//ณ						<codEAN>78954542243154</codEAN>                                                                                         ณ
//ณ						<codNCM>12342139</codNCM>                                                                                               ณ
//ณ						<valorItemNFe>121234.98</valorItemNFe>                                                                                  ณ
//ณ					</produto>                                                                                                                  ณ
//ณ				</notaFiscal>                                                                                                                   ณ
//ณ				-<notaFiscal numOrdemNota="2">                                                                                                  ณ
//ณ					<chaveNFe>35100623452412341324378438992414782342880970</chaveNFe>                                                           ณ
//ณ					<numItens>1</numItens>                                                                                                      ณ
//ณ					-<produto>                                                                                                                  ณ
//ณ						<numItemNFe>1</numItemNFe>                                                                                              ณ
//ณ						<codProdutoNFe>1234</codProdutoNFe>                                                                                     ณ
//ณ						<descProduto>Produto ABC</descProduto>                                                                                  ณ
//ณ						<codEAN>78935253425782</codEAN>                                                                                         ณ
//ณ						<codNCM>12333464</codNCM>                                                                                               ณ
//ณ						<valorItemNFe>1234.98</valorItemNFe>                                                                                    ณ
//ณ					</produto>                                                                                                                  ณ
//ณ				</notaFiscal>                                                                                                                   ณ
//ณ			</listaNotasFiscais>                                                                                                                ณ
//ณ			<numNotasArquivo>2</numNotasArquivo>                                                                                                ณ
//ณ		</infNotasDeclarar>                                                                                                                     ณ
//ณ	</arquivoNotasDeclararAutodesembaraco>                                                                                                      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

