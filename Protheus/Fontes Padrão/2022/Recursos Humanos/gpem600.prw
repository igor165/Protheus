#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEM600.CH"

Static lAutomato := IsBlind()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GPEM600  ³ Autor ³ Ademar Fernandes          ³ Data ³ 13/10/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera os Dados HomologNet (RGW/RGX/RGZ/RGY) para serem enviados ³±±
±±³          ³ ao Ministerio do Trabalho afim de calcular a Rescisao Contrato.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS/FNC    ³  Motivo da Alteracao                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia Carv³03/02/14³REQ 001975_01³Unificacao Folha de Pagamento-Homolog- ³±±
±±³            ³        ³             ³net                                    ³±±
±±³Cecilia Carv³26/05/14³REQ 001975_01³Correção para que não seja gerado movi-³±±
±±³            ³        ³             ³mentacao de rescisao somente quando ha ³±±
±±³            ³        ³             ³registros em SR8.                      ³±±
±±³Cecilia Carv³29/05/14³REQ 001975_01³Correção para que não ocorra error.log ³±±
±±³            ³        ³             ³quando há rescisao para o mes seguinte.³±±
±±³M. Silveira ³31/07/14³       TQBOKP³Inclusao da funcao fGpm600VCod() para  ³±±
±±³            ³        ³             ³validar o Codigo da tabela S027.       ³±±
±±³M. Silveira ³07/07/15³       TSOMA5³Ajuste na validacao dos meses do sindi-³±±
±±³            ³        ³      	      ³cato para nao gerar valores zerados.   ³±±
±±³Allyson M.  ³02/12/15³       TTRFU4³Ajuste na geracao dos dados da SRR para³±±
±±³            ³        ³      	   	  ³validar os dados gerados da SRD. 	  ³±±
±±³M. Silveira ³27/01/16³       TUHCMG³Ajuste para tratar o ID48 para gerar a ³±±
±±³            ³        ³             ³quantidade de horas para categoria H/D.³±±
±±³Esther V.   ³08/06/16³       TVFY37³Incluida validacao de acesso do usuario³±±
±±³Victor A.   ³18/07/16³       TVPZEP³Efetuado réplica utilizando o conceito ³±±
±±³            ³        ³             ³da V12.                                ³±±
±±³Marcos Cout.³28/11/16³       132179³Correção para que não haja error.log   ³±±
±±³            ³        ³             ³na geração do Homolognet.              ³±±
±±³Gabriel A.  ³03/02/17³MRH-5920     ³Ajuste para não gerar error.log quando ³±±
±±³            ³        ³             ³há salário rateado por centro de custo.³±±
±±³WinstonCosta³03/01/19³             ³Retirada do trecho que trata o AS/400  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GPEM600()

Local oDlg
Local nOpca 	   	:=	0
Local aSays 	   	:=	{}
Local aButtons		:= 	{} //<== arrays locais de preferencia
Local aFilterExp 	:=	{} //Expressao de filtro

Local cPerg := "GPM600"

Private aRetFiltro
Private cSraFilter
Private cSrgFilter

Private lAbortPrint := .F.
Private cCadastro 	:= OemtoAnsi(STR0001)		//"Gera‡„o dos Arquivos de Dados HomologNet"
Private aCodFol		:= {}

Pergunte(cPerg,.F.)

// Retorne os Filtros que contenham os Alias Abaixo
aAdd( aFilterExp , { "FILTRO_ALS" , "SRA"     	, .T. , ".or." } )
aAdd( aFilterExp , { "FILTRO_ALS" , "SRG"     	, NIL , NIL    } )
// Que Estejam Definidos para a Função
aAdd( aFilterExp , { "FILTRO_PRG" , FunName() 	, NIL , NIL    } )

AADD(aSays,OemtoAnsi(STR0002) )	//"Este programa gera os Arquivos de Dados HomologNet para serem"
AADD(aSays,OemtoAnsi(STR0003) )	//"enviados posteriormente ao Ministerio do Trabalho."

AADD(aButtons, { 17,.T.,{|| aRetFiltro := FilterBuildExpr( aFilterExp ) }} )	//ROBO=NIL
AADD(aButtons, {  5,.T.,{|| Pergunte(cPerg,.T.) }} )							//ROBO=.T.
AADD(aButtons, {  1,.T.,{|o| nOpca := 1,FechaBatch() }} )
AADD(aButtons, {  2,.T.,{|o| FechaBatch() }} )

If !lAutomato
	FormBatch( cCadastro, aSays, aButtons )
Else
	nOpca := 1
Endif

If nOpca == 1
	If !lAutomato
		ProcGpe({|lEnd| GPM600Processa()},,,.T.)	// Chamada do Processamento
	Else
		GPM600Processa()
	Endif
EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPM600Processa³ Autor ³ Ademar Fernandes ³ Data ³ 13/10/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de processamento                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPM600Processa()                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEM600                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Modalidade de Aviso Previo : "1"-Trabalhado "2"-Indenizado "3" - Ausencia/Dispensa   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function GPM600Processa()

Local aArea		:= GetArea()
Local nX	    := 0
Local nTReg		:= 0
Local cQuery	:= ""

Local cAlias    := "QSRG"
Local cNewCateg := ""

//--Paramentros Selecionados
Private cFilDe		:= mv_par01
Private cFilAte		:= mv_par02
Private cCcDe		:= mv_par03					//	Centro de Custo De
Private cCcAte		:= mv_par04					//	Centro de Custo Ate
Private cMatDe		:= mv_par05					//	Matricula De
Private cMatAte		:= mv_par06					//  Matricula Ate
Private dDemisDe    := mv_par07					// 	Data de Demissao De
Private dDemisAte	:= mv_par08					// 	Data de Demissao Ate
Private dHomolDe	:= mv_par09					//	Data de homologacao De
Private dHomolAte	:= mv_par10					//	Data de homologacao Ate
Private cCategoria	:= mv_par11					//	Categorias a serem geradas

//--Arquivos utilizados
dbSelectArea("SR8")
dbSetOrder(1)	//-R8_FILIAL+R8_MAT+DTOS(R8_DATAINI)+R8_TIPO
dbSelectArea("SRA")
dbSetOrder(1)	//-RA_FILIAL+RA_MAT
dbSelectArea("SRD")
dbSetOrder(1)	//-RD_FILIAL+RD_MAT+RD_DATARQ+RD_PD+RD_SEMANA+RD_SEQ+RD_CC
dbSelectArea("SRF")
dbSetOrder(1)	//-RF_FILIAL+RF_MAT+DTOS(RF_DATABAS)+RF_PD
dbSelectArea("SRG")
dbSetOrder(1)	//-RG_FILIAL+RG_MAT+DTOS(RG_DTGERAR)
dbSelectArea("SRH")
dbSetOrder(1)	//-RH_FILIAL+RH_MAT+DTOS(RH_DATABAS)+DTOS(RH_DATAINI)
dbSelectArea("SRR")
dbSetOrder(1)	//-RR_FILIAL+RR_MAT+RR_TIPO3+DTOS(RR_DATA)+RR_PD+RR_CC
dbSelectArea("SRV")
dbSetOrder(1)	//-RV_FILIAL+RV_COD
dbSelectArea("RGW")
dbSetOrder(1)	//-RGW_FILIAL+RGW_MAT+RGW_TPRESC+DTOS(RGW_HOMOL)+RGW_TPREG+DTOS(RGW_DTINI)
dbSelectArea("RGX")
dbSetOrder(1)	//-RGX_FILIAL+RGX_MAT+RGX_TPRESC+DTOS(RGX_HOMOL)+RGX_MESANO+RGX_TPREG+RGX_CODRUB
dbSelectArea("RGZ")
dbSetOrder(1)	//-RGZ_FILIAL+RGZ_MAT+RGZ_TPRESC+DTOS(RGZ_HOMOL)+RGZ_MOTIVO+DTOS(RGZ_DTMVTO)
dbSelectArea("RGY")
dbSetOrder(1)	//-RGY_FILIAL+RGY_MAT+RGY_TPRESC+DTOS(RGY_HOMOL)+RGY_CODIGO
dbSelectArea("RCE")
dbSetOrder(1)	//-RCE_FILIAL+RCE_CODIGO

dbSelectArea("SRG")
dbSetOrder(retorder("SRG","RG_FILIAL+RG_MAT+DTOS(RG_DATADEM)+DTOS(RG_DATAHOM)+RG_EFETIVA"))

//Separa as categorias pra usar no Bco.Dados
If !Empty(cCategoria)
	cNewCateg := "'"
	For nX:=1 to Len(Alltrim(cCategoria))
		cNewCateg += Substr(cCategoria,nX,1) + "','"
	Next nX
	cNewCateg := Substr(cNewCateg,1,Len(cNewCateg)-2)
Else
	cNewCateg := "' '"
EndIf

//Retorna somente funcionarios com 1 registo no SRG (Sem rescisao complementar)
cQuery := "SELECT RA_FILIAL,RA_MAT,RA_NOME,RA_CC,RA_CIC,RA_ADMISSA,RA_CC,RA_CATFUNC,RA_SALARIO,RA_COMPSAB, RA_SINDICA, SRG1.* "
cQuery += "  FROM "	+ RetSqlName("SRG") + " SRG1 "
cQuery += " INNER JOIN " 	+ RetSqlName("SRA") + " SRA "
cQuery += "    ON RA_FILIAL||RA_MAT=RG_FILIAL||RG_MAT "
cQuery += " INNER JOIN "
cQuery += " ( "
cQuery += "		SELECT SRG3.RG_FILIAL, SRG3.RG_MAT, MIN(SRG3.RG_DTGERAR) PRIMEIRA "
cQuery += " 	  FROM "+ RetSqlName("SRG") + " SRG3 "
cQuery += " 	 WHERE SRG3.D_E_L_E_T_ = ' ' "
cQuery += "		   AND SRG3.RG_FILIAL BETWEEN '"	+ cFilDe + "' AND '" + cFilAte + "' "
cQuery += "		   AND SRG3.RG_MAT BETWEEN '"	+ cMatDe + "' AND '" + cMatAte + "' "
cQuery += "		   AND ( SRG3.RG_EFETIVA='S' OR SRG3.RG_EFETIVA='' )  "
cQuery += "		 GROUP BY SRG3.RG_FILIAL, SRG3.RG_MAT "
cQuery += "  ) "
cQuery += " SRG2 "
cQuery += " ON  "
cQuery += "		SRG1.RG_FILIAL||SRG1.RG_MAT  = SRG2.RG_FILIAL||SRG2.RG_MAT "
cQuery += "		AND SRG1.RG_DTGERAR = SRG2.PRIMEIRA "
cQuery += "	WHERE "
cQuery += " SRG1.RG_FILIAL BETWEEN '"+cFilDe+"' AND '"+cFilAte+"' "
cQuery += "	  AND SRG1.RG_MAT BETWEEN '"+cMatDe+"' AND '"+cMatAte+"' "
cQuery += "	  AND ( SRG1.RG_EFETIVA='S' OR SRG1.RG_EFETIVA='' )  "
cQuery += "	  AND SRG1.RG_DATADEM BETWEEN '"	+DTOS(dDemisDe)	+"' AND '"+DTOS(dDemisAte)+"' "
cQuery += "	  AND SRG1.RG_DATAHOM BETWEEN '"	+DTOS(dHomolDe)	+"' AND '"+DTOS(dHomolAte)+"' "
cQuery += "	  AND SRA.RA_CC BETWEEN '"+cCcDe+"' AND '"+cCcAte+"' "
cQuery += "	  AND SRA.RA_CATFUNC IN ("+cNewCateg+") "
cQuery += "	  AND SRA.D_E_L_E_T_ = ' ' "
cQuery += "   AND SRG1.D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY SRG1.RG_FILIAL,SRG1.RG_MAT,SRG1.RG_DATAHOM "

cQuery := ChangeQuery(cQuery)

If Select(cAlias) > 0
	(cAlias)->(dbCloseArea())
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias)

Count To nTReg	//# Conta os registros retornados
aEval( SRA->(dbStruct()),{|x| IIF(x[2] != "C",TcSetField(cAlias,x[1],x[2],x[3],x[4]),Nil)} )	//# Corrige a forma das Datas e Numeros
aEval( SRG->(dbStruct()),{|x| IIF(x[2] != "C",TcSetField(cAlias,x[1],x[2],x[3],x[4]),Nil)} )	//# Corrige a forma das Datas e Numeros

