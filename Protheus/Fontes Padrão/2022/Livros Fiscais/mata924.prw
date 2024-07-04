#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATA924.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MATA924   ³ Autor ³Mary C. Hergert        ³ Data ³30/07/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Simples Nacional - Regime Especial Unificado de Arrecadacao ³±±
±±³          ³de Tributos e Contribuicoes devidos pelas Microempresas e   ³±±
±±³          ³Empresas de Pequeno Porte - Super Simples                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MATA924(lAutomato,nOpcApur)

Local cCadastro := STR0015 //"Apuracao do Simples Nacional"
Local aSays		:= {}
Local aButtons	:= {}
Local cPerg		:= "MTA924"
Local cTitulo1	:= STR0016 //"Este programa faz a Apura‡„o do Simples Nacional, das ME - Microempresas e    "
Local cTitulo2	:= STR0017 //"EPP - Empresas de Pequeno Porte, conforme parƒmetros informados pelo usu rio."
Local cFILSNCO	:= FWGrpCompany()+FWGETCODFILIAL
Local cFile		:= "SNCONFIG"+cFILSNCO+".CFG"
Local nOpc		:= 0

Default nOpcApur  := 2
Default lAutomato := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gera Temporario                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
A924Temp()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa grupo de perguntas        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega temporario com as informacoes ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
A924Carga()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Janela Principal                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD(aSays,OemToAnsi( cTitulo1 ) )
AADD(aSays,OemToAnsi( cTitulo2 ) )
AADD(aButtons, { 4,.T.,{|o| A924Cfg()} } )		//Inclusao da tabela temporaria
AADD(aButtons, { 1,.T.,{|o| Processa({||A924Proc()}),o:oWnd:End()} } )
AADD(aButtons, { 2,.T.,{|o| nOpc:=3,o:oWnd:End()} } )
AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T.)} } )

If !lAutomato
	FormBatch( cCadastro, aSays, aButtons )
Else
	A924Proc(lAutomato,nOpcApur)
EndIf

If select("TMP") > 0
	dbSelectArea("TMP")
	dbCloseArea()
EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³A924Proc   ³ Autor ³Mary C. Hergert        ³ Data ³30/07/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa Simples Nacional                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A924Proc(lAutomato,nOpcApur)

Local aConfApur	:= {}                                       
Local aPartilha	:= {}
Local aPartilhaS:= {}
Local aPartST	:= {} 
Local aPartilhaL:= {}
Local aFaixa	:= {}
Local aServ		:= {}
Local cLPadSim	:= AllTrim(GetNewPar("MV_LPADSN",""))
Local cLcPadTit	:= Substr(cLPadSim,1,3)
Local cLcPadExt	:= Substr(cLPadSim,5,3)
Local cImp		:= "SN"		// Simples Nacional
Local cImposto	:= "SPN"
Local cNrLivro	:= ""                                     
Local cArqApur 	:= ""
Local cProgram	:= "MATA924"   
Local cFilIni	:= ""
Local cFilFin	:= ""
Local cAlerta   := ""

Local dDtIni	:= Ctod("")
Local dDtFim	:= Ctod("")               
Local dDtVenc	:= Ctod("")
Local dDtRecIni	:= Ctod("")
Local dDtRecFim	:= Ctod("")                                                    

Local lTitulo	:= .F.
Local lLancCont	:= .F.
Local lApur		:= .F.
Local lProcFil	:= .F.
Local lRet      := .T.
Local nTotalRB	:= 0		//Total da Receita Bruta Acumulada 
Local nRBMensal	:= 0		//Total da Receita Bruta Mensal
Local nRBMesExp	:= 0		//Total da Receita Bruta Mensal Exportacao
Local nVlrDev	:= 0
Local nVlrDevS	:= 0
Local nVlDevST	:= 0
Local nVlrDevL  := 0          
Local nRegTrib	:= 1
Local nMoeda	:= 0    
Local nAno		:= 0
Local nMes		:= 0           
Local nMesAnt	:= 0
Local nAnoAnt	:= 0           
Local nApuracao	:= 0                          
Local nPeriodo	:= 0
Local nPerc		:= 0
Local nPercExp	:= 0
Local nPercS	:= 0
Local nPercST	:= 0
Local nPercL    := 0
Local nRB		:= 0
Local nTribMax	:= 0
Local nRBServ	:= 0
Local nRBServRet:= 0
Local nRBST		:= 0 
Local nRBLoc	:= 0        //Total da Receita Bruta Mensal de Locacao                                                                    
Local nRBAnoCale:= 0        //Total da Receita Bruta no ANo calendario para composição do LIMITE
Local nRBAnt	:= 0
Local cTPRecSN	:= AllTrim(Str(mv_par12)) 		// TP de Receita                                          
Local cArqAnt	:= ""                                          
Local nSeRecSN	:= mv_par13
Local nX		:= 0
Local nTribRec	:= 0
Local nGuiaSN 	:= 0   
Local lTotalRB	:= .F.
Local cdir := mv_par15
Local carq := mv_par16
Local cTPRecServ	:= ""

Default lAutomato	:= .F.
Default nOpcApur	:= 2

Private aDadIC	:= {}
Private aGetApur:= {}      

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametros:                                                  ³
//³ mv_par01 - Regime Tributario: 1=ME ou 2=EPP                  ³
//³ mv_par02 - Data Inicial de processamento                     ³
//³ mv_par03 - Data Final de processamento                       ³
//³ mv_par04 - Gera Titulo ( Sim/Nao )                           ³
//³ mv_par05 - Moeda do Titulo                                   ³
//³ mv_par06 - Gera guia de Recolhimento ( Sim/Nao )             ³
//³ mv_par07 - Exibir Lancamento Contabil( Sim/Nao )             ³
//³ mv_par08 - Orgao Arrecadador                                 ³
//³ mv_par09 - Processa filiais                                  ³
//³ mv_par10 - Filial inicial                                    ³
//³ mv_par11 - Filial final                                      ³
//³ mv_par12 - Tipo de Receita (1, 2 ou 3)                       ³
//³ mv_par13 - Separação das Receitas por Ramo de Atividade      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cNrLivro	:= "*"
cOrgArrec	:= mv_par08
cFilIni		:= mv_par10
cFilFin		:= mv_par11
	
dDtIni		:= mv_par02
dDtFim		:= mv_par03
dDtVenc		:= DataValida(dDtFim+20,.T.)

lTitulo		:= (mv_par04==1)
lGuiaRec	:= (mv_par06==1)
lLancCont	:= (mv_par07==1)
lProcFil	:= (mv_par09==1)

nRegTrib	:= mv_par01
nMoeda		:= If(AllTrim(Str(mv_par05))$"12345",mv_par05,1)
nMes		:= Month(dDtIni)
nAno		:= Year(dDtIni)
nMesAnt		:= Iif((Month(dDtIni)-1) == 0, 12, Month(dDtIni)-1)
nAnoAnt		:= Iif(nMesAnt == 0, Year(dDtIni)-1, Year(dDtIni))
nApuracao	:= 3			// Mensal        
nPeriodo	:= 1 			// Primeiro Periodo

If	Alltrim(cTPRecSN) == '3'
	cTPRecServ	:= ""
	aFaixa	:= A924LeCfg()
	If Len(aFaixa) > 0
		For nX := 1 To Len(aFaixa)
			If	aFaixa[nx][11] > 0
				If	Empty(cTPRecServ)
					cTPRecServ := " '" + Alltrim(Str(aFaixa[nx][16])) + "'"
				Else
					cTPRecServ += ",'" + Alltrim(Str(aFaixa[nx][16])) + "'"
				EndIf
			EndIf
		Next
	EndIf
	If Len(Alltrim(cTPRecServ)) > 0
		cTPRecSN	:=	cTPRecServ
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Vetor com as descricoes a serem apresentadas no arquivo de apuracao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aGetApur(cImp)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Nome do arquivo texto que recebera a apuracao do Simples³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if empty(cdir) .and. empty(carq)
	cArqApur := NmArqApur(cImp,nAno,nMes,nApuracao,nPeriodo,cNrLivro)
else
	cArqApur := alltrim(carq)
	cDir	:= Alltrim(cDir)
	DumpFile(1, @cDir, @cArqApur)
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se ja existe apuracao no periodo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lApur := CheckApur(cImp,nAno,nMes,nApuracao,nPeriodo,cNrLivro,cImposto,aDadIC,nMoeda,cLcPadExt,cArqApur,{},cProgram,,lTitulo,,,,nOpcApur,lAutomato)

//ARQUIVO MES ANTERIOR
if empty(cdir) .and. empty(carq)
	cArqAnt := NmArqApur(cImp,nAnoAnt,nMesAnt,nApuracao,nPeriodo,cNrLivro) 
else
	cArqAnt := alltrim(carq)
	cDir	:= Alltrim(cDir)
	DumpFile(1, @cDir, @cArqAnt)
endif

If lApur
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calcula o Total de Receita Bruta                                   ³
	//³Para o calculo do Simples Nacional, devera ser verificada a receita³
	//³bruta nos ultimos 12 meses anteriores ao periodo de apuracao.      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	A924DtRec(dDtIni,@dDtRecIni,@dDtRecFim)  
	IF  MV_PAR14 == 1 // Regime de Competencia  
		nTotalRB 	:= CalcRB(dDtRecIni,dDtRecFim,,,,,lProcFil,cFilIni,cFilFin,,,.T.,,cTPRecSN,nSeRecSN,,dDtIni,dDtFim,,lTotalRB)
		nRBAnoCale	:= CalcRB(CtoD("01/01/"+StrZero(Year(dDtIni),4)),dDtFim,,,,,lProcFil,cFilIni,cFilFin,,,.T.,,cTPRecSN,nSeRecSN,,dDtIni,dDtFim)
		nRB			:= CalcRB(dDtIni,dDtFim,@nRBMensal,.T.,,,lProcFil,cFilIni,cFilFin,@nRBServ,@nRBST,.T.,@nRBLoc,cTPRecSN,nSeRecSN,@nRBServRet,dDtIni,dDtFim,@nRBMesExp,,@aServ)
	Else
		nTotalRB 	:= RegCaixa(dDtRecIni,dDtRecFim,,,lProcFil,cFilIni,cFilFin,,,,)
		nRBAnoCale	:= RegCaixa(CtoD("01/01/"+StrZero(Year(dDtIni),4)),dDtFim,,,lProcFil,cFilIni,cFilFin,,,)
		nRB			:= RegCaixa(dDtIni,dDtFim,@nRBMensal,.T.,lProcFil,cFilIni,cFilFin,@nRBServ,@nRBST,@nRBLoc,@nRBServRet,@nRBMesExp)
	EndIf                        
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o valor da receita bruta anual nao ultrapassou a ultima faixa configurada.³
	//³Se ultrapassar, o calculo nao sera efetuado - a empresa sera desenquadrada do Simples.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aFaixa		:= A924LeCfg()	
	nRBAnt		:= A924LeArqAnt(cArqAnt)
	If Len(aFaixa) > 0 .And. nSeRecSN == 2	
		For nX := 1 To Len(aFaixa)
		   	If (Len(aFaixa[nX]) > 15 .And. Valtype(aFaixa[nX][15]) <> "U" .And. nSeRecSN == 2)
		   		If  Alltrim(Str(aFaixa[nX][16])) $ Alltrim(cTPRecSN)
			   		nTribRec	:= aFaixa[nX][02]
				EndIf
			EndIf   	
		Next			
		If Len(aFaixa) > 0
			nTribRec	:= aFaixa[Len(aFaixa)][02]
			nTribRec 	+= (nTribRec * 0.20)			
			If nRBAnoCale > nTribRec .And. nRBAnt > nTribRec 
				cAlerta := "A soma da Receita Bruta do Ano calendário do Contribuinte " + chr(13)
		        cAlerta += "(" + Alltrim(Transform(nRBAnoCale,"@E 99999,999,999.99")) + ") " + chr(13)
		        cAlerta += "Excedeu a 20% do Limite Máximo de (" + Alltrim(Transform(aFaixa[Len(aFaixa)][02],"@E 99999,999,999.99")) + ") " + chr(13)
		        cAlerta += " do Simples Nacional, a Empresa não está enquadrada ao Simples Nacional"
				Aviso("A924Limite", cAlerta ,{"Ok"})
		        lRet := .F.
			Endif
		Endif
	Elseif Len(aFaixa) > 0
		nTribMax	:= aFaixa[Len(aFaixa)][02]
		nTribMax 	+= nTribMax * 0.20
		If nRBAnoCale > nTribMax .And. nRBAnt > nTribMax
			cAlerta := "A soma da Receita Bruta do Ano calendário do Contribuinte " + chr(13)
			cAlerta += "(" + Alltrim(Transform(nRBAnoCale,"@E 99999,999,999.99")) + ") " + chr(13)
			cAlerta += "Excedeu a 20% do Limite Máximo de (" + Alltrim(Transform(aFaixa[Len(aFaixa)][02],"@E 99999,999,999.99")) + ") " + chr(13)
			cAlerta += " do Simples Nacional, a Empresa não está enquadrada ao Simples Nacional"
			Aviso("A924Limite", cAlerta ,{"Ok"})
			lRet := .F.
		Endif
	Else
		aFaixa := {{0,0}}
	Endif
    
	If lRet
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula o Valor Devido (Valor a ser pago mensalmente)                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nVlrDev := A924CalcVD(nRegTrib,nTotalRB,nRBMensal,@aPartilha,@nPerc,@nRBServ,@nRBST,@nRBLoc,,,nRBAnoCale,nRBServRet,nRBMesExp,@nPercExp)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula o Valor Devido (Valor a ser pago mensalmente) - Servicos      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nVlrDevS := A924VDServ(nRegTrib,nTotalRB,nRBMensal,@aPartilhaS,@nPercS,@nRBServ,nRBServRet,nRBAnoCale,aServ)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula o Valor Devido (Valor a ser pago mensalmente) - ST      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nVlDevST := A924VDST(nRegTrib,nTotalRB,nRBMensal,@aPartST,@nPercST,@nRBST,@nGuiaSN)
		         
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula o Valor Devido (Valor a ser pago mensalmente) - Locacao ³
		//  de bens moveis 													³       
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nVlrDevL := A924VDLoc(nRegTrib,nTotalRB,nRBMensal,@aPartilhaL,@nPercL,@nRBLoc,nRBAnoCale)  	                       

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Array com as informacoes da apuracao para gravacao e geracao dos titulos³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aConfApur := {lTitulo,nVlrDev,cImposto,cImp,cLcPadTit,dDtIni,dDtFim,dDtVenc,nMoeda,nMes,nAno,cProgram,lLancCont,nApuracao,nPeriodo,cNrLivro,cOrgArrec,lGuiaRec,nVlrDev,nVlrDevS,nVlDevST,nVlrDevL,nGuiaSN}
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualizando os valores do array aGetApur para gravar no arquivo texto³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		A924Refr(nTotalRB,nRBMensal,nVlrDev,nRBServ,nVlrDevS,nRBST,nVlDevST,nRBLoc,nVlrDevL,nRBServRet)
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Apresentacao das Informacoes na Tela                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		A924Tela(nRegTrib,dDtIni,dDtFim,nTotalRB,nVlrDev,nRBMensal,@aConfApur,aPartilha,nPerc,@nRBServ,nPercS,nVlrDevS,aPartilhaS,@nRBST,nPercST,nVlDevST,aPartST,nRBLoc,nPercL,nVlrDevL,aPartilhaL,nRBServRet,nGuiaSN,nRBMesExp,nPercExp,cArqApur,aServ,lAutomato)
	
    EndIf
    
