#INCLUDE "Protheus.ch"
#INCLUDE "FISR501.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ FISR501  ³ Autor ³ Marcos Aurelio (Mano) ³ Data ³ 19/10/2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Livro de Retencoes                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³ Manutencao Efetuada                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³ Uso      ³ Fiscal - Paraguai                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FISR501()
Local aOrd     := {}
Local cDesc1   := STR0002 //"Este programa tiene como objetivo imprimir informe "
Local cDesc2   := STR0003 //"de acuerdo con los parámetros informados por el usuario."
Local cDesc3   := STR0001 //"Livro de Retencão  "
Local cTitulo  := STR0004 //"Resumo de Retencoes"
Local cTamanho := "G"
Local cNomProg := "FISR501" 
Local nTipo    := 0
Local cPerg    := "FSR501"+Space((Len(SX1->X1_GRUPO)-6))
Local cString  := "SF3"
Local lImpRel  := .f.

Private aArqTXT     := {}	// Array auxiliar para geracao do arquivo magnetico
Private m_pag       := 01
Private aReturn     := {OemToAnsi(STR0005),1,OemToAnsi(STR0006),2,2,1,"",1}  //"Zebrado"###"Administracao"
Private nLastKey    := 0
Private cbtxt       := Space(10)
Private cbcont      := 00
Private wnrel       := "FISR501" 
Private lAbortPrint := .F.

Pergunte(cPerg,.F.)

wnrel := SetPrint(cString,cNomProg,cPerg,cTitulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,cTamanho,,.F.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,15,18)

RptStatus({|| lImpRel := RunReport(cTitulo,nTipo)},cTitulo)

If lImpRel
	Processa({|| GeraArq(AllTrim(MV_PAR07))},,STR0021) // "Gerando arquivo"
EndIf	

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³RunReport  ³ Autor ³ Marco Aurelio(Mano)   ³ Data ³ 20/10/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Imprime Livro de Retencoes                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³RunReport(ExpC1,ExpN1,ExpN2)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 = Titulo do relatorio                                  ³±±
±±³          ³ExpN1 = Tipo de caracter a ser impresso(Normal/Compactado)   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³FISR501 (Paraguai)                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RunReport(cTitulo,nTipo)                                                                                                                       
Local cRUCAgenInf := Left(SM0->M0_CGC,Len(AllTrim(SM0->M0_CGC))-1)	// RUC Agente de Informacao
Local cDVAgenInf  := Right(AllTrim(SM0->M0_CGC),1)					// Digito verificador do RUC Agente de Informacao
Local cNomAgenInf := SM0->M0_NOME									// Nome do Agente de Informacao
Local cRUCRepLeg  := AllTrim(MV_PAR12)								// RUC Representante Legal
Local cDVRepLeg   := MV_PAR13										// Digito verificador do RUC Representante Legal
Local cNomRepLeg  := AllTrim(MV_PAR14)								// Nome do Agente de Informacao
Local lForExt     := ( AllTrim(SA2->A2_CGC) == "999999010" ) 		// RUC correspondente a provedor do exterior
Local cMascNF     := ""												// Mascara de definicao para numero de comprovante
Local cMascCert   := ""												// Mascara de definicao para numero do certificado de retencao
Local cSep        := Chr(9)      									// Delimitador (TAB) para as colunas do arquivo TXT
Local cRUC        := ""   											// RUC Fornecedor
Local nMaxLinArq  := 15000											// Quantidade maxima de linhas a serem consideradas no arquivo TXT
Local nQtdLin     := 1												// Contador de linhas auxiliar para quebra de arquivos
Local cLinArq     := "" 											// String com as informacoes da linha detalhe do arquivo TXT a ser gerado
Local nMontoRep   := 0												// Soma total entre retencoes de iva e IR
Local nRetIR      := 0  
Local nRetIVA     := 0
Local nBaseIR     := 0
Local nBaseIVA    := 0
Local nTBasIR     := 0
Local nTBasIVA    := 0   
Local nTRetIR     := 0   
Local nTRetIVA    := 0   
Local nTGRetIR    := 0   
Local nTGRetIVA   := 0   
Local nTGBasIR    := 0
Local nTGBasIVA   := 0   
Local lPrimero    := .T.
Local lRet        := .F.
Local cQuery      := ""
Local cFilSa2     := xFilial("SA2")
Local nLin        := 80 
Local cAliasTMP   := GetNextAlias()
Local cTamanho    := "G"
Local cNomProg    := "FISR501" 
Local Cabec1      := "                                                 | COMPROBANTE RETENIDO |   COMPROBANTE RETENCIÓN  |           |          RETENCIÓN RENTA           |           RETENCIÓN IVA"
Local Cabec2      := "       RUC      |           RAZÓN SOCIAL         | TIPO |     NÚMERO    |    NÚMERO    |  FECHA    | TIMBRADO  |  MONTO IMPONIBLE  |   RETENCIÓN    | MONTO IMPONIBLE   |   RETENCIÓN"	// RUC##RAZÓN SOCIAL##TIPO##NÚMERO##FECHA##TIMBRADO##MONTO IMPONIBLE##RETENCIÓN
                     //  XXXXXXXXXXXXX   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX   XXX    XXXXXXXXXXXXX   XXXXXXXXXXXXX  99/99/9999  XXXXXXXXXX  999,999,999,999.99  999,999,999.99   999,999,999,999.99  999,999,999.99


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtra registros de retencoes na tabela SFE de acordo com os parametros informados ³
//³Somente os tipos I-(Retencao IVA) R-(IRPF) neste processo.                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT FE_TIPO, FE_FILIAL,FE_NFISCAL,FE_NROTES,FE_EMISSAO,FE_VALIMP,FE_RETENC,A2_CGC,A2_NOME,F1_ESPECIE,F1_NUMTIM,F1_EMISSAO FROM "+RetSqlName("SFE")+" SFE "
cQuery += "INNER JOIN "+ RetSQLTab("SA2")+" ON "
If FWModeAccess("SA2",3,)<>"C"
	cQuery +="A2_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+ "' AND "
