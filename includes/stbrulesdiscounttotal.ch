#ifdef SPANISH
	#define STR0001 "Regla de descuento: Aplicado descuento sobre total segun, la(s) siguiente(s) regla(s): "
	#define STR0002 "Regla de descuento:"
	#define STR0003 "Sugerencia de Regla de Descuento: Adicionando mas "
	#define STR0004 " en la venta "
	#define STR0005 " se dara descuento de: "
	#define STR0006 "Regla de descuento no se aplicó porque ya constaba uno o más pagos efectuados para esta venta. La regla de descuento por forma de pago, acepta solamente una de las formas de pago configurado en el registro de la regla de descuento."
	#define STR0007 "El descuento aplicado en la venta no se considerará porque el valor digitado en la forma de pago no es el valor integral de la venta."
	#define STR0008 "Valor integral de la venta R$"
	#define STR0009 "Valor digitado R$"
	#define STR0010 "Para obtener nuevamente el descuento, es necesario rehacer el pago."
#else
	#ifdef ENGLISH
		#define STR0001 "Discount Rule: Discount on the total according to the following rule(s): "
		#define STR0002 "Discount Rule:"
		#define STR0003 "Discount Rule Suggestion: Adding more "
		#define STR0004 " in the sales transaction "
		#define STR0005 " the discount given is of: "
		#define STR0006 "Discount rule not applied as one or more payments made for sale is already included. The discount rule per payment term accepts only one of the payment terms configured in the register of discount rule."
		#define STR0007 "The discount applied to the sales is disregarded because the value entered in the payment term is not the full value of the sales. "
		#define STR0008 "Full value of the sales R$ "
		#define STR0009 "Value entered R$ "
		#define STR0010 "To get the discount again, pay again."
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Regra de desconto: Aplicado desconto no total segundo a(s)s seguinte(s) regra(s): ", "Regra de Desconto: Aplicado desconto no total segundo a(s)s seguinte(s) regra(s): " )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Regra de desconto:", "Regra de Desconto:" )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Sugestão de regra de desconto: A adicionar mais ", "Sugestão de Regra de Desconto: Adicionando mais " )
		#define STR0004 " na venda "
		#define STR0005 " será concedido desconto de: "
		#define STR0006 "Regra de desconto não foi aplicada pois ja constava um ou mais pagamentos efetuados para essa venda. A regra de desconto por forma de pagamento, aceita apenas uma das formas de pagamento configurado no cadastro da regra de desconto."
		#define STR0007 "O desconto aplicado na venda será desconsiderado porque o valor digitado na forma de pagamento, não é o valor integral da venda. "
		#define STR0008 "Valor integral da venda R$ "
		#define STR0009 "Valor digitado R$ "
		#define STR0010 "Para obter novamente o desconto, é necessário refazer o pagamento."
	#endif
#endif
