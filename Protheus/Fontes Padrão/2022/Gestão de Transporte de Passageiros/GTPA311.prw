#include "GTPA311.CH"
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE "PONCALEN.CH"

Static aGA311Log	:= {} 
Static aGA311Calend	:= {}

/*/{Protheus.doc} GTPA311
Programa de Exportação dos horários dos colaboradores, a partir das suas viagens e plantões, para as 
marcações do ponto eletrônico.
@type function
@author jacomo.fernandes
@since 18/02/2019
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GTPA311()
Local nOpc		:= 0
Local oTable	:= nil

aGA311Log := {}

If ( Pergunte("GTPA311",.t.) ) .and. GA311VldData(MV_PAR01, MV_PAR02)
	
	nOpc	:= If(MV_PAR05 == 1,3,5) // 1 = Inclusão, 2 = Exclusão

	MsgRun(STR0002,STR0001,{|| oTable := GA311InitData() })//"Filtrando dados..."//"Iniciando Rotina"
	
	If ( oTable:GetAlias() )->(!Eof())
		MsgRun(STR0004,STR0003,{|| GA311UpdPon(nOpc,oTable) })	//"Atualizando..."//"Marcações do Ponto"
	Else
		Help(,,"Help", STR0005, STR0006 , 1,0  ) //Help(, , "", "", "Não há dados.", , STR0006)		//"Não há Dados"//"Verifique os parâmetros utilizados."
	Endif
	
	GA311Destroy(oTable)		
Endif

Return()

/*/{Protheus.doc} GA311VldData
Validações das datas digitadas nos parâmetros do Pergunte do programa comparando-as com a do Periodo de Apontamento
@type function
@author jacomo.fernandes
@since 18/02/2019
@version 1.0
@param dDataIni, data, (Descrição do parâmetro)
@param dDataFim, data, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GA311VldData(dDataIni, dDataFim)

Local lRet		:= .t.

Local dDtIniApo	:= stod("")
Local dDtFimApo	:= stod("")

If ( PerAponta(@dDtIniApo, @dDtFimApo) )
	If (Empty(dDataIni) .or. Empty(dDataFim)) 
		lRet := .F. 	
		Help(" ",1,"Periodo não informado",,"Data inicial ou final do periodo não informado" ,1,0)
	ElseIf dDataIni > dDataFim
		lRet := .f.
		Help(" ",1,STR0018,,STR0019 ,1,0)//"A Data Inicial é maior que a data Final."//"Período Incorreto"
		
	ElseIf ( dDataIni < dDtIniApo )
		lRet := .f.
		Help(" ",1,STR0018,,STR0017 + dtoc(dDtIniApo) + ")" ,1,0)//"O Período Informado, está fora do período de Apontamento. Data Inicial é menor que data Inicial do Perído ("//"Período Incorreto"
	ElseIf (dDataFim > dDtFimApo)
		lRet := .f.
		Help(" ",1,STR0018,,STR0020 + dtoc(dDtFimApo) + ")" ,1,0)//"O Período Informado, está fora do período de Apontamento. Data Final é maior que data Final do Perído ("//"Período Incorreto"
	Endif
Endif

Return(lRet)

