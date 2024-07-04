#INCLUDE "Protheus.Ch"
#INCLUDE "MatrBol3.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMATRBOL3  บAutor  ณMarcello Gabriel    บFecha ณ 11/12/2008  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImpressao dos livros de compras e vendas para demonstracao  บฑฑ
ฑฑบ          ณdos dados gerados para os arquivos magneticos (DaVinci)     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Bolivia                                                    บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณProgramador ณData    ณ BOPS     ณ Motivo da Alteracao                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณJonathan Glzณ06/07/15ณPCREQ-4256ณSe elimina la funcion AjustaSX1() la  ณฑฑ
ฑฑณ            ณ        ณ          ณhace modificacion a SX1 por motivo de ณฑฑ
ฑฑณ            ณ        ณ          ณadecuacion a fuentes a nuevas estruc- ณฑฑ
ฑฑณ            ณ        ณ          ณturas SX para Version 12.             ณฑฑ
ฑฑณAlf. Medranoณ09/11/15ณPCREQ-4263ณ se realiza merge 12.1.8              ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function MatrBol3()
Local cPerg		:= "MTRBO3"
Local cTitulo	:= STR0020 + " " + STR0021 + "/" + STR0022
Local cDescr1	:= STR0030
Local cNomeProg	:= "MATRBOL3" 
Local aArea		:= {}			

Private cAliasLCV	:= "LCV"
Private cTam		:= "G"
Private wnRel		:= ""
Private aReturn		:= {"Zebrado", 1,"Administracao", 2, 2, 1, "", 1}
Private lEnd		:= .F.
Private nLastKey	:= 0
Private m_pag		:= 1

aArea := GetArea()
Pergunte(cPerg,.F.)

wnRel := SetPrint("",cNomeProg,cPerg,cTitulo,cDescr1,,,.F.,,.T.,cTam,,.T.)

If !(nLastKey == 27)

    SetDefault(aReturn,cAliasLCV)

    If !(nLastKey == 27)

        If BOL3Periodo() 
            RptStatus({|lEnd| BOL3Impr(@lEnd)},cTitulo)
        EndIf
		  
    Endif
	
Endif


RestArea(aArea)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณBOL3Impr  บAutor  ณMarcello Gabrriel   บFecha ณ 22/12/2008  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime o livro escolhido                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MatrBol3 - Boliivia                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function BOL3Impr(lEnd)
Local nLin		:= 0
Local nPag		:= 0
Local nAltPag	:= 0
Local nLarPag	:= 0
Local nCpo		:= 0
Local nPos		:= 0
Local nEspTot	:= 0
Local cTitulo	:= ""
Local cTit		:= ""
Local cCpoCol    := ""
Local aTitulo	:= {}
Local aDados	:= {}
Local xConteudo := ""
Local cFilIni   := MV_PAR06
Local cFilFim   := MV_PAR07

Private aCposImp	:= {}
Private aTitDet		:= {}
Private aCab		:= {}
Private cLinDet		:= ""
Private nLinTit		:= 0
Private nTotFat		:= 0
Private nTotExp		:= 0
Private nTotTxz     := 0
Private nTotIse		:= 0
Private nTotBas		:= 0
Private nTotIVA		:= 0
Private nTotFtOri  := 0
Private nSubTot  := 0
Private nDescont  := 0

If Empty(cFilIni) .and. Empty(cFilFim)
	cFilIni	:= xFilial("SF3")
	cFilFim	:= xFilial("SF3")
EndIf

