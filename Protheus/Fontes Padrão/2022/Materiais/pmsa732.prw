#include "protheus.ch"

/* ----------------------------------------------------------------------------

PmsNwPrCost()

Recalcula os custos previstos do projeto cProject, revisão cRevision. Esta
função consome processador e conexão ao banco de dados.

---------------------------------------------------------------------------- */

Function PmsNwPrCost(cProject, cRevision)
	Local aArea := GetArea()
	Local oTree := Nil

	// 1. montar e recalcula a árvore do projeto
	oTree := PmsCreateTree(cProject, cRevision)
	
	// 2. regravar os valores
	PmsSaveTree(oTree)

	RestArea(aArea)
Return

/* ----------------------------------------------------------------------------

PmsCreateTree()

Cria e recalcula simultaneamente os custos do projeto cProject,
revisão cRevision.

Devolve a estrutura do projeto criada como uma árvore.

---------------------------------------------------------------------------- */
Static Function PmsCreateTree(cProject, cRevision)
	Local oTree := Nil
	Local aArea := GetArea()
	Local aAreaAFC := AFC->(GetArea())
	
	cProject := PadR(cProject, Len(AFC->AFC_PROJET))

	dbSelectArea("AFC")
	AFC->(dbSetOrder(2))
	// AFC_FILIAL + AFC_PROJET + AFC_REVISA + AFC_NIVEL    

	If AFC->(dbSeek(xFilial("AFC") + cProject + cRevision))

		// cria EDT principal (nó raiz)
		oTree := PmsTask():New()

		oTree:IsWbs := .T.
		oTree:Text := AFC->AFC_DESCRI
		oTree:Id := AFC->(Recno())
		oTree:ProjectCode := AFC->AFC_PROJET
		oTree:Revision := AFC->AFC_REVISA
		oTree:TaskCode := AFC->AFC_EDT
  
		PmsAddWbs(oTree, cProject, cRevision, AFC->AFC_EDT)
	EndIf
	
	RestArea(aAreaAFC)
	RestArea(aArea)
Return oTree

/* ----------------------------------------------------------------------------

PmsAddTasks()

Adiciona as tarefas filhas existentes na tarefa oTask, do projeto cProject,
revisão cRevision cuja EDT pai tenha o código igual a cWbs.

---------------------------------------------------------------------------- */
Static Function PmsAddTasks(oTask, cProject, cRevision, cWbs)
	Local oAuxTask := Nil
	Local aArea := GetArea()
	Local aAreaAF9 := AF9->(GetArea())

	// informações para truncamento
	//Local cTrunca := PMSReadValue("AF8", 1, xFilial("AF8") + cProject, ;
	//	                              "AF8_TRUNCA", "2")
	                              	
	cProject := PadR(cProject, Len(AF9->AF9_PROJET))
  
	dbSelectArea("AF9")

	// AF9_FILIAL + AF9_PROJET + AF9_REVISA + AF9_EDTPAI + AF9_ORDEM
	AF9->(dbSetOrder(2))
	AF9->(MsSeek(xFilial("AF9") + cProject + cRevision + cWbs))

	While !AF9->(Eof()) .And. AF9->AF9_FILIAL == xFilial("AF9") .And. ;
	                          AF9->AF9_PROJET == cProject .And. ;
	                          AF9->AF9_REVISA == cRevision .And. ;
	                          AF9->AF9_EDTPAI == cWbs

		oAuxTask := PmsTask():New()
		oTask:AppendChild(oAuxTask)
				
		// setar as propriedades aqui
		oAuxTask:ConsiderBdi := (PmsExistField("AF9", "AF9_UTIBDI") .And. ;
		                         AF9->AF9_UTIBDI == "1" .Or. Empty(AF9->AF9_UTIBDI))

		oAuxTask:Id := AF9->(Recno())
		oAuxTask:IsWbs := .F.

		oAuxTask:Text := AF9->AF9_DESCRI
		oAuxTask:Quantity := AF9->AF9_QUANT
		
		// códigos para retrocompatibilidade
		oAuxTask:TaskCode := AF9->AF9_TAREFA
		oAuxTask:ProjectCode := AF9->AF9_PROJET
		oAuxTask:Revision := AF9->AF9_REVISA
		oAuxTask:CalendarCode := AF9->AF9_CALEND

		oAuxTask:ActualDuration := AF9->AF9_HUTEIS
		oAuxTask:Duration := AF9->AF9_HDURAC
		oAuxTask:MeasurementMethod := AF9->AF9_TPMEDI

		// data início prevista
		oAuxTask:ExpectedStartDate := AF9->AF9_START
		oAuxTask:ExpectedStartTime := AF9->AF9_HORAI
		
		// data início executada
		oAuxTask:ExecutedStartDate := AF9->AF9_DTATUI
		oAuxTask:ExecutedStartTime := AF9->AF9_HRATUI
	
		// data de fim prevista
		oAuxTask:ExpectedFinishDate := AF9->AF9_FINISH
		oAuxTask:ExpectedFinishTime := AF9->AF9_HORAF
		
		// data de fim executada
		oAuxTask:ExecutedFinishDate := AF9->AF9_DTATUF
		oAuxTask:ExecutedFinishTime := AF9->AF9_HRATUF

		// aplica o percentual de BDI (cálculo atual)
		If oAuxTask:ConsiderBdi
			If oAuxTask:MarkupPercent == 0.0 //.And. oAuxTask:MarkupValue == 0.0
				If oAuxTask:ParentNode # Nil
					If oAuxTask:ParentNode:MarkupPercent == 0.0
						oAuxTask:MarkupPercent :=	PMSReadValue("AF8", 1, xFilial("AF8") + ;
						                          oAuxTask:ProjectCode, "AF8_BDIPAD", 0.0)
					Else
						oAuxTask:MarkupPercent := oAuxTask:ParentNode:MarkupPercent
					EndIf
				EndIf
			EndIf
		EndIf

		// captura
		PmsCapture(oAuxTask)	

		// subida
		PmsBubble(oAuxTask)

	  AF9->(dbSkip())
	End

	RestArea(aAreaAF9)
	RestArea(aArea)	
