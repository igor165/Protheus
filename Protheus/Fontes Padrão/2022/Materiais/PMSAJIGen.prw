#include "protheus.ch"
#include "pmsicons.ch"
#include "tbiconn.ch"

Function PmsGetAJI(cProject, dDate)
	Local aArea := GetArea()
	Local aAreaAF9 := AF9->(GetArea())
	Local aAreaAF8 := AF8->(GetArea())
	Local aAreaAFA := AFA->(GetArea())

	Local aTaskInfo := {}
	Local aTaskInfoSet := {}
	
	Local dRefDate := dDataBase
	Local cRevision := PmsAF8Ver(cProject)
	
	Local nItemType := 0

	Local bItemSearch := {}
	Local nPos := 0

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

		// Item alocado
		dbSelectArea("AFA")
		AFA->(dbSetOrder(1)) // AF9_FILIAL+AF9_PROJET+AF9_REVISA+AF9_TAREFA+AF9_ORDEM
	
		AFA->(MsSeek(xFilial("AFA") + cProject + cRevision + AF9->AF9_TAREFA))
	
		While !AFA->(Eof()) .And. AFA->AFA_FILIAL == xFilial("AFA") .And. ;
	                          AFA->AFA_PROJET == cProject .And. ;
	                          AFA->AFA_TAREFA == AF9->AF9_TAREFA .And. ;
	                          AFA->AFA_REVISA == cRevision

			nItemType := PMSItemType(AFA->AFA_RECURS, AFA->AFA_PRODUT)

			Do Case
				
				Case nItemType == PMS_ITEM_RESOURCE_PRODUCT
					bItemSearch := {|x| x[6] == AFA->AFA_RECURS}
							
				Case nItemType == PMS_ITEM_RESOURCE
					bItemSearch := {|x| x[6] == AFA->AFA_RECURS}
					
				Case nItemType == PMS_ITEM_PRODUCT
					bItemSearch := {|x| x[5] == AFA->AFA_PRODUT .And. Empty(AFA->AFA_RECURS)}
			
			EndCase

			// verifica se já existe o produto
			nPos := aScan(aTaskInfoSet, bItemSearch)
			
			If nPos > 0
				
				// adiciona ao item existente
				aTaskInfoSet[nPos][07] += AFA->AFA_QUANT
				aTaskInfoSet[nPos][08] += 0
				aTaskInfoSet[nPos][09] += AFA->AFA_CUSTD
				aTaskInfoSet[nPos][10] += 0
				
			Else

				aTaskInfo := {}
	      	
	  		// 01. código da Filial - AJI_FILIAL
				Aadd(aTaskInfo, AFA->AFA_FILIAL)
	
				// 02. código do Projeto - AJI_PROJET
				Aadd(aTaskInfo, AFA->AFA_PROJET)
				
				// 03. código da Tarefa - AJI_TAREFA
				Aadd(aTaskInfo, AFA->AFA_TAREFA)
				
				// 04. data - AJI_DATA  
				Aadd(aTaskInfo, dRefDate)
	      
				// 05. produto - AJI_PRODUT
				Aadd(aTaskInfo, AFA->AFA_PRODUT)

				// 06. recurso - AJI_RECURS
				Aadd(aTaskInfo, AFA->AFA_RECURS)

				// 07. quantidade prevista - AJI_QTDPRV
				Aadd(aTaskInfo, AFA->AFA_QUANT)
				
				// 08. quantidade realizada - AJI_QTDRLZ
				Aadd(aTaskInfo, 0)	
	
				// 09. custo previsto - AJI_CSTPRV
				Aadd(aTaskInfo, AFA->AFA_CUSTD)
				
				// 10. custo realizado - AJI_CSTRLZ
				Aadd(aTaskInfo, 0)

				// 11. item
				Aadd(aTaskInfo, AFA->AFA_ITEM)

				// inclui novo item
				Aadd(aTaskInfoSet, aTaskInfo)		
			EndIf

			AFA->(dbSkip())		
		End			

		AF9->(dbSkip())		
	End			

	RestArea(aAreaAFA)
	RestArea(aAreaAF8)
	RestArea(aAreaAF9)
	RestArea(aArea)
Return aTaskInfoSet

Function DelAllAJI
	dbSelectArea("AJI")
	AJI->(MsSeek(xFilial()))

	//
	// TODO: otimizar a deleção de registros
	//       para TopConnect
	//
	
	While !AJI->(Eof())
		Reclock("AJI", .F.)
		AJI->(dbDelete())
		MsUnlock()
		
		AJI->(dbSkip())		
	End
Return

Function PMSAJIGen()
	Local aOfflineInfo := {}
	Local i := 0
	
	Local aAreaAJI := AJI->(GetArea())
  Local aAreaAF8 := AF8->(GetArea())

	// deleta todos os registros já existentes
	DelAllAJI()
	
	dbSelectArea("AF8")
	dbSetOrder(1) // AF8_FILIAL + AF8_PROJET + AF8_DESCRI

	AF8->(MsSeek(xFilial("AF8")))

	// exporta informações de todos os projetos
	While !AF8->(Eof())

		aOfflineInfo := PmsGetAJI(AF8->AF8_PROJET, dDatabase)  

		For i := 1 To Len(aOfflineInfo)

			Reclock("AJI", .T.)

			AJI->AJI_FILIAL := aOfflineInfo[i][01]
			AJI->AJI_PROJET := aOfflineInfo[i][02]
			AJI->AJI_TAREFA := aOfflineInfo[i][03]
			AJI->AJI_DATA   := aOfflineInfo[i][04]

			AJI->AJI_PRODUT := aOfflineInfo[i][05]
			AJI->AJI_RECURS := aOfflineInfo[i][06]
			
			AJI->AJI_QTDPRV := aOfflineInfo[i][07]
			AJI->AJI_QTDRLZ := aOfflineInfo[i][08]
			
			AJI->AJI_CSTPRV := aOfflineInfo[i][09]
			AJI->AJI_CSTRLZ := aOfflineInfo[i][10]
			
			AJI->AJI_ITEM   := aOfflineInfo[i][11]
			
			MsUnlock()
		Next

		AF8->(dbSkip())	
	End
	
	RestArea(aAreaAF8)
	RestArea(aAreaAJI)
Return

User Function PMSAJIGen()

	// é obrigatória a inicialização do environment
	PREPARE ENVIRONMENT ;
		EMPRESA ParamIXB[1] ;
		FILIAL  ParamIXB[2] ;
		TABLES "AF8", "AF9", "AFA", "AJI"

	// função padrão para geração de dados AJI
	PMSAJIGen()	
Return Nil
	

Function PMSItemType(cResource, cProduct)
	Local nItemType := 0

	/*
		status              cResource  cProduct  saída                       
		recurso com produto     x          x     PMS_ITEM_RESOURCE_PRODUCT   
		recurso                 x          -     PMS_ITEM_RESOURCE
		produto                 -          x     PMS_ITEM_PRODUCT
		erro                    -          -     PMS_ITEM_UNKNOWN
	*/

	Do Case	
	
		Case !Empty(cResource) .And. !Empty(cProduct)	
			nItemType := PMS_ITEM_RESOURCE_PRODUCT 

		Case !Empty(cResource)
			nItemType := PMS_ITEM_RESOURCE
			
		Case !Empty(cProduct)
			nItemType := PMS_ITEM_PRODUCT
		
		Otherwise
			nItemType := PMS_ITEM_UNKNOWN
			
	EndCase

Return nItemType

