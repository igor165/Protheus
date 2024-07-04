// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 14     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "Protheus.ch"
#include "OFIOR240.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIOR240 ³ Autor ³ Eveli Morasco         ³ Data ³ 25/02/93 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Saldos em Estoques                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Rodrigo Sart.³07/08/98³16964A³Acerto na filtragem dos almoxarifados   ³±±
±±³ Fernando Joly³23/10/98³15013A³Acerto na filtragem de Filiais          ³±±
±±³ Fernando Joly³03/12/98³XXXXXX³S¢ imprimir "Total do Produto" quando   ³±±
±±³              ³        ³      ³houver mais de 1 produto.               ³±±
±±³ Fernando Joly³21/12/98³18920A³Possibilitar filtragem pelo usuario.    ³±±
±±³ Cesar Valadao³30/03/99³XXXXXX³Manutencao na SetPrint()                ³±±
±±³ Aline        ³27/04/99³21147 ³Considerar o NewHead do Titulo          ³±±
±±³ Cesar Valadao³28/04/99³17188A³Inclusao da Pergunta - Descricao Produto³±±
±±³              ³        ³      ³Descricao Cientifica ou Generica.       ³±±
±±³ Cesar Valadao³08/12/99³25510A³Erro na Totalizacao de Produto Por      ³±±
±±³              ³        ³      ³Almoxarifado com Saldo Zerado.          ³±±
±±³ Patricia Sal.³11/07/00³005086³Acerto Salto de linha (P/ Almoxarifado) ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function OFIOR240

Local oReport
               
Private nSizFil := 0
Private cStr    := ""
Private aReturn := {(STR0008), 1,(STR0009), 2, 2, 1, '',1 } // 'Zebrado'###'Administracao'

If !(FindFunction("TRepInUse") .And. TRepInUse())
	Return OR240R3() // Executa versão anterior do fonte
Else
	Pergunte('OFR240',.F.)
	oReport := ReportDef()
	oReport:PrintDialog()
Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ReportDef³ Autor ³ ANDRE                 ³ Data ³ 23/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Relatorio usando o TReport                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Oficina                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportDef()

Local oReport
Local oSection1
Local oCell

oReport := TReport():New("OFIOR240",(STR0015),"OFR240",{|oReport| OR240Imp(oReport)}) //Saldos em Estoques

oSection1 := TRSection():New(oReport,STR0019,{"SB1","SB2"})
TRCell():New(oSection1,"",,"","@!",220,, {|| cStr } )

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OR240Imp ³ Autor ³ ANDRE                 ³ Data ³ 23/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Executa a impressao do relatorio do TReport                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Oficina                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OR240Imp(oReport)

