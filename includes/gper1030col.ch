#ifdef SPANISH
	#define STR0001 "Emisión de Recibos de Pago"
	#define STR0002 "Recibo de Pago"
	#define STR0003 "Recibo No."
	#define STR0004 "Periodo:"
	#define STR0005 "Pago:"
	#define STR0006 "Periodo de Pago:"
	#define STR0007 "Fecha de Pago:"
	#define STR0008 "Sucursal:"
	#define STR0009 "Matrícula:"
	#define STR0010 "Nombre:"
	#define STR0011 "Tipo ID:"
	#define STR0012 "No. ID:"
	#define STR0013 "Función:"
	#define STR0014 "Desc:"
	#define STR0015 "Cargo:"
	#define STR0016 "C.Costo:"
	#define STR0017 "Depto:"
	#define STR0018 "ARL:"
	#define STR0019 "EPS:"
	#define STR0020 "AFP:"
	#define STR0021 "CCF:"
	#define STR0022 "Banco Emp:"
	#define STR0023 "Banco CIA:"
	#define STR0024 "Sueldo:"
	#define STR0025 "Hrs. Men:"
	#define STR0026 "Grossup:"
	#define STR0027 "Devengos"
	#define STR0028 "Descuentos"
	#define STR0029 "Bases"
	#define STR0030 "Concepto"
	#define STR0031 "Hrs./Día"
	#define STR0032 "Importes"
	#define STR0033 "Base"
	#define STR0034 "Total Devengos:"
	#define STR0035 "Total Descuentos:"
	#define STR0036 "Total Bases:"
	#define STR0037 "Neto Recibido (S/.):"
	#define STR0038 "Cuenta:"
	#define STR0039 "Recibí el valor anterior el __/__/___ ___________________________________________"
	#define STR0040 "Empleado"
	#define STR0041 "Banco:"
	#define STR0042 "Neto Recibido:"
	#define STR0043 "Cta.:"
	#define STR0044 "Recibí el valor anterior el ___/___/____"
	#define STR0045 "El servidor SMTP no está cnfigurado "
	#define STR0046 "La cuenta de e-mail no está configurada "
	#define STR0047 "La contraseña del email no está configurada "
	#define STR0048 "Errores ocurridos durante el envío de los comprobantes de pago"
	#define STR0049 "Sr.(a)"
	#define STR0050 "Ocurrieron algunos errores durante el envío del comprobante de pago por email, vea la siguiente lista:"
	#define STR0051 "Error durante el envío del mensaje:"
	#define STR0052 "Falta de dirección de email registrado para el envío:"
	#define STR0053 "Boleta de Remuneraciones - Saldos"
	#define STR0054 "Atentamente,"
	#define STR0055 "Selecionando Registros..."
	#define STR0056 "¡Atención!"
	#define STR0057 "No se localizaron comprobantes de pago disponibles para esta consulta."
	#define STR0058 "¡CONTINUA!"
	#define STR0059 "Comprobante de pago"
	#define STR0060 "Se consigna en documento adjunto su comprobante de pago referente a"
