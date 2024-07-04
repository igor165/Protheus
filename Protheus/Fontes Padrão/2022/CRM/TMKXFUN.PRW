#INCLUDE "TMKXFUN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMKDEF.CH"
#INCLUDE "COLORS.CH" 

Static _lTmkEnt		:= ExistBlock("TMKENT")
Static _lTmkEntCo	:= ExistBlock("TMKENTCO")	// Se existe P.E para filtrar entidades
Static _lPDActive	:= .F.

/*
ACOLS DA ROTINA DE TELEVENDAS
	1  - Produto
	2  - Descricao
	3  - Situacao do Produto
	4  - Quantidade
	5  - Pre‡o Unitario
	6  - Valor do Item (Quantidade * Pre‡o Unitario)
	7  - Local Padrao
	8  - Unidade
	9  - Desconto (%)
	10 - Valor do Desconto
	11 - Tipo E/S                             
	12 - Codigo Fiscal
	13 - Acrescimo (%)
	14 - Valor do Acrescimo
	15 - Preco de Tabela
	16 - Data de entrega
	17 - Lote
	18 - Sub-Lote
	19 - Data de validade do Lote
	
ACOLS DA ROTINA DE TELEMARKETING
	1  - Assunto
	2  - Descricao do assunto
	3  - Produto
	4  - Descricao do produto
	5  - Ocorrencia
	6  - Descricao da ocorrencia
	7  - Codigo do Operador
	8  - Nome do Operador
	9  - Data da Acao
	10 - Acao
	11 - Descricao da Acao
	12 - Observacao
	
	ACOLS DA ROTINA DE TELECOBRANCA
	1  - Titulo
	2  - Prefixo
	3  - Parcela
	4  - Tipo do Titulo
	5  - Descricao do Tipo
	6  - Natureza
	7  - Descricao da Natureza
	8  - Data de Vencimento
	9  - Data de Vencimento Real
	10 - Valor
	11 - Valor Acrescimo
	12 - Valor Desconto
	13 - Status
	14 - Acao
	15 - Descricao da Acao
*/

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tk271DadosContato³ Autor ³ Vendas Clientes       ³ Data ³01/08/01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna os dados solicitados do contato							 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³AP6 Call Center				         	                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TkDadosContato(cContato,nTipo,lPDEval,nTipoTel)
Local cCampo	:= "U5_CONTAT"				//Campo padrao para o retorno
Local cDesc		:= ""						//Retorno da rotina
Local cSource	:= ""
Local cTipoAGB	:= ""

Default nTipo 	:= 0
Default lPDEval := .F.
Default nTipoTel:= 0  

cCampo	:= TkFieldType(nTipo)  

//Carrega o DDI e DDD, conforme o cadastro na tabela AGB
If (nTipo == 8 .Or. nTipo == 9) .And. (nTipoTel > 0 .And. nTipoTel <= 4)
	cTipoAGB := IIf(nTipoTel==1,"21",IIf(nTipoTel==2,"51",IIf(nTipoTel==3,"31",IIf(nTipoTel==4,"11"," "))))
	If !Empty(cTipoAGB)
		cDesc := Posicione("AGB",1,xFilial("AGB") + "SU5" + PadR(cContato,GetSx3Cache("AGB_CODENT","X3_TAMANHO")) + cTipoAGB,IIf(nTipo == 8,"AGB_DDD","AGB_DDI"))
	EndIf
EndIf

If Empty(cDesc)
	cDesc := Posicione("SU5",1,xFilial("SU5") + cContato,cCampo)
EndIf

If lPDEval
	cSource := TkPDxFun()
	cDesc 	:= FATPDObfuscate(cDesc, cCampo, cSource)  
EndIf

Return(cDesc) 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    TkFieldType Autor ³ Vendas Clientes       ³ Data ³01/08/01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna o nome do campo conforme o tipo							 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³AP6 Call Center				         	                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TkFieldType(nTipo)  

	Local cCampo := ""
	
	Default nTipo := 0
	
	Do Case
		Case (nTipo == 0)
			cCampo:= "U5_CONTAT"

		Case (nTipo == 1)
			cCampo:= "U5_FONE"

		Case (nTipo == 2)
			cCampo:= "U5_CELULAR"

		Case (nTipo == 3)
			cCampo:= "U5_FAX"

		Case (nTipo == 4)
			cCampo:= "U5_FCOM1"

		Case (nTipo == 5)
			cCampo:= "U5_FCOM2"

		Case (nTipo == 6)
			cCampo:= "U5_CONTAT"
			
		Case (nTipo == 7)
			cCampo:= "U5_EST"

		Case (nTipo == 8)
			cCampo:= "U5_DDD"

		Case (nTipo == 9)
			cCampo:= "U5_CODPAIS"

		Case (nTipo == 10)
			cCampo:= "U5_EMAIL"

		Case (nTipo == 11)
			cCampo:= "U5_MUN"

	EndCase

Return( cCampo )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk271Entidade    ³ Autor ³ Vendas Clientes       ³ Data ³ 23/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carrega os campos da ENTIDADE selecionada				        	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso   	 ³AP7 Call Center						     				         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TkEntidade(cEntidade,cChave,nTipo,nOrdEnt, lPDEval) 

/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³A ordem dos campos deve seguir a lista abaixo - se for incluido ou alterado algum  ³
	³campo isso sempre deve ser feito para todas as ENTIDADES                           ³
	³                                                                                   ³
	³01 - Nome                                                                          ³
	³02 - Endereco                                                                      ³
	³03 - Municipio                                                                     ³
	³04 - Estado                                                                        ³
	³05 - CEP                                                                           ³
	³06 - Telefone  - Comercial - 1                                                     ³ 
	³07 - E-mail                                                                        ³
	³08 - Homepage                                                                      ³
	³09 - DDD				                                                            ³
	³10 - BAIRRO	                                                                    ³
	³11 - Fantasia	                                                                    ³
	³12 - Loja	                                                                    	³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

Local cCampo		:= ""				//Nome do campo da entidade
Local cRet			:= ""				//Retorno da funcao
Local cSource		:= ""
Local aTbCpos		:= {{"SU2", {"U2_CONCOR",  "U2_END",     "U2_MUN",     "U2_EST",     "U2_CEP",     "U2_TEL",     "",          "",          "U2_DDD",  "U2_BAIRRO",  "",           ""}},;				//Concorrentes
             		    {"AC4", {"AC4_NOME",   "AC4_END",    "AC4_MUN",    "AC4_EST",    "AC4_CEP",    "AC4_TEL",    "",          "AC4_HPAGE", "AC4_DDD", "AC4_BAIRRO", "AC4_NREDUZ", ""}},;				//Parceiros
             		    {"ACH", {"ACH_RAZAO",  "ACH_END",    "ACH_CIDADE", "ACH_EST",    "ACH_CEP",    "ACH_TEL",    "ACH_EMAIL", "ACH_URL",   "ACH_DDD", "ACH_BAIRRO", "ACH_NFANT",  "ACH_LOJA"}},;		//Suspect
             		    {"SA1", {"A1_NOME",    "A1_END",     "A1_MUN",     "A1_EST",     "A1_CEP",     "A1_TEL",     "A1_EMAIL",  "A1_HPAGE",  "A1_DDD",  "A1_BAIRRO",  "A1_NREDUZ",  "A1_LOJA"}},;		//Cliente
             		    {"SA2", {"A2_NOME",    "A2_END",     "A2_MUN",     "A2_EST",     "A2_CEP",     "A2_TEL",     "A2_EMAIL",  "A2_HPAGE",  "A2_DDD",  "A2_BAIRRO",  "A2_NREDUZ",  "A2_LOJA"}},;		//Fornecedor
             		    {"SA3", {"A3_NOME",    "A3_END",     "A3_MUN",     "A3_EST",     "A3_CEP",     "A3_TEL",     "A3_EMAIL",  "A3_HPAGE",  "",        "A3_BAIRRO",  "A3_NREDUZ",  ""}},;				//Vendedor
             		    {"SA4", {"A4_NOME",    "A4_END",     "A4_MUN",     "A4_EST",     "A4_CEP",     "A4_TEL",     "A4_EMAIL",  "A4_HPAGE",  "A4_DDD",  "A4_BAIRRO",  "A4_NREDUZ",  ""}},;				//Transportadora
             		    {"SUS", {"US_NOME",    "US_END",     "US_MUN",     "US_EST",     "US_CEP",     "US_TEL",     "US_EMAIL",  "US_URL",    "US_DDD",  "US_BAIRRO",  "US_NREDUZ",  "US_LOJA"}},;		//Prospect
             		    {"JA2", {"JA2_NOME",   "JA2_END",    "JA2_CIDADE", "JA2_EST",    "JA2_CEP",    "JA2_TEL",    "",          "",          "",        "JA2_BAIRRO", "",           ""}},;				//Alunos
             		    {"BA1", {"BA1_NOMUSR", "BA1_ENDERE", "BA1_MUNICI", "BA1_ESTADO", "BA1_CEPUSR", "BA1_TELEFO", "",          "",          "BA1_DDD", "BA1_BAIRRO", "BA1_NREDUZ", ""}},;				//Familia/Usuario
             		    {"RD0", {"RD0_NOME",   "",           "",           "",           "",           "",           "",          "",          "",        "",           "",           ""}},;
             		    {"BAU", {"BAU_NOME",   "BAU_END",    "BAU_MUN",    "BAU_EST",    "BAU_CEP",    "BAU_TEL",    "BAU_EMAIL", "BAU_WEB",   "",        "BAU_BAIRRO", "BAU_NREDUZ", ""}}}					//Rede de Atendimento (Prestador PLS)
Local nPosTb		:= aScan(aTbCpos,{|x| x[01] == cEntidade})

Default nOrdEnt	:= 1
Default lPDEval := .F.  

lProspect := .F.

If ! Empty(cEntidade) .AND. ! Empty(cChave) .AND. nTipo > 0 .AND. nTipo < 13		// Para proteger a funcao caso ocorra algum problema de integridade
	If nPosTb > 0
		lProspect		:= (cEntidade == "SUS")  //Prospect
		If (cEntidade == "BA1" .AND. nTipo == 1)
			nOrdEnt	:= If(len(Alltrim(cChave)) > 17, 1, GetNewPar("MV_PLORDTM", 2))	//Verifica o tipo de chave utilizada para posicionar no indice correto
		EndIf
		If (cEntidade == "BAU" .AND. nTipo == 1)
			nOrdEnt	:= 1	//Verifica o tipo de chave utilizada para posicionar no indice correto
		EndIf
		cCampo			:= aTbCpos[nPosTb, 2, nTipo]
	Else
		If _lTmkEnt
			cCampo		:= ExecBlock("TMKENT", .F., .F., {cEntidade, nOrdEnt, nTipo})
		Endif
	EndIf
 
	If ! Empty(cCampo)		
		cRet		:= CRIAVAR(cCampo,.F.)
		(cEntidade)->(DbSetOrder(nOrdEnt))
		(cEntidade)->(MsSeek(xFilial(cEntidade) + cChave))		
		cRet		:= If(cCampo $ ("A1_LOJA|A2_LOJA|US_LOJA|ACH_LOJA"), (cEntidade)->&(cCampo), AllTrim((cEntidade)->&(cCampo)))
		If lPDEval
			cSource := TkPDxFun() 
			cRet 	:= FATPDObfuscate(cRet,cCampo,cSource)
		Endif
	Endif
