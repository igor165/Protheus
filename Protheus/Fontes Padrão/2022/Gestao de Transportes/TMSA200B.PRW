#Include "TMSA200B.CH"
#Include "Protheus.ch"
#Include "FWMVCDEF.CH"

Static lTM200Cpo  := ExistBlock("TM200CPO")	//-- Permite inclusão de novos campos no aHeader e no aCols
Static lTM200But  := ExistBlock("TM200BUT")	//-- Permite inclusão de botões
Static nVolOri    := 0
Static nVolAtu    := 0
Static nPesRea    := 0
Static nPesCub    := 0
Static nPesCob    := 0
Static nValMer    := 0
Static nValFre    := 0
Static nValImp    := 0
Static nValTot    := 0
Static cRota      := ""
Static cRoteir    := ""
Static oVolOri
Static oVolAtu
Static oPesRea
Static oPesCub
Static oPesCob
Static oValMer
Static oValFre
Static oValImp
Static oValTot
Static oRota
Static oRoteir

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Tms200bScr ³ Autor ³ Valdemar Roberto  ³ Data ³ 19.05.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe tela de preview do frete a receber                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tms200bScr(aExp01)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aExp01 := Vetor com as informaçõs do cálculo               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³Retorno   ³ aRet :=                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tms200bScr(aPreview)

	Local lRet     := .T.
	Local lBotao   := .T.
	Local aAreas   := {DTQ->(GetArea()),SX3->(GetArea()),GetArea()}
	Local aInfo    := {}
	Local aPosObj  := {}
	Local aObjects := {}
	Local aSize    := MsAdvSize(.T.)
	Local aButtons := {}
	Local aAlter   := {}
	Local aColsWrk := {}
	Local aColsUsu := {}
	Local aCpoUsu  := {}
	Local aButUsu  := {}
	Local aCampos  := {}

	Local nOpca    := 0
	Local nCnt1    := 0
	Local nCnt2    := 0
	Local nPosVet  := 13
	Local oBotao
	Local aFldAux	:= {}
	Local aFldAll	:= {}
	Local nI 		:= 0
	Local nPosFld	:= 0

	Private cCadastro  := STR0012
	Private Inclui     := .F.
	Private aHeaderFre := {}
	Private aColsFre   := {}
	Private aSetKey    := {}
	Private aPvw       := aPreview
	Private nPosPvw    := 0
	Private oDlgFre
	Private oGetFre
	Private oPanFre

	DEFAULT aPreview := {}

	//-- Inclusão De Campos Padrão da Rotina
	aAdd( aCampos , { "DT6_CLIDEV" , "aPvw[nPosPvw,13,01,01]"   , "01"  })  //-- 01	Devedor
	aAdd( aCampos , { "DT6_LOJDEV" , "aPvw[nPosPvw,13,01,02]"   , "02"  })  //-- 02	Loja Devedor
	aAdd( aCampos , { "DT6_NOMDEV" , "aPvw[nPosPvw,13,01,03]"   , "03"  })  //-- 03	Nome Devedor
	aAdd( aCampos , { "DT6_VALFRE" , "aPvw[nPosPvw,13,01,13]"   , "04"  })  //-- 13	Valor Do Frete
	aAdd( aCampos , { "DT6_VALIMP" , "aPvw[nPosPvw,13,01,14]"   , "05"  })  //-- 14	Valor Imposto
	aAdd( aCampos , { "DT6_VALTOT" , "aPvw[nPosPvw,13,01,15]"   , "06"  })  //-- 15	Valor Total
	aAdd( aCampos , { "DT6_CODNEG" , "aPvw[nPosPvw,13,01,24]"   , "07"  })  //-- 24	Código da Negociação //-- DDB
	aAdd( aCampos , { "DDB_DESCRI" , "Tmsa200bDc('DT6_CODNEG')" , "07X" })  //-- 24	Descr. Cód. Negoc.   //-- DDB	
	aAdd( aCampos , { "DT6_SERVIC" , "aPvw[nPosPvw,13,01,25]"   , "08"  })  //-- 25	Servico              //-- SX5 Tab 'L4'
	aAdd( aCampos , { "DT6_SERVIC" , "Tmsa200bDc('DT6_SERVIC')" , "08X" })  //-- 25	Descr. Servico       //-- SX5 Tab 'L4'
	aAdd( aCampos , { "DT6_NCONTR" , "aPvw[nPosPvw,13,01,26]"   , "09"  })  //-- 26	No.Contrato          //-- AAM
	aAdd( aCampos , { "DT6_VOLORI" , "aPvw[nPosPvw,13,01,04]"   , "10"  })  //-- 04	Volume Original
	aAdd( aCampos , { "DT6_QTDVOL" , "aPvw[nPosPvw,13,01,05]"   , "11"  })  //-- 05	Quantidade De Volumes
	aAdd( aCampos , { "DT6_PESO"   , "aPvw[nPosPvw,13,01,06]"   , "12"  })  //-- 06	Peso
	aAdd( aCampos , { "DT6_PESOM3" , "aPvw[nPosPvw,13,01,07]"   , "13"  })  //-- 07	Peso Cubado
	aAdd( aCampos , { "DT6_PESCOB" , "aPvw[nPosPvw,13,01,08]"   , "14"  })  //-- 08	Peso Cobrado
	aAdd( aCampos , { "DT6_VALMER" , "aPvw[nPosPvw,13,01,09]"   , "15"  })  //-- 09	Valor Da Mercadoria
	aAdd( aCampos , { "DT6_TABFRE" , "aPvw[nPosPvw,13,01,10]"   , "16"  })  //-- 10	Tabela De Frete
	aAdd( aCampos , { "DT6_TIPTAB" , "aPvw[nPosPvw,13,01,11]"   , "17"  })  //-- 11	Tipo Tabela De Frete
	aAdd( aCampos , { "DT6_SEQTAB" , "aPvw[nPosPvw,13,01,12]"   , "18"  })  //-- 12	Sequencia Tabela De Frete
	aAdd( aCampos , { "DT6_CDRORI" , "aPvw[nPosPvw,13,01,22]"   , "19"  })  //-- 22	Codigo Regiao Origem
	aAdd( aCampos , { "DT5_REGORI" , "Tmsa200bDc('DT6_CDRORI')" , "19X" })  //-- 22	Descr. Regiao Origem
	aAdd( aCampos , { "DT6_CDRCAL" , "aPvw[nPosPvw,13,01,23]"   , "20"  })  //-- 23	Codigo Regiao Calculo
	aAdd( aCampos , { "DT5_REGDCA" , "Tmsa200bDc('DT6_CDRCAL')" , "20X" })  //-- 22	Descr. Regiao Calculo
	aAdd( aCampos , { "DT6_CLIREM" , "aPvw[nPosPvw,13,01,16]"   , "21"  })  //-- 16	Remetente
	aAdd( aCampos , { "DT6_LOJREM" , "aPvw[nPosPvw,13,01,17]"   , "22"  })  //-- 17	Loja Remetente
	aAdd( aCampos , { "DT6_NOMREM" , "aPvw[nPosPvw,13,01,18]"   , "23"  })  //-- 18	Nome Remetente
	aAdd( aCampos , { "DT6_CLIDES" , "aPvw[nPosPvw,13,01,19]"   , "24"  })  //-- 19	Destinatario
	aAdd( aCampos , { "DT6_LOJDES" , "aPvw[nPosPvw,13,01,20]"   , "25"  })  //-- 20	Loja Destinatario
	aAdd( aCampos , { "DT6_NOMDES" , "aPvw[nPosPvw,13,01,21]"   , "26"  })  //-- 21	Nome Destinatario
	aAdd( aCampos , { "DTC_TIPNFC" , "aPvw[nPosPvw,13,01,30]"   , "27"  })  //-- 22 Tipo NFC
	
	//-- Permite a inclusão de campos no aHeader
	If lTM200Cpo
		aCpoUsu := ExecBlock("TM200CPO",.F.,.F.,{1,Aclone(aCampos),{}})
		If ValType(aCpoUsu) == "A"
			aCampos := AClone(aCpoUsu)
		Endif
	EndIf

	//-- Ordena aCampos Conforme Coluna 03
	ASort(aCampos,,,{|x,y| x[03] < y[03] })

	aFldAux := ApBuildHeader("DT6")
	For nI := 1 To Len(aFldAux)
		aAdd(aFldAll, aFldAux[nI])
	Next

	aFldAux := ApBuildHeader("DDB")
	For nI := 1 To Len(aFldAux)
		aAdd(aFldAll, aFldAux[nI])
	Next

	aFldAux := ApBuildHeader("DT5")
	For nI := 1 To Len(aFldAux)
		aAdd(aFldAll, aFldAux[nI])
	Next

	//-- Monta aHeader
	Aadd(aHeaderFre,{"Seleção","__SELEC","@BMP",1,0,"","","C","","V","",""})

	For nCnt1 := 1 To Len(aCampos)
		If (nPosFld := aScan(aFldAll, {|x| AllTrim(x[2]) == aCampos[nCnt1][1]})) > 0
			Aadd(aHeaderFre, aFldAll[nPosFld])
		EndIf
	Next nCnt1

	//-- Monta aCols
	For nCnt1 := 1 To Len(aPvw)

		//-- Inicializa Variável
		aColsWrk := {"LBOK"}
		nPosPvw  := nCnt1
	
		//-- Incrementa Linha Do aCols Conforme Ordenação Do aCampos
		For nCnt2 := 1 To Len(aCampos)
	
			//-- Executa Macro Substituição Do Metadado
			aAdd( aColsWrk, &(aCampos[nCnt2,02]) )
	
		Next nCnt2
	
		//-- Permite a inclusão de campos no aHeader
		If lTM200Cpo
			aColsUsu := ExecBlock("TM200CPO",.F.,.F.,{2,Aclone(aColsWrk),Aclone(aPvw[nCnt1])})
			If ValType(aColsUsu) == "A"
				aColsWrk := AClone(aColsUsu)
			Endif
		EndIf

		Aadd(aColsWrk,.F.)
		Aadd(aColsFre,Aclone(aColsWrk))

	Next nCnt1

	Tms200bTot(Aclone(aColsFre))

	//-- Botão Composição Do Frete
	AAdd(aSetKey ,{VK_F5    ,{|| Tms200bCmp(Aclone(aPvw))      }})
	AAdd(aButtons,{"SDUPROP",{|| Tms200bCmp(Aclone(aPvw))      }, STR0002 , "<F5> " + STR0003 }) //-- "Composição do Frete" "Comp.Frete"

	//-- Botão Visualizar Contrato
	AAdd(aSetKey ,{VK_F6    ,{|| Tms200bCon(aClone(aColsFre))  }})
	AAdd(aButtons,{"SDUPROP",{|| Tms200bCon(aClone(aColsFre))  }, STR0004 , "<F6> " + STR0005 }) //-- "Visualizar Contrato"	"Vis.Contrato"

	//-- Botão Visualizar Perfil Cliente
	AAdd(aSetKey ,{VK_F7    ,{|| Tms200bPrf(aClone(aColsFre))  }})
	AAdd(aButtons,{"SDUPROP",{|| Tms200bPrf(aClone(aColsFre))  }, STR0006 , "<F7> " + STR0007 }) //-- "Vis. Perfil Cliente" "Vis.Perfil"	

	//-- Botão Visualizar Tabela Frete/Ajuste
	AAdd(aSetKey ,{VK_F8    ,{|| Tms200bTab(aClone(aColsFre),Aclone(aPvw))  }})
	AAdd(aButtons,{"SDUPROP",{|| Tms200bTab(aClone(aColsFre),Aclone(aPvw))  }, STR0008 ,"<F8> " + STR0009 }) //-- "Tabela Frete / Ajuste" "Tab. Frete" 

	//-- Botão Visualizar Docs. Cliente
	AAdd(aSetKey ,{VK_F9    ,{|| Tms200bDoc(aClone(aPvw))      }})
	AAdd(aButtons,{"SDUPROP",{|| Tms200bDoc(aClone(aPvw))      }, STR0010 , "<F9> " + STR0011 }) //-- "Visualiza Documentos Cliente" 

	//-- Permite a inclusão de botoes
	If lTM200But
		aButUsu := ExecBlock("TM200BUT",.F.,.F.,)
		If	ValType(aButUsu) == "A"
			For nCnt1 := 1 To Len(aButUsu)
				AAdd(aButtons,aButUsu[nCnt1])
			Next nCnt1
		EndIf
	EndIf

	//-- Carrega rota e roteiro da viagem
	If IsInCallStack("TMSF76Via")
		cRota   := DTQ->DTQ_ROTA
		cRoteir := DTQ->DTQ_ROTEIR
	EndIf
	//-- Inicializa Teclas de Atalhos
	TmsKeyOn(aSetKey)

	aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],1,1}
	AAdd(aObjects,{080,080,.T.,.T.})
	AAdd(aObjects,{020,020,.T.,.T.})
	aPosObj := MsObjSize(aInfo,aObjects,.T.)

	If !Empty(aColsFre)
		DEFINE MSDIALOG oDlgFre TITLE STR0012 FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL //-- "Preview do Frete a Receber"

		//-- Grid		
		oGetFre := MsNewGetDados():New(aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4],GD_UPDATE,"AllWaysTrue","AllWaysTrue",,aAlter,,Len(aColsFre),,,,oDlgFre,aHeaderFre,aColsFre)
		oGetFre:oBrowse:blDblClick := {||  Tms200bMrk(.T.)}

		//-- Rodapé
		oPanFre := TPanel():New(aPosObj[2,1],aPosObj[2,2],"",oDlgFre,,,,,CLR_WHITE,(aPosObj[2,4]),(aPosObj[2,3]),.T.)

		@ 005,020 CHECKBOX oBotal VAR lBotao PROMPT STR0013 SIZE 68,05 ON CLICK(Tms200bMrk(.F.)) OF oPanFre PIXEL //-- "Marca/Desmarca Todos"

		@ 025,020 SAY RetTitle("DT6_VOLORI")         SIZE 40,9 OF oPanFre PIXEL
		@ 025,060 MSGET oVolOri VAR nVolOri WHEN .F. SIZE 30,9 OF oPanFre PIXEL PICTURE PesqPict("DT6","DT6_VOLORI")

		@ 005,120 SAY RetTitle("DT6_PESO")         SIZE 40,9 OF oPanFre PIXEL
		@ 005,160 MSGET oPesRea VAR nPesRea WHEN .F. SIZE 50,9 OF oPanFre PIXEL PICTURE PesqPict("DT6","DT6_PESO")

		@ 025,120 SAY RetTitle("DT6_QTDVOL")         SIZE 40,9 OF oPanFre PIXEL
		@ 025,160 MSGET oVolAtu VAR nVolAtu WHEN .F. SIZE 30,9 OF oPanFre PIXEL PICTURE PesqPict("DT6","DT6_QTDVOL")

		@ 005,220 SAY RetTitle("DT6_PESCOB")         SIZE 40,9 OF oPanFre PIXEL
		@ 005,260 MSGET oPesCob VAR nPesCob WHEN .F. SIZE 50,9 OF oPanFre PIXEL PICTURE PesqPict("DT6","DT6_PESCOB")

		@ 025,220 SAY RetTitle("DT6_PESOM3")         SIZE 40,9 OF oPanFre PIXEL
		@ 025,260 MSGET oPesCub VAR nPesCub WHEN .F. SIZE 50,9 OF oPanFre PIXEL PICTURE PesqPict("DT6","DT6_PESOM3")

		@ 005,320 SAY RetTitle("DT6_VALFRE")         SIZE 40,9 OF oPanFre PIXEL
		@ 005,360 MSGET oValFre VAR nValFre WHEN .F. SIZE 50,9 OF oPanFre PIXEL PICTURE PesqPict("DT6","DT6_VALFRE")

		@ 025,320 SAY RetTitle("DT6_VALMER")         SIZE 40,9 OF oPanFre PIXEL
		@ 025,360 MSGET oValMer VAR nValMer WHEN .F. SIZE 50,9 OF oPanFre PIXEL PICTURE PesqPict("DT6","DT6_VALMER")

		@ 005,420 SAY RetTitle("DT6_VALIMP")         SIZE 40,9 OF oPanFre PIXEL
		@ 005,460 MSGET oValImp VAR nValImp WHEN .F. SIZE 50,9 OF oPanFre PIXEL PICTURE PesqPict("DT6","DT6_VALIMP")

		@ 025,420 SAY RetTitle("DTQ_ROTA")           SIZE 40,9 OF oPanFre PIXEL
		@ 025,460 MSGET oRota VAR cRota     WHEN .F. SIZE 50,9 OF oPanFre PIXEL PICTURE PesqPict("DTQ","DTQ_ROTA")

		@ 005,520 SAY RetTitle("DT6_VALTOT")         SIZE 40,9 OF oPanFre PIXEL
		@ 005,560 MSGET oValTot VAR nValTot WHEN .F. SIZE 50,9 OF oPanFre PIXEL PICTURE PesqPict("DT6","DT6_VALTOT")

		@ 025,520 SAY RetTitle("DTQ_ROTEIR")         SIZE 40,9 OF oPanFre PIXEL
		@ 025,560 MSGET oRoteir VAR cRoteir WHEN .F. SIZE 50,9 OF oPanFre PIXEL PICTURE PesqPict("DTQ","DTQ_ROTEIR")

		Activate MsDialog oDlgFre ON INIT EnchoiceBar(oDlgFre,{|| nOpca := 1,Iif(Tms200bVld(Aclone(aPvw)),oDlgFre:End(),nOpca == 0)},{|| nOpcA := 0,oDlgFre:End()},,aButtons)
	EndIf

	If nOpca == 0
		lRet := .F.
	Else

		//-- Atualiza aPvw Conforme aCols
		For nCnt1 := 1 To Len(oGetFre:aCols)
	
			If oGetFre:aCols[nCnt1,1] == "LBOK"
				aPvw[nCnt1,14] := .T.
			Else
				aPvw[nCnt1,14] := .F.
			EndIf
		
		Next nCnt1
	EndIf

	nVolOri  := 0
	nVolAtu  := 0
	nPesRea  := 0
	nPesCub  := 0
	nPesCob  := 0
	nValMer  := 0
	nValFre  := 0
	nValImp  := 0
	nValTot  := 0
	cRota    := ""
	cRoteir  := ""
	aPreview := aPvw //-- Retorna valor Para aPreview Para utilização Do TMSA200

	//-- Finaliza Teclas de Atalhos
	TmsKeyOff(aSetKey)

	AEval(aAreas,{|x,y| RestArea(x) })

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Tms200bMrk ³ Autor ³ Valdemar Roberto  ³ Data ³ 20.05.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marca/Desmarca linhas                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tms200bMrk(lExp01)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lExp01 := .T. Inverte a linha / .F. Inverte o Grid         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³Retorno   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tms200bMrk(lLinha)

	Local nCnt1 := 0
	Local nLinIni  := 0
	Local nLinFim  := 0
	Local cStsLin  := ""

	DEFAULT lLinha := .T.

	nLinIni := Iif(lLinha,oGetFre:oBrowse:nAt,1)
	nLinFim := Iif(lLinha,oGetFre:oBrowse:nAt,Len(oGetFre:aCols))
	cStsLin := Iif(oGetFre:aCols[Iif(lLinha,nLinIni,1),1] == "LBOK","LBNO","LBOK")

	nVolOri := 0
	nVolAtu := 0
	nPesRea := 0
	nPesCub := 0
	nPesCob := 0
	nValMer := 0
	nValFre := 0
	nValImp := 0
	nValTot := 0
	cRota   := ""
	cRoteir := ""

	For nCnt1 := nLinIni To nLinFim
		oGetFre:aCols[nCnt1,1] := cStsLin
	Next nCnt1

	Tms200bTot()

	oGetFre:oBrowse:Refresh()
	oVolOri:Refresh()
	oVolAtu:Refresh()
	oPesRea:Refresh()
	oPesCub:Refresh()
	oPesCob:Refresh()
	oValMer:Refresh()
	oValFre:Refresh()
	oValImp:Refresh()
	oValTot:Refresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Tms200bTot ³ Autor ³ Valdemar Roberto  ³ Data ³ 21.05.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Totaliza rodapé                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tms200bTot(aExp01)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aExp01 := Vetor do aCols                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³Retorno   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tms200bTot(aVetWrk)

	Local nCnt1     := 0
	Local nPVolOri  := Ascan( aHeaderFre, { |aField| aField[2] = "DT6_VOLORI" } )
	Local nPVolAtu  := Ascan( aHeaderFre, { |aField| aField[2] = "DT6_QTDVOL" } )
	Local nPPesRea  := Ascan( aHeaderFre, { |aField| aField[2] = "DT6_PESO"   } )
	Local nPPesCub  := Ascan( aHeaderFre, { |aField| aField[2] = "DT6_PESOM3" } )
	Local nPPesCob  := Ascan( aHeaderFre, { |aField| aField[2] = "DT6_PESCOB" } )
	Local nPValMer  := Ascan( aHeaderFre, { |aField| aField[2] = "DT6_VALMER" } )
	Local nPValFre  := Ascan( aHeaderFre, { |aField| aField[2] = "DT6_VALFRE" } )
	Local nPValImp  := Ascan( aHeaderFre, { |aField| aField[2] = "DT6_VALIMP" } )
	Local nPValTot  := Ascan( aHeaderFre, { |aField| aField[2] = "DT6_VALTOT" } )

	DEFAULT aVetWrk := Aclone(oGetFre:aCols)

	For nCnt1 := 1 To Len(aVetWrk)
		If aVetWrk[nCnt1,1] == "LBOK"
			nVolOri += aVetWrk[nCnt1,nPVolOri]
			nVolAtu += aVetWrk[nCnt1,nPVolAtu]
			nPesRea += aVetWrk[nCnt1,nPPesRea]
			nPesCub += aVetWrk[nCnt1,nPPesCub]
			nPesCob += aVetWrk[nCnt1,nPPesCob]
			nValMer += aVetWrk[nCnt1,nPValMer]
			nValFre += aVetWrk[nCnt1,nPValFre]
			nValImp += aVetWrk[nCnt1,nPValImp]
			nValTot += aVetWrk[nCnt1,nPValTot]
		EndIf
	Next nCnt1

