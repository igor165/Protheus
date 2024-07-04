#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEA470.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ GPEA470  ณ Autor ณ Valdeci Lira                    ณ Data ณ 05/10/07 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Cadastro dos Criterios de acumulacao                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Generico                                                             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ              ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณProgramador ณ Data   ณ BOPS/FNC       ณ  Motivo da Alteracao                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณNatie       ณ10/06/08ณ                ณInclusao de validacao RCH_QTDSEQ          ณฑฑ
ฑฑณSilvia Tag. ณ03/10/08ณ155370          ณAjuste para utilizacao na rotina na Argen-ณฑฑ
ฑฑณ            ณ        ณ                ณtina modelo 1                             ณฑฑ
ฑฑณKelly       ณ24/11/08ณ00000005530/2008ณAjuste para utilizacao em Venezuela e     ณฑฑ
ฑฑณ            ณ        ณ                ณColombia.                                 ณฑฑ
ฑฑณRogerio R.  ณ05/05/09ณ00000008714/2009ณCorrecao no erro na validacao ao excluir  ณฑฑ
ฑฑณAdemar Jr.  ณ23/01209ณ00000029430/2009ณTratamento pra localizacao do Peru.       ณฑฑ
ฑฑณChristiane Vณ25/10/11ณ00000026587/2011ณValida็ใo da tabela RCH na exclusใo.      ณฑฑ
ฑฑณAldo Marini ณ24/04/12ณP12-REQ199      ณRecriacao de Acumuladores                 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿/*/
Function GPEA470()
	Local bValidAlt := {|| f470VldAlt() }
	Private cCadastro := OemToAnsi(STR0001)	
	
   	If (MV_MODFOL == "2") .Or. cPaisLoc $ "ARG/VEN/COL/PER"		
		AxCadastro("RG9", cCadastro, "f470VldDel()", "f470VldAlt()", NIL, bValidAlt )
	Else
		Help("",1,"NAO_DISPONIVEL" )
	EndIf
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณf470VldDel    บAutor  ณValdeci Lira        บ Data ณ  18/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza os relacionamentos antes de deletar o RG9_CODCRI       บฑฑ
ฑฑบ          ณ                                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function f470VldDel()    
	Local lDelReg
	Local aAreas := {}
    Local nAreas
 
	//RG7 - Cadastro de acumuladores
	aAdd(aAreas, Array(4))
	nAreas := Len(aAreas)
	aAreas[nAreas, 1] := RG7->(GetArea())
	aAreas[nAreas, 2] := {"RG7_FILIAL", "RG7_CODCRI"}
	aAreas[nAreas, 3] := RetOrdem("RG7", "RG7_FILIAL+RG7_CODCRI", .T.)
	
	//RG6 - Padrao de periodos
	aAdd(aAreas, Array(4))
	nAreas := Len( aAreas )
	aAreas[nAreas, 1] := RG6->( GetArea() )
	aAreas[nAreas, 2] := {"RG6_FILIAL", "RG6_CRITER"}
	aAreas[nAreas, 3] := RetOrdem("RG6", "RG6_FILIAL+RG6_CRITER", .T.)
	aAreas[nAreas, 4] := {"='@'" ," LIKE '%@%'"}
	
	//SRM - Roteiro de Calculo 
	If cPaisLoc $ "MEX|DOM|COS"
		aAdd(aAreas, Array(4))
		nAreas := Len(aAreas)
		aAreas[nAreas, 1] := SRM->(GetArea())
		aAreas[nAreas, 2] := {"RM_FILIAL", "RM_CODCRI"}
		aAreas[nAreas, 3] := RetOrdem("SRM", "RM_FILIAL+RM_CODCRI", .T.)
		
		aAdd(aAreas, Array(4))
		nAreas := Len(aAreas)
		aAreas[nAreas, 1] := RCH->(GetArea())
		aAreas[nAreas, 2] := {"RCH_FILIAL", "RCH_CRITER"}
		aAreas[nAreas, 3] := RetOrdem("RCH", "RCH_FILIAL+RCH_PROCES+RCH_PER+RCH_NUMPAG+RCH_ROTEIR", .T.)		
	EndIf
	
	// verificar se a tabela nao possui registros relacionados //
	lDelReg := ChkDelRegs(	"RG9"				,;	// 1-Alias do Arquivo Principal
							RG9->( Recno() )	,;	// 2-Registro do Arquivo Principal
							5					,;	// 3-Opcao para a AxDeleta
							xFilial("RG9")		,;	// 4-Filial do Arquivo principal para Delecao
							RG9->RG9_CODCRI 	,;	// 5-Chave do Arquivo Principal para Delecao
							aAreas 				,;	// 6-Array contendo informacoes dos arquivos a serem pesquisados
							NIL					,;	// 7-Mensagem para MsgYesNo
							NIL					,;	// 8-Titulo do Log de Delecao
							NIL					,;	// 9-Mensagem para o corpo do Log
							.F.				 	,;	// 10-Se executa AxDeleta
							.T.     			,;	// 11-Se deve Mostrar o Log
							NIL					,;	// 12-Array com o Log de Exclusao
							NIL				 	,;	// 13-Array com o Titulo do Log
							NIL					,;	// 14-Bloco para Posicionamento no Arquivo
							NIL					,;	// 15-Bloco para a Condicao While
							NIL					,;	// 16-Bloco para Skip/Loop no While
							.T.					,;	// 17-Verifica os Relacionamentos no SX9
							NIL					,;	// 18-Alias que nao deverao ser Verificados no SX9
							NIL				 	 ;	// 19-Se faz uma checagem soft
					     )	
Return lDelReg        

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณf470VldQtdSeq บAutor  ณNatie               บ Data ณ  05/06/08   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPermite a inclusao de no maximo 13 sequencias de acumulacao     บฑฑ
ฑฑบ          ณ                                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function  f470VldQtdSeq()
	Local lRetOk	:= .T. 
	Local nConteudo := &(ReadVar())
	
	If nConteudo > 13 
		MsgAlert( OemToAnsi(STR0003) , OemToAnsi( STR0002 ) ) // ""Sao permitidas no maximo 13 sequencias."#"Aviso "
		lRetOk := .F.
	Endif 
Return(lRetOk) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณf470VldAlt    บAutor  ณIP Rh Inovacao      บ Data ณ  23/04/12   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida a opcao de "Alterar" para nao permitir quando houver um  บฑฑ
ฑฑบ          ณcriterio utilizado em meses ja fechados                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GPEA470                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function f470VldAlt()

Local aArea		:= GetArea()
Local cWhere	:= ""
Local cAliasQry	:= GetNextAlias()	
Local lRetOk 	:= .T.

If ALTERA

	cWhere := "% RCH.RCH_DTFECH <> '" + Space(8) + "' AND RCH.RCH_CRITER LIKE '%" + RG9->RG9_CODCRI + "%' %"
	BeginSql alias cAliasQry
	   	SELECT R_E_C_N_O_
		FROM %table:RCH% RCH
		WHERE %exp:cWhere% and RCH.%notDel%
	EndSql
	
	If (cAliasQry)->(!Eof())
		MsgAlert( OemToAnsi(STR0004) , OemToAnsi( STR0002 ) ) // "Crit้rio de acumula็ใo foi utilizado em perํodos jแ fechados, nใo sendo possํvel sua altera็ใo. Por favor, selecione outro crit้rio ou inclua um novo." ### "Aviso "
		lRetOk := .F.
	Endif
	(cAliasQry)->(dbCloseArea())

Endif

RestArea(aArea)

Return lRetOK