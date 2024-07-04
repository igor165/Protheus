#include "Protheus.ch"
#include "APDM050.ch"

#DEFINE _ENTER chr(13)+chr(10)

/*/{Protheus.doc} APDM050

@type function
@author Jorge Heitor
@since 06/04/2016
@version 1.0
@description Rotina de processamento dos cálculos de Resultados de Política de Consolidação

/*/
Function APDM050()

	Local aSays			:= {}
	Local aButtons		:= {}
	Local nOpca
	Local oDlg
	Local aAdvSize		:= {}
	Local aInfoAdvSize	:= {}
	Local aObjSize		:= {}
	Local aObjCoords	:= {}
	Local aGDCoord		:= {}
	Local aArea			:= GetArea()

	Private cCadastro 	:= OemToAnsi(STR0001)  //"Cálculo da Política Consolidada"
	Private nSavRec		:= 0
	Private _nRound		:= GetMV("MV_APDARRM")
	Private dDataCalc	:= Date()


	Pergunte("APDM50",.F.)

	/*
	---------------------------
	Monta dimensões dos objetos
	---------------------------
	*/

	aAdvSize		:= MsAdvSize()
	aAdvSize[5]		:= (aAdvSize[5]/100) * 35	//horizontal
	aAdvSize[6]		:= (aAdvSize[6]/100) * 55	//Vertical
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )
	aGdCoord		:= { (aObjSize[1,1]+3), (aObjSize[1,2]+5), (((aObjSize[1,3])/100)*25), (((aObjSize[1,4])/100)*29.6) }	//1,3 Vertical /1,4 Horizontal

	SetaPilha()

	DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM  aAdvSize[7],20 TO aAdvSize[6]-50,600  OF oMainWnd PIXEL

		@ aGdCoord[1]+20,aGdCoord[2]+4 Say OemToAnsi( STR0002 ) Size 290,07 Pixel Font oFont Color CLR_BLUE	//"Este programa tem como objetivo efetuar o Calculo Consolidado das Avaliacoes (Competências, Metas "
		@ aGdCoord[1]+32,aGdCoord[2]+4 Say OemToAnsi( STR0003 ) Size 290,07 Pixel Font oFont Color CLR_BLUE //"e Outras Pontuações), com base no criterio estabelecido em 'Parâmetros"

		aButtons	:=	{;
						{STR0029 ,{ || Pergunte("APDM50",.T. ) },STR0015,STR0015};
						}

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar( oDlg , { || nOpca 	:= 1, oDlg:End() } , { || nOpca 	:= 0 , oDlg:End() } , NIL , aButtons )

	SetaPilha()

	/*
	------------------------------------
	Variaveis utilizadas para Parâmetros
	------------------------------------
	*/
	If nOpca == 1
		Processa({|lEnd| APD005Proc(),OemToAnsi(STR0001)})   //"Cálculo da Política Consolidada"
	EndIf

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} APD005Proc

@type function
@author Jorge Heitor
@since 06/04/2016
@version 1.0
@description Processamento dos cálculos Consolidados