Local oSection1 := oReport:Section(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cRodaTxt   := 'REG(S)'
Local nCntImpr   := 0
Local nTipo      := 0
Local aOrd       := {(STR0004),(STR0005),(STR0006),(STR0007)} // ' Por Codigo         '###' Por Tipo           '###' Por Descricao    '###' Por Grupo        '

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis locais exclusivas deste programa                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lImpr      :=.F.
Local nSoma      := 0
Local nSavRec    := 0
Local nTotSoma   := 0
Local nX         := 0
Local nRegM0     := 0
Local nIndB1     := 0
Local nIndB2     := 0
Local nQtdProd   := 0
Local aSalProd   := {}
Local cFilialDe  := ''
Local cQuebra1   := ''
Local cCampo     := ''
Local cMens      := ''
Local aProd      := {}
Local aProd1     := {}
Local aProd2     := {}
Local aProd3     := {}
Local cFilOld    := 'úú'
Local cCodAnt    := 'úú'
Local cDesc
Local lIsCient
Local cPict      := "@E 9,999,999.99"

//
Local cGruVei    := PadR(AllTrim(GetNewPar("MV_GRUVEI","VEIC")),TamSx3("B1_GRUPO")[1]," ") // Grupo do Veiculo
Local cGruSrv    := PadR(AllTrim(GetNewPar("MV_GRUSRV","SRVC")),TamSx3("B1_GRUPO")[1]," ") // Grupo do Servico
//

oReport:SetMeter(RecCount())
oSection1:Init(.f.)
oReport:SetMeter(SE1->(RecCount()))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Private exclusivas deste programa                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cQuebra2   := ''
Private cCond2     := ''
Private cFiltroB1  := ''
Private cIndB1     := ''
Private aFilAtu        := FWArrFilAtu() // carrega os dados da Filial logada ( Grupo de Empresa / Empresa / Filial ) 
Private aFiliais       := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. ) // Levanta todas as Filiais da Empresa logada (vetor utilizado no FOR das Filiais)
Private nCont          := 0
Private cBkpFilAnt := cFilAnt // salvar cFilAnt
Private cFiltroB2  := ''
Private cIndB2     := ''
Private lContinua  := .T.
Private cNomArqB1  := ''
Private cNomArqB2  := ''

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Contadores de linha e pagina                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private Li         := 80
Private m_pag      := 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa os codigos de caracter Comprimido/Normal da impressora ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTipo := iif(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona a ordem escolhida ao Titulo do relatorio          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type('NewHead') # 'U'
	NewHead := AllTrim(NewHead)
	NewHead += ' (' + AllTrim(SubStr(aOrd[aReturn[8]],6,20)) + ')'
Else
	Titulo := STR0015 //AllTrim("Saldos em Estoques")
	Titulo += ' (' + AllTrim(SubStr(aOrd[aReturn[8]],6,20)) + ')'
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta os Cabecalhos                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCabec1 := (STR0010) // 'CODIGO          TP GRUP DESCRICAO                      UM FL ALM      QUANTIDADE'
cCabec2 := ''
//-- 123456789012345 12 1234 123456789012345678901234567890 12 12 12 999,999,999.99
//-- 0         1         2         3         4         5         6         7
//-- 012345678901234567890123456789012345678901234567890123456789012345678901234567890


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processos de Inicia‡„o dos Arquivos Utilizados               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//-- SB2 (Saldos em Estoque)
dbSelectArea('SB2')
dbSetOrder(1)

cFiltroB2 := 'B2_COD>="'+mv_par06+'".And.B2_COD<="'+mv_par07+'".And.'
cFiltroB2 += 'B2_LOCAL>="'+mv_par04+'".And.B2_LOCAL<="'+mv_par05+'"'
If !Empty(xFilial('SB2'))
	cFiltroB2 += '.And.B2_FILIAL>="'+mv_par02+'".And.B2_FILIAL<="'+mv_par03+'"'
EndIf

Pergunte('OFR240',.F.)
If mv_par01 == 3
	cIndB2 := 'B2_COD + B2_FILIAL + B2_LOCAL'
ElseIf mv_par01 == 2
	cIndB2 := 'B2_FILIAL + B2_COD + B2_LOCAL'
Else
	cIndB2 := 'B2_COD + B2_FILIAL + B2_LOCAL'
EndIf

cNomArqB2 := Left(CriaTrab('',.F.),7) + 'a'

IndRegua('SB2',cNomArqB2,cIndB2,,cFiltroB2,STR0017)  //Selecionando Registros...
nIndB2 := RetIndex('SB2')
#IFNDEF TOP
	dbSetIndex(cNomArqB2 + OrdBagExt())
#ENDIF
dbSetOrder(nIndB2 + 1)
dbGoTop()

//-- SB1 (Produtos)
dbSelectArea('SB1')
dbSetOrder(aReturn[8])

cFiltroB1 := 'B1_COD>="'+mv_par06+'".And.B1_COD<="'+mv_par07+'".And.'
cFiltroB1 += 'B1_TIPO>="'+mv_par08+'".And.B1_TIPO<="'+mv_par09+'".And.'
cFiltroB1 += 'B1_GRUPO>="'+mv_par10+'".And.B1_GRUPO<="'+mv_par11+'"'
If !Empty(xFilial('SB1'))
	cFiltroB1 += '.And.B1_FILIAL>="'+mv_par02+'".And.B1_FILIAL<="'+mv_par03+'"'
EndIf

If aReturn[8] == 4
	cIndB1 := 'B1_GRUPO+B1_COD+B1_FILIAL'
	cCampo := 'B1_GRUPO'
	cMens  := (STR0012) // 'Grupo.........'
ElseIf aReturn[8] == 3
	cIndB1 := 'B1_DESC+B1_COD+B1_FILIAL'
	cCampo := .T.
ElseIf aReturn[8] == 2
	cIndB1 := 'B1_TIPO+B1_COD+B1_FILIAL'
	cCampo := 'B1_TIPO'
	cMens  := (STR0011) // 'Tipo..........'
Else
	cIndB1 := 'B1_COD+B1_FILIAL'
	cCampo := .T.
Endif

cNomArqB1 := Left(CriaTrab('',.F.),7) + 'b'

IndRegua('SB1',cNomArqB1,cIndB1,,cFiltroB1,STR0017) //Selecionando Registros...
nIndB1 := RetIndex('SB1')
#IFNDEF TOP
	dbSetIndex(cNomArqB1 + OrdBagExt())
#ENDIF
dbSetOrder(nIndB1 + 1)
dbGoTop()

cFilialDe := iif(Empty(xFilial('SB2')),xFilial('SB2'),mv_par02)

If aReturn[8] == 4
	dbSeek(mv_par10, .T.)
ElseIf aReturn[8] == 3
	//-- Pesquisa Somente se a Descricao For Generica.
	If mv_par17 == 2
		dbSeek(mv_par12, .T.)
	Endif
ElseIf aReturn[8] == 2
	dbSeek(mv_par08, .T.)
Else
	dbSeek(mv_par06, .T.)
Endif

//-- 1§ Looping no Arquivo Principal (SB1)

cStr :=(STR0010)
oSection1:PrintLine()
cStr :=""
oSection1:PrintLine()
Do While !SB1->(Eof()) .and. lContinua
	
	// Desconsiderar VEICULOS e SERVICOS
	If SB1->B1_GRUPO == cGruVei .or. SB1->B1_GRUPO == cGruSrv
		SB1->(dbSkip())
		Loop
	EndIf

	aProd  := {}
	aProd1 := {}
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se imprime nome cientifico do produto. Se Sim    ³
	//³ verifica se existe registro no SB5 e se nao esta vazio    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cDesc := SB1->B1_DESC
	lIsCient := .F.
	If mv_par17 == 1
		dbSelectArea("SB5")
		dbSeek(xFilial()+SB1->B1_COD)
		If Found() .and. !Empty(B5_CEME)
			cDesc := B5_CEME
			lIsCient := .T.
		EndIf
		dbSelectArea('SB1')
	Endif
	
	//-- Consiste Descri‡Æo De/At‚
	If cDesc < mv_par12 .Or. cDesc > mv_par13
		SB1->(dbSkip())
		Loop
	EndIf
	
	//-- Filtro do usuario
	If !Empty(aReturn[7]) .And. !&(aReturn[7])
		SB1->(dbSkip())
		Loop
	EndIf
	
	cQuebra1 := iif(aReturn[8]==1.Or.aReturn[8]==3,.T.,&(cCampo))
	
	//-- 2§ Looping no Arquivo Principal (SB1)
	Do While !SB1->(Eof()) .And. (cQuebra1 == Iif(aReturn[8]==1.Or.aReturn[8]==3,.T.,&(cCampo))) .And. lContinua
		
		// Desconsiderar VEICULOS e SERVICOS
		If SB1->B1_GRUPO == cGruVei .or. SB1->B1_GRUPO == cGruSrv
			SB1->(dbSkip())
			Loop
		EndIf

		lImpr := .F.
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se imprime nome cientifico do produto. Se Sim    ³
		//³ verifica se existe registro no SB5 e se nao esta vazio    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cDesc := SB1->B1_DESC
		lIsCient := .F.
		If mv_par17 == 1
			dbSelectArea("SB5")
			dbSeek(xFilial()+SB1->B1_COD)
			If Found() .and. !Empty(B5_CEME)
				cDesc := B5_CEME
				lIsCient := .T.
			EndIf
			dbSelectArea('SB1')
		Endif
		
		//-- Consiste Descri‡Æo De/At‚
		If cDesc < mv_par12 .Or. cDesc > mv_par13
			SB1->(dbSkip())
			Loop
		EndIf
		
		//-- Filtro do usuario
		If !Empty(aReturn[7]) .And. !&(aReturn[7])
			SB1->(dbSkip())
			Loop
		EndIf
		
		For nX := 1 to Len(aFiliais)
			cFilAnt := aFiliais[nX]
			
			IF !lContinua
				Exit
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Localiza produto no Cadastro de ACUMULADOS DO ESTOQUE        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea('SB2')
			If mv_par01 == 3
				dbSeek(SB1->B1_COD + xFilial('SB2'), .T.)
			ElseIf mv_par01 == 2
				dbSeek(xFilial('SB2') + SB1->B1_COD, .T.)
			Else
				dbSeek(SB1->B1_COD + xFilial('SB2') + mv_par04, .T.)
			EndIf
			
			//-- 1§ Looping no Arquivo Secund rio (SB2)
			Do While lContinua .And. !SB2->(Eof()) .And. xFilial("SB2") == B2_FILIAL .AND. B2_COD == SB1->B1_COD
				
				If mv_par01 == 3
					If Empty(xFilial('SB1'))
						cQuebra2  := B2_COD
						cCond2	 := 'B2_COD == cQuebra2'
					Else
						cQuebra2  := B2_COD + B2_FILIAL
						cCond2	 := 'B2_COD + B2_FILIAL == cQuebra2'
					EndIf
				ElseIf mv_par01 == 2
					cQuebra2 := B2_FILIAL + B2_COD
					cCond2   := 'B2_FILIAL + B2_COD == cQuebra2'
				Else
					cQuebra2 := B2_COD + B2_FILIAL + B2_LOCAL
					cCond2   := 'B2_COD + B2_FILIAL + B2_LOCAL == cQuebra2'
				EndIf
				
				//-- NÆo deixa o mesmo Filial/Produto passar mais de 1 vez
				If Len(aProd) <= 4096
					If Len(aProd) == 0 .Or. Len(aProd[Len(aProd)]) == 4096
						aAdd(aProd, {})
					EndIf
					If aScan(aProd[Len(aProd)], cQuebra2) > 0
						SB2->(dbSkip())
						Loop
					Else
						aAdd(aProd[Len(aProd)], cQuebra2)
					EndIf
				Else
					If Len(aProd1) == 0 .Or. Len(aProd1[Len(aProd1)]) == 4096
						aAdd(aProd1, {})
					EndIf
					If aScan(aProd1[Len(aProd1)], cQuebra2) > 0
						SB2->(dbSkip())
						Loop
					Else
						aAdd(aProd1[Len(aProd1)], cQuebra2)
					EndIf
				EndIf
				
				//-- 2§ Looping no Arquivo Secund rio (SB2)
				Do While lContinua .And. !SB2->(Eof()) .And. &(cCond2)
					
					If aReturn[8] == 2 //-- Tipo
						If SB1->B1_TIPO # fContSB1(SB2->B2_FILIAL, SB2->B2_COD, 'B1_TIPO')
							SB2->(dbSkip())
							Loop
						EndIf
					ElseIf aReturn[8] == 4 //-- Grupo
						If SB1->B1_GRUPO # fContSB1(SB2->B2_FILIAL, SB2->B2_COD, 'B1_GRUPO')
							SB2->(dbSkip())
							Loop
						EndIf
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Carrega array com dados do produto na data base.             ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					IF mv_par15 > 2
						//-- Verifica se o SM0 esta posicionado na Filial Correta
						If !Empty(SB2->B2_FILIAL) .And. !(cFilAnt==SB2->B2_FILIAL)
							aSalProd := {0,0,0,0,0,0,0}
						Else
							aSalProd := CalcEst(SB2->B2_COD,SB2->B2_LOCAL,dDataBase+1)
						EndIf
					Else
						aSalProd := {0,0,0,0,0,0,0}
					Endif
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica se devera ser impressa o produto zerado             ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If Iif(mv_par15==1,B2_QATU,Iif(mv_par15==2,B2_QFIM,aSalProd[1])) == 0 .And. mv_par14 == 2 .Or. ;
						Iif(mv_par15==1,B2_QATU,Iif(mv_par15==2,B2_QFIM,aSalProd[1])) > 0  .And. mv_par16 == 1
						cCodAnt := SB2->B2_COD
						SB2->(dbSkip())
						If mv_par01 == 1 .And. SB2->B2_COD # cCodAnt
							If nQtdProd > 1
								lImpr := .T.
							Else
								nSoma    := 0
								nQtdProd := 0
							EndIf
						EndIf
						Loop
					EndIf
					
					lImpr := .T.
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Adiciona 1 ao contador de registros impressos         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If mv_par01 == 1 
					    nSizFil := 12-FWSizeFilial()
						cStr := left(fContSB1(cFilOld, SB2->B2_COD, 'B1_GRUPO')+space(4),4)+" "+;
						left(fContSB1(cFilOld, SB2->B2_COD, 'B1_CODITE')+space(27),27)+" "+;
						left(SB2->B2_COD+space(15),15)+" "+;
						left(fContSB1(SB2->B2_FILIAL, SB2->B2_COD, 'B1_TIPO')+space(2),2)+" "+;
						Left(Iif(lIsCient, cDesc,	fContSB1(SB2->B2_FILIAL, SB2->B2_COD, 'B1_DESC')),17)+" "+;
						fContSB1(SB2->B2_FILIAL, SB2->B2_COD, 'B1_UM')+" "+B2_FILIAL+space(nSizFil)+" "+B2_LOCAL+"   "+Transform( iif(mv_par15==1,B2_QATU,iif(mv_par15==2,B2_QFIM,aSalProd[1])), cPict)
						nQtdProd ++
						oSection1:PrintLine()
					EndIf
					
					nSoma += iif(mv_par15==1,B2_QATU,iif(mv_par15==2,B2_QFIM,aSalProd[1]))
					nTotSoma += iif(mv_par15==1,B2_QATU,iif(mv_par15==2,B2_QFIM,aSalProd[1]))
					
					cFilOld := SB2->B2_FILIAL
					cCodAnt := SB2->B2_COD
					
					SB2->(dbSkip())
					
				EndDo
				
				If lImpr
					
					If mv_par01 == 1
						If SB2->B2_COD # cCodAnt .And. ;
							(aReturn[8] # 2 .And. aReturn[8] # 4)
							If nQtdProd > 1
								cStr := (STR0014) + Space(1) + AllTrim(Left(cCodAnt,15)) + Space(1) + Replicate('.',21-Len(AllTrim(Left(cCodAnt,15))))+" "+; // 'Total do Produto'
								Transform(nSoma, cPict)
								oSection1:PrintLine()
								cStr :=""
								oSection1:PrintLine()
							EndIf
							nSoma    := 0
							nQtdProd := 0
						EndIf
					Else    
					    nSizFil := 12-FWSizeFilial()
						cStr := fContSB1(cFilOld, cCodAnt, 'B1_GRUPO')+" "+fContSB1(cFilOld, cCodAnt, 'B1_CODITE')+" "+;
						Left(cCodAnt+space(15),15)+" "+fContSB1(cFilOld, cCodAnt, 'B1_TIPO')+" "+Left(Iif(lIsCient, cDesc,	fContSB1(cFilOld, cCodAnt, 'B1_DESC')),17)+" "+;
						fContSB1(cFilOld, cCodAnt, 'B1_UM')+" "+Iif(mv_par01==2,cFilOld+space(nSizFil),Repl("*",FWSizeFilial())+space(nSizFil))+" **"+Transform(nSoma, cPict)
						nSoma := 0
						oSection1:PrintLine()
						
					EndIf
					
					lImpr := .F.
					
				EndIf
			EndDo
			
		Next nX
		cFilAnt := cBkpFilAnt
		
		dbSelectArea('SB1')
		SB1->(dbSkip())
		
	EndDo
	
	If (aReturn[8] == 2 .Or. aReturn[8] == 4) .And. ;
		nTotSoma # 0
		cStr := STR0018 + cMens+" "+Transform(nTotSoma, cPict)
		oSection1:PrintLine()
		nTotSoma := 0
	EndIf
	
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Devolve as ordens originais dos arquivos                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RetIndex('SB2')
Set Filter to

RetIndex('SB1')
Set Filter to

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga indices de trabalho                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If File(cNomArqB2 += OrdBagExt())
	fErase(cNomArqB2)
EndIf
If File(cNomArqB1 += OrdBagExt())
	fErase(cNomArqB1)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Devolve a condicao original dos arquivos principal           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea('SB1')
Set Filter To
dbSetOrder(1)

dbSelectArea('SB2')
Set Filter To
dbSetOrder(1)

oSection1:Finish()

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OR240R3  ³ Autor ³  Thiago        ³ Data ³ 21/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Demonstrativo de Metas de Vendas                    |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OR240R3()

Local Tamanho    := 'G'
Local Titulo     := STR0001 // 'Saldos em Estoque'
Local cDesc1     := STR0002 // "Este programa ira' emitir um resumo dos saldos, em quantidade,"
Local cDesc2     := STR0003 // 'dos produtos em estoque.'
Local cDesc3     := ''
Local cString    := 'SB1'
Local aOrd       := {(STR0004),(STR0005),(STR0006),(STR0007)} // ' Por Codigo         '###' Por Tipo           '###' Por Descricao    '###' Por Grupo        '
Local WnRel      := 'OFIOR240'
Local limite       := 220

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis tipo Private padrao de todos os relatorios         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aReturn    := {(STR0008), 1,(STR0009), 2, 2, 1, '',1 } // 'Zebrado'###'Administracao'
Private nLastKey   := 0
Private cPerg      := 'OFR240'

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                                  ³
//³ mv_par01     // Aglutina por: Almoxarifado / Filial / Empresa         ³
//³ mv_par02     // Filial de                                             ³
//³ mv_par03     // Filial ate                                            ³
//³ mv_par04     // Almoxarifado de                                       ³
//³ mv_par05     // Almoxarifado ate                                      ³
//³ mv_par06     // Produto de                                            ³
//³ mv_par07     // Produto ate                                           ³
//³ mv_par08     // tipo de                                               ³
//³ mv_par09     // tipo ate                                              ³
//³ mv_par10     // grupo de                                              ³
//³ mv_par11     // grupo ate                                             ³
//³ mv_par12     // descricao de                                          ³
//³ mv_par13     // descricao ate                                         ³
//³ mv_par14     // imprime qtde zeradas                                  ³
//³ mv_par15     // Saldo a considerar : Atual / Fechamento / Movimento   ³
//³ mv_par16     // Lista Somente Saldos Negativos                 		  ³
//³ mv_par17     // Descricao Produto : Cientifica / Generica      		  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
WnRel := SetPrint(cString,WnRel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,Tamanho)

If nLastKey == 27
	Set Filter to
	Return Nil
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Set Filter to
	Return Nil
Endif

RptStatus({|lEnd| C240Imp(aOrd,@lEnd,WnRel,Titulo,Tamanho)},Titulo)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ C240IMP  ³ Autor ³ Rodrigo de A. Sartorio³ Data ³ 11.12.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ OFIOR240													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function C240Imp(aOrd,lEnd,WnRel,Titulo,Tamanho)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cRodaTxt   := 'REG(S)'
Local nCntImpr   := 0
Local nTipo      := 0

//
Local cGruVei    := PadR(AllTrim(GetNewPar("MV_GRUVEI","VEIC")),TamSx3("B1_GRUPO")[1]," ") // Grupo do Veiculo
Local cGruSrv    := PadR(AllTrim(GetNewPar("MV_GRUSRV","SRVC")),TamSx3("B1_GRUPO")[1]," ") // Grupo do Servico
//

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis locais exclusivas deste programa                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lImpr      :=.F.
Local nSoma      := 0
Local nSavRec    := 0
Local nTotSoma   := 0
Local nX         := 0
Local nRegM0     := 0
Local nIndB1     := 0
Local nIndB2     := 0
Local nQtdProd   := 0
Local aSalProd   := {}
Local cFilialDe  := ''
Local cQuebra1   := ''
Local cCampo     := ''
Local cMens      := ''
Local aProd      := {}
Local aProd1     := {}
Local aProd2     := {}
Local aProd3     := {}
Local cFilOld    := 'úú'
Local cCodAnt    := 'úú'
Local cDesc
Local lIsCient
Local cPict
// Fernando 09/11/99
If ( cPaisLoc=="CHI" )
	cPict:= "@E 999,999,999,999.99"
Else
	cPict:= PesqPictQt(Iif(mv_par15==1,'B2_QATU','B2_QFIM'),16)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Private exclusivas deste programa                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cQuebra2   := ''
Private cCond2     := ''
Private cFiltroB1  := ''
Private cIndB1     := ''
Private aFilAtu        := FWArrFilAtu() // carrega os dados da Filial logada ( Grupo de Empresa / Empresa / Filial ) 
Private aFiliais       := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. ) // Levanta todas as Filiais da Empresa logada (vetor utilizado no FOR das Filiais)
Private nCont          := 0
Private cBkpFilAnt := cFilAnt // salvar cFilAnt
Private cFiltroB2  := ''
Private cIndB2     := ''
Private lContinua  := .T.
Private cNomArqB1  := ''
Private cNomArqB2  := ''                              ­



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Contadores de linha e pagina                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private Li         := 80
Private m_pag      := 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa os codigos de caracter Comprimido/Normal da impressora ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTipo := Iif(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona a ordem escolhida ao Titulo do relatorio          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type('NewHead') # 'U'
	NewHead := AllTrim(NewHead)
	NewHead += ' (' + AllTrim(SubStr(aOrd[aReturn[8]],6,20)) + ')'
Else
	Titulo := AllTrim(Titulo)
	Titulo += ' (' + AllTrim(SubStr(aOrd[aReturn[8]],6,20)) + ')'
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta os Cabecalhos                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCabec1 := (STR0010) // 'CODIGO          TP GRUP DESCRICAO                      UM FL ALM      QUANTIDADE'
cCabec2 := ''
//-- 123456789012345 12 1234 123456789012345678901234567890 12 12 12 999,999,999.99
//-- 0         1         2         3         4         5         6         7
//-- 012345678901234567890123456789012345678901234567890123456789012345678901234567890

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processos de Inicia‡„o dos Arquivos Utilizados               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//-- SB2 (Saldos em Estoque)
dbSelectArea('SB2')
dbSetOrder(1)

cFiltroB2 := 'B2_COD>="'+mv_par06+'".And.B2_COD<="'+mv_par07+'".And.'
cFiltroB2 += 'B2_LOCAL>="'+mv_par04+'".And.B2_LOCAL<="'+mv_par05+'"'
If !Empty(xFilial('SB2'))
	cFiltroB2 += '.And.B2_FILIAL>="'+mv_par02+'".And.B2_FILIAL<="'+mv_par03+'"'
EndIf

If mv_par01 == 3
	cIndB2 := 'B2_COD + B2_FILIAL + B2_LOCAL'
ElseIf mv_par01 == 2
	cIndB2 := 'B2_FILIAL + B2_COD + B2_LOCAL'
Else
	cIndB2 := 'B2_COD + B2_FILIAL + B2_LOCAL'
EndIf

cNomArqB2 := Left(CriaTrab('',.F.),7) + 'a'

IndRegua('SB2',cNomArqB2,cIndB2,,cFiltroB2,STR0017) //Selecionando Registros...
nIndB2 := RetIndex('SB2')
#IFNDEF TOP
	dbSetIndex(cNomArqB2 + OrdBagExt())
#ENDIF
dbSetOrder(nIndB2 + 1)
dbGoTop()

//-- SB1 (Produtos)
dbSelectArea('SB1')
dbSetOrder(aReturn[8])

cFiltroB1 := 'B1_COD>="'+mv_par06+'".And.B1_COD<="'+mv_par07+'".And.'
cFiltroB1 += 'B1_TIPO>="'+mv_par08+'".And.B1_TIPO<="'+mv_par09+'".And.'
cFiltroB1 += 'B1_GRUPO>="'+mv_par10+'".And.B1_GRUPO<="'+mv_par11+'"'
If !Empty(xFilial('SB1'))
	cFiltroB1 += '.And.B1_FILIAL>="'+mv_par02+'".And.B1_FILIAL<="'+mv_par03+'"'
EndIf

If aReturn[8] == 4
	cIndB1 := 'B1_GRUPO+B1_COD+B1_FILIAL'
	cCampo := 'B1_GRUPO'
	cMens  := (STR0012) // 'Grupo.........'
ElseIf aReturn[8] == 3
	cIndB1 := 'B1_DESC+B1_COD+B1_FILIAL'
	cCampo := .T.
ElseIf aReturn[8] == 2
	cIndB1 := 'B1_TIPO+B1_COD+B1_FILIAL'
	cCampo := 'B1_TIPO'
	cMens  := (STR0011) // 'Tipo..........'
Else
	cIndB1 := 'B1_COD+B1_FILIAL'
	cCampo := .T.
Endif

cNomArqB1 := Left(CriaTrab('',.F.),7) + 'b'

IndRegua('SB1',cNomArqB1,cIndB1,,cFiltroB1,STR0017) //Selecionando Registros...
nIndB1 := RetIndex('SB1')
#IFNDEF TOP
	dbSetIndex(cNomArqB1 + OrdBagExt())
#ENDIF
dbSetOrder(nIndB1 + 1)
dbGoTop()

SetRegua(LastRec())

cFilialDe := Iif(Empty(xFilial('SB2')),xFilial('SB2'),mv_par02)

If aReturn[8] == 4
	dbSeek(mv_par10, .T.)
ElseIf aReturn[8] == 3
	//-- Pesquisa Somente se a Descricao For Generica.
	If mv_par17 == 2
		dbSeek(mv_par12, .T.)
	Endif
ElseIf aReturn[8] == 2
	dbSeek(mv_par08, .T.)
Else
	dbSeek(mv_par06, .T.)
Endif

//-- 1§ Looping no Arquivo Principal (SB1)
Do While !SB1->(Eof()) .and. lContinua
	
	// Desconsiderar VEICULOS e SERVICOS
	If SB1->B1_GRUPO == cGruVei .or. SB1->B1_GRUPO == cGruSrv
		SB1->(dbSkip())
		Loop
	EndIf

	aProd  := {}
	aProd1 := {}
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se imprime nome cientifico do produto. Se Sim    ³
	//³ verifica se existe registro no SB5 e se nao esta vazio    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cDesc := SB1->B1_DESC
	lIsCient := .F.
	If mv_par17 == 1
		dbSelectArea("SB5")
		dbSeek(xFilial()+SB1->B1_COD)
		If Found() .and. !Empty(B5_CEME)
			cDesc := B5_CEME
			lIsCient := .T.
		EndIf
		dbSelectArea('SB1')
	Endif
	
	//-- Consiste Descri‡Æo De/At‚
	If cDesc < mv_par12 .Or. cDesc > mv_par13
		SB1->(dbSkip())
		Loop
	EndIf
	
	//-- Filtro do usuario
	If !Empty(aReturn[7]) .And. !&(aReturn[7])
		SB1->(dbSkip())
		Loop
	EndIf
	
	If lEnd
		@ PROW()+1, 001 pSay (STR0013) // 'CANCELADO PELO OPERADOR'
		Exit
	EndIf
	
	cQuebra1 := Iif(aReturn[8]==1.Or.aReturn[8]==3,.T.,&(cCampo))
	
	//-- 2§ Looping no Arquivo Principal (SB1)
	Do While !SB1->(Eof()) .And. (cQuebra1 == Iif(aReturn[8]==1.Or.aReturn[8]==3,.T.,&(cCampo))) .And. lContinua
		
		// Desconsiderar VEICULOS e SERVICOS
		If SB1->B1_GRUPO == cGruVei .or. SB1->B1_GRUPO == cGruSrv
			SB1->(dbSkip())
			Loop
		EndIf

		//-- Incrementa R‚gua
		IncRegua()
		
		lImpr := .F.
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se imprime nome cientifico do produto. Se Sim    ³
		//³ verifica se existe registro no SB5 e se nao esta vazio    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cDesc := SB1->B1_DESC
		lIsCient := .F.
		If mv_par17 == 1
			dbSelectArea("SB5")
			dbSeek(xFilial()+SB1->B1_COD)
			If Found() .and. !Empty(B5_CEME)
				cDesc := B5_CEME
				lIsCient := .T.
			EndIf
			dbSelectArea('SB1')
		Endif
		
		//-- Consiste Descri‡Æo De/At‚
		If cDesc < mv_par12 .Or. cDesc > mv_par13
			SB1->(dbSkip())
			Loop
		EndIf
		
		//-- Filtro do usuario
		If !Empty(aReturn[7]) .And. !&(aReturn[7])
			SB1->(dbSkip())
			Loop
		EndIf
		
		For nX := 1 to Len(aFiliais)
			cFilAnt := aFiliais[nX]
			
			IF !lContinua
				Exit
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Localiza produto no Cadastro de ACUMULADOS DO ESTOQUE        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea('SB2')
			If mv_par01 == 3
				dbSeek(SB1->B1_COD + xFilial('SB2'), .T.)
			ElseIf mv_par01 == 2
				dbSeek(xFilial('SB2') + SB1->B1_COD, .T.)
			Else
				dbSeek(SB1->B1_COD + xFilial('SB2') + mv_par04, .T.)
			EndIf
			
			//-- 1§ Looping no Arquivo Secund rio (SB2)
			Do While lContinua .And. !SB2->(Eof()) .And. xFilial("SB2") == B2_FILIAL .AND. B2_COD == SB1->B1_COD
				
				If mv_par01 == 3
					If Empty(xFilial('SB1'))
						cQuebra2  := B2_COD
						cCond2	 := 'B2_COD == cQuebra2'
					Else
						cQuebra2  := B2_COD + B2_FILIAL
						cCond2	 := 'B2_COD + B2_FILIAL == cQuebra2'
					EndIf
				ElseIf mv_par01 == 2
					cQuebra2 := B2_FILIAL + B2_COD
					cCond2   := 'B2_FILIAL + B2_COD == cQuebra2'
				Else
					cQuebra2 := B2_COD + B2_FILIAL + B2_LOCAL
					cCond2   := 'B2_COD + B2_FILIAL + B2_LOCAL == cQuebra2'
				EndIf
				
				//-- NÆo deixa o mesmo Filial/Produto passar mais de 1 vez
				If Len(aProd) <= 4096
					If Len(aProd) == 0 .Or. Len(aProd[Len(aProd)]) == 4096
						aAdd(aProd, {})
					EndIf
					If aScan(aProd[Len(aProd)], cQuebra2) > 0
						SB2->(dbSkip())
						Loop
					Else
						aAdd(aProd[Len(aProd)], cQuebra2)
					EndIf
				Else
					If Len(aProd1) == 0 .Or. Len(aProd1[Len(aProd1)]) == 4096
						aAdd(aProd1, {})
					EndIf
					If aScan(aProd1[Len(aProd1)], cQuebra2) > 0
						SB2->(dbSkip())
						Loop
					Else
						aAdd(aProd1[Len(aProd1)], cQuebra2)
					EndIf
				EndIf
				
				//-- 2§ Looping no Arquivo Secund rio (SB2)
				Do While lContinua .And. !SB2->(Eof()) .And. &(cCond2)
					
					If aReturn[8] == 2 //-- Tipo
						If SB1->B1_TIPO # fContSB1(SB2->B2_FILIAL, SB2->B2_COD, 'B1_TIPO')
							SB2->(dbSkip())
							Loop
						EndIf
					ElseIf aReturn[8] == 4 //-- Grupo
						If SB1->B1_GRUPO # fContSB1(SB2->B2_FILIAL, SB2->B2_COD, 'B1_GRUPO')
							SB2->(dbSkip())
							Loop
						EndIf
					EndIf
					
					If lEnd
						@ PROW()+1, 001 pSay (STR0013) // 'CANCELADO PELO OPERADOR'
						lContinua := .F.
						Exit
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Carrega array com dados do produto na data base.             ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					IF mv_par15 > 2
						//-- Verifica se o SM0 esta posicionado na Filial Correta
						If !Empty(SB2->B2_FILIAL) .And. !(cFilAnt==SB2->B2_FILIAL)
							aSalProd := {0,0,0,0,0,0,0}
						Else
							aSalProd := CalcEst(SB2->B2_COD,SB2->B2_LOCAL,dDataBase+1)
						EndIf
					Else
						aSalProd := {0,0,0,0,0,0,0}
					Endif
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica se devera ser impressa o produto zerado             ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If Iif(mv_par15==1,B2_QATU,Iif(mv_par15==2,B2_QFIM,aSalProd[1])) == 0 .And. mv_par14 == 2 .Or. ;
						Iif(mv_par15==1,B2_QATU,Iif(mv_par15==2,B2_QFIM,aSalProd[1])) > 0  .And. mv_par16 == 1
						cCodAnt := SB2->B2_COD
						SB2->(dbSkip())
						If mv_par01 == 1 .And. SB2->B2_COD # cCodAnt
							If nQtdProd > 1
								lImpr := .T.
							Else
								nSoma    := 0
								nQtdProd := 0
							EndIf
						EndIf
						Loop
					EndIf
					
					lImpr := .T.
					
					If Li > 55
						Cabec(Titulo,cCabec1,cCabec2,WnRel,Tamanho,nTipo)
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Adiciona 1 ao contador de registros impressos         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If mv_par01 == 1
						@ Li, 00 pSay fContSB1(cFilOld, SB2->B2_COD, 'B1_GRUPO')
						@ li, pcol()+1 pSay fContSB1(cFilOld, SB2->B2_COD, 'B1_CODITE')
						@ li, pcol()+1 pSay left(SB2->B2_COD+space(15),15)
						@ Li, pcol()+1 pSay fContSB1(SB2->B2_FILIAL, SB2->B2_COD, 'B1_TIPO')
						@ Li, pcol()+1 pSay Left(Iif(lIsCient, cDesc,	fContSB1(SB2->B2_FILIAL, SB2->B2_COD, 'B1_DESC')),17)
						@ Li, pcol()+1 pSay fContSB1(SB2->B2_FILIAL, SB2->B2_COD, 'B1_UM')
					    nSizFil := 12-FWSizeFilial()
						@ Li, pcol()+1 pSay B2_FILIAL+space(nSizFil)
						@ Li, pcol()+1 pSay B2_LOCAL
						@ Li, pcol()+1 pSay Transform( Iif(mv_par15==1,B2_QATU,Iif(mv_par15==2,B2_QFIM,aSalProd[1])), cPict)
						Li++
						nQtdProd ++
					EndIf
					
					nSoma += Iif(mv_par15==1,B2_QATU,Iif(mv_par15==2,B2_QFIM,aSalProd[1]))
					nTotSoma += Iif(mv_par15==1,B2_QATU,Iif(mv_par15==2,B2_QFIM,aSalProd[1]))
					
					cFilOld := SB2->B2_FILIAL
					cCodAnt := SB2->B2_COD
					
					SB2->(dbSkip())
					
				EndDo
				
				If lImpr
					
					If Li > 55
						Cabec(Titulo,cCabec1,cCabec2,WnRel,Tamanho,nTipo)
						
					EndIf
					
					If mv_par01 == 1
						If SB2->B2_COD # cCodAnt .And. ;
							(aReturn[8] # 2 .And. aReturn[8] # 4)
							If nQtdProd > 1
								@ Li, 44 pSay (STR0014) + Space(1) + AllTrim(Left(cCodAnt,15)) + Space(5) + Replicate('.',21-Len(AllTrim(Left(cCodAnt,15)))) // 'Total do Produto'
								@ Li, 89 pSay Transform(nSoma, cPict)
								Li += 2
							EndIf
							nSoma    := 0
							nQtdProd := 0
						EndIf
					Else
						@ Li, 00 pSay fContSB1(cFilOld, cCodAnt, 'B1_GRUPO')
						@ Li, pcol()+1 pSay fContSB1(cFilOld, cCodAnt, 'B1_CODITE')
						@ Li, pcol()+1 pSay left(cCodAnt+space(15),15)
						@ Li, pcol()+1 pSay fContSB1(cFilOld, cCodAnt, 'B1_TIPO')
						@ Li, pcol()+1 pSay Left(Iif(lIsCient, cDesc,	fContSB1(cFilOld, cCodAnt, 'B1_DESC')),17)
						@ Li, pcol()+1 pSay fContSB1(cFilOld, cCodAnt, 'B1_UM') 
					    nSizFil := 12-FWSizeFilial()
						@ Li, pcol()+1 pSay Iif(mv_par01==2,cFilOld+space(nSizFil),Repl("*",FWSizeFilial())+space(nSizFil))
						@ Li, pcol()+1 pSay '**'
						@ Li, pcol()+1 pSay Transform(nSoma, cPict)
						Li++
						nSoma := 0
					EndIf
					
					lImpr := .F.
					
				EndIf
			EndDo
			
		Next nX
		cFilAnt := cBkpFilAnt

		dbSelectArea('SB1')
		SB1->(dbSkip())
		
	EndDo
	
	If Li > 55
		Cabec(Titulo,cCabec1,cCabec2,WnRel,Tamanho,nTipo)
		
	EndIf
	
	If (aReturn[8] == 2 .Or. aReturn[8] == 4) .And. ;
		nTotSoma # 0
		@ Li, 40 pSay STR0018 + cMens
		@ Li, 64 pSay Transform(nTotSoma, cPict)
		Li += 2
		nTotSoma := 0
	EndIf
	
EndDo

If Li # 80
	Roda(nCntImpr,cRodaTxt,Tamanho)
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Devolve as ordens originais dos arquivos                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RetIndex('SB2')
Set Filter to

RetIndex('SB1')
Set Filter to

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga indices de trabalho                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If File(cNomArqB2 += OrdBagExt())
	fErase(cNomArqB2)
EndIf
If File(cNomArqB1 += OrdBagExt())
	fErase(cNomArqB1)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Devolve a condicao original dos arquivos principal           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea('SB1')
Set Filter To
dbSetOrder(1)

dbSelectArea('SB2')
Set Filter To
dbSetOrder(1)

If aReturn[5] == 1
	Set Printer To
	dbCommitAll()
	OurSpool(WnRel)
Endif

Ms_Flush()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ fContSB1 ³ Autor ³ Fernando Joly Siquini ³ Data ³ 13.10.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Procura produto em SB1 e retorna o conteudo do campo       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fContSB1( cChave, cCampo)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parƒmetros³ cFil   = Filial de procura                                 ³±±
±±³Parƒmetros³ cCod   = Codido de procura                                 ³±±
±±³          ³ cCampo = Campo cujo conte£do se deseja retornar            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fContSB1(cFil, cCod, cCampo)

//-- Inicializa Variaveis
Local cCont      := &('SB1->' + cCampo)
Local cPesq      := ''
Local nPos       := 0
Local nOrdem     := SB1->(IndexOrd())
Local nRecno     := SB1->(Recno())

If Empty(xFilial('SB1')) .And. !Empty(cFil)
	cFil := xFilial('SB1')
EndIf

cPesq := cFil + cCod

If cPesq == Nil .Or. cCampo == Nil
	Return cCont
EndIf

SB1->(dbSetOrder(1))
If SB1->(dbSeek(cPesq, .F.)) .And. (nPos := SB1->(FieldPos(Upper(cCampo)))) > 0
	cCont := SB1->(FieldGet(nPos))
EndIf

SB1->(dbSetOrder(nOrdem))
SB1->(dbGoto(nRecno))

Return cCont
