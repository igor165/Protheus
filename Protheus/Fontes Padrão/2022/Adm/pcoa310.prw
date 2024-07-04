#INCLUDE "PROTHEUS.CH"
#INCLUDE "fwcommand.ch"
#INCLUDE "pcoa310.ch"
#Define BMP_ON  "LBOK"
#Define BMP_OFF "LBNO"
//AMARRACAO ALTERACAO FONTE ADMXPROC 
/*
_F_U_N_C_ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFUNCAO    ณ PCOA310  ณ AUTOR ณ Edson Maricate        ณ DATA ณ 08.07.2005 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDESCRICAO ณ Programa para reprocessamento dos pontos de lan็amento       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ USO      ณ SIGAPCO                                                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ_DOCUMEN_ ณ PCOA310                                                      ณฑฑ
ฑฑณ_DESCRI_  ณ Programa para reprocessamento dos ppontos de lan็amento      ณฑฑ
ฑฑณ_FUNC_    ณ Esta funcao podera ser utilizada com a sua chamada normal    ณฑฑ
ฑฑณ          ณ partir do Menu ou a partir de uma funcao pulando assim o     ณฑฑ
ฑฑณ          ณ browse principal e executando a chamada direta da rotina     ณฑฑ
ฑฑณ          ณ selecionada.                                                 ณฑฑ
ฑฑณ          ณ Exemplo: PCOA310(2) - Executa a chamada da funcao de visua-  ณฑฑ
ฑฑณ          ณ                        zacao da rotina.                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ_PARAMETR_ณ ExpN1 : Chamada direta sem passar pela mBrowse               ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static lFWCodFil := FindFunction("FWCodFil")
Static lPLogIni  := FindFunction('PROCLOGINI')
Static lPLogAtu  := FindFunction('PROCLOGATU')
Static __lBlind  := IsBlind()
Static _lFKInUse
Static _lAuto    := .F.
Static _aRetPar1 := {}
Static _aRetPar2 := {}

Static __cTmpRec := NIL     //tabela temporaria contendo recnos ja processados
Static __cProcZero := NIL   //procedure strzero
Static __cProcSoma1 := NIL  //procedure soma1
Static __cProcFil   := nil  //procedure xfilial
Static __cProcDel := NIL    //procedure para exclusao dos movimentos or็amentarios no periodo
Static __cProcExec := NIL   //procedure pai quando processo/item  executado por procedure 
Static __cProcID := NIL   //procedure para pegar proximo item do lan็amento 
Static __cProcLote := NIL   //procedure para pegar proximo lote 
Static __lProcAKDLOTE := NIL   //flag se criou a procedure para pegar proximo lote

Static _aRet_SM0 := Nil

Function PCOA310( nCallOpcx, cProcesso, cItProces, aPar1, aPar2 )

Private cCadastro	:= STR0001 //"Reprocessamento de Lan็amentos"
Private aRotina 	:= MenuDef()
	
		ProcLogIni( {}/*aButtons*/, "PCOA310" )
If nCallOpcx <> Nil

	_lAuto := .T.
	_aRetPar1 := aClone(aPar1)
	_aRetPar2 := aClone(aPar2)
	
	dbSelectArea("AKB")
	dbSetOrder(1)
	
	If !Empty(_aRetPar1) .And. dbSeek(xFilial("AKB")+cProcesso+cItProces) .AND. AKB->AKB_PERMR == "1"
			
		A310DLG("AKB",AKB->(RecNo()),nCallOpcx)
		
	EndIf

Else

	mBrowse(6,1,22,75,"AKB")

EndIf


Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA310DLG   บAutor  ณEdson Maricate      บ Data ณ  08/07/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Dialog de reprocessamento                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A310Dlg(cAlias,nRecnoAKB,nCallOpcx)
Local aRet	      := {}
Local aParametros := {}

Local aRetFil     := {}
Local lRet        := .F.
Local cFiltAKD    := ""
Local aAreaOri

//*********************************************
// variaves para reprocessamento Multi-Filial *
//*********************************************
Local cAliasEnt	  := GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM)	
Local nThreads 	  := SuperGetMv("MV_PCOTHRE",.T.,1)
Local cTbField    := If(SubStr(cAliasEnt,1,1)== "S",SubStr(cAliasEnt,2),cAliasEnt)
Local lEnd		  := .T.
Local cFiltro	  := ""
//*********************************************
// variaves para reprocessamento Multi-Filial *
//*********************************************
Local cFilAtu	  := cFilAnt
Local nRegSM0	  := SM0->(Recno())
Local cProcess    := ""
Local cItem       := ""
Local lMultFil	  := .F.
Local lPCO310Aux  := ExistBlock("PCO310AUX")
Local cLoadParam  := cEmpAnt + "_" + cFilAnt + "_A310DLG"  

Local aFilLoc	  := {}
Local lContinua	  := .T.
Local cChave	  := "" 
Local nX
Local nTotReg 	  := 0
Local cMvExecProc := GetNewPar("MV_PCOPROC","")
Local lCpExProc   :=  	Alltrim(TcGetDb()) $ "MSSQL7|ORACLE|DB2|INFORMIX"  .And. ; //bancos homologados
						ExistBlock("PCOA3105")                             .And. ; //se ponto de entrada esta compilado no RPO
						AKB->AKB_PROCES+AKB->AKB_ITEM $ cMvExecProc               //processo+item estar contido no parametro MV_PCOPROC

Local cFil_Log := cFilAnt
//*********************************
// Utilizado no vetor da parambox *
//*********************************

Private DEF_DATINI := 2
Private DEF_DATFIN := 3
Private DEF_FILTRO := 4

Private lDelPeriodo
Private cFilialDe
Private cFilialAte
Private dPeriodoDe
Private dPeriodoAte
Private lVisualiza
Private lAtuSld

dbSelectArea("AL1")
dbSetOrder(1)
dbSelectArea("AL2")
dbSetOrder(1)
dbSelectArea("AK5")
dbSetOrder(1)
dbSelectArea("AKD")
dbSetOrder(1)
dbSelectArea("AKS")
dbSetOrder(1)
dbSelectArea("AKT")
dbSetOrder(1)
dbSelectArea("ALA")
dbSetOrder(1)
dbSelectArea("AKB")

If AKB->AKB_PERMR == "1"

	If !lCpExProc      
		If nThreads>1
			//***********************************************************
			// Avalia se tem Trhead rodando para o processo selecionado *
			// e apresenta tela com processamento Multi-Thread.         *
			//***********************************************************
			lEnd	:= MoniThread()
		EndIf
	EndIf
	
	If lEnd // So continua se nใo tem Thread rodando

		MV_PAR06 := CHR(10) //Limpa Filtro
		If	FWModeAccess("AK8",3) == "C" .And.;	// Processos de Sistema
			FWModeAccess("AKB",3) == "C" .And.;	// Pontos de Lan็amento
			FWModeAccess("AKC",3) == "C" 		// Configuracao de Lancamento
	
			lMultFil := .T.
			
			cLoadParam += "_C" //Compartilhado
			
			aParametros := { 	{ 5, STR0004,.F.,120,,.F.},; //"Apagar lan็amantos do periodo ?"					
								{ 1, STR0022,IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ),"" 	 ,"Empty() .or. ExistCpo('SM0',cEmpAnt+mv_par02)"  ,"SM0"    ,"" ,50 ,.F. },; //"Filial de"
								{ 1, STR0023,IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ),"" 	 ,"MV_PAR03>='ZZ' .or. ExistCpo('SM0',cEmpAnt+mv_par03)"  ,"SM0"    ,"" ,50 ,.F. },; //"Filial ate"
								{ 1, STR0005,CTOD("  /  /  "),"" 	 ,""  ,""    ,"" ,50 ,.F. },; //"Periodo de"
								{ 1, STR0006,CTOD("  /  /  "),"" 	 ,""  ,""    ,"" ,50 ,.F. },; //"Periodo Ate"
								{ 7, STR0007+GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM),GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM),""},; //"Filtro "
								{ 5, STR0008,.F.,120,,.F.},;
								{ 5, STR0042,.F.,120,,.F.,nThreads>1}} //"Atualizar Saldos ?"

		Else
           
			aParametros := { 	{ 5, STR0004,.F.,120,,.F.},; //"Apagar lan็amantos do periodo ?"					
								{ 1, STR0005,CTOD("  /  /  "),"" 	 ,""  ,""    ,"" ,50 ,.F. },; //"Periodo de"
								{ 1, STR0006,CTOD("  /  /  "),"" 	 ,""  ,""    ,"" ,50 ,.F. },; //"Periodo Ate"
								{ 7, STR0007+GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM),GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM),""},; //"Filtro "
								{ 5, STR0008,.F.,120,,.F.},;
								{ 5, STR0042,.F.,120,,.F.,nThreads>1} } //"Atualizar Saldos ?"

		EndIf

		If _lAuto
			aRet := aClone(_aRetPar1)
		EndIf

		If _lAuto .OR. ParamBox(aParametros,STR0009,aRet,,,,,,,cLoadParam) //"Parametros"
		
			If lPCO310Aux
				ExecBlock("PCO310AUX",.F.,.F.)
			EndIf    
			//*******************************
			// reprocessamento Multi-Filial *
			//*******************************
			If lMultFil
				lDelPeriodo			:= aRet[1]
				cFilialDe			:= aRet[2]
				cFilialAte			:= aRet[3]
				lAtuSld				:= aRet[8]
				DEF_DATINI := 4
				DEF_DATFIN := 5
				DEF_FILTRO := 6
				DEF_VISUAL := 7
			Else
				lDelPeriodo			:= aRet[1]
				cFilialDe			:= cFilAnt
				cFilialAte			:= cFilAnt 
				lAtuSld				:= aRet[6]
				DEF_DATINI 			:= 2
				DEF_DATFIN 			:= 3
				DEF_FILTRO 			:= 4
				DEF_VISUAL 			:= 5												
			EndIf	    
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Inicia o log de processamento  - nao tirar a linha abaixo  ณ
			//ณ pois funcao ProcLogIni utiliza as variaveis mv_par private ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			AEval( aRet, { |x,y| SetPrvt("MV_PAR"+AllTrim(STRZERO(y,2,0))), &("MV_PAR"+AllTrim(STRZERO(y,2,0))) := x } )
            
			If	FWModeAccess("AL1",3) == "C"
            	dbSelectArea("AL1")
				cChave := AllTrim(SM0->M0_CODIGO)+"_"+StrTran(AllTrim(xFilial("AL1"))," ","_")				
				If LockByName("PCOA300"+cChave,.F.,.F.)
					aAdd(aFilLoc,"PCOA300"+cChave)
				Else
					Help(" ",1,"PCOA301US",,STR0043,1,0) //"Outro usuario estแ reprocessando saldos. Aguarde!"
					Return
				EndIf					
            Else
	            dbSelectArea("SM0")
				dbSeek(cEmpAnt+cFilialDe,.t.)
				While !SM0->(Eof()) .and. SM0->M0_CODIGO == cEmpAnt .and.	SM0->M0_CODFIL >= cFilialDe .and. SM0->M0_CODFIL <= cFilialAte
					cFilAnt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
					dbSelectArea("AL1")
					cChave := AllTrim(SM0->M0_CODIGO)+"_"+StrTran(AllTrim(xFilial("AL1"))," ","_")				
					If LockByName("PCOA300"+cChave,.F.,.F.)
						aAdd(aFilLoc,"PCOA300"+cChave)
					Else
						lContinua := .F.
						Exit	
					EndIf					
					SM0->(DbSkip())
				EndDo
				DbSelectArea("SM0")
				DbGoTo(nRegSM0)            
			
				If !lContinua
					For nX := 1 To Len(aFilLoc)
						UnLockByName(aFilLoc[nX],.F.,.F.)
					Next
					Help(" ",1,"PCOA301US",,STR0043,1,0) //"Outro usuario estแ reprocessando saldos. Aguarde!"
					Return
				EndIf						
			EndIf            

			If _lAuto .And. lDelPeriodo
				If _lAuto
					aRetFil :=  aClone(_aRetPar2)
				EndIf
	
				If Len(aRetFil) > 0 .And. !Empty(aRetFil[1])
					cFiltAKD := aRetFil[1]
				EndIf
				//Qdo eh rotina automatica considera .T. sempre
				lRet := .T.				
			
			ElseIf lDelPeriodo
				If Aviso(STR0010, STR0016, {STR0017, STR0018} )==1  //"Atencao"##"Filtrar os lancamentos existentes para exclusao do processo selecionado ?"##"Sim"##"Nao"
				
					If  ParamBox( { { 7 , STR0007+STR0019,"AKD",""} }, STR0009, aRetFil,,,,,,, "PCOA310_1", .F., .F.) //"Parametros"##"[ Excluir os Movimentos - AKD ]"
						If !Empty(aRetFil[1])
							cFiltAKD := aRetFil[1]
							lRet := .T.
						EndIf
					EndIf
		
					If !lRet
						Aviso(STR0010, STR0020, {"Ok"})  //"Atencao"##"Filtro nao informado. Operacao Cancelada!"
					EndIf	
					
					AEval( aRet, { |x,y| SetPrvt("MV_PAR"+AllTrim(STRZERO(y,2,0))), &("MV_PAR"+AllTrim(STRZERO(y,2,0))) := x } )
						
				Else
		
					If Aviso(STR0010, STR0021,{STR0017, STR0018} ) == 1  //"Atencao"##"Confirma a exclusao de todos os lancamentos para o processo selecionado?"##"Sim"##"Nao"
						lRet := .T.
					EndIf	
		
				EndIf
			
			Else
			   
				lRet	:= .T.
				
			EndIf

			dbSelectArea("SM0")
			If ! DbSeek(cEmpAnt+cFilialDe)
				Aviso(STR0010, STR0044,{"Ok"} )  //"Atencao"##"Filial Inicial Invalida. Abandonando reprocessamento de lan็amentos. Selecione uma filial vแlida."
				lRet := .F.
			ElseIf ! DbSeek(cEmpAnt+cFilialAte)
				Aviso(STR0010, STR0045,{"Ok"} )  //"Atencao"##""Filial Final Invalida. Abandonando reprocessamento de lan็amentos. Selecione uma filial vแlida."
				lRet := .F.
			EndIf	

			DbSelectArea("SM0")
			DbGoTo(nRegSM0)
			cFilAnt := cFil_Log  //restaura pois F3 da filial de...ate desposiciona cFilAnt
	
			If lRet

				If lCpExProc   
  					
  					//se existe campo e campo esta como 1-Sim Executa por procedure
					A310ExProc(aRet, lAtuSld, cAliasEnt, cFiltAKD)

				Else
					//*******************************
					// reprocessamento Multi-Thread *
					//*******************************

					nTotReg   := TotLanc(aRet, cFilialDe, cFilialAte) //Retorna a quantidade de registros  validando se o processamento serแ multi-thread

					cAliasEnt := GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM)
					cTbField  := If(SubStr(cAliasEnt,1,1)== "S",SubStr(cAliasEnt,2),cAliasEnt)
					If nThreads>1 .And. nTotReg >= nThreads 
						aAreaOri := GetArea()
						dbSelectArea(GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM))
						dbSetOrder(1)
	
						If lDelPeriodo
							cFiltro	:= aRet[DEF_FILTRO]
							dbSelectArea("SM0")
					      	DbSeek(cEmpAnt+cFilialDe,.t.)
							While !SM0->(Eof()) .and. SM0->M0_CODIGO == cEmpAnt .and.	SM0->M0_CODFIL >= cFilialDe .and.; 
																	 					SM0->M0_CODFIL <= cFilialAte
								cFilAnt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
								Processa({|| ProcDel(aRet, cFiltAKD)}, STR0013, STR0014 )	// "Processando lan็amentos" ### "Excluindo lancamentos..."
								SM0->(DbSkip())
							EndDo
							DbSelectArea("SM0")
							DbGoTo(nRegSM0)
		            	EndIf
	
						If  SubStr( cAliasEnt, 1, 1) == "S" 
							//se a primeira letra do alias for "S" entao	
							//considera campo filial a partir da segunda exemplo tabela SA1 - campo A1_FILIAL
							If !Empty(xFilial(cAliasEnt, cFilialDe)) .And. xFilial(cAliasEnt, cFilialDe) <> xFilial(cAliasEnt, cFilialAte)   //Len(xFilial(cAliasEnt)) == 2
								aRet[DEF_FILTRO] += If(Empty(aRet[DEF_FILTRO]),"",".and.") + cAliasEnt +"->"+ SubStr( cAliasEnt, 2, 2 )+"_FILIAL>='"+xFilial(cAliasEnt, cFilialDe)+"' .and. "
								aRet[DEF_FILTRO] += cAliasEnt +"->"+ SubStr( cAliasEnt, 2, 2 )+"_FILIAL<='"+xFilial(cAliasEnt, cFilialAte)+"'"
							Else
								aRet[DEF_FILTRO] += If(Empty(aRet[DEF_FILTRO]),"",".and.") + cAliasEnt +"->"+SubStr(cAliasEnt, 2, 2)+"_FILIAL=='"+xFilial(cAliasEnt, cFilialDe)+"'"
							EndIf
						Else			
							If !Empty(xFilial(cAliasEnt, cFilialDe)) .And. xFilial(cAliasEnt, cFilialDe) <> xFilial(cAliasEnt, cFilialAte)   //Len(xFilial(cAliasEnt)) == 2
								aRet[DEF_FILTRO] += If(Empty(aRet[DEF_FILTRO]),"",".and.") + cAliasEnt +"->"+cAliasEnt+"_FILIAL>='"+xFilial(cAliasEnt, cFilialDe)+"' .and. "
								aRet[DEF_FILTRO] += cAliasEnt +"->"+cAliasEnt+"_FILIAL<='"+xFilial(cAliasEnt, cFilialAte)+"'"
							Else
								aRet[DEF_FILTRO] += If(Empty(aRet[DEF_FILTRO]),"",".and.") + cAliasEnt +"->"+cAliasEnt+"_FILIAL=='"+xFilial(cAliasEnt, cFilialDe)+"'"
							Endif
						EndIf
						RestArea(aAreaOri)
				
						If lRet
							cSql := A310Slq(AKB->AKB_PROCES,AKB->AKB_ITEM,aRet)
							If !Empty(aRet[DEF_FILTRO]) .and. !Empty(cSql)
								aRet[DEF_FILTRO] += " .AND. " + cSql + " "
							Elseif !Empty(cSql)
								aRet[DEF_FILTRO] += cSql + " "
							EndIf
								Processa({|| ThreadLanc(aRet,cFilialDe, cFilialAte )}, STR0013, STR0024 )		// "Processando lan็amentos" ### "Selecionando lan็amentos"
						EndIf
						
						//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
						//ณ Atualiza o log de processamento   ณ
						//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
							ProcLogAtu("FIM")
					Else
			 			cFiltro	:= aRet[DEF_FILTRO]
						dbSelectArea("SM0")
				      	DbSeek(cEmpAnt+cFilialDe,.t.)
						While !SM0->(Eof()) .and. SM0->M0_CODIGO == cEmpAnt .and.	SM0->M0_CODFIL >= cFilialDe .and.; 
																 					SM0->M0_CODFIL <= cFilialAte
							cFilAnt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
						
								ProcLogIni( {}/*aButtons*/, "PCOA310" )
	
							//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
							//ณ Atualiza o log de processamento   ณ
							//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
								ProcLogAtu("INICIO")
							
							aAreaOri := GetArea()
							dbSelectArea(GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM))
							dbSetOrder(1)
							aRet[DEF_FILTRO] := cFiltro
							If  SubStr( cAliasEnt, 1, 1) == "S" 
								//se a primeira letra do alias for "S" entao	
								//considera campo filial a partir da segunda exemplo tabela SA1 - campo A1_FILIAL
								aRet[DEF_FILTRO] += If(Empty(aRet[DEF_FILTRO]),"",".and.") + cAliasEnt +"->"+ SubStr( cAliasEnt, 2, 2 )+"_FILIAL=='"+xFilial(cAliasEnt)+"'"				
							Else			
								aRet[DEF_FILTRO] += If(Empty(aRet[DEF_FILTRO]),"",".and.") + cAliasEnt +"->"+cAliasEnt+"_FILIAL=='"+xFilial(cAliasEnt)+"'"
							EndIf
							RestArea(aAreaOri)
							If lDelPeriodo
				
								Processa({|| ProcDel(aRet, cFiltAKD)}, STR0013, STR0014 )	// "Processando lan็amentos" ### "Excluindo lancamentos..."
										
							EndIf 
					
							If lRet
								conout('INI = NO THREAD as ' + TIME())
								Processa({|| ProcLanc(aRet,,,lAtuSld)}, STR0013, STR0015 )		// "Processando lan็amentos" ### "Gerando lancamentos..."
								conout('FIM = EMP:' + cEmpAnt + ' FIL:' + cFilAnt  + ' NO THREAD as ' + TIME() )
							EndIf
							
							//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
							//ณ Atualiza o log de processamento   ณ
							//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
								ProcLogAtu("FIM")
				            									
							SM0->(DbSkip())
						EndDo
						DbSelectArea("SM0")
						DbGoTo(nRegSM0)
					
						If _lAuto .And. !lAtuSld
			   				Conout( STR0033 +"--->"+STR0034+CRLF+STR0035 ) //"Aviso!" //"Reprocessamento dos lan็amentos finalizado." //" ษ recomendada a atualiza็ใo dos saldos dos Cubos."
						ElseIf !lAtuSld
			   				Aviso( STR0033 , STR0034+CRLF+STR0035,{STR0012} ) //"Aviso!" //"Reprocessamento dos lan็amentos finalizado." //" ษ recomendada a atualiza็ใo dos saldos dos Cubos."
						EndIf  
					
					EndIf
				EndIf
				
			EndIf
			cFilAnt	:= cFilAtu
		
			For nX := 1 To Len(aFilLoc)
				UnLockByName(aFilLoc[nX],.F.,.F.)
			Next
			
		EndIf
	EndIf
