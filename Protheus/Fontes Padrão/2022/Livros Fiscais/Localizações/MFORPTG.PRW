#INCLUDE "MFORPTG.CH"
#INCLUDE "PROTHEUS.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MFORPTG   ³ Autor ³ Cleber Stenio         ³ Data ³23/05/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Relatorio para demonstrar uma relação de clientes que deverá³±±
±±³			 ³ ser entregue quando o valor anual das Vendas seja:         ³±±
±±³			 ³ Para os anos anteriores a 2004, superior a 50.000 euros    ³±±
±±³			 ³ Para o ano 2004 e seguintes, superior a 25.000 euros       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³Data    ³ BOPS     ³ Motivo da Alteracao                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jonathan Glz³06/07/15³PCREQ-4256³Se elimina la funcion AjustaSX1() la  ³±±
±±³            ³        ³          ³hace modificacion a SX1 por motivo de ³±±
±±³            ³        ³          ³adecuacion a fuentes a nuevas estruc- ³±±
±±³            ³        ³          ³turas SX para Version 12.             ³±±
±±³Alf. Medrano³09/11/15³PCREQ-4263³ se realiza merge 12.1.8              ³±±
±±³LuisEnríquez³11/01/17³SERINN001-922³-Se realiza merge para hacer cambio³±±
±±³            ³        ³             ³en creación de tabla temp CTREE.   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MFORPTG
	Local oReport
	Local cPerg		:=	"MFORPT"
	Private oTmpTable := Nil	

	Pergunte(cPerg,.F.)
	oReport := ReportDef()
	oReport:PrintDialog()
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³ Gustavo G. Rueda      ³ Data ³22/05/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Funcao que monta todas as secoes do relatorio               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³oReport - Objeto TReport                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cPerg - Nome do grupo de perguntas                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()
	Local aOrdem 	:= {STR0005}
	Local oReport      
	Local oContr
	Local oMov
	Local cReport	:= "MFORPTG"
	Local cPerg		:= "MFORPT"
	Local cTitulo	:= OemToAnsi(STR0001)	//"MAPA RECAPITULATIVO DE CLIENTES (ANEXO - O)- alínea e) do nº 1 do artigo 28.º do Código do IVA"
	Local cDesc		:= OemToAnsi(STR0002)	//"O Mapa Recapitulativo de Clientes deve ser enviado quando o valor anual das Vendas for: para os anos anteriores a 2004, superior a 50.000 euros ou para o ano 2004 e seguintes, superior a 25.000 euros."
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Componente de impressao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport := TReport():New(cReport,cTitulo,cPerg, {|oReport| ReportPrint(oReport)},cDesc)
	oReport:SetLandscape()
	oReport:SetTotalInLine(.F.)
	oReport:SetPortrait(.T.)
	Pergunte(oReport:uParam,.F.)       

	//Secao 1 - Contribuinte
	oContr := TRSection():New(oReport,OemToAnsi(STR0003),{"SM0"},aOrdem,/*Campos do SX3*/,/*Campos do SIX*/)
	oContr:SetLineStyle()
	TRCell():New(oContr,"M0_CGC"		,"SM0",OemToAnsi(STR0007),	"@R 99.999.999/9999-99"	,040,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oContr,"cPeriodo"		,"SM0",OemToAnsi(STR0008),/*Picture*/				,040,/*lPixel*/,/*{|| code-block de impressao }*/)

	//Secao 2 - Relacao de clientes com sede em território nacional.
	oMov := TRSection():New(oReport,OemToAnsi(STR0009),{"TMP"},aOrdem,/*Campos do SX3*/,/*Campos do SIX*/) // "Resumo Geral por NIF"
	oMov:SetTotalInLine(.F.)
	TRCell():New(oMov,"TMP_SEQ"		,"TMP"	,OemToAnsi(STR0004)			,"@!"						,5													,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oMov,"TMP_NIF"		,"TMP"	,OemToAnsi(STR0005) 		,"@!"						,TamSX3("A2_CGC")[01]								,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oMov,"TMP_VLR"		,"TMP"	,OemToAnsi(STR0006)	   		,"@E 999,999,999,999.99"	,15													,/*lPixel*/,/*{|| code-block de impressao }*/)
	oMov:Cell("TMP_NIF"):SetHeaderAlign("RIGHT")

	//Secao 3 - Totalizador
	oTotal	:= TRSection():New(oReport,OemToAnsi(STR0010),{"SM0"},aOrdem,/*Campos do SX3*/,/*Campos do SIX*/)
	oTotal:SetLineStyle()
	TRCell():New(oTotal,"nTotal","SM0",OemToAnsi(STR0010),"@E 999,999,999,999.99"	,015,/*lPixel*/,/*{|| code-block de impressao }*/)
	oTotal:Cell("nTotal"):SetHeaderAlign("RIGHT")
