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

/*/{Protheus.doc}�LoadSIAFI
Fun��o para popular as tabelas referentes �s 
situa��es do documento h�bil (SIAFI)

@author�Pedro Alencar
@since�23/10/2014
@version�P12.1.3
/*/
Function LoadSIAFI()
	//Popula a tabela de Situa��es
	If ChkFile("FVJ")
		//Verifica se j� h� valor na FVJ
		FVJ->( dbSetOrder( 1 ) ) 
		If FVJ->( !MsSeek( FWxFilial("FVJ") ) )
			LoadFVJ()
		Endif
	EndIf
	
	//Popula a tabela de Tipo de Documento X Se��o
	If ChkFile("FVH")
		//Verifica se j� h� valor na FVH
		FVH->( dbSetOrder( 1 ) ) 
		If FVH->( !MsSeek( FWxFilial("FVH") ) )
			LoadFVH()
		Endif
	EndIf
	
	//Popula a tabela de Se��o X Situa��o
	If ChkFile("FVK")
		//Verifica se j� h� valor na FVK
		FVK->( dbSetOrder( 1 ) ) 
		If FVK->( !MsSeek( FWxFilial("FVK") ) )
			LoadFVK()
		Endif
	EndIf
	
	//Popula a tabela de campos da associa��o Tipo Doc. X Se��o X Situa��o X Campos
	If ChkFile("FV4")
		//Verifica se j� h� valor na FV4
		FV4->( dbSetOrder( 1 ) ) 
		If FV4->( !MsSeek( FWxFilial("FV4") ) )
			LoadFV4()
		Endif
	EndIf
Return Nil

