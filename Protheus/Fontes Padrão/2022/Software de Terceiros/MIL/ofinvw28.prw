// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 6      º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "OFINVW28.ch"

#define STR0024 "REAPROVEITAR"
#define STR0025 "REAPROVEITAR"
#define STR0026 "REAPROVEITAR"
#define STR0027 "REAPROVEITAR"
#define STR0028 "REAPROVEITAR"
#define STR0029 "REAPROVEITAR"
#define STR0030 "REAPROVEITAR"
#define STR0031 "REAPROVEITAR"
#define STR0032 "REAPROVEITAR"
#define STR0033 "REAPROVEITAR"
#define STR0034 "REAPROVEITAR"
#define STR0035 "REAPROVEITAR"
#define STR0036 "REAPROVEITAR"
#define STR0037 "REAPROVEITAR"
#define STR0038 "REAPROVEITAR"
#define STR0039 "REAPROVEITAR"
#define STR0040 "REAPROVEITAR"
#define STR0041 "REAPROVEITAR"
#define STR0042 "REAPROVEITAR"
#define STR0043 "REAPROVEITAR"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | OFINVW28   | Autor | Luis Delorme          | Data | 27/03/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Importação do Layout referente ao Informativo de NFs Cred/Deb|##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFINVW28(lEnd, cArquivo)
//
Local nCurArq
//
Local aLayoutFN0 := {}
Local aLayoutFN1 := {}
Local aLayoutFN2 := {}
  
Private nAnt    := -1 
Private nValLiq := 0
Private nVlLq   := ""
Private nValIR  := 0
Private nVlIR   := ""
  
aAdd(aLayoutFN0, {"C",3,0,001," "}) //  "TIPO DE REGISTRO"})
aAdd(aLayoutFN0, {"N",2,0,004," "}) //   "SUB-CÓDIGO DO REGISTRO"})
aAdd(aLayoutFN0, {"N",6,0,006," "}) //   "NÚMERO DO DN"})
aAdd(aLayoutFN0, {"C",25,0,012," "}) //  "RAZÃO SOCIAL (NOME DO DN)"})
aAdd(aLayoutFN0, {"C",40,0,037," "}) //  "ENDEREÇO"})
aAdd(aLayoutFN0, {"C",20,0,077," "}) //  "COMPLEMENTO DO ENDEREÇO"})
aAdd(aLayoutFN0, {"C",30,0,097," "}) //  "CIDADE"})
aAdd(aLayoutFN0, {"C",2,0,127," "}) //   "ESTADO"})
aAdd(aLayoutFN0, {"C",8,0,129," "}) //   "CEP"})
aAdd(aLayoutFN0, {"C",51,0,137," "}) //  "BRANCOS"})
aAdd(aLayoutFN0, {"N",6,0,188," "}) //   "LAYOUT VERSÃO"})

aAdd(aLayoutFN1, {"C",3,0,001," "}) //   "TIPO DE REGISTRO"})
aAdd(aLayoutFN1, {"N",2,0,004," "}) //   "SUB-CÓDIGO DO REGISTRO"})
aAdd(aLayoutFN1, {"C",1,0,006," "}) //   "TIPO DE NOTA"})
aAdd(aLayoutFN1, {"C",25,0,007," "}) //  "NOME"})
aAdd(aLayoutFN1, {"C",18,0,032," "}) //  "CNPJ"})
aAdd(aLayoutFN1, {"C",18,0,050," "}) //  "INSCRIÇÃO ESTADUAL"})
aAdd(aLayoutFN1, {"C",50,0,068," "}) //  "ENDEREÇO"})
aAdd(aLayoutFN1, {"N",6,0,118," "}) //  "NÚMERO"})
aAdd(aLayoutFN1, {"N",4,0,124," "}) //  "SÉRIE"})
aAdd(aLayoutFN1, {"D",6,0,128," "}) //  "DATA DE EMISSÃO"})
aAdd(aLayoutFN1, {"D",6,0,134," "}) //  "DATA DO VENCIMENTO"})
aAdd(aLayoutFN1, {"C",25,0,140," "}) //  "NOME DO CONTATO"})
aAdd(aLayoutFN1, {"N",4,0,165," "}) //   "NÚMERO DO SETOR"})
aAdd(aLayoutFN1, {"N",11,0,169," "}) //  "NÚMERO DO TELEFONE"})
aAdd(aLayoutFN1, {"N",4,0,180," "}) //   "NÚMERO DA CAIXA POSTAL INTERNA"})
aAdd(aLayoutFN1, {"C",10,0,184," "}) //  "BRANCOS"})

aAdd(aLayoutFN2, {"C",3,0,001," "}) //  "TIPO DE REGISTRO (FNT)"})
aAdd(aLayoutFN2, {"N",2,0,004," "}) //  "SUB-CÓDIGO DO REGISTRO"})
aAdd(aLayoutFN2, {"C",188,0,006," "}) //  "DESCRIÇÃO DO HISTÓRICO"})

