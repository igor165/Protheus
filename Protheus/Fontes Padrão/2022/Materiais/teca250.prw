#INCLUDE "TECA250.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FOLDER.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"
#INCLUDE "TBICONN.CH"
#Include "FWMVCDEF.CH"

#DEFINE MAXGETDAD 999

Static cStatContr := ''
Static lTMSItCt   := Iif(FindFunction("TmsUniNeg"),TmsUniNeg(),.F.)
Static lTabDDP    := AliasIndic("DDP")
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TECA250  ³ Autor ³ Alex Egydio           ³ Data ³06.03.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Contrato de Prestacao de Servicos                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TECA250()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Field Service                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Cleber M.  ³04/10/07³133328³Criacao do P.E. AT250ROT para permitir a  ³±±
±±³            ³        ³      ³inclusao de itens no aRotina.             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/


Function TECA250( cRotina, xAutoCab, xAutoItTEC, xAutoItWMS, xAutoItTMS, nOpcAuto )

Local cAt250Brw		:= ""		// Filtro fornecido pelo ponto de entrada
Local bFiltraBrw	:= {||}		// Bloco de código para execução do filtro
Local aIndexAAM		:= {}		// Indice do AB1
Local cFiltraAAM	:= ""		// Filtro utilizado no bloco de código executado para ativar o filtro
Local lAuto250	    := ( ValType( xAutoCab ) == "A" ) 
Local aAutoMVC   

Private aRotina     := MenuDef()	//Array com as rotinas do programa 
Private cCadastro	:= STR0001		//"Contrato de Prestacao de Servicos"

Private aAutoCab	:= {}			// Cabeçalho da rotina automático
Private aAutoItTEC	:= {}			// Itens da rotina automática TEC
Private aAutoItWMS	:= {}			// Itens da rotina automática WMS
Private aAutoItTMS	:= {}			// Itens da rotina automática TMS

Default cRotina	 	:= ""
Default xAutoCab	:= {}
Default xAutoItTEC	:= {}
Default xAutoItWMS	:= {}
Default xAutoItTMS	:= {}
Default nOpcAuto	:= 3

If !lAuto250
	oBrowse:= FWMBrowse():New()
	oBrowse:SetAlias("AAM")
	oBrowse:SetDescription(STR0001)

	//--Filtra o mBrowse
	If (ExistBlock("AT250Brw"))
		cAt250Brw := ExecBlock("AT250BRW",.F.,.F.)
		If ( ValType(cAt250Brw) == "C" ) .And. !Empty(cAt250Brw)
			cFiltraAAM := cAt250Brw
		EndIf
		bFiltraBrw := {|| FilBrowse("AAM",@aIndexAAM,@cFiltraAAM) }
		Eval(bFiltraBrw)
	EndIf

	oBrowse:SetCacheView(.F.) //-- Desabilita Cache da View, pois gera colunas dinamicamente
	oBrowse:Activate()
Else
	aAutoMVC   := {}
	aAutoCab   := AjustaCab(xAutoCab)
	
	aAdd(aAutoMVC,{ "MdFieldCAAM", aAutoCab })
	
	aAutoItTEC := xAutoItTEC
	If !Empty(aAutoItTEC)
		aAdd(aAutoMVC,{ "MdGridIAAN", aAutoItTEC })
	EndIf
	
	aAutoItWMS := xAutoItWMS
	If !Empty(aAutoItWMS)
		aAdd(aAutoMVC,{ "MdGridIAAO", aAutoItWMS })
	EndIf

	aAutoItTMS := xAutoItTMS
	If !Empty(aAutoItTMS)
		aAdd(aAutoMVC,{ "MdGridIDUX", aAutoItTMS })
	EndIf

	FwMvcRotAuto( ModelDef(), "AAM", nOpcAuto, aAutoMVC )  //Chamada da rotina automatica através do MVC
EndIf	

//--Devolve os indices padroes do SIGA

RetIndex("AAM")
Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³MenuDef   ³ Autor ³ Conrado Q. Gomes      ³ Data ³ 08.12.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Definição do aRotina (Menu funcional)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MenuDef()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TECA250                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
Local aRotina := {}		// Definicoes das rotinas do programa
Local aRotAdic:= {}		// Itens a serem adicionados no aRotina via P.E.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa               ³
//³ ----------- Elementos contidos por dimensao ------------              ³
//³ 1. Nome a aparecer no cabecalho                                       ³
//³ 2. Nome da Rotina associada                                           ³
//³ 3. Usado pela rotina                                                  ³
//³ 4. Tipo de Transa‡„o a ser efetuada                                   ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados                      ³
//³    2 - Simplesmente Mostra os Campos                                  ³
//³    3 - Inclui registros no Bancos de Dados                            ³
//³    4 - Altera o registro corrente                                     ³
//³    5 - Remove o registro corrente do Banco de Dados                   ³
//³    6 - Alteracao sem inclusao de registro                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tirar algumas opcoes do aRotina para o Modulo de Transporte (TMS)     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nModulo <> 43
	aRotina	:= {{ STR0002	,"AxPesqui"    			,0	,1	,0	,.F.	}	,;	//"Pesquisar"
					{ STR0003	,"VIEWDEF.TECA250"	,0	,2	,0	,.T.	}	,;	//"Visualizar"
					{ STR0004	,"VIEWDEF.TECA250"	,0	,3	,0	,.T.	}	,;	//"Incluir"
					{ STR0005	,"VIEWDEF.TECA250"	,0	,4	,0	,.T.	}	,;	//"Alterar"
					{ STR0006	,"VIEWDEF.TECA250"	,0	,5	,0	,.T.	}	,;	//"Excluir"
					{ STR0007	,"At250ProcR"	    ,0	,6	,0	,.T.	}	,;	//"Reajuste"
					{ STR0073	,"At250Copy"	    ,0	,9	,0	,.T.	}  ,; //"Copiar"
					{ STR0008	,"At250GPVen"		,0	,7	,0	,.T.	}	,;	//"Gera P.V"
					{ STR0051	,"At250Reset"		,0	,7	,0	,.T.	}	,; //"Restaura datas"
					{ STR0009	,"MsDocument"		,0	,4	,0	,.T.	}}    //"Conhecimento"
Else
	aRotina	:= {{ STR0002	,"AxPesqui"    			,0	,1	,0	,.F.	}	,;	//"Pesquisar"
					{ STR0003	,"VIEWDEF.TECA250"	,0	,2	,0	,.T.	}	,;	//"Visualizar"
					{ STR0004	,"VIEWDEF.TECA250"	,0	,3	,0	,.T.	}	,;	//"Incluir"
					{ STR0005	,"VIEWDEF.TECA250"	,0	,4	,0	,.T.	}	,;	//"Alterar"
					{ STR0006	,"VIEWDEF.TECA250"	,0	,5	,0	,.T.	}	,;	//"Excluir"
					{ STR0009	,"MsDocument"		,0	,4	,0	,.T.	}	,; //"Conhecimento"
					{ STR0073	,"At250Copy"	    ,0	,9	,0	,.T.	}}     //"Copiar"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona rotinas de usuario ao aRotina               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "AT250ROT" )
	aRotAdic := ExecBlock( "AT250ROT", .F., .F. )
	If ValType( aRotAdic ) == "A"
		AEval( aRotAdic, { |x| AAdd( aRotina, x ) } )
	EndIf
EndIf
Return(aRotina)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³At250Manut³ Autor ³ Alex Egydio           ³ Data ³06.03.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Manutencao do Contrato de Prestacao de Servico             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ At250Manut(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Henry F     ³09/11/05³88616 ³Ajute do controle do inicializador padrao ³±±
±±³            ³        ³      ³alterando a variavel inclui               ³±±
±±³Conrado Q.  ³08/01/07³115744³Retirado chamada ao ajuste do dicionário. ³±±
±±³Conrado Q.  ³08/01/07³115744³Adaptada para utilização do Walk-Thru.    ³±±
±±³Cleber M.   ³03/04/07³122772³Troca do nome do bitmap (Protheus 10).    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function At250Manut( cAlias, nReg, nOpc )

If nOpc == 2
	FWExecView('','TECA250', MODEL_OPERATION_VIEW, , /*{ || .T. }*/, , ,/*aButtons*/ )
ElseIf nOpc == 3
	FWExecView('','TECA250', MODEL_OPERATION_INSERT, , /*{ || .T. }*/, , ,/*aButtons*/ )
ElseIf nOpc == 4
	FWExecView('','TECA250', MODEL_OPERATION_UPDATE, , /*{ || .T. }*/, , ,/*aButtons*/ )
ElseIf nOpc == 5
	FWExecView('','TECA250', MODEL_OPERATION_DELETE, , /*{ || .T. }*/, , ,/*aButtons*/ )
EndIf
Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ At250Header ³ Autor ³ Alex Egydio        ³ Data ³06.03.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta aHeader                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A250Header(ExpC1,ExpC2)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do Arquivo                                   ³±±
±±³          ³ ExpC2 = String com campos que aparecerao no aHeader        ³±±
±±³          ³ ExpN1 = Opcao Selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista    ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cleber M.   ³06/06/06³98346 ³-Alterado X3_TITULO pela funcao X3Titulo, ³±±
±±³            ³        ³      ³para retornar tambem em outros idiomas.   ³±±
±±³Conrado Q.  ³08/01/07³115744³Adaptada para utilização do Walk-Thru.    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function At250Header(cAlias,cCampo,nOpcx)
Local aHTmp     := {} //Array aHeader de retorno da funcao
Local lRet      := .T.
Local lPEAltVld := .T.
Local aPECpos   := {}
Local nC		:= 0
Local aCpos		:= {}
Local cTitulo := "X3_TITULO"

lAltVldSX3:= IIf(Type('lAltVldSX3') == 'U', .F., lAltVldSX3)

If cAlias == 'DUX' .AND. nOpcx == 4 .AND. IntTMS()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se existir CTRC utilizando o Contrato, nao permite alterar as linhas ja'   ³
	//³existentes da Getdados. Permite apenas, a inclusao de novas linhas.        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lRet:= AT250Doc()
	If !lRet
		lAltVldSX3 := .T.
	EndIf
EndIf

//-- Ponto de entrada para indicar campos de usuario/cliente para permitir alteracao se contrato possue CTRC.
If ExistBlock( "AT250CPO" )
	aPECpos := ExecBlock( "AT250CPO", .F., .F. )
	If ValType( aPECpos ) <> "A"
		aPECpos := {}
	EndIf
EndIf

aCpos := FWSX3Util():GetAllFields(cAlias , .T.) //Retorna os campos virtuais

For nC := 1 to Len(aCpos)
	If X3Uso(GetSx3Cache(aCpos[nC],"X3_USADO" )) .AND. cNivel >= GetSx3Cache(aCpos[nC],"X3_NIVEL" )
		lPEAltVld := aScan(aPECpos,{|x|x == TRIM(aCpos[nC])}) == 0
		Aadd(aHTmp,{ AllTrim(TecTituDes( aCpos[nC], .T. ) ),;
						aCpos[nC],;
						GetSx3Cache(aCpos[nC],"X3_PICTURE"),;
						GetSx3Cache(aCpos[nC],"X3_TAMANHO"),;
						GetSx3Cache(aCpos[nC],"X3_DECIMAL"),;
						AllTrim(GetSx3Cache(aCpos[nC],"X3_VALID"))+IIf(lAltVldSX3 .And. lPEAltVld, IIf(!Empty(GetSx3Cache(aCpos[nC],"X3_VALID")),'.AND.','')+'AT250Vld()', '') ,;
						GetSx3Cache(aCpos[nC],"X3_USADO"),;
						GetSx3Cache(aCpos[nC],"X3_TIPO"),;
						GetSx3Cache(aCpos[nC],"X3_ARQUIVO"),;
						GetSx3Cache(aCpos[nC],"X3_CONTEXT") } )
	EndIf
Next nC

// Inclui coluna de registro atraves de funcao generica
ADHeadRec(cAlias, aHTmp)

Return( aHTmp )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ At250ColsInc³ Autor ³ Ricardo Gonçalves  ³ Data ³11.04.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta aCols do contrato WMS com dados pre formatados       ³±±
±±³          ³ pesquisados em outros arquivos                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ At250ColsInc()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Conrado Q.  ³08/01/07³115744³Adaptada para utilização do Walk-Thru.    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/

Function At250ColsInc()
Local aAreaAnt	:= GetArea()
Local aCTmp		:= {}
Local nCntFor	:= 0
Local nItem		:= 0
Local nSeek		:= 0
Local cTlbPrec	:= ''
Local cCondPag	:= ''
Local c1Seek	:= ''
Local c2Seek	:= ''
Local c3Seek	:= ''
Local c4Seek	:= ''
Local lRet		:= .T.

//-- Clientes x Produtos
DbSelectArea( 'SA7' )
DbSetOrder( 1 )
If	lRet .AND. DbSeek( c1Seek := xFilial('SA7') + M->AAM_CODCLI )

	If nModulo <> 43
		While SA7->(!Eof() .AND. SA7->A7_FILIAL + SA7->A7_CLIENTE == c1Seek )
	
			//-- Verifica o nivel do filtro do contrato
			If M->AAM_ABRANG == '1' .AND. !Empty( M->AAM_LOJA ) .AND. M->AAM_LOJA <> SA7->A7_LOJA
				DbSelectArea('SA7')
				DbSkip()
				Loop
			EndIf
	
			//-- Clientes
			If SA1->( DbSeek( if( !Empty( M->AAM_LOJA ), xFilial('SA1') + M->AAM_CODCLI + M->AAM_LOJA,;
				   														xFilial('SA1') + M->AAM_CODCLI )))
				cTlbPrec:= SA1->A1_TABELA
				cCondPag:= SA1->A1_COND
			EndIf

			//-- Varrendo o arquivo de Produto x Servicos
			DbSelectArea( 'DCG' )
			DbSetOrder(1)
			If	DbSeek( c2Seek := xFilial('DCG') + SA7->A7_PRODUTO )
	
				While DCG->(!Eof() .AND. DCG->DCG_FILIAL + DCG->DCG_CODPRO == c2Seek )
	
					//-- Varrendo o arquivo Servico x Tarefa
					DbSelectArea('DC5')
					DbSetOrder(1)
					If DbSeek( c3Seek := xFilial('DC5') + DCG->DCG_SERVIC )
	
						While DC5->(!Eof() .AND. DC5->DC5_FILIAL + DC5->DC5_SERVIC == c3Seek )
	
							//-- Varrendo o arquivo Tarefa x Atividade
							nSeek:= 0
							DbSelectArea( 'DC6')
							DbSetOrder(1)
							If	DbSeek( c4Seek := xFilial('DC6') + DC5->DC5_TAREFA )
	
								While DC6->(!Eof() .AND. DC6->DC6_FILIAL + DC6->DC6_TAREFA == c4Seek )
									//-- Verifica se o registro ja foi incluso no Grid
									If (oModel:GetModel("MdGridIAAO"):GetLine() == 1 .And. Empty(oModel:GetValue("MdGridIAAO","AAO_CODPRO")) ) ;
									   .Or. (!oModel:GetModel("MdGridIAAO"):SeekLine({{"AAO_CODPRO",DCG->DCG_CODPRO},;
																				{"AAO_SERVIC",DCG->DCG_SERVIC},;
																				{"AAO_TAREFA",DC5->DC5_TAREFA},;
																				{"AAO_ATIVID",DC6->DC6_ATIVID}   }) ;
									         .And. oModel:GetModel("MdGridIAAO"):AddLine() > 0 ) 
										 
										oModel:LoadValue("MdGridIAAO","AAO_ITEM"  ,StrZero( oModel:GetModel("MdGridIAAO"):GetLine(), TamSX3('AAO_ITEM')[1] ) )
										oModel:LoadValue("MdGridIAAO","AAO_CODPRO",DCG->DCG_CODPRO )
										oModel:LoadValue("MdGridIAAO","AAO_DESPRO",Posicione( 'SB1', 1, xFilial('SB1') + DCG->DCG_CODPRO, 'B1_DESC' ) )
										oModel:LoadValue("MdGridIAAO","AAO_CONPAG",cCondPag)
										oModel:LoadValue("MdGridIAAO","AAO_SERVIC",DCG->DCG_SERVIC)
										oModel:LoadValue("MdGridIAAO","AAO_DESSER",Tabela( 'L4', DCG->DCG_SERVIC ))
										oModel:LoadValue("MdGridIAAO","AAO_TAREFA",DC5->DC5_TAREFA)
										oModel:LoadValue("MdGridIAAO","AAO_DESTAR",Tabela( 'L2', DC5->DC5_TAREFA ))
										oModel:LoadValue("MdGridIAAO","AAO_ATIVID",DC6->DC6_ATIVID)
										oModel:LoadValue("MdGridIAAO","AAO_DESATI",Tabela( 'L3', DC6->DC6_ATIVID ))
										oModel:LoadValue("MdGridIAAO","AAO_TPSERV",DC5->DC5_TIPO)
	
									EndIf
	
									DbSelectArea( 'DC6' )
									DbSkip()
								EndDo
							EndIf
							//-- Fim do DC6
	
							DbSelectArea( 'DC5' )
							DbSkip()
						EndDo
					EndIf
					//-- Fim do DC5
	
					DbSelectArea( 'DCG' )
					DbSkip()
				EndDo
			EndIf
			//-- Fim do DCG
	
			DbSelectArea( 'SA7' )
			DbSkip()
		EndDo
	EndIf
EndIf
//-- Fim do SA7

RestArea(aAreaAnt)
Return ( .T. )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³At250SkCli³ Autor ³ Alex Egydio           ³ Data ³06.03.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Busca Nome do cliente - Chamado pelo SX3                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void At250SkCli()                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TECA250                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function At250SkCli()
Local lRet    := .T.
Local cCampo  := ReadVar()
Local oModel  := Nil
Local uAuxCpo	:= Nil
Local nOpc		:= 0

Do Case
Case ( cCampo == "M->AAM_LOJA" )
	DbSelectArea("SA1")
	DbSetOrder(1)
	If DbSeek(xFilial("SA1")+M->AAM_CODCLI+&(ReadVar()))
		lRet := RegistroOk("SA1")
		M->AAM_NOMCLI := SA1->A1_NOME

		//--Tratamento: Modulo TMS
		//--Nao permite o cadastro de contratos para clientes
		//--que nao possuam em seu cadastro o codigo da regiao
		//--informado:
		If IntTMS() .And. nModulo == 43
			If Empty( SA1->A1_CDRDES )
				Help( "", 1, "CDRDES",, AllTrim(RetTitle('A1_COD')) + ': ' + SA1->(A1_COD + '/' + A1_LOJA), 4, 1 ) //--"Informe um código de região válida para este cliente."
				lRet := .F.
			EndIf
		EndIf
	Else
		HELP(" ", 1,"REGNOIS")
		lRet := .F.
	EndIf
Case cCampo == "M->AAM_CODCLI"
	DbSelectArea("SA1")
	DbSetOrder(1)
	If ( xFilial("SA1")+&(ReadVar())<>SA1->A1_FILIAL+SA1->A1_COD )
		DbSeek(xFilial("SA1")+&(ReadVar()))
		lRet := RegistroOk("SA1")
	EndIf
	If lRet
		If ( xFilial("SA1")+&(ReadVar())==SA1->A1_FILIAL+SA1->A1_COD )
			lRet := RegistroOk("SA1")
			M->AAM_NOMCLI := SA1->A1_NOME
			//--Tratamento: Modulo TMS
			//--Nao permite o cadastro de contratos para clientes
			//--que nao possuam em seu cadastro o codigo da regiao
			//--informado:
			If IntTMS() .And. nModulo == 43
				If Empty( SA1->A1_CDRDES )
					Help( "", 1, "CDRDES",, AllTrim(RetTitle('A1_COD')) + ': ' + SA1->(A1_COD + '/' + A1_LOJA), 4, 1 ) //--"Informe um código de região válida para este cliente."
					lRet := .F.
				EndIf
			EndIf
		Else
			HELP(" ", 1,"REGNOIS")
			lRet := .F.
		EndIf
	EndIf
	If lRet .And. IntTms() .And. nModulo == 43 .And. lTabDDP .And. IsInCallStack("At250Copy")
		//Ajuste para forçar a validação quando houver % FIXO de rateio, somente quando for para o caso de cópia do contrato
		//obtem modelo atual
		oModel:=FWModelActive()
		nOpc := oModel:GetOperation()
		//salva o conteudo atual
		uAuxCpo := oModel:GetModel( "MdGridIDDP" ):GetValue("DDP_PERRAT")
		// Limpa o campo
		oModel:GetModel( "MdGridIDDP" ):SetValue("DDP_PERRAT", 0)
		//Volta o conteudo
		oModel:GetModel( "MdGridIDDP" ):SetValue("DDP_PERRAT", uAuxCpo)
	EndIf
EndCase
Return(lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³At250ValAb³ Autor ³ Sergio Silveira       ³ Data ³27/04/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao da digitacao da abrangencia                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpL1 := At250ValAb() - chamado pelo SX3                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpL1 -> Validacao                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TECA250                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function At250ValAb() 
Local cConteudo := &( ReadVar() )
Local lRet      := .T.
Local cContrat  := ''

If Altera
	If IntTMS() .And. nModulo == 43
		If AT250Vig(@cContrat)
			Help("", 1, "AT250VIG", ,STR0091 +" : "+ cContrat ,3,0)
			lRet := .F.							
		EndIf			
	Else
		If cConteudo == "1"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Nao permite alterar para Cliente/Loja se estava em Cliente   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If AAM->AAM_ABRANG == "2"
				Help( " ", 1, "AT200ABRAN" ) // Nao e possivel alterar a abrangencia de cliente para cliente / loja  
				lRet := .F.
			EndIf
		EndIf
	EndIf	
EndIf
Return( lRet )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ At250ProcR³ Autor ³ Alex Egydio          ³ Data ³21.03.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inicia o Processo de Reajuste do Contrato                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function At250ProcR(cAlias,nReg,nOpc, lAutomato)
Local aArea		:= GetArea()
Local aSay		:= {}
Local aButtons	:= {}
Local nOpcA		:= 0

Default lAutomato := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                                  ³
//³-----------------------------------------------------------------------³
//³ mv_par01	// Contrato      De  ?                            F3   AAM ³
//³ mv_par02	//               Ate ?                            F3   AAM ³
//³ mv_par03	// Cliente       De  ?                            F3   CLI ³
//³ mv_par04	//               Ate ?                            F3   CLI ³
//³ mv_par05	// Classificacao De  ?                            F3   A1  ³
//³ mv_par06	//               Ate ?                            F3   A1  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte("ATA250",.F.)

Aadd(aSay,STR0017) //"Esta rotina realiza o rejuste de valores dos contratos de "
Aadd(aSay,STR0018) //"manutencao, conforme os parametros solicitados."

AADD(aButtons, { 5,.T.,{|| Pergunte("ATA250",.T.)	}})
AADD(aButtons, { 1,.T.,{|o| nOpcA:= 1,o:oWnd:End()	}})
AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }})

If !lAutomato
	FormBatch( STR0019, aSay, aButtons,,200,405 ) //"Reajuste do Contrato"
	If ( nOpcA == 1 )
		Processa({|lEnd| At250SelCtr(@lEnd, lAutomato)},,,.T. )
	EndIf
Else
	At250SelCtr(.f., lAutomato)
EndIf
RestArea(aArea)
Return NIL
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³At250SelCtr³ Autor ³ Alex Egydio          ³ Data ³21.03.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Seleciona contratos conforme parametrizacao do usuario     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function At250SelCtr(lEnd, lAutomato)
Local aArea		:= GetArea()
Local cQuery
Default lAutomato := .F.


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a Query                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cAliasQry := CriaTrab( , .F. )

cQuery := " SELECT AAM_FILIAL, AAM_CONTRT, AAM_CODCLI, AAM_CLASSI"
cQuery += " FROM"
cQuery += " "+RetSqlName('AAM')+" AAM"
cQuery += " WHERE"
cQuery += " D_E_L_E_T_<>'*'"
cQuery += " AND AAM_FILIAL = '"+xFilial('AAM')+"'"
cQuery += " AND AAM_CONTRT BETWEEN '"+mv_par01+"' AND '"+mv_par02+"'"
cQuery += " AND AAM_CODCLI BETWEEN '"+mv_par03+"' AND '"+mv_par05+"'"
cQuery += " AND AAM_LOJA   BETWEEN '"+mv_par04+"' AND '"+mv_par06+"'"
cQuery += " AND AAM_CLASSI BETWEEN '"+mv_par07+"' AND '"+mv_par08+"'"
cQuery += " AND AAM_INIVIG>='"+DToS( mv_par12 )+"'"
cQuery += " AND AAM_FIMVIG<='"+DToS( mv_par13 )+"'"
cQuery += " ORDER BY "+SqlOrder(AAM->(IndexKey()))
cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
DbSelectArea(cAliasQry)

cAlias := Alias()
If !lAutomato
	ProcRegua(RecCount())
EndIf
DbGoTop()
While !Eof()
	If lEnd
		Exit
	EndIf
	If !lAutomato
		IncProc()
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Aplica o reajuste                                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Begin Transaction
			At250Reaju((cAliasQry)->AAM_CONTRT,mv_par11)
	End Transaction

	DbSelectArea(cAlias)
	DbSkip()
EndDo         

If	Select(cAliasQry) > 0
	DbSelectArea(cAliasQry)
	DbCloseArea()
EndIf
RetIndex("AAM")

RestArea(aArea)
Return NIL
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³At250Reaju³ Autor ³ Alex Egydio           ³ Data ³21.03.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Rotina de reajuste de contratos.                            ³±±
±±³          ³Esta rotina reajusta o valor do contrato e atualiza o perio-³±±
±±³          ³do de validade e cobranca para o periodo posterior ao cadas-³±±
±±³          ³trado no contrato de Manutencao. Ex. Se o periodo de valida ³±±
±±³          ³de for: 01/01/99 a 31/12/99 o novo periodo sera: 01/01/2000 ³±±
±±³          ³a 31/12/2000.                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ At250Reaju(ExpC1,ExpC2,ExpC3,ExpN1)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Numero do Contrato                                 ³±±
±±³          ³ ExpC2 = Codigo do Cliente                                  ³±±
±±³          ³ ExpC3 = Loja do Cliente                                    ³±±
±±³          ³ ExpN1 = Fator de Reajuste                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³ O contrato deve estar posicionado.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Henry Fila  ³11/08/06³85113 ³Implementacao do ponto de entrada AT250REJ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function At250Reaju(cContr,nFator)
Local aArea		:= GetArea()			//Armazena o ambiente atual
Local aAreaAAM	:= AAM->(GetArea())	//Armazena o ambiente da tabela AAM
Local aAreaAAN	:= AAN->(GetArea())	//Armazena o ambiente da tabela AAN
Local aAreaAAO	:= AAO->(GetArea())	//Armazena o ambiente da tabela AA0
Local nValor	:= 0					//Variavel acumuladora de valor
Local nDias		:= 0					//Variavel acumuladora de dias
Local cSeek		:= ''					//Variavel para busca da tabela AAN
Local lAt250Rej := ExistBlock("AT250REJ")

If	cContr == NIL .OR. Empty(cContr) .OR. ValType(cContr)<>"C"
	Return NIL
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Itens do Contrato de Prestacao de Servicos Parceria                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSeek := xFilial("AAN") + cContr

AAN->(DbSetOrder(1))
AAN->(DbSeek( cSeek ))
While AAN->(!Eof() .AND. AAN_FILIAL + AAN_CONTRT == cSeek )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Filtra por produto / reajuste                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If AAN->AAN_CODPRO >= MV_PAR09 .AND. AAN->AAN_CODPRO <= MV_PAR10 .AND. ;
				( ( AAN->AAN_ULTREA >= MV_PAR14 .AND. AAN->AAN_ULTREA <= MV_PAR15 ) .OR. Empty( AAN->AAN_ULTREA ) ) 


		RecLock("AAN",.F.)
		AAN->AAN_VLRUNI *= nFator
		AAN->AAN_VALOR := AAN->AAN_VLRUNI * AAN->AAN_QUANT

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Reajuste do periodo de cobranca                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nDias := AAN->AAN_FIMCOB-AAN->AAN_INICOB
		AAN->AAN_INICOB := AAN->AAN_FIMCOB + 1
		AAN->AAN_FIMCOB += nDias + 1

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava a data do ultimo reajuste                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AAN->AAN_ULTREA := dDataBase

		MsUnLock()
		nValor += AAN->AAN_VALOR

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de entrada após a gravacao do AAN³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lAt250Rej
			ExecBlock("AT250REJ",.F.,.F.)
		Endif

	EndIf

	AAN->(DbSkip())
EndDo
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Itens do Contrato de Prestacao de Servicos WMS                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSeek := xFilial('AAO') + cContr

AAO->(DbSetOrder(1))
AAO->(DbSeek( cSeek ))
While AAO->(!Eof() .AND. AAO_FILIAL + AAO_CONTRT == cSeek )

	If AAO->AAO_CODPRO >= MV_PAR09 .AND. AAO->AAO_CODPRO <= MV_PAR10


		RecLock("AAO",.F.)
		AAO->AAO_VALOR *= nFator
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Reajuste do periodo de cobranca                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nDias := AAO->AAO_FIMCOB-AAO->AAO_INICOB
		AAO->AAO_INICOB := AAO->AAO_FIMCOB + 1
		AAO->AAO_FIMCOB += nDias + 1
		MsUnLock()
		nValor += AAO->AAO_VALOR

	EndIf
	AAO->(DbSkip())
EndDo
RestArea(aAreaAAM)
RestArea(aAreaAAN)
RestArea(aAreaAAO)
RestArea(aArea)
Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ At250Total³ Autor ³ Alex Egydio          ³ Data ³21.03.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Totaliza valores  - Chamado SX3                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function At250Total()
Local cCampo:= AllTrim(ReadVar())

If !IsBlind()
	If cCampo == "M->AAN_QUANT" 
		FwFldPut( "AAN_VALOR", ( M->AAN_QUANT * FwFldGet("AAN_VLRUNI") ) )
	ElseIf cCampo == "M->AAN_VLRUNI"
		FwFldPut( "AAN_VALOR", ( M->AAN_VLRUNI * FwFldGet("AAN_QUANT") ) )
	EndIf
Else
	If cCampo == "M->AAN_QUANT" .AND. ValType(M->AAN_VLRUNI) = "N" .AND. ValType(M->AAN_VALOR) = "N"
		M->AAN_VALOR :=  M->AAN_QUANT * M->AAN_VLRUNI
	ElseIf cCampo == "M->AAN_VLRUNI" .AND. ValType(M->AAN_QUANT) = "N" .AND. ValType(M->AAN_VALOR) = "N"
		M->AAN_VALOR :=  M->AAN_QUANT * M->AAN_VLRUNI
	EndIf

EndIf

Return( .T. )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ At250GPVen³ Autor ³ Alex Egydio          ³ Data ³21.03.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Dispara o Processo de Geracao de Pedidos de Venda, baseado ³±±
±±³          ³ nos Contratos.   (Manual)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function At250GPVen(cAlias,nReg,nOpc, lAutomato)

Local aSay     := {}
Local aButtons := {}

Local nOpca    := 0 
Default lAutomato := .F.

Aadd(aSay, STR0048)  //"Esta rotina dispara o processamento dos contratos"
Aadd(aSay, STR0049)  //"de servico para a geracao de pedidos de venda."

AADD(aButtons, { 1,.T.,{|o| nOpcA:= 1,o:oWnd:End()	}})
AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }})

If !lAutomato
	FormBatch( STR0050, aSay, aButtons,,200,405 ) //"Processamento dos pedidos de venda"
EndIf

If !lAutomato
	If ( nOpcA == 1 )
	
			Processa({|lEnd| At250GeraPv(@lEnd, SuperGetMV("MV_ULCTSER") ) },STR0021,,.T. ) //"Gerando P.Vendas por Contrato"		
			DbSelectArea("SX6")
			PutMV( "MV_ULCTSER", dDataBase )
	
	EndIf
Else
    At250GeraPv(.F., SuperGetMV("MV_ULCTSER"),lAutomato )
EndIf

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ At250Auto ³ Autor ³ Alex Egydio          ³ Data ³21.03.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Dispara o Processo de Geracao de Pedidos de Venda, baseado ³±±
±±³          ³ nos Contratos.   (Automatico)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ At250Auto( [ ExpC1 ] ) - Disparado do campo X2_ROTINA      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Codigo do usuario que ira disparar o processo      ³±±
±±³          ³ ( opcional )                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

Function At250Auto( cCodUser )

Local aArea	:= GetArea()
Local dUlCtSer 

cCodUser := If( ValType( cCodUser ) == "C", cCodUser, "" )

