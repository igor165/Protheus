#INCLUDE "PROTHEUS.CH"
#INCLUDE "GFPX120.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GFPXFUN  ³ Autor ³ Totvs                              ³ Data ³ 08/16/2018 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcoes genericas a serem utilizadas pelo Modulo SIGAGFP - Fechamento      ³±±
±±³          ³                                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄ¿±±
±±³Programador   ³ Data   ³ PRJ/REQ-Chamado ³  Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Silvia T.     ³06/06/18³ DRHGFP-550      ³Funcoes genericas utilizadas para o modulo  ³±±
±±³				 ³        ³                 ³ SIGAGFP - Fechamento do periodo            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

//------------------------------------------------------------------------------
/*/{Protheus.doc} fDdPerAqui
Controla Período Aquisitivo dos Dias de Direito
Utilização no Fechamento da Folha de Pagamento do Ministério Público
@sample 	fDdPerAqui(cDdFil,cDdMat,cDdCat,cDdReg,dDtaIni,dDtaFim)
@param		cDdFil   - RA_FILIAL - Filial do Funcionário
			cDdMat   - RA_MAT	- Matrícula do Funcionário
			cDdCat   - RA_CATFUNC	- Categoria Funcional
			cDdReg   - RA_REGIME	- Regime de Contratação
			dDtaIni  - Inicio Periodo RCH
			dDtaFim  - Fim Periodo RCH
			aTabS106 - Array com conteúdo da Tabela S106 desta Filial
@return		Nil
@author		Tânia Bronzeri
@since		06/06/2018
@version	P.12
/*/
//------------------------------------------------------------------------------
Function fDdPerAqui(cDdFil,cDdMat,cDdCat,cDdReg,dDtaIni,dDtaFim,aTabS106,cSind)

Local aAreaSrf		:= SRF->(GetArea())
Local aAreaRia		:= RIA->(GetArea())
Local cQrySrf		:= GetNextAlias()
Local cQryRia		:= GetNextAlias()
Local cPdRia		:= ""
Local dDtBas		:= CtoD("  /  /  ")
Local dRfFim		:= CtoD("  /  /  ")
Local dRfNew		:= CtoD("  /  /  ")
Local dRf2New		:= CtoD("  /  /  ")
Local dRfDtBas		:= CtoD("  /  /  ")
Local dRfNewBas		:= CtoD("  /  /  ")
Local adRfSave		:= {CtoD("  /  /  "),CtoD("  /  /  ")}
Local nDdRia		:= 0
Local nLiqFal		:= 0
Local nMesAlt		:= 0
Local nPos106		:= 0
Local aAreaPA		:= {}
Local aNewArSrf		:= {}
Local aRdFalDev		:= {}
Local cAliasSRA     := "SRA"
Private	aTabS106	:= {}


//Busca Tabela S106 para carga do Controle de Saldo de Dias
fRetTab(@aTabS106,"S106",,,dDtaFim,,.T.)

//Busca SRF
cDdFil	:= "%'" + cDdFil + "'%"
cDdMat	:= "%'" + cDdMat + "'%"
BeginSql alias cQrySrf
	Column RF_DATABAS as Date
	Column RF_DATAFIM as Date
	Select SRF.*, SRF.R_E_C_N_O_ RfRecno
	from 	%table:SRF% SRF
	Where	SRF.RF_FILIAL = %exp:cDdFil% And
			SRF.RF_MAT	  = %exp:cDdMat% And
			SRF.RF_STATUS in ('0','1','3')   And
			SRF.%notDel%
	Order By SRF.RF_PD, SRF.RF_DATABAS
EndSql