/*/
Static Function APD005Proc()

	Local nx
	Local lMetas		:= .F.			//Define se será processado o Cálculo das Avaliações de Metas (Carregado pela Função LoadMeta)
	Local lComp			:= .F.			//Define se será processado o Cálculo das Avaliações de Competencias (Carregado pela Função LoadMeta)
	Local lForma		:= .F.			//Define se será processado o Cálculo das Formações Acadêmicas (Carregado pela Função LoadMeta)
	Local nPerMeta		:= 0			//Percentual do Cálculo Consolidado a ser considerado para Metas (Carregado pela Função LoadMeta)
	Local nPerComp		:= 0			//Percentual do Cálculo Consolidado a ser considerado para Competências (Carregado pela Função LoadMeta)
	Local nPerForma		:= 0			//Percentual do Cálculo Consolidado a ser considerado para Formação Acadêmica (Carregado pela Função LoadMeta)
	Local aPeriodos		:= {}			//Períodos que compõem a Política Consolidada (Carregado pela Função LoadMeta)
	Local lProcessa		:= .T.
	Local lTemRIZ		:= .F.

	Private aLog		:= {}
	Private cPolitica	:= mv_par01
	Private aFunc		:= {}			//Lista de Participantes

	aAdd(aLog,"----------------------------------------------------------------------")
	aAdd(aLog,STR0022 + DtoC(Date()) + " / " + Time()) //"Data/Hora de Início do Processamento: "
	aAdd(aLog,"----------------------------------------------------------------------")
	aAdd(aLog,"-------------")
	aAdd(aLog,STR0023 + " ") //"Parâmetros: "
	aAdd(aLog,"-------------")
	aAdd(aLog,STR0031 + cPolitica + " - " + Posicione("RIX",1,xFilial("RIX")+cPolitica,"RIX_DESC")) //"Política de Consolidação: "

	/*
	aAdd(aLog," ")
	aAdd(aLog,"----------------------------------------------------------------------")
	aAdd(aLog,STR0032 + Time()) //"Início da Leitura da Política: "
	aAdd(aLog,"----------------------------------------------------------------------")
	*/

	/*
	-----------------------------
	Carrega diretivas da Política
	-----------------------------
	*/
	MsAguarde( { || LoadPolitica(cPolitica,@lComp,@nPerComp,@lMetas,@nPerMeta,@lForma,@nPerForma,@aPeriodos) } , STR0033, STR0030 + cPolitica + "...")  //"Aguarde"###"Carregando Politica "

	aAdd(aLog," ")
	aAdd(aLog,"-------------")
	aAdd(aLog,STR0024 + " ") //"Períodos: "
	aAdd(aLog,"-------------")
	aEval(aPeriodos,{|x| aAdd(aLog,x[1] + " - " + Posicione("RDU",1,xFilial("RDU")+x[1],"RDU_DESC"))})
	aAdd(aLog," ")

	/*
	aAdd(aLog,"----------------------------------------------------------------------")
	aAdd(aLog,STR0034 + Time()) //"Término da Leitura da Política: "
	aAdd(aLog,"----------------------------------------------------------------------")
	aAdd(aLog," ")
	aAdd(aLog,"----------------------------------------------------------------------")
	aAdd(aLog,STR0035 + Time()) //"Verificação de reprocessamento: "
	aAdd(aLog,"----------------------------------------------------------------------")
	*/

	/*
	---------------------------------------------------
	Verifica se existem Cálculos para a Política ()RIZ)
	---------------------------------------------------
	*/
	lTemRIZ := TemRIZ(cPolitica)

	/*
	aAdd(aLog,"----------------------------------------------------------------------")
	aAdd(aLog,STR0036 + Time()) //"Término da Verificação de reprocessamento: "
	aAdd(aLog,"----------------------------------------------------------------------")
	aAdd(aLog," ")
	*/

	If lTemRIZ

		lProcessa := MsgNoYes(STR0037 + cPolitica + ". " + STR0038 , '')  //"Foram encontrados Registros de Resultados para a Politica "###"Deseja continuar e substituir o Calculo anterior?"

	EndIf

	If lProcessa

		/*
		-------------------------------------
		Exclui Registros da RIZ (se houverem)
		-------------------------------------
		*/
		If lTemRIZ

			/*
			aAdd(aLog,"----------------------------------------------------------------------")
			aAdd(aLog,STR0039 + Time()) //"Reprocessamento: "
			aAdd(aLog,"----------------------------------------------------------------------")
			*/

			MsAguarde( { || ExcluiRIZ(cPolitica) } , STR0033, STR0040 + cPolitica + "...")	//"Aguarde"###"Excluindo Resultados para a Politica "

			/*
			aAdd(aLog,"----------------------------------------------------------------------")
			aAdd(aLog,STR0041 + Time()) //"Término do reprocessamento: "
			aAdd(aLog,"----------------------------------------------------------------------")
			aAdd(aLog," ")
			*/

		EndIf

		/*
		-------------------------------------
		Processa Metas
		-------------------------------------
		*/
		If lMetas


			aAdd(aLog,"----------------------------------------------------------------------")
			aAdd(aLog,STR0043 + Time()) //"Cálculos das Metas: "
			aAdd(aLog,"----------------------------------------------------------------------")


			MsAguarde( { || GeraMetas(nPerMeta,aPeriodos) } , STR0033, STR0042)	//"Aguarde"###"Cálculos das Metas: "

			/*
			aAdd(aLog,"----------------------------------------------------------------------")
			aAdd(aLog,STR0044 + Time()) //"Término Cálculo das Metas: "
			aAdd(aLog,"----------------------------------------------------------------------")
			aAdd(aLog," ")
			*/

		EndIf

		/*
		-------------------------------------
		Processa Competências
		-------------------------------------
		*/
		If lComp


			aAdd(aLog," ")
			aAdd(aLog,"----------------------------------------------------------------------")
			aAdd(aLog,STR0045 + Time()) //"Cálculos das Competências: "
			aAdd(aLog,"----------------------------------------------------------------------")


			MsAguarde( { || GeraComp(nPerComp,aPeriodos) } , STR0033, STR0046)	//"Aguarde"###"Calculando Competências..."

			/*
			aAdd(aLog,"----------------------------------------------------------------------")
			aAdd(aLog,STR0047 + Time()) //"Término dos Cálculos das Competências: "
			aAdd(aLog,"----------------------------------------------------------------------")
			aAdd(aLog," ")
			*/

		EndIf

		/*
		-------------------------------------
		Processa Formação Acadêmica
		-------------------------------------
		*/
		If lForma


			aAdd(aLog," ")
			aAdd(aLog,"----------------------------------------------------------------------")
			aAdd(aLog,STR0048 + Time()) //"Cálculos de Outras Pontuações: "
			aAdd(aLog,"----------------------------------------------------------------------")


			MsAguarde( { || GeraForm(nPerForma,aPeriodos) } , STR0033, STR0049+"...")	//"Aguarde"###"Calculando Outras Pontuações..."

			/*
			aAdd(aLog,"----------------------------------------------------------------------")
			aAdd(aLog,STR0050 + Time()) //"Término dos Cálculos de Outras Pontuações: "
			aAdd(aLog,"----------------------------------------------------------------------")
			aAdd(aLog," ")
			*/

		EndIf

		/*
		-------------------------------------
		Processa Cálculo Consolidado
		-------------------------------------
		*/


		aAdd(aLog,"----------------------------------------------------------------------")
		aAdd(aLog,STR0051 + Time()) //"Cálculos Consolidados: "
		aAdd(aLog,"----------------------------------------------------------------------")


		MsAguarde( { || GeraCons() } , STR0033, STR0052+"...")	//"Aguarde"###"Efetuando Cálculo Consolidado..."

		aAdd(aLog," ")
		aAdd(aLog,"----------------------------------------------------------------------")
		aAdd(aLog,STR0053 + Time()) //"Término dos Cálculos Consolidados: "
		aAdd(aLog,"----------------------------------------------------------------------")

	EndIf

	_GravaLog(aLog)

