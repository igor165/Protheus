#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "RHIMP14.CH"

/****************###***************************************************************
***********************************************************************************
***********************************************************************************
***Funcão..: RHIMP14.prw Autor:Leandro Drumond Data: 21/11/2012                 ***
***********************************************************************************
***Descrição..:Responsavel em Processar a Importacao das rescisoes (Dados de    #**
***rescisao e folha de rescisao )											    #**
***********************************************************************************
***Uso........:        														    ***
***********************************************************************************
***Parâmetros.:		cFileName, caractere, nome do arquivo       	      	    ***
***********************************************************************************
***Retorno....: ${return} - ${return_description}                               ***
***********************************************************************************
***********************************************************************************
***RESPONSÁVEL.|DATA....|CÓDIGO|BREVE DESCRIÇÃO DA CORREÇÃO.....................***
***********************************************************************************
***P. Pompeu...|15/04/16|TSQLBE|Preencher c/ zero à esquerda o campo RG_TIPORES ***
***Leandro Dr. |27/07/16|      |Tratamento para utilizacao de DE-PARA de rotina ***
***............|........|......|de importação genérica.                         ***
**********************************************************************************/

/*/{Protheus.doc} RHIMP14
	Responsavel em Processar a Importacao das rescisoes (Dados de rescisao e folha de rescisao )
@author Leandro Drumond
@since 21/11/2012
@version P11
@param cFileName, caractere, nome do arquivo
@return ${return}, ${return_description}
/*/
User Function RHIMP14(cFileName,aRelac,oSelf)
	Local aAreas		:= {SRA->(GetArea()),SRV->(GetArea()),SRG->(GetArea()),RFY->(GetArea()),SRD->(GetArea()),SRR->(GetArea())}	
	Local aFuncImp		:= {}
	Local aLinha		:= {}
	Local aTpRescImp	:= {}
	Local aPeriodo		:= {}
	Local aPDImp		:= {}
	Local aFuncNot		:= {}
	Local aIndAux		:= {}
	Local cBuffer		:= ""
	Local cEmpresaArq	:= ""
	Local cFilialArq	:= ""	
	Local cMatImp		:= ""
	Local cVerbImp		:= ""
	Local cTpRescImp	:= ""
	Local cTipo			:= ""
	Local cDescErro		:= ""
	Local cEmpOri    	:= "##"
	Local lChangeEnv 	:= .T.
	Local nSeqSRD		:= 0
	Local cSemana		:= "01"
	Local cRoteiro		:= ""
	Local cRotFol		:= ""
	Local lExiste		:= .F.
	Local aTabelas 		:= {"SRA","SRV","SRG","SRD","SRC","SRX","SRR","RFY","SRY"}
	Local lApag 		:= .T.
	Local lApagMov		:= .F.
	Local lPergApag		:= .T.
	Local aEmpresas		:= {}
	Local aTemp			:= {} 
	Local nI			:= 0
	Local nX			:= 0
	Local nJ			:= 0
	Local nY 			:= 0
	Local nPos			:= 0
	Local aTpAvi		:= {}
	Local dGDtGer		:= CtoD("//")
	Local nTamMAT 		:= TAMSX3('RA_MAT')[1]
	Local nTamRvCod 	:= TAMSX3('RV_COD')[1]
	Local nTamTpRes 	:= TAMSX3('RG_TIPORES')[1]
	Local aErro 		:= {}
	Local cTpAviso 		:= " "
	Local dProj 		:= CtoD("  /  /  ")
	Local cPeriodo		:= ""
	Local cSeqSRD		:= ""
	Local cDataArqv		:= ""
	DEFAULT aRelac		:= {}
	
	/*Ordem dos campos no array que sera montado com base na linha do TXT rescisao_logix.unl
	01 - Tipo = 1
	02 - * - Empresa Protheus
	03 - RG_FILIAL 	- Filial Protheus
	04 - RG_MAT 	- Matrícula
	05 - RG_TIPORES	- Tipo de Rescisao
	06 - RG_DATDEM 	- Data de Demissao
	07 - RG_DATHOM	- Data de Homologacao
	08 - RG_DTAVISO	- Data do Aviso Previo
	09 - RG_DAVISO 	- Dias de Aviso Previo
	10 - RG_NORMAL 	- Horas Normais de Trabalho
	11 - RG_DESCANS - Horas de DSR
	12 - RG_SALMES 	- Salario Mensal
	13 - RG_SALHORA - Salario Hora
	14 - RG_SALDIA 	- Salario Dia
	15 - RG_TPAVISO	- Tipo Aviso de Demissao
	16 - RG_DFERVEN	- Dias de Ferias Vencidas
	17 - RG_DFERPRO	- Dias de Ferias Proporcionais
	18 - RG_DTGERAR - Data Geração Rescisao
	
	01 - Tipo = 2
	02 - * - Empresa Protheus
	03 - RD_FILIAL 	- Filial Protheus
	04 - RD_MAT 	- Matrícula
	05 - RD_PD		- Verba
	06 - RD_DATARQ	- Data de Referencia
	07 - RD_CC		- Centro de Custos
	08 - RD_TIPO1	- Tipo de Verba
	09 - RD_HORAS 	- Quantidade Calculada
	10 - RD_VALOR 	- Valor da Verba
	11 - RD_DATPGT  - Data de Processamento
	12 - RR_DATAPAG	- Data de Pagamento
	13 - RD_DEPTO   - Departamento
	14 - RD_ITEM    - ITEM
	15 - RD_INSS 	- Incidencia INSS
	16 - RD_IR   	- Incidencia IR
	17 - RD_FGTS	- Incidencia FGTS
	*/
	
	FT_FUSE(cFileName)
	/*Seta tamanho da Regua*/
	U_ImpRegua(oSelf)
	FT_FGOTOP()	
		
	While !FT_FEOF() .And. !lStopOnErr
		cBuffer := FT_FREADLN()
		
		/*Checa se deve parar o processamento.*/				
		U_StopProc(aErro)
		U_StopProc(aFuncImp)
		U_StopProc(aTpRescImp)
		U_StopProc(aPDImp)		
		
		aLinha := {}
		aLinha := StrTokArr2(cBuffer,"|",.T.)
		
		cTipo	  := aLinha[1]
		
		cEmpresaArq	:= aLinha[2]
		cFilialArq	:= aLinha[3]
		
		If !Empty(aRelac) .and. u_RhImpFil()
			cEmpresaArq := u_GetCodDP(aRelac,"FILIAL",aLinha[3],"FILIAL",aLinha[2],.T.,.T.) //Busca a Empresa no DE-PARA
			cFilialArq	:= u_GetCodDP(aRelac,"FILIAL",aLinha[3],"FILIAL",aLinha[2],.T.,.F.) //Busca a Filial no DE-PARA
		EndIf		
		
		U_RHPREARE(cEmpresaArq,cFilialArq,@cEmpOri,'',@lChangeEnv,@lExiste,"GPEA250",aTabelas,,@aErro,OemToAnsi(STR0001))		
		
		
		if(lChangeEnv)
			aFuncNot 	:= {}			
			cRoteiro	:= fGetCalcRot("4")//RES
			cRotFol	:= fGetCalcRot("1")
			SRV->(DbSetOrder(1))			
			if(	cEmpOri  != cEmpresaArq)
				lApag 	:= .T.
				cEmpOri  := cEmpresaArq
				aAdd(aEmpresas,cEmpOri)			
			endIf
		endIf		
			
		If lApag .and. ExistReg(cRoteiro)
			If lApagMov .or. ( lPergApag .and. MsgYesNo(OemToAnsi(STR0005))) // Apaga Movimentação Anterior?
				fDelMov('SRR',cRoteiro)	//Exclui todos os registros tipo R (RR_TIPO2) da SRR
				fDelMov('SRD',cRoteiro)  //Exclui todos os registros tipo R (RD_TIPO2) da SRD
				fDelMov('SRG',cRoteiro)	//Exclui todos os registros da SRG
				fDelMov('RFY',cRoteiro)	//Exclui todos os registros da RFY
				lApagMov := .T.
			Else
				lPergApag := .F.
			EndIf
		EndIf
		
		lApag := .F.
		
		If lExiste
			
			//Verifica existencia de DE-PARA
			If !Empty(aRelac)
				If Empty(aIndAux) //Grava a posicao dos campos que possuem DE-PARA
					aCamposAux := U_fGetCpoMod("RHIMP14")
					aIndAux2   := {}
					For nY := 1 to 2
						aCampos := aClone(aCamposAux[nY])
						aInsAux := {}
						For nX := 1 to Len(aCampos)
							For nJ := 1 to Len(aRelac)
								If (nPos := (aScan(aRelac[nJ],{|x| AllTrim(x) == AllTrim(aCampos[nX,1])}))) > 0
									aAdd(aIndAux,{nX,aRelac[nJ,1]})
								EndIf 
							Next nJ
						Next nX
						aAdd(aIndAux2,aClone(aIndAux))
					Next nY
				EndIf

				aIndAux := aClone(aIndAux2[Val(cTipo)])
				aCampos := aClone(aCamposAux[Val(cTipo)])

				For nX := 1 to Len(aIndAux)
					aLinha[aIndAux[nX,1]] := u_GetCodDP(aRelac,aCampos[aIndAux[nX,1],1],aLinha[aIndAux[nX,1]],aIndAux[nX,2]) //Busca DE-PARA
				Next nX
			EndIf			

			cMatImp	 := PadR(aLinha[4],nTamMAT)
			
			U_IncRuler(OemToAnsi(STR0001),cMatImp + '/' + aLinha[5],cStart,.F.,,oSelf)
						
			If !(SRA->(DbSeek(xFilial("SRA")+cMatImp)))
				If !Empty(aFuncImp)
					If aScan(aFuncImp,  { |x|  X[1]+X[2]+X[3] == cEmpresaArq + cFilialArq + cMatImp }) == 0
						aAdd(aFuncImp, {cEmpresaArq,cFilialArq,cMatImp})
					EndIf
				Else
					aAdd(aFuncImp,{cEmpresaArq,cFilialArq,cMatImp})
				EndIf
				FT_FSKIP()
				Loop
			EndIf
			
			If cTipo == "1"
				cTpRescImp := PadL(aLinha[5],nTamTpRes,"0")
				If fPosTab("S043", cTpRescImp, "==", 4 ) <= 0
					If !Empty(aTpRescImp)
						If aScan(aTpRescImp,  { |x|  X[1]+X[2]+X[3] == cEmpresaArq + cFilialArq + aLinha[5] }) == 0
							aAdd(aTpRescImp, {cEmpresaArq,cFilialArq,aLinha[5]})
						EndIf
					Else
						aAdd(aTpRescImp,{cEmpresaArq,cFilialArq,aLinha[5]})
					EndIf
					
					aAdd(aFuncNot,{cFilialArq,cMatImp})
					
					FT_FSKIP()
					Loop
				EndIf
			Else
				
				If !(aScan(aFuncNot,  { |x|  X[1]+X[2] == cFilialArq + cMatImp }) == 0)
					FT_FSKIP()
					Loop
				Else					
					cVerbImp := PadR(aLinha[5],nTamRvCod)
					
					If !SRV->(DbSeek(xFilial("SRV")+cVerbImp))
						If !Empty(aPDImp)
							If aScan(aPDImp,  { |x|  X[1]+X[2]+X[3] == cEmpresaArq + cFilialArq + aLinha[5] }) == 0
								aAdd(aPDImp, {cEmpresaArq,cFilialArq,aLinha[5]})
							EndIf
						Else
							aAdd(aPDImp,{cEmpresaArq,cFilialArq,aLinha[5]})
						EndIf
						FT_FSKIP()
						Loop
					EndIf
				EndIf
			EndIf			
				
			If cTipo == "1"						
				if CtoD(aLinha[18]) == Ctod("  /  /  ")				
					dGDtGer := CtoD(aLinha[6])
				Else
					dGDtGer := CtoD(aLinha[18])
				Endif
				
				cPeriodo := Anomes(CtoD(aLinha[6]))
				
				RecLock("SRG",SRGIsNew(cMatImp,cPeriodo,cRoteiro,cSemana, DToS(dGDtGer)))
				
				SRG->RG_FILIAL 	:=  xFilial('SRG')
				SRG->RG_MAT 	:=  cMatImp
				SRG->RG_TIPORES :=  cTPrescImp
				SRG->RG_DATADEM :=  CtoD(aLinha[6])				
				SRG->RG_DATAHOM :=  CtoD(aLinha[7])
				SRG->RG_DTGERAR :=  dGDtGer
				
				if CtoD(aLinha[8]) == Ctod("  /  /  ")
					SRG->RG_DTAVISO :=  CtoD(aLinha[6])
				else
					SRG->RG_DTAVISO :=  CtoD(aLinha[8])
				Endif
				
				SRG->RG_DAVISO  :=  U_VldValue(aLinha[9])
				SRG->RG_NORMAL  :=  U_VldValue(aLinha[10])
				SRG->RG_DESCANS :=  U_VldValue(aLinha[11])
				SRG->RG_SALMES  :=  U_VldValue(aLinha[12])
				SRG->RG_SALHORA :=  U_VldValue(aLinha[13])
				SRG->RG_SALDIA  :=  U_VldValue(aLinha[14])
				SRG->RG_TPAVISO :=  aLinha[15]
				SRG->RG_DFERVEN :=  U_VldValue(aLinha[16])
				SRG->RG_DFERPRO :=  U_VldValue(aLinha[17])
				SRG->RG_MEDATU  :=  "S"
				SRG->RG_EFETIVA :=  "S"
				SRG->RG_PERIODO :=  cPeriodo
				SRG->RG_PROCES  :=  SRA->RA_PROCES
				SRG->RG_ROTEIR  :=  cRoteiro
				SRG->RG_SEMANA  :=  cSemana
				
				SRG->(MsUnLock())
				
				
				cTpAviso := aLinha[15]
				dproj := CtoD(aLinha[8])
				dProj := dproj + U_VldValue(aLinha[9])
				
				IF cTpAviso $ "T,D" .and. !Empty(aLinha[8])
					
					
					nPos:= aScan(aTpAvi,{|x|x[1]==xFilial('RFY')+cMatImp+aLinha[8]})
					If nPos == 0
						aAdd(aTpAvi,{xFilial('RFY')+cMatImp+aLinha[8]})
						lGrvAv:= .T.
					Else
						lGrvav := .F.
					Endif
					
					If lGrvAv
						If cTpAviso == "T"
							c_tip:= "1"
						Else
							c_tip:= "4"
						Endif
						
						if CtoD(aLinha[8]) == Ctod("  /  /  ")
							MCHAVE := xFilial('RFY')+cMatImp+DTOS(CtoD(aLinha[6]))
						else
							MCHAVE := xFilial('RFY')+cMatImp+DTOS(CtoD(aLinha[8]))
						Endif						
						
						if !(RFY->(dbSeek(mchave)))
							RecLock("RFY",.T.)
							
							RFY->RFY_FILIAL :=  xFilial('RFY')
							RFY->RFY_MAT    :=  cMatImp
							RFY->RFY_TPAVIS :=  c_tip
							if CtoD(aLinha[8]) == Ctod("  /  /  ")
								RFY->RFY_DTASVP :=  CtoD(aLinha[6])
							else
								RFY->RFY_DTASVP :=  CtoD(aLinha[8])
							Endif
							RFY->RFY_DIASAV :=  U_VldValue(aLinha[9])
							
							if CtoD(aLinha[8]) == Ctod("  /  /  ")
								RFY->RFY_DTPJAV :=  CtoD(aLinha[6])
							ELSE
								RFY->RFY_DTPJAV :=  dproj
							Endif
							RFY->(MsUnLock())
						Endif
					Endif					
					
					cTpAviso := " "
				EndIf
				
			Else
				cPeriodo:= aLinha[6]
				cDataArqv := DToS(CToD(aLinha[6])) 			
				cSemana := '01'
				dDtRef := CtoD(aLinha[12])
				nSeqSRD := fFindSeqSRD(cFilialArq,cVerbImp,cMatImp,cDataArqv)
				cSeqSRD := AllTrim(STR(nSeqSRD))
								
				RecLock("SRD",SRDIsNew(cDataArqv, cVerbImp,cSeqSRD,cPeriodo,cRotFol,cSemana, DtoS(dDtRef)))
									
				SRD->RD_FILIAL :=  xFilial('SRD')
				SRD->RD_MAT    :=  cMatImp
				SRD->RD_PD     :=  cVerbImp
				SRD->RD_DATARQ :=  aLinha[6]
				SRD->RD_MES    :=  SubStr(aLinha[6],5,2)
				SRD->RD_CC     :=  aLinha[7]
				SRD->RD_TIPO1  :=  aLinha[8]
				SRD->RD_HORAS  :=  U_VldValue(aLinha[9])
				SRD->RD_VALOR  :=  U_VldValue(aLinha[10])
				If dGDtGer <> CtoD(aLinha[11])
					SRD->RD_DATPGT :=  dGDtGer
				Else
					SRD->RD_DATPGT :=  CtoD(aLinha[11])
				Endif
				SRD->RD_DTREF  :=  dDtRef
				SRD->RD_DEPTO  :=  aLinha[13]
				SRD->RD_ITEM   :=  aLinha[14]
				SRD->RD_INSS   :=  aLinha[15]
				SRD->RD_IR     :=  aLinha[16]
				SRD->RD_FGTS   :=  aLinha[17]
				SRD->RD_TIPO2  :=  "R"
				SRD->RD_SEQ    :=  cSeqSRD
				SRD->RD_PERIODO :=  cPeriodo
				SRD->RD_PROCES 	:=  SRA->RA_PROCES
				SRD->RD_ROTEIR 	:=  cRotFol
				SRD->RD_SEMANA 	:=  cSemana
				
				SRD->RD_CC		:= SRA->RA_CC
				SRD->RD_ITEM	:= SRA->RA_ITEM
				SRD->RD_CLVL	:= SRA->RA_CLVL
									
				SRD->(MSUnLock())				
				
				
				cPeriodo :=  AnoMes(dGDtGer)			
				
				RecLock("SRR",SRRIsNew("R",cPeriodo,'RES',cSemana, cVerbImp, cSeqSRD, DtoS(dGDtGer)))
				
				SRR->RR_FILIAL  :=  xFilial('SRR')
				SRR->RR_MAT     :=  cMatImp
				SRR->RR_PD      :=  cVerbImp
				SRR->RR_TIPO1   :=  aLinha[8]
				SRR->RR_HORAS   :=  U_VldValue(aLinha[9])
				SRR->RR_VALOR   :=  U_VldValue(aLinha[10])				
				SRR->RR_DATA    :=  dGDtGer				
				SRR->RR_PERIODO := cPeriodo				
				SRR->RR_DATAPAG 	:=  CtoD(aLinha[12])
				SRR->RR_CC      	:=  aLinha[7]
				SRR->RR_ITEM    	:=  aLinha[14]
				SRR->RR_TIPO2   	:=  "R"
				SRR->RR_TIPO3   	:=  "R"
				SRR->RR_SEQ     	:=  cSeqSRD
				SRR->RR_PROCES		:=  SRA->RA_PROCES
				SRR->RR_ROTEIR 		:=  'RES'
				SRR->RR_SEMANA 		:=  cSemana
				
				SRR->(MsUnLock())
				
			EndIf			
		Else
			U_IncRuler(OemToAnsi(STR0001),aLinha[4] + '/' + aLinha[5],cStart,.T.,,oSelf)
		EndIf
		
		FT_FSKIP()		
	EndDo
	FT_FUSE()
	
	if(Len(aFuncImp) > 0)
		aSort( aFuncImp ,,, { |x,y| x[1]+x[2]+X[3] < y[1]+Y[2]+Y[3] } )		
		aEval(aFuncImp,{|x|aAdd(aErro,'['+ x[1] + '/' + x[2] + '/' + x[3] + ']' + OemToAnsi(STR0002))})		
	endIf
	
	if(Len(aPDImp) > 0)		
		aSort( aPDImp ,,, { |x,y| x[1]+x[2]+X[3] < y[1]+Y[2]+Y[3] } )
		aEval(aPDImp,{|x|aAdd(aErro,'['+ x[1] + '/' + x[2] + '/' + x[3] + ']' + OemToAnsi(STR0003))})		
	endIf
	
	if(Len(aTpRescImp) > 0)
		aSort( aTpRescImp ,,, { |x,y| x[1]+x[2]+X[3] < y[1]+Y[2]+Y[3] } )
		aEval(aTpRescImp,{|x|aAdd(aErro,'['+ x[1] + '/' + x[2] + '/' + x[3] + ']' + OemToAnsi(STR0004))})		
	endIf
	
	cEmpOri := cEmpAnt	
	for nI:= 1 to Len(aEmpresas)
		cEmpAnt := aEmpresas[nI]		
		aTemp := u_PerInval()		
		aEval(aTemp,{|x|aAdd(aPeriodo,{cEmpAnt,x[1],x[2]})})
		aTemp := {}
	next nI	
	cEmpAnt := cEmpOri
	
	if(Len(aPeriodo) > 0)		
		aEval(aPeriodo,{|x|aAdd(aErro,'['+x[1]+'/'+x[2]+'/'+x[3]+']'+ OemToAnsi(STR0006))})
	endIf	
	
	U_RIM01ERR(aErro)	
	
	aSize(aErro,0)
	aErro := Nil
	aSize(aPeriodo,0)
	aPeriodo := Nil
	aSize(aPDImp,0)
	aPDImp := Nil
	aSize(aFuncImp,0)
	aFuncImp := Nil
	aSize(aTpRescImp,0)
	aTpRescImp := Nil
	
	aEval(aAreas,{|x|RestArea(x)})
	aSize(aAreas,0)
	aAreas := Nil
