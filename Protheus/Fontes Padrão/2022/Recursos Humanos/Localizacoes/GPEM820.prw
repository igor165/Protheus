#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEM820.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPEM820  ³ Autor ³ Christiane Vieira          ³    Data ³   03.12.2010  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera o relatório de conferência com os dados da Declaracao de           ³±±
±±³          ³ Remuneracoes - Mapa da Seguranca Social - PORTUGAL 			           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Portugal                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³               ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador   ³ Data     ³     FNC      ³  Motivo da Alteracao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Christiane V  ³03/12/2010³000027389/2010³ Desenvolvimento Inicial                   ³±±
±±³  Marco A.    ³ 16/04/18 ³  DMINA-2310  ³Se remueven sentencias CriaTrab y se apli- ³±±
±±³			     ³		    ³              ³ca FWTemporaryTable(), para el manejo de   ³±±
±±³			     ³		    ³              ³las tablas temporales.                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GPEM820()                                    
Local cMes
Local cAno
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Define Variaveis Locais (Basicas)                            ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Local cDesc1 		:= STR0022		//"Mapa de Segurança Social - Declaração de Remunerações"
Local cDesc2 		:= STR0021		//"Será impresso de acordo com os parametros informados pelo usuario."
Local cString		:= "SRA"        // alias do arquivo principal (Base)

Private Titulo	    := STR0001		//Declaração de Remunerações
Private nTamanho    := "G"
Private cFilIni     := ""
Private cFilFim     := ""
Private cCcIni      := ""
Private cCcFim      := ""
Private cDepIni     := ""
Private cDepFim	    := ""
Private cPerInf	    := ""
Private cNPgto	    := ""
Private cCodEs	    := ""
Private cFiltSRA    := ""
Private nTotRem		:= 0
Private nSubTot		:= 0 

// Define Variaveis Private(Basicas)                            
Private NomeProg	:= "GPEM820"
Private aReturn 	:={ "", 1, "", 2, 2, 1,"",1 }
Private nLastKey 	:= 0
Private cPerg	    := "GPM820"

If cPaisLoc = "PTG"  
	dbSelectArea("SX1")
	dbSetOrder(1)

	If !SX1->( dbSeek("GPM820    01") )  	
		Aviso(OemToAnsi(STR0026), OemToAnsi(STR0034), {"OK"})
	    Return
	Endif
Endif               

Pergunte("GPM820",.F.)

// Envia controle para a funcao SETPRINT                       
wnrel:="GPEM820"            //Nome Default do relatorio em Disco
wnrel:=SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,cDesc2,,.F.,,.F.,nTamanho,,.F.)

If nLastKey = 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Return
Endif

nOrdem   := aReturn[8]

cFilIni    := mv_par01   //De Filial
cFilFim    := mv_par02   //Até Filial   
cCcIni     := mv_par03   //De Centro de Custo 
cCcFim     := mv_par04   //Até Centro de Custo 
cDepIni	   := mv_par05   //De Departamento  
cDepFim	   := mv_par06   //Até departamento
cPerInf	   := mv_par07   //Período  
cNPgto	   := mv_par08   //Número de Pagamento   
cCodEs	   := mv_par09   //Código do Estabelecimento
	
//-- Objeto para impressao grafica
oPrint 	:= TMSPrinter():New( STR0001 ) //"Declaração de Remunerações
oPrint:SetLandscape()

Titulo := STR0001//Formulário Trimestral de Planillas de Sueldos y Salarios y Accidentes de Trabajo - Declaración Jurada

RptStatus({|lEnd| GPEM820Imp(@lEnd,wnRel,cString )},Capital(Titulo))   