If SuperGetMv("MV_CONTRSR") .AND. If( Empty( cCodUser ), .T., ( cCodUser == RetCodUsr() ) )
	If ( dDataBase > ( dUlCtSer := SuperGetMV("MV_ULCTSER") ) )
			Processa({|lEnd| At250GeraPv(@lEnd, dUlCtSer ) },STR0021,,.T. ) //"Gerando P.Vendas por Contrato"
			DbSelectArea("SX6")
			PutMV( "MV_ULCTSER", dDataBase )
	EndIf
EndIf

RestArea(aArea)
Return NIL
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³At250GeraPV³ Autor ³ Alex Egydio          ³ Data ³21.03.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Processamento dos contratos - Chamado TecxFun              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ At250GeraPV(ExpL1,ExpD1)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 = .F. = Cancelar o processamento                     ³±±
±±³          ³ ExpD1 = Data do Ultimo Processamento                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Andrea F.   ³26/04/05³79097 ³Forcar a liberacao do numero reservado    ³±±
±±³            ³        ³      ³na funcao FreeUsedCode() com parametro .T.³±±
±±³Cleber M.   ³14/06/06³101529³Tratamento para proteger o fonte de erro  ³±±
±±³            ³        ³      ³de "array out of bounds" no aCondPag.     ³±±
±±³Cleber M.   ³01/11/06³102074³Incluido o param. MV_ULCTDIA para permitir³±±
±±³            ³        ³      ³a geracao do PV no ultimo dia do mes, no  ³±±
±±³            ³        ³      ³caso dos meses que nao terminam em 30 ou  ³±±
±±³            ³        ³      ³31 dias (ex.: Fevereiro).		          ³±±
±±³Conrado Q.  ³08/01/07³115744³Adaptada para utilização do Walk-Thru.    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function At250GeraPV(lEnd, dUlCtSer, lAutomato)

Local aCondPag		:= {}
Local aDadosIt      := {}
Local aRecs         := {}
Local aDataOri      := {}
Local aContPed      := {}
Local aDadosCFO     := {}
Local aRetPE		:= {}

Local cCfo          := ""
Local cEstado       := SuperGetMV( "MV_ESTADO" )
Local cItem         := "00"
Local cSeekAAN      := ""
Local cSeekAAO      := ""

Local dProcesso	 	:= Iif( ValType( dUlCtSer ) == "D", dUlCtSer, dDataBase )
Local dUltRea       := CToD( "" )
Local dDataAAN      := CToD( "" )
Local dDataAAO      := CToD( "" )

Local lAT250FIL     := ExistBlock("AT250FIL")
Local lFiltro       := .T.

Local lAt250Ped     := ExistBlock( "AT250PED" )
Local lATA250PV     := ExistBlock( "ATA250PV" )
Local lATA250CD     := ExistBlock( "ATA250CD" )
Local lAt250Mov		:= ExistBlock( "AT250MOV" )
Local lGeraPV       := .T.
Local lUltimoDia	:= SuperGetMV( "MV_ULCTDIA",.F.,.F.)	//Indica se deve gerar PV no ultimo dia do mes
Local nCampos	  	:= 0
Local nCntFor       := 0
Local nValor        := 0
Local nLoop         := 0
Local nQtdMeses     := 0
Local nQtMesUltRea  := 0
Local nDiaUltRea    := 0
Local nValorReaj    := 0
Local nScanAAN      := 0
Local nScanAAO      := 0
Local nPosPrcVen    := 0
Local nPosQtdVen    := 0
Local nStackSX8     := GetSX8Len()
Local cEventID      := ""                              // Id do Evento a ser disparado pelo Event Viewer
Local cMensagem     := ""                              // Mensagem que sera enviada por e-mail ou RSS pelo Event Viewer
Local aSocios 		:= {} 							   // Array para armazenar os socios do grupo societario
Local nX 			:= 0                               // Incremento utilizado no laco for
Local lRateio 		:= .F.                             // Define se o Pedido de Venda será rateado
Local nQtd 			:= 0                               // Quantidade do Item
Local lCarga		:= .F.                             // Controla a carga do rateio
Local aQtdxAAN		:= {}                              // Array que contem a quantidade rateada para cada item da tabela AAN
Local aQtdxAAO		:= {}                              // Array que contem a quantidade rateada para cada item da tabela AAO
Local cMV_APDLFO	:= SuperGetMV('MV_APDLFOP', .F.)

Private bCampo	  	:= {|x| FieldName(x) }
Private aCols	   	:= {}
Private aHeader     := {}
Private aDistrInd   := {}

Default lAutomato := .F.

If !lAutomato
	ProcRegua(dDataBase-dProcesso)
EndIf

aHeader := At250Header("SC6","")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Percorre todos os dias desde o ultimo processamento ate hoje            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While dProcesso <= dDataBase
	If lEnd
		Exit
	EndIf

	DbSelectArea("AAM")
	DbSetOrder(1)

	DbSeek(xFilial("AAM"))

	While AAM->(!Eof() .AND. AAM_FILIAL == xFilial("AAM") )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Zera os arrays de controle                                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aRecs    := {}
		aContPed := {}

		If lEnd
			Exit
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Execblock AT250FIL                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lAT250FIL
			lFiltro := ExecBlock("AT250FIL",.F.,.F.)
		EndIf

		DbSelectArea("AAS")
		DbSetOrder(1)

		//AAS_FILIAL+AAS_PROPOS+AAS_PREVIS+AAS_CLIENT+AAS_LOJA
		If DbSeek(xFilial("AAS")+AAM->AAM_PROPOS+AAM->AAM_REVPRO)

			lRateio := .T.
			lCarga  := .T.  //Indica que devera fazer a carga da quantidade de cada item.

			While (AAS->(!EOF()) .AND. AAS->AAS_FILIAL == xFilial("AAS") .AND. ;
			AAS->AAS_PROPOS == AAM->AAM_PROPOS .AND. AAS->AAS_PREVIS == AAM->AAM_REVPRO)
				aAdd(aSocios,{AAS->AAS_CLIENT,AAS->AAS_LOJA,AAS->AAS_PERCEN})
			AAS->(DbSkip())
			End

		EndIf

		If !lRateio
			aAdd(aSocios,{AAM->AAM_CODCLI,AAM->AAM_LOJA})
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicio da transacao                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Begin Transaction

		For nX := 1 To Len(aSocios)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se o contrato esta ativo  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
			If AAM->AAM_STATUS == "1" .AND. lFiltro

				aContPed := {}
				aDadosIt := {}
				cItem    := "00"

				AAN->(DbSetOrder(1))
				cSeekAAN := xFilial("AAN") + AAM->AAM_CONTRT

				If	AAN->( DbSeek( cSeekAAN ) )

					While AAN->(!Eof() .AND. AAN_FILIAL + AAN_CONTRT == cSeekAAN )
					
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Obtem a data original ( antes de iniciar o processamento ) ³
						//³ Isso eh necessario pois o programa deve considerar o campo ³
						//³ AAN_DATA antes de ser manipulado                           ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If Empty( nScan := AScan( aDataOri, { |x| x[1]=="AAN" .AND. x[2] == AAN->( Recno() ) } ) ) 
							dDataAAN := AAN->AAN_DATA
							AAdd( aDataOri, { "AAN", AAN->( Recno() ), dDataAAN } )
						Else
							dDataAAN := aDataOri[ nScan, 3 ]
						EndIf

						If	dProcesso >= AAN->AAN_INICOB .AND. Iif( AAM->AAM_TPCONT=="1", .T., dProcesso <= AAN->AAN_FIMCOB )

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Caso necessario, efetua o reajuste                   ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If !Empty( AAN->AAN_CODIND ) .AND. !Empty( AAN->AAN_PERREA )

								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Calcula o numero de meses decorridos                 ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								dUltRea := If( Empty( AAN->AAN_ULTREA ), AAN->AAN_INICOB, AAN->AAN_ULTREA )

								nQtMesUltRea := Year( AAN->AAN_ULTREA ) * 12 + Month( AAN->AAN_ULTREA )
								nDiaUltRea   := Day( AAN->AAN_ULTREA )

								nQtdMeses    := Year( dProcesso ) * 12 + Month( dProcesso ) - nQtMesUltRea - If( Day( dProcesso ) < nDiaUltRea, 1, 0 )

								If nQtdMeses >= AAN->AAN_PERREA

									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Chama a funcao de calculo do reajuste                ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									nValorReaj := AtCalcReaj( AAN->AAN_VLRUNI, AAN->AAN_CODIND, dUltRea + 1, dProcesso )

									RecLock( "AAN", .F. )

									AAN->AAN_ULTREA := dProcesso
									AAN->AAN_VLRUNI := nValorReaj
									AAN->AAN_VALOR  := AAN->AAN_VLRUNI * AAN->AAN_QUANT

									AAN->( MsUnLock() )

								EndIf

							EndIf

							dbSelectArea("SE4")
							SE4->(dbSetOrder(1))
							SE4->(dbSeek(xFilial("SE4")+AAN->AAN_CONPAG ))

							nValor += AAN->AAN_VALOR
							aCondPag := Condicao(nValor,AAN->AAN_CONPAG,0,dProcesso-Day(dProcesso)+1)
							nVlrDif 	:= nValor
							For nCntFor := 1 To Len(aCondPag)
								nVlrDif -= aCondPag[nCntFor][2]
							Next nCntFor
							If Len(aCondPag) > 0
								aCondPag[Len(aCondPag)][2] += nVlrDif
							EndIf
							nValor := 0

							For nCntFor := 1 To Len(aCondPag)
								If ( dDataAAN < aCondPag[nCntFor][1] .AND. nValor == 0 )
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Verifica se a data de processamento e igual a data da condicao ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									If ( dProcesso == aCondPag[nCntFor][1] )
										nValor := aCondPag[nCntFor][2]
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Verifica se esta usando param. p/ gerar PV no ultimo dia do mes³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									ElseIf ( lUltimoDia .AND. dProcesso == LastDay(dProcesso) ) 
										If dProcesso < aCondPag[nCntFor][1]
											nValor := aCondPag[nCntFor][2]
										EndIf
									EndIf
								EndIf
							Next nCntFor

							If	( nValor > 0 )

								lGeraPV := .T.

								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Ponto de entrada para permitir ou nao a geracao        ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If lAta250CD
									lGeraPV := ExecBlock( "ATA250CD",.F., .F., { dProcesso, nValor } )
								EndIf

								If lGeraPV

									lTravas := .T. 

									SB1->(DbSetOrder(1))
									SB1->(DbSeek( xFilial("SB1") + AAN->AAN_CODPRO ))

									cLocPad := If( Empty( RetFldProd(SB1->B1_COD,"B1_LOCPAD") ), "01", RetFldProd(SB1->B1_COD,"B1_LOCPAD") ) 

									SB2->(DbSetOrder(1))
									If SB2->(DbSeek( xFilial("SB2") + AAN->AAN_CODPRO + cLocPad ))
										If !( SoftLock("SB2") )
											lTravas := .F.
										EndIf
									EndIf

									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ O produto deve possuir TES de saida                  ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									SF4->(DbSetOrder(1))
									If SF4->(DbSeek( xFilial("SF4") + RetFldProd(SB1->B1_COD,"B1_TS") )) .AND. lTravas 

										Aadd( aCols, Array(Len(aHeader)+1) )
										nCampos := Len( aCols )

										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³ Posiciona no cliente                                 ³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										SA1->( DbSetOrder( 1 ) ) 
										SA1->( DbSeek( xFilial( "SA1" ) + aSocios[nX][1] + aSocios[nX][2] ) )

										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³ Define o CFO                                         ³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										aDadosCFO := {}
									 	Aadd(aDadosCfo,{"OPERNF","S"})
									 	Aadd(aDadosCfo,{"TPCLIFOR",SA1->A1_TIPO})
									 	Aadd(aDadosCfo,{"UFDEST"  ,SA1->A1_EST})
									 	Aadd(aDadosCfo,{"INSCR"   ,SA1->A1_INSCR})
										cCfo := MaFisCfo(,SF4->F4_CF,aDadosCfo)

										cItem := SomaIt( cItem )

										AAdd( aDadosIt, Array( 5 ) )

										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³ Preenche antecipadamente o valor unitario e a quantidade ³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										If !Empty( nPosPrcVen := AScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "C6_PRCVEN" } ) ) 
											aCols[ nCampos, nPosPrcVen ] := NoRound( AAN->AAN_VLRUNI, aHeader[ nPosPrcVen, 5 ] )
											aDadosIt[ Len( aDadosIt ), 3 ] := aCols[ nCampos, nPosPrcVen ]
										EndIf

										If lRateio

											If lCarga
												aAdd(aQtdxAAN,{cItem,AAN->AAN_QUANT})
											EndIf

											 If (nX == Len(aSocios))

												If !Empty( nPosQtdVen := AScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "C6_QTDVEN" } ) )
													nY	 := aScan(aQtdxAAN,{|x| x[1] == cItem })
													nQtd := aQtdxAAN[nY][2]
													aCols[ nCampos, nPosQtdVen ]	:= NoRound(nQtd, aHeader[ nPosQtdVen, 5 ] )
													aDadosIt[ Len( aDadosIt ), 2 ] := aCols[ nCampos, nPosQtdVen ]

												EndIf

				 							 Else

												If !Empty( nPosQtdVen := AScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "C6_QTDVEN" } ) )
													nQtd := Round((AAN->AAN_QUANT/100) * aSocios[nX][3],TAMSX3("AAN_QUANT")[2])
													aCols[ nCampos, nPosQtdVen ]	:= NoRound(nQtd,aHeader[ nPosQtdVen, 5 ] )
													aDadosIt[ Len( aDadosIt ), 2 ] := aCols[ nCampos, nPosQtdVen ]
													nY := aScan(aQtdxAAN,{|x| x[1] == cItem })
													aQtdxAAN[nY][2] -= nQtd
												EndIf

											EndIf
										Else

											If !Empty( nPosQtdVen := AScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "C6_QTDVEN" } ) )
												aCols[ nCampos, nPosQtdVen ]	:= NoRound( AAN->AAN_QUANT, aHeader[ nPosQtdVen, 5 ] )
												aDadosIt[ Len( aDadosIt ), 2 ] := aCols[ nCampos, nPosQtdVen ]
											EndIf

										EndIf

										For nCntFor := 1 To Len(aHeader)
											If	AllTrim(aHeader[nCntFor,2]) == "C6_ITEM"
												aCols[nCampos,nCntFor]	:= cItem
												aDadosIt[Len(aDadosIt),5] := cItem
											ElseIf AllTrim(aHeader[nCntFor,2]) == "C6_PRODUTO"
												aCols[nCampos,nCntFor]	:= AAN->AAN_CODPRO
											ElseIf AllTrim(aHeader[nCntFor,2]) == "C6_UM"
												aCols[nCampos,nCntFor]	:= SB1->B1_UM
											ElseIf AllTrim(aHeader[nCntFor,2]) == "C6_VALOR"
												aCols[nCampos,nCntFor]	:= NoRound( aCols[nCampos,nPosPrcVen]*;
															aCols[nCampos,nPosQtdVen], aHeader[ nCntFor, 5 ] )
												aDadosIt[ Len( aDadosIt ), 4 ] := aCols[nCampos,nCntFor]
											ElseIf AllTrim(aHeader[nCntFor,2]) == "C6_TES"
												aCols[nCampos,nCntFor]	:= RetFldProd(SB1->B1_COD,"B1_TS")
											ElseIf AllTrim(aHeader[nCntFor,2]) == "C6_CODISS"
												aCols[nCampos,nCntFor]	:= SB1->B1_CODISS
											ElseIf AllTrim(aHeader[nCntFor,2]) == "C6_CF"
												aCols[nCampos,nCntFor]	:= cCfo
											ElseIf AllTrim(aHeader[nCntFor,2]) == "C6_SEGUM"
												aCols[nCampos,nCntFor]	:= SB1->B1_SEGUM
											ElseIf AllTrim(aHeader[nCntFor,2]) == "C6_LOCAL"
												aCols[nCampos,nCntFor]	:= RetFldProd(SB1->B1_COD,"B1_LOCPAD")
											ElseIf AllTrim(aHeader[nCntFor,2]) == "C6_ENTREG"
												aCols[nCampos,nCntFor]	:= dDataBase
											ElseIf AllTrim(aHeader[nCntFor,2]) == "C6_PEDCLI"
												aCols[nCampos,nCntFor]	:= AAN->AAN_CONTRT
											ElseIf AllTrim(aHeader[nCntFor,2]) == "C6_DESCRI"
												aCols[nCampos,nCntFor]	:= SB1->B1_DESC
												aDadosIt[ Len( aDadosIt ), 1 ] := SB1->B1_DESC
											ElseIf AllTrim(aHeader[nCntFor,2]) == "C6_PRUNIT"
												aCols[nCampos,nCntFor]	:= AAN->AAN_VLRUNI
											ElseIf AllTrim(aHeader[nCntFor,2]) == "C6_CONTRT"
												aCols[nCampos,nCntFor]	:= AAN->AAN_CONTRT
											ElseIf AllTrim(aHeader[nCntFor,2]) == "C6_ITCONTR"
												aCols[nCampos,nCntFor]	:= AAN->AAN_ITEM
											ElseIf AllTrim(aHeader[nCntFor,2]) == "C6_TPCONTR"
												aCols[nCampos,nCntFor]	:= "1"
											ElseIf IsHeadRec(aHeader[nCntFor,2])
												aCols[nCampos,nCntFor]	:= 0
											Elseif IsHeadAlias(aHeader[nCntFor,2])
												aCols[nCampos,nCntFor]	:= ""
											ElseIf AllTrim(aHeader[nCntFor,2]) <> "C6_PRCVEN" .AND. ;
													AllTrim(aHeader[nCntFor,2]) <> "C6_QTDVEN"
												aCols[nCampos,nCntFor] := CriaVar(aHeader[nCntFor,2],.T.)
											EndIf
										Next nCntFor
										aCols[nCampos,Len(aHeader)+1] := .F.

										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³ Armazena os itens que geraram PV                     ³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										AAdd( aContPed, { "AAN", AAN->AAN_CONTRT + AAN->AAN_ITEM, NIL } )

									EndIf

								EndIf

							EndIf

						EndIf

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Armazena os itens que foram processados              ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If Empty( AScan( aRecs, { |x| x[1] == "AAN" .AND. x[2]==AAN->AAN_CONTRT + AAN->AAN_ITEM } ) )
							AAdd( aRecs, { "AAN", AAN->AAN_CONTRT + AAN->AAN_ITEM, AAN->( RecNo() ) } )
						EndIf

						AAN->(DbSkip())
					EndDo

				EndIf
				// Contrato de WMS
				AAO->(DbSetOrder(1))
				If	AAO->(DbSeek( xFilial("AAO") + AAM->AAM_CONTRT ))

					While AAO->(!Eof() .AND. AAO_FILIAL + AAO_CONTRT == xFilial("AAO") + AAM->AAM_CONTRT)
						If	dProcesso >= AAO->AAO_INICOB .AND. Iif( AAM->AAM_TPCONT == "1", .T., dProcesso <= AAO->AAO_FIMCOB )

							nValor += AAO->AAO_VALOR
							aCondPag := Condicao(nValor,AAO->AAO_CONPAG,0,dProcesso-Day(dProcesso)+1)
							nVlrDif 	:= nValor
							For nCntFor := 1 To Len(aCondPag)
								nVlrDif -= aCondPag[nCntFor][2]
							Next nCntFor
							If Len(aCondPag) > 0
								aCondPag[Len(aCondPag)][2] += nVlrDif
							EndIf
							nValor := 0

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Obtem a data original ( antes de iniciar o processamento ) ³
							//³ Isso eh necessario pois o programa deve considerar o campo ³
							//³ AAO_DATA antes de ser manipulado                           ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If Empty( nScan := AScan( aDataOri, { |x| x[1]=="AAO" .AND. x[2]==AAO->( Recno() ) } ) ) 
								dDataAAO := AAO->AAO_DATA
								AAdd( aDataOri, { "AAO", AAO->( Recno() ), dDataAAO } )
							Else 
								dDataAAO := aDataOri[ nScan, 3 ]
							EndIf

							For nCntFor := 1 To Len(aCondPag)
								If ( dDataAAO < aCondPag[nCntFor][1] .AND. nValor == 0 .AND. dProcesso == aCondPag[nCntFor][1] )
									nValor := aCondPag[nCntFor][2]
								EndIf
							Next nCntFor

							SB1->(DbSetOrder(1))
							SB1->(DbSeek( xFilial("SB1") + AAO->AAO_CODPRO ))
							cLocPad := Iif(Empty(RetFldProd(SB1->B1_COD,'B1_LOCPAD')),'01',RetFldProd(SB1->B1_COD,'B1_LOCPAD'))
							//-- Obtem quantidade de movimentos conforme referencia de cobranca do contrato
							nQuant := 0

							If AAO->(FieldPos("AAO_FORMUL")) > 0 .AND. 	!Empty(AAO->AAO_FORMUL)
								nQuant := Formula(AAO->AAO_FORMUL)
								nBkpQtd := nQuant
							Else
								nQuant := DL250Movto(cLocPad,AAO->AAO_REFCOB,AAO->AAO_SERVIC,AAO->AAO_TAREFA,AAO->AAO_ATIVID,AAM->AAM_CODCLI,Iif(AAM->AAM_ABRANG=='1',AAM->AAM_LOJA,Space(Len(AAM->AAM_LOJA))))
								nBkpQtd := nQuant
							EndIf

							If	lAt250Mov
								aRetPE:=ExecBlock("AT250MOV",.F.,.F.,{nQuant,dProcesso})
								If	ValType(aRetPE) == 'A' .And. !Empty(aRetPE) .And. ValType(aRetPE[1])=='N'
									nQuant := aRetPE[1]
								EndIf
							EndIf

							If	( nValor > 0 .AND. nQuant > 0 )
								lTravas := .T.
								SB2->(DbSetOrder(1))
								If SB2->(DbSeek( xFilial("SB2") + AAO->AAO_CODPRO + cLocPad ))
									If !( SoftLock("SB2") )
										lTravas := .F.
									EndIf
								EndIf
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ O produto deve possuir TES de saida                  ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								SF4->(DbSetOrder(1))
								If SF4->(DbSeek( xFilial("SF4") + RetFldProd(SB1->B1_COD,"B1_TS") )).AND. lTravas // .AND. !lTravas 

									M->C5_EMISSAO:= dProcesso

									Aadd( aCols, Array(Len(aHeader)+1) )
									nCampos := Len( aCols )

									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Posiciona no cliente                                 ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									SA1->( DbSetOrder( 1 ) ) 
									SA1->( DbSeek( xFilial( "SA1" ) + aSocios[nX][1] + aSocios[nX][2] ) ) 
	
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Define o CFO                                         ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									aDadosCFO := {}
								 	Aadd(aDadosCfo,{"OPERNF","S"})
								 	Aadd(aDadosCfo,{"TPCLIFOR",SA1->A1_TIPO})
								 	Aadd(aDadosCfo,{"UFDEST"  ,SA1->A1_EST})
								 	Aadd(aDadosCfo,{"INSCR"   ,SA1->A1_INSCR})
									cCfo := MaFisCfo(,SF4->F4_CF,aDadosCfo)

									cItem := SomaIt( cItem )

									AAdd( aDadosIt, Array( 5 ) )

									If lRateio 

										If lCarga
											aAdd(aQtdxAAO,{cItem,nBkpQtd})
										EndIf

										If (nX == Len(aSocios))
												nY	 := aScan(aQtdxAAO,{|x| x[1] == cItem }) 
												nQuant := aQtdxAAO[nY][2]
										Else
												nQtd := Round((nQuant/100) * aSocios[nX][3],TAMSX3("DB_QUANT")[2])
												nQuant := nQtd
												nY := aScan(aQtdxAAO,{|x| x[1] == cItem })
												aQtdxAAO[nY][2] -= nQtd
										EndIf

									EndIf

									For nCntFor := 1 To Len(aHeader)
										If	AllTrim(aHeader[nCntFor,2]) == "C6_ITEM"
											aCols[nCampos,nCntFor]	:= cItem
											aDadosIt[Len(aDadosIt),5] := cItem
										ElseIf AllTrim(aHeader[nCntFor,2]) == "C6_PRODUTO"
											aCols[nCampos,nCntFor]	:= AAO->AAO_CODPRO
										ElseIf AllTrim(aHeader[nCntFor,2]) == "C6_UM"
											aCols[nCampos,nCntFor]	:= SB1->B1_UM
										ElseIf AllTrim(aHeader[nCntFor,2]) == "C6_QTDVEN"
											aCols[nCampos,nCntFor]	:= nQuant
											aDadosIt[ Len( aDadosIt ), 2 ] := nQuant
										ElseIf AllTrim(aHeader[nCntFor,2]) == "C6_PRCVEN"
											//-- Obtem preco conforme a tabela de preco informada no contrato
											nPrcVen := 0
											nPrcVen := DL250Preco(AAO->AAO_TABELA,AAO->AAO_CODPRO,nQuant)
											aCols[nCampos,nCntFor]	:= nPrcVen
											aDadosIt[ Len( aDadosIt ), 3 ] := nPrcVen
										ElseIf AllTrim(aHeader[nCntFor,2]) == "C6_VALOR"
											aCols[nCampos,nCntFor]	:= nQuant * nPrcVen
											aDadosIt[ Len( aDadosIt ), 4 ] := nQuant * nPrcVen
										ElseIf AllTrim(aHeader[nCntFor,2]) == "C6_TES"
											aCols[nCampos,nCntFor]	:= RetFldProd(SB1->B1_COD,"B1_TS")
										ElseIf AllTrim(aHeader[nCntFor,2]) == "C6_CF"
											aCols[nCampos,nCntFor]	:= cCfo 
										ElseIf AllTrim(aHeader[nCntFor,2]) == "C6_SEGUM"
											aCols[nCampos,nCntFor]	:= SB1->B1_SEGUM
										ElseIf AllTrim(aHeader[nCntFor,2]) == "C6_LOCAL"
											aCols[nCampos,nCntFor]	:= RetFldProd(SB1->B1_COD,"B1_LOCPAD")
										ElseIf AllTrim(aHeader[nCntFor,2]) == "C6_ENTREG"
											aCols[nCampos,nCntFor]	:= M->C5_EMISSAO
										ElseIf AllTrim(aHeader[nCntFor,2]) == "C6_PEDCLI"
											aCols[nCampos,nCntFor]	:= AAO->AAO_CONTRT
										ElseIf AllTrim(aHeader[nCntFor,2]) == "C6_DESCRI"
											aCols[nCampos,nCntFor]	:= SB1->B1_DESC
											aDadosIt[ Len( aDadosIt ), 1 ] := SB1->B1_DESC
										ElseIf AllTrim(aHeader[nCntFor,2]) == "C6_PRUNIT"
											aCols[nCampos,nCntFor]	:= nQuant * nPrcVen
										ElseIf AllTrim(aHeader[nCntFor,2]) == "C6_CONTRT"
											aCols[nCampos,nCntFor]	:= AAO->AAO_CONTRT
										ElseIf AllTrim(aHeader[nCntFor,2]) == "C6_ITCONTR"
											aCols[nCampos,nCntFor]	:= AAO->AAO_ITEM
										ElseIf AllTrim(aHeader[nCntFor,2]) == "C6_TPCONTR"
											aCols[nCampos,nCntFor]	:= "2"
										ElseIf IsHeadRec(aHeader[nCntFor,2])
											aCols[nCampos,nCntFor]	:= AAN->(Recno())
										Elseif IsHeadAlias(aHeader[nCntFor,2])
											aCols[nCampos,nCntFor]	:= "AAN"
										Else
											aCols[nCampos,nCntFor] := CriaVar(aHeader[nCntFor,2],.T.)
										EndIf
									Next nCntFor
									aCols[nCampos,Len(aHeader)+1] := .F.
				
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Armazena os itens que geraram PV                     ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									AAdd( aContPed, { "AAO", AAO->AAO_CONTRT + AAO->AAO_ITEM, NIL } ) 

								EndIf

							EndIf
						EndIf

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Armazena os itens que foram processados              ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If Empty( AScan( aRecs, { |x| x[1] == "AAO" .AND. x[2] == AAO->AAO_CONTRT + AAO->AAO_ITEM } ) )
							AAdd( aRecs, { "AAO", AAO->AAO_CONTRT + AAO->AAO_ITEM, AAO->( RecNo() ), "" } ) 
						EndIf

						AAO->(DbSkip())
					EndDo

		 		EndIf

				If	nCampos > 0
					SA1->(DbSetOrder(1))
					SA1->(DbSeek( xFilial("SA1") + aSocios[nX][1] + aSocios[nX][2] ))

					DbSelectArea("SC5")
					nCampos := SC5->( FCount() )
					For nCntFor := 1 To nCampos
						M->&(Eval(bCampo,nCntFor)) := CriaVar(FieldName(nCntFor),.T.)
					Next nCntFor
					M->C5_TIPO    := "N"
					M->C5_CLIENTE := aSocios[nX][1]
					M->C5_LOJACLI := aSocios[nX][2]
					M->C5_TIPOCLI := SA1->A1_TIPO 
					M->C5_DESC1   := 0
					M->C5_DESC2   := 0
					M->C5_DESC3   := 0
					M->C5_DESC4   := 0
					M->C5_ACRSFIN := SE4->E4_ACRSFIN 

					If AAM->AAM_GRPVOP == '2'
						M->C5_FILIAL := cMV_APDLFO
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Grava os campos padroes para cliente / loja          ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					ALTERA := .F.
					A410Cli("C5_CLIENTE",M->C5_CLIENTE,.F.)
					A410Loja("C5_LOJACLI",M->C5_LOJACLI,.F.)

					M->C5_CLIENT  := Iif((!Empty(AAM->(FieldGet(FieldPos("AAM_CLIENT"))))),AAM->AAM_CLIENT,AAM->AAM_CODCLI)     ///  Alterado para assumir cliente de entrega cadastrado no contrato
					M->C5_LOJAENT := Iif((!Empty(AAM->(FieldGet(FieldPos("AAM_LOJENT"))))),AAM->AAM_LOJENT,AAM->AAM_LOJA)	  ///  Alterado para assumir Loja do cliente de entrega cadastrado no contrato 
					M->C5_CONDPAG := AAM->AAM_CPAGPV
					M->C5_TABELA  := &( GetNewPar( "MV_ATCSTAB", '"1"' ) )

					Begin Transaction
					Inclui := .T.

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Ponto de entrada antes da gravacao do pedido         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lAt250Ped
						ExecBlock( "AT250PED", .F., .F., { dProcesso } )
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ funcao de gravacao de pedido. Padrao                 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					A410Grava("SC5","SC6")
					While GetSX8Len() > nStackSX8 
						ConfirmSx8()
					EndDo
					EvalTrigger()

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Libera numeros reservados                            ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					FreeUsedCode(.T.)

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Associa os itens do contrato ao pedido               ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nLoop := 1 To Len( aContPed ) 
						aContPed[ nLoop, 3 ] := M->C5_NUM 
					Next nLoop

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Ponto de entrada apos a gravacao do pedido           ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lATA250PV
						ExecBlock("ATA250PV",.F.,.F., { dProcesso } )
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Event Viewer - Envia e-mail ou RSS para Geracao ³
					//³ de Pedido de Venda - Contrato de Servicos.      ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cEventID  := "014" 
					cMensagem := M->C5_NUM + SA1->A1_COD + "/" + SA1->A1_LOJA + "-" + SA1->A1_NOME + "-" + AAM->AAM_CONTRT
					EventInsert(FW_EV_CHANEL_ENVIRONMENT, FW_EV_CATEGORY_MODULES, cEventID, FW_EV_LEVEL_INFO,""/*cCargo*/,STR0075,cMensagem)

					End Transaction

					While GetSX8Len() > nStackSX8
						RollBackSx8()
					EndDo

				EndIf

				aCols   := {}
				nCampos := 0

			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Faz a gravacao da ultima data de processamento e numeros de pedido ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nLoop := 1 to Len( aRecs )

				If aRecs[ nLoop, 1 ] == "AAN"

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Posiciona no AAN                                     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					AAN->( MsGoto( aRecs[ nLoop, 3 ] ) )

					RecLock( "AAN", .F. )

					AAN->AAN_DATA   := dProcesso

					If !Empty( nScan := AScan( aContPed, { |x| x[1] == "AAN" .AND. ;
							x[2] == AAN->AAN_CONTRT + AAN->AAN_ITEM } ) )

						AAN->AAN_ULTPED := aContPed[ nScan, 3 ]
						AAN->AAN_ULTEMI := dDataBase

					EndIf

				ElseIf aRecs[ nLoop, 1 ] == "AAO" 

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Posiciona no AAO                                     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					AAO->( MsGoto( aRecs[ nLoop, 3 ] ) ) 

					RecLock( "AAO", .F. )

					AAO->AAO_DATA   := dProcesso

					If !Empty( nScan := AScan( aContPed, { |x| x[1] == "AAO" .AND. ;
							x[2] == AAO->AAO_CONTRT + AAO->AAO_ITEM } ) )
						
						AAO->AAO_ULTPED := aContPed[ nScan, 3 ]
						AAO->AAO_ULTEMI := dDataBase

					EndIf

				EndIf
			Next nLoop

			lCarga 	 := .F.

		Next nX
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Final da transacao                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		End Transaction

		aSocios  := {}
		aQtdxAAN := {}
		aQtdxAAO := {}
		lRateio  := .F.

		AAM->(DbSkip())
	EndDo
	
	If !lAutomato
		IncProc()
	EndIf
	dProcesso++
