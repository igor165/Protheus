#INCLUDE "PROTHEUS.CH"

//--------------------------------
//DEFINE de SX6
//--------------------------------
#DEFINE MV_SPEDNAT		  01
#DEFINE MV_EASY		 	  02
#DEFINE MV_SPDIFC		  03
#DEFINE MV_RATPROP		  04
#DEFINE MV_M996TPR		  05
#DEFINE MV_ICMPAD		  06
#DEFINE MV_1DUPREF		  07
#DEFINE MV_2DUPREF		  08
#DEFINE MV_C140TIT		  09
#DEFINE MV_STFRETE		  10
#DEFINE MV_ESTTELE		  11
#DEFINE MV_SPDCGPC		  12
#DEFINE MV_CF3ENTR		  13
#DEFINE MV_CONTZF		  14
#DEFINE MV_NFCOMPL		  15
#DEFINE MV_QTAEC		  16
#DEFINE MV_VALEXCL		  17
#DEFINE MV_HISTTAB		  18
#DEFINE MV_PISCOFP		  19
#DEFINE MV_COFLSPD		  20
#DEFINE MV_SPEDCSC		  21
#DEFINE MV_SKPENC		  22
#DEFINE MV_STNIEUF		  23
#DEFINE MV_STUF		  	  24
#DEFINE MV_STUFS		  25
#DEFINE MV_RESF3FT		  26
#DEFINE MV_C100CAN		  27
#DEFINE MV_AGR1900		  28
#DEFINE MV_DFSRVAC		  29
#DEFINE MV_DEDBPIS		  30
#DEFINE MV_DEDBCOF		  31
#DEFINE MV_PRICMS		  32
#DEFINE MV_EFDSERI        33
#DEFINE MV_ICMDSDT        34
#DEFINE MV_SPEDCOP        35

//--------------------------------
//Abaixo Define de SX3
//--------------------------------
#DEFINE FP_F1_MENNOTA	  01
#DEFINE FP_F2_MENNOTA	  02
#DEFINE FP_A1_SUFRAMA	  03
#DEFINE FP_A2_SUFRAMA	  04
#DEFINE FP_A1_ENDNOT	  05
#DEFINE FP_A2_ENDNOT	  06
#DEFINE FP_FT_SERSAT	  07
#DEFINE FP_CF4_FLORIG	  08
#DEFINE FP_CL4_IDCLA	  09
#DEFINE FP_CL2_ALIAS	  10
#DEFINE FP_F1_DTCPISS	  11
#DEFINE FP_F2_DTESERV	  12
#DEFINE FP_FT_CLIDVMC	  13
#DEFINE FP_FT_TES		  14
#DEFINE FP_CL2_CLIFOR	  15
#DEFINE FP_CL2_LOJA		  16
#DEFINE FP_F1_SUBSERI	  17
#DEFINE FP_CKS_AJBCA	  18
#DEFINE FP_CKS_AJBCR	  19
#DEFINE FP_CKS_BCAJUS	  20
#DEFINE FP_A2_DEDBSPC	  21
#DEFINE FP_CCF_TRIB		  22
#DEFINE FP_FV_RESSA	      23 
#DEFINE FP_FV_COMP        24 
#DEFINE FP_FV_RESRET	  25 
#DEFINE FP_FW_RESSA	      26 
#DEFINE FP_FW_COMP        27 
#DEFINE FP_FW_RESRET	  28 
#DEFINE FP_F1_DEVMERC     29
#DEFINE FP_A2_CPFRUR	  30
#DEFINE FP_A2_INDRUR	  31 

//--------------------------------
//Abaixo DEFINE de Ponto de Entrada
//--------------------------------
#DEFINE SPDIMP				01
#DEFINE SPDPISIC			02
#DEFINE SPDPISTR			03
#DEFINE SPDPC0140			04
#DEFINE SPDPCIMOB			05
#DEFINE SPDPC1800			06
#DEFINE SPDPIS07			07
#DEFINE SPDPIS05			08
#DEFINE SPDPIS08			09
#DEFINE SPDFIS03			10
#DEFINE SPDFIS001			11
#DEFINE SPDFIS04			12
#DEFINE SPDPIS06			13
#DEFINE SPEDPROD			14
#DEFINE SPDFIS02			15
#DEFINE SPED0150			16
#DEFINE SPED0205			17
#DEFINE SPED0035			18
#DEFINE SPD1900A			19
#DEFINE SPDRA170			20

//010
#DEFINE A010				01
#DEFINE C010				02
#DEFINE D010				03
#DEFINE F010				04


STATIC aParSX6
STATIC aParSX3
STATIC aParPE
STATIC lMvPar23
STATIC oQryCVN
STATIC lBuild      := GetBuild() >= "7.00.131227A"

STATIC oPSAtiv	   := Nil
STATIC oJSAtiv	   := Nil
STATIC oJCFOP	   := Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA008

Rotina de geração do arquivo texto da EFD Contribuições.
O arquivo será gerado através desta rotina, utilizando as classes disponibilizadas
para esta obrigação. Aqui teremos query das operações, e irá gerenciar as chamadas
para geração do arquivo.
@author Erick G. Dias
@since 19/11/2014
@version 11.80
@description teste descrição

/*/
//-------------------------------------------------------------------
Function FISA008(lAutomato,aMvPar004,aAutoFil)

	Local oProcess
	Local aSM0		 	:= {}
	Local cValid		:= ''
	Local lProcessa		:= .F.
	Local lOk			:= .F.
	Local lCancel		:= .F.
	Local lExtTAFContr := .F.
	//Local nX			:= 0	

	Default aMvPar004	 := {}
	Default aAutoFil	 := {{.T., cFilAnt}}
	Default lAutomato	 := .F.

	If AliasINdic('CKR')

		If lAutomato
			lProcessa	:= .T.
		ElseIf pergunte('FSA008',!lExtTAFContr,'Parâmetros de geração do arquivo')
			cValid	:= ValidPerg()

			If !Empty(cValid)
				Alert(cValid + CRLF + 'Por favor verifique estas informações')
				lProcessa	:= .F.
			EndIF
			lProcessa	:= .T.
		EndIF

		IF lProcessa .AND. Empty(cValid)

			If !lAutomato
				//Aqui chama função para fazer o pergunte FSA004 com informações do contabilista, e retornar as informações no array
				aMvPar004:= ProcContab()
			EndIf

			//Busca as filiais selecionadas pelo usuário
			aSM0	:= GetFilial(lAutomato, aAutoFil)

			IF Len(aSM0) > 0
				ProcCache()

				If !lAutomato
					oProcess := FISProgress():New({||ProcEfd(oProcess,aMvPar004,aSM0,@lOk,@lCancel)},'Processando arquivo da EFD Contribuições',lExtTAFContr)
					oProcess:Activate()

					IF lCancel
						Alert("Operação Cancelada pelo usuário",'EFD Contribuições')
					EndIF
				Else
					Processa({|lCancel|ProcEfd(oProcess,aMvPar004,aSM0,@lOk,@lCancel)})
				EndIf

			EndIF
		EndIF
	Else
		Alert('Dicionário está desatualizado, por favor processar compatibilizador UPDFIS')
	EndIF	

    If oQryCVN <> Nil 
        FreeObj(oQryCVN)
        oQryCVN:= Nil 
    EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcEfd

Rotina que será executada, buscando informações da base de dados,
intgrações, ponto de entrada, identificando cada registro e chamando
as funções correspondentes para cada registro.
@author Erick G. Dias
@since 19/11/2014
@version 11.80
@description teste descrição

/*/
//-------------------------------------------------------------------
Static Function ProcEfd(oProcess,aMvPar004,aSM0,lOk,lCancel)

	Local oTabela
	Local oBloco0			:= EFDCBLOCO0():New()
	Local oBloco1			:= EFDCBLOCO1():New()
	Local oBlocoA			:= EFDCBLOCOA():New()
	Local oBlocoC			:= EFDCBLOCOC():New()
	Local oBlocoD			:= EFDCBLOCOD():New()
	Local oBlocoF			:= EFDCBLOCOF():New()
	Local oBlocoI			:= EFDCBLOCOI():New()
	Local oBlocoM			:= EFDCBLOCOM():New()
	Local oBlocoP			:= EFDCBLOCOP():New()
	Local TimeInicio
	Local TimeFim
	Local aAreaSM0			:= {}
	Local aNumeracao		:= {}
	Local aThread			:= {}
	Local aRegAux			:= {}
	Local aPar0035			:= {}
	Local c0140				:= ''
	Local c0140Pri			:= ''
	Local cA010				:= ''
	Local cC010				:= ''
	Local cD010				:= ''
	Local cF010				:= ''
	Local cArqErro			:= ''
	Local cJob				:= ''
	Local nNumIni			:= ''
	Local cFilMatriz		:= cFilAnt
	Local cSemaphore		:= 'EFDCONTRIB'+Alltrim(Str(ThreadID()))
	Local cSemaCons			:= 'EFDCONTRIBCONSOLID' + Alltrim(Str(ThreadID()))
	Local cJobCon			:= 'FISA008CONS' + Alltrim(Str(ThreadID()))
	Local lGrBlocoM			:= .T.
	Local lBlocACDF			:= .F.
	Local lRgCmpCons		:= .F.
	Local lRgCaxCons		:= .F.
	Local lRgCmpDet			:= .F.
	Local lBlocoI			:= .F.
	Local lBlocoP			:= .F.
	Local lGeraECF			:= .F.
	Local lConIndiv			:= .F.
	Local LEXTTAFCONTR		:= .F.
	Local lConcFil			:= aParSX6[MV_COFLSPD]
	Local nContFil			:= 0
	Local nContIniNf		:= 0
	Local nx				:= 0
	Local nTotErro			:= 0
	Local nTotProc			:= 0
	Local nQtdThread		:= aParSx6[MV_QTAEC]
	Local lReg0900			:= AliasIndic("CIC") .AND. FSA008X1("FSA008","MV_PAR24") .AND. MV_PAR24 == 1
	Local aVarGlobais 		:= {}
	Local lSM0Dup     		:= .f.	// Identifica mesmo CNPJ para filiais distintas em processamento MultThread
	
	STATIC NFENTRADA		:= '1'
	STATIC NFSAIDA 			:= '2'
	STATIC PIS 				:= '1'
	STATIC COFINS 			:= '2'

	For nx:= 1 to len( aSM0 )
		If 	aScan( aSM0, {|x| x[5]==aSM0[nx][5]}) <> nx 
			lSM0Dup := .T.
			exit
		Endif
	Next

	TimeInicio := Time()

	//Aqui irá definir qual período cada thread irá processar.
	If nQtdThread > 0
		aThread	:=	FSA08PerTd(nQtdThread,mv_par01, mv_par02)

	EndIF

	If mv_par01 >= CTOD("01/07/2012") .AND. mv_par08 == 2 //Se data for maior e regime exclusivamente cumulativo

		lBlocACDF	:= .F.
		lRgCmpCons	:= .F.
		lRgCaxCons	:= .F.
		lRgCmpDet	:= .F.

		If  mv_par16 == 1 // Regime de Caixa Consolidado
			lRgCaxCons	:= .T.
		ElseIf mv_par16 == 2 // regime de Competencia consolidado
			lRgCmpCons	:= .T.
		ElseIf mv_par16 == 3 // regime de Competencia detalhado
			lBlocACDF	:= .T.
			lRgCmpDet	:= .T.
		EndIF

	Else
		lBlocACDF	:= .T.
		If mv_par08 == 2
			lRgCmpDet	:= .T.
		EndIF
	EndIF

	If mv_par19 == 1 .AND. (lRgCmpDet .Or. lBlocACDF)
		lGeraECF := .T.
	EndIF

	If mv_par20 == 3 // Gerar exclusivamente informações do blocoP
		lGrBlocoM 	:= .F.
		lBlocACDF	:= .F.
		lGeraECF	:= .F.
	EndIf


	lBlocoI	:= mv_par12 == "3" .AND. !Empty(mv_par17) .AND.  mv_par01 >= cToD("31/12/2013")
	lBlocoP	:= mv_par20 == 1 .OR. mv_par20 == 3
	If lBlocoI
		lBlocACDF	:= .F.
		lRgCmpCons	:= .F.
		lRgCaxCons	:= .F.
		lRgCmpDet	:= .F.
		lGeraECF 	:= .F.
		lBlocoP		:= .F.
	EndIF

	lConIndiv	:= mv_par18 == 1
	If ValType(oProcess)=="O"
		oProcess:Set1Progress(len(aSM0))
		oProcess:Set2Progress(9)

		oProcess:SetDetProgress('Inicio do processamento',TimeInicio,;
			'Fim do Processamento',"" ,;
			'Tempo de processamento',"" ,;
			"","")
		oProcess:Inc1Progress('Iniciando processamento')//"Processando Filial"
	EndIf

	DbSelectArea ("CDG")
	CDG->(DbSetOrder (1))

	DbSelectArea ("CCE")
	CCE->(DbSetOrder (1))

	DbSelectArea ("CDT")
	CDT->(DbSetOrder (1))

	DbSelectArea ("CD5")
	CD5->(DbSetOrder (4))

	oBloco1	:= EFDCBLOCO1():New()
	oBlocoA	:= EFDCBLOCOA():New()
	oBlocoF	:= EFDCBLOCOF():New()

//-------------------------------------------------------------------
//cria objeto da tabela temporária que deverá ser utilizada no processamento dos registros
//-------------------------------------------------------------------
	oTabela	:= TabTemp(nQtdThread)

	//Inicia aqui as Threads de Processamento
	For nx:= 1 to len(aThread)
		cJob	:=	"FISA008" + AllTrim(Str(ThreadID())) + StrZero(nX,2)
		PutGlbValue( cJob , "9" ) //Iniciou
		GlbUnLock()
		StartJob('FSA08Thrd',GetEnvServer(),.F.,cSemaphore,cEmpAnt,cFilAnt,cJob,,lSM0Dup)
		ConOut("THREAD INICIADA: " + cJob)
	next nX
	//Inicia a Thread de consolidação
	If len(aThread) > 0
		//MultiThread, irá subir thread consolidadora com outro semaforo
		PutGlbValue( cJobCon , "9" ) //Iniciou
		GlbUnLock()
		StartJob('FSA08Consol',GetEnvServer(),.F.,cSemaCons,cEmpAnt,cFilAnt,cJobCon,aNumeracao,{oTabela:GetAlias(),oTabela:GetArqDbf(),oTabela:getAlsCad(),oTabela:getArqCad()},lSM0Dup)
	EndIF


	//Vericica abaixo se todas as Thread foram inicializadas corretamente antes de prosseguir
	If Len(aThread) > 0

		nTotProc	:= 0
		While nTotProc < len(aThread)
			For nx:= 1 to len(aThread)
				cJob	:=	"FISA008" + AllTrim(Str(ThreadID())) + StrZero(nX,2)
				While .T.

					IF GetGlbValue(cJob ) == '0'
						//Inicializou e está aguardando para ser chamada
						nTotProc++
						Exit
					EndIF
					Sleep(3000)
				EndDO
			Next nx
		EndDo
		While .T.

			IF GetGlbValue(cJobCon ) == '01'
				//Inicializou e está aguardando para ser chamada
				nTotProc++
				Exit
			EndIF
			Sleep(3000)
		EndDO
	EndIF

//-------------------------------------------------------------------
//Processa registro de abertura do arquivo.
//-------------------------------------------------------------------
	If ValType(oProcess)=="O"
		oProcess:Inc2Progress('Processando registros cabecalhos')//'Processando Notas Fiscais de Saída'
	EndIf

	Reg0000(mv_par01,mv_par02,@aNumeracao,oBloco0,oTabela)

//-------------------------------------------------------------------
//Registro 0120, dispensa da entrega da EFD
//-------------------------------------------------------------------
	ProcCKN(oBloco0, mv_par01,oTabela)

//-------------------------------------------------------------------
//Registro 0100 de contabilista
//-------------------------------------------------------------------
	Reg0100('0001000000001',aMvPar004,@aNumeracao,oBloco0,oTabela)

//-------------------------------------------------------------------
//Processa registro 0110
//-------------------------------------------------------------------
	Reg0110(mv_par01,mv_par02,'0001000000001',@aNumeracao,oBloco0,oTabela,lBlocACDF,lBlocoI,,,,lReg0900)

//-------------------------------------------------------------------
//Início do laço das filiais.
//-------------------------------------------------------------------
	aAreaSM0 := SM0->(GetArea())
	For nContFil := 1 to Len(aSM0)

		SM0->(DbGoTop ())
		SM0->(MsSeek (aSM0[nContFil][1]+aSM0[nContFil][2], .T.))	//Pego a filial mais proxima
		cFilAnt := FWGETCODFILIAL
	//Faz chamada para registro 0140 da matriz que é obrigatório mesmo que não tenha movimentação
		If ValType(oProcess)=="O"
			oProcess:Inc1Progress('Processando Filial: ' +FWGETCODFILIAL)//"Processando Filial"
		EndIf

	//Precisa verificar este parâmetro para cada filial

		If mv_par11 $'03/04' .AND. GetNewPar("MV_FILSCP",.F.)
		//Se estiver indicado para processar SCP com sociedade ostensiva, então deverá somente processar filial
		//onde o parâmetro MV_FILSCP estiver igual a .F., pois se estiver igual a .T. não é sócial ostensiva, e sim
		//sócia participante, que terá suas operações geradas em outro arquivo somente dela, por este motivo
		//pulo sócia participante quando mv_par18 etiver para processar sócia ostensiva.
			Loop
		EndIF

		Reg0140(oBloco0,@aNumeracao)
		c0140	:= oBloco0:getGrupo()

		If cFilMatriz == cFilAnt
			c0140Pri 	:= c0140
		EndIF

		cA010	:= ''
		cC010	:= ''
		cD010	:= ''
		cF010	:= ''

		IF lRgCmpCons .OR. lRgCmpDet
		//Irá processar somente saídas
			nContIniNf	:= 2
			cF010	:= RegF010(oBlocoF,oTabela,@aNumeracao)
			oBlocoF:setaNumer(@aNumeracao)
			oBloco1:setaNumer(@aNumeracao)
		ElseIf lBlocACDF
		//Irá processar entradas e saídas
			nContIniNf	:= 1
		Else
		//Caso contrário coloca 3 para não processar nem saídas e nem entradas
			nContIniNf	:= 3
		EndIF

		IF lBlocACDF
			If EmpTy(cA010)
				cA010:=RegA010(oBlocoA,oTabela,@aNumeracao)
			EndIF
			oBlocoA:setaNumer(@aNumeracao)

			If EmpTy(cC010)
				cC010:=RegC010(oBlocoC,oTabela,@aNumeracao,Iif(lConIndiv,'1','2'))
			EndIF
			oBlocoC:setaNumer(@aNumeracao)

			If EmpTy(cD010)
				cD010:=RegD010(oBlocoD,oTabela,@aNumeracao)
			EndIF
			oBlocoD:setaNumer(@aNumeracao)
		EndIF

		oBloco0:setDtDeAte(mv_par01,mv_par02)
		oBlocoA:setDtDeAte(mv_par01,mv_par02)
		oBlocoC:setDtDeAte(mv_par01,mv_par02)
		oBlocoD:setDtDeAte(mv_par01,mv_par02)
		oBlocoF:setDtDeAte(mv_par01,mv_par02)

		//Define Variaveis globais
		//Quando não existir a variavel Criar
		If Empty(GetGlbValue(cA010)) .And. !EmpTy(cA010)
			PutGlbValue( cA010, ".T." )
			Aadd(aVarGlobais,cA010) 
		Endif

		If  Empty(GetGlbValue(cC010)) .And. !EmpTy(cC010)
			PutGlbValue( cC010, ".T." ) 
			Aadd(aVarGlobais,cC010) 
		Endif

		If  Empty(GetGlbValue(cD010)) .And. !EmpTy(cD010)
			PutGlbValue( cD010, ".T." ) 
			Aadd(aVarGlobais,cD010) 
		Endif

		If  Empty(GetGlbValue(cF010)) .And. !EmpTy(cF010)
			PutGlbValue( cF010, ".T." )
			Aadd(aVarGlobais,cF010) 
		Endif	


		//Aqui chama função para processar os documentos fiscais
		///
		//Inicia os flags do array de multithread
		//Opção 3 indica que já iniciou o processamento na Thread
		//Opção 4 indica que processamento da thread já finalizou
		For nX	:= 1 to len(aThread)
			aThread[nx][3]	:= '0'
			aThread[nx][4]	:= '0'
		Next nX

		//A função que irá processar notas fiscais e cupom fiscal é a PROCNF, que pode ser chamada em miltithread
		//Abaixo irá verificar todas as Threas se ocorreu algum erro, se está processando ou se já concluiu o processamento
		//Somente continuará o processamento após todas finalizarem com sucesso o processamento
		//Se ocorrer algum erro em qualquer thread o processamento é abortado.

		If Len(aThread) > 0
			nTotProc	:= 0
			nTotErro	:= 0

			While nTotProc < len(aThread) .AND. nTotErro == 0

				For nx:= 1 to len(aThread)
					IF nTotErro > 0
						Exit
					EndIF

					cJob	:=	"FISA008" + AllTrim(Str(ThreadID())) + StrZero(nX,2)

					//Passa número inicial de sequencia para cada Thread, para não repetir a numeração
					IF nx == 1
						nNumIni	:= 1
					Else
						nNumIni	:= Int(999999999/len(aThread) * (nx -1 ))
					EndIF
					While .T.

						IF GetGlbValue(cJob ) == '3' .OR.   GetGlbValue(cJobCon ) $ '03/04'
							//Ocorreu erro na Thread , gravar no histórico de erro
							nTotProc++
							nTotErro++
							Exit

						ElseIF aThread[nx][3]	== '0'
							//Chama Thread para iniciar processamento
							If IPCGo( cSemaphore, nContIniNf,oTabela, aThread[nx][1], aThread[nx][2],c0140,lBlocACDF,lRgCmpCons,oProcess,{oTabela:GetAlias(),oTabela:GetArqDbf(),oTabela:getAlsCad(),oTabela:getArqCad()},cJob,lConIndiv,mv_par03,cSemaCons,lGeraECF,nNumIni,{cA010,cC010,cD010,cF010},{cEmpAnt,cFilAnt},{mv_par01,mv_par02},cJobCon)
								aThread[nx][3]	:= '1'

								Exit
							EndIF

						ElseIF GetGlbValue(cJob ) == '2'
								//Aqui a Thread finalizou processamento sem erro
								nTotProc++
								aThread[nx][4]	:= '1'
								PutGlbValue( cJob , "0" ) //Iniciou
								GlbUnLock()

								Exit

						ElseIF GetGlbValue(cJob ) == '1' //ainda processando, pular para próxima thread
							Sleep(3000)
							Exit
						ElseIF aThread[nx][4]	== '1'
							Exit	//J´[a foi finalizado e contabilizado
						EndIF

					EndDO

				Next nx
			EndDo


		Else
			//Aqui é fluxo normal sem Thread
			If lBlocACDF .OR. lRgCmpCons
				ProcNF(nContIniNf,oTabela, mv_par01, mv_par02,c0140,lBlocACDF,lRgCmpCons,oProcess,{},''  ,lConIndiv,mv_par03,'',lGeraECF,1,{cA010,cC010,cD010,cF010},{},{mv_par01,mv_par02},oBloco0,oBloco1,aNumeracao,lCancel,oBlocoD,cJobCon,lSM0Dup)
			EndIF
		EndIF
		////Trecho abaixo somente se for Multithread
		//Fecha todas as Threads para ficarem aguardando próxima filial se houver
		If Len(aThread) > 0
			If nTotErro > 0	//se houve algum erro então irá fechar as threads
				For nX	:= 1 to Len(aThread)

					cJob	:=	"FISA008" + AllTrim(Str(ThreadID())) + StrZero(nX,2)
					IPCGo( cSemaphore, nContIniNf,oTabela, aThread[nx][1], aThread[nx][2],c0140,lBlocACDF,lRgCmpCons,oProcess,{oTabela:GetAlias(),oTabela:GetArqDbf(),oTabela:getAlsCad(),oTabela:getArqCad()},'EXIT',lConIndiv,mv_par03,cSemaCons,lGeraECF,nNumIni,{cA010,cC010,cD010,cF010},{cEmpAnt,cFilAnt},cJobCon)

				Next nX

				IPCGo( cSemaCons, {} ,'EXIT')
				exit
			Else



			//Somente consolida após tods as thread finalizarem o processamento

				While .T. .AND. !GetGlbValue(cJobCon ) $ '03/04'
					If IPCGo( cSemaCons, {} ,'FILIAL')
						Sleep(3000)
						//Aqui conseguiu chamar thread
						While .T.
 							IF GetGlbValue(cJobCon ) == '01'
								//Finalizou consolidação
								Exit
							EndIF
							conout(cJobCon + ': Verificando se consolidada acabou de processar notas - ' + GetGlbValue(cJobCon))
							Sleep(3000)
						EndDo

						Exit
					EndIF
					Sleep(3000)
				EndDo


				DbSelectArea (oTabela:GetAlias())
				IndRegua (oTabela:GetAlias(), oTabela:GetArqDbf(), 'NROBLOCO+GRUPO+REGISTRO')
			EndIF
		EndIF

		If ValType(oProcess)=="O"
			oProcess:Inc2Progress('Processando' )//'Processando Notas Fiscais de Saída'
		EndIF

		//Daqui em diante não faz processamento MultiThread, pois irá somente buscar informações já gravadas pela apuração
		oBloco0:setMT(.F.)
		oBloco1:setMT(.F.)
		oBlocoA:setMT(.F.)
		oBlocoC:setMT(.F.)
		oBlocoD:setMT(.F.)
		oBlocoF:setMT(.F.)

		aRegNf		:= {}

	//Geração do registro 0035, se estiver preenchido informação de SCP na pergunta
		IF	mv_par11 $'03/04/05'
			// Ponto de Entrada para o cliente manipular o CNPJ e o nome a ser gerado para o registro 0035
			If	aParPe[ SPED0035 ]
				aRegAux := Execblock("SPED0035", .F., .F., {SM0->M0_CGC,SM0->M0_NOME})
				//Ira verificar se o retorno do ponto de entrada tem todas as informacoes necessarias
				If	ValType(aRegAux[1]) <> "A"
					If	Len(aRegAux) >= 2
						aPar0035	:= {}
						aAdd(aPar0035, aRegAux[1])
						aAdd(aPar0035, aRegAux[2])
						Proc0035('0001000000001', oBloco0, aPar0035[1], aPar0035[2], ''  )
					EndIf
				Else
					For	nX := 1 To Len(aRegAux)
						If	Len(aRegAux[nX]) >= 2
							aPar0035	:= {}
							aAdd(aPar0035, aRegAux[nX][1])
							aAdd(aPar0035, aRegAux[nX][2])
							Proc0035('0001000000001', oBloco0, aPar0035[1], aPar0035[2], ''  )
						EndIf
					Next nX
				EndIf
			Else
				Proc0035('0001000000001', oBloco0, SM0->M0_CGC, SM0->M0_NOME, ''  )
			EndIf
		EndIF

		//Gera processo referenciado
		If Year(mv_par01) >= 2019
			ProcICMS(oBloco1)
		EndIf

		If ValType(oProcess)=="O"
			If oProcess:Cancel()
				ProcCancel(@lCancel,oTabela)
				Return
			EndIf
		EndIf

		If ValType(oProcess)=="O"
			oProcess:Inc2Progress('Processando operações do bloco F' )//'Processando Notas Fiscais de Saída'
			If oProcess:Cancel()
				ProcCancel(@lCancel,oTabela)
				Return
			EndIf
		EndIf

		//-------------------------------------------------
		//Irá processa registros do BLoco F
		//-------------------------------------------------
		BlocoF(@aNumeracao,oTabela,oBlocoF,oBloco1,oBloco0,lConcFil,mv_par01,mv_par02,c0140,lBlocACDF,lRgCaxCons,lGrBlocoM,lRgCmpCons,mv_par03,,aVarGlobais)

		IF lRgCmpCons
			oTabela:GrvReg(oBlocoF:getF550())
			oTabela:GrvReg(oBlocoF:getF559())

			oTabela:GrvReg(oBlocoF:getF560())
			oTabela:GrvReg(oBlocoF:getF569())

			oBlocoF:clsF550()
		EndIF

		If ValType(oProcess)=="O"
			oProcess:Inc2Progress('Processando operações do bloco P' )//'Processando Notas Fiscais de Saída'
			If oProcess:Cancel()
				ProcCancel(@lCancel,oTabela)
				Return
			EndIf
		EndIF
		//-------------------------------------------------
		//Irá processa registros do BLoco P
		//-------------------------------------------------
		If lBlocoP
			BlocoP(@aNumeracao,oTabela, Iif(cFilMatriz == cFilAnt, .T.,.F.),oBloco0,lConcFil,c0140,c0140Pri,oBlocoP,mv_par01,mv_par02)
		EndIF

		//-------------------------------------------------
		//Irá processa registros do BLoco I
		//-------------------------------------------------
		If lblocoI
		//Aguardando validação do bloco I, na versão beta ainda não será gerado.
			BlocoI(@aNumeracao,oTabela,oBloco0,oTabela,lConcFil,oBloco1)
		EndIF

		//Remore registros X010 Que não possuem Filhos		
		If GetGlbValue(cA010) =='.T.' //GetGlbValue("GeraA010") == 'T'			
			oBlocoA:LimpaX010(cA010)			
		Endif		
		
		If GetGlbValue(cC010) =='.T.'			
			oBlocoC:LimpaX010(cC010)			
		Endif 
				
		If GetGlbValue(cD010) =='.T.'			
			oBlocoD:LimpaX010(cD010)			
		Endif

		If GetGlbValue(cF010) =='.T.'			
			oBlocoF:LimpaX010(cF010)			
		Endif

	//Aqui termina o processamento da filial, irá para próxima
	Next nContFil
	//Trecho abaixo somente se for MultiThread
	IF Len(aThread) > 0 .AND. nTotErro == 0
		For nX	:= 1 to Len(aThread)

			While .T.

				cJob	:=	"FISA008" + AllTrim(Str(ThreadID())) + StrZero(nX,2)
				If IPCGo( cSemaphore, nContIniNf,oTabela, aThread[nx][1], aThread[nx][2],c0140,lBlocACDF,lRgCmpCons,oProcess,{oTabela:GetAlias(),oTabela:GetArqDbf(),oTabela:getAlsCad(),oTabela:getArqCad()},'EXIT',lConIndiv,mv_par03,cSemaCons,lGeraECF,nNumIni,{cA010,cC010,cD010,cF010},{cEmpAnt,cFilAnt})
					Exit
				EndIF

			EndDo
		Next nX

		While .T.
			If IPCGo( cSemaCons, {} ,'EXIT')
				//Aqui conseguiu chamar thread
				Sleep(3000)
				While .T.
					IF GetGlbValue(cJobCon ) == '04'
						//Finalizou consolidação
						Exit
					EndIF
					conout(cJobCon + ': Verificando se consolidada já gravou arrays.')
					Sleep(3000)
				EndDo

				Exit
			EndIF
			Sleep(3000)
		EndDo
		//Refaz indice apos processar todas Filiais
		DbSelectArea (oTabela:GetAlias())
		IndRegua (oTabela:GetAlias(), oTabela:GetArqDbf(), 'NROBLOCO+GRUPO+REGISTRO')
	EndIF

	//Limpa variaveis globais
	For nX := 1 to Len(aVarGlobais)
		If !Empty(GetGlbValue(aVarGlobais[nX]))
			ClearGlbValue(aVarGlobais[nX])
		endif
	Next

	IF nTotErro > 0
		TimeFim := Time()
		If ValType(oProcess)=="O"
			oProcess:Inc2Progress('Operação abortada' )//'Processando Notas Fiscais de Saída'
			oProcess:SetDetProgress('Inicio do processamento',TimeInicio,;
			'Fim do Processamento',TimeFim ,;
			'Tempo de processamento',ELAPTIME(TimeInicio,TimeFim) ,;
			"","")
			alert('Ocorreu erro no processamento de Threads, consultar erro no histórico de log','EFD Contribuições')
			ProcLogView("","FISA008")
		EndIf
		Return
	EndIF
	
	//-------------------------------------------------
	//FIM DO LAÇO DAS FILIAIS, RESTAURA A FILIAL LOGADA
	//-------------------------------------------------
	RestArea (aAreaSM0)
	cFilAnt := FWGETCODFILIAL

	//Grava registros A010 depois de processar todas as filiais.
	oTabela:GrvReg(oBlocoA:getA010())

	//Grava registros A010 depois de processar todas as filiais.
	oTabela:GrvReg(oBlocoC:getC010())

	//Grava registros A010 depois de processar todas as filiais.
	oTabela:GrvReg(oBlocoD:getD010())

	//Grava registros A010 depois de processar todas as filiais.
	oTabela:GrvReg(oBlocoF:getF010())

	//-------------------------------------------------
	//Gravação dos registros 1010 e 1020, detalhamento de processo referenciado
	//-------------------------------------------------
	oTabela:GrvReg(oBloco1:get1010())

	//Geração do registro com detalhamento da exigibilidade suspensa
	IF AliasIndic("CIE") .AND. mv_par01 >= CTOD("01/01/2020")
		oTabela:GrvReg(oBloco1:get1011())
	EndIF

	oTabela:GrvReg(oBloco1:get1020())

	//Trecho para geração do registro 1050
	IF AliasIndic("F3P") .AND. mv_par01 >= CTOD("01/01/2019")
		Qry1050(mv_par01, "1001000000001", oBloco1)
		oTabela:GrvReg(oBloco1:get1050())
	EndIF

	If ValType(oProcess)=="O"
		oProcess:Inc2Progress('Processandodo bloco M' )//'Processando Notas Fiscais de Saída'
		If oProcess:Cancel()
			ProcCancel(@lCancel,oTabela)
			Return
		EndIf
	EndIf

	oTabela:GrvReg(oBloco0:get0035())

	//-------------------------------------------------
	//Processa registros do bloco P, que foram gravados
	//pelas Filiais.
	//-------------------------------------------------
	If ValType(oBlocoP)=="O"

		//Grava registros P010 depois de processar todas as filiais.
		oTabela:GrvReg(oBlocoP:getP010())

		//Processa receita para Filiais
		oBlocoP:ProcRec()

		//Grava P100
		oTabela:GrvReg(oBlocoP:getP100())

		//Limpa objeto
		oBlocoP:clsP100()
	Endif
	//-------------------------------------------------
	//Processa registros do bloco D, que foram gravados
	//pelas Filiais.
	//-------------------------------------------------
	//Grava D200 consolidado por filiais
	If ValType(oBlocoD)=="O"
		oTabela:GrvReg(oBlocoD:getD200())
		oTabela:GrvReg(oBlocoD:getD201())
		oTabela:GrvReg(oBlocoD:getD205())
		oTabela:GrvReg(oBlocoD:getD209())
		oBlocoD:clsD200()
	EndiF
	//-------------------------------------------------
	//Processa registros do bloco M, que foram gravados
	//pela apuração.
	//-------------------------------------------------
	IF lGrBlocoM
		BlocoM(@aNumeracao,oTabela,oBloco0,lConcFil,aSM0)


		oBloco1:setaNumer(@aNumeracao)

		//-------------------------------------------------
		//Processa saldo de crédito de PIS
		//-------------------------------------------------
		If mv_par08 <> 2
			ProcCCYCCW (oBloco1, mv_par01, PIS)
			oTabela:GrvReg(oBloco1:get1100())
			oBloco1:cls1100()

			//-------------------------------------------------
			//Processa saldo de crédito de COFINS
			//-------------------------------------------------
			ProcCCYCCW (oBloco1, mv_par01, COFINS)
			oTabela:GrvReg(oBloco1:get1500())
			oBloco1:cls1500()
		EndIf

		//-------------------------------------------------
		//Processa saldo retenção de PIS
		//-------------------------------------------------
		ProcSFVSFW (oBloco1, mv_par01, PIS)
		oTabela:GrvReg(oBloco1:get1300())
		oBloco1:cls1300()

		//-------------------------------------------------
		//Processa saldo retenção de COFINS
		//-------------------------------------------------
		ProcSFVSFW (oBloco1, mv_par01, COFINS)
		oTabela:GrvReg(oBloco1:get1700())
		oBloco1:cls1700()
	EndIF

	IF  lRgCmpCons .OR. lRgCaxCons
		oTabela:GrvReg(oBloco1:get1900())
	EndIF


	//-------------------------------------------------
	//Ponto de entrada para registro 1800
	//-------------------------------------------------
	IF aParPE[SPDPC1800]
		Proc1800('1001000000001', oBloco1, ExecBlock("SPDPC1800",.F.,.F.,{{},mv_par01,mv_par02}))
		oTabela:GrvReg(oBloco1:get1800())
		oBloco1:cls1800()
	EndIF

	//Atualiza as classes com contadores atualizados antes de gerar registros de contadores.
	oBloco0:setaNumer(aNumeracao)
	oBloco1:setaNumer(aNumeracao)
	oBlocoA:setaNumer(aNumeracao)
	oBlocoC:setaNumer(aNumeracao)
	oBlocoD:setaNumer(aNumeracao)
	oBlocoF:setaNumer(aNumeracao)
	oBlocoI:setaNumer(aNumeracao)
	oBlocoM:setaNumer(aNumeracao)
	oBlocoP:setaNumer(aNumeracao)

	//--------------------------------------------------------------------------------------------
	//Chama função para gravar registro que por algum motivo não foram gravados, já que
	//precisaram ter informações acumuladas, e serão gravados todos de uma só vez aqui
	//--------------------------------------------------------------------------------------------
	GrvRegAcum(oBloco0, oTabela)
	If ValType(oProcess)=="O"
		oProcess:Inc2Progress('Processandodo bloco 9' )//'Processando Notas Fiscais de Saída'
		If oProcess:Cancel()
			ProcCancel(@lCancel,oTabela)
			Return
		EndIf
	EndIf
	//--------------------------------------------------------------------------------------------
	//Chama função para realizar a contagem dos registros gerados, e serão considerados no bloco 9
	//--------------------------------------------------------------------------------------------
	ContBloco9(oTabela, oBloco0, oBloco1, oBlocoA, oBlocoC, oBlocoD, oBlocoF, oBlocoI, oBlocoM, oBlocoP,mv_par01)

	//-----------------------------------------------------------------------------
	//Grava arquivo texto e fecha tabela temporária
	//-----------------------------------------------------------------------------
	If ValType(oProcess)=="O"
		oProcess:Inc2Progress('Gravando arquivo texto')
		If oProcess:Cancel()
			ProcCancel(@lCancel,oTabela)
			Return
		EndIf
	EndIf

	//-----------------------------------------------------------------------------
	//Neste ponto todos os registros fora processados, irá chamar método para gravar
	//informações da tabela temporária para arquivo texto.
	//-----------------------------------------------------------------------------
	cArqErro := otabela:GravaTXT()
	If !Empty(cArqErro)
		Alert('Erro ao gerar arquivo, ele pode estar sendo utilizado por outro aplicativo. Novo arquivo será criado.')
	EndIf

	//-----------------------------------------------------------------------------
	//Deleta tabelas temporárias utilizadas no processamento
	//-----------------------------------------------------------------------------
	oTabela:DelTabela()
	oTabela:DelTabCad()
	DelTodasTabCad()

	nTotProc := 0

	TimeFim := Time()

	If ValType(oProcess)=="O"

		oProcess:Inc2Progress('Concluído' )//'Processando Notas Fiscais de Saída'
		oProcess:SetDetProgress('Inicio do processamento',TimeInicio,;
			'Fim do Processamento',TimeFim ,;
			'Tempo de processamento',ELAPTIME(TimeInicio,TimeFim) ,;
			"","")
	EndIf

	IF nTotErro > 0
		MsgInfo('Ocorreu erro no processamento de Threads, consultar erro no histórico de log','EFD Contribuições')
	ElseIF !lcancel .And. !lExtTAFContr

		IF  Empty(cArqErro)
			MsgInfo("Arquivo " + oTabela:getNomeArq() + "  gerado com Sucesso",'EFD Contribuições')
		ElseIf cArqErro <> "XXXXXX"
			MsgInfo("Novo arquivo " + cArqErro + "  gerado com Sucesso",'EFD Contribuições')
		EndIF
		lOk	:= .T.
	EndIf

	//-----------------------------------------------------------------------------
	//Destroi os objetos criados
	//-----------------------------------------------------------------------------
	FreeObj(oBlocoA)
	oBlocoA:= nil

	FreeObj(oBlocoC)
	oBlocoC:= nil

	FreeObj(oBlocoD)
	oBlocoD:= nil

	FreeObj(oBlocoP)
	oBlocoP:= nil
	
	FreeObj(oTabela)
	oTabela:= nil

	FreeObj(oJSAtiv)
	oJSAtiv := Nil

	FreeObj(oPSAtiv)
	oPSAtiv := Nil

	FreeObj(oJCFOP)
	oJSCFOP := Nil

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GetFilial

Esta função retorna um array com as filiais selecionadas pelo
usuário através da MatFilCacl.

@return aSM0,array, Array com informações das filiais selecionadas
@author Erick G. Dias
@since 01/12/14
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function GetFilial(lAutomato, aAutoFil)

	Local aFil		:= {}
	Local aSM0		:= {}
	Local aAreaSM0	:= {}
	Local nFil		:= 0

	If MV_PAR04 == 1
		If lAutomato
			aFil:= MatFilCalc( .F., aAutoFil )
		Else
			//chama função para usuário escolher filial
			aFil:= MatFilCalc( .T. )
			If len(aFil) ==0
				MsgAlert('Nenhuma filial foi selecionada, o processamento não será realizado.')
			EndiF
		EndIf
	EndIF

	IF MV_PAR04 <> 1
	//Adiciona filial logada para realizar o processamento
		AADD(aFil,{.T.,SM0->M0_CODFIL,SM0->M0_FILIAL,SM0->M0_CGC})
	EndIF

	aAreaSM0 := SM0->(GetArea())
	DbSelectArea("SM0")
	//--------------------------------------------------------
	//Irá preencher aSM0 somente com as filiais selecionadas
	//pelo cliente
	//--------------------------------------------------------
	If Len(aFil) > 0
		SM0->(DbGoTop())
		If SM0->(MsSeek(cEmpAnt))
			Do While !SM0->(Eof())
				nFil := Ascan(aFil,{|x|AllTrim(x[2])==Alltrim(SM0->M0_CODFIL) .And. x[4] == SM0->M0_CGC})
				If nFil > 0 .And. aFil[nFil][1] .AND. cEmpAnt == SM0->M0_CODIGO
					Aadd(aSM0,{SM0->M0_CODIGO,SM0->M0_CODFIL,SM0->M0_FILIAL,SM0->M0_NOME,SM0->M0_CGC})
				EndIf
				SM0->(dbSkip())
			Enddo
		EndIf

		SM0->(RestArea(aAreaSM0))
	EndIF

Return  aSM0

//-------------------------------------------------------------------
/*/{Protheus.doc} ContBloco9()
@description Função que irá realizar contagem dos registros gerados para
			   levar informações para o bloco 9
@return		lProc,Boolean,Indica se o processamento deverá ou não prosseguir
@author Erick G. Dias
@since 27/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function ContBloco9(oTabela, oBloco0, oBloco1, oBlocoA, oBlocoC, oBlocoD, oBlocoF, oBlocoI, oBlocoM, oBlocoP,dDataDe)

	Local aRetCont		:= {}
	Local aContReg		:= {}
	Local aContBloco	:= {}
	Local nCont			:= 0
	Local nTotArqTxt	:= 0
	Local nTotBloco9	:= 0

	//Chama função que irá buscar da tabela temporária os registros gravados e irá retornar seus totalizadores
	aRetCont		:= ContReg(oTabela)
	aContReg		:= aRetCont[1]
	aContBloco		:= aRetCont[2]

	//Faz laço no array de contador por registro para gerar registro 9900 para cada registro gerado.
	For nCont	:= 1 To len(aContReg)
		PrcReg9900(oBloco0, aContReg[nCont][1], Alltrim(Str(aContReg[nCont][2])))
		nTotArqTxt += aContReg[nCont][2] //Considero aqui a quantidade de registro no contador do registro 9999
	Next nCont

	//Atualiza contadores do bloco 9 e do arquivo.
	nTotArqTxt	+=  Len(aContReg) //Somo aqui a quantidade de registro do bloco 9
	nTotBloco9 := Len(aContReg)

	//Laço para gerar registro e abertura e fechamento de cada bloco.
	For nCont	:= 1  to Len(aContBloco)
		Do Case
		Case nCont	 == 1
			//-------------------------------------------------------------------
			//CONTAGEM BLOCO ZERO
			//-------------------------------------------------------------------
			PrcAbreBlc('', oBloco0, '0001', Iif(aContBloco[nCont] == '0' ,'1' ,'0' ),oTabela)
			PrcEncBlc('', oBloco0, '0990', AllTrim(STR(Val( aContBloco[nCont] )+2)),oTabela)
			PrcReg9900(oBloco0, '0001', '1') //Registro 9900 da abertura do bloco
			PrcReg9900(oBloco0, '0990', '1') //Registro 9900 do encerramento do bloco
			nTotBloco9		+= 2
			nTotArqTxt 	+= 4

		Case nCont	 == 2
			//-------------------------------------------------------------------
			//CONTAGEM BLOCO UM
			//-------------------------------------------------------------------
			PrcAbreBlc('', oBloco1, '1001', Iif(aContBloco[nCont] == '0' ,'1' ,'0' ),oTabela)
			PrcEncBlc('', oBloco1, '1990', AllTrim(STR(Val( aContBloco[nCont] )+2)),oTabela)
			PrcReg9900(oBloco0, '1001', '1') //Registro 9900 da abertura do bloco
			PrcReg9900(oBloco0, '1990', '1') //Registro 9900 do encerramento do bloco
			nTotBloco9		+= 2
			nTotArqTxt 	+= 4

		Case nCont	 == 3
			//-------------------------------------------------------------------
			//CONTAGEM BLOCO A
			//-------------------------------------------------------------------
			PrcAbreBlc('', oBlocoA, 'A001', Iif(aContBloco[nCont] == '0' ,'1' ,'0' ),oTabela)
			PrcEncBlc('', oBlocoA, 'A990', AllTrim(STR(Val( aContBloco[nCont] )+2)),oTabela)
			PrcReg9900(oBloco0, 'A001', '1') //Registro 9900 da abertura do bloco
			PrcReg9900(oBloco0, 'A990', '1') //Registro 9900 do encerramento do bloco
			nTotBloco9		+= 2
			nTotArqTxt 	+= 4

		Case nCont	 == 4
			//-------------------------------------------------------------------
			//CONTAGEM BLOCO C
			//-------------------------------------------------------------------
			PrcAbreBlc('', oBlocoC, 'C001', Iif(aContBloco[nCont] == '0' ,'1' ,'0' ),oTabela)
			PrcEncBlc('', oBlocoC, 'C990', AllTrim(STR(Val( aContBloco[nCont] )+2)),oTabela)
			PrcReg9900(oBloco0, 'C001', '1') //Registro 9900 da abertura do bloco
			PrcReg9900(oBloco0, 'C990', '1') //Registro 9900 do encerramento do bloco
			nTotBloco9		+= 2
			nTotArqTxt 	+= 4

		Case nCont	 == 5
			//-------------------------------------------------------------------
			//CONTAGEM BLOCO D
			//-------------------------------------------------------------------
			PrcAbreBlc('', oBlocoD, 'D001', Iif(aContBloco[nCont] == '0' ,'1' ,'0' ),oTabela)
			PrcEncBlc('', oBlocoD, 'D990', AllTrim(STR(Val( aContBloco[nCont] )+2)),oTabela)
			PrcReg9900(oBloco0, 'D001', '1') //Registro 9900 da abertura do bloco
			PrcReg9900(oBloco0, 'D990', '1') //Registro 9900 do encerramento do bloco
			nTotBloco9		+= 2
			nTotArqTxt 	+= 4

		Case nCont	 == 6
			//-------------------------------------------------------------------
			//CONTAGEM BLOCO F
			//-------------------------------------------------------------------
			PrcAbreBlc('', oBlocoF, 'F001', Iif(aContBloco[nCont] == '0' ,'1' ,'0' ),oTabela)
			PrcEncBlc('', oBlocoF, 'F990', AllTrim(STR(Val( aContBloco[nCont] )+2)),oTabela)
			PrcReg9900(oBloco0, 'F001', '1') //Registro 9900 da abertura do bloco
			PrcReg9900(oBloco0, 'F990', '1') //Registro 9900 do encerramento do bloco
			nTotBloco9		+= 2
			nTotArqTxt 	+= 4


		Case nCont	 == 7
			//-------------------------------------------------------------------
			//CONTAGEM BLOCO I
			//-------------------------------------------------------------------
			If dDataDe > cToD("31/12/2013")
				PrcAbreBlc('', oBlocoI, 'I001', Iif(aContBloco[nCont] == '0' ,'1' ,'0' ),oTabela)
				PrcEncBlc('', oBlocoI, 'I990', AllTrim(STR(Val( aContBloco[nCont] )+2)),oTabela)
				PrcReg9900(oBloco0, 'I001', '1') //Registro 9900 da abertura do bloco
				PrcReg9900(oBloco0, 'I990', '1') //Registro 9900 do encerramento do bloco
				nTotBloco9		+= 2
				nTotArqTxt 	+= 4
			EndIF
		Case nCont	 == 8
			//-------------------------------------------------------------------
			//CONTAGEM BLOCO M
			//-------------------------------------------------------------------
			PrcAbreBlc('', oBlocoM, 'M001', Iif(aContBloco[nCont] == '0' ,'1' ,'0' ),oTabela)
			PrcEncBlc('', oBlocoM, 'M990', AllTrim(STR(Val( aContBloco[nCont] )+2)),oTabela)
			PrcReg9900(oBloco0, 'M001', '1') //Registro 9900 da abertura do bloco
			PrcReg9900(oBloco0, 'M990', '1') //Registro 9900 do encerramento do bloco
			nTotBloco9		+= 2
			nTotArqTxt 	+= 4

		Case nCont	 == 9
			//-------------------------------------------------------------------
			//CONTAGEM BLOCO P
			//-------------------------------------------------------------------
			PrcAbreBlc('', oBlocoP, 'P001', Iif(aContBloco[nCont] == '0' ,'1' ,'0' ),oTabela)
			PrcEncBlc('', oBlocoP, 'P990', AllTrim(STR(Val( aContBloco[nCont] )+2)),oTabela)
			PrcReg9900(oBloco0, 'P001', '1') //Registro 9900 da abertura do bloco
			PrcReg9900(oBloco0, 'P990', '1') //Registro 9900 do encerramento do bloco
			nTotBloco9		+= 2
			nTotArqTxt 	+= 4

		EndCase
	Next nCont

	//Gera os últimos totalizadores do arquivo
	nTotBloco9 += 7 //Somo 6 pois faltam considerar:1= Contador do 9001/2= contador do 9990 /3= contador do próprio 9900 /4= contador do 9999 / 5= 9990 / 6= 9001

	//Abertura e encerramento do bloco 9.
	PrcAbreBlc('', oBloco0, '9001', '0',oTabela)
	PrcEncBlc('', oBloco0, '9990', AllTrim(STR( nTotBloco9)),oTabela)
	PrcReg9900(oBloco0, '9001', '1')
	PrcReg9900(oBloco0, '9990', '1')
	PrcReg9900(oBloco0, '9900', AllTrim(STR( nTotBloco9-2)))
	PrcReg9900(oBloco0, '9999', '1')
	oTabela:GrvReg(oBloco0:get9900())

	//Procesa último registro do arquivo.
	nTotArqTxt += 7
	PrcEncBlc('', oBloco0, '9999', AllTrim(STR( nTotArqTxt)),oTabela)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidPerg()
@description Função que que irá fazer validações das perguntas iniciais
			   para geração do arquivo
@return		lProc,Boolean,Indica se o processamento deverá ou não prosseguir
@author Erick G. Dias
@since 27/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function ValidPerg()
	Local cLib		:= ''
	Local nRemType	:= GetRemoteType(@cLib)
	Local lHtml		:= Iif(nRemType == 5, .T., .F. )//'HTML' $ cLib
	Local cMensagem	:= ''

	If Empty(mv_par01) .OR. Empty(mv_par02)	//Verifica se a data inicial e final estão preenchidas
		cMensagem	:= 'É necessário preencher o período inicial e final'
	ElseIF mv_par01 > mv_par02 //Verifica se data final é maior que data inicial
		cMensagem	:= 'A data final não poderá ser maior que a data inicial'
	ElseIF "'"$AllTrim(mv_par03)
		cMensagem	:= 'O livro informado para apuração é inválido.'
	ElseIF (Empty(mv_par05) .OR. Len(Directory(Alltrim(mv_par05)+"*.*","D")) == 0) .And. !lHtml	//Verifica se o diretório informado é válido
		cMensagem	:= 'É necessário informar um diretório válido para geração do arquivo.'
	ElseIF Empty(mv_par06) //Verifica se o nome do arquivo foi informado.
		cMensagem	:= 'É necessário informar o nome do arquivo'
	EndIF

Return cMensagem

//-------------------------------------------------------------------
/*/{Protheus.doc} TabTemp()
@description Esta função irá criar a tabela temporária para processamento
			   dos registros, através dos métodos da classe ARRAYTOTMP em FISX002
@return		oTabTemp,Objeto,Objeto da classe ARRAYTOTMP instanciado
@author Erick G. Dias
@since 19/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function TabTemp(nQtdThread)

	Local oTabTemp	:=ARRAYTOTMP():New()
	Local cNomeArq	:= ''
	Local cLib		:= ''
	Local cTpTab	:= ''
	Local nRemType 	:= GetRemoteType(@cLib)
	Local lHtml		:= Iif(nRemType == 5, .T., .F. )//'HTML' $ cLib
	Local cDir		:= IIf(lHtml,AllTrim( GetSrvProfString( "StartPath" , "" ) ) ,Alltrim(mv_par05))


//Tratamento para Linux onde a barra e invertida
	If !(lHtml)
		If nRemType == 2 // REMOTE_LINUX
			If (SubStr (cDir, Len (cDir), 1)<>"/")
				cDir	+=	"/"
			EndIf
		Else
			If (SubStr (cDir, Len (cDir), 1)<>"\")
				cDir	+=	"\"
			EndIf
		EndIf
	EndIf

//Gera nome do arquivo
	cNomeArq	:= Alltrim(mv_par06)

//Passa nome do arquivo para objeto
	oTabTemp:setNomeArq(cNomeArq)

	oTabTemp:setDiretor(cDir)
	oTabTemp:setHtml(lHtml)

//Cria tabela temporária
	oTabTemp:CriaTabela(nQtdThread == 0) //se for igual a zero quantidade de Thread irá criar em Ctree..para multi thread irá criar DBF.

//Cria tabela temporária
	If nQtdThread == 0
		cTpTab	:='3' //cTree
	Else
		cTpTab	:='1' //Top
	EndIF
	oTabTemp:CriaTabCad(,cTpTab)

Return oTabTemp

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA008SReg()
@description Função que irá realizar o controle do número sequencial dos registros
			   conforme são gerados.
@param			aGrupoReg,array,Array com contadores dos registregistros
@param			cGrupoPai,String,Grupo do registro pai já gerado
@param			cReg,String,Registro em questão
@return		aGrupoReg[nPos][2],Integer,Númer sequencial do registro em questão.
@author Erick G. Dias
@since 19/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function FSA008SReg(aGrupoReg, cGrupoPai, cReg)

	Local nPos			:= 0
	Local cGrupoReg		:= ''

	nPos := aScan (aGrupoReg, {|aX| aX[1] == cReg })

	If nPos > 0
		//Se encontrar o registro então irá adicionar
		aGrupoReg[nPos][2] ++
	Else
		//Caso contrário irá incluir registro no controle
		aAdd(aGrupoReg, {})
		nPos := Len(aGrupoReg)
		aAdd (aGrupoReg[nPos], cReg)
		aAdd (aGrupoReg[nPos], 1)
	EndIF

	//Aqui processa o valor do grupo do registro, que será retornado para gravação.
	cGrupoReg	:=FSA008GReg(cGrupoPai,cReg,aGrupoReg[nPos][2])

Return cGrupoReg

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA008GReg()
@description Função que irá gerar o grupo do registro, considerando
			   o grupo do registro pai já gerado, o registro e seu contador
@param			cGrupoPai,String,Grupo do registro pai
@param			cReg,String,Registro em questão
@param			nCont,Integer,Contador do registro	
@return		aGrupoReg[nPos][2],Integer,Númer sequencial do registro em questão.
@author Erick G. Dias
@since 19/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function FSA008GReg(cGrupoPai,cReg,nCont)

	Local cGrupo	:= ''

	cGrupo:=cGrupoPai+cReg+Strzero(nCont,9)

Return cGrupo


Function IniciaReg(aGrupoReg,nContIni)


FSA008IReg(@aGrupoReg,nContIni, 'C100')
FSA008IReg(@aGrupoReg,nContIni, 'C110')
FSA008IReg(@aGrupoReg,nContIni, 'C111')
FSA008IReg(@aGrupoReg,nContIni, 'C120')
FSA008IReg(@aGrupoReg,nContIni, 'C170')
FSA008IReg(@aGrupoReg,nContIni, 'C395')
FSA008IReg(@aGrupoReg,nContIni, 'C396')
FSA008IReg(@aGrupoReg,nContIni, 'C500')
FSA008IReg(@aGrupoReg,nContIni, 'C505')
FSA008IReg(@aGrupoReg,nContIni, 'C509')
FSA008IReg(@aGrupoReg,nContIni, 'C860')
FSA008IReg(@aGrupoReg,nContIni, 'C870')
FSA008IReg(@aGrupoReg,nContIni, 'C880')
FSA008IReg(@aGrupoReg,nContIni, 'A100')
FSA008IReg(@aGrupoReg,nContIni, 'A110')
FSA008IReg(@aGrupoReg,nContIni, 'A111')
FSA008IReg(@aGrupoReg,nContIni, 'A120')
FSA008IReg(@aGrupoReg,nContIni, 'A170')
FSA008IReg(@aGrupoReg,nContIni, 'D100')
FSA008IReg(@aGrupoReg,nContIni, 'D101')
FSA008IReg(@aGrupoReg,nContIni, 'D105')
FSA008IReg(@aGrupoReg,nContIni, 'D111')
FSA008IReg(@aGrupoReg,nContIni, 'D350')
FSA008IReg(@aGrupoReg,nContIni, 'D359')
FSA008IReg(@aGrupoReg,nContIni, 'D500')
FSA008IReg(@aGrupoReg,nContIni, 'D501')
FSA008IReg(@aGrupoReg,nContIni, 'D505')
FSA008IReg(@aGrupoReg,nContIni, 'D509')
FSA008IReg(@aGrupoReg,nContIni, 'F550')
FSA008IReg(@aGrupoReg,nContIni, 'F559')
FSA008IReg(@aGrupoReg,nContIni, 'F560')
FSA008IReg(@aGrupoReg,nContIni, 'F569')

Return


Function FSA008IReg(aGrupoReg,nContIni, cReg)

Local nPos	:= 0

aAdd(aGrupoReg, {})
nPos := Len(aGrupoReg)
aAdd (aGrupoReg[nPos], cReg)
aAdd (aGrupoReg[nPos], nContIni)


Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ProcContab()
@description Função que irá tratar as informações do contador do contribuinte,
			   através do pergunte FSA004. Irá armazenar o resultado em um array
			   para não misturar as informações do pergunte FSA001 e FSA004
@return	   aFsa004,Integer,Array Array com informações do contabilista.
@author Erick G. Dias
@since 19/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function ProcContab()

	Local aFsa001	:= {}
	Local aFsa004	:= {}

	//Guarda pergunte inicial da rotina
	aAdd(aFsa001,mv_par01)
	aAdd(aFsa001,mv_par02)
	aAdd(aFsa001,mv_par03)
	aAdd(aFsa001,mv_par04)
	aAdd(aFsa001,mv_par05)
	aAdd(aFsa001,mv_par06)
	aAdd(aFsa001,mv_par07)
	aAdd(aFsa001,mv_par08)
	aAdd(aFsa001,mv_par09)
	aAdd(aFsa001,mv_par10)
	aAdd(aFsa001,mv_par11)
	aAdd(aFsa001,mv_par12)
	aAdd(aFsa001,mv_par13)
	aAdd(aFsa001,mv_par14)
	aAdd(aFsa001,mv_par15)
	aAdd(aFsa001,mv_par16)
	aAdd(aFsa001,mv_par17)
	aAdd(aFsa001,mv_par18)
	aAdd(aFsa001,mv_par19)
	aAdd(aFsa001,mv_par20)
	aAdd(aFsa001,mv_par21)
	aAdd(aFsa001,mv_par22)

	//Chama perguntas do contabilista e armazena em aFsa004
	If pergunte('FSA004',.T.,'Parâmetros do Contabilista')

		aAdd(aFsa004,mv_par01)
		aAdd(aFsa004,mv_par02)
		aAdd(aFsa004,mv_par03)
		aAdd(aFsa004,mv_par04)
		aAdd(aFsa004,mv_par05)
		aAdd(aFsa004,mv_par06)
		aAdd(aFsa004,mv_par07)
		aAdd(aFsa004,mv_par08)
		aAdd(aFsa004,mv_par09)
		aAdd(aFsa004,mv_par10)
		aAdd(aFsa004,mv_par11)
		aAdd(aFsa004,mv_par12)
		aAdd(aFsa004,mv_par13)
	Else
		aAdd(aFsa004,'')
		aAdd(aFsa004,'')
		aAdd(aFsa004,'')
		aAdd(aFsa004,'')
		aAdd(aFsa004,'')
		aAdd(aFsa004,'')
		aAdd(aFsa004,'')
		aAdd(aFsa004,'')
		aAdd(aFsa004,'')
		aAdd(aFsa004,'')
		aAdd(aFsa004,'')
		aAdd(aFsa004,'')
		aAdd(aFsa004,'')
	EndIF

	//Restaura as informações da pergunta inicial.
	mv_par01	:= aFsa001[1]
	mv_par02	:= aFsa001[2]
	mv_par03	:= aFsa001[3]
	mv_par04	:= aFsa001[4]
	mv_par05	:= aFsa001[5]
	mv_par06	:= aFsa001[6]
	mv_par07	:= aFsa001[7]
	mv_par08	:= aFsa001[8]
	mv_par09	:= aFsa001[9]
	mv_par10	:= aFsa001[10]
	mv_par11	:= aFsa001[11]
	mv_par12	:= aFsa001[12]
	mv_par13	:= aFsa001[13]
	mv_par14	:= aFsa001[14]
	mv_par15	:= aFsa001[15]
	mv_par16	:= aFsa001[16]
	mv_par17	:= aFsa001[17]
	mv_par18	:= aFsa001[18]
	mv_par19	:= aFsa001[19]
	mv_par20	:= aFsa001[20]
	mv_par21	:= aFsa001[21]
	mv_par22    := aFsa001[22]

Return aFsa004

//-------------------------------------------------------------------
/*/{Protheus.doc} ContReg()
@description Função que irá verificar na tabela temporária os registros gerados
			   para que sejam contados, e gerados no bloco 9
@return	   aFsa004,Integer,Array Array com informações do contabilista.
@author Erick G. Dias
@since 19/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function ContReg(oTabela)

	Local cAliasTRB		:= oTabela:GetAlias()
	Local aQtdReg		:= {}
	Local aQtdBloco		:= {}
	Local cBloco		:= ''
	Local cCont0		:= 0
	Local cCont1		:= 0
	Local cContA		:= 0
	Local cContC		:= 0
	Local cContD		:= 0
	Local cContF		:= 0
	Local cContI		:= 0
	Local cContM		:= 0
	Local cContP		:= 0

	(cAliasTRB)->(DBSetOrder(1))
	(cAliasTRB)->(DbGoTop ())

	//Percorre arquivo temporário
	Do While !(cAliasTRB)->(Eof ())
		//Verifica se o registro já existe em aQtdREg, se não irá incluir, caso contrário irá incrementar contador
		If (nPos := aScan (aQtdREg, {|aX| aX[1]==(cAliasTRB)->REGISTRO}))==0
			aAdd (aQtdREg, {(cAliasTRB)->REGISTRO,1})
		Else
			aQtdREg[nPos][2] += 1
		EndIf

		cBloco	:= Left((cAliasTRB)->REGISTRO,1)

		//Abaixo verifica de qual bloco registro pertence, para incrementar contador do bloco
		Do Case
		Case cBloco == '0'
			cCont0 ++

		Case cBloco == '1'
			cCont1 ++

		Case cBloco == 'A'
			cContA ++

		Case cBloco == 'C'
			cContC ++

		Case cBloco == 'D'
			cContD ++

		Case cBloco == 'F'
			cContF ++

		Case cBloco == 'I'
			cContI ++

		Case cBloco == 'M'
			cContM ++

		Case cBloco == 'P'
			cContP ++

		EndCAse

		(cAliasTRB)->(DbSkip ())
	EndDo

	//Adiciona no aQtdBloco o total de contadores por bloco
	aAdd(aQtdBloco,AllTrim(Str(cCont0)))
	aAdd(aQtdBloco,AllTrim(Str(cCont1)))
	aAdd(aQtdBloco,AllTrim(Str(cContA)))
	aAdd(aQtdBloco,AllTrim(Str(cContC)))
	aAdd(aQtdBloco,AllTrim(Str(cContD)))
	aAdd(aQtdBloco,AllTrim(Str(cContF)))
	aAdd(aQtdBloco,AllTrim(Str(cContI)))
	aAdd(aQtdBloco,AllTrim(Str(cContM)))
	aAdd(aQtdBloco,AllTrim(Str(cContP)))

//Retorna array com contadores de registros, e também array do contador de bloco.
Return {aQtdReg,aQtdBloco}

//-------------------------------------------------------------------
/*/{Protheus.doc} Reg0000()
@description Função para geração do primeiro registro de abertura do arquivo
@param			dDataDe,Date,Data inicial da geração do arquivo
@param			dDataAte,Date,Data final da geração do arquvo
@param			aNumeracao,Array,Array Contador do registro
@param			oTabela,Object,Objeto da classe	 ARRAYTOTMP
@author Erick G. Dias
@since 27/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function Reg0000(dDataDe,dDataAte,aNumeracao,oBloco0,oTabela)

	Local aPAr			:= {}
	Local cVersao		:= ''
	Local cCodMun		:= ''
	Local cTpEscrti		:= ''
	Local cSitEsp		:= ''

	//Verificação para obter o número de versão do layout
	If dDataDe >= CTOD("01/01/2020")
		cVersao:= "006"
	ElseIf dDataDe >= CTOD("01/01/2019")
		cVersao:= "005"
	ElseIf dDataDe >= CTOD("01/06/2018")
		cVersao:= "004"
	ElseIf dDataDe >= CTOD("01/07/2012")
		cVersao:= "003"
	Else
		cVersao:= "002"
	Endif

	//Verificação para obter o código de município
	If (Upper(SM0->M0_ESTENT)) == 'EX'
	//Exterior irá gerar código do município em branco
		cCodMun	:= ''
	ElseIF Len(Alltrim(SM0->M0_CODMUN))<=5
	//Se o código estiver com tamanho 5 ou menoe, ele está incompleto, entao irá chamar função UfCodIBGE
		cCodMun	:= UfCodIBGE(SM0->M0_ESTENT) + SM0->M0_CODMUN
	Else
	//Caso contrário o código está completo no sigamat, basta utilizar
		cCodMun	:= SM0->M0_CODMUN
	EndIF

	//Tipo de escrituração
	If mv_par09 == 1
		cTpEscrti	:= '0'
	ElseIF mv_par09 == 2
		cTpEscrti	:= '1'
	EndIF

	//Situação Especial
	cSitEsp	:= mv_par10

	//Preenche parâmetro
	aAdd(aPar,cVersao)							//VERSAO
	aAdd(aPar,cTpEscrti)						//TIPO_ESCRIT
	aAdd(aPar,cSitEsp	)						//IND_SIT_ESP
	aAdd(aPar,mv_par13)							//NUM_REC_ANTERIOR
	aAdd(aPar,dDataDe)							//DT_INI
	aAdd(aPar,dDataAte)							//DT_FIM
	aAdd(aPar,SM0->M0_NOMECOM)					//NOME
	aAdd(aPar,SM0->M0_CGC)						//CNPJ
	aAdd(aPar,SM0->M0_ESTENT)					//UF
	aAdd(aPar,cCodMun )							//COD_MUN
	aAdd(aPar,SPEDConvType(SM0->M0_INS_SUF))	//SUFRAMA
	aAdd(aPar,mv_par11)							//IND_NAT_PJ
	aAdd(aPar,mv_par12)							//IND_ATIV

//Passa para classe contador e chama função para gravar Registro 0000
	oBloco0:setaNumer(aNumeracao)
	Proc0000(oBloco0, aPar,oTabela)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Reg0100()
@description Função para geração do registro 0100, informações do contabilista
			   As informações deste registro poderão ser geradas através das
			   informações da pergunta da rotina ou através da tabela CVB.
			   Para buscar informações da CVB, preencher somente CNPJ ou CPF nas
			   perguntas iniciais, caso contrário preencher todas as perguntas
			   para não buscar da CVB.
@param			cChave0000,String,Data inicial da geração do arquivo
@param			aMvPar004,Array,Array com informações da pergunta FSA004
@param			aNumeracao,Array,Array Contador do registro
@param			oBloco0,Objeto,Objeto da classe EFDBLOCO0
@param			oTabela,Object,Objeto da classe	 ARRAYTOTMP
@author Erick G. Dias
@since 27/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function Reg0100(cChave0000,aMvPar004,aNumeracao,oBloco0,oTabela)

	Local aPar		:= {}
	Local lCvb		:= .F.
	Local cEnd		:= ''
	Local cNum		:= ''
	local cCodNum	:= ''

	//Se o nome e endereço não foram preenchidos nas perguntas, irá tentar buscar o contabilista na tabela CVB
	IF Empty(aMvPar004[1]) .AND. Empty(aMvPar004[7])

		//Verifica se o CPF está preenchido na pergunta
		IF !EmpTy(aMvPar004[3])
			DbSelectArea ("CVB") //Tabela Contabilista
			CVB->(DbSetOrder(3)) //Indice por CPF
			If CVB->(MsSeek(xFilial("CVB")+aMvPar004[3]))
				lCvb	:= .T.
			Endif
		//Verifica se o CNPj foi preenchido nas perguntas
		ElseIF !Empty(aMvPar004[2])
			DbSelectArea ("CVB") //Tabela Contabilista
			CVB->(DbSetOrder(2)) //Indice por CGC
			If CVB->(MsSeek(xFilial("CVB")+aMvPar004[2]))
				lCvb	:= .T.
			Endif
		Else
			// senao pego o primeiro contabilista informado para a filial corrente.
			DbSelectArea ("CVB") //Tabela Contabilista
			CVB->(DbSetOrder(1)) //Indice por Codigo
			If CVB->(MsSeek(xFilial("CVB")))
				lCvb	:= .T.
			Endif
		EndIF

	EndIF

	IF lCvb
		//Busca endereço do contabilista
		cEnd	:= FisGetEnd(CVB->CVB_END,CVB->CVB_UF)[1]

		//Busca o número do endereço
		IF !Empty(FisGetEnd(CVB->CVB_END,CVB->CVB_UF)[2])
			cNum	:= FisGetEnd(CVB->CVB_END,CVB->CVB_UF)[3]
		Else
			cNum	:= 'SN'
		EndIF

		//Verifica o código de município
		IF Len(Alltrim(CVB->CVB_CODMUN)) <= 5
			cCodNum	:= UfCodIBGE(CVB->CVB_UF) + Alltrim(CVB->CVB_CODMUN)
		Else
			cCodNum	:= Alltrim(CVB->CVB_CODMUN)
		EndIF

		aAdd(aPar,CVB->CVB_NOME)						//NOME
		aAdd(aPar,SPEDConvType(CVB->CVB_CPF))		//CPF
		aAdd(aPar,SPEDConvType(CVB->CVB_CRC))		//CRC
		aAdd(aPar,SPEDConvType(CVB->CVB_CGC))		///CNPJ
		aAdd(aPar,SPEDConvType(CVB->CVB_CEP))		//CEP
		aAdd(aPar,SPEDConvType(cEnd))				//END
		aAdd(aPar,cNum)								//NUM
		aAdd(aPar,SPEDConvType(CVB->CVB_COMPL))	//COMPL
		aAdd(aPar,SPEDConvType(CVB->CVB_BAIRRO))	//BAIRRO
		aAdd(aPar,SPEDConvType(CVB->CVB_TEL))		//FONE
		aAdd(aPar,SPEDConvType(CVB->CVB_FAX))		//FAX
		aAdd(aPar,CVB->CVB_EMAIL)					//EMAIL
		aAdd(aPar,cCodNum)							//COD_MUN

	Else

		aAdd(aPar,aMvPar004[1])	//NOME
		aAdd(aPar,aMvPar004[3])	//CPF
		aAdd(aPar,aMvPar004[4])	//CRC
		aAdd(aPar,aMvPar004[2])	///CNPJ
		aAdd(aPar,aMvPar004[5])	//CEP
		aAdd(aPar,aMvPar004[7])	//END
		aAdd(aPar,aMvPar004[8])	//NUM
		aAdd(aPar,aMvPar004[9])	//COMPL
		aAdd(aPar,aMvPar004[10])	//BAIRRO
		aAdd(aPar,aMvPar004[11])	//FONE
		aAdd(aPar,aMvPar004[12])	//FAX
		aAdd(aPar,aMvPar004[13])	//EMAIL
		aAdd(aPar,aMvPar004[6])	//COD_MUN

	EndIF

	//Processa registro 0100
	oBloco0:setaNumer(aNumeracao)
	Proc0100(cChave0000,oBloco0, aPar,oTabela)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Reg0110()
@description Função para gerar registro 0110
@param			dDataDe,Date,Data inicial da geração do arquivo
@param			cChave0000,String,Chave do registro pai
@param			aNumeracao,Array,Array Contador do registro
@param			oBloco0,Objeto,Objeto da classe EFDBLOCO0
@param			oTabela,Object,Objeto da classe	 ARRAYTOTMP
@author Erick G. Dias
@since 27/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function Reg0110(dDataDe,dDataAte,cChave0000,aNumeracao,oBloco0,oTabela,lBlocACDF,lBlocoI,nTipRegime,nCodTipCont,nIndRegCum,lReg0900)

	Local lIndAprop := aParSX6[MV_RATPROP]
	Local cRegCum	:= ''
	Local cIndAprop	:= ''
	Local aPar		:={}

	Default nTipRegime	:= mv_par08
	Default nCodTipCont	:= mv_par15
	Default nIndRegCum	:= mv_par16
	Default lReg0900	:= .F.

	//Se for diferente de Exclusivamente Cumulativo, irá considerar o parâmetro MV_RATPROP para definir
	//se será método de apropriação direta ou rateio proporcional.
	IF nTipRegime <> 2
		cIndAprop	:=Iif(lIndAprop,"1", "2")
	EndIF

	//Irá prencher detalhamento do regime Cumulativo se for posterior a 07/2012 e regime exclusivamente cumulativo
	IF dDataDe >= CTOD("01/07/2012") .AND. nTipRegime == 2
		If mv_par16 == 3
			cRegCum	:= '9'
		Else
			cRegCum	:= Str(nIndRegCum,1)
		EndIF
	EndIF

	If lBlocoI
		cRegCum	:= ''
	EndIF

	aAdd(aPar,Str(nTipRegime,1))	//COD_INC_TRIB
	aAdd(aPar,cIndAprop)			//IND_APRO_CRED
	aAdd(aPar,Str(nCodTipCont,1))	//COD_TIPO_CONT
	aAdd(aPar,cRegCum)				//IND_REG_CUM

	//Processa registro 0100
	oBloco0:setaNumer(aNumeracao)
	Proc0110(cChave0000,oBloco0, aPar,oTabela)

	IF lBlocACDF
	//Se não for apropriação direta, deverá gerar registro 0111.
	//Se for regime exclusivamente cumulativo também o registro 0111 não deverá ser gerado.
		IF !lIndAprop .AND. !nTipRegime == 2
			Reg0111(dDataDe,dDataAte,oBloco0:getGrupo(),oTabela,oBloco0,nTipRegime)
		EndIF
	EndIF

	//Geração do registro 0900
	If lReg0900
		Proc0900(dDataDe, dDataAte, oTabela, oBloco0, (nTipRegime == 2 .AND. mv_par16 <> 3))
	EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Reg0111()
@description Função para gerar registro 0111
@param			dDataDe,Date,Data inicial da geração do arquivo
@param			dDataAte,Date,Data Final da geração do arquivo
@param			cChave0000,String,Chave do registro pai
@param			oTabela,Object,Objeto da classe	 ARRAYTOTMP
@param			oBloco0,Objeto,Objeto da classe EFDBLOCO0
@author Erick G. Dias
@since 27/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function Reg0111(dDataDe,dDataAte,cChave0110,oTabela,oBloco0,mv_par08)

	Proc0111(dDataDe, dDataAte, cChave0110,oTabela,oBloco0,mv_par08)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Reg0140()
@description Função para gerar registro 0140, cadastro do estabelecimentyo
@param			oBloco0,Objeto,Objeto da classe EFDBLOCO0
@param			aNumeracao,Array,Array Contador do registro
@author Erick G. Dias
@since 27/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function Reg0140(oBloco0,aNumeracao)
	Local 	aPar	:= {}
	Local cNome		:= ''
	local  cPto		:= "."
	Local  cTco		:= "-"
	Local  cINSC	:= SM0->M0_INSC
	Local  nPos1	:= AT(cPto,cINSC)
	Local  nPos2	:= AT(cTco,cINSC)
	Local  cIe		:= 	''

//Tratamento para obter a inscrição Estadual
	While (nPos1 >0 .Or. nPos2 >0)
		nPos1 := AT(cPto,cINSC)
		Iif(!(nPos1 := AT(cPto,cINSC))>0,cINSC,cINSC := Stuff(cINSC,nPos1,1,""))
		nPos2 := AT(cTco,cINSC)
		Iif(!(nPos2 := AT(cTco,cINSC))>0,cINSC,cINSC := Stuff(cINSC,nPos2,1,""))
	Enddo

	IF Substr(SM0->M0_INSC,1,5) <> 'ISENT'
		cIe	:= cINSC
	EndIF

	cNome	:= SM0->M0_NOMECOM
//Verifica se existe ponto de entrada para tratar o nome do estabelecimento
	IF aParPE[SPDPC0140]
		cNome	:= ExecBlock("SPDPC0140", .F., .F., {"SM0"})
	EndIF

	aAdd(aPar,Alltrim(SM0->M0_CODFIL))	//COD_EST
	aAdd(aPar,cNome)						//NOME
	aAdd(aPar,SM0->M0_CGC)				//CNPJ
	aAdd(aPar,SM0->M0_ESTENT) 			//UF
	aAdd(aPar,cIe)						//IE
	aAdd(aPar,SM0->M0_CODMUN)			//COD_MUN
	aAdd(aPar,SM0->M0_INSCM)				//IM
	aAdd(aPar,SM0->M0_INS_SUF)			//SUFRAMA

	oBloco0:setaNumer(@aNumeracao)
//Chama processamento do registro 0140
	Proc0140('',oBloco0, aPar)

Return


Static Function GrvRegAcum(oBloco0, oTabela)

	oTabela:GrvReg(oBloco0:get0140())


Return
//-------------------------------------------------------------------
/*/{Protheus.doc} BlocoF()
@description Função que irá processar as informações do bloco F, buscar e
			   processar estas informações para passar para os objetos
			   respectivos do bloco F.
@author Erick G. Dias
@since 19/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function BlocoF(aNumeracao,oTabela,oBlocoF,oBloco1,oBloco0,lConcFil,dDataDe,dDataAte,c0140,lBlocACDF,lRgCaxCons,lGrBlocoM,lRgCmpCons,cNrLivro,nTipRegime,aVarGlobais)

	Local aRetImob	:= {}
	Local cGrpPaiF	:= ''	

	Default aVarGlobais := {}
	Default nTipRegime	:=	mv_par08

	cGrpPaiF	:= RegF010(oBlocoF,oTabela,aNumeracao)
	oBlocoF:setaNumer(@aNumeracao)
	oBloco1:setaNumer(@aNumeracao)

	If Empty(GetGlbValue(cGrpPaiF)) .And. !EmpTy(cGrpPaiF)
		PutGlbValue( cGrpPaiF, ".T." )
		Aadd(aVarGlobais,cGrpPaiF) 
	Endif

	If lBlocACDF .OR. lRgCmpCons
	//-------------------------------------------------------------------
	//Processa função para gerar registro F100/ F120 e F130
	//-------------------------------------------------------------------
		ProcCL2(dDataDe, dDataAte,cGrpPaiF,oTabela,aNumeracao,oBloco1,oBloco0,lConcFil,c0140,lRgCmpCons,oBlocoF,aParSX3[FP_CL2_ALIAS],aParSX3[FP_CL2_CLIFOR],aParSX3[FP_CL2_LOJA] )
		oBlocoF:setaNumer(@aNumeracao)

		IF nTipRegime <> 2
			oBlocoF:setaNumer(@aNumeracao)
			RegF150(cGrpPaiF,dDataDe,dDataAte,oBlocoF,oTabela,oBloco0,lConcFil)
		EndIF

	EndIF

	oBlocoF:setaNumer(@aNumeracao)

	If lRgCaxCons

		//-------------------------------------------------------------------
		//Processa informações da tabela CL1 para gerar F500/F510
		//-------------------------------------------------------------------
		ProcCL1(dDataDe, dDataAte, cGrpPaiF,oTabela,aNumeracao,oBloco0,lConcFil,oBloco1)
		oBlocoF:setaNumer(@aNumeracao)
		//-------------------------------------------------------------------
		//Processa informações da tabela CL7 para gerar F525
		//-------------------------------------------------------------------
		ProcCL7(dDataDe, dDataAte, cGrpPaiF,oTabela,aNumeracao,oBloco0,lConcFil)
		oBlocoF:setaNumer(@aNumeracao)

		oBloco1:setaNumer(@aNumeracao)
		//Realiza processamento para geração do registro 1900
		Reg1900(dDataDe,dDataAte,cNrLivro,oBloco0,oTabela,lConcFil,oBloco1)

	EndIF


	//-------------------------------------------------------------------
	//Processa informações do registro F200, informações do ramo Imobiliário.
	//-------------------------------------------------------------------
	If aParPE[SPDPCIMOB]
		aRetImob := ExecBlock("SPDPCIMOB",.F.,.F.,{{},dDataDe,dDataAte})

		If Len(aRetImob)>0 .And. ValType(aRetImob[1]) == "A"
			ProcF200(cGrpPaiF, oBlocoF, oTabela, aRetImob)			
			PutGlbValue( cGrpPaiF, ".F." )
		EndIF

	EndIF

	IF lGrBlocoM

	//-------------------------------------------------------------------
	//Processa informações da tabela CKY para gerar F600
	//-------------------------------------------------------------------
		ProcCKY(dDataDe, dDataAte, cGrpPaiF,oTabela,aNumeracao)

	//-------------------------------------------------------------------
	//Processa informações de outras deduções da tabela CF2 no registro F700
	//-------------------------------------------------------------------
		RegF700(dDataDe, oBlocoF, oTabela, cGrpPaiF , nTipRegime)
		If AliasINdic('F0X')
			RegF800(dDataDe, oBlocoF, oTabela,cGrpPaiF)
		EndIf
	EndIF

	/*IF GetGlbValue("GeraF010") == 'T'
		oBlocoF:LimpaX010(cGrpPaiF)
	Endif*/	
	If GetGlbValue(cGrpPaiF) == '.T.'		
		oBlocoF:LimpaX010(cGrpPaiF)
	Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BlocoM()
@description Função que irá processar as informações do bloco M, buscar e
			   processar estas informações para passar para os objetos
			   respectivos do bloco M.
@author Erick G. Dias
@since 19/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function BlocoM(aNumeracao,oTabela,oBloco0,lConcFil,aSM0,dDataDe,dDataAte,nTipRegime,cIndNatPJ)

	Local cGrpPaiM		:= FSA008SReg(@aNumeracao,'', 'M010')
	Local lConsol		:= .F.
	Local lDetAju		:= .F.
	Local dAjuBase		:= CTOD("01/01/2019")
	Local lAjuBase		:= .F.
	Local lCmpAjuBC		:= .F.

	Default dDataDe		:= mv_par01
	Default dDataAte 		:= mv_par02
	Default nTipRegime	:= mv_par08

	lAjuBase		:= !EmptY(dAjuBase) .AND. dDataDe >= dAjuBase
	lCmpAjuBC		:= aParSX3[FP_CKS_AJBCA] .AND. aParSX3[FP_CKS_AJBCR] .AND. aParSX3[FP_CKS_BCAJUS]

	lConsol	:= FS007ApCon(dDataDe)
	lDetAju	:= aParSX3[FP_CL4_IDCLA] .AND. dDataDe >= CTOD("01/10/2015") //Indica que poderá processar detalhamento do ajuste.

	//-------------------------------------------------------------------
	//Processa família dos registros M200 e M600
	//-------------------------------------------------------------------
	PrcM200600(dDataDe,dDataAte,cGrpPaiM,oTabela,@aNumeracao,oBloco0,lConcFil,lConsol,aSM0,lDetAju,cIndNatPJ,lAjuBase, lCmpAjuBC)

	IF nTipRegime <> 2
		//-------------------------------------------------------------------
		//Processa família dos registros M100 e M500
		//-------------------------------------------------------------------
		PrcM100500(dDataDe,dDataAte,cGrpPaiM,oTabela,@aNumeracao,oBloco0,oTabela,lConcFil,lConsol,lDetAju)
	EndIF
	//-------------------------------------------------------------------
	//Processa família dos registros M400 e M800
	//-------------------------------------------------------------------
	PrcM400800(dDataDe,dDataAte,cGrpPaiM,oTabela,@aNumeracao,oBloco0,lConcFil,lConsol)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BlocoP()
@description Função que irá processar as informações do bloco P, buscar e
			   processar estas informações para passar para os objetos
			   respectivos do bloco P.
@author Erick G. Dias
@since 24/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function BlocoP(aNumeracao,oTabela,lP200,oBloco0,lConcFil,c0140,c0140Pri,oBlocoP,dDataDe,dDataAte)

	Local cGrpPaiP		:= ''
	Local cPaiP200		:= ''
	Local nPos			:= 0
	Local aP010			:= {}

	Default dDataDe		:= mv_par01
	Default dDataAte 	:= mv_par02
	Default oBlocoP		:= EFDCBLOCOP():New()

	//Função que verifica se haverá ao menos um registro P100 para ser processado, caso houver
	//ir[a processar P010, caso contrário não terá P010
	IF ProcP100(dDataDe, dDataAte, cGrpPaiP,oTabela,@aNumeracao,oBloco0,lConcFil,.T.,oBlocoP) >0
		aP010 := oBlocoP:getP010()

		nPos := aScan (aP010, {|aX|  AllTrim(aX[3])==AllTrim(SM0->M0_CGC)})

		If nPos == 0
			cGrpPaiP		:= FSA008SReg(@aNumeracao,'', 'P010')
			PrcIdEstab(cGrpPaiP, oBlocoP, oTabela,  'P010', SM0->M0_CGC, '', '')
		Else
			cGrpPaiP	:= aP010[nPos][1]
		Endif

		ProcP100(dDataDe, dDataAte, cGrpPaiP,oTabela,@aNumeracao,oBloco0,lConcFil,.F.,oBlocoP)

	EndIF

	//O registro P200 deverá ser gerado a nível de empresa e não de filial, por este
	//motivo será processado somente quando a matriz for processada, uma vez que
	//as informações já foram consolidadas na apuração.
	If lP200
		cPaiP200	:= FSA008SReg(@aNumeracao,'', 'P200')
		ProcP200(dDataDe, dDataAte, cPaiP200,oTabela,@aNumeracao,oBloco0,c0140Pri,oBlocoP)
	EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BlocoI()
@description Função que irá processar as informações do bloco I, buscar e
			   processar estas informações para passar para os objetos
			   respectivos do bloco I.
@author Erick G. Dias
@since 24/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function BlocoI(aNumeracao,oTabela,oBloco0,oTabela,lConcFil,oBloco1,dDataDe,dDataAte)

	Local cGrpPaiI		:= FSA008SReg(@aNumeracao,'', 'I010')
	Local oBlocoI		:= EFDCBLOCOI():New()

	Default dDataDe		:= mv_par01
	Default dDataAte 	:= mv_par02

	PrcIdEstab(cGrpPaiI, oBlocoI, oTabela,  'I010', SM0->M0_CGC, mv_par17, '')

	ProcBlcI(dDataDe, dDataAte, cGrpPaiI,oTabela,@aNumeracao,oBloco0,oTabela,lConcFil,oBloco1)

	//Grava registros A010 depois de processar todas as filiais.
	oTabela:GrvReg(oBlocoI:getI010())

	FreeObj(oBlocoI)
	oBlocoI:= nil

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} RegA010()
@description Função para controle da abertura do bloco A
@author Erick G. Dias
@since 03/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function RegA010(oBlocoA,oTabela,aNumeracao)

	Local cGrpPaiA	:= ''
	Local aA010		:= oBlocoA:getA010()
	Local nPos			:= 0

	nPos := aScan (aA010, {|aX|  AllTrim(aX[3])==AllTrim(SM0->M0_CGC)})

	IF nPos == 0
		//Adiciona
		cGrpPaiA	:= FSA008SReg(@aNumeracao,'', 'A010')

		PrcIdEstab(cGrpPaiA, oBlocoA, oTabela,  'A010', SM0->M0_CGC, '', '')
	Else
		//Utiliza Grupo do A010 já criado
		cGrpPaiA	:= aA010[nPos][1]
	EndIF

Return cGrpPaiA

//-------------------------------------------------------------------
/*/{Protheus.doc} RegC010()
@description Função para controle da abertura do bloco C
@author Erick G. Dias
@since 03/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function RegC010(oBlocoC,oTabela,aNumeracao,cIndDesri)

	Local cGrpPaiC	:= ''
	Local aC010		:= oBlocoC:getC010()
	Local nPos		:= 0

	nPos := aScan (aC010, {|aX|  AllTrim(aX[3])==AllTrim(SM0->M0_CGC)})

	IF nPos == 0
	//Adiciona
		cGrpPaiC	:= FSA008SReg(@aNumeracao,'', 'C010')

		PrcIdEstab(cGrpPaiC, oBlocoC, oTabela,  'C010', SM0->M0_CGC, cIndDesri, '')
	Else
	//Utiliza Grupo do C010 já criado
		cGrpPaiC	:= aC010[nPos][1]
	EndIF

Return cGrpPaiC

//-------------------------------------------------------------------
/*/{Protheus.doc} RegD010()
@description Função para controle da abertura do bloco D
@author Erick G. Dias
@since 03/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------

Static Function RegD010(oBlocoD,oTabela,aNumeracao)

	Local cGrpPaiD	:= ''
	Local aD010		:= oBlocoD:getD010()
	Local nPos			:= 0

	nPos := aScan (aD010, {|aX|  AllTrim(aX[3])==AllTrim(SM0->M0_CGC)})

	IF nPos == 0
	//Adiciona
		cGrpPaiD	:= FSA008SReg(@aNumeracao,'', 'D010')

		PrcIdEstab(cGrpPaiD, oBlocoD, oTabela,  'D010', SM0->M0_CGC, '', '')
	Else
	//Utiliza Grupo do D010 já criado
		cGrpPaiD	:= aD010[nPos][1]
	EndIF

Return cGrpPaiD

//-------------------------------------------------------------------
/*/{Protheus.doc} RegF010()
@description Função para controle da abertura do bloco A
@author Erick G. Dias
@since 03/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function RegF010(oBlocoF,oTabela,aNumeracao)

	Local cGrpPaiF	:= ''
	Local aF010		:= oBlocoF:getF010()
	Local nPos			:= 0

	nPos := aScan (aF010, {|aX|  AllTrim(aX[3])==AllTrim(SM0->M0_CGC)})

	IF nPos == 0
	//Adiciona
		cGrpPaiF	:= FSA008SReg(@aNumeracao,'', 'F010')

		PrcIdEstab(cGrpPaiF, oBlocoF, oTabela,  'F010', SM0->M0_CGC, '', '')
	Else
	//Utiliza Grupo do F010 já criado
		cGrpPaiF	:= aF010[nPos][1]
	EndIF

Return cGrpPaiF

//-------------------------------------------------------------------
/*/{Protheus.doc} BuscaCDG()
@description Função para buscar informações da tabela CDG e gerar registros de
			   processo referenciado
@author Erick G. Dias
@since 03/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function BuscaCDG(cChavePai, aPar, oBloco, oBloco1, cReg, cRegOri, lProcTabCIE, dPerApur, cItem, cProd, cConta, cCusto, cPart, cChaveNfe)

Local 	cChave		:= ""
Local   cChaveCIE	:= ""
Local   cChaveCCF	:= ""
Local   cChave1010 	:= ""

Default lProcTabCIE	:= .F.
Default dPerApur	:= cTOd('  /  /    ')
Default cRegOri		:= "    "
Default cItem		:= ""
Default cProd		:= ""
Default cConta		:= ""
Default cCusto		:= ""
Default cPart		:= ""
Default cChaveNfe	:= ""



CDG->(DbSetOrder (3))

//Posiciona a CDG do item da SFT processado
IF CDG->(MsSeek (xFilial ("CDG")+aPar[1]+aPar[2]+aPar[3]+aPar[4]+aPar[5]+cItem))

	//Monta chave para processar somente os lançamentos da CDG deste item
	cChave := xFilial ("CDG")+aPar[1]+aPar[2]+aPar[3]+aPar[4]+aPar[5]+cItem

	//Para o item pode haver mais de um lançamento da CDG, por este motivo o laço abaixo
	Do while !CDG->(Eof()) .And. CDG->CDG_FILIAL+CDG->CDG_TPMOV+CDG->CDG_DOC+CDG->CDG_SERIE+CDG->CDG_CLIFOR+CDG->CDG_LOJA+CDG->CDG_ITEM==cChave

		//Posiciono o processo da CDG
		If CCF->(MsSeek (xFilial ('CCF')+ CDG->CDG_PROCES +CDG->CDG_TPPROC))

			//Monta a chave da CCF para processar somente os processos informados na CDG
			cChaveCCF	:= xFilial ('CCF')+ CDG->CDG_PROCES +CDG->CDG_TPPROC

			Do while !CCF->(Eof()) .AND. CCF->CCF_FILIAL+CCF->CCF_NUMERO+CCF->CCF_TIPO == cChaveCCF

				//Verifico se o item da CCF é igual ao item da CDG
				IF CCF->CCF_IDITEM == CDG->CDG_ITPROC

					If CCF->CCF_TPCOMP == '1' //Complemento do processo referenciado - Judicial
						Proc1010('1001000000001', oBloco1, 'CCF')
						cChave1010	:= oBloco1:getGrupo()

						//Processa informações da exigibilidade suspensa para registro 1011
						If lProcTabCIE .AND. aParSX3[FP_CCF_TRIB] .And. CCF->CCF_TRIB $ "7|8|" .AND. CCF->CCF_NATJU $ "12/13/14/15/16/17/19"

							//CIE_FILIAL+DTOS(CIE_PER)+CIE_DOC+CIE_SERIE+CIE_PART+CIE_LOJA+CIE_ITEM+CIE_PROCES+CIE_TIPOPR+CIE_INDAUT+CIE_IDITEM+CIE_NATJU
							cChaveCIE	:= xFilial("CIE") + dTos(dPerApur) + aPar[2] + aPar[3] + aPar[4] + aPar[5] + cItem + CCF->CCF_NUMERO+CCF->CCF_TIPO+CCF->CCF_INDAUT+CCF->CCF_IDITEM+CCF->CCF_NATJU

							If CIE->(MSSEEK(cChaveCIE))

								//Aqui Busco as informações da CIE para enviar para classe do bloco 1
								oBloco1:setRelac(cChave1010)
								oBloco1:setRegRef(cRegOri)
								oBloco1:setChvNfe(cChaveNfe)
								oBloco1:setCodPart(cPart)
								oBloco1:setCodItem(cProd)
								oBloco1:setEmissao(CIE->CIE_DTOPER)
								oBloco1:setConta(cConta)
								oBloco1:setiCCusto(cCusto)
								oBloco1:setTrib(CCF->CCF_TRIB)
								oBloco1:setiCSTPis(CIE->CIE_CPIS)
								oBloco1:setiCSTCof(CIE->CIE_CCOF)
								oBloco1:setiAlqCof(CIE->CIE_ACOF)
								oBloco1:setiAlqPis(CIE->CIE_APIS)
								oBloco1:setValItem(CIE->CIE_VLOPER)
								oBloco1:setCstPisS(CIE->CIE_CPISSU)
								oBloco1:setCstCofS(CIE->CIE_CCOFSU)
								If CCF->CCF_TRIB == "7"
									//Valores de PIS, já que o processo está com tributo PIS
									oBloco1:setiBasPis(CIE->CIE_BPIS)
									oBloco1:setiValPis(CIE->CIE_VPIS)
									oBloco1:setBasPisS(CIE->CIE_BPISSU)
									oBloco1:setAlqPisS(CIE->CIE_APISSU)
									oBloco1:setValPisS(CIE->CIE_VPISSU)
									oBloco1:setCodRec(CIE->CIE_CODPIS)
								ElseIF CCF->CCF_TRIB == "8"
									//Valores de COFINS, já que o processo está com tributo COFINS
									oBloco1:setiBasCof(CIE->CIE_BCOF)
									oBloco1:setiValCof(CIE->CIE_VCOF)
									oBloco1:setBasCofS(CIE->CIE_BCOFSU)
									oBloco1:setAlqCofS(CIE->CIE_ACOFSU)
									oBloco1:setValCofS(CIE->CIE_VCOFSU)
									oBloco1:setCodRec(CIE->CIE_CODCOF)
								EndIF

								oBloco1:Add1011()

							EndIF

						EndIF

					ElseIf CCF->CCF_TPCOMP == '2' //Complemento do processo referenciado - Administrativo
						Proc1020('1001000000001', oBloco1, 'CCF')
					EndIF

					//Filtro para entrar apenas processos referenciados referente à PIS e COFINS
					If aParSX3[FP_CCF_TRIB] .And.  CCF->CCF_TRIB $ " |5|7|8|"
						ProcRefC(cChavePai, oBloco, cReg, CDG->CDG_PROCES, CDG->CDG_TPPROC)
					EndIf
				EndIF
				CCF->(DbSkip())
			Enddo

		EndIF

		CDG->(DbSkip())
	Enddo

EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcCCYCCW()
@description Função que irá buscar valores das tabelas CCY e CCW para gerar
			   registros de saldos de créditos 1100 e 1500
@author Erick G. Dias
@since 04/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function ProcCCYCCW (oBloco1, dDataDe, cTrib)

	Local cFiltro	:= ''
	Local cCampos	:= ''
	Local cAliasQry	:= ''
	Local cPeriodo	:= ''
	Local cFrom	:= ''
	Local cDtAnt	:= firstday(dDataDe)
	Local lConsol	:= FS007ApCon(dDataDe)

	cPeriodo 	:= cvaltochar(strzero(month(cDtAnt),2)) + cvaltochar(year(cDtAnt ))

	If cTrib == PIS

		cCampos +=	 "CCY.CCY_PERIOD, CCY.CCY_COD, 		CCY.CCY_TOTCRD,	CCY.CCY_CREDUT, 	CCY.CCY_CRDISP, "
		cCampos += "CCY.CCY_UTIANT,	CCY.CCY_ANO,		CCY.CCY_MES,		CCY.CCY_CNPJ,		CCY.CCY_ORICRE, "
		cCampos += "CCY.CCY_REANTE, CCY.CCY_COANTE, 	CCY.CCY_RESSA ,	CCY.CCY_COMP, 	CCY.CCY_LEXTEM "

		cFrom	   +=  RetSqlName('CCY')+' CCY '

		cFiltro	+= "CCY.CCY_FILIAL = '" + xFilial("CCY") + "' AND CCY.CCY_PERIOD =   '" + cPeriodo +  "' AND "
		//Os saldos com ressarcimento ou compensação total também precisam ser listados no registro 1100
		cFiltro	+= "(CCY.CCY_TOTCRD > 0 OR CCY.CCY_CREDUT > 0 OR CCY.CCY_COMP > 0 OR CCY.CCY_RESSA > 0 OR CCY.CCY_COANTE > 0  OR CCY.CCY_REANTE > 0 ) AND CCY.D_E_L_E_T_=' '"
		IF lConsol
	       cFiltro 	+= " AND  CCY.CCY_CONSOL = '1' "
	    Else
	       cFiltro 	+= " AND  CCY.CCY_CONSOL = '2' "
	    Endif
		cFiltro    +=" ORDER BY CCY.CCY_PERIOD, CCY.CCY_ANO, CCY.CCY_MES , CCY.CCY_COD"

	ElseIF cTrib == COFINS

		cCampos +=	 "CCW.CCW_PERIOD, CCW.CCW_COD, 		CCW.CCW_TOTCRD,	CCW.CCW_CREDUT, 	CCW.CCW_CRDISP, "
		cCampos += "CCW.CCW_UTIANT,	CCW.CCW_ANO,		CCW.CCW_MES,		CCW.CCW_CNPJ,		CCW.CCW_ORICRE, "
		cCampos += "CCW.CCW_REANTE, CCW.CCW_COANTE, 	CCW.CCW_RESSA ,	CCW.CCW_COMP, 	CCW.CCW_LEXTEM "

		cFrom	   +=  RetSqlName('CCW')+' CCW '

		cFiltro	+= "CCW.CCW_FILIAL = '" + xFilial("CCW") + "' AND CCW.CCW_PERIOD =   '" + cPeriodo +  "' AND "
		//Os saldos com ressarcimento ou compensação total também precisam ser listados no registro 1500
		cFiltro	+= "(CCW.CCW_TOTCRD > 0 OR CCW.CCW_CREDUT > 0 OR CCW.CCW_COMP > 0 OR CCW.CCW_RESSA > 0 OR CCW.CCW_COANTE > 0  OR CCW.CCW_REANTE > 0 ) AND CCW.D_E_L_E_T_=' '"
		IF lConsol
	       cFiltro 	+= " AND CCW.CCW_CONSOL ='1' "
	    Else
	       cFiltro 	+= " AND CCW.CCW_CONSOL ='2' "
	    Endif
		cFiltro    += "ORDER BY CCW.CCW_PERIOD, CCW.CCW_ANO, CCW.CCW_MES , CCW.CCW_COD"

	EndIF

	cFrom	:= '%' + cFrom + '%'
	cFiltro	:= '%' + cFiltro + '%'
	cCampos	:= '%' + cCampos + '%'

	cAliasQry	:=	GetNextAlias()

	BeginSql Alias cAliasQry

		SELECT
		%Exp:cCampos%
		FROM
		%Exp:cFrom%
		WHERE
		%Exp:cFiltro%
	EndSql

	DbSelectArea (cAliasQry)
	(cAliasQry)->(DbGoTop ())
	Do While !(cAliasQry)->(Eof ())
		IF cTrib == PIS
			Proc1100('1001000000001', oBloco1, cAliasQry)
		ElseIF cTrib == COFINS
			Proc1500('1001000000001', oBloco1, cAliasQry)
		EndIF
		(cAliasQry)->(DbSkip ())
	EndDo

	DbSelectArea (cAliasQry)
	(cAliasQry)->(DbCloseArea ())

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcSFVSFW()
@description Função que irá buscar valores das tabelas SFV e SFW para gerar
			   registros de saldos de retenção na fonte 1300 e 1700
@author Erick G. Dias
@since 04/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function ProcSFVSFW (oBloco1, dDataDe, cTrib)

	Local cFiltro	:= ''
	Local cCampos	:= ''
	Local cAliasQry	:= ''
	Local cPeriodo	:= ''
	Local cFrom	:= ''
	Local cDtAnt	:= firstday(dDataDe)
	Local lCmpRetPIS		:= .F.
	Local lCmpRetCOF		:= .F.

	lCmpRetPIS := aParSX3[FP_FV_RESSA] .and. aParSX3[FP_FV_COMP] .and. aParSX3[FP_FV_RESRET]
	lCmpRetCOF := aParSX3[FP_FW_RESSA] .and. aParSX3[FP_FW_COMP] .and. aParSX3[FP_FW_RESRET]

	cPeriodo 	:= cvaltochar(strzero(month(cDtAnt),2)) + cvaltochar(year(cDtAnt ))

	If cTrib == PIS
// incluir novos campos
		If lCmpRetPIS
			cCampos +=	 "SFV.FV_PER, SFV.FV_NATRET, SFV.FV_TOTRET, SFV.FV_VLDISP ,SFV.FV_TPREG ,SFV.FV_MESANO, SFV.FV_RESSA, SFV.FV_COMP, SFV.FV_RESRET "
		Else
			cCampos +=	 "SFV.FV_PER, SFV.FV_NATRET, SFV.FV_TOTRET, SFV.FV_VLDISP ,SFV.FV_TPREG ,SFV.FV_MESANO "
		Endif
		cFrom	   +=  RetSqlName('SFV')+' SFV '
		cFiltro	+= "SFV.FV_FILIAL = '" + xFilial("SFV") + "' AND SFV.FV_PER =   '" + cPeriodo +  "' AND "
		cFiltro	+= "SFV.FV_CONSOL <> ' '  AND SFV.D_E_L_E_T_=' '"


	ElseIF CTrib == COFINS

		If lCmpRetCOF
			cCampos +=	 "SFW.FW_PER, SFW.FW_NATRET, SFW.FW_TOTRET, SFW.FW_VLDISP ,SFW.FW_TPREG ,SFW.FW_MESANO, SFW.FW_RESSA, SFW.FW_COMP, SFW.FW_RESRET " 
		Else
			cCampos +=	 "SFW.FW_PER, SFW.FW_NATRET, SFW.FW_TOTRET, SFW.FW_VLDISP ,SFW.FW_TPREG ,SFW.FW_MESANO "
		Endif
		cFrom	   +=  RetSqlName('SFW')+' SFW '
		cFiltro	+= "SFW.FW_FILIAL = '" + xFilial("SFW") + "' AND SFW.FW_PER =   '" + cPeriodo +  "'  AND "
		cFiltro	+= "SFW.FW_CONSOL <> ' '  AND SFW.D_E_L_E_T_=' '"

	EndIF

	cFrom	:= '%' + cFrom + '%'
	cFiltro	:= '%' + cFiltro + '%'
	cCampos	:= '%' + cCampos + '%'

	cAliasQry	:=	GetNextAlias()

	BeginSql Alias cAliasQry

		SELECT
		%Exp:cCampos%
		FROM
		%Exp:cFrom%
		WHERE
		%Exp:cFiltro%
	EndSql

	DbSelectArea (cAliasQry)
	(cAliasQry)->(DbGoTop ())
	Do While !(cAliasQry)->(Eof ())
		IF cTrib == PIS
			Proc1300('1001000000001', oBloco1, cAliasQry)
		ElseIF cTrib == COFINS
			Proc1700('1001000000001', oBloco1, cAliasQry)
		EndIF
		(cAliasQry)->(DbSkip ())
	EndDo

	DbSelectArea (cAliasQry)
	(cAliasQry)->(DbCloseArea ())

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ProcECF()
@description Função que irá processar as operações de cupom fiscal
@author Erick G. Dias
@since 04/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------

Static Function ProcECF(cNrLivro, cC010, dDataDe, dDataAte, lConsolid, oBlocoC, oBloco1, oBloco0,oTabela,lConcFil,nICMPAD,c0140,lBilhete,oBlocoD,cD010)
	Local cSlctSFT	:= ''
	Local cCmposSB1	:= ''
	Local cAliasSFT	:= ''
	Local cChvPDV		:= ''
	Local cChave		:= ''
	Local aPar			:= {}
	Local cChaveC400	:= ''
	Local cChaveC490	:= ''
	Local cChaveC405	:= ''
	Local cChaveD350    := ''
	Local aParCompl	:= {}
	Local cConta		:= ''
	Local cCodProd	:= ''
	Local cJoin		:= ''
	Local cJoinCDG	:= ''
	Local aProd		:= {}
	Local cDbType  	:= TCGetDB()
	Local cFuncNull	:= ""
	Local cExpIN    := ""
	Local lTabCIE 	:= AliasIndic("CIE") .And. Year(dDataDe) >= 2020
	Local lIntGTP	:= FindFunction('GtpXFis') .And. GtpXFis(dDataDe, dDataAte) 
	DEFAULT lBilhete := .F.
	DEFAULT oBlocoD := NIL
	DEFAULT cD010   := ""

	// Definição da clausula IN do WHERE p/ bilhetes e cupons normais, conforme a chamada da função.
	cExpIN := "%" + IIf(lBilhete, FormatIn('BPR',"|") , FormatIn('CF|ECF',"|")) + "%"

	Do Case // Nome da funcao do banco de dados que substitui NULL por 0
		Case cDbType $ "DB2/POSTGRES"
			cFuncNull	:= "COALESCE"
		Case "ORACLE" $ cDbType
			cFuncNull	:= "NVL"
		Otherwise
			cFuncNull	:= "ISNULL"
	EndCase

	cSlctSFT := "SFT.FT_FILIAL,		SFT.FT_TIPOMOV,		SFT.FT_SERIE,			SFT.FT_NFISCAL,		SFT.FT_CLIEFOR,		"
	cSlctSFT +="SFT.FT_LOJA,			SFT.FT_ITEM,			SFT.FT_PRODUTO,		SFT.FT_ENTRADA,		SFT.FT_NRLIVRO,		"
	cSlctSFT +="SFT.FT_CFOP,			SFT.FT_ESPECIE,		SFT.FT_TIPO,			SFT.FT_EMISSAO,		SFT.FT_DTCANC,		"
	cSlctSFT +="SFT.FT_FORMUL, 		SFT.FT_ALIQPIS,		SFT.FT_VALPIS,		SFT.FT_ALIQCOF,		SFT.FT_VALCOF,		"
	cSlctSFT +="SFT.FT_VALCONT,		SFT.FT_BASEICM,		SFT.FT_VALICM,		SFT.FT_ISSST,	 		SFT.FT_BASERET,		"
	cSlctSFT +="SFT.FT_ICMSRET,		SFT.FT_VALIPI,		SFT.FT_ISENICM,		SFT.FT_QUANT,			SFT.FT_DESCONT,		"
	cSlctSFT +="SFT.FT_TOTAL,		SFT.FT_FRETE,  		SFT.FT_SEGURO,		SFT.FT_DESPESA,		SFT.FT_OUTRICM,		"
	cSlctSFT +="SFT.FT_BASEIPI,		SFT.FT_ISENIPI,		SFT.FT_OUTRIPI,		SFT.FT_ICMSCOM,		SFT.FT_RECISS,		"
	cSlctSFT +="SFT.FT_BASEIRR,		SFT.FT_ALIQICM,		SFT.FT_ALIQIPI,		SFT.FT_CTIPI,			SFT.FT_POSIPI,		"
	cSlctSFT +="SFT.FT_CLASFIS,		SFT.FT_PRCUNIT,		SFT.FT_CFPS,			SFT.FT_ESTADO,		SFT.FT_CODISS,		"
	cSlctSFT +="SFT.FT_ALIQIRR,		SFT.FT_VALIRR,		SFT.FT_BASEINS,		SFT.FT_VALINS,		SFT.FT_PDV,			"
	cSlctSFT +="SFT.FT_ISSSUB,		SFT.FT_CREDST,		SFT.FT_ISENRET,		SFT.FT_OUTRRET,		SFT.FT_CONTA,		"
	cSlctSFT +="SFT.FT_BASEPIS,		SFT.FT_BASECOF,		SFT.FT_VALPS3,		SFT.FT_VALCF3,		SFT.FT_PESO,	    "
	cSlctSFT +="SFT.FT_SOLTRIB,		SFT.FT_CHVNFE, 		SFT.FT_CSTPIS,		SFT.FT_CSTCOF,		SFT.FT_INDNTFR, 	"
	cSlctSFT += "SFT.FT_CODBCC,		SFT.FT_ALIQCF3,  		SFT.FT_VALCF3,		SFT.FT_BASEPS3, 		SFT.FT_ALIQPS3, 	"
	cSlctSFT += "SFT.FT_VALPS3,		SFT.FT_BASECF3,		SFT.FT_TNATREC,		SFT.FT_CNATREC,		SFT.FT_GRUPONC,"
	cSlctSFT += "SFT.FT_PAUTPIS, 	SFT.FT_PAUTCOF,		SFT.FT_DTFIMNT,"
	cSlctSFT += cFuncNull + "( CF4.CF4_VALPIS,0) CF4_VALPIS,"+cFuncNull + "( 	CF4.CF4_VALCOF,0) CF4_VALCOF, "+cFuncNull + "( CF4.CF4_BASPIS,0) CF4_BASPIS, "+cFuncNull + "( CF4.CF4_BASCOF,0) CF4_BASCOF,"


//³CAMPOS DA TABELA SB1 PARA MONTAR A QUERY.³
	cCmposSB1	:=	"SB1.B1_COD,			SB1.B1_DESC,		SB1.B1_VLR_PIS,		SB1.B1_VLR_COF,		SB1.B1_TNATREC,		"
	cCmposSB1	+=  "SB1.B1_CNATREC, 	SB1.B1_GRPNATR, 	SB1.B1_DTFIMNT,		SB1.B1_TIPO,			SB1.B1_CODBAR,		"
	cCmposSB1	+=  "SB1.B1_CODANT, 		SB1.B1_UM, 		SB1.B1_POSIPI,		SB1.B1_EX_NCM,		SB1.B1_CODISS,		"
	cCmposSB1	+=  "SB1.B1_PICM, 		SB1.B1_FECP, 		SB1.B1_DATREF,		SB1.B1_TPREG,			SB1.B1_DATREF,"

//BUSCA CAMPOS DA TABELA cd6 E sb5 PARA GERAÇÃO DOS REGISTROS 0206 E/OU 0208, POIS SERÃO GERADOS QUANDO 0200 FOR GERADO TAMBÉM
	cCmposSB1 += "CD6.CD6_CODANP,"
	cCmposSB1 += "SB5.B5_TABINC, SB5.B5_CODGRU,SB5.B5_MARCA,"

//³CAMPOS DA TABELA SFI E SLG

	cCmposSB1 += "SFI.FI_PDV, 			SFI.FI_DTMOVTO, 	SFI.FI_DESC,  		SFI.FI_SERPDV, 		SFI.FI_VALCON, 		SFI.FI_COO, "
	cCmposSB1 += "SFI.FI_ISS, 			SFI.FI_CRO, 		SFI.FI_NUMREDZ,		SFI.FI_NUMFIM, 		SFI.FI_GTFINAL,					"
	cCmposSB1 += "SFI.FI_CANCEL,		SF4.F4_TPREG, 		SLG.LG_SERPDV, 	    SLG.LG_IMPFISC, 	SLG.LG_PDV"


	cSlctSFT	+=	cCmposSB1
	cSlctSFT  	+= " ,ISNULL(CDG.COUNTCDG,0) COUNTCDG "	

	cSlctSFT	:=	"%"+cSlctSFT+"%"


	cAliasSFT	:=	GetNextAlias()

	cFiltro := "%"
	cCampos := "%"
	If (cNrLivro<>"*")
		cFiltro += " SFT.FT_NRLIVRO = '" +%Exp:cNrLivro% +"' AND "
	EndiF
	cFiltro += "%"
	cCampos += "%"

	cOrderBy  := "%ORDER BY SFI.FI_PDV, SFI.FI_DTMOVTO, SFT.FT_NFISCAL,  SFT.FT_SERIE, SFT.FT_ITEM  %"

	IF aParSX3[FP_CF4_FLORIG]
		cJoin	   +="LEFT JOIN "+RetSqlName("CF4")+" CF4 ON(CF4.CF4_FILIAL='"+xFilial("CF4")+"' AND  CF4.CF4_FLORIG = '" +xFilial("SFT")+ "' AND CF4.CF4_TIPMOV=SFT.FT_TIPOMOV AND CF4.CF4_SERIE=SFT.FT_SERIE AND CF4.CF4_NOTA=SFT.FT_NFISCAL AND CF4.CF4_CLIFOR=SFT.FT_CLIEFOR AND CF4.CF4_LOJA=SFT.FT_LOJA AND CF4.CF4_ITEM=SFT.FT_ITEM AND CF4.CF4_DATAE  = SFT.FT_EMISSAO  AND CF4.CF4_TIPO = 'D' AND CF4.D_E_L_E_T_='') "
	Else
		cJoin	   +="LEFT JOIN "+RetSqlName("CF4")+" CF4 ON(CF4.CF4_FILIAL='"+xFilial("CF4")+"' AND CF4.CF4_TIPMOV=SFT.FT_TIPOMOV AND CF4.CF4_SERIE=SFT.FT_SERIE AND CF4.CF4_NOTA=SFT.FT_NFISCAL AND CF4.CF4_CLIFOR=SFT.FT_CLIEFOR AND CF4.CF4_LOJA=SFT.FT_LOJA AND CF4.CF4_ITEM=SFT.FT_ITEM AND CF4.CF4_DATAE  = SFT.FT_EMISSAO  AND CF4.CF4_TIPO = 'D' AND CF4.D_E_L_E_T_='') "
	EndIF		

		
	//Verifica se existe CGD
	cJoinCDG  	+= " LEFT JOIN (SELECT CDG_FILIAL, CDG_TPMOV, CDG_DOC, CDG_SERIE, CDG_CLIFOR, CDG_LOJA, CDG_ITEM, COUNT(CDG_DOC) COUNTCDG
    cJoinCDG  	+= " FROM "+RetSqlName("CDG")
    cJoinCDG  	+= " WHERE CDG_FILIAL='"+xFilial("CDG")+"' AND D_E_L_E_T_ = '' "
    cJoinCDG  	+= " GROUP BY  CDG_FILIAL, CDG_TPMOV, CDG_DOC, CDG_SERIE, CDG_CLIFOR, CDG_LOJA, CDG_ITEM) CDG "
	cJoinCDG  	+= " ON (CDG.CDG_FILIAL='"+xFilial("CDG")+"' AND CDG.CDG_TPMOV = SFT.FT_TIPOMOV AND CDG.CDG_DOC = SFT.FT_NFISCAL AND CDG.CDG_SERIE = SFT.FT_SERIE AND  CDG.CDG_CLIFOR = SFT.FT_CLIEFOR AND CDG.CDG_LOJA = SFT.FT_LOJA AND CDG.CDG_ITEM = SFT.FT_ITEM  ) "	
	

	cJoin := cJoin + cJoinCDG
	cJoin := "%" + cJoin + "%"

	BeginSql Alias cAliasSFT

		COLUMN FT_EMISSAO AS DATE
		COLUMN FT_ENTRADA AS DATE
		COLUMN FT_DTCANC AS DATE
		COLUMN FI_DTMOVTO AS DATE

		SELECT
		%Exp:cSlctSFT%
		FROM
		%Table:SFT% SFT
		JOIN %Table:SFI% SFI ON (SFI.FI_FILIAL=%xFilial:SFI% AND SFI.FI_PDV=SFT.FT_PDV AND SFI.FI_DTMOVTO=SFT.FT_ENTRADA AND SFI.%NotDel%    )
		JOIN %Table:SLG% SLG ON (SLG.LG_FILIAL=%xFilial:SLG% AND SLG.LG_PDV=SFT.FT_PDV AND SLG.%NotDel%    )
		LEFT JOIN %Table:SB1% SB1 ON(SB1.B1_FILIAL=%xFilial:SB1%  AND SB1.B1_COD=SFT.FT_PRODUTO AND SB1.%NotDel%)
		LEFT JOIN %Table:SD2% SD2 ON(SD2.D2_FILIAL=%xFilial:SD2%  AND SD2.D2_DOC=SFT.FT_NFISCAL AND SD2.D2_SERIE=SFT.FT_SERIE AND SD2.D2_CLIENTE=SFT.FT_CLIEFOR AND SD2.D2_LOJA=SFT.FT_LOJA AND SD2.D2_COD=SFT.FT_PRODUTO AND SD2.D2_ITEM=SFT.FT_ITEM AND SD2.%NotDel%)
		LEFT JOIN %Table:SF4% SF4 ON(SF4.F4_FILIAL=%xFilial:SF4%  AND SF4.F4_CODIGO=SD2.D2_TES AND SF4.%NotDel%)
		LEFT JOIN %Table:CD6% CD6 ON(CD6.CD6_FILIAL=%xFilial:CD6%  AND CD6.CD6_TPMOV=SFT.FT_TIPOMOV AND CD6.CD6_SERIE=SFT.FT_SERIE AND CD6.CD6_DOC=SFT.FT_NFISCAL AND CD6.CD6_CLIFOR=SFT.FT_CLIEFOR AND CD6.CD6_LOJA=SFT.FT_LOJA AND CD6.CD6_ITEM=SFT.FT_ITEM AND CD6.CD6_COD=SFT.FT_PRODUTO       AND CD6.%NotDel%)
		LEFT JOIN %Table:SB5% SB5 ON(SB5.B5_FILIAL=%xFilial:SB5%  AND SB5.B5_COD=SB1.B1_COD AND SB5.%NotDel%)
		%Exp:cJoin%

		WHERE
		SFT.FT_FILIAL=%xFilial:SFT% 		  AND
		SFT.FT_TIPOMOV  = 'S'   				  AND
		SFT.FT_ENTRADA>=%Exp:DToS(dDataDe)%  AND
		SFT.FT_ENTRADA<=%Exp:DToS(dDataAte)% AND
		SFT.FT_DTCANC = ' ' AND
		(SFT.FT_ESPECIE IN %Exp:cExpIN%) AND
		((SFT.FT_BASEPIS > 0 OR SFT.FT_CSTPIS IN ('07','08','09','49' ))  OR (SFT.FT_BASECOF > 0 OR SFT.FT_CSTCOF IN ('07','08','09','49'))) AND
		%Exp:cFiltro%
		SFT.%NotDel%

		%Exp:cOrderBy%

	EndSql

	Do While !(cAliasSFT)->(Eof())

		cChvPDV :=  (cAliasSFT)->FT_PDV

		// Laco por PDV
		While !(cAliasSFT)->(Eof()) .And. cChvPDV==(cAliasSFT)->FT_PDV

			// Laco por Reducao Z
			cChave := (cAliasSFT)->FT_PDV + DtoS((cAliasSFT)->FT_ENTRADA)

			// Indicador de execução p/ geração dos registros de bilhetes de passagem.
			If !lBilhete

				cChaveC405 := ""

				If lConsolid

				//Se consolidado irá gerar C490
					aPar	:= {}
					aAdd(aPar,dDataDe)
					aAdd(aPar,dDataAte)
					/* Utilizado modelo "2D" por questoes de compatibilidade com a rotina antiga
					e o SPED FISCAL, que tambem  possuem este tratamento. Todas as notas geradas
					pelo SIGALOJA, com FT_PDV preenchido e especie CF ou ECF serao escrituradas
					como modelo 2D. */
					aAdd(aPar,"2D")
				//Processa C490
					ProcC490(cC010, oBlocoC, aPar)
				//Paga chave do registro para poder utilizar nos registros filhos
					cChaveC490	:= oBlocoC:getGrupo()					
					PutGlbValue( cC010, ".F." )

				Else
					aPar	:= {}
					aAdd(aPar,Left((cAliasSFT)->LG_IMPFISC,20))
					aAdd(aPar,(cAliasSFT)->LG_SERPDV)
					aAdd(aPar,Right(Alltrim((cAliasSFT)->LG_PDV),3))

				//Processa registro C400
					ProcC400(cC010, oBlocoC, aPar)
				//Pega chave do C400 para utilizar n os filhos
					cChaveC400	:= oBlocoC:getGrupo()					
					PutGlbValue( cC010, ".F." )

				EndIF

			EndIf

			//Processa os itens por redução Z
			While !(cAliasSFT)->(Eof()) .And. (cChave == (cAliasSFT)->FT_PDV + DtoS((cAliasSFT)->FT_ENTRADA))

				//Preencher array para gerar processa referenciado
				aParCompl	:= {}
				aAdd(aParCompl,(cAliasSFT)->FT_TIPOMOV)
				aAdd(aParCompl,(cAliasSFT)->FT_NFISCAL)
				aAdd(aParCompl,(cAliasSFT)->FT_SERIE)
				aAdd(aParCompl,(cAliasSFT)->FT_CLIEFOR)
				aAdd(aParCompl,(cAliasSFT)->FT_LOJA)

				aProd	:=  {"","","","","","","","","","",""}

				//Parametro onde poderá ou não gerar informações dos registros 0200 e 0500
				IF aParSX6[MV_SPDCGPC]
					//-------------------------------------------------------------------
					//Processa conta contábil
					//-------------------------------------------------------------------
					cConta	:= FSA0080500('', oBloco0,oTabela,lConcFil,(cAliasSFT)->FT_CONTA,cAliasSFT)

					//-------------------------------------------------------------------
					//Processa código do produto 0200 para ser utilizado no registros abaixo.
					//-------------------------------------------------------------------
					If aParPE[SPEDPROD]
						aProd := Execblock("SPEDPROD", .F., .F., {cAliasSFT})
					EndIF


					cCodProd	:= FSA0080200(c0140, oBloco0, aProd, cAliasSFT, oTabela, lConcFil, ;
						nICMPAD, (cAliasSFT)->CD6_CODANP, (cAliasSFT)->B5_TABINC,;
						(cAliasSFT)->B5_CODGRU, (cAliasSFT)->B5_MARCA,,dDataDe)
				EndIF

				// Registros relacionados a cupom (loja)
				If !lBilhete

					IF lConsolid

						//Gera família C490 se usuário escolher forma consolidada

						//-------------------------------------------------------------------
						//Processa itens família C490
						//-------------------------------------------------------------------
						PrcC491495(cChaveC490, oBlocoC, cAliasSFT,cConta,cCodProd,aParSX6[MV_PISCOFP])
						IF (cAliasSFT)->COUNTCDG >= 1
							BuscaCDG(cChaveC490, aParCompl, oBlocoC, oBloco1, 'C499','C490', lTabCIE, dDataDe, (cAliasSFT)->FT_ITEM, cCodProd, cConta,,, (cAliasSFT)->FT_CHVNFE)
						Endif
					Else

						//Gera família C400 se usuário escolher forma individualizada
						ProcC405(cChaveC400, oBlocoC, cAliasSFT, cChaveC405)
						//Pega chave do C405 para utilizar em C481, C485
						cChaveC405	:= oBlocoC:getGrupo()

						//-------------------------------------------------------------------
						//Processa itens família C400
						//-------------------------------------------------------------------
						PrcC481485(cChaveC405, oBlocoC, cAliasSFT,cConta,cCodProd,aParSX6[MV_PISCOFP])

						//Processa referenciado regiustro C489
						IF (cAliasSFT)->COUNTCDG >= 1
							BuscaCDG(cChaveC405, aParCompl, oBlocoC, oBloco1, 'C489','C405', lTabCIE, dDataDe, (cAliasSFT)->FT_ITEM, cCodProd, cConta,,, (cAliasSFT)->FT_CHVNFE)
						Endif
					EndIF

				// Registros relacionados a bilhetes de passagem emitidos por ECF - SEM ponto de entrada.
				// Quando vier via PE a geração do D350 ocorre no final da função ProcNF.
				ElseIf lIntGTP .And. !aParPE[SPDPISTR]

					//-------------------------------------------------------------------
					//Processa itens família D350
					//-------------------------------------------------------------------
					ProcD350(cD010, oBlocoD, NIL, cConta, cAliasSFT, aParSX6[MV_PISCOFP])
					cChaveD350	:= oBlocoD:getGrupo()					
					PutGlbValue( cD010, ".F." )

					//Processa referenciado regiustro D359
					IF (cAliasSFT)->COUNTCDG >= 1
						BuscaCDG(cChaveD350, aParCompl, oBlocoD, oBloco1, 'D359', 'D350', lTabCIE, dDataDe, (cAliasSFT)->FT_ITEM, cCodProd, cConta,,, (cAliasSFT)->FT_CHVNFE)
					Endif
				EndIf

				(cAliasSFT)->(dbSkip())

			EndDo

		EndDo

	EndDo

	DbSelectArea (cAliasSFT)
	(cAliasSFT)->(DbCloseArea())

Return

 //-------------------------------------------------------------------
/*/{Protheus.doc} ProcCKN()
@description Função que irá processar informações da tabela CKN para gerar registro 0100
@author Erick G. Dias
@since 04/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function ProcCKN(oBloco0, dDataDe,oTabela)

	Local	cMesEFD	:= SubStr(dTos(dDataDe),5,2)
	Local	cAnoEFD	:= SubStr(dTos(dDataDe),1,4)
	Local	lCodMot	:= CKN->(Fieldpos("CKN_MTCOMP")) > 0
	Local	cInfCom	:= ""

	If CKN->(DbSeek(xFilial('CKN')+cMesEFD+cAnoEFD))
		Do While (!CKN->(Eof ()) .And. (CKN->CKN_FILIAL == xFilial("CKN") .And. CKN->CKN_MESEFD == cMesEFD .And. CKN->CKN_ANOEFD == cAnoEFD))

			//A partir de agosto de 2017 deve ser impresso codigo de motivo
			If lCodMot .and. ((Val(cMesEFD) >= 08 .And. Val(cAnoEFD)>=2017) .or. Val(cAnoEFD)>=2018)
				cInfCom :=  CKN->CKN_MTCOMP
			Else
				cInfCom :=	CKN->CKN_INFCOM
			Endif

			Proc0120('0100000000001', oBloco0, CKN->CKN_MESDIS+CKN->CKN_ANODIS, cInfCom)

			CKN->(dbSkip())
		EndDo
	EndIf

	oTabela:GrvReg(oBloco0:get0120())


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PrcCDT()
@description Função que irá buscar informação complementar, para gerar registros A110, C110 e/ou 0450
@param cRegistro ,String,Registro do SPED Contribuições
@param cChave    ,String,Relacionamento com registro A100 ou C100
@param cChave0140,String,Relacionamento com registro 0140
@param oBloco0   ,Objeto,Objeto da classe EFDCBLOCO0
@param oBloco    ,Objeto,Objeto da classe EFDCBLOCOA
@param oTabela	 ,Objeto,Objeto da classe ARRAYTOTMP
@param cAliasSFT ,Alias posicionado na tabela SFT
@param lFMennota ,Lógico,Protecao para tratamento do campo de mensagem da NF
@param lSPDPISIC ,Lógico,Indica se utiliza ponto de entrada

@author Erick G. Dias
@since 05/12/2014
@version 11.90
/*/

Static Function ProcCDT(cRegistro, cChave, cChave0140, oBloco0, oBloco, oTabela, cAliasSFT, nMVSPDIFC, lFMennota, lSPDPISIC)

	Local aInfCompl := {}
	Local aPEC110	:= {}
	Local cDesc		:= ''
	Local cCodInf	:= ''
	Local cRet		:= ''
	Local nInf		:= 0
	Local nI		:= 0

	/* 	Regra para retornar informações complementares dos documentos fiscais, preenchimento dos Registros A110 e C110,
		Privilegia o processamento do ponto de entrada

		MV_SPDIFC = 0 - retorna a descrição da Tabela CCE - Informações complementares
		MV_SPDIFC = 1 - retorna a descrição da Tabela CDT ou da CDC caso não esteja preenchido CDT.
		MV_SPDIFC = 2 - retorna a descricao do _MENNOTA da SF1 ou SF2
	*/

	If lSPDPISIC	//	Verifica existencia de Ponto de Entrada - maior prioridade
		aPEC110	:=	ExecBlock("SPDPISIC",.F.,.F.,{	(cAliasSFT)->FT_NFISCAL, (cAliasSFT)->FT_SERIE, (cAliasSFT)->FT_CLIEFOR, (cAliasSFT)->FT_LOJA, (cAliasSFT)->FT_ENTRADA,(cAliasSFT)->FT_TIPOMOV})

		For nI := 1 to len( aPEC110 )
			
			If 	len(aPEC110[nI]) == 2 .and. cRegistro == "C110"
				cCodInf   :=	aPEC110[nI][1]
				cDesc	  :=	aPEC110[nI][2]
				aAdd( aInfCompl, { cCodInf, cDesc })
			Elseif 	len(aPEC110[nI]) > 2 .and. aPEC110[nI][3] == cRegistro
				cCodInf   :=	aPEC110[nI][1]
				cDesc	  :=	aPEC110[nI][2]
				aAdd( aInfCompl, { cCodInf, cDesc })
			Endif

		Next
	Else
		
		If (cAliasSFT)->COUNTCDT > 0

			If (cAliasSFT)->COUNTCDT == 1 .And. !Empty((cAliasSFT)->CDTRECNO)
				CDT->(dbGoto( (cAliasSFT)->CDTRECNO))
			Else
				CDT->(MsSeek(xFilial("CDT")+(cAliasSFT)->FT_TIPOMOV+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA))
			EndIf
			
				While !CDT->(Eof()) .and. xFilial ("CDT")+(cAliasSFT)->FT_TIPOMOV+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA ==  CDT->CDT_FILIAL+CDT->CDT_TPMOV+CDT->CDT_DOC+CDT->CDT_SERIE+CDT->CDT_CLIFOR+CDT->CDT_LOJA

					cCodInf	:= CDT->CDT_IFCOMP

					If 	nMVSPDIFC == 0		// Considera descrição da Tabela CCE - Informações Complementares
						If CCE->(MsSeek(xFilial("CCE")+cCodInf))
							cDesc	:= 	CCE->CCE_DESCR
						Endif

					Elseif nMVSPDIFC == 1	// Considera descrição da Tabela CDT - Informações Complementares por Nota Fiscal
						cDesc	:= CDT->CDT_DCCOMP

					Elseif nMVSPDIFC == 2 .AND. lFMennota	// Considera descrição do Documento Fiscal, caso existam campos
						If (cAliasSFT)->FT_TIPOMOV == 'E'
							cDesc	:=	(cAliasSFT)->F1_MENNOTA
						Elseif (cAliasSFT)->FT_TIPOMOV == 'S'
							cDesc	:=	(cAliasSFT)->F2_MENNOTA
						Endif

					Endif
					aAdd( aInfCompl, { cCodInf, cDesc })

					CDT->(dbSkip())
				Enddo
		ElseIf (cAliasSFT)->COUNTCDC > 0 
		
			If (cAliasSFT)->COUNTCDC == 1 .And. !Empty((cAliasSFT)->CDCRECNO)
				CDC->(dbGoto( (cAliasSFT)->CDCRECNO))
			Else
				CDC->(MsSeek (xFilial ("CDC")+(cAliasSFT)->FT_TIPOMOV+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA))
			EndIf

			cCodInf	:= 	CDC->CDC_IFCOMP

			If 	nMVSPDIFC == 0		// Considera descrição da Tabela CCE - Informações Complementares
				If CCE->(MsSeek(xFilial("CCE")+cCodInf))
					cDesc	:= 	CCE->CCE_DESCR
				Endif

			Elseif nMVSPDIFC == 1	// Considera descrição da Tabela CDT - Informações Complementares por Nota Fiscal
				cDesc	:= CDC->CDC_DCCOMP

			Elseif nMVSPDIFC == 2 .AND. lFMennota	// Considera descrição do Documento Fiscal, caso existam campos
				If (cAliasSFT)->FT_TIPOMOV == 'E'
					cDesc	:=	(cAliasSFT)->F1_MENNOTA
				Elseif (cAliasSFT)->FT_TIPOMOV == 'S'
					cDesc	:=	(cAliasSFT)->F2_MENNOTA
				Endif
			Endif
			aAdd( aInfCompl, { cCodInf, cDesc })
		EndIf

	EndIf

	//Gera registros conforme Bloco definido
	For nInf := 1 to len( aInfCompl )
		cCodInf := aInfCompl[nInf][1]
		cDesc   := aInfCompl[nInf][2]
		If !Empty(cCodInf) .and. !Empty(cDesc)
			If 	cRegistro == "C110"
				ProcC110(cChave, oBloco, {cCodInf,cDesc} )
				Reg0450(cChave0140, oBloco0, oTabela, cCodInf)
			ElseIf cRegistro == "A110"
				ProcA110(cChave, oBloco, {cCodInf,cDesc} )
				Reg0450(cChave0140, oBloco0, oTabela, cCodInf)
			Endif
		ElseIf cRegistro == "0450"
			Reg0450(cChave0140, oBloco0, oTabela, cCodInf )
		Endif
		cRet := cCodInf
		//Chamo o método para limpar o array do registro 0450 para evitar duplicidade.
		If !oBloco0:getMT()
			oBloco0:cls0450()
		EndIf

	Next nI

Return cRet


Static Function ProcCD5(cChaveA100, cAliasSFT,  aParItem, oBlocoA)
	CD5->(DbSetOrder (4))
	IF	CD5->(MsSeek (xFilial ("CD5")+aParItem[1]+aParItem[2]+aParItem[3]+aParItem[4]+aParItem[5]))

		ProcA120(cChaveA100, oBlocoA, cAliasSFT, 'CD5')

	EndIF


Return

Static Function PrcCD5BlcC(cChavePai,oBlocoC,cAliasSFT, lMV_EASY,lSPDIMP, cReg )

	Local aAverage	:= {}
	Local aPEImport	:= {}
	Local aPar			:= {}
	Local nX			:= 0

	CD5->(DbSetOrder (4))
	If lSPDIMP .AND. cReg == 'C120' //Somente irá verificar ponto de entrada para registro C120
	//Primeiro procura pelo ponto de entrada, terá maior prioridade
		aPEImport	:=	Execblock("SPDIMP",.F.,.F.,{ (cAliasSFT)->FT_NFISCAL,; //FT_NFISCAL
		(cAliasSFT)->FT_SERIE,; //FT_SERIE
		(cAliasSFT)->FT_CLIEFOR,; //FT_CLIEFOR
		(cAliasSFT)->FT_LOJA,; //FT_LOJA
		(cAliasSFT)->FT_ENTRADA})//FT_ENTRADA
	ElseIF lMV_EASY

	//verifica se tem integração com SIGAEIC, com segunda maior prioridade
		aAverage := AvGetImpSped(xFilial ("SFT"), (cAliasSFT)->FT_NFISCAL, (cAliasSFT)->FT_SERIE, (cAliasSFT)->FT_CLIEFOR, (cAliasSFT)->FT_LOJA)
	EndIF

	If Len(aPEImport) > 0
		For nX	:= 1 to Len(aPEImport)
			aPar	:= {}
			aAdd(aPar,aPEImport[nX][1])
			aAdd(aPar,aPEImport[nX][2])
			aAdd(aPar,aPEImport[nX][3])
			aAdd(aPar,aPEImport[nX][4])
			aAdd(aPar,aPEImport[nX][5])

			IF cReg == 'C120'
				ProcC120(cChavePai, oBlocoC, aPar)
			ElseIF cReg == 'C199'
				ProcC199(cChavePai, oBlocoC, aPar)
			EndIF

		Next nX

	ElseIF Len(aAverage) > 0

		aPar	:= {}
		aAdd(aPar,aAverage[1][2][1][2][1])
		aAdd(aPar,aAverage[1][2][2][2][1])
		aAdd(aPar,aAverage[1][2][3][2][1])
		aAdd(aPar,aAverage[1][2][4][2][1])
		aAdd(aPar,'')

		IF cReg == 'C120'
			ProcC120(cChavePai, oBlocoC, aPar)
		ElseIF cReg == 'C199'
			ProcC199(cChavePai, oBlocoC, aPar)
		EndIF

	ElseiF CD5->(MsSeek(xFilial('CD5')+(cAliasSFT)->(FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA+FT_ITEM)))

		aPar	:= {}
		aAdd(aPar,CD5->CD5_TPIMP)
		aAdd(aPar,CD5->CD5_DOCIMP)
		aAdd(aPar,CD5->CD5_VLPIS)
		aAdd(aPar,CD5->CD5_VLCOF)
		aAdd(aPar,CD5->CD5_ACDRAW)

		IF cReg == 'C120'
			ProcC120(cChavePai, oBlocoC, aPar)
		ElseIF cReg == 'C199'
			ProcC199(cChavePai, oBlocoC, aPar)
		EndIF

	EndIF

Return


Static Function RegF150(cChaveF010,dDataDe,dDataAte,oBlocoF,oTabela,oBloco0,lConcFil)


	Local cAliasCF9	:= ''
	Local cSlctCF9	:= ''
	Local dDtIng		:= firstday(dDataDe)
	Local nCont		:= 0
	Local nQtdMesAnt	:= 12
	Local cConta		:= ''
	Local dDtLimite	:= LastDay(dDataAte)

	For nCont := 1 to nQtdMesAnt
		dDtIng	:=firstday(dDtIng)-1
	Next nCont

	dDtIng	:=firstday(dDtIng)
	dMesIng := month(dDtIng)

	cSlctCF9 := "CF9.CF9_CODBCC,	CF9.CF9_PERING,		CF9.CF9_VLTEST,		CF9.CF9_SCRED ,		CF9.CF9_BASCAL,		"
	cSlctCF9 += "CF9.CF9_BASMES,	CF9.CF9_CSTPIS,		CF9.CF9_ALQPIS,		CF9.CF9_VALPIS,		CF9.CF9_CSTCOF,		"
	cSlctCF9 += "CF9.CF9_ALQCOF,	CF9.CF9_VALCOF,		CF9.CF9_DESCPR,		CF9.CF9_CODCTA"

	cSlctCF9	:=	"%"+cSlctCF9+"%"

	cAliasCF9	:=	GetNextAlias()

	BeginSql Alias cAliasCF9
		COLUMN CF9_PERING AS DATE
		SELECT
		%Exp:cSlctCF9%
		FROM
		%Table:CF9% CF9
		WHERE
		CF9.CF9_FILIAL = %xFilial:CF9% AND
		CF9.CF9_PERING > %Exp:DToS(dDtIng)% AND
		CF9.CF9_PERING <= %Exp:DToS(dDtLimite)% AND
		CF9.%NotDel%
	EndSql

	DbSelectArea (cAliasCF9)
	(cAliasCF9)->(DbGoTop ())

	Do While !(cAliasCF9)->(Eof ())
		If Month((cAliasCF9)->CF9_PERING) = dMesIng .And. Year(dDataDe) > Year((cAliasCF9)->CF9_PERING)
			(cAliasCF9)->(dbSkip())
			Loop
		Endif

		cConta	:= FSA0080500('', oBloco0,oTabela,lConcFil,(cAliasCF9)->CF9_CODCTA,,.F.)

		ProcF150(cChaveF010, oBlocoF, cAliasCF9,cConta)		
		PutGlbValue( cChaveF010, ".F." )

		(cAliasCF9)->(DbSkip ())
	EndDo

	DbSelectArea (cAliasCF9)
	(cAliasCF9)->(DbCloseArea ())

	oTabela:GrvReg(oBlocoF:getF150())

	oBlocoF:clsF150()

Return

Function FSA0080600(cChave0001,oBloco0,oTabela,lConcFil,cCusto,cAliasSFT)
	Local aPar		:= {}
	Local cRetorno	:= ''
	Local cCusFil	:= ''
	Local aRetCC	:= {}

	If aParPE[SPDRA170]
		aRetCC := ExecBlock("SPDRA170", .F., .F., {cCusto,cAliasSFT})
		If ValType(aRetCC) == "A" .And. Len(aRetCC) >= 1
			cCusto := aRetCC[1]
		EndIf
	EndIf

	cCusFil	:= cCusto
	If lConcFil
		cCusFil	+= xFilial("CTT")
	EndIF

	//Deverá verificar se centro de custo já foi utilizado e gravado
	If !Empty(cCusto) .AND. !oTabela:ProCad('10', cCusFil) //Tipo 10 == 0600, passou código já concatenado com filial

		DbSelectArea("CTT")
		CTT->(dbSetOrder(1))
		If CTT->(MsSeek(xFilial("CTT")+ cCusto))
			//Deverá verificar antes de deve ou não concaternar a filial no código antes de incluir ou retornar o códiugo
			If lConcFil
				cCusto += xFilial("CTT")
			EndIF
			aPar := {}
			aAdd(aPar,CTT->CTT_DTEXIS)				//02-DT_ALT
			aAdd(aPar,cCusto)						//03-COD_CCUSC
			aAdd(aPar,left(CTT->CTT_DESC01,60))		//04-CCUS
		Endif

	//Processa registro 0600
		IF len(aPar) > 0
			Proc0600(cChave0001,oBloco0, aPar)
			cRetorno	:= aPar[3]
			IF !oBloco0:getMT()
				oTabela:GrvReg(oBloco0:get0600())
			EndIF
		EndIF

	ElseIf !Empty(cCusto)
		If lConcFil
			cCusto += xFilial("CTT")
		EndIF
	EndIF

Return cCusto

 //-------------------------------------------------------------------
/*/{Protheus.doc} FSA0080500()
@description ~Função que irá processar o código de conta contábil
@param cChave0001,String,Relacionamento com registro 0001
@param oBloco0,Objeto,Objeto do bloco 0
@param oTabela,Objeto,Objeto para ~gravação do registro
@param lConcFil,Lógico,Indica se deverá ser concatenada a filial no código
@param cConta,String,Código da conta contábil
@param aParPE,Array,Array quando conta for gerada através de parâmetro
@param cAliasSFT,String,Alias da query do livro fiscal
@param lSPDPIS07,LógioLógico,Indica se de verá processar o ponto de entrada SPDPIS07
@author Erick G. Dias
@since 15/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function FSA0080500(cChave0001,oBloco0,oTabela,lConcFil,cConta,cAliasSFT,lSPDPIS07,aParPonto)
	Local 		aPar		:= {}
	Local		cCtaRef		:= ''
	Local 		cContaFil	:= ''
	Local		cQuery		:= ''
	Local 		cTypeDB		:= ''
	Default		aParPonto	:= {}
	DEfault 	lSPDPIS07	:= .T.

	//Pessoas juridicas tributadas com base no lucro presumido nao sujeitas a obrigatoriedade da ECD
	If !Empty(cConta) .AND. lMvPar23 .AND. MV_PAR23 == 1 .AND. mv_par08 == 2//Regime Cumulativo e Dispensa de ECD.

		cConta:= "DISPENSA DE ECD - IN RFB N 1.774/2017."

		//Deverá verificar se a conta já foi utilizado e gravado no 0500
		If !oTabela:ProCad('09', cConta)

			aPar	:= {;
							'22122017',; //02-DT_ALT
							'09'	  ,; //03-COD_NAT_CC
							"S"		  ,; //04-IND_CTA
							"0"		  ,; //05-NIVEL
							cConta    ,; //06-COD_CTA
							cConta    ,; //07-NOME_CTA
							''		  ,; //08-COD_CTA_REF
							''		   ; //09-CNPJ_EST
						}	

			//Processa registro 0500
			IF len(aPar) > 0
				Proc0500(cChave0001,oBloco0, aPar)
				IF !oBloco0:getMT()
					oTabela:GrvReg(oBloco0:get0500())
				EndIF
			EndIf
		EndIf
	Else

		If aParPe[SPDPIS07] .And. lSPDPIS07
			cConta	:=	ExecBlock("SPDPIS07", .F., .F., {	(cAliasSFT)->FT_FILIAL,;
				(cAliasSFT)->FT_TIPOMOV,;
				(cAliasSFT)->FT_SERIE,;
				(cAliasSFT)->FT_NFISCAL,;
				(cAliasSFT)->FT_CLIEFOR,;
				(cAliasSFT)->FT_LOJA,;
				(cAliasSFT)->FT_ITEM,;
				(cAliasSFT)->FT_PRODUTO,;
				(cAliasSFT)->FT_CONTA})
				
		Endif

		//Monta o código da conta contábil com a filial conforme lConcFil.
		cContaFil	:= cConta + Iif(lConcFil , xFilial("CT1"), '')

		If !Empty(cConta)
			//Deverá verificar se centro de conta já foi utilizado e gravado
			If !oTabela:ProCad('09', cContaFil)

				If Len(aParPonto) > 0

					aPar	:= {;
									aParPonto[1],; 	//02-DT_ALT
									aParPonto[2],;	//03-COD_NAT_CC
									aParPonto[3],;	//04-IND_CTA
									aParPonto[4],;	//05-NIVEL
									aParPonto[5],;	//06-COD_CTA
									aParPonto[6],;	//07-NOME_CTA
									aParPonto[7],;	//08-COD_CTA_REF
									aParPonto[8] ;	//09-CNPJ_EST
							}	

				Else

					DbSelectArea("CT1")
					CT1->(dbSetOrder(1))
					If CT1->(MsSeek(xFilial("CT1")+ cConta))
						cConta	:= cContaFil
						cCtaRef	:= ''

						if oQryCVN == Nil

							cTypeDB	:= Upper(TcGetDb())

							cQuery:=" SELECT "
							//Para o SQL, trazer a primeira linha
							if cTypeDB == "MSSQL"
								cQuery+=" TOP 1 " 
							endif
						
							cQuery+=" CVD_CTAREF FROM " + RetSQLName("CT1") + " CT1 "
							cQuery+=" JOIN " + RetSQLName("CVD") + " CVD ON CVD_FILIAL=? AND CVD_CONTA=CT1_CONTA AND CVD.D_E_L_E_T_='' "
							cQuery+=" JOIN " + RetSQLName("CVN") + " CVN ON CVN_FILIAL=? AND CVN_CODPLA=CVD_CODPLA AND CVN_VERSAO=CVD_VERSAO AND CVN.D_E_L_E_T_='' "
							cQuery+=" WHERE ?>=CVN_DTVIGI AND (?<=CVN_DTVIGF OR CVN_DTVIGF=' ') "
							cQuery+=" AND CVD_CTAREF<>' ' "
							cQuery+=" AND CT1_CONTA=? "
							cQuery+=" AND CT1.D_E_L_E_T_=' ' "
							cQuery+=" AND CT1_FILIAL=? "
							
							//Para o Oracle trazer a primeira linha
							if cTypeDB == "ORACLE"
								cQuery += " AND ROWNUM = 1 "
							endif
							
							cQuery+=" ORDER BY CVD.R_E_C_N_O_,CVN.R_E_C_N_O_ "
							//Para MSSQL ou PostGreSQL trazer a primeira linha
							if cTypeDB $ "POSTGRES|MYSQL"  
								cQuery += " LIMIT 1 " 
							endif

							cQuery := ChangeQuery(cQuery)

							oQryCVN := FWPreparedStatement():New(cQuery)

						endif
						
						oQryCVN:SetString(1,xFilial("CVD"))
						oQryCVN:SetString(2,xFilial("CVN"))
						oQryCVN:SetString(3,DTOS(oBloco0:getDtDe()))
						oQryCVN:SetString(4,DTOS(oBloco0:getDtAte()))
						oQryCVN:SetString(5,CT1->CT1_CONTA)
						oQryCVN:SetString(6,xFilial("CT1"))

						cQuery	:= oQryCVN:GetFixQuery()
						cCtaRef	:= MpSysExecScalar(cQuery,"CVD_CTAREF") //https://tdn.totvs.com/display/PROT/MPSysExecScalar Executa uma consulta e retorna a primeira linha no conjunto de resultados retornados pela consulta

						aPar	:= {;			    
										CT1->CT1_DTEXIS,;					//02-DT_ALT
										CT1->CT1_NTSPED,;					//03-COD_NAT_CC
										IIF(CT1->CT1_CLASSE=="1","S","A"),; //04-IND_CTA
										Str(CtbNivCta(CT1->CT1_CONTA)),;	//05-NIVEL
										cConta,;   						    //06-COD_CTA
										CT1->CT1_DESC01,;					//07-NOME_CTA
										cCtaRef,;							//08-COD_CTA_REF
										'';									//09-CNPJ_EST
								}	

					Endif
				Endif

				//Processa registro 0600
				IF len(aPar) > 0
					Proc0500(cChave0001,oBloco0, aPar)
					IF !oBloco0:getMT()
						oTabela:GrvReg(oBloco0:get0500())
					EndIF

				EndIF

			Else
				cConta	:= cContaFil
			EndIF
		EndIf	
	EndIf

Return cconta

Static Function Reg0400(cAliasSFT,lSpedNat,oTabela,oBloco0,cChave0140)

	Local cCodNat	:= ''
	Local cDescNat	:= ''	

	If !Empty((cAliasSFT)->CD1_CODNAT)
		cCodNat	:=	(cAliasSFT)->CD1_CODNAT
		cDescNat	:=	(cAliasSFT)->CD1_DESCR

	//Se encontrar TES e MV_SPEDNAT = F
	Elseif !lSpedNat
		cCodNat	:=	(cAliasSFT)->F4_CODIGO
		cDescNat	:=	AllTrim((cAliasSFT)->F4_TEXTO)

	//MV_SPEDNAT = T
	Else
		If Valtype(oJCFOP) <> 'J'
			//Carrega CFOP no Json		
			AllCfops(@oJCFOP)
		Endif
		If (oJCFOP[ AllTrim((cAliasSFT)->FT_CFOP)]) <> Nil		
			cCodNat  := (cAliasSFT)->FT_CFOP
			cDescNat := oJCFOP[AllTrim((cAliasSFT)->FT_CFOP)]
		Endif
	Endif

	If !Empty(cCodNat) .AND. !oTabela:ProCad('07', cCodNat, cChave0140) //Tipo 07 == 0400, passou código já concatenado com filial

		Proc0400(cChave0140,oBloco0, {cCodNat,cDescNat})

		IF !oBloco0:getMT()
			oTabela:GrvReg(oBloco0:get0400())
		EndIF


	EndIF

Return cCodNat

Static Function Reg0450(cChave0140,oBloco0, oTabela, cCodInf, aPar)

	Local cTxtInf	:= ''

	Default aPar	:= {}

	If Len(aPar) > 0 .AND. !Empty( aPar[2] )
		cCodInf	:= aPar[1]
		cTxtInf	:= aPar[2]
	Elseif CCE->(MsSeek (xFilial("CCE")+cCodInf))
		cCodInf	:=	CCE->CCE_COD
		cTxtInf	:=	CCE->CCE_DESCR
	Endif


	If !Empty(cCodInf) .AND.  !oTabela:ProCad('08', cCodInf, cChave0140)
		Proc0450(cChave0140,oBloco0, {cCodInf,cTxtInf})
		IF !oBloco0:getMT()
			oTabela:GrvReg(oBloco0:get0450())
		EndIF

	Endif

Return

 //-------------------------------------------------------------------
/*/{Protheus.doc} FSA0080150()
@description Função para geração do registro de participante 0150

@author Erick G. Dias
@since 08/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function FSA0080150(cChave0140, oTabela, oBloco0, cClieFor, cAliasSFT,lConcFil, dDataIniP)

	Local cCodPart		:= ''
	Local cCodPais		:= ''
	Local cNome			:= ''
	Local cCnpj			:= ''
	Local cCPF			:= ''
	Local cIe			:= ''
	Local cCodMun		:= ''
	Local cSuframa		:= ''
	Local cEnd			:= ''
	Local cNum			:= ''
	Local cCompl		:= ''
	Local cBairro		:= ''
	Local cUf			:= ''
	Local cIm			:= ''
	local aPar			:= {}
	Local aEnder		:= {"",0,"",""}
	Local aRegAux		:= {}
	Local aMod        	:= {}
	Local lRural	 	:= aParSX3[FP_A2_CPFRUR] .And. aParSX3[FP_A2_INDRUR]
	Default dDataIniP	:= MV_PAR01

	If cClieFor	 == 'SA1' // Cliente tabela SA1

	//Campo ENDNOT indica que endereco participante mao esta no formato <logradouro>, <numero> <complemento>
	//Se tiver com 'S' somente o campo de logradouro sera atualizado (numero sera SN)
		If ((cAliasSFT)->A1_EST == "DF") .Or. (aParSX3[FP_A1_ENDNOT]  .And. (cAliasSFT)->A1_ENDNOT == "1")
			aEnder[1] := (cAliasSFT)->A1_END
			aEnder[3] := "SN"
		Else
			If aparSX6[MV_HISTTAB]
				aMod := MsConHist(cClieFor,(cAliasSFT)->A1_COD,(cAliasSFT)->A1_LOJA,dDataIniP,,,)
				cEnd := RetCmpHist(cAliasSFT+"->A1_END", aMod, MV_PAR02, .T.)
				If Len(aMod) > 0 .And. Len(aMod[1]) > 0 .And. !Empty(cEnd)
					aEnder := FisGetEnd(cEnd,(cAliasSFT)->A1_EST)
				Else
					aEnder := FisGetEnd((cAliasSFT)->A1_END,(cAliasSFT)->A1_EST)
				EndIf
			Else
				aEnder := FisGetEnd((cAliasSFT)->A1_END,(cAliasSFT)->A1_EST)
			EndIf
			If Len(aEnder) >= 4 .And. Len(aEnder[1]) >60 .And. Empty(AllTrim((cAliasSFT)->A1_COMPLEM))
				aEnder[1] := SubsTr(aEnder[1], 1,60)
				aEnder[4] := SubsTr(SubsTr(aEnder[1], 61,len(aEnder[1])) + " " + aEnder[4],1,60)
			ElseIf Len(aEnder) >= 4
				aEnder[4] := AllTrim((cAliasSFT)->A1_COMPLEM)
			EndIf
		EndIf

		cCodPart	:= 'SA1'+ Iif(lConcFil ,AllTrim(cFilAnt) ,'' ) +  (cAliasSFT)->A1_COD + (cAliasSFT)->A1_LOJA
		cCodPais	:= (cAliasSFT)->A1_CODPAIS
		cNome		:= (cAliasSFT)->A1_NOME
		cCnpj		:= Iif((cAliasSFT)->A1_PESSOA == 'J'  , SPEDConvType(VldIE((cAliasSFT)->A1_CGC,,.F.)),'')
		cCPF		:= Iif((cAliasSFT)->A1_PESSOA == 'F'  , SPEDConvType(VldIE((cAliasSFT)->A1_CGC,,.F.)),'')
		cIe			:= VldIE((cAliasSFT)->A1_INSCR)
		cCodMun		:= CodMunPart(cCodPais, (cAliasSFT)->A1_EST,(cAliasSFT)->A1_COD_MUN)
		cSuframa	:= Iif(aParSX3[FP_A1_SUFRAMA],(cAliasSFT)->A1_SUFRAMA ,'')
		cEnd		:= aEnder[1]
		cNum		:= Iif (!Empty(aEnder[2]),aEnder[3],"SN")
		cCompl		:= aEnder[4]
		cBairro		:= (cAliasSFT)->A1_BAIRRO
		cUf			:= (cAliasSFT)->A1_EST
		cIm			:= (cAliasSFT)->A1_INSCRM

	ElseIF cClieFor == 'SA2' //Fornecedor tabela SA2
	//Campo ENDNOT indica que endereco participante mao esta no formato <logradouro>, <numero> <complemento>
	//Se tiver com 'S' somente o campo de logradouro sera atualizado (numero sera SN)
		If ((cAliasSFT)->A2_EST == "DF") .Or. (aParSX3[FP_A2_ENDNOT]  .And. (cAliasSFT)->A2_ENDNOT == "1")
			aEnder[1] := (cAliasSFT)->A2_END
			aEnder[3] := "SN"
		Else
			If aparSX6[MV_HISTTAB]
				aMod := MsConHist(cClieFor,(cAliasSFT)->A2_COD,(cAliasSFT)->A2_LOJA,dDataIniP,,,)
				cEnd := RetCmpHist(cAliasSFT+"->A2_END", aMod, MV_PAR02, .T.)
				If Len(aMod) > 0 .And. Len(aMod[1]) > 0 .And. !Empty(cEnd)
					aEnder := FisGetEnd(cEnd,(cAliasSFT)->A2_EST)
				Else
					aEnder := FisGetEnd((cAliasSFT)->A2_END,(cAliasSFT)->A2_EST)
				EndIf
			Else
				aEnder := FisGetEnd((cAliasSFT)->A2_END,(cAliasSFT)->A2_EST)
			EndIf
			If Len(aEnder) >= 4 .And. Len(aEnder[1]) >60 .And. Empty(AllTrim((cAliasSFT)->A2_COMPLEM))
				aEnder[1] := SubsTr(aEnder[1], 1,60)
				aEnder[4] := SubsTr(SubsTr(aEnder[1], 61,len(aEnder[1])) + " " + aEnder[4],1,60)
			ElseIf Len(aEnder) >= 4
				aEnder[4] := AllTrim((cAliasSFT)->A2_COMPLEM)
			EndIf
		EndIf

		cCodPart	:=  'SA2'+ Iif(lConcFil ,AllTrim(cFilAnt) ,'' ) +  (cAliasSFT)->A2_COD + (cAliasSFT)->A2_LOJA
		cCodPais	:= (cAliasSFT)->A2_CODPAIS
		cNome		:= (cAliasSFT)->A2_NOME

		If lRural .And. ((cAliasSFT)->A2_TIPO == 'F') .And. ((cAliasSFT)->A2_INDRUR != '0') .And. ((cAliasSFT)->A2_EST $ 'SP|MG') .And. !Empty((cAliasSFT)->A2_CPFRUR)
			cCnpj	:=  SPEDConvType(VldIE((cAliasSFT)->A2_CGC,,.F.))
			cCPF	:=  ''
		Else
			cCnpj	:=  Iif((cAliasSFT)->A2_TIPO == 'J'  , SPEDConvType(VldIE((cAliasSFT)->A2_CGC,,.F.)),'')
			cCPF	:=  Iif((cAliasSFT)->A2_TIPO == 'F'  , SPEDConvType(VldIE((cAliasSFT)->A2_CGC,,.F.)),'')
		EndIf

		cIe			:=  VldIE((cAliasSFT)->A2_INSCR)
		cCodMun		:= CodMunPart(cCodPais, (cAliasSFT)->A2_EST,(cAliasSFT)->A2_COD_MUN)
		cSuframa	:=  Iif(aParSX3[FP_A2_SUFRAMA],(cAliasSFT)->A2_SUFRAMA ,'')
		cEnd		:= aEnder[1]
		cNum		:= Iif (!Empty(aEnder[2]),aEnder[3],"SN")
		cCompl		:= aEnder[4]
		cBairro		:= (cAliasSFT)->A2_BAIRRO
		cUf			:= (cAliasSFT)->A2_EST
		cIm			:= (cAliasSFT)->A2_INSCRM
	// Tratamento para carregar os dados da filial quando a emissão é uma devolução com formulário próprio e DEVMERC = S no C100 e 0150	
	ElseIf cClieFor == 'SM0'
		
		aEnder := FisGetEnd(SM0->M0_ENDCOB,SM0->M0_ESTCOB)

		cCodPart := "SM0"+SM0->M0_CODFIL
		cCodPais := "01058"
		cNome	 := SM0->M0_NOMECOM
		cCnpj	 := SPEDConvType(VldIE(SM0->M0_CGC,,.F.))
		cCPF	 := ''
		cIe		 := VldIE(SM0->M0_INSC)
		cCodMun	 := CodMunPart("01058", SM0->M0_ESTCOB,SM0->M0_CODMUN)
		cSuframa := SM0->M0_INS_SUF
		cEnd	 := aEnder[1]
		cNum	 := Iif (!Empty(aEnder[2]),aEnder[3],"SN")
		cCompl	 := aEnder[4]
		cBairro	 := SM0->M0_BAIRCOB
		cUf		 := SM0->M0_ESTCOB
		cIm		 := SM0->M0_INSCM
	EndIF

	aPar	:= 	{;
					1,; 				//relação com o pai 0140
					"0150",; 			//01-REG
					cCodPart,;			//01-COD_PART
					cNome,;				//02-NOME
					cCodPais,;			//03-COD_PAIS
					cCnpj,;				//04-CNPJ
					cCPF,;				//05-CPF
					cIe,;				//06-IE
					cCodMun,;			//07-COD_MUN
					cSuframa,;			//08-SUFRAMA
					Padr(cEnd,60),;		//09-END
					cNum,;				//10-NUM
					Padr(cCompl,60),;	//11-COMPL
					cBairro;		 	//12-BAIRRO
				}		

	If aParPe[ SPED0150 ]
		aRegAux := ExecBlock( "SPED0150" , .F. , .F. , { aPar } )
		If Len( aRegAux ) == 14
			aPar := aRegAux
			cCodPart	:= aRegAux[3]
		Endif
	Endif

	If !oTabela:ProCad('01', cCodPart, cChave0140) //01 = Registro 0150
		Proc0150(cChave0140,oBloco0, aPar)
		IF !oBloco0:getMT()
			oTabela:GrvReg(oBloco0:get0150())
		EndIF

	EndIF

Return cCodPart

 //-------------------------------------------------------------------
/*/{Protheus.doc} RegF700()
@description Função que irá buscar informação da tabela CF2 e gerar registro F700
@param dDataDe,Date,Data inicial de geração do arquivo
@param oBlocoF,Objeto,Objeto da classe EFDCBLOCOF
@param oTabela,Objeto,Objeto da classe ARRAYTOTMP
@param cChaveF010,String,Relacionamento com registro F010 pai.
@param nTipRegime,Numeric,Tipo do regime
@author Erick G. Dias
@since 08/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function RegF700(dDataDe, oBlocoF, oTabela, cChaveF010 , nTipRegime)

	Local cSelect	:= 	''
	Local cFrom	:= ''
	Local cWhere	:= ''
	Local cPeriodo 	:= cvaltochar(strzero(month(dDataDe),2)) + cvaltochar(year(dDataDe ))
	Local cAliasCF2	:= ''

	Default nTipRegime	:=	mv_par08
	
	cSelect	:=	"%CF2.CF2_FILIAL, CF2.CF2_PER, CF2.CF2_ORIDED, CF2.CF2_INDNAT, CF2.CF2_DEDPIS, CF2.CF2_DEDCOF, CF2.CF2_BASE, CF2.CF2_CNPJ, CF2.CF2_INFORM, CF2.CF2_CMPDED%"
	cFrom	:=	"%"+RetSqlName("CF2")+" CF2 %"
	cWhere	:=	"%CF2.CF2_FILIAL='"+xFilial("CF2")+"' AND "
	if nTipRegime==1
		cWhere	+=	"CF2.CF2_INDNAT='0' AND "
	ElseIf nTipRegime==2
		cWhere	+=	"CF2.CF2_INDNAT='1' AND "
	EndIF
	cWhere	+=	"CF2.CF2_PER='"+cPeriodo+"' AND "
	cWhere	+=	"CF2.D_E_L_E_T_=''%"

	cAliasCF2	:=	getNextAlias()
	BeginSql Alias cAliasCF2

		SELECT
		%Exp:cSelect%

		FROM
		%Exp:cFrom%

		WHERE
		%Exp:cWhere%

	EndSql

	DbSelectArea (cAliasCF2)
	(cAliasCF2)->(DbGoTop ())

	Do While !(cAliasCF2)->(Eof ())

		ProcF700(cChaveF010, oBlocoF, cAliasCF2)		
		PutGlbValue( cChaveF010, ".F." )

		(cAliasCF2)->(DbSkip())
	EndDo

	oTabela:GrvReg(oBlocoF:getF700())
	oBlocoF:clsF700()

	DbSelectArea (cAliasCF2)
	(cAliasCF2)->(DbCloseArea())

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} RegF800()
@description Função que irá buscar informação da tabela F0X e gerar registro F800
@param dDataDe,Date,Data inicial de geração do arquivo
@param oBlocoF,Objeto,Objeto da classe EFDCBLOCOF
@param oTabela,Objeto,Objeto da classe ARRAYTOTMP
@param cChaveF010,String,Relacionamento com registro F010 pai.
@author Erick G. Dias
@since 08/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function RegF800(dDataDe, oBlocoF, oTabela,cGrpPaiF)
	Local cAliasF0X	:= ''
	Local oGetF0X    := FISX001():New()

	oGetF0X:GetF0X(dDataDe)

	cAliasF0X	:=	getNextAlias()
	BeginSql Alias cAliasF0X
		COLUMN F0X_DTEVEN AS DATE
		SELECT
		%Exp:oGetF0X:GetcSlctF0X()%

		FROM
		%Exp:oGetF0X:GetcFromF0X()%

		WHERE
		%Exp:oGetF0X:GetcWhereF0X()%

	EndSql

	DbSelectArea (cAliasF0X)
	(cAliasF0X)->(DbGoTop ())

	Do While !(cAliasF0X)->(Eof ())

		ProcF800(cGrpPaiF, oBlocoF, cAliasF0X)		
		PutGlbValue( cGrpPaiF, ".F." )

		(cAliasF0X)->(DbSkip())
	EndDo

	oTabela:GrvReg(oBlocoF:getF800())
	oBlocoF:clsF800()

	DbSelectArea (cAliasF0X)
	(cAliasF0X)->(DbCloseArea())

Return

 //-------------------------------------------------------------------
/*/{Protheus.doc} FSA0080200()
@description Função que irá gerar registro 0200 e filhos, que tratam das informações
			   de produtos utilizados na EFD.
@author Erick G. Dias
@since 09/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function FSA0080200(cChave0140, oBloco0, aProdPE, cAliasSB1, oTabela, lConcFil, nICMPAD, cCodAnp, cTabCom,cGrupoCom, cMarcaCom,cUnid,dDataDe)

	Local aPar			:= {}

	Local cTipo			:= '99'
	Local cProd			:= ''
	Local cDescr		:= ''
	Local cCodBarra		:= ''
	Local cCodAnt		:= ''
	Local cUniMed		:= ''
	Local cTpItem		:= ''
	Local cNcm			:= ''
	Local cExNcm		:= ''
	Local cCodGen		:= ''
	Local cCodIss		:= ''
	Local cCodLst		:= ''
	Local cGrupo0200	:= ''
	Local cTpPrd		:= ''
	Local nAlqProd		:= 0
	Local nTipo			:= 0
	Local aHist			:= {}
	Local aAuxDesc		:= {}
	Local cDescProd		:= ''
	Local dDataFinal	:= cTOd('  /  /    ')
	Local dDataInici	:= cTOd('  /  /    ')
	Local nX			:= 0
	Local aPar0205		:= {}
	Local aTipo			:=	{ {"ME","00"},;
		{"MP","01"},;
		{"EM","02"},;
		{"PP","03"},;
		{"SP","05"},;
		{"PI","06"},;
		{"PA","04"},;
		{"MC","07"},;
		{"AI","08"},;
		{"MO","09"},;
		{"OI","10"},;
		{"SV","09"} }

	Local aRegAux		:= {}
	Local cVersao		:= ''
	Local laProdPE 		:= .F.

	DEFAULT aProdPE 	:= {"","","","","","","","","","","",""}
	DEFAULT cUnid		:= ''
	DEFAULT dDataDe		:= cTOd('  /  /    ')

	laProdPE:= Len(aProdPE)>= 11
	If aParPe[SPDFIS001]
		aTipo := ExecBlock("SPDFIS001", .F., .F., {aTipo,cAliasSB1})
	EndIF

	//Verificação para obter o número de versão do layout
	If dDataDe >= CTOD("01/07/2012")
		cVersao:= "003"
	Else
		cVersao:= "002"
	Endif
/*
IMPORTANTE: Para utilizar esta função, ou o produto deverá estar posicionado na SB1, ou os campos de produto deverão
estar na query passada para processar, estão função não irá posicionar o produto.
*/

//-------------------------------------------------------------------
//CÓDIGO DO PRODUTO
//-------------------------------------------------------------------

	IF laProdPE .And. !Empty(aProdPE[1])
		cProd	:= aProdPE[1]
	Else
		cProd	:= (cAliasSB1)->B1_COD+Iif(lConcFil,xFilial("SB1"),"")
	EndIF

	If !oTabela:ProCad('03', cProd, cChave0140)

		//Obtendo o tipo de item para montar o campo do registro
    	cTpPrd := RetFldProd((cAliasSB1)->B1_COD,"B1_TIPO",cAliasSB1)
    	Iif(Empty(cTpPrd),cTpPrd:=(cAliasSB1)->B1_TIPO,) //DSERFIS1-13182 - Corrigir forma de verificação do retorno do P.E SPDFIS001
    	For nTipo := 1 To Len(aTipo)
    		If cTpPrd $ aTipo[nTipo][1]
    			cTipo := aTipo[nTipo][2]
    			Exit
    		EndIf
    	Next nTipo

	//-------------------------------------------------------------------
	//DESCRIÇÃO DO PRODUTO
	//-------------------------------------------------------------------
		IF laProdPE .And. !Empty(aProdPE[2])
			cDescr	:= aProdPE[2]
		Else
			cDescr	:= (cAliasSB1)->B1_DESC
		EndIF

	//-------------------------------------------------------------------
	//CÓDIGO DE BARRA DO PRODUTO
	//-------------------------------------------------------------------
		IF laProdPE .And. !Empty(aProdPE[3])
			cCodBarra	:= aProdPE[3]
		Else
			cCodBarra	:= IIf(type((cAliasSB1)->B1_CODBAR)== "N",(cAliasSB1)->B1_CODBAR,"")
		EndIF

	//-------------------------------------------------------------------
	//CÓDIGO ANTERIOR DO PRODUTO
	//-------------------------------------------------------------------
		IF laProdPE .And. !Empty(aProdPE[4])
			cCodAnt	:= aProdPE[4] //+xFilial("SB1")
		Else
			cCodAnt	:= (cAliasSB1)->B1_CODANT //Iif(!Empty((cAliasSB1)->B1_CODANT),xFilial("SB1"),""))
		EndIF

	//-------------------------------------------------------------------
	//UNIDADE DE MEDIDA DO PRODUTO
	//-------------------------------------------------------------------
		IF laProdPE .And. !Empty(aProdPE[5])
			cUniMed	:= aProdPE[5]
		Else
			cUniMed	:= (cAliasSB1)->B1_UM
		EndIF

		If !Empty(cUnid) //Considera unidade de medida do ponto de entrada SPDFIS02
			cUniMed	:= cUnid
		EndIF

	//-------------------------------------------------------------------
	//TIPO DO PRODUTO
	//-------------------------------------------------------------------
		IF laProdPE .And. !Empty(aProdPE[6])
			cTpItem	:= aProdPE[6]
		Else
			cTpItem	:= cTipo
		EndIF

	//-------------------------------------------------------------------
	//NCM DO PRODUTO
	//-------------------------------------------------------------------
		If laProdPE .And. !Empty(aProdPE[7])
			cNcm	:=	aProdPE[7]
		Elseif Empty((cAliasSB1)->B1_CODISS)
			If (cAliasSB1)->(FieldPos("FT_POSIPI")) > 0
				cNcm	:=	Iif(!Empty((cAliasSB1)->FT_POSIPI), (cAliasSB1)->FT_POSIPI, (cAliasSB1)->B1_POSIPI)
			Else
				cNcm 	:= (cAliasSB1)->B1_POSIPI
			EndIf				
		Endif

	//-------------------------------------------------------------------
	//CÓDIGO EX DA TABELA TIPI DO PRODUTO
	//-------------------------------------------------------------------
		IF laProdPE .And. !Empty(aProdPE[8])
			cExNcm	:= aProdPE[8]
		Else
			cExNcm	:= (cAliasSB1)->B1_EX_NCM
		EndIF

	//-------------------------------------------------------------------
	//CÓDIGO GÊNERO DO PRODUTO
	//-------------------------------------------------------------------
		IF laProdPE .And. !Empty(aProdPE[9])
			cCodGen	:= aProdPE[9]
		Else
			cCodGen	:= Iif(Empty((cAliasSB1)->B1_CODISS),Left(cNcm,2),"00" )
		EndIF

	//-------------------------------------------------------------------
	//CÓDIGO DE SERVIÇO PRODUTO
	//-------------------------------------------------------------------
		If laProdPE .And. !Empty(aProdPE[10])
			cCodIss	:=	aProdPE[10]
		Else
			cCodIss	:=	AllTrim((cAliasSB1)->B1_CODISS)
		Endif

	//-------------------------------------------------------------------
	//ALÍQUOTA INTERNA DO PRODUTO
	//-------------------------------------------------------------------
		If laProdPE .And. (!Empty(aProdPE[11]) .Or. IIF(ValType(aProdPE[11]) == "N" .And. aProdPE[11] == 0, .T., .F. )) //DSERFIS1-14794 - Implementada a opção do P.E informar a posição 11 com valor 0, pois apenas com teste !Empty(aProdPE[11]), apesar da variavel ser numerica, o Empty ao ser utilizado em variavel numerica, retorna true caso valor seja 0(Zero)
			nAlqProd	:= aProdPE[11]
		Elseif (cAliasSB1)->B1_PICM > 0
			nAlqProd	:=	(cAliasSB1)->B1_PICM
		Elseif !(cTipo$"09")
			nAlqProd:=	nICMPAD
		Endif

	//-------------------------------------------------------------------
	//CÓDIGO DE SERVIÇO (LST)DO PRODUTO
	//-------------------------------------------------------------------
		If !Empty(cCodIss)
			If CDN->(MsSeek(xFilial("CDN")+PadR(cCodIss,8)+Alltrim((cAliasSB1)->B1_COD)))
				cCodIss := StrTran(AllTrim(CDN->CDN_CODLST),".","")
			Elseif CDN->(MsSeek(xFilial("CDN")+PadR(cCodIss,8)))
				cCodIss := StrTran(AllTrim(CDN->CDN_CODLST),".","")
			EndIf
		EndIf

		If dDataDe >= ctod('01/05/2015')
			//Tiro todos os pontos que estiverem no cadastro.
			cCodIss	:= StrTran(cCodIss,".","")

			If !Empty(cCodIss)
				//Coloco ponto na terceita posição do código de serviço
				If (Len(ALLTRIM(cCodIss)))<4
					cCodIss	:= SubStr(cCodIss,1,1) + '.' + SubStr(cCodIss,2,2)
				Else
					cCodIss	:= SubStr(cCodIss,1,2) + '.' + SubStr(cCodIss,3,2)
				EndIf
			EndIF

			cCodLst	:= cCodIss
		Else
			cCodIss	:= StrTran(cCodIss,".","")
			cCodLst	:= Substr(cCodIss,1,4)
		EndIf

		aPar	:= {;
						cProd,;
						cDescr,;
						cCodBarra,;
						cCodAnt,;
						cUniMed,;
						cTpItem,;
						cNcm,;
						cExNcm,;
						cCodGen,;
						cCodLst,;
						nAlqProd;
					}

	//Processa registro 0200
		Proc0200(cChave0140,oBloco0, aPar)
		cGrupo0200	:= oBloco0:getGrupo()

	//-------------------------------------------------------------------
	//GERAÇ~ÇAO REGISDTRO UNIDADE DE MEDIDA 0190
	//-------------------------------------------------------------------
		Reg0190(cChave0140, cUniMed, oBloco0, oTabela)

	//-------------------------------------------------------------------
	//GERAÇÃO DOS REGISTROS FILHOS 0205, 0206, 0208
	//-------------------------------------------------------------------

		IF !Empty(cCodAnp)
			Proc0206(cGrupo0200,oBloco0, cCodAnp)
			IF !oBloco0:getMT()
				oTabela:GrvReg(oBloco0:get0206())
				oBloco0:cls0206()
			EndIF
		EndIF

		IF !Empty(cTabCom) .AND. dDataDe < CTOD("30/04/2015") //Registro 0208 não deverá mais ser gerado a partir de 01/05/2015
			Proc0208(cGrupo0200,oBloco0, {cTabCom ,cGrupoCom ,cMarcaCom })
			IF !oBloco0:getMT()
				oTabela:GrvReg(oBloco0:get0208())
				oBloco0:cls0208()
			EndIF
		EndIF
		//tratamento na geracao do registro 0205 - Alteracao do Item quando um item for alterado na data final do arquivo do Sped Fiscal
   		If	aParPe[ SPED0205 ]
			aRegAux	:= 	Execblock("SPED0205", .F., .F., {oBloco0:getDtDe(),oBloco0:getDtAte(),Substr(cProd,1,TamSx3("B1_COD")[1])})
			//Ira verificar se o retorno do ponto de entrada tem todas as informacoes necessarias
			If ValType(aRegAux[1]) <> "A"
				If Len(aRegAux) >= 4
					aPar0205	:= {}
					aAdd(aPar0205, aRegAux[1])
					aAdd(aPar0205, aRegAux[2])
					aAdd(aPar0205, aRegAux[3])
					If cVersao >= "003"
						aAdd(aPar0205, aRegAux[4])
					EndIf
					Proc0205(cGrupo0200,oBloco0, aPar0205)
				EndIf
			Else
				For nX := 1 To Len(aRegAux)
					If Len(aRegAux[nX]) >= 4
						aPar0205	:= {}
						aAdd(aPar0205, aRegAux[nX][1])
						aAdd(aPar0205, aRegAux[nX][2])
						aAdd(aPar0205, aRegAux[nX][3])
						If cVersao >= "003"
							aAdd(aPar0205, aRegAux[nX][4])
						EndIf
						Proc0205(cGrupo0200,oBloco0, aPar0205)
					EndIf
				Next nX
			EndIf

		EndIf
		If aparSX6[MV_HISTTAB]
			aHist := MsConHist("SB1","","",oBloco0:getDtDe() ,oBloco0:getDtAte() ,Substr(cProd,1,TamSx3("B1_COD")[1]))

			//Verificando se a função MsConHist retornou pelo menos um array
			If Len(aHist) > 0

				//Passando para um array auxiliar os arrays que são do campo B1_DESC, para ordenar corretamente por DATA e HORA de alteração
				For nX := 1 To Len(aHist)
					If Alltrim(aHist[nX][1]) $ "B1_DESC|B1_CODANT" //DSERFIS1-12838
						aAdd(aAuxDesc,aHist[nX])
					EndIf
				Next nX
				If len(aAuxDesc) >0
					//Ordenando descrescentemente o array aAuxDesc de acordo com DATA e HORA de alteração
					//Foi necessário colocar a condição da hora ser maior ou igual a dez, pois quando concatena os valor maiores que 10 eram ordenados de forma
					//incorreta caso houvesse outra hora com data próxima ou na mesma data.
					aAuxDesc := aSort(aAuxDesc,,,{|x,y| AllTrim(dTOs(x[3]))+IIf(HoraToInt(x[4])>=10,AllTrim(Str(HoraToInt(x[4]))),"0"+AllTrim(Str(HoraToInt(x[4])))) > AllTrim(dTOs(y[3]))+IIf(HoraToInt(y[4])>=10,AllTrim(Str(HoraToInt(y[4]))),"0"+AllTrim(Str(HoraToInt(y[4]))) ) })

					//Atribuindo a variavel cDescProd o valor da 'DESCRIçãO ANTERIOR DO PRODUTO' da ultima alteração
					cDescProd := aAuxDesc[1][2]

					//Atribuindo a ultima data de alteração a variavel dDataFinal
					dDataFinal := IIf(Day(UltimoDia(aAuxDesc[1][3]))==Day(aAuxDesc[1][3]),aAuxDesc[1][3]-1,aAuxDesc[1][3])
					If Len(aAuxDesc)==1
						//Atribuindo a data da criação do produto a variavel dDataInici por ter efetuado uma alteração do produto
						dbSelectArea("SB1")
						dbSetOrder(1)
						If MsSeek(xFilial("SB1")+Substr(cProd,1,TamSx3("B1_COD")[1]))
							If valtype( (cAliasSB1)->B1_DATREF) == "D"
								dDataInici := (cAliasSB1)->B1_DATREF
							Else
								dDataInici := stod((cAliasSB1)->B1_DATREF)
							EndIF
						EndIf
						If Empty(dDataInici)
							dDataInici := aAuxDesc[1][3]
						Endif
					Else
						//Atribuindo a penultima data de alteração a variavel dDataInici independente se houve alteracao ou não no mesmo dia
						dDataInici := aAuxDesc[2][3]
					Endif

					//O registro 0205 não será gerado caso dDataInici seja menor que dDataFinal, ou seja, os produto incluídos e alterados no último dia do mês,
					//pois o PVA acusa erro de validação, na data final não pode ser igual o último dia do mês, e a data inicial não pode ser maior que a data final
					//por este motivo irei processar da mesma maneira que o SPED Fiscal, o registro 0205 não será gerado quando incluído e alterado no último dia do mês de geração do arquivo.
					If dDataFinal <= oBloco0:getDtAte() .AND. dDataInici < dDataFinal

						aPar0205	:= {}
						aAdd(aPar0205,cDescProd)
						aAdd(aPar0205,dDataInici)
						aAdd(aPar0205,dDataFinal)
						aAdd(aPar0205,(cAliasSB1)->B1_CODANT)

						Proc0205(cGrupo0200,oBloco0, aPar0205)


					EndIf
				EndIf
			EndIf
		EndIf

		IF !oBloco0:getMT()
			oTabela:GrvReg(oBloco0:get0200())

			oTabela:GrvReg(oBloco0:get0205())
			oBloco0:cls0205()
		EndIF

	EndIF

Return cProd

 //-------------------------------------------------------------------
/*/{Protheus.doc} Reg0190()
@description Função para geração do registro 0190

@author Erick G. Dias
@since 09/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function Reg0190(cChave0140, cUnid, oBloco0, oTabela)

	If !oTabela:ProCad('02', cUnid, cChave0140) //02 = registro 0190
		IF SAH->(MsSeek (xFilial ("SAH")+cUnid))
			Proc0190(cChave0140,oBloco0, {cUnid,SAH->AH_DESCPO})
			IF !oBloco0:getMT()
				oTabela:GrvReg(oBloco0:get0190())
			EndIF


		EndIF
	EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} RegD350()
@description Função que irá gerar registro D350 a partir do ponto de entrada
SPDPISTR

@author Erick G. Dias
@since 09/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function RegD350 (cChaveD010,oBlocoD,oBloco0,oBloco1, oTabela,lConcFil,nRelacFil)

	Local aSPDPisTR	:= {}
	Local nCont		:= 	0
	Local cConta		:= ''
	Local nPosD359	:= 	0

	aSPDPisTR := ExecBlock("SPDPISTR",.F.,.F.,{nRelacFil,mv_par01,mv_par02})

	If Len(aSPDPisTR)>0 .AND. !Empty(aSPDPisTR[1])
	//Laço para geração do registro D350
		For nCont:=1 to Len(aSPDPisTR[01])

		//posição 23 representa conta contábil
			If ValType(aSPDPisTR[1,nCont,23])=="A"
				cConta	:= FSA0080500('', oBloco0,oTabela,lConcFil,aSPDPisTR[1,nCont,23,6],,.F.,aSPDPisTR[1,nCont,23])
			Else
				cConta:= FSA0080500('', oBloco0,oTabela,lConcFil,aSPDPisTR[1,nCont,23],,.F.)
			EndIF

		//gera registro D350 com informações do ponto de entrada
			ProcD350(cChaveD010, oBlocoD, aSPDPisTR[1,nCont],cConta)

		//gera informações do processo referenciado
			If Len(aSPDPisTR)>1
				nPosD359 := aScan (aSPDPisTR[2], {|aX| aX[1] == nCont })
				If nPosD359 > 0
					ProcRefC(oBlocoD:getGrupo(), oBlocoD, 'D359', aSPDPisTR[2,nPosD359,3], aSPDPisTR[2,nPosD359,4] )
				EndIF
			EndIF

		Next nCont

	//Gera 1010 através das informações reotornadas pelo PE
		If Len(aSPDPisTR)>2 .AND. !Empty(aSPDPisTR[3])
			For nCont:=1 to Len(aSPDPisTR[3])
				Proc1010('1001000000001', oBloco1, '',aSPDPisTR[3,nCont])
			Next nCont
		EndIf

	//Gera 1020 através das informações reotornadas pelo PE
		If Len(aSPDPisTR)>3 .AND. !Empty(aSPDPisTR[4])
			For nCont:=1 to Len(aSPDPisTR[4])
				Proc1020('1001000000001', oBloco1, '',aSPDPisTR[4,nCont])
			Next nCont
		EndIf

		oTabela:GrvReg(oBlocoD:getD350())
		oTabela:GrvReg(oBlocoD:getD359())
		oBlocoD:clsD350()

	EndIf

Return

 //-------------------------------------------------------------------
/*/{Protheus.doc} CodMunPart()
@description Função para retornar o códiugo do município do participante
			   Esta função ira retornar o código do município com 7 dígitos,
			   conforme layout da EFD.
@param cCodPais,String, Código do Pais do participantes
@param cEstado,String, Estado do participante
@param cCodMun,String, Código de município do cadastro do participante
@author Erick G. Dias
@since 09/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function CodMunPart(cCodPais, cEstado,cCodMun)

	Local cCodRet	:= ''

	If (!'01058'$cCodPais .And. AllTrim(cCodPais) <> '') .OR.  cEstado == 'EX'
		cCodRet	:= '9999999'
	ElseIF Len(AllTrim(cCodMun)) <= 5
		cCodRet	:= UfCodIBGE(cEstado) + cCodMun
	Else
		cCodRet	:= cCodMun
	EndIF

Return cCodRet


//-------------------------------------------------------------------
/*/{Protheus.doc} ProcCancel()
@description Função que irá fechar as tabelas temporárias abertas quando
			  o cancelamento for acionado pelo usuário.
@param lCancel,Lógico, Variável que indica que houve cancelamento
@param oTabela,Objeto,Objeto da Classe ARRAYTOTMP
@author Erick G. Dias
@since 12/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------

Static Function ProcCancel(lCancel,oTabela)

	lCancel:=.T.
	oTabela:DelTabela()
	oTabela:DelTabCad()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcCache()
@description Função para fazer verificação de FieldPos, getnewpar , Existbloc
			   e aliasindic, para manter em cache e não fazer estas verificações
			   mais de uma vez no processamento.
@author Erick G. Dias
@since 12/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function ProcCache()

//Verificação de parâmetros - SX6
	aParSX6	:= ProcSX6()
//Verificação de Campos SX3
	aParSX3 	:= ProcSX3()
//Verificação de Ponto de entrada
	aParPE 	:= ProcPE()
//Verifica se o novo pergunte existe no SX1
	lMvPar23:= !IsInCallStack('EXTFISXTAF') .AND. FSA008X1("FSA008","MV_PAR23")

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcSX6()
@description Função que irá fazer GetNewPar nos parâmetros
			   Quando incluir novo parâmetro na lista abaixo, não esquece de
			   atualizar a lista de DEFINE dos parâmetros
@author Erick G. Dias
@since 12/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function ProcSX6()
	Local aRet	:= {}
	Local nCont	:= 0

	Local aParam 	:= {	{'MV_SPEDNAT'		,	 ''	   		},;		//01
	{'MV_EASY'   		,   ''        },;		//02
	{'MV_SPDIFC'  	,   0         },;		//03
	{'MV_RATPROP'   	,   .F.       },;		//04
	{'MV_M996TPR'   	,   1         },;		//05
	{'MV_ICMPAD'   	,   18        },;		//06
	{'MV_1DUPREF'		,	''    		},; 	//07
	{'MV_2DUPREF'		,	''    		},;	 	//08
	{'MV_C140TIT'		,	''			},;		//09
	{"MV_STFRETE"		,	.F.   		},;	 	//10
	{"MV_ESTTELE"		,	.F.   		},;	 	//11
	{"MV_SPDCGPC"		,	.T.   		},;	 	//12
	{"MV_CF3ENTR"		,	.T.   		},;	 	//13
	{"MV_CONTZF"		,	.F.   		},;	 	//14
	{"MV_NFCOMPL"		,	.T.   		},;	 	//15
	{"MV_QTAEC"		,	0   		},;	 	//16
	{"MV_VALEXCL"		,	.F.   		},;	 	//17
	{"MV_HISTTAB"		,	.F.   		},;	 	//18
	{"MV_PISCOFP"		,	.F.   		},;	 	//19
	{"MV_COFLSPD"		,	.T.   		},;	 	//20
	{"MV_SPEDCSC"		,	.F.   		},;	 	//21
	{"MV_SKPENC"		,	.F.   		},;	 	//22
	{"MV_STNIEUF"		,	.F.   		},;	 	//23
	{"MV_STUF"			,	''   		},; 	//24
	{"MV_STUFS"			,	''   		},;	 	//25
	{"MV_RESF3FT"		,	.F.	    	},;  	//26
	{"MV_C100CAN"		,	.T.			},;  	//27
	{"MV_AGR1900"		,	.F.	    	},;  	//28
	{"MV_DFSRVAC"		,	.F.			},;   	//29
	{"MV_DEDBPIS"		,	''			},;  	//30
	{"MV_DEDBCOF"		,	''			},;   	//31
	{"MV_PRICMS"	   	,	''			},;   	//32
	{"MV_EFDSERI"		,   .F.			},;     //33
	{"MV_ICMDSDT"		, StoD("  /  /   ")},;  //34
	{"MV_SPEDCOP"		,   .F.			}}		//35

//Verifica se parâmetro existe.
	For nCont:=1 to Len(aParam)
		aAdd(aRet , GetNewPar((aParam[nCont,1]),aParam[nCont,2])  )
	Next nX

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcSX3()
@description Função que irá verificar se o campos existe
			   Quando incluir novo parâmetro na lista abaixo, não esquecer de
			   atualizar a lista de DEFINE dos campos
@author Erick G. Dias
@since 12/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function ProcSX3()

	Local nX		:= 0
	Local aAlias	:= {}
	Local aRet	:= {}
	Local aCpo := 	{{"SF1"	,"F1_MENNOTA"},;	//01
	{"SF2"		,"F2_MENNOTA"},;				//02
	{"SA1"		,"A1_SUFRAMA"},;				//03
	{"SA2"		,"A2_SUFRAMA"},;				//04
	{"SA1"		,"A1_ENDNOT"},;					//05
	{"SA2"		,"A2_ENDNOT"},;					//06
	{"SFT"		,"FT_SERSAT"},;					//07
	{"CF4"		,"CF4_FLORIG"},;				//08
	{"CL4"		,"CL4_IDCLA"},;					//09
	{"CL2"		,"CL2_ALIAS"},;					//10
	{"SF1"		,"F1_DTCPISS"},;				//11
	{"SF2"		,"F2_DTESERV"},;				//12
	{"SFT"		,"FT_CLIDVMC"},;				//13
	{"SFT"		,"FT_TES"},;					//14
	{"CL2"		,"CL2_CLIFOR"},;				//15
	{"CL2"		,"CL2_LOJA"},;					//16
	{"SF1"		,"F1_SUBSERI"},;				//17
	{"CKS"		,"CKS_AJBCA"},;					//18
	{"CKS"		,"CKS_AJBCR"},;					//19
	{"CKS"		,"CKS_BCAJUS"},;                //20
	{"SA2"		,"A2_DEDBSPC"},;     			//21
	{"CCF"      ,"CCF_TRIB"},;					//22
	{"SFV"      ,"FV_RESSA"},;					//23 
	{"SFV"      ,"FV_RESSA"},;					//24 
	{"SFV"      ,"FV_RESRET"},;				    //25 
	{"SFW"      ,"FW_RESSA"},;					//26 
	{"SFW"      ,"FW_RESSA"},;					//27 
	{"SFW"      ,"FW_RESRET"},;					//28 
	{"SF1"      ,"F1_DEVMERC"},;				//29
	{"SA2"      ,"A2_CPFRUR"},;					//30 
	{"SA2"      ,"A2_INDRUR"}}					//31 


	For nX := 1 to Len(aCpo)
		nPos := aScan( aAlias , {|x| x[1] == aCpo[nX,01] } )
		If nPos == 0
			aAdd( aAlias , { aCpo[nX,01] , AliasIndic(aCpo[nX,01]) } )
			nPos := Len(aAlias)
		EndIf
		aAdd(aRet , IIf( aAlias[nPos,02] .And. (aCpo[nX,01])->(FieldPos(aCpo[nX,02])) > 0 , .T. , .F. ) )
	Next nX

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcPE()
@description Função que irá verificar existe ponto de entrada no RPO.
			   Quando incluir novo parâmetro na lista abaixo, não esquecer de
			   atualizar a lista de DEFINE de Ponto de entrada
@author Erick G. Dias
@since 12/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function ProcPE()

	Local aRet := { ExistBlock("SPDIMP"),;	// 01
	ExistBlock("SPDPISIC"),;	//02
	ExistBlock("SPDPISTR"),;	//03
	ExistBlock("SPDPC0140"),;	//04
	ExistBlock("SPDPCIMOB"),;	//05
	ExistBlock("SPDPC1800"),;	//06
	ExistBlock("SPDPIS07"),;	//07
	ExistBlock("SPDPIS05"),;	//08
	ExistBlock("SPDPIS08"),;	//09
	ExistBlock("SPDFIS03"),;	//10
	ExistBlock("SPDFIS001"),;	//11
	ExistBlock("SPDFIS04"),;	//12
	ExistBlock("SPDPIS06"),;	//13
	ExistBlock("SPEDPROD"),;	//14
	ExistBlock("SPDFIS02"),;	//15
	ExistBlock("SPED0150"),;	//16
	ExistBlock("SPED0205"),;	//17
	ExistBlock("SPED0035"),;	//18
	ExistBlock("SPD1900A"),;	//19
	ExistBlock("SPDRA170") }	//20
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} IndPagToE2()
@description Função que irá verificar tóítulo a pagar do documento fiscal,
			  para verificar se existem parcelas, para definir se  pagamento
			  será a vista ou parcelado, ou ainda se não possui nenhum título
			  gerado.
			  É necessário ir até o título, pois através da condição de pagamento
			  não garante a informação, pois pode ser alterada. No título
			  também não existe nenhum campo que definie sse é a vista ou não.
@param	cAliasSft, Query,Alias da query do documento fiscal.
@return	nCont,integer,Retorna a quantidade de títulos encontrados.
@author Erick G. Dias
@since 12/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function IndPagToE2(cAliasSFT,dDataIni)

	Local nTamSE2   := TamSx3("E2_PREFIXO")[1]
    Local clPrefix	:= ''
	Local c2Dupref	:= aParSX6[MV_2DUPREF]
	Local cTipoTit	:= aParSX6[MV_C140TIT]
	Local nCont		:= 0
	Local cRet		:= '2'//Outros
	Local lTit      := .F.

    Local cSlctSFT 	:= ""
	Local cFrom		:= ""
	Local cFiltro 	:= ""
	Local cAliasSE2	:= ""

	If !Empty(Alltrim(c2Dupref)) //Se MV_2DUPREF preenchido considera F2_PREFIXO para chegar no título, senão F2_SERIE.
		If !((cAliasSFT)->FT_TIPOMOV == "E" .And. (cAliasSFT)->FT_TIPO == "D")			
			clPrefix := PadR((cAliasSFT)->F1_PREFIXO, nTamSE2)
			lTit := .T.
		Endif
	Else
		clPrefix := PadR((cAliasSFT)->FT_SERIE, nTamSE2)
	Endif

    If lTit
        cSlctSFT	:= " E2_VENCTO "
        cFrom		:= RetSqlName("SE2") + " SE2 "
        cFiltro		:= " SE2.E2_FILIAL 	= '" + xFilial("SE2") 			+ "' AND SE2.E2_FORNECE	= '" + (cAliasSFT)->FT_CLIEFOR	+ "' AND "
        cFiltro		+= " SE2.E2_LOJA	= '" + (cAliasSFT)->FT_LOJA		+ "' AND SE2.E2_PREFIXO	= '" + clPrefix					+ "' AND "
        cFiltro  	+= " SE2.E2_NUM		= '" + (cAliasSFT)->FT_NFISCAL	+ "' AND SUBSTRING(SE2.E2_TIPO, 1, 2) <> 'NC' 				 AND "
        cFiltro 	+= " LTRIM(RTRIM(SE2.E2_TIPO)) NOT IN " + FormatIn(MVTAXA+"|"+MVTXA+"|"+MVABATIM+"|"+cTipoTit, "|") 		+ "  AND "
        
        cSlctSFT 	:= '%' + cSlctSFT	+ '%'
        cFrom		:= '%' + cFrom		+ '%'
        cFiltro 	:= '%' + cFiltro	+ '%'
        cAliasSE2	:=	GetNextAlias()
        BeginSql Alias cAliasSE2
            COLUMN E2_VENCTO AS DATE	
            SELECT
            %Exp:cSlctSFT%
            FROM
            %Exp:cFrom%
            WHERE
            %Exp:cFiltro%
            SE2.%NotDel%
        EndSql

        DbSelectArea(cAliasSE2)
        COUNT To nCont        

        If nCont == 0 //Não existe título, então não da para definir se é avista ou a prazo, considera outros.
            cRet    := IIF(dDataIni >= CTOD("01/07/2012"), "2", "9")
        ElseIf nCont > 1 //Existe mais de um título, então é a prazo, não pode ser avista
            cRet	:= '1'
        ElseIf nCont == 1 //0 Se Existe somente 1 título e emissão é igual o vencimento - 1 Se Existe somente 1 título e emissão não é igual ao vencimento
			(cAliasSE2)->(DbGoTop())
            cRet 	:= IIF((cAliasSFT)->FT_EMISSAO == (cAliasSE2)->E2_VENCTO, '0', '1')
        EndIf
		(cAliasSE2)->(DbCloseArea())
    Else
        cRet	:= IIF(dDataIni >= CTOD("01/07/2012"), "2", "9")
    EndIf

Return  cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} IndPagToE1()
@description Função que irá verificar tóítulo a pagar do documento fiscal,
			  para verificar se existem parcelas, para definir se  recebimento
			  será a vista ou parcelado, ou ainda se não possui nenhum título
			  gerado.
			  É necessário ir até o título, pois através da condição de recebimento
			  não garante a informação, pois pode ser alterada. No título
			  também não existe nenhum campo que definie sse é a vista ou não.
@param	cAliasSft, Query,Alias da query do documento fiscal.
@return nCont,integer,Retorna a quantidade de títulos encontrados.
@author Erick G. Dias
@since 12/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function IndPagToE1(cAliasSFT,dDataIni)

	Local nTamSE1	:= TamSx3("E1_PREFIXO")[1]
	Local clPrefix	:= ''
	Local c1Dupref	:= aParSX6[MV_1DUPREF]
	Local cTipoTit	:= aParSX6[MV_C140TIT]
	Local nCont		:= 0
	Local cRet		:= '2'//Outros
	
	Local cSlctSFT 	:= ""
	Local cFrom		:= ""
	Local cFiltro 	:= ""
	Local cAliasSE1	:= ""
	
	clPrefix := IIF(!Empty(Alltrim(c1Dupref)), PadR((cAliasSFT)->F2_PREFIXO, nTamSE1), PadR((cAliasSFT)->FT_SERIE, nTamSE1)) //Se MV_2DUPREF preenchido considera F1_PREFIXO para título, senão F1_SERIE.
	
	cSlctSFT	:= " E1_VENCTO "
	cFrom		:= RetSqlName("SE1") + " SE1 "
	cFiltro		:= " SE1.E1_FILIAL 	= '" + xFilial("SE1") 			+ "' AND SE1.E1_CLIENTE	= '" + (cAliasSFT)->FT_CLIEFOR	+ "' AND "
	cFiltro		+= " SE1.E1_LOJA		= '" + (cAliasSFT)->FT_LOJA		+ "' AND SE1.E1_PREFIXO	= '" + clPrefix				+ "' AND "
	cFiltro  	+= " SE1.E1_NUM		= '" + (cAliasSFT)->FT_NFISCAL	+ "' AND SUBSTRING(SE1.E1_TIPO, 1, 2) <> 'NC' 				 AND "
	cFiltro 	+= " LTRIM(RTRIM(SE1.E1_TIPO)) NOT IN " + FormatIn(MVTAXA+"|"+MVTXA+"|"+MVABATIM+"|"+cTipoTit, "|") 		+ "  AND "
	
	cSlctSFT 	:= '%' + cSlctSFT	+ '%'
	cFrom		:= '%' + cFrom		+ '%'
	cFiltro 	:= '%' + cFiltro	+ '%'
	cAliasSE1	:=	GetNextAlias()
	BeginSql Alias cAliasSE1
		COLUMN E1_VENCTO AS DATE	
		SELECT
		%Exp:cSlctSFT%
		FROM
		%Exp:cFrom%
		WHERE
		%Exp:cFiltro%
		SE1.%NotDel%
	EndSql

	DbSelectArea(cAliasSE1)
	COUNT To nCont	

	If nCont == 0 //Não existe título, então não da para definir se é avista ou a prazo, considera outros.		
		cRet	:= Iif(dDataIni >= CTOD("01/07/2012"), "2", "9")
	ElseIf nCont > 1 //Existe mais de um título, então é a prazo, não pode ser avista
		cRet	:= '1'
	ElseIf nCont == 1 //0 Se Existe somente 1 título e emissão é igual o vencimento - 1 Se Existe somente 1 título e emissão não é igual ao vencimento
		(cAliasSE1)->(DbGoTop())
		cRet 	:= IIF((cAliasSFT)->FT_EMISSAO == (cAliasSE1)->E1_VENCTO, '0', '1')
	EndIf
	(cAliasSE1)->(DbCloseArea())
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA08PerTd

Função que irá definir período que cada thread deverá processar,
considerando a quantidade de threads e a data inicial e data final

@return array com data inicial e final que cada Thread deverá processar.
@author Erick G. Dias
@since 05/01/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Function FSA08PerTd(nThread,dtIni, dtFin)
Local nRestoDia	:= 0
Local nCont		:= 0
Local nDiasThread	:= 0
Local nDiaAux		:= 0
Local nTotDias	:=(dtFin - dtIni) + 1
Local dtI			:= dtIni
Local dtF			:= dtIni
Local aPer			:= {}

//VERIFICA SE NÚMERO DE THREAD É MENOR QUE O NÚMERO DE DIAS
If nThread <= nTotDias

	For nCont := 1 to nTotDias
		If mod(nTotDias,nThread) == 0
			//Divisão exata
			nDiasThread	:= nTotDias/nThread
			exit
		Else
			nRestoDia++
			nTotDias -=1
		EndIF

	Next nCont

Else
	//O NÚMERO DE THREAD SERÁ O MESMO QUE A QUANTIDADE DE DIA.
	nThread := nTotDias
	nDiasThread	:= 1
EndIF

For nCont := 1 to nThread

	nDiaAux := 0
	If nRestoDia > 0
		nDiaAux := 1
		nRestoDia -= 1
	EndIF
	dtI	:= dtI
	dtF	:= dtI + (nDiasThread-1) + nDiaAux

	AADD(aPer,{dtI,dtF,'0','0'})
	dtI	:=  dtF + 1

Next nCont

Return aPer

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA08Thrd

Função que irá gerenciar processamento das notas e cupom fiscal quando
em MultiThread
5
@version 11.80
/*/
//-------------------------------------------------------------------
Function FSA08Thrd(cSemaphore,cEmp,cFil,cJob,aNumeracao,lSM0Dup)

Local lErro		:= .F.
Local bError      := { |e| oError := e , Break(e) }
Local bErrorBlock := ErrorBlock( bError )
Local oError

Local uParm1, uParm2,uParm3, uParm4, uParm5, uParm6, uParm7,  uParm8,uParm9,uParm10,uParm11,uParm12,uParm13,uParm14,uParm15,uParm16,uParm17,uParm18,uParm19,uParm20,uParm21

//Abre o ambiente
RpcSetType(3)
RpcSetEnv(cEmp,cFil)

BEGIN SEQUENCE
	//TRY
		SM0->(DbGoTop ())
		SM0->(MsSeek (cEmp+cFil, .T.))
		cFilAnt := FWGETCODFILIAL
		ProcCache()
		nTimeOut := 	SuperGetMv("MV_SPDCTTO",,190000000) // Parametro que define TimeOut da Bark -> DEFAULT 190000000 = 52HORAS

		While !KillApp()
			PutGlbValue( cJob , "0" ) //Está pronta para processar
			GlbUnLock()
			If IPCWaitEx( cSemaphore, nTimeOut , 	@uParm1, @uParm2,@uParm3, @uParm4, @uParm5, @uParm6, @uParm7,  @uParm8, @uParm9, @uParm10,@uParm11,@uParm12,@uParm13,@uParm14,@uParm15,@uParm16,@uParm17,@uParm18,@uParm19,@uParm20,@uParm21)

				IF uParm10 == 'EXIT'
					PutGlbValue( cJob , "4" ) //Finalizada
					GlbUnLock()
					Exit
				EndIF
				PutGlbValue( cJob , "1" ) //Iniciou processamento
				GlbUnLock()
				ProcNF(@uParm1,uParm2,uParm3,uParm4,uParm5,uParm6,uParm7,uParm8,uParm9,uParm10,uParm11,uParm12,uParm13,uParm14,uParm15,uParm16,uParm17,uParm18,,,,,,uParm19,lSM0Dup)

				PutGlbValue( cJob , "2" ) //Finalizou processamento sem erros
				GlbUnLock()

				//Fico aguardando a chamada para atualizar o controle, e voltar ao estado de aguardando chamada
				While .T.
					If  GetGlbValue(cJob ) == '0'
						Exit
					EndIF
					Sleep(5000)
				EndDo

				//Volta esperar ser chamada novamente a thread
			Else
				// --------------------
				// Abandona por TimeOut
				PutGlbValue( cJob , "2" ) //Timeout
				GlbUnLock()
			  	//Exit
			EndIf
		End

  	 	//CATCH e as IdxException
		//ConOut( ProcName() + " " + Str(ProcLine()) + " Erro na geração no processamento - " +SM0->M0_CODFIL+" / "+AllTrim(SM0->M0_FILIAL) + " - "   + oError:Description )
  	//END TRY
	RECOVER

lErro	:= .T.

END SEQUENCE
ErrorBlock( bErrorBlock )

IF lErro
	PutGlbValue( cJob , '3' )//Ocorreu algum erro
	GlbUnLock()
	conout(CHR(10)+CHR(13))
	conout('########## - INÍCIO ERRO DE THREAD FISA008 - ##########')
	conout(CHR(10)+CHR(13))
	ConOut("Filial/Empresa " +SM0->M0_CODFIL+" / "+AllTrim(SM0->M0_FILIAL) + " - "   + oError:Description + '-' + oError:ErrorStack)
	conout(CHR(10)+CHR(13))
	conout('########## - FIM ERRO DE THREAD FISA008 - ##########')
	conout(CHR(10)+CHR(13))
	ProcLogAtu("ERRO",oError:Description,oError:ErrorStack,cJob)
EndIF

RpcClearEnv()
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA08Consol

Função que irá gerenciar processamento de consolidação dos registros
gerados pelas demais Threads
@version 11.80
/*/
//-------------------------------------------------------------------
Function FSA08Consol(cSemaphore,cEmp,cFil,cJob,aNumeracao,aTabela,lSM0Dup)

Local lErro		:= .F.
Local bError      := { |e| oError := e , Break(e) }
Local bErrorBlock := ErrorBlock( bError )
Local oError
Local uParm1 ,uParm2, uParm3, uParm4
Local oBloco0			:= EFDCBLOCO0():New()
Local oBloco1			:= EFDCBLOCO1():New()
Local oBlocoA			:= EFDCBLOCOA():New()
Local oBlocoC			:= EFDCBLOCOC():New()
Local oBlocoD			:= EFDCBLOCOD():New()
Local oBlocoF			:= EFDCBLOCOF():New()
Local oTabela			:=ARRAYTOTMP():New()
Local lProcNf			:= .F.
Local lProcCon		:= .F.
//Abre o ambiente
RpcSetType(3)
RpcSetEnv(cEmp,cFil)
SM0->(DbGoTop ())
SM0->(MsSeek (cEmp+cFil, .T.))	//Pego a filial mais proxima
cFilAnt := FWGETCODFILIAL

BEGIN SEQUENCE
	//TRY

		//Abre as tabelas temporárias
		oTabela:OpenTAbTmp(aTabela[1] ,aTabela[2] )
		DbSelectArea (aTabela[1])

		oTabela:OpenTAbCad(aTabela[3] ,aTabela[4] )


		oBloco0:setaNumer(aNumeracao)
		oBloco1:setaNumer(aNumeracao)
		oBlocoA:setaNumer(aNumeracao)
		oBlocoC:setaNumer(aNumeracao)
		oBlocoD:setaNumer(aNumeracao)
		oBlocoF:setaNumer(aNumeracao)

		nTimeOut := 	190000000

		While !KillApp()

			PutGlbValue( cJob , "01" ) //Disponível esperando para ser chamada
			GlbUnLock()

			If IPCWaitEx( cSemaphore,nTimeOut,@uParm1,@uParm2,@uParm3,@uParm4 )
				PutGlbValue( cJob , "02" ) //Processando, ainda não finalizado
				GlbUnLock()
				IF Valtype(uParm2) == 'C' .AND. uParm2 == 'FILIAL'

					oTabela:GrvReg(oBlocoC:getC180())
					oTabela:GrvReg(oBlocoC:getC181())
					oTabela:GrvReg(oBlocoC:getC185())
					oTabela:GrvReg(oBlocoC:getC188())

					oTabela:GrvReg(oBlocoC:getC190())
					oTabela:GrvReg(oBlocoC:getC191())
					oTabela:GrvReg(oBlocoC:getC195())
					oTabela:GrvReg(oBlocoC:getC198())
					oTabela:GrvReg(oBlocoC:getC199())


					oTabela:GrvReg(oBlocoC:getC380())
					oTabela:GrvReg(oBlocoC:getC381())
					oTabela:GrvReg(oBlocoC:getC385())

					oTabela:GrvReg(oBlocoC:getC600())
					oTabela:GrvReg(oBlocoC:getC601())
					oTabela:GrvReg(oBlocoC:getC605())
					oTabela:GrvReg(oBlocoC:getC609())

					oTabela:GrvReg(oBlocoC:getC860())
					oTabela:GrvReg(oBlocoC:getC870())
					oTabela:GrvReg(oBlocoC:getC880())
					oTabela:GrvReg(oBlocoC:getC890())

					oTabela:GrvReg(oBlocoD:getD300())
					oTabela:GrvReg(oBlocoD:getD350())

					oTabela:GrvReg(oBlocoD:getD600())
					oTabela:GrvReg(oBlocoD:getD601())
					oTabela:GrvReg(oBlocoD:getD605())
					oTabela:GrvReg(oBlocoD:getD609())

					oTabela:GrvReg(oBlocoF:getF550())
					oTabela:GrvReg(oBlocoF:getF559())

					oTabela:GrvReg(oBlocoF:getF560())
					oTabela:GrvReg(oBlocoF:getF569())

					oTabela:GrvReg(oBlocoC:getC490())
					oTabela:GrvReg(oBlocoC:getC491())
					oTabela:GrvReg(oBlocoC:getC495())
					oTabela:GrvReg(oBlocoC:getC499())

					oTabela:GrvReg(oBlocoC:getC400())
					oTabela:GrvReg(oBlocoC:getC405())
					oTabela:GrvReg(oBlocoC:getC481())
					oTabela:GrvReg(oBlocoC:getC485())
					oTabela:GrvReg(oBlocoC:getC489())

					If lSM0Dup
						oTabela:GrvReg(oBlocoA:getA100())
						oTabela:GrvReg(oBlocoA:getA110())
						oTabela:GrvReg(oBlocoA:getA111())
						oTabela:GrvReg(oBlocoA:getA120())
						oTabela:GrvReg(oBlocoA:getA170())
						
						oTabela:GrvReg(oBlocoC:getC100())
						oTabela:GrvReg(oBlocoC:getC110())
						oTabela:GrvReg(oBlocoC:getC111())
						oTabela:GrvReg(oBlocoC:getC120())
						oTabela:GrvReg(oBlocoC:getC170())
						oTabela:GrvReg(oBlocoC:getC175())
					Endif

					oBlocoC:clsC180()
					oBlocoC:clsC190()
					oBlocoC:clsC380()
					oBlocoC:clsC600()
					//oBlocoD:clsD200()
					oBlocoD:clsD300()
					oBlocoD:clsD600()
					oBlocoC:clsC860()
					oBlocoF:clsF550()
					oBlocoC:clsC400()
					oBlocoC:clsC490()
					
					If lSM0Dup
						oBlocoA:clsA100()
						oBlocoC:clsC100()
					Endif

					lProcNf	:= .F.
					lProcCon	:= .T.
					conout(cJob + ': Finalizou agrupamento dos arrays.')


				ElseIF Valtype(uParm2) == 'C' .AND. uParm2 == 'EXIT'
					//Consolida Filiais apos processar todas as Threads e Filiais
					If ValType(oBlocoD)=="O"
						oTabela:GrvReg(oBlocoD:getD200())
						oTabela:GrvReg(oBlocoD:getD201())
						oTabela:GrvReg(oBlocoD:getD205())
						oTabela:GrvReg(oBlocoD:getD209())
						oBlocoD:clsD200()

						oTabela:GrvReg(oBloco1:get1900())
						oTabela:GrvReg(oBloco1:get1010(.T.))
						oTabela:GrvReg(oBloco1:get1011())

					EndiF
					(aTabela[1])->( dbCloseArea() ) //Fecha arquivo TRB
					PutGlbValue( cJob , "04" ) //Disponível esperando para ser chamada
					GlbUnLock()
					Exit
				Else
					conout(cJob + ': Iniciou consolidação dos arrays.')

					ConsolThrd(oBloco0,oBloco1,oBlocoA,oBlocoC,oBlocoD,oBlocoF,oTabela,uParm3,uParm4,uParm1,lSM0Dup)
					lProcNf	:= .T.
					lProcCon	:= .F.
					conout(cJob + ': Finalizou consolidação dos arrays.')
				EndIF

			Else
				// --------------------
				// Abandona por TimeOut
				PutGlbValue( cJob , "2" ) //Timeout
				GlbUnLock()
			  	Exit
			EndIf
		End

  	 	//CATCH e as IdxException
		//ConOut( ProcName() + " " + Str(ProcLine()) + " Erro na geração no processamento - " +SM0->M0_CODFIL+" / "+AllTrim(SM0->M0_FILIAL) + " - "   + oError:Description )
  	//END TRY
	RECOVER

lErro	:= .T.

END SEQUENCE
ErrorBlock( bErrorBlock )

IF lErro
	PutGlbValue( cJob , '03' )//Ocorreu algum erro
	GlbUnLock()
	conout(CHR(10)+CHR(13))
	conout('########## - INÍCIO ERRO DE THREAD FISA008 - ##########')
	conout(CHR(10)+CHR(13))
	ConOut("Filial/Empresa " +SM0->M0_CODFIL+" / "+AllTrim(SM0->M0_FILIAL) + " - "   + oError:Description + '-' + oError:ErrorStack)
	conout(CHR(10)+CHR(13))
	conout('########## - FIM ERRO DE THREAD FISA008 - ##########')
	conout(CHR(10)+CHR(13))
	ProcLogAtu("ERRO",oError:Description,oError:ErrorStack,cJob)
EndIF

RpcClearEnv()
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ConsolThrd

Objetivo desta função é de agrupar as informações processadas pelas Threads,
dos registros que são agrupados, e esta Thread que irá consolidar e gravar
os registros no banco quando as demais Threads finalizarem o processamento
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function ConsolThrd(oBloco0,oBloco1,oBlocoA,oBlocoC,oBlocoD,oBlocoF,oTabela,cChave0140,cChave0001,aArray,lSM0Dup)

Local C180	:= 1
Local C181	:= 2
Local C185	:= 3
Local C188	:= 4
Local C190	:= 5
Local C191	:= 6
Local C195	:= 7
Local C198	:= 8
Local C199	:= 9
Local C380	:= 10
Local C381	:= 11
Local C385	:= 12
Local C600	:= 13
Local C601	:= 14
Local C605	:= 15
Local C609	:= 16
Local D200	:= 17
Local D201	:= 18
Local D205	:= 19
Local D209	:= 20
Local D300	:= 21
Local D309	:= 22
Local D600	:= 23
Local D601	:= 24
Local D605	:= 25
Local D609	:= 26
Local F550	:= 27
Local F559	:= 28
Local F560	:= 29
Local F569	:= 30
Local n1900:= 31
Local C490	:= 32
Local C491	:= 33
Local C495	:= 34
Local C499	:= 35
Local C400	:= 36
Local C405	:= 37
Local C481	:= 38
Local C485	:= 39
Local C489	:= 40

Local n0150	:= 41
Local n0190	:= 42
Local n0200	:= 43
Local n0206	:= 44
Local n0208	:= 45
Local n0400	:= 46
Local n0450	:= 47
Local n0500	:= 48
Local n0600	:= 49
Local n0205	:= 50
Local nC860 := 51
Local nC870 := 52
Local nC880 := 53
Local nC890 := 54
Local nD350 := 55
Local nD359 := 56
Local n1010 := 57
Local n1011 := 58

Local A100 	:= 59
Local A110 	:= 60
Local A111 	:= 61
Local A120 	:= 62
Local A170 	:= 63
	
Local C100 	:= 64
Local C110 	:= 65
Local C111 	:= 66
Local C120 	:= 67
Local C170 	:= 68
Local C175 	:= 69

Local nContPai	:=1
Local nContFilho	:=1


Local nConFilho2	:=1

Local cChvPaiAnt	:= ''
Local cChvPaiNov	:= ''

Local cPaiAnt2	:= ''
Local cPaiNov2	:= ''
Local cCod			:= ''
Local aPar			:= {}

Local nContA170	:= 0
Local nContC170	:= 0

//Processamento da família do C180
If len(aArray) >0
	//-------------------------------------------------------------------
	//Agrupa registro da família C180
	//-------------------------------------------------------------------
	For nContPai	:= 1 To Len(aArray[C180])
		cChvPaiAnt	:= aArray[C180][nContPai][1]

		//Processa C180 atrvés da classe
		cChvPaiNov	:= AgrpC180(oBlocoC,aArray[C180][nContPai])


		//Processa registro filho C181
		For  nContFilho	:= 1 to Len(aArray[C181])
			IF cChvPaiAnt == aArray[C181][nContFilho][1]
 				AgrpC181(oBlocoC,aArray[C181][nContFilho],cChvPaiNov)
			EndIF

		Next nContFilho

		//Processa registro filho C185
		For  nContFilho	:= 1 to Len(aArray[C185])
			IF cChvPaiAnt == aArray[C185][nContFilho][1]
 				AgrpC185(oBlocoC,aArray[C185][nContFilho],cChvPaiNov)
			EndIF

		Next nContFilho

		//Processa registro filho C188
		For  nContFilho	:= 1 to Len(aArray[C188])
			IF cChvPaiAnt == aArray[C188][nContFilho][1]
 				AgrpProcRf(oBlocoC,aArray[C188][nContFilho],cChvPaiNov,'C188')
			EndIF

		Next nContFilho

	Next nContPai


	//-------------------------------------------------------------------
	//Agrupa registro da família C190
	//-------------------------------------------------------------------
	For nContPai	:= 1 To Len(aArray[C190])
		cChvPaiAnt	:= aArray[C190][nContPai][1]


		//Processa C190 atrvés da classe
		cChvPaiNov	:= AgrpC190(oBlocoC,aArray[C190][nContPai])


		//Processa registro filho C191
		For  nContFilho	:= 1 to Len(aArray[C191])
			IF cChvPaiAnt == aArray[C191][nContFilho][1]
 				AgrpC191(oBlocoC,aArray[C191][nContFilho],cChvPaiNov)
			EndIF

		Next nContFilho

		//Processa registro filho C195
		For  nContFilho	:= 1 to Len(aArray[C195])
			IF cChvPaiAnt == aArray[C195][nContFilho][1]
 				AgrpC195(oBlocoC,aArray[C195][nContFilho],cChvPaiNov)
			EndIF

		Next nContFilho

		//Processa registro filho C198
		For  nContFilho	:= 1 to Len(aArray[C198])
			IF cChvPaiAnt == aArray[C198][nContFilho][1]
 				AgrpProcRf(oBlocoC,aArray[C198][nContFilho],cChvPaiNov,'C198')
			EndIF

		Next nContFilho

		//Processa registro filho C199
		For  nContFilho	:= 1 to Len(aArray[C199])
			IF cChvPaiAnt == aArray[C199][nContFilho][1]
 				AgrpC199(oBlocoC,aArray[C199][nContFilho],cChvPaiNov)
			EndIF

		Next nContFilho


	Next nContPai

	//-------------------------------------------------------------------
	//Agrupa registro da família C380
	//-------------------------------------------------------------------

	For nContPai	:= 1 To Len(aArray[C380])
		cChvPaiAnt	:= aArray[C380][nContPai][1]


		//Processa C380 atrvés da classe
		cChvPaiNov	:= AgrpC380(oBlocoC,aArray[C380][nContPai])


		//Processa registro filho C381
		For  nContFilho	:= 1 to Len(aArray[C381])
			IF cChvPaiAnt == SubStr(aArray[C381][nContFilho][1],1,Len(cChvPaiAnt))
 				AgrpC381(oBlocoC,aArray[C381][nContFilho],cChvPaiNov)
			EndIF

		Next nContFilho

		//Processa registro filho C385
		For  nContFilho	:= 1 to Len(aArray[C385])
			IF cChvPaiAnt == SubStr(aArray[C385][nContFilho][1],1,Len(cChvPaiAnt))
 				AgrpC385(oBlocoC,aArray[C385][nContFilho],cChvPaiNov)
			EndIF

		Next nContFilho


	Next nContPai


	//-------------------------------------------------------------------
	//Agrupa registro da família C600
	//-------------------------------------------------------------------
	For nContPai	:= 1 To Len(aArray[C600])
		cChvPaiAnt	:= aArray[C600][nContPai][1]

		//Processa C600 atrvés da classe
		cChvPaiNov	:= AgrpC600(oBlocoC,aArray[C600][nContPai])

		//Processa registro filho C601
		For  nContFilho	:= 1 to Len(aArray[C601])
			IF cChvPaiAnt == SubStr(aArray[C601][nContFilho][1],1,Len(cChvPaiAnt))
 				AgrpC601(oBlocoC,aArray[C601][nContFilho],cChvPaiNov)
			EndIF

		Next nContFilho

		//Processa registro filho C605
		For  nContFilho	:= 1 to Len(aArray[C605])
			IF cChvPaiAnt == SubStr(aArray[C605][nContFilho][1],1,Len(cChvPaiAnt))
 				AgrpC605(oBlocoC,aArray[C605][nContFilho],cChvPaiNov)
			EndIF

		Next nContFilho

		//Processa registro filho C609
		For  nContFilho	:= 1 to Len(aArray[C609])
			IF cChvPaiAnt == aArray[C609][nContFilho][1]
 				AgrpProcRf(oBlocoC,aArray[C609][nContFilho],cChvPaiNov,'C609')
			EndIF

		Next nContFilho


	Next nContPai

	//-------------------------------------------------------------------
	//Agrupa registro da família C860 - SAT
	//-------------------------------------------------------------------
	For nContPai	:= 1 To Len(aArray[nC860])
		cChvPaiAnt	:= aArray[nC860][nContPai][1]
		//Processa C860 atrvés da classe
		cChvPaiNov	:= AgrpC860(oBlocoC,aArray[nC860][nContPai])
		//Processa registro filho C870
		For  nContFilho	:= 1 to Len(aArray[nC870])
			IF cChvPaiAnt == SubStr(aArray[nC870][nContFilho][1],1,Len(cChvPaiAnt))
				AgrpC870(oBlocoC,aArray[nC870][nContFilho],cChvPaiNov)
			EndIF
		Next nContFilho
		//Processa registro filho C880
		For  nContFilho	:= 1 to Len(aArray[nC880])
			IF cChvPaiAnt == SubStr(aArray[nC880][nContFilho][1],1,Len(cChvPaiAnt))
				AgrpC880(oBlocoC,aArray[nC880][nContFilho],cChvPaiNov)
			EndIF
		Next nContFilho
		//Processa registro filho C890
		For  nContFilho	:= 1 to Len(aArray[nC890])
			IF cChvPaiAnt == aArray[nC890][nContFilho][1]
 				AgrpProcRf(oBlocoC,aArray[nC890][nContFilho],cChvPaiNov,'C890')
			EndIF

		Next nContFilho
	Next nContPai

	//-------------------------------------------------------------------
	//Agrupa registro da família D200
	//-------------------------------------------------------------------
	For nContPai	:= 1 To Len(aArray[D200])
		cChvPaiAnt	:= aArray[D200][nContPai][1]

		//Processa D200 atrvés da classe
		cChvPaiNov	:= AgrpD200(oBlocoD,aArray[D200][nContPai])

		//Processa registro filho D201
		For  nContFilho	:= 1 to Len(aArray[D201])
			IF cChvPaiAnt == SubStr(aArray[D201][nContFilho][1],1,Len(cChvPaiAnt))
 				AgrpD201(oBlocoD,aArray[D201][nContFilho],cChvPaiNov)
			EndIF

		Next nContFilho

		//Processa registro filho D205
		For  nContFilho	:= 1 to Len(aArray[D205])
			IF cChvPaiAnt == SubStr(aArray[D205][nContFilho][1],1,Len(cChvPaiAnt))
 				AgrpD205(oBlocoD,aArray[D205][nContFilho],cChvPaiNov)
			EndIF

		Next nContFilho

		//Processa registro filho D209
		For  nContFilho	:= 1 to Len(aArray[D209])
			IF cChvPaiAnt == aArray[D209][nContFilho][1]
 				AgrpProcRf(oBlocoD,aArray[D209][nContFilho],cChvPaiNov,'D209')
			EndIF

		Next nContFilho


	Next nContPai

	//-------------------------------------------------------------------
	//Agrupa registro da família D300
	//-------------------------------------------------------------------
	For nContPai	:= 1 To Len(aArray[D300])
		cChvPaiAnt	:= aArray[D300][nContPai][1]

		//Processa D300 atrvés da classe
		cChvPaiNov	:= AgrpD300(oBlocoD,aArray[D300][nContPai])

		//Processa registro filho D309
		For  nContFilho	:= 1 to Len(aArray[D309])
			IF cChvPaiAnt == aArray[D309][nContFilho][1]
 				AgrpProcRf(oBlocoD,aArray[D309][nContFilho],cChvPaiNov,'D309')
			EndIF

		Next nContFilho


	Next nContPai

	//-------------------------------------------------------------------
	//Agrupa registro da família D350
	//-------------------------------------------------------------------
	For nContPai	:= 1 To Len(aArray[nD350])
		cChvPaiAnt	:= aArray[nD350][nContPai][1]

		//Processa D350 atrvés da classe
		cChvPaiNov	:= AgrpD350(oBlocoD,aArray[nD350][nContPai])

		//Processa registro filho D309
		For  nContFilho	:= 1 to Len(aArray[nD359])
			IF cChvPaiAnt == aArray[nD359][nContFilho][1]
 				AgrpProcRf(oBlocoD,aArray[nD359][nContFilho],cChvPaiNov,'D359')
			EndIF
		Next nContFilho
	Next nContPai


	//-------------------------------------------------------------------
	//Agrupa registro da família D600
	//-------------------------------------------------------------------
	For nContPai	:= 1 To Len(aArray[D600])
		cChvPaiAnt	:= aArray[D600][nContPai][1]

		//Processa D600 atrvés da classe
		cChvPaiNov	:= AgrpD600(oBlocoD,aArray[D600][nContPai])

		//Processa registro filho D601
		For  nContFilho	:= 1 to Len(aArray[D601])
			IF cChvPaiAnt == SubStr(aArray[D601][nContFilho][1],1,Len(cChvPaiAnt))
 				AgrpD601(oBlocoD,aArray[D601][nContFilho],cChvPaiNov)
			EndIF

		Next nContFilho

		//Processa registro filho D605
		For  nContFilho	:= 1 to Len(aArray[D605])
			IF cChvPaiAnt == SubStr(aArray[D605][nContFilho][1],1,Len(cChvPaiAnt))
 				AgrpD605(oBlocoD,aArray[D605][nContFilho],cChvPaiNov)
			EndIF

		Next nContFilho

		//Processa registro filho D609
		For  nContFilho	:= 1 to Len(aArray[D609])
			IF cChvPaiAnt == aArray[D609][nContFilho][1]
 				AgrpProcRf(oBlocoD,aArray[D609][nContFilho],cChvPaiNov,'D609')
			EndIF

		Next nContFilho


	Next nContPai

	//-------------------------------------------------------------------
	//Agrupa registro da família F550
	//-------------------------------------------------------------------
	For nContPai	:= 1 To Len(aArray[F550])
		cChvPaiAnt	:= aArray[F550][nContPai][1]

		//Processa F550 atrvés da classe
		cChvPaiNov	:= AgrpF55X(oBlocoF,aArray[F550][nContPai],'F550')


		//Processa registro filho F559
		For  nContFilho	:= 1 to Len(aArray[F559])
			IF cChvPaiAnt == aArray[F559][nContFilho][1]
 				AgrpProcRf(oBlocoF,aArray[F559][nContFilho],cChvPaiNov,'F559')
			EndIF

		Next nContFilho


	Next nContPai

	//-------------------------------------------------------------------
	//Agrupa registro da família F560
	//-------------------------------------------------------------------
	For nContPai	:= 1 To Len(aArray[F560])
		cChvPaiAnt	:= aArray[F560][nContPai][1]

		//Processa F560 atrvés da classe
		cChvPaiNov	:= AgrpF55X(oBlocoF,aArray[F560][nContPai],'F560')


		//Processa registro filho F569
		For  nContFilho	:= 1 to Len(aArray[F569])
			IF cChvPaiAnt == aArray[F569][nContFilho][1]
 				AgrpProcRf(oBlocoF,aArray[F569][nContFilho],cChvPaiNov,'F569')
			EndIF

		Next nContFilho


	Next nContPai


	//-------------------------------------------------------------------
	//Agrupa registro 1900
	//-------------------------------------------------------------------
	For nContPai	:= 1 To Len(aArray[n1900])

		Agrp1900(oBloco1,aArray[n1900][nContPai])

	Next nContPai

	//-------------------------------------------------------------------
	//Agrupa registro da família C490
	//-------------------------------------------------------------------
	For nContPai	:= 1 To Len(aArray[C490])
		cChvPaiAnt	:= aArray[C490][nContPai][1]

		//Processa C490 atrvés da classe
		cChvPaiNov	:= AgrpC490(oBlocoC,aArray[C490][nContPai])

		//Processa registro filho C491
		For  nContFilho	:= 1 to Len(aArray[C491])
			IF cChvPaiAnt == SubStr(aArray[C491][nContFilho][1],1,Len(cChvPaiAnt))
 				AgrpC491(oBlocoC,aArray[C491][nContFilho],cChvPaiNov)
			EndIF

		Next nContFilho

		//Processa registro filho C495
		For  nContFilho	:= 1 to Len(aArray[C495])
			IF cChvPaiAnt == SubStr(aArray[C495][nContFilho][1],1,Len(cChvPaiAnt))
 				AgrpC495(oBlocoC,aArray[C495][nContFilho],cChvPaiNov)
			EndIF

		Next nContFilho

		//Processa registro filho C499
		For  nContFilho	:= 1 to Len(aArray[C499])
			IF cChvPaiAnt == aArray[C499][nContFilho][1]
 				AgrpProcRf(oBlocoC,aArray[C499][nContFilho],cChvPaiNov,'C499')
			EndIF

		Next nContFilho

	Next nContPai

	//-------------------------------------------------------------------
	//Agrupa registro da família C400
	//-------------------------------------------------------------------
	For nContPai	:= 1 To Len(aArray[C400])
		cChvPaiAnt	:= aArray[C400][nContPai][1]

		//Processa C490 atrvés da classe
		cChvPaiNov	:= AgrpC400(oBlocoC,aArray[C400][nContPai])

		//Processa registro filho C405
		For  nContFilho	:= 1 to Len(aArray[C405])
			IF cChvPaiAnt == SubStr(aArray[C405][nContFilho][1],1,Len(cChvPaiAnt))

 				cPaiAnt2	:= aArray[C405][nContFilho][1]

 				cPaiNov2	:= AgrpC405(oBlocoC,aArray[C405][nContFilho],cChvPaiNov)

 				//Processa registro filho C481
				For  nConFilho2	:= 1 to Len(aArray[C481])
					IF cPaiAnt2 == SubStr(aArray[C481][nConFilho2][1],1,Len(cPaiAnt2))
		 				AgrpC481(oBlocoC,aArray[C481][nConFilho2],cPaiNov2)
					EndIF

				Next nConFilho2

				//Processa registro filho C485
				For  nConFilho2	:= 1 to Len(aArray[C485])
					IF cPaiAnt2 == SubStr(aArray[C485][nConFilho2][1],1,Len(cPaiAnt2))
		 				AgrpC485(oBlocoC,aArray[C485][nConFilho2],cPaiNov2)
					EndIF

				Next nConFilho2

				//Processa registro filho C489
				For  nConFilho2	:= 1 to Len(aArray[C489])
					IF cPaiAnt2 == aArray[C489][nConFilho2][1]
		 				AgrpProcRf(oBlocoC,aArray[C489][nConFilho2],cPaiNov2,'C489')
					EndIF

				Next nConFilho2

			EndIF

		Next nContFilho

	Next nContPai

	//-------------------------------------------------------------------
	//Agrupa registro 0150
	//-------------------------------------------------------------------
	For nContPai	:= 1 To Len(aArray[n0150])

		cCod	:= aArray[n0150][nContPai][3]

		If !oTabela:ProCad('01', cCod, cChave0140) //01 = Registro 0150
			aPar	:= {}

			aAdd(aPar,aArray[n0150][nContPai][1] )		//relacao
			aAdd(aPar,aArray[n0150][nContPai][2] )		//0150
			aAdd(aPar,aArray[n0150][nContPai][3] )		//01-COD_PART
			aAdd(aPar,aArray[n0150][nContPai][4] )			//02-NOME
			aAdd(aPar,aArray[n0150][nContPai][5] )		//03-COD_PAIS
			aAdd(aPar,aArray[n0150][nContPai][6] )			//04-CNPJ
			aAdd(aPar,aArray[n0150][nContPai][7] )			//05-CPF
			aAdd(aPar,aArray[n0150][nContPai][8] )			//06-IE
			aAdd(aPar,aArray[n0150][nContPai][9] )		//07-COD_MUN
			aAdd(aPar,aArray[n0150][nContPai][10] )		//08-SUFRAMA
			aAdd(aPar,aArray[n0150][nContPai][11] )			//09-END
			aAdd(aPar,aArray[n0150][nContPai][12] )			//10-NUM
			aAdd(aPar,aArray[n0150][nContPai][13] )			//11-COMPL
			aAdd(aPar,aArray[n0150][nContPai][14] )		//12-BAIRRO

			Proc0150(cChave0140,oBloco0, aPar)
			oTabela:GrvReg(oBloco0:get0150())

		EndIF

	Next nContPai

	//-------------------------------------------------------------------
	//Agrupa registro 0190
	//-------------------------------------------------------------------
	For nContPai	:= 1 To Len(aArray[n0190])

		cCod	:= aArray[n0190][nContPai][3]

		If !oTabela:ProCad('02', cCod, cChave0140) //02 = registro 0190

			Proc0190(cChave0140,oBloco0, {cCod,aArray[n0190][nContPai][4]})

			oTabela:GrvReg(oBloco0:get0190())

		EndIF

	Next nContPai

	//-------------------------------------------------------------------
	//Agrupa registro 0200
	//-------------------------------------------------------------------
	For nContPai	:= 1 To Len(aArray[n0200])

		cCod	:= aArray[n0200][nContPai][3]
		cChvPaiAnt	:=  aArray[n0200][nContPai][1]

		If !oTabela:ProCad('03', cCod, cChave0140)

			aPar	:= {}
			aAdd(aPar,aArray[n0200][nContPai][3])
			aAdd(aPar,aArray[n0200][nContPai][4])
			aAdd(aPar,aArray[n0200][nContPai][5])
			aAdd(aPar,aArray[n0200][nContPai][6])
			aAdd(aPar,aArray[n0200][nContPai][7])
			aAdd(aPar,aArray[n0200][nContPai][8])
			aAdd(aPar,aArray[n0200][nContPai][9])
			aAdd(aPar,aArray[n0200][nContPai][10])
			aAdd(aPar,aArray[n0200][nContPai][11])
			aAdd(aPar,aArray[n0200][nContPai][12])
			aAdd(aPar,aArray[n0200][nContPai][13])

			//Processa registro 0200
			Proc0200(cChave0140,oBloco0, aPar)
			cChvPaiNov	:= oBloco0:getGrupo()
			oTabela:GrvReg(oBloco0:get0200())


			//Processa registro filho 0205
			For  nContFilho	:= 1 to Len(aArray[N0205])
				IF cChvPaiAnt == SubStr(aArray[N0205][nContFilho][1],1,Len(cChvPaiAnt))
	 				//pROCESSA 0205
	 				//AgrpC495(oBlocoC,aArray[0205][nContFilho],cChvPaiNov)
				EndIF

			Next nContFilho

			//Processa registro filho 0206
			For  nContFilho	:= 1 to Len(aArray[N0206])
				IF cChvPaiAnt == SubStr(aArray[N0206][nContFilho][1],1,Len(cChvPaiAnt))

	 				Proc0206(cChvPaiNov,oBloco0, aArray[N0206][nContFilho][3] )
	 				oTabela:GrvReg(oBloco0:get0206())
				EndIF

			Next nContFilho

			//Processa registro filho 0208
			For  nContFilho	:= 1 to Len(aArray[N0208])
				IF cChvPaiAnt == SubStr(aArray[N0208][nContFilho][1],1,Len(cChvPaiAnt))

					Proc0208(cChvPaiNov,oBloco0, {aArray[N0208][nContFilho][3] ,aArray[N0208][nContFilho][4] ,aArray[N0208][nContFilho][5] })
					IF !oBloco0:getMT()
						oTabela:GrvReg(oBloco0:get0208())
					EndIF

				EndIF

			Next nContFilho


		EndIF

	Next nContPai

	//-------------------------------------------------------------------
	//Agrupa registro 0400
	//-------------------------------------------------------------------
	For nContPai	:= 1 To Len(aArray[n0400])

		cCod	:= aArray[n0400][nContPai][3]

		If !oTabela:ProCad('07', cCod, cChave0140) //Tipo 07 == 0400, passou código já concatenado com filial

			Proc0400(cChave0140,oBloco0, {cCod,aArray[n0400][nContPai][4] })

			oTabela:GrvReg(oBloco0:get0400())

		EndIF

	Next nContPai

	//-------------------------------------------------------------------
	//Agrupa registro 0450
	//-------------------------------------------------------------------
	For nContPai	:= 1 To Len(aArray[n0450])

		cCod	:= aArray[n0450][nContPai][3]

		If !oTabela:ProCad('08', cCod, cChave0140)
			Proc0450(cChave0140,oBloco0, {cCod,aArray[n0450][nContPai][4]})
		Endif

	Next nContPai

	iF Len(oBloco0:get0450()) > 0
		oTabela:GrvReg(oBloco0:get0450())
		oBloco0:cls0450()
	EndIf

	//-------------------------------------------------------------------
	//Agrupa registro 0500
	//-------------------------------------------------------------------
	For nContPai	:= 1 To Len(aArray[n0500])

		cCod	:= aArray[n0500][nContPai][7]

		If !oTabela:ProCad('09', cCod)

			aPar	:= {}
			aAdd(aPar,aArray[n0500][nContPai][3])		//02-DT_ALT
			aAdd(aPar,aArray[n0500][nContPai][4])		//03-COD_NAT_CC
			aAdd(aPar,aArray[n0500][nContPai][5])		//04-IND_CTA
			aAdd(aPar,aArray[n0500][nContPai][6])		//05-NIVEL
			aAdd(aPar,aArray[n0500][nContPai][7])		//06-COD_CTA
			aAdd(aPar,aArray[n0500][nContPai][8])		//07-NOME_CTA
			aAdd(aPar,aArray[n0500][nContPai][9])		//08-COD_CTA_REF
			aAdd(aPar,aArray[n0500][nContPai][10])		//09-CNPJ_EST

			Proc0500(cChave0001,oBloco0, aPar)

			oTabela:GrvReg(oBloco0:get0500())

		EndIF

	Next nContPai

	//-------------------------------------------------------------------
	//Agrupa registro 0600
	//-------------------------------------------------------------------
	For nContPai	:= 1 To Len(aArray[n0600])

		cCod	:= aArray[n0600][nContPai][4]

		If !oTabela:ProCad('10', cCod)

			aPar := {}
			aAdd(aPar,aArray[n0600][nContPai][3])		//02-DT_ALT
			aAdd(aPar,aArray[n0600][nContPai][4])		//03-COD_CCUSC
			aAdd(aPar,aArray[n0600][nContPai][5])		//04-CCUS

			Proc0600(cChave0001,oBloco0, aPar)

			oTabela:GrvReg(oBloco0:get0600())

		EndIF

	Next nContPai

	//Agrupa registro 1010
	For nContPai	:= 1 to Len(aArray[n1010])
		cChvPaiAnt	:= aArray[n1010][nContPai][1]

		aPar := {}
		Aadd(aPar,aArray[n1010][nContPai][2]) //REGISTRO
		Aadd(aPar,aArray[n1010][nContPai][3]) //CCF_NUMERO
		Aadd(aPar,aArray[n1010][nContPai][4]) //CCF_IDSEJU
		Aadd(aPar,aArray[n1010][nContPai][5]) //CCF_IDVARA
		Aadd(aPar,aArray[n1010][nContPai][6]) //CCF_NATJU
		Aadd(aPar,aArray[n1010][nContPai][7]) //CCF_DESCJU
		Aadd(aPar,aArray[n1010][nContPai][8]) //CCF_DTSENT

		Proc1010(aArray[n1010][nContPai][1], oBloco1, '', aPar)

		cChvPaiNov	:= oBloco1:getGrupo()

		//Processa registro filho F569
		For  nContFilho	:= 1 to Len(aArray[n1011])
			IF cChvPaiAnt == SubStr(aArray[n1011][nContFilho][1],1,Len(cChvPaiAnt))
				Agrp1011(oBloco1,aArray[n1011][nContFilho],cChvPaiNov)
			EndIF
		Next nContFilho

	Next nContPai

	If lSM0Dup
		//-------------------------------------------------------------------
		//Agrupa registro da família A100
		//-------------------------------------------------------------------
		For nContPai	:= 1 To Len(aArray[A100])
			cChvPaiAnt	:= aArray[A100][nContPai][1]

			//Processa A100 atrvés da classe
			cChvPaiNov	:= AgruA100(oBlocoA,aArray[A100][nContPai])


			//Processa registro filho A110
			For  nContFilho	:= 1 to Len(aArray[A110])
				IF cChvPaiAnt == SubStr(aArray[A110][nContFilho][1],1,len(cChvPaiAnt))
					AgruA110(oBlocoA,aArray[A110][nContFilho],cChvPaiNov)
				EndIF

			Next nContFilho

			//Processa registro filho A111
			For  nContFilho	:= 1 to Len(aArray[A111])
				IF cChvPaiAnt == aArray[A111][nContFilho][1]
					AgrpProcRf(oBlocoA,aArray[A111][nContFilho],cChvPaiNov,'A111')
				EndIF

			Next nContFilho

			//Processa registro filho A120
			For  nContFilho	:= 1 to Len(aArray[A120])
				IF cChvPaiAnt == SubStr(aArray[A120][nContFilho][1],1,len(cChvPaiAnt))
					AgruA120(oBlocoA,aArray[A120][nContFilho],cChvPaiNov)
				EndIF

			Next nContFilho

			//Processa registro filho A170
			nContA170:=0
			For  nContFilho	:= 1 to Len(aArray[A170])
				IF cChvPaiAnt == substr(aArray[A170][nContFilho][1],1,len(cChvPaiAnt))
					nContA170++
					AgruA170(oBlocoA,aArray[A170][nContFilho],cChvPaiNov,nContA170)
				EndIF

			Next nContFilho

		Next nContPai


		//-------------------------------------------------------------------
		//Agrupa registro da família C100
		//-------------------------------------------------------------------
		For nContPai	:= 1 To Len(aArray[C100])
			cChvPaiAnt	:= aArray[C100][nContPai][1]

			//Processa A100 atrvés da classe
			cChvPaiNov	:= AgruC100(oBlocoC,aArray[C100][nContPai])


			//Processa registro filho C110
			For  nContFilho	:= 1 to Len(aArray[C110])
				IF cChvPaiAnt == SubStr(aArray[C110][nContFilho][1],1,len(cChvPaiAnt))
					AgruC110(oBlocoC,aArray[C110][nContFilho],cChvPaiNov)
				EndIF

			Next nContFilho

			//Processa registro filho C111
			For  nContFilho	:= 1 to Len(aArray[C111])
				IF cChvPaiAnt == aArray[C111][nContFilho][1]
					AgrpProcRf(oBlocoC,aArray[C111][nContFilho],cChvPaiNov,'C111')
				EndIF

			Next nContFilho

			
			if !oBlocoC:getnSitDoc()$'02/03/04/05'

				//Processa registro filho C120
				For  nContFilho	:= 1 to Len(aArray[C120])
					IF cChvPaiAnt == SubStr(aArray[C120][nContFilho][1],1,len(cChvPaiAnt))
						AgruC120(oBlocoC,aArray[C120][nContFilho],cChvPaiNov)
					EndIF

				Next nContFilho

				//Processa registro filho C170
				nContC170:=0
				For  nContFilho	:= 1 to Len(aArray[C170])
					IF cChvPaiAnt == substr(aArray[C170][nContFilho][1],1,len(cChvPaiAnt))
						nContC170++
						AgruC170(oBlocoC,aArray[C170][nContFilho],cChvPaiNov,nContC170)
					EndIF

				Next nContFilho

				//Processa registro filho C175
				For  nContFilho	:= 1 to Len(aArray[C175])
					IF cChvPaiAnt == SubStr(aArray[C175][nContFilho][1],1,len(cChvPaiAnt))
						AgruC175(oBlocoC,aArray[C175][nContFilho],cChvPaiNov)
					EndIF

				Next nContFilho

			endif

		Next nContPai

	Endif

EndIF


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcNF

Esta Função é a responsável pro processar as notas fiscais e cupom fiscal
Essa função é chamada seja operação Com MuliThread ou sem MultiThread.

@version 11.80
/*/
//-------------------------------------------------------------------
Static Function ProcNF(nContIniNf,oTabela, dDataIni, dDataFim,c0140,;
						  lBlocACDF,lRgCmpCons,oProcess,aTabela,cJob,;
						  lConIndiv,cLivro,cSemaforo2,lGeraECF,nNumIni,;
						  aX010,aEmpresa,aDate,oBloco0,oBloco1,;
						  aNumeracao,lCancel,oBlocoD,cJobCon,lSM0Dup)


Local aProd				:= {}
Local nContFil			:= 0
Local lGera0150			:= .F.
Local lConcFil			:= aParSX6[MV_COFLSPD]
Local oApurEFD 			:= FISX001():New()
Local nICMPAD 			:= aParSX6[MV_ICMPAD]
Local cOpSemF			:= LeParSeq("MV_OPSEMF")
Local cFrom				:= ''
Local cSlctSFT			:= ''
Local cFiltro			:= ''
Local cOrderBy			:= ''
lOCAL cAliasSFT			:= ''
Local cEspecie			:= ''
Local cA010				:= ''
Local cC010				:= ''
Local cD010				:= ''
Local cF010				:= ''
Local cRelacPai			:= ''
Local cCodPart			:= ''
Local cIndPagto			:= ''
Local cFrete			:= ''
Local cInfCompl			:= ''
Local nRelacPai			:= ''
Local cChaveNf			:=	''
Local nNumItem			:= 0
Local cStMoto			:= .F.
Local cCodProd			:= ''
Local cDescrProd		:= ''
Local cCusto			:= ''
Local cConta			:= ''
Local cCodMun			:= ''
Local cEntSai			:=	''
Local nMovto			:= 0
Local nBasePis			:= 0
Local nBaseCof			:= 0
Local nAlqPis			:= 0
Local nAlqCof			:= 0
Local nPosNf			:= 0
Local nQtdNf			:= 0
Local cSituaDoc			:= ''
Local cClieFor			:= ''
Local aParCompl			:= {}
Local aParF550			:= {}
Local aParItem			:= {}
Local cCodNat			:=''
Local lSpedNat			:= aParSX6[MV_SPEDNAT]
Local lEasy				:= aParSX6[MV_EASY]  == 'S'
Local nSPDIFC			:= aParSX6[MV_SPDIFC]
Local cTipoTit			:= aParSX6[MV_C140TIT]
Local lSPDIMP			:= aParPE[SPDIMP]
Local lSPDPISIC			:= aParPE[SPDPISIC]
local lF1Mennota		:= aParSX3[FP_F1_MENNOTA]
local lF2Mennota		:= aParSX3[FP_F2_MENNOTA]
Local lMT				:= .F.
Local lProc1Item		:= .F.
Local aArrayCon			:= {}
Local aSpdFis02			:= {}
Local cUnid				:= ''
Local nQtde				:= 0
Local cMVESTADO			:= SuperGetMv("MV_ESTADO",,"")
Local cEletC100 		:= SuperGetMv("MV_EFDELET",,"")
Local lEletC100			:= .f.
Local lEnerEle			:= .F.
Local cCFOPEElet 		:= "125/225/325/525/625"
Local AREGNF 			:= {}
Local oBlocoA			:= EFDCBLOCOA():New()
Local oBlocoC			:= EFDCBLOCOC():New()
Local oBlocoF			:= EFDCBLOCOF():New()
Local lConjugada		:= .F.
Local aConjugada		:=	{.F.,.F.}	//Posicao 1 indica se a nota fiscal tem servico e a posicao 2 indica se a nota fiscal possui produto.
Local cChaveF3			:= ''
Local cChave			:= ''
Local cChaveRej			:= ''
Local ProcNf			:= .T.
Local aCFOPs			:= XFUNCFRec()
Local nValSt			:= 0
Local cMVSUBTRIB		:=	SpedPrSeq("MV_SUBTRI")
Local cMVCFE210			:=	LeParSeq("MV_CFE210","1410,1411,1414,1415,1660,1661,1662,2410,2411,2414,2415,2660,2661,2662")
Local nValExcluP		:= 0
Local nValExcluC		:= 0
Local nValPis			:= 0
Local nValCof			:= 0
Local cSitExt			:= ''
Local lSitDocCDT		:= .F.
Local lProcC100			:= .T.
Local lExtTAFContr		:= .F.
Local cDbType  	:= TCGetDB()
Local cFuncNull			:= ""
Local cDedbspc			:=  ''
Local nValICMS			:=  0
Local cDedbpis			:= ''
Local cDedbcof			:= ''
Local cTipoNf  			:= ''
Local cEspC500          := '06/28/29/' + Iif(Year(aDate[1]) >= 2020 , '66','') //A partir de 2020 o modelo 06 fará parte do registro C500 e filhos.
Local lTabCIE			:= AliasIndic("CIE") .AND. Year(aDate[1]) >= 2020
Local lIPIRB            := GetNewPar("MV_DIPIRB",.F.) 
Local lDSTRB 	        := GetNewPar("MV_DSTRB",.F.) 
Local nValipi           := 0
Local nVlrST            := 0 // Variavel para recuperar valor do ICMS ST para uso do parametro MV_DSTRB na composição do Registro F550	

Local aDadAtv			:= {.F., .F., ""}
Local lValidAtv			:= .F.

Local clPrefix			:= ''
Local cTitTipo			:= FormatIn(MVTAXA+"|"+MVTXA+"|"+MVABATIM+"|"+cTipoTit+"|NC", "|" )
Local cJoinSF3			:= ""
Local lIntGTP			:= FindFunction('GtpXFis') .And. GtpXFis(dDataIni, dDataFim)

Local lJSAtiv			:= .F.

Local cCD3VlForn		:= IIF( CD3->(FieldPos("CD3_VLFORN")) > 0 , " CD3.CD3_VLFORN, ", "")

DEFAULT aTabela			:= {}
Default oTabela			:= nil
Default oProcess 		:= FISProgress():New({||},'Processando arquivo da EFD Contribuições',lExtTAFContr)
DEfault cJob			:= ''
Default aX010			:= {}
DEfault aEmpresa		:= {}
DEFAULT cSemaforo2		:= ''
DEfault aDate			:= {}
Default oBloco0			:= EFDCBLOCO0():New()
Default oBloco1			:= EFDCBLOCO1():New()
Default oBlocoD			:= EFDCBLOCOD():New()
DEFAULT aNumeracao		:= {}
DEFAULT cJobCon			:= ""

If IsBlind()
	oProcess := Nil
EndIf

Do Case // Nome da funcao do banco de dados que substitui NULL por 0
	Case cDbType $ "DB2/POSTGRES"
		cFuncNull	:= "COALESCE"
	Case "ORACLE" $ cDbType
		cFuncNull	:= "NVL"
	Otherwise
		cFuncNull	:= "ISNULL"
EndCase

lEasy			:= SuperGetMv("MV_EASY",,.F.)	== 'S'
nICMPAD 		:= 	GetNewPar("MV_ICMPAD",18)

DbSelectArea ("CDG")
CDG->(DbSetOrder (1))

DbSelectArea ("CCE")
CCE->(DbSetOrder (1))

DbSelectArea ("CDT")
CDT->(DbSetOrder (1))


DbSelectArea ("CD5")
CD5->(DbSetOrder (4))


IniciaReg(@aNumeracao,nNumIni)

oBloco0:setaNumer(@aNumeracao)
oBloco1:setaNumer(@aNumeracao)
oBlocoA:setaNumer(@aNumeracao)
oBlocoC:setaNumer(@aNumeracao)
oBlocoD:setaNumer(@aNumeracao)
oBlocoF:setaNumer(@aNumeracao)

oBloco0:setDtDeAte(aDate[1],aDate[2])
oBlocoA:setDtDeAte(aDate[1],aDate[2])
oBlocoC:setDtDeAte(aDate[1],aDate[2])
oBlocoD:setDtDeAte(aDate[1],aDate[2])
oBlocoF:setDtDeAte(aDate[1],aDate[2])

IF Len(aTabela) > 0
	pergunte('FSA008',.T.)
	//Significa que está sendo processado via multithread
	oTabela	:=ARRAYTOTMP():New()
	//Cria tabela temporária

	oTabela:OpenTAbTmp(aTabela[1] ,aTabela[2] )
	DbSelectArea (aTabela[1])


	oTabela:CriaTabCad(cJob,'2') //DBF
	DbSelectArea (cJob)
	(cJob)->(DbSetOrder (1))


	//oTabela:OpenTAbCad(aTabela[3] ,aTabela[4] )
	lMT	:= .T.

EndIF

IF lMT
	SM0->(DbGoTop ())
	SM0->(MsSeek (aEmpresa[1]+aEmpresa[2], .T.))	//Pego a filial mais proxima
	cFilAnt := FWGETCODFILIAL
EndIF

oBloco0:setMT(lMT)
oBloco1:setMT(lMT)
oBlocoA:setMT(lMT)
oBlocoC:setMT(lMT)
oBlocoD:setMT(lMT)
oBlocoF:setMT(lMT)

oBloco0:setJob(SubStr(cJob,8,2))
oBloco1:setJob(SubStr(cJob,8,2))
oBlocoA:setJob(SubStr(cJob,8,2))
oBlocoC:setJob(SubStr(cJob,8,2))
oBlocoD:setJob(SubStr(cJob,8,2))
oBlocoF:setJob(SubStr(cJob,8,2))

//-------------------------------------------------------------------
//Processa abertura dos bloc as A, C, D.
//-------------------------------------------------------------------
cA010	:=	 aX010[1]
cC010	:=  aX010[2]
cD010	:=  aX010[3]
cF010	:= 	 aX010[4]

For nMovto	:= nContIniNf to 2


//Aqui deverão ser chamados os registros por filial.
	IF !lMT .And. ValType(oProcess)=="O"
		oProcess:Inc2Progress('Processando operações de ' + Iif(nMovto == 1 ,'Entrada','Saída' ))//'Processando Notas Fiscais de Saída'
	EndIF
	oApurEFD:SetDtIni(dDataIni)
	oApurEFD:SetDtFin(dDataFim)
	oApurEFD:SetLivro(cLivro)
	IF !lMT .And. ValType(oProcess)=="O"
		If oProcess:Cancel()
			ProcCancel(@lCancel,oTabela)
			Return
		EndIf
	EndIF

	If nMovto == 2
		//Cupom fiscal Regime de Competencia consolidado
		If mv_par19 == 1 .AND. lRgCmpCons
			oApurEFD:setlECF(.T.)
		EndIF
	Endif

	//-------------------------------------------------------------------
	//Define os filtros utilizados para consulta
	//-------------------------------------------------------------------
	cFiltroSFT := oApurEFD:GetWhrSFT(  Iif(nMovto==1 , NFENTRADA, NFSAIDA), aParSx6[MV_NFCOMPL], .T., Iif(!lRgCmpCons.And.MV_PAR08 == 2,.T.,.F.), .T., .F., .T. )

	//-------------------------------------------------------------------
	//Tabela de Livro Fiscal
	//-------------------------------------------------------------------
	cSlctSFT := "SFT.FT_FILIAL,  SFT.FT_TIPOMOV, SFT.FT_ENTRADA, SFT." + SerieNfId("SFT",3,"FT_SERIE") +  " FT_SERIE, SFT.FT_NFISCAL, SFT.FT_CLIEFOR, SFT.FT_LOJA,"
	cSlctSFT += "SFT.FT_ITEM,    SFT.FT_PRODUTO, SFT.FT_CFOP,	 SFT.FT_ESPECIE, SFT.FT_ALIQPIS, SFT.FT_ALIQCOF, SFT.FT_ALIQCF3,"
	cSlctSFT += "SFT.FT_ALIQPS3, SFT.FT_CSTPIS,	 SFT.FT_CSTCOF,  SFT.FT_PAUTPIS, SFT.FT_PAUTCOF, SFT.FT_TNATREC, SFT.FT_CNATREC,"
	cSlctSFT += "SFT.FT_GRUPONC, SFT.FT_DTFIMNT, SFT.FT_CODBCC,  SFT.FT_QUANT,   SFT.FT_EMISSAO, SFT.FT_VALPIS,  SFT.FT_VALCOF,"
	cSlctSFT += "SFT.FT_VALCONT, SFT.FT_TOTAL,   SFT.FT_BASEPIS, SFT.FT_BASECOF, SFT.FT_BASECF3, SFT.FT_BASEPS3, SFT.FT_VALPS3,"
	cSlctSFT += "SFT.FT_VALCF3,	 SFT.FT_MVALCOF, SFT.FT_MALQCOF, SFT.FT_MVALPIS, SFT.FT_MALQPIS, SFT.FT_NFELETR, SFT.FT_FORMUL,"
	cSlctSFT += "SFT.FT_CHVNFE , SFT.FT_DTCANC , SFT.FT_TIPO,	 SFT.FT_TES,     SFT.FT_DESCONT, SFT.FT_CONTA,	 SFT.FT_VRETPIS,"
	cSlctSFT += "SFT.FT_VRETCOF, SFT.FT_VALICM,  SFT.FT_OUTRICM, SFT.FT_OUTRRET, SFT.FT_ISENICM, SFT.FT_ISENRET, SFT.FT_INDNTFR,"
	cSlctSFT += "SFT.FT_BASEICM, SFT.FT_DESPESA, SFT.FT_SEGURO,  SFT.FT_FRETE,   SFT.FT_BASERET, SFT.FT_OBSERV , SFT.FT_DESCZFR,"
	cSlctSFT += "SFT.FT_ALIQICM, SFT.FT_ALIQSOL, SFT.FT_BASEIPI, SFT.FT_ALIQIPI, SFT.FT_VALIPI,  SFT.FT_DESCICM, SFT.FT_POSIPI,"
	cSlctSFT += "SFT.FT_CREDST,  SFT.FT_ESTADO,  SFT.FT_ICMSRET, SFT.FT_ANTICMS, SFT.FT_OBSSOL,  SFT.FT_SOLTRIB, SFT.FT_CODNFE,"
	cSlctSFT += "SFT.FT_NORESP,  SFT.FT_RGESPST, SFT.FT_PDV,     SF4.F4_RGESPCI, SFT.FT_CTIPI ,  SFT.FT_CLASFIS, SFT.R_E_C_N_O_, "

	If aParSX3[FP_FT_SERSAT]
		cSlctSFT += "SFT.FT_SERSAT,"
	EndIf

	cSlctSFT += "SF3.F3_CODRSEF, SF3.F3_CLASCO, SF3.R_E_C_N_O_ SF3RECNO,"

	cSlctSFT += "CD1.CD1_CODNAT, CD1.CD1_DESCR,"      
	cSlctSFT += "SF4.F4_CODIGO, SF4.F4_TEXTO, SF4.F4_SITTRIB, SF4.F4_ESTOQUE, SF4.F4_MOVFIS,  SF4.F4_LFIPI, SF4.F4_PISCRED, SF4.F4_ATUATF,  SF4.F4_PSCFST, "

	//-------------------------------------------------------------------
	//Campos do cadastro de cliente
	//-------------------------------------------------------------------
	cSlctSFT += "SA1.A1_COD,	SA1.A1_LOJA,	SA1.A1_NOME,	SA1.A1_CGC,		SA1.A1_EST,		SA1.A1_INSCR,	SA1.A1_COD_MUN,"
	cSlctSFT += "SA1.A1_END,	SA1.A1_BAIRRO,	SA1.A1_CODPAIS,	SA1.A1_INSCRM,	SA1.A1_PESSOA, 	SA1.A1_TIPO, 	SA1.A1_COMPLEM,"

	If aParSX3[FP_A1_SUFRAMA]
		cSlctSFT +=	"SA1.A1_SUFRAMA,"
	EndIf

	If aParSX3[FP_A1_ENDNOT]
		cSlctSFT +=	"SA1.A1_ENDNOT,"
	EndIf

	//-------------------------------------------------------------------
	//Campos do Cadastro de fornecedor
	//-------------------------------------------------------------------
	cSlctSFT += "SA2.A2_COD, SA2.A2_LOJA,	SA2.A2_NOME,	SA2.A2_CGC,	   SA2.A2_EST,  SA2.A2_INSCR,	SA2.A2_COD_MUN,"
	cSlctSFT += "SA2.A2_END, SA2.A2_BAIRRO,	SA2.A2_CODPAIS,	SA2.A2_INSCRM, SA2.A2_TIPO, SA2.A2_COMPLEM,"

	If aParSX3[FP_A2_ENDNOT]
		cSlctSFT +=	"SA2.A2_ENDNOT,"
	EndIf

	If aParSX3[FP_A2_CPFRUR]
		cSlctSFT +=	"SA2.A2_CPFRUR,"
	EndIf 

	If aParSX3[FP_A2_INDRUR]
		cSlctSFT +=	"SA2.A2_INDRUR,"
	EndIf 

	If aParSX3[FP_A2_SUFRAMA]
		cSlctSFT +=	"SA2.A2_SUFRAMA,"
	EndIf

	cSlctSFT += Iif( aParSX3[FP_A2_DEDBSPC], "SA2.A2_DEDBSPC,", "'' A2_DEDBSPC,")

	//-------------------------------------------------------------------
	//Tabela de complemento de combustível
	//-------------------------------------------------------------------
	cSlctSFT += "CD6.CD6_CODANP,"

	//-------------------------------------------------------------------
	//Tabela de complemento de produtos
	//-------------------------------------------------------------------
	cSlctSFT += "SB5.B5_TABINC, SB5.B5_CODGRU, SB5.B5_MARCA,"

	//-------------------------------------------------------------------
	//Tabela de produto
	//-------------------------------------------------------------------
	cSlctSFT += "SB1.B1_COD	  , SB1.B1_DESC  , SB1.B1_TIPO, SB1.B1_CODBAR, SB1.B1_CODANT, SB1.B1_UM    , SB1.B1_CODISS,"
	cSlctSFT += "SB1.B1_POSIPI, SB1.B1_EX_NCM, SB1.B1_PICM, SB1.B1_ORIGEM, SB1.B1_IMPORT, SB1.B1_DATREF,"

	//-------------------------------------------------------------------
	//Tabela CF4 com campos de notas devolvidas
	//-------------------------------------------------------------------
	cSlctSFT += cFuncNull + "( CF4.CF4_VALPIS,0) CF4_VALPIS,"+cFuncNull + "( CF4.CF4_VALCOF,0) CF4_VALCOF, "+cFuncNull + "( CF4.CF4_BASPIS,0) CF4_BASPIS,"+cFuncNull + "( CF4.CF4_BASCOF,0) CF4_BASCOF,"
	//-------------------------------------------------------------------
	//Tabela de complemento de energia elétrica
	//-------------------------------------------------------------------
	cSlctSFT += "SFU.FU_CLASCON, SFU.FU_CONSTOT, SFU.FU_VALTERC,"

	//-------------------------------------------------------------------
	//Tabela de complemento de Gas
	//-------------------------------------------------------------------
	cSlctSFT += "CD3.CD3_CLASCO, CD3.CD3_VLTERC," + cCD3VlForn

	//-------------------------------------------------------------------
	//Tabela de complemento de nota fiscal de comunicação
	//-------------------------------------------------------------------
	cSlctSFT += "SFX.FX_TIPOREC, SFX.FX_VALTERC, SFX.FX_GRPCLAS, SFX.FX_CLASSIF, SFX.FX_ESTREC,"

	If nMovto == 1
	//-------------------------------------------------------------------
	//Tabela de NF de entrada
	//-------------------------------------------------------------------
		cSlctSFT += "SF1.F1_TPCTE, SF1.F1_TPFRETE, SF1.F1_FRETE, SF1.F1_PREFIXO, SF1.F1_FORMUL, SD1.D1_CC, SD1.D1_PEDIDO, SD1.D1_ITEM, SD1.D1_VALIPI, SD1.D1_ICMSRET,"

		If lF1Mennota
			cSlctSFT += "SF1.F1_MENNOTA,"
		EndIf

		If aParSX3[FP_F1_DTCPISS]
			cSlctSFT += "SF1.F1_DTCPISS,"
		EndIf
		If aParSX3[FP_F1_SUBSERI]
			cSlctSFT += "SF1.F1_SUBSERI,"
		EndIf
		If aParSX3[FP_F1_DEVMERC]
			cSlctSFT += "SF1.F1_DEVMERC,"
		EndIf
		
	ElseIf nMovto == 2
	//-------------------------------------------------------------------
	//Tabela de NF de saída
	//-------------------------------------------------------------------
		cSlctSFT += "SF2.F2_PREFIXO, SF2.F2_NFCUPOM, SD2.D2_CCUSTO, SD2.D2_PEDIDO,"

		If lF2Mennota
			cSlctSFT += "SF1.F1_MENNOTA,"
			cSlctSFT += "SF2.F2_MENNOTA,"
		EndIf

		If aParSX3[FP_F2_DTESERV]
			cSlctSFT += "SF2.F2_DTESERV,"
		EndIf

	EndIf

	//-------------------------------------------------------------------
	//Contagem de Títulos a Pagar / Receber para o Documento Fiscal
	//-------------------------------------------------------------------
	cSlctSFT += cFuncNull + "(TITCOUNTSE,0) TITCOUNTSE, " + cFuncNull + "(TITVENCTO,0) TITVENCTO"


	cSlctView := ParseSlct( cSlctSFT, {"SFT","SF3","SF4","SB1","SB5","CD1","SA1","SA2","CD6","CF4","SFU","SFX","CD3","CDG","CDT","CDC","SF1","SD1","SF2","SD2","SE1","SE2"}) + ","
	cSlctView += "ISNULL(CDG.COUNTCDG,0) COUNTCDG, "
	cSlctView += "ISNULL(CDT.COUNTCDT,0) COUNTCDT, ISNULL(CDT.CDTRECNO,0) CDTRECNO," 
	cSlctView += "ISNULL(CDC.COUNTCDC,0) COUNTCDC, ISNULL(CDC.CDCRECNO,0) CDCRECNO"

	// Redefinição dos campos do Select de acordo com as informações da VIEW
	cSlctSFT  := cSlctView + " FROM ( SELECT " + cSlctSFT

	// Montagem do From da tabela principal SF3 com junções entre as outras tabelas

	cFrom		:= RetSqlName("SF3")+ " SF3 "
	cFrom		+= "INNER JOIN " +RetSqlName("SFT")+ " SFT ON("

	If	nMovto == 1	// Operações de Entrada

		cFrom	+= cFiltroSFT
		cFrom	+= "SFT.D_E_L_E_T_ = ' ')"

		cFrom	+= "INNER JOIN "+RetSqlName("SF1")+" SF1 ON(SF1.F1_FILIAL='"+xFilial("SF1")+"' AND SF1.F1_DOC=SFT.FT_NFISCAL AND SF1.F1_SERIE=SFT.FT_SERIE AND SF1.F1_FORNECE=SFT.FT_CLIEFOR AND SF1.F1_LOJA=SFT.FT_LOJA AND SF1.D_E_L_E_T_='') "
		cFrom	+= "INNER JOIN "+RetSqlName("SD1")+" SD1 ON(SD1.D1_FILIAL='"+xFilial("SD1")+"' AND SD1.D1_DOC=SFT.FT_NFISCAL AND SD1.D1_SERIE=SFT.FT_SERIE AND SD1.D1_FORNECE=SFT.FT_CLIEFOR AND SD1.D1_LOJA=SFT.FT_LOJA AND SD1.D1_COD=SFT.FT_PRODUTO AND SD1.D1_ITEM=SFT.FT_ITEM AND SD1.D_E_L_E_T_='') "

		cFrom	+= "INNER JOIN "+RetSqlName("SF4")+" SF4 ON(SF4.F4_FILIAL='"+xFilial("SF4")+"' AND SF4.F4_CODIGO=SD1.D1_TES AND "

		cFrom	+= "("
		cFrom	+= " (SF4.F4_ATUATF <> 'S' AND (((SFT.FT_BASEPIS > 0  OR  SFT.FT_BASEPS3 > 0) OR SFT.FT_CSTPIS IN ('70','71','72','73','74','98','99'))  OR "
		cFrom	+= " 						   ((SFT.FT_BASECOF > 0  OR  SFT.FT_BASECF3 > 0) OR SFT.FT_CSTCOF IN ('70','71','72','73','74','98','99')))) OR "
		cFrom	+= " (SF4.F4_ATUATF   = 'S') "		
		cFrom	+= ") AND "

		cFrom	+= " SF4.D_E_L_E_T_='') "

		clPrefix := IIF(!Empty(Alltrim(aParSX6[MV_1DUPREF])), " SF1.F1_PREFIXO ", " SFT.FT_SERIE ") //Se MV_2DUPREF preenchido considera F1_PREFIXO para título, senão F1_SERIE.

		cFrom	+= "LEFT JOIN (SELECT SE2_.E2_FILIAL, SE2_.E2_FORNECE, SE2_.E2_LOJA, SE2_.E2_PREFIXO, SE2_.E2_NUM, COUNT(*) TITCOUNTSE, SUM(CASE WHEN SE2_.E2_EMISSAO = SE2_.E2_VENCTO THEN 1 ELSE 0 END) TITVENCTO " 
		cFrom	+= "           FROM "+RetSqlName("SE2")+" SE2_ "
		cFrom	+= "           WHERE SE2_.E2_FILIAL = '"+xFilial("SE2")+"' AND "
		cFrom	+= "                 LTRIM(RTRIM(SE2_.E2_TIPO)) NOT IN " + cTitTipo + " AND "
		cFrom	+= "                 SE2_.D_E_L_E_T_= '' "
		cFrom	+= "           GROUP BY SE2_.E2_FILIAL, SE2_.E2_FORNECE, SE2_.E2_LOJA, SE2_.E2_PREFIXO, SE2_.E2_NUM) SE2 ON (SE2.E2_FILIAL = '"+xFilial("SE2")+"' AND SE2.E2_FORNECE = SFT.FT_CLIEFOR AND SE2.E2_LOJA = SFT.FT_LOJA AND SE2.E2_PREFIXO = " + clPrefix + " AND SE2.E2_NUM = SFT.FT_NFISCAL) "

		cJoinSF3:= "SF3.F3_CFO < '5' AND "

	ElseIf nMovto == 2	// Operações de Saída

		cFrom	+=  cFiltroSFT
		cFrom	+=  " SFT.D_E_L_E_T_ = '')"

		cFrom	+= "LEFT JOIN "+RetSqlName("SF1")+" SF1 ON(SF1.F1_FILIAL='"+xFilial("SF1")+"' AND SF1.F1_DOC=SFT.FT_NFISCAL AND SF1.F1_SERIE=SFT.FT_SERIE AND SF1.F1_FORNECE=SFT.FT_CLIEFOR AND SF1.F1_LOJA=SFT.FT_LOJA AND SF1.D_E_L_E_T_='') "
		cFrom	+= "LEFT JOIN "+RetSqlName("SF2")+" SF2 ON(SF2.F2_FILIAL='"+xFilial("SF2")+"' AND SF2.F2_DOC=SFT.FT_NFISCAL AND SF2.F2_SERIE=SFT.FT_SERIE AND SF2.F2_CLIENTE=SFT.FT_CLIEFOR AND SF2.F2_LOJA=SFT.FT_LOJA AND SF2.D_E_L_E_T_='') "
		cFrom	+= "LEFT JOIN "+RetSqlName("SD2")+" SD2 ON(SD2.D2_FILIAL='"+xFilial("SD2")+"' AND SD2.D2_DOC=SFT.FT_NFISCAL AND SD2.D2_SERIE=SFT.FT_SERIE AND SD2.D2_CLIENTE=SFT.FT_CLIEFOR AND SD2.D2_LOJA=SFT.FT_LOJA AND SD2.D2_COD=SFT.FT_PRODUTO AND SD2.D2_ITEM=SFT.FT_ITEM AND SD2.D_E_L_E_T_='') "
		cFrom	+= "LEFT JOIN "+RetSqlName("SF4")+" SF4 ON(SF4.F4_FILIAL='"+xFilial("SF4")+"' AND SF4.F4_CODIGO=SD2.D2_TES AND SF4.D_E_L_E_T_=' ') "
				
		clPrefix := IIF(!Empty(Alltrim(aParSX6[MV_1DUPREF])), " SF2.F2_PREFIXO ", " SFT.FT_SERIE ") //Se MV_2DUPREF preenchido considera F1_PREFIXO para título, senão F1_SERIE.

		cFrom	+= "LEFT JOIN (SELECT SE1_.E1_FILIAL, SE1_.E1_CLIENTE, SE1_.E1_LOJA, SE1_.E1_PREFIXO, SE1_.E1_NUM, COUNT(*) TITCOUNTSE, SUM(CASE WHEN SE1_.E1_EMISSAO = SE1_.E1_VENCTO THEN 1 ELSE 0 END) TITVENCTO
		cFrom	+= "           FROM "+RetSqlName("SE1")+" SE1_ "
		cFrom	+= "           WHERE SE1_.E1_FILIAL = '"+xFilial("SE1")+"' AND "
		cFrom	+= "                 LTRIM(RTRIM(SE1_.E1_TIPO)) NOT IN " + cTitTipo + " AND "
		cFrom	+= "                 SE1_.D_E_L_E_T_= '' "
		cFrom	+= "           GROUP BY SE1_.E1_FILIAL, SE1_.E1_CLIENTE, SE1_.E1_LOJA, SE1_.E1_PREFIXO, SE1_.E1_NUM) SE1 ON (SE1.E1_FILIAL = '"+xFilial("SE1")+"' AND SE1.E1_CLIENTE = SFT.FT_CLIEFOR AND SE1.E1_LOJA = SFT.FT_LOJA AND SE1.E1_PREFIXO = " + clPrefix + " AND SE1.E1_NUM = SFT.FT_NFISCAL) "

		cJoinSF3:= "SF3.F3_CFO > '4' AND "

	EndIf

	cFrom		+= "INNER JOIN "+RetSqlName("SB1")+" SB1 ON(SB1.B1_FILIAL ='"+xFilial("SB1")+"' AND SB1.B1_COD=SFT.FT_PRODUTO AND SB1.D_E_L_E_T_=' ') "
	cFrom		+= "LEFT  JOIN "+RetSqlName("SB5")+" SB5 ON(SB5.B5_FILIAL ='"+xFilial("SB5")+"' AND SB5.B5_COD=SB1.B1_COD AND SB5.D_E_L_E_T_='') "
	cFrom		+= "LEFT  JOIN "+RetSqlName("CD1")+" CD1 ON(CD1.CD1_FILIAL='"+xFilial("CD1")+"' AND CD1.CD1_CODNAT=SFT.FT_NATOPER AND CD1.D_E_L_E_T_='') "
	cFrom		+= "LEFT  JOIN "+RetSqlName("SA1")+" SA1 ON(SA1.A1_FILIAL ='"+xFilial("SA1")+"' AND SA1.A1_COD="
	If aParSX3[FP_FT_CLIDVMC]
		cFrom	+= "CASE WHEN SFT.FT_CLIDVMC = '" + Space(TamSx3("FT_CLIDVMC")[1]) + "' THEN SFT.FT_CLIEFOR ELSE SFT.FT_CLIDVMC END AND SA1.A1_LOJA=CASE WHEN SFT.FT_LOJDVMC = '" + Space(TamSx3("FT_LOJDVMC")[1]) + "' THEN SFT.FT_LOJA ELSE SFT.FT_LOJDVMC END AND SA1.D_E_L_E_T_='') "
	Else
		cFrom	+= "SFT.FT_CLIEFOR AND SA1.A1_LOJA=SFT.FT_LOJA AND SA1.D_E_L_E_T_='') "
	Endif
	cFrom		+= "LEFT JOIN "+RetSqlName("SA2")+" SA2 ON(SA2.A2_FILIAL ='"+xFilial("SA2")+"' AND SA2.A2_COD=SFT.FT_CLIEFOR AND SA2.A2_LOJA=SFT.FT_LOJA AND SA2.D_E_L_E_T_='') "
	cFrom		+= "LEFT JOIN "+RetSqlName("CD6")+" CD6 ON(CD6.CD6_FILIAL='"+xFilial("CD6")+"' AND CD6.CD6_TPMOV=SFT.FT_TIPOMOV AND CD6.CD6_SERIE=SFT.FT_SERIE AND CD6.CD6_DOC=SFT.FT_NFISCAL AND CD6.CD6_CLIFOR=SFT.FT_CLIEFOR AND CD6.CD6_LOJA=SFT.FT_LOJA AND CD6.CD6_ITEM=SFT.FT_ITEM AND CD6.CD6_COD=SFT.FT_PRODUTO AND CD6.D_E_L_E_T_='') "

	If aParSX3[FP_CF4_FLORIG]
		cFrom	+= "LEFT JOIN "+RetSqlName("CF4")+" CF4 ON(CF4.CF4_FILIAL='"+xFilial("CF4")+"' AND CF4.CF4_FLORIG = '" +xFilial("SFT")+ "' AND CF4.CF4_TIPMOV=SFT.FT_TIPOMOV AND CF4.CF4_SERIE=SFT.FT_SERIE AND CF4.CF4_NOTA=SFT.FT_NFISCAL AND CF4.CF4_CLIFOR=SFT.FT_CLIEFOR AND CF4.CF4_LOJA=SFT.FT_LOJA AND CF4.CF4_ITEM=SFT.FT_ITEM AND CF4.CF4_DATAE  = SFT.FT_EMISSAO  AND CF4.CF4_TIPO = 'D' AND CF4.D_E_L_E_T_='') "
	Else
		cFrom	+= "LEFT JOIN "+RetSqlName("CF4")+" CF4 ON(CF4.CF4_FILIAL='"+xFilial("CF4")+"' AND CF4.CF4_TIPMOV=SFT.FT_TIPOMOV AND CF4.CF4_SERIE=SFT.FT_SERIE AND CF4.CF4_NOTA=SFT.FT_NFISCAL AND CF4.CF4_CLIFOR=SFT.FT_CLIEFOR AND CF4.CF4_LOJA=SFT.FT_LOJA AND CF4.CF4_ITEM=SFT.FT_ITEM AND CF4.CF4_DATAE  = SFT.FT_EMISSAO  AND CF4.CF4_TIPO = 'D' AND CF4.D_E_L_E_T_='') "
	Endif

	cFrom		+= "LEFT JOIN "+RetSqlName("SFU")+" SFU ON(SFU.FU_FILIAL ='"+xFilial("SFU")+"' AND SFU.FU_TIPOMOV=SFT.FT_TIPOMOV AND SFU.FU_SERIE=SFT.FT_SERIE AND SFU.FU_DOC=SFT.FT_NFISCAL AND SFU.FU_CLIFOR=SFT.FT_CLIEFOR AND SFU.FU_LOJA=SFT.FT_LOJA AND SFU.FU_ITEM=SFT.FT_ITEM AND SFU.FU_COD=SFT.FT_PRODUTO AND SFU.D_E_L_E_T_='') "
	cFrom		+= "LEFT JOIN "+RetSqlName("SFX")+" SFX ON(SFX.FX_FILIAL ='"+xFilial("SFX")+"' AND SFX.FX_TIPOMOV=SFT.FT_TIPOMOV AND SFX.FX_SERIE=SFT.FT_SERIE AND SFX.FX_DOC=SFT.FT_NFISCAL AND SFX.FX_CLIFOR=SFT.FT_CLIEFOR AND SFX.FX_LOJA=SFT.FT_LOJA AND SFX.FX_ITEM=SFT.FT_ITEM AND SFX.FX_COD=SFT.FT_PRODUTO AND SFX.D_E_L_E_T_='') "
	cFrom		+= "LEFT JOIN "+RetSqlName("CD3")+" CD3 ON(CD3.CD3_FILIAL='"+xFilial("CD3")+"' AND CD3.CD3_TPMOV=SFT.FT_TIPOMOV AND CD3.CD3_SERIE=SFT.FT_SERIE AND CD3.CD3_DOC=SFT.FT_NFISCAL AND CD3.CD3_CLIFOR=SFT.FT_CLIEFOR AND CD3.CD3_LOJA=SFT.FT_LOJA AND CD3.CD3_ITEM=SFT.FT_ITEM AND CD3.CD3_COD=SFT.FT_PRODUTO AND CD3.D_E_L_E_T_='') "
	
	// Montagem do WHERE da tabela principal encerrando no fechamento da VIEW
	cWhere		:= "SF3.F3_FILIAL= '"+ xFilial("SF3")+ "' AND SF3.F3_ENTRADA>= '" + dtos(oApurEFD:dDtIni) + "' AND SF3.F3_ENTRADA<= '" + DToS(oApurEFD:dDtFin) + "' AND "
	cWhere		+= cJoinSF3
    cWhere		+= "SF3.D_E_L_E_T_ = '' "
	cWhere		+= ") SFT2 "

	// Montagem dos demais campos utilizados na VIEW que servem de totalizadores e ponteiros

	//Verifica se existe CGD
	cSlctView  :="LEFT JOIN (SELECT CDG_FILIAL, CDG_TPMOV, CDG_DOC, CDG_SERIE, CDG_CLIFOR, CDG_LOJA, CDG_ITEM, COUNT(CDG_DOC) COUNTCDG "
    cSlctView  +="FROM "+RetSqlName("CDG") + " "
    cSlctView  +="WHERE CDG_FILIAL='"+xFilial("CDG")+"' AND D_E_L_E_T_ = '' "
    cSlctView  +="GROUP BY  CDG_FILIAL, CDG_TPMOV, CDG_DOC, CDG_SERIE, CDG_CLIFOR, CDG_LOJA, CDG_ITEM) CDG "
	cSlctView  +="ON (CDG.CDG_FILIAL='"+xFilial("CDG")+"' AND CDG.CDG_TPMOV = SFT2.FT_TIPOMOV AND CDG.CDG_DOC = SFT2.FT_NFISCAL AND CDG.CDG_SERIE = SFT2.FT_SERIE AND  CDG.CDG_CLIFOR = SFT2.FT_CLIEFOR AND CDG.CDG_LOJA = SFT2.FT_LOJA AND CDG.CDG_ITEM = SFT2.FT_ITEM) "
	
	//Verifica se existe CDT
	cSlctView  +="LEFT JOIN (SELECT CDT_FILIAL,CDT_TPMOV,CDT_DOC,CDT_SERIE,CDT_CLIFOR,CDT_LOJA, COUNT(CDT_DOC) COUNTCDT, MAX(R_E_C_N_O_) CDTRECNO "
	cSlctView  +="FROM "+RetSqlName("CDT") + " "
	cSlctView  +="WHERE CDT_FILIAL='"+xFilial("CDT")+"' AND D_E_L_E_T_ = '' "
	cSlctView  +="GROUP BY CDT_FILIAL,CDT_TPMOV,CDT_DOC,CDT_SERIE,CDT_CLIFOR,CDT_LOJA) CDT "
	cSlctView  +="ON (CDT.CDT_FILIAL='"+xFilial("CDT")+"' AND CDT.CDT_TPMOV = SFT2.FT_TIPOMOV AND CDT.CDT_DOC = SFT2.FT_NFISCAL AND CDT.CDT_SERIE = SFT2.FT_SERIE AND CDT.CDT_CLIFOR = SFT2.FT_CLIEFOR AND CDT.CDT_LOJA = SFT2.FT_LOJA) "
	
	//Verifica se existe CDC
	cSlctView  +="LEFT JOIN (SELECT CDC_FILIAL,CDC_TPMOV,CDC_DOC,CDC_SERIE,CDC_CLIFOR,CDC_LOJA, COUNT(CDC_DOC) COUNTCDC, MAX(R_E_C_N_O_) CDCRECNO "
	cSlctView  +="FROM "+RetSqlName("CDC") + " "
	cSlctView  +="WHERE CDC_FILIAL='"+xFilial("CDC")+"' AND D_E_L_E_T_ = '' "
	cSlctView  +="GROUP BY CDC_FILIAL,CDC_TPMOV,CDC_DOC,CDC_SERIE,CDC_CLIFOR,CDC_LOJA) CDC "
	cSlctView  +="ON (CDC.CDC_FILIAL='"+xFilial("CDC")+"' AND CDC.CDC_TPMOV = SFT2.FT_TIPOMOV AND CDC.CDC_DOC = SFT2.FT_NFISCAL AND CDC.CDC_SERIE = SFT2.FT_SERIE AND CDC.CDC_CLIFOR = SFT2.FT_CLIEFOR AND CDC.CDC_LOJA = SFT2.FT_LOJA) "

	// Montagem dos campos para ordenacao com base na View criada SFT2
	cOrderBy   :="ORDER BY SFT2.FT_FILIAL,SFT2.FT_TIPOMOV,SFT2.FT_ENTRADA,SFT2.FT_SERIE,SFT2.FT_NFISCAL,SFT2.FT_CLIEFOR,SFT2.FT_LOJA,SFT2.FT_ITEM,SFT2.FT_PRODUTO,SFT2.R_E_C_N_O_ "

	// Necessario concatenar no WHERE demais campos da View e Order By para não apresentar erro de Sintaxe no BeginSQL
	cWhere	   += cSlctView + cOrderBy 

	// Transformação de variaveis para ser utilizada no BeginSQL
	cSlctSFT 	:= '%' + cSlctSFT + '%'
	cFrom		:= '%' + cFrom + '%'
	cWhere		:= '%' + cWhere	+ '%'

	cAliasSFT	:=	GetNextAlias()

	BeginSql Alias cAliasSFT

		COLUMN FT_DTFIMNT AS DATE
		COLUMN FT_DTCANC AS DATE
		COLUMN FT_EMISSAO AS DATE
		COLUMN FT_ENTRADA AS DATE
		COLUMN F2_DTESERV AS DATE
		COLUMN F1_DTCPISS AS DATE

		SELECT		
		%Exp:cSlctSFT%
		
		FROM
		%Exp:cFrom%

		WHERE
		%Exp:cWhere%

	EndSql

	DbSelectArea (cAliasSFT) 
	(cAliasSFT)->(DbGoTop ())
	

	//-------------------------------------------------------------------
	//Laço principal de nota fiscal
	//-------------------------------------------------------------------
	Do While !(cAliasSFT)->(Eof ())
		nNumItem	:= 0
		cEspecie	:= aMODNOT((cAliasSFT)->FT_ESPECIE)
		cEntSai	:=	Iif ("E"$(cAliasSFT)->FT_TIPOMOV, "1", "2")
		cSituaDoc	:=	SPEDSitDoc (, cAliasSFT,,,aDate[1],aDate[2],,,,,,.T., (cAliasSFT)->(F3_CODRSEF))
		cClieFor	:=	'SA'+Iif ((cEntSai=='1' .And. !(cAliasSFT)->FT_TIPO$'BD') .or. (cEntSai=='2' .And. (cAliasSFT)->FT_TIPO$'BD'), '2', '1')
		nRelacPai	:= 0
		cRelacPai	:= ''
		cCodPart	:= ''
		cIndPagto	:= ''
		cInfCompl	:= ''
		cFrete		:= ''
		lGera0150	:= .F.
		cSitExt		:= ''
		lSitDocCDT	:= .F.
		cChave		:= (cAliasSFT)->FT_FILIAL+(cAliasSFT)->FT_TIPOMOV+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA

		cDedbpis := aParSX6[MV_DEDBPIS]
		cDedbcof := aParSX6[MV_DEDBCOF]
		nValICMS 	:= (cAliasSFT)->FT_VALICM
		cDedbspc 	:= (cAliasSFT)->A2_DEDBSPC
		cTipoNf  := (cAliasSFT)->FT_TIPO
		nValDesco	:= DedPisCof(cDedbpis,cDedbcof,cEntSai,nValICMS, cDedbspc,cTipoNf, aparSX6[MV_ICMDSDT])

		If !Empty((cAliasSFT)->FT_PDV) .AND. AllTrim((cAliasSFT)->FT_ESPECIE)$"CF/ECF"
			cEspecie := "2D"
		EndIf

		If (cEspecie$"01|1B|04|55|65" .and. cSituaDoc$"02|03|04|05" .and. !aParSX6[MV_C100CAN]) .Or. ;
		   ((!cEspecie$"01|1B|04|55|65" .and. (cAliasSFT)->FT_TIPO$'D'))	
			lProcC100 := .F.
			(cAliasSFT)->(DbSkip())
		Else
			lProcC100 := .T.
		EndIf
		
		lValidAtv := .F.
		If (cEspecie$"01|1B|04|55|65|07|08|09|10|11|26|27|57|63|67|8B" .Or. Alltrim((cAliasSFT)->FT_ESPECIE)$"NFS|RPS|NFPS").And. (cAliasSFT)->FT_TIPOMOV == 'E'

			If !lJSAtiv
				NFItAtiv(dDataIni,dDataFim)
				lJSAtiv := Valtype(oJSAtiv) =='J' 
			endif

			if lJSAtiv .and. oJSAtiv[cChave]=="SOATIVO"
				lValidAtv := .T.
			ElseIf lJSAtiv .and. oJSAtiv[cChave]=="PARCIAL"
				aDadAtv := aDadAtv := {.F., .T., ""}
			Else
				aDadAtv := {.F., .F., ""}
			EndIf

		Else
			aDadAtv := {.F., .F., ""}
		EndIf

		// Validação necessária para não gerar registro que contenha as especies abaixa e nf de devolução.	
		If lValidAtv
			lProcC100 := .F.
			(cAliasSFT)->(DbSkip())	
		EndIf

		//Busca valor dO IPI para abater do registro F550 campo 2 caso o parâmetro MV_DIPIRB esteja habilitado 
		IF lIPIRB 
			nValipi :=(cAliasSFT)->FT_VALIPI
		Endif

		//Busca valor do ICMS ST para abater do registro F550 campo 2 caso o parâmetro MV_DSTRB esteja habilitado 
		IF lDSTRB 
			nVlrST :=(cAliasSFT)->FT_ICMSRET
		Endif
		
		If lProcC100
			aParCompl	:= {}
			aAdd(aParCompl,(cAliasSFT)->FT_TIPOMOV)
			aAdd(aParCompl,(cAliasSFT)->FT_NFISCAL)
			aAdd(aParCompl,(cAliasSFT)->FT_SERIE)
			aAdd(aParCompl,(cAliasSFT)->FT_CLIEFOR)
			aAdd(aParCompl,(cAliasSFT)->FT_LOJA)

			IF lRgCmpCons
				If oApurEFD:ChkRegraNf((cAliasSFT)->FT_ESPECIE,(cAliasSFT)->FT_CFOP,cEntSai,cEspecie,,(cAliasSFT)->FT_CSTPIS)

					cConta	:= FSA0080500('', oBloco0,oTabela,lConcFil,(cAliasSFT)->FT_CONTA,cAliasSFT)

					nBasePis	:=  (cAliasSFT)->FT_BASEPIS
					nBaseCof	:=  (cAliasSFT)->FT_BASECOF
					nAlqPis		:=  (cAliasSFT)->FT_ALIQPIS
					nAlqCof		:=  (cAliasSFT)->FT_ALIQCOF
					nValPis		:=  (cAliasSFT)->FT_VALPIS
					nValCof		:=  (cAliasSFT)->FT_VALCOF

					IF (cAliasSFT)->FT_CSTPIS == '03' //Pauta
						oBlocoF:setTNatRec((cAliasSFT)->FT_TNATREC)
						oBlocoF:setCNatRec((cAliasSFT)->FT_CNATREC)
						oBlocoF:setGNatRec((cAliasSFT)->FT_GRUPONC)
						oBlocoF:setDNatRec((cAliasSFT)->FT_DTFIMNT)

					//Faz conversão de valores de pauta de PIS
						oBlocoF:setVlPauta((cAliasSFT)->FT_PAUTPIS )
						oBlocoF:setiQtde((cAliasSFT)->FT_QUANT)
						oBlocoF:setiBsPaut((cAliasSFT)->FT_BASEPIS)
						IF oBlocoF:OperPauta(PIS,aParSX6[MV_PISCOFP])
							nAlqPis	:= oBlocoF:getAlqReal()
							nBasePis	:= oBlocoF:getBaseQtd()
						EndIF

					//Faz conversão de valores de pauta de COFINS
						oBlocoF:setVlPauta((cAliasSFT)->FT_PAUTCOF)
						oBlocoF:setiQtde((cAliasSFT)->FT_QUANT)
						oBlocoF:setiBsPaut((cAliasSFT)->FT_BASECOF)
						IF oBlocoF:OperPauta(COFINS,aParSX6[MV_PISCOFP])
							nAlqCof	:= oBlocoF:getAlqReal()
							nBaseCof	:= oBlocoF:getBaseQtd()
						EndIF

					EndIF

					If (cAliasSFT)->FT_PAUTPIS > 0 .OR. (cAliasSFT)->FT_PAUTCOF > 0
						nValExcluP	:= (cAliasSFT)->CF4_BASPIS
						nValExcluC	:= (cAliasSFT)->CF4_BASCOF
					Else
						nValExcluP	:= nValExcluC  := (cAliasSFT)->FT_DESCONT + nValDesco + Iif(aParSx6[MV_VALEXCL],(cAliasSFT)->FT_ICMSRET+(cAliasSFT)->FT_VALIPI,0 )

						nBasePis	-= (cAliasSFT)->CF4_BASPIS
						nValPis		-= (cAliasSFT)->CF4_VALPIS
						nBaseCof	-= (cAliasSFT)->CF4_BASCOF
						nValCof		-= (cAliasSFT)->CF4_VALCOF

						nValExcluP	+= (cAliasSFT)->CF4_BASPIS
						nValExcluC	+= (cAliasSFT)->CF4_BASCOF
					EndIf
					aParF550	:= {}

					If cEspecie $ '07/08/09/10/11/26/27/57/67/8B'
						aAdd(aParF550,(cAliasSFT)->FT_VALCONT )
					Else	
						aAdd(aParF550, (cAliasSFT)->FT_VALCONT+(cAliasSFT)->FT_DESCONT - nValipi - nVlrST) 					
					Endif	
					aAdd(aParF550, (cAliasSFT)->FT_CSTPIS )
					aAdd(aParF550, nValExcluP)
					aAdd(aParF550, nBasePis)
					aAdd(aParF550, nAlqPis)
					aAdd(aParF550, nValPis)
					aAdd(aParF550, (cAliasSFT)->FT_CSTCOF )
					aAdd(aParF550, nValExcluC)
					aAdd(aParF550, nBaseCof)
					aAdd(aParF550, nAlqCof)
					aAdd(aParF550, nValCof)
					aAdd(aParF550, cEspecie)
					aAdd(aParF550, (cAliasSFT)->FT_CFOP)
					aAdd(aParF550, cConta)
					aAdd(aParF550, '')
					If !(cSituaDoc $ "02#03#04#05")
						PrcF550560(cF010, oBlocoF, aParF550)

						cRelacPai	:= oBlocoF:getGrupo()

						IF (cAliasSFT)->COUNTCDG >= 1
							IF (cAliasSFT)->FT_CSTPIS == '03'
								BuscaCDG(cRelacPai, aParCompl, oBlocoF, oBloco1, 'F569', 'F560', lTabCIE, aDate[1], (cAliasSFT)->FT_ITEM,, cConta,,,(cAliasSFT)->FT_CHVNFE)
							Else
								BuscaCDG(cRelacPai, aParCompl, oBlocoF, oBloco1, 'F559', 'F550', lTabCIE, aDate[1], (cAliasSFT)->FT_ITEM,, cConta,,,(cAliasSFT)->FT_CHVNFE)
							EndIF
						Endif
					EndiF
					nPosNf	:= aScan(aRegNf, {|aX| aX[1] == (cAliasSFT)->FT_NFISCAL .AND. ;
						aX[2] == (cAliasSFT)->FT_SERIE .AND. ;
						aX[3] == (cAliasSFT)->FT_ESPECIE  .AND. ;
						aX[4] == (cAliasSFT)->FT_CLIEFOR .AND. ;
						aX[5] == (cAliasSFT)->FT_LOJA} )
					nQtdNf	:= 0
					If nPosNf == 0
						nQtdNf	:= 1
						aAdd(aRegNf, {})
						nPosNf := Len(aRegNf)
						aAdd (aRegNf[nPosNf], (cAliasSFT)->FT_NFISCAL)
						aAdd (aRegNf[nPosNf], (cAliasSFT)->FT_SERIE)
						aAdd (aRegNf[nPosNf], (cAliasSFT)->FT_ESPECIE)
						aAdd (aRegNf[nPosNf], (cAliasSFT)->FT_CLIEFOR)
						aAdd (aRegNf[nPosNf], (cAliasSFT)->FT_LOJA)
					EndIf

					//Para o registro 1900 se a situação do documento não for normal ou cancelada deverá ser igual a 99 - Outros
					If !cSituaDoc $ "00/02/03"
						cSituaDoc := "99"
					ElseIf cSituaDoc=="03" //03 - Cancelamento autorizado fora do prazo, para o 1900 cancelamento deve ir como 02
						cSituaDoc := "02"
					EndIf

					aParF550	:= {}
					aAdd(aParF550, SM0->M0_CGC)
					aAdd(aParF550, Iif(Empty(cEspecie),"98",cEspecie))
					aAdd(aParF550, (cAliasSFT)->FT_SERIE)
					aAdd(aParF550, cSituaDoc)
					If cEspecie $ '07/08/09/10/11/26/27/57/67/8B'
						aAdd(aParF550,(cAliasSFT)->FT_VALCONT )
					Else							
						aAdd(aParF550, (cAliasSFT)->FT_VALCONT+(cAliasSFT)->FT_DESCONT - nValipi - nVlrST) 					
					Endif
					aAdd(aParF550, Alltrim(cValtoChar(nQtdNf)))
					aAdd(aParF550, (cAliasSFT)->FT_CSTPIS )
					aAdd(aParF550, (cAliasSFT)->FT_CSTCOF )
					aAdd(aParF550, (cAliasSFT)->FT_CFOP )
					aAdd(aParF550, '')
					aAdd(aParF550, cConta)

					Proc1900('1001000000001', oBloco1, aParF550,aParSx6[MV_AGR1900])
				EndIF

			//Move para o proximo item da SFT
				(cAliasSFT)->(DbSkip ())
			//Volta para início do laço  
				Loop
			EndIF

			cChave	:= ''
			ProcNf	:= .T.
			cChave	:=	(cAliasSFT)->FT_FILIAL+(cAliasSFT)->FT_TIPOMOV+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA

			//³A funcao GravaC100 verifica se o documento fiscal possui pelo menos um item que gera contribuicao ou credito ³
			//³e desta forma, se possuir, devera escriturar a nota fiscal em sua integralidade. Ou seja, o registro C100 com³
			//³valores totais, e um C170 para cada item da nota.															³
			If cEspecie $ "01/04/1B/55/65/59" .OR. (cEntSai == "1" .AND. cEspecie $ "07/08/09/10/11/26/27/57/67/21/22") .OR. (cEntSai == "2"  .And. !Empty((cAliasSFT)->F2_NFCUPOM).AND. Empty(cEspecie) .AND. Len(AllTrim((cAliasSFT)->FT_CFOP))==4)
					IF cChave <> cChaveRej
							ProcNf	:=	ChkNf(cChave,cEntSai,aCFOPs,cAliasSFT, .T.)
					Else
						ProcNf	:= .F.
					EndIF
			ElseIf cEntSai == "1" .And. !((cAliasSFT)->FT_CSTPIS$("50#51#52#53#54#55#56#60#61#62#63#64#65#66")) .And. aParSx6[MV_SKPENC]
				IF cChave <> cChaveRej
					ProcNf	:=	ChkNf(cChave,cEntSai,aCFOPs,cAliasSFT, .F.)
				Else
					ProcNf	:= .F.
				EndIF
			EndIF

			If !ProcNf
				//Move para o proximo item da SFT
				cChaveRej	:= cChave
				(cAliasSFT)->(DbSkip ())
				//Volta para início do laço
				Loop
			EndIF
			//Verifica abaixo para estes modelos se a d
			lConjugada	:= .F.
			If cMVESTADO == 'DF' .AND. cEspecie $ '01/04/1B/55/63/65'

				aConjugada		:=	{.F.,.F.}	//Posicao 1 indica se a nota fiscal tem servico e a posicao 2 indica se a nota fiscal possui produto.
				cChaveF3		:=	xFilial ("SF3")+DToS ((cAliasSFT)->FT_ENTRADA)+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA
				If SF3->(MsSeek (cChaveF3))

					While !SF3->(Eof()) .And.;
						cChaveF3==xFilial ("SF3")+SF3->(DToS (F3_ENTRADA)+F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA)

						If SF3->F3_TIPO=="S"
							aConjugada[1]	:=	.T.
						Else
							aConjugada[2]	:=	.T.
						EndIf

						//Se eu identificar que a NF eh conjugada, nao preciso continuar lendo o SF3.
						If aConjugada[1] .And. aConjugada[2]
							lConjugada	:= .T.
							Exit
						EndIf
						SF3->(dbSkip())
					End
					//Reposiciona no SF3 para consultas futuras
					SF3->(MsSeek (cChaveF3))
				EndIF
			EndIF

		//-------------------------------------------------------------------
		//Abaixo irá processar os cabeçalhos dos registros que são gerados por nota
		//Mantemos a chave e  número de relação para poder processar os registros filhos.
		//-------------------------------------------------------------------
			lEletC100	:=  IIF(Alltrim((cAliasSFT)->FT_CFOP)$cEletC100,.T.,.F.)
			lEnerEle	:=  (cEspecie=="55") .AND. (SubStr((cAliasSFT)->FT_CFOP,1,3)$cCFOPEElet) .And. !lEletC100

			IF Empty(cEspecie) .OR. (!aParSX6[MV_DFSRVAC] .AND. cEspecie == '55' .AND. (cAliasSFT)->FT_TIPO == 'S' .AND. cMVESTADO == 'DF' .AND. !lConjugada)

				//----------------------------------------------------------------------------------
				//Processa registro 0150 do participante.
				//Obrigatorio nas entradas. Nas saidas gerar apenas se o CPF/CNPJ for preenchido.
				//----------------------------------------------------------------------------------
				If (   (cAliasSFT)->A1_TIPO == 'X' .AND. cEntSai == '2'   ) .Or. cEntSai == '1' .Or. (  cEntSai == '2' .And. !Empty( (cAliasSFT)->A1_CGC)   )
				//If !(Empty((cAliasSFT)->A1_CGC) .And. Empty((cAliasSFT)->A2_CGC)) .Or. cEntSai == "1"
					cCodPart	:= FSA0080150(c0140, oTabela, oBloco0, cClieFor, cAliasSFT, lConcFil)
				EndIf
				
				//Aqui verificar se a nota fiscal possum títulos gerados, para poder processar o indicador de recebimento/pagamento
				If (cAliasSFT)->(TITCOUNTSE) > 1 //Existe mais de um título, então é a prazo, não pode ser avista
					cIndPagto	:= '1'
				ElseIf (cAliasSFT)->(TITCOUNTSE) == 1 //0 Se Existe somente 1 título e emissão é igual o vencimento - 1 Se Existe somente 1 título e emissão não é igual ao vencimento
					cIndPagto 	:= IIF((cAliasSFT)->(TITVENCTO) > 0, '0', '1')
				ElseIf (cAliasSFT)->(TITCOUNTSE) == 0 .Or.;//Não existe título, então não da para definir se é avista ou a prazo, considera outros.		
				   (cEntSai =='1' .And. !((cAliasSFT)->FT_TIPOMOV == "E" .And. (cAliasSFT)->FT_TIPO == "D"))
					cIndPagto	:= Iif(dDataIni >= CTOD("01/07/2012"), "2", "9")	
				EndIf
				
				//-------------------------------------------------------------------
				//Processa cabecalho do A100
				//-------------------------------------------------------------------
				nRelacPai	:= ProcA100(cA010,oBlocoA,cAliasSFT,cCodPart,cIndPagto,aparPE[SPDPIS05],aparSX6[MV_CF3ENTR],cEspecie, aparSX6[MV_EFDSERI], Iif( lSM0Dup, lMT, .f.))				
				PutGlbValue( cA010, ".F." )

				//Pega chave de relação do registro A100 para utilizar nos filhos
				cRelacPai	:= oBlocoA:getGrupo()

				//Verifica informações de processo referenciado A110
				ProcCDT("A110", cRelacPai,c0140,oBloco0, oBlocoA, oTabela, cAliasSFT, nSPDIFC, Iif(cEntSai =='1' ,lF1Mennota ,lF2Mennota),lSPDPISIC)

			ElseIF cEspecie $ '01/04/1B' .OR. (cEspecie == "55" .AND. !lConIndiv .AND. !lEnerEle) .OR. (cEspecie == '65' .And. cEntSai == '2')
				
				// Tratamento para carregar os dados da filial quando a emissão é uma devolução com formulário próprio e DEVMERC = S no C100 e 0150	
				If aParSX3[FP_F1_DEVMERC]  .And. nMovto == 1 .And. (cAliasSFT)->F1_FORMUL == "S" .And. (cAliasSFT)->F1_DEVMERC == 'S'
					cClieFor := "SM0"
				EndIf
				//-------------------------------------------------------------------
				//Processa registro 0150 do participante
				//-------------------------------------------------------------------
				If !cSituaDoc$"02#03#04#05" .AND. cEspecie <> '65'
					cCodPart	:= FSA0080150(c0140, oTabela, oBloco0, cClieFor, cAliasSFT,lConcFil)
				EndIF

				//Aqui verificar se a nota fiscal possum títulos gerados, para poder processar o indicador de recebimento/pagamento
				If (cAliasSFT)->(TITCOUNTSE) > 1 //Existe mais de um título, então é a prazo, não pode ser avista
					cIndPagto	:= '1'
				ElseIf (cAliasSFT)->(TITCOUNTSE) == 1 //0 Se Existe somente 1 título e emissão é igual o vencimento - 1 Se Existe somente 1 título e emissão não é igual ao vencimento
					cIndPagto 	:= IIF((cAliasSFT)->(TITVENCTO) > 0, '0', '1')
				ElseIf (cAliasSFT)->(TITCOUNTSE) == 0 .Or.;//Não existe título, então não da para definir se é avista ou a prazo, considera outros.		
				   (cEntSai =='1' .And. !((cAliasSFT)->FT_TIPOMOV == "E" .And. (cAliasSFT)->FT_TIPO == "D"))
					cIndPagto	:= Iif(dDataIni >= CTOD("01/07/2012"), "2", "9")	
				EndIf

				If (cAliasSFT)->COUNTCDT > 0 .and. CDT->(MsSeek (xFilial ("CDT")+(cAliasSFT)->FT_TIPOMOV+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA))
					lSitDocCDT	:=	.T.
					cSitExt	:=	CDT->CDT_SITEXT
					If !Empty(CDT->CDT_INDFRT)
						cFrete := CDT->CDT_INDFRT
					EndIf
				EndIf

				If Empty(cFrete)
					If !Empty(cOpSemF) .And. AllTrim((cAliasSFT)->FT_CFOP)$cOpSemF
						cFrete	:= "9"
					Else
						cFrete	:=  SPEDSitFrt(cAliasSFT,'',.T.,'','F1_FRETE',.T.,.T.,.T.)
					EndIf
				EndIf


				//-------------------------------------------------------------------
				//Processa cabecalho do C100
				//-------------------------------------------------------------------
				nRelacPai	:= ProcC100(cC010, oBlocoC, cAliasSFT,cCodPart,cIndPagto,cEspecie,aParPe[SPDPIS08],cFrete,aparPE[SPDPIS05],aparSX6[MV_CF3ENTR],lSitDocCDT,cSitExt, aparSX6[MV_EFDSERI], Iif( lSM0Dup, lMT, .f.))
				cRelacPai	:= oBlocoC:getGrupo()				
				PutGlbValue( cC010, ".F." )
				

				//Processa registro C110
				If !cSituaDoc$"02#04#05"
					ProcCDT("C110",cRelacPai,c0140,oBloco0, oBlocoC,oTabela,cAliasSFT,nSPDIFC, Iif(cEntSai =='1' ,lF1Mennota ,lF2Mennota),lSPDPISIC)
				Endif
				//-------------------------------------------------
				//Verifica se é registro de Importação para processar registro C120
				//-------------------------------------------------
				IF  cEntSai == '1' .AND. cEspecie$"01/55" .AND. lEasy
					PrcCD5BlcC(cRelacPai,oBlocoC,cAliasSFT,lEasy,lSPDIMP,'C120')
				EndIF

			ElseiF (cEspecie $ cEspC500 .AND. cEntSai =='1') .OR. lEnerEle

				//-------------------------------------------------------------------
				//Processa registro 0150 do participante
				//-------------------------------------------------------------------
				cCodPart	:= FSA0080150(c0140, oTabela, oBloco0, cClieFor, cAliasSFT,lConcFil)

				//Processa registro 0450 com informações complementares
				cInfCompl	:= ProcCDT("0450",'', c0140, oBloco0, , oTabela, cAliasSFT, 2, .f. ,.f.)

				//-------------------------------------------------------------------
				//Processa cabecalho do C500
				//-------------------------------------------------------------------
				nRelacPai	:= ProcC500(cC010, oBlocoC,cAliasSFT,cCodPart,cInfCompl,cEspecie, aparSX6[MV_EFDSERI],cSituaDoc)
				cRelacPai	:= oBlocoC:getGrupo()				
				PutGlbValue( cC010, ".F." )


			ElseIF cEspecie $ '02/65' .AND. cEntSai =='1'

				//-------------------------------------------------------------------
				//Processa registro 0150 do participante
				//-------------------------------------------------------------------
				IF !cSituaDoc$"02#04#05"
					cCodPart	:= FSA0080150(c0140, oTabela, oBloco0, cClieFor, cAliasSFT,lConcFil)
				EndIF

				//-------------------------------------------------------------------
				//Processa cabecalho do C395
				//-------------------------------------------------------------------
				nRelacPai	:= ProcC395(cC010, oBlocoC,cAliasSFT,cCodPart,cEspecie,aparSX6[MV_EFDSERI] )
				cRelacPai	:= oBlocoC:getGrupo()				
				PutGlbValue( cC010, ".F." )


			ElseIF cEspecie $'07/08/09/10/11/26/27/57/63/67/8B'
				IF cEntSai == '1' 
				//Processa registro D100

				//-------------------------------------------------------------------
				//Processa registro 0150 do participante
				//-------------------------------------------------------------------
					cCodPart	:= FSA0080150(c0140, oTabela, oBloco0, cClieFor, cAliasSFT,lConcFil)

				//-------------------------------------------------------------------
				//Processa conta contábil
				//-------------------------------------------------------------------
					cConta	:= FSA0080500('', oBloco0,oTabela,lConcFil,(cAliasSFT)->FT_CONTA,cAliasSFT)

				//-------------------------------------------------------------------
				//Processa cabecalho do D100
				//-------------------------------------------------------------------
					nRelacPai	:= ProcD100(cD010, oBlocoD,cAliasSFT, cCodPart,cConta,cOpSemF,cEspecie, aparSX6[MV_EFDSERI], (cAliasSFT)->(F3_CODRSEF),cSituaDoc)
					cRelacPai	:= oBlocoD:getGrupo()					
					PutGlbValue( cD010, ".F." )					

					//Processa registro 0450
					ProcCDT("0450",'', c0140, oBloco0, , oTabela, cAliasSFT, 2, .f. ,.f.)
				EndIF

			ElseIF cEspecie $ '21/22'
				
				If ProcNf
					//-------------------------------------------------------------------
					//Processa registro 0150 do participante
					//-------------------------------------------------------------------
					cCodPart	:= FSA0080150(c0140, oTabela, oBloco0, cClieFor, cAliasSFT,lConcFil)

					//-------------------------------------------------------------------
					//Processa conta contábil
					//-------------------------------------------------------------------
					cConta	:= FSA0080500('', oBloco0,oTabela,lConcFil,(cAliasSFT)->FT_CONTA,cAliasSFT)
					//Processa 0450
					cInfCompl	:= ProcCDT("0450",'', c0140, oBloco0, , oTabela, cAliasSFT, 2, .f. ,.f.)

					nRelacPai	:= ProcD500(cD010, oBlocoD,cAliasSFT, cCodPart,cInfCompl,cEspecie,cConta,aParSX3[FP_F1_SUBSERI], aparSX6[MV_EFDSERI],cSituaDoc)
					cRelacPai	:= oBlocoD:getGrupo()				
					PutGlbValue( cD010, ".F." )
				Else
					//Move para o proximo item da SFT
					(cAliasSFT)->(DbSkip ())
					//Volta para início do laço
					Loop
				EndIf

			ElseIF cEspecie $ "59" .AND. !cSituaDoc$'02/03/05'
				//Processa cabecalho do C860
				nRelacPai	:= ProcC860(cC010, oBlocoC, cAliasSFT)
				cRelacPai	:= oBlocoC:getGrupo()				
				PutGlbValue( cC010, ".F." )

			EndIF

		//Monta chave da nota para poder processar os itens
			cChaveNf	:=	(cAliasSFT)->FT_FILIAL+(cAliasSFT)->FT_TIPOMOV+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA
			lProc1Item		:= .F.
		//-------------------------------------------------
		//Abaixo irá fazer laço dos itens da nota fiscal
		//-------------------------------------------------
			Do While !(cAliasSFT)->(Eof ()) .And.;
					cChaveNf==(cAliasSFT)->FT_FILIAL+;
					(cAliasSFT)->FT_TIPOMOV+;
					(cAliasSFT)->FT_SERIE+;
					(cAliasSFT)->FT_NFISCAL+;
					(cAliasSFT)->FT_CLIEFOR+;
					(cAliasSFT)->FT_LOJA

			//----------------------------------------------------------------
			//Verifica se espécie, CFOP irá ser considerados no processamento
			//----------------------------------------------------------------
				If oApurEFD:ChkRegraNf((cAliasSFT)->FT_ESPECIE,(cAliasSFT)->FT_CFOP,cEntSai,cEspecie,,(cAliasSFT)->FT_CSTPIS)
					//Indica que ao menos um item da nota foi processado e deverá gravar registro
					lProc1Item	:= .T.
					nNumItem++
					cCusto		:= ''
					cCodProd	:= ''
					cDescrProd	:= ''
					cConta		:= ''
					cCodMun		:= ''
					aProd		:=  {"","","","","","","","","","",""}
					cStMoto		:= ''
					cCodNat		:= ''

					oBlocoA:setDedbpis(aParSX6[MV_DEDBPIS])
					oBlocoC:setDedbpis(aParSX6[MV_DEDBPIS])
					oBlocoD:setDedbpis(aParSX6[MV_DEDBPIS])
					oBlocoF:setDedbpis(aParSX6[MV_DEDBPIS])

					oBlocoA:setDedbcof(aParSX6[MV_DEDBCOF])
					oBlocoC:setDedbcof(aParSX6[MV_DEDBCOF])
					oBlocoD:setDedbcof(aParSX6[MV_DEDBCOF])
					oBlocoF:setDedbcof(aParSX6[MV_DEDBCOF])

					If (Empty(cEspecie) .OR. (!aParSX6[MV_DFSRVAC] .AND. cEspecie == '55' .AND. (cAliasSFT)->FT_TIPO == 'S' .AND. cMVESTADO == 'DF' .AND. !lConjugada)) .AND. !cSituaDoc == '02'
					//-------------------------------------------------
					//PROCESSA ITENS da Familia A100
					//-------------------------------------------------
						If ! cSituaDoc $ "03|04|05" .And. (cAliasSFT)->F4_ATUATF <> 'S'

							//-------------------------------------------------
							//Processa Conta Contábil
							//-------------------------------------------------
							cConta	:= FSA0080500('', oBloco0,oTabela,lConcFil,(cAliasSFT)->FT_CONTA,cAliasSFT)

							//-------------------------------------------------
							//Processa Centro de Custo
							//-------------------------------------------------
							If (cAliasSFT)->FT_TIPOMOV == 'E'
								cCusto	:= FSA0080600('',oBloco0,oTabela,lConcFil,(cAliasSFT)->D1_CC,cAliasSFT)
							Else
								cCusto	:= FSA0080600('',oBloco0,oTabela,lConcFil,(cAliasSFT)->D2_CCUSTO,cAliasSFT)
							EndIF

							//-------------------------------------------------
							//Processa produto utilizado no Item
							//-------------------------------------------------
							If aParPE[SPEDPROD]
								aProd := Execblock("SPEDPROD", .F., .F., {cAliasSFT})
							EndIF
							cCodProd	:= FSA0080200(c0140, oBloco0, aProd, cAliasSFT, oTabela, lConcFil, ;
								nICMPAD, (cAliasSFT)->CD6_CODANP, (cAliasSFT)->B5_TABINC,;
								(cAliasSFT)->B5_CODGRU, (cAliasSFT)->B5_MARCA,,dDataIni)
							//Descrição do item
							IF !Empty(aProd[2])
								cDescrProd	:= aProd[2]
							Else
								cDescrProd	:= (cAliasSFT)->B1_DESC
							EndIF

							//-------------------------------------------------
							//PROCESSA ITENS da Familia A170
							//-------------------------------------------------
							ProcA170(cRelacPai, oBlocoA, cAliasSFT,nRelacPai,cCusto,cConta,cCodProd,cDescrProd,(cAliasSFT)->FT_ITEM)

							//Verifica processo referenciado A111
							IF (cAliasSFT)->COUNTCDG >= 1
								BuscaCDG(cRelacPai, aParCompl, oBlocoA, oBloco1,'A111', 'A170', lTabCIE, aDate[1], (cAliasSFT)->FT_ITEM, cCodProd, cConta, cCusto, cCodPart,(cAliasSFT)->FT_CHVNFE)
							ENDIF

							//Para documento de entrada, irá verificar se existe informação de complemento
							//de importação para geração do registro A120.
							IF cEntSai=='1'
								aParItem	:= {}
								aAdd(aParItem,(cAliasSFT)->FT_NFISCAL)
								aAdd(aParItem,(cAliasSFT)->FT_SERIE)
								aAdd(aParItem,(cAliasSFT)->FT_CLIEFOR)
								aAdd(aParItem,(cAliasSFT)->FT_LOJA)
								aAdd(aParItem,(cAliasSFT)->FT_ITEM)
								//Geração do registro A120
								ProcCD5(cRelacPai, cAliasSFT,  aParItem, oBlocoA)
							EndIF
						EndIF

					ElseIF cEspecie $ '01/04/1B' .OR. (cEspecie == "55" .AND. !lConIndiv .AND. !lEnerEle .AND. !cSituaDoc == '02')

						//----------------------------------------------------------------
						//Processamento do registro 0400
						//----------------------------------------------------------------
						IF !(cSituaDoc$"02/04/05") .And. Iif(ValType(mv_par22) == "N", mv_par22 == 1, .T.)
							cCodNat:= Reg0400(cAliasSFT,lSpedNat,oTabela,oBloco0,c0140)
						EndIF

						//-------------------------------------------------
						//Processa conta contábil do item
						//-------------------------------------------------
						cConta	:= FSA0080500('', oBloco0,oTabela,lConcFil,(cAliasSFT)->FT_CONTA,cAliasSFT)

						//-------------------------------------------------
						//Processa código do produto do item
						//-------------------------------------------------
						If aParPE[SPEDPROD]
							aProd := Execblock("SPEDPROD", .F., .F., {cAliasSFT})
						EndIF
						cUnid	:= (cAliasSFT)->B1_UM
						nQtde	:= (cAliasSFT)->FT_QUANT
						IF aParPE[SPDFIS02]

							aSpdFis02 := ExecBlock("SPDFIS02", .F., .F., {cAliasSFT,(cAliasSFT)->FT_TIPOMOV})

							If valtype(aSpdFis02) == 'A'
								cUnid     := aSpdFis02[1]
							    nQtde     := aSpdFis02[2]
							ElseIf valtype(aSpdFis02) == 'C'
								cUnid     := aSpdFis02
							EndIF

						EndIF

						cCodProd	:= FSA0080200(c0140, oBloco0, aProd, cAliasSFT, oTabela, lConcFil, ;
							nICMPAD, (cAliasSFT)->CD6_CODANP, (cAliasSFT)->B5_TABINC,;
							(cAliasSFT)->B5_CODGRU, (cAliasSFT)->B5_MARCA,cUnid,dDataIni)

						IF (cAliasSFT)->FT_TNATREC == '4312' .AND. SubStr((cAliasSFT)->FT_CNATREC,1,2) $ '20/30' .AND. cEspecie $ '01/55'
							cStMoto	:= '1' //Indica que tem tratamento de ST de moto, e o primeiro item deverá ter o valor do item zerado no registro C170
						EndIF


						//-------------------------------------------------
						//Processa registro C170
						//-------------------------------------------------

						nValSt	:= FSA008VLST(cAliasSFT,cEntSai,cMVEstado,cMVSUBTRIB,cMVCFE210, aParSX6[MV_STUFS] , aParSX6[MV_STUF] , aParSX6[MV_RESF3FT] , aParSX6[MV_STNIEUF])

						ProcC170(cRelacPai, oBlocoC, cAliasSFT,nRelacPai,cConta,;
								  cCodProd,aParPE[SPDFIS03],cClieFor,aparSX6[MV_STFRETE],AllTrim (STR (nNumItem)),;
								  aParPE[SPDFIS04],cStMoto,cUnid,nQtde,aparSX6[MV_CONTZF],;
								  cCodNat,aParSX6[MV_PISCOFP],nValSt, aDadAtv[2], aparSX6[MV_ICMDSDT])

						//Gera processo referenciado desta nota fiscal
						IF (cAliasSFT)->COUNTCDG >= 1
							BuscaCDG(cRelacPai, aParCompl, oBlocoC, oBloco1, 'C111', 'C170', lTabCIE, aDate[1], (cAliasSFT)->FT_ITEM, cCodProd, cConta, cCusto, cCodPart,(cAliasSFT)->FT_CHVNFE)
						Endif

					//Verifica se o item teve tratamento de ST de moto, se teve então deverá gerar o segundo item em C170 que é com CST 01
						IF cStMoto == '1' .And. !((cAliasSFT)->FT_TIPO $ 'D|B')
							cStMoto := '2'
							nNumItem++
							ProcC170(cRelacPai, oBlocoC, cAliasSFT,nRelacPai,cConta,cCodProd,aParPE[SPDFIS03],cClieFor,aparSX6[MV_STFRETE],AllTrim (STR (nNumItem)),aParPE[SPDFIS04],cStMoto,cUnid,nQtde,aparSX6[MV_CONTZF],cCodNat,aParSX6[MV_PISCOFP], , aDadAtv[2], aparSX6[MV_ICMDSDT])
							cStMoto	:= ''
						EndIF

					//-------------------------------------------------
					//Verifica se é registro de Importação para processar registro C120
					//-------------------------------------------------
						IF  cEntSai == '1' .AND. cEspecie$"01/55" .AND. !lEasy
							PrcCD5BlcC(cRelacPai,oBlocoC,cAliasSFT,lEasy,lSPDIMP,'C120')
						EndIF

					ElseIF cEspecie $ '65' .AND.  cEntSai =='2'

					//-------------------------------------------------
					//Processa conta contábl do item
					//-------------------------------------------------
						cConta	:= FSA0080500('', oBloco0,oTabela,lConcFil,(cAliasSFT)->FT_CONTA,cAliasSFT)
					//-------------------------------------------------
					//Processa registro C175 para NFCE
					//-------------------------------------------------
						ProcC175(cRelacPai, oBlocoC, cAliasSFT,nRelacPai,cConta,aParSX6[MV_PISCOFP], aparSX6[MV_ICMDSDT])

						//Gera processo referenciado desta nota fiscal
						IF (cAliasSFT)->COUNTCDG >= 1
							BuscaCDG(cRelacPai, aParCompl, oBlocoC, oBloco1, 'C111', 'C175', lTabCIE, aDate[1], (cAliasSFT)->FT_ITEM, cCodProd, cConta, cCusto, cCodPart,(cAliasSFT)->FT_CHVNFE)
						ENDIF

					ElseiF cEspecie $'55' .AND.  !cSituaDoc$'02/03/04/05' .AND. !lEnerEle
						If  lConIndiv .AND.  cEntSai=='2' .AND. !(cAliasSFT)->FT_TIPO$"D"

						//-------------------------------------------------
						//Processa conta contábl do item
						//-------------------------------------------------
							cConta	:= FSA0080500('', oBloco0,oTabela,lConcFil,(cAliasSFT)->FT_CONTA,cAliasSFT)

						//-------------------------------------------------
						//Processa código do produto do item
						//-------------------------------------------------
							If aParPE[SPEDPROD]
								aProd := Execblock("SPEDPROD", .F., .F., {cAliasSFT})
							EndIF
							cCodProd	:= FSA0080200(c0140, oBloco0, aProd, cAliasSFT, oTabela, lConcFil, ;
								nICMPAD, (cAliasSFT)->CD6_CODANP, (cAliasSFT)->B5_TABINC,;
								(cAliasSFT)->B5_CODGRU, (cAliasSFT)->B5_MARCA,,dDataIni)

						//-------------------------------------------------
						//PROCESSA família C180
						//-------------------------------------------------
							IF (cAliasSFT)->FT_TNATREC == '4312' .AND. SubStr((cAliasSFT)->FT_CNATREC,1,2) $ '20/30' .AND. cEspecie == '55'
								cStMoto	:= '1' //Indica que tem tratamento de ST de moto, e o primeiro item deverá ter o valor do item zerado no registro C170
							EndIF

							cRelacPai	:= ProcC180(cC010, oBlocoC, cAliasSFT,cCodProd,cConta,cStMoto,aParSX6[MV_PISCOFP],aparSX6[MV_ICMDSDT])							
							PutGlbValue( cC010, ".F." )

							//-------------------------------------------------
							//Processa informações de processo referenciado, registro C188
							//-------------------------------------------------
							IF (cAliasSFT)->COUNTCDG >= 1
								BuscaCDG(cRelacPai, aParCompl, oBlocoC, oBloco1 ,'C188','C180', lTabCIE, aDate[1], (cAliasSFT)->FT_ITEM, cCodProd, cConta, cCusto, cCodPart,(cAliasSFT)->FT_CHVNFE)
							ENDIF

						//Verifica se o item teve tratamento de ST de moto, se teve então deverá gerar o segundo item em C170 que é com CST 01
							IF cStMoto == '1'
								cStMoto := '2'
								ProcC180(cC010, oBlocoC, cAliasSFT,cCodProd,cConta,cStMoto,aParSX6[MV_PISCOFP], aparSX6[MV_ICMDSDT])
								cStMoto	:= ''								
								PutGlbValue( cC010, ".F." )
							EndIF



						ElseIf !lEnerEle .AND. (cEntSai=="1" .OR. ( cEntSai=="2" .AND. ((cAliasSFT)->FT_TIPO$"D") .AND.;
								((cAliasSFT)->FT_CSTPIS$"49") .AND. ((cAliasSFT)->FT_CSTCOF$"49") ))
							IF !(cSituaDoc$"02#04#05")
							//-------------------------------------------------
							//Processa conta contábl do item
							//-------------------------------------------------
								cConta	:= FSA0080500('', oBloco0,oTabela,lConcFil,(cAliasSFT)->FT_CONTA,cAliasSFT)

							//-------------------------------------------------
							//Processa código do produto do item
							//-------------------------------------------------
								If aParPE[SPEDPROD]
									aProd := Execblock("SPEDPROD", .F., .F., {cAliasSFT})
								EndIF
								cCodProd	:= FSA0080200(c0140, oBloco0, aProd, cAliasSFT, oTabela, lConcFil, ;
									nICMPAD, (cAliasSFT)->CD6_CODANP, (cAliasSFT)->B5_TABINC,;
									(cAliasSFT)->B5_CODGRU, (cAliasSFT)->B5_MARCA,,dDataIni)

							//-------------------------------------------------
							//PROCESSA família C190
							//-------------------------------------------------
								cRelacPai	:= ProcC190(cC010, oBlocoC, cAliasSFT,cCodProd,cConta,aParSX6[MV_PISCOFP], aparSX6[MV_ICMDSDT], aDadAtv[2])								
								PutGlbValue( cC010, ".F." )

								//-------------------------------------------------
								//Processa informações de processo referenciado, registro C198
								//-------------------------------------------------
								IF (cAliasSFT)->COUNTCDG >= 1
									BuscaCDG(cRelacPai, aParCompl, oBlocoC,oBloco1 ,'C198','C190', lTabCIE, aDate[1], (cAliasSFT)->FT_ITEM, cCodProd, cConta, cCusto, cCodPart,(cAliasSFT)->FT_CHVNFE)
								ENDIF

								IF cEntSai=="1"
							//Processa registro C199 para Nota fiscal eletrônica
									PrcCD5BlcC(cRelacPai,oBlocoC,cAliasSFT, lEasy,lSPDIMP, 'C199' )
								EndIF
							EndIF
						EndIF

					ElseIF cEspecie $'02/65' .AND. cEntSai =='1'

						//-------------------------------------------------
						//Processa conta contábl do item
						//-------------------------------------------------
						cConta	:= FSA0080500('', oBloco0,oTabela,lConcFil,(cAliasSFT)->FT_CONTA,cAliasSFT)

						//-------------------------------------------------
						//Processa código do produto do item
						//-------------------------------------------------
						If aParPE[SPEDPROD]
							aProd := Execblock("SPEDPROD", .F., .F., {cAliasSFT})
						EndIF
						cCodProd	:= FSA0080200(c0140, oBloco0, aProd, cAliasSFT, oTabela, lConcFil, ;
							nICMPAD, (cAliasSFT)->CD6_CODANP, (cAliasSFT)->B5_TABINC,;
							(cAliasSFT)->B5_CODGRU, (cAliasSFT)->B5_MARCA,,dDataIni)

						//-------------------------------------------------
						//PROCESSA família C395
						//-------------------------------------------------
						ProcC396(cRelacPai, oBlocoC, cAliasSFT,cCodProd,cConta,nRelacPai)

					ElseIF (cEspecie $ cEspC500 .OR. lEnerEle)  .And. (!cSituaDoc $ "02#04#05" .OR. (cSituaDoc == '02' .And. cEspecie == '29' ))

						If cEntSai =='1' .AND. !cSituaDoc =='02' //Cancelada

							//-------------------------------------------------
							//Processa conta contábl do item
							//-------------------------------------------------
							cConta	:= FSA0080500('', oBloco0,oTabela,lConcFil,(cAliasSFT)->FT_CONTA,cAliasSFT)

							//-------------------------------------------------
							//PROCESSA família C500
							//-------------------------------------------------
							PrcC501505(cRelacPai, oBlocoC, cAliasSFT,nRelacPai,cConta)

							//Gera processo referenciado desta nota fiscal
							IF (cAliasSFT)->COUNTCDG >= 1
								BuscaCDG(cRelacPai, aParCompl, oBlocoC, oBloco1, 'C509','C500', lTabCIE, aDate[1], (cAliasSFT)->FT_ITEM, cCodProd, cConta, cCusto, cCodPart,(cAliasSFT)->FT_CHVNFE)
							ENDIF
						ElseIf cEntSai =="2"

							//-------------------------------------------------
							//Processa conta contábl do item
							//-------------------------------------------------
							cConta	:= FSA0080500('', oBloco0,oTabela,lConcFil,(cAliasSFT)->FT_CONTA,cAliasSFT)
							cCodMun	:= CodMunPart((cAliasSFT)->A1_CODPAIS, (cAliasSFT)->A1_EST,(cAliasSFT)->A1_COD_MUN) //Alterado para buscar codmun cliente

							//-------------------------------------------------
							//PROCESSA família C600
							//-------------------------------------------------
							nValSt	:= FSA008VLST(cAliasSFT,cEntSai,cMVEstado,cMVSUBTRIB,cMVCFE210, aParSX6[MV_STUFS] , aParSX6[MV_STUF] , aParSX6[MV_RESF3FT] , aParSX6[MV_STNIEUF])

							cRelacPai	:= PrcC600(cC010, oBlocoC, cAliasSFT,cConta,cCodMun,cEspecie,aParPE[SPDPIS06],nValSt, lEnerEle, aparSX6[MV_EFDSERI], aparSX6[MV_ICMDSDT], cSituaDoc)
							PutGlbValue( cC010, ".F." )

							//-------------------------------------------------
							//Processa informações de processo referenciado, registro C609
							//-------------------------------------------------
							IF (cAliasSFT)->COUNTCDG >= 1
								BuscaCDG(cRelacPai, aParCompl, oBlocoC, oBloco1,'C609','C600', lTabCIE, aDate[1], (cAliasSFT)->FT_ITEM, cCodProd, cConta, cCusto, cCodPart,(cAliasSFT)->FT_CHVNFE)
							ENDIF
						EndIF

					ElseIF cEspecie $'02' .AND. cEntSai =='2' .AND. !cSituaDoc == '02' .AND. !Alltrim((cAliasSFT)->FT_ESPECIE) $ 'CF/ECF'

						//-------------------------------------------------
						//Processa conta contábl do item
						//-------------------------------------------------
						cConta	:= FSA0080500('', oBloco0,oTabela,lConcFil,(cAliasSFT)->FT_CONTA,cAliasSFT)

						//-------------------------------------------------
						//Processa código do produto do item
						//-------------------------------------------------
						If aParPE[SPEDPROD]
							aProd := Execblock("SPEDPROD", .F., .F., {cAliasSFT})
						EndIF
						cCodProd	:= FSA0080200(c0140, oBloco0, aProd, cAliasSFT, oTabela, lConcFil, ;
							nICMPAD, (cAliasSFT)->CD6_CODANP, (cAliasSFT)->B5_TABINC,;
							(cAliasSFT)->B5_CODGRU, (cAliasSFT)->B5_MARCA,,dDataIni)

						//-------------------------------------------------
						//PROCESSA família C380
						//-------------------------------------------------
						ProcC380(cC010, oBlocoC, cAliasSFT,cCodProd,cConta,aParSX6[MV_PISCOFP],cSituaDoc)						
						PutGlbValue( cC010, ".F." )

					ElseIF cEspecie $'07/08/09/10/11/26/27/57/63/67/8B'
						//-------------------------------------------------
						//PROCESSA ITENS DO BLOCO d
						//-------------------------------------------------
						IF cEntSai == '1'

							//-------------------------------------------------
							//Processa conta contábl do item
							//-------------------------------------------------
							cConta	:= FSA0080500('', oBloco0,oTabela,lConcFil,(cAliasSFT)->FT_CONTA,cAliasSFT)

							//-------------------------------------------------
							//PROCESSA família D100
							//-------------------------------------------------
							PrcD101105(cRelacPai, oBlocoD, cAliasSFT,nRelacPai,cConta,aDadAtv[2])

							//Gera processo referenciado desta nota fiscal
							IF (cAliasSFT)->COUNTCDG >= 1
								BuscaCDG(cRelacPai, aParCompl, oBlocoD, oBloco1,'D111','D100', lTabCIE, aDate[1], (cAliasSFT)->FT_ITEM, cCodProd, cConta, cCusto, cCodPart,(cAliasSFT)->FT_CHVNFE)
							ENDIF
						ElseIF cEntSai == '2'
							IF !cSituaDoc$"02#03#04#05"
							//-------------------------------------------------
							//Processa conta contábl do item
							//-------------------------------------------------
								cConta	:= FSA0080500('', oBloco0,oTabela,lConcFil,(cAliasSFT)->FT_CONTA,cAliasSFT)

							//-------------------------------------------------
							//PROCESSA família D200
							//-------------------------------------------------
								cRelacPai:= ProcD200(cD010, oBlocoD,cAliasSFT,cConta,cEspecie, aparSX6[MV_EFDSERI], (cAliasSFT)->(F3_CODRSEF),cSituaDoc)								
								PutGlbValue( cD010, ".F." )

								//-------------------------------------------------
								//Processa informações de processo referenciado, registro D209
								//-------------------------------------------------
								IF (cAliasSFT)->COUNTCDG >= 1
									BuscaCDG(cRelacPai, aParCompl, oBlocoD, oBloco1 ,'D209','D200', lTabCIE, aDate[1], (cAliasSFT)->FT_ITEM, cCodProd, cConta, cCusto, cCodPart,(cAliasSFT)->FT_CHVNFE)
								ENDIF
							EndIF

						EndIF
					ElseIF cEspecie $ '21/22'
						//-------------------------------------------------
						//Processa conta contábl do item
						//-------------------------------------------------
						cConta	:= FSA0080500('', oBloco0,oTabela,lConcFil,(cAliasSFT)->FT_CONTA,cAliasSFT)
						IF cEntSai == '1'
							lProcD501505 := ChkNf(cChave,cEntSai,aCFOPs,cAliasSFT, .F.,.T.)

							If lProcD501505
								PrcD501505(cRelacPai, oBlocoD, cAliasSFT,nRelacPai,cConta)

								IF (cAliasSFT)->COUNTCDG >= 1
									BuscaCDG(cRelacPai, aParCompl, oBlocoD, oBloco1,  'D509','D500', lTabCIE, aDate[1], (cAliasSFT)->FT_ITEM, cCodProd, cConta, cCusto, cCodPart,(cAliasSFT)->FT_CHVNFE)
								ENDIF
							EndIf
						ElseIF cEntSai == '2' .AND.	!cSituaDoc$'02/03'
							//-------------------------------------------------
							//Processa Municipio do item
							//-------------------------------------------------
							cCodMun	:= CodMunPart((cAliasSFT)->A1_CODPAIS, (cAliasSFT)->A1_EST,(cAliasSFT)->A1_COD_MUN)
							//-------------------------------------------------
							//PROCESSA família D600
							//-------------------------------------------------
							cRelacPai	:= ProcD600(cD010, oBlocoD,cAliasSFT,cCodMun,cEspecie,aParSX6[MV_ESTTELE],cConta,(cAliasSFT)->(FT_NFISCAL + FT_SERIE + FT_CLIEFOR + FT_LOJA), aparSX6[MV_EFDSERI], aparSX6[MV_ICMDSDT] )							
							PutGlbValue( cD010, ".F." )
							IF (cAliasSFT)->COUNTCDG >= 1
								BuscaCDG(cRelacPai, aParCompl, oBlocoD, oBloco1, 'D609','D600', lTabCIE, aDate[1], (cAliasSFT)->FT_ITEM, cCodProd, cConta, cCusto, cCodPart,(cAliasSFT)->FT_CHVNFE)
							ENDIF
						EndIF
					ElseIF cEspecie $'13/18' .AND. cEntSai == '2' .AND. !cSituaDoc$'02/03'

						//-------------------------------------------------
						//Processa conta contábl do item
						//-------------------------------------------------
						cConta	:= FSA0080500('', oBloco0,oTabela,lConcFil,(cAliasSFT)->FT_CONTA,cAliasSFT)

						//-------------------------------------------------
						//PROCESSA família D300
						//-------------------------------------------------
						cRelacPai	:= ProcD300(cD010, oBlocoD,cAliasSFT,cConta,cEspecie, aparSX6[MV_EFDSERI], aparSX6[MV_ICMDSDT])						
						PutGlbValue( cD010, ".F." )

						//-------------------------------------------------
						//Processa informações de processo referenciado, registro D309
						//-------------------------------------------------
						IF (cAliasSFT)->COUNTCDG >= 1
							BuscaCDG(cRelacPai, aParCompl, oBlocoD, oBloco1, 'D309','D300',lTabCIE, aDate[1], (cAliasSFT)->FT_ITEM, cCodProd, cConta, cCusto, cCodPart,(cAliasSFT)->FT_CHVNFE)
						ENDIF


					ElseIF cEspecie $ "59" .AND. !cSituaDoc$'02/03/05'
						//Processa código do produto do item
						If aParPE[SPEDPROD]
							aProd := Execblock("SPEDPROD", .F., .F., {cAliasSFT})
						EndIF
						cCodProd	:= FSA0080200(c0140, oBloco0, aProd, cAliasSFT, oTabela, lConcFil, ;
										nICMPAD, (cAliasSFT)->CD6_CODANP, (cAliasSFT)->B5_TABINC,;
										(cAliasSFT)->B5_CODGRU, (cAliasSFT)->B5_MARCA,,dDataIni)
						//Processa conta contábl do item
						cConta	:= FSA0080500('',oBloco0,oTabela,lConcFil,(cAliasSFT)->FT_CONTA,cAliasSFT)

						//-------------------------------------------------
						//Processa informações de processo referenciado, registro C188
						//-------------------------------------------------
						IF (cAliasSFT)->COUNTCDG >= 1
							BuscaCDG(cRelacPai, aParCompl, oBlocoC, oBloco1 ,'C890','C860', lTabCIE, aDate[1], (cAliasSFT)->FT_ITEM, cCodProd, cConta, cCusto, cCodPart,(cAliasSFT)->FT_CHVNFE)
						Endif

						IF (cAliasSFT)->FT_CSTPIS <> '03'
							//Processa cabecalho do C870
							ProcC870(cRelacPai, oBlocoC, oBloco0, oTabela, lConcFil, cAliasSFT, cCodProd, cConta, aparSX6[MV_ICMDSDT])
						Else
							//Processa cabecalho do C880
							ProcC880(cRelacPai, oBlocoC, oBloco0, oTabela, lConcFil, cAliasSFT, cCodProd, cConta, aparSX6[MV_ICMDSDT])
						EndIF

					EndiF
				EndIF

				(cAliasSFT)->(DbSkip ())
			EndDo

		//-------------------------------------------------
		//Aqui foram finalizados os itens da nota fiscal
		//Abaixo irá gravar os registros que são gerados por
		//nota, e atualizados os que são gravados somente
		//quando finalizar todas as notas.
		//-------------------------------------------------
			If Empty(cEspecie) .OR. (!aParSX6[MV_DFSRVAC] .AND. cEspecie == '55' .AND. cMVESTADO == 'DF' .AND. Len(oBlocoA:getA100()) > 0)
				//-------------------------------------------------
				//Gravação dos registros da família A100
				//-------------------------------------------------
				if !lSM0Dup .or. !lMT
					If lProc1Item
						oTabela:GrvReg(oBlocoA:getA100())
						oTabela:GrvReg(oBlocoA:getA110())
						oTabela:GrvReg(oBlocoA:getA111())
						oTabela:GrvReg(oBlocoA:getA120())
						oTabela:GrvReg(oBlocoA:getA170())
					EndIF
					oBlocoA:clsA100()
				endif
			ElseIF cEspecie $ '01/04/1B' .OR. (cEspecie == "55" .AND. !lConIndiv .AND. !lEnerEle) .OR. (cEspecie == '65' .AND. cEntSai == '2')
				//-------------------------------------------------
				//Gravação dos registros da família C100
				//-------------------------------------------------
				if !lSM0Dup .or. !lMT
					IF lProc1Item
						oTabela:GrvReg(oBlocoC:getC100())
						oTabela:GrvReg(oBlocoC:getC111())
						oTabela:GrvReg(oBlocoC:getC110())
						If !cSituaDoc$'02/03/04/05'
							oTabela:GrvReg(oBlocoC:getC120())
							oTabela:GrvReg(oBlocoC:getC170())
							oTabela:GrvReg(oBlocoC:getC175())
						EndIF
					EndIF
					oBlocoC:clsC100()
				endif

			ElseiF cEspecie $'55' .AND.  !cSituaDoc$'02/04/05' .AND. !lEnerEle
				If  lConIndiv .AND.  cEntSai=='2'
				//retirar aqui
				ElseIF cEntSai=='1'

				EndIF
			ElseIF (cEspecie $ cEspC500 .OR. lEnerEle) .AND. !cSituaDoc$'02/04/05'
				If cEntSai =="2" .AND. cEspecie <> "55"


				ElseIf cEntSai =='1' .AND. !cSituaDoc =='02'
				//-------------------------------------------------
				//Gravação dos registros da família C500
				//-------------------------------------------------
					oTabela:GrvReg(oBlocoC:getC500())
					oTabela:GrvReg(oBlocoC:getC501())
					oTabela:GrvReg(oBlocoC:getC505())
					oTabela:GrvReg(oBlocoC:getC509())
					oBlocoC:clsC500()
				EndIF

			ElseIF cEspecie $'02/65' .AND. cEntSai =='1'

				//-------------------------------------------------
				//Gravação dos registros da família C395
				//-------------------------------------------------
				oTabela:GrvReg(oBlocoC:getC395())
				oTabela:GrvReg(oBlocoC:getC396())
				oBlocoC:clsC395()

			ElseIF cEspecie $'07/08/09/10/11/26/27/57/63/67/8B'
				IF cEntSai == '1'
					//-------------------------------------------------
					//Gravação dos registros da família D100
					//-------------------------------------------------
					oTabela:GrvReg(oBlocoD:getD100())
					oTabela:GrvReg(oBlocoD:getD101())
					oTabela:GrvReg(oBlocoD:getD105())
					oTabela:GrvReg(oBlocoD:getD111())
					oBlocoD:clsD100()

				ElseIF cEntSai == '2'
					IF !cSituaDoc$"02#03#04#05"

					EndIF
				EndIF

			ElseIF cEspecie $'13/18' .AND. cEntSai == '2' .AND. !cSituaDoc$'02/03'


			ElseIF cEspecie $ '21/22'
				IF cEntSai == '1'
					//-------------------------------------------------
					//Gravação dos registros da família D500
					//-------------------------------------------------
					oTabela:GrvReg(oBlocoD:getD500())
					oTabela:GrvReg(oBlocoD:getD501())
					oTabela:GrvReg(oBlocoD:getD505())
					oTabela:GrvReg(oBlocoD:getD509())
					oBlocoD:clsD500()
				ElseIF cEntSai == '2'
					oBlocoD:clsD500()
				EndIF
			ElseiF cEspecie $'59' .AND.  !cSituaDoc$'02/04/05' .And. cEntSai=='2'

			EndIF
		EndIf //C100CAN

	EndDo

	DbSelectArea (cAliasSFT)
	(cAliasSFT)->(DbCloseArea())
	Next nMovto

	//Processa cupom fiscal
	IF lGeraECF

		//-------------------------------------------------
		//Chama integração função para processar integração
		//-------------------------------------------------

		ProcECF(cLivro, cC010,  dDataIni, dDataFim,lConIndiv, oBlocoC,oBloco1,oBloco0,oTabela,lConcFil,nICMPAD,c0140)

		//-------------------------------------------------
		//Se usuário escolher processar de forma consolidada
		// irá gerar família C490
		//-------------------------------------------------
		IF lConIndiv .AND. !lMT
			//-------------------------------------------------
			//Grava família C490
			//-------------------------------------------------
			oTabela:GrvReg(oBlocoC:getC490())
			oTabela:GrvReg(oBlocoC:getC491())
			oTabela:GrvReg(oBlocoC:getC495())
			oTabela:GrvReg(oBlocoC:getC499())
			oBlocoC:clsC490()

		ElseIF !lMT
			//-----------------------------------------------------------------------------
			//Se usuário escolher processar de forma individualizada irá gerar família D400
			//-----------------------------------------------------------------------------

			//-------------------------------------------------
			//Grava família C400
			//-------------------------------------------------
			oTabela:GrvReg(oBlocoC:getC400())
			oTabela:GrvReg(oBlocoC:getC405())
			oTabela:GrvReg(oBlocoC:getC481())
			oTabela:GrvReg(oBlocoC:getC485())
			oTabela:GrvReg(oBlocoC:getC489())
			oBlocoC:clsC400()
		EndIF
	EndIF

	// Se houver integração com o SIGAGTP chamar novamente a ProcECF para processar os bilhetes.
	If lIntGTP
		ProcECF(cLivro, cC010, dDataIni, dDataFim, lConIndiv, oBlocoC, oBloco1, oBloco0, oTabela, lConcFil, nICMPAD, c0140, .T., oBlocoD, cD010)
	EndIf

	IF lMT
		aadd(aArrayCon,oBlocoC:getC180())
		aadd(aArrayCon,oBlocoC:getC181())
		aadd(aArrayCon,oBlocoC:getC185())
		aadd(aArrayCon,oBlocoC:getC188())

		aadd(aArrayCon,oBlocoC:getC190())
		aadd(aArrayCon,oBlocoC:getC191())
		aadd(aArrayCon,oBlocoC:getC195())
		aadd(aArrayCon,oBlocoC:getC198())
		aadd(aArrayCon,oBlocoC:getC199())


		aadd(aArrayCon,oBlocoC:getC380())
		aadd(aArrayCon,oBlocoC:getC381())
		aadd(aArrayCon,oBlocoC:getC385())

		aadd(aArrayCon,oBlocoC:getC600())
		aadd(aArrayCon,oBlocoC:getC601())
		aadd(aArrayCon,oBlocoC:getC605())
		aadd(aArrayCon,oBlocoC:getC609())

		aadd(aArrayCon,oBlocoD:getD200())
		aadd(aArrayCon,oBlocoD:getD201())
		aadd(aArrayCon,oBlocoD:getD205())
		aadd(aArrayCon,oBlocoD:getD209())

		aadd(aArrayCon,oBlocoD:getD300())
		aadd(aArrayCon,oBlocoD:getD309())

		aadd(aArrayCon,oBlocoD:getD600())
		aadd(aArrayCon,oBlocoD:getD601())
		aadd(aArrayCon,oBlocoD:getD605())
		aadd(aArrayCon,oBlocoD:getD609())

		aadd(aArrayCon,oBlocoF:getF550())
		aadd(aArrayCon,oBlocoF:getF559())

		aadd(aArrayCon,oBlocoF:getF560())
		aadd(aArrayCon,oBlocoF:getF569())

		aadd(aArrayCon,oBloco1:get1900())

		aadd(aArrayCon,oBlocoC:getC490())
		aadd(aArrayCon,oBlocoC:getC491())
		aadd(aArrayCon,oBlocoC:getC495())

		aadd(aArrayCon,oBlocoC:getC499())

		aadd(aArrayCon,oBlocoC:getC400())
		aadd(aArrayCon,oBlocoC:getC405())
		aadd(aArrayCon,oBlocoC:getC481())
		aadd(aArrayCon,oBlocoC:getC485())
		aadd(aArrayCon,oBlocoC:getC489())


		aadd(aArrayCon,oBloco0:get0150())
		aadd(aArrayCon,oBloco0:get0190())
		aadd(aArrayCon,oBloco0:get0200())
		aadd(aArrayCon,oBloco0:get0206())
		aadd(aArrayCon,oBloco0:get0208())
		aadd(aArrayCon,oBloco0:get0400())
		aadd(aArrayCon,oBloco0:get0450())
		aadd(aArrayCon,oBloco0:get0500())
		aadd(aArrayCon,oBloco0:get0600())
		aadd(aArrayCon,{})//Posição reservada para registro 0205
		aadd(aArrayCon,oBlocoC:getC860())
		aadd(aArrayCon,oBlocoC:getC870())
		aadd(aArrayCon,oBlocoC:getC880())
		aadd(aArrayCon,oBlocoC:getC890())

		aadd(aArrayCon,oBlocoD:getD350())
		aadd(aArrayCon,oBlocoD:getD359())

		aadd(aArrayCon,oBloco1:get1010())
		aadd(aArrayCon,oBloco1:get1011())

		If lSM0Dup
			aadd(aArrayCon,oBlocoA:getA100())
			aadd(aArrayCon,oBlocoA:getA110())
			aadd(aArrayCon,oBlocoA:getA111())
			aadd(aArrayCon,oBlocoA:getA120())
			aadd(aArrayCon,oBlocoA:getA170())

			aadd(aArrayCon,oBlocoC:getC100())
			aadd(aArrayCon,oBlocoC:getC110())
			aadd(aArrayCon,oBlocoC:getC111())
			aadd(aArrayCon,oBlocoC:getC120())
			aadd(aArrayCon,oBlocoC:getC170())
			aadd(aArrayCon,oBlocoC:getC175())
		Endif

		While .T.	.AND.  !GetGlbValue(cJobCon) $ '03/04'
			If IPCGo( cSemaforo2,aArrayCon,''   ,c0140,'' )

				Sleep(3000)
				While .T.
					IF GetGlbValue(cJobCon) == '01'
						//Finalizou consolidação
						Exit
					ElseIF GetGlbValue(cJobCon) == '03'
						//Trhead ocorreu erro
						Exit
					EndIF
					conout(cJobCon + ' Verificando se os arrays foram consolidados: ' + GetGlbValue(cJobCon))
					Sleep(3000)
				EndDo
				Exit
			EndIF
			Sleep(3000)
		EndDo

	EndIF


	IF (lBlocACDF .OR. lRgCmpCons) .AND. !lMT

		//-------------------------------------------------
		//Gravação dos registros da família C180
		//-------------------------------------------------
		oTabela:GrvReg(oBlocoC:getC180())
		oTabela:GrvReg(oBlocoC:getC181())
		oTabela:GrvReg(oBlocoC:getC185())
		oTabela:GrvReg(oBlocoC:getC188())
		oBlocoC:clsC180()

		//-------------------------------------------------
		//Gravação dos registros da família C190
		//-------------------------------------------------
		oTabela:GrvReg(oBlocoC:getC190())
		oTabela:GrvReg(oBlocoC:getC191())
		oTabela:GrvReg(oBlocoC:getC195())
		oTabela:GrvReg(oBlocoC:getC198())
		oTabela:GrvReg(oBlocoC:getC199())
		oBlocoC:clsC190()

		//-------------------------------------------------
		//Gravação dos registros da família C380
		//-------------------------------------------------
		oTabela:GrvReg(oBlocoC:getC380())
		oTabela:GrvReg(oBlocoC:getC381())
		oTabela:GrvReg(oBlocoC:getC385())
		oBlocoC:clsC380()

		//-------------------------------------------------
		//Gravação dos registros da família C600
		//-------------------------------------------------
		oTabela:GrvReg(oBlocoC:getC600())
		oTabela:GrvReg(oBlocoC:getC601())
		oTabela:GrvReg(oBlocoC:getC605())
		oTabela:GrvReg(oBlocoC:getC609())
		oBlocoC:clsC600()

		//-------------------------------------------------
		//Gravação dos registros da família C860 (SAT)
		//-------------------------------------------------
		oTabela:GrvReg(oBlocoC:getC860())
		oTabela:GrvReg(oBlocoC:getC870())
		oTabela:GrvReg(oBlocoC:getC880())
		oTabela:GrvReg(oBlocoC:getC890())
		oBlocoC:clsC860()
		//-------------------------------------------------
		//Gravação dos registros da família D200
		//-------------------------------------------------
		//Grava registro D200 na função ProcEfd para agrupar por filial conforme manual EFD Contribuições.


		//-------------------------------------------------
		//Gravação dos registros da família D300
		//-------------------------------------------------
		oTabela:GrvReg(oBlocoD:getD300())
		oTabela:GrvReg(oBlocoD:getD309())
		oBlocoD:clsD300()

		//-------------------------------------------------
		//Gravação dos registros da família D600
		//-------------------------------------------------
		oTabela:GrvReg(oBlocoD:getD600())
		oTabela:GrvReg(oBlocoD:getD601())
		oTabela:GrvReg(oBlocoD:getD605())
		oTabela:GrvReg(oBlocoD:getD609())
		oBlocoD:clsD600()


		oTabela:GrvReg(oBlocoF:getF550())
		oTabela:GrvReg(oBlocoF:getF559())
		oTabela:GrvReg(oBlocoF:getF560())
		oTabela:GrvReg(oBlocoF:getF569())
		//oTabela:GrvReg(oBloco1:get1900())

		//oTabela:GrvReg(oBloco1:get1010())
		//oTabela:GrvReg(oBloco1:get1020())


		//-------------------------------------------------
		//Ponto de entrada para geração do registro D350
		//-------------------------------------------------
		If aParPE[SPDPISTR]
			//Processa registro D350 que é gerado através do ponto de entrada SPDPISTR
			RegD350(cD010,oBlocoD,oBloco0,oBloco1, oTabela,lConcFil,nContFil)
		Else
			oTabela:GrvReg(oBlocoD:getD350())
			oTabela:GrvReg(oBlocoD:getD359())
			oBlocoD:clsD350()
		EndIF

	EndIF

	IF lMT
		(oTabela:GetAlias())->( dbCloseArea() ) //Fecha arquivo TRB
		(oTabela:getAlsCad())->( dbCloseArea() ) //Fecha arquivo TRB
	EndIF

Return


Static Function Reg1900(dDataDe,dDataAte,cNrLivro,oBloco0,oTabela,lConcFil,oBloco1)

Local aF100Aux			:= {}
Local aRetImob			:= {}
Local aRegNf			:= {}
Local aPar1900			:= {}
Local aCFOPs			:= XFUNCFRec()
Local cCampos			:= ''
Local cEspecie			:= ''
Local cNumTit			:= ''
Local cInfComp			:= ''
Local cConta			:= ''
Local cWhere			:= ''
Local cAliasSFT			:= 'SFT'
Local lRegSFT			:= .F.

Local nPosF100			:= 0
Local nCont				:= 0
Local nPosNf			:= 0
Local nQtdNf			:= 0
Local cFrom				:= ''

DbSelectArea ("DT6")
DT6->(DbSetOrder (1))

DbSelectArea (cAliasSFT)
(cAliasSFT)->(DbSetOrder (2))

cAliasSFT	:=	GetNextAlias()

cWhere := "SFT.FT_FILIAL='"+xFilial("SFT")+"' AND "
cWhere += "SFT.FT_TIPOMOV = 'S' AND "
cWhere += "SFT.FT_TIPO <> 'D' AND "
cWhere += "SFT.FT_ENTRADA >= '"+DToS(dDataDe)+"' AND "
cWhere += "SFT.FT_ENTRADA <= '"+DToS(dDataAte)+"' AND "
cWhere += "((SFT.FT_CFOP NOT LIKE '000%' AND SFT.FT_CFOP NOT LIKE '999%') OR SFT.FT_TIPO='S') AND "
cWhere += "((SFT.FT_BASEPIS > 0 OR SFT.FT_CSTPIS IN ('07','08','09','49','99'))  OR ( SFT.FT_BASECOF > 0 OR SFT.FT_CSTCOF IN ('07','08','09','49','99'))) AND "
If (cNrLivro<>"*")
	cWhere += " SFT.FT_NRLIVRO = '"+cNrLivro+"' AND "
EndiF
cWhere += "SFT.D_E_L_E_T_=''"

If aParPE[SPD1900A] // PE para SCP com Filial unica - TTUXH9
	cWhere := ExecBlock("SPD1900A", .F. , .F. , {cWhere})
Endif

IF aParSX3[FP_FT_TES]
	cFrom	   +="LEFT JOIN "+RetSqlName("SF4")+" SF4 ON(SF4.F4_FILIAL='"+xFilial("SF4")+"'  AND SF4.F4_CODIGO=SFT.FT_TES AND SF4.D_E_L_E_T_=' ') "
else
	cFrom	   +="LEFT JOIN "+RetSqlName("SD2")+" SD2 ON(SD2.D2_FILIAL='"+xFilial("SD2")+"'  AND SD2.D2_DOC=SFT.FT_NFISCAL AND SD2.D2_SERIE=SFT.FT_SERIE AND SD2.D2_CLIENTE=SFT.FT_CLIEFOR AND SD2.D2_LOJA=SFT.FT_LOJA AND SD2.D2_COD=SFT.FT_PRODUTO AND SD2.D2_ITEM=SFT.FT_ITEM AND SD2.D_E_L_E_T_=' ') "
	cFrom	   +="LEFT JOIN "+RetSqlName("SF4")+" SF4 ON(SF4.F4_FILIAL='"+xFilial("SF4")+"'  AND SF4.F4_CODIGO=SD2.D2_TES AND SF4.D_E_L_E_T_=' ') "
end if

cFrom	:= '%' + cFrom + '%'
cWhere	:= "%"+cWhere+"%"
cCampos := "%"

//---------------------------------------
//processa receita de notas fiscais
//---------------------------------------
BeginSql Alias cAliasSFT

	COLUMN FT_EMISSAO AS DATE
	COLUMN FT_ENTRADA AS DATE
	COLUMN FT_DTCANC AS DATE

	SELECT
		SF4.F4_RGESPCI,SFT.FT_NORESP,SFT.FT_FILIAL, SFT.FT_VALCONT ,SFT.FT_CFOP,SFT.FT_CSTPIS,SFT.FT_CSTCOF, SFT.FT_SERIE,SFT.FT_CONTA,SFT.FT_ESPECIE,SFT.FT_DTCANC,SFT.FT_NFISCAL,SFT.FT_CLIEFOR,;
		SFT.FT_LOJA,SFT.FT_PRODUTO,SFT.FT_ITEM,SFT.FT_TIPO,SFT.FT_TIPOMOV,SFT.FT_RGESPST,SFT.FT_PDV,SFT.FT_ENTRADA
		%Exp:cCampos%
	FROM
		%Table:SFT% SFT
		%Exp:cFrom%
	WHERE
		%Exp:cWhere%

	ORDER BY SFT.FT_ESPECIE

EndSql

DbSelectArea (cAliasSFT)
(cAliasSFT)->(DbGoTop ())
ProcRegua ((cAliasSFT)->(RecCount ()))
Do While !(cAliasSFT)->(Eof ())
   	// Tratamento para cupons fiscais gerados pelo SIGALOJA
   	If !Empty((cAliasSFT)->FT_PDV) .AND. AllTrim((cAliasSFT)->FT_ESPECIE)$"CF/ECF"
		cEspecie := "2D"
	Else
		cEspecie :=	AModNot((cAliasSFT)->FT_ESPECIE)
	EndIf

	cCfop	:= AllTrim((cAliasSFT)->FT_CFOP)

	//verificar os CFOPs de receita para poder gerar os registros.³
	If (cCfop$aCFOPs[01] .Or. cCfop$aCFOPs[03]) .AND. !(cCfop$aCFOPs[02])

		cEspecie	:=	Iif(Empty(cEspecie),"98",cEspecie)
		cConta		:= FSA0080500('', oBloco0,oTabela,lConcFil,(cAliasSFT)->FT_CONTA,cAliasSFT)
		cSituaDoc	:=	SPEDSitDoc (,cAliasSFT,,,dDataDe,dDataAte,,,,,,.T.) //verificar SF3 - pendente

		If !cSituaDoc $ "05"

			//Para o registro 1900 se a situação do documento não for normal ou cancelada deverá ser igual a 99 - Outros
			If !cSituaDoc $ "00/02/03"
				cSituaDoc := "99"
			ElseIf cSituaDoc=="03" //03 - Cancelamento autorizado fora do prazo, para o 1900 cancelamento deve ir como 02
				cSituaDoc := "02"
			EndIf

			nPosNf	:= aScan(aRegNf, {|aX| aX[1] == (cAliasSFT)->FT_NFISCAL .AND. ;
				aX[2] == (cAliasSFT)->FT_SERIE .AND. ;
				aX[3] == (cAliasSFT)->FT_ESPECIE  .AND. ;
				aX[4] == (cAliasSFT)->FT_CLIEFOR .AND. ;
				aX[5] == (cAliasSFT)->FT_LOJA} )

			nQtdNf	:= 0
			If nPosNf == 0
				nQtdNf	:= 1
				aAdd(aRegNf, {})
				nPosNf := Len(aRegNf)
				aAdd (aRegNf[nPosNf], (cAliasSFT)->FT_NFISCAL)
				aAdd (aRegNf[nPosNf], (cAliasSFT)->FT_SERIE)
				aAdd (aRegNf[nPosNf], (cAliasSFT)->FT_ESPECIE)
				aAdd (aRegNf[nPosNf], (cAliasSFT)->FT_CLIEFOR)
				aAdd (aRegNf[nPosNf], (cAliasSFT)->FT_LOJA)
			EndIf
			
			lRegSFT := .T.

			aPar1900	:= {}
			aAdd(aPar1900, SM0->M0_CGC)
			aAdd(aPar1900, cEspecie)
			aAdd(aPar1900, (cAliasSFT)->FT_SERIE)
			aAdd(aPar1900, cSituaDoc)
			aAdd(aPar1900, (cAliasSFT)->FT_VALCONT)
			aAdd(aPar1900, Alltrim(cValtoChar(nQtdNf)))
			aAdd(aPar1900, (cAliasSFT)->FT_CSTPIS )
			aAdd(aPar1900, (cAliasSFT)->FT_CSTCOF )
			aAdd(aPar1900, (cAliasSFT)->FT_CFOP )
			aAdd(aPar1900, '')
			aAdd(aPar1900, cConta)

			Proc1900('1001000000001', oBloco1, aPar1900,aParSx6[MV_AGR1900])


		EndIf
	Endif
	(cAliasSFT)->(DbSkip())
Enddo

DbSelectArea (cAliasSFT)
(cAliasSFT)->(DbCloseArea ())

//---------------------------------------
//processa receita de títulos sem notas
//---------------------------------------
aF100Aux := FinSpdF100(Month(dDataDe),Year(dDataDe),,DtoS(dDataDe),DtoS(dDataAte),"1900")

DbSelectArea ("DT6")
DT6->(DbSetOrder (10))

For nPosF100 :=1 to Len(aF100Aux)

	If aF100Aux[nPosF100][3] $ "01#02#03#05#04#06#07#08#09#49#99"

		cNumTit := ""
		cConta	:= ""
		IF aF100Aux[nPosF100][15] == "SE1"
			SE1->(dbGoto( aF100Aux[nPosF100][16]))
			If IntTms () .AND. DT6->(MsSeek (xFilial("DT6")+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_TIPO))
				cNumTit := "referente ao CTe : " + DT6->DT6_DOC
			Else
				cNumTit 	:="referente ao Titulo :" + SE1->E1_NUM
    		EndIF
		ElseIF aF100Aux[nPosF100][15] == "SE5"
			SE5->(dbGoto( aF100Aux[nPosF100][16]))
			cNumTit 	:="referente ao Titulo :" + SE5->E5_NUMERO
		ElseIF aF100Aux[nPosF100][15] == "SEI"
			SEI->(dbGoto( aF100Aux[nPosF100][16]))
			cNumTit 	:="referente a Aplicacao :" + SEI->EI_NUMERO
		EndIF
		cInfComp	:= "Operacao " + cNumTit

		cSituaDoc:= "00"
		//Verifica se existe a posição 30, se existir e estiver igual a .T., então esta operação é cancelada.
		If len(aF100Aux[nPosF100]) >=30 .AND. aF100Aux[nPosF100][30]
			cSituaDoc:= "02"
		EndIF

		If Len(aF100Aux[nPosF100])>22
			cConta	:= FSA0080500('', oBloco0,oTabela,lConcFil,aF100Aux[nPosF100][23],,.F.)
		EndIF

		lRegSFT := .T.

		aPar1900	:= {}
		aAdd(aPar1900, SM0->M0_CGC)
		aAdd(aPar1900, '99')
		aAdd(aPar1900, '')
		aAdd(aPar1900, cSituaDoc)
		aAdd(aPar1900, aF100Aux[nPosF100][2])
		aAdd(aPar1900, '1')
		aAdd(aPar1900, aF100Aux[nPosF100][3] )
		aAdd(aPar1900, aF100Aux[nPosF100][7])
		aAdd(aPar1900, '' )
		aAdd(aPar1900, cInfComp)
		aAdd(aPar1900, cConta)

		Proc1900('1001000000001', oBloco1, aPar1900, aParSx6[MV_AGR1900])


	EndIF
Next nPosF100

//---------------------------------------
//Processa valores de receita imobiliária
//---------------------------------------
IF aParPE[SPDPCIMOB]
	aRetImob := ExecBlock("SPDPCIMOB",.F.,.F.,{{},dDataDe,dDataAte})

	If Len(aRetImob) > 0
		For nCont := 1 to Len(aRetImob[1])
			If Len(aRetImob)>0 .And. ValType(aRetImob[1]) == "A"
				cInfComp	:= aRetImob[1][nCont][22]
				cConta		:= ""

				lRegSFT := .T.

				aPar1900	:= {}
				aAdd(aPar1900, SM0->M0_CGC)
				aAdd(aPar1900, '99')
				aAdd(aPar1900, '')
				aAdd(aPar1900, '99')
				aAdd(aPar1900, aRetImob[1][nCont][11])
				aAdd(aPar1900, '1')
				aAdd(aPar1900, aRetImob[1][nCont][12] )
				aAdd(aPar1900, aRetImob[1][nCont][16])
				aAdd(aPar1900, '' )
				aAdd(aPar1900, cInfComp)
				aAdd(aPar1900, cConta)

				Proc1900('1001000000001', oBloco1, aPar1900, aParSx6[MV_AGR1900])

			Endif
		Next nCont
	EndIf
EndIF

If !lRegSFT
	
	cAliasSFT	:=	GetNextAlias()
	cFrom		:= ""
	cWhere		:= ""
	cGroupBy	:= ""

	cWhere := "SFT.FT_FILIAL='"+xFilial("SFT")+"' AND "
	cWhere += "SFT.FT_TIPOMOV = 'S' AND "
	cWhere += "SFT.FT_TIPO <> 'D' AND "
	cWhere += "SFT.FT_ENTRADA = F0T.F0T_DTEMI AND "
	cWhere += "((SFT.FT_CFOP NOT LIKE '000%' AND SFT.FT_CFOP NOT LIKE '999%') OR SFT.FT_TIPO='S') AND "
	cWhere += "((SFT.FT_BASEPIS > 0 OR SFT.FT_CSTPIS IN ('07','08','09','49','99'))  OR ( SFT.FT_BASECOF > 0 OR SFT.FT_CSTCOF IN ('07','08','09','49','99'))) AND "
	If (cNrLivro<>"*")
		cWhere += " SFT.FT_NRLIVRO = '"+cNrLivro+"' AND "
	EndiF
	cWhere += "SFT.D_E_L_E_T_=''"

	cFrom	    += "LEFT JOIN "+RetSqlName("F0T")+" F0T ON(F0T.F0T_FILAPU='"+xFilial("F0T")+"' AND F0T.F0T_NUMNF=SFT.FT_NFISCAL AND F0T.F0T_SER=SFT.FT_SERIE AND F0T.F0T_ITEM=SFT.FT_ITEM AND F0T.F0T_CFOP=SFT.FT_CFOP AND F0T.F0T_PER='"+DToS(dDataDe)+"' AND F0T.D_E_L_E_T_=  '')"

	cFrom	:= '%' + cFrom  + '%'
	cWhere	:= "%" + cWhere +"%"
	cCampos := "%"

	//---------------------------------------
	//processa receita de notas fiscais
	//---------------------------------------
	BeginSql Alias cAliasSFT

		SELECT
			F0T.F0T_MODELO
			%Exp:cCampos%
		FROM
			%Table:SFT% SFT
			%Exp:cFrom%
		WHERE
			%Exp:cWhere%
		
		GROUP BY F0T.F0T_MODELO
			


	EndSql

	DbSelectArea (cAliasSFT)
	(cAliasSFT)->(DbGoTop ())
	ProcRegua ((cAliasSFT)->(RecCount ()))
	Do While !(cAliasSFT)->(Eof ())
		cEspecie :=	(cAliasSFT)->F0T_MODELO
		cEspecie :=	Iif(Empty(cEspecie),"98",cEspecie)

		aPar1900	:= {}
		aAdd(aPar1900, SM0->M0_CGC)
		aAdd(aPar1900, cEspecie)
		aAdd(aPar1900, '')
		aAdd(aPar1900, '99')
		aAdd(aPar1900, 0)
		aAdd(aPar1900, '')
		aAdd(aPar1900, '')
		aAdd(aPar1900, '')
		aAdd(aPar1900, '')
		aAdd(aPar1900, '')
		aAdd(aPar1900, '')

		Proc1900('1001000000001', oBloco1, aPar1900,aParSx6[MV_AGR1900])
		(cAliasSFT)->(DbSkip())
	Enddo
	DbSelectArea (cAliasSFT)
	(cAliasSFT)->(DbCloseArea ())
	
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ChkNf

@description Função que irá fazer verificação dos itens da nota fiscal, se
eixste ao menos um item com direito ao crédito para poder gerar registro
desta nota, se houver um item com direito ao crédito então toda nota
deverá ser considerada no arquivo, caso contrário documento não será gerado.

@author Erick G. Dias
@since 10/09/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function ChkNf(cChaveSFT,cEntSai,aCFOPs,cAliasSFT, lProC100, lProc1Item)

Local cCFOP			:=	''
Local lGravaC100	:=	.F.
Local lMVNFCompl	:=	aParSx6[MV_NFCOMPL]
Local lSPEDCSC		:=  aParSx6[MV_SPEDCSC]
Local lSPEDCOP		:=	aParSX6[MV_SPEDCOP]

Default lProC100	:= .F.
Default lProc1Item	:= .F.

SFT->(dbGoto( (cAliasSFT)->R_E_C_N_O_))

If !lProc1Item
	Do While !SFT->(Eof ()) .And.	cChaveSFT==SFT->FT_FILIAL+SFT->FT_TIPOMOV+SFT->FT_SERIE+SFT->FT_NFISCAL+SFT->FT_CLIEFOR+SFT->FT_LOJA

		cCFOP	:=	Alltrim(SFT->FT_CFOP)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Para as notas fiscais de entrada, verifica se o CST se enquadra nas regras para gerar o registro C100 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cEntSai == "1"
			IF SFT->FT_CSTPIS $ "50#51#52#53#54#55#56#60#61#62#63#64#65#66" .OR. SFT->FT_CSTCOF $ "50#51#52#53#54#55#56#60#61#62#63#64#65#66"
				lGravaC100 := .T.
				Exit
			ElseIF (SFT->FT_CSTPIS $ "98#99" .OR. SFT->FT_CSTCOF $ "98#99") .AND. (SFT->FT_TIPO == "D" .OR. lSPEDCOP)
				lGravaC100 := .T.
				Exit
			ElseIF !lProC100
				If lSPEDCSC .AND. (SFT->FT_CSTPIS $ "70#71#72#73#74#75" .OR. SFT->FT_CSTCOF $ "70#71#72#73#74#75")
					lGravaC100 := .T.
					Exit
				EndIf
			EndIf
		Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Para as notas fiscais de saida, verifica se algum item da nota nao esta no parametro MV_CFEREC,	 ³
		//³que indica um CFOP nao considerado como receita. Se algum item se enquadra nessa regra, toda a nf ³
		//³deve ser gerada, ou seja, registro C100 e todos os itens C170.									 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (cCFOP$aCFOPs[01] .Or. cCFOP$aCFOPs[03])  .AND. !(cCFOP$aCFOPs[02]) ;
			.Or. (SubStr(SFT->FT_CFOP,2,3)$'949'.And.SFT->FT_CSTPIS $ '01/02/03/04/05/06/07/08/09')
				If SFT->FT_TIPO$"IP" .AND. !lMVNFCompl
					lGravaC100	:= .F.
				Else
					lGravaC100	:=	.T.
				EndIf
				Exit
			Endif
		Endif

		SFT->(dbSkip())
	EndDo
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Para as notas fiscais de entrada, verifica se o CST se enquadra nas regras para gerar o registro C100 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF SFT->FT_CSTPIS $ "50#51#52#53#54#55#56#60#61#62#63#64#65#66" .OR. SFT->FT_CSTCOF $ "50#51#52#53#54#55#56#60#61#62#63#64#65#66"
		lGravaC100 := .T.
	ElseIF (SFT->FT_CSTPIS $ "98#99" .OR. SFT->FT_CSTCOF $ "98#99") .AND. (SFT->FT_TIPO == "D" .OR. lSPEDCOP)
		lGravaC100 := .T.
	ElseIF !lProC100
		If lSPEDCSC .AND. (SFT->FT_CSTPIS $ "70#71#72#73#74#75" .OR. SFT->FT_CSTCOF $ "70#71#72#73#74#75")
			lGravaC100 := .T.
		EndIf
	EndIf

EndIf
Return lGravaC100

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA008VLST

@description Função para obter o valor do ICMS ST para os registros C100, C170 e C600.
Estas regras são necessárias para manter compatibilidade destes registros
da EFD Contribuições com os registros da EFD Fiscal.
@author Erick G. Dias
@since 10/09/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Function FSA008VLST(cAliasSFT,cEntSai,cMVEstado,cMVSUBTRIB,cMVCFE210, cMVSTUFS, cMVSTUF, cMVRESF3FT, cMvSTNIEUF)

Local nValST	:= 0

//Somente irá processar se houver valor em algum destes campos, para evitar processamento desnecessário.
If (cAliasSFT)->FT_TIPO <> "S" .And. (cAliasSFT)->FT_CREDST <> "4" .AND. (cAliasSFT)->(FT_ICMSRET+FT_OUTRRET+FT_ISENRET+FT_OBSSOL+FT_SOLTRIB) > 0

	If 	(cEntSai=="2" .And. (Empty(cMVSTUFS) .Or. (cAliasSFT)->FT_ESTADO $ cMVSTUFS) ;
		.And. (Empty( cMVSTUF ) .Or. (cAliasSFT)->FT_ESTADO $ cMVSTUF ));						//Debito por saida
		.OR. ;
		(cEntSai=="1" .And. (Empty(cMVSTUF) .Or. (cAliasSFT)->FT_ESTADO $ cMVSTUF) ;		//Credito por entrada (devolucoes)
		.And. (cAliasSFT)->FT_TIPO=="D")

		If cMVRESF3FT
			//Na tabela SFT o valor de ICMS Retido pode alternar nas colunas dependendo da escrituracao
			nValST 	:= 	(cAliasSFT)->(FT_ICMSRET+FT_OUTRRET+FT_ISENRET)
		Else
			//Na tabela SF3 o valor do ICMS Retido sempre eh gravado em ICMSRET, independente da escrituracao
			nValST 	:= 	(cAliasSFT)->FT_ICMSRET
		EndIf

		nValST	:=	(cAliasSFT)->(Iif(nValST>0,nValST,FT_OBSSOL))

	ElseIf  (cEntSai=="1") .And. (cAliasSFT)->FT_ESTADO == cMVEstado .And. (cAliasSFT)->FT_CREDST <> "3"

		If (cAliasSFT)->FT_SOLTRIB > 0
			nValST := (cAliasSFT)->FT_SOLTRIB
		Else
			If cMVRESF3FT
				//Na tabela SFT o valor de ICMS Retido pode alternar nas colunas dependendo da escrituracao
				nValST 	:= 	(cAliasSFT)->(FT_ICMSRET+FT_OUTRRET+FT_ISENRET)
			Else
				//Na tabela SF3 o valor do ICMS Retido sempre eh gravado em ICMSRET, independente da escrituracao
				nValST 	:= 	(cAliasSFT)->FT_ICMSRET
			EndIf

			nValST	:=	(cAliasSFT)->(Iif(nValST>0,nValST,FT_OBSSOL))
		EndIf
	EndIf

	//Se valor já for zerado então não deverá fazer as verificações abaixo para zerar o valor de ST.
	IF nValST > 0

		If (cAliasSFT)->FT_TIPO=="D" .And. !(cAliasSFT)->FT_ESTADO==cMVEstado .And. !(cAliasSFT)->FT_ESTADO $ cMVSUBTRIB
			If (cEntSai=="1" .And. AllTrim((cAliasSFT)->FT_CFOP) $ cMVCFE210) .AND. !((cMVEstado+(cAliasSFT)->FT_ESTADO) $ AllTrim(cMvSTNIEUF)) .Or. cEntSai=="2"
				nValST		:=	0
			EndIf
		EndIf

	EndIf

EndIf

Return nValST

/*/{Protheus.doc} FIS8ExtTAF
	(Função intermediária para chamar as funções estaticas do EFD pelo Extrator TAF)

	@type Function
	@author Mauro A. Gonçalves
	@since 09/08/2016

	@param c_Registro, caracter, regisro para geração.

	@return Nil, nulo, não tem retorno
	/*/
Function FIS8ExtTAF(c_Registro)

	Local aSM0			:= {}
	Local cGrpPaiF		:= ''
	Local cGrpPai0		:= ''
	Local cGrpPai1		:= ''
	Local c0140			:= ''
	Local c0140Pri		:= ''
	Local cLivro		:= '*'
	Local cIndNatPJ		:= ''
	Local dDataDe		:= CToD('')
	Local dDataAte		:= CToD('')
	Local lBlocACDF		:= .T.
	Local lBlocoI		:= .T.
	Local lRgCmpCons	:= .F.
	Local lRgCaxCons	:= .F.
	Local lConcFil		:= .F.
	Local nQtdThread	:= 1
	Local nTipRegime	:= 0
	Local nCodTipCont	:= 0
	Local nIndRegCum	:= 0
	Local nIndIncidT	:= 0

	STATIC NFENTRADA	:= '1'
	STATIC NFSAIDA 		:= '2'
	STATIC PIS 			:= '1'
	STATIC COFINS 		:= '2'

	Private oTabela
	Private oBloco0		:= EFDCBLOCO0():New()
	Private oBloco1		:= EFDCBLOCO1():New()
	Private oBlocoA		:= EFDCBLOCOA():New()
	Private oBlocoC		:= EFDCBLOCOC():New()
	Private oBlocoD		:= EFDCBLOCOD():New()
	Private oBlocoF		:= EFDCBLOCOF():New()
	Private oBlocoI		:= EFDCBLOCOI():New()
	Private oBlocoM		:= EFDCBLOCOM():New()
	Private oBlocoP		:= EFDCBLOCOP():New()
	Private aNumeracao	:= {}
	Private aGrupoReg	:= {}
	Private cChave0000	:= ''
	Private cChave0140	:= ''
	Private cChaveD010	:= ''
	Private cChaveF010	:= ''
	Private cGrupoP001	:= ''
	Private cGrupoM010	:= ''
	Private cGrupoF010	:= ''

	Default c_Registro := ""

	ProcCache()

	dDataDe		:= oWizard:GetDataDe()
	dDataAte	:= oWizard:GetDataAte()

	cIndNatPJ	:= oWizard:GetIndNaturezaPJ()

	nTipRegime	:= Val(oWizard:GetIncidTribPeriodo())  //tipo regime
	nCodTipCont	:= Val(oWizard:GetTipoContribuicao()) //tipo contribuição
	nIndRegCum	:= Val(oWizard:GetIndRegimeCumulativo()) //indicador regime cumulativo
	nIndIncidT	:= Val(oWizard:GetIndIncidTribut()) //Código indicador da incidência tributária no período
	//cria objeto da tabela temporária que deverá ser utilizada no processamento dos registros
	oTabela		:= TabTemp(nQtdThread)

	cGrpPai0	:= FSA008SReg(@aNumeracao,'', '0111')
	oBloco0:setaNumer(@aNumeracao)
	oBloco0:setDtIni(dDataDe)
	oBloco0:setDtFin(dDataAte)
	oBloco0:setDtDeAte(dDataDe,dDataAte)
	/*
		alimento a variável mv_par08 para que não ocorra erro posteriormente
	*/
	mv_par01 := dDataDe
	mv_par02 := dDataAte
	mv_par08 := nTipRegime
	mv_par16 := nIndRegCum
	mv_par21 := nIndIncidT

	Do Case
		Case c_Registro=='Bloco0'
			Reg0110(dDataDe,dDataAte,cChave0000,@aNumeracao,oBloco0,oTabela,lBlocACDF,lBlocoI,nTipRegime,nCodTipCont,nIndRegCum)
		Case c_Registro=='BlocoF'
			cGrpPaiF	:= RegF010(oBlocoF,oTabela,aNumeracao)
			oBlocoF:setaNumer(@aNumeracao)
			BlocoF(@aNumeracao, oTabela, oBlocoF, oBloco1, oBloco0, lConcFil, dDataDe, dDataAte, c0140, lBlocACDF, lRgCaxCons, .T., lRgCmpCons, cLivro, nTipRegime)
		Case c_Registro=='BlocoI'
			BlocoI(aNumeracao, oTabela, oBloco0, oTabela, lConcFil, oBloco1, dDataDe, dDataAte)
		Case c_Registro=='BlocoM'
			BlocoM(aNumeracao, oTabela, oBloco0, lConcFil, aSM0, dDataDe, dDataAte, nTipRegime,cIndNatPJ)
			//Processa saldo de crédito de PIS
			If nTipRegime <> 2
				cGrpPai1	:= FSA008SReg(@aNumeracao,'', '1100')
				oBloco1:setaNumer(@aNumeracao)

				ProcCCYCCW(oBloco1, dDataDe, PIS)
				oTabela:GrvReg(oBloco1:get1100())
				oBloco1:cls1100()
				//Processa saldo de crédito de COFINS
				ProcCCYCCW (oBloco1, dDataDe, COFINS)
				oTabela:GrvReg(oBloco1:get1500())
				oBloco1:cls1500()
			EndIf
			//Processo referenciado
			//BuscaCDG(cChavePai, aPar, oBloco, oBloco1, c_Registro )
			//Processa saldo retenção de PIS
			ProcSFVSFW(oBloco1, dDataDe, PIS)
			oTabela:GrvReg(oBloco1:get1300())
			oBloco1:cls1300()
			//Processa saldo retenção de COFINS
			ProcSFVSFW(oBloco1, dDataDe, COFINS)
			oTabela:GrvReg(oBloco1:get1700())
			oBloco1:cls1700()
			If lRgCmpCons .OR. lRgCaxCons
				oTabela:GrvReg(oBloco1:get1900())
			EndIF
		Case c_Registro=='BlocoP'
			BlocoP(@aNumeracao,oTabela,.T.,oBloco0,lConcFil,c0140,c0140Pri,oBlocoP,dDataDe,dDataAte)

			//Grava registros P010 depois de processar todas as filiais.
			oTabela:GrvReg(oBlocoP:getP010())

			//Processa receita para Filiais
			oBlocoP:ProcRec()

			//Grava P100
			oTabela:GrvReg(oBlocoP:getP100())

			//Limpa objeto
			oBlocoP:clsP100()
		Case c_Registro=='Bloco1' .AND. FindFunction( 'Bloco1' )
			Bloco1(@aNumeracao,oTabela,.T.,oBloco0,lConcFil,c0140,c0140Pri,dDataDe,dDataAte)
	EndCase

	//-----------------------------------------------------------------------------
    //Deleta tabelas temporárias utilizadas no processamento
    //-----------------------------------------------------------------------------
    oTabela:DelTabela()
    oTabela:DelTabCad()

        //-----------------------------------------------------------------------------
    //Destroi os objetos criados
    //-----------------------------------------------------------------------------

    FreeObj(oBloco0)
    oBloco0 := nil

    FreeObj(oBloco1)
    oBloco1 := nil

    FreeObj(oBlocoA)
    oBlocoA := nil

    FreeObj(oBlocoC)
    oBlocoC := nil

    FreeObj(oBlocoD)
    oBlocoD := nil

    FreeObj(oBlocoF)
    oBlocoF := nil

    FreeObj(oBlocoI)
    oBlocoI := nil

    FreeObj(oBlocoM)
    oBlocoM := nil

    FreeObj(oBlocoP)
    oBlocoP := nil

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Qry1050

Função que fará query na F3P buscando informações para gerar o registro
1050, com detalhamento dos ajsutes de redução de base de cálulo de PIS
e COFINS, referente a decisão judicial concedendo direito a exclusão do
ICMS a recolher.

@author Erick G. Dias
@since 14/12/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function Qry1050(dPeriodo, cRelac, oBloco1)

Local cFiltro	:= ''
Local cCampos	:= ''
Local cAliasQry	:= ''
Local cFrom		:= ''
Local lConsol	:= FS007ApCon(dPeriodo)//Verifca se é apuração consolidada ou não

//Seção do Select
cCampos += "F3P.F3P_PER,   F3P.F3P_CODAJU, F3P.F3P_CNPJ , F3P.F3P_TOTAJU, F3P.F3P_CST01, "
cCampos += "F3P.F3P_CST01, F3P.F3P_CST02,  F3P.F3P_CST03, F3P.F3P_CST04,  F3P.F3P_CST05, "
cCampos += "F3P.F3P_CST06, F3P.F3P_CST07,  F3P.F3P_CST08, F3P.F3P_CST09,  F3P.F3P_CST49, "
cCampos += "F3P.F3P_CST99, F3P.F3P_INDAP, F3P.F3P_RECIBO, F3P.F3P_INFCOM"

//From
cFrom	   +=  RetSqlName('F3P')+' F3P '

//Where
cFiltro	 += "F3P.F3P_FILIAL = " + valToSql(xFilial("F3P")) + " AND F3P.F3P_PER = " + valToSql(dPeriodo) +  " AND "
cFiltro  += "F3P.F3P_CONSOL = " + Iif(lConsol, valToSql("1"), valToSql("2")) + " AND F3P.D_E_L_E_T_=' '"

cFrom	:= '%' + cFrom + '%'
cFiltro	:= '%' + cFiltro + '%'
cCampos	:= '%' + cCampos + '%'

cAliasQry	:=	GetNextAlias()

BeginSql Alias cAliasQry

	SELECT
	%Exp:cCampos%
	FROM
	%Exp:cFrom%
	WHERE
	%Exp:cFiltro%
EndSql

DbSelectArea (cAliasQry)
(cAliasQry)->(DbGoTop ())
Do While !(cAliasQry)->(Eof ())
	//Gera registro 1050
	oBloco1:setRelac(cRelac)
	oBloco1:setCnpj((cAliasQry)->F3P_CNPJ)
	oBloco1:setPerApu( STOD((cAliasQry)->F3P_PER ) )
	oBloco1:setIndAj((cAliasQry)->F3P_CODAJU)
	oBloco1:setVlTot((cAliasQry)->F3P_TOTAJU)
	oBloco1:setVlCSt01((cAliasQry)->F3P_CST01)
	oBloco1:setVlCSt02((cAliasQry)->F3P_CST02)
	oBloco1:setVlCSt03((cAliasQry)->F3P_CST03)
	oBloco1:setVlCSt04((cAliasQry)->F3P_CST04)
	oBloco1:setVlCSt05((cAliasQry)->F3P_CST05)
	oBloco1:setVlCSt06((cAliasQry)->F3P_CST06)
	oBloco1:setVlCSt07((cAliasQry)->F3P_CST07)
	oBloco1:setVlCSt08((cAliasQry)->F3P_CST08)
	oBloco1:setVlCSt09((cAliasQry)->F3P_CST09)
	oBloco1:setVlCSt49((cAliasQry)->F3P_CST49)
	oBloco1:setVlCSt99((cAliasQry)->F3P_CST99)
	oBloco1:setIndAprop((cAliasQry)->F3P_INDAP)
	oBloco1:setRecibo((cAliasQry)->F3P_RECIBO)
	oBloco1:setInfComp((cAliasQry)->F3P_INFCOM)
	oBloco1:Add1050()

	(cAliasQry)->(DbSkip ())
EndDo

DbSelectArea (cAliasQry)
(cAliasQry)->(DbCloseArea ())

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcICMS

Função que buscará o processo que autoriza a exclusão do ICMS da base de
cálculo de PIS e COFINS, para gerar registro 1010 ou 1020.

@author Erick G. Dias
@since 20/12/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function ProcICMS(oBloco1)

Local aProcICMS		:= StrTokArr2( aParSX6[MV_PRICMS] , "|" ,.T.)

If Len(aProcICMS) >= 4
	//Posicionar CCF e gerar registro
	//CCF_FILIAL+CCF_NUMERO+CCF_TIPO+CCF_INDAUT+CCF_IDITEM
	If CCF->(MsSeek (xFilial ('CCF') + ;
	         Padr(aProcICMS[1],TamSx3("CCF_NUMERO")[1]) + ;
			 Padr(aProcICMS[2],TamSx3("CCF_TIPO")[1])   + ;
			 Padr(aProcICMS[3],TamSx3("CCF_INDAUT")[1]) + ;
			 Padr(aProcICMS[4],TamSx3("CCF_IDITEM")[1]) ))

		If CCF->CCF_TPCOMP == '1' //Complemento do processo referenciado - Judicial
			Proc1010('1001000000001', oBloco1, 'CCF')
		ElseIf CCF->CCF_TPCOMP == '2' //Complemento do processo referenciado - Administrativo
			Proc1020('1001000000001', oBloco1, 'CCF')
		EndIF
	EndIF
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} NFItAtiv

Cria um JSON com todas a entradas que possuem tem que atualiza ativo fixo (por item, total ou parcial)
Com as notas de entrada do periodo processado.

@author Matheus Massarotto
@since 08/12/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function NFItAtiv(dDtIni,dDtFim)
Local cAlias	:= GetNextAlias()
Local cChave	:= " "
Local cQuery	:= " "


	if oPSAtiv == Nil

		cQuery := " SELECT D1_FILIAL,D1_SERIE,D1_DOC,D1_FORNECE,D1_LOJA, (CASE WHEN COUNT(F4_ATUATF)=COUNT(D1_ITEM) THEN 'SOATIVO' ELSE 'PARCIAL' END) ATFIXO
		cQuery += " FROM "+RETSQLNAME("SD1")+" SD1"
		cQuery += " LEFT JOIN "+RETSQLNAME("SF4")+" SF4 ON SF4.F4_FILIAL=? AND SF4.F4_CODIGO=SD1.D1_TES AND SF4.D_E_L_E_T_=' ' AND SF4.F4_ATUATF='S'
		cQuery += " WHERE SD1.D1_FILIAL= ? AND SD1.D1_DTDIGIT BETWEEN ? AND ? AND SD1.D_E_L_E_T_= ' '
		cQuery += " GROUP BY D1_FILIAL,D1_SERIE,D1_DOC,D1_FORNECE,D1_LOJA
		cQuery += " HAVING COUNT(F4_ATUATF) > 0 "

		cQuery 	:= ChangeQuery(cQuery)
		oPSAtiv := FWPreparedStatement():New(cQuery)

	endif
	
	oPSAtiv:SetString(1, xFilial("SF4"))
	oPSAtiv:SetString(2, xFilial("SD1"))
	oPSAtiv:SetString(3, DTOS(dDtIni))
	oPSAtiv:SetString(4, DTOS(dDtFim))

	cQuery	:= oPSAtiv:GetFixQuery()
	MPSysOpenQuery(cQuery, cAlias)	
	
	DbSelectArea (cAlias)
	
	oJSAtiv	:= JsonObject():New()

	While (cAlias)->(!Eof())
		cChave :=  (cAlias)->D1_FILIAL+"E"+(cAlias)->D1_SERIE+(cAlias)->D1_DOC+(cAlias)->D1_FORNECE+(cAlias)->D1_LOJA
		oJSAtiv[cChave] := (cAlias)->ATFIXO
		(cAlias)->(DbSkip())					
	EndDo	
	
	(cAlias)->(dbCloseArea()) //Fecha tabela temporaria	

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA008X1
@Autor alexandre esteves

@since 19/01/2022
@version 12.1.33
referencia do programa FSA231X1 

Verifico se determinado parâmetro do X1(pergunte) existe.
FISA008
/*/
//-------------------------------------------------------------------
Static Function FSA008X1(cPerg,cParam)
Local oFwSX1Util
Local aPergunte	:= {}
Local lRet		:= .T.
Local nPos		:= 1
Local oError    := ErrorBlock({|e| Conout("ERRO na função FISA008: " +e:Description +"- Filial " + FWGETCODFILIAL + " " + Time()+ "ERRORSTACK:"	+ Chr(10)+Chr(13) + e:ErrorStack , lRet:=.F.)})

	if GetRPORelease() <  "12.1.030"

		Begin Sequence
			//pego a posição do parametro que se deseja verificar
			nPos:= val(right(cParam,2))

			//Classe que retorna os campos do SX1 (Perguntas) cadastrados para o ID passado
			oFwSX1Util:= FwSX1Util():New()
			oFwSX1Util:AddGroup(cPerg)
			oFwSX1Util:SearchGroup()
			aPergunte:= oFwSX1Util:GetGroup(cPerg)

			//Verifico se o parâmetro existe
			if !(len(aPergunte)>1 .and. len(aPergunte[2])>(nPos-1) .and. Upper(AllTrim(aPergunte[2][nPos]:CX1_VAR01)) == cParam)
				lRet:=.F.
			endif
			
		End Sequence

		//Limpo o array e limpo o objeto
		FwFreeArray(aPergunte)
		oFwSX1Util:= Nil

		//Tratamento para caso de erro apresentar a msg com conout.
		ErrorBlock(oError)

	endif

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} AllCfops
Função que percorrerá todos os CFOPs da SX5 para realizar a carga automática
@author Rafael Oliveira
@since 16/03/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function AllCfops(oJCFOP)

Local cCfop     := ""
Local nX        := 0
Local aDadosSX5 := FWGetSX5( "13" )

oJCFOP	:= JsonObject():New()

//Posiciono na SX5 a tabela 13 de CFOPs
For nX := 1 to Len(aDadosSX5)
    cCfop         := Alltrim(aDadosSX5[nX][3])
	oJCFOP[cCfop] := Alltrim(aDadosSX5[nX][4])
Next

ASize(aDadosSX5,0)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} DelTodasTabCad
Função que apaga as tabelas temporárias 'FISA008CAD' e 'FSA008CAD' que não foram apagadas no processo
@author Matheus Bispo
@since 14/04/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function DelTodasTabCad()

Local cAliasQry 	:= GetNextAlias()
Local cDbType		:= TCGetDB()
Local cTabela		:= ""
Local cDataTab		:= ""
Local cDataWhere	:= DTOS(dDataBase - 7) // Pega somente de uma semana antes para evitar apagar se houver execuções simultanêas
local nStatus		:= 0
Local cErrorMsg		:= ""
Local cQuery		:= ""

If cDbType $ "MSSQL/MSSQL7/SYBASE"
	cQuery 	:= " SELECT name TABELA "
	cQuery 	+= " FROM sys.tables "
	cQuery 	+= " WHERE SUBSTRING( name, 1, 9) IN ('FISA008CA','FSA008CAD') "
ElseIf cDbType == "ORACLE"
	cQuery 	:= " SELECT object_name TABELA "
	cQuery 	+= " FROM user_objects "
	cQuery 	+= " WHERE SUBSTR( object_name, 1, 9) IN ('FISA008CA','FSA008CAD') "
	cQuery 	+= " AND object_type = 'TABLE' "
Elseif cDbType == "POSTGRES"
	cQuery 	:= " SELECT table_name TABELA "
	cQuery 	+= " FROM information_schema.tables "
	cQuery 	+= " WHERE substring( table_name, 1, 9) IN ('fisa008ca','fsa008cad') "
	// Em POSTGRES a tabela deve ser em minusculo
EndIf

If !Empty(cQuery)

	nStatus := TCSqlExec(cQuery)

	If nStatus >= 0

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)

		While !((cAliasQry)->(EOF()))

			cTabela	 := UPPER(Alltrim((cAliasQry)->TABELA)) // Em POSTGRES os valores são minusculos, portanto é necessário colocar em maiusculo

			cDataTab := LEFT(cValToChar(CTON(SUBSTR(cTabela, 10, 12), 16)), 8)

			If LEFT(cTabela, 10) == 'FISA008CAD' .OR. cDataTab <= cDataWhere
				If TcCanOpen( cTabela )
					TCDelIndex( cTabela, "") // Apaga todos os indices relacionado a tabela
					If !TcDelFile( cTabela ) // Apaga tabela temporaria, caso não consiga será por conta que a tabela está presa por alguma thread
						cErrorMsg := "A tabela ( " + cTabela + " ) em questão está presa por alguma thread de processamento pelo TOP CONNECT, entrar em contato com o Administrador do sistema para liberá-la."
						FwLogMsg("WARN", /*cTransactionId*/, "FISA008", FunName(), "", "01", cErrorMsg, 0, 0,)
					EndIf
				EndIf
			EndIf

			(cAliasQry)->(DbSkip())
		EndDo

		(cAliasQry)->(DBCloseArea())
	EndIf

	cErrorMsg := "FISA008 - Não foi possível excluir as tabelas temporárioas FISA008CAD/FSA008CAD - TCSQLError() : " + TCSQLError()
	// Em caso de erro na Query, envia uma mensagem para o cliente
	Iif(nStatus < 0, FwLogMsg("WARN", /*cTransactionId*/, "FISA008", FunName(), "", "02", cErrorMsg, 0, 0,), "")

EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ParseSlct
Função para retirar alias das tabelas utilizadas na construção da VIEW
@author Jose Ricardo Bernardo
@since 29/05/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function ParseSlct( cQuery, aTabelas)
Local nTabelas := 0
Local cSlctRet := cQuery

For nTabelas:=1 to len( aTabelas )

	cSlctRet := strtran( cSlctRet, aTabelas[nTabelas]+".", "")

Next 

Return cSlctRet