/*/{Protheus.doc} GA311InitData
Função responsavel pela query da apuração das horas dos colaboradores
@type function
@author jacomo.fernandes
@since 18/02/2019
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GA311InitData()
Local cTmpAlias	:= GetNextAlias()
Local oTable	:= NIL

Local dPerIni	:= MV_PAR01 
Local dPerFim	:= MV_PAR02 
Local cColabDe	:= MV_PAR03
Local cColabAte	:= MV_PAR04
Local nTipo		:= MV_PAR05
Local cSetor    := MV_PAR06

Local cFiltro	:= ""
Local cFiltro2	:= ""

Local cSelectGqe    := ""
Local cSelectGqk    := ""
Local lValGqk       := .F.

If GQK->(FieldPos("GQK_INTERV")) > 0
	cSelectGqe := "%GQE_INTERV  AS GQK_INTERV	,%"
	cSelectGqk := "%GQK_INTERV ,%"
	lValGqk := .T.
EndIf

If ( nTipo == 1 )	//Inclusão de apontamento
	cFiltro 	:= "% AND GQE_MARCAD in ('','2')%"
	cFiltro2	:= "% AND GQK_MARCAD in ('','2')%"
Else				//Exclusão do apontamento
	cFiltro 	:= "% AND GQE_MARCAD = '1' %"
	cFiltro2 	:= "% AND GQK_MARCAD = '1' %"
Endif


BeginSql Alias cTmpAlias
	COLUMN GQK_DTREF AS DATE
	COLUMN GQK_DTINI AS DATE
	COLUMN GQK_DTFIM AS DATE
	COLUMN SRARECNO	 AS NUMERIC(16,0)
	COLUMN RECNO	 AS NUMERIC(16,0)

	SELECT 
		SRA.RA_FILIAL,
		SRA.RA_MAT,
		SRA.RA_TNOTRAB,
		SRA.R_E_C_N_O_ AS SRARECNO,
		GYT.GYT_CODIGO,
		GYG.GYG_CODIGO,
		GQE_CONF 	AS GQK_CONF   ,
		'1'         AS GQK_TPDIA  ,
		GQE_DTREF   AS GQK_DTREF  ,
		G55_DTPART  AS GQK_DTINI  ,
		G55_DTCHEG  AS GQK_DTFIM  ,
		GQE_HRINTR  AS GQE_HRINTR ,
		GQE_HRFNTR  AS GQE_HRFNTR ,
		%Exp:cSelectGqe%
		GQE_MARCAD	AS GQK_MARCAD ,
		IsNull(GYK_VALCNH,'2') AS GZS_VOLANT,
		'1'         AS GZS_HRPGTO,
		'GQE'	    AS TABELA,
		GQE.R_E_C_N_O_  AS RECNO
	FROM %Table:GYG% GYG
		INNER JOIN %Table:GYT% GYT ON
			GYT.GYT_FILIAL = %xFilial:GYT%
			AND GYT.GYT_CODIGO = %Exp:cSetor%
			AND GYT.%NotDel%
		INNER JOIN %Table:GY2% GY2 ON
			GY2.GY2_FILIAL = %xFilial:GY2%
			AND GY2.GY2_SETOR = GYT.GYT_CODIGO
			AND GY2.GY2_CODCOL = GYG.GYG_CODIGO
			AND GY2.%NotDel%
		INNER JOIN %Table:SRA% SRA ON
			SRA.RA_FILIAL = GYG.GYG_FILSRA
			AND SRA.RA_MAT = GYG.GYG_FUNCIO
			AND SRA.%NotDel%
		INNER JOIN %Table:GYN% GYN ON
			GYN.GYN_FILIAL = %xFilial:GYN%
			AND GYN.GYN_FINAL = '1'  
			AND GYN.GYN_TIPO <> '2'  
			AND GYN.%NotDel% 
		INNER JOIN %Table:G55% G55 ON
			G55.G55_FILIAL = GYN.GYN_FILIAL
			AND G55.G55_CODVIA = GYN.GYN_CODIGO
			AND G55.%NotDel% 
		INNER JOIN %Table:GQE% GQE ON
			GQE.GQE_FILIAL = GYN.GYN_FILIAL
			AND GQE.GQE_VIACOD = GYN.GYN_CODIGO
			AND GQE.GQE_SEQ = G55.G55_SEQ
			AND GQE.%NotDel% 
			AND GQE.GQE_RECURS = GYG.GYG_CODIGO
			AND GQE_CANCEL = '1'  
			AND GQE_TRECUR = '1'  
			AND GQE_STATUS = '1'  
			AND GQE_TERC IN (' ','2')
			AND GQE.GQE_DTREF BETWEEN %Exp:dPerIni% and %Exp:dPerFim%
			AND GQE.GQE_CONF = '1'
			%Exp:cFiltro%
		LEFT JOIN %Table:GYK% GYK ON
			GYK_FILIAL = %xFilial:GYK%
			AND GYK.GYK_CODIGO = GQE.GQE_TCOLAB
			AND GYK.%NotDel% 
	WHERE
		GYG.GYG_FILIAL = %xFilial:GYG%
		AND GYG.GYG_CODIGO BETWEEN %Exp:cColabDe% and %Exp:cColabAte%
		AND GYG_FUNCIO <> ''
		AND GYG.%NotDel% 

	UNION

	SELECT 
		SRA.RA_FILIAL,
		SRA.RA_MAT,
		SRA.RA_TNOTRAB,
		SRA.R_E_C_N_O_ AS SRARECNO,
		GYT.GYT_CODIGO,
		GYG.GYG_CODIGO,
		GQK_CONF   ,
		GQK_TPDIA  ,
		GQK_DTREF  ,
		GQK_DTINI  ,
		GQK_DTFIM  ,
		GQK_HRINI AS GQE_HRINTR ,
		GQK_HRFIM  AS GQE_HRFNTR ,
		%Exp:cSelectGqk%
		GQK_MARCAD ,
		(Case
			when GZS.GZS_CODIGO IS NOT NULL AND GZS_VOLANT <> '' THEN GZS_VOLANT
			WHEN GQK.GQK_TPDIA = '1' AND IsNull(GYK_VALCNH,'2') = '1' THEN '1'
			ELSE '2'
		End) as GZS_VOLANT,
		IsNull(GZS_HRPGTO,'1') AS GZS_HRPGTO,
		'GQK'		   AS TABELA      ,
		GQK.R_E_C_N_O_  AS RECNO 
	FROM %Table:GYG% GYG
		INNER JOIN %Table:GYT% GYT ON
			GYT.GYT_FILIAL = %xFilial:GYT%
			AND GYT.GYT_CODIGO = %Exp:cSetor%
			AND GYT.%NotDel%
		INNER JOIN %Table:GY2% GY2 ON
			GY2.GY2_FILIAL = %xFilial:GY2%
			AND GY2.GY2_SETOR = GYT.GYT_CODIGO
			AND GY2.GY2_CODCOL = GYG.GYG_CODIGO
			AND GY2.%NotDel%
		INNER JOIN %Table:SRA% SRA ON
			SRA.RA_FILIAL = GYG.GYG_FILSRA
			AND SRA.RA_MAT = GYG.GYG_FUNCIO
			AND SRA.%NotDel%
		INNER JOIN %Table:GQK% GQK ON
			GQK.GQK_FILIAL = %xFilial:GQK%
			AND GQK.GQK_DTREF BETWEEN %Exp:dPerIni% and %Exp:dPerFim%
			AND GQK.GQK_RECURS = GYG.GYG_CODIGO
			AND GQK.GQK_STATUS = '1' 
			AND GQK.%NotDel% 
			AND GQK_TERC IN (' ','2')
			AND GQK.GQK_CONF = '1'
			AND GQK_TPDIA IN('1','2','6')
			%Exp:cFiltro2%
		LEFT JOIN %Table:GYK% GYK ON
			GYK_FILIAL = %xFilial:GYK%
			AND GYK.GYK_CODIGO = GQK_TCOLAB
			AND GYK.%NotDel% 
		LEFT JOIN %Table:GZS% GZS ON
			GZS.GZS_FILIAL = %xFilial:GZS%
			AND GZS.GZS_CODIGO = GQK.GQK_CODGZS
			AND GZS.%NotDel% 
	WHERE
		GYG.GYG_FILIAL = %xFilial:GYG%
		AND GYG.GYG_CODIGO BETWEEN %Exp:cColabDe% and %Exp:cColabAte%
		AND GYG_FUNCIO <> ''
		AND GYG.%NotDel% 
	
	order by GQK_DTREF,GQK_DTINI,GQE_HRINTR

EndSql

oTable  := GtpxTmpTbl(cTmpAlias,{{"IDX",{"GQK_DTREF","GQK_DTINI","GQE_HRINTR"}}})
	
Return oTable 

/*/{Protheus.doc} GA311UpdPon
Função responsavel pela atualização do Ponto do funcionário
@type function
@author jacomo.fernandes
@since 18/02/2019
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GA311UpdPon(nOpc,oTable)
Local lRet			:= .T.
Local cTmpMatric	:= GetMatriculas(oTable)
Local oCalc			:= Nil
Local oCalcDia		:= Nil
Local aTpMarc		:= {"1E","1S","2E","2S"}
Local lFirst		:= .T.
Local cSetor		:= ""
Local cColab		:= ""

