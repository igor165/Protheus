#INCLUDE "TOTVS.ch"
#INCLUDE "PROTHEUS.ch"
#INCLUDE "FWMVCDEF.ch"
#INCLUDE "GPEA710.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma    ³ GPEA710  º Autor ³ Equipe RH                  º Data ³ 18/09/2013  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.       ³   Cadastro do Controle de Restricao de Acesso a Rotinas.           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso         ³   Generico                                                         º±±
±±ºÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±º            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                    º±±
±±ºÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºAnalista    ³ Data   ³ FNC         ³Motivo da Alteracao                          º±±
±±ºÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºRaquel Hager³19/09/13³196001/2013   ³Projeto M12RH01 - Unificacao da Folha de Pa-º±±
±±º            ³        ³              ³gamento Versao 12.                          º±±
±±ºEsther V.   ³29/06/16³  TVKRTS      ³Validacao de acesso de usuario a filial     º±±
±±º            ³        ³              ³escolhida para bloqueio.                    º±±
±±ºVictor A.   ³29/07/16³  TVKRTS      ³Validacao de acesso de usuario a filial     º±±
±±º            ³        ³              ³escolhida para bloqueio - campos Usr1 e Usr2º±±
±±ºJônatas A.  ³30/05/17³DRHPAG-2128   ³Ajustes diversos no bloqueio: associacao    º±±
±±º            ³        ³              ³ao processo; novo indice com processo; nova º±±
±±º            ³        ³              ³forma de bloqueio de acordo ao modo de      º±±
±±º            ³        ³              ³compartilhamento da RG3; correcao no botao  º±±
±±º            ³        ³              ³"Replica"; associacao do modo acesso da RG3 º±±
±±º            ³        ³              ³à RCJ; busca da descricao do campo filial deº±±
±±º            ³        ³              ³acordo ao item selecionado(emp/unid/fil);   º±±
±±º            ³        ³              ³ajuste na carga da descricao da filial dos  º±±
±±º            ³        ³              ³registros ja existentes na RG3; ajuste para º±±
±±º            ³        ³              ³possibilitar a replica de roteiro.          º±±
±±ºWillian U.  ³20/07/17³DRHPONTP-213  ³Melhoria no Ponto eletrônico de forma que   º±±
±±º            ³        ³              ³seja possível bloquear o lançamento e       º±±
±±º            ³        ³              ³manutenção de marcações para o fechamento   º±±
±±º            ³        ³              ³mensal.                                     º±±
±±ºJaqueline L.³26/01/18³DRHPAG-11253  ³Correção no Seek do Bloqueio de Período     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GPEA710()
Local aArea			:= GetArea()
Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F., {"",""} }) //[1]Acesso; [2]Ofusca; [3]Mensagem
Local aFldRel		:= {"RG3_NUSER1", "RG3_NUSER2", "RG3_NUSER3", "RG3_NUSER4"}
Local lBlqAcesso	:= aOfusca[2] .And. !Empty( FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRel ) )

Private lGpea710Inc	:= .F.     // Define se abre tela apos gravacao
Private cX2RG3		:= ""

	//Tratamento de acesso a Dados Sensíveis
	If lBlqAcesso
		//"Dados Protegidos- Acesso Restrito: Este usuário não possui permissão de acesso aos dados dessa rotina. Saiba mais em {link documentação centralizadora}"
		Help(" ",1,aOfusca[3,1],,aOfusca[3,2],1,0)
		Return
	EndIf

	GPA710Manu(,,4) // Sempre acessa os dados como manutencao

	RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GPA710Manu ³ Autor ³ Equipe RH            ³ Data ³10/05/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Manutencao da Rotina do Controle de Resticao de Acessos.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA710                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */
Function GPA710Manu( cAlias , nReg , nOpcx )
// Variaveis auxiliares
Local cDatas			:= " : " + DtoC(RFQ->RFQ_DTINI) + " - " + DtoC(RFQ->RFQ_DTFIM)
Local nOpca 			:= 0
Local nOpcAlt			:= 0.00				// Variavel de controle das alteracoes - utilizada para a gravacao
Local nX				:= 0.00
Local nPosRec			:= 0
Local nSavRec   		:= 	RecNo()
// Variaveis da janela
Local bSet15			:= { || Nil }		// Bloco com as validacoes do botao OK
Local bSet24			:= { || Nil }  		// Bloco com as validacoes do botao Cancelar
Local bReplicate   		:= { || }
Local bDialogInit		:= { || Nil }		// Inicializacao do Dialog
// Variaveis do tipo objetos
Local oDlg1				:= Nil
Local oFont
Local oGroup
// Variaveis para controle de coordenadas da janela
Local aAdvSize			:= {}
Local aInfoAdvSize		:= {}
Local aObjSize			:= {}
Local aObjCoords		:= {}
Local aAdv1Size			:= {}
Local aInfo1AdvSize		:= {}
Local aObj1Coords 		:= {}
Local aObj1Size			:= {}

Local aArea				:= {}

Private	aHeaderRG3	 	:= {}
Private aColsRG3	 	:= {}
Private aColAntRG3		:= {}
Private aBotoes 		:= {}
Private	aFils			:= {}
Private aGdAltRG3		:= {}

Private oGetRG3		 	:= Nil

Private cProcesso	 	:= RFQ->RFQ_PROCES
Private cPeriodo	 	:= RFQ->RFQ_PERIOD
Private cNroPagto	 	:= RFQ->RFQ_NUMPAG
Private cDataIni		:= DtoS(RFQ->RFQ_DTINI)
Private cDataFim		:= DtoS(RFQ->RFQ_DTFIM)
Private cModulo			:= RFQ->RFQ_MODULO

// Variaveis para montagem do aCols RG3
Private nUsadoRG3 		:= 0
Private nOrdRG3			:= RetOrdem( "RG3" , "RG3_FILIAL+RG3_EMP+RG3_FIL+RG3_PROCES+RG3_PERIOD+RG3_SEMANA+RG3_ROTEIR+DTOS(RG3_DTINI)+RG3_TIPO" )

Private aVirtRG3 		:= {}
Private aVisuaRG3 		:= {}
Private aNAltRG3		:= {}
Private aNoCpoRG3 		:= { 	"RG3_FILIAL" , "RG3_EMP" , "RG3_SEQ" , "RG3_DTBLOQ", "RG3_USER3" ,;
								"RG3_NUSER3", "RG3_USER4" , "RG3_NUSER4" , "RG3_TIPO" , "RG3_PERIOD",;
						 		"RG3_SEMANA", "RG3_PROCES" }
Private bSkip      		:= {|| .F. }
Private bSeekWhile 		:= {|| RG3->RG3_FILIAL + RG3->RG3_EMP + RG3->RG3_PERIOD + RG3->RG3_SEMANA  }
Private cQuery			:= ""
Private cSeek			:= ""