dbSelectArea(cAlias)
(cAlias)->(dbGoTop())

//--Funcao de Processamento Selecionado pelos Parametros
fProc1(.T.,cAlias,nTReg)

If Select(cAlias) > 0
	(cAlias)->(dbCloseArea())
Endif

RestArea(aArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fProc1      ³ Autor ³ Ademar Fernandes ³ Data ³ 13/10/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de processamento                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEM600                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
N*/
Static Function fProc1(lTop,cAlias,nTReg)

Local lOk			:= .T.
Local cAuxChv		:= ""
Local cFilAnterior	:= Replicate("!", FWGETTAMFILIAL)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis de Acesso do Usuario                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cAcessaSRA	:= &( " { || " + IF( Empty( cAcessaSRA := ChkRH( "GPEM600" , "SRA" , "2" ) ) , ".T." , cAcessaSRA ) + " } " )
Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F. }) //[2]Ofuscamento
Local aFldRel		:= If(aOfusca[2], FwProtectedDataUtil():UsrNoAccessFieldsInList( {"RA_NOME","RA_CIC"} ), {})
Local lOfuscaCpf	:= .F.

Private lOfuscaNom	:= .F.
Private aGrvDupl	:= {}

If Len(aFldRel) > 0
	lOfuscaNom := aScan( aFldRel, { |x| x:CFIELD == "RA_NOME" } ) > 0
	lOfuscaCpf := aScan( aFldRel, { |x| x:CFIELD == "RA_CIC" } ) > 0
EndIf

If !lAutomato
	GPProcRegua(nTReg)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega os Filtros                                 	 	      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSraFilter	:= GpFltAlsGet( aRetFiltro , "SRA" ) // == ""
cSrgFilter	:= GpFltAlsGet( aRetFiltro , "SRG" ) // == ""

While (cAlias)->( !Eof() )

	If !( (cAlias)->RA_FILIAL $ fValidFil() ) .Or. !Eval( cAcessaSRA )
		(cAlias)->(dbSkip())
		Loop
	EndIf

	If !lAutomato
		GPIncProc((cAlias)->RA_FILIAL + " - " + (cAlias)->RA_MAT + If(lOfuscaNom, "", " - " + (cAlias)->RA_NOME) )
	Endif

 	If !Empty( cSraFilter )
 		If !( &( cSraFilter ) )
			(cAlias)->( dbSkip() )
			Loop
 		EndIf
 	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o funcionario tem + de 1 ano                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (cAlias)->( (RG_DATAHOM - RA_ADMISSA) + RG_DAVISO) < 365
		(cAlias)->( dbSkip() )
		Loop
	EndIf
	cAuxChv := (cAlias)->RG_MAT + "1" + DTOS((cAlias)->RG_DATAHOM)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existem Funcionarios ja importados               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("RGW")	//-RGW_FILIAL+RGW_MAT+RGW_TPRESC+RGW_HOMOL
	If dbSeek(xFilial("RGW",(cAlias)->RA_FILIAL)+cAuxChv,.F.)
		//-Monta array pra ListBox
		aAdd(aGrvDupl, { .T. 									,;	//-01
						xFilial("RGW",(cAlias)->RA_FILIAL)		,;	//-02
						(cAlias)->RG_MAT						,;	//-03
						(cAlias)->RA_CC							,;	//-04
			If(lOfuscaNom, Replicate('*',15), (cAlias)->RA_NOME),;	//-05
			If(lOfuscaCpf, Replicate('*',11), (cAlias)->RA_CIC ),;	//-06
						"1"										,;	//-07
						(cAlias)->RG_DATAHOM					,;	//-08
						" " })
	EndIf

	dbSelectArea(cAlias)
	(cAlias)->( dbSkip() )

EndDo

If Len(aGrvDupl) > 0
	lOk := fMostraDupl(aGrvDupl)
Endif

If !FP_CODFOL(@aCodFol,xFilial("SRA"))
	Help(,,'HELP',,OemToAnsi("Nao foi possivel carregar os Identificadores de Calculo!" ),1,0)
	Return( .F. )
Endif

If lOk
	fProcTOP(cAlias,nTReg)
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fMostraDuplºAutor ³ Ademar Fernandes   º Data ³ 25/10/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Usado na funcao principal                                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ HomologNet                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fMostraDupl(aLbxA)

Local aSvArea	:= GetArea()
Local aSX3Area	:= SX3->( GetArea() )
Local lOK		:= .F.
Local nPosLbxA	:= 0.00
Local oDlg		:= NIL
Local oLbxA		:= NIL
Local aHeaderA	:= {}
Local cMarca	:= GetMark()
Local nX

Private cDtInicial := ""	//-Data inicial dos processamentos
Private oOk := 	LoadBitmap( GetResources(), "LBOK")
Private oNo := 	LoadBitmap( GetResources(), "LBNO")

DEFAULT aLbxA	:= {}

//-Monta o Header com base nas descricoes do SX3
//-fDesc( cAlias , cChave , cCampoRet , nBytes , cFil , nOrder , lPosSx3 )
dbSelectArea("SX3")
dbSetOrder(2)
aAdd(aHeaderA, {"",;											      //-01
				fDesc("SX3","RA_FILIAL","X3_TITULO",MAX(FWGETTAMFILIAL,6),,,.F.),;	//-02
				fDesc("SX3","RA_MAT","X3_TITULO",,,,.F.),;		//-03
				fDesc("SX3","RA_CC","X3_TITULO",,,,.F.),;		   //-04
				fDesc("SX3","RA_NOME","X3_TITULO",,,,.F.),;		//-05
				fDesc("SX3","RA_CIC","X3_TITULO",,,,.F.),;		//-06
				fDesc("SX3","RGW_TPRESC","X3_TITULO",8,,,.F.),;	//-07
				fDesc("SX3","RG_DATAHOM","X3_TITULO",,,,.F.),;	//-08
				"." ;											      //-09
				})
RestArea(aSX3Area)

	If !lAutomato

		DEFINE MSDIALOG oDlg FROM 050,005 TO 558,961 TITLE OemtoAnsi(STR0004) PIXEL Style 128	//-"HomologNet - Geração de Dados"
		//-Style 128 -> Desabilita o X Superior Direito da Tecl
		oDlg:lMaximized := .T.
		oDlg:lEscClose := .F.

		@ 001,015 SAY OemtoAnsi(STR0005)	SIZE 240,10 OF oDlg PIXEL 	//"Funcionários que ja foram importados para os arquivos do HomologNet !!"
		@ 010,015 SAY OemtoAnsi(STR0006)	SIZE 240,10 OF oDlg PIXEL 	//"Selecione abaixo quais funcionários devem ser regravados/reimportados."

		@ 018,007 LISTBOX oLbxA FIELDS HEADER	aHeaderA[1,1],aHeaderA[1,2],aHeaderA[1,3],aHeaderA[1,4], ;
												aHeaderA[1,5],aHeaderA[1,6],aHeaderA[1,7],aHeaderA[1,8],aHeaderA[1,9] ;
												SIZE 465,213 OF oDlg PIXEL
		oLbxA:SetArray(aLbxA)
		oLbxA:bLDblClick := { || (aLbxA[oLbxA:nAt,01] := !aLbxA[oLbxA:nAt,01]) }
		oLbxA:bLine := {|| {Iif(aLbxA[oLbxA:nAt,1],oOk,oNo),aLbxA[oLbxA:nAt,2],aLbxA[oLbxA:nAt,3],aLbxA[oLbxA:nAt,4],;
								aLbxA[oLbxA:nAt,5],aLbxA[oLbxA:nAt,6],aLbxA[oLbxA:nAt,7],aLbxA[oLbxA:nAt,8],aLbxA[oLbxA:nAt,9] }}

		DEFINE SBUTTON FROM 240,366 TYPE 1 ENABLE OF oDlg ACTION ( lOk := .T., nPosLbxA:=oLbxA:nAt,oDlg:End() )
		DEFINE SBUTTON FROM 240,394 TYPE 2 ENABLE OF oDlg ACTION ( lOk := .F., oDlg:End() )

		ACTIVATE MSDIALOG oDlg CENTERED ON INIT .T.	//VldPosArq( oLbxA , aLbxA , cNomeAlias )
	Else
		lOk 	 := .T.
		nPosLbxA := 1
	Endif
	//--Activate MsDialog oDlg On Init fChoicBar(oDlg,bOk,bCancel,,aButtons) CENTERED

	/*
	01		//aAdd(aGrvDupl, { .T. ,;
	02						xFilial("RGW"),;
	03						(cAlias)->RG_MAT,;
	04						(cAlias)->RA_CC,;
	05						(cAlias)->RA_NOME,;
	06						(cAlias)->RA_CIC,;
	07						"1",;
	08						(cAlias)->RG_DATAHOM
							})
	*/

	If ( lOk )
		Begin Transaction
			For nX := 1 to Len(aLbxA)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Deleta os registros dos funcionarios marcados                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If aLbxA[nX,01]	//.T.
					//-Deleta o registro do RGW
					dbSelectArea("RGW")	//-RGW_FILIAL+RGW_MAT+RGW_TPRESC+DTOS(RGW_HOMOL)+RGW_TPREG+DTOS(RGW_DTINI)
					cAuxChv := aLbxA[nX,02]+aLbxA[nX,03]+aLbxA[nX,07]+DTOS(aLbxA[nX,08])

					If dbSeek(cAuxChv,.F.)
						While !Eof() .And. RGW->(RGW_FILIAL+RGW_MAT+RGW_TPRESC+DTOS(RGW_HOMOL)) == cAuxChv
							RecLock("RGW",.F.)
							dbDelete()
							MsUnlock("RGW")

							dbSkip()
						EndDo
					EndIf

					//-Deleta o registro do RGX
					dbSelectArea("RGX")	//-RGX_FILIAL+RGX_MAT+RGX_TPRESC+DTOS(RGX_HOMOL)+RGX_MESANO+RGX_TPREG+RGX_CODRUB
					cAuxChv := aLbxA[nX,02]+aLbxA[nX,03]+aLbxA[nX,07]+DTOS(aLbxA[nX,08])

					If dbSeek(cAuxChv,.F.)
						While !Eof() .And. RGX->(RGX_FILIAL+RGX_MAT+RGX_TPRESC+DTOS(RGX_HOMOL)) == cAuxChv
							RecLock("RGX",.F.)
							dbDelete()
							MsUnlock("RGX")

							dbSkip()
						EndDo
					EndIf

					//-Deleta o registro do RGZ
					dbSelectArea("RGZ")	//-RGZ_FILIAL+RGZ_MAT+RGZ_TPRESC+DTOS(RGZ_HOMOL)+RGZ_MOTIVO+DTOS(RGZ_DTMVTO)
					cAuxChv := aLbxA[nX,02]+aLbxA[nX,03]+aLbxA[nX,07]+DTOS(aLbxA[nX,08])

					If dbSeek(cAuxChv,.F.)
						While !Eof() .And. RGZ->(RGZ_FILIAL+RGZ_MAT+RGZ_TPRESC+DTOS(RGZ_HOMOL)) == cAuxChv
							RecLock("RGZ",.F.)
							dbDelete()
							MsUnlock("RGZ")

							dbSkip()
						EndDo
					EndIf

					//-Deleta o registro do RGY
					dbSelectArea("RGY")	//-RGY_FILIAL+RGY_MAT+RGY_TPRESC+DTOS(RGY_HOMOL)+RGY_CODIGO
					cAuxChv := aLbxA[nX,02]+aLbxA[nX,03]+aLbxA[nX,07]+DTOS(aLbxA[nX,08])

					If dbSeek(cAuxChv,.F.)
						While !Eof() .And. RGY->(RGY_FILIAL+RGY_MAT+RGY_TPRESC+DTOS(RGY_HOMOL)) == cAuxChv
							RecLock("RGY",.F.)
							dbDelete()
							MsUnlock("RGY")

							dbSkip()
						EndDo
					EndIf

				EndIf
			Next nX
		End Transaction
	EndIf

RestArea(aSvArea)
Return( lOk )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fProc1TOP     ³ Autor ³ Ademar Fernandes ³ Data ³ 13/10/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de processamento                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEM600                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fProcTOP(cAlias,nTReg)

