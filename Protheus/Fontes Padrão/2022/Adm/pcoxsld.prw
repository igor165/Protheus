#include "tbiconn.ch"
#INCLUDE "pcoxsld.ch"
#INCLUDE "PROTHEUS.CH"
Static lProcedure := Nil
Static lProcRetSld := Nil
Static lProcAtSld := Nil
//AMARRACAO SPS PROCESSO 13
Static aCubeStru 
Static aAtuTransa	:= {} // Controla atualizacoes solicitadas dentro de uma Transacao
Static _lAKTANALIT  := NIL

/*
_F_U_N_C_ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³PcoAtuSld ³ AUTOR ³ Edson Maricate        ³ DATA ³ 14.02.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Funcao de atualização de saldos mensais.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ USO      ³ SIGAPCO                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³_DOCUMEN_ ³ PcoAtuSld                                                    ³±±
±±³_DESCRI_  ³ Funcao de atualização de saldos mensais.                     ³±±
±±³_FUNC_    ³ Esta funcao podera ser utilizada com a sua chamada normal    ³±±
±±³          ³                                                              ³±±
±±³          ³                                                              ³±±
±±³          ³                                                              ³±±
±±³          ³                                                              ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³_PARAMETR_³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoAtuSld(cTipoMov,cAliasAKD,aValor,dData,cConfigDe,cConfigAte,lReproc,lForcaAtu)

Local aArea		:= GetArea()
Local aAreaAL1	:= AL1->(GetArea())
Local aAreaAKS	:= AKS->(GetArea())
Local cChave	:= ""
Local nPos		:= 1
Local lNotBlind	:= !IsBlind()
Local cTipoAtu	:=	'1'
Local aJobs		:= {}
Local nX:=1
Default cConfigDe	:= SPACE(Len(AL1->AL1_CONFIG))
Default cConfigAte	:= Replicate("Z",Len(AL1->AL1_CONFIG))
Default cAliasAKD	 	:= "AKD" 
Default lReproc 		:= .F.
Default lForcaAtu		:= (cAliasAKD <> 'AKD')

If aCubeStru == NIL
	aCubeStru := Pco_ChvCube()	
EndIf

dbSelectArea("AKT")
dbSetOrder(1)
dbSelectArea("AKS")
dbSetOrder(1)
dbSelectArea("AL1")
dbSetOrder(1)
dbSeek(xFilial()+cConfigDe,.T.)
While !Eof() .And. AL1->AL1_FILIAL==xFilial("AL1") .And. AL1->AL1_CONFIG <= cConfigAte
	cTipoAtu	:=	IIf(Empty(AL1->AL1_TPATU),'1',AL1->AL1_TPATU)
	If  !Empty(AL1->AL1_CHAVER) .And. (lForcaAtu .Or. cTipoAtu <> '3')
		nPos	:= 1
		cChave := (cAliasAKD)->(Padr(&(StrTran(AL1->AL1_CHAVER,'AKD->',cAliasAKD+'->')),Len(AKT->AKT_CHAVE)))	
		If SuperGetMV("MV_PCOCHKS",.F.,"1")=="1"
			dbSelectArea("AKW")
			dbSetOrder(1)
			MsSeek(xFilial()+AL1->AL1_CONFIG)
			While !Eof() .And. 	xFilial()+AL1->AL1_CONFIG == AKW->AKW_FILIAL+AKW->AKW_COD
				dbSelectArea(AKW->AKW_ALIAS)
				dbSetOrder(1)
				If Empty(Substr(cChave,nPos,AKW->AKW_TAMANH))
					If lNotBlind .And. AKW->AKW_OBRIGA == "1"   //campo obrigatorio
						Aviso(STR0001,; //"Processamento de Cubos - Planejamento e Controle Orçamentário"
												STR0002+CHR(13)+CHR(10)+; //"O processamento de saldos do Planejamento e Controle Orçamentario pode estar comprometida pois foram encontrados dados inconsistentes na atualização dos cubos do orçamento. Verifique as configurações do cubo:"
											 	STR0003+AL1->AL1_CONFIG+Space(20)+; //"Código do Cubo : "
											 	STR0004+AKW->AKW_NIVEL+CHR(13)+CHR(10)+; //"Nivel do Cubo : "
											 	STR0005+AKW->AKW_ALIAS+"-"+Sx2Name(AKW->AKW_ALIAS)+CHR(13)+CHR(10)+; //"Tabela : "
											 	STR0006+Alltrim(AKW->AKW_DESCRI)+STR0007+CHR(13)+CHR(10)+; //"Descrição : "###" *** Nao Informado ***"
											 	If(cAliasAKD!="AKD","",;
											 	STR0008+AKD->AKD_LOTE+"/"+AKD->AKD_ID+CHR(13)+CHR(10))+; //"Movimento Origem (Lote/Item) : "
												STR0009,{"Ok"},3,STR0010) //"Chave invalida : (*** Campo obrigatorio nao informado ***)"###"Atenção!"
					EndIf
				Else
					If lNotBlind .And. !Empty(Substr(cChave,nPos,AKW->AKW_TAMANH)) .And. !MsSeek(xFilial(AKW->AKW_ALIAS)+Substr(cChave,nPos,AKW->AKW_TAMANH))
						Aviso(STR0001,	STR0002+CHR(13)+CHR(10)+; //"Processamento de Cubos - Planejamento e Controle Orçamentário"###"O processamento de saldos do Planejamento e Controle Orçamentario pode estar comprometida pois foram encontrados dados inconsistentes na atualização dos cubos do orçamento. Verifique as configurações do cubo:"
											 	STR0003+AL1->AL1_CONFIG+Space(20)+; //"Código do Cubo : "
											 	STR0004+AKW->AKW_NIVEL+CHR(13)+CHR(10)+; //"Nivel do Cubo : "
											 	STR0005+AKW->AKW_ALIAS+"-"+Sx2Name(AKW->AKW_ALIAS)+CHR(13)+CHR(10)+; //"Tabela : "
											 	STR0006+Alltrim(AKW->AKW_DESCRI)+STR0011+CHR(13)+CHR(10)+; //"Descrição : "###" *** Nao Encontrado ***"
											 	If(cAliasAKD!="AKD","",;
											 	STR0008+AKD->AKD_LOTE+"/"+AKD->AKD_ID+CHR(13)+CHR(10))+; //"Movimento Origem (Lote/Item) : "
												STR0012+Substr(cChave,nPos,AKW->AKW_TAMANH),{"Ok"},3,STR0010) //"Chave invalida : "###"Atenção!"
					EndIf
				EndIf
				nPos += AKW->AKW_TAMANH
				dbSelectArea("AKW")
				dbSkip()
			End
		EndIf

		// verificando se o cubo esta sendo reprocessado neste momento
		If ! lReproc .And. Pco_UsedCube(AL1->AL1_CONFIG)
	 
			//caso o cubo esteja sendo reprocessado joga para a fila		
			Pco_PutQueue( aClone({AL1->AL1_CONFIG, cChave }), cTipoMov, dData, IIf(lReproc,'1','2')/*cReproc*/, aValor, cFilAnt, AKD->(Recno())/*nRecAKD*/)
		
		Else
		
			If lForcaAtu .Or. cTipoAtu == '1' 
				PcoWriteSld(cAliasAKD,AL1->AL1_CONFIG,aValor,cTipoMov           ,dData                 ,cChave,,lReproc)
			ElseIf cTipoAtu == '2'
				AAdd(aJobs,{AL1->AL1_CONFIG,cChave})
			EndIf
		
		EndIf
		
	EndIf		
	dbSelectArea("AL1")
	dbSkip()
