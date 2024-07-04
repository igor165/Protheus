#INCLUDE "plsm180.ch"
#include "PLSMGER.CH"
#INCLUDE "APWEBEX.CH"
#INCLUDE "PROTHEUS.CH"
  
static aCpVrInfo := LancFtCpo(1) // Info de valores de co-participacao
static aTpVrInfo := LancFtCpo(2) // Info de valores de taxa-copart
static aCoVrInfo := LancFtCpo(3) // Info de valores de custo operacional
static aToVrInfo := LancFtCpo(4) // Info de valores de taxa-custo
static lUnimed	:= .F.

/*/{Protheus.doc} PLSM180
consolidacao
@type function
@author plsteam
@since 15.08.2002
@version 1.0
/*/                                                                
Function PLSM180(lAutoma)
LOCAL cPerg     := "PLS180    "
LOCAL cCadastro := STR0001 //"Consolidacao dos valores de custo operacional x fator modernador"
Default lAutoma := .F.

If PLVLDBLQCO(dDataBase, {"PLS004"}, .T.) //se a data do sistema esta no periodo bloqueado pela contabilidade, não pode executar a ação
	Iif(!lAutoma, tNewProcess():New("PLSM180",cCadastro,{|oSelf| PLSM180Pro(cPerg,oSelf)},STR0001,cPerg,,.F.,,,.t.,.f. ), "")
EndIf

Return

/*/{Protheus.doc} PLSM180Pro

@type function
@author plsteam
@since 15.08.2002
@version 1.0
/*/
Function PLSM180Pro(cPerg, oSelf, lAutoma)
LOCAL cCodOpe	:= ""
LOCAL cCodEmpDe	:= ""
LOCAL cCodEmpAte:= ""
LOCAL cAnoRef	:= ""
LOCAL cMesRef	:= ""
LOCAL cAno	    := ""
LOCAL cMes	    := ""
LOCAL cLocDe	:= ""
LOCAL cLocAte	:= ""
LOCAL cTipPre	:= ""
LOCAL cAlias	:= ""
LOCAL aAnoMes  	:= {}
LOCAL nFor      := 0
LOCAL cAux  	:= ""
LOCAL cSQL2	    := ""
LOCAL cSQL      := ""
LOCAL aRDA      := {}
LOCAL dDatAte   := stod("")
LOCAL aErro     := {}
LOCAL cMatDe    := ""
LOCAL cMatAte   := ""
LOCAL nVlrMax   := 0
LOCAL nVlrAcum  := 0            
LOCAL nVlrBack  := 0            
LOCAL cContrDe  := ""
LOCAL cContrAte := ""
LOCAL cSubconDe := ""
LOCAL cSubconAte:= ""
LOCAL l180Ac 	:= ExistBlock("PLS180AC")
LOCAL aGuiasOK  := {}
LOCAL nTotReg	:= 0
LOCAL cChaveNot	:= ""
LOCAL lGuiaValid:= .T.
LOCAL aGuiasNAO := {}
LOCAL nQtd      := 0
LOCAL nDiasSrvPrt 	:= GetNewPar("MV_PLDIAPZ",150) 
LOCAL xFilialBD5  	:= xFilial("BD5")
LOCAL xFilialBE4  	:= xFilial("BE4")
LOCAL xFilialBAU  	:= xFilial("BAU")
LOCAL cMV_PLSCGIN 	:= GetNewPar("MV_PLSCGIN","1")
LOCAL cMV_PLSTPIN 	:= GetNewPar("MV_PLSTPIN","OPE")
LOCAL lB80Field   	:= PLSALIASEX("B80") .and. B80->(FieldPos('B80_ANOBAS')) > 0 .and. B80->(FieldPos('B80_MESBAS')) > 0
LOCAL lConsol     	:= GetNewPar("MV_PCONINT",.F.)
LOCAL lPls180In	 	:= .T. // Retorno do ponto de entrada PLS180IN
LOCAL lPLS180Del	:= ExistBlock("PLS180Del")
LOCAL lPE180Del		:= .T.         
LOCAL MV_FRQUIA 	:= GETNEWPAR("MV_FRQUIA",.F.)

Default lAutoma     := .F.

lUnimed := GetNewPar("MV_PLSUNI", "0") == "1"

BAU->(DbSetOrder(1))
BD5->(DbSetorder(1))
BE4->(DbSetorder(1))

//Busca dados dos parametros...               
Iif(!lAutoma, Pergunte(cPerg,.F.), "")

cCodOpe    := mv_par01
cCodEmpDe  := mv_par02
cCodEmpAte := mv_par03
cAnoRef    := mv_par04
cMesRef    := mv_par05
cLocDe     := mv_par06
cLocAte    := mv_par07
cTipPre    := mv_par08
dDatAte    := mv_par09
cMatDe     := mv_par10
cMatAte    := mv_par11
nVlrMax    := mv_par12
cContrDe   := mv_par13
cContrAte  := mv_par14
cSubconDe  := mv_par15
cSubconAte := mv_par16
cRetro150  := mv_par17

//Fábio Consentino - Custom - 19/02/16
//Ponto de entrada antes de iniciar o processamento
If ExistBlock("PLS180IN")
	
	lPls180In := ExecBlock("PLS180IN",.F.,.F.,{cCodOpe,cCodEmpDe,cCodEmpAte,cAnoRef,cMesRef,cLocDe,cLocAte,cTipPre,dDatAte,cMatDe,cMatAte,nVlrMax,cContrDe,cContrAte,cSubconDe,cSubconAte,cRetro150})
	
	//Valida se o processo de consolidação pode continuar.
	If ValType(lPls180In) == "L" .and. !lPls180In
		return Nil
	EndIf
	
endIf	

if findFunction("PLSID33") .and. MV_FRQUIA 
	PLSID33(Nil, Nil, {cCodOpe, cCodEmpDe, cCodEmpAte, cAnoRef, cMesRef, cLocDe, cLocAte, cTipPre, dDatAte, cMatDe, cMatAte, cContrDe, cContrAte, cSubconDe, cSubconAte} )
endif

aadd(aAnoMes,{cAnoRef,cMesRef})

cAux := PLSDIMAM(cAnoRef,cMesReF,"0")
aadd(aAnoMes,{Subs(cAux,1,4),Subs(cAux,5,2)})

cAux := PLSDIMAM(Subs(cAux,1,4),Subs(cAux,5,2),"0")
aadd(aAnoMes,{Subs(cAux,1,4),Subs(cAux,5,2)})

