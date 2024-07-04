#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEM044.CH"
#INCLUDE "SCOPECNT.CH"

Static lRGEStat   	:= ChkFile("RGE") .And. RGE->(ColumnPos( "RGE_STATUS" )) > 0
Static lRGEDtAlt   	:= ChkFile("RGE") .And. RGE->(ColumnPos( "RGE_DTALT" )) > 0

#DEFINE TAMIMP 120

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao		³ GPEM044    ³ Autor ³ Claudinei Soares               ³ Data ³ 07/06/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao 	³ Atualizacao PPE                 									    ³±±
±±³          	³ Rotina para atualizar no histórico de contratos (RGE) os funcionarios ³±±
±±³          	³ que irao aderir ao PPE - Programa de Protecao ao Emprego              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   	³ GPEM044()                                   			    		    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      	³ Generico (DOS e Windows)                                   		    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.               			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador  ³ Data     ³ FNC			³  Motivo da Alteracao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Claudinei S. ³07/06/2016³ TUQEKD         ³Criacao novo fonte.                        ³±±
±±³Emerson G.   ³14/07/2020³ DRHGCH-20124   ³Considerar codigo PPE nas alteracoes.      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function GPEM044()

Local aSays		   	:= {}
Local aButtons	   	:= {}
Local cPerg        	:= "GPEM044"
Local nOpcA		  	:= 0

Private aArea		:= GetArea()
Private aAreaSRA	:= SRA->( GetArea() )
Private cCadastro 	:= OemToAnsi(STR0001) //"PPE - Programa de Proteção ao Emprego"

Private cSraFilter	:= ""
Private aRetFiltro	:= {}
Private aFilterExp	:= {}

dbSelectArea("SX1")
dbSetOrder(1)

If SX1->(dbSeek("GPEM044"))
	Pergunte(cPerg,.F.)
Else
	Help( ,, OemToAnsi(STR0016),, OemToAnsi(STR0017), 1, 0 ) //"Atenção" ## "Esta rotina só está disponível a partir do Release 12.1.07 de Agosto de 2016"
	Return
Endif

aAdd( aFilterExp , { "FILTRO_ALS" , "SRA"    	, .T. } )			 	/* Retorne os Filtros que contenham os Alias Abaixo */
aAdd( aFilterExp , { "FILTRO_PRG" , FunName()	, NIL , NIL    } )	/* Que Estejam Definidos para a Função */

aAdd(aSays,OemToAnsi(STR0003))			//"Rotina de atualização de funcionários no PPE - Programa de Proteção ao Emprego"
aAdd(aSays,OemToAnsi(STR0004))			//"Consiste em atualizar o campo RGE_PPE do Histórico de Contratos, a fim de "
aAdd(aSays,OemToAnsi(STR0005))			//"incluir funcionários no programa, será gerado de acordo com os parâmetros "
aAdd(aSays,OemToAnsi(STR0006))			//"informados."

aAdd(aButtons, { 17,.T.,{||  aRetFiltro := FilterBuildExpr( aFilterExp ) } } )
aAdd(aButtons, { 5 ,.T.,{||  Pergunte(cPerg,.T. ) } } )
aAdd(aButtons, { 1 ,.T.,{|o| nOpcA := 1,IF(gpconfOK(),FechaBatch(),nOpcA:=0) }} )
aAdd(aButtons, { 2 ,.T.,{|o| FechaBatch() }} )
FormBatch( cCadastro, aSays, aButtons )

IF nOpcA == 1
	Processa({|lEnd| fGp044Pro(cPerg),STR0001})  //"PPE - Programa de Proteção ao Emprego"
EndIF

//Restaura os Dados de Entrada
RestArea( aAreaSRA )
RestArea( aArea )

Return( NIL )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Funcao    ³ fGp044Pro		³Autor³  Claudinei Soares³ Data ³14/09/2015 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descricao ³Processo de atualização do campo RGE_PPE no Histórico de    ³
³          ³contratos   												³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³														    ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEM044                                                     ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

Static Function fGp044Pro(cPerg)