Return


/* ----------------------------------------------------------------------------

PmsAddWbs()

Adiciona as EDTs filhas existentes na tarefa oWbs, do projeto cProject,
revisão cRevision, cuja EDT pai tenha o código igual a cWbs.

---------------------------------------------------------------------------- */
Static Function PmsAddWbs(oWbs, cProject, cRevision, cWbs)
	Local aArea := GetArea()
	Local aAreaAFC := AFC->(GetArea())

	Local oAuxTask := Nil

	// capture
	PmsCapture(oWbs)

	PMSAddTasks(oWbs, cProject, cRevision, cWbs)
	
	dbSelectArea("AFC")
	AFC->(dbSetOrder(2))
	AFC->(MsSeek(xFilial("AFC") + cProject + cRevision + cWbs))

	While !AFC->(Eof()) .And. AFC->AFC_FILIAL == xFilial("AF9") .And. ;
	                          AFC->AFC_PROJET == cProject .And. ;
	                          AFC->AFC_REVISA == cRevision .And. ;
	                          AFC->AFC_EDTPAI == cWbs

		oAuxTask := PmsTask():New()

		// setar os atributos aqui
		oAuxTask:Text := AFC->AFC_DESCRI
			
		// markup
		oAuxTask:MarkupPercent := AFC->AFC_BDITAR
		oAuxTask:MarkupValue := AFC->AFC_VALBDI 
		
		oAuxTask:Id := AFC->(Recno())
		oAuxTask:IsWbs := .T.
		oAuxTask:TaskCode := AFC->AFC_EDT
		oAuxTask:ProjectCode := AFC->AFC_PROJET
		oAuxTask:Revision := AFC->AFC_REVISA
		oAuxTask:CalendarCode := AFC->AFC_CALEND
		oAuxTask:ActualDuration := AFC->AFC_HUTEIS
		oAuxTask:Duration := AFC->AFC_HDURAC

		oWbs:AppendChild(oAuxTask)
	
		PmsAddWbs(oAuxTask, cProject, cRevision, AFC->AFC_EDT)
	  
	  AFC->(dbSkip())
	End

	// subida
	PmsBubble(oWbs)	
	
	RestArea(aAreaAFC)
	RestArea(aArea)
Return

/* ----------------------------------------------------------------------------

PmsCapture()

PmsCapture() é executada quando a árvore de tarefas do projeto é percorrida
do nó raiz aos nós folhas.

É utilizada quando é necessário passar alterar as propriedades das tarefas
filhas a partir da EDT pai.

Recebe a tarefa atual oTask que está sendo processada neste momento. Devolve
nulo.

Futuramente, PmsCapture() e PmsBubble() devem ser implementadas através do
design pattern Strategy.

---------------------------------------------------------------------------- */
Static Function PmsCapture(oTask)
	oTask:Cost := PmsAF91Cost(oTask)
	oTask:Markup := oTask:Cost * (oTask:MarkupPercent / 100)
	oTask:TotalCost := oTask:Cost + oTask:Markup
Return Nil

/* ----------------------------------------------------------------------------

PmsBubble()

PmsBubble() é executada quando a árvore de tarefas do projeto é percorrida dos
nós folhas ao nó raiz.

É utilizada quando é necessário passar alterar as propriedades da EDT pai a
partir das tarefas filhas.

Recebe a tarefa atual oTask que está sendo processada neste momento. Devolve
nulo.

Futuramente, PmsCapture() e PmsBubble() devem ser implementadas através do
design pattern Strategy.

---------------------------------------------------------------------------- */

Static Function PmsBubble(Task)
	If Task:ParentNode # Nil
		Task:ParentNode:Cost += Task:Cost
		Task:ParentNode:TotalCost += Task:TotalCost
	Endif
	
	PmsIncProc(.T., , "PROJ")
Return Nil

/* ----------------------------------------------------------------------------

PmsSaveTree() 

PmsSaveTree() grava a árvore de tarefas na base de dados. Recebe como parâmetro
o nó inicial Node e, a partir deste, todos os nós filhos serão gravados na base.

Deste modo, não é necessário que o nó inicial seja o nó raiz, podendo ser um nó
contendo uma sub-árvore.

Restrição: Esta função utiliza o recno para localizar e gravar o registro.
Também não utiliza transação durante a gravação.

---------------------------------------------------------------------------- */

Static Function PmsSaveTree(Node)
	Local AuxNode := Node
	
	Local aArea := GetArea()
	Local aAreaAFC := AFC->(GetArea())
	Local aAreaAF9 := AF9->(GetArea())

	While AuxNode # Nil
		
		If AuxNode:IsWbs
			AFC->(dbGoto(AuxNode:Id))
			
			AFC->(Reclock("AFC", .F.))
      
			AFC->AFC_CUSTO := AuxNode:Cost
			AFC->AFC_TOTAL := AuxNode:TotalCost
		
			AFC->(MsUnlock())

			PmsSaveTree(AuxNode:Children)
		Else
			AF9->(dbGoto(AuxNode:Id))		
			AF9->(Reclock("AF9", .F.))
      
			AF9->AF9_CUSTO  := AuxNode:Cost
			AF9->AF9_VALBDI := AuxNode:Markup
			AF9->AF9_TOTAL  := AuxNode:TotalCost
			
			AF9->(MsUnlock())

			// ponto de entrada para o cliente customizar
			// o calculo do custo da tarefa				
			If ExistBlock("PMSXCust")
				ExecBlock("PMSXCust") // calcula o custo   
			EndIf
	EndIf
		
		AuxNode := AuxNode:NextSibling
	End

	RestArea(aAreaAF9)
	RestArea(aAreaAFC)	
	RestArea(aArea)
Return Nil

/* ----------------------------------------------------------------------------

As funções abaixo foram baseadas nas funções contidas no PMSXFUN

---------------------------------------------------------------------------- */


/* ----------------------------------------------------------------------------

PmsAFACost()

Esta função foi baseada na função PmsCotpAFA(), portanto deve apresentar
os mesmos resultados.

---------------------------------------------------------------------------- */

