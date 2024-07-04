#Include "Protheus.Ch"
#Include "Diefpa.Ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DIEFPA    ³ Autor ³Mary C. Hergert        ³ Data ³09/08/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Geracao do meio magnetico DIEFPA                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN -> nFuncao - Funcao a ser chamada pela principal.      ³±±
±±³          ³ExpC -> String - String qualquer utilizada pelas funcoes.   ³±±
±±³          ³ExpN -> nPosFimCfp - Posicao final do arquivo CFP utilizado ³±±
±±³          ³ pela funcao sfRetCfop().                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function DIEFPA (nFuncao,nRegistro)
	Local xRet    := .T.
	Local cCfpDia := ""
	//
	Default nFuncao   := 1
	Default nRegistro := 1
	//
	cCfpOld := "DIEFPA"+Alltrim(Str(nRegistro))+".CFP"
	cCfpDia := "DIEFPA"+Alltrim(Str(nRegistro))+cEmpAnt+cFilAnt+".CFP"
	//
	If (nFuncao==1)
		xRet := DIEFPACfp(cCfpDia,nRegistro,cCfpOld)
	ElseIf (nFuncao==2)
		xRet := LeCfp (AllTrim(cCfpDia))
	EndIf
	//
Return (xRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DIEFPACfp ³ Autor ³Mary C. Hergert        ³ Data ³01.03.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta arquivo CFP com parametros a serem utilizados no      ³±±
±±³          ³DIEFPA.INI                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DIEFPACfp (cCfpDia,nReg,cCfpOld)
	Local 	cValid 		:= ""
	Local 	nI	 		:= 1
	Local 	nOpcA	 	:= 2
	Local 	oDlgGet
	Local	cBarra		:=	""
	Local	cTitJan		:=	""

	Private	aSel		:= {}
	Private aListBox	:= {}
	Private	aMsg	  	:= {}
	Private	aValid	  	:= {}
	Private	aConteudo 	:= {}

    Do Case
    Case nReg == 1
	   // INFORMACOES SOBRE A EMPRESA
	   // "0001 - Tipo do Logradouro"
       aAdd(aListBox,OemToAnsi(STR0001));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0001));aAdd(aValid,"VldCfpPA('C','STR')")
       // "0002 - Logradouro"
       aAdd(aListBox,OemToAnsi(STR0002));aAdd(aSel,.T.);AAdd(aMsg,OemToAnsi(STR0002));aAdd(aValid,"VldCfpPA('C','STR')")
       // "0003 - Numero referente ao Logradouro"
       aAdd(aListBox,OemToAnsi(STR0003));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0003));aAdd(aValid,"VldCfpPA('N','NUM')")
       // "0004 - Complemento"
       aAdd(aListBox,OemToAnsi(STR0004));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0004));aAdd(aValid,"VldCfpPA('C','STR')")
       // "0005 - Bairro"
       aAdd(aListBox,OemToAnsi(STR0005));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0005));aAdd(aValid,"VldCfpPA('C','STR')")
       // "0006 - Codigo do Municipio"
       aAdd(aListBox,OemToAnsi(STR0006));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0006));aAdd(aValid,"VldCfpPA('N','NUM')")
       // "0007 - DDD do Telefone para contato"
       aAdd(aListBox,OemToAnsi(STR0007));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0007));aAdd(aValid,"VldCfpPA('N','STR')")
       // "0008 - Telefone para contato"
       aAdd(aListBox,OemToAnsi(STR0008));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0008));aAdd(aValid,"VldCfpPA('C','FON')")
       // "0009 - E-mail do Contribuinte"
       aAdd(aListBox,OemToAnsi(STR0009));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0009));aAdd(aValid,"VldCfpPA('C','STR')")
       // "0010 - Ano de inicio das atividades da empresa"
       aAdd(aListBox,OemToAnsi(STR0081));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0081));aAdd(aValid,"VldCfpPA('N','NUM')")
       // "0011 - A empresa mudou de endereço no período?"
       aAdd(aListBox,OemToAnsi(STR0082));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0082));aAdd(aValid,"VldCfpPA('C','STR')")
       // "0012 - Modalidade de atividade exercida pela empresa"
       aAdd(aListBox,OemToAnsi(STR0083));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0083));aAdd(aValid,"VldCfpPA('C','STR')")

    Case nReg == 2
       // INFORMACOES SOBRE O CONTABILISTA
       // "0001 - CPF do Contabilista ou CNPJ do Escritorio"
       aAdd(aListBox,OemToAnsi(STR0010));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0010));aAdd(aValid,"VldCfpPA('N','NUM')")
       // "0002 - CRC do Contabilista"
       aAdd(aListBox,OemToAnsi(STR0011));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0011));aAdd(aValid,"VldCfpPA('C','STR')")
       // "0003 - UF do CRC do Contabilista"
       aAdd(aListBox,OemToAnsi(STR0012));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0012));aAdd(aValid,"VldCfpPA('C','STR')")
       // "0004 - Nome do Contabilista" 
       aAdd(aListBox,OemToAnsi(STR0013));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0013));aAdd(aValid,"VldCfpPA('C','STR')")
       // "0005 - DDD Telefone do Contabilista"
       aAdd(aListBox,OemToAnsi(STR0014));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0014));aAdd(aValid,"VldCfpPA('C','STR')")
       // "0006 - Telefone do Contabilista"
       aAdd(aListBox,OemToAnsi(STR0015));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0015));aAdd(aValid,"VldCfpPA('C','FON')")
       // "0007 - E-mail do Contabilista"
       aAdd(aListBox,OemToAnsi(STR0016));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0016));aAdd(aValid,"VldCfpPA('C','STR')")

       // Novos parametros - DIEF2007
       // "0008 - Troca de Munícipio"
       aAdd(aListBox,OemToAnsi(STR0152));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0152));aAdd(aValid,"VldCfpPA('C','STR')")
    Case nReg == 3
       // INFORMACOES SOBRE A DECLARACAO
       // 001 - "0001 - Periodicidade"
       aAdd(aListBox,OemToAnsi(STR0017));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0017));aAdd(aValid,"VldCfpPA('C','STR')")
       // 002 - "0002 - Tipo de Declaração"
       aAdd(aListBox,OemToAnsi(STR0018));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0018));aAdd(aValid,"VldCfpPA('C','STR')")
       // 003 - "0003 - Movimentacao"
       aAdd(aListBox,OemToAnsi(STR0019));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0019));aAdd(aValid,"VldCfpPA('C','STR')")
       // 004 - "0004 - Tipo de Tributacao do Imposto de Renda"
       aAdd(aListBox,OemToAnsi(STR0020));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0020));aAdd(aValid,"VldCfpPA('C','STR')")
       // 005 - "0005 - Forma de Tributacao do Imposto de Renda"
       aAdd(aListBox,OemToAnsi(STR0021));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0021));aAdd(aValid,"VldCfpPA('C','STR')")
       // 006 - "0006 - Valor de Outras Receitas do Mes"
       aAdd(aListBox,OemToAnsi(STR0054));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0054));aAdd(aValid,"VldCfpPA('N','NUM')")

       // Novos parametros - DIEF2006
       // 007 - "0007 - Tipo Contribuinte"
       aAdd(aListBox,OemToAnsi(STR0134));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0134));aAdd(aValid,"VldCfpPA('C','STR')")
       // 010 - "0010 - Anexo III - Declaração Sem Receitas"
       aAdd(aListBox,OemToAnsi(STR0137));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0137));aAdd(aValid,"VldCfpPA('C','STR')")
       // 011 - "0011 - Anexo I (Anual) - Declaração Sem Serviços"
       aAdd(aListBox,OemToAnsi(STR0138));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0138));aAdd(aValid,"VldCfpPA('C','STR')")

       // Novos parametros - DIEF2008
       // 012 - "0012 - ICMS Diferenciado"
       aAdd(aListBox,OemToAnsi(STR0158));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0158));aAdd(aValid,"VldCfpPA('N','NUM')")
       // 013 - "0013 - ICMS Diferenciado ST Interna"
       aAdd(aListBox,OemToAnsi(STR0159));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0159));aAdd(aValid,"VldCfpPA('N','NUM')")

       // Novos parametros - DIEF2011
       // 014 - "0014 - Anexo I (Mensal) - Declaração Sem Serviços"
       aAdd(aListBox,OemToAnsi(STR0160));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0160));aAdd(aValid,"VldCfpPA('C','STR')")

       // Novos parametros - DIEF2015
       // 015 - "0015 - Anexo II - Combustíveis"
       aAdd(aListBox,OemToAnsi(STR0161));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0161));aAdd(aValid,"VldCfpPA('C','STR')")

	Case nReg == 4
       // DADOS DE DESPESAS DO ANO ANTERIOR
       // "0001 - Pró-Labore e Retiradas"
       aAdd(aListBox,OemToAnsi(STR0055));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0055));aAdd(aValid,"VldCfpPA('N','NUM')")
       // "0002 - Salários e Remunerações"
       aAdd(aListBox,OemToAnsi(STR0056));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0056));aAdd(aValid,"VldCfpPA('N','NUM')")
       // "0003 - Encargos Sociais
       aAdd(aListBox,OemToAnsi(STR0057));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0057));aAdd(aValid,"VldCfpPA('N','NUM')")
       // "0004 - ICMS
       aAdd(aListBox,OemToAnsi(STR0058));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0058));aAdd(aValid,"VldCfpPA('N','NUM')")
       // "0005 - Outros Impostos e Taxas"
       aAdd(aListBox,OemToAnsi(STR0059));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0059));aAdd(aValid,"VldCfpPA('N','NUM')")
       // "0006 - Fretes"
       aAdd(aListBox,OemToAnsi(STR0060));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0060));aAdd(aValid,"VldCfpPA('N','NUM')")
       // "0007 - Energia Elétrica"
       aAdd(aListBox,OemToAnsi(STR0061));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0061));aAdd(aValid,"VldCfpPA('N','NUM')")
       // "0008 - Aluguéis e Condomínios"
       aAdd(aListBox,OemToAnsi(STR0062));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0062));aAdd(aValid,"VldCfpPA('N','NUM')")
       // "0009 - Despesas Financeiras"
       aAdd(aListBox,OemToAnsi(STR0063));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0063));aAdd(aValid,"VldCfpPA('N','NUM')")
       // "0010 - Outras Despesas"
       aAdd(aListBox,OemToAnsi(STR0064));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0064));aAdd(aValid,"VldCfpPA('N','NUM')")
	Case nReg == 5
       // INFORMACOES GERAIS DO ESTOQUE
       // "0001 - Valor do Estoque inicial para venda do ano anterior"
       aAdd(aListBox,OemToAnsi(STR0065));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0065));aAdd(aValid,"VldCfpPA('N','NUM')")
       // "0002 - Valor do Estoque inicial para uso e consumo do ano anterior"
       aAdd(aListBox,OemToAnsi(STR0066));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0066));aAdd(aValid,"VldCfpPA('N','NUM')")
       // "0003 - Valor do Estoque final para venda do ano anterior"
       aAdd(aListBox,OemToAnsi(STR0067));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0067));aAdd(aValid,"VldCfpPA('N','NUM')")
       // "0004 - Valor do Estoque final para uso e consumo do ano anterior"
       aAdd(aListBox,OemToAnsi(STR0068));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0068));aAdd(aValid,"VldCfpPA('N','NUM')")
       // "0005 - Valor do Estoque inicial para venda do ano atual"
       aAdd(aListBox,OemToAnsi(STR0069));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0069));aAdd(aValid,"VldCfpPA('N','NUM')")
       // "0006 - Valor do Estoque inicial para uso e consumo do ano atual"
       aAdd(aListBox,OemToAnsi(STR0070));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0070));aAdd(aValid,"VldCfpPA('N','NUM')")
       // "0007 - Valor do Estoque final para venda do ano atual"
       aAdd(aListBox,OemToAnsi(STR0071));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0071));aAdd(aValid,"VldCfpPA('N','NUM')")
       // "0008 - Valor do Estoque final para uso e consumo do ano atual"
       aAdd(aListBox,OemToAnsi(STR0072));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0072));aAdd(aValid,"VldCfpPA('N','NUM')")
       // "0009 - Valor do Estoque inicial de terceiros do ano anterior"
       aAdd(aListBox,OemToAnsi(STR0130));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0130));aAdd(aValid,"VldCfpPA('N','NUM')")
       // "0010 - Valor do Estoque final de terceiros do ano anterior"
       aAdd(aListBox,OemToAnsi(STR0131));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0131));aAdd(aValid,"VldCfpPA('N','NUM')")
       // "0011 - Valor do Estoque inicial de terceiros do ano atual"
       aAdd(aListBox,OemToAnsi(STR0132));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0132));aAdd(aValid,"VldCfpPA('N','NUM')")
       // "0012 - Valor do Estoque final de terceiros do ano atual"
       aAdd(aListBox,OemToAnsi(STR0133));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0133));aAdd(aValid,"VldCfpPA('N','NUM')")
	Case nReg == 6
       // DADOS DA APURAÇÃO DO ICMS
       // "0001 - Estornos de Crédito: Transferência de Crédito Cheque Moradia"
       aAdd(aListBox,OemToAnsi(STR0073));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0073));aAdd(aValid,"VldCfpPA('N','NUM')")
       // "0003 - Outros Créditos: Crédito do Ativo Imobilizado"
       aAdd(aListBox,OemToAnsi(STR0075));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0075));aAdd(aValid,"VldCfpPA('N','NUM')")
       // "0004 - Outros Créditos: Crédito Cheque Moradia"
       aAdd(aListBox,OemToAnsi(STR0076));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0076));aAdd(aValid,"VldCfpPA('N','NUM')")
       // "0005 - Outros Créditos: Crédito Transfrência por Cheque Moradia"
       aAdd(aListBox,OemToAnsi(STR0077));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0077));aAdd(aValid,"VldCfpPA('N','NUM')")

	   // Novos parametros - DIEF2006
       // "0006 - Outros Créditos: Credito Homologado por Antecipação na Saída"
       aAdd(aListBox,OemToAnsi(STR0141));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0141));aAdd(aValid,"VldCfpPA('N','NUM')")
       // "0007 - Outros Créditos: Credito Pelo Recolhimento do ICMS Antecipado Especial"
       aAdd(aListBox,OemToAnsi(STR0142));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0142));aAdd(aValid,"VldCfpPA('N','NUM')")

       // Novo parametros - DIEF2008
       // "0008 - Outros Créditos: Credito Pelo Recolhimento do ICMS Antecipado Glosa Crédito"
       aAdd(aListBox,OemToAnsi(STR0157));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0157));aAdd(aValid,"VldCfpPA('N','NUM')")

       // "0009 - Saldos Credores Transferidos Entre Estab. do Mesmo Grupo"
       aAdd(aListBox,OemToAnsi(STR0139));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0139));aAdd(aValid,"VldCfpPA('N','NUM')")
       // "0010 - Saldos Credores Transferidos Para Outro Estabelecimento"
       aAdd(aListBox,OemToAnsi(STR0140));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0140));aAdd(aValid,"VldCfpPA('N','NUM')")
       // "0011 - Saldos Credores Recebidos por Transf. Entre Estab. do Mesmo Grupo"
       aAdd(aListBox,OemToAnsi(STR0143));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0143));aAdd(aValid,"VldCfpPA('N','NUM')")
       // "0012 - Saldos Credores Recebidos por Transf. de Outro Estab."
       aAdd(aListBox,OemToAnsi(STR0144));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0144));aAdd(aValid,"VldCfpPA('N','NUM')")
       // "0013 - Deduções da Lei Semear"
       aAdd(aListBox,OemToAnsi(STR0145));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0145));aAdd(aValid,"VldCfpPA('N','NUM')")
       // "0014 - Outras Deduções"
       aAdd(aListBox,OemToAnsi(STR0146));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0146));aAdd(aValid,"VldCfpPA('N','NUM')")

	   // Novos parametros - DIEF2007
       // "0015 - Outros Créditos: Crédito Presumido - Incentivo Fiscal"
       aAdd(aListBox,OemToAnsi(STR0153));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0153));aAdd(aValid,"VldCfpPA('N','NUM')")
       // "0016 - Outros Créditos: Crédito Presumido - Outros Créditos"
       aAdd(aListBox,OemToAnsi(STR0154));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0154));aAdd(aValid,"VldCfpPA('N','NUM')")
       // "0017 - Deduções da FICOP"
       aAdd(aListBox,OemToAnsi(STR0155));aAdd(aSel,.T.);aAdd(aMsg,OemToAnsi(STR0155));aAdd(aValid,"VldCfpPA('N','NUM')")
    EndCase

	For nI := 1 To (Len (aListBox))
		aListBox[nI]	:=	OemToAnsi(aListBox[nI])
		aMsg[nI]		:=	OemToAnsi(aMsg[nI])
	Next (nI)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Le informacoes do arquivo de configuracao DIEFPA?.CFP  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Load(cCfpDia,cCfpOld)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ativa ListBox com opcoes para o array da configuracao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    Do Case
	    Case nReg == 1
		   cBarra	:=	STR0024 // "Informacoes do Estabelecimento"
	   	Case nReg == 2
	       cBarra	:=	STR0025 // "Informacoes do Contabilista"
	    Case nReg == 3
	       cBarra	:=	STR0026 // "Informacoes da Declaracao"
	    Case nReg == 4
	       cBarra	:=	STR0078 // "Despesas Gerais do Ano Anterior"
	    Case nReg == 5
	       cBarra	:=	STR0079 // "Informacoes sobre o Estoque Anterior e Atual"
	    Case nReg == 6
	       cBarra	:=	STR0080 // "Informacoes sobre a Apuração do ICMS"
    EndCase

	cTitJan	:=	"DIEF - PA"

	If !isBlind()
		
		Define MSDialog oDlgGet Title OemToAnsi (cBarra) From 223, 150 To 510, 661 Pixel Of oMainWnd
		@ 006, 015 Say OemToAnsi (cTitJan) Size 140, 007 Of oDlgGet Pixel
		@ 016, 015 To 127, 244 LABEL "" OF oDlgGet Pixel
		@ 027, 022 ListBox oListBox Var cVar Fields Header "" On DBLCLICK (List (oListBox,nReg)) Size 215, 90 Pixel

		oListBox:SetArray (aListBox)
		oListBox:bLine := {||{aListBox[oListBox:nAt]}}

		Define SButton From 130, 190 Type 1 Action (nOpca := 1, oDlgGet:End ()) Enable Of oDlgGet
		Define SButton From 130, 218 Type 2 Action (nOpca := 2, oDlgGet:End ()) Enable Of oDlgGet

		Activate MSDialog oDlgGet Centered
	
	Else
		nOpca := 1
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava itens no arquivo de configuracao DIEFPA?.CFP  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (nOpcA==1)
		GravaIt (cCfpDia)
	Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Load      ³ Autor ³Mary C. Hergert        ³ Data ³09/08/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Carrega conteudo do arquivo de configuracao                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cArqINI -> Arquivo .CFP a ser criado.                       ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Load(cArqIni,cCfpOld)
