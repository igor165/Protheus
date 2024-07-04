#INCLUDE "PROTHEUS.CH"
#INCLUDE "FISA073.CH"
#INCLUDE "FWCOMMAND.CH"

STATIC cDbType := TCGetDB()

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA073

Rotina de geracao do Arquivo XML do Inovar Auto

@return Nil

@author Luccas Curcio 
@since 11/04/2014
@version 1.0

/*/
//-------------------------------------------------------------------
Function FISA073()
Local aFilial := {}
Local lVerpesssen := Iif(FindFunction("Verpesssen"),Verpesssen(),.T.)

If lVerpesssen .And. Pergunte( "FISA073" )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³X073IniRot -> Inicializao da rotina do Inovar Auto               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If X073IniRot()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³MatFilCalc -> Funcao que oferece interface ao usuario para       ³
		//³selecionar as filiais que serao consideradas no processamento.   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aFilial := MatFilCalc( .T. )
		If !Empty(aFilial)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³X073Schema -> Estruturacao e copia (se necessario) do Schema no RootPath ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			X073Schema( 2 )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³X073XMLForn -> Estrutura, valida e gera o Arquivo XML de Fornecedores ou Montadoras  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If MV_PAR06 == 1
				Processa( { || X073XMLForn( aFilial ) } , STR0014 )	//"Processando Arquivo XML"
			ElseIf MV_PAR06 == 2
				Processa( { || X073ConvF( aFilial ) } , STR0014 )	//"Processando Arquivo XML"
			ElseIf MV_PAR06 == 3
				Processa( { || X073AquisF( aFilial ) } , STR0014 )	//"Processando Arquivo XML"			
			Endif
		EndIf
	EndIf
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} X073XMLForn

Geracao do Arquivo XML para os Fornecedores do programa Inovar Auto

@param	aFilial,Array,contendo as filiais da empresa indicando quais foram selecionadas.

@return Nil

@author Luccas Curcio 
@since 11/04/2014
@version 11.0

/*/
//-------------------------------------------------------------------
Static Function X073XMLForn( aFilial )
Local dDataDe    := MV_PAR01
Local dDataAte   := MV_PAR02
Local cMes       := StrZero(Month( dDataDe ),2)
Local cAno       := Str(Year( dDataDe ),4)
Local cFile      := X073XMLName(cMes,cAno)
Local cStartPath := Nil
Local cEndPath   := AllTrim( MV_PAR05 )
Local cPathSchema:= GetNewPar( "MV_INOVSCH" , "" ) + GetNewPar( "MV_INOVXSF" , "" ) + ".XSD"
Local cBarra     := If(isSrvUnix(),"/","\")
Local cArq       := Nil
Local cXML       := ""
Local cErroXML   := ""
Local cWarnXML   := ""
Local cError     := ""
Local cWarning   := ""
Local cAliasQry  := ""
Local cAliasDev  := ""
Local cIsMatriz  := ""
Local cIsRetif   := ""
Local cClNome    := ""
Local cClCNPJ    := ""
Local cDev       := ""
Local nVlrRet    := 0
Local nVlrTot    := 0
Local nVlrDed    := 0
Local nHandle    := 0
Local nX         := 0
Local nPosProd   := 0
Local nVlrDev    := 0
Local nVlDedDev  := 0
Local aCalcProd  := {}
Local lAbort     := .F.
Local aAreaSM0   := SM0->( GetArea() )
Local lRet       := .T.
Local lFound     := .F.
Local lDevolv    := .F.
Local oXML
Local cLOGRec    := ""
Local cPerPrd   := ""
Local cMesPrd   := ""
Local cAnoPrd   := ""
Local CvhSekDev := "" 

If	SubStr(cEndPath,Len(cEndPath),1) <> cBarra
	cEndPath := cEndPath + cBarra
EndIf

//Aglutino a barra "\" caso nao tenha sido preenchida
If !Substring(cPathSchema,1,1) == "\"
	cPathSchema := "\" + cPathSchema
EndIf

ProcRegua( 3 )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                                                                     ³
//³             ESTRUTURACAO DO ARQUIVO XML DOS FORNECEDORES DE MONTADORAS QUE ADERIRAM AO PROGRAMA INOVAR AUTO         ³
//³                                                                                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IncProc( STR0010 )	//"Estruturando Arquivo XML"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Identifica se eh uma declaracao retificadora ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cIsRetif := Iif( MV_PAR04 == 1 , 'true' , 'false' )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa Cabecalho do Arquivo XML  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cXML += X073String( 'XML_INI_CAB' , { cIsRetif } )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Laco das Filiais selecionadas no inicio da rotina, pois podera ser gerado um unico arquivo XML   ³
//³para todas as filiais que efetuaram vendas para as Montadoras.                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To Len( aFilial )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifico se a Filial foi selecionada para processamento  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aFilial[ nX , 1 ]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Posiciona a Filial selecionada em MatFilCalc             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SM0->( dbSeek( cEmpAnt + aFilial[ nX , 2 ] ) )
		cFilAnt := FWGETCODFILIAL
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inicializa matriz de produto processados                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aCalcProd := {}
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Query na tabela SFT para retornar as vendas do periodo para as Montadoras (agrupa por Montadora) ³
		//³Tambem sera utilizado para identificar se a Filial corrente tem movimentacao de venda para       ³
		//³alguma Montadora, pois se nao houver nao devera ser gerada no arquivo XML.                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		X073GetQry( 1 , { dDataDe , dDataAte } , 'FORNECEDOR' , @cAliasQry, @lRet )
		If lRet
			lFound := .T.
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Inicia o processamento - Limpa tabelas / Calcula Entradas            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MATPrcPrd(cMes,cAno,Nil,Nil,"CLJ",.T.) 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Identifica se a Filial eh a Matriz, para informacao nas tags proprias³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cIsMatriz := Iif( AllTrim( SM0->M0_CODFIL ) == AllTrim( MV_PAR03 ) , 'true' , 'false' )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Gera as Tags que inicializam o Grupo Declarante. ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cXML += X073String( 'XML_INI_DECLARANTE'  , { x073Conv(SM0->M0_NOMECOM) , SM0->M0_CGC , cIsMatriz } )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Retorna as devoluções se houver  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			X073GetDev({ DToS(dDataDe), DToS(dDataAte) }, @cDev)	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Laco na query feita para as vendas do periodo.   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
			While !(cAliasQry)->( Eof() )
				cClNome := (cAliasQry)->A1_NOME
				cClCNPJ := (cAliasQry)->A1_CGC
				nVlrTot := 0
				nVlrDed := 0
				nVlrDev := 0
				nVlDedDev	:= 0
				While cClNome+cClCNPJ == (cAliasQry)->A1_NOME+(cAliasQry)->A1_CGC
				
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Calculo do valor dedutivel unitario do produto. ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If (nPosProd := aScan(aCalcProd, {|x| x[1]==(cAliasQry)->FT_PRODUTO})) == 0
						
						cPerPrd := ""
						nVlrRet := 0
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Retorna o periodo da ultima producao do produto.³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						cPerPrd := x073UltProd((cAliasQry)->FT_PRODUTO, dDataAte)
						
						If cPerPrd <> "000000"
							cMesPrd := SubStr(cPerPrd,1,2)
							cAnoPrd := SubStr(cPerPrd,3,4)
						
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Processa as producoes do produto com base no ultimo periodo obtido.³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ						
							MATPrcPrd(cMesPrd,cAnoPrd,(cAliasQry)->FT_PRODUTO,(cAliasQry)->FT_PRODUTO,"CLJ",.F.,@cLOGRec)
							
							CLJ->(DbSetOrder(1)) //CLJ_FILIAL+CLJ_COD+CLJ_PERIOD
							
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Obtenho o VI calculado com base no periodo da ultima producao. ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ								
							If CLJ->(MsSeek(xFilial("CLJ")+(cAliasQry)->FT_PRODUTO+cMesPrd+cAnoPrd))
								nVlrRet := CLJ->CLJ_VLRVI
							EndIf
						EndIf
				   
						aAdd(aCalcProd,{(cAliasQry)->FT_PRODUTO, nVlrRet})
						
					Else
						nVlrRet := aCalcProd[nPosProd, 2]
					EndIf
					lDevolv   := .F.
					If (cDev)->(MsSeek((cAliasQry)->A1_COD+(cAliasQry)->A1_LOJA)) 	.And.;
						(cAliasQry)->A1_COD+(cAliasQry)->A1_LOJA <> CvhSekDev									
							nVlrDev   += (cDev)->FT_VALCONT
							nVlDedDev += (cDev)->FT_QUANT
							lDevolv   := .T.		
							CvhSekDev := 	(cAliasQry)->A1_COD+(cAliasQry)->A1_LOJA						
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				   //³Multiplica valor encontrado pela quantidade de vendas ³
				   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					 nVlrTot += IIF(lDevolv,(cAliasQry)->FT_VALCONT - nVlrDev, (cAliasQry)->FT_VALCONT )
					 nVlrDed += IIF(lDevolv,((cAliasQry)->FT_QUANT-nVlDedDev) * nVlrRet, (cAliasQry)->FT_QUANT * nVlrRet)
					       
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Pula para o proximo registro da query.   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					(cAliasQry)->( dbSkip() )					
					lDevolv := .F.
				EndDo
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Geracao das Tags de Operacao (deve ser gerado um Grupo de Tags Operacao para cada Montadora      ³
				//³que possui vendas no periodo)                                                                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nVlrTot < 0  //tratamento para zerar saldo negativo, até ser criado controle de saldo
					nVlrTot := 0
				Endif
				cXML += X073String( 'XML_OPERACAO' , { x073Conv(cClNome) , cClCNPJ , Month( dDataDe ) , Year( dDataDe ) , nVlrTot , nVlrDed } )
			EndDo
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Finaliza o processamento - Apresenta LOG de Recursividade           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MATPrcPrd(cMes,cAno,Nil,Nil,"CLJ",.F.,@cLOGRec,.T.)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Gera as Tags que finalizam o Grupo Declarante.   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cXML += X073String( 'XML_END_DECLARANTE' )
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Fecha area aberta para execucao da Query ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		X073GetQry( 2 , , , cAliasQry )
		
		If !Empty(cDev)
		   DbSelectArea(cDev)
		   DbCloseArea()
		   cDev := ""
		EndIf
	Endif
Next nX
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Rodape do Arquivo XML    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cXML += X073String( 'XML_END_CAB' )

If lFound
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³                                                                                                                     ³
	//³             VALIDACAO DO ARQUIVO XML DOS FORNECEDORES DE MONTADORAS QUE ADERIRAM AO PROGRAMA INOVAR AUTO            ³
	//³                                                                                                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IncProc( STR0011 )	//"Validando Arquivo XML"

	oXML := XMLParser( cXML , '_' , @cErroXML , @cWarnXML )

	Do Case
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Situacao onde o XMLParser() nao resolveu a string e nao foi possivel construir o objeto XML  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Case oXML == Nil
			MsgStop(	STR0002 + CRLF +;				//"Falha ao gerar Objeto XML!"
						STR0003 + cErroXML + CRLF +;	//"Erro: " ####
						STR0004 + cWarnXML )			//"Advertência: " ####

			lAbort	:=	.T.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Situacao onde o XML nao esta de acordo com o Schema - utilizacao da funcao XMLSVldSch()      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Case !( XMLSVldSch( cXML , cPathSchema , @cError , @cWarning ) )

			MsgStop(	STR0005 + CRLF +;				//"O arquivo XML gerado não está de acordo com o Schema!"
						STR0003 + cError + CRLF +;		//"Erro: " ####
						STR0004 + cWarning )			//"Advertência: " ####

			lAbort := .T.
	End Case
Else
	Aviso("Sem Movimento","Não houve movimento no período, ou na Filial selecionada. " + CRLF + CRLF + "Nenhum XML será gerado.",{"Fechar"},3)
	lAbort := .T.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                                                      ³
//³     GERACAO DO ARQUIVO XML DOS FORNECEDORES DE MONTADORAS QUE ADERIRAM AO PROGRAMA INOVAR AUTO       ³
//³                                                                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If !lAbort

	IncProc( STR0012 )	//"Gerando Arquivo XML"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³xFunGetDir -> Funcao responsavel pela criacao do arquivo em diretorio direcionado.   ³
	//³Quando o primeiro parametro igual a 1, executa criacao do arquivo no StartPath       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If xFunGetDir( 1 , , @cArq , @cStartPath , @nHandle )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³WrtStrTxt -> Funcao responsavel por efetuar a gravacao de String em um arquivo   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		WrtStrTxt( nHandle , cXML )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³xFunGetDir -> Funcao responsavel pela criacao do arquivo em diretorio direcionado.   ³
		//³Quando o primeiro parametro igual a 2, libera o Handle do arquivo                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If xFunGetDir( 2 , , , , nHandle )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³xFunGetDir -> Funcao responsavel pela criacao do arquivo em diretorio direcionado.                       ³
			//³Quando o primeiro parametro igual a 3, efetuar copia do arquivo do StartPath para diretorio selecionado  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If xFunGetDir( 3 , cEndPath + cFile , cArq , cStartPath )
				MsgInfo( STR0006 + cFile + STR0007 + cEndPath )	//"O arquivo " #### " foi criado com sucesso no diretório " ####
			Endif
		Endif
	Endif
Endif

RestArea( aAreaSM0 )
cFilAnt := FWGETCODFILIAL

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} X073Schema

Funcao que retorna e gera o arquivo XSD (Schema) base do XML na pasta
do RootPath

@param	nEvent,number,Evento<BR>1 - Retorna String com estrutura do XSD.<BR>	2 - Retorna String com estrutura do XSD e gera o arquivo no diretorio selecionado (MV_INOVSCH) do RootPath.
		
@return cXSD,String,estrutura do arquivo XSD

@author Luccas Curcio 
@since 11/04/2014
@version 11.0

/*/
//-------------------------------------------------------------------
Static Function X073Schema( nEvent )
Local nHandle    := 0
Local cFile      := ""
Local cXSD       := ""
Local cEndPath   := ""
Local cMvInovsch := ""
Local cStartPath := Nil
Local cArq       := Nil
Local cTpArq	 := MV_PAR06
Local cRootPath  := AllTrim(GetSrvProfString("RootPath",""))

If cTpArq == 1
	cFile      := GetNewPar( "MV_INOVXSF" , "" ) + ".XSD"
ElseIf cTpArq == 2
	cFile      := GetNewPar( "MV_INOVXSC" , "" ) + ".XSD"
ElseIf cTpArq == 3
	cFile      := GetNewPar( "MV_INOVXSA" , "" ) + ".XSD"
Endif

//Independente do preenchimento do parametro, faco a verificacao
//Verifico se a Root Path ja veio preenchida com a barra no final
If Substring(cRootPath,Len(cRootPath),1) == "\"
	//Se o parametro for preenchido com barra "\", desconsidero a barra do parametro
	If SubString(GetNewPar( 'MV_INOVSCH' , '' ),1,1) == "\"	
		cMvInovsch := SubString(GetNewPar( 'MV_INOVSCH' , '' ),2,Len(GetNewPar( 'MV_INOVSCH' , '' )))
	Else
		//Se o parametro estiver sem barra, aglutino a informacao
		cMvInovsch := GetNewPar( 'MV_INOVSCH' , '\Schemas\InovarAuto\' )
	EndIf
Else
	If SubString(GetNewPar( 'MV_INOVSCH' , '\Schemas\InovarAuto\' ),1,1) == "\"
		//Se o parametro estiver com barra, aglutino a informacao
		cMvInovsch := GetNewPar( 'MV_INOVSCH' , '' )
	Else
		//Se estiver sem barra, no parametro e na root path. aglutino a barra
		cMvInovsch := "\" + GetNewPar( 'MV_INOVSCH' , '\Schemas\InovarAuto\' )
	EndIf
EndIf

cEndPath := cRootPath + cMvInovsch

If MV_PAR06 == 1
	cXSD := X073String( 'XSD' )
ElseIf MV_PAR06 == 2           
	cXSD := X073String( 'XSD_CONV_FOR' )
ElseIf MV_PAR06 == 3
	cXSD := X073String( 'XSD_AUT_DEC_AQU' )
Endif

If !FwMakeDir( cEndPath ,.F.)
	FwMakeDir(cMvInovsch)
	cEndPath := cMvInovsch
EndIf

If nEvent == 2 .And. !( File( cEndPath + cFile ) )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³xFunGetDir -> Funcao responsavel pela criacao do arquivo em diretorio direcionado.   ³
	//³Quando o primeiro parametro igual a 1, executa criacao do arquivo no StartPath       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If xFunGetDir( 1 , , @cArq , @cStartPath , @nHandle )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³WrtStrTxt -> Funcao responsavel por efetuar a gravacao de String em um arquivo   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		X073WrtStr( nHandle , cXSD )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³xFunGetDir -> Funcao responsavel pela criacao do arquivo em diretorio direcionado.   ³
		//³Quando o primeiro parametro igual a 2, libera o Handle do arquivo                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If xFunGetDir( 2 , , , , nHandle )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³xFunGetDir -> Funcao responsavel pela criacao do arquivo em diretorio direcionado.                       ³
			//³Quando o primeiro parametro igual a 3, efetuar copia do arquivo do StartPath para diretorio selecionado  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If xFunGetDir( 3 , cEndPath + cFile , cArq , cStartPath )
				MsgInfo( STR0008 + cEndPath )	//'O Schema (arquivo .XSD) foi gerado com sucesso no diretório: ####
			Endif
		Endif
	Endif
Endif

Return cXSD

//-------------------------------------------------------------------
/*/{Protheus.doc} X073String

Funcao que retorna string para montagem dos arquivos XML e XSD

@param	cType,String,Tipo da String que deseja que seja retornada pela funcao.
@param	aParam,Array,Parametros para geracao das informacoes das Tags.

@return	cString,String,String para utilizar nos arquivos XML e XSD

@author Luccas Curcio 
@since 11/04/2014
@version 11.0

/*/
//-------------------------------------------------------------------
Static Function X073String( cType , aParam )
Local cString := ""

If cType == 'XML_INI_CAB'

	cString	+=	'<?xml version="1.0" encoding="ISO-8859-1" ?>'
	cString	+=	'<tns:AutoDeclaracao '
	cString	+=	'xmlns:tns="http://www.tarea.com.br/InovarAuto/AutoDeclaracao" '
	cString	+=	'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
	cString	+=	'<tns:retificadora>' + aParam[1] + '</tns:retificadora>'

Elseif cType == 'XML_END_CAB'

	cString	+=	'</tns:AutoDeclaracao>'

Elseif cType == 'XML_INI_DECLARANTE'

	cString	+=	'<tns:declarante>'
	cString	+=	'<tns:tipo_declarante>' + 'F' + '</tns:tipo_declarante>'
	cString	+=	'<tns:razao_social>' + AllTrim( aParam[1] ) + '</tns:razao_social>'
	cString	+=	'<tns:cnpj>' + AllTrim( aParam[2] ) + '</tns:cnpj>'
	cString	+=	'<tns:matriz>' + aParam[3] + '</tns:matriz>'

Elseif cType == 'XML_END_DECLARANTE'

	cString	+=	'</tns:declarante>'

Elseif cType == 'XML_OPERACAO'

	cString	+=	'<tns:operacao>'
	cString	+=	'<tns:natureza_operacao>V</tns:natureza_operacao>'
	cString	+=	'<tns:empresa>'
	cString	+=	'<tns:razao_social>' + AllTrim( aParam[1] ) + '</tns:razao_social>'
	cString	+=	'<tns:cnpj>' + AllTrim( aParam[2] ) + '</tns:cnpj>'
	cString	+=	'</tns:empresa>'
	cString	+=	'<tns:mes_ref>' + AllTrim( Str( aParam[3] ) ) + '</tns:mes_ref>'
	cString	+=	'<tns:ano_ref>' + AllTrim( Str( aParam[4] ) ) + '</tns:ano_ref>'
	cString	+=	'<tns:vl_total_notas>' + AllTrim( Str( aParam[5] ) ) + '</tns:vl_total_notas>'
	cString	+=	'<tns:vl_parc_dedutivel>' + AllTrim( Str( aParam[6] ) ) + '</tns:vl_parc_dedutivel>'
	cString	+=	'</tns:operacao>'

Elseif cType == 'XSD'

	cString	+=	'<?xml version="1.0" encoding="UTF-8"?>'
	cString	+=	'<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema"'
	cString	+=	'	targetNamespace="http://www.tarea.com.br/InovarAuto/AutoDeclaracao"'
	cString	+=	'	xmlns:tns="http://www.tarea.com.br/InovarAuto/AutoDeclaracao"'
	cString	+=	'	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'
	cString	+=	'	elementFormDefault="qualified"'
	cString	+=	'	attributeFormDefault="unqualified" xmlns:xsd="http://www.w3.org/2001/XMLSchema">'
	cString	+=	'	<xs:element name="AutoDeclaracao" type="tns:AutoDeclaracaoType"/>'
	cString	+=	'	<xs:element name="AutoDeclaracaoResponse" type="tns:AutoDeclaracaoTypeResponse"/>'
	cString	+=	'	<xs:complexType name="AutoDeclaracaoType">'
	cString	+=	'		<xs:sequence>'
	cString	+=	'			<xs:element name="retificadora" type="xs:boolean" minOccurs="1" maxOccurs="1"/>'
	cString	+=	'			<xs:element name="declarante" type="tns:DeclaranteType" minOccurs="1" maxOccurs="unbounded"/>'
	cString	+=	'		</xs:sequence>'
	cString	+=	'	</xs:complexType>'
	cString	+=	'	<xs:complexType name="DeclaranteType">'
	cString	+=	'		<xs:sequence>'
	cString	+=	'			<xs:element name="tipo_declarante" type="tns:TipoDeclaranteType" minOccurs="1" maxOccurs="1"/>'
	cString	+=	'			<xs:element name="razao_social" type="xs:string" minOccurs="1" maxOccurs="1"/>'
	cString	+=	'			<xs:element name="cnpj" type="xs:long" minOccurs="1" maxOccurs="1"/>'
	cString	+=	'			<xs:element name="matriz" type="xs:boolean" minOccurs="1" maxOccurs="1"/>'
	cString	+=	'			<xs:element name="operacao" type="tns:OperacaoType" minOccurs="1" maxOccurs="unbounded"/>'
	cString	+=	'		</xs:sequence>'
	cString	+=	'	</xs:complexType>'
	cString	+=	'	<xs:complexType name="OperacaoType">'
	cString	+=	'		<xs:sequence>'
	cString	+=	'			<xs:element name="natureza_operacao" type="tns:NaturezaOperacaoType" minOccurs="1" maxOccurs="1"/>'
	cString	+=	'			<xs:element name="empresa" type="tns:EmpresaType" minOccurs="1" maxOccurs="1"/>'
	cString	+=	'			<xs:element name="mes_ref" type="tns:MesReferenciaType" minOccurs="1" maxOccurs="1"/>'
	cString	+=	'			<xs:element name="ano_ref" type="xs:integer" minOccurs="1" maxOccurs="1"/>'
	cString	+=	'			<xs:element name="vl_total_notas" type="xs:double" minOccurs="1" maxOccurs="1"/>'
	cString	+=	'			<xs:element name="vl_parc_dedutivel" type="xs:double" minOccurs="0" maxOccurs="1"/>'
	cString	+=	'		</xs:sequence>'
	cString	+=	'	</xs:complexType>'
	cString	+=	'	<xs:complexType name="EmpresaType">'
	cString	+=	'		<xs:sequence>'
	cString	+=	'			<xs:element name="razao_social" type="xs:string" minOccurs="1" maxOccurs="1"/>'
	cString	+=	'			<xs:element name="cnpj" type="xs:long" minOccurs="1" maxOccurs="1"/>'
	cString	+=	'		</xs:sequence>'
	cString	+=	'	</xs:complexType>'
	cString	+=	'	<xs:complexType name="AutoDeclaracaoTypeResponse">'
	cString	+=	'		<xs:sequence>'
	cString	+=	'			<xs:element name="cnpj" type="xs:long" minOccurs="1" maxOccurs="1"/>'
	cString	+=	'			<xs:element name="data" type="xs:dateTime" minOccurs="1" maxOccurs="1"/>'
	cString	+=	'			<xs:element name="status" type="xs:string" minOccurs="1" maxOccurs="1"/>'
	cString	+=	'			<xs:element name="num_transacao" type="xs:string" minOccurs="1" maxOccurs="1"/>'
	cString	+=	'		</xs:sequence>'
	cString	+=	'	</xs:complexType>'
	cString	+=	'	<xs:simpleType name="NaturezaOperacaoType">'
	cString	+=	'		<xs:annotation>'
	cString	+=	'			<xs:documentation>'
	cString	+=	'				Indica se trata-se de uma operacao de [A]quisicao ou [V]enda.'
	cString	+=	'			</xs:documentation>'
	cString	+=	'		</xs:annotation>'
	cString	+=	'		<xs:restriction base="xs:string">'
	cString	+=	'			<xs:enumeration value="A"/>'
	cString	+=	'			<xs:enumeration value="V"/>'
	cString	+=	'		</xs:restriction>'
	cString	+=	'	</xs:simpleType>'
	cString	+=	'	<xs:simpleType name="TipoDeclaranteType">'
	cString	+=	'		<xs:annotation>'
	cString	+=	'			<xs:documentation>'
	cString	+=	'				Indica se o arquivo e de um [F]ornecedor ou [M]ontadora.'
	cString	+=	'			</xs:documentation>'
	cString	+=	'		</xs:annotation>'
	cString	+=	'		<xs:restriction base="xs:string">'
	cString	+=	'			<xs:enumeration value="F"/>'
	cString	+=	'			<xs:enumeration value="M"/>'
	cString	+=	'		</xs:restriction>'
	cString	+=	'	</xs:simpleType>'
	cString	+=	'	<xs:simpleType name="MesReferenciaType">'
	cString	+=	'		<xs:annotation>'
	cString	+=	'			<xs:documentation>'
	cString	+=	'				Valores validos para o mes de referencia.'
	cString	+=	'			</xs:documentation>'
	cString	+=	'		</xs:annotation>'
	cString	+=	'		<xs:restriction base="xs:integer">'
	cString	+=	'			<xs:minInclusive value="1"/>'
	cString	+=	'			<xs:maxInclusive value="12"/>'
	cString	+=	'		</xs:restriction>'
	cString	+=	'	</xs:simpleType>'
	cString	+=	'</xs:schema>'

Elseif cType == 'XSD_CONV_FOR'
	cString	+=	'<?xml version="1.0" encoding="UTF-8"?>'
	cString	+=	'<xs:schema'
	cString +=  '	xmlns:xs="http://www.w3.org/2001/XMLSchema"'
	cString +=  '	targetNamespace="http://www.tarea.com.br/InovarAuto/CargaFornecedores"'
	cString +=  '	xmlns:tns="http://www.tarea.com.br/InovarAuto/CargaFornecedores"'
	cString +=  '	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'
	cString	+=	'	elementFormDefault="qualified"'
	cString	+=	'	attributeFormDefault="unqualified">'	
	cString	+=	'	<xs:element name="CargaFornecedores" type="tns:CargaFornecedoresType"/>'
	cString	+=	'	<xs:element name="CargaFornecedoresResponse" type="tns:CargaFornecedoresTypeResponse"/>'
	cString	+=	'	<xs:complexType name="CargaFornecedoresType">'
	cString	+=	'		<xs:sequence>'
	cString	+=	'			<xs:element name="razao_social" type="xs:string" minOccurs="1" maxOccurs="1"/>'
	cString	+=	'			<xs:element name="cnpj" type="xs:long" minOccurs="1" maxOccurs="1"/>'
	cString	+=	'			<xs:element name="fornecedores" type="tns:FornecedoresType" minOccurs="1" maxOccurs="unbounded"/>'
	cString	+=	'		</xs:sequence>'
	cString	+=	'	</xs:complexType>'
	cString	+=	'	<xs:complexType name="FornecedoresType">'
	cString	+=	'	<xs:sequence>'
	cString	+=	'		<xs:element name="nome_fantasia" type="xs:string" minOccurs="1" maxOccurs="1"/>'
	cString	+=	'		<xs:element name="razao_social" type="xs:string" minOccurs="1" maxOccurs="1"/>'
	cString	+=	'		<xs:element name="cnpj" type="xs:long" minOccurs="1" maxOccurs="1"/>'
	cString	+=	'		<xs:element name="nome_responsavel" type="xs:string" minOccurs="1" maxOccurs="1"/>'
	cString	+=	'		<xs:element name="cargo" type="xs:string" minOccurs="0" maxOccurs="1"/>'
	cString	+=	'		<xs:element name="email" type="xs:string" minOccurs="1" maxOccurs="1"/>'
	cString	+=	'		<xs:element name="telefone" type="xs:string" minOccurs="0" maxOccurs="1"/>'
	cString	+=	'	</xs:sequence>'
	cString	+=	'	</xs:complexType>'
	cString	+=	'	<xs:complexType name="CargaFornecedoresTypeResponse">'
	cString	+=	'	<xs:sequence>'
	cString	+=	'		<xs:element name="cnpj" type="xs:long" minOccurs="1" maxOccurs="1"/>'
	cString	+=	'		<xs:element name="data" type="xs:dateTime" minOccurs="1" maxOccurs="1"/>'
	cString	+=	'		<xs:element name="status" type="xs:string" minOccurs="1" maxOccurs="1"/>'
	cString	+=	'		<xs:element name="num_transacao" type="xs:string" minOccurs="1" maxOccurs="1"/>'
	cString	+=	'	</xs:sequence>'
	cString	+=	'	</xs:complexType>'
	cString	+=	'</xs:schema>'

Elseif cType == 'XSD_AUT_DEC_AQU'
	cString +=	'<?xml version="1.0" encoding="UTF-8"?>'
	cString +=	'<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema"'
	cString +=	'	targetNamespace="http://www.tarea.com.br/InovarAuto/AutoDeclaracao"'
	cString +=	'	xmlns:tns="http://www.tarea.com.br/InovarAuto/AutoDeclaracao"'
	cString +=	'	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'
	cString +=	'	elementFormDefault="qualified"
	cString +=	'	attributeFormDefault="unqualified" xmlns:xsd="http://www.w3.org/2001/XMLSchema">'
	cString +=	'	<xs:element name="AutoDeclaracao" type="tns:AutoDeclaracaoType"/> 
	cString +=	'	<xs:element name="AutoDeclaracaoResponse" type="tns:AutoDeclaracaoTypeResponse"/>
	cString +=	'	<xs:complexType name="AutoDeclaracaoType">'
	cString +=	'		<xs:sequence>'
	cString +=	'			<xs:element name="retificadora" type="xs:boolean" minOccurs="1" maxOccurs="1"/>'
	cString +=	'			<xs:element name="declarante" type="tns:DeclaranteType" minOccurs="1" maxOccurs="unbounded"/>'
	cString +=	'		</xs:sequence>'
	cString +=	'	</xs:complexType>
	cString +=	'	<xs:complexType name="DeclaranteType">'
	cString +=	'		<xs:sequence>'
	cString +=	'			<xs:element name="tipo_declarante" type="tns:TipoDeclaranteType" minOccurs="1" maxOccurs="1"/>'
	cString +=	'			<xs:element name="razao_social" type="xs:string" minOccurs="1" maxOccurs="1"/>'
	cString +=	'			<xs:element name="cnpj" type="xs:long" minOccurs="1" maxOccurs="1"/>'
	cString +=	'			<xs:element name="matriz" type="xs:boolean" minOccurs="1" maxOccurs="1"/>'
	cString +=	'			<xs:element name="operacao" type="tns:OperacaoType" minOccurs="1" maxOccurs="unbounded"/>'
	cString +=	'		</xs:sequence>'
	cString +=	'	</xs:complexType>
	cString +=	'	<xs:complexType name="OperacaoType">
	cString +=	'		<xs:sequence>
	cString +=	'			<xs:element name="natureza_operacao" type="tns:NaturezaOperacaoType" minOccurs="1" maxOccurs="1"/>'
	cString +=	'			<xs:element name="empresa" type="tns:EmpresaType" minOccurs="1" maxOccurs="1"/>'
	cString +=	'			<xs:element name="mes_ref" type="tns:MesReferenciaType" minOccurs="1" maxOccurs="1"/>'
	cString +=	'			<xs:element name="ano_ref" type="xs:integer" minOccurs="1" maxOccurs="1"/>'
	cString +=	'			<xs:element name="vl_total_notas" type="xs:double" minOccurs="1" maxOccurs="1"/>'
	cString +=	'			<xs:element name="vl_parc_dedutivel" type="xs:double" minOccurs="0" maxOccurs="1"/>'
	cString +=	'		</xs:sequence>'
	cString +=	'	</xs:complexType>'
	cString +=	'	<xs:complexType name="EmpresaType">
	cString +=	'		<xs:sequence>'
	cString +=	'			<xs:element name="razao_social" type="xs:string" minOccurs="1" maxOccurs="1"/>'
	cString +=	'			<xs:element name="cnpj" type="xs:long" minOccurs="1" maxOccurs="1"/>'
	cString +=	'		</xs:sequence>'
	cString +=	'	</xs:complexType>'
	cString +=	'	<xs:complexType name="AutoDeclaracaoTypeResponse">'
	cString +=	'		<xs:sequence>
	cString +=	'			<xs:element name="cnpj" type="xs:long" minOccurs="1" maxOccurs="1"/>'
	cString +=	'			<xs:element name="data" type="xs:dateTime" minOccurs="1" maxOccurs="1"/>'
	cString +=	'			<xs:element name="status" type="xs:string" minOccurs="1" maxOccurs="1"/>'
	cString +=	'			<xs:element name="num_transacao" type="xs:string" minOccurs="1" maxOccurs="1"/>'
	cString +=	'		</xs:sequence>'
	cString +=	'	</xs:complexType>'
	cString +=	'	<xs:simpleType name="NaturezaOperacaoType">'
	cString +=	'		<xs:annotation>'
	cString +=	'			<xs:documentation>Indica se trata-se de uma operacao de [A]quisicao ou [V]enda.</xs:documentation>'
	cString +=	'		</xs:annotation>'
	cString +=	'		<xs:restriction base="xs:string">'
	cString +=	'			<xs:enumeration value="A"/>'
	cString +=	'			<xs:enumeration value="V"/>'
	cString +=	'		</xs:restriction>'
	cString +=	'	</xs:simpleType>
	cString +=	'	<xs:simpleType name="TipoDeclaranteType">'
	cString +=	'		<xs:annotation>'
	cString +=	'			<xs:documentation>Indica se o arquivo e de um [F]ornecedor ou [M]ontadora.</xs:documentation>'
	cString +=	'		</xs:annotation>'
	cString +=	'		<xs:restriction base="xs:string">'
	cString +=	'			<xs:enumeration value="F"/>'
	cString +=	'			<xs:enumeration value="M"/>'
	cString +=	'		</xs:restriction>'
	cString +=	'	</xs:simpleType>'
	cString +=	'	<xs:simpleType name="MesReferenciaType">'
	cString +=	'		<xs:annotation>'
	cString +=	'			<xs:documentation>Valores validos para o mes de referencia.</xs:documentation>'
	cString +=	'		</xs:annotation>'
	cString +=	'		<xs:restriction base="xs:integer">'
	cString +=	'			<xs:minInclusive value="1"/>'
	cString +=	'			<xs:maxInclusive value="12"/>'
	cString +=	'		</xs:restriction>'
	cString +=	'	</xs:simpleType>'
	cString +=	'</xs:schema>'	
																										
Elseif cType == 'XSD_CONS_DEC_VEN'
	cString +=	'<?xml version="1.0" encoding="UTF-8"?>'
	cString +=	'<xs:schema'
	cString +=	'	xmlns:xs="http://www.w3.org/2001/XMLSchema"'
	cString +=	'	targetNamespace="http://www.tarea.com.br/InovarAuto/MencaoCNPJVendas"'
	cString +=	'	xmlns:tns="http://www.tarea.com.br/InovarAuto/MencaoCNPJVendas"'
	cString +=	'	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'
	cString +=	'	elementFormDefault="qualified"'
	cString +=	'	attributeFormDefault="unqualified">'
	cString +=	'	<xs:element name="Vendas" type="tns:VendasType"/>'
	cString +=	'	<xs:element name="VendasResponse" type="tns:VendasTypeResponse"/>'
	cString +=	'	<xs:complexType name="VendasType">
	cString +=	'		<xs:sequence>'
	cString +=	'			<xs:element name="empresa" type="tns:EmpresaType" minOccurs="1" maxOccurs="unbounded"/>'
	cString +=	'			<xs:element name="dt_geracao" type="xs:dateTime" minOccurs="1" maxOccurs="1"/>'
	cString +=	'		</xs:sequence>'
	cString +=	'	</xs:complexType>'
	cString +=	'	<xs:complexType name="OperacaoType">'
	cString +=	'		<xs:sequence>'
	cString +=	'			<xs:element name="razao_social" type="xs:string" minOccurs="1" maxOccurs="1"/>'
	cString +=	'			<xs:element name="cnpj" type="xs:long" minOccurs="1" maxOccurs="1"/>'
	cString +=	'			<xs:element name="mes_ref" type="xs:integer" minOccurs="1" maxOccurs="1"/>'
	cString +=	'			<xs:element name="ano_ref" type="xs:integer" minOccurs="1" maxOccurs="1"/>'
	cString +=	'			<xs:element name="vl_total_notas" type="xs:double" minOccurs="1" maxOccurs="1"/>'
	cString +=	'			<xs:element name="vl_parc_dedutivel" type="xs:double" minOccurs="1" maxOccurs="1"/>'
	cString +=	'		</xs:sequence>'
	cString +=	'	</xs:complexType>'
	cString +=	'	<xs:complexType name="EmpresaType">'
	cString +=	'		<xs:sequence>'
	cString +=	'			<xs:element name="razao_social" type="xs:string" minOccurs="1" maxOccurs="1"/>'
	cString +=	'			<xs:element name="cnpj" type="xs:long" minOccurs="1" maxOccurs="1"/>'
	cString +=	'			<xs:element name="matriz" type="xs:boolean" minOccurs="1" maxOccurs="1"/>'
	cString +=	'			<xs:element name="operacao" type="tns:OperacaoType" minOccurs="1" maxOccurs="unbounded"/>'
	cString +=	'		</xs:sequence>'
	cString +=	'	</xs:complexType>'
	cString +=	'	<xs:complexType name="VendasTypeResponse">'
	cString +=	'		<xs:sequence>'
	cString +=	'			<xs:element name="cnpj" type="xs:long" minOccurs="1" maxOccurs="1"/>'
	cString +=	'			<xs:element name="data" type="xs:dateTime" minOccurs="1" maxOccurs="1"/>'
	cString +=	'			<xs:element name="status" type="xs:string" minOccurs="1" maxOccurs="1"/>'
	cString +=	'			<xs:element name="num_transacao" type="xs:string" minOccurs="1" maxOccurs="1"/>'
	cString +=	'		</xs:sequence>'
	cString +=	'	</xs:complexType>'
	cString +=	'</xs:schema>'

Elseif cType == 'XSD_NAO_INF_VEN'
	cString +=	'<?xml version="1.0" encoding="UTF-8"?>'
	cString +=	'<xs:schema'
	cString +=	'	xmlns:xs="http://www.w3.org/2001/XMLSchema"'
	cString +=	'	targetNamespace="http://www.tarea.com.br/InovarAuto/NaoInformacaoVendas"'
	cString +=	'	xmlns:tns="http://www.tarea.com.br/InovarAuto/NaoInformacaoVendas"'
	cString +=	'	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'
	cString +=	'	elementFormDefault="qualified"'
	cString +=	'	attributeFormDefault="unqualified">'
	cString +=	'	<xs:element name="NaoInformacaoVendas" type="tns:NaoInformacaoVendasType"/>
	cString +=	'	<xs:element name="NaoInformacaoVendasResponse" type="tns:NaoInformacaoVendasTypeResponse"/>'
	cString +=	'	<xs:complexType name="NaoInformacaoVendasType">'
	cString +=	'		<xs:sequence>'
	cString +=	'			<xs:element name="empresa" type="tns:EmpresaType" minOccurs="1" maxOccurs="unbounded"/>'
	cString +=	'			<xs:element name="dt_geracao" type="xs:dateTime" minOccurs="1" maxOccurs="1"/>'
	cString +=	'		</xs:sequence>'
	cString +=	'	</xs:complexType>
	cString +=	'	<xs:complexType name="OperacaoType">'
	cString +=	'		<xs:sequence>'
	cString +=	'			<xs:element name="razao_social" type="xs:string" minOccurs="1" maxOccurs="1"/>'
	cString +=	'			<xs:element name="cnpj" type="xs:long" minOccurs="1" maxOccurs="1"/>'
	cString +=	'			<xs:element name="mes_ref" type="tns:MesReferenciaType" minOccurs="1" maxOccurs="1"/>'
	cString +=	'			<xs:element name="ano_ref" type="xs:integer" minOccurs="1" maxOccurs="1"/>'
	cString +=	'			<xs:element name="vl_total_nota" type="xs:double" minOccurs="1" maxOccurs="1"/>'
	cString +=	'		</xs:sequence>'
	cString +=	'	</xs:complexType>'
	cString +=	'	<xs:complexType name="EmpresaType">'
	cString +=	'		<xs:sequence>'
	cString +=	'			<xs:element name="razao_social" type="xs:string" minOccurs="1" maxOccurs="1"/>'
	cString +=	'			<xs:element name="cnpj" type="xs:long" minOccurs="1" maxOccurs="1"/>'
	cString +=	'			<xs:element name="matriz" type="xs:boolean" minOccurs="1" maxOccurs="1"/>'
	cString +=	'			<xs:element name="operacao" type="tns:OperacaoType" minOccurs="1" maxOccurs="unbounded"/>'
	cString +=	'		</xs:sequence>'
	cString +=	'	</xs:complexType>'
	cString +=	'	<xs:complexType name="NaoInformacaoVendasTypeResponse">'
	cString +=	'		<xs:sequence>'
	cString +=	'			<xs:element name="cnpj" type="xs:long" minOccurs="1" maxOccurs="1"/>'
	cString +=	'			<xs:element name="data" type="xs:dateTime" minOccurs="1" maxOccurs="1"/>'
	cString +=	'			<xs:element name="status" type="xs:string" minOccurs="1" maxOccurs="1"/>'
	cString +=	'			<xs:element name="num_transacao" type="xs:string" minOccurs="1" maxOccurs="1"/>'
	cString +=	'		</xs:sequence>'
	cString +=	'	</xs:complexType>'
	cString +=	'	<xs:simpleType name="MesReferenciaType">'
	cString +=	'	<xs:annotation>'
	cString +=	'		<xs:documentation>Valores validos para o mes de referencia.</xs:documentation>
	cString +=	'	</xs:annotation>'
	cString +=	'	<xs:restriction base="xs:integer">'
	cString +=	'		<xs:minInclusive value="1"/>'
	cString +=	'		<xs:maxInclusive value="12"/>'
	cString +=	'	</xs:restriction>'
	cString +=	'	</xs:simpleType>'
	cString +=	'</xs:schema>'
Endif	
Return cString

//-------------------------------------------------------------------
/*/{Protheus.doc} X073GetQry

Funcao que executa os filtros para processamento da rotina

@param	nEvent,number,Evento:<BR>1 - Criacao de filtro e workarea de query<BR>2 - Fechamento da workarea da query.
@param	aParam,Array,Parametros para utilizacao nos filtros que serao executados
@param	cQuery,String,Identificacao do Filtro que deve ser executado
@param	cAliasQry,String,Alias que sera retornado quando evento 1 e que sera fechado quando evento 2.

@return lRet,logico,Quando evento 1, indica se possui registros no filtro executado

@author Luccas Curcio 
@since 11/04/2014
@version 11.0

/*/
//-------------------------------------------------------------------
Static Function X073GetQry( nEvent , aParam , cQuery , cAliasQry, lRet )
Local cSelect:= ""
Local cFrom  := ""
Local cWhere := ""
Local cGroup := ""
Local cOrder := ""
Default	lRet := .T.

If nEvent == 1

	If cQuery == "FORNECEDOR"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³                   SELECT                    ³
		//³---------------------------------------------³
		//³TABELA SFT-> SOMA DO CAMPO FT_VALCONT        ³
		//³             SOMA DO CAMPO FT_QUANT          ³
		//³             FT_PRODUTO(USADO NO AGRUPAMENTO)³
		//³TABELA SA1-> A1_NOME   (USADO NO AGRUPAMENTO)³
		//³             A1_CGC    (USADO NO AGRUPAMENTO)³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cSelect	:=	"SUM( SFT.FT_VALCONT ) AS FT_VALCONT , SUM( SFT.FT_QUANT ) AS FT_QUANT , FT_PRODUTO , SA1.A1_NOME AS A1_NOME , SA1.A1_CGC AS A1_CGC, SA1.A1_COD, A1_LOJA, SFT.FT_NFISCAL AS FT_NFISCAL, SFT.FT_SERIE AS FT_SERIE, SFT.FT_ITEM AS FT_ITEM "
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³                   FROM                      ³
		//³---------------------------------------------³
		//³TABELA SFT ->ITEM DO LIVRO FISCAL            ³
		//³TABELA SD2 ->ITEM DO DOCTO SAIDA ( JOIN )    ³
		//³TABELA SF4 ->TES                 ( JOIN )    ³
		//³TABELA SA1 ->CADASTRO DE CLIENTE ( JOIN )    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cFrom	:=	RetSQLName( "SFT" ) + " SFT "
		cFrom	+=	"JOIN " + RetSQLName( "SD2" ) + " SD2 ON SD2.D2_FILIAL = '" + xFilial( "SD2" ) + "' AND SD2.D2_DOC = SFT.FT_NFISCAL AND SD2.D2_SERIE = SFT.FT_SERIE AND SD2.D2_ITEM =SFT.FT_ITEM AND SD2.D2_CLIENTE = SFT.FT_CLIEFOR AND SD2.D2_LOJA = SFT.FT_LOJA AND SD2.D_E_L_E_T_ = '' "
		cFrom	+=	"JOIN " + RetSQLName( "SF4" ) + " SF4 ON SF4.F4_FILIAL = '" + xFilial( "SF4" ) + "' AND SF4.F4_CODIGO = SD2.D2_TES AND SF4.F4_INOVAUT = '1' AND SF4.D_E_L_E_T_ = '' "
		cFrom	+=	"JOIN " + RetSQLName( "SA1" ) + " SA1 ON SA1.A1_FILIAL = '" + xFilial( "SA1" ) + "' AND SA1.A1_COD = SFT.FT_CLIEFOR AND SA1.A1_LOJA = SFT.FT_LOJA AND SA1.D_E_L_E_T_ = '' AND SA1.A1_INOVAUT = '1' "
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³                   WHERE                     ³
		//³---------------------------------------------³
		//³TABELA SFT-> FT_FILIAL                       ³
		//³             FT_ENTRADA (DENTRO PERIODO)     ³
		//³             FT_CFOP (SAIDAS)                ³
		//³             NOT D_E_L_E_T_                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cWhere	:=	"SFT.FT_FILIAL = '" + xFilial( "SFT" ) + "' AND "
		cWhere	+=	"SFT.FT_ENTRADA >= '" + DToS( aParam[1] ) + "' AND "
		cWhere	+=	"SFT.FT_ENTRADA <= '" + DToS( aParam[2] ) + "' AND "
		cWhere	+=	"SUBSTRING( SFT.FT_CFOP , 1 , 1 ) >= '5' AND SFT.FT_DTCANC = ' ' AND "
		cWhere	+=	"SFT.D_E_L_E_T_ = ''"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³                  GROUP BY                   ³
		//³---------------------------------------------³
		//³             FT_PRODUTO                      ³
		//³TABELA SA1 ->A1_NOME                         ³
		//³             A1_CGC                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cGroup	:=	"GROUP BY FT_PRODUTO, A1_NOME, A1_CGC, SA1.A1_COD, SA1.A1_LOJA,FT_NFISCAL,FT_SERIE,FT_ITEM "
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³                  ORDER BY                   ³
		//³---------------------------------------------³
		//³TABELA SA1 -> A1_NOME                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cOrder	:=	"ORDER BY SA1.A1_CGC, SA1.A1_NOME"
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Define estrutura para execucao do BeginSQL   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSelect  := "%" + cSelect + "%" 
	cFrom    := "%" + cFrom   + "%" 
	cWhere   := "%" + cWhere  + cGroup + cOrder + "%"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Execucao do BeginSQL ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (TcSrvType()<>"AS/400")

		cAliasQry := GetNextAlias()

		BeginSql Alias cAliasQry
			SELECT 
				%Exp:cSelect%
			FROM 
				%Exp:cFrom%
			WHERE 
				%Exp:cWhere%
		EndSql
		
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se a query retornou algum registro  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lRet := ( cAliasQry )->( !Eof() )

Elseif nEvent == 2

	If Select( cAliasQry ) <> 0
		( cAliasQry )->( dbCloseArea() )
	EndIf

Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} X073XMLName

Funcao que retorna o nome do arquivo XML

@return cXMLName,String,Nome do arquivo XML

@author Luccas Curcio 
@since 11/04/2014
@version 11.0
/*/
//-------------------------------------------------------------------
Static Function X073XMLName(cFMonth,cFYear)
Local cXMLName := ""
Local aAreaSM0 := SM0->( GetArea() )

Default cFMonth:= StrZero( Month( MV_PAR01 ) , 2 )
Default cFYear := Str( Year( MV_PAR01 ) , 4 )

SM0->( dbGoTop ())
SM0->( dbSeek( cEmpAnt + MV_PAR03 ) )

If MV_PAR06 == 1
	//Autodeclaração de venda
	cXMLName := SM0->M0_CGC + '_V_' + cFMonth + '_' + cFYear + '.XML'
ElseIf MV_PAR06 == 2
	// Convite para fornecedores
	cXMLName := SM0->M0_CGC + '_CF_' + cFMonth + '_' + cFYear + '.XML'	
ElseIf MV_PAR06 == 3
	//Autodeclaração de Aquisição
	cXMLName := SM0->M0_CGC + '_A_' + cFMonth + '_' + cFYear + '.XML'
Endif

RestArea( aAreaSM0 )

Return cXMLName

//-------------------------------------------------------------------
/*/{Protheus.doc} X073IniRot

Funcao que faz as validacoes iniciais da rotina

@return lRet,logico,Indica se Validacoes ok ou nao

@author Luccas Curcio 
@since 11/04/2014
@version 11.0
/*/
//-------------------------------------------------------------------
Static Function X073IniRot()
Local lRet := .T.

If SA1->( FieldPos( "A1_INOVAUT" ) ) <= 0
	lRet := .F.
	MsgAlert( STR0013, STR0018 ) //"Não foi encontrado o campo A1_INOVAUT no Dicionário de Dados."###"Necessário execução do UPDFIS."
Endif

If SA2->( FieldPos( "A2_INOVAUT" ) ) <= 0
	lRet := .F.
	MsgAlert( STR0013, STR0025 ) //"Não foi encontrado o campo A2_INOVAUT no Dicionário de Dados."###"Necessário execução do UPDFIS."
Endif

If lRet .And. SD3->( FieldPos ( "D3_VLRPD" ) ) <= 0
	lRet := .F.
	MsgAlert( STR0015, STR0018 ) //"Não foi encontrado o campo D3_VLRPD no Dicionário de Dados."###"Necessário execução do UPDFIS."
Endif

If lRet .And. SF4->( FieldPos ( "F4_INOVAUT" ) ) <= 0
	lRet := .F.
	MsgAlert( STR0016, STR0018 ) //"Não foi encontrado o campo F4_INOVAUT no Dicionário de Dados."###"Necessário execução do UPDFIS."
Endif

If lRet .And. !AliasIndic("CLJ")
	lRet := .F.
	MsgAlert( STR0017, STR0018 ) //"Não foi encontrado a tabela de Apuração INOVAR-AUTO (CLJ) no Dicionário de Dados."###"Necessário execução do UPDFIS."
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} x073Conv    
Funcao que converte os caracteres com acento 
para a correta vizualizacao no XML