cAux := PLSDIMAM(Subs(cAux,1,4),Subs(cAux,5,2),"0")
aadd(aAnoMes,{Subs(cAux,1,4),Subs(cAux,5,2)})

cAux := PLSDIMAM(Subs(cAux,1,4),Subs(cAux,5,2),"0")
aadd(aAnoMes,{Subs(cAux,1,4),Subs(cAux,5,2)})
    
cAux := PLSDIMAM(Subs(cAux,1,4),Subs(cAux,5,2),"0")
aadd(aAnoMes,{Subs(cAux,1,4),Subs(cAux,5,2)})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Conta a qtde das  empresas parametrizados...                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL := "SELECT Count(1) QTD FROM "+RetSQLName("BG9")+" WHERE "
cSQL += "BG9_FILIAL = '"+xFilial("BG9")+"' AND "
cSQL += "BG9_CODINT = '"+cCodOpe+"' AND "
cSQL += "BG9_CODIGO >= '"+cCodEmpDe+"' AND "
cSQL += "BG9_CODIGO <= '"+cCodEmpAte+"' AND "
cSQL += "D_E_L_E_T_ = ' ' "

OPEN QUERY cSQL ALIAS "Trb"

nQtd := Trb->QTD

CLOSE QUERY "Trb"

Iif(!lAutoma,oSelf:SetRegua1(nQtd),"")

cSQL := "SELECT BG9_CODINT,BG9_CODIGO, BG9_DESCRI FROM "+RetSQLName("BG9")+" WHERE "
cSQL += "BG9_FILIAL = '"+xFilial("BG9")+"' AND "
cSQL += "BG9_CODINT = '"+cCodOpe+"' AND "
cSQL += "BG9_CODIGO >= '"+cCodEmpDe+"' AND "
cSQL += "BG9_CODIGO <= '"+cCodEmpAte+"' AND "
cSQL += "D_E_L_E_T_  = ' ' "

OPEN QUERY cSQL ALIAS "Trb"

While ! Trb->(Eof())

	If !lAutoma
		If oSelf:lEnd
			Exit
		EndIf
	EndIf
	
	Iif(!lAutoma, oSelf:IncRegua1(Trb->BG9_CODIGO +" - "+Trb->BG9_DESCRI), "")

	For nFor := 1 To Len(aAnoMes)
		cAno := aAnoMes[nFor,1]
		cMes := aAnoMes[nFor,2]
		
		BD6->(DbSetOrder(9))//BD6_FILIAL + BD6_OPEUSR + BD6_CODEMP + BD6_ANOPAG + BD6_MESPAG + BD6_CONEMP + BD6_VERCON + BD6_SUBCON + BD6_VERSUB
		If !BD6->(MsSeek(xFilial("BD6")+Trb->(BG9_CODINT+BG9_CODIGO)+cAno+cMes))
			loop
		endIf 

		//Excluo todos os BDH em aberto para esssa empresa no ano/mes...      
		BDH->(DbSetOrder(6))//BDH_FILIAL, BDH_CODINT, BDH_CODEMP, BDH_ANOFT, BDH_MESFT, BDH_STATUS
		If BDH->(MsSeek(xFilial("BDH")+Trb->(BG9_CODINT+BG9_CODIGO)+cAno+cMes+"1"))
			
			While ! BDH->(Eof()) .And. BDH->(BDH_FILIAL+BDH_CODINT+BDH_CODEMP+BDH_ANOFT+BDH_MESFT+BDH_STATUS) == xFilial("BDH")+Trb->(BG9_CODINT+BG9_CODIGO)+cAno+cMes+"1"

				BA1->(DbSetOrder(2))
				If BA1->(MsSeek(xFilial("BA1")+BDH->(BDH_CODINT+BDH_CODEMP+BDH_MATRIC+BDH_TIPREG)))
					If  !(BA1->BA1_CONEMP >= cContrDe .And. BA1->BA1_CONEMP <= cContrAte .And. BA1->BA1_SUBCON >= cSubconDe .And. BA1->BA1_SUBCON <= cSubconAte)
						BDH->(DbSkip())
						loop
					Endif
				Endif
				
				if lPLS180Del	
					lPE180Del := ExecBlock("PLS180Del",.F.,.F.)					
				endIf
				
				If lPE180Del .and. BDH->BDH_CODEMP >= cCodEmpDe .And. BDH->BDH_CODEMP <= cCodEmpAte .And. BDH->BDH_MATRIC >= cMatDe .And. BDH->BDH_MATRIC <= cMatAte 
					
					PLSM180Del() //limpa seqpf a partir de um bdh
					
					If lB80Field// Limpa o parcelamento
						PLSM180PAR(lAutoma) 
					EndIf
					
					BDH->(RecLock("BDH",.F.))
						BDH->(DbDelete())
					BDH->(MsUnLock())
				Endif
				
			BDH->(DbSkip())
			Enddo
			
		Endif
		
		cSQL3 := " SELECT R_E_C_N_O_ REC,BD6_FILIAL,BD6_ANOPAG,BD6_MESPAG,BD6_OPEUSR,BD6_CODEMP,BD6_MATRIC,BD6_TIPREG,BD6_CODOPE,BD6_SEQUEN, "
		cSQL3 += " BD6_CODLDP,BD6_CODPEG,BD6_NUMERO,BD6_CODRDA,BD6_SEQIMP,BD6_TIPGUI,BD6_VLRTPF 
		
		If lConsol .And. BD6->( FieldPos("BD6_CONSOL") ) > 0 .And. BD6->BD6_CONSOL <> '0'
			cSQL3 += " ,BD6_CONSOL "
		EndIf
		
		cSQL3 += " FROM " + RetSqlName("BD6")
		cSQL3 += " WHERE "
		cSQL3 += " BD6_FILIAL =  '"+xFilial("BD6")+"' AND "
		cSQL3 += " BD6_OPEUSR =  '"+Trb->BG9_CODINT+"' AND "
		cSQL3 += " BD6_CODEMP =  '"+Trb->BG9_CODIGO+"' AND "
		cSQL3 += " BD6_ANOPAG =  '"+cAno+"' AND "
		cSQL3 += " BD6_MESPAG =  '"+cMes+"' AND "
		cSQL3 += " BD6_CONEMP >= '"+cContrDe+"' AND BD6_CONEMP <= '"+cContrAte+"' AND "
		cSQL3 += " BD6_SUBCON >= '"+cSubconDe+"' AND BD6_SUBCON <= '"+cSubconAte+"' AND "
		cSQL3 += " BD6_MATRIC >= '"+cMatDe+"' AND BD6_MATRIC <=  '"+cMatAte+"' AND "
		
		cSQL3 += PlReChvEst("BD6",.T.,.F.,.F.,.T.,.F.,.F.)[1]
		
		If cRetro150 == 1		  // Todos
			If !Empty(dDatAte)
				cSQL3 += " BD6_DATPRO <= '"+DTOS(dDatAte)+"' AND "
			Endif
		EndIf
		If cRetro150 == 2		 // Nao
			If !Empty(dDatAte)
				cSQL3 += " BD6_DATPRO > '"+DTOS(dDatAte - nDiasSrvPrt)+"' AND "
			Endif
		EndIf
		If cRetro150 == 3		 // Sim
			If !Empty(dDatAte)
				cSQL3 += " BD6_DATPRO <= '"+DTOS(dDatAte-nDiasSrvPrt)+"' AND "
			Endif
		EndIf

