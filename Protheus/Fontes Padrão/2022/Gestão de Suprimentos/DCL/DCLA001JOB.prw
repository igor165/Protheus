#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "tbiconn.ch"

//--------------------------------
//Esqueminha para remover warning
Function __DCLA001JOB()
Scheddef()
Return
//--------------------------------

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLA001
Funco principal para JOB ANP45

@author Alexandre Gimenez
@since 05/5/2016
@version P12
/*/
//-------------------------------------------------------------------
Function DCLA001JOB(aParam)
Local cTime	:= Time()

conout("Iniciado Job - ANP45" )
DCLA001Proc(.T.)
conout("Finalizado Job - ANP45 - Tempo Total " + ElapTime(cTime, Time()) )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Scheddef
Funco Scheddef para configurar Job

@author Alexandre Gimenez
@since 05/5/2016
@version P12
/*/
//-------------------------------------------------------------------
Static Function SchedDef()
Local aParam  := {}

aParam := { "P"	,;	//Tipo R para relatorio P para processo
            		,;	//Pergunte do relatorio, caso nao use passar ParamDef
            		,;	//Alias
            		,;	//Array de ordens
            }			//Titulo

Return aParam

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLA001Proc
Funco de menu para reprocessar ANP45

@author Alexandre Gimenez
@since 05/5/2016
@version P12
/*/
//-------------------------------------------------------------------
Static Function DCLA001Proc(lJob)
local dData	:= Date()	// Data de Referencia
Local lFilial	:= .F.			// .T. Processa somente filial Logada / .F. Todas as filiais
Local lSemana	:= .T.			// .T. Processa semana toda / .F. Somente data de referencia
Local cProd	:= ""			// Range produtos
Local aProd	:= {}
Local aSemana	:= {}
Local lProc	:= .T.
Local cMsg		:= ""
Local cWhereProd	:= ""
Local cAliasProd	:= GetNextAlias()
Local oProcess
Local dDataAux := Date()
Local nDiaSem  := 0

Default lJob		:= .F.

Private cTime := Time()

If lJob	
	lProc := .T.
Else
	lProc :=  Pergunte("ANP45REP")
EndIf

If lProc	
	//---------------------------
	// Variaveis  Pergunte
	//---------------------------
	MakeSqlExp("ANP45REP")
	dData	:= IIF(lJob,Date(), MV_PAR01)
	cProd	:= IIF(lJob,""		, MV_PAR02)
	lSemana:= IIF(lJob,.F.		, MV_PAR03 == 1 )
	lFilial:= IIF(lJob,.F.		, MV_PAR04 == 2 )
	If !lJob
		//---------------------------
		// Validação de Datas
		//---------------------------
		nDiaSem := DOW (dData)
		If nDiaSem = 1
			nDiaSem := 8
		EndIf
		If nDiaSem > 4   
			dDataAux := dData - (nDiaSem-5)  
		else
			dDataAux := dData + (5-nDiaSem)
		EndIf
		
		aSemana	:= ANP45Data(dDataAUX) 
		If lSemana 
			If aSemana[3] >= Date()
				lProc := .F.
			EndIf
		Else
			If dData >= Date()
				lProc := .F.
			Else
				dDataAUX := dData
			EndIf
		EndIf
	EndIf
	If !lProc
		cMsg := "A data de processmento é superior a data atual, não é possivel reprocessar"
	Else
		//---------------------------
		// Monta Array de Produtos
		//---------------------------
		
		If !Empty(cProd)
			cWhereProd := "%" + cProd + "%"
		EndIf
		
		
		BeginSql Alias cAliasProd
			SELECT B1_COD
				FROM	%Table:SB1% SB1 
					JOIN %Table:DH5% DH5
					ON SB1.B1_COD = DH5.DH5_COD
					AND SB1.B1_FILIAL = DH5.DH5_FILIAL
					WHERE SB1.%NotDel% 
					AND SB1.B1_FILIAL = %xFilial:SB1%
					AND DH5.DH5_FILIAL = %xFilial:DH5%
					AND DH5.DH5_ANP45 = 'T'
					AND SB1.%NotDel% AND	DH5.%NotDel%
					AND %Exp:cWhereProd%
		EndSql	
		
		While !(cAliasProd)->(EOF())	
			aAdd(aProd,(cAliasProd)->B1_COD)
			(cAliasProd)->(DbSkip())
		EndDo
		(cAliasProd)->(DbCloseArea())
		If Len(aProd) == 0
			cMsg := "Não existem produtos configurados a processar. Verifique o cadastro de produto o campo ANP45"
			lProc := .F.
		Endif
	EndIf
	
	If lProc
		If lJob 
			DCLJobProc(aProd,dDataAux,lFilial)
		Else
			//---------------------------
			// Reprocessamento (Menu) 
			//---------------------------
			oProcess := MSNewProcess():New( { | lEnd | DCL001Reproc( @oProcess,@lEnd, aProd,dDataAux,lFilial,lSemana  ) }, "Reprocessando Relatório ANP45", "Reprocessando", .F. )
			oProcess:Activate()
		EndIf
	Else
		If lJob
			conout("DCLJobProc - "+ cMsg)
		Else
			Help(" ",1,"DCL001PROC",,cMsg,1,0)
		EndIf
	EndIf
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLJobProc
Funco para Processar ANP45 por job

@author Alexandre Gimenez
@since 05/5/2016
@version P12
/*/
//-------------------------------------------------------------------
Function DCLJobProc(aProd,dData,lFilial)
Local lGrava	:= .T. // Job Sempre Grava
Local lReproc	:= .F. // Job
Local nProd	:= 0

For nProd := 1 to Len(aProd) 
	Conout("Job ANP45 - Inicou produto: "+Alltrim(aProd[nProd]))
	//------------------------
	//Processa Armazenamento
	//------------------------
	DclGrvD34(aProd[nProd],dData,lFilial,lGrava,lReproc)
	//------------------------
	// Processa Est. Transito
	//------------------------
	DclGrvD34(aProd[nProd],dData,lFilial,lGrava,lReproc,"2")
	Conout("Job ANP45 - Finalizou produto: "+Alltrim(aProd[nProd]))
Next nProd

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} DCL001Reproc
Funco para reprocessar ANP45 (Separa produtos)

@author Alexandre Gimenez
@since 05/5/2016
@version P12
/*/
//-------------------------------------------------------------------
Function DCL001Reproc( oProcess,lEnd, aProd,dData,lFilial,lSemana )
Local lGrava	:= .T. // Reprocessamento Sempre Grava
Local lReproc	:= .T. // Reprocessamento
Local nProd	:= 0
Local nData	:= 0
Local nDiasSem:= IIF(lSemana,7,1)
Local aSemana	:= ANP45Data(dData)
Local dDataPro

Static lTransito := .F.

oProcess:SetRegua1(Len(aProd))

For nProd := 1 to Len(aProd)
	oProcess:IncRegua1("Processando produto: "+Alltrim(aProd[nProd]))
	oProcess:SetRegua2(nDiasSem*2)
	lTransito := .F. //Roda transito so 1 vez na semana(Performance)
	For nData := 1 to nDiasSem
		If lSemana
			dDataPro := aSemana[2]+nData-1
		Else
			dDataPro := dData
		EndIf
		//------------------------
		//Processa Armazenamento
		//------------------------
		oProcess:IncRegua2("Armazenamento Dia: "+DTOC(dDataPro)+" Semana: "+Alltrim(Str(aSemana[1])))
		DclGrvD34(aProd[nProd],dDataPro,lFilial,lGrava,lReproc)
		//------------------------
		// Processa Est. Transito
		//------------------------
		oProcess:IncRegua2("Est. Trânsito Dia: "+DTOC(dDataPro)+" Semana: "+Alltrim(Str(aSemana[1])))
		DclGrvD34(aProd[nProd],dDataPro,lFilial,lGrava,lReproc,"2")
	Next nData
Next nProd

Return



//-------------------------------------------------------------------
/*/{Protheus.doc} DclGrvD34
Funco para gravar D34, Detalhamento ANP45