Local nX
Local nPos
Local aDadosIni	   	:= {}
Local aFerias	   	:= {}
Local a13Sal	   	:= {}
Local aFinanc	   	:= {}
Local aMovto	   	:= {}
Local aDescto	   	:= {}
Local aTransf	   	:= {}
Local aCompSRD		:= {}
Local cFilAnterior	:= Replicate("!", FWGETTAMFILIAL)
Local cMesAnoAnt	:= "!!!!!!"

Local nVrb13Sal := 0
Local nFalt01   := 0
Local nFalt02   := 0
Local nFalt03   := 0
Local nFalt04   := 0
Local nFalt05   := 0
Local nFalt06   := 0
Local nFalt07   := 0
Local nFalt08   := 0
Local nFalt09   := 0
Local nFalt10   := 0
Local nFalt11   := 0
Local nFalt12   := 0
Local nFaltaP   := 0
Local nPerc		:= 0 //--> Percentual da rúbrica.
Local nTmpPerc	:= 0 //--> Conteúdo temporário do percentual da rúbrica.

Local cTmpMatr	 := "" //--> Guarda a matrícula no laço para comparações
Local cTmpSind	 := "" //--> Guarda o sindicato no laço para comparações
Local cQuery     := ""
Local nTRegSRD   := 0
Local cAliasSR8  := "QRYSR8"
Local cAliasSRD  := "QRYSRD"
Local cAliasSRR  := "QRYSRR"
Local lSomaPerc  := .T.

// Variaveis de tratamento para Salario Liquido Mes Anterior a Rescisao
Local aTab25	:= {}
Local nAchou	:= 0
Local cVrbFixa	:= ""
Local nVlSalLiq := 0
Local cAnoProc	:= ""
Local cMesProc	:= ""
Local cQryWhere	:= ""
Local cPerIni	:= ""
Local cPerFim	:= ""
Local cHomolog	:= ""
Local cCodFol	:= ""

Local aAreaSRG  := SRG->(getarea())
Local aTransf	:= {}
Local aTabS043 	:= {}
Local aTabS032 	:= {}
Local cTipo1	:= ""
Local cCodR		:= ""
Local cFgtsMAnt	:= aCodFol[117,1] // Codigo de fgts Mes anterior
Local cAMesProx := ""
Local dDtDemis  := Ctod("  /  /    ")
Local cIniMov   := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis de Acesso do Usuario                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cAcessaSRA := &( " { || " + IF( Empty( cAcessaSRA := ChkRH( "GPEM600" , "SRA" , "2" ) ) , ".T." , cAcessaSRA ) + " } " )

dbSelectArea(cAlias)
(cAlias)->(dbGoTop())

If !lAutomato
	GPProcRegua(nTReg)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega os Filtros                                 	 	     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSraFilter	:= GpFltAlsGet( aRetFiltro , "SRA" )
