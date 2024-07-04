#ifdef SPANISH
	#define STR0001 "Este programa emitirá la lista del valor recuperable de activos "
	#define STR0002 "efectuados dentro de un período."
	#define STR0003 "Lista del valor recuperable de los bienes"
	#define STR0004 "Cuenta"
	#define STR0005 "C. Costo"
	#define STR0006 "Fecha de adquisición"
	#define STR0007 "Base       Ítem Descripción                              Adquisic.  Cantidad     Factura    Placa    Grupo    C. Costo  Dirección"
	#define STR0008 "                In.Depr.  Ts.Depr.       Valor original    Deprec. Acumulada   Correc Acumulada    Fecha de la baja"
	#define STR0009 " por "
	#define STR0010 " en "
	#define STR0011 " entre "
	#define STR0012 " a "
	#define STR0013 "ANULADO POR EL OPERADOR"
	#define STR0014 "PROVEEDOR "
	#define STR0015 "Cuenta del bien      Cuenta corrección    Cta.Gast.Depr.       Cta.Depr.Acum.       Cta.Corr.Depr. "
	#define STR0016 "TOTAL "
	#define STR0017 "TOTAL GENERAL: "
	#define STR0018 "A rayas"
	#define STR0019 "Administración"
	#define STR0020 "Seleccionando registros..."
	#define STR0021 "Datos del bien"
	#define STR0022 "Total de la cuenta"
	#define STR0023 "Total del centro de costo"
	#define STR0024 "Total de la fecha de adquisición"
	#define STR0025 "Total de la sucursal:"
	#define STR0026 "In.Depr"
	#define STR0027 "Ts.Depr."
	#define STR0028 "Valor original"
	#define STR0029 "Deprec. Acumulada"
	#define STR0030 "Correccion acumulada"
#else
	#ifdef ENGLISH
		#define STR0001 "This program issues a list of assets recoverable assets"
		#define STR0002 "performed within a period."
		#define STR0003 "Relation of assets recoverable value"
		#define STR0004 "Account"
		#define STR0005 "C. Center"
		#define STR0006 "Acquisition Date"
		#define STR0007 "Base  Item Description                 Acquis.   Amount       Invoices Plate    Group    C. Address Cost"
		#define STR0008 "                In.Depr.  Tx.Depr.       Original Value Deprec. Accrued  Correction Accrued  Write-off Date"
		#define STR0009 " by "
		#define STR0010 " in  "
		#define STR0011 " between "
		#define STR0012 " to "
		#define STR0013 "CANCELLED BY THE OPERATOR"
		#define STR0014 "SUPPLIER "
		#define STR0015 "Asset account        Correction Account      Account Exp. Depr.       Account Accr. Depr.       Curr. Acc. Depr. "
		#define STR0016 "TOTAL "
		#define STR0017 "GRAND TOTAL: "
		#define STR0018 "Z-form"
		#define STR0019 "Management"
		#define STR0020 "Selecting Records..."
		#define STR0021 "Asset Information"
		#define STR0022 "Account total"
		#define STR0023 "Cost Center Total"
		#define STR0024 "Total of Acquisition Date"
		#define STR0025 "Branch Total:"
		#define STR0026 "Depre In"
		#define STR0027 "Depr.Rt."
		#define STR0028 "Original Value"
		#define STR0029 "Accrued Deprec."
		#define STR0030 "Accrued Correction"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Este programa emitirá a relação do valor recuperável de activos", "Este programa irá emitir a relação do valor recuperavel de ativos" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "efectuadas dentro de um período.", "efetuadas dentro de um periodo." )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Relação do valor recuperável dos bens", "Relacao do valor recuperavel dos bens" )
		#define STR0004 "Conta"
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "C.Custo", "C Custo" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Data Obtenção", "Data Aquisicao" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Base       Elem Descrição                                Obtenç.   Quantidade   Factura Chapa    Grupo    C.Custo  Endereço", "Base       Item Descricao                                Aquisic.   Quantidade   Nota Fisc. Chapa    Grupo    C. Custo  Endereco" )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "                In.Depr.  Tx.Depr.       Valor Original    Deprec. Acumulada   Correcção Acumulada  Data da Liquidação", "                In.Depr.  Tx.Depr.       Valor Original    Deprec. Acumulada   Correcao Acumulada  Data da Baixa" )
		#define STR0009 " por "
		#define STR0010 " em "
		#define STR0011 " entre "
		#define STR0012 " a "
		#define STR0013 "CANCELADO PELO OPERADOR"
		#define STR0014 "FORNECEDOR "
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "Conta do Bem         Conta Correcção       Cta.Desp.Depr.       Cta.Depr.Acum.       Cta.Corr.Depr. ", "Conta do Bem         Conta Correcao       Cta.Desp.Depr.       Cta.Depr.Acum.       Cta.Corr.Depr. " )
		#define STR0016 "TOTAL : "
		#define STR0017 "TOTAL GERAL: "
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "Código de Barras", "Zebrado" )
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "Administração", "Administracao" )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "A Seleccionar Registos...", "Selecionando Registros..." )
		#define STR0021 "Dados do Bem"
		#define STR0022 "Total da Conta"
		#define STR0023 "Total do Centro de Custo"
		#define STR0024 If( cPaisLoc $ "ANG|PTG", "Total da Data de Obtenção", "Total da Data de Aquisição" )
		#define STR0025 "Total da Filial:"
		#define STR0026 If( cPaisLoc $ "ANG|PTG", "In.Depr.", "In.Depr" )
		#define STR0027 "Tx.Depr."
		#define STR0028 If( cPaisLoc $ "ANG|PTG", "Valor original", "Valor Original" )
		#define STR0029 "Deprec. Acumulada"
		#define STR0030 If( cPaisLoc $ "ANG|PTG", "Correcção acumulada", "Correcao Acumulada" )
	#endif
#endif