@author Alexandre Gimenez
@since 05/5/2016
@version P12
/*/
//-------------------------------------------------------------------
Function DclGrvD34(cProd,dDataReg,lFilial,lGrava,lReproc,cNature)
Local cCodReg 	:= StrZero(Val(SuperGetMV("MV_CSIMPAR",.F.,"")), 10) // pegar do simp
Local cInst1		:= StrZero(Val(SuperGetMV("MV_INSTSIM",.F.,"",cFilAnt)), 10) // Pegar do Simp Filial origem
Local cInst2		:= Replicate("0",10)
Local cInst2Branco	:= Replicate("0",10)
Local aInst2		:= {}
Local cFilOri		:= cFilAnt
Local cFilProc	:= cFilAnt
Local cWhereArm	:= ""
Local cAliasArm	:= GetNextAlias()
Local cAliasSld	:= GetNextAlias()
Local cAliasD34	:= GetNextAlias()	
Local aLocManut	:= {}
Local aFilMnt		:= {}
Local nSaldo		:= 0
Local nX			:= 0
Local nZ			:= 0
Local nI			:= 0	
Local nLastro		:= 0
Local nPosTran		:= 0
Local nPosTer		:= 0
Local cSeek		:= ""
Local lSeek		:= .F.
Local aSemana		:= ANP45Data(dDataReg)
Local nSaldoTer	:= 0
Local lSaldoTer	:= SuperGetMV("MV_ANP45TE",.F.,.F.)
Local lUsaPETN3	:= SuperGetMV("MV_SDTESN3",.F.,0) == 0
Local cArmTerDe	:= Replicate(" ",TamSx3("NNR_CODIGO")[2])
Local cArmTerAte	:= Replicate("Z",TamSx3("NNR_CODIGO")[2])
Local cDataIni		:= ""
Local cDataFin		:= ""
Local cSeekD34		:= ""

Default dDataReg	:= Date()
Default lFilial	:= .T.
Default lGrava	:= .T.
Default lReproc	:= .F.
Default cNature	:= "1" 	// 1-Armazenamento - 2 Transito

//-----------------------------------------------
//Identifica Locais de manutencao
//-----------------------------------------------
If lFilial //Somente filial corrente
	aLocManut := {DclGetLocMnt(cFilOri)[1,2]}
Else
	aLocManut:= DclGetAllMnt()
EndIf
//--------------------------------------------------

For nX := 1 to Len(aLocManut)

	If lGrava  

		//-------------------
		//Zera acumuladores
		//-------------------
		//aInst2 	:= {{cInst2,0,DtoS(dDataReg)}}
		//aInst2 	:= {{cInst2,VolTra,dDataReg,VolTer,DataOrigem}}
		aInst2 	:= {{cInst2,0,DtoS(dDataReg),0,""}}
		aFilMnt	:= DclGetFilMnt(aLocManut[nX])
		//-------------------
	
		//-----------------------------
		//Processa Filiais
		//-----------------------------
		For nZ := 1 to Len(aFilMnt)
			cFilProc := aFilMnt[nZ,1]
			DclMTChangeF(cFilProc)// Troca a filial do sistema
			
			//-------------------
			//Zera acumuladores
			//-------------------
			nSaldo 	:= 0
			nSaldoTer	:= 0
			nLastro	:= 0
			cWhereArm	:= "" 
			cInst1		:= StrZero(Val(SuperGetMV("MV_INSTSIM",.F.,"",cFilProc)), 10) // Pegar do Simp Filial origem
			//-------------------
			
			If cNature == "1"
				If lReproc 
					//------------
					//Monta Arms
					//-------------
					BeginSql Alias cAliasArm
					SELECT  NNR_FILIAL,NNR_CODIGO
						FROM	%Table:NNR% NNR
						WHERE NNR.NNR_FILIAL = %xFilial:NNR%
						AND NNR.%NotDel%
						AND NNR.NNR_ANP45 = 'T' 
					EndSql
					
					While !(cAliasArm)->(EOF()) 
						nSaldo += CalcEst(cProd,(cAliasArm)->NNR_CODIGO,dDataReg+1)[1]
						(cAliasArm)->(DbSkip())
					EndDo
					(cAliasArm)->(DBCloseArea())
				Else
					nSaldo := Dcl001SaldoANP(cProd,cFilProc)
				EndIf

				//--------------------
				//Atualiza Lastro
				//--------------------	
				nLastro	:= GetLastro(cProd,aFilMnt,cFilProc)
				//nLastro	:= GetLastro(cProd,aFilMnt)
			EndIf
	
			If cNature == "2" .And. !lTransito
				aInst2 := DclGetTran(cProd,dDataReg,aFilMnt)
				//---------------------------
				//Calcula poduto em terceiros
				//---------------------------
				If lSaldoTer
					aInst2 := MtANPTer(cProd,dDataReg)
				EndIf
			EndIf

			//---------------------------------------
			// Grava por local de instalação destino
			//---------------------------------------
			For nI := 1 To Len(aInst2)		
				
				DbSelectArea("D34") 				
				DbsetOrder(1) //D34_FILIAL+D34_FILORI+D34_NATURE+D34_CODREG+D34_INST1+D34_INST2+D34_LOCMNT+D34_CODPRO+D34_DATA+D34_DATAOR
				If lSaldoTer .And. aInst2[nI,4] != 0
					//Quando for estoque em terceiros, o codigo do terceiro tem que ficar no inst1 e o inst2 com zero
					cSeek := xFilial("D34")+cFilProc+cNature+cCodReg+aInst2[nI,1]+cInst2Branco+aLocManut[nX]+cProd+aInst2[nI,3]+aInst2[nI,5]
				Else
					cSeek := xFilial("D34")+cFilProc+cNature+cCodReg+cInst1+aInst2[nI,1]+aLocManut[nX]+cProd+aInst2[nI,3]+aInst2[nI,5]
				EndIf 

				lSeek := D34->(MsSeek(cSeek))	
			
				If lSeek
					Reclock("D34",.F.)
						D34_LASTRO	:= nLastro						
						D34_VOLTRA	:= aInst2[nI,2]
						If lSaldoTer 
							If aInst2[nI,4] == 0 // Tem saldo em terceiro
								D34_VOLLOC	:= nSaldo	
							Else
								D34_VOLLOC	:= 0
							EndIf	
							D34_VOLTER	:= aInst2[nI,4]
						Else
							D34_VOLLOC	:= nSaldo
						EndIf	
					MsUnlock()		
				Else
					RecLock("D34",.T.)
						D34_FILIAL	:= xFilial("D34") //compartilhado
						D34_FILORI	:=	cFilProc
						D34_NATURE	:= cNature
						D34_CODREG	:= cCodReg
						If lSaldoTer .And. aInst2[nI,4] != 0 
							//Quando for estoque em terceiros, o codigo do terceiro tem que ficar no inst1 e o inst2 com zero
							D34_INST1	:= aInst2[nI,1]
							D34_INST2	:= cInst2Branco						
						Else
							D34_INST1	:= cInst1
							D34_INST2	:= aInst2[nI,1]
						EndIf
						D34_LOCMNT	:= aLocManut[nX]
						D34_CODPRO	:= cProd
						D34_SEMANA	:= ANP45Data(dDataReg)[1]
						D34_ANOREF	:= ANP45MesAno(dDataReg,"A")
						D34_DATA	:= StoD(aInst2[nI,3])
						D34_LASTRO	:= nLastro						
						D34_VOLTRA	:= aInst2[nI,2]
						D34_DATAOR	:= StoD(aInst2[nI,5])
						If lSaldoTer 
							If aInst2[nI,4] == 0 // Tem saldo em terceiro
								D34_VOLLOC	:= nSaldo	
							Else
								D34_VOLLOC	:= 0
							EndIf	
							D34_VOLTER	:= aInst2[nI,4]
						Else
							D34_VOLLOC	:= nSaldo
						EndIf
					D34->(MsUnlock())
				EndIf
				//----------------
				// Atu Sintetico
				//----------------
				DclGrvD39(dDataReg)
			Next nI

			//-----------------------
			//Valida terceiro que 
			//deixou de ser.
			//-----------------------
			cDataIni :=  DtoS(dDataReg)
			If lSaldoTer
				BeginSql Alias cAliasD34
					Select D34_INST1,R_E_C_N_O_ RecD34
						from %Table:D34% D34
					WHERE D34.D34_FILIAL = %xFilial:D34%
						AND D34.D34_FILORI = %Exp:cFilProc%
						AND D34.D34_NATURE = %Exp:cNature%
						AND D34.D34_CODREG = %Exp:cCodReg%
						AND D34.D34_LOCMNT = %Exp:aLocManut[nX]%
						AND D34.D34_CODPRO = %Exp:cProd%
						AND D34.D34_VOLTER > 0
						AND D34.D34_DATA = %Exp:cDataIni%
						AND D34.%NotDel%
				EndSql
				
				While !((cAliasD34)->(Eof()))
					nPosTer :=  aScan(aInst2, {|X| X[1] == (cAliasD34)->D34_INST1}) //Valida se item da query existe no Array
					If nPoster == 0 // Não tem no array, então não é mais terceiro.
						D34->(DbGoto((cAliasD34)->RecD34))
						cSeekD34	:= D34->(D34_NATURE+D34_CODREG+D34_INST1+D34_INST2+D34_LOCMNT+D34_CODPRO)
						Reclock("D34",.F.)
						dbDelete()
						MsUnlock()
						// Atu Sintetico
						DclGrvD39(dDataReg,cSeekD34)
					EndIf				
					(cAliasD34)->(DbSkip())	
				EndDo
				(cAliasD34)->(DbCloseArea())
			EndIf

			//----------------------------
			// Busca Transito gravado, 
			// que não  é mais transito 
			//-----------------------------
			If cNature == "2" 
				
				cDataIni := DtoS(aSemana[2]) // Primeiro dia
				cDataFin := DtoS(dDataReg) // dia do processamento
				
				BeginSql Alias cAliasD34
					SELECT  R_E_C_N_O_ as RecD34
							FROM 	%Table:D34% D34
								WHERE D34.D34_FILIAL = %xFilial:D34%
									AND D34.D34_FILORI = %Exp:cFilProc%
									AND D34.D34_NATURE = %Exp:cNature%
									AND D34.D34_CODREG = %Exp:cCodReg%
									AND D34.D34_INST1  = %Exp:cInst1%
									AND D34.D34_LOCMNT = %Exp:aLocManut[nX]%
									AND D34.D34_CODPRO = %Exp:cProd%
									AND D34.%NotDel%
									//AND D34.D34_DATA >= %Exp:cDataIni%
									AND D34.D34_DATA = %Exp:cDataFin%
								ORDER BY D34.D34_DATAOR,D34.D34_DATA
				EndSql
				While !((cAliasD34)->(Eof()))
					D34->(DbGoto((cAliasD34)->RecD34))
					nPosTran :=  aScan(aInst2, {|X| X[1] == D34->D34_INST2 .And.  X[5] == Dtos(D34->D34_DATAOR)  })
					If nPosTran == 0  //Registro não encontrado, Não tem transito	
						cSeekD34	:= D34->(D34_NATURE+D34_CODREG+D34_INST1+D34_INST2+D34_LOCMNT+D34_CODPRO)
						Reclock("D34",.F.)
						dbDelete()
						MsUnlock()						
						// Atu Sintetico
						DclGrvD39(dDataReg,cSeekD34)
					Else
						If D34->D34_VOLTRA != aInst2[nPosTran,2]
							Reclock("D34",.F.)
							D34_VOLTRA	:= aInst2[nPosTran,2]
							MsUnlock()						
							// Atu Sintetico
							DclGrvD39(dDataReg)							
						EndIf
					EndIf
					(cAliasD34)->(DbSkip())					
				EndDo
				
				(cAliasD34)->(DbCloseArea())
			EndIf
			DclMTChangeF(cFilOri) // Volta Filial do Sistema	
		Next Nz		
	EndIf
Next nX

If cNature == "2" .And. !lTransito
	// Marca transito como executado
	lTransito := .T.
EndIf
Return nSaldo

//-------------------------------------------------------------------
/*/{Protheus.doc} DclGrvD39
Funco para gravar/atualizar D39, Aglutinado ANP45