/*/{Protheus.doc}�LoadFVJ
Fun��o para popular a tabela de Situa��es, 
referente as situa��es do documento h�bil (SIAFI)

@author�Pedro Alencar
@since�23/10/2014
@version�P12.1.2
/*/
Static Function LoadFVJ()
	Local cChave := ""
	Local nI := 0
	Local aAreaTab := {}
	Local aValores := {}
	Local cFilTab := ""
	Local cAliastab := "FVJ" 
	Local nTamSit := TamSX3("FVJ_ID")[1]
	
	//Tipos de Pr�-Doc: 1=OB; 2=NS; 3=GRU; 4=GPS; 6=DAR; 7=DARF
	//Tipos de Situa��o: 1=DH; 2=PF
	//Estrutura:    {  C�digo ,       Descri��o   ,Pr�-Doc, Tipo Situac  } 	
	AAdd( aValores, { "AFL001", OemToAnsi(STR0030), "" , "1" } ) //"ANULA��O DE DESPESA DE PESSOAL"
	AAdd( aValores, { "AFL002", OemToAnsi(STR0031), "" , "1" } ) //"ANULA��O DE DESPEadminSA DE PESSOAL - ADIANTAMENTO DE 13 SAL�RIO"
	AAdd( aValores, { "AFL003", OemToAnsi(STR0032), "" , "1" } ) //"ANULA��O DE DESPESA DE PESSOAL - ADIANTAMENTO DE 1/3 DE FERIAS"
	AAdd( aValores, { "AFL004", OemToAnsi(STR0033), "" , "1" } ) //"ANULA��O DE DESPESA DE PESSOAL - ADIANTAMENTO DE SALARIO"
	AAdd( aValores, { "CRA001", OemToAnsi(STR0133), "" , "1" } ) //"CLASSIFICA��O DE RECEITA ARRECADADA POR GRU - DEP�SITO DE TERCEIROS" 
	AAdd( aValores, { "CRA002", OemToAnsi(STR0134), "" , "1" } ) //"REGISTRO DE DESPESAS BANC�RIAS POR RECEBIMENTO DE GRU - C�DIGO 98815-4" 
	AAdd( aValores, { "CRA003", OemToAnsi(STR0135), "" , "1" } ) //"REGISTRO DE DESPESAS COM IOF POR RECEBIMENTO DE GRU - C�DIGO 98815-4" 
	AAdd( aValores, { "CRD016", OemToAnsi(STR0136), "" , "1" } ) //"REALIZA��O DE DESPESA ANTECIPADA DE SERVI�OS POR COMPET�NCIA (C/C 002)" 
	AAdd( aValores, { "CRD018", OemToAnsi(STR0137), "" , "1" } ) //"ATUALIZA��O MON. E APROP. DE JUROS S/ CR�DITOS POR DANOS AO PATRIM�NIO C/C004" 
	AAdd( aValores, { "CRD020", OemToAnsi(STR0138), "" , "1" } ) //"TRANSFER�NCIA CURTO P/ LONGO PRAZO DE EMPR�STIMOS E FINANCIAMENTOS CONCEDIDOS" 
	AAdd( aValores, { "CRD021", OemToAnsi(STR0139), "" , "1" } ) //"TRANSFER�NCIA LONGO P/ CURTO PRAZO DE EMPR�STIMOS E FINANCIAMENTOS CONCEDIDOS" 
	AAdd( aValores, { "CRD045", OemToAnsi(STR0140), "" , "1" } ) //"AJUSTES FINANCEIROS DE LONGO PRAZO DE EMPR�STIMOS CONCEDIDOS - NEGATIVO" 
	AAdd( aValores, { "CRD049", OemToAnsi(STR0141), "" , "1" } ) //"AJUSTES FINANCEIROS DE LONGO PRAZO DE EMPR�STIMOS CONCEDIDOS - POSITIVO." 
	AAdd( aValores, { "CRD107", OemToAnsi(STR0142), "" , "1" } ) //"BAIXA DO ADIANTAMENTO CONCEDIDO POR SUPRIMENTO DE FUNDOS DE EXEC�CIOS ANTERIORES" 
	AAdd( aValores, { "CRD121", OemToAnsi(STR0143), "" , "1" } ) //"APROPRIA��O DE CR�DITOS DESPESAS ANTECIPADAS RECLASSIFICADAS" 
	AAdd( aValores, { "DDF001", OemToAnsi(STR0001), "7", "1" } ) //"RETEN��O DE IMPOSTOS SOBRE CONTRIBUI��ES DIVERSAS- IN 1234 SRF, DE 11/1/12"
	AAdd( aValores, { "DDF002", OemToAnsi(STR0002), "7", "1" } ) //"IMPOSTO DE RENDA RETIDO NA FONTE - IRRF"	
	AAdd( aValores, { "DDF010", OemToAnsi(STR0035), "7", "1" } ) //"PLANO DE SEGURIDADE SOCIAL DO SERVIDOR"
	AAdd( aValores, { "DDR001", OemToAnsi(STR0003), "6", "1" } ) //"RETEN��ES DE IMPOSTOS RECOLH�VEIS POR DAR"
	AAdd( aValores, { "DFE001", OemToAnsi(STR0144), "" , "1" } ) //"ESTORNO - DESPESA COM REMUNERACAO A PESSOAL ATIVO CIVIL - RPPS" 
	AAdd( aValores, { "DFL001", OemToAnsi(STR0004), "1", "1" } ) //"DESPESA COM PESSOAL" 
	AAdd( aValores, { "DFL002", OemToAnsi(STR0037), "" , "1" } ) //"DESPESA COM PESSOAL - ADIANTAMENTOS DE 13� SALARIO" 
	AAdd( aValores, { "DFL003", OemToAnsi(STR0005), "1", "1" } ) //"DESPESA COM PESSOAL - ADIANTAMENTOS DE 1/3 DE FERIAS" 
	AAdd( aValores, { "DFL004", OemToAnsi(STR0006), "" , "1" } ) //"DESPESA COM PESSOAL - ADIANTAMENTOS DE SAL�RIO" 
	AAdd( aValores, { "DFL011", OemToAnsi(STR0145), "1", "1" } ) //"DESPESA COM REMUNERA��O A PESSOAL ATIVO CIVIL - RGPS" 
	AAdd( aValores, { "DFL013", OemToAnsi(STR0146), "1", "1" } ) //"DESPESA COM BENEF�CIOS A PESSOAL - CIVIL RGPS" 
	AAdd( aValores, { "DFL034", OemToAnsi(STR0147), "1", "1" } ) //"DESPESA COM INDENIZA��ES E RESTITUI��ES TRABALHISTAS" 
	AAdd( aValores, { "DFL035", OemToAnsi(STR0148), "1", "1" } ) //"RESSARCIMENTO DE DESPESAS DE PESSOAL REQUISITADO DE OUTROS �RG�OS OU ENTES" 
	AAdd( aValores, { "DFL045", OemToAnsi(STR0149), "1", "1" } ) //"DESPESA COM OUTROS SERVI�OS DE TERCEIROS - PESSOA F�SICA" 
	AAdd( aValores, { "DFN001", OemToAnsi(STR0150), "" , "1" } ) //"NORMAL - DESPESA COM REMUNERACAO A PESSOAL ATIVO CIVIL - RPPS" 
	AAdd( aValores, { "DGP001", OemToAnsi(STR0129), "4", "1" } ) //"APROPRIA��O DAS RETN��ES RELACIONADAS AO INSS"
	AAdd( aValores, { "DGP001", OemToAnsi(STR0010), "4", "1" } ) //"RETEN��O DE INSS"
	AAdd( aValores, { "DGR002", OemToAnsi(STR0151), "3", "1" } ) //"RETEN��O PARA RESSARCIMENTO DE PESSOAL REQUISITADO" 
	AAdd( aValores, { "DGR005", OemToAnsi(STR0152), "3", "1" } ) //"RETEN��O DE INDENIZA��ES E RESTITUI��ES" 
	AAdd( aValores, { "DGR009", OemToAnsi(STR0038), "3", "1" } ) //"APROPRIA��O DE CONSIGNA��ES LINHA DE CONTRACHEQUE"
	AAdd( aValores, { "DGR010", OemToAnsi(STR0039), "3", "1" } ) //"RETEN��O FONTE TESOURO/PROPRIA"
	AAdd( aValores, { "DOB001", OemToAnsi(STR0007), "1", "1" } ) //"RETENCAO DE ISS SOBRE SERVICOS DE TERCEIROS (EXCETO SUPRIMENTO DE FUNDOS)"
	AAdd( aValores, { "DOB005", OemToAnsi(STR0008), "1", "1" } ) //"OUTROS CONSIGNATARIOS - OB RESERVA"
	AAdd( aValores, { "DOB006", OemToAnsi(STR0153), "1", "1" } ) //"RETEN��O DE EMPR�STIMOS" 
	AAdd( aValores, { "DOB007", OemToAnsi(STR0009), "1", "1" } ) //"DESCONTO DA PENSAO ALIMENTICIA"
	AAdd( aValores, { "DOB008", OemToAnsi(STR0154), "1", "1" } ) //"RETENCAO FOLHA REFERENTE A ENTIDADES REPRESENTATIVAS DE CLASSE"  
	AAdd( aValores, { "DOB009", OemToAnsi(STR0155), "1", "1" } ) //"RETEN��O PARA PLANOS DE PREVID�NCIA E ASSIST�NCIA M�DICA" 
	AAdd( aValores, { "DOB013", OemToAnsi(STR0156), "1", "1" } ) //"RETEN��O CONSIGNA��O ASSOCIA��ES" 
	AAdd( aValores, { "DOB029", OemToAnsi(STR0157), "1", "1" } ) //"PAGAMENTO DE FATURA - CGPF" 	
	AAdd( aValores, { "DSE005", OemToAnsi(STR0158), "" , "1" } ) //"ESTORNO - TRIBUT�RIAS COM A UNI�O, ESTADOS OU MUNIC�PIOS" 
	AAdd( aValores, { "DSF003", OemToAnsi(STR0159), "2", "1" } ) //"DEVOLU��O SAQUE CARTAO PAGAMENTOS P/VAL. A DEBITAR" 
	AAdd( aValores, { "DSF004", OemToAnsi(STR0160), "2", "1" } ) //"DEV.FATURA CARTAO PAGAMENTOS P/VAL. A DEBITAR" 
	AAdd( aValores, { "DSN005", OemToAnsi(STR0161), "" , "1" } ) //"NORMAL - DESPESAS TRIBUT�RIAS COM A UNI�O, ESTADOS OU MUNIC�PIOS - RECOLH. OB/GR" 
	AAdd( aValores, { "DSP001", OemToAnsi(STR0011), "3", "1" } ) //"DESPESAS CORRENTES DE SERVI�OS"
	AAdd( aValores, { "DSP005", OemToAnsi(STR0162), "" , "1" } ) //"DESPESAS TRIBUT�RIAS COM A UNI�O, ESTADOS OU MUNIC�PIOS - RECOLH. OB/GRU" 
	AAdd( aValores, { "DSP011", OemToAnsi(STR0012), "3", "1" } ) //"DESPESAS COM BOLSAS DE ESTUDO"
	AAdd( aValores, { "DSP051", OemToAnsi(STR0163), "1", "1" } ) //"AQUISI��O DE SERVI�OS - PESSOAS F�SICAS" 
	AAdd( aValores, { "DSP062", OemToAnsi(STR0164), "1", "1" } ) //"DESPESAS COM SERVI�OS EVENTUAIS DE PESSOAL T�CNICO" 
	AAdd( aValores, { "DSP081", OemToAnsi(STR0165), "1", "1" } ) //"DESPESAS COM DI�RIAS" 
	AAdd( aValores, { "DSP100", OemToAnsi(STR0013), "3", "1" } ) //"DESPESAS COM MERCADORIAS PARA DOA��O"
	AAdd( aValores, { "DSP101", OemToAnsi(STR0014), "3", "1" } ) //"DESPESAS COM MATERIAIS PARA ESTOQUE"
	AAdd( aValores, { "DSP102", OemToAnsi(STR0041), "3", "1" } ) //"DESPESAS COM MATERIAIS PARA CONSUMO IMEDIATO"
	AAdd( aValores, { "DSP200", OemToAnsi(STR0042), "3", "1" } ) //"DESPESAS COM INVESTIMENTOS DE BENS IM�VEIS"
	AAdd( aValores, { "DSP201", OemToAnsi(STR0015), "3", "1" } ) //"DESPESAS COM AQUISI��O DE EQUIPAMENTOS E MATERIAIS PERMANENTES"
	AAdd( aValores, { "DSP206", OemToAnsi(STR0016), "3", "1" } ) //"DESPESAS COM A REALIZA��O DE OBRAS E INSTALA��ES"
	AAdd( aValores, { "DSP215", OemToAnsi(STR0017), "3", "1" } ) //"DESPESAS COM AQUISI��O DE BENS INTANGIVEIS FAVORECIDO DA NE"
	AAdd( aValores, { "DSP900", OemToAnsi(STR0018), "3", "1" } ) //"DESPESAS COM INDENIZA��ES E RESTITUI��ES"
	AAdd( aValores, { "DSP901", OemToAnsi(STR0019), "" , "1" } ) //"DESPESAS CORRENTES COM INDENIZA��ES E RESTITUI��ES COM AUX�LIO MORADIA"
	AAdd( aValores, { "DSP902", OemToAnsi(STR0043), "" , "1" } ) //"DESPESAS CORRENTES PARA AUX�LIO A PESQUISADORES SEM CONTROLE DE RESPONSABILIDADE"
	AAdd( aValores, { "DSP925", OemToAnsi(STR0166), "1", "1" } ) //"DESPESAS COM DEP�SITOS PARA RECURSOS" 
	AAdd( aValores, { "DSP975", OemToAnsi(STR0167), "" , "1" } ) //"DESPESAS COM JUROS/ENCARGOS DE MORA DE OBRIGACOES TRIBUTARIAS" 
	AAdd( aValores, { "DVL001", OemToAnsi(STR0168), "" , "1" } ) //"DEVOLU��O DE DESPESAS COM CONTRATA��O DE SERVI�OS - PESSOAS JUR�DICAS" 
	AAdd( aValores, { "DVL081", OemToAnsi(STR0169), "" , "1" } ) //"DEVOLU��O DE DESPESAS COM DI�RIAS" 
	AAdd( aValores, { "DVL973", OemToAnsi(STR0170), "" , "1" } ) //"DEVOLU��O DE DESPESAS COM JUROS/ENCARGOS DE MORA COM BENS/SERVI�OS" 
	AAdd( aValores, { "EDS001", OemToAnsi(STR0044), "" , "1" } ) //"ESTORNO/ANULA��O DE DESPESAS CORRENTES COM SERVI�OS SEM CONTRATO"
	AAdd( aValores, { "EDS011", OemToAnsi(STR0045), "" , "1" } ) //"ESTORNO/ANULA��O DE DESPESAS COM BOLSAS DE ESTUDO"
	AAdd( aValores, { "EDS101", OemToAnsi(STR0046), "" , "1" } ) //"ESTORNO/ANULA��O DE DESPESAS COM AQUISI��O DE MATERIAIS PARA ESTOQUE"
	AAdd( aValores, { "EDS102", OemToAnsi(STR0047), "" , "1" } ) //"ESTORNO/ANULA��O DE DESPESAS COM MATERIAIS PARA CONSUMO IMEDIATO"
	AAdd( aValores, { "EDS200", OemToAnsi(STR0048), "" , "1" } ) //"ESTORNO/ANULA��O DE DESPESAS COM AQUISI��O DE IM�VEIS"
	AAdd( aValores, { "EDS201", OemToAnsi(STR0049), "" , "1" } ) //"ESTORNO/ANULA��O DE DESPESAS COM EQUIPAMENTOS E MATERIAL PERMANENTE"
	AAdd( aValores, { "EDS206", OemToAnsi(STR0050), "" , "1" } ) //"ESTORNO/ANULA��O DE DESPESAS COM A REALIZA��O DE OBRAS E INSTALA��ES"
	AAdd( aValores, { "EDS900", OemToAnsi(STR0051), "" , "1" } ) //"ESTORNO/ANULA��O DE ESPESAS COM INDENIZA��ES E RESTITUI��ES."
	AAdd( aValores, { "ENC001", OemToAnsi(STR0052), "4", "1" } ) //"ENCARGO PATRONAL - INSS - RECOLHIDO POR MEIO DE GPS"
	AAdd( aValores, { "ENC002", OemToAnsi(STR0171), "4", "1" } ) //"ENCARGOS PATRONAIS - FGTS - RECOLHIMENTO POR GFIP" 
	AAdd( aValores, { "ENC004", OemToAnsi(STR0172), "7", "1" } ) //"ENCARGOS TRIBUTARIOS COM IRPJ - POR DARF" 
	AAdd( aValores, { "ENC005", OemToAnsi(STR0053), "7", "1" } ) //"PIS/PASEP RECOLHIDO POR MEIO DE DARF (EXCETO FOLHA DE PAGAMENTO)"
	AAdd( aValores, { "ENC011", OemToAnsi(STR0054), "7", "1" } ) //"ENCARGOS SOCIAIS RPPS - PSSS PATRONAL"
	AAdd( aValores, { "ENC014", OemToAnsi(STR0173), "1", "1" } ) //"ENCARGOS PATRONAIS COM PREVID�NCIA PRIVADA E ASSIST. M�DICO-ODONTOL�GICA" 
	AAdd( aValores, { "ENC015", OemToAnsi(STR0055), "1", "1" } ) //"ENCARGOS SOCIAIS - PREVID�NCIA REGIME PROPRIO - FUNPRESP"
	AAdd( aValores, { "ENC021", OemToAnsi(STR0174), "" , "1" } ) //"ENCARGOS TRIBUT�RIOS COM UNI�O, ESTADOS OU MUNIC�PIOS - RECOLH. OB/GRU" 
	AAdd( aValores, { "ENC022", OemToAnsi(STR0175), "7", "1" } ) //"ENCARGOS TRIBUT�RIOS COM A UNI�O - RECOLHIMENTO POR DARF" 
	AAdd( aValores, { "ENC024", OemToAnsi(STR0176), "4", "1" } ) //"ENCARGO PATRONAIS SOBRE SERVI�OS DE TERCEIROS - INSS" 
	AAdd( aValores, { "ENC028", OemToAnsi(STR0177), "" , "1" } ) //"ENCARGOS COM CONTRIBUI��ES SOCIAIS - DOCUMENTOS DE REALIZA��O OB/GRU" 
	AAdd( aValores, { "ETQ001", OemToAnsi(STR0178), "" , "1" } ) //"BAIXA DE ESTOQUES DE ALMOXARIFADO POR CONSUMO/DISTRIBUI��O GRATUITA (C/C 007)" 
	AAdd( aValores, { "ETQ027", OemToAnsi(STR0179), "" , "1" } ) //"TRANSFER�NCIA DE ESTOQUES COM C/C SUBITEM ENTRE UG OU DENTRO DA MESMA UG" 
	AAdd( aValores, { "IMB070", OemToAnsi(STR0180), "" , "1" } ) //"APROPRIA��O DA DEPRECIA��O DE IMOBILIZADO - BENS M�VEIS" 
	AAdd( aValores, { "IMB071", OemToAnsi(STR0181), "" , "1" } ) //"APROPRIA��O DA DEPRECIA��O DE IMOBILIZADO - BENS IM�VEIS" 
	AAdd( aValores, { "INT001", OemToAnsi(STR0182), "" , "1" } ) //"APROPRIA��O DA AMORTIZA��O DOS BENS INTANG�VEIS - DO EXERC�CIO" 
	AAdd( aValores, { "LDV011", OemToAnsi(STR0183), "" , "1" } ) //"ASSINATURA DE CONTRATOS DE DESPESA" 
	AAdd( aValores, { "LDV051", OemToAnsi(STR0184), "" , "1" } ) //"APROPRIA��O DE RESPONSABILIDADES COM TERCEIROS" 
	AAdd( aValores, { "LDV052", OemToAnsi(STR0185), "" , "1" } ) //"BAIXA DE RESPONSABILIDADES COM TERCEIROS" 
	AAdd( aValores, { "LDV053", OemToAnsi(STR0186), "" , "1" } ) //"APROPRIA��O DE GARANTIAS/CONTRAGARANTIAS RECEBIDAS" 
	AAdd( aValores, { "LPA301", OemToAnsi(STR0187), "" , "1" } ) //"APROPRIA��O DE PESSOAL E ENCARGOS A PAGAR SEM SUPORTE ORCAMENT�RIO" 
	AAdd( aValores, { "LPA331", OemToAnsi(STR0188), "" , "1" } ) //"APROPRIA��O DE PASSIVOS CIRCULANTES (ISF P)" 
	AAdd( aValores, { "PRV002", OemToAnsi(STR0057), "" , "1" } ) //"BAIXA DE PROVIS�ES E ADIANTAMENTOS DA FOLHA DE PAGAMENTO"
	AAdd( aValores, { "PRV003", OemToAnsi(STR0058), "" , "1" } ) //"BAIXA DE ADIANTAMENTOS DA FOLHA DE PAGAMENTO"	
	AAdd( aValores, { "PRV004", OemToAnsi(STR0059), "" , "1" } ) //"BAIXA DE PROVIS�ES PARA 13 SALARIO, F�RIAS OU LIC. PR�MIO"
	AAdd( aValores, { "PRV005", OemToAnsi(STR0060), "" , "1" } ) //"BAIXA DE ADIANTAMENTOS DA FOLHA DE PAGAMENTO - EXERC�CIOS ANTERIORES"
	AAdd( aValores, { "PRV006", OemToAnsi(STR0061), "" , "1" } ) //"BAIXA DE PROVIS�ES DA FOLHA DE PAGAMENTO - EXERC�CIOS ANTERIORES"
	AAdd( aValores, { "PRV007", OemToAnsi(STR0189), "" , "1" } ) //"APROPRIA��O DE PROVIS�ES A CURTO PRAZO" 
	AAdd( aValores, { "PRV008", OemToAnsi(STR0190), "" , "1" } ) //"CONSTITUI��O DE PROV.INDENIZ.TRABALHISTAS" 
	AAdd( aValores, { "PSO001", OemToAnsi(STR0062), "3", "1" } ) //"RECOLHIMENTO DE VALORES EM TR�NSITO PARA ESTORNO DE DESPESA"
	AAdd( aValores, { "PSO002", OemToAnsi(STR0063), "" , "1" } ) //"REGULARIZA��O DE ORDENS BANC�RIAS CANCELADAS (2.1.2.6.3.00.00)-VALOR DEVIDO(OB)"
	AAdd( aValores, { "PSO006", OemToAnsi(STR0064), "3", "1" } ) //"REGULARIZACAO OB CANCELADA-EMISS�O GRU - 21.263.00.00 - VALOR NAO DEVIDO"			
	AAdd( aValores, { "PSO023", OemToAnsi(STR0191), "" , "1" } ) //"PAGAMENTO/DEVOLU��O DE DEP�SITOS DIVERSOS (CONTAS 2.1.8.8.1.XX.XX - C/C FONTE)" 
	AAdd( aValores, { "PSO030", OemToAnsi(STR0192), "1", "1" } ) //"APROPRIA��O DO ISS SOBRE VENDAS BRUTA DE PRODUTOS - REALIZA��O POR OB" 
	AAdd( aValores, { "PSO042", OemToAnsi(STR0193), "" , "1" } ) //"PAGAMENTO DEP�SITOS DIVERSOS (CONTAS 2.1.8.8.X.XX.XX-C/C FTE+CNPJ,CPF,UG,IG,999)" 
	AAdd( aValores, { "PSO045", OemToAnsi(STR0194), "7", "1" } ) //"APROPRIA��O DE OBRIGA��ES COM A UNI�O A RECOLHER - SEM NE - GERANDO DARF" 
	AAdd( aValores, { "PSO079", OemToAnsi(STR0195), "1", "1" } ) //"RETENCAO EM FOLHA - PLANO DE PREV. E ASSIST M�D - LIQUIDADAS POR OUTRO DOC S/NE" 
	AAdd( aValores, { "SPE003", OemToAnsi(STR0196), "1", "1" } ) //"ESTORNO - DESPESAS COM SUPRIMENTO DE FUNDOS - EXCETO AS DE CAR�TER SIGILOSO" 
	AAdd( aValores, { "SPF003", OemToAnsi(STR0197), "1", "1" } ) //"SUPRIMENTO DE FUNDOS - CART�O DE PAGAMENTO GOVERNO FEDERAL - SAQUE E FATURA" 	
	AAdd( aValores, { "SPN003", OemToAnsi(STR0198), "" , "1" } ) //"NORMAL - DESPESAS CORRENTES COM SUPRIMENTO DE FUNDOS" 
	//Situa��es de Programa��o Financeira
	AAdd( aValores, { "EXE001", OemToAnsi(STR0093), "" , "2" } ) //"EXERC�CIO CORRENTE"	
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