cSrgFilter	:= GpFltAlsGet( aRetFiltro , "SRG" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verificacoes Primarias                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//-Calcular as medias sobre meses de direito (S/N) ?
cCalcMed := "S"
cFmCalcM := "1"
cPerMed  := " "
nMesMed  := 0
nComiMed := 0

If Upper(Alltrim(GetMV("MV_MEDDIRE"))) # "S"
	cCalcMed := "N"
EndIf

While (cAlias)->( !Eof() )
	If !Eval( cAcessaSRA ) .Or. !( (cAlias)->RA_FILIAL $ fValidFil() )
		(cAlias)->( dbSkip() )
		Loop
	EndIf

	If !lAutomato
		GPIncProc((cAlias)->RA_FILIAL + " - " + (cAlias)->RA_MAT + If( lOfuscaNom, "", " - " + (cAlias)->RA_NOME) )
	Endif

 	If !Empty( cSraFilter )
 		If !( &( cSraFilter ) )
			(cAlias)->( dbSkip() )
			Loop
 		EndIf
 	EndIf

	If !Empty( cSrgFilter )
		If !( &( cSrgFilter ) )
			(cAlias)->( dbSkip() )
			Loop
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o funcionario tem + de 1 ano                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (cAlias)->( (RG_DATAHOM - RA_ADMISSA) + RG_DAVISO) < 365
		(cAlias)->( dbSkip() )
		Loop
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona o Cadastro de Funcionarios                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SRA")
	dbSeek((cAlias)->RA_FILIAL+(cAlias)->RG_MAT,.F.)
	dbSelectArea(cAlias)

	If (cAlias)->RA_FILIAL # cFilAnterior
		cFilAnterior:= (cAlias)->RA_FILIAL
		If !FP_CODFOL(@aCodFol, cFilAnterior)
			Exit
		Endif
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica forma de calculo de medias                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cFmCalcM := "1"
	cPerMed  := " "
	nMesMed  := 0
	nComiMed := 0

	If !Empty((cAlias)->RA_SINDICA)
		dbSelectArea("RCE")	//-//-RCE_FILIAL+RCE_CODIGO
		If dbSeek(xFilial("RCE",(cAlias)->RA_FILIAL)+(cAlias)->RA_SINDICA,.F.)

			If cCalcMed # "S"
				If RCE_MED01 > 0
					cFmCalcM := "2"

					If RCE_MED01 = 12
						cPerMed  := "2"
					Else
						cPerMed  := "1"
					EndIf

					nMesMed  := RCE_MED01
					nComiMed := GetMV("MV_COMISSA")

					If nComiMed == 0
						nComiMed := nMesMed
					Endif

				EndIf
			EndIf
		EndIf
		dbSelectArea(cAlias)
	EndIf

	aTransf	    := {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ 1.	Manipulacao e Gravacao de Dados Iniciais                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    //
	//				StrZero(nMesMed,Len(RGW->RGW_QTDE13)),;	//-13
	//				StrZero(nComiMed,Len(RGW->RGW_MA13)),;	//-14
	//				cFmCalcM,;								//-15
	//				cPerMed,;								//-16
	//				StrZero(nMesMed,Len(RGW->RGW_QTDFER)),;	//-17
	//				StrZero(nComiMed,Len(RGW->RGW_MAFER)),;	//-18
	//				cFmCalcM,;								//-19
	//				StrZero(nMesMed,Len(RGW->RGW_QTDEAV)),;	//-20
	//				StrZero(nComiMed,Len(RGW->RGW_MAAV)),;	//-21
	//				StrZero(nDiasAv,Len(RCE->RCE_DIASAV)) ;	//-22
	aDadosIni := {}
	aAdd(aDadosIni, { .T. ,;								//-01
					xFilial("RGW",(cAlias)->RA_FILIAL),;	//-02
					(cAlias)->RG_MAT,;						//-03
					(cAlias)->RA_CC,;						//-04
					(cAlias)->RA_NOME,;						//-05
					(cAlias)->RA_CIC,;						//-06
					"1",;									//-07
					(cAlias)->RG_DATAHOM,;					//-08
					(cAlias)->RG_JTCUMPR,;					//-09
					(cAlias)->RA_COMPSAB,;					//-10
					cFmCalcM,;								//-11
					cPerMed,;								//-12
					nMesMed,;								//-13
					nComiMed,;								//-14
					cFmCalcM,;								//-15
					cPerMed,;								//-16
					nMesMed,;								//-17
					nComiMed,;								//-18
					cFmCalcM,;								//-19
					nMesMed,;								//-20
					nComiMed,;								//-21
					(cAlias)->RG_DAVISO,;					//-22
					(cAlias)->RA_CATFUNC,;					//-23
					(cAlias)->RA_SALARIO ;					//-24
					})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ 2.	Manipulacao e Gravacao de Dados de Ferias                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//-- Monta array com os Periodos Aquisitivos
	aFerias := {}
	aFerias := MontaPerAq(.T.,cAlias)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ 3.	Manipulacao e Gravacao de Dados de 13o.Salario             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Select("QRYSRD") > 0
		QRYSRD->(dbCloseArea())
	Endif
	a13Sal  := {}
	cVrb13Sal := aCodFol[Val("024"),1]	//-aCodFol[Val("022"),1]+"/"+aCodFol[Val("024"),1]+"/"+aCodFol[Val("028"),1]+"/"+aCodFol[Val("163"),1]	//108
	cVrbFalta := aCodFol[Val("054"),1]+"/"+aCodFol[Val("203"),1]+"/"+aCodFol[Val("242"),1]														//910-441-445

	//fBuscaAcmPer(cVerbas		,;	// Lista de Verbas a acumular
	//             cStrSrv		,;	// Condicao do cadastro de verbas para somatorio dos valores ou horas
	//             cRetVH		,;	// Tipo do Retorno (em (H) horas ou em (V) valores)
	//             nValor		,;	// Retorno da soma em valores - por referencia
	//             nQtd			,;	// Retorno da soma em horas - por referencia
	//             cPerIni		,;	// Periodo Inicial
	//             cPerFim		,;	// Periodo Final
	//             cNumPgtIni 	,;	// Numero de Pagamento Inicial
	//             cNumPgtFim 	,;	// Numero de Pagamento Final
   	//             cRoteiro   	,;	// Lista de Roteiro de Execucao
   	//             lVerbas    	,; 	//Acumula por Verbas
   	//             lRetNeg     	;   //Retorna Negativo

	// Deve-se carregar todos os Meses do Ano de Afastamento e os 5 anos anteriores. No XML
	// serao gerados os meses trabalhados no ano de afastamento e os 5 anos anteriores
	cAnoProc  := AllTrim(Str(Year((cAlias)->RG_DATAHOM)))

	For nX := 1 to 6
		 nVrb13Sal := fBuscaAcmPer(cVrb13Sal,,"V",,,cAnoProc+"0101",cAnoProc+"1231",,,fGetCalcRot("6")) //13o salario 2a parcela

		 If PosSrv(cVrbFalta,SRG->RG_FILIAL,"RV_TIPO") $ "D"
		 	nFalt01 := fBuscaAcmPer(cVrbFalta,,"D",,,cAnoProc+"0101",cAnoProc+"0131",,,fGetCalcRot("1"))
		 	nFalt02 := fBuscaAcmPer(cVrbFalta,,"D",,,cAnoProc+"0201",cAnoProc+"02"+StrZero(f_UltDia(CTOD("01/02/"+cAnoProc)),2),,,fGetCalcRot("1"))
		 	nFalt03 := fBuscaAcmPer(cVrbFalta,,"D",,,cAnoProc+"0301",cAnoProc+"0331",,,fGetCalcRot("1"))
			nFalt04 := fBuscaAcmPer(cVrbFalta,,"D",,,cAnoProc+"0401",cAnoProc+"0430",,,fGetCalcRot("1"))
			nFalt05 := fBuscaAcmPer(cVrbFalta,,"D",,,cAnoProc+"0501",cAnoProc+"0531",,,fGetCalcRot("1"))
			nFalt06 := fBuscaAcmPer(cVrbFalta,,"D",,,cAnoProc+"0601",cAnoProc+"0630",,,fGetCalcRot("1"))
			nFalt07 := fBuscaAcmPer(cVrbFalta,,"D",,,cAnoProc+"0701",cAnoProc+"0731",,,fGetCalcRot("1"))
			nFalt08 := fBuscaAcmPer(cVrbFalta,,"D",,,cAnoProc+"0801",cAnoProc+"0831",,,fGetCalcRot("1"))
			nFalt09 := fBuscaAcmPer(cVrbFalta,,"D",,,cAnoProc+"0901",cAnoProc+"0930",,,fGetCalcRot("1"))
			nFalt10 := fBuscaAcmPer(cVrbFalta,,"D",,,cAnoProc+"1001",cAnoProc+"1031",,,fGetCalcRot("1"))
			nFalt11 := fBuscaAcmPer(cVrbFalta,,"D",,,cAnoProc+"1101",cAnoProc+"1130",,,fGetCalcRot("1"))
			nFalt12 := fBuscaAcmPer(cVrbFalta,,"D",,,cAnoProc+"1201",cAnoProc+"1231",,,fGetCalcRot("1"))
		EndIf

		aAdd(a13Sal, {	cAnoProc, nVrb13Sal,;
						Abs(nFalt01), Abs(nFalt02), Abs(nFalt03), Abs(nFalt04), Abs(nFalt05), Abs(nFalt06),;
						Abs(nFalt07), Abs(nFalt08), Abs(nFalt09), Abs(nFalt10), Abs(nFalt11), Abs(nFalt12)	})

		cAnoProc  := AllTrim(Str(Year((cAlias)->RG_DATAHOM) - nX ))
		///-- Limita os dados do 13 terceiro ao ano da admissao do funcionario.
	    If ( Year( (cAlias)->RG_DATAHOM ) - nX ) < Year( (cAlias)->RA_ADMISSA )
	    	Exit
	    Endif
	Next nX

	//Carrega transferencias
	fTransf( @aTransf , .T.)

	If Empty(aTransf)
		cQryWhere := "AND RD_FILIAL='"+(cAlias)->RG_FILIAL+"' "
		cQryWhere += "AND RD_MAT='"+(cAlias)->RG_MAT+"' "
	Else
		cQryWhere := "AND ( ( RD_FILIAL='"+(cAlias)->RG_FILIAL+"' "
		cQryWhere += "AND RD_MAT='"+(cAlias)->RG_MAT+"' ) "
		For nX := 1 to Len(aTransf)
			//Somente quando for transferencia da mesma empresa e para outra filial
			If aTransf[nX,01] == cEmpAnt .and. !( aTransf[nX,08] == (cAlias)->RG_FILIAL )
				cQryWhere += "OR ( RD_FILIAL='"+aTransf[nX,08]+"' "
				cQryWhere += "AND RD_MAT='"+aTransf[nX,09]+"' ) "
			EndIf
		Next nX
		cQryWhere += " ) "
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ 4.	Manipulacao e Gravacao de Dados Financeiros                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// Tratamento de verbas do Acumulado
	cQuery     := ""
	cAliasSRD  := "QRYSRD"
	cDtInicial := DTOS( MonthSub((cAlias)->RG_DATAHOM,85) )	//-MonthSub(dDate,nMonth)

	cQuery := "SELECT RV_PERC, RV_INCORP, RV_REFFER, RV_REF13, RV_HOMOLOG, SRD.* "
	cQuery += "  FROM " + RetSqlName("SRD") + " SRD "

	cQuery += "INNER JOIN " + RetSqlName("SRV") + " SRV "
	cQuery += "   ON SRV.D_E_L_E_T_ = ' ' "
	cQuery += "  AND RV_FILIAL='"+xFilial("SRV",(cAlias)->RA_FILIAL)+"' "
	cQuery += "  AND RV_COD=RD_PD "
	cQuery += "  AND RV_TIPOCOD='1' "

	cQuery += "WHERE SRD.D_E_L_E_T_ = ' ' "
	cQuery += cQryWhere
	cQuery +=   "AND RD_DATARQ >= '" + SubStr(cDtInicial,1,6) + "' "
	cQuery += "  AND RD_MES <> '13' "

	cQuery += "ORDER BY RD_FILIAL,RD_MAT,RD_DATARQ,RV_HOMOLOG,RV_COD "

	cQuery := ChangeQuery(cQuery)

	If Select(cAliasSRD) > 0
		(cAliasSRD)->(dbCloseArea())
	Endif

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSRD)

	Count To nTRegSRD	//# Conta os registros retornados
	aEval( SRD->(dbStruct()),{|x| IIF(x[2] != "C",TcSetField(cAliasSRD,x[1],x[2],x[3],x[4]),Nil)} )	//# Corrige a forma das Datas e Numeros

	nPosSRD := 0
	aFinanc := {}

	// -------------------------------------------------------------------------------------------------------
	//  |94| Salario do mes anterior a rescisao
	// -------------------------------------------------------------------------------------------------------
	// A VERBA gravada aqui refere-se ao SRV e eh utilizada tanto para SRD quanto para SRR logo abaixo
	// -------------------------------------------------------------------------------------------------------
	fRetTab( @aTab25, "S025",,,,, .T. )

	cVrbFixa := ""

	If Len( aTab25 ) > 0 .and. (nAchou := aScan(aTab25, {|x| x[5] = '94'})) > 0
		cVrbFixa := aTab25[ nAchou, 6 ]
	Endif

	dbSelectArea(cAliasSRD)
	(cAliasSRD)->(dbGoTop())

	While (cAliasSRD)->( !Eof() )

		cMesAnoPag := SubStr((cAliasSRD)->RD_DATARQ,1,6)	//-29/11/2010-SubStr((cAliasSRD)->RD_DATARQ,5,2)+SubStr((cAliasSRD)->RD_DATARQ,1,4)
		cHomolog   := (cAliasSRD)->RV_HOMOLOG
		cCodFol	   := PosSrv((cAliasSRD)->RD_PD,(cAliasSRD)->RD_FILIAL,"RV_CODFOL")
		cTmpMatr   := (cAliasSRD)->RD_MAT
		cTmpSind   := GetAdvFVal("SRA", "RA_SINDICA", xFilial("SRA")+cTmpMatr,,.F.)
		nPerc	   := (cAliasSRD)->RV_PERC

		If cMesAnoPag != cMesAnoAnt
			cMesAnoAnt := cMesAnoPag
			aAdd( aCompSRD, {cMesAnoAnt} )
		EndIf

		lSomaPerc:= .T.

		//Busca o percentual de acordo com o cadastro de sindicato
		If cCodFol $ "0001/0002/0003/0004/0005/"  //cCodFol = "0031"
			Do Case
				Case cCodFol == "0001"
					nTmpPerc := GetAdvFVal("RCE","RCE_PERAN", xFilial("RCE")+cTmpSind,,.F.)
					nPerc 	 := Iif(nTmpPerc > 0, nTmpPerc, nPerc)
				Case cCodFol == "0002"
					nTmpPerc := GetAdvFVal("RCE","RCE_PERBI", xFilial("RCE")+cTmpSind,,.F.)
					nPerc 	 := Iif(nTmpPerc > 0, nTmpPerc, nPerc)
				Case cCodFol == "0003"
					nTmpPerc := GetAdvFVal("RCE","RCE_PERTR", xFilial("RCE")+cTmpSind,,.F.)
					nPerc 	 := Iif(nTmpPerc > 0, nTmpPerc, nPerc)
				Case cCodFol == "0004"
					nTmpPerc := GetAdvFVal("RCE","RCE_PERQR", xFilial("RCE")+cTmpSind,,.F.)
					nPerc 	 := Iif(nTmpPerc > 0, nTmpPerc, nPerc)
				Case cCodFol == "0005"
					nTmpPerc := GetAdvFVal("RCE","RCE_PERQN", xFilial("RCE")+cTmpSind,,.F.)
					nPerc 	 := Iif(nTmpPerc > 0, nTmpPerc, nPerc)
			EndCase
		EndIf

		If Empty(cHomolog) // "001"
			nPosSRD := aScan( aFinanc, {|x| x[02]==cMesAnoPag .And. x[03]==(cAliasSRD)->RD_PD} )
		Else
			IF ( cHomolog <> '004' )
				nPosSRD := aScan( aFinanc, {|x| x[02]==cMesAnoPag .And. x[03]==cHomolog} )
				lSomaPerc:= .T.
			Else
				//-- Horas Extras com mesmo percentual
				nPosSRD := aScan( aFinanc, {|x|	x[02]==cMesAnoPag .And. x[03]=='004' .And. X[11] == nPerc} )
				lSomaPerc:= .F.
			Endif
		EndIf

		//O saldo de salario e gerado para Horista e Mensalista, sendo sua configuracao padrao rubrica 001 (Salario Fixo)
		//Entao, o codigo sera alterado para 005 somente para horista ou diarista, para que a verba seja gerada em horas
		If (cAlias)->RA_CATFUNC $ "H/D" .And. cCodFol $ "0048" .And. cHomolog # '005'
			cHomolog := '005'
		EndIf

		If nPosSRD > 0	// = 0
			aFinanc[nPosSRD,04] += (cAliasSRD)->RD_HORAS
			aFinanc[nPosSRD,05] += (cAliasSRD)->RD_VALOR
			If nPerc > 0 .and. lSomaPerc
				aFinanc[nPosSRD,11] += nPerc
			EndIf
			//Altera o codigo do Saldo de Salario do horista/diarista de 001 para 005
			If cCodFol $ "0048"
				aFinanc[nPosSRD,03]	:= cHomolog
			EndIf
		Else
			cIncorpSal := "000"

			If (cAliasSRD)->RV_INCORP == "S"	// = "N"
				If (cAliasSRD)->RV_REFFER == "S"
					cIncorpSal := "1"
				Else
					cIncorpSal := "0"
				EndIf

				If (cAliasSRD)->RV_REF13 == "S"
					cIncorpSal += "1"
				Else
					cIncorpSal += "0"
				EndIf
				cIncorpSal += "0"
			EndIf

			nVlSalLiq := If(!Empty( cVrbFixa ) .and. (cAliasSRD)->RD_PD $ cVrbFixa, (cAliasSRD)->RD_VALOR, 0.00 )	//ROBO=0

			If Substr( cMesAnoPag, 5, 2 ) > "12"
				cMesAnoPag := Substr( cMesAnoPag, 1, 4 ) + "12"
			EndIf

			aAdd(aFinanc, { Iif(!Empty(cHomolog),"1","2")						,;	// - 01
							cMesAnoPag											,;	// - 02
							Iif(!Empty(cHomolog),cHomolog,(cAliasSRD)->RD_PD)	,;	// - 03
							(cAliasSRD)->RD_HORAS								,;	// - 04
							(cAliasSRD)->RD_VALOR								,;	// - 05
							(cAliasSRD)->RD_FGTS								,;	// - 06
							(cAliasSRD)->RD_INSS								,;	// - 07
							(cAliasSRD)->RD_IR									,;	// - 08
							cIncorpSal											,;	// - 09
							(cAliasSRD)->RD_DATPGT								,;	// - 10
							nPerc												,;	// - 11
							nVlSalLiq											;	// - 12 - Liquido a Receber
							})
		EndIf

		dbSelectArea(cAliasSRD)
		(cAliasSRD)->( dbSkip() )
	EndDo

	//# Tratamento de verbas de PROVENTO da Rescisao
	cQuery     := ""
	cAliasSRR  := "QSRR"

	cQuery := "SELECT RV_PERC,RV_INCORP,RV_REFFER,RV_REF13, RV_FGTS,RV_INSS,RV_IR,RV_HOMOLOG,SRR.* "
	cQuery += "  FROM " + RetSqlName("SRR") + " SRR "
	cQuery += " INNER JOIN " + RetSqlName("SRV") + " SRV "
	cQuery += "    ON SRV.D_E_L_E_T_ = ' ' "
	cQuery += "   AND RV_FILIAL='"+xFilial("SRV",(cAlias)->RA_FILIAL)+"' "
	cQuery += "   AND RV_COD=RR_PD "
	cQuery += "   AND RV_TIPOCOD='1' "
	cQuery += " WHERE SRR.D_E_L_E_T_ = ' ' "
	cQuery += "   AND RR_TIPO3='R' "
	cQuery += "   AND RR_FILIAL='"+(cAlias)->RG_FILIAL+"' "
	cQuery += "   AND RR_MAT='"+(cAlias)->RG_MAT+"' "
	cQuery += "   AND RR_DATA= '"+DTOS((cAlias)->RG_DTGERAR)+"' "
	cQuery += " ORDER BY RR_FILIAL,RR_MAT,RV_HOMOLOG,RV_COD "

	cQuery := ChangeQuery(cQuery)

	If Select(cAliasSRR) > 0
		(cAliasSRR)->(dbCloseArea())
	Endif

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSRR)

	Count To nTRegSRD	//# Conta os registros retornados
	aEval( SRR->(dbStruct()),{|x| IIF(x[2] != "C",TcSetField(cAliasSRR,x[1],x[2],x[3],x[4]),Nil)} )	//# Corrige a forma das Datas e Numeros

	// -------------------------------------------------------------------------------------------------------
	//  |94| Salario do mes anterior a rescisao
	// -------------------------------------------------------------------------------------------------------
	// A VERBA gravada aqui refere-se ao SRV e eh utilizada tanto para SRD quanto para SRR logo abaixo
	// -------------------------------------------------------------------------------------------------------
	fRetTab( @aTab25, "S025",,,,, .T. )

	cVrbFixa := ""

	If Len( aTab25 ) > 0 .and. (nAchou := aScan(aTab25, {|x| x[5] = '94'})) > 0
		cVrbFixa := aTab25[ nAchou, 6 ]
	Endif

	dbSelectArea(cAliasSRR)
	(cAliasSRR)->(dbGoTop())

	nPosSRR := 0
	cHomolog:= ""
	cCodFol	:= ""

	While (cAliasSRR)->( !Eof() )
		cMesAnoPag := SubStr(DTOS((cAliasSRR)->RR_DATA),1,6)	//-29/11/2010-SubStr(DTOS((cAliasSRR)->RR_DATA),5,2)+SubStr(DTOS((cAliasSRR)->RR_DATA),1,4)
		cHomolog   := (cAliasSRR)->RV_HOMOLOG
		cCodFol	   := PosSrv((cAliasSRR)->RR_PD,(cAliasSRR)->RR_FILIAL,"RV_CODFOL")
		cTmpMatr   := (cAliasSRR)->RR_MAT
		cTmpSind   := GetAdvFVal("SRA", "RA_SINDICA", xFilial("SRA")+cTmpMatr,,.F.)
		nPerc	   := (cAliasSRR)->RV_PERC

		If aScan( aCompSRD, {|x| x[01] == cMesAnoPag } ) > 0
			(cAliasSRR)->( dbSkip() )
			Loop
		EndIf

		If cCodFol $ "0034/0035/0048/0064/0067/0066/0070/0071/0072/0077/0086/0087/0111/0112/0113/0114/0115/0121/0122/0125/0126/0129/0166/0224/0226/0230/0231/0248/0249/0250/0251/0252/0253/0328/0430/0625/0925/0926" .and.;
		   VAL(PosSrv((cAliasSRR)->rr_pd,(cAliasSRR)->RR_FILIAL,"RV_HOMOLOG")) == 0
			(cAliasSRR)->( dbSkip() )
			loop
		Endif

		//Busca o percentual de acordo com o cadastro de sindicato
		If cCodFol $ "0001/0002/0003/0004/0005/"
			Do Case
				Case cCodFol == "0001"
					nTmpPerc := GetAdvFVal("RCE","RCE_PERAN", xFilial("RCE")+cTmpSind,,.F.)
					nPerc 	 := Iif(nTmpPerc > 0, nTmpPerc, nPerc)
				Case cCodFol == "0002"
					nTmpPerc := GetAdvFVal("RCE","RCE_PERBI", xFilial("RCE")+cTmpSind,,.F.)
					nPerc 	 := Iif(nTmpPerc > 0, nTmpPerc, nPerc)
				Case cCodFol == "0003"
					nTmpPerc := GetAdvFVal("RCE","RCE_PERTR", xFilial("RCE")+cTmpSind,,.F.)
					nPerc 	 := Iif(nTmpPerc > 0, nTmpPerc, nPerc)
				Case cCodFol == "0004"
					nTmpPerc := GetAdvFVal("RCE","RCE_PERQR", xFilial("RCE")+cTmpSind,,.F.)
					nPerc 	 := Iif(nTmpPerc > 0, nTmpPerc, nPerc)
				Case cCodFol == "0005"
					nTmpPerc := GetAdvFVal("RCE","RCE_PERQN", xFilial("RCE")+cTmpSind,,.F.)
					nPerc 	 := Iif(nTmpPerc > 0, nTmpPerc, nPerc)
			EndCase
		EndIf

		lSomaPerc:= .T.

		If Empty(cHomolog)
			nPosSRR := aScan( aFinanc, {|x| x[02]==cMesAnoPag .And. x[03]==(cAliasSRR)->RR_PD} )
		Else
			IF ( (cAliasSRR)->RV_HOMOLOG <> '004' )
				nPosSRR := aScan( aFinanc, {|x| x[02]==cMesAnoPag .And. x[03]==cHomolog} )
				lSomaPerc:= .T.
			Else
				//-- Horas Extras com mesmo percentual
				nPosSRR := aScan( aFinanc, {|x|	x[02]==cMesAnoPag 	.And. ;
												x[03]=='004' 		.And. X[11] == nPerc} )
				lSomaPerc:= .F.
			Endif
		EndIf

		//O saldo de salario e gerado para Horista e Mensalista, sendo sua configuracao padrao rubrica 001 (Salario Fixo)
		//Entao, o codigo sera alterado para 005 somente para horista ou diarista, para que a verba seja gerada em horas
		If (cAlias)->RA_CATFUNC $ "H/D" .And. cCodFol $ "0048" .And. cHomolog # '005'
			cHomolog := '005'
		EndIf

		If nPosSRR > 0
			aFinanc[nPosSRR,04] += (cAliasSRR)->RR_HORAS
			aFinanc[nPosSRR,05] += (cAliasSRR)->RR_VALOR
			If nPerc > 0 .AND. lSomaPerc
				aFinanc[nPosSRR,11] += nPerc
			EndIf
			//Altera o codigo do Saldo de Salario do horista/diarista de 001 para 005
			If cCodFol $ "0048"
				aFinanc[nPosSRR,03]	:= cHomolog
			EndIf
		Else
			cIncorpSal := "000"

			If (cAliasSRR)->RV_INCORP == "S"
				If (cAliasSRR)->RV_REFFER == "S"
					cIncorpSal := "1"
				Else
					cIncorpSal := "0"
				EndIf

				If (cAliasSRR)->RV_REF13 == "S"
					cIncorpSal += "1"
				Else
					cIncorpSal += "0"
				EndIf
				cIncorpSal += "0"
			EndIf

			nVlSalLiq := If(!Empty( cVrbFixa ) .and. (cAliasSRR)->RR_PD $ cVrbFixa, (cAliasSRR)->RR_VALOR, 0.00 )

			// Tratamento para o Mes do Decimo Terceiro. Converte Mes "13" para 12, pois o validador do homolognet nao aceita 13
			If Substr( cMesAnoPag, 5, 2 ) > "12"
				cMesAnoPag := Substr( cMesAnoPag, 1, 4 ) + "12"
			EndIf

			aAdd(aFinanc, { Iif(!Empty(cHomolog),"1","2")						,;	// - 01
							cMesAnoPag											,;	// - 02
							Iif(!Empty(cHomolog),cHomolog,(cAliasSRR)->RR_PD)	,;	// - 03
							(cAliasSRR)->RR_HORAS								,;	// - 04
							(cAliasSRR)->RR_VALOR								,;	// - 05
							(cAliasSRR)->RV_FGTS								,;	// - 06
							(cAliasSRR)->RV_INSS								,;	// - 07
							(cAliasSRR)->RV_IR									,;	// - 08
							cIncorpSal											,;	// - 09
							CTOD("//")											,;	// - 10
							nPerc												,;	// - 11
							nVlSalLiq											;	// - 12 - Liquido a Receber
							})
		EndIf

		dbSelectArea(cAliasSRR)
		(cAliasSRR)->( dbSkip() )
	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ 5.	Manipulacao e Gravacao de Dados de Movimentacao            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cIniMov  := DTOS( MonthSub((cAlias)->RG_DATADEM,85) )	//-MonthSub(dDate,nMonth)
    dDtDemis := (cAlias)->RG_DATADEM

	cQuery     := ""
	cAliasSR8  := "QRYSR8"

	cQuery := "SELECT SR8.* "
	cQuery += "  FROM " + RetSqlName("SR8") + " SR8 "
	cQuery += " INNER JOIN " + RetSqlName("RCM") + " RCM "
	cQuery += "    ON RCM.D_E_L_E_T_ = ' ' "
	cQuery += "   AND RCM_FILIAL='"+xFilial("RCM",(cAlias)->RA_FILIAL)+"' "
	cQuery += "   AND RCM_TIPO=R8_TIPOAFA "
	cQuery += "   AND RCM_TIPOAF='1' "
	cQuery += " WHERE SR8.D_E_L_E_T_ = ' ' "
	cQuery += "   AND R8_FILIAL='"+(cAlias)->RG_FILIAL+"' "
	cQuery += "   AND R8_MAT='"+(cAlias)->RG_MAT+"' "
	cQuery += "   AND R8_DATAINI>='"+SubStr(cIniMov,1,6)+"' "
	cQuery += " ORDER BY R8_FILIAL,R8_MAT,R8_DATAINI,R8_TIPOAFA,RCM_TIPO,RCM_TIPOAF "

	cQuery := ChangeQuery(cQuery)

	If Select(cAliasSR8) > 0
		(cAliasSR8)->(dbCloseArea())
	Endif

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSR8)

	Count To nTRegSR8	//# Conta os registros retornados
	aEval( SR8->(dbStruct()),{|x| IIF(x[2] != "C",TcSetField(cAliasSR8,x[1],x[2],x[3],x[4]),Nil)} )	//# Corrige a forma das Datas e Numeros

	dbSelectArea(cAliasSR8)
	(cAliasSR8)->(dbGoTop())

	nPosSR8 := 0
	aMovto  := {}
	aAfast  := {}

	While (cAliasSR8)->( !Eof() )

		//**********************
		cAuxCompet	:= Substr(DTOS((cAliasSR8)->R8_DATAINI),1,6)
		cSitFunc	:= Nil
		FMSR8Hom(cAuxCompet,@aAfast,@cSitFunc,(cAliasSR8)->R8_DATAINI,(cAliasSR8)->R8_TIPOAFA)
		//**********************

		If Len(aAfast) > 0
			For nX := 1 to Len(aAfast)
				If !Empty(aAfast[nX,1]) .and. Empty(Ascan(aMovto,{|x| ( x[2] = aAfast[nX,2] ) .and. ( x[3] = aAfast[nX,1] ) } ))
					aAdd(aMovto, {	"1", aAfast[nX,2], aAfast[nX,1]	})
				EndIf
			Next nX
		EndIf

		dbSelectArea(cAliasSR8)
		(cAliasSR8)->( dbSkip() )
	EndDo


    cAuxCompet	:= SubStr(cIniMov,1,6)
    cAMesProx	:= MesAno(dDtDemis+((f_UltDia(dDtDemis)-Day(dDtDemis))+1))

	//estou colocando aqui como experiencia
	//Verifica Existencia da Tabela S043 - Tipos de Rescisao
	fCarrTab( @aTabS043, "S043",,.T.)
	If Len( aTabS043 ) == 0
	    Aviso(STR0007,STR0010,{STR0011}) //"ATENCAO","Tabela S043 - Tipos deRescisao não encontrada. Favor verificar!" ### Sair
	    Return .F.
	EndIf

	//Verifica Existencia da Tabela S032 - Cód.Movimentação
	fCarrTab( @aTabS032, "S032",,.T.)
	If Len( aTabS032 ) == 0
	    Aviso(STR0007,STR0010,{STR0013}) //"ATENCAO","Tabela S032 - Cod. Movimentação não encontrada. Favor verificar!" ### Sair
	    Return .F.
	EndIf

	If SRA->RA_SITFOLH == 'D'
		 cTipo1 := fCodMov( SRA->RA_AFASFGT,SRA->RA_DEMISSA,cAuxCompet )
		 If !Empty(Ascan(aTabS032,{|x| ( x[5] = cTipo1 ) } ))
    		 Aadd(aAfast,{SRA->RA_DEMISSA,cTipo1,"D",0,.T.,.F.})
	    EndIf
	Else
		If SRG->(dbSeek(SRA->RA_FILIAL+SRA->RA_MAT+cAMesProx))
		 	If SRR->(dbseek(SRA->RA_FILIAL+SRA->RA_MAT+"R"+DTOS(SRG->RG_DTGERAR)+cFgtsMAnt))
		 		If ( nPos := aScan(aTabS043,{|x| x[3] == SRG->RG_TIPORES .and. (Empty(x[1]) .or. x[1] == xFilial("SRA"))}) ) == 0
	                Aviso(STR0007,STR0012,{STR0011}) //"ATENCAO","Tipo de Rescisao não cadastrado na tabela S043." ### Sair
	                Return .F.
	            EndIf

	            GPM080Empresa( xFilial("SRA"), @cCodCnpj, @cNomeEmpr )
	            cCodR 	:= aTabS043[nPos,22]
	            cTipo1 	:= fCodMov( cCodR,SRG->RG_DATADEM,cAuxCompet )

     		    If !Empty(Ascan(aTabS032,{|x| ( x[5] = cTipo1 ) } ))
     		    	Aadd(aAfast,{SRG->RG_DATADEM,cTipo1,"D",0,.T.,.T.})
     		    EndIf

     		    cSitFunc :=	"D"
     		Endif
		Endif
	Endif

	fTransf( aTransf , cAuxCompet)

	If len(aTRansf) > 0
		For nX := 1 to len(aTransf)
			If (aTransf[nx,04]+aTransf[nx,10] == cEmpAnt+SRA->RA_FILIAL) .and. (aTransf[nx,01]+aTransf[nx,08]#aTransf[nx,04]+aTransf[nx,10])
				Aadd(aAfast,{aTransf[nx,7],"N2","A",0,.T.,.T.})
			EndIf
		Next nX
	EndIf

	If Len(aAfast) > 0
		For nX := 1 to Len(aAfast)
			If !Empty(aAfast[nX,1]) .and. ;
				Empty(Ascan(aMovto,{|x| ( x[2] = aAfast[nX,2] ) .and. ( x[3] = aAfast[nX,1] ) } ))
				aAdd(aMovto, {	"1", aAfast[nX,2], aAfast[nX,1]	})
			EndIf
		Next nX
	EndIf

	RestArea(aAreaSRG )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ 7.	Manipulacao e Gravacao de Dados de Descontos             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//# Tratamento de verbas de DESCONTO da Rescisao
	cQuery     := ""
	cAliasSRR  := "QSRR"

	cQuery := "SELECT RV_INCORP,RV_REFFER,RV_REF13, RV_FGTS,RV_INSS,RV_IR,RV_HOMOLOG,SRR.* "
	cQuery += "  FROM " + RetSqlName("SRR") + " SRR "
	cQuery += " INNER JOIN " + RetSqlName("SRV") + " SRV "
	cQuery += "    ON SRV.D_E_L_E_T_ = ' ' "
	cQuery += "   AND RV_FILIAL='"+xFilial("SRV",(cAlias)->RA_FILIAL)+"' "
	cQuery += "   AND RV_COD=RR_PD "
	cQuery += "   AND RV_TIPOCOD='2' "
	cQuery += " WHERE SRR.D_E_L_E_T_ = ' ' "
	cQuery += "   AND RR_TIPO3='R' "
	cQuery += "   AND RR_FILIAL	= '" + (cAlias)->RG_FILIAL		  +"' "
	cQuery += "   AND RR_MAT	= '" + (cAlias)->RG_MAT			  +"' "
	cQuery += "   AND RR_DATA	= '" + DTOS((cAlias)->RG_DTGERAR) +"' "
	cQuery += " ORDER BY RR_FILIAL,RR_MAT,RV_HOMOLOG,RV_COD "

	cQuery := ChangeQuery(cQuery)

	If Select(cAliasSRR) > 0
		(cAliasSRR)->(dbCloseArea())
	Endif

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSRR)

	Count To nTRegSRD	//# Conta os registros retornados
	aEval( SRR->(dbStruct()),{|x| IIF(x[2] != "C",TcSetField(cAliasSRR,x[1],x[2],x[3],x[4]),Nil)} )	//# Corrige a forma das Datas e Numeros

	dbSelectArea(cAliasSRR)
	(cAliasSRR)->(dbGoTop())

	nPosSRR := 0
	aDescto := {}

	While (cAliasSRR)->( !Eof() )
		cMesAnoPag := SubStr(DTOS((cAliasSRR)->RR_DATA),1,6)	//-29/11/2010-SubStr(DTOS((cAliasSRR)->RR_DATA),5,2)+SubStr(DTOS((cAliasSRR)->RR_DATA),1,4)

		If PosSrv((cAliasSRR)->rr_pd,(cAliasSRR)->RR_FILIAL,"RV_CODFOL") $ "0034/0035/0048/0064/0066/0067/0070/0071/0072/0077/0086/0087/0111/0112/0113/0114/0115/0121/0122/0125/0126/0129/0166/0224/0226/0230/0231/0248/0249/0250/0251/0252/0253/0328/0430/0625/0925/0926"
			(cAliasSRR)->( dbSkip() )
			loop
		Endif

		If Empty((cAliasSRR)->RV_HOMOLOG)
			nPosSRR := aScan( aDescto, {|x| x[02]==cMesAnoPag .And. x[03]==(cAliasSRR)->RR_PD} )
		Else
			nPosSRR := aScan( aDescto, {|x| x[02]==cMesAnoPag .And. x[03]==(cAliasSRR)->RV_HOMOLOG} )
		EndIf

		If nPosSRR > 0
			aDescto[nPosSRR,04] += (cAliasSRR)->RR_HORAS
			If (cAliasSRR)->RV_HOMOLOG == "A03"
				aDescto[nPosSRR,05] += (cAliasSRR)->RR_HORAS
			Else
				aDescto[nPosSRR,05] += (cAliasSRR)->RR_VALOR
			Endif
		Else
			cIncorpSal := "000"

			If (cAliasSRR)->RV_INCORP == "S"
				If (cAliasSRR)->RV_REFFER == "S"
					cIncorpSal := "1"
				Else
					cIncorpSal := "0"
				EndIf

				If (cAliasSRR)->RV_REF13 == "S"
					cIncorpSal += "1"
				Else
					cIncorpSal += "0"
				EndIf
				cIncorpSal += "0"
			EndIf

			// Tratamento para o Mes do Decimo Terceiro. Converte Mes "13" para 12, pois o validador do homolognet nao aceita 13
			If Substr( cMesAnoPag, 5, 2 ) > "12"
				cMesAnoPag := Substr( cMesAnoPag, 1, 4 ) + "12"
			EndIf

			aAdd(aDescto, { Iif(!Empty((cAliasSRR)->RV_HOMOLOG),"1","2")									 	,;	// - 01
							cMesAnoPag																			,;	// - 02
							Iif(!Empty((cAliasSRR)->RV_HOMOLOG),(cAliasSRR)->RV_HOMOLOG,(cAliasSRR)->RR_PD)	 	,;	// - 03
							(cAliasSRR)->RR_HORAS															 	,;	// - 04
							Iif((cAliasSRR)->RV_HOMOLOG == "A03",(cAliasSRR)->RR_HORAS,(cAliasSRR)->RR_VALOR)	,;	// - 05
							(cAliasSRR)->RV_FGTS															 	,;	// - 06
							(cAliasSRR)->RV_INSS															 	,;	// - 07
							(cAliasSRR)->RV_IR																 	,;	// - 08
							cIncorpSal																		 	,;	// - 09
							CTOD("//")																		 	;	// - 10
							})
		EndIf

		dbSelectArea(cAliasSRR)
		(cAliasSRR)->( dbSkip() )
	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ (*) Faz a gravacao dos dados gerados em Arrays               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	fGrvArrays(aDadosIni, aFerias, a13Sal, aFinanc, aMovto, aDescto, (cAlias)->RA_FILIAL)

	dbSelectArea(cAlias)
	(cAlias)->( dbSkip() )