Return

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tms200bCmp
@autor		: Eduardo Alberti
@descricao	: Exibe Composição Do Frete
@since		: Sep./2016
@using		: TMSA200B
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Static Function Tms200bCmp(aVetFre)

	Local aArea   := GetArea()
	Local nLinAtu := oGetFre:oBrowse:nAt
	Local aVetTel := {}

	Default aVetFre := {} 	
	
	If ValType(aVetFre[nLinAtu]) == "A" //-- Vetor De Componentes De Frete

		aAdd( aVetTel, { aVetfre[nLinAtu,1,1,6] , aClone(aVetFre[nLinAtu,15]),aClone(aVetFre[nLinAtu,13][1]) }) //-- Inclui Cód Produto e Vetor Do Frete

		SaveInter()
		TmsViewFrt("1",,,,,,, aVetTel )
		RestInter()
		
	EndIf
	
	RestArea(aArea)

Return

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tms200bCon
@autor		: Eduardo Alberti
@descricao	: Visualização Do Contrato Conforme Browse
@since		: Sep./2016
@using		: TMSA200B
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Static Function Tms200bCon(aVetWrk)

	Local aArea    := GetArea()
	Local nLinAtu  := oGetFre:oBrowse:nAt
	Local nPNContr := Ascan( aHeaderFre, { |aField| aField[2] = "DT6_NCONTR" } )
	Local cContrat := ""

	If nPNContr > 0
	
		cContrat := aVetWrk[nLinAtu,nPNContr]
		
		If !Empty(cContrat)

			//-- Posiciona No Contrato
			DbSelectArea("AAM")
			DbSetOrder(1) //-- AAM_FILIAL+AAM_CONTRT
			If MsSeek( FWxFilial("AAM") + cContrat , .F.)
			
				SaveInter()
				FWExecView('','TECA250', MODEL_OPERATION_VIEW, , /*{ || .T. }*/, , ,/*aButtons*/ )
				RestInter()
			Else
				Help('', 1, 'REGNOIS' )
			EndIf			
		EndIf
	EndIf		
	
	RestArea(aArea)