EndDo


Return NIL
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ DL250Movto³ Autor ³ Alex Egydio          ³ Data ³21.03.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Quantidade para o pedido baseado na referencia de cobranca ³±±
±±³          ³ do contrato                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DL250Movto(ExpC1,ExpC2,ExpC3,ExpC4,ExpC5,ExpC6)            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Almoxarifado                                       ³±±
±±³          ³ ExpC3 = Referencia para cobranca                           ³±±
±±³          ³ ExpC4 = Servico                                            ³±±
±±³          ³ ExpC5 = Tarefa                                             ³±±
±±³          ³ ExpC6 = Atividade                                          ³±±
±±³          ³ ExpC7 = Cliente/Fornecedor                                 ³±±
±±³          ³ ExpC8 = Loja                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± */
Function DL250Movto(cAlmox,cRefCob,cServico,cTarefa,cAtivid,cCliFor,cLoja)
Local aAreaAnt	:= GetArea()
Local aAreaSB1	:= SB1->(GetArea())
Local nRet		:= 0
Local lRet		:= .T.
Default cRefCob:= '0004'		//-- Movimentacoes

//-- Nao gera mais de 1 PV por periodo
If !Empty(AAO->AAO_PPERMA) .AND. dDataBase >= (AAO->AAO_DATA+AAO->AAO_PPERMA)
	lRet := .F.
EndIf

If	lRet
	//-- DB_FILIAL + DB_CLIFOR + DB_LOJA + DB_SERVIC + DB_TAREFA + DB_ATIVID + DB_ESTORNO
	SDB->(DbSetOrder(13))
	SDB->(DbSeek(xFilial('SDB')+cCliFor+cLoja))
	While SDB->(!Eof() .AND. SDB->DB_FILIAL + SDB->DB_CLIFOR + SDB->DB_LOJA == xFilial('SDB')+cCliFor+cLoja)
		If	SDB->DB_LOCAL == cAlmox .AND. SDB->DB_ATUEST == 'N' .AND. (SDB->DB_ESTORNO==' ' .Or. SDB->DB_STATUS=='F') .AND.;
			DtoS(SDB->DB_DATA)>=DtoS(AAM->AAM_INIVIG) .AND. Iif(Empty(AAM->AAM_FIMVIG),.T.,DtoS(SDB->DB_DATA) <= DtoS(AAM->AAM_FIMVIG))
			If	Iif(Empty(SDB->DB_SERVIC),.T.,AllTrim(SDB->DB_SERVIC) == AllTrim(cServico)).AND.;
				Iif(Empty(SDB->DB_TAREFA),.T.,AllTrim(SDB->DB_TAREFA) == AllTrim(cTarefa)) .AND.;
				Iif(Empty(SDB->DB_ATIVID),.T.,AllTrim(SDB->DB_ATIVID) == AllTrim(cAtivid))
				If AllTrim(cRefCob) == '0001'						//-- Peso
					SB1->(DbSetOrder(1))
					SB1->(DbSeek(xFilial('SB1')+SDB->DB_PRODUTO))
					If	Upper(AllTrim(SB1->B1_UM)) == STR0026 //-- 'KG'
						nRet += SDB->DB_QUANT
					Else
						nRet += SDB->DB_QUANT * SB1->B1_PESO
					EndIf
				ElseIf AllTrim(cRefCob) == '0002'				//-- Volume M3
					SB5->(DbSetOrder(1))
					SB5->(DbSeek(xFilial('SB5')+SDB->DB_PRODUTO))
					nRet	+= SDB->DB_QUANT * (SB5->B5_ALTURLC*SB5->B5_LARGLC*SB5->B5_COMPRLC)
				ElseIf AllTrim(cRefCob) == '0003'				//-- Itens
					nRet	+= SDB->DB_QTSEGUM						//-- embalagem com 4 garrafas e igual a 1 item
				ElseIf AllTrim(cRefCob) == '0004'				//-- Movimentacoes
					nRet	+= 1
				ElseIf AllTrim(cRefCob) == '0005'				//-- Paletes
					nRet	+= 1
				ElseIf AllTrim(cRefCob) == '0006'				//-- Quantidade
					nRet	+= SDB->DB_QUANT
				EndIf
			EndIf
		EndIf
		SDB->(DbSkip())
	EndDo
	If	nRet <= 0
		Aviso(STR0022, STR0027+cServico+' / '+cTarefa+' / '+cAtivid+STR0028, {STR0014}) //'SIGAWMS'###'Movimentacoes do Servico/Tarefa/Atividade '###' nao encontrado no SDB.'###'Ok'
		nRet := 0
	EndIf
EndIf
RestArea(aAreaSB1)
RestArea(aAreaAnt)
Return nRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ DL250Preco³ Autor ³ Alex Egydio          ³ Data ³21.03.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Busca o preco correspondente a qtde digitada               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DL250Movto(ExpC1,ExpC2,ExpC3,ExpC4,ExpC5,ExpC6)            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Tabela de preco                                    ³±±
±±³          ³ ExpC2 = Produto                                            ³±±
±±³          ³ ExpC3 = Quantidade                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± */
Static Function DL250Preco(cTabela,cProduto,nQtde)
Local aAreaDA1	:= DA1->(GetArea())
Local nRet		:= 1
Local cSeek		:= ''

DA1->(DbSetOrder(1))
If DA1->(DbSeek( cSeek := xFilial("DA1") + cTabela + cProduto, .F. ))
	While DA1->( !Eof() .AND. DA1_FILIAL + DA1_CODTAB + DA1_CODPRO == cSeek )
		//-- Busca o preco correspondente a qtde digitada
		If	nQtde <= DA1->DA1_QTDLOT
			nRet := DA1->DA1_PRCVEN
			Exit
		EndIf
		DA1->(DbSkip())
	EndDo
Else
	Aviso(STR0022, STR0030+cTabela+STR0031+cProduto+STR0032, {STR0014}) //'SIGAWMS'###'Tabela de precos '###' do Produto '###' nao encontrado no DA1.'###'Ok'
	lRet := .F.
EndIf

RestArea(aAreaDA1)
Return( nRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³AT250When ³ Autor ³Patricia A. Salomao    ³ Data ³05.04.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Determinar permissao de edicao dos campos dos contrato      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³AT250When( cExpC1 )                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExpC1: Campo a ser considerado para validacao             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TECA250 - Integracao com o Modulo de Transporte (TMS)       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function AT250When( cCampo )
Local lRet     := .T.
Local aArea    := GetArea()
Local aAreaDC5 := DC5->(GetArea())
Local cCont    := ""
Local cTabela  := ""
Local oModel   := FWModelActive()  
Local cCodServ := ""

Default cCampo := ReadVar()

If cCampo $ 'M->AAM_FIMVIG'
	lRet := M->AAM_TPCONT == "2"

ElseIf cCampo $ 'M->DUX_VALFIX|M->DUX_FIXVAR'

	//--Somente habilita os campos DUX_VALFIX
	//--e DUX_FIXVAR quando o servico configurado
	//--no contrato estiver amarrado a um docto. 
	//--de apoio	
	DC5->(DbSetOrder(1)) //--DC5_FILIAL+DC5_SERVIC+DC5_ORDEM
	If DC5->(DbSeek(xFilial('DC5')+GDFieldGet('DUX_SERVIC',n)))
		If !(DC5->DC5_DOCTMS $ '|B|C|H|I|')
			lRet := .F.
			GDFieldPut('DUX_VALFIX', 0, n)
			GDFieldPut('DUX_FIXVAR', '0', n)	//--"0"=Nao Utilizado
		EndIf
	EndIf

ElseIf cCampo $ 'M->DUX_CRIRAT|M->DDA_CRIRAT|M->DDC_CRIRAT'
	// Sendo Criterio Sendo NAO UTILIZA, os outros campos de Rateio tambem	//
	// serao gatilhados automaticamente como NAO UTILIZA e bloqueados		//
	
	If IsInCallStack("RUNTRIGGER") //-- Libera Edição Para Atualização De Gatilhos
		lRet := .t.
	Else
		Do Case
		Case cCampo $ 'M->DDA_CRIRAT'
			cTabela := 'DDA'
		Case cCampo $ 'M->DDC_CRIRAT'
			cTabela := 'DDC'
		Case cCampo $ 'M->DUX_CRIRAT'
			cTabela := 'DUX'
		EndCase
		
		If FwFldGet(cTabela + '_BACRAT',n) == StrZero(1, Len(DUX->DUX_BACRAT))
			 lRet := .F.
		EndIf
	EndIf
	
ElseIf cCampo $ 'M->DDA_BACRAT|M->DDC_BACRAT|M->DUX_BACRAT'  
		If IsInCallStack("RUNTRIGGER") //-- Libera Edição Para Atualização De Gatilhos
			lRet := .t.
		EndIf

ElseIf cCampo $ 'M->DUX_PRORAT|M->DDA_PRORAT|M->DDC_PRORAT'
	If IsInCallStack("RUNTRIGGER") //-- Libera Edição Para Atualização De Gatilhos
		lRet := .t.
	Else	
		// Sendo NAO UTILIZA, os outros campos de Rateio tambem			 //
		// serao gatilhados automaticamente como NAO UTILIZA e bloqueados//
		// OU
		// Base 'Ponto a Ponto' e Criterio 'Origem/Destino' obrigatoriamente 
		// o campo DUX_PRORAT deve ser 'Nao Utiliza', pois nao havera rateio 
		
		Do Case
		Case cCampo $ 'M->DDA_PRORAT'
			cTabela := 'DDA'
		Case cCampo $ 'M->DDC_PRORAT'
			cTabela := 'DDC'
		Case cCampo $ 'M->DUX_PRORAT'
			cTabela := 'DUX'
		EndCase
		
		If FwFldGet( cTabela + '_BACRAT' , n ) == StrZero(1, Len(DUX->DUX_BACRAT))
			lRet := .F.
		ElseIf FwFldGet(cTabela + '_BACRAT' , n ) == StrZero(2, Len(DUX->DUX_BACRAT)) .And. (FwFldGet(cTabela + '_CRIRAT' , n ) == StrZero(2, Len(DUX->DUX_CRIRAT)) ;
			.Or. FwFldGet(cTabela + '_CRIRAT' , n ) == 'A' )
			lRet := .F.
		EndIf
		
	EndIf
	
ElseIf cCampo $ 'M->DDC_FIMVIG'
	lRet := FwFldGet('DDC_TPCONT') == '2'
	
ElseIf cCampo $ 'M->DUX_VALCOL|M->DDA_VALCOL'

	If cCampo $ 'M->DDA_VALCOL'
		cCont := FwFldGet('DDA_SERVIC',n)
	Else
		cCont := FwFldGet('DUX_SERVIC',n)
	EndIf	
		
	//-- Serviços X Tarefas 		
	DbSelectArea("DC5")
	DbSetOrder( 1 ) //-- DC5_FILIAL+DC5_SERVIC+DC5_ORDEM
	MsSeek( FWxFilial("DC5") + cCont )
	
	If DC5->DC5_SERTMS <> '1' //-- Coleta
		If IsInCallStack("RUNTRIGGER") //-- Libera Edição Para Atualização De Gatilhos
			lRet := .t.
		Else
			lRet := .f.
		EndIf		
	EndIf
ElseIf cCampo $ 'M->DDA_TIPOPE|M->DDC_TIPOPE|M->DUX_TIPOPE'

	Do Case
	Case cCampo $ 'M->DDA_TIPOPE'
		cCont    := 'DDA'
		cCodServ := FwFldGet('DDA_SERVIC',n)
	Case cCampo $ 'M->DDC_TIPOPE'
		cCont    := 'DDC'
	Case cCampo $ 'M->DUX_TIPOPE'
		cCont    := 'DUX'
		cCodServ := FwFldGet('DUX_SERVIC',n)
	EndCase
	
	//-- Serviços X Tarefas 	
	If !Empty(cCodServ)	
		DbSelectArea("DC5")
		DbSetOrder( 1 ) //-- DC5_FILIAL+DC5_SERVIC+DC5_ORDEM
		MsSeek( FWxFilial("DC5") + cCodServ )
		
		If DC5->DC5_SERTMS <> '1' //-- Coleta
			If IsInCallStack("RUNTRIGGER") //-- Libera Edição Para Atualização De Gatilhos
				lRet := .t.
			Else
				lRet := .f.
			EndIf		
		EndIf
	EndIf
	
	If lRet
		If FwFldGet( cCont + '_VALCOL' , n ) == '0'  //Nao Utiliza
			If IsInCallStack("RUNTRIGGER") //-- Libera Edição Para Atualização De Gatilhos
				lRet := .t.
			Else	
				lRet := .f.
			EndIf
		EndIf
	EndIf	
			

ElseIf cCampo $ 'M->DDP_CLIDEV|M->DDP_LOJDEV|M->DDP_PERRAT|M->DDP_CRIRAT'
	lRet := M->AAM_ABRANG == '2'   //Cliente
	If lRet
		//--- Somente Criterio de Rateio %Fixo
		If lTMSItCt
			lRet:= oModel:GetModel( "MdGridIDDA" ):GetValue( "DDA_PRORAT" ) == 'A' .Or.;
			(oModel:GetModel( "MdGridIDDA" ):GetValue( "DDA_PRORAT" ) == '1' .And. oModel:GetModel( "MdGridIDDC" ):GetValue( "DDC_PRORAT" ) == 'A')
		Else
			lRet:= oModel:GetModel( "MdGridIDUX" ):GetValue( "DUX_PRORAT" ) == 'A'
		EndIf	  
	EndIf

ElseIf cCampo $ 'M->DUX_CRDVFA|M->DDA_CRDVFA|M->DDC_CRDVFA'
	If IsInCallStack("RUNTRIGGER") //-- Libera Edição Para Atualização De Gatilhos
		lRet:= .T.
	Else	
		Do Case
		Case cCampo $ 'M->DDA_CRDVFA'
			cCont := 'DDA'
		Case cCampo $ 'M->DDA_CRDVDC'
			cCont := 'DDA'		
		Case cCampo $ 'M->DDC_CRDVFA'
			cCont := 'DDC'
		Case cCampo $ 'M->DDC_CRDVDC'
			cCont := 'DDC'
		Case cCampo $ 'M->DUX_CRDVFA'
			cCont := 'DUX'
		Case cCampo $ 'M->DUX_CRDVDC'
			cCont := 'DUX'		
		EndCase
		
		If FwFldGet( cCont + '_PRORAT' , n ) <> 'A'
			lRet:= .F.
		EndIf
	EndIf
	
EndIf

RestArea(aAreaDC5)
RestArea(aArea)
Return( lRet )

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³AT250Perfi³ Autor ³Patricia A. Salomao    ³ Data ³10.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Perfil do Cliente                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³AT250Perfil(ExpN1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 - Opcao Selecionada                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TECA250 - Integracao com o Modulo de Transporte (TMS)       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function AT250Perfil(nOpcx)
Local   aArea    := GetArea()
Local   aSavTela := {}
Local   aSavGets := {}
Private cCodcli  := M->AAM_CODCLI
Private cLoja    := M->AAM_LOJA
Default aTela		:= {}
Default aGets		:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva as variaveis utilizadas na GetDados Anterior.    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aSavTela := aClone(aTela)
aSavGets := aClone(aGets)
SAVEINTER()

cCadastro := STR0045 // "Perfil do Cliente"

If Empty(M->AAM_CODCLI) .OR. Empty(M->AAM_LOJA)
	Help('',1,'AT250NOCLI') //Informe o Codigo do Cliente / Loja
	Return .T.
EndIf

DbSelectArea('DUO')
DbSetOrder(1)
DbSeek(xFilial('DUO')+M->AAM_CODCLI+M->AAM_LOJA)
If DUO->(Eof())
	Inclui := .T.
	Altera := .F.                                         
	FWExecView (, "TMSA480" , 3 , ,{|| .T. }, , , , , , , ) 
Else
	Inclui := .F.
	Altera := .T.
	FWExecView (, "TMSA480" , 4 , ,{|| .T. }, , , , , , , ) 
EndIf

aTela     := aClone(aSavTela)
aGets     := aClone(aSavGets)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura as variaveis utilizadas na GetDados Anterior. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RESTINTER()

RestArea(aArea)

Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³AT250Vld  ³ Autor ³Patricia A. Salomao    ³ Data ³10.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se os campos poderao ser Alterados                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³AT250Vld()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TECA250 - Integracao com o Modulo de Transporte (TMS)       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function AT250Vld(lOnlyNeg, cAction)

	Local lRet    		:= .T.
	Local oModel		:= FWModelActive()
	Local cServic		:= Iif(lTMSItCt,oModel:GetModel("MdGridIDDA"):GetValue("DDA_SERVIC"),oModel:GetModel("MdGridIDUX"):GetValue("DUX_SERVIC"))
	Local cCodNeg		:= Iif(lTMSItCt,oModel:GetModel("MdGridIDDC"):GetValue("DDC_CODNEG"),"")
	Local lContCtt		:= SuperGetMv("MV_CONTCTT",,.F.) //-- Este Parâmetro Define Se Os Campos Do Grid Podem Ser Alterados Se Já Houver Movimentos Do Contrato.

	Default lOnlyNeg := .F.

	//-- Este Parâmetro Define Se Os Campos Do Grid Podem Ser Alterados Se Já Houver Movimentos Do Contrato. 
	If !lContCtt .And. !(cAction = "DELETE")
		If lOnlyNeg .Or. "DDC_" $ ReadVar()
			cServic := ""
		EndIf
		If !Empty(cServic) .Or. !Empty(cCodNeg)
			lRet:= AT250Doc(cServic,cCodNeg)
		Endif	
		
		If !lRet
			Help('',1,"AT250NOVLD") // Este Campo Nao podera ser alterado, pois Existe CTRC Utizando este Servico ...
		EndIf
	EndIf

Return( lRet )

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³AT250Val  ³ Autor ³Patricia A. Salomao    ³ Data ³26.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao dos  campos                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³AT250Val()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TECA250 - Integracao com o Modulo de Transporte (TMS)       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function AT250Val()

Local aArea     := GetArea()
Local lRet      := .T.
Local cCampo    := ReadVar()
Local cTabela   := ""
Local cTipo     := ""
Local cServic   := ""
Local oModel    := FWModelActive()  
Local oView		:= FWViewActive()  
Local oMdGridDUX := oModel:GetModel( "MdGridIDUX" )
Local oMdGridDDA := oModel:GetModel( "MdGridIDDA" )
Local oMdGridDDC := oModel:GetModel( "MdGridIDDC" )
Local oMdGridDDP := oModel:GetModel( "MdGridIDDP" )
Local oMdlFldAAM := oModel:GetModel( "MdFieldCAAM" )
Local cConteudo  := ""
Local lCriRat    := .T.
Local nI         := 0
Local cMsgErr    := ''

If cCampo == 'M->DUX_SERVIC'  .Or. cCampo == 'M->DDA_SERVIC' .Or. cCampo == 'M->DDA_SRVCOL' .Or. cCampo == 'M->DDC_SRVCOL'
	If cCampo == 'M->DUX_SERVIC'
		cServic := M->DUX_SERVIC
	ElseIf  cCampo == 'M->DDA_SERVIC'
		cServic := M->DDA_SERVIC
	ElseIf  cCampo == 'M->DDA_SRVCOL'
		cServic := M->DDA_SRVCOL
	ElseIf  cCampo == 'M->DDC_SRVCOL'
		cServic := M->DDC_SRVCOL					
	EndIf
	
	If cCampo == 'M->DDC_SRVCOL' .Or. cCampo == 'M->DDA_SRVCOL'
		DC5->(DbSetOrder(1))
		If DC5->(DbSeek(xFilial('DC5')+cServic)) .AND. DC5->DC5_SERTMS <> StrZero(1,Len(DC5->DC5_SERTMS))
			Help("",1,"AT250NOCOL") //-- O Serviço selecionado não é de coleta. Selecione/Digite um serviço de coleta. 
			lRet := .F.
		EndIf
	EndIf	
	
	DC5->(DbSetOrder(1))
	If DC5->(DbSeek(xFilial('DC5')+cServic)) .AND. DC5->DC5_CATSER <> StrZero(1,Len(DC5->DC5_CATSER))
		Help("",1,"AT250NOSER") //-- Serviço inválido. Selecione um serviço de categoria operacional.
		lRet := .F.
	Else
		//--Se o Docto. de Transporte amarrado
		//--ao servico nao for um Docto. de Apoio,
		//--Zera os campos referente a cobranca do
		//--valor fixo do contrato:
		If !(DC5->DC5_DOCTMS $ '|B|C|H|I|')
			GDFieldPut('DUX_VALFIX', 0, n)
			GDFieldPut('DUX_FIXVAR', '0', n)	//--"0"=Nao Utilizado
		EndIf
	EndIf
	If	lRet
		lRet := TecA250Chk('2')
	EndIf

ElseIf cCampo $ 'M->DUX_TABFRE.M->DUX_TIPTAB.M->DDA_TABFRE.M->DDA_TIPTAB'
	lRet := TecA250Chk('2',.T.,.F.)
	If	lRet
		If cCampo == 'M->DUX_TABFRE'
			cTabela := M->DUX_TABFRE
			cTipo   := FwFldGet( 'DUX_TIPTAB' )
		ElseIf cCampo == 'M->DUX_TIPTAB'
			cTabela := FwFldGet( 'DUX_TABFRE' )
			cTipo   := M->DUX_TIPTAB
		ElseIf cCampo == 'M->DDA_TABFRE'
			cTabela := M->DDA_TABFRE
			cTipo   := FwFldGet( 'DDA_TIPTAB', n )
		ElseIf cCampo == 'M->DDA_TIPTAB'
			cTabela := FwFldGet( 'DDA_TABFRE', n )
			cTipo   := M->DDA_TIPTAB
		EndIf
		If !Empty(cTabela) .AND. !Empty(cTipo) 
		 	lRet := ExistCpo('DTL',cTabela+cTipo,1) 
		 	If lRet
				lRet := TMSTbAtiva( cTabela, cTipo, , , , .T. )
				If lRet
					lRet := AT250WhCfg()
				EndIf
			EndIf
		EndIf
	EndIf

ElseIf cCampo $ 'M->DUX_TABALT.M->DUX_TIPALT.M->DDA_TABALT.M->DDA_TIPALT'
	lRet := TecA250Chk('2',.F.,.T.)
	If	lRet
		If cCampo == 'M->DUX_TABALT'
			cTabela := M->DUX_TABALT
			cTipo   := FwFldGet( 'DUX_TIPALT', n )
		ElseIf cCampo == 'M->DUX_TIPALT'
			cTabela := FwFldGet( 'DUX_TABALT', n )
			cTipo   := M->DUX_TIPALT
		ElseIf cCampo == 'M->DDA_TABALT'
			cTabela := M->DDA_TABALT
			cTipo   := FwFldGet( 'DDA_TIPALT', n )
		ElseIf cCampo == 'M->DDA_TIPALT'
			cTabela := FwFldGet( 'DDA_TABALT', n )
			cTipo   := M->DDA_TIPALT
		EndIf
		If !Empty(cTabela) .AND. !Empty(cTipo) 
			lRet := ExistCpo('DTL',cTabela+cTipo,1)
			If lRet
				lRet := TMSTbAtiva( cTabela, cTipo )
			EndIf
		EndIf
	EndIf
		
ElseIf cCampo $ 'M->DUX_BACRAT|M->DDA_BACRAT|M->DDC_BACRAT'

	// 1=Nao Utiliza;2=Ponto a Ponto;3=Consolidado //
	// Sendo Criterio Consolidado, o Criterio de Calculo (DUX_CRIRAT)     //
	// sera gatilhado automaticamente como 2=Orig/Dest e o campo bloqueado//
	If lTMSItCt    
		If cCampo $ 'M->DDA_BACRAT'
			If M->DDA_BACRAT == StrZero(3, Len(DDA->DDA_BACRAT))				
				oMdGridDDA:LoadValue('DDA_CRIRAT',StrZero(2, Len(DDA->DDA_CRIRAT)))
				oMdGridDDA:LoadValue('DDA_DECRIR',TMSValField("FwFldGet('DDA_CRIRAT')",.F.))
				
			// Sendo NAO UTILIZA, os outros campos de Rateio tambem //
			// serao gatilhados automaticamente como NAO UTILIZA	//
			ElseIf M->DDA_BACRAT == StrZero(1, Len(DDA->DDA_BACRAT))
				oMdGridDDA:LoadValue('DDA_CRIRAT',StrZero(1, Len(DDA->DDA_CRIRAT)))
				oMdGridDDA:LoadValue('DDA_DECRIR',TMSValField("FwFldGet('DDA_CRIRAT')",.F.))
				oMdGridDDA:LoadValue('DDA_PRORAT',StrZero(1, Len(DDA->DDA_PRORAT)))
				oMdGridDDA:LoadValue('DDA_DEPROR',TMSValField("FwFldGet('DDA_PRORAT')",.F.))
			EndIf
		Else
			If M->DDC_BACRAT == StrZero(3, Len(DDC->DDC_BACRAT))  
				oMdGridDDC:LoadValue('DDC_CRIRAT',StrZero(2, Len(DDC->DDC_CRIRAT)))
				oMdGridDDC:LoadValue('DDC_DECRIR',TMSValField("FwFldGet('DDC_CRIRAT')",.F.))
				   
			ElseIf M->DDC_BACRAT == StrZero(1, Len(DDC->DDC_BACRAT))
				oMdGridDDC:LoadValue('DDC_CRIRAT',StrZero(1, Len(DDC->DDC_CRIRAT)))
				oMdGridDDC:LoadValue('DDC_DECRIR',TMSValField("FwFldGet('DDC_CRIRAT')",.F.))   
				oMdGridDDC:LoadValue('DDC_PRORAT',StrZero(1, Len(DDC->DDC_PRORAT)))
				oMdGridDDC:LoadValue('DDC_DEPROR',TMSValField("FwFldGet('DDC_PRORAT')",.F.))  
			EndIf
		EndIf	
	Else
		If M->DUX_BACRAT == StrZero(3, Len(DUX->DUX_BACRAT))
		    If DUX->(ColumnPos('DUX_CRIRAT')) > 0
			   oMdGridDUX:LoadValue('DUX_CRIRAT',StrZero(2, Len(DUX->DUX_CRIRAT)))
			EndIf
			If DUX->(ColumnPos('DUX_DECRIR')) > 0
			    oMdGridDUX:LoadValue('DUX_DECRIR',TMSValField("FwFldGet('DUX_CRIRAT')",.F.))
	        EndIf
		// Sendo NAO UTILIZA, os outros campos de Rateio tambem //
		// serao gatilhados automaticamente como NAO UTILIZA	//
		ElseIf M->DUX_BACRAT == StrZero(1, Len(DUX->DUX_BACRAT))
			 oMdGridDUX:LoadValue('DUX_CRIRAT',StrZero(1, Len(DUX->DUX_CRIRAT))) 
			 oMdGridDUX:LoadValue('DUX_DECRIR',TMSValField("FwFldGet('DUX_CRIRAT')",.F.))
			 oMdGridDUX:LoadValue('DUX_PRORAT',StrZero(1, Len(DUX->DUX_PRORAT)))
			 oMdGridDUX:LoadValue('DUX_CRIRAT',StrZero(1, Len(DUX->DUX_CRIRAT)))
			 If DUX->(ColumnPos('DUX_DECRIR')) > 0 
			    oMdGridDUX:LoadValue('DUX_DECRIR',TMSValField("FwFldGet('DUX_CRIRAT')",.F.))
			 EndIf
			 If DUX->(ColumnPos('DUX_DEPROR')) > 0
			    oMdGridDUX:LoadValue('DUX_DEPROR',TMSValField("FwFldGet('DUX_PRORAT')",.F.))
			 EndIf
		EndIf
	EndIf
	
ElseIf cCampo $ 'M->DUX_CRIRAT|M->DDA_CRIRAT|M->DDC_CRIRAT'

	// 3=Consolidado E 3=Maior Vlr.Comp
	If lTMSItCt
		If cCampo $ 'M->DDA_CRIRAT'
			If FwFldGet( 'DDA_BACRAT', n ) == StrZero(3, Len(DDA->DDA_BACRAT)) 
				If M->DDA_CRIRAT == StrZero(3, Len(DDA->DDA_CRIRAT))
					lRet := .F.
					lCriRat:= .F.
				EndIf	
			ElseIf FwFldGet( 'DDA_BACRAT', n ) == StrZero(2, Len(DDA->DDA_BACRAT)) .And. (M->DDA_CRIRAT == StrZero(2, Len(DDA->DDA_CRIRAT)) ;
				.oR. M->DDA_CRIRAT == 'A' )
				oMdGridDDA:LoadValue('DDA_PRORAT',StrZero(1, Len(DDA->DDA_PRORAT)))
			EndIf			
		Else
			If FwFldGet( 'DDC_BACRAT', n ) == StrZero(3, Len(DDC->DDC_BACRAT)) 
				If  M->DDC_CRIRAT == StrZero(3, Len(DDC->DDC_CRIRAT))
					lRet := .F.
					lCriRat:= .F.
				EndIf	
					
			ElseIf FwFldGet( 'DDC_BACRAT', n ) == StrZero(2, Len(DDC->DDC_BACRAT)) .And. (M->DDC_CRIRAT == StrZero(2, Len(DDC->DDC_CRIRAT)) ;
				.oR. M->DDC_CRIRAT == 'A' )
		 		oMdGridDDC:LoadValue('DDC_PRORAT',StrZero(1, Len(DDC->DDC_PRORAT)))
			EndIf	
		EndIf
	Else
		If FwFldGet( 'DUX_BACRAT', n ) == StrZero(3, Len(DUX->DUX_BACRAT)) 
			If M->DUX_CRIRAT == StrZero(3, Len(DUX->DUX_CRIRAT))
				lRet := .F.
				lCriRat:= .F.
			EndIf		
		ElseIf FwFldGet( 'DUX_BACRAT', n ) == StrZero(2, Len(DUX->DUX_BACRAT)) .And. (M->DUX_CRIRAT == StrZero(2, Len(DUX->DUX_CRIRAT)) ;
			.oR. M->DUX_CRIRAT == 'A' )
		 	oMdGridDUX:LoadValue('DUX_PRORAT',StrZero(1, Len(DUX->DUX_PRORAT)))
		EndIf	
	EndIf
	
	If !lRet 
		If !lCriRat
			Aviso("AVISO",STR0077, {"OK"}) //"Opção 3=Maior Vlr.Comp não pode ser Selecionada quando Consolidado !"
		EndIf
	EndIf
	
ElseIf cCampo $ 'M->DUX_PRORAT|M->DDA_PRORAT|M->DDC_PRORAT'	 
	cServic:= ""
	Do Case
	Case cCampo $ 'M->DDA_PRORAT'
		cTabela  := 'DDA'
		cConteudo:= M->DDA_PRORAT
		cServic  := FwFldGet('DDA_SERVIC',n)
	Case cCampo $ 'M->DDC_PRORAT'
		cTabela := 'DDC'
		cConteudo:= M->DDC_PRORAT
	Case cCampo $ 'M->DUX_PRORAT'
		cTabela := 'DUX'
		cConteudo:= M->DUX_PRORAT
		cServic  := FwFldGet('DUX_SERVIC',n)
	EndCase
	
	If cConteudo == 'A' 
		If (FwFldGet( cTabela + '_BACRAT', n ) <> StrZero(3, Len(DUX->DUX_BACRAT)) .Or. M->AAM_ABRANG <> '2' )   //%Fixo
			Aviso("AVISO",'Opção somente pode ser Selecionada para Consolidado e Abrangencia do Contrato igual a "Cliente" !', {"OK"}) 
			lRet:= .F.
		ElseIf cTabela == "DDC" 
			HELP(" ", 1,"AT250PRORAT") //Opção somente pode ser Selecionada para Servico de Negociação !
			lRet:= .F.
		EndIf	
	Else
			
		If cConteudo == "D" .And. cServic <> ''  //Qtd.Coletas
			DbSelectArea("DC5")
			DbSetOrder( 1 ) //-- DC5_FILIAL+DC5_SERVIC+DC5_ORDEM
			If MsSeek( FWxFilial("DC5") + cServic ) .And.  DC5->DC5_SERTMS <> '1' 
				Aviso("AVISO",'Opção somente pode ser Selecionada para Servico de Coleta !', {"OK"}) 
				lRet:= .F.
			EndIf
		EndIf	
	EndIf
	
ElseIf cCampo == 'M->DDC_STATUS'
	//-- 1=Ativo | 2=Suspenso | 3=Encerrado
	If ( DDC->DDC_STATUS == StrZero(1,Len(DDC->DDC_STATUS)) .Or. DDC->DDC_STATUS == StrZero(2,Len(DDC->DDC_STATUS)) ) .And. ;
		M->DDC_STATUS == StrZero(3,Len(DDC->DDC_STATUS))

		//-- Se A negociacao do contrato estava "Ativa" ou "Suspensa" e foi passada para "Encerrada":
		If Aviso( STR0060, STR0078 + " " + STR0098 + " " + oMdGridDDC:GetValue("DDC_CODNEG"), { STR0062, STR0063} ) == 2 // "AVISO" ### "Deseja Encerrar a Negociacao do Contrato ?" ### "Sim" ### "Nao"
			lRet := .F.
		EndIf

	ElseIf DDC->DDC_STATUS == StrZero(3,Len(DDC->DDC_STATUS)) .And. ; 
			( M->DDC_STATUS == StrZero(1,Len(DDC->DDC_STATUS)) .Or. M->DDC_STATUS == StrZero(2,Len(DDC->DDC_STATUS)) )

		//--Se a negociacao do contrato estava "Encerrada" e foi passada para "Ativa" ou "Suspensa":
		If Aviso( STR0060, STR0079 + " " + STR0098 + " " + oMdGridDDC:GetValue("DDC_CODNEG"), { STR0062, STR0063} ) == 2 // "AVISO" ### "A negociacao do contrato encontra-se encerrada. Deseja ativar a negociacao do contrato ?" ### "Sim" ### "Nao"
			lRet := .F.
		EndIf
	EndIf

ElseIf cCampo $ 'M->DDH_TABFPG.M->DDH_TIPTPG'
	If cCampo == 'M->DDH_TABFPG'
		cTabela := M->DDH_TABFPG
		// Se a tabela nao for preenchida limpa tb o tipo de tabela
		If Empty(cTabela)
			oModel:LoadValue("MdGridIDDH","DDH_TIPTPG",Criavar("DDH_TIPTPG",.F.))
			If ValType(oView) == "O"
				oView:SetModified(.T.)
			EndIf
		EndIf
		cTipo := oModel:GetModel("MdGridIDDH"):GetValue("DDH_TIPTPG")
	ElseIf cCampo == 'M->DDH_TIPTPG'
		cTipo   := M->DDH_TIPTPG
		// Se o tipo nao for preenchido limpa tb a tabela
		If Empty(cTipo)
			oModel:LoadValue("MdGridIDDH","DDH_TABFPG",Criavar("DDH_TABFPG",.F.))
			If ValType(oView) == "O"
				oView:SetModified(.T.)
			EndIf
		EndIf
		cTipo := oModel:GetModel("MdGridIDDH"):GetValue("DDH_TABFPG")
	EndIf

	If !Empty(cTabela) .And. !Empty(cTipo)
		lRet := TMSTbAtiva(cTabela,cTipo,,,"2",.T.)
	EndIf

	If ValType(oView) == "O"
		oView:Refresh()
	EndIf

ElseIf cCampo $ 'M->DDP_CLIDEV|M->DDP_LOJDEV'
	If cCampo $ 'M->DDP_CLIDEV' .And. !Empty('M->DDP_CLIDEV')
		If  ExistCpo("SA1") .And. M->DDP_CLIDEV <> M->AAM_CODCLI
			Help("",1,"AT250NORAT") //-- O codigo do cliente devedor de rateio deve ser igual ao cliente do contrato.       
			lRet:= .F.
		EndIf
	EndIf
	
	If cCampo $ 'M->DDP_LOJDEV'
		lRet:= (ExistCpo("SA1",oMdGridDDP:GetValue("DDP_CLIDEV")+ M->DDP_LOJDEV ))
   	EndIf
ElseIf	cCampo $ "M->DDC_SRVCOL"
	If Posicione("DC5", 1, xFilial("DC5") + oMdGridDDC:Getvalue("DDC_SRVCOL"), "DC5_SERTMS") <> StrZero(1, Len(DC5->DC5_SERTMS))
		lRet := .F.
		Help(" ",1,"REGNOIS") //Nao existe registro relacionado a este codigo.
	EndIf
ElseIf cCampo $ 'M->DDC_TPCONT' //-- Tipo de Neg. Contrato
	//-- Se Cabeçalho é Por Tempo Determinado, o Item No DDC Não Pode Ser Vitalício
	If M->AAM_TPCONT == '2' .And. FwFldGet('DDC_TPCONT') == '1'
		Help('',1,'AT250TEMPD')
		lRet := .f.
	EndIf
ElseIf cCampo $ 'M->AAM_TPCONT' .And. lTMSItCt

	If M->AAM_TPCONT == '2' //-- Tempo Determinado

		If DDC->(ColumnPos("DDC_TPCONT")) > 0
	
			For nI := 1 To oMdGridDDC:Length()
				
				//-- Posiciona Na Linha Do Loop
				oMdGridDDC:GoLine( nI )
				
				If !(oMdGridDDC:IsDeleted())
				
					If oMdGridDDC:GetValue("DDC_TPCONT") == '1' .And. lRet
						Help('',1,'AT250TEMPV')
						oMdlFldAAM:SetValue("AAM_TPCONT","1") //-- Volta o Campo Para o Valor Anterior Pois O MVC Não Estava Respeitando o Retorno .f. 
						If ValType(oView) == "O"
							oView:Refresh()
						EndIf
						lRet := .f.				
					EndIf	
				EndIf
			Next nI
		EndIf
	EndIf	
ElseIf cCampo $ 'M->DDC_FIMVIG' .And. lTMSItCt

	//-- Valida Fim Da Vigência Do Contrato X Item Do Contrato 
	If !Empty(oMdGridDDC:GetValue("DDC_FIMVIG")) .And. !Empty( oMdGridDDC:GetValue("DDC_INIVIG") ) .AND.  oMdGridDDC:GetValue("DDC_FIMVIG") < oMdGridDDC:GetValue("DDC_INIVIG")
		Help('',1,'AT250FIMVG01') // "Data final de vigência menor que a data inicial na negociação do cliente."
		lRet := .f.
	ElseIf !Empty(oMdlFldAAM:GetValue("AAM_FIMVIG")) .And. Empty( oMdGridDDC:GetValue("DDC_FIMVIG") ) .AND. oMdGridDDC:GetValue("DDC_TPCONT") == "2"
		Help('',1,'AT250FIMVG02') //"Data final da vigência da negociação do cliente não pode ser vazia, pois a data final da  vigência do contrato esta preenchida."
		lRet := .f.
	ElseIf !Empty(oMdlFldAAM:GetValue("AAM_FIMVIG")) .And. oMdGridDDC:GetValue("DDC_FIMVIG") > oMdlFldAAM:GetValue("AAM_FIMVIG")
		
        cMsgErr := 'O campo ' + RetTitle('DDC_FIMVIG') + ' ref. a linha ' + StrZero(oMdGridDDC:getLine(),3) + ' da Grid ' +;
                    oMdGridDDC:getDescription() + ' não pode ser maior que a data de vigência do campo ' + RetTitle('AAM_FIMVIG')

		Help('',1,'AT250FIMVG','', cMsgErr ,1,4 )
       
		lRet := .f.
		
	ElseIf !Empty(oMdGridDDC:GetValue("DDC_FIMVIG")) .And. (oMdGridDDC:GetValue("DDC_FIMVIG") < oMdlFldAAM:GetValue("AAM_INIVIG")) 
		Help('',1,'AT250FIMVG03') //"Data final da vigência da negociação do cliente, não pode ser menor que a data inicial de vigencia do contrato.                             "
		lRet := .f.
	EndIf	
	
ElseIf cCampo $ 'M->DDC_INIVIG' .And. lTMSItCt

	//-- Valida Fim Da Vigência Do Contrato X Item Do Contrato 
	If oMdGridDDC:GetValue("DDC_INIVIG") < oMdlFldAAM:GetValue("AAM_INIVIG")
		Help('',1,'AT250INIVG') // "Início Da Vigência Do Item Menor Que o Início Da Vigência Do Contrato(AAM_INIVIG)!"
		lRet := .f.
	ElseIf !Empty(oMdlFldAAM:GetValue("AAM_FIMVIG")) .And. oMdGridDDC:GetValue("DDC_INIVIG") > oMdlFldAAM:GetValue("AAM_FIMVIG")
		Help('',1,'AT250INIVG01') //Início da vigência do item é maior que o fim da vigência do contrato(AAM_FIMIVIG)!                                        
		lRet := .f.
	EndIf	

ElseIf cCampo == 'M->DDC_CODNEG'
	If IsInCallStack("TMSF79Tela")
		lRet := TMSF79VCpo()
	Else
		DDB->(DbSetOrder(1))
		If DDB->(DbSeek(xFilial("DDB") + M->DDC_CODNEG))
			Help( ,, 'HELP',, "Código de negociação nao existe.", 1, 0) 
			lRet := .F.
		EndIf
	EndIf

ElseIf cCampo == "M->AAM_NFCTR"
	If nModulo == 43
		If M->AAM_AGRNFC <> '2' .And. M->AAM_NFCTR == 0
			lRet := .F.
			Help('',1,'AT250NFCTR',,'',1,0)
		EndIf	
	EndIf
EndIf

RestArea(aArea)

Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³AT250WhCfg³ Autor ³Alex Egydio            ³ Data ³10.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Nao permite editar campos se encontrar documentos que usem o³±±
±±³          ³numero do contrato e servico.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TECA250 - Somente se tiver Integracao com o TMS (Transporte)³±±
±±³          ³DT9_CODPAS,DT9_SERVIC,DT9_CALPES,DT9_CALPAS,DT9_AGRPAS      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function AT250WhCfg()
Local aAreaDT6	:= DT6->(GetArea())
Local oModel		:= FWModelActive()
Local cServic		:= Iif(lTMSItCt,oModel:GetModel("MdGridIDDA"):GetValue("DDA_SERVIC"),oModel:GetModel("MdGridIDUX"):GetValue("DUX_SERVIC"))
Local cCodNeg		:= Iif(lTMSItCt,oModel:GetModel("MdGridIDDC"):GetValue("DDC_CODNEG"),"")
Local lRet			:= .T.
Local lContCtt	:= SuperGetMv("MV_CONTCTT",,.F.) //-- Este Parâmetro Define Se Os Campos Do Grid Podem Ser Alterados Se Já Houver Movimentos Do Contrato.

If !Inclui .AND. IntTMS() .AND. ! Empty( cServic ) .And. !lContCtt
	lRet:= AT250Doc(cServic,cCodNeg)

	If !lRet
		Help('',1,"AT250NOVLD") // Este Campo Nao podera ser alterado, pois Existe CTRC Utizando este Servico ...
	EndIf
EndIf
RestArea(aAreaDT6)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ At250Reset³ Autor ³ Sergio Silveira      ³ Data ³12/06/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada da funcao que reinicializa as datas de controle dos³±±
±±³          ³ itens do contrato de servico e WMS                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ At250Reset()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function At250Reset(cAlias,nReg,nOpc, lAutomato)

Local aSay      := {}
Local aButtons  := {}

Local lPergunte := .F.

Local nOpca     := 0

Default lAutomato := .F.


Aadd(aSay, STR0052 ) //"Esta rotina reinicializa as datas de controle dos itens "
Aadd(aSay, STR0053 ) //"do contrato de parceria e WMS permitindo que os mesmos "
Aadd(aSay, STR0054 ) //"sejam avaliados novamente."
Aadd(aSay, STR0055 ) //"Atencao : Esta rotina deve ser utilizada apenas "
Aadd(aSay, STR0056 ) //"quando se deseja avaliar / gerar pedidos novamente."

AADD(aButtons, { 5,.T.,{|o| lPergunte := Pergunte( "ATA251", .T. )}})
AADD(aButtons, { 1,.T.,{|o| nOpcA:= 1,o:oWnd:End()	}})
AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }})