/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณExecuta a rotina DaVinci() para geracao das informacoes ณ
ณfiscais                                                 ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
If MV_PAR03 == 1 // Compras

    MsgRun(STR0002,STR0001,{|| DaVinci("C",cFilIni,cFilFim)}) //"Preparando as informacoes para o livro de compras"###"Livros fiscais"
	/*  
    Campos do detalhe: {nome do campos, tamanho para impressao, mascara, tipo, cabecalho} */
    Aadd(aCposImp,{"NUMSEQ" ,06,"","C",STR0036})                //"No"
    Aadd(aCposImp,{"EMISSAO",10,"","D",STR0055})                //"Data da Fatura ou DUE"  
    Aadd(aCposImp,{"NIT",13,"","C",STR0004})							//"NIT DO FORNECEDOR"
    Aadd(aCposImp,{"RAZSOC",25,"","C",STR0023})						//"Nome ou Razใo Social"   
    Aadd(aCposImp,{"NFISCAL",15,"","C",STR0056})						//"No DA FATURA"
    Aadd(aCposImp,{"POLIZA",16,"","C",STR0007})						//"No de DUE"
    Aadd(aCposImp,{"NUMAUT",15,"","C",STR0008})						//"Numero DE AUTORIZACAO"  
    Aadd(aCposImp,{"VALCONT",12,"@E 9,999,999.99","N",STR0057})	//"VALOR TOTAL DA COMPRA"
    Aadd(aCposImp,{"EXENTAS",12,"@E 9,999,999.99","N",STR0058})	//"VALOR NAO SUJEITO A CREDITO FISCAL"
    Aadd(aCposImp,{"SUBTOT",12,"@E 9,999,999.99","N",STR0059})   //"SUBTOTAL"
    Aadd(aCposImp,{"DESCONT",14,"@E 9,999,999.99","N",STR0060})   //"Descontos Bonifica็๕es e Abatimentos Obtidos"  
    Aadd(aCposImp,{"BASEIMP",12,"@E 9,999,999.99","N",STR0014})	//"Valor Base para Cr้dito Fiscal" 
    Aadd(aCposImp,{"VALIMP",12,"@E 9,999,999.99","N",STR0013})	   //"Credito Fiscal"    
    Aadd(aCposImp,{"CODCTR",17,"","C",STR0015})						//"CODIGO DE CONTROLE"
    Aadd(aCposImp,{"TIPONF",7,"","C",STR0003})                  //"TIPO DE FATURA"

ElseIf MV_PAR03 == 2  // Vendas

    MsgRun(STR0016,STR0001,{|| DaVinci("V",cFilIni,cFilFim)}) //"Preparando as informacoes para o livro de vendas"###"Livros fiscais"
	/*  
	Campos do detalhe: {nome do campos, tamanho para impressao, mascara, tipo, cabecalho} */
    Aadd(aCposImp,{"NUMSEQ" ,06,"","C",STR0036})                //"No"
    Aadd(aCposImp,{"EMISSAO",10,"","D",STR0009})                //"DATA FATURA"(FECHA FACTURA)
    Aadd(aCposImp,{"NFISCAL",15,"","C",STR0006})                //"No DE FATURA"(No DE FACTURA)
    Aadd(aCposImp,{"NUMAUT",15,"","C",STR0008})                 //"NUMERO DE AUTORIZACAO"(No DE AUTORIZACION)
    Aadd(aCposImp,{"STATUSNF",9,"","C",STR0019})                //"ESTADO"
    Aadd(aCposImp,{"NIT",13,"","C",STR0040})                    //"NIT/CI CLIENTE" 
    Aadd(aCposImp,{"RAZSOC",25,"","C",STR0005})					   //"NOME OU RAZAO SOCIAL"(NOMBRE O RAZON SOCIAL)
    Aadd(aCposImp,{"VALCONT",12,"@E 9,999,999.99","N",STR0010})   //"VALOR TOTAL DE VENDA"(IMPORTE TOTAL DE VENTA)
    Aadd(aCposImp,{"EXENTAS",12,"@E 9,999,999.99","N",STR0011})   //"VALOR ICE/ IEHD/ TAXAS"(IMPORTE ICE/ IEHD/ TASAS)
    Aadd(aCposImp,{"EXPORT",15,"@E 9,999,999.99","N",STR0061})    //"EXPORTACOES E OPERACOES ISENTAS"(EXPORTACIONES Y OPERACIONES EXENTAS)
    Aadd(aCposImp,{"TAXAZERO",12,"@E 9,999,999.99","N",STR0012})   //"VENDAS GRAVADAS A TAXA ZERO"(VENTAS GRAVADAS A TASA CERO)
    Aadd(aCposImp,{"SUBTOT",12,"@E 9,999,999.99","N",STR0059})    //"SUBTOTAL"
    Aadd(aCposImp,{"DESCONT",14,"@E 9,999,999.99","N",STR0062})   //"DESCONTOS BONIFICACOES E ABATIMENTOS CONCEDIDOS"(DESCUENTOS BONIFICACIONES Y REBAJAS OTORGADAS)
    Aadd(aCposImp,{"BASEIMP",12,"@E 9,999,999.99","N",STR0017})   //"VALOR BASE PARA DEBITO FISCAL"(IMPORTE BASE PARA DEBITO FISCAL)
    Aadd(aCposImp,{"VALIMP",12,"@E 9,999,999.99","N",STR0018})    //"DEBITO FISCAL"(DEBITO FISCAL)
    Aadd(aCposImp,{"CODCTR",14,"","C",STR0015})						//"CODIGO DE CONTROLE"(CODIGO DE CONTROL)