Endif

Return lRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³A924CalcVD ³ Autor ³Mary C. Hergert        ³ Data ³30/07/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Calcula o Valor Devido (Valor a ser pago mensalmente)        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/					
Static Function A924CalcVD(nRegTrib,nTotalRB,nRBMensal,aPartilha,nPerc,nRBServ,nRBST,nRBLoc,nValBrut,nValIss,nRBAnoCale,nRBServRet,nRBMesExp,nPercExp)

Local aFaixa	:= {}
Local nX		:= 0
Local nVlrDev	:= 0
Local nVlrIni	:= 0
Local nVlrFim	:= 0
Local nAliq		:= 0
Local nAliqMax  := 0 
Local nRRBExC   := 0
Local nFaixaMax := 3600000   // limite maximo da faixa do Simples Nacional
Local cTPRecSN	:= mv_par12
Local nSeRecSN	:= mv_par13
Local nBasICMS	:= nRBMensal
Local nRedICMS	:= 0
Local nOtrasRec	:= 0
Local nRBMesNac	:= nRBMensal

aPartilha := {{"IRPJ",0,0},{"CSLL",0,0},{"Cofins",0,0},{"PIS/Pasep",0,0},{"INSS",0,0},{"ICMS",0,0},{"ISS",0,0},{"IPI",0,0},{"IRPJ, PIS/Pasep, Cofins e CSLL",0,0},{"CPP",0,0}}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tabela de Percentuais Aplicaveis       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aFaixa := A924LeCfg()

If Len(aFaixa) > 0

	For nX := 1 To Len(aFaixa)
		cTPRecSN := IIf (Valtype(cTPRecSN) == "C",Val(cTPRecSN),cTPRecSN)
	   	If (aFaixa[nx][09]<>0).And.(aFaixa[nX][11]==0) .And. (IIf(Len(aFaixa[nX])>15 .And. Valtype(aFaixa[nX][15])<>"U" .And. nSeRecSN==2 ,aFaixa[nX][16]==cTPRecSN,.T.))
			nVlrIni	:= aFaixa[nX][01]
			nVlrFim	:= aFaixa[nX][02]
		 								
			If (nTotalRB >= nVlrIni .And. nTotalRB <= nVlrFim) .Or. (nTotalRB == 0 .And. nRBMensal >= nVlrIni .And. nRBMensal <= nVlrFim)
			    If aFaixa[nX][10] > 0
					nBasICMS := nRBMensal - (nRBMensal * aFaixa[nX][10] / 100)				
					nRedICMS := (nRBMensal * aFaixa[nX][09] / 100) - (nBasICMS * aFaixa[nX][09] / 100)
				Endif	
				nAliq	:= aFaixa[nX][03]
				
				If nRBMesExp > 0 //Subtrai as aliquotas PIS/COFINS/ICMS/ISS/IPI conforme legislacao
					nPercExp := aFaixa[nX][03] - (aFaixa[nX][06] + aFaixa[nX][07] + aFaixa[nX][9] + aFaixa[nX][11] + aFaixa[nX][12])	
				Endif	

				nOtrasRec	:= nRBServ + nRBServRet + nRBST + nRBLoc
				IF nRBMesNac > 0
					nVlrDev := ((nRBMesNac - nOtrasRec) * nAliq/100) - nRedICMS
				ENDIF	
				If nRBMesExp > 0
					nVlrDev += (nRBMesExp * nPercExp/100) - nRedICMS
				EndIf
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Divide o valor do Simples calculado pelos impostos abrangidos pela legislacao³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aPartilha[01][02] 	:= (nRBMensal-nOtrasRec)				* aFaixa[nX][04] / 100
				aPartilha[02][02] 	:= (nRBMensal-nOtrasRec) 			* aFaixa[nX][05] / 100
				aPartilha[03][02] 	:= (nRBMensal-nOtrasRec) 			* aFaixa[nX][06] / 100
				aPartilha[04][02] 	:= (nRBMensal-nRBMesExp-nOtrasRec) * aFaixa[nX][07] / 100
				aPartilha[05][02] 	:= (nRBMensal-nRBMesExp-nOtrasRec) * aFaixa[nX][08] / 100
				aPartilha[06][02] 	:= (nBasICMS - nOtrasRec) 			* aFaixa[nX][09] / 100
				aPartilha[07][02] 	:= (nRBMensal-nRBMesExp-nOtrasRec) * aFaixa[nX][11] / 100
				aPartilha[08][02] 	:= (nRBMensal-nOtrasRec) 			* aFaixa[nX][12] / 100
				aPartilha[09][02] 	:= (nRBMensal-nOtrasRec) 			* aFaixa[nX][13] / 100
				aPartilha[10][02] 	:= (nRBMensal-nOtrasRec) 			* aFaixa[nX][14] / 100
				
				aPartilha[01][03] 	:= aFaixa[nX][04]
				aPartilha[02][03] 	:= aFaixa[nX][05]
				aPartilha[03][03] 	:= aFaixa[nX][06]
				aPartilha[04][03] 	:= aFaixa[nX][07]
				aPartilha[05][03] 	:= aFaixa[nX][08]
				aPartilha[06][03] 	:= aFaixa[nX][09]
				aPartilha[07][03] 	:= aFaixa[nX][11]
				aPartilha[08][03] 	:= aFaixa[nX][12]
				aPartilha[09][03] 	:= aFaixa[nX][13] 
				aPartilha[10][03] 	:= aFaixa[nX][14]			
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se a faixa ultrapassou o limite maximo de 3.600.000,00 se sim, conforme a ³
				//³legislação do Simples Nacional, a alíquota deverá ser majorada em 20% prevista na  ³
				//³tabela a ser aplicada sobre a parcela excedente e depois calcular o RRBExC         ³
				//³(Relação entre a parcela da Receita Bruta mensal cujo valor acumulado exceder o    ³
				//³limite de R$ 3.600.000,00 e a Receita Bruta total).								  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ElseIf nTotalRB > nVlrFim .AND. nTotalRB > nFaixaMax  .And. nVlrFim == nFaixaMax
    			nAliq	:= aFaixa[nX][03]                  // aliquota maxima prevista na tabela

				If nRBMesExp > 0 //Subtrai as aliquotas PIS/COFINS/ICMS/ISS/IPI conforme legislacao
					nPercExp := aFaixa[nX][03] - (aFaixa[nX][06] + aFaixa[nX][07] + aFaixa[nX][9] + aFaixa[nX][11] + aFaixa[nX][12])	
				Endif	
				
				nOtrasRec	:= nRBServ + nRBServRet + nRBST + nRBLoc

				If nRBAnoCale > nFaixaMax  
					nAliqMax := (nAliq * 1.2)	   			// aliquota maxima majorada em 20% 
					nRRBExC = Round((nTotalRB - nVlrFim) / nRBMensal,2) // calcula o RRBExC    //valor acumulado nos ultimos 12 meses
					nVlrDev := (((nRBMesNac * (1 - nRRBExC) * nAliq)/100) + (((nRBMesNac * nRRBExC) * nAliqMax)/100))    
					If nRBMesExp > 0
						nVlrDev += (((nRBMesExp * (1 - nRRBExC) * nPercExp)/100) + (((nRBMesNac * nRRBExC) * nAliqMax)/100))    
					EndIf
				Else
					IF nRBMesNac > 0
						nVlrDev := (((nRBMesNac-nOtrasRec) * nAliq)/100)
					ENDIF	
					If nRBMesExp > 0							     
						nVlrDev += (((nRBMesExp-nOtrasRec) * nPercExp)/100)
					EndIf							     
				EndIf 

				aPartilha[01][02] 	:= (nRBMensal-nOtrasRec)			* aFaixa[nX][04] / 100
				aPartilha[02][02] 	:= (nRBMensal-nOtrasRec) 			* aFaixa[nX][05] / 100
				aPartilha[03][02] 	:= (nRBMensal-nOtrasRec) 			* aFaixa[nX][06] / 100
				aPartilha[04][02] 	:= (nRBMensal-nRBMesExp-nOtrasRec) * aFaixa[nX][07] / 100
				aPartilha[05][02] 	:= (nRBMensal-nRBMesExp-nOtrasRec) * aFaixa[nX][08] / 100
				aPartilha[06][02] 	:= (nBasICMS - nOtrasRec) 			* aFaixa[nX][09] / 100
				aPartilha[07][02] 	:= (nRBMensal-nRBMesExp-nOtrasRec) * aFaixa[nX][11] / 100
				aPartilha[08][02] 	:= (nRBMensal-nOtrasRec) 			* aFaixa[nX][12] / 100
				aPartilha[09][02] 	:= (nRBMensal-nOtrasRec) 			* aFaixa[nX][13] / 100
				aPartilha[10][02] 	:= (nRBMensal-nOtrasRec) 			* aFaixa[nX][14] / 100
				
				aPartilha[01][03] 	:= aFaixa[nX][04]
				aPartilha[02][03] 	:= aFaixa[nX][05]
				aPartilha[03][03] 	:= aFaixa[nX][06]
				aPartilha[04][03] 	:= aFaixa[nX][07]
				aPartilha[05][03] 	:= aFaixa[nX][08]
				aPartilha[06][03] 	:= aFaixa[nX][09]
				aPartilha[07][03] 	:= aFaixa[nX][11]
				aPartilha[08][03] 	:= aFaixa[nX][12]
				aPartilha[09][03] 	:= aFaixa[nX][13]
				aPartilha[10][03] 	:= aFaixa[nX][14]		
			Endif				
	 	Endif
	Next	
Endif
IF !Empty(nRBMensal)			
	nPerc := IIf(nAliqMax>0, nAliqMax, nAliq)
ELSE
	nPerc := 0
ENDIF

Return(nVlrDev)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³A924VDServ ³ Autor ³Andressa Fagundes      ³ Data ³26/02/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Calcula o Valor Devido (Valor a ser pago mensalmente)        ³±±
±±³          ³para as notas de servico                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A924VDServ(nRegTrib,nTotalRB,nRBMensal,aPartilhaS,nPercS,nRBServ,nRBServRet,nRBAnoCale,aServ)

Local aFaixa	:= {}

Local nX		:= 0
Local nVlrDevS	:= 0
Local nVlrIni	:= 0
Local nVlrFim	:= 0
Local nAliqS	:= 0 
Local nTPRecSN	:= Alltrim(Str(mv_par12))
Local nSeRecSN	:= mv_par13
Local nFaixaMax := 3600000   // limite maximo da faixa do Simples Nacional
Local nAliqMax := 0
Local nPos	:=	0
Local cTPRecServ	:= ""

Default aServ	:=	{}
Default nRBAnoCale	 := 0

aPartilhaS := {{"IRPJ",0,0},{"CSLL",0,0},{"Cofins",0,0},{"PIS/Pasep",0,0},{"INSS",0,0},{"ICMS",0,0},{"ISS",0,0},{"IPI",0,0},{"IRPJ, PIS/Pasep, Cofins e CSLL",0,0},{"CPP",0,0}}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tabela de Percentuais Aplicaveis       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aFaixa := A924LeCfg()

