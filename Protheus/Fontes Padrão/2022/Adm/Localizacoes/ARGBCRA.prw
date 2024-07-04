#INCLUDE 'protheus.ch'
#INCLUDE "rwmake.ch"   
#INCLUDE "ARGBCRA.ch"  

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ ARGBCRA  ³ Autor ³ Marivaldo                  ³ Data ³ 01/03/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa de impressao do relatorio das faturas pedentes de      ³±±
±±           ³ de pagamentos de fornecedores do exterior                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RDMAKE PADRAO                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ATUAIZACOES SOFRIDAS                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³   BOPS   ³           Motivo da Alteracao             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marco A. Glz³30/03/17³ MMI-4535 ³Se replica llamado (TTNRIZ - V11.8),       ³±±
±±³            ³        ³          ³Pasivos Externos - Reemplazo del campo     ³±±
±±³            ³        ³          ³F1_HWAB por F1_NUMDES. (ARG)               ³±±
±±³L. Samaniego³05/01/17³DMICNS    ³Replica del issue DMIMIX-290. Argentina    ³±±
±±³            ³        ³ -1200    ³Tratamiento para manejadores Oracle.       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function ARGBCRA()

	Local cDesc1	:= STR0001 //"Este informe imprimira los precios Passivos Externos"
	Local cDesc2	:= ""
	Local cDesc3	:= ""
	Local cPerg		:= "ARGBCRA"

	Local lContinua	:= .T.
	Local aOrd		:= {}                                                       
	Local aAreaAtu	:= GetArea()  

	Private lAbortPrint	:= .F.
	Private Tamanho		:= "G"
	Private NomeProg	:= "ARGBCRA"
	Private nTipo		:= 0
	Private m_pag		:= 1
	Private aReturn		:= { STR0013, 1, STR0012, 2, 2, 1, "", 1} //"A Rayas" - "Administración"
	Private nLastKey	:= 0
	Private wnrel		:= "ARGBCRA" 
	Private cString		:= " " 
	Private Titulo		:= STR0007 
	Private nLin		:= 80
	Private aDatos		:= {}
	Private Cabec1		:= STR0002 
	Private Cabec2		:= STR0003 
	Private Cabec3		:= STR0004 
	Private Cabec4		:= STR0005   
	Private Cabec5		:= ""
	Private cCam1		:= Space(100)
	Private cNomeArq	:= Space(100)
	Private aInfo		:= {}
	Private aInfo2		:= {} 
	Private aCancel		:= {} 
	Private aSldPA		:= {} 
	Private lTer		:= .F.

	Pergunte(cPerg, .T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                         
	wnrel  := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RptStatus({|| RunReport(Cabec1,Cabec2,Cabec3,Cabec4,Cabec5,Titulo,nLin) },Titulo)
	RestArea(aAreaAtu)
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³RunReport ºTOTVS  ³Marivaldo 		     º Data ³  01/03/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao que monta o layout de impressão                     º±±
±±º          ³ conforme os parametros informados                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Funcao Principal                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RunReport(Cabec1,Cabec2,Cabec3,Cabec4,Cabec5,Titulo,nLin)
	
	Local cAliasQry	:= GetNextAlias()
	Local cChavNF	:= '' 
	local nFilial	:= ''
	Local cFornece	:= ''
	Local cLoja		:= ''
	Local nDoc		:= ''                                                                      
	Local nSerie	:= ''
	Local cEspecie	:= ''
	Local aDatos	:= {} 
	Local lFin		:= .F.
	Local cDocAnt	:= ''
	Local nReg		:= 0

	cQuery := "SELECT F1_FILIAL, F1_FORNECE, F1_LOJA, F1_VALBRUT, F1_DESP, F1_DOC, F1_SERIE, F1_ESPECIE, F1_TPVENT, A2_COD, A2_NOME, F1_ESPECIE, D1_EMISSAO, F1_DTLANC, B1_CONTA, CT1_DESC01, D1_CONHEC," 
	cQuery += " D1_QUANT,  D1_VUNIT, D1_TOTAL, F1_TXMOEDA, F1_MOEDA, F1_NUMDES, F1_FECDSE, E2_TIPO,E2_VENCREA, E2_PARCELA ,E2_VALOR,E2_SALDO"
	cQuery += " FROM "        
	cQuery += RetSqlName("SF1") + " SF1 " 
	cQuery += " LEFT JOIN "+RetSqlName("SA2")+ " ON A2_COD = F1_FORNECE AND A2_LOJA = F1_LOJA "
	cQuery += " LEFT JOIN "+RetSqlName("SD1")+ " ON D1_FILIAL = F1_FILIAL AND D1_FORNECE = F1_FORNECE AND D1_LOJA    = F1_LOJA AND D1_DOC = F1_DOC AND D1_SERIE = F1_SERIE "
	cQuery += " LEFT JOIN "+RetSqlName("SB5")+ " ON B5_FILIAL = F1_FILIAL AND B5_COD = D1_COD "
	cQuery += " LEFT JOIN "+RetSqlName("SB1")+ " ON B1_FILIAL = D1_FILIAL AND B1_COD = D1_COD "
	cQuery += " LEFT JOIN "+RetSqlName("CT1")+ " ON CT1_FILIAL = B1_FILIAL AND CT1_CONTA = B1_CONTA " 
	cQuery += " LEFT JOIN "+RetSqlName("SE2")+ " ON E2_FILIAL = F1_FILIAL AND E2_PREFIXO = F1_SERIE AND E2_NUM = F1_DOC "
	cQuery += " WHERE A2_TIPO = 'E' " 
	cQuery += "   AND  F1_FILIAL = '"+ xFilial("SF1")+"'"
	cQuery += "   AND (F1_ESPECIE = 'NF' OR F1_ESPECIE = 'NDP' OR F1_ESPECIE = 'NCI' OR F1_ESPECIE = 'NCP' OR F1_ESPECIE = 'NDI') "
	If Upper(Alltrim(TcGetDB()))== "ORACLE"
		cQuery += "   AND F1_DTLANC BETWEEN '"+Dtos(MV_PAR01)+"' AND '"+Dtos(MV_PAR02) +"'"
	Else
		cQuery += "   AND F1_DTLANC BETWEEN "+Dtos(MV_PAR01)+" AND "+Dtos(MV_PAR02)
	EndIf
	cQuery += " ORDER BY 1,2,3,4,5" 
	cQuery := ChangeQuery(cQuery)

	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)
	TcSetField(cAliasQry,"D1_EMISSAO  ","D",TamSX3("D1_EMISSAO")[1],TamSX3("D1_EMISSAO")[2])
	TcSetField(cAliasQry,"F1_DTLANC","D",TamSX3("F1_DTLANC")[1],TamSX3("F1_DTLANC")[2])
	TcSetField(cAliasQry,"D1_QUANT","N",TamSX3("D1_QUANT")[1],TamSX3("D1_QUANT")[2])
	TcSetField(cAliasQry,"D1_VUNIT","N",TamSX3("D1_VUNIT")[1],TamSX3("D1_VUNIT")[2])
	TcSetField(cAliasQry,"D1_TOTAL","N",TamSX3("D1_TOTAL")[1],TamSX3("D1_TOTAL")[2])

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Count to nReg
	SetRegua(nReg) 
	
	(cAliasQry)->(DBGoTop())
	While (cAliasQry)->(!Eof())
		IncRegua()
		If !Empty(cChavNF) .And. cChavNF <> (cAliasQry)->(F1_FILIAL+F1_FORNECE+F1_LOJA)		
			lFin	:= .T.
			aCancel	:= {}
			nLin	:= CanARGBCRA (nLin,nFilial,nSerie,nDoc,cFornece,cEspecie,aDatos,lFin)
			//nLin	:= nLin + 1 
			nLin	:= CancARGBCR (nLin,nFilial,nSerie,nDoc,cFornece,cEspecie,aDatos,lFin)
			//nLin	:= nLin + 1 
			nLin	:= TotARGBCR(nLin,nFilial,nSerie,nDoc,cFornece,cEspecie,aDatos,lFin)	
			If Left(cChavNF,Len((cAliasQry)->(F1_FILIAL+F1_FORNECE))) <> (cAliasQry)->(F1_FILIAL+F1_FORNECE)		
				lFin := .T.		  
			EndIf
		EndIf 

		If nLin > 55 //determina tamanho da linha
			Cabec(Titulo,"","",NomeProg,Tamanho,nTipo)	
			nLin := 5
			@nLin+1,00 PSAY cabec1
			@nLin+1,09 PSAY MV_PAR03
			nLin := nLin + 1                                                                                                 
			@nLin+1,00 PSAY STR0008
			nLin := nLin + 1
			@nLin+1,00 PSAY cabec2		
			nLin := nLin + 1
			@nLin+1,00 PSAY cabec3
			nLin := nLin + 1
			@nLin+1,00 PSAY cabec4
			nLin := nLin + 1
			@nLin+1,00 PSAY STR0008
			nLin := nLin + 2
		Endif

		If cChavNF <> (cAliasQry)->(F1_FILIAL+F1_FORNECE+F1_LOJA+F1_DOC)
			nFilial := (cAliasQry)->F1_FILIAL                                         
			cFornece:= (cAliasQry)->F1_FORNECE
			cLoja	:= (cAliasQry)->F1_LOJA
			nDoc	:= (cAliasQry)->F1_DOC
			nSerie	:= (cAliasQry)->F1_SERIE
			cEspecie:= (cAliasQry)->F1_ESPECIE    
			cTpvent := (cAliasQry)->F1_TPVENT
			cChavNF := (cAliasQry)->(F1_FILIAL+F1_FORNECE+F1_LOJA+F1_DOC)		
		EndIF

		nTaxMoe := Iif(MV_PAR04 == 2,Iif((cAliasQry)->F1_TXMOEDA>0,(cAliasQry)->F1_TXMOEDA,RecMoeda((cAliasQry)->D1_EMISSAO,(cAliasQry)->F1_MOEDA)),RecMoeda(dDataBase,(cAliasQry)->F1_MOEDA))
		dDatMoe := Iif(MV_PAR04 == 1, dDataBase, (cAliasQry)->D1_EMISSAO) 
		nMoeda  := Iif(Empty(MV_PAR03),1,MV_PAR03)	
			
		nPos := aScan(aDatos,{|x| x[1] + x[3] + x[4] == cFornece + cEspecie + nDoc })
		
		AAdd( aDatos,{(cAliasQry)->A2_COD,;
			(cAliasQry)->A2_NOME,;
			(cAliasQry)->F1_ESPECIE,;
			(cAliasQry)->F1_DOC,;
			dtoc((cAliasQry)->D1_EMISSAO),;
			dtoc((cAliasQry)->F1_DTLANC),;
			(cAliasQry)->B1_CONTA,;
			(cAliasQry)->CT1_DESC01,;
			(cAliasQry)->D1_CONHEC,;				  
			(cAliasQry)->D1_QUANT,;
			(cAliasQry)->D1_VUNIT,;
			Str(xMoeda((cAliasQry)->D1_VUNIT,(cAliasQry)->F1_MOEDA,nMoeda,dDatMoe,, nTaxMoe )),;
			(cAliasQry)->D1_TOTAL,;
			xMoeda((cAliasQry)->D1_TOTAL,(cAliasQry)->F1_MOEDA,nMoeda,dDatMoe,, nTaxMoe ),;
			(cAliasQry)->E2_PARCELA,;
			xMoeda((cAliasQry)->F1_VALBRUT,(cAliasQry)->F1_MOEDA,nMoeda,dDatMoe,, nTaxMoe ),;        
			"","","","","","","","","","","","","","","",""})

		If nPos = 0 
		
			@nLin,000 PSay (cAliasQry)->A2_COD                                                                               
			@nLin,010 PSay SubStr((cAliasQry)->A2_NOME,1,20)
			@nLin,040 Psay (cAliasQry)->F1_NUMDES
			@nLin,064 Psay dtoc(StoD((cAliasQry)->F1_FECDSE))  
			@nLin,079 Psay (cAliasQry)->D1_EMISSAO 
			@nLin,089 Psay Transform(xMoeda((cAliasQry)->F1_VALBRUT,(cAliasQry)->F1_MOEDA,nMoeda,dDatMoe,, nTaxMoe )	,"@E 999,999,999,999.99")
			nLin := nLin+1
		EndIf 			       	 
		(cAliasQry)->(dbSkip())
		
	EndDo 

	nPos := aScan(aDatos,{|x| x[1] + x[3] + x[4] == cFornece + cEspecie + nDoc })	 

	If nPos == 0
		MsgAlert(STR0009) //"Archivo vacío." 
		Return
	EndIf

	cDocAnt:= nDoc
	If cDocAnt == aDatos [nPos,4] 
		lFin	:= .T.                                                                                                              
		aCancel	:= {}   	
		nLin	:= CanARGBCRA (nLin,nFilial,nSerie,nDoc,cFornece,cEspecie,aDatos,lFin)
		nLin	:= nLin + 1 
		lFin	:= .T.
		nLin	:= CancARGBCR (nLin,nFilial,nSerie,nDoc,cFornece,cEspecie,aDatos,lFin)
		lFin	:= .T.
		nLin	:= TotARGBCR(nLin,nFilial,nSerie,nDoc,cFornece,cEspecie,aDatos,lFin)	
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio... ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SET DEVICE TO SCREEN
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se impressao em disco, chama o gerenciador de impressao... ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aReturn[5] == 1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif 

	MS_FLUSH()