Endif
Return(cRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 TkPDxFun	       ³ Autor ³ Vendas Clientes       ³ Data ³ 23/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carrega os campos Protegidos							        	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso   	 ³ Call Center							     				         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TkPDxFun()

	Local cSource 	:= ""
	Local aPDFields := { "U2_CONCOR",  "U2_END",     "U2_MUN",     "U2_EST",     "U2_CEP",     "U2_TEL","U2_DDD",  "U2_BAIRRO",;
             		    "AC4_NOME",   "AC4_END",    "AC4_MUN",    "AC4_EST",    "AC4_CEP",    "AC4_TEL", "AC4_HPAGE", "AC4_DDD", "AC4_BAIRRO", "AC4_NREDUZ",;
             		    "ACH_RAZAO",  "ACH_END",    "ACH_CIDADE", "ACH_EST",    "ACH_CEP",    "ACH_TEL",    "ACH_EMAIL", "ACH_URL",   "ACH_DDD", "ACH_BAIRRO", "ACH_NFANT",  "ACH_LOJA",;
             		    "A1_NOME",    "A1_END",     "A1_MUN",     "A1_EST",     "A1_CEP",     "A1_TEL",     "A1_EMAIL",  "A1_HPAGE",  "A1_DDD",  "A1_BAIRRO",  "A1_NREDUZ",  "A1_LOJA",;
             		    "A2_NOME",    "A2_END",     "A2_MUN",     "A2_EST",     "A2_CEP",     "A2_TEL",     "A2_EMAIL",  "A2_HPAGE",  "A2_DDD",  "A2_BAIRRO",  "A2_NREDUZ",  "A2_LOJA",;
             		    "A3_NOME",    "A3_END",     "A3_MUN",     "A3_EST",     "A3_CEP",     "A3_TEL",     "A3_EMAIL",  "A3_HPAGE", "A3_BAIRRO",  "A3_NREDUZ",;
             		    "A4_NOME",    "A4_END",     "A4_MUN",     "A4_EST",     "A4_CEP",     "A4_TEL",     "A4_EMAIL",  "A4_HPAGE", "A4_DDD",  "A4_BAIRRO",  "A4_NREDUZ",;
             		    "US_NOME",    "US_END",     "US_MUN",     "US_EST",     "US_CEP",     "US_TEL",     "US_EMAIL",  "US_URL", "US_DDD",  "US_BAIRRO",  "US_NREDUZ",  "US_LOJA",;
             		    "JA2_NOME",   "JA2_END",    "JA2_CIDADE", "JA2_EST",    "JA2_CEP",    "JA2_TEL","JA2_BAIRRO",;
             		    "BA1_NOMUSR", "BA1_ENDERE", "BA1_MUNICI", "BA1_ESTADO", "BA1_CEPUSR", "BA1_TELEFO", "BA1_DDD", "BA1_BAIRRO", "BA1_NREDUZ",;
             		    "RD0_NOME", "BAU_NOME", "BAU_END", "BAU_MUN", "BAU_EST", "BAU_CEP", "BAU_TEL", "BAU_EMAIL", "BAU_WEB", "BAU_BAIRRO", "BAU_NREDUZ",;
						"U5_CONTAT","U5_FONE","U5_FAX","U5_FCOM1","U5_FCOM2","U5_CELULAR","U5_EMAIL","U5_EST","U5_DDD","U5_CODPAIS","U5_MUN"}
	
	cSource := FATPDLoad(Nil, Nil, aPDFields) 

	aSize(aPDFields, 0)
	aPDFields := Nil  

Return cSource    

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk271Contato  ³ Autor ³ Vendas Clientes       ³ Data ³ 22/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Mostra todas as entidades dos contatos    	                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso   	 ³AP6 Call Center						     				      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TkEntContato(cContato)

Local aArea		:= GetArea()		 				//Salva a area atual
Local aChave		:= TkEntEstru()		 			//Array de estrutura da chave para demonstracao
Local aCont		:= {}				 				//Array com os contatos
Local aPDFields		:= {"A1_NOME"}					//Campos utilizados na carga do função FATPDLoad
Local aPDCols 		:= {"","","A1_NOME"}			//Campos utilizados no Listbox
Local nOpcao		:= 0		  						//Opcao de resposta
Local nPos			:= 0								//Posicao escolhida no array                   
Local nPosEnt		:= 0			 					//Posicao da entidade dentro doa array de estrutura
Local oLbx												//Listbox
Local oDlg							 					//Tela	
Local cEnt			:= Space(3)			 			//Alias da Entidade
Local cCodEnt		:= Space(25)						//Codigo da Entidade	
Local cEntidade	:= ""				 	   			//Alias : SA1
Local cDescInd	:= Space(40)		 				//Indice: Codigo + Loja
Local cChave		:= ""				 				//Codigo: 00000101
Local cDescChave	:= ""				 				//Descr : Empresa X Ltda.
Local cDescEnt	:= Space(40)		 				//Nome  : Cadastro de Clientes
Local cDescCod	:= Space(40)						//Nome da Empresa de acordo com a entidade         
Local cEntChave	:= ""    			  				//Chave da entidade para exibicao no browse
Local lShowBtn	:= .T.				 				//Flag para exibir ou nao o botao de CANCELA e INCLUIR
Local nPosBtn		:= 225				 				//Posicao do botao de OK
Local aAreaSA1	:= {}			   					//Area do SA1
Local cStatusA1	:= ""								//Status do cliente (bloqueado ou nao)
Local nTamCon		:= GetSX3Cache("UC_CODCONT","X3_TAMANHO")			//Tamanho do campo UC_CODCONT
Local lRet			:= .T.
Local lMvTmkF3 	:= SuperGetMv("MV_TMKF3",.F.)
Local cFilAC8		:= xFilial("AC8")
Local cFilSA1		:= xFilial("SA1")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se a funcao foi executada por gatilho³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If TkSetTrigger()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³A funcao e recurssiva se o parametro estiver preenchido mantem o valor³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cContato	:= IIf(ValType(cContato) == "C" ,cContato,"")
	
	DbSelectArea("AC8")
	DbSetOrder(1)
	If ! DbSeek(cFilAC8 + cContato)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Nao existe relacionamentos para o CONTATO entao executa a inclusao das entidades.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nOpcao := TkInsertEnt(cContato,@aCont,@oLbx)
		If nOpcao == 1
			// Se o operador ja elencou uma entidade para esse contato
			lShowBtn := .F.
			nPosBtn  := 285
		Endif
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega todos as ENTIDADES relacionadas do CONTATO escolhido³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("AC8")
	DbSetOrder(1)
	If DbSeek(cFilAC8 + cContato , .T.)
		If nOpcao == 1
			aCont := {}
		Endif
			
		While !Eof() .AND. (cFilAC8 == AC8->AC8_FILIAL) .AND. (cContato == AC8->AC8_CODCON)

			If TmkBlqCont(AllTrim(AC8->AC8_ENTIDA), cFilSA1 + AllTrim(AC8->AC8_CODENT))	// Verifica se há bloqueio na entidade
				AC8->(DbSkip())
				LOOP
			EndIf
			
			nPosEnt := Ascan(aChave, {|x| x[1] == AllTrim(AC8->AC8_ENTIDA)})	// Busca a estrutura de chaves das entidades
            
			If nPosEnt > 0
            	// Caso encontrou utiliza para demonstrar no browse
				cEntChave := Substr(AC8->AC8_CODENT,1,aChave[nPosEnt][2])
				If aChave[nPosEnt][3] > 0
					// Caso exista filial/loja exibe concatenando com o codigo
					cEntChave += "-" + Substr(AC8->AC8_CODENT,aChave[nPosEnt][2]+1,aChave[nPosEnt][3])
				Endif
			Else
				// Caso nao encontrou utiliza diretamente o campo AC8_CODENT	                                                    
				cEntChave := AllTrim(AC8->AC8_CODENT)
			Endif
	
			cEnt		:= AllTrim(AC8->AC8_ENTIDA)											//Alias : SA1
			cDescEnt	:= Posicione("SX2",1,cEnt,"X2NOME()")								//Nome  : Cadastro de Clientes
			cCodEnt	:= AllTrim(AC8->AC8_CODENT)											//Codigo: 00000101
			cDescCod	:= TkEntidade(cEnt,cCodEnt,1)										//Descr : Empresa X Ltda.
			cDescInd	:= AllTrim(Posicione("SIX",1,cEnt + "1","SIXDescricao()"))		//Indice: Codigo + Loja
			
			If _lTmkEntCo
	        	// P.E para filtrar a entidade
				lRet := ExecBlock("TMKENTCO",.F.,.F.,{cEnt,cCodEnt})
			Endif
        
			If lRet
				Aadd(aCont,{cEnt,;			// 1 - Alias : SA1
				            cDescInd,;		// 2 - Indice: Codigo + Loja
				            cCodEnt,;		// 3 - Codigo: 00000101
				            cDescEnt,;		// 4 - Nome  : Cadastro de Clientes
				            cDescCod,;		// 5 - Descr : Empresa X Ltda.
				            cEntChave})		// 6 - Chave para demonstracao no browse
			Endif
	
			DbSelectArea("AC8")
			DbSkip()
		EndDo
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se existe relacionamento para esse CONTATO mostra as Entidades³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aCont) > 0
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se nao estiver usando a entrada automatica³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !( Type("lTk271Auto") <> "U" .AND. lTk271Auto )
			If !lMvTmkF3 //não apresenta Dialog se utiliza seleção de entidades

				FATPDLoad(/*cUserPDA*/, /*aAlias*/, aPDFields)
				
				DEFINE MSDIALOG oDlg FROM  300,20 TO 560,650 TITLE STR0002 PIXEL //"Relacionamento Contatos X Entidades"
				@01,03 TO 110,315 LABEL "" OF oDlg PIXEL
				@05,05 LISTBOX oLbx FIELDS HEADER STR0003, STR0028, STR0006 SIZE 307,103 NOSCROLL OF oDlg PIXEL ON DBLCLICK(nOpcao :=1 , nPos := oLbx:nAt ,oDlg:End())	//"Entidade"##"Codigo"##"Descricao"
				oLbx:SetArray(aCont)
				If FATPDActive() .And. FTPDUse(.T.)
					oLbx:aObfuscatedCols := FATPDColObfuscate(aPDCols)
				EndIf
				oLbx:bLine	:= {||{aCont[oLbx:nAt,4], aCont[oLbx:nAt,6], aCont[oLbx:nAt,5] }}
				oLbx:nAt	:= 1
				DEFINE SBUTTON FROM 115,nPosBtn TYPE 1 ENABLE OF oDlg ACTION (nOpcao:=1, nPos:=oLbx:nAt, oDlg:End())  	//OK
				If lShowBtn
					DEFINE SBUTTON FROM 115,255 TYPE 2 ENABLE OF oDlg ACTION (nOpcao:=0,oDlg:End())                //CANCELA
					DEFINE SBUTTON FROM 115,285 TYPE 4 ENABLE OF oDlg ACTION TkInsertEnt(cContato,@aCont,@oLbx)    //INCLUI
				Endif
				FATPDLogUser("TKENTCONTA")
				ACTIVATE MSDIALOG oDlg CENTER
				
				FATPDUnload() 
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Ativa o cronometro da tela 10- 10 Segundos³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cTimeIni := Time()
				oTimerCro:Activate()
			Else
				nOpcao	:= 1
				nPos	:= TKExistEnt(aCont, M->UC_CHAVE, cCodEnt, M->UC_ENTIDAD)
				If nPos == 0 //Não encontrou contas limpa campos na memoria
					M->UC_CODCONT	:= Space(nTamCon)
					M->UC_DESCNT	:= ""
					M->UC_ENTIDAD	:= ""
					M->UC_DESCENT	:= ""
					M->UC_DESCIND	:= ""
					M->UC_CHAVE  	:= ""
					M->UC_DESCCHA	:= ""
				EndIf
			EndIf
		Else
			nOpcao:=1
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Pesquisa no array aCont qual e a posicao do contato passado no  ³
			//³array aAutoCab (entrada automatica) 		                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nPos:= Ascan(aCont,{|x| x[1]+x[3] == aAutoCab[ProcTmk("UC_ENTIDAD"),2] + AllTrim(aAutoCab[ProcTmk("UC_CHAVE"),2]) })
		Endif
		
		If (nOpcao == 1) .AND. nPos > 0
			cEntidade	:= aCont[nPos,1]	// 1 - Alias : SA1
			cDescInd	:= aCont[nPos,2]	// 2 - Indice: Codigo + Loja
			cChave		:= aCont[nPos,3]	// 3 - Codigo: 00000101
			cDescEnt	:= aCont[nPos,4]	// 4 - Nome  : Cadastro de Clientes
			cDescChave	:= aCont[nPos,5]	// 5 - Descr : Empresa X Ltda.
			
			lProspect := (cEntidade == "SUS")
		
			TkCliente(cEntidade,cChave)
	
			M->UC_DESCENT	:= cDescEnt		//Cadastro de Clientes
			M->UC_DESCIND	:= cDescInd		//Codigo + Loja
			M->UC_CHAVE	:= cChave			//00000101
			M->UC_DESCCHA	:= cDescChave		//Empresa X Ltda.
		Endif
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Nenhuma entidade encontrada:        ³
		//³Limpa os campos e notifica o usuario³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !( Type("lTk271Auto") <> "U" .AND. lTk271Auto )
			Help(" ",1,"TK061NAC8")
		EndIf
		M->UC_CODCONT	:= Space(nTamCon)
		M->UC_DESCNT	:= ""
		M->UC_ENTIDAD	:= ""
		M->UC_DESCENT	:= ""
		M->UC_DESCIND	:= ""
		M->UC_CHAVE  	:= ""
		M->UC_DESCCHA	:= ""
	Endif