@param	cString,String, String a ser convertida

@author Fabio V. Santana
@since 29/10/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function x073Conv(cString)

Local cRet := ''
Local nI , nT := len(cString)
Local cChar

For nI := 1 to nT
	cChar := substr(cString,nI,1)
	If ASC(cChar) < 32 .Or. ASC(cChar) > 127
		cRet += '&#x'+x073ToHex(cChar)+';'
	ElseIf cChar == "&"
		cRet += '&#x'+x073ToHex(cChar)+';'
	Else
		cRet += cChar
	Endif
Next

Return cRet
//-------------------------------------------------------------------
/*/{Protheus.doc} x073ToHex    
Funcao que converte o caractere HEXADECIMAL

@parametros                      
cString - String a ser convertida

@author Fabio V. Santana
@since 29/10/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function x073ToHex(cChar)

Local hx := '0123456789ABCDEF'
Local n1,n2,nI
Local xRet := ''

For nI := 1 to len(cChar)
	nS := asc(substr(cChar,nI,1))
	n1 := Int(nS/16)
	n2 := nS-(n1*16)
	xRet += substr(hx,n1+1,1) + substr(hx,n2+1,1)
Next

Return xRet
//-------------------------------------------------------------------
/*/{Protheus.doc} X073MedEnt
Funcao que Grava media do valor importado para os produtos comprados
Executada apartir da funcao MATMedEnt (SIGACUS.PRW)