//		cSQL3 += " BD6_VLRTPF > 0 AND "
		cSQL3 += " BD6_FASE IN ('3','4') AND "
		cSQL3 += " BD6_SITUAC  = '1' AND "
		cSQL3 += " BD6_SEQPF   = ' ' AND "
		cSQL3 += " BD6_CODLDP >= '"+cLocDe+"' AND BD6_CODLDP <= '"+cLocAte+"'  "
	//	cSQL3 += " BD6_BLOCPA <> '1' "  
		
		If lConsol .And. BD6->( FieldPos("BD6_CONSOL") ) > 0 .And. BD6->BD6_CONSOL <> '0'
			cSQL3 += " AND BD6_CONSOL <> '0'  "
		EndIf

		cSQL3 += " AND D_E_L_E_T_ = ' ' AND "
		cSQL3 += " ( SELECT COUNT(1) CONTADOR FROM "+RetSqlName("BD7")
		cSQL3 += " 		WHERE "
		cSQL3 += " 		BD7_FILIAL = BD6_FILIAL AND "
		cSQL3 += " 		BD7_CODOPE = BD6_CODOPE AND "
		cSQL3 += " 		BD7_CODLDP = BD6_CODLDP AND "
		cSQL3 += " 		BD7_CODPEG = BD6_CODPEG AND "
		cSQL3 += " 		BD7_NUMERO = BD6_NUMERO AND "
		cSQL3 += " 		BD7_ORIMOV = BD6_ORIMOV AND "
		cSQL3 += " 		BD7_SEQUEN = BD6_SEQUEN AND "
//		cSQL3 += " 		(BD7_BLOPAG <> '1' OR (BD7_BLOPAG = '1' AND BD6_MOTBPG IN ('066','067','068') )) AND "
		cSQL3 += " 		D_E_L_E_T_ = ' ' ) > 0 "
		cSQL3 += " ORDER BY	BD6_OPEUSR,BD6_CODEMP,BD6_MATRIC,BD6_TIPREG "
		
		OPEN QUERY cSQL3 ALIAS "TrbBD6"
		
		nTotReg	:= 0
		TrbBD6->( dbEval( { || nTotReg++ } ) )
		Iif(!lAutoma,oSelf:setRegua2(nTotReg),"")
		TrbBD6->(DbGoTop())     
		
		while ! TrbBD6->(eof())

			Iif(!lAutoma, oSelf:IncRegua2(STR0005+TrbBD6->(BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG)+" ..."), "")
			//Verifica se a guia deste tipo de prestador pode ser consolidada     
			nPos := aScan(aRDA,{ |x| x[1] == TrbBD6->BD6_CODRDA})
			
			if  nPos == 0
				
				BAU->(msSeek(xFilialBAU+TrbBD6->BD6_CODRDA))
				
				aadd(aRda,{BAU->BAU_CODIGO,BAU->BAU_TIPPRE})
				
				nPos := len(aRDA)
			endIf   
			
			if  !empty(cTipPre)
				
				if  aRDA[nPos,2] $ cTipPre
					TrbBD6->(dbSkip())
					loop
				endIf
				
			endIf
			
			//Consolidação: somente cobrar se foi ja foi vincula
			If cMV_PLSCGIN == "2" .And. aRda[nPos,2] == cMV_PLSTPIN .And. empty(TrbBD6->BD6_SEQIMP)
				TrbBD6->(dbSkip())
				Loop
			Endif
			
			//Despreza guias que nao podem ser validadas...                       
			cChaveNot := TrbBD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)
			
			If Ascan(aGuiasNAO,cChaveNot) > 0
				TrbBD6->(dbSkip())
				Loop
			Endif

			//Ponto de entrada que permite desprezar guias para serem consolidadas neste momento   
			If l180Ac
				
				BD6->(DbGoTo(TrbBD6->(REC)))
				If ! ExecBlock("PLS180AC",.F.,.F.)
					TrbBD6->(DbSkip())
					Loop
				Endif
				
			Endif
			
			//Valor maximo
			If nVlrMax > 0
			
				nVlrBack   := nVlrAcum
				lGuiaValid := .T.
				
				If Ascan(aGuiasOK,cChaveNot) == 0

					BD6->(DbSetOrder(1))
					BD6->(MsSeek(cChaveNot))
					
					While ! BD6->(Eof()) .And. BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO) == cChaveNot .And. lGuiaValid
						
						If (nVlrAcum + BD6->BD6_VLRTPF) <= nVlrMax
							nVlrAcum += BD6->BD6_VLRTPF
						Else
							lGuiaValid := .F.
						Endif
						
						BD6->(DbSkip())
					Enddo
					
					If lGuiaValid
						aadd(aGuiasOK,cChaveNot)
					Else
						//essa guia toda nao vai sera consolidada...
						nVlrAcum := nVlrBack
						aadd(aGuiasNAO,cChaveNot)
						TrbBD6->(DbSkip())
						Loop
					Endif
				Endif
				
				nVlrAcum := nVlrBack
				
			Endif
			
			cAlias := IIF(TrbBD6->BD6_TIPGUI $ "03,05","BE4","BD5")
			
			BD6->(DbGoTo(TrbBD6->(REC)))
			
			If cAlias == "BD5"
			
				lAtuBD5 := .t.
			
				if TrbBD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO) <> BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO)
					lAtuBD5 := BD5->(MsSeek(xFilialBD5+TrbBD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)))
				endIf	
			
				if lAtuBD5
					B45->(DbSetOrder(1))
					//B45_FILIAL+B45_OPEMOV+B45_ANOAUT+B45_MESAUT+B45_NUMAUT+B45_SEQUEN                                                                                               
					If B45->(MsSeek(XFilial("B45")+BD5->(BD5_OPEMOV+BD5_ANOAUT+BD5_MESAUT+BD5_NUMAUT)+TRbBD6->BD6_SEQUEN)).And. B45->B45_ABATPF =='1'
						TrbBD6->(dbSkip())
						loop
					endIf
					grvPFBDH(TrbBD6->(BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG),"1",TrbBD6->BD6_ANOPAG,TrbBD6->BD6_MESPAG,cAlias,aErro,IIf(Alltrim(BD5->BD5_TIPPAC)=='1','1','2'))
					nVlrAcum += TrbBD6->BD6_VLRTPF
				endIf	
			
			Else                           
				lAtuBE4 := .t.
			
				if TrbBD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO) <> BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO)
					lAtuBE4 := BE4->(MsSeek(xFilialBE4+TrbBD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)))
				endIf	
			
				if lAtuBE4
					grvPFBDH(TrbBD6->(BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG),"1",TrbBD6->BD6_ANOPAG,TrbBD6->BD6_MESPAG,cAlias,aErro,"1")
					nVlrAcum += TrbBD6->BD6_VLRTPF
				endIf	
				
			Endif
			
		TrbBD6->(DbSkip())
		Enddo

		CLOSE QUERY "TrbBD6"
	Next
	
	If ( nVlrMax > 0 ) .And. ( nVlrAcum >= nVlrMax )
		Exit
	Endif
	