Else
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza a variavel de memoria caso contrario o retorno da funcao vai limpar a variavel³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(M->UC_ENTIDAD)
		cEntidade := M->UC_ENTIDAD
	Endif

Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ativa novamente o flag de gatiho para TRUE - Dessa forma sera executado na proxima alteracao do campo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TkSetTrigger(.T.)
RestArea(aArea)
aSize(aPDFields, 0)
aSize(aPDCols, 0)
Return(cEntidade)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³TkEntEstru    ³ Autor ³ Vendas Clientes       ³ Data ³ 15/08/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Estrutura das entidades                   	                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso   	 ³Call Center						     				          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TkEntEstru()

Local aEnt := {}		//Variavel de trabalho do array de entidades

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Seleciona a area para garantir que a tabela sera aberta³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SA1")
DbSelectArea("SA2")
DbSelectArea("AC4")
DbSelectArea("ACH")
DbSelectArea("SA4")
DbSelectArea("SU2")
DbSelectArea("SUS")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Adiciona no array a estrutura de chaves                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd( aEnt, {"SA1",Len(SA1->A1_COD), Len(SA1->A1_LOJA) } )
Aadd( aEnt, {"SA2",Len(SA2->A2_COD), Len(SA2->A2_LOJA) } )
Aadd( aEnt, {"AC4",Len(AC4->AC4_PARTNE), 0 } )
Aadd( aEnt, {"ACH",Len(ACH->ACH_CODIGO), Len(ACH->ACH_LOJA) } )
Aadd( aEnt, {"SA4",Len(SA4->A4_COD), 0 } )
Aadd( aEnt, {"SU2",Len(SU2->U2_COD), 0 } )
Aadd( aEnt, {"SUS",Len(SUS->US_COD),Len(SUS->US_LOJA) } )
Aadd( aEnt, {"BA1",17,0} )

Return(aEnt)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³TkEntTam      ³ Autor ³ Vendas Clientes       ³ Data ³ 05/11/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Função utilizada para a obtenção dos tamanhos dos campos chaves³±±
±±³          ³ da entidade.                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ cPar1 = Entidade do qual se deseja obter os tamanhos           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRet = Array com 2 posicoes, onde:                             ³±±
±±³          ³        aRet[1] = Tamanho do campo Cliente ou Respectivo        ³±±
±±³          ³        aRet[2] = Tamanho do campo Loja ou Respectivo           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso   	 ³Call Center						     				          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TkEntTam( cEntidade )
Local aArea		:= GetArea()												// Salva a área atual
Local aEntStr		:= TkEntEstru()											// Pega a estrutura dos campos chave das entidades
Local nPosEntStr	:= aScan(aEntStr, {|x| x[1] == cEntidade})			// Pega a posição da entidade na estrutura dos campos chave das entidades
Local nTamCod		:= If(nPosEntStr > 0, aEntStr[nPosEntStr, 2], 6)		// Tamanho do campo código da entidade
Local nTamLoja	:= If(nPosEntStr > 0, aEntStr[nPosEntStr, 3], 2)		// Tamanho do campo loja da entidade

RestArea(aArea)
Return {nTamCod, nTamLoja}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk271InsertEnt ³ Autor ³ Vendas Clientes       ³ Data ³ 21/06/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Insere uma nova entidade para o contato e cria o relacionamento  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso 	 ³Call Center			                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TkInsertEnt(cContato,aCont,oLbx)

Local aArea		:= GetArea()                   		// Salva a area atual
Local aChaveEnt	:= TkEntEstru() 					// Array de estrutura da chave para demonstracao
Local aEntidades:= {}								// Array com as entidades que possuem contatos
Local aOpcoes   := {}								// Array com as entidades que possuem contatos
Local aMsRel    := {}								// Relacionamentos da MsRelation
Local aChave	:= {} 								// Array com as chaves do MsRelation
Local nEnt		:= 1								// Numero da Entidades selecionada que possuem contatos
Local nOpca     := 0								// Opcao do botao 
Local nLoop		:= 0                                // Controle de lacos
Local nScan		:= 0								// Pesquisa da entidade no MsRelation
Local nPosEnt   := 0		 						// Posicao da entidade dentro doa array de estrutura
Local cCad		:= cCadastro						// Salva cCadastro
Local cEntChave := ""    							//Chave da entidade para exibicao no browse
Local aRots		:= aClone(aRotina)					// Salva aRotinas
Local oDlg		:= Nil								// Janela
Local oEntidade := Nil								// Objeto que exibira as entidades para a escolha
Local oPanel	:= Nil								// Panel que contem o radio
Local bBlock	:= Nil								// Bloco para setar a variavel para o radio
Local nTamCon	:= GetSX3Cache("UC_CODCONT","X3_TAMANHO")			// Tamanho do campo UC_CODCONT
Local lJaExiste := .F.								// Se o relacionamento já existe

Local cEnt     := Space(3)							// Alias : SA1			
Local cDescInd := Space(40)							// Indice: Codigo + Loja
Local cCodEnt  := Space(25)							// Codigo: 00000101
Local cDescEnt := Space(40)							// Nome  : Cadastro de Clientes
Local cDescCod := Space(40)            	 			// Descr : Empresa X Ltda.

Local cFilSX5		:= xFilial("SX5")
Local cFilAC8		:= xFilial("AC8")

cCadastro	:= STR0023 //Atendimento
aRotina	:= MenuDef()  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica quais as entidades que possuem contatos.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SX5")
DbSetOrder(1)
DbSeek(cFilSX5 + "T5",.T.)
While !Eof() .AND. (cFilSX5 == SX5->X5_FILIAL) .AND. (SX5->X5_TABELA == "T5")
	Aadd(aEntidades,{	ALLTRIM(SX5->X5_CHAVE),;
						ALLTRIM(OemToAnsi(X5DESCRI()))})
	SX5->(DbSkip())                                                                                        
End
      
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Sorteia o array pela descricao dos arquivos.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aEntidades:= ASort(aEntidades,,,{|x,y| x[2] < y[2]})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Alimenta o array com as opcoes que serao exibidos para o usuario.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AEval( aEntidades, { |x| AAdd( aOpcoes, x[2] ) } ) 	

DEFINE MSDIALOG oDlg FROM  300,20 TO 580,330 TITLE STR0011  PIXEL OF oMainWnd //"Selecione a entidade"

	@05,03 MSPANEL oPanel VAR "" OF oDlg SIZE 120,132 LOWERED

	bBlock := &("{||nEnt:= oEntidade:nOption }")				

	oEntidade	:= TRadMenu():New(  05, 05, aOpcoes,;
									bSETGET(nEnt), oPanel , NIL ,bBlock ,;
									CLR_BLUE, NIL, NIL, .T., NIL,;
									100, Len(aOpcoes)*2, NIL, .T., .T.,;
									.T. )

	DEFINE SBUTTON FROM 05,125 TYPE 14 	ENABLE OF oDlg ACTION ;				//VISUALIZAR / Funciona como o OK da tela 
			(	DbSelectArea(aEntidades[nEnt,1]),;
				nOpca:= IIf(Conpad1("","","",Iif(aEntidades[nEnt,1] <> "BA1",aEntidades[nEnt,1],"BY2PLS"),,,.F.),1,0),;
				IIf(nOpca == 1,oDlg:End(),"")	)

	DEFINE SBUTTON FROM 25,125 TYPE 2 ENABLE OF oDlg ACTION (oDlg:End())   //CANCELA

ACTIVATE MSDIALOG oDlg CENTERED

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o operador escolheu OK no F3 da entidade ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nOpca == 1)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Grava o NOVO relacionamento	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aMsRel := MsRelation()
	
	If !Empty( nScan := Ascan( aMsRel, { |x| x[1] == aEntidades[nEnt,1] } ) )
		
		cCodEnt  := ""
		aChave   := aMsRel[ nScan, 2 ]
		
		For nLoop := 1 To Len(aChave)
			cCodEnt += ( aEntidades[nEnt,1] )->( FieldGet( FieldPos( aChave[ nLoop ] ) ) )
		Next nLoop
		
		DbSelectArea("AC8")
		If DbSeek(	cFilAC8 + cContato + aEntidades[nEnt,1] + xFilial(aEntidades[nEnt,1]) + cCodEnt )
			MsgStop (STR0032) //"Este relacionamento já existe e não será gravado"
			lJaExiste := .T.
		Else 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se a entidade esta com bloqueio no campo XX_MSBLQL³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If TmkBlqCont(aEntidades[nEnt,1], xFilial(aEntidades[nEnt,1]) + cCodEnt)
				Help(" ",1,"REGBLOQ")
				M->UC_CODCONT	:= Space(nTamCon)
				M->UC_DESCNT	:= ""
				M->UC_ENTIDAD	:= ""
				M->UC_DESCENT	:= ""
				M->UC_DESCIND	:= ""
				M->UC_CHAVE  	:= ""
				M->UC_DESCCHA	:= ""
				cCadastro		:= cCad
				aRotina  		:= aClone(aRots)				
				RestArea(aArea)				
				Return(0)				
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Gravacao do novo relacionamento³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				RecLock("AC8",.T.)
				Replace AC8->AC8_FILIAL With cFilAC8			                 		// Filial: 02
				Replace AC8->AC8_FILENT With xFilial(aEntidades[nEnt,1])    		// Filial da Entidade: 01
				Replace AC8->AC8_ENTIDA With aEntidades[nEnt,1]             		// Alias : SA1
				Replace AC8->AC8_CODENT With cCodEnt								// Codigo: 00000101
				Replace AC8->AC8_CODCON With cContato                       		// Contato:000001
				MsUnLock()
				DbCommit()
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busca a estrutura de chaves das entidades                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPosEnt := Ascan( aChaveEnt, { |x| x[1] == ALLTRIM(AC8->AC8_ENTIDA) })
            
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Caso encontrou utiliza para demonstrar no browse            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nPosEnt > 0
			cEntChave := Substr(AC8->AC8_CODENT,1,aChaveEnt[nPosEnt][2])

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Caso exista filial/loja exibe concatenando com o codigo     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aChaveEnt[nPosEnt][3] > 0
				cEntChave += "-" + Substr(AC8->AC8_CODENT,aChaveEnt[nPosEnt][2]+1,aChaveEnt[nPosEnt][3])
			Endif   
		Else	                                                    
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Caso nao encontrou utiliza diretamente o campo AC8_CODENT   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cEntChave := ALLTRIM(AC8->AC8_CODENT)
		Endif		

	
		cEnt    := ALLTRIM(AC8->AC8_ENTIDA)									// Alias : SA1
		cDescEnt:= Posicione("SX2",1,cEnt,"X2NOME()")						// Nome  : Cadastro de Clientes
		cCodEnt := ALLTRIM(AC8->AC8_CODENT)         						// Codigo: 00000101
		cDescCod:= TkEntidade(cEnt,cCodEnt,1)       						// Descr : Empresa X Ltda.
		cDescInd:= ALLTRIM(Posicione("SIX",1,cEnt + "1","SIXDescricao()"))	// Indice: Codigo + Loja 
		      
		If !lJaExiste
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Carrega os relacionamentos do contato.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Aadd(aCont,{cEnt,;			// Alias : SA1
						cDescInd,;		// Indice: Codigo + Loja
						cCodEnt,;		// Codigo: 00000101
						cDescEnt,;		// Nome  : Cadastro de Clientes
						cDescCod,;		// Descr : Empresa X Ltda.
						cEntChave})		// Chave da entidade 
		EndIf

		If oLbx <> NIL
			oLbx:SetArray(aCont)
			oLbx:bLine:={||{aCont[oLbx:nAt,4],;	//Entidade
							aCont[oLbx:nAt,6],;		//Codigo da Entidade			
							aCont[oLbx:nAt,5]}}		//Descricao
							
			oLbx:nAt := 1       	
			oLbx:Refresh()
		Endif
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura o ambiente salvo.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCadastro:= cCad
aRotina  := aClone(aRots)