If !lAutomato
	FormBatch( STR0051, aSay, aButtons,,200,405 )  // Restaura datas
Else
	nOpcA := 1
EndIf

If ( nOpcA == 1 )

	If !lPergunte
		Pergunte( "ATA251", .F. )
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega os parametros para a chamada da funcao de processamento ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aParam := {}

	AAdd( aParam, { "CONTR_FROM" , MV_PAR01 } )
	AAdd( aParam, { "CONTR_TO"   , MV_PAR02 } )
	AAdd( aParam, { "CUSTID_FROM", MV_PAR03 } )
	AAdd( aParam, { "CUSTID_TO"  , MV_PAR04 } )
	AAdd( aParam, { "PRODID_FROM", MV_PAR05 } )
	AAdd( aParam, { "PRODID_TO"  , MV_PAR06 } )
	AAdd( aParam, { "ITEM_FROM"  , MV_PAR07 } )
	AAdd( aParam, { "ITEM_TO"    , MV_PAR08 } )
	AAdd( aParam, { "DATE"       , MV_PAR09 } )
	AAdd( aParam, { "TYPE"       , MV_PAR10 } )
	AAdd( aParam, { "UPDPAR"     , MV_PAR11 } )

	If !lAutomato
		Processa({|lEnd| At250ResPr( aParam, lAutomato ) },STR0057,,.T. ) // "Reinicializando datas"
	Else
		 At250ResPr( aParam, lAutomato ) 
	EndIf
	DbSelectArea("SX6")
	SX6->( MsUnLock() )

EndIf

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ At250ResPr³ Autor ³ Sergio Silveira      ³ Data ³12/06/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Reinicializa as datas de controle dos itens do contrato de ³±±
±±³          ³ servico e WMS                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ At250ResPr( ExpA1 )                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

Function At250ResPr( aParam, lAutomato )

Local cContrIni  := Space( Len( AAM->AAM_CONTRT ) )
Local cContrFim  := Replicate( "z", Len( AAM->AAM_CONTRT ) )
Local cCodCliIni := Space( Len( AAM->AAM_CODCLI ) )
Local cCodCliFim := Replicate( "z", Len( AAM->AAM_CODCLI ) )
Local cCodProIni := Space( Len( AAN->AAN_CODPRO ) )
Local cCodProFim := Replicate(  "z", Len( AAN->AAN_CODPRO ) )
Local cItemIni   := Space( Len( AAN->AAN_ITEM ) )
Local cItemFim   := Replicate( "z", Len( AAN->AAN_ITEM ) )
Local dDataReset := CTOD( "01/01/80" )

Local cTipo   := ""

Local nLoop   := 0
Local nAtuSX6 := 2
Local nAbrang := 3
Local cQuery    := ""
Local cAliasQry := ""

Default lAutomato := .F.


For nLoop := 1 To Len( aParam )

	cTipo    := aParam[ nLoop, 1 ]

	Do Case
	Case cTipo == "CONTR_FROM"
		cContrIni    := aParam[ nLoop, 2 ]
	Case cTipo == "CONTR_TO"
		cContrFim    := aParam[ nLoop, 2 ]
	Case cTipo == "CUSTID_FROM"
		cCodCliIni   := aParam[ nLoop, 2 ]
	Case cTipo == "CUSTID_TO"
		cCodCliFim   := aParam[ nLoop, 2 ]
	Case cTipo == "PRODID_FROM"
		cCodProIni   := aParam[ nLoop, 2 ]
	Case cTipo == "PRODID_TO"
		cCodProFim   := aParam[ nLoop, 2 ]
	Case cTipo == "ITEM_FROM"
		cItemIni     := aParam[ nLoop, 2 ]
	Case cTipo == "ITEM_TO"
		cItemFim     := aParam[ nLoop, 2 ]
	Case cTipo == "DATE"
		dDataReset   := aParam[ nLoop, 2 ]
	Case cTipo == "TYPE"
		nAbrang      := aParam[ nLoop, 2 ]
	Case cTipo == "UPDPAR"
		nAtuSX6      := aParam[ nLoop, 2 ]
	EndCase

Next nLoop



If nAbrang == 1 .OR. nAbrang == 3

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Contrato de parceria                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cAliasQRY := GetNextAlias()

	cQuery := ""
	cQuery += "SELECT AAN.R_E_C_N_O_ AANRECNO FROM " + RetSqlName("AAM") + " AAM," + RetSqlName("AAN") + " AAN "
	cQuery += "WHERE "
	cQuery += "AAM_FILIAL='"  + xFilial( "AAM" ) + "' AND "
	cQuery += "AAM_CONTRT>='" + cContrINI  + "' AND AAM_CONTRT<='" + cContrFIM  + "' AND "
	cQuery += "AAM_CODCLI>='" + cCodCliINI + "' AND AAM_CODCLI<='" + cCodCliFIM + "' AND "
	cQuery += "AAM.D_E_L_E_T_=' ' AND "

	cQuery += "AAM_CONTRT=AAN_CONTRT AND "

	cQuery += "AAN_FILIAL='"  + xFilial( "AAN" ) + "' AND "
	cQuery += "AAN_ITEM>='"   + cItemIni   + "' AND AAN_ITEM<='"   + cItemFIM   + "' AND "
	cQuery += "AAN_CODPRO>='" + cCodProIni + "' AND AAN_CODPRO<='" + cCodProFim + "' AND "
	cQuery += "AAN.D_E_L_E_T_=' '"

	cQuery := ChangeQuery( cQuery )

	dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery ), cAliasQRY, .F., .T. )

	While !( cAliasQry )->( Eof() )
		AAN->( dbGoto( ( cAliasQRY )->AANRECNO ) )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Reinicializa a data                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RecLock( "AAN", .F. )
		AAN->AAN_DATA := dDataReset
		AAN->( MsUnlock() )
		( cAliasQry )->( DbSkip() )
	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Fecha a area de trabalho da query                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	( cAliasQry )->( dbCloseArea() )
	DbSelectArea( "AAM" )

EndIf

If nAbrang == 2 .OR. nAbrang == 3

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Contrato WMS                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cAliasQRY := GetNextAlias()

	cQuery := ""
	cQuery += "SELECT AAO.R_E_C_N_O_ AAORECNO FROM " + RetSqlName("AAM") + " AAM," + RetSqlName("AAO") + " AAO "
	cQuery += "WHERE "
	cQuery += "AAM_FILIAL='"  + xFilial( "AAM" ) + "' AND "
	cQuery += "AAM_CONTRT>='" + cContrINI  + "' AND AAM_CONTRT<='" + cContrFIM  + "' AND "
	cQuery += "AAM_CODCLI>='" + cCodCliINI + "' AND AAM_CODCLI<='" + cCodCliFIM + "' AND "
	cQuery += "AAM.D_E_L_E_T_=' ' AND "

	cQuery += "AAM_CONTRT=AAO_CONTRT AND "

	cQuery += "AAO_FILIAL='"  + xFilial( "AAO" ) + "' AND "
	cQuery += "AAO_ITEM>='"   + cItemIni   + "' AND AAO_ITEM<='"   + cItemFIM   + "' AND "
	cQuery += "AAO_CODPRO>='" + cCodProIni + "' AND AAO_CODPRO<='" + cCodProFim + "' AND "
	cQuery += "AAO.D_E_L_E_T_=' '"

	cQuery := ChangeQuery( cQuery )

	dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery ), cAliasQRY, .F., .T. )

	While !( cAliasQry )->( Eof() )
		AAO->( dbGoto( ( cAliasQRY )->AAORECNO ) )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Reinicializa a data                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RecLock( "AAO", .F. )
		AAO->AAO_DATA := dDataReset
		AAO->( MsUnlock() )
		( cAliasQry )->( DbSkip() )
	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Fecha a area de trabalho da query                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	( cAliasQry )->( dbCloseArea() )
	DbSelectArea( "AAM" )

EndIf


If nAtuSX6 == 1
	PutMV( "MV_ULCTSER", dDataReset )
EndIf

Return( .T. )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TecA250Chk³ Autor ³ Alex Egydio           ³ Data ³24.09.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se ha ajustes utilizando o servico do contrato    ³±±
±±³          ³ Funcao utilizada pelo SIGATMS                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - 1 = Avalia todos os servicos, utilizado na exclusao³±±
±±³          ³         2 = Avalia o servico posicionado na getdados,      ³±±
±±³          ³             utilizado na delecao da linha e na digitacao   ³±±
±±³          ³             do codigo do servico                           ³±±
±±³          ³ ExpL1 - .T. = Avalia a tabela de frete                     ³±±
±±³          ³         .F. = Nao avalia a tabela de frete                 ³±±
±±³          ³ ExpL2 - .T. = Avalia a tabela de frete alternativa         ³±±
±±³          ³         .F. = Nao avalia a tabela de frete alternativa     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TecA250Chk(cAcao,lTabFre,lTabAlt)
Local lRet		:= .T.
Local cServic	:= ''
Local cTabFre	:= ''
Local cTipTab	:= ''
Local nCntFor	:= 0
Local aSvCols	:= Nil

DEFAULT lTabFre:= .T.
DEFAULT lTabAlt:= .T.

//-- Verifica se o indice(7) do arquivo(DVC) foi criado
If	SIX->(DbSeek('DVC7')) .AND. AllTrim(SIX->CHAVE)=='DVC_FILIAL+DVC_SERVIC+DVC_TABFRE+DVC_TIPTAB+DVC_CODCLI+DVC_LOJCLI'
	//-- Executado pela exclusao de contratos
	If	cAcao == '1'
		aSvCols := aClone(aCols)
	   	aCols   := aClone(oModel:GetModel(Iif(lTMSItCt,"MdGridIDDA","MdGridIDUX")):aCols)
		
		//-- Nao permite a exclusao do contrato se houver ajustes utilizando o servico
		For nCntFor := 1 To Len(aCols)
			cServic := GdFieldGet(Iif(lTMSItCt,'DDA_SERVIC','DUX_SERVIC'),nCntFor)
			cTabFre := GdFieldGet(Iif(lTMSItCt,'DDA_TABFRE','DUX_TABFRE'),nCntFor)
			cTipTab := GdFieldGet(Iif(lTMSItCt,'DDA_TIPTAB','DUX_TIPTAB'),nCntFor)
			//-- Verifica se ha ajustes utilizando o servico e tabela de frete
			If	TecA250DVC(cServic,cTabFre,cTipTab,M->AAM_CODCLI,M->AAM_LOJA)
				lRet := .F.
				Exit
			EndIf
			cTabFre := GdFieldGet(Iif(lTMSItCt,'DDA_TABALT','DUX_TABALT'),nCntFor)
			cTipTab := GdFieldGet(Iif(lTMSItCt,'DDA_TIPALT','DUX_TIPALT'),nCntFor)
			//-- Verifica se ha ajustes utilizando o servico e tabela de frete alternativa
			If	TecA250DVC(cServic,cTabFre,cTipTab,M->AAM_CODCLI,M->AAM_LOJA)
				lRet := .F.
				Exit
			EndIf
		Next nCntFor
		
		aCols   := aClone(aSvCols)
		aSvCols := Nil
	//-- Executado na digitacao do codigo do servico, tabela de frete, tabela de frete alternativa e delecao do item do contrato
	ElseIf cAcao == '2'
		cServic := Iif(lTMSItCt,oModel:GetModel("MdGridIDDA"):GetValue("DDA_SERVIC"),oModel:GetModel("MdGridIDUX"):GetValue("DUX_SERVIC"))
		If	lTabFre
			cTabFre := Iif(lTMSItCt,oModel:GetModel("MdGridIDDA"):GetValue("DDA_TABFRE"),oModel:GetModel("MdGridIDUX"):GetValue("DUX_TABFRE"))
			cTipTab := Iif(lTMSItCt,oModel:GetModel("MdGridIDDA"):GetValue("DDA_TIPTAB"),oModel:GetModel("MdGridIDUX"):GetValue("DUX_TIPTAB"))
			//-- Verifica se ha ajustes utilizando o servico e tabela de frete
			If	TecA250DVC(cServic,cTabFre,cTipTab,M->AAM_CODCLI,M->AAM_LOJA)
				lRet := .F.
			EndIf
		EndIf
		If	lRet .AND. lTabAlt
			cTabFre := Iif(lTMSItCt,oModel:GetModel("MdGridIDDA"):GetValue("DDA_TABALT"),oModel:GetModel("MdGridIDUX"):GetValue("DUX_TABALT"))
			cTipTab := Iif(lTMSItCt,oModel:GetModel("MdGridIDDA"):GetValue("DDA_TIPALT"),oModel:GetModel("MdGridIDUX"):GetValue("DUX_TIPALT"))

			//-- Verifica se ha ajustes utilizando o servico e tabela de frete alternativa
			If	TecA250DVC(cServic,cTabFre,cTipTab,M->AAM_CODCLI,M->AAM_LOJA)
				lRet := .F.
			EndIf
		EndIf
	EndIf
	If !lRet
		//-- Nao sera permitido a alteracao do contrato pois ha ajustes para a tabela de frete
		Help('',1,'AT250AJUST',,STR0047 + cServic + CHR(13) + CHR(10) +;
		RetTitle('DUX_TABFRE')+' : '+cTabFre+' / '+cTipTab + CHR(13) + CHR(10) +;
		STR0043 + M->AAM_CODCLI+' / '+M->AAM_LOJA,4,1)
	EndIf
EndIf
Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TecA250DVC³ Autor ³ Alex Egydio           ³ Data ³24.09.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se ha ajustes utilizando o servico do contrato    ³±±
±±³          ³ Funcao utilizada pelo SIGATMS                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Codigo do servico                                  ³±±
±±³          ³ ExpC2 - Tabela de frete ou tabela de frete alternativa     ³±±
±±³          ³ ExpC3 - Tipo da tabela                                     ³±±
±±³          ³ ExpC4 - Codigo do cliente                                  ³±±
±±³          ³ ExpC5 - Loja                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function TecA250DVC(cServic,cTabFre,cTipTab,cCliente,cLojCli)
Local lRet := .F.
DVC->(DbSetOrder(7))
If	!Empty(cServic) .AND. !Empty(cTabFre) .AND. !Empty(cTipTab) .AND. !Empty(cCliente) .AND.;
	!Empty(cLojCli) .AND. DVC->(DbSeek(xFilial('DVC')+cServic+cTabFre+cTipTab+cCliente+cLojCli))
	lRet := .T.
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³AT250REL  ³ Autor ³ Patricia A. Salomao   ³ Data ³04.08.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inicializador padrao do campo DT9_PERCOB                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Conteudo do campo DT9_PERCOB                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Conrado Q.  ³08/01/07³115744³Adaptada para utilização do Walk-Thru.    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function AT250Rel()
Local  nValor := 0
If Inclui .OR. ValType(DT9->DT9_PERCOB) <> 'N'
	nValor := 100
EndIf
Return nValor

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³AT250Ajust³ Autor ³Eduardo de Souza       ³ Data ³ 20/01/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ajustes do Cliente (Ultima Sequencia)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TECA250 - Somente se tiver Integracao com o TMS (Transporte)³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function AT250Ajust( nOpcx )

Local oDlg
Local oList
Local cVar       := ''
Local aSize      := {}
Local aInfo      := {}
Local aObjects   := {}
Local aPosObj    := {}
Local aButtons   := {}
Local cTabFre    := ''
Local cTipTab    := ''
Local cServic    := ''
Local aAjustes   := {}
Local bSavKeyF4  := SetKey(VK_F4,Nil)
Local aCabec     := {}
Local aCabec1    := {}
Local IncOld     := Inclui
Local oModel		:= FwModelActive()
Local oSize		:= FwDefSize():New( .T. )

If lTMSItCt 
	cTabFre  := oModel:GetModel("MdGridIDDA"):GetValue("DDA_TABFRE")
	cTipTab  := oModel:GetModel("MdGridIDDA"):GetValue("DDA_TIPTAB")
	cServic  := oModel:GetModel("MdGridIDDA"):GetValue("DDA_SERVIC")
Else
	cTabFre  := oModel:GetModel("MdGridIDUX"):GetValue("DUX_TABFRE")
	cTipTab  := oModel:GetModel("MdGridIDUX"):GetValue("DUX_TIPTAB")
	cServic  := oModel:GetModel("MdGridIDUX"):GetValue("DUX_SERVIC")
Endif

aAjustes := AT250GerAj(cTabFre,cTipTab,cServic,@aCabec,@aCabec1) //-- Cria array com os ajustes do cliente

bSavKeyF4 := SetKey( VK_F4 , {|| AT250VerAj(aAjustes,oListBox:nAt,cTabFre,cTipTab,aCabec1) } )
Aadd(aButtons,	{'PRECO'  ,{|| AT250VerAj(aAjustes,oListBox:nAt,cTabFre,cTipTab,aCabec1) } , STR0065+ ' - <F4>', STR0066 })  //"Ajustes do Cliente" ### "Ajuste"
Aadd(aButtons,	{'BTPESQ' , {|| oListBox:nAt := AT250Pesq(aCabec, aAjustes, oListBox:nAt) } , STR0002, STR0002 })  //"Pesquisa"

//-- Dimensoes padroes
aSize   := MsAdvSize(.T.)

If nOpcx <> 3 .And. Inclui
	Inclui := .F.
EndIf

If Len(aAjustes) > 0

	aObjects := {}
	AAdd( aObjects, { 100,20, .t., .t. } )

	aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
	aPosObj := MsObjSize( aInfo, aObjects)

	DEFINE MSDIALOG oDlg FROM aSize[7], 000 TO aSize[6],aSize[5] TITLE STR0065 OF oMainWnd PIXEL STYLE WS_DLGFRAME 

	oListBox := TWBrowse():New( aPosObj[1,1],aPosObj[1,2],aPosObj[1,4]-aPosObj[1,2],aPosObj[1,3]-aPosObj[1,1], NIL, ;
                                 aCabec, NIL, oDlg, NIL, NIL, NIL,,,,,,,,,, "ARRAY", .T. )
	oListBox:SetArray( aAjustes )

	oListBox:bLine:= &('{ || Teca250bLi(oListBox:nAT,aAjustes) }')

	ACTIVATE MSDIALOG  oDlg ON INIT EnchoiceBar( oDlg, { || nOpca := 1,oDlg:End()}, {||oDlg:End()},,aButtons)
Else
	HELP(" ", 1,"REGNOIS")
Endif

SetKey(VK_F4,bSavKeyF4)

Inclui := IncOld

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³AT250GerAj³ Autor ³Eduardo de Souza       ³ Data ³ 20/01/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera array com os Ajustes do Cliente (Ultima Sequencia)    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ AT250GerAj()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TECA250 - Somente se tiver Integracao com o TMS (Transporte)³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function AT250GerAj(cTabFre,cTipTab,cServic,aCabec,aCabec1)

Local cQuery     := ''
Local aAjustes   := {}
Local cDesServ   := ''
Local cDesNeg	   := ''
Local aArea      := GetArea()
Local lAt250Aju  := ExistBlock("AT250AJU")
Local aUserCamp  := {}
Local aAreaSx3   := {}
Local nCount     := 0
Local nPadrao    := 0
Local aCabec2    := {}
Local cContexto  := ""

Private cAt250Qry:= GetNextAlias()
AADD( aCabec1, { '10', "DVC_CDRORI" , 'R','' } )
AADD( aCabec1, { '20', "DVC_REGORI" , 'R','' } )
AADD( aCabec1, { '30', "DVC_CDRDES" , 'R','' } )
AADD( aCabec1, { '40', "DVC_REGDES" , 'R','' } )
AADD( aCabec1, { '50', "DVC_SEQTAB" , 'R','' } )
AADD( aCabec1, { '60', "DVC_SERVIC" , 'R','' } )
AADD( aCabec1, { '70', "DVC_DESSER" , 'V','' } )
AADD( aCabec1, { '80', "DVC_CODPRO" , 'R','' } )
AADD( aCabec1, { '90', "B1_DESC" , 'R','' } )

If lTMSItCt
	AADD( aCabec1, { '71', "DVC_CODNEG" , 'R','' } )
	AADD( aCabec1, { '72', "DVC_DESNEG" , 'V','' } )
EndIf