End

//Colocar na fila
For nX:= 1 To Len(aJobs)

	Pco_PutQueue(aJobs[nX], cTipoMov, dData, IIf(lReproc,'1','2')/*cReproc*/, aValor, cFilAnt, AKD->(Recno())/*nRecAKD*/)

Next

RestArea(aAreaAKS)
RestArea(aAreaAL1)
RestArea(aArea)

Return 

Static Function Pco_PutQueue(aJobs, cTipoMov, dData, cReproc, aValor, cFilAnt, nRecAKD)

RecLock('ALA',.T.)
ALA_FILIAL	:=	xFilial('ALA')
ALA_STATUS	:=	'1'
ALA_DATA	:=	MsDate()
ALA_HORA	:= Time()
ALA_CUBO	:=	aJobs[1]
ALA_CHAVAK	:=	aJobs[2]
ALA_TIPOMV	:=	cTipoMov
ALA_DATAMV	:=	dData
ALA_REPROC 	:=	cReproc  //IIf(lReproc,'1','2')
ALA_VALOR1  :=	aValor[1]
ALA_VALOR2  :=	aValor[2]
ALA_VALOR3  :=	aValor[3]
ALA_VALOR4  :=	aValor[4]
ALA_VALOR5  :=	aValor[5]
ALA_FILMOV	:=	cFilAnt
ALA_RECAKD	:=	nRecAKD // AKD->(Recno())
MsUnLock()

//start o job assim que entrar 1 registro na fila (ALA)
lExisteJob	:=	File('/semaforo/pcojobsld'+aJobs[1]+'.job') .And. Ferase('/semaforo/pcojobsld'+aJobs[1]+'.job') == -1
If !lExisteJob
	StartJob("PcoJobSld",GetEnvServer(),.F.,cEmpAnt,cFilAnt,aJobs[1])
Endif	

Return