Else
	If _lAuto
		Conout(STR0010+"-->"+STR0011) //"Aten็ใo"###"Este ponto nใo pode ser reprocessado"
	Else
		Aviso(STR0010,STR0011,{STR0012},2) //"Aten็ใo"###"Este ponto nใo pode ser reprocessado"###"Fechar"
	EndIf
EndIf

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA310   บAutor  ณMicrosiga           บ Data ณ  05/22/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function A310FilInt(cProcesso,cItem,aRet)
Local lRet := .F.

Do Case
	Case cProcesso+cItem == "00025201"  // Inclusao de itens da Planilha
		lRet	:=	( AK2->AK2_DATAI >= aRet[DEF_DATINI] .And. AK2->AK2_DATAF <= aRet[DEF_DATFIN] )
		If lRet	
			AK1->(dbSetOrder(1))
			lRet := ( AK1->(MsSeek(xFilial('AK1')+AK2->AK2_ORCAME)) .And. AK2->AK2_VERSAO == AK1->AK1_VERSAO ) 	
		Endif
	Case cProcesso+cItem == "00025202"  // Inclusao de itens da Planilha versoes revisadas
		lRet	:=	( AK2->AK2_DATAI >= aRet[DEF_DATINI] .And. AK2->AK2_DATAF <= aRet[DEF_DATFIN] )
		If lRet	
			AKR->(dbSetOrder(1))
			AK1->(dbSetOrder(1))
			lRet := !( AKR->(MsSeek(xFilial('AKR')+AK2->AK2_ORCAME+AK2->AK2_VERSAO))).And.( AK1->(MsSeek(xFilial('AK1')+AK2->AK2_ORCAME)) .And. AK2->AK2_VERSAO <> AK1->AK1_VERSAO ) 
		Endif
	Case cProcesso+cItem == "00025203"  // Inclusao de itens da Planilha versoes simuladas
		lRet	:=	( AK2->AK2_DATAI >= aRet[DEF_DATINI] .And. AK2->AK2_DATAF <= aRet[DEF_DATFIN] )
		If lRet	
			AKR->(dbSetOrder(1))
			lRet := ( AKR->(MsSeek(xFilial('AKR')+AK2->AK2_ORCAME+AK2->AK2_VERSAO)))
		Endif
	Case cProcesso+cItem == "00035801"  // Inclusao de movimentos de planejamento
		lRet	:=	( ALY->ALY_DTINI >= aRet[DEF_DATINI] .And. ALY->ALY_DTFIM <= aRet[DEF_DATFIN] )
/*		If lRet	
			AKR->(dbSetOrder(1))
			lRet := ( AKR->(MsSeek(xFilial('AKR')+AK2->AK2_ORCAME+AK2->AK2_VERSAO)))
		Endif */
	Case cProcesso+cItem == "00008201"  // Lan็amentos contabeis CT2
		lRet	:=	( CT2->CT2_DATA >= aRet[DEF_DATINI] .And. CT2->CT2_DATA <= aRet[DEF_DATFIN] )
		
OtherWise 
	lRet := .T.
EndCase

If lRet .And.  ExistBlock( "PCOA3102" )
	//P_Eฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//P_Eณ Ponto de entrada utilizado para inclusao de funcoes de usuarios na     ณ
	//P_Eณ validacao do reprocessamento dos Lancamentos                           ณ
	//P_Eณ Parametros : Nenhum                                                    ณ
	//P_Eณ Retorno    : .T.ou .F.  //.T.validacao de usuario OK  .F.-Falhou       ณ
	//P_Eณ               Ex. :  User Function PCOA3102                            ณ
	//P_Eณ                      Return(If(U_FuncUsr(), .T., .F.))                 ณ
	//P_Eภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	lRet := ExecBlock( "PCOA3102", .F., .F.,{cProcesso,cItem,aClone(aRet)})
EndIf

Return lRet



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA310   บAutor  ณMicrosiga           บ Data ณ  05/22/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function A310Slq(cProcesso,cItem,aRet)
Local cRet := ""

Do Case
	Case cProcesso == "000252"  // Inclusao de itens da Planilha versoes simuladas
		cRet :=	"AK2_DATAI >='" + Dtos(aRet[DEF_DATINI]) + "' .AND. AK2_DATAF<='" + Dtos(aRet[DEF_DATFIN]) + "'" 
	Case cProcesso+cItem == "00035801"  // Inclusao de movimentos de planejamento
		cRet := "ALY_DTINI >='" + Dtos(aRet[DEF_DATINI]) + "' .AND. ALY_DTFIM <= '" + Dtos(aRet[DEF_DATFIN]) + "'" 
	Case cProcesso+cItem == "00008201"  //Lancamentos contabeis
		cRet := "CT2_DATA >='" + Dtos(aRet[DEF_DATINI]) + "' .AND. CT2_DATA <= '" + Dtos(aRet[DEF_DATFIN]) + "'" 

OtherWise 
	cRet := ""
EndCase

Return cRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA310   บAutor  ณMicrosiga           บ Data ณ  05/22/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ProcDel(aRet, cFiltAKD)

Local cQuery := ""
Local cQryCond		:= ""
Local lResolvQry 	:= .F.
Local cFiltQry 		:= ""
Local cQryFim       := ""
Local nX, nMin, nMax
Local cCampos
Local dDatIni := aRet[DEF_DATINI]
Local dDatFim := aRet[DEF_DATFIN]
Local cAliasQry
Local dDataAnt
Local nDias
Local lDelAll := SuperGetMV("MV_PCODELR",.T.,"1")=="2" // Deleta todos os movimentos (Validos e Invalidos)
Local cFilOrg := iIf( FWModeAccess("AKB",3) == "E" ,xFilial(AKB->AKB_ENTIDA),cFilAnt)

If _lFKInUse == NIL
	_lFKInUse := FKInUse()
EndIf

//verifica se filtro digitado por usuario e resolvido na query
If !Empty(cFiltAKD)
	cFiltQry := PcoParseFil(cFiltAKD, "AKD")
	If ! Empty(cFiltQry)
		lResolvQry 	:= .T.
	EndIf
Else
	lResolvQry 	:= .T.	
EndIf	

Begin Transaction

dbSelectArea("AL1")
dbSetOrder(1)
DbgoTop()
//***********************************************************
// Verrica se existe cubo cadastrado e tem query de delecao *
//***********************************************************
If lResolvQry .and. dbSeek( xFilial("AL1") )

	nMin	:=	0
	nMax    := 	0
	
	cQryCond := "   AKD_FILIAL = '" + xFilial("AKD")  + "' AND "
	cQryCond += "   AKD_FILORI = '" + cFilOrg + "' AND "
	cQryCond += "   AKD_PROCES = '" + AKB->AKB_PROCES + "' AND "
	cQryCond += "   AKD_ITEM   = '" + AKB->AKB_ITEM   + "' AND "
	cQryCond += "   ( "
	cQryCond += "		AKD_DATA = ' ' OR ( AKD_DATA BETWEEN '" + DtoS( dDatIni ) + "' AND '" + DtoS( dDatFim ) + "' )" 
	cQryCond += "   ) AND "
	cQryCond += "   D_E_L_E_T_ = ' ' "
	//*************************************
	// utilizado para Deletar todos os    *
	// lan็amentos (validos e invalidos). *
	//*************************************
	If !lDelAll
		cQryCond +=	" AND AKD_STATUS='1' "
	EndIf
	cQryCond +=	" AND AKD_TIPO IN ( '1', '2') "

	// Adiciona expressao de filtro convertida para SQL	
	If !Empty(cFiltQry)
		cQryCond += " AND (" + cFiltQry +")"
	EndIf
	
	cQuery	:=	" SELECT Min(R_E_C_N_O_) MinRecno, "
	cQuery	+=	" Max(R_E_C_N_O_) MaxRecno "
	cQuery	+=	" FROM " + RetSqlName("AKD")
	cQuery	+=	" WHERE "
	cQuery	+=	cQryCond
	cQuery	:=	ChangeQuery(cQuery)
	
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery),"QRYTRB", .F., .F. )
	
	If !Eof()                                           
		nMin	:=	MINRECNO
		nMax	:=	MAXRECNO
	Endif	                                                                             
	
	QRYTRB->( dbCloseArea() )
	
	ProcRegua(Round((nMax-nMin)/10000,0))	
	
	For nX := nMin To nMax	STEP 10000
	
		If _lFKInUse
			cQryFim := " UPDATE " + RetSqlName('AKD') + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ "
		Else
			cQryFim	:= " DELETE FROM  "+RetSqlName('AKD') 
		EndIf
		
		cQryFim += " WHERE "
		cQryFim += cQryCond
		cQryFim += " AND R_E_C_N_O_ BETWEEN "+Str(nX)+ ' AND '+Str(nX+10000)
		
		IncProc(STR0036) //"Apagando Movimentos ..."
		
		If TcSqlExec(cQryFim) <> 0
		
			UserException(STR0037 + CRLF + STR0038 + CRLF + TCSqlError() ) //"Erro na exclusao de movimentos " //"Processo cancelado..."
					lRet	:=	.F.
			Exit 		
		Else		    	
			//Forcar o Commit para DB2 para nao estourar o LOG (mesmo sem ter iniciado transacao)
		   	If Upper(TcGetDb()) == 'DB2'
				TcSqlExec('commit')
   			Endif   			
		Endif
		
	Next

	TcRefresh(RetSqlName("AKD"))

	dbSelectArea( "AKD" )
	
Else

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Conta linhas que serao processadas para montar gauge ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cQuery := "SELECT COUNT(R_E_C_N_O_) TOTREG "
	cQuery += "FROM " + RetSQLName("AKD") + " AKD "
	cQuery += "WHERE "
	cQuery += "   AKD_FILIAL = '" + xFilial("AKD")  + "' AND "
	cQuery += "   AKD_FILORI = '" + xFilial(AKB->AKB_ENTIDA)  + "' AND "
	cQuery += "   AKD_PROCES = '" + AKB->AKB_PROCES + "' AND "
	cQuery += "   AKD_ITEM   = '" + AKB->AKB_ITEM   + "' AND "
	cQuery += "   D_E_L_E_T_ = ' ' "
	
	cQuery	:=	ChangeQuery(cQuery)
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery),"QRYTRB", .F., .F. )
	
	ProcRegua(QRYTRB->TOTREG)
	
	QRYTRB->( dbCloseArea() )
	dbSelectArea("AKD")

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Seleciona os lan็amentos do processo para exclusใo ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cQuery := "SELECT R_E_C_N_O_ NUMREC "
	cQuery += "FROM " + RetSQLName("AKD") + " AKD "
	cQuery += "WHERE "
	cQuery += "   AKD_FILIAL = '" + xFilial("AKD")  + "' AND "
	cQuery += "   AKD_FILORI = '" + xFilial(AKB->AKB_ENTIDA)  + "' AND "
	cQuery += "   AKD_PROCES = '" + AKB->AKB_PROCES + "' AND "
	cQuery += "   AKD_ITEM   = '" + AKB->AKB_ITEM   + "' AND "
	cQuery += "   ( "
	cQuery += "		AKD_DATA = ' ' OR ( AKD_DATA BETWEEN '" + DtoS( aRet[DEF_DATINI] ) + "' AND '" + DtoS( aRet[DEF_DATFIN] ) + "' )" 
	cQuery += "   ) AND "
	cQuery += "   D_E_L_E_T_ = ' ' "


	cQuery	:=	ChangeQuery(cQuery)
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery),"QRYAKD", .F., .F. )

	Do While QRYAKD->( !Eof() )

		IncProc()

		AKD->( dbGoTo( QRYAKD->NUMREC ) )	
		
		If ! Empty(cFiltAKD) .And. ! lResolvQry .And. ! AKD->(&cFiltAKD)
			QRYAKD->(dbSkip())
			Loop
		EndIf	
		
		RecLock("AKD",.F.,.T.)
		AKD->(dbDelete())
		AKD->(MsUnlock())

		QRYAKD->(dbSkip())

	EndDo

	QRYAKD->( dbCloseArea() )
	dbSelectArea( "AKD" )	

EndIf

End Transaction

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMoniThreadบAutor  ณ Acacio Egas        บ Data ณ  05/18/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para mapear as threads em uso pela rotina de        บฑฑ
ฑฑบ          ณ reprocessamento.                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MoniThread()

Local aArea		:= GetArea()
Local aAreaSM0  := SM0->(GetArea())
Local cAliasEnt	:= GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM)
Local cTbField 	:= If(SubStr(cAliasEnt,1,1)== "S",SubStr(cAliasEnt,2),cAliasEnt)
Local cQuery	:= ""
Local lRet		:= .T.
Local cThreads	:= ""
Local nThreads 	:= SuperGetMv("MV_PCOTHRE",.T.,1) 
Local nX
Local nCtdFile  := 0
Local nFilEmpr  := 0

If _aRet_SM0 == NIL
	_aRet_SM0	:= FWLoadSM0()
	RestArea( aAreaSM0 )
EndIf
nFilEmpr  := Qtd_Fil(_aRet_SM0, cEmpAnt)

Do While .T.
	nCtdFile++
	lRet		:= .T.
	cThreads := ""
	For nX := 1 to nThreads	
		cTabMult	:= "TMP" + cAliasEnt + StrZero(nCtdFile,2) + StrZero(nX,2)
		If TCCanOpen(cTabMult)
			If Select(cTabMult)>0
				(cTabMult)->(DbCloseArea())				
			EndIf			
			dbUseArea( .T., 'TOPCONN', cTabMult, cTabMult, .T., .F. )
		EndIf
		If Select(cTabMult)>0
			cQuery := "SELECT COUNT(*) AS TOT,THREAD FROM " + cTabMult + " " 
			cQuery += "WHERE D_E_L_E_T_='' AND THREAD<>'' GROUP BY THREAD"
			
			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),"TRBRUN",.T.,.T.)
			
			If TRBRUN->(!Eof())
			    Do While TRBRUN->(!Eof())
			    	cThreads += TRBRUN->THREAD + ": " + Alltrim(Str(TRBRUN->TOT)) + STR0025 + CHR(10)+CHR(13) //"registros Pendentes de processamento."
			    	If LockByName("PCOA310_RUN_"  + StrZero(nCtdFile,2) + TRBRUN->THREAD ,.T.,.T.,.T.) 
						If Aviso(  STR0010 , STR0026 + TRBRUN->THREAD + STR0027,{STR0018,STR0017} )==2 //"Aten็ใo!"##"Foram encontrador registros pendentes de processamento para a Thread "##". Desejแ continuar o processamento?"##"Nใo"##"Sim"
					    	lRet:= .F.
							(cTabMult)->(DbCloseArea())
							conout('INI = THREAD:' + TRBRUN->THREAD + "[" + Alltrim(Str(TRBRUN->TOT)) + " " + STR0028 + "] " + " as " + TIME()) //registros
							UnLockByName("PCOA310_RUN_" + StrZero(nCtdFile,2) + TRBRUN->THREAD ,.T.,.T.,.T.)
							StartJob("PcoThr310",GetEnvServer(),.F., cTabMult ,cEmpAnt,cFilAnt, StrZero(nCtdFile,2)+TRBRUN->THREAD,AKB->(GetArea()),{.F.,Ctod(""),Ctod("31/12/20"),"", .F., .F.})
			    	    Else
			    	    	UnLockByName("PCOA310_RUN_"  + StrZero(nCtdFile,2) + TRBRUN->THREAD ,.T.,.T.,.T.)
							(cTabMult)->(DbCloseArea())
							MsErase(cTabMult)			    	    	
			    	    EndIf
			    	Else
				    	lRet:= .F.
			    		(cTabMult)->(DbCloseArea())
			    	EndIf
				    TRBRUN->(DbSkip())
			    EndDo		  
			ElseIf LockByName("PCOA310_RUN_"  + StrZero(nCtdFile,2) + StrZero(nX,2) ,.T.,.T.,.T.)
				UnLockByName("PCOA310_RUN_"  + StrZero(nCtdFile,2) + TRBRUN->THREAD ,.T.,.T.,.T.)
				(cTabMult)->(DbCloseArea())
				MsErase(cTabMult)
			Else
		    	lRet:= .F.
		    	cThreads += StrZero(nX,2) + ": " + STR0029 + CHR(10)+CHR(13) //"Atualizando Saldos."
		    	(cTabMult)->(DbCloseArea())
			EndIf
			TRBRUN->(DbCloseArea())
		ElseIf TCCanOpen(cTabMult)
			(cTabMult)->(DbCloseArea())
			MsErase(cTabMult)
		EndIf
	Next
	If lRet .or. Aviso( STR0010 , STR0030 + CHR(10)+CHR(13) + cThreads, {STR0031,STR0032} )==1 //"Aten็ใo!"##"Existem processamento sendo executados:"##"Sair"##"Atualizar"
		Exit
	EndIf
	If nCtdFile >= nFilEmpr  //somente sair quando varrer todas as filiais
		Exit
	EndIf	
