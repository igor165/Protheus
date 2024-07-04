#INCLUDE "PCOA300.ch"
#INCLUDE "PROTHEUS.CH"
// INCLUIDO PARA TRADU«√O DE PORTUGAL//

Static __lBlind  := IsBlind()
Static lProcA300 := NIL
Static cTipoDB
Static lQuery
Static lOracle
Static lPostgres
Static lDB2
Static lInformix
Static cSrvType

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥ Pcoa300 ∫ Autor ≥                     ∫ Data ≥  06/07/16   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Rotina de reprocessamento de cubos                         ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ PCOA300 - Planejamento e Controle Orcamentario             ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Function Pcoa300(lAuto, aParametros)
LOCAL nOpca	:=0
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Define Variaveis                                             ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ           


Local aSays			:={}
Local aButtons		:={}
Local cFunction		:= "PCOA300"
Local cPerg			:= "PCA300"
Local cTitle		:= STR0001	//"Reprocessamento dos Saldos"
Local cDescription	:= STR0002 + CRLF +;		//"  Este programa tem como objetivo recalcular e analisar os saldos dia a dia de um "
					   STR0003 + CRLF + CRLF+;	//"  determinado per°odo ate a data base do sistema. "
					   STR0004	//"  Utilizado no caso de haver necessidade de entrada de movimentos  retroativos. "
Local bProcess		:= { |oSelf| PCOA300Sld(oSelf) }
Local lRet          := .T.

Private cCadastro := STR0001 //"Reprocessamento dos Saldos"

DEFAULT lAuto := .F.
DEFAULT aParametros := {}

IF FunName() == 'PCOA300'  //acerta variavel static __lBlind qdo amteriormente foi chamada de outra rotina pcoa301/pcoa302
	__lBlind  := IsBlind()
EndIf

If lAuto .And. Len(aParametros) > 0
	
	MV_PAR01 := aParametros[1]  //Cubo de
	MV_PAR02 := aParametros[2]  //Cubo Ate
	MV_PAR03 := aParametros[3]  //data de 
	MV_PAR04 := aParametros[4]  //data ate
	MV_PAR05 := aParametros[5]  //Considera todos os tipos de saldo 
	MV_PAR06 := aParametros[6]  //Tipo de saldo especifico
	
	__lBlind := .T.
		
	lRet := PCOA300Sld()
	
Else

	If !__lBlind 
		tNewProcess():New( cFunction, cTitle, bProcess, cDescription, cPerg )
		//A300ChkCub(MV_PAR01, MV_PAR02, .T.)
	Else
	 	Eval(bProcess)
	EndIf
	
EndIf

Return(lRet)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥ PCOA300Sld ∫ Autor ≥                  ∫ Data ≥  06/07/16   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Rotina de reprocessamento de cubos                         ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ PCOA300 - Planejamento e Controle Orcamentario             ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
	
Static Function PCOA300Sld(oSelf)
Local aConfig	:= {,,,}
Local dDataIni	
Local dDataFim	
Local nX 	:=	0
Local nMin	:=	0
Local nMax  := 	0
Local lRet	:=	.T.
Local lRet1	:=	.T.
Local cQuery:= 	""
Local cAliasQry:= 	""
Local dDataAnt	
Local nDias              
Local cCampos
Local aNivel:= {}
Local aNivelAux := {}
Local iX      := 0
Local cExec   := ""
Local nZ:=0
Local aTmpDim :={}
Local cTpSld  := ""
//**********************************************
// Controle de atualizaÁ„o de saldo por nivel  *
//**********************************************

//carrega as variaveis static
cTipoDB	:= Alltrim(Upper(TCGetDB()))
lQuery 	:= ( TCSrvType() # "AS/400" )
cSrvType := Alltrim(Upper(TCSrvType()))
	
lOracle		:= "ORACLE"   $ cTipoDB
lPostgres 	:= "POSTGRES" $ cTipoDB
lDB2		:= "DB2|SYBASE" $ cTipoDB
lInformix 	:= "INFORMIX"   $ cTipoDB

If lPostgres .OR. lInformix  //postgres e informix faz pelo padrao sem procedure dinamica
	lQuery 	:= .F.	
EndIf
If mv_par05 == 2
	cTpSld := "( '"+AllTrim(mv_par06)+"' )"
EndIf

aConfig[1] := MV_PAR01
aConfig[2] := MV_PAR02
aConfig[3] := MV_PAR03
aConfig[4] := MV_PAR04

dDataIni := aConfig[3]
dDataFim := aConfig[4]


If !__lBlind 
	oSelf:Savelog(STR0012)	//"Processamento iniciado."
EndIf	

dbSelectArea("AL1")
dbSetOrder(1)

DbSelectArea("AKT")           
dbSetOrder(1)

If !lQuery

	dbSelectArea("AL1")
	dbSeek(xFilial("AL1")+aConfig[1],.T.)
	While AL1->( ! Eof() .And. AL1_FILIAL+AL1_CONFIG <= xFilial("AL1")+aConfig[2] )
		//vERIFICA SE A ESTRUTURA DO CUBO EXISTE	
	   dbSelectArea("AKW") 
	   dbSetOrder(1)
	   If !(dbSeek(xFilial("AKW")+AL1->AL1_CONFIG))
	   	dbSelectArea("AL1")
	   	dbSkip()
	   	Loop
	   EndIf 
		//Bloquear o cubo com RecLock() para ninguem atualiza-lo durante o processamento
		If AL1->(dbRLock())
			//AL1_STATUS := "2"   // Em reprocessamento
			PcoCubeStatus("2")
	    Else
	    	AL1->(dbSkip())
	    	Loop
	    EndIf

		//se conseguir lockar o cubo entao reprocessa
		//saldos diarios para reprocessamento sempre considera mes cheio
		dbSelectArea("AKT")
		If !__lBlind
			oSelf:SetRegua1(RecCount())
		EndIf	
		dbSeek(xFilial("AKT")+AL1->AL1_CONFIG)
		While AKT->( ! Eof() .And. AKT->AKT_FILIAL+AKT->AKT_CONFIG == xFilial("AKT")+AL1->AL1_CONFIG )
			
			If !__lBlind
				oSelf:IncRegua1()
		    EndIf
		
			If AKT->AKT_DATA>=dDataIni.And. AKT->AKT_DATA<=dDataFim 
				Reclock("AKT",.F.,.T.)
				dbDelete()
				MsUnlock()
			EndIf
				
			dbSkip()
				
		EndDo // AKT

		//apos exclusao dos saldos mensais e diarios procede o reprocessamento baseado nos movimenstos (AKD)
		If !__lBlind
			oSelf:SetRegua1(dDataFim-dDataIni)
		EndIf
		
		dDataAnt	:= dDataIni
		dbSelectArea("AKD")
		dbSetOrder(9)
		dbSeek(xFilial()+DTOS(dDataIni),.T.)
		
		While AKD->( ! Eof() .And. AKD_FILIAL+DTOS(AKD_DATA) <= xFilial()+DTOS(dDataFim) )

			If AKD->AKD_DATA <> dDataAnt
				For nX := 1 To AKD->AKD_DATA-dDataAnt 
					If !__lBlind
						oSelf:IncRegua1(DtoC(dDataAnt+nX))
					EndIf	
				Next                      
				dDataAnt	:=	AKD->AKD_DATA
			Endif
				
			If AKD->AKD_STATUS == "1"   //STATUS = 1 deve atualizar o saldo do cubo gerencial
			
				If AKD->AKD_TIPO=="1"
					PcoAtuSld( "C" /*cTipoMov*/, "AKD"/*cAliasAKD*/, {AKD->AKD_VALOR1,AKD->AKD_VALOR2,AKD->AKD_VALOR3,AKD->AKD_VALOR4,AKD->AKD_VALOR5}, AKD->AKD_DATA, AL1->AL1_CONFIG/*cConfigDe*/, AL1->AL1_CONFIG/*cConfigAte*/, .T./*lReproc*/, .T./*lForcaAtu*/ )
				Else
					PcoAtuSld( "D" /*cTipoMov*/, "AKD"/*cAliasAKD*/, {AKD->AKD_VALOR1,AKD->AKD_VALOR2,AKD->AKD_VALOR3,AKD->AKD_VALOR4,AKD->AKD_VALOR5}, AKD->AKD_DATA, AL1->AL1_CONFIG/*cConfigDe*/, AL1->AL1_CONFIG/*cConfigAte*/, .T./*lReproc*/, .T./*lForcaAtu*/ )
				EndIf
					
			EndIf
				
			dbSelectArea("AKD")
			dbSkip()
				
		EndDo //AKD

		dbSelectArea("AL1")
		//libera o lock do registro referente ao cubo gerencial
		//AL1_STATUS := "1"   // Livre para reprocessamento
		PcoCubeStatus("1")
		AL1->(dbRUnlock())
		
		dbSkip()
	EndDo  //AL1

Else

    //se a procedure XFILIAL nao existir no banco e nem os campos
    //AKT_NIV01.......NIV06/AKT_TPSALD nao executa por procedure
    //rodando o reprocessamento padrao
	If lProcA300 == Nil
		//desvio para INFORMIX nao executar procedure dinamica
		//reprocessar pela rotina do padrao
		lProcA300 := If(Alltrim(Upper(TcGetDb())) = "INFORMIX",.T., .T.)
		If lProcA300
			If AKT->(FieldPos("AKT_TPSALD")) == 0 .OR. ;
				AKT->(FieldPos("AKT_NIV01")) == 0 .OR. ;
				AKT->(FieldPos("AKT_NIV02")) == 0 .OR. ;
				AKT->(FieldPos("AKT_NIV03")) == 0 .OR. ;
				AKT->(FieldPos("AKT_NIV04")) == 0 .OR. ;
				AKT->(FieldPos("AKT_NIV05")) == 0 .OR. ;
				AKT->(FieldPos("AKT_NIV06")) == 0
				lProcA300 := .F.
			EndIf
		EndIf
	EndIf
	
    If lProcA300
		aTmpDim := {}
		dbSelectArea("AL1")
		dbSeek(xFilial("AL1")+aConfig[1],.T.)	
		While AL1->( ! Eof() .And. AL1_FILIAL+AL1_CONFIG <= xFilial("AL1")+aConfig[2] )
			aNivel := PcoGeraSup(AL1->AL1_CONFIG,aTmpDim)
			AADD(aNivelAux, {AL1->AL1_CONFIG, aClone(aNivel)})
		   	dbSelectArea("AL1")
	  		dbSkip()
		EndDo
	EndIf

	//quando executado por query
	dbSelectArea("AL1")
	dbSeek(xFilial("AL1")+aConfig[1],.T.)
	While AL1->( ! Eof() .And. AL1_FILIAL+AL1_CONFIG <= xFilial("AL1")+aConfig[2] )
		//vERIFICA SE A ESTRUTURA DO CUBO EXISTE	
	   dbSelectArea("AKW") 
	   dbSetOrder(1)
	   If !(dbSeek(xFilial("AKW")+AL1->AL1_CONFIG))
			dbSelectArea("AL1")
			dbSkip()
			Loop
	   EndIf 

		//Bloquear o cubo com RecLock() para ninguem atualiza-lo durante o processamento
      If AL1->(dbRLock())
			//AL1->AL1_STATUS := "2" // em reprocessamento
	      	PcoCubeStatus("2")			
	   Else
	    	//se nao conseguir lockar
	    	AL1->(dbSkip())
	    	Loop
	   EndIf

      If lProcA300 
	 	
			If !__lBlind
				oSelf:SetRegua1(2)
				oSelf:IncRegua1(STR0010+AL1->AL1_CONFIG)//'Selecionando lancamentos para processar o cubo ']
				SysRefresh()
			EndIf
			
			aNivel  := aClone(aNivelAux[Ascan(aNivelAux,{|x|x[1]==AL1->AL1_CONFIG}),2])
			
			P300CallProc(aNivel,dDataIni, dDataFim, cTpSld)
			
			If !__lBlind
				If !lRet
					lProcA300:= .F.
				Else
					oSelf:IncRegua1("..."+AL1->AL1_CONFIG)//'Selecionando lancamentos para processar o cubo ']
					SysRefresh()
				EndIf
			EndIf
		EndIf                                              
				
		// Executa pelo padrao caso ocorr alguma falaha na criacao ou execucao das procedures
		If !lProcA300
			//se conseguir lockar o cubo entao reprocessa
			lRet := .T.
			nMin	:=	0
			nMax    := 	0
			cQuery	:=	" SELECT Min(R_E_C_N_O_) MINRECNO, MAX(R_E_C_N_O_) MAXRECNO "
			cQuery	+=	" FROM "+RetSqlName('AKT') 
			cQuery	+=	" WHERE AKT_FILIAL = '"+xFilial('AKT')+"' AND "
			cQuery	+=	" AKT_CONFIG = '" + AL1->AL1_CONFIG +"' AND "
			cQuery	+=	" AKT_DATA BETWEEN '"+DToS(dDataIni)+"' AND '"+DToS(dDataFim)+"' "
			cQuery	:=	ChangeQuery(cQuery)				
			dbUseArea( .T., "TopConn", TCGenQry(,,cQuery),"QRYTRB", .F., .F. )
			If !Eof()
				nMin	:=	QRYTRB->MINRECNO
				nMax	:=	QRYTRB->MAXRECNO
			Endif
		    dbSelectArea("QRYTRB")
			dbCloseArea()
		    If !__lBlind
				oSelf:SetRegua1(Round((nMax-nMin)/10000,0))
			EndIf
			
			
			//faz update ou delete diretamente no banco em lotes de 10000 registros
			//a partir do menor recno ate o maior recno (nMin - nMax)  [[ SALDOS DIARIOS  ]]
			For nX := nMin To nMax	STEP 10000
			
				If !__lBlind
					oSelf:IncRegua1(STR0005)//'Apagando saldos diarios...'
			    EndIf
			    
				If __lFKInUse                 
					cQuery  := " UPDATE " + RetSqlName('AKT')
					cQuery  += " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ "
				Else
					cQuery	:= " DELETE FROM  "+RetSqlName('AKT') 
				EndIf	                                         
			
				cQuery += " WHERE AKT_FILIAL='" + xFilial('AKT') + "' AND "
				cQuery += " AKT_CONFIG = '" + AL1->AL1_CONFIG +"' AND "
				cQuery += " AKT_DATA BETWEEN '" + DToS(dDataIni) + "' AND '" + DToS(dDataFim)+"' "
				cQuery += " AND R_E_C_N_O_ BETWEEN " + Str(nX)+ ' AND ' + Str(nX+10000)
			
				If TcSqlExec(cQuery) <> 0
			
					UserException(STR0007; // "Erro na delecao de movimentos " 
							+ CRLF + STR0009+ CRLF + TCSqlError() )//"Processo cancelado..."
					lRet	:=	.F.
					Exit 
			
				Else
			
					//Forcar o Commit para DB2 para nao estourar o LOG (mesmo sem ter iniciado transacao)
					If Upper(TcGetDb()) == 'DB2' .Or. Upper(TcGetDb()) == 'SYBASE'
			        	TcSqlExec('commit')
					Endif
					
				Endif
				
			Next
	
			//se apagou saldos diarios (AKT) procede o reprocessamento
			If lRet
	
				If !__lBlind
					oSelf:SetRegua1(2)
					oSelf:IncRegua1(STR0010+AL1->AL1_CONFIG)//'Selecionando lancamentos para processar o cubo '
				EndIf
				
				//Trazer o AKD agrupado por daa e pela chave do cubo
				cCampos := StrTran(AL1->AL1_CHAVER, "+", ",")  //mudar de sinal (+) para virgula (,)
				cCampos	:=	StrTran(cCampos, "AKD->" , "") // tira o alias AKD-> q esta fixo
				cCampos	:=	Alltrim(cCampos) 
				
				cQuery	:=	" SELECT AKD_TIPO, AKD_DATA, "
				cQuery	+=	cCampos+" , "    //campos do cubo gerencial
				cQuery	+=	" SUM(AKD_VALOR1) AKD_VALOR1, "
				cQuery	+=	" SUM(AKD_VALOR2) AKD_VALOR2, "
				cQuery	+=	" SUM(AKD_VALOR3) AKD_VALOR3, "
				cQuery	+=	" SUM(AKD_VALOR4) AKD_VALOR4, "
				cQuery	+=	" SUM(AKD_VALOR5) AKD_VALOR5 "
				cQuery	+=	" FROM " + RetSqlName('AKD') + " AKD "
				cQuery	+=	" WHERE AKD_FILIAL = '" + xFilial('AKD') + "' "
				cQuery	+=	" AND AKD_DATA BETWEEN '"+DToS(dDataIni)+"' AND '"+DToS(dDataFim)+"' "
				cQuery	+=	" AND AKD_STATUS='1' "
				cQuery	+=	" AND AKD_TIPO IN ( '1', '2') "
				cQuery	+=	" AND D_E_L_E_T_<>'*'"
				cQuery	+=	" GROUP BY AKD_TIPO,AKD_DATA, "+AllTrim(cCampos)
				cQuery	+=	" ORDER BY AKD_DATA "
				cQuery	:=	ChangeQuery(cQuery)	
				cAliasQry	:=	CriaTrab(,.F.)
				dbUseArea( .T., "TopConn", TCGenQry(,,cQuery),cAliasQry, .F., .F. )
		
				TcSetField(cAliasQry,'AKD_DATA','D',8,0)
				TcSetField(cAliasQry,'AKD_VALOR1','N', TamSx3('AKD_VALOR1')[1],TamSx3('AKD_VALOR1')[2])
				TcSetField(cAliasQry,'AKD_VALOR2','N', TamSx3('AKD_VALOR2')[1],TamSx3('AKD_VALOR2')[2])
				TcSetField(cAliasQry,'AKD_VALOR3','N', TamSx3('AKD_VALOR3')[1],TamSx3('AKD_VALOR3')[2])
				TcSetField(cAliasQry,'AKD_VALOR4','N', TamSx3('AKD_VALOR4')[1],TamSx3('AKD_VALOR4')[2])
				TcSetField(cAliasQry,'AKD_VALOR5','N', TamSx3('AKD_VALOR5')[1],TamSx3('AKD_VALOR5')[2])
				dDataAnt	:=	dDataIni
	
				If !__lBlind
					oSelf:SetRegua2(dDataFim-dDataIni)
					oSelf:IncRegua2(STR0011+AL1->AL1_CONFIG+ " - "+Dtoc((cAliasQry)->AKD_DATA))//'Processando cubo '
				EndIf	
	
				//Processar o AKD Agrupado da query	
				While (cAliasQry)->( ! Eof() )
				
					If (cAliasQry)->AKD_DATA<>dDataAnt
						nDias	:=	(cAliasQry)->AKD_DATA-dDataAnt
						For nX:= 1 To nDias-1
							If !__lBlind
								oSelf:IncRegua2()
							EndIf	
						Next
						If !__lBlind
							oSelf:IncRegua2(STR0011+AL1->AL1_CONFIG+ " - "+Dtoc((cAliasQry)->AKD_DATA))//'Processando cubo '					
						EndIf	
						dDataAnt	:=	(cAliasQry)->AKD_DATA
					Endif
	
					If (cAliasQry)->AKD_TIPO=="1"
						PcoAtuSld( "C" /*cTipoMov*/, (cAliasQry)/*cAliasAKD*/, {(cAliasQry)->AKD_VALOR1,(cAliasQry)->AKD_VALOR2,(cAliasQry)->AKD_VALOR3,(cAliasQry)->AKD_VALOR4,(cAliasQry)->AKD_VALOR5}, (cAliasQry)->AKD_DATA, AL1->AL1_CONFIG/*cConfigDe*/, AL1->AL1_CONFIG/*cConfigAte*/, .T./*lReproc*/, .T./*lForcaAtu*/ )
					Else
						PcoAtuSld( "D" /*cTipoMov*/, (cAliasQry)/*cAliasAKD*/, {(cAliasQry)->AKD_VALOR1,(cAliasQry)->AKD_VALOR2,(cAliasQry)->AKD_VALOR3,(cAliasQry)->AKD_VALOR4,(cAliasQry)->AKD_VALOR5}, (cAliasQry)->AKD_DATA, AL1->AL1_CONFIG/*cConfigDe*/, AL1->AL1_CONFIG/*cConfigAte*/, .T./*lReproc*/, .T./*lForcaAtu*/ )
					EndIf
	
					(cAliasQry)->(DbSkip())
					
				EndDo // cAliasQry
				
				DbSelectArea(cAliasQry)
				DbCloseArea()
				
			EndIf //se apagou saldos diarios (AKT) procede o reprocessamento
	
		EndIf // If lProcA300 

		dbSelectArea("AL1")
		//libera o lock do registro referente ao cubo gerencial
		//AL1_STATUS := "1"   // Livre para reprocessamento
		PcoCubeStatus("1")		
		AL1->(dbRUnlock())
		
		dbSkip()
			
	Enddo
	If lProcA300 
		For nZ := 1 to Len(aNivelAux)
			aNivel := aClone(aNivelAux[nZ,2])
			For iX := 1 to Len(aNivel)     // tabelas com as superiores
				If TcCanOpen(aNivel[iX][2])
					lRet1 := TcDelFile(aNivel[iX][2])
					If !lRet1
						MsgAlert(STR0014+aNivel[iX][2]+STR0015)  //"Erro na exclusao da Tabela: "##". Excluir manualmente"
					Endif
				EndIf
		  	Next iX
			For iX := 1 to Len(aNivel)
				If aNivel[iX,3] <> Nil .and. TCSPExist(aNivel[iX,3])
					cExec := "Drop procedure "+aNivel[iX,3]
					cRet := TcSqlExec(cExec)
					If cRet <> 0
						MsgAlert(STR0016+aNivel[iX,3]+STR0017)  //"Erro na exclusao da Procedure: "###". Excluir manualmente no banco."
					Endif
				EndIf
			Next iX
		Next nZ
	EndIf	

Endif  // ! lQuery

If !__lBlind	
	oSelf:Savelog(STR0013) 	//"Processamento encerrado."
EndIf	

Return(lRet)

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥A300LastDay≥ Autor ≥ Alice Yaeko Yamamoto  ≥ Data ≥06.06.08  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Cria  procedure que retorna o ultimo dia do mes              ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥   DATA   ≥ Programador   ≥Manutencao Efetuada                          ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function A300LastDay( cArq )
Local aSaveArea := GetArea()
Local cQuery := ""
Local cProc  := cArq+"_"+cEmpAnt
Local lRet   := .T.

cQuery :="create procedure "+cProc+CRLF
cQuery+="   ( "+CRLF
cQuery+="   @IN_DATA  Char( 08 ),"+CRLF
cQuery+="   @OUT_DATA Char( 08 ) OutPut"+CRLF
cQuery+="   )"+CRLF
cQuery+="as"+CRLF

cQuery+="Declare @cData    VarChar( 08 )"+CRLF
cQuery+="Declare @iAno     Float"+CRLF
cQuery+="Declare @iResto   Float"+CRLF
cQuery+="Declare @iPos     Integer"+CRLF
cQuery+="Declare @cResto   VarChar( 10 )"+CRLF

cQuery+="begin"+CRLF
cQuery+="   Select @OUT_DATA = ' '"+CRLF
cQuery+="   Select @cData  = Substring( @IN_DATA, 5, 2 )"+CRLF//  -- MES
cQuery+="   select @iAno   = 0"+CRLF
cQuery+="   select @iResto = 0"+CRLF
cQuery+="   Select @iPos   = 0"+CRLF
cQuery+="   select @cResto = ''"+CRLF
   
   /* --------------------------------------------------------------
      Ultimo dia do periodo
      -------------------------------------------------------------- */
cQuery+="   If @cData IN ( '01', '03', '05', '07', '08','10','12' ) begin"+CRLF
cQuery+="      select @cData = Substring( @IN_DATA, 1, 6 )||'31'"+CRLF
cQuery+="   end else begin"+CRLF
cQuery+="      If @cData = '02' begin"+CRLF
cQuery+="         Select @iAno = Convert( Float, Substring(@IN_DATA, 1,4) )"+CRLF
cQuery+="         Select @iResto = @iAno/4"+CRLF
cQuery+="         Select @cResto = Convert( varchar(10), @iResto )"+CRLF
         /* --------------------------------------------------------------
            nao existe '.' no @cResto , o nro È inteiro, divisivel por 4
            O ano deve ser m˙ltiplo de 100, ou seja, divisÌvel por 400
            -------------------------------------------------------------- */
cQuery+="         Select @iPos   = Charindex( '.', @cResto )"+CRLF
cQuery+="         If @iPos = 0 begin"+CRLF
cQuery+="            select @cData = Substring( @IN_DATA, 1, 6 )||'29'"+CRLF
cQuery+="            If @iAno in ( 2100, 2200, 2300, 2500 ) begin"+CRLF  // -- ANOS NAO DIVISÕVEIS POR 400
cQuery+="               select @cData = Substring( @IN_DATA, 1, 6 )||'28'"+CRLF
cQuery+="            End"+CRLF
cQuery+="         end else begin"+CRLF
cQuery+="            select @cData = Substring( @IN_DATA, 1, 6 )||'28'"+CRLF
cQuery+="         end"+CRLF
cQuery+="      end else begin"+CRLF
cQuery+="         select @cData = Substring( @IN_DATA, 1, 6 )||'30'"+CRLF
cQuery+="      End"+CRLF
cQuery+="   End"+CRLF
cQuery+="   Select @OUT_DATA = @cData"+CRLF
cQuery+="End"+CRLF

cQuery := MsParse(cQuery,If(Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB())))
If Upper(TcSrvType())= "ISERIES" .and. !Empty( cQuery )
	cQuery := pVldDb2400( cQuery )