Static Function PmsAFACost(oNode, dDataRef, aCusto, nDecCst, lAcumulado, nPercEx, cTrunca, nQuantity)
	Local lRet		:= .F.
	//Local aTX2M		:= {0,0,0,0,0}
	
	Local dDtConv, cCnvPrv
	//Local nPercFrt := 1 
	Local nCusto := 0

	Default cTrunca := "1"
	Default nDecCst    := TamSX3("AF9_CUSTO")[2]
	Default lAcumulado := .T. 
	
	Default nQuantity := oNode:Quantity

	aCusto := {0, 0, 0, 0, 0}

	If lAcumulado 
		lRet := PmsAcCostAFA(oNode, dDataRef, nPercEx, @nCusto, nQuantity)
	Else

		// faz o calculo do custo no valor nao acumulado, 
		// isto é não é o valor previsto até o dia, mas o valor previsto pro dia.	
		lRet := PMSNaCostAFA(oNode, dDataRef, nPercEx, @nCusto, nQuantity)
	
	EndIf	
	
	PmsVerConv(@dDtConv, @cCnvPrv)
	
	// truncamento do custo
	aCusto[1] := PmsTrunca(cTrunca, nCusto, nDecCst, nQuantity)	
Return lRet

/* ----------------------------------------------------------------------------

PmsAcCostAFA() - Esta função não utiliza PmsTrunca()

---------------------------------------------------------------------------- */

Static Function PmsAcCostAFA(oNode, dDataRef, nPercEx, nCusto, nQuantity)
	Local lRet := .F.
	Local nHrsUteis := 0
	Local nPerc := 0	
	Local nQuant := 0
                   
	Default nQuantity := oNode:Quantity

  nQuant := PmsAFAQuant(AFA_PROJET, AFA_REVISA, AFA_TAREFA, AFA_PRODUT, nQuantity, AFA_QUANT, oNode:Duration)  
  
	Do Case
		Case AFA->AFA_ACUMUL == "1"

			If dDataRef >= oNode:ExpectedStartDate .And. dDataRef < oNode:ExpectedFinishDate
				nCusto := AFA_CUSTD * nQuant / 2
				lRet		:= .T.
	   	EndIf
	    	
			If dDataRef >= oNode:ExpectedFinishDate
				nCusto		:= AFA_CUSTD * nQuant
				lRet		:= .T.
			EndIf
			
		Case AFA->AFA_ACUMUL == "2"
			If dDataRef >= oNode:ExpectedFinishDate
				nCusto 		:= AFA_CUSTD * nQuant
				lRet		:= .T.
			EndIf
		Case AFA->AFA_ACUMUL == "4"
			If dDataRef>=AFA->AFA_DATPRF
				nCusto		:= AFA_CUSTD * nQuant
				lRet		:= .T.
			EndIf
		Case AFA->AFA_ACUMUL == "5"
			If dDataRef>=AFA->AFA_DTAPRO
				nCusto	:= AFA_CUSTD * nQuant
				lRet		:= .T.
			EndIf
		Case AFA->AFA_ACUMUL == "6"
		
			If dDataRef>=AFA->AFA_DTAPRO
				If nPercEx != Nil
					nCusto	:= AFA_CUSTD * nQuant * nPercEx
				Else
					If oNode:ActualDuration > 0
						If dDataRef >= oNode:ExpectedFinishDate
							nHrsUteis := oNode:ActualDuration
						Else
							nHrsUteis := PmsHrsItvl(AFA->AFA_DTAPRO,oNode:ExpectedStartTime,dDataRef,"24:00",oNode:CalendarCode,oNode:ProjectCode)
						EndIf
						If nHrsUteis==oNode:ActualDuration
							nPerc		:= 1
						Else
							nPerc		:= nHrsUteis/PmsHrsItvl(AFA->AFA_DTAPRO,oNode:ExpectedStartTime,oNode:ExpectedFinishTime,oNode:ExecutedFinishDate,oNode:CalendarCode,oNode:ProjectCode)
						EndIf
					Else
						If dDataRef >= AFA->AFA_DTAPRO
							nPerc	:= 1
						Else
							nPerc	:= 0
						EndIf
					EndIf
					nCusto	:= AFA_CUSTD * nQuant *nPerc
				EndIf
				lRet := .T.
			EndIf
			
		OtherWise
			If nPercEx == Nil
				If dDataRef >= oNode:ExpectedStartDate
					nPerc := PmsExpTrfCst(oNode, dDataRef)
					//nPerc := PMSPrvAF9Cst(AFA_PROJET,AFA_REVISA,AFA_TAREFA,dDataRef)
				Else
					nPerc := 0
				EndIf
				nCusto := AFA_CUSTD * nQuant *nPerc
			Else
				nCusto := AFA_CUSTD * nQuant * nPercEx
			Endif
			lRet := .T.
	EndCase
Return lRet

/* ----------------------------------------------------------------------------

PMSNaCostAFA()

---------------------------------------------------------------------------- */