// Variaveis Chave Usadas em Todo o Programa
Private cSis     		:= xFilial( "RG3", RCJ->RCJ_FILIAL )


	Begin Sequence

		If lGpea710Inc // Ja incluiu o primeiro
			lGpea710Inc := .F.
			Return(	Nil	)
		EndIf

		// Carga das Empresas e Filiais do SM0
		fCargaSM0()

		// Monta aCols RG3
		MontaCols(nOpcx)
		aColAntRG3  := aClone( aColsRG3 )
		// Carrega aGdAltRG3 p/ tela de replica
		MontaEdit()

		// Monta as Dimensoes dos Objetos
		aAdvSize		:= MsAdvSize()
		aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 3 , 3 }
		aAdd( aObjCoords , { 000 , 025 , .T. , .F. } )		// 1-Cabecalho
		aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )		// 2-GetDados
		aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

		//Divisao em colunas Linha 1-Dados do Processo+Periodo+Nro.Pagamento+Roteiro
		aAdv1Size		:= aClone(aObjSize[1])
		aInfo1AdvSize	:= { aAdv1Size[2] , aAdv1Size[1] , aAdv1Size[4] , aAdv1Size[3] , 2 , 2 }
		aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )	// 1-Processo
		aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )	// 2-Periodo
		aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )	// 3-Nro.Pagamento
		aObj1Size		:= MsObjSize( aInfo1AdvSize , aObj1Coords,,.T. )


		// Define o Bloco para a Inicializacao do Dialog
		bDialogInit		:= { ||;
								CursorWait()							,;
								EnchoiceBar( oDlg1 , bSet15 , bSet24 )	,;
								RstEnchoVlds()							,;
								CursorArrow()							 ;
	                         }

		DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
		DEFINE MSDIALOG oDlg1 TITLE OemToAnsi(STR0006) From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL // "Restricao de Acesso a Rotinas"

			If IsIncallStack("PONA290")

				@ aObj1Size[1,1] , aObj1Size[1,2]    	GROUP oGroup 	TO aObj1Size[1,3] , aObj1Size[1,4]  LABEL OemToAnsi(STR0057) OF oDlg1 PIXEL	// "Processo"
				@ aObj1Size[1,1]+10 , aObj1Size[1,2]+5 SAY  DTOC(SPO->PO_DATAINI) + " - " + DTOC(SPO->PO_DATAFIM)SIZE 095,10 OF oDlg1 PIXEL FONT oFont
				oGroup:oFont:= oFont

				@ aObj1Size[2,1] , aObj1Size[2,2] 		GROUP oGroup 	TO aObj1Size[2,3] , aObj1Size[2,4]  LABEL OemToAnsi(STR0058) OF oDlg1 PIXEL //"Periodo"
				@ aObj1Size[2,1]+10 , aObj1Size[2,2]+5 SAY SUBSTR(DTOC(SPO->PO_DATAINI),1,2) SIZE 095,10 OF oDlg1 PIXEL FONT oFont
				oGroup:oFont:= oFont

			Else

				@ aObj1Size[1,1] , aObj1Size[1,2]    	GROUP oGroup 	TO aObj1Size[1,3] , aObj1Size[1,4]  LABEL OemToAnsi(STR0056) OF oDlg1 PIXEL	// "Processo"
				@ aObj1Size[1,1]+10 , aObj1Size[1,2]+5 SAY  cProcesso SIZE 095,10 OF oDlg1 PIXEL FONT oFont
				oGroup:oFont:= oFont

				@ aObj1Size[2,1] , aObj1Size[2,2] 		GROUP oGroup 	TO aObj1Size[2,3] , aObj1Size[2,4]  LABEL OemToAnsi(STR0057) OF oDlg1 PIXEL //"Periodo"
				@ aObj1Size[2,1]+10 , aObj1Size[2,2]+5 SAY cPeriodo+cDatas	SIZE 095,10 OF oDlg1 PIXEL FONT oFont
				oGroup:oFont:= oFont

				@ aObj1Size[3,1] , aObj1Size[3,2]    	GROUP oGroup 	TO  aObj1Size[3,3] , aObj1Size[3,4] LABEL OemToAnsi(STR0058) OF oDlg1 PIXEL	// "Nro.Pagamento"
				@ aObj1Size[3,1]+10 , aObj1Size[3,2]+5 SAY cNroPagto	SIZE 095,10  OF oDlg1 PIXEL FONT oFont
				oGroup:oFont:= oFont

			EndIf

			oGetRG3 := MsNewGetDados():New(aObjSize[2,1],;		// 1  nTop
										 	aObjSize[2,2]	,;  // 2  nLelft
										 	aObjSize[2,3]	,;	// 3  nBottom
			                             	aObjSize[2,4]	,;	// 4  nRright
										 	Iif(nOpcx == 4, GD_INSERT + GD_UPDATE + GD_DELETE,0),;  // 5  Controle do que podera ser realizado na GetDado - nstyle
	 										"GPA710LinOk"	,;	// 6  Funcao para validar a edicao da linha - ulinhaOK
										 	"GPA710TudOk"	,;	// 7  Funcao para validar todas os registros da GetDados - uTudoOK
		  								 	Nil				,;	// 8  cIniCPOS
										 	Nil				,;	// 9  aAlter
										 	0			  	,; 	// 10 nfreeze
										 	99999			,;  // 11 nMax
										 	Nil				,;	// 12 cFieldOK
										 	Nil				,;	// 13 usuperdel
										 	Nil				,;	// 14 udelOK
										 	@oDlg1			,; 	// 15 Objeto de dialogo - oWnd
										 	@aHeaderRG3    	,;	// 16 Vetor com Colunas - AparHeader
										 	@aColsRG3 	    ,;	// 17 Vetor com Header - AparCols
											            	,;  // 18
											 "2")		   		// 19 Tela

		bSet15		:= {|| nOpca:= (If(nOpcx=5,2,1)), (If(oGetRG3:TudoOk(),oDlg1:End(),nOpca:=0))}
		bSet24		:= {|| nOpca:= 0, oDlg1:End()}
		bReplicate 	:= {|| GPA710Repl(), Nil }
		aBotoes 	:= { {"DESTINOS", bReplicate, OemToAnsi( STR0016 ), OemToAnsi( STR0017 )} }	//"Replicar Informacoes <F4>..."###"Replicar"
		If(nOpcx == 4,SetKey(VK_F4,bReplicate),)

		ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1, bSet15, bSet24, , If(nOpcx == 4, aBotoes,) )

		If ( nOpca == 1 .And. nOpcx <> 2 )
	   		Begin Transaction
	   			fGp710Grv( "RG3" , aVirtRG3 , nOpcx )
	   			If nOpcx == 4
					lGpea710Inc	:= .T. // Ja incluiu/alterou
				EndIf
	   		End Transaction
		EndIf

		// Desabilita Tecla <F4>
		If(nOpcx == 4,SetKey(VK_F4,Nil),)

	End Sequence

	dbSelectArea("RFQ")
	Go nSavRec

Return( Nil )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fCargaSM0 ³ Autor ³ Equipe RH            ³ Data ³ 10/05/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Carga Inicial da Tabela RG3 a Partir do SM0.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA710                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */
Static Function fCargaSM0()

Local aArea		:= GetArea()
Local nSm0Rec 	:= SM0->(Recno())
Local cFilGet	:= ""

	dbSelectArea( "SM0" )
	dbGoTop()
	Do While !Eof()

		If SM0->M0_CODIGO = cEmpAnt .And. (cFilGet := xFilial("RG3",FWGETCODFILIAL)) == cSis
			AADD(aFils,{ SM0->M0_CODIGO, FWGETCODFILIAL, FWFILIALNAME(NIL,FWGETCODFILIAL), SM0->M0_NOME })
			AADD(aFils,{ SM0->M0_CODIGO, FWCompany()+FWUnitBusiness(), FWUNITNAME(NIL,FWCompany()+FWUnitBusiness()), SM0->M0_NOME })
			AADD(aFils,{ SM0->M0_CODIGO, FWCompany(), FWCOMPANYNAME(NIL,FWCompany()), SM0->M0_NOME })
		EndIf

		dbSkip()
	EndDo

	SM0->(dbGoTo( nSm0Rec ))
	RestArea( aArea )
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MontaCols ³ Autor ³ Equipe RH            ³ Data ³10/05/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta aCols da Tabela Principal.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA710                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */
Static Function MontaCols(nOpcx)
Local aArea	:= GetArea()
Local cDataBloq 	:= ""
Local cNrPgtBloq 	:= ""

// ---------------------------------------------------------------
// - Utiliza os dados da SPO quando a opção for referente a
// - bloqueio de período do Ponto eletrônico.
// ---------------------------------------------------------------

cDataBloq 	:= DtoS(SPO->PO_DATAINI)
cDataBloq 	:= Substr(cDataBloq,1,6)
cNrPgtBloq	:= Substr(Dtoc(SPO->PO_DATAINI),1,2)

cPeriodo  := Iif(IsIncallStack("PONA290"),cDataBloq,cPeriodo)
cNroPagto := Iif(IsIncallStack("PONA290"),cNrPgtBloq,cNroPagto)

	cQuery := " RG3_FILIAL = '" + cSis  + "'"
	cQuery += " AND "
	cQuery += " RG3_EMP = '" + cEmpAnt + "'"
	cQuery += " AND "
	cQuery := " RG3_PROCES = '" + cProcesso  + "'"
	cQuery += " AND "
	cQuery += " RG3_PERIOD = '" + cPeriodo + "'"
	cQuery += " AND "
	cQuery += " RG3_SEMANA = '" + cNroPagto + "'"
	cQuery += " AND "
	cQuery += " D_E_L_E_T_ = ' ' "

	DbSelectArea( "RG3" )
	DbSetOrder( nOrdRG3 )
	aColsRG3:= GdMontaCols(	@aHeaderRG3,	; //01 -> Array com os Campos do Cabecalho da GetDados
							@nUsadoRG3,		; //02 -> Numero de Campos em Uso
							@aVirtRG3,		; //03 -> [@]Array com os Campos Virtuais
							@aVisuaRG3,		; //04 -> [@]Array com os Campos Visuais
							"RG3",			; //05 -> Opcional, Alias do Arquivo Carga dos Itens do aCols
							@aNoCpoRG3		,; //06 -> Opcional, Campos que nao Deverao constar no aHeader
							@aColsRG3,		; //07 -> [@]Array unidimensional contendo os Recnos
							"RG3",			; //08 -> Alias do Arquivo Pai
							cSeek,			; //09 -> Chave para o Posicionamento no Alias Filho
							bSeekWhile		,;//10 -> Bloco para condicao de Loop While
							bSkip,			; //11 -> Bloco para Skip no Loop While
							Nil,			; //12 -> Se Havera o Elemento de Delecao no aCols
							Nil,			; //13 -> Se cria variaveis Publicas
							Nil,			; //14 -> Se Sera considerado o Inicializador Padrao
							Nil,			; //15 -> Lado para o inicializador padrao
							Nil,			; //16 -> Opcional, Carregar Todos os Campos
							Nil,			; //17 -> Opcional, Nao Carregar os Campos Virtuais
							cQuery,			; //18 -> Opcional, Utilizacao de Query para Selecao de Dados
							.F.,			; //19 -> Opcional, Se deve Executar bKey  ( Apenas Quando TOP )
							.F.,			; //20 -> Opcional, Se deve Executar bSkip ( Apenas Quando TOP )
							.F.,			; //21 -> Carregar Coluna Fantasma e/ou BitMap ( Logico ou Array )
							Nil,			; //22 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
							Nil,			; //23 -> Verifica se Deve Checar se o campo eh usado
							Nil,			; //24 -> Verifica se Deve Checar o nivel do usuario
							Nil,			; //25 -> Verifica se Deve Carregar o Elemento Vazio no aCols
							Nil,			; //26 -> [@]Array que contera as chaves conforme recnos
							Nil,			; //27 -> [@]Se devera efetuar o Lock dos Registros
							Nil,			; //28 -> [@]Se devera obter a Exclusividade nas chaves dos registros
							Nil,			; //29 -> Numero maximo de Locks a ser efetuado
							.F.,			; //30 -> Utiliza Numeracao na GhostCol
							Nil,			; //31 -> Carrega os Campos de Usuario
							nOpcx			) //32 -> Numero correspondente a operacao a ser executada

	// Carrega nomes dos usuarios(campos sao virtuais)
	GP710Nome( @aColsRG3, .T. )
	// Carrega nome das filiais(campos sao virtuais)
	fDFilial()

	RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GP710Nome ³ Autor ³ Equipe RH          ³ Data ³ 10/05/2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Preenche o Nome do Usuario.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA710                                                    ³±±
±±³          ³ X3_VALID - RG3_USER1 / RG3_USER2 / RG3_USER3 / RG3_USER4   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */
Function GP710Nome( aColsTmp, lAll )
Local cVar		:= ReadVar()
Local nPosUser1 := 0
Local nPosUser2 := 0
Local nPosNome1 := 0
Local nPosNome2 := 0
Local nPosNome	:= 0
Local nX 		:= 0
Local nLinha	:= 0

