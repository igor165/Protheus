#INCLUDE "PROTHEUS.CH"
#Include 'TopConn.CH'
//-------------------------------------------------------------------
/*/{Protheus.doc} PLCRWEBPRE
Função para pré validar informações do credenciamento no cadastro via WEB. 
@author Karine Riquena Limp
@since 25/05/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLCRWEBPRE()
 
Local lRet 		:= .T.
Local dDataAtu	:=	Date()
Local cCodInt		:= PLSINTPAD()
Local nTimeAcad	:= 0
Local nTimeEsp	:= 0
Local cDesCid		:= ""
Local cDesEsp		:= ""
Local lCritica	:= GetNewPar("MV_CRICREDP", .F.)
Local cPassoPad	:= GetNewPar("MV_MOTPAD", "")
Local nTamNi   	:= 0
Local nI     		:= 0
Local nJ			:= 0
Local nX 			:= 0
Local cMsg			:= ""
Local nPosB9V		:= 0 
Local nPosB9Q		:= 0 
Local nPosB9Y		:= 0
Local aB9Q			:= {}
Local nEspInd		:= 0
Local nEspTot		:= 0
Local cCodMun     := ""
Local cCodSeqB9V  := ""
Local cCodEsp     := ""
Local cSeqGriB9Q  := ""
Local aEsp        := {}
Local cStcred     := "1"
Local lTemFor     := .F.
Local lTemEsp     := .F.
Local cCodLoc     := ""
Local cCPFCGC     := ""
Local cTppes		:= ""
Local cMsg        := ""
Local lOpenB9Z    :=	ChkFile("B9Z",.F.)
Local lOpenB2E    :=	ChkFile("B2E",.F.)
Local lOpenB2F    :=	ChkFile("B2F",.F.)
Local lEntrou     := .F.
Local lErro       := .F.
Local aAux        := {}
Local lAchouEsp   := .F.

	BIC->(DbSelectArea("BIC"))
	BIC->(DbSetOrder(2))
	
	BIB->(DbSelectArea("BIB"))
	BIB->(DbSetOrder(1))
	
	B9I->(DbSelectArea("B9I"))
	B9I->(DbSetOrder(1))
	
	B9J->(DbSelectArea("B9J"))
	B9J->(DbSetOrder(2))
	
	cCPFCGC := Alltrim(GetDadoArr(aDados, "B9Y", "B9Y_CPFCGC",,.T.)[1])
	cCPFCGC := StrTran(cCPFCGC,'.','')  
	cCPFCGC := StrTran(cCPFCGC,'-','')
	cCPFCGC := StrTran(cCPFCGC,'/','')	
	SetDadoArr(@aDados, "B9Y", "B9Y_CPFCGC", cCPFCGC)
	
	cTppes := IIF(Len(cCPFCGC) == 14, "J","F")

	nTamNi := Len(aDados)
	nPosB9V :=  aScan(aDados, { |x| x[1] ==  "B9V" })
	
	If nPosB9V <> 0
		nI := nPosB9V
		While (nI <= nTamNi) .AND. (aDados[nI,1] <> NIL) .AND. (aDados[nI,1]) == "B9V" .AND. !lErro //pego o primeiro registro da B9V			
				cCodMun := GetDadoArr(aDados, "B9V", "B9V_CODCID")[1] //pego o codigo do municipio do primeiro registro da B9V
				cCodSeqB9V := GetDadoArr(aDados, "B9V", "B9V_CODSEQ")[1] //pego o codigo sequencial do primeiro registro da B9V								
				nPosB9Q :=  aScan(aDados, { |x| x[1] ==  "B9Q" }) 
				If (cCodMun <> NIL) .OR. (cCodSeqB9V <> NIL) //qualquer um desses campos obrigatórios NIL significa que nao achou o item
					nJ := nPosB9Q	
					lAchouEsp := .F. //variavel que quando encontrar 1 especialidade pro local fica .T. 
					While (nJ <= nTamNi) .AND. (aDados[nJ,1] <> NIL) .AND. (aDados[nJ,1] == "B9Q") .AND. !lErro
							aB9Q	 := GetDadoArr(aDados, "B9Q", "B9Q_CODLOC", cCodSeqB9V)	//pego o codigo do local do primeiro registro da B9Q que possui o codigo da B9V					
							If (aB9Q[1] <> NIL .AND. aB9Q[2] <> NIL)
								lAchouEsp  := .T.
								cCodLoc := aB9Q[1] //valor do codigo local
								cSeqGriB9Q := aB9Q[2] //sequencia da linha no grid
								cCodEsp := GetDadoArr(aDados, "B9Q", "B9Q_CODESP",,,cSeqGriB9Q)[1] // valor da especialidade
								dTemFor := GetDadoArr(aDados, "B9Q", "B9Q_TEMFOR",,,cSeqGriB9Q)[1] // pego a data de formaçao da linha igual a do codigo especialidade
								dTemEsp := GetDadoArr(aDados, "B9Q", "B9Q_TEMESP",,,cSeqGriB9Q)[1] // pego a data de especialidade da linha igual a do codigo especialidade
								dTemFor := IIF(dTemFor <> NIL, CTOD(dTemFor), NIL) 
								dTemEsp := IIF(dTemEsp <> NIL, CTOD(dTemEsp), NIL) 
								cDesCid := Posicione("BID",1,xFilial("BID") + cCodMun,"BID_DESCRI")
								cDesEsp := Posicione("BAQ",7,XFILIAL("BAQ") + cCodEsp,"BAQ_DESCRI")
								cStcred := "1"
								lTemFor := .F.
								lTemEsp := .F.
								If lCritica .AND. dTemFor <> nil .AND. dTemEsp <> nil .AND. cTppes == "F"
									If BIC->(MsSeek(xFilial("BIC") + cCodInt + cCodMun))				
										If BIB->(MsSeek(xFilial("BIB") + cCodInt + BIC->BIC_CODREG))				
											If B9I->(MsSeek(xFilial("B9I") + cCodInt + BIB->BIB_CODCLA))				
												If B9J->(MsSeek(xFilial("B9J") + B9I->B9I_CODCLA + cCodEsp))
																				
													nTimeAcad :=  ROUND(((dDataAtu - dTemFor)/365), 0)
													nTimeEsp  :=  ROUND(((dDataAtu - dTemEsp)/365), 0)
																							
													If (nTimeAcad < B9J->B9J_TPACAD).AND. (nTimeEsp < B9J->B9J_TPESPE)											
														lTemFor := .T.
														lTemEsp := .T.
														cStcred := "4"
														nEspInd++
													ElseIf (nTimeAcad < B9J->B9J_TPACAD)																			
														lTemFor := .T.
														lTemEsp := .F.
														cStcred := "4"									
														nEspInd++
													ElseIf (nTimeEsp < B9J->B9J_TPESPE)																						
														lTemFor := .F.
														lTemEsp := .T.
														cStcred := "4"															
														nEspInd++
													Else																						
														lTemFor := .F.
														lTemEsp := .F.
														cStcred := "1"										
													EndIf																					
												EndIf		
											EndIf
										EndIf			
									EndIf
								EndIf
							aAdd(aEsp, {cCodEsp, cDesEsp, cStcred, cCodLoc, cCodMun, cDesCid, B9J->B9J_TPACAD, nTimeAcad, lTemFor, B9J->B9J_TPESPE, nTimeEsp, lTemEsp })
							nEspTot++
							
							//AQUI EU ADICIONO O CAMPO STCRED NA B9Q, PARA SER GRAVADO COMO 1 (pendente c/ a op) ou 4(indeferido)
							//faço isso pois no layout genérico não tem condição para gravar um valor ou outro
							ASIZE( aDados, nTamNi+1 )
							nX := 1
							lEntrou := .F.
							While nX <= nTamNi .AND. !lEntrou
								If ((aDados[nX][1] == "B9Q") .AND. (aDados[nX][4] == cSeqGriB9Q))						
									aIns(aDados, nX)
									aDados[nX] := {"B9Q", "cB9Q_STCRED", cStcred, cSeqGriB9Q, .F., "B9Q_STCRED"}
									lEntrou := .T.
								EndIf
								nX++
							EndDo
						Else					
							If !lAchouEsp//devo sair do laço pois não foi encontrada nenhuma especialidade com o codigo do local informado	
								lErro := .T.
							EndIf
						EndIf		
						nJ++
					EndDo
				EndIf
			nI++
		EndDo
	EndIf	
	
	B9J->(DbCloseArea("B9J"))
	
	B9I->(DbCloseArea("B9I"))
	
	BIB->(DbCloseArea("BIB"))
	
	BIC->(DbCloseArea("BIC"))
	
	If lErro
		aEsp := {}
		lRet := .F.
		cMsg := "Há endereços que não estão relacionados a nenhuma especialidade"
	Else
	
		If (nEspTot > 0 .AND. nEspTot == nEspInd)
			cStcred := "4"
		Else
			cStcred := "1"
			cPassoPad := ""
		EndIf
	
		//AQUI EU ADICIONO O CAMPO STCRED NA B9Y, PARA SER GRAVADO COMO 1 (pendente c/ a op) ou 4(indeferido)
		//faço isso pois no layout genérico não tem condição para gravar um valor ou outro
		lEntrou := .F.	
		nTamNi := Len(aDados)
		For nJ := 1 to nTamNi
	        //se tiver no meio do array                     //se tiver no fim do array
			If ((aDados[nJ][1] <> "B9Y") .AND. !lEntrou) .OR. ((nJ == nTamNi) .AND. (aDados[nJ][1] == "B9Y"))
				aAdd(aAux, {"B9Y", "cB9Y_STCRED", cStcred, "", .F., "B9Y_STCRED"})
				aAdd(aAux, {"B9Y", "cB9Y_PCRED", cPassoPad, "", .F., "B9Y_PCRED"})
				lEntrou := .T.
			EndIf
			
			aAdd(aAux, aDados[nJ])
		Next nJ
		
		aDados := ACLONE(aAux)
	EndIf

	
Return {lRet, cMsg, aEsp}
//-------------------------------------------------------------------
/*/{Protheus.doc} PLCRWEBPOS
Função para pós validar especialidades indeferidas e enviar email. 
@author Karine Riquena Limp
@since 25/05/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLCRWEBPOS()

Local lRet 		:= .T.
Local aArea 		:= GetArea()
Local lCritica	:= GetNewPar("MV_CRICREDP", .F.)
Local cPassoPad	:= GetNewPar("MV_MOTPAD", "")
Local nTamNi   	:= 0
Local nI     		:= 0
Local aEsp			:= IIF(Len(aRet) >=3, aRet[3], {})
Local cEmail		:= ""
Local cAlert		:= ""
Local cMsgAux		:= ""
Local cMsgPad		:= ""
Local cCodInt		:= PLSINTPAD()
Local cCodB2E		:= ""
Local cCodigo 	:= B9Y->B9Y_CODIGO
Local cTppes		:= IIF(Len(Alltrim(B9Y->B9Y_CPFCGC)) == 14, "J","F")
Local cMes			:= ALLTRIM(STRZERO(Month(Date()), 2))
Local cAno			:= SUBSTR(ALLTRIM(STR(Year(Date()))), -2) 
Local cProt		:= ""
Default aRet		:= {} 

cProt := cMes + cAno + cCodigo
                       //     1        2        3        4        5        6          7          8         9           10          11       12    
