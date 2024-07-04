#INCLUDE "FILEIO.CH"
#INCLUDE "PROTHEUS.CH"                                              
#INCLUDE "fwschedule.ch"
#INCLUDE "CTBXSEM.CH"

STATIC __cExt			:= GetDbExtension()
STATIC __lBlind 		:= IsBlind()
STATIC __lCT1LOCKED		:= .F.
STATIC __lCT1LSTLCK
STATIC __aCTBMLock 		:= {}
STATIC __nT2Abort				//Numero Máximo de Tentativas de Lock de Contas.
STATIC __nTETry					//Tempo entre tentativas de Lock de Contas.
STATIC __nTSA					//Numero de Tentativas sem alerta ao usuário.

STATIC __lCT2Exc		:= NIL
STATIC __lExcFil		:= NIL
STATIC __nCTFQDT        := NIL   // nNumero de documentos a serem criados
STATIC __aSM0           := {}    //
STATIC __lCtbSerial     := NIL
STATIC __lRelease       := NIL 
STATIC __aChaveLock     := NIL  // Chaves bloqueadas pelo lockbyname
STATIC _lOracle         := NIL
STATIC _nRecCTFLk 		:= 0
STATIC _nRecCT2Lk 		:= 0
STATIC _cKey_CTF        := ""
STATIC _lRecupCTF        := .F.
STATIC _nRegRecup        := 0
Static lPEFilExc        := ExistBlock("CTBSMEXC")
Static _lCTBPXDCQRY     := ExistBlock('CTBPXDCQRY')
Static _lCTBPRXDOC      := ExistBlock("CTBPRXDOC")

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ C050Next  ³ Autor ³ Pilar S Albaladejo    ³ Data ³ 30/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera numero de Lote e Documento na valida‡„o da Data.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ C050NextdDataLanc,cLote,cSubLote,cDoc,oLote,oSubLote,oDoc,; ³±±
±±³			 ³	  CTF_LOCK,nOpc,nOperacao)  			                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ctba050                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 = Data do Lancamento								   ³±±
±±³          ³ ExpC1 = Lote                  							   ³±±
±±³          ³ ExpC2 = SubLote               							   ³±±
±±³          ³ ExpC3 = Documento             							   ³±±
±±³          ³ ExpO1 = Objeto do lote        							   ³±±
±±³          ³ ExpO2 = Objeto do Sublote     							   ³±±
±±³          ³ ExpO3 = Objeto do Documento   							   ³±±
±±³          ³ ExpN1 = Semaforo para proximo documento                     ³±±
±±³          ³ ExpN2 = Numero da Opcao escolhida                           ³±±
±±³          ³ ExpN3 = Numero da Operacao                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Programador³ Data   ³ BOPS/FNC  ³  Motivo da Alteracao                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Jose Glez   ³        ³  MMI-5346 ³Numero de póliza debe ser consecutivo³±±
±±³             ³        ³           ³por mes.                             ³±±
±±³  Marco Aur  ³22/03/18³DMICNS-1588³Validacao da origem do processo para ³±±
±±³             ³        ³           ³nao por mes.                         ³±±
±±³  Marco A.   ³28/05/18³DMINA-2113 ³Se modifican funciones C050Next(),   ³±±
±±³             ³        ³           ³CTB105Next, LockDoc y ProxDoc para   ³±±
±±³             ³        ³           ³No. Poliza Consecutivo por mes. (MEX)³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C050Next(dDataLanc,cLote,cSubLote,cDoc,oLote,oSubLote,oDoc,CTF_LOCK,nOpc,nOperacao)

Local aSaveArea	:= GetArea()
Local lRet		:= .T.
Local dDataCTF	:= dDataLanc

If cPaisLoc == "MEX" // Consecutivo por mes, aplica solo para CTF
	dDataCTF := StoD( Substr(DtoS(dDataCTF), 1, 6) + "01" )
EndIf

dbSelectArea("CTF")
dbSetOrder(1)

If nOperacao == 2 		// Lancamento de integracao
	MsSeek(xFilial()+Dtos(dDataCTF)+cLote+cSubLote+cDoc,.t.)
EndIf	

If nOpc == 3 .Or. nOpc == 6 .Or. nOpc == 7
	
	Ctb105Next(dDataLanc,@cLote ,@cSubLote,@cDoc,nOperacao,@oLote,@oSubLote,@oDoc,@CTF_LOCK)		// Gera n£mero de Documento
	
	If ValType(oLote) == "O" .And. ValType(oSubLote) == "O" .And. ValType(oDoc)  == "O"
		oLote:Refresh()	;oSubLote:Refresh();oDoc:Refresh()		// Atualiza a Tela
	EndIf	
EndIf
RestArea(aSaveArea)

Return lRet
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±                    ±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CTB105Next ³ Autor ³ Pilar S Albaladejo    ³ Data ³04.02.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera pr¢ximo n£mero de Documento / Lote                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctb105Next(dDataLanc,@cLote,@cSubLote,@cDoc)                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA050 / CTBA105                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 = Data do Lan‡amento								   ³±±
±±³			 ³ ExpC1 = Lote 											   ³±±
±±³          ³ Expc2 = SubLote											   ³±±
±±³          ³ Expc3 = Documento										   ³±±
±±³          ³ ExpN1 = Numero da Operacao 								   ³±±
±±³          ³ ExpO1 = Objeto do Lote     								   ³±±
±±³          ³ ExpO2 = Objeto do SubLote  								   ³±±
±±³          ³ ExpO3 = Objeto do Documento								   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION CTB105Next(dDataLanc,cLote,cSubLote,cDoc,nOperacao,oLote,oSubLote,oDoc,CTF_LOCK)

Local aSaveArea	:= GetArea()
Local nIndCT2	:= CT2->(IndexOrd())
Local nRecCT2	:= CT2->(Recno())
Local dDataCTF	:= dDataLanc

DEFAULT CTF_LOCK:= 0

// Indica se o lancamento eh manual (1) ou de integracao (2)
nOperacao := Iif(nOperacao == Nil,1,nOperacao)

// Consecutivo por mes, aplica solo para CTF
If cPaisLoc == "MEX"
	dDataCTF := StoD( Substr(DtoS(dDataCTF), 1, 6) + "01" )
EndIf
             
If nOperacao == 1
	If CTF_LOCK > 0							/// SE HOUVER CTF_LOCK INDICA ALTERACAO/EXCLUSAO
		dbSelectArea("CTF")		
		DbGoto(CTF_LOCK)     
		CtbDestrava(CTF->CTF_DATA,CTF->CTF_LOTE,CTF->CTF_SBLOTE,CTF->CTF_DOC,@CTF_LOCK)		///	(MAS CHECA SE OUTRO USUÁRIO NAO GRAVOU CT2 COM O MESMO NUMERO PARA NÃO DELETAR INDEVIDO)
	Endif

	If Empty(cLote)
		If GetNewPar("MV_LOTECON","T") == "T"				// Numero de Lote vindo da Tabela SX5 (MV_LOTECON = T)
			cLote := If(cModulo=="CTB",Tabela("09","CON"),Tabela("09",cModulo))
			cLote := Iif(Len(Alltrim(cLote)) < 6, PADL(cLote,6,"0"),cLote)
		Else							// Numero de Lote Sequencial pelo CTF (MV_LOTECON = U)
			dbSelectArea("CTF") 
			dbSetOrder(1)
			If !MsSeek(xFilial("CTF")+Dtos(dDataCTF)+"ZZZZZZZZZ",.t.)
				dbSkip(-1)         
				If dtos(CTF->CTF_DATA) == dtos(dDataCTF)
					cLote    := Soma1(CTF->CTF_LOTE)
				Else
					cLote    := '000001'
				Endif
			Endif
		Endif
	Endif
	
	If !lSubLote
		cSubLote := cLoteSub
	Endif
Else
	Return(.T.)
EndIf
Do While !ProxDoc(dDataLanc,cLote,cSubLote,@cDoc,@CTF_LOCK)                  
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso o N§ do Doc estourou, incrementa o lote         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cLote := CtbInc_Lot(cLote, cModulo)
Enddo

CT2->(dbSetOrder(nIndCT2))		//// VOLTA A POSICAO ORIGINAL NO CT2 - INDICE
CT2->(MsGoTo(nRecCT2))			//// VOLTA A POSICAO ORIGINAL NO CT2 - REGISTRO
RestArea(aSaveArea)

If ValType(oLote) == "O" .And. ValType(oSubLote) == "O" .And. ValType(oDoc) == "O"
	oLote:Refresh()	;oSubLote:Refresh();oDoc:Refresh()		// Atualiza a Tela
EndIf	

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³UnLockDoc  ³ Autor ³ Pilar S Albaladejo    ³ Data ³ 30/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o Numero do Documento (apaga registro no CTF)       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ UnLockDoc(Ctf_Lock)				                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ctba050                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Semaforo para proximo documento                     ³±±                    								   
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function UnLockDoc(Ctf_Lock)
Local lExclReg := .F.
If  __lRelease  == NIL
 	__lRelease  := CTF->(FieldPos('CTF_USADO'))>0
EndIf	
If __lRelease    //>=12.1.031
	If CTF_Lock > 0
		If ! (IsIncallstack("CA100INCL") .Or. IsIncallstack("CTBA101") .Or. IsIncallstack("CTBA102") .Or. IsIncallstack("CTBA103") )
			lExclReg := .T.
		EndIf
		DbSelectArea("CTF")
		dbGoto(CTF_Lock) 
		If Intransact()
			//Quando em transação nAo pode utilizar MSRUnlock 
			Reclock("CTF",.F.)
			If lExclReg
				CTF->(dbDelete())
			Else
				If _lRecupCTF
					CTF->CTF_USADO	:= "R"
					If !Empty(CTF->CTF_LINHA)
						CTF->CTF_LINHA	:= " "
					EndIf
					_lRecupCTF := .F.
				ElseIf CTF->( Recno() ) == _nRegRecup
					CTF->CTF_USADO	:= "R"
					If !Empty(CTF->CTF_LINHA)
						CTF->CTF_LINHA	:= " "
					EndIf
					_nRegRecup := 0
				Else
					If CTF->CTF_USADO == "S" .OR. Empty(CTF->CTF_USADO)
						CTF->CTF_USADO	:= "X"
					EndIf
				EndIf
			EndIf
			MsUnlock()

			CTF->(dbCommit())
			CTF->(FKCOMMIT())
			
		Else
			Reclock("CTF",.F.)
			If lExclReg
				CTF->(dbDelete())
			Else
				If _lRecupCTF
					CTF->CTF_USADO	:= "R"
					If !Empty(CTF->CTF_LINHA)
						CTF->CTF_LINHA	:= " "
					EndIf
					_lRecupCTF := .F.
				ElseIf CTF->( Recno() ) == _nRegRecup
					CTF->CTF_USADO	:= "R"
					If !Empty(CTF->CTF_LINHA)
						CTF->CTF_LINHA	:= " "
					EndIf
					_nRegRecup := 0
				Else
					If CTF->CTF_USADO == "S" .OR. Empty(CTF->CTF_USADO)
						CTF->CTF_USADO	:= "X"
					EndIf
				EndIf				
			EndIf
			MsRUnlock()

			CTF->(dbCommit())
			CTF->(FKCOMMIT())

		Endif
		CTF_Lock := 0

		Leave1Code("CTF"+CTF->(CTF_FILIAL+DTOS(CTF_DATA)+CTF_LOTE+CTF_SBLOTE+CTF_DOC+"X") )

		ConoutR(ProcName() + '| Realizando o desbloqueio do documento:' + Str(CTF_LOCK) )

	Endif
else // Release menor 12.1.031
	If CTF_Lock > 0
		DbSelectArea("CTF")
		dbGoto(CTF_Lock)                   
		If CTF->(RLock())
			CTF->(MsUnlock())
			Reclock("CTF",.F.)
			CTF->(dbDelete())
			MsUnlock()
		Else
			MsUnlock()
		Endif
		CTF_Lock := 0
		
		Leave1Code("CTF"+CTF->(CTF_FILIAL+DTOS(CTF_DATA)+CTF_LOTE+CTF_SBLOTE+CTF_DOC) )

		ConoutR(ProcName() + '| Realizando o desbloqueio do documento:' + Str(CTF_LOCK) )
	Endif
EndIf

Return .T.


//---------------------------------------------------------------------------------
/*/{Protheus.doc} CtSetRcCTF
Grava na tabela CTF - Num Doc Contabil se pode recuperar este registro da CTF
Se aplica nos casos de exclusao de documento para posterior redigitacao com mesmo numero
Para que isto aconteca a cada documento a ser excluido deve ser setado esta variavel static no momento da exclusao
@author Totvs
@since 07/12/2021
@version P12
/*/
//---------------------------------------------------------------------------------

Function CtSetRcCTF(lRecupCTF)
	_lRecupCTF := lRecupCTF
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ LockDoc   ³ Autor ³ Totvs   ³               Data ³ 10/08/2020³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descr‡ ³ Redireciona para OldLockDoc < 12.1.031 ou NewLockDoc >=12.1.031´±±
±±³Trava o Documento a ser utilizado no Lan‡amento Cont bil                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LockDoc( dDataLanc , cLote , cDoc )                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA050 / CTBA105                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 = Data do Lan‡amento 							       ³±±
±±³          ³ ExpC1 = Lote Cont bil 									   ³±±
±±³          ³ ExpC2 = SubLote                     						   ³±±
±±³          ³ ExpC3 = N£mero do Documento 								   ³±±
±±³          ³ ExpN1 = Semaforo para proximo documento                     ³±±                    								   
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LockDoc(dDataLanc,cLote,cSubLote,cDoc,CTF_LOCK )
If  __lRelease  == NIL
 	__lRelease  := CTF->(FieldPos('CTF_USADO'))>0
EndIf

If __lRelease
	Return NewLockDoc(dDataLanc,cLote,cSubLote,cDoc,@CTF_LOCK )
Else
	Return OldLockDoc(dDataLanc,cLote,cSubLote,cDoc,@CTF_LOCK )
Endif

Return
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o   ³ NewLockDoc   ³ Autor ³ Totvs   ³            Data ³ 10/08/2020³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descr‡ ³ NewLockDoc >=12.1.031                                          ´±±
±±³Trava o Documento a ser utilizado no Lan‡amento Cont bil                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LockDoc( dDataLanc , cLote , cDoc )                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA050 / CTBA105                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 = Data do Lan‡amento 							       ³±±
±±³          ³ ExpC1 = Lote Cont bil 									   ³±±
±±³          ³ ExpC2 = SubLote                     						   ³±±
±±³          ³ ExpC3 = N£mero do Documento 								   ³±±
±±³          ³ ExpN1 = Semaforo para proximo documento                     ³±±                    								   
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NewLockDoc(dDataLanc,cLote,cSubLote,cDoc,CTF_LOCK )
Local aSaveArea	:= GetArea()
Local lRet      := .F.

DbSelectArea("CTF")
If CTF->( ! Eof() )   //sempre verificar se nao esta em fim de arquivo
	If CTF->CTF_USADO == "R"
		_nRegRecup := CTF->( Recno() )
	EndIf
	RecLock("CTF",.F.)                    //alteracao
	CTF->CTF_USADO	:= "S"
	CTF->(MsUnlock())
	CTF->(dbCommit())
	CTF->(FKCOMMIT())

	If CTF->(SimpleLock(CTF_LOCK))       //lock do registro
		lRet := .T.
	Endif
Endif
RestArea(aSaveArea)

Return(lRet)
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o   ³ OldLockDoc   ³ Autor ³ Totvs   ³            Data ³ 10/08/2020³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descr‡ ³ NewLockDoc <12.1.031                                          ´±±
±±³Trava o Documento a ser utilizado no Lan‡amento Cont bil                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LockDoc( dDataLanc , cLote , cDoc )                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA050 / CTBA105                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 = Data do Lan‡amento 							       ³±±
±±³          ³ ExpC1 = Lote Cont bil 									   ³±±
±±³          ³ ExpC2 = SubLote                     						   ³±±
±±³          ³ ExpC3 = N£mero do Documento 								   ³±±
±±³          ³ ExpN1 = Semaforo para proximo documento                     ³±±                    								   
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function OldLockDoc(dDataLanc,cLote,cSubLote,cDoc,CTF_LOCK )