Return

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tms200bPrf
@autor		: Eduardo Alberti
@descricao	: Visualização Do Perfil Do Cliente
@since		: Sep./2016
@using		: TMSA200B
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Static Function Tms200bPrf(aVetWrk)

	Local aArea    := GetArea()
	Local nLinAtu  := oGetFre:oBrowse:nAt
	Local nPCliDev := Ascan( aHeaderFre, { |aField| aField[2] = "DT6_CLIDEV" } )
	Local nPLojDev := Ascan( aHeaderFre, { |aField| aField[2] = "DT6_LOJDEV" } )
	Local cCliDev  := ""
	Local cLojDev  := ""
	
	If nPCliDev > 0 .And. nPLojDev > 0
	
		cCliDev := aVetWrk[nLinAtu,nPCliDev]
		cLojDev := aVetWrk[nLinAtu,nPLojDev]
		
		//-- Posiciona No Perfil Do Cliente
		DbSelectArea('DUO')
		DbSetOrder(1) //-- DUO_FILIAL+DUO_CODCLI+DUO_LOJCLI
		If MsSeek( FWxFilial('DUO') + cCliDev + cLojDev ,.f.)

			SaveInter()
			FWExecView('','TMSA480', MODEL_OPERATION_VIEW, , /*{ || .T. }*/, , ,/*aButtons*/ )
			RestInter()
		Else	
			Help('', 1, 'REGNOIS' )			
		EndIf
	EndIf		

	RestArea(aArea)

