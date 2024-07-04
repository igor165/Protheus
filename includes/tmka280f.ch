#ifdef SPANISH
	#define STR0001 " Datos del Cliente y Contacto"
	#define STR0002 "Cliente"
	#define STR0003 "Contacto"
	#define STR0004 " Titulos Pendientes"
	#define STR0005 "Titulos"
	#define STR0006 "Totales"
	#define STR0007 "Deducciones"
	#define STR0008 "Corr. Monet."
	#define STR0009 "Intereses"
	#define STR0010 "Descuentos"
	#define STR0011 "Aumentos"
	#define STR0012 "Reducciones"
	#define STR0013 "Sld Mda Tit."
	#define STR0014 "Sld Mda Corr."
	#define STR0015 "Valor Original"
	#define STR0016 "Pago Parcial"
	#define STR0017 "Deud Mda Tit"
	#define STR0018 "Deud Mda Corr"
	#define STR0019 "Saldo"
	#define STR0020 "Sld.Correg.Mda.Tit"
	#define STR0021 "Saldo Correg."
#else
	#ifdef ENGLISH
		#define STR0001 " Customer Data and Contact"
		#define STR0002 "Customer"
		#define STR0003 "Contact"
		#define STR0004 " Open Bills"
		#define STR0005 "Bills"
		#define STR0006 "Total"
		#define STR0007 "Deductions"
		#define STR0008 "Monet. Adj."
		#define STR0009 "Interests"
		#define STR0010 "Deductions"
		#define STR0011 "Increases"
		#define STR0012 "Decreases"
		#define STR0013 "Bal Mda Bill"
		#define STR0014 "Bal. Mda Corr."
		#define STR0015 "Original Value"
		#define STR0016 "Partial Paymt."
		#define STR0017 "Debt Mda Bill"
		#define STR0018 "Debt Mda Corr"
		#define STR0019 "Balance"
		#define STR0020 "Bill Curr Corr Bal"
		#define STR0021 "Corr Balance"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", " Dados Do Cliente E Contacto", " Dados do Cliente e Contato" )
		#define STR0002 "Cliente"
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Contacto", "Contato" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", " T�tulos Em Aberto", " T�tulos em Aberto" )
		#define STR0005 "T�tulos"
		#define STR0006 "Totais"
		#define STR0007 "Abatimentos"
		#define STR0008 "Corr. Monet."
		#define STR0009 "Juros"
		#define STR0010 "Descontos"
		#define STR0011 "Acr�scimos"
		#define STR0012 "Decr�scimos"
		#define STR0013 "Sld Mda Tit."
		#define STR0014 "Sld Mda Corr."
		#define STR0015 "Valor Original"
		#define STR0016 "Pagto Parcial"
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "Div Mda Tit", "D�v Mda T�t" )
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "Div Mda Corr", "D�v Mda Corr" )
		#define STR0019 "Saldo"
		#define STR0020 "Sld.Corrig.Mda.Tit"
		#define STR0021 "Saldo Corrig."
	#endif
#endif