Return Nil

//=====================
// Monta Cancelamentos
//=====================
Static Function CanARGBCRA(nLin,cFilF1,cSerie,cDoc,cFornece,cEspecie,aDatos,lFin)
	
	Local cabec1
	Local cabec2
	Local cabec3
	Local cabec4
	Local Lindet
	Local cQry		:= GetNextAlias()
	Local nMoeda	:= Iif(Empty(MV_PAR03),1,MV_PAR03)
	Local dDataMoe	:= dDataBase
	Local nTaxMoe 	:= 0
	Local nMoedaSEK:= 0   
	Local cQry2		:= GetNextAlias() 
	Local nSaldo    := SE2->E2_SALDO  
	Local nX	:= 0 
	Local nI    := 0 
	Local nLenaDatos := 0
	Private aInfo := {}
	Private aInfo2 := {} 
	Private aCancel := {} 
	Private aSldPA := {} 

	// Baixas referente a orden de pago                                  
	BEGINSQL Alias cQry
		SELECT 
			SEK.EK_ORDPAGO, SEK.EK_NUM, SEK.EK_VALOR, SEK.EK_TIPODOC, SEK.EK_TIPO,SEK.EK_EMISSAO,
			SEK.EK_MOEDA, SEK.EK_TXMOE02, SEK.EK_TXMOE03, SEK.EK_TXMOE04, SEK.EK_TXMOE05,
			SEK.EK_BANCO, SEK.EK_AGENCIA, SEK.EK_CONTA, SE5.E5_NUMERO, SE5.E5_VALOR, SE5.E5_TIPODOC, SE5.E5_TIPO,
			SE5.E5_DATA, SE5.E5_MOEDA, SE5.E5_TXMOEDA, SE5.E5_BANCO, 
			SE5.E5_AGENCIA, SE5.E5_CONTA, SE5.E5_CLIFOR
		FROM 
			%Table:SEK% SEK, %Table:SE5% SE5
		WHERE 
			(SEK.EK_TIPODOC = %Exp:'CP'% OR SEK.EK_TIPODOC = %Exp:'PA'% OR SEK.EK_TIPO = %Exp:'PA'%) AND 
			SEK.%NotDel% AND SE5.E5_NUMERO = SEK.EK_ORDPAGO AND SE5.E5_CLIFOR = SEK.EK_FORNECE AND 
			SEK.EK_ORDPAGO IN 
			(
			SELECT 
				DISTINCT SE5.E5_ORDREC	
			FROM 
				%Table:SE5% SE5 
			WHERE 
				SE5.E5_FILIAL = %Exp:cFilF1% AND 
				SE5.E5_PREFIXO = %Exp:PadR(cSerie,TamSX3("E5_PREFIXO")[1])% AND 
				SE5.E5_ORDREC <> %Exp:''% AND 
				SE5.E5_DATA <> %Exp:''% AND	 		   
				SEK.EK_EMISSAO <=  %Exp:Dtos(MV_PAR02)% AND	 		    
				SE5.%NotDel%
			)
	EndSQL   

	While !(cQry)->(Eof())
		
		nMoedaSEK := Val((cQry)->EK_MOEDA )
		dDatMoe   := Iif(MV_PAR03 == 1, dDataBase, StoD((cQry)->EK_EMISSAO))
		
		If nMoedaSEK <> 1 .And. (cQry)->&("EK_TXMOE0"+AllTrim((cQry)->EK_MOEDA)) >0
			nTaxMoe:=(cQry)->&("EK_TXMOE0"+AllTrim((cQry)->EK_MOEDA))
		Else
			nTaxMoe:= Iif(MV_PAR03 == 1,Iif(nMoedaSEK > 0,nMoedaSEK,RecMoeda((cQry)->EK_EMISSAO,(cQry)->EK_MOEDA)),RecMoeda(dDatMoe,nMoeda))
		EndIf  
		If (cQry)->EK_TIPODOC $ MVPAGANT .And. (cQry)->EK_TIPO $ MVPAGANT
			aAdd(aSldPA,{AllTrim(STR(nMoeda)),xMoeda((cQry)->EK_VALOR,Val((cQry)->EK_MOEDA),nMoeda,dDatMoe,, nTaxMoe),nTaxMoe,xMoeda((cQry)->EK_VALOR,Val((cQry)->EK_MOEDA),nMoeda,dDatMoe,, nTaxMoe)*nTaxMoe})
			(cQry)->(dbSkip())
			Loop
		Else
			aAdd(aSldPA,{,,,})		
		EndIf

		@nLin,120 PSAY IIf((cQry)->EK_TIPODOC ="CP","OP", "CP")
		@nLin,124 PSAY (cQry)->EK_ORDPAGO
		@nLin,142 PSAY StoD((cQry)->EK_EMISSAO)  
		@nLin,155 PSAY (cQry)->EK_BANCO 
		@nLin,162 PSAY Transform(xMoeda((cQry)->EK_VALOR,Val((cQry)->EK_MOEDA),nMoeda,dDatMoe,, Val((cQry)->EK_MOEDA)),"@E 999,999,999,999.99")

		aAdd(aCancel,{IIf((cQry)->EK_TIPO $ MVPAGANT, "PA  ", "OP  ") + (cQry)->EK_ORDPAGO,;
			dtoc(StoD((cQry)->EK_EMISSAO)),;
			(cQry)->EK_BANCO + " " + Posicione("SA6",1,xFilial("SA6")+(cQry)->(EK_BANCO+EK_AGENCIA+EK_CONTA),"A6_NREDUZ"),;
			Str((xMoeda((cQry)->EK_VALOR,Val((cQry)->EK_MOEDA),nMoeda,dDatMoe,, nTaxMoe))),;
			(nTaxMoe),;
			Str(xMoeda((cQry)->EK_VALOR,Val((cQry)->EK_MOEDA),nMoeda,dDatMoe,, nTaxMoe) * nTaxMoe)})
			
		(cQry)->(dbSkip())

		lTer	:= .F.	
		nPos	:= aScan(aDatos,{|x| x[1] + x[3] + x[4] == cFornece + cEspecie + cDoc })
		nLin	:= nLin + 1
		If nPos > 0  //se encontrou --> x[1] + x[3] + x[4] == cFornece + cEspecie + cDoc
			nLenaDatos := len(aDatos)
			For nI := 1 to len(aCancel)
				For nX := nPos to nLenaDatos
					If  aDatos[nX,1] == aDatos[nPos,1]  .And. aDatos[nX,3] == aDatos[nPos,3]  .And. aDatos[nX,4] == aDatos[nPos,4]  
						If Empty(aDatos[nX,22])//.and. lTer .and. nX=1
							aDatos[nX,22] :=   aCancel[nI,1]
							aDatos[nX,23] :=   aCancel[nI,2]
							aDatos[nX,24] :=   aCancel[nI,3]
							aDatos[nX,25] :=   aCancel[nI,4]
							aDatos[nX,26] :=   aCancel[nI,5]                         
							aDatos[nX,27] :=   aCancel[nI,6]
						Else
							If nPos == nLenaDatos
								lTer := .T.	
								Exit
							Else
								Loop
							End if
						End if	
					Else
						lTer := .T.	
						Exit 
					End if	
				Next
				If lTer
					aAdd(aDatos,{aDatos[nPos,1],;
						aDatos[nPos,2],;
						aDatos[nPos,3],;
						aDatos[nPos,4],;
						aDatos[nPos,5],;
						aDatos[nPos,6],;
						aDatos[nPos,7],;
						aDatos[nPos,8],;
						aDatos[nPos,9],;
						aDatos[nPos,10],;
						aDatos[nPos,11],;
						aDatos[nPos,12],;
						aDatos[nPos,13],;
						aDatos[nPos,14],;
						aDatos[nPos,15],;
						aDatos[nPos,16],;
						aDatos[nPos,17],;
						aDatos[nPos,18],;
						aDatos[nPos,19],;
						aDatos[nPos,20],;
						aDatos[nPos,21],;
						aCancel[nI,1],;
						aCancel[nI,2],;
						aCancel[nI,3],;
						aCancel[nI,4],;
						aCancel[nI,5],;
						aCancel[nI,6],;
						aDatos[nPos,28],;
						aDatos[nPos,29],;
						aDatos[nPos,30],;
						aDatos[nPos,31]})
				Endif
			Next
		EndIf
		
	EndDo

	(cQry)->(DbCloseArea())

	//baixas referente a compensacao
	BEGINSQL Alias cQry2
		SELECT SE5.E5_NUMERO, SE5.E5_VLMOED2,SE5.E5_VALOR, SE5.E5_TIPODOC, SE5.E5_TIPO,
			SE5.E5_DATA, SE5.E5_MOEDA, SE5.E5_TXMOEDA, SE5.E5_BANCO, 
			SE5.E5_AGENCIA, SE5.E5_CONTA 
		FROM 
			%Table:SE5% SE5
		WHERE 
			(SE5.E5_TIPODOC = %Exp:'CP'% OR SE5.E5_TIPODOC = %Exp:'PA'%) AND 
			SE5.%NotDel% AND
			SE5.E5_NUMERO IN 
			(
			SELECT 
				DISTINCT SE2.E2_NUM	
			FROM 
				%Table:SE2% SE2 
			WHERE
				SE2.E2_FORNECE = %Exp:cFornece% AND   
				SE2.E2_FILIAL = %Exp:cFilF1% AND 
				SE2.E2_NUM = %Exp:PadR(cDoc,TamSX3("E2_NUM")[1])% AND 
				SE2.E2_NUM = SE5.E5_NUMERO AND
				SE2.E2_BAIXA <=  %Exp:Dtos(MV_PAR02)% AND
				SE2.%NotDel%
			)
	EndSQL   

	While !(cQry2)->(Eof())

		nMoedaSEK := IIf((cQry2)->E5_MOEDA == "1",1,(cQry2)->&("E5_TXMOEDA"+AllTrim((cQry2)->E5_MOEDA)))
		dDatMoe := Iif(MV_PAR04 == 1, dDataBase, StoD((cQry2)->E5_DATA))
		nTaxMoe := Iif(MV_PAR04 == 2,Iif(nMoedaSE5 > 0,nMoedaSE5,RecMoeda((cQry2)->E5_DATA,(cQry2)->E5_MOEDA)),RecMoeda(dDatMoe,nMoeda))


		@nLin,120 PSAY (cQry2)->E5_TIPODOC 
		@nLin,124 PSAY (cQry2)->E5_NUMERO
		@nLin,142 PSAY StoD((cQry2)->E5_DATA)  
		@nLin,155 PSAY (cQry2)->E5_BANCO 
		@nLin,162 PSAY Transform(xMoeda((cQry2)->E5_VALOR,Val((cQry2)->E5_MOEDA),nMoeda,dDatMoe,, nTaxMoe)*nTaxMoe,"@E 999,999,999,999.99")

		nLin:=nLin+1

		aAdd(aInfo,{(cQry2)->E5_NUMERO,;
			(cQry2)->E5_VLMOED2,;
			(cQry2)->E5_TIPODOC,;
			(cQry2)->E5_TIPO,;
			(cQry2)->E5_DATA,;
			(cQry2)->E5_MOEDA,;
			(cQry2)->E5_TXMOEDA,;
			(cQry2)->E5_BANCO,;
			(cQry2)->E5_AGENCIA,;
			(cQry2)->E5_CONTA,;
			(cQry2)->E5_VALOR})

		(cQry2)->(dbSkip())
	EndDo

	(cQry2)->(DbCloseArea())

	lTer := .F.
	nPos := aScan(aDatos,{|x| x[1] + x[3] + x[4] == cFornece + cEspecie + cDoc })
	If nPos > 0  //se encontrou --> x[1] + x[3] + x[4] == cFornece + cEspecie + cDoc
		nLenaDatos := len(aDatos)
		For nI := 1 to len(aInfo)
			For nX := nPos to nLenaDatos
				If  aDatos[nX,1] == aDatos[nPos,1]  .And. aDatos[nX,3] == aDatos[nPos,3]  .And. aDatos[nX,4] == aDatos[nPos,4]  
					If Empty(aDatos[nX,22])// .and. nX=1 //.and. (aInfo[nI,3]) = "CP"
						aDatos[nX,22] :=   aInfo[nI,3]
						aDatos[nX,23] :=   dtoc(StoD(aInfo[nI,5]))
						aDatos[nX,24] :=   aInfo[nI,8]
						aDatos[nX,25] :=   aInfo[nI][11]
						aDatos[nX,26] :=   cValtoChar(aInfo[nI][7])
						aDatos[nX,27] :=   aInfo[nI][2]	
					Else
						If nPos == nLenaDatos
							lTer := .T.	
							Exit
						Else
							Loop
						End if
					EndIf				
				Else
					lTer := .T.	
					Exit 
				End if	
			Next
			If lTer
				aAdd(aDatos,{aDatos[nPos,1],;
					aDatos[nPos,2],;
					aDatos[nPos,3],;
					aDatos[nPos,4],;
					aDatos[nPos,5],;
					aDatos[nPos,6],;
					aDatos[nPos,7],;
					aDatos[nPos,8],;
					aDatos[nPos,9],;
					aDatos[nPos,10],;
					aDatos[nPos,11],;
					aDatos[nPos,12],;
					aDatos[nPos,13],;
					aDatos[nPos,14],;
					aDatos[nPos,15],;
					aDatos[nPos,16],;
					aDatos[nPos,17],;
					aDatos[nPos,18],;
					aDatos[nPos,19],;
					aDatos[nPos,20],;
					aDatos[nPos,21],;
					aInfo[nI,3],;
					dtoc(StoD(aInfo[nI,5])),;
					aInfo[nI,8],;
					(aInfo[nI][2]),;
					cValtoChar(aInfo[nI][7]),;
					(aInfo[nI][11]),; 
					aDatos[nPos,28],;
					aDatos[nPos,29],;
					aDatos[nPos,30],;
					aDatos[nPos,31]})
			Endif
		Next
	Endif	