Else //Compras Deb/Cre e ou Ventas Deb/Cre

    MsgRun(STR0016,STR0001,{|| DaVinci(Iif(MV_PAR03==3,"CDC","VDC"),cFilIni,cFilFim)}) //"Preparando as informacoes para o livro de vendas"###"Livros fiscais"
    /*  
    Campos do detalhe: {nome do campos, tamanho para impressao, mascara, tipo, cabecalho} */

    Aadd(aCposImp,{"NUMSEQ"  ,06,"","C",STR0036})                   // "No"
    Aadd(aCposImp,{"EMISSAO" ,10,"","D",STR0037})                   // "Data Nota de Cr้dito/D้bito"   
    Aadd(aCposImp,{"NFISCAL" ,15,"","C",STR0038})                   // "No Nota de Cr้dito - D้bito"
    Aadd(aCposImp,{"NUMAUT"  ,15,"","C",STR0039})                   // "No DE AUTORIZACAO"
    
    If MV_PAR03==3
        Aadd(aCposImp,{"STATUSNF",06,"","C",STR0019})                   // "ESTADO"
    EndIf        

    Aadd(aCposImp,{"NIT"     ,13,"","C",Iif(MV_PAR03==3,STR0040,STR0052)})      // "NIT/CI Cliente"##"NIT Provedor"
    Aadd(aCposImp,{"RAZSOC"  ,25,"","C",Iif(MV_PAR03==3,STR0041,STR0053)})      // "Nombre ou Razใo Social Cliente"##"Nombre ou Razใo Social Provedor" 
    Aadd(aCposImp,{"VALCONT" ,12,"@E 9,999,999.99","N",STR0042+" "+Iif(MV_PAR03==3,STR0050,STR0051)})      // "Valor total da Devolu็ใo ou Rescisใo"##"Recebida"##"Efetuada"    
    Aadd(aCposImp,{"VALIMP" ,12,"@E 9,999,999.99","N",Iif(MV_PAR03==3,STR0043,STR0054)})       // "Cr้dito Fiscal"##"Debito Fiscal"
    Aadd(aCposImp,{"CODCTR",17,"","C",STR0044})                     // "C๓digo de Controle da Nota de Cr้dito - D้bito"
    Aadd(aCposImp,{"DTNFORI",10,"","D",STR0045})                    // "Data Fatura Original"
    Aadd(aCposImp,{"NFORI",15,"","C",STR0046})                      // "Nบ Fatura Original"
    Aadd(aCposImp,{"AUTNFORI",15,"","C",STR0047})                    // "Nบ de Autoriza็ใo Fatura Original"
    Aadd(aCposImp,{"VALNFORI",12,"@E 9,999,999.99","N",STR0048})      // "Valor Total Fatura Original"