Trb->(DbSkip())
Enddo

CLOSE QUERY "Trb"

//Ponto de entrada para permitir atualizar campos no BB0  
If  ExistBlock("PLS180F")
	ExecBlock("PLS180F",.F.,.F.)
Endif

//DelCons
If FindFunction("PlDelCons")
	PlDelCons(aErro)
Endif
  
Return

/*/{Protheus.doc} PLSM180Del
DELETA
@type function
@author plsteam
@since 15.08.2002
@version 1.0
/*/
Function PLSM180Del()
LOCAL nOrdBD5 	:= BD5->(IndexOrd())
LOCAL nRecBD5 	:= BD5->(Recno())
LOCAL nOrdBE4 	:= BE4->(IndexOrd())
LOCAL nRecBE4 	:= BE4->(Recno())
LOCAL aRecBD6	:= {}
LOCAL nFor		:= 0

LOCAL lAtuBD5	:= .t.
LOCAL lAtuBE4	:= .t.
LOCAL xFilialBD5 := xFilial("BD5")
LOCAL xFilialBE4 := xFilial("BE4")
LOCAL xFilialBD7 := xFilial("BD7")

BD5->(DbSetOrder(1))
BE4->(DbSetOrder(1))
BD6->(DbSetOrder(12))
BD7->(DbSetOrder(1))

If BD6->( msSeek( xFilial("BD6")+BDH->(BDH_CODINT+BDH_CODEMP+BDH_MATRIC+BDH_TIPREG+BDH_ANOFT+BDH_MESFT+BDH_SEQPF) ) )
	
	While !BD6->( Eof() ) .and. BDH->(BDH_FILIAL+BDH_CODINT+BDH_CODEMP+BDH_MATRIC+BDH_TIPREG+BDH_ANOFT+BDH_MESFT+BDH_SEQPF) ==;
							     BD6->(BD6_FILIAL+BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG+BD6_ANOPAG+BD6_MESPAG+BD6_SEQPF)
		aAdd(aRecBD6,BD6->(RecNo()))
		BD6->(dbSkip())
	EndDo
	
	For nFor := 1 to Len(aRecBD6)
	
		// Posiciono no Evento
		BD6->(DbGoTo(aRecBD6[nFor]))
		
		// Inicia processo de estorno da co-participação.
		BD6->(RecLock("BD6",.F.))
			
			BD6->BD6_SEQPF := ""
			
		BD6->(MsUnLock())

		If BD6->BD6_TIPGUI $ "  ,01,02,04,06,10"
			
			lAtuBD5 := .t.
			if BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO) <> BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)
				lAtuBD5 := BD5->(MsSeek(xFilialBD5+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)))
			endIf
			
			if lAtuBD5
				BD5->(RecLock("BD5",.F.))
				BD5->BD5_SEQPF := ""
				BD5->(MsUnLock())
			endIf
			
		Else
			
			lAtuBE4 := .t.
			
			if BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO) <> BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)
				lAtuBE4 := BE4->(MsSeek(xFilialBE4+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)))
			endIf
			
			if lAtuBE4
				BE4->(RecLock("BE4",.F.))
				BE4->BE4_SEQPF := ""
				BE4->(MsUnLock())
			endIf
			
		Endif
		
	Next
	
Endif

BE4->(DbSetOrder(nOrdBE4))
BE4->(DbGoTo(nRecBE4))

BD5->(DbSetOrder(nOrdBD5))
BD5->(DbGoTo(nRecBD5))


Return()

/*/{Protheus.doc} PLSM180PAR
Realiza exclusao do parcelamento
@type function
@author plsteam
@since 15.08.2002
@version 1.0
/*/
Function PLSM180PAR(lAutoma)
Local cCodigo 	:= ""
Local cCliente	:= ""
Local cLoja 	:= ""  
Local aAreaBDH	:= BDH->(GetArea())   

Default lAutoma := .F.   

BA3->(DbSetOrder(1))
If BA3->(MsSeek(xFilial("BA3")+BDH->(BDH_CODINT+BDH_CODEMP+BDH_MATRIC)))
	cCliente 	:= BA3->BA3_CODCLI
	cLoja		:= BA3->BA3_LOJA
Else
	Return(.T.)
EndIf

B80->(DbSetOrder(1))//B80_FILIAL, B80_CODIGO, B80_CODINT, B80_CODEMP, B80_MATRIC, B80_TIPREG, R_E_C_D_E_L_
BK2->(DbSetOrder(6)) 
BDH->(DbSetOrder(1))// BDH_FILIAL, BDH_CODINT, BDH_CODEMP, BDH_MATRIC, BDH_TIPREG, BDH_ANOFT, BDH_MESFT
B78->(DbSetOrder(1))
B79->(DbSetOrder(1)) 

