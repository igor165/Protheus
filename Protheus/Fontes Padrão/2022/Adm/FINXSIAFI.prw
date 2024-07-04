#Include "Protheus.ch"
#Include "FINXSIAFI.ch"
#INCLUDE "FWMVCDEF.CH"

#Define TIPO_CHAR "1"
#Define TIPO_NUM "2"
#Define TIPO_BOOL	"3"
#DEFINE TIPO_DATA	"4"

Static __cSecAnt := ""
Static __cSituac := ""
Static __cTipoDc := ""
Static __lUsaDH	 := NIL

/*/{Protheus.doc} LoadSIAFI
Função para popular as tabelas referentes às 
situações do documento hábil (SIAFI)

@author Pedro Alencar
@since 23/10/2014
@version P12.1.3
/*/
Function LoadSIAFI()
	//Popula a tabela de Situações
	If ChkFile("FVJ")
		//Verifica se já há valor na FVJ
		FVJ->( dbSetOrder( 1 ) ) 
		If FVJ->( !MsSeek( FWxFilial("FVJ") ) )
			LoadFVJ()
		Endif
	EndIf
	
	//Popula a tabela de Tipo de Documento X Seção
	If ChkFile("FVH")
		//Verifica se já há valor na FVH
		FVH->( dbSetOrder( 1 ) ) 
		If FVH->( !MsSeek( FWxFilial("FVH") ) )
			LoadFVH()
		Endif
	EndIf
	
	//Popula a tabela de Seção X Situação
	If ChkFile("FVK")
		//Verifica se já há valor na FVK
		FVK->( dbSetOrder( 1 ) ) 
		If FVK->( !MsSeek( FWxFilial("FVK") ) )
			LoadFVK()
		Endif
	EndIf
	
	//Popula a tabela de campos da associação Tipo Doc. X Seção X Situação X Campos
	If ChkFile("FV4")
		//Verifica se já há valor na FV4
		FV4->( dbSetOrder( 1 ) ) 
		If FV4->( !MsSeek( FWxFilial("FV4") ) )
			LoadFV4()
		Endif
	EndIf
Return Nil

/*/{Protheus.doc} LoadFVJ
Função para popular a tabela de Situações, 
referente as situações do documento hábil (SIAFI)

@author Pedro Alencar
@since 23/10/2014
@version P12.1.2
/*/
Static Function LoadFVJ()
	Local cChave := ""
	Local nI := 0
	Local aAreaTab := {}
	Local aValores := {}
	Local cFilTab := ""
	Local cAliastab := "FVJ" 
	Local nTamSit := TamSX3("FVJ_ID")[1]
	
	//Tipos de Pré-Doc: 1=OB; 2=NS; 3=GRU; 4=GPS; 6=DAR; 7=DARF
	//Tipos de Situação: 1=DH; 2=PF
	//Estrutura:    {  Código ,       Descrição   ,Pré-Doc, Tipo Situac  } 	
	AAdd( aValores, { "AFL001", OemToAnsi(STR0030), "" , "1" } ) //"ANULAÇÃO DE DESPESA DE PESSOAL"
	AAdd( aValores, { "AFL002", OemToAnsi(STR0031), "" , "1" } ) //"ANULAÇÃO DE DESPEadminSA DE PESSOAL - ADIANTAMENTO DE 13 SALÁRIO"
	AAdd( aValores, { "AFL003", OemToAnsi(STR0032), "" , "1" } ) //"ANULAÇÃO DE DESPESA DE PESSOAL - ADIANTAMENTO DE 1/3 DE FERIAS"
	AAdd( aValores, { "AFL004", OemToAnsi(STR0033), "" , "1" } ) //"ANULAÇÃO DE DESPESA DE PESSOAL - ADIANTAMENTO DE SALARIO"
	AAdd( aValores, { "CRA001", OemToAnsi(STR0133), "" , "1" } ) //"CLASSIFICAÇÃO DE RECEITA ARRECADADA POR GRU - DEPÓSITO DE TERCEIROS" 
	AAdd( aValores, { "CRA002", OemToAnsi(STR0134), "" , "1" } ) //"REGISTRO DE DESPESAS BANCÁRIAS POR RECEBIMENTO DE GRU - CÓDIGO 98815-4" 
	AAdd( aValores, { "CRA003", OemToAnsi(STR0135), "" , "1" } ) //"REGISTRO DE DESPESAS COM IOF POR RECEBIMENTO DE GRU - CÓDIGO 98815-4" 
	AAdd( aValores, { "CRD016", OemToAnsi(STR0136), "" , "1" } ) //"REALIZAÇÃO DE DESPESA ANTECIPADA DE SERVIÇOS POR COMPETÊNCIA (C/C 002)" 
	AAdd( aValores, { "CRD018", OemToAnsi(STR0137), "" , "1" } ) //"ATUALIZAÇÃO MON. E APROP. DE JUROS S/ CRÉDITOS POR DANOS AO PATRIMÔNIO C/C004" 
	AAdd( aValores, { "CRD020", OemToAnsi(STR0138), "" , "1" } ) //"TRANSFERÊNCIA CURTO P/ LONGO PRAZO DE EMPRÉSTIMOS E FINANCIAMENTOS CONCEDIDOS" 
	AAdd( aValores, { "CRD021", OemToAnsi(STR0139), "" , "1" } ) //"TRANSFERÊNCIA LONGO P/ CURTO PRAZO DE EMPRÉSTIMOS E FINANCIAMENTOS CONCEDIDOS" 
	AAdd( aValores, { "CRD045", OemToAnsi(STR0140), "" , "1" } ) //"AJUSTES FINANCEIROS DE LONGO PRAZO DE EMPRÉSTIMOS CONCEDIDOS - NEGATIVO" 
	AAdd( aValores, { "CRD049", OemToAnsi(STR0141), "" , "1" } ) //"AJUSTES FINANCEIROS DE LONGO PRAZO DE EMPRÉSTIMOS CONCEDIDOS - POSITIVO." 
	AAdd( aValores, { "CRD107", OemToAnsi(STR0142), "" , "1" } ) //"BAIXA DO ADIANTAMENTO CONCEDIDO POR SUPRIMENTO DE FUNDOS DE EXECÍCIOS ANTERIORES" 
	AAdd( aValores, { "CRD121", OemToAnsi(STR0143), "" , "1" } ) //"APROPRIAÇÃO DE CRÉDITOS DESPESAS ANTECIPADAS RECLASSIFICADAS" 
	AAdd( aValores, { "DDF001", OemToAnsi(STR0001), "7", "1" } ) //"RETENÇÃO DE IMPOSTOS SOBRE CONTRIBUIÇÕES DIVERSAS- IN 1234 SRF, DE 11/1/12"
	AAdd( aValores, { "DDF002", OemToAnsi(STR0002), "7", "1" } ) //"IMPOSTO DE RENDA RETIDO NA FONTE - IRRF"	
	AAdd( aValores, { "DDF010", OemToAnsi(STR0035), "7", "1" } ) //"PLANO DE SEGURIDADE SOCIAL DO SERVIDOR"
	AAdd( aValores, { "DDR001", OemToAnsi(STR0003), "6", "1" } ) //"RETENÇÕES DE IMPOSTOS RECOLHÍVEIS POR DAR"
	AAdd( aValores, { "DFE001", OemToAnsi(STR0144), "" , "1" } ) //"ESTORNO - DESPESA COM REMUNERACAO A PESSOAL ATIVO CIVIL - RPPS" 
	AAdd( aValores, { "DFL001", OemToAnsi(STR0004), "1", "1" } ) //"DESPESA COM PESSOAL" 
	AAdd( aValores, { "DFL002", OemToAnsi(STR0037), "" , "1" } ) //"DESPESA COM PESSOAL - ADIANTAMENTOS DE 13º SALARIO" 
	AAdd( aValores, { "DFL003", OemToAnsi(STR0005), "1", "1" } ) //"DESPESA COM PESSOAL - ADIANTAMENTOS DE 1/3 DE FERIAS" 
	AAdd( aValores, { "DFL004", OemToAnsi(STR0006), "" , "1" } ) //"DESPESA COM PESSOAL - ADIANTAMENTOS DE SALÁRIO" 
	AAdd( aValores, { "DFL011", OemToAnsi(STR0145), "1", "1" } ) //"DESPESA COM REMUNERAÇÃO A PESSOAL ATIVO CIVIL - RGPS" 
	AAdd( aValores, { "DFL013", OemToAnsi(STR0146), "1", "1" } ) //"DESPESA COM BENEFÍCIOS A PESSOAL - CIVIL RGPS" 
	AAdd( aValores, { "DFL034", OemToAnsi(STR0147), "1", "1" } ) //"DESPESA COM INDENIZAÇÕES E RESTITUIÇÕES TRABALHISTAS" 
	AAdd( aValores, { "DFL035", OemToAnsi(STR0148), "1", "1" } ) //"RESSARCIMENTO DE DESPESAS DE PESSOAL REQUISITADO DE OUTROS ÓRGÃOS OU ENTES" 
	AAdd( aValores, { "DFL045", OemToAnsi(STR0149), "1", "1" } ) //"DESPESA COM OUTROS SERVIÇOS DE TERCEIROS - PESSOA FÍSICA" 
	AAdd( aValores, { "DFN001", OemToAnsi(STR0150), "" , "1" } ) //"NORMAL - DESPESA COM REMUNERACAO A PESSOAL ATIVO CIVIL - RPPS" 
	AAdd( aValores, { "DGP001", OemToAnsi(STR0129), "4", "1" } ) //"APROPRIAÇÃO DAS RETNÇÕES RELACIONADAS AO INSS"
	AAdd( aValores, { "DGP001", OemToAnsi(STR0010), "4", "1" } ) //"RETENÇÃO DE INSS"
	AAdd( aValores, { "DGR002", OemToAnsi(STR0151), "3", "1" } ) //"RETENÇÃO PARA RESSARCIMENTO DE PESSOAL REQUISITADO" 
	AAdd( aValores, { "DGR005", OemToAnsi(STR0152), "3", "1" } ) //"RETENÇÃO DE INDENIZAÇÕES E RESTITUIÇÕES" 
	AAdd( aValores, { "DGR009", OemToAnsi(STR0038), "3", "1" } ) //"APROPRIAÇÃO DE CONSIGNAÇÕES LINHA DE CONTRACHEQUE"
	AAdd( aValores, { "DGR010", OemToAnsi(STR0039), "3", "1" } ) //"RETENÇÃO FONTE TESOURO/PROPRIA"
	AAdd( aValores, { "DOB001", OemToAnsi(STR0007), "1", "1" } ) //"RETENCAO DE ISS SOBRE SERVICOS DE TERCEIROS (EXCETO SUPRIMENTO DE FUNDOS)"
	AAdd( aValores, { "DOB005", OemToAnsi(STR0008), "1", "1" } ) //"OUTROS CONSIGNATARIOS - OB RESERVA"
	AAdd( aValores, { "DOB006", OemToAnsi(STR0153), "1", "1" } ) //"RETENÇÃO DE EMPRÉSTIMOS" 
	AAdd( aValores, { "DOB007", OemToAnsi(STR0009), "1", "1" } ) //"DESCONTO DA PENSAO ALIMENTICIA"
	AAdd( aValores, { "DOB008", OemToAnsi(STR0154), "1", "1" } ) //"RETENCAO FOLHA REFERENTE A ENTIDADES REPRESENTATIVAS DE CLASSE"  
	AAdd( aValores, { "DOB009", OemToAnsi(STR0155), "1", "1" } ) //"RETENÇÃO PARA PLANOS DE PREVIDÊNCIA E ASSISTÊNCIA MÉDICA" 
	AAdd( aValores, { "DOB013", OemToAnsi(STR0156), "1", "1" } ) //"RETENÇÃO CONSIGNAÇÃO ASSOCIAÇÕES" 
	AAdd( aValores, { "DOB029", OemToAnsi(STR0157), "1", "1" } ) //"PAGAMENTO DE FATURA - CGPF" 	
	AAdd( aValores, { "DSE005", OemToAnsi(STR0158), "" , "1" } ) //"ESTORNO - TRIBUTÁRIAS COM A UNIÃO, ESTADOS OU MUNICÍPIOS" 
	AAdd( aValores, { "DSF003", OemToAnsi(STR0159), "2", "1" } ) //"DEVOLUÇÃO SAQUE CARTAO PAGAMENTOS P/VAL. A DEBITAR" 
	AAdd( aValores, { "DSF004", OemToAnsi(STR0160), "2", "1" } ) //"DEV.FATURA CARTAO PAGAMENTOS P/VAL. A DEBITAR" 
	AAdd( aValores, { "DSN005", OemToAnsi(STR0161), "" , "1" } ) //"NORMAL - DESPESAS TRIBUTÁRIAS COM A UNIÃO, ESTADOS OU MUNICÍPIOS - RECOLH. OB/GR" 
	AAdd( aValores, { "DSP001", OemToAnsi(STR0011), "3", "1" } ) //"DESPESAS CORRENTES DE SERVIÇOS"
	AAdd( aValores, { "DSP005", OemToAnsi(STR0162), "" , "1" } ) //"DESPESAS TRIBUTÁRIAS COM A UNIÃO, ESTADOS OU MUNICÍPIOS - RECOLH. OB/GRU" 
	AAdd( aValores, { "DSP011", OemToAnsi(STR0012), "3", "1" } ) //"DESPESAS COM BOLSAS DE ESTUDO"
	AAdd( aValores, { "DSP051", OemToAnsi(STR0163), "1", "1" } ) //"AQUISIÇÃO DE SERVIÇOS - PESSOAS FÍSICAS" 
	AAdd( aValores, { "DSP062", OemToAnsi(STR0164), "1", "1" } ) //"DESPESAS COM SERVIÇOS EVENTUAIS DE PESSOAL TÉCNICO" 
	AAdd( aValores, { "DSP081", OemToAnsi(STR0165), "1", "1" } ) //"DESPESAS COM DIÁRIAS" 
	AAdd( aValores, { "DSP100", OemToAnsi(STR0013), "3", "1" } ) //"DESPESAS COM MERCADORIAS PARA DOAÇÃO"
	AAdd( aValores, { "DSP101", OemToAnsi(STR0014), "3", "1" } ) //"DESPESAS COM MATERIAIS PARA ESTOQUE"
	AAdd( aValores, { "DSP102", OemToAnsi(STR0041), "3", "1" } ) //"DESPESAS COM MATERIAIS PARA CONSUMO IMEDIATO"
	AAdd( aValores, { "DSP200", OemToAnsi(STR0042), "3", "1" } ) //"DESPESAS COM INVESTIMENTOS DE BENS IMÓVEIS"
	AAdd( aValores, { "DSP201", OemToAnsi(STR0015), "3", "1" } ) //"DESPESAS COM AQUISIÇÃO DE EQUIPAMENTOS E MATERIAIS PERMANENTES"
	AAdd( aValores, { "DSP206", OemToAnsi(STR0016), "3", "1" } ) //"DESPESAS COM A REALIZAÇÃO DE OBRAS E INSTALAÇÕES"
	AAdd( aValores, { "DSP215", OemToAnsi(STR0017), "3", "1" } ) //"DESPESAS COM AQUISIÇÃO DE BENS INTANGIVEIS FAVORECIDO DA NE"
	AAdd( aValores, { "DSP900", OemToAnsi(STR0018), "3", "1" } ) //"DESPESAS COM INDENIZAÇÕES E RESTITUIÇÕES"
	AAdd( aValores, { "DSP901", OemToAnsi(STR0019), "" , "1" } ) //"DESPESAS CORRENTES COM INDENIZAÇÕES E RESTITUIÇÕES COM AUXÍLIO MORADIA"
	AAdd( aValores, { "DSP902", OemToAnsi(STR0043), "" , "1" } ) //"DESPESAS CORRENTES PARA AUXÍLIO A PESQUISADORES SEM CONTROLE DE RESPONSABILIDADE"
	AAdd( aValores, { "DSP925", OemToAnsi(STR0166), "1", "1" } ) //"DESPESAS COM DEPÓSITOS PARA RECURSOS" 
	AAdd( aValores, { "DSP975", OemToAnsi(STR0167), "" , "1" } ) //"DESPESAS COM JUROS/ENCARGOS DE MORA DE OBRIGACOES TRIBUTARIAS" 
	AAdd( aValores, { "DVL001", OemToAnsi(STR0168), "" , "1" } ) //"DEVOLUÇÃO DE DESPESAS COM CONTRATAÇÃO DE SERVIÇOS - PESSOAS JURÍDICAS" 
	AAdd( aValores, { "DVL081", OemToAnsi(STR0169), "" , "1" } ) //"DEVOLUÇÃO DE DESPESAS COM DIÁRIAS" 
	AAdd( aValores, { "DVL973", OemToAnsi(STR0170), "" , "1" } ) //"DEVOLUÇÃO DE DESPESAS COM JUROS/ENCARGOS DE MORA COM BENS/SERVIÇOS" 
	AAdd( aValores, { "EDS001", OemToAnsi(STR0044), "" , "1" } ) //"ESTORNO/ANULAÇÃO DE DESPESAS CORRENTES COM SERVIÇOS SEM CONTRATO"
	AAdd( aValores, { "EDS011", OemToAnsi(STR0045), "" , "1" } ) //"ESTORNO/ANULAÇÃO DE DESPESAS COM BOLSAS DE ESTUDO"
	AAdd( aValores, { "EDS101", OemToAnsi(STR0046), "" , "1" } ) //"ESTORNO/ANULAÇÃO DE DESPESAS COM AQUISIÇÃO DE MATERIAIS PARA ESTOQUE"
	AAdd( aValores, { "EDS102", OemToAnsi(STR0047), "" , "1" } ) //"ESTORNO/ANULAÇÃO DE DESPESAS COM MATERIAIS PARA CONSUMO IMEDIATO"
	AAdd( aValores, { "EDS200", OemToAnsi(STR0048), "" , "1" } ) //"ESTORNO/ANULAÇÃO DE DESPESAS COM AQUISIÇÃO DE IMÓVEIS"
	AAdd( aValores, { "EDS201", OemToAnsi(STR0049), "" , "1" } ) //"ESTORNO/ANULAÇÃO DE DESPESAS COM EQUIPAMENTOS E MATERIAL PERMANENTE"
	AAdd( aValores, { "EDS206", OemToAnsi(STR0050), "" , "1" } ) //"ESTORNO/ANULAÇÃO DE DESPESAS COM A REALIZAÇÃO DE OBRAS E INSTALAÇÕES"
	AAdd( aValores, { "EDS900", OemToAnsi(STR0051), "" , "1" } ) //"ESTORNO/ANULAÇÃO DE ESPESAS COM INDENIZAÇÕES E RESTITUIÇÕES."
	AAdd( aValores, { "ENC001", OemToAnsi(STR0052), "4", "1" } ) //"ENCARGO PATRONAL - INSS - RECOLHIDO POR MEIO DE GPS"
	AAdd( aValores, { "ENC002", OemToAnsi(STR0171), "4", "1" } ) //"ENCARGOS PATRONAIS - FGTS - RECOLHIMENTO POR GFIP" 
	AAdd( aValores, { "ENC004", OemToAnsi(STR0172), "7", "1" } ) //"ENCARGOS TRIBUTARIOS COM IRPJ - POR DARF" 
	AAdd( aValores, { "ENC005", OemToAnsi(STR0053), "7", "1" } ) //"PIS/PASEP RECOLHIDO POR MEIO DE DARF (EXCETO FOLHA DE PAGAMENTO)"
	AAdd( aValores, { "ENC011", OemToAnsi(STR0054), "7", "1" } ) //"ENCARGOS SOCIAIS RPPS - PSSS PATRONAL"
	AAdd( aValores, { "ENC014", OemToAnsi(STR0173), "1", "1" } ) //"ENCARGOS PATRONAIS COM PREVIDÊNCIA PRIVADA E ASSIST. MÉDICO-ODONTOLÓGICA" 
	AAdd( aValores, { "ENC015", OemToAnsi(STR0055), "1", "1" } ) //"ENCARGOS SOCIAIS - PREVIDÊNCIA REGIME PROPRIO - FUNPRESP"
	AAdd( aValores, { "ENC021", OemToAnsi(STR0174), "" , "1" } ) //"ENCARGOS TRIBUTÁRIOS COM UNIÃO, ESTADOS OU MUNICÍPIOS - RECOLH. OB/GRU" 
	AAdd( aValores, { "ENC022", OemToAnsi(STR0175), "7", "1" } ) //"ENCARGOS TRIBUTÁRIOS COM A UNIÃO - RECOLHIMENTO POR DARF" 
	AAdd( aValores, { "ENC024", OemToAnsi(STR0176), "4", "1" } ) //"ENCARGO PATRONAIS SOBRE SERVIÇOS DE TERCEIROS - INSS" 
	AAdd( aValores, { "ENC028", OemToAnsi(STR0177), "" , "1" } ) //"ENCARGOS COM CONTRIBUIÇÕES SOCIAIS - DOCUMENTOS DE REALIZAÇÃO OB/GRU" 
	AAdd( aValores, { "ETQ001", OemToAnsi(STR0178), "" , "1" } ) //"BAIXA DE ESTOQUES DE ALMOXARIFADO POR CONSUMO/DISTRIBUIÇÃO GRATUITA (C/C 007)" 
	AAdd( aValores, { "ETQ027", OemToAnsi(STR0179), "" , "1" } ) //"TRANSFERÊNCIA DE ESTOQUES COM C/C SUBITEM ENTRE UG OU DENTRO DA MESMA UG" 
	AAdd( aValores, { "IMB070", OemToAnsi(STR0180), "" , "1" } ) //"APROPRIAÇÃO DA DEPRECIAÇÃO DE IMOBILIZADO - BENS MÓVEIS" 
	AAdd( aValores, { "IMB071", OemToAnsi(STR0181), "" , "1" } ) //"APROPRIAÇÃO DA DEPRECIAÇÃO DE IMOBILIZADO - BENS IMÓVEIS" 
	AAdd( aValores, { "INT001", OemToAnsi(STR0182), "" , "1" } ) //"APROPRIAÇÃO DA AMORTIZAÇÃO DOS BENS INTANGÍVEIS - DO EXERCÍCIO" 
	AAdd( aValores, { "LDV011", OemToAnsi(STR0183), "" , "1" } ) //"ASSINATURA DE CONTRATOS DE DESPESA" 
	AAdd( aValores, { "LDV051", OemToAnsi(STR0184), "" , "1" } ) //"APROPRIAÇÃO DE RESPONSABILIDADES COM TERCEIROS" 
	AAdd( aValores, { "LDV052", OemToAnsi(STR0185), "" , "1" } ) //"BAIXA DE RESPONSABILIDADES COM TERCEIROS" 
	AAdd( aValores, { "LDV053", OemToAnsi(STR0186), "" , "1" } ) //"APROPRIAÇÃO DE GARANTIAS/CONTRAGARANTIAS RECEBIDAS" 
	AAdd( aValores, { "LPA301", OemToAnsi(STR0187), "" , "1" } ) //"APROPRIAÇÃO DE PESSOAL E ENCARGOS A PAGAR SEM SUPORTE ORCAMENTÁRIO" 
	AAdd( aValores, { "LPA331", OemToAnsi(STR0188), "" , "1" } ) //"APROPRIAÇÃO DE PASSIVOS CIRCULANTES (ISF P)" 
	AAdd( aValores, { "PRV002", OemToAnsi(STR0057), "" , "1" } ) //"BAIXA DE PROVISÕES E ADIANTAMENTOS DA FOLHA DE PAGAMENTO"
	AAdd( aValores, { "PRV003", OemToAnsi(STR0058), "" , "1" } ) //"BAIXA DE ADIANTAMENTOS DA FOLHA DE PAGAMENTO"	
	AAdd( aValores, { "PRV004", OemToAnsi(STR0059), "" , "1" } ) //"BAIXA DE PROVISÕES PARA 13 SALARIO, FÉRIAS OU LIC. PRÊMIO"
	AAdd( aValores, { "PRV005", OemToAnsi(STR0060), "" , "1" } ) //"BAIXA DE ADIANTAMENTOS DA FOLHA DE PAGAMENTO - EXERCÍCIOS ANTERIORES"
	AAdd( aValores, { "PRV006", OemToAnsi(STR0061), "" , "1" } ) //"BAIXA DE PROVISÕES DA FOLHA DE PAGAMENTO - EXERCÍCIOS ANTERIORES"
	AAdd( aValores, { "PRV007", OemToAnsi(STR0189), "" , "1" } ) //"APROPRIAÇÃO DE PROVISÕES A CURTO PRAZO" 
	AAdd( aValores, { "PRV008", OemToAnsi(STR0190), "" , "1" } ) //"CONSTITUIÇÃO DE PROV.INDENIZ.TRABALHISTAS" 
	AAdd( aValores, { "PSO001", OemToAnsi(STR0062), "3", "1" } ) //"RECOLHIMENTO DE VALORES EM TRÂNSITO PARA ESTORNO DE DESPESA"
	AAdd( aValores, { "PSO002", OemToAnsi(STR0063), "" , "1" } ) //"REGULARIZAÇÃO DE ORDENS BANCÁRIAS CANCELADAS (2.1.2.6.3.00.00)-VALOR DEVIDO(OB)"
	AAdd( aValores, { "PSO006", OemToAnsi(STR0064), "3", "1" } ) //"REGULARIZACAO OB CANCELADA-EMISSÃO GRU - 21.263.00.00 - VALOR NAO DEVIDO"			
	AAdd( aValores, { "PSO023", OemToAnsi(STR0191), "" , "1" } ) //"PAGAMENTO/DEVOLUÇÃO DE DEPÓSITOS DIVERSOS (CONTAS 2.1.8.8.1.XX.XX - C/C FONTE)" 
	AAdd( aValores, { "PSO030", OemToAnsi(STR0192), "1", "1" } ) //"APROPRIAÇÃO DO ISS SOBRE VENDAS BRUTA DE PRODUTOS - REALIZAÇÃO POR OB" 
	AAdd( aValores, { "PSO042", OemToAnsi(STR0193), "" , "1" } ) //"PAGAMENTO DEPÓSITOS DIVERSOS (CONTAS 2.1.8.8.X.XX.XX-C/C FTE+CNPJ,CPF,UG,IG,999)" 
	AAdd( aValores, { "PSO045", OemToAnsi(STR0194), "7", "1" } ) //"APROPRIAÇÃO DE OBRIGAÇÕES COM A UNIÃO A RECOLHER - SEM NE - GERANDO DARF" 
	AAdd( aValores, { "PSO079", OemToAnsi(STR0195), "1", "1" } ) //"RETENCAO EM FOLHA - PLANO DE PREV. E ASSIST MÉD - LIQUIDADAS POR OUTRO DOC S/NE" 
	AAdd( aValores, { "SPE003", OemToAnsi(STR0196), "1", "1" } ) //"ESTORNO - DESPESAS COM SUPRIMENTO DE FUNDOS - EXCETO AS DE CARÁTER SIGILOSO" 
	AAdd( aValores, { "SPF003", OemToAnsi(STR0197), "1", "1" } ) //"SUPRIMENTO DE FUNDOS - CARTÃO DE PAGAMENTO GOVERNO FEDERAL - SAQUE E FATURA" 	
	AAdd( aValores, { "SPN003", OemToAnsi(STR0198), "" , "1" } ) //"NORMAL - DESPESAS CORRENTES COM SUPRIMENTO DE FUNDOS" 
	//Situações de Programação Financeira
	AAdd( aValores, { "EXE001", OemToAnsi(STR0093), "" , "2" } ) //"EXERCÍCIO CORRENTE"	
	AAdd( aValores, { "RAP001", OemToAnsi(STR0094), "" , "2" } ) //"RESTOS A PAGAR"
	
	cFilTab := FWxFilial( cAliasTab )
	aAreaTab := &(cAliasTab)->( GetArea() )
	&(cAliasTab)->( dbSetOrder( 1 ) )
	For nI := 1 To Len( aValores )
		cChave := cFilTab + PadR( aValores[nI][1], nTamSit ) 
		If &(cAliasTab)->( !MsSeek( cChave ) )
			RecLock( cAliasTab, .T. )
			&(cAliasTab)->(FVJ_FILIAL) := cFilTab
			&(cAliasTab)->(FVJ_ID) := aValores[nI][1]
			&(cAliasTab)->(FVJ_DESCRI) := aValores[nI][2]
			&(cAliasTab)->(FVJ_PREDOC) := aValores[nI][3]
			&(cAliasTab)->(FVJ_TIPO) := aValores[nI][4]
			&(cAliasTab)->( MsUnLock() )
		EndIf
	Next nI	
	&(cAliasTab)->( RestArea( aAreaTab ) )