Static Function PMSNaCostAFA(oNode, dDataRef, nPercEx, nCusto, nQuantity) 
	Local lRet := .F.
	Local nQuant := 0
	
	Default nQuantity := oNode:Quantity  
	
	nQuant := PmsAFAQuant(AFA->AFA_PROJET, AFA->AFA_REVISA, AFA->AFA_TAREFA, AFA->AFA_PRODUT, ;
	                      nQuantity, AFA_QUANT, oNode:Duration)
	
	//Local nHrsUteis := 0
	//Local nPerc := 0
	
	Do Case
		Case AFA->AFA_ACUMUL == "1"
			If dDataRef == oNode:ExpectedStartDate .AND. dDataRef == oNode:ExpectedFinishDate
				nCusto		:= AFA_CUSTD * nQuant
				lRet		:= .T.

			Else
				If dDataRef == oNode:ExpectedStartDate .OR. dDataRef == oNode:ExpectedFinishDate
					nCusto		:= AFA_CUSTD * nQuant / 2
					lRet		:= .T.
		    	EndIf
	    	EndIf
		Case AFA->AFA_ACUMUL == "2"
			If dDataRef == oNode:ExpectedFinishDate
				nCusto 		:= AFA_CUSTD * nQuant
				lRet		:= .T.
			EndIf
		Case AFA->AFA_ACUMUL == "4"
			If dDataRef == AFA->AFA_DATPRF
				nCusto		:= AFA_CUSTD * nQuant
				lRet		:= .T.
			EndIf
		Case AFA->AFA_ACUMUL == "5"
			If dDataRef>=AFA->AFA_DTAPRO
				nCusto	:= AFA_CUSTD * nQuant
				lRet		:= .T.
			EndIf
		Case AFA->AFA_ACUMUL == "6"
			If dDataRef>=AFA->AFA_DTAPRO
				If nPercEx == Nil
					//nCusto := AFA_CUSTD * PmsPrvAFA(AFA->(recno()), dDataRef, dDataRef ,nRecAF9)
					nCusto := AFA_CUSTD * PmsPrv2AFA(oNode, dDataRef, dDataRef, nQuantity)
				Else
					nCusto		:= AFA_CUSTD * nPercEx
				Endif
				lRet		:= .T.
			EndIf
		OtherWise
			If nPercEx == Nil
				//nCusto		:= (AFA_CUSTD*PmsPrvAFA(AFA->(recno()), dDataRef, dDataRef,nRecAF9))*nPercFrt
				nCusto := (AFA_CUSTD * PmsPrv2AFA(oNode, dDataRef, dDataRef)) * nPercFrt
			Else
				nCusto		:= (AFA_CUSTD*nPercEx)*nPercFrt
			Endif
			lRet		:= .T.
	EndCase
Return lRet

/* ----------------------------------------------------------------------------

PMSPrv2AFA()

---------------------------------------------------------------------------- */

Static Function PmsPrv2AFA(oTask, dDataDe, dDataAte, nQuantity)

Local nPerc
Local nHrsUteis := 0
Local nQuant	:= 0

Default nQuantity := oTask:Quantity

dbSelectArea("AFA")
Do Case
	Case AFA->AFA_ACUMUL == "1"
		If (dDataDe >= oTask:ExpectedStartDate .And. dDataDe < oTask:ExpectedFinishDate) .Or.(dDataAte >= oTask:ExpectedStartDate .And. dDataAte < oTask:ExpectedFinishDate)
			nQuant	:= PmsAFAQuant(AFA_PROJET,AFA_REVISA,AFA_TAREFA,AFA_PRODUT,nQuantity,AFA_QUANT,oTask:Duration)/2
    	EndIf
		If dDataDe <= oTask:ExpectedStartDate .And. dDataAte >= oTask:ExpectedFinishDate
			nQuant	:= PmsAFAQuant(AFA_PROJET,AFA_REVISA,AFA_TAREFA,AFA_PRODUT,nQuantity,AFA_QUANT,oTask:Duration)
    	EndIf
	Case AFA->AFA_ACUMUL == "2"
		If dDataDe <= oTask:ExpectedFinishDate .And. dDataAte >= oTask:ExpectedFinishDate
			nQuant	:= PmsAFAQuant(AFA_PROJET,AFA_REVISA,AFA_TAREFA,AFA_PRODUT,nQuantity,AFA_QUANT,oTask:Duration)
		EndIf
	Case AFA->AFA_ACUMUL == "4"
		If dDataDe <= AFA->AFA_DATPRF .And. dDataAte >= AFA->AFA_DATPRF
			nQuant	:= PmsAFAQuant(AFA_PROJET,AFA_REVISA,AFA_TAREFA,AFA_PRODUT,nQuantity,AFA_QUANT,oTask:Duration)
		EndIf
	Case AFA->AFA_ACUMUL == "5"
		If dDataDe>=AFA->AFA_DTAPRO
			nQuant	:= PmsAFAQuant(AFA_PROJET,AFA_REVISA,AFA_TAREFA,AFA_PRODUT,nQuantity,AFA_QUANT,oTask:Duration)
		EndIf
	Case AFA->AFA_ACUMUL == "6"
		If oTask:ActualDuration > 0
		
  			If !((dDataDe < AFA->AFA_DTAPRO .And. dDataAte < AFA->AFA_DTAPRO) ;
  			    .OR.(dDataDe > oTask:ExpectedFinishDate .And. dDataAte > oTask:ExpectedFinishDate))
  			    
				If AFA->AFA_DTAPRO >= dDataDe
					dDataDe := AFA->AFA_DTAPRO
				EndIf
				
				If oTask:ExpectedFinishDate < dDataAte
					dDataAte := oTask:ExpectedFinishDate
				EndIf
				   
				nHrsUteis := PmsHrsItvl(dDataDe ,oTask:ExpectedStartTime, dDataAte ,"24:00",oTask:CalendarCode,oTask:ProjectCode)
				If nHrsUteis == oTask:ActualDuration
					nPerc := 1
				Else
					nPerc := nHrsUteis/PmsHrsItvl(AFA->AFA_DTAPRO,oTask:ExpectedStartTime,oTask:ExpectedFinishDate,oTask:ExpectedFinishTime,oTask:CalendarCode,oTask:ProjectCode)
				EndIf
			Else
				nPerc := 0
  			EndIf
		Else
			If dDataDe <= AFA->AFA_DTAPRO .And. dDataAte >= oTask:ExpectedFinishDate
				nPerc	:= 1
			Else
				nPerc	:= 0
			EndIf
		EndIf
		nQuant	:= PmsAFAQuant(AFA_PROJET,AFA_REVISA,AFA_TAREFA,AFA_PRODUT,nQuantity,AFA_QUANT,oTask:Duration)*nPerc
	OtherWise
		If oTask:ActualDuration > 0
			nPerc		:= (PMSPrv2AF9(oTask:ProjectCode,oTask:Revision,oTask:TaskCode,dDataAte)-PMSPrv2AF9(oTask:ProjectCode,oTask:Revision,oTask:TaskCode,dDataDe-1))/oTask:Duration
		Else
			If dDataDe <= oTask:ExpectedStartDate .And. dDataAte >= oTask:ExpectedFinishDate
				nPerc	:= 1
			Else
				nPerc	:= 0
			EndIf
		EndIf
		nQuant	:= PmsAFAQuant(AFA_PROJET,AFA_REVISA,AFA_TAREFA,AFA_PRODUT,nQuantity,AFA_QUANT,oTask:Duration)*nPerc