cSQL2 := " SELECT B80.* FROM "+RetSqlName("B80")+" B80 " 
cSQL2 += " INNER JOIN "+RetSqlName("BA3")+" BA3 "
cSQL2 += " 		ON	BA3.BA3_FILIAL	=	'"+xFilial("BA3")+"'
cSQL2 += " 		AND	BA3.BA3_CODINT	=	B80.B80_CODINT "
cSQL2 += " 		AND BA3.BA3_CODEMP	=	B80.B80_CODEMP "
cSQL2 += " 		AND BA3.BA3_MATRIC	=	B80.B80_MATRIC "
cSQL2 += " WHERE "
cSQL2 += " 		BA3.BA3_FILIAL 	= 	'"+xFilial("BA3")+"' AND "
cSQL2 += " 		BA3.BA3_CODINT 	= 	'"+BDH->BDH_CODINT+"' AND "
cSQL2 += " 		BA3.BA3_CODEMP 	= 	'"+BDH->BDH_CODEMP+"' AND "
cSQL2 += " 		BA3.BA3_CODCLI 	= 	'"+cCliente+"' AND "
cSQL2 += " 		BA3.BA3_LOJA 	= 	'"+cLoja+"' AND "
cSQL2 += " 		B80.B80_ANOBAS 	>= 	'"+BDH->BDH_ANOFT+"' AND "
cSQL2 += " 		B80.B80_MESBAS 	>= 	'"+BDH->BDH_MESFT+"' AND "
cSQL2 += " 		B80.D_E_L_E_T_ 	= 	' ' AND " 
cSQL2 += " 		BA3.D_E_L_E_T_ 	= 	' ' "
cSQL2 += " ORDER BY B80.B80_CODINT ASC, B80.B80_CODEMP ASC, B80.B80_MATRIC ASC, B80.B80_ANOBAS DESC, B80.B80_MESBAS DESC"

OPEN QUERY cSQL2 ALIAS "TrbPar"

While !TrbPar->( Eof() )
		
	If B80->( MsSeek(xFilial("B80")+TrbPar->(B80_CODIGO+B80_CODINT+B80_CODEMP+B80_MATRIC+B80_TIPREG)))
		
		cCodigo := B80->B80_CODIGO
		
		// Apago o parcelamento do saldo
		cChvAnt := TrbPar->(B80_CODINT+B80_CODEMP+B80_MATRIC+B80_TIPREG+B80_ANOBAS+B80_MESBAS)
		
		If 	BK2->(MsSeek(xFilial("BK2")+cChvAnt))
			BK2->(RecLock("BK2",.F.)) 
				BK2->BK2_PARCEL := "N" 
				BK2->BK2_SALDO := B80->B80_VALSAL
			BK2->(MsUnLocK())  
		EndIf
		
		// Deleto o saldo do mes seguinte
		cChave := TrbPar->(B80_CODINT+B80_CODEMP+B80_MATRIC+B80_TIPREG)
		cChave += Iif(Soma1(TrbPar->B80_MESBAS) == "13", Soma1(TrbPar->B80_ANOBAS,4)	, TrbPar->B80_ANOBAS )
		cChave += Iif(Soma1(TrbPar->B80_MESBAS) == "13", "01"							, Soma1(TrbPar->B80_MESBAS,2) )

		If BK2->(MsSeek(xFilial("BK2")+cChave))
			BK2->(RecLock("BK2",.F.)) 
				BK2->(DbDelete())
			BK2->(MsUnLocK())
		EndIf  
		
		// Deleto o valor da parcela
		cChave := TrbPar->(B80_CODINT+B80_CODEMP+B80_MATRIC+B80_TIPREG+B80_ANOBAS+B80_MESBAS)
		If BDH->(MsSeek(xFilial("BDH")+cChave))
			BDH->(RecLock("BDH",.F.)) 
				BDH->BDH_VLRPAR := 0
			BDH->(MsUnLock())
		EndIf
		
		// Deleto o historico
		cChave := TrbPar->(B80_CODINT+B80_CODEMP+B80_MATRIC+B80_TIPREG+B80_ANOBAS+B80_MESBAS)
		If B78->(MsSeek(xFilial("B78")+cChave))
			B78->(RecLock("B78",.F.)) 
				B78->(DbDelete())
			B78->(MsUnLock())
		EndIf 
		
		// Deleto o parcelamento
		B80->(RecLock("B80",.F.)) 
			B80->(DbDelete())
		B80->(MsUnLock())
	EndIf
	
	// Caso so exista um eu deleto o cabecalho do parcelamento
	If !B80->(MsSeek(xFilial("B80")+cCodigo))
		If B79->(MsSeek(xFilial("B79")+cCodigo)) 
			B79->(RecLock("B79",.F.)) 
				B79->(DbDelete())
			B79->(MsUnLock())		
		EndIf
	EndIf
	
TrbPar->(DbSkip())
EndDo

CLOSE QUERY "TrbPar"

RestArea(aAreaBDH)

Return(.T.)

/*/{Protheus.doc} grvPFBDH
Gera o registro de participacao financeira na tabela BDH
@type function
@author plsteam
@since 15.08.2002
@version 1.0
/*/
function grvPFBDH(cMatricUsr, cTipo, cAnoPag, cMesPag, cAliasPri, aErro, cTpPaci)
local nRet      := 0
local cLancF	:= ""
local aRet    	:= {}
local aRetCOV 	:= {}
local aRetTXV 	:= {}
local lCobPF  	:= .t.
local lCobProPF	:= .f.
Local lExcecaoBlq := .F.
Local lBlopag	:= .F.
Local lSegueProc := .T.
Local lTPFZero := .F.
Local lAvisado	:= .F.

default cAnoPag := ""
default cMesPag := ""
default aErro   := {}
default cTpPaci := "1"  // 1= Assitencia 2= Ocupacional

//Se o item foi avisado e depois glosado, bloqueado pagamento ou copart... 
//mesmo assim na cobrança final (PTU A500 XML) ele deve ser exportado (zerado) conforme manual da UB
if lUnimed
	B5S->(dbsetOrder(2))
	if B5S->(msseek(xFilial("B5S") + BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO))) 		
		if B2S->(MsSeek(xFilial("B2S")+B5S->B5S_NUMLOT))
			lAvisado := .T.	
		endIf
	endif
endif

lBlopag	    := BD6->BD6_BLOPAG == '1'
lTPFZero	:= BD6->BD6_VLRTPF == 0
lExcecaoBlq := BD6->BD6_MOTBPG $ "066,067,068"