oPrint:Preview()  							// Visualiza impressao grafica antes de imprimir

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GPEM820Imp ³ Autor ³ Christiane Vieira    ³ Data ³03/12/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao do Mapa de Segurança Social - Portugal           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEM820                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GPEM820Imp(lEnd,wnRel,cString)

	Local cAcessaSRA	:= &( " { || " + ChkRH( "GPEM820" , "SRA", "2" ) + " } " )       
	Local cRegAnt := ""
	Local cFilAnt := ""
	Local aFunc		:={}	 
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Variaveis para controle em ambientes TOP.                    ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/ 
	Local cAlias   := ""   
	Local cQrySRA  := "SRA"
	Local cQrySRC  := "SRC"  
	Local cQrySRD  := "SRD"   
	Local aStruct  := {}      
	Local lQuery   := .F. 
	Local cQuery   := ""
	Local cQryTX   := ""
	Local cFiltro  := ""
	Local cFunINSS := ""
	Local cMsgTX   := ""
	
	//Vaviaveis private para impressao  
	Local cCodSalM:="",cCodSalH:="",cCodFalt:="",cTurTrab:="",cCodTXE :="",cCodTXF:="",cPeriod:=""
	Local cNomTab :="",cDatNas :="",cRazSoc :="",cNISS  :="" ,cNIF    :="",CNISSEE:="",cValSin:=""
	Local cTotRem :="",cTSinRem:="",cTotCon :="",cTSinCon:="",cNatRem:="",cSinTabr:="",cDiaTabr:=""
	Local nCont   :=0 ,nTotReg :=0 ,nPorcTX :=0 ,nTxEmp :=0 ,nTxFunc :=0 
	Local cNISSPS := ""
	Local cPerTRB := ""
	Local nPosTx  := 0 
	Local nPagina := 0
	Local cCodss  := ""
	
	Private aInfo:= {}
	
	cCcIni  :=Iif(ValType(cCcIni)	=="N",Alltrim(Str(cCcIni))	,cCcIni)
	cCcFim  :=Iif(ValType(cCcFim)	=="N",Alltrim(Str(cCcFim))	,cCcFim)
	cDepIni :=Iif(ValType(cDepIni)	=="N",Alltrim(Str(cDepIni))	,cDepIni)
	cDepFim :=Iif(ValType(cDepFim)	=="N",Alltrim(Str(cDepFim))	,cDepFim)
	cPerInf	:=Iif(ValType(cPerInf)	=="N",Alltrim(Str(cPerInf))	,cPerInf)
	cNPgto	:=Iif(ValType(cNPgto)	=="N",Alltrim(Str(cNPgto))	,cNPgto)
	cCodEs 	:=Iif(ValType(cCodEs)	=="N",Alltrim(Str(cCodEs))	,cCodEs)
	//=================================================================================================================
	//Traz a Taxa que sera utilizado para Calcular o Total da Contribuicao Seguridade Social
	//=================================================================================================================
	cCodTXE:=Posicione("SRV",2,xFilial("SRV")+"0783","RV_COD")//Taxa SS da Empresa//FGETCODFOL("783")
	cCodTXF:=Posicione("SRV",2,xFilial("SRV")+"0064","RV_COD")//Taxa SS do Funcionario//FGETCODFOL("0064")
	//=================================================================================================================
	                                                                                                                   
	//=============================================================================================================
	//Filtro definido por meio do Botao Filtro da Tela Inicial
	//=============================================================================================================  
	If !Empty(cFilTSRA) 
		cFiltro:=""
		For nCont:=1 To Len(Alltrim(cFilTSra))
			If !Substr(Alltrim(cFilTSra),nCont,1)$"."    
				If Substr(Alltrim(cFilTSra),nCont,1)$'"'
					cFiltro+="'"
				ElseIf Substr(Alltrim(cFilTSra),nCont,1)$"="
					cFiltro+="="
					nCont++					
				Else
					cFiltro+=Substr(Alltrim(cFilTSra),nCont,1)
				Endif
			Endif	              
		Next       
	Endif           
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Objetos para Impressao Grafica - Declaracao das Fontes Utilizadas.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private oFont08, oFont09, oFont09n, oFont16n
	
	oFont08	:= TFont():New("Courier New",08,08,,.F.,,,,.T.,.F.)
	oFont09	:= TFont():New("Courier New",09,09,,.F.,,,,.T.,.F.) 
	oFont09n:= TFont():New("Courier New",09,09,,.T.,,,,.T.,.F.)     //Negrito//
	oFont16n:= TFont():New("Courier New",16,16,,.T.,,,,.T.,.F.)     //Negrito//
	
	nEpoca:= SET(5,1910)
	//-- MUDAR ANO PARA 4 DIGITOS 
	SET CENTURY ON 

	//=============================================================================================================
	//Traz somente os funcionarios que possui as duas taxas
	//=============================================================================================================
	cQryTX:="SELECT DISTINCT RA_FILIAL,RC_MAT MAT, RA_NOME NOMFUN,COUNT(*) QTD,SUM(RC_HORAS) PORC "
	cQryTX+="FROM "+RETSQLNAME("SRA")+" SRA "
	cQryTX+="INNER JOIN "+RETSQLNAME("SRC")+" SRC ON "
	cQryTX+="RA_MAT = RC_MAT "
	cQryTX+= "AND RC_PERIODO='"+Alltrim(cPerInf)+"' "
	If !Empty(cCCIni) .And. !Empty(cCCFim)
		cQryTX+= "AND RC_CC BETWEEN '"+cCCIni+"' AND '"+cCCFim+"' "
	ElseIf !Empty(cCCIni)
		cQryTX+= "AND RC_CC >= '"+cCCIni+"' "
	ElseIf !Empty(cCCFim)
		cQryTX+= "AND RC_CC <= '"+cCCFim+"' "
	Endif
	If !Empty(cNPgto)
		cQryTX+= "AND RC_SEMANA='"+Alltrim(cNPgto)+"' "
	Endif
	cQryTX+="AND RC_PD IN ('"+cCodTXE+"','"+cCodTXF+"') "            
	cQryTX+="AND SRC.D_E_L_E_T_='' "
	cQryTX+= "INNER JOIN "+RETSQLNAME("SQB")+" SQB ON "
	cQryTX+= "QB_DEPTO=RA_DEPTO "
	If !Empty(cDepIni) .And. !Empty(cDepFim)
		cQryTX+= "AND QB_DEPTO BETWEEN '"+cDepIni+"' AND '"+cDepFim+"' "
	ElseIf !Empty(cDepIni)
		cQryTX+= "AND QB_DEPTO >= '"+cDepIni+"' "
	ElseIf !Empty(cDepFim)
		cQryTX+= "AND QB_DEPTO <= '"+cDepFim+"' "
	Endif
	cQryTX+= "AND QB_CESTAB = '"+cCodEs+"' "
	cQryTX+="AND SQB.D_E_L_E_T_='' "
	cQryTX+="WHERE SRA.D_E_L_E_T_='' "
	If !Empty(cFiltro)
		cQryTX+="AND "+cFiltro
	Endif
	If !Empty(cFilIni) .And. !Empty(cFilFim)
		cQryTX+= "AND RA_FILIAL BETWEEN '"+cFilIni+"' AND '"+cFilFim+"' "
	ElseIf !Empty(cFilIni)
		cQryTX+= "AND RA_FILIAL >= '"+cFilIni+"' "
	ElseIf !Empty(cFilFim)
		cQryTX+= "AND RA_FILIAL <= '"+cFilFim+"' "
	Endif           
	cQryTX+="GROUP BY RA_FILIAL,RC_MAT, RA_NOME "  
	cQryTX+="HAVING COUNT(*) > 1  "	
	cQryTX+="UNION "//JUNCAO
	cQryTX+="SELECT DISTINCT RA_FILIAL,RD_MAT MAT,RA_NOME NOMFUN,COUNT(*) QTD,SUM(RD_HORAS) PORC "
	cQryTX+="FROM "+RETSQLNAME("SRA")+" SRA "
	cQryTX+="INNER JOIN "+RETSQLNAME("SRD")+" SRD ON "
	cQryTX+="RA_MAT = RD_MAT "
	cQryTX+= "AND RD_DATARQ='"+Alltrim(cPerInf)+"' "
	If !Empty(cCCIni) .And. !Empty(cCCFim)
		cQryTX+= "AND RD_CC BETWEEN '"+cCCIni+"' AND '"+cCCFim+"' "
	ElseIf !Empty(cCCIni)
		cQryTX+= "AND RD_CC >= '"+cCCIni+"' "
	ElseIf !Empty(cCCFim)
		cQryTX+= "AND RD_CC <= '"+cCCFim+"' "
	Endif
	If !Empty(cNPgto)
		cQryTX+= "AND RD_SEMANA='"+Alltrim(cNPgto)+"' "
	Endif
	cQryTX+="AND RD_PD IN ('"+cCodTXE+"','"+cCodTXF+"') "            
	cQryTX+="AND SRD.D_E_L_E_T_='' "
	cQryTX+= "INNER JOIN "+RETSQLNAME("SQB")+" SQB ON "
	cQryTX+= "QB_DEPTO=RA_DEPTO "
	If !Empty(cDepIni) .And. !Empty(cDepFim)
		cQryTX+= "AND QB_DEPTO BETWEEN '"+cDepIni+"' AND '"+cDepFim+"' "
	ElseIf !Empty(cDepIni)
		cQryTX+= "AND QB_DEPTO >= '"+cDepIni+"' "
	ElseIf !Empty(cDepFim)
		cQryTX+= "AND QB_DEPTO <= '"+cDepFim+"' "
	Endif
	cQryTX+="AND QB_CESTAB = '"+cCodEs+"' "
	cQryTX+="AND SQB.D_E_L_E_T_='' "
	cQryTX+="WHERE SRA.D_E_L_E_T_='' "
	If !Empty(cFiltro)
		cQryTX+="AND "+cFiltro
	Endif
	If !Empty(cFilIni) .And. !Empty(cFilFim)
		cQryTX+= "AND RA_FILIAL BETWEEN '"+cFilIni+"' AND '"+cFilFim+"' "
	ElseIf !Empty(cFilIni)
		cQryTX+= "AND RA_FILIAL >= '"+cFilIni+"' "
	ElseIf !Empty(cFilFim)
		cQryTX+= "AND RA_FILIAL <= '"+cFilFim+"' "
	Endif           
	cQryTX+="GROUP BY RA_FILIAL,RD_MAT, RA_NOME "  
	cQryTX+="HAVING COUNT(*) > 1  "
	cQryTX := ChangeQuery(cQryTX)
	
	If Select("TAXA")>0
		DbSelectArea("TAXA")
		TAXA->(DbCloseArea())
	Endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryTX),"TAXA",.F.,.T.)
	DbSelectArea("TAXA")
	TAXA->(DbGoTop())  

	//==============================================================================================================
	//Caso nao haja nenhuma das duas taxas de inss, o sistema aborta o processo
	//==============================================================================================================
	If TAXA->(EOF())
		cMsgTX:=Alltrim(STR0023)+chr(10)+chr(30);
		+Alltrim(STR0024)+cCodTXE+chr(10)+chr(30); 
		+Alltrim(STR0025)+cCodTXF
		MsgAlert(cMsgTX,STR0026)
		Return
	Else
		cFunINSS:="'"
		nPorcTX :=TAXA->PORC
		Do While TAXA->(!EOF())          
			cFunINSS+=ALLTRIM(TAXA->MAT)+"','"
			aAdd(aFunc,{TAXA->RA_FILIAL,TAXA->MAT,TAXA->NOMFUN,TAXA->PORC})
			TAXA->(DbSkip())
		End           
		cFunINSS+="'"                        
	Endif
   
	//==============================================================================================================
	//MOVIMENTOS DO PERIODO (SRC)
	//==============================================================================================================
	cQuery:= "SELECT CASE WHEN RA_NOMECMP='' THEN RA_NOME ELSE RA_NOMECMP END NOMFUN, 'SRC' ALIAS,  "
	cQuery+= "RA_FILIAL FILIAL,RA_MAT ,RA_NASC ,RA_NISSPS,RA_DEPTO,QB_DESCRIC,RC_PERIODO PERIODO, RC_ROTEIR ROTEIRO, "
	cQuery+= "RC_PD VERBA,QB_CESTAB,RC_VALOR VALOR, RV_NATRSS,RA_CODSS, RC_HORAS HORAS, "
	cQuery+= "CASE WHEN RV_TIPOCOD = '1' or RV_TIPOCOD = '3' THEN '0' ELSE '-' END SINAL "
	cQuery+= "FROM "+RETSQLNAME("SRA")+" SRA "
	cQuery+= "INNER JOIN "+RETSQLNAME("SRC")+" SRC ON "
	cQuery+= "RC_FILIAL=RA_FILIAL "
	cQuery+= "AND RC_MAT=RA_MAT "
	cQuery+= "AND RC_MAT IN ("+cFunINSS+") "
	cQuery+= "AND RC_VALOR > 0 "
	cQuery+= "AND RC_PERIODO='"+Alltrim(cPerInf)+"' "
	cQuery+= "AND SRC.D_E_L_E_T_='' "
	cQuery+= "INNER JOIN "+RETSQLNAME("SQB")+" SQB ON "
	cQuery+= "QB_DEPTO=RA_DEPTO "
	cQuery+= "AND SQB.D_E_L_E_T_='' "
	cQuery+= "INNER JOIN "+RETSQLNAME("SRV")+" SRV ON " 
	cQuery+= "RV_COD=RC_PD AND RV_FILIAL='"+xFilial("SRV")+"' AND SRV.D_E_L_E_T_='' AND SRV.RV_INSS='S' "
	cQuery+= "WHERE SRA.D_E_L_E_T_='' "
	//==============================================================================================================
	cQuery+= "UNION "//UNIAO ENTRE OS DADOS DOS MOVIMENTOS DO PERIODO COM O HISTORICO DOS MOVIMENTOS
	//==============================================================================================================
	//HISTORICOS DOS MOVIMENTOS (SRD)
	//==============================================================================================================
	cQuery+= "SELECT CASE WHEN RA_NOMECMP='' THEN RA_NOME ELSE RA_NOMECMP END NOMFUN, 'SRD' ALIAS,  "
	cQuery+= "RA_FILIAL FILIAL,RA_MAT,RA_NASC,RA_NISSPS,RA_DEPTO,QB_DESCRIC,RD_DATARQ PERIODO,RD_ROTEIR ROTEIRO, "
	cQuery+= "RD_PD VERBA,QB_CESTAB,RD_VALOR VALOR, RV_NATRSS,RA_CODSS, RD_HORAS HORAS, "    
	cQuery+= "CASE WHEN RV_TIPOCOD = '1' or RV_TIPOCOD = '3' THEN '0' ELSE '-' END SINAL "
	cQuery+= "FROM "+RETSQLNAME("SRA")+" SRA "	
	cQuery+= "INNER JOIN "+RETSQLNAME("SRD")+" SRD ON "
	cQuery+= "RD_FILIAL=RA_FILIAL "
	cQuery+= "AND RD_MAT=RA_MAT "           
	cQuery+= "AND RD_MAT IN ("+cFunINSS+") "
	cQuery+= "AND RD_VALOR > 0 "
	cQuery+= "AND RD_DATARQ='"+Alltrim(cPerInf)+"' "
	cQuery+= "AND SRD.D_E_L_E_T_='' "
	cQuery+= "INNER JOIN "+RETSQLNAME("SQB")+" SQB ON "
	cQuery+= "QB_DEPTO=RA_DEPTO "
	cQuery+= "AND SQB.D_E_L_E_T_='' "
	cQuery+= "INNER JOIN "+RETSQLNAME("SRV")+" SRV ON " 
	cQuery+= "RV_COD=RD_PD AND RV_FILIAL='"+xFilial("SRV")+"' AND SRV.D_E_L_E_T_='' AND SRV.RV_INSS='S' "
	cQuery+= "WHERE SRA.D_E_L_E_T_='' "

	cQuery+= "ORDER BY QB_CESTAB,FILIAL,RA_CODSS,RA_MAT,RV_NATRSS,SINAL "
	cQuery := ChangeQuery(cQuery)

	If Select("TRB")>0
		DbSelectArea("TRB")
		TRB->(DbCloseArea())
	Endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRB",.F.,.T.)
	cTpGer:="SQL"    

	nTotRem:=0      
	nTotReg:=0
	nSubTot:=0
	cCodSalM:=Posicione("SRV",2,xFilial("SRV")+"0031","RV_COD")//Codigo do Salario Mensal
	cCodSalH:=Posicione("SRV",2,xFilial("SRV")+"0032","RV_COD")//Codigo do Salario Horista
	cCodFalt:=Posicione("SRV",2,xFilial("SRV")+"0054","RV_COD")//Codigo das Faltas  
          
	//Carrega Regua de Processamento
	SetPrc(0,0)      
	SetRegua( Len(aFunc) )
	
	DbSelectArea("TRB")
	TRB->(DbGoTop()) 
	
	If TRB->(!EOF())
		DbSelectArea("RCO")
		RCO->(DbGoTop())     
		RCO->(DbSetOrder(RetOrder("RCO","RCO_FILIAL+RCO_CODIGO")))
		If DbSeek(xFilial("RCO")+TRB->QB_CESTAB)
			cRazSoc:= ALLTRIM(RCO->RCO_NOME)
			cNISS  := RCO->RCO_NISS					  //Numero de Identificacao Social da Empresa
			cNIF   := RCO->RCO_NIF 					  //Numero Identificacao Fiscal da Empresa
			cNISSEE:= Substr(Alltrim(RCO->RCO_NESTAB),1,4)//Estabelecimento da Entidade Empregadora
		Endif	  
		DbSelectArea("TRB")						
	Endif
	
	Do While TRB->(!EOF())    	
	 	IncRegua() 

		If lEnd
			@Prow()+1,0 PSAY cCancel
			Exit
	    Endif          

		If cFilAnt <> TRB->FILIAL       //se filial eh diferente da anterior  
			nPagina += 1
			GeraCabMapa(cRazSoc, cNISS, cNIF, cNISSEE, nPagina)
			If nTotRem <> 0 
				GeraRodMapa(nTotReg, .T., nPorcTX)
				oPrint:Endpage()
			Endif       
			             
			nTotReg := 1
			cFilAnt := TRB->FILIAL
			cRegAnt := TRB->RA_CODSS
			nTotRem := 0
			nSubTot := 0
		ElseIf cRegAnt <> TRB->RA_CODSS 
			If nTotRem <> 0
				GeraRodMapa(nTotReg, .T., nPorcTX)
				oPrint:Endpage()
			Endif

			nPagina += 1
			GeraCabMapa(cRazSoc, cNISS, cNIF, cNISSEE, nPagina) 
			nTotReg := 1
			cRegAnt := TRB->RA_CODSS
			nTotRem := 0
			nSubTot := 0
		Endif
		
		//Verifica se existem Verbas de Salario de Mensalista, Salario de Horista
		nValMes:=0
		nValHor:=0
		nValFal:=0
  		If TRB->ALIAS=="SRC"
			DbSelectArea("SRC")
			SRC->(DbSetOrder(RetOrder("SRC","RC_FILIAL+RC_MAT+RC_PERIODO")))
			SRC->(DbGoTop())
			If DbSeek(TRB->FILIAL+TRB->RA_MAT+Alltrim(TRB->PERIODO))
				Do While SRC->(!EOF()) .And. Alltrim(SRC->RC_PERIODO)==Alltrim(TRB->PERIODO)
				    If Alltrim(SRC->RC_PD)==Alltrim(cCodSalM)
						nValMes:=SRC->RC_HORAS//Dias
					ElseIf Alltrim(SRC->RC_PD)==Alltrim(cCodSalH)
						DbSelectArea("RCF")
						RCF->(DbSetOrder(RetOrder("RCF","RCF_FILIAL+RCF_PER")))
						RCF->(DbGoTop()) 
						If DbSeek(xFilial("RCF")+TRB->PERIODO)
							cTurTrab:=Posicione("SRA",1,TRB->FILIAL+TRB->RA_MAT,"RA_TNOTRAB")//Posiciona no Turno do Trabalho do funcionario
							Do While RCF->(!EOF()) .And. RCF->RCF_PER==TRB->PERIODO
								If RCF->RCF_TNOTRA==cTurTrab
									nValHor:=RCF->RCF_DIATRA//Dias                        
									Exit
								Endif
								RCF->(DbSkip())
							End
						Endif
					ElseIf Alltrim(SRC->RC_PD)==Alltrim(cCodFalt)
					    nValFal:=SRC->RC_HORAS//Dias
					Endif
					SRC->(DbSkip())
				End	 
			Endif		
		Else            
			DbSelectArea("SRD")
			SRC->(DbSetOrder(RetOrder("SRD","RD_FILIAL+RD_MAT+RD_DATARQ+RD_PD")))
			SRC->(DbGoTop())
			If DbSeek(TRB->FILIAL+TRB->RA_MAT+Alltrim(TRB->PERIODO)+cCodSalM)
				nValMes:=SRC->RC_HORAS
			Endif
			SRC->(DbGoTop())
			If DbSeek(TRB->FILIAL+TRB->RA_MAT+Alltrim(TRB->PERIODO)+cCodSalH)
				DbSelectArea("RCF")
				RCF->(DbSetOrder(RetOrder("RCF","RCF_FILIAL+RCF_PER")))
				RCF->(DbGoTop()) 
				If DbSeek(xFilial("RCF")+TRB->PERIODO)
					cTurTrab:=Posicione("SRA",1,TRB->FILIAL+TRB->RA_MAT,"RA_TNOTRAB")//Posiciona no Turno do Trabalho do funcionario
					Do While RCF->(!EOF()) .And. RCF->RCF_PER==TRB->PERIODO
						If RCF->RCF_TNOTRA==cTurTrab
							nValHor:=RCF->RCF_DIATRA//Dias                        
							Exit
						Endif
						RCF->(DbSkip())
					End
				Endif
			Endif
			SRC->(DbGoTop())
			If DbSeek(TRB->FILIAL+TRB->RA_MAT+Alltrim(TRB->PERIODO)+cCodFalt)
			    nValFal:=SRC->RC_HORAS			
			Endif
		Endif	                                                     

		If nValMes==0 .And. nValHor==0         
			//Desconsiderado a informacao caso nao haja Verba de Salario Mensal ou Salario de Horista    
			TRB->(DbSkip())
			Loop
   		Else                                      
            nDiaTabr:=0 //Quantidade de Dias Trabalhado(Numerico)
			cDiaTabr:=""//Quantidade de Dias Trabalhado(Alfanumerico)
			cSinTabr:=""//Sinal Dias de Trabalho

           	//Dias Trabalhados descontado as faltas
			If nValMes > 0
				nDiaTabr := nValMes - nValFal
			ElseIf nValHor > 0
				nDiaTabr := nValHor - nValFal				
			Endif                                                   
			//Se dias trabalhados for maior que 30 considera 30 dias
			If nDiaTabr > 30
				nDiaTabr := 30	
			Endif  

			//Tratamento Dias Trabalhado
			For nCont := 1 To Len(Alltrim(Str(nDiaTabr)))
				If !Substr(Alltrim(Str(nDiaTabr)),nCont,1)$"-"
					cDiaTabr += Substr(Alltrim(Str(nDiaTabr)),nCont,1)
					cSinTabr := "0"							
				Else
					cSinTabr := "-"	
				Endif	              
			Next 
			cDiaTabr:=StrZero(Val(cDiaTabr),3)
		Endif   

		//Verificacao do Cadastro da Verba
		DbSelectArea("SRV")                         
		SRV->(DbSetOrder(RetOrder("SRV","RV_FILIAL+RV_COD")))
		SRV->(DbGoTop())
		If DbSeek(xFilial("SRV")+TRB->VERBA)
			cNatRem:=SRV->RV_NATRSS
			cNatRem:=Space(2-Len(cNatRem))+cNatRem
                
			cNomTab:=alltrim(TRB->NOMFUN)+SPACE(60-LEN(alltrim(TRB->NOMFUN)))//Nome do Tranbalhador
			cDatNas:=TRB->RA_NASC//Data de Nascimento
			cNISSPS:=TRB->RA_NISSPS 
			cPerTRB:=TRB->PERIODO
			nPosTx := aScan( aFunc , {|x| x[2]=TRB->RA_MAT }) 
			If nPosTx > 0
				nPorcTX:=aFunc[nPosTx][4]
			Endif                     

		    If nTotReg > 20
		    	GeraRodMapa(nTotReg, .F.)
				oPrint:EndPage()
				nTotReg := 1
			 	nSubTot := 0
			 	nPagina += 1
				GeraCabMapa(cRazSoc, cNISS, cNIF, cNISSEE, nPagina)
		    Endif
		    GeraDetMapa(nTotReg, cNISSPS, cNomTab, cDatNas, cPerTRB, cNatRem)
		    nTotReg += 1
		Endif
		
		TRB->(DbSkip())
	End
	GeraRodMapa(nTotReg, .T., nPorcTX)
	nSubTot := 0
	oPrint:EndPage()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GeraCabMapaºAutor  ³Christiane Vieira  º Data ³  03/12/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GeraCabMapa(cRazSoc, cNISS, cNIF, cNISSEE, nPag)
	oPrint:StartPage() 						//Inicia uma nova pagina   
            
	oPrint:say ( 0080, 0070, Upper(STR0001), oFont16n ) //Declaração de Remunerações
	
	oPrint:say ( 0080, 1100, STR0019, oFont09n ) //Identificação da Entidade Empregadora
    oPrint:Box ( 0120, 1100, 450, 2560 ) 	//BOX EMPRESA
    oPrint:say ( 0140, 1110, STR0020, oFont09n )  //Nome:
    oPrint:say ( 0145, 1230, cRazSoc, oFont09 )
	oPrint:line ( 0200, 1100, 0200, 2560 )  //LINHA VERTICAL - Dados da Empresa

    oPrint:Box ( 0120, 2615, 0180, 2675 ) 			//BOX 
    oPrint:say ( 0140, 2715, STR0033, oFont09n )	//Entrada Fora de Prazo

    oPrint:say ( 0220, 1110, STR0018, oFont09n ) //Número de Identificação da Segurança Social
    oPrint:say ( 0265, 1110, cNISS, oFont09 )		    
    oPrint:say ( 0220, 2100, STR0016, oFont09n )  //Código da Taxa	                                  
    oPrint:say ( 0265, 2100, TRB->RA_CODSS, oFont09 )		    

    oPrint:say ( 0220, 2615, STR0032, oFont09n )			//Data de Referência    
    oPrint:say ( 0265, 2615, Substr(cPerInf, 1, 4) + "/" + Substr(cPerInf, 5, 2), oFont09 )

    oPrint:say ( 0320, 1110, STR0017, oFont09n ) 	//Número de Identificação Fiscal
    oPrint:say ( 0365, 1110, cNIF, oFont09 ) 			    
    oPrint:say ( 0320, 2100, STR0015, oFont09n ) 	//Estabelecimento
    oPrint:say ( 0365, 2100, cCodEs, oFont09 ) 			    
    
    oPrint:say ( 0365, 2615, STR0030, oFont09n )			//Página nº
    oPrint:say ( 0365, 2815, cValToChar(nPag), oFont09 )	//Página nº

	oPrint:Box ( 550, 0025, 650, 3200 ) 	//BOX Cabeçalho - Funcionário
	oPrint:line ( 0550, 0105, 0650, 0105 )  //LINHA VERTICAL			
	oPrint:say ( 580, 0115, STR0013, oFont09n ) //Identificação
	oPrint:line ( 0550, 0405, 0650, 0405 )  //LINHA VERTICAL
	oPrint:say ( 580, 0425, STR0008, oFont09n ) //Nome Completo do Trabalhador
	oPrint:line ( 0600, 1505, 0600, 3200 )  //LINHA HORIZONTAL - Cabeçalho Funcionário   
	oPrint:line ( 0550, 1505, 0650, 1505 )  //LINHA VERTICAL
	oPrint:say ( 550, 1545, STR0007, oFont09n ) //Data de Nascimento
	oPrint:say ( 600, 1575, STR0003, oFont09 )  //Ano
	oPrint:line ( 0600, 1655, 0650, 1655 )  //LINHA VERTICAL
 	oPrint:say ( 600, 1695, STR0004, oFont09 ) //Mês
 	oPrint:line ( 0600, 1775, 0650, 1775 )  //LINHA VERTICAL 
 	oPrint:say ( 600, 1820, STR0005, oFont09 ) //Dia
	oPrint:line ( 0550, 1945, 0650, 1945 )  //LINHA VERTICAL  			
 	oPrint:say ( 550, 1975, STR0006, oFont09n ) //Data Remunerações
 	oPrint:say ( 600, 2020, STR0003, oFont09 ) //Ano
 	oPrint:line ( 0600, 2120, 0650, 2120 )  //LINHA VERTICAL
 	oPrint:say ( 600, 2170, STR0004, oFont09 ) //Mês
	oPrint:line ( 0550, 2330, 0650, 2330 )  //LINHA VERTICAL  			 			
 	oPrint:say ( 550, 2425, STR0002, oFont09n ) //Dias de Trabalho/Remunerações
 	oPrint:say ( 600, 2370, STR0012, oFont09 ) //Dias
 	oPrint:line ( 0600, 2475, 0650, 2475 )  //LINHA VERTICAL
 	oPrint:say ( 600, 2480, STR0009, oFont09 ) //Sinal
 	oPrint:line ( 0600, 2600, 0650, 2600 )  //LINHA VERTICAL
 	oPrint:say ( 600, 2615, STR0010, oFont09 ) //Valor das Remunerações
 	oPrint:line ( 0600, 3115, 0650, 3115 )  //LINHA VERTICAL
 	oPrint:say ( 600, 3125, STR0011, oFont09 ) //Cód.