If	Alltrim(nTPRecSN) == '3'
	cTPRecServ	:= ""
	If Len(aFaixa) > 0
		For nX := 1 To Len(aFaixa)
			If	aFaixa[nx][11] > 0
				If	Empty(cTPRecServ)
					cTPRecServ :=	Alltrim(Str(aFaixa[nx][16]))
				Else
					cTPRecServ += "|" + Alltrim(Str(aFaixa[nx][16]))
				EndIf
			EndIf
		Next
	EndIf
	If Len(Alltrim(cTPRecServ)) > 0
		nTPRecSN	:=	cTPRecServ
	EndIf
EndIf

If Len(aFaixa) > 0
			
	// -------------------------------------------------------------------------------------------------
	// - Quando selecionar a opcao de segregar receitas, soh devera retornar os valores de Servico se o
	// - tipo de Receita selecionado for de Servicos.
	// -------------------------------------------------------------------------------------------------
	If ( nSeRecSN == 1 .Or. ( nSeRecSN == 2 .And. '3' $ Alltrim(nTPRecSN) ) )

		For nX := 1 To Len(aFaixa)
			If aFaixa[nX][11]<>0 .And. (IIf(Len(aFaixa[nX])>15 .And. Valtype(aFaixa[nX][15])<>"U" .And. nSeRecSN==2, Alltrim(Str(aFaixa[nX][16])) $ Alltrim(nTPRecSN),.T.))
				nVlrIni	:= aFaixa[nX][01]
				nVlrFim	:= aFaixa[nX][02]							
								
				If nTotalRB >= nVlrIni .And. nTotalRB <= nVlrFim 
					
					If (nPos := aScan (aServ,{|x| x[1] $ Iif(nSeRecSN == 1,"3",Alltrim(Str(aFaixa[nX][16])))})) <> 0
						nAliqS	:= aFaixa[nX][03]
						nVlrDevS += (((aServ[nPos][2]+aServ[nPos][3]) * nAliqS)/100)
						//Subtraio do valor devido o valor de ISS retido
						nVlrDevS :=	nVlrDevS - (aServ[nPos][3] * aFaixa[nX][11] / 100)
						
						//Adiciono a Aliquota utilizada.
						aAdd (aServ[nPos], nAliqS) 
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Divide o valor do Simples calculado pelos impostos abrangidos pela legislacao³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aPartilhaS[01][02] 	+= (aServ[nPos][2] + aServ[nPos][3]) * aFaixa[nX][04] / 100
						aPartilhaS[02][02] 	+= (aServ[nPos][2] + aServ[nPos][3]) * aFaixa[nX][05] / 100
						aPartilhaS[03][02] 	+= (aServ[nPos][2] + aServ[nPos][3]) * aFaixa[nX][06] / 100
						aPartilhaS[04][02] 	+= (aServ[nPos][2] + aServ[nPos][3]) * aFaixa[nX][07] / 100
						aPartilhaS[05][02] 	+= (aServ[nPos][2] + aServ[nPos][3]) * aFaixa[nX][08] / 100
						aPartilhaS[06][02] 	+= (aServ[nPos][2] + aServ[nPos][3]) * aFaixa[nX][09] / 100
						aPartilhaS[07][02] 	+=  aServ[nPos][2] * aFaixa[nX][11] / 100 //Nao calculo o valor de ISS para ISS Retido, apenas outros impostos
						aPartilhaS[08][02] 	+= (aServ[nPos][2] + aServ[nPos][3]) * aFaixa[nX][12] / 100
						aPartilhaS[09][02] 	+= (aServ[nPos][2] + aServ[nPos][3]) * aFaixa[nX][13] / 100
	 					aPartilhaS[10][02] 	+= (aServ[nPos][2] + aServ[nPos][3]) * aFaixa[nX][14] / 100
						aPartilhaS[01][03] 	+= aFaixa[nX][04]
						aPartilhaS[02][03] 	+= aFaixa[nX][05]
						aPartilhaS[03][03] 	+= aFaixa[nX][06]
						aPartilhaS[04][03] 	+= aFaixa[nX][07]
						aPartilhaS[05][03] 	+= aFaixa[nX][08]
						aPartilhaS[06][03] 	+= aFaixa[nX][09]
						aPartilhaS[07][03] 	+= aFaixa[nX][11]
						aPartilhaS[08][03] 	+= aFaixa[nX][12]
						aPartilhaS[09][03] 	+= aFaixa[nX][13]
						aPartilhaS[10][03] 	+= aFaixa[nX][14]

						nPercs := nAliqS
					EndIf
				ElseIf nTotalRB > nVlrFim .AND. nTotalRB > nFaixaMax  .And. nVlrFim == nFaixaMax
    				If (nPos := aScan (aServ,{|x| x[1] == Alltrim(Str(aFaixa[nX][16]))})) <> 0
    					nAliqs	:= aFaixa[nX][03]
						If nRBAnoCale > nFaixaMax  
							nAliqMax := (nAliqs * 1.2)	   			// aliquota maxima majorada em 20% 
							nVlrDevS := aServ[nPos][2] * (nAliqMax/100)
						Else
							nVlrDevs := aServ[nPos][2] * (nAliqS/100)
						EndIf
						
						//Adiciono a Aliquota utilizada.
						aAdd (aServ[nPos], nAliqS) 

						aPartilhaS[01][02] 	+= (aServ[nPos][2] + aServ[nPos][3]) * aFaixa[nX][04] / 100
						aPartilhaS[02][02] 	+= (aServ[nPos][2] + aServ[nPos][3]) * aFaixa[nX][05] / 100
						aPartilhaS[03][02] 	+= (aServ[nPos][2] + aServ[nPos][3]) * aFaixa[nX][06] / 100
						aPartilhaS[04][02] 	+= (aServ[nPos][2] + aServ[nPos][3]) * aFaixa[nX][07] / 100
						aPartilhaS[05][02] 	+= (aServ[nPos][2] + aServ[nPos][3]) * aFaixa[nX][08] / 100
						aPartilhaS[06][02] 	+= (aServ[nPos][2] + aServ[nPos][3]) * aFaixa[nX][09] / 100
						aPartilhaS[07][02] 	:=  aServ[nPos][2] * aFaixa[nX][11] / 100 //Nao calculo o valor de ISS para ISS Retido, apenas outros impostos
						aPartilhaS[08][02] 	+= (aServ[nPos][2] + aServ[nPos][3]) * aFaixa[nX][12] / 100
						aPartilhaS[09][02] 	+= (aServ[nPos][2] + aServ[nPos][3]) * aFaixa[nX][13] / 100
	 					aPartilhaS[10][02] 	+= (aServ[nPos][2] + aServ[nPos][3]) * aFaixa[nX][14] / 100
						aPartilhaS[01][03] 	:= aFaixa[nX][04]
						aPartilhaS[02][03] 	:= aFaixa[nX][05]
						aPartilhaS[03][03] 	:= aFaixa[nX][06]
						aPartilhaS[04][03] 	:= aFaixa[nX][07]
						aPartilhaS[05][03] 	:= aFaixa[nX][08]
						aPartilhaS[06][03] 	:= aFaixa[nX][09]
						aPartilhaS[07][03] 	:= aFaixa[nX][11]
						aPartilhaS[08][03] 	:= aFaixa[nX][12]
						aPartilhaS[09][03] 	:= aFaixa[nX][13]
						aPartilhaS[10][03] 	:= aFaixa[nX][14]
					
						nPercs := IIf(nAliqMax>0, nAliqMax, aFaixa[nX][03])
					EndIf	
				Endif
			Endif
		Next
	Endif	
Endif

Return(nVlrDevS)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³A924VDST ³ Autor ³Cleber Stenio            ³ Data ³08/01/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Calcula o Valor Devido (Valor a ser pago mensalmente)        ³±±
±±³          ³para as notas com ICMS-ST                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A924VDST(nRegTrib,nTotalRB,nRBMensal,aPartST,nPercST,nRBST,nGuiaSN)

Local aFaixa	:= {}

Local nX		:= 0
Local nVlDevST	:= 0
Local nVlrIni	:= 0
Local nVlrFim	:= 0
Local nAliqST	:= 0
Local cTPRecSN	:= mv_par12
Local nSeRecSN	:= mv_par13
Local nAliqGST 	:= 0

Default nGuiaSN := 0

aPartST := {{"IRPJ",0,0},{"CSLL",0,0},{"Cofins",0,0},{"PIS/Pasep",0,0},{"INSS",0,0},{"ICMS",0,0},{"ISS",0,0},{"IPI",0,0},{"IRPJ, PIS/Pasep, Cofins e CSLL",0,0},{"CPP",0,0}}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tabela de Percentuais Aplicaveis       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aFaixa := A924LeCfg()

If Len(aFaixa) > 0

	For nX := 1 To Len(aFaixa)
		cTPRecSN := IIf (Valtype(cTPRecSN) == "C",Val(cTPRecSN),cTPRecSN)
		If aFaixa[nX][15]==1 .And. (IIf (Len(aFaixa[nX]) > 15 .And. Valtype(aFaixa[nX][15]) <> "U" .And. nSeRecSN == 2,aFaixa[nX][16] == cTPRecSN,.T.))
			nVlrIni	:= aFaixa[nX][01]
			nVlrFim	:= aFaixa[nX][02]								
				
			If nTotalRB >= nVlrIni .And. nTotalRB <= nVlrFim
				nAliqST	:= aFaixa[nX][03]
				nAliqGST := aFaixa[nX][03]	
				nVlDevST := ((nRBST * nAliqST)/100)
					
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Divide o valor do Simples calculado pelos impostos abrangidos pela legislacao³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aPartST[01][02] 	:= nRBST * aFaixa[nX][04] / 100
				aPartST[02][02] 	:= nRBST * aFaixa[nX][05] / 100
				aPartST[03][02] 	:= nRBST * aFaixa[nX][06] / 100
				aPartST[04][02] 	:= nRBST * aFaixa[nX][07] / 100
				aPartST[05][02] 	:= nRBST * aFaixa[nX][08] / 100
				aPartST[06][02] 	:= nRBST * aFaixa[nX][09] / 100
				aPartST[07][02] 	:= nRBST * aFaixa[nX][11] / 100
				aPartST[08][02] 	:= nRBST * aFaixa[nX][12] / 100
				aPartST[09][02] 	:= nRBST * aFaixa[nX][13] / 100				
				aPartST[10][02] 	:= nRBST * aFaixa[nX][14] / 100
				aPartST[01][03] 	:= aFaixa[nX][04]
				aPartST[02][03] 	:= aFaixa[nX][05]
				aPartST[03][03] 	:= aFaixa[nX][06]
				aPartST[04][03] 	:= aFaixa[nX][07]            	
				aPartST[05][03] 	:= aFaixa[nX][08]
				aPartST[06][03] 	:= aFaixa[nX][09]
				aPartST[07][03] 	:= aFaixa[nX][11]
				aPartST[08][03] 	:= aFaixa[nX][12]
				aPartST[09][03] 	:= aFaixa[nX][13]
				aPartST[10][03] 	:= aFaixa[nX][14]
				Exit
			Endif
		Endif
	Next	
Endif
			
nGuiaSN := aPartST[06][02]				
nPercST := nAliqGST

Return(nVlDevST)  



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³A924VDLoc ³ Autor ³Erica E. Souza		     ³ Data ³19/11/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Calcula o Valor Devido (Valor a ser pago mensalmente)        ³±±
±±³          ³para as notas fiscais de locacao de bens moveis.             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A924VDLoc(nRegTrib,nTotalRB,nRBMensal,aPartilhaL,nPercL,nRBLoc,nRBAnoCale)


Local aFaixa	:= {}

Local nX		:= 0
Local nVlrDevL	:= 0
Local nVlrIni	:= 0
Local nVlrFim	:= 0
Local nAliqL	:= 0  
Local nTPRecSN	:= Alltrim(Str(mv_par12))
Local nSeRecSN	:= mv_par13
Local nFaixaMax := 3600000   // limite maximo da faixa do Simples Nacional
Local nAliqMax := 0
Local cTPRecServ := ""

Default nRBAnoCale := 0

aPartilhaL := {{"IRPJ",0,0},{"CSLL",0,0},{"Cofins",0,0},{"PIS/Pasep",0,0},{"INSS",0,0},{"ICMS",0,0},{"ISS",0,0},{"IPI",0,0},{"IRPJ, PIS/Pasep, Cofins e CSLL",0,0},{"CPP",0,0}}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tabela de Percentuais Aplicaveis       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aFaixa := A924LeCfg()

If	Alltrim(nTPRecSN) == '3'
	cTPRecServ	:= ""
	If Len(aFaixa) > 0
		For nX := 1 To Len(aFaixa)
			If	aFaixa[nx][11] > 0
				If	Empty(cTPRecServ)
					cTPRecServ :=	Alltrim(Str(aFaixa[nx][16]))
				Else
					cTPRecServ += "|" + Alltrim(Str(aFaixa[nx][16]))
				EndIf
			EndIf
		Next
	EndIf
	If Len(Alltrim(cTPRecServ)) > 0
		nTPRecSN	:=	cTPRecServ
	EndIf
EndIf