Local n1			:= 0
Local n2			:= 0
Local aCabec		:= {}
Local cTurno		:= ""

Local cPerAponta	:= ""
Local dApontaDe		:= dDataBase
Local dApontaAte	:= dDataBase

Local cFilOld		:= cFilAnt
Local cMatric		:= ""

Local aLinha		:= {}
Local aItens		:= {}

Local aExcecoes		:= {}
Local aSp2			:= {}
Local aRecnos		:= {}
Local cMotivo		:= ""	
Local cTpTraba		:= ""

Local lTP311Pon	:= ExistBlock("TP311PON")

DbSelectArea('SRA')

While (cTmpMatric)->(!Eof())
	SRA->(DBGOTO((cTmpMatric)->SRARECNO))


	cFilAnt := (cTmpMatric)->RA_FILIAL
	cMatric	:= (cTmpMatric)->RA_MAT
	cTurno	:= (cTmpMatric)->RA_TNOTRAB
	cSetor	:= (cTmpMatric)->GYT_CODIGO
	cColab	:= (cTmpMatric)->GYG_CODIGO

	aCabec	:= {}
	aLinha	:= {}
	aItens	:= {}
	aExcecoes:= {}
	aRecnos	:= {}
	PerAponta(@dApontaDe, @dApontaAte)
	
	cPerAponta := DToS(dApontaDe) + DToS(dApontaAte)

	oCalc := GetApontamentos(oTable,cFilAnt,cMatric,cSetor,cColab,aRecnos)
	
	AAdd(aCabec,{"RA_FILIAL", xFilial('SRA')})
	AAdd(aCabec,{"RA_MAT" 	, cMatric})

	For n1 := 1 To Len(oCalc:aDias)
		oCalcDia	:= oCalc:aDias[n1]

		//Cria Marcações
		If oCalcDia:cTpDia <= '2'
			
			For n2 := 1 To Len(aTpMarc) 

				If oCalcDia:ExistMarcacao(aTpMarc[n2])
					aLinha := {}		
					// 1ª Marcação de Entrada
					AAdd(aLinha,{"P8_FILIAL"	,XFilial("SP8")})
					AAdd(aLinha,{"P8_MAT"		,cMatric})
					AAdd(aLinha,{"P8_DATA"		,oCalcDia:GetValorMarcacao(aTpMarc[n2],'Data') })
					AAdd(aLinha,{"P8_HORA"		,Val(StrTran(oCalcDia:GetValorMarcacao(aTpMarc[n2],'cHora'),":",'.')) })
					AAdd(aLinha,{"P8_ORDEM"		,""}) 
					AAdd(aLinha,{"P8_TPMARCA"	,aTpMarc[n2]})
					AAdd(aLinha,{"P8_TURNO"		,cTurno})
					AAdd(aLinha,{"P8_PAPONTA"	,cPerAponta}) 
					AAdd(aLinha,{"P8_DATAAPO"	,oCalcDia:dDtRef})
					AAdd(aLinha,{"P8_MOTIVRG"	,"EXPORTAÇÃO HRS MÓD. GTP"})

					AAdd(aItens,aLinha)
				Endif

			Next
		//Cria Exceções
		Else

			aSP2 := {}
			
			cMotivo		:= "D.S.R " + DTOC(oCalcDia:dDtRef) 
			cTpTraba	:= "D"
		
			aAdd(aSP2, {"P2_FILIAL"		, xFilial("SP2"), Nil } )
			aAdd(aSP2, {"P2_MOTIVO"		, cMotivo, Nil} )
			aAdd(aSP2, {"P2_DATA"		, oCalcDia:dDtRef, Nil} )
			aAdd(aSP2, {"P2_DATAATE"	, oCalcDia:dDtRef, Nil} )
			aAdd(aSP2, {"P2_MAT"		, cMatric, Nil} )
			aAdd(aSP2, {"P2_TURNO"		, Space(TamSx3("P2_TURNO")[1]), Nil } )
			aAdd(aSP2, {"P2_CC"			, Space(TamSx3("P2_CC")[1]), Nil} )
			aAdd(aSP2, {"P2_TIPODIA"	, Space(TamSx3("P2_TIPODIA")[1]), Nil})	
			aAdd(aSP2, {"P2_TRABA"		, cTpTraba, Nil } )
			aAdd(aSP2, {"P2_HERDHOR"	, "N", Nil } )
			aAdd(aSP2, {"P2_CODHEXT"	, "2", Nil } )
			aAdd(aSP2, {"P2_CODHNOT"	, "6", Nil } )
			aAdd(aSP2, {"P2_MINHNOT"	, Posicione("SR6",1,xFilial("SR6")+cTurno,"R6_MINHNOT"), Nil } )//PEGAR PARA TODOS DE R6_MINHNOT
			aAdd(aSP2, {"P2_HORMENO"	, 5, Nil} )
			aAdd(aSP2, {"P2_HORMAIS"	, 5, Nil} )
			
			aAdd(aExcecoes,aSP2)
		Endif
	Next

	//-----Finaliza as separações do colaborador
	//-----Inicia a gravação do Ponto do Colaborador
	
	Begin Transaction 
		lRet := GravaPonto(nOpc,aCabec,aItens,aExcecoes,@lFirst)
		
		lRet := lRet .and. GravaAlocacoes(nOpc,aRecnos)	
		
		If !lRet
			DisarmTransaction()
		Endif
	
	End Transaction
		
	
	If lTP311Pon .and. Len(aItens) > 0
		ExecBlock("TP311PON", .f., .f., {nOpc,aClone(aCabec),aClone(aItens),aClone(aExcecoes)})
	Endif
	
	oCalc:Destroy()
	(cTmpMatric)->(DbSkip())