DbSelectArea(cQrySrf)
(cQrySrf)->(DbGoTop())
Do While (cQrySrf)->(!Eof())
	If ((cQrySrf)->RF_STATUS != "3")
		If (((cQrySrf)->RF_PD == fGetCodFol("1332")) 	.Or.	;
			((cQrySrf)->RF_PD == fGetCodFol("1333"))) 	//Licença Prêmio - Gozo ou Indenização
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Apura Faltas Justificadas e Não Justificadas Ano a Ano ³
			//³ Devolve: Array Faltas e Devoluções no período          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//Verifica se é algum período anteriormente alterado
			dRfDtBas	:= Iif((cQrySrf)->RF_DATABAS == adRfSave[1] .Or. Empty(adRfSave[1]), (cQrySrf)->RF_DATABAS, adRfSave[2])
			aRdFalDev	:= fGetFalDev((cQrySrf)->RF_FILIAL,(cQrySrf)->RF_MAT,dRfDtBas,(cQrySrf)->RF_DATAFIM,,,.F.,,.F.,dDtaFim)
			//aRdFalDev	:= {aFaltas, aDevols}
			//aFaltas	:= Verba, Horas, Valor, Datarq
			//aDevols	:= Verba, Horas, Valor, Referência
			
			nLiqFal		:= fLiqFalDev(aRdFalDev,dRfDtBas,(cQrySrf)->RF_DATAFIM)
			nMesAlt		:= Int(nLiqFal / nFalLicen) * nMesLicen
			
			If !(nMesAlt == 0)
				dRfFim	:= (cQrySrf)->RF_DATAFIM
				DbSelectArea("SRF")
				SRF->(DbGoTo((cQrySrf)->RfRecno))
				
				//Busca Dias de Direito por Sindicato
				nPos106  := aScan(aTabS106, {|x,y| AllTrim(x[10]) == (cQrySrf)->RF_PD .And. cDdCat $ AllTrim(x[11]) .And. cDdReg $ AllTrim(x[12]) .And. cSind == AllTrim(x[16])})
				
				If nPos106 == 0 //nao possui configuração por sindicato, busca apenas por categoria
					nPos106	:= aScan(aTabS106, {|x,y| AllTrim(x[10]) == (cQrySrf)->RF_PD .And. cDdCat $ AllTrim(x[11]) .And. cDdReg $ AllTrim(x[12])})
				EndIf
				
				If nPos106 > 0
					dRfNew	:= Iif(aTabS106[nPos106][13]=="1",DaySum(SRF->RF_DATABAS,aTabS106[nPos106][14])-1,MonthSum(SRF->RF_DATABAS,aTabS106[nPos106][14])-1)
				Endif
				
				If nMesAlt > 0
					dRfNew	:= MonthSum(dRfNew,Abs(nMesAlt))
				ElseIf nMesAlt < 0
					dRfNew	:= MonthSub(dRfNew,Abs(nMesAlt))
				EndIf
				If !(dRfFim == dRfNew)
					Reclock("SRF",.F.)
					SRF->RF_DATAFIM	:= dRfNew
					If SRF->RF_DATAFIM <= dDtaFim
						SRF->RF_DFALVAT	:= nLiqFal
					Else
						SRF->RF_DFALAAT := nLiqFal
					EndIf
					SRF->(MsUnlock())
					//Tem Próximo SRF?
					aAreaPA	:= SRF->(GetArea())
					DbSetOrder(2)
					If SRF->(DbSeek((cQrySrf)->RF_FILIAL + (cQrySrf)->RF_MAT + (cQrySrf)->RF_PD + DtoS(dRfFim + 1)))
						adRfSave[1]	:= SRF->RF_DATABAS
						dRf2New	:= Iif(aTabS106[nPos106][13]=="1",DaySum(dRfNew,aTabS106[nPos106][14]),MonthSum(dRfNew,aTabS106[nPos106][14]))
						adRfSave[2]	:= DaySum(dRfNew,1)
						Reclock("SRF",.F.)
						SRF->RF_DATABAS	:= adRfSave[2]
						SRF->RF_DATAFIM	:= dRf2New
						SRF->(MsUnlock())
					//(...)
					EndIf
					RestArea(aAreaPA)
				EndIf
			EndIf
		EndIf
		If (cQrySrf)->RF_STATUS $ "0|1"
			DbSelectArea("SRF")
			SRF->(DbGoTo((cQrySrf)->RfRecno))
			Reclock("SRF",.F.)
			SRF->RF_STATUS	:= If(SRF->RF_DATAFIM <= dDtaFim,"1","0")	//Período Ativo (ja adquirido)
			SRF->(MsUnlock())
			If SRF->RF_STATUS == "1" //ATIVO
				Reclock("SRF",.F.)
				SRF->RF_DFERAAT	:= 0
				SRF->RF_DFERVAT	:= SRF->RF_DIASDIR //DIAS VENCIDOS
				SRF->(MsUnlock())
				fAtuLicFer((cQrySrf)->RF_FILIAL,(cQrySrf)->RF_MAT,cDdCat,cDdReg,SRF->RF_DATAFIM,(cQrySrf)->RF_PD,aTabS106,cSind)
			Else //0 - EM AQUISICAO
				nPos106  := aScan(aTabS106, {|x,y| AllTrim(x[10]) == (cQrySrf)->RF_PD .And. cDdCat $ AllTrim(x[11]) .And. cDdReg $ AllTrim(x[12]) .And. cSind == AllTrim(x[16])})
				
				If nPos106 == 0 //nao possui configuração por sindicato, busca apenas por categoria
					nPos106	:= aScan(aTabS106, {|x,y| AllTrim(x[10]) == (cQrySrf)->RF_PD .And. cDdCat $ AllTrim(x[11]) .And. cDdReg $ AllTrim(x[12])})
				EndIf
				
				If nPos106 > 0
					Reclock("SRF",.F.)
					SRF->RF_DFERAAT	:= Min((aTabS106[nPos106][15] / aTabS106[nPos106][14]) * Max(DateDiffMonth(SRF->RF_DATABAS, DDTAFIM + 1),1), SRF->RF_DIASDIR) //DIAS PROPORCIONAIS
					SRF->(MsUnlock())
				Endif	
				fAtuLicFer((cQrySrf)->RF_FILIAL,(cQrySrf)->RF_MAT,cDdCat,cDdReg,SRF->RF_DATAFIM,(cQrySrf)->RF_PD,aTabS106,cSind)
			EndIf
		EndIf
	
		//Busca RIA
	    cPdRia	:= "%'" + (cQrySrf)->RF_PD + "'%"
	    dDtBas	:= (cQrySrf)->RF_DATABAS
	    nDdRia	:= 0
		BeginSql alias cQryRia
			Column RIA_DTINPA as Date
			Column RIA_DATINI as Date
			Column RIA_DATFIM as Date
			Column RIA_DTPGAD as Date
			Column RIA_DATPAG as Date
			Select RIA.*, RIA.R_E_C_N_O_ RiaRecno
			from 	%table:RIA% RIA
			Where	RIA.RIA_FILIAL = %exp:cDdFil%   And
					RIA.RIA_MAT    = %exp:cDdMat%   And
					RIA.RIA_PD     = %exp:cPdRia%   And
					RIA.RIA_DTINPA = %exp:dDtBas%   And
					RIA.RIA_STATUS in ('0','2','4') And
					RIA.%notDel%
			Order By RIA.RIA_DTINPA, RIA_DATINI
		EndSql
	
		//Ajusta Status RIA e SRF
		DbSelectArea(cQryRia)
		DbGoTop()
		Do While (cQryRia)->(!(Eof()))
			//Se ainda nao quitado, verifica se ultimo dia de gozo é menor ou igual ao periodo em fechamento ou se é só indenizado, e quita a RIA
			If (cQryRia)->RIA_STATUS == '0'
				If ( !empty((cQryRia)->RIA_DATFIM) .and. (cQryRia)->RIA_DATFIM <= dDtaFim ) .or. ;
						(empty((cQryRia)->RIA_DATFIM) .and. (cQryRia)->RIA_DTPGAD <= dDtaFim .and. !empty((cQryRia)->RIA_NRDIND) )
			    	DbSelectArea("RIA")
			    	RIA->(DbGoTo((cQryRia)->RiaRecno))
			    	Reclock("RIA",.F.)
			    	RIA->RIA_STATUS	:= "4"	//Quita a programação da RIA
			    	RIA->(MsUnlock())
				EndIf
			EndIf
			(cQryRia)->(DbSkip())
		EndDo
	
		//Se na SRF os dias programados >= dias de direito
		If (cQrySrf)->RF_DIASPRG >= (cQrySrf)->RF_DIASDIR
			DbSelectArea(cQryRia)
			DbGoTop()
			Do While (cQryRia)->(!(Eof()))
				//Posiciona na RIA para buscar o status atual, que pode ter sido alterado pela rotina acima e a query estará com o status anterior
		    	RIA->(DbGoTo((cQryRia)->RiaRecno))
				//Se status da RIA for 2=Suspenso ou 4=Quitado
				If RIA->RIA_STATUS $ '2/4'
					nDdRia	:= nDdRia + RIA->RIA_NRDGOZ + RIA->RIA_NRDIND
				EndIf
				(cQryRia)->(DbSkip())
			EndDo
			//Se nDdRia >= dias de direito, altera SRF para Pago
			If nDdRia >= (cQrySrf)->RF_DIASDIR
				DbSelectArea("SRF")
				SRF->(DbGoTo((cQrySrf)->RfRecno))
				Reclock("SRF",.F.)
				SRF->RF_STATUS	:= "3"	//Pago
				SRF->RF_DFERAAT	:= 0
				SRF->RF_DFERVAT	:= SRF->RF_DIASDIR //DIAS VENCIDOS
				SRF->(MsUnlock())
			EndIf
		Endif
		DbSelectArea(cQryRia)
		(cQryRia)->(DbCloseArea())
	EndIf
	//Cria novo PA
	DbSelectArea("SRF")
	SRF->(DbGoTo((cQrySrf)->RfRecno))
	If 	(SRF->RF_DATAFIM >= dDtaIni .And. ;
		SRF->RF_DATAFIM <= dDtaFim) .Or. (SRF->RF_STATUS == "3" .And. SRF->RF_DATAFIM <= dDtaFim .And. (SRF->RF_PD == fGetCodFol("1332") ;
		.Or. SRF->RF_PD == fGetCodFol("1333")))
		
		//Busca Dias de Direito por Sindicato
		nPos106  := aScan(aTabS106, {|x,y| AllTrim(x[10]) == (cQrySrf)->RF_PD .And. cDdCat $ AllTrim(x[11]) .And. cDdReg $ AllTrim(x[12]) .And. cSind == AllTrim(x[16])})
		
		If nPos106 == 0 //nao possui configuração por sindicato, busca apenas por categoria
			nPos106	:= aScan(aTabS106, {|x,y| AllTrim(x[10]) == (cQrySrf)->RF_PD .And. cDdCat $ AllTrim(x[11]) .And. cDdReg $ AllTrim(x[12])})
		EndIf
		
		If nPos106 > 0 .and. aTabS106[nPos106][14] > 0	//Se quant. dias Per.Aquisitivo for informada, é recorrente.
		
			dRfNewBas	:= (cQrySrf)->RF_DATAFIM
			dRfNewBas   := DaySum(dRfNewBas,1)
			aNewArSrf	:= SRF->(GetArea())
			SRF->(dbsetorder(1))
			If !SRF->(DbSeek((cAliasSRA)->RA_FILIAL+(cAliasSRA)->RA_MAT+DtoS(dRfNewBas)+(cQrySrf)->RF_PD))
				//nPos106	:= aScan(aTabS106, {|x,y| AllTrim(x[10]) == (cQrySrf)->RF_PD .And. cDdCat $ AllTrim(x[11]) .And. cDdReg $ AllTrim(x[12])})
				Reclock("SRF",.T.)
				SRF->RF_FILIAL	:= (cAliasSRA)->RA_FILIAL
				SRF->RF_MAT		:= (cAliasSRA)->RA_MAT
				SRF->RF_PD		:= (cQrySrf)->RF_PD
				SRF->RF_DATABAS	:= dRfNewBas
				SRF->RF_DATAFIM	:= Iif(aTabS106[nPos106][13]=="1",DaySum(dRfNewBas-1,aTabS106[nPos106][14]),MonthSum(dRfNewBas-1,aTabS106[nPos106][14]))
				SRF->RF_DIASDIR	:= aTabS106[nPos106][15]
				SRF->RF_STATUS	:= "0"
				SRF->RF_DFERVAT	:= 0
				SRF->RF_DFERAAT	:= 0
				SRF->RF_DFALVAT	:= 0
				SRF->RF_DFALAAT	:= 0
				SRF->(MsUnlock())
			EndIF
			RestArea(aNewArSrf)
			
        EndIf
	ElseIf (cQrySrf)->RF_DATAFIM <= dDtaIni
		fAtuLicFer((cQrySrf)->RF_FILIAL,(cQrySrf)->RF_MAT,cDdCat,cDdReg,(cQrySrf)->RF_DATAFIM,(cQrySrf)->RF_PD,aTabS106,cSind)
	EndIf
	(cQrySrf)->(DbSkip())