/*
_F_U_N_C_ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³PcoRetSld ³ AUTOR ³ Edson Maricate        ³ DATA ³ 14.02.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Funcao de Retoorno dos saldos de uma entidade                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ USO      ³ SIGAPCO                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³_DOCUMEN_ ³ PcoRetSld                                                    ³±±
±±³_DESCRI_  ³ Funcao para consulta aos saldos das entidades de acordo      ³±±
±±³_FUNC_    ³ com o codigo da configuracao de saldos informada.            ³±±
±±³          ³                                                              ³±±
±±³          ³                                                              ³±±
±±³          ³                                                              ³±±
±±³          ³                                                              ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³_PARAMETR_³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoRetSld(cConfig,cChave,dData)
Local aArea	:= GetArea()
Local aSaldo 	:= {{0,0,0,0,0},{0,0,0,0,0}}
Local aSldAux
Local lQuery	:=	.F.
Local cQuery	:=	""
Local lContinua := .T.
Local lSldChv	:= ( GetNewPar("MV_PCOMCHV","1") == "4" )  
Local lPcoSldo  := ExistBlock("PCOSLDO")
Local cPCO002   := GetSPName('PCO002',"13")
IF TcGetDb() <> "AS/400"
	lQuery	:=	.T.
Endif

dbSelectArea("AKT")
dbSetOrder(1)
	
If lProcRetSld == Nil
	lProcRetSld := ExistProc(cPCO002,VerIDProc1())
Endif

If !lQuery
	
	dbSelectArea("AKT")
	lContinua := dbSeek(xFilial("AKT")+cConfig+Padr(cChave,Len(AKT->AKT_CHAVE)))

    If lContinua

		While AKT->( !Eof() .And. AKT_FILIAL+AKT_CONFIG+AKT_CHAVE+DTOS(AKT_DATA) <= xFilial("AKT")+cConfig+Padr(cChave,Len(AKT->AKT_CHAVE))+DTOS(dData) )  
			aSaldo[1,1]+= AKT->AKT_MVCRD1
			aSaldo[1,2]+= AKT->AKT_MVCRD2
			aSaldo[1,3]+= AKT->AKT_MVCRD3
			aSaldo[1,4]+= AKT->AKT_MVCRD4
			aSaldo[1,5]+= AKT->AKT_MVCRD5
			aSaldo[2,1]+= AKT->AKT_MVDEB1
			aSaldo[2,2]+= AKT->AKT_MVDEB2
			aSaldo[2,3]+= AKT->AKT_MVDEB3
			aSaldo[2,4]+= AKT->AKT_MVDEB4
			aSaldo[2,5]+= AKT->AKT_MVDEB5
			AKT->( dbSkip() )
		EndDo

	EndIf
	
Else            

	dbSelectArea("AKT")
	dbSetOrder(1)
	If lSldChv .Or. lProcRetSld
		lContinua := .T.
	Else
		lContinua := MsSeek(xFilial("AKT")+cConfig+Padr(cChave,Len(AKT->AKT_CHAVE)))
	EndIf	

	If lContinua .And. lProcRetSld
		MsSeek(xFilial("AKT")+cConfig+Padr(cChave,Len(AKT->AKT_CHAVE))) //Posiciona no registro AKT
		aSldAux	:= TCSPExec( xProcedures(cPCO002), xFilial("AKT"), Dtos(dData), cConfig, PadR(cChave,Len(AKS->AKS_CHAVE)))
		aSaldo  := { 	{ aSldAux[1], aSldAux[2], aSldAux[3], aSldAux[4], aSldAux[5] },;
		                { aSldAux[6], aSldAux[7], aSldAux[8], aSldAux[9], aSldAux[10] } }

	Else

		If lContinua

			cQuery	:=	"SELECT "
			cQuery	+=	" SUM(AKT_MVCRD1) AKT_MVCRD1, "
			cQuery	+=	" SUM(AKT_MVCRD2) AKT_MVCRD2, "
			cQuery	+=	" SUM(AKT_MVCRD3) AKT_MVCRD3, "
			cQuery	+=	" SUM(AKT_MVCRD4) AKT_MVCRD4, "
			cQuery	+=	" SUM(AKT_MVCRD5) AKT_MVCRD5, "
			cQuery	+=	" SUM(AKT_MVDEB1) AKT_MVDEB1, "
			cQuery	+=	" SUM(AKT_MVDEB2) AKT_MVDEB2, "
			cQuery	+=	" SUM(AKT_MVDEB3) AKT_MVDEB3, " 
			cQuery	+=	" SUM(AKT_MVDEB4) AKT_MVDEB4, "
			cQuery	+=	" SUM(AKT_MVDEB5) AKT_MVDEB5  "
			cQuery	+=	" FROM	"+RetSqlName('AKT')+" AKT "
			cQuery	+=	" WHERE "			
			cQuery	+=	" AKT_FILIAL = '"+AKT->(xFilial("AKT"))+"' AND " 
			cQuery	+=	" AKT_CONFIG = '"+cConfig  +"' AND " 
			cQuery	+=	" AKT_CHAVE  = '"+Padr(cChave,Len(AKS->AKS_CHAVE))+"' AND " 
			cQuery	+=	" AKT_DATA <= '"+dtos(dData)+"' AND "
			cQuery	+=	" D_E_L_E_T_= ' '"
			
			cQuery := ChangeQuery( cQuery )       

			dbUseArea( .T., "TopConn", TCGenQry(,,cQuery),"QRYTRB", .F., .F. )
			
			If QRYTRB->( !Eof() )
				aSaldo[1,1] += QRYTRB->AKT_MVCRD1
				aSaldo[1,2] += QRYTRB->AKT_MVCRD2
				aSaldo[1,3] += QRYTRB->AKT_MVCRD3
				aSaldo[1,4] += QRYTRB->AKT_MVCRD4
				aSaldo[1,5] += QRYTRB->AKT_MVCRD5
				aSaldo[2,1] += QRYTRB->AKT_MVDEB1
				aSaldo[2,2] += QRYTRB->AKT_MVDEB2
				aSaldo[2,3] += QRYTRB->AKT_MVDEB3
				aSaldo[2,4] += QRYTRB->AKT_MVDEB4
				aSaldo[2,5] += QRYTRB->AKT_MVDEB5
			EndIf
			
			QRYTRB->( dbCloseArea() )

		EndIf
		
	EndIf
EndIf

IF lPcoSldo
	aSaldo := ExecBlock("PCOSLDO",.F.,.F.,aSaldo)
EndIF

RestArea(aArea)

Return aSaldo


Function PcoWriteSld(cAliasAKD,cConfig,aValor,cTipoMov,dData,cChave,cAtuSin,lReproc,cNivSint,lAnalit)
Local aArea	 := GetArea()
Local aAreaAKW := AKW->(GetArea())
Local dDataFim
Local aAreaSave
Local cChaver	 	:=	""
Local cChavSin	 	:=	""
Local lContinua   := .T. // continua com o processamento
Local nZ, nPosConfig, nPosTpSald, nPosCpo, aCubeAux		
Local aNivChave := nil
Local cTpSald:= ""
Local cPCO001   := GetSPName("PCO001","12")
Local cPCO003   := GetSPName("PCO003","13")
Local lProcIFX  
Default cAtuSin	:= ""
Default lReproc	:= .F.
Default cNivSint:= ""
Default lAnalit := .T.

If _lAKTANALIT == NIL
	_lAKTANALIT := ( AKT->( FieldPos("AKT_ANALIT") ) > 0 )
EndIf

//***************************************************************
//      Data: 12/08/09 - Acacio Egas                            *
// Verrifica se a PcoDetLan foi chamada dentro de uma Transacao.*
// Neste caso nao se pode manipular as Tabelas AKS e AKT dentro *
// da transacao. A atualização sera feita na PcoFinLan.         *
//***************************************************************
If PcoIntrans()

	aAdd(aAtuTransa,{cAliasAKD,cConfig,aValor,cTipoMov,dData,cChave,cAtuSin,lReproc,cNivSint})

Else
	If ((Alltrim(Upper(TcGetDb())) == "INFORMIX"))
		//Somente INFORMIX
		If !TCSPExist("TX")
			lProcIFX := cCriaSPIFX()
		EndIf
	EndIf
	If lProcAtSld == Nil
		//desvio para INFORMIX nao executar procedure
		//reprocessar pela rotina do padrao
		lProcAtSld := If( !(Alltrim(Upper(TcGetDb())) $ "MSSQL7|ORACLE|DB2|INFORMIX"),.F., .T.)
		If lProcAtSld
		    //se os campos nao existir nao executa por procedure 
		    //AKS ou AKT_NIV01.......NIV06/AKT_TPSALD nao executa a procedure PCO003
			If 	AKT->(FieldPos("AKT_TPSALD")) == 0 .OR. ;
				AKT->(FieldPos("AKT_NIV01")) == 0 .OR. ;
				AKT->(FieldPos("AKT_NIV02")) == 0 .OR. ;
				AKT->(FieldPos("AKT_NIV03")) == 0 .OR. ;
				AKT->(FieldPos("AKT_NIV04")) == 0 .OR. ;
				AKT->(FieldPos("AKT_NIV05")) == 0 .OR. ;
				AKT->(FieldPos("AKT_NIV06")) == 0 .OR. ;
				AKT->(FieldPos("AKT_ANALIT")) == 0
				lProcAtSld := .F.
			Else
				lProcAtSld := ExistProc(cPCO003,VerIDProc1())
			EndIf
		EndIf
	Endif
	If lProcedure == Nil
		lProcedure := lProcAtSld
	Endif
	
	Private AUXCHAVE	:= ""
	Private aResult  := {} 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de Entrada para verificar se grava o lançamento no cubo gerencial.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("PCOGrvSld")
		lContinua := ExecBlock("PCOGrvSld",.F.,.F.,{cAliasAKD,cConfig,aValor,cTipoMov,dData,cChave,cNivSint})
	EndIf
	
	If lContinua
		
		dbSelectArea("AKT")
		
		//inicia o semaforo
		While !LockByName(xFilial("AKT")+cConfig+cChave+DTOS(dData),.T.,.T.,.T.)
			Sleep(100)
		EndDo

		If aCubeStru == NIL
			aCubeStru := Pco_ChvCube()	
		EndIf

		//grava a chave quebradas por nivel do cubo gerencial e tipo de saldo
		nPosConfig := aScan(aCubeStru, {|x| Alltrim(x[1]) == Alltrim(cConfig) } )  //procura o cubo
	
		If nPosConfig > 0
	
			aCubeAux := aCubeStru[nPosConfig, 2]
			nPosTpSald := aScan(aCubeAux, {|x| Alltrim(x[1])=="AL2" }) //procura dimensao tipo saldo        
			
			If Len(aCubeAux)<7
				aNivChave := Array(6) // Caso o cubo tenha menos de 7 niveis
				AEval(aNivChave, {|x,y| aNivChave[y]:= ''})
			Else
				aNivChave := Array(Len(aCubeAux) -1 )
			EndIf
	
			//*******************************************
			// Valida se o cubo tem no maximo 7 niveis  *
			//*******************************************
			If lProcAtSld .And. lProcedure .And. Len(aCubeAux)<=7
						
				aCubeAux := aCubeStru[nPosConfig, 2]
				nPosTpSald := aScan(aCubeAux, {|x| Alltrim(x[1])=="AL2" }) //procura dimensao tipo saldo
				
				For nZ := 1 TO Len(aCubeAux)
					//grava a chave quebrada por dimensao do cubo
					If nZ == nPosTpSald
						cTpsald := Substr(cChave, aCubeAux[ nZ, 3], aCubeAux[ nZ, 4])
					Else
						aNivChave[nZ] := Substr(cChave, aCubeAux[ nZ, 3], aCubeAux[ nZ, 4])
					EndIf
				Next //nZ
				//somente Informix
				If Upper(Alltrim(tcGetDb())) == "INFORMIX"
					If TCSPExist("TX")
						tcSPExec("TX")
					EndIf
				End                

				If lProcedure
					//atualizacao de todo os saldos com procedure PCO003
					aResult := TCSPExec( xProcedures(cPCO003), cFilAnt, cConfig, cTipoMov, Dtos(dData), Dtos(LastDay(dData)), cChave, ;
			                 aValor[1],aValor[2],aValor[3],aValor[4],aValor[5],cTpSald, aNivChave[1], aNivChave[2], aNivChave[3],;
								  aNivChave[4], aNivChave[5], aNivChave[6],If(lAnalit, "1", "0"))
			
					If Empty(aResult) .Or. Empty(aResult[1]) .Or. aResult[1] = "0"
						PcoAlertPr( STR0017, IsBlind() )
					EndIf
				EndIf
			Else
						
				//*************************************************
				// Utilizado para montar as Chaves das superiores *
				//*************************************************
				For nZ := 1 TO Len(aCubeAux)
					//grava a chave quebrada por dimensao do cubo
					If nZ == nPosTpSald
						cTpsald := Substr(cChave, aCubeAux[ nZ, 3], aCubeAux[ nZ, 4])
					Else
						aNivChave[nZ] := Substr(cChave, aCubeAux[ nZ, 3], aCubeAux[ nZ, 4])
					EndIf    
		    	Next				
		
				//atualizacao de todo os saldos sem utilizar procedure PCO003
				If dbSeek(xFilial("AKT")+cConfig+cChave+DTOS(dData))
					RecLock("AKT",.F.)
					If cTipoMov == "C"
						AKT->AKT_MVCRD1 += aValor[1]
						AKT->AKT_MVCRD2 += aValor[2]
						AKT->AKT_MVCRD3 += aValor[3]
						AKT->AKT_MVCRD4 += aValor[4]
						AKT->AKT_MVCRD5 += aValor[5]
					ElseIf cTipoMov == "D"
						AKT->AKT_MVDEB1 += aValor[1]
						AKT->AKT_MVDEB2 += aValor[2]
						AKT->AKT_MVDEB3 += aValor[3]
						AKT->AKT_MVDEB4 += aValor[4]
						AKT->AKT_MVDEB5 += aValor[5]
					EndIf
					MsUnlock()
					AKT->( dbCommit() )
				Else
					RecLock("AKT",.T.)
					AKT->AKT_FILIAL := xFilial("AKT")
					AKT->AKT_CHAVE 	:= cChave
					AKT->AKT_DATA	:= dData
					AKT->AKT_CONFIG := cConfig
					If _lAKTANALIT 
						AKT->AKT_ANALIT := If(lAnalit, "1", "0")
					EndIf 
					If cTipoMov == "C"
						AKT->AKT_MVCRD1 := aValor[1]
						AKT->AKT_MVCRD2 := aValor[2]
						AKT->AKT_MVCRD3 := aValor[3]
						AKT->AKT_MVCRD4 := aValor[4]
						AKT->AKT_MVCRD5 := aValor[5]
					ElseIf cTipoMov == "D"
						AKT->AKT_MVDEB1 := aValor[1]
						AKT->AKT_MVDEB2 := aValor[2]
						AKT->AKT_MVDEB3 := aValor[3]
						AKT->AKT_MVDEB4 := aValor[4]
						AKT->AKT_MVDEB5 := aValor[5]
					EndIf
										
					For nZ := 1 TO Len(aCubeAux)
		
						//grava a chave quebrada por dimensao do cubo
						If nZ == nPosTpSald
							nPosCpo := AKT->(FieldPos("AKT_TPSALD"))
						Else
							nPosCpo := AKT->(FieldPos("AKT_NIV"+StrZero(nZ, 2)))
						EndIf
		
						If nPosCpo > 0  //se o campo existe na tabela AKT entao grava
							AKT->(FieldPut(nPosCpo, Substr(cChave, aCubeAux[ nZ, 3], aCubeAux[ nZ, 4])))
						EndIf
		
					Next //nZ
												
					MsUnLock()
					AKT->( dbCommit() )
				EndIf
								
			EndIf
	
			//termina o semaforo 
			UnLockByName(xFilial("AKT")+cConfig+cChave+DTOS(dData),.T.,.T.,.T.)
	
			// Verifica a existencia da conta superior na configuração do saldo
			dbSelectArea("AKW")
			dbSetOrder(1)
			MsSeek(xFilial()+cConfig+cNivSint)
		    nCont := 1
			While !Eof() .And. AKW->AKW_FILIAL+AKW->AKW_COD==xFilial()+cConfig .And. (Empty(cNivSint) .Or.cNivSint == AKW->AKW_NIVEL)

				cChaver	:= ''
				aEval(aNivChave,{|x,y| If(y<=nCont,cChaver+= x,.F.) })

				If !Empty(cAtuSin) .And. cNivSint == AKW->AKW_NIVEL
					AUXCHAVE	:= cAtuSin
				Else
					AUXCHAVE	:= cChaver
				EndIf
				aAreaSave :=(AKW->AKW_ALIAS)->(GetArea())
				dbSelectArea(AKW->AKW_ALIAS)
				dbSetOrder(1)
				dbSeek(xFilial()+cChaver)
				cContaSint	:=	""
				If !Empty(AKW->AKW_ATUSIN)
					cContaSint	:=	&((cAliasAKD)->(StrTran(AKW->AKW_ATUSIN,'AKD->',cAliasAKD+'->')))
					If !Empty(cContaSint)
						cChavSin	:=	''
						aEval(aNivChave,{|x,y| cChavSin += If(y=nCont,cContaSint,x) })
						cChavSin	:=	Padr(cChavSin + cTpsald,Len(AKT->AKT_CHAVE))
						PcoWriteSld(cAliasAKD,cConfig,aValor,cTipoMov,dData,cChavSin    ,cContaSint,lReproc,AKW->AKW_NIVEL, .F. /*lAnalit*/ )
					Endif
				EndIf
				RestArea(aAreaSave)
				dbSelectArea("AKW")
				dbSkip()
				nCont++
			EndDo

		Endif
	
	EndIf