Return

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tms200bTab
@autor		: Eduardo Alberti
@descricao	: Visualização Da Tabela Frete/Ajuste
@since		: Sep./2016
@using		: TMSA200B
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Static Function Tms200bTab( aVetWrk, aVetFre )

	Local aArea     := GetArea()
	Local aFrete    := {}
	Local nPCliDev  := Ascan( aHeaderFre, { |aField| aField[2] = "DT6_CLIDEV" } )
	Local nPLojDev  := Ascan( aHeaderFre, { |aField| aField[2] = "DT6_LOJDEV" } )
	Local cCliDev   := ""
	Local cLojDev   := ""
	
	Private nLinAtu := oGetFre:oBrowse:nAt
	Private aVetTst := aClone(aVetFre) //-- Converte Variável Em Private Para Testar Existência Das Posições Para o Vetor aFrete
	
	//-- Determina Vetor De Frete Conforme a Linha Do aCols
	If nLinAtu > 0 .And. Type("aVetTst[nLinAtu,01,01,28,01,02]") == "A"
		
		aFrete   := aVetFre[nLinAtu,01,01,28,01,02] //-- Coordenadas De Localização Do Vetor Gerado pela Rotina TmsCalFret()
		cCliDev  := aVetWrk[nLinAtu,nPCliDev]
		cLojDev  := aVetWrk[nLinAtu,nPLojDev]
		
		SaveInter()
		Tms200bFre( aFrete, cCliDev, cLojDev )
		RestInter()
		
	EndIf

	RestArea(aArea)

