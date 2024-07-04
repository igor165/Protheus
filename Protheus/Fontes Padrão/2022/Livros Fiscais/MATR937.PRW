#INCLUDE "MATR937.ch"
#INCLUDE "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MATR937  ºAutor  ³Mary C. Hergert     º Data ³ 04/04/2005  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Demonstrativo de Estoque e de Operacoes com Cafe(DEOC)     º±±
±±º          ³ Minas Gerais                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigafis                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function MATR937

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao das variaveis                                      |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aWizard		:= {}         
Local aCFOPs		:= {}
Local lRet			:= .T.
Local aArea		:= GetArea()
Local Titulo    := OemToAnsi(STR0001)  //"Demonstrativo de Estoque e de Operacoes com Cafe (DEOC)"
Local cDesc1    := OemToAnsi(STR0002) 	//"Este relatório ira imprimir as movimentacoes e estoques de cafe"
Local cDesc2    := OemToAnsi(STR0003)  //"(beneficiado, em coco e torrado/moido)."
Local cDesc3    := ""
Local lDic      := .F. 					// Habilita/Desabilita Dicionario
Local lComp     := .F. 					// Habilita/Desabilita o Formato Comprimido/Expandido
Local lFiltro   := .F. 					// Habilita/Desabilita o Filtro
Local wnrel     := "MATR937"  			// Nome do Arquivo utilizado no Spool
Local nomeprog  := "MATR937"  			// nome do programa
Local cString	:= "SD2"
Local nPagina	:= 1
Local lVerpesssen := Iif(FindFunction("Verpesssen"),Verpesssen(),.T.)

Private Tamanho := "G"					// P/M/G
Private Limite  := 220 					// 80/132/220
Private cPerg   := "MTR937"				// Pergunta do Relatorio
Private aReturn := {STR0004,1,STR0060,1,2,1,"",1}	//"Zebrado"###"Administracao"

Private lEnd    := .F.					// Controle de cancelamento do relatorio
Private m_pag   := 1  					// Contador de Paginas
Private nLastKey:= 0  					// Controla o cancelamento da SetPrint e SetDefault

If lVerpesssen
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processa a Wizard com as configuracoes para o relatorio³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Matr937Wiz()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Envia para a SetPrint                                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	wnrel:=SetPrint(cString,wnrel,"",@titulo,cDesc1,cDesc2,cDesc3,lDic,,lComp,Tamanho,lFiltro,.F.)
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
±±ºPrograma  ³ ImpRel   ºAutor  ³Mary C. Hergert     º Data ³ 04/04/2005  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Imprime o Relatorio                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATR937                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                    