Local aInfoSRA		:= {}
Local aContrato		:= {}
Local aArea			:= GetArea()
Local cOperacao		:= "" // A=Altera registro RGE; I=Inclui registro RGE; E= Inclui inconsistência no Log
Local nC			:= 0
Local nI        	:= 0
Local nTam			:= 0
Local cMsgLog		:= ""
Local cMsgAux		:= ""
Local cItem			:= " - "
Local cChaveRGE		:= ""
Local cConteudo	:= ""
Local cCampo	:= ""
Local aTitle		:= {}
Local aLogProc  	:= {}
Local nPosTab		:= 0
Local dDtCancel		:= CtoD("//")
Local dDtReduc		:= CtoD("//")
Local dDtVig		:= CtoD("//")
Local dDtAlt		:= CtoD("//")
Local nDiasPror		:= 0 
Local nTpAtua		:= If(Empty(MV_PAR12), 1, MV_PAR12)		//Tipo de Atualização
Local lRet    		:= .T.
Local lAddNew		:= .F.

//Log de ocorrencias
Aadd( aLogProc,OemToAnsi(STR0007))  //"Inicio do processamento"
Aadd( aLogProc,{} )

//Busca os funcionarios conforme parametros de geracao
If !fGp044Info(@aInfoSRA)
	Return()
EndIf

dbSelectArea("RGE")
RGE->(DbSetOrder(2))