Local aSaveArea	:= GetArea()
Local lMsgUnq	:= IsInCallStack("CTBI102")
Local dDataCTF	:= dDataLanc
Local lInclCTF  := .T.

If _lOracle == NIL
	_lOracle := ( Upper(Alltrim(TcGetDb()))=="ORACLE" )
EndIf

// Consecutivo por mes, aplica solo para CTF
If cPaisLoc == "MEX"
	dDataCTF := StoD( Substr(DtoS(dDataCTF), 1, 6) + "01" )
EndIf

DbSelectArea("CTF")
DbGotop()

If _lOracle .And. Intransact()
	CtCTFJob( xFilial("CTF"), dDataCTF, cLote, cSubLote, cDoc, @lInclCTF)
EndIf

If lInclCTF
	RecLock("CTF",.T.)
	CTF->CTF_FILIAL		:= xFilial("CTF")
	CTF->CTF_DATA		:= dDataCTF
	CTF->CTF_LOTE		:= cLote
	CTF->CTF_SBLOTE		:= cSubLote
	CTF->CTF_DOC		:= cDoc
	CTF->(MsUnlock())
	CTF->(dbCommit())
	CTF->(FKCOMMIT())
EndIf
//³Não efetuar o MsUnlock() - O Registro deve ficar reservado³
RecLock("CTF",.F.)
CTF_LOCK := CTF->(Recno())

// Proteção para mensagem única
If lMsgUnq
	MsUnLock()
EndIf 

ConoutR(ProcName() + '| Realizando o bloqueio do documento:' + Str(CTF_LOCK) )

RestArea(aSaveArea)

Return .T.

/*
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ UniqueIdxErr   ³ Autor ³ TOTVS     ³ Data ³ 23/03/2020      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Captura de erro                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LockDoc( oError, cError )                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lErr                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LockDoc                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oError                                                      ³±±
±±³          ³ cError                                                      ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*static function UniqueIdxErr(oError, cError)
local lErr as logical
//Código do erro de índice único, precisa testar em outros bancos para saber se segue esse padrão...
lErr := oError:GenCode != 46
cError := oError:Description
break
return lErr*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³A370CanProºAutor  ³Marcos S. Lobo      º Data ³  06/26/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cria Semaforo de processamento e verifica concorrencia com  º±±
±±º          ³base nos intervalos de parametros                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP - Contabilizacao Off-Line Financeiro                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±³Param- ExpD1 - dDtVldDe  - Data Inicial do processamento               ³±±
±±³       ExpD2 - dDtVldAte - Data Final do processamento                 ³±±
±±³       ExpC3 - cFilDe    - Filial Inicial a processar                  ³±±
±±³       ExpC4 - cFilAte   - Filial Final a processar                    ³±±
±±³                     Caso a rotina tenha seleção de filiais, cFilDe    ³±±
±±³				        recebe array das filiais selecionadas e cFilAte   ³±±
±±³				        recebe "" ou não passa nada. Caso queira executar ³±±
±±³                     somente a filial logada infomarmá-la em cFilDe e  ³±±
±±³                     cFilAte                                           ³±±      
±±³       ExpC5 - cChave    - Chave/nome do programa chama a função       ³±±
±±³                           Tamanho maximo chave : Caracter de 6        ³±±
±±³       ExpL6 - lSerial   - Se .T., recebe demais parâmetros e esta fun-³±±
±±³                     ção trabalha de forma independente das funções    ³±±
±±³                     CtbSerialI e CtbSerialF. Se Versão anterior a     ³±±
±±³                     P12.1.31 trabalha com arquivo de semáforo contábil³±±
±±³                     no system.                                        ³±±
±±³       ExpC7 - cEmpProc  - Aqui informar o Grupo de empresas, SOMENTE  ³±±
±±³                           QUANDO O PROCESSAMENTO ENVOLVER DOIS OU MAIS³±±
±±³                           GRUPOS DE EMPRESAS. Exemplo: Consolidação   ³±±
±±³                           Contábil, InterCompany.                     ³±±
±±³       ExpA8 - aChaveLock- Declarado no fonte origem como variável     ±±³
±±³                           Local e passado por referência. Vai conter  ±±³
±±³                          um todas as chaves bloqueadas pelo LockByName³±±
±±³ Obs: o parâmetro lSerial trabalha em conjunto com a variável estática ³±±
±±³      __lCtbSerial para versões iguais ou superiores a P12.1.31. De    ³±±
±±³      forma que se o parâmetro recebido lSerial for .T., esta função,  ³±±
±±³      CanProcItvl trabalhará independente das funções CtbSerialI e     ³±±
±±³      CtbSerialF. Fará LockByName.                         ³±±
±±³      Para versões inferiores a P12.1.31, esse parâmetro e a variável  ³±±
±±³      estática __lCtbSerial não terão nenhum efeito.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T./.F.                                                     ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CanProcItvl(dDtVldDe, dDtVldAte, cFilDe, cFilAte, cChave, lSerial, aSelFil,  cEmpProc)  //__aChaveLock 
Default lSerial := .T.
If  __lRelease  == NIL
 	__lRelease  :=  CTF->(FieldPos('CTF_USADO'))>0
EndIf

If __lRelease
	If __aChaveLock == NIL
		__aChaveLock  := {}
	Endif
	//comentar para validar novo
	If lSerial  // CTBANFE e CTBANFS -- demais chama ctbinisemaforo - CTBSERIALI/CTBSERIALF
		If __lCtbSerial == NIL 
			__lCtbSerial := .T.
		EndIf
		Return NewCanProcItvl(dDtVldDe, dDtVldAte, cFilDe, cFilAte, cChave, lSerial, aSelFil,  cEmpProc)  //, @aChaveLock )
	//Else
	//	Return NewCanProcItvl(dDtVldDe, dDtVldAte, cFilDe, cFilAte, cChave)   //, lSerial, aSelFil, cEmpProc, @aChaveLock )
	endif
Else
    Return OldCanProcItvl(dDtVldDe, dDtVldAte, cFilDe, cFilAte, cChave)
EndIf

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³NewCanProcItvlºAutor  ³Marcos S. Lobo      º Data ³06/26/06 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cria Semaforo de processamento e verifica concorrencia com  º±±
±±º          ³base nos intervalos de parametros                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP - Contabilizacao Off-Line Financeiro                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±³Param- ExpD1 - dDtVldDe  - Data Inicial do processamento               ³±±
±±³       ExpD2 - dDtVldAte - Data Final do processamento                 ³±±
±±³       ExpC3 - cFilDe    - Filial Inicial a processar                  ³±±
±±³       ExpC4 - cFilAte   - Filial Final a processar                    ³±±
±±³                     Caso a rotina tenha seleção de filiais, cFilDe    ³±±
±±³				        recebe array das filiais selecionadas e cFilAte   ³±±
±±³				        recebe "" ou não passa nada. Caso queira executar ³±±
±±³                     somente a filial logada infomarmá-la em cFilDe e  ³±±
±±³                     cFilAte                                           ³±±      
±±³       ExpC5 - cChave    - Chave/nome do programa chama a função       ³±±
±±³                           Tamanho maximo chave : Caracter de 6        ³±±
±±³       ExpL6 - lSerial   - Se .T., recebe demais parâmetros e esta fun-³±±
±±³                     ção trabalha de forma independente das funções    ³±±
±±³                     CtbSerialI e CtbSerialF. Se Versão anterior a     ³±±
±±³                     P12.1.31 trabalha com arquivo de semáforo contábil³±±
±±³                     no system.                                        ³±±
±±³       ExpC7 - cEmpProc  - Aqui informar o Grupo de empresas, SOMENTE  ³±±
±±³                           QUANDO O PROCESSAMENTO ENVOLVER DOIS OU MAIS³±±
±±³                           GRUPOS DE EMPRESAS. Exemplo: Consolidação   ³±±
±±³                           Contábil, InterCompany.                     ³±±
±±³       ExpA8 - aChaveLock- Declarado no fonte origem como variável     ±±³
±±³                           Local e passado por referência. Vai conter  ±±³
±±³                          um todas as chaves bloqueadas pelo LockByName³±±
±±³ Obs: o parâmetro lSerial trabalha em conjunto com a variável estática ³±±
±±³      __lCtbSerial para versões iguais ou superiores a P12.1.31. De    ³±±
±±³      forma que se o parâmetro recebido lSerial for .T., esta função,  ³±±
±±³      CanProcItvl trabalhará independente das funções CtbSerialI e     ³±±
±±³      CtbSerialF utilizando apenas LockByName.                         ³±±
±±³      Para versões inferiores a P12.1.31, esse parâmetro e a variável  ³±±
±±³      estática __lCtbSerial não terão nenhum efeito.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T./.F.                                                     ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NewCanProcItvl(dDtVldDe, dDtVldAte, cFilDe, cFilAte, cChave, lSerial, aSelFil,  cEmpProc)  //, aChaveLock )
Local lRet		:= .F.
Local aAreaOri	:= GetArea()
Local iX		:= 1
Local nEr		:= 0 
Local nCTBSERT	:=	GetNewPar( "MV_CTBSERT", 1000) /// Tempo em Milisegundos (Retry)
Local lFilExc 	:= .F.
Local aSM0      := AdmAbreSm0()
Local nContFil  := 0
Local cFilLock  := ""
Local cChaveLock:= ""
Local cDataDe   := ""
Local cDataAte  := ""
Local cEmpLock  := ""
Local cEmpAtu   := cEmpAnt
Local cFilAtu   := cFilAnt
Local cTamEmp   := FWSM0Layout(cEmpAnt)   //"EEUUUFFF    "
Local iTamEmp   := 0
Local lEmpLock := .F.
Local lFilLock := .F.
Local lPerLock := .F.

PRIVATE cUserCTB := PADR('SCHED',15)
DEFAULT dDtVldDe  := Stod("")
DEFAULT dDtVldAte := Stod("")
DEFAULT cFilDe    := cFilAnt
DEFAULT cFilAte   := cFilAnt
DEFAULT aSelFil   := {}
DEFAULT cChave	  := 'ctbnfx'
DEFAULT lSerial   := .F.
DEFAULT cEmpLock  := cEmpAnt
 
 If __aChaveLock == NIL
	 __aChaveLock := {}
Endif
/*If ExistBlock("TstLockByName")
	lRet := ExecBlock("TstLockByName",.F.,.F.)
	Return
Endif*/
If Empty(dDtVldDe) .or. Empty( dDtVldAte) .or. (!Empty(dDtVldAte) .and. !Empty(dDtVldDe) .and. (dDtVldAte < dDtVldDe))
	Help(" ",1,"DATAPROC",,STR0019,1,0)//"Informar as Datas Inicio e Fim para o Processamento ou verificar se Data Início Não é Maior que a Data Fim !"
	Return lRet
Endif

cDataDe  := Dtos(dDtVldDe)
cDataAte := Dtos(dDtVldAte)

cTamEmp   := FWSM0Layout(cEmpAnt)   //"EEUUUFFF    "
For iX = 1 to Len(cTamEmp)
	cChar := Substring(cTamEmp, ix, 1 )
	If cChar == 'E'
		iTamEmp := iTamEmp + 1
	Else
		Exit
	Endif
Next

nCTBSERT := iIf(nCTBSERT == 0, 1000, nCTBSERT)
If Empty( cChave ) .or. cChave == nil
	cChave := "ctbnfx"
EndIf
//cChave := "_" + substr( cChave, 2, Len(cChave))	

If GetNewPar( "MV_CTBNFE" , "1" ) == "2"  
	Return .T.		/// Se o semaforo estiver desligado (Default é ligado), permite o processamento.
EndIf
If ! __lBlind
	cUserCTB := cUserName
EndIf

lFilExc :=  CTBExcFil()

//While ! LockByName( cChave + "ctbprc" + cEmpAnt ,.T., lFilExc, .T.)
/* Nome a ser bloqueado
   cChaveLock ->  cChave + cEmpLock + cFilLock + cDataDe */
iX := 1
For nContFil := 1 to Len(aSM0)	
	If !Empty(cEmpProc)
		/* ---------------------------------------------------------------------------------------------------------------------
		Tratamento Grupo Empresa - Se utiliza mais de um Grupo de Empresas  deve vir separados por '|'. Exemplo:  "T1|"T2|T3" 
	    -------------------------------------------------------------------------------------------------------------------- */
		cEmpLock := Substring(cEmpProc, iX, iTamEmp )
		cEmpAnt := cEmpLock
		iX := iTamEmp + 1
		lEmpLock := .T.
		//lFilLock := .F.
		//lPerLock := .F.
		//cChaveLock := cChave + cEmpAnt /// + cFilLock + cDataDe
	else
		lEmpLock := .F.
	EndIf
	//Lock de Grupo  de empresas - Consolidação/ Intercompany ( utiliza mais de um Grupo de Empresas )
	If lEmpLock .and. aSM0[nContFil][SM0_GRPEMP] != cEmpAnt
		Loop
	Endif
	// !lEmpLock -> NÃO FAZ Lock em 1 ou mais Grupos de Empresas. SOMENTE FILIAL LOGADA
//	If !lEmpLockt
	//cFilDE - cFilAte preenchidos
	If Len(aSelFil) = 0 .and. !Empty(cFilDe) .and. !Empty(cFilAte)
		lFilLock := .T.
	EndIf
		//Seleciona Filiais cFilDe = array de filiais
	If Len(aSelFil) > 0 
		cFilDe  := aSelDe[1]
		cFilAte := aSelFil[Len(aSelFil)]
		lFilLock := .T.	
	EndIf
	If !Empty(dDtVldDe) .and. ((dDtVldDe) <= (dDtvldAte))
		lPerLock := .T.
	Endif
//	EndIf
	If ((aSM0[nContFil][SM0_CODFIL] < cFilDe .Or. aSM0[nContFil][SM0_CODFIL] > cFilAte)  .and. lFilLock ) .Or. aSM0[nContFil][SM0_GRPEMP] != cEmpAnt
		Loop
	EndIf
	If lEmpLock 
		cChaveLock := cChave + cEmpAnt
		If lFilLock
			cChaveLock := cChave + cEmpAnt + cFilLock
			If lPerLock
				cChaveLock := cChave + cEmpAnt + cFilLock + cDataDe
			Endif
		Endif
	EndIf
	If !lEmpLock .and. lFilLock
		cChaveLock := cChave + cEmpAnt
		If lPerLock
			cFilLock := aSM0[nContFil][SM0_CODFIL]
		Else
			cFilLock := aSM0[nContFil][SM0_CODFIL]
		Endif
	Endif

	If lFilLock
		If lPerLock
			cChaveLock := cChave + cEmpAnt + cFilLock + cDataDe
		Else
			cDataDe  := "  "
			cChaveLock := cChave + cEmpAnt + cFilLock
		Endif
	Endif
	While (cDataDe <= cDataAte .and. lPerLock .and. lFilLock ) .or. ( !lPerLock .and. lFilLock .and. Empty(cDataDe) ) .or. lEmpLock
		While ! LockByName( cChaveLock,.T., lFilExc)  //, .T.)
			nER++
			If ! __lBlind
				msAguarde( {|| sleep(nCTBSERT) }, STR0001 + allTrim( str( nER ) ), STR0002 ) //"Semaforo de processamento... tentativa "#"Aguarde, arquivo sendo criado por outro usuário."
			Else
				sleep( nCTBSERT )
			EndIf
			If nER >= 5	/// A PARTIR DA QUINTA TENTATIVA
				If ! __lBlind
					If Aviso(STR0003,STR0004,{STR0005,STR0006},2) == 2//"Criação de Semaforo de processamento."#"Não foi possivel acesso exclusivo para criar o semaforo de processamento."#"Repetir"#"Fechar"
						ProcLogAtu("ERRO",STR0007,STR0008+STR0009)	 //"Atenção!"###"Este processo esta sendo utilizado com parametros conflitantes ( mesmo periodo ou carteiras ) por outro usuário ( "###" ) no momento. Verifique o período e os parametros selecionados para o processamento ou tente novamente mais tarde."
						aSize(__aChaveLock, 0)
						Return lRet
					Else
						nER := 0
					EndIf		

				ElseIf nER >= 30
					ProcLogAtu("ERRO",STR0007,STR0008+STR0009)	 //"Atenção!"###"Este processo esta sendo utilizado com parametros conflitantes ( mesmo periodo ou carteiras ) por outro usuário ( "###" ) no momento. Verifique o período e os parametros selecionados para o processamento ou tente novamente mais tarde."
					aSize(__aChaveLock, 0)
					Return lRet
				EndIf
			EndIf
		EndDo
		//Array com as Chaves Locadas
		AADD(__aChaveLock, cChaveLock )
		If !Empty(cDataDe)
			cDataDe := Dtos(StoD(cDataDe) + 1)
		EndIf
		If lEmpLock 
			cChaveLock := cChave + cEmpAnt // + cFilLock + cDataDe
		ElseIf lFilLock
			If lPerLock
				cChaveLock := cChave + cEmpAnt + cFilLock + cDataDe
			Else
				cChaveLock := cChave + cEmpAnt + cFilLock
			EndIf
		Endif
	EndDo