Static Function ImpRel(lEnd,wnRel,cString,Tamanho,nPagina)       

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Definicao de Variaveis                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local lRet 		:= .T.
	Local lQuery	:= .F.	
	Local lHelp		:= .F.
	Local lMov		:= .F.
	
	Local aCFOPs 	:= {}
	Local aTemp		:= MTR937Stru()
	Local aLay		:= R937LayOut()
	Local aWizard	:= {}
	Local aApur		:= {}
	Local aInvent	:= {}
	Local aEstabelec:= Array(03)
	Local aEmTerc	:= Array(03)
	Local aDeTercMG	:= Array(03)
	Local aDeTerc	:= Array(03)	
	
	Local cAliasSD2	:= "SD2"	
	Local cAliasSD1	:= "SD1"
	Local cTitulo	:= ""
	Local cMensagem	:= ""
	Local cHelp		:= ""
	Local cMunA1	:= GetNewPar("MV_DEOCA1","")
	Local cMunA2	:= GetNewPar("MV_DEOCA2","")
	Local cMunEmp	:= GetNewPar("MV_DEOCMUN","")
	Local cTipoA1	:= GetNewPar("MV_DEOCTA1","")
	Local cTipoA2	:= GetNewPar("MV_DEOCTA2","")
	Local cTipoB5	:= GetNewPar("MV_DEOCCLA","")
	Local cEstado	:= ""
	Local cTES		:= ""
	Local cCNPJ		:= ""           
	Local cICMSDif	:= ""                                        
	Local cTipo		:= ""
	Local cTipoCli	:= ""
	
	Local nMunA1	:= Iif(!Empty(cMunA1),SA1->(FieldPos((cMunA1))),0)
	Local nMunA2	:= Iif(!Empty(cMunA2),SA2->(FieldPos((cMunA2))),0)
	Local nTipoA1	:= Iif(!Empty(cTipoA1),SA1->(FieldPos((cTipoA1))),0)
	Local nTipoA2	:= Iif(!Empty(cTipoA2),SA2->(FieldPos((cTipoA2))),0)
	Local nTipoB5	:= Iif(!Empty(cTipoB5),SB5->(FieldPos((cTipoB5))),0)
	Local nMunic	:= 0
	Local nSacas	:= 0
	Local nKg		:= 0
	Local nLin		:= 0
	Local nTotSacas	:= 0
	Local nTotKG	:= 0
	Local nTotVal	:= 0
	Local nTotICMS	:= 0
	Local nRegsSD2	:= 0
	Local nRegsSD1	:= 0
	Local nRegsPrint:= 0 
	Local nX		:= 0     
	Local nBenefic 	:= 0
	Local nCoco		:= 0
	Local nTorrado	:= 0
	Local nTotBenefi:= 0
	Local nTotCoco	:= 0
	Local nTotTorra	:= 0
			
	Local dUltFec	:= cToD("  /  /  ")

	#IFDEF TOP
		Local aStruSD2	:= {}                                       
		Local aStruSD1	:= {}                                       
	#ELSE
		Local cChave	:= ""
	#ENDIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica a consistencia dos parametros da rotina³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(cMunA1) .Or. nMunA1 == 0
		cTitulo		:= STR0036 //"Parâmetro não existe"
		cMensagem	:= STR0037 //"O parâmetro MV_DEOCA1 não está definido no dicionário de dados ou o seu conteúdo é inválido. "
		cMensagem   += STR0038 //"Para que a rotina continue corretamente, "
		cMensagem	+= STR0039 //"será necessário respeitar a solução proposta abaixo."
		cHelp		:= STR0040 //"Incluir o parâmetro MV_DEOCA1 na tabela SX6 com a seguinte estrutura: "
		cHelp		+= STR0041 //"<campo da tabela SA1 que indica o código da município>"
		cHelp		+= STR0042 //" Para maiores referências, consultar a documentação que acompanha a rotina."
		xMagHelpFis(cTitulo,cMensagem,cHelp)
		lHelp		:= .T.
	Endif

	If Empty(cMunA2) .Or. nMunA2 == 0
		cTitulo		:= STR0036 //"Parâmetro não existe"
		cMensagem	:= STR0043 //"O parâmetro MV_DEOCA2 não está definido no dicionário de dados ou o seu conteúdo é inválido. "
		cMensagem   += STR0038 //"Para que a rotina continue corretamente, "
		cMensagem	+= STR0039 //"será necessário respeitar a solução proposta abaixo."
		cHelp		:= STR0044 //"Incluir o parâmetro MV_DEOCA2 na tabela SX6 com a seguinte estrutura: "
		cHelp		+= STR0061 //"<campo da tabela SA1 que indica o código da município>"
		cHelp		+= STR0042 //" Para maiores referências, consultar a documentação que acompanha a rotina."
		xMagHelpFis(cTitulo,cMensagem,cHelp)
		lHelp		:= .T.
	Endif

	If Empty(cMunEmp)
		cTitulo		:= STR0036 //"Parâmetro não existe"
		cMensagem	:= STR0045 //"O parâmetro MV_DEOCMUN não está definido no dicionário de dados ou o seu conteúdo é inválido. "
		cMensagem   += STR0038 //"Para que a rotina continue corretamente, "
		cMensagem	+= STR0039 //"será necessário respeitar a solução proposta abaixo."
		cHelp		:= STR0046 //"Incluir o parâmetro MV_DEOCMUN na tabela SX6 com a seguinte estrutura: "
		cHelp		+= STR0047 //"<código da município do contribuinte>"
		cHelp		+= STR0042 //" Para maiores referências, consultar a documentação que acompanha a rotina."
		xMagHelpFis(cTitulo,cMensagem,cHelp)
		lHelp		:= .T.		
	Endif                                  

	If Empty(cTipoA1) .Or. nTipoA1 == 0
		cTitulo		:= STR0036 //"Parâmetro não existe"
		cMensagem	:= STR0048 //"O parâmetro MV_DEOCTA1 não está definido no dicionário de dados ou o seu conteúdo é inválido. "
		cMensagem   += STR0038 //"Para que a rotina continue corretamente, "
		cMensagem	+= STR0039 //"será necessário respeitar a solução proposta abaixo."
		cHelp		:= STR0049 //"Incluir o parâmetro MV_DEOCTA1 na tabela SX6 com a seguinte estrutura: "
		cHelp		+= STR0050 //"<campo do SA1 que indica o tipo de atividade do cliente (Indústria/Exportador/Cooperativa)."
		cHelp		+= STR0042 //" Para maiores referências, consultar a documentação que acompanha a rotina."
		xMagHelpFis(cTitulo,cMensagem,cHelp)
		lHelp		:= .T.		
	Endif

	If Empty(cTipoA2) .Or. nTipoA2 == 0
		cTitulo		:= STR0036 //"Parâmetro não existe"
		cMensagem	:= STR0051 //"O parâmetro MV_DEOCTA2 não está definido no dicionário de dados ou o seu conteúdo é inválido. "
		cMensagem   += STR0038 //"Para que a rotina continue corretamente, "
		cMensagem	+= STR0039 //"será necessário respeitar a solução proposta abaixo."
		cHelp		:= STR0052 //"Incluir o parâmetro MV_DEOCTA2 na tabela SX6 com a seguinte estrutura: "
		cHelp		+= STR0053 //"<campo do SA2 que indica o tipo de atividade do fornecedor (Produtor Rural/Atacadista/Cooperativa/Indústria)."
		cHelp		+= STR0042 //" Para maiores referências, consultar a documentação que acompanha a rotina."
		xMagHelpFis(cTitulo,cMensagem,cHelp)
		lHelp		:= .T.		
	Endif

	If Empty(cTipoB5) .Or. nTipoB5 == 0
		cTitulo		:= STR0036 //"Parâmetro não existe"
		cMensagem	:= STR0054 //"O parâmetro MV_DEOCCLA não está definido no dicionário de dados ou o seu conteúdo é inválido. "
		cMensagem   += STR0038 //"Para que a rotina continue corretamente, "
		cMensagem	+= STR0039 //"será necessário respeitar a solução proposta abaixo."
		cHelp		:= STR0055 //"Incluir o parâmetro MV_DEOCCLA na tabela SX6 com a seguinte estrutura: "
		cHelp		+= STR0056 //"<campo do SB5 que indica o tipo café movimentado (Beneficiado/Em Coco/Torrado-Moído)."
		cHelp		+= STR0042 //" Para maiores referências, consultar a documentação que acompanha a rotina."
		xMagHelpFis(cTitulo,cMensagem,cHelp)
		lHelp		:= .T.		
	Endif
                          
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Somente efetua o processamento se todos os parametros estiverem corretos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lHelp
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Excluindo as tabelas temporarias ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		MTR937DelArq(aTemp)
		Return
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Le a wizard com as configuracoes dos CFOPs³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lRet := !xMagLeWiz("MTR937",@aWizard,.T.)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Painel numero 2³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//"01 - Exportação Direta: "
	Aadd(aCFOPs,Alltrim(aWizard[02][01]))
	//"02 - Remessa com fim específico de Exportação: "
	Aadd(aCFOPs,Alltrim(aWizard[02][02]))
	//"03 - Saídas Internas Tributadas: "
	Aadd(aCFOPs,Alltrim(aWizard[02][03]))
	//"04 - Saías Interestaduais Tributadas: "
	Aadd(aCFOPs,Alltrim(aWizard[02][04]))
	//"05 - Transferências Internas Diferidas: "
	Aadd(aCFOPs,Alltrim(aWizard[02][05]))
	//"06 - Remessas para Armazéns Gerais: "
	Aadd(aCFOPs,Alltrim(aWizard[02][06]))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Painel numero 3³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//"07 - Saidas Internas Diferidas - Indústrias: "
	Aadd(aCFOPs,Alltrim(aWizard[03][01]))
	//"08 - Saidas Internas Diferidas - Exportadores/Cooperativas: "
	Aadd(aCFOPs,Alltrim(aWizard[03][02]))
	//"09 - Quebras de Maquinacao / Eliminacao impurezas: "
	Aadd(aCFOPs,Alltrim(aWizard[03][03]))
	//"10 - Remessas para Beneficio / Industrializacao - Suspensao: "
	Aadd(aCFOPs,Alltrim(aWizard[03][04]))
	//"11 - Devolucoes de Compras: "
	Aadd(aCFOPs,Alltrim(aWizard[03][05]))
	//"12 - Outras Saídas: "
	Aadd(aCFOPs,Alltrim(aWizard[03][06]))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Painel numero 4³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//"13 - Aquisicoes com finalidade específica de Exportação: "
	Aadd(aCFOPs,Alltrim(aWizard[04][01]))
	//"14 - Aquisicoes internas tributadas: "    
	Aadd(aCFOPs,Alltrim(aWizard[04][02]))
	//"15 - Aquisicoes interestaduais tributadas: "
	Aadd(aCFOPs,Alltrim(aWizard[04][03]))
	//"16 - Recebimentos em Transferência do Estado: "
	Aadd(aCFOPs,Alltrim(aWizard[04][04]))
	//"17 - Retorno de Armazéns Gerais: "
	Aadd(aCFOPs,Alltrim(aWizard[04][05]))
	//"18 - Aquisições de Produtores Rurais - Diferidas: "
	Aadd(aCFOPs,Alltrim(aWizard[04][06]))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Painel numero 4³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//"19 - Aquisições de Atacadistas / Cooperativas - Diferidas: "
	Aadd(aCFOPs,Alltrim(aWizard[05][01]))
	//"20 - Retorno de Benefício / Industrialização - Suspensão: "
	Aadd(aCFOPs,Alltrim(aWizard[05][02]))
	//"21 - Devoluções de Vendas: "            
	Aadd(aCFOPs,Alltrim(aWizard[05][03]))
	//"22 - Outras Entradas: "                 
	Aadd(aCFOPs,Alltrim(aWizard[05][04]))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Painel numero 1³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//"23 - Data Inicial: "
	Aadd(aCFOPs,Alltrim(aWizard[01][01]))
	//"24 - Data Final: "
	Aadd(aCFOPs,Alltrim(aWizard[01][02]))
	//"25 - Agência Fazendária: "
	Aadd(aCFOPs,Alltrim(aWizard[01][03]))
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleciona Movimentacao de Saida                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	#IFDEF TOP
 		lQuery 		:= .T.   
		cAliasSD2	:= "SD2_DEOC"
		aStru  		:= SD2->(dbStruct())
		cQuery 		:= "SELECT SD2.D2_COD,SD2.D2_UM,SD2.D2_SEGUM,SD2.D2_QUANT,SD2.D2_TOTAL,SD2.D2_VALICM,SD2.D2_TES,"
		cQuery		+= "SD2.D2_CF,SD2.D2_CLIENTE,SD2.D2_LOJA,SD2.D2_EMISSAO,SD2.D2_QTSEGUM,SD2.D2_BASEICM,SD2.D2_TIPO,"
		cQuery		+= "SB5." + Alltrim(cTipoB5) + ",SF4.F4_LFICM,SF4.F4_ICMSDIF "
		cQuery 		+= "FROM " + RetSqlName("SD2") + " SD2, " 
		cQuery 		+= RetSqlName("SB5") + " SB5, " 
		cQuery 		+= RetSqlName("SF4") + " SF4, " 
		cQuery		+= "WHERE SD2.D2_FILIAL = '" + xFilial("SD2") + "' AND "    
		cQuery 		+= "SD2.D2_TIPO <> 'S' AND "
		cQuery 		+= "SUBSTRING(SD2.D2_CF,1,1) >= '5' AND "
		cQuery 		+= "SD2.D2_EMISSAO >= '" + aCFOPs[23] + "' AND "
		cQuery 		+= "SD2.D2_EMISSAO <= '" + aCFOPs[24] + "' AND "
		cQuery 		+= "SD2.D_E_L_E_T_ = ' ' AND "
		cQuery		+= "SB5.B5_FILIAL = '" + xFilial("SB5") + "' AND SB5.B5_COD = SD2.D2_COD AND "
		cQuery		+= "SB5." + Alltrim(cTipoB5) + " IN('1','2','3') AND "
		cQuery		+= "SF4.F4_FILIAL = '" + xFilial("SF4") + "' AND SF4.F4_CODIGO = SD2.D2_TES"		
	    cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD2,.T.,.T.)
		For nX := 1 To len(aStru)
			If aStru[nX][2] <> "C" 
			   TcSetField(cAliasSD2,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
			EndIf
		Next nX
	#Else
		dbSelectArea("SD2")
		nIndex	:=	RetIndex("SD2")
		cArqInd	:=	CriaTrab(NIL,.F.)
     	cChave	:=	"DTOS(D2_EMISSAO)+D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE,D2_LOJA"
		cFiltro :=	"D2_FILIAL == '" + xFilial() + "' .AND. D2_TIPO <> 'S' .AND. SUBSTR(D2_CF,1,1) >= '5' .AND. "
		cFiltro	+=	"DTOS(D2_EMISSAO) >= '" + aCFOPs[23] + "' .AND. DTOS(D2_EMISSAO) <= '" + aCFOPs[24] + "'"
		IndRegua(cAliasSD2,cArqInd,cChave,,cFiltro,STR0057) //"Selecionando Registros..."
	#ENDIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega os arquivos temporarios das movimentacoes de saida³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea(cAliasSD2)
	nRegsSD2 := LastRec()
	SetRegua(nRegsSD2)
	(cAliasSD2)->(DbGoTop())
	
	SA1->(dbSetOrder(1))
	SA2->(dbSetOrder(1))	
	SYA->(dbSetOrder(1))	
	SF4->(dbSetOrder(1))
	MOV->(dbSetOrder(1))
	QDC->(dbSetOrder(1))
	While !(cAliasSD2)->(Eof())
		
	    IncRegua()
		  
		If Interrupcao(@lEnd)
		    Exit
	 	Endif

		If !lQuery               
			// Complemento do Produto - tipo de café
			SB5->(dbSetOrder(1))
			If !SB5->(dbSeek(xFilial("SB5")+(cAliasSD2)->D2_COD))
				(cAliasSD2)->(dbSkip())
				Loop
			Endif	 
			
			If !(SB5->(FieldGet(nTipoB5)))$"123"
				(cAliasSD2)->(dbSkip())
				Loop
			Endif  
			
			// TES - Verifica o tipo de tributacao do ICMS	
			If !SF4->(dbSeek(xFilial("SF4")+(cAliasSD2)->D2_TES))
				(cAliasSD2)->(dbSkip())
				Loop
			Endif        
			
			cTipo 	:= SB5->&(cTipoB5)
			cTES 	:= SF4->F4_LFICM                                            
			cICMSDif:= SF4->F4_ICMSDIF
		Else
			cTipo	:= (cAliasSD2)->&(cTipoB5)
			cTES	:= (cAliasSD2)->F4_LFICM
			cICMSDif:= (cAliasSD2)->F4_ICMSDIF
		Endif      

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o produto esta classificado como cafe:³
		//³- Beneficiado: sacas de 60 kg                     ³
		//³- Em Coco: sacas de 40 kg                         ³
		//³- Torrado/Moido: por quilo                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nSacas	:= 0	
		nKg		:= 0
		If cTipo$"12"                       
			nSacas	:= (cAliasSD2)->D2_QUANT
		Else
			nKg		:= (cAliasSD2)->D2_QUANT
		Endif
		          
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica Cliente/Fornecedor³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (cAliasSD2)->D2_TIPO$"DB"
			If ! SA2->(dbSeek(xFilial("SA2")+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA))
				(cAliasSD2)->(dbSkip())
				Loop
			Endif
			nMunic 	:= Val(SA2->&(cMunA2))
			cEstado	:= SA2->A2_EST	 
			cCNPJ	:= SA2->A2_CGC
			cTipoCli:= SA2->&(cTipoA2)
			// Verifica o pais no caso das exportacoes
			If SubStr((cAliasSD2)->D2_CF,1,1) == "7"
				If !SYA->(dbSeek(xFilial("SYA")+SA2->A2_PAIS))
					(cAliasSD2)->(dbSkip())
					Loop
				Endif
			Endif
		Else
			If ! SA1->(dbSeek(xFilial("SA1")+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA))
				(cAliasSD2)->(dbSkip())
				Loop				
			Endif
			nMunic 	:= Val(SA1->&(cMunA1))
			cEstado	:= SA1->A1_EST 
			cCNPJ	:= SA1->A1_CGC             
			cTipoCli:= SA1->&(cTipoA1)
			// Verifica o pais no caso das exportacoes			
			If SubStr((cAliasSD2)->D2_CF,1,1) == "7"
				If !SYA->(dbSeek(xFilial("SYA")+SA1->A1_PAIS))
					(cAliasSD2)->(dbSkip())
					Loop
				Endif
			Endif
		Endif                 
		
    	//"01 - Exportação Direta: "
		If Alltrim((cAliasSD2)->D2_CF) $ aCFOPs[01]
	  		If !MOV->(dbSeek(1))
	  			RecLock("MOV",.T.)
				MOV->MOV_COD  	:= 1
				MOV->MOV_DESCR	:= STR0066 //"Exportacao Direta (Detalhar no campo C)"
				MOV->MOV_SACAS	:= nSacas
				MOV->MOV_KG		:= nKg
				MOV->MOV_VALOR	:= (cAliasSD2)->D2_TOTAL
				MOV->MOV_ICMS	:= (cAliasSD2)->D2_VALICM
	  		Else                  
	  			RecLock("MOV",.F.)
				MOV->MOV_SACAS	+= nSacas
				MOV->MOV_KG		+= nKg
				MOV->MOV_VALOR	+= (cAliasSD2)->D2_TOTAL
				MOV->MOV_ICMS	+= (cAliasSD2)->D2_VALICM
	  		Endif		        
	  		MsUnLock()
	  		If !QDC->(dbSeek(SYA->YA_CODGI))
	  			RecLock("QDC",.T.)
				QDC->QDC_CPAIS	:= SYA->YA_CODGI
				QDC->QDC_DESCR	:= SYA->YA_DESCR
				QDC->QDC_SACAS	:= nSacas
				QDC->QDC_KG		:= nKg
				QDC->QDC_VALOR	:= (cAliasSD2)->D2_TOTAL
	  		Else
	  			RecLock("QDC",.F.)
				QDC->QDC_SACAS	+= nSacas
				QDC->QDC_KG		+= nKg
				QDC->QDC_VALOR	+= (cAliasSD2)->D2_TOTAL
	  		Endif               
	  		MsUnLock()
		Endif
		
		//"02 - Remessa com fim específico de Exportação: "
		If Alltrim((cAliasSD2)->D2_CF) $ aCFOPs[02]
	  		If !MOV->(dbSeek(2))
	  			RecLock("MOV",.T.)
				MOV->MOV_COD  	:= 2
				MOV->MOV_DESCR	:= STR0067 //"Remessa com fim especifico de Exportacao (Detalhar no campo D)"
				MOV->MOV_SACAS	:= nSacas
				MOV->MOV_KG		:= nKg
				MOV->MOV_VALOR	:= (cAliasSD2)->D2_TOTAL
				MOV->MOV_ICMS	:= (cAliasSD2)->D2_VALICM
	  		Else                  
	  			RecLock("MOV",.F.)
				MOV->MOV_SACAS	+= nSacas
				MOV->MOV_KG		+= nKg
				MOV->MOV_VALOR	+= (cAliasSD2)->D2_TOTAL
				MOV->MOV_ICMS	+= (cAliasSD2)->D2_VALICM
	  		Endif		        
	  		MsUnLock()
	  		If !QDD->(dbSeek(cEstado+cCNPJ))
	  			RecLock("QDD",.T.)
				QDD->QDD_UF		:= cEstado
				QDD->QDD_CNPJ 	:= cCNPJ
				QDD->QDD_SACAS	:= nSacas
				QDD->QDD_KG		:= nKg
				QDD->QDD_VALOR	:= (cAliasSD2)->D2_TOTAL
	  		Else
	  			RecLock("QDD",.F.)
				QDD->QDD_SACAS	+= nSacas
				QDD->QDD_KG		+= nKg
				QDD->QDD_VALOR	+= (cAliasSD2)->D2_TOTAL
	  		Endif               
	  		MsUnLock()
		Endif

		//"03 - Saídas Internas Tributadas: "
		If Alltrim((cAliasSD2)->D2_CF) $ aCFOPs[03] .And. cTES == "T"
	  		If !MOV->(dbSeek(3))
	  			RecLock("MOV",.T.)
				MOV->MOV_COD  	:= 3
				MOV->MOV_DESCR	:= STR0068 //"Saidas internas tributadas"
				MOV->MOV_SACAS	:= nSacas
				MOV->MOV_KG		:= nKg
				MOV->MOV_VALOR	:= (cAliasSD2)->D2_TOTAL
				MOV->MOV_ICMS	:= (cAliasSD2)->D2_VALICM
	  		Else                  
	  			RecLock("MOV",.F.)
				MOV->MOV_SACAS	+= nSacas
				MOV->MOV_KG		+= nKg
				MOV->MOV_VALOR	+= (cAliasSD2)->D2_TOTAL
				MOV->MOV_ICMS	+= (cAliasSD2)->D2_VALICM
	  		Endif		        
	  		MsUnLock()
	  	Endif
		
		//"04 - Saías Interestaduais Tributadas: "
		If Alltrim((cAliasSD2)->D2_CF) $ aCFOPs[04] .And. cTES == "T"
	  		If !MOV->(dbSeek(4))
	  			RecLock("MOV",.T.)
				MOV->MOV_COD  	:= 4
				MOV->MOV_DESCR	:= STR0069 //"Saidas interestaduais tributadas (Detalhar no campo E)"
				MOV->MOV_SACAS	:= nSacas
				MOV->MOV_KG		:= nKg
				MOV->MOV_VALOR	:= (cAliasSD2)->D2_TOTAL
				MOV->MOV_ICMS	:= (cAliasSD2)->D2_VALICM
	  		Else                  
	  			RecLock("MOV",.F.)
				MOV->MOV_SACAS	+= nSacas
				MOV->MOV_KG		+= nKg
				MOV->MOV_VALOR	+= (cAliasSD2)->D2_TOTAL
				MOV->MOV_ICMS	+= (cAliasSD2)->D2_VALICM
	  		Endif		        
	  		MsUnLock()
	  		If !QDE->(dbSeek(cEstado))
	  			RecLock("QDE",.T.)
				QDE->QDE_UF		:= cEstado
				QDE->QDE_SACAS	:= nSacas
				QDE->QDE_KG		:= nKg
				QDE->QDE_BASE	:= (cAliasSD2)->D2_BASEICM
				QDE->QDE_ICMS	:= (cAliasSD2)->D2_VALICM
	  		Else
	  			RecLock("QDE",.F.)
				QDE->QDE_SACAS	+= nSacas
				QDE->QDE_KG		+= nKg
				QDE->QDE_BASE	+= (cAliasSD2)->D2_BASEICM
				QDE->QDE_ICMS	+= (cAliasSD2)->D2_VALICM
	  		Endif               
	  		MsUnLock()
	  	Endif
		
		//"05 - Transferências Internas Diferidas: "
		If Alltrim((cAliasSD2)->D2_CF) $ aCFOPs[05] .And. cICMSDif == "1"
	  		If !MOV->(dbSeek(5))
	  			RecLock("MOV",.T.)
				MOV->MOV_COD  	:= 5
				MOV->MOV_DESCR	:= STR0070 //"Transferencias internas diferidas (Detalhar no campo F)"
				MOV->MOV_SACAS	:= nSacas
				MOV->MOV_KG		:= nKg
				MOV->MOV_VALOR	:= (cAliasSD2)->D2_TOTAL
				MOV->MOV_ICMS	:= (cAliasSD2)->D2_VALICM
	  		Else                  
	  			RecLock("MOV",.F.)
				MOV->MOV_SACAS	+= nSacas
				MOV->MOV_KG		+= nKg
				MOV->MOV_VALOR	+= (cAliasSD2)->D2_TOTAL
				MOV->MOV_ICMS	+= (cAliasSD2)->D2_VALICM
	  		Endif		        
	  		MsUnLock()
	  		If !QDF->(dbSeek(cCNPJ))
	  			RecLock("QDF",.T.)
				QDF->QDF_CNPJ	:= cCNPJ  
				QDF->QDF_SACAS	:= nSacas
				QDF->QDF_KG		:= nKg
				QDF->QDF_VALOR	:= (cAliasSD2)->D2_TOTAL  
	  		Else
	  			RecLock("QDF",.F.)
				QDF->QDF_SACAS	+= nSacas
				QDF->QDF_KG		+= nKg
				QDF->QDF_VALOR	+= (cAliasSD2)->D2_TOTAL  
	  		Endif               
	  		MsUnLock()
		Endif

		//"06 - Remessas para Armazéns Gerais: "
		If Alltrim((cAliasSD2)->D2_CF) $ aCFOPs[06]
	  		If !MOV->(dbSeek(6))
	  			RecLock("MOV",.T.)
				MOV->MOV_COD  	:= 6
				MOV->MOV_DESCR	:= STR0018 // "Remessas para Armazens Gerais"
				MOV->MOV_SACAS	:= nSacas
				MOV->MOV_KG		:= nKg
				MOV->MOV_VALOR	:= (cAliasSD2)->D2_TOTAL
				MOV->MOV_ICMS	:= (cAliasSD2)->D2_VALICM
	  		Else                  
	  			RecLock("MOV",.F.)
				MOV->MOV_SACAS	+= nSacas
				MOV->MOV_KG		+= nKg
				MOV->MOV_VALOR	+= (cAliasSD2)->D2_TOTAL
				MOV->MOV_ICMS	+= (cAliasSD2)->D2_VALICM
	  		Endif		        
	  		MsUnLock()
	  	Endif

		//"07 - Saidas Internas Diferidas - Indústrias: "
		If Alltrim((cAliasSD2)->D2_CF) $ aCFOPs[07] .And. cICMSDif == "1" .And. cTipoCli == "1"
	  		If !MOV->(dbSeek(7))
	  			RecLock("MOV",.T.)
				MOV->MOV_COD  	:= 7
				MOV->MOV_DESCR	:= STR0071 //"Saidas internas diferidas com destino a Industrias"
				MOV->MOV_SACAS	:= nSacas
				MOV->MOV_KG		:= nKg
				MOV->MOV_VALOR	:= (cAliasSD2)->D2_TOTAL
				MOV->MOV_ICMS	:= (cAliasSD2)->D2_VALICM
	  		Else                  
	  			RecLock("MOV",.F.)
				MOV->MOV_SACAS	+= nSacas
				MOV->MOV_KG		+= nKg
				MOV->MOV_VALOR	+= (cAliasSD2)->D2_TOTAL
				MOV->MOV_ICMS	+= (cAliasSD2)->D2_VALICM
	  		Endif		        
	  		MsUnLock()
	  	Endif

		//"08 - Saidas Internas Diferidas - Exportadores/Cooperativas - do Municipio: "
		If Alltrim((cAliasSD2)->D2_CF) $ aCFOPs[08] .And. cICMSDif == "1" .And. cTipoCli$"23" .And. nMunic == Val(cMunEmp)
	  		If !MOV->(dbSeek(8))
	  			RecLock("MOV",.T.)
				MOV->MOV_COD  	:= 8
				MOV->MOV_DESCR	:= STR0072 //"Saidas internas diferidas com destino a Exportadores/Cooperativas do municipio"
				MOV->MOV_SACAS	:= nSacas
				MOV->MOV_KG		:= nKg
				MOV->MOV_VALOR	:= (cAliasSD2)->D2_TOTAL
				MOV->MOV_ICMS	:= (cAliasSD2)->D2_VALICM
	  		Else                  
	  			RecLock("MOV",.F.)
				MOV->MOV_SACAS	+= nSacas
				MOV->MOV_KG		+= nKg
				MOV->MOV_VALOR	+= (cAliasSD2)->D2_TOTAL
				MOV->MOV_ICMS	+= (cAliasSD2)->D2_VALICM
	  		Endif		        
	  		MsUnLock()
	  	Endif

		//"09 - Saidas Internas Diferidas - Exportadores/Cooperativas - de outros Municipios: "
		If Alltrim((cAliasSD2)->D2_CF) $ aCFOPs[08] .And. cICMSDif == "1" .And. cTipoCli$"23" .And. nMunic <> Val(cMunEmp)
	  		If !MOV->(dbSeek(9))
	  			RecLock("MOV",.T.)
				MOV->MOV_COD  	:= 9
				MOV->MOV_DESCR	:= STR0073 //"Saidas internas diferidas com destino a Exportadores/Cooperativas de outros municipios"
				MOV->MOV_SACAS	:= nSacas
				MOV->MOV_KG		:= nKg
				MOV->MOV_VALOR	:= (cAliasSD2)->D2_TOTAL
				MOV->MOV_ICMS	:= (cAliasSD2)->D2_VALICM
	  		Else                  
	  			RecLock("MOV",.F.)
				MOV->MOV_SACAS	+= nSacas
				MOV->MOV_KG		+= nKg
				MOV->MOV_VALOR	+= (cAliasSD2)->D2_TOTAL
				MOV->MOV_ICMS	+= (cAliasSD2)->D2_VALICM
	  		Endif		        
	  		MsUnLock()
	  	Endif

		//"10 - Quebras de Maquinacao / Eliminacao impurezas: "
		If Alltrim((cAliasSD2)->D2_CF) $ aCFOPs[09]
	  		If !MOV->(dbSeek(10))
	  			RecLock("MOV",.T.)
				MOV->MOV_COD  	:= 10
				MOV->MOV_DESCR	:= STR0074 //"Quebras de maquinacao / Eliminacao de impurezas"
				MOV->MOV_SACAS	:= nSacas
				MOV->MOV_KG		:= nKg
				MOV->MOV_VALOR	:= (cAliasSD2)->D2_TOTAL
				MOV->MOV_ICMS	:= (cAliasSD2)->D2_VALICM
	  		Else                  
	  			RecLock("MOV",.F.)
				MOV->MOV_SACAS	+= nSacas
				MOV->MOV_KG		+= nKg
				MOV->MOV_VALOR	+= (cAliasSD2)->D2_TOTAL
				MOV->MOV_ICMS	+= (cAliasSD2)->D2_VALICM
	  		Endif		        
	  		MsUnLock()
	  	Endif
		
		//"11 - Remessas para Beneficio / Industrializacao - Suspensao: "
		If Alltrim((cAliasSD2)->D2_CF) $ aCFOPs[10]
	  		If !MOV->(dbSeek(11))
	  			RecLock("MOV",.T.)
				MOV->MOV_COD  	:= 11
				MOV->MOV_DESCR	:= STR0075 //"Remessas para beneficio / Industrializacao - Suspensao"
				MOV->MOV_SACAS	:= nSacas
				MOV->MOV_KG		:= nKg
				MOV->MOV_VALOR	:= (cAliasSD2)->D2_TOTAL
				MOV->MOV_ICMS	:= (cAliasSD2)->D2_VALICM
	  		Else                  
	  			RecLock("MOV",.F.)
				MOV->MOV_SACAS	+= nSacas
				MOV->MOV_KG		+= nKg
				MOV->MOV_VALOR	+= (cAliasSD2)->D2_TOTAL
				MOV->MOV_ICMS	+= (cAliasSD2)->D2_VALICM
	  		Endif		        
	  		MsUnLock()
	  	Endif

		//"12 - Devolucoes de Compras: "
		If Alltrim((cAliasSD2)->D2_CF) $ aCFOPs[11]
	  		If !MOV->(dbSeek(12))
	  			RecLock("MOV",.T.)
				MOV->MOV_COD  	:= 12
				MOV->MOV_DESCR	:= STR0023 //"Devolucoes de Compras"
				MOV->MOV_SACAS	:= nSacas
				MOV->MOV_KG		:= nKg
				MOV->MOV_VALOR	:= (cAliasSD2)->D2_TOTAL
				MOV->MOV_ICMS	:= (cAliasSD2)->D2_VALICM
	  		Else                  
	  			RecLock("MOV",.F.)
				MOV->MOV_SACAS	+= nSacas
				MOV->MOV_KG		+= nKg
				MOV->MOV_VALOR	+= (cAliasSD2)->D2_TOTAL
				MOV->MOV_ICMS	+= (cAliasSD2)->D2_VALICM
	  		Endif		        
	  		MsUnLock()
	  	Endif

		//"13 - Outras Saídas: "
		If Alltrim((cAliasSD2)->D2_CF) $ aCFOPs[12]
	  		If !MOV->(dbSeek(13))
	  			RecLock("MOV",.T.)
				MOV->MOV_COD  	:= 13
				MOV->MOV_DESCR	:= STR0024 //"Outras Saidas"
				MOV->MOV_SACAS	:= nSacas
				MOV->MOV_KG		:= nKg
				MOV->MOV_VALOR	:= (cAliasSD2)->D2_TOTAL
				MOV->MOV_ICMS	:= (cAliasSD2)->D2_VALICM
	  		Else                  
	  			RecLock("MOV",.F.)
				MOV->MOV_SACAS	+= nSacas
				MOV->MOV_KG		+= nKg
				MOV->MOV_VALOR	+= (cAliasSD2)->D2_TOTAL
				MOV->MOV_ICMS	+= (cAliasSD2)->D2_VALICM
	  		Endif		        
	  		MsUnLock()
	  	Endif

		(cAliasSD2)->(dbSkip())

    Enddo
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleciona Movimentacao de Entrada                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	#IFDEF TOP
 		lQuery 		:= .T.   
		cAliasSD1	:= "SD1_DEOC"
		aStru  		:= SD1->(dbStruct())
		cQuery 		:= "SELECT SD1.D1_COD,SD1.D1_UM,SD1.D1_SEGUM,SD1.D1_QUANT,SD1.D1_TOTAL,SD1.D1_VALICM,SD1.D1_TES,"
		cQuery		+= "SD1.D1_CF,SD1.D1_FORNECE,SD1.D1_LOJA,SD1.D1_EMISSAO,SD1.D1_QTSEGUM,SD1.D1_BASEICM,SD1.D1_TIPO,"
		cQuery		+= "SB5." + Alltrim(cTipoB5) + ",SF4.F4_LFICM,SF4.F4_ICMSDIF "
		cQuery 		+= "FROM " + RetSqlName("SD1") + " SD1, " 
		cQuery 		+= RetSqlName("SB5") + " SB5, " 
		cQuery 		+= RetSqlName("SF4") + " SF4, " 
		cQuery		+= "WHERE SD1.D1_FILIAL = '" + xFilial("SD1") + "' AND "    
		cQuery 		+= "SD1.D1_TIPO <> 'S' AND "
		cQuery 		+= "SUBSTRING(SD1.D1_CF,1,1) < '5' AND "
		cQuery 		+= "SD1.D1_EMISSAO >= '" + aCFOPs[23] + "' AND "
		cQuery 		+= "SD1.D1_EMISSAO <= '" + aCFOPs[24] + "' AND "
		cQuery 		+= "SD1.D_E_L_E_T_ = ' ' AND "
		cQuery		+= "SB5.B5_FILIAL = '" + xFilial("SB5") + "' AND SB5.B5_COD = SD1.D1_COD AND "
		cQuery		+= "SB5." + Alltrim(cTipoB5) + " IN('1','2','3') AND "
		cQuery		+= "SF4.F4_FILIAL = '" + xFilial("SF4") + "' AND SF4.F4_CODIGO = SD1.D1_TES"		
	    cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD1,.T.,.T.)
		For nX := 1 To len(aStru)
			If aStru[nX][2] <> "C"
			   TcSetField(cAliasSD1,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
			EndIf
		Next nX
	#Else
		dbSelectArea("SD1")
		nIndex	:=	RetIndex("SD1")
		cArqInd	:=	CriaTrab(NIL,.F.)
     	cChave	:=	"DTOS(D1_EMISSAO)+D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE,D1_LOJA"
		cFiltro :=	"D1_FILIAL == '" + xFilial() + "' .AND. D1_TIPO <> 'S' .AND. SUBSTR(D1_CF,1,1) < '5' .AND. "
		cFiltro	+=	"DTOS(D1_EMISSAO) >= '" + aCFOPs[23] + "' .AND. DTOS(D1_EMISSAO) <= '" + aCFOPs[24] + "'"
		IndRegua(cAliasSD1,cArqInd,cChave,,cFiltro,STR0057) //"Selecionando Registros..."
	#ENDIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega os arquivos temporarios das movimentacoes de entrada³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea(cAliasSD1)
	nRegsSD1 := LastRec()
	SetRegua(nRegsSD1)
	(cAliasSD1)->(DbGoTop())

	SA1->(dbSetOrder(1))
	SA2->(dbSetOrder(1))	
	SF4->(dbSetOrder(1))
	MOV->(dbSetOrder(1))
	While !(cAliasSD1)->(Eof())
		
	    IncRegua()
	  
		If Interrupcao(@lEnd)
		    Exit
	 	Endif

		If !lQuery               
			// Complemento do Produto - tipo de café
			SB5->(dbSetOrder(1))
			If !SB5->(dbSeek(xFilial("SB5")+(cAliasSD1)->D1_COD))
				(cAliasSD1)->(dbSkip())
				Loop
			Endif	 
			
			If !(SB5->(FieldGet(nTipoB5)))$"123"
				(cAliasSD1)->(dbSkip())
				Loop
			Endif  
			
			// TES - Verifica o tipo de tributacao do ICMS	
			If !SF4->(dbSeek(xFilial("SF4")+(cAliasSD1)->D1_TES))
				(cAliasSD1)->(dbSkip())
				Loop
			Endif        
			
			cTipo 	:= SB5->&(cTipoB5)
			cTES 	:= SF4->F4_LFICM                                            
			cICMSDif:= SF4->F4_ICMSDIF
		Else
			cTipo	:= (cAliasSD1)->&(cTipoB5)
			cTES	:= (cAliasSD1)->F4_LFICM
			cICMSDif:= (cAliasSD1)->F4_ICMSDIF
		Endif      

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o produto esta classificado como cafe:³
		//³- Beneficiado: sacas de 60 kg                     ³
		//³- Em Coco: sacas de 40 kg                         ³
		//³- Torrado/Moido: por quilo                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nSacas	:= 0	
		nKg		:= 0
		If cTipo$"12"                       
			nSacas	:= (cAliasSD1)->D1_QUANT
		Else
			nKg		:= (cAliasSD1)->D1_QUANT
		Endif
		          
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica Fornecedor/Cliente³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !(cAliasSD1)->D1_TIPO$"DB"
			If ! SA2->(dbSeek(xFilial("SA2")+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA))
				(cAliasSD1)->(dbSkip())
				Loop
			Endif
			nMunic 	:= Val(SA2->&(cMunA2))
			cEstado	:= SA2->A2_EST	 
			cCNPJ	:= SA2->A2_CGC
			cTipoCli:= SA2->&(cTipoA2)
		Else
			If ! SA1->(dbSeek(xFilial("SA1")+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA))
				(cAliasSD1)->(dbSkip())
				Loop				
			Endif
			nMunic 	:= Val(SA1->&(cMunA1))
			cEstado	:= SA1->A1_EST 
			cCNPJ	:= SA1->A1_CGC             
			cTipoCli:= SA1->&(cTipoA1)
		Endif                 
		
		//"14 - Aquisicoes com finalidade específica de Exportação: "
		If Alltrim((cAliasSD1)->D1_CF) $ aCFOPs[13]
	  		If !MOV->(dbSeek(14))
	  			RecLock("MOV",.T.)
				MOV->MOV_COD  	:= 14
				MOV->MOV_DESCR	:= STR0076 //"Aquisicoes com finalidade especifica de Exportacao (Detalhar no campo G)"
				MOV->MOV_SACAS	:= nSacas
				MOV->MOV_KG		:= nKg
				MOV->MOV_VALOR	:= (cAliasSD1)->D1_TOTAL
				MOV->MOV_ICMS	:= (cAliasSD1)->D1_VALICM
	  		Else                  
	  			RecLock("MOV",.F.)
				MOV->MOV_SACAS	+= nSacas
				MOV->MOV_KG		+= nKg
				MOV->MOV_VALOR	+= (cAliasSD1)->D1_TOTAL
				MOV->MOV_ICMS	+= (cAliasSD1)->D1_VALICM
	  		Endif		        
	  		MsUnLock() 
	  		If !QDG->(dbSeek(cEstado+cCNPJ))
	  			RecLock("QDG",.T.)
				QDG->QDG_UF		:= cEstado
				QDG->QDG_CNPJ 	:= cCNPJ
				QDG->QDG_SACAS	:= nSacas
				QDG->QDG_KG		:= nKg
				QDG->QDG_VALOR	:= (cAliasSD1)->D1_TOTAL
	  		Else
	  			RecLock("QDG",.F.)
				QDG->QDG_SACAS	+= nSacas
				QDG->QDG_KG		+= nKg
				QDG->QDG_VALOR	+= (cAliasSD1)->D1_TOTAL
	  		Endif               
	  		MsUnLock()
		Endif
		
		//"15 - Aquisicoes internas tributadas: "    
		If Alltrim((cAliasSD1)->D1_CF) $ aCFOPs[14] .And. cTES == "T"
	  		If !MOV->(dbSeek(15))
	  			RecLock("MOV",.T.)
				MOV->MOV_COD  	:= 15
				MOV->MOV_DESCR	:= STR0077 //"Aquisicoes internas tributadas"
				MOV->MOV_SACAS	:= nSacas
				MOV->MOV_KG		:= nKg
				MOV->MOV_VALOR	:= (cAliasSD1)->D1_TOTAL
				MOV->MOV_ICMS	:= (cAliasSD1)->D1_VALICM
	  		Else                  
	  			RecLock("MOV",.F.)
				MOV->MOV_SACAS	+= nSacas
				MOV->MOV_KG		+= nKg
				MOV->MOV_VALOR	+= (cAliasSD1)->D1_TOTAL
				MOV->MOV_ICMS	+= (cAliasSD1)->D1_VALICM
	  		Endif		        
	  		MsUnLock()
	  	Endif
		
		//"16 - Aquisicoes interestaduais tributadas: "
		If Alltrim((cAliasSD1)->D1_CF) $ aCFOPs[15] .And. cTES == "T"
	  		If !MOV->(dbSeek(16))
	  			RecLock("MOV",.T.)
				MOV->MOV_COD  	:= 16
				MOV->MOV_DESCR	:= STR0078 //"Aquisicoes interestaduais tributadas (Detalhar no campo H)"
				MOV->MOV_SACAS	:= nSacas
				MOV->MOV_KG		:= nKg
				MOV->MOV_VALOR	:= (cAliasSD1)->D1_TOTAL
				MOV->MOV_ICMS	:= (cAliasSD1)->D1_VALICM
	  		Else                  
	  			RecLock("MOV",.F.)
				MOV->MOV_SACAS	+= nSacas
				MOV->MOV_KG		+= nKg
				MOV->MOV_VALOR	+= (cAliasSD1)->D1_TOTAL
				MOV->MOV_ICMS	+= (cAliasSD1)->D1_VALICM
	  		Endif		        
	  		MsUnLock()
	  		If !QDH->(dbSeek(cEstado))
	  			RecLock("QDH",.T.)
				QDH->QDH_UF		:= cEstado
				QDH->QDH_SACAS	:= nSacas
				QDH->QDH_KG		:= nKg
				QDH->QDH_BASE	:= (cAliasSD1)->D1_BASEICM
				QDH->QDH_ICMS	:= (cAliasSD1)->D1_VALICM
	  		Else
	  			RecLock("QDH",.F.)
				QDH->QDH_SACAS	+= nSacas
				QDH->QDH_KG		+= nKg
				QDH->QDH_BASE	+= (cAliasSD1)->D1_BASEICM
				QDH->QDH_ICMS	+= (cAliasSD1)->D1_VALICM
	  		Endif               
	  		MsUnLock()
	  	Endif
		
		//"17 - Recebimentos em Transferência do Estado: "
		If Alltrim((cAliasSD1)->D1_CF) $ aCFOPs[16]
	  		If !MOV->(dbSeek(17))
	  			RecLock("MOV",.T.)
				MOV->MOV_COD  	:= 17
				MOV->MOV_DESCR	:= STR0079 //"Recebimentos em Transferencia do Estado (Detalhar no campo I)"
				MOV->MOV_SACAS	:= nSacas
				MOV->MOV_KG		:= nKg
				MOV->MOV_VALOR	:= (cAliasSD1)->D1_TOTAL
				MOV->MOV_ICMS	:= (cAliasSD1)->D1_VALICM
	  		Else                  
	  			RecLock("MOV",.F.)
				MOV->MOV_SACAS	+= nSacas
				MOV->MOV_KG		+= nKg
				MOV->MOV_VALOR	+= (cAliasSD1)->D1_TOTAL
				MOV->MOV_ICMS	+= (cAliasSD1)->D1_VALICM
	  		Endif		        
	  		MsUnLock()
	  		If !QDI->(dbSeek(cCNPJ))
	  			RecLock("QDI",.T.)
				QDI->QDI_CNPJ	:= cCNPJ  
				QDI->QDI_SACAS	:= nSacas
				QDI->QDI_KG		:= nKg
				QDI->QDI_VALOR	:= (cAliasSD1)->D1_TOTAL  
	  		Else
	  			RecLock("QDI",.F.)
				QDI->QDI_SACAS	+= nSacas
				QDI->QDI_KG		+= nKg
				QDI->QDI_VALOR	+= (cAliasSD1)->D1_TOTAL  
	  		Endif               
	  		MsUnLock()
		Endif

		//"18 - Retorno de Armazéns Gerais: "
		If Alltrim((cAliasSD1)->D1_CF) $ aCFOPs[17]
	  		If !MOV->(dbSeek(18))
	  			RecLock("MOV",.T.)
				MOV->MOV_COD  	:= 18
				MOV->MOV_DESCR	:= STR0030 //"Retorno de Armazens Gerais: "
				MOV->MOV_SACAS	:= nSacas
				MOV->MOV_KG		:= nKg
				MOV->MOV_VALOR	:= (cAliasSD1)->D1_TOTAL
				MOV->MOV_ICMS	:= (cAliasSD1)->D1_VALICM
	  		Else                  
	  			RecLock("MOV",.F.)
				MOV->MOV_SACAS	+= nSacas
				MOV->MOV_KG		+= nKg
				MOV->MOV_VALOR	+= (cAliasSD1)->D1_TOTAL
				MOV->MOV_ICMS	+= (cAliasSD1)->D1_VALICM
	  		Endif		        
	  		MsUnLock()
	  	Endif

		//"19 - Aquisicoes de Produtores Rurais do municipio - diferidas"
		If Alltrim((cAliasSD1)->D1_CF) $ aCFOPs[18] .And. cICMSDif == "1" .And. cTipoCli == "1" .And. nMunic == Val(cMunEmp)
	  		If !MOV->(dbSeek(19))
	  			RecLock("MOV",.T.)
				MOV->MOV_COD  	:= 19
				MOV->MOV_DESCR	:= STR0080 //"Aquisicoes de Produtores Rurais do municipio - diferidas"
				MOV->MOV_SACAS	:= nSacas
				MOV->MOV_KG		:= nKg
				MOV->MOV_VALOR	:= (cAliasSD1)->D1_TOTAL
				MOV->MOV_ICMS	:= (cAliasSD1)->D1_VALICM
	  		Else                  
	  			RecLock("MOV",.F.)
				MOV->MOV_SACAS	+= nSacas
				MOV->MOV_KG		+= nKg
				MOV->MOV_VALOR	+= (cAliasSD1)->D1_TOTAL
				MOV->MOV_ICMS	+= (cAliasSD1)->D1_VALICM
	  		Endif		        
	  		MsUnLock()
	  	Endif

		//"20 - Aquisicoes de Produtores Rurais de outros municipios - diferidas"
		If Alltrim((cAliasSD1)->D1_CF) $ aCFOPs[18] .And. cICMSDif == "1" .And. cTipoCli == "1" .And. nMunic <> Val(cMunEmp)
	  		If !MOV->(dbSeek(20))
	  			RecLock("MOV",.T.)
				MOV->MOV_COD  	:= 20
				MOV->MOV_DESCR	:= STR0081 //"Aquisicoes de Produtores Rurais de outros municipios - diferidas"
				MOV->MOV_SACAS	:= nSacas
				MOV->MOV_KG		:= nKg
				MOV->MOV_VALOR	:= (cAliasSD1)->D1_TOTAL
				MOV->MOV_ICMS	:= (cAliasSD1)->D1_VALICM
	  		Else                  
	  			RecLock("MOV",.F.)
				MOV->MOV_SACAS	+= nSacas
				MOV->MOV_KG		+= nKg
				MOV->MOV_VALOR	+= (cAliasSD1)->D1_TOTAL
				MOV->MOV_ICMS	+= (cAliasSD1)->D1_VALICM
	  		Endif		        
	  		MsUnLock()
	  	Endif

		//"21 - Aquisicoes de Atacadistas/Cooperativas do municipio - diferidas"
		If Alltrim((cAliasSD1)->D1_CF) $ aCFOPs[19] .And. cICMSDif == "1" .And. cTipoCli $ "23" .And. nMunic == Val(cMunEmp)
	  		If !MOV->(dbSeek(21))
	  			RecLock("MOV",.T.)
				MOV->MOV_COD  	:= 21
				MOV->MOV_DESCR	:= STR0082 //"Aquisicoes de Atacadistas/Cooperativas do municipio - diferidas"
				MOV->MOV_SACAS	:= nSacas
				MOV->MOV_KG		:= nKg
				MOV->MOV_VALOR	:= (cAliasSD1)->D1_TOTAL
				MOV->MOV_ICMS	:= (cAliasSD1)->D1_VALICM
	  		Else                  
	  			RecLock("MOV",.F.)
				MOV->MOV_SACAS	+= nSacas
				MOV->MOV_KG		+= nKg
				MOV->MOV_VALOR	+= (cAliasSD1)->D1_TOTAL
				MOV->MOV_ICMS	+= (cAliasSD1)->D1_VALICM
	  		Endif		        
	  		MsUnLock()
	  	Endif

		//"22 - Aquisicoes de Atacadistas/Cooperativas de outros municipios - diferidas"
		If Alltrim((cAliasSD1)->D1_CF) $ aCFOPs[19] .And. cICMSDif == "1" .And. cTipoCli $ "23" .And. nMunic <> Val(cMunEmp)
	  		If !MOV->(dbSeek(22))
	  			RecLock("MOV",.T.)
				MOV->MOV_COD  	:= 22
				MOV->MOV_DESCR	:= STR0083 //"Aquisicoes de Atacadistas/Cooperativas de outros municipios - diferidas"
				MOV->MOV_SACAS	:= nSacas
				MOV->MOV_KG		:= nKg
				MOV->MOV_VALOR	:= (cAliasSD1)->D1_TOTAL
				MOV->MOV_ICMS	:= (cAliasSD1)->D1_VALICM
	  		Else                  
	  			RecLock("MOV",.F.)
				MOV->MOV_SACAS	+= nSacas
				MOV->MOV_KG		+= nKg
				MOV->MOV_VALOR	+= (cAliasSD1)->D1_TOTAL
				MOV->MOV_ICMS	+= (cAliasSD1)->D1_VALICM
	  		Endif		        
	  		MsUnLock()
	  	Endif

		//"23 - Retorno de Benecifio / Industrializacao - Suspensao"
		If Alltrim((cAliasSD1)->D1_CF) $ aCFOPs[20]
	  		If !MOV->(dbSeek(23))
	  			RecLock("MOV",.T.)
				MOV->MOV_COD  	:= 23
				MOV->MOV_DESCR	:= STR0084 //"Retorno de Benecifio / Industrializacao - Suspensao"
				MOV->MOV_SACAS	:= nSacas
				MOV->MOV_KG		:= nKg
				MOV->MOV_VALOR	:= (cAliasSD1)->D1_TOTAL
				MOV->MOV_ICMS	:= (cAliasSD1)->D1_VALICM
	  		Else                  
	  			RecLock("MOV",.F.)
				MOV->MOV_SACAS	+= nSacas
				MOV->MOV_KG		+= nKg
				MOV->MOV_VALOR	+= (cAliasSD1)->D1_TOTAL
				MOV->MOV_ICMS	+= (cAliasSD1)->D1_VALICM
	  		Endif		        
	  		MsUnLock()
	  	Endif

		//"21 - Devolucoes de Vendas: "
		If Alltrim((cAliasSD1)->D1_CF) $ aCFOPs[21]
	  		If !MOV->(dbSeek(24))
	  			RecLock("MOV",.T.)
				MOV->MOV_COD  	:= 24
				MOV->MOV_DESCR	:= STR0034 //"Devolucoes de Vendas: "
				MOV->MOV_SACAS	:= nSacas
				MOV->MOV_KG		:= nKg
				MOV->MOV_VALOR	:= (cAliasSD1)->D1_TOTAL
				MOV->MOV_ICMS	:= (cAliasSD1)->D1_VALICM
	  		Else                  
	  			RecLock("MOV",.F.)
				MOV->MOV_SACAS	+= nSacas
				MOV->MOV_KG		+= nKg
				MOV->MOV_VALOR	+= (cAliasSD1)->D1_TOTAL
				MOV->MOV_ICMS	+= (cAliasSD1)->D1_VALICM
	  		Endif		        
	  		MsUnLock()
	  	Endif

		//"25 - Outras Entradas"
		If Alltrim((cAliasSD1)->D1_CF) $ aCFOPs[22]
	  		If !MOV->(dbSeek(25))
	  			RecLock("MOV",.T.)
				MOV->MOV_COD  	:= 25
				MOV->MOV_DESCR	:= STR0035 //"Outras Entradas: "  
				MOV->MOV_SACAS	:= nSacas
				MOV->MOV_KG		:= nKg
				MOV->MOV_VALOR	:= (cAliasSD1)->D1_TOTAL
				MOV->MOV_ICMS	:= (cAliasSD1)->D1_VALICM
	  		Else                  
	  			RecLock("MOV",.F.)
				MOV->MOV_SACAS	+= nSacas
				MOV->MOV_KG		+= nKg
				MOV->MOV_VALOR	+= (cAliasSD1)->D1_TOTAL
				MOV->MOV_ICMS	+= (cAliasSD1)->D1_VALICM
	  		Endif		        
	  		MsUnLock()
	  	Endif

		(cAliasSD1)->(dbSkip())

    Enddo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Insere os movimentos não processados³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !MOV->(dbSeek(1))
		RecLock("MOV",.T.)
		MOV->MOV_COD  	:= 1
		MOV->MOV_DESCR	:= STR0066 //"Exportacao Direta (Detalhar no campo C)"
		MsUnLock()
	Endif
	If !MOV->(dbSeek(2))
		RecLock("MOV",.T.)
		MOV->MOV_COD  	:= 2
		MOV->MOV_DESCR	:= STR0067 //"Remessa com fim especifico de Exportacao (Detalhar no campo D)"
		MsUnLock()
	Endif		        
	If !MOV->(dbSeek(3))
		RecLock("MOV",.T.)
		MOV->MOV_COD  	:= 3
		MOV->MOV_DESCR	:= STR0068 //"Saidas internas tributadas"
	Endif		        
	If !MOV->(dbSeek(4))
		RecLock("MOV",.T.)
		MOV->MOV_COD  	:= 4
		MOV->MOV_DESCR	:= STR0069 //"Saidas interestaduais tributadas (Detalhar no campo E)"
	Endif		        
	If !MOV->(dbSeek(5))
		RecLock("MOV",.T.)
		MOV->MOV_COD  	:= 5
		MOV->MOV_DESCR	:= STR0070 //"Transferencias internas diferidas (Detalhar no campo F)"
	Endif		        
	If !MOV->(dbSeek(6))
		RecLock("MOV",.T.)
		MOV->MOV_COD  	:= 6
		MOV->MOV_DESCR	:= STR0018 // "Remessas para Armazens Gerais"
	Endif		        
	If !MOV->(dbSeek(7))
		RecLock("MOV",.T.)
		MOV->MOV_COD  	:= 7
		MOV->MOV_DESCR	:= STR0071 //"Saidas internas diferidas com destino a Industrias"
	Endif		        
	If !MOV->(dbSeek(8))
		RecLock("MOV",.T.)
		MOV->MOV_COD  	:= 8
		MOV->MOV_DESCR	:= STR0072 //"Saidas internas diferidas com destino a Exportadores/Cooperativas do municipio"
	Endif		        
	If !MOV->(dbSeek(9))
		RecLock("MOV",.T.)
		MOV->MOV_COD  	:= 9
		MOV->MOV_DESCR	:= STR0073 //"Saidas internas diferidas com destino a Exportadores/Cooperativas de outros municipios"
	Endif		        
	If !MOV->(dbSeek(10))
		RecLock("MOV",.T.)
		MOV->MOV_COD  	:= 10
		MOV->MOV_DESCR	:= STR0074 //"Quebras de maquinacao / Eliminacao de impurezas"
	Endif		        
	If !MOV->(dbSeek(11))
		RecLock("MOV",.T.)
		MOV->MOV_COD  	:= 11
		MOV->MOV_DESCR	:= STR0075 //"Remessas para beneficio / Industrializacao - Suspensao"
	Endif		        
	If !MOV->(dbSeek(12))
		RecLock("MOV",.T.)
		MOV->MOV_COD  	:= 12
		MOV->MOV_DESCR	:= STR0023 //"Devolucoes de Compras"
	Endif		        
	If !MOV->(dbSeek(13))
		RecLock("MOV",.T.)
		MOV->MOV_COD  	:= 13
		MOV->MOV_DESCR	:= STR0024 //"Outras Saidas"
	Endif		        
	If !MOV->(dbSeek(14))
		RecLock("MOV",.T.)
		MOV->MOV_COD  	:= 14
		MOV->MOV_DESCR	:= STR0076 //"Aquisicoes com finalidade especifica de Exportacao (Detalhar no campo G)"
	Endif		        
	If !MOV->(dbSeek(15))
		RecLock("MOV",.T.)
		MOV->MOV_COD  	:= 15
		MOV->MOV_DESCR	:= STR0077 //"Aquisicoes internas tributadas"
	Endif		        
	If !MOV->(dbSeek(16))
		RecLock("MOV",.T.)
		MOV->MOV_COD  	:= 16
		MOV->MOV_DESCR	:= STR0078 //"Aquisicoes interestaduais tributadas (Detalhar no campo H)"
	Endif		        
	If !MOV->(dbSeek(17))
		RecLock("MOV",.T.)
		MOV->MOV_COD  	:= 17
		MOV->MOV_DESCR	:= STR0079 //"Recebimentos em Transferencia do Estado (Detalhar no campo I)"
	Endif		        
	If !MOV->(dbSeek(18))
		RecLock("MOV",.T.)
		MOV->MOV_COD  	:= 18
		MOV->MOV_DESCR	:= STR0030 //"Retorno de Armazens Gerais: "
	Endif		        
	If !MOV->(dbSeek(19))
		RecLock("MOV",.T.)
		MOV->MOV_COD  	:= 19
		MOV->MOV_DESCR	:= STR0080 //"Aquisicoes de Produtores Rurais do municipio - diferidas"
	Endif		        
	If !MOV->(dbSeek(20))
		RecLock("MOV",.T.)
		MOV->MOV_COD  	:= 20
		MOV->MOV_DESCR	:= STR0081 //"Aquisicoes de Produtores Rurais de outros municipios - diferidas"
	Endif		        
	If !MOV->(dbSeek(21))
		RecLock("MOV",.T.)
		MOV->MOV_COD  	:= 21
		MOV->MOV_DESCR	:= STR0082 //"Aquisicoes de Atacadistas/Cooperativas do municipio - diferidas"
	Endif		        
	If !MOV->(dbSeek(22))
		RecLock("MOV",.T.)
		MOV->MOV_COD  	:= 22
		MOV->MOV_DESCR	:= STR0083 //"Aquisicoes de Atacadistas/Cooperativas de outros municipios - diferidas"
	Endif		        
	If !MOV->(dbSeek(23))
		RecLock("MOV",.T.)
		MOV->MOV_COD  	:= 23
		MOV->MOV_DESCR	:= STR0084 //"Retorno de Benecifio / Industrializacao - Suspensao"
	Endif		        
	If !MOV->(dbSeek(24))
		RecLock("MOV",.T.)
		MOV->MOV_COD  	:= 24
		MOV->MOV_DESCR	:= STR0034 //"Devolucoes de Vendas: "
	Endif
	If !MOV->(dbSeek(25))
		RecLock("MOV",.T.)
		MOV->MOV_COD  	:= 25
		MOV->MOV_DESCR	:= STR0035 //"Outras Entradas: "  
	Endif		        

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿  
	//³Processando os saldos em estoque³  
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aInvent := {"INV",""}  
	dUltFec := cToD(SubStr(aCFOPs[24],7,2) + "/" + SubStr(aCFOPs[24],5,2) + "/" + SubStr(aCFOPs[24],1,4))
 	FsEstInv(aInvent,1,.T.,.F.,dUltFec,.F.)

	MOV->(dbSetOrder(1))
	MOV->(dbGoTop())
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Total de registros a serem impressos ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nRegsPrint := MOV->(LastRec()) + QDC->(LastRec()) + QDD->(LastRec()) + QDE->(LastRec()) + QDF->(LastRec()) + QDG->(LastRec()) + QDH->(LastRec()) + QDI->(LastRec()) + INV->(LastRec()) + INV->(LastRec())
	SetRegua(nRegsPrint)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprime as movimentacoes de entrada e saida processadas.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nLin := Mtr937Cabec(aCFOPs[25],aCFOPs[23])
	FmtLin(,aLay[12],,,@nLin)		                                
	Do While ! MOV->(Eof())
		IncRegua()
		If MOV->MOV_COD == 1
			FmtLin(,aLay[013],,,@nLin)		                                				
			FmtLin(,aLay[014],,,@nLin)
			FmtLin(,aLay[015],,,@nLin)
		Endif
		If MOV->MOV_COD <= 13
			FmtLin({StrZero(MOV->MOV_COD,2),SubStr(MOV->MOV_DESCR,1,100),Str(MOV->MOV_SACAS,20,2),Str(MOV->MOV_KG,20,2),Str(MOV->MOV_VALOR,20,2),Str(MOV->MOV_ICMS,20,2)},aLay[016],,,@nLin)
			nTotSacas	+= MOV->MOV_SACAS
			nTotKG		+= MOV->MOV_KG
			nTotVal		+= MOV->MOV_VALOR
			nTotICMS	+= MOV->MOV_ICMS
			If MOV->MOV_COD < 13     
				FmtLin(,aLay[028],,,@nLin)
			Else                          
				FmtLin(,aLay[017],,,@nLin)
				FmtLin({Str(nTotSacas,20,2),Str(nTotKG,20,2),Str(nTotVal,20,2),Str(nTotICMS,20,2)},aLay[018],,,@nLin)
				FmtLin(,aLay[019],,,@nLin)
				FmtLin(,aLay[020],,,@nLin)
			Endif
		Else    
			If MOV->MOV_COD = 14
				nTotSacas	:= 0
				nTotKG		:= 0
				nTotVal		:= 0
				nTotICMS	:= 0
				nLin := Mtr937Cabec(aCFOPs[25],aCFOPs[23])
				FmtLin(,aLay[12],,,@nLin)		                                
				FmtLin(,aLay[021],,,@nLin)		                                				
				FmtLin(,aLay[022],,,@nLin)
				FmtLin(,aLay[023],,,@nLin)
            Endif            
			FmtLin({StrZero(MOV->MOV_COD,2),SubStr(MOV->MOV_DESCR,1,100),Str(MOV->MOV_SACAS,20,2),Str(MOV->MOV_KG,20,2),Str(MOV->MOV_VALOR,20,2),Str(MOV->MOV_ICMS,20,2)},aLay[024],,,@nLin)
			nTotSacas	+= MOV->MOV_SACAS
			nTotKG		+= MOV->MOV_KG
			nTotVal		+= MOV->MOV_VALOR
			nTotICMS	+= MOV->MOV_ICMS
			If MOV->MOV_COD < 25     
				FmtLin(,aLay[028],,,@nLin)
			Else                          
				FmtLin(,aLay[025],,,@nLin)
				FmtLin({Str(nTotSacas,20,2),Str(nTotKG,20,2),Str(nTotVal,20,2),Str(nTotICMS,20,2)},aLay[026],,,@nLin)
				FmtLin(,aLay[027],,,@nLin)
			Endif
		Endif
		MOV->(dbSkip(1))
	Enddo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprime o Quadro de Detalhe C               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nLin := Mtr937Cabec(aCFOPs[25],aCFOPs[23])
	nLin := Mtr937SubC("QDC",nLin)
	nTotSacas	:= 0
	nTotKG		:= 0
	nTotVal		:= 0
	nTotICMS	:= 0      
	lMov		:= .F.                        
	QDC->(dbSetOrder(2))
	QDC->(dbGoTop())
	Do While ! QDC->(Eof())
		IncRegua()
		If nLin > 60
			FmtLin(,aLay[037],,,@nLin)
			nLin := Mtr937Cabec(aCFOPs[25],aCFOPs[23])
			nLin := Mtr937SubC("QDC",nLin)
		Endif
		FmtLin({QDC->QDC_DESCR,Str(QDC->QDC_SACAS,20,2),Str(QDC->QDC_KG,20,2),Str(QDC->QDC_VALOR,20,2)},aLay[034],,,@nLin)	
		nTotSacas	+= QDC->QDC_SACAS
		nTotKG		+= QDC->QDC_KG
		nTotVal		+= QDC->QDC_VALOR
		lMov		:= .T.
		QDC->(dbSkip())
	Enddo              
	If nLin > 60
		FmtLin(,aLay[037],,,@nLin)
		nLin := Mtr937Cabec(aCFOPs[25],aCFOPs[23])
		nLin := Mtr937SubC("QDC",nLin)
	Endif
	If ! lMov                      
		FmtLin(,aLay[148],,,@nLin)		
	Endif
	FmtLin(,aLay[035],,,@nLin)		
	FmtLin({Str(nTotSacas,20,2),Str(nTotKG,20,2),Str(nTotVal,20,2)},aLay[036],,,@nLin)	
	FmtLin(,aLay[037],,,@nLin)			                                     
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprime o Quadro de Detalhe D               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nLin > 60
		nLin := Mtr937Cabec(aCFOPs[25],aCFOPs[23])
	Endif
	nLin := Mtr937SubC("QDD",nLin)
	nTotSacas	:= 0
	nTotKG		:= 0
	nTotVal		:= 0
	nTotICMS	:= 0                              
	lMov		:= .F.
	QDD->(dbGoTop())
	Do While ! QDD->(Eof())
		IncRegua()
		If nLin > 60
			FmtLin(,aLay[037],,,@nLin)
			nLin := Mtr937Cabec(aCFOPs[25],aCFOPs[23])
			nLin := Mtr937SubC("QDD",nLin)
		Endif
		FmtLin({QDD->QDD_UF,QDD->QDD_CNPJ,Str(QDD->QDD_SACAS,20,2),Str(QDD->QDD_KG,20,2),Str(QDD->QDD_VALOR,20,2)},aLay[043],,,@nLin)	
		nTotSacas	+= QDD->QDD_SACAS
		nTotKG		+= QDD->QDD_KG
		nTotVal		+= QDD->QDD_VALOR
		lMov := .T.
		QDD->(dbSkip())
	Enddo                           
	If nLin > 60
		FmtLin(,aLay[037],,,@nLin)
		nLin := Mtr937Cabec(aCFOPs[25],aCFOPs[23])
		nLin := Mtr937SubC("QDD",nLin)
	Endif  
	If ! lMov                      
		FmtLin(,aLay[148],,,@nLin)		
	Endif
	FmtLin(,aLay[044],,,@nLin)		
	FmtLin({Str(nTotSacas,20,2),Str(nTotKG,20,2),Str(nTotVal,20,2)},aLay[045],,,@nLin)	
	FmtLin(,aLay[046],,,@nLin)			                                     

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprime o Quadro de Detalhe E               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nLin > 60
		nLin := Mtr937Cabec(aCFOPs[25],aCFOPs[23])
	Endif
	nLin := Mtr937SubC("QDE",nLin)
	nTotSacas	:= 0
	nTotKG		:= 0
	nTotVal		:= 0
	nTotICMS	:= 0                              
	lMov		:= .F.
	QDE->(dbGoTop())
	Do While ! QDE->(Eof())
		IncRegua()
		If nLin > 60
			FmtLin(,aLay[037],,,@nLin)
			nLin := Mtr937Cabec(aCFOPs[25],aCFOPs[23])
			nLin := Mtr937SubC("QDE",nLin)
		Endif
		FmtLin({QDE->QDE_UF,Str(QDE->QDE_SACAS,20,2),Str(QDE->QDE_KG,20,2),Str(QDE->QDE_BASE,20,2),Str(QDE->QDE_ICMS,20,2)},aLay[052],,,@nLin)	
		nTotSacas	+= QDE->QDE_SACAS
		nTotKG		+= QDE->QDE_KG
		nTotVal		+= QDE->QDE_BASE             
		nTotICMS	+= QDE->QDE_ICMS                  
		lMov		:= .T.
		QDE->(dbSkip())
	Enddo                           
	If nLin > 60
		FmtLin(,aLay[037],,,@nLin)
		nLin := Mtr937Cabec(aCFOPs[25],aCFOPs[23])
		nLin := Mtr937SubC("QDE",nLin)
	Endif                 
	If ! lMov                      
		FmtLin(,aLay[148],,,@nLin)		
	Endif
	FmtLin(,aLay[053],,,@nLin)		
	FmtLin({Str(nTotSacas,20,2),Str(nTotKG,20,2),Str(nTotVal,20,2),Str(nTotICMS,20,2)},aLay[054],,,@nLin)	
	FmtLin(,aLay[055],,,@nLin)			                                     

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprime o Quadro de Detalhe F               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nLin > 60
		nLin := Mtr937Cabec(aCFOPs[25],aCFOPs[23])
	Endif
    nLin := Mtr937SubC("QDF",nLin)
	nTotSacas	:= 0
	nTotKG		:= 0
	nTotVal		:= 0
	nTotICMS	:= 0                              
	lMov		:= .F.
	QDF->(dbGoTop())
	Do While ! QDF->(Eof())
		IncRegua()
		If nLin > 60
			FmtLin(,aLay[037],,,@nLin)		
			nLin := Mtr937Cabec(aCFOPs[25],aCFOPs[23])
			nLin := Mtr937SubC("QDF",nLin)
		Endif
		FmtLin({QDF->QDF_CNPJ,Str(QDF->QDF_SACAS,20,2),Str(QDF->QDF_KG,20,2),Str(QDF->QDF_VALOR,20,2)},aLay[061],,,@nLin)	
		nTotSacas	+= QDF->QDF_SACAS
		nTotKG		+= QDF->QDF_KG
		nTotVal		+= QDF->QDF_VALOR            
		lMov		:= .T.
		QDF->(dbSkip())
	Enddo                           
	If nLin > 60
		FmtLin(,aLay[037],,,@nLin)	
		nLin := Mtr937Cabec(aCFOPs[25],aCFOPs[23])
		nLin := Mtr937SubC("QDF",nLin)
	Endif                 
	If ! lMov                      
		FmtLin(,aLay[148],,,@nLin)		
	Endif
	FmtLin(,aLay[062],,,@nLin)		
	FmtLin({Str(nTotSacas,20,2),Str(nTotKG,20,2),Str(nTotVal,20,2)},aLay[063],,,@nLin)	
	FmtLin(,aLay[064],,,@nLin)			                                     

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprime o Quadro de Detalhe G               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nLin > 60
		nLin := Mtr937Cabec(aCFOPs[25],aCFOPs[23])
	Endif
    nLin := Mtr937SubC("QDG",nLin)
	nTotSacas	:= 0
	nTotKG		:= 0
	nTotVal		:= 0
	nTotICMS	:= 0                              
	lMov		:= .F.
	QDG->(dbGoTop())
	Do While ! QDG->(Eof())
		IncRegua()
		If nLin > 60
			FmtLin(,aLay[037],,,@nLin)		
			nLin := Mtr937Cabec(aCFOPs[25],aCFOPs[23])
			nLin := Mtr937SubC("QDG",nLin)
		Endif
		FmtLin({QDG->QDG_UF,QDG->QDG_CNPJ,Str(QDG->QDG_SACAS,20,2),Str(QDG->QDG_KG,20,2),Str(QDG->QDG_VALOR,20,2)},aLay[070],,,@nLin)	
		nTotSacas	+= QDG->QDG_SACAS
		nTotKG		+= QDG->QDG_KG
		nTotVal		+= QDG->QDG_VALOR            
		lMov		:= .T.
		QDG->(dbSkip())
	Enddo                           
	If nLin > 60
		FmtLin(,aLay[037],,,@nLin)	
		nLin := Mtr937Cabec(aCFOPs[25],aCFOPs[23])
		nLin := Mtr937SubC("QDG",nLin)
	Endif
	If ! lMov                      
		FmtLin(,aLay[148],,,@nLin)		
	Endif
	FmtLin(,aLay[071],,,@nLin)		
	FmtLin({Str(nTotSacas,20,2),Str(nTotKG,20,2),Str(nTotVal,20,2)},aLay[072],,,@nLin)	
	FmtLin(,aLay[073],,,@nLin)			                                     

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprime o Quadro de Detalhe H               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nLin > 60
		nLin := Mtr937Cabec(aCFOPs[25],aCFOPs[23])
	Endif
	nLin := Mtr937SubC("QDH",nLin)
	nTotSacas	:= 0
	nTotKG		:= 0
	nTotVal		:= 0
	nTotICMS	:= 0                              
	lMov		:= .F.
	QDH->(dbGoTop())
	Do While ! QDH->(Eof())
		IncRegua()
		If nLin > 60
			FmtLin(,aLay[037],,,@nLin)		
			nLin := Mtr937Cabec(aCFOPs[25],aCFOPs[23])
			nLin := Mtr937SubC("QDH",nLin)
		Endif
		FmtLin({QDH->QDH_UF,Str(QDH->QDH_SACAS,20,2),Str(QDH->QDH_KG,20,2),Str(QDH->QDH_BASE,20,2),Str(QDH->QDH_ICMS,20,2)},aLay[079],,,@nLin)	
		nTotSacas	+= QDH->QDH_SACAS
		nTotKG		+= QDH->QDH_KG
		nTotVal		+= QDH->QDH_BASE            
		nTotICMS	+= QDH->QDH_ICMS
		lMov		:= .T.
		QDh->(dbSkip())
	Enddo                           
	If nLin > 60
		FmtLin(,aLay[037],,,@nLin)	
		nLin := Mtr937Cabec(aCFOPs[25],aCFOPs[23])
		nLin := Mtr937SubC("QDH",nLin)
	Endif
	If ! lMov                      
		FmtLin(,aLay[148],,,@nLin)		
	Endif
	FmtLin(,aLay[080],,,@nLin)		
	FmtLin({Str(nTotSacas,20,2),Str(nTotKG,20,2),Str(nTotVal,20,2),Str(nTotICMS,20,2)},aLay[081],,,@nLin)	
	FmtLin(,aLay[082],,,@nLin)			                                     

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprime o Quadro de Detalhe I               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nLin > 60
		nLin := Mtr937Cabec(aCFOPs[25],aCFOPs[23])
	Endif
	nLin := Mtr937SubC("QDI",nLin)
	nTotSacas	:= 0
	nTotKG		:= 0
	nTotVal		:= 0
	nTotICMS	:= 0                              
	lMov		:= .F.
	QDI->(dbGoTop())
	Do While ! QDI->(Eof())
		IncRegua()
		If nLin > 60
			FmtLin(,aLay[037],,,@nLin)		
			nLin := Mtr937Cabec(aCFOPs[25],aCFOPs[23])
			nLin := Mtr937SubC("QDI",nLin)
		Endif
		FmtLin({QDI->QDI_CNPJ,Str(QDI->QDI_SACAS,20,2),Str(QDI->QDI_KG,20,2),Str(QDI->QDI_VALOR,20,2)},aLay[088],,,@nLin)	
		nTotSacas	+= QDI->QDI_SACAS
		nTotKG		+= QDI->QDI_KG
		nTotVal		+= QDI->QDI_VALOR            
		lMov		:= .T.
		QDI->(dbSkip())
	Enddo                           
	If nLin > 60
		FmtLin(,aLay[037],,,@nLin)	
		nLin := Mtr937Cabec(aCFOPs[25],aCFOPs[23])
		nLin := Mtr937SubC("QDI",nLin)
	Endif
	If ! lMov                      
		FmtLin(,aLay[148],,,@nLin)		
	Endif
	FmtLin(,aLay[089],,,@nLin)		
	FmtLin({Str(nTotSacas,20,2),Str(nTotKG,20,2),Str(nTotVal,20,2)},aLay[090],,,@nLin)	
	FmtLin(,aLay[091],,,@nLin)			                                     

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprime o Quadro de Detalhe J               ³
	//|Apuracao do ICMS                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nLin > 60
		nLin := Mtr937Cabec(aCFOPs[25],aCFOPs[23])
	Endif
    nLin := Mtr937SubC("QDJ",nLin)

	aApur := FisApur("IC",Val(SubStr(aCFOPs[23],1,4)),Val(SubStr(aCFOPs[23],5,2)),2,0,"*",.F.,{},1,.F.,"")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verificando os valores necessarios da apuracao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// Saldo Credor do Periodo Anterior
	If nLin > 60
		nLin := Mtr937Cabec(aCFOPs[25],aCFOPs[23])
		nLin := Mtr937SubC("QDJ",nLin)
	Endif
	nValor := 0         
	If aScan(aApur,{|a| a[1]=="009"}) > 0
		nValor := aApur[aScan(aApur,{|a| a[1]=="009"})][3]
	Endif
	FmtLin({Str(nValor,20,2)},aLay[095],,,@nLin)		                                				
	FmtLin(,aLay[096],,,@nLin)		                                				
	// Creditos pelas Aquisicoes
	If nLin > 60
		nLin := Mtr937Cabec(aCFOPs[25],aCFOPs[23])
		nLin := Mtr937SubC("QDJ",nLIn)
	Endif
	nValor := 0
	If aScan(aApur,{|a| a[1]=="005"}) > 0
		nValor := aApur[aScan(aApur,{|a| a[1]=="005"})][3]
	Endif
	FmtLin({Str(nValor,20,2)},aLay[097],,,@nLin)		                                				
	FmtLin(,aLay[098],,,@nLin)		                                				
	// Outros Creditos                    
	If nLin > 60
		nLin := Mtr937Cabec(aCFOPs[25],aCFOPs[23])
		nLin := Mtr937SubC("QDJ",nLin)
	Endif
	nValor := 0
	If aScan(aApur,{|a| a[1]=="006"}) > 0
		nValor := aApur[aScan(aApur,{|a| a[1]=="006"})][3]
	Endif
	FmtLin({Str(nValor,20,2)},aLay[099],,,@nLin)		                                				
	FmtLin(,aLay[100],,,@nLin)		                                				
	// Estorno de Creditos                
	If nLin > 60
		nLin := Mtr937Cabec(aCFOPs[25],aCFOPs[23])
		nLin := Mtr937SubC("QDJ",nLin)
	Endif
	nValor := 0
	If aScan(aApur,{|a| a[1]=="003"}) > 0
		nValor := aApur[aScan(aApur,{|a| a[1]=="003"})][3]
	Endif
	FmtLin({Str(nValor,20,2)},aLay[101],,,@nLin)		                                				
	FmtLin(,aLay[102],,,@nLin)		                                				
	// Debitos pelas Saidas               
	If nLin > 60
		nLin := Mtr937Cabec(aCFOPs[25],aCFOPs[23])
		nLin := Mtr937SubC("QDJ",nLin)
	Endif
	nValor := 0
	If aScan(aApur,{|a| a[1]=="001"}) > 0
		nValor := aApur[aScan(aApur,{|a| a[1]=="001"})][3]
	Endif
	FmtLin({Str(nValor,20,2)},aLay[103],,,@nLin)		                                				
	FmtLin(,aLay[104],,,@nLin)		                                				
	// ICMS Recolhido                     
	If nLin > 60
		nLin := Mtr937Cabec(aCFOPs[25],aCFOPs[23])
		nLin := Mtr937SubC("QDJ",nLin)
	Endif
	nValor := 0
	If aScan(aApur,{|a| a[1]=="013"}) > 0
		nValor := aApur[aScan(aApur,{|a| a[1]=="013"})][3]
	Endif
	FmtLin({Str(nValor,20,2)},aLay[105],,,@nLin)		                                				
	FmtLin(,aLay[106],,,@nLin)		                                				
    // Estorno de Debitos
	If nLin > 60
		nLin := Mtr937Cabec(aCFOPs[25],aCFOPs[23])
		nLin := Mtr937SubC("QDJ",nLin)
	Endif
	nValor := 0
	If aScan(aApur,{|a| a[1]=="007"}) > 0
		nValor := aApur[aScan(aApur,{|a| a[1]=="007"})][3]
	Endif
	FmtLin({Str(nValor,20,2)},aLay[107],,,@nLin)		                                				
	FmtLin(,aLay[108],,,@nLin)		                                				
	// Saldo para o periodo seguinte    
	If nLin > 60
		nLin := Mtr937Cabec(aCFOPs[25],aCFOPs[23])
		nLin := Mtr937SubC("QDJ",nLin)
	Endif
	nValor := 0
	If aScan(aApur,{|a| a[1]=="014"}) > 0
		nValor := aApur[aScan(aApur,{|a| a[1]=="014"})][3]
	Endif
	FmtLin({Str(nValor,20,2)},aLay[109],,,@nLin)		                                				
	FmtLin(,aLay[110],,,@nLin)		                                				

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprimindo os saldos em estoque³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 to 3
		aEstabelec[nX]	:= 0
		aEmTerc[nX]		:= 0
		aDeTercMG[nX]	:= 0
		aDeTerc[nX]		:= 0
	Next
	
	RES->(dbSetOrder(1))
	INV->(dbGoTop())
	Do While ! INV->(Eof())

		IncRegua()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o produto esta classificado como cafe:³
		//³- Beneficiado: sacas de 60 kg                     ³
		//³- Em Coco: sacas de 40 kg                         ³
		//³- Torrado/Moido: por quilo                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SB5->(dbSetOrder(1))
		If !SB5->(dbSeek(xFilial("SB5")+INV->CODIGO))
			INV->(dbSkip())
			Loop
		Endif	 
			
		If !(SB5->(FieldGet(nTipoB5)))$"123"
			INV->(dbSkip())
			Loop
		Endif  
		
		cTipo 	:= SB5->&(cTipoB5)
		
		// Estoque no Estabelecimento
		If INV->SITUACA == "1"
			If cTipo == "1" 
				aEstabelec[01] += INV->QUANT
			Endif
			If cTipo == "2"      
				aEstabelec[02] += INV->QUANT
			Endif
			If cTipo == "3"      
				aEstabelec[03] += INV->QUANT
			Endif
		Endif
		
		// Estoque em Terceiros
		If INV->SITUACA == "2"
			If INV->UF == "MG"
				If cTipo == "1" 
					aEmTerc[01] += INV->QUANT
				Endif
				If cTipo == "2"      
					aEmTerc[02] += INV->QUANT
				Endif
				If cTipo == "3"      
					aEmTerc[03] += INV->QUANT
				Endif
			Endif
		Endif

		// Estoque de Terceiros
		If INV->SITUACA == "3"
			// De Contribuintes Mineiros
			If INV->UF == "MG"
				If cTipo == "1" 
					aDeTercMG[01] += INV->QUANT
				Endif
				If cTipo == "2"      
					aDeTercMG[02] += INV->QUANT
				Endif
				If cTipo == "3"      
					aDeTercMG[03] += INV->QUANT
				Endif
			Else // De Contribuintes de Outros Estados
				If cTipo == "1" 
					aDeTerc[01] += INV->QUANT
				Endif
				If cTipo == "2"      
					aDeTerc[02] += INV->QUANT
				Endif
				If cTipo == "3"      
					aDeTerc[03] += INV->QUANT
				Endif
			Endif
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Acumula por CNPJ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If INV->SITUACA == "3"
			nBenefic 	:= 0
			nCoco		:= 0
			nTorrado	:= 0
			If cTipo == "1"
				nBenefic 	:= INV->QUANT
			Endif  
			If cTipo == "2"
				nCoco 		:= INV->QUANT
			Endif  
			If cTipo == "3"
				nTorrado	:= INV->QUANT
			Endif                  
	
			If !RES->(dbSeek(INV->CNPJ))  
				RecLock("RES",.T.)
				RES->RES_CNPJ	:= INV->CNPJ
				RES->RES_IE		:= INV->INSCR
				RES->RES_NOME	:= INV->NOME
				RES->RES_COD	:= INV->CODNOME
				RES->RES_BENEF	:= nBenefic
				RES->RES_COCO	:= nCoco
				RES->RES_TORRA	:= nTorrado
				MsUnLock()
			Else
				RecLock("RES",.F.)
				RES->RES_BENEF	+= nBenefic
				RES->RES_COCO	+= nCoco
				RES->RES_TORRA	+= nTorrado
				MsUnLock()
			Endif
		Endif				

		INV->(dbSkip())
		
	Enddo
	
	nLin := Mtr937Cabec(aCFOPs[25],aCFOPs[23])
	FmtLin(,aLay[020],,,@nLin)		                                				
	FmtLin(,aLay[111],,,@nLin)		                                					
	FmtLin(,aLay[112],,,@nLin)		                                				
	FmtLin(,aLay[113],,,@nLin)		                                				
	FmtLin(,aLay[114],,,@nLin)		                                				
	FmtLin(,aLay[115],,,@nLin)		                                					
	FmtLin({Str(aEstabelec[01],20,2),Str(aEstabelec[02],20,2),Str(aEstabelec[03],20,2)},aLay[116],,,@nLin)		                                				
	FmtLin(,aLay[117],,,@nLin)		                                						
	FmtLin({Str(0,20,2),Str(0,20,2),Str(0,20,2)},aLay[118],,,@nLin)		                                				
	FmtLin(,aLay[119],,,@nLin)		                                						
	FmtLin({Str(0,20,2),Str(0,20,2),Str(0,20,2)},aLay[120],,,@nLin)		                                				
	FmtLin(,aLay[121],,,@nLin)		                                						
	FmtLin({Str(aEmTerc[01],20,2),Str(aEmTerc[02],20,2),Str(aEmTerc[03],20,2)},aLay[122],,,@nLin)		                                				
	FmtLin(,aLay[123],,,@nLin)		                                						
	FmtLin({Str(aDeTercMG[01],20,2),Str(aDeTercMG[02],20,2),Str(aDeTercMG[03],20,2)},aLay[124],,,@nLin)		                                				
	FmtLin(,aLay[125],,,@nLin)		                                						
	FmtLin({Str(aDeTerc[01],20,2),Str(aDeTerc[02],20,2),Str(aDeTerc[03],20,2)},aLay[126],,,@nLin)		                                				
	FmtLin(,aLay[127],,,@nLin)		                                						

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprime CNPJ a CNPJ do estoque de terceiros³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FmtLin(,aLay[020],,,@nLin)
	FmtLin(,aLay[128],,,@nLin)
	FmtLin(,aLay[129],,,@nLin)
	FmtLin(,aLay[130],,,@nLin)
	FmtLin(,aLay[131],,,@nLin)				
	FmtLin(,aLay[132],,,@nLin)	
	RES->(dbGoTop())
	Do While ! RES->(Eof())

		IncRegua()

		If nLin > 60
		 	FmtLin(,aLay[135],,,@nLin)
		 	FmtLin({Str(nTotBenefi,20,2),Str(nTotCoco,20,2),Str(nTotTorra,20,2)},aLay[136],,,@nLin)		
		 	FmtLin(,aLay[137],,,@nLin)
			nLin := Mtr937Cabec(aCFOPs[25],aCFOPs[23])
			FmtLin(,aLay[138],,,@nLin)			
			FmtLin(,aLay[139],,,@nLin)
			FmtLin(,aLay[140],,,@nLin)
			FmtLin(,aLay[141],,,@nLin)
			FmtLin(,aLay[142],,,@nLin)                                                                    
			FmtLin({Str(nTotBenefi,20,2),Str(nTotCoco,20,2),Str(nTotTorra,20,2)},aLay[143],,,@nLin)		
			FmtLin(,aLay[144],,,@nLin)                                                                    			
		Endif
		
		FmtLin({RES->RES_NOME},aLay[133],,,@nLin)	
		FmtLin({RES->RES_IE,RES->RES_CNPJ,RES->RES_COD,Str(RES->RES_BENEF,20,2),Str(RES->RES_COCO,20,2),Str(RES->RES_TORRA,20,2)},aLay[134],,,@nLin)	
		FmtLin(,aLay[135],,,@nLin)	

		nTotBenefi 	+= RES->RES_BENEF
		nTotCoco	+= RES->RES_COCO
		nTotTorra	+= RES->RES_TORRA
	
		RES->(dbSkip())

	Enddo

	If nLin > 60
	 	FmtLin({Str(nTotBenefi,20,2),Str(nTotCoco,20,2),Str(nTotTorra,20,2)},aLay[136],,,@nLin)		
	 	FmtLin(,aLay[137],,,@nLin)
		nLin := Mtr937Cabec(aCFOPs[25],aCFOPs[23])
	 	FmtLin(,aLay[020],,,@nLin)
		FmtLin(,aLay[138],,,@nLin)			
		FmtLin(,aLay[139],,,@nLin)
		FmtLin(,aLay[140],,,@nLin)
		FmtLin(,aLay[141],,,@nLin)
		FmtLin(,aLay[142],,,@nLin)                                                                    
		FmtLin({Str(nTotBenefi,20,2),Str(nTotCoco,20,2),Str(nTotTorra,20,2)},aLay[143],,,@nLin)		
		FmtLin(,aLay[144],,,@nLin)                                                                    			
	Endif
	FmtLin({Str(nTotBenefi,20,2),Str(nTotCoco,20,2),Str(nTotTorra,20,2)},aLay[146],,,@nLin)		
	FmtLin(,aLay[147],,,@nLin)                                                                    			

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Excluindo as tabelas temporarias ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MTR937DelArq(aTemp)
	FsEstInv(aInvent,2,,,dUltFec,.F.)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exclui area de trabalho do SD2³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lQuery
		RetIndex("SD2")	
		dbClearFilter()	
		Ferase(cArqInd+OrdBagExt())
	Else
		dbSelectArea(cAliasSD2)
		dbCloseArea()
	Endif		

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exclui area de trabalho do SD1³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lQuery
		RetIndex("SD1")	
		dbClearFilter()	
		Ferase(cArqInd+OrdBagExt())
	Else
		dbSelectArea(cAliasSD1)
		dbCloseArea()
	Endif		

Return( .T. ) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |R937LayOutºAutor  ³Mary C. Hergert     º Data ³ 05/04/2005  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Layout de Impressao                                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³MATR937                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R937LayOut()

	Local aLay := Array(150)      
	
//	aLay[001] :=   01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//  aLay[001] :=   0         10        20        30        40        50        60        70        80        90        100       110       120       130       140       150       160       170       180       190       200       210       220                                                                           	
	aLay[001] := '+==========================================================================================================================================================================================================================+'
	aLay[002] := STR0086 //'|                                                             D E M O N S T R A T I V O   D E   E S T O Q U E   E   D E   O P E R A C O E S   C O M   C A F E                                                              |'
	aLay[003] := '|==========================================================================================================================================================================================================================|'
	aLay[004] := STR0087 //'| AF:            ################################################################################################  | Mes:                ##                            | Ano:    ####                                      |'     
    aLay[005] := '|------------------------------------------------------------------------------------------------------------------+-------------------------------------------------------------------------------------------------------|'
	aLay[006] := STR0088 //'| Contribuinte:  ################################################################################################  | Inscricao Estadual: ##################                                                                |'     	
    aLay[007] := '|------------------------------------------------------------------------------------------------------------------+-------------------------------------------------------------------------------------------------------|'
	aLay[008] := STR0089 //'| Endereco:      ################################################################################################  | CNPJ:               ##################                                                                |'     	
    aLay[009] := '|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|'
	aLay[010] := STR0090 //'| Municipio:     ################################################################################################  | Estado:             ##                            | C.A.E.: ######################                    |'     	
    aLay[011] := '+==========================================================================================================================================================================================================================+'

    aLay[012] := '                                                                                                                                                                                                                            '          

    aLay[013] := '+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+'
	aLay[014] := STR0091 //'|    Campo A    |                                             SAIDAS                                               |       Sacas (cru)       |    Kg (torrado/moido)   |        Valor (R$)       |         ICMS (R$)       |'
    aLay[015] := '|------------------------------------------------------------------------------------------------------------------+-------------------------+-------------------------+-------------------------+-------------------------|'
	aLay[016] := '|    ##    | ####################################################################################################  | ####################### | ####################### | ####################### | ####################### |'
    aLay[017] := '|------------------------------------------------------------------------------------------------------------------+-------------------------+-------------------------+-------------------------+-------------------------+'
    aLay[018] := STR0092 //'|                                               TOTAL DO CAMPO "A"                                                 | ####################### | ####################### | ####################### | ####################### |'                                       
    aLay[019] := '+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+'

    aLay[020] := '                                                                                                                                                                                                                            '          

    aLay[021] := '+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+'
	aLay[022] := STR0093 //'|    Campo B    |                                            ENTRADAS                                              |       Sacas (cru)       |    Kg (torrado/moido)   |        Valor (R$)       |         ICMS (R$)       |'
    aLay[023] := '|------------------------------------------------------------------------------------------------------------------+-------------------------+-------------------------+-------------------------+-------------------------|'
	aLay[024] := '|    ##    | ####################################################################################################  | ####################### | ####################### | ####################### | ####################### |'
    aLay[025] := '|------------------------------------------------------------------------------------------------------------------+-------------------------+-------------------------+-------------------------+-------------------------+'
    aLay[026] := STR0094 //'|                                               TOTAL DO CAMPO "B"                                                 | ####################### | ####################### | ####################### | ####################### |'                                       
    aLay[027] := '+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+'

    aLay[028] := '|----------+-------------------------------------------------------------------------------------------------------+-------------------------+-------------------------+-------------------------+-------------------------|'
              
    aLay[029] := '+---------------------------------------------------------------------------------------------------------------------------------------+'
	aLay[030] := STR0095 //'|    Campo C    |                                                  EXPORTACAO DIRETA                                                    |'
    aLay[031] := '|---------------------------------------------------------------------------------------------------------------------------------------|'
	aLay[032] := STR0145 //'|                  Pais                 |             Sacas             |               Kg              |           Valor (R$)          |'
    aLay[033] := '|---------------------------------------+-----------------------------------------------------------------------------------------------|'
	aLay[034] := '|       #########################       |    #######################    |    #######################    |    #######################    |'
    aLay[035] := '|---------------------------------------+-------------------------------+-------------------------------+-------------------------------|'
	aLay[036] := STR0096 //'|    TOTAL C                            |    #######################    |    #######################    |    #######################    |'
    aLay[037] := '+---------------------------------------------------------------------------------------------------------------------------------------+'

    aLay[038] := '+---------------------------------------------------------------------------------------------------------------------------------------+'
	aLay[039] := STR0097 //'|    Campo D    |                                      REMESSAS COM FIM ESPECIFICO DE EXPORTACAO                                        |'
    aLay[040] := '|---------------------------------------------------------------------------------------------------------------------------------------|'
	aLay[041] := STR0098 //'|      UF      |          CNPJ          |             Sacas             |               Kg              |           Valor (R$)          |'
    aLay[042] := '|--------------+------------------------+-------------------------------+-------------------------------+-------------------------------|'
	aLay[043] := '|      ##      |     ##############     |    #######################    |    #######################    |    #######################    |'
    aLay[044] := '|---------------------------------------+-------------------------------+-------------------------------+-------------------------------|'
	aLay[045] := STR0099 //'|    TOTAL D                            |    #######################    |    #######################    |    #######################    |'
    aLay[046] := '+---------------------------------------------------------------------------------------------------------------------------------------+'

    aLay[047] := '+---------------------------------------------------------------------------------------------------------------------------------------+'
	aLay[048] := STR0100 //'|    Campo E    |                                           SAIDAS INTERESTADUAIS TRIBUTADAS                                            |'
    aLay[049] := '|---------------+-----------------------------------------------------------------------------------------------------------------------|'
	aLay[050] := STR0101 //'|      UF       |            Sacas            |             Kg              |     Base de Calculo (R$)    |          ICMS (R$)          |'
    aLay[051] := '|---------------+-----------------------------+-----------------------------+-----------------------------+-----------------------------|'
	aLay[052] := '|      ##       |   #######################   |   #######################   |   #######################   |   #######################   |'
    aLay[053] := '|---------------+-----------------------------+-----------------------------+-----------------------------+-----------------------------|'
	aLay[054] := STR0102 //'|    TOTAL E    |   #######################   |   #######################   |   #######################   |   #######################   |'
    aLay[055] := '+---------------------------------------------------------------------------------------------------------------------------------------+'

    aLay[056] := '+---------------------------------------------------------------------------------------------------------------------------------------+'
	aLay[057] := STR0103 //'|    Campo F    |                                          TRANSFERENCIAS INTERNAS DIFERIDAS                                            |'
    aLay[058] := '|---------------------------------------------------------------------------------------------------------------------------------------|'
	aLay[059] := STR0104 //'|               CNPJ              |              Sacas              |                Kg               |           Valor (R$)            |'
    aLay[060] := '|---------------------------------+---------------------------------+---------------------------------+---------------------------------|'
	aLay[061] := '|          ##############         |     #######################     |     #######################     |     #######################     |'
    aLay[062] := '|---------------------------------+---------------------------------+---------------------------------+---------------------------------|'
	aLay[063] := STR0105 //'|    TOTAL F                      |     #######################     |     #######################     |     #######################     |'
    aLay[064] := '+---------------------------------------------------------------------------------------------------------------------------------------+'
//	aLay[001] :=   01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//  aLay[001] :=   0         10        20        30        40        50        60        70        80        90        100       110       120       130       140       150       160       170       180       190       200       210       220                                                                           	

    aLay[065] := '+---------------------------------------------------------------------------------------------------------------------------------------+'
	aLay[066] := STR0106 //'|    Campo G    |                                     AQUISICOES COM FIM ESPECIFICO DE EXPORTACAO                                       |'
    aLay[067] := '|---------------------------------------------------------------------------------------------------------------------------------------|'
	aLay[068] := STR0107 //'|      UF      |          CNPJ          |             Sacas             |               Kg              |           Valor (R$)          |'
    aLay[069] := '|--------------+------------------------+-------------------------------+-------------------------------+-------------------------------|'
	aLay[070] := '|      ##      |     ##############     |    #######################    |    #######################    |    #######################    |'
    aLay[071] := '|---------------------------------------+-------------------------------+-------------------------------+-------------------------------|'
	aLay[072] := STR0108 //'|    TOTAL G                            |    #######################    |    #######################    |    #######################    |'
    aLay[073] := '+---------------------------------------------------------------------------------------------------------------------------------------+'

    aLay[074] := '+---------------------------------------------------------------------------------------------------------------------------------------+'
	aLay[075] := STR0109 //'|    Campo H    |                                         AQUISICOES INTERESTADUAIS TRIBUTADAS                                          |'
    aLay[076] := '|---------------------------------------------------------------------------------------------------------------------------------------|'
	aLay[077] := STR0110 //'|      UF       |           Sacas             |             Kg              |    Base de Calculo (R$)     |          ICMS (R$)          |'
    aLay[078] := '|---------------+-----------------------------+-----------------------------+-----------------------------+-----------------------------|'
	aLay[079] := '|      ##       |   #######################   |   #######################   |   #######################   |   #######################   |'
    aLay[080] := '|---------------+-----------------------------+-----------------------------+-----------------------------+-----------------------------|'
	aLay[081] := STR0111 //'|    TOTAL H    |   #######################   |   #######################   |   #######################   |   #######################   |'
    aLay[082] := '+---------------------------------------------------------------------------------------------------------------------------------------+'

	aLay[083] := '+---------------------------------------------------------------------------------------------------------------------------------------+'
	aLay[084] := STR0112 //'|    Campo I    |                                       RECEBIMENTOS EM TRANSFERENCIA DO ESTADO                                         |'
    aLay[085] := '|---------------+-----------------------------------------------------------------------------------------------------------------------|'
	aLay[086] := STR0113 //'|               CNPJ              |              Sacas              |                Kg               |           Valor (R$)            |'
    aLay[087] := '|---------------------------------+---------------------------------+---------------------------------+---------------------------------|'
	aLay[088] := '|          ##############         |     #######################     |     #######################     |     #######################     |'
    aLay[089] := '|---------------------------------+---------------------------------+---------------------------------+---------------------------------|'
	aLay[090] := STR0114 //'|    TOTAL I                      |     #######################     |     #######################     |     #######################     |'
    aLay[091] := '+---------------------------------------------------------------------------------------------------------------------------------------+'

    aLay[092] := '+---------------------------------------------------------------------------------------------------------------------------------------+'
	aLay[093] := STR0115 //'|    Campo J    |                                             CONTA CORRENTE DE ICMS (R$)                                               |'
    aLay[094] := '|---------------------------------------------------------------------------------------------------------------------------------------|'
	aLay[095] := STR0116 //'|               (+) Saldo credor do periodo anterior                                                   |     ######################     |'
    aLay[096] := '|------------------------------------------------------------------------------------------------------+--------------------------------|'
	aLay[097] := STR0117 //'|               (+) Creditos pelas aquisicoes                                                          |     ######################     |'
    aLay[098] := '|------------------------------------------------------------------------------------------------------+--------------------------------|'
	aLay[099] := STR0118 //'|               (+) Outros creditos                                                                    |     ######################     |'
    aLay[100] := '|------------------------------------------------------------------------------------------------------+--------------------------------|'
	aLay[101] := STR0119 //'|               (-) Estorno de creditos                                                                |     ######################     |'
    aLay[102] := '|------------------------------------------------------------------------------------------------------+--------------------------------|'
	aLay[103] := STR0120 //'|               (-) Debitos pelas saidas                                                               |     ######################     |'
    aLay[104] := '|------------------------------------------------------------------------------------------------------+--------------------------------|'
	aLay[105] := STR0121 //'|               (-) ICMS recolhido                                                                     |     ######################     |'
    aLay[106] := '|------------------------------------------------------------------------------------------------------+--------------------------------|'
	aLay[107] := STR0122 //'|               (-) Estorno de debitos                                                                 |     ######################     |'
    aLay[108] := '|------------------------------------------------------------------------------------------------------+--------------------------------|'
	aLay[109] := STR0123 //'|               (=) SALDO PARA O PERIODO SEGUINTE                                                      |     ######################     |'
    aLay[110] := '+---------------------------------------------------------------------------------------------------------------------------------------+'
    
    aLay[111] := '+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+'
	aLay[112] := STR0124 //'|                                  ESTOQUE EXISTENTE NO ULTIMO DIA DO MES                                   |                                                  QUANTIDADE                                                  |'
	aLay[113] := '|------------------------------+----------------+-----------------------------------------------------------+------------------------------------+------------------------------------+------------------------------------|'    
	aLay[114] := STR0125 //'|                              |     CODIGO     |                                                           |       BENEFICIADO (Sc. 60Kg)       |         EM COCO (Sc. 40 Kg)        |        TORRADO / MOIDO - Kg        |'  
	aLay[115] := '|------------------------------+----------------+-----------------------------------------------------------+------------------------------------+------------------------------------+------------------------------------|'
	aLay[116] := STR0126 //'|                              |       00       |       No Estabelecimento Declarante                       |       ######################       |       ######################       |       ######################       |'
	aLay[117] := '|                              |----------------+-----------------------------------------------------------+------------------------------------+------------------------------------+------------------------------------|'    
	aLay[118] := STR0127 //'|                              |       01       |       Em Deposito Fechado                                 |       ######################       |       ######################       |       ######################       |'
	aLay[119] := STR0128 //'|       1 - PROPRIO            |----------------+-----------------------------------------------------------+------------------------------------+------------------------------------+------------------------------------|'    
	aLay[120] := STR0129 //'|                              |       02       |       Depositado em Armazens Gerais do Estado de MG       |       ######################       |       ######################       |       ######################       |'
	aLay[121] := '|                              |----------------+-----------------------------------------------------------+------------------------------------+------------------------------------+------------------------------------|'    
	aLay[122] := STR0130 //'|                              |       03       |       Em Poder de Terceiros no Estado de MG               |       ######################       |       ######################       |       ######################       |'
	aLay[123] := '|------------------------------+----------------+-----------------------------------------------------------+-------------------------------------------------------------------------+------------------------------------|'    
	aLay[124] := STR0131 //'|                              |       04       |       Pertencentes de Terceiros no Estado de MG           |       ######################       |       ######################       |       ######################       |'
	aLay[125] := STR0132 //'|       2 - DE TERCEIROS       |----------------+-----------------------------------------------------------+------------------------------------+------------------------------------+------------------------------------|'    
	aLay[126] := STR0133 //'|                              |       05       |       De Contribuintes de Outros Estados                  |       ######################       |       ######################       |       ######################       |'
	aLay[127] := '+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+'    
	
//	aLay[001] := 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//  aLay[001] := 0         10        20        30        40        50        60        70        80        90        100       110       120       130       140       150       160       170       180       190       200       210       220                                                                           	
    aLay[128] := '+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+'
	aLay[129] := STR0134 //'|                                                                                                           |                                                  QUANTIDADE                                                  |'
	aLay[130] := STR0135 //'|                                         Relacao dos Contribuintes                                         +------------------------------------+------------------------------------+------------------------------------|'    
	aLay[131] := STR0136 //'|                                                                                                           |       BENEFICIADO (Sc. 60Kg)       |         EM COCO (Sc. 40 Kg)        |        TORRADO / MOIDO - Kg        |'  
	aLay[132] := '|-----------------------------------------------------------------------------------------------------------+------------------------------------+------------------------------------+------------------------------------|'
	aLay[133] := STR0137 //'| Nome: ########################################                                                            |                                    |                                    |                                    |'
	aLay[134] := STR0138 //'| Inscricao Estadual: ##################             CNPJ: ##############          Codigo: ######           |       ######################       |       ######################       |       ######################       |'
	aLay[135] := '|-----------------------------------------------------------------------------------------------------------+------------------------------------+------------------------------------+------------------------------------|'
	aLay[136] := STR0139 //'|                                       Total Parcial a Transportar                                         |       ######################       |       ######################       |       ######################       |'          
	aLay[137] := '+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+'

    aLay[138] := '+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+'
	aLay[139] := STR0140 //'|                                                                                                           |                                                  QUANTIDADE                                                  |'
	aLay[140] := STR0141 //'|                                 Relacao dos Contribuintes (Continuacao)                                   +------------------------------------+------------------------------------+------------------------------------|'    
	aLay[141] := STR0142 //'|                                                                                                           |       BENEFICIADO (Sc. 60Kg)       |         EM COCO (Sc. 40 Kg)        |        TORRADO / MOIDO - Kg        |'  
	aLay[142] := '|-----------------------------------------------------------------------------------------------------------+------------------------------------+------------------------------------+------------------------------------|'
	aLay[143] := STR0143 //'|                                       Total Parcial Transportado                                          |       ######################       |       ######################       |       ######################       |'          
	aLay[144] := '+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+'

	aLay[145] := '|-----------------------------------------------------------------------------------------------------------+------------------------------------+------------------------------------+------------------------------------|'
	aLay[146] := STR0144 //'|                                               Total Geral                                                 |       ######################       |       ######################       |       ######################       |'          
	aLay[147] := '+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+'

	aLay[148] := STR0145 //'|                                                            SEM MOVIMENTO                                                              |'

Return aLay

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MATR937Wiz  ºAutor  ³Mary C. Hergert     º Data ³ 04/04/2005  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta a wizard com as perguntas necessarias                   º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³MATR937                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function MATR937Wiz()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Declaracao das variaveis³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aTxtPre 		:= {}
	Local aPaineis 		:= {}
	
	Local cTitObj1		:= ""                
	Local cMask			:= Replicate("X",245)
	
	Local nPos			:= 0
	
	Local lRet			:= 0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta wizard com as perguntas necessarias³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aTxtPre,STR0005) //"Demonstrativo de Estoque e de Operacoes com Cafe (DEOC)"
	aAdd(aTxtPre,STR0006) //"Atenção"
	aAdd(aTxtPre,STR0007) //"Preencha corretamente as informações solicitadas."
	aAdd(aTxtPre,STR0008+STR0009+STR0010)	//"Esta rotina ira permitir a configuracao das informacoes "
											//"necessarias a geracao do relatorio auxiliar do DEOC - "
											//"Demonstrativo de Estoque e de Operacoes com Cafe"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Painel 1 - Informacoes Gerais            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aPaineis,{})
	nPos :=	Len(aPaineis)
	aAdd(aPaineis[nPos],STR0011) //"Assistente de parametrização" 
	aAdd(aPaineis[nPos],STR0062) //"Informacoes Gerais:"
	aAdd(aPaineis[nPos],{})

	cTitObj1 :=	STR0063 //"Data Inicial: "
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
    aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,"@d",3,,,,8})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
    //
	cTitObj1 :=	STR0064 //"Data Final: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,"@d",3,,,,8})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
    //
	cTitObj1 :=	STR0065 //"Agência Fazendária: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,Replicate("X",40),1,,,,40})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
    //
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Painel 2 - CFOPs saídas - primeira parte ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aPaineis,{})
	nPos :=	Len(aPaineis)
	aAdd(aPaineis[nPos],STR0011) //"Assistente de parametrização" 
	aAdd(aPaineis[nPos],STR0012) //"CFOP's para Saidas:"
	aAdd(aPaineis[nPos],{})
	//
	cTitObj1 :=	STR0013 //"Exportação Direta: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,245})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 :=	STR0014 //"Remessa com fim específico de Exportação: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,245})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 :=	STR0015 //"Saídas Internas Tributadas: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,245})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//                             
	cTitObj1 :=	STR0016 //"Saías Interestaduais Tributadas: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,245})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//                                                    
	cTitObj1 :=	STR0017 //"Transferências Internas Diferidas: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,245})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//   
	cTitObj1 :=	STR0018 //"Remessas para Armazéns Gerais: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,245})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Painel 3 - CFOPs saídas - segunda parte  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aPaineis,{})
	nPos :=	Len(aPaineis)
	aAdd(aPaineis[nPos],STR0011) //"Assistente de parametrização" 
	aAdd(aPaineis[nPos],STR0012) //"CFOP's para Saidas:"
	aAdd(aPaineis[nPos],{})
	//
	cTitObj1 :=	STR0019 //"Saidas Internas Diferidas - Indústrias: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,245})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 :=	STR0020 //"Saidas Internas Diferidas - Exportadores/Cooperativas: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,245})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 :=	STR0021 //"Quebras de Maquinacao / Eliminacao impurezas: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,245})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})                             
	//
	cTitObj1 :=	STR0022 //"Remessas para Beneficio / Industrializacao - Suspensao: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,245})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 :=	STR0023 //"Devolucoes de Compras: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,245})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//                                          
	cTitObj1 :=	STR0024 //"Outras Saídas: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,245})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Painel 4 - CFOPs Entradas                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aPaineis,{})
	nPos :=	Len(aPaineis)
	aAdd(aPaineis[nPos],STR0011) //"Assistente de parametrização" 
	aAdd(aPaineis[nPos],STR0025) //"CFOP's para Entradas: "
	aAdd(aPaineis[nPos],{})
	//
	cTitObj1 :=	STR0026 //"Aquisicoes com finalidade específica de Exportação: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,245})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 :=	STR0027 //"Aquisicoes internas tributadas: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,245})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 :=	STR0028 //"Aquisicoes interestaduais tributadas: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,245})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 :=	STR0029 //"Recebimentos em Transferência do Estado: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,245})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 :=	STR0030 //"Retorno de Armazéns Gerais: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,245})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 :=	STR0031 //"Aquisições de Produtores Rurais - Diferidas: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,245})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Painel 5 - CFOPs Entradas - segunda parte³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aPaineis,{})
	nPos :=	Len(aPaineis)
	aAdd(aPaineis[nPos],STR0011) //"Assistente de parametrização" 
	aAdd(aPaineis[nPos],STR0025) //"CFOP's para Entradas: "
	aAdd(aPaineis[nPos],{})
    //
	cTitObj1 :=	STR0032 //"Aquisições de Atacadistas / Cooperativas - Diferidas: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,245})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 :=	STR0033 //"Retorno de Benefício / Industrialização - Suspensão: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,245})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 :=	STR0034 //"Devoluções de Vendas: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,245})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 :=	STR0035 //"Outras Entradas: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,245})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//

	lRet :=	xMagWizard(aTxtPre,aPaineis,"MTR937")
	