Local nI		:= 0
Local lAchou	:= .F.
Local cConteudo	:= ""

If File(cArqIni)
	lAchou  := .T.
ElseIf File(cCfpOld)
	cArqIni := cCfpOld
	lAchou  := .T.
EndIf

If lAchou
	For nI := 1 To Len(aListBox)
		cConteudo := ""
		If (IsDigit(SubStr(aListBox[nI], 2, 4)))
			cConteudo := Ler(cArqIni, Substr(aListBox[nI], 2, 4))
			If (Len(cConteudo)<254)
				cConteudo := cConteudo+Space(254-Len(cConteudo))
			EndIf
		Endif
		aAdd(aConteudo, cConteudo)
	Next
Else
	For nI := 1 To (Len(aListBox))
		aAdd(aConteudo, Space(254))
	Next
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GravaIt   ³ Autor ³Mary C. Hergert        ³ Data ³09/08/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Grava arquivo de confuiguracao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cArqIni -> Arquivo .CFP a ser criado.                       ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GravaIt (cArqIni)
Local cArqBkp	:= StrTran(cArqIni, ".CFP", ".#CF")
Local aGravar	:= {}
Local nI		:= 0

If File(cArqBkp)
	Ferase(cArqBkp)
Endif
FRename(cArqIni,cArqBkp)
nHandle	:=	MSFCREATE(cArqIni)
For nI := 1 To (Len(aListBox))
	If (IsDigit(Substr(aListBox[nI], 2, 4)))
		aAdd(aGravar, "["+Substr (aListBox[nI], 2, 4)+"]="+RTrim(aConteudo[nI])+Chr(13)+Chr(10))
	EndIf
Next
For nI := 1 To (Len(aGravar))
	FWrite(nHandle, aGravar[nI], Len(aGravar[nI]))