@author Alexandre Gimenez
@since 05/5/2016
@version P12
/*/
//-------------------------------------------------------------------
Static Function DclGrvD39(dDataReg)
Local cSeekD34	:= D34->(D34_NATURE+D34_CODREG+D34_INST1+D34_INST2+D34_LOCMNT+D34_CODPRO)
Local lSeek		:= .F.
Local nESMD		:= 0
Local aDados		:= Array(7)
Local lSaldoTer	:= SuperGetMV("MV_ANP45TE",.F.,.F.)
Local nEsmObj	:= 0
Local cMes		:= ANP45MesAno(dDataReg,"M") 
Local cAno		:= ANP45MesAno(dDataReg,"A")

Default cSeekD34	:= D34->(D34_NATURE+D34_CODREG+D34_INST1+D34_INST2+D34_LOCMNT+D34_CODPRO)


cSeekD34 += STR(D34->D34_SEMANA,TamSx3("D34_SEMANA")[1])

DbSelectArea("D39") 
DbsetOrder(1) 
lSeek := D39->(MsSeek(xFilial("D39")+cSeekD34))
			
If !lSeek

	DbSetOrder(2)//D39_FILIAL+D39_CODREG+D39_LOCMNT+D39_CODPRO+D39_MES+D39_ANO
	If D39->(DbSeek(xFilial("D39")+D34->(D34_CODREG+D34_LOCMNT+D34_CODPRO)+cMes+cAno))
		nEsmObj := D39->D39_ESDMOB
	Else
		nEsmObj := DclGetESDOB(D34->D34_CODPRO,D34->D34_LOCMNT,dDataReg)
	EndIf

	//----------------------
	// Cadastra novo item
	//----------------------
	RecLock("D39",.T.)
		D39_FILIAL	:= xFilial("D39") //compartilhado
		D39_NATURE	:= D34->D34_NATURE
		D39_CODREG	:= D34->D34_CODREG
		D39_INST1	:= D34->D34_INST1
		D39_INST2	:= D34->D34_INST2
		D39_LOCMNT	:= D34->D34_LOCMNT
		D39_CODPRO	:= D34->D34_CODPRO
		D39_SEMANA	:= D34->D34_SEMANA
		D39_MES	:= ANP45MesAno(dDataReg,"M") 
		D39_ANOREF	:= ANP45MesAno(dDataReg,"A")
		If lSaldoTer
			D39->D39_ESMD	:= (D34->D34_VOLLOC +D34->D34_VOLTER+ D34->D34_VOLTRA)
		Else
			D39->D39_ESMD	:= (D34->D34_VOLLOC + D34->D34_VOLTRA)	
		EndIf
		D39_ESDMOB	:= DclGetESDOB(D39_CODPRO,D39_LOCMNT,dDataReg)
		D39_OBS	:= GetObs(DclGetFilMnt(D34->D34_LOCMNT))
	D39->(MsUnlock())
Else
	//----------------------
	// Atualiza ESMD
	//----------------------
	aDados[1] := D34->D34_NATURE
	aDados[2] := D34->D34_CODREG
	aDados[3] := D34->D34_INST1
	aDados[4] := D34->D34_INST2
	aDados[5] := D34->D34_LOCMNT
	aDados[6] := D34->D34_CODPRO
	aDados[7] := D34->D34_SEMANA
	nESMD := DclGetESMD(aDados)

	RecLock("D39",.F.)
		D39_ESMD := nESMD
	D39->(MsUnlock())
	
	
EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Dcl001SaldoANP(aFil)
Funco para recuperar o saldo atual SB2 
somando as filiais 

@author Alexandre Gimenez
@since 05/5/2016
@version P12
/*/
//-------------------------------------------------------------------
Function Dcl001SaldoANP(cProd,cFil)
Local nRet			:= 0
Local nZ			:= 0
local cLocMnt		:= DclGetLocMnt(cFilAnt)[1,2]
Local aFilMnt 	:= DclGetFilMnt(cLocMnt)
Local cWhereArm	:= ""
Local cAliasSld	:= GetNextAlias()
Local nTamFil		:= Len(AllTrim(xFilial("NNR")))

