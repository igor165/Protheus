#Include "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "GPER355.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GPER355 ³ Autor ³ Renan Borges                                             ³ Data ³ 04/04/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Geracao de Remuneracoes e Participacoes a Pagar                                              ³±±
±±³          ³                                                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPER355()                                                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                              ALTERACOES DESDE SUA CONSTRUCAO INICIAL                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³    Programador     ³   Data   ³  Chamado  ³                     Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Marco A. Glez R.   ³03/03/2021³DMINA-11323³Se remueve funcion fChkUpd() que comprueba si el ambiente    ³±±
±±³                    ³          ³           ³esta actuzalido. (PER)                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GPER355()

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Define Variaveis Locais (Basicas)                            ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Local cDesc1 		:= STR0001		//"Remuneracoes e Participacoes a Pagar"
Local cDesc2 		:= STR0002		//"Sera impresso de acordo com os parametros solicitados pelo utilizador."
Local cDesc3 		:= STR0003		//Obs.: deve-se imprimir um formulário anual para cada empresa."
Local cString		:= "SRA"        //alias do arquivo principal (Base)

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Define Variaveis Private(Basicas)                            ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Private nomeprog	:= "GPER355"
Private aReturn 	:= { , 1,, 2, 2, 1,"",1 }	
Private nLastKey 	:= 0
Private cPerg   	:= "GPER355"
Private aInfo		:= {}

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Variaveis Utilizadas na funcao de Impressao                  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Private Titulo		:= STR0001
Private nTamanho	:= "M" 
Private lEnd

Private cFilProc	:= ""
Private cExerc		:= ""
Private oPrint
Private oFont8, oFont9, oFont9n, oFont10

oFont8  := TFont():New("Courier New",08,08,,.F.,,,,.T.,.F.)
oFont9  := TFont():New("Courier New",09,09,,.F.,,,,.T.,.F.)
oFont9n := TFont():New("Courier New",09,09,,.T.,,,,.T.,.F.)	//Negrito
oFont10 := TFont():New("Courier New",10,10,,.F.,,,,.T.,.F.)
oFont10n:= TFont():New("Courier New",10,10,,.T.,,,,.T.,.F.)	//Negrito

pergunte("GPER355",.F.)  

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Envia controle para a funcao SETPRINT                        ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
wnrel := "GPER355"	//Nome Default do relatorio em Disco
wnrel := SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,,,nTamanho)

If nLastKey = 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Return
Endif

MakeSqlExpr(cPerg)

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Variaveis utilizadas para parametros                         ³
³ mv_par01        //Exercicio                                  ³ 
³ mv_par02        //Filiais                                    ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
cExerc   := cValToChar(MV_PAR01)
cFilProc := MV_PAR02

//-- Objeto para impressao grafica
oPrint 	:= TMSPrinter():New( STR0001 ) //"Remuneraciones y Participaciones por Pagar"
oPrint:SetPortrait()

Titulo := ( STR0001 ) //"Remuneraciones y Participaciones por Pagar"
											 
RptStatus({|lEnd| IMPLANC(@lEnd,wnRel,cString,.F. )},Capital(Titulo))   

//Visualiza impressao grafica antes de imprimir
oPrint:Preview()  							
                                                                              
Return                       


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IMPLANC   ºAutor  ³Renan Borges        º Data ³  04/04/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPER355                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function IMPLANC()                 

Local cQryLanc 
Local cLastCta  := "%%"

Local cCtaCod   := ""
Local cCtaNome  := ""
Local cFunMat   := ""
Local cFunNome  := ""
Local cFunTpDoc := ""
Local cFunDoc   := ""
Local cFiltro   := ""
Local cCodRUC   := ""
Local cEmp      := ""

Local nValSaldo := 0
Local nTotCta   := 0
Local nTotEmp   := 0 
Local nColSol   := 2040
Local nLinIni   := 0340
Local lPriPage  := .T.
Local lNewPage  := .F.
Local aTabEmp   := {}

//Exercicio
If !Empty(cExerc)
	cFiltro += " SRD.RD_DATARQ BETWEEN '" + cExerc + "01' AND '" + cExerc + "12'"
EndIf

//Filial
If !Empty(cFilProc)
	cFiltro += If( !Empty(cFiltro)," AND ", "" )
	cFiltro += cFilProc
EndIf