For nI := 1 To Len(aInfoSRA)
	Aadd(aTitle, OemToAnsi(STR0009)) //"Log de Ocorrencias - PPE"
	Aadd( aLogProc,{})

	cMsgLog := "" //Limpa variavel que armazena erros

	If dbSeek(aInfoSRA[nI,1]+aInfoSRA[nI,2])
		While !Eof() .And. RGE->RGE_FILIAL+RGE->RGE_MAT == aInfoSRA[nI,1]+aInfoSRA[nI,2] 
			aAdd(aContrato, { RGE->RGE_DATAIN, RGE->RGE_DATAFI, RGE->RGE_STATUS, RGE->RGE_DTALT})
			cChaveRGE:= RGE->RGE_FILIAL+RGE->RGE_MAT+DTOS(RGE->RGE_DATAIN)
			dbSkip()
		EndDo
		
		//Busca o último contrato do funcionario
		nC := LEN( aContrato )

		If Empty(aContrato[nC,2])
			If aInfoSRA[nI,4] >= aContrato[nC,1] .Or. aInfoSRA[nI,5] >= aContrato[nC,1]
				cOperacao := "A" //Alterar o contrato	
			Else
				cOperacao := "E" //Mostrar no log a inconsistência
			Endif

		ElseIf (aInfoSRA[nI,4] >= aContrato[nC,1] .And. If(aContrato[nC, 3] == "4", aContrato[nC,4]  >= aInfoSRA[nI,4], aContrato[nC,2] >= aInfoSRA[nI,4]));                                                                                
				.Or. (aInfoSRA[nI,4] <= aContrato[nC,1] .And. aInfoSRA[nI,5] >= aContrato[nC,1] )
			cOperacao := "E" //Mostrar no log a inconsistência				
		Else
			// Se a data final do último contrato for inferior a data de início do PPE gera um novo registro no histórico de contratos 
			If If(aContrato[nC, 3] == "4", aContrato[nC,4], aContrato[nC,2]) < aInfoSRA[nI,4] 
				cOperacao := "I" // Incluir um novo contrato
			Else
				cOperacao := "E" //Mostrar no log a inconsistência
			Endif
		Endif

		// Verificar se o codigo PPE é o mesmo caso seja diferente de Inclusão
		If RGE->(dbSeek(cChaveRGE)) .And. nTpAtua != 1
			If RGE->(ColumnPos("RGE_COD")) > 0
				If RGE->RGE_COD != aInfoSRA[nI][7]
					cOperacao := "E" //Mostrar no log a inconsistência
				EndIf
			EndIf
		EndIf		

	Else //Caso não encontre registro do funcionário no histórico de contratos, irá incluir.
		cOperacao := "I" //Incluir um novo contrato
	EndIf

	If cOperacao 	== "E" //Incluir no log a mensagem de inconsistência
		cMsgLog += cItem + OemToAnsi(STR0010)//"Já existe um contrato cadastrado para o funcionário, mas está com vigência conflitante com a informada para o PPE."
		cMsgLog += space(TAMIMP - Len(OemToAnsi(STR0010)) - Len(cItem))
		cMsgLog += cItem + OemToAnsi(STR0011)//"Verifique a necessidade deste funcionário estar no PPE."
		cMsgLog += space(TAMIMP - Len(OemToAnsi(STR0011)) - Len(cItem))
		cMsgLog += OemToAnsi(STR0012)//"Se for realmente necessário altere a vigência do contrato ou encerre este e inclua um novo contrato com vigência compatível com o PPE."
		cMsgLog += space(TAMIMP - Len(OemToAnsi(STR0012)))
	ElseIf cOperacao == "I" //Incluir na RGE um novo contrato com a vigencia igual a vigencia do PPE
		If nTpAtua <> 1
			cMsgLog += cItem + OemToAnsi(STR0021)//"Funcionario não possui registro ativo para esse tipo de processamento (Prorrogação/Cancelamento/Redução)"
			cMsgLog += space(TAMIMP - Len(OemToAnsi(STR0021)) - Len(cItem))
		Else
			RecLock ("RGE", .T. )
			RGE->RGE_FILIAL 	:= aInfoSRA[nI,1]
			RGE->RGE_MAT 		:= aInfoSRA[nI,2]
			RGE->RGE_PPE		:= "1"
			RGE->RGE_DATAIN		:= aInfoSRA[nI,4]
			RGE->RGE_DATAFI		:= aInfoSRA[nI,5]
			If RGE->(ColumnPos("RGE_COD")) > 0
				RGE->RGE_COD	:= aInfoSRA[nI,7]
			Endif
			RGE->( MsUnlock() )
			cMsgLog += cItem + OemToAnsi(STR0013)//"Incluído um novo registro no Histórico de Contratos do funcionário"
			cMsgLog += space(TAMIMP - Len(OemToAnsi(STR0013)) - Len(cItem))
		Endif	

	ElseIf cOperacao == "A" //Alterar o contrato atual na RGE atualizando o campo RGE_PPE
		If dbSeek(cChaveRGE)
			RecLock ("RGE", .F. )
			RGE->RGE_PPE	:= "1"
			RGE->RGE_DATAIN	:= aInfoSRA[nI,4]
			RGE->RGE_DATAFI	:= aInfoSRA[nI,5]
			If RGE->(ColumnPos("RGE_COD")) > 0
				RGE->RGE_COD:= aInfoSRA[nI,7]
				If !Empty(RGE->RGE_COD) .And. nTpAtua > 1 .And. lRGEStat .And. lRGEDtAlt
				
					dDtVig		:= aInfoSRA[nI,5]  //Data Final Vigencia
					dDtCancel	:= aInfoSRA[nI,8]  //Data Cancelamento 
					dDtReduc	:= aInfoSRA[nI,9]  //Data Redução
					nDiasPror	:= aInfoSRA[nI,10] //Dias Prorrogação

					If nTpAtua == 2	.And. !Empty(dDtVig) 		//Prorrogação
						If nDiasPror > 0							
							
							dDtAlt		:= dDtVig + nDiasPror
							dDtAltCpo	:= RGE->RGE_DTALT
							cConteudo 	:=  If(!Empty(dDtAltCpo),DtoS(dDtAltCpo), DtoS(dDtAlt))
							cConteudo 	:=  SubStr(AllTrim(cConteudo),7,2) + "/" + SubStr(AllTrim(cConteudo),5,2) + "/" + SubStr(AllTrim(cConteudo),1,4)	//Dia + Mes + Ano	
							cCampo		:= "RGE_DTALT"

							// Grava historico dos dados da primeira prorrogacao somente a partir da segunda prorrogacao
							// Primeira prorrogacao, não grava nada
							If !Empty(dDtAltCpo)
								// Antes de trocar, grava histórico na tabela SR9
								dbSelectArea("SR9")       
								SR9->( dbSetOrder(1) ) // R9_FILIAL+R9_MAT+R9_CAMPO+DTOS(R9_DATA)
								SR9->( DbGoTop() )
								SR9->( dbSeek(SRA->RA_FILIAL + SRA->RA_MAT + cCampo) )
								lAddNew := !( SR9->( dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + cCampo + Dtos( dDataBase ) ) ) )
								
								If SR9->( RecLock( "SR9" , lAddNew , .T. ) )
									SR9->R9_FILIAL   := SRA->RA_FILIAL
									SR9->R9_MAT      := SRA->RA_MAT
									SR9->R9_DATA     := dDataBase
									SR9->R9_CAMPO    := cCampo
									SR9->R9_DESC     := AllTrim(cConteudo)
									SR9->( MsUnLock() )
								EndIf
							EndIf
						
							RGE->RGE_DTALT  := (dDtAlt)
							RGE->RGE_STATUS := "3"
						else
							cMsgLog += cItem + OemToAnsi(STR0020)//"Quantidade de dias de prorrogação não preenchida para esse Codigo de PPE - Tabela S061"
							cMsgLog += space(TAMIMP - Len(OemToAnsi(STR0020)) - Len(cItem))
							lRet := .F.
						Endif		

					ElseIf nTpAtua == 3 		//Redução
						If !Empty(dDtReduc)
							RGE->RGE_DTALT  :=  dDtReduc
							RGE->RGE_STATUS := "4"
						else
							cMsgLog += cItem + OemToAnsi(STR0019)//"Data de Reduçao não preenchida para esse Codigo de PPE - Tabela S061"
							cMsgLog += space(TAMIMP - Len(OemToAnsi(STR0019)) - Len(cItem))
							lRet := .F.
						Endif		

					ElseIf nTpAtua == 4	 
						If !Empty(dDtCancel)	//Cancelamento
							RGE->RGE_DTALT  := dDtCancel
							RGE->RGE_STATUS := "2"
						else
							cMsgLog += cItem + OemToAnsi(STR0018)//"Data de Cancelamento não preenchida para esse Codigo de PPE - Tabela S061"
							cMsgLog += space(TAMIMP - Len(OemToAnsi(STR0018)) - Len(cItem))
							lRet := .F.
						Endif		
					Endif	
				Endif 		
			Endif
			If lRet
				cMsgLog += cItem + OemToAnsi(STR0014)//"Atualizado o Histório de Contratos do funcionário"
				cMsgLog += space(TAMIMP - Len(OemToAnsi(STR0014)) - Len(cItem))
			Endif
			RGE->( MsUnlock() )
		Endif
	Endif

	//Geracao do nome do funcionario no log de ocorrencias
	cMsgAux := DToC(dDataBase) + " - " + AllTrim(aInfoSRA[nI,1]) + " - "
	cMsgAux += AllTrim(aInfoSRA[nI,2]) + " - " + AllTrim(aInfoSRA[nI,3]) + " : "
	cMsgAux += space(TAMIMP - Len(cMsgAux))
	cMsgAux += cMsgLog
	cMsgLog := cMsgAux

	//Tratamento para tamanho do Log
	If Len(cMsgLog) <= TAMIMP
		aAdd(aLogProc, cMsgLog)
	Else
		aAdd(aLogProc, Subs(cMsgLog, 1, TAMIMP))
		For nTam:= 1 to Int(Len(cMsgLog)/TAMIMP)
			aAdd(aLogProc, Subs(cMsgLog, TAMIMP * nTam + 1, TAMIMP))
		Next nTam
	EndIf