RestArea(aArea)

Return(nOpca)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |MenuDef	³ Autor ³ Vendas Clientes       ³ Data ³12/12/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao de definição do aRotina                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRotina   retorna a array com lista de aRotina             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGATMK                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef() 

Local aRotina:= {		{ STR0007  ,"AxPesqui"   ,0 ,1 , , .F. },;  //"Pesquisar"
						{ STR0008  ,"AxVisual"   ,0 ,2 , , .T. },;  //Visualizar
						{ STR0009  ,"AxInclui"   ,0 ,3 , , .T. },;  //"Incluir"
						{ STR0010  ,"AxAltera"   ,0 ,4 , , .T. } }  //"Alterar"
Return(aRotina)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FSemana  ³ Autor ³ Vendas Clientes       ³ Data ³ 20/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Selecionar o Dia da Semana                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FSemana()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CALL CENTER                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FSemana( lGet , lHora)

Local MvPar												//Parametro do SX6
Local MvPar2											//Parametro do SX6
Local MvPar3											//Parametro do SX6
Local MvPar4											//Parametro do SX6
Local cTitulo := ""										//Titulo da coluna
Local cOpcoes := ""										//Opcoes para escolha do dia
Local oDlg 												//Objeto do dialogo
Local nFor												//Contorle do for
Local cRet												//Retorno da funcao
Local oListbox											//Objeto da Listbox
Local aListBox											//Conteudo da ListBox
Local nOpca												//Retorno do dialogo (se confirmou ou nao)
Local oOk := LoaDbitmap( GetResources(), "LBOK" )		//Objeto:Figura para item selecionado
Local oNo := LoaDbitmap( GetResources(), "LBNO" )		//Objeto:Figura para item nao selecionado
Local aOpcoes := {}										//Titulos dos dias da semana

lHora := If(lHora == NIL,.T.,lHora)

If	lGet <> NIL
	mvPar  := &(ALLTRIM("MV_PAR01"))
	mvPar2 := &(ALLTRIM("MV_PAR02"))
	mvPar3 := &(ALLTRIM("MV_PAR03"))
	mvPar4 := &(ALLTRIM("lPerg"))

	mvRet  := "MV_PAR01"
	mvRet2 := "MV_PAR02"
	mvRet3 := "MV_PAR03"
	mvRet4 := "lPerg"
Else
	mvPar  := &(ALLTRIM(ReadVar()))   // Carrega Nome da Variavel do Get em Questao
	mvRet  := ALLTRIM(ReadVar())      // Iguala Nome da Variavel ao Nome variavel de Retorno
Endif

aOpcoes := {STR0012,STR0013,STR0014,STR0015,STR0016,STR0017,STR0018}
			//"Domingo","Segunda","Terca","Quarta","Quinta","Sexta","Sabado"
cOpcoes := "1234567"

cTitulo  := STR0019 //"Semana"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa a selecao dos dias³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cRet	:= MvPar
nLin1	:= .5
nCol1	:= 2
aListBox:= {}

cHora1:=Time()
cHora2:=cHora1

For nFor := 1 to Len(aOpcoes)
	Aadd(aListBox,{ ( SubStr(cOpcoes,nFor,1) $ MvPar ), aOpcoes[nFor] })
Next nFor

nOpca := 0
If !( Type("lTk070Auto") <> "U" .And. lTk070Auto )
	DEFINE MSDIALOG oDlg FROM 5, 5 TO 19, 50 TITLE STR0020 //"Escolha os Dias"
		
		@ nLin1,nCol1 LISTBOX oListBox VAR cVarQ ;
			FIELDS HEADER "",cTitulo;
			SIZE 150,62 ;
			ON DbLCLICK (aListBox:=TkInverte(oListBox:nAt,aListBox),oListBox:Refresh()) NOSCROLL
			
		oListBox:SetArray(aListBox)
		oListBox:bLine := { || {If(aListBox[oListBox:nAt,1],oOk,oNo),aListBox[oListBox:nAt,2]}}
		
		If ( lHora )
			@ 75,16  SAY STR0021 SIZE 28,7 OF oDlg PIXEL //"Hora Inicial:"
			@ 75,45  MSGET cHora1 PICTURE "99:99:99" SIZE 24,10 OF oDlg PIXEL WHEN .T.
			@ 75,90  SAY STR0022 SIZE 20,7 OF oDlg PIXEL //"Final:"
			@ 75,115 MSGET cHora2 PICTURE "99:99:99" VALID TkValHora(cHora1,cHora2) SIZE 24,10 OF oDlg PIXEL WHEN .T.
		Endif
	
		DEFINE SBUTTON FROM 89,105  TYPE 1 ACTION (nOpca := 1,IIf(cHora1>cHora2.AND.lHora,Help(" ",1,"HRMAIOR"),.T.),IIf(cHora1=cHora2.AND.lHora,Help(" ",1,"HRIGUAL"),.T.),IIf(cHora1>cHora2.AND.lHora,nOpca:=0,.T.),oDlg:End()) ENABLE OF oDlg
		
		DEFINE SBUTTON FROM 89,138  TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
	
	ACTIVATE MSDIALOG oDlg CENTERED
EndIf

If nOpca == 1
	cRet := ""
	
	For nFor := 1 TO Len(aListBox)
		If aListBox[nFor,1]
			cRet += SubStr(cOpcoes,nFor,1)
		Endif
	Next nFor

	If lHora .AND. nModulo == 32  
		M->U5_HORAV1:=cHora1
		M->U5_HORAV2:=cHora2
	ElseIf lHora
		M->U5_HORA1:=cHora1
		M->U5_HORA2:=cHora2
	Endif
	lRefresh:=.T.
Else
	cRet := ""	
	For nFor := 1 TO Len(aListBox)
		If aListBox[nFor,1]
			cRet += SubStr(cOpcoes,nFor,1)
		Endif
	Next nFor
Endif                        

MvPar := cRet
If	MvPar2 <> NIL
	MvPar2 := cHora1
	MvPar3 := cHora2
	MvPar4 := (nOpca == 1)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Devolve Resultado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
&MvRet := mvPar                                              
If	mvPar2 <> NIL
	&mvRet2 := mvPar2
	&mvRet3 := mvPar3
	&mvRet4 := mvPar4
Endif     

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TkInverte ³ Autor ³ Vendas Clientes       ³ Data ³ 28/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Inverte o valor selecionado no Listbox                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Posicao do item, ExpA2 = Array com os itens        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGATMK                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TkInverte(nAt,aArray)

aArray[nat,1] := !aArray[nat,1]

Return(aArray)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ TkNumero    ³ Autor ³ Vendas Clientes     ³ Data ³ 28/03/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para VALIDAR a numeracao do atendimento              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ ACF_CODIGO - SX3 - CALL CENTER                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TkNumero(cAlias,cCampo)
Local aArea		:= GetArea()						// Salva a area atual
Local cNumAtend	:= GetSxeNum(cAlias,cCampo)			// Numero do atendimento
Local nSaveSx8 	:= GetSX8Len()						// Funcao de numeracao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se houver problemas na tentativa de pegar um novo numero para o Telemarketing/Televendas³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea(cAlias)
DbSetOrder(1)
While .T.
	
	If ! DbSeek(xFilial(cAlias) + cNumAtend)
		Exit
	Endif
	While (GetSx8Len() > nSaveSx8)
		ConfirmSX8()
	End	
	
	cNumAtend:= GetSxeNum(cAlias,cCampo)
End

RestArea(aArea)
Return(cNumAtend)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk271DCliente³ Autor ³ Vendas Clientes       ³ Data ³04/02/02  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carrega o nome do Cliente/Prospect informado para TLV e TLC    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³Executado por GATILHO	 - Televendas e Telecobranca			 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TkDCliente(cCliente,cLoja)

Local aArea		:= GetArea()					// Salva a area atual
Local cArq			:= ""							// Nome da tabela utilizada
Local cDesc		:= CRIAVAR("A1_NOME",.F.)		// Nome do cliente/prospect
Local cAux 		:= cLoja						// Loja do cliente/prospect
Local cTipoAte	:= ""

If FunName() <> "TMKC010"
	If Empty(cLoja) .OR. (cLoja == NIL)
		cTipoAte	:= TkGetTipoAte()
		cAux		:= SuperGetMv("MV_LOJAPAD")
		If (cTipoAte $ "245") 	//Televendas, Ambos ou TMK x TLV
			M->UA_LOJA := cAux
		ElseIf (cTipoAte == "3") .And. !Empty(cCliente)		//Telecobranca
			M->ACF_LOJA := cAux
		Endif
	Endif
		
	lProspect	:= IIF(Type("lProspect") <> "U", lProspect, SUA->UA_PROSPEC)
	cArq		:= IIF(lProspect,"SUS","SA1")
	cDesc		:= Posicione(cArq,1,xFilial(cArq) + cCliente + cAux, SubStr(cArq,2,2) + "_NOME")
	
Else

	If SUA->UA_PROSPEC 
		DbSelectArea("SUS")
		DbSetOrder(1)
		If DbSeek(xFilial("SUS") + SUA->UA_CLIENTE + SUA->UA_LOJA)
			cDesc := SUS->US_NOME
		Endif
	Else
		DbSelectArea("SA1")
		DbSetOrder(1)
		If DbSeek(xFilial("SA1") + SUA->UA_CLIENTE + SUA->UA_LOJA)
			cDesc := SA1->A1_NOME
		Endif
	Endif
Endif

RestArea(aArea)

Return(cDesc)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tk271Operador  ³ Autor ³ Vendas Clientes       ³ Data ³29/03/00  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna o Codigo do Operador informado                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso	     ³SIGATMK    					          	       			       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TkOperador()
Local cOperador	:= Space(Len(SU7->U7_COD))	// Codigo do operador
Local aArea     := GetArea()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pesquisa o usuario no cadastro de operadores					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SU7->(DbSetOrder(4))
If SU7->(MsSeek(xFilial("SU7") + __cUserId)) // Nome completo
	cOperador	:= SU7->U7_COD
EndIf

RestArea(aArea)
Return(cOperador)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk271Limpa³ Autor ³ Vendas Clientes       ³ Data ³ 23/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Executa a inicializacao das variaveis comuns as rotinas de  ³±±
±±³          ³televendas,telemarketing e telecobranca                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso 	 ³ATENDIMENTO										    	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function TkLimpa(	oCrono		,cCrono			,nTimeSeg		,nTimeMin	,;
					nOpc		,oFolderTmk		,oEnchTmk		,lHabilita	,;
					oFolderTlv	,oEnchTlv		,nLiquido		,cCob		,;
					cEnt		,cCidadeC		,cCepC			,cUfC		,;
					cBairroc	,cCidadeE 		,cCepE			,cUfE		,;
					cBairroE	,nEntrada		,aParcelas		,nFinanciado,;
					cTransp		,cCodPagto		,cDescPagto		,nTxJuros	,;
					nVlJur		,nNumParcelas	,cCodTransp		,oFolderTlc	,;
					oEnchTlc	,cCodAnt		,aSx3SUA		,aSx3SUC	,;
					lExibeMsg	,cCliAnt		,lExibeHelp		,cLock		)					
					
Local cAlias	:= ""		// Armazena o Alias para ler do SX3
Local cCampo	:= ""		// Variavel auxiliar para o CRIAVAR
Local nCont		:= 0    	// Contador         
Local nLenSx3   := 0 		// Contador para o SX3
Local nLenEnch	:= 0 		// Contador para refresh da enchoice
Local nPosLoja	:= 0		// Posicao do campo UA_LOJA na enchoice oEnchTlv
Local nOldOpc	:= nOpc		// Grava histórico do nOpc, para saber se vai ou não limpar o semáforo do loja
Local cCpoFocus := ""		// Campo que o operador está posicionado
Local cTipoAte	:= ""