End

(cTmpMatric)->(DbCloseArea())

//Se houver Log para apresentar
If ( Len(aGA311Log) > 0 )
	
	oModel := FWLoadModel("GTPA311A")
	oModel:SetOperation(MODEL_OPERATION_VIEW)
	
	oModel:Activate()
	
	FWExecView(STR0016,"GTPA311A",MODEL_OPERATION_VIEW,,{|| .T.},,,,,,,oModel)//"Log de Erro"
		
Endif


cFilAnt := cFilOld

Return

/*/{Protheus.doc} GetMatriculas
Função responsavel pela busca das Matriculas encontradas na query
@type function
@author jacomo.fernandes
@since 18/02/2019
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GetMatriculas(oTable)
Local cTmpAlias	 := GetNextAlias()
Local cTableName := '%'+oTable:GetRealName()+'%'

Beginsql Alias cTmpAlias 
	COLUMN SRARECNO	 AS NUMERIC(16,0)
	
	Select 
		RA_FILIAL ,
		RA_MAT    ,
		RA_TNOTRAB,
		SRARECNO  ,
		GYT_CODIGO,
		GYG_CODIGO
	From 
		%Exp:cTableName% TB_MATRICULA
	Group By 
		RA_FILIAL ,
		RA_MAT    ,
		RA_TNOTRAB,
		SRARECNO  ,
		GYT_CODIGO,
		GYG_CODIGO
EndSql

Return cTmpAlias


/*/{Protheus.doc} GetApontamentos(oTable,cFilAnt,cMatric,cTurno,aRecnos)
(long_description)
@type  Function
@author user
@since 06/09/2019
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function GetApontamentos(oTable,cFilAnt,cMatric,cSetor,cColab,aRecnos)
Local oCalc			:= GTPxCalcHrPeriodo():New(cSetor,cColab)
Local cTmpAlias		:= GetNextAlias()
Local cTableName	:= '%'+oTable:GetRealName()+'%'
Local cSelect       := ""
Local lValGqk       := .F.
Local aArea         := GetArea()