Endif
/*
cria a linha de detalhe com a distribuicao dos campos para uso da funcao FmtLin() */
For nCpo := 1 To Len(aCposImp)
	If nCpo > 1
		cLinDet += " "
	Endif
	cLinDet += Replicate("#",aCposImp[nCpo,2])
Next
/*
Cria array com os cabecalhos dos campos, distribuindo as palavras ("quebrando o titulo") em linhas para que o titulo do campo caiba no espaco
que foi reservado para esse campo*/
(cAliasLCV)->(DbGoTop())
nLarPag := Len(cLinDet)
nAltPag := 62
nLinTit := 0
aTitDet := {}
For nCpo := 1 To Len(aCposImp)
	cTitulo := Upper(AllTrim(aCposImp[nCpo,5]))
	aTitulo := {}
	While !Empty(cTitulo)
		cTit := AllTrim(Substr(cTitulo,1,aCposImp[nCpo,2]))
		nPos := aCposImp[nCpo,2]
		If !Empty(Substr(cTitulo,aCposImp[nCpo,2] + 1,1))
			While nPos > 0 .And. !Empty(Substr(cTitulo,nPos,1))
				nPos--
			Enddo
			If nPos > 0
				cTit := Substr(cTitulo,1,nPos - 1)
			Else
				nPos := aCposImp[nCpo,2]
			Endif
		Endif
		//Os campos numericos sao "jogados" para a direita
		If aCposImp[nCpo,4] == "N"
			cTit := PadL(cTit,aCposImp[nCpo,2])
		Endif
		Aadd(aTitulo,cTit)
		cTitulo := LTrim(Substr(cTitulo,nPos + 1))
	Enddo
	nLinTit := Max(nLinTit,Len(aTitulo))
	Aadd(aTitDet,aTitulo)
Next
//
nTotFat	:= 0
nTotIC	   := 0
nTotIse	:= 0
nTotBas	:= 0
nTotIVA   := 0
nTotFtOri := 0
nTotExp   := 0
nTotTxz   := 0

SetRegua((cAliasLCV)->(RecCount()))
While !((cAliasLCV)->(Eof())) .And. !lEnd
	/*
	Impressao do cabecalho do livro */
	nPag++
	nLin := BOL3Cabec(nPag)
	/*
	Impressao do detalhe do livro */
	nPos := 0
	While !((cAliasLCV)->(Eof())) .And. nLin < nAltPag .And. !lEnd
		aDados := {}
		For nCpo := 1 To Len(aCposImp)
		
            cCpoCol   := aCposImp[nCpo,1]
            xConteudo := Iif(MV_PAR03>2 .and. cCpoCol=="VALCONT" .and. !Empty((cAliasLCV)->BASEIMP),(cAliasLCV)->BASEIMP,(cAliasLCV)->(FieldGet(FieldPos(aCposImp[nCpo,1]))))

			If Empty(aCposImp[nCpo,3])
				Aadd(aDados,PadR(Iif(AllTrim((cAliasLCV)->STATUSNF)<>"V" .and. cCpoCol$"VALCONT|VALIMP",0,xConteudo),aCposImp[nCpo,2]))
			Else
				Aadd(aDados,Transform(Iif(AllTrim((cAliasLCV)->STATUSNF)<>"V" .and. cCpoCol$"VALCONT|VALIMP",0,xConteudo),aCposImp[nCpo,3]))
			Endif
			
		Next
		
		FmtLin(aDados,cLinDet,,,@nLin)
		If AllTrim((cAliasLCV)->STATUSNF) == "V"
			nTotFat += Iif(MV_PAR03>2 .and. !Empty((cAliasLCV)->BASEIMP),(cAliasLCV)->BASEIMP,(cAliasLCV)->VALCONT)

        If MV_PAR03 == 2             
            nTotExp += (cAliasLCV)->EXPORT
            nTotTxz += (cAliasLCV)->TAXAZERO
        EndIf			

			nTotIse += (cAliasLCV)->EXENTAS
			nTotBas += (cAliasLCV)->BASEIMP
			nTotIVA += (cAliasLCV)->VALIMP
         nTotFtOri+= (cAliasLCV)->VALNFORI
         nSubTot  += (cAliasLCV)->SUBTOT
         nDescont += (cAliasLCV)->DESCONT
			
		Endif
		If lEnd
			(cAliasLCV)->(DbGoBottom())
		Endif
		(cAliasLCV)->(DbSkip())
		IncRegua()
	Enddo
	If (cAliasLCV)->(Eof()) .And. !lEnd
		If nTotFat <> 0
	  		BOL3Totais()
		Endif
	Endif