Default lExibeHelp := .F.	// Informa um valor Default 
Default cLock	:= ""

If LTMKLIMPA
	lRet := U_TMKLIMPA(nOpc,lExibeMsg)
	If !lRet
		Return(lRet)
	Endif	
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se o operador estiver com o foco em algum campo do   ³
//³ aCols (SUD, SUB e ACG), não será executado a limpeza ³
//³ do atendimento, até que o operador saia do foco.	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTipoAte	:= TkGetTipoAte()
If (nFolder == 1) .And. (cTipoAte $ "145")		//Telemarketing
	cCpoFocus := ReadVar()
	If !Empty(cCpoFocus) .And. ("UD_" $ cCpoFocus)      
		Return(.F.) 
	EndIf
ElseIf (nFolder == 2) .And. (cTipoAte $ "245")	//Televendas
	cCpoFocus := ReadVar()
	If !Empty(cCpoFocus) .And. ("UB_" $ cCpoFocus)      
		Return(.F.) 
	EndIf
ElseIf (nFolder == 3) .And. (cTipoAte $ "34")		//Telecobrança
	cCpoFocus := ReadVar()
	If !Empty(cCpoFocus) .And. ("ACG_" $ cCpoFocus)      
		Return(.F.) 
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se esta limpando retorna a condicao de inclusao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nOpc     	:= 3
Inclui   	:= .T.
lAltTpOper 	:= .T.
lExibeHelp	:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se foi usado o SX8 e nao foi feita nenhuma inclusao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If __lSx8
	RollBackSx8()
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Limpa os objetos comuns da tela        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nFolder == 1)
	If (cTipoAte $ "145")  //Telemarketing, Ambos ou TMK x TLV
		cAlias:= "SUC"
		
		cChave := cEmpAnt + xFilial( "SUC" ) + M->UC_CODIGO
		Tk271UnLock( cChave )
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inicializo a GETDADOS   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TK271Config("SUD","UD_CODIGO",nOpc,NIL,NIL,NIL)
		
		//Seta o aCols e aHeader para o Telemarketing
		aHeader  := {}
		aCols    := {}
		aHeader  := aClone(aSvFolder[1][1])
		aCols    := aClone(aSvFolder[1][2])
		n		 := aSvFolder[1][3]
		oGetTmk:NOPC:=3
		oGetTmk:OBROWSE:NOPC:=3
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Antes de limpar os objestos, forcar o foco no browse, pq caso ³
		//³o foco esteja no campo Observacao (Memo)o campo nao e limpo   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oGetTmk:oBrowse:SetFocus()

		oGetTmk:oBrowse:Refresh(.T.)
		oFolderTmk:Refresh()
		
		Tk271HabObj(.T.,@lHabilita,@oEnchTmk)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza o status da tabela de atendentes IN/OUT para o Monitor³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TkGrvSUV(__cUserId, "TMK0")

	 	//Faz o desbloqueio do atendimento no momento da limpeza, para liberá-lo para outro operador.
	 	If !Empty(cLock)
			UnLockByName(cLock,.T.,!Empty(xFilial("SUC")),.T.)
			cLock := ""
		EndIf
		
	ElseIf (cTipoAte == "2")
		cAlias:= "SUA"
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Libera o orçamento no loja, claro, se o orçamento for do loja.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (nOldOpc == 4)
			TkLibLoja("D")
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Variaveis da condi‡„o de pagamento    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nLiquido 	:= 0
		nEntrada 	:= 0
		aParcelas	:= {}
		nFinanciado	:= 0
		nTxJuros	:= 0
		nVlJur		:= 0
		nNumParcelas:= 0
		
		cCob     	:=""
		cEnt     	:=""
		cCidadeC 	:=""
		cCepC    	:=""
		cUfC     	:=""
		cBairroc 	:=""
		cCidadeE 	:=""
		cCepE    	:=""
		cUfE     	:=""
		cBairroE 	:=""
		cTransp 	:= ""
		cCodPagto	:= CRIAVAR("E4_CODIGO",.F.)
		cDescPagto	:=""
		cCodTransp 	:= CRIAVAR("A4_COD",.F.)
		cCodAnt		:= ""
		cCliAnt		:= ""
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Variavel private para consulta TEF³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cGaranCh := ""
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inicializo a GETDADOS   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TK271Config("SUB","UB_NUM",nOpc,NIL,NIL,NIL)
		
		aHeader:= aClone(aSvFolder[2][1])
		aCols  := aClone(aSvFolder[2][2])
		n	   := aSvFolder[2][3]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Antes de limpar os objestos, forcar o foco no browse, pq caso ³
		//³o foco esteja no campo Observacao (Memo)o campo nao e limpo   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oGetTlv:oBrowse:SetFocus()
        
		oGetTlv:oBrowse:Refresh(.T.)

        oEnchTlv:ResetScroll()

		oFolderTlv:Refresh()
		
		If MaFisFound()
			For nCont := 1 to Len(aValores)
				aValores[nCont] := 0
			Next nCont
		
			Tk273Refresh()

			MaFisClear()
			MaColsToFis(aHeader,aCols,,"TK271")
		Endif
		
		Tk271HabObj(.T.,@lHabilita,@oEnchTlv)
		Tk273ValOper("UA_OPERADO") // Habilita/Desabilita os campos de acordo com o operador
		oEnchTlv:Refresh()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Reinicializa a variavél do prospect para .F. porque limpou a tela³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lProspect := .F.
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza o status da tabela de atendentes IN/OUT para o Monitor³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TkGrvSUV(__cUserId, "TLV0")

	 	//Faz o desbloqueio do atendimento no momento da limpeza, para liberá-lo para outro operador.
	 	If !Empty(cLock)
			UnLockByName(cLock,.T.,!Empty(xFilial("SUA")),.T.)
			cLock := ""
		EndIf
				
	ElseIf (cTipoAte == "3")             //Telecobranca
		cAlias:= "ACF"
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inicializo a GETDADOS   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TK271Config("ACG","ACG_CODIGO",nOpc,NIL,NIL,NIL)
		
		aHeader:= aClone(aSvFolder[3][1])
		aCols  := aClone(aSvFolder[3][2])
		n	   := aSvFolder[3][3]

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Antes de limpar os objetos, forcar o foco no browse, pq caso ³
		//³o foco esteja no campo Observacao (Memo)o campo nao e limpo  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oGetTlc:oBrowse:SetFocus()
		oGetTlc:oBrowse:Refresh(.T.)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Limpa o Rodape de Telecobranca³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Tk274LimpaRdp()
		oFolderTlc:Refresh()
		
		Tk271HabObj(.T.,@lHabilita,@oEnchTlc)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza o status da tabela de atendentes IN/OUT para o Monitor³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TkGrvSUV(__cUserId, "TLC0")
		
	Endif
	
ElseIf (nFolder == 2)
	cAlias:= "SUA"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Libera o orçamento no loja, claro, se o orçamento for do loja.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (nOldOpc == 4)
		TkLibLoja("D")
	EndIf	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Variaveis da condi‡„o de pagamento    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nLiquido 	:= 0
	nEntrada 	:= 0
	aParcelas	:= {}
	nFinanciado	:= 0
	nTxJuros	:= 0
	nVlJur		:= 0
	nNumParcelas:= 0
	
	cCob     	:=""
	cEnt     	:=""
	cCidadeC 	:=""
	cCepC    	:=""
	cUfC     	:=""
	cBairroc 	:=""
	cCidadeE 	:=""
	cCepE    	:=""
	cUfE     	:=""
	cBairroE 	:=""
	cTransp 	:= ""
	cCodPagto	:= CRIAVAR("E4_CODIGO",.F.)
	cDescPagto	:=""
	cCodTransp 	:= CRIAVAR("A4_COD",.F.)
	cCodAnt		:= ""
	cCliAnt		:= ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Variavel private para consulta TEF³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cGaranCh := ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicializo a GETDADOS   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TK271Config("SUB","UB_NUM",nOpc,NIL,NIL,NIL)
	
	aHeader:= aClone(aSvFolder[2][1])
	aCols  := aClone(aSvFolder[2][2])
	n	   := aSvFolder[2][3]
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Antes de limpar os objestos, forcar o foco no browse, pq caso ³
	//³o foco esteja no campo Observacao (Memo)o campo nao e limpo   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oGetTlv:oBrowse:SetFocus()

	oGetTlv:oBrowse:Refresh(.T.)
	
	oEnchTlv:ResetScroll()
	
	oFolderTlv:Refresh()
	
	If MaFisFound()
		For nCont := 1 to Len(aValores)
			aValores[nCont] := 0
		Next nCont
		
		Tk273Refresh()
		
		MaFisClear()
		MaColsToFis(aHeader,aCols,,"TK271")
	Endif
	
	Tk271HabObj(.T.,@lHabilita,@oEnchTlv)
	Tk273ValOper("UA_OPERADO") // Habilita/Desabilita os campos de acordo com o operador
	oEnchTlv:Refresh()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Reinicializa a variavél do prospect para .F. porque limpou a tela³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lProspect := .F.
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza o status da tabela de atendentes IN/OUT para o Monitor³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TkGrvSUV(__cUserId, "TLV0")

 	//Faz o desbloqueio do atendimento no momento da limpeza, para liberá-lo para outro operador.
 	If !Empty(cLock)
		UnLockByName(cLock,.T.,!Empty(xFilial("SUA")),.T.)
		cLock := ""
	EndIf
			