nPadrao := Len(aCabec1)
If lAt250Aju
	aUserCamp := ExecBlock("AT250AJU",.F.,.F.,  )
	For nCount := 1 To Len(aUserCamp)
		If !( ValType(aUserCamp) == "A" .And. ValType(aUserCamp[nCount,1]) == "C" .And. !Empty( aUserCamp[nCount,1] ) ;
				.And. !Empty(FWSX3Util():GetFieldType( aUserCamp[nCount,1] ) )  )
			aCabec2 := {}
			Exit
		EndIf
		cContexto := GetSx3Cache(  aUserCamp[nCount,1], "X3_CONTEXT")
		//caso o ponto de entrada retorne um campo virtual e nao foi preenchido o codigo para alimentar o mesmo,
		//desconsidera o ponto de entrada.
		If Empty(aUserCamp[nCount,3]) .And. cContexto  == "V"
			aCabec2 := {}
			Exit
		EndIf
		//pesquisa no acabec1 para nao colocar 2 vezes o mesmo campo
		If Ascan( aCabec1, {|x| AllTrim(x[2]) == AllTrim( aUserCamp[nCount,2] ) }) == 0
			//acrescenta num array de apoio ate verificar se nao existe algum campo com problema em todo o array
			Aadd( aCabec2, { aUserCamp[nCount,2], aUserCamp[nCount,1] , cContexto,  IIF(cContexto== "V",  aUserCamp[nCount,3], "") } )
		EndIf
	Next nCount
	//caso esteja tudo bem acrescenta no array principal o array de apoio
	If Len(aCabec2) > 0
		For nCount := 1 To Len(aCabec2)
			Aadd( aCabec1, { aCabec2[nCount,1], aCabec2[nCount,2] , aCabec2[nCount,3], aCabec2[nCount,4] } )
		Next nCount
	EndIf
EndIf


cQuery := " SELECT DVC_CDRORI DVC_CDRORI , MAX(DUY1.DUY_DESCRI) DVC_REGORI, DVC_CDRDES DVC_CDRDES, "
If lTMSItCt
	cQuery += "        MAX(DUY2.DUY_DESCRI) DVC_REGDES, DVC_CODNEG DVC_CODNEG, DVC_SERVIC DVC_SERVIC,  DVC_CODPRO DVC_CODPRO, "
Else	
	cQuery += "        MAX(DUY2.DUY_DESCRI) DVC_REGDES, DVC_SERVIC DVC_SERVIC,  DVC_CODPRO DVC_CODPRO, "
EndIf	
cQuery += "        MAX(B1_DESC) B1_DESC       , MAX(DVC_SEQTAB) DVC_SEQTAB "
For nCount := nPadrao To Len(aCabec1)
	If aCabec1[nCount,3] <> "V"
		cQuery += " , MAX(" + aCabec1[nCount,2] + ") " + aCabec1[nCount,2] + " "
	EndIf
Next nCount

aCabec1 := aSort(aCabec1,,,{|x,y| x[1] < y[1] })

For nCount := 1 To Len(aCabec1)
	Aadd( aCabec , RetTitle( aCabec1[nCount,2] ) )
Next nCount

cQuery += "    FROM " + RetSqlName("DVC") + " DVC  "
cQuery += "    JOIN " + RetSqlName("DUY") + " DUY1 "
cQuery += "      ON  DUY1.DUY_FILIAL = '" + xFilial("DUY") + "' "
cQuery += "      AND DUY1.DUY_GRPVEN = DVC_CDRORI 	"
cQuery += "      AND DUY1.D_E_L_E_T_ = ' ' "
cQuery += "    JOIN " + RetSqlName("DUY") + " DUY2 "
cQuery += "      ON  DUY2.DUY_FILIAL = '" + xFilial("DUY") + "' "
cQuery += "      AND DUY2.DUY_GRPVEN = DVC_CDRDES "
cQuery += "      AND DUY2.D_E_L_E_T_ = ' ' "
cQuery += "    LEFT JOIN " + RetSqlName("SB1") + " SB1 "
cQuery += "      ON  B1_FILIAL = '" + xFilial("SB1") + "' "
cQuery += "      AND B1_COD    = DVC_CODPRO "
cQuery += "      AND SB1.D_E_L_E_T_ = ' ' "
cQuery += "      WHERE DVC_FILIAL = '" + xFilial("DVC") + "' "
cQuery += "        AND DVC_TABFRE = '" + cTabFre + "' "
cQuery += "        AND DVC_TIPTAB = '" + cTipTab + "' "
cQuery += "        AND DVC_CODCLI = '" + M->AAM_CODCLI + "' "
cQuery += "        AND DVC_LOJCLI = '" + M->AAM_LOJA   + "' "
cQuery += "        AND ( DVC_SERVIC = ' ' OR DVC_SERVIC = '" + cServic + "' ) "
cQuery += "        AND DVC.D_E_L_E_T_ = ' ' "
If lTMSItCt
	cQuery += " GROUP BY DVC_TABFRE, DVC_TIPTAB, DVC_CODCLI, DVC_LOJCLI, DVC_CDRORI , DVC_CDRDES, DVC_CODNEG, DVC_SERVIC, DVC_CODPRO "
Else
	cQuery += " GROUP BY DVC_TABFRE, DVC_TIPTAB, DVC_CODCLI, DVC_LOJCLI, DVC_CDRORI , DVC_CDRDES, DVC_SERVIC, DVC_CODPRO "
EndIf	
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAt250Qry, .F., .T.)

While (cAt250Qry)->(!Eof())
	cDesServ := ''
	cDesNeg  := ''
	If !Empty((cAt250Qry)->DVC_SERVIC)
		cDesServ := Tabela( "L4", (cAt250Qry)->DVC_SERVIC )
	EndIf
	
	If lTMSItCt
		If !Empty((cAt250Qry)->DVC_CODNEG)
			cDesNeg := POSICIONE("DDB",1,XFILIAL("DDB") + (cAt250Qry)->DVC_CODNEG,"DDB_DESCRI")
		EndIf
	EndIf

	Aadd( aAjustes, {  } )

	For nCount := 1 To Len(aCabec1)
		If aCabec1[nCount,2] == "DVC_DESSER"
			Aadd( aAjustes[Len(aAjustes)] , cDesServ )
		ElseIf aCabec1[nCount,2] == "DVC_DESNEG"
			Aadd( aAjustes[Len(aAjustes)] , cDesNeg )
		ElseIf aCabec1[nCount,3] == "V"
			Aadd( aAjustes[Len(aAjustes)] , &(aCabec1[nCount,4] ) )
		Else
			Aadd( aAjustes[Len(aAjustes)] , &("(cAt250Qry)->" + aCabec1[nCount,2]) )
		EndIf
	Next nCount

	(cAt250Qry)->(DbSkip())
EndDo

(cAt250Qry)->(DbCloseArea())

RestArea( aArea )

Return aAjustes

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³AT250VerAj³ Autor ³Eduardo de Souza       ³ Data ³ 20/01/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Visualiza os Ajustes do Cliente                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ AT250VerAj()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TECA250 - Somente se tiver Integracao com o TMS (Transporte)³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function AT250VerAj(aAjustes,nAt,cTabFre,cTipTab,aCabec1)

Local nCdrOri  := Ascan( aCabec1, {|x| AllTrim(x[2]) == "DVC_CDRORI" })
Local nCdrDes  := Ascan( aCabec1, {|x| AllTrim(x[2]) == "DVC_CDRDES" })
Local nSeqTab  := Ascan( aCabec1, {|x| AllTrim(x[2]) == "DVC_SEQTAB" })
Local nCodPro  := Ascan( aCabec1, {|x| AllTrim(x[2]) == "DVC_CODPRO" })
Local nServic  := Ascan( aCabec1, {|x| AllTrim(x[2]) == "DVC_SERVIC" })

Local cCdrOri  := aAjustes[nAt,nCdrOri]
Local cCdrDes  := aAjustes[nAt,nCdrDes]
Local cSeqTab  := aAjustes[nAt,nSeqTab]
Local cCodPro  := aAjustes[nAt,nCodPro]
Local cServic  := aAjustes[nAt,nServic]
Private cCadastro := STR0065
Private aFolder   := {}

SaveInter()

DVC->( DbSetOrder( 3 ) )
If DVC->(DbSeek(xFilial('DVC')+M->AAM_CODCLI+M->AAM_LOJA+cCdrOri+cCdrDes+cTabFre+cTipTab+cSeqTab+cCodPro+cServic))
	TMSA011Mnt('DVC' ,DVC->(Recno() ), 2 )
	//-- Restaura a tecla F4
	SetKey( VK_F4 , {|| AT250VerAj(aAjustes,nAt,cTabFre,cTipTab) } )
EndIf

RestInter()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSHisTabF³ Autor ³Eduardo de Souza       ³ Data ³ 09/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Historico da Tabela de Frete                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ TMSHisTabF()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TECA250 - Somente se tiver Integracao com o TMS (Transporte)³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSHisTabF()

Local oGet       := Nil
Local oDlg       := Nil   
Local aSize      := {}
Local aInfo      := {}
Local aObjects   := {}
Local aPosObj    := {}
Local aNoFields  := {}
Local aYesFields := {}
Local aButtons   := {}
Local oModel		:= FwModelActive()

If lTMSItCt 
	cTabFre  := oModel:GetModel("MdGridIDDA"):GetValue("DDA_TABFRE")
	cTipTab  := oModel:GetModel("MdGridIDDA"):GetValue("DDA_TIPTAB")
Else
	cTabFre  := oModel:GetModel("MdGridIDUX"):GetValue("DUX_TABFRE")
	cTipTab  := oModel:GetModel("MdGridIDUX"):GetValue("DUX_TIPTAB")
Endif

SaveInter()

Private aHeader := {}
Private aCols   := {}
Private aTela[0][0]
Private aGets[0]

//-- Dimensoes padroes
aSize   := MsAdvSize()
AAdd( aObjects, { 100, 100, .T., .T. } )

aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T.)

DWP->(DbSetOrder(1))
If DWP->(DbSeek(xFilial("DWP")+cTabFre+cTipTab))

	Aadd(aButtons, {'PARAMETROS',	{||TMSVisHTabF()},STR0067,STR0068 }) // 'Hist. Tabela de Frete', 'Hist.Tab.Frt'

	DEFINE MSDIALOG oDlg TITLE STR0069 FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL STYLE WS_DLGFRAME      // 'Historico de Reajuste de Tabela de Frete'

	TMSFillGetDados(2, "DWP", 1, xFilial("DWP") + cTabFre + cTipTab, { || DWP->DWP_FILIAL + DWP->DWP_TABFRE + DWP->DWP_TIPTAB }, { || .T. }, aNoFields, aYesFields)
	oGet := MSGetDados():New(aPosObj[1,1], aPosObj[1,2], aPosObj[1,3], aPosObj[1,4],2,'AllWaysTrue','AllWaysTrue',,.F.,,,,,,,,)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| oDlg:End() },{|| oDlg:End() },, aButtons )

EndIf

RestInter()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSVisHTbF³ Autor ³Eduardo de Souza       ³ Data ³ 09/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Historico da Tabela de Frete                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ TMSVisHTabF()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TECA250 - Somente se tiver Integracao com o TMS (Transporte)³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSVisHTabF()

Local oGet       := Nil
Local oDlg       := Nil
Local aSize      := {}
Local aInfo      := {}
Local aObjects   := {}
Local aPosObj    := {}
Local aNoFields  := {}
Local aYesFields := {}
Local aButtons   := {}
Local cNumIde    := aCols[n,GDFieldPos('DWP_NUMIDE')]

SaveInter()

Private aHeader := {}
Private aCols   := {}
Private aTela[0][0]
Private aGets[0]

//-- Dimensoes padroes
aSize   := MsAdvSize()
AAdd( aObjects, { 100, 050, .T., .T. } )
AAdd( aObjects, { 100, 050, .T., .T. } )

aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T.)

DWP->(DbSetOrder(3))
If DWP->(DbSeek(xFilial("DWP")+cNumIde))
	RegToMemory("DWP",.F.)
	DEFINE MSDIALOG oDlg TITLE STR0069 FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL STYLE WS_DLGFRAME

	oEnch := MsMGet():New('DWP',DWP->(Recno()),2,,,,,aPosObj[1],,3,,,,,,.T.)

	DWQ->(DbSetOrder(1))
	If DWQ->(DbSeek(xFilial("DWQ")+DWP->DWP_NUMIDE))
		TMSFillGetDados(2, "DWQ", 1, xFilial("DWQ") + cNumIde, { || DWQ->DWQ_FILIAL + DWQ->DWQ_NUMIDE }, { || .T. }, aNoFields, aYesFields)
		oGet := MSGetDados():New(aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4],2,'AllWaysTrue','AllWaysTrue',,.F.,,,,,,,,)
	EndIf

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| oDlg:End() },{|| oDlg:End() } ) 

EndIf

RestInter()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSHisCli ³ Autor ³Eduardo de Souza       ³ Data ³ 09/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Historico de reajuste do cliente                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ TMSHisCli()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TECA250 - Somente se tiver Integracao com o TMS (Transporte)³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSHisCli()

Local oGet
Local oDlg
Local aSize      := {}
Local aInfo      := {}
Local aObjects   := {}
Local aPosObj    := {}
Local aNoFields  := {}
Local aYesFields := {}
Local aButtons   := {}

SaveInter()

Private aHeader := {}
Private aCols   := {}
Private aTela[0][0]
Private aGets[0]

//-- Dimensoes padroes
aSize   := MsAdvSize()
AAdd( aObjects, { 100, 100, .T., .T. } )

aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T.)

DWR->(DbSetOrder(1))
If DWR->(DbSeek(xFilial("DWR")+M->AAM_CODCLI+M->AAM_LOJA))

	Aadd(aButtons, {'PARAMETROS',	{||TMSVisHCli()},STR0070,STR0071 }) // "Hist. Reajuste Cliente", "His.Reaj.Cli"

	DEFINE MSDIALOG oDlg TITLE STR0072 FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL STYLE WS_DLGFRAME            // 'Historico de Reajuste de Clientes'

	TMSFillGetDados(2, "DWR", 1, xFilial("DWR") + M->AAM_CODCLI + M->AAM_LOJA, { || DWR->DWR_FILIAL + DWR->DWR_CODCLI + DWR->DWR_LOJCLI }, { || .T. }, aNoFields, aYesFields)
	oGet := MSGetDados():New(aPosObj[1,1], aPosObj[1,2], aPosObj[1,3], aPosObj[1,4],2,'AllWaysTrue','AllWaysTrue',,.F.,,,,,,,,)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| oDlg:End() },{|| oDlg:End() },, aButtons )

EndIf

RestInter()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSVisHCli³ Autor ³Eduardo de Souza       ³ Data ³ 09/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Historico de Reajuste de Clientes                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ TMSVisHCli()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TECA250 - Somente se tiver Integracao com o TMS (Transporte)³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSVisHCli()

Local oGet
Local oDlg
Local aSize      := {}
Local aInfo      := {}
Local aObjects   := {}
Local aPosObj    := {}
Local aNoFields  := {}
Local aYesFields := {}
Local aButtons   := {}
Local cNumIde    := aCols[n,GDFieldPos('DWR_NUMIDE')]
Local lDWR       := .F.
Local lDWS       := .F.

SaveInter()

Private aHeader := {}
Private aCols   := {}
Private aTela[0][0]
Private aGets[0]

DWR->(DbSetOrder(3))
If DWR->(DbSeek(xFilial("DWR")+cNumIde))
	lDWR := .T.
	DWS->(DbSetOrder(1))
	If DWS->(DbSeek(xFilial("DWS")+DWR->DWR_NUMIDE))
		lDWS := .T.
	EndIf
EndIf

//-- Dimensoes padroes
aSize   := MsAdvSize()
If lDWS
	AAdd( aObjects, { 100, 050, .T., .T. } )
	AAdd( aObjects, { 100, 050, .T., .T. } )
Else
	AAdd( aObjects, { 100, 100, .T., .T. } )
EndIf
aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T.)

If lDWR
	RegToMemory("DWR",.F.)

	DEFINE MSDIALOG oDlg TITLE STR0072 FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL STYLE WS_DLGFRAME

	oEnch := MsMGet():New('DWR',DWR->(Recno()),2,,,,,aPosObj[1],,3,,,,,,.T.)
	If lDWS
		TMSFillGetDados(2, "DWS", 1, xFilial("DWS") + cNumIde, { || DWS->DWS_FILIAL + DWS->DWS_NUMIDE }, { || .T. }, aNoFields, aYesFields)
		oGet := MSGetDados():New(aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4],2,'AllWaysTrue','AllWaysTrue',,.F.,,,,,,,,)
	EndIf

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| oDlg:End() },{|| oDlg:End() } )

EndIf

RestInter()

Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Teca250bLi³ Autor ³Wellington A Santos    ³ Data ³06.11.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna os campos a serem exibidos na tela                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nExpN1 - Posicao do Array na chamada da funcao              ³±±
±±³          ³aExpA2 - Array com os campos do ListBox                     ³±±
±±³          ³aExpA3 - Array com o cabecalho a ser exibido                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tm500BLin                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Teca250bLi(nAt,aList)

Local abLine  := {}
Local nCont   := 0

If nAt > Len(aList)
	Return abLine
EndIf

For nCont := 1 To Len(aList[nAT])
	Aadd( abLine, aList[nAT,nCont])
Next nCont

Return abLine
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AT250Gat  ³ Autor ³Fernando Ribeiro       ³ Data ³ 04.07.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para Retornar a Descricao do Grupo de Regioes       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AT250Gat(cCodigo)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCodigo = Codigo do Grupo de Regioes                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TECA250                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function AT250Gat(cCodigo)

Local cDescri	:= ""
cDescri := Posicione("DUY", 1, xFilial("DUY") + cCodigo, "DUY_DESCRI")

Return cDescri



/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AT250Pesq ³ Autor ³Fernando Ribeiro       ³ Data ³ 04.07.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para pesquisa do Ajuste de Frete                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AT250Pesq(aCabec,aAjustes,nPosicao)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aCabec = Array contendo o cabecalho da TWBrowse            ³±±
±±³          ³ aAjustes = Array contendo os conteudo da TWBrowse          ³±±
±±³          ³ nPosicao = Posicao atual da TWBrowse                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TECA250                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AT250Pesq(aCabec, aAjustes, nPosicao)

Local oDlg		:= Nil
Local cGetCORI	:= Space(TamSX3("DVC_CDRORI")[1])
Local oGetCORI	:= Nil
Local cGetDORI	:= Space(TamSX3("DVC_REGORI")[1])
Local oGetDORI	:= Nil
Local cGetCDES	:= Space(TamSX3("DVC_CDRDES")[1])
Local oGetCDES	:= Nil
Local cGetDDES	:= Space(TamSX3("DVC_REGDES")[1])
Local oGetDDES	:= Nil
Local nOpca		:= 0
Local nPosVet  	:= nPosicao

DEFINE MSDIALOG oDlg FROM 5, 5 TO 14, 50 TITLE STR0065

@ 0.4,1.2 Say aCabec[1] Size 120,20 COLOR CLR_BLACK OF oDlg 
@ 1.1,1.2 MsGet oGetCORI Var cGetCORI F3 "DUY" Valid(cGetDORI := AT250Gat(cGetCOri)) Size 40,10 COLOR CLR_BLACK Picture "@!" OF oDlg

@ 0.4,7.8 Say aCabec[2] Size 120,20 COLOR CLR_BLACK OF oDlg
@ 1.1,7.8 MsGet oGetDORI Var cGetDORI Size 115,10 COLOR CLR_BLACK Picture "@!" OF oDlg When .F.

@ 2.2,1.2 Say aCabec[3] Size 120,20 COLOR CLR_BLACK OF oDlg 
@ 2.9,1.2 MsGet oGetCDES Var cGetCDES F3 "DUY" Valid(cGetDDes := AT250Gat(cGetCDes)) Size 40,10 COLOR CLR_BLACK Picture "@!" OF oDlg 

@ 2.2,7.8 Say aCabec[4] Size 120,20 COLOR CLR_BLACK OF oDlg
@ 2.9,7.8 MsGet oGetDDES Var cGetDDES Size 115,10 COLOR CLR_BLACK Picture "@!" OF oDlg When .F.

DEFINE SBUTTON FROM 054,122	TYPE 1 ACTION (nOpca := 1,oDlg:End()) ENABLE OF oDlg
DEFINE SBUTTON FROM 054,149.1 TYPE 2 ACTION (oDlg  :End()) ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTERED

If nOpca == 1
	nPosVet := aScan(aAjustes, { |x| x[1] == cGetCORI .AND. x[3] == cGetCDES } )
	If (nPosVet == 0)
		Help(" ",1,"PESQ01")
		nPosVet := nPosicao
	EndIf
EndIf
lRefresh := .T.

Return nPosVet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AT250Doc  ³ Autor ³Katia                  ³ Data ³ 24.09.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Função para verificar se existe CTRC utilizando o Servico  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AT250Doc()                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AT250Doc(cServic,cCodNeg)

Local cAliasTop:= ''
Local lRet     := .T.
Local aAreaAnt := GetArea()
Local lTabDDH  := AliasIndic("DDH")

Default cCodNeg := ""

If Type("Altera") != "U" .And. Altera .And. Type("M->AAM_CONTRT") == "U"
	RegToMemory("AAM",.F.)
EndIf
	
cAliasTop :=GetNextAlias()
cQuery := " SELECT COUNT(1) NREG FROM " + RetSqlName("DT6") + " DT6 "
cQuery += " WHERE DT6_FILIAL = '" + xFilial("DT6") + "' "
cQuery += " AND DT6_NCONTR = '"   + M->AAM_CONTRT  + "' "
If lTMSItCt .And. !Empty(cCodNeg)
	cQuery += " AND DT6_CODNEG = '" + cCodNeg + "' "
EndIf
If !Empty(cServic)
	cQuery += " AND DT6_SERVIC = '" + cServic + "' "
EndIf
//-- Se for exclusivo por Filial
If !Empty(M->AAM_FILIAL) .And. Len(AllTrim(M->AAM_FILIAL)) == Len(AllTrim(cFilAnt))
	cQuery += " AND DT6_FILDOC = '" + M->AAM_FILIAL + "' "
EndIf
cQuery += " AND DT6_CLIDEV = '" + M->AAM_CODCLI + "' "
cQuery += " AND DT6_LOJDEV = '" + M->AAM_LOJA + "' "
cQuery += " AND D_E_L_E_T_   = ' ' "
cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasTop,.F.,.T.)
If !(cAliasTop)->(EOF()) .And. (cAliasTop)->NREG > 0
	lRet:= .F.
EndIf
(cAliasTop)->( DbCloseArea() )

//--- Agendamento
If lTMSItCt
	If lRet 
		cAliasTop :=GetNextAlias()
		cQuery := " SELECT COUNT(1) NREG FROM " + RetSqlName("DF1") + " DF1 "
		cQuery += " WHERE DF1_FILIAL = '" + xFilial("DF1") + "' "
		cQuery += " AND DF1_NCONTR = '"   + M->AAM_CONTRT  + "' "
		If !Empty(cCodNeg)
			cQuery += " AND DF1_CODNEG = '" + cCodNeg + "' "
		EndIf
		If !Empty(cServic)
			If DF1->(ColumnPos("DF1_SRVCOL")) > 0
				cQuery += " AND (DF1_SERVIC = '" + cServic + "' OR DF1_SRVCOL = '" + cServic + "') "
			Else
				cQuery += " AND DF1_SERVIC = '" + cServic + "' "
			EndIf
		EndIf
		cQuery += " AND DF1_CLIDEV = '" + M->AAM_CODCLI + "' "
		cQuery += " AND DF1_LOJDEV = '" + M->AAM_LOJA + "' "
		cQuery += " AND D_E_L_E_T_   = ' ' "
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasTop,.F.,.T.)
		If !(cAliasTop)->(EOF()) .And. (cAliasTop)->NREG > 0
			lRet:= .F.
		EndIf
		(cAliasTop)->( DbCloseArea() )
	EndIf
	
	//--- Solicitação de Coleta
	If lRet
		cAliasTop :=GetNextAlias()
		cQuery := " SELECT COUNT(1) NREG FROM " + RetSqlName("DT5") + " DT5 "
		cQuery += " WHERE DT5_FILIAL = '" + xFilial("DT5") + "' "
		cQuery += " AND DT5_NCONTR = '"   + M->AAM_CONTRT  + "' "
		If !Empty(cCodNeg)
			cQuery += " AND DT5_CODNEG = '" + cCodNeg + "' "
		EndIf
		If !Empty(cServic)
			If DT5->(ColumnPos("DT5_SRVENT")) > 0
				cQuery += " AND (DT5_SERVIC = '" + cServic + "' OR DT5_SRVENT = '" + cServic + "') "
			Else
				cQuery += " AND DT5_SERVIC = '" + cServic + "' "
			EndIf
		EndIf
		cQuery += " AND DT5_CLIDEV = '" + M->AAM_CODCLI + "' "
		cQuery += " AND DT5_LOJDEV = '" + M->AAM_LOJA + "' "
		cQuery += " AND D_E_L_E_T_   = ' ' "
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasTop,.F.,.T.)
		If !(cAliasTop)->(EOF()) .And. (cAliasTop)->NREG > 0
			lRet:= .F.
		EndIf
		(cAliasTop)->( DbCloseArea() )
	EndIf
	
	//-- Cotação de Frete
	If lRet
		cAliasTop :=GetNextAlias()
		cQuery := " SELECT COUNT(1) NREG FROM " + RetSqlName("DT4") + " DT4 "
		cQuery += " WHERE DT4_FILIAL = '" + xFilial("DT4") + "' "
		cQuery += " AND DT4_NCONTR = '"   + M->AAM_CONTRT  + "' "
		If !Empty(cCodNeg)
			cQuery += " AND DT4_CODNEG = '" + cCodNeg + "' "
		EndIf
		If !Empty(cServic)
			cQuery += " AND DT4_SERVIC = '" + cServic + "' "
		EndIf
		cQuery += " AND DT4_CLIDEV = '" + M->AAM_CODCLI + "' "
		cQuery += " AND DT4_LOJDEV = '" + M->AAM_LOJA + "' "
		cQuery += " AND D_E_L_E_T_   = ' ' "
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasTop,.F.,.T.)
		If !(cAliasTop)->(EOF()) .And. (cAliasTop)->NREG > 0
			lRet:= .F.
		EndIf
		(cAliasTop)->( DbCloseArea() )
	EndIf
EndIf	
RestArea(aAreaAnt)
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AT250Vig  ³ Autor ³Raspa                  ³ Data ³ 20.Abr.10³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consiste a data de vigencia informada X Contratos existen_ ³±±
±±³          ³ tes p/ o cliente                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AT250Vig(cContrat)
Local lRet       := .T.
Local cQuery     := ''
Local cAliasQry  := ''
Local nI,nOld,cReadOld
Local oModel     := FWModelActive()
Local lFim       := .F.
Local cAbrang    := ""

Default cContrat := ''

cQuery := "SELECT AAM.AAM_CONTRT, AAM.AAM_ABRANG "
cQuery += "FROM " + RetSQLTab('AAM')
cQuery += "WHERE AAM.AAM_FILIAL = '" + xFilial('AAM') + "' AND "
cQuery += "      AAM.AAM_CODCLI = '" + M->AAM_CODCLI + "' AND "


If M->AAM_ABRANG == "1" //--Abrangencia: 1=Cliente/Loja
	cQuery += "      AAM.AAM_LOJA   = '" + M->AAM_LOJA + "' AND "
EndIf

If M->AAM_TIPFRE = '1' //-- CIF
	cQuery	+= " AAM.AAM_TIPFRE IN ('1','3') AND "
ElseIf M->AAM_TIPFRE == '2' //-- FOB
	cQuery	+= " AAM.AAM_TIPFRE IN ('2','3') AND "
ElseIf M->AAM_TIPFRE == '3' //-- CIF/FOB
	cQuery	+= " AAM.AAM_TIPFRE IN ('1','2','3') AND "
EndIf

cQuery += "      AAM.AAM_CONTRT <> '" + M->AAM_CONTRT + "' AND "
cQuery += "      AAM.AAM_STATUS IN ('" + StrZero(1, Len(AAM->AAM_STATUS)) + "','" + StrZero(2, Len(AAM->AAM_STATUS)) + "') AND " //--Status: 1=Ativo | 2=Suspenso

//--Tipo Contrato:
//--1=Vitalicio | 2=Tempo Determ.
If M->AAM_TPCONT == "1"
	//--Novo cadastro: Contrato Vitalicio
	//--Verifica se existe algum contato vitalicio cujo inicio da vigiencia
	//--eh inferior a data de inicio informada ou se existe algum contrato
	//--cuja vigencia eh posterior a data de inicio informada.
	cQuery += "      ( (AAM.AAM_INIVIG <= '" + DtoS(M->AAM_INIVIG) + "' AND AAM.AAM_FIMVIG = ' ') OR "
	cQuery += "        (AAM.AAM_INIVIG >= '" + DtoS(M->AAM_INIVIG) + "') ) AND

ElseIf M->AAM_TPCONT == "2" 
	//--Novo cadastro: Contrato p/ tempo determinado
	//-- 1o) Verifica se a data de inicio informada nao coincide com a data
	//--     de inicio/fim de outro contrato; 
	//-- 2o) Verifica se a data de termino informada nao coincide com a data
	//--     de inicio fim de outro contrato;
	//-- 3o) Verifica se existe algum contrato vitalicio a partir da data de
	//--     inicio informada
	cQuery += "      ( ('" + DtoS(M->AAM_INIVIG) + "' BETWEEN AAM.AAM_INIVIG AND AAM.AAM_FIMVIG) OR
	cQuery += "        ('" + DtoS(M->AAM_FIMVIG) + "' BETWEEN AAM.AAM_INIVIG AND AAM.AAM_FIMVIG) OR
	cQuery += "        (AAM.AAM_INIVIG BETWEEN '" + DtoS(M->AAM_INIVIG) + "' AND '" + DtoS(M->AAM_FIMVIG) + "') OR "
	cQuery += "        (AAM.AAM_FIMVIG BETWEEN '" + DtoS(M->AAM_INIVIG) + "' AND '" + DtoS(M->AAM_FIMVIG) + "') OR "
	cQuery += "        ('" + DtoS(M->AAM_INIVIG) + "' >= AAM.AAM_INIVIG AND AAM.AAM_FIMVIG = ' ' ) OR "
	cQuery += "        (AAM.AAM_TPCONT = '1' AND AAM.AAM_STATUS = '1' ) ) AND "     //-- Se exitir algum contrato vitalicio ativo deve-se encerrá-lo primeiro.

	If !M->AAM_FIMVIG <= DATE()
		lFim := .T.
	EndIf

EndIf
cQuery += "      AAM.D_E_L_E_T_ = ' '"

//--Processamento da Query:
cQuery    := ChangeQuery(cQuery)
cAliasQry := GetNextAlias()
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T. )

cContrat := (cAliasQry)->AAM_CONTRT 
cAbrang  := (cAliasQry)->AAM_ABRANG

(cAliasQry)->(DbCloseArea())

//+--------------------------------------------------
//| SE RETORNOU CONTRATO AVISA O USUÁRIO |
//+--------------------------------------------------
If  !lFim
	If !Empty(cContrat) .And. (M->AAM_ABRANG == cAbrang)
	    Return .T.
	EndIf
EndIf

Return .F.