Return nLin 

Static Function CancARGBCR(nLin,cFilF1,cSerie,cDoc,cFornece,cEspecie,aDatos,lFin)
	
	Local cQry3		:= GetNextAlias()
	Local nX		:= 0
	Local nI		:= 0
	Local nSaldo	:= SE2->E2_SALDO 
	Local cTipo		:= MV_CPNEG
	Local cTipoAux	:= "'" 
	Local nMoedaSE2	:= SE2->E2_MOEDA
	
	Private aInfo	:= {}
	Private aInfo2	:= {} 
	Private aCancel	:= {} 

	While At(",",cTipo) <> 0
		cTipoAux += SubStr(cTipo,1,At(",",cTipo)-1) + "','"
		cTipo := SubStr(cTipo,At(",",cTipo)+1,Len(cTipo))
		If At(",",cTipo) == 0 .And. Len(cTipo) <> 0
			cTipoAux += cTipo + "'"
		EndIf
	EndDo

	If Len(cTipoAux) <= 1
		cTipoAux:= "''"
	EndIf

	cTipoAux := "%" + " AND SE2.E2_TIPO IN (" + cTipoAux + ") " + "%" 

	//Retorna o saldo do PA 
	BEGINSQL Alias cQry3              
		SELECT SE2.E2_PREFIXO, SE2.E2_NUM, SE2.E2_PARCELA, SE2.E2_VALOR, SE2.E2_TIPO,
			SE2.E2_FORNECE, SE2.E2_LOJA, SE2.E2_EMISSAO, SE2.E2_MOEDA, SE2.E2_TXMOEDA,SE2.E2_SALDO,SE2.E2_VALLIQ,SE2.E2_VlCRUZ,SE2.E2_BCOCHQ,SE2.E2_FATFOR 
		FROM 
			%Table:SE2% SE2
		WHERE
			SE2.E2_SALDO > 0 AND
			SE2.E2_FORNECE = %Exp:cFornece% AND
			SE2.E2_FILIAL = %Exp:cFilF1% AND
			SE2.E2_BAIXA <=  %Exp:Dtos(MV_PAR02)% AND
			SE2.%NotDel%
	EndSQL

	While !(cQry3)->(Eof()) 

		dDatMoe := Iif(MV_PAR04 == 1, dDataBase, StoD((cQry3)->E2_EMISSAO))
		nTaxMoe := Iif(MV_PAR04 == 2,Iif(nMoedaSE2 > 0,nMoedaSE2,RecMoeda((cQry3)->E5_EMISSAO,(cQry3)->E2_MOEDA)),RecMoeda(dDatMoe,nMoeda))

		If nSaldo >= 0 .and. (cQry3)->E2_TIPO $ MVPAGANT + "/" + MV_CPNEG 
			@nLin,120 PSAY (cQry3)->E2_TIPO 
			@nLin,124 PSAY (cQry3)->E2_NUM
			@nLin,142 PSAY StoD((cQry3)->E2_EMISSAO)
			@nLin,162 PSAY Transform(xMoeda((cQry3)->E2_SALDO,SE2->E2_MOEDA,nMoeda,dDatMoe,, SE2->E2_TXMOEDA)*nTaxMoe,"@E 999,999,999,999.99")
			nLin := nLin + 1 
		EndIf
		//nLin := nLin + 1

		aAdd(aInfo2,{(cQry3)->E2_PREFIXO,;
			(cQry3)->E2_NUM,;
			(cQry3)->E2_PARCELA,;
			(cQry3)->E2_VALOR,;
			(cQry3)->E2_TIPO,;
			(cQry3)->E2_FORNECE,;
			(cQry3)->E2_LOJA,;
			(cQry3)->E2_EMISSAO,;
			(cQry3)->E2_MOEDA,;
			(cQry3)->E2_TXMOEDA,;  
			(cQry3)->E2_VALLIQ,;
			(cQry3)->E2_SALDO,;
			(cQry3)->E2_BCOCHQ,;
			(cQry3)->E2_VLCRUZ,;
			(cQry3)->E2_FATFOR}) 

		(cQry3)->(dbSkip())	

	EndDo

	(cQry3)->(DbCloseArea()) 

	nPos := aScan(aDatos,{|x| x[1] + x[3] + x[4] == cFornece + cEspecie + cDoc })
	If nPos > 0  //se encontrou --> x[1] + x[3] + x[4] == cFornece + cEspecie + cDoc
		nLenaDatos := len(aDatos)
		For nI := 1 to len(aInfo2)
			For nX := nPos to nLenaDatos
				If  aDatos[nX,1] == aDatos[nPos,1]  .And. aDatos[nX,3] == aDatos[nPos,3]  .And. aDatos[nX,4] == aDatos[nPos,4]   
					If Empty(aDatos[nX,22]).and. lTer .and. nX == 1
						aDatos[nX,22] :=   aInfo2[nI,5]
						aDatos[nX,23] :=   dtoc(StoD(aInfo2[nI,8]))
						aDatos[nX,24] :=   aInfo2[nI,13]
						aDatos[nX,25] :=   Str((aInfo2[nI][4]))
						aDatos[nX,26] :=    cValtoChar(aInfo2[nI,9])
						aDatos[nX,27] :=   Str((aInfo2[nI][14]))
						aDatos[nX,28] :=   cValtoChar(aInfo2[nI,9])
						aDatos[nX,29] :=   (-aInfo2[nI][11])
						aDatos[nX,30] :=   cValtoChar(aInfo2[nI][10])
						aDatos[nX,31] :=   (-aInfo2[nI][12])
					Else
						lTer := .T.	
						Exit			                                                                  
					EndIf	
				Else
					lTer := .T.	
					Exit 
				End if	
			Next
			If lTer .and. lFin
				aAdd(aDatos,{aDatos[nPos,1],;
					aDatos[nPos,2],;
					aInfo2[nI,15],;
					aInfo2[nI,15],;
					aInfo2[nI,15],;
					aInfo2[nI,15],;
					aInfo2[nI,15],;
					aInfo2[nI,15],;
					aInfo2[nI,15],;
					aInfo2[nI,15],;
					aInfo2[nI,15],;
					aInfo2[nI,15],;
					aInfo2[nI,15],;
					aInfo2[nI,15],;
					aInfo2[nI,15],;
					aInfo2[nI,15],;
					aInfo2[nI,15],;
					aInfo2[nI,15],;
					aInfo2[nI,15],;
					aInfo2[nI,15],;
					aInfo2[nI,15],;
					aInfo2[nI,5],;
					dtoc(StoD(aInfo2[nI,8])),;
					aInfo2[nI,13],;
					Str((aInfo2[nI][4])),;
					cValtoChar(aInfo2[nI][10]),;
					Str((aInfo2[nI][14])),;
					cValtoChar(aInfo2[nI,9]),;
					-aInfo2[nI][12],;
					cValtoChar(aInfo2[nI][10]),;
					Str(-aInfo2[nI][14])})	                 
			Endif	
		Next
	Endif