EndCase
Return nQuant

/* ----------------------------------------------------------------------------

PMSPrv2AF9()

---------------------------------------------------------------------------- */

Static Function PMSPrv2AF9(oTask, dDataRef)
Local lTpMed3 := .F.
Local nRet := 0
Local aAuxCRTE := {}
Local nCustoReal := 0
Local nPercFrt := 1

Default dDataRef := dDataBase

Do Case
	Case oTask:MeasurementMethod == "1"
		If dDataRef >= oTask:ExpectedFinishDate
			nRet := oTask:ActualDuration
		EndIf
	Case oTask:MeasurementMethod == "2"
		If dDataRef >= oTask:ExpectedFinishDate
			nRet := oTask:ActualDuration
		Else
			nRet := oTask:ActualDuration * 0.2
		EndIf
	Case oTask:MeasurementMethod == "3"
		dbSelectArea("AFP")
		dbSetOrder(1)
		If MsSeek(xFilial()+cProjeto+cRevisa+cTarefa)
			While !Eof() .And. xFilial()+cProjeto+cRevisa+cTarefa==;
								AFP_FILIAL+AFP_PROJET+AFP_REVISA+AFP_TAREFA
				If AFP_USO==GetNewPar("MV_PMSEVEN","0001")
					lTpMed3	:= .T.
					If AFP_DTPREV <= dDataRef
						nRet := oTask:ActualDuration * AFP_PERC/100
					EndIf
				EndIf
				dbSkip()
			End
		EndIf
		If !lTpMed3
			If dDataRef >= oTask:ExpectedFinishDate
				nRet := oTask:ActualDuration
			Else
				nRet := PmsHrsItvl(oTask:ExpectedStartDate, ;
				                   oTask:ExpectedStartTime, dDataRef, "24:00", ;
				                   oTask:CalendarCode, ;
				                   oTask:ProjectCode)
			EndIf
		EndIf
	Case oTask:MeasurementMethod == "5"
		If dDataRef >= oTask:ExpectedFinishDate
			nRet := oTask:ActualDuration
		Else
			aAuxCRTE := PmsIniCRTE(cProjeto,cRevisa,dDataRef,cTarefa,cTarefa)
			nCustoReal := PmsRetCRTE(aAuxCRTE,1,cTarefa)[1]
			nRet := (Min(nCustoReal,oTask:Cost)/oTask:Cost) * oTask:ActualDuration
		EndIf
	Case oTask:MeasurementMethod == "6"
		dbSelectArea("AFZ")
		dbSetOrder(1)
		If MsSeek(xFilial()+cProjeto+cRevisa+cTarefa+DTOS(dDataRef),.T.)
			nRet	:= oTask:ActualDuration * AFZ_PERC/100
		Else
			dbSkip(-1)
			If 	!Bof().And. cProjeto==AFZ->AFZ_PROJET.And.;
				cRevisa==AFZ->AFZ_REVISA.And.;
				cTarefa==AFZ->AFZ_TAREFA
				nRet := oTask:ActualDuration * AFZ_PERC/100
			Else
				nRet := 0
			EndIf
		EndIf
	OtherWise
		If dDataRef >= oTask:ExpectedFinishDate
			nRet := oTask:ActualDuration
		Else
			nRet := PmsHrsItvl(oTask:ExpectedStartDate, oTask:ExpectedStartTime, ;
			dDataRef,"24:00", ;
			oTask:CalendarCode, ;
			oTask:ProjectCode)
		EndIf
EndCase

// verifica se estamos usados Frente e Pega o seu Percentual
If !Empty(PmsGetFrt())
	nPercFrt := PmsPercFrt(oTask:ProjectCode, oTask:Revision, oTask:TaskCode, PmsGetFrt())
	nRet *= nPercFrt
Endif
Return nRet

/* ----------------------------------------------------------------------------

PmsAFBCost()

Esta função foi baseada na função PmsCotpAFB(), portanto deve apresentar
os mesmos resultados. O cálculo foi dividido em acumulado - função PmsAFBAcCost()
e não-acumulado - função PMSAFBNaCost().

---------------------------------------------------------------------------- */

Static Function PmsAFBCost(oTask, dDataRef, aCusto, nDecCst, lAcumulado, ;
                           nPercEx, cTrunca, nQuantity)
	Local lRet := .F.
	Local nCusto := 0
	Local aTX2M := {0, 0, 0, 0, 0}
	Local dDtConv := ""
	Local cCnvPrv

	Default nDecCst := TamSX3("AF9_CUSTO")[2]
	Default lAcumulado := .T.
	
	Default nQuantity := oTask:Quantity
	
	aCusto	:= {0, 0, 0, 0, 0}

	If lAcumulado
	
		// faz o cálculo do custo acumulado, ou seja, o custo previsto
		// até o dia
		PmsAFBAcCost(oTask, dDataRef, nPercEx, @nCusto, cTrunca, nQuantity)
	Else

		// faz o calculo do custo não-acumulado, isto é,
		// não é o valor previsto até o dia, mas o valor previsto para o dia.	
		PMSAFBNaCost(oTask, dDataRef, nPercEx, @nCusto, cTrunca, nQuantity) 		
	EndIf           
	PmsVerConv(@dDtConv,@cCnvPrv)
	aCusto := PmsConvCus(nCusto, AFB->AFB_MOEDA, cCnvPrv, dDtConv, ;
	                     oTask:ExpectedStartDate, ;
	                     oTask:ExpectedFinishDate, , aTX2M, cTrunca, nQuantity)
Return lRet

/* ----------------------------------------------------------------------------

PmsAFBAcCost()

Calcula o custo acumulado das despesas.

---------------------------------------------------------------------------- */