#else
	#ifdef ENGLISH
		#define STR0001 "Issue or Payment Receipts"
		#define STR0002 "Payment Receipt"
		#define STR0003 "Receipt no."
		#define STR0004 "Period:"
		#define STR0005 "Payment:"
		#define STR0006 "PAYMENT PERIOD:"
		#define STR0007 "Payment Date:"
		#define STR0008 "Branch:"
		#define STR0009 "Registration:"
		#define STR0010 "Name"
		#define STR0011 "ID Type:"
		#define STR0012 "ID.No.:"
		#define STR0013 "Function:"
		#define STR0014 "Desc.:"
		#define STR0015 "Position:"
		#define STR0016 "Cost Center:"
		#define STR0017 "Dept:"
		#define STR0018 "ARL:"
		#define STR0019 "EPS:"
		#define STR0020 "AFP:"
		#define STR0021 "CCF:"
		#define STR0022 "Comp. Bank:"
		#define STR0023 "CIA Bank:"
		#define STR0024 "Salary:"
		#define STR0025 "Mth. Hours:"
		#define STR0026 "Grossup:"
		#define STR0027 "Wages"
		#define STR0028 "Discounts"
		#define STR0029 "Bases"
		#define STR0030 "Funds"
		#define STR0031 "Hrs./Day"
		#define STR0032 "Values"
		#define STR0033 "Base"
		#define STR0034 "Total Compensations:"
		#define STR0035 "Total Discounts:"
		#define STR0036 "Total Bases:"
		#define STR0037 "Net Amount Receipt (S/.):"
		#define STR0038 "Account:"
		#define STR0039 "I received the amount on __/__/___ ___________________________________________"
		#define STR0040 "Employee"
		#define STR0041 "Bank:"
		#define STR0042 "Net Amount Receipt:"
		#define STR0043 "Account:"
		#define STR0044 "I received the previous value on ___/___/____"
		#define STR0045 "SMTP server is not configured"
		#define STR0046 "Email account is not configured"
		#define STR0047 "Email password is not configured"
		#define STR0048 "Errors during submission of payment receipts"
		#define STR0049 "Mr./Ms."
		#define STR0050 "Some errors occurred during the submission of the payment receipt through email, see this list:"
		#define STR0051 "Error during submission of message:"
		#define STR0052 "Lack of email address registered for submission:"
		#define STR0053 "Compensations receipt - Balances"
		#define STR0054 "Sincerely,"
		#define STR0055 "Selecting records..."
		#define STR0056 "Attention!"
		#define STR0057 "No payment receipts available for this inquiry."
		#define STR0058 "CONTINUE."
		#define STR0059 "Payment Receipt"
		#define STR0060 "See in the document attached your payment receipt related to"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Emisión de Recibos de Pago", "Emissão de Recibos de Pagamento" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Recibo de Pago", "Recibo de Pagamento" )
		#define STR0003 "Recibo No."
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Periodo:", "Período:" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Pago:", "Pagamento:" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Periodo de Pago:", "Período de Pagamento:" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Fecha de Pago:", "Data de Pagamento:" )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Sucursal:", "Filial:" )
		#define STR0009 "Matrícula:"
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "Nombre:", "Nome" )
		#define STR0011 "Tipo ID:"
		#define STR0012 "No. ID:"
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "Función:", "Função:" )
		#define STR0014 "Desc:"
		#define STR0015 "Cargo:"
		#define STR0016 If( cPaisLoc $ "ANG|PTG", "C.Costo:", "C.Custo:" )
		#define STR0017 "Depto:"
		#define STR0018 "ARL:"
		#define STR0019 "EPS:"
		#define STR0020 "AFP:"
		#define STR0021 "CCF:"
		#define STR0022 "Banco Emp:"
		#define STR0023 "Banco CIA:"
		#define STR0024 If( cPaisLoc $ "ANG|PTG", "Sueldo:", "Salário:" )
		#define STR0025 "Hrs. Men:"
		#define STR0026 "Grossup:"
		#define STR0027 If( cPaisLoc $ "ANG|PTG", "Devengos", "Remunerações" )
		#define STR0028 If( cPaisLoc $ "ANG|PTG", "Descuentos", "Descontos" )
		#define STR0029 "Bases"
		#define STR0030 If( cPaisLoc $ "ANG|PTG", "Concepto", "Verba" )
		#define STR0031 If( cPaisLoc $ "ANG|PTG", "Hrs./Día", "Hrs./Dia" )
		#define STR0032 If( cPaisLoc $ "ANG|PTG", "Importes", "Valores" )
		#define STR0033 "Base"
		#define STR0034 If( cPaisLoc $ "ANG|PTG", "Total Devengos:", "Total Remunerações:" )
		#define STR0035 If( cPaisLoc $ "ANG|PTG", "Total Descuentos:", "Total Descontos:" )
		#define STR0036 "Total Bases:"
		#define STR0037 If( cPaisLoc $ "ANG|PTG", "Neto Recibido (S/.):", "Líquido Recebido (S/.):" )
		#define STR0038 If( cPaisLoc $ "ANG|PTG", "Cuenta:", "Conta:" )
		#define STR0039 If( cPaisLoc $ "ANG|PTG", "Recibí el valor anterior el __/__/___ ___________________________________________", "Recebi o valor anterior em __/__/___ ___________________________________________" )
		#define STR0040 If( cPaisLoc $ "ANG|PTG", "Empleado", "Funcionário" )
		#define STR0041 "Banco:"
		#define STR0042 If( cPaisLoc $ "ANG|PTG", "Neto Recibido:", "Líquido Recebido:" )
		#define STR0043 "Cta.:"
		#define STR0044 If( cPaisLoc $ "ANG|PTG", "Recibí el valor anterior el ___/___/____", "Recebi o valor anterior em ___/___/____" )
		#define STR0045 If( cPaisLoc $ "ANG|PTG", "El servidor SMTP no está cnfigurado ", "O servidor SMTP não está configurado" )
		#define STR0046 If( cPaisLoc $ "ANG|PTG", "La cuenta de e-mail no está configurada ", "A conta de e-mail não está configurada" )
		#define STR0047 If( cPaisLoc $ "ANG|PTG", "La contraseña del email no está configurada ", "A senha do e-mail não está configurada" )
		#define STR0048 If( cPaisLoc $ "ANG|PTG", "Errores ocurridos durante el envío de los comprobantes de pago", "Erros ocorridos durante o envio dos recibos de pagamento" )
		#define STR0049 "Sr.(a)"
		#define STR0050 If( cPaisLoc $ "ANG|PTG", "Ocurrieron algunos errores durante el envío del comprobante de pago por email, vea la siguiente lista:", "Ocorreram alguns erros durante o envio do recibo de pagamento por e-mail, veja a seguinte lista:" )
		#define STR0051 If( cPaisLoc $ "ANG|PTG", "Error durante el envío del mensaje:", "Erro durante o envio da mensagem:" )
		#define STR0052 If( cPaisLoc $ "ANG|PTG", "Falta de dirección de email registrado para el envío:", "Falta de endereço do e-mail cadastrado para o envio:" )
		#define STR0053 If( cPaisLoc $ "ANG|PTG", "Boleta de Remuneraciones - Saldos", "Recibo de Remunerações - Saldos" )
		#define STR0054 If( cPaisLoc $ "ANG|PTG", "Atentamente,", "Atenciosamente,," )
		#define STR0055 "Selecionando Registros..."
		#define STR0056 If( cPaisLoc $ "ANG|PTG", "¡Atención!", "Atenção!" )
		#define STR0057 If( cPaisLoc $ "ANG|PTG", "No se localizaron comprobantes de pago disponibles para esta consulta.", "Não foram localizados os recibos de pagamento disponíveis para esta consulta." )
		#define STR0058 If( cPaisLoc $ "ANG|PTG", "¡CONTINUA!", "PROSSEGUIR!" )
		#define STR0059 If( cPaisLoc $ "ANG|PTG", "Comprobante de pago", "Recibo de Pagamento" )
		#define STR0060 If( cPaisLoc $ "ANG|PTG", "Se consigna en documento adjunto su comprobante de pago referente a", "Consta em documento anexo seu recibo de pagamento referente a" )
	#endif
#endif