nTamNi := Len(aEsp)    // {cCodEsp, cDesEsp, cStcred, cCodLoc, cCodMun, cDesMun, nForObrigat, nTimeAcad, lTemFor,   nEspObrigat, nTimeEsp, lTemEsp }
						
	For nI := 1 to nTamNi	
		If ((!lCritica) .OR. (cTppes == "J")) .OR. IIF(Len(aEsp[nI]) > 6, ((!aEsp[nI][9]) .AND. (!aEsp[nI][12])), .T.)
			// cMSG aux serve para receber a mensagem sem quebra de linha e depois ser adicionada com <br />
			// chr(13)+chr(10) para o alert na tela, se não fica aparecendo <br /> no meio da msg
			cMsgAux := "Especialidade " + Alltrim(aEsp[nI][2]) + " EM ANÁLISE com a operadora para o municipio " + aEsp[nI][6]
			cAlert  += cMsgAux + chr(13) + chr(10)
			cEmail  += cMsgAux + "<br />"
		Else
			If aEsp[nI][9] .AND. aEsp[nI][12]
				cMsgPad := "Especialidade " + Alltrim(aEsp[nI][2]) + " INDEFERIDA por tempo de especialidade e tempo acadêmico para o municipio " + Alltrim(aEsp[nI][6])
				cMsgAux := cMsgPad
				cEmail  += cMsgAux + "<br />"
				cAlert  += cMsgAux + chr(13) + chr(10)
				cMsgAux := "Tempo de especialidade informado: " + Alltrim(STR(aEsp[nI][11])) + " ano(s), NECESSÁRIO: " + Alltrim(STR(aEsp[nI][10])) + " ano(s)"
				cEmail  += cMsgAux + "<br />"
				cAlert  += cMsgAux + chr(13) + chr(10)
				cMsgAux := "Tempo de formação informado: "      + Alltrim(STR(aEsp[nI][8]))  + " ano(s), NECESSÁRIO: " + Alltrim(STR(aEsp[nI][7]))  + " ano(s)"
				cEmail  += cMsgAux + "<br /><br />"
				cAlert  += cMsgAux + chr(13) + chr(10) + chr(13) + chr(10)				
			ElseIf aEsp[nI][9]
				cMsgPad := "Especialidade " + Alltrim(aEsp[nI][2]) + " INDEFERIDA por tempo acadêmico para o municipio " + Alltrim(aEsp[nI][6])
				cMsgAux := cMsgPad
				cEmail  += cMsgAux + "<br />"
				cAlert  += cMsgAux + chr(13) + chr(10)
				cMsgAux := "Tempo de formação informado: " + Alltrim(STR(aEsp[nI][8])) + " ano(s), NECESSÁRIO: " + Alltrim(STR(aEsp[nI][7]))  + " ano(s)"
				cEmail  += cMsgAux + "<br /><br />"
				cAlert  += cMsgAux + chr(13) + chr(10) + chr(13) + chr(10)			
			Else
				cMsgPad := "Especialidade " + Alltrim(aEsp[nI][2]) + " INDEFERIDA por tempo de especialidade para o municipio " + Alltrim(aEsp[nI][6])
				cMsgAux := cMsgPad
				cEmail  += cMsgAux + "<br />"
				cAlert  += cMsgAux + chr(13) + chr(10)
				cMsgAux := "Tempo de especialidade informado: " + Alltrim(STR(aEsp[nI][11])) + " ano(s), NECESSÁRIO: " + Alltrim(STR(aEsp[nI][10])) + " ano(s)"
				cEmail  += cMsgAux + "<br /><br />"
				cAlert  += cMsgAux + chr(13) + chr(10) + chr(13) + chr(10)			
			EndIf
			
				cCodB2E := GETSXENUM("B2E", "B2E_CODSEQ")	
				//GRAVAR B2E E B2F
				B2E->(RecLock("B2E", .T.))
					B2E->B2E_FILIAL := XFILIAL("B2E")
					B2E->B2E_CODIGO := B9Y->B9Y_CODIGO
					B2E->B2E_CODPAS := cPassoPad
					B2E->B2E_DATAIN := Date()
					B2E->B2E_STATUS := .T.
					B2E->B2E_DATAFM := Date()
					B2E->B2E_USUARI := "Indeferimento automático portal"
					B2E->B2E_CODSEQ := cCodB2E 
					B2E->B2E_CODINT := cCodInt
					B2E->B2E_CODLOC := aEsp[nI][4]
					B2E->B2E_CODESP := aEsp[nI][1]
					B2E->B2E_ENVIOU := .T.
				B2E->(MsUnlock())
				
				B2F->(RecLock("B2F", .T.))
					B2F->B2F_FILIAL := XFILIAL("B2F")
					B2F->B2F_CODPAS := cPassoPad
					B2F->B2F_DATAIN := Date()
					B2F->B2F_DESCRI := cMsgPad
					B2F->B2F_CODIGO := B9Y->B9Y_CODIGO
					B2F->B2F_CODSEQ := cCodB2E 
					B2F->B2F_CODINT := cCodInt
					B2F->B2F_CODLOC := aEsp[nI][4]
					B2F->B2F_CODESP := aEsp[nI][1]
					B2F->B2F_SEQB2F := GETSXENUM("B2F", "B2F_SEQB2F")
				B2F->(MsUnlock())
				
		EndIf
	Next nI
	
	B9Y->(RecLock("B9Y", .F.))
		  B9Y->B9Y_NROPRO := cProt
	B9Y->(MsUnlock())
	
	//Confirm SX8
	While __lSx8
 		ConfirmSx8()
	End
	
	cEmail += "O protocolo para acompanhamento da solicitação é: " + cProt + chr(13) + chr(10)
	
	If nTamNi > 0 
		EnvMailCre(cEmail, Alltrim(B9Y->B9Y_EMAIL))
	EndIf

RestArea(aArea)

Return cAlert
//-------------------------------------------------------------------
/*/{Protheus.doc} EnvMailCre
Envia email para o candidato do portal. 
@author Karine Riquena Limp
@since 28/05/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function EnvMailCre(cMsg, cDest)
Local cHtm := "\workflow\wfCredPortal.htm"
Local cCodInt := PLSINTPAD()
Local cDescOpe := ""
Local aCposEData := {}

BA0->(DbSelectArea("BA0"))
BA0->(DbSetOrder(1))
If BA0->(MsSeek(xFilial("BA0")+cCodInt))
	cDescOpe := BA0->BA0_NOMINT
EndIf

AADD(aCposEData, {"TEXTO", cMsg})

PlsWFProc("000003", "Email agradecimento solicitação candidato", "Solicitação de credenciamento " + cDescOpe,"", cDest, "", "",cHtm, aCposEData ,.F.,,.T.)
Return 
//-------------------------------------------------------------------
/*/{Protheus.doc} GetDadoArr
Função para pegar dados do array aDados. 
@author Karine Riquena Limp
@since 25/05/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function GetDadoArr(aArray, cTable, cCampo , cValor, lCons, cSeqGrid)
LOCAL nPos 	 := 0
LOCAL xValor	 := ""
LOCAL cSeq     := ""
Default cValor := ""
Default cSeqGrid := ""
Default lCons  := .F.

If !Empty(cValor) .AND. lCons
	nPos := aScan(aArray, { |x| x[1] ==  cTable .AND. x[6] == cCampo .AND. x[3] == cValor })
ElseIf Empty(cValor) .AND. lCons
	nPos := aScan(aArray, { |x| x[1] ==  cTable .AND. x[6] == cCampo })
Else
	If !Empty(cValor) .AND. !lCons
		nPos := aScan(aArray, { |x| x[1] ==  cTable .AND. x[6] == cCampo .AND. x[3] == cValor .AND. !(x[5]) })
	ElseIf !Empty(cSeqGrid)
		nPos := aScan(aArray, { |x| x[1] ==  cTable .AND. x[6] == cCampo .AND. x[4] == cSeqGrid .AND. !(x[5]) })
	Else
		nPos := aScan(aArray, { |x| x[1] ==  cTable .AND. x[6] == cCampo .AND. !(x[5])})
	EndIf
	
	If nPos > 0
		aArray[nPos, 5] := .T.
	EndIf
	
EndIf

If nPos > 0
	xValor := aArray[nPos, 3]
	cSeq   := aArray[nPos, 4]
Else 
	xValor := nil
	cSeq   := nil
Endif

Return ({xValor, cSeq})
//-------------------------------------------------------------------
/*/{Protheus.doc} SetDadoArr
Função para setar dados do array aDados. 
@author Karine Riquena Limp
@since 25/05/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function SetDadoArr(aArray, cTable, cCampo, xValor, cSeqGrid)
LOCAL nPos 	 := 0
Default xValor := ""
Default lCons  := .F.
Default cSeqGrid := ""

If !Empty(cSeqGrid)
	nPos := aScan(aArray, { |x| x[1] ==  cTable .AND. x[6] == cCampo .AND. x[4] == cSeqGrid })
Else
	nPos := aScan(aArray, { |x| x[1] ==  cTable .AND. x[6] == cCampo })	
EndIf

If nPos > 0
	aArray[nPos, 3] := xValor
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSALTCPRE
Função para pré validar informações do credenciamento no cadastro via WEB. 
@author Oscar Zanin
@since 02/07/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSALTCPRE()
//Formato do adados
//[X][Y]
//[X]		= Posição	
//[X][1]	= Alias
//[X][2]	= Campo (variável do portal)
//[X][3]	= Valor (após alterar)
//[X][4]	= Sequencial da Grid (
//[X][5]	= Booleano (Define se altera o outro booleano)
//[X][6]	= Campo (Tabela)
//[X][7]	= RECNO

//Partes Zero e Um movidas para após o processamento dos arrays.

//Parte Zero - Verificar se é necessário gravar a solicitação
/*
*/

/*
Plano... Ver o aLog, aMotivo e aValida, se Len do aLog + Len do aValida + Len do aMotivo > 0, então vai gravar solicitação.
Se o Len do aMotivo for zero, então já grava com o Status "1", se for maior, grava com o Status "0".
*/


//Parte I - Gravar pré solicitação

Local cCodRDA	:= GetDadoArr(aDados, "BAU", 'BAU_CODIGO', , .T.,)[1]
Local cCodInt	:= PLSINTPAD()
Local cCodSeq	:= ""
Local aB2C := {}
Local nPos := 0
Local cCodLay := B90->(B90_SEQUEN)
Local aLog := {}
Local nTamanhoDoaDados := len(aDados)
Local aValida := {}
Local aMotivo := {}
Local cCpoVer	:= ""
Local nJ		:= 1
Local nI		:= 1
Local nCont 	:= 0
Local cCodBAU	:= "" 
Local cChvBAU := "" 	
Local cCodInt := PLSINTPAD()	
Local cChvBB8 := "" 
Local cChvBAX	:= "" 
Local cChaveB	:= ""
Local nRecno	:= 0
Local xValor	
Local cXFilial := xFilial("B7L")
Local cAliTab  := ""
Local cCampo	 := ""
Local cAliChv  := ""
Local cChave   := ""
Local lGravad  := .F.
Local cTipo    := ""
Local nRecReg  := 0
Local dData    := dDataBase
Local cHora    := ""
Local cUser    := ""
Local cAgpReg  := ""
Local cSequen	 := ""
Local nAuxTam  := nTamanhoDoaDados
Local nTamLog  := 0
Local nTamVld	 := 0
Local nTamMot  := 0
Local nMotFim  := 0
Local lExecPos := .F.
Local cCPGCGC  := ""
Local aPos		 := {}
local aPosic	 := {}
Local nNewPos	 := nTamanhoDoaDados

//Para verificar as tabelas envolvidas e
//definir o tipo da solicitação
Local aTipSol	 := {}
Local cTipsol  := ""

//Variáveis para tratar o aCpoOut
Local aTable	 := {}
Local aCpoOut := {}
Local cAliAtu	 := ""
Local cAliAnt	 := ""
Local xRegAnt	 := ""
Local lSxEnum	 := .F.
Local lB		 := .F.
Local nK		 := 1
Local lCpToaDad := .F.
Local aCpToaDad := {}
//Alterar o lGrvDadServ, pois não deve gravar Filial e o aDadServ
//Essa variável é private no web service que chama essa função
lGrvDadServ := .F.