EndDo

RestArea( aAreaSM0 )
RestArea(aArea)

Return lRet

//---------------------------------------------------------------------------------
/*/{Protheus.doc} Qtd_Fil
Retorna o numero de filiais do GrupoEmpresa passada como parametro
@since 02/07/2021
@version P12

/*/
//---------------------------------------------------------------------------------
Static Function Qtd_Fil( aRetSM0, cGrpEmpr)
Local nRet := 0
Local nX

Default aRetSM0 := {}
Default cGrpEmpr := cEmpAnt

For nX := 1 To Len(_aRet_SM0)
	If aRetSM0[nX, SM0_GRPEMP] == cGrpEmpr
		nRet++
	EndIf
Next
Return nRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณThreadLancบAutor  ณ Acacio Egas        บ Data ณ  05/18/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de reprocessamento de lan็amentos por Multi-Thread  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ThreadLanc(aRet,cFilialDe, cFilialAte)

Local nThreads 	:= SuperGetMv("MV_PCOTHRE",.T.,1)
Local cAliasEnt	:= GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM)
Local cTbField 	:= If(SubStr(cAliasEnt,1,1)== "S",SubStr(cAliasEnt,2),cAliasEnt)
Local aProcs 	:= {}
Local cQuery	:= ""
Local cUpdate	:= ""
Local cFiltro	:=	PcoParseFil(aRet[DEF_FILTRO],GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM))	
Local nMed		:= 0
Local nMin		:= 0
Local nMax
Local nTot
Local nX

Local cTabMult
Local nThr		:= 0


Local aFilxProc := {} 
Local nCtd := 0

Local cxFil := ""
Local nPercThrd := 0
Local aProcFil := {}

cQuery := "SELECT COUNT(*) AS TOT FROM " + RetSqlName(cAliasEnt) +  " " + cAliasEnt + " "
cQuery += "WHERE D_E_L_E_T_=' ' AND " + cTbField + "_FILIAL >= '" + xFilial(cAliasEnt,cFilialDe) +"'  AND  "+ cTbField + "_FILIAL <='" + xFilial(cAliasEnt,cFilialAte) + If(Empty(cFiltro),"'","' AND (" + cFiltro + ")") 
cQuery := ChangeQuery(cQuery)

DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),"TRBTHR",.T.,.T.)

nTot	:= TRBTHR->TOT
TRBTHR->(DbCLoseArea())

nThreads := iIf( nTot <= 999 .OR. nTot < nThreads, 1,nThreads)   //menor que 1000 lancamentos nao faz em multi-thread

If nThreads > 1 .And. nTot >= nThreads

	cQuery := " SELECT "+cTbField + "_FILIAL TRBXFIL, "+" COUNT(*) AS TOTREG FROM " + RetSqlName(cAliasEnt) +  " " + cAliasEnt + " "
	cQuery += " WHERE D_E_L_E_T_=' ' AND " + cTbField + "_FILIAL >= '" + xFilial(cAliasEnt,cFilialDe) +"'  AND  "+ cTbField + "_FILIAL <='" + xFilial(cAliasEnt,cFilialAte) + If(Empty(cFiltro),"'","' AND (" + cFiltro + ")") 
	cQuery += " GROUP BY "+cTbField + "_FILIAL "

	cQuery := ChangeQuery(cQuery)

	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),"TRBTHR",.T.,.T.)
	aFilxProc := {}
	Do While TRBTHR->(!Eof())
		nPercThrd :=TRBTHR->TOTREG/nTot
		//aFilxProc 
		//Elemento 1 - Campo Filial da Tabela Origem
		//Elemento 2 - Total de Registro existente
		//Elemento 3 - Percentual --> Total de Registros da Filial / Total de Registros a serem processados de todas as filiais
		//Elemento 4 - Percentual de treads a ser levantada com base no parametro 
		//Elemento 5 - Numero de Treads a ser levantada -- se percentual for menor que 1 entao considera 1 thread
		aAdd(aFilxProc, { TRBTHR->TRBXFIL, TRBTHR->TOTREG, nPercThrd, nPercThrd*nThreads, If(nPercThrd*nThreads<1, 1, Int(nPercThrd*nThreads)) })

		TRBTHR->(DbSkip())
	EndDo
	TRBTHR->(DbCLoseArea())
	
	For nCtd := 1 TO Len(aFilxProc)
		cxFil := aFilxProc[nCtd,1]
		nTot  := aFilxProc[nCtd,2]
		aProcs := {}

		nMed	:= Round( nTot / aFilxProc[nCtd,5] /*nThreads*/ ,0) + 1  //Colocado +1 para nao 

		dbSelectArea("SM0")
		DbSeek(cEmpAnt+cFilialDe,.t.)
		While !SM0->(Eof()) .and. SM0->M0_CODIGO == cEmpAnt .and.	SM0->M0_CODFIL >= cFilialDe .and.; 
												 					SM0->M0_CODFIL <= cFilialAte
				
			cFilAnt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )

			If xFilial(cAliasEnt) <> cxFil
				SM0->(dbSkip())
				Loop
			EndIf	

			cQuery := "SELECT R_E_C_N_O_ AS REC FROM " + RetSqlName(cAliasEnt) + " " + cAliasEnt + " " 
			cQuery += "WHERE D_E_L_E_T_='' AND " + cTbField + "_FILIAL='" + xFilial(cAliasEnt) + If(Empty(cFiltro),"'","' AND (" + cFiltro + ")") + " ORDER BY R_E_C_N_O_" 
		
			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),"TRBTHR",.T.,.T.)

			nX	:= 0   //controle de quantos registros por thread
			ProcRegua(nTot)

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณCria uma tabela para Thread. ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			aStruSQL := {}
			AADD(aStruSQL,{"R_E_C_"  	,"N",10,00})
			AADD(aStruSQL,{"THREAD"  	,"C",02,00})
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณCaptura a query  para os registrosณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณMonta a Clausula da SELECTณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If TRBTHR->(!Eof())

				cTabMult	:= "TMP" + cAliasEnt + StrZero(nCtd,2) + StrZero(1,2)
				If TCCanOpen(cTabMult)
					MsErase(cTabMult)
				EndIf
						
				MsCreate(cTabMult, aStruSQL, 'TOPCONN' )
				dbUseArea( .T., 'TOPCONN', cTabMult, cTabMult, .T., .F. )		
				
				aAdd( aProcs , { StrZero(1,2) , 0 , TRBTHR->REC , TRBTHR->REC+nMed , cTabMult } )

				Do While TRBTHR->(!Eof())

					DbSelectArea(cAliasEnt)
					DbGoto(TRBTHR->REC)
					DbSelectArea(cTabMult)

					RecLock(cTabMult,.T.)
					(cTabMult)->(R_E_C_) := (cAliasEnt)->(Recno())
					(cTabMult)->(THREAD) := StrZero(Len(aProcs),2)
					(cTabMult)->(MsUnlock())
					IncProc()
					nX++

					TRBTHR->(DbSkip())

					If TRBTHR->(!Eof()) .And. nMed == nX   //para quebrar em multiplas threads

						(cTabMult)->(DbCloseArea())
						cTabMult	:= "TMP" + cAliasEnt + StrZero(nCtd,2) + StrZero(Len(aProcs)+1,2 ) 
						If TCCanOpen(cTabMult)
							MsErase(cTabMult)
						EndIf
						MsCreate(cTabMult, aStruSQL, 'TOPCONN' )
						dbUseArea( .T., 'TOPCONN', cTabMult, cTabMult, .T., .F. )
						aAdd( aProcs , { StrZero(Len(aProcs)+1,2) , 0 , TRBTHR->REC , TRBTHR->REC+nMed , cTabMult } )						
						
						nX	:= 1
					EndIf	

				EndDo
				TRBTHR->(DbCLoseArea())
				(cTabMult)->(DbCloseArea())

			EndIf
				
			For nX := 1 to Len(aProcs)
				conout('INI = THREAD:' + aProcs[nX][1] + "[" + Alltrim(Str(aProcs[nX][3])) + "][" + Alltrim(Str(aProcs[nX][4])) + "] " + " as " + TIME())
				StartJob("PcoThr310",GetEnvServer(),.F., aProcs[nX][5] ,cEmpAnt,cFilAnt,StrZero(nCtd,2)+aProcs[nX][1],AKB->(GetArea()),aRet)
				nThr++
			Next nX
			
			aSize(aProcs,0)

			SM0->(DbSkip())	
		
		EndDo
	
	Next

	If !lAtuSld
   		Aviso( STR0033 , STR0039 +AllTrim(STR(nThr))+ STR0040 +CRLF +STR0041, {STR0012} ) //"Aviso!" //"Foram iniciados " //" processos simultaneos (Threads) para reprocessamento." //"Assim que todos os processos forem finalizados, ้ recomendada a atualiza็ใo dos saldos dos Cubos." //"Fechar"
	EndIf

else  
	//faz processamento normal sem multiThread
	cFltAux := aRet[6]
	dbSelectArea("SM0")
	DbSeek(cEmpAnt+cFilialDe,.t.)
	While !SM0->(Eof()) .and. SM0->M0_CODIGO == cEmpAnt .and.	SM0->M0_CODFIL >= cFilialDe .and.; 
																SM0->M0_CODFIL <= cFilialAte
			
		cFilAnt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
		If aScan(aProcFil, xFilial(cAliasEnt)) == 0
			aRet[6] := cFltAux + " .and. "+cAliasEnt+"->"+cTbField+"_FILIAL == '"+xFilial(cAliasEnt)+"' "
			Processa({|| ProcLanc(aRet,,,lAtuSld)}, STR0013, STR0015 )		// "Processando lan็amentos" ### "Gerando lancamentos..."
			aAdd(aProcFil, xFilial(cAliasEnt) )
		EndIf
		SM0->(DbSkip())	
	
	EndDo
EndIf
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA310   บAutor  ณMicrosiga           บ Data ณ  05/22/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PcoThr310(cTable,cEmp,cFil,cMark,aAreaAKB,aRet)

Local cAliasEnt
Local cTbField
Local lAtuSld			

RpcSetType(3)
// Seta job para empresa filial desejada
RpcSetEnv( cEmp, cFil,,,'PCO')

//*******************************
// reprocessamento Multi-Filial *
//*******************************
If Len(aRet)>6
	DEF_DATINI := 4
	DEF_DATFIN := 5
	DEF_FILTRO := 6
	lAtuSld	   := aRet[8]
Else
	DEF_DATINI := 2
	DEF_DATFIN := 3
	DEF_FILTRO := 4
	lAtuSld	   := aRet[6]
EndIf	    
                                                	
If LockByName("PCOA310_RUN_" + cMark ,.T.,.T.,.T.) 
	     
	DbSelectArea("AKB")
	DbSelectArea("AKD")
	DbSelectArea("AKS")
	DbSelectArea("AKT")
	
	RestArea(aAreaAKB)
	
	cAliasEnt	:= GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM)
	dbUseArea( .T., 'TOPCONN', cTable, cTable, .T., .F. )
	DbSelectArea(cTable)
	
	aRet[DEF_DATINI]	:= cTod('01/01/01')
	aRet[DEF_DATFIN]	:= cToD('31/12/30')
	aRet[DEF_FILTRO] := ""
	    
	ProcLanc(aRet,.T.,cTable,lAtuSld)
		
	conout('FIM = EMP:' + cEmp + ' FIL:' + cFil  + 'THREAD:' + cMark + " as " + TIME() + " ----" + aRet[DEF_FILTRO])
	UnLockByName("PCOA310_RUN_" + cMark ,.T.,.T.,.T.)
	(cTable)->(DbCloseArea())
	MsErase(cTable)
Else
	conout('ERRO= EMP:' + cEmp + ' FIL:' + cFil  + 'THREAD:' + cMark + " as " + TIME())
EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA310   บAutor  ณMicrosiga           บ Data ณ  05/22/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ProcLanc(aRet,lThread,cTable,lAtuSld)
Local	nIndex
Local	cIndex   := ""
Local cFiltro	:=	""
Local	lCloseArea	:=	.F.
Local bWhile
Local cAlias
Local cProcesso,cItem,cAliasEntid
Local cTbField
Local nLimTran	:= SuperGetMv("MV_PCOLIMI",.T.,9999)
Local nLimCount	:= 0 
Local cCubIni	:= ""
Local cCubFim   := ""
Local lTemReg	:= .F.

//****************************************************
// Esta variavel so esta com .T. quando a fun็ใo ้   *
// solicitada por uma Thread de processamento. Neste *
// caso serแ utilizada uma tabela temporaria para    *
// posicionar os recnos a serem processados.         *
//****************************************************
Default lThread := .F.
Default lAtuSld := .F.

cProcesso := AKB->AKB_PROCES
cItem := AKB->AKB_ITEM
cAliasEntid := GetEntFilt(cProcesso,cItem)

PcoIniLan(AKB->AKB_PROCES)