DEFAULT lAll     := .F.
DEFAULT aColsTmp := aCols


    // Monta nome dos usuarios
	nPosUser1 := GdFieldPos( "RG3_USER1"  , aHeaderRG3 )
	nPosUser2 := GdFieldPos( "RG3_USER2"  , aHeaderRG3 )
	nPosNome1 := GdFieldPos( "RG3_NUSER1" , aHeaderRG3 )
	nPosNome2 := GdFieldPos( "RG3_NUSER2" , aHeaderRG3 )


	If nPosUser1 > 0 .And. nPosUser2 > 0 .And. nPosNome1 > 0 .And. nPosNome2 > 0
		If lAll  // Chamada pelo fonte GPEA710
			For nX := 1 to Len(aColsTmp)
				aColsTmp[nX,nPosNome1] := UsrRetName( aColsTmp[nX,nPosUser1] )
				aColsTmp[nX,nPosNome2] := UsrRetName( aColsTmp[nX,nPosUser2] )
			Next nX
		Else    // Chamada pelos campos RG3_USER1 / RG3_USER2 / RG3_USER3 / RG3_USER4
			nLinha	:= oGetRG3:nAt
			nPosNome:= If (cVar == "M->RG3_USER1", nPosNome1, nPosNome2)
			If !Empty( cVar )
				aColsTmp[nLinha,nPosNome] := UsrRetName( &(cVar) )
			Else
				aColsTmp[nLinha,nPosNome] := " "
			EndIf

		EndIf
	EndIf

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fDFilial  ³ Autor ³ Equipe RH            ³ Data ³ 18/01/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Preenche os nomes das Filiais(RG3_FIL).                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA710                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */
Static Function fDFilial()

Local aArea		:= GetArea()
Local nPosFil	:= GdFieldPos("RG3_FIL", aHeaderRG3)
Local nPosDFil	:= GdFieldPos("RG3_DFIL", aHeaderRG3)
Local nPos 		:= 0
Local nX		:= 0

	For nX := 1 to Len(aColsRG3)
		If (nPos := aScan(aFils,{|x| Alltrim(x[1] + x[2]) == Alltrim(cEmpAnt + aColsRG3[nX, nPosFil])})) > 0
			aColsRG3[nX, nPosDFil] := aFils[nPos,3]
		EndIf
	Next nX

	RestArea(aArea)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MontaEdit ³ Autor ³ Equipe RH            ³ Data ³ 10/05/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta aGdAltRG3 com os Campos Editaveis.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA710                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */
Static Function MontaEdit()
Local aArea	:= GetArea()
Local nX 	:= 0

	aGdAltPai := {}

	For nX := 1 To nUsadoRG3
		If (( aScan(aVirtRG3,   aHeaderRG3[nX,02]) == 0 ) .And. 			;
			( aScan(aVisuaRG3,  aHeaderRG3[nX,02]) == 0 ) .And. 			;
			( aScan(aNoCpoRG3,  aHeaderRG3[nX,02]) == 0 ) .And. 			;
			( aScan(aNAltRG3,   aHeaderRG3[nX,02]) == 0 ) 				   )

			aAdd( aGdAltRG3, aHeaderRG3[nX,02] )
		EndIf
	Next

	RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fVldBloq()³ Autor ³ Equipe RH            ³ Data ³ 17/09/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida bloqueio por Filial.			                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ X3_VALID - RG3_FIL                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */
