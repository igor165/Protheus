// �����������������ͻ
// � Versao � 4      �
// �����������������ͼ

#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "OFINVW24.ch"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun��o    | OFINVW24   | Autor | Luis Delorme          | Data | 27/03/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri��o | Importa��o do Layout referente aquisi��o a Prazo    			|##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFINVW24(lEnd, cArquivo)
//
Local nCurArq
//
//
Local aLayoutFN0 := {}
Local aLayoutFN1 := {}
Local aLayoutFN2 := {}

Private nAnt := 0

aAdd(aLayoutFN0, {"C",	3	,0,	001," " }) // "TIPO DE REGISTRO"})
aAdd(aLayoutFN0, {"N",	5	,0,	004," " }) // "SUB-C�DIGO DO REGISTRO"})
aAdd(aLayoutFN0, {"C",	179, 0,	009," " }) // "CABE�ALHO INICIAL A SER IMPRESSO"})
aAdd(aLayoutFN0, {"N",	6	,0,	188," " }) // "LAYOUT VERS�O (Fixo: 040501)"})

aAdd(aLayoutFN1, {	"C",3,0,001," " }) // "TIPO DE REGISTRO (FCR)"				   })
aAdd(aLayoutFN1, {	"N",5,0,004," " }) // "SUB-C�DIGO DO REGISTRO (Fixo=32001)"	   })
aAdd(aLayoutFN1, {	"N",6,0,009," " }) // "N�MERO DA NOTA FISCAL FATURA"			   })
aAdd(aLayoutFN1, {	"N",2,0,015," " }) // "SUFIXO DA NOTA"						   })
aAdd(aLayoutFN1, {	"N",1,0,017," " }) // "TIPO DA NOTA"							   })
aAdd(aLayoutFN1, {	"D",8,0,018," " }) // "DATA DE EMISS�O (ddmmaaaa)"			   })
aAdd(aLayoutFN1, {	"D",8,0,026," " }) // "DATA DO PRIMEIRO VENCIMENTO (ddmmaaaa)"  })
aAdd(aLayoutFN1, {  "D",8,0,034," " }) // "DATA DO SEGUNDO VENCIMENTO (ddmmaaaa)"    })
aAdd(aLayoutFN1, {	"N",15,2,042," " }) //"VALOR DA DUPLICATA"					   })
aAdd(aLayoutFN1, {	"N",15,2,057," " }) //"VALOR PAGO"							   })
aAdd(aLayoutFN1, {	"N",15,2,072," " }) //"SALDO DEVEDOR"						   })
aAdd(aLayoutFN1, {	"D",8,0,087," " }) // "DATA DO PAGAMENTO (ddmmaaaa)"			   })
aAdd(aLayoutFN1, {	"C",4,0,095," " }) // "TIPO DE DOCUMENTO"					   })
aAdd(aLayoutFN1, {	"N",6,0,099," " }) // "N�MERO DO DN INTERNO"					   })
aAdd(aLayoutFN1, {	"N",1,0,105," " }) // "F�BRICA N�MERO"						   })
aAdd(aLayoutFN1, {	"C",88,0,106," " }) //"BRANCOS"								   })

aAdd(aLayoutFN2, {"C",	3	,0,	001," " }) // "TIPO DE REGISTRO (FLH)"})
aAdd(aLayoutFN2, {"N",	5	,0,	004," " }) // "SUB-C�DIGO DO REGISTRO (Fixo=55502)"})
aAdd(aLayoutFN2, {"C",	185 ,0,	009," " }) // "CABE�ALHO FINAL A SER IMPRESSO"})
//
// PROCESSAMENTO DOS ARQUIVOS
//
aAdd(aArquivos,cArquivo)
// La�o em cada arquivo
for nCurArq := 1 to Len(aArquivos)
	// pega o pr�ximo arquivo
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
		// Informa��es extra�das da linha do arquivo de importa��o ficam no vetor aInfo
		if Left(cStr,8)=="FCR32000"
			aInfo := ExtraiEDI(aLayoutFN0,cStr)
		elseif Left(cStr,8)=="FCR32001"
			aInfo := ExtraiEDI(aLayoutFN1,cStr)
		elseif Left(cStr,8)=="FCR32002"
			aInfo := ExtraiEDI(aLayoutFN2,cStr)
		endif
		// Trabalhar com aInfo gravando as informa��es
		if Left(cStr,8) $ "FCR32000.FCR32001.FCR32002"
			GrvInfo(aInfo)
		endif
		FT_FSkip()
	EndDo
	//
	FT_FUse()