Default cFil := ''

If Empty(cFil)
	//----------------------
	//Where Filiais LocMnt
	//----------------------		
	For nZ := 1 to Len(aFilMnt)
		If nZ != 1
			cWhereArm += " OR "
		EndIf
			cWhereArm += " SB2.B2_FILIAL = '"+ aFilMnt[nZ,1] +"'"
	Next nz
Else
	cWhereArm := " SB2.B2_FILIAL = '" + cFil +"'"
EndIf 
cWhereArm := '% ('+ cWhereArm + ' )%'

//----------------------
//Busca Saldo Atual 
//----------------------		
BeginSql Alias cAliasSld
SELECT SUM(B2_QATU) SOMASALDO
	FROM %Table:SB2% SB2	
	JOIN %Table:NNR% NNR ON NNR.%NotDel% 
		AND NNR.NNR_FILIAL = SUBSTRING(SB2.B2_FILIAL,1,%Exp:nTamFil%) 
		AND NNR.NNR_CODIGO = SB2.B2_LOCAL 
		AND NNR.NNR_ANP45 = 'T'
WHERE SB2.%NotDel%  
	AND SB2.B2_COD = %Exp:cProd%
	AND %Exp:cWhereArm%
EndSql	 
//----------------------
//Atualiza Saldo Atual
//----------------------			
nRet := (cAliasSld)->SOMASALDO
(cAliasSld)->(dbCloseArea())	

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetLastro
Funco para recuperar o lastro dos tanques de um produto

@author Alexandre Gimenez
@since 05/5/2016
@version P12
/*/
//-------------------------------------------------------------------
Static Function GetLastro(cProd,aFiliais,cFilProc)
Local nRet :=0
Local cAliasLastro := GetNextAlias()
Local nX := 0
Local cWhere := ""

Default cFilProc	:= ""

If Empty(cFilProc) 	
	For nX := 1 To Len(aFiliais)
		If Empty(cWhere)
			cWhere := " ( DHG_FILIAL = '" +  aFiliais[nX,1] + "'"
		Else
			cWhere += " Or DHG_FILIAL = '" +  aFiliais[nX,1] + "'"
		EndIf
	Next nX
		cWhere := "%" + cWhere + ")%"
Else
	cWhere := "%"+" DHG_FILIAL = '"+cFilProc+"'"+"%"
EndIf
//Obs tabela DHG sempre exclusiva

	BeginSql Alias cAliasLastro
		SELECT Distinct  DHG_FILIAL,DHG_TANQUE,DHG_CODPRO,DHG_LASTRO
		FROM	%Table:DHG% DHG
		JOIN %Table:SB1% SB1	
		ON SB1.B1_COD = DHG.DHG_CODPRO
			AND SB1.B1_FILIAL = DHG.DHG_FILIAL 
			AND SB1.%NotDel%
		JOIN %Table:DH5% DH5 
		ON SB1.B1_COD = DH5.DH5_COD
			AND DH5.DH5_ANP45 = 'T'	
			AND SB1.B1_FILIAL = DH5.DH5_FILIAL 
		WHERE DHG.%NotDel% 
		AND %Exp:cWhere%
	EndSql
	
	While !(cAliasLastro)->(EOF())
		nRet += (cAliasLastro)->DHG_LASTRO
		(cAliasLastro)->(dbSkip())
	EndDo

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetObs
Funco para criar obs com filiais do sistema no local de manutencao

@author Alexandre Gimenez
@since 05/5/2016
@version P12
/*/
//-------------------------------------------------------------------
Static Function GetObs(aFiliais)
Local nX	:= 0
Local cRet	:= " Filiais "
Local cFil	:= ""

For nX := 1 To Len(aFiliais)
	If cFil != aFiliais[nX,1]
		cRet += " - " + aFiliais[nX,1]
	EndIf	
Next nX


Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DclGetESMD
Calcula a media de estoque mensal conforme outros registros

aDados[1] - D34->D34_NATURE
aDados[2] - D34->D34_CODREG
aDados[3] - D34->D34_INST1
aDados[4] - D34->D34_INST2
aDados[5] - D34->D34_LOCMNT
aDados[6] - D34->D34_CODPRO
aDados[7] - D34->D34_SEMANA

@author Alexandre Gimenez
@since 05/5/2016
@version P12
/*/
//-------------------------------------------------------------------
Function DclGetESMD(aDados)
Local cAliasMed := GetNextAlias()
Local nRet			:= 0
Local nSoma		:= 0
Local nCount		:= 0
Local cCampos		:= ""
Local lSaldoTer	:= SuperGetMV("MV_ANP45TE",.F.,.F.)

If lSaldoTer
	cCampos := "%D34_VOLLOC + D34_VOLTRA + D34_VOLTER%"
Else
	cCampos := "%D34_VOLLOC + D34_VOLTRA%"
EndIf

//----------------------
// Atualiza saldo
//----------------------
BeginSql Alias cAliasMed
SELECT  SUM(%Exp:cCampos%) ESMD_MEDIA, D34_DATA
	FROM	%Table:D34% D34
WHERE D34.%NotDel%
	AND D34_NATURE	= %Exp:aDados[1]%
	AND D34_CODREG	= %Exp:aDados[2]%
	AND D34_INST1		= %Exp:aDados[3]%
	AND D34_INST2		= %Exp:aDados[4]%
	AND D34_LOCMNT	= %Exp:aDados[5]%
	AND D34_CODPRO	= %Exp:aDados[6]%
	AND D34_SEMANA	= %Exp:aDados[7]%
GROUP BY D34_DATA
EndSql


While !(cAliasMed)->(EOF())
	nSoma += (cAliasMed)->ESMD_MEDIA
	nCount++
	(cAliasMed)->(DbSkip())
EndDo
(cAliasMed)->(dbCloseArea())

nRet := nSoma/ 7 //Sempre dividir por 7 //nCount

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Dcl01GetWhere()
Calcula a media de estoque mensal conforme outros registros

@author Alexandre Gimenez
@since 05/5/2016
@version P12
/*/
//-------------------------------------------------------------------
Function Dcl01GetWhere()
Local cRet			:= ""
Local dDataRef	:= IIF(Empty(MV_PAR01),Date(),MV_PAR01)

//MV_PAR01 - DATA DE REFERENCIA
//MV_PAR03 - PERIODO
If MV_PAR03 == 1 //Semana
	cRet := "D39_SEMANA = "+ AllTrim(Str(ANP45Data(dDataRef)[1]))
ElseIf MV_PAR03 == 2 //Mes 
	cRet := "D39_MES = '"+ ANP45MesAno(dDataRef,"M") +"'"  
EndIf

// Sempre filtra pelo ano.
If !Empty(cRet)
	cRet += " AND "
EndIf
cRet += " D39_ANOREF = " + ANP45MesAno(dDataRef,"A")

cRet := "%"+ cRet + "%"
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ANP45Sema
Funco para retornar array com semana ANP45 Com base na data