Static Function PmsAFBAcCost(oTask, dDataRef, nPercEx, nCusto, cTrunca, nQuantity)
	Local lRet := .F.
	Local nHrsUteis := 0
	Local nPerc := 0	
	
	Default nQuantity := oTask:Quantity
	
	Do Case
		Case AFB->AFB_ACUMUL == "1"
			If dDataRef >= oTask:ExpectedStartDate .And. dDataRef < oTask:ExpectedFinishDate
				nCusto := PmsAFBValor(nQuantity, AFB->AFB_VALOR) / 2
				lRet := .T.
			EndIf
			
			If dDataRef >= oTask:ExpectedStartDate
				nCusto := PmsAFBValor(nQuantity, AFB->AFB_VALOR)
				lRet := .T.
			EndIf

		Case AFB->AFB_ACUMUL == "2"
			If dDataRef >= oTask:ExpectedFinishDate
				nCusto := PmsAFBValor(nQuantity, AFB->AFB_VALOR)
				lRet := .T.
			EndIf

		Case AFB->AFB_ACUMUL == "4"
			If dDataRef >= AFB->AFB_DATPRF
				nCusto := PmsAFBValor(nQuantity, AFB->AFB_VALOR)
				lRet := .T.
			EndIf

		Case AFB->AFB_ACUMUL == "5"
			If dDataRef >= AFB->AFB_DTAPRO
				nCusto := PmsAFBValor(nQuantity, AFB->AFB_VALOR)
				lRet := .T.
			EndIf
			
		Case AFB->AFB_ACUMUL == "6"
			If dDataRef >= AFB->AFB_DTAPRO
				If nPercEx != NIL
					nCusto := PmsAFBValor(nQuantity, AFB->AFB_VALOR) * nPercEx
				Else
					If oTask:ActualDuration > 0
						If dDataRef >= oTask:ExpectedFinishDate
							nHrsUteis := oTask:ActualDuration
						Else
							nHrsUteis := PmsHrsItvl(AFB->AFB_DTAPRO, oTask:ExpectedStartTime, dDataRef, "24:00", ;
							                        oTask:CalendarCode, oTask:ProjectCode)
						EndIf
						If nHrsUteis==oTask:ActualDuration
							nPerc := 1
						Else
							nPerc := nHrsUteis/PmsHrsItvl(AFB->AFB_DTAPRO,oTask:ExpectedStartTime,oTask:ExpectedFinishDate, ;
							               oTask:ExpectedFinishTime, ;
							               oTask:CalendarCode, ;
							               oTask:ProjectCode)
						EndIf
					Else
						If dDataRef >= oTask:ExpectedStartDate
							nPerc	:= 1
						Else
							nPerc	:= 0
						EndIf
					EndIf
					nCusto := PmsAFBValor(nQuantity, AFB->AFB_VALOR) * nPerc
				EndIf
				lRet := .T.
			EndIf

		OtherWise
			If nPercEx <> Nil
			   nPerc := nPercEx
			Else				
				If dDataRef >= oTask:ExpectedStartDate
					//nPerc := PMSPrvAF9Cst(AFB_PROJET,AFB_REVISA,AFB_TAREFA,dDataRef)
					nPerc := PmsExpTrfCst(oTask, dDataRef)
				Else
					nPerc := 0
				EndIf
			Endif
			nCusto := PmsAFBValor(nQuantity, AFB->AFB_VALOR) * nPerc
			lRet := .T.
	EndCase	
Return lRet

/* ----------------------------------------------------------------------------

PMSAFBNaCost()

Calcula o custo não acumulado das despesas.

---------------------------------------------------------------------------- */

Static Function PMSAFBNaCost(oTask, dDataRef, nPercEx, nCusto, cTrunca, nQuantity) 
	Local lRet := .F.
	
	Default nQuantity := oTask:Quantity

	Do Case
		Case AFB->AFB_ACUMUL == "1"
			If dDataRef == oTask:ExpectedStartDate .And. dDataRef == oTask:ExpectedFinishDate
				nCusto := PmsAFBValor(nQuantity, AFB->AFB_VALOR)
				lRet := .T.
			Else
				If dDataRef == oTask:ExpectedStartDate .Or. dDataRef == oTask:ExpectedFinishDate
					nCusto := PmsAFBValor(nQuantity, AFB->AFB_VALOR) / 2
					lRet := .T.
				EndIf
    	EndIf
		Case AFB->AFB_ACUMUL == "2"
			If dDataRef == oTask:ExpectedFinishDate
				nCusto := PmsAFBValor(nQuantity, AFB->AFB_VALOR)
				lRet := .T.
			EndIf
		Case AFB->AFB_ACUMUL == "4"
			If dDataRef == AFB->AFB_DATPRF
				nCusto := PmsAFBValor(nQuantity, AFB->AFB_VALOR)
				lRet := .T.
			EndIf
		Case AFB->AFB_ACUMUL == "5"
			If dDataRef>=AFB->AFB_DTAPRO
				nCusto := PmsAFBValor(nQuantity, AFB->AFB_VALOR)
				lRet := .T.
			EndIf
		Case AFB->AFB_ACUMUL == "6"
			If oTask:ActualDuration > 0
				If dDataRef >= oTask:ExpectedFinishDate
					nHrsUteis := oTask:ActualDuration
				Else
					nHrsUteis := PmsHrsItvl(AFB->AFB_DTAPRO,oTask:ExpectedStartTime,dDataRef,"24:00", ;
					oTask:CalendarCode, oTask:ProjectCode)
				EndIf
				If nHrsUteis==oTask:ActualDuration
					nPerc		:= 1
				Else
					nPerc		:= nHrsUteis/PmsHrsItvl(AFB->AFB_DTAPRO,oTask:ExpectedStartTime,oTask:ExpectedFinishDate, ;
					oTask:ExpectedFinishTime, oTask:CalendarCode, oTask:ProjectCode)
				EndIf
			Else
				If dDataRef >= oTask:ExpectedStartDate
					nPerc	:= 1
				Else
					nPerc	:= 0
				EndIf
			EndIf
			nCusto		:= PmsAFBValor(nQuantity, AFB->AFB_VALOR)*nPerc
			lRet		:= .T.
		OtherWise
			If nPercEx <> Nil
				nPerc	:=	nPercEx
			Else	
				//nPerc := PmsPrvAFB(AFA->(recno()), dDataRef, dDataRef,nRecAF9)
				nPerc := PmsPrv2AFB(oTask, dDataRef, dDataRef, cTrunca, nQuantity)
			EndIf
			nCusto		:= PmsAFBValor(nQuantity, AFB->AFB_VALOR)*nPerc
			lRet		:= .T.
	EndCase	