Next
//UnLockByName( cChave + "ctbprc" + cEmpAnt, .T., lFilExc, .T. )

cEmpAnt := cEmpAtu  // Volta para a Empresa logada
cFilAnt := cFilAtu
lRet :=.T.
aSize(aSM0, 0)
aSM0 := NIL
RestArea( aAreaOri )
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OldCanProcItvlºAutor  TOTVS      º Data ³  12/08/2020       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cria Semaforo de processamento e verifica concorrencia com  º±±
±±º          ³base nos intervalos de parametros                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP - Contabilizacao Off-Line Financeiro                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±³Parametros³ExpD1 - Data Inicial do processamento                       ³±±
±±³          ³ExpD2 - Data Final do processamento                         ³±±
±±³          ³ExpC3 - Filial Inicial a ser considerada no processamento.  ³±±
±±³          ³ExpC4 - Filial Final a ser considerada no processamento.    ³±±
±±³          ³ExpC3 - Chave do programa que esta chamando a função        ³±±
±±³          ³        Tamanho maximo chave : Caracter de 6                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T./.F.                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OldCanProcItvl(dDtVldDe, dDtVldAte, cFilDe, cFilAte, cChave)

Local lRet		:= .F.
Local aAreaOri	:= GetArea()
Local nEr		:= 0 
Local cFile		:= ""
Local nCTBSERT	:=	GetNewPar( "MV_CTBSERT", 1000) /// Tempo em Milisegundos (Retry)
Local lFilExc 	:= .F.

PRIVATE cUserCTB	:= PADR('SCHED',15)
PRIVATE cAliasTMP	:= ""

DEFAULT cFilDe  := cFilAnt
DEFAULT cFilAte := cFilAnt
DEFAULT cChave	:= 'ctbnfx'

nCTBSERT := iIf(nCTBSERT == 0, 1000, nCTBSERT)
If Empty( cChave ) .or. cChave == nil
	cChave := "ctbnfx"
EndIf

cChave := "_" + substr( cChave, 2, Len(cChave))	

cAliasTMP	:= cChave 

If GetNewPar( "MV_CTBNFSE" , "1" ) == "2"  
	Return .T.		/// Se o semaforo estiver desligado (Default é ligado), permite o processamento.
EndIf

If ! __lBlind
	cUserCTB := cUserName
EndIf

lFilExc := CTBExcFil() 

While ! LockByName( cChave + "ctbprc" + cEmpAnt ,.T., lFilExc, .T.)
    nER++

	If ! __lBlind
		msAguarde( {|| sleep(nCTBSERT) }, STR0001 + allTrim( str( nER ) ), STR0002 ) //"Semaforo de processamento... tentativa "#"Aguarde, arquivo sendo criado por outro usuário."
	Else
		sleep( nCTBSERT )
	EndIf

	If nER >= 5	/// A PARTIR DA QUINTA TENTATIVA
		If ! __lBlind
			If Aviso(STR0003,STR0004,{STR0005,STR0006},2) == 2//"Criação de Semaforo de processamento."#"Não foi possivel acesso exclusivo para criar o semaforo de processamento."#"Repetir"#"Fechar"
				ProcLogAtu("ERRO",STR0007,STR0008+STR0009)	 //"Atenção!"###"Este processo esta sendo utilizado com parametros conflitantes ( mesmo periodo ou carteiras ) por outro usuário ( "###" ) no momento. Verifique o período e os parametros selecionados para o processamento ou tente novamente mais tarde."
				Return lRet
			Else
				nER := 0
			EndIf		

		ElseIf nER >= 30
			ProcLogAtu("ERRO",STR0007,STR0008+STR0009)	 //"Atenção!"###"Este processo esta sendo utilizado com parametros conflitantes ( mesmo periodo ou carteiras ) por outro usuário ( "###" ) no momento. Verifique o período e os parametros selecionados para o processamento ou tente novamente mais tarde."
			Return lRet

		EndIf
    EndIf
EndDo

// nome do temporario
cFile := cChave + AllTrim( cEmpAnt )

// função para a criação do temporario do semaforo de processamento
IF ! CtbProcTmp( cFile )
	Return .T.
Endif

dbSelectArea( cAliasTMP )
dbGoTop()

lSai		:= .F.
lRet1		:= .T.
lRet2		:= .T.
lRet3		:= .T.	

While ! lSai .and. ( cAliasTMP )->(!Eof())
	        
	IF cFilDe <= ( cAliasTMP )->FILIALI .and. cFilAte >= (cAliasTMP)->FILIALF
		lRet1 := .F.
	ElseIF cFilDe >= (cAliasTMP)->FILIALI .and. cFilDe <= (cAliasTMP)->FILIALF
		lRet1 := .F.
	ElseIf cFilAte >= (cAliasTMP)->FILIALI .and. cFilAte <= (cAliasTMP)->FILIALF
		lRet1 := .F.
	ElseIf cFilDe > cFilAte
		lRet1 := .F.		
	Endif	    

	IF dDtVldDe <= (cAliasTMP)->DTDE .and. dDtVldAte >= (cAliasTMP)->DTATE
		lRet2 := .F.
	ElseIF dDtVldDe >= (cAliasTMP)->DTDE .and. dDtVldDe <= (cAliasTMP)->DTATE
		lRet2 := .F.
	ElseIf dDtVldAte >= (cAliasTMP)->DTDE .and. dDtVldAte <= (cAliasTMP)->DTATE
		lRet2 := .F.
	ElseIf dDtVldDe > dDtVldAte
		lRet2 := .F.		
	Endif
	
	If !lRet1 .and. !lRet2
		/// SE LOCALIZOU NO MESMO PERIODO E NAS MESMAS FILIAIS

		If !__lBlind
			Aviso(STR0007,STR0008+Alltrim((cAliasTMP)->CUSER)+" "+(cAliasTMP)->HORAI+" "+STR0009,{STR0006},2) //"Atenção!"###"Este processo esta sendo utilizado com parametros conflitantes ( mesmo periodo ou carteiras ) por outro usuário ( "###" ) no momento. Verifique o período e os parametros selecionados para o processamento ou tente novamente mais tarde."###"Fechar"
		EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza o log de processamento com o erro  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ProcLogAtu("ERRO",STR0007,STR0008+Alltrim((cAliasTMP)->CUSER)+STR0009) //"Atenção!"###"Este processo esta sendo utilizado com parametros conflitantes ( mesmo periodo ou carteiras ) por outro usuário ( "###" ) no momento. Verifique o período e os parametros selecionados para o processamento ou tente novamente mais tarde."
		lSai		:= .T.
	EndIf

	(cAliasTMP)->(dbSkip())
EndDo

If ! lSai
	RecLock( cAliasTMP,.T.)

	Field->CROTINA	:= FunName()
	Field->FILIALI	:= cFILDE
	Field->FILIALF	:= cFILATE
	Field->CUSER	:= cUserCTB
	Field->DATAI    := Date()
	Field->HORAI	:= Time()
	Field->DTDE		:= dDtVldDe
	Field->DTATE    := dDtVldAte

	MsUnlock()	
	MsRLock( (cAliasTMP)->(Recno()) ) ///DEIXA REGISTRO ALOCADO com MsRLock em função de transções...
	lRet := .T.		///PROCESSAMENTO PODE SER EFETUADO
EndIf

UnLockByName( cChave + "ctbprc" + cEmpAnt, .T., lFilExc, .T. )

RestArea( aAreaOri )

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FreeProcItºAutor  ³TOTVS               º Data ³  06/26/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Libera registro alocado no semaforo de processamento.       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP Contabilizacao Off-Line Financeiro                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FreeProcItvl( cChave)   //__aChaveLock
If  __lRelease  == NIL
 	__lRelease  := CTF->(FieldPos('CTF_USADO'))>0
EndIf	
If __lRelease
	If __lCtbSerial	
		Return NewFreeProcItvl( cChave)   //__aChaveLock )  // esta função seta  __lCtbSerial com NIL
	Endif
Else
	Return OldFreeProcItvl( cChave )
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NewFreeProcItºAutor  ³TOTVS               º Data ³12/08/2020º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Libera registro alocado no semaforo de processamento.       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP Contabilizacao Off-Line Financeiro                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NewFreeProcItvl( cChave)    //, aChaveLock )
Local nCTBSERT	:= GetNewPar( "MV_CTBSERT", 1000) /// Tempo em Milisegundos (Retry)
Local lFilExc   := .F.
Local iX := 0

nCTBSERT := iIf(nCTBSERT == 0, 1000, nCTBSERT)
If GetNewPar( "MV_CTBNFSE" , "1" ) == "2"  
	Return 	/// Se o semaforo estiver desligado (Default é ligado), permite o processamento.
EndIf

lFilExc := CTBExcFil()
//While ! LockByName( cChave + "ctbprc" + cEmpAnt, .T., lFilExc, .T.)
If __aChaveLock != NIL .and. Len(__aChaveLock) > 0
	For iX := 1 to Len(__aChaveLock) 
		UnLockByName( __aChaveLock[iX], .T., lFilExc, .T.)
	Next
	aSize(__aChaveLock, 0)
EndIf
__aChaveLock := NIL
__lCtbSerial := NIL
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OldFreeProcItºAutor  ³TOTVS               º Data ³12/08/2020º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Libera registro alocado no semaforo de processamento.       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP Contabilizacao Off-Line Financeiro                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OldFreeProcItvl( cChave )

Local cFile 	:= ""
Local cAliasTMP := ""
Local nER		:= 0
Local nCTBSERT	:= GetNewPar( "MV_CTBSERT", 1000) /// Tempo em Milisegundos (Retry)
Local lFilExc   := .F.

nCTBSERT := iIf(nCTBSERT == 0, 1000, nCTBSERT)
cChave := "_" + substr( cChave, 2, Len( cChave ) )	

cAliasTMP := cChave	

cFile 	:= cChave + AllTrim( cEmpAnt )

If GetNewPar( "MV_CTBNFSE" , "1" ) == "2"  
	Return 	/// Se o semaforo estiver desligado (Default é ligado), permite o processamento.
EndIf

If ! File( cFile + __cExt )
	Return
EndIf

If Select( cAliasTMP ) <= 0
	Return
EndIf

lFilExc := CTBExcFil()

While ! LockByName( cChave + "ctbprc" + cEmpAnt, .T., lFilExc, .T.)
    nER++

	If !__lBlind
		MsAguarde({|| Sleep(nCTBSERT) }, STR0001+ALLTRIM(STR(nER)), STR0002)//"Semaforo de processamento... tentativa "#"Aguarde, arquivo sendo criado por outro usuário."
	Else
		Sleep( nCTBSERT )	
	EndIf

	If nER > 5	/// A PARTIR DA QUINTA TENTATIVA
		If !__lBlind
			If Aviso(STR0003,STR0004,{STR0005,STR0006},2) == 2//"Gravacao de Semaforo de processamento."#"Não foi possivel acesso exclusivo para gravar o semaforo de processamento."#"Repetir"#"Fechar"
				ProcLogAtu("ERRO",STR0007,STR0008+STR0009)	 //"Atenção!"###"Este processo esta sendo utilizado com parametros conflitantes ( mesmo periodo ou carteiras ) por outro usuário ( "###" ) no momento. Verifique o período e os parametros selecionados para o processamento ou tente novamente mais tarde."
				Return
			Else
				nER := 0
			EndIf		

		ElseIf nER >= 30
			ProcLogAtu("ERRO",STR0007,STR0008+STR0009)	 //"Atenção!"###"Este processo esta sendo utilizado com parametros conflitantes ( mesmo periodo ou carteiras ) por outro usuário ( "###" ) no momento. Verifique o período e os parametros selecionados para o processamento ou tente novamente mais tarde."
			Return
		EndIf
    EndIf
EndDo

dbSelectArea( cAliasTMP )

If ! Eof()
	If (cAliasTMP)->( MsRLock( (cAliasTmp)->(Recno()) ) ) ///DEIXA REGISTRO ALOCADO com MsRLock em função de transções...
		Field->HORAF	:= Time()
		Field->DATAF	:= Date()

		MsRUnlock()
	EndIf

	MsRLock( (cAliasTmp)->(Recno()) )///DEIXA REGISTRO ALOCADO com MsRLock em função de transções...

	(cAliasTMP)->(dbDelete())

	MsRUnlock()
	dbCloseArea()
EndIf

UnLockByName( cChave + "ctbprc" + cEmpAnt, .T., lFilExc, .T. )

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CtbDestrav³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 24.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Destrava e retorna nro. do documento                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CtbDestrava(dData,cLote,cSubLote,cDoc,CTF_LOCK)             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhuma	                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 = Data do Lancamento Contabil                        ³±±
±±³          ³ ExpC1 = Lote                                               ³±±
±±³          ³ ExpC2 = Sub-Lote                                           ³±±
±±³          ³ ExpC3 = Documento                                          ³±±
±±³          ³ ExpN1 = Semaforo                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbDestrava(dData,cLote,cSubLote,cDoc,CTF_LOCK,lSimula,cTabCTK,cTabCT2)

Local aSaveArea := GetArea()
Local aAreaCT2  := CT2->(GetArea())
Local cChaveCT2	:= ""

Default lSimula	:= .F.
Default cTabCTK	:= "CTK"
Default cTabCT2	:= "CT2"

If  __lRelease  == NIL
 	__lRelease  := CTF->(FieldPos('CTF_USADO'))>0
EndIf	

If _lOracle == NIL
	_lOracle := ( Upper(Alltrim(TcGetDb()))=="ORACLE" )
EndIf

