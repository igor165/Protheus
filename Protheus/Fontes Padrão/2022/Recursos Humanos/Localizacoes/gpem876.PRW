#include "PROTHEUS.CH"    
#INCLUDE "GPEM876.CH"
/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPEM876  ³ Autor ³ Luis Trombini           ³ Data ³ 20/10/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ GERA ARQUIVO DA DREP (RH6)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³             ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador  ³ Data   ³ Chamado ³ Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³±±
±±³Kelly Soares	³05/09/11³         ³ Remoção da mensagem de log que menciona ³±±
±±³             ³        ³         ³ boletim no FTP.						 ³±±
±±³Kelly Soares	³13/02/12³ TEIHIO  ³ Ajuste no calculo de imposto retido e   ³±±
±±³             ³        ³         ³ causado (campos 409 e 411 do F107)      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±± 
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GPEM876()
Local nOpca 	:= 0
Local aSays		:= {}
Local aButtons	:= {} //<== arrays locais de preferencia

Private cCadastro := OemToAnsi(STR0001) //"Geraçäo do Arquivo da D.R.E.P."
Private cSraFilter	:= ""
Private aRetFiltro	:= {}
Private aFilterExp	:= {} 

Pergunte("GPM876",.F.)

AAdd( aFilterExp , { "FILTRO_ALS" , "SRA"     	, .T. } )			 /* Retorne os Filtros que contenham os Alias Abaixo */
AAdd( aFilterExp , { "FILTRO_PRG" , FunName() 	, NIL , NIL    } )  /* Que Estejam Definidos para a Função */
AADD(aSays,OemToAnsi(STR0002) )  //"Este programa gera o arquivo da D.R.E.P."

AAdd(aButtons, { 17,.T., { || aRetFiltro := FilterBuildExpr( aFilterExp ) } } )
AADD(aButtons, { 5,.T.,{|| Pergunte("GPM876",.T. ) } } )
AADD(aButtons, { 1,.T.,{|o| nOpca := 1,IF(gpm876OK(),FechaBatch(),nOpca:=0) }} )
AADD(aButtons, { 2,.T.,{|o| FechaBatch() }} )
	
FormBatch( cCadastro, aSays, aButtons )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ mv_par01 - Filial de                                         ³
//³ mv_par02 - Ano Base                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

IF nOpca == 1
	ProcGpe({|lEnd| GPM876Processa()})  // Chamada do Processamento
Endif

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³GPM876ProcessaºAutor  ³L.Trombini        º Data ³  20/10/10  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                             º±±
±±º          ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ P11                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GPM876Processa()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis LOCAIS DO PROGRAMA                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cFilAnterior
Local nX
Local nA
Local nI
Local nAb

Local cVerba
Local nPos 		:= 0

Local cQuery        
Local cChave        
Local nMax 		:= 0     
Local nMin 		:= 0     
Local nPont 	:= 0    
Local nPosPer   := 0
Local cMat
Local cFil
Local cPutFilAnt:= cFilAnt          
Local lLimpaTudo:= .F.
Local lTemCpoDFE:= ""
Local lDtIniPg  := .F. 

Private aInfo 	:= {}
Private aCodFol	:= {}   // Matriz com Codigo da folha

Private aLog	:= {}
Private aTitle	:= {}
Private aTotRegs:= array(9)         
Private aVerba	:= {}

Private cAliasSRD := "SRD"
Private cAliasRH5 := "RH5"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis PRIVADAS BASICAS                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aCRA 	:= { STR0003,STR0004,STR0005 } //"Confirma"###"Redigita"###"Abandona"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis PRIVADAS DO PROGRAMA                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cInfOut		:= ""
Private cDescri 	:= ""
Private cCodRet 	:= ""
Private aFunc 		:= {}     
Private cFilDe		:=	mv_par01
Private cAno		:= 	MV_PAR02
Private nTamCpf		:= TamSX3("RA_CIC")[1]
Private aPerAtual 	:= {}
Private cAnoMesAb 	:= MesAno(dDataBase)
Private aAbono 		:= {}     