EndIf
cQuery +="A2_COD = FE_FORNECE AND A2_LOJA = FE_LOJA " 
cQuery += "INNER JOIN "+ RetSQLTab("SF1")+" ON "
If FWModeAccess("SF1",3,)<>"C"
	cQuery +="F1_FILIAL BETWEEN ' "+MV_PAR01+"' AND '"+MV_PAR02+ "' AND " 
EndIf
cQuery +="F1_DOC = FE_NFISCAL AND F1_SERIE = FE_SERIE AND F1_FORNECE = FE_FORNECE AND F1_LOJA = FE_LOJA " 
cQuery += "WHERE "
If FWModeAccess("SFE",3,)<>"C"
	cQuery += "FE_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND "
EndIf
cQuery += "FE_EMISSAO BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' AND "
cQuery += "FE_FORNECE BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' AND "
cQuery += "FE_TIPO IN ('I','R') AND "
cQuery += "SFE.D_E_L_E_T_ <> '*' "

cQuery += "ORDER BY FE_EMISSAO,FE_ORDPAGO "

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTMP,.T.,.T.)

TCSetField(cAliasTMP,"FE_EMISSAO","D")
TCSetField(cAliasTMP,"F1_EMISSAO","D")

SetRegua(Contar(cAliasTMP, ".T."))

(cAliasTMP)->(dbGoTop())

m_pag := MV_PAR07
aAdd(aArqTxt,Array(1))

