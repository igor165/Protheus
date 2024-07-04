#INCLUDE "MATR939.ch"
#INCLUDE "Protheus.ch"

STATIC cDbType := TCGetDB()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MATR939  ºAutor  ³Mary C. Hergert     º Data ³ 26/08/2005  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valor Adicionado Fiscal - VAF                              º±±
±±º          ³ Relatorio auxiliar para preenchimento                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigafis                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function MATR939

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao das variaveis                                      |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aWizard		:= {}         
Local aCFOPs		:= {}
Local aArea			:= GetArea()

Local Titulo    	:= STR0001	   	//"Valor Adicionado Fiscal (VAF)"
Local cDesc1    	:= STR0002 		//"Este relatório é uma ferramenta auxiliar para o preenchimento"
Local cDesc2    	:= STR0003  	//"da VAF - Valor Adicionado Fiscal"
Local cDesc3    	:= ""
Local wnrel     	:= "MATR939"  			// Nome do Arquivo utilizado no Spool
Local nomeprog  	:= "MATR939"  			// nome do programa
Local cString		:= "SF3"
Local cTitulo		:= ""
Local cMensagem		:= ""
Local cHelp			:= ""
Local cMunA1		:= SuperGetMv("MV_VAFA1")
Local cMunA2		:= SuperGetMv("MV_VAFA2")

Local lRet			:= .T.
Local lDic      	:= .F. 					// Habilita/Desabilita Dicionario
Local lComp     	:= .F. 					// Habilita/Desabilita o Formato Comprimido/Expandido
Local lFiltro   	:= .F. 					// Habilita/Desabilita o Filtro
Local lHelp			:= .F.

Local nPagina		:= 1
Local nMunA1		:= Iif(!Empty(cMunA1),SA1->(FieldPos((cMunA1))),0)
Local nMunA2 		:= Iif(!Empty(cMunA2),SA2->(FieldPos((cMunA2))),0)
Local lVerpesssen 	:= Iif(FindFunction("Verpesssen"),Verpesssen(),.T.)

Private aReturn 	:= {STR0004,1,STR0005,1,2,1,"",1}	//"Zebrado"###"Administracao"

Private Tamanho 	:= "M"					// P/M/G
Private cPerg   	:= "MTR939"				// Pergunta do Relatorio

Private lEnd    	:= .F.					// Controle de cancelamento do relatorio

Private Limite  	:= 132 					// 80/132/220
Private m_pag   	:= 1  					// Contador de Paginas
Private nLastKey	:= 0  					// Controla o cancelamento da SetPrint e SetDefault

If lVerpesssen
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica a consistencia dos parametros da rotina³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(cMunA1) .Or. nMunA1 == 0
		cTitulo		:= STR0048 //"Parâmetro não existe"
		cMensagem	:= STR0049 //"O parâmetro MV_VAFA1 não está definido no dicionário de dados ou o seu conteúdo é inválido. "
		cMensagem   += STR0050 //"Para que a rotina continue corretamente, "
		cMensagem	+= STR0051 //"será necessário respeitar a solução proposta abaixo."
		cHelp		:= STR0052 //"Incluir o parâmetro MV_VAFA1 na tabela SX6 com a seguinte estrutura: "
		cHelp		+= STR0053 //"Campo da tabela SA1 que indica o código da município mineiro do cliente. "
		cHelp		+= STR0054 //" Para maiores referências, consultar a documentação que acompanha a rotina."
		xMagHelpFis(cTitulo,cMensagem,cHelp)
		lHelp		:= .T.
	Endif

	If Empty(cMunA2) .Or. nMunA2 == 0
		cTitulo		:= STR0048 //"Parâmetro não existe"
		cMensagem	:= STR0055 //"O parâmetro MV_VAFA2 não está definido no dicionário de dados ou o seu conteúdo é inválido. "
		cMensagem   += STR0050 //"Para que a rotina continue corretamente, "
		cMensagem	+= STR0051 //"será necessário respeitar a solução proposta abaixo."
		cHelp		:= STR0056 //"Incluir o parâmetro MV_VAFA2 na tabela SX6 com a seguinte estrutura: "
		cHelp		+= STR0057 //"Campo da tabela SA2 que indica o código da município mineiro do fornecedor. "
		cHelp		+= STR0054 //" Para maiores referências, consultar a documentação que acompanha a rotina."
		xMagHelpFis(cTitulo,cMensagem,cHelp)
		lHelp		:= .T.
	Endif
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processa a Wizard com as configuracoes para o relatorio³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ! lHelp
		If MATR939Wiz()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Envia para a SetPrint                                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			wnrel:=SetPrint(cString,wnrel,"",@titulo,cDesc1,cDesc2,cDesc3,lDic,"",lComp,Tamanho,lFiltro,.F.)
			If ( nLastKey==27 )
				dbSelectArea(cString)
				dbSetOrder(1)
				dbClearFilter()
				Return
			Endif
			SetDefault(aReturn,cString)
			If ( nLastKey==27 )
				dbSelectArea(cString)
				dbSetOrder(1)
				dbClearFilter()
				Return
			Endif
			
			RptStatus({|lEnd| ImpRel(@lEnd,wnRel,cString,Tamanho,nPagina)},titulo)
		Endif
	Endif
			
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura Ambiente                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea(cString)
	dbClearFilter()
	Set Device To Screen
	Set Printer To

	If ( aReturn[5] = 1 )
		dbCommitAll()
		OurSpool(wnrel)
	Endif
	MS_FLUSH()
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ImpRel   ºAutor  ³Mary C. Hergert     º Data ³ 26/08/2005  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Imprime o Relatorio                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATR939                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                    