//Tratamento para o aDadServ
//Contexto: A rotina genérica faz a gravação de filial e dos itens do aDadserv automaticamente
//como podemos zerar o aDados de uma tabela, temos que pegar esses valores aqui e adiciona-los
//ao aDados, para tratarmos junto dos itens que vem no aDados. Isso é necessário, pois, em uma
//inclusão, caso tiremos itens do aDados, é gravado um registro com a Filial, outro com o aDadserv
//e, depois da análise, outro com os dados do adados.

//O que é feito: Essa parte que estava no PLGRVLWEB (PLSCADLAY) só ativada se uma variável private
//do Web Service estiver como .T., caso formos trabalhar o aDados e não iremos gravar tudo, devemos
//setar essa variável como .F. para que ele não fazer nada lá, pois aqui já iremos tomar as providências

//Montar o aTable (array sobre as tabelas que compõe o layout)
B7C->(DbSetOrder(2))
B7C->(MsSeek(xFilial("B7C") + B90->B90_SEQUEN ))

While !B7C->(Eof()) .AND. xFilial("B7C") + B7C->B7C_SEQB90 == xFilial("B7C") + B90->B90_SEQUEN 
	AADD(aTable, { B7C->B7C_ALIAS, B7C->B7C_ORDEM , B7C->B7C_GRUPAI, B7C->B7C_TIPO} )
	B7C->(DbSkip())					 
EndDo

B91->(DbSetOrder(1))
B91->(MsSeek(xFilial("B91") + B90->B90_SEQUEN + aTable[nI, 2] ))

For nK	:= 1 To Len(aTable)

	//montar o aCpoOut, que tem os dados dos campos com gravação automática, que não vão pra tela
	While !B91->(Eof()) .AND. xFilial("B91") + B91->B91_SEQUEN + B91->B91_GRUPO == xFilial("B91") + B90->B90_SEQUEN + aTable[nK, 2]
		If !B91->B91_VISUAL .AND. (!Empty(B91->B91_DADSRV) .OR. B91->B91_TIPO == "S")// esse campo sera executado macro para pegar o valor
			AADD(aCpoOut, {B91->B91_CAMPO, B91->B91_DADSRV, B91->B91_TIPO})						
		EndIf
		B91->(DbSkip()) 
	EndDo
	For nI := 1 To nTamanhoDoaDados
		
		//Pode haver aDados[nI] com 6 ou 7 posições
		IF(Len(aDados[nI]) >= 7)
			
			//Verificamos se a posição atual e anterior pertencem ao mesmo registro
			//Damos o retorno na variável lB
			If (ValType(xRegAnt) <> ValType(aDados[nI][7]))
				If ValType(xRegAnt) == "U"
					lB := IIF(ValType(aDados[nI][7]) == "N", .F., xRegAnt <> aDados[nI][7])
				else
					lB := IIF(ValType(aDados[nI][7]) == "U", xRegAnt <> 0, .F.)
				EndIf
			EndIF
		else
			aSize(aDados[nI], 7)
			If (ValType(xRegAnt) <> ValType(aDados[nI][7]))
				If ValType(xRegAnt) == "U"
					lB := IIF(ValType(aDados[nI][7]) == "N", .T., xRegAnt <> aDados[nI][7])
				else
					lB := IIF(ValType(aDados[nI][7]) == "U", xRegAnt <> 0, .T.)
				EndIf
			EndIF
		EndIf
		
		//Se for o primeiro registro, ou o Aliant for diferente do alias atual e o lB
		If nI == 1 .OR. ( cAliAnt <> aDados[nI][1] .AND. lB)
			cAliAnt := aDados[nI][1]
			xRegAnt := aDados[nI][7]
			cAliAtu := aDados[nI][1]
			
			//Verificamos o aCpoOut
			For nJ := 1 To Len(aCpoOut)
				//Se o Alias for igual E o Alias já não tiver sido verificado, gravamos o que seria o aDadServ no aDados
				If cAliAtu == Left(aCpoOut[nJ,1], Len(cAliAtu)) .AND. (Ascan(aCpToaDad, cAliAtu) == 0)
					lSxEnum := (("GETSX8NUM" $ UPPER(aCpoOut[nJ,2])) .OR. ("GETSXENUM" $ UPPER(aCpoOut[nJ,2]))) // Faço isso pra poder confirmar depois o sequencial
					If !lSxEnum .AND. aTable[nK, 4] <> "G" .AND. aCpoOut[nJ, 3] == "S" .AND. Empty(aCpoOut[nJ,2]) // Aqui eu verifico se é um sequencial e nao informada a função
						lSxEnum := .T.
						Aadd(aDados, { cAliAtu, "c"+aCpoOut[nJ,1], &("GETSXENUM('"+ cAliAtu +"','" + aCpoOut[nJ,1] + "')"), aDados[nI][4], aDados[nI][5], aCpoOut[nJ,1], aDados[nI][7]} )
					ElseIf lSxEnum 
						Aadd(aDados, { cAliAtu, "c"+aCpoOut[nJ,1], &(aCpoOut[nJ,2])	, aDados[nI][4], aDados[nI][5], aCpoOut[nJ,1], aDados[nI][7]} )
					EndIf
					If !lSxEnum
						Aadd(aDados, { cAliAtu, "c"+aCpoOut[nJ,1], &(aCpoOut[nJ,2])	, aDados[nI][4], aDados[nI][5], aCpoOut[nJ,1], aDados[nI][7]} )			
					EndIf
					//Marcamos a variável como .T. para fazer o tratamento se o alias já foi, para não gravar vários no aDados
					lCpToaDad := .T.
				EndIf
			Next
			
			//Adicionamos o
			If lCpToaDad
				Aadd(aCpToaDad, cAliAtu)
				lCpToaDad := .F.
			EndIF
			
			If lSxEnum
				&(cAliAtu+"->(ConfirmSX8())") // confirmo a utilização do sequencial
			EndIf
		EndIF
	Next
Next
//Formato do adados
//[X][Y]
//[X]		= Posição	
//[X][1]	= Alias
//[X][2]	= Campo (variável do portal)
//[X][3]	= Valor (após alterar)
//[X][4]	= Sequencial da Grid (
//[X][5]	= Booleano (Define se altera o outro booleano)
//[X][6]	= Campo (Tabela)
//[X][7]	= RECNO

//Gerar Sequencial
cCodSeq := B98->(GetSX8num("B98", "B98_CODSEQ"))
		B98->(ConfirmSX8())
		
//Parte II - Marcar aDados com LOG, VALIDA e MOTIVO
/*
Adicionamos as posições [X](Log), [Y](Valida) e [Z](Motivo) no array aDados
para tratarmos posteriormente
B90 já chegam aqui posicionadas (teoricamente)
cLayout é uma variável private

primeiro adicionamos os campos que existem na B2C no aB2C...
daí começa a mágica..
Depois criamos mais 3 posições no aDados (deixando ele com 9 posições)
a posição 10 irá receber o valor da variável LOG
a posição 8 irá receber o valor da variável VALIDA
a posição 9 irá receber o valor da variável MOTIVO
*/

B2C->(DbSelectArea("B2C"))
B2C->(DbSetOrder(1))

B2C->(MsSeek(xFilial("B2C")+cCodLay))

//Busca na B2C todos os itens correspondentes ao código do layout
While !(B2C->(EoF())) .AND. B2C->(B2C_FILIAL) == xFilial("B2C") .AND. B2C->(B2C_SEQB90) == cCodLay

	Aadd(aB2C, {B2C->B2C_VAR, B2C->B2C_VALOR, B2C->B2C_CMPB91})
	B2C->(DbSkip())
EndDo

B2C->(DbCloseArea())

cCPFCGC := Alltrim(GetDadoArr(aDados, "B9Y", "B9Y_CPFCGC",,.T.)[1])
cCPFCGC := StrTran(cCPFCGC,'.','')  
cCPFCGC := StrTran(cCPFCGC,'-','')
cCPFCGC := StrTran(cCPFCGC,'/','')	
SetDadoArr(@aDados, "B9Y", "B9Y_CPFCGC", cCPFCGC)

For nI := 1 To Len(aDados) //Percorre o aDados
	
	nJ := 1
	aSize(aDados[nI], 10)
	cCpoVer := aDados[nI][2]
	
	While ( (nJ <= (Len(aB2C)) ) .AND. (nCont <= 2) )
		
		If (AllTrim(aB2C[nJ][3]) == cCpoVer)
			
			Do Case
			
				Case (Alltrim(aB2C[nJ][1]) == "LOG")		
					aDados[nI][10] := AllTrim(aB2C[nJ][2])
					nCont++
				
				Case (AllTrim(aB2C[nJ][1]) == "VALIDA")
					aDados[nI][8] := Alltrim(aB2C[nJ][2])
					nCont++
				
				Case (AllTrim(aB2C[nJ][1]) == "MOTIVO")
					aDados[nI][9]	:= AllTrim(aB2C[nJ][2])
					nCont++

			EndCase
		EndIf
		nJ++
	EndDo
	
	nCont := 0
Next

//Parte V - Montar array de motivos (ou documentos, se der já)
/*
gravamos todos com a posição [Z] Motivo do array aDados no array aMotivo
Verificar se há motivos repetidos e gravar só um.
*/

For nI := 1 To Len(aDados)
	If ( ValType(aDados[nI][9]) <> "U" ) .AND. !(Empty(aDados[nI][9]))
		If ((aScan(aMotivo,aDados[nI][9])) == 0)
			Aadd(aMotivo, adados[nI])
		EndIF
	EndIf
Next

//Parte IV - Separa Array de validação (que não será gravado)
/*
gravamos todos com a posição [Y] Valida do array aDados no array aValdia
e retiramos essas posições do aDados.
*/

For nI := 1 To Len(aDados) //nAuxTam

	If  ( ValType(aDados[nI][8]) <> "U" ) .and. !(Empty(AllTrim(aDados[nI][8])))
		Aadd(aValida, aDados[nI])
		Aadd(aPosic, nI)
		nAuxTam--
	else
		If ValType(aDados[nI][7]) == "U" //Se foi inclusão de registro, vai para análise
			Aadd(aValida, aDados[nI])
			Aadd(aPosic, nI)
			nAuxTam--
		EndIf
	EndIf	
Next

For nI := 1 To Len(aPosic)
	
	Adel(aDados, aPosic[nI])
	
Next

Asize(aDados, nAuxTam)

//Parte III - Monta array do log
/*
gravamos todos com a Posição [X] Log do array aDados no array aLog
*/

For nI := 1 To nAuxTam
	If ( ValType(aDados[nI][10]) <> "U" ) .AND. !(Empty(aDados[nI][10]))
		Aadd(aLog, aDados[nI])
	EndIf
Next

//Fase 2 -> Ordenar o aLog, por tabela e sequencial
Asort(aLog, , , { |x, y| x[1]+x[4] < y[1]+y[4]})

nTamLog := Len(aLog)

//Fase 3 -> Ver cada elemento e adicionar o Recno e valor anterior

//No Array aLog
For nI := 1 To nTamLog
	
	aSize(aLog[nI], 12)
	
	xValor := ""
	
	If aLog[nI][1] == "BAU"
		If (ValType(aLog[nI][7]) == "N")
			BAU->(DbGoTo(aLog[nI][7]))
				xValor	:= BAU->(&(aLog[nI][6]))
		EndIF
	EndIf
	
	If aLog[nI][1] == "BB8"
		If (ValType(aLog[nI][7]) == "N")
			BB8->(DbGoTo(aLog[nI][7]))
				xValor	:= BB8->(&(aLog[nI][6]))
		EndIF
	EndIf
	
	If aLog[nI][1] == "BAX"
		If (ValType(aLog[nI][7]) == "N")
			BAX->(DbGoTo(aLog[nI][7]))
				xValor	:= BAX->(&(aLog[nI][6]))
		EndIF
	EndIF
	
	If ( ValType(xValor) == "N" )
		xValor := Str(xValor)
	ElseIf ( ValType(xValor) == "D" )
		xValor := DToS(xValor)
	EndIF
	
	aLog[nI][12] := AllTrim(xValor)