Return Nil



/*/{Protheus.doc} LoadPolitica

@type function
@author Jorge Heitor
@since 14/04/2016
@version 1.0
@description Carrega dados da Política de Avaliação Consolidada

/*/
Static Function LoadPolitica(cPolitica,lComp,nPerComp,lMetas,nPerMeta,lForma,nPerForma,aPeriodos)

	//Caso o Alias esteja em uso, fecha o mesmo
	If Select("TRIX") > 0 ; TRIX->(dbCloseArea()) ; EndIf

	BeginSQL Alias "TRIX"

		SELECT * FROM %Table:RIX% RIX
		WHERE RIX.RIX_CODIGO = %Exp:cPolitica% AND RIX.%NotDel% AND RIX.RIX_STATUS = %Exp:'1'%

	EndSQL

	dbSelectArea("TRIX")
	If !TRIX->(Eof())

		lComp     := (TRIX->RIX_PERCOM > 0)
		nPerComp  := TRIX->RIX_PERCOM
		lMetas    := (TRIX->RIX_PERMET > 0)
		nPerMeta  := TRIX->RIX_PERMET
		lForma    := (TRIX->RIX_PERFOR > 0)
		nPerForma := TRIX->RIX_PERFOR

		TRIX->(dbCloseArea())

		/*
		--------------------------
		Carrega dados dos Períodos
		--------------------------
		*/
		If Select("TRIY") > 0 ; TRIY->(dbCloseArea()) ; EndIf

		BeginSQL Alias "TRIY"

			SELECT RIY.RIY_CODPER CODIGO,RDU.RDU_TIPO TIPO FROM %Table:RIY% RIY
			INNER JOIN %Table:RDU% RDU ON
				RDU.RDU_CODIGO = RIY.RIY_CODPER
			WHERE RIY.RIY_CODIGO = %Exp:cPolitica% AND RIY.%NotDel% AND RDU.%NotDel%
			ORDER BY RIY.RIY_CODPER,RDU.RDU_TIPO

		EndSQL

		dbSelectArea("TRIY")
		If !TRIY->(Eof())

			While !TRIY->(Eof())

				aAdd(aPeriodos,{TRIY->CODIGO,TRIY->TIPO})
				TRIY->(dbSkip())

			End

		EndIf

		TRIY->(dbCloseArea())

	Else

		MsgStop(STR0054) //"A política informada não foi encontrada e/ou não está ativa."

	EndIf

Return Nil

/*/{Protheus.doc} TemRIZ

@type function
@author Jorge Heitor
@since 06/04/2016
@version 1.0
@description Verificação da existência de registros já processados com os parâmetros informados

/*/
Static Function TemRIZ(cPolitica)

	Local lRet		:= .F.

	//Caso o Alias esteja em uso, fecha o mesmo
	If Select("TRIZ") > 0 ; TRIZ->(dbCloseArea()) ; EndIf

	BeginSQL Alias "TRIZ"

		SELECT COUNT(*) QTD FROM %Table:RIZ% RIZ
		WHERE RIZ.%NotDel% AND RIZ.RIZ_IDCONS = %Exp:cPolitica%

	EndSQL

	dbSelectArea("TRIZ")

	If TRIZ->QTD > 0

		lRet := .T.

	EndIf

Return lRet

/*/{Protheus.doc} ExcluiRIZ

@type function
@author Jorge Heitor
@since 06/04/2016
@version 1.0
@description Exclui informações de Processamento de Cálculo Consolidado Anterior

/*/
Static Function ExcluiRIZ(cPolitica)

	Local aArea		:= GetArea()
	Local cChave    := xFilial("RIZ")+cPolitica

	dbSelectArea("RIZ")
	dbSetOrder(1) //RIZ_IDCONS
	dbGoTop()

	dbSeek(cChave)
	If Found()

		While !RIZ->(Eof()) .and. RIZ->(RIZ_FILIAL+RIZ_IDCONS) == cChave

			RecLock("RIZ",.F.)

				RIZ->(dbDelete())

			MsUnlock()

			RIZ->(dbSkip())

		End

	EndIf

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} GeraMetas

@type function
@author Jorge Heitor
@since 14/04/2016
@version 1.0
@description Calcula Resultado Consolidado de Avaliações de Metas