EndDo
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MontaPerAq    ³ Autor ³ Ademar Fernandes ³ Data ³ 01/11/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta array com todos os Periodos Aquisitivos do funciona- ³±±
±±³          ³ rio, sendo desde a Admissao ate a Demissao.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEM600                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MontaPerAq(lTop,cAlias)

Local lSRHok		:= .F.
Local cIndAux		:= ""
Local aPerAqui		:= {}
Local dDtBasIni		:= CTOD("//")
Local dDtBasFim		:= CTOD("//")
Local dDtLoopIni	:= CTOD("//")
Local dDtLoopFim	:= CTOD("//")
Local dDtFimFun 	:= CTOD("//")

dbSelectArea("SRH")	//-RH_FILIAL+RH_MAT+DTOS(RH_DATABAS)+DTOS(RH_DATAINI)

If dbSeek(xFilial("SRH",(cAlias)->RA_FILIAL)+(cAlias)->RA_MAT,.F.)
	lSRHok		:= .T.
	dDtBasIni	:= SRH->RH_DATABAS
	dDtBasFim	:= SRH->RH_DBASEAT
Else
	dbSelectArea("SRF")	//-RF_FILIAL+RF_MAT+DTOS(RF_DATABAS)+RF_PD
	If dbSeek(xFilial("SRF",(cAlias)->RA_FILIAL)+(cAlias)->RA_MAT,.F.)
		dDtBasIni := SRF->RF_DATABAS
	Else
		dDtBasIni := (cAlias)->RA_ADMISSA
	EndIf
	dDtBasFim := fCalcFimAq( dDtBasIni )