/*/{Protheus.doc}�LoadFVH
Fun��o para popular a tabela de Tipo de Documento X Se��o, 
referente as situa��es do documento h�bil (SIAFI)

@author�Pedro Alencar
@since�23/10/2014
@version�P12.1.2
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
	
	//Estrutura: {Tp. Doc., Se��o}
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

/*/{Protheus.doc}�LoadFVK
Fun��o para popular a tabela de Se��o X Situa��o, 
referente as situa��es do documento h�bil (SIAFI)

@author�Pedro Alencar
@since�23/10/2014
@version�P12.1.2
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
	
	//Estrutura:{Tp. Doc. , Se��o   , Situa��o }
	
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

/*/{Protheus.doc}�LoadFV4
Fun��o para popular a tabela de campos da associa��o 
Tipo Doc. X Se��o X Situa��o X Campos, referente as 
situa��es do documento h�bil (SIAFI)

@author�Pedro Alencar
@since�23/10/2014
@version�P12.1.2
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
	
	//Estrutura:    { Situa��o,  Campo, Descri��o do Campo, Tam.	, Tp. Campo, Picture          	, Obrigat., TagXML, Ativo?, Local, Modo Edi��o, Consul. Pad,Valida��o }
	AAdd( aValores, { "AFL001", "0001", OemToAnsi(STR0095),  nTamCT1, TIPO_CHAR , cPicCT1	, "1", "numClassA",  "1"  ,  "1" , "", "CT1" ,"F761VCT1('C0001')"} ) //"Varia��o Patrimonial Diminutiva"
	
	AAdd( aValores, { "AFL003", "0001", OemToAnsi(STR0095),  nTamCT1, TIPO_CHAR , cPicCT1	, "1", "numClassA",  "1"  ,  "1" , "", "CT1" ,"F761VCT1('C0001')"} ) //"Varia��o Patrimonial Diminutiva"
	
	AAdd( aValores, { "AFL004", "0001", OemToAnsi(STR0095),   nTamCT1		, TIPO_CHAR , cPicCT1	, "1", "numClassA",  "1"  ,  "1" , "", "CT1" ,"F761VCT1('C0001')"} ) //"Varia��o Patrimonial Diminutiva"
	
	AAdd( aValores, { "CRA001", "0001", OemToAnsi(STR0199),  10		, TIPO_CHAR , ""           		, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"Fonte" 
	AAdd( aValores, { "CRA001", "0002", OemToAnsi(STR0200),  3		, TIPO_CHAR , ""           		, "1", "txtInscrB",  "1"  ,  "1" , "", "" ,""} ) //"Vincula��o" 
	AAdd( aValores, { "CRA001", "0003", OemToAnsi(STR0201),  14		, TIPO_CHAR , ""           		, "1", "txtInscrC",  "1"  ,  "1" , "", "" ,""} ) //"CNPJ, CPF, UG ou IG." 	
	AAdd( aValores, { "CRA001", "0004", OemToAnsi(STR0202),  nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0004')"} ) //"Classifica��o Cont�bil da Receita" 
	AAdd( aValores, { "CRA001", "0005", OemToAnsi(STR0203),  nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0005')"} ) //"Classifica��o Or�ament�ria da Receita" 
	
	AAdd( aValores, { "CRA002", "0001", OemToAnsi(STR0204),  12		, TIPO_CHAR , ""	           	, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"Empenho" 
	AAdd( aValores, { "CRA002", "0002", OemToAnsi(STR0205),  2		, TIPO_CHAR , ""           		, "1", "txtInscrB",  "1"  ,  "1" , "", "" ,""} ) //"Subitem" 
	AAdd( aValores, { "CRA002", "0003", OemToAnsi(STR0206), nTamCT1 , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"Despesas Banc�rias"	
	AAdd( aValores, { "CRA002", "0004", OemToAnsi(STR0202), nTamCT1	, TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0004')"} ) //"Classifica��o Cont�bil da Receita" 
	
	AAdd( aValores, { "CRA003", "0001", OemToAnsi(STR0204),  12		, TIPO_CHAR , ""	           	, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"Empenho" 
	AAdd( aValores, { "CRA003", "0002", OemToAnsi(STR0205),  2		, TIPO_CHAR , ""           		, "1", "txtInscrB",  "1"  ,  "1" , "", "" ,""} ) //"Subitem" 
	AAdd( aValores, { "CRA003", "0003", OemToAnsi(STR0207),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"Imposto s/ Opera��es Financeiras - IOF"	
	AAdd( aValores, { "CRA003", "0004", OemToAnsi(STR0202),nTamCT1	, TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0004')"} ) //"Classifica��o Cont�bil da Receita" 
	
	AAdd( aValores, { "CRD016", "0001", OemToAnsi(STR0208),  14		, TIPO_CHAR , ""           		, "1", "txtInscrB",  "1"  ,  "1" , "", "" ,""} ) //"CNPJ, CPF, UG, IG ou 999" 
	AAdd( aValores, { "CRD016", "0002", OemToAnsi(STR0209), nTamCT1, TIPO_CHAR  , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"VPD de Servi�os"	
	AAdd( aValores, { "CRD016", "0003", OemToAnsi(STR0210), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"Conta de Despesa Antecipada" 
	
	AAdd( aValores, { "CRD018", "0001", OemToAnsi(STR0211),  4		, TIPO_CHAR , ""	           	, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"Exerc�cio" 
	AAdd( aValores, { "CRD018", "0002", OemToAnsi(STR0208),  14		, TIPO_CHAR , ""           		, "1", "txtInscrB",  "1"  ,  "1" , "", "" ,""} ) //"CNPJ, CPF, UG, IG OU 999" 
	AAdd( aValores, { "CRD018", "0003", OemToAnsi(STR0212), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"Cr�ditos Administrativos ou TCE ou Processo Judicial"	
	AAdd( aValores, { "CRD018", "0004", OemToAnsi(STR0213), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0004')"} ) //"Receita de juros / Atualiza��o Monet�ria" 
	
	AAdd( aValores, { "CRD020", "0001", OemToAnsi(STR0214),  14		, TIPO_CHAR , ""           		, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"CNPJ, CPF, UG ou IG - Curto Prazo" 
	AAdd( aValores, { "CRD020", "0002", OemToAnsi(STR0215),  14		, TIPO_CHAR , ""           		, "1", "txtInscrB",  "1"  ,  "1" , "", "" ,""} ) //"CNPJ, CPF, UG ou IG - Longo Prazo" 
	AAdd( aValores, { "CRD020", "0003", OemToAnsi(STR0216), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"Empr�stimos e Financiamentos a Curto Prazo"	
	AAdd( aValores, { "CRD020", "0004", OemToAnsi(STR0217), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0004')"} ) //"Empr�stimos e Financiamentos a Longo Prazo" 
	
	AAdd( aValores, { "CRD021", "0001", OemToAnsi(STR0218),  9		, TIPO_CHAR , ""           		, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"Conta-corrente de Financiamento" 
	AAdd( aValores, { "CRD021", "0002", OemToAnsi(STR0217), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"Empr�stimos e Financiamentos a Longo Prazo"	
	AAdd( aValores, { "CRD021", "0003", OemToAnsi(STR0216), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"Empr�stimos e Financiamentos a Curto Prazo" 
		
	AAdd( aValores, { "CRD045", "0001", OemToAnsi(STR0208),  14		, TIPO_CHAR , ""           		, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"CNPJ, CPF, UG, IG ou 999" 
	AAdd( aValores, { "CRD045", "0002", OemToAnsi(STR0219), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"ajustes Financeiros de Empr�stimos Concedidos - Negativo"	
	AAdd( aValores, { "CRD045", "0003", OemToAnsi(STR0220), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"Cr�ditos a Longo Prazo" 

	AAdd( aValores, { "CRD049", "0001", OemToAnsi(STR0208),  14		, TIPO_CHAR , "9999"           	, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"CNPJ, CPF, UG, IG ou 999" 
	AAdd( aValores, { "CRD049", "0002", OemToAnsi(STR0221), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"Empr�stimos concedidos - longo prazo"	
	AAdd( aValores, { "CRD049", "0003", OemToAnsi(STR0222), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"Ajustes Financeiros de Empr�stimos Concedidos - Positivo" 
	
	AAdd( aValores, { "CRD121", "0001", OemToAnsi(STR0102),  14		, TIPO_CHAR ,"99.999.999/9999-99", "1", "txtInscrA",  "1"  ,  "1" , "", "" ,"F761VCGC('C0001')"} ) //"Favorecido do Contrato" 
	AAdd( aValores, { "CRD121", "0002", OemToAnsi(STR0223), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"Despesa antecipada a apropriar" 
	AAdd( aValores, { "CRD121", "0003", OemToAnsi(STR0224), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"VPD Reclassificada" 
	
	AAdd( aValores, { "DDF001", "0001", OemToAnsi(STR0069),  4		, TIPO_CHAR , "9999"           	, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"C�digo DARF"
	AAdd( aValores, { "DDF001", "0002", OemToAnsi(STR0027),  4		, TIPO_CHAR , "9999"           	, "1", "txtInscrA",  "1"  ,  "2" , "", "" ,""} ) //"C�digo do DARF"
	AAdd( aValores, { "DDF001", "0003", OemToAnsi(STR0096), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"VPD de Multa ou Encargos Tribut�rios"
	
	AAdd( aValores, { "DDF002", "0001", OemToAnsi(STR0069),  4		, TIPO_CHAR , "9999"           	, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"C�digo DARF"
	AAdd( aValores, { "DDF002", "0002", OemToAnsi(STR0027),  4		, TIPO_CHAR , "9999"           	, "1", "txtInscrA",  "1"  ,  "2" , "", "" ,""} ) //"C�digo do DARF"	
	AAdd( aValores, { "DDF002", "0003", OemToAnsi(STR0096), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"VPD de Multa ou Encargos Tribut�rios"
	
	AAdd( aValores, { "DDR001", "0001", OemToAnsi(STR0025),  4		, TIPO_CHAR , "9999"           	, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"C�digo do Munic�pio"
	AAdd( aValores, { "DDR001", "0002", OemToAnsi(STR0026),  4		, TIPO_CHAR , "9999"           	, "1", "txtInscrB",  "1"  ,  "1" , "", "" ,""} ) //"C�digo de Receita"
	AAdd( aValores, { "DDR001", "0003", OemToAnsi(STR0025),  4		, TIPO_CHAR , "9999"           	, "1", "txtInscrA",  "1"  ,  "2" , "", "" ,""} ) //"C�digo do Munic�pio"
	AAdd( aValores, { "DDR001", "0004", OemToAnsi(STR0026),  4		, TIPO_CHAR , "9999"           	, "1", "txtInscrB",  "1"  ,  "2" , "", "" ,""} ) //"C�digo de Receita"
	AAdd( aValores, { "DDR001", "0005", OemToAnsi(STR0096), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0005')"} ) //"VPD de Multa ou Encargos Tribut�rios"
	
	AAdd( aValores, { "DDR006", "0001", OemToAnsi(STR0025),  4		, TIPO_CHAR , "9999"           	, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"C�digo do Munic�pio"
	AAdd( aValores, { "DDR006", "0002", OemToAnsi(STR0026),  4		, TIPO_CHAR , "9999"           	, "1", "txtInscrB",  "1"  ,  "1" , "", "" ,""} ) //"C�digo de Receita"
	AAdd( aValores, { "DDR006", "0003", OemToAnsi(STR0025),  4		, TIPO_CHAR , "9999"           	, "1", "txtInscrA",  "1"  ,  "2" , "", "" ,""} ) //"C�digo do Munic�pio"
	AAdd( aValores, { "DDR006", "0004", OemToAnsi(STR0026),  4		, TIPO_CHAR , "9999"           	, "1", "txtInscrB",  "1"  ,  "2" , "", "" ,""} ) //"C�digo de Receita"
	AAdd( aValores, { "DDR006", "0005", OemToAnsi(STR0096), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0006')"} ) //"VPD de Multa ou Encargos Tribut�rios"
	
	AAdd( aValores, { "DFE001", "0001", OemToAnsi(STR0124),  12		, TIPO_CHAR , ""           	   	, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"Empenho para Estorno" 
	AAdd( aValores, { "DFE001", "0002", OemToAnsi(STR0225),  2		, TIPO_CHAR , ""	           	, "1", "txtInscrB",  "1"  ,  "2" , "", "" ,""} ) //"Subitem 3" 
	AAdd( aValores, { "DFE001", "0003", OemToAnsi(STR0095), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassC",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"Varia��o Patrimonial Diminutiva" 
	
	AAdd( aValores, { "DFL001", "0001", OemToAnsi(STR0095), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0001')"} ) //"Varia��o Patrimonial Diminutiva"
	
	AAdd( aValores, { "DFL002", "0001", OemToAnsi(STR0097),  3		, TIPO_CHAR , ""               	, "1", "txtInscrA",  "1"  ,  "2" , "", "" ,""} ) //"Banco"
	AAdd( aValores, { "DFL002", "0002", OemToAnsi(STR0098),  4		, TIPO_CHAR , ""               	, "1", "txtInscrB",  "1"  ,  "2" , "", "" ,""} ) //"Ag�ncia"
	AAdd( aValores, { "DFL002", "0003", OemToAnsi(STR0099),  10		, TIPO_CHAR , ""               	, "1", "txtInscrC",  "1"  ,  "2" , "", "" ,""} ) //"Conta"
	AAdd( aValores, { "DFL002", "0004", OemToAnsi(STR0095), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0004')"} ) //"Varia��o Patrimonial Diminutiva"
		
	AAdd( aValores, { "DFL003", "0001", OemToAnsi(STR0095), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0001')"} ) //"Varia��o Patrimonial Diminutiva"
	
	AAdd( aValores, { "DFL004", "0001", OemToAnsi(STR0095), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0001')"} ) //"Varia��o Patrimonial Diminutiva"
	
	AAdd( aValores, { "DFL011", "0001", OemToAnsi(STR0095), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  , "2"	, "", "CT1" ,"F761VCT1('C0001')"} )//"Varia��o Patrimonial Diminutiva" 
	
	AAdd( aValores, { "DFL013", "0001", OemToAnsi(STR0095), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  , "2"	, "", "CT1" ,"F761VCT1('C0001')"} )//"Varia��o Patrimonial Diminutiva" 
	
	AAdd( aValores, { "DFL034", "0001", OemToAnsi(STR0095), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  , "2"	, "", "CT1" ,"F761VCT1('C0001')"} )//"Varia��o Patrimonial Diminutiva" 
	AAdd( aValores, { "DFL034", "0002", OemToAnsi(STR0226), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  , "2"	, "", "CT1" ,"F761VCT1('C0002')"} )//"Indeniza��es a Pagar" 
	
	AAdd( aValores, { "DFL035", "0001", OemToAnsi(STR0227), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  , "2"	, "", "CT1" ,"F761VCT1('C0001')"} )//"Pessoal Requisitado de Outros �rg�os" 
	
	AAdd( aValores, { "DFL045", "0001", OemToAnsi(STR0095), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  , "2"	, "", "CT1" ,"F761VCT1('C0001')"} )//"Varia��o Patrimonial Diminutiva" 
	
	AAdd( aValores, { "DFN001", "0001", OemToAnsi(STR0127),  12		, TIPO_CHAR , ""				   	, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"Novo Empenho" 
	AAdd( aValores, { "DFN001", "0002", OemToAnsi(STR0128),  14		, TIPO_CHAR , ""           	   	, "1", "txtInscrB",  "1"  ,  "2" , "", "" ,""} ) //"Novo Subitem" 
	AAdd( aValores, { "DFN001", "0003", OemToAnsi(STR0095), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassC",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"Varia��o Patrimonial Diminutiva" 
	
	AAdd( aValores, { "DGP001", "0001", OemToAnsi(STR0029),  4		, TIPO_CHAR , "9999"           	, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"C�digo de Pagamento GPS"
	AAdd( aValores, { "DGP001", "0002", OemToAnsi(STR0029),  4		, TIPO_CHAR , "9999"           	, "1", "txtInscrA",  "1"  ,  "2" , "", "" ,""} ) //"C�digo de Pagamento GPS"	
	AAdd( aValores, { "DGP001", "0003", OemToAnsi(STR0096), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"VPD de Multa ou Encargos Tribut�rios"
	
	AAdd( aValores, { "DGR002", "0001", OemToAnsi(STR0021),  6		, TIPO_CHAR , "99999-9"        	, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"C�digo de Recolhimento da GRU" 
	
	AAdd( aValores, { "DGR005", "0001", OemToAnsi(STR0021),  6		, TIPO_CHAR , "99999-9"        	, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"C�digo de Recolhimento da GRU" 
	
	AAdd( aValores, { "DGR009", "0001", OemToAnsi(STR0021),  6		, TIPO_CHAR , "99999-9"        	, "1", "txtInscrA",  "1"  ,  "1" , "F761WhenCtr(.T.)", "" ,""} ) //"C�digo de Recolhimento GRU"
	
	AAdd( aValores, { "DGR010", "0001", OemToAnsi(STR0021), 6       , TIPO_CHAR , "99999-9"        	, "1", "txtInscrA",  "1"  ,  "1" , "F761WhenCtr(.T.)", "" ,""} ) //"C�digo de Recolhimento GRU"
	
	AAdd( aValores, { "DOB005", "0001", OemToAnsi(STR0100),  14		, TIPO_CHAR , "99.999.999/9999-99", "1", "txtInscrA",  "1"  ,  "2" , "", "" ,"F761VCGC('C0001')"} ) //"Credor da Obriga��o"
	AAdd( aValores, { "DOB005", "0002", OemToAnsi(STR0101), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"Outros Consignat�rios"
	
	AAdd( aValores, { "DOB006", "0001", OemToAnsi(STR0100),  14		, TIPO_CHAR ,"99.999.999/9999-99", "1", "txtInscrA",  "1"  ,  "1" , "", "" ,"F761VCGC('C0001')"} ) //"Credor da Obriga��o" 
	AAdd( aValores, { "DOB006", "0002", OemToAnsi(STR0228), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"Reten��es a Empr�stimo e financiamentos" 
	
	AAdd( aValores, { "DOB007", "0001", OemToAnsi(STR0100),  14		, TIPO_CHAR ,"99.999.999/9999-99", "1", "txtInscrA",  "1"  ,  "1" , "", "" ,"F761VCGC('C0001')"} ) //"Credor da Obriga��o"
	AAdd( aValores, { "DOB007", "0002", OemToAnsi(STR0123), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"Pens�o Aliment�cia"
	
	AAdd( aValores, { "DOB008", "0001", OemToAnsi(STR0100),  14		, TIPO_CHAR ,"99.999.999/9999-99", "1", "txtInscrA",  "1"  ,  "1" , "", "" ,"F761VCGC('C0001')"} ) //"Credor da Obriga��o" 
	AAdd( aValores, { "DOB008", "0002", OemToAnsi(STR0229), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"Reten��es a Entidades Representativas de Classe" 
	
	AAdd( aValores, { "DOB009", "0001", OemToAnsi(STR0100),  14		, TIPO_CHAR ,"99.999.999/9999-99", "1", "txtInscrA",  "1"  ,  "1" , "", "" ,"F761VCGC('C0001')"} ) //"Credor da Obriga��o" 
	AAdd( aValores, { "DOB009", "0002", OemToAnsi(STR0230), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"Planos de Previd�ncia e Assist�ncia M�dica" 
	
	AAdd( aValores, { "DOB013", "0001", OemToAnsi(STR0100),  14		, TIPO_CHAR ,"99.999.999/9999-99", "1", "txtInscrA",  "1"  ,  "1" , "", "" ,"F761VCGC('C0001')"} ) //"Credor da Obriga��o" 
	AAdd( aValores, { "DOB013", "0002", OemToAnsi(STR0231), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"Reten��es a Associa��es" 
	
	AAdd( aValores, { "DSE005", "0001", OemToAnsi(STR0124),  12		, TIPO_CHAR , ""           		, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"Empenho para Estorno" 
	AAdd( aValores, { "DSE005", "0002", OemToAnsi(STR0125),  14		, TIPO_CHAR , ""           		, "1", "txtInscrB",  "1"  ,  "1" , "", "" ,""} ) //"Subitem para Estorno" 
	AAdd( aValores, { "DSE005", "0003", OemToAnsi(STR0232), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "txtInscrA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"Conta de Passivo" 
	AAdd( aValores, { "DSE005", "0004", OemToAnsi(STR0095), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "txtInscrC",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0004')"} ) //"Varia��o Patrimonial Diminutiva" 
	
	AAdd( aValores, { "DSF003", "0001", OemToAnsi(STR0121),  3		, TIPO_CHAR , ""       			, "1", "txtInscrD",  "1"  ,  "1" , "", "" ,""} ) //"Vincula��o de Pagamento" 
	
	AAdd( aValores, { "DSF004", "0001", OemToAnsi(STR0121),  3		, TIPO_CHAR , ""       		 	, "1", "txtInscrD",  "1"  ,  "1" , "", "" ,""} ) //"Vincula��o de Pagamento" 
	
	AAdd( aValores, { "DSN005", "0001", OemToAnsi(STR0127),  12		, TIPO_CHAR , ""           		, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"Novo Empenho" 
	AAdd( aValores, { "DSN005", "0002", OemToAnsi(STR0128),  14		, TIPO_CHAR , ""           		, "1", "txtInscrB",  "1"  ,  "1" , "", "" ,""} ) //"Novo Subitem" 
	AAdd( aValores, { "DSN005", "0003", OemToAnsi(STR0232), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "txtInscrA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"Conta de Passivo" 
	AAdd( aValores, { "DSN005", "0004", OemToAnsi(STR0095), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "txtInscrC",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0004')"} ) //"Varia��o Patrimonial Diminutiva" 
	
	AAdd( aValores, { "DSP001", "0001", OemToAnsi(STR0021),  9		, TIPO_CHAR , "99999-9"		 	, "1", "txtInscrD",  "1"  ,  "1" , "F761WhenCtr(.T.)", "" ,""} ) //"C�digo de Recolhimento GRU"
	AAdd( aValores, { "DSP001", "0002", OemToAnsi(STR0102),  14		, TIPO_CHAR ,"99.999.999/9999-99", "1", "txtInscrE",  "1"  ,  "1" , "F761WhenCtr()", "" ,"F761VCGC('C0002')"} ) //"Favorecido do Contrato"
	AAdd( aValores, { "DSP001", "0003", OemToAnsi(STR0095), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"Varia��o Patrimonial Diminutiva"
	AAdd( aValores, { "DSP001", "0004", OemToAnsi(STR0103), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0004')"} ) //"Contas a Pagar"
	AAdd( aValores, { "DSP001", "0005", OemToAnsi(STR0104), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassC",  "1"  ,  "2" , "F761WhenCtr()", "CT1" ,"F761VCT1('C0005')"} ) //"Ativo a Apropriar"
	AAdd( aValores, { "DSP001", "0006", OemToAnsi(STR0070), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassD",  "1"  ,  "2" , "F761WhenCtr()", "CT1" ,"F761VCT1('C0006')"} ) //"Conta de Contrato"
	
	AAdd( aValores, { "DSP005", "0001", OemToAnsi(STR0102),  14		, TIPO_CHAR ,"99.999.999/9999-99", "1", "txtInscrA",  "1"  ,  "1" , "F761WhenCtr()", "" ,"F761VCGC('C0001')"} ) //"Favorecido do Contrato" 
	AAdd( aValores, { "DSP005", "0002", OemToAnsi(STR0021),  6		, TIPO_CHAR , "99999-9"		 	, "1", "txtInscrD",  "1"  ,  "1" , "F761WhenCtr(.T.)", "" ,""} ) //"C�digo de Recolhimento GRU" 
	AAdd( aValores, { "DSP005", "0003", OemToAnsi(STR0233), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"VPD com Encargos Tribut�rios com Uni�o, Estados ou Munic�pios" 
	AAdd( aValores, { "DSP005", "0004", OemToAnsi(STR0234), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0004')"} ) //"Obriga��es Fiscais a Curto Prazo a Pagar" 
	AAdd( aValores, { "DSP005", "0005", OemToAnsi(STR0235), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassC",  "1"  ,  "2" , "F761WhenCtr()", "CT1" ,"F761VCT1('C0005')"} ) //"Tributos Pagos Antecipadamente" 
	AAdd( aValores, { "DSP005", "0006", OemToAnsi(STR0070), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassD",  "1"  ,  "2" , "F761WhenCtr()", "CT1" ,"F761VCT1('C0006')"} ) //"Conta de Contrato" 
	
	AAdd( aValores, { "DSP051", "0001", OemToAnsi(STR0102),  14		, TIPO_CHAR ,"99.999.999/9999-99", "1", "txtInscrD",  "1"  ,  "1" , "F761WhenCtr()", "" ,"F761VCGC('C0001')"} ) //Favorecido do Contrato 
	AAdd( aValores, { "DSP051", "0002", OemToAnsi(STR0095), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //Varia��o Patrimonial Diminutiva 
	AAdd( aValores, { "DSP051", "0003", OemToAnsi(STR0103), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //Contas a Pagar 
	AAdd( aValores, { "DSP051", "0004", OemToAnsi(STR0070), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassD",  "1"  ,  "2" , "F761WhenCtr()", "CT1" ,"F761VCT1('C0004')"} ) //Conta de Contrato 
	
	AAdd( aValores, { "DSP062", "0001", OemToAnsi(STR0157), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassD",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0001')"} ) //"VPD de Servi�o T�cnico Profissional" 
		
	AAdd( aValores, { "DSP101", "0001", OemToAnsi(STR0102),  14		, TIPO_CHAR ,"99.999.999/9999-99", "1", "txtInscrD",  "1"  ,  "1" , "F761WhenCtr()", "" ,"F761VCGC('C0001')"} ) //"Favorecido do Contrato"
	AAdd( aValores, { "DSP101", "0002", OemToAnsi(STR0021),  6		, TIPO_CHAR , "99999-9"		 	, "1", "txtInscrE",  "1"  ,  "1" , "F761WhenCtr(.T.)", "" ,""} ) //"C�digo de Recolhimento GRU"
	AAdd( aValores, { "DSP101", "0003", OemToAnsi(STR0105), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"Conta de Estoque"
	AAdd( aValores, { "DSP101", "0004", OemToAnsi(STR0103), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0004')"} ) //"Contas a Pagar"
	AAdd( aValores, { "DSP101", "0005", OemToAnsi(STR0070), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassD",  "1"  ,  "2" , "F761WhenCtr()", "CT1" ,"F761VCT1('C0005')"} ) //"Conta de Contrato"
	
	AAdd( aValores, { "DSP102", "0001", OemToAnsi(STR0102),  14		, TIPO_CHAR ,"99.999.999/9999-99", "1", "txtInscrD",  "1"  ,  "1" , "F761WhenCtr()", "" ,"F761VCGC('C0001')"} ) //"Favorecido do Contrato" 
	AAdd( aValores, { "DSP102", "0002", OemToAnsi(STR0021),  6		, TIPO_CHAR , "99999-9"		 	, "1", "txtInscrE",  "1"  ,  "1" , "F761WhenCtr(.T.)", "" ,""} ) //"C�digo de Recolhimento GRU" 
	AAdd( aValores, { "DSP102", "0003", OemToAnsi(STR0095), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"Varia��o Patrimonial Diminutiva"
	AAdd( aValores, { "DSP102", "0004", OemToAnsi(STR0103), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0004')"} ) //"Contas a Pagar"
	AAdd( aValores, { "DSP102", "0005", OemToAnsi(STR0105), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassC",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0005')"} ) //"Conta de Estoque"
	AAdd( aValores, { "DSP102", "0006", OemToAnsi(STR0070), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassD",  "1"  ,  "2" , "F761WhenCtr()", "CT1" ,"F761VCT1('C0006')"} ) //"Conta de Contrato"
	
	AAdd( aValores, { "DSP201", "0001", OemToAnsi(STR0102),  14		, TIPO_CHAR ,"99.999.999/9999-99", "1", "txtInscrE",  "1"  ,  "1" , "F761WhenCtr()", "" ,"F761VCGC('C0001')"} ) //"Favorecido do Contrato"
	AAdd( aValores, { "DSP201", "0002", OemToAnsi(STR0021),  6		, TIPO_CHAR , "99999-9"		 	, "1", "txtInscrD",  "1"  ,  "1" , "F761WhenCtr(.T.)", "" ,""} ) //"C�digo de Recolhimento GRU"
	AAdd( aValores, { "DSP201", "0003", OemToAnsi(STR0106), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"Conta de Bens M�veis"
	AAdd( aValores, { "DSP201", "0004", OemToAnsi(STR0103), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0004')"} ) //"Contas a Pagar"
	AAdd( aValores, { "DSP201", "0005", OemToAnsi(STR0070), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassD",  "1"  ,  "2" , "F761WhenCtr()", "CT1" ,"F761VCT1('C0005')"} ) //"Conta de Contrato"
	                                                                            
	AAdd( aValores, { "DSP215", "0001", OemToAnsi(STR0021),  6		, TIPO_CHAR , "99999-9"		 	, "1", "txtInscrD",  "1"  ,  "1" , "F761WhenCtr(.T.)", "" ,""} ) //"C�digo de Recolhimento GRU"
	AAdd( aValores, { "DSP215", "0002", OemToAnsi(STR0102),  14		, TIPO_CHAR ,"99.999.999/9999-99", "1", "txtInscrE",  "1"  ,  "1" , "F761WhenCtr()", "" ,"F761VCGC('C0002')"} ) //"Favorecido do Contrato"
	AAdd( aValores, { "DSP215", "0003", OemToAnsi(STR0107), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"Bem Intang�vel"
	AAdd( aValores, { "DSP215", "0004", OemToAnsi(STR0103), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0004')"} ) //"Contas a Pagar"
	AAdd( aValores, { "DSP215", "0005", OemToAnsi(STR0070), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassE",  "1"  ,  "2" , "F761WhenCtr()", "CT1" ,"F761VCT1('C0005')"} ) //"Conta de Contrato"
	                                                                            
	AAdd( aValores, { "DSP901", "0001", OemToAnsi(STR0021),  6		, TIPO_CHAR , "99999-9"		 	, "1", "txtInscrD",  "1"  ,  "1" , "F761WhenCtr(.T.)", "" ,""} ) //"C�digo de Recolhimento GRU"
	AAdd( aValores, { "DSP901", "0002", OemToAnsi(STR0108), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"Indeniza��es e Restitui��es a Pagar"
	                                                                            
	AAdd( aValores, { "DSP925", "0001", OemToAnsi(STR0102),  14		, TIPO_CHAR ,"99.999.999/9999-99", "1", "txtInscrE",  "1"  ,  "1" , "F761WhenCtr()", "" ,"F761VCGC('C0001')"} ) //"Favorecido do Contrato" 
	AAdd( aValores, { "DSP925", "0002", OemToAnsi(STR0236), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"Dep�sito p/ Recursos Judiciais" 
	AAdd( aValores, { "DSP925", "0003", OemToAnsi(STR0103), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassC",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"Contas a Pagar" 
	AAdd( aValores, { "DSP925", "0004", OemToAnsi(STR0070), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassD",  "1"  ,  "2" , "F761WhenCtr()", "CT1" ,"F761VCT1('C0004')"} ) //"Conta de Contratos" 
	                                                                            
	AAdd( aValores, { "DSP975", "0001", OemToAnsi(STR0021),  6		, TIPO_CHAR , "99999-9"		 	, "1", "txtInscrD",  "1"  ,  "1" , "F761WhenCtr(.T.)", "" ,""} ) //"C�digo de Recolhimento GRU" 
	AAdd( aValores, { "DSP975", "0002", OemToAnsi(STR0102),  14		, TIPO_CHAR ,"99.999.999/9999-99", "1", "txtInscrE",  "1"  ,  "1" , "F761WhenCtr()", "" ,"F761VCGC('C0002')"} ) //"Favorecido do Contrato" 
	AAdd( aValores, { "DSP975", "0003", OemToAnsi(STR0237), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"VPD - Juros/Encargos de mora" 
	AAdd( aValores, { "DSP975", "0004", OemToAnsi(STR0103), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0004')"} ) //"Contas a Pagar" 
	AAdd( aValores, { "DSP975", "0005", OemToAnsi(STR0070), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassD",  "1"  ,  "2" , "F761WhenCtr()", "CT1" ,"F761VCT1('C0005')"} ) //"Conta de Contratos" 
	                                                                            
	AAdd( aValores, { "DVL001", "0001", OemToAnsi(STR0121),  3		, TIPO_CHAR , ""		 			, "1", "txtInscrD",  "1"  ,  "1" , "", "" ,""} ) //"Vincula��o de Pagamento" 
	AAdd( aValores, { "DVL001", "0002", OemToAnsi(STR0102),  14		, TIPO_CHAR ,"99.999.999/9999-99", "1", "txtInscrE",  "1"  ,  "1" , "F761WhenCtr()", "CT1" ,"F761VCGC('C0002')"} ) //"Favorecido do Contrato" 
	AAdd( aValores, { "DVL001", "0003", OemToAnsi(STR0238), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"VPD de Servi�o Pessoas Jur�dicas" 
	AAdd( aValores, { "DVL001", "0004", OemToAnsi(STR0232), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0004')"} ) //"Conta de Passivo" 
	AAdd( aValores, { "DVL001", "0005", OemToAnsi(STR0070), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassE",  "1"  ,  "2" , "F761WhenCtr()", "CT1" ,"F761VCT1('C0005')"} ) //"Conta de Contrato" 
	                                                                            
	AAdd( aValores, { "DVL081", "0001", OemToAnsi(STR0121),  3		, TIPO_CHAR , ""		 		 	, "1", "txtInscrD",  "1"  ,  "1" , "", "" ,""} ) //"Vincula��o de Pagamento" 
	                                                                            
	AAdd( aValores, { "DVL973", "0001", OemToAnsi(STR0121),  3		, TIPO_CHAR , ""		 		 	, "1", "txtInscrD",  "1"  ,  "1" , "", "" ,""} ) //"Vincula��o de Pagamento" 
	AAdd( aValores, { "DVL973", "0002", OemToAnsi(STR0102),  14		, TIPO_CHAR ,"99.999.999/9999-99", "1", "txtInscrE",  "1"  ,  "1" , "F761WhenCtr()", "" ,"F761VCGC('C0002')"} ) //"Favorecido do Contrato" 
	AAdd( aValores, { "DVL973", "0003", OemToAnsi(STR0239), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"VPD de Juros/Encargos de Mora" 
	AAdd( aValores, { "DVL973", "0004", OemToAnsi(STR0232), nTamCT1, TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0004')"} ) //"Conta de Passivo" 
	AAdd( aValores, { "DVL973", "0005", OemToAnsi(STR0070),  9  	, TIPO_CHAR , cPicCT1			, "1", "numClassE",  "1"  ,  "2" , "F761WhenCtr()", "CT1" ,"F761VCT1('C0005')"} ) //"Conta de Contrato" 
	                                                                            
	AAdd( aValores, { "ENC001", "0001", OemToAnsi(STR0029),  4		, TIPO_CHAR , "9999"           	, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"C�digo de Pagamento GPS"
	AAdd( aValores, { "ENC001", "0002", OemToAnsi(STR0109),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"VPD de Encargos Patronais"
	AAdd( aValores, { "ENC001", "0003", OemToAnsi(STR0110),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"Encargos de INSS a Pagar"
	AAdd( aValores, { "ENC001", "0004", OemToAnsi(STR0029),  4		, TIPO_CHAR , "9999"           	, "1", "txtInscrA",  "1"  ,  "2" , "", "" ,""} ) //"C�digo de Pagamento GPS"	
	                                                                            
	AAdd( aValores, { "ENC002", "0001", OemToAnsi(STR0240),  3		, TIPO_CHAR , ""	           	, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"C�digo de Recolhimento GFIP" 
	AAdd( aValores, { "ENC002", "0002", OemToAnsi(STR0241),  14		, TIPO_CHAR , "99.999.999/9999-99", "1", "txtInscrB",  "1"  ,  "1" , "", "" ,"F761VCGC('C0002')"} ) //"Credor da GFIP" 
	AAdd( aValores, { "ENC002", "0003", OemToAnsi(STR0242),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"VPD de FGTS" 
	                                                                            
	AAdd( aValores, { "ENC004", "0001", OemToAnsi(STR0069),  4		, TIPO_CHAR , "9999"           	, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"C�digo de Recolhimento DARF" 
	AAdd( aValores, { "ENC004", "0002", OemToAnsi(STR0243),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"VPD com Imposto de Renda" 
	AAdd( aValores, { "ENC004", "0003", OemToAnsi(STR0244),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"IRPJ a Recolher" 
	                                                                            
	AAdd( aValores, { "ENC005", "0001", OemToAnsi(STR0069),  4		, TIPO_CHAR , "9999"           	, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"C�digo de Recolhimento DARF" 
	AAdd( aValores, { "ENC005", "0002", OemToAnsi(STR0245),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"VPD de PIS/PASEP" 
	AAdd( aValores, { "ENC005", "0003", OemToAnsi(STR0246),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"PIS/PASEP a Recolher" 
	                                                                            
	AAdd( aValores, { "ENC011", "0001", OemToAnsi(STR0069),  4		, TIPO_CHAR , "9999"           	, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"C�digo DARF"
	AAdd( aValores, { "ENC011", "0002", OemToAnsi(STR0109),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"VPD de Encargos Patronais"
	AAdd( aValores, { "ENC011", "0003", OemToAnsi(STR0069),  4		, TIPO_CHAR , "9999"           	, "1", "txtInscrA",  "1"  ,  "2" , "", "" ,""} ) //"C�digo DARF"
	                                                                            
	AAdd( aValores, { "ENC014", "0001", OemToAnsi(STR0247),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0001')"} ) //"VPD com Encargos Patronais - Prev. Privada e Assit. M�dica Hospitalar" 
	AAdd( aValores, { "ENC014", "0002", OemToAnsi(STR0248),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"Encargos de Previdencia Privada a Recolher" 
	                                                                            
	AAdd( aValores, { "ENC015", "0001", OemToAnsi(STR0111),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0001')"} ) //"VPD com Encargos Patronais - FUNPRESP"
	AAdd( aValores, { "ENC015", "0002", OemToAnsi(STR0112),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"Encargos Patronais a recolher - FUNPRESP"
	                                                                            
	AAdd( aValores, { "ENC021", "0001", OemToAnsi(STR0069),  4		, TIPO_CHAR , "9999"           	, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"C�digo de Recolhimento DARF" 
	AAdd( aValores, { "ENC021", "0002", OemToAnsi(STR0249),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"VPD com Encargos Tribut�rios com a Uni�o" 
	AAdd( aValores, { "ENC021", "0003", OemToAnsi(STR0250),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"Encargos Tribut�rios com a Uni�o a recolher" 
	                                                                            
	AAdd( aValores, { "ENC022", "0001", OemToAnsi(STR0251),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0001')"} ) //"VPD com Encargos Tribut�rios com Uni�o, Estados ou Municipios - Recolh. OB/GRU" 
	AAdd( aValores, { "ENC022", "0002", OemToAnsi(STR0252),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"Encargos Tribut�rios com Uni�o, Estados ou Municipios - Recolh.OB/GRU a recolher" 
                                                                                
	AAdd( aValores, { "ENC024", "0001", OemToAnsi(STR0029),  4		, TIPO_CHAR , "9999"           	, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"C�digo de Pagamento GPS" 
	AAdd( aValores, { "ENC024", "0002", OemToAnsi(STR0253),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"VPD com Encargos Patronais sobre servi�os de terceiros" 
	AAdd( aValores, { "ENC024", "0003", OemToAnsi(STR0254),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"Encargos Patronais sobre servi�os de terceiros a recolher" 
	                                                                            
	AAdd( aValores, { "ENC028", "0001", OemToAnsi(STR0021),  6		, TIPO_CHAR , "99999-9"        	, "1", "txtInscrA",  "1"  ,  "1" , "F761WhenCtr(.T.)", "" ,""} ) //"C�digo de Recolhimento GRU" 
	AAdd( aValores, { "ENC028", "0002", OemToAnsi(STR0255),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"VPD de Contribui��es Sociais" 
	AAdd( aValores, { "ENC028", "0003", OemToAnsi(STR0256),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"Obriga��es Fiscais a Recolher" 
	
	AAdd( aValores, { "ETQ001", "0001", OemToAnsi(STR0257),  2		, TIPO_CHAR , ""				   	, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"Subitem da Despesa" 
	AAdd( aValores, { "ETQ001", "0002", OemToAnsi(STR0258),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"Estoque de Materiais" 
	AAdd( aValores, { "ETQ001", "0003", OemToAnsi(STR0259),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"VPD de Consumo de Materiais/Distribui��o" 
	
	AAdd( aValores, { "ETQ027", "0001", OemToAnsi(STR0257),  12		, TIPO_CHAR , ""				   	, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"Subitem da Despesa" 
	AAdd( aValores, { "ETQ027", "0002", OemToAnsi(STR0260),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"Conta de Estoque transferidora" 
	AAdd( aValores, { "ETQ027", "0003", OemToAnsi(STR0261),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"Conta de Estoque recebedora" 
	
	AAdd( aValores, { "IMB070", "0001", OemToAnsi(STR0262),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0001')"} ) //"Bem M�veis de Refer�ncia" 
	
	AAdd( aValores, { "IMB071", "0001", OemToAnsi(STR0263),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0001')"} ) //"Bem Im�veis de Refer�ncia" 
	
	AAdd( aValores, { "INT001", "0001", OemToAnsi(STR0264),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0001')"} ) //"Amortiza��o Acumulada" 
	AAdd( aValores, { "INT001", "0002", OemToAnsi(STR0265),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"Bem Intang�vel de Refer�ncia" 
	
	AAdd( aValores, { "LDV011", "0001", OemToAnsi(STR0102),  12		, TIPO_CHAR ,"99.999.999/9999-99", "1", "txtInscrB",  "1"  ,  "1" , "F761WhenCtr()", "" ,"F761VCGC('C0001')"} ) //"Favorecido do Contrato" 
	AAdd( aValores, { "LDV011", "0002", OemToAnsi(STR0070),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "F761WhenCtr()", "CT1" ,"F761VCT1('C0002')"} ) //"Conta de Contrato" 

  	AAdd( aValores, { "LDV051", "0001", OemToAnsi(STR0208),  12		, TIPO_CHAR , ""				   	, "1", "txtInscrB",  "1"  ,  "1" , "", "" ,""} ) //"CNPJ, CPF, UG, IG OU 999" 
	AAdd( aValores, { "LDV051", "0002", OemToAnsi(STR0266),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"Responsabilidades com Terceiros" 
	
	AAdd( aValores, { "LDV052", "0001", OemToAnsi(STR0208),  12		, TIPO_CHAR , ""				   	, "1", "txtInscrB",  "1"  ,  "1" , "", "" ,""} ) //"CNPJ, CPF, UG, IG OU 999" 
	AAdd( aValores, { "LDV052", "0002", OemToAnsi(STR0266),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"Responsabilidades com Terceiros" 
	
	AAdd( aValores, { "LDV053", "0001", OemToAnsi(STR0208),  12		, TIPO_CHAR , ""				   	, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"CNPJ, CPF, UG, IG OU 999" 
	AAdd( aValores, { "LDV053", "0002", OemToAnsi(STR0267),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"Execu��o de Garantias/Contragarantias Recebidas" 
	
	AAdd( aValores, { "LPA301", "0001", OemToAnsi(STR0268),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0001')"} ) //"Pessoal ou Encargos a Pagar" 
	AAdd( aValores, { "LPA301", "0002", OemToAnsi(STR0095),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"Varia��o Patrimonial Diminutiva" 
	
	AAdd( aValores, { "LPA331", "0001", OemToAnsi(STR0095),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0001')"} ) //"Varia��o Patrimonial Diminutiva" 
	AAdd( aValores, { "LPA331", "0002", OemToAnsi(STR0232),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"Conta de Passivo" 
				
	AAdd( aValores, { "PRV001", "0001", OemToAnsi(STR0113),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "1" , "", "CT1" ,"F761VCT1('C0001')"} ) //"VPD com 13 Sal�rio"
	AAdd( aValores, { "PRV001", "0002", OemToAnsi(STR0114),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "1" , "", "CT1" ,"F761VCT1('C0002')"} ) //"13 Sal�rio a Pagar"
	
	AAdd( aValores, { "PRV002", "0001", OemToAnsi(STR0115),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "1" , "", "CT1" ,"F761VCT1('C0001')"} ) //"VPD com F�rias"
	AAdd( aValores, { "PRV002", "0002", OemToAnsi(STR0116),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "1" , "", "CT1" ,"F761VCT1('C0002')"} ) //"F�rias a Pagar"
	
	AAdd( aValores, { "PRV003", "0001", OemToAnsi(STR0113),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "1" , "", "CT1" ,"F761VCT1('C0001')"} ) //"VPD com 13 Sal�rio"
	AAdd( aValores, { "PRV003", "0002", OemToAnsi(STR0114),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "1" , "", "CT1" ,"F761VCT1('C0002')"} ) //"13 Sal�rio a Pagar"
	
	AAdd( aValores, { "PRV004", "0001", OemToAnsi(STR0117),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "1" , "", "CT1" ,"F761VCT1('C0001')"} ) //"Conta de Precat�rios"
	
	AAdd( aValores, { "PRV005", "0001", OemToAnsi(STR0081),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "1" , "", "CT1" ,"F761VCT1('C0001')"} ) //"Adiantamento Pessoal"
	
	AAdd( aValores, { "PRV006", "0001", OemToAnsi(STR0118),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "1" , "", "CT1" ,"F761VCT1('C0001')"} ) //"Pessoal a Pagar"
	
	AAdd( aValores, { "PRV007", "0001", OemToAnsi(STR0119),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "1" , "", "CT1" ,"F761VCT1('C0001')"} ) //"Obriga��es"
	AAdd( aValores, { "PRV007", "0002", OemToAnsi(STR0120),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "1" , "", "CT1" ,"F761VCT1('C0002')"} ) //"VPD"
	
	AAdd( aValores, { "PSO001", "0001", OemToAnsi(STR0021),  6		, TIPO_CHAR , "99999-9"        	, "1", "txtInscrA",  "1"  ,  "2" , "F761WhenCtr(.T.)", "" ,""} ) //"C�digo de Recolhimento GRU"
		
	AAdd( aValores, { "PSO002", "0001", OemToAnsi(STR0082),  14		, TIPO_CHAR , ""               	, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"N�mero da Ordem Banc�ria Cancelada (OB)"
	AAdd( aValores, { "PSO002", "0002", OemToAnsi(STR0021),  6		, TIPO_CHAR , "99999-9"        	, "1", "txtInscrB",  "1"  ,  "1" , "F761WhenCtr(.T.)", "" ,""} ) //"C�digo de Recolhimento GRU"

	AAdd( aValores, { "PSO006", "0001", OemToAnsi(STR0021),  6		, TIPO_CHAR , "99999-9"        	, "1", "txtInscrA",  "1"  ,  "2" , "F761WhenCtr(.T.)", "" ,""} ) //"C�digo de Recolhimento GRU"
	AAdd( aValores, { "PSO006", "0002", OemToAnsi(STR0028),  14		, TIPO_CHAR , ""               	, "1", "txtInscrB",  "1"  ,  "2" , "", "" ,""} ) //"Fonte de Recurso"	
	AAdd( aValores, { "PSO006", "0003", OemToAnsi(STR0121),  3 		, TIPO_CHAR , ""               	, "1", "txtInscrC",  "1"  ,  "2" , "", "" ,""} ) //"Vincula��o de Pagamento"
	AAdd( aValores, { "PSO006", "0004", OemToAnsi(STR0122),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0001')"} ) //"Classifica��o da Receita"
	
	AAdd( aValores, { "PSO023", "0001", OemToAnsi(STR0021),  6		, TIPO_CHAR , "99999-9"        	, "1", "txtInscrA",  "1"  ,  "1" , "F761WhenCtr(.T.)", "" ,""} ) //"C�digo de Recolhimento GRU" 
	AAdd( aValores, { "PSO023", "0002", OemToAnsi(STR0269),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"Dep�sitos diversos" 
	
	AAdd( aValores, { "PSO030", "0001", OemToAnsi(STR0270),  1		, TIPO_CHAR , ""				   	, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"Tipo de Arrecada�ao" 
	AAdd( aValores, { "PSO030", "0002", OemToAnsi(STR0271),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"ISS a Recolher" 
	AAdd( aValores, { "PSO030", "0003", OemToAnsi(STR0203),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"Classifica��o Or�ament�ria da Receita" 
	
	AAdd( aValores, { "PSO042", "0001", OemToAnsi(STR0272),  9		, TIPO_CHAR , ""				   	, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"Conta-corrente da conta Dep�sito" 
	AAdd( aValores, { "PSO042", "0002", OemToAnsi(STR0021),  6		, TIPO_CHAR , "99999-9"			, "1", "txtInscrD",  "1"  ,  "1" , "F761WhenCtr(.T.)", "" ,""} ) //"C�digo de Recolhimento GRU" 
	AAdd( aValores, { "PSO042", "0003", OemToAnsi(STR0273),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"Dep�sito de Diversas Origens" 
	
	AAdd( aValores, { "PSO045", "0001", OemToAnsi(STR0069),  4		, TIPO_CHAR , "9999"				, "1", "txtInscrD",  "1"  ,  "1" , "", "" ,""} ) //"C�digo de Recolhimento DARF" 
	AAdd( aValores, { "PSO045", "0002", OemToAnsi(STR0274),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassA",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0002')"} ) //"Obriga��es a Recolher" 
	AAdd( aValores, { "PSO045", "0003", OemToAnsi(STR0275),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassB",  "1"  ,  "2" , "", "CT1" ,"F761VCT1('C0003')"} ) //"Conta de VPD Tribut�ria" 
	
	AAdd( aValores, { "SPE003", "0001", OemToAnsi(STR0124),  12		, TIPO_CHAR , ""					, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"Empenho para Estorno"
	AAdd( aValores, { "SPE003", "0002", OemToAnsi(STR0125),  14		, TIPO_CHAR , ""					, "1", "txtInscrB",  "1"  ,  "1" , "", "" ,""} ) //"Subitem para Estorno"	
	AAdd( aValores, { "SPE003", "0003", OemToAnsi(STR0126),  14 	, TIPO_CHAR , ""					, "1", "txtInscrC",  "1"  ,  "1" , "", "" ,""} ) //"Agente Suprido ou 999"
	
	AAdd( aValores, { "SPN003", "0001", OemToAnsi(STR0127),  12		, TIPO_CHAR , ""					, "1", "txtInscrA",  "1"  ,  "1" , "", "" ,""} ) //"Novo Empenho"
	AAdd( aValores, { "SPN003", "0002", OemToAnsi(STR0128),  14		, TIPO_CHAR , ""					, "1", "txtInscrB",  "1"  ,  "1" , "", "" ,""} ) //"Novo Subitem"	
	AAdd( aValores, { "SPN003", "0003", OemToAnsi(STR0095),nTamCT1  , TIPO_CHAR , cPicCT1			, "1", "numClassC",  "1"  ,  "1" , "", "CT1","F761VCT1('C0003')" } ) //"Varia��o Patrimonial Diminutiva"
	
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
Fun��o para montar o filtro da consulta padr�o de situa��o 

@return cRet, String com a express�o que ser� considerada no filtro    

@author Pedro Alencar	
@since�23/10/2014
@version P12.1.2
/*/
Function FiltraFVJ()
	Local aAreaFVK	:= FVK->( GetArea() )		
	Local cSec		:= ""
	Local cFilFVK	:= FWxFilial("FVK")
	Local cRet		:= ""
	Local cField	:= ReadVar()
	Local cTipoDc	:= M->FV0_TIPODC

	If "FV2" $ cField //Folder 0002 - Principal com Or�amento
		cSec := "000002"
	ElseIf "FV8" $ cField //Folder 0003 - Principal sem Or�amento 
		cSec := "000003"
	ElseIf "FV9" $ cField //Folder 0003 - Principal sem Or�amento 
		cSec := "000003"
	ElseIf "FVF" $ cField //Folder 0004 - Cr�ditos 
		cSec := "000004"
	ElseIf "FVA" $ cField //Folder 0005 - Outros Lan�amentos
		cSec := "000005"
	ElseIf "FVB" $ cField //Folder 0007 - Encargos
		cSec := "000007"
	ElseIf "FVD" $ cField //Folder 0006 - Dedu��es 
		cSec := "000006"
	ElseIf "FVL" $ cField //Folder 0008 - Despesa a Anular
		cSec := "000008"		
	Else 
		cSec := ""
		
		//Limpa a vari�vel est�tica para n�o filtrar nada
		__cSituac := ""		
	EndIf  
	
	If !Empty( cSec ) .And. !Empty(cTipoDc)
		//Se for a mesma se��o utilizada na �ltima consulta, filtra com base nas situa��es que j� est�o no vetor est�tico 
		If cSec <> __cSecAnt .Or. cTipoDc <> __cTipoDc  						
			//Se for uma se��o diferente, l� a tabela novamente para pegar as situa��es a serem filtradas
			__cSituac := ""
			FVK->( dbSetOrder( 1 ) ) //Filial + Tipo Doc + Se��o + Situa��o
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