@author Alexandre Gimenez
@since 05/5/2016
@version P12
/*/
//-------------------------------------------------------------------
Static Function ANP45Sema(nSemana,dData)
Local aRet := Array(3)
Local dDataIni

Default dData := Date()

dDataIni := ANP45IniAno(dData)

aRet[1]	:= nSemana // Semana
aRet[2]	:= dDataIni
aRet[3] := aRet[2] + 6 // Data Final da Semana

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} ANP45Data
Funco para retornar array com semana ANP45 Com base na data

@author Alexandre Gimenez
@since 05/5/2016
@version P12
/*/
//-------------------------------------------------------------------
static Function ANP45Data(dData)
Local dDataIni := ANP45IniAno(dData)
Local nSemana := VAL(RetSem(dData))
Local aRet := ANP45Sema(nSemana,dData)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ANP45MesAno
Funco para retornar o mes com base na semana ANP45 Com base na data

@author Alexandre Gimenez
@since 05/5/2016
@version P12
/*/
//-------------------------------------------------------------------
static Function ANP45MesAno(dData,cTipo)
Local cRet		:= ""
Local aSemana	:= {}
Local nDia		:= 0
Local dDataVld
Local nDiaSem
Local dDataAux

Default dData := Date()
Default cTipo	:= "M"

aSemana := ANP45Data(dData)
nDia := Day(aSemana[3])
If nDia > 4
	dDataVld := aSemana[3]// Considera como data o Ultimo dia por ter ao menos 4 dias na semana
Else
	dDataVld := aSemana[2]// Considera como data o primeiro dia por ter mais de 4 dias
EndIf

If cTipo $ "Mm" // Mês
	cRet := SUBSTR(CMONTH(dDataVld), 1, 3) 	
ElseIf cTipo $ "Aa" //Ano
	nDiaSem := DOW (dData)
	If nDiaSem = 1
		nDiaSem := 8
	EndIf
	If nDiaSem > 4   
		dDataAux := dData - (nDiaSem-5)  
	else
		dDataAux := dData + (5-nDiaSem)
	EndIf
	cRet := Str(Year(dDataAux),4)	
ElseIf cTipo == "MES" //Ano
	cRet := AllTrim(Str(MONTH(dDataVld)))	
EndIf

Return cRet



//-------------------------------------------------------------------
/*/{Protheus.doc} ANP45IniAno
Funco para o primeiro dia do ano. 

@author Alexandre Gimenez
@since 05/5/2016
@version P12
/*/
//-------------------------------------------------------------------
Static Function ANP45IniAno(dData)
Local nYear 	:= Year(dData)
Local dData1	:= CTOD("01/01/"+Str(nYear))
Local nDiaSem	:= DOW(dData1)
Local lDomingo:= .F. // - apurado de 2ª-feira a domingo de cada semana do mês corrente do ano atual
Local lAfter	:= .F. // -Mês corrente da semana: mês que abrange, no mínimo, 4 (quatro) dias da semana.
Local nFator	:= 0
Local dRet		:= dData1
Local dDataAux  := dData

nDiaSem := DOW (dData) 
If nDiaSem = 1 
	nDiaSem := 8
EndIF
If nDiaSem > 4  
	dDataAux := dData - (nDiaSem-5)  
else
	dDataAux := dData + (5-nDiaSem)
EndIf
nYear 	:= Year(dDataAux)
dData1	:= CTOD("01/01/"+Str(nYear))		

If lDomingo
	nFator := (nDiaSem - 1)
Else
	nFator := (nDiaSem - 2)
	If nFator < 0
		nFator := 6 //para quando Semana Comeca segunda e dia 1 é Domingo
	EndIf
EndIf
dRet := dData - nFator //Primeiro dia da semana.

//4 sexta,5 sabado ,6 domingo - Menos de 3 dias na semana, vale a proxima. 
If nFator > 3 
	lAfter := .T.
EndIf

If lAfter
	dRet := dRet + 7 // uma semana depois
EndIf

Return dRet	


//-------------------------------------------------------------------
/*/{Protheus.doc} DclGetTran(cProd,dDataRef,aFilMnt)
Funcao para recuperar o estoque em transito das filiais