//-------------------------------------------------------------------
/*/{Protheus.doc} AT250Vig2
                  Validação da Vigência do Contrato.
@author 

@since 15/07/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AT250Vig2()
Local lRet       := .T.
Local cQuery     := ''
Local cAliasQry  := ''
Local nI,nOld,cReadOld
Local oModel   := FWModelActive()  
//-- Se não encontrou outro contrato na vigencia, valida se no grid a vigência está correta.

	If IntTMS() .And. nModulo == 43 .And. lTMSItCt
		nOld 	  := oModel:GetModel( "MdGridIDDC" ):GetLine()
		cReadOld  := ReadVar()
		For nI := 1 To oModel:GetModel( "MdGridIDDC" ):Length()
			
			//-- Posiciona Na Linha Do Loop
			oModel:GetModel( "MdGridIDDC" ):GoLine( nI )

			If !oModel:GetModel( "MdGridIDDC" ):IsDeleted()
				__ReadVar := "M->DDC_INIVIG"
				M->DDC_INIVIG := oModel:GetModel( "MdGridIDDC" ):GetValue( "DDC_INIVIG" )
				If !At250Val()
					lRet := .F.
					Exit
				EndIf				

				__ReadVar := "M->DDC_FIMVIG"
				M->DDC_FIMVIG := oModel:GetModel( "MdGridIDDC" ):GetValue( "DDC_FIMVIG" )
				If dDataBase > M->DDC_FIMVIG  .And. oModel:GetModel( "MdGridIDDC" ):GetValue( "DDC_TPCONT" ) <> StrZero(1, Len(DDC->DDC_TPCONT))   //--Altera o Status da negociação
					oModel:GetModel( "MdGridIDDC" ):SetValue("DDC_STATUS",StrZero(3, Len(DDC->DDC_STATUS)))//--Status Encerrado
				EndIf
				If !At250Val()
					lRet := .F.
					Exit
				EndIf				
			EndIf
		Next nI
		oModel:GetModel( "MdGridIDDC" ):GoLine( nOld )
		__ReadVar := cReadOld
	EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³At250AtCrt³ Autor ³ Vendas CRM            ³ Data ³16/12/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Não permite ativacao do contrato cancelado.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpL1 := At200AtCtr()                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpL1 -> Validacao                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TECA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function At250AtCrt()

Local cConteudo	:= &(ReadVar())  	// Variavel corrente que esta sendo editada.
Local lRet	:= .T.					// Retorno da validacao. 
 	
If Altera
	
	Do Case 
	
		Case ( AAM->AAM_STATUS == '4' .AND. cConteudo == '1' )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³	 Problema: Não será possível ativar um contrato cancelado. ³	
			//³	 Solucao: Inclua um novo contrato.                    	   ³	
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Help("",1,"CONTRCAN")
			lRet := .F.
		
		Case ( AAM->AAM_STATUS == '4' .AND. cConteudo <> '4' )
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³	 Problema: Não será possível alterar o status de um contrato cancelado. ³	
			//³	 Solucao: Inclua um novo contrato.									    ³	
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Help("",1,"STSCONTR") 	
			lRet := .F.	         
		
	EndCase	
															
EndIf		 

Return ( lRet )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef - Modelo de Dados

@author Jefferson Lima  

@since Dez/2015
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ModelDef()

Local oModel	:= Nil
Local oStruCAAM := Nil
Local oStruIAAN := Nil
Local oStruIAAO := Nil
Local oStruIDT9 := Nil
Local oStruIDUX := Nil
Local oStruIDDA := Nil
Local oStruIDDC := Nil
Local oStruIDDP := Nil

// Validacoes do Modelo
Local bPosValid 	:= { |oModel| PosVldMdl(oModel) }

// Validacoes da Grid
Local bPreAAM       := { |oModel,cAction,cIdCampo,xValue| PreVldAAM(oModel,cAction,cIdCampo,xValue) }
Local bLnPostAAN	:= { |oModel| PosVldLine(oModel,"AAN") }
Local bLnPostAAO	:= { |oModel| PosVldLine(oModel,"AAO") }
Local bLnPostDUX	:= { |oModel| PosVldLine(oModel,"DUX") }
Local bLnPostDDA	:= { |oModel| PosVldLine(oModel,"DDA") }
Local bLnPostDDC	:= { |oModel| PosVldLine(oModel,"DDC") }
Local bLnPreDUX     := { |oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue| PreVldLine(oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue)}
Local bLnPreDDC     := { |oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue| PreVldLine(oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue)}
Local bLnPreDDA     := { |oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue| PreVldLine(oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue)}
Local bLnPreDT9     := { |oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue| PreVldLine(oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue)}
Local bLnPreDDP     := { |oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue| PreVldLine(oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue)}
Local bLnPostDDP	:= Nil 
Local bLnPostDDH	:= Nil
Local lTabDDH		:= AliasIndic("DDH")
Local aPECpos		:= {}
Local aMemoAAM := { { 'AAM_CODMEM' , 'AAM_MEMO' } }

oStruCAAM := FwFormStruct( 1, "AAM")
oStruIAAN := FwFormStruct( 1, "AAN")
oStruIAAO := FwFormStruct( 1, "AAO")
oStruIDT9 := FwFormStruct( 1, "DT9")
oStruIDUX := FwFormStruct( 1, "DUX")
oStruIDDA := FwFormStruct( 1, "DDA")
oStruIDDC := FwFormStruct( 1, "DDC")
oStruIDDP := Iif(lTabDDP, FwFormStruct( 1, "DDP"), Nil)
oStruIDDH := Iif(lTabDDH, FwFormStruct( 1, "DDH"), Nil)

bLnPostDDP	:= Iif(lTabDDP,{ |oModel| PosVldLine(oModel,"DDP") },Nil)  
bLnPostDDH	:= Iif(lTabDDH,{ |oModel| PosVldLine(oModel,"DDH") },Nil)

oModel := MPFormModel():New( "TECA250",, bPosValid , {|oModel| CommitMdl(oModel) }, { |oModel| CancelMdl(oModel) } )
oModel:SetDescription(STR0001) 	//-- 

//-- CabeÃ§alho do Contrato
oModel:AddFields( "MdFieldCAAM", /*cOwner*/, oStruCAAM,bPreAAM,,/*bLoad*/ )

oModel:SetPrimaryKey( {"AAM_FILIAL", "AAM_CONTRT"} )

//-- Parceiros
oModel:AddGrid("MdGridIAAN", "MdFieldCAAM" /*cOwner*/, oStruIAAN , /*bLinePre*/ , bLnPostAAN /*bLinePost*/ , /*bPre*/ , /*bPost*/,  /*bLoad*/)
oModel:SetRelation( "MdGridIAAN", {	{"AAN_FILIAL","xFilial('AAN')"  },;
										{"AAN_CONTRT","AAM_CONTRT"}}, AAN->( IndexKey( 1 ) ) )

If nModulo <> 28									
	oModel:SetOptional( "MdGridIAAN", .T. )
EndIf

oStruIAAO:SetProperty("AAO_CONTRT",MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,"FwFldGet('AAM_CONTRT')"))

//-- WMS
oModel:AddGrid("MdGridIAAO", "MdFieldCAAM" /*cOwner*/, oStruIAAO , /*bLinePre*/ , bLnPostAAO /*bLinePost*/ , /*bPre*/ , /*bPost*/,  /*bLoad*/)
oModel:SetRelation( "MdGridIAAO", {	{"AAO_FILIAL","xFilial('AAO')"  }, ;
										{"AAO_CONTRT","AAM_CONTRT"}}, AAO->( IndexKey( 1 ) ) )

oModel:GetModel( "MdGridIAAO" ):SetUniqueLine( { "AAO_CODPRO", "AAO_SERVIC", "AAO_TAREFA", "AAO_ATIVID" } )
oModel:GetModel( "MdGridIAAO" ):SetUseOldGrid(.T.)
oModel:SetOptional( "MdGridIAAO", .T. )

//-- Ponto de entrada para indicar campos de usuario/cliente para permitir alteracao se contrato possue CTRC.
If ExistBlock( "AT250CPO" )
	aPECpos := ExecBlock( "AT250CPO", .F., .F. )
	If ValType( aPECpos ) <> "A"
		aPECpos := {}
	EndIf
EndIf

//-- Prepara campo virtual para gravação pela estrutura AAM
FWMemoVirtual( oStruCAAM, aMemoAAM )

//-- TMS - 
If IntTms() .And. nModulo == 43
	If !lTMSItCt
		If Altera .And. !AT250Doc()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se existir CTRC utilizando o Contrato, nao permite alterar as linhas ja'   ³
			//³existentes da Getdados. Permite apenas, a inclusao de novas linhas.        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AT250Stru("DUX",oStruIDUX,aPECpos)
			AT250Stru("DT9",oStruIDT9,aPECpos)
			//-- Percentual Fixo de Rateio
			If lTabDDP
				AT250Stru("DDP",oStruIDDP,aPECpos)
			EndIf
		EndIf

		//-- Serviço de Negociação
		oModel:AddGrid("MdGridIDUX", "MdFieldCAAM" /*cOwner*/, oStruIDUX , bLnPreDUX/*bLinePre*/ , bLnPostDUX /*bLinePost*/ , /*bPre*/ , /*bPost*/,  /*bLoad*/)
		oModel:SetRelation( "MdGridIDUX", {	{"DUX_FILIAL","xFilial('DUX')"  }, ;
												{"DUX_NCONTR","AAM_CONTRT"}}, DUX->( IndexKey( 1 ) ) )
	
		oModel:GetModel( "MdGridIDUX" ):SetUniqueLine( { "DUX_SERVIC" } )		
		oModel:GetModel( "MdGridIDUX" ):SetUseOldGrid(.T.)
		If nModulo <> 43									
			oModel:SetOptional( "MdGridIDUX", .T. )
		EndIf
		
		//-- Componentes do Serviço
		oModel:AddGrid("MdGridIDT9", "MdGridIDUX" /*cOwner*/, oStruIDT9 , bLnPreDT9/*bLinePre*/ , {|| PosVldLDT9() } /*bLinePost*/ , /*bPre*/ , /*bPost*/,  /*bLoad*/)
		oModel:SetRelation( "MdGridIDT9", {	{"DT9_FILIAL","xFilial('DT9')"  }, ;
												{"DT9_NCONTR","AAM_CONTRT"}, ;
												{"DT9_SERVIC","DUX_SERVIC"}}, DT9->( IndexKey( 1 ) ) )
		
		oModel:GetModel( "MdGridIDT9" ):SetUniqueLine( { "DT9_CODPAS" } )	
		oModel:GetModel( "MdGridIDT9" ):SetUseOldGrid(.T.)
		oModel:SetOptional( "MdGridIDT9", .T. )
	
		//-- Percentual Fixo de Rateio
		If lTabDDP
			oModel:AddGrid("MdGridIDDP", "MdGridIDUX" /*cOwner*/, oStruIDDP , bLnPreDDP/*bLinePre*/ , bLnPostDDP  /*bLinePost*/ , /*bPre*/ , /*bPost*/,  /*bLoad*/)
			oModel:SetRelation( "MdGridIDDP", {	{"DDP_FILIAL","xFilial('DDP')"  }, ;
													{"DDP_NCONTR","AAM_CONTRT"}, ;
													{"DDP_SERVIC","DUX_SERVIC"}}, DDP->( IndexKey( 1 ) ) )
			
			oModel:GetModel( "MdGridIDDP" ):SetUniqueLine( { "DDP_CLIDEV","DDP_LOJDEV" } )	
			oModel:GetModel( "MdGridIDDP" ):SetUseOldGrid(.T.)
			oModel:SetOptional( "MdGridIDDP", .T. )
		EndIf	
	Else
		If Altera .And. !AT250Doc()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se existir CTRC utilizando o Contrato, nao permite alterar as linhas ja'   ³
			//³existentes da Getdados. Permite apenas, a inclusao de novas linhas.        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AT250Stru("DDC",oStruIDDC,aPECpos)
			AT250Stru("DDA",oStruIDDA,aPECpos)
			AT250Stru("DT9",oStruIDT9,aPECpos)
			//-- Percentual Fixo de Rateio
			If lTabDDP
				AT250Stru("DDP",oStruIDDP,aPECpos)
			EndIf
		EndIf
				//-- Negociação do Contrato
		oModel:AddGrid("MdGridIDDC", "MdFieldCAAM" /*cOwner*/, oStruIDDC , bLnPreDDC/*bLinePre*/ , bLnPostDDC /*bLinePost*/ , /*bPre*/ , /*bPost*/,  /*bLoad*/)
		oModel:SetRelation( "MdGridIDDC", {	{"DDC_FILIAL","xFilial('DDC')"  }, ;
												{"DDC_NCONTR","AAM_CONTRT"}}, DDC->( IndexKey( 1 ) ) )
	
		oModel:GetModel( "MdGridIDDC" ):SetUniqueLine( { "DDC_CODNEG" } )
		oModel:GetModel( "MdGridIDDC" ):SetUseOldGrid(.T.)
		
		//-- Serviço de Negociação
		oModel:AddGrid("MdGridIDDA", "MdGridIDDC" /*cOwner*/, oStruIDDA , bLnPreDDA/*bLinePre*/ , bLnPostDDA /*bLinePost*/ , /*bPre*/ , /*bPost*/,  /*bLoad*/)
		oModel:SetRelation( "MdGridIDDA", {	{"DDA_FILIAL","xFilial('DDA')"  }, ;
												{"DDA_NCONTR","AAM_CONTRT"}, ;
												{"DDA_CODNEG","DDC_CODNEG"}}, DDA->( IndexKey( 1 ) ) )
	
		oModel:GetModel( "MdGridIDDA" ):SetUniqueLine( { "DDA_SERVIC" } )
		oModel:GetModel( "MdGridIDDA" ):SetUseOldGrid(.T.)
	
		//-- Componentes do Serviço
		oModel:AddGrid("MdGridIDT9", "MdGridIDDA" /*cOwner*/, oStruIDT9 , bLnPreDT9/*bLinePre*/ , {|| PosVldLDT9() }/*bLinePost*/ , /*bPre*/ , /*bPost*/,  /*bLoad*/)
		oModel:SetRelation( "MdGridIDT9", {	{"DT9_FILIAL","xFilial('DT9')"  }, ;
												{"DT9_NCONTR","AAM_CONTRT"}, ;
												{"DT9_CODNEG","DDC_CODNEG"}, ;
												{"DT9_SERVIC","DDA_SERVIC"}}, DT9->( IndexKey( 1 ) ) )
		
		oModel:GetModel( "MdGridIDT9" ):SetUniqueLine( { "DT9_CODPAS" } )	
		oModel:GetModel( "MdGridIDT9" ):SetUseOldGrid(.T.)
		oModel:SetOptional( "MdGridIDT9", .T. )

		//-- Tabela de Frete a Pagar
		If lTabDDH
			oModel:AddGrid("MdGridIDDH", "MdGridIDDA" /*cOwner*/, oStruIDDH , /*bLinePre*/ , bLnPostDDH /*bLinePost*/ , /*bPre*/ , /*bPost*/,  /*bLoad*/)
			oModel:SetRelation( "MdGridIDDH", {	{"DDH_FILIAL","xFilial('DDH')"  }, ;
													{"DDH_NCONTR","AAM_CONTRT"}, ;
													{"DDH_CODNEG","DDC_CODNEG"}, ;
													{"DDH_SERVIC","DDA_SERVIC"}}, DDH->( IndexKey( 1 ) ) )
			
			oModel:GetModel( "MdGridIDDH" ):SetUniqueLine( { "DDH_FROVEI" } )	
			oModel:GetModel( "MdGridIDDH" ):SetUseOldGrid(.T.)
			oModel:SetOptional( "MdGridIDDH", .T. )
			
		EndIf
		
		//-- Percentual Fixo de Rateio
		If lTabDDP
			oModel:AddGrid("MdGridIDDP", "MdGridIDDA" /*cOwner*/, oStruIDDP , bLnPreDDP/*bLinePre*/ , bLnPostDDP /*bLinePost*/ , /*bPre*/ , /*bPost*/,  /*bLoad*/)
			oModel:SetRelation( "MdGridIDDP", {	{"DDP_FILIAL","xFilial('DT9')"  }, ;
													{"DDP_NCONTR","AAM_CONTRT"}, ;
													{"DDP_CODNEG","DDC_CODNEG"}, ;
													{"DDP_SERVIC","DDA_SERVIC"}}, DDP->( IndexKey( 1 ) ) )
			
			oModel:GetModel( "MdGridIDDP" ):SetUniqueLine( { "DDP_CLIDEV","DDP_LOJDEV" } )	
			oModel:GetModel( "MdGridIDDP" ):SetUseOldGrid(.T.)
			oModel:SetOptional( "MdGridIDDP", .T. )
		EndIf
	EndIf
EndIf
oModel:SetVldActivate( { | oModel | VldActiv( oModel ) } )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} CancelMdl
Realiza o cancelamento do Modelo

@author Valdemar Roberto  

@since Dez/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CancelMdl(oModel)

Local lRet := .T.
Local nOpc := oModel:GetOperation()

If ExistBlock("AT250CAN")
	ExecBlock("AT250CAN",.F.,.F.,{nOpc})
EndIf
		
Return(lRet)

/*/{Protheus.doc} AjustaCab
//TODO Ajusta cabeçalho da AAM com data fim
@author caio.y
@since 23/06/2017
@version undefined
@param aCab, array, descricao
@type function
/*/
Static Function AjustaCab(aCab)
Local nCount	:= 1
Local nPos		:= 1 
Local aRet		:= {}
Local nLen		:= 0 

Default aCab	:= {} 

nPos	:= Ascan(aCab,{ | x | x[1] == "AAM_TPCONT" }) 

If nPos > 0 
	If aCab[nPos,2] == "1" //-- Vitalicio
		
		nPos	:= Ascan(aCab,{ | x | x[1] == "AAM_FIMVIG" }) 
		
		If nPos > 0 
			nLen	:= Len(aCab)
			
			ADel( aCab, nPos )
			ASize( aCab, nLen - 1 )
		
		EndIf
		
	EndIf
EndIf

aRet	:= aClone(aCab)

Return aRet

/*/{Protheus.doc} CommitMdl
//Bloco de gravação do modelo
@author caio.y
@since 22/06/2017
@version undefined
@param oModel, object, modelo de dados
@type function
/*/
Static Function CommitMdl(oModel)
Local lRet		:= .T. 
Local nOpc		:= 3 
Local oModelAAM	:= Nil

Default oModel	:= FwModelActive()

nOpc	:= oModel:GetOperation()

If nOpc == 3 	
	oModelAAM	:= oModel:GetModel("MdFieldCAAM")
	
	If oModelAAM:GetValue("AAM_TPCONT") == "1" //-- Vitalicio
		oModelAAM:LoadValue("AAM_FIMVIG",CToD(""))
	EndIf	
EndIf

lRet	:= FwFormCommit(oModel)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PosVldMdl
Pós Validação do Model - Antigo Tudo OK

@author Jefferson Lima  

@since Dez/2015
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function PosVldMdl( oModel )

Local lRet		  := .T.
Local aAreaAnt	  := GetArea()
Local nCntFor	  := 0
Local nCount      := 0

Local nDel        := 0
Local nLoop       := 0
Local nLoop1      := 0
Local n1Cpo       := 0
Local n2Cpo       := 0
Local nLinCount   := 0
Local cAliasQry   := GetNextAlias()

//-- Verificacoes do Portal
Local aSrvTransp  := {}
Local cSerTMS     := ""
Local cTipTra     := ""
Local cPorTMS     := ""

Local nOpcx		  := oModel:GetOperation()
Local lRatFix	  := .F.
Local nTotPer	  := 0

Local cMsgFix     := ""

//-- Objetos Para Validação Em MVC
Local oView       := FWViewActive()  
Local oMdGridDDA  := oModel:GetModel( "MdGridIDDA" )
Local oMdGridDDC  := oModel:GetModel( "MdGridIDDC" )
Local aSaveLine   := FWSaveRows()
Local cCodNeg     := ""
Local cServic     := ""
Local aMsgErr     := {}
Local cMsgErr     := ""
Local nI          := 0
Local nJ          := 0
Local cMsgInfo    := ""
Local cMsgInfDDC  := "" 
Local oModelAAM	  := Nil

//Verifica se tem pedido de venda gerado para o contrato de serviço.
If nOpcx == MODEL_OPERATION_DELETE
	lRet := !Empty(AAN->AAN_ULTPED)
	If !lRet
		Help(,, "At250Ped",,STR0112,1,0,,,,,,{STR0113}) // Existem Pedidos de Venda criados para esse contrato...##Exclua o pedido para continuar o processo
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se existir Documentos do TMS utilizando o Contrato, nao permite excluir o mesmo  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .And. nOpcx == MODEL_OPERATION_DELETE .And. IntTMS()
	lRet := AT250Doc()
	If !lRet
		Help('',1,'AT250NODEL') // Existem Documentos utilizando este Contrato ...
	Else
		lRet := TecA250Chk('1')
	EndIf
EndIf

If	nOpcx == MODEL_OPERATION_INSERT .OR. nOpcx == MODEL_OPERATION_UPDATE		// Incluir ou Alterar

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se o Tp. de Contrato for igual a "Determinado", o campo AAM_FIMVIG           ³
	//³ (Final Vigencia Contrato) tem que ser informado.                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If M->AAM_TPCONT =="2" .AND. Empty(M->AAM_FIMVIG)
		Help( " ", 1, "OBRIGAT2", , RetTitle( "AAM_FIMVIG" ), 4, 1 )
		lRet := .F.
	EndIf
    
	//--Consiste se houve alteracao
	//--no Status do contrato.
	//--Status do Contrato: 
	//--1=Ativo | 2=Suspenso | 3=Encerrado
	If lRet .And. nOpcx == MODEL_OPERATION_UPDATE
		If AAM->AAM_STATUS <> M->AAM_STATUS
			If ( AAM->AAM_STATUS == StrZero(1,Len(AAM->AAM_STATUS)) .Or. AAM->AAM_STATUS == StrZero(2,Len(AAM->AAM_STATUS)) ) .And. ;
				M->AAM_STATUS == StrZero(3,Len(AAM->AAM_STATUS))

				//--Se o contrato estava "Ativo" ou "Suspenso" e 
				//--foi passado para "Encerrado":
				If Aviso( STR0060, STR0061, { STR0062, STR0063} ) == 1 // "AVISO" ### "Deseja Encerrar o Contrato ?" ### "Sim" ### "Nao"
					M->AAM_STATUS := StrZero(3,Len(AAM->AAM_STATUS)) //-- Encerrado
				Else
					lRet := .F.
				EndIf

			ElseIf AAM->AAM_FIMVIG <= M->AAM_FIMVIG .And. M->AAM_STATUS <> StrZero(1,Len(AAM->AAM_STATUS))

				//--Se o contrato estava "Encerrado" e
				//--foi passado para "Ativo" ou "Suspenso":
				If Aviso( STR0060, STR0064, { STR0062, STR0063} ) == 1 // "AVISO" ### "O Contrato encontra-se encerrado. Deseja ativar o Contrato ?" ### "Sim" ### "Nao"
					If  M->AAM_STATUS == StrZero(2,Len(AAM->AAM_STATUS))
						M->AAM_STATUS := StrZero(2,Len(AAM->AAM_STATUS)) //-- Suspenso
					Else
						M->AAM_STATUS := StrZero(1,Len(AAM->AAM_STATUS)) //-- Ativo
					EndIf
				Else
					lRet := .F.
				EndIf

			ElseIf  M->AAM_STATUS == StrZero(1,Len(AAM->AAM_STATUS)) .And. M->AAM_FIMVIG < dDataBase .And. M->AAM_TPCONT == StrZero(2,Len(AAM->AAM_TPCONT))
				Help( " ", 1, "AT250FIMVIG2", , STR0109 + RetTitle( "AAM_FIMVIG" ) + STR0110 +;
			              RetTitle("AAM_TPCONT") + STR0111, 4, 1 )
				lRet := .F.
			EndIf
			//-- Ajuste do status da negociação (DDC_STATUS)
			If lRet .And. IntTMS() .And. nModulo == 43 .And. FindFunction("TmsVlStAAM")
				TmsVlStAAM(oModel, AAM->AAM_STATUS, M->AAM_STATUS)
			EndIf
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existe outro contrato na mesma data de vigencia para o cliente   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If IntTMS() .And. nModulo == 43
		If AT250Vig()
		    Help("", 1, "AT250VIG")
			lRet := .F.
		Else
		   If !AT250Vig2()  //- valida a vigencia do serviço de negociação e do contrato
		      lRet := .F.
		   Endif
		EndIf

     	//-- Valida se tipo do frete foi informado
	    If Empty(M->AAM_TIPFRE)
	       Help(" ",1, "OBRIGAT2", , RetTitle("AAM_TIPFRE"), 4, 1)
		   lRet := .F.
	    Endif

	EndIf
 
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada na validacao da linha                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	If ExistBlock("AT250TOK")
		lRet := ExecBlock("AT250TOK",.F.,.F.,{nOpcx})
	Endif
Endif

If	lRet

	If IntTMS() .AND. nModulo == 43
		
		If lTMSItCt
			For nLoop1 := 1 To oModel:GetModel( "MdGridIDDC" ):Length()
				oModel:GetModel( "MdGridIDDC" ):GoLine( nLoop1 )
				cMsgInfDDC  := "Ref. a linha " + StrZero(oModel:getModel("MdGridIDDC"):getLine(),3) + " da grid " + oModel:getModel("MdGridIDDC"):getDescription()
				
				If !oModel:GetModel( "MdGridIDDC" ):IsDeleted()
					aSrvTransp := {}
					//-- Valorização Coleta - Testa Preenchimento De Campos
					If DDC->(ColumnPos("DDC_TIPOPE")) > 0 .And. DDC->(ColumnPos("DDC_VALCOL")) > 0
						
						//-- Se DDC_VALCOL <> '0' (Nao Utiliza), Exige Conteúdo No Campo DDC_TIPOPE
						If oModel:GetModel( "MdGridIDDC" ):GetValue( "DDC_VALCOL" ) <> '0'
							If oModel:GetModel( "MdGridIDDC" ):GetValue( "DDC_TIPOPE" ) == '0' //-- Não Utiliza

								Help( " ", 1, "AT250TIPOPE", , "Se o campo " + RetTitle("DDC_VALCOL") + " estiver preenchido com 'SIM' ou 'NÃO', o campo " + RetTitle( "DDC_TIPOPE" ) +;
								                               " não poderá estar com o conteudo '0=não utiliza'. " + chr(13) + cMsgInfDDC , 4, 1 )
								lRet := .F.
								Exit
							EndIf
						EndIf
						
						If oModel:GetModel( "MdGridIDDC" ):GetValue( "DDC_PRORAT" ) == 'D' .And. oModel:GetModel( "MdGridIDDC" ):GetValue( "DDC_VALCOL" ) == '1'  //D-Quantidade de Coletas e 1-Sim
							cMsgInfDDC  := "Ref. a linha " + StrZero(oModel:getModel("MdGridIDDC"):getLine(),3) + " da grid " + oModel:getModel("MdGridIDDC"):getDescription()
							Help( ,1, 'AT250RCOL',,+ chr(13) + chr(13) + cMsgInfDDC, 4, 1) //Para o criterio de Rateio 'D- Quantidade de Coletas', o campo 'Valoriza Coleta Não Realizada' deve ser configurado com a opção 'Não', para que o Rateio seja executado somente para as Coletas realizadas.                                        
							lRet := .F.
							Exit
						EndIf			
					
					EndIf
					
					If lRet
						For nLoop := 1 To oModel:GetModel( "MdGridIDDA" ):Length()
							oModel:GetModel( "MdGridIDDA" ):GoLine( nLoop )
							cMsgInfo := cMsgInfDDC +;
							            " e linha " + StrZero(oModel:getModel("MdGridIDDA"):getLine(),3) + " da grid " + oModel:getModel("MdGridIDDA"):getDescription()
							
							If !oModel:GetModel( "MdGridIDDA" ):IsDeleted()
								lRatFix:= .F.
								If lTabDDP 
									If oModel:GetModel( "MdGridIDDA" ):Getvalue("DDA_PRORAT") == 'A'   //%Fixo
										lRatFix:= .T.
										If !(lRet:= AT250DDP(oModel,@nTotPer))
											cMsgFix:= RetTitle( "DDA_CODNEG" ) + ": " + oModel:GetModel( "MdGridIDDA" ):Getvalue("DDA_CODNEG") + " - " + ;
											          RetTitle( "DDA_SERVIC" ) + ": " + oModel:GetModel( "MdGridIDDA" ):Getvalue("DDA_SERVIC") + " / " + ;
                                                      cMsgInfo
											Exit
										EndIf
										If lRet
											//--- Para o criterio %Fixo, é obrigatorio informar o campo _CRDVDC
											If oModel:GetModel( "MdGridIDDA" ):GetValue( "DDA_CRDVDC" ) == '0' //-- Não Utiliza
												Help( " ", 1, "AT250CRDVDC", , RetTitle( "DDA_CRDVDC" ) + cMsgInfo , 4, 1 )
												lRet := .F.
												Exit
											EndIf
										EndIf
									Else	
										If oModel:GetModel( "MdGridIDDP" ):Length(.T.) >= 1 .And. !oModel:GetModel( "MdGridIDDP" ):IsEmpty()
										    
										    cMsgInfo   := cMsgInfDDC +;
										                  "e linha " + StrZero(oModel:getModel("MdGridIDDP"):getLine(),3) + " da grid " + oModel:getModel("MdGridIDDP"):getDescription()
										    
											Help( " ", 1, "AT250HDDP",, RetTitle("DDA_CODNEG") + " : " + oModel:GetModel( "MdGridIDDA" ):Getvalue("DDA_CODNEG") +;
											      " / "  + RetTitle("DDA_SERVIC") + " : " + oModel:GetModel( "MdGridIDDA" ):Getvalue("DDA_SERVIC") + " " + cMsgInfo ) //Nao é permitido informar Percentual de Negociação para Criterios de Rateio diferente de Fixo (A)  .							
											lRet := .F.
											Exit
										EndIf
									EndIf		
								EndIf
								cSerTMS := Posicione('DC5',1,xFilial('DC5')+oModel:GetModel( "MdGridIDDA" ):GetValue( "DDA_SERVIC" ),'DC5_SERTMS')
									
								If oModel:GetModel( "MdGridIDDA" ):GetValue( "DDA_PORTMS" ) == "1"
									cTipTra := DC5->DC5_TIPTRA
									If Ascan(aSrvTransp,{ | e | e[1]+e[2] == cSerTMS+cTipTra }) > 0
									    cMsgInfo   := cMsgInfDDC +;  
									                 " e linha " + StrZero(oModel:getModel("MdGridIDDA"):getLine(),3) + " da grid " + oModel:getModel("MdGridIDDA"):getDescription()
									    
										Help( " ", 1, "AT250PORTMS" ) //Nao e permitido mais de um servico de negociacao por contrato do mesmo servico e tipo de transporte para ser utilizado no portal TMS
										Help( " ", 1, "AT250PORTMS-B",,cMsgInfo,4,1)
										lRet := .F.
										Exit
									Else
										Aadd(aSrvTransp,{ cSerTms, cTipTra })
									EndIf
								EndIf
								//-- Valorização Coleta - Testa Preenchimento De Campos
								If DDA->(ColumnPos("DDA_TIPOPE")) > 0 .And. DDA->(ColumnPos("DDA_VALCOL")) > 0
									If cSerTMS == StrZero(1, Len(DC5->DC5_SERTMS))   
										//-- Servico de Coleta, exige preenchimento dos campos abaixo
										If oModel:GetModel( "MdGridIDDA" ):GetValue( "DDA_VALCOL" ) == '0' .Or. oModel:GetModel( "MdGridIDDA" ):GetValue( "DDA_TIPOPE" ) == '0' //-- Não Utiliza
											If oModel:GetModel( "MdGridIDDC" ):GetValue( "DDC_VALCOL" ) == '0' .Or. oModel:GetModel( "MdGridIDDC" ):GetValue( "DDC_TIPOPE" ) == '0' //-- Não Utiliza
											    cMsgInfo  := cMsgInfDDC +  " e linha " + StrZero(oModel:getModel("MdGridIDDA"):getLine(),3) + " da grid " + oModel:getModel("MdGridIDDA"):getDescription()
												Help ("",1,"AT250COL", ,"   " +  RetTitle( "DDA_VALCOL" ) + " e " + RetTitle( "DDA_TIPOPE" ) + ". " +;
												                                 " e não podem ter o conteúdo igual a '0-não utiliza'." + chr(13) + cMsgInfo, 4, 1) //Para o Servico de coleta é obrigatorio informar os campos:"  
												lRet := .F.
												Exit
											EndIf
										EndIf	
									EndIf			
								EndIf
								
								If oModel:GetModel( "MdGridIDDA" ):GetValue( "DDA_PRORAT" ) == 'D' .And. oModel:GetModel( "MdGridIDDA" ):GetValue( "DDA_VALCOL" ) == '1'  //D-Quantidade de Coletas e 1-Sim
									cMsgInfo  := cMsgInfDDC +  " e linha " + StrZero(oModel:getModel("MdGridIDDA"):getLine(),3) + " da grid " + oModel:getModel("MdGridIDDA"):getDescription()
									Help( ,1, 'AT250RCOL',,+ chr(13) + chr(13) + cMsgInfo, 4, 1) //Para o criterio de Rateio 'D- Quantidade de Coletas', o campo 'Valoriza Coleta Não Realizada' deve ser configurado com a opção 'Não', para que o Rateio seja executado somente para as Coletas realizadas.                                        
									lRet := .F.
									Exit
								EndIf
										
							EndIf
						Next nLoop
					EndIf
				EndIf	
			Next nLoop1
		Else
			For nLoop:= 1 To oModel:GetModel( "MdGridIDUX" ):Length()
				oModel:GetModel( "MdGridIDUX" ):GoLine( nLoop )
				cMsgInfo   := "Ref. a linha " + StrZero(oModel:getModel("MdGridIDUX"):getLine(),3) + " da grid " + oModel:getModel("MdGridIDUX"):getDescription()
				
				If !oModel:GetModel( "MdGridIDUX" ):IsDeleted()
					lRatFix:= .F.
					If lTabDDP 
						If oModel:GetModel( "MdGridIDUX" ):Getvalue("DUX_PRORAT") == 'A'   //%Fixo
							If	(oModel:GetModel( "MdGridIDDP" ):Length() <= 1 .And. oModel:GetModel( "MdGridIDDP" ):IsEmpty())  .Or. M->AAM_ABRANG <> '2' //Cliente
								lRatFix:= .T.
								If !(lRet:= AT250DDP(oModel,@nTotPer))
									cMsgFix:= RetTitle( "DUX_SERVIC" ) + ": " + oModel:GetModel( "MdGridIDUX" ):Getvalue("DUX_SERVIC")
											
									Exit
								EndIf
							EndIf
						Else	
							If oModel:GetModel( "MdGridIDDP" ):Length(.T.) >= 1 .And. !oModel:GetModel( "MdGridIDDP" ):IsEmpty()
								Help( " ", 1, "AT250HDDP",,RetTitle("DUX_SERVIC") + " : " + oModel:GetModel( "MdGridIDUX" ):Getvalue("DUX_SERVIC") + " " + cMsgInfo) //Nao é permitido informar Percentual de Negociação para Criterios de Rateio diferente de Fixo (A)  .								 
								lRet := .F.
								Exit
							EndIf
						EndIf									
					EndIf
					cSerTMS := Posicione('DC5',1,xFilial('DC5')+oModel:GetModel( "MdGridIDUX" ):GetValue( "DUX_SERVIC" ),'DC5_SERTMS')
					
					If oModel:GetModel( "MdGridIDUX" ):GetValue( "DUX_PORTMS" ) == "1"
						cTipTra := DC5->DC5_TIPTRA
						If Ascan(aSrvTransp,{ | e | e[1]+e[2] == cSerTMS+cTipTra }) > 0
							Help( " ", 1, "AT250PORTMS" ) //Nao e permitido mais de um servico de negociacao por contrato do mesmo servico e tipo de transporte para ser utilizado no portal TMS
							lRet := .F.
							Exit
						Else
							Aadd(aSrvTransp,{ cSerTms, cTipTra })
						EndIf
					EndIf

					//-- Valorização Coleta - Testa Preenchimento De Campos
					If DUX->(ColumnPos("DUX_TIPOPE")) > 0 .And. DUX->(ColumnPos("DUX_VALCOL")) > 0
						If cSerTMS == StrZero(1, Len(DC5->DC5_SERTMS))   
							//-- Servico de Coleta, exige preenchimento dos campos abaixo
							If oModel:GetModel( "MdGridIDUX" ):GetValue( "DUX__VALCOL" ) == '0' .Or. oModel:GetModel( "MdGridIDUX" ):GetValue( "DUX_TIPOPE" ) == '0' //-- Não Utiliza
								Help ("",1,"AT250COL", ,  RetTitle( "DUX_VALCOL" ) + " e " + RetTitle( "DUX_TIPOPE" ) + " " + cMsgInfo, 4, 1) //Para o Servico de coleta é obrigatorio informar os campos:"  
								lRet := .F.
								Exit
							EndIf	
						EndIf			
					EndIf
					
				EndIf
			Next nLoop		
		EndIf
		
		If lRatFix .And. !lRet
			If nTotPer == 0
				Help( " ", 1, "AT250PERFX" ) //Quando utiliza-se um Criterio de Rateio = A (%Fixo) é obrigatorio informar o Percentual Fixo e a Abrangencia do Cliente deve ser 'Cliente'
			Else
				Help( " ", 1, "AT250TOTPR",, " - " + cMsgFix, 4, 1 ) //A somatória do Percentual de Rateio deve ser 100%.
			EndIf	
		EndIf
		//--------------------------------------------------------------------------------------------
		//-- Valida se o status do contrato foi alterado para ativo, mas sem ter negociação ativa
		//-- ou dentro da vigencia.
		//--------------------------------------------------------------------------------------------
		If M->AAM_STATUS == StrZero(1,Len(AAM->AAM_STATUS))
			If !oMdGridDDC:SeekLine({{"DDC_TPCONT","1"},{"DDC_STATUS","1"}}) .And.;
			   !oMdGridDDC:SeekLine({{"DDC_TPCONT","2"},{"DDC_STATUS","1"}})
				oModel:SetErrorMessage(oModel:GetId(),"DDC_STATUS",,,,STR0107, STR0108 )
				lRet := .F.
			EndIf
		EndIf

		//-------------------------------------------------------------------------------------------------
		//-- Início - Verifica Preenchimento Do Serviço De Coleta Automática ( DDC_SRVCOL e DDA_SRVCOL )
		//-------------------------------------------------------------------------------------------------
		If lRet .And. ( DDC->(ColumnPos("DDC_SRVCOL")) > 0 .And. DDA->(ColumnPos("DDA_SRVCOL")) )
		
			//-- Loop No Grid DDC ( Negociações Por Cliente )
			For nI := 1 To oMdGridDDC:Length()
				
				//-- Posiciona Na Linha Do Loop
				oMdGridDDC:GoLine( nI )
				
				If !(oMdGridDDC:IsDeleted())
				
					//-- Se Houver Serviço De Coleta Autom. No DDC Não Precisa Procurar No DDA
					If Empty( oMdGridDDC:GetValue("DDC_SRVCOL") )
					
						//-- Loop No Grid DDA ( Serviços Negociação Cliente )
						For nJ := 1 To oMdGridDDA:Length()
						
							//-- Posiciona Na Linha Do Loop
							oMdGridDDA:GoLine( nJ )
							
							If !(oMdGridDDA:IsDeleted())
	
								//-- Posiciona na DC5 ( Serviços X Tarefas )
								DbSelectArea("DC5")
								DbSetOrder(1) //-- DC5_FILIAL+DC5_SERVIC+DC5_ORDEM
								If MsSeek( FWxFilial("DC5") + oMdGridDDA:GetValue("DDA_SERVIC") , .F. )
								
									If DC5->DC5_SERTMS <> '1' //-- Coleta
									
										If Empty( oMdGridDDA:GetValue("DDA_SRVCOL") )
										
											cCodNeg := oMdGridDDC:GetValue("DDC_CODNEG") //-- Carrega o Código De Negociação Posicionado
											cServic := oMdGridDDA:GetValue("DDA_SERVIC") //-- Carrega o Serviço Posicinado
											
											nPos := Ascan( aMsgErr,{ | e | e[1] == cCodNeg })
											
											If nPos == 0
												aAdd( aMsgErr, { cCodNeg , cServic })
											Else
												aMsgErr[nPos,2] += "," + cServic
											EndIf	
											
										EndIf
									EndIf
								EndIf		
							EndIf
						Next nJ
					EndIf	
				EndIf
			Next nI				

			//-- Formata Mensagem De Help
			If Len(aMsgErr) > 0
				For nJ := 1 To Len(aMsgErr)
					cMsgErr += Chr(13) + Chr(10) + STR0098 + aMsgErr[nJ,01] + ", " + STR0099 + aMsgErr[nJ,02]	//-- "Cód. Negociação: " "Serviço(s): "
				Next nJ
				
				If nOpcx == MODEL_OPERATION_INSERT .OR. nOpcx == MODEL_OPERATION_UPDATE	
					If !MsgYesNo( STR0100 + Chr(13) + Chr(10) + STR0101 + cMsgErr , STR0102 ) //-- "Existe(m) Cód(s). Negociação Ou Serviços Sem Cód. De Coleta Automática Informado. " "Caso Sejam Utilizados Rotinas Que Tenham Geração De Coleta Automática Podem Ocorrer Erros." "Confirma Gravação?"
						lRet := .f.
						oModel:SetErrorMessage(oModel:GetId(),"DDA_SRVCOL",,,,cMsgErr, STR0103 ) //-- "Informe o Código De Coleta Automática"
					EndIf
				EndIf
					
			EndIf
		EndIf			
		If M->AAM_AGRNFC <> '2' .And. M->AAM_NFCTR == 0
		    lRet := .F.
			Help('',1,'AT250NFCTR',,'',1,0)
		EndIf
		//-------------------------------------------------------------------------------------------------
		//-- Fim    - Verifica Preenchimento Do Serviço De Coleta Automática ( DDC_SRVCOL e DDA_SRVCOL )
		//-------------------------------------------------------------------------------------------------
	EndIf