EndIf

If !Empty( dDtBasIni )
	cIndAux := xFilial( "SRH", (cAlias)->RA_FILIAL )  + (cAlias)->RA_MAT

	// Carrega todos os Periodos Aquisitivos no Vetor
	If (cAlias)->RA_ADMISSA <= dDtBasIni
		dDtLoopIni := (cAlias)->RA_ADMISSA
		While dDtLoopIni < dDtBasIni

			// Define a data final do periodo aquisitivo
			dDtLoopFim := fCalcFimAq( dDtLoopIni )

	  		aAdd( aPerAqui, {	"G02"		,;		// -01- Origem
								dDtLoopIni	,;		// -02- Data Per.Aquisitivo Inicial
								dDtLoopFim	,;		// -03- Data Per.Aquisitivo Final
								30		   	,;		// -04- Dias de Ferias Vencidas
								0			,;		// -05- Dias de Ferias Gozadas
								0		   	,;		// -06- Dias de Abono Gozados
								0			;		// -07- Dias de Faltas no Periodo
								})

			dDtLoopIni := dDtLoopFim + 1
		EndDo
	EndIf

	// Carrega e/ou Atualiza os Periodos do Vetor conforme a existencia no SRH
	If lSRHok
		While SRH->(!Eof()) .And. SRH->(RH_FILIAL+RH_MAT) == cIndAux

			nPos := aScan(aPerAqui, {|x| x[02]==SRH->RH_DATABAS})

			// Ao encontrar o periodo deve-se atualizar os 4 elementos abaixo.
			// Caso nao encontre, deve-se criar o periodo.
			If nPos > 0
				aPerAqui[nPos,01] := "G01"				// -01- Origem
				aPerAqui[nPos,05] += SRH->RH_DFERIAS	// -05- Dias de Ferias Gozadas
				aPerAqui[nPos,06] += SRH->RH_DABONPE	// -06- Dias de Abono Gozados
				aPerAqui[nPos,07] += SRH->RH_DFALTAS	// -07- Dias de Faltas no Periodo
			Else
				aAdd(	aPerAqui,	{	"SRH"		   		,;		// -01- Origem
										SRH->RH_DATABAS		,;		// -02- Data Per.Aquisitivo Inicial
										SRH->RH_DBASEAT		,;		// -03- Data Per.Aquisitivo Final
										SRH->RH_DFERVEN		,;		// -04- Dias de Ferias Vencidas
										SRH->RH_DFERIAS		,;		// -05- Dias de Ferias Gozadas
										SRH->RH_DABONPE		,;		// -06- Dias de Abono Gozados
										SRH->RH_DFALTAS		;		// -07- Dias de Faltas no Periodo
										})
			EndIf

			dDtBasFim  := SRH->RH_DBASEAT
			dDtLoopIni := SRH->RH_DATABAS
			dDtLoopFim := SRH->RH_DBASEAT

			SRH->( dbSkip() )
		EndDo
	EndIf

	//-Carrega os Periodos finais
	dDtFimFun := Iif( (cAlias)->RG_DATAHOM > (cAlias)->RG_DATADEM, (cAlias)->RG_DATAHOM, (cAlias)->RG_DATADEM )
	If !lSRHok .Or. dDtBasFim < dDtFimFun

		If lSRHok
			dDtLoopIni := dDtLoopFim + 1
		EndIf

		While dDtLoopIni < dDtFimFun
			nFaltaP := 0

			// Define a data final do periodo aquisitivo
			dDtLoopFim := fCalcFimAq( dDtLoopIni )

			If dDtLoopFim >= dDtFimFun //periodo em aberto
				cVrbFalta := aCodFol[Val("054"),1]+"/"+aCodFol[Val("203"),1]+"/"+aCodFol[Val("242"),1]