EndIf

If Empty( cQuery )
	MsgAlert(MsParseError(),STR0018+cProc)  //'A query nao passou pelo Parse '
	lRet := .F.
Else
	If !TCSPExist( cProc )
		cRet := TcSqlExec(cQuery)
		If cRet <> 0
			If !__lBlind
				MsgAlert(STR0019+cProc)  //'Erro na criacao da procedure '
				lRet:= .F.
			EndIf
		EndIf
	EndIf
EndIf
RestArea(aSaveArea)
Return (lRet)

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥PCOA300B   ≥ Autor ≥ Alice Yaeko Yamamoto  ≥ Data ≥13.06.08  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Cria as procedures de atualizacao do AKT                     ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥PCOA300B( cCubo,cArq )                                       ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥  Uso     ≥ SigaPCO                                                     ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ParÑmetros≥ ExpC1 = cCubo - Codigo do Cubo a ser atualizado             ≥±±
±±≥          ≥ ExpC2 = cArq  - Nome da procedure q sera criada no banco    ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/         
Function PCOA300B(cCubo, cArq, aProc )
Local aSaveArea  := GetArea()
Local cQuery     := ""
Local cQueryAux  := ""
Local cTipo      := ""
Local nPos       := 0
Local aCampos    := AKT->(DbStruct())
Local nPTratRec  := 0
Local nPosFim    := 0
Local nPosFim2   := 0 
Local nPos3      := 0
Local cProc      := cArq+"_"+cEmpAnt
Local lRet       := .T.
Local cTabela    := RetSqlName("AKT")
Local nRet       := 0
Local nCnt01     := 0

cQuery :="create procedure "+cProc+CRLF
cQuery +="( "+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "AKT_FILIAL" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery +="	@IN_FILIALCOR	"+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "AKT_CONFIG" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery +="	@IN_CONFIG    	"+cTipo+CRLF
cQuery +="	@IN_DATA    	Char(08),"+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "AKT_CHAVE" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery +="	@IN_CHAVE      "+cTipo+CRLF
cQuery +="	@IN_VALORD1   	float,"+CRLF
cQuery +="	@IN_VALORD2  	float,"+CRLF
cQuery +="	@IN_VALORD3  	float,"+CRLF
cQuery +="	@IN_VALORD4  	float,"+CRLF
cQuery +="	@IN_VALORD5  	float,"+CRLF
cQuery +="	@IN_VALORC1   	float,"+CRLF
cQuery +="	@IN_VALORC2  	float,"+CRLF
cQuery +="	@IN_VALORC3  	float,"+CRLF
cQuery +="	@IN_VALORC4  	float,"+CRLF
cQuery +="	@IN_VALORC5  	float,"+CRLF
cQuery +="	@IN_ANALIT  	char(1),"+CRLF
DbSelectArea("AKW")
DbSetOrder(1)
DbSeek( xFilial("AKW")+cCubo)
While AKW_FILIAL+AKW->AKW_COD = xFilial("AKW")+cCubo .and. !Eof()
	cQueryAux :=cQueryAux+"   @IN_NIV"+Trim(AKW->AKW_NIVEL)+"      Char( "+StrZero(AKW->AKW_TAMANH,02)+" ),"+CRLF  // CONTA
	dbSkip()