Begin Transaction
	dbSelectArea(GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM))
	dbSetOrder(1) 
	If !lThread
		ProcRegua(RecCount())
	Else
		(cTable)->(ProcRegua(RecCount()))
	EndIf
	
	//************************************************
	// Coni็ใo para Filtro SQL e quando nใo ้ Thread *
	//************************************************
	If !Empty(aRet[DEF_FILTRO]) .and. !lThread
		cFiltro	:=	PcoParseFil(aRet[DEF_FILTRO],GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM))
		If !Empty(cFiltro)
			cQuery 	:= " SELECT R_E_C_N_O_ RECTAB "
			cQuery 	+= "  FROM " + RetSQLName(GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM)) + " " +GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM)
			cQuery 	+= "  WHERE (" + cFiltro+") AND "// Adiciona expressao de filtro convertida para SQL
			cQuery 	+= " D_E_L_E_T_ <> '*' "
			If ExistBlock( "PCOA3103" )
				//P_Eฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//P_Eณ Ponto de entrada utilizado para inclusao de funcoes de usuarios na     ณ
				//P_Eณ preparacao da query para reprocessamento dos Lancamentos               ณ
				//P_Eณ Parametros : cProcesso, cItem, aClone(aRet), cAliasEntid, cQuery       ณ
				//P_Eณ Retorno    : cQuery      expressao da query                            ณ
				//P_Eภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				cQuery := ExecBlock( "PCOA3103", .F., .F.,{cProcesso,cItem,aClone(aRet),cAliasEntid,cQuery})
			EndIf
						
			cQuery 	+= " ORDER BY  " + SqlOrder((GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM))->(IndexKey()))			
			cQuery 	:= ChangeQuery(cQuery)
			

			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "PCOTRB", .T., .T. )
			DbSelectArea("PCOTRB")
			cAlias := Alias()
			lCloseArea	:=	.T.
		Else
			cIndex := CriaTrab(,.F.)
			IndRegua(GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM),cIndex,IndexKey(),,aRet[DEF_FILTRO])
			nIndex := RetIndex(GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM))
			dbSelectArea(GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM))
			dbSetOrder(nIndex+1)
			cAlias := Alias()
		Endif
		DbGoTop()
		bWhile := { || ! (cAlias)->(Eof()) }
	Else

		//*****************************
		// Condi็ใo para Filtro ADVPL *
		//*****************************
		If !lThread
			dbSeek(xFilial())
			cAlias := Alias()
			
			If  SubStr( cAlias, 1, 1) == "S" 
				//se a primeira letra do alias for "S" entao	
				//considera campo filial a partir da segunda exemplo tabela SA1 - campo A1_FILIAL
				bWhile := {|| (cAlias)->(!Eof()) .And. &(SubStr( cAlias, 2, 2 ) + "_FILIAL") == xFilial() }
			Else			
				bWhile := {|| (cAlias)->(!Eof()) .And. &(cAlias + "_FILIAL") == xFilial() }
			EndIf
		Else
		//***************************************
		// Condi็ใo para utiliza็ใo com Threads *
		//***************************************
			bWhile := {|| (cTable)->(!Eof()) }
		EndIf
	Endif
	
	While Eval(bWhile)
		
		lTemReg := .T.
		
		dbSelectArea(GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM))
		If lThread
			//*****************************************
			// Posiciona Recno da tabela temporaria   *
			// utilizada pela Thread de Processamento *
			//*****************************************
	  		(cAliasEntid)->(DbGoto((cTable)->(R_E_C_)))
	  	Endif		
		If lCloseArea
			(GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM))->(MsGoTo(PCOTRB->RECTAB))
		Endif	
		IncProc()
		If A310FilInt(AKB->AKB_PROCES,AKB->AKB_ITEM,aRet)
			
			If !DetProc(AKB->AKB_PROCES,AKB->AKB_ITEM)    //processos normais

				If nLimCount >= nLimTran
					//*****************************************
					// O Comentario deste Bloco deve ser      *
					// retirado em caso de DeadLock no banco  *
					//*****************************************
					/*nXz := 1
					While nXz<4 .and. !LockByName("PCOA310_RUN_FINLAN",.T.,.T.,.T.)
						Sleep(1)
						nXz++
					EndDo
               	    If nXz<4*/
						EndTran()
						PcoFinLan(AKB->AKB_PROCES,.F.,.T.,,.F./*lAtuSld*/)
						//UnLockByName("PCOA310_RUN_FINLAN",.T.,.T.,.T.)
						PcoIniLan(AKB->AKB_PROCES)
						BeginTran()
						nLimCount := 0
					/*Else
						nLimCount++
					EndIf*/
				Else
					nLimCount++
				EndIf
				PcoDetLan(AKB->AKB_PROCES,AKB->AKB_ITEM,"PCOA310")			

			Else
                //processos de rateio que utilizam outra tabela alem da de origem
			    If  (AKB->AKB_PROCES == "000002" .And. (AKB->AKB_ENTIDA == "SEZ" .OR.AKB->AKB_ENTIDA == "SEV") .OR. ;
					AKB->AKB_PROCES == "000001" .And. (AKB->AKB_ENTIDA == "SEZ" .OR.AKB->AKB_ENTIDA == "SEV") )			    

					aDetProc	:=	GetDetProc(AKB->AKB_PROCES,AKB->AKB_ITEM)
					DbSelectArea(aDetProc[1,1])
					DbSetOrder(aDetProc[1,2])
					DbSeek(Eval(aDetProc[1,3]))
					While !Eof() .And. Eval(aDetProc[1,4])
						//SEV
						If Len(aDetProc)==1
							PcoDetLan(AKB->AKB_PROCES,AKB->AKB_ITEM,"PCOA310")
							DbSelectArea(aDetProc[1,1])
							DbSkip()
						Else
						//SEZ
							DbSelectArea(aDetProc[2,1])
							DbSetOrder(aDetProc[2,2])
							DbSeek(Eval(aDetProc[2,3]))
							While !Eof() .And. Eval(aDetProc[2,4])
								PcoDetLan(AKB->AKB_PROCES,AKB->AKB_ITEM,"PCOA310")
								DbSelectArea(aDetProc[2,1])
								DbSkip()
							Enddo
							DbSelectArea(aDetProc[1,1])
							DbSkip()
						Endif
					Enddo					
					dbSelectArea(GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM))

			    ElseIf AKB->AKB_PROCES == "000054" 
			    			    
			    	If	AKB->AKB_ITEM $ '09|10|11' .And. AKB->AKB_ENTIDA == "SDE"
						aDetProc :=	GetDetProc(AKB->AKB_PROCES,AKB->AKB_ITEM)
						DbSelectArea(aDetProc[1,1])
						DbSetOrder(aDetProc[1,2])
						If DbSeek(Eval(aDetProc[1,3])) 
							Posic_Tabelas( aDetProc[1,5] )
						EndIf	
						Do While !Eof() .And. Eval(aDetProc[1,4])
							PcoDetLan(AKB->AKB_PROCES,AKB->AKB_ITEM,"PCOA310")
							DbSelectArea(aDetProc[1,1])
							DbSkip()
						EndDo
						dbSelectArea(GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM))
					ElseIf AKB->AKB_ITEM $ '01|05' .And. AKB->AKB_ENTIDA == "SD1"	
						aDetProc :=	GetDetProc(AKB->AKB_PROCES,AKB->AKB_ITEM)
						DbSelectArea(aDetProc[1,1])
						DbSetOrder(aDetProc[1,2])
						DbSeek(Eval(aDetProc[1,3])) 
   						If Eval(aDetProc[1,6])
							PcoDetLan(AKB->AKB_PROCES,AKB->AKB_ITEM,"PCOA310")
						EndIf
						DbSelectArea(aDetProc[1,1])
						dbSelectArea(GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM))
					EndIf
					
				// Processos de movimentacao internas, producao e acerto de inventario devem gerar os 
				// lancamentos na tabela AKD de acordo com o campo D3_TM da tabela SD3.
				ElseIf AKB->AKB_PROCES $ "000151|000152|000153" .And.;
						AKB->AKB_ITEM $ "01|02" .And.;
						AKB->AKB_ENTIDA == "SD3"

					// Movimentos internos
					If AKB->AKB_PROCES == "000151"
						If AKB->AKB_ITEM == "01" .And. SD3->D3_TM <= "500"
							PcoDetLan(AKB->AKB_PROCES,AKB->AKB_ITEM,"PCOA310")
						ElseIf AKB->AKB_ITEM == "02" .And. SD3->D3_TM > "500"
							PcoDetLan(AKB->AKB_PROCES,AKB->AKB_ITEM,"PCOA310")
						EndIf             
					// Producao
					ElseIf AKB->AKB_PROCES == "000152" .And. SubStr(SD3->D3_CF,1,2) $ "PR|ER"
						If AKB->AKB_ITEM == "01" .And. SD3->D3_TM <= "500"
							PcoDetLan(AKB->AKB_PROCES,AKB->AKB_ITEM,"PCOA310")
						ElseIf AKB->AKB_ITEM == "02" .And. SD3->D3_TM > "500"
							PcoDetLan(AKB->AKB_PROCES,AKB->AKB_ITEM,"PCOA310")
						EndIf                                            
					// Inventario
					ElseIf AKB->AKB_PROCES == "000153" .And. SD3->D3_DOC == "INVENT"
						If AKB->AKB_ITEM == "01" .And. SD3->D3_TM <= "500"
							PcoDetLan(AKB->AKB_PROCES,AKB->AKB_ITEM,"PCOA310")
						ElseIf AKB->AKB_ITEM == "02" .And. SD3->D3_TM > "500"
							PcoDetLan(AKB->AKB_PROCES,AKB->AKB_ITEM,"PCOA310")
						EndIf
					EndIf	
				ElseIf AKB->AKB_PROCES == "000358" .And. AKB->AKB_ITEM == '01' // Rotina de planejamento orcamentario
					DbSelectArea("ALX")
					DbSetOrder(2)
					If DbSeek(xFilial("ALX")+ALY->ALY_PLANEJ+ALY->ALY_VERSAO+ALY->ALY_SEQ) // Posiciona Tabela ALX
					
						PcoDetLan(AKB->AKB_PROCES,AKB->AKB_ITEM,"PCOA310")
					
					EndIf
				EndIf            

			Endif			
		EndIf
		
		If lCloseArea
			dbSelectArea("PCOTRB")
		Else
			dbSelectArea(GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM))
		Endif
		If !lThread
			(cAlias)->(dbSkip())		
		Else
			If (cTable)->(FieldPos("THREAD"))>0
				//***********************************
				// Retira flag para reprocessamento *
				// da na Thread.                    *
				//***********************************
				RecLock(cTable,.F.)
				(cTable)->(FieldPut(FieldPos("THREAD"),""))
				MsUnlock()
			EndIf		
			(cTable)->(dbSkip())
		EndIf
	EndDo                        
	If lCloseArea
		DbSelectArea("PCOTRB")
		DbCloseArea()
		DbSelectArea(GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM))
	Endif		
End Transaction		      

PcoFinLan(AKB->AKB_PROCES,.F.,.T.,,.F./*lAtuSld*/)

If lAtuSld .And. lTemReg
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Atualiza Saldos dos Cubos         ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea("AL1")
	AL1->(dbSetOrder(1))
	If AL1->(dbSeek(xFilial("AL1"))) //Verifica se existe Cubo cadastrado
		cCubIni := AL1->AL1_CONFIG
		AL1->(dbSeek(xFilial("AL1")+Replicate('z',TamSX3("AL1_CONFIG")[1]),.T.))
		AL1->(dbSkip(-1)) 
	 	cCubFim := AL1->AL1_CONFIG
	  	PCOA301EXE(,.T.,{cCubIni,cCubFim,aRet[DEF_DATINI],aRet[DEF_DATFIN],.T.,""}) //Atualizar Saldo dos Cubos
	EndIf	
EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA310   บAutor  ณMicrosiga           บ Data ณ  05/22/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function GetEntFilt(cProcesso,cItem)
Local aArea := GetArea()
DbSelectArea('AKB')
DbSetOrder(1)
MsSeek(xFilial()+cProcesso+cItem)
cRet	:=	AKB->AKB_ENTIDA
If cProcesso == "000002" .And. (AKB->AKB_ENTIDA == "SEZ" .OR.AKB->AKB_ENTIDA == "SEV")
	cRet	:=	"SE2"                                                                       
ElseIf cProcesso == "000001" .And. (AKB->AKB_ENTIDA == "SEZ" .OR.AKB->AKB_ENTIDA == "SEV")
	cRet	:=	"SE1"       
ElseIf cProcesso == "000054" .And. AKB->AKB_ENTIDA == "SDE"
	cRet	:=	"SD1"       
Endif	                                                                	
RestArea(aArea)
Return cRet              


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA310   บAutor  ณMicrosiga           บ Data ณ  05/22/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function DetProc(cProcesso, cItem)
Local lRet	:=	.F.
If cProcesso == "000002" .And. (cItem == '04' .OR. cItem == '05')
	lRet	:=	.T.
ElseIf cProcesso == "000001" .And. (cItem == '04' .OR. cItem == '05')
	lRet	:=	.T.
ElseIf cProcesso == "000054" .And. cItem $ '09|10|11'
	lRet	:=	.T.
ElseIf cProcesso == "000054" .And. cItem $ '01|05'
	lRet	:=	.T.
ElseIf cProcesso $ "000151|000152|000153" .And. cItem $ '01|02'
	lRet	:=	.T.
ElseIf cProcesso $ "000358" .And. cItem $ '01' // Rotina de planejamento orcamentario
	lRet	:=	.T.
Endif	                                                                	
Return lRet              


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA310   บAutor  ณMicrosiga           บ Data ณ  05/22/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function GetDetProc(cProcesso, cItem)
Local lRet		:=	.F.
Local aDetProc	:=	{}
Local cChaveSEV	:= ""
Local cChaveSDE	:= ""
Local cChaveSD1	:= ""
         
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณEstrutura do Array aDetProc                                                                ณ
//ณ                                                                                           ณ
//ณaDetProc[n,1] - Alias da tabela principal do lancamento na AKD                             ณ
//ณaDetProc[n,2] - Indice para posicionamento (dbSetOrder)                                    ณ
//ณaDetProc[n,3] - Chave do registro posicionado para pesquisa na tabela principal            ณ
//ณaDetProc[n,4] - Chave para condicao do loop                                                ณ
//ณaDetProc[n,5] - Tabelas para posicionar a partir da tabela principal (funcao Posic_Tabelas)ณ
//ณaDetProc[n,5,1] - Alias da tabela secundaria                                               ณ
//ณaDetProc[n,5,2] - Ordem para pesquisa                                                      ณ
//ณaDetProc[n,5,3] - Chave para pesquisa                                                      ณ
//ณaDetProc[n,6] - Condicao de filtro para nao processar linha da tabela principal            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If cProcesso == "000002"  .And. (cItem == '04' .Or. cItem == '05')
	aDetProc	:=	Array(1,4)
	aDetProc[1,1]	:=	"SEV"
	aDetProc[1,2]	:=	2                
	cChaveSeV := RetChaveSev("SE2")
	aDetProc[1,3]	:=	&('{|| "' + cChaveSEV + '"}')
	aDetProc[1,4]	:=	&('{|| xFilial("SEV")+SEV->(EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIFOR+EV_LOJA+EV_IDENT) == "' + cChaveSEV +"1"+'"}')
	If cItem == '05'
		AAdd(aDetProc,Array(4))
		aDetProc[2,1]	:=	"SEZ"
		aDetProc[2,2]	:=	4
		cChaveSeV := RetChaveSev("SE2",,"SEZ")
		aDetProc[2,3]	:=	&('{|| "' + cChaveSEV + '"+ SEV->EV_NATUREZ }')
		aDetProc[2,4]	:=	&('{|| xFilial("SEZ")+SEZ->(EZ_PREFIXO+EZ_NUM+EZ_PARCELA+EZ_TIPO+EZ_CLIFOR+EZ_LOJA+EZ_NATUREZ+EZ_IDENT) == "' + cChaveSEV +'"+SEV->EV_NATUREZ+"1"}')
	Endif
ElseIf cProcesso == "000001" .And. (cItem == '04' .OR. cItem == '05')
	aDetProc	:=	Array(1,4)
	aDetProc[1,1]	:=	"SEV"
	aDetProc[1,2]	:=	2                
	cChaveSeV := RetChaveSev("SE1")
	aDetProc[1,3]	:=	&('{|| "' + cChaveSEV + '"}')
	aDetProc[1,4]	:=	&('{|| xFilial("SEV")+SEV->(EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIFOR+EV_LOJA+EV_IDENT) == "' + cChaveSEV +"1"+'"}')
	If cItem == '05'      
		AAdd(aDetProc,Array(4))
		aDetProc[2,1]	:=	"SEZ"
		aDetProc[2,2]	:=	4
		cChaveSeV := RetChaveSev("SE1",,"SEZ")
		aDetProc[2,3]	:=	&('{|| "' + cChaveSEV + '"+ SEV->EV_NATUREZ }')
		aDetProc[2,4]	:=	&('{|| xFilial("SEZ")+SEZ->(EZ_PREFIXO+EZ_NUM+EZ_PARCELA+EZ_TIPO+EZ_CLIFOR+EZ_LOJA+EZ_NATUREZ+EZ_IDENT) == "' + cChaveSEV +'"+SEV->EV_NATUREZ+"1"}')
	Endif
ElseIf cProcesso == "000054" .And. cItem $ '09|10|11'
	aDetProc	:=	Array(1,5)
	aDetProc[1,1]	:=	"SDE"
	aDetProc[1,2]	:=	1
	cChaveSDE 		:=  RetChaveSDE("SD1")
	aDetProc[1,3]	:=	&('{|| "' + cChaveSDE  + '"}')
	aDetProc[1,4]	:=	&('{|| xFilial("SDE")+SDE->(DE_DOC+DE_SERIE+DE_FORNECE+DE_LOJA+DE_ITEMNF) == "' + cChaveSDE +'" }')
	aDetProc[1,5]	:=	{}   //ARRAY PARA POSICIONAR TABELAS CONFORME ITEM 	
	aAdd(aDetProc[1,5], { "SF1", 1, &('{|| "' + RetChaveSDE("SD1",,"SF1") + '"}') })
	aAdd(aDetProc[1,5], { "SB1", 1, &('{|| xFilial("SB1")+'+GetEntFilt(cProcesso,cItem)+'->D1_COD }') })
	aAdd(aDetProc[1,5], { "SA2", 1, &('{||  xFilial("SA2")+'+GetEntFilt(cProcesso,cItem)+'->(D1_FORNECE+D1_LOJA) }') })
ElseIf cProcesso == "000054" .And. cItem $ '01|05'
	aDetProc	:=	Array(1,6)
	aDetProc[1,1]	:=	"SD1"
	aDetProc[1,2]	:=	1                   
	cChaveSD1		:=	SD1->(IndexKey(1))
	aDetProc[1,3]	:=	&("{|| "+cChaveSD1+"}")
	aDetProc[1,4]	:=	{}
	aDetProc[1,5]	:=	{}   
	If cItem == "01"
		aDetProc[1,6] := {|| SD1->D1_TIPO <> "D"}
	Else	
		aDetProc[1,6] := {|| SD1->D1_TIPO == "D"}
	EndIf	
Endif	                                                                	

Return aDetProc


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA310   บAutor  ณMicrosiga           บ Data ณ  05/22/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function RetChaveSDE(cAlias,cCampo,cArqKey)
Local cChave

cArqKey := IIf(cArqKey == NIL,"SDE",cArqKey)

If cAlias $ "SD1|SF1"
	cCampo := Right(cAlias,2)
Endif
cChave := xFilial(cArqKey)+(cAlias)->&(cCampo+"_DOC")+(cAlias)->&(cCampo+"_SERIE")+;
		  					    (cAlias)->&(cCampo+"_FORNECE")+(cAlias)->&(cCampo+"_LOJA")+;
								If(cArqKey=='SF1', "", (cAlias)->&(cCampo+"_ITEM"))		  					    
Return cChave


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA310   บAutor  ณMicrosiga           บ Data ณ  05/22/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Posic_Tabelas(aPosic)
Local nX
Local aArea := GetArea()
Local nOrdem := 0
Local nPosAlias

nPosAlias := ASCAN(aPosic, {|aVal| aVal[1] == aArea[1] })

For nX := 1 TO Len(aPosic)
	dbSelectArea(aPosic[nX,1])
	nOrdem := IndexOrd()
	dbSetOrder(aPosic[nX,2])
	dbSeek(Eval(aPosic[nX,3]))
	//depois que posicionou retorna para dbsetorder() de origem
	//atencao -> nao pode ser utilizado Getarea() / RestArea() - deve ficar posicionado
	dbSetOrder(nOrdem)
Next

If nPosAlias > 0   //se tiver que posicionar na tabela atual soh retorna para alias
	dbSelectArea(aArea[1])
Else  //senao restaura a area
	RestArea(aArea)
EndIf	

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณMenuDef   ณ Autor ณ Ana Paula N. Silva     ณ Data ณ29/11/06 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Utilizacao de menu Funcional                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณArray com opcoes da rotina.                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณParametros do array a Rotina:                               ณฑฑ
ฑฑณ          ณ1. Nome a aparecer no cabecalho                             ณฑฑ
ฑฑณ          ณ2. Nome da Rotina associada                                 ณฑฑ
ฑฑณ          ณ3. Reservado                                                ณฑฑ
ฑฑณ          ณ4. Tipo de Transao a ser efetuada:                        ณฑฑ
ฑฑณ          ณ		1 - Pesquisa e Posiciona em um Banco de Dados     ณฑฑ
ฑฑณ          ณ    2 - Simplesmente Mostra os Campos                       ณฑฑ
ฑฑณ          ณ    3 - Inclui registros no Bancos de Dados                 ณฑฑ
ฑฑณ          ณ    4 - Altera o registro corrente                          ณฑฑ
ฑฑณ          ณ    5 - Remove o registro corrente do Banco de Dados        ณฑฑ
ฑฑณ          ณ5. Nivel de acesso                                          ณฑฑ
ฑฑณ          ณ6. Habilita Menu Funcional                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ   DATA   ณ Programador   ณManutencao efetuada                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ               ณ                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function MenuDef()
Local aUsRotina := {}
Local aRotina 	:= {	{ STR0002,		"AxPesqui", 0 , 1},;     //"Pesquisar // Buscar"
							{ STR0003, 	"A310DLG" , 0 , 2}, ; //"Reprocessar"
							{ "View Log", 	"ProcLogView()" , 0 , 2} } 
						
If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Adiciona botoes do usuario no aRotina                                  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If ExistBlock( "PCOA3101" )
		//P_Eฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//P_Eณ Ponto de entrada utilizado para inclusao de funcoes de usuarios no     ณ
		//P_Eณ browse da tela de Configuracao dos Lancamentos                         ณ
		//P_Eณ Parametros : Nenhum                                                    ณ
		//P_Eณ Retorno    : Array contendo as rotinas a serem adicionados na enchoice ณ
		//P_Eณ               Ex. :  User Function PCOA3101                            ณ
		//P_Eณ                      Return {{"Titulo", {|| U_Teste() } }}             ณ
		//P_Eภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If ValType( aUsRotina := ExecBlock( "PCOA3101", .F., .F. ) ) == "A"
			AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
		EndIf
	EndIf
EndIf
Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPco310NextAliasบAutorณ Acacio Egas            ณ  18/15/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณProte็ใo para retornar o pr๓ximo alias disponivel no Banco  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Pco310Tmp(cAlias)

Local aArea := GetArea()
Local lRet	:= .F.

If !TCCanOpen(cAlias) .And. Select(cAlias) == 0
	lRet	:= .T.
EndIf

RestArea(aArea)
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ A310FilAKD บAutorณ Paulo Carnelossi         ณ  30/08/2016 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida filtro para verificar se pode inserir na clausula    บฑฑ
ฑฑบ          ณWHERE da query                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function A310FilAKD( cFiltAKD, cFiltQry)
Local lRet := .T.