@param	cString,String,Mes a ser calculado
@param	cString,String,Ano a ser calculado
@param	cString,String,Range de produtos
@param	cString,String,Range de produtos

@author Fiscal
@since 06/11/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function X073MedEnt(cMes,cAno,cProdDe,cProdAte)
Local aAreaSD1   := SD1->(GetArea())
Local cQuery     := ""
Local cAlias     := GetNextAlias()
Local lExistII   := SD1->(FieldPos("D1_II")) > 0
Local lSigaEIC	:= (GetNewPar("MV_EASY",.F.)=="S") //Integracao com SIGAEIC - IMPORTACAO
Local cMVINVCFD1 := GetNewPar( "MV_INVCFD1" , "" )
Local lMVINVCFD1 := .T.
Local cTitulo    := " "
Local cMensagem  := " "
Local cHelp      := " " 

If !Empty(cMVINVCFD1) .And. (at(";",cMVINVCFD1)+at(",",cMVINVCFD1)+at("'",cMVINVCFD1)+at("\",cMVINVCFD1)>0)
               
	cTitulo   	:= STR0019 // "Parâmetro Inconsistente" 
	cMensagem 	:= STR0020 // "O parâmetro MV_INVCFD1 está com seu conteúdo é inválido, os CFOP's cadastrados não serão desconsiderados. " 
	cMensagem 	+= STR0021 // "Será necessário respeitar a solução proposta abaixo, para que as congurações do parâmetro surtam efeito no processamento." 
	cHelp    	:= STR0022 // "O parâmetro MV_INVCFD1 na tabela SX6 deverá seguir a seguinte estrutura: " 
	cHelp 		+= STR0023 // "/CFOP/ Ex: /1101/1102/  Para que os CFOP's de entrada cadastrados sejam desconsiderados da apuração"
	cHelp 		+= STR0024 // "Para maiores referências, consultar a documentação que acompanha a rotina."
	
	lMVINVCFD1 := .F.
	
	xMagHelpFis(cTitulo,cMensagem,cHelp)   
              
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Query para retornar todos as entradas de MP do Periodo, agrupadas por Codigo de Produto ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT SUM(SD1.D1_QUANT) AS QUANTIDADE, "
cQuery += "SUM("
cQuery += "CASE WHEN SD1.D1_CF IN ('3101','3102','3126','3127') THEN (SD1.D1_TOTAL+SD1.D1_VALFRE+SD1.D1_SEGURO) "
cQuery += "ELSE ((SD1.D1_TOTAL+SD1.D1_VALFRE+SD1.D1_SEGURO)-(SD1.D1_VALIPI)) END "
cQuery += "*(CASE WHEN SUBSTRING(SD1.D1_CLASFIS,1,1) = '5' THEN 0 "
cQuery += "WHEN SUBSTRING(SD1.D1_CLASFIS,1,1) IN ('1','2','6','7','8',' ') AND SD1.D1_CF NOT IN ('3101','3102','3126','3127') THEN 1 "
cQuery += "WHEN SUBSTRING(SD1.D1_CLASFIS,1,1) IN ('3','4') AND SD1.D1_CF NOT IN ('3101','3102','3126','3127') THEN 0.5 "
cQuery += "WHEN SUBSTRING(SD1.D1_CLASFIS,1,1) IN ('0','5') AND SD1.D1_CF NOT IN ('3101','3102','3126','3127') THEN 0 "
cQuery += "ELSE 1 END)) AS VI, "
cQuery += "SD1.D1_COD "
cQuery += "FROM "+RetSqlName("SD1")+" SD1 JOIN "+RetSqlName("SF4")+" SF4 ON SF4.F4_FILIAL = '"+xFilial('SF4')+"' "
cQuery += "AND SF4.F4_CODIGO = SD1.D1_TES "
cQuery += "AND SF4.D_E_L_E_T_ = '' "
cQuery += "WHERE SD1.D1_FILIAL = '"+xFilial('SD1')+"' AND SUBSTRING(SD1.D1_DTDIGIT,1,6) = '"+cAno+cMes
cQuery += "' AND SD1.D_E_L_E_T_ = '' AND SD1.D1_COD >= '"+cProdDe+"' AND SD1.D1_COD <= '"+cProdAte+"'"+" AND SD1.D1_TIPO = 'N' "

If !Empty(cMVINVCFD1) .And. lMVINVCFD1 
	cQuery += "AND SD1.D1_CF NOT IN " + FormatIn(cMVINVCFD1,"/") + " "
EndIf

cQuery += "GROUP BY SD1.D1_COD"
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava todos os valores encontrados para o periodo na tabela                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While !(cAlias)->(Eof())
	DbSelectArea(cTBProc)
	(cTBProc)->(DbSetOrder(1))
	If !MsSeek(xFilial(cTBProc)+(cAlias)->D1_COD + cMes + cAno)
		MATGrvTAB((cAlias)->D1_COD,cMes+cAno,((cAlias)->(VI)/(cAlias)->(QUANTIDADE)),"C",.T.)
	Else
		MATGrvTAB((cAlias)->D1_COD,cMes+cAno,((cAlias)->(VI)/(cAlias)->(QUANTIDADE)),"C",.F.)
	EndIf
	(cAlias)->(DbSkip())
EndDo

(cAlias)->(DbCloseArea())
RestArea(aAreaSD1)

Return

/*/{Protheus.doc} X073WrtStr
Funcao responsavel por efetuar a gravacao de String em um arquivo texto XML
@param nHandle  -> Array com os campos de gravacao conforme registro
       cString  -> String contendo info para geracao do arquivo
            
@return NIL

@author Flavio Luiz Vicco
@since 09/12/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function X073WrtStr( nHandle , cString )

Local nRet := 0

Default cString := Nil

If cString != Nil .And. !Empty( cString )
	nRet := FWrite( nHandle , cString , Len( cString ) )
EndIf

//-- Se houver erro na gravacao, nao limpo a variavel
If nRet != -1
	cString := ""
EndIf

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} X073GetDev

Função para retornar as devoluções de venda

@return cAliasDev

@author Henrique Fabiano
@since 03/02/2015
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function X073GetDev(aParam, cDev)

Local aCampos	:= {}
Local cAliasDev := ""
Local cQuery	:= ""

If (TcSrvType()<>"AS/400")
	cAliasDev := GetNextAlias()

/*
	BeginSql Alias cAliasDev
		SELECT
			SFT.FT_NFORI, SFT.FT_CLIEFOR, SFT.FT_LOJA, SUM(SFT.FT_VALCONT) AS FT_VALCONT, SUM(SFT.FT_QUANT) AS FT_QUANT
		FROM
			%table:SFT% SFT
		JOIN %table:SA1% SA1 ON
			SA1.A1_FILIAL = %xFilial:SA1% AND
			SA1.A1_COD = SFT.FT_CLIEFOR AND
			SA1.A1_LOJA = SFT.FT_LOJA AND
			SA1.A1_INOVAUT = '1' AND
			SA1.%NotDel%
		JOIN %table:SD2% SD2 ON
			SD2.D2_FILIAL = %xFilial:SD2% AND
			SD2.D2_DOC = SFT.FT_NFORI AND
			SD2.D2_SERIE = SFT.FT_SERORI AND
			SD2.D2_ITEM = SFT.FT_ITEMORI AND
			SD2.D2_CLIENTE = SFT.FT_CLIEFOR AND
			SD2.D2_LOJA = SFT.FT_LOJA AND
			SD2.D2_EMISSAO<= %Exp:aParam[2]% AND
			SUBSTRING( SD2.D2_CF , 1 , 1 ) >= '5' AND
			SD2.%NotDel%
		JOIN %table:SF4% SF4 ON
			SF4.F4_FILIAL = %xFilial:SF4% AND
			SF4.F4_CODIGO = SD2.D2_TES AND
			SF4.F4_INOVAUT = '1' AND
			SF4.%NotDel%
		WHERE
			SFT.FT_FILIAL = %xFilial:SFT% AND 
			SFT.FT_TIPOMOV = 'E' AND
			SFT.FT_TIPO = 'D' AND
			SFT.FT_EMISSAO >= %Exp:aParam[1]% AND SFT.FT_EMISSAO <= %Exp:aParam[2]% AND
			SFT.FT_DTCANC = '' AND
			SFT.%NotDel%
		GROUP BY SFT.FT_NFORI, SFT.FT_CLIEFOR, SFT.FT_LOJA
	EndSql
*/
	//Quando executada mais de uma vez (múltiplas filiais) a consulta ao banco de dados (query) no formato
	//embedded sql não era convertida para o padrão Oracle ocasionando o erro reportado na ISSUE DSERFIS1-3585.
	cQuery := "	SELECT	SFT.FT_NFORI	, " + CRLF
	cQuery += "			SFT.FT_CLIEFOR	, " + CRLF
	cQuery += "			SFT.FT_LOJA		, " + CRLF
	cQuery += "			SUM(SFT.FT_VALCONT)	AS FT_VALCONT	, " + CRLF
	cQuery += "			SUM(SFT.FT_QUANT)	AS FT_QUANT " + CRLF
	cQuery += " FROM " + RetSqlName('SFT') + " SFT "  + CRLF
	cQuery += " JOIN " + RetSqlName('SA1') + " SA1 ON "	 + CRLF
	cQuery += " 		SA1.A1_FILIAL	=	'" + xFilial('SA1') + "'" + CRLF
	cQuery += "		AND SA1.A1_COD		=	SFT.FT_CLIEFOR "	+ CRLF
	cQuery += "		AND SA1.A1_LOJA		=	SFT.FT_LOJA"		+ CRLF
	cQuery += "		AND SA1.A1_INOVAUT	=	'1' "				+ CRLF
	cQuery += "		AND	SA1.D_E_L_E_T_	=	''  "				+ CRLF
	cQuery += " JOIN " + RetSqlName('SD2') + " SD2 ON " 		+ CRLF
	cQuery += " 		SD2.D2_FILIAL	= 	'" + xFilial('SD2') + "'" + CRLF
	cQuery += "		AND	SD2.D2_DOC		= 	SFT.FT_NFORI	"	+ CRLF
	cQuery += "		AND	SD2.D2_SERIE	= 	SFT.FT_SERORI	"	+ CRLF
	cQuery += "		AND	SD2.D2_ITEM		= 	SFT.FT_ITEMORI	"	+ CRLF
	cQuery += "		AND	SD2.D2_CLIENTE	= 	SFT.FT_CLIEFOR	"	+ CRLF
	cQuery += "		AND	SD2.D2_LOJA		= 	SFT.FT_LOJA		"	+ CRLF
	cQuery += "		AND	SD2.D2_EMISSAO	<= '" + aParam[2] + "'" + CRLF
	cQuery += "		AND	SUBSTRING( SD2.D2_CF , 1 , 1 ) >= '5' "	+ CRLF 
	cQuery += "		AND SD2.D_E_L_E_T_	=	'' "				+ CRLF
	cQuery += " JOIN " + RetSqlName('SF4') + " SF4 ON "			+ CRLF
	cQuery += " 		SF4.F4_FILIAL	=	'" + xFilial('SF4') + "'" + CRLF
	cQuery += "		AND	SF4.F4_CODIGO	=	SD2.D2_TES		"	+ CRLF
	cQuery += "		AND	SF4.F4_INOVAUT	=	'1'	"				+ CRLF
	cQuery += "		AND	SF4.D_E_L_E_T_	=	''  "				+ CRLF
	cQuery += " WHERE	SFT.FT_FILIAL	=	'" + xFilial('SFT') + "'"
	cQuery += "		AND	SFT.FT_TIPOMOV	=	'E' "				+ CRLF
	cQuery += "		AND	SFT.FT_TIPO		=	'D' "				+ CRLF
	cQuery += "		AND	SFT.FT_EMISSAO	>=	'" + aParam[1] + "'"+ CRLF
	cQuery += "		AND SFT.FT_EMISSAO	<=	'" + aParam[2] + "'"+ CRLF
	cQuery += "		AND	SFT.FT_DTCANC	=	''  " 				+ CRLF
	cQuery += "		AND	SFT.D_E_L_E_T_	=	''  "				+ CRLF	
	cQuery += "	GROUP BY SFT.FT_NFORI, SFT.FT_CLIEFOR, SFT.FT_LOJA " + CRLF
	
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasDev,.F.,.T.)
 
Endif 
	 
AADD(aCampos,{"FT_VALCONT","N",TamSX3("FT_VALCONT")[1],2})
AADD(aCampos,{"FT_QUANT","N",TamSX3("FT_QUANT")[1],0})
AADD(aCampos,{"A1_COD","C",TamSX3("A1_COD")[1],0})
AADD(aCampos,{"A1_LOJA","C",TamSX3("A1_LOJA")[1],0})
AADD(aCampos,{"D2_DOC","C",TamSX3("D2_DOC")[1],0})

cDev := CriaTrab(aCampos)
dbUseArea(.T.,__LocalDriver, cDev,,.T.,.F.)
IndRegua(cDev,cDev,"A1_COD+A1_LOJA")
DbSelectArea(cDev)
DbSetOrder(1)

Do While !(cAliasDev)->(Eof())
    If (cDev)->(DbSeek((cAliasDev)->FT_CLIEFOR+(cAliasDev)->FT_LOJA))
       RecLock(cDev,.F.)
	    (cDev)->FT_VALCONT+= (cAliasDev)->FT_VALCONT
	    (cDev)->FT_QUANT  += (cAliasDev)->FT_QUANT
	    (cDev)->A1_COD    += (cAliasDev)->FT_CLIEFOR
	    (cDev)->A1_LOJA   += (cAliasDev)->FT_LOJA
	    (cDev)->D2_DOC    += (cAliasDev)->FT_NFORI
	    MSUNLOCK(cDev)
    Else
      RecLock(cDev,.T.)
	    (cDev)->FT_VALCONT:= (cAliasDev)->FT_VALCONT
	    (cDev)->FT_QUANT  := (cAliasDev)->FT_QUANT
	    (cDev)->A1_COD    := (cAliasDev)->FT_CLIEFOR
	    (cDev)->A1_LOJA   := (cAliasDev)->FT_LOJA
	    (cDev)->D2_DOC    := (cAliasDev)->FT_NFORI
	    MSUNLOCK(cDev)
   EndIf
   (cAliasDev)->(dbSkip())
EndDo

(cAliasDev)->(DbCloseArea())

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} X073ConvF
Funcao responsavel pela montagem do arquivo XML do Convite para Fornecedores
@param nHandle  -> Array com os campos de gravacao conforme registro
       cString  -> String contendo info para geracao do arquivo
            