Next nI

If Len(aLogProc) > 0 //Imprime Log
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Apresenta o Log                                         ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	If Len(aLogProc) == 2
		Aadd( aLogProc,OemToAnsi(STR0015))	//"A consulta não retornou informações, favor verificar os parâmetros de geração."
	Endif

	fMakeLog({aLogProc}, aTitle, Nil, Nil, cPerg, OemToAnsi(STR0009), "M", "P",, .F.) //"Log de Ocorrencias - PPE"
Endif

Return()

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Funcao    ³ fGp044Info      ³Autor³  Claudinei Soares³ Data ³14/09/2015³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descricao ³Busca informacoes dos funcionarios conforme os parametros   ³
³          ³informados na geracao.          								  ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEM044                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³.T.     															  ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³ aInfoSRA = Array com o resultado da Query  				  ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

Static Function fGp044Info(aInfoSRA)
Local aArea			:= GetArea()
Local aInfoFIL		:= {}
Local nPosTab		:= 0
Local nFil			:= 0
Local cFilQry 		:= ""
Local cItem			:= " - "
Local cCatQuery 	:= ""
Local cSitQuery 	:= ""
Local cWhere		:= ""
Local cWhereFil		:= ""
Local cFilDe    	:= If(Empty(MV_PAR01)," "	, MV_PAR01)	//Filial De
Local cFilAte   	:= If(Empty(MV_PAR02)," "	, MV_PAR02)	//Filial Ate
Local cCCDe     	:= If(Empty(MV_PAR03)," "	, MV_PAR03)	//Centro de Custo De
Local cCCAte    	:= If(Empty(MV_PAR04)," "	, MV_PAR04)	//Centro de Custo Ate
Local cMatDe    	:= If(Empty(MV_PAR05)," "	, MV_PAR05)	//Matricula De
Local cMatAte   	:= If(Empty(MV_PAR06)," "	, MV_PAR06)	//Matricula Ate
Local cDeptoDe  	:= If(Empty(MV_PAR07)," "	, MV_PAR07)	//Departamento De
Local cDeptoAte  	:= If(Empty(MV_PAR08)," "	, MV_PAR08)	//Departamento Ate
Local cCategoria 	:= MV_PAR09 							//Categoria
Local cSituacao  	:= MV_PAR10 							//Situacao
Local cSindic   	:= ""									//Sindicato (conforme cadastrado na tabela S061)
Local lFilVazia		:= .F.
Local cFilS061		:= ""
Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), {.T., .F.}) //[2]Ofuscamento
Local aFldRel		:= If(aOfusca[2], FwProtectedDataUtil():UsrNoAccessFieldsInList({"RA_NOME"}), {})
Local lOfusca		:= Len(aFldRel) > 0