EndDo  
/* Tirar a virgula do final*/
cQueryAux := SubString(cQueryAux,1, (Len(cQueryAux)-3))
cQuery +=cQueryAux+CRLF
cQuery +=")"+CRLF
cQuery +="as"+CRLF
/* ---------------------------------------------------------------------------------------------------------------------
    Vers„o          - <v> Protheus 8.11 </v>
    Assinatura      - <a> 001 </a>
    Fonte Microsiga - <s> PCOA300 </s>
    Descricao       - <d> Atualiza os saldos do AKT  </d>
    Funcao do Siga  -     PcoWriteSld()
    -----------------------------------------------------------------------------------------------------------------
    Entrada         -  <ri> @IN_FILIALCOR	- Filial corrente 
       				   		@IN_CONFIG    	- Codigo do cubo
         						@IN_DATA    	- Ultimo dia do mes da data do movimento
         						@IN_CHAVE  		- Chave do cubo
         						@IN_VALOR1   	- Valor na moeda 1
         						@IN_VALOR2   	- Valor na moeda 2
         						@IN_VALOR3   	- Valor na moeda 3
         						@IN_VALOR4   	- Valor na moeda 4
         						@IN_VALOR5   	- Valor na moeda 5	</ri>
    -----------------------------------------------------------------------------------------------------------------
    Saida       :  <ro> Sem saida </ro>
    -----------------------------------------------------------------------------------------------------------------
    Vers„o      :  <v> Advanced Protheus </v>
    -----------------------------------------------------------------------------------------------------------------
    ObservaÁıes :  <o>   </o>
    -----------------------------------------------------------------------------------------------------------------
    Responsavel :   <r> Alice Yaeko Yamamoto  </r>
    -----------------------------------------------------------------------------------------------------------------
    Data        :  <dt> 29/04/2008 </dt>

    Estrutura de chamadas
    ========= == ========
   --------------------------------------------------------------------------------------------------------------------- */
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "AKT_FILIAL" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery +="Declare @cFil_AKT   "+cTipo+CRLF
cQuery +="Declare @cAux       Char(03)"+CRLF
cQuery +="Declare @iRecnoAKT  Integer"+CRLF
cQuery +="Declare @nValorD1   Float"+CRLF
cQuery +="Declare @nValorD2   Float"+CRLF
cQuery +="Declare @nValorD3   Float"+CRLF
cQuery +="Declare @nValorD4   Float"+CRLF
cQuery +="Declare @nValorD5   Float"+CRLF
cQuery +="Declare @nValorC1   Float"+CRLF
cQuery +="Declare @nValorC2   Float"+CRLF
cQuery +="Declare @nValorC3   Float"+CRLF
cQuery +="Declare @nValorC4   Float"+CRLF
cQuery +="Declare @nValorC5   Float"+CRLF
cQuery +=""+CRLF
// Insere tratamento para xfilial dentro do codigo 
cQuery +="begin"+CRLF
   /* --------------------------------------------------------------
      Recuperando Filiais
      -------------------------------------------------------------- */
cQuery +="   select @cAux = 'AKT'"+CRLF
cQuery +="   EXEC "+aProc[2]+" @cAux, @IN_FILIALCOR, @cFil_AKT OutPut "+CRLF
   
cQuery +="   select @nValorD1 = @IN_VALORD1"+CRLF
cQuery +="   select @nValorD2 = @IN_VALORD2"+CRLF
cQuery +="   select @nValorD3 = @IN_VALORD3"+CRLF
cQuery +="   select @nValorD4 = @IN_VALORD4"+CRLF
cQuery +="   select @nValorD5 = @IN_VALORD5"+CRLF
cQuery +="   select @nValorC1 = @IN_VALORC1"+CRLF
cQuery +="   select @nValorC2 = @IN_VALORC2"+CRLF
cQuery +="   select @nValorC3 = @IN_VALORC3"+CRLF
cQuery +="   select @nValorC4 = @IN_VALORC4"+CRLF
cQuery +="   select @nValorC5 = @IN_VALORC5"+CRLF
cQuery +="   select @iRecnoAKT = null"+CRLF
   /* --------------------------------------------------------------
      Atualizacao de Credito do dia - AKT
      -------------------------------------------------------------- */
cQuery +="   Select @iRecnoAKT = R_E_C_N_O_"+CRLF
cQuery +="     From "+cTabela+CRLF
cQuery +="    where AKT_FILIAL = @cFil_AKT"+CRLF
cQuery +="		and AKT_CONFIG = @IN_CONFIG"+CRLF
cQuery +="		and AKT_CHAVE  = @IN_CHAVE"+CRLF
cQuery +="		and AKT_DATA   = @IN_DATA"+CRLF
cQuery +="      and D_E_L_E_T_ = ' '"+CRLF
   
cQuery +="   If @iRecnoAKT Is Null begin"+CRLF
cQuery +="      select @iRecnoAKT = IsNull(Max(R_E_C_N_O_), 0) FROM "+RetSqlName("AKT") + CRLF
cQuery +="      select @iRecnoAKT = @iRecnoAKT + 1"+CRLF
cQuery +="      ##TRATARECNO @iRecnoAKT\"+CRLF    
cQuery +="      begin tran"+CRLF
cQuery +="      insert into "+cTabela+" (	AKT_FILIAL, AKT_CHAVE,  AKT_DATA,   AKT_CONFIG, AKT_MVCRD1, AKT_MVCRD2, AKT_MVCRD3, AKT_MVCRD4, AKT_MVCRD5,"+CRLF
DbSelectArea("AKW")
DbSetOrder(1)                                                               
DbSeek( xFilial("AKW")+cCubo)
cQueryAux := ""
While AKW_FILIAL+AKW->AKW_COD = xFilial("AKW")+cCubo .and. !Eof()
	If Trim(Substring(AKW->AKW_CHAVER, 9, Len(AKW->AKW_CHAVER))) = "_TPSALD"
		cQueryAux :=cQueryAux+"AKT_TPSALD, "
	Else
		cQueryAux :=cQueryAux+"AKT_NIV"+Trim(AKW->AKW_NIVEL)+","+"  "
	EndIf
	dbSkip()
EndDo
//AKT_NIV01,  AKT_NIV02,  AKT_TPSALD, R_E_C_N_O_ )"+CRLF
cQuery +="                           AKT_MVDEB1, AKT_MVDEB2, AKT_MVDEB3, AKT_MVDEB4, AKT_MVDEB5, "+cQueryAux/*AKT_NIV01,  AKT_NIV02,  AKT_TPSALD, */
cQuery +=" AKT_ANALIT, " 
cQuery +=" R_E_C_N_O_ )"+CRLF
cQuery +="                   values( @cFil_AKT,  @IN_CHAVE,  @IN_DATA,   @IN_CONFIG, @nValorC1,  @nValorC2,  @nValorC3,  @nValorC4,  @nValorC5,"+CRLF
cQuery +="                           @nValorD1,  @nValorD2,  @nValorD3,  @nValorD4,  @nValorD5,  "
DbSelectArea("AKW")
DbSetOrder(1)                                                               
DbSeek( xFilial("AKW")+cCubo)
cQueryAux := ""
While AKW_FILIAL+AKW->AKW_COD = xFilial("AKW")+cCubo .and. !Eof()
	cQueryAux :=cQueryAux+"@IN_NIV"+Trim(AKW->AKW_NIVEL)+","+"  "
	dbSkip()
EndDo
cQueryAux += " @IN_ANALIT, "
cQuery +=cQueryAux+"@iRecnoAKT )"+CRLF
cQuery +="      commit tran"+CRLF
cQuery +=""+CRLF
cQuery +="      ##FIMTRATARECNO"+CRLF
cQuery +="   end else begin"+CRLF
cQuery +="      begin tran"+CRLF
cQuery +="      Update "+cTabela+CRLF
cQuery +="         Set AKT_MVCRD1 = AKT_MVCRD1 + @nValorC1, AKT_MVCRD2 = AKT_MVCRD2 + @nValorC2, AKT_MVCRD3 = AKT_MVCRD3 + @nValorC3,"+CRLF
cQuery +="             AKT_MVCRD4 = AKT_MVCRD4 + @nValorC4, AKT_MVCRD5 = AKT_MVCRD5 + @nValorC5, AKT_MVDEB1 = AKT_MVDEB1 + @nValorD1,"+CRLF
cQuery +="             AKT_MVDEB2 = AKT_MVDEB2 + @nValorD2, AKT_MVDEB3 = AKT_MVDEB3 + @nValorD3, AKT_MVDEB4 = AKT_MVDEB4 + @nValorD4,"+CRLF
cQuery +="             AKT_MVDEB5 = AKT_MVDEB5 + @nValorD5"+CRLF
cQuery +="       Where R_E_C_N_O_ = @iRecnoAKT"+CRLF
cQuery +="      commit tran"+CRLF
cQuery +="   End"+CRLF

cQuery +="end"+CRLF

cQuery := CtbAjustaP(.T., cQuery, @nPTratRec)
cQuery := MsParse(cQuery,If(Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB())))
cQuery := CtbAjustaP(.F., cQuery, nPTratRec)

If !TCSPExist( cProc )
	nRet := TcSqlExec(cQuery)
	If nRet <> 0 
		If !__lBlind
			MsgAlert(STR0020+cProc)  //'Erro na criacao da procedure de atualizacao do AKT'
			lRet:= .F.
		EndIf
	EndIf
EndIf

RestArea(aSaveArea)
Return(lRet)
/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥PCOA300F   ≥ Autor ≥ Alice Yaeko Yamamoto  ≥ Data ≥06.06.08  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Cria  procedure Exclusao de AKT do periodo                   ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ PCOOA300F(cCubo,cArq )                                      ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥  Uso     ≥ SigaPCO                                                     ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ParÑmetros≥ ExpC1 = cCubo   - Codigo do Cubo a ser atualizado           ≥±±
±±≥          ≥ ExpC2 = cArq    - Nome da procedure q sera criada no banco  ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function PCOA300F(cCubo, cArq, aProc, cTpSld )
Local aSaveArea:=GetArea()
Local cQuery   := ""
Local cQueryAux:= ""
Local cTipo    := ""
Local nPos     := 0
Local aCampos  := AKT->(DbStruct())
Local cProc    := cArq+"_"+cEmpAnt 
Local lRet     := .T.
Local nPosAux   := 0
Local cNumField := ""
Local nPosIni   := 0
Local nPosFim   := 0
Local cCampo    := ''
Local lMantem   :=.T.
Local nPos2     := 0
Local cTabela   :=""
Local cChaveUnica:=""
Local nPTratRec := 0
Local cFunName  := Alltrim(FunName())

cQuery:="Create Procedure "+cProc+"("+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "AKT_FILIAL" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery+="   @IN_FILIAL  "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "AKT_CONFIG" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery+="	@IN_CONFIG    	"+cTipo+CRLF
cQuery+="   @IN_DATAI   Char( 08 ), "+CRLF
cQuery+="   @IN_DATAF   Char( 08 ),"+CRLF
cQuery+="   @IN_FK      Char( 01 )"+CRLF
cQuery+=")"+CRLF
cQuery+="as"+CRLF
/* ---------------------------------------------------------------------------------------------------------------------
   Vers„o          - <v> Protheus 9.12 </v>
   Assinatura      - <a> 001 </a>
   Fonte Microsiga - <s> PCOA300.PRX </s>
   Descricao       - <d> Exclusao de AKT do periodo </d>
   Funcao do Siga  -     
   -----------------------------------------------------------------------------------------------------------------
   Entrada         -  <ri> @IN_FILIALR	- Filial corrente 
       				   		@IN_CONFIG  - Codigo do cubo
         						@IN_DATAI   - Periodo Inicial
         						@IN_DATAF   - Periodo Final
         						@IN_FK      - '1' se integridade estiver ligada	</ri>
   -----------------------------------------------------------------------------------------------------------------
   Saida          -  <ro> @OUT_RESULT    -  </ro>
   -----------------------------------------------------------------------------------------------------------------
   Responsavel    -   <r> Alice Yaeko Yamamoto  </r>
   -----------------------------------------------------------------------------------------------------------------
   Data           -  <dt> 020/06/2008 </dt>
   
   1 - excluir os movimentos di·rios do periodo do AKT
   --------------------------------------------------------------------------------------------------------------------- */
cQuery+="Declare @cAux        Char( 03 )"+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "AKT_FILIAL" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="Declare @cFil_AKT    "+cTipo+CRLF
cQuery+="Declare @iMinRecno   Integer"+CRLF
cQuery+="Declare @iMaxRecno   Integer"+CRLF
cQuery+="Declare @iNroRegs    Integer"+CRLF

cQuery+="Begin"+CRLF
cQuery+="   select @iMinRecno   = 0"+CRLF
cQuery+="   select @iMaxRecno   = 0"+CRLF
If cFunName = 'PCOA300'  
	cQuery+="   select @iNroRegs    = 10000"+CRLF
else
	cQuery+="   select @iNroRegs    = 1"+CRLF
EndIf
cQuery+="   select @cFil_AKT   = '  '"+CRLF
   /* --------------------------------------------------------------
      Recuperando Filiais
      -------------------------------------------------------------- */
cQuery+="   select @cAux = 'AKT'"+CRLF
cQuery+="   EXEC "+aProc[2]+" @cAux, @IN_FILIAL, @cFil_AKT OutPut"+CRLF

   /* --------------------------------------------------------------
      Inicia a exclus„o de slds diarios, AKT, para reprocessamento
      -------------------------------------------------------------- */
cQuery+="   Select @iMinRecno = IsNull(Min( R_E_C_N_O_), 0), @iMaxRecno = IsNull(Max( R_E_C_N_O_ ), 0 )"+CRLF
cQuery+="     From "+RetSqlName("AKT")+CRLF
cQuery+="    Where AKT_FILIAL = @cFil_AKT"+CRLF
cQuery+="      and AKT_CONFIG = @IN_CONFIG"+CRLF
If !Empty(cTpSld)
	cQuery+="      and AKT_TPSALD IN "+cTpSld+CRLF
endIf
cQuery+="      and AKT_DATA between @IN_DATAI and @IN_DATAF"+CRLF
cQuery+="      and D_E_L_E_T_ = ' '"+CRLF
   
cQuery+="   While ( ( @iMinRecno != 0 ) and (@iMinRecno <= @iMaxRecno))  begin"+CRLF
cQuery+="      If @IN_FK = '1' begin"+CRLF
         /* --------------------------------------------------------------
            Integridade eferencial LIGADA
            -------------------------------------------------------------- */
cQuery+="         begin tran"+CRLF
cQuery+="         Update "+RetSqlName("AKT")+CRLF
cQuery+="            Set D_E_L_E_T_ = '*'"+CRLF
cQuery+="         ##FIELDP01( 'AKT.R_E_C_D_E_L_' )"+CRLF
cQuery+="              , R_E_C_D_E_L_ = R_E_C_N_O_"+CRLF
cQuery+="         ##ENDFIELDP01"+CRLF
cQuery+="          Where AKT_FILIAL = @cFil_AKT"+CRLF
cQuery+="            and AKT_CONFIG = @IN_CONFIG"+CRLF
If !Empty(cTpSld)
	cQuery+="            and AKT_TPSALD IN "+cTpSld+CRLF
endIf
cQuery+="            and AKT_DATA between @IN_DATAI and @IN_DATAF"+CRLF
cQuery+="            and R_E_C_N_O_ between @iMinRecno and @iMinRecno + @iNroRegs"+CRLF
cQuery+="         commit tran"+CRLF
cQuery+="      end"+CRLF
      /* --------------------------------------------------------------
         Integridade eferencial nao ligada
         -------------------------------------------------------------- */
cQuery+="      begin tran"+CRLF
cQuery+="      Delete from "+RetSqlName("AKT")+CRLF
cQuery+="       Where AKT_FILIAL = @cFil_AKT"+CRLF
cQuery+="         and AKT_CONFIG = @IN_CONFIG"+CRLF
If !Empty(cTpSld)
	cQuery+="            and AKT_TPSALD IN "+cTpSld+CRLF
EndIf
cQuery+="         and AKT_DATA between @IN_DATAI and @IN_DATAF"+CRLF
cQuery+="         and R_E_C_N_O_ between @iMinRecno and @iMinRecno + @iNroRegs"+CRLF
cQuery+="      commit tran"+CRLF
cQuery+="      select @iMinRecno = @iMinRecno + @iNroRegs"+CRLF
cQuery+="   End"+CRLF
cQuery+="End"+CRLF