/*/
Static Function GeraMetas(nPerMeta,aPeriodos)

	Local aArea	 := GetArea()
	Local aRIZ		 := {}
	Local cGrupo	 := "01"
	Local nPos		 := 0
	Local nPosFunc 	 := 0
	Local cMetasIn   := ""
	Local cWhere	 := ""
	Local cChave	 := ""
	Local x

	/*
	------------------------
	Composição do Array aRIZ
	------------------------
	aRIZ[x][1]  -> RDJ_FILIAL
	aRIZ[x][2]  -> RDJ_CODPAR
	aRIZ[x][3]  -> cPolitica
	aRIZ[x][4]  -> cGrupo
	aRIZ[x][5]  -> RIY_CODPER
	aRIZ[x][6]  -> nPerMeta
	aRIZ[x][7]  -> nTotPer
	aRIZ[x][8]  -> nMedParc
	aRIZ[x][9]  -> nMedFin
	aRIZ[x][10] -> Date()
	*/

	//Cria Condição WHERE para os períodos do tipo "Meta"
	aEval(aPeriodos,{|y| cMetasIn += Iif(y[2] == '3' , "'" + y[1] + "',","")})

	cMetasIn := "(" + SubString(cMetasIn,1,Len(cMetasIn)-1) + ")"

	If cMetasIn <> "()"

       //Dispensa metas com status (cancelado ou cancelado histórico)
		cWhere := " RDJ_STATUS NOT IN('4','6') "
		cWhere += " AND RDJ_ESCREA <> '' AND RDJ_ITESCR <> '' "
		cWhere += " AND RDJ_PERIOD IN " + cMetasIn
		cWhere := "%" + cWhere + "%"

		//Caso esteja aberto o Alias, fecha-o
		If Select("TRDJ") > 0 ; TRDJ->(dbCloseArea()) ; EndIf

		//Busca somente os Objetivos
		BeginSQL Alias "TRDJ"

			SELECT distinct RDJ_CODOBJ, RDI_DESC
			FROM %Table:RDJ% RDJ
			INNER JOIN %Table:RDV% RDV
				ON RDV_CODPER = RDJ_PERIOD AND RDV_CODOBJ = RDJ_CODOBJ AND RDV_CODPAR = RDJ_CODPAR AND
				   RDV_VERATU = RDJ_VERITM
			INNER JOIN %Table:RDI% RDI
				ON RDI_CODIGO = RDV_CODOBJ AND RDI.%notDel%
			WHERE %Exp:cWhere% AND RDJ.%notDel% AND RDV.%notDel%
			ORDER BY RDJ_CODOBJ

		EndSQL

		dbSelectArea("TRDJ")
		While !TRDJ->(Eof())
			aAdd(aLog,'    ' +  STR0080 + ' ' + TRDJ->RDJ_CODOBJ + " - " + AllTrim(TRDJ->RDI_DESC)) //"Objetivo processado:"
			TRDJ->(dbskip())
		EndDo

		//Caso esteja aberto o Alias, fecha-o
		If Select("TRDJ") > 0 ; TRDJ->(dbCloseArea()) ; EndIf

		BeginSQL Alias "TRDJ"

			SELECT RDJ_CODPAR, RDJ_PERIOD, SUM(RDJ_RESULT) TOTRESULT, COUNT(RDJ_CODPAR) FATOR
			FROM %Table:RDJ% RDJ
			INNER JOIN %Table:RDV% RDV
				ON RDV_CODPER = RDJ_PERIOD AND RDV_CODOBJ = RDJ_CODOBJ AND RDV_CODPAR = RDJ_CODPAR AND
				   RDV_VERATU = RDJ_VERITM
			WHERE %Exp:cWhere%
			GROUP BY RDJ_CODPAR,RDJ_PERIOD
			ORDER BY RDJ_CODPAR,RDJ_PERIOD

		EndSQL

		dbSelectArea("TRDJ")
		While !TRDJ->(Eof())

			//Resultado obtido no período
			nTotPer := Round(( TRDJ->TOTRESULT / TRDJ->FATOR),_nRound)

			//Verifica se o Funcionário ja existe no array de Gravação do RIZ (mediante filtros)
			nPos := aScan(aRIZ,{|x| x[2] == TRDJ->RDJ_CODPAR .And. x[5] == TRDJ->RDJ_PERIOD})

			If nPos <= 0
				aAdd(aRIZ,{xFilial("RDJ"), TRDJ->RDJ_CODPAR, cPolitica, cGrupo, TRDJ->RDJ_PERIOD, nPerMeta, nTotPer, 0, 0, dDataCalc })
			EndIf

			//Verifica se o Funcionário existe no Array de Funcionarios (Para processamento de Outras Pontuações)
			If aScan(aFunc,{|z| z[1] == TRDJ->RDJ_CODPAR }) <= 0
				aAdd(aFunc,{TRDJ->RDJ_CODPAR, 	;	//01-Codigo do Participante
					        xFilial("RDJ"),		;	//02-Filial
					        0,					;	//03-Nota Metas
					        0,					;	//04-Nota Competencias
					        0,					;	//05-Nota Outras Pontuacoes
					        0					;	//06-Nota Total
					        })
			EndIf

			TRDJ->(dbSkip())
		End

		If Len(aRIZ) > 0

			//Processa Média Parcial para o ultimo registro de cada Funcionário (Serão totalizados todos os períodos)
			cChave := aRIZ[1][1] + aRIZ[1][2] //Filial + Codigo RD0
			nValor := 0
			nFator := 0

			For x := 1 To Len(aRIZ)

				If cChave <> aRIZ[x][1] + aRIZ[x][2]

					aRIZ[x-1][8] := Round(nValor / nFator,_nRound)                    //Media Parcial
					aRIZ[x-1][9] := Round(aRIZ[x-1][8] * (aRIZ[x-1][6]/100),_nRound)  //Resultado Final
					nValor := 0
					nFator := 0

				EndIf

				nValor += aRIZ[x][7]
				nFator ++

				cChave := aRIZ[x][1] + aRIZ[x][2]

			Next x

			//Processa último Funcionário
			nLast := Len(aRIZ)
			aRIZ[nLast][8] := Round(nValor / nFator,_nRound)                       //Media Parcial
			aRIZ[nLast][9] := Round(aRIZ[nLast][8] * (aRIZ[nLast][6]/100),_nRound) //Resultado Final
			nValor := 0
			nFator := 0

			MsAguarde( { || GravaRIZ(aRIZ) } , STR0033, STR0057) //"Aguarde"###"Gravando Metas..."

		EndIf

	EndIf

	RestArea(aArea)

Return