Return	
//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tms200bTab
@autor		: Eduardo Alberti
@descricao	: Monta o Grid Dos Componentes De Frete Para Posterior Visualização Da Tabela De Frete Por Componentes
@since		: Sep./2016
@using		: TMSA200B
@review	:
/*/
//-------------------------------------------------------------------------------------------------		 	
Function Tms200bFre( aFrete, cCli, cLoja )

	Local aAreas    := {DDB->(GetArea()),SA1->(GetArea()),SB1->(GetArea()),DUY->(GetArea()),GetArea()}
	Local oDlg      := Nil
	Local oGrd      := Nil
	Local aCoord	  := MsAdvSize(.T.)
	Local lOpc      := .f.
	Local aButtons  := {}
	Local cTitulo   := STR0014 //-- "Cálculo Do Frete"   
	Local aCab      := {}
	Local n1        := 0
	Local cNomCli	:= ""

	Default aFrete  := {}
	Default cCli    := ""
	Default cLoja   := ""

	//-- Remove Tipos 'TF' Do Vetor aFrete
	For n1 := 1 To Len(aFrete)
		If aFrete[n1,03] == 'TF'
			aDel(aFrete,n1)
			aSize(aFrete,Len(aFrete)-1)
		EndIf	
	Next n1	

	//-- Insere Cabeçalho De Campos Do Grid
	aAdd( aCab, RetTitle("DT8_CODPAS")) //-- 01
	aAdd( aCab, RetTitle("DT3_DESCRI")) //-- 02
	aAdd( aCab, RetTitle("DT8_CDRORI")) //-- 03
	aAdd( aCab, RetTitle("DUY_DESCRI")) //-- 04
	aAdd( aCab, RetTitle("DT8_CDRDES")) //-- 05
	aAdd( aCab, RetTitle("DUY_DESCRI")) //-- 06
	aAdd( aCab, RetTitle("DT8_TABFRE")) //-- 07
	aAdd( aCab, RetTitle("DT8_TIPTAB")) //-- 08
	aAdd( aCab, RetTitle("DT8_SEQTAB")) //-- 09
	aAdd( aCab, RetTitle("DT8_CODPRO")) //-- 10
	aAdd( aCab, RetTitle("B1_DESC"   )) //-- 11
	aAdd( aCab, RetTitle("DT6_SERVIC")) //-- 12
	aAdd( aCab, RetTitle("DTC_DESSER")) //-- 13
	aAdd( aCab, RetTitle("A1_COD"    )) //-- 14
	aAdd( aCab, RetTitle("A1_LOJA"   )) //-- 15
	aAdd( aCab, RetTitle("A1_NOME"   )) //-- 16
	aAdd( aCab, RetTitle("DT6_CODNEG")) //-- 17
	aAdd( aCab, RetTitle("DDB_DESCRI")) //-- 18


	//---------------------------------------
	//-- Botoes da barra superior              
	//---------------------------------------
	AAdd(aButtons,{""	,{|| Tms200Tbf( aFrete , oGrd:nAT, oGrd:nColPos ) 	}, STR0008	, STR0009 }) //-- "Tabela Frete / Ajuste" "Tab. Frete"

	//oDlg			:= TDialog():New(000,000,aCoord[6],aCoord[5],OemToAnsi(_cTitulo ),,,,,,,,oMainWnd,.T.)			// Tela Inteira
	oDlg 			:= TDialog():New(000,000,aCoord[6]/1.5,aCoord[5]/1.5,OemToAnsi(cTitulo ),,,,,,,,oMainWnd,.T.) 	// Tela Menor
	oGrd 			:= TWBrowse():New(030,003,oDlg:nClientWidth/2-5,oDlg:nClientHeight/2-45,,aCab,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oGrd:lHScroll	:= .T. //-- Indica se habilita(.T.)/desabilita (.F.) a barra de rolagem horizontal.
	oGrd:lVScroll	:= .T. //-- Indica se habilita(.T.)/desabilita(.F.) a barra de rolagem vertical.
	
	
	//-- Seta Duplo Clique Na Linha
	oGrd:bLDblClick  := { || Tms200Tbf( aFrete , oGrd:nAT, oGrd:nColPos ) }	
	
	oGrd:SetArray(aFrete)
	If ExistFunc('FWPDCanUse') .And. FWPDCanUse(.T.)
		If Len(FwProtectedDataUtil():UsrAccessPDField( __CUSERID, {"A1_NOME"} )) > 0		
			cNomCli := Alltrim( Posicione("SA1", 01, FWxFilial("SA1") + aFrete[oGrd:nAt][19] + aFrete[oGrd:nAt][20] , "A1_NOME"))
		Else				
			cNomCli := Replicate('*',TamSX3('A1_NOME')[1])
		EndIf	
	Else	
		cNomCli := Alltrim( Posicione("SA1", 01, FWxFilial("SA1") + aFrete[oGrd:nAt][19] + aFrete[oGrd:nAt][20] , "A1_NOME"))
	EndIf

	oGrd:bLine := {||{;
	aFrete[oGrd:nAt][03],; 																										//-- 01 - Cód. Componente
	aFrete[oGrd:nAt][01],; 																										//-- 02 - Descrição Componente
	aFrete[oGrd:nAt][07],; 																										//-- 03 - Codigo Da Regiao Origem
	Alltrim( Posicione("DUY", 01, FWxFilial("DUY") + aFrete[oGrd:nAt][07] , "DUY_DESCRI")),; 									//-- 04 - Descrição Da Região Origem
	aFrete[oGrd:nAt][08],; 																										//-- 05 - Codigo Da Regiao Destino
	Alltrim( Posicione("DUY", 01, FWxFilial("DUY") + aFrete[oGrd:nAt][08] , "DUY_DESCRI")),; 									//-- 06 - Descrição Da Região Destino
	aFrete[oGrd:nAt][09],; 																										//-- 07 - Tabela de Frete
	aFrete[oGrd:nAt][10],; 																										//-- 08 - Tipo da Tabela de Frete
	aFrete[oGrd:nAt][11],; 																										//-- 09 - Sequencia da Tabela de Frete
	aFrete[oGrd:nAt][17],; 																										//-- 10 - Cód Produto
	Alltrim( Posicione("SB1", 01, FWxFilial("SB1") + aFrete[oGrd:nAt][17] , "B1_DESC")),; 										//-- 11 - Descrição Do Produto
	aFrete[oGrd:nAt][18],; 																										//-- 12 - Cód Serviço
	Alltrim(Tabela('L4',aFrete[oGrd:nAt][18])),;																				//-- 13 - Descrição Do Serviço	 
	aFrete[oGrd:nAt][19],; 																										//-- 14 - Cód. Cliente	    
	aFrete[oGrd:nAt][20],; 																										//-- 15 - Loja Cliente
	cNomCli,;																													//-- 16 - Nome Cliente
	aFrete[oGrd:nAt][22],; 																										//-- 17 - Cód Negociação
	Alltrim( Posicione("DDB", 01, FWxFilial("DDB") + aFrete[oGrd:nAt][22] , "DDB_DESCRI"))}} 									//-- 18 - Descr. Cód Negociação
	
	Activate MsDialog oDlg On Init EnchoiceBar(oDlg,/*bOk*/ {|| lOpc := .t., oDlg:End()} ,/*bCancel*/ {|| oDlg:End() },/*lMsgDel*/,aButtons,/*nRecno*/,/*cAlias*/,/*lMashups*/,/*lImpCad*/,.T. /*lPadrao*/,.F. /*lHasOk*/,/*lWalkThru*/,/*cProfileID*/)

	
	//-- Formato do vetor aFrete
	//
	//-- aRet[01] = Descricao do componente
	//-- aRet[02] = Valor do componente
	//-- aRet[03] = Codigo do componente
	//-- aRet[04] = Item SD2. Atualizado pelas funcoes que geram o SD2
	//-- aRet[05] = Na cotacao eh gravado o valor do imposto do componente
	//-- aRet[06] = Total do componente ( valor + imposto )
	//-- aRet[07] = Codigo da regiao origem
	//-- aRet[08] = Codigo da regiao destino
	//-- aRet[09] = Tabela de Frete
	//-- aRet[10] = Tipo da Tabela de Frete
	//-- aRet[11] = Sequencia da Tabela de Frete
	//-- aRet[12] = Forca a linha totalizadora para a ultima linha
	//-- aRet[13] = Desconto dado ao valor do componente
	//-- aRet[14] = Acrescimo dado ao valor do componente
	//-- aRet[15] = Indica se o componente foi calculado com o valor minimo. "1"= Sim, "2"= Nao
	//-- aRet[16] = Indica o criterio de calculo do componente - Peso, Volume, Quantidade
	//-- aRet[17] = Produto
	//-- aRet[18] = Codigo do Serviço
	//-- aRet[19] = Codigo do Cliente
	//-- aRet[20] = Loja do cliente
	//-- aRet[21] = Percentual de Rateio do Componente
	//-- aRet[22] = Codigo Negociacao
	//-- aRet[23] = Indica se o componente é obrigatorio	

	AEval(aAreas,{|x,y| RestArea(x) })