Static Function ImpRel(lEnd,wnRel,cString,Tamanho,nPagina)       

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Definicao de Variaveis                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aWizard	:= {}
	Local aEntrEst	:= {}
	Local aEntrOut	:= {}
	Local aEntrExt	:= {}
	Local aEntrMun	:= {}
	Local aEntrUF	:= {}
	Local aSaiEst	:= {}
	Local aSaiOut	:= {}
	Local aSaiExt	:= {}
	Local aSaiUF	:= {}
	Local aExclu	:= {}
	Local aInvent 	:= {}
	Local aEstoque	:= {}
	Local aUF 		:= {}
	Local aLay		:= {}
	Local aEst		:= {}
	Local aIniFre	:= {}

	Local cAliasSF3	:= "SF3"
	Local cAliasSD1	:= "SD1"
	Local cAliasSD2	:= "SD2"
	Local cAliasSF4	:= "SF4"
	Local cAliasSB9	:= "SB9"
	Local cAliasSB1	:= "SB1"
	Local cMVESTADO	:= SuperGetMv("MV_ESTADO",.F.,"")
	Local cMunA1	:= SuperGetMv("MV_VAFA1","")
	Local cMunA2	:= SuperGetMv("MV_VAFA2","")
	Local cMunSM0	:= Substr(SM0->M0_CODMUN,3,5)	
	Local cMunic	:= ""
	Local cInscr	:= ""
	Local cTipo		:= ""
	Local cTrib		:= ""
	Local cProcCFOP	:= ""
	Local cCFOPNovo	:= ""
	Local Titulo	:= STR0001 
	Local cCabec1 	:= STR0033 // "DAMEF - Declaração do Movimento Econômico e Fiscal"
	Local cCabec2	:= ""
	Local nomeProg	:= "MATR939"
	Local cDataIni	:= ""
	Local cDataFin	:= ""
	Local cDescMun	:= ""
	Local cIncide	:= ""
	Local cDataB9	:= ""
	Local cFuncNull	:= ""

	Local lRet 		:= .T.
	Local lQuery	:= .F.	
	Local lMov		:= .F.
	Local lProcessa	:= .F.
	Local lSBZ		 := .F. 

	Local nMunA1	:= Iif(!Empty(cMunA1),SA1->(FieldPos((cMunA1))),0)
	Local nMunA2	:= Iif(!Empty(cMunA2),SA2->(FieldPos((cMunA2))),0)
	Local nPos		:= 0
	Local nRegsPrint:= 0
	Local nX		:= 0  
	Local nLin		:= 55
	Local nTotCont 	:= 0
	Local nTotBase 	:= 0
	Local nTotICMS 	:= 0
	Local nTotOutr 	:= 0
	Local nTotEntr 	:= 0
	Local nTotSai 	:= 0
	Local nTotIni 	:= 0
	Local nTotFinal	:= 0
	Local nOutEntr  := 0
	Local nCredPres := 0
	Local nTotOutEn := 0
	Local nTotCrePr := 0
	Local cSep		:= "/"
	Local cAux		:= ""

	#IFDEF TOP
		Local aStruSF3 := {}
		Local aStruSD1 := {}
		Local aStruSD2 := {}
		Local aStruSB9 := {}
		Local cQuery   := ""
		Local cFrom    := ""
	#ELSE
		Local cIndex   := ""
		Local cCondicao:= ""
	#ENDIF
	
	local nAux := 0
	local aAux := {}
	local cIn	:= ""
	local cAliBLH  := GetNextAlias()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Le a wizard com as configuracoes dos CFOPs³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lRet := xMagLeWiz("MATR939",@aWizard,.T.)
	
	aLay := R939LayOut(aWizard)
	cDataIni := aWizard[01][01]
	cDataFin := aWizard[01][02]
	lSBZ     := "1"$aWizard[01][05]
	cAliasPRD:= IIf(lSBZ,"SBZ","SB1")
	cCampoPRD:= IIf(lSBZ,"BZ_CLASFIS","B1_CLASFIS")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se a data digitada e valida para geracao do relatorio.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(cDataIni) .Or. Empty(cDataFin) .Or. cDataIni > cDataFin
		Return
	Endif

	Do Case
		Case cDbType $ "DB2/POSTGRES"
			cFuncNull := "COALESCE"
		Case cDbType $ "ORACLE/INFORMIX"
			cFuncNull := "NVL"
		Otherwise
			cFuncNull := "ISNULL"
	EndCase
	cFuncNull := "%"+cFuncNull+"%"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Estados para os resumos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SX5->(DbSetOrder(1))
	SX5->(DbSeek(xFilial("SX5")+"12"))
	Do While !SX5->(Eof()) .And. SX5->X5_TABELA == "12"
		Aadd(aUF,{AllTrim(SX5->X5_CHAVE),AllTrim(SX5->X5_DESCRI)})
		SX5->(DbSkip())
	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posicoes dos arrays de totalizadores (aEntrEst, aEntrOut, aEntrExt, aSaiEst, ASaiOut, aSaiExt) ³
	//³1 = Titulo da Linha                                                                            ³
	//³2 = Valor Contabil                                                                             ³
	//³3 = Base de Calculo                                                                            ³
	//³4 = Valor do ICMS                                                                              ³
	//³5 = Operacoes sem Credito/Debito de ICMS                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Entradas do Estado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aEntrEst,{STR0018,0,0,0,0}) // Compras
	Aadd(aEntrEst,{STR0019,0,0,0,0}) // Transferências
	Aadd(aEntrEst,{STR0020,0,0,0,0}) // Devoluções
	Aadd(aEntrEst,{STR0021,0,0,0,0}) // Energia Elétrica
	Aadd(aEntrEst,{STR0022,0,0,0,0}) // Comunicações
	Aadd(aEntrEst,{STR0023,0,0,0,0}) // Transportes
	Aadd(aEntrEst,{STR0024,0,0,0,0}) // Outras
	Aadd(aEntrEst,{STR0025,0,0,0,0}) // Produtor Rural

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Entradas de outros Estados³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aEntrOut,{STR0018,0,0,0,0}) // Compras
	Aadd(aEntrOut,{STR0019,0,0,0,0}) // Transferências
	Aadd(aEntrOut,{STR0020,0,0,0,0}) // Devoluções
	Aadd(aEntrOut,{STR0021,0,0,0,0}) // Energia Elétrica
	Aadd(aEntrOut,{STR0022,0,0,0,0}) // Comunicações
	Aadd(aEntrOut,{STR0023,0,0,0,0}) // Transportes
	Aadd(aEntrOut,{STR0024,0,0,0,0}) // Outras

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Entradas do Exterior ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aEntrExt,{STR0018,0,0,0,0}) // Compras
	Aadd(aEntrExt,{STR0020,0,0,0,0}) // Devoluções
	Aadd(aEntrExt,{STR0021,0,0,0,0}) // Energia Elétrica
	Aadd(aEntrExt,{STR0022,0,0,0,0}) // Comunicações
	Aadd(aEntrExt,{STR0023,0,0,0,0}) // Transportes
	Aadd(aEntrExt,{STR0024,0,0,0,0}) // Outras

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Saídas para o Estado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aSaiEst,{STR0029,0,0,0,0}) // Vendas
	Aadd(aSaiEst,{STR0019,0,0,0,0}) // Transferências
	Aadd(aSaiEst,{STR0020,0,0,0,0}) // Devoluções
	Aadd(aSaiEst,{STR0021,0,0,0,0}) // Energia Elétrica
	Aadd(aSaiEst,{STR0022,0,0,0,0}) // Comunicações
	Aadd(aSaiEst,{STR0023,0,0,0,0}) // Transportes
	Aadd(aSaiEst,{STR0024,0,0,0,0}) // Outras
	Aadd(aSaiEst,{STR0102,0,0,0,0}) // Transporte Tomado
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Saídas para outros Estado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aSaiOut,{STR0029,0,0,0,0}) // Vendas
	Aadd(aSaiOut,{STR0019,0,0,0,0}) // Transferências
	Aadd(aSaiOut,{STR0020,0,0,0,0}) // Devoluções
	Aadd(aSaiOut,{STR0021,0,0,0,0}) // Energia Elétrica
	Aadd(aSaiOut,{STR0022,0,0,0,0}) // Comunicações
	Aadd(aSaiOut,{STR0023,0,0,0,0}) // Transportes
	Aadd(aSaiOut,{STR0024,0,0,0,0}) // Outras

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Saídas para o Exterior   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aSaiExt,{STR0029,0,0,0,0}) // Vendas
	Aadd(aSaiExt,{STR0020,0,0,0,0}) // Devoluções
	Aadd(aSaiExt,{STR0021,0,0,0,0}) // Energia Elétrica
	Aadd(aSaiExt,{STR0022,0,0,0,0}) // Comunicações
	Aadd(aSaiExt,{STR0023,0,0,0,0}) // Transportes
	Aadd(aSaiExt,{STR0024,0,0,0,0}) // Outras
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exclusoes - aExclu              ³
	//³1 = Titulo da Linha             ³
	//³2 = Base de Calculo nas Entradas³
	//³3 = Base de Calculo nas Saidas  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aExclu,{STR0059,0,0}) //"Parcela do ICMS retido por Subst. Tributária: "
	Aadd(aExclu,{STR0060,0,0}) //"Parcela do IPI que não integre a base de cálculo do ICMS: "	
	Aadd(aExclu,{STR0039,0,0}) //"Energia Elétrica/Comunicação: "
	Aadd(aExclu,{STR0040,0,0}) //"Transportes (parcela não utilizada): "
	Aadd(aExclu,{STR0042,0,0}) //"Subcontratação de Serv. Transporte: "
	Aadd(aExclu,{STR0061,0,0}) //"Transportes iniciados em outra UF/Transp. Municipal: "	
	Aadd(aExclu,{STR0034,0,0}) //"Entrega Futura (Simples Faturamento): "
	Aadd(aExclu,{STR0035,0,0}) //"Ativo Imobilizado: "
	Aadd(aExclu,{STR0036,0,0}) //"Material de Uso e Consumo: "
	Aadd(aExclu,{STR0037,0,0}) //"Mercadoria com Suspensão de ICMS: "
	Aadd(aExclu,{STR0038,0,0}) //"Simples Remessa (por conta e ordem de Terceiro): "
	Aadd(aExclu,{STR0043,0,0}) //"Remessa/Retorno de Armazenamento/Depósito: "
	Aadd(aExclu,{STR0103,0,0}) //"Remessa/Retorno de consignação: "	
	Aadd(aExclu,{STR0024,0,0}) //"Outras: "
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³** Entradas por Estado - aEntrUF    ³
	//³1 = Sigla do Estado                 ³
	//³2 = Descrição do Estado             ³
	//³3 = Valor Contábil                  ³
	//³4 = Base de Cálculo                 ³
	//³5 = Outras Entradas                 ³
	//³6 = ST Petróleo                     ³
	//³7 = ST Outros                       ³
	//³** Saidas por Estado - aSaiUF       ³
	//³1 = Sigla do Estado                 ³
	//³2 = Descrição do Estado             ³
	//³3 = Valor Contábil Contribuinte     ³
	//³4 = Valor Contábil Nao Contribuinte ³
	//³5 = Base de Calculo Contribuinte    ³
	//³6 = Base de Calculo Nao Contribuinte³
	//³7 = Outras Saidas                   ³
	//³8 = Subst. Tributária               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 To Len(aUF)
		Aadd(aEntrUF,{aUF[nx][01],aUF[nx][02],0,0,0,0,0})
		Aadd(aSaiUF,{aUF[nx][01],aUF[nx][02],0,0,0,0,0,0})		
	Next

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Estoque - aEstoque ³
	//³1 = Cod. Identifica³
	//³2 = Título         ³
	//³3 = Estoque Inicial³
	//³4 = Estoque Final  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aEstoque,{"T",STR0064,0,0}) //"Tributados: "	
	Aadd(aEstoque,{"S",STR0065,0,0}) //"Sujeitos a Subst. Tributária: "
	Aadd(aEstoque,{"I",STR0066,0,0}) //"Isentos: "
	Aadd(aEstoque,{"O",STR0067,0,0}) //"Outros: "

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleciona Movimentacao     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SF3")
	dbSetOrder(1)               
	ProcRegua(LastRec())

	#IFDEF TOP
		If TcSrvType()<>"AS/400"

			lQuery		:= .T.
			cAliasSF3	:= GetNextAlias()

			BeginSql Alias cAliasSF3

				COLUMN F3_ENTRADA AS DATE

				SELECT SF3.F3_FILIAL,SF3.F3_ENTRADA,SF3.F3_NFISCAL,SF3.F3_SERIE,SF3.F3_CLIEFOR,SF3.F3_LOJA,
					SF3.F3_ESTADO,SF3.F3_CFO,SF3.F3_TIPO,SF3.F3_VALCONT,SF3.F3_BASEICM,SF3.F3_OUTRICM,SF3.F3_ISENICM,
					SF3.F3_ICMSRET,SF3.F3_VALICM

				FROM %table:SF3% SF3

				WHERE SF3.F3_FILIAL = %xFilial:SF3% AND
					SF3.F3_ENTRADA >= %Exp:cDataIni% AND
					SF3.F3_ENTRADA <= %Exp:cDataFin% AND
					SF3.F3_DTCANC = %Exp:Dtos(Ctod(''))% AND
					SF3.F3_TIPO <> 'S' AND
					SF3.%NotDel%

				ORDER BY %Order:SF3%

			EndSql

			dbSelectArea(cAliasSF3)
		Else
	#ENDIF
			cIndex    := CriaTrab(NIL,.F.)
			cCondicao := 'F3_FILIAL == "' + xFilial("SF3") + '" .And. '
			cCondicao += 'DTOS(F3_ENTRADA) >= "' + cDataIni + '" .And. '
			cCondicao += 'DTOS(F3_ENTRADA) <= "' + cDataFin + '" .And. '
			cCondicao += 'Empty(F3_DTCANC) .And. '
			cCondicao += 'F3_TIPO <> "S" '
			IndRegua(cAliasSF3,cIndex,SF3->(IndexKey()),,cCondicao)
			dbSelectArea(cAliasSF3)
			ProcRegua(LastRec())
			dbGoTop()
	#IFDEF TOP
		Endif
	#ENDIF

	SA1->(dbSetOrder(1))
	SA2->(dbSetOrder(1))

	While !(cAliasSF3)->(Eof())
		
		IncProc(STR0069) // "Preparando Base 1/5 - Processando movimentações de Entrada/Saída"
		If Interrupcao(@lEnd)
		    Exit
	 	Endif
		          
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica Cliente/Fornecedor³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Left(AllTrim((cAliasSF3)->F3_CFO),1) >= "5"
			If (cAliasSF3)->F3_TIPO$"DB"
				If ! SA2->(dbSeek(xFilial("SA2")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
					(cAliasSF3)->(dbSkip())
					Loop
				Endif
				cMunic		:= SA2->&(cMunA2)
				cInscr		:= SA2->A2_INSCR
				cTipo		:= SA2->A2_TIPO  
				cDescMun	:= SA2->A2_MUN
			Else
				If ! SA1->(dbSeek(xFilial("SA1")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
					(cAliasSF3)->(dbSkip())
					Loop				
				Endif
				cMunic 		:= SA1->&(cMunA1)
				cInscr		:= SA1->A1_INSCR
				cTipo		:= SA1->A1_TIPO
				cDescMun	:= SA1->A1_MUN
			Endif                 
		Else
			If (cAliasSF3)->F3_TIPO$"DB"
				If ! SA1->(dbSeek(xFilial("SA1")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
					(cAliasSF3)->(dbSkip())
					Loop				
				Endif
				cMunic	 	:= SA1->&(cMunA1)
				cInscr		:= SA1->A1_INSCR
				cTipo		:= SA1->A1_TIPO
				cDescMun	:= SA1->A1_MUN
			Else
				If ! SA2->(dbSeek(xFilial("SA2")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
					(cAliasSF3)->(dbSkip())
					Loop
				Endif
				cMunic 		:= SA2->&(cMunA2)
				cInscr		:= SA2->A2_INSCR
				cTipo  		:= SA2->A2_TIPO
				cDescMun	:= SA2->A2_MUN
			Endif                 
		Endif      

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Entradas do Estado³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		// "Compras: "
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[02][01]
			aEntrEst[01][02] += (cAliasSF3)->F3_VALCONT
			aEntrEst[01][03] += (cAliasSF3)->F3_BASEICM
			aEntrEst[01][04] += (cAliasSF3)->F3_VALICM
			aEntrEst[01][05] += (cAliasSF3)->F3_VALCONT - (cAliasSF3)->F3_BASEICM
		Endif
		//"Transferências: "                  
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[02][02]
			aEntrEst[02][02] += (cAliasSF3)->F3_VALCONT
			aEntrEst[02][03] += (cAliasSF3)->F3_BASEICM
			aEntrEst[02][04] += (cAliasSF3)->F3_VALICM
			aEntrEst[02][05] += (cAliasSF3)->F3_VALCONT - (cAliasSF3)->F3_BASEICM
		Endif
		//"Devoluções: "                      
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[02][03]
			aEntrEst[03][02] += (cAliasSF3)->F3_VALCONT
			aEntrEst[03][03] += (cAliasSF3)->F3_BASEICM
			aEntrEst[03][04] += (cAliasSF3)->F3_VALICM
			aEntrEst[03][05] += (cAliasSF3)->F3_VALCONT - (cAliasSF3)->F3_BASEICM
		Endif
		//"Energia Elétrica: "               
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[02][04]
			aEntrEst[04][02] += (cAliasSF3)->F3_VALCONT
			aEntrEst[04][03] += (cAliasSF3)->F3_BASEICM
			aEntrEst[04][04] += (cAliasSF3)->F3_VALICM
			aEntrEst[04][05] += (cAliasSF3)->F3_VALCONT - (cAliasSF3)->F3_BASEICM
		Endif
		//"Comunicações : "                   
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[02][05]
			aEntrEst[05][02] += (cAliasSF3)->F3_VALCONT
			aEntrEst[05][03] += (cAliasSF3)->F3_BASEICM
			aEntrEst[05][04] += (cAliasSF3)->F3_VALICM
			aEntrEst[05][05] += (cAliasSF3)->F3_VALCONT - (cAliasSF3)->F3_BASEICM
		Endif
		//"Transportes: "                     
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[02][06]
			aEntrEst[06][02] += (cAliasSF3)->F3_VALCONT
			aEntrEst[06][03] += (cAliasSF3)->F3_BASEICM
			aEntrEst[06][04] += (cAliasSF3)->F3_VALICM
			aEntrEst[06][05] += (cAliasSF3)->F3_VALCONT - (cAliasSF3)->F3_BASEICM
		Endif
		//"Outras: "                          
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[02][07]
			aEntrEst[07][02] += (cAliasSF3)->F3_VALCONT
			aEntrEst[07][03] += (cAliasSF3)->F3_BASEICM
			aEntrEst[07][04] += (cAliasSF3)->F3_VALICM
			aEntrEst[07][05] += (cAliasSF3)->F3_VALCONT - (cAliasSF3)->F3_BASEICM
                
   			// Os valores lancados na coluna "Outras" devem ser totalizados por municipio Mineiro
			If (cAliasSF3)->F3_ESTADO == "MG"
				nPos := aScan(aEntrMun,{|x| x[1]==cMunic})
				If Left(Alltrim(aWizard[01,04]),1) == "1" //Transportadoras
					nOutEntr	:= (cAliasSF3)->F3_VALCONT * 80 / 100
					nCredPres	:= (cAliasSF3)->F3_VALCONT * 20 / 100
					If nPos == 0                            
						Aadd(aEntrMun,{cMunic,AllTrim(cDescMun),nOutEntr,nCredPres})                          
					Else
						aEntrMun[nPos][03] += nOutEntr
						aEntrMun[nPos][04] += nCredPres
					Endif
				Else
					If nPos == 0                            
						Aadd(aEntrMun,{cMunic,AllTrim(cDescMun),(cAliasSF3)->F3_VALCONT})
			   		Else
						aEntrMun[nPos][03] += (cAliasSF3)->F3_VALCONT
					Endif
				Endif
			Endif
		Endif
		//"Aquisição de Produtos Agropecuários: "
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[02][08]
			aEntrEst[08][02] += (cAliasSF3)->F3_VALCONT
			aEntrEst[08][03] += (cAliasSF3)->F3_BASEICM
			aEntrEst[08][04] += (cAliasSF3)->F3_VALICM
			aEntrEst[08][05] += (cAliasSF3)->F3_VALCONT - (cAliasSF3)->F3_BASEICM
		Endif
		//"Transporte Tomado: "
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[05][08]
			aSaiEst[08][02] += (cAliasSF3)->F3_VALCONT
			aSaiEst[08][03] += (cAliasSF3)->F3_BASEICM
			aSaiEst[08][04] += (cAliasSF3)->F3_VALICM
			aSaiEst[08][05] += (cAliasSF3)->F3_VALCONT - (cAliasSF3)->F3_BASEICM
		Endif
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Entradas de outros Estados ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		// "Compras: "
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[03][01]
			aEntrOut[01][02] += (cAliasSF3)->F3_VALCONT
			aEntrOut[01][03] += (cAliasSF3)->F3_BASEICM
			aEntrOut[01][04] += (cAliasSF3)->F3_VALICM
			aEntrOut[01][05] += (cAliasSF3)->F3_VALCONT - (cAliasSF3)->F3_BASEICM
		Endif
		//"Transferências: "                  
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[03][02]
			aEntrOut[02][02] += (cAliasSF3)->F3_VALCONT
			aEntrOut[02][03] += (cAliasSF3)->F3_BASEICM
			aEntrOut[02][04] += (cAliasSF3)->F3_VALICM
			aEntrOut[02][05] += (cAliasSF3)->F3_VALCONT - (cAliasSF3)->F3_BASEICM
		Endif
		//"Devoluções: "                      
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[03][03]
			aEntrOut[03][02] += (cAliasSF3)->F3_VALCONT
			aEntrOut[03][03] += (cAliasSF3)->F3_BASEICM
			aEntrOut[03][04] += (cAliasSF3)->F3_VALICM
			aEntrOut[03][05] += (cAliasSF3)->F3_VALCONT - (cAliasSF3)->F3_BASEICM
		Endif
		//"Energia Elétrica: "               
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[03][04]
			aEntrOut[04][02] += (cAliasSF3)->F3_VALCONT
			aEntrOut[04][03] += (cAliasSF3)->F3_BASEICM
			aEntrOut[04][04] += (cAliasSF3)->F3_VALICM
			aEntrOut[04][05] += (cAliasSF3)->F3_VALCONT - (cAliasSF3)->F3_BASEICM
		Endif
		//"Comunicações : "                   
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[03][05]
			aEntrOut[05][02] += (cAliasSF3)->F3_VALCONT
			aEntrOut[05][03] += (cAliasSF3)->F3_BASEICM
			aEntrOut[05][04] += (cAliasSF3)->F3_VALICM
			aEntrOut[05][05] += (cAliasSF3)->F3_VALCONT - (cAliasSF3)->F3_BASEICM
		Endif
		//"Transportes: "                     
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[03][06]
			aEntrOut[06][02] += (cAliasSF3)->F3_VALCONT
			aEntrOut[06][03] += (cAliasSF3)->F3_BASEICM
			aEntrOut[06][04] += (cAliasSF3)->F3_VALICM
			aEntrOut[06][05] += (cAliasSF3)->F3_VALCONT - (cAliasSF3)->F3_BASEICM
		Endif
		//"Outras: "                          
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[03][07]
			aEntrOut[07][02] += (cAliasSF3)->F3_VALCONT
			aEntrOut[07][03] += (cAliasSF3)->F3_BASEICM
			aEntrOut[07][04] += (cAliasSF3)->F3_VALICM
			aEntrOut[07][05] += (cAliasSF3)->F3_VALCONT - (cAliasSF3)->F3_BASEICM
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Entradas do Exterior       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		// "Compras: "
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[04][01]
			aEntrExt[01][02] += (cAliasSF3)->F3_VALCONT
			aEntrExt[01][03] += (cAliasSF3)->F3_BASEICM
			aEntrExt[01][04] += (cAliasSF3)->F3_VALICM
			aEntrExt[01][05] += (cAliasSF3)->F3_VALCONT - (cAliasSF3)->F3_BASEICM
		Endif
		//"Devoluções: "                      
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[04][02]
			aEntrExt[02][02] += (cAliasSF3)->F3_VALCONT
			aEntrExt[02][03] += (cAliasSF3)->F3_BASEICM
			aEntrExt[02][04] += (cAliasSF3)->F3_VALICM
			aEntrExt[02][05] += (cAliasSF3)->F3_VALCONT - (cAliasSF3)->F3_BASEICM
		Endif
		//"Energia Elétrica: "               
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[04][03]
			aEntrExt[03][02] += (cAliasSF3)->F3_VALCONT
			aEntrExt[03][03] += (cAliasSF3)->F3_BASEICM
			aEntrExt[03][04] += (cAliasSF3)->F3_VALICM
			aEntrExt[03][05] += (cAliasSF3)->F3_VALCONT - (cAliasSF3)->F3_BASEICM
		Endif
		//"Comunicações : "                   
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[04][04]
			aEntrExt[04][02] += (cAliasSF3)->F3_VALCONT
			aEntrExt[04][03] += (cAliasSF3)->F3_BASEICM
			aEntrExt[04][04] += (cAliasSF3)->F3_VALICM
			aEntrExt[04][05] += (cAliasSF3)->F3_VALCONT - (cAliasSF3)->F3_BASEICM
		Endif
		//"Transportes: "                     
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[04][05]
			aEntrExt[05][02] += (cAliasSF3)->F3_VALCONT
			aEntrExt[05][03] += (cAliasSF3)->F3_BASEICM
			aEntrExt[05][04] += (cAliasSF3)->F3_VALICM
			aEntrExt[05][05] += (cAliasSF3)->F3_VALCONT - (cAliasSF3)->F3_BASEICM
		Endif
		//"Outras: "                          
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[04][06]
			aEntrExt[06][02] += (cAliasSF3)->F3_VALCONT
			aEntrExt[06][03] += (cAliasSF3)->F3_BASEICM
			aEntrExt[06][04] += (cAliasSF3)->F3_VALICM
			aEntrExt[06][05] += (cAliasSF3)->F3_VALCONT - (cAliasSF3)->F3_BASEICM
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Saidas para o Estado³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		// "Vendas: "
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[05][01]
			aSaiEst[01][02] += (cAliasSF3)->F3_VALCONT
			aSaiEst[01][03] += (cAliasSF3)->F3_BASEICM
			aSaiEst[01][04] += (cAliasSF3)->F3_VALICM
			aSaiEst[01][05] += (cAliasSF3)->F3_VALCONT - (cAliasSF3)->F3_BASEICM
		Endif
		//"Transferências: "                  
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[05][02]
			aSaiEst[02][02] += (cAliasSF3)->F3_VALCONT
			aSaiEst[02][03] += (cAliasSF3)->F3_BASEICM
			aSaiEst[02][04] += (cAliasSF3)->F3_VALICM
			aSaiEst[02][05] += (cAliasSF3)->F3_VALCONT - (cAliasSF3)->F3_BASEICM
		Endif
		//"Devoluções: "                      
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[05][03]
			aSaiEst[03][02] += (cAliasSF3)->F3_VALCONT
			aSaiEst[03][03] += (cAliasSF3)->F3_BASEICM
			aSaiEst[03][04] += (cAliasSF3)->F3_VALICM
			aSaiEst[03][05] += (cAliasSF3)->F3_VALCONT - (cAliasSF3)->F3_BASEICM
		Endif
		//"Energia Elétrica: "               
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[05][04]
			aSaiEst[04][02] += (cAliasSF3)->F3_VALCONT
			aSaiEst[04][03] += (cAliasSF3)->F3_BASEICM
			aSaiEst[04][04] += (cAliasSF3)->F3_VALICM
			aSaiEst[04][05] += (cAliasSF3)->F3_VALCONT - (cAliasSF3)->F3_BASEICM
		Endif
		//"Comunicações : "                   
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[05][05]
			aSaiEst[05][02] += (cAliasSF3)->F3_VALCONT
			aSaiEst[05][03] += (cAliasSF3)->F3_BASEICM
			aSaiEst[05][04] += (cAliasSF3)->F3_VALICM
			aSaiEst[05][05] += (cAliasSF3)->F3_VALCONT - (cAliasSF3)->F3_BASEICM
		Endif
		//"Transportes: "                     
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[05][06]
			aSaiEst[06][02] += (cAliasSF3)->F3_VALCONT
			aSaiEst[06][03] += (cAliasSF3)->F3_BASEICM
			aSaiEst[06][04] += (cAliasSF3)->F3_VALICM
			aSaiEst[06][05] += (cAliasSF3)->F3_VALCONT - (cAliasSF3)->F3_BASEICM
		Endif
		//"Outras: "                          
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[05][07]
			aSaiEst[07][02] += (cAliasSF3)->F3_VALCONT
			aSaiEst[07][03] += (cAliasSF3)->F3_BASEICM
			aSaiEst[07][04] += (cAliasSF3)->F3_VALICM
			aSaiEst[07][05] += (cAliasSF3)->F3_VALCONT - (cAliasSF3)->F3_BASEICM
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Saidas para outros Estados³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		// "Vendas: "
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[06][01]
			ASaiOut[01][02] += (cAliasSF3)->F3_VALCONT
			ASaiOut[01][03] += (cAliasSF3)->F3_BASEICM
			ASaiOut[01][04] += (cAliasSF3)->F3_VALICM
			ASaiOut[01][05] += (cAliasSF3)->F3_VALCONT - (cAliasSF3)->F3_BASEICM
		Endif
		//"Transferências: "                  
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[06][02]
			ASaiOut[02][02] += (cAliasSF3)->F3_VALCONT
			ASaiOut[02][03] += (cAliasSF3)->F3_BASEICM
			ASaiOut[02][04] += (cAliasSF3)->F3_VALICM
			ASaiOut[02][05] += (cAliasSF3)->F3_VALCONT - (cAliasSF3)->F3_BASEICM
		Endif
		//"Devoluções: "                      
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[06][03]
			ASaiOut[03][02] += (cAliasSF3)->F3_VALCONT
			ASaiOut[03][03] += (cAliasSF3)->F3_BASEICM
			ASaiOut[03][04] += (cAliasSF3)->F3_VALICM
			ASaiOut[03][05] += (cAliasSF3)->F3_VALCONT - (cAliasSF3)->F3_BASEICM
		Endif
		//"Energia Elétrica: "               
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[06][04]
			ASaiOut[04][02] += (cAliasSF3)->F3_VALCONT
			ASaiOut[04][03] += (cAliasSF3)->F3_BASEICM
			ASaiOut[04][04] += (cAliasSF3)->F3_VALICM
			ASaiOut[04][05] += (cAliasSF3)->F3_VALCONT - (cAliasSF3)->F3_BASEICM
		Endif
		//"Comunicações : "                   
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[06][05]
			ASaiOut[05][02] += (cAliasSF3)->F3_VALCONT
			ASaiOut[05][03] += (cAliasSF3)->F3_BASEICM
			ASaiOut[05][04] += (cAliasSF3)->F3_VALICM
			ASaiOut[05][05] += (cAliasSF3)->F3_VALCONT - (cAliasSF3)->F3_BASEICM
		Endif
		//"Transportes: "                     
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[06][06]
			ASaiOut[06][02] += (cAliasSF3)->F3_VALCONT
			ASaiOut[06][03] += (cAliasSF3)->F3_BASEICM
			ASaiOut[06][04] += (cAliasSF3)->F3_VALICM
			ASaiOut[06][05] += (cAliasSF3)->F3_VALCONT - (cAliasSF3)->F3_BASEICM
		Endif
		//"Outras: "                          
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[06][07]
			ASaiOut[07][02] += (cAliasSF3)->F3_VALCONT
			ASaiOut[07][03] += (cAliasSF3)->F3_BASEICM
			ASaiOut[07][04] += (cAliasSF3)->F3_VALICM
			ASaiOut[07][05] += (cAliasSF3)->F3_VALCONT - (cAliasSF3)->F3_BASEICM
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Saidas para o Exterior    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		// "Vendas: "
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[07][01]
			aSaiExt[01][02] += (cAliasSF3)->F3_VALCONT
			aSaiExt[01][03] += (cAliasSF3)->F3_BASEICM
			aSaiExt[01][04] += (cAliasSF3)->F3_VALICM
			aSaiExt[01][05] += (cAliasSF3)->F3_VALCONT - (cAliasSF3)->F3_BASEICM
		Endif
		//"Devoluções: "                      
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[07][02]
			aSaiExt[02][02] += (cAliasSF3)->F3_VALCONT
			aSaiExt[02][03] += (cAliasSF3)->F3_BASEICM
			aSaiExt[02][04] += (cAliasSF3)->F3_VALICM
			aSaiExt[02][05] += (cAliasSF3)->F3_VALCONT - (cAliasSF3)->F3_BASEICM
		Endif
		//"Energia Elétrica: "               
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[07][03]
			aSaiExt[03][02] += (cAliasSF3)->F3_VALCONT
			aSaiExt[03][03] += (cAliasSF3)->F3_BASEICM
			aSaiExt[03][04] += (cAliasSF3)->F3_VALICM
			aSaiExt[03][05] += (cAliasSF3)->F3_VALCONT - (cAliasSF3)->F3_BASEICM
		Endif
		//"Comunicações : "                   
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[07][04]
			aSaiExt[04][02] += (cAliasSF3)->F3_VALCONT
			aSaiExt[04][03] += (cAliasSF3)->F3_BASEICM
			aSaiExt[04][04] += (cAliasSF3)->F3_VALICM
			aSaiExt[04][05] += (cAliasSF3)->F3_VALCONT - (cAliasSF3)->F3_BASEICM
		Endif
		//"Transportes: "                     
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[07][05]
			aSaiExt[05][02] += (cAliasSF3)->F3_VALCONT
			aSaiExt[05][03] += (cAliasSF3)->F3_BASEICM
			aSaiExt[05][04] += (cAliasSF3)->F3_VALICM
			aSaiExt[05][05] += (cAliasSF3)->F3_VALCONT - (cAliasSF3)->F3_BASEICM
		Endif
		//"Outras: "                          
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[07][06]
			aSaiExt[06][02] += (cAliasSF3)->F3_VALCONT
			aSaiExt[06][03] += (cAliasSF3)->F3_BASEICM
			aSaiExt[06][04] += (cAliasSF3)->F3_VALICM
			aSaiExt[06][05] += (cAliasSF3)->F3_VALCONT - (cAliasSF3)->F3_BASEICM
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Exclusões nas Entradas³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//"Parcela do ICMS retido por Subst. Tributária: "
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[08][01]
			aExclu[01][02] += (cAliasSF3)->F3_ICMSRET
		Endif                              
		//"Entrega Futura (Simples Faturamento): "
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[08][02]
			aExclu[07][02] += (cAliasSF3)->F3_VALCONT
		Endif       
		//"Ativo Imobilizado: "
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[08][04]
			aExclu[08][02] += (cAliasSF3)->F3_VALCONT
		Endif
		//"Material de Uso e Consumo: "
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[08][05]
			aExclu[09][02] += (cAliasSF3)->F3_VALCONT
		Endif
		//"Simples Remessa (por conta e ordem de Terceiro): "
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[08][06]
			aExclu[11][02] += (cAliasSF3)->F3_VALCONT
		Endif
		//"Energia Elétrica/Comunicação: "
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[08][07]
			aExclu[03][02] += (cAliasSF3)->F3_VALCONT
		Endif
		//"Transportes (parcela não utilizada): "
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[08][08]
			aExclu[04][02] += (cAliasSF3)->F3_VALCONT
		Endif
		//"Remessa/Retorno/Consignação/Depósito: "
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[08][09]
			aExclu[12][02] += (cAliasSF3)->F3_VALCONT
		Endif
		//"Outras: "
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[08][11]
			aExclu[14][02] += (cAliasSF3)->F3_VALCONT
		Endif
		//"Remessa/Retorno de consignação:"
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[08][10]
			aExclu[13][02] += (cAliasSF3)->F3_VALCONT
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Exclusões nas Entradas³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//"Parcela do ICMS retido por Subst. Tributária: "
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[09][01]
			aExclu[01][02] += (cAliasSF3)->F3_ICMSRET
		Endif                              
		//"Entrega Futura (Simples Faturamento): "
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[09][02]
			aExclu[07][02] += (cAliasSF3)->F3_VALCONT
		Endif       
		//"Ativo Imobilizado: "
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[09][04]
			aExclu[08][02] += (cAliasSF3)->F3_VALCONT
		Endif
		//"Material de Uso e Consumo: "
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[09][05]
			aExclu[09][02] += (cAliasSF3)->F3_VALCONT
		Endif
		//"Simples Remessa (por conta e ordem de Terceiro): "
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[09][06]
			aExclu[11][02] += (cAliasSF3)->F3_VALCONT
		Endif
		//"Energia Elétrica/Comunicação: "
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[09][07]
			aExclu[03][02] += (cAliasSF3)->F3_VALCONT
		Endif
		//"Transportes (parcela não utilizada): "
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[09][08]
			aExclu[04][02] += (cAliasSF3)->F3_VALCONT
		Endif
		//"Remessa/Retorno/Consignação/Depósito: "
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[09][09]
			aExclu[12][02] += (cAliasSF3)->F3_VALCONT
		Endif
		//"Outras: "
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[09][11]
			aExclu[14][02] += (cAliasSF3)->F3_VALCONT
		Endif
		//"Remessa/Retorno de consignação:"
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[09][10]
			aExclu[13][02] += (cAliasSF3)->F3_VALCONT
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Exclusões nas Saidas  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//"Parcela do ICMS retido por Subst. Tributária: "
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[10][01]
			aExclu[01][03] += (cAliasSF3)->F3_ICMSRET
		Endif                              
		//"Entrega Futura (Simples Faturamento): "
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[10][02]
			aExclu[07][03] += (cAliasSF3)->F3_VALCONT
		Endif                             
		//"Ativo Imobilizado: "
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[10][04]
			aExclu[08][03] += (cAliasSF3)->F3_VALCONT
		Endif
		//"Material de Uso e Consumo: "
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[10][05]
			aExclu[09][03] += (cAliasSF3)->F3_VALCONT
		Endif
		//"Simples Remessa (por conta e ordem de Terceiro): "
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[10][06]
			aExclu[11][03] += (cAliasSF3)->F3_VALCONT
		Endif
		//"Remessa/Retorno/Consignação/Depósito: "
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[10][07]
			aExclu[12][03] += (cAliasSF3)->F3_VALCONT
		Endif
		//"Outras: "
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[10][09]
			aExclu[14][03] += (cAliasSF3)->F3_VALCONT
		Endif                                            
		//"Remessa/Retorno de consignação:"
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[10][08]
			aExclu[13][03] += (cAliasSF3)->F3_VALCONT
		Endif
		//"Transportes iniciados em outro Pais/UF/Municipio:"
		If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[10][10]
			//aIniFre[1] = UF
			//aIniFre[2] = Minicipio
			aIniFre := IniFrete(cAliasSF3)
			If aIniFre[1] <> cMVESTADO //Interestadual  		
				aExclu[06][03] += (cAliasSF3)->F3_VALCONT
			ElseIf aIniFre[2] <> cMunSM0 //Intermunicipal
				aExclu[06][03] += (cAliasSF3)->F3_VALCONT
			Endif	
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Entradas Interestaduais - Total por UF³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Left(AllTrim((cAliasSF3)->F3_CFO),1) == "2"
			nPos := aScan(aEntrUF,{|x| x[1]==(cAliasSF3)->F3_ESTADO})
			If nPos > 0
				aEntrUF[nPos][03] += (cAliasSF3)->F3_VALCONT
				aEntrUF[nPos][04] += (cAliasSF3)->F3_BASEICM
				aEntrUF[nPos][05] += (cAliasSF3)->F3_ISENICM + (cAliasSF3)->F3_OUTRICM						
				If (cAliasSF3)->F3_ICMSRET > 0
					If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[11][01]
						aEntrUF[nPos][06] += (cAliasSF3)->F3_ICMSRET
					Endif
					If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[11][02]
						aEntrUF[nPos][07] += (cAliasSF3)->F3_ICMSRET
					Endif
				Endif
			Endif
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Saidas Interestaduais - Total por UF  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Left(AllTrim((cAliasSF3)->F3_CFO),1) == "6"
			nPos := aScan(aSaiUF,{|x| x[1]==(cAliasSF3)->F3_ESTADO})
			// Valores para não Contribuintes
			If nPos > 0
				If (AllTrim((cAliasSF3)->F3_CFO) $ aWizard[11][03]) .Or.;
					"ISENT" $Upper(cInscr) .Or. ;
					(Empty(cInscr) .And. cTipo != "L")
					aSaiUF[nPos][04] += (cAliasSF3)->F3_VALCONT
					aSaiUF[nPos][06] += (cAliasSF3)->F3_BASEICM
				Else
					aSaiUF[nPos][03] += (cAliasSF3)->F3_VALCONT
					aSaiUF[nPos][05] += (cAliasSF3)->F3_BASEICM
				Endif
				aSaiUF[nPos][07] += (cAliasSF3)->F3_ISENICM + (cAliasSF3)->F3_OUTRICM						
				aSaiUF[nPos][08] += (cAliasSF3)->F3_ICMSRET
			Endif
		Endif
			
		(cAliasSF3)->(dbSkip())
	Enddo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exclui area de trabalho utilizada - SF3³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lQuery
		RetIndex("SF3")	
		dbClearFilter()	
		Ferase(cIndex+OrdBagExt())
	Else
		dbSelectArea(cAliasSF3)
		dbCloseArea()
	Endif		

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processando as movimentacoes de entrada - IPI³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SD1")
	dbSetOrder(1)               
	ProcRegua(LastRec())
	
	cProcCFOP 	:= Alltrim(aWizard[08][03])+"/"+Alltrim(aWizard[09][03])

	#IFDEF TOP    
	    If TcSrvType()<>"AS/400"
	    
			lQuery		:= .T.
			cAliasSD1	:= GetNextAlias()
			cAliasSF4	:= cAliasSD1
			                       
			cQuery 		:= "%"
			cQuery 		+= "SD1.D1_CF IN " + FormatIn(cProcCFOP,cSep) + " "
			cQuery 		+= "%"
			                       
			BeginSql Alias cAliasSD1

  				SELECT SUM(SD1.D1_VALIPI) D1_VALIPI

				FROM %table:SD1% SD1, %table:SF4% SF4
  				
				WHERE SD1.D1_FILIAL = %xFilial:SD1% AND
					SD1.D1_DTDIGIT >= %Exp:cDataIni% AND 
					SD1.D1_DTDIGIT <= %Exp:cDataFin% AND 
					SD1.D1_VALIPI > 0 AND
					%Exp:cQuery% AND
  					SD1.%NotDel% AND
  					SF4.F4_FILIAL = %xFilial:SF4% AND
  					SF4.F4_CODIGO = SD1.D1_TES AND
  					SF4.F4_INCIDE <> 'S'
  					
  				ORDER BY D1_VALIPI

			EndSql
			
			dbSelectArea(cAliasSD1)	
		Else
	#ENDIF
		    cIndex    := CriaTrab(NIL,.F.)
			cCondicao := 'D1_FILIAL == "' + xFilial("SD1") + '" .And. '
			cCondicao += 'DTOS(D1_DTDIGIT) >= "' + cDataIni + '" .And. '
			cCondicao += 'DTOS(D1_DTDIGIT) <= "' + cDataFin + '" .And. '
			cCondicao += 'D1_VALIPI > 0 .And. '
			cCondicao += 'ALLTRIM(D1_CF) $ "' + cProcCFOP + '"'
	
		    IndRegua(cAliasSD1,cIndex,SD1->(IndexKey()),,cCondicao)
		    dbSelectArea(cAliasSD1)
		    ProcRegua(LastRec())
		    dbGoTop()
	#IFDEF TOP
		Endif    
	#ENDIF
	
	Do While !((cAliasSD1)->(Eof()))
	
		IncProc(STR0068) // "Preparando Base 2/5 - Processando movimentação de IPI"
		If Interrupcao(@lEnd)
		    Exit
	 	Endif
		
		If ! lQuery    
			If !(cAliasSF4)->(dbSeek(xFilial("SF4")+(cAliasSD1)->D1_TES))
				(cAliasSD1)->(dbSkip())
				Loop			
			Endif
			cIncide := (cAliasSF4)->F4_INCIDE
		Else
			cIncide := ""
		Endif		
			
		
		If cIncide <> "S"
			aExclu[02][02] += (cAliasSD1)->D1_VALIPI			
		Endif
		
		(cAliasSD1)->(dbSkip())
	Enddo                                        
				                 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exclui area de trabalho utilizada - SD1³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lQuery
		RetIndex("SD1")	
		dbClearFilter()	
		Ferase(cIndex+OrdBagExt())
	Else
		dbSelectArea(cAliasSD1)
		dbCloseArea()
	Endif		

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processando as movimentacoes de saída - IPI  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SD2")
	dbSetOrder(1)               
	ProcRegua(LastRec())

	cProcCFOP 	:= Alltrim(aWizard[10][03])

	#IFDEF TOP    
	    If TcSrvType()<>"AS/400"

			lQuery		:= .T.
			cAliasSD2	:= GetNextAlias()
			cAliasSF4	:= cAliasSD2

			cQuery 		:= "%"
			cQuery 		+= "SD2.D2_CF IN " + FormatIn(cProcCFOP,cSep) + " "
			cQuery 		+= "%"
			                        
			BeginSql Alias cAliasSD2

  				SELECT SUM(SD2.D2_VALIPI) D2_VALIPI

				FROM %table:SD2% SD2, %table:SF4% SF4
  				
				WHERE SD2.D2_FILIAL = %xFilial:SD2% AND
					SD2.D2_EMISSAO >= %Exp:cDataIni% AND 
					SD2.D2_EMISSAO <= %Exp:cDataFin% AND 
					SD2.D2_VALIPI > 0 AND
					%Exp:cQuery% AND
  					SD2.%NotDel% AND
  					SF4.F4_FILIAL = %xFilial:SF4% AND
  					SF4.F4_CODIGO = SD2.D2_TES AND
  					SF4.F4_INCIDE <> 'S'
  					
  				ORDER BY D2_VALIPI

			EndSql
			
			dbSelectArea(cAliasSD2)	
		Else
	#ENDIF
		    cIndex    := CriaTrab(NIL,.F.)
			cCondicao := 'D2_FILIAL == "' + xFilial("SD2") + '" .And. '
			cCondicao += 'DTOS(D2_EMISSAO) >= "' + cDataIni + '" .And. '
			cCondicao += 'DTOS(D2_EMISSAO) <= "' + cDataFin + '" .And. '
			cCondicao += 'D2_VALIPI > 0 .And. '
			cCondicao += 'ALLTRIM(D2_CF) $ "' + Alltrim(aWizard[10][03]) + '"'
	
		    IndRegua(cAliasSD2,cIndex,SD2->(IndexKey()),,cCondicao)
		    dbSelectArea(cAliasSD2)
		    ProcRegua(LastRec())
		    dbGoTop()
	#IFDEF TOP
		Endif    
	#ENDIF
	
	Do While !((cAliasSD2)->(Eof()))
	
		IncProc(STR0068) // "Preparando Base 3/5 - Processando entradas com Suspensão de ICMS"
		If Interrupcao(@lEnd)
		    Exit
	 	Endif
		
		If ! lQuery    
			If !(cAliasSF4)->(dbSeek(xFilial("SF4")+(cAliasSD2)->D2_TES))
				(cAliasSD2)->(dbSkip())
				Loop			
			Endif                              
			cIncide := (cAliasSF4)->F4_INCIDE
		Else
			cIncide := ""
		Endif
		
		If  cIncide <> "S"
			aExclu[02][03] += (cAliasSD2)->D2_VALIPI			
		Endif
		
		(cAliasSD2)->(dbSkip())
	Enddo                                        

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exclui area de trabalho utilizada - SD2³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lQuery
		RetIndex("SD2")	
		dbClearFilter()	
		Ferase(cIndex+OrdBagExt())
	Else
		dbSelectArea(cAliasSD2)
		dbCloseArea()
	Endif		

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processando as entradas com suspensao de ICMS atraves da ³
	//³classificacao fiscal (classificacao = 50 - Suspensao)    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SD1")
	dbSetOrder(1)
	ProcRegua(LastRec())

	#IFDEF TOP
		If TcSrvType()<>"AS/400"
			lQuery		:= .T.
			cAliasSD1	:= GetNextAlias()
			cFrom		:= "%"
			cQuery		:= "%"
			If lSBZ
				cFrom	+= "JOIN "+RetSqlName("SBZ")+" SBZ ON "
				cFrom	+= "SBZ.BZ_FILIAL ='" + xFilial("SBZ") + "' AND "
				cFrom	+= "SBZ.BZ_COD = SD1.D1_COD AND "
				cFrom	+= "SBZ.D_E_L_E_T_= '' "
				cQuery	+= "(SUBSTRING(SD1.D1_CLASFIS,2,2) = '50' OR (SBZ.BZ_CLASFIS = '50' AND SD1.D1_CLASFIS = ''))"
			Else
				cFrom	+= "JOIN "+RetSqlName("SB1")+" SB1 ON "
				cFrom	+= "SB1.B1_FILIAL ='" + xFilial("SB1") + "' AND "
				cFrom	+= "SB1.B1_COD = SD1.D1_COD AND "
				cFrom	+= "SB1.D_E_L_E_T_= '' "
				cQuery	+= "(SUBSTRING(SD1.D1_CLASFIS,2,2) = '50' OR (SB1.B1_CLASFIS = '50' AND SD1.D1_CLASFIS = ''))"
			Endif
			If !Empty(aWizard[08][11]) .or. !Empty(aWizard[09][11])
				cIn := FormatIn(AllTrim(aWizard[08][11])+"/"+AllTrim(aWizard[09][11]),cSep)
				if !empty(cIn)
					cQuery	+= "AND SD1.D1_CF not in " + cIn + " "
				endif
			EndIf
			cFrom	+= "%"
			cQuery	+= "%"
			BeginSql Alias cAliasSD1
				SELECT
					%Exp:cFuncNull% (SUM(SD1.D1_TOTAL),0) AS D1_TOTAL
				FROM
					%table:SD1% SD1
					%Exp:cFrom%
				WHERE
					SD1.D1_FILIAL = %xFilial:SD1% AND
					SD1.D1_DTDIGIT >= %Exp:cDataIni% AND
					SD1.D1_DTDIGIT <= %Exp:cDataFin% AND
					SD1.%NotDel% AND
					%Exp:cQuery%
			EndSql
			dbSelectArea(cAliasSD1)
		Else
	#ENDIF
			cIndex    := CriaTrab(NIL,.F.)
			cCondicao := 'D1_FILIAL == "' + xFilial("SD1") + '" .And. '
			cCondicao += 'DTOS(D1_DTDIGIT) >= "' + cDataIni + '" .And. '
			cCondicao += 'DTOS(D1_DTDIGIT) <= "' + cDataFin + '" .And. '
			cCondicao += '(SUBSTR(D1_CLASFIS,2,2) == "50" .Or. EMPTY(D1_CLASFIS))'
			IndRegua(cAliasSD1,cIndex,SD1->(IndexKey()),,cCondicao)
			dbSelectArea(cAliasSD1)
			ProcRegua(LastRec())
			dbGoTop()
	#IFDEF TOP
		Endif
	#ENDIF

	If !lQuery
		Do While !((cAliasSD1)->(Eof()))
	
			IncProc(STR0100) // "Preparando Base 3/5 - Processando movimentação com Suspensão ICMS - Entradas"
			If Interrupcao(@lEnd)
		    	Exit
		 	Endif
		 	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se nao existe a classificacao fiscal no item, pega do cadastro do produto³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			(cAliasPRD)->(dbSetOrder(1))
			If !(cAliasPRD)->(dbSeek(xFilial(cAliasPRD)+(cAliasSD1)->D1_COD))
				(cAliasSD1)->(dbSkip())
			   	Loop
			Endif
			
			If Empty((cAliasSD1)->D1_CLASFIS)
				If !(cAliasPRD)->&cCampoPRD == "50"
					(cAliasSD1)->(dbSkip())
				   	Loop
				Endif
			Endif
				
		 	aExclu[10][02] += (cAliasSD1)->D1_TOTAL
		                                             	
			(cAliasSD1)->(dbSkip())
		Enddo                                        
	Else 
		IncProc(STR0100) // "Preparando Base 3/5 - Processando movimentação com Suspensão ICMS - Entradas"
		aExclu[10][02] += (cAliasSD1)->D1_TOTAL
	Endif
				                 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exclui area de trabalho utilizada - SD1³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lQuery
		RetIndex("SD1")	
		dbClearFilter()	
		Ferase(cIndex+OrdBagExt())
	Else
		dbSelectArea(cAliasSD1)
		dbCloseArea()
	Endif		

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processando as saidas com suspensao de ICMS atraves da   ³
	//³classificacao fiscal (classificacao = 50 - Suspensao)    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SD2")
	dbSetOrder(1)
	ProcRegua(LastRec())

	#IFDEF TOP
		If TcSrvType()<>"AS/400"
			lQuery		:= .T.
			cAliasSD2	:= GetNextAlias()
			cFrom		:= "%"
			cQuery		:= "%"
			If lSBZ
				cFrom	+= "JOIN "+RetSqlName("SBZ")+" SBZ ON "
				cFrom	+= "SBZ.BZ_FILIAL ='" + xFilial("SBZ") + "' AND "
				cFrom	+= "SBZ.BZ_COD = SD2.D2_COD AND "
				cFrom	+= "SBZ.D_E_L_E_T_= '' "
				cQuery	+= "(SUBSTRING(SD2.D2_CLASFIS,2,2) = '50' OR (SBZ.BZ_CLASFIS = '50' AND SD2.D2_CLASFIS = ''))"
			Else
				cFrom	+= "JOIN "+RetSqlName("SB1")+" SB1 ON "
				cFrom	+= "SB1.B1_FILIAL ='" + xFilial("SB1") + "' AND "
				cFrom	+= "SB1.B1_COD = SD2.D2_COD AND "
				cFrom	+= "SB1.D_E_L_E_T_= '' "
				cQuery	+= "(SUBSTRING(SD2.D2_CLASFIS,2,2) = '50' OR (SB1.B1_CLASFIS = '50' AND SD2.D2_CLASFIS = ''))"
			Endif
			If !Empty(aWizard[10][09])
				if At("/", aWizard[10][09]) == 0
					cQuery	+= "AND SD2.D2_CF <> '"+AllTrim(aWizard[10][09])+"'"
				else
					cIn := FormatIn(AllTrim(aWizard[10][09]),cSep)
					if !empty(cIn)
						cQuery	+= "AND SD2.D2_CF not in " + cIn + " "
					endif
				endif
			EndIf			

			cFrom	+= "%"
			cQuery	+= "%"
			BeginSql Alias cAliasSD2
				SELECT
					%Exp:cFuncNull% (SUM(SD2.D2_TOTAL),0) AS D2_TOTAL
				FROM
					%table:SD2% SD2
					%Exp:cFrom%
				WHERE
					SD2.D2_FILIAL = %xFilial:SD2% AND
					SD2.D2_EMISSAO >= %Exp:cDataIni% AND
					SD2.D2_EMISSAO <= %Exp:cDataFin% AND
					SD2.%NotDel% AND
					%Exp:cQuery%
			EndSql
			dbSelectArea(cAliasSD2)
		Else
	#ENDIF
			cIndex    := CriaTrab(NIL,.F.)
			cCondicao := 'D2_FILIAL == "' + xFilial("SD2") + '" .And. '
			cCondicao += 'DTOS(D2_EMISSAO) >= "' + cDataIni + '" .And. '
			cCondicao += 'DTOS(D2_EMISSAO) <= "' + cDataFin + '" .And. '
			cCondicao += '(SUBSTR(D2_CLASFIS,2,2) == "50" .Or. EMPTY(D2_CLASFIS))'
			IndRegua(cAliasSD2,cIndex,SD2->(IndexKey()),,cCondicao)
			dbSelectArea(cAliasSD2)
			ProcRegua(LastRec())
			dbGoTop()
	#IFDEF TOP
		Endif
	#ENDIF

	If !lQuery
		Do While !((cAliasSD2)->(Eof()))
	
			IncProc(STR0101) // "Preparando Base 3/5 - Processando movimentação com Suspensão ICMS - Saidas"
			If Interrupcao(@lEnd)
		    	Exit
		 	Endif
		 	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se nao existe a classificacao fiscal no item, pega do cadastro do produto³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			(cAliasPRD)->(dbSetOrder(1))
			If !(cAliasPRD)->(dbSeek(xFilial(cAliasPRD)+(cAliasSD2)->D2_COD))
				(cAliasSD1)->(dbSkip())
			   	Loop
			Endif
			
			If Empty((cAliasSD2)->D2_CLASFIS)
				If !(cAliasPRD)->&cCampoPRD == "50"
					(cAliasSD2)->(dbSkip())
				   	Loop
				Endif
			Endif

		 	aExclu[10][03] += (cAliasSD2)->D2_TOTAL
		
			(cAliasSD2)->(dbSkip())
		Enddo                                        
	Else 
		IncProc(STR0101) // "Preparando Base 3/5 - Processando movimentação com Suspensão ICMS - Saidas"
		aExclu[10][03] += (cAliasSD2)->D2_TOTAL
	Endif
				                 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exclui area de trabalho utilizada - SD2³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lQuery
		RetIndex("SD2")	
		dbClearFilter()	
		Ferase(cIndex+OrdBagExt())
	Else
		dbSelectArea(cAliasSD2)
		dbCloseArea()
	Endif		

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿  
	//³Processando os saldos em estoque³  
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Left(Alltrim(aWizard[01][03]),1) == "1"
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Processando o saldo inicial do periodo³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		IF ExistBlock("SPEDALTH")
			 cAliBLH := ExecBlock("SPEDALTH",.F.,.F.,{SToD(cDataIni)-1,''})

			//Verifica se arquivo existe
			IF File(cAliBLH+GetDBExtension())
				
				dbSelectArea(cAliBLH) 
				(cAliBLH)->(dbGoTop())              
			Else
				Alert(STR0111) //"Não foi encontrado arquivo do ponto de entrada SPEDALTH para compor Bloco H"        
			Endif
		Else
			//aEst := {"EST",""}
			//FsEstInv(aEst,1,.T.,.F.,sTod(cDataIni)-1,.F.,.F.,,,,,,,,,,,,,lSBZ)
			SPDBlocH(@cAliBLH,,sTod(cDataIni)-1)
		Endif
			
		if !Empty(cAliBLH) .AND. SELECT(cAliBLH) > 0
			dbSelectArea(cAliBLH)
			(cAliBLH)->(dbGoTop())
			Do While ! (cAliBLH)->(Eof())
				
				IncProc(STR0070) // "Preparando Base 5/5 - Processando Estoques"
				If Interrupcao(@lEnd)
					Exit
				Endif

				Do Case
				Case (cAliBLH)->CL_CLASS $ "10/30/60/70"
					cTrib := "S"
				Case (cAliBLH)->CL_CLASS $ "40/41"
					cTrib := "I"
				Case (cAliBLH)->CL_CLASS $ "50/51/90"
					cTrib := "O"
				OtherWise 
					cTrib := "T"
				EndCase
				
				nPos := aScan(aEstoque,{|x| x[1]==cTrib})
				If nPos > 0
					// Estoque na empresa
					If (cAliBLH)->IND_PROP== "0"
						aEstoque[nPos][03] += (cAliBLH)->VL_ITEM
					Endif
				Endif

				(cAliBLH)->(dbSkip())
			Enddo  
			( cAliBLH )->( dbCloseArea() )
		EndIf		
		
			// Excluindo area aberta pela funcao FsEstInv
			//FsEstInv(aEst,2,,,sTod(cDataIni)-1,.F.,.F.,,,,,,,,,,,,,lSBZ)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Processando o saldo final do periodo  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//aEst := {"EST",""}
			//FsEstInv(aEst,1,.T.,.F.,sTod(cDataFin),.F.,.F.,,,,,,,,,,,,,lSBZ)
		cAliBLH := ""
		IF ExistBlock("SPEDALTH")
			 cAliBLH := ExecBlock("SPEDALTH",.F.,.F.,{SToD(cDataFin),''})

			//Verifica se arquivo existe
			IF File(cAliBLH+GetDBExtension())
				
				dbSelectArea(cAliBLH) 
				(cAliBLH)->(dbGoTop())              
			Else
				Alert(STR0111)        // "Não foi encontrado arquivo do ponto de entrada SPEDALTH para compor Bloco H"
			Endif
		Else
			SPDBlocH(@cAliBLH,sTod(cDataIni),sTod(cDataFin))
		Endif

		if !Empty(cAliBLH)
			
			(cAliBLH)->(dbGoTop())
			Do While ! (cAliBLH)->(Eof())
				
				IncProc(STR0070) // "Preparando Base 5/5 - Processando Estoques"
				If Interrupcao(@lEnd)
					Exit
				Endif

				Do Case
				Case (cAliBLH)->CL_CLASS $ "10/30/60/70"
					cTrib := "S"
				Case (cAliBLH)->CL_CLASS $ "40/41"
					cTrib := "I"
				Case (cAliBLH)->CL_CLASS $ "50/51/90"
					cTrib := "O"
				OtherWise 
					cTrib := "T"
				EndCase
				
				nPos := aScan(aEstoque,{|x| x[1]==cTrib})
				If nPos > 0
					// Estoque na empresa
					If (cAliBLH)->IND_PROP == "0"
						aEstoque[nPos][04] += (cAliBLH)->VL_ITEM                                                             						
					Endif
				Endif

				(cAliBLH)->(dbSkip())
			Enddo
		EndIf  
		
		// Excluindo area aberta pela funcao FsEstInv
		//FsEstInv(aEst,2,,,sTod(cDataIni)-1,.F.,.F.,,,,,,,,,,,,,lSBZ)
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Total de registros a para impressao  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nRegsPrint := 	Len(aEntrEst) + Len(aEntrOut) + Len(aEntrExt) + Len(aEntrMun) + ;
					Len(aEntrUF) + Len(aSaiEst) + Len(aSaiOut) + Len(aSaiExt) + ;
					Len(aSaiUF) + Len(aExclu) + Len(aEstoque)

	SetRegua(nRegsPrint)                                                         
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ordena o array por cidade           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Asort(aEntrMun,,,{|x,y|x[2]<y[2]})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprimindo a DAMEF das entradas³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nLin 	:= Cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,15,,.F.)
	nLin++      

	// Estoque
	FmtLin(,aLay[061],,"@X",@nLin)
	FmtLin(,aLay[062],,"@X",@nLin)
	FmtLin(,aLay[063],,"@X",@nLin)
	FmtLin(,aLay[064],,"@X",@nLin)
	FmtLin(,aLay[065],,"@X",@nLin)
	
	For nX := 1 to Len(aEstoque)
		IncRegua()
		FmtLin({SubStr(aEstoque[nX][02],1,Len(aEstoque[nX][02])-1),Transform(aEstoque[nX][03],"@E 999,999,999,999.99"),Transform(aEstoque[nX][04],"@E 999,999,999,999.99")},aLay[066],,"@X",@nLin)	
		nTotIni 	+= aEstoque[nX][03]
		nTotFinal 	+= aEstoque[nX][04]
	Next                       
	
	FmtLin(,aLay[067],,"@X",@nLin)	
	FmtLin({Transform(nTotIni,"@E 999,999,999,999.99"),Transform(nTotFinal,"@E 999,999,999,999.99")},aLay[068],,"@X",@nLin)		
	FmtLin(,aLay[069],,"@X",@nLin)		

	cCabec1 := STR0033 // "DAMEF - Declaração do Movimento Econômico e Fiscal"
	nLin 	:= Cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,15,,.F.)
	nLin++      

	// Entradas do Estado	
	FmtLin(,aLay[001],,"@X",@nLin)
	FmtLin(,aLay[002],,"@X",@nLin)
	FmtLin(,aLay[003],,"@X",@nLin)
	FmtLin(,aLay[004],,"@X",@nLin)
	FmtLin(,aLay[005],,"@X",@nLin)
	FmtLin(,aLay[006],,"@X",@nLin)     
	FmtLin(,aLay[007],,"@X",@nLin)
	FmtLin(,aLay[008],,"@X",@nLin)
	FmtLin(,aLay[009],,"@X",@nLin)

	nTotCont := 0
	nTotBase := 0
	nTotICMS := 0
	nTotOutr := 0

	For nX := 1 to Len(aEntrEst)
		IncRegua()
		FmtLin({SubStr(aEntrEst[nX][01],1,Len(aEntrEst[nX][01])-1),Transform(aEntrEst[nX][02],"@E 999,999,999,999.99"),Transform(aEntrEst[nX][03],"@E 999,999,999,999.99"),Transform(aEntrEst[nX][04],"@E 999,999,999,999.99"),Transform(aEntrEst[nX][05],"@E 999,999,999,999.99")},aLay[010],,"@X",@nLin)	
		nTotCont += aEntrEst[nX][02]
		nTotBase += aEntrEst[nX][03]
		nTotICMS += aEntrEst[nX][04]
		nTotOutr += aEntrEst[nX][05]
	Next                       
	
	FmtLin(,aLay[011],,"@X",@nLin)	
	FmtLin({Transform(nTotCont,"@E 999,999,999,999.99"),Transform(nTotBase,"@E 999,999,999,999.99"),Transform(nTotICMS,"@E 999,999,999,999.99"),Transform(nTotOutr,"@E 999,999,999,999.99")},aLay[012],,"@X",@nLin)		
	FmtLin(,aLay[013],,"@X",@nLin)		
	
	// Entradas de Outros Estados
	nLin += 2
	FmtLin(,aLay[013],,"@X",@nLin)
	FmtLin(,aLay[014],,"@X",@nLin)
	FmtLin(,aLay[005],,"@X",@nLin)
	FmtLin(,aLay[006],,"@X",@nLin)     
	FmtLin(,aLay[007],,"@X",@nLin)
	FmtLin(,aLay[008],,"@X",@nLin)
	FmtLin(,aLay[009],,"@X",@nLin)

	nTotCont := 0
	nTotBase := 0
	nTotICMS := 0
	nTotOutr := 0
	For nX := 1 to Len(aEntrOut)
		IncRegua()
		FmtLin({SubStr(aEntrOut[nX][01],1,Len(aEntrOut[nX][01])-1),Transform(aEntrOut[nX][02],"@E 999,999,999,999.99"),Transform(aEntrOut[nX][03],"@E 999,999,999,999.99"),Transform(aEntrOut[nX][04],"@E 999,999,999,999.99"),Transform(aEntrOut[nX][05],"@E 999,999,999,999.99")},aLay[010],,"@X",@nLin)	
		nTotCont += aEntrOut[nX][02]
		nTotBase += aEntrOut[nX][03]
		nTotICMS += aEntrOut[nX][04]
		nTotOutr += aEntrOut[nX][05]
	Next                       
	
	FmtLin(,aLay[011],,"@X",@nLin)	
	FmtLin({Transform(nTotCont,"@E 999,999,999,999.99"),Transform(nTotBase,"@E 999,999,999,999.99"),Transform(nTotICMS,"@E 999,999,999,999.99"),Transform(nTotOutr,"@E 999,999,999,999.99")},aLay[012],,"@X",@nLin)		
	FmtLin(,aLay[013],,"@X",@nLin)		
	
	// Entradas do Exterior
	nLin += 2
	FmtLin(,aLay[013],,"@X",@nLin)
	FmtLin(,aLay[015],,"@X",@nLin)
	FmtLin(,aLay[005],,"@X",@nLin)
	FmtLin(,aLay[006],,"@X",@nLin)     
	FmtLin(,aLay[007],,"@X",@nLin)
	FmtLin(,aLay[008],,"@X",@nLin)
	FmtLin(,aLay[009],,"@X",@nLin)

	nTotCont := 0
	nTotBase := 0
	nTotICMS := 0
	nTotOutr := 0
	For nX := 1 to Len(aEntrExt)
		IncRegua()
		FmtLin({SubStr(aEntrExt[nX][01],1,Len(aEntrExt[nX][01])-1),Transform(aEntrExt[nX][02],"@E 999,999,999,999.99"),Transform(aEntrExt[nX][03],"@E 999,999,999,999.99"),Transform(aEntrExt[nX][04],"@E 999,999,999,999.99"),Transform(aEntrExt[nX][05],"@E 999,999,999,999.99")},aLay[010],,"@X",@nLin)	
		nTotCont += aEntrExt[nX][02]
		nTotBase += aEntrExt[nX][03]
		nTotICMS += aEntrExt[nX][04]
		nTotOutr += aEntrExt[nX][05]
	Next                       
	
	FmtLin(,aLay[011],,"@X",@nLin)	
	FmtLin({Transform(nTotCont,"@E 999,999,999,999.99"),Transform(nTotBase,"@E 999,999,999,999.99"),Transform(nTotICMS,"@E 999,999,999,999.99"),Transform(nTotOutr,"@E 999,999,999,999.99")},aLay[012],,"@X",@nLin)		
	FmtLin(,aLay[013],,"@X",@nLin)		
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprimindo a DAMEF das Saidas  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCabec1 := STR0033 // "DAMEF - Declaração do Movimento Econômico e Fiscal"
	nLin 	:= Cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,15,,.F.)
	nLin++      

	// Saidas para o Estado	
	FmtLin(,aLay[016],,"@X",@nLin)
	FmtLin(,aLay[017],,"@X",@nLin)
	FmtLin(,aLay[018],,"@X",@nLin)
	FmtLin(,aLay[019],,"@X",@nLin)
	FmtLin(,aLay[020],,"@X",@nLin)
	FmtLin(,aLay[021],,"@X",@nLin)     
	FmtLin(,aLay[022],,"@X",@nLin)
	FmtLin(,aLay[023],,"@X",@nLin)
	FmtLin(,aLay[024],,"@X",@nLin)

	nTotCont := 0
	nTotBase := 0
	nTotICMS := 0
	nTotOutr := 0

	For nX := 1 to Len(aSaiEst)
		IncRegua()
		FmtLin({SubStr(aSaiEst[nX][01],1,Len(aSaiEst[nX][01])-1),Transform(aSaiEst[nX][02],"@E 999,999,999,999.99"),Transform(aSaiEst[nX][03],"@E 999,999,999,999.99"),Transform(aSaiEst[nX][04],"@E 999,999,999,999.99"),Transform(aSaiEst[nX][05],"@E 999,999,999,999.99")},aLay[025],,"@X",@nLin)	
		nTotCont += aSaiEst[nX][02]
		nTotBase += aSaiEst[nX][03]
		nTotICMS += aSaiEst[nX][04]
		nTotOutr += aSaiEst[nX][05]
	Next                       
	
	FmtLin(,aLay[026],,"@X",@nLin)	
	FmtLin({Transform(nTotCont,"@E 999,999,999,999.99"),Transform(nTotBase,"@E 999,999,999,999.99"),Transform(nTotICMS,"@E 999,999,999,999.99"),Transform(nTotOutr,"@E 999,999,999,999.99")},aLay[027],,"@X",@nLin)		
	FmtLin(,aLay[028],,"@X",@nLin)		

	// Saidas para outros Estados	
	nLin	+= 2
	FmtLin(,aLay[028],,"@X",@nLin)
	FmtLin(,aLay[029],,"@X",@nLin)
	FmtLin(,aLay[020],,"@X",@nLin)
	FmtLin(,aLay[021],,"@X",@nLin)     
	FmtLin(,aLay[022],,"@X",@nLin)
	FmtLin(,aLay[023],,"@X",@nLin)
	FmtLin(,aLay[024],,"@X",@nLin)

	nTotCont := 0
	nTotBase := 0
	nTotICMS := 0
	nTotOutr := 0

	For nX := 1 to Len(aSaiOut)
		IncRegua()
		FmtLin({SubStr(aSaiOut[nX][01],1,Len(aSaiOut[nX][01])-1),Transform(aSaiOut[nX][02],"@E 999,999,999,999.99"),Transform(aSaiOut[nX][03],"@E 999,999,999,999.99"),Transform(aSaiOut[nX][04],"@E 999,999,999,999.99"),Transform(aSaiOut[nX][05],"@E 999,999,999,999.99")},aLay[025],,"@X",@nLin)	
		nTotCont += aSaiOut[nX][02]
		nTotBase += aSaiOut[nX][03]
		nTotICMS += aSaiOut[nX][04]
		nTotOutr += aSaiOut[nX][05]
	Next                       
	
	FmtLin(,aLay[026],,"@X",@nLin)	
	FmtLin({Transform(nTotCont,"@E 999,999,999,999.99"),Transform(nTotBase,"@E 999,999,999,999.99"),Transform(nTotICMS,"@E 999,999,999,999.99"),Transform(nTotOutr,"@E 999,999,999,999.99")},aLay[027],,"@X",@nLin)		
	FmtLin(,aLay[028],,"@X",@nLin)		

	// Saidas para o Exterior	
	nLin	+= 2
	FmtLin(,aLay[028],,"@X",@nLin)
	FmtLin(,aLay[030],,"@X",@nLin)
	FmtLin(,aLay[020],,"@X",@nLin)
	FmtLin(,aLay[021],,"@X",@nLin)     
	FmtLin(,aLay[022],,"@X",@nLin)
	FmtLin(,aLay[023],,"@X",@nLin)
	FmtLin(,aLay[024],,"@X",@nLin)

	nTotCont := 0
	nTotBase := 0
	nTotICMS := 0
	nTotOutr := 0

	For nX := 1 to Len(aSaiExt)
		IncRegua()
		FmtLin({SubStr(aSaiExt[nX][01],1,Len(aSaiExt[nX][01])-1),Transform(aSaiExt[nX][02],"@E 999,999,999,999.99"),Transform(aSaiExt[nX][03],"@E 999,999,999,999.99"),Transform(aSaiExt[nX][04],"@E 999,999,999,999.99"),Transform(aSaiExt[nX][05],"@E 999,999,999,999.99")},aLay[025],,"@X",@nLin)	
		nTotCont += aSaiExt[nX][02]
		nTotBase += aSaiExt[nX][03]
		nTotICMS += aSaiExt[nX][04]
		nTotOutr += aSaiExt[nX][05]
	Next                       
	
	FmtLin(,aLay[026],,"@X",@nLin)	
	FmtLin({Transform(nTotCont,"@E 999,999,999,999.99"),Transform(nTotBase,"@E 999,999,999,999.99"),Transform(nTotICMS,"@E 999,999,999,999.99"),Transform(nTotOutr,"@E 999,999,999,999.99")},aLay[027],,"@X",@nLin)		
	FmtLin(,aLay[028],,"@X",@nLin)		

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprimindo Exclusões VAF³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	cCabec1 := STR0044 // "Informações Referentes ao VAF"
	nLin 	:= Cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,15,,.F.)
	nLin++      
	
	FmtLin(,aLay[031],,"@X",@nLin)	
	FmtLin(,aLay[032],,"@X",@nLin)	
	FmtLin(,aLay[033],,"@X",@nLin)	
	FmtLin(,aLay[034],,"@X",@nLin)	
	FmtLin(,aLay[035],,"@X",@nLin)					
	
	For nX := 1 to Len(aExclu)
		IncRegua()
		FmtLin({SubStr(aExclu[nX][01],1,Len(aExclu[nX][01])-1),Transform(aExclu[nX][02],"@E 999,999,999,999.99"),Transform(aExclu[nX][03],"@E 999,999,999,999.99")},aLay[036],,"@X",@nLin)	
		nTotEntr += aExclu[nX][02]
		nTotSai  += aExclu[nX][03]
	Next

	FmtLin(,aLay[037],,"@X",@nLin)	
	FmtLin({Transform(nTotEntr,"@E 999,999,999,999.99"),Transform(nTotSai,"@E 999,999,999,999.99")},aLay[038],,"@X",@nLin)	
	FmtLin(,aLay[039],,"@X",@nLin)		

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprimindo Detalhamento VAF nas Entradas³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nLin += 2	
	FmtLin(,aLay[040],,"@X",@nLin)	
	FmtLin(,aLay[041],,"@X",@nLin)	
	FmtLin(,aLay[042],,"@X",@nLin)	
	FmtLin(,aLay[043],,"@X",@nLin)	
	FmtLin(,aLay[044],,"@X",@nLin)
		
	For nX := 1 to Len(aEntrMun)
		IncRegua()
		If nLin > 58               
			FmtLin(,aLay[046],,"@X",@nLin)			
			nLin 	:= Cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,15,,.F.)
			nLin++      
			FmtLin(,aLay[040],,"@X",@nLin)	
			FmtLin(,aLay[041],,"@X",@nLin)	
			FmtLin(,aLay[042],,"@X",@nLin)	
			FmtLin(,aLay[043],,"@X",@nLin)	
			FmtLin(,aLay[044],,"@X",@nLin)
			
		Endif
		
		If Left(Alltrim(aWizard[01,04]),1) == "1" //Transportadora
			FmtLin({aEntrMun[nX][01],aEntrMun[nX][02],Transform(aEntrMun[nX,03],"@E 999,999,999,999.99"),;
					Transform(aEntrMun[nX,04],"@E 999,999,999,999.99"),Transform(aEntrMun[nX,04]+aEntrMun[nX,03],"@E 999,999,999,999.99")},aLay[045],,"@X",@nLin)
					
			nTotOutEn += aEntrMun[nX,03]
			nTotCrePr += aEntrMun[nX,04]
		Else		
			FmtLin({aEntrMun[nX][01],aEntrMun[nX][02],Transform(aEntrMun[nX][03],"@E 999,999,999,999.99")},aLay[045],,"@X",@nLin)
		Endif
		
	Next
		
	If Left(Alltrim(aWizard[01,04]),1) == "1" //Transportadora
		FmtLin(,aLay[073],,"@X",@nLin)
		FmtLin({Transform(nTotOutEn,"@E 999,999,999,999.99"),Transform(nTotCrePr,"@E 999,999,999,999.99"),Transform(nTotOutEn+nTotCrePr,"@E 999,999,999,999.99")},aLay[072],,"@X",@nLin)
	Endif
	
	If Len(aEntrMun) == 0
		FmtLin(,aLay[070],,"@X",@nLin)	
	Endif               
	
	FmtLin(,aLay[046],,"@X",@nLin)	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprimindo GI - Entradas³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCabec1 := STR0063 //"GI - Guia de Informação Interestadual"
	nLin 	:= Cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,15,,.F.)
	nLin++                     
		
	FmtLin(,aLay[047],,"@X",@nLin)	
	FmtLin(,aLay[048],,"@X",@nLin)	
	FmtLin(,aLay[049],,"@X",@nLin)	
	FmtLin(,aLay[050],,"@X",@nLin)	
	FmtLin(,aLay[051],,"@X",@nLin)	
	
	lProcessa := .F.
	For nX := 1 to Len(aEntrUF)             
		IncRegua()
		If aEntrUF[nX][03] + aEntrUF[nX][04] + aEntrUF[nX][05] + aEntrUF[nX][06] + aEntrUF[nX][07] > 0
			FmtLin({aEntrUF[nX][01],Transform(aEntrUF[nX][03],"@E 999,999,999,999.99"),Transform(aEntrUF[nX][04],"@E 999,999,999,999.99"),Transform(aEntrUF[nX][05],"@E 999,999,999,999.99"),Transform(aEntrUF[nX][06],"@E 999,999,999,999.99"),Transform(aEntrUF[nX][07],"@E 999,999,999,999.99")},aLay[052],,"@X",@nLin)
			lProcessa := .T.
		Endif
	Next                        
		
	If !lProcessa
		FmtLin(,aLay[071],,"@X",@nLin)	
	Endif

	FmtLin(,aLay[053],,"@X",@nLin)	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprimindo GI - Saídas  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nLin > 58
		cCabec1 := STR0063 //"GI - Guia de Informação Interestadual"
		nLin 	:= Cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,15,,.F.)
		nLin++                     
	Endif                   
	
	nLin += 2
	
	FmtLin(,aLay[054],,"@X",@nLin)	
	FmtLin(,aLay[055],,"@X",@nLin)	
	FmtLin(,aLay[056],,"@X",@nLin)	
	FmtLin(,aLay[057],,"@X",@nLin)	
	FmtLin(,aLay[058],,"@X",@nLin)	
		
	lProcessa := .F.
	For nX := 1 to Len(aSaiUF)
		IncRegua()  
		If nLin > 58
			FmtLin(,aLay[060],,"@X",@nLin)	
			cCabec1 := STR0063 //"GI - Guia de Informação Interestadual"
			nLin 	:= Cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,15,,.F.)
			nLin++                     
			FmtLin(,aLay[054],,"@X",@nLin)	
			FmtLin(,aLay[055],,"@X",@nLin)	
			FmtLin(,aLay[056],,"@X",@nLin)	
			FmtLin(,aLay[057],,"@X",@nLin)	
			FmtLin(,aLay[058],,"@X",@nLin)	
		Endif                   

		If aSaiUF[nX][03] + aSaiUF[nX][04]+ aSaiUF[nX][05] + aSaiUF[nX][06] + aSaiUF[nX][07] + aSaiUF[nX][08] > 0
			FmtLin({aSaiUF[nX][01],Transform(aSaiUF[nX][03],"@E 999,999,999,999.99"),Transform(aSaiUF[nX][04],"@E 999,999,999,999.99"),Transform(aSaiUF[nX][05],"@E 999,999,999,999.99"),Transform(aSaiUF[nX][06],"@E 999,999,999,999.99"),Transform(aSaiUF[nX][07],"@E 999,999,999,999.99"),Transform(aSaiUF[nX][08],"@E 999,999,999,999.99")},aLay[059],,"@X",@nLin)
			lProcessa := .T.
		Endif
	Next                        
	
	If !lProcessa
		FmtLin(,aLay[071],,"@X",@nLin)	
	Endif

	FmtLin(,aLay[060],,"@X",@nLin)

	If !Empty(cAliBLH) .And. Select(cAliBLH) > 0
		( cAliBLH )->( dbCloseArea() )
	EndIf
		