/*/{Protheus.doc} GeraComp

@type function
@author Jorge Heitor
@since 14/04/2016
@version 1.0
@description Calcula Resultado Consolidado de Avaliações de Competências

/*/
Static Function GeraComp(nPerComp,aPeriodos)

	Local aArea		:= GetArea()
	Local aRIZ		:= {}
	Local cGrupo	:= "02"
	Local nPos		:= 0
	Local nPosFunc	:= 0
	Local cCompIn	:= ""
	Local cWhere	:= ""
	Local nTotAva	:= 0
	Local x
	Local cChave	:= ""

	/*
	------------------------
	Composição do Array aRIZ
	------------------------
	aRIZ[x][1]  -> RDD_FILIAL
	aRIZ[x][2]  -> RDD_CODADO
	aRIZ[x][3]  -> cPolitica
	aRIZ[x][4]  -> cGrupo
	aRIZ[x][5]  -> RDD_CODAVA
	aRIZ[x][6]  -> nPerComp
	aRIZ[x][7]  -> nTotAva
	aRIZ[x][8]  -> nMedParc
	aRIZ[x][9]  -> nMedFin
	aRIZ[x][10] -> Date()
	*/

	//Cria Condição WHERE para os períodos do tipo "Competência"
	aEval(aPeriodos,{|y| cCompIn += Iif(y[2] == '4' , "'" + y[1] + "',","")})

	cCompIn := "(" + SubString(cCompIn,1,Len(cCompIn)-1) + ")"

	If cCompIn <> "()"

		cWhere := " RD6.RD6_CODPER IN " + cCompIn
		cWhere := "%" + cWhere + "%"

		//Caso esteja aberto o Alias, fecha-o
		If Select("TRD6") > 0 ; TRD6->(dbCloseArea()) ; EndIf

		BeginSQL Alias "TRD6"

			SELECT RD6_CODIGO,RD6_DESC,RD6_STATUS
			FROM %Table:RD6% RD6
			WHERE %Exp:cWhere% AND RD6.%notDel%
			ORDER BY RD6_CODIGO

		EndSQL

		dbSelectArea("TRD6")
		While !TRD6->(Eof())

			//Caso a Pesquisa ainda esteja aberta, coloca no LOG e pula para a próxima
			If TRD6->RD6_STATUS <> '1'

				aAdd(aLog,STR0058 + TRD6->RD6_CODIGO + " - " + AllTrim(TRD6->RD6_DESC) + STR0059) //"A avaliação "###" não foi processada, pois esta com status 'Aberto'."
				TRD6->(dbSkip())
				Loop

			EndIf

			/*
			--------------------------------------
			Busca resultados para a pesquisa atual
			--------------------------------------
			*/
			//Fecha Alias caso esteja aberto
			If Select("TRDD") > 0 ; TRDD->(dbCloseArea()) ; EndIf

			//Monta Cláusula Where
			cWhere := " RDD.RDD_CODAVA = '" + TRD6->RD6_CODIGO + "'"
			cWhere += " AND RDD.RDD_TIPOAV IN ('1','3')"
			cWhere := "%" + cWhere + "%"

			BeginSQL Alias "TRDD"

				SELECT RDD.RDD_FILIAL, RDD.RDD_CODAVA, RDD.RDD_CODADO, RDD.RDD_TIPOAV, SUM(RDD.RDD_PTOMAX) RDD_PTOMAX, SUM(RDD.RDD_RESOBT) RDD_RESOBT
				FROM %Table:RDD% RDD
				WHERE %Exp:cWhere% AND RDD.%notDel%
				GROUP BY RDD.RDD_FILIAL, RDD.RDD_CODAVA, RDD.RDD_CODADO, RDD.RDD_TIPOAV
				ORDER BY RDD.RDD_FILIAL ASC, RDD.RDD_CODAVA ASC, RDD.RDD_CODADO ASC, RDD.RDD_TIPOAV DESC

			EndSQL

			dbSelectArea("TRDD")
			While !TRDD->(Eof())

				//Se for o mesmo funcionario anterior, para a mesma avaliação, pula, pois pega apenas o primeiro registro.
				If cChave == TRDD->RDD_FILIAL + TRDD->RDD_CODAVA + TRDD->RDD_CODADO

					TRDD->(dbSkip())
					Loop
				EndIf

				//Alimenta informações de Funcionarios para o processo de outras pontuações
				nPosFunc := aScan(aFunc,{|z| z[1] == TRDD->RDD_CODADO })
				If nPosFunc <= 0
					aAdd(aFunc,{TRDD->RDD_CODADO, 	;	//01-Codigo do Participante
						        TRDD->RDD_FILIAL,	;	//02-Filial
						        0,					;	//03-Nota Metas
						        0,					;	//04-Nota Competencias
						        0,					;	//05-Nota Outras Pontuacoes
						        0					;	//06-Nota Total
						        })
				EndIf

				//Calculo do Resultado Obtido
				nTotAva := Round((TRDD->RDD_RESOBT/TRDD->RDD_PTOMAX) * 100,_nRound)

				//Alimenta Array aRIZ
				aAdd(aRIZ,{TRDD->RDD_FILIAL,TRDD->RDD_CODADO, cPolitica, cGrupo, TRDD->RDD_CODAVA, nPerComp,nTotAva,0,0,dDataCalc})

				//Atualiza chave para verificação
				cChave := TRDD->RDD_FILIAL + TRDD->RDD_CODAVA + TRDD->RDD_CODADO

				TRDD->(dbSkip())

			End

			aAdd(aLog,'    ' +  STR0079 + ' ' + TRD6->RD6_CODIGO + " - " + AllTrim(TRD6->RD6_DESC)) //"Avaliação processada:"

			TRD6->(dbSkip())

		End

		If Len(aRIZ) > 0

			//Processa Média Parcial para o ultimo registro de cada Funcionário (Serão totalizados todos os períodos)
			cChave := aRIZ[1][1] + aRIZ[1][2] //Filial + Codigo RD0
			nValor := 0
			nFator := 0

			For x := 1 To Len(aRIZ)

				If cChave <> aRIZ[x][1] + aRIZ[x][2]

					aRIZ[x-1][8] := Round( (nValor / (nFator * 100)) * 100,_nRound) //Media Parcial
					aRIZ[x-1][9] := Round(aRIZ[x-1][8] * (aRIZ[x-1][6]/100),_nRound) //Resultado considerando o Peso
					nValor := 0
					nFator := 0

				EndIf

				nValor += aRIZ[x][7]
				nFator ++

				cChave := aRIZ[x][1] + aRIZ[x][2]

			Next x

			//Processa último Funcionário
			nLast := Len(aRIZ)
			aRIZ[nLast][8] := Round( (nValor / (nFator * 100)) * 100,_nRound) //Media Parcial
			aRIZ[nLast][9] := Round(aRIZ[nLast][8] * (aRIZ[nLast][6]/100),_nRound)
			nValor := 0
			nFator := 0

			MsAguarde( { || GravaRIZ(aRIZ) } , STR0033, STR0066)	//"Aguarde"###"Gravando Competências..."

		EndIf

		//Fecha alias temporários
		TRD6->(dbCloseArea())

		If Select("TRDD") > 0
			TRDD->(dbCloseArea())
		EndIf

	EndIf