@return NIL

@author Cleber Maldonado
@since 31/02/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function X073ConvF()
Local nHandle		:= 0
Local lAbort		:= .F.
Local cXML			:= ""
Local cFrom			:= ""
Local cSelect		:= ""
Local cWhere		:= ""
Local cAliasQry		:= ""
Local cError		:= ""
Local cWarning		:= ""
Local cFile			:= ""
Local cArq      	:= Nil
Local cStartPath	:= Nil
Local dDataDe		:= MV_PAR01
Local dDataAte		:= MV_PAR02
Local cFilMat		:= MV_PAR03
Local cEndPath		:= AllTrim(MV_PAR05)
Local cTpXML		:= Alltrim(Str(MV_PAR06))
Local cErroXML		:= "Falha ao gerar o objeto XML"
Local cWarnXML		:= "O arquivo XML não está de acordo com o Schema"
Local cPathSchema	:= GetNewPar( "MV_INOVSCH" , "" ) + GetNewPar( "MV_INOVXSC" , "" ) + ".XSD"

cSelect	+=	"%SA2.A2_NREDUZ, SA2.A2_NOME, SA2.A2_CGC, SA2.A2_EMAIL, SA2.A2_TEL, SA2.A2_NOMRESP, SA2.A2_CARGO, SA2.A2_DTCONV%"
cFrom	+=	"%" + RetSQLName( "SA2" ) + " SA2 " +"%"
		cWhere  += "%"
		cWhere	+=	"SA2.A2_FILIAL = '" + xFilial( "SA2" ) + "' AND "
		cWhere	+=	"SA2.A2_INOVAUT = '3'" + " AND "
		cWhere  +=  "SA2.A2_DTCONV IS NOT NULL AND "
		cWhere	+=	"SA2.D_E_L_E_T_ = ''" + "%"

	If (TcSrvType()<>"AS/400")

		cAliasQry := GetNextAlias()

		BeginSql Alias cAliasQry
			SELECT 
				%Exp:cSelect%
			FROM 
				%Exp:cFrom%
			WHERE 
				%Exp:cWhere%
		EndSql
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se a query retornou algum registro  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lRet := ( cAliasQry )->( !Eof() )

	If lRet
  		cXML	+=	'<car:CargaFornecedores xmlns:car="http://www.tarea.com.br/InovarAuto/CargaFornecedores">'
		cXML	+=	'<car:razao_social>'+Alltrim(SM0->M0_NOMECOM)+'</car:razao_social>'
		cXML	+=	'<car:cnpj>'+Alltrim(SM0->M0_CGC)+'</car:cnpj>'

		While !(cAliasQry)->( Eof() )
			cXML	+=	'<car:fornecedores>'   
			cXML	+=	'	<car:nome_fantasia>'+AllTrim((cAliasQry)->A2_NREDUZ)+'</car:nome_fantasia>'
			cXML	+=	'	<car:razao_social>'+AllTrim((cAliasQry)->A2_NOME)+'</car:razao_social>'
			cXML	+=	'	<car:cnpj>'+AllTrim((cAliasQry)->A2_CGC)+'</car:cnpj>'
			cXML	+=	'	<car:nome_responsavel>'+AllTrim((cAliasQry)->A2_NOMRESP)+'</car:nome_responsavel>'
			cXML	+=	'	<car:cargo>'+AllTrim((cAliasQry)->A2_CARGO)+'</car:cargo>'
			cXML	+=	'	<car:email>'+Alltrim((cAliasQry)->A2_EMAIL)+'</car:email>'
			cXML 	+=	'	<car:telefone>'+AllTrim((cAliasQry)->A2_TEL)+'</car:telefone>'
			cXML 	+=	'</car:fornecedores>'
			(cAliasQry)->( dbSkip() )
		End
		cXML	+=	'</car:CargaFornecedores>'
		IncProc( STR0011 )	//"Validando Arquivo XML"
		oXML := XMLParser( cXML , '_' , @cErroXML , @cWarnXML )
		Do Case
			Case oXML == Nil
				MsgStop(	STR0002 + CRLF +;				//"Falha ao gerar Objeto XML!"
							STR0003 + cErroXML + CRLF +;	//"Erro: " ####
							STR0004 + cWarnXML )			//"Advertência: " ####
				lAbort	:=	.T.
			Case !( XMLSVldSch( cXML , cPathSchema , @cError , @cWarning ) )
        	
				MsgStop(	STR0005 + CRLF +;				//"O arquivo XML gerado não está de acordo com o Schema!"
							STR0003 + cError + CRLF +;		//"Erro: " ####
							STR0004 + cWarning )			//"Advertência: " ####
				lAbort := .T.
		End Case
	Else
		Aviso("Sem Movimento","Não houve movimento no período, ou na Filial selecionada. " + CRLF + CRLF + "Nenhum XML será gerado.",{"Fechar"},3)
		lAbort := .T.
	EndIf
	
	If !lAbort
		IncProc( STR0012 )	//"Gerando Arquivo XML"
		cFile := X073XMLName(StrZero(Month( dDataDe ),2),Str(Year( dDataDe ),4))
		If xFunGetDir( 1 , , @cArq , @cStartPath , @nHandle )
			WrtStrTxt( nHandle , cXML )
			If xFunGetDir( 2 , , , , nHandle )
				If xFunGetDir( 3 , cEndPath + cFile , cArq , cStartPath )
					MsgInfo( STR0006 + cFile + STR0007 + cEndPath )	//"O arquivo " #### " foi criado com sucesso no diretório " ####
					DbSelectArea(cAliasQry)
					(cAliasQry)->(DbGoTop())
					DbSelectArea("SA2")
					dbSetOrder(3)
					While !(cAliasQry)->(EOF())
						If MsSeek(xFilial("SA2")+(cAliasQry)->A2_CGC)
							Reclock("SA2",.F.)
							A2_DTCONV := DDATABASE
							MsUnlock()
						Endif
						(cAliasQry)->(dbSkip())
					End
				Endif
			Endif
		Endif
	Endif