Return nLin                                                    

//======================
// Total por Fornecedor
//======================
Static Function TotARGBCR(nLin,cFilF1,cSerie,cDoc,cFornece,cEspecie,aDatos,lFin,cChavNF,cAliasQry)

	Local nPos 		 := 0
	Local nLenaDatos := 0
	Local nX 		 := 0 
	Local nTotal	 := 0
	Local nTotGer    := 0
	Local cChaAnt    := cChavNF

	nLin := nLin+1  

	nPos := aScan(aDatos,{|x| x[1] + x[3] == cFornece + cEspecie })
	If nPos > 0  //se encontrou --> x[1] + x[3] + x[4] == cFornece + cEspecie + cDoc
		nLenaDatos := len(aDatos)
		For nX := nPos to nLenaDatos
			If  aDatos[nX,1] == aDatos[nPos,1]  
				If !Empty(aDatos[nX,13])
					nTotal  := aDatos[nX,13]
					nTotGer := nTotGer+nTotal
					If MV_PAR03 == 1 
						If !Empty(Alltrim(aDatos[nx,4])) .and. SubStr((Alltrim(aDatos[nx, 22])),1,2) == "OP" 
							nTotal  := Val(aDatos[nx,25])
							nTotGer := nTotGer-(nTotal)  				
						EndIf
					Else
						If !Empty(Alltrim(aDatos[nx,4])) .and. SubStr((Alltrim(aDatos[nx,22])), 1, 2) == "OP" 
							nTotal  := Val(aDatos[nx,27])
							nTotGer := nTotGer -(nTotal)  				
						EndIf
					EndIf				     	
				Else
					If MV_PAR03 == 1		   		      	
						If Alltrim(aDatos[nx,22])$"PA"
							nTotal  := aDatos[nx,29]
							nTotGer := nTotGer+(nTotal)	  				
						EndIf
					Else                                          
						If Alltrim(aDatos[nx,22])$"PA"
							nTotal  := aDatos[nx,29]
							nTotGer := nTotGer+(nTotal)
						EndIf 			  
					EndIf  
				EndIf  				
			EndIf
		Next	

		If !Empty(cChavNF) .And. cChavNF <> (cAliasQry)->(F1_FILIAL+F1_FORNECE+F1_LOJA+F1_DOC+F1_SERIE)
			@nLin,000 PSAY (aDatos)[1][1] 
			@nLin,010 PSAY Alltrim((aDatos)[1][2])
			@nLin,040 PSAY STR0010 //"SALDO" 
			If !SubStr(cChavNF,1,8) == SubStr((cAliasQry)->(F1_FILIAL+F1_FORNECE+F1_LOJA+F1_DOC+F1_SERIE),1,8)
				@nLin,162 PSAY Transform(xMoeda(nTotGer,SE2->E2_MOEDA,nMoeda,dDatMoe,, SE2->E2_TXMOEDA)*nTaxMoe,"@E 999,999,999,999.99")
				nLin := nLin+1 
				@nLin,040 PSAY STR0011 //"TOTAL"
				@nLin,162 PSAY Transform(xMoeda(nTotGer,SE2->E2_MOEDA,nMoeda,dDatMoe,, SE2->E2_TXMOEDA)*nTaxMoe,"@E 999,999,999,999.99")
				nLin := nLin+1  
				@nLin+1,00 PSAY STR0008	
				nLin := nLin+1 		
			EndIf				
		Else                                                                              
			@nLin,000 PSAY (aDatos)[nPos,1] 
			@nLin,010 PSAY Alltrim((aDatos)[nPos,2])
			@nLin,040 PSAY STR0010 //"SALDO"
			@nLin,162 PSAY Transform(xMoeda(nTotGer,SE2->E2_MOEDA,nMoeda,dDatMoe,, SE2->E2_TXMOEDA) * nTaxMoe, "@E 999,999,999,999.99")
			nLin := nLin + 1         
			@nLin,040 PSAY STR0011 //"TOTAL"
			@nLin,162 PSAY Transform(xMoeda(nTotGer,SE2->E2_MOEDA,nMoeda,dDatMoe,, SE2->E2_TXMOEDA) * nTaxMoe, "@E 999,999,999,999.99")
			nLin := nLin + 1  
			@nLin+1,00 PSAY STR0008
			nLin := nLin + 1 
		EndIf		
	Endif

	nLin := nLin + 1 
	lTer := .F.			

Return nLin