RestArea(aArea)

Return

/*/{Protheus.doc} GeraForm

@type function
@author Jorge Heitor
@since 06/04/2016
@version 1.0
@description Registra resultados recebidos via PE APDCONSOLID

/*/
Static Function GeraForm(nPerForma,aPeriodos)

	Local aArea			:= GetArea()
	Local nMax			:= 100
	Local nPontos		:= 0
	Local cGrupo		:= "03"
	Local aRIZ			:= {}
	Local x
	Local cCodRD0		:= ""
	Local cChave		:= ""

	Local aOutros  		:= {}
	Local nSeq			:= 1

	Local nX
	Local nY
	Local nZ
	Local nPosFunc

	Local lApdConsol := ExistBlock("APDCONSOLID")


	/*
	------------------------
	Composição do Array aRIZ
	------------------------
	aRIZ[x][1]  -> FILIAL
	aRIZ[x][2]  -> Participante
	aRIZ[x][3]  -> cPolitica
	aRIZ[x][4]  -> cGrupo
	aRIZ[x][5]  -> Sequencial
	aRIZ[x][6]  -> Peso
	aRIZ[x][7]  -> Resultado
	aRIZ[x][8]  -> nMedParc
	aRIZ[x][9]  -> nMedFin
	aRIZ[x][10] -> Date()
	aRIZ[x][11] -> Descrição
	*/

	For nX := 1 To Len(aFunc)

		If lApdConsol
			aOutros := ExecBlock("APDCONSOLID", .F., .F., {cPolitica,aFunc[nX][2],aFunc[nX][1]} )
		EndIf

       If ValType(aOutros) == "A"
    		For nY := 1 To Len(aOutros)

                 // Descrição da Pontuação e Resultado
              If !empty(aOutros[nY][1]) .and. !empty(aOutros[nY][2])
        			aAdd(aRIZ,{xFilial("RIZ"),aFunc[nX][1],cPolitica,cGrupo,StrZero(nSeq,6),nPerForma,aOutros[nY][2],0,0,dDataCalc,aOutros[nY][1]})
	    		    nSeq++
	    		EndIf

    		Next nY

    	EndIf

	Next nX

	If Len(aRIZ) > 0

		//Processa Média Parcial para o ultimo registro de cada Participante (Serão totalizados todos os períodos)
		cChave := aRIZ[1][1] + aRIZ[1][2] //Filial + Participante
		nValor := 0
		nFator := 0

		For x := 1 To Len(aRIZ)

			If cChave <> aRIZ[x][1] + aRIZ[x][2]
				aRIZ[x-1][8] := Round(nValor,_nRound) //Media Parcial (Considera a pontuação atingida)
				aRIZ[x-1][9] := Round(Iif(nValor > 100,100,nValor) * (aRIZ[x-1][6]/100),_nRound) //Resultado considerando o Peso (Considera Teto de 100 pontos)
				nValor := 0
			EndIf

			nValor += aRIZ[x][7]

			cChave := aRIZ[x][1] + aRIZ[x][2]

		Next x

		//Processa último participante
		nLast := Len(aRIZ)
		aRIZ[nLast][8] := Round(nValor,_nRound) //Media Parcial (Considera a pontuação atingida)
		aRIZ[nLast][9] := Round(Iif(nValor > 100,100,nValor) * (aRIZ[nLast][6]/100),_nRound) //Resultado considerando o Peso (Considera Teto de 100 pontos)
		nValor := 0
		nFator := 0

		MsAguarde( { || GravaRIZ(aRIZ) } , STR0033, STR0068)	//"Aguarde"###"Gravando Outras Pontuações..."

	EndIf

	RestArea(aArea)

Return

