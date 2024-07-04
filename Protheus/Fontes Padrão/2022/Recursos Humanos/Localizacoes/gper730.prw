#INCLUDE "PROTHEUS.CH"
#Include "TOPCONN.Ch"  
#Include "GPER730.Ch"  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPER730  ³ Autor ³ Marco Kato                   ³ Data ³ 30/05/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio Listagem Seguradora	                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Emerson  ³ Alteracao da tabela S021 para S022.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³   FNC    ³          Motivo da Alteracao              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alex        ³ 04/01/10 ³031140    ³Adaptação para a Gestão Corporativa,       ³±±
±±³            ³          ³ /2009    ³respeitar o grupo campos de filiais.       ³±±
±±³  Marco A.  ³ 16/04/18 ³DMINA-2310³Se remueven sentencias CriaTrab y se apli- ³±± 
±±³			   ³		  ³          ³ca FWTemporaryTable(), para el manejo de   ³±±
±±³			   ³		  ³          ³las tablas temporales.                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GPER730()

	Local aCpo:={}          
	Local nCont	 :=0
	Local cIndex :="",cKey   :=""        
	Local cCatSra:="",SitSra :=""
	Local cFilIni:="",cFilFim:=Replicate("Z", FwGetTamFilial),cMatIni:="",cMatFim:="ZZZZZZ",cCCini :="",cCCFim:="ZZZZZZZZZ" 
	Local cDepIni:="",cDepFim:="ZZZZZZZZZ",cSegIni:="",cSegFim:="ZZ",cSituac:="ADFT",cCateg:="ACDEGHMPST" 
	Local cPerInf:="",cNumPgt:=""
	
	Local wnrel                  
	Private cString := "SRA"
	Private Limite  := 132
	Private Titulo  := STR0031 //"Listado para la Aseguradora"
	Private cDesc1   := STR0032 //"Este informe va a imprimir la relacón de"
	Private cDesc2   := STR0033 //"Empleados asociados a la Aseguradora"
	Private cDesc3   :=""
	Private tamanho  := "G"
	Private aOrdem   := {}
	Private cPerg    := "GPR730"
	Private aReturn  := { STR0034, 1, STR0035, 1, 1, 1, "",1 } //"A Rayas" - "Administración"
	Private nomeprog := "GPER730"
	Private nLastKey := 0
	Private cAlias   := ""
	
	m_pag := 01
	wnrel := "GPER730"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica as perguntas selecionadas                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	pergunte("GPR730",.F.)
	wnrel:=SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,,,Tamanho)
	If nLastKey == 27
		dbClearFilter()
		Return
	Endif
	
	SetDefault(aReturn,cString)
	
	If nLastKey == 27
		dbClearFilter()
		Return
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                              ³
	//³ mv_par01            // Filial De			                      ³
	//³ mv_par02            // Filial Ate                                 ³  
	//³ mv_par03            // Matricula De                               ³
	//³ mv_par04            // Matricula Ate                              ³  
	//³ mv_par05            // Centro de Custo De                         ³
	//³ mv_par06            // Centro de Custo Ate                        ³  
	//³ mv_par07            // Departamento De                            ³
	//³ mv_par08            // Departamento Ate                           ³  
	//³ mv_par09            // Seguro De                                  ³
	//³ mv_par10            // Seguro ate                                 ³  
	//³ mv_par11            // Situacoes                                  ³
	//³ mv_par12            // Categoria                                  ³  
	//³ mv_par13            // Periodo                                    ³
	//³ mv_par14            // Numero de Pagamento                        ³  
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	cFilIni:= mv_par01            							// Filial De
	cFilFim:= Iif(mv_par02=Space(FwGetTamFilial),Replicate("Z", FwGetTamFilial),mv_par02)            // Filial Ate
	cMatIni:= mv_par03            							// Matricula De
	cMatFim:= Iif(Empty(mv_par04),"ZZZZZZ",mv_par04)        // Matricula Ate
	cCCini := mv_par05            							// Centro de Custo De
	cCCFim := Iif(Empty(mv_par06),"ZZZZZZZZZ",mv_par06)     // Centro de Custo Ate
	cDepIni:= mv_par07            							// Departamento De
	cDepFim:= Iif(Empty(mv_par08),"ZZZZZZZZZ",mv_par08)     // Departamento Ate
	cSegIni:= mv_par09            							// Seguro De
	cSegFim:= Iif(Empty(mv_par10),"ZZ",mv_par10)            // Seguro ate
	cSituac:= mv_par11            							// Situacoes
	cCateg := mv_par12            							// Categoria
	cPerInf:= mv_par13            							// Periodo
	cNumPgt:= mv_par14            							// Numero de Pagamento
	
	cCatSra:=""
	cSitSra:=""
	For nCont:=1 To Len(Alltrim(cCateg))
		cCatSra+="'"+Substr(Alltrim(cCateg),nCont,1)+"',"
	Next  
	cCatSra:=Substr(cCatSra,1,Len(cCatSra)-1)
	For nCont:=1 To Len(Alltrim(cSituac))
		cSitSra+="'"+Substr(Alltrim(cSituac),nCont,1)+"',"
	Next
	cSitSra:=Substr(cSitSra,1,Len(cSitSra)-1)                    
	//==================================================================================================================
	//VIA SRC - MOVIMENTOS MENSAIS   
	//==================================================================================================================
	//SEGURO POR EMPRESA -->COD. DO SEGURO NO CADASTRO DO FUNCIONARIO EM BRANCO 
	//==================================================================================================================
	cQuery := "SELECT RA_FILIAL,SUBSTRING(RCC_CONTEU,"+alltrim(str(FwGetTamFilial+1))+",2) RA_CODSEG, RA_MAT, RA_NOME, RA_CODFUNC, "
	cQuery += "RA_SALARIO,RC_PD PD,RC_PERIODO PERIODO,RC_HORAS HORAS,RC_VALOR VALOR "
	cQuery += "FROM " + RetSqlName("SRA")+" SRA "
	cQuery += "INNER JOIN " + RetSqlName("SRC")+" SRC ON "
	cQuery += "RC_FILIAL=RA_FILIAL "
	cQuery += "AND RC_MAT=RA_MAT "
	cQuery += "AND RC_PERIODO='"+UPPER(cPerInf)+"' "
	cQuery += "AND RC_SEMANA ='"+UPPER(cNumPgt)+"' "	
	cQuery += "AND SRC.D_E_L_E_T_ <> '*' "
	cQuery += "INNER JOIN " + RetSqlName("RCC")+" RCC ON "
	cQuery += "SUBSTRING(RCC_CONTEU,1,"+alltrim(str(FwGetTamFilial))+")=RA_FILIAL "
	cQuery += "AND RCC_CODIGO='S022' "
	cQuery += "AND SUBSTRING(RCC_CONTEU,"+alltrim(str(FwGetTamFilial+1))+",2) BETWEEN '"+UPPER(cSegIni)+"' AND '"+UPPER(cSegFim)+"' "       	
	cQuery += "AND RCC.D_E_L_E_T_ <> '*' "
	cQuery += "WHERE SRA.D_E_L_E_T_ <> '*'  "                                        
	cQuery += "AND RA_FILIAL 	BETWEEN '"+UPPER(cFilIni)+"' AND '"+UPPER(cFilFim)+"' "
	cQuery += "AND RA_MAT 	    BETWEEN '"+UPPER(cMatIni)+"' AND '"+UPPER(cMatFim)+"' "       
	cQuery += "AND RA_CC 		BETWEEN '"+UPPER(cCCIni)+"' AND '"+UPPER(cCCFim)+"' "       
	cQuery += "AND RA_DEPTO 	BETWEEN '"+UPPER(cDepIni)+"' AND '"+UPPER(cDepFim)+"' "       
	cQuery += "AND RA_TIPOPGT IN ("+cCatSra+") "
	cQuery += "AND RA_CODCAT IN ("+cSitSra+") "
	cQuery += "AND RA_CODSEG='' "
	//==================================================================================================================
	cQuery += "UNION "
	//==================================================================================================================
	//SEGURO POR FUNCIONARIO -->COD. DO SEGURO NO CADASTRO DO FUNCIONARIO PREENCHIDO 
	//==================================================================================================================
	cQuery += "SELECT RA_FILIAL,RA_CODSEG, RA_MAT, RA_NOME, RA_CODFUNC,"
	cQuery += "RA_SALARIO,RC_PD PD,RC_PERIODO PERIODO,RC_HORAS HORAS,RC_VALOR VALOR 
	cQuery += "FROM " + RetSqlName("SRA")+" SRA "
	cQuery += "INNER JOIN " + RetSqlName("SRC")+" SRC ON "
	cQuery += "RC_FILIAL=RA_FILIAL "
	cQuery += "AND RC_MAT=RA_MAT "
	cQuery += "AND RC_PERIODO='"+UPPER(cPerInf)+"' "
	cQuery += "AND RC_SEMANA ='"+UPPER(cNumPgt)+"' "	
	cQuery += "AND SRC.D_E_L_E_T_ <> '*' "
	cQuery += "WHERE SRA.D_E_L_E_T_ <> '*' "
	cQuery += "AND RA_FILIAL 	BETWEEN '"+UPPER(cFilIni)+"' AND '"+UPPER(cFilFim)+"' "
	cQuery += "AND RA_MAT 	    BETWEEN '"+UPPER(cMatIni)+"' AND '"+UPPER(cMatFim)+"' "       
	cQuery += "AND RA_CC 		BETWEEN '"+UPPER(cCCIni)+"' AND '"+UPPER(cCCFim)+"' "       
	cQuery += "AND RA_DEPTO 	BETWEEN '"+UPPER(cDepIni)+"' AND '"+UPPER(cDepFim)+"' "   
	cQuery += "AND RA_CODSEG    BETWEEN '"+UPPER(cSegIni)+"' AND '"+UPPER(cSegFim)+"' "     
	cQuery += "AND RA_TIPOPGT IN ("+cCatSra+") "
	cQuery += "AND RA_CODCAT IN ("+cSitSra+") "
	cQuery += "AND RA_CODSEG<>'' "
	//==================================================================================================================
	cQuery += "UNION "//UNIAO ENTRE OS MOVIMENTOS MENSAIS E HISTORICO DE MOVIMENTOS 
	//==================================================================================================================
	//SEGURO POR EMPRESA -->COD. DO SEGURO NO CADASTRO DO FUNCIONARIO EM BRANCO  
	//==================================================================================================================
	cQuery += "SELECT RA_FILIAL,SUBSTRING(RCC_CONTEU,"+alltrim(str(FwGetTamFilial+1))+",2) RA_CODSEG, RA_MAT, RA_NOME, RA_CODFUNC, "
	cQuery += "RA_SALARIO,RD_PD PD,RD_DATARQ PERIODO,RD_HORAS HORAS,RD_VALOR VALOR "
	cQuery += "FROM " + RetSqlName("SRA")+" SRA "
	cQuery += "INNER JOIN " + RetSqlName("SRD")+" SRD ON "
	cQuery += "RD_FILIAL=RA_FILIAL "
	cQuery += "AND RD_MAT=RA_MAT "
	cQuery += "AND RD_DATARQ ='"+UPPER(cPerInf)+"' "
	cQuery += "AND RD_SEMANA ='"+UPPER(cNumPgt)+"' "	
	cQuery += "AND SRD.D_E_L_E_T_ <> '*' "
	cQuery += "INNER JOIN " + RetSqlName("RCC")+" RCC ON "
	cQuery += "SUBSTRING(RCC_CONTEU,1,"+alltrim(str(FwGetTamFilial))+")=RA_FILIAL "
	cQuery += "AND RCC_CODIGO='S022' "
	cQuery += "AND SUBSTRING(RCC_CONTEU,"+alltrim(str(FwGetTamFilial+1))+",2) BETWEEN '"+UPPER(cSegIni)+"' AND '"+UPPER(cSegFim)+"' "       	
	cQuery += "AND RCC.D_E_L_E_T_ <> '*' "
	cQuery += "WHERE SRA.D_E_L_E_T_ <> '*'  "
	cQuery += "AND RA_FILIAL 	BETWEEN '"+UPPER(cFilIni)+"' AND '"+UPPER(cFilFim)+"' "
	cQuery += "AND RA_MAT 	    BETWEEN '"+UPPER(cMatIni)+"' AND '"+UPPER(cMatFim)+"' "       
	cQuery += "AND RA_CC 		BETWEEN '"+UPPER(cCCIni)+"' AND '"+UPPER(cCCFim)+"' "       
	cQuery += "AND RA_DEPTO 	BETWEEN '"+UPPER(cDepIni)+"' AND '"+UPPER(cDepFim)+"' "   
	cQuery += "AND RA_TIPOPGT IN ("+cCatSra+") "
	cQuery += "AND RA_CODCAT IN ("+cSitSra+") "
	cQuery += "AND RA_CODSEG='' "
	//==================================================================================================================
	cQuery += "UNION "
	//==================================================================================================================
	//SEGURO POR FUNCIONARIO -->COD. DO SEGURO NO CADASTRO DO FUNCIONARIO PREENCHIDO  
	//==================================================================================================================
	cQuery += "SELECT RA_FILIAL,RA_CODSEG, RA_MAT, RA_NOME, RA_CODFUNC,"
	cQuery += "RA_SALARIO,RD_PD PD,RD_DATARQ PERIODO,RD_HORAS HORAS,RD_VALOR VALOR 
	cQuery += "FROM " + RetSqlName("SRA")+" SRA "
	cQuery += "INNER JOIN " + RetSqlName("SRD")+" SRD ON "
	cQuery += "RD_FILIAL=RA_FILIAL "
	cQuery += "AND RD_MAT=RA_MAT "
	cQuery += "AND RD_DATARQ ='"+UPPER(cPerInf)+"' "
	cQuery += "AND RD_SEMANA ='"+UPPER(cNumPgt)+"' "	
	cQuery += "AND SRD.D_E_L_E_T_ <> '*' "
	cQuery += "WHERE SRA.D_E_L_E_T_ <> '*' "
	cQuery += "AND RA_FILIAL 	BETWEEN '"+UPPER(cFilIni)+"' AND '"+UPPER(cFilFim)+"' "
	cQuery += "AND RA_MAT 	    BETWEEN '"+UPPER(cMatIni)+"' AND '"+UPPER(cMatFim)+"' "       
	cQuery += "AND RA_CC 		BETWEEN '"+UPPER(cCCIni)+"' AND '"+UPPER(cCCFim)+"' "       
	cQuery += "AND RA_DEPTO 	BETWEEN '"+UPPER(cDepIni)+"' AND '"+UPPER(cDepFim)+"' "     
	cQuery += "AND RA_CODSEG    BETWEEN '"+UPPER(cSegIni)+"' AND '"+UPPER(cSegFim)+"' "        	
	cQuery += "AND RA_TIPOPGT IN ("+cCatSra+") "
	cQuery += "AND RA_CODCAT IN ("+cSitSra+") "
	cQuery += "AND RA_CODSEG<>'' "
	//==================================================================================================================
	cQuery := ChangeQuery(cQuery)
	If Select("TRB")>0
		DbSelectArea("TRB")
		TRB->(DbCloseArea())
	Endif
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRB",.F.,.T.)
	cAlias:="TRB"
	DbSelectArea(cAlias)                                        
	(cAlias)->(dbGoTop())
	
	If (cAlias)->(!Eof())
		RptStatus({|lEnd| LisSegImp(@lEnd,wnRel,cString)})
	Else
		MsgAlert(STR0036, STR0037) //"No hay datos para ser procesados" - "Verifique los parámetros"
	Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LisSegImp ³ Autor ³ SSERVICE              ³ Data ³ 31.05.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ layout do Relatorio                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Portugal                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LisSegImp(lEnd,WnRel,cString)