Return Nil

/*/{Protheus.doc} LoadFVH
Função para popular a tabela de Tipo de Documento X Seção, 
referente as situações do documento hábil (SIAFI)

@author Pedro Alencar
@since 23/10/2014
@version P12.1.2
/*/
Static Function LoadFVH()
	Local cChave := ""
	Local nI := 0
	Local aAreaTab := {}
	Local aValores := {}
	Local cFilTab := ""
	Local cAliastab := "FVH"
	Local nTamTpDc := TamSX3("FVH_TIPODC")[1]
	Local nTamSec := TamSX3("FVH_SECAO")[1]
	
	//Estrutura: {Tp. Doc., Seção}
	AAdd( aValores, { "AV", "000001" } ) 
	AAdd( aValores, { "AV", "000002" } ) 
	AAdd( aValores, { "AV", "000003" } ) 
	AAdd( aValores, { "AV", "000006" } ) 
	AAdd( aValores, { "AV", "000007" } ) 
	AAdd( aValores, { "AV", "000010" } ) 
	AAdd( aValores, { "CE", "000001" } ) 
	AAdd( aValores, { "CE", "000003" } ) 
	AAdd( aValores, { "CE", "000006" } ) 
	AAdd( aValores, { "CE", "000007" } ) 
	AAdd( aValores, { "CE", "000010" } ) 
	AAdd( aValores, { "DD", "000001" } ) 
	AAdd( aValores, { "DD", "000002" } ) 
	AAdd( aValores, { "DD", "000010" } ) 
	AAdd( aValores, { "DT", "000001" } )
	AAdd( aValores, { "DT", "000002" } ) 	
	AAdd( aValores, { "DT", "000003" } )
	AAdd( aValores, { "DT", "000005" } )
	AAdd( aValores, { "DT", "000006" } ) 
	AAdd( aValores, { "DT", "000007" } )
	AAdd( aValores, { "DT", "000010" } )
	AAdd( aValores, { "DU", "000001" } ) 
	AAdd( aValores, { "DU", "000002" } ) 
	AAdd( aValores, { "DU", "000010" } ) 
	AAdd( aValores, { "FL", "000001" } )
	AAdd( aValores, { "FL", "000002" } )
	AAdd( aValores, { "FL", "000003" } ) 
	AAdd( aValores, { "FL", "000005" } )
	AAdd( aValores, { "FL", "000006" } )
	AAdd( aValores, { "FL", "000007" } )
	AAdd( aValores, { "FL", "000008" } )
	AAdd( aValores, { "FL", "000010" } )
	AAdd( aValores, { "IT", "000001" } )
	AAdd( aValores, { "IT", "000005" } )
	AAdd( aValores, { "IT", "000010" } )
	AAdd( aValores, { "NP", "000001" } )
	AAdd( aValores, { "NP", "000002" } )
	AAdd( aValores, { "NP", "000003" } ) 
	AAdd( aValores, { "NP", "000005" } ) 
	AAdd( aValores, { "NP", "000006" } )
	AAdd( aValores, { "NP", "000007" } )
	AAdd( aValores, { "NP", "000008" } )
	AAdd( aValores, { "NP", "000010" } )
	AAdd( aValores, { "PA", "000001" } ) 
	AAdd( aValores, { "PA", "000005" } ) 
	AAdd( aValores, { "PA", "000010" } ) 
	AAdd( aValores, { "PC", "000001" } )
	AAdd( aValores, { "PC", "000002" } ) 
	AAdd( aValores, { "PC", "000006" } ) 
	AAdd( aValores, { "PC", "000007" } ) 
	AAdd( aValores, { "PC", "000010" } )
	AAdd( aValores, { "PI", "000001" } ) 
	AAdd( aValores, { "PI", "000002" } ) 
	AAdd( aValores, { "PI", "000010" } ) 
	AAdd( aValores, { "RB", "000001" } )
	AAdd( aValores, { "RB", "000002" } )
	AAdd( aValores, { "RB", "000003" } )
	AAdd( aValores, { "RB", "000005" } )
	AAdd( aValores, { "RB", "000006" } )
	AAdd( aValores, { "RB", "000007" } )
	AAdd( aValores, { "RB", "000010" } )
	AAdd( aValores, { "RC", "000001" } )
	AAdd( aValores, { "RC", "000005" } )
	AAdd( aValores, { "RC", "000010" } )
	AAdd( aValores, { "RP", "000001" } )
	AAdd( aValores, { "RP", "000002" } )
	AAdd( aValores, { "RP", "000003" } )
	AAdd( aValores, { "RP", "000005" } )
	AAdd( aValores, { "RP", "000006" } )
	AAdd( aValores, { "RP", "000007" } )
	AAdd( aValores, { "RP", "000010" } )
	AAdd( aValores, { "SF", "000001" } ) 
	AAdd( aValores, { "SF", "000002" } ) 
	AAdd( aValores, { "SF", "000005" } ) 
	AAdd( aValores, { "SF", "000006" } ) 
	AAdd( aValores, { "SF", "000007" } ) 
	AAdd( aValores, { "SF", "000010" } ) 
	AAdd( aValores, { "SJ", "000001" } ) 
	AAdd( aValores, { "SJ", "000002" } ) 
	AAdd( aValores, { "SJ", "000003" } ) 
	AAdd( aValores, { "SJ", "000006" } ) 
	AAdd( aValores, { "SJ", "000007" } ) 
	AAdd( aValores, { "SJ", "000010" } ) 
	AAdd( aValores, { "TB", "000001" } ) 
	AAdd( aValores, { "TB", "000002" } ) 
	AAdd( aValores, { "TB", "000006" } ) 
	AAdd( aValores, { "TB", "000007" } ) 
	AAdd( aValores, { "TB", "000040" } ) 
	AAdd( aValores, { "TF", "000001" } ) 
	AAdd( aValores, { "TF", "000003" } ) 
	AAdd( aValores, { "TF", "000006" } ) 
	AAdd( aValores, { "TF", "000007" } ) 
	AAdd( aValores, { "TF", "000010" } ) 
	
	cFilTab := FWxFilial( cAliasTab )
	aAreaTab := &(cAliasTab)->( GetArea() )
	&(cAliasTab)->( dbSetOrder( 1 ) )
	For nI := 1 To Len( aValores )
		cChave := cFilTab + PadR( aValores[nI][1], nTamTpDc ) + PadR( aValores[nI][2], nTamSec )
		If &(cAliasTab)->( !MsSeek( cChave ) )
			RecLock( cAliasTab, .T. )
			&(cAliasTab)->(FVH_FILIAL) := cFilTab
			&(cAliasTab)->(FVH_TIPODC) := aValores[nI][1]
			&(cAliasTab)->(FVH_SECAO)  := aValores[nI][2]
			&(cAliasTab)->( MsUnLock() )
		EndIf
	Next nI	
	&(cAliasTab)->( RestArea( aAreaTab ) )