cQuery := CtbAjustaP(.T., cQuery, @nPTratRec)
cQuery := MsParse(cQuery, If(Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB())))
cQuery := CtbAjustaP(.F., cQuery, nPTratRec)

If Empty( cQuery )
	MsgAlert(MsParseError(),STR0021+cProc)  //'A query de exclusao de AKT nao passou pelo Parse '
	lRet := .F.
Else
	If !TCSPExist( cProc )
		cRet := TcSqlExec(cQuery)
		If cRet <> 0
			If !__lBlind
				MsgAlert(STR0022+cProc)  //"Erro na criacao da procedure de exclusao de AKT "
				lRet:= .F.
			EndIf
		EndIf
	EndIf
EndIf
RestArea(aSaveArea)
Return(lRet)

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥PCOA300A   ≥ Autor ≥ Alice Yaeko Yamamoto  ≥ Data ≥06.06.08  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Cria  procedures pa atualizacao do AKT para todos os niveis  ≥±±
±±≥          ≥do Cubo                                                      ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ PCOOA300E(cCubo,aNivel, cArq,cArqAKT, aProcAKT )            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥  Uso     ≥ SigaPCO                                                     ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ParÑmetros≥ ExpC1 = cCubo -  Codigo do Cubo a ser atualizado            ≥±±
±±≥          ≥ ExpA2 = aNivel-  Niveis a serem atualizados                 ≥±±
±±≥          ≥ ExpC2 = cArq  -  Nome da procedure q sera criada no banco   ≥±±
±±≥          ≥ ExpC2 = cArqAKT- Nome da procedure de At. do AKT            ≥±±
±±≥          ≥ ExpC2 = aProcAKT-Nome da procedure de At. do AKT            ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function PCOA300A(cCubo, aNivel, cArq, cArqAKT, aProcAKT )
Local aSaveArea := GetArea()
Local cQuery    := ""
Local cQueryAux := ""
Local cTipo     := ""
Local nPos      := 0
Local iX        := 0
Local iNivel    := 0
Local aCampos   := AKT->(DbStruct())
Local cProc     := cArq+"_"
Local cProcAKT  := cArqAKT+"_"+cEmpAnt
Local lRet      := .T. 
/* aNivel[1][1] = AK5 ou CT1 -> Alias do Nivel
	aNivel[1][2] = SC999999   -> Tabela temporaria
	aNivel[1][3] = Nome da procedure superior
	aNivel[1][4] = Nivel do cubo em q sls superiores ser„o gerados
*/
For iX := 1 to Len(aNivel)
	cQuery := ""
	cQuery:="Create Procedure "+cProc+StrZero(iX, 2)+"_"+cEmpAnt+" ("+CRLF
	nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "AKT_FILIAL" } )
	cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
	cQuery+="	@IN_FILIAL     "+cTipo+CRLF
	nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "AKT_CONFIG" } )
	cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
	cQuery +="	@IN_CONFIG    	"+cTipo+CRLF
	cQuery+="	@IN_DATA    	Char( 08 ),"+CRLF
	cQuery+="	@IN_VALORD1  	float,"+CRLF
	cQuery+="	@IN_VALORD2  	float,"+CRLF
	cQuery+="	@IN_VALORD3  	float,"+CRLF
	cQuery+="	@IN_VALORD4  	float,"+CRLF
	cQuery+="	@IN_VALORD5  	float,"+CRLF
	cQuery+="	@IN_VALORC1   	float,"+CRLF
	cQuery+="	@IN_VALORC2   	float,"+CRLF
	cQuery+="	@IN_VALORC3   	float,"+CRLF
	cQuery+="	@IN_VALORC4   	float,"+CRLF
	cQuery+="	@IN_VALORC5   	float,"+CRLF
	cQueryAux:= ""
	DbSelectArea("AKW")
	DbSetOrder(1)
	DbSeek( xFilial("AKW")+cCubo)
	While AKW_FILIAL+AKW->AKW_COD = xFilial("AKW")+cCubo .and. !Eof()
		cQueryAux :=cQueryAux+"       @IN_NIV"+Trim(AKW->AKW_NIVEL)+"      Char( "+StrZero(AKW->AKW_TAMANH,02)+" ),"+CRLF  // CONTA
		dbSkip()
	EndDo  
	/* Tirar a virgula do final*/
	cQueryAux := SubString(cQueryAux,1, (Len(cQueryAux)-3))
	cQuery +=cQueryAux+CRLF
	cQuery+=")"+CRLF
	
	cQuery+="as"+CRLF
	DbSelectArea("AKW")
	DbSetOrder(1)
	dbSeek(xFilial("AKW")+cCubo+aNivel[ix][4])
	cQuery+="Declare @cAnalitica    Char( "+StrZero(AKW->AKW_TAMANH,02)+" )"+CRLF
	cQuery+="Declare @cSuperior     Char( "+StrZero(AKW->AKW_TAMANH,02)+" )"+CRLF
	
	nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "AKT_CHAVE" } )
	cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
	cQuery+="Declare @cChaveR "+cTipo+CRLF
	cQuery+="Declare @iRegs integer "+CRLF
	cQuery+="Declare @iTranCount integer "+CRLF

	cQuery+="begin"+CRLF
	cQuery+="   select @cChaveR = ''"+CRLF
	cQuery+="   select @iRegs = 0"+CRLF
	
	cQuery+="   Declare CUR_AKT"+aNivel[iX][1]+"NIV"+aNivel[iX][4]+" insensitive cursor for"+CRLF
	cQuery+="   select ANALITICA, SUPERIOR"+CRLF
	cQuery+="     from "+aNivel[iX][2]+CRLF   // tabela tempor·ria
	cQuery+="    where ANALITICA = @IN_NIV"+aNivel[iX][4]+CRLF  
	cQuery+="   for read only"+CRLF
	cQuery+="   Open CUR_AKT"+aNivel[iX][1]+"NIV"+aNivel[iX][4]+CRLF
	cQuery+="   Fetch CUR_AKT"+aNivel[iX][1]+"NIV"+aNivel[iX][4]+" into @cAnalitica, @cSuperior"+CRLF
	
	cQuery+="   While @@fetch_status = 0 begin"+CRLF
	/* Atualizo as superiores
		ak5 = 111002 -> analitica       CTT = 112 ->  analitica                                                                                   
				111    -> 1 superior            11  -> 1 superior 
				11     -> 2 superior            1   -> 2 superior 
				1		 -> 3 superior 
		No caso de termos AK5 =  nivel01 e CTT = nivel02 Tipo de Saldo = PR,
		as Analiticas do nivel01 e a analitica do nivel2 sao as mesmas = 111002 112 PR
	    */
	DbSelectArea("AKW")
	DbSetOrder(1)
	DbSeek( xFilial("AKW")+cCubo)
	cQueryAux:=""
	cQueryAux+="      Select @cChaveR = "
	While AKW_FILIAL+AKW->AKW_COD = xFilial("AKW")+cCubo .and. !Eof()
		cQueryAux += IIf(AKW->AKW_NIVEL=aNivel[ix][4]," @cSuperior||","@IN_NIV"+AKW->AKW_NIVEL+"||" )
		dbSkip()
	EndDo
	/* Tirar || do final */
	cQueryAux := SubString(cQueryAux,1, (Len(cQueryAux)-2))
	cQuery +=cQueryAux+CRLF
	      /* --------------------------------------------------------------
	         Inicia o Atualizacao do AKT 
	         PCOA300B - aproc[3]
	         -------------------------------------------------------------- */
	cQuery+="      EXEC "+cProcAKT+" @IN_FILIAL,  @IN_CONFIG,  @IN_DATA,    @cChaveR,    @IN_VALORD1, @IN_VALORD2, @IN_VALORD3, @IN_VALORD4, @IN_VALORD5,"+CRLF
	cQuery+="                       @IN_VALORC1, @IN_VALORC2, @IN_VALORC3, @IN_VALORC4, @IN_VALORC5, '0',"
	cQueryAux:= ""
	DbSelectArea("AKW")
	DbSetOrder(1)
	DbSeek( xFilial("AKW")+cCubo)
	While AKW_FILIAL+AKW->AKW_COD = xFilial("AKW")+cCubo .and. !Eof()
		cQueryAux += IIf(AKW->AKW_NIVEL=aNivel[iX][4]," @cSuperior,"," @IN_NIV"+AKW->AKW_NIVEL+"," )
		dbSkip()
	EndDo
	/* Tirar , do final */
	cQueryAux := SubString(cQueryAux,1, (Len(cQueryAux)-1))
	cQuery +=cQueryAux+CRLF
	cQuery+="      Fetch CUR_AKT"+aNivel[iX][1]+"NIV"+aNivel[iX][4]+" into @cAnalitica, @cSuperior"+CRLF
	cQuery+="   End"+CRLF
	cQuery+="   Close CUR_AKT"+aNivel[iX][1]+"NIV"+aNivel[iX][4]+CRLF
	cQuery+="   Deallocate CUR_AKT"+aNivel[iX][1]+"NIV"+aNivel[iX][4]+CRLF
	cQuery+="End"+CRLF
	
	cQuery := MsParse(cQuery,If(Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB())))
	cQuery := CtbAjustaP(.f., cQuery, 0)
	
	If Empty( cQuery )
		MsgAlert(MsParseError(),STR0023+aNivel[ix][1]+"-"+aNivel[iX][4]+"-"+cProc)  //'A query de Atual. Slds de Ctas Superiores  nao passou pelo Parse '
		lRet := .F.
	Else
		If !TCSPExist( cProc )
			cRet := TcSqlExec(cQuery)
			AADD( aProcAKT, cProc+StrZero(iX, 2)+"_"+cEmpAnt )
			If cRet <> 0
				If !__lBlind 
					MsgAlert(STR0024+aNivel[ix][1]+"-"+aNivel[iX][4]+"-"+cProc)  //"Erro na criacao da proc de Atual. Slds de Ctas Superiores Nivel: "
					lRet:= .F.
					Exit
				EndIf
			EndIf
		EndIf
	EndIf
Next iX

RestArea(aSaveArea)
Return(lRet)

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥PCOA300Proc≥ Autor ≥ Alice Yaeko Yamamoto    ≥ Data ≥06.06.08  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Cria  procedures Pai                                           ≥±±
±±≥          ≥                                                               ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥  Uso     ≥ SigaPCO                                                       ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ParÑmetros≥ExpC1 = cCubo    - Codigo do Cubo a ser atualizado             ≥±±
±±≥          ≥ExpA1 = aNivel   - Niveis a serem atualizados                  ≥±±
±±≥          ≥ExpC2 = cArq     - Nome da procedure q sera criada no banco    ≥±±
±±≥          ≥ExpA1 = aProc    - Array c procedures                          ≥±±
±±≥          ≥ExpA2 = aProcAKT - Array com as procedures criadas p niveis AKT≥±±
±±≥          ≥ExpC3 = cTpSald  - Tipo do Saldo                               ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function PCOA300Proc( cCubo, aNivel, cArq, aProc, aProcAKT, cTpSld )
Local aSaveArea := GetArea()
Local cQuery    := ""
Local cQueryAux := ""
Local cTipo     := ""
Local nPos      := 0
Local iX        := 0
Local iZ        := 0
Local iNivel    := 0
Local aCampos1  := AKT->(DbStruct())
Local aCampos2  := AKD->(DbStruct())
Local aCposAux, cVarAux, nZ
Local cProc     := cArq+"_"+cEmpAnt
Local lREt      := .T.
Local iProc     := 0

cQuery:="Create Procedure "+cProc+"("+CRLF 
nPos := Ascan( aCampos1, {|x| Alltrim(x[1]) == "AKT_FILIAL" } )
cTipo := " Char( "+StrZero(aCampos1[nPos][3],3)+" ),"
cQuery+="   @IN_FILIAL  "+cTipo+CRLF
nPos := Ascan( aCampos1, {|x| Alltrim(x[1]) == "AKT_CONFIG" } )
cTipo := " Char( "+StrZero(aCampos1[nPos][3],3)+" ),"
cQuery+="   @IN_CONFIG  "+cTipo+CRLF
cQuery+="   @IN_DATAI   Char( 08 ),"+CRLF
cQuery+="   @IN_DATAF   Char( 08 ),"+CRLF
cQuery+="   @IN_FK      Char( 01 ),"+CRLF
cQuery+="   @OUT_RESULT Char( 01) OutPut"+CRLF
cQuery+=")"+CRLF
cQuery+="as"+CRLF 
/* ---------------------------------------------------------------------------------------------------------------------
   Vers„o          - <v> Protheus 9.12 </v>
   Assinatura      - <a> 001 </a>
   Fonte Microsiga - <s> PCOA300.PRX </s>
   Descricao       - <d> Reprocessamento de Saldos - Cubos </d>
   Funcao do Siga  -     PCOA300Sld()
   -----------------------------------------------------------------------------------------------------------------
   Entrada         -  <ri> @IN_FILIALR	- Filial corrente 
       				   		@IN_CONFIG  - Codigo do cubo
         						@IN_DATAI   - Periodo Inicial
         						@IN_DATAF   - Periodo Final
         						@IN_FK      - '1' se integridade estiver ligada	</ri>
   -----------------------------------------------------------------------------------------------------------------
   Saida          -  <ro> @OUT_RESULT    -  </ro>
   -----------------------------------------------------------------------------------------------------------------
   Responsavel    -   <r> Alice Yaeko Yamamoto  </r>
   -----------------------------------------------------------------------------------------------------------------
   Data           -  <dt> 08/05/2008 </dt>
   Estrutura de chamadas
   ========= == ========
   Obs.: N„o remova os tags acima. Os tags s„o a base para a geraÁ„o autom·tica, de documentaÁ„o, pelo Parse.
   
   1 - excluir os movimentos di·rios do periodo do AKT
   3 - Iniciar Reprocessamento
      3.1 - Gerar todo o AKT do periodo atravÈs do AKD
      
/*   Ordem de chamada das procedures - Ordem de criacao de procedures aproc[1],..,aproc[10]
  **  0.1.A300LastDay  - Retorna o ultimo dia do Mes .LASTDAY.................... 1  aProc[1]
  **  0.2.CallXFilial  - Xfilial ................................................ 2  aProc[2]
   				
  	
   1.PCOA300 - Procedure pai .................................................... 6  aProc[6]
	1.2.PCOA300F -       Exclusao do AKT do periodo ....................... 4  aProc[4]
   	1.3. PCOA300A -      Atualiza os slds sintÈticos do AKT ..................... 5  aProc[5]
		1.3.1.PCOA300B - Atualiza a analitica do AKT ............................ 3  aProc[3]
   --------------------------------------------------------------------------------------------------------------------- */
