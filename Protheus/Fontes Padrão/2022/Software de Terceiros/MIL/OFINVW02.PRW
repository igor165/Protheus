// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 2      º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "OFINVW02.ch"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | OFINVW02   | Autor | Luis Delorme          | Data | 20/05/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Importação VW Assunto FVW-Faturamento Diário de Veículos     |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFINVW02(lEnd, cArquivo)
//
Local nCurArq
//
Local aFVW000 := {}
Local aFVW001 := {}
Local aFVW002 := {}
Local aFVW003 := {}
Local aFVW004 := {}
Local aFVW005 := {}
Local aFVW007 := {}
Local aFVW008 := {}
//
Private aD000 := {}
Private aD001 := {}
Private aD002 := {}
Private aD003 := {}
Private aD004 := {}
Private aD005 := {}
Private aD007 := {}
Private aD008 := {}
//
aAdd(aFVW000, {"C",3,0,1," " }) 	// "TIPO DE REGISTRO (FVW)"})
aAdd(aFVW000, {"N",3,0,4," " }) 	// "SUB-CÓDIGO DO REGISTRO (000)"})
aAdd(aFVW000, {"D",8,0,7," " }) 	// "DATA DO FATURAMENTO (ddmmaaaa)"})
aAdd(aFVW000, {"N",6,0,15," " }) 	// "NÚMERO DA NOTA FISCAL"})
aAdd(aFVW000, {"C",4,0,21," " }) 	// "NÚMERO DE SÉRIE DA NOTA FISCAL"})
aAdd(aFVW000, {"N",2,0,25," " }) 	// "FÁBRICA - PLANTA DE FATURAMENTO"})
aAdd(aFVW000, {"N",6,0,27," " }) 	// "NÚMERO DO PEDIDO (BASYS/VW)"})
aAdd(aFVW000, {"C",1,0,33," " }) 	// "IDENTIFICAÇÃO DO PEDIDO"})
aAdd(aFVW000, {"C",1,0,34," " }) 	// "IDENTIFICAÇÃO DE VENDA"})
aAdd(aFVW000, {"N",5,0,35," " }) 	// "GRUPO - CONSÓRCIO"})
aAdd(aFVW000, {"N",5,0,40," " }) 	// "QUOTA - CONSÓRCIO"})
aAdd(aFVW000, {"N",10,0,45," " }) 	// "NÚMERO DA AVE (AUTORIZAÇÃO DE VENDAS ESPECIAIS)"})
aAdd(aFVW000, {"C",30,0,55," " }) 	// "NOME DA FONTE PAGADORA"})
aAdd(aFVW000, {"D",8,0,85," " }) 	// "DATA DE VENCIMENTO N.FISCAL (ddmmaaaa)"})
aAdd(aFVW000, {"C",1,0,93," " }) 	// "TIPO DE PAGAMENTO"})
aAdd(aFVW000, {"N",5,0,94," " }) 	// "DEALER DE ENTREGA DO VEÍCULO"})
aAdd(aFVW000, {"N",5,0,99," " }) 	// "DEALER DE VENDA DO VEÍCULO"})
aAdd(aFVW000, {"C",40,0,104," " }) 	// "NOME DO ARRENDATÁRIO (LEASING)"})
aAdd(aFVW000, {"C",1,0,144," " }) 	// "INDICAÇÃO DE HOLDBACK"})
aAdd(aFVW000, {"C",43,0,145," " }) 	// "BRANCOS"})
aAdd(aFVW000, {"N",6,0,188," " }) 	// "VERSÃO DO LAY-OUT (Fixo: 230103)"})
//
aAdd(aFVW001, {"C",3,0,1," " }) // "TIPO DE REGISTRO (FVW)"})
aAdd(aFVW001, {"N",3,0,4," " }) // "SUB-CÓDIGO DO REGISTRO (Fixo=001)"})
aAdd(aFVW001, {"D",8,0,7," " }) // "DATA DO FATURAMENTO (ddmmaaaa)"})
aAdd(aFVW001, {"N",6,0,15," " }) // "NÚMERO DA NOTA FISCAL"})
aAdd(aFVW001, {"C",4,0,21," " }) // "NÚMERO DE SÉRIE DA NOTA FISCAL"})
aAdd(aFVW001, {"N",2,0,25," " }) // "FÁBRICA - PLANTA DE FATURAMENTO"})
aAdd(aFVW001, {"C",20,0,27," " }) // "CNPJ / CPF DO CLIENTE"})
aAdd(aFVW001, {"C",40,0,47," " }) // "NOME DO CLIENTE"})
aAdd(aFVW001, {"C",40,0,87," " }) // "ENDEREÇO"})
aAdd(aFVW001, {"C",20,0,127," " }) // "BAIRRO"})
aAdd(aFVW001, {"N",5,0,147," " }) // "CEP"})
aAdd(aFVW001, {"N",3,0,152," " }) // "COMPLEMENTO DO CEP"})
aAdd(aFVW001, {"C",20,0,155," " }) // "CIDADE"})
aAdd(aFVW001, {"C",2,0,175," " }) // "ESTADO"})
aAdd(aFVW001, {"N",17,0,177," " }) // "BRANCOS "})
//
aAdd(aFVW002, {"C",3,0,1," " }) // "TIPO DE REGISTRO (FVW)"})
aAdd(aFVW002, {"N",3,0,4," " }) // "SUB-CÓDIGO DO REGISTRO (Fixo=002)"})
aAdd(aFVW002, {"D",8,0,7," " }) // "DATA DO FATURAMENTO (ddmmaaaa)"})
aAdd(aFVW002, {"N",6,0,15," " }) // "NÚMERO DA NOTA FISCAL"})
aAdd(aFVW002, {"C",4,0,21," " }) // "NÚMERO DE SÉRIE DA NOTA FISCAL"})
aAdd(aFVW002, {"N",2,0,25," " }) // "FÁBRICA - PLANTA DE FATURAMENTO"})
aAdd(aFVW002, {"C",1,0,27," " }) // "IDENTIFICAÇÃO DO VEÍCULO - "})
aAdd(aFVW002, {"C",7,0,28," " }) // "VEÍCULO (TMASEQ-Produtos TEGÜ)"})
aAdd(aFVW002, {"C",3,0,35," " }) // "CÔR EXTERNA (Produtos TEGÜ)"})
aAdd(aFVW002, {"C",2,0,38," " }) // "ESTOFAMENTO (Produtos TEGÜ/BASYS)"})
aAdd(aFVW002, {"C",6,0,40," " }) // "CÓDIGO DO MODELO (Produtos BASYS)"})
aAdd(aFVW002, {"C",1,0,46," " }) // "EDIÇÃO (Produtos BASYS)"})
aAdd(aFVW002, {"C",4,0,47," " }) // "CÔR EXTERNA (Produtos BASYS)"})
aAdd(aFVW002, {"C",40,0,51," " }) // "DESCRIÇÃO DA COR DO VEÍCULO"})
aAdd(aFVW002, {"N",4,0,91," " }) // "ANO DO MODELO (aaaa)"})
aAdd(aFVW002, {"N",4,0,95," " }) // "ANO DE FABRICAÇÃO (aaaa)"})
aAdd(aFVW002, {"C",1,0,99," " }) // "COMBUSTÍVEL "})
aAdd(aFVW002, {"C",1,0,100," " }) // "IDENTIFICAÇÃO TAXI (Branco ou 'T')"})
aAdd(aFVW002, {"C",4,0,101," " }) // "OPCIONAIS"})
aAdd(aFVW002, {"C",4,0,105," " }) // "OPCIONAIS"})
aAdd(aFVW002, {"C",4,0,109," " }) // "OPCIONAIS"})
aAdd(aFVW002, {"C",4,0,113," " }) // "OPCIONAIS"})
aAdd(aFVW002, {"C",4,0,117," " }) // "OPCIONAIS"})
aAdd(aFVW002, {"C",4,0,121," " }) // "OPCIONAIS"})
aAdd(aFVW002, {"C",4,0,125," " }) // "OPCIONAIS"})
aAdd(aFVW002, {"C",4,0,129,""  }) // !OPCIONAIS"})
aAdd(aFVW002, {"C",4,0,133," " }) // "OPCIONAIS"})
aAdd(aFVW002, {"C",4,0,137," " }) // "OPCIONAIS"})
aAdd(aFVW002, {"C",4,0,141," " }) // "OPCIONAIS"})
aAdd(aFVW002, {"C",4,0,145," " }) // "OPCIONAIS"})
aAdd(aFVW002, {"C",4,0,149," " }) // "OPCIONAIS"})
aAdd(aFVW002, {"C",4,0,153," " }) // "OPCIONAIS"})
aAdd(aFVW002, {"C",4,0,157," " }) // "OPCIONAIS"})
aAdd(aFVW002, {"C",4,0,161," " }) // "OPCIONAIS"})
aAdd(aFVW002, {"C",4,0,165," " }) // "OPCIONAIS"})
aAdd(aFVW002, {"C",4,0,169," " }) // "OPCIONAIS"})
aAdd(aFVW002, {"C",4,0,173," " }) // "OPCIONAIS"})
aAdd(aFVW002, {"C",4,0,177," " }) // "OPCIONAIS"})
aAdd(aFVW002, {"N",4,0,181," " }) // "QTD DE  POTÊNCIA MOTOR"})
aAdd(aFVW002, {"C",1,0,185," " }) // "UNIDADE DE POTÊNCIA"})
aAdd(aFVW002, {"C",8,0,186," " }) // "BRANCOS"})
//
aAdd(aFVW003, {"C",3,0,1," " }) // "TIPO DE REGISTRO (FVW)"})
aAdd(aFVW003, {"N",3,0,4," " }) // "SUB-CÓDIGO DO REGISTRO (Fixo=003)"})
aAdd(aFVW003, {"D",8,0,7," " }) // "DATA DO FATURAMENTO (ddmmaaaa)"})
aAdd(aFVW003, {"N",6,0,15," " }) // "NÚMERO DA NOTA FISCAL"})
aAdd(aFVW003, {"C",4,0,21," " }) // "NÚMERO DE SÉRIE DA NOTA FISCAL"})
aAdd(aFVW003, {"N",2,0,25," " }) // "FÁBRICA - PLANTA DE FATURAMENTO"})
aAdd(aFVW003, {"C",17,0,27," " }) // "NÚMERO DO CHASSIS"})
aAdd(aFVW003, {"N",8,0,44," " }) // "NÚMERO RENAVAM - VEÍCULO"})
aAdd(aFVW003, {"N",2,0,52," " }) // "NÚMERO RENAVAM - CÔR"})
aAdd(aFVW003, {"C",10,0,54," " }) // "CÓDIGO DA DECLARAÇÃO DE IMPORTAÇÃO - DI"})
aAdd(aFVW003, {"N",8,0,64," " }) // "DATA DA DECLARAÇÃO DE IMPORTAÇÃO - DI (ddmmaaaa)"})
aAdd(aFVW003, {"C",16,0,72," " }) // "CÓDIGO DA LICENÇA DE IMPORTAÇÃO - GI"})
aAdd(aFVW003, {"N",8,0,88," " }) // "DATA DA LICENÇA DE IMPORTAÇÃO - GI (ddmmaaaa)"})
aAdd(aFVW003, {"C",20,0,96," " }) // "NÚMERO DO MOTOR"})
aAdd(aFVW003, {"C",40,0,116," " }) // "DESCRIÇÃO DO VEÍCULO"})
aAdd(aFVW003, {"C",38,0,156," " }) // "BRANCOS"})
//
aAdd(aFVW004, {"C",3,0,1," " }) // "TIPO DE REGISTRO (FVW)"})
aAdd(aFVW004, {"N",3,0,4," " }) // "SUB-CÓDIGO DO REGISTRO (Fixo=004)"})
aAdd(aFVW004, {"D",8,0,7," " }) // "DATA DO FATURAMENTO (ddmmaaaa)"})
aAdd(aFVW004, {"N",6,0,15," " }) // "NÚMERO DA NOTA FISCAL"})
aAdd(aFVW004, {"C",4,0,21," " }) // "NÚMERO DE SÉRIE DA NOTA FISCAL"})
aAdd(aFVW004, {"N",2,0,25," " }) // "FÁBRICA - PLANTA DE FATURAMENTO"})
aAdd(aFVW004, {"N",15,2,27," " }) // "VALOR TOTAL DA NOTA FISCAL"})
aAdd(aFVW004, {"N",5,3,42," " }) // "TAXA DE BONIFICAÇÃO"})
aAdd(aFVW004, {"N",15,2,47," " }) // "VALOR DESCONTO FUNDO APOLO"})
aAdd(aFVW004, {"N",15,2,62," " }) // "VALOR ICMS SUBSTITUTIVO"})
aAdd(aFVW004, {"N",15,2,77," " }) // "BASE DE CÁLCULO ICMS SUBSTITUTIVO"})
aAdd(aFVW004, {"N",15,2,92," " }) // "VALOR ICMS FABRICANTE"})
aAdd(aFVW004, {"N",15,2,107," " }) // "BASE DE CÁLCULO ICMS FABRICANTE"})
aAdd(aFVW004, {"N",5,2,122," " }) // "TAXA DO IPI MODELO BÁSICO"})
aAdd(aFVW004, {"N",15,2,127," " }) // "BASE DE CÁLCULO DO IPI MODELO BÁSICO"})
aAdd(aFVW004, {"N",15,2,142," " }) // "VALOR TOTAL DO IPI "})
aAdd(aFVW004, {"N",5,2,157," " }) // "TAXA DE IPI DOS OPCIONAIS"})
aAdd(aFVW004, {"N",15,2,162," " }) // "BASE DE CÁLCULO DO IPI OPCIONAIS BÁSICO"})
aAdd(aFVW004, {"N",15,2,177," " }) // "VALOR DESPESAS ACESSÓRIAS"})
aAdd(aFVW004, {"C",2,0,192," " }) // "BRANCOS"})
//
aAdd(aFVW005, {"C",3,0,1," " }) // "TIPO DE REGISTRO (FVW)"})
aAdd(aFVW005, {"N",3,0,4," " }) // "SUB-CÓDIGO DO REGISTRO (Fixo=005)"})
aAdd(aFVW005, {"D",8,0,7," " }) // "DATA DO FATURAMENTO (ddmmaaaa)"})
aAdd(aFVW005, {"N",6,0,15," " }) // "NÚMERO DA NOTA FISCAL"})
aAdd(aFVW005, {"C",4,0,21," " }) // "NÚMERO DE SÉRIE DA NOTA FISCAL"})
aAdd(aFVW005, {"N",2,0,25," " }) // "FÁBRICA - PLANTA DE FATURAMENTO"})
aAdd(aFVW005, {"N",18,5,27," " }) // "QUANTIDADE DE QC'S DO VALOR DO FATURAMENTO"})
aAdd(aFVW005, {"N",18,5,45," " }) // "QUANTIDADE DE QC'S DO VALOR DEPÓSITO DO PLANO DE CAPITALIZAÇÃO"})"
aAdd(aFVW005, {"N",15,2,63," " }) // "VALOR DE DESCONTO"})
aAdd(aFVW005, {"N",15,2,78," " }) // "VALOR TOTAL SEGURO"})
aAdd(aFVW005, {"N",15,2,93," " }) // "VALOR DO FRETE"})
aAdd(aFVW005, {"N",15,2,108," " }) // "VALOR DO PIS"})
aAdd(aFVW005, {"N",15,2,123," " }) // "VALOR DO COFINS"})
aAdd(aFVW005, {"N",15,2,138," " }) // "VALOR DE CONTRIBUIÇÃO DA MONTADORA"})
aAdd(aFVW005, {"N",15,2,153," " }) // "VALOR DE CONTRIBUIÇÃO DO DEALER"})
aAdd(aFVW005, {"N",15,2,168," " }) // "VALOR DE CONTRIBUIÇÃO DA ASSOCIAÇÃO"})
aAdd(aFVW005, {"C",11,0,183," " }) // "BRANCOS"})
//
aAdd(aFVW007, {"C",3,0,1," " }) // "TIPO DE REGISTRO (FVW)"})
aAdd(aFVW007, {"N",3,0,4," " }) // "SUB-CÓDIGO DO REGISTRO (Fixo=007)"})
aAdd(aFVW007, {"D",8,0,7," " }) // "DATA DO FATURAMENTO (ddmmaaaa)"})
aAdd(aFVW007, {"N",6,0,15," " }) // "NÚMERO DA NOTA FISCAL"})
aAdd(aFVW007, {"C",4,0,21," " }) // "NÚMERO DE SÉRIE DA NOTA FISCAL"})
aAdd(aFVW007, {"N",2,0,25," " }) // "FÁBRICA - PLANTA DE FATURAMENTO"})
aAdd(aFVW007, {"C",40,0,27," " }) // "DESCRIÇÃO DO VEICULO (somente para TRUCK & BUS)"})
aAdd(aFVW007, {"C",44,0,67," " }) // "AUTORIZAÇÃO SEFAZ (somente para Nota Fiscal Eletrônica)"})
aAdd(aFVW007, {"C",83,0,111," " }) // "BRANCOS"})
//
aAdd(aFVW008, {"C",3,0,1," " }) // "TIPO DE REGISTRO (FVW)"})
aAdd(aFVW008, {"N",3,0,4," " }) // "SUB-CÓDIGO DO REGISTRO (Fixo=008)"})
aAdd(aFVW008, {"D",8,0,7," " }) // "DATA DO FATURAMENTO (ddmmaaaa)"})
aAdd(aFVW008, {"N",6,0,15," " }) // "NÚMERO DA NOTA FISCAL"})
aAdd(aFVW008, {"C",4,0,21," " }) // "NÚMERO DE SÉRIE DA NOTA FISCAL"})
aAdd(aFVW008, {"N",2,0,25," " }) // "FÁBRICA - PLANTA DE FATURAMENTO"})
aAdd(aFVW008, {"C",4,0,27," " }) // "OPCIONAIS"})
aAdd(aFVW008, {"C",4,0,31," " }) // "OPCIONAIS"})
aAdd(aFVW008, {"C",4,0,35," " }) // "OPCIONAIS"})
aAdd(aFVW008, {"C",4,0,39," " }) // "OPCIONAIS"})
aAdd(aFVW008, {"C",4,0,43," " }) // "OPCIONAIS"})
aAdd(aFVW008, {"C",4,0,47," " }) // "OPCIONAIS"})
aAdd(aFVW008, {"C",4,0,51," " }) // "OPCIONAIS"})
aAdd(aFVW008, {"C",4,0,55," " }) // "OPCIONAIS"})
aAdd(aFVW008, {"C",4,0,59," " }) // "OPCIONAIS"})
aAdd(aFVW008, {"C",4,0,63," " }) // "OPCIONAIS"})
aAdd(aFVW008, {"C",4,0,67," " }) // "OPCIONAIS"})
aAdd(aFVW008, {"C",4,0,71," " }) // "OPCIONAIS"})
aAdd(aFVW008, {"C",4,0,75," " }) // "OPCIONAIS"})
aAdd(aFVW008, {"C",4,0,79," " }) // "OPCIONAIS"})
aAdd(aFVW008, {"C",4,0,83," " }) // "OPCIONAIS"})
aAdd(aFVW008, {"C",4,0,87," " }) // "OPCIONAIS"})
aAdd(aFVW008, {"C",4,0,91," " }) // "OPCIONAIS"})
aAdd(aFVW008, {"C",4,0,95," " }) // "OPCIONAIS"})
aAdd(aFVW008, {"C",4,0,99," " }) // "OPCIONAIS"})
aAdd(aFVW008, {"C",4,0,103," " }) // "OPCIONAIS"})
aAdd(aFVW008, {"C",4,0,107," " }) // "OPCIONAIS"})
aAdd(aFVW008, {"C",4,0,111," " }) // "OPCIONAIS"})
aAdd(aFVW008, {"C",4,0,115," " }) // "OPCIONAIS"})
aAdd(aFVW008, {"C",4,0,119," " }) // "OPCIONAIS"})
aAdd(aFVW008, {"C",4,0,123," " }) // "OPCIONAIS"})
aAdd(aFVW008, {"C",4,0,127," " }) // "OPCIONAIS"})
aAdd(aFVW008, {"C",4,0,131," " }) // "OPCIONAIS"})
aAdd(aFVW008, {"C",4,0,135," " }) // "OPCIONAIS"})
aAdd(aFVW008, {"C",4,0,139," " }) // "OPCIONAIS"})
aAdd(aFVW008, {"C",4,0,143," " }) // "OPCIONAIS"})
aAdd(aFVW008, {"C",4,0,147," " }) // "OPCIONAIS"})
aAdd(aFVW008, {"C",4,0,151," " }) // "OPCIONAIS"})
aAdd(aFVW008, {"C",4,0,155," " }) // "OPCIONAIS"})
aAdd(aFVW008, {"C",4,0,159," " }) // "OPCIONAIS"})
aAdd(aFVW008, {"C",4,0,163," " }) // "OPCIONAIS"})
aAdd(aFVW008, {"C",4,0,167," " }) // "OPCIONAIS"})
aAdd(aFVW008, {"C",4,0,171," " }) // "OPCIONAIS"})
aAdd(aFVW008, {"C",4,0,175," " }) // "OPCIONAIS"})
aAdd(aFVW008, {"C",4,0,179," " }) // "OPCIONAIS"})
aAdd(aFVW008, {"C",4,0,183," " }) // "OPCIONAIS"})
aAdd(aFVW008, {"C",7,0,187," " }) // "BRANCOS"})
//
// PROCESSAMENTO DOS ARQUIVOS
//
aAdd(aArquivos,cArquivo)
// Laço em cada arquivo
for nCurArq := 1 to Len(aArquivos)
	// pega o próximo arquivo
	cArquivo := Alltrim(aArquivos[nCurArq])
	//
	nPos = Len(cArquivo)
	if nPos = 0
		lAbort = .t.
		return
	endif
	// Processamento para Arquivos TXT planos
	FT_FUse( cArquivo )
	//
	FT_FGotop()
	if FT_FEof()
		loop
	endif
	//
	nTotRec := FT_FLastRec()
	//
	nLinhArq := 0
	While !FT_FEof()
		cStr := FT_FReadLN()
		nLinhArq++
		// Informações extraídas da linha do arquivo de importação ficam no vetor aInfo
		if Left(cStr,6)=="FVW000"
			aInfo := ExtraiEDI(aFVW000,cStr)
		elseif Left(cStr,6)=="FVW001"
			aInfo := ExtraiEDI(aFVW001,cStr)
		elseif Left(cStr,6)=="FVW002"
			aInfo := ExtraiEDI(aFVW002,cStr)
		elseif Left(cStr,6)=="FVW003"
			aInfo := ExtraiEDI(aFVW003,cStr)
		elseif Left(cStr,6)=="FVW004"
			aInfo := ExtraiEDI(aFVW004,cStr)
		elseif Left(cStr,6)=="FVW005"
			aInfo := ExtraiEDI(aFVW005,cStr)
		elseif Left(cStr,6)=="FVW007"
			aInfo := ExtraiEDI(aFVW007,cStr)
		elseif Left(cStr,6)=="FVW008"
			aInfo := ExtraiEDI(aFVW008,cStr)
		endif
		// Trabalhar com aInfo gravando as informações
		if Left(cStr,6) $ "FVW000.FVW001.FVW002.FVW003.FVW004.FVW005.FVW007.FVW008"
			GrvInfo(aInfo)
		endif
		FT_FSkip()
	EndDo
	//
	GrvInfo({"FVW",0}) // chamada para encerrar o último veículo
	//
	FT_FUse()