Return (.T.)

/*/{Protheus.doc} fDelMov
	Apaga os dados da SRG, SRR e SRD.
@author Leandro Drumond
@since 21/11/12
@version P11
@param cAlias, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*/
Static Function fDelMov(cAlias,cRoteiro)
	Local cQuery := ''
	
	cQuery := " DELETE FROM " + InitSqlName(cAlias) + " "
	If cAlias == "SRD"
		cQuery += " WHERE RD_TIPO2 = 'R' AND RD_FILIAL = '" + xFilial("SRD") + "' "
	EndIf
	If cAlias == "SRR"
		cQuery += " WHERE RR_ROTEIR = '" + cRoteiro + "' AND RR_FILIAL = '" + xFilial("SRR") + "' "
	EndIf
	If cAlias == "SRG"
		cQuery += " WHERE RG_FILIAL = '" + xFilial("SRG") + "' "
	EndIf
	
	If cAlias == "RFY"
		cQuery += " WHERE RFY_FILIAL = '" + xFilial("RFY") + "' "
	EndIf
	
	
	TcSqlExec( cQuery )
	
	TcRefresh( InitSqlName(cAlias) )
	
	
Return NIL

/*/{Protheus.doc} fFindSeqSRD
	Incrementa a sequencia da tabela SRD.
@author Edna Dalfovo
@since 08/05/13
@version P11
@param cFilialArq, character, (Descrição do parâmetro)
@param cPdAux, character, (Descrição do parâmetro)
@param cMatAux, character, (Descrição do parâmetro)
@param cDtArqAx, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*/
Static Function fFindSeqSRD(cFilialArq,cPdAux,cMatAux, cDtArqAx)
	Local cAliasAux := "QTABAUX"
	Local cWhere	:= ''
	Local nRet 		:= 0
	
	cWhere += "%"
	cWhere += " SRD.RD_FILIAL     = 	'" + cFilialArq    + "' "
	cWhere += " AND SRD.RD_PD     = 	'" + cPdAux     + "' "
	cWhere += " AND SRD.RD_MAT    = 	'" + cMatAux    + "' "
	cWhere += " AND SRD.RD_DATARQ = 	'" + cDtArqAx   + "' "
	cWhere += "%"
	
	BeginSql alias cAliasAux
		SELECT MAX(RD_SEQ) SEQMAX
		FROM %table:SRD% SRD
		WHERE 		%exp:cWhere% AND
		SRD.%NotDel%
	EndSql
	
	If Val((cAliasAux)->SEQMAX) > 0
		nRet := Val((cAliasAux)->SEQMAX) + 1
	Else
		nRet := 1
	EndIf
	
	(cAliasAux)->(DbCloseArea())
	