EndDo

dbSelectArea(cQrySrf)
(cQrySrf)->(DbCloseArea())

RestArea(aAreaRia)
RestArea(aAreaSrf)
Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} fAtuLicFer
Controla Período Aquisitivo dos Dias de Direito
Utilização no Fechamento da Folha de Pagamento do Ministério Público
@sample 	fAtuLicFer(cNrfFil,cNrfMat,cNrfCat,cNrfReg,dNrfFim,cNrfPd,aTab106)
@param		cNrfFil  - RA_FILIAL 	- Filial do Funcionário
			cNrfMat  - RA_MAT		- Matrícula do Funcionário
			cNrfCat  - RA_CATFUNC	- Categoria Funcional
			cNrfReg  - RA_REGIME 	- Regime de Contratação
			dNrfFim	 - RF_DATAFIM	- Data Final do P.Aquis. finalizado
			cNrfPd	 - RF_PD		- Verba de identificação do P.A.
			aTab106  - aTabS106		- Conteúdo da Tabela S106 desta Filial
@return		Nil
@author		Tânia Bronzeri
@since		06/06/2018
@version	P.12
@obs
aTabS106[x,5]  = (RCC_CONTEU,1,50) S106001 - Tipo Ocorrencia
aTabS106[x,6]  = (RCC_CONTEU,51,1) S106002 - Dias Cred para cada 1 trab
aTabS106[x,7]  = (RCC_CONTEU,52,1) S106003 - Publica Portaria
aTabS106[x,8]  = (RCC_CONTEU,53,1) S106004 - Trocar Descanso por Inden
aTabS106[x,9]  = (RCC_CONTEU,54,3) S106005 - Provento de indenização
aTabS106[x,10] = (RCC_CONTEU,57,3) S106006 - Base de dias em descando
aTabS106[x,11] = (RCC_CONTEU,60,30)S106007 - Categorias
aTabS106[x,12] = (RCC_CONTEU,90,2) S106008 - Regime
aTabS106[x,13] = (RCC_CONTEU,92,1) S106009 - Unid. Per. Aquisitivo
aTabS106[x,14] = (RCC_CONTEU,93,3) S106010 - Qtd. Per. Aquisitivo
aTabS106[x,15] = (RCC_CONTEU,96,3) S106011 - Dias Direito Per.Aquisit.
aTabS106[x,16] = (RCC_CONTEU,99,2) S106012 - Codigo Sindicato
/*/
//------------------------------------------------------------------------------
Function fAtuLicFer(cNrfFil,cNrfMat,cNrfCat,cNrfReg,dNrfFim,cNrfPd,aTab106,cSind)
	
	Local aArea			:= GetArea()
	Local aAreaSRF		:= SRF->(GetArea())
	Local n106			:= 0
	Local dNPa			:= dNrfFim + 1
	Local dDtFim		:= CtoD("  /  /  ")
	Local lGrv			:= .T.
	Local dDataAux		:= CtoD("  /  /  ")
	Local aPerFerias	:= {}
	Local nI
	
	Default aTab106	:= {}
	
	//Busca Dias de Direito por Sindicato
	n106  := aScan(aTabS106, {|x,y| AllTrim(x[10]) == cNrfPd .And. cNrfCat $ AllTrim(x[11]) .And. cNrfReg $ AllTrim(x[12]) .And. cSind == AllTrim(x[16])})
	
	If n106 == 0 //nao possui configuração por sindicato, busca apenas por categoria
		n106  := aScan(aTabS106, {|x,y| AllTrim(x[10]) == cNrfPd .And. cNrfCat $ AllTrim(x[11]) .And. cNrfReg $ AllTrim(x[12])})
	EndIf
	
	If n106 > 0 .AND. aTab106[n106][14] > 0	//Se quant. dias Per.Aquisitivo for informada, é recorrente.
		DbSelectArea("SRF")
		DbSetOrder(2)
		
		If cNrfPd == aCodFol[0072][1]
			dDataAux := fBuscaFer()
			Calc_Fer(@aPerFerias, If(SRA->RA_SITFOLH == "D", SRA->RA_DEMISSA, dDtaFim),,,,,,.F.,dDataAux)
			
			For nI := 1 To Len(aPerFerias)
				If ! SRF->( DbSeek(SRA->(RA_FILIAL + RA_MAT) + cNrfPd + DtoS(aPerFerias[nI, 1])))
					If nI > 1 .And. aPerFerias[nI, 8] == "1" .And. aPerFerias[nI - 1, 8] == "2" .And. Empty(aPerFerias[nI - 1, 9])//Se período anterior esta preescrito e não houve retorno do afastamento, não cria registro ativo
						Loop
					EndIf
					RecLock("SRF", .T.)
					SRF->RF_FILIAL  := SRA->RA_FILIAL
					SRF->RF_MAT     := SRA->RA_MAT
					SRF->RF_PD      := cNrfPd
					SRF->RF_DATABAS := aPerFerias[nI,1]
					SRF->RF_DATAFIM := aPerFerias[nI,2]
					SRF->RF_DFERVAT := If(!Empty(aPerFerias[nI,3]), aTab106[n106][15], 0)
					SRF->RF_DIASDIR := aTab106[n106][15] 
					SRF->RF_DFERAAT := If(aPerFerias[nI, 2] <= dDtaFim, 0, (aTabS106[n106][15] / aTabS106[n106][14]) * Max(DateDiffMonth(aPerFerias[nI, 1], dDtaFim + 1), 1))
					SRF->RF_DVENPEN := aPerFerias[nI,11]
					SRF->RF_DFALVAT := 0
					SRF->RF_DFALAAT := 0
					MsUnLock()
				EndIf
			Next nI
		Else
			
			While dNPa <= dDtaFim
				lGrv := !(DbSeek(cNrfFil + cNrfMat + cNrfPd + DtoS(dNPa)))
				dDtFim := Iif(aTab106[n106][13] == "1", DaySum(dNPa - 1, aTab106[n106][14]), MonthSum(dNPa - 1, aTab106[n106][14]))
				If lGrv //é novo registro
					Reclock("SRF",lGrv)
					SRF->RF_FILIAL	:= cNrfFil
					SRF->RF_MAT		:= cNrfMat
					SRF->RF_STATUS	:= If(dDtFim <= dDtaFim, "1","0")
					SRF->RF_PD		:= cNrfPd
					SRF->RF_DATABAS	:= dNPa
					SRF->RF_DATAFIM	:= dDtFim
					SRF->RF_DIASDIR	:= aTab106[n106][15]
					SRF->RF_DIASPRG	:= 0
					SRF->RF_DIREMAN := 0
					SRF->RF_DFERVAT	:= If(dDtFim <= dDtaFim, aTab106[n106][15],0)
					SRF->RF_DFERAAT	:= If(dDtFim <= dDtaFim,0,(aTabS106[n106][15] / aTabS106[n106][14]) * Max(DateDiffMonth(dNPa,dDtaFim+1),1)) //DIAS PROPORCIONAIS
					SRF->RF_DFALVAT	:= 0
					SRF->RF_DFALAAT	:= 0
					MsUnlock()
				EndIf
				dNPa := dDtFim + 1
			EndDo
		EndIf
	EndIf
	
	RestArea(aAreaSRF)
	RestArea(aArea)
Return Nil


//------------------------------------------------------------------------------
/*/{Protheus.doc} fGetTmpPAq
Obtem intervalo do Período Aquisitivo
Utilização no Fechamento da Folha de Pagamento do Ministério Público
@sample 	fGetTmpPAq(dInicio,dFinal)
@param		dInicio - Data de inicio a ser considerada na pesquisa
			dFinal  - Data final a ser considerada na pesquisa
