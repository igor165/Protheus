#ifdef SPANISH
	#define STR0001 "SUELDOS Y JORNALES"
	#define STR0002 "REGISTRO PATRONAL Nº"
	#define STR0003 "SEMESTRE Año"
	#define STR0004 "Razón Social o PRP :"
	#define STR0005 "Explotación : "
	#define STR0006 "Domicilio : "
	#define STR0007 "N. de"
	#define STR0008 "Or-"
	#define STR0009 "den"
	#define STR0010 "Nombre y Apellido"
	#define STR0011 "SALARIO"
	#define STR0012 "MES DE"
	#define STR0013 "Forma de Importe"
	#define STR0014 "Pago"
	#define STR0015 "unitario"
	#define STR0016 "Horas"
	#define STR0017 "Trab."
	#define STR0018 "Remuner."
	#define STR0019 "Percib"
	#define STR0020 "Total Hs."
	#define STR0021 "Extras"
	#define STR0022 "50% 100%"
	#define STR0023 "IMPOR"
	#define STR0024 "TE"
	#define STR0025 "Hs Ex-"
	#define STR0026 "tras"
	#define STR0027 "Tot.hs.en"
	#define STR0028 "el semes-"
	#define STR0029 "tre incluy."
	#define STR0030 "Hs.Ext."
	#define STR0031 "Total de "
	#define STR0032 "Salario"
	#define STR0033 "incluyendo"
	#define STR0034 "Hs.ext."
	#define STR0035 "BENEFICIOS SOCIALES"
	#define STR0036 "Aguinaldo"
	#define STR0037 "Bonificacion"
	#define STR0038 "Fliar"
	#define STR0039 "Vacación"
	#define STR0040 "Otros"
	#define STR0041 "Beneficios"
	#define STR0042 "TOTAL GENERAL"
	#define STR0043 "Incluyendo hs"
	#define STR0044 "extras y bene-"
	#define STR0045 "ficios sociales"
	#define STR0046 "A TRANSPORTAR"
	#define STR0047 "TRANSPORTE"
#else
	#ifdef ENGLISH
		#define STR0001 "SALARIES AND WAGES"
		#define STR0002 "EMPLOYER RECORD No."
		#define STR0003 "SEMESTER Year"
		#define STR0004 "Company Name or PRP:"
		#define STR0005 "Exploration :"
		#define STR0006 "Residence: "
		#define STR0007 "No. of"
		#define STR0008 "Or-"
		#define STR0009 "den"
		#define STR0010 "Name and Surname"
		#define STR0011 "SALARY"
		#define STR0012 "MONTH OF"
		#define STR0013 "Import Method"
		#define STR0014 "Paymt"
		#define STR0015 "unitary"
		#define STR0016 "Hours"
		#define STR0017 "Work"
		#define STR0018 "Compens."
		#define STR0019 "Perceb"
		#define STR0020 "Total of"
		#define STR0021 "Overtime"
		#define STR0022 "50% 100%"
		#define STR0023 "VA"
		#define STR0024 "LUE"
		#define STR0025 "Over"
		#define STR0026 "time"
		#define STR0027 "Total of hours"
		#define STR0028 "in the"
		#define STR0029 "semester includes"
		#define STR0030 "Overtime"
		#define STR0031 "Total of "
		#define STR0032 "Salary"
		#define STR0033 "including"
		#define STR0034 "Overtime"
		#define STR0035 "SOCIAL BENEFITS"
		#define STR0036 "Year-end bonus"
		#define STR0037 "Bonus"
		#define STR0038 "Fliar"
		#define STR0039 "Vacation"
		#define STR0040 "Others"
		#define STR0041 "Benefits"
		#define STR0042 "GRAND TOTAL"
		#define STR0043 "Including"
		#define STR0044 "Overtime and"
		#define STR0045 "Social benefits"
		#define STR0046 "TO TRANSPORT"
		#define STR0047 "TRANSPORT"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Salários E Diárias", "SALÁRIOS E DIÁRIAS" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Registo Patronal Núm.", "REGISTRO PATRONAL Nº" )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Semestre Ano", "SEMESTRE Ano" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Razão social o prp :", "Razão Social ou PRP:" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Exploração : ", "Exploração  : " )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Domicílio : ", "Endereço  : " )
		#define STR0007 "N. de"
		#define STR0008 "Or-"
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Den", "dem" )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "Nome E Apelido", "Nome e Sobrenome" )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "Salário", "SALÁRIO" )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "Mês De", "MÊS DE" )
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "Forma De Importação", "Forma de Pagamento" )
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "Pago", "Pagamento" )
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "Unitário", "unitário" )
		#define STR0016 "Horas"
		#define STR0017 "Trab."
		#define STR0018 "Remuner."
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "Percib", "Receb" )
		#define STR0020 "Total Hs."
		#define STR0021 "Extras"
		#define STR0022 "50% 100%"
		#define STR0023 If( cPaisLoc $ "ANG|PTG", "Impor", "VA" )
		#define STR0024 If( cPaisLoc $ "ANG|PTG", "Te", "LOR" )
		#define STR0025 "Hs Ex-"
		#define STR0026 If( cPaisLoc $ "ANG|PTG", "Tras", "tras" )
		#define STR0027 If( cPaisLoc $ "ANG|PTG", "Tot.hs.en", "Tot.hs." )
		#define STR0028 If( cPaisLoc $ "ANG|PTG", "El semes-", "no semes-" )
		#define STR0029 If( cPaisLoc $ "ANG|PTG", "Tre incluy.", "tre inclui" )
		#define STR0030 If( cPaisLoc $ "ANG|PTG", "Hs.ext.", "Hs.Ext." )
		#define STR0031 "Total de "
		#define STR0032 "Salário"
		#define STR0033 If( cPaisLoc $ "ANG|PTG", "Incluyndo", "incluindo" )
		#define STR0034 "Hs.ext."
		#define STR0035 If( cPaisLoc $ "ANG|PTG", "Benefícios Sociais", "BENEFÍCIOS SOCIAIS" )
		#define STR0036 "13º salário"
		#define STR0037 If( cPaisLoc $ "ANG|PTG", "Bonificação", "Bônus" )
		#define STR0038 "Fliar"
		#define STR0039 "Férias"
		#define STR0040 "Outros"
		#define STR0041 "Benefícios"
		#define STR0042 If( cPaisLoc $ "ANG|PTG", "Total Geral", "TOTAL GERAL" )
		#define STR0043 If( cPaisLoc $ "ANG|PTG", "Incluyndo hs", "Incluindo hs" )
		#define STR0044 If( cPaisLoc $ "ANG|PTG", "Extras y bene-", "extras e bene-" )
		#define STR0045 If( cPaisLoc $ "ANG|PTG", "Ficios sociales", "fícios sociais" )
		#define STR0046 If( cPaisLoc $ "ANG|PTG", "A Transportar", "A TRANSPORTAR" )
		#define STR0047 If( cPaisLoc $ "ANG|PTG", "Transporte", "TRANSPORTE" )
	#endif
#endif