Function fVldBloq()
Local aArea			:= GetArea()
Local aRot			:= {}
Local cRotCpo		:= ""
Local cFilGet		:= ""
Local cRotGet		:= ""
Local cReadVar		:= ReadVar()
Local lRet			:= .T.
Local nTam			:= 0
Local nX			:= 0
Local nPos1			:= 1
Local nLinPos		:= 0
Local nPosFil		:= GdFieldPos("RG3_FIL")
Local nPosRot 		:= GdFieldPos("RG3_ROTEIR")
Local nTamCpo		:= GetSx3Cache("RY_CALCULO","X3_TAMANHO")

	If Empty(cX2RG3)
	    dbSelectArea("SX2")
	    dbSetOrder(1)
	    dbSeek("RG3")
	    cX2RG3 := X2Nome()
	EndIf

	If nPosFil > 0
		If IsMemVar("RG3_FIL")
			cFilGet := GetMemVar("RG3_FIL")
		Else
			cFilGet	:= aCols[oGetRG3:nAt,nPosFil]
		EndIf
	Else
		Return(lRet)
	EndIf

	If IsMemVar("RG3_ROTEIR")
		cRotGet := GetMemVar("RG3_ROTEIR")
	Else
		cRotGet	:= aCols[oGetRG3:nAt,nPosRot]
	EndIf

	If (cReadVar == "M->RG3_FIL") .And. (Alltrim(cSis) # Left(cFilGet,Len(Alltrim(cSis))) .Or. aScan( aFils, { |x| Alltrim(x[2]) == Alltrim(cFilGet) }) == 0 )
		MsgAlert(OemToAnsi(STR0077 + "RG3-" + Alltrim(cX2RG3) + "."), OemToAnsi(STR0007))// "Atencao"###"Selecione uma filial associada ao período utilizado, de acordo ao modo de acesso da tabela RG3-"
		lRet	:= .F.
		Return(lRet)
	EndIf

	If cReadVar == "M->RG3_ROTEIR"
		While Len(cRotGet) > 0
	   		cRotCpo := SubStr(cRotGet,nPos1,nTamCpo)
			AADD(aRot, cRotCpo)
			nPos2 	:= AT("*", cRotGet)
			If nPos2 > 0
				cRotGet	:= SubStr(cRotGet,nPos2+1,Len(cRotGet)-1)
			Else // Limpa cRotGet para finalizar
				cRotGet := ""
			EndIf
		EndDo

	 	nLinPos	:= oGetRG3:nAt // Linha posicionada
		For nX := 1 To Len(oGetRG3:aCols)
			If nX <> nLinPos
				nPos	:= aScan(aRot,{|X| X $ aCols[nX,nPosRot]})
				If aCols[nX,nPosFil] == cFilGet .And. nPos > 0 .And. ;
					aCols[nX][Len(aCols[nX])] == .F. // Nao deletada
			    	MsgAlert(OemToansi(STR0065) ,  OemToAnsi( STR0007 ) )// "Atencao"###"Verifique o(s) roteiro(s) cadastrados para essa filial - dados duplicados!"
					lRet	:= .F.
					Return(lRet)
			    EndIf
		    EndIf
		Next nX
	EndIf

	RestArea(aArea)
Return( lRet )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ fIntData	³ Autor ³ Equipe RH         	³ Data ³ 18/07/13 |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica intervalo de datas.   			                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ X3_VALID - RG3_DTINI/RG3_DTFIM							  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function fIntData()
Local cReadVar	:= ReadVar()
Local dDtFim	:= Ctod("")
Local dDtIni	:= Ctod("")
Local lRet      := .T.
Local nLinha	:= oGetRG3:nAt
Local nColFil   := aScan(aHeaderRG3 ,{|x| Alltrim(Upper(x[2]))== "RG3_FIL"})
Local nColDtIni := aScan(aHeaderRG3 ,{|x| Alltrim(upper(x[2]))== "RG3_DTINI"})
Local nColDtFim := aScan(aHeaderRG3 ,{|x| Alltrim(upper(x[2]))== "RG3_DTFIM"})
Local nX

	dDtIni		:= If( AllTrim(Substr(cReadVar,4))== "RG3_DTINI",&(ReadVar()),If (nColDtIni > 0,aCols[nLinha,nColDtIni],""))
	dDtFim		:= If( AllTrim(Substr(cReadVar,4))== "RG3_DTFIM",&(ReadVar()),If (nColDtFim > 0,aCols[nLinha,nColDtFim],""))
	cAnoMesI  	:= MesAno(dDtIni)
	cAnoMesF  	:= MesAno(dDtFim)

	If !Empty(dDtFim) .And. ( dDtFim < dDtIni )
	   	Help(" ",1,"DATA2INVAL")  // "A Data de Fim nao pode ser menor do que a Data de Inicio."
		lRet := .F.
	EndIf

	If !(IsIncallStack("PONA290"))

	   	If !Empty(dDtIni) .And. ( dDtIni < RFQ->RFQ_DTINI )
		   	MsgAlert(OemToansi(STR0066) + DtoC(RFQ->RFQ_DTINI) ,  OemToAnsi( STR0007 ) )  // "Aviso"###"A data inicial nao pode anteceder a data inicial do periodo selecionado - "
			lRet := .F.
		EndIf

		If !Empty(dDtFim) .And. ( dDtFim < RFQ->RFQ_DTINI )
		   	MsgAlert(OemToansi(STR0067) + DtoC(RFQ->RFQ_DTINI) ,  OemToAnsi( STR0007 ) )  // "Aviso"###"A data final nao pode anteceder a data inicial do periodo selecionado - "
			lRet := .F.
		EndIf

	   	If !Empty(dDtIni) .And. ( dDtIni > RFQ->RFQ_DTFIM )
		   	MsgAlert(OemToansi(STR0063) + DtoC(RFQ->RFQ_DTFIM) ,  OemToAnsi( STR0007 ) )  // "Aviso"###"A data inicial nao pode ultrapassar a data final do periodo selecionado - "
			lRet := .F.
		EndIf

	EndIf

Return( lRet )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GPA710LinOk ³ Autor ³ Equipe RH          ³ Data ³ 10/05/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao da Linha Digitada no aCols.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA710                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */
Function GPA710LinOk()
Local aArea			:= GetArea()
Local aCposKey		:= {}
Local aCols_Aux		:= oGetRG3:aCols
Local lLinOk		:= .T.
Local nHeaders		:= Len(oGetRG3:aHeader)+1
Local nColUsr1   	:= 0
Local nColusr2   	:= 0
// Variaveis para validacao de linha duplicada ref Roteiro
Local aRot			:= {}
Local cRotCpo		:= ""
Local cFilGet		:= ""
Local cRotGet		:= ""
Local lRet			:= .T.
Local nTam			:= 0
Local nX			:= 0
Local nPos1			:= 1
Local nLinPos		:= 0
Local nPosFil		:= GdFieldPos("RG3_FIL")
Local nPosRot 		:= GdFieldPos("RG3_ROTEIR")
Local nTamCpo		:= GetSx3Cache("RY_CALCULO","X3_TAMANHO")
Local nPosUsr		:= GdFieldPos("RG3_USER1")
Local cUserFil		:= ""
Local cUser2Fil		:= ""

	Begin Sequence

		// Verifica apenas Itens Nao Deletados
		If !aCols_Aux[ oGetRG3:nAt,nHeaders ]

			// Validacao de linha para roteiros duplicados
			// Carrega aRot com os roteiros selecionados no campo
			cFilGet	:= aCols[oGetRG3:nAt,nPosFil]
			cRotGet	:= aCols[oGetRG3:nAt,nPosRot]

			//Validacao de acesso de filial do usuario
			If !( AllTrim( cFilGet) $ fValidFil() )
				MsgAlert(OemToansi(STR0068) ,  OemToAnsi( STR0007 ) ) //Usuario sem acesso a filial escolhida. Favor escolher outra filial.
				lLinOk	:= .F.
				Break
			EndIf

			While Len(cRotGet) > 0
		   		cRotCpo := SubStr(cRotGet,nPos1,nTamCpo)
				AADD(aRot, cRotCpo)
				nPos2 	:= AT("*", cRotGet)
				If nPos2 > 0
					cRotGet	:= SubStr(cRotGet,nPos2+1,Len(cRotGet)-1)
				Else // Limpa cRotGet para finalizar
					cRotGet := ""
				EndIf
			EndDo

		 	nLinPos	:= oGetRG3:nAt // Linha posicionada
			For nX := 1 To Len(oGetRG3:aCols)
				If nX <> nLinPos
					nPos	:= aScan(aRot,{|X| X $ aCols[nX,nPosRot]})
					If aCols[nX,nPosFil] == cFilGet .And. nPos > 0 .And. ;
						aCols[nX][Len(aCols[nX])] == .F. // Nao deletada
				    	MsgAlert(OemToansi(STR0065) ,  OemToAnsi( STR0007 ) )// "Atencao"###"Verifique o(s) roteiro(s) cadastrados para essa filial - dados duplicados!"
						lLinOk	:= .F.
						Break
				    EndIf
			    EndIf
			Next nX

			// Verifica Se o Campos Estao Devidamente Preenchidos
			aAdd(aCposKey, "RG3_FIL")
			aAdd(aCposKey, "RG3_ROTEIR")
			aAdd(aCposKey, "RG3_DTINI")
			aAdd(aCposKey, "RG3_DTFIM")
			If !( lLinOk := GdNoEmpty( aCposKey, oGetRG3:nAt, oGetRG3:aHeader, oGetRG3:aCols,  ) )
				Break
			EndIf

			nColUsr1   	:= aScan(aHeaderRG3 ,{|x| AllTrim(Upper(x[2]))== "RG3_USER1"})
			nColUsr2   	:= aScan(aHeaderRG3 ,{|x| AllTrim(Upper(x[2]))== "RG3_USER2"})

			If nColUsr1 > 0 .And. nColUsr2 > 0
				If  Empty(aCols[oGetRG3:nAt,nColUsr1]) .And. Empty(aCols[oGetRG3:nAt,nColUsr2])
					MsgAlert(OemToansi(STR0061) ,  OemToAnsi( STR0007 ) )// "Atencao"###"Informe ao menos um usuario liberado."
					lLinOk	:= .F.
					Break
				EndIf
			EndIf

			// --> Verifica os campos de usuário que estão preenchidos para que não seja gerado erro no momento da consulta dos acessos.
			If !Empty(aCols[oGetRG3:nAt, nColUsr1])
				cUserFil := AllStrFil(aCols[oGetRG3:nAt, nColUsr1])
			EndIf

			If !Empty(aCols[oGetRG3:nAt, nColUsr2])
				cUser2Fil := AllStrFil(aCols[oGetRG3:nAt, nColUsr2])
			EndIf

			//Validacao de acesso de filial do usuario RG3_USER1
			If !Empty(aCols[oGetRG3:nAt,nColUsr1])
				If !(cUserFil == ".T.")
					If !( AllTrim( cFilGet ) $ cUserFil )
						MsgAlert(OemToansi(STR0069) + Alltrim(aCols[oGetRG3:nAt,nColUsr1]);
								 + OemToAnsi(STR0070) , OemToAnsi( STR0007 ) ) //Usuario ### sem acesso a filial escolhida. Favor escolher outra filial.
						lLinOk	:= .F.
						Break
					EndIf
				EndIf
			EndIf

			//Validacao de acesso de filial do usuario RG3_USER2
			If !Empty(aCols[oGetRG3:nAt,nColUsr2])
				If !(cUser2Fil == ".T.")
					If !( AllTrim( cFilGet ) $ cUser2Fil )
						MsgAlert(OemToansi(STR0069) + Alltrim(aCols[oGetRG3:nAt,nColUsr2]);
								 + OemToAnsi(STR0070) , OemToAnsi( STR0007 ) ) //Usuario ### sem acesso a filial escolhida. Favor escolher outra filial.
						lLinOk	:= .F.
						Break
					EndIf
				EndIf
			EndIf
		EndIf

	End Sequence

	RestArea(aArea)

Return( lLinOk )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GPA710TudOk ³ Autor ³ Equipe RH          ³ Data ³ 10/05/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao Geral da aCols na Confirmacao.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA710                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */
Function GPA710TudOk()
Local aArea		:= GetArea()
Local lTudoOk	:= .T.		// Variavel para controle de Retorno
Local nX		:= 0

	For nX := 1 To Len(oGetRG3:aCols)
		oGetRG3:nAt := nX
	 	If !(lTudoOk := GPA710LinOk())
			Exit
	 	EndIf
	Next nX

	RestArea(aArea)

Return( lTudoOk )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fGp710Grv ³ Autor ³ Equipe RH            ³ Data ³ 10/05/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gravacao dos Registros do aCols na Tabela RG3.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias     = Alias da tabela p/ gravacao                   ³±±
±±³          ³ aVirtual   = Array com campos virtuais                     ³±±
±±³          ³ nOpcx     = Numero da opcao selecionada                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA710                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */
Static Function fGp710Grv( cAlias , aVirtual , nOpcx )
Local aHeaderAux 	:= aClone( oGetRG3:aHeader )
Local aColsAux   	:= aClone( oGetRG3:aCols )
Local aColsAnt   	:= aClone( aColAntRG3 )
Local cPrefixo   	:= ( PrefixoCpo( cAlias ) + "_" )
Local cCampo     	:= ""
Local lTudoIgual 	:= .F.
Local lTravou		:= .F.
Local nX         	:= 0
Local nY         	:= 0
Local nLenHeader 	:= Len( aHeaderAux )
Local nLenCols   	:= Len( aColsAux )
Local nPosDel    	:= GdFieldPos( "GDDELETED" , aHeaderAux)
Local nPosRec		:= GdfieldPos("RG3_REC_WT",aHeaderRG3)
Local nPosDatarq
Local cDataBloq		:= ""
Local cNrPgtBloq	:= ""

	nLenCols := Len( aColsAux )

	Begin Transaction

		If !fCompArray( aColsAux , aColsAnt )
			For nX := 1 To nLenCols
				lTravou:=.F.
				If aColsAux[nX][nPosRec] > 0   // Registro pre-existente
			    	(cAlias)->(DBGoto(aColsAux[nX][nPosRec]))
					RecLock("RG3", .F.,.T.)   // Alteracao
					lTravou:=.T.
				Else
					If !(aColsAux[nX][Len(aColsAux[nX])])  // Nova linha
						RecLock("RG3",.T.)  // Inclusao
						lTravou:=.T.
					EndIf
				EndIf

                    If lTravou
					If ( aColsAux[nX,nPosDel] ) // Linha deletada
						(cAlias)->( dbDelete() )
					Else

						cDataBloq 	:= DtoS(SPO->PO_DATAINI)
						cDataBloq 	:= Substr(cDataBloq,1,6)
						cNrPgtBloq	:= Substr(Dtoc(SPO->PO_DATAINI),1,2)

						(cAlias)->(&(cPrefixo+"FILIAL")) 	:= cSis
						(cAlias)->(&(cPrefixo+"EMP")) 		:= cEmpAnt
						(cAlias)->(&(cPrefixo+"PERIOD")) 	:= Iif(IsIncallStack("PONA290"),cDataBloq,cPeriodo)
						(cAlias)->(&(cPrefixo+"SEMANA")) 	:= Iif(IsIncallStack("PONA290"),cNrPgtBloq,cNroPagto)
						(cAlias)->(&(cPrefixo+"PROCES")) 	:= cProcesso

						For nY := 1 To nLenHeader
							//Obtem o Campo para Gravacao
							cCampo := aHeaderAux[nY,2]
							//Nao Grava Campo Virtual
							If aScan(aVirtual,cCampo) # 0
								Loop
							EndIf
							(cAlias)->( &cCampo ) := aColsAux[nX,nY]
						Next nY
					EndIf
				EndIf
				//Destrava o Registro
				( cAlias )->( MsUnLock() )
			Next nX
			( cAlias )->( EvalTrigger() )
		EndIf

	End Transaction

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fVldAccess ³ Autor ³ Equipe RH          ³ Data ³ 10/05/07   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para Validar o Acesso dos Usuarios.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fVldAccess(c_Filial,dData,c_Semana,lAviso,cRoteiro,cTpAviso)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ c_Filial = Filial que esta sendo processada                 ³±±
±±³          ³ dData    = Data de Referencia                               ³±±
±±³          ³ c_Semana = Semana de Referencia                             ³±±
±±³          ³ lAviso   = Indica se Demonstrara Aviso ao Usuario           ³±±
±±³          ³ cRoteiro = Roteiro de Esta Sendo Calculado                  ³±±
±±³          ³ cTpAviso = Define a Mensagem que Sera Retornada ao Usuario  ³±±
±±³          ³ cTipoVld = Tipo de Validacao - (G)eral / (V)erba            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FONTES DIVERSOS                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */
Function fVldAccess( c_Filial, dData, c_Semana, lAviso, cRoteiro, cTpAviso, cTipoVld, lPortal )
Local aArea    	:= GetArea()
Local cCodUser 	:= RetCodUsr()
Local cDtIni   	:= "RG3->RG3_DTINI"
Local cDtFim	:= "RG3->RG3_DTFIM"
Local cAviso   	:= ""
Local cSisFil
Local cMesAno
Local cVerba
Local cMsg	   		:= ""
Local cFilSrv		:= ""
Local cRG3Mod		:= ""
Local cRG3Seek	:= ""
Local cNewSeek	:= ""
Local lRet     	:= .T.
Local lAdtPd   	:= .T.
Local lTemAdt  	:= .F.
Local nAcolsA  	:= 1
Local nPd	   		:= 0
Local lBloqPon	:= .T.

DEFAULT dData    := dDataBase
DEFAULT c_Semana := "01"
DEFAULT c_Filial := cFilAnt
DEFAULT lAviso   := .T.
DEFAULT cRoteiro := fGetRotOrdinar()
DEFAULT cTpAviso := "1"
DEFAULT cTipoVld := "G"	//(G)eral / (V)erba
DEFAULT lPortal  := .F.

	cSisFil := xFilial( "RG3" )
	cRG3Mod := xFilial( "RG3", c_Filial )
	If ( ValType( dData ) == "D" )
		cMesAno := MesAno( dData )  // Data de referencia
	Else
		cMesAno	:= dData // Perido
	EndIf

	dbSelectArea("RG3")
	RG3->(dbSetOrder( 3 ))

	If cRoteiro <> "PON"
		lBloqPon := RG3->(dbSeek( xFilial("RG3") + cEmpAnt + c_Filial + cMesAno + c_Semana ))
	Else
		lBloqPon := RG3->(dbSeek( xFilial("RG3") + cEmpAnt + c_Filial + cMesAno))
	Endif

	While RG3->( RG3->RG3_FILIAL + cEmpAnt + c_Filial + cMesAno) == RG3_FILIAL+RG3_EMP+RG3_FIL+RG3_PERIOD

		If !lRet .And. cRoteiro <> "PON" .And. !RG3->(dbSeek( RG3->RG3_FILIAL + cEmpAnt + c_Filial + cMesAno + c_Semana ))
			Exit
		Endif

		If lBloqPon // Busca filial completa ou apenas unidade/empresa, de acordo a modo de compartilh. da RG3
			If cRoteiro $ RG3->RG3_ROTEIR

				If !Empty( (&cDtIni) ) .And. !Empty( (&cDtFim) ) .And.;	// Campos datas preenchidas
					Date() >= (&cDtIni) .And. Date() <= (&cDtFim) .And.;	// Data do sistema dentro do periodo de bloqueio
					(!(cCodUser $ RG3->RG3_USER1 + "/" + RG3->RG3_USER2) .Or. lPortal) // Valida usuario de acesso

					// Tipo de Validacao - Geral
					If cTipoVld == "G"
						lRet := .F.
					EndIf

					// Tipo de Validacao - Verbas
					If cTipoVld == "V"
						aSRVArea := SRV->(GetArea())
						aSRCArea := SRC->(GetArea())
						If Upper(AllTrim(FunName())) == "GPEA580"	// Lancamento Mensal
							If oGet:oBrowse:nAt <= Len(aColsAnt) .And. !fCompArray(aCols[oGet:oBrowse:nAt], aColsAnt[oGet:oBrowse:nAt])

								If Upper(AllTrim(PosSrv(aCols[oGet:oBrowse:nAt,GdFieldPos("RGB_PD")],SRA->RA_FILIAL,"RV_ADIANTA"))) == "S" .Or. ;
									aCols[oGet:oBrowse:nAt,GdFieldPos("RGB_PD")] $ (	PosSrv("0006", SRA->RA_FILIAL, "RV_COD", RetOrdem("SRV","RV_FILIAL+RV_CODFOL"), .F. )+"/"+;
																						PosSrv("0007", SRA->RA_FILIAL, "RV_COD", RetOrdem("SRV","RV_FILIAL+RV_CODFOL"), .F. )+"/"+;
																						PosSrv("0008", SRA->RA_FILIAL, "RV_COD", RetOrdem("SRV","RV_FILIAL+RV_CODFOL"), .F. )+"/"+;
																				 		PosSrv("0009", SRA->RA_FILIAL, "RV_COD", RetOrdem("SRV","RV_FILIAL+RV_CODFOL"), .F. )+"/"+;
																						PosSrv("0010", SRA->RA_FILIAL, "RV_COD", RetOrdem("SRV","RV_FILIAL+RV_CODFOL"), .F. )+"/"+;
																						PosSrv("0011", SRA->RA_FILIAL, "RV_COD", RetOrdem("SRV","RV_FILIAL+RV_CODFOL"), .F. )+"/"+;
																						PosSrv("0012", SRA->RA_FILIAL, "RV_COD", RetOrdem("SRV","RV_FILIAL+RV_CODFOL"), .F. )+"/"+;
																						PosSrv("0059", SRA->RA_FILIAL, "RV_COD", RetOrdem("SRV","RV_FILIAL+RV_CODFOL"), .F. )+"/"+;
																						PosSrv("0546", SRA->RA_FILIAL, "RV_COD", RetOrdem("SRV","RV_FILIAL+RV_CODFOL"), .F. ) )
									lRet := .F.
								EndIf
							EndIf

						ElseIf Upper(AllTrim(FunName())) == "GPEM040"	// Calculo de Rescisao

							nPosPd		:= GdFieldPos("RR_PD")
							nPosTipo2	:= GdFieldPos("RR_TIPO2")
							nPosSemana	:= GdFieldPos("RR_SEMANA")
							nPosCc		:= GdFieldPos("RR_CC")
							nPosItem	:= GdFieldPos("RR_ITEM")
							nPosClVl	:= GdFieldPos("RR_CLVL")
							nPosValor	:= GdFieldPos("RR_VALOR")
							nPosHoras	:= GdFieldPos("RR_HORAS")
							nPosDtPg	:= GdFieldPos("RR_DATAPAG")
							nPosDel		:= GdFieldPos("GDDELETED")

							lTemAdt	:= .F.

							// Verifica se existe alguma verba com incidencia no adiantamento e
							// Garante que nenhuma verba de adiantamento foi excluida
							For nPd := 1 To Len( aColsAnt )
								IF 	lAdtPd
									// Faz tratamento diferenciado qdo. rescisao para o mes seguinte
									If lRescMSeg
										// Na rescisao p/ mes seguinte, na 1a. tela da resc. as verbas aparecem ndeletadas, e na segunda as verbas nao aparecem
										lAdtPd := aScan( aCols, { |x| x[nPosPd] == aColsAnt[nPd][nPosPd] .And. x[nPosDel] } ) > 0 .Or. aScan( aCols, { |x| x[nPosPd] == aColsAnt[nPd][nPosPd] .And. aColsAnt[nPd][nPosTipo2] == "A" } ) == 0
									Else
										// A verba de ded. de dependente (id. 059) eh a mesma para folha e adiantamento, logo trata-se tb a origem 'R'
										If (  ;
									 			  ( ( aScan( aCols, { |x| x[nPosPd] == aColsAnt[nPd][nPosPd] .And. aColsAnt[nPd][nPosTipo2] $ "A" } )  ) > 0 ) ;
									 			.And.;
												( aScan( aCols, { |x| x[nPosPd] == aColsAnt[nPd][nPosPd] .And. x[nPosDel] == aColsAnt[nPd][nPosDel] } )  == 0 );
										   )

											lAdtPd := .F.
										EndIf
									EndIf
								Endif
								// Verifica se existe pelo menos uma verba com incidencia para Adiantamento
								lTemAdt := IIF(Upper(AllTrim(PosSrv(aColsant[nPd, nPosPd],Sra->Ra_Filial,"RV_ADIANTA"))) == "S" , .T., lTemAdt)

								// Se satisfez ambas as condicoes, sai do Loop antes do termino
								If lTemAdt .And. (!lAdtPd)
								   Exit
								EndIf
							Next

		 					// Realiza consistencias apenas se existir verbas para adiantamento
							If lTemAdt
								// Verifica se o lancamento posicionado foi modificado
								If lAdtPd
									If ( Upper(AllTrim(PosSrv(aCols[oGet:oBrowse:nAt,nPosPd],Sra->Ra_Filial,"RV_ADIANTA"))) == "S" .Or. ;
										aCols[oGet:oBrowse:nAt,nPosPd] $ StrTran( 	aCodFol[6,1]	+	"/"	+	aCodFol[7,1]	+	"/"	+	aCodFol[8,1]	+	"/"	+;
																					aCodFol[9,1]	+	"/"	+	aCodFol[10,1]	+	"/"	+	aCodFol[11,1]	+	"/"	+;
																					aCodFol[12,1]	+	"/"	+	aCodFol[59,1]	+	"/"	+	aCodFol[546,1]			," ","" ) )

										If ( nPos := aScan( aColsAnt, { |x| x[nPosPd] == aCols[oGet:oBrowse:nAt][nPosPd] .And. If( lRescMSeg, x[nPosDel] .And. aCols[oGet:oBrowse:nAt][nPosDel], !x[nPosDel] .And. !aCols[oGet:oBrowse:nAt][nPosDel] ) } ) ) > 0
											If !lRescMSeg
												If ( cValToChar( aCols[oGet:oBrowse:nAt][nPosHoras] ) + cValToChar( aCols[oGet:oBrowse:nAt][nPosValor] ) ) <> (cValToChar( aColsAnt[nPos][nPosHoras] ) + cValToChar( aColsAnt[nPos][nPosValor] ) )
													cMsg += CRLF + STR0035 // "Houve mudanca de quantidade de horas ou valor do lancamento."
													lRet := .F.
												EndIf

												If aCols[oGet:oBrowse:nAt][nPosSemana] + aCols[oGet:oBrowse:nAt][nPosCc] <> aColsAnt[nPos][nPosSemana] + aColsAnt[nPos][nPosCc]
													cMsg += CRLF + STR0036 // "Houve mudanca de semana ou centro de custo do lancamento."
													lRet := .F.
												EndIf

												If nPosItem > 0 .And. nPosClVl > 0 .And. ( aCols[oGet:oBrowse:nAt][nPosItem] + aCols[oGet:oBrowse:nAt][nPosClVl] ) <> ( aColsAnt[nPos][nPosItem] + aColsAnt[nPos][nPosClVl] )
													cMsg += CRLF + STR0037 // "Houve mudanca de item contábil ou classe de valor do lancamento."
													lRet := .F.
												EndIf

												If aCols[oGet:oBrowse:nAt][nPosDtPg] <> aColsAnt[nPos][nPosDtPg]
													cMsg += CRLF + STR0038 // "Houve mudanca de data de pagamento do lancamento."
													lRet := .F.
												EndIf

												If !( aCols[oGet:oBrowse:nAt][nPosTipo2] $ aColsAnt[nPos][nPosTipo2] + "*R" )
													cMsg += CRLF + STR0039 // "Houve mudanca de origem do lancamento."
													lRet := .F.
												EndIf
											EndIf
										ElseIf !aCols[oGet:oBrowse:nAt][nPosDel] .AND. (!aCols[oGet:oBrowse:nAt][nPosTipo2] $ 'R')
											cMsg += CRLF + STR0040 // "Foram incluidos ou excluidos lançamentos de adiantamento."
											lRet := .F.
										EndIf
									EndIf
								Else
									cMsg += CRLF + STR0041 // "Lancamentos de adiantamento foram excluidos, incluidos ou modificados pelo usuario."
									lRet := .F.
								EndIf
							Endif
						Else
							If Upper(Alltrim(FunName())) $ "GPEA590/GPEM170/TMSA740"	// Lancamento por Verba / Geracao de Verbas
								cVerba   	:= SRV->RV_COD
								cFilSrv		:= SRV->RV_FILIAL
							ElseIf Upper(Alltrim(FunName())) == "GPEM160"	// Cancelamento de Calculo
								cVerba   	:= SRC->RC_PD
								cFilSrv		:= SRC->RC_FILIAL
							EndIf

							If Upper(AllTrim(PosSrv(cVerba,cFilSrv,"RV_ADIANTA"))) == "S" .Or. ;
													cVerba $ (	PosSrv("0006", cFilSrv, "RV_COD", RetOrdem("SRV","RV_FILIAL+RV_CODFOL"), .F. )+"/"+;
																PosSrv("0007", cFilSrv, "RV_COD", RetOrdem("SRV","RV_FILIAL+RV_CODFOL"), .F. )+"/"+;
																PosSrv("0008", cFilSrv, "RV_COD", RetOrdem("SRV","RV_FILIAL+RV_CODFOL"), .F. )+"/"+;
																PosSrv("0009", cFilSrv, "RV_COD", RetOrdem("SRV","RV_FILIAL+RV_CODFOL"), .F. )+"/"+;
																PosSrv("0010", cFilSrv, "RV_COD", RetOrdem("SRV","RV_FILIAL+RV_CODFOL"), .F. )+"/"+;
																PosSrv("0011", cFilSrv, "RV_COD", RetOrdem("SRV","RV_FILIAL+RV_CODFOL"), .F. )+"/"+;
																PosSrv("0012", cFilSrv, "RV_COD", RetOrdem("SRV","RV_FILIAL+RV_CODFOL"), .F. )+"/"+;
																PosSrv("0059", cFilSrv, "RV_COD", RetOrdem("SRV","RV_FILIAL+RV_CODFOL"), .F. )+"/"+;
																PosSrv("0546", cFilSrv, "RV_COD", RetOrdem("SRV","RV_FILIAL+RV_CODFOL"), .F. ) )
								lRet := .F.
							EndIf
						EndIf

						RestArea(aSRVArea)
						RestArea(aSRCArea)
					EndIf

					cMsg := If( !Empty(cMsg), CRLF + STR0042 + cMsg, "" ) // "Detalhes: "

					If !lRet
						If lAviso
							cAviso  :=	Iif(cTpAviso=="1",	STR0015, ;	//"Os lancamentos/calculos estao bloqueados para este periodo! Contate o responsavel do RH!"
										Iif(cTpAviso=="2",	STR0029, ;	//"Existem filiais com restricao de calculo no intervalo selecionado!"
										Iif(cTpAviso=="3",	STR0030, ;	//"As verbas referente a Adiantamento estao bloqueadas para alteracao! Contate o responsavel do RH!"
															STR0031 )))	//"Existem, no intervalo selecionado, filiais com restricao de verbas de Adiantamento!"

							Aviso(STR0007,cAviso+cMsg,{STR0008},3,FunDesc())  //"ATENCAO"###"Lancamentos Bloqueados! Contate o Administrador do RH!"###"Ok"
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
		RG3->(DbSkip())
	EndDo

	RestArea( aArea )

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fValidBloqRes ³ Autor ³ Equipe RH        ³ Data ³ 09/01/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para Validar o Acesso dos Usuarios no calculo da    ³±±
±±³          ³ rescisao.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ c_Filial = Filial que esta sendo processada                ³±±
±±³          ³ dDataRef = Data de Referencia                              ³±±
±±³          ³ cTipoVld = Tipo - (1)Exclusao /(2)Calculo                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEM040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */
Function fValidBloqRes( c_Filial, dDataRef, cTipoVld )
Local aArea     := GetArea()
Local cCodUser 	:= RetCodUsr()
Local cAviso   	:= ""
Local cSisFil
Local cMesAno
Local lRet     := .T.

DEFAULT dDataRef := dDataBase
DEFAULT c_Filial := cFilAnt
DEFAULT cTipoVld := "2"

	cSisFil		:= xFilial( "RG3" )
	c_Filial	:= xFilial( "RG3", c_Filial )
	cMesAno		:= MesAno( dDataRef )
	RG3->(dbSetOrder( 2 )) // RG3_FILIAL+RG3_EMP+RG3_PERIOD+RG3_SEMANA+RG3_ROTEIR+RG3_FIL

	If RG3->(dbSeek( cSisFil + cEmpAnt + cMesAno + cRoteiro + c_Filial))
	    While RG3->( !Eof() .And. RG3_FILIAL + RG3_EMP + RG3_FIL + RG3_PERIOD + RG3_SEMANA  == cSisFil + cEmpAnt + c_Filial + cMesAno  )
			If cRoteiro $ RG3->RG3_ROTEIR
				If Dtos(dDataRef) >= Dtos(RG3->RG3_DTINI) .And. Dtos(dDataRef) <= Dtos(RG3->RG3_DTFIM) .And. !( cCodUser $ RG3->RG3_USER1 + "/" + RG3->RG3_USER2 )
				    cAviso := Iif(cTipoVld=="1",STR0048,; // "Exclusao bloqueada pelo administrador para o periodo: 99/99/9999 -> 99/99/9999"
				                                 STR0049)  // "Calculo bloqueado pelo administrador para o periodo: 99/99/9999 -> 99/99/9999"
			        cAviso := cAviso + Dtoc(RG3->RG3_DTINI) + " -> " + Dtoc(RG3->RG3_DTFIM)
				    lRet := .F.
					Aviso("",cAviso,{STR0008},3)  // "Ok"
		            Exit
				EndIf
			EndIf
	   		RG3->( dbSkip() )
		EndDo
	EndIf

	Restarea( aArea )

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fVldAltPon ³ Autor ³ Equipe RH           ³ Data ³ 14/12/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para validar alteracao de verbas vindas do SIGAPON  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cTpAviso = Define a Mensagem que Sera Retornada ao Usuario.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA100/GPEM040/GPEA160                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */
Function fVldAltPon( cTpAviso )
Local cAviso   := ""

DEFAULT cTpAviso := "1"

	cAviso := Iif( cTpAviso == "1",	STR0032, ;	// "As verbas vindas do SIGAPON estão bloqueadas para alteracao! Contate o responsavel do RH!"
									STR0033 )	// "Existem, no intervalo selecionado, filiais com restricao de verbas vindas do SIGAPON!"

	Aviso(STR0007,cAviso,{STR0008},3,FunDesc())  //"ATENCAO !"###"Lanaamentos vindos do SIGAPON estão Bloqueados! Contate o Administrador do RH!"###"Ok"

Return


//--------------------------------------------------------- ----------------------------//
//---------------------------- INICIO - BLOCO PARA REPLICAS ----------------------------//
//--------------------------------------------------------- ----------------------------//

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    | GPA710Repl ³ Autor ³ Equipe RH           ³ Data ³ 10/05/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para Replicar Informacoes de Datas e Usuarios.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aLocHeader = Array com informacoes da tabela RG3.          ³±±
±±³          ³ aLocCols   = Array com informacoes digitadas.              ³±±
±±³          ³ aLocAltera = Array com campos editaveis.                   ³±±
±±³          ³ aLocVisual = Array com campos visuais.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA710                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */
Static Function GPA710Repl()
Local aArea			:= GetArea()
Local aSvKeys      	:= GetKeys()
Local aListBox     	:= {}
Local aColsLoc     	:= oGetRG3:aCols
Local bSet15      	 := { || nOpcA := 1 , If( oGet:TudoOk() , ( RestKeys( aSvKeys , .T. ) , oDlg2:End() ) , nOpcA := 0 ) }
Local bSet24       	:= { || RestKeys( aSvKeys , .T. ) , oDlg2:End() , nOpcA := 0 }
Local nOpcA        	:= 0
Local lRet         	:= .F.
Local nX           	:= 0
Local nY          	:= 0
Local oOk          	:= LoadBitmap( GetResources(), "LBOK" )
Local oNo          	:= LoadBitmap( GetResources(), "LBNO" )

Local nPosFil      := GdFieldPos( "RG3_FIL"    , aHeaderRG3 )
Local nPosdFil     := GdFieldPos( "RG3_DFIL"   , aHeaderRG3 )
Local nPosRot      := GdFieldPos( "RG3_ROTEIR" , aHeaderRG3 )
Local nPosUser1    := GdFieldPos( "RG3_USER1"  , aHeaderRG3 )
Local nPosUser2    := GdFieldPos( "RG3_USER2"  , aHeaderRG3 )
Local nPosDtIni    := GdFieldPos( "RG3_DTINI"  , aHeaderRG3 )
Local nPosDtFim    := GdFieldPos( "RG3_DTFIM"  , aHeaderRG3 )

Local lCheckGrv    := .F.
Local oDlg2
Local oGet
Local oFont
Local oFontBig
Local oMain
Local oListBox
Local oCheckGrv
Local oBtnMarcTod
Local oBtnDesmTod
Local oBtnInverte

// Declaracao de arrays para dimensionar tela
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aGDCoord		:= {}
Local aButtons 		:= {}

Private aCols   	:= {}
Private aHeader 	:= {}

	// Inicia n pois do Gpea400 vem zerado
	n := 1

    oGetRG3:ForceRefresh()
    // Monta aHeader
	For nX := 1 To Len( aHeaderRG3 )
		If Alltrim( aHeaderRG3[nX,02] ) $ "RG3_DTINI,RG3_DTFIM,RG3_USER1,RG3_USER2,RG3_ROTEIR"
			AADD( aHeader, aHeaderRG3[nX] )
			If AllTrim( aHeaderRG3[nX,02] ) == "RG3_USER1"
				aHeader[Len(aHeader),06] := "Vazio() .Or. UsrExist(M->RG3_USER1)"
			ElseIf AllTrim( aHeaderRG3[nX,02] ) == "RG3_USER2"
				aHeader[Len(aHeader),06] := "Vazio() .Or. UsrExist(M->RG3_USER2)"
			ElseIf Alltrim( aHeaderRG3[nX,02] ) == "RG3_DTINI"
				aHeader[Len(aHeader),06] := "NaoVazio() .And. fVldDtRpl()"
			ElseIf Alltrim( aHeaderRG3[nX,02] ) == "RG3_DTFIM"
				aHeader[Len(aHeader),06] := "NaoVazio() .And. fVldDtRpl()"
			EndIf
		EndIf
	Next

	// Monta aCols
	Aadd(aCols,{})
	For nX := 1 To Len( aHeader )
		If aHeader[nX,08] == "D"
			AADD( aCols[Len(aCols)], Ctod("") )
		ElseIf aHeader[nX,08] == "N"
			AADD( aCols[Len(aCols)], 0 )
		Else
			AADD( aCols[Len(aCols)], Space( aHeader[nX,04] ) )
		EndIf
	Next

	//Carrega no aListBox as registros do RG3 para o periodo atual
	For nX := 1 To Len( aColsLoc )
		AADD( aListBox,{ .T., 						;
						aColsLoc[nX,nPosFil],	 	;
						aColsLoc[nX,nPosdFil],	 	;
						aColsLoc[nX,nPosRot],	 	;
						aColsLoc[nX,nPosDtIni], 	;
						aColsLoc[nX,nPosDtFim], 	;
						aColsLoc[nX,nPosUser1],		;
						aColsLoc[nX,nPosUser2]}		)
	Next nX

	// Monta as Dimensoes dos Objetos
	aAdvSize		:= MsAdvSize()
	aAdvSize[5]	:=	(aAdvSize[5]/100) * 90	// Horizontal
	aAdvSize[6]	:=  (aAdvSize[6]/100) * 85	// Vertical
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )
	aGdCoord	:= { (aObjSize[1,1]+3), (aObjSize[1,2]+5), (((aObjSize[1,3])/100)*75), (((aObjSize[1,4])/100)*88) }

	DEFINE FONT oFont		NAME "Arial" SIZE 0,-11 BOLD
	DEFINE FONT oFontBig	NAME "Arial" SIZE 07,25 BOLD
	DEFINE MSDIALOG oDlg2 TITLE OemToAnsi( STR0006 ) From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMain PIXEL	//"Restricao de Acessos a Rotinas"

		 oGet := MSGetDados():New(aGdCoord[1], aGdCoord[2], (((aObjSize[1,3])/100)*30), aGdCoord[4],4,"GP710RepLOk","GP710RepTOk","",Nil,aGdAltRG3,,,1)

		@ (((aObjSize[1,3])/100)*32) , aGdCoord[2] LISTBOX oListBox FIELDS HEADER ;
		" ",STR0022,STR0023, STR0059, STR0046, STR0047, STR0027, STR0028 ; //"Filial"###"Desc.Filial"###"Data Inicio"###"Data Final"###"Usua Lib 01"###"Usua Lib 02"
		SIZE aGdCoord[4]-3, aGdCoord[3]-(((aObjSize[1,3])/100)*37) PIXEL ON DBLCLICK (GPA710BoxM(oListBox,@aListBox,@oDlg2),oListBox:nColPos := 1,oListBox:Refresh()) NOSCROLL

		oListBox:SetArray(aListBox)
		oListBox:bLine := { || { If(aListBox[oListBox:nAt,1],oOk,oNo), ;
									aListBox[oListBox:nAt,2],			;
									aListBox[oListBox:nAt,3],			;
									aListBox[oListBox:nAt,4],			;
									aListBox[oListBox:nAt,5],			;
									aListBox[oListBox:nAt,6],			;
									aListBox[oListBox:nAt,7],			;
									aListBox[oListBox:nAt,8]}			}
		@ aGdCoord[3]-4,005	BUTTON oBtnMarcTod	PROMPT OemToAnsi( STR0019 )		SIZE 54.50,13.50 OF oDlg2	PIXEL ACTION (GPA710BoxM( oListBox , @aListBox , @oDlg2 , "M" ),oListBox:nColPos := 1,oListBox:Refresh()) // "Marca Todos"
		SetKey(VK_F4,{ || ( GPA710BoxM( oListBox , @aListBox , @oDlg2 , "M" ),oListBox:nColPos := 1,oListBox:Refresh()) } )

		@ aGdCoord[3]-4,061	BUTTON oBtnDesmTod	PROMPT OemToAnsi( STR0020 )		SIZE 54.50,13.50 OF oDlg2	PIXEL ACTION (GPA710BoxM( oListBox , @aListBox , @oDlg2 , "D" ),oListBox:nColPos := 1,oListBox:Refresh()) // "Desmarca Todos"
		SetKey(VK_F5,{ || ( GPA710BoxM( oListBox , @aListBox , @oDlg2 , "D" ),oListBox:nColPos := 1,oListBox:Refresh()) } )

		@ aGdCoord[3]-4,117.5	BUTTON oBtnInverte	PROMPT OemToAnsi( STR0021 ) SIZE 54.50,13.50 OF oDlg2	PIXEL ACTION (GPA710BoxM( oListBox , @aListBox , @oDlg2 , "I" ),oListBox:nColPos := 1,oListBox:Refresh()) // "Inverte Sele‡„o"
		SetKey(VK_F6,{ || ( GPA710BoxM( oListBox , @aListBox , @oDlg2 , "I" ),oListBox:nColPos := 1,oListBox:Refresh()) } )

		@ aGdCoord[3]-2,200 CHECKBOX oCheckGrv VAR lCheckGrv PROMPT OemToAnsi( STR0018 ) SIZE 80,08 OF oDlg2 PIXEL 	//"Gravar Brancos"

	ACTIVATE MSDIALOG oDlg2 CENTERED ON INIT EnchoiceBar( @oDlg2 , bSet15 , bSet24 )

	DeleteObject(oOk)
	DeleteObject(oNo)

	RestKeys( aSvKeys , .T. )

	// Atualiza Dados
	If nOpcA == 1
		For nX := 1 To Len( aCols )
			For nY := 1 To Len( aColsLoc )
				If aListBox[nY,1]
					If lCheckGrv .Or. !Empty( aCols[nX, GdFieldPos("RG3_DTINI" , aHeader)] )
						aColsLoc[nY,nPosDtIni] := aCols[nX, GdFieldPos("RG3_DTINI" , aHeader)]
					EndIf
						If lCheckGrv .Or. !Empty( aCols[nX, GdFieldPos("RG3_DTFIM" , aHeader)] )
						aColsLoc[nY,nPosDtFim] := aCols[nX, GdFieldPos("RG3_DTFIM" , aHeader)]
					EndIf
					If lCheckGrv .Or. !Empty( aCols[nX, GdFieldPos("RG3_USER1"  , aHeader)] )
						aColsLoc[nY,nPosUser1]  := aCols[nX, GdFieldPos("RG3_USER1"  , aHeader)]
					EndIf
					If lCheckGrv .Or. !Empty( aCols[nX, GdFieldPos("RG3_USER2"  , aHeader)] )
						aColsLoc[nY,nPosUser2]  := aCols[nX, GdFieldPos("RG3_USER2"  , aHeader)]
					EndIf
					If lCheckGrv .Or. !Empty( aCols[nX, GdFieldPos("RG3_ROTEIR"  , aHeader)] )
						aColsLoc[nY,nPosRot]  := aCols[nX, GdFieldPos("RG3_ROTEIR"  , aHeader)]
					EndIf
				EndIf
			Next nY
		Next nX
	EndIf

	oGetRG3:aCols := aClone( aColsLoc )
	GP710Nome( @oGetRG3:aCols, .T. )
	n := 0 // Retorna n = 0 para Gpea400
	RestArea(aArea)