Return( .T. ) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |R939LayOutºAutor  ³Mary C. Hergert     º Data ³ 05/04/2005  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Layout de Impressao                                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³MATR939                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R939LayOut(aWizard)

	Local aLay := Array(75)

//	aLay[001] :=   0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
//	aLay[001] :=   0         10        20        30        40        50        60        70        80        90        100       110       120       130
	aLay[001] := '+-----------------------------------------------------------------------------------------------------------------------------------+'
	aLay[002] := STR0071 //'|                                            RESUMO DAS OPERAÇÕES E PRESTAÇÕES DE ENTRADA                                           |'
	aLay[003] := '|-----------------------------------------------------------------------------------------------------------------------------------|'
	aLay[004] := STR0072 //'|                                                         Entradas do Estado                                                        |'
	aLay[005] := '|-------------------------------+--------------------------------------------------------------------------+------------------------|'
	aLay[006] := STR0073 //'|                               |                     Oper/Prest. com Crédito de ICMS                      | Operações e Prestações |'
	aLay[007] := STR0074 //'|           Natureza            |--------------------------------------------------------------------------+     sem Crédito de     |'
	aLay[008] := STR0075 //'|                               |     Valor Contábil     |    Base de Cálculo     |          ICMS          |          ICMS          |'
	aLay[009] := '|-------------------------------+------------------------+------------------------+------------------------+------------------------|'
	aLay[010] := '|   #########################   |   ##################   |   ##################   |   ##################   |   ##################   |'
	aLay[011] := '|-------------------------------+------------------------+------------------------+------------------------+------------------------|'
	aLay[012] := '|   SUBTOTAL                    |   ##################   |   ##################   |   ##################   |   ##################   |'
	aLay[013] := '+-----------------------------------------------------------------------------------------------------------------------------------+'
	aLay[014] := STR0076 //'|                                                       Entradas de Outros Estados                                                  |'
	aLay[015] := STR0077 //'|                                                          Entradas do Exterior                                                     |'

	aLay[016] := '+-----------------------------------------------------------------------------------------------------------------------------------+'
	aLay[017] := STR0078 //'|                                             RESUMO DAS OPERAÇÕES E PRESTAÇÕES DE SAÍDA                                            |'
	aLay[018] := '|-----------------------------------------------------------------------------------------------------------------------------------|'
	aLay[019] := STR0079 //'|                                                        Saídas para o Estado                                                       |'
	aLay[020] := '|-------------------------------+--------------------------------------------------------------------------+------------------------|'
	aLay[021] := STR0080 //'|                               |                     Oper/Prest. com Debito de ICMS                       | Operações e Prestações |'
	aLay[022] := STR0081 //'|           Natureza            |--------------------------------------------------------------------------+        sem Debito      |'
	aLay[023] := STR0082 //'|                               |     Valor Contábil     |    Base de Cálculo     |          ICMS          |           ICMS         |'
	aLay[024] := '|-------------------------------+------------------------+------------------------+------------------------+------------------------|'
	aLay[025] := '|   #########################   |   ##################   |   ##################   |   ##################   |   ##################   |'
	aLay[026] := '|-------------------------------+------------------------+------------------------+------------------------+------------------------|'
	aLay[027] := STR0083 //'|   SUBTOTAL                    |   ##################   |   ##################   |   ##################   |   ##################   |'
	aLay[028] := '+-----------------------------------------------------------------------------------------------------------------------------------+'
	aLay[029] := STR0084 //'|                                                       Saídas para Outros Estados                                                  |'
	aLay[030] := STR0085 //'|                                                         Saidas para o Exterior                                                    |'

	aLay[031] := '+---------------------------------------------------------------------------------------------------------------+'
	aLay[032] := STR0086 //'|                                                EXCLUSÕES DO VAF                                               |'
	aLay[033] := '|---------------------------------------------------------------------------------------------------------------|'
	aLay[034] := STR0087 //'|                         Exclusões                           |        Entradas        |         Saídas         |'
	aLay[035] := '|-------------------------------------------------------------+------------------------+------------------------|'
	aLay[036] := '|   #######################################################   |   ##################   |   ##################   |'
	aLay[037] := '|-------------------------------------------------------------+------------------------+------------------------|'
	aLay[038] := STR0088 //'|   TOTAL DAS EXCLUSÕES                                       |   ##################   |   ##################   |'
	aLay[039] := '+---------------------------------------------------------------------------------------------------------------+'
    
	If Left(Alltrim(aWizard[01,04]),1) == "1" //Transportadora
		aLay[040] := '+---------------------------------------------------------------------------------------------------------------------------+'
		aLay[041] := STR0104 //'|                                    DETALHAMENTO DO VAF (OUTRAS ENTRADAS) POR MUNICÍPIO                                    |'
		aLay[042] := '|---------------------------------------------------------------------------------------------------------------------------|'
		aLay[043] := STR0105 //'|   Código  |         Nome do Município          |  Outras Entradas (80%) |    Créd. Pres. (20%)   |          TOTAL         |'
		aLay[044] := '|-----------+------------------------------------+--------------------------------------------------------------------------|'
		aLay[045] := '|   #####   |   ##############################   |   ##################   |   ###################  |    ################    |'
		aLay[073] := '|-----------+------------------------------------+--------------------------------------------------------------------------|'
		aLay[072] := STR0107 //'|  TOTAL                                         |   ##################   |   ###################  |    ################    |'
		aLay[046] := '+---------------------------------------------------------------------------------------------------------------------------+'
		aLay[070] := STR0106 //'|                                                     << Sem Movimento >>                                                   |'                                        
	Else
		aLay[040] := '+-------------------------------------------------------------------------+'
		aLay[041] := STR0089 //'|           DETALHAMENTO DO VAF (OUTRAS ENTRADAS) POR MUNICÍPIO           |'
		aLay[042] := '|-------------------------------------------------------------------------|'
		aLay[043] := STR0090 //'|   Código  |         Nome do Município          |         Total          |'
		aLay[044] := '|-----------+------------------------------------+------------------------|'
		aLay[045] := '|   #####   |   ##############################   |   ##################   |'
		aLay[046] := '+-------------------------------------------------------------------------+'
		aLay[070] := STR0091 //'|                           << Sem Movimento >>                           |'
		aLay[072] := ''
		aLay[073] := ''
	Endif

	aLay[047] := '+-----------------------------------------------------------------------------------------------------------------------------------+'
	aLay[048] := STR0092 //'|                                     ENTRADAS DE MERCADORIAS, BENS E/OU AQUISIÇÕES DE SERVIÇOS                                     |'
	aLay[049] := '|-----------------------------------------------------------------------------------------------------------------------------------|'
	aLay[050] := STR0093 //'|  UF  |     Valor Contábil      |    Base de Cálculo     |     Outras Saídas      |       ST Petróleo      |       ST Outros       |'
	aLay[051] := '|------+-------------------------+------------------------+------------------------+------------------------+-----------------------|'
	aLay[052] := '|  ##  |   ##################    |   ##################   |   ##################   |   ##################   |   ##################  |'
	aLay[053] := '+-----------------------------------------------------------------------------------------------------------------------------------|'
	aLay[071] := STR0094 //'|                                                        << Sem Movimento >>                                                        |'
	
	aLay[054] := '+-----------------------------------------------------------------------------------------------------------------------------------+'
	aLay[055] := STR0095 //'|                                      SAÍDAS DE MERCADORIAS, BENS E/OU AQUISIÇÕES DE SERVIÇOS                                      |'
	aLay[056] := '|-----------------------------------------------------------------------------------------------------------------------------------|'
	aLay[057] := STR0096 //'| UF | VC (Contribuinte)  | VC(N Contribuinte) | BC (Contribuinte)  | BC(N Contribuinte) |   Outras Saidas    | Subst. Tributária   |'
	aLay[058] := '|----+--------------------+--------------------+--------------------+--------------------+--------------------+---------------------|'
	aLay[059] := '| ## | ################## | ################## | ################## | ################## | ################## | ##################  |'
	aLay[060] := '+-----------------------------------------------------------------------------------------------------------------------------------+'

	aLay[061] := '+--------------------------------------------------------------------------------------+'
	aLay[062] := STR0097 //'|                          ESTOQUES DE MERCADORIAS E PRODUTOS                          |'
	aLay[063] := '|--------------------------------------------------------------------------------------|'
	aLay[064] := STR0098 //'|            Discriminação           |     Inicial (em R$)    |      Final (em R$)     |'
	aLay[065] := '|------------------------------------+------------------------+------------------------|'
	aLay[066] := '|   ##############################   |   ##################   |   ##################   |'
	aLay[067] := '|------------------------------------+------------------------+------------------------|'
	aLay[068] := STR0099 //'|   TOTAL                            |   ##################   |   ##################   |'
	aLay[069] := '+--------------------------------------------------------------------------------------+'