cFiltro	:= If( Empty(cFiltro ), "%%", "% AND " +cFiltro+ "%" )

cQryLanc := GetNextAlias()

	BeginSql alias cQryLanc
		SELECT SRD.RD_FILIAL, SRV.RV_CONTA, SRD.RD_MAT, SRA.RA_NOME, SRA.RA_RG, SRA.RA_TPDOCTO, SRD.RD_PD, SUM(SRD.RD_VALOR) AS VALOR
		FROM %table:SRD% SRD

		INNER JOIN %table:SRA% SRA
		ON 	SRA.RA_FILIAL = SRD.RD_FILIAL AND
			SRA.RA_MAT = SRD.RD_MAT

		INNER JOIN %table:SRV% SRV
		ON SRD.RD_PD = SRV.RV_COD

		INNER JOIN %table:CT1% CT1
		ON CT1.CT1_CONTA = SRV.RV_CONTA

		WHERE SRV.RV_CONTA <> %exp:''% AND 
		SRA.%notDel% AND SRD.%notDel% AND SRV.%notDel% AND CT1.%notDel% %exp:Upper(cFiltro)%

		GROUP BY SRD.RD_FILIAL, SRD.RD_PD, SRD.RD_MAT, SRA.RA_NOME, SRV.RV_CONTA, SRA.RA_TPDOCTO, SRA.RA_RG
		ORDER BY SRV.RV_CONTA, SRD.RD_PD, SRD.RD_MAT	
	EndSql	