If Len(aFaixa) > 0

	For nX := 1 To Len(aFaixa)

		If (aFaixa[nx][09]==0) .And. (aFaixa[nX][10]==0) .And. (aFaixa[nX][13]==0) .And. (IIf(Len(aFaixa[nX])>15 .And. Valtype(aFaixa[nX][15])<>"U" .And. nSeRecSN==2, Alltrim(Str(aFaixa[nX][16])) $ Alltrim(nTPRecSN),.T.))
			nVlrIni	:= aFaixa[nX][01]
			nVlrFim	:= aFaixa[nX][02]							
							
			If nTotalRB >= nVlrIni .And. nTotalRB <= nVlrFim 
			
				nAliqL	:= aFaixa[nX][03]- aFaixa[nX][11]  //ALIQ
				nVlrDevL := ((nRBLoc * nAliqL)/100)
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Divide o valor do Simples calculado pelos impostos abrangidos pela legislacao³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aPartilhaL[01][02] 	:= nRBLoc * aFaixa[nX][04] / 100
				aPartilhaL[02][02] 	:= nRBLoc * aFaixa[nX][05] / 100
				aPartilhaL[03][02] 	:= nRBLoc * aFaixa[nX][06] / 100
				aPartilhaL[04][02] 	:= nRBLoc * aFaixa[nX][07] / 100
				aPartilhaL[05][02] 	:= nRBLoc * aFaixa[nX][08] / 100
				aPartilhaL[06][02] 	:= nRBLoc * aFaixa[nX][09] / 100
				aPartilhaL[07][02] 	:= nRBLoc * aFaixa[nX][11] / 100
				aPartilhaL[08][02] 	:= nRBLoc * aFaixa[nX][12] / 100
				aPartilhaL[09][02] 	:= nRBLoc * aFaixa[nX][13] / 100
				aPartilhaL[10][02] 	:= nRBLoc * aFaixa[nX][14] / 100
				aPartilhaL[01][03] 	:= aFaixa[nX][04]
				aPartilhaL[02][03] 	:= aFaixa[nX][05]
				aPartilhaL[03][03] 	:= aFaixa[nX][06]
				aPartilhaL[04][03] 	:= aFaixa[nX][07]
				aPartilhaL[05][03] 	:= aFaixa[nX][08]
				aPartilhaL[06][03] 	:= aFaixa[nX][09]
				aPartilhaL[07][03] 	:= aFaixa[nX][11]
				aPartilhaL[08][03] 	:= aFaixa[nX][12]
				aPartilhaL[09][03] 	:= aFaixa[nX][13]
				aPartilhaL[10][03] 	:= aFaixa[nX][14]
				Exit
			ElseIf nTotalRB > nVlrFim .AND. nTotalRB > nFaixaMax  .And. nVlrFim == nFaixaMax
    			nAliqL	:= aFaixa[nX][03]- aFaixa[nX][11]
				If nRBAnoCale > nFaixaMax  
					nAliqMax := (nAliqL * 1.2)	   			// aliquota maxima majorada em 20% 
					nVlrDevL := nRBLoc * (nAliqMax/100)    
				Else
					nVlrDevL := nRBLoc * (nAliqL/100)
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Divide o valor do Simples calculado pelos impostos abrangidos pela legislacao³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aPartilhaL[01][02] 	:= nRBLoc * aFaixa[nX][04] / 100
				aPartilhaL[02][02] 	:= nRBLoc * aFaixa[nX][05] / 100
				aPartilhaL[03][02] 	:= nRBLoc * aFaixa[nX][06] / 100
				aPartilhaL[04][02] 	:= nRBLoc * aFaixa[nX][07] / 100
				aPartilhaL[05][02] 	:= nRBLoc * aFaixa[nX][08] / 100
				aPartilhaL[06][02] 	:= nRBLoc * aFaixa[nX][09] / 100
				aPartilhaL[07][02] 	:= nRBLoc * aFaixa[nX][11] / 100
				aPartilhaL[08][02] 	:= nRBLoc * aFaixa[nX][12] / 100
				aPartilhaL[09][02] 	:= nRBLoc * aFaixa[nX][13] / 100
				aPartilhaL[10][02] 	:= nRBLoc * aFaixa[nX][14] / 100
				aPartilhaL[01][03] 	:= aFaixa[nX][04]
				aPartilhaL[02][03] 	:= aFaixa[nX][05]
				aPartilhaL[03][03] 	:= aFaixa[nX][06]
				aPartilhaL[04][03] 	:= aFaixa[nX][07]
				aPartilhaL[05][03] 	:= aFaixa[nX][08]
				aPartilhaL[06][03] 	:= aFaixa[nX][09]
				aPartilhaL[07][03] 	:= aFaixa[nX][11]
				aPartilhaL[08][03] 	:= aFaixa[nX][12]
				aPartilhaL[09][03] 	:= aFaixa[nX][13]
				aPartilhaL[10][03] 	:= aFaixa[nX][14]
			Endif
		Endif
	Next	
Endif

If nVlrDevL > 0
	nPercL:= nAliqL
Endif

Return(nVlrDevL)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³A924Tela   ³ Autor ³Mary C. Hergert        ³ Data ³30/07/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Apresenta as informacoes na Tela                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A924Tela(nRegTrib,dDataIni,dDataFim,nTotalRB,nVlrDev,nRBMensal,aConfApur,aPartilha,nPerc,nRBServ,nPercS,nVlrDevS,aPartilhaS,nRBST,nPercST,nVlDevST,aPartST,nRBLoc,nPercL,nVlrDevL,aPartilhaL,nRBServRet,nGuiaSN,nRBMesExp,nPercExp,cArqApur,aServ,lAutomato)

Local oDlg, oFont, oFont2
Local nSeRecSN	:= mv_par13
Local nTPRecSN	:= mv_par12
Local nRBMensal2 := (nRBMensal - nRBST - nRBMesExp - (A924ChkServ( nRBServ ) + A924ChkServ( nRBServRet )) )
Local lRBMensal2 := Empty(nRBMensal2)
Default aServ	:=	{}
Default lAutomato := .F.

DEFINE FONT oFont NAME "Arial" SIZE 0, -12 BOLD
DEFINE FONT oFont2 NAME "Arial" SIZE 0, -11
DEFINE FONT oFont3 NAME "Arial" SIZE 0, -11 BOLD
DEFINE FONT oFont4 NAME "Arial" SIZE 0, -12 

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0001) OF oMainWnd PIXEL FROM 0,0 TO 510,515		//Simples Nacional

@ 003, 005 TO 27, 253 OF oDlg PIXEL
@ 007, 010 SAY OemToAnsi (STR0005) FONT oFont  SIZE 180, 8 OF oDlg PIXEL		//Razao Social
@ 017, 010 SAY OemToAnsi (Upper (AllTrim (SM0->M0_NOMECOM))) FONT oFont2 SIZE 180, 8 OF oDlg PIXEL

@ 030, 005 TO 54, 253 OF oDlg PIXEL
@ 034, 010 SAY OemToAnsi (STR0006) FONT oFont SIZE 180, 8 OF oDlg PIXEL		//Regime Tributario
@ 044, 010 SAY OemToAnsi (IIf(nRegTrib==1,STR0008,STR0009)) FONT oFont2 SIZE 180, 8 OF oDlg PIXEL	//1=ME ou 2=EPP

@ 057, 005 TO 81, 253 OF oDlg PIXEL
@ 061, 010 SAY OemToAnsi (STR0010) FONT oFont SIZE 180, 8 OF oDlg PIXEL		//Periodo
@ 071, 010 SAY DtoC(dDataIni) + OemToAnsi(STR0011) + DtoC(dDataFim) FONT oFont2 SIZE 180, 8 OF oDlg PIXEL

@ 082, 005 TO 175, 253 OF oDlg PIXEL        
@ 086, 010 SAY OemToAnsi (STR0035) FONT oFont SIZE 180, 8 OF oDlg PIXEL		//Calculo do Simples
@ 096, 010 SAY OemToAnsi (STR0007) FONT oFont3 SIZE 180, 8 OF oDlg PIXEL		//Receita Bruta Acumulada
@ 096, 120 SAY Transform(nTotalRB,"@E 99999,999,999.99") FONT oFont2 SIZE 180, 8 OF oDlg PIXEL

@ 106, 010 SAY OemToAnsi (STR0013) FONT oFont3 SIZE 180, 8 OF oDlg PIXEL		//Receita Bruta Mensal - Nacional
@ 106, 120 SAY Transform(IIF(nTPRecSN==3,0,nRBMensal2),"@E 99999,999,999.99") FONT oFont2 SIZE 180, 8 OF oDlg PIXEL
@ 106, 164 SAY "x" FONT oFont2 SIZE 180, 8 OF oDlg PIXEL
@ 106, 175 SAY Transform(iif(lRBMensal2,0,nPerc),"@R 999.99%") FONT oFont2 SIZE 180, 8 OF oDlg PIXEL

@ 116, 010 SAY OemToAnsi (STR0082) FONT oFont3 SIZE 180, 8 OF oDlg PIXEL		//Receita Bruta Mensal - Exportacao
@ 116, 120 SAY Transform((nRBMesExp),"@E 99999,999,999.99") FONT oFont2 SIZE 180, 8 OF oDlg PIXEL
@ 116, 164 SAY "x" FONT oFont2 SIZE 180, 8 OF oDlg PIXEL
@ 116, 175 SAY Transform(nPercExp,"@R 999.99%") FONT oFont2 SIZE 180, 8 OF oDlg PIXEL

If	Len(aServ) > 1
	@ 126, 010 SAY OemToAnsi (STR0068) + " Tip.Rec. " + aServ[01][1] + ":" FONT oFont3 SIZE 180, 8 OF oDlg PIXEL //Receita Bruta Mensal - Serviços:
	@ 126, 120 SAY Transform(A924ChkServ( aServ[01][2] ) + A924ChkServ( aServ[01][3] ),"@E 99999,999,999.99") FONT oFont2 SIZE 180, 8 OF oDlg PIXEL
	@ 126, 164 SAY "x" FONT oFont2 SIZE 180, 8 OF oDlg PIXEL
	If Len(aServ[01]) > 3
		@ 126, 175 SAY Transform(aServ[01][4],"@R 999.99%") FONT oFont2 SIZE 180, 8 OF oDlg PIXEL
	EndIF
	@ 136, 010 SAY OemToAnsi (STR0068) + " Tip.Rec. " + aServ[02][1] + ":" FONT oFont3 SIZE 180, 8 OF oDlg PIXEL //Receita Bruta Mensal - Serviços Outra Tabela:
	@ 136, 120 SAY Transform(A924ChkServ( aServ[02][2] ) + A924ChkServ( aServ[02][3] ),"@E 99999,999,999.99") FONT oFont2 SIZE 180, 8 OF oDlg PIXEL
	@ 136, 164 SAY "x" FONT oFont2 SIZE 180, 8 OF oDlg PIXEL
	If Len(aServ[01]) > 3
		@ 136, 175 SAY Transform(aServ[02][4],"@R 999.99%") FONT oFont2 SIZE 180, 8 OF oDlg PIXEL
	EndIf
	@ 146, 010 SAY OemToAnsi (STR0070) FONT oFont3 SIZE 180, 8 OF oDlg PIXEL //Receita Bruta Mensal - ST:
	@ 146, 120 SAY Transform(nRBST,"@E 99999,999,999.99") FONT oFont2 SIZE 180, 8 OF oDlg PIXEL
	@ 146, 164 SAY "x" FONT oFont2 SIZE 180, 8 OF oDlg PIXEL
	@ 146, 175 SAY Transform(nPercST,"@R 999.99%") FONT oFont2 SIZE 180, 8 OF oDlg PIXEL

	@ 156, 010 SAY OemToAnsi (STR0073) FONT oFont3 SIZE 180, 8 OF oDlg PIXEL //Receita Bruta Mensal - Locacao de bens moveis:
	@ 156, 120 SAY Transform(nRBLoc,"@E 99999,999,999.99") FONT oFont2 SIZE 180, 8 OF oDlg PIXEL
	@ 156, 164 SAY "x" FONT oFont2 SIZE 180, 8 OF oDlg PIXEL
	@ 156, 175 SAY Transform(nPercL,"@R 999.99%") FONT oFont2 SIZE 180, 8 OF oDlg PIXEL 
	
	@ 159, 010 SAY "-----------------------------------------------------------------------------------------------------------------------" FONT oFont2 SIZE 180, 8 OF oDlg PIXEL
	
	@ 167, 010 SAY OemToAnsi (STR0012) FONT oFont3 SIZE 180, 8 OF oDlg PIXEL		//Valor Devido
	@ 167, 120 SAY Transform(nVlrDev+nVlrDevS+nVlDevST+nVlrDevL,"@E 99999,999,999.99") FONT oFont2 SIZE 180, 8 OF oDlg PIXEL  
