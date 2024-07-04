#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.Ch"
#INCLUDE "TopConn.ch"
#include "GPEM878.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออออหออออออออออหอออออออหอออออออออออออออออออออออออออหออออออหอออออออออออออปฑฑ
ฑฑบPrograma    บGPEM878   บAutor  บLuis Trombini              บ Data บ  20/10/2010 บฑฑ
ฑฑฬออออออออออออุออออออออออสอออออออสอออออออออออออออออออออออออออสออออออสอออออออออออออนฑฑ
ฑฑบDesc.       บ ROTINA PARA EXPORTACAO EM ARQUIVO ANUAL XML.(EQUADOR)             บฑฑ
ฑฑบ            บ                                                                   บฑฑ
ฑฑฬออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso         บ P11                                                               บฑฑ
ฑฑฬออออออออออออุออออออออหอออออออออออออหออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador บ Data   บ   BOPS      บ  Motivo da Alteracao                       บฑฑ
ฑฑฬออออออออออออุออออออออุอออออออออออออุออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบL.Trombini  บ18/05/11บ00010930/2011บ Inclusao das strings no CH. para cabe็a-   บฑฑ
ฑฑบ            บ        บ             บ lhos e mensagens                           บฑฑ
ฑฑบKelly Soaresบ27/10/11บ  TDUJOF-2011บ EQU: Ajuste de mensagem de arquivo gerado  บฑฑ
ฑฑบ            บ        บ             บ com sucesso.                               บฑฑ
ฑฑบ            บ        บ             บ                                            บฑฑ
ฑฑบJonathan Glzบ05/05/15บ   PCREQ-4256บ Se elimina la funcion GP878PERG, la cual   บฑฑ
ฑฑบ            บ        บ             บ realiza la modificacion al diccionario de  บฑฑ
ฑฑบ            บ        บ             บ datos (SX1) por motivo de adecuacion de    บฑฑ
ฑฑบ            บ        บ             บ nueva estructura de SXs para version 12    บฑฑ
ฑฑศออออออออออออสออออออออสอออออออออออออสออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function GPEM878()

	Private cPerg	:= "GPM878"
	Private oGeraXML

		pergunte(cPerg,.F.)

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Montagem da tela de processamento.                                  ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		@ 200,001 TO 410,480 DIALOG oGeraXML TITLE OemToAnsi(STR0003) //( "Geracao de Arquivo em XML" )
		@ 002,010 TO 095,230
		@ 010,018 Say STR0004 //" El Programa genera el archivoi de Datos de la R.D.E.P en XML "

		@ 070,128 BMPBUTTON TYPE 05 ACTION Pergunte(cPerg,.T.)
		@ 070,158 BMPBUTTON TYPE 01 ACTION Processa({|| GP878PROC(),Close(oGeraXML)},STR0007) //"Procesando...")
		@ 070,188 BMPBUTTON TYPE 02 ACTION Close(oGeraXML)

		Activate Dialog oGeraXML Centered

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGP878PROC บAutor  ณLuis Trombini       บ Data ณ  20/10/2010 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ GERAR ROTINA DE PAGAMENTO EM XML.                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ P11                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static Function GP878PROC()
	Local lRet 		:= .T.
	Local cQry			:= {}
	Local cFreq		:= ""
	Local cQryItem	:= {}

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Carregando variaveis mv_par?? para Variaveis do Sistema.     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local cFilDe		:= mv_par01		//Filial De
	Local cMatDe	   	:= mv_par02		//Matricula De
	Local cAno			:= mv_par03		//Ano Base
	Local cPath		:= Upper( AllTrim( mv_par04) )
	Local cFilAnt 	:= SPACE(FWGETTAMFILIAL)
	Local cFiltro		:=""

	cAliasRH6 := "RH6"
	#IFDEF TOP


		//--Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
		MakeSqlExpr("GPM878")

		//-- Adiciona no filtro o parametro tipo Range
		//-- Filial
		If !Empty(mv_par01)
			cFiltro += mv_par01
		EndIf

		//-- mATRICULA
		If !Empty(mv_par02)
			cFiltro += Iif(!Empty(cFiltro)," AND ","")
			cFiltro += mv_par02
		EndIf
    	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Consiste o filtro incluido pelo usuario -bt.personalizar     ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

		cOrdem := "%RH6.RH6_FILIAL, RH6.RH6_MAT%"
		cAnoBs := "%"+"RH6.RH6_ANORET="+ MV_PAR03+"%"
        cFiltro := "%"+cFiltro+"%"


		//dbSelectArea(cAliasSRA)
		BeginSql alias cAliasRH6
    	SELECT RH6.*
  			FROM %table:RH6% RH6
			WHERE  RH6.%notDel%  AND
			       %exp:cAnoBs%  AND
			   	   %exp:cFiltro%
			ORDER BY %exp:cOrdem%
		EndSql

	#Endif


   	If !Empty(RH6->RH6_FILIAL) .and. !Empty(RH6->RH6_MAT)

   		BEGIN TRANSACTION

   			//Abrir a Tabela de Funcionarios
   			DbSelectArea("RH6")
   			//Setar o Indice: RH6_FILIAL + RH6_MAT
   			RH6->( Dbgotop() )
   		    cFilAnt := ""

		   	AUTOGRLOG('<?xml version="1.0" encoding="ISO-8859-1" standalone="yes"?> ')