Do While (cQryLanc)->(!Eof())

	If lPriPage .Or. lNewPage
		//Inicia a impressao da pagina inicial ou quando houver quebra de pagina
		oPrint:StartPage() 

		//CABECALHO COM DADOS DA EMPRESA - Imprime somente na primeira pagina
		If lPriPage
			
			//Dados da empresa
			fInfo(@aInfo, (cQryLanc)->RD_FILIAL)
			cEmp := AllTrim( aInfo[3] )
			
			fRetTab(@aTabEmp,"S015",,,dDataBase)
			If Len(aTabEmp) > 0
				cCodRUC := aTabEmp[6]
			EndIf			
			
			nLinIni  += 50	
			oPrint:say( 0020, 0040, OemToAnsi(STR0005), 	oFont10)	//"EXERCICIO: "
			oPrint:say( 0020, 0300, cExerc,					oFont10n)	//ANO
			oPrint:say( 0070, 0040, OemToAnsi(STR0006),		oFont10)	//"CNPJ: "
			oPrint:say( 0070, 0300, cCodRUC,				oFont10n)	//CNPJ
			oPrint:say( 0120, 0040, OemToAnsi(STR0007), 	oFont10)	//"SOBRENOMES E NOMES, DENOMINACAO OU RAZAO SOCIAL: "
			oPrint:say( 0120, 1140, cEmp, 					oFont10n)	//Nome da Empresa
			lPriPage := .F.
			cLastCta := (cQryLanc)->RV_CONTA
			
		EndIf

		//TITULO DOS LANCAMENTOS
		If lNewPage
			//Posicao do titulo ao imprimir a partir da segunda pagina
			nLinIni	:= 0200
			lNewPage := .F.		
			
			oPrint:box ( 0020, 0050, 0190, 2400 )						//box

			oPrint:say(  0020, 0350, OemToAnsi(STR0008), oFont9n )		//"CONTA E SUBCONTA"
			oPrint:say(  0020, 1470, OemToAnsi(STR0009), oFont9n )		//"TRABALHADOR"
			oPrint:line( 0060, 0050, 0060, 2150 )         				//Linha horizontal
			oPrint:line( 0060, 1140, 0190, 1140 ) 						//linha vertical matricula (direita)
			oPrint:line( 0020, 0970, 0190, 0970 ) 						//linha vertical matricula (esquerda)
			oPrint:line( 0020, 2150, 0190, 2150 ) 						//linha vertical saldo (esquerda)

			oPrint:say(  0070, 0300, OemToAnsi(STR0010), oFont9n )		//"REMUNERACOES A PAGAR"
			oPrint:say(  0070, 1770, OemToAnsi(STR0011), oFont9n )		//"DOC DE IDENTIDADE"
			oPrint:say(  0070, 2170, OemToAnsi(STR0012), oFont9n )		//"SALDO FINAL"
			oPrint:line( 0060, 1750, 0190, 1750 ) 						//linha vertical apelidos
			oPrint:line( 0110, 0050, 0110, 0970 )         				//Linha horizontal - abaixo remuneraciones por pagar
			oPrint:line( 0110, 1750, 0110, 2150 )         				//Linha horizontal - abaixo doc identidade

			oPrint:say(  0110, 0150, OemToAnsi(STR0013), oFont9n )		//"CODIGO" (CONTA)
			oPrint:say(  0110, 0500, OemToAnsi(STR0014), oFont9n )		//"DENOMINACAO"
			oPrint:say(  0110, 1000, OemToAnsi(STR0013), oFont9n )		//"CODIGO" (MATRICULA)
			oPrint:say(  0110, 1250, OemToAnsi(STR0015), oFont9n )		//"SOBRENOMES E NOMES"
			oPrint:say(  0110, 1780, OemToAnsi(STR0016), oFont9n )		//"TIPO"
			oPrint:say(  0110, 1940, OemToAnsi(STR0017), oFont9n )		//"NUMERO"
			oPrint:line( 0110, 0420, 0190, 0420 ) 						//linha vertical codigo conta
			oPrint:line( 0110, 1910, 0190, 1910 ) 						//linha vertical tipo tabela

			oPrint:say(  0150, 1760, OemToAnsi(STR0018), oFont9n )		//"(TAB.2)"
		Else               
			//Posicao do titulo ao imprimir a primeira pagina
			oPrint:box ( 0220, 0050, 0380, 2400 )						//box
			
			oPrint:say(  0220, 0350, OemToAnsi(STR0008), oFont9n )    	//"CONTA E SUBCONTA"
			oPrint:say(  0220, 1470, OemToAnsi(STR0009), oFont9n )		//"TRABALHADOR"
			oPrint:line( 0260, 0050, 0260, 2150 )         				//Linha horizontal
			oPrint:line( 0260, 1140, 0380, 1140 ) 						//linha vertical matricula (direita)
			oPrint:line( 0220, 0970, 0380, 0970 ) 						//linha vertical matricula (esquerda)
			oPrint:line( 0220, 2150, 0380, 2150 ) 						//linha vertical saldo
			
			oPrint:say(  0260, 0300, OemToAnsi(STR0010), oFont9n )		//"REMUNERACOES A PAGAR"
			oPrint:say(  0260, 1770, OemToAnsi(STR0011), oFont9n )		//"DOC DE IDENTIDADE"
			oPrint:say(  0260, 2170, OemToAnsi(STR0012), oFont9n )		//"SALDO FINAL"
			oPrint:line( 0260, 1750, 0380, 1750 ) 						//linha vertical apelidos
			oPrint:line( 0300, 0050, 0300, 0970 )         				//Linha horizontal - abaixo remuneraciones por pagar
			oPrint:line( 0300, 1750, 0300, 2150 )         				//Linha horizontal - abaixo doc identidade
			
			oPrint:say(  0300, 0150, OemToAnsi(STR0013), oFont9n )		//"CODIGO" (CONTA)
			oPrint:say(  0300, 0500, OemToAnsi(STR0014), oFont9n )		//"DENOMINACAO"
			oPrint:say(  0300, 1000, OemToAnsi(STR0013), oFont9n )		//"CODIGO" (MATRICULA)
			oPrint:say(  0300, 1250, OemToAnsi(STR0015), oFont9n )		//"SOBRENOMES E NOMES"
			oPrint:say(  0300, 1780, OemToAnsi(STR0016), oFont9n )		//"TIPO"
			oPrint:say(  0300, 1940, OemToAnsi(STR0017), oFont9n )		//"NUMERO"
			oPrint:line( 0300, 0420, 0380, 0420 ) 						//linha vertical codigo conta
			oPrint:line( 0300, 1910, 0380, 1910 ) 						//linha vertical tipo tabela

			oPrint:say( 0340, 1760, OemToAnsi(STR0018), oFont9n)		//"(TAB.2)"
		EndIf
		
	EndIf

	//Imprime o SubTotal toda vez que trocar a conta contabil
	If cLastCta <> (cQryLanc)->RV_CONTA
		nLinIni += 50
		oPrint:say( nLinIni, 0200, OemToAnsi(STR0019),						 oFont9  )	//"SUBTOTAL"
		oPrint:say( nLinIni, 2020, "S/.", 									 oFont9n )	//Soles
		oPrint:say( nLinIni, 2040, Transform(nTotCta, "999,999,999,999.99"),oFont9n )	//Total da conta
		nLinIni  += 50
		oPrint:line( nLinIni, 0060, nLinIni, 2400 )          							//Linha horizontal

		//Apos imprimir o total da conta zera o valor para iniciar uma proxima conta
		nTotCta  := 0 
		cLastCta := (cQryLanc)->RV_CONTA
	EndIf

	//Atribui o valor das variaveis
	cCtaCod   := AllTrim( (cQryLanc)->RV_CONTA )
	cCtaDesc  := SUBSTR( fDesc("CT1", cCtaCod, "CT1_DESC01"), 1, 30 )
	cCtaNome  := AllTrim( cCtaDesc )
	cFunMat   := AllTrim( (cQryLanc)->RD_MAT )
	cFunNome  := AllTrim( (cQryLanc)->RA_NOME )
	cFunTpDoc := AllTrim( (cQryLanc)->RA_TPDOCTO )
	cFunDoc   := AllTrim( (cQryLanc)->RA_RG )
	nValSaldo := (cQryLanc)->VALOR
	
	//Incrementa o valor de cada conta
	nTotCta   += nValSaldo
	nTotEmp	  += nValSaldo

	nLinIni += 40	
	oPrint:say( nLinIni, 0060, cCtaCod,		oFont8 )	//Conta contabil - Codigo
	oPrint:say( nLinIni, 0430, cCtaNome,	oFont8 )	//Conta contabil - Nome
	oPrint:say( nLinIni, 1000, cFunMat,		oFont8 )	//Funcionario - Matricula
	oPrint:say( nLinIni, 1170, cFunNome,	oFont8 )	//Funcionario - Nome
	oPrint:say( nLinIni, 1800, cFunTpDoc,	oFont8 )	//Funcionario - Tipo documento
	oPrint:say( nLinIni, 1930, cFunDoc, 	oFont8 )	//Funcionario - Numero documento

	oPrint:say( nLinIni, 2150, Transform(nValSaldo, "999,999,999.99"), oFont8 ) //Conta contabil - Saldo

	//Trata a quebra de pagina	
	If nLinIni >= 3100
		lNewPage := .T.
		oPrint:EndPage()		
	EndIf

	(cQryLanc)->(DbSkip()) 
	