@author Alexandre Gimenez
@since 05/5/2016
@version P12
/*/
//-------------------------------------------------------------------
Function DclGetTran(cProd,dDataRef,aFilMnt)
Local cAliasTran	:= GetNextAlias()
Local nX			:= 0
Local cWhere		:= ""
Local cWhereEst		:= ""
Local cWhereEstA1	:= ""
Local aRet			:= {}
Local aDatas		:= ANP45Data(dDataRef)
Local cDataRef		:= DtoS(dDataRef)
Local cFilCGC		:= DclMTDataFil(cFilAnt,"M0_CGC")
Local nTamFilA1	:= Len(AllTrim(xFilial("SA1")))
Local nTamFilF4	:= Len(AllTrim(xFilial("SF4")))
Local aEstados		:= StrToArray(GetEstados(cFilAnt),"|")

aDatas[2]:= DtoS(aDatas[2])
aDatas[3]:= DtoS(aDatas[3])

For nX := 1 To Len(aFilMnt)
	If Empty(cWhere)
		cWhere := " ( SD2.D2_FILIAL = '" +  aFilMnt[nX,1] + "'"
	Else
		cWhere += " OR SD2.D2_FILIAL = '" +  aFilMnt[nX,1] + "'"
	EndIf
Next nX
cWhere := "%" + cWhere + ")%"

For nX := 1 To Len(aEstados)
	If Empty(cWhereEst)
		cWhereEst := " ( SA2.A2_EST = '" +  aEstados[nX] + "'"
		cWhereEstA1:= " ( SA1.A1_EST = '" +  aEstados[nX] + "'"
	Else
		cWhereEst += " OR SA2.A2_EST = '" +  aEstados[nX] + "'"
		cWhereEstA1+= " OR SA1.A1_EST = '" +  aEstados[nX] + "'"
	EndIf
Next nX
cWhereEst := "%" + cWhereEst + ")%"
cWhereEstA1 := "%" + cWhereEstA1 + ")%"

BeginSql Alias cAliasTran

Select TAB.FILIAL, TAB.DATAORI, TAB.CODIGO,TAB.LOJA,TAB.INST,SUM(TAB.TRANSITO) as TRANSITO FROM (

	//-------------------------
	//Atualmente em transito 
	//Nota de fornecedor 
	//-------------------------
	SELECT SD1.D1_FILIAL FILIAL,
			SD1.D1_EMISSAO DATAORI,
			D30.D30_CODFOR CODIGO,
       	D30.D30_LOJFOR LOJA,
       	D30_INSTSI INST,
       	Sum(D1_QUANT) TRANSITO
	FROM %Table:SD1% SD1
		JOIN %Table:D30% D30 ON D30.D30_CODFOR = SD1.D1_FORNECE
			AND D30.D30_LOJFOR = SD1.D1_LOJA
			AND D30.%NotDel%
			AND D30.D30_FILIAL = %xFilial:D30%
		JOIN %Table:SA2% SA2 ON SA2.A2_COD = SD1.D1_FORNECE
			AND SA2.A2_LOJA = SD1.D1_LOJA
			AND SA2.%NotDel%
			AND SA2.A2_FILIAL = %xFilial:SA2%
			AND %Exp:cWhereEst% //trata mesmo local de manut
	WHERE SD1.D1_COD = %Exp:cProd%
  		AND SD1.D1_TRANSIT = 'S'
  		//AND SD1.D1_EMISSAO >= %Exp:aDatas[2]%
  		AND SD1.D1_EMISSAO <= %Exp:cDataRef% //%Exp:aDatas[3]%
  		AND SD1.D1_ORIGLAN <> 'LF'
  		AND SD1.%NotDel%
  		AND SD1.D1_FILIAL = %xFilial:SD1%
	GROUP BY SD1.D1_FILIAL,
				SD1.D1_EMISSAO,
				D30.D30_CODFOR,
    	    	D30.D30_LOJFOR,
         		D30_INSTSI
         		
UNION
	//----------------------------
	//Esteve em transito
	//Nota de fornecedor
	//----------------------------
	SELECT SD1.D1_FILIAL FILIAL,
			SD1.D1_EMISSAO DATAORI,
		 	D30.D30_CODFOR CODIGO,
       	D30.D30_LOJFOR LOJA,
       	D30_INSTSI INST,
       	SUM(D1_QUANT) TRANSITO
	FROM %Table:SD1% SD1
		JOIN %Table:SF4% SF4 ON SF4.F4_CODIGO = SD1.D1_TES
			AND SF4.F4_TRANSIT = 'S'
			AND SF4.%NotDel%
			AND SF4.F4_FILIAL = %xFilial:SF4%
		JOIN %Table:D30% D30 ON D30.D30_CODFOR = SD1.D1_FORNECE
			AND D30.D30_LOJFOR = SD1.D1_LOJA
			AND D30.%NotDel%
			AND D30.D30_FILIAL = %xFilial:D30%
		JOIN %Table:SA2% SA2 ON SA2.A2_COD = SD1.D1_FORNECE
			AND SA2.A2_LOJA = SD1.D1_LOJA
			AND SA2.%NotDel%
			AND SA2.A2_FILIAL = %xFilial:SA2%
			AND %Exp:cWhereEst% //trata mesmo local de manut
		JOIN %Table:SD3% SD3 ON SD3.D3_DOC = SD1.D1_DOC
			AND SD3.D3_COD = SD1.D1_COD
			AND SD3.D3_QUANT = SD1.D1_QUANT
			AND SD3.D3_LOCAL = SD1.D1_LOCAL
			AND SD3.D3_CF = 'DE6'
			AND SD3.D3_EMISSAO > %Exp:cDataRef% //Considera se devolveu até data atual
			AND SD3.%NotDel%
			AND SD3.D3_FILIAL = %xFilial:SD3%
	WHERE SD1.D1_COD = %Exp:cProd%
  		//AND SD1.D1_EMISSAO >= %Exp:aDatas[2]%
  		AND SD1.D1_EMISSAO <= %Exp:cDataRef% //%Exp:aDatas[3]%
  		AND SD1.D1_ORIGLAN <> 'LF'
  		AND SD1.%NotDel%
  		AND SD1.D1_FILIAL = %xFilial:SD1%
	GROUP BY SD1.D1_FILIAL,
			SD1.D1_EMISSAO,
	 		D30.D30_CODFOR,
    	   	D30.D30_LOJFOR,
         	D30_INSTSI

UNION
	//------------------------- 
	//Nota de Transferencia 
	//Sem PreNota, com PreNota e Classificado apos o periodo
	//-------------------------
	SELECT SD2.D2_FILIAL FILIAL,
			SD2.D2_EMISSAO DATAORI,
			'' CODIGO,
       	'' LOJA,
       	'' INST,
       	SUM(D2_QUANT) TRANSITO
		FROM %Table:SD2% SD2
			JOIN %Table:SA1% SA1 ON SA1.A1_COD = SD2.D2_CLIENTE
				AND SA1.A1_LOJA = SD2.D2_LOJA
				AND SA1.A1_FILIAL = SUBSTRING(SD2.D2_FILIAL,1,%Exp:nTamFilA1%) 
				AND SA1.%NotDel%
				AND (SA1.A1_FILTRF = %Exp:cFilAnt%
				     OR SA1.A1_CGC = %Exp:cFilCGC%)
				AND %Exp:cWhereEstA1% //trata mesmo local de manut
			JOIN %Table:AI0% AI0 ON AI0.A1_COD = SA1.A1_COD
				AND AI0.A1_LOJA = SA1.A1_LOJA
				AND AI0.A1_FILIAL = SA1.A1_FILIAL 
				AND AI0.%NotDel%
			JOIN %Table:SF4% SF4 ON SF4.F4_CODIGO = SD2.D2_TES
				AND SF4.F4_TRANFIL = '1'
				AND SF4.F4_FILIAL = SUBSTRING(SD2.D2_FILIAL,1,%Exp:nTamFilF4%)
				AND SF4.%NotDel%		
			LEFT JOIN %Table:SD1% SD1 ON  SD1.D1_DOC = SD2.D2_DOC 
				AND SD1.D1_SERIE = SD2.D2_SERIE
				AND SD1.D1_EMISSAO = SD2.D2_EMISSAO 
				AND SD1.D1_FILIAL = %Exp:cFilAnt%
				AND SD1.%NotDel%	
		WHERE SD2.%NotDel% 
				//AND SD2.D2_EMISSAO >= %Exp:aDatas[2]%
				AND SD2.D2_EMISSAO <= %Exp:cDataRef% // %Exp:aDatas[3]%
      			//Trata Transito
      			AND (SD1.D1_TES IS NULL 
      					OR SD1.D1_TES = ' ' 
      					OR SD1.D1_DTDIGIT > %Exp:cDataRef%)	
      			//Trata Filais
      			AND %Exp:cWhere%	
		GROUP BY SD2.D2_FILIAL,
				SD2.D2_EMISSAO,
				SA1.A1_COD,
         		SA1.A1_LOJA,
         		AI0_CODINS


		//--
		UNION
	//-------------------------
	//Atualmente em transito 
	//Pré nota de fornecedor 
	//-------------------------
	SELECT SD1.D1_FILIAL FILIAL,
			SD1.D1_EMISSAO DATAORI,
			SA2.A2_COD CODIGO,
       	SA2.A2_LOJA LOJA,
       	D30_INSTSI INST,
       	Sum(D1_QUANT) TRANSITO
	FROM %Table:SD1% SD1
		JOIN %Table:D30% D30 ON D30.D30_CODFOR = SD1.D1_FORNECE
			AND D30.D30_LOJFOR = SD1.D1_LOJA
			AND D30.%NotDel%
			AND D30.D30_FILIAL = %xFilial:D30%
	WHERE SD1.D1_COD = %Exp:cProd%
  		AND SD1.D1_T_ANP45 = '1'
  		AND SD1.D1_TES = ' '
  		//AND SD1.D1_EMISSAO = %Exp:cDataRef%
  		//AND SD1.D1_EMISSAO >= %Exp:aDatas[2]%
  		AND SD1.D1_EMISSAO <= %Exp:cDataRef% //%Exp:aDatas[3]%
  		AND SD1.D1_ORIGLAN <> 'LF'
  		AND SD1.%NotDel%
  		AND SD1.D1_FILIAL = %xFilial:SD1%
	GROUP BY SD1.D1_FILIAL,
				SD1.D1_EMISSAO,
				SA2.A2_COD,
    	    	SA2.A2_LOJA,
         		D30_INSTSI
         		
UNION         		
	//-------------------------
	//Atualmente em transito 
	//Pré nota de fornecedor 
	//-------------------------
	SELECT SD1.D1_FILIAL FILIAL,
			SD1.D1_EMISSAO DATAORI,
			SA2.A2_COD CODIGO,
       	SA2.A2_LOJA LOJA,
       	D30_INSTSI INST,
       	Sum(D1_QUANT) TRANSITO
	FROM %Table:SD1% SD1
		JOIN %Table:D30% D30 ON D30.D30_CODFOR = SD1.D1_FORNECE
			AND D30.D30_LOJFOR = SD1.D1_LOJA
			AND D30.%NotDel%
			AND D30.D30_FILIAL = %xFilial:D30%
	WHERE SD1.D1_COD = %Exp:cProd%
  		AND SD1.D1_T_ANP45 = '1'
  		AND SD1.D1_TES <> ' ' //Tes Preenchida
  		//AND SD1.D1_EMISSAO >= %Exp:aDatas[2]% // Emitida na semana
  		AND SD1.D1_EMISSAO <= %Exp:cDataRef% // Emitida na semana 
  		AND SD1.D1_DTDIGIT > %Exp:cDataRef% // Recebida na semana seguinte
  		AND SD1.D1_ORIGLAN <> 'LF'
  		AND SD1.%NotDel%
  		AND SD1.D1_FILIAL = %xFilial:SD1%
	GROUP BY SD1.D1_FILIAL,
				SD1.D1_EMISSAO,
				SA2.A2_COD,
    	    	SA2.A2_LOJA,
         		D30_INSTSI         		

)As TAB GROUP BY TAB.FILIAL, TAB.DATAORI, TAB.CODIGO,TAB.LOJA,TAB.INST
		//--

EndSql

While !(cAliasTran)->(EOF()) 
	If Empty((cAliasTran)->(CODIGO+LOJA+INST))
		aAdd(aRet,{StrZero(Val(SuperGetMV("MV_INSTSIM",.F.,"",(cAliasTran)->FILIAL)), 10) ,;
						(cAliasTran)->TRANSITO,;
						 (cAliasTran)->DATAORI})
	Else
		aAdd(aRet,{PadR((cAliasTran)->INST,10),;
						(cAliasTran)->TRANSITO,;
						 (cAliasTran)->DATAORI})
	EndIf
	(cAliasTran)->(DbSkip())
EndDo
(cAliasTran)->(DbCloseArea())

Return aRet	
//-------------------------------------------------------------------
/*/{Protheus.doc} DclGetESDOB(D39_CODPRO,D39_LOCMNT,D39_MES,D39_ANO)
Funcao montar query que retorna o estoque objetivo do local de manutencao no periodo