cQuery+="Declare @cAux        Char( 03 )"+CRLF
nPos := Ascan( aCampos1, {|x| Alltrim(x[1]) == "AKT_FILIAL" } )
cTipo := " Char( "+StrZero(aCampos1[nPos][3],3)+" )"
cQuery+="Declare @cFil_AKD    "+cTipo+CRLF
cQuery+="Declare @cFil_ALA    "+cTipo+CRLF
cQuery+="Declare @cFilial     "+cTipo+CRLF
cQuery+="Declare @cFilAnt     "+cTipo+CRLF
nPos := Ascan( aCampos2, {|x| Alltrim(x[1]) == "AKD_TIPO" } )
cTipo := " Char( "+StrZero(aCampos2[nPos][3],3)+" )"
cQuery+="Declare @cAKD_TIPO   "+cTipo+CRLF
cQuery+="Declare @cAKD_DATA   Char( 08 )"+CRLF
cQuery+="Declare @cDataAnt    Char( 08 )"+CRLF
/* mais campos a serem criados run time - olhar oos NÌveis do Cubo */ 
DbSelectArea("AKW")
DbSetOrder(1)
DbSeek( xFilial("AKW")+cCubo)
cQueryAux := ""
While AKW_FILIAL+AKW->AKW_COD = xFilial("AKW")+cCubo .and. !Eof()
	aCposAux	:=	Str2Arr( Alltrim(AKW->AKW_CHAVER) , "+")  //quebra em array por delimitador "+"
	If Len(aCposAux) == 1
		cQueryAux +="Declare @c"+Trim(Substring(AKW->AKW_CHAVER,6,Len(AKW->AKW_CHAVER)))+" Char( "+StrZero(AKW->AKW_TAMANH,2)+" )"+CRLF
		cQueryAux +="Declare @c"+Trim(Substring(AKW->AKW_CHAVER,6,Len(AKW->AKW_CHAVER)))+"Ant"+" Char( "+StrZero(AKW->AKW_TAMANH,2)+" )"+CRLF
	Else
		For nZ := 1 TO Len(aCposAux)
			cVarAux := Alltrim(StrTran(aCposAux[nZ], "AKD->", ""))
			cQueryAux +="Declare @c"+cVarAux+" Char( "+StrZero(TamSx3(cVarAux)[1] ,2)+" )"+CRLF
			cQueryAux +="Declare @c"+cVarAux+"Ant"+" Char( "+StrZero(TamSx3(cVarAux)[1],2)+" )"+CRLF
		Next	
  		cQueryAux +="Declare @c"+Alltrim(StrTran(aCposAux[1], "AKD->", ""))+"Aux  Char( "+StrZero(AKW->AKW_TAMANH,2)+" )"+CRLF
  		cQueryAux +="Declare @c"+Alltrim(StrTran(aCposAux[1], "AKD->", ""))+"AuxAnt Char( "+StrZero(AKW->AKW_TAMANH,2)+" )"+CRLF
	EndIf	
	dbSkip()
EndDo
cQuery+=cQueryAux
cQuery+="Declare @nAKD_VALOR1 Float"+CRLF
cQuery+="Declare @nAKD_VALOR2 Float"+CRLF
cQuery+="Declare @nAKD_VALOR3 Float"+CRLF
cQuery+="Declare @nAKD_VALOR4 Float"+CRLF
cQuery+="Declare @nAKD_VALOR5 Float"+CRLF
cQuery+="Declare @nTotDEB1    Float"+CRLF
cQuery+="Declare @nTotDEB2    Float"+CRLF
cQuery+="Declare @nTotDEB3    Float"+CRLF
cQuery+="Declare @nTotDEB4    Float"+CRLF
cQuery+="Declare @nTotDEB5    Float"+CRLF
cQuery+="Declare @nTotCRD1    Float"+CRLF
cQuery+="Declare @nTotCRD2    Float"+CRLF
cQuery+="Declare @nTotCRD3    Float"+CRLF
cQuery+="Declare @nTotCRD4    Float"+CRLF
cQuery+="Declare @nTotCRD5    Float"+CRLF
cQuery+="Declare @nValorD1    Float"+CRLF
cQuery+="Declare @nValorD2    Float"+CRLF
cQuery+="Declare @nValorD3    Float"+CRLF
cQuery+="Declare @nValorD4    Float"+CRLF
cQuery+="Declare @nValorD5    Float"+CRLF
cQuery+="Declare @nValorC1    Float"+CRLF
cQuery+="Declare @nValorC2    Float"+CRLF
cQuery+="Declare @nValorC3    Float"+CRLF
cQuery+="Declare @nValorC4    Float"+CRLF
cQuery+="Declare @nValorC5    Float"+CRLF
cQuery+="Declare @cDataDiario VarChar( 08 )"+CRLF
nPos := Ascan( aCampos1, {|x| Alltrim(x[1]) == "AKT_CHAVE" } )
cTipo := " Char( "+StrZero(aCampos1[nPos][3],3)+" )"
cQuery+="Declare @cChaveAKT   "+cTipo+CRLF
cQuery+="Declare @cChaveR     "+cTipo+CRLF
cQuery+="Declare @cChave      "+cTipo+CRLF
cQuery+="Declare @cChave1     "+cTipo+CRLF
cQuery+="Declare @lAtuAKT Char( 01 )"+CRLF
cQuery+="Declare @lAtlAKT Char( 01 )"+CRLF
cQuery+="Declare @lPrim   Char( 01 )"+CRLF

cQuery+="Begin"+CRLF
cQuery+="   select @OUT_RESULT  = '0'"+CRLF
cQuery+="   select @nTotDEB1 = 0, @nTotDEB2 = 0, @nTotDEB3 = 0, @nTotDEB4 = 0, @nTotDEB5 = 0"+CRLF
cQuery+="   select @nTotCRD1 = 0, @nTotCRD2 = 0, @nTotCRD3 = 0, @nTotCRD4 = 0, @nTotCRD5 = 0"+CRLF
cQuery+="   select @cDataDiario = ''"+CRLF
cQuery+="   select @cChaveAKT   = ''"+CRLF
cQuery+="   select @cChaveR     = ''"+CRLF
cQuery+="   select @cChave      = ''"+CRLF
cQuery+="   select @cChave1     = ''"+CRLF
cQuery+="   select @cFil_AKD    = '  '"+CRLF
cQuery+="   select @cFil_ALA     = '  '"+CRLF
cQuery+="   select @nValorD1    = 0"+CRLF
cQuery+="   select @nValorD2    = 0"+CRLF
cQuery+="   select @nValorD3    = 0"+CRLF
cQuery+="   select @nValorD4    = 0"+CRLF
cQuery+="   select @nValorD5    = 0"+CRLF
cQuery+="   select @nValorC1    = 0"+CRLF
cQuery+="   select @nValorC2    = 0"+CRLF
cQuery+="   select @nValorC3    = 0"+CRLF
cQuery+="   select @nValorC4    = 0"+CRLF
cQuery+="   select @nValorC5    = 0"+CRLF
cQuery+="   select @lAtuAKT     = '0'"+CRLF
cQuery+="   select @lAtlAKT     = '0'"+CRLF
cQuery+="   select @lPrim       = '1'"+CRLF
cQuery+="   select @cFilAnt     = '  '"+CRLF
cQuery+="   select @cDataAnt    = ''"+CRLF

DbSelectArea("AKW")
DbSetOrder(1)
DbSeek( xFilial("AKW")+cCubo)
cQueryAux := ""
While AKW_FILIAL+AKW->AKW_COD = xFilial("AKW")+cCubo .and. !Eof()
	aCposAux	:=	Str2Arr( Alltrim(AKW->AKW_CHAVER) , "+")  //quebra em array por delimitador "+"
	If Len(aCposAux) == 1
		cQueryAux +="   Select @c"+Trim(Substring(AKW->AKW_CHAVER,6,Len(AKW->AKW_CHAVER)))+"Ant"+" = ''"+CRLF	
	Else
		For nZ := 1 TO Len(aCposAux)
			cVarAux := Alltrim(StrTran(aCposAux[nZ], "AKD->", ""))
			cQueryAux +="   Select @c"+cVarAux+"Ant"+" = ''"+CRLF
		Next
  		cQueryAux +="   Select @c"+Alltrim(StrTran(aCposAux[1], "AKD->", ""))+"Aux    = ''"+CRLF
  		cQueryAux +="   Select @c"+Alltrim(StrTran(aCposAux[1], "AKD->", ""))+"AuxAnt = ''"+CRLF
	EndIf	
	dbSkip()
EndDo
cQuery+=cQueryAux
   /* --------------------------------------------------------------
      Recuperando Filiais
      -------------------------------------------------------------- */
cQuery+="   select @cAux = 'AKD'"+CRLF
cQuery+="   EXEC "+aProc[2]+" @cAux, @IN_FILIAL, @cFil_AKD OutPut"+CRLF
cQuery+="   select @cAux = 'ALA'"+CRLF
cQuery+="   EXEC "+aProc[2]+" @cAux, @IN_FILIAL, @cFil_ALA OutPut"+CRLF
   /* ----------------------------------------------------------------------------
      Inicia a exlus„o de slds diarios AKT , para reprocessamento
      PCOA300F
      ---------------------------------------------------------------------------- */
cQuery+="   EXEC "+aProc[4]+" @IN_FILIAL, @IN_CONFIG, @IN_DATAI, @IN_DATAF, @IN_FK"+CRLF
   /* --------------------------------------------------------------
      3 - Inicia o Reprocessamento no range informado
		Trazer o AKD agrupado por data e pela chave do cubo
      -------------------------------------------------------------- */
cQuery+="   Declare CUR_PCO300 insensitive cursor for"+CRLF      //- AL1->AL1_CHAVER, cQuery	+=	cCampos+" , "    //campos do cubo gerencial   
cQuery+="	Select AKD_FILIAL, AKD_TIPO, AKD_DATA, "
cQueryAux:=""
DbSelectArea("AKW")
DbSetOrder(1)
DbSeek( xFilial("AKW")+cCubo)
While AKW_FILIAL+AKW->AKW_COD = xFilial("AKW")+cCubo .and. !Eof()
	aCposAux	:=	Str2Arr( Alltrim(AKW->AKW_CHAVER) , "+")  //quebra em array por delimitador "+"
	If Len(aCposAux) == 1
		cQueryAux +=Trim(Substring(AKW->AKW_CHAVER,6,Len(AKW->AKW_RELAC)))+", "
		iNivel += 1
	Else
		For nZ := 1 TO Len(aCposAux)
			cVarAux := Alltrim(StrTran(aCposAux[nZ], "AKD->", ""))
			cQueryAux += cVarAux + ", " 
			iNivel += 1
		Next nZ	
	EndIf	
	dbSkip()
EndDo
cQuery+=cQueryAux
cQuery+="SUM(AKD_VALOR1), SUM(AKD_VALOR2), SUM(AKD_VALOR3), SUM(AKD_VALOR4), SUM(AKD_VALOR5)"+CRLF
cQuery+="     from "+RetSqlName("AKD") +CRLF
cQuery+="    where AKD_FILIAL = @cFil_AKD"+CRLF
cQuery+="		and AKD_DATA Between @IN_DATAI and @IN_DATAF"+CRLF
cQuery+="		and AKD_STATUS = '1'"+CRLF
cQuery+="       and AKD_TIPO IN ( '1', '2' )"+CRLF
If !Empty(cTpSld)
	cQuery+="       and AKD_TPSALD IN "+cTpSld+CRLF
EndIf
cQuery+="		and D_E_L_E_T_ = ' '"+CRLF
cQuery+="       and R_E_C_N_O_ NOT IN ( Select ALA_RECAKD "+CRLF
cQuery+="                                from "+RetSqlName("ALA")+CRLF
cQuery+="                               where ALA_FILIAL = @cFil_ALA"+CRLF
cQuery+="                                 and ALA_STATUS = '1'"+CRLF
cQuery+="                                 and D_E_L_E_T_ = ' ' )"+CRLF
cQuery+="		group by AKD_FILIAL, AKD_TIPO, AKD_DATA,"  //, AKD_CO, AKD_CC, AKD_TPSALD
cQueryAux:=Substring(cQueryAux,1,(Len(cQueryAux)-2))
cQuery+= cQueryAux+CRLF
cQuery+="		order by 3"
For iZ = 1 to iNivel
	iX = 3 +	iZ
	cQuery+= ", "+Str(3+iZ)
Next iZ
cQuery+=CRLF
cQuery+="   for read only"+CRLF
cQuery+="   Open CUR_PCO300"+CRLF
cQuery+="   Fetch CUR_PCO300 into @cFilial, @cAKD_TIPO, @cAKD_DATA,"/*@cAKD_CO, @cAKD_CC, @cAKD_TPSALD*/
cQueryAux:=""
DbSelectArea("AKW")
DbSetOrder(1)
DbSeek( xFilial("AKW")+cCubo)
While AKW_FILIAL+AKW->AKW_COD = xFilial("AKW")+cCubo .and. !Eof()
	aCposAux	:=	Str2Arr( Alltrim(AKW->AKW_CHAVER) , "+")  //quebra em array por delimitador "+"
	If Len(aCposAux) == 1
		cQueryAux +="@c"+Trim(Substring(AKW->AKW_CHAVER,6,Len(AKW->AKW_RELAC)))+", "
	Else
		For nZ := 1 TO Len(aCposAux)
			cVarAux := Alltrim(StrTran(aCposAux[nZ], "AKD->", ""))
			cQueryAux +="@c"+cVarAux+", "
		Next	
	EndIf	
	dbSkip()
EndDo
cQuery+=cQueryAux
cQuery+="@nAKD_VALOR1, @nAKD_VALOR2, @nAKD_VALOR3, @nAKD_VALOR4, @nAKD_VALOR5"+CRLF
cQuery+="   While (@@Fetch_status = 0 ) begin"+CRLF
cQueryAux:= ""
DbSelectArea("AKW")
DbSetOrder(1)
DbSeek( xFilial("AKW")+cCubo)
While AKW_FILIAL+AKW->AKW_COD = xFilial("AKW")+cCubo .and. !Eof()
	aCposAux	:=	Str2Arr( Alltrim(AKW->AKW_CHAVER) , "+")  //quebra em array por delimitador "+"
	If Len(aCposAux) == 1
		cQueryAux +="@c"+Trim(Substring(AKW->AKW_CHAVER,6,Len(AKW->AKW_RELAC)))+", "
	Else
		cQueryAux+="@c"+Alltrim(StrTran(aCposAux[1], "AKD->", ""))+"Aux"+", "
		cVarAux:= ""
		For nZ := 1 TO Len(aCposAux)
//                 = @cAKD_CODPLAAnt||@cAKD_VERSAOAnt		
			cVarAux += "@c"+Alltrim(StrTran(aCposAux[nZ], "AKD->", ""))+If(nZ < Len(aCposAux), "||", "")
		Next
		If Len(cVarAux) > 0
			cQuery +="         select "+"@c"+Alltrim(StrTran(aCposAux[1], "AKD->", ""))+"Aux = "+cVarAux+CRLF
		EndIf
	EndIf
	dbSkip()
EndDo
      /* ---------------------------------------------------------------- 
         Somente na primeira, dados anteriores recebem os atuais
         ---------------------------------------------------------------- */