EndDo

//Imprime o Rodape e o total da empresa
If !lPriPage     

	If lNewPage
		nLinIni := 20
	Else
		nLinIni += 50
	EndIf

	oPrint:say( nLinIni, 0200, OemToAnsi(STR0019),	oFont9 )						//"SUBTOTAL"
	oPrint:say( nLinIni, 2020, "S/.", 									 oFont9n )	//Soles
	oPrint:say( nLinIni, 2040, Transform(nTotCta, "999,999,999,999.99"),oFont9n )	//Total da conta
	nLinIni  += 50
	oPrint:line( nLinIni, 0060, nLinIni, 2400 )          							//Linha horizontal

	//Ajusta a posicao do simbolo caso o valor total seja superior a 1 Bilhao
	If nTotEmp > 1000000000
		nColSol := 1950
	EndIf
	
	nLinIni  += 100	
	oPrint:say( nLinIni, 0200, OemToAnsi(STR0020),		oFont9 )					//Total
	oPrint:say( nLinIni, nColSol, "S/.", 								 oFont9n )	//Soles
	oPrint:say( nLinIni, 2040, Transform(nTotEmp, "999,999,999,999.99"),oFont9n )	//"TOTAL" (Empresa)
	nLinIni  += 50
	oPrint:line( nLinIni, 0060, nLinIni, 2400 )       								//Linha horizontal

	nLinIni  += 200  
	oPrint:line( nLinIni, 0300, nLinIni, 1000 )    									//Linha horizontal	
	oPrint:say( nLinIni,  0450, OemToAnsi(STR0021),		oFont9 )					//"REPRESENTANTE LEGAL"

	oPrint:line( nLinIni, 1300, nLinIni, 2000 )        								//Linha horizontal	
	oPrint:say( nLinIni,  1550, OemToAnsi(STR0022),		oFont9 )					//"CONTADOR"

	oPrint:EndPage()
EndIf

Return