If GQK->(FieldPos("GQK_INTERV")) > 0
	cSelect := "%GQK_INTERV	,%"
	lValGqk := .T.
EndIf

Beginsql Alias cTmpAlias 
	COLUMN GQK_DTREF AS DATE
	COLUMN GQK_DTINI AS DATE
	COLUMN GQK_DTFIM AS DATE
	COLUMN RECNO	 AS NUMERIC(16,0)

	Select 
		GQK_DTREF 	,
		GQK_TPDIA 	,
		GQK_DTINI 	,
		GQK_DTFIM 	,
		GQE_HRINTR	,
		GQE_HRFNTR	,
		%Exp:cSelect%
		GZS_VOLANT	,
		GZS_HRPGTO	,
		TABELA		,
		RECNO
	From %Exp:cTableName% TB_DADOS
	Where
		RA_FILIAL = %Exp:cFilAnt%
		AND RA_MAT = %Exp:cMatric%
		AND GYG_CODIGO = %Exp:cColab%
		AND GYT_CODIGO = %Exp:cSetor%

EndSql

While (cTmpAlias)->(!Eof())
	If lValGqk		
		oCalc:AddTrechos((cTmpAlias)->GQK_DTREF		,;
						(cTmpAlias)->GQK_TPDIA		,;
						(cTmpAlias)->GQK_DTINI		,;
						(cTmpAlias)->GQE_HRINTR		,;
						/*cCodOri*/	,;
						/*cDesOri*/	,;
						(cTmpAlias)->GQK_DTFIM		,;
						(cTmpAlias)->GQE_HRFNTR			,;
						/*cCodDes*/	,;
						/*cDesDes*/	,;
						(cTmpAlias)->GZS_VOLANT == "1"		,;
						(cTmpAlias)->GZS_HRPGTO == "1" .AND. (cTmpAlias)->GQK_INTERV <> "1"	,;
						.T.		)
	Else
		oCalc:AddTrechos((cTmpAlias)->GQK_DTREF		,;
						(cTmpAlias)->GQK_TPDIA		,;
						(cTmpAlias)->GQK_DTINI		,;
						(cTmpAlias)->GQE_HRINTR		,;
						/*cCodOri*/	,;
						/*cDesOri*/	,;
						(cTmpAlias)->GQK_DTFIM		,;
						(cTmpAlias)->GQE_HRFNTR			,;
						/*cCodDes*/	,;
						/*cDesDes*/	,;
						(cTmpAlias)->GZS_VOLANT == "1"		,;
						(cTmpAlias)->GZS_HRPGTO == "1" 	,;
						.T.		)
	EndIf
	aAdd(aRecnos,{(cTmpAlias)->TABELA,(cTmpAlias)->RECNO})
	(cTmpAlias)->(DbSkip())
End

(cTmpAlias)->(DbCloseArea())

oCalc:Calcula()

RestArea(aArea)
Return oCalc

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} GA311UpdSP8

Função que retorna a variável estática aGA311Log que é um array que contem os dados de log de erro

@Return
	aGA311Log: 

@sample aGA311Log := GA311GetError()
@author Fernando Radu Muscalu

@since 08/01/2015
@version 1.0
*/
//------------------------------------------------------------------------------------------------------
Static Function GA311UpdSP8(aItensAuto)