Else 
	@ 128, 010 SAY OemToAnsi (STR0068) FONT oFont3 SIZE 180, 8 OF oDlg PIXEL //Receita Bruta Mensal - Serviços:
	@ 128, 114 SAY Transform(A924ChkServ( nRBServ ) + A924ChkServ( nRBServRet ),"@E 99999,999,999.99") FONT oFont2 SIZE 180, 8 OF oDlg PIXEL
	@ 128, 154 SAY "x" FONT oFont2 SIZE 180, 8 OF oDlg PIXEL
	@ 128, 169 SAY Transform(nPercS,"@R 999.99%") FONT oFont2 SIZE 180, 8 OF oDlg PIXEL

	@ 138, 010 SAY OemToAnsi (STR0070) FONT oFont3 SIZE 180, 8 OF oDlg PIXEL //Receita Bruta Mensal - ST:
	@ 138, 114 SAY Transform(nRBST,"@E 99999,999,999.99") FONT oFont2 SIZE 180, 8 OF oDlg PIXEL
	@ 138, 154 SAY "x" FONT oFont2 SIZE 180, 8 OF oDlg PIXEL
	@ 138, 169 SAY Transform(nPercST,"@R 999.99%") FONT oFont2 SIZE 180, 8 OF oDlg PIXEL

	@ 148, 010 SAY OemToAnsi (STR0073) FONT oFont3 SIZE 180, 8 OF oDlg PIXEL //Receita Bruta Mensal - Locacao de bens moveis:
	@ 148, 114 SAY Transform(nRBLoc,"@E 99999,999,999.99") FONT oFont2 SIZE 180, 8 OF oDlg PIXEL
	@ 148, 154 SAY "x" FONT oFont2 SIZE 180, 8 OF oDlg PIXEL
	@ 148, 169 SAY Transform(nPercL,"@R 999.99%") FONT oFont2 SIZE 180, 8 OF oDlg PIXEL 

	@ 158, 010 SAY OemToAnsi (STR0012) FONT oFont3 SIZE 180, 8 OF oDlg PIXEL		//Valor Devido
	@ 158, 114 SAY Transform(nVlrDev+nVlrDevS+nVlDevST+nVlrDevL,"@E 99999,999,999.99") FONT oFont2 SIZE 180, 8 OF oDlg PIXEL  
EndIf
 
@ 176, 005 TO 239, 253 OF oDlg PIXEL
@ 177, 010 SAY OemToAnsi (STR0034) FONT oFont SIZE 180, 8 OF oDlg PIXEL		//Partilha pelos tributos:

@ 186, 010 SAY OemToAnsi (STR0026)+ ":" FONT oFont3 SIZE 180, 8 OF oDlg PIXEL		//IRPJ:
@ 186, 074 SAY Transform((aPartilha[01][02]+aPartilhaS[01][02]+aPartST[01][02]+aPartilhaL[01][02]),"@E 99999,999,999.99") FONT oFont2 SIZE 180, 8 OF oDlg PIXEL
@ 186, 140 SAY OemToAnsi (STR0028)+ ":" FONT oFont3 SIZE 180, 8 OF oDlg PIXEL		//CSLL:
@ 186, 204 SAY Transform((aPartilha[02][02]+aPartilhaS[02][02]+aPartST[02][02]+aPartilhaL[02][02]),"@E 99999,999,999.99") FONT oFont2 SIZE 180, 8 OF oDlg PIXEL

@ 195, 010 SAY OemToAnsi (STR0029)+ ":" FONT oFont3 SIZE 180, 8 OF oDlg PIXEL		//Cofins:
@ 195, 074 SAY Transform((aPartilha[03][02]+aPartilhaS[03][02]+aPartST[03][02]+aPartilhaL[03][02]),"@E 99999,999,999.99") FONT oFont2 SIZE 180, 8 OF oDlg PIXEL
@ 195, 140 SAY OemToAnsi (STR0030)+ ":" FONT oFont3 SIZE 180, 8 OF oDlg PIXEL		//PIS/Pasep:
@ 195, 204 SAY Transform((aPartilha[04][02]+aPartilhaS[04][02]+aPartST[04][02]+aPartilhaL[04][02]),"@E 99999,999,999.99") FONT oFont2 SIZE 180, 8 OF oDlg PIXEL

@ 204, 010 SAY OemToAnsi (STR0031)+ ":" FONT oFont3 SIZE 180, 8 OF oDlg PIXEL		//INSS.:
@ 204, 074 SAY Transform((aPartilha[05][02]+aPartilhaS[05][02]+aPartST[05][02]+aPartilhaL[05][02]),"@E 99999,999,999.99") FONT oFont2 SIZE 180, 8 OF oDlg PIXEL
@ 204, 140 SAY OemToAnsi (STR0032)+ ":" FONT oFont3 SIZE 180, 8 OF oDlg PIXEL		//ICMS:
@ 204, 204 SAY Transform((aPartilha[06][02]+aPartilhaS[06][02]+aPartST[06][02]+aPartilhaL[06][02]),"@E 99999,999,999.99") FONT oFont2 SIZE 180, 8 OF oDlg PIXEL

@ 213, 010 SAY OemToAnsi (STR0033)+ ":" FONT oFont3 SIZE 180, 8 OF oDlg PIXEL		//ISS:
@ 213, 074 SAY Transform((aPartilhaS[07][02]),"@E 99999,999,999.99") FONT oFont2 SIZE 180, 8 OF oDlg PIXEL
@ 213, 140 SAY OemToAnsi (STR0027)+ ":" FONT oFont3 SIZE 180, 8 OF oDlg PIXEL		//IPI:
@ 213, 204 SAY Transform((aPartilha[08][02]+aPartilhaS[08][02]+aPartST[08][02]+aPartilhaL[08][02]),"@E 99999,999,999.99") FONT oFont2 SIZE 180, 8 OF oDlg PIXEL

@ 222, 010 SAY OemToAnsi (STR0056)+ ":" FONT oFont3 SIZE 180, 8 OF oDlg PIXEL		//"IRPJ/PIS/COF/CS"
@ 222, 074 SAY Transform((aPartilha[09][02]+aPartilhaS[09][02]+aPartST[09][02]+aPartilhaL[09][02]),"@E 99999,999,999.99") FONT oFont2 SIZE 180, 8 OF oDlg PIXEL

@ 230, 010 SAY OemToAnsi (STR0081)+ ":" FONT oFont3 SIZE 180, 8 OF oDlg PIXEL		//"CPP"
@ 230, 074 SAY Transform((aPartilha[10][02]+aPartilhaS[10][02]+aPartST[10][02]+aPartilhaL[10][02]),"@E 99999,999,999.99") FONT oFont2 SIZE 180, 8 OF oDlg PIXEL

DEFINE SBUTTON FROM 240, 130 TYPE 1 ACTION (A924ConfAp(aConfApur,aPartilha,aPartilhaS,aPartST,aPartilhaL,cArqApur),oDlg:End()) ENABLE OF oDlg PIXEL
DEFINE SBUTTON FROM 240, 160 TYPE 2 ACTION (oDlg:End()) ENABLE OF oDlg PIXEL
DEFINE SBUTTON FROM 240, 230 TYPE 6 ACTION (A924Print(nTotalRB,nVlrDev,nRegTrib,dDataIni,dDataFim,nRBMensal,nPerc,aPartilha,nRBServ,nVlrDevS,nPercS,aPartilhaS,nRBST,nVlDevST,nPercST,aPartST,nRBLoc,nPercL,nVlrDevL,aPartilhaL,nRBMesExp,nPercExp)) ENABLE OF oDlg PIXEL

If !lAutomato
	ACTIVATE MSDIALOG oDlg CENTERED
Else
	A924ConfAp(aConfApur,aPartilha,aPartilhaS,aPartST,aPartilhaL,cArqApur,lAutomato)                  
EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³A924Atu    ³ Autor ³Mary C. Hergert        ³ Data ³30/07/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Atualiza os calculos do Simples Nacional                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/								
Static Function A924Atu(nTotalRB,nVlrDev,nRegTrib,dDataIni,dDataFim,nRBMensal,aConfApur,aPartilha,nPerc,aPartilhaS,nPercS,nVlrDevS,nRBServ,nPercST,nVlDevST,nRBST,aPartST,nRBLoc,nVlrDevL,nPercL,aPartilhaL,nRBServRet,nGuiaSN)

Local cFilIni	:= mv_par10
Local cFilFin	:= mv_par11
Local cAlerta   := ""
Local cArqAnt	:= ""
Local cTPRecServ := ""

Local dDtRecIni	:= Ctod("")
Local dDtRecFim	:= Ctod("")                                                    

Local lProcFil	:= (mv_par09==1)
Local lRet      := .T.

Local nRB		:= 0
Local nRBAnoCale:= 0
Local nTribMax	:= 0 
Local cTPRecSN	:= Alltrim(Str(mv_par12))
Local nSeRecSN	:= mv_par13
Local nX		:= 0
Local nTribRec	:= 0
Local nRBAnt	:= 0

Default nRBLoc		:= 0
Default nPercL 		:= 0
Default aPartilhaL  := 0
Default nGuiaSN 	:= 0     

nRegTrib		:= mv_par01		//Regime de Tributacao: 1=ME ou 2=EPP
dDataIni		:= mv_par02		//Data Inicial
dDataFim		:= mv_par03		//Data Final 

If	Alltrim(cTPRecSN) == '3'
	cTPRecServ	:= ""
	aFaixa	:= A924LeCfg()
	If Len(aFaixa) > 0
		For nX := 1 To Len(aFaixa)
			If	aFaixa[nx][11] > 0
				If	Empty(cTPRecServ)
					cTPRecServ := "'" + Alltrim(Str(aFaixa[nx][16])) + "'"
				Else
					cTPRecServ += ",'" + Alltrim(Str(aFaixa[nx][16])) + "'"
				EndIf
			EndIf
		Next
	EndIf
	If Len(Alltrim(cTPRecServ)) > 0
		cTPRecSN	:=	cTPRecServ
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calcula o Total de Receita Bruta                                   ³
//³Para o calculo do Simples Nacional, devera ser verificada a receita³
//³bruta nos ultimos 12 meses anteriores ao periodo de apuracao.      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
A924DtRec(dDataIni,@dDtRecIni,@dDtRecFim)
//ARQUIVO MES ANTERIOR
cArqAnt := NmArqApur(cImp,nAnoAnt,nMesAnt,nApuracao,nPeriodo,cNrLivro)
IF MV_PAR14 == 1	// Regime de Competencia                               
	nTotalRB 	:= CalcRB(dDtRecIni,dDtRecFim,,,,,lProcFil,cFilIni,cFilFin,,,.T.,,cTPRecSN,nSeRecSN,, dDtIni, dDtFim)                 
	nRBAnoCale	:= CalcRB(CtoD("01/01/"+StrZero(Year(dDataIni),4)),dDataFim,,,,,lProcFil,cFilIni,cFilFin,,,.T.,,cTPRecSN,nSeRecSN,, dDtIni, dDtFim)
	nRB			:= CalcRB(dDataIni,dDataFim,@nRBMensal,.T.,,,lProcFil,cFilIni,cFilFin,@nRBServ,@nRBST,.T.,@nRBLoc,cTPRecSN,nSeRecSN,@nRBServRet, dDtIni, dDtFim,,,@aServ)
Else
	nTotalRB 	:= RegCaixa(dDtRecIni,dDtRecFim,,,lProcFil,cFilIni,cFilFin,,,,)
	nRBAnoCale	:= RegCaixa(CtoD("01/01/"+StrZero(Year(dDataIni),4)),dDataFim,,,lProcFil,cFilIni,cFilFin,,,)
	nRB			:= RegCaixa(dDataIni,dDataFim,@nRBMensal,.T.,lProcFil,cFilIni,cFilFin,@nRBServ,@nRBST,@nRBLoc,@nRBServRet)    
EndIf	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o valor da receita bruta anual nao ultrapassou a ultima faixa configurada.³
//³Se ultrapassar, o calculo nao sera efetuado - a empresa sera desenquadrada do Simples.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aFaixa		:= A924LeCfg()
	nRBAnt		:= A924LeArqAnt(cArqAnt)
	If Len(aFaixa) > 0 .And. nSeRecSN == 2	
		For nX := 1 To Len(aFaixa)
		   	If (Len(aFaixa[nX]) > 15 .And. Valtype(aFaixa[nX][15]) <> "U" .And. nSeRecSN == 2)
		   		If	Str(Alltrim(aFaixa[nX][16])) $ Alltrim(cTPRecSN)
			   		nTribRec	:= aFaixa[nX][02]
				EndIf
			EndIf   	
		Next
		If Len(aFaixa) > 0
			nTribRec	:= aFaixa[Len(aFaixa)][02]
			nTribRec 	+= (nTribRec * 0.20)			
			If nRBAnoCale > nTribRec .And. nRBAnt > nTribRec 
				cAlerta := "A soma da Receita Bruta do Ano calendário do Contribuinte " + chr(13)
		        cAlerta += "(" + Alltrim(Transform(nRBAnoCale,"@E 99999,999,999.99")) + ") " + chr(13)
		        cAlerta += "Excedeu a 20% do Limite Máximo de (" + Alltrim(Transform(aFaixa[Len(aFaixa)][02],"@E 99999,999,999.99")) + ") " + chr(13)
		        cAlerta += " do Simples Nacional, a Empresa não está enquadrada ao Simples Nacional"
				Aviso("A924Limite", cAlerta ,{"Ok"})
		        lRet := .F.
			Endif
		Endif 
	Elseif Len(aFaixa) > 0
		nTribMax	:= aFaixa[Len(aFaixa)][02]
		nTribMax 	+= nTribMax * 0.20
		If nRBAnoCale > nTribMax .And. nRBAnt > nTribMax
			cAlerta := "A soma da Receita Bruta do Ano calendário do Contribuinte " + chr(13)
			cAlerta += "(" + Alltrim(Transform(nRBAnoCale,"@E 99999,999,999.99")) + ") " + chr(13)
			cAlerta += "Excedeu a 20% do Limite Máximo de (" + Alltrim(Transform(aFaixa[Len(aFaixa)][02],"@E 99999,999,999.99")) + ") " + chr(13)
			cAlerta += " do Simples Nacional, a Empresa não está enquadrada ao Simples Nacional"
			Aviso("A924Limite", cAlerta ,{"Ok"})
			lRet := .F.
		Endif
	Endif				
If lRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Recalcula o valor devido - Comercio    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nVlrDev := A924CalcVD(nRegTrib,nTotalRB,nRBMensal,@aPartilha,@nPerc,@nRBServ,@nRBST,@nRBLoc,,,nRBAnoCale,nRBServRet)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Recalcula o valor devido - Servico     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nVlrDevS := A924VDServ(nRegTrib,nTotalRB,nRBMensal,@aPartilhaS,@nPercS,@nRBServ,nRBServRet,,aServ)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula o Valor Devido - ST   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nVlDevST := A924VDST(nRegTrib,nTotalRB,nRBMensal,@aPartST,@nPercST,@nRBST)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Recalcula o valor devido - Locacao     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nVlrDevL := A924VDLoc(nRegTrib,nTotalRB,nRBMensal,@aPartilhaL,@nPercL,@nRBLoc)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualizando os valores do array aGetApur para gravar no arquivo texto³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	A924Refr(nTotalRB,nRBMensal,nVlrDev,nRBServ,nVlrDevS,nRBST,nVlDevST,nRBLoc,nVlrDevL,nRBServRet)     

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Apresentacao das Informacoes na Tela                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	A924Tela(nRegTrib,dDataIni,dDataFim,nTotalRB,nVlrDev,nRBMensal,@aConfApur,aPartilha,nPerc,@nRBServ,nPercS,nVlrDevS,aPartilhaS,@nRBST,nPercST,nVlDevST,aPartST,nRBLoc,nPercL,nVlrDevL,aPartilhaL,nRBServRet,nGuiaSN,,,,aServ)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualizando valores da apuracao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aConfApur[02] := nVlrDev
	aConfApur[19] := nVlrDev
	aConfApur[20] := nVlrDevS
	aConfApur[21] := nVlDevST
	aConfApur[22] := nVlrDevL
	AADD(aConfApur,nGuiaSN)
	
EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³A924Print  ³ Autor ³Mary C. Hergert        ³ Data ³30/07/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Imprime as informacoes do Simples Nacional                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A924Print(nTotalRB,nVlrDev,nRegTrib,dDataIni,dDataFim,nRBMensal,nAliq,aPartilha,nRBServ,nVlrDevS,nAliqS,aPartilhaS,nRBST,nVlDevST,nAliqST,aPartST,nRBLoc,nVlrDevL,nAliqL,aPartilhaL,nRBMesExp,nPercExp)

Local cTitulo	:= STR0002				// Impressao das informacoes do Simples Nacional
Local lDic     	:= .F. 					// Habilita/Desabilita Dicionario      
Local lComp    	:= .T. 					// Habilita/Desabilita o Formato Comprimido/Expandido
Local lFiltro  	:= .F. 					// Habilita/Desabilita o Filtro
Local wnrel    	:= "MATA924"  			// Nome do Arquivo utilizado no Spool
Local nomeprog 	:= "MATA924"  			// nome do programa         
Local cString	:= "SF2"

Private Tamanho := "G"					// P/M/G
Private Limite  := 220 	   				// 80/132/220
Private aOrdem  := {}  					// Ordem do Relatorio
Private aReturn := {"Zebrado",1,"Adminis",1,2,1,"",1}	

Private lEnd    := .F.					// Controle de cancelamento do relatorio
Private m_pag   := 1  					// Contador de Paginas
Private nLastKey:= 0  					// Controla o cancelamento da SetPrint e SetDefault       

Default nRBLoc 		:=0
Default nVlrDevL	:=0
Default nAliql 		:=0
Default aPartilhaL 	:=0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Envia para a SetPrint                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := SetPrint("",wnrel,"",@ctitulo,"","","",lDic,aOrdem,lComp,Tamanho,lFiltro)
If ( nLastKey==27 )
	dbSelectArea(cString)
	dbSetOrder(1)
	dbClearFilter()
	Return
Endif
SetDefault(aReturn,cString)
If ( nLastKey==27 )
	dbSelectArea(cString)
	dbSetOrder(1)
	dbClearFilter()
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprime o relatorio³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RptStatus({|lEnd| A924ImpDet(nTotalRB,nVlrDev,nRegTrib,dDataIni,dDataFim,nRBMensal,nAliq,aPartilha,nRBServ,nVlrDevS,nAliqS,aPartilhaS,nRBST,nVlDevST,nAliqST,aPartST,nRBLoc,nVlrDevL,nAliqL,aPartilhaL,nRBMesExp,nPercExp)},cTitulo)

dbSelectArea(cString)
dbClearFilter()
Set Device To Screen
Set Printer To

If (aReturn[5] = 1)
	dbCommitAll()
	OurSpool(wnrel)
Endif
MS_FLUSH()

Return .T. 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³A924ImpDet ³ Autor ³Mary C. Hergert        ³ Data ³ 20.06.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Impressao detalhes do relatorio                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A924ImpDet(nTotalRB,nVlrDev,nRegTrib,dDataIni,dDataFim,nRBMensal,nAliq,aPartilha,nRBServ,nVlrDevS,nAliqS,aPartilhaS,nRBST,nVlDevST,nAliqST,aPartST,nRBLoc,nAliqL,nVlrDevL,aPartilhaL,nRBMesExp,nPercExp)

Local nLinha	:= Cabec(OemToAnsi(STR0001),"","","MATA924","G",18) + 1
Local aLay		:= A924LayOut()
Local nX		:= 0
Local aFaixa	:= {}
Local nVlMesExp := nRBMesExp * nPercExp / 100   
                                 
Default nRBLoc 		:=0
Default nVlrDevL	:=0
Default nAliql 		:=0
Default aPartilhaL 	:=0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tabela de Percentuais Aplicaveis       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aFaixa := A924LeCfg()

FmtLin({},aLay[01],,,@nLinha)
FmtLin({},aLay[02],,,@nLinha)
FmtLin({AllTrim(SM0->M0_NOMECOM)},aLay[03],,,@nLinha)                              

FmtLin({},aLay[01],,,@nLinha)
FmtLin({},aLay[04],,,@nLinha)                              
FmtLin({OemToAnsi(IIf(nRegTrib==1,STR0008,STR0009))},aLay[05],,,@nLinha)

FmtLin({},aLay[01],,,@nLinha)
FmtLin({},aLay[06],,,@nLinha)
FmtLin({DtoC(dDataIni) + " à " + DtoC(dDataFim)},aLay[07],,,@nLinha)

FmtLin({},aLay[01],,,@nLinha)
FmtLin({},aLay[08],,,@nLinha)                              
FmtLin({TransForm(nTotalRB,"@E 99,999,999,999.99"),TransForm((nRBMensal-nRBMesExp-nRBServ-nRBST-nRBLoc),"@E 99,999,999,999.99"),TransForm(nAliq,"@R 999.99 %"),TransForm(nRBST,"@E 99,999,999,999.99"),TransForm(nAliqST,"@R 999.99 %"),TransForm((nVlrDev+nVlDevST-nVlMesExp),"@E 99,999,999,999.99")},aLay[09],,,@nLinha)

FmtLin({},aLay[01],,,@nLinha)
FmtLin({},aLay[24],,,@nLinha)                              
FmtLin({TransForm(nTotalRB,"@E 99,999,999,999.99"),TransForm(nRBMesExp,"@E 99,999,999,999.99"),TransForm(nPercExp,"@R 999.99 %"),TransForm(nVlMesExp,"@E 99,999,999,999.99")},aLay[25],,,@nLinha)

FmtLin({},aLay[01],,,@nLinha)
FmtLin({},aLay[19],,,@nLinha)                              
FmtLin({TransForm(nTotalRB,"@E 99,999,999,999.99"),TransForm(nRBServ,"@E 99,999,999,999.99"),TransForm(nAliqS,"@R 999.99 %"),TransForm(nVlrDevS,"@E 99,999,999,999.99")},aLay[20],,,@nLinha)

FmtLin({},aLay[01],,,@nLinha)
FmtLin({},aLay[21],,,@nLinha)                              
FmtLin({TransForm(nTotalRB,"@E 99,999,999,999.99"),TransForm(nRBLoc,"@E 99,999,999,999.99"),TransForm(nAliqL,"@R 999.99 %"),TransForm(nVlrDevL,"@E 99,999,999,999.99")},aLay[22],,,@nLinha)

FmtLin({},aLay[01],,,@nLinha)                            
FmtLin({TransForm((nVlrDev+nVlDevST+nVlrDevS+nVlrDevL),"@E 99,999,999,999.99")},aLay[23],,,@nLinha)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprimindo a partilha pelos impostos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FmtLin({},aLay[01],,,@nLinha)
FmtLin({},aLay[10],,,@nLinha)
FmtLin({TransForm((aPartilha[01][02]+aPartilhaS[01][02]+aPartilhaL[01][02]),"@E 9,999,999.99"),;
		TransForm((aPartilha[02][02]+aPartilhaS[02][02]+aPartilhaL[02][02]),"@E 9,999,999.99"),;
		TransForm((aPartilha[03][02]+aPartilhaS[03][02]+aPartilhaL[03][02]),"@E 9,999,999.99"),;
		TransForm((aPartilha[04][02]+aPartilhaS[04][02]+aPartilhaL[04][02]),"@E 9,999,999.99");
		},aLay[11],,,@nLinha)
FmtLin({TransForm((aPartilha[05][02]+aPartilhaS[05][02]+aPartilhaL[05][02]),"@E 9,999,999.99"),;
		TransForm((aPartilha[06][02]+nVlDevST+aPartilhaS[06][02]+aPartilhaL[06][02]),"@E 9,999,999.99"),;
		TransForm((aPartilha[07][02]+aPartilhaS[07][02]+aPartilhaL[07][02]),"@E 9,999,999.99"),;
		TransForm((aPartilha[08][02]+aPartilhaS[08][02]+aPartilhaL[08][02]),"@E 9,999,999.99");
		},aLay[12],,,@nLinha)
FmtLin({TransForm((aPartilha[09][02]+aPartilhaS[09][02]+aPartilhaL[09][02]),"@E 9,999,999.99"),;
		TransForm((aPartilha[10][02]+aPartilhaS[10][02]+aPartilhaL[10][02]),"@E 9,999,999.99");  
   		},aLay[18],,,@nLinha)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprime os Percentuais Aplicaveis                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FmtLin({},aLay[01],,,@nLinha) 
FmtLin({},aLay[13],,,@nLinha)
FmtLin({},aLay[14],,,@nLinha)
FmtLin({},aLay[15],,,@nLinha)
FmtLin({},aLay[16],,,@nLinha)
For nX := 1 To Len(aFaixa)
	FmtLin({TransForm(aFaixa[nX][01],"@E 9,999,999.99"),;
			TransForm(aFaixa[nX][02],"@E 9,999,999.99"),;
			Iif(aFaixa[nX][13]==1,"S","N"),;
			TransForm(aFaixa[nX][03],"@R 999.99 %"),;
			TransForm(aFaixa[nX][04],"@R 999.99 %"),;
			TransForm(aFaixa[nX][05],"@R 999.99 %"),;
			TransForm(aFaixa[nX][06],"@R 999.99 %"),;
			TransForm(aFaixa[nX][07],"@R 999.99 %"),;
			TransForm(aFaixa[nX][08],"@R 999.99 %"),;
			TransForm(aFaixa[nX][09],"@R 999.99 %"),;
			TransForm(aFaixa[nX][10],"@R 999.99 %"),;
			TransForm(aFaixa[nX][11],"@R 999.99 %"),;
			TransForm(aFaixa[nX][12],"@R 999.99 %"),;
			TransForm(aFaixa[nX][13],"@R 999.99 %"),;
			TransForm(aFaixa[nX][14],"@R 999.99 %")},aLay[17],,,@nLinha)
Next                          
FmtLin({},aLay[14],,,@nLinha)

Return Nil
                                                                                               
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A924LayOut| Autor ³ Mary C. Hergert       ³ Data ³ 20.06.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna o LayOut a ser impresso                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A924LayOut()

Local aLay := Array(25)
                                     