ElseIf (nFolder == 3) //Telecobranca
	cAlias:= "ACF"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicializo a GETDADOS   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TK271Config("ACG","ACG_CODIGO",nOpc,NIL,NIL,NIL)
	
	aHeader:= aClone(aSvFolder[3][1])
	aCols  := aClone(aSvFolder[3][2])
	n	   := aSvFolder[3][3]

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Antes de limpar os objetos, forcar o foco no browse, pq caso ³
	//³o foco esteja no campo Observacao (Memo)o campo nao e limpo  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oGetTlc:oBrowse:SetFocus()
	oGetTlc:oBrowse:Refresh(.T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Limpa o Rodape de Telecobranca³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Tk274LimpaRdp()
	oFolderTlc:Refresh()
	
	Tk271HabObj(.T.,@lHabilita,@oEnchTlc)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza o status da tabela de atendentes IN/OUT para o Monitor³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TkGrvSUV(__cUserId, "TLC0")
	
Endif

Do Case
	Case cAlias == "SUA"
	    
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inicializa as variaveis de memoria da enchoice³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nLenSX3 := LEN(aSx3SUA)
		For nCont := 1 TO nLenSX3
			cCampo 		:= Alltrim(aSx3SUA[nCont][1])		//X3_CAMPO
			M->&(cCampo):= CriaVar(cCampo,.T.)
		Next nCont
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Essa funcao e para evitar o problema de digitacao do codigo do cliente sem validacao do SX3 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(oEnchTlv:aEntryCtrls) > 0

			oEnchTlv:aEntryCtrls[1]:SetFocus()

			nPosLoja := aScan(oEnchTlv:aEntryCtrls,{|oObj| AllTrim(oObj:cReadVar) == 'M->UA_LOJA'})
			oEnchTlv:aEntryCtrls[nPosLoja]:lModified := .F.

		Endif

	Case cAlias == "SUC"
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inicializa as variaveis de memoria da enchoice³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nLenSX3 := LEN(aSx3SUC)
		For nCont := 1 TO nLenSX3
			cCampo 		:= Alltrim(aSx3SUC[nCont][1])		//X3_CAMPO
			M->&(cCampo):= CriaVar(cCampo,.T.)
		Next nCont
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Essa funcao e para evitar o problema de digitacao do codigo do cliente sem validacao do SX3 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(oEnchTmk:aEntryCtrls) > 0
			oEnchTmk:aEntryCtrls[1]:SetFocus()
		Endif

	Case cAlias == "ACF"
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inicializa as variaveis de memoria da enchoice³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SX3")
		DbSetOrder(1)
		DbSeek(cAlias)
		While ( !SX3->( Eof() ) .AND. SX3->X3_ARQUIVO == cAlias)
			If X3USO(SX3->X3_USADO)
				cCampo := SX3->X3_CAMPO
				M->&(cCampo) := CriaVar(cCampo,.T.)
			Endif
			
			DbSkip()                             
		End
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Essa funcao e para evitar o problema de digitacao do codigo do cliente sem validacao do SX3 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(oEnchTlc:aEntryCtrls) > 0
			oEnchTlc:aEntryCtrls[1]:SetFocus()
		Endif
EndCase

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Zero cronometro         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oTimerCro:DeActivate()

oCrono:nClrText := CLR_BLUE
cCrono:= "00:00"
oCrono:Refresh()

nTimeSeg  := 0
nTimeMin  := 0
lCreateNew:= .F.

cLigacao  := ""
oLigacao:Refresh()

cOperador := ""
oOperador:Refresh()

cOperacao := ""
oOperacao:Refresh()

cStatus   := ""
oStatus:Refresh()

cProximo  := ""
oProximo:Refresh()

cNomeHist := ""										// Nome completo da entidade selecionada no atendimento
oNomeHist:Refresh()

cContHist := ""
oContHist:Refresh()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza o sistema para exibir de novo o HELP de obrigat³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lExibeHelp := .T.

MaReleTabPrc()//Limpa array da tabela de preço

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TkConhecimento   ³Autor  ³ Vendas Clientes ³ Data ³ 20/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Chamada do botão do banco de conhecimento.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CALL CENTER						                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TkConhecimento()

Local aRotBack := aClone(aRotina)							// Backup do vetor aRotina
Local aSArea   := GetArea()									// Backup da area atual
Local cAtend   := ""										// Atendimento
Local cEntidade:= ""										// Entidade
Local cChave   := ""										// Chave de busca
Local cCodCont := ""										// Codigo do contato
Local cOperador:= ""										// Codigo do operador
Local cCliente := ""										// Codigo do cliente
Local cLoja    := ""										// Loja do cliente
Local aSavAhead:= Iif(Type("aHeader")=="A",aHeader,{})		// Backup do aheader
Local aSavAcol := Iif(Type("aCols")=="A",aCols,{})			// Backup do acols
Local nSavN    := Iif(Type("aCols")=="A",n,0)				// Backup do numero da linha atual
Local lRet     := .T.										// Retorno da funcao
Local nIndEnt  := 1											// 	Indice da Entidade
Local cTipoAte	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Altera n para getdados do banco de conhecimento.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
n:=1

aRotina := {}
Aadd(aRotina,{STR0031,"MsDocument", 0 , 4})   // "Conhecimento"

If nFolder == 1 // Telemarketing ou Televendas

	cTipoAte	:= TkGetTipoAte()
	If (cTipoAte $ "145") // Telemarketing , Ambos ou TMK x TLV
		cAtend   := M->UC_CODIGO
		cEntidade:= M->UC_ENTIDAD
		cChave   := M->UC_CHAVE
		cCodCont := M->UC_CODCONT
		cOperador:= M->UC_OPERADO
		
	ElseIf cTipoAte == "2" // Televendas
		cAtend   := M->UA_NUM
		cEntidade:= IIf(lProspect,"SUS","SA1")
		cCliente := M->UA_CLIENTE
		cLoja	 := M->UA_LOJA
		cCodCont := M->UA_CODCONT
		cOperador:= M->UA_OPERADO
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Armazena os dados da chave primaria para pesquisa   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cChave := Alltrim(cCliente)+Alltrim(cLoja)

	ElseIf cTipoAte == "3" // Telecobranca
		cEntidade:= IIf(lProspect,"SUS","SA1")
		cChave   := M->ACF_CLIENT + M->ACF_LOJA
		cAtend   := M->ACF_CODIGO
		cCodCont := M->ACF_CODCON
		cOperador:= M->ACF_OPERAD	
	Endif
	
ElseIf nFolder == 2 // Televendas
	cAtend   := M->UA_NUM
	cEntidade:= IIf(lProspect,"SUS","SA1")
	cCliente := M->UA_CLIENTE
	cLoja	 := M->UA_LOJA
	cCodCont := M->UA_CODCONT
	cOperador:= M->UA_OPERADO
    
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Armazena os dados da chave primaria para pesquisa   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cChave := cCliente+cLoja
	
ElseIf nFolder == 3 // Telecobranca
	cEntidade:= IIf(lProspect,"SUS","SA1")
	cChave   := M->ACF_CLIENT + M->ACF_LOJA
	cAtend   := M->ACF_CODIGO
	cCodCont := M->ACF_CODCON
	cOperador:= M->ACF_OPERAD
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chama a alteração dos dados da entidade.			  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cEntidade)
	DbSelectArea(cEntidade)
	If cEntidade == "BA1" .AND. GetNewPar("MV_TMKF3", .F.)
		nIndEnt := 2
	EndIf
	DbSetOrder(nIndEnt)
	If DbSeek(xFilial(cEntidade) + cChave)
		MsDocument( Alias(), RecNo(), 1)
	Else
		Help(" ",1,"SEMENTIDAD") //Selecione uma entidade valida
		lRet := .F.
	Endif
Else
	Help(" ",1,"SEMENTIDAD") //Selecione uma entidade valida
	lRet := .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura a Integridade dos Dados                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	aHeader := aSavAHead
	aCols   := aSavaCol
	n       := nSavN
Endif

aRotina := {}
aRotina := aClone(aRotBack)
RestArea(aSArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³TkOperacao³ Autor ³ Vendas Clientes       ³ Data ³ 20/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carrega a descricao da Operacao (1-Receptivo 2-Ativo)       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso  	 ³TeleMarketing / Telecobranca					              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TkOperacao(cOperacao)
Local cDesc := ""		//Tipo da operacao

If VAL(cOperacao) == RECEPTIVO
	cDesc := STR0024  //"Receptivo	
Else                  
	cDesc := STR0025 //"Ativo"
Endif

Return(cDesc)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TkValHora³ Autor ³ Vendas Clientes       ³ Data ³ 03/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consiste a Hora                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CALL CENTER                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TkValHora(cHora1,cHora2)
Local lRet := .T.		// Retorno da rotina

If cHora2 < cHora1
	Help(" ",1,"HRMENOR")
	lRet := .F.
Endif

If cHora2 == cHora1
	Help(" ",1,"HRIGUAL")
	lRet := .F.
Endif

If (Val(substr(chora1,len(chora1)-4,2)) > 60) .OR. (Val(substr(chora1,len(chora1)-1,2)) > 60) .OR.;
( Val(substr(chora1,1,2)) > 24)  
	Help(" ",1,"HORA_PEND") // HELP RE-APROVEITADO 
	lRet := .F.
Endif

If (Val(substr(chora2,len(chora2)-4,2)) > 60) .OR. (Val(substr(chora2,len(chora2)-1,2)) > 60) .OR.;
( Val(substr(chora2,1,2)) > 24)  
	Help(" ",1,"HORA_PEND")
	lRet := .F.
Endif

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Function  ³STARTTMK  ³Autor  ³ Vendas Clientes    ³ Data ³  07/17/03   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³ Funcao chamada a cada click de Menu.                       ³±±
±±³          ³ Utilizada para execucao de funcoes antes da entrada das ro-³±±
±±³          ³ tinas  													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ AP8                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function StartTmk()
Local lRet := .F. // Retorno da funcao.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Funcao de abertura do TEF para Call Center.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Left(Upper(AllTrim(FunName())),4) $ "TMKC/TMKR"
	lRet:= Tmk273AbreTef()
Endif

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ProcTmk   ºAutor  ³ Vendas Clientes    º Data ³  06/22/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Pesquisa no array aAutoCab a posicao do campo  e retorna a  º±±
±±º          ³posicao correspondente                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CALL CENTER - ENTRADA AUTOMATICA                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function ProcTmk(cCampo)

Local nPos:= 0		// Posicao do retorno da busca no array

nPos := Ascan(aAutoCab,{|x|Trim(x[1])== cCampo })

Return(nPos) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ProcTmkVldºAutor  ³ Vendas Clientes    º Data ³  29/04/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Pesquisa no array aValidGet a posicao da variavel e retorna º±±
±±º          ³a posicao correspondente                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CALL CENTER - ENTRADA AUTOMATICA                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function ProcTmkVld(cCampo)

Local nPos:= 0		// Posicao do retorno da busca no array

nPos := Ascan(aValidGet,{|x|Trim(x[1])== cCampo })

Return(nPos) 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TkSetTriggerºAutor  ³ Vendas Clientes  º Data ³  07/25/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Permite ou nao a execucao do gatilho existente no campo     º±±
±±º          ³UC_CODCONT (CONTATO)                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CALL CENTER - TELEMARKETING                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TkSetTrigger(lSet)

Static lTrigger := .T.				//Flag de controle da funcao

If Valtype(lSet) == "L"
	lTrigger := lSet
	lGet     := lSet
Else 
	lGet := lTrigger
Endif	            

//-------------------------------------------------------------------
//Força o gatilho, pois as vezes perde a referência
//-------------------------------------------------------------------
If !lGet .And. Empty( M->UC_DESCENT )
	lGet := .T.
EndIf

Return(lGet)

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ TMKQNCEnc  ³ Autor ³ Vendas Clientes       ³ Data ³ 15/12/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Encerra Assunto/Atendimento no TMK pelo QNC                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMKQNCEnc()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAQNC - (Integracao)                 					    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMKQNCEnc(nReg)

Local cAten    	:= ""  	// Codigo do Atendimento
Local nItens   	:= 0   	// Numero de itens do Atendimento
Local nEnc     	:= 0   	// Numero de itens encerrados do Atendimento
Local cMotivo  	:= ""  	// Motivo do encerramento do Atendimento
Local cEncerra 	:= ""  	// Codigo do Tipo de Encerramento
Local cObs 		:= ""   // Observacao do Iten do Atendimento      

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciono o assunto que quero encerrar e obtenho o numero do atendimento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbGoto(nReg)
cAten := SUD->UD_CODIGO
RecLock("SUD",.F.)
SUD->UD_STATUS := Str(FECHADA,1)   // Ocorrencia/Acao FECHADA
If !Empty(SUD->UD_CODEXEC)
	cObs := MSMM(SUD->UD_CODEXEC,TamSx3("UD_OBSEXEC")[1])
	cObs +=CHR(13)+CHR(10)+STR0030+SUD->UD_CODFNC+"/"+SUD->UD_FNCREV+" **" //"** ITEM ENCERRADO PELO CONTROLE DE NAO-CONFORMIDADES DEVIDO A BAIXA DA FNC : "
	MSMM( SUD->UD_CODEXEC , TamSx3("UD_OBSEXEC")[1] , NIL , cObs  ,;
	      1                , NIL                     , NIL , "SUD" ,;
	      "UD_CODEXEC"    )
Else
	cObs +=STR0030+SUD->UD_CODFNC+"/"+SUD->UD_FNCREV+" **" //"** ITEM ENCERRADO PELO CONTROLE DE NAO-CONFORMIDADES DEVIDO A BAIXA DA FNC : "     
	MSMM( NIL , TamSx3("UD_OBSEXEC")[1] , NIL , cObs  ,;
	      1   , NIL                      , NIL , "SUD" , "UD_CODEXEC")                                                                                                      
Endif                                                                                
MsUnlock()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifico o status dos outros atendimentos e caso estes  estejam encerra-³
//³ dos encerro tambem o atendimento                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSetOrder(1)
If Dbseek(xFilial("SUD")+cAten)
	While !SUD->(EOF()) .AND. SUD->(xFilial("SUD"))+cAten == SUD->UD_FILIAL+SUD->UD_CODIGO		
		nItens++
		If SUD->UD_STATUS == Str(FECHADA,1) // Encerrada
			nEnc++         
		Endif
		SUD->(DbSkip())
	End
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se o numero de Itens do atendimento sao iguais  ao numero de itens encerrados eu devo encerrar o Atencimento   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nItens == nEnc
		DbSelectArea("SUC")
		DbSetOrder(1)
		If Dbseek(xFilial("SUC")+cAten)             
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Executa a tela de Encerramento         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Tk272Encerra(.F.,SUC->UC_CODIGO,@cEncerra,@cMotivo,"1")

			If !Empty(cMotivo)  
				cMotivo+=CHR(13)+CHR(10)+STR0029  // "** ATENDIMENTO ENCERRADO PELO CONTROLE DE NAO-CONFORMIDADES **"
			Else
				cMotivo:=STR0029 // "** ATENDIMENTO ENCERRADO PELO CONTROLE DE NAO-CONFORMIDADES **"
			EndIF

			RecLock("SUC",.F.)
			SUC->UC_STATUS := Str(ENCERRADA,1)
			SUC->UC_DTENCER := dDataBase
			SUC->UC_CODENCE := cEncerra
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ MEMO DO MOTIVO DE ENCERRAMENTO ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(cMotivo)  
				MSMM(,TamSx3("UC_OBSMOT")[1],,cMotivo,1,,,"SUC","UC_CODMOT")
			Endif			
			MsUnlock()
		Endif	
	Endif
Endif
Return Nil                                                                                       

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Function  ³TmkBlqCont³Autor  ³ Vendas Clients     ³ Data ³  16/04/07   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Funcao utilizada para validar se o contato nao esta bloquea-³±±
±±³          ³do devido a sua entidade esta bloqueada.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGATMK                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TmkBlqCont(cEntidade,cChave,cOrdem)

Local aArea		:= GetArea()							//Area atual
Local aAreaEnt	:= (cEntidade)->(GetArea())			//Area da entidade
Local cCampo	:= PrefixoCpo(cEntidade)+"_MSBLQL"		//Nome do campo de bloqueio
Local cBloqueio	:= "1"									//Valor que indica o bloqueio
Local lRet		:= .F.									//Retorno da funcao

Default cChave	:= ""
Default cOrdem 	:= 1

If (cEntidade)->(FieldPos(cCampo)) > 0

	DbSelectArea(cEntidade)
	DbSetOrder(cOrdem)

	If DbSeek(cChave) 
		lRet := !((cEntidade)->&(cCampo) <> cBloqueio)
	EndIf
	
EndIf

RestArea(aAreaEnt)
RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TmkVerModoºAutor  ³Vendas CRM          º Data ³  14/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se as tabelas de configuracao do atendimento estao º±±
±±º          ³todas com o mesmo modo de acesso (compart. ou exclusivo)    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGATMK                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TmkVerModo()

Local aArea		:= GetArea()
Local aTabsModo	:= {"SU7","SU0"}
Local nX		:= 0 
Local cModo		:= ""
Local lRet		:= .T.
Local cMsg		:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Adiciona as tabelas recentes que pode nao existir³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If AliasInDic("AGI")
	AAdd(aTabsModo,"AGI")
EndIf

If AliasInDic("AGJ")
	AAdd(aTabsModo,"AGJ")
EndIf

If AliasInDic("AG9")
	AAdd(aTabsModo,"AG9")
EndIf

If AliasInDic("SKK")
	AAdd(aTabsModo,"SKK")
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se as tabelas estao todas como compartilhadas ou exclusivas³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to Len(aTabsModo)
	If Empty(cModo)
		cModo := SX2MODO(aTabsModo[nX])
	ElseIf cModo <> SX2MODO(aTabsModo[nX])
		lRet := .F.			
	EndIf
Next nX

If !lRet

	cMsg := STR0033	//"A configuração das tabelas: "
	
	SX2->(DbSetOrder(1))
	
	For nX := 1 to Len(aTabsModo)
	
		SX2->(DbSeek(aTabsModo[nX]))
	
		cMsg += aTabsModo[nX] + "(" + Capital(AllTrim(X2Nome())) + ")"
	
		If nX < Len(aTabsModo)
			If nX == Len(aTabsModo) - 1
				cMsg +=STR0035 // " e "
			Else
				cMsg +=", "
			EndIf
		EndIf
	
	Next nX
	
	cMsg += STR0034 + CRLF + CRLF //" está incorreta."
	cMsg += STR0036 + CRLF + CRLF //"Todas estas tabelas devem estar configuradas com o mesmo modo de operação: Compartilhado ou Exclusivo."
	cMsg += STR0037 //"Notifique o administrador do sistema para que esta configuração seja realizada."

	Aviso(STR0039,cMsg,{"Ok"},3,STR0038) //"Atenção"###"Configuração incorreta"

EndIf

RestArea(aArea)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} TKCalcPer
Calcula o período de duracao passando data e hora de início e data e hora de término.