Local aSeek			:= {}
Local aResult		:= {{"P8_DATA","P8_MAT","P8_TURNO","P8_PAPONTA","P8_DATAAPO","P8_HORA"}}



Local nI			:= 0
Local nPFilial		:= Iif(Len(aItensAuto) > 0 , aScan(aItensAuto[1],{|x| x[1] == "P8_FILIAL" }), 0)
Local nPMatric		:= Iif(Len(aItensAuto) > 0 , aScan(aItensAuto[1],{|x| x[1] == "P8_MAT" }), 0)
Local nPTurno		:= Iif(Len(aItensAuto) > 0 , aScan(aItensAuto[1],{|x| x[1] == "P8_TURNO" }), 0)
Local nPTpMarca		:= Iif(Len(aItensAuto) > 0 , aScan(aItensAuto[1],{|x| x[1] == "P8_TPMARCA" }), 0)
Local nPPerAponta	:= Iif(Len(aItensAuto) > 0 , aScan(aItensAuto[1],{|x| x[1] == "P8_PAPONTA" }), 0)
Local nPData		:= Iif(Len(aItensAuto) > 0 , aScan(aItensAuto[1],{|x| x[1] == "P8_DATA" }), 0)
Local nPDataApo		:= Iif(Len(aItensAuto) > 0 , aScan(aItensAuto[1],{|x| x[1] == "P8_DATAAPO" }), 0)
Local nPHora		:= Iif(Len(aItensAuto) > 0 , aScan(aItensAuto[1],{|x| x[1] == "P8_HORA" }), 0)

For nI := 1 To Len(aItensAuto)
	aSeek	:= {}
	aAdd(aSeek,{"P8_FILIAL"	,aItensAuto[nI][nPFilial,2]})
	aAdd(aSeek,{"P8_MAT"	,aItensAuto[nI][nPMatric,2]})
	aAdd(aSeek,{"P8_DATA"	,aItensAuto[nI][nPData,2]})
	aAdd(aSeek,{"P8_HORA"	,aItensAuto[nI][nPHora,2]})
	
	If GTPSeekTable("SP8",aSeek,aResult) .and. Len(aResult) > 1
	
		SP8->(DbGoTo(aResult[2,Len(aResult[2])]))
		
		RecLock("SP8",.F.)
		
			SP8->P8_TPMARCA 	:= aItensAuto[nI][nPTpMarca,2] //cTpMarca
			SP8->P8_TURNO		:= aItensAuto[nI][nPTurno,2]
			SP8->P8_PAPONTA		:= aItensAuto[nI][nPPerAponta,2]
			SP8->P8_DATA		:= aItensAuto[nI][nPData,2]
			SP8->P8_DATAAPO		:= aItensAuto[nI][nPDataApo,2]
			SP8->P8_ORDEM		:= GA311SetOrdem(aItensAuto[nI][nPDataApo,2])
		
		SP8->(MsUnlock())
	Endif
Next


Return()

//------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA311GetError
Função que retorna a variável estática aGA311Log que é um array que contem os dados de log de erro
@type function
@author jacomo.fernandes
@since 20/02/2019
@version 1.0
@return aGA311Log, Array. Retorna vetor de Log de Erros
		aGA311Log[n,1]: Caractere. Cód do Funcionário
		aGA311Log[n,2]: Caractere. Nome do Funcionário
		aGA311Log[n,3]: Data. Data da Marcação
		aGA311Log[n,4]: Caractere. 1ª Marcação (1ª Entrada) 
		aGA311Log[n,5]: Caractere. 2ª Marcação (1ª Saída)
		aGA311Log[n,6]: Caractere. 3ª Marcação (2ª Entrada)
		aGA311Log[n,7]: Caractere. 4ª Marcação (2ª Saída)
		aGA311Log[n,7]: Caractere. Mensagem de erro.
@example
(examples)
@see (links_or_references)
/*/
Function GA311GetError()
Return(aGA311Log)

/*/{Protheus.doc} GTPSetCalendPonto
(long_description)
@type function
@author jacomo.fernandes
@since 18/02/2019
@version 1.0
@param aCalendario, array, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GTPSetCalendPonto(aCalendario)

aGA311Calend := aClone(aCalendario)

Return(Len(aGA311Calend) > 0)

/*/{Protheus.doc} GTPGetCalendPonto
(long_description)
@type function
@author jacomo.fernandes
@since 18/02/2019
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GTPGetCalendPonto()

Return(aGA311Calend)

/*/{Protheus.doc} GA311SetOrdem
(long_description)
@type function
@author jacomo.fernandes
@since 18/02/2019
@version 1.0
@param dDataPonto, data, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GA311SetOrdem(dDataPonto)

Local nI		:= 0