//				if PosSrv(cVrbFalta,SRG->RG_FILIAL,"RV_TIPO") $ "H"
//					nFaltaPH := fBuscaAcmPer(cVrbFalta,,dDtLoopIni,dDtFimFun,"H",)
//				endif
				If PosSrv(cVrbFalta,SRG->RG_FILIAL,"RV_TIPO") $ "D"
					nFaltaP := fBuscaAcmPer(cVrbFalta,,"H",,,Dtos(dDtLoopIni),Dtos(dDtFimFun),,,fGetCalcRot('1'))
				Endif

			   //	nFalt01 := fBuscaAcmPer(cVrbFalta,,CTOD("01/01/"+cAnoProc),CTOD("31/01/"+cAnoProc),"H",)
				nFaltaP := abs(nFaltaP)

				fMFaltas(cAlias)
				If nFaltap > 99
					nfaltap := 99
				Endif
			Endif

			aAdd(	aPerAqui, {	"G02"		,;	// -01- Origem
								dDtLoopIni	,;	// -02- Data Per.Aquisitivo Inicial
								dDtLoopFim	,;	// -03- Data Per.Aquisitivo Final
								30			,;	// -04- Dias de Ferias Vencidas
								0			,;	// -05- Dias de Ferias Gozadas
								0			,;	// -06- Dias de Abono Gozados
								nFaltap		;	// -07- Dias de Faltas no Periodo
								})

			dDtLoopIni := dDtLoopFim + 1
		EndDo
	EndIf
EndIf

Return(aPerAqui)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FSubst        ³ Autor ³ Cristina Ogura   ³ Data ³ 17/09/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao que substitui os caracteres especiais por espacos   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FSubst()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEM610                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fGrvArrays(aDadosIni, aFerias, a13Sal, aFinanc, aMovto, aDescto, cFilPar)

Local nX := 0

DEFAULT aDadosIni	:= {}
DEFAULT aFerias		:= {}
DEFAULT a13Sal		:= {}
DEFAULT aFinanc		:= {}
DEFAULT aMovto		:= {}
DEFAULT aDescto		:= {}

Begin Transaction

	If Len(aDadosIni) > 0

		If Len(aFerias) > 0
			For nX := 1 to Len(aFerias)
				RecLock("RGW",.T.)

				//-Cadastra Dados Iniciais
				RGW->RGW_FILIAL	:= aDadosIni[01,02]
				RGW->RGW_CCUSTO := aDadosIni[01,04]
				RGW->RGW_MAT	:= aDadosIni[01,03]
				RGW->RGW_TPRESC	:= aDadosIni[01,07]	//-1=Normal;2=Complementar
				RGW->RGW_HOMOL	:= aDadosIni[01,08]
				RGW->RGW_JTCUMP	:= aDadosIni[01,09]
				RGW->RGW_COMPSA	:= aDadosIni[01,10]
				RGW->RGW_FM13	:= aDadosIni[01,11]	//-1=CLT;2=Convencionado
				RGW->RGW_PER13	:= aDadosIni[01,12]
				RGW->RGW_QTDE13	:= aDadosIni[01,13]
				RGW->RGW_MA13	:= aDadosIni[01,14]
				RGW->RGW_FMFER	:= aDadosIni[01,15]	//-1=CLT;2=Convencionado
				RGW->RGW_PERFER	:= aDadosIni[01,16]
				RGW->RGW_QTDFER	:= aDadosIni[01,17]
				RGW->RGW_MAFER	:= aDadosIni[01,18]
				RGW->RGW_FMAV	:= aDadosIni[01,19]	//-1=CLT;2=Convencionado
				RGW->RGW_QTDEAV	:= aDadosIni[01,20]
				RGW->RGW_MAAV	:= aDadosIni[01,21]
				RGW->RGW_DAVISO	:= aDadosIni[01,22]

				//-Cadastra Dados de Ferias
				RGW->RGW_TPREG	:= "1"	//-1=Ferias;2=13.Salario
				RGW->RGW_DTINI	:= aFerias[nX,02]
				RGW->RGW_DTFIM	:= aFerias[nX,03]

				RGW->RGW_QUIT	:= "1"	//-1=Sim;2=Nao

				If aFerias[nX,01] == "G02"
					RGW->RGW_QUIT := "2"
				ElseIf nX = Len(aFerias)
					//-RF_FILIAL+RF_MAT+DTOS(RF_DATABAS)+RF_PD
					If SRF->( dbSeek(xFilial("SRF",aDadosIni[01,02])+aDadosIni[01,03]+DTOS(aFerias[nX,02]),.F.) )
						RGW->RGW_QUIT	:= "2"
					EndIf
				EndIf

				RGW->RGW_ALT	:= "1"	//-1=Gerado;2=Informado;3=Alterado
				RGW->RGW_FALT	:= iif (aFerias[nX,07]>99, 99, aFerias[nX,07])

				//??RGW->RGW_DTIFER	:= aFerias[nX,08]

				MsUnLock("RGW")
			Next nX
		EndIf

		If Len(a13Sal) > 0
			For nX := 1 to Len(a13Sal)
				RecLock("RGW",.T.)

				//-Cadastra Dados Iniciais
				RGW->RGW_FILIAL	:= aDadosIni[01,02]
				RGW->RGW_MAT	:= aDadosIni[01,03]
				RGW->RGW_CCUSTO	:= aDadosIni[01,04]
				RGW->RGW_TPRESC	:= aDadosIni[01,07]	//-1=Normal;2=Complementar
				RGW->RGW_HOMOL	:= aDadosIni[01,08]
				RGW->RGW_JTCUMP	:= aDadosIni[01,09]
				RGW->RGW_COMPSA	:= aDadosIni[01,10]
				RGW->RGW_FM13	:= aDadosIni[01,11]	//-1=CLT;2=Convencionado
				RGW->RGW_PER13	:= aDadosIni[01,12]
				RGW->RGW_QTDE13	:= aDadosIni[01,13]
				RGW->RGW_MA13   := aDadosIni[01,14]
				RGW->RGW_FMFER	:= aDadosIni[01,15]	//-1=CLT;2=Convencionado
				RGW->RGW_PERFER	:= aDadosIni[01,16]
				RGW->RGW_QTDFER	:= aDadosIni[01,17]
				RGW->RGW_MAFER	:= aDadosIni[01,18]
				RGW->RGW_FMAV   := aDadosIni[01,19]	//-1=CLT;2=Convencionado
				RGW->RGW_QTDEAV	:= aDadosIni[01,20]
				RGW->RGW_MAAV   := aDadosIni[01,21]
				RGW->RGW_DAVISO	:= aDadosIni[01,22]

				//-Cadastra Dados de 13.Salario
				RGW->RGW_TPREG	:= "2"	//-1=Ferias;2=13.Salario
				RGW->RGW_DTINI	:= CTOD("01/12/"+a13Sal[nX,01])
				RGW->RGW_DTFIM	:= CTOD("//")
				RGW->RGW_QUIT	:= Iif(a13Sal[nX,02] > 0, "1", "2")
				RGW->RGW_ALT	:= "1"	//-1=Gerado;2=Informado;3=Alterado
				RGW->RGW_FALT	:= 0
				RGW->RGW_VALP13	:= a13Sal[nX,02]
				RGW->RGW_M01	:= a13Sal[nX,03]
				RGW->RGW_M02	:= a13Sal[nX,04]
				RGW->RGW_M03	:= a13Sal[nX,05]
				RGW->RGW_M04	:= a13Sal[nX,06]
				RGW->RGW_M05	:= a13Sal[nX,07]
				RGW->RGW_M06	:= a13Sal[nX,08]
				RGW->RGW_M07	:= a13Sal[nX,09]
				RGW->RGW_M08	:= a13Sal[nX,10]
				RGW->RGW_M09	:= a13Sal[nX,11]
				RGW->RGW_M10	:= a13Sal[nX,12]
				RGW->RGW_M11	:= a13Sal[nX,13]
				RGW->RGW_M12	:= a13Sal[nX,14]
				MsUnLock("RGW")
			Next nX
		EndIf

		If Len(aFinanc) > 0

			//-Zera variaveis
			cForSal		:= ""
			cTpSal		:= ""
			cFgts		:= ""
			cInss		:= ""
			cIrrf		:= ""
			dPgtoDt		:= CTOD("//")
			nLiqSalMAnt := 0

			//-Carrega a Tabela S020 (HomologNet-Cod.Rubricas)
	   		//-fRetTab( aTab_Fol, cCodTab, npoSind, npoExpre, dDataRef, cSindica, lTabFull, cFilPar)
	   		aTabS020 := {}
	   		fRetTab(@aTabS020,"S020",,,aDadosIni[01,08],,.T.,cFilPar)

			For nX := 1 to Len(aFinanc)
				RecLock("RGX",.T.)

				RGX->RGX_FILIAL	:= xFilial("RGX", aDadosIni[01,02])
				RGX->RGX_MAT	:= aDadosIni[01,03]
				RGX->RGX_TPRESC	:= aDadosIni[01,07]	//-1=Normal;2=Complementar
				RGX->RGX_HOMOL	:= aDadosIni[01,08]

				cForSal := Iif((aDadosIni[01,23]$"C*T*J" .And. aDadosIni[01,24]=0), "2", "3")
				cTpSal := " "
				If cForSal=="3" .And. aDadosIni[01,23]=="H"
					cTpSal := "1"
				ElseIf cForSal=="3" .And. aDadosIni[01,23]=="D"
					cTpSal := "3"
				Else
					cTpSal := "2"
				EndIf
				RGX->RGX_TPREG	:= aFinanc[nX,01]
				RGX->RGX_MESANO	:= aFinanc[nX,02]
				RGX->RGX_FORSAL	:= cForSal
				RGX->RGX_TPSAL	:= cTpSal
				RGX->RGX_CODRUB	:= aFinanc[nX,03]

				If aFinanc[nX,01] == "2"	//-SRV->RV_COD

					RGX->RGX_VALRUB	:= aFinanc[nX,05]

				Else						//-SRV->RV_HOMOLOG

			 		nPosMyTab := aScan( aTabS020, {|x| x[5] == aFinanc[nX,03] } )
			 		If nPosMyTab > 0
				 		If aTabS020[nPosMyTab,07] == "S"
							RGX->RGX_VALRUB	:= aFinanc[nX,05]
						EndIf
				 		If aTabS020[nPosMyTab,08] == "S"
							RGX->RGX_QTDHOR	:= aFinanc[nX,04]
						EndIf
				 		If aTabS020[nPosMyTab,09] == "S"
				 			if RGX->RGX_CODRUB == "004"
								RGX->RGX_PERC	:= aFinanc[nX,11] - 100
							else
								RGX->RGX_PERC	:= aFinanc[nX,11]
							endif
						EndIf
				 		If aTabS020[nPosMyTab,10] == "S"
							RGX->RGX_VALBC	:= Round((aFinanc[nX,05] / aFinanc[nX,11] * 100), MsDecimais(1))
						EndIf
					Else
						RGX->RGX_VALRUB	:= aFinanc[nX,05]
					EndIf
				EndIf

				RGX->RGX_PROD	:= ""
				RGX->RGX_QTDPRO	:= 0
				cFgts := Iif(Alltrim(aFinanc[nX,06]) == "S", "1", "0")
				cInss := Iif(Alltrim(aFinanc[nX,07]) == "S", "1", "0")
				cIrrf := Iif(Alltrim(aFinanc[nX,08]) == "S", "1", "0")
				RGX->RGX_TRIBUT	:= cFgts + cInss + cIrrf
				RGX->RGX_INTBC	:= aFinanc[nX,09]

				MsUnLock("RGX")

				If aFinanc[nX,10] > dPgtoDt
					dPgtoDt := aFinanc[nX,10]
				EndIf
				If aFinanc[nX,12] > 0.00
					nLiqSalMAnt := aFinanc[nX,12]
				EndIf
			Next nX

			//-Registro de fechamento do funcionario
			RecLock("RGX",.T.)

			RGX->RGX_FILIAL	:= xFilial("RGX", aDadosIni[01,02])
			RGX->RGX_MAT	:= aDadosIni[01,03]
			RGX->RGX_TPRESC	:= aDadosIni[01,07]	//-1=Normal;2=Complementar
			RGX->RGX_HOMOL	:= aDadosIni[01,08]

			RGX->RGX_TPREG	:= "3"
			RGX->RGX_MESANO	:= "999999"
			RGX->RGX_QTDDSR	:= 0

			// Somente enviar Salario Liquido se Data de Afastamento for entre o Primeiro e Sexto Dia do Mes
			// If dPgtoDt >= aDadosIni[01,08]	//-Dt.Pgto > Dt.Homolog
			If Day( dPgtoDt ) < 7
				RGX->RGX_SALLIQ	:= nLiqSalMAnt
			Else
				RGX->RGX_SALLIQ	:= 0
			EndIf

			MsUnLock("RGX")
		EndIf

		If Len(aMovto) > 0

			For nX := 1 to Len(aMovto)
				RecLock("RGZ",.T.)

				RGZ->RGZ_FILIAL	:= xFilial("RGZ", aDadosIni[01,02])
				RGZ->RGZ_MAT	:= aDadosIni[01,03]
				RGZ->RGZ_TPRESC	:= aDadosIni[01,07]	//-1=Normal;2=Complementar
				RGZ->RGZ_HOMOL	:= aDadosIni[01,08]
				if aMovto[nX,02] == "X"
			  		RGZ->RGZ_MOTIVO	:= "X2"
				Elseif	aMovto[nX,02] == "Z5"
			  		RGZ->RGZ_MOTIVO	:= "Z10"
				ELSE
			  		RGZ->RGZ_MOTIVO	:= aMovto[nX,02]
			 	ENDIF

				RGZ->RGZ_DTMVTO	:= aMovto[nX,03]

				MsUnLock("RGZ")

			Next nX
		EndIf

		If Len(aDescto) > 0

			//-Zera variaveis
			cFgts	:= ""
			cInss	:= ""
			cIrrf	:= ""

			For nX := 1 to Len( aDescto )
				RecLock("RGY",.T.)

				RGY->RGY_FILIAL	:= xFilial("RGY", aDadosIni[01,02])
				RGY->RGY_MAT	:= aDadosIni[01,03]
				RGY->RGY_TPRESC	:= aDadosIni[01,07]	//-1=Normal;2=Complementar
				RGY->RGY_HOMOL	:= aDadosIni[01,08]

				RGY->RGY_TPREG	:= aDescto[nX,01]
				//?? RGY->RGY_MESANO	:= aDescto[nX,02]
				RGY->RGY_CODIGO	:= aDescto[nX,03]
				RGY->RGY_VALHOR	:= aDescto[nX,05]
				cFgts := Iif(Alltrim(aDescto[nX,06]) == "S", "1", "0")
				cInss := Iif(Alltrim(aDescto[nX,07]) == "S", "1", "0")
				cIrrf := Iif(Alltrim(aDescto[nX,08]) == "S", "1", "0")
				RGY->RGY_TRIBUT	:= cFgts + cInss + cIrrf
				//?? RGY->RGY_INTBC	:= aDescto[nX,09]

				MsUnLock("RGY")

			Next nX
		EndIf

	EndIf

