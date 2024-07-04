#ifdef SPANISH
	#define STR0001 "Matrícula"
	#define STR0002 "C Costo"
	#define STR0003 "Nomb"
	#define STR0004 "Planilla de AFP"
	#define STR0005 "AFP : "
	#define STR0006 "Emision de la planilla de pago de cotizaciones previsionales y depósitos voluntarios."
	#define STR0007 "Se imprimirá de acuerdo con los parámetros solicitados por"
	#define STR0008 "el usuario."
	#define STR0009 "A rayas"
	#define STR0010 "Administración"
	#define STR0011 "EMISIÓN DE LIBRO DE REMUNERACIONES"
	#define STR0012 "Página : "
	#define STR0013 "Período: "
	#define STR0014 "D E T A L L E   D E   C O T I Z A C I O N E S   P R E V I S I O N A L E S"
	#define STR0015 "RUT EMPLEADOR : "
	#define STR0016 "NOMBRE O RAZÓN SOCIAL : "
	#define STR0017 "       MONTO   COTIZACIÓN   COTIZACIÓN    CUENTA DE FECHA      FECHA     RUT ENTIDAD"
	#define STR0018 "CÓDIGO RUT            NOMBRE                       IMPONIBLE  OBLIGATORIA   VOLUNTARIA       AHORRO INICIO     TÉRMINO   PAGADORA   "
	#define STR0019 "TOTAL PÁGINA    :"
	#define STR0020 "TOTAL ACUMULADO :"
	#define STR0021 "TOTAL IMPONENTES : "
	#define STR0022 "MONTO IMPONIBLE"
	#define STR0023 "COTIZACIÓN OBLIGATORIA"
	#define STR0024 "COTIZACIÓN VOLUNTARIA"
	#define STR0025 "CUENTA DE AHORRO"
	#define STR0026 "COTIZACIÓN A PAGAR"
	#define STR0027 "TOTAL IMPONENTES"
	#define STR0028 "PLANILLA DE PAGO DE COTIZACIONES PREVISIONALES Y DEPÓSITOS VOLUNTARIOS"
	#define STR0029 "LUGAR DE INTEGRO PREVISIONAL : "
#else
	#ifdef ENGLISH
		#define STR0001 "Registration"
		#define STR0002 "Cost Center"
		#define STR0003 "Name"
		#define STR0004 "AFPs spreadsheet"
		#define STR0005 "AFP : "
		#define STR0006 "Issue of spreadsheet with social security contribution payments and voluntary deposits."
		#define STR0007 "It will be printed in accordance with the parameters requested by the"
		#define STR0008 "user."
		#define STR0009 "Z-form"
		#define STR0010 "Management"
		#define STR0011 "ISSUE OF COMPENSATIONS BOOK"
		#define STR0012 "Page : "
		#define STR0013 "Period: "
		#define STR0014 "S O C I A L S E C U R I T Y C O N T R I B U T I O N S D E T A I L"
		#define STR0015 "EMPLOYER CNPJ:"
		#define STR0016 "NAME OR CORPORATE NAME:"
		#define STR0017 "CONTRIBUTION VALUE CONTRIBUTION ACCOUNT FROM DATE DATE ENTITY CNPJ"
		#define STR0018 "CNPJ CODE NAME TAXABLE REQUIRED VOLUNTARY SAVINGS START END PAYER"
		#define STR0019 "PAGE TOTAL    :"
		#define STR0020 "ACCRUED TOTAL :"
		#define STR0021 "TAXABLES TOTAL:"
		#define STR0022 "TAXABLE VALUE"
		#define STR0023 "REQUIRED CONTRIBUTION"
		#define STR0024 "VOLUNTARY CONTRIBUTION"
		#define STR0025 "SAVINGS ACCOUNT"
		#define STR0026 "CONTRIBUTION PAYABLE"
		#define STR0027 "TAXABLES TOTAL"
		#define STR0028 "SPREADSHEET WITH SOCIAL SECURITY CONTRIBUTION PAYMENTS AND VOLUNTARY DEPOSITS."
		#define STR0029 "LOCATION OF SOCIAL SECURITY INTEGRAL:"
	#else
		#define STR0001 "Matrícula"
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "C.custo", "C.Custo" )
		#define STR0003 "Nome"
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Folha De C+alculo De Afps", "Planilha de AFPs" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Afp : ", "AFP : " )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Emissão da folha de cálculo de pagamento de quotizações previsionais e depósitos voluntários.", "Emissão da planilha de pagamento de cotizações previdenciárias e depósitos voluntários." )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Será impresso de acordo com os parâmetros requeridos por", "Será impresso segundo os parâmetros solicitados pelo" )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "El utilizador.", "usuário." )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "A Rayas", "Zebrado" )
		#define STR0010 "Administração"
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "Emissão Do Livro De Remunerações", "EMISSÃO DE LIVRO DE REMUNERAÇÕES" )
		#define STR0012 "Página : "
		#define STR0013 "Período: "
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "Detalhe De Cotizações Previsionais", "D E T A L H E   D E   C O T I Z A Ç Õ E S   P R E V I D E N C I Á R I A S" )
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "NIB empregador : ", "CNPJ EMPREGADOR : " )
		#define STR0016 If( cPaisLoc $ "ANG|PTG", "Nome o razão social : ", "NOME OU RAZÃO SOCIAL : " )
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "       Montante   Quotização   Quotização    Conta De Data      Data     NIB Entidade", "       VALOR   COTIZAÇÃO   COTIZAÇÃO    CONTA DE DATA      DATA     CNPJ ENTIDAD" )
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "Código NIB            nome                       tributável  obrigatória   voluntária       poupança início     término   pagadora   ", "CÓDIGO CNPJ           NOME                       TRIBUTÁVEL OBRIGATÓRIA   VOLUNTÁRIA       POUPANÇA  INÍCIO     TÉRMINO  PAGADORA   " )
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "Total página    :", "TOTAL PÁGINA    :" )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "Total acumulado :", "TOTAL ACUMULADO :" )
		#define STR0021 If( cPaisLoc $ "ANG|PTG", "TOtal imponentes : ", "TOTAL TRIBUTÁVEIS: " )
		#define STR0022 If( cPaisLoc $ "ANG|PTG", "Base Imponível", "VALOR TRIBUTÁVEL" )
		#define STR0023 If( cPaisLoc $ "ANG|PTG", "Cotização Obrigatória", "COTIZAÇÃO OBRIGATÓRIA" )
		#define STR0024 If( cPaisLoc $ "ANG|PTG", "Quotização Voluntária", "COTIZAÇÃO VOLUNTÁRIA" )
		#define STR0025 If( cPaisLoc $ "ANG|PTG", "Conta De Aforro", "CONTA POUPANÇA" )
		#define STR0026 If( cPaisLoc $ "ANG|PTG", "Quotização A Pagar", "COTIZAÇÃO A PAGAR" )
		#define STR0027 If( cPaisLoc $ "ANG|PTG", "Total Imponentes", "TOTAL TRIBUTÁVEIS" )
		#define STR0028 If( cPaisLoc $ "ANG|PTG", "Folha De Cálculo De Pagamento De Quotizações Previsionais E Depósitos Voluntários", "PLANILHA DE PAGAMENTO DE COTIZAÇÕES PREVIDENCIÁRIAS E DEPÓSITOS VOLUNTÁRIOS" )
		#define STR0029 If( cPaisLoc $ "ANG|PTG", "Lugar de integração previsional", "LOCAL DE ÍNTEGRO PREVIDENCIÁRIO : " )
	#endif
#endif