Local lImprimiu := .F.
Local Li 		:= 80                          
Local cDescSeg	:="",cNumApol:="",cDescRam:=STR0015//"No Registrado"
Local nbCont 	:=0,nTotAli:=0,nTotFer:=0,nTotNat:=0,nTotOut:=0,nTotGer:=0,nTotJust:=0,nTotInjust:=0
Local nGerSal	:=0,nGerAli:=0,nGerFer:=0,nGerNat:=0,nGerOut:=0,nGerTot:=0,nGerJust:=0,nGerInjust:=0
Local cVFJust	:="789|790"	//Verbas de Faltas Justificadas
Local cVFInJust	:="054"	   	//Verbas de Faltas InJustificadas
Local cVAlim	:="784|785"	//Verbas de Alimentacao
Local cVFerias	:="072"	   	//Verbas de S.Ferias
Local cVNatal	:="024"	   	//Verbas de Sub.Natal

DbSelectArea(cAlias)
(cAlias)->(DbGoTop())
Do While (cAlias)->(!Eof())
	
	//Cadastro da Seguradora  
	DbSelectArea("RGI")
	RGI->(DbSetOrder(RetOrder("RGI","RGI_FILIAL+RGI_CODIGO")))
	RGI->(DbGoTop())
	If RGI->(DbSeek((cAlias)->RA_FILIAL+(cAlias)->RA_CODSEG))
		cDescSeg:=RGI->RGI_DESCRI
		cNumApol:=RGI->RGI_NRAPOL
	Else
		cDescSeg:=(cAlias)->RA_CODSEG
	Endif                            
    //===================================================================
	//S018-TIPOS DE COBERTURA(PADRAO)            
    //===================================================================
    cDescRam:=" "
	DbSelectArea("RCC")
	RCC->(DbSetOrder(RetOrder("RCC","RCC_FILIAL+RCC_CODIGO")))
	RCC->(DbGoTop())
	If RCC->(DbSeek(xFilial("RCC")+"S018"))
		Do While RCC->(!Eof()).And. RCC->RCC_CODIGO=="S018"	
			If SUBSTR(RCC->RCC_CONTEU,1,2)==(cAlias)->RA_CODSEG 
				cDescRam+=SUBSTR(RCC->RCC_CONTEU,5,Len(RCC->RCC_CONTEU)-4)+","
			Endif

			RCC->(DbSkip())
		End
		cDescRam:=Substr(cDescRam,1,Len(cDescRam)-1)
	Endif                           
	//=================================================================== 		
	cCabec1:=STR0016+" - "+cDescSeg+"   "+STR0003+"-"+cNumApol+SPACE(121)+STR0002+"-";
	+SubStr((cAlias)->PERIODO,5,2)+"/"+SubStr((cAlias)->PERIODO,1,4)//Seguradora-STR0016#Apolice#periodo
	cCabec2:=STR0001+"-"+Iif(cDescRam=="","STR0015",cDescRam)//Ramo
	li := cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,15)
	li++
	@ li,000 PSAY STR0004
	@ li,035 PSAY STR0005
	@ li,070 PSAY STR0006
	@ li,090 PSAY STR0007
	@ li,110 PSAY STR0008
	@ li,130 PSAY STR0009
	@ li,150 PSAY STR0010
	@ li,170 PSAY STR0014
	@ li,190 PSAY STR0011
	@ li,200 PSAY STR0012
	li++
	@ li,000 PSAY __PrtThinLine()
	li++
		
	If lEnd
		@PROW()+1,001 PSAY STR0017
		Exit
	EndIf
	
	cSeguradora:=(cAlias)->RA_CODSEG
	Do While (cAlias)->(!Eof()) .And. cSeguradora==(cAlias)->RA_CODSEG
		cNomFun:=(cAlias)->RA_NOME//Nome do Funcionario
		@ li,000 PSAY cNomFun
		DbSelectArea("SRJ")
		SRJ->(DbSetOrder(RetOrder("SRJ","RJ_FILIAL+RJ_FUNCAO")))
		SRJ->(DbGoTop())
		If DbSeek(xFilial("SRJ")+(cAlias)->RA_CODFUNC)
			@ li,035 PSAY SRJ->RJ_DESC
		Else
			@ li,035 PSAY ""
		Endif	
		//================================================================
		//Ven.Base
		//================================================================
		@ li,070 PSAY (cAlias)->RA_SALARIO		Picture "@E 99,999,999.99"
		cMatricula:=(cAlias)->RA_MAT
		nGerSal+=(cAlias)->RA_SALARIO//Total do Venc.Base
		Do While (cAlias)->(!Eof()) .And. cMatricula==(cAlias)->RA_MAT
			If (cAlias)->PD$cVAlim
				//================================================================
				//Alimentacao
				//================================================================
					cTotAli+=(cAlias)->VALOR
			ElseIf (cAlias)->PD$cVFerias
				//================================================================
				//Ferias
				//================================================================
					cTotFer+=(cAlias)->VALOR
			ElseIf (cAlias)->PD$cVNatal
				//================================================================
				//Natal
				//================================================================
				nTotNat+=(cAlias)->VALOR
			ElseIf (cAlias)->PD$cVFJust
				//================================================================
				//Faltas Justificadas
				//================================================================
				nTotJust+=(cAlias)->HORAS
			ElseIf (cAlias)->PD$cVFInjust
				//================================================================
				//Faltas Injustificadas
				//================================================================
				nTotInJust+=(cAlias)->HORAS										
			Else
				//================================================================
				//Outros
				//================================================================
				nTotOut+=(cAlias)->VALOR
			Endif
			cMatricula:=(cAlias)->RA_MAT
			(cAlias)->(dbSkip())
		End
		
		nTotGer:=nTotAli+nTotFer+nTotNat+nTotOut//Totalizacao das Verbas
		@ li,090 PSAY nTotAli		Picture "@E 99,999,999.99"//Ferias			
		@ li,110 PSAY nTotFer		Picture "@E 99,999,999.99"//Ferias
		@ li,130 PSAY nTotNat		Picture "@E 99,999,999.99"//Sub.Natal
		@ li,150 PSAY nTotOut		Picture "@E 99,999,999.99"//Outros
		@ li,170 PSAY nTotGer 		Picture "@E 99,999,999.99"//Total
		@ li,190 PSAY nTotJust  	Picture "@E 99.99"		  //Faltas Justificadas
		@ li,200 PSAY nTotInJust	Picture "@E 99.99"		  //Faltas Injustificadas
		li++

		nGerAli+=nTotAli
		nGerFer+=nTotFer
		nGerNat+=nTotNat
		nGerOut+=nTotOut	
		nGerTot+=nTotGer	                               
		nGerJust+=nTotJust
		nGerInjust+=nTotInjust
		//Zerando as variaveis totalizadoras do funcionario			
		nTotAli:=0
		nTotFer:=0
		nTotNat:=0
		nTotOut:=0
		nTotGer:=0    
		nTotJust:=0
		nTotInjust:=0
		//Quebra de Pagina      
		If li>=60
			li := cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,15)
			li++
			@ li,000 PSAY STR0004
			@ li,035 PSAY STR0005
			@ li,070 PSAY STR0006
			@ li,090 PSAY STR0007
			@ li,110 PSAY STR0008
			@ li,130 PSAY STR0009
			@ li,150 PSAY STR0010
			@ li,170 PSAY STR0014
			@ li,190 PSAY STR0011
			@ li,200 PSAY STR0012
			li++
			@ li,000 PSAY __PrtThinLine()
			li++	 
		Endif			
	End
	li++
	@ li,000 PSAY __PrtThinLine()
	li++
	@ li,056 PSAY STR0013+":"
	@ li,070 PSAY nGerSal 		Picture "@E 99,999,999.99"
	@ li,090 PSAY nGerAli 		Picture "@E 99,999,999.99"
	@ li,110 PSAY nGerFer 		Picture "@E 99,999,999.99"
	@ li,130 PSAY nGerNat 		Picture "@E 99,999,999.99"
	@ li,150 PSAY nGerOut 		Picture "@E 99,999,999.99"
	@ li,170 PSAY nGerTot 		Picture "@E 99,999,999.99"
	@ li,190 PSAY nGerJust		Picture "@E 99.99"
	@ li,200 PSAY nGerInjust	Picture "@E 99.99"
	lImprimiu := .T. 
	li++
	//Zerando as Variaveis totalizadoras do seguro
	nGerSal:=0
	nGerAli:=0
	nGerFer:=0
	nGerNat:=0
	nGerOut:=0
	nGerTot:=0       
	nGerJust:=0
	nGerInjust:=0
End

If lImprimiu
	Roda(nbCont,"",Tamanho)
EndIf

If ( aReturn[5] = 1 )
	Set Printer To
	dbCommitAll()
	OurSpool(wnrel)
Endif
MS_FLUSH()
Return(.T.)