next
//
return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun��o    | GrvInfo    | Autor | Luis Delorme          | Data | 17/03/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri��o | Processa o resultado da importa��o                           |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function GrvInfo(aInfo)
// Realizar as atualiza��es necess�rias a partir das informa��es extra�das
// fazer verifica��es de erro e atualizar o vetor aIntIte ou aLinErros conforme
// o caso
Titulo := STR0038
Cabec1 := " "
Cabec2 := ""
cCab := STR0039
NomeProg := "OFINVW24"
if li > 65
	li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	@li ++ ,1 psay " "
endif
//
if Empty(aInfo)
	@li ++ ,1 psay cArquivo + STR0020 + Alltrim(STR(nLinhArq))
endif
// Realizar as atualiza��es necess�rias a partir das informa��es extra�das
// fazer verifica��es de erro e atualizar o vetor aIntIte ou aLinErros conforme
// o caso
if aInfo[2] == 32000
	if nAnt == 32002 .or.nAnt == 32001
		li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		@li ++ ,1 psay " "
	endif 
	@li ++ ,1 psay Alltrim(aInfo[3])
	nAnt := 32000
elseif aInfo[2] == 32001
	if nAnt != 32001
		@li ++ ,1 psay cCab
	endif
	cSufixoNF := IIF(aInfo[4] == 0,STR0021,IIF(aInfo[4] == 1,STR0022,STR0023))
	cTipoNF := IIF(aInfo[5] == 1,STR0024,IIF(aInfo[5] == 2,STR0025,IIF(aInfo[5] == 2,STR0026,STR0027)))
	@li ++ ,1 psay  ;
	STRZERO(aInfo[3],9)  + "  " +  Left(dtoc(aInfo[6])+space(10),10) + " " +  Left(dtoc(aInfo[7])+space(10),10) + " " + Left(dtoc(aInfo[8])+space(10),10) + " " + Left(dtoc(aInfo[12])+space(10),10) + " " + ;
	Transform(aInfo[9],"@E 999,999,999,999.99") + " " + ;
	Transform(aInfo[10],"@E 999,999,999,999.99") + " " + ;
	Transform(aInfo[11],"@E 999,999,999,999.99") + " " + ;
	aInfo[13] + " " + STRZERO(aInfo[14],6) + " " + cTipoNF + " " + cSufixoNF +" "+ strzero(aInfo[15],1)
	nAnt := 32001
elseif aInfo[2] == 32002
	@li ++ ,1 psay Alltrim(aInfo[3])
	nAnt := 32002
endif

return
/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa � ExtraiEDI � Autor � Luis Delorme             � Data � 26/03/13 ���
����������������������������������������������������������������������������͹��
���Descricao� Monta vetores a partir de uma descri��o de layout e da linha de���
���         � importa��o EDI                                                 ���
����������������������������������������������������������������������������͹��
��� Retorno � aRet - Valores extra�dos da linha                              ���
���         �        Se der erro o vetor retorna {}                          ���
����������������������������������������������������������������������������͹��
���Parametro� aLayout[n,1] = Tipo do campo ([D]ata,[C]aracter ou [N]umerico) ���
���         � aLayout[n,2] = Tamanho do Campo                                ���
���         � aLayout[n,3] = Quantidade de Decimais do Campo                 ���
���         � aLayout[n,4] = Posi��o Inicial do Campo na Linha               ���
���         �                                                                ���
���         � cLinhaEDI    = Linha para extra��o das informa��es             ���
����������������������������������������������������������������������������͹��
���                                                                          ���
���  EXEMPLO DE PREENCHIMENTO DOS VETORES                                    ���
���                                                                          ���
���  aAdd(aLayout,{"C",10,0,1})                                              ���
���  aAdd(aLayout,{"C",20,0,11})                                             ���
���  aAdd(aLayout,{"N",5,2,31})                                              ���
���  aAdd(aLayout,{"N",4,0,36})                                              ���
���                        1         2         3                             ���
���               123456789012345678901234567890'123456789                    ���
���  cLinhaEDI = "Jose SilvaVendedor Externo    123121234                    ���
���                                                                          ���
���  No caso acima o retorno seria:                                          ���
���  aRet[1] - "Jose Silva"                                                  ���
���  aRet[2] - "Vendedor Externo"                                            ���
���  aRet[3] - 123,12                                                        ���
���  aRet[4] - 1234                                                          ���
���                                                                          ���
���                                                                          ���
���                                                                          ���
���                                                                          ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
*/
Static Function ExtraiEDI(aLayout, cLinhaEDI)
Local aRet := {}
Local nCntFor, nCntFor2

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
		ncValor := ctod(cStrTexto)
	else
		ncValor := cStrTexto
	endif
	aAdd(aRet, ncValor)
next

return aRet