Default cFiltQry := ""  

//verifica se filtro digitado por usuario e resolvido na query
If !Empty(cFiltAKD)
	cFiltQry := PcoParseFil(cFiltAKD, "AKD")
	If Empty(cFiltQry)
		Aviso("Atencao","Expressao de filtro invalida para ser executado por procedure.",{"Cancela"})
		lRet := .F.
	EndIf
EndIf	

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ Pcoa310PDel บAutorณ Paulo Carnelossi         ณ  30/08/2016 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณProcedure para excluir registros da AKD do processo         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function A310ProcDel(cProc, cFilProc, cFiltQry)
Local aArea := GetArea()
Local lRet  := .T.
Local cQuery := ""
Local cWhere := ""
Local lDelAll := SuperGetMV("MV_PCODELR",.T.,"1")=="2" // Deleta todos os movimentos (Validos e Invalidos)

cQuery :="create procedure "+cProc+"_"+cEmpAnt+CRLF
cQuery +="( "+CRLF
cQuery +="	@IN_FILIAL      Char("+Alltrim(Str(Len(AKD->AKD_FILIAL)))+"),"+CRLF
cQuery +="	@IN_ENTIDA      Char("+Alltrim(Str(Len(AKB->AKB_ENTIDA)))+"),"+CRLF
cQuery +="	@IN_PROCES      Char("+Alltrim(Str(Len(AKB->AKB_PROCES)))+"),"+CRLF
cQuery +="	@IN_ITEMPR      Char("+Alltrim(Str(Len(AKB->AKB_ITEM)))+"),"+CRLF
cQuery +="	@IN_DATAINI     Char(8),"+CRLF
cQuery +="	@IN_DATAFIM     Char(8),"+CRLF
cQuery+="   @OUT_RESULT Char( 01) OutPut"+CRLF
cQuery+=")"+CRLF
cQuery+="as"+CRLF
cQuery +=""+CRLF

/* ---------------------------------------------------------------------------------------------------------------------
   Versใo          - <v> Protheus 11.8 </v>
   Assinatura      - <a> 001 </a>
   Fonte Microsiga - <s> PCOA310.PRX </s>
   Descricao       - <d> Exclusao dos registros da AKD no Reprocessamento de lancamentos para processo/item no periodo </d>
   Funcao do Siga  -     
   -----------------------------------------------------------------------------------------------------------------
   Entrada         -  <ri> @IN_FILIAL	- Filial corrente 
       				   		@IN_ENTIDA  - Entidade (por ex CT2)
       				   		@IN_PROCES  - Processo (por ex 000082 contabilizacao)
       				   		@IN_ITEMPR  - Item do Processo
         					@IN_DATAINI   - Periodo Inicial
         					@IN_DATAFIM   - Periodo Final	</ri>
   -----------------------------------------------------------------------------------------------------------------
   Saida          -  <ro> @OUT_RESULT    -  </ro>
   -----------------------------------------------------------------------------------------------------------------
   Responsavel    -   <r> Paulo Carnelossi  </r>
   -----------------------------------------------------------------------------------------------------------------
   Data           -  <dt> 22/09/2016 </dt>
   
   1 - Exclusao dos registros da AKD no Reprocessamento de lancamentos para processo/item no periodo
   --------------------------------------------------------------------------------------------------------------------- */

cQuery+="Declare @cFil_AKD    Char("+Alltrim(Str(Len(AKD->AKD_FILIAL)))+")"+CRLF
cQuery+="Declare @cFil_Entid  Char("+Alltrim(Str(Len(AKD->AKD_FILIAL)))+")"+CRLF
cQuery+="Declare @cAux  Char(3)"+CRLF
cQuery+="Declare @iprimeiro_recno integer"+CRLF
cQuery+="Declare @iultimo_recno   integer"+CRLF

// Insere tratamento para xfilial dentro do codigo 
cQuery +="begin"+CRLF
   /* --------------------------------------------------------------
      Recuperando Filiais
      -------------------------------------------------------------- */
cQuery +="   select @cAux = 'AKD'"+CRLF
cQuery +="   EXEC "+cFilProc+"_"+cEmpAnt+" @cAux, @IN_FILIAL, @cFil_AKD OutPut "+CRLF

cQuery +="   select @cAux = @IN_ENTIDA"+CRLF
cQuery +="   EXEC "+cFilProc+"_"+cEmpAnt+" @cAux, @IN_FILIAL, @cFil_Entid OutPut "+CRLF

cQuery += " SELECT @iprimeiro_recno = ISNULL( MIN( R_E_C_N_O_ ), 0 ), @iultimo_recno = ISNULL( MAX( R_E_C_N_O_ ) , 0 )"+CRLF
cQuery += " FROM "+RetSqlName("AKD")+CRLF
cQuery += " WHERE "+CRLF
cWhere := "   AKD_FILIAL = @cFil_AKD AND "
If AKD->(FieldPos("AKD_FILORI")) > 0
	cWhere += "   AKD_FILORI = @cFil_Entid AND "  //'" + xFilial(AKB->AKB_ENTIDA)  + "'
EndIf
cWhere += "   AKD_PROCES = @IN_PROCES AND "
cWhere += "   AKD_ITEM   = @IN_ITEMPR AND "
cWhere += "   ( "
cWhere += "		AKD_DATA = ' ' OR ( AKD_DATA BETWEEN @IN_DATAINI AND @IN_DATAFIM )" 
cWhere += "   ) "

//*************************************
// utilizado para Deletar todos os    *
// lan็amentos (validos e invalidos). *
//*************************************
If lDelAll
	cWhere +=	" AND AKD_TIPO IN ( '1', '2', '3') "
Else
	cWhere +=	" AND AKD_STATUS='1' "
	cWhere +=	" AND AKD_TIPO IN ( '1', '2') "
EndIf

// Adiciona expressao de filtro convertida para SQL	
If !Empty(cFiltQry)
	cWhere += " AND (" + cFiltQry +")"
EndIf

cWhere += " AND D_E_L_E_T_ = ' '"+CRLF

cQuery += cWhere

cQuery += "/*----------------------------------------------------------------------------------------------"+CRLF
cQuery += "Fazendo DELETE por blocos."+CRLF
cQuery += "----------------------------------------------------------------------------------------------*/"+CRLF
cQuery += " WHILE ( @iprimeiro_recno <= @iultimo_recno ) begin"+CRLF
cQuery += "                  "+CRLF
cQuery += " BEGIN TRAN"+CRLF
cQuery += " DELETE "+RetSqlName("AKD")
cQuery += " WHERE"+CRLF
cQuery += cWhere              
cQuery += " and R_E_C_N_O_ between @iprimeiro_recno and @iprimeiro_recno + 1024"+CRLF
cQuery += " COMMIT TRAN"+CRLF
cQuery += " SELECT @iprimeiro_recno = @iprimeiro_recno + 1024"+CRLF
cQuery += " "+CRLF                  
cQuery += " END"+CRLF
cQuery += ""+CRLF                  

cQuery+="   select @OUT_RESULT  = '1'"+CRLF
cQuery+="End"+CRLF
cQuery := MsParse( cQuery, If( Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB()) ) )
cQuery := CtbAjustaP(.F., cQuery, 0)

If Empty( cQuery )
	MsgAlert(MsParseError(),'A query da procedure de exclusao dos movimentos nao passou pelo Parse '+cProc)
	lRet := .F.
Else
	If !TCSPExist( cProc )
		cRet := TcSqlExec(cQuery)
		If cRet <> 0
			If !__lBlind
				MsgAlert("Erro na criacao da procedure de exclusao dos movimentos: "+cProc)
				lRet:= .F.
			EndIf
		EndIf
	EndIf
EndIf
RestArea(aArea)

//script exemplo em sql server da rotina acima - nao retirar
/*

-- Procedure creation 
CREATE PROCEDURE [dbo].[SC025460_T1] (
    @IN_FILIAL Char( 8 ) , 
    @IN_ENTIDA Char( 3 ) , 
    @IN_PROCES Char( 6 ) , 
    @IN_ITEMPR Char( 2 ) , 
    @IN_DATAINI Char( 8 ) , 
    @IN_DATAFIM Char( 8 ) , 
    @OUT_RESULT Char( 01 )  output ) AS
 
-- Declaration of variables
DECLARE @cFil_AKD Char( 8 )
DECLARE @cFil_Entid Char( 8 )
DECLARE @cAux Char( 3 )
DECLARE @iprimeiro_recno Integer
DECLARE @iultimo_recno Integer
BEGIN
   SET @cAux  = 'AKD' 
   EXEC SC025420_T1 @cAux , @IN_FILIAL , @cFil_AKD output 
   SET @cAux  = @IN_ENTIDA 
   EXEC SC025420_T1 @cAux , @IN_FILIAL , @cFil_Entid output 
   SELECT @iprimeiro_recno  = ISNULL ( MIN ( R_E_C_N_O_ ), 0 ), @iultimo_recno  = ISNULL ( MAX ( R_E_C_N_O_ ), 0 )
     FROM AKDT10 
     WHERE AKD_FILIAL  = @cFil_AKD  
       and AKD_FILORI  = @cFil_Entid  
       and AKD_PROCES  = @IN_PROCES  
       and AKD_ITEM  = @IN_ITEMPR 
       and  (AKD_DATA  = ' '  or  (AKD_DATA  between @IN_DATAINI and @IN_DATAFIM ) )  
       and AKD_STATUS  = '1'  
       and AKD_TIPO IN ('1' , '2' )  
       and D_E_L_E_T_  = ' ' 
   
   WHILE ( (@iprimeiro_recno  <= @iultimo_recno ) )
   BEGIN
      BEGIN TRAN 
      DELETE FROM AKDT10  
      WHERE AKD_FILIAL  = @cFil_AKD  
        and AKD_FILORI  = @cFil_Entid  
        and AKD_PROCES  = @IN_PROCES  
        and AKD_ITEM  = @IN_ITEMPR 
        and  (AKD_DATA  = ' '  or  (AKD_DATA  between @IN_DATAINI and @IN_DATAFIM ) )  
        and AKD_STATUS  = '1'  
        and AKD_TIPO IN ('1' , '2' )  
        and D_E_L_E_T_  = ' '  
        and R_E_C_N_O_  between @iprimeiro_recno and @iprimeiro_recno  + 1024 
      COMMIT TRAN 
      SET @iprimeiro_recno  = @iprimeiro_recno  + 1024 
   END 
   SET @OUT_RESULT  = '1' 
END 

*/

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ A310LOTAKD  บAutorณ Paulo Carnelossi         ณ  30/08/2016 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para lockar o proximo lote da AKD                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function A310LOTAKD()
Local cAliasQry
Local cNumLote  := SPACE(LEN(AKD->AKD_LOTE))
Local cQryAKD   := ""
Local lRet      := .T.
Local cQuery    := ""
Local aResult   := {}

If __lProcAKDLOTE  == NIL .OR. __lProcAKDLOTE 

	If __cProcLote == NIL
		
		__cProcLote := CriaTrab(,.F.)
		
		cQuery :="create procedure "+__cProcLote+"_"+cEmpAnt+CRLF
		cQuery +="( "+CRLF
		cQuery+="   @OUT_RESULT     Char("+Alltrim(Str(Len(AKD->AKD_LOTE)))+") OutPut"+CRLF
		cQuery+=")"+CRLF
		cQuery+="as"+CRLF
		cQuery +=""+CRLF
		
		/* ---------------------------------------------------------------------------------------------------------------------
	   Versใo          - <v> Protheus 11.8 </v>
	   Assinatura      - <a> 001 </a>
	   Fonte Microsiga - <s> PCOA310.PRX </s>
	   Descricao       - <d> Geracao do proximo lote no Reprocessamento de lancamentos para processo/item no periodo </d>
	   Funcao do Siga  -     
	   -----------------------------------------------------------------------------------------------------------------
	   Entrada         -  <ri> </ri>
	   -----------------------------------------------------------------------------------------------------------------
	   Saida          -  <ro> @OUT_RESULT    -  </ro>
	   -----------------------------------------------------------------------------------------------------------------
	   Responsavel    -   <r> Paulo Carnelossi  </r>
	   -----------------------------------------------------------------------------------------------------------------
	   Data           -  <dt> 22/09/2016 </dt>
	   
	   1 - Geracao do proximo lote no Reprocessamento de lancamentos para processo/item no periodo
	   --------------------------------------------------------------------------------------------------------------------- */
		cQuery+="Declare @cAKD_LOTE    Char("+Alltrim(Str(Len(AKD->AKD_LOTE)))+") "+CRLF
		
		// Insere tratamento para xfilial dentro do codigo 
		cQuery +="begin"+CRLF
		
		cQuery += " SELECT @cAKD_LOTE = ISNULL( MAX( AKD.AKD_LOTE ), ' ') "+CRLF
		cQuery += " FROM " + RetSqlName( "AKD" ) + " AKD "+CRLF
		cQuery += " WHERE "+CRLF
		cQuery += " AKD.AKD_FILIAL='" + xFilial("AKD")               + "' AND "+CRLF
		cQuery += " AKD.D_E_L_E_T_=' '"+CRLF
		cQuery += " if @cAKD_LOTE = ' ' begin"+CRLF
		cQuery += "     SELECT @cAKD_LOTE = '0000000001' "+CRLF
		cQuery += " end else begin "+CRLF
		cQuery += "     EXEC "+__cProcSoma1+"_"+cEmpAnt+" @cAKD_LOTE, '0', @cAKD_LOTE OutPut "+CRLF
		cQuery += " end "+CRLF
		cQuery += " SELECT @OUT_RESULT = @cAKD_LOTE "+CRLF
		 
		cQuery += "end "+CRLF
		cQuery := MsParse( cQuery, If( Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB()) ) )
		cQuery := CtbAjustaP(.F., cQuery, 0)
		
		If Empty( cQuery )
			MsgAlert(MsParseError()+CRLF+'A query da procedure do proximo lote nao passou pelo Parse '+__cProcLote,"Parse Error")
			lRet := .F.
			__lProcAKDLOTE := .F.
		Else
			If !TCSPExist( __cProcLote )
				cRet := TcSqlExec(cQuery)
				If cRet <> 0
					If !__lBlind
						MsgAlert("Erro na criacao da procedure  do proximo lote: "+__cProcLote)
						lRet:= .F.
						__lProcAKDLOTE := .F.
					EndIf
				Else
					__lProcAKDLOTE := .T.
				EndIf
			EndIf
		EndIf
	
	EndIf
	
	//se criou procedure e nao deu erro 
	If lRet .And. __lProcAKDLOTE
	
		//executa a procedure para proximo lote
		aResult := TCSPExec( xProcedures(__cProcLote) )

		If Empty(aResult)
			MsgAlert(tcsqlerror(),"Erro na procedure de geracao do proximo lote.")
			lRet := .F.
			__lProcAKDLOTE := .F.
		Else
		
			cNumLote := aResult[1]
			//la็o para semaforo no numero do lote na filial 
			While !Empty(cNumLote) .And. !MayIUseCode("AKD"+xFilial('AKD')+cNumLote) 
			
				cNumLote := Soma1(cNumLote)
				
			EndDo 
		
		EndIf
		
	EndIf
	
EndIf

If ! __lProcAKDLOTE

	cAliasQry := CriaTrab(,.F.)
	cQryAKD := "SELECT ISNULL(MAX(AKD_LOTE),' ') LOTE "
	cQryAKD += "  FROM " + RetSqlName( 'AKD' ) + " AKD "
	cQryAKD += " WHERE AKD.AKD_FILIAL = '" + xFilial( 'AKD' ) + "'"
	cQryAKD += "   AND D_E_L_E_T_ = ' '"
	
	cQryAKD := ChangeQuery(cQryAKD)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryAKD),cAliasQry,.T.,.F.)
	
	If (cAliasQry)->LOTE = ' '
		cNumLote := StrZero(1,LEN(AKD->AKD_LOTE))
	Else
		cNumLote := Soma1((cAliasQry)->LOTE)
	EndIf
	
	(cAliasQry)->(dbCloseArea())
	//la็o para semaforo no numero do lote na filial 
	While !Empty(cNumLote) .And. !MayIUseCode("AKD"+xFilial('AKD')+cNumLote) 
	
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryAKD),cAliasQry,.T.,.F.)
	
		If (cAliasQry)->LOTE = ' '
			cNumLote := StrZero(1,LEN(AKD->AKD_LOTE))
		Else
			cNumLote := Soma1((cAliasQry)->LOTE)
		EndIf
		
		(cAliasQry)->(dbCloseArea())
		       
	EndDo 

EndIf

//scrip da procedure em sql server para Geracao do proximo lote 
/*


*/
Return(cNumLote)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ A310LoteId  บAutorณ Paulo Carnelossi         ณ  30/08/2016 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para gerar proximo id do lote                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function A310LoteId()
Local lRet := .T.
Local cQuery := ""

cQuery :="create procedure "+__cProcId+"_"+cEmpAnt+CRLF
cQuery +="( "+CRLF
cQuery +="	@IN_LOTE      	Char("+Alltrim(Str(Len(AKD->AKD_LOTE)))+"), "+CRLF
cQuery+="   @OUT_RESULT     Char("+Alltrim(Str(Len(AKD->AKD_ID)))+") OutPut"+CRLF
cQuery+=")"+CRLF
cQuery+="as"+CRLF
cQuery +=""+CRLF

		/* ---------------------------------------------------------------------------------------------------------------------
	   Versใo          - <v> Protheus 11.8 </v>
	   Assinatura      - <a> 001 </a>
	   Fonte Microsiga - <s> PCOA310.PRX </s>
	   Descricao       - <d> Geracao do proximo id (item) do lote no Reprocessamento de lancamentos para processo/item no periodo </d>
	   Funcao do Siga  -     
	   -----------------------------------------------------------------------------------------------------------------
	   Entrada         -  <ri> </ri>
	   -----------------------------------------------------------------------------------------------------------------
	   Saida          -  <ro> @OUT_RESULT    -  </ro>
	   -----------------------------------------------------------------------------------------------------------------
	   Responsavel    -   <r> Paulo Carnelossi  </r>
	   -----------------------------------------------------------------------------------------------------------------
	   Data           -  <dt> 22/09/2016 </dt>
	   
	   1 - Geracao do proximo id (item) do lote chamado no ponto de entrada
	   --------------------------------------------------------------------------------------------------------------------- */

cQuery+="Declare @cAKD_ID    Char("+Alltrim(Str(Len(AKD->AKD_ID)))+") "+CRLF
cQuery+="Declare @cAKD_IDOUT Char("+Alltrim(Str(Len(AKD->AKD_ID)))+") "+CRLF

// Insere tratamento para xfilial dentro do codigo 
cQuery +="begin"+CRLF

cQuery += "     SELECT @cAKD_IDOUT = '    ' "+CRLF