Return Nil

/*/{Protheus.doc} LoadFVK
Função para popular a tabela de Seção X Situação, 
referente as situações do documento hábil (SIAFI)

@author Pedro Alencar
@since 23/10/2014
@version P12.1.2
/*/
Static Function LoadFVK()
	Local cChave := ""
	Local nI := 0
	Local aAreaTab := {}
	Local aValores := {}
	Local cFilTab := ""
	Local cAliastab := "FVK"
	Local nTamDoc := TamSX3("FVK_TIPODC")[1]
	Local nTamSec := TamSX3("FVK_SECAO")[1]
	Local nTamSit := TamSX3("FVK_SITUAC")[1]
	
	//Estrutura:{Tp. Doc. , Seção   , Situação }
	
	AAdd( aValores, { "AV", "000002", "DSP001" } ) 
	AAdd( aValores, { "AV", "000002", "DSP081" } ) 
	AAdd( aValores, { "AV", "000002", "DSP051" } ) 
	AAdd( aValores, { "AV", "000002", "DSP901" } ) 
	AAdd( aValores, { "AV", "000003", "PSO002" } ) 
	AAdd( aValores, { "AV", "000006", "DDR001" } ) 
	AAdd( aValores, { "AV", "000006", "DDF001" } ) 
	AAdd( aValores, { "AV", "000006", "DDF002" } ) 
	AAdd( aValores, { "AV", "000006", "DGP001" } ) 
	AAdd( aValores, { "AV", "000007", "ENC001" } ) 
	AAdd( aValores, { "AV", "000007", "ENC002" } ) 
	AAdd( aValores, { "AV", "000007", "ENC004" } ) 
	AAdd( aValores, { "AV", "000007", "ENC005" } ) 
	AAdd( aValores, { "AV", "000007", "ENC024" } ) 
	AAdd( aValores, { "CE", "000003", "PSO002" } ) 
	AAdd( aValores, { "CE", "000006", "DDF002" } ) 
	AAdd( aValores, { "CE", "000006", "DGP001" } ) 
	AAdd( aValores, { "CE", "000007", "ENC001" } ) 
	AAdd( aValores, { "CE", "000007", "ENC004" } ) 
	AAdd( aValores, { "CE", "000007", "ENC005" } ) 
	AAdd( aValores, { "CE", "000007", "ENC024" } ) 
	AAdd( aValores, { "DD", "000002", "DVL001" } ) 
	AAdd( aValores, { "DD", "000002", "DVL081" } ) 
	AAdd( aValores, { "DD", "000002", "DVL973" } ) 
	AAdd( aValores, { "DU", "000002", "DSF003" } ) 
	AAdd( aValores, { "DU", "000002", "DSF004" } ) 
	AAdd( aValores, { "DT", "000002", "DSP001" } ) 
	AAdd( aValores, { "DT", "000002", "DSP005" } ) 
	AAdd( aValores, { "DT", "000002", "DSP975" } ) 
	AAdd( aValores, { "DT", "000002", "DSP051" } ) 
	AAdd( aValores, { "DT", "000003", "PSO001" } )
	AAdd( aValores, { "DT", "000003", "PSO002" } )
	AAdd( aValores, { "DT", "000003", "PSO023" } ) 
	AAdd( aValores, { "DT", "000003", "PSO030" } ) 
	AAdd( aValores, { "DT", "000003", "PSO042" } ) 
	AAdd( aValores, { "DT", "000003", "PSO045" } ) 
	AAdd( aValores, { "DT", "000003", "PSO006" } )
	AAdd( aValores, { "DT", "000005", "DSE005" } ) 
	AAdd( aValores, { "DT", "000005", "DSN005" } ) 
	AAdd( aValores, { "DT", "000005", "LPA331" } ) 
	AAdd( aValores, { "DT", "000006", "DDF001" } ) 
	AAdd( aValores, { "DT", "000006", "DDF002" } ) 
	AAdd( aValores, { "DT", "000006", "DDR001" } )
	AAdd( aValores, { "DT", "000006", "DGP001" } ) 
	AAdd( aValores, { "DT", "000007", "ENC001" } )
	AAdd( aValores, { "DT", "000007", "ENC005" } )
	AAdd( aValores, { "DT", "000007", "ENC002" } ) 
	AAdd( aValores, { "DT", "000007", "ENC004" } ) 
	AAdd( aValores, { "DT", "000007", "ENC021" } ) 
	AAdd( aValores, { "DT", "000007", "ENC022" } ) 
	AAdd( aValores, { "DT", "000007", "ENC024" } ) 
	AAdd( aValores, { "DT", "000007", "ENC028" } ) 
	AAdd( aValores, { "FL", "000002", "DFL002" } )
	AAdd( aValores, { "FL", "000002", "DFL003" } )
	AAdd( aValores, { "FL", "000002", "DFL004" } )
	AAdd( aValores, { "FL", "000002", "DFL001" } ) 
	AAdd( aValores, { "FL", "000002", "DFL011" } ) 
	AAdd( aValores, { "FL", "000002", "DFL013" } ) 
	AAdd( aValores, { "FL", "000002", "DFL034" } ) 
	AAdd( aValores, { "FL", "000002", "DFL035" } ) 
	AAdd( aValores, { "FL", "000002", "DFL045" } ) 
	AAdd( aValores, { "FL", "000002", "DSP901" } ) 
	AAdd( aValores, { "FL", "000002", "DSP975" } ) 
	AAdd( aValores, { "FL", "000003", "PSO002" } ) 
	AAdd( aValores, { "FL", "000003", "PSO023" } ) 
	AAdd( aValores, { "FL", "000003", "PSO042" } ) 
	AAdd( aValores, { "FL", "000003", "PSO079" } ) 
	AAdd( aValores, { "FL", "000005", "DFE001" } ) 
	AAdd( aValores, { "FL", "000005", "DFN001" } ) 
	AAdd( aValores, { "FL", "000005", "LPA301" } ) 
	AAdd( aValores, { "FL", "000005", "LPA331" } ) 
	AAdd( aValores, { "FL", "000005", "PRV001" } )
	AAdd( aValores, { "FL", "000005", "PRV002" } )
	AAdd( aValores, { "FL", "000005", "PRV003" } )
	AAdd( aValores, { "FL", "000005", "PRV004" } )
	AAdd( aValores, { "FL", "000005", "PRV005" } )
	AAdd( aValores, { "FL", "000005", "PRV006" } )
	AAdd( aValores, { "FL", "000006", "DDF001" } ) 
	AAdd( aValores, { "FL", "000006", "DDR001" } ) 
	AAdd( aValores, { "FL", "000006", "DGR002" } ) 
	AAdd( aValores, { "FL", "000006", "DGR005" } ) 
	AAdd( aValores, { "FL", "000006", "DOB006" } ) 
	AAdd( aValores, { "FL", "000006", "DOB008" } ) 
	AAdd( aValores, { "FL", "000006", "DOB009" } ) 
	AAdd( aValores, { "FL", "000006", "DOB013" } ) 
	AAdd( aValores, { "FL", "000006", "DDF002" } )
	AAdd( aValores, { "FL", "000006", "DDF010" } )
	AAdd( aValores, { "FL", "000006", "DGP001" } )
	AAdd( aValores, { "FL", "000006", "DGR009" } )
	AAdd( aValores, { "FL", "000006", "DGR010" } )
	AAdd( aValores, { "FL", "000006", "DOB005" } )
	AAdd( aValores, { "FL", "000006", "DOB007" } )
	AAdd( aValores, { "FL", "000007", "ENC002" } ) 
	AAdd( aValores, { "FL", "000007", "ENC004" } ) 
	AAdd( aValores, { "FL", "000007", "ENC014" } ) 
	AAdd( aValores, { "FL", "000007", "ENC024" } ) 
	AAdd( aValores, { "FL", "000007", "ENC001" } )
	AAdd( aValores, { "FL", "000007", "ENC011" } )
	AAdd( aValores, { "FL", "000007", "ENC015" } )
	AAdd( aValores, { "FL", "000008", "AFL001" } )
	AAdd( aValores, { "FL", "000008", "AFL002" } )
	AAdd( aValores, { "FL", "000008", "AFL003" } )
	AAdd( aValores, { "FL", "000008", "AFL004" } )
	AAdd( aValores, { "IT", "000005", "CRD020" } ) 
	AAdd( aValores, { "IT", "000005", "CRD021" } ) 
	AAdd( aValores, { "FL", "000005", "PRV001" } )
	AAdd( aValores, { "FL", "000005", "PRV002" } )
	AAdd( aValores, { "FL", "000005", "PRV003" } )
	AAdd( aValores, { "FL", "000005", "PRV004" } )
	AAdd( aValores, { "FL", "000005", "PRV005" } )
	AAdd( aValores, { "FL", "000005", "PRV006" } )
	AAdd( aValores, { "NP", "000002", "DSP001" } )
	AAdd( aValores, { "NP", "000002", "DSP011" } )
	AAdd( aValores, { "NP", "000002", "DSP100" } )
	AAdd( aValores, { "NP", "000002", "DSP101" } )
	AAdd( aValores, { "NP", "000002", "DSP102" } )
	AAdd( aValores, { "NP", "000002", "DSP200" } )
	AAdd( aValores, { "NP", "000002", "DSP201" } )
	AAdd( aValores, { "NP", "000002", "DSP206" } )
	AAdd( aValores, { "NP", "000002", "DSP215" } )
	AAdd( aValores, { "NP", "000002", "DSP900" } )
	AAdd( aValores, { "NP", "000002", "DSP005" } ) 
	AAdd( aValores, { "NP", "000002", "DSP051" } ) 
	AAdd( aValores, { "NP", "000002", "DSP062" } ) 
	AAdd( aValores, { "NP", "000002", "DSP901" } ) 
	AAdd( aValores, { "NP", "000002", "DSP925" } ) 
	AAdd( aValores, { "NP", "000002", "DSP975" } ) 
	AAdd( aValores, { "NP", "000003", "PSO002" } ) 
	AAdd( aValores, { "NP", "000003", "PSO023" } ) 
	AAdd( aValores, { "NP", "000003", "PSO042" } ) 
	AAdd( aValores, { "NP", "000005", "DSE005" } ) 
	AAdd( aValores, { "NP", "000005", "DSN005" } ) 
	AAdd( aValores, { "NP", "000005", "ETQ001" } ) 
	AAdd( aValores, { "NP", "000005", "LDV011" } ) 
	AAdd( aValores, { "NP", "000005", "LPA331" } ) 
	AAdd( aValores, { "NP", "000006", "DDF002" } ) 
	AAdd( aValores, { "NP", "000006", "DGR002" } ) 
	AAdd( aValores, { "NP", "000006", "DGR005" } ) 
	AAdd( aValores, { "NP", "000006", "DDF001" } )
	AAdd( aValores, { "NP", "000006", "DDR001" } )
	AAdd( aValores, { "NP", "000006", "DOB001" } )
	AAdd( aValores, { "NP", "000006", "DGP001" } )
	AAdd( aValores, { "NP", "000007", "ENC004" } ) 
	AAdd( aValores, { "NP", "000007", "ENC001" } )
	AAdd( aValores, { "NP", "000007", "ENC002" } ) 
	AAdd( aValores, { "NP", "000007", "ENC005" } ) 
	AAdd( aValores, { "NP", "000007", "ENC022" } ) 
	AAdd( aValores, { "NP", "000007", "ENC024" } ) 
	AAdd( aValores, { "NP", "000007", "ENC028" } ) 
	AAdd( aValores, { "NP", "000008", "EDS001" } )
	AAdd( aValores, { "NP", "000008", "EDS011" } )
	AAdd( aValores, { "NP", "000008", "EDS101" } )
	AAdd( aValores, { "NP", "000008", "EDS102" } )
	AAdd( aValores, { "NP", "000008", "EDS200" } )
	AAdd( aValores, { "NP", "000008", "EDS201" } )
	AAdd( aValores, { "NP", "000008", "EDS206" } )
	AAdd( aValores, { "NP", "000008", "EDS900" } )
	AAdd( aValores, { "PA", "000005", "CRA001" } ) 
	AAdd( aValores, { "PA", "000005", "CRA002" } ) 
	AAdd( aValores, { "PA", "000005", "CRA003" } ) 
	AAdd( aValores, { "PA", "000005", "CRD016" } ) 
	AAdd( aValores, { "PA", "000005", "CRD018" } ) 
	AAdd( aValores, { "PA", "000005", "CRD020" } ) 
	AAdd( aValores, { "PA", "000005", "CRD021" } ) 
	AAdd( aValores, { "PA", "000005", "CRD045" } ) 
	AAdd( aValores, { "PA", "000005", "CRD049" } ) 
	AAdd( aValores, { "PA", "000005", "CRD107" } ) 
	AAdd( aValores, { "PA", "000005", "CRD121" } ) 
	AAdd( aValores, { "PA", "000005", "ETQ001" } ) 
	AAdd( aValores, { "PA", "000005", "ETQ027" } ) 
	AAdd( aValores, { "PA", "000005", "IMB070" } ) 
	AAdd( aValores, { "PA", "000005", "IMB071" } ) 
	AAdd( aValores, { "PA", "000005", "INT001" } ) 
	AAdd( aValores, { "PA", "000005", "LDV053" } ) 
	AAdd( aValores, { "PA", "000005", "LPA301" } ) 
	AAdd( aValores, { "PA", "000005", "LPA331" } ) 
	AAdd( aValores, { "PA", "000005", "PRV007" } ) 
	AAdd( aValores, { "PA", "000005", "PRV008" } ) 
	AAdd( aValores, { "PC", "000002", "DSP902" } )
	AAdd( aValores, { "PC", "000002", "DSP901" } ) 
	AAdd( aValores, { "PC", "000006", "DDF001" } ) 
	AAdd( aValores, { "PC", "000006", "DDF002" } ) 
	AAdd( aValores, { "PC", "000006", "DDR001" } ) 
	AAdd( aValores, { "PC", "000006", "DGP001" } ) 
	AAdd( aValores, { "PC", "000007", "ENC001" } ) 
	AAdd( aValores, { "PC", "000007", "ENC022" } ) 
	AAdd( aValores, { "PC", "000007", "ENC024" } ) 
	AAdd( aValores, { "PI", "000002", "DSP901" } ) 
	AAdd( aValores, { "RB", "000002", "DSP900" } )
	AAdd( aValores, { "RB", "000002", "DSP901" } )
	AAdd( aValores, { "RB", "000002", "DFL003" } ) 
	AAdd( aValores, { "RB", "000002", "DFL013" } ) 
	AAdd( aValores, { "RB", "000002", "DSP001" } ) 
	AAdd( aValores, { "RB", "000002", "DSP005" } ) 
	AAdd( aValores, { "RB", "000002", "DSP051" } ) 
	AAdd( aValores, { "RB", "000002", "DSP081" } ) 
	AAdd( aValores, { "RB", "000002", "DSP101" } ) 
	AAdd( aValores, { "RB", "000002", "DSP102" } ) 
	AAdd( aValores, { "RB", "000002", "DSP215" } ) 
	AAdd( aValores, { "RB", "000002", "DSP975" } ) 
	AAdd( aValores, { "RB", "000003", "PSO002" } ) 
	AAdd( aValores, { "RB", "000005", "DSE005" } ) 
	AAdd( aValores, { "RB", "000005", "DSN005" } ) 
	AAdd( aValores, { "RB", "000005", "LPA331" } ) 
	AAdd( aValores, { "RB", "000006", "DDF001" } ) 
	AAdd( aValores, { "RB", "000006", "DDF002" } ) 
	AAdd( aValores, { "RB", "000007", "ENC022" } ) 
	AAdd( aValores, { "RC", "000005", "LDV011" } ) 
	AAdd( aValores, { "RC", "000005", "LDV051" } ) 
	AAdd( aValores, { "RC", "000005", "LDV052" } ) 
	AAdd( aValores, { "RC", "000005", "LDV053" } ) 
	AAdd( aValores, { "RP", "000002", "DSP001" } )
	AAdd( aValores, { "RP", "000002", "DSP011" } )
	AAdd( aValores, { "RP", "000002", "DSP005" } ) 
	AAdd( aValores, { "RP", "000002", "DSP051" } ) 
	AAdd( aValores, { "RP", "000002", "DSP062" } ) 
	AAdd( aValores, { "RP", "000002", "DSP101" } ) 
	AAdd( aValores, { "RP", "000002", "DSP102" } ) 
	AAdd( aValores, { "RP", "000002", "DSP215" } ) 
	AAdd( aValores, { "RP", "000002", "DSP901" } ) 
	AAdd( aValores, { "RP", "000002", "DSP925" } ) 
	AAdd( aValores, { "RP", "000002", "DSP975" } ) 
	AAdd( aValores, { "RP", "000003", "PSO002" } ) 
	AAdd( aValores, { "RP", "000003", "PSO023" } ) 
	AAdd( aValores, { "RP", "000003", "PSO042" } ) 
	AAdd( aValores, { "RP", "000005", "DSE005" } ) 
	AAdd( aValores, { "RP", "000005", "DSN005" } ) 
	AAdd( aValores, { "RP", "000005", "ETQ001" } ) 
	AAdd( aValores, { "RP", "000005", "LPA331" } ) 
	AAdd( aValores, { "RP", "000006", "DDF001" } ) 
	AAdd( aValores, { "RP", "000006", "DGR002" } ) 
	AAdd( aValores, { "RP", "000006", "DGR005" } ) 
	AAdd( aValores, { "RP", "000006", "DOB007" } ) 
	AAdd( aValores, { "RP", "000006", "DDF002" } )
	AAdd( aValores, { "RP", "000006", "DGP001" } )
	AAdd( aValores, { "RP", "000006", "DDR001" } )
	AAdd( aValores, { "RP", "000006", "DOB001" } )
	AAdd( aValores, { "RP", "000007", "ENC001" } ) 
	AAdd( aValores, { "RP", "000007", "ENC002" } ) 
	AAdd( aValores, { "RP", "000007", "ENC004" } ) 
	AAdd( aValores, { "RP", "000007", "ENC005" } ) 
	AAdd( aValores, { "RP", "000007", "ENC022" } ) 
	AAdd( aValores, { "RP", "000007", "ENC024" } ) 
	AAdd( aValores, { "RP", "000007", "ENC028" } ) 
	AAdd( aValores, { "SF", "000002", "SPF003" } ) 
	AAdd( aValores, { "SF", "000005", "SPE003" } ) 
	AAdd( aValores, { "SF", "000005", "SPN003" } ) 
	AAdd( aValores, { "SF", "000006", "DOB029" } ) 
	AAdd( aValores, { "SF", "000006", "DGP001" } ) 
	AAdd( aValores, { "SF", "000007", "ENC001" } ) 
	AAdd( aValores, { "SF", "000007", "ENC024" } ) 
	AAdd( aValores, { "SJ", "000002", "DFL011" } ) 
	AAdd( aValores, { "SJ", "000002", "DSP001" } ) 
	AAdd( aValores, { "SJ", "000002", "DSP051" } ) 
	AAdd( aValores, { "SJ", "000002", "DSP102" } ) 
	AAdd( aValores, { "SJ", "000002", "DSP901" } ) 
	AAdd( aValores, { "SJ", "000002", "DSP925" } ) 
	AAdd( aValores, { "SJ", "000003", "PSO023" } ) 
	AAdd( aValores, { "SJ", "000003", "PSO042" } ) 
	AAdd( aValores, { "SJ", "000006", "DDF001" } ) 
	AAdd( aValores, { "SJ", "000006", "DDF002" } ) 
	AAdd( aValores, { "SJ", "000006", "DGP001" } ) 
	AAdd( aValores, { "SJ", "000007", "ENC001" } ) 
	AAdd( aValores, { "SJ", "000007", "ENC022" } ) 
	AAdd( aValores, { "SJ", "000007", "ENC024" } ) 
	AAdd( aValores, { "TB", "000002", "DSP925" } ) 
	AAdd( aValores, { "TB", "000006", "DDF002" } ) 
	AAdd( aValores, { "TB", "000006", "DGP001" } ) 
	AAdd( aValores, { "TB", "000007", "ENC002" } ) 
	AAdd( aValores, { "TF", "000003", "PSO002" } ) 
	AAdd( aValores, { "TF", "000003", "PSO023" } ) 
	AAdd( aValores, { "TF", "000003", "PSO042" } ) 
	AAdd( aValores, { "TF", "000006", "DDF001" } ) 
	AAdd( aValores, { "TF", "000006", "DDF002" } ) 
	AAdd( aValores, { "TF", "000007", "ENC001" } ) 
	AAdd( aValores, { "TF", "000007", "ENC004" } ) 
	AAdd( aValores, { "TF", "000007", "ENC005" } ) 
	AAdd( aValores, { "TF", "000007", "ENC024" } ) 
	
	cFilTab := FWxFilial( cAliasTab )
	aAreaTab := &(cAliasTab)->( GetArea() )
	&(cAliasTab)->( dbSetOrder( 1 ) )
	For nI := 1 To Len( aValores )
		cChave := cFilTab + PadR( aValores[nI][1], nTamDoc ) + PadR( aValores[nI][2], nTamSec ) + PadR( aValores[nI][3], nTamSit ) 
		If &(cAliasTab)->( !MsSeek( cChave ) )
			RecLock( cAliasTab, .T. )
			&(cAliasTab)->(FVK_FILIAL) := cFilTab
			&(cAliasTab)->(FVK_TIPODC) := aValores[nI][1]
			&(cAliasTab)->(FVK_SECAO)  := aValores[nI][2]
			&(cAliasTab)->(FVK_SITUAC) := aValores[nI][3]
			&(cAliasTab)->( MsUnLock() )
		EndIf
	Next nI	
	&(cAliasTab)->( RestArea( aAreaTab ) )