//cTipo "1" Adicao
//      "0" Subtracao
// Gravacao da participacao financeira acumulada...
lCobPF 	:= BD6->BD6_BLOCPA <> "1" .OR. (BD6->BD6_BLOCPA =="1" .and. lAvisado) //Não deve dar return em caso de bloqueio de copart de um item ja avisado

// Proteção Financeira, marca registro zerado porque foi contemplado pela Proteção.
lCobProPF 	:= BD6->BD6_ALIAPF == "BRT" //Adicionando a condição do BRT, pois itens zerados do ID33 devem ser marcados

if ! lCobPF
	return
endIf

//Marca os registros com bloqueio de pagamento/copart, sem ser os com motivos de exceção
if (lBlopag .AND. !lExcecaoBlq .AND. lAvisado) .OR. (lTPFZero .AND. lAvisado) .OR. (BD6->BD6_BLOCPA =="1" .and. lAvisado)
	cLancF := "116"
	grvBDH("BDH_VALOR",cLancF,cTipo,0,cMatricUsr,cAnoPag,cMesPag,cAliasPri,.f.,cTpPaci)
	lSegueProc := .F.
endif

if ( ( cTipo == "1" .and. (BD6->BD6_VLRTPF > 0 .or. lCobProPF)) .Or. ( cTipo = "0" ) ) .AND. lSegueProc

	// Verifico se eh guia comprada
	if BD6->BD6_GUIACO <> "1"
		
		//co-participacao
		if BD6->BD6_TPPF == "1" 

			// Proteção financeira.
			if (BD6->BD6_VLRTPF == 0 .and. lCobProPF)
				
				//Proteção Financeira: Co-part zerada, so vai preencher o SEQPF do ITEM para controle.
				cLancF := "116"
				grvBDH("BDH_VALOR",cLancF,cTipo,0,cMatricUsr,cAnoPag,cMesPag,cAliasPri,.f.,cTpPaci)
				
			elseIf BD6->BD6_TIPUSR == '1' .and. !existBlock('PLTIPATO') //Fisica

				// Gravacao da participacao financeira
				cLancF := "116"
				grvBDH("BDH_VALOR",cLancF,cTipo,BD6->BD6_VLRPF,cMatricUsr,cAnoPag,cMesPag,cAliasPri,.f.,cTpPaci)
				
			else

				// Apuro os valores e lancamentos coparticipacao
				aRet := PLSTIPOCOP('2')

				if  valType(aRet[1]) == "A"
					aRetCOV := aRet[1]
					aRetTXV := aRet[2]
				else
					aRetCOV := aRet
				endIf

				// Gravacao da participacao financeira
				for nRet := 1 to len(aRetCOV)
				
					//tem que desconsiderar estas posicoes por questoes de compatibilidade com o passado
					if nRet == 2 .or. nRet == 3
						loop
					endIf
					
					if aRetCOV[nRet] > 0
					
						nPos := Ascan(aCpVrInfo, {|x| x[3] == nRet})
						
						if nPos > 0
							cLancF := aCpVrInfo[nPos][2]
							grvBDH(aCpVrInfo[nPos][1],aCpVrInfo[nPos][2],cTipo,aRetCOV[nRet],cMatricUsr,cAnoPag,cMesPag,cAliasPri,.f.,cTpPaci)
						else
							//"Posicao da matriz do PLSTIPOCOP sem campo de referencia no BDH"	
							aadd(aErro, { STR0030,BD6->(' ['+BD6_OPEUSR+'.'+BD6_CODEMP+'.'+BD6_MATRIC+'.'+BD6_TIPREG+'] '+BD6_ANOPAG+'/'+BDH_MESPAG),"","",'0',allTrim( str( BD6->(recno() ) ) ),'09' })
						endIf
						
					endIf
					
				next

				// Gravacao da taxa
				for nRet := 1 to len(aRetTXV)
					
					//tem que desconsiderar estas posicoes por questoes de compatibilidade com o passado
					if nRet == 2 .or. nRet == 3
						loop
					endIf
					
					if aRetTXV[nRet] > 0
						nPos := Ascan(aTpVrInfo, {|x| x[3] == nRet})
						
						//a taxa tem que ficar no mesmo lançamento, do lancamento principal para nao ser necessario criar campo no bd6
						if nPos > 0						
							grvBDH(aTpVrInfo[nPos][1],cLancF,cTipo,aRetTXV[nRet],cMatricUsr,cAnoPag,cMesPag,cAliasPri,.t.,cTpPaci)
						else
							//"Posicao da matriz do PLSTIPOCOP sem campo de referencia no BDH"
							aadd(aErro, { STR0030,BD6->(' ['+BD6_OPEUSR+'.'+BD6_CODEMP+'.'+BD6_MATRIC+'.'+BD6_TIPREG+'] '+BD6_ANOPAG+'/'+BDH_MESPAG),"","",'0',allTrim(str(BD6->(recno()))),'09' })
						endIf
						
					endIf
					
				next
				
			endIf
			
		// Apuro os valores e lancamentos Custo operacional.
		else
		
			// Proteção financeira.
			if (BD6->BD6_VLRTPF == 0 .and. lCobProPF)
		
				//Proteção Financeira: Co-part zerada, so vai preencher o SEQPF do ITEM para controle.
				cLancF := "116"
				grvBDH("BDH_VALOR",cLancF,cTipo,0,cMatricUsr,cAnoPag,cMesPag,cAliasPri,.f.,cTpPaci)
				
			else
				// Apuro os valores e lancamentos custo operacional
				aRet := PLSTIPOCOP('1')
				
				if  valType(aRet[1]) == "A"
					aRetCOV := aRet[1]
					aRetTXV := aRet[2]
				else
					aRetCOV := aRet
				endIf

				// Gravacao da participacao financeira
				for nRet := 1 to len(aRetCOV)

					if aRetCOV[nRet] > 0

						nPos := Ascan(aCoVrInfo, {|x| x[3] == nRet})

						if nPos > 0
							cLancF := aCoVrInfo[nPos][2]
							grvBDH(aCoVrInfo[nPos][1],aCoVrInfo[nPos][2],cTipo,aRetCOV[nRet],cMatricUsr,cAnoPag,cMesPag,cAliasPri,.f.,cTpPaci)
						else
							//"Posicao da matriz do PLSTIPOCOP sem campo de referencia no BDH"
							aadd(aErro, { STR0030,BD6->(' ['+BD6_OPEUSR+'.'+BD6_CODEMP+'.'+BD6_MATRIC+'.'+BD6_TIPREG+'] '+BD6_ANOPAG+'/'+BDH_MESPAG),"","",'0',allTrim(str(BD6->(recno()))),'09' })
						endIf
						
					endIf
					
				next

				// Gravacao da taxa
				for nRet := 1 to len(aRetTXV)

					if aRetTXV[nRet] > 0

						nPos := Ascan(aToVrInfo, {|x| x[3] == nRet})
						
						//a taxa tem que ficar no mesmo lançamento, do lancamento principal para nao ser necessario criar campo no bd6
						if nPos > 0                     
							grvBDH(aToVrInfo[nPos][1],cLancF,cTipo,aRetTXV[nRet],cMatricUsr,cAnoPag,cMesPag,cAliasPri,.t.,cTpPaci)
						else
							//"Posicao da matriz do PLSTIPOCOP sem campo de referencia no BDH"
							aadd(aErro, { STR0030,BD6->(' ['+BD6_OPEUSR+'.'+BD6_CODEMP+'.'+BD6_MATRIC+'.'+BD6_TIPREG+'] '+BD6_ANOPAG+'/'+BDH_MESPAG),"","",'0',allTrim(str(BD6->(recno()))),'09' })
						endIf
						
					endIf
					
				next

			endIf
			
		endIf

		// Caso nao houve composicao da taxa grava-se a taxa no campo fixo
		if  len(aRetTXV) == 0 .and. !empty(cLancF)
			grvBDH("BDH_VLRTAX",cLancF,cTipo,BD6->BD6_VLRTAD,cMatricUsr,cAnoPag,cMesPag,cAliasPri,.t.,cTpPaci)
		endIf
		
	else
	
		// Paga no Ato
		if BD6->BD6_QUACOB == "1"
		 	
		 	//Co-Participacao
			if BD6->BD6_TPPF == "1" 
				
				grvBDH("BDH_VALCOC","121",cTipo,BD6->BD6_VLRPF,cMatricUsr,cAnoPag,cMesPag,cAliasPri,.f.,cTpPaci)
				grvBDH("BDH_VALCOT","121",cTipo,BD6->BD6_VLRTAD,cMatricUsr,cAnoPag,cMesPag,cAliasPri,.t.,cTpPaci)
				
			// Custo
			else
			 
				grvBDH("BDH_VALCOM","120",cTipo,BD6->BD6_VLRPF,cMatricUsr,cAnoPag,cMesPag,cAliasPri,.f.,cTpPaci)
				grvBDH("BDH_VALCOT","120",cTipo,BD6->BD6_VLRTAD,cMatricUsr,cAnoPag,cMesPag,cAliasPri,.t.,cTpPaci)
				
			endIf
			
		// Paga na proxima fatura
		else 
		
			//Co-Participacao
			if BD6->BD6_TPPF == "1" 
			
				grvBDH("BDH_VALCPF","124",cTipo,BD6->BD6_VLRPF,cMatricUsr,cAnoPag,cMesPag,cAliasPri,.f.,cTpPaci)
				grvBDH("BDH_VALTCF","124",cTipo,BD6->BD6_VLRTAD,cMatricUsr,cAnoPag,cMesPag,cAliasPri,.t.,cTpPaci)

			// Custo
			else 

				grvBDH("BDH_VALCOF","123",cTipo,BD6->BD6_VLRPF,cMatricUsr,cAnoPag,cMesPag,cAliasPri,.f.,cTpPaci)
				grvBDH("BDH_VALTCF","123",cTipo,BD6->BD6_VLRTAD,cMatricUsr,cAnoPag,cMesPag,cAliasPri,.t.,cTpPaci)

			endIf
			
		endIf
		
	endIf
	