EndIf
FWRestRows( aSaveLine )
RestArea(aAreaAnt)

 Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} PosVldLine
Pós Valid Linha - Antigo Linha OK

@author Jefferson Lima  

@since Dez/2015
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function PosVldLine( oModelGrid, cAlias )

Local aAreaAnt   	 := GetArea()
Local lRet      	 := .T.
Local cTabFre    	 := ''
Local cTipTabFre	 := ''
Local cTabAlt   	 := ''
Local cTipTabAlt	 := ''
Local cTpCont        := ''
Local cStatus        := ''
Local dFimVig        := CToD('  /  /  ')
Local nTpContrato	 := 0	
Local lCamposRat     := Iif(!lTMSItCt,DUX->(ColumnPos("DUX_BACRAT")) > 0,DDA->(ColumnPos("DDA_BACRAT")) > 0)
Local cTabCar        := ""
Local lCmpRatNew     := Iif(!lTMSItCt,DUX->(ColumnPos("DUX_CRDVDC")) > 0,DDA->(ColumnPos("DDA_CRDVDC")) > 0)
Local aAreaDC5   	:= DC5->(GetArea())

Default oModelGrid := Nil
Default cAlias 	   := ""

If !oModelGrid:IsDeleted() // VERIFICAR CONDICAO AJUSTANDO DICIONARIO- If ( !GDDeleted() .AND. ( Len( aCols ) > 1 .OR. iif(nTpContrato<> 3,!Empty(aCols[n,nPd]), .T.) ) )
	
	If cAlias == "AAN"
		
		nTpContrato := 1
		
		If oModelGrid:GetValue( "AAN_FIMCOB" ) < oModelGrid:GetValue( "AAN_INICOB" )
			//Verificar se o MVC trata o AVISO
			Aviso( STR0036, STR0037 + ; //"Atencao!"###"A data final de cobranca deve ser igual ou superior"
					STR0038, { STR0039 }, 2 )    		 //" a data inicial de cobranca !"###"Ok"
			lRet := .F.			
		EndIf
		
	
	ElseIf cAlias == "AAO"
		
		nTpContrato := 2
	
	ElseIf cAlias == "DUX" .Or. cAlias == "DDA"
		
		nTpContrato := 3
		cTabFre    := oModelGrid:GetValue( Iif(lTMSItCt,"DDA_TABFRE","DUX_TABFRE") )
		cTipTabFre := oModelGrid:GetValue( Iif(lTMSItCt,"DDA_TIPTAB","DUX_TIPTAB") )

		If !Empty(cTabFre)
			DT0->(DbSetOrder(1))
			If !DT0->(DbSeek(xFilial('DT0')+cTabFre+cTipTabFre ))
				Help(" ", 1, "AT250TABFR") //Tabela de Frete Invalida
				Return ( .F. )
			EndIf
		EndIf

		cTabAlt    := oModelGrid:GetValue( Iif(lTMSItCt,"DDA_TABALT","DUX_TABALT") )
		cTipTabAlt := oModelGrid:GetValue( Iif(lTMSItCt,"DDA_TIPALT","DUX_TIPALT") )
		
		If lRet .AND. !Empty(cTabAlt)
			If !DT0->(DbSeek(xFilial('DT0')+cTabAlt+cTipTabAlt))
				Help(" ", 1, "AT250TABAL") //Tabela de Frete Alternativa Invalida
				Return ( .F. )
			EndIf
		EndIf

		If lRet .AND. !Empty(cTabFre) .AND. cTabAlt+cTipTabAlt == cTabFre+cTipTabFre 
			Help(" ",1,"AT250TFINV") // A Tabela de Frete Alternativa nao pode ser igual a Tabela de Frete ...
			Return ( .F. )
		EndIf

		If lRet .And. lCamposRat
			//Permitir a opcao Nao Utiliza somente na condição:
			//Quando todos forem 1=Nao utiliza
			//ou
			//Base Rateio 2= Ponto a Ponto, Criterio Calculo= Origem/Destino e Criterio Rateio = Nao Utiliza
		
			If lTMSItCt
				If oModelGrid:GetValue('DDA_BACRAT') <> StrZero(1, Len(DDA->DDA_BACRAT)) .Or. oModelGrid:GetValue('DDA_CRIRAT') <> StrZero(1, Len(DDA->DDA_CRIRAT));
				  	.Or. oModelGrid:GetValue('DDA_PRORAT') <> StrZero(1, Len(DDA->DDA_PRORAT))
				
					If oModelGrid:GetValue('DDA_BACRAT') == StrZero(1, Len(DDA->DDA_BACRAT)) .Or. oModelGrid:GetValue('DDA_CRIRAT') == StrZero(1, Len(DDA->DDA_CRIRAT));
						.Or. oModelGrid:GetValue('DDA_PRORAT') == StrZero(1, Len(DDA->DDA_PRORAT))
							
							If oModelGrid:GetValue('DDA_BACRAT') == StrZero(2, Len(DDA->DDA_BACRAT)) .And. (oModelGrid:GetValue('DDA_CRIRAT') == StrZero(2, Len(DDA->DDA_CRIRAT)) ;
								.Or. oModelGrid:GetValue('DDA_CRIRAT') == 'A' )
								lRet:= .T.
							Else	
								Help( " ", 1, "AT250RAT",,AllTrim(RetTitle('DDA_SERVIC'))  + ': ' + oModelGrid:GetValue('DDA_SERVIC'), 4, 1 ) //Verifique a configuração referente ao Rateio de Frete !
								lRet:= .F.  
							EndIf
					EndIf	
				EndIf
				If lRet .And. lCmpRatNew .And. oModelGrid:GetValue('DDA_PRORAT') == 'A'  //%Fixo, obrigatorio informar os campos _CRDVFA e _CRDVDC
					If oModelGrid:GetValue('DDA_CRDVFA') ==  StrZero(0, Len(DDA->DDA_CRDVFA)) .Or. oModelGrid:GetValue('DDA_CRDVDC') ==  StrZero(0, Len(DDA->DDA_CRDVDC)) //Nao Utiliza
						Help( " ", 1, "OBRIGAT2", , Iif(oModelGrid:GetValue('DDA_CRDVFA') ==  StrZero(0, Len(DDA->DDA_CRDVFA)), RetTitle( "DDA_CRDVFA" ),RetTitle( "DDA_CRDVDC" )), 4, 1 )
						lRet:= .F.
					EndIf	 
				EndIf
				
				If lRet
					DC5->(DbSetOrder(1))
					If DC5->(DbSeek(xFilial("DC5") + oModelGrid:GetValue('DDA_SERVIC'))) .And. DC5->DC5_SERTMS != StrZero(1,Len(DC5->DC5_SERTMS))
						If oModelGrid:GetValue('DDA_AGEVIR') ==  StrZero(1, Len(DDA->DDA_AGEVIR)) .And. Empty(oModelGrid:GetValue('DDA_SRVCOL'))
							Help( " ", 1, "OBRIGAT2", ,RetTitle( "DDA_SRVCOL" ) + " da linha: " + StrZero(oModelGrid:getLine(),3) + " Referente a Grid. "+;
							              oModelGrid:getDescription(), 4, 1 )
							lRet:= .F.
						EndIf
					EndIf
				EndIf
			Else
				If oModelGrid:GetValue('DUX_BACRAT') <> StrZero(1, Len(DUX->DUX_BACRAT)) .Or. oModelGrid:GetValue('DUX_CRIRAT') <> StrZero(1, Len(DUX->DUX_CRIRAT));
					  	.Or. oModelGrid:GetValue('DUX_PRORAT') <> StrZero(1, Len(DUX->DUX_PRORAT))
					
						If oModelGrid:GetValue('DUX_BACRAT') == StrZero(1, Len(DUX->DUX_BACRAT)) .Or. oModelGrid:GetValue('DUX_CRIRAT') == StrZero(1, Len(DUX->DUX_CRIRAT));
							.Or. oModelGrid:GetValue('DUX_PRORAT') == StrZero(1, Len(DUX->DUX_PRORAT))
								
							If oModelGrid:GetValue('DUX_BACRAT') == StrZero(2, Len(DUX->DUX_BACRAT)) .And. (oModelGrid:GetValue('DUX_CRIRAT') == StrZero(2, Len(DUX->DUX_CRIRAT)) ;
								.Or. oModelGrid:GetValue('DUX_CRIRAT') == 'A' )
								lRet:= .T.
							Else	
								Help( " ", 1, "AT250RAT",,AllTrim(RetTitle('DUX_SERVIC'))  + ': ' + oModelGrid:GetValue('DUX_SERVIC'), 4, 1 ) //Verifique a configuração referente ao Rateio de Frete !
								lRet:= .F.  
							EndIf
						EndIf
							
				EndIf
				If lRet .And. lCmpRatNew .And. oModelGrid:GetValue('DUX_PRORAT') == 'A'  //%Fixo, obrigatorio informar os campos _CRDVFA e _CRDVDC
					If oModelGrid:GetValue('DUX_CRDVFA') ==  StrZero(0, Len(DUX->DUX_CRDVFA)) .Or. oModelGrid:GetValue('DUX_CRDVDC') ==  StrZero(0, Len(DUX->DUX_CRDVDC)) //Nao Utiliza
						Help( " ", 1, "OBRIGAT2", , Iif(oModelGrid:GetValue('DUX_CRDVFA') ==  StrZero(0, Len(DUX->DUX_CRDVFA)), RetTitle( "DUX_CRDVFA" ),RetTitle( "DUX_CRDVDC" )), 4, 1 )
						lRet:= .F.
					EndIf	 
				EndIf	
				
				If lRet  
					//-- Valorização Coleta - Testa Preenchimento De Campos
					If DUX->(ColumnPos("DUX_TIPOPE")) > 0 .And. DUX->(ColumnPos("DUX_VALCOL")) > 0
						If Posicione('DC5',1,xFilial('DC5')+oModelGrid:GetValue( "DUX_SERVIC" ),'DC5_SERTMS') == StrZero(1, Len(DC5->DC5_SERTMS))
							If oModelGrid:GetValue( "DUX_VALCOL" ) == '0' .Or. oModelGrid:GetValue( "DUX_TIPOPE" ) == '0' //-- Não Utiliza
								Help( " ", 1, "OBRIGAT2", , Iif(oModelGrid:GetValue( "DUX_TIPOPE" ) == '0',RetTitle( "DUX_TIPOPE" ),RetTitle( "DUX_VALCOL" )), 4, 1 )
								lRet := .F.	
							EndIf
						EndIf				
					EndIf	
				EndIf
				
				If lRet .And. DUX->(ColumnPos("DUX_SRVCOL")) > 0
					DC5->(DbSetOrder(1))
					If DC5->(DbSeek(xFilial("DC5") + oModelGrid:GetValue('DUX_SERVIC'))) .And. DC5->DC5_SERTMS != StrZero(1,Len(DC5->DC5_SERTMS))
						If oModelGrid:GetValue('DUX_AGEVIR') ==  StrZero(1, Len(DUX->DUX_AGEVIR)) .And. Empty(oModelGrid:GetValue('DUX_SRVCOL'))
							Help( " ", 1, "OBRIGAT2", ,RetTitle( "DUX_SRVCOL" ), 4, 1 )
							lRet:= .F.
						EndIf
					EndIf
				EndIf
				
			EndIf
		EndIf

		If lRet 
			lRet:= VldDtVge("AAM") .AND. VldDtVge("DDC",oModelGrid) .AND. VldDtVge("DDA",oModelGrid)
		EndIf 


	ElseIf cAlias == "DDC"

		lRet := VldDtVge("AAM",oModelGrid) .AND. VldDtVge("DDC",oModelGrid)

		If lCamposRat
			If oModelGrid:GetValue('DDC_BACRAT') <> StrZero(1, Len(DDC->DDC_BACRAT)) .Or. oModelGrid:GetValue('DDC_CRIRAT') <> StrZero(1, Len(DDC->DDC_CRIRAT));
			  	.Or. oModelGrid:GetValue('DDC_PRORAT') <> StrZero(1, Len(DDC->DDC_PRORAT))
				
				If oModelGrid:GetValue('DDC_BACRAT') == StrZero(1, Len(DDC->DDC_BACRAT)) .Or. oModelGrid:GetValue('DDC_CRIRAT') == StrZero(1, Len(DDC->DDC_CRIRAT));
					.Or. oModelGrid:GetValue('DDC_PRORAT') == StrZero(1, Len(DDC->DDC_PRORAT))
							
						If oModelGrid:GetValue('DDC_BACRAT') == StrZero(2, Len(DDC->DDC_BACRAT)) .And. (oModelGrid:GetValue('DDC_CRIRAT') == StrZero(2, Len(DDC->DDC_CRIRAT)) ;
							.Or. oModelGrid:GetValue('DDC_CRIRAT') == 'A' )
							lRet:= .T.
						Else	
							Help( " ", 1, "AT250RAT",,AllTrim(RetTitle('DDC_CODNEG'))  + ': ' + oModelGrid:GetValue('DDC_CODNEG'), 4, 1 ) //Verifique a configuração referente ao Rateio de Frete !
							lRet:= .F.  
						EndIf
				EndIf	
			EndIf
			If lRet .And. lCmpRatNew .And. oModelGrid:GetValue('DDC_PRORAT') == 'A' //%Fixo, obrigatorio informar os campos _CRDVFA e _CRDVDC
				If oModelGrid:GetValue('DDC_CRDVFA') ==  StrZero(0, Len(DDC->DDC_CRDVFA)) .Or. oModelGrid:GetValue('DDC_CRDVDC') ==  StrZero(0, Len(DDC->DDC_CRDVDC)) //Nao Utiliza
					Help( " ", 1, "OBRIGAT2", , Iif(oModelGrid:GetValue('DDC_CRDVFA') ==  StrZero(0, Len(DDC->DDC_CRDVFA)), RetTitle( "DDC_CRDVFA" ),RetTitle( "DDC_CRDVDC" )), 4, 1 )
					lRet:= .F. 
				EndIf
			EndIf
		EndIf
		
		If lRet .And. DDC->(ColumnPos("DDC_SRVCOL")) > 0
			DC5->(DbSetOrder(1))
			If DC5->(DbSeek(xFilial("DC5") + oModelGrid:GetValue('DDC_SRVCOL'))) .And. DC5->DC5_SERTMS != StrZero(1,Len(DC5->DC5_SERTMS))
				If oModelGrid:GetValue('DDC_AGEVIR') ==  StrZero(1, Len(DDC->DDC_AGEVIR)) .And. Empty(oModelGrid:GetValue('DDC_SRVCOL'))
					Help( " ", 1, "OBRIGAT2", ,RetTitle( "DDC_SRVCOL" ), 4, 1 )
					lRet:= .F.
				EndIf
			EndIf
		EndIf	

	ElseIf cAlias == "DDP"

		If !Empty(oModelGrid:GetValue( "DDP_CLIDEV" )) .And. oModelGrid:GetValue( "DDP_PERRAT" ) == 0
			Help( " ", 1, "OBRIGAT2", , RetTitle( "DDP_PERRAT" ), 4, 1 )
			lRet := .F.		
		EndIf
		If !(oModelGrid:GetValue( "DDP_CLIDEV" ) = M->AAM_CODCLI)
			Help("",1,"AT250NORAT") //-- O codigo do cliente devedor de rateio deve ser igual ao cliente do contrato.       
			lRet:= .F.
		EndIf
	ElseIf cAlias == "DDH"

		cTabFre    := oModelGrid:GetValue("DDH_TABFPG")
		cTipTabFre := oModelGrid:GetValue("DDH_TIPTPG")

		If !Empty(cTabFre)
			DT0->(DbSetOrder(1))
			If !DT0->(DbSeek(xFilial('DT0') + cTabFre + cTipTabFre))
				Help(" ", 1, "AT250TABFR") //Tabela de Frete Invalida
				Return ( .F. )
			EndIf
		EndIf

		If lRet
			cTabCar := oModelGrid:GetValue("DDH_TABCPG")
	
			If !Empty(cTabCar)
				DUS->(DbSetOrder(1))
				If !DUS->(DbSeek(xFilial('DUS') + cTabCar))
					Help(" ", 1, "AT250TABFR") //Tabela de Frete Invalida
					Return ( .F. )
				EndIf
			EndIf
		EndIf

		If Empty(cTabFre + cTipTabFre + cTabCar)
			Help("",1,"AT250TBVAZ") //-- Atenção # Informe a tabela de frete a pagar ou a tabela de carreteiro
			Return ( .F. )
		EndIf
		
		If !Empty(cTabCar) .And. !Empty(cTabFre) 
			Help("",1,"AT250PAGCA") // Informe apenas uma tabela de frete a pagar ou carreteiro por rota para o contrato.              
			Return ( .F. )
		EndIf 	
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada na validacao da linha                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	If ExistBlock("AT250LOK")
		lRet := ExecBlock("AT250LOK",.F.,.F.,{nTpContrato})
	Endif
Endif

RestArea(aAreaDC5)

RestArea(aAreaAnt)

Return( lRet )