@return		Array com anos e dias para processamento na function fGetFalDev()
@author		Tânia Bronzeri
@since		06/06/2018
@version	P.12
/*/
//------------------------------------------------------------------------------
Function fGetTmpPAq(dInicio,dFinal)
Local nAnoIni	:= 0
Local nAnoFin	:= 0
Local aTmpDias	:= {}

dFinal	:= Iif(Empty(dFinal),dDataBase,dFinal)

nAnoIni	:= Year(dInicio)
nAnoFin	:= Year(dFinal)

If nAnoIni == nAnoFin
	aadd(aTmpDias, {AllTrim(Str(nAnoIni)), (dFinal - dInicio) + 1})
Else
	aAdd(aTmpDias, {AllTrim(Str(nAnoIni)), (StoD(AllTrim(Str(nAnoIni)) + "1231") - dInicio) + 1})
	nAnoIni++
	While nAnoIni < nAnoFin
		aAdd(aTmpDias, {AllTrim(Str(nAnoIni)), (StoD(AllTrim(Str(nAnoIni)) + "1231") - StoD(AllTrim(Str(nAnoIni)) + "0101")) + 1})
		nAnoIni++
	EndDo
    aAdd(aTmpDias, {AllTrim(Str(nAnoIni)), dFinal - (StoD(AllTrim(Str(nAnoFin)) + "0101")) + 1})
EndIf

Return aClone(aTmpDias)


//------------------------------------------------------------------------------
/*/{Protheus.doc} fLiqFalDev
Obtem o líquido de Faltas: Faltas por RD_DATARQ / Devoluções por RD_DTREF
Utilização no Fechamento da Folha de Pagamento do Ministério Público
@sample 	fLiqFalDev(aRdFalDev)
@param		aRdFalDev - //aRdFalDev	:= {aFaltas, aDevols}
						//aFaltas	:= Verba, Horas, Valor, Datarq (Ano Mes)
						//aDevols	:= Verba, Horas, Valor, Referência (Ano Mes)
			dDtIniPa - Início do Periodo Aquisitivo ou PA Salvo
			dDtFimPa - Final do Periodo Aquisitivo