EndIf

RestArea(aAreaAKW)
RestArea(aArea)
Return

Function Sx2Name(cAlias)
Local aArea := GetArea()
Local aAreaSX2 := SX2->(GetArea())
Local cSx2Name := ""
dbSelectArea("SX2")
dbSetOrder(1)
If dbSeek(cAlias)
	cSx2Name := Alltrim(SX2->(X2NOME()))
EndIf



RestArea(aAreaSX2)
RestArea(aArea)

Return(cSx2Name)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PmsJobRlz ³ Autor ³Edson Maricate         ³ Data ³19.07.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Job de calculo do PMS                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto XML                                           ³±±
±±³          ³ExpN2: ID do JOB                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PcoJobSld(cCodEmp,cCodFil,cJob)
Local nHdl
Local lComecou
Local cChave            
Local nCtdSelect  := 0
Local cJobFile	:=	'/semaforo/pcojobsld'+cJob+'.job'
nHdl	:=	FCreate(cJobFile)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Preparando o ambiente para execucao                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RpcSetType ( 3 )
PREPARE ENVIRONMENT EMPRESA cCodEmp FILIAL cCodFil MODULO "PCO"                                 
	ConOut("PCOJOBSLD("+Alltrim(cJob)+")-["+Dtoc(Date())+" "+Time()+"]: "+"Job de atualizazao de saldos iniciado...") 
	nIntervalo	:=	GetNewPar('MV_PCOJOB1',10)
	nDiasALA		:=	GetNewPar('MV_PCOJOB2',0)
	While !KillApp()                             
		lComecou	:=	.F.                                             
		Sleep(nIntervalo*1000)
		cQuery	:=	" SELECT ALA.*,AL1.R_E_C_N_O_ AS AL1REC,ALA.R_E_C_N_O_ AS ALAREC FROM "+RetSqlName('ALA')+" ALA,"+RetSqlName('AL1')+" AL1 "
		cQuery	+=	" WHERE ALA_FILIAL = '"+xFilial('ALA')+"' AND "
		cQuery	+=	" ALA_STATUS = '1'  AND "
		cQuery	+=	" ALA.ALA_CUBO  = '"+cJob+"' AND "
		cQuery	+=	" ALA.D_E_L_E_T_ = ' ' AND"
		cQuery	+=	" AL1_FILIAL = '"+xFilial('AL1')+"' AND "
		cQuery	+=	" AL1_CONFIG = ALA.ALA_CUBO  AND "     
		cQuery	+=	" AL1.D_E_L_E_T_ = ' ' "
		cQuery	+=	" ORDER BY ALA_FILIAL,ALA_DATA,ALA_HORA,ALA_CUBO"

		cQuery := ChangeQuery( cQuery )       
		
		dbUseArea( .T., "TopConn", TCGenQry(,,cQuery),"ALATRB", .F., .F. )
		DbGoTop()        
		AL1->(DbSetOrder(1))
		If !Eof()
			ConOut("PCOJOBSLD("+Alltrim(cJob)+")-["+Dtoc(Date())+" "+Time()+"]: "+" Atualizando saldos...") 
			lComecou	:=	.T.
			nCtdSelect  := 1
		Else
			nCtdSelect++
			If nCtdSelect > 4
				DbSelectArea('ALATRB')
				DbCloseArea()
				Exit
			EndIf		
		Endif
		While !Eof()

			AL1->(dbSkip())  //nao retirar esta instrucao pois serve para provocar mudanca da linha
								// da tabela AL1 - nao enxergava atualização do campo AL1_STATUS na instr.abaixo			
			AL1->(MsGoTo(ALATRB->AL1REC))
			// avanca se o cubo que for processar estiver em reprocessamento  (pcoa300)
		    If Pco_UsedCube(AL1->AL1_CONFIG)
				DbSelectArea('ALATRB')
				DbSkip()
				Loop
		    EndIf
			
			AKD->(MsGoTo(ALATRB->ALA_RECAKD))
			DbSelectArea('ALA')
			MsGoTo(ALATRB->ALAREC)
			If	MsRLock()  
				If nDiasALA > 0
					ALA_DATAI 	:=	MsDate()
					ALA_HORAI 	:=	Time()
				Endif
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Pesquisa o Pedido de Venda solicitado                                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                                             
				cChave	:=	Padr(ALATRB->ALA_CHAVAK,Len(AKT->AKT_CHAVE))
				PcoWriteSld('AKD',AL1->AL1_CONFIG,{ALATRB->ALA_VALOR1,ALATRB->ALA_VALOR2,ALATRB->ALA_VALOR3,ALATRB->ALA_VALOR4,ALATRB->ALA_VALOR5},ALATRB->ALA_TIPOMV,STOD(ALATRB->ALA_DATAMV),cChave,,ALATRB->ALA_REPROC=='1')
				ALA_STATUS	:=	'2'
				If nDiasALA > 0
					ALA_DATAF 	:=	MsDate()
					ALA_HORAF 	:=	Time()
				Endif
				MsUnLock()
			Endif
			DbSelectArea('ALATRB')
			DbSkip()
		Enddo
		If lComecou
			cQuery	:= "DELETE FROM  "+RetSqlName('ALA') 
			cQuery	+=	" WHERE ALA_FILIAL = '"+xFilial('ALA')+"' AND "
			cQuery	+=	" ALA_CUBO  = '"+cJob+"' AND "
			cQuery	+=	" ALA_STATUS = '2'  AND ALA_DATA <= " +Dtos(MsDate()-nDiasALA)
			TcSqlExec(cQuery)
			ConOut("PCOJOBSLD("+Alltrim(cJob)+")-["+Dtoc(Date())+" "+Time()+"]-["+Dtoc(Date())+" "+Time()+"]: "+" Atualizacao de saldos finalizada...") 
   		Endif
		DbSelectArea('ALATRB')
		DbCloseArea()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Finalizando o ambiente para execucao                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	EndDo      
   	FClose(nHdl)
	FErase(cJobFile)