(cAliasQry)->(DbCloseArea())
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} X073AquisF
Funcao responsavel pela montagem do arquivo XML de aquisição.
@param nHandle  -> Array com os campos de gravacao conforme registro
       cString  -> String contendo info para geracao do arquivo
            
@return NIL

@author Cleber Maldonado
@since 31/02/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function X073AquisF()
Local nHandle		:= 0
Local lAbort		:= .F.
Local cXML			:= ""
Local cFrom			:= ""
Local cSelect		:= ""
Local cWhere		:= "" 
Local cGroup		:= ""
Local cAliasQry		:= ""
Local cError		:= ""
Local cWarning		:= ""
Local cFile			:= ""
Local cArq      	:= Nil
Local cStartPath	:= Nil
Local dDataDe		:= MV_PAR01
Local dDataAte		:= MV_PAR02
Local cFilMat		:= MV_PAR03
Local cEndPath		:= AllTrim(MV_PAR05)
Local cTpXML		:= Alltrim(Str(MV_PAR06))
Local cErroXML		:= "Falha ao gerar o objeto XML"
Local cWarnXML		:= "O arquivo XML não está de acordo com o Schema"
Local cPathSchema	:= GetNewPar( "MV_INOVSCH" , "" ) + GetNewPar( "MV_INOVXSA" , "" ) + ".XSD"