/*/{Protheus.doc} GeraCons

@type function
@author Jorge Heitor
@since 06/04/2016
@version 1.0
@description Calcula Média Final Consolidada (Com base nos dados da tabela RIZ que forem contemplados pela execução da rotina)

/*/
Static Function GeraCons()

	Local aArea		:= GetArea()
	Local cGrupo	:= "99"
	Local cKey		:= "000000"
	Local aRIZ		:= {}

	/*
	------------------------
	Composição do Array aRIZ
	------------------------
	aRIZ[x][1]  -> RIZ_FILIAL
	aRIZ[x][2]  -> cCdoRD0
	aRIZ[x][3]  -> cPolitica
	aRIZ[x][4]  -> cGrupo
	aRIZ[x][5]  -> cKey
	aRIZ[x][6]  -> nPerForm
	aRIZ[x][7]  -> PONTOS
	aRIZ[x][8]  -> nMedParc
	aRIZ[x][9]  -> nMedFin
	aRIZ[x][10] -> Date()
	*/


	If Select("TRIZ") > 0 ; TRIZ->(dbCloseArea()) ; EndIf

	BeginSQL Alias "TRIZ"

		SELECT RIZ_CODRD0, RIZ_IDCONS, SUM(RIZ_MEDTOT) MEDIA
		FROM %Table:RIZ% RIZ
		WHERE RIZ_IDCONS = %Exp:cPolitica%
		AND RIZ_GRUPO IN ('01','02','03')
		AND RIZ.%NotDel%
		GROUP BY RIZ_CODRD0,RIZ_IDCONS

	EndSQL

	dbSelectArea("TRIZ")
	While !TRIZ->(Eof())

		aAdd(aRIZ,{xFilial("RIZ"),TRIZ->RIZ_CODRD0, cPolitica, cGrupo, cKey, 0, 0, 0, Round(TRIZ->MEDIA,_nRound), dDataCalc})

		TRIZ->(dbskip())
	End

	MsAguarde( { || GravaRIZ(aRIZ) } , STR0033, STR0069)	//"Aguarde"###"Gravando Cálculo Consolidado..."

	RestArea(aArea)

Return

/*/{Protheus.doc} GravaRIZ

@type function
@author Jorge Heitor
@since 14/04/2016
@version 1.0
@description Grava Array gerado pelas Funções na tabela RIZ

/*/
Static Function GravaRIZ(aRIZ)

	Local aArea		:= GetArea()
	Local x

	dbSelectArea("RIZ")

	For x := 1 To Len(aRIZ)

		RecLock("RIZ",.T.)

			RIZ->RIZ_FILIAL := xFilial("RIZ")
			RIZ->RIZ_CODRD0 := aRIZ[x][2]
			RIZ->RIZ_IDCONS := aRIZ[x][3]
			RIZ->RIZ_GRUPO  := aRIZ[x][4]
			RIZ->RIZ_KEY	:= aRIZ[x][5]
			RIZ->RIZ_PESO   := aRIZ[x][6]
			RIZ->RIZ_RESOBT := aRIZ[x][7]
			RIZ->RIZ_MEDPAR := aRIZ[x][8]
			RIZ->RIZ_MEDTOT := aRIZ[x][9]
			RIZ->RIZ_DTCALC := aRIZ[x][10]

          	//Descrição de outras pontuações vindas do PE APDCONSOLID
			If Len(aRIZ[x]) == 11
				RIZ->RIZ_KEYDSC := aRIZ[x][11]
			EndIf

			//Atualiza aFunc com as notas
			aFunc[ aScan(aFunc,{|z| z[1] == RIZ->RIZ_CODRD0 }), 3 ] += if( RIZ->RIZ_GRUPO == '01', RIZ->RIZ_MEDTOT, 0 )
			aFunc[ aScan(aFunc,{|z| z[1] == RIZ->RIZ_CODRD0 }), 4 ] += if( RIZ->RIZ_GRUPO == '02', RIZ->RIZ_MEDTOT, 0 )
			aFunc[ aScan(aFunc,{|z| z[1] == RIZ->RIZ_CODRD0 }), 5 ] += if( RIZ->RIZ_GRUPO == '03', RIZ->RIZ_MEDTOT, 0 )
			aFunc[ aScan(aFunc,{|z| z[1] == RIZ->RIZ_CODRD0 }), 6 ] += if( RIZ->RIZ_GRUPO == '99', RIZ->RIZ_MEDTOT, 0 )

		MsUnlock()

	Next x

	RestArea(aArea)

Return

//Valida Parâmetros de processamento

Function APD005V(cPolitica)

	Local lRet 		:= .T.
	Local aArea 	:= GetArea()
	Local cMsg  	:= ''
	Local cStatus 	:= Posicione("RIX",1,FWxFilial("RIX") + cPolitica,"RIX_STATUS")

	If  cStatus $ "2/3"

		lRet := .F.
		cMsg := STR0070+If(cStatus=='2',STR0071,STR0072)+"." 	//"A Politica de Consolidação informada encontra-se "###"cancelada"###"fechada"

	EndIf

	If !Empty(cMsg) .And. !lRet

		help("APD005V",,"RIX_STATUS",STR0073,cMsg,1,0,,,,,) //"Política"

	EndIf

	RestArea(aArea)

Return lRet