/*/{Protheus.doc}�FinGrvBx
Fun��o para efetuar a baixa/estorno de titulos a pagar e receber via execauto
A filial logada deve ser a correspondente a unidade pagadora

@author Pamela Bernardo Sousa
@param nCart  parametro define se a baixa/estorno ser� a pagar ou a receber
	1 = define carteira a receber
	2 = define carteira a pagar
@param cChave  Chave do titulo para baixa/estorno. 
				Esta chave deve conter xFilial() da filial de origem j� que o titulo pode ter uma unidade pagadora
				diferente da unidade original.
@param nOpc  Defino se o movimento ser� de baixa ou estorno.
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

@since�08/12/2014
@version�P12.1.3
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
		cHistorico := STR0090 + " " + cDocHabil // "Realiza��o de documento habil "
	Else
		cHistorico := STR0132 + " " + cDocHabil // "Cancelamento de Documento H�bil"
	EndIf 
	
	If nCart == 1
		lMsErroAuto := .F.
		dbSelectArea( "SE1" ) // T�tulo a Receber
		aSE1Area := SE1->(GetArea())
		SE1->(dbSetOrder(1)) // Filial + Prefixo + N�mero + Parcela + Tipo 
		
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
		dbSelectArea( "SE2" ) // T�tulo a Pagar
		aSE2Area := SE2->(GetArea())
		
		SE2->(dbSetOrder(1)) // Filial + Prefixo + N�mero + Parcela + Tipo + Fornecedor + Loja
		
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
Fun��o para validar o documento h�bil (SIAFI) est� habilitado 

@return lRet 	retorno l�gico de valida��o do uso ou n�o do documento h�bil    

@author Mauricio Pequim Junior
@since�27/11/2014
@version P12.1.3
/*/
Function FinUsaDH()
	//Verifica se uso do documento h�bil (SIAFI) est� habilitado
	If __lUsaDH == NIL
		__lUsaDH := SuperGetmv("MV_USADH",,'2') == '1'
	Endif