cSelect	+=	"%SUM(SD1.D1_TOTAL) AS TOTAL, SD1.D1_FORNECE, SD1.D1_LOJA, SA2.A2_NOME, SA2.A2_CGC%"
cFrom	+=	"%"+RetSQLName("SD1")+" SD1 "
cFrom	+=	"JOIN " + RetSQLName( "SA2" ) + " SA2 ON SA2.A2_COD = SD1.D1_FORNECE %"
cWhere  +=  "%SA2.A2_INOVAUT = '1' AND SD1.D1_DTDIGIT <= '"+ DTOS(dDataAte) + "' AND SA2.A2_DTCONV <= '"+ DTOS(dDataAte) + "' AND SD1.D1_TIPO = 'N'%"
cGroup	+=	"%SD1.D1_FORNECE, SD1.D1_LOJA, SA2.A2_NOME, SA2.A2_CGC %"

If (TcSrvType()<>"AS/400")
	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT 
			%Exp:cSelect%
		FROM 
			%Exp:cFrom%
		WHERE 
			%Exp:cWhere%
		GROUP BY
			%Exp:cGroup%
	EndSql
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se a query retornou algum registro  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lRet := ( cAliasQry )->( !Eof() )

If lRet
	cXML	+=	'<?xml version="1.0" encoding="ISO-8859-1" ?>'
	cXML	+=	'<tns:AutoDeclaracao'
	cXML	+=	'	xmlns:tns="http://www.tarea.com.br/InovarAuto/AutoDeclaracao"'
	cXML	+=	'	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
	cXML	+=	'	<tns:retificadora>'+IIF(MV_PAR04==1,"true","false")+'</tns:retificadora>'
	cXML	+=	'	<tns:declarante>'
	cXML	+=	'		<tns:tipo_declarante>M</tns:tipo_declarante>'
	cXML	+=	'		<tns:razao_social>'+Alltrim(SM0->M0_NOMECOM)+'</tns:razao_social>'
	cXML	+=	'		<tns:cnpj>'+SM0->M0_CGC+'</tns:cnpj>'
	cXML	+=	'		<tns:matriz>'+"true"+'</tns:matriz>'
	While !(cAliasQry)->(Eof())	
		cXML	+=	'		<tns:operacao>'
		cXML	+=	'			<tns:natureza_operacao>A</tns:natureza_operacao>'
		cXML	+=	'			<tns:empresa>'
		cXML	+=	'				<tns:razao_social>'+(cAliasQry)->A2_NOME+'</tns:razao_social>'
		cXML	+=	'				<tns:cnpj>'+(cAliasQry)->A2_CGC+'</tns:cnpj>'
		cXML	+=	'			</tns:empresa>'
		cXML	+=	'	 		<tns:mes_ref>'+Alltrim(Str(Month(dDataDe)))+'</tns:mes_ref>'
		cXML	+=	'			<tns:ano_ref>'+Alltrim(Str(Year(dDataDe)))+'</tns:ano_ref>'
		cXML	+=	'			<tns:vl_total_notas>'+Alltrim(Str((cAliasQry)->TOTAL))+'</tns:vl_total_notas>'
		cXML	+=	'		</tns:operacao>'
		(cAliasQry)->(dbSkip())
	End
	cXML	+=	'	</tns:declarante>'
	cXML	+=	'</tns:AutoDeclaracao>'
		
	IncProc( STR0011 )	//"Validando Arquivo XML"
	oXML := XMLParser( cXML , '_' , @cErroXML , @cWarnXML )
	Do Case
		Case oXML == Nil
			MsgStop(	STR0002 + CRLF +;				//"Falha ao gerar Objeto XML!"
						STR0003 + cErroXML + CRLF +;	//"Erro: " ####
						STR0004 + cWarnXML )			//"Advertência: " ####
			lAbort	:=	.T.
		Case !( XMLSVldSch( cXML , cPathSchema , @cError , @cWarning ) )
       	
			MsgStop(	STR0005 + CRLF +;				//"O arquivo XML gerado não está de acordo com o Schema!"
						STR0003 + cError + CRLF +;		//"Erro: " ####
						STR0004 + cWarning )			//"Advertência: " ####
			lAbort := .T.
	End Case