Return aLay

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MATR939Wiz  ºAutor  ³Mary C. Hergert     º Data ³ 26/08/2005  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta a wizard com as perguntas necessarias                   º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³MATR939                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function MATR939Wiz()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Declaracao das variaveis³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aTxtPre		:= {}
	Local aPaineis		:= {}
	Local aYesNo		:= {STR0015,STR0016} //{"1 - Sim","2 - Não"}
	Local cTitObj1		:= ""
	Local nTam			:= 500
	Local cMask			:= Replicate("X",nTam)
	Local nPos			:= 0
	Local lRet			:= 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta wizard com as perguntas necessarias³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aTxtPre,STR0001) //"Valor Adicionado Fiscal (VAF)"
	aAdd(aTxtPre,STR0006) //"Atenção"
	aAdd(aTxtPre,STR0007) //"Preencha corretamente as informações solicitadas."
	aAdd(aTxtPre,STR0008+STR0009+STR0001)	//"Esta rotina ira permitir a configuracao das informacoes "
											//"necessarias a geracao do relatorio auxiliar para o preenchimento da "
											//"Declaração do Valor Adicionado Fiscal (VAF)"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Painel 1 - Informacoes Gerais            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aPaineis,{})
	nPos := Len(aPaineis)
	aAdd(aPaineis[nPos],STR0010) //"Assistente de parametrização"
	aAdd(aPaineis[nPos],STR0011) //"Informações gerais:"
	aAdd(aPaineis[nPos],{})

	cTitObj1 := STR0012 //"Data Inicial: "
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,"@d",3,,,,8})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0013 //"Data Final: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,"@d",3,,,,8})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0014 //"Gera Informações de Estoque? "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{3,,,1,,aYesNo,,7})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0109 //"Contribuinte é Transportadora?"
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{3,,,1,,aYesNo,,7})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0110 //"Utiliza SBZ?"
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{3,,,1,,aYesNo,,7})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Painel 2 - CFOPs Entradas do Estado      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aPaineis,{})
	nPos := Len(aPaineis)
	aAdd(aPaineis[nPos],STR0010) //"Assistente de parametrização"
	aAdd(aPaineis[nPos],STR0017) //"DAMEF - CFOPs utilizados nas Entradas do Estado:"
	aAdd(aPaineis[nPos],{})
	//
	cTitObj1 := STR0018 //"Compras: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0019 //"Transferências: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0020 //"Devoluções: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0021 //"Energia Elétrica: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0022 //"Comunicações : "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0023 //"Transportes: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0024 //"Outras: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0025 //"Aquisição de Produtos Agropecuários: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Painel 3 - CFOPs Entradas de Outros Estados  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aPaineis,{})
	nPos := Len(aPaineis)
	aAdd(aPaineis[nPos],STR0010) //"Assistente de parametrização" 
	aAdd(aPaineis[nPos],STR0026) //"DAMEF - CFOPs utilizados nas Entradas de Outros Estados:"
	aAdd(aPaineis[nPos],{})
	//
	cTitObj1 := STR0018 //"Compras: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0019 //"Transferências: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0020 //"Devoluções: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0021 //"Energia Elétrica: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0022 //"Comunicações : "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//  
	cTitObj1 := STR0023 //"Transportes: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0024 //"Outras: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Painel 4 - CFOPs Entradas do Exterior        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aPaineis,{})
	nPos := Len(aPaineis)
	aAdd(aPaineis[nPos],STR0010) //"Assistente de parametrização"
	aAdd(aPaineis[nPos],STR0027) //"DAMEF - CFOPs utilizados nas Entradas do Exterior:"
	aAdd(aPaineis[nPos],{})
	//
	cTitObj1 := STR0018 //"Compras: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0020 //"Devoluções: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0021 //"Energia Elétrica: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0022 //"Comunicações : "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0023 //"Transportes: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0024 //"Outras: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Painel 5 - CFOPs Saídas para o Estado   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aPaineis,{})
	nPos := Len(aPaineis)
	aAdd(aPaineis[nPos],STR0010) //"Assistente de parametrização"
	aAdd(aPaineis[nPos],STR0028) //"DAMEF - CFOPs utilizados nas Saidas para o Estado:"
	aAdd(aPaineis[nPos],{})
	//
	cTitObj1 := STR0029 //"Vendas: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0019 //"Transferências: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0020 //"Devoluções: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0021 //"Energia Elétrica: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0022 //"Comunicações : "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0023 //"Transportes: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0024 //"Outras: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0102 //"Transporte Tomado: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Painel 6 - CFOPs Saídas para outros Estados ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aPaineis,{})
	nPos := Len(aPaineis)
	aAdd(aPaineis[nPos],STR0010) //"Assistente de parametrização" 
	aAdd(aPaineis[nPos],STR0030) //"DAMEF - CFOPs utilizados nas Saidas para outros Estados:"
	aAdd(aPaineis[nPos],{})
	//
	cTitObj1 := STR0029 //"Vendas: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0019 //"Transferências: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0020 //"Devoluções: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0021 //"Energia Elétrica: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0022 //"Comunicações : "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//  
	cTitObj1 := STR0023 //"Transportes: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0024 //"Outras: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Painel 7 - CFOPs Saídas para o Exterior     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aPaineis,{})
	nPos := Len(aPaineis)
	aAdd(aPaineis[nPos],STR0010) //"Assistente de parametrização" 
	aAdd(aPaineis[nPos],STR0031) //"DAMEF - CFOPs utilizados nas Saidas para o Exterior:"
	aAdd(aPaineis[nPos],{})
	//
	cTitObj1 := STR0029 //"Vendas: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0020 //"Devoluções: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0021 //"Energia Elétrica: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0022 //"Comunicações : "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0023 //"Transportes: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0024 //"Outras: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Painel 8 - CFOPs - Exclusoes nas Entradas   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aPaineis,{})
	nPos := Len(aPaineis)
	aAdd(aPaineis[nPos],STR0010) //"Assistente de parametrização"
	aAdd(aPaineis[nPos],STR0032) //"VAF - Exclusões nas Entradas:"
	aAdd(aPaineis[nPos],{})
	//
	cTitObj1 := STR0059 //"ICMS Retido por Subst. Tributária: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0034 //"Entrega Futura (Simples Faturamento): "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0060 //"Parcela do IPI que não integra a base de cálculo: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0035 //"Ativo Imobilizado: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0036 //"Material de Uso e Consumo: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0038 //"Simples Remessa (por conta e ordem de Terceiro): "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0039 //"Energia Elétrica/Comunicação: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0040 //"Transportes (parcela não utilizada): "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0043 //"Remessa/Retorno/Consignação/Depósito: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0103	//"Remessa/Retorno de consignação:"
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0024 //"Outras: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Painel 9 - CFOPs - Exclusoes nas Entradas Interestadual ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aPaineis,{})
	nPos := Len(aPaineis)
	aAdd(aPaineis[nPos],STR0010) //"Assistente de parametrização"
	aAdd(aPaineis[nPos],STR0112) //"VAF - Exclusões nas Entradas externas:"
	aAdd(aPaineis[nPos],{})
	//
	cTitObj1 := STR0059 //"ICMS Retido por Subst. Tributária: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0034 //"Entrega Futura (Simples Faturamento): "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0060 //"Parcela do IPI que não integra a base de cálculo: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0035 //"Ativo Imobilizado: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0036 //"Material de Uso e Consumo: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0038 //"Simples Remessa (por conta e ordem de Terceiro): "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0039 //"Energia Elétrica/Comunicação: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0040 //"Transportes (parcela não utilizada): "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0043 //"Remessa/Retorno/Consignação/Depósito: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0103	//"Remessa/Retorno de consignação:"
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0024 //"Outras: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Painel 10 - CFOPs - Exclusoes nas Saidas     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aPaineis,{})
	nPos := Len(aPaineis)
	aAdd(aPaineis[nPos],STR0010) //"Assistente de parametrização"
	aAdd(aPaineis[nPos],STR0058) //"VAF - Exclusões nas Saidas:"
	aAdd(aPaineis[nPos],{})
	//
	cTitObj1 := STR0059 //"ICMS Retido por Subst. Tributária: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0034 //"Entrega Futura (Simples Faturamento): "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0060 //"Parcela do IPI que não integra a base de cálculo: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0035 //"Ativo Imobilizado: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0036 //"Material de Uso e Consumo: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0038 //"Simples Remessa (por conta e ordem de Terceiro): "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0043 //"Remessa/Retorno de Armazenamento/Depósito: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0103 //"Remessa/Retorno de consignação:"
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0024 //"Outras: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0061 //"Transp. iniciados em outro País/UF/Municipio:"
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Painel 11 - CFOPs - GI - Subst. Tributaria  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aPaineis,{})
	nPos := Len(aPaineis)
	aAdd(aPaineis[nPos],STR0010) //"Assistente de parametrização" 
	aAdd(aPaineis[nPos],STR0045) //"GI - CFOPs para entradas com Subst. Tributária e Saídas para Não Contribuintes:"
	aAdd(aPaineis[nPos],{})
	//
	cTitObj1 := STR0046 //"Entradas com Subst. Tributária - Petróleo: "
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0047 //"Entradas com Subst. Tributária - Outros: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 := STR0062 //"Saídas para Não Contribuintes: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,nTam})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})

	lRet :=	xMagWizard(aTxtPre,aPaineis,"MATR939")

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} MATR939