Return lRet

/* ----------------------------------------------------------------------------

PmsPrv2AFB()

---------------------------------------------------------------------------- */

Static Function PmsPrv2AFB(oTask, dDataDe, dDataAte, cTrunca, nQuantity)
Local nPerc := 0
Local nCusto	:= 0
Local aTX2M		:={0,0,0,0,0}
Local aCusto	:= {0,0,0,0,0}
Local dDtConv, cCnvPrv

//Local nCostPass1 := 0

Default nQuantity := oTask:Quantity

Do Case

	Case AFB->AFB_ACUMUL == "1"

		If (dDataDe >= oTask:ExpectedStartDate .And. dDataDe < oTask:ExpectedFinishDate) .Or.(dDataAte >= oTask:ExpectedStartDate .And. dDataAte < oTask:ExpectedFinishDate)
	//If ( dDataAte <= AF9->AF9_START  .And. AF9->AF9_START >= dDataDe  ) .Or.(dDataAte >= AF9->AF9_START .And. dDataAte < AF9->AF9_FINISH)
			nCusto := PmsAFBValor(nQuantity, AFB->AFB_VALOR) / 2
   	EndIf
   	
		If dDataDe <= oTask:ExpectedStartDate .And. dDataAte >= oTask:ExpectedFinishDate
			nCusto := PmsAFBValor(nQuantity, AFB->AFB_VALOR)
		EndIf

	Case AFB->AFB_ACUMUL == "2"
		If dDataDe <= oTask:ExpectedFinishDate .And. dDataAte >= oTask:ExpectedFinishDate
			nCusto := PmsAFBValor(nQuantity, AFB->AFB_VALOR)
		EndIf

	Case AFB->AFB_ACUMUL == "4"
		If dDataDe <= AFB->AFB_DATPRF .And. dDataAte >= AFB->AFB_DATPRF
			nCusto := PmsAFBValor(nQuantity, AFB->AFB_VALOR)
		EndIf

	Case AFB->AFB_ACUMUL == "5"
		If dDataDe >= AFB->AFB_DTAPRO
			nCusto := PmsAFBValor(nQuantity, AFB->AFB_VALOR)
		EndIf

	Case AFB->AFB_ACUMUL == "6"
		If oTask:ActualDuration > 0
  			If !((dDataDe < AFB->AFB_DTAPRO .And. dDataAte < AFB->AFB_DTAPRO) ;
  			    .OR.(dDataDe > oTask:ExpectedFinishDate .And. dDataAte > oTask:ExpectedFinishDate))
  			    
				If AFB->AFB_DTAPRO >= dDataDe
					dDataDe := AFB->AFB_DTAPRO
				EndIf
				
				If oTask:ExpectedFinishDate < dDataAte
					dDataAte := oTask:ExpectedFinishDate
				EndIf
				   
				nHrsUteis := PmsHrsItvl(dDataDe ,oTask:ExpectedStartTime, dDataAte ,"24:00",oTask:CalendarCode, oTask:ProjectCode)
				If nHrsUteis==oTask:ActualDuration
					nPerc := 1
				Else
					nPerc := nHrsUteis/PmsHrsItvl(AFB->AFB_DTAPRO, oTask:ExpectedStartTime, ;
					                              oTask:ExpectedFinishDate, ;
					                              oTask:ExpectedFinishTime, ;
					                              oTask:CalendarCode, ;
					                              oTask:ProjectCode)
				EndIf
			Else
				nPerc := 0
 			EndIf
		Else
			If dDataDe <= AFB->AFB_DTAPRO .And. dDataAte >= oTask:ExpectedFinishDate
				nPerc	:= 1
			Else
				nPerc	:= 0
			EndIf
		EndIf
		nCusto := PmsAFBValor(nQuantity, AFB->AFB_VALOR) * nPerc
	OtherWise
		If oTask:ActualDuration > 0
			nPerc	:= (PMSPrvAF9(oTask:ProjectCode, oTask:Revision, oTask:TaskCode, dDataAte) - ;
			          PMSPrvAF9(oTask:ProjectCode, oTask:Revision, oTask:TaskCode, dDataDe - 1)) / oTask:Duration
		Else
			If dDataDe <= oTask:ExpectedStartDate .And. dDataAte >= oTask:ExpectedFinishDate
				nPerc	:= 1
			Else
				nPerc	:= 0
			EndIf
		EndIf
		nCusto := PmsAFBValor(nQuantity, AFB->AFB_VALOR) * nPerc
EndCase

	PmsVerConv(@dDtConv,@cCnvPrv)
	aCusto := PmsConvCus(nCusto,AFB->AFB_MOEDA,cCnvPrv,dDtConv, oTask:ExpectedStartDate, ;
	oTask:ExpectedFinishDate, , aTX2M, cTrunca, nQuantity)
Return aCusto

/* ----------------------------------------------------------------------------

PmsExpTrfCst()

---------------------------------------------------------------------------- */