Enddo
If Select(cAliasLCV) > 0
	DbSelectArea(cAliasLCV)
	DbCloseArea()
Endif
If lEnd
	cTit := Upper(AllTrim(STR0032))
	nPos := (nLarPag - Len(cTit)) / 2
	@PRow() + 2,nPos PSay cTit
Endif
//	
If aReturn[5]==1
   dbCommitAll()
   Set Printer To
   OurSpool(wnRel)
Endif
MS_FLUSH() 
Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMATRBOL3  บAutor  ณMicrosiga           บFecha ณ 29/12/2008  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprimi a somatoria do livro fiscal e o nome do responsavel บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MATRBOL3                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function BOL3Totais()
Local nCpo		:= 0
Local nLin		:= 0
Local nLarPag	:= 0
Local aDados	:= {}

nLin := PRow() + 1
nLarPag := Len(cLinDet)
/*
Impressao dos totais */
@nLin,0 PSay Replicate("_",nLArPag)
nLin++
For nCpo := 1 To Len(aCposImp)
	Aadd(aDados,Space(aCposImp[nCpo,2]))
Next
//titulo
nCpo := Ascan(aCposImp,{|cpo| cpo[1] == "NUMAUT"})
aDados[nCpo] := STR0031		//"Total"
//total da fatura
nCpo := Ascan(aCposImp,{|cpo| cpo[1] == "VALCONT"})
aDados[nCpo] := Transform(nTotFat,aCposImp[nCpo,3])

If MV_PAR03<3 // Livro de Compras e ou Livro de Vendas
    
            
    //Isentos
    
    nCpo := Ascan(aCposImp,{|cpo| cpo[1] == "EXENTAS"})
    aDados[nCpo] := Transform(nTotIse,aCposImp[nCpo,3])

    If MV_PAR03 == 2

        //Exportacoes e Operacoes isentas
        
        nCpo := Ascan(aCposImp,{|cpo| cpo[1] == "EXPORT"})
        aDados[nCpo] := Transform(nTotExp,aCposImp[nCpo,3])

        //Taxa Zero
        
        nCpo := Ascan(aCposImp,{|cpo| cpo[1] == "TAXAZERO"})
        aDados[nCpo] := Transform(nTotTxz,aCposImp[nCpo,3])


    EndIf

    //Subtotal
    
    nCpo := Ascan(aCposImp,{|cpo| cpo[1] == "SUBTOT"})
    aDados[nCpo] := Transform(nSubTot,aCposImp[nCpo,3])

    //Desconto
    
    nCpo := Ascan(aCposImp,{|cpo| cpo[1] == "DESCONT"})
    aDados[nCpo] := Transform(nDescont,aCposImp[nCpo,3])
    
    //Base
    
    nCpo := Ascan(aCposImp,{|cpo| cpo[1] == "BASEIMP"})
    aDados[nCpo] := Transform(nTotBas,aCposImp[nCpo,3])

EndIf

//Imposto
nCpo := Ascan(aCposImp,{|cpo| cpo[1] == "VALIMP"})
aDados[nCpo] := Transform(nTotIVA,aCposImp[nCpo,3])