RESET ENVIRONMENT	

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Pco_ChvCube ºAutor  ³Paulo Carnelossi    º Data ³ 07/02/08  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que carrega todos os cubos com a posicao inicial e   º±±
±±º          ³final para cada nivel do cubo com relacao a Chave completa  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Pco_ChvCube()
Local aArea		:= GetArea()
Local aAreaAL1	:= AL1->(GetArea())
Local aAreaAKW	:= AKW->(GetArea())
Local cCodeCube
Local nPosInic

dbSelectArea("AL1")
dbSetOrder(1)
If dbSeek(xFilial())

	aCubeStru := {}
	
	While AL1->( ! Eof() .And. AL1_FILIAL==xFilial("AL1") )
	    
		cCodeCube := AL1->AL1_CONFIG
	
		dbSelectArea("AKW")
		dbSetOrder(1)
	   
		If dbSeek(xFilial("AKW")+cCodeCube)
		
			aAdd(aCubeStru, { cCodeCube, {} } )
			nPosInic := 1
	   
			While AKW->( ! Eof() .And. AKW_FILIAL+AKW_COD == xFilial("AKW")+cCodeCube )
	
				aAdd(aCubeStru[Len(aCubeStru), 2], { AKW->AKW_ALIAS, AKW->AKW_NIVEL, nPosInic, AKW->AKW_TAMANH } )
				nPosInic += AKW->AKW_TAMANH
				
			   dbSelectArea("AKW")
			   dbSkip()
		   
			EndDo
		
	    EndIf
		
		dbSelectArea("AL1")
		dbSkip()
	
	EndDo