Retorna a origem do frete

@return	{cUF, cMunic}

@author Mauro A. Gonçalves
@since 15/09/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function IniFrete(cAliasSF3)

Local cUF		:= ''
Local cMunic	:= ''
Local lDUESol	:= DUE->(FieldPos("DUE_CODSOL")) > 0

If IntTMS() //Integracao com TMS
	DTC->(DbSetOrder(3)) //DTC_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SERIE+DTC_SERVIC+DTC_CODPRO
	If DTC->(MsSeek (xFilial("DTC")+(cAliasSF3)->F3_FILIAL+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE))
		If !Empty(DTC->DTC_NUMSOL) .And. DTC->DTC_SELORI == "3" //--Origem e Local de Coleta
				//--Posiciona na Ordem de Coleta
			DT5->(DbSetOrder (1))
			If DT5->(MsSeek (xFilial ("DT5")+DTC->DTC_FILORI+DTC->DTC_NUMSOL))
					//--Verifica se o Solicitante tem Sequencias de Endereco
				If Empty (DT5->DT5_SEQEND)
					DUE->(dbSetOrder(1))
					If !lDUESol
						DUE->(MsSeek(xFilial("DUE")+DT5->(DT5_DDD+DT5_TEL)))
					Else
						DUE->(MsSeek(xFilial("DUE")+DT5->DT5_CODSOL))
					EndIf
					cMunic	:= Iif(DUE->(FieldPos("DUE_CODMUN"))>0, DUE->DUE_CODMUN, "")
					cUF		:= Iif(DUE->(FieldPos("DUE_EST"))>0, DUE->DUE_EST,"")
				Else
					If !lDUESol
						DUL->(dbSetOrder(1))
						DUL->(MsSeek(xFilial("DUL")+DT5->(DT5_DDD+DT5_TEL+DT5_SEQEND)))
					Else
						DUL->(dbSetOrder(3))
						DUL->(MsSeek(xFilial("DUL")+DT5->(DT5_CODSOL+DT5_SEQEND)))
					EndIf
					cMunic	:= Iif(DUL->(FieldPos("DUL_CODMUN"))>0, DUL->DUL_CODMUN, "")
					cUF		:= Iif(DUL->(FieldPos("DUL_EST"))>0, DUL->DUL_EST,"")
				EndIf
			EndIf
		EndIf
	EndIf
	If Empty(cMunic)
		DT6->(dbSetOrder(1)) //DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE
		If (DT6->(MsSeek (xFilial ("DT6")+(cAliasSF3)->F3_FILIAL+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE)))
			If DT6->DT6_DOCTMS == StrZero( 8, Len( DT6->DT6_DOCTMS ) )  //-- Conhecimento Complementar
				If DT6->(MsSeek(xFilial('DT6') + DT6->(DT6_FILDCO+DT6_DOCDCO+DT6_SERDCO))) //-- Busca o Conhecimento Original
					DTC->(DbSetOrder(1)) //DTC_FILIAL+DTC_FILORI+DTC_LOTNFC+DTC_CLIREM+DTC_LOJREM+DTC_CLIDES+DTC_LOJDES+DTC_SERVIC+DTC_CODPRO+DTC_NUMNFC+DTC_SERNFC+DTC_NUMSOL
					If DTC->(MsSeek(xFilial('DTC') + DT6->(DT6_FILORI + DT6_LOTNFC)))
						If !Empty(DTC->DTC_NUMSOL) .And. DTC->DTC_SELORI == "3" //--Origem e Local de Coleta
								//-- Posiciona na Ordem de Coleta
							DT5->(DbSetOrder (1))
							If DT5->(MsSeek(xFilial("DT5")+DTC->DTC_FILORI+DTC->DTC_NUMSOL))
									//--Verifica se o Solicitante tem Sequencias de Endereco
								If Empty (DT5->DT5_SEQEND)
									DUE->(dbSetOrder(1))
									If !lDUESol
										DUE->(MsSeek(xFilial("DUE")+DT5->(DT5_DDD+DT5_TEL)))
									Else
										DUE->(MsSeek(xFilial("DUE")+DT5->DT5_CODSOL))
									EndIf
									cMunic	:= Iif(DUE->(FieldPos("DUE_CODMUN"))>0, DUE->DUE_CODMUN, "")
									cUF		:= Iif(DUE->(FieldPos("DUE_EST"))>0, DUE->DUE_EST,"")
								Else
									If !lDUESol
										DUL->(dbSetOrder(1))
										DUL->(MsSeek(xFilial("DUL")+DT5->(DT5_DDD+DT5_TEL+DT5_SEQEND)))
									Else
										DUL->(dbSetOrder(3))
										DUL->(MsSeek(xFilial("DUL")+DT5->(DT5_CODSOL+DT5_SEQEND)))
									EndIf
									cMunic	:= Iif(DUL->(FieldPos("DUL_CODMUN"))>0, DUL->DUL_CODMUN, "")
									cUF		:= Iif(DUL->(FieldPos("DUL_EST"))>0, DUL->DUL_EST,"")
								EndIf
							EndIf
						ElseIf DTC->DTC_SELORI == "2" //--Origem Cliente Remetente
							cMunic := ''
							SA1->(DbSetOrder(1))
							If SA1->(MsSeek (xFilial ("SA1")+DT6->(DT6_CLIREM+DT6_LOJREM)))
								cMunic := SA1->A1_COD_MUN
								cUF    := SA1->A1_EST
							EndIf
						ElseIf DTC->DTC_SELORI == "1" //--Origem Transportadora
							cMunic := Substr(SM0->M0_CODMUN,3,5)
						EndIf
					Else
						cMunic := ''
						SA1->(DbSetOrder(1))
						If SA1->(MsSeek(xFilial("SA1")+DT6->(DT6_CLIREM+DT6_LOJREM)))
							cMunic := SA1->A1_COD_MUN
							cUF    := SA1->A1_EST
						EndIf
					EndIf
				EndIf
			Else
				DTC->(DbSetOrder(1)) //DTC_FILIAL+DTC_FILORI+DTC_LOTNFC+DTC_CLIREM+DTC_LOJREM+DTC_CLIDES+DTC_LOJDES+DTC_SERVIC+DTC_CODPRO+DTC_NUMNFC+DTC_SERNFC+DTC_NUMSOL
				If DTC->(MsSeek(xFilial('DTC') + DT6->(DT6_FILORI + DT6_LOTNFC)))
					If !Empty(DTC->DTC_NUMSOL) .And. DTC->DTC_SELORI == "3" //--Origem e Local de Coleta
							//-- Posiciona na Ordem de Coleta
						DT5->(DbSetOrder (1))
						If DT5->(MsSeek (xFilial ("DT5")+DTC->DTC_FILORI+DTC->DTC_NUMSOL))
								//--Verifica se o Solicitante tem Sequencias de Endereco
							If Empty (DT5->DT5_SEQEND)
								DUE->(dbSetOrder(1))
								If !lDUESol
									DUE->(MsSeek(xFilial("DUE")+DT5->(DT5_DDD+DT5_TEL)))
								Else
									DUE->(MsSeek(xFilial("DUE")+DT5->DT5_CODSOL))
								EndIf
								cMunic	:= Iif(DUE->(FieldPos ("DUE_CODMUN"))>0, DUE->DUE_CODMUN, "")
								cUF		:= Iif(DUE->(FieldPos("DUE_EST"))>0, DUE->DUE_EST,"")
							Else
								If !lDUESol
									DUL->(dbSetOrder(1))
									DUL->(MsSeek(xFilial("DUL")+DT5->(DT5_DDD+DT5_TEL+DT5_SEQEND)))
								Else
									DUL->(dbSetOrder(3))
									DUL->(MsSeek(xFilial("DUL")+DT5->(DT5_CODSOL+DT5_SEQEND)))
								EndIf
								cMunic	:= Iif(DUL->(FieldPos("DUL_CODMUN"))>0, DUL->DUL_CODMUN, "")
								cUF		:= Iif(DUL->(FieldPos("DUL_EST"))>0, DUL->DUL_EST,"")
							EndIf
						EndIf
					ElseIf DTC->DTC_SELORI == "2" //--Origem Cliente Remetente
						cMunic := ''
						SA1->(DbSetOrder (1))
						If SA1->(MsSeek (xFilial ("SA1")+DT6->(DT6_CLIREM+DT6_LOJREM)))
							cMunic := SA1->A1_COD_MUN
							cUF    := SA1->A1_EST
						EndIf
					ElseIf DTC->DTC_SELORI == "1" //--Origem Transportadora
						cMunic := Substr(SM0->M0_CODMUN,3,5)
						cUF    := SM0->M0_ESTENT
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
Else
	SA1->(dbSeek(xFilial("SA1")+(cAliasSF3)->(F3_CLIEFOR+F3_LOJA)))
	cMunic	:=	SA1->A1_COD_MUN
	cUF    :=	SA1->A1_EST
EndIf
Return {cUF, cMunic}
