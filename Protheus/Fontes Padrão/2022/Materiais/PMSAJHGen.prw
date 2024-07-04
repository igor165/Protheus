#include "protheus.ch"
#include "pmsicons.ch"
#include "tbiconn.ch"

/*
	PmsGetAJH()

	Devolve as informações necessárias para o Painel de Controle
	offilne a partir do projeto especificado pelo código cProject.

	As informações que serão devolvidas são as operações
	realizadas na data dDate.
*/
Function PmsGetAJH(cProject, dDate)
	Local aArea := GetArea()
	Local aAreaAF9 := AF9->(GetArea())
	Local aAreaAF8 := AF8->(GetArea())

	Local aTaskInfo := {}
	Local aTaskInfoSet := {}
	
	Local dRefDate := dDataBase
	
	Local cRevision := PmsAF8Ver(cProject)
	
	Local aProjectCOTE := {}
	Local nCOTE := 0

	Local aProjectCRTE := {}	
	Local nCRTE := 0
	
	Local aProjectCOTP := {}
	Local nCOTP := 0
	
	Local aProjectCPT := {}
	Local nCPT := 0

	Local nVC  := 0
	Local nIDC := 0
	Local nECT := 0
	Local nVP  := 0
	Local nIDP := 0
	Local dDET := 0
	
	/*
	
	  Campos necessários para o painel:

		AJH_FILIAL - Filial - C-2-0
		AJH_PROJET - Projeto - C-10-0
		AJH_TAREFA - Tarefa - C-12-0
		AJH_REVISA - Revisão - C-4-0
		AJH_DATA   - Data de Referência - D-8-0
	  
	  AJH_CPT    - Custo Previsto no Término - N-14-2
	  AJH_COTP   - COTP - N-14-2
	  AJH_COTE   - COTE - N-14-2
	  AJH_CRTE   - CRTE - N-14-2
	  AJH_VC     - VC - Variação nos Custos - N-6-2
	  AJH_IDC    - IDC - Índice de Desempenho de Custos - N-6-2
	  AJH_ECT    - ECT - Estimativa de Custo no Término - N-14-2
	  AJH_VP     - VP - Variação nos Prazos - N-6-2
	  AJH_IDP    - IDP - Índice de Desempenho de Prazo - N-6-2
	  AJH_DET    - DET - Data Estimada para Término - D-8-0

		Tabela: AJH

	*/

	// Project
	dbSelectArea("AF8")
	AF8->(dbSetOrder(1)) // AF8_FILIAL + AF8_PROJET
	AF8->(MsSeek(xFilial("AF8") + cProject))

	// Task	
	dbSelectArea("AF9")
	AF9->(dbSetOrder(1)) // AF9_FILIAL+AF9_PROJET+AF9_REVISA+AF9_TAREFA+AF9_ORDEM
	
	AF9->(MsSeek(xFilial("AF9") + cProject + cRevision))
	
	While !AF9->(Eof()) .And. AF9->AF9_FILIAL == xFilial("AF9") .And. ;
	                          AF9->AF9_PROJET == cProject .And. ;
	                          AF9->AF9_REVISA == cRevision

		aTaskInfo := {}
		
		/*

			aTaskInfo - layout:
			
			[01] - Filial
			[02] - Código do Projeto
			[03] - Código da Tarefa
			[04] - Revisão
			[05] - Data de Referência

			[06] - COTE
			[07] - CRTE
			[08] - COTP
			[09] - CTP
			[10] - VC
			[11] - IDC
		  [12] - ECT
		  [13] - VP
		  [14] - IDP
		  [15] - DET
		
		*/
		
		Aadd(aTaskInfo, AF9->AF9_FILIAL)  // Filial
		Aadd(aTaskInfo, AF9->AF9_PROJET)  // Projeto
		Aadd(aTaskInfo, AF9->AF9_TAREFA)  // Tarefa
		Aadd(aTaskInfo, AF9->AF9_REVISA)  // Revisão
		Aadd(aTaskInfo, dDate)            // Data de Referência
				
		// 1. recupera o valor de COTE
		aProjectCOTE := PmsIniCOTE(AF9->AF9_PROJET, AF9->AF9_REVISA, ;
		                           dRefDate, AF9->AF9_TAREFA, AF9->AF9_TAREFA)
		nCOTE := PmsRetCOTE(aProjectCOTE, PMS_TASK, AF9->AF9_TAREFA, .T.)[1]		
		Aadd(aTaskInfo, nCOTE)
				
		// 2. recupera o valor de CRTE
		aProjectCRTE := PmsIniCRTE(AF9->AF9_PROJET, AF9->AF9_REVISA, ;
		                           dRefDate, AF9->AF9_TAREFA, AF9->AF9_TAREFA)
		nCRTE := PmsRetCRTE(aProjectCRTE, PMS_TASK, AF9->AF9_TAREFA, .T.)[1]
		Aadd(aTaskInfo, nCRTE)
		
		// 3. recupera o valor de COTP		
		aProjectCOTP := PmsIniCOTP(AF9->AF9_PROJET, AF9->AF9_REVISA, ;
		                           dRefDate, AF9->AF9_TAREFA, AF9->AF9_TAREFA)
		nCOTP := PmsRetCOTP(aProjectCOTP, PMS_TASK, AF9->AF9_TAREFA, .T.)[1]
		Aadd(aTaskInfo, nCOTP)
				
		// 4. recupera o valor de Custo Previsto no Término
		aProjectCPT := PmsIniCOTP(AF9->AF9_PROJET, AF9->AF9_REVISA, ;
		                          AF9->AF9_FINISH, AF9->AF9_TAREFA, AF9->AF9_TAREFA)
		nCPT := PmsRetCOTP(aProjectCPT, PMS_TASK, AF9->AF9_TAREFA)[1]
		Aadd(aTaskInfo, nCPT)
				
		// 5. recupera o valor de Variação nos Custos
		nVC := (nCOTE - nCRTE) / nCOTE * -100
		If nVC > 100
			Aadd(aTaskInfo, 0)
		Else
			Aadd(aTaskInfo, nVC)
		EndIf
				
		// 6. recupera o valor de IDC		
		nIDC := nCOTE / nCRTE * 100
		Aadd(aTaskInfo, nIDC)
				
		// 7. recupera o valor de ECT
		nECT := nCPT / nIDC * 100
		If nECT > 100
			Aadd(aTaskInfo, 0)
		Else
			Aadd(aTaskInfo, nECT)					
		EndIf
		    
		// 8. recupera o valor de VP
		nVP		:= (nCOTE - nCOTP) / nCOTE * -100
		Aadd(aTaskInfo, nVP)		
		
		// 9. recupera o valor de IDP
		nIDP := nCOTE / nCOTP * 100
		Aadd(aTaskInfo, nIDP)
				
		// 10. recupera a DET
		// se não existe um IDP, não é possível calcular o DET		
		If nIDP == 0
			dDET := PMS_EMPTY_DATE
		Else
			dDET := Int((AF9->AF9_FINISH - AF9->AF9_START) / nIDP * 100) + AF9->AF9_START
		EndIf		
		Aadd(aTaskInfo, dDET)
		
		// salva informações da Tarefa
		Aadd(aTaskInfoSet, aTaskInfo)
		
		AF9->(dbSkip())	
	End			
  
	RestArea(aAreaAF8)
	RestArea(aAreaAF9)
	RestArea(aArea)