cQuery+="      If @lPrim = '1' begin"+CRLF
cQuery+="         select @cFilAnt  = @cFilial"+CRLF
cQuery+="         select @cDataAnt = @cAKD_DATA"+CRLF
DbSelectArea("AKW")
DbSetOrder(1)
DbSeek( xFilial("AKW")+cCubo)
cQueryAux := ""
While AKW_FILIAL+AKW->AKW_COD = xFilial("AKW")+cCubo .and. !Eof()
	aCposAux	:=	Str2Arr( Alltrim(AKW->AKW_CHAVER) , "+")  //quebra em array por delimitador "+"
	If Len(aCposAux) == 1
		cQueryAux +="         Select @c"+Trim(Substring(AKW->AKW_CHAVER,6,Len(AKW->AKW_CHAVER)))+"Ant = "+"@c"+Trim(Substring(AKW->AKW_CHAVER,6,Len(AKW->AKW_CHAVER)))+CRLF
	Else
		For nZ := 1 TO Len(aCposAux)
			cVarAux := Alltrim(StrTran(aCposAux[nZ], "AKD->", ""))
			cQueryAux +="         Select @c"+cVarAux+"Ant = @c"+cVarAux+CRLF
		Next
		cQueryAux +="         Select @c"+Alltrim(StrTran(aCposAux[1], "AKD->", ""))+"AuxAnt = @c"+Alltrim(StrTran(aCposAux[1], "AKD->", ""))+"Aux"+CRLF
	EndIf
	dbSkip()
EndDo
cQuery+=cQueryAux
cQuery+="         select @lPrim = '0'"+CRLF
cQuery+="      End"+CRLF

cQueryAux:= ""
DbSelectArea("AKW")
DbSetOrder(1)
DbSeek( xFilial("AKW")+cCubo)
While AKW_FILIAL+AKW->AKW_COD = xFilial("AKW")+cCubo .and. !Eof()
	aCposAux	:=	Str2Arr( Alltrim(AKW->AKW_CHAVER) , "+")  //quebra em array por delimitador "+"
	If Len(aCposAux) == 1
		cQueryAux +="@c"+Trim(Substring(AKW->AKW_CHAVER,6,Len(AKW->AKW_RELAC)))+", "
	Else
		cQueryAux+="@c"+Alltrim(StrTran(aCposAux[1], "AKD->", ""))+"Aux"+", "
		cVarAux:= ""
		For nZ := 1 TO Len(aCposAux)
//                 = @cAKD_CODPLAAnt||@cAKD_VERSAOAnt		
			cVarAux += "@c"+Alltrim(StrTran(aCposAux[nZ], "AKD->", ""))+If(nZ < Len(aCposAux), "||", "")
		Next
		If Len(cVarAux) > 0
			cQuery +="         select "+"@c"+Alltrim(StrTran(aCposAux[1], "AKD->", ""))+"Aux = "+cVarAux+CRLF
		EndIf
	EndIf
	dbSkip()
EndDo
cQueryAux:= StrTran(cQueryAux,", ","Ant||")
cQueryAux:= Substring(cQueryAux,1,(Len(cQueryAux)-2))                  
cQuery+="      Select @cDataDiario = SubsTring(@cDataAnt,1,6)"+CRLF
cQuery+="      select @cChaveAKT = @cFilAnt||@cDataAnt||"+cQueryAux+CRLF      //@cAKD_COAnt||@cAKD_CCAnt||@cAKD_TPSALDAnt"+CRLF
cQuery+="      select @cChaveR   =           "+cQueryAux+CRLF   //@cAKD_COAnt||@cAKD_CCAnt||@cAKD_TPSALDAnt"+CRLF
cQueryAux:= StrTran(cQueryAux,"Ant","")
cQuery+="      select @cChave  = @cFilial||@cAKD_DATA||"+cQueryAux /*@cAKD_CO||@cAKD_CC||@cAKD_TPSALD*/+CRLF
cQuery+="      select @cChave1 = @cFilial||"+cQueryAux /*@cAKD_CO||@cAKD_CC||@cAKD_TPSALD*/+CRLF
      /* -----------------------------------------------------------------
         Atualiza @lAtuAKT com '1' para efetuar a gravavao do AKT
         ----------------------------------------------------------------- */
cQuery+="      If @cChave != @cChaveAKT begin"+CRLF
cQuery+="         select @lAtuAKT = '1'"+CRLF
cQuery+="      End"+CRLF

cQuery+="         select @lAtlAKT = '1'"+CRLF  //se passou no laco atribui 1

      /* --------------------------------------------------------------
         Inicia o Atualizacao do AKT p/ cada um dos niveis Conta, CC
         -------------------------------------------------------------- */      
cQueryAux:= StrTran(cQueryAux,"||","Ant, ")+"Ant"
cQuery+="      If @lAtuAKT = '1' begin"+CRLF
         /* --------------------------------------------------------------
            Atualizo a analitica do AKT - apenas uma analitica
            PCOA300B  - proc[3]
            -------------------------------------------------------------- */
cQuery+="         EXEC "+aProc[3]+" @cFilAnt,  @IN_CONFIG, @cDataAnt, @cChaveR, @nValorD1,  @nValorD2,  @nValorD3,    @nValorD4,      @nValorD5,"+CRLF
cQuery+="                          @nValorC1, @nValorC2,  @nValorC3, @nValorC4, @nValorC5, '1',"+cQueryAux/*@cAKD_COAnt, @cAKD_CCAnt, @cAKD_TPSALDAnt*/+CRLF
         /* --------------------------------------------------------------
            Atualizo AKT de nÌveis sintÈticos para cada nivel do cubo 
            PCOA300A - proc[5]
            -------------------------------------------------------------- */
For iProc = 1 to Len(aProcAKT)
	cQuery+="         EXEC "+aProcAKT[iProc]+" @cFilAnt,  @IN_CONFIG, @cDataAnt, @nValorD1, @nValorD2, @nValorD3, @nValorD4, @nValorD5,"+CRLF
	cQuery+="                          @nValorC1, @nValorC2,  @nValorC3,  @nValorC4, @nValorC5, "+cQueryAux /*@cAKD_COAnt, @cAKD_CCAnt, @cAKD_TPSALDAnt*/+CRLF
Next iProc
cQuery+="         select @nValorC1 = 0, @nValorC2 = 0, @nValorC3 = 0, @nValorC4 = 0, @nValorC5 = 0"+CRLF
cQuery+="         select @nValorD1 = 0, @nValorD2 = 0, @nValorD3 = 0, @nValorD4 = 0, @nValorD5 = 0"+CRLF
cQuery+="         select @lAtuAKT = '0'"+CRLF
cQuery+="      End"+CRLF
      /* --------------------------------------------------------------
         Vars para atualizacao do AKT
         -------------------------------------------------------------- */  
cQuery+="      If @cAKD_TIPO = '1' begin"+CRLF
cQuery+="         select @nValorC1 = @nAKD_VALOR1"+CRLF
cQuery+="         select @nValorC2 = @nAKD_VALOR2"+CRLF
cQuery+="         select @nValorC3 = @nAKD_VALOR3"+CRLF
cQuery+="         select @nValorC4 = @nAKD_VALOR4"+CRLF
cQuery+="         select @nValorC5 = @nAKD_VALOR5"+CRLF
cQuery+="      end else begin"+CRLF
cQuery+="         select @nValorD1 = @nAKD_VALOR1"+CRLF
cQuery+="         select @nValorD2 = @nAKD_VALOR2"+CRLF
cQuery+="         select @nValorD3 = @nAKD_VALOR3"+CRLF
cQuery+="         select @nValorD4 = @nAKD_VALOR4"+CRLF
cQuery+="         select @nValorD5 = @nAKD_VALOR5"+CRLF
cQuery+="      end"+CRLF
cQuery+="      select @cFilAnt  = @cFilial"+CRLF
cQuery+="      select @cDataAnt = @cAKD_DATA"+CRLF
DbSelectArea("AKW")
DbSetOrder(1)
DbSeek( xFilial("AKW")+cCubo)
cQueryAux := ""
While AKW_FILIAL+AKW->AKW_COD = xFilial("AKW")+cCubo .and. !Eof()
	aCposAux	:=	Str2Arr( Alltrim(AKW->AKW_CHAVER) , "+")  //quebra em array por delimitador "+"
	If Len(aCposAux) == 1
		cQueryAux +="      Select @c"+Trim(Substring(AKW->AKW_CHAVER,6,Len(AKW->AKW_CHAVER)))+"Ant = "+"@c"+Trim(Substring(AKW->AKW_CHAVER,6,Len(AKW->AKW_CHAVER)))+CRLF
	Else
		For nZ := 1 TO Len(aCposAux)
			cVarAux := Alltrim(StrTran(aCposAux[nZ], "AKD->", ""))
			cQueryAux +="      Select @c"+cVarAux+"Ant = @c"+cVarAux+CRLF
		Next
		cQueryAux +="      Select @c"+Alltrim(StrTran(aCposAux[1], "AKD->", ""))+"AuxAnt = @c"+Alltrim(StrTran(aCposAux[1], "AKD->", ""))+"Aux"+CRLF
	EndIf
	dbSkip()
EndDo
cQuery+=cQueryAux
cQueryAux:= ""
DbSelectArea("AKW")
DbSetOrder(1)
DbSeek( xFilial("AKW")+cCubo)
While AKW_FILIAL+AKW->AKW_COD = xFilial("AKW")+cCubo .and. !Eof()
	aCposAux	:=	Str2Arr( Alltrim(AKW->AKW_CHAVER) , "+")  //quebra em array por delimitador "+"
	If Len(aCposAux) == 1
		cQueryAux +="@c"+Trim(Substring(AKW->AKW_CHAVER,6,Len(AKW->AKW_RELAC)))+", "
	Else
		For nZ := 1 TO Len(aCposAux)
			cVarAux := Alltrim(StrTran(aCposAux[nZ], "AKD->", ""))
			cQueryAux +="@c"+cVarAux+", "
		Next
	EndIf	
	dbSkip()
EndDo
cQuery+="      Fetch CUR_PCO300 into @cFilial, @cAKD_TIPO, @cAKD_DATA, "+cQueryAux/*@cAKD_CO, @cAKD_CC, @cAKD_TPSALD,*/+"@nAKD_VALOR1, @nAKD_VALOR2, @nAKD_VALOR3, @nAKD_VALOR4,"+CRLF
cQuery+="                             @nAKD_VALOR5"+CRLF
cQuery+="   End"+CRLF
cQueryAux:= SubString(cQueryAux,1, Len(cQueryAux)-2)
cQueryAux:= StrTran(cQueryAux,", ","||")

cQuery+="   If @lAtlAKT = '1' begin"+CRLF
cQuery+="   select @cChaveR = "+cQueryAux /*@cAKD_CO||@cAKD_CC||@cAKD_TPSALD*/+CRLF
   /* ----------------------------------------------------------------------------------------------------- 
      Atualizo o ultimo AKT do Result Set
      ----------------------------------------------------------------------------------------------------- */
cQueryAux:= ""
DbSelectArea("AKW")
DbSetOrder(1)
DbSeek( xFilial("AKW")+cCubo)
While AKW_FILIAL+AKW->AKW_COD = xFilial("AKW")+cCubo .and. !Eof()
	aCposAux	:=	Str2Arr( Alltrim(AKW->AKW_CHAVER) , "+")  //quebra em array por delimitador "+"
	If Len(aCposAux) == 1
		cQueryAux +="@c"+Trim(Substring(AKW->AKW_CHAVER,6,Len(AKW->AKW_RELAC)))+", "
	Else
		cQueryAux+="@c"+Alltrim(StrTran(aCposAux[1], "AKD->", ""))+"Aux"+", "
	EndIf
	dbSkip()
EndDo
cQueryAux:= StrTran(cQueryAux,", ","Ant, ")
cQueryAux:= Substring(cQueryAux,1,(Len(cQueryAux)-2))
         /* --------------------------------------------------------------
            Atualizo a analitica do AKT
            -------------------------------------------------------------- */
cQuery+="   EXEC "+aProc[3]+" @cFilAnt,  @IN_CONFIG, @cDataAnt, @cChaveR, @nValorD1,  @nValorD2,  @nValorD3,    @nValorD4,      @nValorD5,"+CRLF
cQuery+="                     @nValorC1, @nValorC2,  @nValorC3, @nValorC4, @nValorC5, '1', "+cQueryAux /*@cAKD_COAnt, @cAKD_CCAnt, @cAKD_TPSALDAnt*/+CRLF
For iProc = 1 to Len(aProcAKT)
	cQuery+="   EXEC "+aProcAKT[iProc]+" @cFilAnt,  @IN_CONFIG, @cDataAnt, @nValorD1, @nValorD2, @nValorD3, @nValorD4, @nValorD5,"+CRLF
	cQuery+="                            @nValorC1, @nValorC2,  @nValorC3,  @nValorC4, @nValorC5, "+cQueryAux/*@cAKD_COAnt, @cAKD_CCAnt, @cAKD_TPSALDAnt*/+CRLF
Next iProc
cQuery+="   select @cDataDiario =  SUBSTRING(@cDataAnt , 1 , 6 )||'01'"+CRLF
cQuery+="   End"+CRLF
cQuery+="   close CUR_PCO300"+CRLF
cQuery+="   deallocate CUR_PCO300"+CRLF
cQuery+="   select @OUT_RESULT  = '1'"+CRLF
cQuery+="End"+CRLF

cQuery := MsParse( cQuery, If( Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB()) ) )
cQuery := CtbAjustaP(.F., cQuery, 0)

If Empty( cQuery )
	MsgAlert(MsParseError(),STR0025+cProc)  //'A query da procedure pai nao passou pelo Parse '
	lRet := .F.
Else
	If !TCSPExist( cProc )
		cRet := TcSqlExec(cQuery)
		If cRet <> 0
			If !__lBlind
				MsgAlert(STR0026+cProc)  //"Erro na criacao da proc Pai: "
				lRet:= .F.
			EndIf
		EndIf
	EndIf
EndIf
RestArea(aSaveArea)

Return( lRet )