Else
	Aviso("Sem Movimento","Não houve movimento no período, ou na Filial selecionada. " + CRLF + CRLF + "Nenhum XML será gerado.",{"Fechar"},3)
	lAbort := .T.
EndIf
	
If !lAbort
	IncProc( STR0012 )	//"Gerando Arquivo XML"
	cFile := X073XMLName(StrZero(Month( dDataDe ),2),Str(Year( dDataDe ),4))	
	If xFunGetDir( 1 , , @cArq , @cStartPath , @nHandle )
		WrtStrTxt( nHandle , cXML )
		If xFunGetDir( 2 , , , , nHandle )
			If xFunGetDir( 3 , cEndPath + cFile , cArq , cStartPath )
				MsgInfo( STR0006 + cFile + STR0007 + cEndPath )	//"O arquivo " #### " foi criado com sucesso no diretório " ####
			Endif
		Endif
	Endif
Endif
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} x073UltProd

Consulta pelo ultimo periodo anterior à data de ref. passada 
no qual houve producao, transferencia ou desmontagem de determinado 
produto. Funcao transportada do fonte FCIXFUN pois esta mesma consulta 
já é utilizada na apuração da FCI.

@param	cProduto -> Produto a ser pesquisado.
@param	dDtRef -> Data de referencia.