endIf

return

/*/{Protheus.doc} grvBDH
BD6 tem que estar posicionado
@type function
@author plsteam
@since 09/11/09
@version 1.0
/*/
function grvBDH(cCampo,cLancF,cTipo,nValor,cMatricUsr,cAnoPag,cMesPag,cAliasPri,lTaxa,cTpPaci)
local cSeq 		:= ""
local lNovo     := .t.
default cTpPaci := "1"

if cPaisLoc <> "BRA"

	BDH->(dbSetOrder(12))
	if !BDH->(msSeek(xFilial("BDH")+cMatricUsr+cAnoPag+cMesPag+cLancF+"1"))
		
		BDH->(dbSetOrder(11)) // Novo indice, pegar o numero
		BDH->(DbSeek(xFilial("BDH")+cMatricUsr+cAnoPag+cMesPag+cLancF+replicate('9',len(BDH->BDH_SEQPF)),.t.)) // Criar novo indice.
		BDH->(dbSkip(-1))
		
		if BDH->(BDH_FILIAL+BDH_CODINT+BDH_CODEMP+BDH_MATRIC+BDH_TIPREG+BDH_ANOFT+BDH_MESFT+BDH_LANCF) == xFilial("BDH")+cMatricUsr+cAnoPag+cMesPag+cLancF
			cSeq := soma1(BDH->BDH_SEQPF)
		else
			cSeq := strZero(1,len(BDH->BDH_SEQPF))
		endIf
		
		lNovo := .t.
		
		BDH->(recLock("BDH",.t.))
			BDH->BDH_FILIAL := xFilial("BDH")
			BDH->BDH_CODINT := Subs(cMatricUsr,atCodOpe[1],atCodOpe[2])
			BDH->BDH_CODEMP := Subs(cMatricUsr,atCodEmp[1],atCodEmp[2])
			BDH->BDH_MATRIC := Subs(cMatricUsr,atMatric[1],atMatric[2])
			BDH->BDH_TIPREG := Subs(cMatricUsr,atTipReg[1],atTipReg[2])
			BDH->BDH_ANOFT  := cAnoPag
			BDH->BDH_MESFT  := cMesPag
			
			if BDH->( fieldPos("BDH_LANCF") ) > 0
				BDH->BDH_LANCF	:= cLancF		// Criar campo.
			endIf
			
			BDH->BDH_VALOR  := 0
			
			if BDH->( fieldPos("BDH_VLCOPA") ) > 0
				BDH->BDH_VLCOPA	:= 0
			endIf
			
			BDH->BDH_OPEFAT := ""
			BDH->BDH_NUMFAT := ""
			BDH->BDH_PREFIX := ""
			BDH->BDH_NUMTIT := ""
			BDH->BDH_PARCEL := ""
			BDH->BDH_TIPTIT := ""
			BDH->BDH_STATUS := "1"
			BDH->BDH_SEQPF  := cSeq
			BDH->BDH_INTERC := BD6->BD6_INTERC
			BDH->BDH_TIPINT := BD6->BD6_TIPINT
			BDH->BDH_OPEORI := BD6->BD6_OPEORI
			
			if BDH->(fieldPos("BDH_EMPORI")) > 0
				BDH->BDH_EMPORI := if(len(allTrim(BD6->BD6_MATANT))==17,SUBS(BD6->BD6_MATANT,5,4),SUBS(BD6->BD6_MATANT,4,4))
			endIf
			
		BDH->( msUnLock() )
		
	else
		cSeq := BDH->BDH_SEQPF
	endIf
	