/* NAO APAGAR O TRECHO ABAIXO!! Rascunho que originou a procedure

Create Procedure PCOA300_##(
   @IN_FILIAL  Char( 02 ),
   @IN_CONFIG  Char( 'AL1_CONFIG' ),
   @IN_DATAI   Char( 08 ), 
   @IN_DATAF   Char( 08 ),
   @IN_FK      Char( 01 ),
   @OUT_RESULT Char( 01) OutPut
)
as
 ---------------------------------------------------------------------------------------------------------------------
   Vers„o          - <v> Protheus 9.12 </v>
   Assinatura      - <a> 001 </a>
   Fonte Microsiga - <s> PCOA300.PRX </s>
   Descricao       - <d> Reprocessamento de Saldos - Cubos </d>
   Funcao do Siga  -     PCOA300Sld()
   -----------------------------------------------------------------------------------------------------------------
   Entrada         -  <ri> @IN_FILIALR	- Filial corrente 
       				   		@IN_CONFIG  - Codigo do cubo
         						@IN_DATAI   - Periodo Inicial
         						@IN_DATAF   - Periodo Final
         						@IN_FK      - '1' se integridade estiver ligada	</ri>
   -----------------------------------------------------------------------------------------------------------------
   Saida          -  <ro> @OUT_RESULT    -  </ro>
   -----------------------------------------------------------------------------------------------------------------
   Responsavel    -   <r> Alice Yaeko Yamamoto  </r>
   -----------------------------------------------------------------------------------------------------------------
   Data           -  <dt> 08/05/2008 </dt>
   Estrutura de chamadas
   ========= == ========
   Obs.: N„o remova os tags acima. Os tags s„o a base para a geraÁ„o autom·tica, de documentaÁ„o, pelo Parse.
   
   1 - excluir os movimentos di·rios do periodo do AKT
   3 - Iniciar Reprocessamento
      3.1 - Gerar todo o AKT do periodo atravÈs do AKD

/*   Ordem de chamada das procedures - Ordem de criacao de procedures aproc[1],..,aproc[6]
  **  0.1.A300LastDay  - Retorna o ultimo dia do Mes .LASTDAY.................... 1  aProc[1]
  **  0.2.CallXFilial  - Xfilial ................................................ 2  aProc[2]
   				
  	
   1.PCOA300 - Procedure pai .................................................... 6  aProc[6]
	1.2.PCOA300F -       Exclusao do AKT do periodo ............................. 4  aProc[4]
   	1.3. PCOA300A -      Atualiza os slds sintÈticos do AKT ..................... 5  aProc[5]
		1.3.1.PCOA300B - Atualiza a analitica do AKT ............................ 3  aProc[3]
	-------------------------------------------------------------------------------------------------------------------- 
Declare @cAux        Char( 03 )
Declare @cFil_AKD    Char( 02 )
Declare @cFil_ALA    Char( 02 )
Declare @cFilial     Char( 02 )
Declare @cFilAnt     Char( 02 )
Declare @cAKD_TIPO   Char( 01 )
Declare @cAKD_DATA   Char( 08 )
Declare @cDataAnt    Char( 08 )
Declare @cAKD_CO     Char( 'AKT_TPSALD' )
Declare @cAKD_CC     Char( 'AKT_CC' )
-- mais campos a serem criados run time
Declare @cAKD_TPSALD Char( 'AKT_TPSALD' )
Declare @nAKD_VALOR1 Float
Declare @nAKD_VALOR2 Float
Declare @nAKD_VALOR3 Float
Declare @nAKD_VALOR4 Float
Declare @nAKD_VALOR5 Float
Declare @nTotDEB1    Float
Declare @nTotDEB2    Float
Declare @nTotDEB3    Float
Declare @nTotDEB4    Float
Declare @nTotDEB5    Float
Declare @nTotCRD1    Float
Declare @nTotCRD2    Float
Declare @nTotCRD3    Float
Declare @nTotCRD4    Float
Declare @nTotCRD5    Float
Declare @nValorD1    Float
Declare @nValorD2    Float
Declare @nValorD3    Float
Declare @nValorD4    Float
Declare @nValorD5    Float
Declare @nValorC1    Float
Declare @nValorC2    Float
Declare @nValorC3    Float
Declare @nValorC4    Float
Declare @nValorC5    Float
Declare @cDataDiario VarChar( 08 )
Declare @cChaveAKT   Char( 'AL1_CHAVER' )
Declare @cChaveR     Char( 'AL1_CHAVER' )
Declare @cChave      Char( 'AL1_CHAVER' )
Declare @cChave1     Char( 'AL1_CHAVER' )
Declare @lAtuAKT Char( 01 )

Begin
   select @OUT_RESULT  = '0'
   select @nTotDEB1 = 0, @nTotDEB2 = 0, @nTotDEB3 = 0, @nTotDEB4 = 0, @nTotDEB5 = 0
   select @nTotCRD1 = 0, @nTotCRD2 = 0, @nTotCRD3 = 0, @nTotCRD4 = 0, @nTotCRD5 = 0
   select @cDataDiario = ''
   select @cChaveAKT   = ''
   select @cChaveR     = ''
   select @cChave      = ''
   select @cChave1     = ''
   select @nValorD1    = 0
   select @nValorD2    = 0
   select @nValorD3    = 0
   select @nValorD4    = 0
   select @nValorD5    = 0
   select @nValorC1    = 0
   select @nValorC2    = 0
   select @nValorC3    = 0
   select @nValorC4    = 0
   select @nValorC5    = 0
   select @lAtuAKT     = '0'
   select @cFilAnt     = '0'
   select @cDataAnt    = '0'
   select @cAKD_COAnt  = '' 
   select @cAKD_CCAnt  = '' 
   select @cAKD_TPSALDAnt  = '' 
    --------------------------------------------------------------
      Recuperando Filiais
      -------------------------------------------------------------- 
   select @cAux = 'AKD'
   EXEC XFILIAL_## @cAux, @IN_FILIAL, @cFil_AKD OutPut
   select @cAux = 'ALA'
   EXEC XFILIAL_## @cAux, @IN_FILIAL, @cFil_ALA OutPut
    ----------------------------------------------------------------------------
      Inicia a exclus„o de slds diarios AKT para reprocessamento
      ---------------------------------------------------------------------------- 
   EXEC PCOA300F_## @IN_FILIAL, @IN_CONFIG, @IN_DATAI, @IN_DATAF, @IN_FK
    --------------------------------------------------------------
      3 - Inicia o Reprocessamento no range informado
		Trazer o AKD agrupado por data e pela chave do cubo
      -------------------------------------------------------------- 
   Declare CUR_PCO300 insensitive cursor for      --- AL1->AL1_CHAVER, cQuery	+=	cCampos+" , "    //campos do cubo gerencial   
	Select AKD_FILIAL, AKD_TIPO, AKD_DATA, AKD_CO, AKD_CC, AKD_TPSALD, SUM(AKD_VALOR1), SUM(AKD_VALOR2), SUM(AKD_VALOR3), SUM(AKD_VALOR4), SUM(AKD_VALOR5)
     from AKD###
    where AKD_FILIAL = @cFil_AKD
		and AKD_DATA Between @IN_DATAI and @IN_DATAF
		and AKD_STATUS = '1'
      and AKD_TIPO IN ( '1', '2' )
		and D_E_L_E_T_ = ' '
      and R_E_C_N_O_ NOT IN ( Select ALA_RECAKD 
                                from ALA###
                               where ALA_FILIAL = @cFil_ALA
                                 and ALA_STATUS = '1'
                                 and D_E_L_E_T_ = ' ' )
		group by AKD_FILIAL, AKD_TIPO, AKD_DATA, AKD_CO, AKD_CC, AKD_TPSALD
   	order by AKD_DATA, AKD_CO, AKD_CC, AKD_TPSALD
   for read only
   Open CUR_PCO300
   Fetch CUR_PCO300 into @cFilial, @cAKD_TIPO, @cAKD_DATA,@cAKD_CO, @cAKD_CC, @cAKD_TPSALD, @nAKD_VALOR1, @nAKD_VALOR2, @nAKD_VALOR3, @nAKD_VALOR4, @nAKD_VALOR5
   While (@@Fetch_status = 0 ) begin
       --------------------------------------------------------------
         Inicia o Atualizacao do AKT p/ cada um dos niveis Conta, CC
         --------------------------------------------------------------
      If @lAtuAKT = '1' begin
         --------------------------------------------------------------
            Atualizo a analitica somente uma vez para oprimeiro nivel
            --------------------------------------------------------------
         EXEC PCOA300B_## @cFilAnt,  @IN_CONFIG, @cDataAnt, @cChaveR, @nValorD1,  @nValorD2,  @nValorD3,    @nValorD4,      @nValorD5,
                          @nValorC1, @nValorC2,  @nValorC3, @nValorC4, @nValorC5, @cAKD_COAnt, @cAKD_CCAnt, @cAKD_TPSALDAnt
         If @lAtuSup ='1' begin
	         EXEC PCOA300A @cFilAnt,  @IN_CONFIG, @cDataAnt, @nValorD1, @nValorD2, @nValorD3, @nValorD4, @nValorD5,
                          @nValorC1, @nValorC2,  @nValorC3,  @nValorC4, @nValorC5, @cAKD_COAnt, @cAKD_CCAnt, @cAKD_TPSALDAnt
         End
         select @nValorC1 = 0, @nValorC2 = 0, @nValorC3 = 0, @nValorC4 = 0, @nValorC5 = 0
         select @nValorD1 = 0, @nValorD2 = 0, @nValorD3 = 0, @nValorD4 = 0, @nValorD5 = 0
         select @lAtuAKT = '0'
      End
       --------------------------------------------------------------
         Vars para atualizacao do AKT
         -------------------------------------------------------------- 
      If @cAKD_TIPO = '1' begin
         select @nValorC1 = @nAKD_VALOR1
         select @nValorC2 = @nAKD_VALOR2
         select @nValorC3 = @nAKD_VALOR3
         select @nValorC4 = @nAKD_VALOR4
         select @nValorC5 = @nAKD_VALOR5
      end else begin
         select @nValorD1 = @nAKD_VALOR1
         select @nValorD2 = @nAKD_VALOR2
         select @nValorD3 = @nAKD_VALOR3
         select @nValorD4 = @nAKD_VALOR4
         select @nValorD5 = @nAKD_VALOR5
      end
      Select @cDataDiario = SubsTring(@cAKD_DATA,1,6)
      select @cChaveAKT = @cFilial||@cAKD_DATA||@cAKD_CO||@cAKD_CC||@cAKD_TPSALD
      select @cChaveR   = @cAKD_CO||@cAKD_CC||@cAKD_TPSALD
      select @cFilAnt  = @cFilial
      select @cDataAnt = @cAKD_DATA
      select @cAKD_COAnt  = @cAKD_CO 
      select @cAKD_CCAnt  = @cAKD_CC 
      select @cAKD_TPSALDAnt  = @cAKD_TPSALD 
      Fetch CUR_PCO300 into @cFilial, @cAKD_TIPO, @cAKD_DATA, @cAKD_CO, @cAKD_CC, @cAKD_TPSALD, @nAKD_VALOR1, @nAKD_VALOR2, @nAKD_VALOR3, @nAKD_VALOR4,
                             @nAKD_VALOR5
      select @cChave  = @cFilial||@cAKD_DATA||@cAKD_CO||@cAKD_CC||@cAKD_TPSALD
      select @cChave1 = @cFilial||@cAKD_CO||@cAKD_CC||@cAKD_TPSALD
      If @@fetch_status = -1 begin
         select @cChave  = ' '
         select @cChave1 = ' '
      End
       -----------------------------------------------------------------
         Atualiza @lAtuAKT com '1' para efetuar a gravavao do AKT
         ----------------------------------------------------------------- 
      If @cChave != @cChaveAKT begin
         select @lAtuAKT = '1'
      End
   End
   If @lAtuAKT = '1' begin
      EXEC PCOA300B_## @cFilAnt,  @IN_CONFIG, @cDataAnt, @cChaveR, @nValorD1,  @nValorD2,  @nValorD3,    @nValorD4,      @nValorD5,
                       @nValorC1, @nValorC2,  @nValorC3, @nValorC4, @nValorC5, @cAKD_COAnt, @cAKD_CCAnt, @cAKD_TPSALDAnt
       ---------------------------------------------------------------------------------------------------------------------
         Essa procedure sera criada somente se a atualizacao das superiores for solicitada
         --------------------------------------------------------------------------------------------------------------------- 
   	   EXEC PCOA300A_## @cFilAnt,  @IN_CONFIG, @cDataAnt, @nValorD1, @nValorD2, @nValorD3, @nValorD4, @nValorD5,
   	                    @nValorC1, @nValorC2,  @nValorC3,  @nValorC4, @nValorC5, @cAKD_COAnt, @cAKD_CCAnt, @cAKD_TPSALDAnt
   End
   close CUR_PCO300
   deallocate CUR_PCO300
   select @OUT_RESULT  = '1'
End
*/


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥CallXFilial∫Autor  ≥Microsiga           ∫ Data ≥  04/24/13  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Func„o que monta a procedure para retornar xFilial          ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ PCOA300 e PCOA301                                          ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

/* --------------------------------------------------------------------
Funcao xFilial para uso dentro do corpo das procedures dinamicas do PCO
Recebe como parametro as strings das variaveis da procedure a serem
utilizadas : Alias, Filial atual ou default, e filial de retorno
Retorna o corpo da xfilial a ser executado.
OUTRA OBSERVACAO : Deu erro no AS400 , nao sabemos por que. Reclama de passagem de valores null como parametro.
Nao achamos onde era, e trocamos pela query direta. Funciona, sem erro, e torna esse programa 
totalmente independente da aplicacao de procedures do padrao.
-------------------------------------------------------------------- */

Function CallXFilial( cArq )
Local aSaveArea := GetArea()
Local cProc   := cArq+"_"+cEmpAnt
Local cQuery  := ""
Local lRet    := .T.
Local aCampos := CT2->(DbStruct())
Local nPos    := 0
Local cTipo   := ""

cQuery :="Create procedure "+cProc+CRLF
cQuery +="( "+CRLF
cQuery +="  @IN_ALIAS        Char(03),"+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_FILIAL" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery +="  @IN_FILIALCOR    "+cTipo+","+CRLF
cQuery +="  @OUT_FILIAL      "+cTipo+" OutPut"+CRLF
cQuery +=")"+CRLF
cQuery +="as"+CRLF

/* -------------------------------------------------------------------
    Vers„o      -  <v> GenÈrica </v>
    Assinatura  -  <a> 010 </a>
    Descricao   -  <d> Retorno o modo de acesso da tabela em questao </d>

    Entrada     -  <ri> @IN_ALIAS        - Tabela a ser verificada
                        @IN_FILIALCOR    - Filial corrente </ri>

    Saida       -  <ro> @OUT_FILIAL      - retorna a filial a ser utilizada </ro>
                   <o> brancos para modo compartilhado @IN_FILIALCOR para modo exclusivo </o>

    Responsavel :  <r> Alice Yaeko </r>
    Data        :  <dt> 14/12/10 </dt>
   
   X2_CHAVE X2_MODO X2_MODOUN X2_MODOEMP X2_TAMFIL X2_TAMUN X2_TAMEMP
   -------- ------- --------- ---------- --------- -------- ---------
   CT2      E       E         E          3.0       3.0        2.0       
      X2_CHAVE   - Tabela
      X2_MODO    - Comparti/o da Filial, 'E' exclusivo e 'C' compartilhado
      X2_MODOUN  - Comparti/o da Unidade de NegÛcio, 'E' exclusivo e 'C' compartilhado
      X2_MODOEMP - Comparti/o da Empresa, 'E' exclusivo e 'C' compartilhado
      X2_TAMFIL  - Tamanho da Filial
      X2_TAMUN   - Tamanho da Unidade de Negocio
      X2_TAMEMP  - tamanho da Empresa
   
   Existe hierarquia no compartilhamento das entidades filial, uni// de negocio e empresa.
   Se a Empresa for compartilhada as demais entidades DEVEM ser compartilhadas
   Compartilhamentos e tamanhos possÌveis
   compartilhaemnto         tamanho ( zero ou nao zero)
   EMP UNI FIL             EMP UNI FIL
   --- --- ---             --- --- ---
    C   C   C               0   0   X   -- 1 - somente filial
    E   C   C               0   X   X   -- 2 - filial e unidade de negocio
    E   E   C               X   0   X   -- 3 - empresa e filial
    E   E   E               X   X   X   -- 4 - empresa, unidade de negocio e filial
------------------------------------------------------------------- */
cQuery +="Declare @cModo    Char( 01 )"+CRLF
cQuery +="Declare @cModoUn  Char( 01 )"+CRLF
cQuery +="Declare @cModoEmp Char( 01 )"+CRLF
cQuery +="Declare @iTamFil  Integer"+CRLF
cQuery +="Declare @iTamUn   Integer"+CRLF
cQuery +="Declare @iTamEmp  Integer"+CRLF