While !(cAliasTMP)->(Eof())
	
	nQtdLin++

	If lAbortPrint
		@ nLin,00 PSAY "*** "+STR0007+" ***" // "CANCELADO PELO OPERADOR"
		Exit
	Endif
	
	If nLin > 57
		
		If !lPrimero 
			
			nLin ++		
			@nLin,000 PSAY Replicate("-",220)
			nLin ++
			
			@ nLin,008 PSAY STR0016+"            -----------> " 	// "Totales de la Página"
			@ nLin,110 PSAY nTBasIR  Picture Tm(FE_VALIMP,TamSX3("FE_VALIMP")[1],0)
			@ nLin,130 PSAY nTRetIR	 Picture Tm(FE_RETENC,TamSX3("FE_RETENC")[1],0)
			@ nLin,147 PSAY nTBasIVA Picture Tm(FE_VALIMP,TamSX3("FE_VALIMP")[1],0)
			@ nLin,167 PSAY nTRetIVA Picture Tm(FE_RETENC,TamSX3("FE_RETENC")[1],0)

			nLin ++                                                       
			
			If m_Pag > (MV_PAR07+1)

				nLin ++                                                       
				@ nLin,008 PSAY STR0020+" -----------> "  	// "Totales acumulados de la página"
				@ nLin,110 PSAY nTGBasIR  Picture Tm(FE_VALIMP,TamSX3("FE_VALIMP")[1],0)
				@ nLin,130 PSAY nTGRetIR  Picture Tm(FE_RETENC,TamSX3("FE_RETENC")[1],0)
				@ nLin,147 PSAY nTGBasIVA Picture Tm(FE_VALIMP,TamSX3("FE_VALIMP")[1],0)
				@ nLin,167 PSAY nTGRetIVA Picture Tm(FE_RETENC,TamSX3("FE_RETENC")[1],0)
				nLin ++
			
			EndIf	

			nTBasIR  := 0
			nTRetIR  := 0
			nTBasIVA := 0
			nTRetIVA := 0
			
		Else
			lPrimero := .F.
		EnDif
		
		nLin := Cabec(cTitulo,Cabec1,Cabec2,cNomProg,cTamanho,nTipo)
		nLin++
		
		@ nLin,008 PSAY STR0018+" "+dtoc(MV_PAR03)+" "+STR0019+" "+dtoc(MV_PAR04)	// "Desde Fecha"##"hasta el"
		nLin++

		If m_Pag > (MV_PAR07+1)

			@ nLin,008 PSAY STR0017+" -----------> "	// "SALDO ACUMULADO DA PÁGINA ANTERIOR"
			@ nLin,110 PSAY nTGBasIR  Picture Tm(FE_VALIMP,TamSX3("FE_VALIMP")[1],0)
			@ nLin,130 PSAY nTGRetIR  Picture Tm(FE_RETENC,TamSX3("FE_RETENC")[1],0)
			@ nLin,147 PSAY nTGBasIVA Picture Tm(FE_VALIMP,TamSX3("FE_VALIMP")[1],0)
			@ nLin,167 PSAY nTGRetIVA Picture Tm(FE_RETENC,TamSX3("FE_RETENC")[1],0)
			nLin++

		EndIf
		
		@ nLin,000 PSAY Replicate("-",220)
  		nLin++
		
	Endif
	
	If !Empty(cFilSA2)
		cFilSA2 := (cAliasTMP)->FE_FILIAL
	EndIf

	@ nLin,003 PSAY (cAliasTMP)->A2_CGC					Picture PesqPict ("SA2","A2_CGC")
	@ nLin,018 PSAY Substr((cAliasTMP)->A2_NOME,1,30) 	Picture PesqPict ("SA2","A2_NOME")
	@ nLin,052 PSAY (cAliasTMP)->F1_ESPECIE		   		
	@ nLin,058 PSAY (cAliasTMP)->FE_NFISCAL				Picture PesqPict ("SFE","FE_NFISCAL")
	@ nLin,074 PSAY (cAliasTMP)->FE_NROTES       		Picture PesqPict ("SFE","FE_NROTES")
	@ nLin,089 PSAY (cAliasTMP)->FE_EMISSAO 
   	@ nLin,101 PSAY (cAliasTMP)->F1_NUMTIM  

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atribui valores conforme tipo: I-(Retencao IVA) ou  R-(IR) ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (cAliasTMP)->FE_TIPO == "I" 		
		nBaseIVA  += (cAliasTMP)->FE_VALIMP	 
		nRetIVA	  += (cAliasTMP)->FE_RETENC
		nTBasIVA  += (cAliasTMP)->FE_VALIMP 
		nTRetIVA  += (cAliasTMP)->FE_RETENC  
		nTGBasIVA += (cAliasTMP)->FE_VALIMP  
		nTGRetIVA += (cAliasTMP)->FE_RETENC   
		nMontoRep += (cAliasTMP)->FE_RETENC  
	Else	
		nBaseIR   += (cAliasTMP)->FE_VALIMP	 
		nRetIR	  += (cAliasTMP)->FE_RETENC
		nTBasIR   += (cAliasTMP)->FE_VALIMP 
		nTRetIR   += (cAliasTMP)->FE_RETENC  
		nTGBasIR  += (cAliasTMP)->FE_VALIMP  
		nTGRetIR  += (cAliasTMP)->FE_RETENC   
		nMontoRep += (cAliasTMP)->FE_RETENC  
	EndIf
        
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera linha detalhe para montagem do arquivo magnetico ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	cRUC      := StrTran(AllTrim((cAliasTMP)->A2_CGC),"-","")
	cMascNF   := Iif(lForExt .or. (cAliasTMP)->F1_EMISSAO < CTOD("01/01/2008"),"@!",Iif(TamSX3("FE_NFISCAL")[1]==7,"@R ###-###-#","@R ###-###-#######"))
	cMascCert := Iif(lForExt .or. (cAliasTMP)->FE_EMISSAO < CTOD("01/01/2008") ,"@!","@R ###-###-#######")   
	cLinArq   := "2"+cSep+Left(cRUC,Len(cRUC)-1)+cSep+Right(cRUC,1)+cSep+(cAliasTMP)->A2_NOME+cSep+"1"+cSep+DTOC((cAliasTMP)->F1_EMISSAO)+cSep
	cLinArq   += Transform(StrTran((cAliasTMP)->FE_NFISCAL,"-",""),cMascNF)+cSep+Transform(StrTran((cAliasTMP)->FE_NROTES,"-",""),cMascCert)+cSep
	cLinArq   += DTOC((cAliasTMP)->FE_EMISSAO)+cSep+Str(Int(nBaseIR),20)+cSep+Str(Int(nBaseIVA),20)+cSep+Str(Int(nRetIVA),20)+cSep
	cLinArq   += Str(Int(nRetIR),20)+cSep+(cAliasTMP)->F1_NUMTIM+chr(13)+chr(10)

	aAdd(aArqTXT[Len(aArqTXT)],cLinArq)

	(cAliasTMP)->(DbSkip())

	If (cAliasTMP)->(Eof()) .or. (nQtdLin == nMaxLinArq)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Gera linha de cabecalho para montagem do arquivo magnetico ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cRUCAgenInf := StrTran(AllTrim(SM0->M0_CGC),"-","")
		cDVAgenInf  := Right(cRUCAgenInf,1)				   		// Digito verificador do RUC Agente de Informacao
		cRUCAgenInf := Left(cRUCAgenInf,Len(cRUCAgenInf)-1)		// RUC Agente de Informacao	
		cLinArq     := "1"+cSep+Left(DTOS(MV_PAR03),6)+cSep+"1"+cSep+"931"+cSep+"231"+cSep+cRUCAgenInf+cSep+cDVAgenInf+cSep+cNomAgenInf+cSep
		cLinArq     += +cRUCRepLeg+cSep+cDVRepLeg+cSep+cNomRepLeg+cSep+AllTrim(Str(nQtdLin-1,10))+cSep+AllTrim(Str(nMontoRep,20))+cSep+"2"
		cLinArq     += chr(13)+chr(10)
	
		aArqTXT[Len(aArqTXT)][1] := cLinArq

		If (nQtdLin == nMaxLinArq) 
			
			aAdd(aArqTxt,Array(1))
			
			nQtdLin   := 1
			nMontoRep := 0
			
		EndIf
		
	EndIf
	
	IncRegua()

	@ nLin,111 PSAY nBaseIR  Picture Tm(FE_VALIMP,TamSX3("FE_VALIMP" )[1],0)
	@ nLin,131 PSAY nRetIR   Picture Tm(FE_RETENC,TamSX3("FE_RETENC")[1],0)
	@ nLin,148 PSAY nBaseIVA Picture Tm(FE_VALIMP,TamSX3("FE_VALIMP")[1],0)
	@ nLin,168 PSAY nRetIVA  Picture Tm(FE_RETENC,TamSX3("FE_RETENC")[1],0)

	nBaseIVA := 0
	nBaseIR  := 0
	nRetIVA  := 0
	nRetIR   := 0
	nLin++