EndIf
RestArea(aAreaAKW)
RestArea(aAreaAL1)
RestArea(aArea)

Return(aCubeStru)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VerIDProc1³ Autor ³ Marcelo Pimentel      ³ Data ³24.07.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Identifica a sequencia de controle do fonte ADVPL com a     ³±±
±±³          ³stored procedure, qualquer alteracao que envolva diretamente³±±
±±³          ³a stored procedure a variavel sera incrementada.            ³±±
±±³          ³Procedure PC0O01                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/         
Static Function VerIDProc()
//Não retirar, utilizado pelo configurador para a procedure 012 - Compatibilização com versões anteriores a 12.1.17 Out/17
Return '010'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VerIDProc1³ Autor ³ Marcelo Pimentel      ³ Data ³24.07.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Identifica a sequencia de controle do fonte ADVPL com a     ³±±
±±³          ³stored procedure, qualquer alteracao que envolva diretamente³±±
±±³          ³a stored procedure a variavel sera incrementada.            ³±±
±±³          ³Procedure PC0O03                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/         
Static Function VerIDProc1()
Return '011'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PcoFinTranºAutor  ³ Acacio Egas        º Data ³  08/12/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atuliza a fila de atualizacao de saldo criado devido ao    º±±
±±º          ³ controle de transacao ativo no banco.                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PCOFINLAN (PCOXFUN)                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PcoFinTran()