@sample 	TKCalcPer(dDtIni,cHrIni,dDtFim,cHrFim) 

@param		dDtIni 	Data de Início do Período 
			cHrIni	Hora de Início do Período
			dDtFim	Data de Término do Período
			cHrFim  Hora de Término do Período
	
@return	texto da duração

@author	Aline Kokumai
@since		02/05/2013       
@version	P11.80   
/*/
//------------------------------------------------------------------------------
Function TKCalcPer(dDtIni,cHrIni,dDtFim,cHrFim)

Local cHoras     := ""		//tempo de duracao em horas e minutos 
Local nDias      := 0			//tempo de duracao em dias
Local nMeses     := 0			//tempo de duracao em meses
Local nAnos      := 0			//tempo de duracao em anos
Local cDuracao   := ""		//Retorno do texto da duracao
Local oDatetime1 := Nil		//Objeto Datetime Inicial
Local oDatetime2 := Nil		//Objeto Datetime Final

If Empty(dDtFim)
	dDtFim := DDATABASE
	cHrFim := SubStr(Time(),1,5)
ElseIf !Empty(dDtFim) .AND. Empty(cHrFim)
	cHrFim := "23:59"
EndIf
	
If !(Empty(dDtIni) .and. Empty(cHrIni)) .and. dDtFim >= dDtIni
	//Instancia os objetos data início e data fim
	oDatetime1	:= TMKDateTime():New() 
	oDatetime1 := TMKDateTime():This(dDtIni,cHrIni+':00')
	oDatetime2	:= TMKDateTime():New() 
	oDatetime2 := TMKDateTime():This(dDtFim,cHrFim+':00')

	//Calcula o numero de dias 
	nDias	:= oDatetime1:diffInDays(oDatetime2,.T.)
	
	//Calula as horas e minutos
	If (nDias < 1)
		nHoras := oDatetime1:diffInHours(oDatetime2,.T.,.T.,.T.)
		If(nHoras > 0)
			cHoras := IntToHora( Abs(nHoras) )
		Else 
			nHoras :=oDatetime1:diffInMinutes(oDatetime2,.T.,.T.)
			cHoras := IntToHora( Abs(nHoras*60) )
		EndIf
	Else	
	 	nHoras := (nDias-Int(nDias))*24
		cHoras := IntToHora( Abs(nHoras) )
		nDias	:= Int(nDias)
	EndIf
		
		//Diminui um mês caso não seja o ultimo dia		
		If IIF (ValType(oDatetime2:getDay()) == 'C', Val(oDatetime2:getDay()),oDatetime2:getDay()) <> oDatetime2:getMDays(oDatetime2:getMonth())
			oDatetime2:setMonth(oDatetime2:getMonth(oDatetime2:minusMonths(1)))
		EndIf
		
		//Calcula o numero de meses 
		While (nDias >= oDatetime2:getMDays(oDatetime2:getMonth()))
			nMeses +=1						
			nDias -= oDatetime2:getMDays(oDatetime2:getMonth()) 
			oDatetime2:minusMonths(1)			 
		EndDo
		
		//Calcula o numero de anos 
		While (nMeses >= 12)
			nAnos +=1						
			nMeses -= 12			
		EndDo
		
		//Formata o texto de retorno
		If nAnos > 1
			cDuracao += cValtoChar(nAnos) + " " + STR0040 + " " //" anos "
		ElseIf nAnos == 1
			cDuracao += cValtoChar(nAnos) + " " + STR0041 + " " //" ano "
		EndIf
		If nMeses > 1
			cDuracao += cValtoChar(nMeses) + " " + STR0042 + " " //" meses "
		ElseIf nMeses == 1
			cDuracao += cValtoChar(nMeses) + " " + STR0043 + " " //" mes "
		EndIf
		If nDias > 1
			cDuracao += cValtoChar(nDias) + " " + STR0044 + " " //" dias "
		ElseIf nDias == 1
			cDuracao += cValtoChar(nDias) + " " + STR0045 + " " //" dia "
		EndIf
		If SubStr(cHoras,1,2) <> "00" .and. SubStr(cHoras,1,2) <> "01"
			cDuracao += SubStr(cHoras,1,2) + " " + STR0046 + " " //" horas "
		ElseIf SubStr(cHoras,1,2) <> "00" .and. SubStr(cHoras,1,2) == "01"
			cDuracao += SubStr(cHoras,1,2) + " " + STR0047 + " " //" hora "
		EndIf
		If SubStr(cHoras,4,5) <> "00" .and. SubStr(cHoras,4,5) <> "01"
			cDuracao += SubStr(cHoras,4,5) + " " + STR0048 + " " //" minutos "
		ElseIf SubStr(cHoras,4,5) <> "00" .and. SubStr(cHoras,4,5) == "01"
			cDuracao += SubStr(cHoras,4,5) + " " + STR0049 + " " //" minuto "
		EndIf
EndIf

Return( cDuracao )   


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TkxFunOrigºAutor  ³Vendas CRM          º Data ³  21/05/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Consulta especifica F3ORIG								  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGATMK                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TkxFunOrig() 

Local cSXB 		:= ""		// Consulta Padrão
Local cCampo	:= ""		// Campo de retorno da consulta
Local lRetorno	:= .F.		// Retorno da funcao
Static cValor	:= ""       // Valor que vai ser atribuido ao campo

// 1=Mailing;2=Campanha;3=Web;4=Indicacao;5=Evento;6=Anuncio;7=Parceiro;8=Relacoes publicas;9=Seminario;A=Boca-a-boca;B=Outros
// Verifica qual foi a escolha do usuario para ver qual consunta padrão usar.
If Type("M->ACH_ORIGEM") == "C" .AND. Type("M->ACH_ENTORI") == "C"  .And.;
	ACH->(FieldPos("ACH_ORIGEM")) > 0 .And. ACH->(FieldPos("ACH_ENTORI")) > 0
	
	If M->ACH_ORIGEM == "1"
		cSXB := "SA2MAI"
		cCampo := "SA2->A2_COD"
	ElseIf M->ACH_ORIGEM == "2"
		cSXB := "SUO"
		cCampo := "SUO->UO_CODCAMP"
	ElseIf M->ACH_ORIGEM == "5"
		cSXB := "ACD"
		cCampo := "ACD->ACD_CODIGO"
	ElseIf M->ACH_ORIGEM == "7"
		cSXB := "AC4"
		cCampo := "AC4->AC4_PARTNE"
	EndIf
	
ElseIf Type("M->US_ENTORI") == "C" .And. SUS->(FieldPos("US_ORIGEM")) > 0 .And. SUS->(FieldPos("US_ENTORI")) > 0

	If M->US_ORIGEM == "1"
		cSXB := "SA2MAI"
		cCampo := "SA2->A2_COD"
	ElseIf M->US_ORIGEM == "2"
		cSXB := "SUO"
		cCampo := "SUO->UO_CODCAMP"
	ElseIf M->US_ORIGEM == "5"
		cSXB := "ACD"
		cCampo := "ACD->ACD_CODIGO"
	ElseIf M->US_ORIGEM == "7"
		cSXB := "AC4"
		cCampo := "AC4->AC4_PARTNE"
	EndIf

ElseIf Type("M->A1_ENTORI") == "C" .And. SA1->(FieldPos("A1_ORIGEM")) > 0 .And. SA1->(FieldPos("A1_ENTORI")) > 0
	
	If M->A1_ORIGCT == "1"
		cSXB := "SA2MAI"
		cCampo := "SA2->A2_COD"
	ElseIf M->A1_ORIGCT == "2"
		cSXB := "SUO"
		cCampo := "SUO->UO_CODCAMP"
	ElseIf M->A1_ORIGCT == "5"
		cSXB := "ACD"
		cCampo := "ACD->ACD_CODIGO"
	ElseIf M->A1_ORIGCT == "7"
		cSXB := "AC4"
		cCampo := "AC4->AC4_PARTNE"
	EndIf
	
EndIf

lRetorno := ConPad1(,,,cSXB)

//Retorno da consulta padrão.
If lRetorno
	cValor		:= &(cCampo)
Else
	cValor		:= " "
EndIf

Return( lRetorno )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TkxRetOrigºAutor  ³Vendas CRM          º Data ³  21/05/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorno da consulta especifica F3ORIG						  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGATMK                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TkxRetOrig()  
Return (cValor)

//------------------------------------------------------------------------------
/*/{Protheus.doc} TmkLoad

