#include "protheus.ch"
#include "topconn.ch"
#include "GPEM750.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPEM750  ³ Autor ³ SSERVICE		          ³ Data ³   24.05.08    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera o arquivo com os dados da Declaracao de Remuneracoes         ³±±
±±³          ³Seguranca Social de PORTUGAL -Layout DRI	        				 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Portugal                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³    FNC    ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Francisco Jr³10/02/2010³00002526-10³Compatibilizado para Gestao Corporativa   ³±±
±±³Tiago Malta ³15/10/2010³022608/2010³Alteração de ordenação dos registros.     ³±±
±±³Christiane V³25/11/2010³027389/2010³Correção da listagem e geração arquivo qdo³±±
±±³            ³          ³           ³existem funcionarios com diversos regimes ³±±
±±³            ³          ³           ³de contribuição social.                   ³±±
±±³  Marco A.  ³ 16/04/18 ³ DMINA-2310³Se remueven sentencias CriaTrab y se apli-³±±
±±³            ³          ³           ³ca FWTemporaryTable(), para el manejo de  ³±±
±±³            ³          ³           ³las tablas temporales.                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GPEM750()       

Local cFilIni     := " ", cFilFim := " ", cCcIni      := " ", cCcFim      := " ", cDepIni	  := " ", cDepFim	  := " "
Local cPerInf	  := " ", cNPgto  := " ", cCodEs	  := " "
Private cFiltSRA  := ""
Private cCadastro := OemToAnsi(STR0001)
Private aSays 	  := {}         
Private aButtons  := {}
Private aLogProc  := {} 
Private cProcesso := ""
Private cRoteiro  := ""
Private cPathFile := ""
Private cExtRel   := ".##R"  
Private cDestino  := ""    

nOpca 			  := 0            

Pergunte("GPM750",.F.)

cPathFile 		:= ( __RelDir + "GPEM750" + cExtRel )

AADD(aSays,OemToAnsi(STR0002))
AADD(aSays,OemToAnsi(STR0003))
AADD(aButtons, { 15,.T.,{|| If(File(cPathFile),(OurSpool( "GPEM750" ),Ms_Flush()),nOpca:=0)} } )
AADD(aButtons, { 17,.T.,{|| cFiltSRA := BuildExpr("SRA",,cFiltSRA) } } )
AADD(aButtons, {  5,.T.,{|| Pergunte("GPM750",.T. ) } } )
AADD(aButtons, {  1,.T.,{|o| nOpca := 1,FechaBatch()}} )
AADD(aButtons, {  2,.T.,{|o| FechaBatch() }} )      
//==================================================================================================================
//Montagem da Tela Inicial
//==================================================================================================================
FormBatch( cCadastro, aSays, aButtons )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega variaveis mv_par99 para variaveis do sistema      	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFilIni       := mv_par01
cFilFim       := mv_par02
cCcIni        := mv_par03
cCcFim        := mv_par04
cDepIni		  := mv_par05
cDepFim		  := mv_par06
cPerInf		  := mv_par07
cNPgto		  := mv_par08
cCodEs		  := mv_par09
cDestino      := mv_par10                                                          
//==================================================================================================================
//Caso haja a confirmacao do processo executa o processamento da geracao do arquivo                                 
//==================================================================================================================
If nOpca == 1
	Processa({|lEnd| GPM750Proc(@lEnd,cFiltSRA,cFilIni,cFilFim,cCcIni,cCcFim,cDepIni,cDepFim,cPerInf,cNPgto,cCodEs),STR0050}) //"Generación de la Declaración de Seguridad Social en disco"