Return aTaskInfoSet

/*
	PMSAJHGen()
	
	Esta função foi recomendada como User Function para poder
	ser customizada pelo cliente.
*/
User Function PMSAJHGen()

	//
	// TODO: receber os parâmetros do StartJob() do SigaDW
	//	

	// é obrigatória a inicialização do environment
	PREPARE ENVIRONMENT ;
		EMPRESA ParamIXB[1] ;
		FILIAL  ParamIXB[2] ;
		TABLES "AF8", "AF9", "AJH"

	// função padrão para geração de dados AJH
	PMSAJHGen()	
Return Nil

/*



*/
Function PMSAJHGen()
	Local aOfflineInfo := {}
	Local i := 0
	
	Local aAreaAJH := AJH->(GetArea())
  Local aAreaAF8 := AF8->(GetArea())

	// deleta todos os registros já existentes
	DelAllAJH()
	
	dbSelectArea("AF8")
	dbSetOrder(1) // AF8_FILIAL + AF8_PROJET + AF8_DESCRI
	AF8->(MsSeek(xFilial("AF8")))

	// exporta informações de todos os projetos	
	While !AF8->(Eof())

		aOfflineInfo := PmsGetAJH(AF8->AF8_PROJET, dDatabase)  

		For i := 1 To Len(aOfflineInfo)

			Reclock("AJH", .T.)
	
			AJH->AJH_FILIAL := aOfflineInfo[i][01]
			AJH->AJH_PROJET := aOfflineInfo[i][02]
			AJH->AJH_TAREFA := aOfflineInfo[i][03]
			AJH->AJH_REVISA := aOfflineInfo[i][04]
			AJH->AJH_DATA   := aOfflineInfo[i][05]
			AJH->AJH_COTE   := aOfflineInfo[i][06]
			AJH->AJH_CRTE   := aOfflineInfo[i][07]
			AJH->AJH_COTP   := aOfflineInfo[i][08]			
			AJH->AJH_CPT    := aOfflineInfo[i][09]
			AJH->AJH_VC     := aOfflineInfo[i][10]
			AJH->AJH_IDC    := aOfflineInfo[i][11]
			AJH->AJH_ECT    := aOfflineInfo[i][12]
			AJH->AJH_VP     := aOfflineInfo[i][13]
			AJH->AJH_IDP    := aOfflineInfo[i][14]
			AJH->AJH_DET    := aOfflineInfo[i][15]
			
			MsUnlock()		
		Next	

		AF8->(dbSkip())	
	End
	
	RestArea(aAreaAF8)
	RestArea(aAreaAJH)
Return Nil

/*

*/
Function DelAllAJH
	dbSelectArea("AJH")
	AJH->(MsSeek(xFilial()))

	//
	// TODO: otimizar a deleção de registros
	//       para TopConnect
	//
	
	While !AJH->(Eof())
		Reclock("AJH", .F.)
		AJH->(dbDelete())
		MsUnlock()
		
		AJH->(dbSkip())		
	End
Return Nil