Local cRetOrdem	:= ""

Local aCalend	:= GTPGetCalendPonto()

Default dDataPonto	:= SP8->P8_DATAAPO

nI := aScan(aCalend,{|x| x[CALEND_POS_DATA] == dDataPonto })

If ( nI > 0 )
	cRetOrdem := aCalend[nI,CALEND_POS_ORDEM]
EndIf

Return(cRetOrdem)


/*/{Protheus.doc} GA311Destroy
(long_description)
@type function
@author jacomo.fernandes
@since 18/02/2019
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GA311Destroy(oTable)

If ( Valtype(oTable) == "O")
	oTable:Delete()
	Freeobj(oTable)
EndIf

Return()

/*/{Protheus.doc} GravaPonto
(long_description)
@type function
@author jacomo.fernandes
@since 20/02/2019
@version 1.0
@param nOpc, numérico, (Descrição do parâmetro)
@param aCabec, array, (Descrição do parâmetro)
@param aItens, array, (Descrição do parâmetro)
@param aExcecoes, array, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GravaPonto(nOpc,aCabec,aItens,aExcecoes,lFirst)
Local lRet	:= .T.
Local n1	:= 0  
Local nX	:= 0

Private lMsErroAuto	:= .f.
Private lGeolocal 			:= SP8->(ColumnPos("P8_LATITU")) > 0 .And. SP8->(ColumnPos("P8_LONGIT")) > 0

//Efetua as marcações
aRetInc := Ponm010(	.F.,;				//01 -> Se o "Start" foi via WorkFlow
					.F.,;				//02 -> Considera as configuracoes dos parametros do usuário
					.F.,;				//03 -> Se deve limitar a Data Final de Apontamento a Data Base
					xFilial("SP8"),;	//04 -> Filial a Ser Processada
					.F.,;				//05 -> Processo por Filial
					.F.,;				//06 -> Apontar quando nao Leu as Marcacoes para a Filial
					.F.,;				//07 -> Se deve Forcar o Reapontamento
					aCabec,;
					aItens,;
					nOpc)


If ( ValType(aRetInc) <> "U" .And. Len(aRetInc) > 0 )

	lRet 	:=  aRetInc[1]
	lArray 	:= .t.
	
	If !lRet .and. nOpc == 5 .and. (!lFirst .or. FwAlertYesNo("Não foi possivel encontrar as marcações no Ponto, deseja desmarcar mesmo assim?") )
		lRet := .T.
		lFirst	:= .F.
	EndIf
	
	If ( lRet .and. nOpc <> 5)
		GA311UpdSP8(aItens)				
	EndIf
	
Else
	lArray	:= .f.	
Endif	

//Se deu erro na marcacao, gera log do funcionário, para apresentar em tela
//ao final do processamento
If ( !lRet ) 
	
	cMsg := ""
	
	If ( lArray )
	
		For nX := 1 to Len(aRetInc[2])
			cMsg += aRetInc[2,nX] + CRLF
		Next nX
	Else
		cMsg := STR0007 //"Não foi possível gerar marcações de apontamento."
	Endif
	
	aAdd(aGA311Log, {	aCabec[1][2],;	//Cód do Funcionário
						aCabec[2][2],;	//Nome do Funcionário
						Stod(''),;	//Data da Marcação
						'',;	//1ª Marcação (1ª Entrada)
						'',;		//2ª Marcação (1ª Saída)
						'',;		//3ª Marcação (2ª Entrada)
						'',;	//4ª Marcação (2ª Saída)
						cMsg})			//Observação do Erro ocorrido

	
Endif

If lRet
	For n1	:= 1 To Len(aExcecoes)
		If nOpc <> 3 .OR. (nOpc == 3 .AND. ValidExcecao(aExcecoes[n1])) 
			MsExecAuto({|x,y| PONA090(x,y)}, aExcecoes[n1], nOpc)
			If lMsErroAuto
				If nOpc == 5 .and.(!lFirst .or. FwAlertYesNo("Não foi possivel encontrar as exceções no Ponto, deseja desmarcar mesmo assim?"))
					lRet := .T.
					lFirst := .F.
				Else
					SetErroExcecao(aExcecoes[n1])
					lRet := .F.
					Exit
				EndIf
			Endif
		Endif
	
	Next
Endif

Return lRet