Next

nTamVld := Len(aValida)

//No Array aValida
For nI := 1 To nTamVld
	
	aSize(aValida[nI], 12)
	
	xValor := ""
	
	If aValida[nI][1] == "BAU"
		If (ValType(aValida[nI][7]) == "N")
			BAU->(DbGoTo(aValida[nI][7]))
				xValor	:= BAU->(&(aValida[nI][6]))
		EndIF
	EndIf
	
	If aValida[nI][1] == "BB8"
		If (ValType(aValida[nI][7]) == "N")
			BB8->(DbGoTo(aValida[nI][7]))
				xValor	:= BB8->(&(aValida[nI][6]))
		EndIF
	EndIf
	
	If aValida[nI][1] == "BAX"
		If (ValType(aValida[nI][7]) == "N")
			BAX->(DbGoTo(aValida[nI][7]))
				xValor	:= BAX->(&(aValida[nI][6]))
		EndIF
	EndIF
	
	If ( ValType(xValor) == "N" )
		xValor := Str(xValor)
	ElseIf ( ValType(xValor) == "D" )
		xValor := DToS(xValor)
	EndIF
	
	aValida[nI][12] := AllTrim(xValor)
Next

nTamMot := Len(aMotivo)

//No Array aMotivo
For nI := 1 To nTamMot
	
	aSize(aMotivo[nI], 12)
	
	xValor := ""
	
	If aMotivo[nI][1] == "BAU"
		If (ValType(aMotivo[nI][7]) == "N")
			BAU->(DbGoTo(aMotivo[nI][7]))
				xValor	:= BAU->(&(aMotivo[nI][6]))
		EndIf
	EndIf
	
	If aMotivo[nI][1] == "BB8"
		If (ValType(aMotivo[nI][7]) == "N")
			BB8->(DbGoTo(aMotivo[nI][7]))
				xValor	:= BB8->(&(aMotivo[nI][6]))
		EndIF
	EndIf
	
	If aMotivo[nI][1] == "BAX"
		If (ValType(aMotivo[nI][7]) == "N")
			BAX->(DbGoTo(aMotivo[nI][7]))
				xValor	:= BAX->(&(aMotivo[nI][6]))
		EndIf
	EndIF
	
	If ( ValType(xValor) == "N" )
		xValor := Str(xValor)
	ElseIf ( ValType(xValor) == "D" )
		xValor := DToS(xValor)
	EndIF
	
	aMotivo[nI][12] := AllTrim(xValor)
	
	If AllTrim(aMotivo[nI][3]) <> aMotivo[nI][12]
		Aadd(aPos, aMotivo[nI])
	EndIF
Next

//Parte VI - Gravar tabela de log
/*
agora que temos o cCodSeq e todos os outros dados, podemos gravar a tabela de Log
Campos que devemos salvar:
B7L_FILIAL
B7L_SEQUEN
B7L_ALIAS
B7L_CAMPO
B7L_ALIACH
B7L_CHAVE
B7L_VLANT
B7L_VLPOS
B7L_GRAVAD
B7L_TIPO
B7L_RECREG
B7L_DATA
B7L_HORA
B7L_USER
B7L_CHVREG
*/

//Array aLog
For nI := 1 To nTamLog
	
	If aLog[nI][12] <> AllTrim(aLog[nI][3])
		B7L->(Reclock("B7L", .T.))
			B7L->B7L_FILIAL := cXFilial
	
			cSequen := GetSXENum("B7L","B7L_SEQUEN")
				ConfirmSx8()
			
			B7L->B7L_SEQUEN 	:= cSequen
			B7L->B7L_ALIAS	:= aLog[nI][1]
			B7L->B7L_CAMPO	:= aLog[nI][6]
			B7L->B7L_ALIACH	:= "B98"
			B7L->B7L_CHAVE	:= cCodSeq
			B7L->B7L_VLANT	:= aLog[nI][12]
			B7L->B7L_VLPOS	:= aLog[nI][3]
			B7L->B7L_GRAVAD	:= .T.	//Verificar
			
			If ( ValType(aLog[nI][7]) == "N" )
				cTipo := "2"
			else
				cTipo := "1"
			EndIF
			
			B7L->B7L_TIPO		:= cTipo
			
			If (ValType(aLog[nI][7]) == "N")
				B7L->B7L_RECREG	:= AllTrim(Str(aLog[nI][7]))
			else
				B7L->B7L_RECREG	:= "0"
			EndIF
			
			B7L->B7L_DATA		:= dData
			B7L->B7L_HORA		:= Left(Time(),5)
			B7L->B7L_USER		:= cLogin
			B7L->B7L_CHVREG	:= aLog[nI][4]
		B7L->(MsUnlock())
	EndIF
Next

//Array a Valida
For nI := 1 To nTamVld
	
	If Ascan(aTipSol, aValida[nI][1]) == 0
		Aadd(aTipSol, aValida[nI][1])
	EndIf
	
	If aValida[nI][12] <> AllTrim(aValida[nI][3])
		B7L->(Reclock("B7L", .T.))
			B7L->B7L_FILIAL := cXFilial
	
			cSequen := GetSXENum("B7L","B7L_SEQUEN")
				ConfirmSx8()
			
			B7L->B7L_SEQUEN 	:= cSequen
			B7L->B7L_ALIAS	:= aValida[nI][1]
			B7L->B7L_CAMPO	:= aValida[nI][6]
			B7L->B7L_ALIACH	:= "B98"
			B7L->B7L_CHAVE	:= cCodSeq
			B7L->B7L_VLANT	:= aValida[nI][12]
			B7L->B7L_VLPOS	:= aValida[nI][3]
			B7L->B7L_GRAVAD	:= .F.	//Verificar
			
			If ( ValType(aValida[nI][7]) == "N" )
				cTipo := "2"
			else
				cTipo := "1"
			EndIF
			
			B7L->B7L_TIPO		:= cTipo
			
			If ValType(aValida[nI][7]) == "N"
				B7L->B7L_RECREG	:= AllTrim(Str(aValida[nI][7]))
			else
				B7L->B7L_RECREG	:= "0"
			EndIF
			
			B7L->B7L_DATA		:= dData
			B7L->B7L_HORA		:= Left(Time(),5)
			B7L->B7L_USER		:= cLogin
			B7L->B7L_CHVREG	:= aValida[nI][4]
		B7L->(MsUnlock())
	EndIF
Next

If Len(aTipSol) > 1
	cTipSol := '6'
else
	If Len(aTipSol) > 0
		Do Case
		Case aTipSol[1] == "BAX"
			cTipSol := '2'
		Case aTipSol[1] == "BB8"
			cTipSol := '3'
		OtherWise
			cTipSol := '1'
		End Case
	EndIf
EndIf

//Parte que era a I + a Parte Zero
If ( (Len(aLog) + Len(aValida) + Len(aMotivo)) > 0 )
	B98->(DbSelectArea("B98"))
	B98->(DbSetOrder(1))
	
	B98->(RecLock("B98", .T.))	
		If Len(aPos) > 0	
			B98->(B98_STATUS) := "0" //Solicitação com documentos pendentes
			lExecPos := .T.
		else
			B98->(B98_STATUS) := "1" //Solicitação não necessita documentos
			lExecPos := .F.
		EndIF
		
	B98->(B98_FILIAL)	:= xFilial("B98")
	B98->(B98_CODSEQ)	:= cCodSeq
	B98->(B98_CODIGO)	:= StrZero( Val(cCodRDA), 6)
	B98->(B98_CODSOL)	:= GetNewPar("MV_PLSB98", "999999")
	B98->(B98_CODINT)	:= cCodInt
	B98->(B98_TIPSOL)	:= cTipSol
	B98->(B98_DATA)	:= dDataBase
	
	B98->(MsUnlock())
EndIF

//Parte VII - Caso o tamanho do aMotivo seja Maior que Zero... 
/*
Tem que chamar o APH do cara selecionar os documentos na Pos..
*/

return {.T., "", cCodSeq, aPos, lExecPos, cCodRDA, "1"}