aLay[01] := OemToAnsi(STR0037) //+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
aLay[02] := OemToAnsi(STR0038) //| Razao Social:                                                                                                                                                                                                      |"
aLay[03] := OemToAnsi(STR0039) //| ###########################################################################                                                                                                                                        |"
aLay[04] := OemToAnsi(STR0040) //| Regime de Tributacao:                                                                                                                                                                                              |"
aLay[05] := OemToAnsi(STR0041) //| ###########################################################################                                                                                                                                        |"
aLay[06] := OemToAnsi(STR0042) //| Periodo:                                                                                                                                                                                                           |"
aLay[07] := OemToAnsi(STR0043) //| ###################                                                                                                                                                                                                |"
aLay[08] := OemToAnsi(STR0044) //| Receita Bruta Acumulada:      Receita Bruta Mensal-Nac:   Aliq. Aplicada:                                                                    Receita Bruta Mensal-ST:    Aliq. Aplicada- ST:        Valor Devido:  |"
aLay[09] := OemToAnsi(STR0045) //|        #################          #################             ########                                                                            #################               ########    #################  |"
aLay[24] := OemToAnsi(STR0083) //| Receita Bruta Acumulada:      Receita Bruta Mensal-Exp:   Aliq. Aplicada:                                                                                                                           Valor Devido   |"
aLay[25] := OemToAnsi(STR0084) //|        #################          #################              #######                                                                                                                        #################  |"
aLay[19] := OemToAnsi(STR0071) //| Receita Bruta Acumulada:      Receita Bruta Mensal-Serviços:                 Aliq. Aplicada - Serviços:                                                                                             Valor Devido   |"
aLay[20] := OemToAnsi(STR0072) //|        #################          ################                                            #######                                                                                           #################  |"
aLay[21] := OemToAnsi(STR0074) //| Receita Bruta Acumulada:      Receita Bruta Mensal-Locacao:                  Aliq. Aplicada - Locacao de bens moveis:                                                                               Valor Devido   |"
aLay[22] := OemToAnsi(STR0075) //|        #################          #################                                                        ##########                                                                           #################  |"
aLay[23] := OemToAnsi(STR0076) //| Total Valor Devido:                                                                                                                                                                             #################  |"
aLay[10] := OemToAnsi(STR0046) //| Partilha pelos Tributos:                                                                                                                                                                                           |"
aLay[11] := OemToAnsi(STR0047) //| IRPJ   :   ############                    CSLL   :   ############                    Cofins     ########:   ############                    PIS/Pasep   :    ############                                         |"
aLay[12] := OemToAnsi(STR0048) //| INSS   :   ############                    ICMS   :   ############                    ISS        ########:   ############                    IPI         :    ############                                         |"
aLay[13] := OemToAnsi(STR0050) //| Percentuais Aplicaveis:                                                                                                                                                                                            |"
aLay[14] := OemToAnsi(STR0051) //"+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
aLay[15] := OemToAnsi(STR0052) //"| Faixa inicial | Faixa final  | C/ICMS-ST |  Aliquota  |   IRPJ     |    CSLL    |   Cofins   |  PIS/Pasep  |    INSS     |    ICMS     |  RED ICMS  |     ISS      |    IPI      |  IRPJ/PIS/COF/CS  |    CPP      |"
aLay[16] := OemToAnsi(STR0053) //"|---------------+--------------+-----------+------------+------------+------------+------------+-------------+-------------+-------------+------------+--------------+-------------+-------------------+-------------+"
aLay[17] := OemToAnsi(STR0054) //"| ############  | ############ |     #     |  ########  |  ########  |  ########  |  ########  |   ########  |  ########   |  ########   |  ########  |    ########  |   ########  |     ########      |  ########   |"
aLay[18] := OemToAnsi(STR0057) //"| IR/PIS/COF/CS  :  ############                    CPP    :  ############                                                                                                                                                                          |"

Return(aLay)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³A924ConfAp ³ Autor ³Mary C. Hergert        ³ Data ³ 03.01.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Efetua a gravacao da apuracao/titulo/lancto. contabil        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A924ConfAp(aConfApur,aPartilha,aPartilhaS,aPartST,aPartilhaL,cArqApur,lAutomato) 

Local aGnre		:= {}

Local cImposto	:= aConfApur[03]
Local cImp		:= aConfApur[04]
Local cLcPadTit	:= aConfApur[05]
Local cProgram	:= aConfApur[12]
Local cNrLivro	:= aConfApur[16]                                
Local cOrgArrec	:= aConfApur[17] 
Local cNumero	:= ""

Local dDtIni	:= aConfApur[06]
Local dDtFim	:= aConfApur[07]
Local dDtVenc	:= aConfApur[08]

Local lTitulo	:= aConfApur[01]
Local lLancCont	:= aConfApur[13]                   
Local lGuiaRec	:= aConfApur[18]

Local nVlrDev	:= aConfApur[02]
Local nMoeda	:= aConfApur[09]
Local nMes		:= aConfApur[10]
Local nAno		:= aConfApur[11]
Local nApuracao	:= aConfApur[14]
Local nPeriodo	:= aConfApur[15]
Local nValICMS	:= aConfApur[19]
Local nVlrDevS	:= aConfApur[20]
Local nVlDevST	:= aConfApur[21]
Local nVlrDevL  := aConfApur[22]
Local nX		:= 0
Local nGuiaSN	:= aConfApur[23]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gera o titulo a pagar com o valor devido calculado pelo SIMPLES.            ³
//³Para gerar o lancamento contabil, foram gerados os seguintes codigos padrão:³
//³770 - para a apuracao do Simples Nacional                                   ³
//³771 - para o estorno da apuracao do Simples Nacional                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lTitulo .And. ((nVlrDev+nVlrDevS+nVlDevST+nVlrDevL)  > 0 .Or. nGuiaSN > 0)
	GravaTit(lTitulo,(nVlrDev+nVlrDevS+nVlDevST),cImposto,cImp,cLcPadTit,dDtIni,dDtFim,dDtVenc,nMoeda,lGuiaRec,nMes,nAno,(nValICMS+nVlrDevS+nVlDevST),0,cProgram,lLancCont,@cNumero,@aGnre,,,,,,,,,,,,,,,,nGuiaSN,,,,,,,,lAutomato)
	AADD(aGetApur,{"TIT",cNumero+" "+Dtoc(dDtVenc)+" "+cOrgArrec,(nVlrDev+nVlrDevS+nVlDevST+nVlrDevL)})
Endif

For nX := 1 to Len(aGnre)
	AADD(aGetApur,{Padr("GNRE "+Alltrim(aGnre[nX][01])+" "+Dtoc(aGnre[nX][02]),20),"",aGnre[nX][03]})
Next

For nX := 1 to Len(aPartilha)
	AADD(aGetApur,{Padr(aPartilha[nX][01],20),"",(aPartilha[nX][02]+aPartilhaS[nX][02]+aPartST[nX][02]+aPartilhaL[nX][02])})
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Grava o arquivo de apuracao gerado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
GravaApu(cImp,nAno,nMes,nApuracao,nPeriodo,cNrLivro,dDtIni,dDtFim,nMoeda,,cArqApur)

DumpFile(2,,cArqApur)

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³A924Refr   ³ Autor ³Mary C. Hergert        ³ Data ³ 04.01.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Atualiza valores que serao gravados no arquivo texto.        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A924Refr(nTotalRB,nRBMensal,nVlrDev,nRBServ,nVlrDevS,nRBST,nVlDevST,nRBLoc,nVlrDevL,nRBServRet) 

// Receita Bruta Acumulada 
aGetApur[1,3] := nTotalRB
// Receita Bruta Mensal 
aGetApur[2,3] := (nRBMensal-nRBServ-nRBServRet-nRBST-nRBLoc)
// Receita Bruta Mensal - Servico
aGetApur[3,3] := A924ChkServ( nRBServ ) + A924ChkServ( nRBServRet )
// Receita Bruta Mensal - ST
aGetApur[4,3] := nRBST 
// Receita Bruta Mensal - Locacao
aGetApur[5,3] := nRBLoc
// Valor Devido (Comercio+Servico+ST+Locacao)
aGetApur[6,3] := nVlrDev+nVlrDevS+nVlDevST+nVlrDevL

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³A924LeCfg  ³ Autor ³Mary C. Hergert        ³ Data ³30/07/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Le o arquivo de configuracao SNCONFIG.CFG                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A924LeCfg()

Local aRet		:= {}
Local cFILSNCO	:= FWGrpCompany()+FWGETCODFILIAL
Local cFile		:= "SNCONFIG"+cFILSNCO+".CFG"
Local cLinha	:= ""
Local nX := 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Arquivo de Configuracao dos Percentuais Aplicaveis           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !File(cFile)
	//-- usa somente filial se não achou configuracao para empresa+filial.
	cFile := "SNCONFIG"+FWGETCODFILIAL+".CFG"
EndIf
If File(cFile)
	FT_FUSE(cFile)
	FT_FGotop()
	While ( !FT_FEof() )
		cLinha := AllTrim(UPPER(FT_FREADLN()))
		If !Empty(cLinha) .And. Left(cLinha,1)=="{" .And. Right(cLinha,1)=="}" .And.	IIf(Len(&cLinha)>15,Len(&cLinha)==16,Len(&cLinha)==15)
			AADD(aRet,&cLinha)
			If ValType(aRet[nX][16]) == "U"
				aRet[nX][16]:= 0
			Endif
			nX ++
		Endif
		FT_FSKIP()
	EndDo
	FT_FUse()
	If Len(aRet)> 0
		If Len(aRet[1])==15
			AADD(aRet[1],0)
		Endif
	endif
Endif

Return( aRet )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³A924Cfg    ³ Autor ³Mary C. Hergert        ³ Data ³30/07/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Tela de configuracao da tabela de percentuais aplicaveis     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A924Cfg(lAutomato)

Local aAltera	:= {"ORDEM","FXINI","FXFIM","ALIQ","IRPJ","CSLL","COFINS","PISPASEP","INSS","ICMS","REDICMS","ISS","IPI","CONSOL","CPP","TIPREC","F4_TPRSPL"}
Local cFILSNCO	:= FWGrpCompany()+FWGETCODFILIAL
Local cFile		:= "SNCONFIG"+cFILSNCO+".CFG"
Local cArqBkp	:= "SNCONFIG"+cFILSNCO+".#FG"	//Backup
Local cDados	:= ""

Local nHandle	:= 0
Local nX		:= 0
Local nOpca	:= 0
Local oDlg   
Local nSeRecSN	:= mv_par13   
Local nY 			:= 0      

Default lAutomato := .F.

Private aHeader	:= {}
Private aRotina := {{OemtoAnsi(STR0018)	,"AxPesqui"	,0,1},; // "Pesquisar"
                    {OemtoAnsi(STR0019)	,"AxVisual"	,0,2},; // "Visualizar"
                    {OemtoAnsi(STR0020)	,"AxInclui"	,0,3},; // "Incluir"
                    {OemtoAnsi(STR0021)	,"AxAltera"	,0,4},; // "Alterar"
                    {OemtoAnsi(STR0022)	,"AxDeleta"	,0,5} } // "Excluir"

If lAutomato
	A924Temp()
EndIf

dbSelectArea("TMP")
dbSetOrder(0)
dbGoTop()

A924Carga()
                                                                                               
AADD(aHeader,{ OemtoAnsi(STR0023),"FXINI","@E 999,999,999,999.99",15,2,"","","N","TMP","" } )
AADD(aHeader,{ OemtoAnsi(STR0024),"FXFIM","@E 999,999,999,999.99",15,2,"","","N","TMP","" } )
AADD(aHeader,{ OemtoAnsi(STR0025),"ALIQ","@E 99.99",05,2,"","","N","TMP","" } )   
AADD(aHeader,{ OemtoAnsi(STR0026),"IRPJ","@E 99.99",05,2,"","","N","TMP","" } )   
AADD(aHeader,{ OemtoAnsi(STR0028),"CSLL","@E 99.99",05,2,"","","N","TMP","" } )   
AADD(aHeader,{ OemtoAnsi(STR0029),"COFINS","@E 99.99",05,2,"","","N","TMP","" } )   
AADD(aHeader,{ OemtoAnsi(STR0030),"PISPASEP","@E 99.99",05,2,"","","N","TMP","" } )   
AADD(aHeader,{ OemtoAnsi(STR0031),"INSS","@E 99.99",05,2,"","","N","TMP","" } )   
AADD(aHeader,{ OemtoAnsi(STR0032),"ICMS","@E 99.99",05,2,"","","N","TMP","" } )   
AADD(aHeader,{ OemtoAnsi("RED."+STR0032),"REDICMS","@E 999.99",06,2,"","","N","TMP","" } ) 
AADD(aHeader,{ OemtoAnsi(STR0033),"ISS","@E 99.99",05,2,"","","N","TMP","" } )   
AADD(aHeader,{ OemtoAnsi(STR0027),"IPI","@E 99.99",05,2,"","","N","TMP","" } )   
AADD(aHeader,{ OemtoAnsi(STR0055),"CONSOL","@E 99.99",05,2,"","","N","TMP","" } )   
AADD(aHeader,{ OemtoAnsi(STR0081),"CPP","@E 99.99",05,2,"","","N","TMP","" } ) // "CPP"  
AADD(aHeader,{ OemtoAnsi(STR0069),"TIPREC","@!",01,0,"","","N","TMP","" } )
If nSeRecSN == 2   //determina se vai aparecer o array para segregação de receitas por Ramo (Simples Nacional)
	AADD(aHeader,{ OemtoAnsi(STR0080),"F4_TPRSPL","@!",01,0,"ExistCpo('SX5','89'+M->F4_TPRSPL)","","C","SF4","" } )
EndIf

aSize		:= MsAdvSize()
aObjects	:= {} 

AAdd( aObjects, { 100, 100, .T., .T. } )

aInfo	:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj	:= MsObjSize( aInfo, aObjects )

DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0014) From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
If nSeRecSN == 2   //determina se vai aparecer o array para segregação de receitas por Ramo (Simples Nacional)
	oGetDb := MsGetDB():New(aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4],4,"IIf(!Empty(TMP->F4_TPRSPL),.T.,.F.) .And. AllwaysTrue()","Allwaystrue",,.T.,aAltera,,.T.,,"TMP",,,.T.,,.T.)
Else
	oGetDb := MsGetDB():New(aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4],4,"Allwaystrue","Allwaystrue",,.T.,aAltera,,.T.,,"TMP",,,.T.,,.T.)
Endif

If !lAutomato
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,oDlg:End()},{||nOpcA:=2,oDlg:End()})
Else
	nOpcA := 1
EndIf