aAdd(aIntCab,{STR0023,"C",145,"@!"})
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
		if Left(cStr,5)=="FNT00"
			aInfo := ExtraiEDI(aLayoutFN0,cStr)
		elseif Left(cStr,5)=="FNT01"
			aInfo := ExtraiEDI(aLayoutFN1,cStr)
		elseif Left(cStr,5)=="FNT02"
			aInfo := ExtraiEDI(aLayoutFN2,cStr)
		endif
		// Trabalhar com aInfo gravando as informações
		if Left(cStr,5) $ "FNT00.FNT01.FNT02"
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
//
// Realizar as atualizações necessárias a partir das informações extraídas
// fazer verificações de erro e atualizar o vetor aIntIte ou aLinErros conforme
// o caso
Local Tamanho := "P"
Titulo := STR0001
Cabec1 := " "
Cabec2 := ""
NomeProg := "OFINVW28"

if li > 60
	li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	@li ++ ,1 psay " "
endif
//
if Empty(aInfo)
	@li ++ ,1 psay cArquivo + STR0015 + Alltrim(STR(nLinhArq))
endif
//
if aInfo[2] == 0
	If li > 6 //Para sempre imprimir no inicio da pagina.
		li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	EndIf
	@li++ ,1 psay STR0009 + STRZERO(aInfo[3],6)
	@li++ ,1 psay STR0010 + Alltrim(aInfo[4])
	@li++ ,1 psay STR0011 + Alltrim(aInfo[5]) + " - " + Alltrim(aInfo[6])
	@li++ ,1 psay STR0012+Alltrim(aInfo[7]) + SPACE(9)+ STR0013 + Alltrim(aInfo[8])+"   "+STR0014+Transform(aInfo[9],"@R 99999-999")
	li++
elseif aInfo[2] == 1
	li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	@li ++ ,1 psay " "
	@li++ ,1 psay STR0008 + aInfo[3] + " - " + IIF(aInfo[3] == "C",STR0016,STR0017)
	li++
	@li++ ,1 psay STR0002 + Alltrim(aInfo[4])
	@li++ ,1 psay STR0003 + AllTrim(aInfo[5])
	@li++ ,1 psay STR0004 + Alltrim(aInfo[6])
	@li++ ,1 psay STR0005 + Alltrim(aInfo[7])
	@li++
	@li++ ,1 psay STR0018+Alltrim(STR(aInfo[8])) + " / " + Alltrim(STR(aInfo[9]))
	@li++ ,1 psay STR0006 + dtoc(aInfo[10])
	@li++ ,1 psay STR0007 + dtoc(aInfo[11])
	@li++
	@li++ ,1 psay STR0019 + Alltrim(aInfo[12])
	@li++ ,1 psay STR0020 + Alltrim(STR(aInfo[13]))
	@li++ ,1 psay STR0021 + AllTrim(STR(aInfo[14]))
	@li++ ,1 psay STR0022 + Alltrim(STR(aInfo[15]))
	@li++
elseif aInfo[2] == 2
	@li++ ,1 psay "    | "+Left(aInfo[3]+space(80),73) + "|"
endif
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
		cStrTexto := Left(cStrTexto,2)+"/"+subs(cStrTexto,3,2)+"/"+Right(cStrTexto,2)
		if ctod(cStrTexto) == ctod("  /  /  ")                         
			return {}
		endif
		ncValor := ctod(cStrTexto)
	else
		ncValor := cStrTexto
	endif

   if cTipo = "C"
	
		if "IR  SOBRE COMISSOES" $ ncValor
	
			lPriIR := .T.
			cPosIR := ""
			for nCntFor2 := 1 to Len(cStrTexto)
				if Subs(cStrTexto,nCntFor2,1)$"0123456789"
			   	if lPriIR
				   	cPosIR := nCntFor2
					   lPriIR := .F.
					endif   
					nVlIR += Subs(cStrTexto,nCntFor2,1)
				endif
			next                      
		
      	nValIR := VAL(nVlIR) / 100
      
		endif
	


   	if "TOTAL LIQUIDO" $ ncValor
   
			lPriTL := .T.
			cPosTL := ""
			for nCntFor2 := 1 to Len(cStrTexto)
				if Subs(cStrTexto,nCntFor2,1)$"0123456789"
			   	if lPriTL
				   	cPosTL := nCntFor2
					   lPriTL := .F.
					endif   
					nVlLq += Subs(cStrTexto,nCntFor2,1)
				endif
			next                      
		
      	nValLiq := VAL(nVlLq) / 100
   
	      nValLiq := nValLiq - nValIR
 
   	   ncValor := left(cStrTexto,cPosTL-1) + transform(nValLiq,"@E 999,999.99")
      
      	nValIR  := 0
	      nVlIR   := ""
   	   lPriIR  := .T.
   	   nValLiq :=0
   	   nVlLq   := "" 
     	   lPriTL  := .T.     
     	   
	   endif

   endif

	aAdd(aRet, ncValor)

next

return aRet