//-------------------------------------------------------------------
/*/{Protheus.doc} PLALBPRE
Valida se Gera B7L para os campos flagados como VALIDA
@author Roberto Vanderlei
@since 04/12/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLALBPRE(lAltSolBen, lAltSolB7L)
//Formato do adados
//[X][Y]
//[X]		= Posição
//[X][1]	= Alias
//[X][2]	= Campo (variável do portal)
//[X][3]	= Valor (após alterar)
//[X][4]	= Sequencial da Grid (
//[X][5]	= Booleano (Define se altera o outro booleano)
//[X][6]	= Campo (Tabela)
//[X][7]	= RECNO

local aB2C := {}
Local cCodLay := B90->(B90_SEQUEN)
local lRet := .T.
local nI
local nJ
local cCpoVer
local aLog := {}
local nTamLog
local aMotivo := {}
local nTamMot
local aPos := {}
local aValida := {}
local nAuxTam := len(aDados)
local nTamVld
local cCodSeq
Local dData    := dDataBase
local cTipo
local lExecPos
local nCont := 0
Local cXFilial := xFilial("B7L")
local cCodFam
local cCodInt
local cCodEmp
local cMatricPrt
local cMotAnt
local cMotAtu
local nRecBBA
Local aDataAux := Separa(xDataAux, "|")
Local lBBAapr	:= .T.
Local nX		:= 0
Local xAux	
Local aB7lCont	:= {{},{}}
Local nB7LAux	:= 0
Local nContent	:= 1
Local lExisteBeneficiario := .F.

Default lAltSolBen := .F.
Default lAltSolB7L := .F.

If !lAltSolBen .And. !lAltSolB7L
	cCodSeq := BBA->(GetSX8num("BBA", "BBA_CODSEQ"))
	BBA->(ConfirmSX8())
EndIf

B2C->(DbSelectArea("B2C"))
B2C->(DbSetOrder(1))

B2C->(MsSeek(xFilial("B2C")+cCodLay))

//Busca na B2C todos os itens correspondentes ao código do layout
While !(B2C->(EoF())) .AND. B2C->(B2C_FILIAL) == xFilial("B2C") .AND. B2C->(B2C_SEQB90) == cCodLay
	
	Aadd(aB2C, {B2C->B2C_VAR, B2C->B2C_VALOR, B2C->B2C_CMPB91})
	B2C->(DbSkip())
EndDo

B2C->(DbCloseArea())

If ExistBlock("PLALBPRED")
	aDados := ExecBlock("PLALBPRED",.F.,.F.,{aDados}) // Ponto de Entrada que permite a manipulação da variável aDados
	nAuxTam:= len(aDados)
Endif

For nI := 1 To Len(aDados) //Percorre o aDados
	
	nJ := 1
	
	aSize(aDados[nI], 10)
	
	cCpoVer := aDados[nI][2]
	
	While ( (nJ <= (Len(aB2C)) ) .AND. (nCont <= 2) )
		
		If (AllTrim(aB2C[nJ][3]) == cCpoVer)
			
			Do Case
				
			Case (Alltrim(aB2C[nJ][1]) == "LOG")
				aDados[nI][10] := AllTrim(aB2C[nJ][2])
				nCont++
				
			Case (AllTrim(aB2C[nJ][1]) == "VALIDA")
				aDados[nI][8] := Alltrim(aB2C[nJ][2])
				nCont++
				
			Case (AllTrim(aB2C[nJ][1]) == "MOTIVO")
				aDados[nI][9]	:= AllTrim(aB2C[nJ][2])
				nCont++
			EndCase
		EndIf
		nJ++
	EndDo
	
	nCont := 0
Next

For nI := 1 To len(aDados)
	If ( ValType(aDados[nI][10]) <> "U" ) .AND. !(Empty(aDados[nI][10])) .and. (( ValType(aDados[nI][8]) = "U" ) .or. (Empty(aDados[nI][8])))
		Aadd(aLog, aDados[nI])
	EndIf
Next

//Fase 2 -> Ordenar o aLog, por tabela e sequencial
Asort(aLog, , , { |x, y| x[1]+x[4] < y[1]+y[4]})

nTamLog := Len(aLog)

//No Array aLog
For nI := 1 To nTamLog
	
	aSize(aLog[nI], 12)
	
	xValor := ""
	
	If aLog[nI][1] == "BA1"
		If (ValType(aLog[nI][7]) == "N")
			BA1->(DbGoTo(aLog[nI][7]))
			xValor	:= BA1->(&(aLog[nI][6]))
		EndIF
	EndIf
	
	If ( ValType(xValor) == "N" )
		xValor := Str(xValor)
	ElseIf ( ValType(xValor) == "D" )
		Set(_SET_DATEFORMAT,'dd/mm/yyyy')
		xValor := DToS(xValor)
		Set(_SET_DATEFORMAT,'dd/mm/yy')
	EndIF
	
	aLog[nI][12] := AllTrim(xValor)
Next

For nI := 1 To Len(aDados)
	If ( ValType(aDados[nI][9]) <> "U" ) .AND. !(Empty(aDados[nI][9]))
		If ((aScan(aMotivo,aDados[nI][9])) == 0)
			Aadd(aMotivo, adados[nI])
		EndIF
	EndIf
Next

nTamMot := Len(aMotivo)

//No Array aMotivo
For nI := 1 To nTamMot
	
	aSize(aMotivo[nI], 12)
	
	xValor := ""
	
	If aMotivo[nI][1] == "BA1"
		If (ValType(aMotivo[nI][7]) == "N")
			BA1->(DbGoTo(aMotivo[nI][7]))
			xValor	:= BA1->(&(aMotivo[nI][6]))
		EndIf
	EndIf
	
	If ( ValType(xValor) == "N" )
		xValor := Str(xValor)
	ElseIf ( ValType(xValor) == "D" )
		xValor := DToS(xValor)
		aMotivo[nI,3] := dtos(ctod(aMotivo[nI,3]))
	EndIF
	
	aMotivo[nI][12] := AllTrim(xValor)
	
	cMotAnt := AllTrim(aMotivo[nI][3])
	cMotAtu := AllTrim(aMotivo[nI][12])
	
	If !(cMotAnt == cMotAtu)
		Aadd(aPos, aMotivo[nI])
	EndIF
Next

For nI := 1 To Len(aDados) //nAuxTam
	If ( ValType(aDados[nI]) <> "U" ) .and. ( ValType(aDados[nI][8]) <> "U" ) .AND. !(Empty(AllTrim(aDados[nI][8])))
		Aadd(aValida, aDados[nI])
		Adel(aDados, nI)
		nAuxTam--
	endif
Next

Asize(aDados, nAuxTam)

nTamVld := Len(aValida)

//No Array aValida
For nI := 1 To nTamVld
	
	aSize(aValida[nI], 12)
	
	xValor := ""
	
	If aValida[nI][1] == "BA1"
		If (ValType(aValida[nI][7]) == "N")
			BA1->(DbGoTo(aValida[nI][7]))
			xValor	:= BA1->(&(aValida[nI][6]))
		EndIF
	EndIf
	
	If ( ValType(xValor) == "N" )
		xValor := Str(xValor)
	ElseIf ( ValType(xValor) == "D" )
		xValor := DToS(xValor)
		aValida[nI,3] := dtos(ctod(aValida[nI,3]))
	EndIF
	
	aValida[nI][12] := AllTrim(xValor)
Next

If !lAltSolBen .And. !lAltSolB7L // Consulta de Solicitação de Alteração/Inclusão já possui as tabelas B2N e B7L gravadas 
	//Array aLog
	For nI := 1 To nTamLog
		
		If aLog[nI][12] <> AllTrim(aLog[nI][3])
			B7L->(Reclock("B7L", .T.))
				B7L->B7L_FILIAL := cXFilial
				
				cSequen := GetSXENum("B7L","B7L_SEQUEN")
				ConfirmSx8()
				
				B7L->B7L_SEQUEN 	:= cSequen
				B7L->B7L_ALIAS	:= aLog[nI][1]
				B7L->B7L_CAMPO	:= aLog[nI][6]
				B7L->B7L_ALIACH	:= "BBA"
				B7L->B7L_CHAVE	:= cCodSeq
				B7L->B7L_VLANT	:= aLog[nI][12]
				B7L->B7L_VLPOS	:= aLog[nI][3]
				B7L->B7L_GRAVAD	:= .T.	//Verificar
				
				If ( ValType(aLog[nI][7]) == "N" )
					cTipo := "2"
				else
					cTipo := "1"
				EndIF
				
				B7L->B7L_TIPO		:= cTipo
				
				If (ValType(aLog[nI][7]) == "N")
					B7L->B7L_RECREG	:= AllTrim(Str(aLog[nI][7]))
				else
					B7L->B7L_RECREG	:= "0"
				EndIF
				
				B7L->B7L_DATA		:= dData
				B7L->B7L_HORA		:= Left(Time(),5)
				B7L->B7L_USER		:= cLogin
				B7L->B7L_CHVREG	:= aLog[nI][4]
			B7L->(MsUnlock())
		EndIF
	Next

	//Array a Valida
	For nI := 1 To nTamVld
		
		If AllTrim(aValida[nI][12]) <> AllTrim(aValida[nI][3]) .Or. AllTrim(aValida[nI][3]) <> AllTrim(aValida[nI][12])
			
			lBBAapr := .F.
			
			B7L->(Reclock("B7L", .T.))
			B7L->B7L_FILIAL := cXFilial
			
			cSequen := GetSXENum("B7L","B7L_SEQUEN")
			ConfirmSx8()
			
			B7L->B7L_SEQUEN 	:= cSequen
			B7L->B7L_ALIAS	:= aValida[nI][1]
			B7L->B7L_CAMPO	:= aValida[nI][6]
			B7L->B7L_ALIACH	:= "BBA"
			B7L->B7L_CHAVE	:= cCodSeq
			B7L->B7L_VLANT	:= aValida[nI][12]
			B7L->B7L_VLPOS	:= aValida[nI][3]
			B7L->B7L_GRAVAD	:= .F.	//Verificar
			
			If ( ValType(aValida[nI][7]) == "N" )
				cTipo := "2"
			else
				cTipo := "1"
			EndIF
			
			B7L->B7L_TIPO		:= cTipo
			
			If ValType(aValida[nI][7]) == "N"
				B7L->B7L_RECREG	:= AllTrim(Str(aValida[nI][7]))
			else
				B7L->B7L_RECREG	:= "0"
			EndIF
			
			B7L->B7L_DATA		:= dData
			B7L->B7L_HORA		:= Left(Time(),5)
			B7L->B7L_USER		:= cLogin
			B7L->B7L_CHVREG	:= aValida[nI][4]
			B7L->(MsUnlock())
		EndIF
	Next
EndIf

If cTpPortal == "3" //Beneficiário
	
	cCodFam    := SubStr(cMatric, 1,14)
	cCodInt    := SubStr(cMatric, 1,4)
	cCodEmp    := SubStr(cMatric, 5,4)
	cMatricPrt := SubStr(cMatric, 9,6)
	
	cSQL := "SELECT BA3_CODINT, BA3_CODEMP, BA3_CONEMP, BA3_MATRIC, BA3_VERCON, BA3_SUBCON, BA3_VERSUB, BA3_VERSAO, BA3_CODPLA "
	cSQL += " FROM " + RetSQLName("BA3")
	cSQL += " WHERE BA3_CODINT = '" + cCodInt + "' AND BA3_CODEMP = '" + cCodEmp + "' AND BA3_MATRIC = '" + cMatricPrt + "' AND BA3_CODEMP = '" + cCodEmp + "' AND BA3_FILIAL = '" + xFilial("BA3") + "'"
	cSQL += " AND D_E_L_E_T_ = ''"
	
	If Select("TRBBA3") > 0
		TRBBA3->(DbCloseArea())
	EndIf
	
	TCQUERY cSQL New Alias "TRBBA3"
	
	TRBBA3->(DbGoTop())
else
	if cTpPortal = "2"
		
		cSQL := "SELECT B40_CODEMP, B40_NUMCON, B40_VERCON, B40_SUBCON, B40_VERSUB "
		cSQL += " FROM " + RetSQLName("B40")
		cSQL += " WHERE B40_CODUSR = (SELECT BSW_CODUSR FROM " +  RetSQLName("BSW") + " where BSW_LOGUSR = '"
		cSQL += cLogin + "') AND "
		cSQL += " D_E_L_E_T_ = ''"

		If Select("TRBB40") > 0
			TRBB40->(DbCloseArea())
		EndIf
		
		dbUseArea(.t.,"TOPCONN",tcGenQry(,,changeQuery(cSQL)),"TRBB40",.f.,.t.) 

	endif
endif

If lAltSolBen
		aDataAux[1] := Iif(ValType(aDataAux[1]) == "N", aDataAux[1], Val(aDataAux[1]))
		B2N->(DBGoTo(aDataAux[1]))
		BBA->(DbSetOrder(1))
		If BBA->(MsSeek(xFilial("BBA")+Alltrim(B2N->B2N_PROTOC)))
			cCodSeq := BBA->BBA_CODSEQ 
		EndIf

		B2N->(RecLock("B2N", .F.))
			For nX := 1 to Len(aDados)

				If ExistCpo("SX3",aDados[nX][6],2 , , .F.) .And. AllTrim(aDados[nX][6]) != "B2N_PROTOC"
					If substr(aDados[nX][2],1,1) == "c"
						&(aDados[nX][1]+"->"+aDados[nX][6]) := AllTrim(aDados[nX][3])
					ElseIf substr(aDados[nX][2],1,1) == "d"	
						&(aDados[nX][1]+"->"+aDados[nX][6]) := CTOD(AllTrim(aDados[nX][3]))
					ElseIf substr(aDados[nX][2],1,1) == "n"
						&(aDados[nX][1]+"->"+aDados[nX][6]) := Val(AllTrim(aDados[nX][3]))
					EndIf
				EndIf
			Next
		B2N->(MsUnlock())
ElseIf lAltSolB7L
	
	B7L->(DbSetOrder(3))
	If B7L->(MsSeek(xFilial("B7L")+aDataAux[1]))
		BBA->(DbSetOrder(1))
		If BBA->(MsSeek(xFilial("BBA")+Alltrim(B7L->B7L_CHAVE)))
			cCodSeq := BBA->BBA_CODSEQ 
		EndIf

		BA1->(DbGoTo(Val(B7L->B7L_RECREG)))
		If BA1->(!EOF())
			lExisteBeneficiario := .T.
		EndIf
	EndIf

	For nX := 1 to Len(aDados)
		
		If B7L->(MsSeek(xFilial("B7L")+PADR(aDataAux[1], TamSX3("B7L_CHAVE")[1]) + aDados[nX][6]))
			B7L->(RecLock("B7L", .F.))
				If substr(aDados[nX][2],1,1) == "c"
					B7L->B7L_VLPOS := AllTrim(aDados[nX][3])
				ElseIf substr(aDados[nX][2],1,1) == "d"	
					B7L->B7L_VLPOS := CTOD(AllTrim(aDados[nX][3]))
				ElseIf substr(aDados[nX][2],1,1) == "n"
					B7L->B7L_VLPOS := Val(AllTrim(aDados[nX][3]))
				EndIf
			B7L->(MsUnlock())
		Else
			If lExisteBeneficiario
				BA1->(RecLock("BA1", .F.))
				If substr(aDados[nX][2],1,1) == "c"
					&(aDados[nX][1]+"->"+aDados[nX][6]) := AllTrim(aDados[nX][3])
				ElseIf substr(aDados[nX][2],1,1) == "d"	
					&(aDados[nX][1]+"->"+aDados[nX][6]) := CTOD(AllTrim(aDados[nX][3]))
				ElseIf substr(aDados[nX][2],1,1) == "n"
					&(aDados[nX][1]+"->"+aDados[nX][6]) := Val(AllTrim(aDados[nX][3]))
				EndIf
				BA1->(MsUnlock())
			EndIf
		EndIf
	Next
Else
	BBA->(RecLock("BBA", .T.))  
		BBA->BBA_FILIAL := xFilial("BBA")
		BBA->BBA_CODSEQ := cCodSeq
		BBA->BBA_TIPMAN := "2" //Essa função é a De alteração, o TIPMAN será sempre 2 -> Alteração
		BBA->BBA_TIPSOL := "2"

		If Len(aPos) > 0 
			BBA->(BBA_STATUS) := "1" //Solicitação com documentos pendentes
			lExecPos := .T.
		else
			if !(lBBAapr)
				BBA->(BBA_STATUS) := "2" //Solicitação não necessita documentos
			else
				BBA->(BBA_STATUS) := "7" //Solicitação aprovada automaticamente
			EndIf
			lExecPos := .F.
		EndIF

		If cTpPortal == "2" 
			BBA->BBA_EMPBEN := Posicione("BA1",2,xFilial("BA1") + aDataAux[2],"BA1_NOMUSR") 
			
			cCdPlano  := Posicione("BA1",2,xFilial("BA1") + aDataAux[2],"BA1_CODPLA") 
			cCdVersao := Posicione("BA1",2,xFilial("BA1") + aDataAux[2],"BA1_VERSAO") 
			
			If EMPTY(cCdPlano)

				cCdPlano  := Posicione("BA3",1,xFilial("BA3") + SubStr(cMatric, 1,14),"BA3_CODPLA") 
				cCdVersao := Posicione("BA3",1,xFilial("BA3") + SubStr(cMatric, 1,14),"BA3_VERSAO") 
			Endif

			BBA->BBA_CODPRO := cCdPlano
			BBA->BBA_VERSAO := cCdVersao
		EndIf 
		
		BBA->BBA_CODINT := PlsIntPad() // Verificar
		BBA->BBA_DATSOL := DATE()
		BBA->BBA_HORSOL := TIME()
		BBA->BBA_NROPRO := Posicione("BA0",1,xFilial("BA0")+PLSINTPAD(),"BA0_SUSEP") + dtos(DDATABASE) + cCodSeq
		BBA->BBA_CPFTIT := StrTran(StrTran(aDataAux[1], ".", ""), "-", "")
		
		BBA->BBA_CODEMP := Iif(cTpPortal == "3", TRBBA3->BA3_CODEMP, TRBB40->B40_CODEMP)
		BBA->BBA_CONEMP := Iif(cTpPortal == "3", TRBBA3->BA3_CONEMP, TRBB40->B40_NUMCON)
		BBA->BBA_VERCON := Iif(cTpPortal == "3", TRBBA3->BA3_VERCON, TRBB40->B40_VERCON)
		BBA->BBA_SUBCON := Iif(cTpPortal == "3", TRBBA3->BA3_SUBCON, TRBB40->B40_SUBCON)
		BBA->BBA_VERSUB := Iif(cTpPortal == "3", TRBBA3->BA3_VERSUB, TRBB40->B40_VERSUB)
		BBA->BBA_MATRIC := aDataAux[2]

		if cTpPortal = "3"
			BBA->BBA_MATRIC := cMatric
			BBA->BBA_CODPRO := TRBBA3->BA3_CODPLA
		endif
	BBA->(MsUnlock())

EndIf

nRecBBA := BBA->( Recno() )

If cTpPortal == "3" .And. !lAltSolBen .And. !lAltSolB7L
	TrbBA3->(DbCloseArea())
elseIf cTpPortal == "2"
	TRBB40->(dbcloseArea())
endIf

Return {lRet,"", cCodSeq, aPos, lExecPos, "", "2", nRecBBA, lAltSolBen}

//-------------------------------------------------------------------
/*/{Protheus.doc} PLBENPRE
Incluir BBA e Retornar o Sequencial
@author Roberto Vanderlei
@since 13/11/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLBENPRE()
//Formato do adados
//[X][Y]
//[X]		= Posição
//[X][1]	= Alias
//[X][2]	= Campo (variável do portal)
//[X][3]	= Valor (após alterar)
//[X][4]	= Sequencial da Grid (
//[X][5]	= Booleano (Define se altera o outro booleano)
//[X][6]	= Campo (Tabela)
//[X][7]	= RECNO
Local cCodSeq 		:= ""
Local lRet 			:= .T.
Local cMsg			:= ""
local nI
local nIndiceProtoc := 0
local nRecBBA 		:= 0
Local cSQL			:= ""
local cUserCod  	:= IIF(AllTrim(xDataAux) == "|", cLogin , StrTran(StrTran(xDataAux, ".", ""), "-", "")) //cLogin//HttpSession->USR_INFO[1]:CUSERLOGIN
Local cCPFB2N		:= ''
Local aDataAux 		:= Iif(AllTrim(xDataAux) == "|", {}, Separa(cUserCod, "|"))
local cCodTit 		:= getNewPar("MV_PLCDTIT", "T")
local cCodDep 		:= getNewPar("MV_PLCDDEP", "D")
local cCodEmp 		:= ""
local cConEmp 		:= ""
local cSubCon 		:= ""
local cCodPro 		:= ""
local aCritica 		:= {}
local nPosGraPa 	:= Ascan(aDados, {|x| x[6] == "B2N_GRAUPA"}) 
local cMV_TIT  		:= getNewPar("MV_PLCDTGP", "01")
Local cCodOpe  		:= PlsIntPad() 
Local cMatricFam	:= ""
Local cCodMunicipio := ""
Local cDescMunicipio := ""
Local nPosMunicipio := 0