@private	cLimFalDev(mv_vddfade)
@return		Líquido de Faltas - Devoluções no Período Aquisitivo
@author		Tânia Bronzeri
@since		06/06/2018
@version	P.12
/*/
//------------------------------------------------------------------------------
Function fLiqFalDev(aRdFalDev,dDtIniPa,dDtFimPa)
Local nLiquido	:= 0
Local nI	    := 0
Local nFd		:= 0
Local aFd		:= Array(Len(aRdFalDev))
Local lPriMes	:= Iif(Day(dDtIniPa) <= Val(cLimFalDev),.T.,.F.)
Local lUltMes	:= Iif(Day(dDtFimPa) >= Val(cLimFalDev),.T.,.F.)

For nFd	:= 1 to Len(aFd)
	For nI := 1 to Len(aRdFalDev[nFd])
		If 	(lPriMes .And. AnoMes(dDtIniPa) == aRdFalDev[nFd][nI][4]) .Or. ;
			(lUltMes .And. AnoMes(dDtFimPa) == aRdFalDev[nFd][nI][4]) .Or. ;
			(aRdFalDev[nFd][nI][4] > AnoMes(dDtIniPa) .And. aRdFalDev[nFd][nI][4] < AnoMes(dDtFimPa))
			If nFd == 1
				nLiquido	+= Abs(aRdFalDev[nFd][nI][2])
			Else
				nLiquido	-= Abs(aRdFalDev[nFd][nI][2])
			EndIf
		EndIf
	Next nI
Next nFd

/*
//Faltas
For nI := 1 to Len(aRdFalDev[1])
	If 	(lPriMes .And. AnoMes(dDtIniPa) == aRdFalDev[1][nI][4]) .Or. ;
		(lUltMes .And. AnoMes(dDtFimPa) == aRdFalDev[1][nI][4]) .Or. ;
		(aRdFalDev[1][nI][4] > AnoMes(dDtIniPa) .And. aRdFalDev[1][nI][4] < AnoMes(dDtFimPa))
		nLiquido	+= Abs(aRdFalDev[1][nI][2])
	EndIf
Next nI

//Devoluções
For nI := 1 to Len(aRdFalDev[2])
	If 	(lPriMes .And. AnoMes(dDtIniPa) == aRdFalDev[2][nI][4]) .Or. ;
		(lUltMes .And. AnoMes(dDtFimPa) == aRdFalDev[2][nI][4]) .Or. ;
		(aRdFalDev[2][nI][4] > AnoMes(dDtIniPa) .And. aRdFalDev[2][nI][4] < AnoMes(dDtFimPa))
		nLiquido	-= Abs(aRdFalDev[2][nI][2])
	EndIf
Next nI
*/

Return nLiquido



