#INCLUDE "PROTHEUS.CH"

// O protheus necessita ter ao menos uma fun็ใo p๚blica para que o fonte seja exibido na inspe็ใo de fontes do RPO.
Function LOJA1171() ; Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออออัอออออออออออออออออออออออออออออออออออัอออออออออออออออออออัออออออออออออออออปฑฑ
ฑฑบ     Classe: ณ LJCInitialLoadStatus              ณ Autor: Vendas CRM ณ Data: 07/02/10 บฑฑ
ฑฑฬอออออออออออออุอออออออออออออออออออออออออออออออออออฯอออออออออออออออออออฯออออออออออออออออนฑฑ
ฑฑบ  Descri็ใo: ณ classe para o status da carga                                                        บฑฑ
ฑฑบ             ณ                                                                        บฑฑ
ฑฑศอออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Class LJCInitialLoadStatus From FWSerialize
	Data cCodeLoad
	Data cStatus
	Data cOrder
	Data cEntireIncremental
	
	Method New()	

EndClass

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออออัอออออออออออออออออออออออออออออออออออัอออออออออออออออออออัออออออออออออออออปฑฑ
ฑฑบ     M้todo: ณ New                               ณ Autor: Vendas CRM ณ Data: 07/02/10 บฑฑ
ฑฑฬอออออออออออออุอออออออออออออออออออออออออออออออออออฯอออออออออออออออออออฯออออออออออออออออนฑฑ
ฑฑบ  Descri็ใo: ณ Construtor.                                                            บฑฑ
ฑฑบ             ณ                                                                        บฑฑ
ฑฑฬอออออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Parametros: ณ cCodeLoad: Codigo da carga                                             บฑฑ
ฑฑบ             ณ cStatus: status.                                                       บฑฑ
ฑฑบ             ณ cOrder: ordem da carga                                                 บฑฑ
ฑฑบ             ณ cEntireIncremental: tipo da carga (1 = inteira / 2= incremental.       บฑฑ
ฑฑฬอออออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ    Retorno: ณ                                                                        บฑฑ
ฑฑศอออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method New( cCodeLoad, cStatus, cOrder, cEntireIncremental ) Class LJCInitialLoadStatus
	Self:cCodeLoad			:= cCodeLoad
	Self:cStatus				:= cStatus
	Self:cOrder				:= cOrder
	Self:cEntireIncremental	:= cEntireIncremental

Return