for nI := 1 to len(aDados)
	if aDados[nI][2] = "cB2N_PROTOC" 
		nIndiceProtoc := nI
	endif
	if aDados[nI][6] == "B2N_CPFUSR"
		
		//verifica se o beneficiário é titular
		If aDados[nPosGraPa][3] == cMV_TIT //26-03
			Aadd(aDados, {"B2N", 'cB2N_TIPUSU', cCodTit, aDados[nI][4], aDados[nI][5], "B2N_TIPUSU", aDados[nI][7]})
		else
			Aadd(aDados, {"B2N", 'cB2N_TIPUSU', cCodDep, aDados[nI][4], aDados[nI][5], "B2N_TIPUSU", aDados[nI][7]})
		endIf
	EndIf

	if aDados[nI][6] == "B2N_CODEMP"
		cCodOpe	 := Substr(aDados[nI][3],1,4) // Codigo da Operado retornado do portal		
		aDados[nI][3] := Substr(aDados[nI][3],6,9)													
		cCodEmp := aDados[nI][3]				
    endif

	if aDados[nI][6] == "B2N_CONEMP"
		cConEmp := aDados[nI][3]
	endIf
	if aDados[nI][6] == "B2N_SUBCON"
		cSubCon := aDados[nI][3]
	endIf
	if aDados[nI][6] == "B2N_CODPRO"
		cCodPro := aDados[nI][3]
	endIf

	If aDados[nI][6] == "B2N_CODMUN"
		cCodMunicipio := aDados[nI][3]
	endIf

	If aDados[nI][6] == "B2N_MUNICI"
		nPosMunicipio := nI
	EndIf

next

// Carrega a descrição do municipio
If !Empty(cCodMunicipio)
	cDescMunicipio := Posicione("BID", 1, xFilial("BID")+cCodMunicipio, "BID_DESCRI")

	If nPosMunicipio > 0
		aDados[nPosMunicipio][3] := Alltrim(cDescMunicipio)
	Else
		Aadd(aDados, {"B2N", "cB2N_MUNICI", Alltrim(cDescMunicipio), "", .F., "B2N_MUNICI", 0})
	EndIf
EndIf

aCritica := PLSVLMBEN(aDados)

if !aCritica[1]
	Return {.F., aCritica[2]}
Endif

If cTpPortal == "2" .And. Len(aDataAux) >= 2
	cMatricFam := Substr(aDataAux[2], 1, 14)
	aCritica := VldIncDep(cMatricFam,cCodOpe,cCodEmp,cConEmp,cSubCon)

	If !aCritica[1]
		Return {.F., aCritica[2]}
	Endif
EndIf