//------------------------------------------------------------------------------
/*{Protheus.doc} fArrNextPC
Carrega arrays aNextPer e aNextComp por referência
Utilização no Fechamento da Folha de Pagamento do Ministério Público
@sample 	fArrNextPC(aNextPer,aNextComp,lPPer,lPComp,nRegRch,nQuem)
@param		aNextPer  	- Array de informações para o próximo Período
			aNextComp 	- Array de informações para a próxima Competência
			lPPer		- Informa se aNextPer  pertence ao próximo período
			lPComp		- Informa se aNextComp pertence ao próximo período
			nRegRch		- Recno da RCH a salvar
			nQuem		- Quem grava: 1=aNextPer / 2=aNextComp / 3=Ambos
@return		aNextPer e aNextComp - por referência
@author		Tânia Bronzeri
@since		06/06/2018
@version	P.12
*/
//------------------------------------------------------------------------------
Function fArrNextPC(aNextPer,aNextComp,lPPer,lPComp,nRegRch,nQuem)

Local aASalRch		:= RCH->(GetArea())
Local cAliasRCH     := "RCH"

Default aNextPer	:= {}
Default aNextComp	:= {}
Default lPPer		:= .T.
Default lPComp		:= .T.
Default nQuem		:= 3

DbSelectArea("RCH")
DbGoTo(nRegRch)
If nQuem == 1 .Or. nQuem == 3
	aAdd(aNextPer, {	(cAliasRCH)->RCH_FILIAL	,;
						(cAliasRCH)->RCH_PER	,;
						(cAliasRCH)->RCH_NUMPAG	,;
						(cAliasRCH)->RCH_PROCES	,;
						(cAliasRCH)->RCH_ROTEIR	,;
						(cAliasRCH)->RCH_MES	,;
						(cAliasRCH)->RCH_ANO	,;
						(cAliasRCH)->RCH_DTPAGO	,;
						(cAliasRCH)->RCH_DTINI	,;
						(cAliasRCH)->RCH_DTFIM	,;
						lPPer					,;
						(cAliasRCH)->(Recno())  ;
					} )
EndIf
If nQuem == 2 .Or. nQuem == 3
	aAdd( aNextComp, { 	(cAliasRCH)->RCH_FILIAL	,;
						(cAliasRCH)->RCH_PER	,;
						(cAliasRCH)->RCH_NUMPAG	,;
						(cAliasRCH)->RCH_PROCES	,;
						(cAliasRCH)->RCH_ROTEIR	,;
						(cAliasRCH)->RCH_MES	,;
						(cAliasRCH)->RCH_ANO	,;
						(cAliasRCH)->RCH_DTPAGO	,;
						(cAliasRCH)->RCH_DTINI	,;
						(cAliasRCH)->RCH_DTFIM	,;
						lPComp					,;
						(cAliasRCH)->(Recno())  ;
					} )
EndIf

RestArea(aASalRch)

Return Nil



//------------------------------------------------------------------------------
/*{Protheus.doc} fValPer13s
Valida Existência do Período da Segunda Parcela do 13º, quando do fechamento
		da Folha da Primeira Parcela.
Utilização no Fechamento da Folha de Pagamento do Ministério Público
@sample 	fValPer13s(nRecno,cFilRCH)
@param	    nRecno	= Numero do Recno da RCH, por referência
			cFilRCH	= Filial da RCH
@return		lRet - Se encontrou o Roteiro 312 em dezembro.
@author		Tânia Bronzeri
@since		06/06/2018
@version	P.12
*/
//------------------------------------------------------------------------------
Function fValPer13s(nRecno,cFilRCH, cAnoProc)
Local aArTemRch	:= RCH->(GetArea())
Local aArTemSry	:= SRY->(GetArea())
Local cQuerySry	:= GetNextAlias()
Local c213Pag	:= Iif(cTransPd $ "13", "01", cNumPag)
Local cQSryFil	:= Iif(Empty(cFilRCH), "", "%'" + cFilRCH  + "'%")
Local c213Rot	:= ""
Local lRet		:= .F.
Local cAliasRCH := "RCH"


BeginSql Alias cQuerySry

	Select SRY.*
	from 	%table:SRY% SRY
	Where	SRY.RY_FILIAL = %exp:cQSryFil% 	And
			SRY.RY_TIPO = "6"				And
			SRY.%notDel%
	Order By SRY.RY_TIPO, SRY.RY_CALCULO
EndSql

DbSelectArea(cQuerySry)
DbGoTop()
While !Eof()
	c213Rot	+= (cQuerySry)->RY_CALCULO + "|"
	(cQuerySry)->(DbSkip())
EndDo
If !Empty(c213Rot)
	c213Rot	:= Substr(c213Rot,1,Len(c213Rot)-1)
EndIf

DbSelectArea("RCH")
DbSetOrder(RetOrdem("RCH","RCH_FILIAL+RCH_PROCES+RCH_PER+RCH_NUMPAG+RCH_ROTEIR"))
If (cAliasRCH)->(DbSeek(cFilRCH+cProcesso+cAnoProc+"12"+c213Pag))
	While	(cAliasRCH)->RCH_FILIAL == cFilRCH .And.		;
			(cAliasRCH)->RCH_PROCES == cProcesso .And.		;
			(cAliasRCH)->RCH_PER    == cAnoProc+"12" .And.	;
			(cAliasRCH)->RCH_NUMPAG == c213Pag .And.		;
			!lRet
			lRet	:= Iif((cAliasRCH)->RCH_ROTEIR $ c213Rot, .T., .F.)
			nRecno	:= Iif(lRet, (cAliasRCH)->(Recno()), 0)

			(cAliasRCH)->(DbSkip())
   EndDo
EndIf

RestArea(aArTemSry)
RestArea(aArTemRch)

Return lRet


//------------------------------------------------------------------------------
/*{Protheus.doc} f120APeSrc
Valida Existência de Lançamentos na SRC.
Utilização no Fechamento da Folha de Pagamento do Ministério Público
@sample 	f120APeSrc()
@param
@return		lRet - Se encontrou lançamentos na SRC
@author		Tânia Bronzeri
@since		06/06/2018
@version	P.12
*/
//------------------------------------------------------------------------------
Function f120APeSrc()
Local aArea		:= GetArea()
Local cAlsSrc	:= GetNextAlias()
Local cQPeriodo	:= "%'" + cPeriodo + "'%"
Local cQRoteiro	:= "%'" + cRoteiro + "'%"
Local cQProces	:= "%'" + cProcesso  + "'%"
Local lRet		:= .F.

