#Include "Ctbr070.Ch"
#Include "PROTHEUS.Ch"

// 17/08/2009 -- Filial com mais de 2 caracteres

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quando informava o parâmetro Documento de/Ate, não estava sendo respeitado. ³
//³Foi alterado as regras de skip para o documento, sublote, lote, seqlan.     ³
//³Efetuado o desvio da função da ctbr071 para a ctbr070                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
Function CtbR071()
	Ctbr070()
Return