cQuery += " SELECT @cAKD_ID = ISNULL( MAX( AKD.AKD_ID ), ' ') "+CRLF
cQuery += " FROM " + RetSqlName( "AKD" ) + " AKD "+CRLF
cQuery += " WHERE "+CRLF
cQuery += " AKD.AKD_FILIAL='" + xFilial("AKD")               + "' AND "+CRLF
cQuery += " AKD.AKD_LOTE = @IN_LOTE AND "+CRLF
cQuery += " AKD.D_E_L_E_T_=' '"+CRLF
cQuery += " if @cAKD_ID = ' ' begin"+CRLF
cQuery += "     SELECT @cAKD_IDOUT = '0001' "+CRLF
cQuery += " end else begin "+CRLF
cQuery += "     EXEC "+__cProcSoma1+"_"+cEmpAnt+" @cAKD_ID, '0', @cAKD_IDOUT OutPut "+CRLF
cQuery += " end "+CRLF
cQuery += " SELECT @OUT_RESULT = @cAKD_IDOUT "+CRLF
 
cQuery += "end "+CRLF
cQuery := MsParse( cQuery, If( Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB()) ) )
cQuery := CtbAjustaP(.F., cQuery, 0)

If Empty( cQuery )
	MsgAlert(MsParseError()+CRLF+'A query da procedure do proximo item do lote nao passou pelo Parse '+__cProcId,"Parse Error")
	lRet := .F.
Else
	If !TCSPExist( __cProcId )
		cRet := TcSqlExec(cQuery)
		If cRet <> 0
			If !__lBlind
				MsgAlert("Erro na criacao da procedure  do proximo item do lote: "+__cProcId)
				lRet:= .F.
			EndIf
		EndIf
	EndIf
EndIf

//scrip da procedure em sql server para Geracao do proximo ID (item) do lote 
/*
-- Procedure creation 
CREATE PROCEDURE [dbo].[SC025530_T1] (
    @IN_LOTE Char( 10 ) , 
    @OUT_RESULT Char( 4 )  output ) AS
 
-- Declaration of variables
DECLARE @cAKD_ID Char( 4 )
DECLARE @cAKD_IDOUT Char( 4 )
BEGIN
   SELECT @cAKD_ID  = ISNULL ( MAX ( AKD.AKD_ID ), ' ' )
     FROM AKDT10 AKD
     WHERE AKD.AKD_FILIAL  = 'D MG 01 '  and AKD.AKD_LOTE  = @IN_LOTE  and AKD.D_E_L_E_T_  = ' ' 
   IF @cAKD_IDOUT  = ' ' 
   BEGIN 
      SET @cAKD_IDOUT  = '0001' 
   END 
   ELSE 
   BEGIN 
   	  //CHAMA A PROCEDURE SOMA1 PASSANDO O MAX DO AKD_ID E RECEBE NA VARIAVEL @cAKD_ID 
      EXEC SC025520_T1 @cAKD_ID , '0' , @cAKD_IDOUT output   
   END 
   SET @OUT_RESULT  = @cAKD_IDOUT 
END 

*/

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ A310Tools   บAutorณ Paulo Carnelossi         ณ  30/08/2016 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para criar procedures soma1 e strzero                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function A310Tools()
Local lRet := .T.

If lRet
	
	If __cProcZero == NIL
		__cProcZero := CriaTrab(,.F.)
	EndIf

	cSqlCtbZERO := ProcSTRZERO(__cProcZero)
	
	If !TCSPExist( __cProcZero )
		cRet := TcSqlExec(cSqlCtbZERO)
		If cRet <> 0
			If !__lBlind
				MsgAlert("Erro na criacao da procedure CtbZero[StrZero] : "+cNomProcZero,"Erro") 
				lRet:= .F.
			EndIf
		EndIf
	EndIf

	If lRet

		If __cProcSoma1 == NIL
			__cProcSoma1 := CriaTrab(,.F.)
		Endif
		
		lRet := ! TCSPExist( __cProcSoma1 )

		lRet := lRet .And. CTM300SOMA( __cProcSoma1 , __cProcZero+"_"+cEmpAnt )

	EndIf

EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA310ExProc บAutor  ณMicrosiga          บ Data ณ  08/09/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExecucao do reprocessamento de lancamentos por procedure    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A310ExProc(aRet,lAtuSld, cAliasEnt, cFiltAKD)
Local nLimTran	:= SuperGetMv("MV_PCOLIMI",.T.,50000)
Local cFilialde := ""
Local cFilialAte := ""
Local cQuery := ""
Local cFiltQry := ""

Local cProcesso := AKB->AKB_PROCES
Local cItem := AKB->AKB_ITEM
Local cNumLote := ""

Local aResult	:= {}
Local lFirst    := .T.
Local nRegProc  := 0
Local lRet      := .T.
Local aProc
Local aMsg
Local lAtSld300 := .F.

Default aRet := {}
Default lAtuSld := .F.
Default cAliasEnt := ""
Default cFiltAKD := ""

If Len(aRet) > 0 .And. !Empty(cAliasEnt) .And. A310FilAKD( cFiltAKD, @cFiltQry)

	If  SubStr( cAliasEnt, 1, 1) == "S" 
		//se a primeira letra do alias for "S" entao	
		//considera campo filial a partir da segunda exemplo tabela SA1 - campo A1_FILIAL
		If !Empty(xFilial(cAliasEnt)) .And. Len(xFilial(cAliasEnt)) == 2
			aRet[DEF_FILTRO] += If(Empty(aRet[DEF_FILTRO]),"",".and.")
			aRet[DEF_FILTRO] += cAliasEnt +"->"+ SubStr( cAliasEnt, 2, 2 )+"_FILIAL>='"+cFilialDe+"' .and. "
			aRet[DEF_FILTRO] += cAliasEnt +"->"+ SubStr( cAliasEnt, 2, 2 )+"_FILIAL<='"+cFilialAte+"'"
		Else
			aRet[DEF_FILTRO] += If(Empty(aRet[DEF_FILTRO]),"",".and.")
			aRet[DEF_FILTRO] += cAliasEnt +"->"+SubStr( cAliasEnt, 2, 2 )+"_FILIAL=='"+xFilial(cAliasEnt)+"'"
		EndIf
	Else			
		If !Empty(xFilial(cAliasEnt)) .And. Len(xFilial(cAliasEnt)) == 2
			aRet[DEF_FILTRO] += If(Empty(aRet[DEF_FILTRO]),"",".and.")
			aRet[DEF_FILTRO] += cAliasEnt +"->"+cAliasEnt+"_FILIAL>='"+cFilialDe+"' .and. "
			aRet[DEF_FILTRO] += cAliasEnt +"->"+cAliasEnt+"_FILIAL<='"+cFilialAte+"'"
		Else
			aRet[DEF_FILTRO] += If(Empty(aRet[DEF_FILTRO]),"",".and.")
			aRet[DEF_FILTRO] += cAliasEnt +"->"+cAliasEnt+"_FILIAL=='"+xFilial(cAliasEnt)+"'"
		Endif
	EndIf

	If !Empty(aRet[DEF_FILTRO])
		
		If cProcesso == '000082'
			aRet[DEF_FILTRO] += " .and. "
			aRet[DEF_FILTRO] += cAliasEnt +"->"+cAliasEnt+"_DC !='4' .and. "  //continuacao de historico nao vai para PCO
			aRet[DEF_FILTRO] += cAliasEnt +"->"+cAliasEnt+"_DATA>='"+DTOS(aRet[DEF_DATINI])+"' .and. "
			aRet[DEF_FILTRO] += cAliasEnt +"->"+cAliasEnt+"_DATA<='"+DTOS(aRet[DEF_DATFIN])+"' "
		EndIf
		
		//PARSE DO FILTRO USANDO FUNCAO PCOPARSEFIL
		cFiltro	:=	PcoParseFil( aRet[DEF_FILTRO], cAliasEnt )
			
		If !Empty(cFiltro)
			If __cTmpRec  == NIL  //Cria arquivo temporario que contera os registros processados
				__cTmpRec := A310CrTmp({{"RECORI","N",15,0}}, "RECORI")
			EndIf 
		
			//cria arquivo temporario no banco 
			cQuery 	:= " SELECT COUNT(R_E_C_N_O_) RECTAB "
			cQuery 	+= "  FROM " + RetSQLName(cAliasEnt) + " " + cAliasEnt
			cQuery 	+= "  WHERE " 
			cWhere  :=  cFiltro// Adiciona expressao de filtro convertida para SQL contendo aRet[DEF_FILTRO]
			cWhere 	+= " AND "+cAliasEnt+".D_E_L_E_T_ = ' ' "
			cWhere 	+= " AND "+cAliasEnt+".R_E_C_N_O_ NOT IN ( SELECT RECORI FROM "+__cTmpRec+" ) "
			
			If ExistBlock( "PCOA3104" )
				//P_Eฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//P_Eณ Ponto de entrada utilizado para inclusao de funcoes de usuarios na     ณ
				//P_Eณ preparacao da query para reprocessamento dos Lancamentos               ณ
				//P_Eณ Parametros : cProcesso, cItem, aClone(aRet), cAliasEntid, cQuery       ณ
				//P_Eณ Retorno    : cQuery      expressao da query                            ณ
				//P_Eภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				cWhere := ExecBlock( "PCOA3104", .F., .F.,{cProcesso,cItem,aClone(aRet),cAliasEntid,cWhere})
			EndIf

			If !Empty(cWhere)
				cQuery 	+= cWhere
			Else
				Aviso("Atencao","Expressao de filtro invalida para ser executado por procedure.",{"Cancela"})
				lRet := .F.
			EndIf


			If lRet
				//cQuery 	+= " ORDER BY  " + SqlOrder((cAliasEnt)->(IndexKey()))  //retirado para melhora de performance			
				cQuery 	:= ChangeQuery(cQuery)
				dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "PCOTRB", .T., .T. )
				If PCOTRB->RECTAB == 0
					Aviso("Atencao","Nao existem registros a serem processados.",{"Cancela"})
					PCOTRB->(dbCloseArea())
					lRet := .F.
				Else
					PCOTRB->(dbCloseArea())  //se tiver registros somente fecha a area corrente
				EndIf
			EndIf
			
		Else
		
			Aviso("Atencao","Expressao de filtro invalida para ser executado por procedure.",{"Cancela"})
			lRet := .F.
		
		Endif

		//CRIA PROCEDURE XFILIAL
		If __cProcFil == nil
			__cProcFil := CriaTrab(,.F.)
			lRet :=  lRet .And. CallxFilial( __cProcFil )
		EndIf
		
		//CRIA PROCEDURE SOMA1 E STRZERO
		lRet := lRet .And. A310Tools()
		
		//CRIA PROCEDURE PROXIMO ITEM DO LANวAMENTO
		If __cProcID == nil
			__cProcID := CriaTrab(,.F.)
			lRet :=  lRet .And. A310LoteId()
		EndIf

		If __cProcDel == nil
			__cProcDel := CriaTrab(,.F.)
		EndIf

		//CRIA PROCEDURE DE EXCLUSAO DOS MOVIMENTOS ORCAMENTARIOS NO PERIODO
		lRet := lRet .And. A310ProcDel(__cProcDel, __cProcFil, cFiltQry)
		 
		//CRIA PROCEDURE PAI PARA LACO NA TABELA DE ENTIDADE (ORIGEM)
		lRet := lRet .And. A310Proced(aRet, cProcesso, cItem, cAliasEnt, cWhere, __cProcFil)
		
		If lRet

			If Alltrim(TcGetDB()) == "INFORMIX"  //PROCEDURE DE EXCLUSAO NAO FUNCIONA EM INFORMIX
			
				Processa({|| ProcDel(aRet, cFiltAKD)}, STR0013, STR0014 )	// "Processando lan็amentos" ### "Excluindo lancamentos..."
			
			Else

				//executa a procedure para exclusao dos movimentos orcamentarios
				aResult := TCSPExec( xProcedures(__cProcDel), ;
													 cFilAnt, ;
													 cAliasEnt, ;
													 cProcesso, ;
													 cItem,;
													 Dtos(aRet[DEF_DATINI]), ;
													 Dtos(aRet[DEF_DATFIN]) )
		
				If Empty(aResult) .Or. aResult[1] = "0"
					MsgAlert(tcsqlerror(),"Erro no Reprocessamento de lan็amentos na exclusใo dos movimentos orcamentarios, abandonando processamento. Verifique!")
					lRet := .F.	
				EndIf
			EndIf
		EndIf
		
		If lRet
		
			//laco para processamento dos lancamentos
			While lRet   //processa enquanto todos os registros nใo processados
		
					dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "PCOTRB", .T., .T. )
					If lFirst
						nRegProc := PCOTRB->RECTAB
						lFirst := .F.
					EndIf
					 
					If PCOTRB->RECTAB >  0
						
						//obtem o numero de lote (cria a procedure proximo lote)
						cNumLote := A310LOTAKD()  //verifica o ultimo numero e soma1 depois locka com MayIUseCode
						
						//executa a procedure pai para la็o nos movimentos de origem
						aResult := TCSPExec( xProcedures(__cProcExec), ;
												 cFilAnt, ;
												 cAliasEnt, ;
												 cProcesso, ;
												 cItem, ;
												 cNumLote, ;
												 Dtos(aRet[DEF_DATINI]), ;
												 Dtos(aRet[DEF_DATFIN]), ;
												 nLimTran )
	
						Leave1Code("AKD"+xFilial('AKD')+cNumLote)  //libera chave criada com funcao A310LOTAKD()
						
						If Empty(aResult) .Or. aResult[1] = "0"
							MsgAlert(tcsqlerror(),"Erro no Reprocessamento de lan็amentos. Verifique!")
							lRet := .F.	
							PCOTRB->(dbCloseArea())
							Exit
						EndIf
					Else
						PCOTRB->(dbCloseArea())  //terminou de processar todos os registros da ENTIDADE (CT2)
						Exit
					EndIf
		
					PCOTRB->(dbCloseArea())
			EndDo
		
		EndIf
		
	EndIf
	
	If lRet .And. lAtuSld
	
		lAtSld300 := ( Alltrim(TcGetDB()) == "INFORMIX" .OR. nRegProc < 10000 .OR. ( aRet[DEF_DATFIN]-aRet[DEF_DATINI] ) < 10 )  
	
		If lAtSld300
	  		PCOA300(.T.,{"  "/*cCubIni*/,"ZZ"/*cCubFim*/,aRet[DEF_DATINI],aRet[DEF_DATFIN],1,"  " }) //Atualizar Saldo dos Cubos
	  	Else
	  		PCOA301EXE(,.T.,{"  "/*cCubIni*/,"ZZ"/*cCubFim*/,aRet[DEF_DATINI],aRet[DEF_DATFIN],.F.,"  " }) //Atualizar Saldo dos Cubos
	  	EndIf
	EndIf
EndIf

aProc := {}
aMsg := {}

If __cProcZero != NIL
	aAdd(aProc, __cProcZero)
	aAdd(aMsg, "Erro na exclusao da Procedure: "+__cProcZero+" [Inclui Zeros a Esquerda]. Excluir manualmente no banco." )
EndIf

If __cProcSoma1 != NIL
	aAdd(aProc, __cProcSoma1)
	aAdd(aMsg, "Erro na exclusao da Procedure: "+__cProcSoma1+" [Incrementa 1 na String]. Excluir manualmente no banco." )
EndIf

If __cProcFil != NIL
	aAdd(aProc, __cProcFil)
	aAdd(aMsg, "Erro na exclusao da Procedure: "+__cProcFil+" [xFilial da Entidade]. Excluir manualmente no banco." )
EndIf

If __cProcDel != NIL
	aAdd(aProc, __cProcDel)
	aAdd(aMsg, "Erro na exclusao da Procedure: "+__cProcDel+" [Exclusao de Movimentos]. Excluir manualmente no banco." )
EndIf

If __cProcExec != NIL
	aAdd(aProc, __cProcExec)
	aAdd(aMsg, "Erro na exclusao da Procedure: "+__cProcExec+" [Reprocessamento de Lancamentos]. Excluir manualmente no banco." )
EndIf

If __cProcID != NIL
	aAdd(aProc, __cProcID)
	aAdd(aMsg, "Erro na exclusao da Procedure: "+__cProcID+" [Incrementa Item do Lancamento]. Excluir manualmente no banco." )
EndIf

If __cProcLote != NIL
	aAdd(aProc, __cProcLote)
	aAdd(aMsg, "Erro na exclusao da Procedure: "+__cProcLote+" [Incrementa Lote]. Excluir manualmente no banco." )
EndIf

//se estiver aberto a tabela temporaria fecha para apagar na funcao A310ExcProc
If Select( __cTmpRec ) > 0
	(__cTmpRec)->( dbCloseArea() )
EndIf

A310ExcProc( aProc, aMsg, __cTmpRec )

//apos exclusao das procedures dinamicas e tabela temporaria inicializar as variaveis static
__cTmpRec 		:= NIL  //tabela temporaria contendo recnos ja processados
__cProcZero 	:= NIL  //procedure strzero
__cProcSoma1 	:= NIL  //procedure soma1
__cProcFil   	:= nil  //procedure xfilial
__cProcDel 		:= NIL  //procedure para exclusao dos movimentos or็amentarios no periodo
__cProcExec 	:= NIL  //procedure pai quando processo/item  executado por procedure 
__cProcID 		:= NIL  //procedure para pegar proximo item do lan็amento 
__cProcLote 	:= NIL  //procedure para pegar proximo lote 
__lProcAKDLOTE 	:= NIL  //flag se criou a procedure para pegar proximo lote

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA310Proced บAutor  ณMicrosiga          บ Data ณ  08/09/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCriar procedure principal do reprocessamento de lancamentos บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function A310Proced(aRet, cProcesso, cItem, cAliasEntid, cWhere, cFilProc)
Local lRet := .T.
Local cDeclare := ""
Local cCpoCursor := ""
Local cVarProc := ""
Local cCpos := ""
Local cVar := ""
Local cQuery := ""
Local aCampos
Local nPTratRec := 0
Local cPE3105 := ""

Default cProcesso := AKB->AKB_PROCES
Default cItem := AKB->AKB_ITEM
Default cAliasEntid := AKB_ENTIDA
Default cWhere := ""

dbSelectArea(cAliasEntid)
dbSetOrder(1) 
aCampos := dbStruct()

lRet := ExistBlock("PCOA3105")