Return __lUsaDH

/*/{Protheus.doc} FinTemDH()
Fun��o para validar se um titulo est� relacionado a um documento h�bil 

@param lFiltro	Indica se a rotina deve retornar uma expressao de filtro ou valor l�gico para valida��o
@param cAlias	Alias a ser considerado para valida��o ou filtro
@param lHelp	Indica se o help ser� mostrado ou n�o
@param lTop		Indica se a express�o de filtro deve ser no padr�o codebase (.F.) ou SQL (.T.)

@return xRet 	String com a express�o que ser� considerada no filtro ou retorno l�gico de valida��o    

@author Mauricio Pequim Junior
@since�27/11/2014
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
				HELP(" ",1,"DOCTO_HABIL",, 	STR0087+CRLF+; //"Este t�tulo est� relacionado a um documento h�bil."
											   	STR0088+CRLF+; //"T�tulos nesta situa��o n�o podem sofrer qualquer a��o/altera��o."
											   	STR0089,2,0)	 //"Caso necessite, acesse o documento h�bil e retire o t�tulo do mesmo."
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
Fun��o para informar os dados de login de acesso a WebService ManterContasPagarReceber do SIAFI

@return aLogin[1] Retorna o login informado
@return aLogin[2] Retorna a senha informada

@author Marylly Ara�jo Silva
@since�13/01/2015
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
Fun��o que busca o tipo de pr�-doc que ser� carregado quando clicar no bot�o Pr�-doc do documento h�bil.
@author William Matos Gundim Jr
@since�15/01/2015
@version 12.1.5
@param cSituac C�digo de Identifica��o informado na Situa��o do Documento H�bil
/*/
Function LoadPreDoc(cSituac)
Local cRet := ''
//1=OB;2=NS;3=GRU;4=GPS;5=GFIP;6=DAR;7=DARF
cRet := POSICIONE('FVJ', 1, FWxFilial('FVJ') + cSituac , 'FVJ_PREDOC')
Return cRet