Return(lRet)   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MTR937StruºAutor  ³Mary C. Hergert     º Data ³ 01/10/2004  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cria a estrutura do arquivo temporario para a impressao do  º±±
±±º          ³relatorio.                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³MATR937                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function MTR937Stru()
                 
	Local aTemp		:= {}

	Local aStruMOV 	:= {}
	Local cArqMOV 	:= ""
	Local aStruQDC 	:= {}
	Local cArqQDC 	:= ""
	Local cArqQDC2	:= ""
	Local aStruQDD 	:= {}          
	Local cArqQDD 	:= ""
	Local aStruQDE 	:= {}
	Local cArqQDE 	:= ""
	Local aStruQDF 	:= {}
	Local cArqQDF 	:= ""
	Local aStruQDG 	:= {}
	Local cArqQDG 	:= ""
	Local aStruQDH 	:= {}
	Local cArqQDH 	:= ""
	Local aStruQDI 	:= {}
	Local cArqQDI 	:= ""
	Local aStruRes	:= {}
	Local cArqRes	:= ""
		
	AADD(aStruMOV,{"MOV_COD"		,"N",002,0})
	AADD(aStruMOV,{"MOV_DESCR"		,"C",255,0})
	AADD(aStruMOV,{"MOV_SACAS"		,"N",020,2})
	AADD(aStruMOV,{"MOV_KG"	 		,"N",020,2})
	AADD(aStruMOV,{"MOV_VALOR"		,"N",020,2})
	AADD(aStruMOV,{"MOV_ICMS"		,"N",020,2})
	//
	cArqMOV	:=	CriaTrab(aStruMOV)
	dbUseArea(.T.,__LocalDriver,cArqMOV,"MOV")
	IndRegua("MOV",cArqMOV,"MOV_COD")
	
	AADD(aStruQDC,{"QDC_CPAIS"		,"C",003,0})
	AADD(aStruQDC,{"QDC_DESCR"		,"C",025,0})
	AADD(aStruQDC,{"QDC_SACAS"		,"N",020,2})
	AADD(aStruQDC,{"QDC_KG"			,"N",020,2})
	AADD(aStruQDC,{"QDC_VALOR"		,"N",020,2})
	//
	cArqQDC	:=	CriaTrab(aStruQDC)
	dbUseArea(.T.,__LocalDriver,cArqQDC,"QDC")
	IndRegua("QDC",cArqQDC,"QDC_CPAIS")
	dbClearIndex()
	//
	cArqQDC2 :=	CriaTrab(Nil,.F.)
	IndRegua("QDC",cArqQDC2,"QDC_DESCR")
	dbClearIndex()	
	//
	dbSelectArea("QDC")
	dbSetIndex(cArqQDC+OrdBagExt())
	dbSetIndex(cArqQDC2+OrdBagExt())
	dbSetOrder(1)
    //
    
	AADD(aStruQDD,{"QDD_UF"			,"C",002,0})
	AADD(aStruQDD,{"QDD_CNPJ"		,"C",014,0})
	AADD(aStruQDD,{"QDD_SACAS"		,"N",020,2})
	AADD(aStruQDD,{"QDD_KG"	 		,"N",020,2})
	AADD(aStruQDD,{"QDD_VALOR"		,"N",020,2})
	//
	cArqQDD	:=	CriaTrab(aStruQDD)
	dbUseArea(.T.,__LocalDriver,cArqQDD,"QDD")
	IndRegua("QDD",cArqQDD,"QDD_UF+QDD_CNPJ")

	AADD(aStruQDE,{"QDE_UF"			,"C",002,0})
	AADD(aStruQDE,{"QDE_SACAS"		,"N",020,2})
	AADD(aStruQDE,{"QDE_KG"	 		,"N",020,2})
	AADD(aStruQDE,{"QDE_BASE"		,"N",020,2})
	AADD(aStruQDE,{"QDE_ICMS"		,"N",020,2})
	//
	cArqQDE	:=	CriaTrab(aStruQDE)
	dbUseArea(.T.,__LocalDriver,cArqQDE,"QDE")
	IndRegua("QDE",cArqQDE,"QDE_UF")

	AADD(aStruQDF,{"QDF_CNPJ"		,"C",014,0})
	AADD(aStruQDF,{"QDF_SACAS"		,"N",020,2})
	AADD(aStruQDF,{"QDF_KG"	 		,"N",020,2})
	AADD(aStruQDF,{"QDF_VALOR"		,"N",020,2})
	//
	cArqQDF	:=	CriaTrab(aStruQDF)
	dbUseArea(.T.,__LocalDriver,cArqQDF,"QDF")
	IndRegua("QDF",cArqQDF,"QDF_CNPJ")

	AADD(aStruQDG,{"QDG_UF"			,"C",002,0})
	AADD(aStruQDG,{"QDG_CNPJ"		,"C",014,0})
	AADD(aStruQDG,{"QDG_SACAS"		,"N",020,2})
	AADD(aStruQDG,{"QDG_KG"	 		,"N",020,2})
	AADD(aStruQDG,{"QDG_VALOR"		,"N",020,2})
	//
	cArqQDG	:=	CriaTrab(aStruQDG)
	dbUseArea(.T.,__LocalDriver,cArqQDG,"QDG")
	IndRegua("QDG",cArqQDG,"QDG_UF+QDG_CNPJ")

	AADD(aStruQDH,{"QDH_UF"			,"C",002,0})
	AADD(aStruQDH,{"QDH_SACAS"		,"N",020,2})
	AADD(aStruQDH,{"QDH_KG"	 		,"N",020,2})
	AADD(aStruQDH,{"QDH_BASE"		,"N",020,2})
	AADD(aStruQDH,{"QDH_ICMS"		,"N",020,2})
	//
	cArqQDH	:=	CriaTrab(aStruQDH)
	dbUseArea(.T.,__LocalDriver,cArqQDH,"QDH")
	IndRegua("QDH",cArqQDH,"QDH_UF")

	AADD(aStruQDI,{"QDI_CNPJ"		,"C",014,0})
	AADD(aStruQDI,{"QDI_SACAS"		,"N",020,2})
	AADD(aStruQDI,{"QDI_KG"	 		,"N",020,2})
	AADD(aStruQDI,{"QDI_VALOR"		,"N",020,2})
	//
	cArqQDI	:=	CriaTrab(aStruQDI)
	dbUseArea(.T.,__LocalDriver,cArqQDI,"QDI")
	IndRegua("QDI",cArqQDI,"QDI_CNPJ")

	AADD(aStruRES,{"RES_CNPJ"		,"C",014,0})
	AADD(aStruRES,{"RES_IE"			,"C",018,0})
	AADD(aStruRES,{"RES_NOME"		,"C",040,0})
	AADD(aStruRES,{"RES_COD"		,"C",006,0})
	AADD(aStruRES,{"RES_BENEF"		,"N",020,2})
	AADD(aStruRES,{"RES_COCO"		,"N",020,2})
	AADD(aStruRES,{"RES_TORRA"		,"N",020,2})
	//
	cArqRES	:=	CriaTrab(aStruRES)
	dbUseArea(.T.,__LocalDriver,cArqRES,"RES")
	IndRegua("RES",cArqRES,"RES_CNPJ")

	aTemp := {{cArqMOV,"MOV"},{cArqQDC,"QDC"},{cArqQDD,"QDD"},{cArqQDE,"QDE"},{cArqQDF,"QDF"},{cArqQDG,"QDG"},{cArqQDH,"QDH"},{cArqQDI,"QDI"},{cArqRES,"RES"}}
	