/*/{Protheus.doc} GravaAlocacoes
Função responsavel pela gravação das alocações
@type function
@author jacomo.fernandes
@since 20/02/2019
@version 1.0
@param nOpc, numérico, (Descrição do parâmetro)
@param aAlocacoes, array, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GravaAlocacoes(nOpc,aAlocacoes)
Local lRet	:= .T.
Local n1	:= 0

DbSelectArea("GQE")
DbSelectArea("GQK")

For n1:= 1 to Len(aAlocacoes)
	
	(aAlocacoes[n1][1])->(DbGoTo(aAlocacoes[n1][2]))
	
	Reclock(aAlocacoes[n1][1],.F.)
		(aAlocacoes[n1][1])->&(aAlocacoes[n1][1]+"_MARCAD") := If(nOpc == 3,'1','2')
	(aAlocacoes[n1][1])->(MsUnlock())
	
	
Next

Return lRet

/*/{Protheus.doc} ValidExcecao
a rotina PONA290 não trata uma exceção que já fora previamente gerada para a mesma data e matrícula
a checagem será feita a seguir
@type function
@author jacomo.fernandes
@since 20/02/2019
@version 1.0
@param aSP2, array, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function ValidExcecao(aSP2)
Local lRet	:= .T.
Local cMsg	:= ""
Local aSeek	:= {}
Local cHrIni:= "00:00"
Local cHrFim:= "23:59"
Local cNome	:= ""

aAdd(aSeek,{"P2_FILIAL"	,aSP2[1,2]}) 
aAdd(aSeek,{"P2_MAT"	,aSP2[5,2]}) 
aAdd(aSeek,{"P2_CC"		,aSP2[7,2]}) 
aAdd(aSeek,{"P2_TURNO"	,aSP2[6,2]}) 
aAdd(aSeek,{"P2_DATA"	,aSP2[3,2]}) 
aAdd(aSeek,{"P2_TIPODIA",aSP2[8,2]})

If GTPSeekTable("SP2",aSeek)  
								
	lRet := .F.								
	
	
	cMsg := "Já existe marcação de exceção para o período, conforme demonstra os seguintes dados: " + CRLF//"Erro ao tentar gerar a marcação de Exceção. "
	cMsg += STR0010 + Alltrim(cHrIni) + CRLF//" * Hora Entrada: "
	cMsg += STR0011 + Alltrim(cHrFim) + CRLF//" * Hora Saída: "
	cMsg += STR0012 + dtoc(aSP2[3,2]) + CRLF//" * Data: "
	
	cNome	:= Posicione('SRA',1,xFilial('SRA')+aSP2[5,2],'RA_NOME')
	
	aAdd(aGA311Log, {	aSP2[5,2],;	//Cód do Funcionário
						cNome,;	//Nome do Funcionário
						aSP2[3,2]	,;	//Data da Marcação
						cHrIni,;	//1ª Marcação (1ª Entrada)
						cHrFim,;		//2ª Marcação (1ª Saída)
						'',;		//3ª Marcação (2ª Entrada)
						'',;	//4ª Marcação (2ª Saída)
						cMsg})			//Observação do Erro ocorrido
	
Endif

Return lRet


/*/{Protheus.doc} 
(long_description)
@type function
@author jacomo.fernandes
@since 20/02/2019
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function SetErroExcecao(aSP2)
Local cHrIni:= "00:00"
Local cHrFim:= "23:59"
Local cNome	:= ""
Local cMsg	:= ""
//Se deu erro na marcacao de excecao, gera log do funcionário, para apresentar em tela
//ao final do processamento

cMsg := STR0008 + CRLF//"Erro ao tentar gerar a marcação de Exceção. "
cMsg += STR0009 + CRLF//"A marcação que seria gerada, teria as seguintes informações: "
cMsg += STR0010 + Alltrim(cHrIni) + CRLF//" * Hora Entrada: "
cMsg += STR0011 + Alltrim(cHrFim) + CRLF//" * Hora Saída: "
cMsg += STR0012 + dtoc(aSP2[3,2]) + CRLF//" * Data: "
cMsg += CRLF

MostraErro(GetSrvProfString("Startpath", ""), "LOG_PONA090.LOG")

If ( File("LOG_PONA090.LOG") )
	
	FT_FUse("LOG_PONA090.LOG")
	
	While ( !FT_FEof() )
		cMsg += Alltrim(FT_FReadLn()) + CRLF
		FT_FSkip()
	EndDo
	
	FT_FUse() //Fechar
	
	fErase("LOG_PONA090.LOG")
	
	cNome	:= Posicione('SRA',1,xFilial('SRA')+aSP2[5,2],'RA_NOME')
	
	aAdd(aGA311Log, {	aSP2[5,2],;	//Cód do Funcionário
						cNome,;	//Nome do Funcionário
						aSP2[3,2]	,;	//Data da Marcação
						cHrIni,;	//1ª Marcação (1ª Entrada)
						cHrFim,;		//2ª Marcação (1ª Saída)
						'',;		//3ª Marcação (2ª Entrada)
						'',;	//4ª Marcação (2ª Saída)
						cMsg})			//Observação do Erro ocorrido
		
Endif

Return