/*/{Protheus.doc} _GravaLog

@type function
@author Jorge Heitor
@since 08/04/2016
@version 1.0
@description Apresenta LOG (Resumo) e permite visualizar Log Completo dos dados processados

/*/
Static Function _GravaLog(aLog)

	Local aSays			:= {}
	Local aButtons		:= {}
	Local nOpca
	Local oDlg1
	Local aAdvSize		:= {}
	Local aInfoAdvSize	:= {}
	Local aObjSize		:= {}
	Local aObjCoords	:= {}
	Local aGDCoord		:= {}
	Local aArea			:= GetArea()
	Local cLog			:= ""
	Local cArq			:= GetSrvProfString("Startpath", "") + CriaTrab( , .F. ) + ".txt"
	Local nHandle		:= fCreate(cArq)
	Local x
	Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F. }) //[2]Ofuscamento
	Local aFldRel		:= Iif( aOfusca[2], FwProtectedDataUtil():UsrNoAccessFieldsInList( {"RD0_NOME"} ), {} )
	Local lOfusca		:= Len(aFldRel) > 0

	Private cCadastro 	:= OemToAnsi(STR0004) //"Processamento Concluído"

	If nHandle < 0

		MsgStop(STR0005) //"_GravaLog - Não foi possivel criar o arquivo de Log."

	EndIf

	cLog := STR0017 + _ENTER //"Processo concluído! Clique em 'Confirmar' para mais detalhes."
	cLog += _ENTER

	For x := 1 To Len(aLog)

		cLog += aLog[x] + _ENTER
		FWrite(nHandle,aLog[x]+_ENTER)

	Next x

	FWrite(nHandle,_ENTER)
	FWrite(nHandle,Replicate("-",115) + _ENTER)
	FWrite(nHandle,STR0074 + _ENTER) //"LISTA DE PARTICIPANTES PROCESSADOS"
	FWrite(nHandle,Replicate("-",115) + _ENTER)
	FWrite(nHandle,_ENTER)
	FWrite(nHandle,PADR(STR0077,12)  + " " + PADR(STR0078,34)  + " " + PADL("Metas",9)  + " " + PADL("Competencia",11)   + " " + PADL("Outros",9) + " " + PADL("Total",9)  + _ENTER) //" "Participante"###"Nome"###"Metas"###"Competencia"###"Outros"###"Total"
	FWrite(nHandle,Replicate("-",12) + " " + Replicate("-",34) + " " + Replicate("-",9) + " " + Replicate("-",11)        + " " + Replicate("-",9) + " " + Replicate("-",9) + _ENTER)

	ASORT( aFunc,,, {|x,y| x[1] < y[1] } )

	For x := 1 To Len(aFunc)

		FWrite(nHandle,PadR(aFunc[x][1],13) + If(lOfusca, Replicate('*',35), PadR(Posicione("RD0",1,xFilial("RD0") + aFunc[x][1], "RD0_NOME"),35) ) + Transform(aFunc[x][3],"@E 9999.9999") + '   '  + Transform(aFunc[x][4],"@E 9999.9999") + ' ' + Transform(aFunc[x][5],"@E 9999.9999") + ' ' + Transform(aFunc[x][6],"@E 9999.9999") + _ENTER)

	Next x

	FClose(nHandle)

	/*
		Monta dimensões dos objetos
	*/
	aAdvSize		:= MsAdvSize()
	aAdvSize[5]		:= (aAdvSize[5]/100) * 35	//horizontal
	aAdvSize[6]		:= (aAdvSize[6]/100) * 55	//Vertical
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )
	aGdCoord		:= { (aObjSize[1,1]+3), (aObjSize[1,2]+5), (((aObjSize[1,3])/100)*25), (((aObjSize[1,4])/100)*29.6) }	//1,3 Vertical /1,4 Horizontal

	SetaPilha()

	DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
	DEFINE MSDIALOG oDlg1 TITLE cCadastro FROM  aAdvSize[7],20 TO aAdvSize[6]-50,600  OF oMainWnd PIXEL

		@ aGdCoord[1]+7,aGdCoord[2]	GROUP oGroup1 TO (aGdCoord[3]*1.9)+5,aGdCoord[4]+5  LABEL "" OF oDlg1 PIXEL
		oGroup1:oFont:=oFont
		@ aGdCoord[1]+11,aGdCoord[2]+4 Get oGet Var cLog Memo Size 273,173 OF oGroup1 Pixel

		aButtons	:=	{}

	ACTIVATE MSDIALOG oDlg1 CENTERED ON INIT EnchoiceBar( oDlg1 , { || nOpca 	:= 1, oDlg1:End() } , { || nOpca 	:= 0 , oDlg1:End() } , NIL , aButtons )

	SetaPilha()

	/*
		Variaveis utilizadas para Parâmetros
	*/
	If nOpca == 1
		AbreLog(cArq)
	EndIf
	Delete File(cArq)

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} AbreLog

@type function
@author Jorge Heitor
@since 07/04/2016
@version 1.0
@description Validações específicas para constatar se o período informado no parâmetro pode ser utilizado para o Cálculo de Metas

/*/
Static Function AbreLog(cArquivo)

	Local cNomeArq	:= Iif(SubStr(cArquivo,1,1) $ "\", SubsTr(cArquivo, RAT("\",cArquivo) ,Len(cArquivo)),cArquivo)
	Local cDirLocal	:= GetTempPath()

	If CpyS2T(cArquivo,cDirLocal)

		ShellExecute("Open",cDirLocal + cNomeArq, "", "C:\", 3 )

	Else

		MsgStop(STR0008 + cNomeArq + STR0009) // "Falha na cópia do arquivo " | " para visualização. O arquivo estará disponível na pasta '\SYSTEM\' do Servidor."

	Endif

Return Nil