Return(aTemp)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao   ³MTR937DelArqºAutor  ³ Mary C. Hergert    º Data ³ 05/04/2005  º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.    ³ Apaga arquivos temporarios criados                           º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³ MATR937                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MTR937DelArq(aDelArqs)

	Local aAreaDel 	:= GetArea()
	Local nI 		:= 0
	
	For nI := 1 To Len(aDelArqs)
		If File(aDelArqs[ni,1]+GetDBExtension())
			dbSelectArea(aDelArqs[ni,2])
			dbCloseArea()
			Ferase(aDelArqs[ni,1]+GetDBExtension())
			Ferase(aDelArqs[ni,1]+OrdBagExt())
		Endif	
	Next
	
	RestArea(aAreaDel)
	
Return
	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao   ³MTR937Cabec ºAutor  ³ Mary C. Hergert    º Data ³ 05/04/2005  º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.    ³Imprime o cabecalho                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³MATR937                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Mtr937Cabec(cAF,cData)

	Local nLin		:= 0
	Local aLay		:= R937LayOut()
		
	@ 0,0 PSAY AvalImp(220)
	FmtLin(,aLay[01],,,@nLin)		
	FmtLin(,aLay[02],,,@nLin)		
	FmtLin(,aLay[03],,,@nLin)		
	FmtLin({cAF,SubStr(cData,5,2),SubStr(cData,1,4)},aLay[04],,,@nLin)		
	FmtLin(,aLay[05],,,@nLin)		
	FmtLin({SM0->M0_NOMECOM,SM0->M0_INSC},aLay[06],,,@nLin)		
	FmtLin(,aLay[07],,,@nLin)		                                
	FmtLin({SM0->M0_ENDENT,SM0->M0_CGC},aLay[08],,,@nLin)		    
	FmtLin(,aLay[09],,,@nLin)		                                
	FmtLin({SM0->M0_CIDENT,SM0->M0_ESTENT,SM0->M0_CNAE},aLay[10],,,@nLin)		    
	FmtLin(,aLay[11],,,@nLin)		                                
	