Return Nil

/*/{Protheus.doc} LoadFV4
Função para popular a tabela de campos da associação 
Tipo Doc. X Seção X Situação X Campos, referente as 
situações do documento hábil (SIAFI)

@author Pedro Alencar
@since 23/10/2014
@version P12.1.2
/*/
Static Function LoadFV4()
	Local cChave := ""
	Local nI := 0
	Local aAreaTab := {}
	Local aValores := {}
	Local cFilTab := ""
	Local cAliastab := "FV4"
	Local nTamSit := TamSX3("FV4_SITUAC")[1]
	Local nTamID := TamSX3("FV4_IDCAMP")[1]
	Local nTamCT1 := TamSX3("CT1_CONTA")[1]
	Local cPicCT1 := MascaraCTB(Replicate('9',nTamCT1),,nTamCT1,"","CT1")
	
	//Estrutura:    { Situação,  Campo, Descrição do Campo, Tam.	, Tp. Campo, Picture          	, Obrigat., TagXML, Ativo?, Local, Modo Edição, Consul. Pad,Validação }
	AAdd( aValores, { "AFL001", "0001", OemToAnsi(STR0095),  nTamCT1, TIPO_CHAR , cPicCT1	, "1", "numClassA",  "1"  ,  "1" , "", "CT1" ,"F761VCT1('C0001')"} ) //"Variação Patrimonial Diminutiva"
	
	AAdd( aValores, { "AFL003", "0001", OemToAnsi(STR0095),  nTamCT1, TIPO_CHAR , cPicCT1	, "1", "numClassA",  "1"  ,  "1" , "", "CT1" ,"F761VCT1('C0001')"} ) //"Variação Patrimonial Diminutiva"
	
	AAdd( aValores, { "AFL004", "0001", OemToAnsi(STR0095),   nTamCT1		, TIPO_CHAR , cPicCT1	, "1", "numClassA",  "1"  ,  "1" , "", "CT1" ,"F761VCT1('C0001')"} ) //"Variação Patrimonial Diminutiva"
	
	AAdd( aValores, { "CRA001", "0001", OemToAnsi(STR0199),  10		, TIPO_CHAR , ""           		, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"Fonte" 
	AAdd( aValores, { "CRA001", "0002", OemToAnsi(STR0200),  3		, TIPO_CHAR , ""           		, "1", "txtInscrB",  "1"  ,  "1" , "", "" ,""} ) //"Vinculação" 
	AAdd( aValores, { "CRA001", "0003", OemToAnsi(STR0201),  14		, TIPO_CHAR , ""           		, "1", "txtInscrC",  "1"  ,  "1" , "", "" ,""} ) //"CNPJ, CPF, UG ou IG." 	
	AAdd( aValores, { "CRA001", "0004", OemToAnsi(STR0202),  nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0004')"} ) //"Classificação Contábil da Receita" 
	AAdd( aValores, { "CRA001", "0005", OemToAnsi(STR0203),  nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0005')"} ) //"Classificação Orçamentária da Receita" 
	
	AAdd( aValores, { "CRA002", "0001", OemToAnsi(STR0204),  12		, TIPO_CHAR , ""	           	, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"Empenho" 
	AAdd( aValores, { "CRA002", "0002", OemToAnsi(STR0205),  2		, TIPO_CHAR , ""           		, "1", "txtInscrB",  "1"  ,  "1" , "", "" ,""} ) //"Subitem" 
	AAdd( aValores, { "CRA002", "0003", OemToAnsi(STR0206), nTamCT1 , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"Despesas Bancárias"	
	AAdd( aValores, { "CRA002", "0004", OemToAnsi(STR0202), nTamCT1	, TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0004')"} ) //"Classificação Contábil da Receita" 
	
	AAdd( aValores, { "CRA003", "0001", OemToAnsi(STR0204),  12		, TIPO_CHAR , ""	           	, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"Empenho" 
	AAdd( aValores, { "CRA003", "0002", OemToAnsi(STR0205),  2		, TIPO_CHAR , ""           		, "1", "txtInscrB",  "1"  ,  "1" , "", "" ,""} ) //"Subitem" 
	AAdd( aValores, { "CRA003", "0003", OemToAnsi(STR0207),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"Imposto s/ Operações Financeiras - IOF"	
	AAdd( aValores, { "CRA003", "0004", OemToAnsi(STR0202),nTamCT1	, TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0004')"} ) //"Classificação Contábil da Receita" 
	
	AAdd( aValores, { "CRD016", "0001", OemToAnsi(STR0208),  14		, TIPO_CHAR , ""           		, "1", "txtInscrB",  "1"  ,  "1" , "", "" ,""} ) //"CNPJ, CPF, UG, IG ou 999" 
	AAdd( aValores, { "CRD016", "0002", OemToAnsi(STR0209), nTamCT1, TIPO_CHAR  , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"VPD de Serviços"	
	AAdd( aValores, { "CRD016", "0003", OemToAnsi(STR0210), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"Conta de Despesa Antecipada" 
	
	AAdd( aValores, { "CRD018", "0001", OemToAnsi(STR0211),  4		, TIPO_CHAR , ""	           	, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"Exercício" 
	AAdd( aValores, { "CRD018", "0002", OemToAnsi(STR0208),  14		, TIPO_CHAR , ""           		, "1", "txtInscrB",  "1"  ,  "1" , "", "" ,""} ) //"CNPJ, CPF, UG, IG OU 999" 
	AAdd( aValores, { "CRD018", "0003", OemToAnsi(STR0212), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"Créditos Administrativos ou TCE ou Processo Judicial"	
	AAdd( aValores, { "CRD018", "0004", OemToAnsi(STR0213), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0004')"} ) //"Receita de juros / Atualização Monetária" 
	
	AAdd( aValores, { "CRD020", "0001", OemToAnsi(STR0214),  14		, TIPO_CHAR , ""           		, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"CNPJ, CPF, UG ou IG - Curto Prazo" 
	AAdd( aValores, { "CRD020", "0002", OemToAnsi(STR0215),  14		, TIPO_CHAR , ""           		, "1", "txtInscrB",  "1"  ,  "1" , "", "" ,""} ) //"CNPJ, CPF, UG ou IG - Longo Prazo" 
	AAdd( aValores, { "CRD020", "0003", OemToAnsi(STR0216), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"Empréstimos e Financiamentos a Curto Prazo"	
	AAdd( aValores, { "CRD020", "0004", OemToAnsi(STR0217), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0004')"} ) //"Empréstimos e Financiamentos a Longo Prazo" 
	
	AAdd( aValores, { "CRD021", "0001", OemToAnsi(STR0218),  9		, TIPO_CHAR , ""           		, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"Conta-corrente de Financiamento" 
	AAdd( aValores, { "CRD021", "0002", OemToAnsi(STR0217), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"Empréstimos e Financiamentos a Longo Prazo"	
	AAdd( aValores, { "CRD021", "0003", OemToAnsi(STR0216), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"Empréstimos e Financiamentos a Curto Prazo" 
		
	AAdd( aValores, { "CRD045", "0001", OemToAnsi(STR0208),  14		, TIPO_CHAR , ""           		, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"CNPJ, CPF, UG, IG ou 999" 
	AAdd( aValores, { "CRD045", "0002", OemToAnsi(STR0219), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"ajustes Financeiros de Empréstimos Concedidos - Negativo"	
	AAdd( aValores, { "CRD045", "0003", OemToAnsi(STR0220), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"Créditos a Longo Prazo" 

	AAdd( aValores, { "CRD049", "0001", OemToAnsi(STR0208),  14		, TIPO_CHAR , "9999"           	, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"CNPJ, CPF, UG, IG ou 999" 
	AAdd( aValores, { "CRD049", "0002", OemToAnsi(STR0221), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"Empréstimos concedidos - longo prazo"	
	AAdd( aValores, { "CRD049", "0003", OemToAnsi(STR0222), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"Ajustes Financeiros de Empréstimos Concedidos - Positivo" 
	
	AAdd( aValores, { "CRD121", "0001", OemToAnsi(STR0102),  14		, TIPO_CHAR ,"99.999.999/9999-99", "1", "txtInscrA",  "1"  ,  "1" , "", "" ,"F761VCGC('C0001')"} ) //"Favorecido do Contrato" 
	AAdd( aValores, { "CRD121", "0002", OemToAnsi(STR0223), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"Despesa antecipada a apropriar" 
	AAdd( aValores, { "CRD121", "0003", OemToAnsi(STR0224), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"VPD Reclassificada" 
	
	AAdd( aValores, { "DDF001", "0001", OemToAnsi(STR0069),  4		, TIPO_CHAR , "9999"           	, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"Código DARF"
	AAdd( aValores, { "DDF001", "0002", OemToAnsi(STR0027),  4		, TIPO_CHAR , "9999"           	, "1", "txtInscrA",  "1"  ,  "2" , "", "" ,""} ) //"Código do DARF"
	AAdd( aValores, { "DDF001", "0003", OemToAnsi(STR0096), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"VPD de Multa ou Encargos Tributários"
	
	AAdd( aValores, { "DDF002", "0001", OemToAnsi(STR0069),  4		, TIPO_CHAR , "9999"           	, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"Código DARF"
	AAdd( aValores, { "DDF002", "0002", OemToAnsi(STR0027),  4		, TIPO_CHAR , "9999"           	, "1", "txtInscrA",  "1"  ,  "2" , "", "" ,""} ) //"Código do DARF"	
	AAdd( aValores, { "DDF002", "0003", OemToAnsi(STR0096), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"VPD de Multa ou Encargos Tributários"
	
	AAdd( aValores, { "DDR001", "0001", OemToAnsi(STR0025),  4		, TIPO_CHAR , "9999"           	, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"Código do Município"
	AAdd( aValores, { "DDR001", "0002", OemToAnsi(STR0026),  4		, TIPO_CHAR , "9999"           	, "1", "txtInscrB",  "1"  ,  "1" , "", "" ,""} ) //"Código de Receita"
	AAdd( aValores, { "DDR001", "0003", OemToAnsi(STR0025),  4		, TIPO_CHAR , "9999"           	, "1", "txtInscrA",  "1"  ,  "2" , "", "" ,""} ) //"Código do Município"
	AAdd( aValores, { "DDR001", "0004", OemToAnsi(STR0026),  4		, TIPO_CHAR , "9999"           	, "1", "txtInscrB",  "1"  ,  "2" , "", "" ,""} ) //"Código de Receita"
	AAdd( aValores, { "DDR001", "0005", OemToAnsi(STR0096), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0005')"} ) //"VPD de Multa ou Encargos Tributários"
	
	AAdd( aValores, { "DDR006", "0001", OemToAnsi(STR0025),  4		, TIPO_CHAR , "9999"           	, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"Código do Município"
	AAdd( aValores, { "DDR006", "0002", OemToAnsi(STR0026),  4		, TIPO_CHAR , "9999"           	, "1", "txtInscrB",  "1"  ,  "1" , "", "" ,""} ) //"Código de Receita"
	AAdd( aValores, { "DDR006", "0003", OemToAnsi(STR0025),  4		, TIPO_CHAR , "9999"           	, "1", "txtInscrA",  "1"  ,  "2" , "", "" ,""} ) //"Código do Município"
	AAdd( aValores, { "DDR006", "0004", OemToAnsi(STR0026),  4		, TIPO_CHAR , "9999"           	, "1", "txtInscrB",  "1"  ,  "2" , "", "" ,""} ) //"Código de Receita"
	AAdd( aValores, { "DDR006", "0005", OemToAnsi(STR0096), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0006')"} ) //"VPD de Multa ou Encargos Tributários"
	
	AAdd( aValores, { "DFE001", "0001", OemToAnsi(STR0124),  12		, TIPO_CHAR , ""           	   	, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"Empenho para Estorno" 
	AAdd( aValores, { "DFE001", "0002", OemToAnsi(STR0225),  2		, TIPO_CHAR , ""	           	, "1", "txtInscrB",  "1"  ,  "2" , "", "" ,""} ) //"Subitem 3" 
	AAdd( aValores, { "DFE001", "0003", OemToAnsi(STR0095), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassC",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"Variação Patrimonial Diminutiva" 
	
	AAdd( aValores, { "DFL001", "0001", OemToAnsi(STR0095), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0001')"} ) //"Variação Patrimonial Diminutiva"
	
	AAdd( aValores, { "DFL002", "0001", OemToAnsi(STR0097),  3		, TIPO_CHAR , ""               	, "1", "txtInscrA",  "1"  ,  "2" , "", "" ,""} ) //"Banco"
	AAdd( aValores, { "DFL002", "0002", OemToAnsi(STR0098),  4		, TIPO_CHAR , ""               	, "1", "txtInscrB",  "1"  ,  "2" , "", "" ,""} ) //"Agência"
	AAdd( aValores, { "DFL002", "0003", OemToAnsi(STR0099),  10		, TIPO_CHAR , ""               	, "1", "txtInscrC",  "1"  ,  "2" , "", "" ,""} ) //"Conta"
	AAdd( aValores, { "DFL002", "0004", OemToAnsi(STR0095), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0004')"} ) //"Variação Patrimonial Diminutiva"
		
	AAdd( aValores, { "DFL003", "0001", OemToAnsi(STR0095), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0001')"} ) //"Variação Patrimonial Diminutiva"
	
	AAdd( aValores, { "DFL004", "0001", OemToAnsi(STR0095), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0001')"} ) //"Variação Patrimonial Diminutiva"
	
	AAdd( aValores, { "DFL011", "0001", OemToAnsi(STR0095), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  , "2"	, "", "CT1" ,"F761VCT1('C0001')"} )//"Variação Patrimonial Diminutiva" 
	
	AAdd( aValores, { "DFL013", "0001", OemToAnsi(STR0095), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  , "2"	, "", "CT1" ,"F761VCT1('C0001')"} )//"Variação Patrimonial Diminutiva" 
	
	AAdd( aValores, { "DFL034", "0001", OemToAnsi(STR0095), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  , "2"	, "", "CT1" ,"F761VCT1('C0001')"} )//"Variação Patrimonial Diminutiva" 
	AAdd( aValores, { "DFL034", "0002", OemToAnsi(STR0226), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  , "2"	, "", "CT1" ,"F761VCT1('C0002')"} )//"Indenizações a Pagar" 
	
	AAdd( aValores, { "DFL035", "0001", OemToAnsi(STR0227), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  , "2"	, "", "CT1" ,"F761VCT1('C0001')"} )//"Pessoal Requisitado de Outros Órgãos" 
	
	AAdd( aValores, { "DFL045", "0001", OemToAnsi(STR0095), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  , "2"	, "", "CT1" ,"F761VCT1('C0001')"} )//"Variação Patrimonial Diminutiva" 
	
	AAdd( aValores, { "DFN001", "0001", OemToAnsi(STR0127),  12		, TIPO_CHAR , ""				   	, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"Novo Empenho" 
	AAdd( aValores, { "DFN001", "0002", OemToAnsi(STR0128),  14		, TIPO_CHAR , ""           	   	, "1", "txtInscrB",  "1"  ,  "2" , "", "" ,""} ) //"Novo Subitem" 
	AAdd( aValores, { "DFN001", "0003", OemToAnsi(STR0095), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassC",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"Variação Patrimonial Diminutiva" 
	
	AAdd( aValores, { "DGP001", "0001", OemToAnsi(STR0029),  4		, TIPO_CHAR , "9999"           	, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"Código de Pagamento GPS"
	AAdd( aValores, { "DGP001", "0002", OemToAnsi(STR0029),  4		, TIPO_CHAR , "9999"           	, "1", "txtInscrA",  "1"  ,  "2" , "", "" ,""} ) //"Código de Pagamento GPS"	
	AAdd( aValores, { "DGP001", "0003", OemToAnsi(STR0096), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"VPD de Multa ou Encargos Tributários"
	
	AAdd( aValores, { "DGR002", "0001", OemToAnsi(STR0021),  6		, TIPO_CHAR , "99999-9"        	, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"Código de Recolhimento da GRU" 
	
	AAdd( aValores, { "DGR005", "0001", OemToAnsi(STR0021),  6		, TIPO_CHAR , "99999-9"        	, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"Código de Recolhimento da GRU" 
	
	AAdd( aValores, { "DGR009", "0001", OemToAnsi(STR0021),  6		, TIPO_CHAR , "99999-9"        	, "1", "txtInscrA",  "1"  ,  "1" , "F761WhenCtr(.T.)", "" ,""} ) //"Código de Recolhimento GRU"
	
	AAdd( aValores, { "DGR010", "0001", OemToAnsi(STR0021), 6       , TIPO_CHAR , "99999-9"        	, "1", "txtInscrA",  "1"  ,  "1" , "F761WhenCtr(.T.)", "" ,""} ) //"Código de Recolhimento GRU"
	
	AAdd( aValores, { "DOB005", "0001", OemToAnsi(STR0100),  14		, TIPO_CHAR , "99.999.999/9999-99", "1", "txtInscrA",  "1"  ,  "2" , "", "" ,"F761VCGC('C0001')"} ) //"Credor da Obrigação"
	AAdd( aValores, { "DOB005", "0002", OemToAnsi(STR0101), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"Outros Consignatários"
	
	AAdd( aValores, { "DOB006", "0001", OemToAnsi(STR0100),  14		, TIPO_CHAR ,"99.999.999/9999-99", "1", "txtInscrA",  "1"  ,  "1" , "", "" ,"F761VCGC('C0001')"} ) //"Credor da Obrigação" 
	AAdd( aValores, { "DOB006", "0002", OemToAnsi(STR0228), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"Retenções a Empréstimo e financiamentos" 
	
	AAdd( aValores, { "DOB007", "0001", OemToAnsi(STR0100),  14		, TIPO_CHAR ,"99.999.999/9999-99", "1", "txtInscrA",  "1"  ,  "1" , "", "" ,"F761VCGC('C0001')"} ) //"Credor da Obrigação"
	AAdd( aValores, { "DOB007", "0002", OemToAnsi(STR0123), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"Pensão Alimentícia"
	
	AAdd( aValores, { "DOB008", "0001", OemToAnsi(STR0100),  14		, TIPO_CHAR ,"99.999.999/9999-99", "1", "txtInscrA",  "1"  ,  "1" , "", "" ,"F761VCGC('C0001')"} ) //"Credor da Obrigação" 
	AAdd( aValores, { "DOB008", "0002", OemToAnsi(STR0229), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"Retenções a Entidades Representativas de Classe" 
	
	AAdd( aValores, { "DOB009", "0001", OemToAnsi(STR0100),  14		, TIPO_CHAR ,"99.999.999/9999-99", "1", "txtInscrA",  "1"  ,  "1" , "", "" ,"F761VCGC('C0001')"} ) //"Credor da Obrigação" 
	AAdd( aValores, { "DOB009", "0002", OemToAnsi(STR0230), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"Planos de Previdência e Assistência Médica" 
	
	AAdd( aValores, { "DOB013", "0001", OemToAnsi(STR0100),  14		, TIPO_CHAR ,"99.999.999/9999-99", "1", "txtInscrA",  "1"  ,  "1" , "", "" ,"F761VCGC('C0001')"} ) //"Credor da Obrigação" 
	AAdd( aValores, { "DOB013", "0002", OemToAnsi(STR0231), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"Retenções a Associações" 
	
	AAdd( aValores, { "DSE005", "0001", OemToAnsi(STR0124),  12		, TIPO_CHAR , ""           		, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"Empenho para Estorno" 
	AAdd( aValores, { "DSE005", "0002", OemToAnsi(STR0125),  14		, TIPO_CHAR , ""           		, "1", "txtInscrB",  "1"  ,  "1" , "", "" ,""} ) //"Subitem para Estorno" 
	AAdd( aValores, { "DSE005", "0003", OemToAnsi(STR0232), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "txtInscrA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"Conta de Passivo" 
	AAdd( aValores, { "DSE005", "0004", OemToAnsi(STR0095), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "txtInscrC",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0004')"} ) //"Variação Patrimonial Diminutiva" 
	
	AAdd( aValores, { "DSF003", "0001", OemToAnsi(STR0121),  3		, TIPO_CHAR , ""       			, "1", "txtInscrD",  "1"  ,  "1" , "", "" ,""} ) //"Vinculação de Pagamento" 
	
	AAdd( aValores, { "DSF004", "0001", OemToAnsi(STR0121),  3		, TIPO_CHAR , ""       		 	, "1", "txtInscrD",  "1"  ,  "1" , "", "" ,""} ) //"Vinculação de Pagamento" 
	
	AAdd( aValores, { "DSN005", "0001", OemToAnsi(STR0127),  12		, TIPO_CHAR , ""           		, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"Novo Empenho" 
	AAdd( aValores, { "DSN005", "0002", OemToAnsi(STR0128),  14		, TIPO_CHAR , ""           		, "1", "txtInscrB",  "1"  ,  "1" , "", "" ,""} ) //"Novo Subitem" 
	AAdd( aValores, { "DSN005", "0003", OemToAnsi(STR0232), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "txtInscrA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"Conta de Passivo" 
	AAdd( aValores, { "DSN005", "0004", OemToAnsi(STR0095), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "txtInscrC",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0004')"} ) //"Variação Patrimonial Diminutiva" 
	
	AAdd( aValores, { "DSP001", "0001", OemToAnsi(STR0021),  9		, TIPO_CHAR , "99999-9"		 	, "1", "txtInscrD",  "1"  ,  "1" , "F761WhenCtr(.T.)", "" ,""} ) //"Código de Recolhimento GRU"
	AAdd( aValores, { "DSP001", "0002", OemToAnsi(STR0102),  14		, TIPO_CHAR ,"99.999.999/9999-99", "1", "txtInscrE",  "1"  ,  "1" , "F761WhenCtr()", "" ,"F761VCGC('C0002')"} ) //"Favorecido do Contrato"
	AAdd( aValores, { "DSP001", "0003", OemToAnsi(STR0095), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"Variação Patrimonial Diminutiva"
	AAdd( aValores, { "DSP001", "0004", OemToAnsi(STR0103), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0004')"} ) //"Contas a Pagar"
	AAdd( aValores, { "DSP001", "0005", OemToAnsi(STR0104), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassC",  "1"  ,  "2" , "F761WhenCtr()", "CT1" ,"F761VCT1('C0005')"} ) //"Ativo a Apropriar"
	AAdd( aValores, { "DSP001", "0006", OemToAnsi(STR0070), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassD",  "1"  ,  "2" , "F761WhenCtr()", "CT1" ,"F761VCT1('C0006')"} ) //"Conta de Contrato"
	
	AAdd( aValores, { "DSP005", "0001", OemToAnsi(STR0102),  14		, TIPO_CHAR ,"99.999.999/9999-99", "1", "txtInscrA",  "1"  ,  "1" , "F761WhenCtr()", "" ,"F761VCGC('C0001')"} ) //"Favorecido do Contrato" 
	AAdd( aValores, { "DSP005", "0002", OemToAnsi(STR0021),  6		, TIPO_CHAR , "99999-9"		 	, "1", "txtInscrD",  "1"  ,  "1" , "F761WhenCtr(.T.)", "" ,""} ) //"Código de Recolhimento GRU" 
	AAdd( aValores, { "DSP005", "0003", OemToAnsi(STR0233), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"VPD com Encargos Tributários com União, Estados ou Municípios" 
	AAdd( aValores, { "DSP005", "0004", OemToAnsi(STR0234), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0004')"} ) //"Obrigações Fiscais a Curto Prazo a Pagar" 
	AAdd( aValores, { "DSP005", "0005", OemToAnsi(STR0235), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassC",  "1"  ,  "2" , "F761WhenCtr()", "CT1" ,"F761VCT1('C0005')"} ) //"Tributos Pagos Antecipadamente" 
	AAdd( aValores, { "DSP005", "0006", OemToAnsi(STR0070), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassD",  "1"  ,  "2" , "F761WhenCtr()", "CT1" ,"F761VCT1('C0006')"} ) //"Conta de Contrato" 
	
	AAdd( aValores, { "DSP051", "0001", OemToAnsi(STR0102),  14		, TIPO_CHAR ,"99.999.999/9999-99", "1", "txtInscrD",  "1"  ,  "1" , "F761WhenCtr()", "" ,"F761VCGC('C0001')"} ) //Favorecido do Contrato 
	AAdd( aValores, { "DSP051", "0002", OemToAnsi(STR0095), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //Variação Patrimonial Diminutiva 
	AAdd( aValores, { "DSP051", "0003", OemToAnsi(STR0103), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //Contas a Pagar 
	AAdd( aValores, { "DSP051", "0004", OemToAnsi(STR0070), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassD",  "1"  ,  "2" , "F761WhenCtr()", "CT1" ,"F761VCT1('C0004')"} ) //Conta de Contrato 
	
	AAdd( aValores, { "DSP062", "0001", OemToAnsi(STR0157), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassD",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0001')"} ) //"VPD de Serviço Técnico Profissional" 
		
	AAdd( aValores, { "DSP101", "0001", OemToAnsi(STR0102),  14		, TIPO_CHAR ,"99.999.999/9999-99", "1", "txtInscrD",  "1"  ,  "1" , "F761WhenCtr()", "" ,"F761VCGC('C0001')"} ) //"Favorecido do Contrato"
	AAdd( aValores, { "DSP101", "0002", OemToAnsi(STR0021),  6		, TIPO_CHAR , "99999-9"		 	, "1", "txtInscrE",  "1"  ,  "1" , "F761WhenCtr(.T.)", "" ,""} ) //"Código de Recolhimento GRU"
	AAdd( aValores, { "DSP101", "0003", OemToAnsi(STR0105), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"Conta de Estoque"
	AAdd( aValores, { "DSP101", "0004", OemToAnsi(STR0103), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0004')"} ) //"Contas a Pagar"
	AAdd( aValores, { "DSP101", "0005", OemToAnsi(STR0070), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassD",  "1"  ,  "2" , "F761WhenCtr()", "CT1" ,"F761VCT1('C0005')"} ) //"Conta de Contrato"
	
	AAdd( aValores, { "DSP102", "0001", OemToAnsi(STR0102),  14		, TIPO_CHAR ,"99.999.999/9999-99", "1", "txtInscrD",  "1"  ,  "1" , "F761WhenCtr()", "" ,"F761VCGC('C0001')"} ) //"Favorecido do Contrato" 
	AAdd( aValores, { "DSP102", "0002", OemToAnsi(STR0021),  6		, TIPO_CHAR , "99999-9"		 	, "1", "txtInscrE",  "1"  ,  "1" , "F761WhenCtr(.T.)", "" ,""} ) //"Código de Recolhimento GRU" 
	AAdd( aValores, { "DSP102", "0003", OemToAnsi(STR0095), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"Variação Patrimonial Diminutiva"
	AAdd( aValores, { "DSP102", "0004", OemToAnsi(STR0103), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0004')"} ) //"Contas a Pagar"
	AAdd( aValores, { "DSP102", "0005", OemToAnsi(STR0105), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassC",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0005')"} ) //"Conta de Estoque"
	AAdd( aValores, { "DSP102", "0006", OemToAnsi(STR0070), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassD",  "1"  ,  "2" , "F761WhenCtr()", "CT1" ,"F761VCT1('C0006')"} ) //"Conta de Contrato"
	
	AAdd( aValores, { "DSP201", "0001", OemToAnsi(STR0102),  14		, TIPO_CHAR ,"99.999.999/9999-99", "1", "txtInscrE",  "1"  ,  "1" , "F761WhenCtr()", "" ,"F761VCGC('C0001')"} ) //"Favorecido do Contrato"
	AAdd( aValores, { "DSP201", "0002", OemToAnsi(STR0021),  6		, TIPO_CHAR , "99999-9"		 	, "1", "txtInscrD",  "1"  ,  "1" , "F761WhenCtr(.T.)", "" ,""} ) //"Código de Recolhimento GRU"
	AAdd( aValores, { "DSP201", "0003", OemToAnsi(STR0106), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"Conta de Bens Móveis"
	AAdd( aValores, { "DSP201", "0004", OemToAnsi(STR0103), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0004')"} ) //"Contas a Pagar"
	AAdd( aValores, { "DSP201", "0005", OemToAnsi(STR0070), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassD",  "1"  ,  "2" , "F761WhenCtr()", "CT1" ,"F761VCT1('C0005')"} ) //"Conta de Contrato"
	                                                                            
	AAdd( aValores, { "DSP215", "0001", OemToAnsi(STR0021),  6		, TIPO_CHAR , "99999-9"		 	, "1", "txtInscrD",  "1"  ,  "1" , "F761WhenCtr(.T.)", "" ,""} ) //"Código de Recolhimento GRU"
	AAdd( aValores, { "DSP215", "0002", OemToAnsi(STR0102),  14		, TIPO_CHAR ,"99.999.999/9999-99", "1", "txtInscrE",  "1"  ,  "1" , "F761WhenCtr()", "" ,"F761VCGC('C0002')"} ) //"Favorecido do Contrato"
	AAdd( aValores, { "DSP215", "0003", OemToAnsi(STR0107), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"Bem Intangível"
	AAdd( aValores, { "DSP215", "0004", OemToAnsi(STR0103), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0004')"} ) //"Contas a Pagar"
	AAdd( aValores, { "DSP215", "0005", OemToAnsi(STR0070), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassE",  "1"  ,  "2" , "F761WhenCtr()", "CT1" ,"F761VCT1('C0005')"} ) //"Conta de Contrato"
	                                                                            
	AAdd( aValores, { "DSP901", "0001", OemToAnsi(STR0021),  6		, TIPO_CHAR , "99999-9"		 	, "1", "txtInscrD",  "1"  ,  "1" , "F761WhenCtr(.T.)", "" ,""} ) //"Código de Recolhimento GRU"
	AAdd( aValores, { "DSP901", "0002", OemToAnsi(STR0108), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"Indenizações e Restituições a Pagar"
	                                                                            
	AAdd( aValores, { "DSP925", "0001", OemToAnsi(STR0102),  14		, TIPO_CHAR ,"99.999.999/9999-99", "1", "txtInscrE",  "1"  ,  "1" , "F761WhenCtr()", "" ,"F761VCGC('C0001')"} ) //"Favorecido do Contrato" 
	AAdd( aValores, { "DSP925", "0002", OemToAnsi(STR0236), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"Depósito p/ Recursos Judiciais" 
	AAdd( aValores, { "DSP925", "0003", OemToAnsi(STR0103), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassC",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"Contas a Pagar" 
	AAdd( aValores, { "DSP925", "0004", OemToAnsi(STR0070), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassD",  "1"  ,  "2" , "F761WhenCtr()", "CT1" ,"F761VCT1('C0004')"} ) //"Conta de Contratos" 
	                                                                            
	AAdd( aValores, { "DSP975", "0001", OemToAnsi(STR0021),  6		, TIPO_CHAR , "99999-9"		 	, "1", "txtInscrD",  "1"  ,  "1" , "F761WhenCtr(.T.)", "" ,""} ) //"Código de Recolhimento GRU" 
	AAdd( aValores, { "DSP975", "0002", OemToAnsi(STR0102),  14		, TIPO_CHAR ,"99.999.999/9999-99", "1", "txtInscrE",  "1"  ,  "1" , "F761WhenCtr()", "" ,"F761VCGC('C0002')"} ) //"Favorecido do Contrato" 
	AAdd( aValores, { "DSP975", "0003", OemToAnsi(STR0237), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"VPD - Juros/Encargos de mora" 
	AAdd( aValores, { "DSP975", "0004", OemToAnsi(STR0103), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0004')"} ) //"Contas a Pagar" 
	AAdd( aValores, { "DSP975", "0005", OemToAnsi(STR0070), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassD",  "1"  ,  "2" , "F761WhenCtr()", "CT1" ,"F761VCT1('C0005')"} ) //"Conta de Contratos" 
	                                                                            
	AAdd( aValores, { "DVL001", "0001", OemToAnsi(STR0121),  3		, TIPO_CHAR , ""		 			, "1", "txtInscrD",  "1"  ,  "1" , "", "" ,""} ) //"Vinculação de Pagamento" 
	AAdd( aValores, { "DVL001", "0002", OemToAnsi(STR0102),  14		, TIPO_CHAR ,"99.999.999/9999-99", "1", "txtInscrE",  "1"  ,  "1" , "F761WhenCtr()", "CT1" ,"F761VCGC('C0002')"} ) //"Favorecido do Contrato" 
	AAdd( aValores, { "DVL001", "0003", OemToAnsi(STR0238), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"VPD de Serviço Pessoas Jurídicas" 
	AAdd( aValores, { "DVL001", "0004", OemToAnsi(STR0232), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0004')"} ) //"Conta de Passivo" 
	AAdd( aValores, { "DVL001", "0005", OemToAnsi(STR0070), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassE",  "1"  ,  "2" , "F761WhenCtr()", "CT1" ,"F761VCT1('C0005')"} ) //"Conta de Contrato" 
	                                                                            
	AAdd( aValores, { "DVL081", "0001", OemToAnsi(STR0121),  3		, TIPO_CHAR , ""		 		 	, "1", "txtInscrD",  "1"  ,  "1" , "", "" ,""} ) //"Vinculação de Pagamento" 
	                                                                            
	AAdd( aValores, { "DVL973", "0001", OemToAnsi(STR0121),  3		, TIPO_CHAR , ""		 		 	, "1", "txtInscrD",  "1"  ,  "1" , "", "" ,""} ) //"Vinculação de Pagamento" 
	AAdd( aValores, { "DVL973", "0002", OemToAnsi(STR0102),  14		, TIPO_CHAR ,"99.999.999/9999-99", "1", "txtInscrE",  "1"  ,  "1" , "F761WhenCtr()", "" ,"F761VCGC('C0002')"} ) //"Favorecido do Contrato" 
	AAdd( aValores, { "DVL973", "0003", OemToAnsi(STR0239), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"VPD de Juros/Encargos de Mora" 
	AAdd( aValores, { "DVL973", "0004", OemToAnsi(STR0232), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0004')"} ) //"Conta de Passivo" 
	AAdd( aValores, { "DVL973", "0005", OemToAnsi(STR0070),  9  	, TIPO_CHAR , cPicCT1			, "1", "numClassE",  "1"  ,  "2" , "F761WhenCtr()", "CT1" ,"F761VCT1('C0005')"} ) //"Conta de Contrato" 
	                                                                            
	AAdd( aValores, { "ENC001", "0001", OemToAnsi(STR0029),  4		, TIPO_CHAR , "9999"           	, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"Código de Pagamento GPS"
	AAdd( aValores, { "ENC001", "0002", OemToAnsi(STR0109),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"VPD de Encargos Patronais"
	AAdd( aValores, { "ENC001", "0003", OemToAnsi(STR0110),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"Encargos de INSS a Pagar"
	AAdd( aValores, { "ENC001", "0004", OemToAnsi(STR0029),  4		, TIPO_CHAR , "9999"           	, "1", "txtInscrA",  "1"  ,  "2" , "", "" ,""} ) //"Código de Pagamento GPS"	
	                                                                            
	AAdd( aValores, { "ENC002", "0001", OemToAnsi(STR0240),  3		, TIPO_CHAR , ""	           	, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"Código de Recolhimento GFIP" 
	AAdd( aValores, { "ENC002", "0002", OemToAnsi(STR0241),  14		, TIPO_CHAR , "99.999.999/9999-99", "1", "txtInscrB",  "1"  ,  "1" , "", "" ,"F761VCGC('C0002')"} ) //"Credor da GFIP" 
	AAdd( aValores, { "ENC002", "0003", OemToAnsi(STR0242),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"VPD de FGTS" 
	                                                                            
	AAdd( aValores, { "ENC004", "0001", OemToAnsi(STR0069),  4		, TIPO_CHAR , "9999"           	, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"Código de Recolhimento DARF" 
	AAdd( aValores, { "ENC004", "0002", OemToAnsi(STR0243),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"VPD com Imposto de Renda" 
	AAdd( aValores, { "ENC004", "0003", OemToAnsi(STR0244),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"IRPJ a Recolher" 
	                                                                            
	AAdd( aValores, { "ENC005", "0001", OemToAnsi(STR0069),  4		, TIPO_CHAR , "9999"           	, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"Código de Recolhimento DARF" 
	AAdd( aValores, { "ENC005", "0002", OemToAnsi(STR0245),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"VPD de PIS/PASEP" 
	AAdd( aValores, { "ENC005", "0003", OemToAnsi(STR0246),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"PIS/PASEP a Recolher" 
	                                                                            
	AAdd( aValores, { "ENC011", "0001", OemToAnsi(STR0069),  4		, TIPO_CHAR , "9999"           	, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"Código DARF"
	AAdd( aValores, { "ENC011", "0002", OemToAnsi(STR0109),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"VPD de Encargos Patronais"
	AAdd( aValores, { "ENC011", "0003", OemToAnsi(STR0069),  4		, TIPO_CHAR , "9999"           	, "1", "txtInscrA",  "1"  ,  "2" , "", "" ,""} ) //"Código DARF"
	                                                                            
	AAdd( aValores, { "ENC014", "0001", OemToAnsi(STR0247),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0001')"} ) //"VPD com Encargos Patronais - Prev. Privada e Assit. Médica Hospitalar" 
	AAdd( aValores, { "ENC014", "0002", OemToAnsi(STR0248),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"Encargos de Previdencia Privada a Recolher" 
	                                                                            
	AAdd( aValores, { "ENC015", "0001", OemToAnsi(STR0111),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0001')"} ) //"VPD com Encargos Patronais - FUNPRESP"
	AAdd( aValores, { "ENC015", "0002", OemToAnsi(STR0112),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"Encargos Patronais a recolher - FUNPRESP"
	                                                                            
	AAdd( aValores, { "ENC021", "0001", OemToAnsi(STR0069),  4		, TIPO_CHAR , "9999"           	, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"Código de Recolhimento DARF" 
	AAdd( aValores, { "ENC021", "0002", OemToAnsi(STR0249),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"VPD com Encargos Tributários com a União" 
	AAdd( aValores, { "ENC021", "0003", OemToAnsi(STR0250),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"Encargos Tributários com a União a recolher" 
	                                                                            
	AAdd( aValores, { "ENC022", "0001", OemToAnsi(STR0251),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0001')"} ) //"VPD com Encargos Tributários com União, Estados ou Municipios - Recolh. OB/GRU" 
	AAdd( aValores, { "ENC022", "0002", OemToAnsi(STR0252),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"Encargos Tributários com União, Estados ou Municipios - Recolh.OB/GRU a recolher" 
                                                                                
	AAdd( aValores, { "ENC024", "0001", OemToAnsi(STR0029),  4		, TIPO_CHAR , "9999"           	, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"Código de Pagamento GPS" 
	AAdd( aValores, { "ENC024", "0002", OemToAnsi(STR0253),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"VPD com Encargos Patronais sobre serviços de terceiros" 
	AAdd( aValores, { "ENC024", "0003", OemToAnsi(STR0254),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"Encargos Patronais sobre serviços de terceiros a recolher" 
	                                                                            
	AAdd( aValores, { "ENC028", "0001", OemToAnsi(STR0021),  6		, TIPO_CHAR , "99999-9"        	, "1", "txtInscrA",  "1"  ,  "1" , "F761WhenCtr(.T.)", "" ,""} ) //"Código de Recolhimento GRU" 
	AAdd( aValores, { "ENC028", "0002", OemToAnsi(STR0255),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"VPD de Contribuições Sociais" 
	AAdd( aValores, { "ENC028", "0003", OemToAnsi(STR0256),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"Obrigações Fiscais a Recolher" 
	
	AAdd( aValores, { "ETQ001", "0001", OemToAnsi(STR0257),  2		, TIPO_CHAR , ""				   	, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"Subitem da Despesa" 
	AAdd( aValores, { "ETQ001", "0002", OemToAnsi(STR0258),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"Estoque de Materiais" 
	AAdd( aValores, { "ETQ001", "0003", OemToAnsi(STR0259),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"VPD de Consumo de Materiais/Distribuição" 
	
	AAdd( aValores, { "ETQ027", "0001", OemToAnsi(STR0257),  12		, TIPO_CHAR , ""				   	, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"Subitem da Despesa" 
	AAdd( aValores, { "ETQ027", "0002", OemToAnsi(STR0260),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"Conta de Estoque transferidora" 
	AAdd( aValores, { "ETQ027", "0003", OemToAnsi(STR0261),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"Conta de Estoque recebedora" 
	
	AAdd( aValores, { "IMB070", "0001", OemToAnsi(STR0262),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0001')"} ) //"Bem Móveis de Referência" 
	
	AAdd( aValores, { "IMB071", "0001", OemToAnsi(STR0263),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0001')"} ) //"Bem Imóveis de Referência" 
	
	AAdd( aValores, { "INT001", "0001", OemToAnsi(STR0264),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0001')"} ) //"Amortização Acumulada" 
	AAdd( aValores, { "INT001", "0002", OemToAnsi(STR0265),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"Bem Intangível de Referência" 
	
	AAdd( aValores, { "LDV011", "0001", OemToAnsi(STR0102),  12		, TIPO_CHAR ,"99.999.999/9999-99", "1", "txtInscrB",  "1"  ,  "1" , "F761WhenCtr()", "" ,"F761VCGC('C0001')"} ) //"Favorecido do Contrato" 
	AAdd( aValores, { "LDV011", "0002", OemToAnsi(STR0070),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "F761WhenCtr()", "CT1" ,"F761VCT1('C0002')"} ) //"Conta de Contrato" 

  	AAdd( aValores, { "LDV051", "0001", OemToAnsi(STR0208),  12		, TIPO_CHAR , ""				   	, "1", "txtInscrB",  "1"  ,  "1" , "", "" ,""} ) //"CNPJ, CPF, UG, IG OU 999" 
	AAdd( aValores, { "LDV051", "0002", OemToAnsi(STR0266),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"Responsabilidades com Terceiros" 
	
	AAdd( aValores, { "LDV052", "0001", OemToAnsi(STR0208),  12		, TIPO_CHAR , ""				   	, "1", "txtInscrB",  "1"  ,  "1" , "", "" ,""} ) //"CNPJ, CPF, UG, IG OU 999" 
	AAdd( aValores, { "LDV052", "0002", OemToAnsi(STR0266),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"Responsabilidades com Terceiros" 
	
	AAdd( aValores, { "LDV053", "0001", OemToAnsi(STR0208),  12		, TIPO_CHAR , ""				   	, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"CNPJ, CPF, UG, IG OU 999" 
	AAdd( aValores, { "LDV053", "0002", OemToAnsi(STR0267),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"Execução de Garantias/Contragarantias Recebidas" 
	
	AAdd( aValores, { "LPA301", "0001", OemToAnsi(STR0268),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0001')"} ) //"Pessoal ou Encargos a Pagar" 
	AAdd( aValores, { "LPA301", "0002", OemToAnsi(STR0095),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"Variação Patrimonial Diminutiva" 
	
	AAdd( aValores, { "LPA331", "0001", OemToAnsi(STR0095),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0001')"} ) //"Variação Patrimonial Diminutiva" 
	AAdd( aValores, { "LPA331", "0002", OemToAnsi(STR0232),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"Conta de Passivo" 
				
	AAdd( aValores, { "PRV001", "0001", OemToAnsi(STR0113),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "1" , "", "CT1" ,"F761VCT1('C0001')"} ) //"VPD com 13 Salário"
	AAdd( aValores, { "PRV001", "0002", OemToAnsi(STR0114),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "1" , "", "CT1" ,"F761VCT1('C0002')"} ) //"13 Salário a Pagar"
	
	AAdd( aValores, { "PRV002", "0001", OemToAnsi(STR0115),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "1" , "", "CT1" ,"F761VCT1('C0001')"} ) //"VPD com Férias"
	AAdd( aValores, { "PRV002", "0002", OemToAnsi(STR0116),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "1" , "", "CT1" ,"F761VCT1('C0002')"} ) //"Férias a Pagar"
	
	AAdd( aValores, { "PRV003", "0001", OemToAnsi(STR0113),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "1" , "", "CT1" ,"F761VCT1('C0001')"} ) //"VPD com 13 Salário"
	AAdd( aValores, { "PRV003", "0002", OemToAnsi(STR0114),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "1" , "", "CT1" ,"F761VCT1('C0002')"} ) //"13 Salário a Pagar"
	
	AAdd( aValores, { "PRV004", "0001", OemToAnsi(STR0117),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "1" , "", "CT1" ,"F761VCT1('C0001')"} ) //"Conta de Precatórios"
	
	AAdd( aValores, { "PRV005", "0001", OemToAnsi(STR0081),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "1" , "", "CT1" ,"F761VCT1('C0001')"} ) //"Adiantamento Pessoal"
	
	AAdd( aValores, { "PRV006", "0001", OemToAnsi(STR0118),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "1" , "", "CT1" ,"F761VCT1('C0001')"} ) //"Pessoal a Pagar"
	
	AAdd( aValores, { "PRV007", "0001", OemToAnsi(STR0119),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "1" , "", "CT1" ,"F761VCT1('C0001')"} ) //"Obrigações"
	AAdd( aValores, { "PRV007", "0002", OemToAnsi(STR0120),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "1" , "", "CT1" ,"F761VCT1('C0002')"} ) //"VPD"
	
	AAdd( aValores, { "PSO001", "0001", OemToAnsi(STR0021),  6		, TIPO_CHAR , "99999-9"        	, "1", "txtInscrA",  "1"  ,  "2" , "F761WhenCtr(.T.)", "" ,""} ) //"Código de Recolhimento GRU"
		
	AAdd( aValores, { "PSO002", "0001", OemToAnsi(STR0082),  14		, TIPO_CHAR , ""               	, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"Número da Ordem Bancária Cancelada (OB)"
	AAdd( aValores, { "PSO002", "0002", OemToAnsi(STR0021),  6		, TIPO_CHAR , "99999-9"        	, "1", "txtInscrB",  "1"  ,  "1" , "F761WhenCtr(.T.)", "" ,""} ) //"Código de Recolhimento GRU"

	AAdd( aValores, { "PSO006", "0001", OemToAnsi(STR0021),  6		, TIPO_CHAR , "99999-9"        	, "1", "txtInscrA",  "1"  ,  "2" , "F761WhenCtr(.T.)", "" ,""} ) //"Código de Recolhimento GRU"
	AAdd( aValores, { "PSO006", "0002", OemToAnsi(STR0028),  14		, TIPO_CHAR , ""               	, "1", "txtInscrB",  "1"  ,  "2" , "", "" ,""} ) //"Fonte de Recurso"	
	AAdd( aValores, { "PSO006", "0003", OemToAnsi(STR0121),  3 		, TIPO_CHAR , ""               	, "1", "txtInscrC",  "1"  ,  "2" , "", "" ,""} ) //"Vinculação de Pagamento"
	AAdd( aValores, { "PSO006", "0004", OemToAnsi(STR0122),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0001')"} ) //"Classificação da Receita"
	
	AAdd( aValores, { "PSO023", "0001", OemToAnsi(STR0021),  6		, TIPO_CHAR , "99999-9"        	, "1", "txtInscrA",  "1"  ,  "1" , "F761WhenCtr(.T.)", "" ,""} ) //"Código de Recolhimento GRU" 
	AAdd( aValores, { "PSO023", "0002", OemToAnsi(STR0269),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"Depósitos diversos" 
	
	AAdd( aValores, { "PSO030", "0001", OemToAnsi(STR0270),  1		, TIPO_CHAR , ""				   	, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"Tipo de Arrecadaçao" 
	AAdd( aValores, { "PSO030", "0002", OemToAnsi(STR0271),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"ISS a Recolher" 
	AAdd( aValores, { "PSO030", "0003", OemToAnsi(STR0203),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"Classificação Orçamentária da Receita" 
	
	AAdd( aValores, { "PSO042", "0001", OemToAnsi(STR0272),  9		, TIPO_CHAR , ""				   	, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"Conta-corrente da conta Depósito" 
	AAdd( aValores, { "PSO042", "0002", OemToAnsi(STR0021),  6		, TIPO_CHAR , "99999-9"			, "1", "txtInscrD",  "1"  ,  "1" , "F761WhenCtr(.T.)", "" ,""} ) //"Código de Recolhimento GRU" 
	AAdd( aValores, { "PSO042", "0003", OemToAnsi(STR0273),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"Depósito de Diversas Origens" 
	
	AAdd( aValores, { "PSO045", "0001", OemToAnsi(STR0069),  4		, TIPO_CHAR , "9999"				, "1", "txtInscrD",  "1"  ,  "1" , "", "" ,""} ) //"Código de Recolhimento DARF" 
	AAdd( aValores, { "PSO045", "0002", OemToAnsi(STR0274),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"Obrigações a Recolher" 
	AAdd( aValores, { "PSO045", "0003", OemToAnsi(STR0275),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"Conta de VPD Tributária" 
	
	AAdd( aValores, { "SPE003", "0001", OemToAnsi(STR0124),  12		, TIPO_CHAR , ""					, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"Empenho para Estorno"
	AAdd( aValores, { "SPE003", "0002", OemToAnsi(STR0125),  14		, TIPO_CHAR , ""					, "1", "txtInscrB",  "1"  ,  "1" , "", "" ,""} ) //"Subitem para Estorno"	
	AAdd( aValores, { "SPE003", "0003", OemToAnsi(STR0126),  14 	, TIPO_CHAR , ""					, "1", "txtInscrC",  "1"  ,  "1" , "", "" ,""} ) //"Agente Suprido ou 999"
	
	AAdd( aValores, { "SPN003", "0001", OemToAnsi(STR0127),  12		, TIPO_CHAR , ""					, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"Novo Empenho"
	AAdd( aValores, { "SPN003", "0002", OemToAnsi(STR0128),  14		, TIPO_CHAR , ""					, "1", "txtInscrB",  "1"  ,  "1" , "", "" ,""} ) //"Novo Subitem"	
	AAdd( aValores, { "SPN003", "0003", OemToAnsi(STR0095),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassC",  "1"  ,  "1" , "", "CT1","F761VCT1('C0003')" } ) //"Variação Patrimonial Diminutiva"
	
	cFilTab := FWxFilial( cAliasTab )
	aAreaTab := &(cAliasTab)->( GetArea() )
	&(cAliasTab)->( dbSetOrder( 1 ) )
	For nI := 1 To Len( aValores )
		cChave := cFilTab + PadR( aValores[nI][3], nTamSit ) + PadR( aValores[nI][4], nTamID )
		If &(cAliasTab)->( !MsSeek( cChave ) )
			RecLock( cAliasTab, .T. )
			&(cAliasTab)->(FV4_FILIAL) := cFilTab
			&(cAliasTab)->(FV4_SITUAC) := aValores[nI][1]
			&(cAliasTab)->(FV4_IDCAMP) := aValores[nI][2]
			&(cAliasTab)->(FV4_DSCAMP) := aValores[nI][3]
			&(cAliasTab)->(FV4_TAMCAM) := aValores[nI][4]
			&(cAliasTab)->(FV4_TPCAMP) := aValores[nI][5]
			&(cAliasTab)->(FV4_PICCAM) := aValores[nI][6]
			&(cAliasTab)->(FV4_OBGCAM) := aValores[nI][7]
			&(cAliasTab)->(FV4_CSPCAM) := aValores[nI][12]
			&(cAliasTab)->(FV4_TAGXML) := aValores[nI][8]
			&(cAliasTab)->(FV4_STATUS) := aValores[nI][9]			
			&(cAliasTab)->(FV4_LOCAL)  := aValores[nI][10]
			&(cAliasTab)->(FV4_WHEN)   := aValores[nI][11]
			&(cAliasTab)->(FV4_VALID)  := aValores[nI][13]
			&(cAliasTab)->( MsUnLock() )
		EndIf
	Next nI	
	&(cAliasTab)->( RestArea( aAreaTab ) )
Return Nil

/*/{Protheus.doc} FiltraFVJ
Função para montar o filtro da consulta padrão de situação 

@return cRet, String com a expressão que será considerada no filtro    

@author Pedro Alencar	
@since 23/10/2014
@version P12.1.2
/*/
Function FiltraFVJ()
	Local aAreaFVK	:= FVK->( GetArea() )		
	Local cSec		:= ""
	Local cFilFVK	:= FWxFilial("FVK")
	Local cRet		:= ""
	Local cField	:= ReadVar()
	Local cTipoDc	:= M->FV0_TIPODC

	If "FV2" $ cField //Folder 0002 - Principal com Orçamento
		cSec := "000002"
	ElseIf "FV8" $ cField //Folder 0003 - Principal sem Orçamento 
		cSec := "000003"
	ElseIf "FV9" $ cField //Folder 0003 - Principal sem Orçamento 
		cSec := "000003"
	ElseIf "FVF" $ cField //Folder 0004 - Créditos 
		cSec := "000004"
	ElseIf "FVA" $ cField //Folder 0005 - Outros Lançamentos
		cSec := "000005"
	ElseIf "FVB" $ cField //Folder 0007 - Encargos
		cSec := "000007"
	ElseIf "FVD" $ cField //Folder 0006 - Deduções 
		cSec := "000006"
	ElseIf "FVL" $ cField //Folder 0008 - Despesa a Anular
		cSec := "000008"		
	Else 
		cSec := ""
		
		//Limpa a variável estática para não filtrar nada
		__cSituac := ""		
	EndIf  
	
	If !Empty( cSec ) .And. !Empty(cTipoDc)
		//Se for a mesma seção utilizada na última consulta, filtra com base nas situações que já estão no vetor estático 
		If cSec <> __cSecAnt .Or. cTipoDc <> __cTipoDc  						
			//Se for uma seção diferente, lê a tabela novamente para pegar as situações a serem filtradas
			__cSituac := ""
			FVK->( dbSetOrder( 1 ) ) //Filial + Tipo Doc + Seção + Situação
			If FVK->( msSeek( cFilFVK + cTipoDc + cSec ) )
				While FVK->( !EOF() ) .AND. FVK->FVK_FILIAL == cFilFVK .AND. FVK->FVK_SECAO == cSec .AND. FVK->FVK_TIPODC == cTipoDc
					__cSituac += Iif( Empty(__cSituac), FVK->FVK_SITUAC, "|" + FVK->FVK_SITUAC )
					FVK->( dbSkip() )
				EndDo
			Endif
			FVK->( RestArea( aAreaFVK ) )
			__cSecAnt := cSec
			__cTipoDc := cTipoDc		
		Endif
	Endif
	
	cRet := Iif( Empty(__cSituac), "", "FVJ->FVJ_ID $ '" + __cSituac + "'" )
Return cRet

/*/{Protheus.doc} FinGrvBx
Função para efetuar a baixa/estorno de titulos a pagar e receber via execauto
A filial logada deve ser a correspondente a unidade pagadora

@author Pamela Bernardo Sousa
@param nCart  parametro define se a baixa/estorno será a pagar ou a receber
	1 = define carteira a receber
	2 = define carteira a pagar
@param cChave  Chave do titulo para baixa/estorno. 
				Esta chave deve conter xFilial() da filial de origem já que o titulo pode ter uma unidade pagadora
				diferente da unidade original.
@param nOpc  Defino se o movimento será de baixa ou estorno.
3 = Baixa.
5 = Estorno.
@param aBanco Vetor com os dados 
	[1] = BANCO
	[2] = AGENCIA
	[3] = CONTA
@param aVlr vetor com valores de baixa
	[1] = Valor da baixa
	[2] = Juros
	[3] = Multa
	[4] = Desconto
	
@param cMotbx  Motivo de baixa
 ------------------

@since 08/12/2014
@version P12.1.3
/*/
Function FinGrvBx(nCart, cDocHabil, cChave, nOpc, aBanco, aVlr, cMotbx, cTitPai)
	Local lRet			:=  .T.
	Local aVetor			:= {}
	Local cFilAtu			:= cFilAnt
	Local cHistorico		:= ""
	Local bBloqVld		:= ""
	Local aArea			:= GetArea()
	Local aSE2Area		:= {}
	Local aSE1Area		:= {}
	
	Private lMsErroAuto  := .F.
	Private lMsHelpAuto  := .T.
	Private lMostraErro  := .F.
	
	Default nCart			:= 2
	Default cDocHabil		:= cDocHabil
	Default cChave		:= ""
	Default nOpc			:= 3
	Default aBanco		:= {}
	Default aVlr			:= {}
	Default cMotbx		:= "DEB"
	
	If nOpc == 3
		cHistorico := STR0090 + " " + cDocHabil // "Realização de documento habil "
	Else
		cHistorico := STR0132 + " " + cDocHabil // "Cancelamento de Documento Hábil"
	EndIf 
	
	If nCart == 1
		lMsErroAuto := .F.
		dbSelectArea( "SE1" ) // Título a Receber
		aSE1Area := SE1->(GetArea())
		SE1->(dbSetOrder(1)) // Filial + Prefixo + Número + Parcela + Tipo 
		
		If SE1->(MsSeek(cChave))
			AADD(aVetor,{"E1_FILIAL"	, SE1->E1_FILIAL 		,Nil})
			AADD(aVetor,{"E1_PREFIXO"	, SE1->E1_PREFIXO 	,Nil})
			AADD(aVetor,{"E1_NUM"		, SE1->E1_NUM       	,Nil})
			AADD(aVetor,{"E1_PARCELA"	, SE1->E1_PARCELA  	,Nil})
			AADD(aVetor,{"E1_TIPO"		, SE1->E1_TIPO     	,Nil})
			AADD(aVetor,{"E1_CLIENTE"	, SE1->E1_CLIENTE  	,Nil})
			AADD(aVetor,{"E1_LOJA"		, SE1->E1_LOJA     	,Nil})
			AADD(aVetor,{"E1_NATUREZA"	, SE1->E1_NATUREZA 	,Nil})		
			AADD(aVetor,{"AUTMOTBX"	, cMotbx            	,Nil})
			AADD(aVetor,{"AUTDTBAIXA"	, dDataBase			,Nil})
			AADD(aVetor,{"AUTDTDEB"	, dDataBase			,Nil})
			AADD(aVetor,{"AUTHIST"		, cHistorico			,Nil})
			
			If Len(aBanco) > 0
				AADD(aVetor,{"AUTBANCO",aBanco[1],NIL}) //Banco
				AADD(aVetor,{"AUTAGENCIA",aBanco[2],NIL}) //agencia
				AADD(aVetor,{"AUTCONTA",aBanco[3],NIL}) //Conta
			EndIf
	
			If Len(aVlr) > 0
				If aVlr[1] == 0
					AADD(aVetor,{"AUTVLRPG",SE1->E1_SALDO,NIL}) //Valor de pagamento	
				Else
					AADD(aVetor,{"AUTVLRPG",aVlr[1],NIL}) //Valor de pagamento
				EndIf
				
				AADD(aVetor,{"AUTJUROS",aVlr[2],NIL}) 	//Valor de Juros Pagos (AUTJUROS)
				AADD(aVetor,{"AUTMULTA",aVlr[3],NIL})  //Valor da Multa Paga  (AUTMULTA)
				AADD(aVetor,{"AUTDESCONT",aVlr[4],NIL})//Valor da Desconto Paga  (AUTDESCONT)	
			EndIf
			
			MSExecAuto({|x,y| Fina070(x,y)},aVetor,nOpc)
			
			//Em caso de erro na baixa desarma a transacao
			If lMsErroAuto 
				lRet:= .F.
				If !IsBlind()
					MOSTRAERRO() //Sempre que o micro comeca a apitar esta ocorrendo um erro desta forma
				EndIf
			Endif
		Endif
		RestArea(aSE1Area)
	Else
		lMsErroAuto := .F.
		dbSelectArea( "SE2" ) // Título a Pagar
		aSE2Area := SE2->(GetArea())
		
		SE2->(dbSetOrder(1)) // Filial + Prefixo + Número + Parcela + Tipo + Fornecedor + Loja
		
		If SE2->(MsSeek(cChave))
			bBloqVld := "SE2->E2_FILIAL + SE2->E2_PREFIXO + SE2->E2_NUM + SE2->E2_PARCELA + SE2->E2_TIPO"
			If EMPTY(cTitPai)
				bBloqVld += " + SE2->E2_FORNECE + SE2->E2_LOJA "
			EndIf

			While SE2->(!Eof()) .AND.  &bBloqVld == cChave .AND. Iif(!EMPTY(cTitPai),AllTrim(SE2->E2_FILIAL + SE2->E2_TITPAI) == cTitPai,.T.)
				AADD(aVetor,{"E2_FILIAL"	, SE2->E2_FILIAL 		,Nil})
				AADD(aVetor,{"E2_PREFIXO"	, SE2->E2_PREFIXO 	,Nil})
				AADD(aVetor,{"E2_NUM"		, SE2->E2_NUM       	,Nil})
				AADD(aVetor,{"E2_PARCELA"	, SE2->E2_PARCELA  	,Nil})
				AADD(aVetor,{"E2_TIPO"		, SE2->E2_TIPO     	,Nil})
				AADD(aVetor,{"E2_FORNECE"	, SE2->E2_FORNECE  	,Nil})
				AADD(aVetor,{"E2_LOJA"		, SE2->E2_LOJA     	,Nil})
				AADD(aVetor,{"E2_NATUREZ"	, SE2->E2_NATUREZ 	,Nil})
				AADD(aVetor,{"AUTMOTBX"	, cMotbx            	,Nil})
				AADD(aVetor,{"AUTDTBAIXA"	, dDataBase			,Nil})
				AADD(aVetor,{"AUTDTDEB"	, dDataBase			,Nil})
				AADD(aVetor,{"AUTHIST"		, cHistorico			,Nil})		
				
				If Len(aBanco) > 0
					AADD(aVetor,{"AUTBANCO",aBanco[1],NIL}) //Banco
					AADD(aVetor,{"AUTAGENCIA",aBanco[2],NIL}) //agencia
					AADD(aVetor,{"AUTCONTA",aBanco[3],NIL}) //Conta
				EndIf
		
				If Len(aVlr) > 0
					If aVlr[1] == 0
						AADD(aVetor,{"AUTVLRPG",SE2->E2_SALDO,NIL}) //Valor de pagamento	
					Else
						AADD(aVetor,{"AUTVLRPG",aVlr[1],NIL}) //Valor de pagamento
					EndIf
					AADD(aVetor,{"AUTJUROS",aVlr[2],NIL}) 	//Valor de Juros Pagos (AUTJUROS)
					AADD(aVetor,{"AUTMULTA",aVlr[3],NIL})  //Valor da Multa Paga  (AUTMULTA)
					AADD(aVetor,{"AUTDESCONT",aVlr[4],NIL})//Valor da Desconto Paga  (AUTDESCONT)
				EndIf
				
				MSExecAuto({|x,y| Fina080(x,y)},aVetor,nOpc)
				
				//Em caso de erro na baixa desarma a transacao
				If lMsErroAuto 
					lRet := .F.
					If !IsBlind()
						MOSTRAERRO() //Sempre que o micro comeca a apitar esta ocorrendo um erro desta forma
					EndIf
					Exit
					Exit
				EndIf
				SE2->(DbSkip())
			EndDo
		EndIf
		RestArea(aSE2Area)
	EndIf
	RestArea(aArea)
Return lRet

/*/{Protheus.doc} FinUsaDH()
Função para validar o documento hábil (SIAFI) está habilitado 

@return lRet 	retorno lógico de validação do uso ou não do documento hábil    

@author Mauricio Pequim Junior
@since 27/11/2014
@version P12.1.3
/*/
Function FinUsaDH()
	//Verifica se uso do documento hábil (SIAFI) está habilitado
	If __lUsaDH == NIL
		__lUsaDH := SuperGetmv("MV_USADH",,'2') == '1'
	Endif
Return __lUsaDH

/*/{Protheus.doc} FinTemDH()
Função para validar se um titulo está relacionado a um documento hábil 

@param lFiltro	Indica se a rotina deve retornar uma expressao de filtro ou valor lógico para validação
@param cAlias	Alias a ser considerado para validação ou filtro
@param lHelp	Indica se o help será mostrado ou não
@param lTop		Indica se a expressão de filtro deve ser no padrão codebase (.F.) ou SQL (.T.)

@return xRet 	String com a expressão que será considerada no filtro ou retorno lógico de validação    

@author Mauricio Pequim Junior
@since 27/11/2014
@version P12.1.3
/*/
Function FinTemDH(lFiltro,cAlias, lHelp, lTop)
	Local xRet := ""
	
	Default lFiltro := .F.
	Default cAlias  := "SE2"
	Default lHelp   := .T.
	Default lTop    := .T.
	
	If FinUsaDH()
		//Se for um filtro
		If lFiltro
			If lTop
				xRet := " AND E2_DOCHAB = '" + Space(TamSX3("E2_DOCHAB")[1])+ "' "
			Else
				xRet := " .AND. EMPTY(E2_DOCHAB) "
			Endif		
		Else
			xRet := If(!EMPTY(SE2->E2_DOCHAB),.T.,.F.)
			If xRet .and. lHelp 
				HELP(" ",1,"DOCTO_HABIL",, 	STR0087+CRLF+; //"Este título está relacionado a um documento hábil."
											   	STR0088+CRLF+; //"Títulos nesta situação não podem sofrer qualquer ação/alteração."
											   	STR0089,2,0)	 //"Caso necessite, acesse o documento hábil e retire o título do mesmo."
			Endif
		Endif
	Else
		//Se for um filtro
		If lFiltro
			xRet := ""
		Else
			xRet := .F.
		Endif
	Endif

Return xRet

/*/{Protheus.doc} LoginCPR()
Função para informar os dados de login de acesso a WebService ManterContasPagarReceber do SIAFI

@return aLogin[1] Retorna o login informado
@return aLogin[2] Retorna a senha informada

@author Marylly Araújo Silva
@since 13/01/2015
@version P12.1.4
/*/
Function LoginCPR()
	Local aReturn		:= {}
	Local oGetLogin	:= Nil
	Local oGetSenha	:= Nil
	Local cLogin		:= Space(11)
	Local cSenha		:= Space(12)
	Local nOpcG		:= 0
	Local nSuperior	:= 0
	Local nEsquerda	:= 0
	Local nInferior	:= 0
	Local nDireita	:= 0
	Local oDlgTela	:= Nil
	
	nSuperior := 0
	nEsquerda := 0
	nInferior := 150
	nDireita  := 400
	
	DEFINE MSDIALOG oDlgTela TITLE STR0091 FROM nSuperior,nEsquerda TO nInferior,nDireita PIXEL //"Login Manter Contas a Pagar e Receber"
	
	oGetLogin	:= TGet():New(35,10, BSetGet(cLogin),oDlgTela,100,10,"@R 999.999.999-99",{ || CGC(cLogin) } ,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cLogin,,,,,,, STR0130 ) // 'Login : '
	
	oGetSenha	:= TGet():New(55,10, BSetGet(cSenha),oDlgTela,100,10,"",{ || .T. } ,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.T.,,cSenha,,,,,,, STR0131 ) //'Senha : '
	
	ACTIVATE MSDIALOG oDlgTela CENTERED ON INIT EnchoiceBar(oDlgTela,{|| nOpcG:=1,oDlgTela:End()},{||nOpcG:=0,oDlgTela:End()})
	
	If nOpcG == 1 .AND. !EMPTY(cLogin)
		Aadd(aReturn,cLogin)
		Aadd(aReturn,cSenha)
	ElseIf nOpcG == 1 .AND. EMPTY(cLogin)	
		Help( "", 1, "SIAFLOGIN", , STR0092, 1, 0 ) //"Por favor, informe um login para acessar o WebService."
	EndIf

Return aReturn

/*/{Protheus.doc} LoadPreDoc()
Função que busca o tipo de pré-doc que será carregado quando clicar no botão Pré-doc do documento hábil.
@author William Matos Gundim Jr
@since 15/01/2015
@version 12.1.5
@param cSituac Código de Identificação informado na Situação do Documento Hábil
/*/
Function LoadPreDoc(cSituac)
Local cRet := ''
//1=OB;2=NS;3=GRU;4=GPS;5=GFIP;6=DAR;7=DARF
cRet := POSICIONE('FVJ', 1, FWxFilial('FVJ') + cSituac , 'FVJ_PREDOC')
Return cRet

/*/{Protheus.doc} GTpForOrg()
Função que verifica se o fornecedor é oficial (Órgão Público) ou fornecedor comum (Privado)
@author Marylly Araújo Silva
@since 20/05/2015
@version 12.1.5
@param cFornec Código de identificação do fornecedor
@param cLoja Código de identificação da loja/filial do fornecedor
/*/
Function GTpForOrg(cFornec,cLoja)
Local nRet 		:= 0
Local aArea		:= GetArea()
Local aCPAArea	:= {}
Local aSA2Area	:= {}

DbSelectArea("CPA") // Órgãos Públicos
aCPAArea := CPA->(GetArea())
CPA->(DbSetOrder(1)) // Filial + Código Órgão

DbSelectArea("SA2")
aSA2Area := SA2->(GetArea())
SA2->(DbSetOrder(1)) // Filial + Código + Lojaadmin

If CPA->(DbSeek(FWxFilial("CPA") + cFornec))
	nRet := 2 // Órgão Público (Fornecedor Oficial)
ElseIf SA2->(DbSeek(FWxFilial("SA2") + cFornec + cLoja ) )
	nRet := 1 // Fornecedor Privado
EndIf
		
RestArea(aArea)	
RestArea(aCPAArea)
RestArea(aSA2Area)
Return nRet

/*/{Protheus.doc} FinGrvMov()
Função que gera movimentações de pagamento ou estorno de pagamento para o documento hábil.
@author Marylly Araújo Silva
@since 12/06/2015
@version 12.1.6
@param cFornec Código de identificação do fornecedor
@param cLoja Código de identificação da loja/filial do fornecedor
/*/
Function FinGrvMov(dDataMov, dDataPag, nValorMov, cCarteira, cFontRec, cDocHabil, nOpc, cIdMov)
Local lRet		:= .T.
Local cHistorico	:= ""
Local aCab		:= {}

Local oModelMov	:= FWLoadModel("FINM030") //Model de Movimento Bancário
Local oSubFK5		:= Nil
Local oSubFKA		:= Nil
Local cLog		:= ""
Local cCamposE5	:= ""

DEFAULT dDataMov	:= CTOD("  / /  ")
DEFAULT dDataPag	:= CTOD("  / /  ")
DEFAULT nValorMov	:= 0
DEFAULT cCarteira	:= "P"
DEFAULT cFontRec	:= ""
DEFAULT cDocHabil := ""
DEFAULT nOpc		:= 3
DEFAULT cIdMov	:= ""
	
If nOpc == MODEL_OPERATION_INSERT
	//Define os campos que não existem nas FKs e que serão gravados apenas na E5, para que a gravação da E5 continue igual
	//Estrutura para o E5_CAMPOS: "{{'SE5->CAMPO', Valor}, {'SE5->CAMPO', Valor}}|{{'SE5->CAMPO', Valor}, {'SE5->CAMPO', Valor}}"
	If !Empty(cCamposE5)
		cCamposE5 += "|"
	Endif
	cCamposE5 += "{"		
	cCamposE5 += "{'E5_DTDIGIT', dDataBase}"
	cCamposE5 += "}"
	oModelMov:SetOperation( MODEL_OPERATION_INSERT ) //Inserção
	cHistorico := STR0090 + " - " + cDocHabil // "Realização DH "
	oModelMov:Activate()
	oModelMov:SetValue( "MASTER", "E5_GRV"		, .T. ) //Informa se vai gravar SE5 ou não
	oModelMov:SetValue( "MASTER", "E5_CAMPOS"	, cCamposE5 ) //Informa os campos da SE5 que serão gravados indepentes de FK5
	oModelMov:SetValue( "MASTER", "NOVOPROC", .T. ) //Informa que a inclusão será feita com um novo número de processo
	
	//Dados do Processo
	oSubFKA := oModelMov:GetModel("FKADETAIL")
	oSubFKA:SetValue( "FKA_IDORIG", FWUUIDV4() )
	oSubFKA:SetValue( "FKA_TABORI", "FK5" )
	
	oSubFK5 := oModelMov:GetModel( "FK5DETAIL" )
	/*
	 * Data do Movimento Financeiro
	 */
	oSubFK5:SetValue( "FK5_DATA", dDataMov )
	/*
	 * Tipo de Moeda do Movimento Financeiro
	 */
	oSubFK5:SetValue( "FK5_MOEDA", "CC" )
	/*
	 * Valor do Movimento Financeiro
	 */
	oSubFK5:SetValue( "FK5_VALOR"	, nValorMov )
	/*
	 * Natureza Financeira no Movimento Financeiro
	 */
	oSubFK5:SetValue( "FK5_NATURE"	, "NAT0000001" )
	/*
	 * Tipo do Documento da Movimentação Financeira
	 */
	oSubFK5:SetValue( "FK5_TPDOC"	, "VL" )
	/*
	 * Dados Bancários da Movimentação Financeira
	 */
	oSubFK5:SetValue( "FK5_BANCO"	, "999" )
	oSubFK5:SetValue( "FK5_AGENCI"	, "99999" )
	oSubFK5:SetValue( "FK5_CONTA"	, cFontRec )
	/*
	 * Tipo do Movimento Financeiro
	 */
	oSubFK5:SetValue( "FK5_RECPAG"	, cCarteira)
	oSubFK5:SetValue( "FK5_HISTOR"	, cHistorico )
	/*
	 * Data de Disponibilidade do Movimento Financeiro
	 */	
	oSubFK5:SetValue( "FK5_DTDISP"	, dDataPag )
	oSubFK5:SetValue( "FK5_LA"		, "S" )
	/*
	 * Filial de Origem do Movimento Financeiro
	 */
	oSubFK5:SetValue( "FK5_FILORI"	, cFilAnt)
	oSubFK5:SetValue( "FK5_ORIGEM"	, FunName() )
	/*
	 * Identificação do Documento do Movimento Financeiro
	 */
	oSubFK5:SetValue( "FK5_DOC"	, cDocHabil )
	/*
	 * Histórico do Movimento Financeiro
	 */
	oSubFK5:SetValue( "FK5_HISTOR", cHistorico )
	
	cIdMov := oSubFKA:GetValue("FKA_IDORIG")
Else
	dbSelectArea( "SE5" )
	SE5->( DbSetOrder( 21 ) ) //E5_FILIAL + E5_IDORIG				
	If SE5->( msSeek( FWxFilial("SE5") + cIdMov ) )
		oModelMov:SetOperation( MODEL_OPERATION_DELETE ) //Deleção
		oModelMov:Activate()
		cHistorico := STR0132 + " - " + cDocHabil // "Cancelamento DH"
	EndIf
EndIf

If oModelMov:VldData()
	oModelMov:CommitData()
	oModelMov:DeActivate()
Else
	lRet := .F.
	cLog := cValToChar(oModelMov:GetErrorMessage()[MODEL_MSGERR_IDFIELDERR]) + ' - '
	cLog += cValToChar(oModelMov:GetErrorMessage()[MODEL_MSGERR_MESSAGE]) + ' - '
	cLog += cValToChar(oModelMov:GetErrorMessage()[MODEL_MSGERR_VALUE])
	Help( ,,"M030VALID",,cLog, 1, 0 )	            
Endif

Return {lRet,cIdMov}