If CTF_LOCK > 0
	dbSelectArea("CT2")
	If lSimula .and. !(Type("cFunname") <> "U" .and. (cFunname == "FINA840" .or. cFunname == "FINA087A"))
		dbSelectArea("SIX")
		dbSetOrder(1)		//INDICE+ORDEM
		If SIX->(dbSeek("CT21"))
			cChaveCT2 := AllTrim(SIX->CHAVE)
			IndRegua("CT2", cTabCT2, cChaveCT2, , , )
		EndIf
		dbSelectArea("CT2")
	Else
		dbSetOrder(1)
	EndIf
	If CT2->(!MsSeek(xFilial("CT2")+Dtos(dData)+cLote+cSubLote+cDoc))
		UnlockDoc(@CTF_LOCK)	
	Else
		//AQUI Na Master do tfs
		If !__lRelease
			Leave1Code("CTF"+CTF->(CTF_FILIAL+DTOS(CTF_DATA)+CTF_LOTE+CTF_SBLOTE+CTF_DOC) )
		Endif
		CTF->(MsUnlock())

		If _lOracle
			If _nRecCTFLk > 0        //variaveis static utilizada na OldProxDoc
				dbSelectArea("CTF")
				CTF->(MsGoto(_nRecCTFLk))
				CTF->( MsUnlock() )
				_nRecCTFLk := 0
			EndIf
			If _nRecCT2Lk > 0      //variaveis static utilizada na OldProxDoc
				dbSelectArea("CT2")
				CT2->(MsGoto(_nRecCT2Lk))
				CT2->( MsUnlock() )
				_nRecCT2Lk := 0
			EndIf
			UnLockbyName(_cKey_CTF)
			_cKey_CTF        := ""
		EndIf

	EndIf
Endif

RestArea(aAreaCT2)
RestArea(aSaveArea)

aSize(aAreaCT2,0)
aAreaCT2 := nil 

aSize(aSaveArea,0)
aSaveArea := nil 
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBSerialIºAutor  ³Marcos S. Lobo      º Data ³  06/26/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cria e checa semaforo de processamento por rotina 		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP Processos SigaCTB - Serializacao                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±³Parametros³cChave- Chave do programa que esta chamando a função		  ³±±
±±³          ³cOnOff  Indicador se trata-se de rotina on-line/off-line    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T./.F.                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CtbSerialI( cChave, cONOFF, cFILDE, cFILATE, dDataDe, dDataAte )
Local lRet := .T.
If  __lRelease  == NIL
 	__lRelease  := CTF->(FieldPos('CTF_USADO'))>0
EndIf	
If !__lRelease
	Return OldICtbSerial( cChave, cONOFF, cFILDE, cFILATE)
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OldCTBSerialIºAutor  ³Totvs            º Data ³  13/08/2020 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cria e checa semaforo de processamento por rotina 		  º±±
±±º          VERSÕES MENORES QUE 12.1.31                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP Processos SigaCTB - Serializacao                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±³Parametros³cChave- Chave do programa que esta chamando a função		  ³±±
±±³          ³cOnOff  Indicador se trata-se de rotina on-line/off-line    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T./.F.                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OldICtbSerial( cChave, cONOFF, cFILDE, cFILATE )

Local lRet		:= .F.
Local lRet1		:= .F.
Local aAreaOri	:= GetArea()
Local nER		:= 0 
Local cFile		:= ""
Local lFiliais	:= .F.
Local cFilialCt2
local cThReadID	:= threadID()
local cFunName	:= funName()
Local cCTBSER	:= GetNewPar( "MV_CTBSER"	, "1" )	/// 1 =Ligado, 2=Desligado, 3=TestMode
Local nCTBSERT	:= GetNewPar( "MV_CTBSERT"	, 1000) /// Tempo em Milisegundos (Retry)
Local lFilExc 	:= .F.

PRIVATE cUserCTB	:= PADR( 'SCHED', 15 )
PRIVATE cAliasTMP	:= ""

If cCTBSER	== "2"	/// Se MV_CTBSER desligado
	RestArea( aAreaOri )
	Return .T.
EndIf

dbSelectArea( "CT2" )
cFilialCt2 := xFilial("CT2")

DEFAULT cFilDE	:= If( Empty( cFilialCt2 ), ""	, cFilialCt2 )
DEFAULT cFilATE	:= If( Empty( cFilialCt2 ), "ZZ", cFilialCt2 )
DEFAULT cChave	:= "ctbproc"
DEFAULT cONOFF	:= "OFF"

nCTBSERT := iIf(nCTBSERT == 0, 1000, nCTBSERT)
If Empty( cChave ) .or. cChave == nil
	cChave := "ctbproc"
EndIf

cChave := "_" + Lower( cChave )	/// Atribui LowerCase por causa do Linux/Unix (case sensitive)

cAliasTMP := cChave

If ! __lBlind
	cUserCTB := cUserName
EndIf
 
lFilExc := CTBExcFil()

While ! LockByName( cChave + "SERIAL" + cEmpAnt ,.T., lFilExc, .T. )
    nER++

	If ! __lBlind
		MsAguarde( {|| Sleep( nCTBSERT ) }, "1." + STR0001+ALLTRIM(STR(nER)), STR0002) //"Semaforo de processamento... tentativa " #"Aguarde, arquivo sendo criado por outro usuário."
	Else
		sleep( nCTBSERT )
		FWLogMsg('INFO',, 'CTBXSEM', cFunName, '', '01', 'SLEEP LockByName segurando: ' + cValToChar(nER) + " - " + str(cThReadID) , 0, 0, {})
	EndIf

	If nER >= 5	 /// A PARTIR DA QUINTA TENTATIVA
		If !__lBlind
			If Aviso(STR0003,STR0004,{STR0005,STR0006},2) == 2//"Criação de Semaforo de processamento."#"Não foi possivel acesso exclusivo para criar o semaforo de processamento."#"Repetir"#"Fechar"
				RestArea(aAreaOri)
				Return .F.
			Else
				nER := 0
			EndIf		

		ElseIf nER >= 30
			RestArea(aAreaOri)
			Return .F.
		EndIf
    EndIf
EndDo

// nome do temporario
cFile := cChave + AllTrim( cEmpAnt )

// função para a criação do temporario do semaforo de processamento
IF ! CtbProcTmp( cFile )
	coNoutR( "|" + str(cThReadID) + "| Erro na criação do arquivo de semaforo." )
	UnLockByName( cChave + "SERIAL" + cEmpAnt, .T., lFilExc, .T. )  
	Return .F.
Endif

If Select( cAliasTMP ) <= 0
	coNoutR( "|" + str(cThReadID) + "| Erro ao selecionar o arquivo de semaforo." )
	UnLockByName( cChave + "SERIAL" + cEmpAnt, .T., lFilExc, .T. )  
	Return .F.
Endif

dbSelectArea( cAliasTMP )
dbGoTop()

lSai		:= .F.
lRet1  		:= .T.
nER			:= 0
lFiliais	:= (cAliasTMP)->( FieldPos("FILIALI") > 0) 

While ! lSai .and. (cAliasTMP)->(!Eof())

	IF ! Deleted()
		If cONOFF == "ON"/// se for processamento ON-LINE verifica se existe OFF-Line rodando

			If (cAliasTMP)->CONOFF == "OFF"
				If SimpleLock()
					Reclock(cAliasTMP)			/// SE CONSEGUIR ALOCAR 	
					(cAliasTMP)->(dbDelete())		/// NAO TEM CONCORRENCIA
					MsUnlock()
				Else
					If lFiliais
						IF cFilDe <= ( cAliasTMP )->FILIALI .and. cFilAte >= (cAliasTMP)->FILIALF
							lRet1 := .F.
						ElseIF cFilDe >= (cAliasTMP)->FILIALI .and. cFilDe <= (cAliasTMP)->FILIALF
							lRet1 := .F.
						ElseIf cFilAte >= (cAliasTMP)->FILIALI .and. cFilAte <= (cAliasTMP)->FILIALF
							lRet1 := .F.
						ElseIf cFilDe > cFilAte
							lRet1 := .F.		
						Endif	  
					Else
						If ( (cAliasTMP)->THREADID <> ThreadID() ) // se a thread for diferente, travo o processo
							lRet1 := .F.					/// PROCESSO "OFF" EM USO POR OUTRO USUÁRIO			
						Endif
					EndIf
				EndIf
			Endif
		Else			/// se for processamento OFF-LINE verifica tanto ON-line quanto OFF-Line rodando
			If SimpleLock()
				Reclock(cAliasTMP)				/// SE CONSEGUIR ALOCAR 	
				(cAliasTMP)->(dbDelete())		/// NAO TEM CONCORRENCIA
				MsUnlock()
			Else
				If lFiliais
					IF cFilDe <= ( cAliasTMP )->FILIALI .and. cFilAte >= (cAliasTMP)->FILIALF
						lRet1 := .F.
					ElseIF cFilDe >= (cAliasTMP)->FILIALI .and. cFilDe <= (cAliasTMP)->FILIALF
						lRet1 := .F.
					ElseIf cFilAte >= (cAliasTMP)->FILIALI .and. cFilAte <= (cAliasTMP)->FILIALF
						lRet1 := .F.
					ElseIf cFilDe > cFilAte
						lRet1 := .F.		
					Endif	    
				Else
					If ( (cAliasTMP)->THREADID <> cThReadID)  // se a thread for diferente, travo o processo
						lRet1 := .F.				    	/// PROCESSO "OFF" EM USO POR OUTRO USUÁRIO			
					Endif
				EndIf
			EndIf
		EndIf
	    
		If ! lRet1
			nER++
			/// SE LOCALIZOU NO MESMO PERIODO E NAS MESMAS FILIAIS
			If nER <= 5

				If ! __lBlind
					msAguarde({|| sleep(nCTBSERT) }, "2." + STR0001 + allTrim( str(nER) ), STR0002) //"Semaforo de processamento... tentativa "#"Aguarde, arquivo sendo criado por outro usuário."				
				Else
					sleep( nCTBSERT )
					FWLogMsg('INFO',, 'CTBXSEM', cFunName, '', '01', 'SLEEP segurando: ' + cValToChar(nER) + " - " + str(cThReadID) , 0, 0, {})
				EndIf
				lRet1		:= .T.
				dbGoTop()
				Loop		
			Else
				If !__lBlind
					If cONOFF == "ON"
						Aviso(STR0003,STR0004,{STR0005},2) //"Criação de Semaforo de processamento."#"Não foi possivel acesso exclusivo para criar o semaforo de processamento."#"Repetir"#"Fechar"
						nER			:= 0
						lRet1		:= .T.
						dbGoTop()
						Loop
					Else					/// PROCESSOS OFF-LINE
						If Aviso(STR0003,STR0004,{STR0005,STR0006},2) == 2//"Criação de Semaforo de processamento."#"Não foi possivel acesso exclusivo para criar o semaforo de processamento."#"Repetir"#"Fechar"
							/// SE OPTAR POR FECHAR - CANCELA O PROCESSO (VOLTA AO MENU)
							MsgInfo(STR0010)
							lSai := .T.
						Else	/// SE OPTAR POR REPETIR A TENTATIVA
							nER			:= 0
							lRet1		:= .T.
							dbGoTop()
							Loop
						EndIf
					EndIf
				Else
					If cONOFF == "ON"
						nER			:= 0
						lRet1		:= .T.
						dbGoTop()
						Loop
					Else
						FWLogMsg('INFO',, 'CTBXSEM', cFunName, '', '01', STR0010 + " - " + str(cThReadID) , 0, 0, {})
						lSai := .T.
					EndIf
				EndIf
			EndIf
		EndIf

	Endif

	( cAliasTMP )->(dbSkip())
EndDo

If ! lSai
	RecLock( cAliasTMP, .T. )

	Field->CONOFF	:= cONOFF
	Field->CROTINA	:= cFunName
	Field->FILIALI	:= cFILDE
	Field->FILIALF	:= cFILATE
	Field->CUSER	:= cUserCTB
	Field->HORAI	:= Time()
	Field->DATAI    := Date()
	Field->THREADID	:= ThreadID()

	MsUnlock()	
	MsRLock( (cAliasTMP)->(Recno()) ) ///DEIXA REGISTRO ALOCADO com MsRLock em função de transções...

	lRet := .T.		///PROCESSAMENTO PODE SER EFETUADO

	If cCTBSER == "3"
		msgInfo( cFunName + " Lock." , "ID: " + allTrim( str( threadID() ) ) + " - Process type " + cONOFF + " Line" )
	EndIf
EndIf

UnLockByName( cChave + "SERIAL" + cEmpAnt, .T., lFilExc, .T. )
FreeUsedCode()  //libera codigos ainda travados

RestArea( aAreaOri )

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NewICTBSerialºAutor  ³Totvs            º Data ³  13/08/2020 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cria e checa semaforo de processamento por rotina 		  º±±
±±º          VERSÕES MAIORES OU IGUAIS A 12.1.31                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP Processos SigaCTB - Serializacao                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±³Parametros³cChave- Chave do programa que esta chamando a função		  ³±±
±±³          ³cOnOff  Indicador se trata-se de rotina on-line/off-line    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T./.F.                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NewICtbSerial( cChave, cONOFF, cFILDE, cFILATE, dDataDe, dDataAte )
Local lRet		:= .T.
Local aAreaOri	:= GetArea()
Local nER		:= 0 
Local cFilialCt2
local cThReadID	:= threadID()
local cFunName	:= funName()
Local cCTBSER	:= GetNewPar( "MV_CTBSER"	, "1" )	/// 1 =Ligado, 2=Desligado, 3=TestMode
Local nCTBSERT	:= GetNewPar( "MV_CTBSERT"	, 1000) /// Tempo em Milisegundos (Retry)
Local lFilExc 	:= .F.

PRIVATE cUserCTB	:= PADR( 'SCHED', 15 )
//PRIVATE cAliasTMP	:= ""

If cCTBSER	== "2"	/// Se MV_CTBSER desligado
	RestArea( aAreaOri )
	Return .T.
EndIf

dbSelectArea( "CT2" )
cFilialCt2 := xFilial("CT2")

DEFAULT cFilDE	:= If( Empty( cFilialCt2 ), " "	, cFilialCt2 )
DEFAULT cFilATE	:= If( Empty( cFilialCt2 ), "ZZ", cFilialCt2 )
DEFAULT cChave	:= "ctbproc"
DEFAULT cONOFF	:= "OFF"

nCTBSERT := iIf(nCTBSERT == 0, 1000, nCTBSERT)
If Empty( cChave ) .or. cChave == nil
	cChave := "ctbproc"
EndIf

cChave := "_" + Lower( cChave )	/// Atribui LowerCase por causa do Linux/Unix (case sensitive)

//cAliasTMP := cChave

If ! __lBlind
	cUserCTB := cUserName
EndIf
 
lFilExc := CTBExcFil()

//While ! LockByName( cChave + "SERIAL" + cEmpAnt ,.T., lFilExc, .T. )
While ! LockByName( cChave + "SERIAL" + cEmpAnt ,.T., lFilExc, .T.)
    nER++

	If ! __lBlind
		MsAguarde( {|| Sleep( nCTBSERT ) }, "1." + STR0001+ALLTRIM(STR(nER)), STR0002) //"Semaforo de processamento... tentativa " #"Aguarde, arquivo sendo criado por outro usuário."
	Else
		sleep( nCTBSERT )
		FWLogMsg('INFO',, 'CTBXSEM', cFunName, '', '01', 'SLEEP LockByName segurando: ' + cValToChar(nER) + " - " + str(cThReadID) , 0, 0, {})
	EndIf

	If nER >= 5	 /// A PARTIR DA QUINTA TENTATIVA
		If !__lBlind
			If Aviso(STR0003,STR0004,{STR0005,STR0006},2) == 2//"Criação de Semaforo de processamento."#"Não foi possivel acesso exclusivo para criar o semaforo de processamento."#"Repetir"#"Fechar"
				RestArea(aAreaOri)
				Return .F.
			Else
				nER := 0
			EndIf		

		ElseIf nER >= 30
			RestArea(aAreaOri)
			Return .F.
		EndIf
    EndIf
EndDo