Return( lRet )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ fVldDtRpl³ Autor ³ Equipe RH         	³ Data ³ 18/07/13 |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica intervalo de datas.   			                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ X3_VALID - RG3_DTINI/RG3_DTFIM (quando replica)			  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function fVldDtRpl()
Local aArea		:= GetArea()
Local cReadVar	:= ReadVar()
Local dDtFim	:= Ctod("")
Local dDtIni	:= Ctod("")
Local lRet      := .T.
Local nLinha	:= n
Local nColDtIni := aScan(aHeader ,{|x| Alltrim(upper(x[2]))== "RG3_DTINI"})
Local nColDtFim := aScan(aHeader ,{|x| Alltrim(upper(x[2]))== "RG3_DTFIM"})
Local nX

	dDtIni		:= If( AllTrim(Substr(cReadVar,4))== "RG3_DTINI",&(ReadVar()),If (nColDtIni > 0,aCols[nLinha,nColDtIni],""))
	dDtFim		:= If( AllTrim(Substr(cReadVar,4))== "RG3_DTFIM",&(ReadVar()),If (nColDtFim > 0,aCols[nLinha,nColDtFim],""))

	If !Empty(dDtFim) .And. ( dDtFim < dDtIni )
	   	Help(" ",1,"DATA2INVAL")  // "A Data de Fim nao pode ser menor do que a Data de Inicio."
		lRet := .F.
	EndIf

   	If !Empty(dDtIni) .And. ( dDtIni > RFQ->RFQ_DTFIM )
	   	MsgAlert(OemToansi(STR0063) + DtoC(RFQ->RFQ_DTFIM) ,  OemToAnsi( STR0007 ) )  // "Aviso"###"A data inicial nao pode ultrapassar a data final do periodo selecionado - "
		lRet := .F.
	EndIf

	If !Empty(dDtFim)  .And.  dDtFim > RFQ->RFQ_DTFIM
		MsgAlert(OemToansi(STR0062) + DtoC(RFQ->RFQ_DTFIM) ,  OemToAnsi( STR0007 ) )  // "Aviso"###"A data final nao pode ultrapassar a data final do periodo selecionado - "
		lRet := .F.
	EndIf

	RestArea(aArea)

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GP710RepLOk ³ Autor ³ Equipe RH          ³ Data ³ 10/05/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para Validar a Linha Digitada na Replica de Dados.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPA710Repl - Objeto oGet                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */
Function GP710RepLOk()
Local aArea		:= GetArea()
Local dDtFim	:= Ctod("")
Local dDtIni	:= Ctod("")
Local cReadVar	:= ReadVar()
Local lRet 		:= .T.
Local nColDtIni := aScan(aGdAltRG3 ,{|x| AllTrim(Upper(x))== "RG3_DTINI"})
Local nColDtFim := aScan(aGdAltRG3 ,{|x| AllTrim(Upper(x))== "RG3_DTFIM"})
Local nX

	dDtIni	:= If( AllTrim(Substr(cReadVar,4))== "RG3_DTINI",&(ReadVar()),If (nColDtIni > 0,aCols[n,nColDtIni],""))
	dDtFim	:= If( AllTrim(Substr(cReadVar,4))== "RG3_DTFIM",&(ReadVar()),If (nColDtFim > 0,aCols[n,nColDtFim],""))

	If !Empty(dDtFim) .And. ( dDtFim < dDtIni )
	   	Help(" ",1,"DATA2INVAL")  // "A Data de Fim nao pode ser menor do que a Data de Inicio."
		lRet := .F.
	EndIf

	If !Empty(dDtFim)  .And.  dDtFim > RFQ->RFQ_DTFIM
   		MsgAlert(OemToansi(STR0062) + RFQ->RFQ_DTFIM ,  OemToAnsi( STR0007 ) )  // "Aviso"###"A data final nao pode ultrapassar a data final do periodo selecionado - "
   		lRet := .F.
	EndIf

	RestArea(aArea)

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GP710RepTOk ³ Autor ³ Equipe RH          ³ Data ³ 10/05/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para Validar a Replica de Dados.			          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPA710Repl                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */
Function GP710RepTOk()
Local lRet := .T.
Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GPA710BoxMarc³ Autor ³ Equipe RH         ³ Data ³ 10/05/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para Valicar o Acesso dos Usuarios.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ c_Filial = Filial que esta sendo processada                ³±±
±±³          ³ dData    = Data de Referencia                              ³±±
±±³          ³ c_Semana = Semana de Referencia                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPA710Manu                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */
Static Function GPA710BoxM( oListBox , aListBox , oDlg , cMarckTip )
Local aArea	:= GetArea()

	DEFAULT cMarckTip := ""

	If Empty( cMarckTip )
		aListBox[ oListBox:nAt , 1 ] := !aListBox[ oListBox:nAt , 1 ]
	ElseIf cMarckTip	 == "M"
		aEval( aListBox , { |x,y| aListBox[y,1] := .T. } )
	ElseIf cMarckTip == "D"
		aEval( aListBox , { |x,y| aListBox[y,1] := .F. } )
	ElseIf cMarckTip == "I"
		aEval( aListBox , { |x,y| aListBox[y,1] := !aListBox[y,1] } )
	EndIf

	RestArea(aArea)