SX3->(dbSetOrder(2)) //Indice por campo

//Busca informacoes dos funcionarios
cAliasFIL := "QFIL"

//Verifica se alias esta em uso
If (Select(cAliasFIL) > 0)
	(cAliasFIL)->(dbCloseArea())
EndIf

cWhereFil += 'SRA.RA_FILIAL BETWEEN' + " '"+cFilDe +"'" + " AND "+ "'"+cFilAte + "'"
cWhereFil := "% " + cWhereFil + " %"

BeginSql alias cAliasFIL
	SELECT DISTINCT
	RA_FILIAL
	FROM %table:SRA% SRA
	WHERE %exp:cWhereFil%
	ORDER BY SRA.RA_FILIAL
EndSql

dbSelectArea(cAliasFIL)


//Posicionamento do primeiro registro e Loop Principal
While (cAliasFIL)->(!Eof())
	//Condicoes para DBF, nao serao necessarias em TOP pois estao aplicadas na query

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Posiciona na tabela SRA - Fisica                    	 	   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	dbSelectArea("SRA")
	dbSetOrder(RetOrder("SRA", "RA_FILIAL+RA_MAT"))
	dbSeek((cAliasFIL)->(RA_FILIAL),.F.)

	aAdd( aInfoFIL, {(cAliasFIL)->RA_FILIAL} )
	(cAliasFIL)->(dbSkip())

EndDo

//Fecha alias que esta em uso
If (Select(cAliasFIL) > 0)
	(cAliasFIL)->(dbCloseArea())
EndIf

dbSelectArea("SRA")
dbGotop()