BeginSql Alias cAlsSrc

	Select Count(SRC.RC_PD) nVerbas
	from 	%table:SRC% SRC
	Where	SRC.RC_PERIODO	= %exp:cQPeriodo%	And
			SRC.RC_ROTEIR	= %exp:cQRoteiro%	And
			SRC.RC_PROCES	= %exp:cQProces%	And
			SRC.%notDel%
EndSql

DbSelectArea(cAlsSrc)
DbGoTop()
If !Eof()
	lRet	:= Iif((cAlsSrc)->nVerbas > 0,.T.,.F.)
EndIf

(cAlsSrc) ->(DbCloseArea())
RestArea(aArea)
Return lRet

//------------------------------------------------------------------------------
/*{Protheus.doc} f120TraVer
Controla Período Aquisitivo dos Dias de Direito
Utilização no Fechamento da Folha de Pagamento do Ministério Público
@sample 	f120TraVer(aPerErros)
@return		Nil
@author		Silvia Taguti
@since		06/06/2018
@version	P.12
*/
//------------------------------------------------------------------------------

Function f120TraVer(aPerErros ,cTransPd,cFilRCH , cProcFec, cRotFec,cSemFec,aNextPer,aNextComp,cMesProc , cAnoProc )

Local aArea		:= GetArea()
Local nRec		:= 0
Local lRet 		:= .T.
Local lOrdinar  := .F.
Local c213Pag	:= Iif(cTransPd $ "13", "01", cNumPag)
Local aArTemRch	:= {}
Local lTemSrc	:= .F.
Local cMens		:= ""
Local cAliasRCH		:= "RCH"

cRotFunc := fGetRotOrdinar()

If !Empty(cRotFunc) .And. cRotFunc == cRotFec
	lOrdinar := .T.
Endif

If cTpRoteir == "5" .And. cMesProc == "11"
	lRet	:= fValPer13s(@nRec, cFilRCH , cAnoProc)
	If !lRet
		//"Não existe Pagamento '"	###	"' para a segunda parcela no mês de Dezembro" ### "'. É necessária a sua criação para prosseguir com o Fechamento."
		aAdd( aPerErros, STR0001+ c213Pag + STR0002 + STR0003 )
	Else
		fArrNextPC(@aNextPer,@aNextComp,.T.,.T.,nRec,3)
	EndIf
ElseIf cTpRoteir == "6" 	//Identifica se é fechamento da 2ª Parc. do 13º Sal.
	fArrNextPC(@aNextPer,@aNextComp,.T.,.T.,(cAliasRCH)->(Recno()),3)
	lRet := .T.