Static Function PmsExpTrfCst(oTask, dDataRef)
	Local lTpMed3	:= .F.
	Local nRet		:= 0
	Local aAuxCRTE := {}
	Local nCustoReal := 0
	
	Local cProjeto := oTask:ProjectCode
	Local cRevisa := oTask:Revision
	Local cTarefa := oTask:TaskCode
	
	Default dDataRef := dDataBase

	Do Case
		Case oTask:MeasurementMethod == "1"
			If dDataRef >= oTask:ExpectedFinishDate
				nRet := 1
			EndIf
			
		Case oTask:MeasurementMethod == "2"
			If dDataRef >= oTask:ExpectedFinishDate
				nRet := 1
			Else
				nRet := 0.2
			EndIf
			
		Case oTask:MeasurementMethod == "3"
			dbSelectArea("AFP")
			dbSetOrder(1)
			If MsSeek(xFilial()+cProjeto+cRevisa+cTarefa)
				While !Eof() .And. xFilial()+cProjeto+cRevisa+cTarefa==;
									AFP_FILIAL+AFP_PROJET+AFP_REVISA+AFP_TAREFA
					If AFP_USO==GetNewPar("MV_PMSEVEN","0001")
						lTpMed3	:= .T.
						If AFP_DTPREV <= dDataRef
							nRet := AFP_PERC/100
						EndIf
					EndIf
					dbSkip()
				End
			EndIf

			If !lTpMed3
				If dDataRef >= oTask:ExpectedFinishDate
					nRet := 1
				Else
					nRet := PmsHrsItvl(oTask:ExpectedStartDate,oTask:ExpectedStartTime,dDataRef,"24:00",oTask:CalendarCode,oTask:ProjectCode)/oTask:Duration
				EndIf
			EndIf

		Case oTask:MeasurementMethod == "5"
			If dDataRef >= oTask:ExpectedFinishDate
				nRet := 1
			Else
				aAuxCRTE := PmsIniCRTE(cProjeto,cRevisa,dDataRef,cTarefa,cTarefa)
				nCustoReal := PmsRetCRTE(aAuxCRTE,1,cTarefa)[1]

				nRet := Min(nCustoReal, oTask:Cost) / oTask:Cost
			EndIf

		Case oTask:MeasurementMethod == "6"
			dbSelectArea("AFZ")
			dbSetOrder(1)
			If MsSeek(xFilial()+cProjeto+cRevisa+cTarefa+DTOS(dDataRef),.T.)
				nRet	:= AFZ_PERC/100
			Else
				dbSkip(-1)
				If 	!Bof().And. cProjeto==AFZ->AFZ_PROJET.And.;
					cRevisa==AFZ->AFZ_REVISA.And.;
					cTarefa==AFZ->AFZ_TAREFA
					nRet := AFZ_PERC/100
				Else
					nRet := 0
				EndIf
			EndIf
		
		OtherWise
			If dDataRef >= oTask:ExpectedFinishDate
				nRet := 1
			Else
				nRet := PmsHrsItvl(oTask:ExpectedStartDate,oTask:ExpectedStartTime,dDataRef,"24:00",oTask:CalendarCode,oTask:ProjectCode)/oTask:Duration
			EndIf
	EndCase
Return nRet

/* ----------------------------------------------------------------------------

PmsAF91Cost()

---------------------------------------------------------------------------- */

Static Function PmsAF91Cost(oTask, dDate, lUnit)
	Local aArea    := GetArea()
	Local aAreaAF9 := AF9->(GetArea())
	Local aAreaAFA := AFA->(GetArea())
	Local aAreaAFB := AFB->(GetArea())

	Local i := 0
	
	// custo da tarefa	
	Local aCost := {0, 0, 0, 0, 0}	
	Local aAuxCost := {}

	// informações de tarefa
	Local cProject := oTask:ProjectCode
	Local cRevision := oTask:Revision
	Local cTask := oTask:TaskCode

	Local cTrunca := PMSReadValue("AF8", 1, xFilial("AF8") + cProject, ;
	                              "AF8_TRUNCA", "2")
	Local nTamDecT := TamSX3("AF9_CUSTO")[2]
	Local nQuantity := 0
	
	Default dDate := Ctod("31/12/2020")
	
	If lUnit
		nQuantity := 1
	Else
		nQuantity := oTask:Quantity	
	EndIf
	
	dbSelectArea("AFA")
	dbSetOrder(1)
	MsSeek(xFilial("AFA") + cProject + cRevision + cTask)
	
	While !AFA->(Eof()) .And. AFA->AFA_FILIAL == xFilial("AFA") .And. ;
	                          AFA->AFA_PROJET == cProject .And. ;
	                          AFA->AFA_REVISA == cRevision .And. ;
	                          AFA->AFA_TAREFA == cTask

		aAuxCost := {0, 0, 0, 0, 0}
		
		PmsAFACost(oTask, dDate, aAuxCost, nTamDecT, .T., , cTrunca, nQuantity)

		// totaliza os custos de recursos e produtos
		For i := 1 To Len(aAuxCost)
			aCost[i] += aAuxCost[i]		
		Next
				
 		AFA->(dbSkip())
 	End

 	dbSelectArea("AFB")
 	dbSetOrder(1)
 	MsSeek(xFilial("AFB") + cProject + cRevision + cTask)
 	
 	While !AFB->(Eof()) .And. AFB->AFB_FILIAL == xFilial("AFB") .And. ;
	                          AFB->AFB_PROJET == cProject .And. ;
	                          AFB->AFB_REVISA == cRevision .And. ;
	                          AFB->AFB_TAREFA == cTask
		
		aAuxCost := {0, 0, 0, 0, 0}

		// calcula custo de despesas
		PmsAFBCost(oTask, dDate, aAuxCost, nTamDecT, .T., , cTrunca, nQuantity)

		// totaliza os custos de despesas
		For i := 1 To Len(aAuxCost)
			aCost[i] += aAuxCost[i]		
		Next
		
 		AFB->(dbSkip())	 	
 	End

	RestArea(aAreaAFB) 
	RestArea(aAreaAFA)
	RestArea(aAreaAF9)
	RestArea(aArea)
Return aCost[1]

/* ----------------------------------------------------------------------------

PmsExistField()

Verifica se existe um campo cFieldName no alias cAlias especificado. O alias
deve estar aberto no momento.

---------------------------------------------------------------------------- */
Function PmsExistField(cAlias, cFieldName)
Return (cAlias)->(FieldPos(cFieldName)) > 0