next
//
return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡…o    | GrvInfo    | Autor | Luis Delorme          | Data | 17/03/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡…o | Processa o resultado da importação                           |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function GrvInfo(aInfo)
// Realizar as atualizações necessárias a partir das informações extraídas
// fazer verificações de erro e atualizar o vetor aIntIte ou aLinErros conforme
// o caso
Local nCntFor

if li > 80
	li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	li := li+2
endif
//
if Empty(aInfo)
	@li ++ ,1 psay cArquivo + STR0001 + Alltrim(STR(nLinhArq))
	return
endif
//
if aInfo[2] == 0
	if !Empty(aD000)
		//
		// MONTA TUDO AQUI
		//
		lTegu := .f.
		cPlantaFaturamento := STR0005
		cPlantaFaturamento := IIF(aD000[6]==6,STR0043,cPlantaFaturamento)
		cPlantaFaturamento := IIF(aD000[6]==41,STR0009,cPlantaFaturamento)
		cPlantaFaturamento := IIF(aD000[6]==51,STR0008,cPlantaFaturamento)
		cPlantaFaturamento := IIF(aD000[6]==52,STR0103,cPlantaFaturamento)
		cPlantaFaturamento := IIF(aD000[6]==53,STR0107,cPlantaFaturamento)
		cPlantaFaturamento := IIF(aD000[6]==55,STR0102,cPlantaFaturamento)
		cPlantaFaturamento := IIF(aD000[6]==57,STR0042,cPlantaFaturamento)
		cPlantaFaturamento := IIF(aD000[6]==1,STR0008,cPlantaFaturamento)
		cPlantaFaturamento := IIF(aD000[6]==3,STR0107,cPlantaFaturamento)
		cPlantaFaturamento := IIF(aD000[6]==8,STR0101,cPlantaFaturamento)

		cIdentPedido := STR0006
		cIdentPedido := IIF(aD000[8]==" ",STR0085,cIdentPedido)
		cIdentPedido := IIF(aD000[8]=="C",STR0034,cIdentPedido)
		cIdentPedido := IIF(aD000[8]=="F",STR0061,cIdentPedido)
		cIdentPedido := IIF(aD000[8]=="L",STR0077,cIdentPedido)
		cIdentPedido := IIF(aD000[8]=="T",STR0106,cIdentPedido)
		cIdentPedido := IIF(aD000[8]=="U",STR0117,cIdentPedido)

		cIdentVenda := STR0006
		cIdentVenda :=  IIF(aD000[9]==" ",STR0130,cIdentVenda)
		cIdentVenda :=  IIF(aD000[9]=="A",STR0125,cIdentVenda)
		cIdentVenda :=  IIF(aD000[9]=="B",STR0025,cIdentVenda)
		cIdentVenda :=  IIF(aD000[9]=="C",STR0124,cIdentVenda)
		cIdentVenda :=  IIF(aD000[9]=="F",STR0126,cIdentVenda)
		cIdentVenda :=  IIF(aD000[9]=="G",STR0128,cIdentVenda)
		cIdentVenda :=  IIF(aD000[9]=="I",STR0129,cIdentVenda)
		cIdentVenda :=  IIF(aD000[9]=="M",STR0036,cIdentVenda)
		cIdentVenda :=  IIF(aD000[9]=="O",STR0053,cIdentVenda)
		cIdentVenda :=  IIF(aD000[9]=="P",STR0097,cIdentVenda)
		cIdentVenda :=  IIF(aD000[9]=="R",STR0088,cIdentVenda)
		cIdentVenda :=  IIF(aD000[9]=="S",STR0048,cIdentVenda)
		cIdentVenda :=  IIF(aD000[9]=="T",STR0111,cIdentVenda)
		cIdentVenda :=  IIF(aD000[9]=="U",STR0066,cIdentVenda)
		cIdentVenda :=  IIF(aD000[9]=="V",STR0133,cIdentVenda)
		cIdentVenda :=  IIF(aD000[9]=="W",STR0127,cIdentVenda)
		cIdentVenda :=  IIF(aD000[9]=="Z",STR0134,cIdentVenda)

		cTipoPagamento :=  STR0006
		cTipoPagamento :=  IIF(aD000[15]==" ",STR0085,cTipoPagamento)
		cTipoPagamento :=  IIF(aD000[15]=="A",STR0039,cTipoPagamento)
		cTipoPagamento :=  IIF(aD000[15]=="B",STR0041,cTipoPagamento)
		cTipoPagamento :=  IIF(aD000[15]=="C",STR0067,cTipoPagamento)
		cTipoPagamento :=  IIF(aD000[15]=="D",STR0024,cTipoPagamento)
		cTipoPagamento :=  IIF(aD000[15]=="E",STR0065,cTipoPagamento)
		cTipoPagamento :=  IIF(aD000[15]=="F",STR0022,cTipoPagamento)
		cTipoPagamento :=  IIF(aD000[15]=="G",STR0063,cTipoPagamento)
		cTipoPagamento :=  IIF(aD000[15]=="H",STR0064,cTipoPagamento)
		cTipoPagamento :=  IIF(aD000[15]=="I",STR0151,cTipoPagamento)
		cTipoPagamento :=  IIF(aD000[15]=="J",STR0153,cTipoPagamento)
		cTipoPagamento :=  IIF(aD000[15]=="K",STR0149,cTipoPagamento)
		cTipoPagamento :=  IIF(aD000[15]=="L",STR0068,cTipoPagamento)
		cTipoPagamento :=  IIF(aD000[15]=="P",STR0152,cTipoPagamento)
		cTipoPagamento :=  IIF(aD000[15]=="Q",STR0150,cTipoPagamento)
		cTipoPagamento :=  IIF(aD000[15]=="R",STR0131,cTipoPagamento)
		cTipoPagamento :=  IIF(aD000[15]=="S",STR0132,cTipoPagamento)
		cTipoPagamento :=  IIF(aD000[15]=="T",STR0023,cTipoPagamento)
		cTipoPagamento :=  IIF(aD000[15]=="U",STR0092,cTipoPagamento)
		cTipoPagamento :=  IIF(aD000[15]=="V",STR0093,cTipoPagamento)
		cTipoPagamento :=  IIF(aD000[15]=="W",STR0039,cTipoPagamento)
		cTipoPagamento :=  IIF(aD000[15]=="X",STR0094,cTipoPagamento)
		cTipoPagamento :=  IIF(aD000[15]=="Y",STR0041,cTipoPagamento)
		cTipoPagamento :=  IIF(aD000[15]=="Z",STR0040,cTipoPagamento)
		cTipoPagamento :=  IIF(aD000[15]=="1",STR0086,cTipoPagamento)
		cTipoPagamento :=  IIF(aD000[15]=="2",STR0096,cTipoPagamento)
		cTipoPagamento :=  IIF(aD000[15]=="3",STR0091,cTipoPagamento)
		cTipoPagamento :=  IIF(aD000[15]=="4",STR0069,cTipoPagamento)
		cTipoPagamento :=  IIF(aD000[15]=="5",STR0038,cTipoPagamento)
		cTipoPagamento :=  IIF(aD000[15]=="6",STR0089,cTipoPagamento)
		cTipoPagamento :=  IIF(aD000[15]=="7",STR0060,cTipoPagamento)
		cTipoPagamento :=  IIF(aD000[15]=="8",STR0027,cTipoPagamento)
		cTipoPagamento :=  IIF(aD000[15]=="9",STR0095,cTipoPagamento)

		if li > 30
			li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		endif
		//
		@li++, 0 psay " "
		@li++, 0 psay Left(STR0059 + Replicate("=",80),80)
		@li++, 0 psay STR0045+dtoc(aD000[3])
		@li++, 0 psay STR0123+dtoc(aD000[14])
		@li++, 0 psay STR0082 + Alltrim(STR(aD000[4])) + "/" + aD000[5]
		@li++, 0 psay STR0087 + Alltrim(STR(aD000[7])) + "(" + Alltrim(STR(aD000[6])) + " - " + cPlantaFaturamento+ ") - " +cIdentPedido
		@li++, 0 psay STR0076 + Alltrim(aD000[9]) +" - "+ cIdentVenda
		if (aD000[10] + aD000[11] != 0)
			@li++, 0 psay STR0035 + aD000[10] +"/" + Alltrim(STR(aD000[11]))
		endif
		if aD000[12] != 0
			@li++, 0 psay STR0016 + Alltrim(STR(aD000[12]))
		endif
		@li++, 0 psay STR0110 + aD000[15] + " - " + cTipoPagamento
		@li++, 0 psay STR0046 + Alltrim(STR(aD000[16]))
		@li++, 0 psay STR0047 + Alltrim(STR(aD000[17]))
		if (aD000[18] != "")
			@li++, 0 psay STR0011 + aD000[18]
		endif
		@li++, 0 psay STR0074 + IIF(aD000[19]=="S",STR0105,STR0081)
		@li++, 0 psay STR0062 +aD000[13]
		if !Empty(aD001)
			cPlantaFaturamento := STR0005
			cPlantaFaturamento := IIF(aD001[6]==6,STR0043,cPlantaFaturamento)
			cPlantaFaturamento := IIF(aD001[6]==41,STR0009,cPlantaFaturamento)
			cPlantaFaturamento := IIF(aD001[6]==51,STR0008,cPlantaFaturamento)
			cPlantaFaturamento := IIF(aD001[6]==52,STR0103,cPlantaFaturamento)
			cPlantaFaturamento := IIF(aD001[6]==53,STR0107,cPlantaFaturamento)
			cPlantaFaturamento := IIF(aD001[6]==55,STR0102,cPlantaFaturamento)
			cPlantaFaturamento := IIF(aD001[6]==57,STR0042,cPlantaFaturamento)
			cPlantaFaturamento := IIF(aD001[6]==1,STR0008,cPlantaFaturamento)
			cPlantaFaturamento := IIF(aD001[6]==3,STR0107,cPlantaFaturamento)
			cPlantaFaturamento := IIF(aD001[6]==8,STR0101,cPlantaFaturamento)

			@li++, 0 psay Left(STR0121+ " "+Repl("-",80),80)
			//			@li++, 0 psay SPACE(10)+STR0045+dtoc(aD001[3])
			//			@li++, 0 psay SPACE(10)+STR0082 + Alltrim(STR(aD001[4])) + "/" + aD001[5]
			@li++, 0 psay SPACE(10)+STR0030 + Alltrim(aD001[7]) + " - " + aD001[8]
			@li++, 0 psay SPACE(10)+STR0057 + Left(Alltrim(aD001[9]),40) + " - "+ STR0021 + aD001[10]
			@li++, 0 psay SPACE(10)+STR0028 + Alltrim(STR(aD001[11]))+ "-" + Alltrim(STR(aD001[12]))+ "    "+ aD001[13] + "/" + aD001[14]
		endif
		if !Empty(aD002)
			cIdentVeiculo :=STR0006
			cIdentVeiculo := IIF(aD002[7]=="A",STR0013,cIdentVeiculo)
			cIdentVeiculo := IIF(aD002[7]=="D",STR0012,cIdentVeiculo)
			cIdentVeiculo := IIF(aD002[7]=="L",STR0147,cIdentVeiculo)
			cIdentVeiculo := IIF(aD002[7]=="T",STR0112,cIdentVeiculo)
			cIdentVeiculo := IIF(aD002[7]=="O",STR0114,cIdentVeiculo)
			cIdentVeiculo := IIF(aD002[7]=="M",STR0113,cIdentVeiculo)
			cIdentVeiculo := IIF(aD002[7]=="S",STR0104,cIdentVeiculo)
			cIdentVeiculo := IIF(aD002[7]=="V",STR0148,cIdentVeiculo)
			cIdentVeiculo := IIF(aD002[7]=="A" .and. lTegu,STR0015,cIdentVeiculo)
			cIdentVeiculo := IIF(aD002[7]=="M" .and. lTegu,STR0078,cIdentVeiculo)
			cIdentVeiculo := IIF(aD002[7]=="O" .and. lTegu,STR0083,cIdentVeiculo)
			cIdentVeiculo := IIF(aD002[7]=="T" .and. lTegu,STR0026,cIdentVeiculo)
			cIdentVeiculo := IIF(aD002[7]=="U" .and. lTegu,STR0118,cIdentVeiculo)

			cCombustivel := STR0004
			cCombustivel := IIF(aD002[17]=="1",STR0007,cCombustivel)
			cCombustivel := IIF(aD002[17]=="2",STR0072,cCombustivel)
			cCombustivel := IIF(aD002[17]=="3",STR0052 ,cCombustivel)
			cCombustivel := IIF(aD002[17]=="4",STR0071 ,cCombustivel)
			cCombustivel := IIF(aD002[17]=="5",STR0070 ,cCombustivel)
			cCombustivel := IIF(aD002[17]=="6",STR0056 ,cCombustivel)
			cCombustivel := IIF(aD002[17]=="7",STR0055 ,cCombustivel)
			cCombustivel := IIF(aD002[17]=="8",STR0073,cCombustivel)

			@li++, 0 psay Left(STR0120+ " " + Repl("-",80),80)
			@li++, 0 psay SPACE(5)+STR0109 + aD002[7] + " - " +  cIdentVeiculo + IIF(aD002[18]=="T",STR0003,"")
			@li++, 0 psay SPACE(5)+STR0079 + aD002[11] + SPACE(10) + STR0010+Alltrim(str(aD002[15]))+"/"+Alltrim(str(aD002[16]))
			@li++, 0 psay SPACE(5)+STR0090 + Alltrim(STR(aD002[39]))+ " " + aD002[40]
			@li++, 0 psay SPACE(5)+STR0033 + cCombustivel

			if Len(aD003) > 0
				@li++, 0 psay SPACE(5)+STR0050 + Alltrim(aD003[15])
			endif
			if Len(aD007) > 0
				if !Empty(aD007[7])
					@li++, 0 psay SPACE(5)+STR0051 + Alltrim(aD007[7])
				endif
				@li++, 0 psay SPACE(5)+STR0014 + Alltrim(aD007[8])
			endif

			if Len(aD003) > 0
				@li++, 0 psay SPACE(5)+STR0029 + Alltrim(aD003[7])
				@li++, 0 psay SPACE(5)+STR0100 + Alltrim(STR(aD003[8])) + STR0002+Alltrim(STR(aD003[9]))
				@li++, 0 psay SPACE(5)+STR0080 + Alltrim(aD003[14])
				if Alltrim(aD003[10]) != ""
					@li, 0 psay SPACE(5)+STR0031 + Alltrim(aD003[10])
					@li++, 40 psay STR0044 + SUBS(str(aD003[11],8),1,2)+"/"+SUBS(str(aD003[11],8),3,2)+"/"+SUBS(str(aD003[11],8),5,4)
					@li, 0 psay SPACE(5)+STR0032 + aD003[12]
					@li++, 40 psay STR0044 + SUBS(str(aD003[13],8),1,2)+"/"+SUBS(str(aD003[13],8),3,2)+"/"+SUBS(str(aD003[13],8),5,4)
				endif
			endif

			if !Empty(aD002[8])
				@li++, 0 psay SPACE(5)+STR0122 + aD002[8] + "   " +  STR0037 + aD002[9] + " - " + Alltrim(aD002[14])
			endif
			if !Empty(aD002[10])
				@li++, 0 psay SPACE(5)+STR0058 + aD002[10]
			endif
			if !Empty(aD002[12])
				@li++, 0 psay SPACE(5)+STR0054 + aD002[12] + "   " +  STR0037 + aD002[13] + " - " + Alltrim(aD002[14])
			endif

			@li++, 0 psay SPACE(5)+STR0084
			nAcessorios := 0
			cStrAcessorios := ""
			for nCntFor := 19 to 38
				if !Empty(Alltrim(aD002[nCntFor]))
					nAcessorios++
					cStrAcessorios +=aD002[nCntFor]+"/"
				endif
				if nAcessorios == 10
					@li++, 0 psay SPACE(8) + cStrAcessorios
					nAcessorios = 0
					cStrAcessorios := ""
				endif
			next
			if Len(aD008) > 0
				for nCntFor := 7 to 46
					if !Empty(Alltrim(aD008[nCntFor]))
						nAcessorios++
						cStrAcessorios += aD008[nCntFor]+"/"
					endif
					if nAcessorios == 10
						@li++, 0 psay SPACE(8) + cStrAcessorios
						nAcessorios = 0
						cStrAcessorios := ""
					endif
				next
			endif
			if !Empty(cStrAcessorios)
				@li++, 0 psay SPACE(8) + cStrAcessorios
			endif
		endif
		if !Empty(aD004)
			@li++, 0 psay Left(STR0119+ " " + Repl("-",80),80)
			@li++, 0 psay STR0138 + Transform(aD004[7],"@E 999,999,999.99")
			@li, 40 psay STR0115 + Transform(aD004[8],"@E 99,999,999.999")
			@li++, 0 psay STR0049 + Transform(aD004[9],"@E 999,999,999.99")
			@li, 40 psay STR0075 + Transform(aD004[10],"@E 999,999,999.99")
			@li++, 0 psay STR0018 + Transform(aD004[11],"@E 999,999,999.99")
			@li, 40 psay STR0136 + Transform(aD004[12],"@E 999,999,999.99")
			@li++, 0 psay STR0017 + Transform(aD004[13],"@E 999,999,999.99")
			@li, 40 psay STR0135 + Transform(aD004[19],"@E 999,999,999.99")
			@li++, 0 psay STR0116 + Transform(aD004[14],"@E 999,999,999.99")
			@li, 40 psay STR0020 + Transform(aD004[15],"@E 999,999,999.99")
			@li++, 0 psay STR0137 + Transform(aD004[16],"@E 999,999,999.99")
			@li, 40 psay STR0108 + Transform(aD004[17],"@E 999,999,999.99")
			@li++, 0 psay STR0019 + Transform(aD004[18],"@E 999,999,999.99")
		endif
		if !Empty(aD005)
			@li, 0 psay STR0098 + Transform(aD005[7],"@E 9999,999.99999")
			@li++, 40 psay STR0099 + Transform(aD005[8],"@E 9999,999.99999")
			@li, 0 psay STR0143 + Transform(aD005[9],"@E 999,999,999.99")
			@li++, 40 psay STR0146 + Transform(aD005[10],"@E 999,999,999.99")
			@li, 0 psay STR0144 + Transform(aD005[11],"@E 999,999,999.99")
			@li++, 40 psay STR0145 + Transform(aD005[12],"@E 999,999,999.99")
			@li, 0 psay STR0139 + Transform(aD005[13],"@E 999,999,999.99")
			@li++, 40 psay STR0142 + Transform(aD005[14],"@E 999,999,999.99")
			@li, 0 psay STR0141 + Transform(aD005[15],"@E 999,999,999.99")
			@li++, 40 psay STR0140 + Transform(aD005[16],"@E 999,999,999.99")
		endif


		// ZERA VETORES
		aD000 := {}
		aD001 := {}
		aD002 := {}
		aD003 := {}
		aD004 := {}
		aD005 := {}
		aD007 := {}
		aD008 := {}
	endif
	if Len(aInfo) == 1
		return
	endif
	aD000 := aClone(aInfo)