If lRet .And. !Empty(cWhere)

	If __cProcExec == nil
		__cProcExec := CriaTrab(,.F.)
	EndIf

	CtbPrepProc( @cDeclare, @cCpoCursor, @cVarProc, @cCpos, @cVar, @aCampos)

	cQuery :="create procedure "+__cProcExec+"_"+cEmpAnt+CRLF
	cQuery +="( "+CRLF
	cQuery +="	@IN_FILIAL      Char("+Alltrim(Str(Len(AKD->AKD_FILIAL)))+"),"+CRLF
	cQuery +="	@IN_ENTIDA      Char("+Alltrim(Str(Len(AKB->AKB_ENTIDA)))+"),"+CRLF
	cQuery +="	@IN_PROCES      Char("+Alltrim(Str(Len(AKB->AKB_PROCES)))+"),"+CRLF
	cQuery +="	@IN_ITEMPR      Char("+Alltrim(Str(Len(AKB->AKB_ITEM)))+"),"+CRLF
	cQuery +="	@IN_NUMLOTE     Char("+Alltrim(Str(Len(AKD->AKD_LOTE)))+"),"+CRLF
	cQuery +="	@IN_DATAINI     Char(8),"+CRLF
	cQuery +="	@IN_DATAFIM     Char(8),"+CRLF
	cQuery +="	@IN_LIMTRAN     integer,"+CRLF
	cQuery+="   @OUT_RESULT Char( 01) OutPut"+CRLF
	cQuery+=")"+CRLF
	cQuery+="as"+CRLF
	cQuery +=""+CRLF
	
	/* ---------------------------------------------------------------------------------------------------------------------
   Versใo          - <v> Protheus 11.8 </v>
   Assinatura      - <a> 001 </a>
   Fonte Microsiga - <s> PCOA310.PRX </s>
   Descricao       - <d> Procedure Principal Reprocessamento de lancamentos para processo/item no periodo </d>
   Funcao do Siga  -     
   -----------------------------------------------------------------------------------------------------------------
   Entrada         -  <ri> @IN_FILIAL	- Filial corrente 
       				   		@IN_ENTIDA  - Entidade (por ex CT2)
       				   		@IN_PROCES  - Processo (por ex 000082 contabilizacao)
       				   		@IN_ITEMPR  - Item do Processo
       				   		@IN_NUMLOTE  - Numero do Lote
         					@IN_DATAINI   - Periodo Inicial
         					@IN_DATAFIM   - Periodo Final
         					@IN_LIMTRAN   - Limite por lote (transacao)	</ri>
   -----------------------------------------------------------------------------------------------------------------
   Saida          -  <ro> @OUT_RESULT    -  </ro>
   -----------------------------------------------------------------------------------------------------------------
   Responsavel    -   <r> Paulo Carnelossi  </r>
   -----------------------------------------------------------------------------------------------------------------
   Data           -  <dt> 22/09/2016 </dt>
   
   1 - Procedure Principal Reprocessamento de lancamentos para processo/item no periodo
      +----chama procedure dinamica xFilial para AKD  (callxfilial)    
      +----chama procedure dinamica xFilial para Entidade (por exemplo CT2 no processo 000082 | callxfilial)
      
      Faz um cursor com select da Entidade de Origem e vai inserindo em arq temp controle dos recnos ja processado e 
      os inserts na AKD sใo efetuados pelo ponto de entrada PCOA3105  

   --------------------------------------------------------------------------------------------------------------------- */
	
	cQuery+="Declare @cAux        Char( 03 )"+CRLF
	cQuery+="Declare @cFil_AKD    Char("+Alltrim(Str(Len(AKD->AKD_FILIAL)))+")"+CRLF
	cQuery+="Declare @cFil_Entid  Char("+Alltrim(Str(Len(AKD->AKD_FILIAL)))+")"+CRLF
	cQuery+="Declare @nLinCount integer"+CRLF
	cQuery+="Declare @cId Char("+Alltrim(Str(Len(AKD->AKD_ID)))+")"+CRLF
	cQuery+="Declare @iRecno integer"+CRLF

	cQuery+=cDeclare+CRLF
	
	// Insere tratamento para xfilial dentro do codigo 
	cQuery +="begin"+CRLF
	   /* --------------------------------------------------------------
	      Recuperando Filiais
	      -------------------------------------------------------------- */
	cQuery +="   select @cAux = 'AKD'"+CRLF
	cQuery +="   EXEC "+cFilProc+"_"+cEmpAnt+" @cAux, @IN_FILIAL, @cFil_AKD OutPut "+CRLF
	
	cQuery +="   select @cAux = @IN_ENTIDA"+CRLF
	cQuery +="   EXEC "+cFilProc+"_"+cEmpAnt+" @cAux, @IN_FILIAL, @cFil_Entid OutPut "+CRLF
	
	cQuery += "select @OUT_RESULT = '0' " + CRLF
	cQuery += "select @nLinCount = 0 " + CRLF
	
	//declaracao do cursor
	cQuery += "Declare cCursor insensitive cursor for" + CRLF
	cQuery += " "+ CRLF
    //select para cursor
	cQuery += "SELECT "+cCpoCursor+ CRLF
	cQuery += " FROM "+RetSqlName(cAliasEntid)+" "+cAliasEntid+" "+CRLF
	cQuery += " WHERE "+ CRLF
	cQuery += cWhere + CRLF
	cQuery += "FOR READ ONLY" + CRLF

	//abre cursor
	cQuery += "Open cCursor "+ CRLF
	cQuery += "    Fetch cCursor into "+ cVarProc+ CRLF
	//laco do cursor
	cQuery += "While (@@FETCH_STATUS = 0)  "+ CRLF
	cQuery += "begin "+ CRLF
	cQuery += "    Select @nLinCount = @nLinCount + 1 "+ CRLF
	cQuery += "    if @nLinCount <= @IN_LIMTRAN begin "+ CRLF
	
	//grava arquivo temporario
	cQuery += "       INSERT INTO "+__cTmpRec+ "( RECORI, R_E_C_N_O_ ) VALUES ( @iRecnoEnt, @iRecnoEnt)"+ CRLF
	
	//ponto de entrada que grava AKD, deve ser usado @iRecno para gravar R_E_C_N_O_	
	//campos estao em variaveis @ + tipo + nome do campo da entidade
	If ExistBlock( "PCOA3105" )
		//P_Eฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//P_Eณ Ponto de entrada utilizado para inclusao de funcoes de usuarios na     ณ
		//P_Eณ preparacao da query para reprocessamento dos Lancamentos               ณ
		//P_Eณ Parametros : cProcesso, cItem, aClone(aRet), cAliasEntid, cQuery       ณ
		//P_Eณ Retorno    : cQuery      expressao da query                            ณ
		//P_Eภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cPE3105 := ExecBlock( "PCOA3105", .F., .F.,{cProcesso,cItem,aClone(aRet),cAliasEntid,__cProcId})
	EndIf
//-------------------------------------------------------------------------------------------------------------------------------//
//INICIO exemplo de ponto de entrada PCOA3105  NAO RETIRAR DO FONTE
//-------------------------------------------------------------------------------------------------------------------------------//
	//Local cCposAKD
	//Local cVarsAKD
	//cPE3105 :=""
	//cPE3105 +="   select @cId = '    '"+CRLF
	
	//cPE3105 +="   if @IN_PROCES = '000082' begin "+CRLF

	//cPE3105 +="       EXEC "+__cProcID+"_"+cEmpAnt+" @IN_NUMLOTE, @cId, @cId OutPut "+CRLF

	//cCposAKD := "AKD_FILIAL,AKD_STATUS,AKD_LOTE,AKD_ID,AKD_DATA,AKD_CO,AKD_CLASSE,AKD_OPER,AKD_TIPO,AKD_TPSALD,AKD_HIST,AKD_IDREF,AKD_PROCES,AKD_CHAVE,AKD_ITEM,AKD_SEQ,AKD_USER,AKD_COSUP,AKD_VALOR1,AKD_VALOR2,AKD_VALOR3,AKD_VALOR4,AKD_VALOR5,AKD_CODPLA,AKD_VERSAO,AKD_CC,AKD_ITCTB,AKD_CLVLR,AKD_LCTBLQ,AKD_UNIORC,AKD_FILORI,D_E_L_E_T_,R_E_C_N_O_,R_E_C_D_E_L_"
	//variaveis debito
	//cVarsAKD := "@cFil_AKD,'1'        ,@IN_NUMLOTE,@cId,@cCT2_DATA,@cCT2_DEBITO,'000001','','2','RE','CONTABILIDADE DEBITO PARA AKD',''  ,@IN_PROCES,@cCT2_FILIAL+@cCT2_DATA+@cCT2_LOTE+@cCT2_SBLOTE+@cCT2_DOC+@cCT2_LINHA+@cCT2_TPSALD+@cCT2_EMPORI+@cCT2_FILORI+@cCT2_MOEDLC,@IN_ITEMPR,'01','"+__cUserId+"','',@nCT2_VALOR,0,0,0,0,'','',@cCT2_CCD,@cCT2_ITEMD,@cCT2_CLVLDB,' ',' ','"+cFilAnt+"',' ',@iRecno,0"
	
	//cPE3105 +="   		if @cCT2_DC = '3' OR @cCT2_DC = '1' begin "+CRLF

	//cPE3105 += "      ##TRATARECNO @iRecno\ "+ CRLF
	//cPE3105 += "      begin tran"+CRLF
	
	//cPE3105 += "      INSERT INTO "+RetSqlName("AKD") +" ("+cCposAKD+")"+ CRLF 
	//cPE3105 += "                                  VALUES ("+cVarsAKD+")" + CRLF
	//cPE3105 += "      commit tran"+CRLF
	//cPE3105 += "       ##FIMTRATARECNO "+ CRLF
	//cPE3105 += "       end   "+ CRLF //finaliza if @cCT2_DC

	//cPE3105 +="   		if @cCT2_DC = '3' OR @cCT2_DC = '2' begin "+CRLF
	
	//variaveis credito
	//cVarsAKD := "@cFil_AKD,'1'        ,@IN_NUMLOTE,@cId,@cCT2_DATA,@cCT2_CREDIT,'000001','','1','RE','CONTABILIDADE CREDITO PARA AKD',''  ,@IN_PROCES,@cCT2_FILIAL+@cCT2_DATA+@cCT2_LOTE+@cCT2_SBLOTE+@cCT2_DOC+@cCT2_LINHA+@cCT2_TPSALD+@cCT2_EMPORI+@cCT2_FILORI+@cCT2_MOEDLC,@IN_ITEMPR,'01','"+__cUserId+"','',@nCT2_VALOR,0,0,0,0,'','',@cCT2_CCC,@cCT2_ITEMC,@cCT2_CLVLCR,' ',' ','"+cFilAnt+"',' ',@iRecno,0"

	//cPE3105 += "      ##TRATARECNO @iRecno\ "+ CRLF
	//cPE3105 += "      begin tran"+CRLF
	
	//cPE3105 += "      INSERT INTO "+RetSqlName("AKD") +" ("+cCposAKD+")"+ CRLF 
	//cPE3105 += "                                  VALUES ("+cVarsAKD+")" + CRLF
	//cPE3105 += "      commit tran"+CRLF
	//cPE3105 += "       ##FIMTRATARECNO "+ CRLF
	

	//cPE3105 += "       end "+ CRLF   ///finaliza if @cCT2_DC 
	//cPE3105 += "  end"+ CRLF   ///finaliza if @IN_PROCES = '000082' 
//-------------------------------------------------------------------------------------------------------------------------------//
//TERMINO exemplo de ponto de entrada PCOA3105  NAO RETIRAR DO FONTE
//-------------------------------------------------------------------------------------------------------------------------------//
	If Empty(cPE3105)
		Alert("Erro no ponto de entrada de inclusao do lan็amento na tabela de Movimentos (AKD)")
		Return(.F.)	
	Else
		cQuery += cPE3105+ CRLF
	EndIf
	cQuery += "  end "+ CRLF   //finaliza o if @nLinCount <= @IN_LIMTRAN begin "+ CRLF
	
	If Trim(TcGetDb()) = 'DB2'  //em DB2 tem que forcar para colocar esta linha antes do fetch
	     cQuery += ' SELECT @fim_CUR = 0'+ CRLF
	EndIf

	//fetch
	cQuery += "       Fetch cCursor into "+ cVarProc+ CRLF
	//final do while
	cQuery += " "+ CRLF
	cQuery += "   end "+ CRLF   //final do while -- cursor
	
	cQuery +="   Close cCursor "+CRLF
	cQuery +="   deallocate cCursor "+CRLF
	
	cQuery += "   select @OUT_RESULT = '1' " + CRLF
	
	cQuery += " "+ CRLF
	cQuery += "   end "+ CRLF
	
	cQuery := CtbAjustaP(.T., cQuery, @nPTratRec)
	cQuery := MsParse( cQuery, If( Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB()) ) )
	cQuery := CtbAjustaP(.F., cQuery, nPTratRec)

	If Empty( cQuery )
		MsgAlert("Procedure [ Processamento de Lan็amento ] nao passou pelo Parse. "+__cProcExec+CRLF+MsParseError(),"Erro") 
		lRet := .F.
	Else
		If !TCSPExist( __cProcExec+"_"+cEmpAnt )
			cRet := TcSqlExec(cQuery)
			If cRet <> 0
				If !__lBlind
					MsgAlert("Erro na criacao da procedure [ Processamento de Lan็amento ] : "+__cProcExec,"Erro")  
					lRet:= .F.
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

Return(lRet)