aFill(aTotRegs,0)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Limpar o arquivo da DIRF                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea( "RH6" )
If RecCount() > 0 
	Aviso(STR0009,STR0010,{"OK"}) //"Atencao"#"A tabela RH6 será limpa para que a partir de agora o historico possa ser armazenado."
	
	#IFDEF TOP 
		If ( TcSrvType()!="AS/400" )
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica qual eh o maior e o menor³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cQuery := "SELECT MIN(R_E_C_N_O_) MINRECNO,"
			cQuery +=	 "MAX(R_E_C_N_O_) MAXRECNO "
			cQuery += "FROM "+RetSqlName("RH6")+" RH6 "
		
			cQuery := ChangeQuery(cQuery)
		
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SRL550DELE")
			
			nMax := SRL550DELE->MAXRECNO
			nMin := SRL550DELE->MINRECNO
			dbCloseArea()
			dbSelectArea("RH6")
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Monta a string de execucao no banco³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cQuery := "DELETE FROM "+RetSqlName("RH6")+" "
			cQuery += "WHERE "
			If Type("SRL->RL_ORIGEM") # "U" 
		    	cQuery +=  "RL_ORIGEM = '1'"
			EndIf 
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Executa a string de execucao no banco para os proximos 1024 registro³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nPont := nMin To nMax STEP 1024
					cChave := "R_E_C_N_O_>="+Str(nPont,10,0)+" AND R_E_C_N_O_<="+Str(nPont+1023,10,0)+""
					TcSqlExec(cQuery+cChave)
				Next nPont
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³A tabela eh fechada para restaurar o buffer da aplicacao³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("RH6")
				dbCloseArea()
				ChkFile("RH6",.F.)
		Else //- Opcao para AS400  	
	#ELSE 
			If Ma280Flock("RH6")           // Abre Arquivo SRL Exclusivo
				OpenIndX("RH6",.F.)
				Zap                        // Limpa Arquivo
				dbCloseArea()
				ChkFile("RH6",.F.)
	    	Else
				Help(" ",1,"GP550NOPEN")
				Return Nil
			Endif
	#ENDIF
		
	#IFDEF TOP
		EndIf
	#ENDIF
		
EndIf
                                              
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem das Datas para a Query³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cDtPesqI := MV_PAR02 + "0101"
cDtPesqF := MV_PAR02+ "1231"
nINAnoMes := Val(mv_par02+"01")
nFNAnoMes := Val(mv_par02+"12")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona Ponteiro "DE" Informado                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea( "SRA" )
dbSetOrder(1)
//dbSeek( cFilDe + cMatDe , .T. )
Dbgotop()

#IFDEF TOP
    SRA->( dbCloseArea() )
	cAliasX := "SRA" 
    cQuery :="Select * from "+ RetSqlName("SRA")+" SRA "
    cQuery += "WHERE " + "SRA."+RANGESX1("RA_FILIAL"  ,MV_PAR01)
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasX,.T.,.T.) 
	TcSetField(cAliasX, "RA_DEMISSA", "D", 8, 0) 
	TcSetField(cAliasX, "RA_ADMISSA", "D", 8, 0)
	TcSetField(cAliasX, "RA_NASC", "D", 8, 0)
#ELSE                                
	cAliasX := "SRA"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a ordem selecionada                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cIndCond:= "RA_FILIAL + RA_MAT"
	cIndTRB	:= "FILIAL + MAT"
	(cAliasX)->( DbGoTop() )

	//-- Adiciona no filtro o parametro tipo Range
	//-- Filial 
	cFiltro := '(SRA->RA_FILIAL  $ "' + mv_par01  + '")' 
	oSection:SetFilter(cFiltro, cIndCond, , "SRA") 
	DBGOTOP()
#ENDIF	


GPProcRegua(SRA->(RecCount()))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega os Filtros                                 	 	     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSraFilter	:= GpFltAlsGet( aRetFiltro , "SRA" )

cFilAnterior  := Replicate("!",FwGetTamFilial)