// nome do temporario
/*cFile := cChave + AllTrim( cEmpAnt )

// função para a criação do temporario do semaforo de processamento
IF ! CtbProcTmp( cFile )
	coNoutR( "|" + str(cThReadID) + "| Erro na criação do arquivo de semaforo." )
	UnLockByName( cChave + "SERIAL" + cEmpAnt, .T., lFilExc, .T. )  
	Return .F.
Endif

If Select( cAliasTMP ) <= 0
	coNoutR( "|" + str(cThReadID) + "| Erro ao selecionar o arquivo de semaforo." )
	UnLockByName( cChave + "SERIAL" + cEmpAnt, .T., lFilExc, .T. )  
	Return .F.
Endif

dbSelectArea( cAliasTMP )
dbGoTop()

lSai		:= .F.
lRet1  		:= .T.
nER			:= 0
lFiliais	:= (cAliasTMP)->( FieldPos("FILIALI") > 0) 

While ! lSai .and. (cAliasTMP)->(!Eof())

	IF ! Deleted()
		If cONOFF == "ON"/// se for processamento ON-LINE verifica se existe OFF-Line rodando

			If (cAliasTMP)->CONOFF == "OFF"
				If SimpleLock()
					Reclock(cAliasTMP)			/// SE CONSEGUIR ALOCAR 	
					(cAliasTMP)->(dbDelete())		/// NAO TEM CONCORRENCIA
					MsUnlock()
				Else
					If lFiliais
						IF cFilDe <= ( cAliasTMP )->FILIALI .and. cFilAte >= (cAliasTMP)->FILIALF
							lRet1 := .F.
						ElseIF cFilDe >= (cAliasTMP)->FILIALI .and. cFilDe <= (cAliasTMP)->FILIALF
							lRet1 := .F.
						ElseIf cFilAte >= (cAliasTMP)->FILIALI .and. cFilAte <= (cAliasTMP)->FILIALF
							lRet1 := .F.
						ElseIf cFilDe > cFilAte
							lRet1 := .F.		
						Endif	  
					Else
						If ( (cAliasTMP)->THREADID <> ThreadID() ) // se a thread for diferente, travo o processo
							lRet1 := .F.					/// PROCESSO "OFF" EM USO POR OUTRO USUÁRIO			
						Endif
					EndIf
				EndIf
			Endif
		Else			/// se for processamento OFF-LINE verifica tanto ON-line quanto OFF-Line rodando
			If SimpleLock()
				Reclock(cAliasTMP)				/// SE CONSEGUIR ALOCAR 	
				(cAliasTMP)->(dbDelete())		/// NAO TEM CONCORRENCIA
				MsUnlock()
			Else
				If lFiliais
					IF cFilDe <= ( cAliasTMP )->FILIALI .and. cFilAte >= (cAliasTMP)->FILIALF
						lRet1 := .F.
					ElseIF cFilDe >= (cAliasTMP)->FILIALI .and. cFilDe <= (cAliasTMP)->FILIALF
						lRet1 := .F.
					ElseIf cFilAte >= (cAliasTMP)->FILIALI .and. cFilAte <= (cAliasTMP)->FILIALF
						lRet1 := .F.
					ElseIf cFilDe > cFilAte
						lRet1 := .F.		
					Endif	    
				Else
					If ( (cAliasTMP)->THREADID <> cThReadID)  // se a thread for diferente, travo o processo
						lRet1 := .F.				    	/// PROCESSO "OFF" EM USO POR OUTRO USUÁRIO			
					Endif
				EndIf
			EndIf
		EndIf
	    
		If ! lRet1
			nER++
			/// SE LOCALIZOU NO MESMO PERIODO E NAS MESMAS FILIAIS
			If nER <= 5

				If ! __lBlind
					msAguarde({|| sleep(nCTBSERT) }, "2." + STR0001 + allTrim( str(nER) ), STR0002) //"Semaforo de processamento... tentativa "#"Aguarde, arquivo sendo criado por outro usuário."				
				Else
					sleep( nCTBSERT )
					FWLogMsg('INFO',, 'CTBXSEM', cFunName, '', '01', 'SLEEP segurando: ' + cValToChar(nER) + " - " + str(cThReadID) , 0, 0, {})
				EndIf
				lRet1		:= .T.
				dbGoTop()
				Loop		
			Else
				If !__lBlind
					If cONOFF == "ON"
						Aviso(STR0003,STR0004,{STR0005},2) //"Criação de Semaforo de processamento."#"Não foi possivel acesso exclusivo para criar o semaforo de processamento."#"Repetir"#"Fechar"
						nER			:= 0
						lRet1		:= .T.
						dbGoTop()
						Loop
					Else					/// PROCESSOS OFF-LINE
						If Aviso(STR0003,STR0004,{STR0005,STR0006},2) == 2//"Criação de Semaforo de processamento."#"Não foi possivel acesso exclusivo para criar o semaforo de processamento."#"Repetir"#"Fechar"
							/// SE OPTAR POR FECHAR - CANCELA O PROCESSO (VOLTA AO MENU)
							MsgInfo(STR0010)
							lSai := .T.
						Else	/// SE OPTAR POR REPETIR A TENTATIVA
							nER			:= 0
							lRet1		:= .T.
							dbGoTop()
							Loop
						EndIf
					EndIf
				Else
					If cONOFF == "ON"
						nER			:= 0
						lRet1		:= .T.
						dbGoTop()
						Loop
					Else
						FWLogMsg('INFO',, 'CTBXSEM', cFunName, '', '01', STR0010 + " - " + str(cThReadID) , 0, 0, {})
						lSai := .T.
					EndIf
				EndIf
			EndIf
		EndIf

	Endif

	( cAliasTMP )->(dbSkip())
EndDo

If ! lSai
	RecLock( cAliasTMP, .T. )

	Field->CONOFF	:= cONOFF
	Field->CROTINA	:= cFunName
	Field->FILIALI	:= cFILDE
	Field->FILIALF	:= cFILATE
	Field->CUSER	:= cUserCTB
	Field->HORAI	:= Time()
	Field->DATAI    := Date()
	Field->THREADID	:= ThreadID()

	MsUnlock()	
	MsRLock( (cAliasTMP)->(Recno()) ) ///DEIXA REGISTRO ALOCADO com MsRLock em função de transções...

	lRet := .T.		///PROCESSAMENTO PODE SER EFETUADO

	If cCTBSER == "3"
		msgInfo( cFunName + " Lock." , "ID: " + allTrim( str( threadID() ) ) + " - Process type " + cONOFF + " Line" )
	EndIf
EndIf*/

//UnLockByName( cChave + "SERIAL" + cEmpAnt, .T., lFilExc, .T. )
//FreeUsedCode()  //libera codigos ainda travados

RestArea( aAreaOri )

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBSerialFºAutor  ³Marcos S. Lobo      º Data ³  06/26/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Libera registro alocado no semaforo de processamento.       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP Processos SigaCTB - Serializacao                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CtbSerialF( cChave, cONOFF )
If  __lRelease  == NIL
 	__lRelease  := CTF->(FieldPos('CTF_USADO'))>0
EndIf	
If !__lRelease
	Return OldFCtbSerial( cChave, cONOFF )
EndIf
Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NewFCTBSerialºAutor  ³TOTVS            º Data ³  13/08/2020 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Libera registro alocado no semaforo de processamento.       º±±
±±º          ³ VERSÕES MENORES A 12.1.31                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP Processos SigaCTB - Serializacao                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NewFCtbSerial( cChave, cONOFF )
Local aAreaOri	:= GetArea()
Local cCTBSER	:= GetNewPar( "MV_CTBSER" , "1")	/// 1 =Ligado, 2=Desligado, 3=TestMode
Local lFilExc := .F.

If cCTBSER == "2"	/// Se MV_CTBSER desligado
	RestArea( aAreaOri )
	ConoutR( "1. Semaforo desligado !" )
	Return .T.
EndIf

If Empty( cChave ) 
	cChave := "ctbproc"
EndIf

cChave := "_" + Lower( cChave )		/// Atribui LowerCase por causa do Linux/Unix (case sensitive)

lFilExc := CTBExcFil()

UnLockByName( cChave + "SERIAL" + cEmpAnt, .T., lFilExc, .T. )
FreeUsedCode()  //libera codigos ainda travados

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OldFCTBSerialºAutor  ³TOTVS            º Data ³  13/08/2020 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Libera registro alocado no semaforo de processamento.       º±±
±±º          ³ VERSÕES MENORES A 12.1.31                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP Processos SigaCTB - Serializacao                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OldFCtbSerial( cChave, cONOFF )

Local aAreaOri	:= GetArea()
Local cFile 	:= ""
Local cAliasTMP := cChave
Local cCTBSER	:= GetNewPar( "MV_CTBSER" , "1")	/// 1 =Ligado, 2=Desligado, 3=TestMode
Local lFilExc := .F.

If cCTBSER == "2"	/// Se MV_CTBSER desligado
	RestArea( aAreaOri )
	ConoutR( "1. Semaforo desligado !" )
	Return .T.
EndIf

If Empty( cChave ) 
	cChave := "ctbproc"
EndIf

cChave := "_" + Lower( cChave )		/// Atribui LowerCase por causa do Linux/Unix (case sensitive)
cAliasTMP := cChave

cFile := cChave + AllTrim( cEmpAnt )

If ! File( cFile + __cExt )
	RestArea( aAreaOri )
	ConoutR( "2. Semaforo desligado !" )
	Return .F.
EndIf

If Select( cAliasTMP ) <= 0
	RestArea( aAreaOri )
	ConoutR( "3. Semaforo desligado !" )
	Return .F.
EndIf

dbSelectArea( cAliasTMP )

If ! Eof() .And. ! Deleted()
	If SimpleLock()

		Field->HORAF	:= Time()
		Field->DATAF	:= Date()
		MsUnlock()
	
		RecLock(cAliasTmp)
		( cAliasTMP )->( dbDelete() )
		MsUnlock()
	EndIf

	If cCTBSER == "3"
		MsgInfo( FunName() + " UnLock." , "ID: " + ALLTRIM( STR( ThreadID() )) + " - Process type " + cONOFF + " Line")	
	EndIf
EndIf

lFilExc := CTBExcFil()

UnLockByName( cChave + "SERIAL" + cEmpAnt, .T., lFilExc, .T. )
FreeUsedCode()  //libera codigos ainda travados

dbSelectArea( cAliasTMP )
dbCloseArea()

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ct1MLock  ºAutor  ³Marcos S. Lobo      º Data ³  01/08/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ct1MLock(aCodes)

Local lLockOk   := .T.
Local aAreaBak	:= GetArea()
Local aAreaTAB	:= {}
Local nL
Local cFilTAB	:= ""
Local lOkError  := .T.
Local bErrBlock	:= ErrorBlock( { |e| lOkError := CtbChkErro(e) } )
LOCAL lLockCT1	:= .T.

BEGIN SEQUENCE

	dbSelectArea( "CT1" )
	aAreaTAB := GetArea()
	
	If ValType(__lCT1LSTLCK) == "U"
		__lCT1LSTLCK := FieldPos("CT1_LSTLCK") > 0
		__lCT1LOCKED := FieldPos("CT1_LOCKED") > 0
	EndIf
	
	dbSetOrder( 1 )
	cFilTAB := xFilial( "CT1" )
	
	For nL := 1 to Len( aCodes )
		If ! Empty( aCodes[nL] )

			dbSelectArea( "CT1" )
			If MsSeek( cFilTAB + aCodes[nL] )

				If LockByName( "CT1" + cEmpAnt + CT1->( CT1_FILIAL + CT1_CONTA ), .T., .F., .T. )

					If InTransact()
						lLockCT1 := RecLock("CT1")
					Else
						lLockCT1 := MsRLock()
					EndIf

					IF ( CT1->( Recno() ) <> 0 .And. CT1->( ! Eof() ) )
						aAdd(__aCTBMLock,Recno())
	
						If __lCT1LSTLCK
	
							REPLACE CT1->CT1_LSTLCK WITH (cUserName+"|"+RetCodUsr()+"|"+Alltrim(FunName())+"|"+DTOC(Date())+"|"+Time())
	
							If __lCT1LOCKED
								REPLACE CT1->CT1_LOCKED WITH "S"
							EndIf
						EndIf
					ENDIF
	
					If lLockCT1 // se consegui locar o registro
						IF ! InTransact() //Nao retirar ## verifica se o mesmo esta em transação
							CT1->( MsRUnLock() )
						ELSE
							CT1->(MsUnlock())
						Endif
					EndIf
				Else
					lLockOk := .F.
					Ct1MUnLock()
					Exit
				EndIf		
			EndIf
		EndIf
	Next
	
	RestArea(aAreaTAB)
	RestArea(aAreaBak)

END SEQUENCE

ErrorBlock( bErrBlock )
	
/* *** COMENTADO... APENAS SE NECESSARIO DEBUGAR/TESTAR SEMAFORO DAS CONTAS COM CONCORRENCIA (AVALIAR USO DE PE/PARAMETRO PARA HABILITAR, SE NECESSARIO)
If lLockOk
	nQbL 		:= 0
	nLenCodes	:= Len(aCodes)
	cContas		:= ""
	For nL := 1 to nLenCodes
		nQbl++
		cContas += alltrim(aCodes[nL])
		If nL < nLenCodes
			cContas += ", "
			If nQbl == 2					///Definida quebra de linha a cada 2 contas
				cContas += CRLF
				nQbl := 0
			EndIf
		EndIf
	Next
	MsgInfo("Semaforo nas contas:"+CRLF+cContas+CRLF+"Ativado !",FunName()+" Thread:"+ALLTRIM(STR( THREADID() )) )
EndIf
*/

Return(lLockOK)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ct1MUnlockºAutor  ³Marcos S. Lobo      º Data ³  01/08/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ct1MUnLock()		/// Libera as contas alocadas pela Ct1Mlock()

Local aAreaBak	:= GetArea()
Local aAreaTAB	:= {}
Local nL		:= 1
Local lLockCT1  := .F.

If ValType(__aCTBMLock) == "A" .and. Len(__aCTBMLock) > 0
	For nL := 1 to Len(__aCTBMLock)
		dbSelectArea("CT1")
		aAreaTAB := GetArea()
		MsGoTo(__aCTBMLock[nL])

		If __lCT1LOCKED
			If InTransact()
				lLockCT1 := RecLock("CT1")
			Else
				lLockCT1 := MsRLock()
			EndIf
	
			REPLACE CT1->CT1_LOCKED WITH "N" // limpo o flag de lock do ct1

			If lLockCT1 // se consegui locar o registro
				IF ! InTransact() //Nao retirar
					CT1->( MsRUnLock() )
				ELSE
					MsUnlock()
				Endif
			EndIf

			__lCT1LOCKED := .F.
		EndIf

		UnLockByName( "CT1" + cEmpAnt + CT1->( CT1_FILIAL + CT1_CONTA ), .T., .F., .T. ) // retiro a trava do lockbyname para cada conta
	Next

	__aCTBMLock  := {}
	__lCT1LSTLCK := nil

	RestArea(aAreaTAB)
EndIf

RestArea(aAreaBak)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBcanGrv ºAutor  ³Marcos S. Lobo      º Data ³  01/29/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CtbCanGrv(aTravas,lAtSldBase,lAtuSldCT7,lAtuSldCT3,lAtuSldCT4,lAtuSldCTI,lLiberaW,lUltCJ)

Local lPodeGrv := .F.
Local LWhile   := .T.				///SE for o CTBA102/CTBA105/CTBA103 apenas retorna .F. para tentar gravacao da próxima linha

DEFAULT aTravas 	:= {}
DEFAULT lAtSldBase	:= .T.
DEFAULT lAtuSldCT7	:= .T.
DEFAULT lAtuSldCT3	:= .T.
DEFAULT lAtuSldCT4	:= .T.
DEFAULT lAtuSldCTI	:= .T.
DEFAULT lLiberaW 	:= .F.				///CTBA102/CTBA105/CTBA103 = .T., demais programas .F. CTBA101,CTBA280,CTBA340, etc.
DEFAULT lUltCJ		:= .F.

nTry     	:= 0
nTryGer		:= 0
If __nT2Abort == Nil
	__nT2Abort 	:= GetNewPar("MV_CTSNDT",15) 		///Contabilidade Saldos Numero de Tentativas de Alocacao
EndIf
If __nTETry == Nil
	__nTETry		:= GetNewPar("MV_CTSTET",3000)	///Contabilidade Saldos Tempo Entre Tentativas (milisegundos) 