EndDo

If nLin <> 80

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprime os valores totais do Livro ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nLin++
	@ nLin,000 PSAY Replicate("-",220)
	nLin++

	If m_Pag > (MV_PAR07+1)

		@ nLin,008 PSAY STR0016+"  -----------> "	//"Totales de la Página"
		@ nLin,110 PSAY nTBasIR   Picture Tm(FE_VALIMP,TamSX3("FE_VALIMP")[1],0)
		@ nLin,130 PSAY nTRetIR   Picture Tm(FE_RETENC,TamSX3("FE_RETENC")[1],0)
		@ nLin,147 PSAY nTBasIVA  Picture Tm(FE_VALIMP,TamSX3("FE_VALIMP")[1],0)
		@ nLin,167 PSAY nTRetIVA  Picture Tm(FE_RETENC,TamSX3("FE_RETENC")[1],0)
		nLin +=2                                                       
	
	EndIf
		
	@ nLin,008 PSAY STR0015+"    ------------> "	// "Totales generales"
	@ nLin,110 PSAY nTGBasIR  Picture Tm(FE_VALIMP,TamSX3("FE_VALIMP")[1],0)
	@ nLin,130 PSAY nTGRetIR  Picture Tm(FE_RETENC,TamSX3("FE_RETENC")[1],0)
	@ nLin,147 PSAY nTGBasIVA Picture Tm(FE_VALIMP,TamSX3("FE_VALIMP")[1],0)
	@ nLin,167 PSAY nTGRetIVA Picture Tm(FE_RETENC,TamSX3("FE_RETENC")[1],0)

	lRet :=.T.
	