if aDados[nIndiceProtoc][3] = "000000"
	
	if cTpPortal = "2"
		
		cSQL := "SELECT B40_CODINT, B40_CODEMP, B40_NUMCON, B40_VERCON, B40_SUBCON, B40_VERSUB "
		cSQL += " FROM " + RetSQLName("B40")
		cSQL += " WHERE D_E_L_E_T_ = '' AND B40_FILIAL = '"+xFilial("B40")+"' AND B40_CODUSR = "
		cSQL += " (SELECT BSW_CODUSR FROM " + RetSQLName("BSW") + " WHERE "
		cSQL += " BSW_LOGUSR = '" + cLogin + "' AND D_E_L_E_T_ = '')"
		cSQL += iif(Empty(cCodEmp), "", " AND B40_CODEMP = '" + cCodEmp + "'")
		cSQL += iif(Empty(cConEmp), "", " AND B40_NUMCON = '" + cConEmp + "'")
		cSQL += iif(Empty(cCodOpe), "", " AND B40_CODINT = '" + cCodOpe + "'")

		dbUseArea(.t.,"TOPCONN",tcGenQry(,,changeQuery(cSql)),"TRBB40",.f.,.t.)

	endif
	
	cCodSeq := GETSXENUM("BBA", "BBA_CODSEQ")
	aDados[nIndiceProtoc][3] = cCodSeq
	
	BBA->(RecLock("BBA", .T.))
	BBA->BBA_FILIAL := xFilial("BBA") 
	BBA->BBA_CODSEQ := cCodSeq
	BBA->BBA_TIPMAN := "1"
	BBA->BBA_TIPSOL := "2"
	BBA->BBA_STATUS := "1"
	BBA->BBA_CODINT := cCodOpe
	BBA->BBA_DATSOL := DATE()
	BBA->BBA_HORSOL := TIME()
	BBA->BBA_NROPRO := Posicione("BA0",1,xFilial("BA0")+PLSINTPAD(),"BA0_SUSEP") + dtos(DDATABASE) + cCodSeq
	BBA->BBA_CPFTIT := cUserCod
	BBA->BBA_CODPRO := cCodPro

	if cTpPortal = "2"
		BBA->BBA_CODEMP := TRBB40->B40_CODEMP
		BBA->BBA_CONEMP := TRBB40->B40_NUMCON
		BBA->BBA_VERCON := TRBB40->B40_VERCON
		BBA->BBA_SUBCON := IIF(Empty(cSubCon), TRBB40->B40_SUBCON, cSubCon)
		BBA->BBA_VERSUB := TRBB40->B40_VERSUB
		BBA->BBA_EMPBEN := Posicione('BT5', 1, xFilial('BT5') + BBA->(BBA_CODINT+BBA_CODEMP+BBA_CONEMP+BBA_VERCON), 'BT5_NOME') 
		BBA->BBA_VERSAO := Posicione("BI3", 1, xFilial("BI3") + cCodOpe + cCodPro,"BI3_VERSAO") 
		BBA->BBA_MATRIC := IIF( Len(aDataAux) >= 2, aDataAux[2], cMatric) 
		BBA->BBA_EMPBEN := aDados[Ascan(aDados, {|x| x[6] == "B2N_NOMUSR"})][3] 
		BBA->BBA_CPFTIT := IIF(aDados[Ascan(aDados, {|x| x[6] == "B2N_TIPUSU"})][3] == "T", ; 
													 aDados[Ascan(aDados, {|x| x[6] == "B2N_CPFUSR"})][3], ""	)  
		
		TRBB40->(DbCloseArea()) 
	
	ElseIf cTpPortal == "3" .AND. !(EmpTy(cMatric))
		BBA->BBA_MATRIC := cMatric		
		
		BBA->BBA_CODEMP := Posicione('BA3', 1, xFilial('BA3')+SubStr(AllTrim(IIF( Len(aDataAux) >= 2, aDataAux[2], cMatric)),1,14), 'BA3_CODEMP')
		BBA->BBA_VERCON := Posicione('BA3', 1, xFilial('BA3')+SubStr(AllTrim(IIF( Len(aDataAux) >= 2, aDataAux[2], cMatric)),1,14), 'BA3_VERCON')
		BBA->BBA_SUBCON := Posicione('BA3', 1, xFilial('BA3')+SubStr(AllTrim(IIF( Len(aDataAux) >= 2, aDataAux[2], cMatric)),1,14), 'BA3_SUBCON')
		BBA->BBA_VERSUB := Posicione('BA3', 1, xFilial('BA3')+SubStr(AllTrim(IIF( Len(aDataAux) >= 2, aDataAux[2], cMatric)),1,14), 'BA3_VERSUB')
		BBA->BBA_CONEMP := Posicione('BA3', 1, xFilial('BA3')+SubStr(AllTrim(IIF( Len(aDataAux) >= 2, aDataAux[2], cMatric)),1,14), 'BA3_CONEMP')
		
		BBA->BBA_CPFTIT := Posicione('BA1', 2, xFilial('BA1') + cMatric, 'BA1_CPFUSR')
		BBA->BBA_EMPBEN := Posicione('BT5', 1, xFilial('BT5') + BBA->(BBA_CODINT+BBA_CODEMP+BBA_CONEMP+BBA_VERCON), 'BT5_NOME')
	elseif !(EmpTy(cMatric))
		BBA->BBA_MATRIC := cMatric 
		BBA->BBA_CODEMP := Posicione('BA3', 1, xFilial('BA3')+SubStr(AllTrim(IIF( Len(aDataAux) >= 2, aDataAux[2], cMatric)),1,14), 'BA3_CODEMP')
	endif
	
	If !(empTy(cMatric)) .OR. ( Len(aDataAux) >= 2 .AND. !(EmPty(aDataAux[2])) )
		BBA->BBA_CODPRO := Posicione('BA3', 1, xFilial('BA3')+SubStr(AllTrim(IIF( Len(aDataAux) >= 2, aDataAux[2], cMatric)),1,14), 'BA3_CODPLA')
		BBA->BBA_VERSAO := Posicione('BA3', 1, xFilial('BA3')+SubStr(AllTrim(IIF( Len(aDataAux) >= 2, aDataAux[2], cMatric)),1,14), 'BA3_VERSAO')
	EndIf
	
	BBA->(MsUnlock())
	
	ConfirmSX8()
	
	nRecBBA := BBA->( Recno() )
	
else
	cCodSeq := aDados[nIndiceProtoc][3]
	
	BBA->(DbSetOrder(1))
	BBA->(MsSeek(xFilial("BBA") + cCodSeq))
	nRecBBA := BBA->( Recno() )
endif

//Adiciona uma posição
//Asize(aDados, Len(aDados)+1)
//Atribui o valor
//Insere a posição
//Ains(aDados, 1)
//aDados[1] := {"B2N", "cB2N_PROTOC", cCodSeq, "", .F., "B2N_PROTOC", 0}
		
Return {lRet,cCodSeq, str(nRecBBA)}

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSBENPOS
Função pós para questionar o beneficiário se deseja adicionar novos beneficiários.
@author Roberto Vanderlei
@since 23/11/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSBENPOS()
	
	/*
Pós gravação
*/

Local cAlert 		:= ""
Local aArea 		:= GetArea()

if (aRet[1])
	cAlert := "Deseja realizar o cadastro de outro beneficiário ?|@Sim~  $('html, body').animate({scrollTop:0}, 'slow');" 
	cAlert += "window.frames[0].frameElement.contentWindow.GrvBenef('1','"+aRet[2]+"', '0');"
	cAlert += "@Não~ $('html, body').animate({scrollTop:0}, 'slow');window.frames[0].frameElement.contentWindow.GrvBenef('2', '"+aRet[2]+"' , '"+aRet[3]+"');|N"
Else
	cAlert 		:= "Há criticas que devem ser corrigidas <br>"+ aRet[2] +"|@OK~  $('html, body').animate({scrollTop:0}, 'slow');|N"
EndIf

RestArea(aArea)
	
return PLSDECODE(cAlert)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSALTCPOS
Função para pré validar informações do credenciamento no cadastro via WEB. 
@author Oscar Zanin
@since 02/07/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSALTCPOS(lAltBen)

/*
Pós gravação
Aqui passa o retorno pra executar o aph de anexar documentos, ou o cMotivo Vazio, se não tem motivos no aMotivo

IMPORTANTE!!!!
Para retornar uma página a ser executada, é necessário por um "|", pra que o conteúdo 
do retorno fique na posição [1], após o split.
Caso for retornar somente uma mensagem, o retorno deve ir na posição [0] (sem "|").
*/

Local cMotivos 	:= ""
Local nI 		:= 1
Local cAlert 	:= '|W_PLENVADT.APW?cCodSeq='+aRet[3]+'&cCodRDA='+aRet[6] + '&cTipo=' +  aRet[7] //cTipo 1 - Movimentação cadastral 2 - Cadastro de Beneficiário
Local cCodInt 	:= PLSINTPAD()
Local aArea 	:= GetArea()
Local nLenRet   := Len(aRet[4]) 
Local xDataAux 	:= xDataAux

Default lAltBen := .F.

If ExistBlock("PLALTCPMS")
	cMsg := ExecBlock("PLALTCPMS",.F.,.F.,{cMsg})	//	Ponto de Entrada que permite a manipulação da variável cMsg
Endif

For nI := 1 To nLenRet 

	if ( aRet[4][nI][4] <> aRet[4][nI][12] )
		cMotivos += aRet[4][nI][9]
	EndIF
	
	If nI < nLenRet
		cMotivos += ":"
	EndIF
Next

cAlert += "&cMotivos="+cMotivos

If Len(aRet) >= 8
	cAlert += "&cRecno=" + Str(aRet[8])
EndIf

If !(aRet[5]) .and. aRet[7] = "1"
	cAlert := "Solicitação enviada com sucesso!"
	If ExistBlock("PLALTCPMS")
		cAlert := cMsg
	EndIf
else
	if !(aRet[5]) .and. aRet[7] = "2"
		If lAltBen
			cAlert := "Solicitação enviada com sucesso! Protocolo: " + BBA->BBA_NROPRO
		Else
			cAlert := "Solicitação enviada com sucesso!|@OK~  $('html, body').animate({scrollTop:0}, 'slow');window.frames[0].frameElement.contentWindow.chamaRelAltBenef('"+alltrim(str(aRet[8]))+"');|N"
		EndIf
		If ExistBlock("PLALTCPMS")
			cAlert := cMsg + " |@OK~  $('html, body').animate({scrollTop:0}, 'slow');window.frames[0].frameElement.contentWindow.chamaRelAltBenef('"+alltrim(str(aRet[8]))+"');|N"
		EndIf
	endif
EndIf

//Grava documentos pendentes na tabela BC8 a partir dos documentos cadastrados na B9X
B9X->(DbSetOrder(4)) //Ordena a B9X por: B9X_FILIAL+B9X_CODINT+B9X_CODMOT+B9X_CODDOC
BC8->(DbSetOrder(1)) //Ordena a BC8 por: BC8_FILIAL+BC8_CODIGO+BC8_CODDOC

For nI := 1 To Len(aRet[4])	
	//Verificar se o motivo encontrado existe na B9X
	If (B9X->(MsSeek(xFilial("B9X")+cCodInt+aRet[4][nI][9])))				
		//Caso exista, inclui na tabela BC8 TODOS os documentos relacionados ao motivo
		//Percorre a tabela B9X enquanto a filial, código da operadora e motivo estiverem relacionados à RDA alterada.
		While !(B9X->(EoF()));
				.AND. B9X->(B9X_FILIAL) == xFilial("B9X");
				.AND. B9X->(B9X_CODINT) == cCodInt;
				.AND. B9X->(B9X_CODMOT) == aRet[4][nI][9]
			
			//Verifica se o documento selecionado na B9X já existe na tabela de documentos da RDA (BC8)
			//Índice:         BC8_FILIAL     + BC8_CODIGO (RDA)        + BC8_CODDOC
			If !(BC8->(MsSeek(xFilial("BC8") + StrZero(Val(aRet[6]),6) + B9X->B9X_CODDOC)))
				//Adiciona novo registro com o documento localizado na tabela de Motivos X Documentos (B9X)			
				BC8->(RecLock("BC8", .T.))	
					BC8->BC8_FILIAL := XFILIAL("BC8")					
					BC8->BC8_CODIGO := StrZero(Val(aRet[6]),6)
					BC8->BC8_CODDOC := B9X->B9X_CODDOC
					BC8->BC8_DOCOBR := B9X->B9X_OBRIG
					BC8->BC8_DOCENT := "0" //Não entregue				
				BC8->(MsUnlock())	
			EndIf
			
			//Avanca para próximo documento relacionado ao motivo
			B9X->(DbSkip())
		EndDo
	EndIf
Next

RestArea(aArea)