EndIf
If __nTSA == Nil
	__nTSA		:= GetNewPar("MV_CTSTSA",5)		///Contabilidade Saldos Tentativas sem alerta
EndIf

While !lPodeGrv .and. If(lLiberaW,lWhile,.T.)

	//Se estiver com saldos off-line, ou, todos os pontos de entrada tiverem desabilitado atualização de saldos.
	If !lAtSldBase .or. ( !lAtuSldCT7 .and. !lAtuSldCT3 .and. !lAtuSldCT4 .and. !lAtuSldCTI )
	   	// Permite a gravação sem semaforo e atualizar saldos.
	   	lPodeGrv := .T.
	Else
		IF __nT2Abort <> 0 .and. nTryGer >= __nT2Abort
			// Se estourou a quantitade máxima de tentativas de atualizar saldos, sem sucesso.
			If !__lBlind
				// Pergunta se deseja gravar sem atualizar saldos.
				If MsgYesNo(STR0010+ALLTRIM(STR(INT(nTryGer)))+STR0011+CRLF+;   //"Foram efetuadas "//" tentativas de atualização de saldo sem sucesso !"//
							STR0012+CRLF+;    //"É possível gravar os lançamento deixando a atualização de saldos para execução através do 'Reprocessamento de Saldos'."
							STR0013+CRLF+;    //"Selecione 'Ok' para gravar lançamentos sem atualizar saldos (recomendado), ou, "
							STR0014,STR0015)  //"Selecione 'Cancelar' para tentar novamente a gravação com atualização de saldos."
					lAtSldBase := .F.
					lPodeGrv := .T.
				EndIf
			Else
				// Em processamentos sem interface assume gravação dos lançamentos sem saldos (caso não consiga alocar as contas)
				lAtSldBase := .F.
				lPodeGrv := .T.
			EndIf
		EndIf
	
		nTry++
		nTryGer++
		
		If nTry >= __nTSA
			cContas := ""
			If !__lBlind
				MsAguarde({|| Sleep(__nTETry) }, STR0015+alltrim(str(int(nTryGer))), STR0016) //"Aguardando liberação de registros...Tentativa: "//"Conta(s) em uso por outro usuário !"
			Else
				Sleep(__nTETry)
			EndIf
		EndIf    	
	
		//Chamar a multlock	
	  	IF CT1MLock(aTravas)    
			lPodeGrv := .T.
		Else          			
			lPodeGrv := .F.
			If lLiberaW				///SE for o CTBA102/CTBA105/CTBA103 apenas retorna .F. para tentar gravacao da próxima linha
				If !lUltCJ			//Se houverem outros conjuntos para atualizar saldos (se não for o último)
					lWhile := .F.	// Libera while para tentar atualizar o proximo conjunto.
				EndIF
			EndIf
		Endif
	Endif
EndDo

Return(lPodeGrv)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |CtbProcTmp³ Autor ³ Renato F. Campos      ³ Data ³ 10/05/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina analizadora do erro                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³CTBXFUNA                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbProcTmp( cFile )

Local lOkError := .T.
Local bErrBlock	:= ErrorBlock( { |e| lOkError := CtbChkErro(e) } )
Local nCTBSERT	:= GetNewPar( "MV_CTBSERT"	, 1000) /// Tempo em Milisegundos (Retry)

nCTBSERT := iIf(nCTBSERT == 0, 1000, nCTBSERT)
BEGIN SEQUENCE
	
	// Verifica se a rotina tem acesso exclusivo ao temporario criado
	// se possuir acesso exclusivo, o mesmo é excluido fisicamente
	If File( cFile + __cExt )
	
		If Select( cAliasTmp ) > 0			
			(cAliasTmp)->(dbCloseArea())
		Endif
	
		dbUseArea( .T.,, cFile, cAliasTMP, .F., .F. ) //COM ACESSO EXCLUSIVO
	
		If ! NETERR()
			
			// parametro de deleção do arquivo de semaforo                                    
			If GetNewPar("MV_CTBSERD",.T.) // .T. deleta o arquivo, .F. passa sem deletar
				If Select(cAliasTmp) > 0
					(cAliasTmp)->(dbCloseArea())					
				Endif
				FErase( cFile + __cExt )
			ElseIf GetNewPar("MV_CTBSERZ",.T.) // .T. efetua o zap no arquivo , .F. passa sem zapear
				dbSelectArea(cAliasTmp)
				If Select( cAliasTmp ) > 0
					ZAP
					(cAliasTmp)->(dbCloseArea())
				Endif				    
			Endif				
		Else
		
			If Select( cAliasTmp ) > 0			//verifica se a tabela esta em uso
				(cAliasTmp)->(dbCloseArea())
			Endif
			
		EndIf
	EndIf
	
	// tenta criar o arquivo temporario
	If ! File( cFile + __cExt )
		aStruct  := {}
	
		AAdd( aStruct, { "CONOFF"	, "C", 3				, 0 } )
		AAdd( aStruct, { "CROTINA"	, "C", 15				, 0 } )
		AAdd( aStruct, { "FILIALI"	, "C", Len( cFilAnt )	, 0 } )
		AAdd( aStruct, { "FILIALF"	, "C", Len( cFilAnt )	, 0 } )
		AAdd( aStruct, { "DTDE"		, "D", 8 				, 0 } )
		AAdd( aStruct, { "DTATE"	, "D", 8 				, 0 } )
		AAdd( aStruct, { "CCART"	, "C", 1				, 0 } )
		AAdd( aStruct, { "CUSER"	, "C", Len( cUserCTB )	, 0 } )
		AAdd( aStruct, { "DATAI"	, "D", 8				, 0 } )
		AAdd( aStruct, { "HORAI"	, "C", Len(Time())		, 0 } )
		AAdd( aStruct, { "DATAF"	, "D", 8				, 0 } )
		AAdd( aStruct, { "HORAF"	, "C", Len(Time())		, 0 } )
		AAdd( aStruct, { "THREADID"	, "N", 10				, 0 } )
	
		MsCreate( cFile , aStruct , __LOCALDRIVER ) 
		Sleep( nCTBSERT )

		cArqTrab := cFile
	Else
		cArqTrab := cFile
	EndIf  
	
	// tenta abrir o temporario
	// se não conseguir abrir o temporario, retornara uma mensagem de erro para o usuario
	If Select( cAliasTMP ) <= 0
		dbUseArea( .T.,, cArqTrab, cAliasTMP, .T., .F. )
	
		IF NETERR()
			If ! __lBlind
				Help(" ",1,"CT5CRIA6",,STR0017,1,0)//"Erro na criação do semaforo de processamentos concorrentes, semaforo desabilitado !"
				Return .F.
			EndIf
		EndIf
	EndIf
END SEQUENCE

ErrorBlock( bErrBlock )

RETURN lOkError


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |CtbChkErro³ Autor ³ Renato F. Campos      ³ Data ³ 10/05/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina analizadora do erro                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³CTBXFUNA                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbChkErro( e )

Local lOkError := .T.

If e:gencode == 20 // fail to create
	lOkError := .F.
	Help(" ",1,"SEMACT5",,STR0017,1,0)//"Erro na criação do arquivo semaforo de processamentos concorrentes, semaforo desabilitado !"
ElseIf ( e:gencode == 35 .Or. e:gencode == 21 )  // fail to open
	lOkError := .F.
	Help(" ",1,"SEMACT51",,STR0018,1,0)//"Erro na abertura do arquivo semaforo de processamentos concorrentes, semaforo desabilitado !"
Else
	// otherwise fail
	lOkError := .F.
	Help( " ",1,"ERR_FORM",,e:Description,3,1)
Endif

If ! lOkError
	Break
Endif

Return lOkError



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  | Ctb102Smlt ºAutor  ³Renato F. Campos  º Data ³  05/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Efetua a verificação de concorrencia entre usuarios         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA102                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ctb102Smlt( cChave )
LOCAL lRetorno := .T.
Local lFilExc := .F.

DEFAULT cChave := CT2->( DTOS( CT2_DATA ) + CT2_LOTE + CT2_SBLOTE + CT2_DOC )

cChave := '__' + Lower( cChave )

IF GetNewPar( "MV_CT2SMLT" , .F. ) == .T. // se estiver configurado para verificar alterações simultaneos

	lFilExc := CTBExcFil() 

	// efetua o lock fisica
	lRetorno := LockByName( cChave + "SMLT" + cEmpAnt ,.T., lFilExc, .T.)
ENDIF

RETURN lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  | Ct102SmltF ºAutor  ³Renato F. Campos  º Data ³  05/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Efetua a liberação da concorrencia entre usuarios           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA102                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ct102SmltF( cChave )
Local lFilExc := .F.

DEFAULT cChave := CT2->( DTOS( CT2_DATA ) + CT2_LOTE + CT2_SBLOTE + CT2_DOC )

cChave := '__' + Lower( cChave )

lFilExc := CTBExcFil() 

UnLockByName( cChave + "SMLT" + cEmpAnt, .T., lFilExc, .T. )

RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} CTBExcFil
Rotina que verifica se o controle do semáforo será por grupo de empresa ou por filial.

Para o controle ser por filial a tabela CT2 deve ser totalmente exclusiva e 
usuario devera ainda retornar .T. no ponto de entrada CTBSMEXC

@author Totvs
@since 02/01/2020
@version 12
/*/
//--------------------------------------------------------------------
Static Function CTBExcFil()
Local lRet			:= .F.


If __lCT2Exc  == NIL
	__lCT2Exc := CTXSEFil()  //chama uma unica vez e coloca retorno na variavel static
EndIf

If __lCT2Exc

	If __lExcFil  == NIL

		If lPEFilExc

			__lExcFil := .F.   //coloca como .F. ao iniciar
			__lExcFil := ExecBlock( "CTBSMEXC" , .F.,.F. ) //recebe variavel logica do ponto de entrada

			If Valtype(__lExcFil) != "L"   //se nao retornar variavel logica retorna false
				__lExcFil := .F.
			EndIf

		Else

			__lExcFil := .F.

		Endif

		lRet := __lExcFil   //atribui retorno variavel static __lExcFil

	Else

		lRet := __lExcFil   //atribui retorno variavel static __lExcFil

	Endif
EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} CTXSEFil
Rotina que verifica se o controle do semáforo será por grupo de empresa ou por filial.

Para o controle ser por filial a tabela CT2 deve ser totalmente exclusiva.

@author Alvaro Camillo Neto
@since 11/02/2016
@version 12 
/*///--------------------------------------------------------------------
Static Function CTXSEFil()
Local lRet			:= .F.
Local cEmpCT2		:= ALLTRIM( UPPER( FWModeAccess("CT2",1) ) )
Local cUniCT2		:= ALLTRIM( UPPER( FWModeAccess("CT2",2) ) )
Local cFilCT2		:= ALLTRIM( UPPER( FWModeAccess("CT2",3) ) )

If cEmpCT2 == 'E' .And. cUniCT2 == 'E' .And. cFilCT2 == 'E'
	lRet := .T.
EndIf

Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ ProxDoc   ³ Autor ³ Pilar S Albaladejo    ³ Data ³04.02.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera pr¢ximo n£mero de Documento baseado na Data / Lote     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ProxDoc ( dDataLan, cLote ,cSublote, @cDoc )	               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. /.F. (Se retornou .F. ‚ por que estourou o doc no Lote) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA105 , CTBA050                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 = Data do lan‡amento								   ³±±
±±³          ³ ExpC1 = Lote Cont bil 									   ³±±
±±³          ³ ExpC2 = Sub-Lote Cont bil								   ³±±
±±³          ³ Expc3 = N§ do Doc (X Referˆncia)							   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                 
FUNCTION ProxDoc(dDataLanc,cLote,cSubLote,cDoc,CTF_LOCK,lSimula,cTabCTK,cTabCT2,lExecauto)

Default cDoc		:= ""
DEFAULT CTF_LOCK	:= 0
Default lSimula		:= .F.
Default cTabCTK		:= "CTK"
Default cTabCT2		:= "CT2"
Default lExecauto	:= .F.
If  __lRelease  == NIL
 	__lRelease  := CTF->(FieldPos('CTF_USADO'))>0
EndIf	
// Retorna CallProxDc p12.1.31  - comentar para validar
If  __lRelease
 	Return CallProxDc(dDataLanc,cLote,cSubLote,@cDoc,@CTF_LOCK,lSimula,cTabCTK,cTabCT2,lExecauto)
Else
	/* Versões anteriores a 12.1.031  */
	Return OldProxDoc(dDataLanc,cLote,cSubLote,@cDoc,@CTF_LOCK,lSimula,cTabCTK,cTabCT2)
EndIf

Return
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OldProxDoc   ³ Autor ³ TOTVS              ³ Data ³18/08/2020³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera pr¢ximo n£mero de Documento baseado na Data / Lote     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ OldProxDoc ( dDataLan, cLote ,cSublote, @cDoc )             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. /.F. (Se retornou .F. ‚ por que estourou o doc no Lote) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA105 , CTBA050                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 = Data do lan‡amento								   ³±±
±±³          ³ ExpC1 = Lote Cont bil 									   ³±±
±±³          ³ ExpC2 = Sub-Lote Cont bil								   ³±±
±±³          ³ Expc3 = N§ do Doc (X Referˆncia)							   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                 
FUNCTION OldProxDoc(dDataLanc,cLote,cSubLote,cDoc,CTF_LOCK,lSimula,cTabCTK,cTabCT2)

Local aArea		:= GetArea()
Local aAreaCTF	:= CTF->(GetArea())
Local aAreaCT2	:= CT2->(GetArea())
Local lRet		:= .T.
Local cKeyCTF	:= ""
Local cChaveCT2	:= ""
Local dDataCTF	:= dDataLanc
Local cKeyCT2	:= ""
Local lAutoInc	:= .T.
Local lApurRes	:= FWIsInCallStack("CTB211PROC") 
Local cUltDoc := ""
Local lMore := .F.
Local lFoundCT2 := .F.
Local nCtd_Lock := 0


Default cDoc		:= ""
DEFAULT CTF_LOCK	:= 0
Default lSimula		:= .F.
Default cTabCTK		:= "CTK"
Default cTabCT2		:= "CT2"

//------------------------------------------------------------------------------------------------------
// No CTBA280 é possivel o cliente definir o número do Documento, entao caso ele o faça e o número seja
// maior que a ultima numeracao, o mesmo é utilizado, caso contrário, é obtida a próxima sequencia
//------------------------------------------------------------------------------------------------------
If !Empty(cDoc)
	cDoc := StrZero(Val(cDoc),6)
EndIf

// Consecutivo por mes, aplica solo para CTF
If lRet .And. cPaisLoc == "MEX"
	dDataCTF := StoD( Substr(DtoS(dDataCTF), 1, 6) + "01" )
EndIf

aAreaCT2 := (cTabCT2)->(GetArea())

dbSelectArea( "CTF" )
dbSetOrder( 1 )
cKeyCTF := xFilial("CTF")+dtos(dDataCTF)+cLote+cSubLote
cKeyCT2 := xFilial("CTF")+dtos(dDataLanc)+cLote+cSubLote

If _lCTBPRXDOC .And. !lSimula
	cDoc := ExecBlock("CTBPRXDOC",.F.,.F.,{dDataLanc,cLote,cSubLote})