Return(nLin)	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao   ³MTR937SubC  ºAutor  ³ Mary C. Hergert    º Data ³ 05/04/2005  º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.    ³Imprime os sub-cabecalhos                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³MATR937                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Mtr937SubC(cQuadro,nLin)

	Local aLay		:= R937LayOut()
		
	If cQuadro == "QDC"                                                                
		FmtLin(,aLay[020],,,@nLin)		                                					
		FmtLin(,aLay[029],,,@nLin)		                                				
		FmtLin(,aLay[030],,,@nLin)
		FmtLin(,aLay[031],,,@nLin)
		FmtLin(,aLay[032],,,@nLin)
		FmtLin(,aLay[033],,,@nLin)		
	Endif

	If cQuadro == "QDD"
		FmtLin(,aLay[020],,,@nLin)		                                				
		FmtLin(,aLay[038],,,@nLin)		                                				
		FmtLin(,aLay[039],,,@nLin)
		FmtLin(,aLay[040],,,@nLin)
		FmtLin(,aLay[041],,,@nLin)
		FmtLin(,aLay[042],,,@nLin)		
	Endif

	If cQuadro == "QDE"
		FmtLin(,aLay[020],,,@nLin)		                                				
		FmtLin(,aLay[047],,,@nLin)		                                				
		FmtLin(,aLay[048],,,@nLin)
		FmtLin(,aLay[049],,,@nLin)
		FmtLin(,aLay[050],,,@nLin)
		FmtLin(,aLay[051],,,@nLin)
	Endif

	If cQuadro == "QDF"
		FmtLin(,aLay[020],,,@nLin)		                                				
		FmtLin(,aLay[056],,,@nLin)		                                				
		FmtLin(,aLay[057],,,@nLin)
		FmtLin(,aLay[058],,,@nLin)
		FmtLin(,aLay[059],,,@nLin)
		FmtLin(,aLay[060],,,@nLin)
	Endif

	If cQuadro == "QDG"
		FmtLin(,aLay[020],,,@nLin)		                                				
		FmtLin(,aLay[065],,,@nLin)		                                				
		FmtLin(,aLay[066],,,@nLin)
		FmtLin(,aLay[067],,,@nLin)
		FmtLin(,aLay[068],,,@nLin)
		FmtLin(,aLay[069],,,@nLin)
	Endif

	If cQuadro == "QDH"
		FmtLin(,aLay[020],,,@nLin)		                                				
		FmtLin(,aLay[074],,,@nLin)		                                				
		FmtLin(,aLay[075],,,@nLin)
		FmtLin(,aLay[076],,,@nLin)
		FmtLin(,aLay[077],,,@nLin)
		FmtLin(,aLay[078],,,@nLin)
	Endif

	If cQuadro == "QDI"
		FmtLin(,aLay[020],,,@nLin)		                                				
		FmtLin(,aLay[083],,,@nLin)		                                				
		FmtLin(,aLay[084],,,@nLin)
		FmtLin(,aLay[085],,,@nLin)
		FmtLin(,aLay[086],,,@nLin)
		FmtLin(,aLay[087],,,@nLin)
	Endif

	If cQuadro == "QDJ"
		FmtLin(,aLay[020],,,@nLin)		                                				
		FmtLin(,aLay[092],,,@nLin)		                                				
		FmtLin(,aLay[093],,,@nLin)		                                				
		FmtLin(,aLay[094],,,@nLin)
	Endif
	
Return(nLin)	