@author Alexandre Gimenez
@since 05/5/2016
@version P12
/*/
//-------------------------------------------------------------------
Function DclGetESDOB(cCodPro,cLocMnt,dDataReg)
Local nRet 		:= 0
Local nX			:= 0
Local aFiliais	:= DclGetFilMnt(cLocMnt)
Local nDias		:= DclGetLocMnt(aFiliais[1,1])[1,3]
Local cWhereFil	:= ""
Local cAliasESD	:= GetNextAlias()
Local dRef			:= DclANPIniMes(dDataReg)
Local dDataIni	:= DclANPIniMes(CTOD("15/"+ANP45MesAno(dRef,"MES")+"/"+Str(Val(ANP45MesAno(dRef,"A"))-1,4)))
Local dDataFim
Local cDataIni
Local cDataFim
Local aArea		:= GetArea()

If Month(dRef) == 12
	dDataFim := DclANPIniMes(CTOD("15/01/"+ANP45MesAno(dRef,"A")))
Else
	dDataFim := DclANPIniMes(CTOD("15/"+Str(Val(ANP45MesAno(dRef,"MES"))+1)+"/"+Str(Val(ANP45MesAno(dRef,"A"))-1,4))) 
EndIf

cDataIni := DtoS(dDataIni)
cDataFim := DtoS(dDataFim)

For nX := 1 to Len(aFiliais)
	If nX != 1
		cWhereFil += ' OR '
	EndIf
	cWhereFil += " D2_FILIAL =  '"+aFiliais[nX,1]+"'"	 
Next nX
cWhereFil := "%("+ cWhereFil +" )%"

BeginSql Alias cAliasESD
	SELECT SUM(ISNULL(SG1.G1_QUANT * SD2.D2_QUANT, SD2.D2_QUANT)) QUANT
		FROM %Table:SD2% SD2
			JOIN %Table:SF4% SF4 ON SF4.F4_CODIGO = SD2.D2_TES
				AND SF4.F4_ESTOQUE = 'S'
				AND SF4.F4_FILIAL = %xFilial:SF4%
				AND SF4.%NotDel%
			JOIN %Table:DH5% DH5 ON DH5.DH5_COD = SD2.D2_COD
				AND DH5.DH5_FILIAL = %xFilial:DH5%
				AND DH5.%NotDel%
			JOIN %Table:SA1% SA1 ON SA1.A1_COD = SD2.D2_CLIENTE
				AND SA1.A1_LOJA = SD2.D2_LOJA 
				AND SA1.A1_FILIAL = %xFilial:SA1%
				AND SA1.%NotDel%
			LEFT JOIN %Table:SG1% SG1 ON SG1.G1_COD = SD2.D2_COD
				AND SG1.G1_COMP IN (SELECT DH5X.DH5_COD 
									FROM %Table:DH5% DH5X 
										WHERE DH5X.DH5_ANP45 = 'T'
											AND DH5X.DH5_FILIAL = %xFilial:DH5% 
											AND DH5X.%NotDel%)
				AND SG1.G1_INI <= %Exp:cDataIni%
				AND SG1.G1_FIM > %Exp:cDataFim%
				AND SG1.G1_FILIAL = %xFilial:SG1%
				AND SG1.%NotDel%
		WHERE  NOT (DH5.DH5_ANP45 = 'F' AND SG1.G1_COMP IS NULL)
  				AND SD2.D2_EMISSAO >= %Exp:cDataIni% 
				AND SD2.D2_EMISSAO < %Exp:cDataFim% 
  				AND SD2.D2_ORIGLAN <> 'LF'
  				AND IsNull(SG1.G1_COMP,SD2.D2_COD) = %Exp:cCodPro%
  				AND %Exp:cWhereFil%
  				AND SD2.%NotDel%
EndSQL	

nRet := ( (cAliasESD)->QUANT / 30 ) * nDias
	
(cAliasESD)->(DbCloseArea())
 
 RestArea(aArea)
  				
Return nRet	 
//-------------------------------------------------------------------
/*/{Protheus.doc} DclGetLocMnt(cFil)
Funcao para recuperar Locais de manutenção

@author Alexandre Gimenez
@since 05/5/2016
@version P12
/*/
//-------------------------------------------------------------------
Function DclGetLocMnt(cFil,cEst,lIgual)
Local aRet 	:= {}
Local aLocais := {}
Local aFiliais:= {}
Local nX		:=	0
Local nLocal	:=	0
Local cTipo	:= SuperGetMv("MV_ANP",.F.,'D')
Local aAreaSM0:= SM0->(GetArea())

Default cFil := ""
Default cEst 	:= ""
Default lIgual:= .F.

//------------------
//Tabela ANP
//------------------
If cTipo == "P"
	//--------------------------------------------
	// para produtores de derivados de petrolio
	//--------------------------------------------
	aAdd(aLocais,{"AC|AM|RO|RR|PA|AP",5})//1 Unidades Federadas da Região Norte, exceto TO
	aAdd(aLocais,{"BA|SE|AL|PE|PB|RN|CE|PI|MA|TO",5})//2 TO e Unidades Federadas da Região Nordeste
	aAdd(aLocais,{"ES|MG|MS|MT|RJ|SP|DF|GO",3})//3 Unidades Federadas da Região Centro-Oeste e Sudeste
	aAdd(aLocais,{"PR|SC|RS",3})//4 Unidades Federadas da Região Sul
Else
	//--------------------------------------------
	//para distribuidores de combustiveis
	//-------------------------------------------- 
	aAdd(aLocais,{"AC|AM|AP|PA|RO|RR",5})//1 Unidades Federadas da Região Norte, exceto TO
	aAdd(aLocais,{"BA|SE",3})//2 BA e SE
	aAdd(aLocais,{"AL|CE|MA|PB|PE|PI|RN|TO",5})//3 TO e Unidades Federadas da Região Nordeste, com exceção de BA e SE
	aAdd(aLocais,{"DF|ES|GO|MG|MS|MT|RJ|SP",3})//4 Unidades Federadas da Região Centro-Oeste e Sudeste
	aAdd(aLocais,{"PR|SC|RS",3})//5 Unidades Federadas da Região Sul
EndIf

SM0->(dbSetOrder(1))

IF Empty(cFil)
	aFiliais := FwLoadSM0()
	For nX := 1 To len(aFiliais)
		If aFiliais[nX,SM0_GRPEMP] == cEmpAnt
			SM0->(MsSeek(cEmpAnt+aFiliais[nX,SM0_CODFIL]))
			nLocal := aScan(aLocais, {|x| SM0->M0_ESTENT $ x[1]})
			aAdd(aRet,{aFiliais[nX,SM0_CODFIL],Str(nLocal,1),aLocais[nLocal,2]})
		EndIf	
	Next nX 
Else
	SM0->(MsSeek(cEmpAnt+cFil))
	nLocal := aScan(aLocais, {|x| SM0->M0_ESTENT $ x[1]})
	aAdd(aRet,{cFil,Str(nLocal,1),aLocais[nLocal,2]})
	If !Empty(cEst)
		lIgual := cEst $ aLocais[nLocal,1]  
	EndIf 	
EndIf

RestArea(aAreaSM0)	
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DclGetFilMnt(cLocal)
Funcao para as Filiais de um mesmo Local de manutenção

@author Alexandre Gimenez
@since 05/5/2016
@version P12
/*/
//-------------------------------------------------------------------
Function DclGetFilMnt(cLocal)
Local aAllFil	:= DclGetLocMnt()
Local nX		:= 0
Local aRet		:= {}