return PLSDECODE(cAlert)
//-------------------------------------------------------------------
/*/{Protheus.doc} PLINDPRE
Pegar Carteirinha
@author Oscar Zanin
@since 20/07/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLINDPRE()
//Formato do adados
//[X][Y]
//[X]		= Posição
//[X][1]	= Alias
//[X][2]	= Campo (variável do portal)
//[X][3]	= Valor (após alterar)
//[X][4]	= Sequencial da Grid (
//[X][5]	= Booleano (Define se altera o outro booleano)
//[X][6]	= Campo (Tabela)
//[X][7]	= RECNO
Local cCodLog := ""
Local cCartei	:= ""
Local nI		:= 1
Local cTel		:= ""	
Local cCep		:= ""
Local nPosB9V	:= 0
Local nPosB9Q	:= 0
Local lRet		:= .T.
Local cMsg		:= ""
Local lErro		:= .F.
Local lAchouEsp	:= .F.
Local cCodSeqB9V	:= ""

cTel := Alltrim(GetDadoArr(aDados, "B9Y", "B9Y_TEL",,.T.)[1])
cTel := StrTran(cTel,'.','')  
cTel := StrTran(cTel,'-','')
cTel := StrTran(cTel,'/','')	
SetDadoArr(@aDados, "B9Y", "B9Y_TEL", cTel)

cCep := Alltrim(GetDadoArr(aDados, "B9V", "B9V_CEP",,.T.)[1])
cCep := StrTran(cCep,'-','')	
SetDadoArr(@aDados, "B9V", "B9V_CEP", cCep)
//todo endereco tem que ter uma especialidade - validar B9V_CODSEQ = B9Q_CODLOC
nTamNi	:= Len(aDados)
nPosB9V	:= aScan(aDados, { |x| x[1] ==  "B9V" })

If nPosB9V <> 0
	nI := nPosB9V
	While (nI <= nTamNi) .And. (aDados[nI,1] <> NIL) .And. (aDados[nI,1]) == "B9V" .AND. !lErro .And. cCodSeqB9V <> Nil 			
		cCodSeqB9V	:= GetDadoArr(aDados, "B9V", "B9V_CODSEQ")[1] //pego o codigo sequencial do primeiro registro da B9V								
		nPosB9Q		:= aScan(aDados, { |x| x[1] ==  "B9Q" }) 
		nJ 			:= nPosB9Q
		lAchouEsp	:= .F.
		If cCodSeqB9V <> Nil	
			While (nJ <= nTamNi) .AND. (aDados[nJ,1] <> NIL) .AND. (aDados[nJ,1] == "B9Q") .AND. !lErro
				aEspec := GetDadoArr(aDados, "B9Q", "B9Q_CODLOC",cCodSeqB9V)
				If aEspec[1] == Nil 
					lErro := .T.
					Loop
				Else
					lAchouEsp := .T.
					Exit
				EndIf
				nJ++
			End
		EndIf
		nI++
	End
EndIf

If lErro
	lRet := .F.
	cMsg := "Há endereços que não estão relacionados a nenhuma especialidade"
Else	
	//Busca código do usuário
	BSW->(DbSetOrder(1))
	BSW->(MsSeek(xFilial("BSW")+cLogin))
	cCodLog := BSW->(BSW_CODUSR)
	
	//Busca Carteirinha do usuário
	B49->(DbSetOrder(1))
	B49->(MsSeek(xFilial("B49")+cCodLog))
	cCartei := B49->(B49_BENEFI)
	
	//Adiciona uma posição
	Asize(aDados, Len(aDados)+1)
	
	//Insere a posição
	Ains(aDados, 1)
	
	//Atribui o valor
	aDados[1] := {"B9Y", "cB9Y_CARTEI", cCartei, "", .F., "B9Y_CARTEI", 0}
EndIf
Return {lRet,cMsg}
//-------------------------------------------------------------------
/*/{Protheus.doc} PLINDPOS
Função para pós validar indicações de prestador pelo beneficiário e enviar email. 
@author Fábio Siqueira dos Santos
@since 22/07/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLINDPOS()
Local nTamNi   	:= 0
Local nI     	:= 0
Local cMsgPad	:= ""
Local cEmail  := ""
Local cAlert	:= ""
Local cCodInt	:= PLSINTPAD()
Local cDesInt := alltrim(POSICIONE("BA0",1,XFILIAL("BA0")+cCodInt,"BA0_NOMINT"))                                                                    
Local cCodigo := B9Y->B9Y_CODIGO
Local cProt	:= B9Y->B9Y_NROPRO
Local cCartei := alltrim(B9Y->B9Y_CARTEI)
Local cEmailBenef := ""
//	PLSA809 é a função do cadastro de indicação de prestador via call center, vamos usar o mesmo sinalizador
Local cFuncao     := Left( "PLSA809" + Space( TamSX3("BOJ_ROTINA")[1] ), TamSX3("BOJ_ROTINA")[1] )

//Email do beneficiário que fez a indicação
cEmailBenef := POSICIONE("BA1",2,XFILIAL("BA1")+cCartei,"BA1_EMAIL")

cMsgPad := "A " + cDesint + " agradece a sua indicação"
cAlert += cMsgPad + chr(13) + chr(10)
cEmail += cMsgPad + "<br />"
cMsgPad := "O protocolo para acompanhamento da indicação é: " + cProt
cAlert += cMsgPad + chr(13) + chr(10)
cEmail += cMsgPad + "<br />"

BOJ->(DbSetOrder(2))
If BOJ->(MsSeek(xFilial("BOJ") + cFuncao + "3"))

	If !(Empty(Alltrim(cEmailBenef)))
		PLSinaliza(BOJ->BOJ_CODSIN,,,cEmailBenef, "Agradecimento a indicação de prestador",,,,,,,cEmail,,"000002")
	EndIf
	
EndIf
		
Return cAlert
//-------------------------------------------------------------------
/*/{Protheus.doc} PLGERAPROT
Função para gerar protocolos de credenciamento. 
@author Karine Riquena Limp
@since 20/07/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLGEPROB9Y(cSeq)
Local cProt := ""
Local cMes			:= ALLTRIM(STRZERO(Month(Date()), 2))
Local cAno			:= SUBSTR(ALLTRIM(STR(Year(Date()))), -2)
DEFAULT cSeq := getSxEnum("B9Y", "B9Y_CODIGO")
cProt := cMes + cAno + cSeq 
Return cProt

//-------------------------------------------------------------------
/*/{Protheus.doc} PL817PRE
Função para gravar dados complementares da visita institucional 
@author TOTVS
@since 12/08/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PL817PRE()
Local cCodRDA := 0
Local cCodInt := PLSINTPAD()
Local ni		:= 1
Local lMailWeb := .F.
//cLogin é carregado da função GrvForm do fonte WSPLCadWeb
 
BSW->(DbSelectArea("BSW"))
BSW->(DbSetOrder(1))//BSW_FILIAL+BSW_LOGUSR                                                                                                                                           
If BSW->(MsSeek(xFilial("BSW")+UPPER(AllTrim(cLogin))))		
	BSO->(DbSelectArea("BSO"))
	BSO->(DbSetOrder(3))//BSO_FILIAL+BSO_CODUSR                                                                                                                                                                                                                                                                                      
	If BSO->(MsSeek(xFilial("BSO")+BSW->BSW_CODUSR))
	  cCodRDA := BSO->BSO_CODIGO
	Endif		
Endif

If !Empty(cCodRDA)
	
	aAdd(aDados, {"B7K", "cB7K_FILIAL", xFilial("B7K"), "", .F., "B7K_FILIAL"})
	aAdd(aDados, {"B7K", "cB7K_CODINT", PLSINTPAD()   , "", .F., "B7K_CODINT"})
	aAdd(aDados, {"B7K", "cB7K_CODVIS", GETSXENUM("B7K","B7K_CODVIS"), "", .F., "B7K_CODVIS"})
	aAdd(aDados, {"B7K", "cB7K_DATSOL", Date()         , "", .F., "B7K_DATSOL"})
	aAdd(aDados, {"B7K", "cB7K_HORSOL", Left(Time(),5) , "", .F., "B7K_HORSOL"})
	aAdd(aDados, {"B7K", "cB7K_DEFERE", "0"            , "", .F., "B7K_DEFERE"})
	
	//RDA
	BAU->(DbSelectArea("BAU"))
	BAU->(DbSetOrder(1))
	If BAU->(MsSeek(xFilial("BAU")+cCodRda))		
		aAdd(aDados, {"B7K", "cB7K_CODRDA", cCodRda         , "", .F., "B7K_CODRDA"})
		aAdd(aDados, {"B7K", "cB7K_CNTSOL", BAU->BAU_NREDUZ , "", .F., "B7K_CNTSOL"})
		If !Empty(BAU->BAU_TEL)
			aAdd(aDados, {"B7K", "cB7K_TELSOL", BAU->BAU_TEL    , "", .F., "B7K_TELSOL"})
		Endif
		
		For nI := 1 To len(aDados)
			If aDados[nI][6] == 'B7K_MAILSL' .AND. !(Empty(AllTrim(aDados[nI][3])))
				lMailWeb := .T.
				Exit
			EndIf
		Next
		
		If !lMailweb
		If !Empty(BAU->BAU_EMAIL)
			aAdd(aDados, {"B7K", "cB7K_MAILSL", BAU->BAU_EMAIL  , "", .F., "B7K_MAILSL"})
		Endif	
		EndIf
	Endif
	
	//Operadora
	BA0->(DbSelectArea("BA0"))
	BA0->(DbSetOrder(1))                                                                                                                      
	If BA0->(MsSeek(xFilial("BA0")+cCodInt))		
		If !Empty(BA0->BA0_CODFOR)
			aAdd(aDados, {"B7K", "cB7K_CNTOPE", BA0->BA0_CODFOR , "", .F., "B7K_CNTOPE"})
		Endif
		If !Empty(BA0->BA0_TELEF1)
			aAdd(aDados, {"B7K", "cB7K_TELOPE", BA0->BA0_TELEF1 , "", .F., "B7K_TELOPE"})
		Endif	
		If !Empty(alltrim(BA0->BA0_EMAIL))
			aAdd(aDados, {"B7K", "cB7K_MAILOP", BA0->BA0_EMAIL  , "", .F., "B7K_MAILOP"})
		Endif	
	Endif
Endif

Return {.T.}

//-------------------------------------------------------------------------------
/*/{Protheus.doc} PL817POS
Função para enviar email de agradecimento pela solicitação da visita institucional 
@author TOTVS
@since 18/08/2015
@version P12
/*/
//-------------------------------------------------------------------------------
Function PL817POS()
Local nTamNi   	:= 0
Local cMsgPad	:= ""
Local cEmail  := ""
Local cAlert	:= ""
Local cCodInt	:= PLSINTPAD()
//Importante: os e-mail tem que ser separados por ; 
Local cDestino:= AllTrim(GetNewPar("MV_817EMAI"," "))//e-mail dos analistas que receberão a solicitacao
//PLSA817 é o codigo do Layout Generico e usado no campo Rotina do cadastrado de Sinalizador. 
Local cFuncao     := Left( "PLSA817" + Space( TamSX3("BOJ_ROTINA")[1] ), TamSX3("BOJ_ROTINA")[1] )

cMsgPad := "Solicitação realizada com sucesso!!"
cAlert += cMsgPad + chr(13) + chr(10)
cEmail += cMsgPad + "<br />"

BOJ->(DbSetOrder(3))
If BOJ->(MsSeek(xFilial("BOJ") + cFuncao + "0"))
	If !(Empty(Alltrim(cEmail)))
		PLSinaliza(BOJ->BOJ_CODSIN,,,cDestino, "Visita institucional",,,,,,,cEmail,,"000002",)
	EndIf
EndIf
		
Return cAlert

//-------------------------------------------------------------------------------
/*/{Protheus.doc} VldIncDep
Valida se os dados referente a Operadora, Empresa, Contrato ou SubContrato estão 
de acordo com os dados da Familia na inclusão do dependente no Portal 

@author Vinicius.Queiros
@since 10/11/2020
@version P12
/*/
//-------------------------------------------------------------------------------
Function VldIncDep(cMatricFam,cCodOpe,cCodEmp,cConEmp,cSubCon)

Local aRetorno	:= {.T.,""}

Default cCodOpe := ""
Default cCodEmp := ""
Default cConEmp := ""
Default cSubCon := ""

	BA3->(DbSetOrder(1))
   	If BA3->(msSeek(xFilial("BA3") + cMatricFam ))
	   Do Case
			Case cCodOpe <> BA3->BA3_CODINT
				aRetorno := {.F., "Operadora selecionada diferente da Familia: " + BA3->BA3_CODINT }
			
			Case cCodEmp <> BA3->BA3_CODEMP
				aRetorno := {.F., "Empresa selecionada diferente da Familia: " + BA3->BA3_CODEMP }
			
			Case cConEmp <> BA3->BA3_CONEMP
				aRetorno := {.F., "Contrato selecionado diferente da Familia: " + BA3->BA3_CONEMP }
			
			Case cSubCon <> BA3->BA3_SUBCON
				aRetorno := {.F., "Subcontrato selecionado diferente da Familia: " + BA3->BA3_SUBCON }		
	   EndCase
	EndIf

Return aRetorno