elseif aInfo[2] == 1
	aD001 := aClone(aInfo)
elseif aInfo[2] == 2
	aD002 := aClone(aInfo)
elseif aInfo[2] == 3
	aD003 := aClone(aInfo)
elseif aInfo[2] == 4
	aD004 := aClone(aInfo)
elseif aInfo[2] == 5
	aD005 := aClone(aInfo)
elseif aInfo[2] == 7
	aD007 := aClone(aInfo)
elseif aInfo[2] == 8
	aD008 := aClone(aInfo)
endif
//
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³ ExtraiEDI º Autor ³ Luis Delorme             º Data ³ 26/03/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao³ Monta vetores a partir de uma descrição de layout e da linha deº±±
±±º         ³ importação EDI                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno ³ aRet - Valores extraídos da linha                              º±±
±±º         ³        Se der erro o vetor retorna {}                          º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro³ aLayout[n,1] = Tipo do campo ([D]ata,[C]aracter ou [N]umerico) º±±
±±º         ³ aLayout[n,2] = Tamanho do Campo                                º±±
±±º         ³ aLayout[n,3] = Quantidade de Decimais do Campo                 º±±
±±º         ³ aLayout[n,4] = Posição Inicial do Campo na Linha               º±±
±±º         ³                                                                º±±
±±º         ³ cLinhaEDI    = Linha para extração das informações             º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º                                                                          º±±
±±º  EXEMPLO DE PREENCHIMENTO DOS VETORES                                    º±±
±±º                                                                          º±±
±±º  aAdd(aLayout,{"C",10,0,1})                                              º±±
±±º  aAdd(aLayout,{"C",20,0,11})                                             º±±
±±º  aAdd(aLayout,{"N",5,2,31})                                              º±±
±±º  aAdd(aLayout,{"N",4,0,36})                                              º±±
±±º                        1         2         3                             º±±
±±º               123456789012345678901234567890'123456789                    º±±
±±º  cLinhaEDI = "Jose SilvaVendedor Externo    123121234                    º±±
±±º                                                                          º±±
±±º  No caso acima o retorno seria:                                          º±±
±±º  aRet[1] - "Jose Silva"                                                  º±±
±±º  aRet[2] - "Vendedor Externo"                                            º±±
±±º  aRet[3] - 123,12                                                        º±±
±±º  aRet[4] - 1234                                                          º±±
±±º                                                                          º±±
±±º                                                                          º±±
±±º                                                                          º±±
±±º                                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function ExtraiEDI(aLayout, cLinhaEDI)
Local aRet := {}
Local nCntFor, nCntFor2

cLinhaEDI := cLinhaEDI + space(1000)

for nCntFor = 1 to Len(aLayout)
	//
	cTipo := aLayout[nCntFor,1]
	nTamanho := aLayout[nCntFor,2]
	nDecimal := aLayout[nCntFor,3]
	nPosIni := aLayout[nCntFor,4]
	//
	if nPosIni + nTamanho - 1 > Len(cLinhaEDI)
		return {}
	endif
	cStrTexto := Subs(cLinhaEDI,nPosIni,nTamanho)
	ncValor := ""
	if Alltrim(cTipo) == "N"
		for nCntFor2 := 1 to Len(cStrTexto)
			if !(Subs(cStrTexto,nCntFor2,1)$"0123456789 ")
				return {}
			endif
		next
		ncValor = VAL(cStrTexto) / (10 ^ nDecimal)
	elseif Alltrim(cTipo) == "D"
		cStrTexto := Left(cStrTexto,2)+"/"+subs(cStrTexto,3,2)+"/"+Right(cStrTexto,4)
		if ctod(cStrTexto) == ctod("  /  /  ")
			return {}
		endif
		ncValor := ctod(cStrTexto)
	else
		ncValor := cStrTexto
	endif
	aAdd(aRet, ncValor)
next

return aRet