For	nX := 1 To Len(aAllFil)
	If ( aScan(aRet, {|x| x == aAllFil[nX,2] }) == 0 )
		aAdd(aRet,aAllFil[nX])	
	EndIf
Next nX

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} DclGetAllMnt()
Funcao para as Filiais de um mesmo Local de manutenção

@author Alexandre Gimenez
@since 05/5/2016
@version P12
/*/
//-------------------------------------------------------------------
Function DclGetAllMnt()
Local aAllFil	:= DclGetLocMnt()
Local nX		:= 0
Local cLocal	:= ""
Local aRet		:= {}

For	nX := 1 To Len(aAllFil)
	If aAllFil[nX,2] != cLocal
		cLocal := aAllFil[nX,2]
		aAdd(aRet,aAllFil[nX,2])	
	EndIf
Next nX

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DclANPIniMes()
Funcao para identificar inicio e fim do mes segundo ANP

@author Alexandre Gimenez
@since 05/5/2016
@version P12
/*/
//-------------------------------------------------------------------
Function DclANPIniMes(dDataRef)
Local dRet	
Local cMes 	:= ANP45MesAno(dDataRef,"MES")
Local cAno		:= ANP45MesAno(dDataRef,"A")
Local nFator  := 0

If Val(cMes) ==  Val(ANP45MesAno(CTOD("01/"+cMes+"/"+cAno),"MES"))
	nFator := ( DOW(CTOD(("01/"+cMes+"/"+cAno))) - 2)
	If nFator < 0 //Nunca vai entrar
		nFator := 6 //para quando Semana Comeca segunda e dia 1 é Domingo
	EndIf
	dRet := CTOD("01/"+cMes+"/"+cAno) - nFator
Else
	nFator := ( DOW(CTOD(("01/"+cMes+"/"+cAno))))
	If nFator == 2// se for segunda
		nFator := 0
	ElseIf nFator != 1
		nFator := 9 - nFator
	EndIf
	dRet := CTOD("01/"+cMes+"/"+cAno) + nFator
EndIf

Return dRet



//-------------------------------------------------------------------
/*/{Protheus.doc} DclMTChangeF()
Funcao para trocar de filial

@author Alexandre Gimenez
@since 05/5/2016
@version P12
/*/
//-------------------------------------------------------------------
Function DclMTChangeF(cFil)
Local aAreaSM0 := SM0->(GetArea())

SM0->(dbSetOrder(1))
If SM0->(MsSeek(cEmpAnt+cFil))
	cFilAnt := FWCodFil()
EndIf

RestArea(aAreaSM0)
Return



//-------------------------------------------------------------------
/*/{Protheus.doc} DclMTDataFil()
Funcao para retornar dado da SM0

@author Alexandre Gimenez
@since 05/5/2016
@version P12
/*/
//-------------------------------------------------------------------
Function DclMTDataFil(cFil,cData)
Local aAreaSM0 := SM0->(GetArea())
Local cRet := ''

SM0->(dbSetOrder(1))
If SM0->(MsSeek(cEmpAnt+cFil))
	cRet := SM0->&(cData)
EndIf

RestArea(aAreaSM0)
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MtANPTer()
Calcular Poder de terceiro 

@author Alexandre Gimenez
@Return aRet[1] Inst2
		 aRet[2] Saldo em Transito
		 aRet[3] Data do Registro
		 aRet[4] Saldo em Terceiro
		 
@since 10/04/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function MtANPTer(cProd,dDataReg)
Local aRet 		:= {}
Local aSaldo 		:= {}
Local lUsaPETN3	:= SuperGetMV("MV_SDTESN3",.F.,0) == 0
Local cArmTerDe	:= Replicate(" ",TamSx3("NNR_CODIGO")[1])
Local cArmTerAte	:= Replicate("Z",TamSx3("NNR_CODIGO")[1])
Local nX			:= 0
Local cInst2		:= Replicate("0",10)
Local aArea		:= GetArea()
Local lIgual		:= .F.
Local aLocal		:= {}

//Adiciona valor vazio para ser considerado local 
aADD(aRet,{cInst2,0,DtoS(dDataReg),0,""})
	
aSaldo := SaldoTerc(cProd,cArmTerDe,"E",dDataReg,cArmTerAte,.T. /*lCliFor*/,,lUsaPETN3,,,,,.F. /*lIdent*/)
DbSelectArea("SA2")
DbSetOrder(1)
For nX := 1 To Len(aSaldo)
	If !Empty(aSaldo[nX,1]) 
		If SubStr(aSaldo[nX,1],1,1) == "F" .And. SA2->(DbSeek(xFilial("SA2")+SubStr(aSaldo[nX,1],2)))  .And. aSaldo[nX,2] > 0  // Cliente+Loja
			aLocal := DclGetLocMnt(cFilAnt,SA2->A2_EST,@lIgual)	
			If lIgual
				cInst2 := PadR(SA2->A2_T_INST,10)
				If !Empty(cInst2)
					aADD(aRet,{cInst2,0,DtoS(dDataReg),aSaldo[nX,2],""})
				EndIf
			EndIf
		EndIf
	EndIf
Next nX

RestArea(aArea)
Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} GetEstados(cFil)
Funcao para recuperar Locais de manutenção

@author Alexandre Gimenez
@since 05/5/2016
@version P12
/*/
//-------------------------------------------------------------------
Static Function GetEstados(cFil)
Local aRet 		:= {}
Local aLocais	:= {}
Local cTipo		:= SuperGetMv("MV_T_ANP",.F.,'D')
Local cEst		:= DclMTDataFil(cFil,"M0_ESTENT")
Local nLocal	:= 0
//------------------
//Tabela ANP
//------------------
If cTipo == "P"
	//--------------------------------------------
	// para produtores de derivados de petrolio
	//--------------------------------------------
	aAdd(aLocais,{"AC|AM|RO|RR|PA|AP",5})//1 Unidades Federadas da Região Norte, exceto TO
	aAdd(aLocais,{"BA|SE|AL|PE|PB|RN|CE|PI|MA|TO",5})//2 TO e Unidades Federadas da Região Nordeste
	aAdd(aLocais,{"ES|MG|MS|MT|RJ|SP|DF|GO",3})//3 Unidades Federadas da Região Centro-Oeste e Sudeste
	aAdd(aLocais,{"PR|SC|RS",3})//4 Unidades Federadas da Região Sul
Else
	//--------------------------------------------
	//para distribuidores de combustiveis
	//-------------------------------------------- 
	aAdd(aLocais,{"AC|AM|AP|PA|RO|RR",5})//1 Unidades Federadas da Região Norte, exceto TO
	aAdd(aLocais,{"BA|SE",3})//2 BA e SE
	aAdd(aLocais,{"AL|CE|MA|PB|PE|PI|RN|TO",5})//3 TO e Unidades Federadas da Região Nordeste, com exceção de BA e SE
	aAdd(aLocais,{"DF|ES|GO|MG|MS|MT|RJ|SP",3})//4 Unidades Federadas da Região Centro-Oeste e Sudeste
	aAdd(aLocais,{"PR|SC|RS",3})//5 Unidades Federadas da Região Sul
EndIf

nLocal := aScan(aLocais, {|x| cEst $ x[1]})
If nLocal > 0
	aRet := aLocais[nLocal,1]
EndIf

Return aRet