Return	

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tms200Tbf
@autor		: Eduardo Alberti
@descricao	: Chama Rotina De Visualização da Tabela de Frete
@since		: Oct./2016
@using		: TMSA200B
@review	:
/*/
//-------------------------------------------------------------------------------------------------	
Static Function Tms200Tbf( aFrete , nLin, nCol )

	Local aArea    := GetArea()
	Local cTabFre  := aFrete[nLin,09]
	Local cTipTab  := aFrete[nLin,10]
	Local cSeqTab  := aFrete[nLin,11]
	Local cCdrOri  := aFrete[nLin,07]
	Local cCdrCal  := aFrete[nLin,08]
	Local cServic  := aFrete[nLin,18]
	Local cCodPro  := aFrete[nLin,17]
	Local cCliDev  := aFrete[nLin,19]
	Local cLojDev  := aFrete[nLin,20]
	Local cCodNeg  := aFrete[nLin,22]

	SaveInter()		
	TmsVisTbFre(cTabFre, cTipTab, cSeqTab, cCdrOri, cCdrCal, cServic, cCodPro, cCliDev, cLojDev, cCodNeg )
	RestInter()

	RestArea(aArea)
	
Return()	

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tms200bDoc
@autor		: Eduardo Alberti
@descricao	: Visualização Dos Documentos Do Cliente
@since		: Oct./2016
@using		: TMSA200B
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Static Function Tms200bDoc( aVetFre )

	Local aAreas    := {DTC->(GetArea()),GetArea()}
	Local cNumNfc   := ""
	Local cSerNfc   := ""
	Local cCliRem   := ""
	Local cLojRem   := ""
	
	Default aVetFre := {}
	
	Private nLinAtu := oGetFre:oBrowse:nAt
	Private aVetTst := aClone(aVetFre) //-- Converte Variável Em Private Para Testar Existência Das Posições Para o Vetor aFrete

	//-- Determina Vetor De Frete Conforme a Linha Do aCols
	If nLinAtu > 0 .And. Type("aVetTst[nLinAtu,13,1]") == "A" .And. Type("aVetTst[nLinAtu,1,1,29]") == "A"
	
		cNumNfc   := aVetFre[nLinAtu,1,1,29,1,1]
		cSerNfc   := aVetFre[nLinAtu,1,1,29,1,2]
		cCliRem   := aVetFre[nLinAtu,13,1,16]
		cLojRem   := aVetFre[nLinAtu,13,1,17]

		DbSelectArea("DTC")
		DTC->(DbSetOrder(2))
		If DTC->( MsSeek( FWxFilial('DTC')+ cNumNFC + cSerNFC + cCliRem + cLojRem ))
			SaveInter()
			TmsA050Mnt('DTC',DTC->(Recno()),2)
			RestInter()
		EndIf
	EndIf

	AEval(aAreas,{|x,y| RestArea(x) })

Return()

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tms200bVld
@autor		: Eduardo Alberti
@descricao	: Validação Da Tela
@since		: Oct./2016
@using		: TMSA200B
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Function Tms200bVld(aVetWrk)

	Local lRet := .T.

	DEFAULT aVetWrk := {}

	//-- Se o lote é baseado em rateio e possui pelo menos uma linha desmarcada e possui pelo menos uma linha marcada
	//-- não pode prosseguir pois lotes baseados em rateio devem ser calculados por completo ou não calculados
	If TMSLRateio( DTP->DTP_FILORI, DTP->DTP_LOTNFC ) .And. AScan(oGetFre:aCols,{|x| x[1] == "LBNO"}) > 0 .And. AScan(oGetFre:aCols,{|x| x[1] == "LBOK"}) > 0
		Help(" ",1,"TMSA200B1") //-- "Lote baseado em rateio não pode ter exclusão parcial de ítens." //-- Help Incluído pelo Projeto 000043 (Valdemar)
		lRet := .F.
	EndIf


Return lRet
//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tmsa200bDc
@autor		: Eduardo Alberti
@descricao	: Gera Descrição De Campos Do aCols
@since		: Sep./2016
@using		: TMSA200B
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Function Tmsa200bDc( cCampo )

	Local cDesc    := ""
	Local aAreas   := {DUY->(GetArea()),GetArea()}

	Default cCampo := ""

	If "DT6_CDRORI" = cCampo

		DbselectArea("DUY")
		DbSetOrder(1) //-- DUY_FILIAL+DUY_GRPVEN
		MsSeek( FWxFilial("DUY") + aPvw[nPosPvw,13,01,22] , .f. )
	
		cDesc := Alltrim( DUY->DUY_DESCRI ) + " - " + DUY->DUY_EST
	
	ElseIf "DT6_CDRCAL" = cCampo

		DbselectArea("DUY")
		DbSetOrder(1) //-- DUY_FILIAL+DUY_GRPVEN
		MsSeek( FWxFilial("DUY") + aPvw[nPosPvw,13,01,23] , .f. )
	
		cDesc := Alltrim( DUY->DUY_DESCRI ) + " - " + DUY->DUY_EST
		
	ElseIf "DT6_CODNEG" = cCampo

		DbselectArea("DDB")
		DbSetOrder(1) //-- DDB_FILIAL+DDB_CODNEG
		MsSeek( FWxFilial("DDB") + aPvw[nPosPvw,13,01,24] , .f. )
	
		cDesc := Alltrim( DDB->DDB_DESCRI )

	ElseIf "DT6_SERVIC" = cCampo
	
		cDesc := Tabela('L4',aPvw[nPosPvw,13,01,25])
	
	EndIf

	AEval(aAreas,{|x,y| RestArea(x) })

Return(cDesc)