For nFil := 1 To Len(aInfoFil)
	//TRATAMENTO PARA O SINDICATO DA TABELA S061
	lContinua := .T.
	If ( nPosTab := fPosTab("S061", MV_PAR11, "==", 4, aInfoFil[nFil,1], "==" ,1,,,,,aInfoFil[nFil,1] ) ) > 0
		If Empty(fTabela("S061",nPosTab, 5,,aInfoFil[nFil,1]))
			lSindVazio := .T. //Sindicato Vazio
		Else
			cSindic := fTabela("S061",nPosTab, 5,,aInfoFil[nFil,1])
		Endif
  	ElseIf ( nPosTab := fPosTab("S061", MV_PAR11, "==", 4, Space(LEN(MV_PAR01)),"==" ,1,,,,,Space(LEN(MV_PAR01)) ) ) > 0
		If Empty(fTabela("S061",nPosTab, 5))
			lSindVazio := .T. //Sindicato Vazio
		Else
			cSindic := fTabela("S061",nPosTab, 5)
		Endif
	Else
		lContinua := .F.
	Endif

	//TRATAMENTO PARA A FILIAL DA TABELA S061
	If lContinua
		If ( nPosTab := fPosTab("S061", MV_PAR11, "==", 4, aInfoFil[nFil,1], "==" ,1,,,,,aInfoFil[nFil,1] ) ) > 0
			If Empty(fTabela("S061",nPosTab, 1,,aInfoFil[nFil,1]))
				lFilVazia := .T. //Filial Vazia
			Else
				cFilS061 := fTabela("S061",nPosTab, 1,,aInfoFil[nFil,1])
			Endif
	  	ElseIf ( nPosTab := fPosTab("S061", MV_PAR11, "==", 4, Space(LEN(MV_PAR01)),"==" ,1,,,,,Space(LEN(MV_PAR01)) ) ) > 0
			lFilVazia := .T. //Filial Vazia
		Else
			lContinua := .F.
		Endif
	Endif

	If lContinua
		//Busca informacoes dos funcionarios
		cAliasSRA := "QSRA"

		//Verifica se alias esta em uso
		If (Select(cAliasSRA) > 0)
			(cAliasSRA)->(dbCloseArea())
		EndIf

		//Tratamento categorias
		cCatQuery := ""
		If Empty(cCategoria)
			cCatQuery := "'" + "*" + "'"
		Else
			cCatQuery := Upper("" + fSqlIN(cCategoria, 1) + "")
		EndIf

		//Tratamento situacoes
		cSiqQuery := ""
		If Empty(cSituacao)
			cSitQuery := "'" + " " + "'"
		Else
			cSitQuery := Upper("" + fSqlIN(cSituacao, 1) + "")
		EndIf

		cWhere := ""
		If lFilVazia
			cWhere += " SRA.RA_FILIAL =" + "'" +aInfoFil[nFil,1]+ "'""
		Else
			cWhere += " SRA.RA_FILIAL =" + "'" +cFilS061+ "'""
		Endif

		cWhere += " AND SRA.RA_CC BETWEEN " + "'"+cCCDe +"'" + " AND "+ "'"+cCCAte + "'""
   		If !Empty(cSindic)
   			cWhere += " AND SRA.RA_SINDICA 	=" + "'" +cSindic + "'""
   		Endif
   		cWhere += " AND SRA.RA_MAT BETWEEN " + "'"+cMatDe +"'" + " AND "+ "'"+cMatAte + "'""
   		cWhere += " AND SRA.RA_DEPTO BETWEEN " + "'"+cDeptoDe +"'" + " AND "+ "'"+cDeptoAte + "'""
  		cWhere += " AND SRA.RA_CATFUNC IN ("+ cCatQuery + ") "
		cWhere += " AND SRA.RA_SITFOLH IN ("+ cSitQuery + ") "
		cWhere += " AND SRA.D_E_L_E_T_ = ' ' "
   		cWhere := "% " + cWhere + " %"

		BeginSql alias cAliasSRA
			SELECT
			RA_FILIAL, RA_MAT, RA_NOME, RA_SINDICA
			FROM %table:SRA% SRA
			WHERE %exp:cWhere%
   			ORDER BY SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_NOME
		EndSql

		dbSelectArea(cAliasSRA)

		ProcRegua((cAliasSRA)->(RecCount()))

		//Posicionamento do primeiro registro e Loop Principal
		While (cAliasSRA)->(!Eof())
			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Posiciona na tabela SRA - Fisica                    	 	   ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			dbSelectArea("SRA")
			dbSetOrder(RetOrder("SRA", "RA_FILIAL+RA_MAT"))
			dbSeek((cAliasSRA)->(RA_FILIAL+RA_MAT),.F.)
			cSraFilter	:= GpFltAlsGet( aRetFiltro , "SRA" )
			If !Empty( cSraFilter )
				If !( &( cSraFilter ) )
					(cAliasSRA)->(dbSkip())
					Loop
				EndIf
			EndIf

			//IncProc para melhor performance
			IncProc(OemToAnsi(STR0008) + "  " + (cAliasSRA)->RA_FILIAL + " - " + (cAliasSRA)->RA_MAT + If(lOfusca, "", " - " + (cAliasSRA)->RA_NOME) )//"Gerando o registro de:"
			If (fTabela("S061", nPosTab, 10 ) <> Nil) .And. (fTabela("S061", nPosTab, 11 ) <> Nil) .And. (fTabela("S061", nPosTab, 12 ) <> Nil)
				aAdd( aInfoSRA, {(cAliasSRA)->RA_FILIAL,(cAliasSRA)->RA_MAT, If(lOfusca, Replicate("*",15), (cAliasSRA)->RA_NOME ), fTabela("S061", nPosTab,6), fTabela("S061", nPosTab,7),fTabela("S061", nPosTab,5), fTabela("S061", nPosTab,4), fTabela("S061", nPosTab, 10 ),fTabela("S061", nPosTab, 11 ),fTabela("S061", nPosTab, 12 )  } )
			else
				aAdd( aInfoSRA, {(cAliasSRA)->RA_FILIAL,(cAliasSRA)->RA_MAT, If(lOfusca, Replicate("*",15), (cAliasSRA)->RA_NOME ), fTabela("S061", nPosTab,6), fTabela("S061", nPosTab,7),fTabela("S061", nPosTab,5), fTabela("S061", nPosTab,4)  } )
			Endif	
			(cAliasSRA)->(dbSkip())
		EndDo

		//Fecha alias que esta em uso
		If (Select(cAliasSRA) > 0)
			(cAliasSRA)->(dbCloseArea())
		EndIf
	Endif
Next nFil

RestArea(aArea)

Return .T.