If nOpcA == 1
	
	If (File(cFile))
		If File(cArqBkp)
			FErase (cArqBkp)
		Endif
		FRename(cFile,cArqBkp)
	Endif
	nHandle	:=	MsFCreate(cFile)	

	If !lAutomato	
		
		dbSelectArea("TMP")
		dbSetOrder(1)
		dbGoTop()    
		While !Eof() 
			If !(TMP->_FLAG)
				cDados	:=	'{'+;
						LTRIM(STR(TMP->FXINI,15,2))+','+;
						LTRIM(STR(TMP->FXFIM,15,2))+','+;
						LTRIM(STR(TMP->ALIQ,5,2))+','+;
						LTRIM(STR(TMP->IRPJ,5,2))+','+;
						LTRIM(STR(TMP->CSLL,5,2))+','+;
						LTRIM(STR(TMP->COFINS,5,2))+','+;
						LTRIM(STR(TMP->PISPASEP,5,2))+','+;
						LTRIM(STR(TMP->INSS,5,2))+','+;
						LTRIM(STR(TMP->ICMS,5,2))+','+;
						LTRIM(STR(TMP->REDICMS,6,2))+','+;
						LTRIM(STR(TMP->ISS,5,2))+','+;
						LTRIM(STR(TMP->IPI,5,2))+','+;
						LTRIM(STR(TMP->CONSOL,5,2))+','+;
						LTRIM(STR(TMP->CPP,5,2))+','+;
						LTRIM(STR(TMP->TIPREC))+','+;
						Iif(nSeRecSN==2,LTRIM(TMP->F4_TPRSPL),'')+;															
					'}'+Chr(13)+Chr(10)
					// ATENÇÃO!!! O alias F4_TPRSPL foi criado unicamente para ser utilizado
					// na tabela temporaria TMP, não tendo relação com alteração de dados na TES por exemplo.
					// Foi necessario utilizar o alias F4_TPRSPL na tabela TMP, para que a função MsGetDb 
					// consiga interpretar que esse campo temporario terá a mesma consulta padrão
					// utilizada no campo F4_TPRSPL da tabela SF4 TES.
				FWrite(nHandle,cDados,Len(cDados))				
			EndIf
			dbSkip()
		Enddo
	Else
	
		If FindFunction("GetParAuto")
			aRetAuto	:= GetParAuto("MATA924TestCase")
		EndIf
		
		If Len(aRetAuto) > 0
		
			For nY := 1 to Len(aRetAuto)
			
				cDados :=  aRetAuto[nY][1] + CRLF
			
				FWrite(nHandle,cDados,Len(cDados))
			
			Next nY

		EndIf
	
		dbSelectArea("TMP")
		dbCloseArea()
	
	EndIf

	If nHandle >= 0
		FClose(nHandle)
	Endif
Else 
	A924Carga()	
Endif

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³A924Temp   ³ Autor ³Mary C. Hergert        ³ Data ³30/07/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Gera arquivo temporario                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A924Temp()

Local aStru		:= {}
Local cArq		:= ""
     
AADD(aStru,{"REGTRIB"	,"C",003,0})	//ME ou EPP
AADD(aStru,{"FXINI"		,"N",015,2})	//Faixa Inicial
AADD(aStru,{"FXFIM"		,"N",015,2})	//Faixa Final
AADD(aStru,{"ALIQ"		,"N",005,2})	//Percentual Aplicavel
AADD(aStru,{"IRPJ"		,"N",005,2})	//Percentual IRPJ
AADD(aStru,{"CSLL"		,"N",005,2})	//Percentual CSLL
AADD(aStru,{"COFINS"	,"N",005,2})	//Percentual COFINS
AADD(aStru,{"PISPASEP"	,"N",005,2})	//Percentual PIS/PASEP
AADD(aStru,{"INSS"		,"N",005,2})	//Percentual Contr. Seg. Social
AADD(aStru,{"ICMS"		,"N",005,2})	//Percentual ICMS
AADD(aStru,{"REDICMS"	,"N",005,2})	//Percentual Redução de ICMS
AADD(aStru,{"ISS"		,"N",005,2})	//Percentual ISS
AADD(aStru,{"IPI"		,"N",005,2})	//Percentual IPI
AADD(aStru,{"CONSOL"	,"N",005,2})	//Percentual consolidado de IRPJ, PIS/Pasep, Cofins e CSLL     
AADD(aStru,{"CPP"		,"N",005,2})	//Percentual CPP - Contribuição Patronal Previdenciária
AADD(aStru,{"TIPREC"	,"N",001,0})	//Tipo Receita (1=Com ST;2=Sem ST)
AADD(aStru,{"_FLAG"		,"L",001,0})	//Flag de Controle
// ATENÇÃO!!! O alias F4_TPRSPL foi criado unicamente para ser utilizado
// na tabela temporaria TMP, não tendo relação com alteração de dados na TES por exemplo.
// Foi necessario utilizar o alias F4_TPRSPL na tabela TMP, para que a função MsGetDb 
// consiga interpretar que esse campo temporario terá a mesma consulta padrão
// utilizada no campo F4_TPRSPL da tabela SF4 TES.
AADD(aStru,{"F4_TPRSPL"		,"C",001,0})	//Tipo de Receita (1, 2 ou 3)

cArq := CriaTrab(aStru)
dbUseArea(.T.,__LocalDriver,cArq,"TMP")
IndRegua("TMP",cArq,"STR(FXINI,15,2)+STR(ALIQ,5,2)+STR(CONSOL,5,2)+STR(ISS,5,2)")

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³A924Carga  ³ Autor ³Mary C. Hergert        ³ Data ³30/07/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Carrega arquivo temporario                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A924Carga()

Local aFaixa	:= A924LeCfg()
Local nSeRecSN	:= mv_par13
Local nX		:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Excluindo os itens atuais para recarregar o temporario³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("TMP")
Do While !TMP->(Eof())
	RecLock("TMP",.F.)
	TMP->(dbDelete())
	MsUnLock()
	TMP->(dbSkip())
Enddo

If Len(aFaixa) > 0
	For nX := 1 To Len(aFaixa) 
		RecLock("TMP",.T.)
		FXINI		:= aFaixa[nX][01]
		FXFIM		:= aFaixa[nX][02]
		ALIQ		:= aFaixa[nX][03]
		IRPJ		:= aFaixa[nX][04]
		CSLL		:= aFaixa[nX][05]
		COFINS		:= aFaixa[nX][06]
		PISPASEP	:= aFaixa[nX][07]
		INSS		:= aFaixa[nX][08]
		ICMS		:= aFaixa[nX][09]
		REDICMS		:= aFaixa[nX][10]
		ISS			:= aFaixa[nX][11]
		IPI			:= aFaixa[nX][12]
		CONSOL		:= aFaixa[nX][13]
		CPP 		:= aFaixa[nX][14]
		TIPREC		:= aFaixa[nX][15]
		nSeRecSN := IIf (Valtype(nSeRecSN) == "C",Val(nSeRecSN),nSeRecSN)
		If nSeRecSN == 2 .And. Len(aFaixa[nX]) > 15
			F4_TPRSPL	:= IIf(ValType(aFaixa[nX][16]) <> "U", Alltrim(Str(aFaixa[nX][16])), "1")
		EndIf
		MsUnlock()
	Next
Else
	RecLock("TMP",.T.)
	MsUnlock()
Endif

dbSelectArea("TMP")
dbGoTop()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³A924DtRec  ³ Autor ³Mary C. Hergert        ³ Data ³30/07/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Verifica os 12 meses para calculo da receita bruta.          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A924DtRec(dDtIni,dDtRecIni,dDtRecFim)	
  
Local dDtAux	:= Ctod("")                                                    

Local nMesFim 	:= 0
Local nAnoFim	:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calcula a data final onde serao processados os ultimos 12 meses     ³
//³de receita bruta do contribuinte.                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Month(dDtIni) == 1
	nMesFim := 12 
	nAnoFim	:= Year(dDtIni) - 1
Else
	nMesFim := Month(dDtIni) - 1
	nAnoFim	:= Year(dDtIni)
Endif
dDtAux		:= cTod("01/" + StrZero(nMesFim,2) + "/" + StrZero(nAnoFim,4))
dDtRecFim 	:= LastDay(dDtAux)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calcula a data inicial onde serao processados os ultimos 12 meses   ³
//³de receita bruta do contribuinte.                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dDtRecIni 	:= cTod("01/" + StrZero(Month(dDtIni),2) + "/" + StrZero(Year(dDtIni)-1,4))

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³A924Msg    ³ Autor ³Mary C. Hergert        ³ Data ³06/09/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Apresenta mensagem de desenquadramento                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A924Msg(nTotalRB,nTribMax)

Local cTitulo	:= ""
Local cErro		:= ""
Local cSolucao	:= ""

cTitulo 	:= STR0058 				//"Limites do Simples Nacional"	
cErro		:= STR0059 				//"A receita bruta do contribuinte ("
cErro		+= Alltrim(Transform(nTotalRB,"@E 99999,999,999.99")) + ") "
cErro		+= STR0060 				//"ultrapassou o limite da última faixa de tributação cadastrada ("
cErro		+= Alltrim(Transform(nTribMax,"@E 99999,999,999.99")) + "). "
cErro		+= STR0061 				//"Neste caso, ou as faixas de tributação foram cadastradas de forma "
cErro		+= STR0062 				//"incompleta ou o contribuinte ultrapassou o limite de faturamento "
cErro		+= STR0063 				//"para enquadramento no Simples Nacional (ME ou EPP)."
cSolucao	:= STR0064 				//"O sistema irá efetuar o cálculo do valor a ser recolhido ao Simples Nacional "
cSolucao	+= STR0065 				//"com base na última faixa de tributação cadastrada. Verifique se as faixas de "
cSolucao	+= STR0066 				//"tributação foram cadastradas corretamente ou se a empresa deverá permanecer "
cSolucao	+= STR0067 				//"enquadrada no Simples Nacional de acordo com o seu faturamento."
xMagHelpFis(cTitulo,cErro,cSolucao)

Return .T.  

//-------------------------------------------------------------------
/*/{Protheus.doc} A924ChkServ
Verifica se os valores de Servico devem ou nao ser demonstrados na Apuracao
@param	nValor - Valor de Servico
@return nValor - Valor de Servico
@author Luccas Curcio
@since 28/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function A924ChkServ( nValor )
Local	nSeRecSN	:=	mv_par13
Local	nTpRecSN	:=	Iif( ValType( mv_par12 ) == 'C' , Val( mv_par12 ) , mv_par12 )	

If nSeRecSN == 2 .And. nTpRecSN <> 3
	nValor	:=	0
Endif

Return nValor

//-------------------------------------------------------------------
/*/{Protheus.doc} A924LeArqAnt
Verifica se os valores de Servico devem ou nao ser demonstrados na Apuracao
@param cArqAnt - Nome do Arquivo do Perido Anterior
@return nRBAnt - Receita Bruta Anual do Periodo Anterior
@author Beatriz Scarpa
@since 25/03/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function A924LeArqAnt(cArqAnt)

Local cLinha	:= ""
Local nRBAnt	:= 0

Default cArqAnt	:= ""

If File(cArqAnt)
	FT_FUSE(cArqAnt)
	FT_FGotop()
	While ( !FT_FEof() )
		cLinha := AllTrim(UPPER(FT_FREADLN()))
		If !Empty(cLinha) .And. (Left(cLinha,3)=="001" .Or. Left(cLinha,3)=="002")
			nRBAnt	+= Val(Alltrim(Right(cLinha,15)))
		Endif
		FT_FSKIP()	
	EndDo
	FT_FUse()	
EndIf

Return nRBAnt

//-------------------------------------------------------------------
/*/{Protheus.doc}
@description geracao do arquivo texto
@author Flavio Luiz Vicco
@since 12/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DumpFile(nAcao, cDir, cFileDest)
Local cLib       := ""
Local cStartPath := AllTrim(GetSrvProfString("StartPath",""))
Local nRemType   := GetRemoteType(@cLib)
Local lHtml      := IIf(nRemType == 5 ,.T.,.F.)
Local nRet       := 0

Default nAcao    := 1
Default cDir     := ""
Default cFileDest:= ""

If nAcao == 1
	If Empty(cDir) .Or. lHtml
		cDir := cStartPath
	EndIf
	If !SubStr(cDir,Len(cDir),1)$"\/"
		cDir += "\"
	EndIf
	cFileDest := AllTrim(cFileDest)
	cFileDest := AllTrim(cDir)+cFileDest 
	If (IsSrvUnix() .And. (Empty(cDir) .Or. lHtml))  .Or. nRemType == 2
		cFileDest := StrTran(cFileDest,"\","/")
		cFileDest := StrTran(StrTran(StrTran(Alltrim(cFileDest)," ","_"),chr(13),""),chr(10),"")
	Else
		//Se o drive nao existir, pergunto ao usuario se deseja cria-lo atraves da funcao LjDirect()
		If !ExistDir(cDir)
			LjDirect(cDir,.T.)
		Endif
	EndIf
Else
	If File(cFileDest)
		If lHtml
			MsgAlert("Em função do acesso ao sistema ser via SmartClient HTML, o caminho informado para salvar o arquivo será desconsiderado, e será processado conforme configuração do navegador.")
			nRet := CPYS2TW(cFileDest)
			If nRet == 0
				FErase(cFileDest)
				MsgInfo(OemToAnsi("Arquivo " + cFileDest + " gerado com sucesso!"))
			EndIf
		Else
			MsgInfo(OemToAnsi("Arquivo " + cFileDest + " gerado com sucesso!"))
		EndIf
	Else
		MsgAlert(OemToAnsi("Não foi possível gerar o arquivo!"))
	EndIf
EndIf

Return Nil