If MV_PAR03>2

    // Total Fatura Original
    nCpo := Ascan(aCposImp,{|cpo| cpo[1] == "VALNFORI"})
    aDados[nCpo] := Transform(nTotFtOri,aCposImp[nCpo,3])

EndIf    


//
FmtLin(aDados,cLinDet,,,@nLin)
/*
Impressao do nome e CI do responsavel */
nLin++
MV_PAR04 := Upper(AllTrim(MV_PAR04))
MV_PAR05 := Upper(AllTrim(MV_PAR05))
@nLin,00 Psay PadC(MV_PAR04,20)
@nLin,40 Psay PadC(MV_PAR05,50)
nLin++
@nLin,00 Psay Replicate("_",20)
@nLin,40 Psay Replicate("_",50)
nLin++
@nLin,00 PSay PadC(Upper(Alltrim("CI")),20)
@nLin,40 PSay PadC(Upper(AllTrim(STR0029)),50)  //"NOME COMPLETO DO RESPONSAVEL"
Return()

/*/






/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunao    ณBOL3Periodo  ณ Autor ณ Marco Aurelio - Mano    ณ Data ณ22/12/14  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao ณValida periodo informado nos parametros                          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณBOL3Periodo()                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ                                                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณLivros - Bolivia                                                 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/          
Function BOL3Periodo()
Local cMsg    := ""
Local lRet    := .t.

If Substring(DtoS(MV_PAR01),1,6) <> Substring(DtoS(MV_PAR02),1,6)
   cMsg := STR0049 //##"Somente poderแ ser informado um perํodo de datas dentro do mesmo M๊s/Ano."  
EndIf

If !Empty(cMsg)
    
    Aviso("Aten็ใo",cMsg,{"OK"})
    
    lRet := .f.
    
EndIf

Return lRet
    

    
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณBOL3CABEC บAutor  ณMarcello Gabriel    บFecha ณ23/12/2008   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime o cabecalho do livro fiscal                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MATRBOL3 - Bolivia                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function BOL3Cabec(nPag)
Local cTitLivro := ""
Local nLin      := 0
Local nX        := 0
Local nY        := 0
Local nLarPag   := 0
Local nColTit   := 0
Local aDados    := {}

nLarPag := Len(cLinDet)
/*
Titulo do livro */
cTitLivro := "IVA - "+STR0020+" "+If(MV_PAR03==1,STR0021,If(MV_PAR03==2,STR0022,If(MV_PAR03==3,STR0021+" "+STR0033,STR0022+" "+STR0033)))   //"LIVRO DE "###"COMPRAS"###"VENDAS"###"Notas de Cr้dito/D้bito"

nColTit := 0
nLin := 0
nColTit := (nLarPag - Len(cTitLivro)) / 2
@nLin,nColTit PSay cTitLivro
nLin++

@nLin,0 PSay Replicate("_",nLarPag)
nLin++

@nLin,0 PSay STR0026+": "+STR0034+": "+Substring(DtoS(MV_PAR01),1,4)+"      "+STR0035+":  "+Substring(DtoS(MV_PAR01),5,2) //"Periodo"###"Ano"###"Mes"
nLin++

@nLin,0 PSay STR0023+": "+AllTrim(SM0->M0_NOMECOM)+Space(10)+"NIT: " + AllTrim(SM0->M0_CGC)+Space(10)+STR0024 + ": " + cFilAnt //"Nome ou Razao social"###"Filial"
nLin++

@nLin,0 PSay Replicate("_",nLarPag)
nLin++

/*
Impressao do cabecalho das colunas */
For nY := 1 To nLinTit
    aDados := {}
    For nX := 1 To Len(aTitDet)
        Aadd(aDados,Space(aCposImp[nX,2]))
        If nY <= Len(aTitDet[nX])
            Adados[Len(aDados)] := aTitDet[nX,nY]
        Endif
    Next
    FmtLin(aDados,cLinDet,,,@nLin)
Next
@nLin,0 PSay Replicate("_",nLArPag)
/**/
nLin++
Return(nLin)
    