Return nRet

/*/{Protheus.doc} ExistReg
	Função que verifica se existe registros antes de perguntar se deseja limpar a tabela!
@author philipe.pompeu
@since 16/09/2015
@version P12
@return lResult,lógico,verdadeiro se existe registros nas tabelas
/*/
Static Function ExistReg(cRoteiro)
	Local aArea	:= GetArea()
	Local cAliasAux := GetNextAlias()
	Local lResult := .F.
	
	BeginSql alias cAliasAux
		SELECT SUM(SOMA) AS TOTAL from(
		SELECT COUNT(*) AS SOMA
		FROM %table:SRD% SRD 
		WHERE
		RD_ROTEIR =  %exp:cRoteiro% AND RD_FILIAL = %xFilial:SRD% AND SRD.%NotDel%
		
		UNION
		
		SELECT COUNT(*) AS SOMA
		FROM %table:SRR% SRR 
		WHERE
		RR_TIPO2 = 'R' AND RR_FILIAL = %xFilial:SRR% AND SRR.%NotDel%
		) RESULTADO
	EndSql
	
	lResult := (cAliasAux)->TOTAL > 0  
		
	(cAliasAux)->(DbCloseArea())
	
	RestArea(aArea)
	
Return (lResult)

/*/{Protheus.doc} SRGIsNew
(long_description)
@author philipe.pompeu
@since 12/01/2017
@version P11
@param cMat, character, (Descrição do parâmetro)
@param cPer, character, (Descrição do parâmetro)
@param cRot, character, (Descrição do parâmetro)
@param cWeek, character, (Descrição do parâmetro)
@param cDtGer, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*/
Static Function SRGIsNew(cMat, cPer, cRot, cWeek, cDtGer)
	Local lIsNew := .T.
	Local cChave := ''
	
	SRG->(DbSetOrder(1)) // RG_FILIAL+RG_MAT+DTOS(RG_DTGERAR)
	
	cChave := xFilial('SRG') + cMat + cDtGer
	
	if(SRG->(dbSeek(cChave)))
		// X2_UNICO
		//RG_FILIAL+RG_MAT+RG_PERIODO+RG_ROTEIR+RG_SEMANA+DTOS(RG_DTGERAR)		
		while ( SRG->(((RG_FILIAL + RG_MAT + DtoS(RG_DTGERAR)) == cChave) .And. !Eof()) )
			
			if(SRG->(RG_PERIODO == cPer .And. RG_ROTEIR == cRot .And. RG_SEMANA == cWeek))
				lIsNew := .F.
				Exit
			endIf			
			
			SRG->(dbSkip())
		EndDo
		
	endIf