Local nX

For nX :=1 to Len(aAtuTransa)	
	PcoWriteSld(aAtuTransa[nX,1],aAtuTransa[nX,2],aAtuTransa[nX,3],aAtuTransa[nX,4],aAtuTransa[nX,5],aAtuTransa[nX,6],aAtuTransa[nX,7],aAtuTransa[nX,8],aAtuTransa[nX,9])
Next
aAtuTransa	:= {}

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PcoVldCub ºAutor  ³ Acacio Egas        º Data ³  12/15/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função de validação da estrutura do cubo para utilizar     º±±
±±º          ³  consulta por nivel.                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAPCO                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoVldCub(cCubo)

Local aAreaAL1	:= AL1->(GetArea())
Local aAreaAKW	:= AKW->(GetArea())
Local aArea		:= GetArea()
Local lRet		:= .T.

DbSelectArea("AKW")
DbSetOrder(1)
DbSeek(xFilial("AKW")+cCubo)
Do while AKW->(!Eof()) .and. AKW->(AKW_FILIAL+AKW_COD)==xFilial("AKW")+cCubo
	cNiv	:= PadR( AKW->AKW_NIVEL , 2)
	If AKW->AKW_ALIAS<>"AL2" .and. (AKS->(FieldPos("AKS_NIV" + cNiv)) = 0 .or. AKT->(FieldPos("AKT_NIV" + cNiv)) = 0)
		lRet	:= .F.
		Exit
	EndIf
	AKW->(DbSkip())