Else
	lQuery := .F.
	If _lOracle == NIL
		_lOracle := ( Upper(Alltrim(TcGetDb()))=="ORACLE" )
	EndIf
	_nRecCTFLk := 0  //variavel static
	_nRecCT2Lk := 0 //variavel static
	lFoundCT2 := .F.
	nCtd_Lock := 0
	lMore := .T.

	While lMore

		cQuery := "SELECT Max(CTF_DOC) MAXDOC "
		cQuery += "  FROM " + RetSqlName("CTF") + " CTF "
		cQuery += " WHERE CTF_FILIAL = '" + xFilial("CTF") + "'"
		cQuery += "   AND CTF_DATA = '" + DTOS(dDataCTF) + "' "
		cQuery += "   AND CTF_LOTE = '" + cLote + "' "
		cQuery += "   AND CTF_SBLOTE = '" + cSubLote + "' "
		cQuery += "   AND D_E_L_E_T_ = ' ' "

		If _lCTBPXDCQRY //ExistBlock( 'CTBPXDCQRY' )
			cQuery := Execblock( 'CTBPXDCQRY' , .F. , .F. , {cQuery} )
		Endif

		IF Select( "TMPPRXDOC" ) > 0
			dbSelectArea("TMPPRXDOC")
			("TMPPRXDOC")->(dbCloseArea())
		Endif

		// forço o reposicionamento da CTF para garantir a leitura suja da tabela. Commit multiplo.
		DbSelectArea("CTF")
		DbGoTop()

		// Abro o Cursor do proximo do numero
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPPRXDOC")

		If Select( "TMPPRXDOC" ) > 0

			If _lOracle  //somente para banco de dados Oracle
				If CTF->(dbSeek( xFilial("CTF") + DTOS(dDataCTF) + cLote + cSubLote + AllTrim( ("TMPPRXDOC")->MAXDOC ) ) ) 

					If CTF->( DBRLock() )
						lMore := .F.
						_nRecCTFLk := CTF->( Recno() )
					Else
						Sleep(50)
						nCtd_Lock++
						If nCtd_Lock > 20  //20 x 50 = 1000 = 1seg
							lMore := .F.
							_nRecCTFLk := 0
						EndIf
					EndIf

				Else
				
					lFoundCT2 := CT2->( dbSeek( xFilial("CT2") + DTOS(dDataCTF) + cLote  ) ) 

					If lFoundCT2
						If CT2->( dbRLock() )
							lMore := .F.
							_nRecCT2Lk := CT2->( Recno() )
						Else
							Sleep(50)
							nCtd_Lock++
							If nCtd_Lock > 20   //20 x 50 = 1000 = 1seg
								lMore := .F.
								_nRecCT2Lk := 0
							EndIf
						EndIf
					Else
						lMore := .F.
						_nRecCT2Lk := 0
					EndIf

				EndIf
			Else
				lMore := .F.
			EndIf

			If ! lMore
				If cDoc > AllTrim(("TMPPRXDOC")->MAXDOC)
					lAutoInc := .F.
					cUltDoc:=  AllTrim(("TMPPRXDOC")->MAXDOC)
				Else
					cDoc := AllTrim(("TMPPRXDOC")->MAXDOC)
				EndIf

				dbSelectArea("TMPPRXDOC")
				("TMPPRXDOC")->(dbCloseArea())
				//forca saida do laço lMore
				Exit
			EndIf

		Endif

	EndDo

	dbSelectArea("CTF")

	If STRZERO(VAL(cDoc),6) == "999999"
		If lApurRes
			lRet := .T.
		Else
			lRet := .F.
		EndIf
	Else
		If Empty(cDoc)
			cDoc := "000001"
		ElseIf lAutoInc 
			cDoc := StrZero(Val(cDoc)+1,6)
		ElseIF !lAutoInc .and. Empty(cUltDoc)
			cDoc := "000001"	
		ElseIf !lAutoInc .and. !Empty(cUltDoc) 
			cDoc := StrZero(Val(cUltDoc)+1,6)	
		EndIf
	EndIf
EndIf

If lRet
	dbSelectArea("CT2")
	If lSimula
		dbSelectArea("SIX")
		dbSetOrder(1)		//INDICE+ORDEM
		dbGoTop()
		If SIX->(dbSeek("CT21"))
			cChaveCT2 := AllTrim(SIX->CHAVE)
			IndRegua("CT2", cTabCT2, cChaveCT2, , , )
		EndIf
		dbSelectArea("CT2")
	Else
		dbSetOrder(1)
	EndIf
	While !MayIUseCode("CTF"+cKeyCTF+cDoc) .Or. CTF->(MsSeek(cKeyCTF+cDoc,.F.)) .Or.;
	 		Iif(cPaisLoc == "MEX", !CT2ValDoc(xFilial("CT2"),dDataLanc,cLote,cSubLote,cDoc), CT2->(MsSeek(cKeyCT2+cDoc,.F.)))
		
		Leave1Code("CTF"+cKeyCTF+cDoc)
		If cDoc == "999999"
			lRet := .F.
			Exit
		Else
			cDoc := StrZero(Val(cDoc)+1,6)
		EndIf
	EndDo

	//somente oracle faz mais esta trava com lockbyname - na funcao destrava libera
	If lRet .And. _lOracle
		_cKey_CTF := cEmpAnt+"CTF"+cKeyCTF+cDoc
		While !LockbyName(_cKey_CTF)
			If cDoc == "999999"
				lRet := .F.
				Exit
			Else
				cDoc := StrZero(Val(cDoc)+1,6)
				_cKey_CTF := cEmpAnt+"CTF"+cKeyCTF+cDoc
				Sleep(20)
			EndIf
		EndDo
	EndIf

	If lRet
		LockDoc(dDataLanc,cLote,cSubLote,cDoc,@CTF_LOCK)
	EndIF
EndIf

RestArea(aAreaCT2)
RestArea(aAreaCTF)
RestArea(aArea)

Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ NewProxDoc ³ Autor ³ TOTVS                ³ Data ³10.08.2020³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tenta pegar próximo numero de Documento na Data / Lote     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ NewProxDoc ( dDataLan, cLote ,cSublote, @cDoc )             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. /.F. (Se retornou .F. ‚ por que estourou o doc no Lote) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA105 , CTBA050                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 = Data do lan‡amento								   ³±±
±±³          ³ ExpC1 = Lote Cont bil 									   ³±±
±±³          ³ ExpC2 = Sub-Lote Cont bil								   ³±±
±±³          ³ Expc3 = N§ do Doc (X Referˆncia)							   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION NewProxDoc(dDataLanc,cLote,cSubLote,cDoc,CTF_LOCK,lSimula,cTabCTK,cTabCT2,lExecauto)

Local aArea		:= GetArea()
Local aAreaCTF	:= CTF->(GetArea())
Local aAreaCT2	:= CT2->(GetArea())
Local lRet		:= .F.
Local cKeyCTF	:= ""
Local dDataCTF	:= dDataLanc
Local cKeyCT2	:= ""
Local cAliasCTF := CTF->(GetNextAlias())

Default cDoc		:= ""
DEFAULT CTF_LOCK	:= 0
Default lSimula		:= .F.
Default cTabCTK		:= "CTK"
Default cTabCT2		:= "CT2"
Default lExecauto 	:= .F.

//------------------------------------------------------------------------------------------------------
// No CTBA280 é possivel o cliente definir o número do Documento, entao caso ele o faça e o número seja
// maior que a ultima numeracao, o mesmo é utilizado, caso contrário, é obtida a próxima sequencia
//------------------------------------------------------------------------------------------------------
//If !Empty(cDoc)  //Se definir que só pode um rateio por vez não precisa
//	cDoc := StrZero(Val(cDoc),6)
//EndIf
// Consecutivo por mes, aplica solo para CTF// Don`t know what for...
//If lRet .And. cPaisLoc == "MEX"
//	dDataCTF := StoD( Substr(DtoS(dDataCTF), 1, 6) + "01" )
//EndIf
aAreaCT2 := (cTabCT2)->(GetArea())

// Consecutivo por mes, aplica solo para CTF
If cPaisLoc == "MEX"
	dDataCTF := StoD( Substr(DtoS(dDataCTF), 1, 6) + "01" )
EndIf

dbSelectArea( "CT2" ) 
dbSetOrder( 1 )
dbSelectArea( "CTF" ) 
dbSetOrder( 1 )
cKeyCTF := xFilial("CTF")+dtos(dDataCTF)+cLote+cSubLote
cKeyCT2 := xFilial("CT2")+dtos(dDataLanc)+cLote+cSubLote

lQuery := .F.
cQuery := "SELECT CTF_DOC  CTFDOC, R_E_C_N_O_ CTFRECNO "   // MIN(R_E_C_N_O_)
If lExecauto 
	cQuery += " , CTF_USADO "
EndIf
cQuery += "  FROM " + RetSqlName("CTF") 
cQuery += " WHERE CTF_FILIAL = '" + xFilial("CTF") + "'"
cQuery += "   AND CTF_DATA   = '" + DTOS(dDataCTF) + "' "
cQuery += "   AND CTF_LOTE   = '" + cLote + "' "
cQuery += "   AND CTF_SBLOTE = '" + cSubLote + "' "

If !lExecauto 
	cQuery += "   AND CTF_USADO  = 'X' "
EndIf

cQuery += "   AND D_E_L_E_T_ = ' ' "
cQuery += "ORDER BY CTFRECNO "

//DbSelectArea("CTF")
//CTF->(DbGoTop())
// Abro o Cursor do proximo do numero
//REcno TcSetField   ??
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCTF)

While (cAliasCTF)->(!Eof())
	If  lExecauto 
		IF (cAliasCTF)->CTF_USADO == 'X' //verifico se tem algum doc disponivel senao retornara falso para criação da CTF
			lRet := .T.
		EndIF
		If cDoc != (cAliasCTF)->(CTFDOC)
			(cAliasCTF)->(DbSkip())
			LOOP
		Else
			IF (cAliasCTF)->CTF_USADO != 'X' 
				lRet := .T.
				Exit
			EndiF
			CTF_LOCK := (cAliasCTF)->(CTFRECNO) //somente atualizo CTF_LOCK quando for X
		EndiF
		lRet := .F.  // documento nao utilizado-> retorno lret para o conteudo default para tratativa de lock
	EndIf
	If !LockByName("CTF"+cKeyCTF+(cAliasCTF)->(CTFDOC)+"X") .Or.;
		(CTF->(DbSeek(cKeyCTF+(cAliasCTF)->(CTFDOC),.F.)) .and. (CTF->CTF_USADO != 'X')  ) .Or.;
		Iif(cPaisLoc == "MEX", !CT2ValDoc(xFilial("CT2"),dDataLanc,cLote,cSubLote,(cAliasCTF)->(CTFDOC)), CT2->(DbSeek(cKeyCT2+(cAliasCTF)->(CTFDOC),.F.)))
		//UnLockByName("CTF"+cKeyCTF+(cAliasCTF)->(CTFDOC)+"X")
		If (cAliasCTF)->(CTFDOC) == "999999"  
			cLote := CtbInc_Lot(cLote, cModulo)
		EndIf
	Else
		//Se consegui simpleLock, gravo CTF e retorno true Ver TRANSACTION DOC = 999999  VER
		If !LockDoc(dDataLanc,cLote,cSubLote,(cAliasCTF)->(CTFDOC),(cAliasCTF)->(CTFRECNO))
			UnLockByName("CTF"+cKeyCTF+(cAliasCTF)->(CTFDOC)+"X")  // tiro Lockby		
		else
			UnLockByName("CTF"+cKeyCTF+(cAliasCTF)->(CTFDOC)+"X")  // tiro Lockby
			lRet := .T.
			Exit
		Endif
	Endif
	(cAliasCTF)->(DbSkip())
	
EndDo
If !lExecauto 
	CTF_LOCK := (cAliasCTF)->(CTFRECNO)
	cDoc     := (cAliasCTF)->(CTFDOC)
EndIf

(cAliasCTF)->(DbCloseArea())
RestArea(aAreaCT2)
RestArea(aAreaCTF)
RestArea(aArea)

Return(lRet)

/*  ---------------------------------------------------------------------------
   {Protheus.doc } CallProxDc.
    Chama a função ProxDoc e caso esta não consiga pegar um número de 
	documento (chave-CTF_FILIAL,CTF_DATA,CTF_LOTE,CTF_SBLOTE,CTF_DOC)
	esta iniciará um JOB para criar e gravar 10 documentos (chave) novos.
    @autor Totvs
	@since 30/05/2020
	@version >= 12.1.031
//----------------------------------------------------------------------------*/
Function CallProxDc(dDataLanc,cLote,cSubLote,cDoc,CTF_LOCK,lSimula,cTabCTK,cTabCT2,lExecauto,lForcNewCTF)
Local lRet as logical
Local cDocAnt as Character 
Local aKeyCTF  as array 
Default cDoc		:= ""
DEFAULT CTF_LOCK	:= 0
Default lSimula		:= .F.
Default cTabCTK		:= "CTK"
Default cTabCT2		:= "CT2"
Default lExecauto   := .F.
Default lForcNewCTF	:= .F. // Variavel que força a criação da CTF quando vindo das rotinas CTBA101, 102 e 103  

cDocAnt := ""  

SaveInter()

If __nCTFQDT == NIL
   __nCTFQDT := SuperGetMV("MV_CTFQTD",.F. ,100) 
Endif

lRet := .T.
While Empty(cDocAnt)

	If !lForcNewCTF .and. NewProxDoc(dDataLanc,cLote,cSubLote,@cDoc,@CTF_LOCK,lSimula,cTabCTK,cTabCT2,lExecauto) 
		cDocAnt := cDoc
		Exit
	Else
		// ------------------------------------------------------------------------------------
		// Se Não conseguir pegar o Documento, Start Job e gerar documentos e tenta novamente
		// CtbCriaCTF
		// ------------------------------------------------------------------------------------ 
		aKeyCTF := { xFilial("CTF"), dDataLanc,cLote,cSubLote,cDoc,CTF_LOCK,lSimula,cTabCTK,cTabCT2 ,__nCTFQDT}
		If inTransact()//- se estiver em transação usa o job
			lRet := StartJob("CTBCRIACTF",getenvserver(),.T., cEmpAnt, cFilAnt, .T., aKeyCTF)
		Else 
     		lRet := CTBCRIACTF(cEmpAnt,cFilAnt,.F. , aKeyCTF)
		EndIf
		// habilitar a linha abaixo parakkk debugar e comentar a de cima
     	//	CTBCRIACTF(cEmpAnt,cFilAnt,.F. , { xFilial("CTF"),dDataLanc,cLote,@cSubLote,@cDoc,CTF_LOCK,lSimula,cTabCTK,cTabCT2 })
		If lForcNewCTF 
			cDocAnt := 'XX' //Quando forçada a criação interrompo o laço apos a criação da quantidade de documentos de acordo com parametro MV_CTFQTD
		EndIf
	EndIf
EndDo

RestInter()
Return(lRet)

/*/ ---------------------------------------------------------------------------
   {Protheus.doc } CtbCriaCTF.
    Chama a função ProxDoc e caso esta não consiga pegar um número de 
	documento (chave-CTF_FILIAL,CTF_DATA,CTF_LOTE,CTF_SBLOTE,CTF_DOC)
	esta iniciará um JOB para criar e gravar 5 documentos (chave) novos.
    @autor Totvs
	@since 30/03/2020
	@version 12
	 StarJob("CtbCriaCTF",getenvserver(),.T.,xFilial("CTF"),DataLanc,cLote,@cSubLote,@cDoc)
*///---------------------------------------------------------------------------  
Function CtbCriaCTF(cEmp, cFil, lRPC, aParams)
Local cFilCTF   := aParams[1]
Local dDataLanc := aParams[2]
Local cLote     := aParams[3]
Local cSubLote  := aParams[4]
Local cDoc      := aParams[5]
Local CTF_LOCK  := aParams[6]
Local lSimula   := aParams[7]
Local cTabCTK   := aParams[8]
Local cTabCT2   := aParams[9]
Local nTotDocs  := aParams[10]
Local nQtd      := 1
Local cQuery    := ""
Local lRet      := .T.
Local cKeyCTF   := ""
Local cChaveCT2 := ""
Local dDataCTF  := dDataLanc
Local cKeyCT2   := ""
Local lAutoInc  := .T.
Local lApurRes  := FWIsInCallStack("CTB211PROC") 
Local cUltDoc   := ""
Local cNullDb   :=""
Local aArea    as Array 
Local aAreaCT2 as Array 