Return lIsNew

/*/{Protheus.doc} SRDIsNew
(long_description)
@author philipe.pompeu
@since 12/01/2017
@version P11
@param cDataArqv, character, (Descrição do parâmetro)
@param cVerbImp, character, (Descrição do parâmetro)
@param cSeq, character, (Descrição do parâmetro)
@param cPeriodo, character, (Descrição do parâmetro)
@param cRotFol, character, (Descrição do parâmetro)
@param cSeman, character, (Descrição do parâmetro)
@param cDtRef, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*/
Static Function SRDIsNew(cDataArqv, cVerbImp, cSeq,cPeriodo,cRotFol,cSeman,cDtRef)
	Local lIsNew := .T.
	Local cChave := ''
	
	SRD->(DbSetOrder(1))	
	cChave := xFilial('SRD') + SRA->RA_MAT + cDataArqv
	
	if(SRD->(dbSeek(cChave)))		
		SRD->(DbSetOrder(RetOrder("SRD","RD_FILIAL+RD_MAT+RD_CC+RD_ITEM+RD_CLVL+RD_DATARQ+RD_PD+RD_SEQ+RD_PERIODO+RD_SEMANA+RD_ROTEIR+DTOS(RD_DTREF)")))
		
		cChave := xFilial('SRD') + SRA->RA_MAT
		cChave += SRA->(RA_CC + RA_ITEM + RA_CLVL)
		cChave += cDataArqv + cVerbImp + cSeq
		cChave += cPeriodo + cSeman + cRotFol + cDtRef
		
		lIsNew := !(SRD->(dbSeek(cChave)))		
	endIf
	