/* script da procedure em sql server - procedure principal
-- Procedure creation 
CREATE PROCEDURE [dbo].[SC025550_T1] (
    @IN_FILIAL Char( 8 ) , 
    @IN_ENTIDA Char( 3 ) , 
    @IN_PROCES Char( 6 ) , 
    @IN_ITEMPR Char( 2 ) , 
    @IN_NUMLOTE Char( 10 ) , 
    @IN_DATAINI Char( 8 ) , 
    @IN_DATAFIM Char( 8 ) , 
    @IN_LIMTRAN Integer , 
    @OUT_RESULT Char( 01 )  output ) AS
 
-- Declaration of variables
DECLARE @cAux Char( 03 )
DECLARE @cFil_AKD Char( 8 )
DECLARE @cFil_Entid Char( 8 )
DECLARE @nLinCount Integer
DECLARE @cId Char( 4 )
DECLARE @iRecno Integer
DECLARE @cCT2_FILIAL Char( 8 )
DECLARE @cCT2_DATA Char( 8 )
DECLARE @cCT2_LOTE Char( 6 )
DECLARE @cCT2_SBLOTE Char( 3 )
DECLARE @cCT2_DOC Char( 6 )
DECLARE @cCT2_LINHA Char( 3 )
DECLARE @cCT2_MOEDLC Char( 2 )
DECLARE @cCT2_DC Char( 1 )
DECLARE @cCT2_DEBITO Char( 20 )
DECLARE @cCT2_CREDIT Char( 20 )
DECLARE @cCT2_DCD Char( 1 )
DECLARE @cCT2_DCC Char( 1 )
DECLARE @nCT2_VALOR Float
DECLARE @cCT2_MOEDAS Char( 5 )
DECLARE @cCT2_HP Char( 3 )
DECLARE @cCT2_HIST Char( 40 )
DECLARE @cCT2_CCD Char( 9 )
DECLARE @cCT2_CCC Char( 9 )
DECLARE @cCT2_ITEMD Char( 9 )
DECLARE @cCT2_ITEMC Char( 9 )
DECLARE @cCT2_CLVLDB Char( 9 )
DECLARE @cCT2_CLVLCR Char( 9 )
DECLARE @cCT2_ATIVDE Char( 40 )
DECLARE @cCT2_ATIVCR Char( 40 )
DECLARE @cCT2_EMPORI Char( 2 )
DECLARE @cCT2_FILORI Char( 8 )
DECLARE @cCT2_INTERC Char( 1 )
DECLARE @cCT2_IDENTC Char( 50 )
DECLARE @cCT2_TPSALD Char( 1 )
DECLARE @cCT2_SEQUEN Char( 10 )
DECLARE @cCT2_MANUAL Char( 1 )
DECLARE @cCT2_ORIGEM Char( 100 )
DECLARE @cCT2_ROTINA Char( 10 )
DECLARE @cCT2_AGLUT Char( 1 )
DECLARE @cCT2_LP Char( 3 )
DECLARE @cCT2_SEQHIS Char( 3 )
DECLARE @cCT2_SEQLAN Char( 3 )
DECLARE @cCT2_DTVENC Char( 8 )
DECLARE @cCT2_SLBASE Char( 1 )
DECLARE @cCT2_DTLP Char( 8 )
DECLARE @cCT2_DATATX Char( 8 )
DECLARE @nCT2_TAXA Float
DECLARE @nCT2_VLR01 Float
DECLARE @nCT2_VLR02 Float
DECLARE @nCT2_VLR03 Float
DECLARE @nCT2_VLR04 Float
DECLARE @nCT2_VLR05 Float
DECLARE @cCT2_CRCONV Char( 1 )
DECLARE @cCT2_CRITER Char( 4 )
DECLARE @cCT2_KEY Char( 200 )
DECLARE @cCT2_SEGOFI Char( 10 )
DECLARE @cCT2_DTCV3 Char( 8 )
DECLARE @cCT2_SEQIDX Char( 5 )
DECLARE @cCT2_CONFST Char( 1 )
DECLARE @cCT2_OBSCNF Char( 40 )
DECLARE @cCT2_USRCNF Char( 15 )
DECLARE @cCT2_DTCONF Char( 8 )
DECLARE @cCT2_HRCONF Char( 10 )
DECLARE @cCT2_MLTSLD Char( 20 )
DECLARE @cCT2_CTLSLD Char( 1 )
DECLARE @cCT2_CODPAR Char( 6 )
DECLARE @cCT2_NODIA Char( 10 )
DECLARE @cCT2_DIACTB Char( 2 )
DECLARE @cCT2_MOEFDB Char( 2 )
DECLARE @cCT2_MOEFCR Char( 2 )
DECLARE @cCT2_AT01DB Char( 20 )
DECLARE @cCT2_AT01CR Char( 20 )
DECLARE @cCT2_AT02DB Char( 20 )
DECLARE @cCT2_AT02CR Char( 20 )
DECLARE @cCT2_AT03DB Char( 20 )
DECLARE @cCT2_AT03CR Char( 20 )
DECLARE @cCT2_AT04DB Char( 20 )
DECLARE @cCT2_AT04CR Char( 20 )
DECLARE @cCT2_CTRLSD Char( 1 )
DECLARE @iRecnoEnt Integer
DECLARE @iLoop Integer
DECLARE @ins_error Integer
DECLARE @ins_ini Integer
DECLARE @ins_fim Integer
DECLARE @icoderror Integer
BEGIN
   SET @cAux  = 'AKD' 
   EXEC SC025500_T1 @cAux , @IN_FILIAL , @cFil_AKD output 
   SET @cAux  = @IN_ENTIDA 
   EXEC SC025500_T1 @cAux , @IN_FILIAL , @cFil_Entid output 
   SET @OUT_RESULT  = '0' 
   SET @nLinCount  = 0 
    
   -- Cursor declaration cCursor
   DECLARE cCursor insensitive  CURSOR FOR 
   SELECT CT2_FILIAL , CT2_DATA , CT2_LOTE , CT2_SBLOTE , CT2_DOC , CT2_LINHA , CT2_MOEDLC , CT2_DC , CT2_DEBITO , CT2_CREDIT , 
          CT2_DCD , CT2_DCC , CT2_VALOR , CT2_MOEDAS , CT2_HP , CT2_HIST , CT2_CCD , CT2_CCC , CT2_ITEMD , CT2_ITEMC , CT2_CLVLDB , 
          CT2_CLVLCR , CT2_ATIVDE , CT2_ATIVCR , CT2_EMPORI , CT2_FILORI , CT2_INTERC , CT2_IDENTC , CT2_TPSALD , CT2_SEQUEN , 
          CT2_MANUAL , CT2_ORIGEM , CT2_ROTINA , CT2_AGLUT , CT2_LP , CT2_SEQHIS , CT2_SEQLAN , CT2_DTVENC , CT2_SLBASE , 
          CT2_DTLP , CT2_DATATX , CT2_TAXA , CT2_VLR01 , CT2_VLR02 , CT2_VLR03 , CT2_VLR04 , CT2_VLR05 , CT2_CRCONV , CT2_CRITER , 
          CT2_KEY , CT2_SEGOFI , CT2_DTCV3 , CT2_SEQIDX , CT2_CONFST , CT2_OBSCNF , CT2_USRCNF , CT2_DTCONF , CT2_HRCONF , 
          CT2_MLTSLD , CT2_CTLSLD , CT2_CODPAR , CT2_NODIA , CT2_DIACTB , CT2_MOEFDB , CT2_MOEFCR , CT2_AT01DB , CT2_AT01CR , 
          CT2_AT02DB , CT2_AT02CR , CT2_AT03DB , CT2_AT03CR , CT2_AT04DB , CT2_AT04CR , CT2_CTRLSD , R_E_C_N_O_ 
     FROM CT2T10 CT2
     WHERE CT2.CT2_FILIAL  = 'D MG 01 '  and CT2.CT2_DC  <> '4'  and CT2.CT2_DATA  >= '20160101'  and CT2.CT2_DATA  <= '20161231' 
      and CT2.D_E_L_E_T_  = ' '  and CT2.R_E_C_N_O_ NOT IN (
   SELECT RECORI 
     FROM SC025490 ) 
   FOR READ ONLY 
    
   OPEN cCursor
   FETCH cCursor 
    INTO @cCT2_FILIAL , @cCT2_DATA , @cCT2_LOTE , @cCT2_SBLOTE , @cCT2_DOC , @cCT2_LINHA , @cCT2_MOEDLC , @cCT2_DC , @cCT2_DEBITO , 
          @cCT2_CREDIT , @cCT2_DCD , @cCT2_DCC , @nCT2_VALOR , @cCT2_MOEDAS , @cCT2_HP , @cCT2_HIST , @cCT2_CCD , @cCT2_CCC , 
          @cCT2_ITEMD , @cCT2_ITEMC , @cCT2_CLVLDB , @cCT2_CLVLCR , @cCT2_ATIVDE , @cCT2_ATIVCR , @cCT2_EMPORI , @cCT2_FILORI , 
          @cCT2_INTERC , @cCT2_IDENTC , @cCT2_TPSALD , @cCT2_SEQUEN , @cCT2_MANUAL , @cCT2_ORIGEM , @cCT2_ROTINA , @cCT2_AGLUT , 
          @cCT2_LP , @cCT2_SEQHIS , @cCT2_SEQLAN , @cCT2_DTVENC , @cCT2_SLBASE , @cCT2_DTLP , @cCT2_DATATX , @nCT2_TAXA , 
          @nCT2_VLR01 , @nCT2_VLR02 , @nCT2_VLR03 , @nCT2_VLR04 , @nCT2_VLR05 , @cCT2_CRCONV , @cCT2_CRITER , @cCT2_KEY , 
          @cCT2_SEGOFI , @cCT2_DTCV3 , @cCT2_SEQIDX , @cCT2_CONFST , @cCT2_OBSCNF , @cCT2_USRCNF , @cCT2_DTCONF , @cCT2_HRCONF , 
          @cCT2_MLTSLD , @cCT2_CTLSLD , @cCT2_CODPAR , @cCT2_NODIA , @cCT2_DIACTB , @cCT2_MOEFDB , @cCT2_MOEFCR , @cCT2_AT01DB , 
          @cCT2_AT01CR , @cCT2_AT02DB , @cCT2_AT02CR , @cCT2_AT03DB , @cCT2_AT03CR , @cCT2_AT04DB , @cCT2_AT04CR , @cCT2_CTRLSD , 
          @iRecnoEnt 
   WHILE ( (@@FETCH_STATUS  = 0 ) )
   BEGIN
      SET @nLinCount  = @nLinCount  + 1 
      IF @nLinCount  <= @IN_LIMTRAN 
      BEGIN 
         INSERT INTO SC025490 (RECORI , R_E_C_N_O_ ) 
         VALUES (@iRecnoEnt , @iRecnoEnt );
         SET @cId  = '    ' 
         IF @IN_PROCES  = '000082' 
         BEGIN 
            IF @cCT2_DC  = '3'  or @cCT2_DC  = '1' 
            BEGIN 
               SELECT @iRecno  = ISNULL ( MAX ( R_E_C_N_O_ ), 0 )
                 FROM AKDT10 
               SET @iRecno  = @iRecno  + 1 
               EXEC SC025530_T1 @IN_NUMLOTE , @cId , @cId output 
               select @iLoop = 0 
While @iLoop = 0 begin 
 Begin tran
  BEGIN TRY 
                
               INSERT INTO AKDT10 (AKD_FILIAL , AKD_STATUS , AKD_LOTE , AKD_ID , AKD_DATA , AKD_CO , AKD_CLASSE , AKD_OPER , 
                      AKD_TIPO , AKD_TPSALD , AKD_HIST , AKD_IDREF , AKD_PROCES , AKD_CHAVE , AKD_ITEM , AKD_SEQ , AKD_USER , 
                      AKD_COSUP , AKD_VALOR1 , AKD_VALOR2 , AKD_VALOR3 , AKD_VALOR4 , AKD_VALOR5 , AKD_CODPLA , AKD_VERSAO , 
                      AKD_CC , AKD_ITCTB , AKD_CLVLR , AKD_LCTBLQ , AKD_UNIORC , AKD_FILORI , D_E_L_E_T_ , R_E_C_N_O_ , R_E_C_D_E_L_ ) 
               VALUES (@cFil_AKD , '1' , @IN_NUMLOTE , @cId , @cCT2_DATA , RTRIM ( @cCT2_DEBITO ), '000001' , ' ' , '2' , 
                      'RE' , 'CONTABILIDADE DEBITO PARA AKD' , ' ' , @IN_PROCES , @cCT2_FILIAL  + @cCT2_DATA  + @cCT2_LOTE  + @cCT2_SBLOTE  + @cCT2_DOC  + @cCT2_LINHA  + @cCT2_TPSALD  + @cCT2_EMPORI  + @cCT2_FILORI  + @cCT2_MOEDLC 
                 , @IN_ITEMPR , '01' , '000000' , ' ' , @nCT2_VALOR , 0 , 0 , 0 , 0 , ' ' , ' ' , @cCT2_CCD , @cCT2_ITEMD , 
                      @cCT2_CLVLDB , ' ' , ' ' , 'D MG 01 ' , ' ' , @iRecno , 0 );
                
               
    select @iLoop = 1 
  END TRY 
  BEGIN CATCH 
    select @ins_error = @@ERROR
    If @ins_error = 2627 
      begin
        select @iRecno = @iRecno + 1 
    End 
    If ( @ins_error <> 2627 )
    begin
       select @iLoop = 1
    End
  END CATCH
  commit Tran
End 
 
            END 
            IF @cCT2_DC  = '3'  or @cCT2_DC  = '2' 
            BEGIN 
               IF @cCT2_DC  = '3' 
               BEGIN 
                  SET @nLinCount  = @nLinCount  + 1 
               END 
               SELECT @iRecno  = ISNULL ( MAX ( R_E_C_N_O_ ), 0 )
                 FROM AKDT10 
               SET @iRecno  = @iRecno  + 1 
               EXEC SC025530_T1 @IN_NUMLOTE , @cId , @cId output 
               select @iLoop = 0 
While @iLoop = 0 begin 
 Begin tran
  BEGIN TRY 
                
               INSERT INTO AKDT10 (AKD_FILIAL , AKD_STATUS , AKD_LOTE , AKD_ID , AKD_DATA , AKD_CO , AKD_CLASSE , AKD_OPER , 
                      AKD_TIPO , AKD_TPSALD , AKD_HIST , AKD_IDREF , AKD_PROCES , AKD_CHAVE , AKD_ITEM , AKD_SEQ , AKD_USER , 
                      AKD_COSUP , AKD_VALOR1 , AKD_VALOR2 , AKD_VALOR3 , AKD_VALOR4 , AKD_VALOR5 , AKD_CODPLA , AKD_VERSAO , 
                      AKD_CC , AKD_ITCTB , AKD_CLVLR , AKD_LCTBLQ , AKD_UNIORC , AKD_FILORI , D_E_L_E_T_ , R_E_C_N_O_ , R_E_C_D_E_L_ ) 
               VALUES (@cFil_AKD , '1' , @IN_NUMLOTE , @cId , @cCT2_DATA , RTRIM ( @cCT2_CREDIT ), '000001' , ' ' , '1' , 
                      'RE' , 'CONTABILIDADE CREDITO PARA AKD' , ' ' , @IN_PROCES , @cCT2_FILIAL  + @cCT2_DATA  + @cCT2_LOTE  + @cCT2_SBLOTE  + @cCT2_DOC  + @cCT2_LINHA  + @cCT2_TPSALD  + @cCT2_EMPORI  + @cCT2_FILORI  + @cCT2_MOEDLC 
                 , @IN_ITEMPR , '01' , '000000' , ' ' , @nCT2_VALOR , 0 , 0 , 0 , 0 , ' ' , ' ' , @cCT2_CCC , @cCT2_ITEMC , 
                      @cCT2_CLVLCR , ' ' , ' ' , 'D MG 01 ' , ' ' , @iRecno , 0 );
                
               
    select @iLoop = 1 
  END TRY 
  BEGIN CATCH 
    select @ins_error = @@ERROR
    If @ins_error = 2627 
      begin
        select @iRecno = @iRecno + 1 
    End 
    If ( @ins_error <> 2627 )
    begin
       select @iLoop = 1
    End
  END CATCH
  commit Tran
End 
 
            END 
         END 
      END 
      FETCH cCursor 
       INTO @cCT2_FILIAL , @cCT2_DATA , @cCT2_LOTE , @cCT2_SBLOTE , @cCT2_DOC , @cCT2_LINHA , @cCT2_MOEDLC , @cCT2_DC , @cCT2_DEBITO , 
             @cCT2_CREDIT , @cCT2_DCD , @cCT2_DCC , @nCT2_VALOR , @cCT2_MOEDAS , @cCT2_HP , @cCT2_HIST , @cCT2_CCD , @cCT2_CCC , 
             @cCT2_ITEMD , @cCT2_ITEMC , @cCT2_CLVLDB , @cCT2_CLVLCR , @cCT2_ATIVDE , @cCT2_ATIVCR , @cCT2_EMPORI , @cCT2_FILORI , 
             @cCT2_INTERC , @cCT2_IDENTC , @cCT2_TPSALD , @cCT2_SEQUEN , @cCT2_MANUAL , @cCT2_ORIGEM , @cCT2_ROTINA , @cCT2_AGLUT , 
             @cCT2_LP , @cCT2_SEQHIS , @cCT2_SEQLAN , @cCT2_DTVENC , @cCT2_SLBASE , @cCT2_DTLP , @cCT2_DATATX , @nCT2_TAXA , 
             @nCT2_VLR01 , @nCT2_VLR02 , @nCT2_VLR03 , @nCT2_VLR04 , @nCT2_VLR05 , @cCT2_CRCONV , @cCT2_CRITER , @cCT2_KEY , 
             @cCT2_SEGOFI , @cCT2_DTCV3 , @cCT2_SEQIDX , @cCT2_CONFST , @cCT2_OBSCNF , @cCT2_USRCNF , @cCT2_DTCONF , @cCT2_HRCONF , 
             @cCT2_MLTSLD , @cCT2_CTLSLD , @cCT2_CODPAR , @cCT2_NODIA , @cCT2_DIACTB , @cCT2_MOEFDB , @cCT2_MOEFCR , @cCT2_AT01DB , 
             @cCT2_AT01CR , @cCT2_AT02DB , @cCT2_AT02CR , @cCT2_AT03DB , @cCT2_AT03CR , @cCT2_AT04DB , @cCT2_AT04CR , @cCT2_CTRLSD , 
             @iRecnoEnt 
   END 
   CLOSE cCursor
   DEALLOCATE cCursor
   SET @OUT_RESULT  = '1' 
END
*/


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA310CrTmp  บAutor  ณMicrosiga          บ Data ณ  08/09/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCriar arquivo temporario no banco conforme estrutura informaบฑฑ
ฑฑบ          ณda                                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function A310CrTmp(aStruct, cIndice)

Default aStruct := dbStruct()
Default cIndice := IndexKey()

// Cria a tabela temporia direto no banco de dados	                					
cArquivoTmp := CriaTrab( , .F.)
MsErase(cArquivoTmp)

MsCreate(cArquivoTmp,aStruct, "TOPCONN")
Sleep(1000)

dbUseArea(.T., "TOPCONN",cArquivoTmp,cArquivoTmp/*cAlias*/,.F.,.F.)

If !Empty(cIndice)
	// Cria o indice temporario
	TcSqlExec("Create index "+Substr(cArquivoTmp,1,7)+"A on " + cArquivoTmp+"( " + StrTran(cIndice, "+", ",") + " ) ")
EndIf

(cArquivoTmp)->( dbCloseArea() )

Return(cArquivoTmp)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbPrepProcบAutor  ณMicrosiga          บ Data ณ  08/09/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPrepara as variaveis para cursor a ser utilizado na         บฑฑ
ฑฑบ          ณprocedure                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function CtbPrepProc( cDeclare, cCpoCursor, cVarProc, cCpos, cVar, aCampos)
Local nX
Local nLenCpos

DEFAULT cDeclare := ""
DEFAULT cCpoCursor := ""
DEFAULT cVarProc := ""
DEFAULT cCpos := ""
DEFAULT cVar := ""
DEFAULT aCampos := dbStruct()

nLenCpos := Len(aCampos)

For nX := 1 To nLenCpos  //todos os campos contidos no array static aCampos

	cDeclare+= "Declare "  //declaracao das variaveis a ser utilizada no curosr

	If 	aCampos[nX][2] == "C"
		cVarProc 	+= " @c"
		cDeclare 	+= " @c"+aCampos[nX][1]+" char(" + Alltrim(STR(aCampos[nX][3])) + ")" + CRLF
	Elseif 	aCampos[nX][2] == "N"
		cVarProc 	+= " @n"
		cDeclare	+= " @n"+aCampos[nX][1]+" float" + CRLF
	Elseif 	aCampos[nX][2] == "D"
		cVarProc 	+= " @c"
		cDeclare 	+= " @c"+aCampos[nX][1]+" char(8)" + CRLF
	Else // logico "L"
		cVarProc 	+= " @l"
		cDeclare 	+= " @l"+aCampos[nX][1]+" char(1)" + CRLF
	Endif
	
	cVarTipo := Right(cVarProc, 2)
	
	cCpoCursor	+= aCampos[nX][1]+", "  //campos do cursor
	cVarProc 	+= aCampos[nX][1]+", "  //variaveis do cursor mesmo nome do campo com @tipvar

	cCpos 	+= aCampos[nX][1]+", "
	cVar	+= cVarTipo+aCampos[nX][1]+","

Next nX

cDeclare += " Declare @iRecnoEnt integer "

cCpoCursor += " R_E_C_N_O_ "
cVarProc 	+= " @iRecnoEnt "

cVar	+= " @iRecnoEnt "
cCpos 	+= " R_E_C_N_O_ "

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA310ExcProcบAutor  ณMicrosiga          บ Data ณ  08/09/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExcluir as procedures dinamicas criadas no banco para       บฑฑ
ฑฑบ          ณreprocessamento                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function A310ExcProc( aProc, aMsg, cArqTemp, cMsgTemp )
Local iX
Local cRet
Local cExec
Local cMsgProc

Default aProc := {}
Default aMsg := {}
Default cArqTemp := NIL
Default cMsgTemp := "Erro na exclusao da Tabela: "+cArqTemp+" utilizada no reprocessamento de lancamentos. Excluir manualmente"

cMsgProc := "Erro na exclusao da Procedure: ###. Excluir manualmente no banco."

For ix := 1 to Len(aProc)    

	If TCSPExist(aProc[iX]+"_"+cEmpAnt)
		cExec := "Drop procedure "+aProc[iX]+"_"+cEmpAnt
		cRet := TcSqlExec(cExec)
		If cRet <> 0
			If iX <= Len(aMsg)
				MsgAlert( aMsg[iX] )
			Else
				MsgAlert( StrTran(cMsgProc, "###", aProc[iX] ) )
			EndIf
		Endif
		Sleep(10)
	EndIf

Next iX

If cArqTemp != NIL .And. TcCanOpen(cArqTemp)   // exclusao de cArqTemp 
	If !TcDelFile(cArqTemp)
		MsgAlert(cMsgTemp)
	Endif
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}TotLanc()
Retorna quantidade de lan็amentos
@author Andr้ Brito
@since  14/03/2018
@version 12
/*/
//-------------------------------------------------------------------

Static Function TotLanc(aRet, cFilialDe, cFilialAte)

Local cAliasEnt	:= GetEntFilt(AKB->AKB_PROCESS,AKB->AKB_ITEM)
Local cTbField 	:= If(SubStr(cAliasEnt,1,1)== "S",SubStr(cAliasEnt,2),cAliasEnt)
Local cQuery	:= ""
Local cFiltro	:=	PcoParseFil(aRet[DEF_FILTRO],GetEntFilt(AKB->AKB_PROCESS,AKB->AKB_ITEM))	
Local nTotal    := 0

Default aRet    := {}

cQuery := " SELECT COUNT(*) AS TOT, MIN(R_E_C_N_O_) AS MIN, MAX(R_E_C_N_O_) AS MAX FROM " + RetSqlName(cAliasEnt) +  " " + cAliasEnt + " "
cQuery += " WHERE D_E_L_E_T_='' AND "
If xFilial(cAliasEnt, cFilialDe) == xFilial(cAliasEnt, cFilialAte) 
	cQuery +=  cTbField + "_FILIAL='" + xFilial(cAliasEnt, cFilialDe) 
Else
	cQuery +=  cTbField + "_FILIAL>='" + xFilial(cAliasEnt,cFilialDe) + "' AND " + cTbField + "_FILIAL<='" + xFilial(cAliasEnt,cFilialAte)
EndIf
cQuery +=  If(Empty(cFiltro),"'","' AND (" + cFiltro + ")")
cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),"TRBTOT",.T.,.T.)

nTotal	:= TRBTOT->TOT

TRBTOT->(DbCLoseArea())

Return nTotal