Return oReport
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrint³ Autor ³ Gustavo G. Rueda      ³ Data ³22/05/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Funcao que gera o relatorio pre-definido                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³oReport - Objeto TReport                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportPrint(oReport)
	Local 	oContr		:= oReport:Section(1)
	Local 	oMov		:= oReport:Section(2)
	Local 	oTotal		:= oReport:Section(3)
	Local	cPeriodo	:=	MV_PAR01
	Local 	cCondicao	:= "SM0->M0_CODFIL == '" + cFilAnt + "' .And. SM0->M0_CODIGO == '" + cEmpAnt + "'"
	Local	aTMP		:=	{}
	Local	lGerou		:=	.F.
	Local	nOpEst		:=	0
	Local	nEstrang	:=	0
	Local	nTotal		:=	0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Transforma parametros Range em expressao SQL                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MakeSqlExpr(oReport:uParam)
	oContr:SetFilter(cCondicao)
	oTotal:SetFilter(cCondicao)
	MakeAdvplExpr(oReport:uParam)    		

	//Monta e alimenta o arquivo de trabalho
	MontFOR(1,oReport,@aTMP,.T.,cPeriodo)

	dbSelectArea("TMP")
	oReport:SetMeter(TMP->(LastRec()))

	oContr:Cell("cPeriodo"):SetBlock({|| cPeriodo }) 
	oContr:Init()
	oContr:Print()
	oContr:Finish()

	lGerou	:=	.F.
	oReport:ThinLine()
	oReport:SkipLine()
	oReport:SkipLine()
	oReport:PrintText(STR0009)
	oReport:ThinLine()
	oMov:Init()
	TMP->(dbGoTop())
	Do While !oReport:Cancel() .And. !TMP->(Eof())

		If oReport:Cancel()                    		
			Exit
		EndIf                                                    		

		oMov:IncMeter()                       		

		// Anos anteriores a 2004, superior a 50.000 euros
		If 	(cPeriodo < "2004") .AND. (TMP->TMP_VLR > 50000)

			nTotal	+=	TMP->TMP_VLR
			// Anos superiores a 2004, superior a 25.000 euros	    
		ElseIf (cPeriodo > "2004") .AND. (TMP->TMP_VLR > 25000)

			nTotal	+=	TMP->TMP_VLR
		EndIf

		If nTotal > 0
			oMov:PrintLine()
			lGerou	:=	.T.
		EndIf
		TMP->(dbSkip())
	Enddo
	oMov:Finish()

	If !lGerou
		oReport:PrintText(STR0011)//"*** Sem informação ***"
	EndIf

	oTotal:Cell("nTotal"):SetBlock({|| Int(nTotal) }) 
	oTotal:Init()
	oTotal:Print()
	oTotal:Finish()

	//Apaga o arquivo de trabalho gerado
	MontFOR(2,,aTMP,,cPeriodo)
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MontFor   ³ Autor ³ Gustavo G. Rueda      ³ Data ³22/05/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Funcao que monta e alimenta o arquivo de trabalho com base  ³±±
±±³          ³ no SF3.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nOpc - 1=Cria e alimenta, 2=Apaga                           ³±±
±±³          ³oReport - Objeto TReport                                    ³±±
±±³          ³aTMP - Array que retorna o alias e o nome fisico do arquivo ³±±
±±³          ³ de trabalho.                                               ³±±
±±³          ³lRelat - Flag que indica se a chamada da funcao e do relato-³±±
±±³          ³ rio ou nao.                                                ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MontFOR(nOpc,oReport,aTMP,lRelat,cAno)
	Local	cAls	:=	GetNextAlias()
	Local	nTam	:=	0
	Local	aStr	:=	{}
	Local	nSeq	:=	0
	Local	cWhere	:=	""  
	Local   dDatini := dTos(ctod("01/01/"+ cAno,"ddmmyy") )
	Local   dDatFin := dTos(ctod("31/12/"+ cAno,"ddmmyy") ) 
	Local	cChave	:=	""
	Local aOrdem := {}

	If nOpc==1
		aAdd(aStr,{"TMP_SEQ",	"C",	005,	0})
		nTam	:=	TamSx3("A2_CGC")[1]
		aAdd(aStr,{"TMP_NIF",	"C",	nTam,	0})
		aAdd(aStr,{"TMP_ENT",	"N",	018,	2})	
		aAdd(aStr,{"TMP_SAI",	"N",	018,	2})	
		aAdd(aStr,{"TMP_VLR",	"N",	018,	2})	
		//
		oTmpTable := FWTemporaryTable():New("TMP") 
		oTmpTable:SetFields( aStr ) 
		aOrdem	:=	{"TMP_NIF"} 
		oTmpTable:AddIndex("IN1", aOrdem) 
		oTmpTable:Create() 
		
		cWhere		:=	"%SF3.F3_DTCANC=''%"

		BeginSql Alias cAls

		//COLUMN D2_EMISSAO AS DATE

		SELECT 	A2_CGC, A2_EST, F3_CLIEFOR, F3_LOJA, F3_NFISCAL, F3_SERIE, F3_VALCONT, F3_TIPOMOV, F3_ESPECIE 

		FROM %table:SF3% SF3, %table:SA2% SA2

		WHERE 	SF3.%NotDel%          		        AND
		SA2.%NotDel%          		        AND
		SF3.F3_FILIAL  	=  %xFilial:SF3% 	AND
		SF3.F3_ENTRADA 	>= %Exp:dDatini%    AND 
		SF3.F3_ENTRADA 	<= %Exp:dDatFin%    AND
		%Exp:cWhere%						AND
		SA2.A2_FILIAL  	=  %xFilial:SA2% 	AND
		SA2.A2_COD     	= 	SF3.F3_CLIEFOR 	AND
		SA2.A2_LOJA    	=   SF3.F3_LOJA		AND
		SF3.F3_VALIMP1  >   0				AND
		SF3.F3_EXENTAS  =   0               AND
		SF3.F3_TIPOMOV  =  'C'

		ORDER BY 1

		EndSql

		//GetLastQuery()[2] 

		TMP->(dbSetOrder(1))

		If lRelat
			oReport:SetMeter((cAls)->(LastRec()))
		EndIf

		While !(cAls)->(Eof())

			//Posicionar o SF3 somente uma vez qdo houver duas escriturações ou mais para a mesma nota
			If cChave<>(cAls)->(F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE)
				cChave	:=	(cAls)->(F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE)


				If lRelat
					oReport:IncMeter()
				EndIf

				If TMP->(dbSeek(aRetDig((cAls)->A2_CGC,.F.)))
					RecLock("TMP",.F.)
				Else
					nSeq++
					RecLock("TMP",.T.)
					TMP->TMP_SEQ	:=	StrZero(nSeq,5)
					TMP->TMP_NIF	:=	aRetDig((cAls)->A2_CGC,.F.)
				EndIf

				If !((cAls)->A2_EST$"98/99")	//INTRACOMUNITARIO/EXTRACOMUNITARIO
					//Acumular Saidas
					If (cAls)->F3_TIPOMOV == "V"
						//Se for Nota de Crédito subtrair
						If Substr((cAls)->F3_ESPECIE,1,2)=="NC"
							TMP->TMP_SAI	-=	(cAls)->F3_VALCONT
						Else
							TMP->TMP_SAI	+=	(cAls)->F3_VALCONT				
						EndIf		
						//Acumular Entradas
					ElseIf (cAls)->F3_TIPOMOV == "C"

						//Se for Nota de Crédito subtrair
						If Substr((cAls)->F3_ESPECIE,1,2)==		"NC"
							TMP->TMP_ENT	-=	(cAls)->F3_VALCONT
						Else
							TMP->TMP_ENT	+=	(cAls)->F3_VALCONT				
						EndIf		

					EndIf
					//Total Faturado para o Fornecedor igual a Saidas menos Entradas para o mesmo
					TMP->TMP_VLR := TMP->TMP_ENT - TMP->TMP_SAI
				EndIf

				MsUnLock()
				FkCommit()	

				(cAls)->(dbSkip())		
			Else
				(cAls)->(dbSkip())
			EndIf
		End
		(cAls)->(dbCloseArea())
	Else
		If oTmpTable <> Nil   
			oTmpTable:Delete()  
			oTmpTable := Nil 
		Endif	
	EndIf
Return