Return lIsNew

/*/{Protheus.doc} SRRIsNew
(long_description)
@author philipe.pompeu
@since 12/01/2017
@version P11
@param cTp3, character, (Descrição do parâmetro)
@param cPer, character, (Descrição do parâmetro)
@param cRot, character, (Descrição do parâmetro)
@param cWeek, character, (Descrição do parâmetro)
@param cPd, character, (Descrição do parâmetro)
@param cSeq, character, (Descrição do parâmetro)
@param cData, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*/
Static Function SRRIsNew(cTp3,cPer,cRot,cWeek, cPd, cSeq, cData)
	Local lIsNew := .T.
	Local cChave := ''
	Local xOrder := ''
	
	cChave := xFilial('SRR') + SRA->RA_MAT
	
	SRR->(dbSetOrder(1))
	if(SRR->(dbSeek(cChave)))	
		//RR_FILIAL+RR_MAT+RR_TIPO3+RR_PERIODO+RR_ROTEIR+RR_SEMANA+RR_PD+RR_CC+RR_ITEM+RR_CLVL+RR_SEQ+DTOS(RR_DATA)
		xOrder := RetOrder('SRR','RR_FILIAL+RR_MAT+RR_TIPO3+RR_PERIODO+RR_ROTEIR+RR_SEMANA+RR_PD+RR_CC+RR_ITEM+RR_CLVL+RR_SEQ+DTOS(RR_DATA)')	
		SRR->(dbSetOrder(xOrder))
		
		cChave += cTp3 + cPer + cRot + cWeek + cPd
		cChave += SRA->(RA_CC + RA_ITEM + RA_CLVL)
		cChave += cSeq + cData
		
		lIsNew := !(SRR->(dbSeek(cChave)))		
	endIf
	
Return lIsNew