EndIf

SET DEVICE TO SCREEN

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chama gerenciador de impressao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao     ³ GeraArq  ³ Autor ³Marco Aurelio - Mano ³ Data ³ 27.10.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao  ³ Gera o arquivo magnetico do Livro de Retencoes             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³                                                            ³±±
±±³            ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno    ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³ Paraguai                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GeraArq()
Local cArq    := ""		// Nome do arquivo
Local nHdl    := 0		// Handle do arquivo criado
Local nInd    := 0		// Indexador de laco For/Next
Local nInd2   := 0		// Indexador de laco For/Next
Local nPosArq := 0		// Auxiliar para busca de texto
Local lRet    := .T.    // Conteudo de retorno
Local cMsg    := ""		// Mensagem de alerta de inconsistencia

If Aviso(STR0011+" - FISR501",STR0012,{STR0013,STR0014}) == 1	//"Geração de Arquivo"##"Confirma geração do arquivo?"##"Sim"##"Não"

	If Empty(MV_PAR09)
		cMsg := STR0010	// "Nome do arquivo deve ser informado nos parâmetros."
	Else

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Gera arquivo magnetico ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nInd:=1 To Len(aArqTXT)

			cArq    := AllTrim(MV_PAR09)	
			nPosArq := At(".",cArq)
			cArq    := AllTrim(mv_par10)+Left(cArq,Iif(nPosArq>0,nPosArq-1,Len(cArq)))+Iif(Len(aArqTXT)>1,"_"+StrZero(nInd,3),"")+".txt"
			nHdl    := FCREATE(cArq)
			
			If nHdl <= 0
				cMsg := STR0009+' "'+cArq+'"'	// "Falha ao tentar criar o arquivo"
			Else
	
				For nInd2:=1 To Len(aArqTXT[nInd])
					FWRITE(nHdl,aArqTXT[nInd][nInd2])
				Next
				
				FCLOSE(nHdl)
	
			EndIf
			
		Next

	EndIf

EndIf

If !Empty(cMsg)
	Aviso(STR0008,cMsg)	// "Atenção"			
	lRet := .f.
EndIf

Return lRet