/*/{Protheus.doc} GTpForOrg()
Fun��o que verifica se o fornecedor � oficial (�rg�o P�blico) ou fornecedor comum (Privado)
@author Marylly Ara�jo Silva
@since�20/05/2015
@version 12.1.5
@param cFornec C�digo de identifica��o do fornecedor
@param cLoja C�digo de identifica��o da loja/filial do fornecedor
/*/
Function GTpForOrg(cFornec,cLoja)
Local nRet 		:= 0
Local aArea		:= GetArea()
Local aCPAArea	:= {}
Local aSA2Area	:= {}

DbSelectArea("CPA") // �rg�os P�blicos
aCPAArea := CPA->(GetArea())
CPA->(DbSetOrder(1)) // Filial + C�digo �rg�o

DbSelectArea("SA2")
aSA2Area := SA2->(GetArea())
SA2->(DbSetOrder(1)) // Filial + C�digo + Lojaadmin

If CPA->(DbSeek(FWxFilial("CPA") + cFornec))
	nRet := 2 // �rg�o P�blico (Fornecedor Oficial)
ElseIf SA2->(DbSeek(FWxFilial("SA2") + cFornec + cLoja ) )
	nRet := 1 // Fornecedor Privado
EndIf
		
RestArea(aArea)	
RestArea(aCPAArea)
RestArea(aSA2Area)
Return nRet