//-------------------------------------------------------------------
/*/{Protheus.doc} PosVldLDT9
Pós Valid da tabela DT9

@author Jefferson Lima  

@since Dez/2015
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function PosVldLDT9()

Local lRet    := .T.
Local cCodPas := FwFldGet('DT9_CODPAS')
Local cAgrPas := FwFldGet('DT9_AGRPAS')
Local oModel 	:= FwModelActive()
Local cTabela := " "
Local cTipTab := " "

cTabela := Iif(lTMSItCt,oModel:GetModel("MdGridIDDA"):GetValue("DDA_TABFRE"),;
						oModel:GetModel("MdGridIDUX"):GetValue("DUX_TABFRE"))
cTipTab := Iif(lTMSItCt,oModel:GetModel("MdGridIDDA"):GetValue("DDA_TIPTAB"),;
						oModel:GetModel("MdGridIDUX"):GetValue("DUX_TIPTAB"))
cTabAlt := Iif(lTMSItCt,oModel:GetModel("MdGridIDDA"):GetValue("DDA_TABALT"),;
						oModel:GetModel("MdGridIDUX"):GetValue("DUX_TABALT"))
cTipAlt := Iif(lTMSItCt,oModel:GetModel("MdGridIDDA"):GetValue("DDA_TIPALT"),;
						oModel:GetModel("MdGridIDUX"):GetValue("DUX_TIPALT"))

DVE->(DbSetOrder(2))

If !GdDeleted(n)
	//-- Valida o preenchimento dos campos obrigatorios
	lRet := MaCheckCols(aHeader,aCols,n)

	If lRet .And. (!DVE->(DbSeek(xFilial('DVE')+cCodPas+cTabela+cTipTab)) .Or.;
		IIf(!Empty(cAgrPas), !DVE->(DbSeek(xFilial('DVE')+cAgrPas+cTabela+cTipTab)) , .F.) ) .Or. ;
		(!DVE->(DbSeek(xFilial('DVE')+cCodPas+cTabAlt+cTipAlt)) .Or.;
		IIf(!Empty(cAgrPas), !DVE->(DbSeek(xFilial('DVE')+cAgrPas+cTabAlt+cTipAlt)) , .F.) )
		Help('',1,'AT250NOCOM') // Este Componente nao faz parte da Config. da Tabela de Frete Informada ...
		Return ( .F. )
	EndIf

	If lRet .AND. cCodPas == cAgrPas
		Help(" ",1,"AT250AGRUP") // Os Codigos dos Componentes informados estao Iguais.
		Return ( .F. )
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Retorna a View da rotina de Contrato de Cliente

@author Jefferson Lima  

@since Dez/2015
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ViewDef()
Local oModel 	:= FwLoadModel("TECA250")
Local oView 	:= Nil
Local nI		:= 1
Local oStruCAAM := Nil
Local oStruIAAN := Nil
Local oStruIAAO := Nil
Local oStruIDT9 := Nil
Local oStruIDUX := Nil
Local oStruIDDA := Nil
Local oStruIDDC := Nil
Local oStruIDDP := Nil
Local lTabDDH   := AliasIndic("DDH")

oStruCAAM := FwFormStruct( 2, "AAM" )
oStruIAAN := FwFormStruct( 2, "AAN" )
oStruIAAO := FwFormStruct( 2, "AAO" )
oStruIDT9 := FwFormStruct( 2, "DT9" )
oStruIDUX := FwFormStruct( 2, "DUX" )
oStruIDDA := FwFormStruct( 2, "DDA" )
oStruIDDC := FwFormStruct( 2, "DDC" )
oStruIDDP := Iif(lTabDDP,FwFormStruct( 2, "DDP" ),Nil)
oStruIDDH := Iif(lTabDDH,FwFormStruct( 2, "DDH" ),Nil)

oStruIAAN:RemoveField( "AAN_CONTRT" )
oStruIAAO:RemoveField( "AAO_CONTRT" )
oStruIDUX:RemoveField( "DUX_NCONTR" )
oStruIDT9:RemoveField( "DT9_NCONTR" )
oStruIDT9:RemoveField( "DT9_CODNEG" )
oStruIDT9:RemoveField( "DT9_SERVIC" )

If lTMSItCt
	oStruIDDC:RemoveField( "DDC_NCONTR" )
	oStruIDDC:RemoveField( "DDC_CODCLI" )
	oStruIDDC:RemoveField( "DDC_LOJCLI" )
	oStruIDDC:RemoveField( "DDC_CRDVFA" )
	oStruIDDC:RemoveField( "DDC_CRDVDC" )
		
	oStruIDDA:RemoveField( "DDA_NCONTR" )
	oStruIDDA:RemoveField( "DDA_CODCLI" )
	oStruIDDA:RemoveField( "DDA_LOJCLI" )
	oStruIDDA:RemoveField( "DDA_CODNEG" )
	
	If lTabDDH
		oStruIDDH:RemoveField( "DDH_NCONTR" )
		oStruIDDH:RemoveField( "DDH_CODNEG" )
		oStruIDDH:RemoveField( "DDH_SERVIC" )
	EndIF	
EndIf

If lTabDDP
	oStruIDDP:RemoveField( "DDP_NCONTR" )
	oStruIDDP:RemoveField( "DDP_SERVIC" )
	oStruIDDP:RemoveField( "DDP_CODNEG" )
	oStruIDDP:RemoveField( "DDP_CODCLI" )
	oStruIDDP:RemoveField( "DDP_LOJCLI" )
	oStruIDDP:RemoveField( "DDP_NOMCLI" )
EndIf
	
oView := FwFormView():New()
oView:SetModel(oModel)

oView:SetContinuousForm()   

oView:CreateHorizontalBox( "Sup", 020 )
oView:CreateHorizontalBox( "Inf", 080  )

oView:CreateFolder( "Folder1",  "Inf" )

oView:AddSheet( "Folder1", "Sht1_F1", STR0010 )
oView:AddSheet( "Folder1", "Sht2_F1", STR0011 )

oView:CreateHorizontalBox( "Box1F1Sht1", 100,,, "Folder1", "Sht1_F1" )  
oView:CreateHorizontalBox( "Box1F1Sht2", 100,,, "Folder1", "Sht2_F1" )

oView:AddField('VwFieldCAAM', oStruCAAM, 'MdFieldCAAM')

oView:AddGrid( "VwGridIAAN", oStruIAAN, "MdGridIAAN" )
oView:AddGrid( "VwGridIAAO", oStruIAAO, "MdGridIAAO" )

oView:EnableTitleView('VwFieldCAAM', "Dados do Contrato" )
oView:EnableTitleView('VwGridIAAN' , STR0010 ) 
oView:EnableTitleView('VwGridIAAO' , STR0011 ) 

oView:AddIncrementField("VwGridIAAN", "AAN_ITEM" )     
oView:AddIncrementField("VwGridIAAO", "AAO_ITEM" )

oView:SetOwnerView( "VwFieldCAAM", "Sup")
oView:SetOwnerView( "VwGridIAAN" , "Box1F1Sht1" )
oView:SetOwnerView( "VwGridIAAO" , "Box1F1Sht2" )

oView:SetViewProperty("VwGridIAAN", "ENABLENEWGRID")
oView:SetViewProperty("VwGridIAAO", "ENABLENEWGRID")

If IntTMS() .And. nModulo == 43

	oView:AddSheet( "Folder1", "Sht3_F1", STR0033 )
	
	oView:CreateHorizontalBox( "Box1F1Sht3", 200,,.T., "Folder1", "Sht3_F1" ) // 370
	oView:CreateHorizontalBox( "Box2F1Sht3", 200,,.T., "Folder1", "Sht3_F1" ) // 250
	oView:CreateHorizontalBox( "Box3F1Sht3", 200,,.T., "Folder1", "Sht3_F1" ) // 250

	If !lTMSItCt		
		oView:AddGrid( "VwGridIDUX", oStruIDUX, "MdGridIDUX" )
		oView:AddGrid( "VwGridIDT9", oStruIDT9, "MdGridIDT9" )
		If lTabDDP
			oView:AddGrid( "VwGridIDDP", oStruIDDP, "MdGridIDDP" )
		EndIf	
		
		oView:EnableTitleView('VwGridIDUX' , "Itens Prestacao de Servico TMS" ) 
		oView:EnableTitleView('VwGridIDT9' , "Config. de Componentes por Contrato" )
		If lTabDDP
			oView:EnableTitleView('VwGridIDDP' , "Percentual Fixo de Rateio" )
		EndIf	
		
		oView:AddIncrementField("VwGridIDUX", "DUX_ITEM" )
		
		oView:SetOwnerView( "VwGridIDUX" , "Box1F1Sht3" )
		oView:SetOwnerView( "VwGridIDT9" , "Box2F1Sht3" )
		If lTabDDP
			oView:SetOwnerView( "VwGridIDDP" , "Box3F1Sht3" )
		EndIf	
	
		oView:SetViewProperty("VwGridIDUX", "ENABLENEWGRID")
		oView:SetViewProperty("VwGridIDT9", "ENABLENEWGRID")
		If lTabDDP	
			oView:SetViewProperty("VwGridIDDP", "ENABLENEWGRID")
		EndIf	
	Else
		oView:CreateHorizontalBox( "Box4F1Sht3", 200,,.T., "Folder1", "Sht3_F1" ) // 250
		oView:CreateHorizontalBox( "Box5F1Sht3", 200,,.T., "Folder1", "Sht3_F1" ) // 250

		oView:AddGrid( "VwGridIDDC", oStruIDDC, "MdGridIDDC" )
		oView:AddGrid( "VwGridIDDA", oStruIDDA, "MdGridIDDA" )
		oView:AddGrid( "VwGridIDT9", oStruIDT9, "MdGridIDT9" )
		If lTabDDH
			oView:AddGrid( "VwGridIDDH", oStruIDDH, "MdGridIDDH" )
		EndIF	

		If lTabDDP
			oView:AddGrid( "VwGridIDDP", oStruIDDP, "MdGridIDDP" )
		EndIf	
		
		oView:EnableTitleView('VwGridIDDC' , "Negociacoes do Cliente" ) 
		oView:EnableTitleView('VwGridIDDA' , "Servicos de Negociacoes do Cliente" )
		oView:EnableTitleView('VwGridIDT9' , "Config. de Componentes por Negociacoes do Contrato" )
		
		If lTabDDH
			oView:EnableTitleView('VwGridIDDH' , "Tabela de Frete a Pagar" )
		EndIf	

		If lTabDDP
			oView:EnableTitleView('VwGridIDDP' , "Percentual Fixo de Rateio" )
			oView:AddIncrementField("VwGridIDDP", "DDP_ITEM" )
		EndIf
		
		oView:AddIncrementField("VwGridIDDC", "DDC_ITEM" )
		oView:AddIncrementField("VwGridIDDA", "DDA_ITEM" )
		
		oView:SetOwnerView( "VwGridIDDC" , "Box1F1Sht3" )
		oView:SetOwnerView( "VwGridIDDA" , "Box2F1Sht3" )
		oView:SetOwnerView( "VwGridIDT9" , "Box3F1Sht3" )
		If lTabDDP
			oView:SetOwnerView( "VwGridIDDP" , "Box4F1Sht3" )
		EndIf
		If lTabDDH
			oView:SetOwnerView( "VwGridIDDH" , "Box5F1Sht3" )
		EndIf	
			
		oView:SetViewProperty("VwGridIDDC", "ENABLENEWGRID")
		oView:SetViewProperty("VwGridIDDA", "ENABLENEWGRID")
		oView:SetViewProperty("VwGridIDT9", "ENABLENEWGRID")
		
		If lTabDDH
			oView:SetViewProperty("VwGridIDDH", "ENABLENEWGRID")
		EndIf	

		If lTabDDP
			oView:SetViewProperty("VwGridIDDP", "ENABLENEWGRID")
		EndIf	
	EndIf

	oView:SelectFolder("FOLDER_01",1,2)

	oView:AddUserButton( STR0045, "BMPUSER"		, {|oView| AT250Perfil(oView:GetOperation()) } 		,NIL,VK_F5, { MODEL_OPERATION_VIEW, MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE })
	oView:AddUserButton( STR0065, "sduprop"		, {|oView| AT250Ajust(oView:GetOperation()) } 		,NIL,VK_F6, { MODEL_OPERATION_VIEW, MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE })
	oView:AddUserButton( STR0067, "RELATORIO"		, {|| TMSHisTabF() } 								,NIL,VK_F7, { MODEL_OPERATION_VIEW, MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE })
	oView:AddUserButton( STR0070, "DEVOLNF"		, {|| TMSHisCli() } 								,NIL,VK_F8, { MODEL_OPERATION_VIEW, MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE })

	If lTMSItCt
		oView:AddUserButton( STR0080, "WEB"		, {|| TMSDiaCol() } 								,NIL,VK_F9, { MODEL_OPERATION_VIEW, MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE })
	EndIf
	
EndIf

oView:AddUserButton( STR0009, "MsDocument"	, {|| MsDocument( "AAM", AAM->( RecNo() ), 4 ) } 		,NIL,, { MODEL_OPERATION_VIEW, MODEL_OPERATION_UPDATE } )
oView:AddUserButton( STR0076, "bmpord1"		, {|| TecTracker( AAM->AAM_PROPOS ) } 					,NIL,, { MODEL_OPERATION_VIEW } )

//ÃšÃ„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„ÃÃ„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Â¿
//Â³ Inclui botoes do usuario                                                  Â³
//Ã€Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã™
If ExistBlock( "AT250BUT" )
	If ValType( aUsButtons := ExecBlock( "AT250BUT", .F., .F., {oModel:GetOperation()} ) ) == "A"
		For nI := 1 To Len(aUsButtons)
			oView:AddUserButton( aUsButtons[nI,1],"",aUsButtons[nI,2] )
		Next nI
	EndIf
EndIf

If lTabDDP
	If lTMSItCt
		oView:SetFieldAction( 'DDA_PRORAT'	, { |oView,cIdForm,cIdCampo,cValue| AT250Act(oView,cIdForm,cIdCampo,cValue) } )
	Else
		oView:SetFieldAction( 'DUX_PRORAT'	, { |oView,cIdForm,cIdCampo,cValue| AT250Act(oView,cIdForm,cIdCampo,cValue) } )
	EndIf	
EndIf	
oView:SetAfterViewActivate({|oView| StAftVwAct(oView)})

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} StAftVwAct

@author Inovação Logística 

@since Dez/2015
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function StAftVwAct(oView)
Local lRet := .T.
Local oModel 	   := Nil         	// Recebe o Model 

Default oView   := FwViewActive()

SetActFold(oView)

// Preenche os campos em caso de copia
If IsInCallStack("At250Copy")
	oModel := oView:GetModel()
	oModel:LoadValue("MdFieldCAAM","AAM_CODCLI", AAM->AAM_CODCLI)
	oModel:LoadValue("MdFieldCAAM","AAM_LOJA", AAM->AAM_LOJA)
	oModel:LoadValue("MdFieldCAAM","AAM_TIPFRE", AAM->AAM_TIPFRE)
	oView:Refresh("VwFieldCAAM")
Else
	lRet	:= VldVgeMdl(oModel)
EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} SetActFold

@author Inovação Logística 

@since Dez/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SetActFold(oView)

If IntTms() .And. nModulo == 43
	oView:SelectFolder('Folder1',3,2)
ElseIf nModulo == 42
	oView:SelectFolder('Folder1',2,2)
EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSDiaCol

@author Inovação Logística 

@since Dez/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TMSDiaCol()
Local aAreas	:= {DC5->(GetArea()),GetArea()}
Local aDiaSem  := {STR0081,STR0082,STR0083,STR0084,STR0085,STR0086,STR0087}
Local aDias    := {}
Local aRet     := {}
Local cDias    := ""
Local cSerTMS  := ""
Local lCkb     := .F.
Local lInv     := .F.
Local nCntFor1 := 0

Local oModel   := FWModelActive()
Local oView    := FWViewActive()
Local cDiaCol  := oModel:GetModel("MdGridIDDA"):GetValue("DDA_DIACOL")
Local cServic  := oModel:GetModel("MdGridIDDA"):GetValue("DDA_SERVIC")

If Empty(cServic)
	Aviso(STR0036,STR0046,{STR0039},2) //"Atencao!"###"Informe o servico !"###"Ok"
Else
	If Posicione("DC5",1,xFilial("DC5") + cServic,"DC5_SERTMS") != "1"
		Aviso(STR0036,STR0090,{STR0039},2) //"Atencao!"###"Opção válida somente para serviços de coleta !"###"Ok"
	Else 
		DUE->( DbSetOrder( 3 ) )
		If DUE->(DbSeek(xFilial('DUE')+M->AAM_CODCLI+M->AAM_LOJA))
			For nCntFor1 := 1 To Len(aDiaSem)
				lCkb := .F.
				If SubStr(cDiaCol,nCntFor1,1) == "*"
					lCkb := .T.
				EndIf
				aAdd(aDias,{4,"",lCkb,aDiaSem[nCntFor1],80,,.F.} )
			Next nCntFor1
			
			aRet  := {}
			cDias := ""
			If oModel:nOperation == 1 .And. ValType(oView) == "O"
				ParamBox(aDias,STR0088,aRet,,{{11,{|oPanel| TmsMrkCol(aDias,aRet,lInv),oPanel:Refresh()},STR0089}},.T.,,,,,.F.)	//"Dias Coleta Automática"###"Marca/Desmarca Todos" Visualização
			ElseIf ValType(oView) == "O" .And. ParamBox(aDias,STR0088,@aRet,,{{11,{|oPanel| TmsMrkCol(aDias,@aRet,@lInv),oPanel:Refresh()},STR0089}},.T.,,,,,.F.)	//"Dias Coleta Automática"###"Marca/Desmarca Todos"
				For nCntFor1 := 1 To Len(aRet)
					cDias += Iif(aRet[nCntFor1],"*"," ")
				Next nCntFor1
				If oModel:LoadValue("MdGridIDDA","DDA_DIACOL",cDias) .And. oModel:nOperation != 1
					oView:SetModified(.T.)
				Endif
			EndIf
		Else
			Aviso(STR0036,STR0097,{STR0039},2) //"Atencao!"###"Este cliente não esta cadastrado como Solicitante!"###"Ok"
		Endif	
		If ValType(oView) == "O"
			oView:Refresh()
		EndIf
	EndIf
EndIf

AEval(aAreas,{|x| RestArea(x) })

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TmsMrkCol

@author Inovação Logística 

@since Dez/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TmsMrkCol(aDias,aRet,lInv)
Local nCntFor1 := 0

For nCntFor1 := 1 To Len(aDias)
	&("MV_PAR" + StrZero(nCntFor1,2)) := Iif(lInv,.F.,.T.)
Next nCntFor1

lInv := !lInv

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³AT250DDP  ³ Autor ³ Katia                 ³ Data ³29/04/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao do percentual de rateio                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpL1 := AT250DDP(oModel,nTotPer)                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpL1 -> Validacao                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TECA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function AT250DDP(oModel,nTotPer)
Local lRet     := .T.
Local nTotPer  := 0
Local nLoop    := 0

Default oModel := Nil
Default nTotPer:= 0

If	(oModel:GetModel( "MdGridIDDP" ):Length() <= 1 .And. oModel:GetModel( "MdGridIDDP" ):IsEmpty()) .Or. M->AAM_ABRANG <> '2' //Cliente  
	lRet:= .F.
Else
	For nLoop:= 1 To oModel:GetModel( "MdGridIDDP" ):Length()
		oModel:GetModel( "MdGridIDDP" ):GoLine( nLoop )
		If !oModel:GetModel( "MdGridIDDP" ):IsDeleted()
			nTotPer+= oModel:GetModel( "MdGridIDDP" ):GetValue('DDP_PERRAT')
		EndIf	
	Next nLoop
	
	If nTotPer <> 100
		lRet:= .F.
	EndIf	
EndIf	
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} AT250Ini
Inicializador dos campos: DDC_DECRIR, DDA_DECRIR, DUX_DECRIR,
DDC_DEPROR, DDA_DEPROR e DUX_DEPROR

@author Katia  

@since 05/05/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function AT250Ini()
	Local cRet    := ""
	Local cCampo  := ReadVar()
	Local cVarIni := '1'  //Nao Utiliza
	
	Private cCriRat:= ""
	Private cProRat:= ""
	
	
	If cCampo $ 'M->DDC_DECRIR|M->DDA_DECRIR|M->DUX_DECRIR'
		If Inclui
			cCriRat := cVarIni
		Else
			Do Case
			Case cCampo $ 'M->DDA_DECRIR'
				cCriRat  := Iif(Empty(DDA->DDA_CRIRAT), cVarIni, DDA->DDA_CRIRAT)   
			Case cCampo $ 'M->DDC_DECRIR'
				cCriRat:= Iif(Empty(DDC->DDC_CRIRAT), cVarIni, DDC->DDC_CRIRAT)     
			Case cCampo $ 'M->DUX_DECRIR' .And. DUX->(ColumnPos('DUX_DECRIR')) > 0
				cCriRat:= Iif(Empty(DUX->DUX_CRIRAT), cVarIni, DUX->DUX_CRIRAT)
			EndCase
		EndIf
		
		cRet   := TMSValField('cCriRat',.F.)
	ElseIf cCampo $ 'M->DDC_DEPROR|M->DDA_DEPROR|M->DUX_DEPROR'
		If Inclui
			cProRat := cVarIni
		Else
			Do Case
			Case cCampo $ 'M->DDA_DEPROR'
				cProRat:= Iif(Empty(DDA->DDA_PRORAT), cVarIni, DDA->DDA_PRORAT)
			Case cCampo $ 'M->DDC_DEPROR'
					cProRat := Iif(Empty(DDC->DDC_PRORAT), cVarIni, DDC->DDC_PRORAT)
			Case cCampo $ 'M->DUX_DEPROR'  .And. DUX->(ColumnPos('DUX_DEPROR')) > 0
				cProRat:= Iif(Empty(DUX->DUX_PRORAT), cVarIni, DUX->DUX_PRORAT)
			EndCase
		EndIf
			
		cRet   := TMSValField('cProRat',.F.)
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AT250Act
Acao a ser executada apos a validacao do campo.

@author Katia  

@since 06/06/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function AT250Act(oView,cIdForm,cIdCampo,cValue)
Local oModel		 := NIL				// Recebe o Modelo 
Local oModelGrid	 := NIL				// Recebe o Modelo do Grid
Local aArea		 := GetArea()			// Recebe a area Ativa
Local oViewObj   	 := NIL				// Recebe o Objeto contendo dados da View
Local nLineAtu	 := 0					// Recebe a Linha atual
Local oMdGridDDP	 := NIL
Local nI			 := 0

Default oView		 := FwViewActive() 	// Recebe o Objeto do View
Default cIdForm	 := "" 				// Recebe o Id do Formulario
Default cIdCampo	 := "" 				// Recebe o Id do Campo
Default cValue	 := "" 				// Recebe o Valor do campo

// Recebe o Modelo do Grid
oModel     := oView:GetModel()

// Recebe as Informações da view apartir do nome do formulario
oViewObj   := oView:GetViewObj(cIdForm)

// Recebe o modelo do grid     
oModelGrid := oModel:GetModel( oViewObj[6] ) //Grid do folder

// recebe a linha atual
nLineAtu   := oModelGrid:GetLine()

If cIdCampo $ "DDC_PRORAT|DDA_PRORAT|DUX_PRORAT"
	oMdGridDDP := oModel:GetModel( "MdGridIDDP" )

	If cValue == "A" 
		oMdGridDDP:LoadValue("DDP_CLIDEV",	M->AAM_CODCLI)
	Else
		For nI:= 1 To oMdGridDDP:Length()
			oMdGridDDP:GoLine(nI)
			
			oMdGridDDP:DeleteLine()
		Next nI
		oView:Refresh("VwGridIDDP")
		oMdGridDDP:GoLine(1)	 
	EndIf	
EndIf

oModelGrid:SetLine(nLineAtu) //posiciona na linha    
oView:Refresh(cIdForm) //Atualiza a tela 

RestArea(aArea)
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} AT250Stru
Verifica e manipula a estrutura do modelo

@author Daniel Carlos

@since 11/07/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AT250Stru(cAlias,oStru,aPECpos)
Local aFields    := oStru:GetFields()
Local cNoFields  := "DDC_TPCONT|DDC_INIVIG|DDC_FIMVIG|"
Local nCnt,cVld,cCpo

Default aPECpos := {}

For nCnt := 1 To Len(aFields)
	cCpo := aFields[nCnt][MVC_MODEL_IDFIELD]
	If !(cCpo $ cNoFields) .And. aScan( aPECpos,{|cCpoPe| AllTrim(cCpoPe) == AllTrim(cCpo) }) == 0

		cVld := AllTrim(oStru:GetProperty(cCpo, MODEL_FIELD_CVALID ) )
		cVld += IIf(!Empty(cVld),'.AND.','')+'AT250Vld()'
		oStru:SetProperty(cCpo,MODEL_FIELD_VALID,FWBuildFeature(STRUCT_FEATURE_VALID,cVld) )
	EndIf
Next nCnt


Return
//-------------------------------------------------------------------
/*/{Protheus.doc} PreVldLine
Pré-Validação da linha: utiliza-se, entre outras ações, na deleção de linhas como a antiga DelOk

@author Daniel Carlos Leme

@since 11/07/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function PreVldLine(oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue)
 Local lRet       := .T.
 Local oModel     := oGridModel:GetModel()
 Local nOperation := oModel:GetOperation()
 Local dFimVigenc := CTOD("")
 Local oMdlFldAAM := Nil

	// Valida se pode ou não apagar uma linha do Grid
	If cAction == 'DELETE' .And. nOperation == MODEL_OPERATION_UPDATE .And. Upper(AllTrim(oGridModel:cId)) $ "MDGRIDIDDC|MDGRIDIDUX|MDGRIDIDT9|MDGRIDIDDP|MDGRIDIDDA|"
		lRet := AT250Vld(Upper(AllTrim(oGridModel:cId)) == "MDGRIDIDDC", cAction)
	EndIf

	// Valida a data de Fim de Vigencia do contrato, quando a data estiver vencida e na alteração deste campo for adicionado uma data maior ou igual a data atual
	// e status assumirá o status de '1-ATIVO'
	// ** somente para a grid de serviços da negociação.

	If cIDField == "DDC_FIMVIG"
		If cAction == 'SETVALUE' .And. nOperation == MODEL_OPERATION_UPDATE .And. Upper(AllTrim(oGridModel:cID)) $ "MDGRIDIDDC"
			oMdlFldAAM := oModel:GetModel( "MdFieldCAAM" )
			If dDataBase <= xValue  .And. oModel:GetModel( "MdGridIDDC" ):GetValue( "DDC_TPCONT" ) <> StrZero(1, Len(DDC->DDC_TPCONT))   //--Altera o Status da negociação se inserida nova data para contratos do tipo '2-tempo indeterminado'
				If Aviso(STR0105,STR0106,{STR0062,STR0063}) == 1
					oModel:GetModel( "MdGridIDDC" ):SetValue("DDC_STATUS",StrZero(1, Len(DDC->DDC_STATUS)))//--Status Ativo
					oMdlFldAAM:SetValue("AAM_STATUS","1") //-- Status 1-Ativo
					If oMdlFldAAM:GetValue("AAM_FIMVIG") < dDataBase
						oMdlFldAAM:SetValue("AAM_FIMVIG",xValue)
					EndIf
				//-- Impede a alteração do campo se usuário não confirmar a mudança do status do contrato para '1-Ativo'
				Else
					lResult := .F.
				EndIf
			EndIf
		EndIf
	EndIF

Return lRet

/*/{Protheus.doc} PreVldAAM
	(Pre Validação de Campo do Cabeçalho da Rotina, tabela AAM)
	@type  Static Function
	@author tiago.dsantos
	@since 10/07/2019 11:38
	@version 0.0.1
	@param oModel, object, objeto do modelo que representa o MPFormModel
	@param cAction, é preenchido com CANSETVALUE indicando se o campo pode ser alterado ou SETVALUE que indica que o campo recebeu valor. Possíveis valores:CANSETVALUE,ISENABLE
	@param cIdCampo, informa qual o campo que está em edição
	@param xValue, quando cAction retorna o valor 'SETVALUE' é retornado também esse argumento com o valor inserido no campo em foco.
	@return boolean, boolean, verdadeiro se o campo pode receber o valor.
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function PreVldAAM(oModelFld,cAction,cIdCampo,xValue)
 Local lResult    := .T.
 Local oModel     := oModelFld:GetModel()
 Local nOperation := oModel:GetOperation()
 Local oMdGridDDC := NIL

	If nOperation == MODEL_OPERATION_UPDATE
		If cAction == "SETVALUE" .And. cIdCampo == "AAM_FIMVIG"
			If dDataBase <= xValue .And. oModelFld:GetValue("AAM_TPCONT") <> StrZero(1,Len(AAM->AAM_TPCONT)) .And. M->AAM_STATUS <> StrZero(1,Len(AAM->AAM_STATUS)) //-- Se Tipo de Contrato for por temp determinado.
				//-- Pede confirmação para mudar o status do contrato para '1-Ativo'
				If Aviso(STR0105,STR0106,{STR0062,STR0063}) == 1
					oModelFld:LoadValue("AAM_STATUS","1")
					If IntTMS() .AND. nModulo == 43
						oMdGridDDC := oModel:GetModel("MdGridIDDC")
						If !oMdGridDDC:SeekLine({{"DDC_TPCONT","1"},{"DDC_STATUS","1"}})
							Aviso(STR0036,STR0107,{"OK"}) //--"Não foi localizado registro de Negociação ativo na grid de Negociações por Cliente. Verifique."
						EndIf
					EndIf
				//-- Impede a alteração do campo se usuário não confirmar a mudança do status do contrato para '1-Ativo'
				Else
					lResult := .F.
				EndIf
			EndIf
		EndIf
	EndIf

Return lResult

/*/{Protheus.doc} VldActiv
	
@author Daniel Carlos Leme
@since 13/07/2016
@version 1.0
		
@param ${oModel}, ${Modelo de dados}

@return ${lRet}, ${Se Ã© possÃ­vel alterar o modelo}

@description

Valida se Ã© permitido alterar o Modelo

/*/
Static Function VldActiv(oModel)
Local lRet 		:= .T.
Local oView		:= FWViewActive()
Local aArea   	:= GetArea()

If ValType(oView) <> "O"
	oView := FwLoadView("TECA250")
EndIf	

If oModel:GetOperation() == MODEL_OPERATION_UPDATE .And. nModulo == 43 .And. IntTMS() .And. ValType(oView) == "O"
	//--Na alteracao, verifica o Status
	//--do contrato:
	If AAM->AAM_STATUS == StrZero(3, Len(AAM->AAM_STATUS))
		If Aviso( STR0036, STR0074, {STR0063, STR0062} ) == 1 //--"Atencao!"###"Atualmente o contrato esta 'ENCERRADO'. Prosseguir com a alteracao do contrato?"###"Nao"###"Sim"
			lRet := .F.
			oModel:SetErrorMessage(oModel:GetId(),"AAM_STATUS",,,,STR0104, '' ) //-- "Operação Cancelada!"
		EndIf
	EndIf
EndIf	

RestArea(aArea)
Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} At250Copy()
Copia de registro no Modelo

Uso: TECA250

@sample
//At250Copy()

@author Paulo Henrique CorrÃªa Cardoso.
@since 20/12/2016
@version 1.0
-----------------------------------------------------------/*/
Function At250Copy()
	FWExecView( STR0001 ,'TECA250',9,, { || .T. },{ || .T. },,,{ || .T. })  //"Movimento de Custo de Transporte"
Return 


/*/-----------------------------------------------------------
{Protheus.doc} VldDtVge()
Valida data do Contrato

Uso: TECA250

@sample
//At250Copy()

@author Caio Murakami
@since 20/12/2016
@version 1.0
-----------------------------------------------------------/*/
Static Function VldDtVge( cTabVld , oModelGrid )
Local lRet		:= .T. 
Local cTabFre	:= ""
Local cTipTab	:= ""

Default cTabVld		:= "AAM"
Default oModelGrid	:= Nil

If cTabVld == "AAM"
	If FwFldGet("AAM_TPCONT") == "2" .And. FwFldGet("AAM_FIMVIG") < dDataBase 
		lRet	:= .F. 
		Help( " ", 1, "AT250FIMVIG", , STR0109 + RetTitle( "AAM_FIMVIG" ) + " >= " + DToC(dDataBase) + STR0110 +;
								RetTitle("AAM_TPCONT") + STR0111 + chr(13) + chr(10) + "", 4, 1 )
	EndIf 
ElseIf cTabVld == "DDC"

	If lRet 
		If FwFldGet( "DDC_TPCONT" ) == "2" .And. ( FwFldGet( "DDC_FIMVIG" ) < dDataBase .Or. Empty(FwFldGet( "DDC_FIMVIG" )) )
			lRet	:= .F. 
			Help( " ", 1, "AT250FIMVIG", , STR0109 + RetTitle( "DDC_FIMVIG" ) + " >= " + DToC(dDataBase) + STR0110 +;
									RetTitle("DDC_TPCONT") + STR0111 + chr(13) + chr(10) + "", 4, 1 )
		EndIf 	
	EndIf	
ElseIf cTabVld == "DDA"
	If lRet
		cTabFre	:= FwFldGet("DDA_TABFRE")
		cTipTab	:= FwFldGet("DDA_TIPTAB")

		DTL->(dbSetOrder(1))
		If DTL->( MsSeek( xFilial("DTL") + cTabFre + cTipTab )) .And. !Empty(DTL->DTL_DATATE)
			If dDataBase > DTL->DTL_DATATE
				lRet	:= .F. 
				Help( " ", 1, "AT250FIMVIG", , RetTitle("DDA_TABFRE") + ": " + cTabFre + "/" + cTipTab + chr(13) + chr(10) + ; 
						STR0105 + " " + DToC(DTL->DTL_DATATE)+ chr(13) + chr(10), 4, 1 ) //-- Data Fim de Vigência
			EndIf 
		EndIf 
		If lRet
			DY9->(dbSetOrder(1))
			If DY9->(MsSeek(xFilial("DY9") + cTabFre + cTipTab )) .And. !Empty(DY9->DY9_DATATE)
				If dDataBase > DY9->DY9_DATATE
					lRet	:= .F. 
					Help( " ", 1, "AT250FIMVIG", , FWX2Nome("DY9") + chr(13) + chr(10) + RetTitle( "DDA_TABFRE" ) + ": " + cTabFre + "/" + cTipTab + chr(13) + chr(10) + ; 
							STR0105 + " " + DToC(DY9->DY9_DATATE) + chr(13) + chr(10) + "", 4, 1 ) //-- Data Fim de Vigência
				
				EndIf 
			EndIf 
		EndIf
	EndIf 

	If lRet 
		cTabFre	:= FwFldGet("DDA_TABALT")
		cTipTab	:= FwFldGet("DDA_TIPALT")

		DTL->(dbSetOrder(1))
		If DTL->( MsSeek( xFilial("DTL") + cTabFre + cTipTab )) .And. !Empty(DTL->DTL_DATATE)
			If dDataBase > DTL->DTL_DATATE
				lRet	:= .F. 
				Help( " ", 1, "AT250FIMVIG", , RetTitle( "DDA_TABALT" ) + ": " + cTabFre + "/" + cTipTab + chr(13) + chr(10) + ; 
						STR0105 + " " + DToC(DTL->DTL_DATATE) + chr(13) + chr(10) + "", 4, 1 ) //-- Data Fim de Vigência
			
			EndIf 
		EndIf

		If lRet
			DY9->(dbSetOrder(1))
			If DY9->(MsSeek(xFilial("DY9") + cTabFre + cTipTab )) .And. !Empty(DY9->DY9_DATATE)
				If dDataBase > DY9->DY9_DATATE
					lRet	:= .F. 
					Help( " ", 1, "AT250FIMVIG", , FWX2Nome("DY9") + chr(13) + chr(10) + RetTitle( "DDA_TABALT" ) + ": " + cTabFre + "/" + cTipTab + chr(13) + chr(10) + ; 
							STR0105 + " " + DToC(DY9->DY9_DATATE) + chr(13) + chr(10) + "", 4, 1 ) //-- Data Fim de Vigência
				
				EndIf 
			EndIf 
		Endif
	EndIf 
EndIf 

Return lRet 

/*/-----------------------------------------------------------
{Protheus.doc} VldVgeMdl()
Valida vigencia do contrato

Uso: TECA250

@sample
//At250Copy()

@author Caio Murakami
@since 30/03/2021
@version 1.0
-----------------------------------------------------------/*/
Static Function VldVgeMdl(oModel)
Local lRet		:= .T. 
Local nCount	:= 1 
Local oMdlGrid	:= Nil 
Local cTabAlt	:= ""
Local cTipAlt	:= ""
Local cTabFre	:= ""
Local cTipFre	:= ""
Local cMsg		:= ""
Local nBkpLine  := 0
Local aAreas    := {}

Default oModel	:= FwModelActive() 

If IntTms() .And. nModulo == 43 .And. oModel:GetOperation() == MODEL_OPERATION_UPDATE

	aAreas := {DTL->(GetArea()), GetArea()}

	If oModel:GetModel("MdFieldCAAM"):GetValue("AAM_TPCONT") == "2"
		If dDataBase > oModel:GetModel("MdFieldCAAM"):GetValue("AAM_FIMVIG")
			cMsg	+= AllTrim(RetTitle("AAM_CONTRT")) + ": " + oModel:GetModel("MdFieldCAAM"):GetValue("AAM_CONTRT") + " - " + DToC( oModel:GetModel("MdFieldCAAM"):GetValue("AAM_FIMVIG") ) + chr(10) 
		EndIf		
	EndIf 

	oMdlGrid := oModel:GetModel("MdGridIDDC")
	nBkpLine := oMdlGrid:GetLine()
	For nCount := 1 To oMdlGrid:Length()
		oMdlGrid:GoLine(nCount)
		If oMdlGrid:GetValue("DDC_TPCONT") == "2"
			If dDataBase > oMdlGrid:GetValue("DDC_FIMVIG")
				cMsg	+= AllTrim(RetTitle("DDC_CODNEG")) + ": "  + oMdlGrid:GetValue("DDC_CODNEG") + " - " + DToC( oMdlGrid:GetValue("DDC_FIMVIG") ) + chr(10) 
			EndIf 
		EndIf 

	Next nCount
	If nBkpLine != oMdlGrid:GetLine()
		oMdlGrid:GoLine(nBkpLine)
	EndIf

	DTL->( dbSetOrder(1))
	oMdlGrid := oModel:GetModel("MdGridIDDA")
	nBkpLine := oMdlGrid:GetLine()
	For nCount := 1 To oMdlGrid:Length()
		oMdlGrid:GoLine(nCount)
		cTabFre	:= oMdlGrid:GetValue("DDA_TABFRE")
		cTipFre	:= oMdlGrid:GetValue("DDA_TIPTAB")

		If DTL->(dbSeek( xFilial("DTL") + cTabFre + cTipAlt ))  .And. !Empty( DTL->DTL_DATATE )
			If dDataBase > DTL->DTL_DATATE 
				cMsg	+= AllTrim(RetTitle("DTL_TABFRE")) + ": "  + cTabFre + "/" + cTipFre + " - " + DToC( DTL->DTL_DATATE ) + chr(10) 
			EndIf 
		EndIf 

		cTabAlt	:= oMdlGrid:GetValue("DDA_TABALT")
		cTipAlt	:= oMdlGrid:GetValue("DDA_TIPALT")
		If DTL->(dbSeek( xFilial("DTL") + cTabAlt + cTipAlt ))  .And. !Empty( DTL->DTL_DATATE )
			If dDataBase > DTL->DTL_DATATE 
				cMsg	+= AllTrim(RetTitle("DTL_TABFRE")) + ": "  + cTabAlt + "/" + cTipAlt + " - " + DToC( DTL->DTL_DATATE ) + chr(10) 
			EndIf 
		EndIf 
	Next nCount
	If nBkpLine != oMdlGrid:GetLine()
		oMdlGrid:GoLine(nBkpLine)
	EndIf

	oMdlGrid	:= oModel:GetModel("MdGridIDDH")
	nBkpLine := oMdlGrid:GetLine()
	For nCount := 1 To oMdlGrid:Length()
		oMdlGrid:GoLine(nCount)
		cTabFre	:= oMdlGrid:GetValue("DDH_TABFPG")
		cTipFre	:= oMdlGrid:GetValue("DDH_TIPTPG")

		If DTL->(dbSeek( xFilial("DTL") + cTabFre + cTipAlt )) .And. !Empty( DTL->DTL_DATATE )
			If dDataBase > DTL->DTL_DATATE 
				cMsg	+= AllTrim(RetTitle("DTL_TABFRE")) + ": "  +  cTabFre + "/" + cTipFre + " - " + DToC( DTL->DTL_DATATE ) + chr(10) 
			EndIf 
		EndIf 

	Next nCount
	If nBkpLine != oMdlGrid:GetLine()
		oMdlGrid:GoLine(nBkpLine)
	EndIf

	AEval( aAreas, { |aArea| RestArea(aArea) } )

EndIf 

If !Empty(cMsg)
	MsgAlert( STR0105 + chr(10) + cMsg ) //-- Data de fim da vigência
EndIf 

Return lRet 