@return String com o mes e o ano da ultima producao do produto.

@author joao.pellegrini 
@since 23/09/2015
@version 11.0

/*/
//-------------------------------------------------------------------
Static Function x073UltProd(cProduto,dDtRef)

Local aAreaAnt  := GetArea()
Local aAreaSD3	:= SD3->(GetArea())
Local cAlias 	:= "" 
Local cFuncNull	:= "" 
Local cQuery 	:= ""   
Local cData   	:= ""
Local cAno      := ""
Local cMes      := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Nome da funcao do banco de dados que substitui NULL por 0³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Do Case
	Case cDbType $ "DB2/POSTGRES"
		cFuncNull	:= "COALESCE"
	Case cDbType $ "ORACLE/INFORMIX"   
  		cFuncNull	:= "NVL"
 	Otherwise
 		cFuncNull	:= "ISNULL"
EndCase

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Efetua query para retornar o periodo no qual houve a ultima entrada de producao, transferencia ou desmontagem  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cAlias := GetNextAlias()

cQuery	:= "SELECT " + cFuncNull + " (MAX(SD3.D3_EMISSAO),'00000000') AS PERIODO "
cQuery += "FROM " + RetSQLName("SD3") + " SD3 "
cQuery += " WHERE SD3.D3_FILIAL = '"+xFilial("SD3")+"'"
cQuery += " AND SD3.D3_COD = '"+cProduto+"'" 
cQuery += " AND SD3.D3_EMISSAO <= '"+dtos(dDtRef)+"'"  
cQuery += " AND D3_ESTORNO = ' ' "
cQuery += " AND D3_CF IN ('DE4','DE7','PR0') "
cQuery += " AND D_E_L_E_T_ = ' '"

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)   

cData:= Substr((cAlias)->(PERIODO),1,6)
cMes := Substr(cData,5,2)
cAno := Substr(cData,1,4)

(cAlias)->(DbCloseArea())

RestArea(aAreaSD3)     
RestArea(aAreaAnt)

Return cMes+cAno