While SRA->(!Eof()) //.And. SRA->RA_FILIAL + SRA->RA_MAT <= cFilAte + cMatAte
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Aplicação do filtro na tabela SRA.       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty( cSraFilter )
 		If !( &( cSraFilter ) )
			dbSkip()
			Loop
 		EndIf
 	EndIf	
    If Year(SRA->RA_DEMISSA) > 0
    	If Year(SRA->RA_DEMISSA) < Val(mv_par02)
	 	 	dbSkip()
			Loop
		endif	
    Endif
    If Year(SRA->RA_ADMISSA) > Val(mv_par02)
	 	dbSkip()
		Loop
    Endif
    If SRA->RA_SITFOLH <> "D"
      nMeses := nFNAnoMes  - Val(MesAno(SRA->RA_ADMISSA))
      If nMeses > 12
         nMeses := 12
      EndIf
    Else 
      nMeses := (Val(MesAno(SRA->RA_DEMISSA)) - nINAnoMes )+1
    EndIf       
    

    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Movimenta cursor para movimentacao da barra                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	GPIncProc(SRA->RA_FILIAL+" - "+SRA->RA_MAT+" - "+SRA->RA_NOME)
	
	If SRA->RA_FILIAL # cFilAnterior
		cFilAnterior := SRA->RA_FILIAL
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega Variaveis CODIGOS DA FOLHA                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//		If ! FP_CODFOL(@aCodFol,cFilAnterior)
//			Exit
//		Endif
		If ! fInfo(@aInfo,cFilAnterior)
			Exit
		Endif
		cCgc := aInfo[8]
	Endif

	nDel 		:= 0
	cInfOut 	:= ""

	cInfOut      := ""
	lGravouAlgum := .F.
	cMat := SRA->RA_MAT		
	cFil := SRA->RA_FILIAL
    
	dbSelectArea("SRD")
	#IFDEF TOP
		If TcSrvType()<>"AS/400"  
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Montagem da Query para buscar Valores no Acumulado "SRD"     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			lQuery 		:= .T.
			cAliasSRD 	:= "m876MontSRD"
			aStru  		:= SRD->(dbStruct())
			cQuery 		:= "SELECT RD_FILIAL, RD_MAT, RD_PD, RD_DATARQ, RD_DATPGT, SUM(RD_VALOR)TOTVERBA, COUNT(RD_PD) QUANTAS "		
			cQuery 		+= " FROM "+	RetSqlName("SRD")
			cQuery 		+= " WHERE RD_FILIAL  ='" + cFil + "'"
			cQuery 		+= " AND RD_MAT     = '" + cMat+ "'"
			cQuery 		+= " AND RD_DATPGT BETWEEN '"+cDtPesqI+"' AND '"+cDtPesqF+"'"
			cQuery 		+= " AND D_E_L_E_T_ = ' ' "
			cQuery 		+= "GROUP by RD_FILIAL, RD_MAT, RD_PD, RD_DATARQ, RD_DATPGT "
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSRD,.T.,.T.)
 
			For nX := 1 To len(aStru)
				If aStru[nX][2] <> "C" .And. FieldPos(aStru[nX][1])<>0
					TcSetField(cAliasSRD,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
				EndIf
			Next nX
			dbSelectArea(cAliasSRD)	     
			
			
   			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Montagem da Query do arquivo RH5 - Gastos Personales         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			

   			lQuery 		:= .T.
			cAliasRH5 	:= "m876MontRH5"
			aStru  		:= SRD->(dbStruct())
			cQuery 		:= "SELECT RH5_FILIAL, RH5_MAT, RH5_ANO, RH5_CODIGO, RH5_VALOR "		
			cQuery 		+= " FROM "+	RetSqlName("RH5")
			cQuery 		+= " WHERE RH5_FILIAL  ='" + cFil + "'"
			cQuery 		+= " AND RH5_MAT     = '" + cMat+ "'"
			cQuery 		+= " AND RH5_ANO = '" + MV_PAR02 + "'" 
			cQuery 		+= " AND D_E_L_E_T_ = ' ' "
			cQuery 		+= "Group by RH5_FILIAL, RH5_MAT, RH5_ANO, RH5_CODIGO, RH5_VALOR "
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasRH5,.T.,.T.)
 
			For nX := 1 To len(aStru)
				If aStru[nX][2] <> "C" .And. FieldPos(aStru[nX][1])<>0
					TcSetField(cAliasRH5,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
				EndIf
			Next nX
			dbSelectArea(cAliasRH5)			
		Else
	#ENDIF
		(cAliasSRD)->(MsSeek(SRA->RA_FILIAL+SRA->RA_MAT+MV_PAR02),.T.) 
		(cAliasRH5)->(MsSeek(SRA->RA_FILIAL+SRA->RA_MAT+StrZero(MV_PAR06-1,4)+"12",.T.)) 
		
	#IFDEF TOP
		EndIf
	#ENDIF   
	
   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis de totalização dos valores a serem gravados no "RH6"  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private nVal301 := 0.00
	Private nVal303 := 0.00
	Private nVal305 := 0.00
	Private nVal307 := 0.00
	Private nVal309 := 0.00
	Private nVal311 := 0.00
	Private nVal313 := 0.00
	Private nVal315 := 0.00
	Private nVal317 := 0.00
	Private nVal319 := 0.00
	Private nVal321 := 0.00
	Private nVal323 := 0.00
	Private nVal325 := 0.00
	Private nVal327 := 0.00
	Private nVal329 := 0.00
	Private nVal331 := 0.00
	Private nVal351 := 0.00
	Private nVal353 := 0.00
	Private nVal401 := 0.00
	Private nVal403 := 0.00
	Private nVal405 := 0.00
	Private nVal407 := 0.00
	Private nVal409 := 0.00
	Private nVal411 := 0.00
	Private nVal413 := 0.00
//	Private nMeses  := 0.00
	Private nDiv327 := 0.00
	Private nDiv329 := 0.00
	Private nRetAno := 0.00 
	Private cEstado := "  "
	Private cTipID  := "2"
	Private CNrID   := ''
	
    While (cAliasSRD)->(!Eof()) .And. SRA->RA_FILIAL+SRA->RA_MAT == (cAliasSRD)->RD_FILIAL+(cAliasSRD)->RD_MAT
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Despreza os lanctos de transferencias de outras empresas³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//      	If (cAliasSRD)->RD_EMPRESA # FwCodEmp("SRD") .And. !Empty((cAliasSRD)->RD_EMPRESA)
//			(cAliasSRD)->( dbSkip() )
//			Loop
//		Endif          
        mVarcod := POSSRV((cAliasSRD)->RD_PD,SRA->RA_FILIAL,"RV_COD107")
		If empty((cAliasSRD)->RD_PD)
			If aTotRegs[4] == 0
				cLog := STR0011 //"Lancamento com verba em branco no acumulado.    Filial/Matricula  Competencia            Valor "
				Aadd(aTitle,cLog)  
				Aadd(aLog,{})
				aTotRegs[4] := len(aLog)
			EndIf	      
 			       
			Aadd(aLog[aTotRegs[4]],space(49)+(cAliasSRD)->RD_FILIAL+"-"+(cAliasSRD)->RD_MAT+space(08)+substr((cAliasSRD)->RD_DATARQ,5,2)+"/"+substr((cAliasSRD)->RD_DATARQ,1,4) +space(04)+transform((cAliasSRD)->RD_VALOR,"@E 99,999,999,999.99") )
			(cAliasSRD)->( dbSkip() )
			Loop
		EndIf                      
        
		If empty((cAliasSRD)->RD_DATARQ)
			If aTotRegs[5] == 0
				cLog := STR0012 //"Lancamento com competencia em branco no acumulado.   Filial/Matricula  Verba             Valor"
				Aadd(aTitle,cLog)  
				Aadd(aLog,{})
				aTotRegs[5] := len(aLog)
			EndIf	     
			Aadd(aLog[aTotRegs[5]],space(54)+(cAliasSRD)->RD_FILIAL+"-"+(cAliasSRD)->RD_MAT+space(09)+(cAliasSRD)->RD_PD+space(03)+transform((cAliasSRD)->RD_VALOR,"@E 99,999,999,999.99") )
			(cAliasSRD)->( dbSkip() )
			Loop
		EndIf

		If empty((cAliasSRD)->RD_DATPGT)
			If aTotRegs[6] == 0
				cLog := STR0013 //"Lancamento com data de pagamento em branco no acumulado."
				Aadd(aTitle,cLog)  
				Aadd(aLog,{})
				aTotRegs[6] := len(aLog)
			EndIf	             
			Aadd(aLog[aTotRegs[6]],(cAliasSRD)->RD_FILIAL+"-"+(cAliasSRD)->RD_MAT+"-"+(cAliasSRD)->RD_PD+"-" +transform((cAliasSRD)->RD_VALOR,"@E 99,999,999,999.99") )
			(cAliasSRD)->( dbSkip() )
			Loop
		EndIf
		
		If (cAliasSRD)->QUANTAS > 12 .and. SRV->RV_CODFOL = "0031" .AND. SRA->RA_CATFUNC <> "S"
			If aTotRegs[8] == 0
				cLog := STR0014 //"Verba duplicada nos acumulados.    Filial/Matricula   Verba   Competencia             Valor"
				Aadd(aTitle,cLog)  
				Aadd(aLog,{})
				aTotRegs[8] := len(aLog)
			EndIf	             
			Aadd(aLog[aTotRegs[8]],SPACE(35)+(cAliasSRD)->RD_FILIAL+"-"+(cAliasSRD)->RD_MAT+SPACE(10)+(cAliasSRD)->RD_PD+SPACE(05)+substr((cAliasSRD)->RD_DATARQ,5,2)+"/"+substr((cAliasSRD)->RD_DATARQ,1,4)+SPACE(5)+ transform((cAliasSRD)->RD_VALOR,"@E 99,999,999,999.99") )
		EndIf		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Esta função buscará os valores das verbas no acumulado,      ³
		//³e suas incidências, e as guardará no array afun, para gravar ³
		//³posteriormente nas tabelas SR4 e SRL.                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
		If SRA->RA_CODPAIS <> "009"
			cTipID  := "3" 
			cNrID :=SRA->RA_PASSPOR
			if Len(ALLTRIM(cNrId)) > 10
			  cNrId := substr(cNrID,1,10)
			else
			  cNrId := replicate("0",(10-Len(ALLTRIM(cNrId))))+ Alltrim(cNrId) 
			endif 
		ELSE
			cTipID  := "2" 
			cNrID :=SRA->RA_RG
			if Len(ALLTRIM(cNrId)) > 10
			  cNrId := substr(cNrID,1,10)
			else
			  cNrId := replicate("0",(10-Len(ALLTRIM(cNrId))))+ Alltrim(cNrId) 
			endif 	  
		endif	
	  		
		If mVarcod == "301" 
			nVal301 += (cAliasSRD)->TOTVERBA
//			If SRV->RV_CODFOL = "0031"
//    			nmeses  += (cAliasSRD)->QUANTAS
//    		EndIf	
  		ElseIf mVarcod == "303"
			nVal303 += (cAliasSRD)->TOTVERBA
   		ElseIf mVarcod == "305"
			nVal305 += (cAliasSRD)->TOTVERBA
   		ElseIf mVarcod == "307"
			nVal307 += (cAliasSRD)->TOTVERBA
   		ElseIf mVarcod == "309"
			nVal309 += (cAliasSRD)->TOTVERBA
   		ElseIf mVarcod == "311"
			nVal311 += (cAliasSRD)->TOTVERBA
   		ElseIf mVarcod == "313"
			nVal313 += (cAliasSRD)->TOTVERBA
		ElseIf mVarcod == "315"
			nVal315 += (cAliasSRD)->TOTVERBA 
		ElseIf mVarcod == "327"
			nVal327 += (cAliasSRD)->TOTVERBA
			nDiv327 += (cAliasSRD)->QUANTAS
		ElseIf mVarcod == "329"
			nVal329 += (cAliasSRD)->TOTVERBA
			nDiv329 += (cAliasSRD)->QUANTAS 
		ElseIf mVarcod == "331"
			nVal331 += (cAliasSRD)->TOTVERBA 
		ElseIf mVarcod == "401"
			nVal401 += (cAliasSRD)->TOTVERBA
		ElseIf mVarcod == "403"
   			nVal403 += (cAliasSRD)->TOTVERBA
		ElseIf mVarcod == "405"
			nVal405 += (cAliasSRD)->TOTVERBA
//		ElseIf mVarcod == "409"
//			nVal409 += (cAliasSRD)->TOTVERBA
		ElseIf mVarcod == "411"
			nVal411 += (cAliasSRD)->TOTVERBA
			nRetAno += (cAliasSRD)->QUANTAS
		ElseIf mVarcod == "413"
		   	nVal413 += (cAliasSRD)->TOTVERBA
        Endif
		(cAliasSRD)->( dbSkip())
	Enddo
	#IFDEF TOP
		dbSelectArea(cAliasSRD)
		dbCloseArea()
	#ENDIF    

    While (cAliasRH5)->(!Eof()) .And. SRA->RA_FILIAL+SRA->RA_MAT == (cAliasRH5)->RH5_FILIAL+(cAliasRH5)->RH5_MAT 
     
    	If (cAliasRH5)->RH5_CODIGO == "106 "
			nVal317 += (cAliasRH5)->RH5_VALOR
		ElseIf (cAliasRH5)->RH5_CODIGO == "107 "
			nVal319 += (cAliasRH5)->RH5_VALOR
		ElseIf (cAliasRH5)->RH5_CODIGO == "108 "
			nVal321 += (cAliasRH5)->RH5_VALOR
		ElseIf (cAliasRH5)->RH5_CODIGO == "109 "
			nVal323 += (cAliasRH5)->RH5_VALOR
		ElseIf (cAliasRH5)->RH5_CODIGO == "110 "
			nVal325 += (cAliasRH5)->RH5_VALOR
		ElseIf (cAliasRH5)->RH5_CODIGO == "106O"
			nVal403 += (cAliasRH5)->RH5_VALOR
		ElseIf (cAliasRH5)->RH5_CODIGO == "107O"
			nVal403 += (cAliasRH5)->RH5_VALOR
		ElseIf (cAliasRH5)->RH5_CODIGO == "108O"
			nVal403 += (cAliasRH5)->RH5_VALOR
		ElseIf (cAliasRH5)->RH5_CODIGO == "109O"
			nVal403 += (cAliasRH5)->RH5_VALOR
		ElseIf (cAliasRH5)->RH5_CODIGO == "110O"
			nVal403 += (cAliasRH5)->RH5_VALOR
        EndIf
    	(cAliasRH5)->( dbSkip())
	Enddo
	#IFDEF TOP
		dbSelectArea(cAliasRH5)
		dbCloseArea()
	#ENDIF 
    // Deve ser somado apenas uma vez  os valores nVal327 2 nVal329 e esta acumulando de acordo com os meses trabalhado devido query
	IF nDiv327 > 1
	   nVal327 := nVal327 / nDiv327
	endif         
	If SRA->RA_CATFUNC == "S"
	  If nRetAno > nMeses
	     nRetAno:= nMeses
	  EndIf   
    EndIf
	IF nDiv329 > 1
	   nVal329 :=nVal329 / nDiv329
	endif      

    nVal351 := ( nVal301 + nVal303 + nVal311 - nVal315 - nVal317 - nVal319 - nVal321 - nVal323 - nVal325 - nVal327 - nVal329 + nVal331)
    nVal407 := ( nVal351 + nVal401 - nVal403 - nVal405 )

	nVal409 := CalIRFin()   
    If SRA->RA_ESTADO $ "01/02/03/04/05/06/10/11/17/18/23"
		cEstado := "2"+SRA->RA_ESTADO
    ElseIf SRA->RA_ESTADO $ "07/08/09/12/13/24"  
		cEstado := "1"+SRA->RA_ESTADO
    ElseIf SRA->RA_ESTADO $ "14/15/16/19/21/22"  
		cEstado := "3"+SRA->RA_ESTADO
    ElseIf SRA->RA_ESTADO $ "20"  
		cEstado := "4"+SRA->RA_ESTADO
    Endif  
    
	If nVal351 <> 0
		cFilAnt	:= SRA->RA_FILIAL
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Gravar Cabe‡alho da Dirf/informe³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    FGravaRH6()
		cFilAnt := cPutFilAnt
	Endif

	dbSelectArea("SRA")
	dbSkip()
Enddo
#IFDEF TOP
	dbSelectArea(cAliasX)
	dbCloseArea() 
	dbSelectArea("RH6")
	dbCloseArea() 
#ENDIF    
If aTotRegs[1] == 0 .and. aTotRegs[2] == 0 .and. aTotRegs[4] == 0 .and. aTotRegs[5]==0 .and. ;
   aTotRegs[6] == 0 .and. aTotRegs[7] == 0 .and. aTotRegs[8] == 0
	
	If aTotRegs[9] == 0
		cLog := STR0015 //"Arquivo gerado com sucesso!"
		Aadd(aTitle,cLog)  
		Aadd(aLog,{})
		aTotRegs[9] := len(aLog)
	EndIf	
	Aadd(aLog[aTotRegs[9]], STR0016 ) //"Não foi encontrada nenhuma inconsistência durante a geração."
EndIf   

If aTotRegs[3] == 0
	cLog := STR0017 //"Informações para gerar a DREP."
	Aadd(aTitle,cLog)  
	Aadd(aLog,{})
	aTotRegs[3] := len(aLog)
EndIf	
//Aadd(aLog[aTotRegs[3]], STR0018 )//"Para obter informações detalhadas de como proceder para configurar a DREP, consulte"
//Aadd(aLog[aTotRegs[3]], STR0019 )//"o Boletim Técnico que se encontra no FTP da Microsiga: ftp.microsiga.com.br"
fMakeLog(aLog,aTitle,,,"DREP"+cAno,STR0020,"M","P",,.F.) //"Log de ocorrências da DREP"


Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³FGravaRH6 ºAutor  ³L.Trombini          º Data ³  20/10/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Grava arquivo D.R.E.P.                                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ P11                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FGravaRH6()            
Local cTipoFJ 	:= ""
Local cChave	:= ""                   

cTipoFJ := If( Len(AllTrim(SRA->RA_CIC)) > 11, "2","1")

cChave	:=  SRA->RA_FILIAL+SRA->RA_MAT
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava no Arquivo de Cabecalho da DIRF/INFORME                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("RH6")
dbSetOrder(2)
If dbSeek( cChave )
		RecLock("RH6",.F.)
	Else
		RecLock("RH6",.T.)
	Endif     

	RH6->RH6_FILIAL   := SRA->RA_FILIAL
	RH6->RH6_MAT      := SRA->RA_MAT 
	RH6->RH6_NOME     := SRA->RA_NOME
	RH6->RH6_NRRUC    := cCgc
	RH6->RH6_TIPID    := cTipID
	RH6->RH6_IDRET	  := cNrId
	RH6->RH6_DIRCAL   := SRA->RA_ENDERECO
	RH6->RH6_DIRNUM   := SRA->RA_NUMERO
	RH6->RH6_CODMUN   := SRA->RA_MUNICIP
	RH6->RH6_CODEST   := cEstado
	RH6->RH6_NRTELE   := SRA->RA_TELEFON
	RH6->RH6_SISSAL   := SRA->RA_GROSSUP
	RH6->RH6_SALAR    := nVal301
	RH6->RH6_COMISS   := nVal303
	RH6->RH6_FONDO    := nVal309
	RH6->RH6_D13SAL   := nVal305
	RH6->RH6_D14SAL   := nVal307
	RH6->RH6_PARUTI   := nVal311
	RH6->RH6_VRESCI   := nVal313
	RH6->RH6_APIESS   := nVal315
	RH6->RH6_DEDVIV   := nVal317
	RH6->RH6_DEDSAL   := nVal319
	RH6->RH6_DEDEDU   := nVal321
	RH6->RH6_DEDALI   := nVal323
	RH6->RH6_DEDVES   := nVal325
	RH6->RH6_DESCAP   := nVal327
	RH6->RH6_TERIDA   := nVal329
	RH6->RH6_INRETE   := nVal331
	RH6->RH6_SUBTOT   := nVal351
	RH6->RH6_NUNRET   := nRetAno
	RH6->RH6_NUMMES   := nMeses
	RH6->RH6_OUTEMP   := nVal401
	RH6->RH6_OUTDED   := nVal403
	RH6->RH6_OUTBXS   := nVal405
   	RH6->RH6_BASIMP   := nVal407
	RH6->RH6_IMPCAU   := If(nVal409 >= 0, nVal409, 0.00)
	RH6->RH6_OUTIMP   := nVal413
	RH6->RH6_IMPRET   := nVal411
	RH6->RH6_ANORET   := MV_PAR02		
   	MsUnlock()                
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³GPM876Ok  ºAutor  ³L.Trombini          º Data ³  20/10/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GPM876Ok()
Return (MsgYesNo(OemToAnsi(STR0008),OemToAnsi(STR0009))) //"Confirma configura‡„o dos parƒmetros?"###"Aten‡„o"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³CalIRFin  ºAutor  ³Kelly Soares        º Data ³  18/01/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calcula IR final.                                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CalIRFin()

Local nPos      := 0
Local nBaseIR   := 0
Local nValorFB  := 0
Local nFatorFB  := 0
Local nPerSS	:= 0 
Local nValSS	:= 0
Local nLimite   := 0 
Local nGastos   := 0       
Local nValAux   := 0
Local nFatAux   := 0   
Local nIdade    := 0    
Local nFator3Id := 0
Local nValor3Id := 0
Local nFatorDef := 0
Local nValorDef := 0
Local nPerc     := 0
Local nExcesso  := 0
Local nParFixa  := 0
Local nResulta  := 0 
Local nValIR    := 0
Local cRH5Cod   := ""
Local cVrbBase  := FGETCODFOL("0015") + "/" + FGETCODFOL("0016") + "/" + FGETCODFOL("1118")
Local dInicio   := MAX(CTOD("01/01/"+cAno),SRA->RA_ADMISSA)
Local dFim      := CTOD("31/12/"+cAno)
Local aTab10    := {}
Local aTab14    := {}  

If !Empty(SRA->RA_DEMISSA)
	dFim := Min(dFim,SRA->RA_DEMISSA)
Endif

fRetTab(@aTab10 ,"S010", , ,dFim)
fRetTab(@aTab14 ,"S014", , ,dFim)
                               
If Len(aTab10) > 0 .and. Len(aTab14) > 0
	
// ----------------------------------------------------------------------------------------------------------------------- //
//  Obtem base de IR no periodo                                                                                            //
// ----------------------------------------------------------------------------------------------------------------------- //
	fBuscaAcm(cVrbBase,,dInicio,dFim,"V",@nBaseIR,,fGetRotOrdinar())
	If nBaseIR < 0
		nBaseIR *= -1
	Endif

	If nBaseIR > 0
// ----------------------------------------------------------------------------------------------------------------------- //
//      Calcula Seguro Social                                                                                              //
// ----------------------------------------------------------------------------------------------------------------------- //
		nPerSS := fTabela("S011", 1, 5)
		If nPerSS > 0
			nValSS := Round((nBaseIR*nPerSS)/100,2)
			nBaseIR -= nValSS
		Endif
// ----------------------------------------------------------------------------------------------------------------------- //
//      Obtem gastos pessoais do periodo
// ----------------------------------------------------------------------------------------------------------------------- //
		nValorFB := aTab14[5]    //VALOR FRAÇAO BASICA
		nFatorFB := aTab10[6]	 //FATOR FRAÇAO BASICA
		nLimite  := ROUND(nValorFB * nFatorFB,2)
		DbSelectArea("RH5")
		DbSeek(SRA->RA_FILIAL+SRA->RA_MAT+cAno)
		While !RH5->(Eof()) .and. RH5->RH5_FILIAL + RH5->RH5_MAT + RH5->RH5_ANO = SRA->RA_FILIAL + SRA->RA_MAT + cAno		
			cRH5Cod := RH5->RH5_CODIGO
			nRH5Val := RH5->RH5_VALOR   
			If nLimite > 0
				nGastos += nRH5Val
			Else
				nPos    := fPosTab("S019", cRH5Cod, "=", 4)
				nFatAux := fTabela("S019", nPos, 6)
				nValAux := nValorFB * nFatAux
				nGastos += Min(nRH5Val,nValAux)
            End
			RH5->(DbSkip())
        Enddo
// ----------------------------------------------------------------------------------------------------------------------- //
//      Calcula deducao especial
// ----------------------------------------------------------------------------------------------------------------------- //
		nIdade := Val(cAno) - Year(SRA->RA_NASC)
		If ( nIdade >= 65 )
			nFator3Id := aTab10[7]
			nValor3Id := nValorFB * nFator3Id
		Endif
		If SRA->RA_DEFIFIS = "1"
			nFatorDef := aTab10[8]	
			nValorDef := nValorFB * nFatorDef
		Endif
// ----------------------------------------------------------------------------------------------------------------------- //
//      Calcula base liquida de IR
// ----------------------------------------------------------------------------------------------------------------------- //
		nBaseIR -= nGastos + nValor3Id + nValorDef
// ----------------------------------------------------------------------------------------------------------------------- //
//      Aplica base liquida na tabela de IR
// ----------------------------------------------------------------------------------------------------------------------- //
		If nBaseIR > 0		
        	nPos := fPosTab("S014",nBaseIR,"<=",05)    
    		If (nPos > 0)    
				nPerc := fTabela("S014", nPos, 07)
				If nPerc > 0    
					nExcesso := fTabela("S014", nPos, 04)
					nParFixa := fTabela("S014", nPos, 06)
					nResulta := ROUND((nBaseIR - nExcesso) * nPerc / 100 , 2) 
					nValIR   := ROUND(nResulta + nParFixa,2) 
				EndIF
			Endif
		Endif
	Endif
Endif             

Return nValIR