Funções a serem executadas na entrada do modulo CallCenter

@sample 	TmkLoad() 

@param		Nenhum
	
@return	Nenhum

@author	Aline Kokumai
@since		24/06/2013       
@version	P11.80   
/*/
//---------------------------------------------------------------------
Function TmkLoad() 
TkxLayMile()  
Return
//------------------------------------------------------------------------------
/*/ {Protheus.doc} TkxLayMile

Cria os layouts do Mile para as entidades ACH, SUS, SA1 e AIK.

@sample 	TkxLayMile()

@param		Nenhum
	
@return	Nenhum

@author	Aline Kokumai
@since		24/06/2013       
@version	P11.80   
/*/
//---------------------------------------------------------------------
Function TkxLayMile()

Local oFwMile 	:= FwMile():New()
Local lImpLayMl := SuperGetMv("MV_MLLYENT",,.T.)

//Apaga layout NeoWay descontinuado;
If !lImpLayMl
	NwLayClear()
EndIf

If ( FindFunction("FWMILEIMPORT") .AND. lImpLayMl .AND. FindFunction("Tk341Mile") .AND.;
	FindFunction("Tk260Mile") .AND. FindFunction("Ma030Mile") .AND. FindFunction("Tk700Mile") )

	If !(TkxExtMile("ACHLAY01"))
		Tk341Mile("ACHLAY01")
	EndIf
	If !(TkxExtMile("SUSLAY01"))
		Tk260Mile("SUSLAY01")
	EndIf
	If !(TkxExtMile("SA1LAY01"))
		Ma030Mile("SA1LAY01")
	EndIf
	If !(TkxExtMile("TK700IMP"))
		Tk700Mile()
	EndIf

	PutMv("MV_MLLYENT",.F.)
EndIf
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} TkxExtMile

Verifica se já existe o layout do Mile

@sample 	TkxExtMile(cLayout) 

@param		cLayout - Código do layout do Mile
	
@return	Verdadeiro ou Falso

@author	Aline Kokumai
@since		24/06/2013       
@version	P11.80   
/*/
//---------------------------------------------------------------------
Function TkxExtMile(cLayout)

Local lExistLay	:= .F. //Existe layout

DbSelectArea("XXJ") 
DbSetOrder(1)

lExistLay := XXJ->(DbSeek(cLayout)) 

Return( lExistLay )

//------------------------------------------------------------------------------
/*/{Protheus.doc} TkxRetOri

Cria parametro para identificar se os layouts do mile foram importados

@sample 	TkxRetOri() 
	
@return	cTipo - Opção escolhida

@author	Vendas CRM
@since		14/08/2013       
@version	P11.80   
/*/
//---------------------------------------------------------------------

Function TkxRetOri()

Local cTipo := "1=Mailing;2=Campanha;3=Web;4=Indicacao;5=Evento;6=Anuncio;7=Parceiro;8=Relacoes Publicas;9=Seminario;A=Boca-a-boca;B=Outros;C=uMov.me"

Return cTipo
 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FilCON    ºAutor  ³Vendas CRM          º Data ³  22/07/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Filtro da consulta padrao CON - Cliente x Contato X Prospectº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGATMK                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FilCON()
Local lRet := .T.

lRet := AC8->AC8_FILIAL == xFilial("AC8") .And.;
         AC8->AC8_ENTIDA == IIF(!Empty(M->AD1_CODCLI),"SA1","SUS") .And.;
          Rtrim(AC8->AC8_CODENT) == IIF(!Empty(M->AD1_CODCLI),M->AD1_CODCLI+M->AD1_LOJCLI,M->AD1_PROSPE+M->AD1_LOJPRO)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} TKExistEnt
Verifica se o código em memória equivale ao array de contatos.
Utilizada para garantir a limpeza dos campos no gatilho

@sample 	TKExistEnt() 

@return	nPos1, Numerico, Posição da entidade no Array de contatos

@author		Serviços
@since		29/04/2015       
@version	12.1.7   
/*/         
//------------------------------------------------------------------------------
Function TKExistEnt(aCont, cChvMemori, cChave, cEntMemori)
Local nPos1 	:= 0
		
Default cChvMemori	:= ""
Default cChave	:= ""

If !Empty(cChvMemori) .And. !Empty(cChave)
	nPos1 := AScan(aCont,{|x| x[3] == cChvMemori .AND. x[1] == cEntMemori} )
	If nPos1 == 0
		nPos1 := AScan(aCont,{|x| x[3] == cChave} )
	EndIf
EndIf
Return(nPos1)

//------------------------------------------------------------------------------
/*/{Protheus.doc} NwLayClear
Verifica se os layouts Mile NeoWay (SUS00001, PROS0001, CLI00001) existem na base.
Caso positivo executa a limpeza, apagando os layouts descontinuados.

@sample 	NwLayClear() 

@return		Nil

@author		SQUAD CRM/Faturamento
@since		18/09/2017       
@version	12.1.17+   
/*/         
//------------------------------------------------------------------------------
Function NwLayClear() 
If TkxExtMile("SUS00001")
	MileXXJClr("SUS00001")
EndIf

If TkxExtMile("PROS0001")
	MileXXJClr("PROS0001")
EndIf

If TkxExtMile("CLI00001")
	MileXXJClr("CLI00001")
EndIf
Return Nil
 
//------------------------------------------------------------------------------
/*/{Protheus.doc} MileXXJClr
Apaga o layout desejado.

@sample 	MileXXJClr(cLayoutNeo) 
@Param		cLayoutNeo, Char, Nome do Layout que será deletado
@return		Nil

@author		SQUAD CRM/Faturamento
@since		18/09/2017    
@version	12.1.17+   
/*/         
//------------------------------------------------------------------------------
Function MileXXJClr(cLayoutNeo)
Local   aAreaXXJ	:= XXJ->( GetArea() )
Default cLayoutNeo 	:= ""

DbSelectArea("XXJ")
XXJ->( DbSetOrder(1) )
If !Empty( cLayoutNeo ) .And. XXJ->( DbSeek(cLayoutNeo) )
	RecLock("XXJ",.F.)
	XXJ->( DbDelete() )
	XXJ->( MsUnlock() )
EndIf
RestArea( aAreaXXJ )
Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} TkChkOMS
Verifica se o pedido de vendas possui carga montada no OMS ou se possui uma viagem no Cockpit Logístico vinculada ao Pedido de Vendas
@sample 	TkChkOMS(cNumPV, cItemPV, lRetLogical)
@Param		cNumPV, Char, Número do Pedido de Vendas
@Param		cItemPV, Char, Item do Pedido de Vendas
@return	NIL = Quando a função chamadora não exige um retorno lógico
        	.T. = Pedido de Vendas não possui viagem vinculada
        	.F. = Pedido de Vendas possui viagem vinculada
@author	SQUAD CRM/Faturamento
@since		Agosto/2018
@version	12.1.17
/*/
//------------------------------------------------------------------------------
Function TkChkOMS(cNumPV, cItemPV, lRetLogical)
//Dummy Function mantida devido a compatibilidade de dicionários
//Deve ser removida do fonte quando a versão 12.1.27 estiver obsoleta.
Return .T.

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLoad
    @description
    Inicializa variaveis com lista de campos que devem ser ofuscados de acordo com usuario.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cUser, Caractere, Nome do usuário utilizado para validar se possui acesso ao 
        dados protegido.
    @param aAlias, Array, Array com todos os Alias que serão verificados.
    @param aFields, Array, Array com todos os Campos que serão verificados, utilizado 
        apenas se parametro aAlias estiver vazio.
    @param cSource, Caractere, Nome do recurso para gerenciar os dados protegidos.
    
    @return cSource, Caractere, Retorna nome do recurso que foi adicionado na pilha.
    @example FATPDLoad("ADMIN", {"SA1","SU5"}, {"A1_CGC"})
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDLoad(cUser, aAlias, aFields, cSource)
	Local cPDSource := ""

	If FATPDActive()
		cPDSource := FTPDLoad(cUser, aAlias, aFields, cSource)
	EndIf

Return cPDSource


//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDUnload
    @description
    Finaliza o gerenciamento dos campos com proteção de dados.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cSource, Caractere, Remove da pilha apenas o recurso que foi carregado.
    @return return, Nulo
    @example FATPDUnload("XXXA010") 
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDUnload(cSource)    

    If FATPDActive()
		FTPDUnload(cSource)    
    EndIf

Return Nil

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDColObfuscate
    @description
    Verifica se a coluna de um grid deve ser ofuscado, tendo como base uma lista de
    campos, esta função deve utilizada somente após a inicialização das variaveis 
    atravez da função FATPDLoad.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cField, Caractere, Campo que sera validado
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.

    @return lObfuscate, Lógico, Retorna se o campo será ofuscado.
    @example FATPDIsObfuscate({"A1_COD","A1_NOME","A1_CGC"})
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDColObfuscate(aFields, cSource)  
    
	Local aPDColObf	:= {}

    If FATPDActive()
		aPDColObf := FTPDColObfuscate(aFields, cSource)  
    EndIf 

Return aPDColObf  

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDObfuscate
    @description
    Realiza ofuscamento de uma variavel ou de um campo protegido.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @sample FATPDObfuscate("999999999","U5_CEL")
    @author Squad CRM & Faturamento
    @since 04/12/2019
    @version P12
    @param xValue, (caracter,numerico,data), Valor que sera ofuscado.
    @param cField, caracter , Campo que sera verificado.
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado

    @return xValue, retorna o valor ofuscado.
/*/
//-----------------------------------------------------------------------------
Static Function FATPDObfuscate(xValue, cField, cSource, lLoad)
    
    If FATPDActive()
		xValue := FTPDObfuscate(xValue, cField, cSource, lLoad)
    EndIf

Return xValue   

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLogUser
    @description
    Realiza o log dos dados acessados, de acordo com as informações enviadas, 
    quando a regra de auditoria de rotinas com campos sensíveis ou pessoais estiver habilitada
	Remover essa função quando não houver releases menor que 12.1.27

   @type  Function
    @sample FATPDLogUser(cFunction, nOpc)
    @author Squad CRM & Faturamento
    @since 06/01/2020
    @version P12
    @param cFunction, Caracter, Rotina que será utilizada no log das tabelas
    @param nOpc, Numerico, Opção atribuída a função em execução - Default=0

    @return lRet, Logico, Retorna se o log dos dados foi executado. 
    Caso o log esteja desligado ou a melhoria não esteja aplicada, também retorna falso.

/*/
//-----------------------------------------------------------------------------
Static Function FATPDLogUser(cFunction, nOpc)

	Local lRet := .F.

	If FATPDActive()
		lRet := FTPDLogUser(cFunction, nOpc)
	EndIf 

Return lRet  

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Função que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive  

//-----------------------------------------------------------------------------
/*/{Protheus.doc}TkVldUser
    @description
    Verifica se usuario esta ativo ou bloqueado no modulo configurador.

    @type  	Function
    @sample TkVldUser( cCodUser )
    @author Squad CRM & Faturamento
    @since 	27/01/2020
    @version P12    
    @return	lRet, Logico, Indica se usuario esta habilitado ou bloqueado.
/*/
//-----------------------------------------------------------------------------
Function TkVldUser( cCodUser )
	Local lRet      := .F.    
    Local aArray    := {}

    Default cCodUser  := RetCodUsr()

    PswOrder(1)
    If PswSeek( cCodUser , .T. )
        // Retorna Array com informações do usuário
        aArray := PswRet() 
        If !aArray[1,17]
            lRet := .T.
        Else
           Help(" ",1,"REGBLOQ")
        Endif
	Else
		Help(" ",1,"REGNOIS")
    EndIf

    aSize(aArray, 0)

Return lRet