ElseIf !(cTpRoteir $ "5*6")

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Se não for Ordinário, verifica SRC                            ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	If !lOrdinar
		lTemSrc	:= f120APeSrc()
	EndIf

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Validacao do Periodo Seguinte                                 ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	If cTransPd	== "1"
		//Próximo Período - Pagamento 01
		aArTemRch	:= GetArea()
		If (cAliasRCH)->(Eof())
			lNextPer := .F.
			lRet := .F.
			(cAliasRCH)->( DbSkip(-1) )
			aAdd( aPerErros, STR0004 )	//"Não existe Pagamento '" ### "' no próximo Período do Roteiro '" ### "'. É necessária a sua criação para prosseguir com o Fechamento."
		Else
			Do While ((cAliasRCH)->(!Eof())) .And. lRet
				If  !((cAliasRCH)->RCH_FILIAL == cFilRCH) 	.Or. ;
					!((cAliasRCH)->RCH_PROCES == cProcesso)	.Or. ;
					!((cAliasRCH)->RCH_ROTEIR == cRoteiro)	.AND.;
					(lOrdinar .Or. lTemSrc)
		        		aAdd( aPerErros, STR0004 )
							  	//Dar mensagem que não existe pagamento 01 no próximo periodo
						//"Não existe Pagamento '" ### "' no próximo Período do Roteiro '" ### "'. É necessária a sua criação para prosseguir com o Fechamento."
						lRet	:= .F.
				ElseIf (cAliasRCH)->RCH_PER == cPeriodo
					(cAliasRCH)->(DbSkip())
				ElseIf !lOrdinar
					If !Empty((cAliasRCH)->RCH_DTFECH)
						(cAliasRCH)->(DbSkip())
					Else
						fArrNextPC(@aNextPer,@aNextComp,.T.,.T.,(cAliasRCH)->(Recno()),3)
						Break
					EndIf
				ElseIf (cAliasRCH)->RCH_NUMPAG == "01"
					fArrNextPC(@aNextPer,@aNextComp,.T.,.T.,(cAliasRCH)->(Recno()),3)
					Break
				EndIf
			EndDo
		EndIf
		RestArea(aArTemRch)
	ElseIf cTransPd	== "2"
		//Próximo Período - Mesmo Pagamento
		aArTemRch	:= GetArea()
		Do While ((cAliasRCH)->(!Eof())) 	.And. lRet
			If  !((cAliasRCH)->RCH_FILIAL == cFilRCH) 	.Or. ;
				!((cAliasRCH)->RCH_PROCES == cProcesso)	.Or. ;
				!((cAliasRCH)->RCH_ROTEIR == cRoteiro)
				If lOrdinar .Or. lTemSrc
					//Da mensagem que não existe o mesmo pagamento no próximo periodo
					cMens := OemToAnsi(STR0001) + cNumPag + OemToAnsi(STR0005) + cRoteiro + OemToAnsi(STR0003)
					//"Não existe Pagamento '" ### "' no próximo Período do Roteiro '" ### "'. É necessária a sua criação para prosseguir com o Fechamento. "
					aAdd( aPerErros, STR0001 + cNumPag + STR0005 + cRoteiro + STR0003 )
					lRet := .F.
				EndIf
			ElseIf (cAliasRCH)->RCH_PER == cPeriodo
				(cAliasRCH)->(DbSkip())
			ElseIf (cAliasRCH)->RCH_NUMPAG < cNumPag
				(cAliasRCH)->(DbSkip())
			ElseIf !lOrdinar
				If !Empty((cAliasRCH)->RCH_DTFECH)
					(cAliasRCH)->(DbSkip())
				Else
					fArrNextPC(@aNextPer,@aNextComp,.T.,.T.,(cAliasRCH)->(Recno()),3)
					Break
				EndIf
			ElseIf (cAliasRCH)->RCH_NUMPAG == cNumPag
				cNexPer	:= (cAliasRCH)->RCH_PER
				fArrNextPC(@aNextPer,@aNextComp,.T.,.T.,(cAliasRCH)->(Recno()),3)
				Break
			EndIf
		EndDo
		RestArea(aArTemRch)
	Else	//cTransPd	== "3" - Próximo Pagamento
		If 	( (cAliasRCH)->( !Eof() ) ) 			.and. ;
			( (cAliasRCH)->RCH_FILIAL == cFilRCH ) 	.and. ;
			( (cAliasRCH)->RCH_PROCES == cProcesso )  .and. ;
			( (cAliasRCH)->RCH_ROTEIR == cRoteiro )	.and. ;
			( !Empty( (cAliasRCH)->RCH_DTFECH ) )

			// "O periodo seguinte ja foi fechado. "
			aAdd( aPerErros, STR0006)
			lRet := .F.

		ElseIf 	( ( (cAliasRCH)->( !Eof() ) ) 				.and. ;
			( ( (cAliasRCH)->RCH_FILIAL <> cFilRCH )	.or.  ;
			( (cAliasRCH)->RCH_PROCES <> cProcesso )  	.or.  ;
			( (cAliasRCH)->RCH_ROTEIR <> cRoteiro) ) )	.or.  ;
			( (cAliasRCH)->( Eof() ))

			lNextPer := .F.
			lRet := .F.
			(cAliasRCH)->( DbSkip(-1) )

			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³Quando nao houver proximo periodo ou competencia, devera ser   ³
			³tratado com informacoes do period que esta sendo fechado +1 dia³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			fArrNextPC(@aNextPer,@aNextComp,.F.,.F.,(cAliasRCH)->(Recno()),3)
		Else

			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³Array com as informacoes do proximo periodo - Transf. Verbas  ³
			³Periodo de Controle da Semana                                 ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			fArrNextPC(@aNextPer,,.T.,,(cAliasRCH)->(Recno()),1)

			While (cAliasRCH)->( !Eof() ) .and. (cAliasRCH)->RCH_FILIAL == cFilRCH .and. ;
				(cAliasRCH)->RCH_PROCES == cProcesso .and. (cAliasRCH)->RCH_ROTEIR == cRoteiro
				If (cAliasRCH)->RCH_PER == cPeriodo
					(cAliasRCH)->( DbSkip() )
				Else
					Exit
				EndIf
			EndDo

			If (cAliasRCH)->( !Eof() ) .and. (cAliasRCH)->RCH_FILIAL == cFilRCH .and. ;
				(cAliasRCH)->RCH_PROCES == cProcesso .and. (cAliasRCH)->RCH_ROTEIR == cRoteiro
				fArrNextPC(,@aNextComp,,.T.,(cAliasRCH)->(Recno()),2)
			Else
				lNextPer := .F.
				lRet := .F.
			EndIf

		EndIf

		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Para os periodos com Nro. de Pagamento em branco, devera veri³
		³ ficar quais lancamentos com Nro de Pagamento deverao ser fech³
		³ ados, pois podera existir periodos com mesmo codigo e Nro. de³
		³ pagamentos diferentes de branco. Esses deverao ser fechados  ³
		³ atraves do proprio periodo.                                  ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		If Empty(cNumPag)
			DbSelectArea( ("RCH") )
			(cAliasRCH)->(DbSetOrder( 4 )) // RCH_FILIAL + RCH_PROCES + RCH_ROTEIR + RCH_PER + RCH_NUMPAG
			DbSeek( cFilRCH + cProcesso + cRoteiro + cPeriodo, .F. )
			While (cAliasRCH)->(!Eof()) .and. (cAliasRCH)->(RCH_PER + RCH_PROCES + RCH_ROTEIR) == cPeriodo + cProcesso + cRoteiro
				If (cAliasRCH)->RCH_NUMPAG <> cNumPag
					aAdd( aPerPgto, { 	(cAliasRCH)->RCH_FILIAL	,;
					(cAliasRCH)->RCH_PER	,;
					(cAliasRCH)->RCH_NUMPAG	,;
					(cAliasRCH)->RCH_PROCES	,;
					(cAliasRCH)->RCH_ROTEIR	 ;
					} )
				EndIf
				(cAliasRCH)->( DbSkip() )
			EndDo
		EndIf
	EndIf
EndIf

RestArea(aArea)

Return lRet

/*/{Protheus.doc} fBuscaFer
Busca período aquisitivo atual
@type  Static Function
@author Cícero Alves
@since 02/12/2019
@return dRet, Data, Data base do período aquisitivo atual
/*/
Static Function fBuscaFer()
	
	Local aArea		:= GetArea()
	Local cChave 	:= ""
	Local dRet 		:= SRA->RA_ADMISSA
	
	cChave := SRA->RA_FILIAL + SRA->RA_MAT + aCodFol[72, 1]
	
	DbSelectArea("SRF")
	DbSetOrder(2)
	
	If DbSeek(cChave)
		While !Eof() .And. SRF->(RF_FILIAL + RF_MAT + RF_PD == cChave)
			If SRF->RF_STATUS == "1" //ATIVO
				dRet := SRF->RF_DATABAS
				Exit
			Else
				dRet := SRF->RF_DATAFIM + 1
			EndIf
			DbSkip()
		EndDo
	EndIf
	
	RestArea(aArea)
	
Return dRet