Return( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ f710Roteiro  ³ Autor ³ Equipe RH         ³ Data ³ 20/01/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para filtrar roteiros disponiveis pra chave da RFQ. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ X3_WHEN - Campo RG3_ROTEIR                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */
Function f710Roteiro()
Local aArea 	:= GetArea()
Local cTitulo	:= OemToAnsi( STR0064 )// "Roteiros cadastrados para esse periodo:"
Local cChave	:= ""
Local cRot1		:= ""
Local cRot2		:= ""
Local nTam		:= 0
Local nFor		:= 0
Local nElem		:= 0
Local nPos1		:= 0
Local nTamCpo	:= GetSx3Cache("RY_CALCULO","X3_TAMANHO")
Local MvRetor	:= ""
Local MvParDef	:= ""
Local l1Elem	:= .F.
Local bBlocOpc	:= { || }
Local aBloqPon	:= {"1 - " + 'PON'}

Private aRot	:= {}

	MvPar:=&(Alltrim(ReadVar()))
	mvRet:=Alltrim(ReadVar())

	dbSelectArea("RCH")
	dbSetOrder(RetOrdem("RCH", "RCH_FILIAL+RCH_PER+RCH_NUMPAG+RCH_PROCES+DTOS(RCH_DTINI)+DTOS(RCH_DTFIM)+RCH_MODULO"))
	If RCH->(dbSeek(xFilial("RCH")+ cPeriodo + cNroPagto + cProcesso + cDataIni + cDataFim + cModulo))
		CursorWait()
		While !Eof() .And. RCH->RCH_FILIAL == xFilial("RCH") .And. RCH->RCH_PER == cPeriodo .And. RCH->RCH_NUMPAG == cNroPagto ;
					.And. RCH->RCH_PROCES == cProcesso .And. DtoS(RCH->RCH_DTINI) == cDataIni .And. DtoS(RCH->RCH_DTFIM) == cDataFim ;
					.And. RCH->RCH_MODULO == cModulo
				Aadd(aRot, RCH->RCH_ROTEIR + " - " + fDescRot(RCH->RCH_ROTEIR))
				MvParDef += RCH->RCH_ROTEIR
			dbSkip()
		Enddo
		CursorArrow()
	Endif

	bBlocOpc := Iif(IsIncallStack("PONA290"),f_Opcoes(@MvPar,cTitulo,aBloqPon,"PON",,,l1Elem,nTamCpo,999,.T.),;
					     f_Opcoes(@MvPar,cTitulo,aRot,MvParDef,,,l1Elem,nTamCpo,999,.T.) )

	If bBlocOpc  // Chama funcao f_Opcoes
		CursorWait()
		cRoteiros	:= mVPar
		nTam		:= Len( mVpar )
		For nFor := 1 To Len( mVpar ) Step 3
			If ( SubStr( mVpar , nFor , 3 ) # "***" )
				mvRetor += SubStr( mVpar , nFor , 3 )
			EndIf
		Next nFor
		nTam		:= Len( mvRetor )/nTamCpo
		For nFor := 1 To nTam
  		    If (nPos1 > 0, nPos1 += nTamCpo, nPos1+=1)
			cRot1 := SubStr(mvRetor,nPos1,nTamCpo)
			cRot2 += cRot1
			If (nFor >= 1 .And. nFor != nTam,cRot2 += "*", cRot2)
		Next nFor
		&MvRet := AllTrim(cRot2)
		CursorArrow()
	EndIf

RestArea(aArea)

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fDescRot     ³ Autor ³ Equipe RH         ³ Data ³ 20/01/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna descricao do roteiro.							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA710 					                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */
Function fDescRot(cRot)

Local aArea 	:= GetArea()
Local cDesc		:= ""

	dbSelectArea("SRY")
	dbSetOrder(1)
	If SRY->(dbSeek(xFilial("SRY")+ cRot))
		cDesc	:= Alltrim(SRY->RY_DESC)
	EndIf

RestArea(aArea)

Return( cDesc )

/*/{Protheus.doc}GP710FilD()
- Retorna descrição da filiAL/unid/emp.
@Type Function
@author:	Jônatas Alves
@since:		22/05/2017
@version 1.0
@return cFilDesc - Descrição da Filial/Unidade/Empresa de acordo com layout
/*/
Function GP710FilD()

Local cFilDesc	:= ""
Local cFilGet	:= ""
Local cLayout	:= Alltrim(FWSM0Layout()) // "EEUUUFFF    "
Local nI		:= 0
Local nEmp		:= 0
Local nUnit		:= 0
Local nFil		:= 0

	For nI := 1 To Len(cLayout)
		If Substr(cLayout,nI,1) == "E"
			nEmp := nI
		ElseIf Substr(cLayout,nI,1) == "U"
			nUnit := nI
		ElseIf Substr(cLayout,nI,1) == "F"
			nFil := nI
		EndIf
	Next

	If IsMemVar("RG3_FIL")
		cFilGet := GetMemVar("RG3_FIL")

		If Len(cFilGet) # Len(FWCodFil(cFilGet))
			cFilGet := xFilial("RG3",cFilGet)
		EndIf

		If Len(Alltrim(cFilGet)) > nUnit
			cFilDesc := FWFILIALNAME(NIL,GetMemVar("RG3_FIL"))
		ElseIf Len(Alltrim(cFilGet)) > nEmp
			cFilDesc := FWUNITNAME(NIL,GetMemVar("RG3_FIL"))
		Else
			cFilDesc := FWCOMPANYNAME(NIL,GetMemVar("RG3_FIL"))
		EndIf
	EndIf
Return(cFilDesc)