Return                   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GeraDetMapaºAutor  ³Christiane Vieira  º Data ³  03/12/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GeraDetMapa(nTotReg, cNISSPS, cNomTab, cDatNas, cPerTRB, cNatRem)
	Local nTamLin := 70
	Local nLinIni := 650
	Local nPosIni := 670
	Local cSinal  := ""   

	cSinal := IIF(TRB->SINAL == "0", "", "-")

	oPrint:Box ( nLinIni + (nTamLin * (nTotReg - 1)), 0025, nLinIni + nTamLin + (nTamLin * (nTotReg - 1)), 3200 ) 	//BOX Cabeçalho - Funcionário	
	oPrint:line ( nLinIni + (nTamLin * (nTotReg - 1)), 0105, nLinIni + nTamLin + (nTamLin * (nTotReg - 1)), 0105 )  //LINHA VERTICAL			
	oPrint:line ( nLinIni + (nTamLin * (nTotReg - 1)), 0405, nLinIni + nTamLin + (nTamLin * (nTotReg - 1)), 0405 )  //LINHA VERTICAL
	oPrint:line ( nLinIni + (nTamLin * (nTotReg - 1)), 1505, nLinIni + nTamLin + (nTamLin * (nTotReg - 1)), 1505 )  //LINHA VERTICAL
	oPrint:line ( nLinIni + (nTamLin * (nTotReg - 1)), 1655, nLinIni + nTamLin + (nTamLin * (nTotReg - 1)), 1655 )  //LINHA VERTICAL
 	oPrint:line ( nLinIni + (nTamLin * (nTotReg - 1)), 1775, nLinIni + nTamLin + (nTamLin * (nTotReg - 1)), 1775 )  //LINHA VERTICAL 
	oPrint:line ( nLinIni + (nTamLin * (nTotReg - 1)), 1945, nLinIni + nTamLin + (nTamLin * (nTotReg - 1)), 1945 )  //LINHA VERTICAL  			
 	oPrint:line ( nLinIni + (nTamLin * (nTotReg - 1)), 2120, nLinIni + nTamLin + (nTamLin * (nTotReg - 1)), 2120 )  //LINHA VERTICAL
	oPrint:line ( nLinIni + (nTamLin * (nTotReg - 1)), 2330, nLinIni + nTamLin + (nTamLin * (nTotReg - 1)), 2330 )  //LINHA VERTICAL  			 			
 	oPrint:line ( nLinIni + (nTamLin * (nTotReg - 1)), 2475, nLinIni + nTamLin + (nTamLin * (nTotReg - 1)), 2475 )  //LINHA VERTICAL
 	oPrint:line ( nLinIni + (nTamLin * (nTotReg - 1)), 2600, nLinIni + nTamLin + (nTamLin * (nTotReg - 1)), 2600 )  //LINHA VERTICAL
 	oPrint:line ( nLinIni + (nTamLin * (nTotReg - 1)), 3115, nLinIni + nTamLin + (nTamLin * (nTotReg - 1)), 3115 )  //LINHA VERTICAL

	oPrint:say ( nPosIni + (nTamLin * (nTotReg - 1)), 0045, cValToChar(nTotReg), oFont09 ) //Numeração
	oPrint:say ( nPosIni + (nTamLin * (nTotReg - 1)), 0115, cNISSPS, oFont09 ) //Identificação 	
	oPrint:say ( nPosIni + (nTamLin * (nTotReg - 1)), 0425, cNomTab, oFont09 ) //Nome Completo do Trabalhador	
	oPrint:say ( nPosIni + (nTamLin * (nTotReg - 1)), 1550, Substr(cDatNas, 1, 4), oFont09 ) //Ano de Nascimento     
 	oPrint:say ( nPosIni + (nTamLin * (nTotReg - 1)), 1695, Substr(cDatNas, 5, 2), oFont09 ) //Mês de Nascimento
 	oPrint:say ( nPosIni + (nTamLin * (nTotReg - 1)), 1820, Substr(cDatNas, 7, 2), oFont09 ) //Dia de Nascimento
 	oPrint:say ( nPosIni + (nTamLin * (nTotReg - 1)), 2000, Substr(cPerTRB, 1, 4), oFont09 ) //Ano do Período
 	oPrint:say ( nPosIni + (nTamLin * (nTotReg - 1)), 2175, Substr(cPerTRB, 5, 2), oFont09 ) //Mês do Período
 	oPrint:say ( nPosIni + (nTamLin * (nTotReg - 1)), 2370, Transform(TRB->HORAS, "@E 99.99"), oFont09 ) //Dias 
 	oPrint:say ( nPosIni + (nTamLin * (nTotReg - 1)), 2490, cSinal, oFont09 ) //Sinal 
 	oPrint:say ( nPosIni + (nTamLin * (nTotReg - 1)), 2720, Transform(TRB->VALOR, "@E 999,999,999.99"), oFont09 ) //Valor das Remunerações
 	oPrint:say ( nPosIni + (nTamLin * (nTotReg - 1)), 3125, cNatRem, oFont09 ) //Cód.	 					

	IF TRB->SINAL == "0"//1-Provento|3-Base(Provento)
		nTotRem += TRB->VALOR
		nSubTot += TRB->VALOR
	Else//2-Desconto|4-Base(Desconto)         
		nTotRem += -TRB->VALOR
		nSubTot += -TRB->VALOR
	Endif			
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GeraRodMapaºAutor  ³Christiane Vieira  º Data ³  03/12/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GeraRodMapa(nTotReg, bImpTotais, nPorcTX)
	Local nCont := 0
	Local nTamLin := 70
	Local nLinIni := 650 
	Local nPosIni := 670
	Local nContrib  := 0                                
	Default nPorcTX := 0

	For nCont = nTotReg to 21
		oPrint:Box ( nLinIni + (nTamLin * (nTotReg - 1)), 0025, nLinIni + nTamLin + (nTamLin * (nTotReg - 1)), 3200 ) 	//BOX Rodapé - Funcionário	
		oPrint:line ( nLinIni + (nTamLin * (nTotReg - 1)), 0105, nLinIni + nTamLin + (nTamLin * (nTotReg - 1)), 0105 )  //LINHA VERTICAL		
	 	oPrint:line ( nLinIni + (nTamLin * (nTotReg - 1)), 2475, nLinIni + nTamLin + (nTamLin * (nTotReg - 1)), 2475 )  //LINHA VERTICAL
	 	oPrint:line ( nLinIni + (nTamLin * (nTotReg - 1)), 2600, nLinIni + nTamLin + (nTamLin * (nTotReg - 1)), 2600 )  //LINHA VERTICAL

		If !nTotReg == 21
			oPrint:line ( nLinIni + (nTamLin * (nTotReg - 1)), 0405, nLinIni + nTamLin + (nTamLin * (nTotReg - 1)), 0405 )  //LINHA VERTICAL
			oPrint:line ( nLinIni + (nTamLin * (nTotReg - 1)), 1505, nLinIni + nTamLin + (nTamLin * (nTotReg - 1)), 1505 )  //LINHA VERTICAL
			oPrint:line ( nLinIni + (nTamLin * (nTotReg - 1)), 1655, nLinIni + nTamLin + (nTamLin * (nTotReg - 1)), 1655 )  //LINHA VERTICAL
		 	oPrint:line ( nLinIni + (nTamLin * (nTotReg - 1)), 1775, nLinIni + nTamLin + (nTamLin * (nTotReg - 1)), 1775 )  //LINHA VERTICAL 
			oPrint:line ( nLinIni + (nTamLin * (nTotReg - 1)), 1945, nLinIni + nTamLin + (nTamLin * (nTotReg - 1)), 1945 )  //LINHA VERTICAL  			
		 	oPrint:line ( nLinIni + (nTamLin * (nTotReg - 1)), 2120, nLinIni + nTamLin + (nTamLin * (nTotReg - 1)), 2120 )  //LINHA VERTICAL
			oPrint:line ( nLinIni + (nTamLin * (nTotReg - 1)), 2330, nLinIni + nTamLin + (nTamLin * (nTotReg - 1)), 2330 )  //LINHA VERTICAL  			 			
		 	oPrint:line ( nLinIni + (nTamLin * (nTotReg - 1)), 3115, nLinIni + nTamLin + (nTamLin * (nTotReg - 1)), 3115 )  //LINHA VERTICAL
			nTotReg += 1		 	
		Endif
	Next
 	oPrint:say ( nPosIni + (nTamLin * (nTotReg - 1)), 1975, STR0027, oFont09n ) //Subtotal da Página
 	oPrint:say ( nPosIni + (nTamLin * (nTotReg - 1)), 2720, Transform(nSubTot, "@E 999,999,999.99"), oFont09n ) //Valor das Remunerações 	

 	If bImpTotais                                                               
 		nContrib := nTotRem * (nPorcTx / 100)

 		oPrint:say ( 2210, 1000, STR0014, oFont09n ) //Total das Remunerações - Cálculo das Contribuições
		oPrint:Box ( 2270, 1000, 2430, 2200 ) 	//BOX Rodapé - Totais

 		oPrint:say ( 2290, 1050, STR0028, oFont09 ) //Total Remunerações
 		oPrint:say ( 2290, 1530, STR0031, oFont09 ) //Taxa
 		oPrint:say ( 2290, 1750, STR0029, oFont09 ) //Total Contribuições

 		oPrint:say ( 2350, 1100, Transform(nTotRem, "@E 999,999,999.99") + "   X ", oFont09 )  //Total Remunerações 		
 		oPrint:say ( 2350, 1510, Transform(nPorcTX, "@E 999.99") + " %     = ", oFont09 )    //Taxa 		                
 		oPrint:say ( 2350, 1800, Transform(nContrib, "@E 999,999,999.99"), oFont09 ) //Total Contribuições
 	Endif
Return