EndDo

If !lRet

	Aviso(STR0013,STR0014; //"Atenção!"##"A estrutura do cubo gerencial selecionado não é suportada pelas consultas por nível."
		 + CHR(13) + CHR(10) + STR0015, {STR0016})//"Desative o parâmetro 'MV_PCOCNIV' ou consulte a configuração de cubos com mais de 7 níveis."##"OK"

EndIf

RestArea(aAreaAL1)
RestArea(aAreaAKW)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} EngSPS12Signature
Processo 12 - ATUALIZA SALDOS DOS CUBOS NAS DATAS POSTERIORES AO MOVIMENTO (MV_PCOINTE = '1')
Funções executadas durante a exibição de informações detalhadas 
do processo na interface de gestão de procedures.
Faz a execução de funções STATIC proprietárias das rotinas donas 
dos processos.

@return  cAssinatura
@author  TOTVS
@since   01/02/2022
@version 12
/*/
//-------------------------------------------------------------------
Function EngSPS12Signature(cProcess as character)
Local cAssinatura as character

cAssinatura := STATICCALL(PCOXSLD,VERIDPROC)

Return cAssinatura

//-------------------------------------------------------------------
/*/{Protheus.doc} EngSPS13Signature
// Processo 13 - ATUALIZA OS SALDOS DOS CUBOS POR CHAVE (MV_PCOINTE = '1')
Funções executadas durante a exibição de informações detalhadas 
do processo na interface de gestão de procedures.
Faz a execução de funções STATIC proprietárias das rotinas donas 
dos processos.

@return cAssinatura
@author  TOTVS
@since   13/12/2021
@version 12
/*/
//-------------------------------------------------------------------
Function EngSPS13Signature(cProcess as character)
Local cAssinatura as character

cAssinatura := STATICCALL(PCOXSLD,VERIDPROC1)

Return cAssinatura


//-------------------------------------------------------------------
/*/{Protheus.doc} PcoAlertPr
// Funcao para verificar se msg deve ser exibida via alert para o usuario dar OK ou mandar para Console via CONOUTR

@return 
@author  TOTVS
@since   28/09/2022
@version 12
/*/
//-------------------------------------------------------------------
Static Function PcoAlertPr( cMsg, lBlind )

Default cMsg := ""
Default lBlind := IsBlind()

If ! lBlind
	MsgAlert( cMsg )
Else
	ConOutR( cMsg , .F. , 'PCOXSLD' )
EndIf

Return .T.