/*/{Protheus.doc} FinGrvMov()
Fun��o que gera movimenta��es de pagamento ou estorno de pagamento para o documento h�bil.
@author Marylly Ara�jo Silva
@since�12/06/2015
@version 12.1.6
@param cFornec C�digo de identifica��o do fornecedor
@param cLoja C�digo de identifica��o da loja/filial do fornecedor
/*/
Function FinGrvMov(dDataMov, dDataPag, nValorMov, cCarteira, cFontRec, cDocHabil, nOpc, cIdMov)
Local lRet		:= .T.
Local cHistorico	:= ""
Local aCab		:= {}

Local oModelMov	:= FWLoadModel("FINM030") //Model de Movimento Banc�rio
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
	//Define os campos que n�o existem nas FKs e que ser�o gravados apenas na E5, para que a grava��o da E5 continue igual
	//Estrutura para o E5_CAMPOS: "{{'SE5->CAMPO', Valor}, {'SE5->CAMPO', Valor}}|{{'SE5->CAMPO', Valor}, {'SE5->CAMPO', Valor}}"
	If !Empty(cCamposE5)
		cCamposE5 += "|"
	Endif
	cCamposE5 += "{"		
	cCamposE5 += "{'E5_DTDIGIT', dDataBase}"
	cCamposE5 += "}"
	oModelMov:SetOperation( MODEL_OPERATION_INSERT ) //Inser��o
	cHistorico := STR0090 + " - " + cDocHabil // "Realiza��o DH "
	oModelMov:Activate()
	oModelMov:SetValue( "MASTER", "E5_GRV"		, .T. ) //Informa se vai gravar SE5 ou n�o
	oModelMov:SetValue( "MASTER", "E5_CAMPOS"	, cCamposE5 ) //Informa os campos da SE5 que ser�o gravados indepentes de FK5
	oModelMov:SetValue( "MASTER", "NOVOPROC", .T. ) //Informa que a inclus�o ser� feita com um novo n�mero de processo
	
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
	 * Tipo do Documento da Movimenta��o Financeira
	 */
	oSubFK5:SetValue( "FK5_TPDOC"	, "VL" )
	/*
	 * Dados Banc�rios da Movimenta��o Financeira
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
	 * Identifica��o do Documento do Movimento Financeiro
	 */
	oSubFK5:SetValue( "FK5_DOC"	, cDocHabil )
	/*
	 * Hist�rico do Movimento Financeiro
	 */
	oSubFK5:SetValue( "FK5_HISTOR", cHistorico )
	
	cIdMov := oSubFKA:GetValue("FKA_IDORIG")
Else
	dbSelectArea( "SE5" )
	SE5->( DbSetOrder( 21 ) ) //E5_FILIAL + E5_IDORIG				
	If SE5->( msSeek( FWxFilial("SE5") + cIdMov ) )
		oModelMov:SetOperation( MODEL_OPERATION_DELETE ) //Dele��o
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