Next
FClose(nHandle)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³List      ³ Autor ³Mary C. Hergert        ³ Data ³09/08/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Atualiza parametro clicando.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO -> oListBox = Objeto listbox.                          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function List (oListBox,nReg)
	Local oDlgGet2
	Local lUpdated	:=	.F.
	Local bValid
	Local aOpcao    := {}
	Local lCombo    := .F.

	Private cCampo	:=	"cCpoItem"

	nAt	:=	oListBox:nAt

	Private cValid	:=	"{||"+aValid[nAt]+"}"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define opcoes do ComboBox                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

    Do Case
	Case nReg == 1
       Do Case
	   Case Substr(aListBox[nAt],1,4) == "0001"
          aOpcao    := {STR0090,STR0091,STR0092,STR0093,STR0094,STR0095,STR0096,STR0097,STR0098,STR0099,STR0100,;
          				STR0101,STR0102,STR0103,STR0104,STR0105,STR0106,STR0107,STR0108,STR0109,STR0110,STR0111,;
          				STR0112,STR0113,STR0114,STR0115,STR0116,STR0117,STR0118,STR0119,STR0120,STR0121,STR0122,;
          				STR0123,STR0124,STR0125,STR0126,STR0127,STR0128}
          				// {"AER - Aeroporto","ALD - Alameda","ALT - Altos","AVE - Avenida","BEC - Beco","CAI - Cais",
						// "CAM - Caminho","CHC - Chácara","CNJ - Conjunto","CON - Condomínio","CTR - Centro","EST - Estrada",
						// "ETR - Estrada","FAV - Favela","FAZ - Fazenda","FEI - 	Feira","FRT - Fortaleza","GAL - Galeria",
						// "ILH - Ilha","JAR - Jardim","LAD - Ladeira","LGO - Largo","LOT - Loteamento","LUG - Lugarejo","MER - Mercado",
						// "MRO - Morro","PAS - Passagem","PAT - Pátio","PCA - Praça","PIT - Pita","POV - Povoado","PRA - Praia","PRQ - Parque",
						// "PTE - Ponte","ROD - Rodovia","RUA - Rua","TRV - Travessa","VDO - Viaduto","VLA - Vila",
          lCombo    := .T.
       Case Substr(aListBox[nAt],1,4) == "0011"
          aOpcao    := {STR0044,STR0045} // {"T - Sim","F - Nao"}
          lCombo    := .T.
       Case Substr(aListBox[nAt],1,4) == "0012"
          aOpcao    := {STR0087,STR0085,STR0084,STR0086,STR0089} 	// {"1 - Concessionária de Serviço Público de Fornecimento de Água","2 - Empresa Geradora e Fornecedora de Energia Elétrica","3 - Prestadora de Serviço de Comunicação",
	                                                               	//  "4 - Prestadora de Serviço de Transporte Interestadual e Intermunicipal","5 - Empresa de Telecomunicações","6 - Outras Modalidades"}
          lCombo    := .T.
       EndCase
	Case nReg == 2
	   Do Case
	   Case Substr(aListBox[nAt],1,4) == "0008"
	          aOpcao    := {STR0044,STR0156} // "1 - Sim","0 - Nao"
	          lCombo    := .T.
	   EndCase
	Case nReg == 3
       Do Case
       Case Substr(aListBox[nAt],1,4) == "0001"
          aOpcao    := {STR0032,""} // {"1 - Mensal","2 - Anual"}versao 1.1 2009 nao contempla mais anual
          lCombo    := .T.
       Case Substr(aListBox[nAt],1,4) == "0002"
          aOpcao    := {STR0034,STR0035,STR0036} // {"1 - Normal","2 - Substitutiva","3 - Baixa"}
          lCombo    := .T.
       Case Substr(aListBox[nAt],1,4) == "0003"
          aOpcao    := {STR0037,STR0038} // {"1 - Sem Movimento","0 - Com Movimento"}
          lCombo    := .T.
       Case Substr(aListBox[nAt],1,4) == "0004"
          aOpcao    := {STR0039,STR0040,STR0041} // {"1 - Lucro Presumido","2 - Simples","3 - Lucro Real"}
          lCombo    := .T.
       Case Substr(aListBox[nAt],1,4) == "0005"
          aOpcao    := {STR0042,STR0043} // {"1 - Caixa","2 - Escrituracao Contabil"}
          lCombo    := .T.
       Case Substr(aListBox[nAt],1,4) == "0007"
          aOpcao    := {STR0147,STR0148,STR0149,STR0150} // "0 - Nada","1 - Rural","2 - Serviço","3 - Extracao Mineral"}
          lCombo    := .T.
       Case Substr(aListBox[nAt],1,4) $ "0008#0009#0010#0011#0014#0015"
          aOpcao    := {STR0044,STR0045} // "1 - Sim","0 - Nao"
          lCombo    := .T.
       EndCase
    EndCase

	If (aSel[nAt])
		&cCampo	:=	aConteudo[nAt]
		bValid	:=	&(cValid)

		Define MSDialog oDlgGet2 Title aMsg[nAt] From  300,100 To 400,620 Pixel Of oListBox
		@ 08, 20 To 30, 237 LABEL "" Of oDlgGet2 Pixel
		If lCombo
			@ 15, 24 ComboBox &cCampo items aOpcao size 210,08 of oDlgGet2 pixel
		Else
			@ 15, 24 MSGet &cCampo Picture "@!" Valid Eval (bValid) Size 210, 08 Of oDlgGet2 Pixel
		EndIf

		Define SButton From 032, 182 Type 1 Action (lUpdated:=.T.,oDlgGet2:End ()) Enable Of oDlgGet2
		Define SButton From 032, 210 Type 2 Action (lUpdated:=.F.,oDlgGet2:End ()) Enable Of oDlgGet2

		Activate MSDialog oDlgGet2 Centered

		If (lUpdated)
			aConteudo[nAt] := StrTran (&cCampo,'"',"'")
		Endif
	Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Ler       ³ Autor ³Mary C. Hergert        ³ Data ³09/08/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Le o CFP.                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpL -> lEnd                                                ³±±
±±³          ³ExpC -> cCpo                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ler (cArqIni, cCPO, lEnd)

Local cIni		:= ""
Local cConteudo	:= ""
Local nI		:= 0

lEnd := If(lEnd==NIL, .F., lEnd)
cCPO := "["+cCPO+"]="

If !File(cArqIni)
	Help(" ",1,"DIEFPA?.CFP")
	lContinua	:= .F.
	lEnd		:= .T.
	Return (cIni)
Else
	cConteudo	:= MemoRead(cArqIni)
	nLinhas		:= MlCount(cConteudo, 254)
	For nI := 1 To nLinhas
		cLinha	:=	AllTrim(MemoLine(cConteudo, 254, nI))
		If (cCPO$cLinha)
			cIni := SubStr(cLinha, 8)
			Exit
		Endif
	Next
Endif

Return(cIni)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³VldCfpPA  ³ Autor ³Mary C. Hergert        ³ Data ³09/08/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Valida string do CFP.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL -> lRet (.T./.F.)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC -> cTipo - Tipo do campo.                              ³±±
±±³          ³ExpC -> cCampo - Campo a ser tratado.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function VldCfpPA (cTipo, cCampo)

	Local	lRet		:=	.T.
	Local	cConteudo	:=	&(ReadVar())
	Local	nI			:=	0

	Default	cTipo	:=	""
	Default	cCampo	:=	""

	cConteudo	:=	Alltrim (cConteudo)

	If (cTipo=="N")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Avalia valores numericos                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !(Isdigit (SubStr (cConteudo, nI, 1)))  
			lRet	:=	.F.
			If SubStr (cConteudo, nI, 1) == "-"
			   lRet := .T.
			EndIf
		Endif
	ElseIf cTipo=="D"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Avalia datas.                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
		If (CToD (cConteudo)==CToD (Space (8)))
		   lRet	:=	.F.
		Endif
	EndIf
	//
	If (cCampo=="VAL")
		If (Len (AllTrim (cConteudo))>16) .OR. !("."$((cConteudo)))
		   Help (" ", 1, STR0046,,STR0047, 3, 0)	// "VALOR INVALIDO" "Inserir Valor no formato 9999999999999.99"
		   lRet	:=	.F.
		EndIf
	ElseIf (cCampo=="NUM")
		If !IsDigit(cConteudo)
		   Help (" ", 1, STR0046,,STR0048, 3, 0)	// "VALOR INVALIDO" "Inserir Valor numérico"
		   lRet	:=	.F.
		EndIf
	ElseIf (cCampo=="FON")
  	    If (Len (AllTrim (cConteudo))<7)
		   Help (" ", 1, STR0049,,STR0050, 3, 0)	// "FORMATO INVALIDO" "Inserir Telefone no Formato 999-9999 ou 9999-9999"
		   lRet	:=	.F.
		EndIf
	ElseIf (cCampo=="DAT") 	
	  	If (Len (AllTrim (cConteudo))<>10)
		   Help (" ", 1, STR0051,,STR0052, 3, 0)	// "DATA INVALIDA" "Inserir Data no Formato DD/MM/AAAA"
		   lRet	:=	.F.
		EndIf   
	ElseIf (cCampo=="CEN") 	
		If (Len (AllTrim (cConteudo))>13) .OR. ("."$((cConteudo))) .OR. (","$((cConteudo)))
		   Help (" ", 1, STR0046,,STR0053, 3, 0)	// "VALOR INVALIDO" "Inserir Valor, sem considerar os centavos, no formato 9999999999999"
		   lRet	:=	.F.
		EndIf
    EndIf	

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³LeCfp     ³ Autor ³Mary C. Hergert        ³ Data ³09/08/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Monta o CFP em um array para ser utilizado no INI.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL -> aRet - array conteudo CFP.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC -> cArquivo - Arquivo CFP.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function LeCfp(cArquivo)

Local cConteudo	:= MemoRead(cArquivo)
Local nLinhas	:= MlCount(cConteudo, 254)
Local nI		:= 0
Local aRet		:= {}

For nI := 1 To nLinhas
	cLinha := AllTrim(MemoLine(cConteudo, 254, nI))
	aAdd(aRet, {SubStr(cLinha, 2, 3), SubStr(cLinha, 8)})
Next