cQuery +="begin"+CRLF
  
cQuery +="  Select @OUT_FILIAL = ' '"+CRLF
cQuery +="  Select @cModo = ' ', @cModoUn = ' ', @cModoEmp = ' '"+CRLF
cQuery +="  Select @iTamFil = 0, @iTamUn = 0, @iTamEmp = 0"+CRLF
  
cQuery +="  Select @cModo = X2_MODO,   @cModoUn = X2_MODOUN, @cModoEmp = X2_MODOEMP,"+CRLF
cQuery +="         @iTamFil = X2_TAMFIL, @iTamUn = X2_TAMUN, @iTamEmp = X2_TAMEMP"+CRLF
cQuery +="    From SX2"+cEmpAnt+"0 "+CRLF
cQuery +="   Where X2_CHAVE = @IN_ALIAS"+CRLF
cQuery +="     and D_E_L_E_T_ = ' '"+CRLF
  
  /*   SITUACAO -> 1 somente FILIAL */
cQuery +="  If ( @iTamEmp = 0 and @iTamUn = 0 and @iTamFil >= 2 ) begin"+CRLF   //  -- so tem filial tam 2
cQuery +="    If @cModo = 'C' select @OUT_FILIAL = '  '"+CRLF
cQuery +="    else select @OUT_FILIAL = @IN_FILIALCOR"+CRLF
cQuery +="  end else begin"+CRLF
    /*  SITUACAO -> 2 UNIDADE DE NEGOCIO e FILIAL  */
cQuery +="    If @iTamEmp = 0 begin"+CRLF
cQuery +="      If @cModoUn = 'E' begin"+CRLF
cQuery +="        If @cModo = 'E' select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamUn)||Substring( @IN_FILIALCOR, @iTamUn + 1, @iTamFil )"+CRLF
cQuery +="        else select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamUn)"+CRLF
cQuery +="      end"+CRLF
cQuery +="    end else begin"+CRLF
      /* SITUACAO -> 4 EMPRESA, UNIDADE DE NEGOCIO e FILIAL */
cQuery +="      If @iTamUn > 0 begin"+CRLF
cQuery +="        If @cModoEmp = 'E' begin"+CRLF
cQuery +="          If @cModoUn = 'E' begin"+CRLF
cQuery +="            If @cModo = 'E' select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamEmp)||Substring(@IN_FILIALCOR, @iTamEmp+1, @iTamUn)||Substring( @IN_FILIALCOR, @iTamEmp+@iTamUn + 1, @iTamFil )"+CRLF
cQuery +="            else select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamEmp)||Substring(@IN_FILIALCOR, @iTamEmp+1, @iTamUn)"+CRLF
cQuery +="          end else begin"+CRLF
cQuery +="            select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamEmp)"+CRLF
cQuery +="          end"+CRLF
cQuery +="        end"+CRLF
cQuery +="      end else begin"+CRLF
        /*  SITUACAO -> 3 EMPRESA e FILIAL */
cQuery +="        If @cModoEmp = 'E' begin"+CRLF
cQuery +="          If @cModo = 'E' select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamEmp)||Substring( @IN_FILIALCOR, @iTamEmp+1, @iTamFil )"+CRLF
cQuery +="          else select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamEmp)"+CRLF
cQuery +="        end"+CRLF
cQuery +="      end"+CRLF
cQuery +="    end"+CRLF
cQuery +="  end"+CRLF
cQuery +="end"+CRLF

cQuery := MsParse( cQuery, If( Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB()) ) )
cQuery := CtbAjustaP(.F., cQuery, 0)

If Empty( cQuery )
	MsgAlert(MsParseError(),STR0027+cProc)  //'A query da filial nao passou pelo Parse '
	lRet := .F.
Else
	If !TCSPExist( cProc )
		cRet := TcSqlExec(cQuery)
		If cRet <> 0
			If !__lBlind
				MsgAlert(STR0028+cProc)  //"Erro na criacao da proc filial: "
				lRet:= .F.
			EndIf
		EndIf
	EndIf
EndIf
RestArea(aSaveArea)

Return(lRet)  


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥P300CallProc∫Autor  ≥Microsiga           ∫ Data ≥  04/24/13   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Func„o responsavel pela chamada das procedures.               ∫±±
±±∫          ≥                                                              ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ PCOA300 e PCOA301                                            ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Function P300CallProc(aNivel, dDataIni, dDataFim, cTpSld )
            
Local cArqTemp 	:= "" 
Local nProx 	:= 1
Local aProc   	:= {}
Local aProcAKT	:= {}  // Tantos qtos forem os n'iveis do CUbo
Local cArqTrb
Local cArq  	:= ""
Local lRet		:= .T.
Local aResult	:= {}
Local cExec  	:= ""
Local cRet   	:= ""
Local iX      	:= 0
Default cTpSld  := ""  // array com os tipos de saldo a atualizar

/*   Ordem de chamada das procedures - Ordem de criacao de procedures aproc[1],..,aproc[10]
  **  0.1.A300LastDay  - Retorna o ultimo dia do Mes .LASTDAY.................... 1  aProc[1]
  **  0.2.CallXFilial  - Xfilial ................................................ 2  aProc[2]
   				
  	
   1.PCOA300 - Procedure pai .................................................... 6  aProc[6]
	1.2.PCOA300F -       Exclusao do AKT do periodo ............................. 4  aProc[4]
   	1.3. PCOA300A -      Atualiza os slds sintÈticos do AKT ..................... 5  aProc[5]
		1.3.1.PCOA300B - Atualiza a analitica do AKT ............................ 3  aProc[3]
  			    
  			    
/*	Variaveis
	aNivel[n][1] - Alias do Nivel, CTT, AK5
	aNivel[n][2] - SC00872635 - Temporario com o nivel analitico e sinteticos 
    cArq         - nome de todas as procedures a serem criadas
    nProx        - Compoe junto com cArq os nomes das procedures a serem criadas
    o NOME das procedures sera com se segue descrito
    SC99999901_XX
	|		  |  ¿> XX -> empresa onde foi criada a procedure -cEmpAnt
  	|         ¿> 01 Nro da procedure
    ¿---------> NOme gerado pelo criatrab    */
 
cArqTrb := CriaTrab(,.F.)
cArq    := cArqTRB+StrZero(nProx,2)+"_"+AL1->AL1_CONFIG
AADD( aProc, cArq+"_"+cEmpAnt)
lRet    := A300LastDay( cArq )   // A300LastDay aProc[1]

If lRet
	nProx   := nProx + 1
	cArq    := cArqTRB+StrZero(nProx,2)+"_"+AL1->AL1_CONFIG
	cArqAKT := cArq
	AADD( aProc, cArq+"_"+cEmpAnt)
	lRet    := CallXFilial( cArq )  // CallXfilial aProc[2]
EndIf                           
If lRet
	/*Cria Procedure de atualizacao do AKT, cArq
	  cArq = SC999901  Nome da procedure */
	nProx := nProx + 1
	cArq    := cArqTRB+StrZero(nProx,2)+"_"+AL1->AL1_CONFIG
	cArqAKT := cArq
	AADD( aProc, cArq+"_"+cEmpAnt)           // PCOA300B  aProc[3]
	lRet    := PCOA300B(AL1->AL1_CONFIG, cArq, aProc)
EndIf
If lRet
	//Cria Procedure que exclui dados do AKT
	nProx:= nProx+1
	cArq := cArqTrb+StrZero(nProx,2)+"_"+AL1->AL1_CONFIG
	AADD( aProc, cArq+"_"+cEmpAnt)           // PCOA300F   aProc[4]
  	lRet:=PCOA300F(AL1->AL1_CONFIG, cArq, aProc, cTpSld )
EndIf
If lRet
	//Cria Procedure que faz chamada das atualizacoes de saldo no AKT
	nProx:= nProx+1
	cArq := cArqTrb+StrZero(nProx,2)+"_"+AL1->AL1_CONFIG
	AADD( aProc, cArq+"_"+cEmpAnt)
	lRet := PCOA300A(AL1->AL1_CONFIG, aNivel, cArq, cArqAKT, @aProcAKT )   //  PCOA300A  aproc[5]
EndIf
If lRet
	//Cria Procedure que faz chamada das atualizacoes de saldo no AKT
	nProx:= nProx+1
	cArq := cArqTrb+StrZero(nProx,2)+"_"+AL1->AL1_CONFIG
	AADD( aProc, cArq+"_"+cEmpAnt)
	lRet := PCOA300Proc( AL1->AL1_CONFIG, aNivel, cArq, aProc, aProcAKT, cTpSld )   //  aProc[6]
EndIf
If lRet
	ConoutR("===========================")
	conoutR( Time())
	ConoutR( " Inicio Cubo: "+AL1->AL1_CONFIG)
	aResult := TCSPExec( xProcedures(cArq), cFilAnt, AL1->AL1_CONFIG, Dtos(dDataIni), Dtos(dDataFim), If(__lFKInUse, "1", "0"))
	TcRefresh(RetSqlName("AKT"))
	If Empty(aResult) .Or. aResult[1] = "0"
		MsgAlert(tcsqlerror(),STR0029+ AL1->AL1_CONFIG)  //"Erro no Reprocessamento de Cubos! - Cubo: "
		lRet := .F.	
	EndIf
	ConoutR( " Fim Cubo: "+AL1->AL1_CONFIG)
	conoutR( Time())
	ConoutR("---------------------------")
EndIf
/* Procedures e tabelas a 'Dropar'
   Procedures - aProc[1],.., aProc[8] = Ordem de chamadas de procedures
			       aProcAKT[1],..,aProcAKT[n] = procedures de atual. Saldos do AKT para cada Nivel do Cubo
	             
	 Tabelas   - aNivel[1][1],..aNivel[n][2]= tabela temporaria com as sinteticas p todos os niveis do cubo
					 cArqTemp
*/
For iX = 1 to Len(aProc)   // exclusao de aProc
	If TCSPExist(aProc[iX])
		cExec := "Drop procedure "+aProc[iX]
		cRet := TcSqlExec(cExec)
		If cRet <> 0
			MsgAlert("Erro na exclusao da Procedure: "+aProc[iX] +". Excluir manualmente no banco")
		Endif
	EndIf
Next iX
For ix := 1 to Len(aProcAKT)    // exclusao de aProcAKT
	If TCSPExist(aProcAKT[iX])
		cExec := "Drop procedure "+aProcAKT[iX]
		cRet := TcSqlExec(cExec)
		If cRet <> 0
			MsgAlert("Erro na exclusao da Procedure: "+aProcAKT[iX] +". Excluir manualmente no banco")
		Endif
	EndIf
Next iX
If TcCanOpen(cArqTemp)   // exclusao de cArqTemp 
	If !TcDelFile(cArqTemp)
		MsgAlert("Erro na exclusao da Tabela: "+cArqTemp+". Excluir manualmente")
	Endif
EndIf

Return lRet
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥ A300ChkCub ∫ Autor ≥ Paulo Carnelossi ∫ Data ≥  06/07/16   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Funcao para conferencia dos saldos dos cubos               ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ PCOA300 - Planejamento e Controle Orcamentario             ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Function A300ChkCub(cCuboIni, cCuboFim, lHelp)
Local aArea := GetArea()
Local lRet := .T.
Local cQuery := ""
Local nCredito := 0
Local nDebito := 0

Default cCuboIni := Space(Len(AL1->AL1_CONFIG))
Default cCuboFim := Replicate("z", Len(AL1->AL1_CONFIG))
Default lHelp := .T.

//soma os creditos da tabela AKD-Movimentos OrÁamentarios
cQuery := " SELECT SUM(AKD_VALOR1) CREDITO FROM  "+RetSqlName("AKD")
cQuery += " WHERE AKD_FILIAL = '"+xFilial("AKD")+"' AND AKD_TIPO = '1'  AND AKD_STATUS = '1' AND D_E_L_E_T_ = ' ' "
cQuery	:=	ChangeQuery(cQuery)				
dbUseArea( .T., "TopConn", TCGenQry(,,cQuery),"QRYCHK", .F., .F. )
If QRYCHK->( !Eof() )
	nCredito :=	QRYCHK->CREDITO
Endif
dbSelectArea("QRYCHK")
dbCloseArea()
 
//soma os debitos da tabela AKD-Movimentos OrÁamentarios
cQuery := " SELECT SUM(AKD_VALOR1) DEBITO FROM "+RetSqlName("AKD")
cQuery += " WHERE AKD_FILIAL = '"+xFilial("AKD")+"' AND AKD_TIPO = '2' AND AKD_STATUS = '1' AND D_E_L_E_T_ = ' ' "
cQuery	:=	ChangeQuery(cQuery)				
dbUseArea( .T., "TopConn", TCGenQry(,,cQuery),"QRYCHK", .F., .F. )
If QRYCHK->( !Eof() )
	nDebito  :=	QRYCHK->DEBITO
Endif
dbSelectArea("QRYCHK")
dbCloseArea()

dbSelectArea("AL1")
dbSetOrder(1)
dbSeek( xFilial("AL1")+Alltrim(cCuboIni) )

//laco na tabela AL1 - Cubos
While AL1->( !Eof() .And. AL1_FILIAL == xFilial("AL1") .And. AL1_CONFIG <= cCuboFim )

	//soma os creditos e debitos na tabela de saldos diario
	cQuery := " SELECT  SUM(AKT_MVCRD1) CREDITO, SUM(AKT_MVDEB1) DEBITO FROM "+RetSqlName("AKT")
	cQuery += " WHERE AKT_FILIAL = '"+xFilial("AKT")+"' AND AKT_CONFIG='"+AL1->AL1_CONFIG+"' "
	cQuery += " AND AKT_ANALIT = '1' AND D_E_L_E_T_ = ' ' " 

	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery),"QRYCHK", .F., .F. )

	If Round(nDebito,2) != Round(QRYCHK->DEBITO,2) .OR. Round(nCredito,2) != Round(QRYCHK->CREDITO,2)
		if lHelp
			Help(" ",1,"PCOA300CB",,"Cubo "+AL1->AL1_CONFIG+" inconsistente, favor reprocessar. ",1,0) 
		EndIf
		lRet := .F.
	EndIf 

	dbSelectArea("QRYCHK")
	dbCloseArea()

	If ! lRet
		Exit  //se retornou falso sai do laco
	EndIf

	AL1->( dbSkip() )

EndDo

RestArea(aArea)

If lRet
	ConoutR(STR0030) //"Verificado saldos das contas analiticas e os cubos foram processados com sucesso. "
EndIf

if lRet .And. lHelp
	Help(" ",1,"PCOA300CB",,STR0030,1,0)  //"Verificado saldos das contas analiticas e os cubos foram processados com sucesso. " 
EndIf

Return(lRet)