//			AUTOGRLOG('<pi:PIF xmlns:pi="http://www.convergys.com/2008/ProcessingInstruction" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.convergys.com/2008/ProcessingInstructionspif-1.1.xsd"> ')

			Do While RH6->(!Eof())

		   		if RH6->RH6_FILIAL <> cFilAnt
			 	   cFilAnt := RH6->RH6_FILIAL
                   AUTOGRLOG('<rdep> ')
			       AUTOGRLOG('        <numRuc>' + Alltrim(RH6->RH6_NRRUC) +'</numRuc> ') //Numero RUC
				   AUTOGRLOG('        <anio>' + Alltrim(RH6->RH6_ANORET) + '</anio> ')
			       AUTOGRLOG('<retRelDep> ')
				EndIf

				Do While RH6->(!Eof()) .and. RH6->RH6_FILIAL == cFilAnt

				    AUTOGRLOG('    <datRetRelDep> ')
				    AUTOGRLOG('        <tipIdRet>'+ RH6->RH6_TIPID+'</tipIdRet> ') //Tipo de Documento de Identificacao
				    AUTOGRLOG('        <idRet>' + RH6->RH6_IDRET+ '</idRet> ')
				    AUTOGRLOG('        <dirCal>' + Alltrim(RH6->RH6_DIRCAL) + '</dirCal> ')
			    	AUTOGRLOG('        <dirNum>' + Alltrim(RH6->RH6_DIRNUM) + '</dirNum> ')
				    AUTOGRLOG('        <dirCiu>' + Alltrim(RH6->RH6_CODMUN) + '</dirCiu> ')
				    AUTOGRLOG('        <dirProv>'+ Alltrim(RH6->RH6_CODEST) + '</dirProv> ')
				    AUTOGRLOG('        <tel>' + Alltrim(RH6->RH6_NRTELE) + '</tel> ')
		    	    AUTOGRLOG('        <sisSalNet>' + Alltrim(RH6->RH6_SISSAL) + '</sisSalNet> ')
			    	AUTOGRLOG('        <suelSal>' + Transform(RH6->RH6_SALAR,"999999999.99") + '</suelSal> ')
				    AUTOGRLOG('        <sobSuelComRemu>' + Transform(RH6->RH6_COMISS,"999999999.99") +  '</sobSuelComRemu> ')
					AUTOGRLOG('        <decimTer>' + Transform(RH6->RH6_D13SAL ,"999999999.99") + '</decimTer> ')
				    AUTOGRLOG('        <decimCuar>' + Transform(RH6->RH6_D14SAL,"999999999.99") + '</decimCuar> ')
				    AUTOGRLOG('        <fondoReserva>' +Transform(RH6->RH6_FONDO,"999999999.99") + '</fondoReserva> ')
		        	AUTOGRLOG('        <partUtil>' + Transform(RH6->RH6_PARUTI,"999999999.99") + '</partUtil> ')
			        AUTOGRLOG('        <desauOtras>' + Transform(RH6->RH6_VRESCI,"999999999.99") + '</desauOtras> ')
			        AUTOGRLOG('        <apoPerIess>' + Transform(RH6->RH6_APIESS,"999999999.99") + '</apoPerIess> ')
			        AUTOGRLOG('        <deducVivienda>' + Transform(RH6->RH6_DEDVIV,"999999999.99") + '</deducVivienda> ')
		    	    AUTOGRLOG('        <deducSalud>' + Transform(RH6->RH6_DEDSAL,"999999999.99") + '</deducSalud> ')
		        	AUTOGRLOG('        <deducEduca>' + Transform(RH6->RH6_DEDEDU,"999999999.99") + '</deducEduca> ')
			        AUTOGRLOG('        <deducAliement>' + Transform(RH6->RH6_DEDALI,"999999999.99") + '</deducAliement> ')
			        AUTOGRLOG('        <deducVestim>' + Transform(RH6->RH6_DEDVES,"9999999.99") + '</deducVestim> ')
			        AUTOGRLOG('        <rebEspDiscap>' + Transform(RH6->RH6_DESCAP,"999999999.99") + '</rebEspDiscap> ')
		    	    AUTOGRLOG('        <rebEspTerEd>' + Transform(RH6->RH6_TERIDA,"999999999.99") + '</rebEspTerEd> ')
		        	AUTOGRLOG('        <impRentEmpl>' + Transform(RH6->RH6_INRETE,"9999999.99") + '</impRentEmpl> ')
			        AUTOGRLOG('        <subTotal>' + Transform(RH6->RH6_SUBTOT,"9999999.99") + '</subTotal> ')
			        AUTOGRLOG('        <numRet>' + strzero(RH6->RH6_NUNRET,2) + '</numRet> ')
			        AUTOGRLOG('        <numMesEmplead>' +strzero(RH6->RH6_NUMMES,2) + '</numMesEmplead> ')
		    	    AUTOGRLOG('        <intGrabGen>' + Transform(RH6->RH6_OUTEMP,"999999999.99") + '</intGrabGen> ')
		        	AUTOGRLOG('        <deduccGastosOtrEmpl>' + Transform(RH6->RH6_OUTDED,"999999999.99") + '</deduccGastosOtrEmpl> ')
			        AUTOGRLOG('        <otrRebjOtrEmpl>' + Transform(RH6->RH6_OUTBXS,"999999999.99") + '</otrRebjOtrEmpl> ')
			        AUTOGRLOG('        <basImp>' + Transform(RH6->RH6_BASIMP,"999999999.99") + '</basImp> ')
			        AUTOGRLOG('        <impRentCaus>' + Transform(RH6->RH6_IMPCAU,"9999999.99") + '</impRentCaus> ')
		    	    AUTOGRLOG('        <valRet>' + Transform(RH6->RH6_IMPRET,"999999999.99") + '</valRet> ')
		        	AUTOGRLOG('        <valorImpempAnter>' + Transform(RH6->RH6_OUTIMP,"999999999.99") + '</valorImpempAnter> ')
			        AUTOGRLOG('        <anioRet>' + RH6->RH6_ANORET + '</anioRet> ')
			   		AUTOGRLOG('    </datRetRelDep> ')
					RH6->(DbSkip())

				EndDo


				AUTOGRLOG('</retRelDep> ')
				AUTOGRLOG('</rdep> ')

		   	EndDo


			__COPYFILE(NOMEAUTOLOG() , cPath)

			MSGINFO(STR0005,STR0008) //('ARQUIVO GERADO COM SUCESSO !')

			RH6->(DbCloseArea())

   		END TRANSACTION

   	Else

   		Alert(STR0006) //('NรO FOI ENCONTRADO NENHUM REGISTRO PARA EXPORTAวรO !')
   		lRet := .F.
   		RH6->(DbCloseArea())

   	EndIf

Return lRet

Function fDir878m()
	Local mvRet	:= Alltrim(ReadVar())
	Local cType 	:= ""
	Local cArq		:= ""
	Local aDir		:= {}
	Local nDir		:= 0

		cType:= STR0002 //"Arquivos Tipo XML  (*.XML) |*.XML|"
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Comando para selecionar um arquivo.                          ณ
		//ณ Parametro: GETF_LOCALFLOPPY - Inclui o floppy drive local.   ณ
		//ณ            GETF_LOCALHARD - Inclui o Harddisk local.         ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cArq 	:= cGetFile(cType, STR0001, 0,,.T.,GETF_LOCALHARD+GETF_LOCALFLOPPY)  // "Selecione arquivo "
		aDir	:= { { cArq } }


		&mvRet := cArq

Return (.T.)