Return (aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AnexoI    ºAutor  ³Mary C. Hergert     º Data ³ 11/08/2004  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Totaliza compras de produtores rurais e movimentos de       º±±
±±º          ³entrada/saida de acordo com os CFOPs cadastrados parametro  º±±
±±º          ³(Anual)                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³DIEFPA                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AnexoI(dDtIni,dDtFim,cNrLivro,cTipoEmpr)

	Local aStruct	:= {}
	Local aProd		:= {}
	Local aTrbs		:= {}

	Local cCodMun	:= ""

	Local nInd		:= 1

	Local nMVCDDIEF := SB5->(FieldPos(SuperGetMV("MV_CODDIEF")))
	Local nMVA1DIEF := SA1->(FieldPos(SuperGetMV("MV_A1DIEF")))
	Local nMVA2DIEF := SA2->(FieldPos(SuperGetMV("MV_A2DIEF")))
	Local dAnoDief  := Ctod("  /  /    ")
	Local dAnual1   := Ctod("  /  /    ")
	Local dAnual2   := Ctod("  /  /    ")

	Local cProdDief := ""
	Local cCfopMov  := SuperGetMV("MV_CFODIEF")
	Local cAliasSF3 := "SF3"
	Local cFilSB5   := xFilial("SB5")
	Local cFilSA1   := xFilial("SA1")
	Local cFilSA2   := xFilial("SA2")
	Local cFilSD1   := xFilial("SD1")
	Local cFilSD2   := xFilial("SD2")

	#IFDEF TOP
		Local aStruSF3  := {}
		Local cCondicao := ""
	#ENDIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Consideracoes que deverao ser analisadas referentes ao SF3 de acordo com os parametros da rotina - TOP         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	#IFDEF TOP
		If cNrLivro <> "*"
			cCondicao += " SF3.F3_NRLIVRO = '"+cNrLivro+"' AND "
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Condicao que será adicionada a query somente se necessário       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(cCondicao)
			cCondicao := "%%"
		Else
			cCondicao := "% " + cCondicao + " %"
		Endif
	#ENDIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tabela Temporaria (Anual) com os Movimentos                                   ³
	//³Energia Eletrica, Comunicacao, Fornecimento Agua e Compra de Produtor Rural   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AADD(aStruct,{"CODSERV"	,"C",003,0})
	AADD(aStruct,{"CODPROD"	,"C",005,0})
	AADD(aStruct,{"CODMUN"	,"C",005,0})
	AADD(aStruct,{"VALSAI"	,"N",014,2})
	AADD(aStruct,{"VALENT"	,"N",014,2})
	AADD(aStruct,{"QUANT"	,"N",014,2})

	cArqTRB := CriaTrab(aStruct)
	dbUseArea(.T.,__LocalDriver,cArqTRB,"TRB")

	cArqTRB1 := CriaTrab(Nil,.F.)
	IndRegua ("TRB",cArqTRB1,"CODSERV+CODMUN")
	dbClearIndex()

	cArqTRB2 := CriaTrab(Nil,.F.)
	IndRegua ("TRB",cArqTRB2,"CODPROD+CODMUN")
	dbClearIndex()

	cArqTRB3 := CriaTrab(Nil,.F.)
	IndRegua ("TRB",cArqTRB3,"CODSERV+CODMUN+CODPROD")
	dbClearIndex()

	aTrbs := {{cArqTRB,"TRB"}}

	dbSelectArea("TRB")
	dbSetIndex(cArqTRB1+OrdBagExt())
	dbSetIndex(cArqTRB2+OrdBagExt())
	dbSetIndex(cArqTRB3+OrdBagExt())
	TRB->(dbSetOrder(1))

	If nMVCDDIEF == 0
		Return(aTrbs)
	EndIf

	dbSelectArea("SA1")
	dbSetOrder(1) //A1_FILIAL+A1_COD+A1_LOJA
	dbSelectArea("SA2")
	dbSetOrder(1) //A2_FILIAL+A2_COD+A2_LOJA
	dbSelectArea("SB5")
	dbSetOrder(1) //B5_FILIAL+B5_COD
	dbSelectArea("SF3")
	dbSetOrder(1) //F3_FILIAL+F3_ENTRADA+F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA+F3_CFO+F3_ALIQICM

	//Pega os dados do ano de anterior
	If Alltrim(Str(Year(dDtFim)))>"2010"
		dAnoDief := Year(dDtFim)-1
		dAnual1 := Ctod("01/01/" + Str(dAnoDief))
		dAnual2 := Ctod("31/12/" + Str(dAnoDief))
	Else
		dAnual1 := dDtIni
		dAnual2 := dDtFim
	Endif

	#IFDEF TOP
		If TcSrvType()<>"AS/400"
			lQuery    := .T.
			cAliasSF3 := GetNextAlias()
			aStruSF3  := SF3->(dbStruct())
			BeginSql Alias cAliasSF3
				COLUMN F3_ENTRADA AS DATE
				COLUMN F3_DTCANC AS DATE
				SELECT 	SF3.F3_FILIAL, SF3.F3_ENTRADA, SF3.F3_ESPECIE, SF3.F3_CFO, SF3.F3_NFISCAL, SF3.F3_SERIE,
						SF3.F3_CLIEFOR, SF3.F3_LOJA, SF3.F3_DTCANC, SF3.F3_TIPO
				FROM 	%table:SF3% SF3
				WHERE 	SF3.F3_FILIAL = %xFilial:SF3% AND
						SF3.F3_ENTRADA >= %Exp:dAnual1% AND
						SF3.F3_ENTRADA <= %Exp:dAnual2% AND
						SF3.F3_DTCANC = %Exp:Dtos(Ctod(''))% AND
						%Exp:cCondicao%
						SF3.%NotDel%
				ORDER BY %Order:SF3%
			EndSql
		Else
	#ELSE
		dbSelectArea(cAliasSF3)
		cIndSF3 := CriaTrab(NIL,.F.)
		cChave  := IndexKey()
		cFiltro := "SF3->F3_FILIAL=='"+xFilial("SF3")+"' .And. DTOS(SF3->F3_ENTRADA)>='"+Dtos(dAnual1)+"' .AND. DTOS(SF3->F3_ENTRADA)<='"+Dtos(dAnual2)+"'"
		cFiltro += " .And. DTOS(SF3->F3_DTCANC)=='"+Dtos(Ctod(""))+"'"
		If cNrLivro <> "*"
			cFiltro += " .And. SF3->F3_NRLIVRO=='"+cNrLivro+"'"
		Endif
		IndRegua(cAliasSF3,cIndSF3,cChave,,cFiltro)
	#ENDIF

	(cAliasSF3)->(DbgoTop())

	#IFDEF TOP
		Endif
	#ENDIF

	Do While !(cAliasSF3)->(Eof()) .And. Iif(lQuery,.T.,(cAliasSF3)->F3_FILIAL == xFilial("SF3") .And. (cAliasSF3)->F3_ENTRADA<=dAnual2)

		// Apenas documentos de compra de produtor rural ou CFOPs que indiquem a movimentação do tipo da empresa
		If AllTrim((cAliasSF3)->F3_ESPECIE) <> "NFP" .And. !AllTrim((cAliasSF3)->F3_CFO)$cCfopMov
			(cAliasSF3)->(dbSkip())
			Loop
		Endif

		If SubStr((cAliasSF3)->F3_CFO,1,1) < "5"
			aProd  := {}
			cChave := cFilSD1 + (cAliasSF3)->F3_NFISCAL + (cAliasSF3)->F3_SERIE + (cAliasSF3)->F3_CLIEFOR + (cAliasSF3)->F3_LOJA
			SD1->(dbSetOrder(1)) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
			SD1->(dbSeek(cChave))
			Do While !SD1->(Eof()) .And. cChave == SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)

				If SD1->D1_CF <> (cAliasSF3)->F3_CFO
					SD1->(dbSkip())
					Loop
				Endif

				cProdDief := ""
				If SB5->(msSeek(cFilSB5+SD1->D1_COD))
					cProdDief := Str(Val(SB5->(FieldGet(nMVCDDIEF))),5)
				EndIf

				If !Empty(cProdDief)
					Aadd(aProd,{cProdDief, SD1->D1_QUANT, SD1->D1_TOTAL, 0})
				Endif

				SD1->(dbSkip())
			Enddo
		Else
			aProd  := {}
			cChave := cFilSD2 + (cAliasSF3)->F3_NFISCAL + (cAliasSF3)->F3_SERIE + (cAliasSF3)->F3_CLIEFOR + (cAliasSF3)->F3_LOJA
			SD2->(dbSetOrder(3)) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
			SD2->(dbSeek(cChave))
			Do While !SD2->(Eof()) .And. cChave == SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA)

				If SD2->D2_CF <> (cAliasSF3)->F3_CFO
					SD2->(dbSkip())
					Loop
				Endif

				cProdDief := ""
				If SB5->(msSeek(cFilSB5+SD2->D2_COD))
					cProdDief := Str(Val(SB5->(FieldGet(nMVCDDIEF))),5)
				EndIf
				If !Empty(cProdDief)
					Aadd(aProd,{cProdDief, SD2->D2_QUANT, 0, SD2->D2_TOTAL})
				Endif

				SD2->(dbSkip())
			Enddo
		Endif

		// Buscando Cliente/Fornecedor do documento
		cCodMun := ""
		If SubStr((cAliasSF3)->F3_CFO,1,1) < "5" .And. !(cAliasSF3)->F3_TIPO$'DB' .Or. (SubStr((cAliasSF3)->F3_CFO,1,1) > "5" .And. (cAliasSF3)->F3_TIPO$'DB')
			SA2->(msSeek(cFilSA2+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
			If nMVA2DIEF <> 0
				cCodMun := Str(Val(SA2->(FieldGet(nMVA2DIEF))),5)
			EndIf
		Else
			SA1->(msSeek(cFilSA1+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
			If nMVA1DIEF <> 0
				cCodMun := Str(Val(SA1->(FieldGet(nMVA1DIEF))),5)
			EndIf
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³NFP = Nota de Produtor Rural                                     ³
		//³Este tipo de documento necessita que sejam informados os produtos³
		//³adquiridos com os códigos da Receita Federal.                    ³
		//³Outros documentos que atendam os CFOPs configurados pelo usuário ³
		//³serão lançados como serviços.                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nInd := 1 to Len(aProd)
			If AllTrim((cAliasSF3)->F3_ESPECIE) == "NFP"
				TRB->(dbSetOrder(2))
				If !TRB->(dbSeek(aProd[nInd,1]+cCodMun))
					RecLock("TRB",.T.)
					TRB->CODSERV	:= "5"
					TRB->CODPROD	:= aProd[nInd,1]
					TRB->CODMUN		:= cCodMun
					TRB->QUANT		:= aProd[nInd,2]
					TRB->VALENT		:= aProd[nInd,3]
					TRB->VALSAI		:= aProd[nInd,4]
					MsUnlock()
				Else
					RecLock("TRB",.F.)
					TRB->QUANT		+= aProd[nInd,2]
					TRB->VALENT		+= aProd[nInd,3]
					TRB->VALSAI		+= aProd[nInd,4]
					MsUnlock()
				Endif
			Else
				TRB->(dbSetOrder(3))
				If !TRB->(dbSeek(cTipoEmpr+cCodMun+aProd[nInd,1]))
					RecLock("TRB",.T.)
					TRB->CODSERV	:= cTipoEmpr
					TRB->CODPROD	:= aProd[nInd,1]
					TRB->CODMUN		:= cCodMun
					TRB->QUANT		:= aProd[nInd,2]
					TRB->VALENT		:= aProd[nInd,3]
					TRB->VALSAI		:= aProd[nInd,4]
					MsUnlock()
				Else
					RecLock("TRB",.F.)
					TRB->QUANT		+= aProd[nInd,2]
					TRB->VALENT		+= aProd[nInd,3]
					TRB->VALSAI		+= aProd[nInd,4]
					MsUnlock()
				Endif
			Endif
		Next
		(cAliasSF3)->(dbSkip())
	Enddo

	#IFDEF TOP
		dbSelectArea(cAliasSF3)
		dbCloseArea()
	#ENDIF

Return(aTrbs)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AnexoIM   ºAutor  ³Cecilia Carvalho    º Data ³ 09/03/2011  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Totaliza compras de produtores rurais e movimentos de       º±±
±±º          ³entrada/saida de acordo com os CFOPs cadastrados parametro  º±±
±±º          ³(Mensal)                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³DIEFPA                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AnexoIM(dDtIni,dDtFim,cNrLivro,cTipoEmpr)

	Local aStruct	:= {}
	Local aProd		:= {}
	Local aTrbs		:= {}

	Local cCodMun	:= ""

	Local nInd		:= 1

	Local nMVCDDIEF := SB5->(FieldPos(SuperGetMV("MV_CODDIEF")))
	Local nMVA1DIEF := SA1->(FieldPos(SuperGetMV("MV_A1DIEF")))
	Local nMVA2DIEF := SA2->(FieldPos(SuperGetMV("MV_A2DIEF")))
	
	Local cProdDief	:= ""
	Local cCfopMov	:= SuperGetMV("MV_CFODIEF")
	Local cAliasSF3 := "SF3"
	Local cFilSB5   := xFilial("SB5")
	Local cFilSA1   := xFilial("SA1")
	Local cFilSA2   := xFilial("SA2")
	Local cFilSD1   := xFilial("SD1")
	Local cFilSD2   := xFilial("SD2")

	#IFDEF TOP
		Local aStruSF3  := {}
		Local cCondicao := ""
	#ENDIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Consideracoes que deverao ser analisadas referentes ao SF3 de acordo com os parametros da rotina - TOP         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	#IFDEF TOP
		If cNrLivro <> "*"
			cCondicao += " SF3.F3_NRLIVRO = '"+cNrLivro+"' AND "
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Condicao que será adicionada a query somente se necessário       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(cCondicao)
			cCondicao := "%%"
		Else
			cCondicao := "% " + cCondicao + " %"
		Endif
	#ENDIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tabela Temporaria (Anual) com os Movimentos                                   ³
	//³Energia Eletrica, Comunicacao, Fornecimento Agua e Compra de Produtor Rural   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AADD(aStruct,{"CODSERV"	,"C",003,0})
	AADD(aStruct,{"CODPROD"	,"C",005,0})
	AADD(aStruct,{"CODMUN"	,"C",005,0})
	AADD(aStruct,{"VALSAI"	,"N",014,2})
	AADD(aStruct,{"VALENT"	,"N",014,2})
	AADD(aStruct,{"QUANT"	,"N",014,2})

	cArqTRB := CriaTrab(aStruct)
	dbUseArea(.T.,__LocalDriver,cArqTRB,"TRM")

	cArqTRB1 := CriaTrab(Nil,.F.)
	IndRegua ("TRM",cArqTRB1,"CODSERV+CODMUN")
	dbClearIndex()
	
	cArqTRB2 := CriaTrab(Nil,.F.)
	IndRegua ("TRM",cArqTRB2,"CODPROD+CODMUN")
	dbClearIndex()
	
	cArqTRB3 := CriaTrab(Nil,.F.)
	IndRegua ("TRM",cArqTRB3,"CODSERV+CODMUN+CODPROD")
	dbClearIndex()

	aTrbs := {{cArqTRB,"TRM"}}

	dbSelectArea("TRM")
	dbSetIndex(cArqTRB1+OrdBagExt())
	dbSetIndex(cArqTRB2+OrdBagExt())
	dbSetIndex(cArqTRB3+OrdBagExt())
	TRM->(dbSetOrder(1))

	If nMVCDDIEF == 0
		Return(aTrbs)
	EndIf

	dbSelectArea("SA1")
	dbSetOrder(1) //A1_FILIAL+A1_COD+A1_LOJA
	dbSelectArea("SA2")
	dbSetOrder(1) //A2_FILIAL+A2_COD+A2_LOJA
	dbSelectArea("SB5")
	dbSetOrder(1) //B5_FILIAL+B5_COD
	dbSelectArea("SF3")
	dbSetOrder(1) //F3_FILIAL+F3_ENTRADA+F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA+F3_CFO+F3_ALIQICM

	#IFDEF TOP
		If TcSrvType()<>"AS/400"
			lQuery    := .T.
			cAliasSF3 := GetNextAlias()
			aStruSF3  := SF3->(dbStruct())
			BeginSql Alias cAliasSF3
				COLUMN F3_ENTRADA AS DATE
				COLUMN F3_DTCANC AS DATE
				SELECT 	SF3.F3_FILIAL, SF3.F3_ENTRADA, SF3.F3_ESPECIE, SF3.F3_CFO, SF3.F3_NFISCAL, SF3.F3_SERIE,
						SF3.F3_CLIEFOR, SF3.F3_LOJA, SF3.F3_DTCANC, SF3.F3_TIPO
				FROM 	%table:SF3% SF3
				WHERE 	SF3.F3_FILIAL = %xFilial:SF3% AND 
						SF3.F3_ENTRADA >= %Exp:dDtIni% AND 
						SF3.F3_ENTRADA <= %Exp:dDtFim% AND 
						SF3.F3_DTCANC = %Exp:Dtos(Ctod(''))% AND
						%Exp:cCondicao%
						SF3.%NotDel%
				ORDER BY %Order:SF3%
			EndSql
		Else
	#ELSE
		dbSelectArea(cAliasSF3)
		cIndSF3 := CriaTrab(NIL,.F.)
		cChave  := IndexKey()
		cFiltro := "SF3->F3_FILIAL=='"+xFilial("SF3")+"' .And. DTOS(SF3->F3_ENTRADA)>='"+Dtos(dDtIni)+"' .AND. DTOS(SF3->F3_ENTRADA)<='"+Dtos(dDtFim)+"'"						
		cFiltro += " .And. DTOS(SF3->F3_DTCANC)=='"+Dtos(Ctod(""))+"'"	
		If cNrLivro <> "*"
			cFiltro	+= " .And. SF3->F3_NRLIVRO=='"+cNrLivro+"'"
		Endif
		IndRegua(cAliasSF3,cIndSF3,cChave,,cFiltro)
	#ENDIF

	(cAliasSF3)->(DbgoTop())

	#IFDEF TOP
		Endif
	#ENDIF

	Do While !(cAliasSF3)->(Eof()) .And. Iif(lQuery,.T.,(cAliasSF3)->F3_FILIAL == xFilial("SF3") .And. (cAliasSF3)->F3_ENTRADA<=dDtFim)

		// Apenas documentos de compra de produtor rural ou CFOPs que indiquem a movimentação do tipo da empresa
		If AllTrim((cAliasSF3)->F3_ESPECIE) <> "NFP" .And. !AllTrim((cAliasSF3)->F3_CFO)$cCfopMov
			(cAliasSF3)->(dbSkip())
			Loop
		Endif

		If SubStr((cAliasSF3)->F3_CFO,1,1) < "5"
			aProd  := {}
			cChave := cFilSD1 + (cAliasSF3)->F3_NFISCAL + (cAliasSF3)->F3_SERIE + (cAliasSF3)->F3_CLIEFOR + (cAliasSF3)->F3_LOJA
			SD1->(dbSetOrder(1)) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
			SD1->(dbSeek(cChave))
			Do While !SD1->(Eof()) .And. cChave == SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)

				If SD1->D1_CF <> (cAliasSF3)->F3_CFO
					SD1->(dbSkip())
					Loop
				Endif

				cProdDief := ""
				If SB5->(msSeek(cFilSB5+SD1->D1_COD))
					cProdDief := Str(Val(SB5->(FieldGet(nMVCDDIEF))),5)
				EndIf

				If !Empty(cProdDief)
					Aadd(aProd,{cProdDief, SD1->D1_QUANT, SD1->D1_TOTAL, 0})
				Endif

				SD1->(dbSkip())
			Enddo
		Else
			aProd  := {}
			cChave := cFilSD2 + (cAliasSF3)->F3_NFISCAL + (cAliasSF3)->F3_SERIE + (cAliasSF3)->F3_CLIEFOR + (cAliasSF3)->F3_LOJA
			SD2->(dbSetOrder(3)) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
			SD2->(dbSeek(cChave))
			Do While !SD2->(Eof()) .And. cChave == SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA)

				If SD2->D2_CF <> (cAliasSF3)->F3_CFO
					SD2->(dbSkip())
					Loop
				Endif

				cProdDief := ""
				If SB5->(msSeek(cFilSB5+SD2->D2_COD))
					cProdDief := Str(Val(SB5->(FieldGet(nMVCDDIEF))),5)
				EndIf

				If !Empty(cProdDief)
					Aadd(aProd,{cProdDief, SD2->D2_QUANT, 0, SD2->D2_TOTAL})
				EndIf

				SD2->(dbSkip())
			Enddo
		Endif

		// Buscando Cliente/Fornecedor do documento
		cCodMun := ""
		If SubStr((cAliasSF3)->F3_CFO,1,1) < "5" .And. !(cAliasSF3)->F3_TIPO$'DB' .Or. (SubStr((cAliasSF3)->F3_CFO,1,1) > "5" .And. (cAliasSF3)->F3_TIPO$'DB')
			SA2->(msSeek(cFilSA2+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
			If nMVA2DIEF <> 0
				cCodMun := Str(Val(SA2->(FieldGet(nMVA2DIEF))),5)
			EndIf
		Else
			SA1->(msSeek(cFilSA1+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
			If nMVA1DIEF <> 0
				cCodMun := Str(Val(SA1->(FieldGet(nMVA1DIEF))),5)
			EndIf
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³NFP = Nota de Produtor Rural                                     ³
		//³Este tipo de documento necessita que sejam informados os produtos³
		//³adquiridos com os códigos da Receita Federal.                    ³
		//³Outros documentos que atendam os CFOPs configurados pelo usuário ³
		//³serão lançados como serviços.                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nInd := 1 to Len(aProd)
			If AllTrim((cAliasSF3)->F3_ESPECIE) == "NFP"
				TRM->(dbSetOrder(2))
				If !TRM->(dbSeek(aProd[nInd,1]+cCodMun))
					RecLock("TRM",.T.)
					TRM->CODSERV	:= "5"
					TRM->CODPROD	:= aProd[nInd,1]
					TRM->CODMUN		:= cCodMun
					TRM->QUANT		:= aProd[nInd,2]
					TRM->VALENT		:= aProd[nInd,3]
					TRM->VALSAI		:= aProd[nInd,4]
					MsUnlock()
				Else
					RecLock("TRM",.F.)
					TRM->QUANT		+= aProd[nInd,2]
					TRM->VALENT		+= aProd[nInd,3]
					TRM->VALSAI		+= aProd[nInd,4]
					MsUnlock()
				Endif
			Else
				TRM->(dbSetOrder(3))
				If !TRM->(dbSeek(cTipoEmpr+cCodMun+aProd[nInd,1]))
					RecLock("TRM",.T.)
					TRM->CODSERV	:= cTipoEmpr
					TRM->CODPROD	:= aProd[nInd,1]
					TRM->CODMUN		:= cCodMun
					TRM->QUANT		:= aProd[nInd,2]
					TRM->VALENT		:= aProd[nInd,3]
					TRM->VALSAI		:= aProd[nInd,4]
					MsUnlock()
				Else
					RecLock("TRM",.F.)
					TRM->QUANT		+= aProd[nInd,2]
					TRM->VALENT		+= aProd[nInd,3]
					TRM->VALSAI		+= aProd[nInd,4]
					MsUnlock()
				Endif
			Endif
		Next
		(cAliasSF3)->(dbSkip())
	Enddo

	#IFDEF TOP
		dbSelectArea(cAliasSF3)
		dbCloseArea()
	#ENDIF

Return(aTrbs)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AnexoII   ºAutor  ³Mary C. Hergert     º Data ³ 11/08/2004  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Totaliza movimentos com ICMS ST por Natureza (Entrada/Saida)º±±
±±º          ³por operacao (interna/externa) e por CNPJ.                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³DIEFPA                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AnexoII(dDtIni,dDtFim,cNrLivro)

	Local aStruct	:= {}
	Local aTrbs		:= {}

	Local cAlias    := GetNextAlias()
	Local cNatureza	:= ""
	Local cTipo		:= ""
	Local cOperacao := ""

	Local nMVA1DIEF := SA1->(FieldPos(SuperGetMV("MV_A1DIEF")))
	Local nMVA2DIEF := SA2->(FieldPos(SuperGetMV("MV_A2DIEF")))
	Local cCodMun	:= ""

	Local cCNPJ		:= ""
	Local cUF       := ""

	Local cFilSA1   := xFilial("SA1")
	Local cFilSA2   := xFilial("SA2")
	Local cFilSB1   := xFilial("SB1")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tabela Temporaria com os Movimentos                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AADD(aStruct,{"NATOPER"	,"C",001,0})
	AADD(aStruct,{"TIPO"	,"C",001,0})
	AADD(aStruct,{"NUMERO"	,"C",001,0})
	AADD(aStruct,{"CNPJ"	,"C",014,0})
	AADD(aStruct,{"UF"	    ,"C",002,0})
	AADD(aStruct,{"VALCONT"	,"N",014,2})
	AADD(aStruct,{"ICMSRET"	,"N",014,2})
	AADD(aStruct,{"CODMUN"  ,"C",006,0})
	AADD(aStruct,{"OPERACAO","C",001,0})

	cArqTRB	:=	CriaTrab(aStruct)
	dbUseArea(.T.,__LocalDriver,cArqTRB,"TST")

	cArqTRB1 := CriaTrab(Nil,.F.)
	IndRegua ("TST",cArqTRB1,"NATOPER+TIPO+OPERACAO+CNPJ")
	dbClearIndex()
	
	aTrbs := {{cArqTRB,"TST"}}
	
	dbSelectArea("TST")
	dbSetIndex(cArqTRB1+OrdBagExt())
	TST->(dbSetOrder(1))

#IFDEF TOP
	If TcSrvType()<>"AS/400"
		cAlias := GetNextAlias()
		BeginSql Alias cAlias
			COLUMN D1_DTDIGIT AS DATE
			COLUMN D1_EMISSAO AS DATE
			SELECT SD1.D1_FILIAL, SD1.D1_DTDIGIT, SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_FORNECE, SD1.D1_LOJA,
			       SD1.D1_COD, SD1.D1_ITEM, SD1.D1_EMISSAO, SD1.D1_VALICM, SD1.D1_VALANTI,
			       SD1.D1_CF, SD1.D1_TIPO, SD1.D1_TES, SD1.D1_ICMSRET, SD1.D1_TOTAL,
			       SFT.FT_VALCONT, SFT.FT_CLASFIS
			FROM %table:SD1% SD1
			JOIN %table:SFT% SFT ON SFT.FT_FILIAL = %xFilial:SFT% AND
									SFT.FT_NFISCAL = SD1.D1_DOC AND
									SFT.FT_SERIE = SD1.D1_SERIE AND
									SFT.FT_CLIEFOR = SD1.D1_FORNECE AND
									SFT.FT_LOJA = SD1.D1_LOJA AND
									SFT.FT_ITEM = SD1.D1_ITEM AND
									SFT.FT_CFOP = SD1.D1_CF AND
									SFT.%NotDel%
			WHERE SD1.D1_FILIAL = %xFilial:SD1% AND
				SD1.D1_DTDIGIT >= %Exp:dDtIni% AND
				SD1.D1_DTDIGIT <= %Exp:dDtFim% AND
				(SUBSTRING(SD1.D1_CF, 1, 1) = '1' OR SUBSTRING(SD1.D1_CF, 1, 1) = '2') AND 
				SD1.%NotDel%
			ORDER BY 1,2
		EndSql
		dbSelectArea(cAlias)
	Else
#ENDIF
cIndex  := CriaTrab(NIL,.F.)
cFiltro := "D1_FILIAL == '" + xFilial("SD1") + "' .AND. "
cFiltro += "dtos(D1_DTDIGIT) >= '"+dtos(dDtIni)+"' .AND. "
cFiltro += "dtos(D1_DTDIGIT) <= '"+dtos(dDtFim)+"' .AND. "
cFiltro += "(SUBSTRING(D1_CF,1,1) == '1' .OR. SUBSTRING(D1_CF,1,1) == '2'"
IndRegua(cAlias, cIndex, (cAlias)->(IndexKey ()),, cFiltro)
nIndex := RetIndex(cAlias)
#IFNDEF TOP
	DbSetIndex(cIndex+OrdBagExt())
#ENDIF
DbSelectArea(cAlias)
DbSetOrder(nIndex)
#IFDEF TOP
	Endif
#ENDIF

DbSelectArea(cAlias)
(cAlias)->(DbGoTop())
ProcRegua((cAlias)->(RecCount()))
While !(cAlias)->(Eof())
	// Natureza: 1 = Entrada
	// Tipo:     1 = Interna, 2 = Interestadual
	// Buscando Fornecedor do documento
	If !(cAlias)->D1_TIPO$'BD'	
		SA2->(dbSetOrder(1))
		SA2->(msSeek(cFilSA2+(cAlias)->D1_FORNECE+(cAlias)->D1_LOJA))
		cCNPJ := SA2->A2_CGC
		cUF   := SA2->A2_EST
		
		If nMVA2DIEF <> 0
			cCodMun := Str(Val(SA2->(FieldGet(nMVA2DIEF))),6)
		EndIf
		
	Else
		SA1->(dbSetOrder(1))
		SA1->(msSeek(cFilSA1+(cAlias)->D1_FORNECE+(cAlias)->D1_LOJA))
		cCNPJ := SA1->A1_CGC
		cUF   := SA1->A1_EST

		If nMVA1DIEF <> 0
			cCodMun := Str(Val(SA1->(FieldGet(nMVA1DIEF))),6)
		Endif

	EndIf

	cNatureza := "1"
	If SubStr((cAlias)->D1_CF,1,1) == "1"
		cTipo := "1" //Interna
	Else
		cTipo := "2" //Interestadual
	EndIf
	cOperacao := ""
	If SubStr((cAlias)->FT_CLASFIS,2,2) == "10" .And. (cAlias)->D1_ICMSRET > 0
		cOperacao := "1"
	ElseIf (cAlias)->D1_VALANTI > 0
		If cTipo<>"1"
			cOperacao := "2"
		EndIf
	ElseIf SubStr((cAlias)->FT_CLASFIS,2,2) == "60"
		cOperacao := "3"
	Else
		If (Alltrim((cAlias)->D1_CF) $ "1151/1152/1153/1154/1408/1409/1552/1557/1658/1659/2151/2152/2153/2154/2408/2409/2552/2557/2658/2659/")
			cOperacao := "4"
		Else
			SB1->(dbSetOrder(1))
			If SB1->(msSeek(cFilSB1+(cAlias)->D1_COD)) .And. SB1->B1_PICMENT<>0
				cOperacao := "5"
			EndIf
		EndIf
	Endif

	If !Empty(cOperacao)
		TST->(dbSetOrder(1))
		If !TST->(dbSeek(cNatureza+cTipo+cOperacao+cCNPJ))
			RecLock("TST",.T.)
			TST->NATOPER	:= cNatureza
			TST->TIPO		:= cTipo
			TST->CNPJ		:= cCNPJ
			TST->UF     	:= cUF
			TST->VALCONT	:= (cAlias)->FT_VALCONT 
			If cTipo == "1"
				If cOperacao == "1"
					TST->ICMSRET := (cAlias)->D1_ICMSRET
				Else
					TST->ICMSRET := 0
				Endif
			Else
				If cOperacao == "3" .Or. cOperacao == "5"
					TST->ICMSRET := 0
				Else
					TST->ICMSRET := (cAlias)->D1_ICMSRET
				Endif
			EndIf
			TST->CODMUN     := cCodMun
			TST->OPERACAO   := cOperacao
		Else
			RecLock("TST",.F.)
			TST->ICMSRET	+= (cAlias)->D1_ICMSRET
			TST->VALCONT	+= (cAlias)->FT_VALCONT
		Endif
		MsUnlock()
	EndIf

	(cAlias)->(DbSkip())
EndDo
DbSelectArea(cAlias)
(cAlias)->(DbCloseArea())

#IFDEF TOP
	If TcSrvType()<>"AS/400"
		cAlias := GetNextAlias()
		BeginSql Alias cAlias
			COLUMN D2_EMISSAO AS DATE
			SELECT SD2.D2_FILIAL, SD2.D2_DOC, SD2.D2_SERIE, SD2.D2_CLIENTE, SD2.D2_LOJA,
			       SD2.D2_COD, SD2.D2_ITEM, SD2.D2_EMISSAO, SD2.D2_VALICM,
			       SD2.D2_CF, SD2.D2_TIPO, SD2.D2_TES, SD2.D2_ICMSRET, SD2.D2_TOTAL,
			       SFT.FT_CLASFIS, SFT.FT_VALCONT
			FROM %table:SD2% SD2
			JOIN %table:SFT% SFT ON SFT.FT_FILIAL = %xFilial:SFT% AND
									SFT.FT_NFISCAL = SD2.D2_DOC AND
									SFT.FT_SERIE = SD2.D2_SERIE AND
									SFT.FT_CLIEFOR = SD2.D2_CLIENTE AND
									SFT.FT_LOJA = SD2.D2_LOJA AND
									SFT.FT_CFOP = SD2.D2_CF AND
									SFT.FT_ITEM = SD2.D2_ITEM AND
									SFT.%NotDel%
			WHERE SD2.D2_FILIAL = %xFilial:SD2% AND
				SD2.D2_EMISSAO >= %Exp:dDtIni% AND
				SD2.D2_EMISSAO <= %Exp:dDtFim% AND
				(SUBSTRING(SD2.D2_CF,1,1) = '5') AND
				SD2.%NotDel%
			ORDER BY 1,2
		EndSql
		dbSelectArea(cAlias)
	Else
#ENDIF
cIndex  := CriaTrab(NIL,.F.)
cFiltro := "D2_FILIAL == '" + xFilial("SD2") + "' .AND. "
cFiltro += "dtos(D2_EMISSAO) >= '"+dtos(dDtIni)+"' .AND. "
cFiltro += "dtos(D2_EMISSAO) <= '"+dtos(dDtFim)+"' .AND. "
cFiltro += "(SUBSTRING(D2_CF,1,1) == '5'"

IndRegua(cAlias, cIndex, (cAlias)->(IndexKey()),, cFiltro)
nIndex := RetIndex(cAlias)
#IFNDEF TOP
	DbSetIndex(cIndex+OrdBagExt())
#ENDIF
DbSelectArea(cAlias)
DbSetOrder(nIndex)
#IFDEF TOP
	Endif
#ENDIF

DbSelectArea(cAlias)
(cAlias)->(DbGoTop())
ProcRegua((cAlias)->(RecCount()))
While !(cAlias)->(Eof())
	// Natureza: 2 = Saída
	// Tipo:     1 = Interna
	// Buscando Cliente do documento
	If !(Alltrim((cAlias)->D2_CF) $ "5929/6929/") //Não gerar para nota fiscal emitida sobre cupom fiscal

		cCodMun := ""
		If (cAlias)->D2_TIPO$'D'
			SA2->(dbSetOrder(1))
			SA2->(msSeek(cFilSA2+(cAlias)->D2_CLIENTE+(cAlias)->D2_LOJA))
			cCNPJ := SA2->A2_CGC
			cUF   := SA2->A2_EST
			If nMVA2DIEF <> 0
				cCodMun := Str(Val(SA2->(FieldGet(nMVA2DIEF))),6)
			EndIf
		ElseIf !(cAlias)->D2_TIPO$'BD'
			SA1->(dbSetOrder(1))
			SA1->(msSeek(cFilSA1+(cAlias)->D2_CLIENTE+(cAlias)->D2_LOJA))
			cCNPJ := SA1->A1_CGC
			cUF   := SA1->A1_EST
			If nMVA1DIEF <> 0
				cCodMun := Str(Val(SA1->(FieldGet(nMVA1DIEF))),6)
			Endif
		Else
			SA2->(dbSetOrder(1))
			SA2->(msSeek(cFilSA2+(cAlias)->D2_CLIENTE+(cAlias)->D2_LOJA))
			cCNPJ := SA2->A2_CGC
			cUF   := SA2->A2_EST
			cCodMun := ""
		EndIf
		cNatureza := "2"
		cTipo := "1"
		cOperacao := ""
		If SubStr((cAlias)->FT_CLASFIS,2,2) == "10" .And. (cAlias)->D2_ICMSRET > 0
			cOperacao := "1"
		ElseIf SubStr((cAlias)->FT_CLASFIS,2,2) == "60"
			cOperacao := "2"
		Else
			If (Alltrim((cAlias)->D2_CF) $ "5151/5152/5153/5155/5156/5408/5409/5552/5557/5601/5602/5605/5658/5659/")
				cOperacao := "3"
			Else
				SB1->(dbSetOrder(1))
				If SB1->(msSeek(cFilSB1+(cAlias)->D2_COD)) .And. SB1->B1_PICMRET<>0
					cOperacao := "4"
				EndIf
			EndIf
		Endif

		If !Empty(cOperacao)
			TST->(dbSetOrder(1))
			If !TST->(dbSeek(cNatureza+cTipo+cOperacao+cCNPJ))
				RecLock("TST",.T.)
				TST->NATOPER	:= cNatureza
				TST->TIPO		:= cTipo
				TST->CNPJ       := cCNPJ
				TST->UF     	:= cUF
				TST->VALCONT	:= (cAlias)->FT_VALCONT
				If cOperacao == "1"
					TST->ICMSRET := (cAlias)->D2_ICMSRET
				Else
					TST->ICMSRET := 0
				EndIf
				TST->CODMUN     := cCodMun
				TST->OPERACAO   := cOperacao
			Else
				RecLock("TST",.F.)
				TST->ICMSRET	+= (cAlias)->D2_ICMSRET
				TST->VALCONT	+= (cAlias)->FT_VALCONT
			Endif
			MsUnlock()
		EndIf
	EndIf
	(cAlias)->(DbSkip())
EndDo
DbSelectArea(cAlias)
(cAlias)->(DbCloseArea())

Return(aTrbs)

//-------------------------------------------------------------------
/*/{Protheus.doc} AnexoIIComb
ANEXO II - SUBSTITUIÇÃO TRIBUTÁRIA  - Registro Tipo 88
Subtipo de Registro 26#27#28#29#30

@author Simone Oliveira
@since 21/01/2016
@version 11.80

/*/
//-------------------------------------------------------------------
function AnexoIIComb(dDtIni,dDtFim,lGeraComb)

Local aTrbs     := {}
Local aTpCombus := {}
Local lPCLLOJA  := findfunction("T_PCLRgDIEF") .And. AliasIndic("LF1") .And. AliasIndic("LEI")

//Criação das tabelas temporárias
aTrbs := CriaTabTemp()

//Estes registros serão gerados apenas de houver o template de Combustiveis utilizado pelo Loja
if lPCLLOJA .And. lGeraComb

	aTpCombus:= T_PCLRgDIEF(dDtIni,dDtFim)

	if len(aTpCombus) > 0

		// ANEXO II - SUBSTITUIÇÃO TRIBUTÁRIA - Combustível ( Movimentação )
		if len(aTpCombus[1]) > 0
			CombusMov(aTpCombus[1])
		endif

		// ANEXO II - SUBSTITUIÇÃO TRIBUTÁRIA - Combustível ( Estoque )
		if len(aTpCombus[2]) > 0
			CombusEstoq(aTpCombus[2])
		endif

		// ANEXO II - SUBSTITUIÇÃO TRIBUTÁRIA - Combustível ( Entradas )
		if len(aTpCombus[3]) > 0
			CombusEntr(aTpCombus[3])
		endif

		// ANEXO II - SUBSTITUIÇÃO TRIBUTÁRIA - Combustível ( Saídas )
		if len(aTpCombus[4]) > 0
			CombusSai(aTpCombus[4])
		endif

		// ANEXO II - SUBSTITUIÇÃO TRIBUTÁRIA - Combustível ( Tanques )
		if len(aTpCombus[5]) > 0
			CombusTanque(aTpCombus[5])
		endif

	endif

endif

Return aTrbs

//-------------------------------------------------------------------
/*/{Protheus.doc} CriaTabTemp
Criação das tabelas temporárias referente aos registros do
ANEXO II - SUBSTITUIÇÃO TRIBUTÁRIA - Combustível (Movimentação)

@author Simone Oliveira
@since 22/01/2016
@version 11.80

/*/
//-------------------------------------------------------------------
static function CriaTabTemp()

local aStruct  := {}
local aStruct1 := {}
local aStruct2 := {}
local aStruct3 := {}
local aStruct4 := {}

local aTrbs    := {}
local aTrbs1   := {}
local aTrbs2   := {}
local aTrbs3   := {}
local aTrbs4   := {}

	//Movimentações

	aadd(aStruct,{"SERBOMBA"	,"C",020,0})
	aadd(aStruct,{"NBICO"	,"C",002,0})
	aadd(aStruct,{"TPCOMBUS"	,"C",002,0})
	aadd(aStruct,{"ENCFINAL"	,"N",010,0})
	aadd(aStruct,{"ENCINICI"	,"N",010,0})
	aadd(aStruct,{"VLSEMINT"	,"N",008,0})
	aadd(aStruct,{"VLCOMINT"	,"N",008,0})

	cArqTRB	:=	CriaTrab(aStruct)
	dbUseArea(.T.,__LocalDriver,cArqTRB,"TSU")

	cArqTRB1 := CriaTrab(Nil,.F.)
	IndRegua ("TSU",cArqTRB1,"SERBOMBA+NBICO+TPCOMBUS")
	dbClearIndex()

	aTrbs := {cArqTRB,"TSU"}

	dbSelectArea("TSU")
	dbSetIndex(cArqTRB1+OrdBagExt())
	TSU->(dbSetOrder(1))

	//Estoque

	aadd(aStruct1,{"TANQUE"		,"C",020,0})
	aadd(aStruct1,{"TPCOMBUS"	,"C",002,0})
	aadd(aStruct1,{"QTDINI"		,"N",008,0})
	aadd(aStruct1,{"QTDFIM"		,"N",008,0})

	cArqTRB	:=	CriaTrab(aStruct1)
	dbUseArea(.T.,__LocalDriver,cArqTRB,"TSV")

	cArqTRB1 := CriaTrab(Nil,.F.)
	IndRegua ("TSV",cArqTRB1,"TANQUE+TPCOMBUS")
	dbClearIndex()

	aTrbs1 := {cArqTRB,"TSV"}

	dbSelectArea("TSV")
	dbSetIndex(cArqTRB1+OrdBagExt())
	TSV->(dbSetOrder(1))

	//Entrada

	aadd(aStruct2,{"CNPJ"		,"C",014,0})
	aadd(aStruct2,{"TPCOMBUS"	,"C",002,0})
	aadd(aStruct2,{"NUMNF"		,"C",007,0})
	aadd(aStruct2,{"DTNF"		,"C",008,0})
	aadd(aStruct2,{"TANQUEDS"	,"C",002,0})
	aadd(aStruct2,{"QTDLITRO"	,"N",008,0})
	aadd(aStruct2,{"VLRLITRO"	,"N",014,2})
	aadd(aStruct2,{"VLRNF"		,"N",014,2})

	cArqTRB	:=	CriaTrab(aStruct2)
	dbUseArea(.T.,__LocalDriver,cArqTRB,"TSX")

	cArqTRB1 := CriaTrab(Nil,.F.)
	IndRegua ("TSX",cArqTRB1,"CNPJ+NUMNF+TPCOMBUS+DTNF")
	dbClearIndex()

	aTrbs2 := {cArqTRB,"TSX"}

	dbSelectArea("TSX")
	dbSetIndex(cArqTRB1+OrdBagExt())
	TSX->(dbSetOrder(1))

	//Saída

	aadd(aStruct3,{"TPCOMBUS"	,"C",002,0})
	aadd(aStruct3,{"VLRCONT"	,"N",014,2})
	aadd(aStruct3,{"QTDTOTAL"	,"N",002,0})

	cArqTRB	:=	CriaTrab(aStruct3)
	dbUseArea(.T.,__LocalDriver,cArqTRB,"TSY")

	cArqTRB1 := CriaTrab(Nil,.F.)
	IndRegua ("TSY",cArqTRB1,"TPCOMBUS")
	dbClearIndex()

	aTrbs3 := {cArqTRB,"TSY"}

	dbSelectArea("TSY")
	dbSetIndex(cArqTRB1+OrdBagExt())
	TSY->(dbSetOrder(1))

	//Tanques

	aadd(aStruct4,{"TANQUES"	,"N",002,0})
	aadd(aStruct4,{"CAPNOM"		,"N",008,0})
	aadd(aStruct4,{"NBICOINI"	,"N",002,0})
	aadd(aStruct4,{"NBICOFIM"	,"N",002,0})

	cArqTRB	:=	CriaTrab(aStruct4)
	dbUseArea(.T.,__LocalDriver,cArqTRB,"TSZ")

	cArqTRB1 := CriaTrab(Nil,.F.)
	IndRegua ("TSZ",cArqTRB1,"TANQUES")
	dbClearIndex()

	aTrbs4 := {cArqTRB,"TSZ"}

	dbSelectArea("TSZ")
	dbSetIndex(cArqTRB1+OrdBagExt())
	TSZ->(dbSetOrder(1))

Return{aTrbs,aTrbs1,aTrbs2,aTrbs3,aTrbs4}

//-------------------------------------------------------------------
/*/{Protheus.doc} CombusMov
ANEXO II - SUBSTITUIÇÃO TRIBUTÁRIA - Combustível (Movimentação)

@author Simone Oliveira
@since 21/01/2016
@version 11.80

/*/
//-------------------------------------------------------------------
static function CombusMov(aRegMov)

local aStruct	:= {}
local cSerBomba	:= ""
local cBico		:= ""
local cTpCombus	:= ""
local nA		:= 0
local nEncInici	:= 0
local nEncFinal	:= 0
local nVlSemInt	:= 0
local nVlComInt	:= 0

default aRegMov	:= {}


    //Alimento a tabela temporária 
   	for nA:= 1 to len(aRegMov)
    		
    	cSerBomba	:= 	alltrim(aRegMov[nA,1])			//Série da Bomba
    	cBico		:=	Right(alltrim(aRegMov[nA,2]),2)	//Bico do Abastecimento
    	cTpCombus	:= 	alltrim(aRegMov[nA,3])			//Tipo de Combustivel
    	nEncInici	:=	Right(Str(aRegMov[nA,4]),10)	//Leitura Encerrantes Final
    	nEncFinal	:=	Right(Str(aRegMov[nA,5]),10)	//Leitura Encerrantes Final
    	nVlSemInt	:= 	Right(Str(aRegMov[nA,6]),8)		//Volume Comercializado Sem Intervenção
    	nVlComInt	:= 	Right(Str(aRegMov[nA,7]),8)		//Volume Comercializado Com Intervenção
    		
    	if ! TSU->(dbSeek(cSerBomba+cBico+cTpCombus))
    	
    		RecLock("TSU",.T.)
    		
				TSU->SERBOMBA	:= cSerBomba
				TSU->NBICO		:= cBico
				TSU->TPCOMBUS	:= cTpCombus
				TSU->ENCFINAL	:= Val( nEncFinal )
				TSU->ENCINICI	:= Val( nEncInici )
				TSU->VLSEMINT	:= Val( nVlSemInt )
				TSU->VLCOMINT	:= Val( nVlComInt ) 
				
			MsUnlock()  
			
    	endif
    next
    
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CombusEstoq
ANEXO II - SUBSTITUIÇÃO TRIBUTÁRIA - Combustível (estoque)


@author Simone Oliveira
@since 21/01/2016
@version 11.80

/*/
//-------------------------------------------------------------------
Static Function CombusEstoq(aRegEstoq)

local aStruct	:=	{}
local cTpCombus	:= ""
local cTanque	:= ""
local nA		:= 0
local nQtdeIni	:= 0
local nQtdeFim	:= 0

default aRegEstoq	:= {}

	   
    //Alimento a tabela temporária 
   	for nA:= 1 to len(aRegEstoq)
    		
    	cTanque	:= 	aRegEstoq[nA,1]								//Tanque
    	cTpCombus	:= 	alltrim(aRegEstoq[nA,2])						//Tipo de Combustivel
    	nQtdeIni	:=	Right(Str(aRegEstoq[nA,3]),8) 				//QTD Inicial
    	nQtdeFim	:=	Right(Str(aRegEstoq[nA,4]),8)				//QTD Final
    	   		    		
    		
    	if ! TSV->(dbSeek(cTanque+cTpCombus))
    	
    		RecLock("TSV",.T.)
				TSV->TANQUE	:= cTanque
				TSV->TPCOMBUS	:= cTpCombus
				TSV->QTDINI	:= Val( nQtdeIni )
				TSV->QTDFIM	:= Val( nQtdeFim )
			MsUnlock()  
			
    	endif
    next
    
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CombusEntr
ANEXO II - SUBSTITUIÇÃO TRIBUTÁRIA - Combustível (entradas)

@author Simone Oliveira
@since 21/01/2016
@version 11.80

/*/
//-------------------------------------------------------------------
Static Function CombusEntr(aRegEntr)

local aStruct	:= {}
local cTpCombus	:= ""
local cCnpj		:= ""
local cDtNF		:= ""
local cTanqDes	:= ""
local nA		:= 0
local nQtdeLtr	:= 0
local nPrcLtr	:= 0
local nVlrNF	:= 0

default aRegEntr	:= {}

	   
    //Alimento a tabela temporária 
   	for nA:= 1 to len(aRegEntr)
    		
    	cCnpj		:= 	alltrim(aRegEntr[nA,8])				//CNPJ Remetente
    	cTpCombus	:= 	alltrim(aRegEntr[nA,1])				//Tipo de Combustivel
    	cNumNf		:=	Right(alltrim(aRegEntr[nA,2]),7)	//Nº Nota Fiscal
    	cDtNF		:=	DtoS(aRegEntr[nA,3])  				//Data Nota Fiscal #DDMMAAAA
    	cTanqDes	:=	Right(Alltrim(aRegEntr[nA,4]),2)	//Tanque Descarga
    	nQtdeLtr	:=	Right(Str(aRegEntr[nA,5]),8)		//Quantidade Litros
    	nPrcLtr	:=	aRegEntr[nA,6]						//Preço Litro
    	nVlrNF		:=	aRegEntr[nA,7]						//Valor Nota Fiscal
    	
    	cDtNF		:= substr(cDtNF,7,2) + substr(cDtNF,5,2) + substr(cDtNF,1,4)
    		
    	if ! TSX->(dbSeek(cCnpj+cNumNf+cTpCombus))
    	
    		RecLock("TSX",.T.)
				TSX->CNPJ		:= cCnpj
				TSX->TPCOMBUS	:= cTpCombus
				TSX->NUMNF		:= cNumNf
				TSX->DTNF		:= cDtNF
				TSX->TANQUEDS	:= cTanqDes
				TSX->QTDLITRO	:= Val( nQtdeLtr )
				TSX->VLRLITRO	:= nPrcLtr
				TSX->VLRNF		:= nVlrNF
			MsUnlock()  
			
    	endif
    next
    
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CombusSai
ANEXO II - SUBSTITUIÇÃO TRIBUTÁRIA - Combustível (saídas)

@author Simone Oliveira
@since 21/01/2016
@version 11.80

/*/
//-------------------------------------------------------------------
Static Function CombusSai(aRegSaida)

local aStruct	:= {}
local cTpCombus	:= ""
local nA		:= 0
local nQtdeLtr	:= 0
local nPrcLtr	:= 0
local nVlrNF	:= 0

default aRegSaida	:= {}

	    
    //Alimento a tabela temporária 
   	for nA:= 1 to len(aRegSaida)
    		
    	cTpCombus	:= 	alltrim(aRegSaida[nA,1])				//Tipo de Combustivel
    	nVlrCont	:=	aRegSaida[nA,2]						//Valor Contábil
    	nQtdeTot	:=	Right(Str(aRegSaida[nA,3]),2)		//Quantidade Total
    	   		
    	if ! TSY->(dbSeek(cTpCombus))
    	
    		RecLock("TSY",.T.)
				TSY->TPCOMBUS		:= cTpCombus
				TSY->VLRCONT		:= nVlrCont
				TSY->QTDTOTAL		:= Val( nQtdeTot )
			MsUnlock()  
			
    	endif
    next
    
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CombusTanque
ANEXO II - SUBSTITUIÇÃO TRIBUTÁRIA - Combustível (tanques)

@author Simone Oliveira
@since 21/01/2016
@version 11.80

/*/
//-------------------------------------------------------------------
Static Function CombusTanque(aRegTanque)

local aStruct	:= {}
local nA		:= 0
local nTanque	:= 0
local nCapNom	:= 0
local nBicoIni	:= 0
local nBicoFim	:= 0

default aRegTanque	:= {}
	   
    //Alimento a tabela temporária 
   	for nA:= 1 to len(aRegTanque)
    		
    	nTanque	:=	Right( Alltrim(aRegTanque[nA,1]),2)		//Tanques
    	nCapNom	:=	Right(Str(aRegTanque[nA,2]),8)				//Capacidade Nominal
    	nBicoIni	:=	aRegTanque[nA,3]								//Bicos Início
    	nBicoFim	:=	aRegTanque[nA,4]								//Bicos Final
    	   		
    	if ! TSZ->(dbSeek(nTanque))
    	
    		RecLock("TSZ",.T.)
				TSZ->TANQUES		:= Val( nTanque )
				TSZ->CAPNOM		:= Val( nCapNom )
				TSZ->NBICOINI		:= nBicoIni
				TSZ->NBICOFIM		:= nBicoFim
			MsUnlock()  
			
    	endif
    next
    
return
       
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao   ³DiefDelArq ºAutor  ³ Mary C. Hergert    º Data ³ 18/08/2004  º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.    ³Apaga arquivos temporarios criados para gerar o arquivo      º±±
±±º         ³Magnetico                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³DIEFPA                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function DiefDelArq(aDelArqs)

Local aAreaDel := GetArea()
Local nI := 0

For nI:= 1 To Len(aDelArqs)
	If File(aDelArqs[ni,1]+".DBF")
		dbSelectArea(aDelArqs[ni,2])
		dbCloseArea()
		Ferase(aDelArqs[ni,1]+".DBF")
		Ferase(aDelArqs[ni,1]+OrdBagExt())
	Endif
Next

RestArea(aAreaDel)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao   ³DiefUlt    ºAutor  ³ Natalia Antoucci   º Data ³ 17/03/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.    ³  Grava apenas a ultima data de reducao Z                    º±±
±±º         ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³DIEFPA                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function DiefUlt()
Local aArea    := GetArea()
Local aServPdv := {}
Local aTrbs    := {}
Local nS       := 0
Local n        := 0
Local nX       := 0
Local aData    := {}
Local aCampos  := {}
Local dMovto   := MV_PAR02

DbSelectArea("SLG")
DbSetOrder(1)
DbGotop()
If DbSeek(cFilAnt )
	While SLG->(!Eof()) .And. SLG->LG_FILIAL == cFilAnt
		If aScan(aServPdv,{|x| x == SLG->LG_SERPDV } ) == 0 .And.  !Empty(AllTrim(SLG->LG_SERPDV)) 
			AADD(aServPdv,SLG->LG_SERPDV)
		EndIf	
		DbSkip()
	End
EndIf 
nS := Len(aServPdv)
aData := Array(nS) 
If Select("TRZ")<> 0
	("TRZ")->(dbCloseArea())
EndIf

AADD(aCampos,{ "SERPDV"		,"C",TamSx3("FI_SERPDV")[1]  ,0 } )
AADD(aCampos,{ "PDV"		,"C",TamSx3("FI_PDV")[1]     ,0 } )
AADD(aCampos,{ "NUMREDZ"	,"C",TamSX3("FI_NUMREDZ")[1] ,0 } )
AADD(aCampos,{ "COO"		,"C",TamSX3("FI_COO")[1]     ,0 } )
AADD(aCampos,{ "CRO"		,"C",TamSX3("FI_CRO")[1]     ,0 } )
AADD(aCampos,{ "GTFINAL"	,"N",TamSX3("FI_GTFINAL")[1] ,TamSX3("FI_GTFINAL")[2]  } )   
cArqTrab1 := CriaTrab(aCampos)
aTrbs := {{cArqTrab1,"TRZ"}}
USE &cArqTrab1 ALIAS TRZ NEW 
IndRegua("TRZ",cArqTrab1,"COO",,,,,)	

nDia := Day(MV_PAR01)

For nX := Day(MV_PAR02) to nDia STEP -1
	DbSelectArea("SFI")
	DbSetOrder(1)  
	If DbSeek(xFilial("SFI") + Dtos(dMovto),.T. )
		For n:= 1 to nS
			While nS >= n .And. SFI->FI_DTMOVTO >= MV_PAR01 
		   		If aServPdv[n]== SFI->FI_SERPDV  .And. SFI->FI_DTMOVTO <= MV_PAR02 
		   		  If ValType(aData[n]) == "U"
		   		  	aData[n]:= SFI->FI_DTMOVTO 
		   		  	RecLock("TRZ",.T.)
		   		  	TRZ->SERPDV		:= SFI->FI_SERPDV
					TRZ->PDV   		:= SFI->FI_PDV
					TRZ->NUMREDZ    := SFI->FI_NUMREDZ
					TRZ->COO        := SFI->FI_COO
					TRZ->CRO		:= SFI->FI_CRO
					TRZ->GTFINAL    := SFI->FI_GTFINAL
					MsUnlock()
		   		  	exit 
		   		  EndIf
		   		EndIf  
		   		SFI->(DbSkip(-1))
			EndDo
			nX := nDia
		Next n
		
	Else
		dMovto := DaySub(dMovto, 1)
	EndIf
Next nX
RestArea(aArea)
Return (aTrbs)

//-------------------------------------------------------------------
/*/{Protheus.doc} DebDifal
Retorna o valor do Débito referente ao Difal de PA 

@author Simone Oliveira
@since 13/04/2016
@version 11.80

/*/
//-------------------------------------------------------------------
function DebDifal(dDtPer, cUF, cLivro)

local nVal		:= 0

default cUF		:= ''
default cLivro	:= ''
default dDtPer	:= ctod(" / / ")

//Verifica se a tabela referente à Apuração de Difal existe - F0I
if AliasIndic("F0I")

	dbselectarea('F0I')
	F0I->(dbSetOrder(1))

	if F0I->(dbSeek(xFilial("F0I")+ dtos(dDtPer)+ cUF+ cLivro))

		nVal := F0I->F0I_DIFREC

	endif
	F0I->(dbCloseArea())
endif

return nVal