End Transaction
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FMSR8Hom  ³ Autor ³ Mauro            ³ Data ³ 25/03/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica no SR8 existe o funcionario                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FMSr8Hom(AnoMes,aAfast)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEM610                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fMSr8Hom(cCompet,aAfast,cSitFunc,dAuxPar01,cTipoAfa)

Local lRet		:= .F.
Local dDtUltAc 	:= CTOD("")
Local dDtUltAd 	:= CTOD("")
Local nDiasSR8 	:= 0
Local lAtu		:= .T.
Local aGetArea	:= GetArea()
Local aAfas_OP	:= {}
Local lContAfas := .F.
Local cContAfa	:= ""
Local nPosAfas	:= 0
Local cTipo1	   := ""
Local lExistPE	:= ExistBlock("GP610AFAS")	//-- Ponto de Entrada para validar o tipo de afastamento.
Local lGp610Afas := .T.
Local nX		    := 0
Local nPos       := 0

cSitFunc := If (cSitFunc == Nil , SRA->RA_SITFOLH,cSitFunc)

// Array aAfast
// 1 - Data da movimentacao
// 2 - Tipo de Ocorrencia para a SEFIP
// 3 - "A"=Afastamento "R"=Retorno
// 4 - Dias do afastamento
// 5 - Flag se F=colocar zeros nos dias do Tipo 32

dbSelectArea("SR8")
dbSetOrder(6)
If dbSeek(xFilial("SR8")+SRA->RA_MAT+Dtos(dAuxPar01)+cTipoAfa)
	While !Eof() .And. SR8->R8_FILIAL+SR8->R8_MAT==SRA->RA_FILIAL+SRA->RA_MAT
		//-- Executa o ponto de entrada
		If lExistPE
			lGp610Afas:= ExecBlock('GP610AFAS',.F.,.F.)
		Endif

		dbSelectArea("RCM")
		dbSetOrder(RetOrder("RCM", "RCM_FILIAL+RCM_TIPO"))
      	If dbSeek(xFilial("RCM")+SR8->R8_TIPOAFA)
      		If RCM->RCM_TIPOAFA == '1' .And. !Empty(RCM->RCM_CODHOM) .And. lGp610Afas // Ferias e Licenca Remunerada
      			cTipo1 := Alltrim(RCM->RCM_CODHOM)
      			lAtu	:= .T.

      			If (RCM->RCM_CODSEF $"O1*O2*O3*P1*P2*P3")
      				Aadd(aAfas_OP,{SR8->R8_SEQ,RCM->RCM_CODSEF,SR8->R8_DATAINI,SR8->R8_DATAFIM,SR8->R8_CONTAFA })
      			EndIf

			    If cCompet == MesAno(SR8->R8_DATAINI) .Or.;
			    	(MesAno(SR8->R8_DATAINI) <= cCompet .And.  Empty(SR8->R8_DATAFIM)) .Or.;
			    	(MesAno(SR8->R8_DATAINI) <= cCompet .And.  MesAno(SR8->R8_DATAFIM) >= cCompet)

			    	// Desconsiderar para Tipo O e P quando os dias forem <= 15
			    	If cTipo1 $ "P1*P2*P3*O1*O2*O3" .And. !Empty(SR8->R8_DATAFIM) .And. (Day(SR8->R8_DATAFIM) - Day(SR8->R8_DATAINI) <= 15)
			    		lAtu := .F.
			    	EndIf

				    // Calcula os dias quando existir retorno de afastamento
				    nDiasSR8 :=0
				    If MesAno(SR8->R8_DATAFIM) == cCompet
				    	If Month(SR8->R8_DATAINI) == Month(SR8->R8_DATAFIM)
				    		// Desconsidera os 15 dias
				    		If cTipo1 $ "O1*P1"
				    			nDiasSR8 := SR8->R8_DATAFIM - (SR8->R8_DATAINI + 14)
				    		Else
				    			nDiasSR8 := SR8->R8_DATAFIM - SR8->R8_DATAINI
				    		EndIf
				    	Else
				    		nDiasSR8 := Day(SR8->R8_DATAFIM)
				    	EndIf

				    	If nDiasSR8 < 0
				    		nDiasSR8 := 0
				    	EndIf
				    Else
				    	nDiasSR8 := SR8->R8_DURACAO
				    EndIf

				    Aadd(aAfast,{SR8->R8_DATAINI,cTipo1,"A",nDiasSR8,lAtu,.F.})

 				    If !Empty(SR8->R8_DATAFIM)
 				    	If Alltrim(RCM->RCM_CODHOM) == "Q1"
 				    		cTipo1 := "Z1"
						ElseIf Alltrim(RCM->RCM_CODHOM) == "O1"
							cTipo1 := "Z2"
						ElseIf Alltrim(RCM->RCM_CODHOM) == "O2"
							cTipo1 := "Z3"
						ElseIf Alltrim(RCM->RCM_CODHOM) == "R"
							cTipo1 := "Z4"
						ElseIf Alltrim(RCM->RCM_CODHOM)== "O3"
							cTipo1 := "Z6"
						ElseIf Alltrim(RCM->RCM_CODHOM)== "P1"
							cTipo1 := "Z7"
						ElseIf Alltrim(RCM->RCM_CODHOM) == "P2"
							cTipo1 := "Z8"
						ElseIf Alltrim(RCM->RCM_CODHOM) == "X1"
							cTipo1 := "Z9"
						ElseIf Alltrim(RCM->RCM_CODHOM) == "X2"
							cTipo1 := "Z10"
						ElseIf Alltrim(RCM->RCM_CODHOM) == "U3"
							cTipo1 := "Z11"
						ElseIf Alltrim(RCM->RCM_CODHOM)== "W"
							cTipo1 := "Z12"
						ElseIf Alltrim(RCM->RCM_CODHOM)== "Q3"
							cTipo1 := "Z13"
						ElseIf Alltrim(RCM->RCM_CODHOM) == "Q2"
							cTipo1 := "Z14"
						ElseIf Alltrim(RCM->RCM_CODHOM)== "Q4"
							cTipo1 := "Z15"
						ElseIf Alltrim(RCM->RCM_CODHOM)== "Q6"
							cTipo1 := "Z6"
						Endif

						Aadd(aAfast,{SR8->R8_DATAFIM,cTipo1,"R",0,lAtu,.F.})
					Endif
				Endif
			EndIf
		EndIf

		dbSelectArea("SR8")
		dbSkip()
	EndDo
Endif
RestArea(aGetArea)

Return lRet


//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
//±±³Fun‡…o    ³ FMFaltas      ³ Autor ³ Marcia           ³ Data ³ 16/12/10 ³±±
//±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
//±±³Descri‡…o ³ Verifica no SR8 existe o funcionario                       ³±±
//±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
//±±³Sintaxe   ³ FMFaltas                                                   ³±±
//±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
//±±³Uso       ³ GPEM610                                                    ³±±
//±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function fMFaltas(cAlias)

	dbSelectArea("SRR")	//-RR_FILIAL+RR_MAT+RR_TIPO3+DTOS(RR_DATA)+RR_PD+RR_CC
   	dbSeek((cAlias)->RA_FILIAL+(cAlias)->RA_MAT+"R"+DTOS(SRG->RG_DATADEM),.F.)
	SRR->( dbSeek( (cAlias)->( RA_FILIAL + RA_MAT ) + "R"+ Dtos(SRG->RG_DTGERAR) ) )

	While SRR->( !Eof() )
		If SRR->RR_FILIAL == SRG->RG_FILIAL .And. SRR->RR_MAT == SRG->RG_MAT .And. SRR->RR_TIPO3 == 'R' .And. SRR->RR_DATA == SRG->RG_DATADEM
			If SRR->RR_PD == aCodFol[ 054, 1 ] .Or. SRR->RR_PD == aCodFol[ 203,1] .Or. SRR->RR_PD == aCodFol[242,1]
				If PosSrv(SRR->RR_PD,SRR->RR_FILIAL,"RV_TIPO") $ "D"
					nFaltaP += INT(SRR->RR_HORAS)
				Endif
			Endif
		Endif
		dbSelectArea("SRR")
		SRR->( dbSkip() )
	EndDo

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ VldVerRub ³ Autor ³ Luis Ricardo Cinalli ³ Data ³ 31/05/2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida Relacionamento entre as Rubricas Externas e as Verbas ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VldVerRub													³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ True ou False												³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function VldVerRub( )

Local aArea	:= GetArea()
Local lRet	:= .F.

DbSelectArea( "SRV" )
DbSetOrder( 1 )
If DbSeek( xFilial( "SRV" ) + M->VERBA )
	If ! Empty( SRV->RV_HOMOLOG )
		Aviso( STR0007, STR0008, { "Ok" } )
	Else
		lRet := .T.
	EndIf
Else
	Aviso( STR0007, STR0009, { "Ok" } )
EndIf

RestArea( aArea )

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fGpm600VCod ³ Autor ³ M. Silveira        ³ Data ³ 31/07/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida o Codigo informado na tabela S027                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ True ou False												³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function fGpm600VCod()

Local aArea	:= GetArea()
Local lRet	:= .T.

If ( Type("M->CODIGO") # "U" )

	If Val(M->CODIGO) < 100
		lRet	:= .F.
		Aviso( STR0007, STR0014, { "Ok" } ) //"O Codigo deve ter o valor igual ou maior que 100."
	EndIf

EndIf

RestArea( aArea )

Return( lRet )