Endif

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GPM750Proc³ Autor ³ SSERVICE		          ³ Data ³   24.05.08    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Geracao do Arquivo TXT da Declaracao de Remuneracoes Seguranca 	 ³±±
±±³          ³ Social         										    		 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Portugal                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GPM750Proc(lEnd,cFiltSRA,cFilIni,cFilFim,cCcIni,cCcFim,cDepIni,cDepFim,cPerInf,cNPgto,cCodE)

	//==================================================================================================================
	//Variaveis para tratamento via SQL
	//==================================================================================================================
	Local cQuery:="",cQryTX:="", cFiltro:="",cFunINSS:="",cMsgTX:=""
	//==================================================================================================================
	//Variaveis para tratamento via DBF
	//==================================================================================================================
	Local aCpo	 	:={},lExistTX:=.F.
	Local nValor	:=0
	Local cIndex    :="",cKey	 :="",cTRB:=""
	Local cMat:="",cNasc:="",cNome:="",cDep:="",cCdEstab:="",cDescEst:=""
	//==================================================================================================================
	//Variaveis para tratamento via LOG
	//==================================================================================================================
	Local aFunc		  :={}	
	Local aNatureza   :={}	
	Local aLogDesc    :={}
	Local aProcTitLog :={}
	Local aGPEM750Tit :={}
	Local aGPEM750Log :={}     
	Local cDescrNat	  :="" 
	//=================================================================================================================
	Local lCaractere:=.T.
	Local cCodSalM:="",cCodSalH:="",cCodFalt:="",cTurTrab:="",cTipGer:="",cCodTXE :="",cCodTXF:="",cPeriod:=""
	Local cNomTab :="",cDatNas :="",cArquivo:="",cRazSoc :="",cNISS  :="",cNIF    :="",CNISSEE:="",cValSin:=""
	Local cTotRem :="",cTSinRem:="",cTotCon :="",cTSinCon:="",cNatRem:="",cSinTabr:="",cDiaTabr:=""
	Local nCont   :=0 ,nTotRem :=0 ,nTotReg :=0 ,nPorcTX :=0 ,nTxEmp :=0 ,nTxFunc :=0 ,nContPosDec:=0
	Local aRegs   := {}
	Local lGerR3  := .F.
	Local cTotReg := ""
	Local nTotCon := 0 
	Local cNISSPS := ""
	Local cPerTRB := ""
	Local cChave  := ""
	Local nPosTx  := 0 
	Local nValorT := 0
	Local cTotalR := ""
	Local nTotalR := 0
	Local nRemTot := 0
	Local nConTot := 0
	Local cCodss  := ""
	
	cCcIni  :=Iif(ValType(cCcIni)	=="N",Alltrim(Str(cCcIni))	,cCcIni)
	cCcFim  :=Iif(ValType(cCcFim)	=="N",Alltrim(Str(cCcFim))	,cCcFim)
	cDepIni :=Iif(ValType(cDepIni)	=="N",Alltrim(Str(cDepIni))	,cDepIni)
	cDepFim :=Iif(ValType(cDepFim)	=="N",Alltrim(Str(cDepFim))	,cDepFim)
	cPerInf	:=Iif(ValType(cPerInf)	=="N",Alltrim(Str(cPerInf))	,cPerInf)
	cNPgto	:=Iif(ValType(cNPgto)	=="N",Alltrim(Str(cNPgto))	,cNPgto)
	cCodE 	:=Iif(ValType(cCodE)	=="N",Alltrim(Str(cCodE))	,cCodE)
	//=================================================================================================================
	//Traz a Taxa que sera utilizado para Calcular o Total da Contribuicao Seguridade Social
	//=================================================================================================================
	cCodTXE:=Posicione("SRV",2,xFilial("SRV")+"0783","RV_COD")//Taxa SS da Empresa//FGETCODFOL("783")
	cCodTXF:=Posicione("SRV",2,xFilial("SRV")+"0064","RV_COD")//Taxa SS do Funcionario//FGETCODFOL("0064")
	//=================================================================================================================
	If File(cPathFile)
		FERASE(cPathFile)//Deleta o Arquivo
	Endif
	//=============================================================================================================
	//Filtro definido por meio do Botao Filtro da Tela Inicial
	//=============================================================================================================  
	If Len(AllTrim(cFilTSRA)) > 0  
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
	//=================================================================================================================
	//Codigo da Natureza de Remuneracao
	//=================================================================================================================
	aAdd(aNatureza,STR0035)//"C-Comissoes"
	aAdd(aNatureza,STR0036)//"F-Subsidio de Ferias"
	aAdd(aNatureza,STR0037)//"N-Subsidio de Natal"
	aAdd(aNatureza,STR0038)//"P-Remuneracoes de Carater Permanente"
	aAdd(aNatureza,STR0039)//"X-Outros Subsidios"
	aAdd(aNatureza,STR0040)//"O-Forcas Armadas"
	aAdd(aNatureza,STR0041)//"1-Remuneracoes Variaveis"
	aAdd(aNatureza,STR0042)//"2-Remuneracoes referente a ferias pagas e nao gozadas"
	aAdd(aNatureza,STR0043)//"6-Diferencas de Vencimento"
	aAdd(aNatureza,STR0044)//"8-Exercicio Temporario de Funcoes"
	aAdd(aNatureza,STR0045)//"9-Promocoes
	
	//=================================================================================================================
	//Linhas que serao impressas no arquivo de log
	//=================================================================================================================
	aAdd( aLogProc , {"1", Replicate("=",130)                      	,"1"} ) 		
	aAdd( aLogProc,  {"1", STR0015                                	,"2"} )//Parametro
	aAdd( aLogProc , {"1", Replicate("-",130)                     	,"3"} )		
	aAdd( aLogProc,  {"1", STR0016+cFilIni+STR0022+cFilFim          ,"4"} )//Filial.....................:   Ate
	aAdd( aLogProc,  {"1", STR0017+cCcIni +STR0022+cCCFim           ,"5"} )//Centro de Custo............:   Ate
	aAdd( aLogProc,  {"1", STR0018+cDepIni+STR0022+cDepfIM          ,"6"} )//Departamento...............:   Ate
	aAdd( aLogProc,  {"1", STR0019+cPerInf                          ,"7"} )//Periodo....................:
	aAdd( aLogProc,  {"1", STR0020+cNPgto                           ,"8"} )//Numero de Pagamento........:
	aAdd( aLogProc,  {"1", STR0021+cCodE							,"9"} )//Codigo do Estabelecimento..:   
	aAdd( aLogProc , {"2", Replicate("=",130)                       ,"1"} ) 		
	aAdd( aLogProc,  {"2", STR0013                                  ,"2"} )//"Filtro utilizado pela opcao de Filtro da Tela Inicial"
	aAdd( aLogProc , {"2", Replicate("-",130)                       ,"3"} )		
	aAdd( aLogProc,  {"2", cFiltro                                  ,"4"} )   
	aAdd( aLogProc , {"4", Replicate("=",130)                       ,"01"} )
	aAdd( aLogProc , {"4", STR0008                                  ,"02"} )//"Funcionarios com Taxas de SS da Empresa e Funcionario"   
	aAdd( aLogProc , {"4", Replicate("-",130)                       ,"03"} ) 
	aAdd( aLogProc , {"4", Replicate("-",130)                       ,"06"} ) 
	aAdd( aLogProc , {"4", STR0009	                                ,"07"} )//"Funcionarios que nao constam abaixo nao possuem as duas taxas"  
	aAdd( aLogProc,  {"5", Replicate("=",130) 						,"1"} )
	aAdd( aLogProc,  {"5", STR0023        							,"2"} )//"Funcionario sem Valor Salario" 
	aAdd( aLogProc,  {"5", Replicate("-",130) 						,"3"} )
	aAdd( aLogProc,  {"5", Space(80)		 						,"8"} )  
	aAdd( aLogProc,  {"6", Replicate("=",130) 						,"500"} )
	aAdd( aLogProc,  {"6", STR0027        							,"510"} )//"Informacoes referente ao arquivo" 
	aAdd( aLogProc,  {"6", Replicate("-",130) 						,"520"} )
	aAdd( aLogProc,  {"6", Space(80)		 						,"530"} )

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
	cQryTX+= "AND QB_CESTAB = '"+cCodE+"' "
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
	cQryTX+="AND QB_CESTAB = '"+cCodE+"' "
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
		cMsgTX:=Alltrim(STR0004)+chr(10)+chr(30);
		+Alltrim(STR0005)+cCodTXE+chr(10)+chr(30); 
		+Alltrim(STR0006)+cCodTXF
		MsgAlert(cMsgTX,STR0007)
		aAdd( aLogProc , {"3", STR0004				,"1"} )//"Nao ha Funcionarios com as Taxas de Contribuicao SS:"  
		aAdd( aLogProc , {"3", Replicate("=",130)   ,"2"} ) 
		aAdd( aLogProc , {"3",cCodTXE+"-"+STR0005	,"3"} )//"Codigo da Verba da Taxa da Empresa "
		aAdd( aLogProc , {"3",cCodTXF+"-"+STR0006	,"4"} )//"Codigo da Verba da Taxa do Funcionario"  
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
		
		aAdd( aLogProc , {"4","->"+cCodTXE+"-"+STR0005	,"04"} ) //"Codigo da Verba da Taxa da Empresa "  
		aAdd( aLogProc , {"4","->"+cCodTXF+"-"+STR0006	,"05"} ) //"Codigo da Verba da Taxa do Funcionario"  
		For nCont:=1 To Len(aFunc)
			aAdd( aLogProc , {"4",aFunc[nCont][1]+"-"+aFunc[nCont][2]+"->"+aFunc[nCont][3],"08"+aFunc[nCont][1]+aFunc[nCont][2]} ) 
		Next                                                                  
		aAdd( aLogProc , {"4",Replicate("-",130) 				                    ,"09"} ) 		
		aAdd( aLogProc , {"4",STR0014+Alltrim(Str(Len(aFunc)))                      ,"10"} ) 
	Endif   
	
	//==============================================================================================================
	//MOVIMENTOS DO PERIODO (SRD)
	//==============================================================================================================
	cQuery:= "SELECT CASE WHEN RA_NOMECMP='' THEN RA_NOME ELSE RA_NOMECMP END NOMFUN, 'SRC' ALIAS,  "
	cQuery+= "RA_FILIAL FILIAL,RA_MAT ,RA_NASC ,RA_NISSPS,RA_DEPTO,QB_DESCRIC,RC_PERIODO PERIODO, RC_ROTEIR ROTEIRO, "
	cQuery+= "RC_PD VERBA,QB_CESTAB,RC_VALOR VALOR, RV_NATRSS,RA_CODSS, "
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
	cQuery+= "RD_PD VERBA,QB_CESTAB,RD_VALOR VALOR, RV_NATRSS,RA_CODSS, "    
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

	//=======================================================================================
	//Montagem do Arquivo TXT
	//=======================================================================================
	nTotRem:=0      
	nTotReg:=0
	cCodSalM:=Posicione("SRV",2,xFilial("SRV")+"0031","RV_COD")//Codigo do Salario Mensal
	cCodSalH:=Posicione("SRV",2,xFilial("SRV")+"0032","RV_COD")//Codigo do Salario Horista
	cCodFalt:=Posicione("SRV",2,xFilial("SRV")+"0054","RV_COD")//Codigo das Faltas  
	
	DbSelectArea("TRB")
	TRB->(DbGoTop())
	If TRB->(!EOF())
		Do While TRB->(!EOF())    
			lR1:=.T. 			    
			cCEst:=TRB->QB_CESTAB
			Do While TRB->(!EOF()).And.cCEst==TRB->QB_CESTAB
				If lR1
					DbSelectArea("RCO")
					RCO->(DbGoTop())     
					RCO->(DbSetOrder(RetOrder("RCO","RCO_FILIAL+RCO_CODIGO")))
					If DbSeek(xFilial("RCO")+TRB->QB_CESTAB)
						cArquivo := cDestino
						nHdlArq  := fCreate(cArquivo)
						//=====================================
						//Gravacao do Registro R0              
						//=====================================
						cGrava:="R0RC4008"+Space(02)+"01"+Space(106)
						fWrite(nHdlArq,cGrava,118)
						fWrite(nHdlArq,CHR(13)+CHR(10))
						cRazSoc:=ALLTRIM(RCO->RCO_NOME)
						cNISS  :=RCO->RCO_NISS					  //Numero de Identificacao Social da Empresa
						cNIF   :=RCO->RCO_NIF 					  //Numero Identificacao Fiscal da Empresa
						CNISSEE:=Substr(Alltrim(RCO->RCO_NESTAB),1,4)//Estabelecimento da Entidade Empregadora
						//=====================================
						//Gravacao do Registro R1              
						//=====================================
						fWrite(nHdlArq,"R1",2)
						fWrite(nHdlArq,cNISS,11)
						fWrite(nHdlArq,CNISSEE,4)
						fWrite(nHdlArq,cNIF,9)  
						cGrava:=cRazSoc+SPACE(66-LEN(cRazSoc))
						fWrite(nHdlArq,cGrava,66)
						cGrava:=TRB->PERIODO+SPACE(20)
						fWrite(nHdlArq,cGrava,26)
						fWrite(nHdlArq,CHR(13)+CHR(10))                
						aAdd( aLogProc,  {"6",STR0028+Alltrim(cRazSoc)                           ,"600"} )//Razao Social					
						aAdd( aLogProc,  {"6",STR0029+cNISS+Space(60-Len(cNISS))+" "+STR0030+cNIF,"601"} )//"Num. Ident.Fiscal Empresa: "#"Estab. Entidade Fiscal: "
						aAdd( aLogProc,  {"6",Replicate("_",130)            ,"602"} )
						lR1:=.F.
					Else
						TRB->(DbSkip())
						Loop
					Endif
				Endif      
				//----------------------------------------------------------------------------
				//Verifica se existe Verbas de Salario de Mensalista, Salario de Horista
				//e Faltas. 			
				//----------------------------------------------------------------------------
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
				//=================================================================
	            //Desconsiderado a informacao caso nao haja Verba de Salario Mensal 
	            //ou Salario de Horista    
	            //===================================================================
				If nValMes==0 .And. nValHor==0         
				 	aAdd( aLogProc,  {"5",TRB->FILIAL+"-"+TRB->RA_MAT ,"4"+TRB->RA_MAT} )
					TRB->(DbSkip())
					Loop
	            Else                                      
	            	nDiaTabr:=0 //Quantidade de Dias Trabalhado(Numerico)
					cDiaTabr:=""//Quantidade de Dias Trabalhado(Alfanumerico)
					cSinTabr:=""//Sinal Dias de Trabalho
	            	//=====================================
	            	//Dias Trabalhados descontado as faltas
	            	//======================================
	             	If nValMes>0
						nDiaTabr:=nValMes-nValFal
					ElseIf nValHor>0
						nDiaTabr:=nValHor-nValFal				
					Endif                                                   
					//=====================================
					//Se dias trabalhados for maior que 30 
					//considera 30 dias
					//=====================================
					If nDiaTabr>30
						nDiaTabr:=30	
					Endif  
					//===============================
					//Tratamento Dias Trabalhado
					//===============================
					For nCont:=1 To Len(Alltrim(Str(nDiaTabr)))
						If !Substr(Alltrim(Str(nDiaTabr)),nCont,1)$"-"
							cDiaTabr+=Substr(Alltrim(Str(nDiaTabr)),nCont,1)
							cSinTabr:="0"							
						Else
							cSinTabr:="-"	
						Endif	              
					Next 
					cDiaTabr:=StrZero(Val(cDiaTabr),3)
				Endif   
				//----------------------------------------------------------------------------
				//Verificacao do Cadastro da Verba
				//----------------------------------------------------------------------------                    
				DbSelectArea("SRV")                         
				SRV->(DbSetOrder(RetOrder("SRV","RV_FILIAL+RV_COD")))
				SRV->(DbGoTop())
				If DbSeek(xFilial("SRV")+TRB->VERBA)
					cNatRem:=SRV->RV_NATRSS
					cNatRem:=Space(2-Len(cNatRem))+cNatRem
	                
					//=====================================
					//Gravacao do Registro R2              
					//=====================================
					cNomTab:=alltrim(TRB->NOMFUN)+SPACE(60-LEN(alltrim(TRB->NOMFUN)))//Nome do Tranbalhador
					cDatNas:=TRB->RA_NASC//Data de Nascimento
					cNISSPS:=TRB->RA_NISSPS 
					cPerTRB:=TRB->PERIODO
					nPosTx := aScan( aFunc , {|x| x[2]=TRB->RA_MAT })
					
					IF nPosTx > 0
						nPorcTX:=aFunc[nPosTx][4]
					ENDIF
					
					IF ( nPosReg :=  aScan( aRegs , {|x| x[1]=TRB->FILIAL .and. x[2]=TRB->RA_MAT .and. x[4]=TRB->RV_NATRSS } ) ) > 0  
						aRegs[nPosReg][3] += TRB->VALOR
					ELSE       
						aAdd( aRegs , { TRB->FILIAL , TRB->RA_MAT , TRB->VALOR , TRB->RV_NATRSS , TRB->RA_CODSS , TRB->SINAL  } )
					Endif
					
					TRB->(dbskip())
					
					IF aScan( aRegs , {|x| x[1]=TRB->FILIAL .and. x[2]=TRB->RA_MAT .and. x[4]=TRB->RV_NATRSS .and. x[6]=TRB->SINAL } ) == 0  
					    
						IF aScan( aRegs , {|x| x[5]=TRB->RA_CODSS } ) == 0 
							lGerR3 := .T.
						ENDIF
						
						//Tratamento do Valor
						nValorT := aRegs[1][3]
						cValSin := aRegs[1][6]				
						cVerba:=""     
						lCaractere:=.F.
						For nCont:=1 To Len(Alltrim(Str(Round(nValorT,2))))
							If !Substr(Alltrim(Str(nValorT)),nCont,1)$"."
								cVerba+=Substr(Alltrim(Str(nValorT)),nCont,1)
							Else
								lCaractere:=.T.
								nContPosDec:=nCont//Posicao do Ponto
							Endif
						Next   
						If lCaractere
		                	If Len(Substr(cVerba,nContPosDec,Len(cVerba)))==1
		                		cVerba:=cVerba+"0"
		                	Endif	
		                	lCaractere:=.F.
		                Else
							cVerba:=cVerba+"00"                	
		                Endif
		                            
		                IF cValSin == "0"//1-Provento|3-Base(Provento)
							nTotRem+=Val(Substr(cVerba,1,Len(cVerba)-2)+"."+Substr(cVerba,Len(cVerba)-1,2))
						Else//2-Desconto|4-Base(Desconto)         
							nTotRem+=-Val(Substr(cVerba,1,Len(cVerba)-2)+"."+Substr(cVerba,Len(cVerba)-1,2))
						Endif             
						
						fWrite(nHdlArq,"R2",2)
						fWrite(nHdlArq,cNISS,11) //Numero de Identificacao Social da Empresa                   
						fWrite(nHdlArq,cNISSEE,4)//Codigo do Estabelecimento   
						fWrite(nHdlArq,cNISSPS,11)//Numero de Identificacao da SS do Trabalhador
						fWrite(nHdlArq,cNomTab,60)
						fWrite(nHdlArq,cDatNas,8)
						fWrite(nHdlArq,cPerTRB,6) //Mes de Referencia  
						fWrite(nHdlArq,cDiaTabr,3)//Dias Trabalhados
						fWrite(nHdlArq,cSinTabr,1)//Sinal Dia Trabalhado(0 ou -)
						fWrite(nHdlArq,cNatRem,2)//codigo da Natureza         
						fWrite(nHdlArq,StrZero(Val(cVerba),9),9)//Valor da Remessa
						fWrite(nHdlArq,cValSin,1)//Sinal da Remessa(0 ou -) 
						fWrite(nHdlArq,CHR(13)+CHR(10)) 
						//=================================
						//Gravacao do Detalhe do Arquivo   
						//=================================  
						For nCont:=1 To Len(aNatureza)
							If Substr(aNatureza[nCont],1,1)==Upper(Alltrim(cNatRem))	
								cDescrNat:=aNatureza[nCont]
								Exit
							Endif
						Next 
						
						nTotReg++//Contador de registro R2 que sera utilizado no R3
						nTotalR++//Contador Log
	
						aAdd( aLogProc,  {"6",STR0031+Alltrim(cNomTab)+Space(60-Len(Alltrim(cNomTab)))+" "+STR0032+"   "+ cNISSPS, "7"+Alltrim(Str(nTotReg))+"0"} )
						aAdd( aLogProc,  {"6",STR0033+cDescrNat+Space(61-Len(cDescrNat))+STR0034+Transform(Val(Substr(cVerba,1,Len(cVerba)-2)+"."+Substr(cVerba,Len(cVerba)-1,2)),"@E 999,999,999.99"),"7"+Alltrim(Str(nTotReg))+"1"} )
						aAdd( aLogProc,  {"6",Space(118),"7"+Alltrim(Str(nTotReg))+"4"} )
						
						IF lGerR3
							//=========================================================================
							//Se a Totalizacao da Remuneracao for negativo informe - senao informe 0   
							//=========================================================================         
							If AT("-",ALLTRIM(STR(nTotRem)))>0
								cTSinRem:="-"
							Else
								cTSinRem:="0"			
							Endif                           
							//==============================
							//Tratamento do Total de Remessa
							//===============================
							cTotRem:=""
							For nCont:=1 To Len(Alltrim(Str(nTotRem)))
								If !Substr(Alltrim(Str(nTotRem)),nCont,1)$"-."
									cTotRem+=Substr(Alltrim(Str(nTotRem)),nCont,1)
								Endif	              
							Next
							cTotRem:=StrZero(Val(cTotRem),14)
							//=====================
					        //Taxa Contributiva    
					        //=====================
							cPorcTX:=Substr(Alltrim(Str(nPorcTX)),1,AT(".",ALLTRIM(STR(nPorcTX)))-1)+ iif( len(Substr(Alltrim(Str(nPorcTX)),AT(".",ALLTRIM(STR(nPorcTX)))+1,2)) > 1 , Substr(Alltrim(Str(nPorcTX)),AT(".",ALLTRIM(STR(nPorcTX)))+1,2) , "0" + Substr(Alltrim(Str(nPorcTX)),AT(".",ALLTRIM(STR(nPorcTX)))+1,2) )
							//=====================
							//Total da Contribuicao
							//===================== 
							nTotCon:=Round(((nTotRem/100)*nPorcTX),2)
							If AT("-",ALLTRIM(STR(nTotCon)))>0
								cTSinCon:="-"
							Else         
								cTSinCon:="0"	 
							Endif                                
							
							cTotCon:=""
							For nCont:=1 To Len(Alltrim(Str(nTotCon)))
								If !Substr(Alltrim(Str(nTotCon)),nCont,1)$"-."
									cTotCon+=Substr(Alltrim(Str(nTotCon)),nCont,1)
								Endif	              
							Next          
							cTotCon:=Strzero(Val(cTotCon),12)
							//=========================
							//Total de Registro R3
							//=========================
							cTotReg:=Alltrim(Str(nTotReg))
							cTotReg:=StrZero(Val(cTotReg),6)
							//=========================================================================
							cGrava:="R3"+SUBSTR(ALLTRIM(cNISS),1,11)+CNISSEE+"99999999999"+cTotRem+cTSinRem+cTotCon+cTSinCon+cPorcTX+cTotReg+Space(52)
							fWrite(nHdlArq,cGrava,118)
							fWrite(nHdlArq,CHR(13)+CHR(10))
							
							nConTot+= nTotCon // Total Contribuição Log
							nRemTot+= nTotRem // Total Remunerações log							
							lGerR3 := .F.  
							cTotalR:=Alltrim(Str(nTotalR))
							cTotalR:=StrZero(Val(cTotalR),6)
							aAdd( aLogProc, {"8",Replicate("=",130)                               ,"0"} )//"Total de Registro
							aAdd( aLogProc, {"8",STR0026+Alltrim(STR(VAL(cTotalR)))+"   "+STR0024+Transform(nRemTot,"@E 999,999,999.99")+"   "+STR0025+Transform(nConTot,"@E 999,999,999.99"),"1"} )//"Total de Registro"#Total Remuneracao:#Total Contribuicao:"
							aAdd( aLogProc, {"8",Replicate("=",130)                               ,"0"} )//"Total de Registro						
							
							nTotRem:= 0
							nTotReg:= 0
							nConTot:= 0
							nRemTot:= 0 
							nTotalR:= 0
	
							//TRB->(DbSkip())
							IF TRB->(!EOF())
								//=====================================
								//Gravacao do Registro R1              
								//=====================================
								fWrite(nHdlArq,"R1",2)
								fWrite(nHdlArq,cNISS,11)
								fWrite(nHdlArq,CNISSEE,4)
								fWrite(nHdlArq,cNIF,9)  
								cGrava:=cRazSoc+SPACE(66-LEN(cRazSoc))
								fWrite(nHdlArq,cGrava,66)
								cGrava:=TRB->PERIODO+SPACE(20)
								fWrite(nHdlArq,cGrava,26)
								fWrite(nHdlArq,CHR(13)+CHR(10))                
								
								aRegs := {}					
								LOOP
							ENDIF 
							         
						ENDIF      
						
						aRegs := {}
						LOOP
					ELSE
						LOOP					
					ENDIF	    				
				Endif
				TRB->(DbSkip())
			End                                                                    
			fClose(nHdlArq)
		End
	Else
		MsgAlert( STR0048 , STR0049)
	Endif
	
	//aSort(aLogProc,,,{|x,y| x[1]+x[3] < y[1]+y[3] }) // coloca o log em ordem por tipo de ocorrencia             
	aAdd( aLogProc, {"9",STR0010 + " " + Time() + "  "  + Dtoc( MsDate() ),""} )//"Final do Processo de Geracao"
	aLogRenova := {}
	For nCont := 1 To Len(aLogProc)
		aAdd(aLogDesc,aLogProc[nCont][2])
	Next
	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  ³Adiciona Informacoes do Processamento no Log Geral           			³
	  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	aAdd( aProcTitLog       , STR0011        )//	"Informacoes do Processo de Geracao do Arquivo de Seguranca Social" 
	aAdd( aGPEM750Tit		, aProcTitLog[1] )
	aAdd( aGPEM750Log		, aLogDesc       )
	MsAguarde( { || fMakeLog(aGPEM750Log,aGPEM750Tit,"",.T.,"GPEM750",STR0012,"M","P") } ,  STR0012) //"Log de Ocorrencias"
		
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Gpm750Dir ºAutor  ³Tiago Malta         º Data ³  09/14/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função para selecionar destino da geração do arquivo.      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Gpm750Dir()

Local _mvRet  := Alltrim(ReadVar())
Local _cPath  := mv_par10

_cPath:=cGetFile( STR0046 ,STR0047 ,0,_cPath,.F.,GETF_RETDIRECTORY+GETF_LOCALFLOPPY+GETF_LOCALHARD) 

&_mvRet := _cPath

Return