Default lRPc     := .F.     
Default cFilCTF  := xFilial("CTF")
DEFAULT CTF_LOCK := 0
Default lSimula := .F.
Default cTabCTK	:= "CTK"
Default cTabCT2	:= "CT2"
If !lRpc
	aArea := GetArea()
	aAreaCT2 := CT2->(GetArea())
EndIf

If lRPC
	RpcSetType(3)
	RpcSetEnv(cEmp,cFil,,,"CTB",'CtbCriaCTF',{"CT2","CTF"})  //, {"CT2","CTF"} , /*lShowFinal*/, /*lAbend*/, .F. /*lOpenSX*/, /*lConnect*/)
Endif
dbSelectArea( "CTF" )
dbSetOrder( 1 )
dbSelectArea( "CT2" )
dbSetOrder( 1 )

IF (Alltrim(Upper(TcGetDb())) $ "ORACLE|POSTGRES|DB2")
	cNullDb := "COALESCE"
Else
	IF ("MSSQL" $ Alltrim(Upper(TcGetDb())))
		cNullDb := "IsNull"
	ElseIf (Alltrim(Upper(TcGetDb())) $ "INFORMIX")
		cNullDb := "NVL"
	EndIf
EndIf
//------------------------------------------------------------------------------------------------------
// No CTBA280 é possivel o cliente definir o número do Documento, entao caso ele o faça e o número seja
// maior que a ultima numeracao, o mesmo é utilizado, caso contrário, é obtida a próxima sequencia
//------------------------------------------------------------------------------------------------------
If !Empty(cDoc)
	cDoc := StrZero(Val(cDoc),6)
EndIf

// Consecutivo por mes, aplica solo para CTF
If lRet .And. cPaisLoc == "MEX"
	dDataCTF := StoD( Substr(DtoS(dDataCTF), 1, 6) + "01" )
EndIf

cKeyCTF := xFilial("CTF")+dtos(dDataCTF)+cLote+cSubLote
cKeyCT2 := xFilial("CT2")+dtos(dDataLanc)+cLote+cSubLote

If _lCTBPRXDOC .And. !lSimula
	cDoc := ExecBlock("CTBPRXDOC",.F.,.F.,{dDataLanc,cLote,cSubLote})
Else
	cQuery := "SELECT "+cNullDb+"(MAX(CTF_DOC), ' ')  MAXDOC, "+cNullDb+"(MAX(R_E_C_N_O_), 0) RECNO "
	cQuery += "  FROM "+ RetSqlName("CTF")
	cQuery += " WHERE CTF_FILIAL = '"+cFilCTF+"'"
	cQuery += "   AND CTF_DATA   = '"+Dtos(dDataCTF)+"'"
	cQuery += "   AND CTF_LOTE   = '"+cLote+"'"
	cQuery += "   AND CTF_SBLOTE = '"+cSubLote+"'"
	//cQuery += "   AND CTF_USADO  = 'X' "  Não colocar!!!!!!
	cQuery += "   AND D_E_L_E_T_ = ' ' "
	If _lCTBPXDCQRY
		cQuery := Execblock( 'CTBPXDCQRY' , .F. , .F. , {cQuery} )
	Endif
	IF Select( "TMPPRXDOC" ) > 0
		("TMPPRXDOC")->(dbCloseArea())
	Endif
	// Abro o Cursor do proximo do numero
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPPRXDOC")
	If Select("TMPPRXDOC") > 0
		If cDoc > AllTrim(("TMPPRXDOC")->MAXDOC)
			lAutoInc := .F.
			cUltDoc:=  AllTrim(("TMPPRXDOC")->MAXDOC)
		Else
			cDoc := AllTrim(("TMPPRXDOC")->MAXDOC)
		EndIf
		("TMPPRXDOC")->(dbCloseArea())
	Endif

	dbSelectArea("CTF")
	If STRZERO(VAL(cDoc),6) == "999999"
		If lApurRes
			lRet := .T.
		Else
			lRet := .F.   // Verificar PONTO DE APURAÇÃO
		EndIf
	Else
		If Empty(cDoc)
			cDoc := "000001"
		ElseIf lAutoInc 
			cDoc := StrZero(Val(cDoc)+1,6)
		ElseIF !lAutoInc .and. Empty(cUltDoc)
			cDoc := "000001"
		ElseIf !lAutoInc .and. !Empty(cUltDoc) 
			cDoc := StrZero(Val(cUltDoc)+1,6)	
		EndIf
	EndIf
EndIf

If lRet
	dbSelectArea("CT2")
	If lSimula
		dbSelectArea("SIX")
		dbSetOrder(1)		//INDICE+ORDEM
		dbGoTop()
		If SIX->(dbSeek("CT21"))
			cChaveCT2 := AllTrim(SIX->CHAVE)
			IndRegua("CT2", cTabCT2, cChaveCT2, , , )
		EndIf
		dbSelectArea("CT2")
	Else
		dbSetOrder(1)
	EndIf
	//cKeyCTF = xFilial("CTF")+dtos(dDataCTF)+cLote+cSubLote  -Sempre FORA de TRANSAÇÃO.
	While nQtd <= nTotDocs                // SE FOR APURACAO 
		If !LockByName("CTF"+cKeyCTF+cDoc) .Or. CTF->(MsSeek(cKeyCTF+cDoc,.F.) ) .Or.;
			Iif(cPaisLoc == "MEX", !CT2ValDoc(xFilial("CT2"),dDataLanc,cLote,cSubLote,cDoc), CT2->(MsSeek(cKeyCT2+cDoc,.F.)))
			//UnLockByName("CTF"+cKeyCTF+cDoc)
			If cDoc == "999999"  
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Caso o N§ do Doc estourou, incrementa o lote         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cLote 	:= CtbInc_Lot(cLote, cModulo)
				cKeyCTF := xFilial("CTF")+dtos(dDataCTF)+cLote+cSubLote
				cKeyCT2 := xFilial("CT2")+dtos(dDataLanc)+cLote+cSubLote
				cDoc := "000001"
			Else
				cDoc := StrZero(Val(cDoc)+1,6)
			EndIf
			Loop
		Else 
			//Se consegui bloquear, gravo CTF  Ver '999999'
			CTF->(Reclock("CTF", .T.))
			CTF->CTF_FILIAL := cFilCTF
			CTF->CTF_DATA   := dDataCTF
			CTF->CTF_LOTE   := cLote
			CTF->CTF_SBLOTE := cSubLote
			CTF->CTF_DOC    := cDoc
			CTF->CTF_USADO  := 'X'
			CTF->(MsUnlock())
			UnLockByName("CTF"+cKeyCTF+cDoc)  // tiro Lockby
		Endif
		cDoc := StrZero(Val(cDoc)+1,6)
		If cDoc == "999999"  
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Caso o N§ do Doc estourou, incrementa o lote         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cLote := CtbInc_Lot(cLote, cModulo)
			cKeyCTF := xFilial("CTF")+dtos(dDataCTF)+cLote+cSubLote
			cKeyCT2 := xFilial("CT2")+dtos(dDataLanc)+cLote+cSubLote
			cDoc := "000001"
		EndIf
		nQtd++
	EndDo
Endif

If !lRpc
	RestArea(aAreaCT2)
	RestArea(aArea)
	aSize(aArea,0)
	aSize(aAreaCT2,0)
Endif

Return(lRet)




/*/ ---------------------------------------------------------------------------
   {Protheus.doc } CtCTFJob
    Chama funcao que cria a Procedure com nome fixo CTBINCCTF_ + cEmpAnt
	que inclui 1 registro na tabela CTF 
	documento (chave-CTF_FILIAL,CTF_DATA,CTF_LOTE,CTF_SBLOTE,CTF_DOC)
	
	Executa a Procedure criada por StartJob
    @autor Totvs
	@since 30/03/2020
	@version 12
//---------------------------------------------------------------------------  */
Static Function CtCTFJob( cxFilCTF, dDataCTF, cLote, cSubLote, cDoc, lInclCTF)
Local lRet := .T.
Local lMore := .T.
Local nTentativa := 0

If 	lRet := CtCrProCTF(cEmpAnt, RetSqlName("CTF"))
	/* ----------------------------------------------------------------------
	//e Start Job cria o registro na CTF 
	// CtbOneCTF
	//   ---------------------------------------------------------------------- */
	lRet := StartJob("CTBONECTF",getenvserver(),.T., cEmpAnt, cFilAnt, .T., { cxFilCTF, DTOS(dDataCTF), cLote,cSubLote,cDoc })
	//CTBONECTF(cEmpAnt, cFilAnt, .F., { cxFilCTF, DTOS(dDataCTF), cLote,cSubLote,cDoc })
	sleep(50)
	
	If lRet

		TCConfig("TCSOFTREFRESH=ON")
		tcrefresh(retsqlname("CTF"))

		While lMore .And. nTentativa < 100

			If CTF->( dbSeek(cxFilCTF+DtoS(dDataCTF)+cLote+cSubLote+cDoc ) )
				lMore := .f.
				nTentativa := 100
				lInclCTF := .F.
				Exit
			EndIf

			nTentativa++

			Conout(nTentativa)
			sleep(50)

			If nTentativa == 100
				Conout("Tempo CTF esgotado")
				lRet := .F.
				lMore := .f.
				Exit
			EndIf

		EndDo
	EndIf

EndIf

Return lRet
/*/ ---------------------------------------------------------------------------
   {Protheus.doc } CtCrProCTF.
    Cria a Procedure com nome fixo CTBINCCTF_ + cEmpAnt
	que inclui 1 registro na tabela CTF 
	documento (chave-CTF_FILIAL,CTF_DATA,CTF_LOTE,CTF_SBLOTE,CTF_DOC)
	
	a Procedure sera executada por StartJob
    @autor Totvs
	@since 30/03/2020
	@version 12
//---------------------------------------------------------------------------  */
Static Function CtCrProCTF(cGrEmpr, cArqCTF)
Local cProcQry := ""
Local nPTratRec := 0
Local lRet := .T.

If ! TCSPExist("CTBINCCTF_" + cGrEmpr )

	cProcQry := "CREATE PROCEDURE CTBINCCTF_" +cGrEmpr
	cProcQry += "(" + CRLF
	cProcQry += "   @IN_XFILCTF     Char( "+Alltrim(Str(TamSX3('CTF_FILIAL')[1]))+")," + CRLF
	cProcQry += "   @IN_DATA        Char( 08)," + CRLF
	cProcQry += "   @IN_LOTE        Char( "+Alltrim(Str(TamSX3('CTF_LOTE')[1]))+")," + CRLF
	cProcQry += "   @IN_SUBLOTE     Char( "+Alltrim(Str(TamSX3('CTF_SBLOTE')[1]))+")," + CRLF
	cProcQry += "   @IN_DOC  	    Char( "+Alltrim(Str(TamSX3('CTF_DOC')[1]))+")," + CRLF
	cProcQry += "   @OUT_RECNOCTF   integer OutPut" + CRLF
	cProcQry += "  )" + CRLF

	cProcQry += "as" + CRLF

	cProcQry += "Declare @iRecno       Integer" + CRLF
	cProcQry += "Declare @lGravou      Char( 01 )" + CRLF

	cProcQry += "Begin" + CRLF

				/* ----------------------------------------------------------*
				|           gravo CTF 									    |		
			   *---------------------------------------------------------- */   
	cProcQry += "          Select @iRecno = IsNull(Max( R_E_C_N_O_ ), 0 ) FROM  "+ cArqCTF + CRLF
	cProcQry += "          Select @iRecno = @iRecno + 1" + CRLF 
				
	cProcQry += "           ##TRATARECNO @iRecno\ " + CRLF
	cProcQry += "           Insert Into  "+cArqCTF+" ( CTF_FILIAL , CTF_DATA, CTF_DOC, CTF_LOTE , CTF_SBLOTE  ,  R_E_C_N_O_ ) " + CRLF
	cProcQry += "                             VALUES ( @IN_XFILCTF, @IN_DATA, @IN_DOC, @IN_LOTE , @IN_SUBLOTE , @iRecno     )" + CRLF
	cProcQry += "           select @lGravou = '1'" + CRLF
	cProcQry += "           ##FIMTRATARECNO " + CRLF
	cProcQry += "  Select @OUT_RECNOCTF = @iRecno" + CRLF
	
	cProcQry += "End" + CRLF

	cProcQry := CtbAjustaP(.T., cProcQry, @nPTratRec)
	cProcQry := MsParse(cProcQry, If(Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB())))
	cProcQry := CtbAjustaP(.F., cProcQry, nPTratRec)
	cProcQry := AjustaProc(cProcQry)
	cProcQry += CRLF

	If !Empty( MsParseError() )
		If !__lBlind
			MsgAlert( 'Erro na criacao da procedure [CTBINCCTF_'+cEmpAnt + "] " + MsParseError() )  //'Erro na criacao da procedure'
		EndIf
		lRet := .F.
	Else
		cRet := TcSqlExec( cProcQry )
		If cRet <> 0
			If !__lBlind
				MsgAlert( 'Erro na criacao da procedure [CTBINCCTF_'+cEmpAnt + "] " + TcSQLError() )  //'Erro na criacao da procedure'
			EndIf
			lRet := .F.
		EndIf
	EndIf

EndIf

Return(lRet)

/*/ ---------------------------------------------------------------------------
   {Protheus.doc } CTBONECTF.
    Executa a procedure que Cria 1 registro na tabela CTF fora de transacao pois e chamada por StartJob 
	documento (chave-CTF_FILIAL,CTF_DATA,CTF_LOTE,CTF_SBLOTE,CTF_DOC)

    @autor Totvs
	@since 30/03/2020
	@version 12
//---------------------------------------------------------------------------  */
Function CTBONECTF(cEmp, cFil, lRPC, aParams)
Local cxFilCTF   := aParams[1]
Local cDataCTF := aParams[2]
Local cLote     := aParams[3]
Local cSubLote  := aParams[4]
Local cDoc      := aParams[5]
Local cNameProc
Local aResult
Local lRet       := .F.

If lRPC
	RpcSetType(3)
	RpcSetEnv(cEmp,cFil,,,"CTB",,,,.F.,)  //, {"CT2","CTF"} , /*lShowFinal*/, /*lAbend*/, .F. /*lOpenSX*/, /*lConnect*/)
Endif

cNameProc := "CTBINCCTF_"+cEmp
// Executar procedure
aResult	:= TCSPEXEC( 	cNameProc,;                     //Nome da Procedure
						cxFilCTF,;				        //xFilial CTF
						cDataCTF ,;				        //Data em formato STRING AAAAMMDD
						cLote,;					        //Lote
						cSubLote,;					    //SubLote
						cDoc )				            //Doc

If Empty( aResult )
	If !__lBlind
		Conout( "Erro executando a Stored Procedure ["+cNameProc+"] : " + TCSqlError() ) // "Erro executando a Stored Procedure"
	EndIf

ElseIf aResult[1] != 0
	lRet := .T.
	If aResult[1] > 0
		lInclCTF := .F.
	EndIf
EndIf

Return(lRet)

//-----------------------------------------------------------------------------------------
/*
{Protheus.doc}AjustaProc(cProcedure)
Função responsavel por retirar os commit de dentro da procedure dinâmica

@author Nilton Rodrigues - Engenharia
@since  14/07/2022
@version 12
*/
//-----------------------------------------------------------------------------------------
Static Function AjustaProc(cProcedure)
cProcedure := StrTran(cProcedure, 'BEGIN TRANSACTION','')
cProcedure := StrTran(cProcedure, 'COMMIT TRANSACTION','')
cProcedure := StrTran(cProcedure, 'BEGIN TRAN',"" )
cProcedure := StrTran(cProcedure, 'COMMIT TRAN','' )
cProcedure := StrTran(cProcedure, 'COMMIT','' )
Return(cProcedure)