else

	BDH->(dbSetOrder(1))
	if !BDH->(msSeek(xFilial("BDH")+cMatricUsr+cAnoPag+cMesPag + "1" + cTpPaci))
		
		BDH->(dbSetOrder(3))
		BDH->(DbSeek(xFilial("BDH")+cMatricUsr+cAnoPag+cMesPag+replicate('9',len(BDH->BDH_SEQPF)),.t.)) // Criar novo indice.
		BDH->(dbSkip(-1))
		
		if BDH->(BDH_FILIAL+BDH_CODINT+BDH_CODEMP+BDH_MATRIC+BDH_TIPREG+BDH_ANOFT+BDH_MESFT) == xFilial("BDH")+cMatricUsr+cAnoPag+cMesPag
			cSeq := soma1(BDH->BDH_SEQPF)
		else
			cSeq := strZero(1,len(BDH->BDH_SEQPF))
		endIf
		
		lNovo := .t.
		BDH->(recLock("BDH",.t.))
			BDH->BDH_FILIAL := xFilial("BDH")
			BDH->BDH_CODINT := Subs(cMatricUsr,atCodOpe[1],atCodOpe[2])
			BDH->BDH_CODEMP := Subs(cMatricUsr,atCodEmp[1],atCodEmp[2])
			BDH->BDH_MATRIC := Subs(cMatricUsr,atMatric[1],atMatric[2])
			BDH->BDH_TIPREG := Subs(cMatricUsr,atTipReg[1],atTipReg[2])
			BDH->BDH_ANOFT  := cAnoPag
			BDH->BDH_MESFT  := cMesPag
			BDH->BDH_VALOR  := 0
			BDH->BDH_OPEFAT := ""
			BDH->BDH_NUMFAT := ""
			BDH->BDH_PREFIX := ""
			BDH->BDH_NUMTIT := ""
			BDH->BDH_PARCEL := ""
			BDH->BDH_TIPTIT := ""
			BDH->BDH_STATUS := "1"
			BDH->BDH_SEQPF  := cSeq
			BDH->BDH_INTERC := BD6->BD6_INTERC
			BDH->BDH_TIPINT := BD6->BD6_TIPINT
			BDH->BDH_OPEORI := BD6->BD6_OPEORI
			
			if BDH->(fieldPos("BDH_EMPORI")) > 0
				BDH->BDH_EMPORI := if(len(allTrim(BD6->BD6_MATANT))==17,SUBS(BD6->BD6_MATANT,5,4),SUBS(BD6->BD6_MATANT,4,4))
			endIf
			
			if BDH->(fieldPos("BDH_TIPPAC")) > 0
				BDH->BDH_TIPPAC := cTpPaci
			endIf
			
		BDH->( msUnLock() )
		
	else
		cSeq := BDH->BDH_SEQPF
	endIf
	
endIf

// nao pode ser inclusao e subtracao
if ! ( cTipo == "0" .and. lNovo )

	//adicao
	if cTipo == "1" 
	
		BDH->(recLock("BDH",.f.))
	
			&("BDH->"+cCampo) += nValor
	
			// Alimento o campo de valor para parcelamento bruto
			if 	BDH->( fieldPos("BDH_VLBRPA") ) > 0
				BDH->BDH_VLBRPA	+= nValor
			endIf
	
			// Alimento o campo de valor para parcelamento liquido
			if 	BDH->( fieldPos("BDH_VLCOPA") ) > 0 .and.;
					BR8->(Posicione("BR8",1,xFilial("BR8")+BD6->(BD6_CODPAD+BD6_CODPRO),"BR8_PODPAR")) != "1"
				BDH->BDH_VLCOPA	+= nValor
			endIf
	
			if  !lTaxa
				BDH->BDH_QTDEVE += BD6->BD6_QTDPRO
			endIf
			
		BDH->( msUnLock() )
		
	else
	
		BDH->(recLock("BDH",.f.))

			&("BDH->"+cCampo) -= nValor
		
			// Alimento o campo de valor para parcelamento bruto
			if 	BDH->( fieldPos("BDH_VLBRPA") ) > 0
				BDH->BDH_VLBRPA	-= nValor
			endIf
			
			// Alimento o campo de valor para parcelamento liquido
			if 	BDH->( fieldPos("BDH_VLCOPA") ) > 0 .and.;
					BR8->(Posicione("BR8",1,xFilial("BR8")+BD6->(BD6_CODPAD+BD6_CODPRO),"BR8_PODPAR")) != "1"
				BDH->BDH_VLCOPA -= nValor
			endIf
			
			if  !lTaxa
				BDH->BDH_QTDEVE -= BD6->BD6_QTDPRO
			endIf
			
		BDH->( msUnLock() )
	endIf
endIf

// atualiza o BD6
BD6->(recLock("BD6",.f.))

	BD6->BD6_SEQPF := cSeq
	
	if cPaisLoc <> "BRA"
	
		if !lTaxa .and. BD6->(fieldPos("BD6_LANCF")) > 0
			BD6->BD6_LANCF := cLancF
		endIf
		
	endIf
	
BD6->(msUnLock())

// atualiza o cabecalho
&(cAliasPri+"->(recLock('"+cAliasPri+"',.f.))")

	&(cAliasPri+"->"+cAliasPri+"_SEQPF") := cSeq

	if cPaisLoc <> "BRA"
	
		if !lTaxa .and. (cAliasPri)->(fieldPos((cAliasPri+"_LANCF"))) > 0
			&(cAliasPri+"->"+cAliasPri+"_LANCF") := cLancF
		endIf
	
	endIf
	
&(cAliasPri+"->(msUnLock())")

return
