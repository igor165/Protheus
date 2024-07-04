#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEM035.CH"

Static cChargeTab	:= ''
Static aChargeFlds	:= {}
Static cPergAux		:= ''
Static cOpcoes		:= ''
Static cVersEnvio	:= "2.2"
Static aEfd			:= If( cPaisLoc == 'BRA', If(Findfunction("fEFDSocial"), fEFDSocial(), {.F.,.F.,.F.,.F.,.F.}), {.F.,.F.,.F.,.F.,.F.} )
Static lIntTAF		:= SuperGetMv("MV_RHTAF",, .F.) == .T. //Integracao com TAF
Static cVersGPE		:= ""

/**
�����������������������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������������ͻ��
���Programa  �GPEM035     �Autor  �Gustavo M.		   � Data �  27/05/14                         ���
�������������������������������������������������������������������������������������������������͹��
���Desc.     �Processamento das inconsist�ncias do e-social			                        	  ���
�������������������������������������������������������������������������������������������������͹��
���Uso       �GPEM035 			                                                                  ���
�������������������������������������������������������������������������������������������������Ĵ��
���                ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL                               ���
�������������������������������������������������������������������������������������������������Ĵ��
���Analista     � Data     � FNC/Requisito  � Chamado �Motivo da Alteracao                        ���
�������������������������������������������������������������������������������������������������Ĵ��
���Claudinei S. |10/12/2015|                |TU2544   �Disponibiliza��o da Rotina para a P12.     ���
���Marcia Moura |23/03/2016|                |TU2544   �FOnte recompilado apenas para subir v12.1.7���
���Marcia Moura |04/08/2016|                |TUWITW   �Correcoes na consistencia CTT e no botao   ���
���             |          |                |         �de outras acoes                            ���
���Marcos Cout  |12/06/2017|DRHESOCP-398    |         �Realizar ajustes na fun��o que valida os   ���
���             |          |                |         �campos do eSocial                          ���
���Oswaldo L    |14/06/2017|                |DRHESOCP �Ajuste erro query ao nao informar parametro���
���             |          |                |426      � nro 8(sit folha) no gpm035A               ���
���Oswaldo L    |04/07/2017|                |DRHESOCP �Remover tratativas de campos que passaram  ���
���             |          |                |552      � "nao utilizados" no SX3                   ���
���Marcos Cout  |01/08/2017|DRHESOCP-706              |Retirado do controle do menor aprendiz,pois���
���             |          |                          | o  campo NPROJ14 deixou de ser obrigatorio���
���Marcos Cout  |19/09/2017|DRHESOCP-456              |Realizado a tratativa para colocar um campo���
���             |          |                          |De/Ate para melhorar a performance na con_ ���
���             |          |                          |sist�ncia das tabelas do eSocial           ���
���Marcos Cout  |20/09/2017|DRHESOCP-456              |Realizado ajustes para que as perguntas add���
���             |          |                          |batessem com a ordem de perguntas vindas do���
���             |          |                          |ATUSX ou do AJSXGPE                        ���
���Cec�lia C.   |08/11/2017| DRHESOCP-1749  |         |Inclus�o de filtro para situa��o de funcio-���
���             |          |                |         |n�rios.                                    ���
���Oswaldo L    |22/11/2017| DRHPAG-8145              |Ajuste chamadas funcoes em relacao aos Para���
���             |          |                          |metros da tela de op��es(op��o S e V).     ���
��|Eduardo. Vic.|04/12/2017|DRHESOCP-2226   |        |Tratativa para valida��o de campo Tabelas   |��
���Marcos Cout  |06/12/2017| DRHESOCP-2227  |         |Realizado ajustes na valida��o do estagi�_ |��
���             |          |                |         |rio e do turno de trabalhado. Realizado    |��
���             |          |                |         |ajustes na carga e na consistencia S-1050  |��
���Marcos Cout  |20/12/2017| DRHESOCP-2449  |         |Realizado a consist�ncia da nova maneira de|��
���             |          | DRHESOCP-2450  |         |conhecer obras proprias ou empreitada total|��
���             |          | DRHESOCP-2452  |         |CTT_TPLOT = "01" e CTT_TIPO2 = "4- CNO"    |��
���Marcos Cout  |22/12/2017| DRHESOCP-2457  |         |Realizado ajustes para gravar o hist�rico  |��
���             |          |                |         |de altera��es dentro da SR9                |��
���Eduardo Vic  |27/12/2017| DRHESOCP-2456  |         |Inclus�o de novos campos na query,para tra-|��
���             |          |                |         |tativa de campos de verbas em novas valida-|��
���             |          |                |         |��es										  |��
���Jo�o Balbino |28/12/2017|MPRIMESP-13029  |         |Realizado ajustes para que valide as infor-|��
���             |          |                |         |ma��es corretamente para os trabladores.   |��
���Cec�lia Carv |08/01/2018|DRHESOCP-2682   |         |Ajuste para gera��o de contrato intermiten-|��
���             |          |                |         |te - evento S-2200.                        |��
���             |12/01/2018|DRHESOCP-2793   |         |Altera��o da descri��o 'Par�metro 14' para |��
���             |          |                |         |'Tabela S037' ou 'Tabela S038'.            |��
���Marcos Cout  |06/02/2018| DRHESOCP-2993  |         |Realizando ajustes para que o registro in_ |��
���             |          |                |         |consistente dos dependentes seja carregado |��
���             |          |                |         |com sucesso quando solicitado              |��
���Cec�lia Carv |26/02/2018| DRHESOCP-2894  |         |Ajuste para consistir campos do cadastro de|��
���             |          |                |         |fun��es referentes aos �rg�os p�blicos.    |��
�������������������������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������������������
*/
Function GPEM035()

Local aTitle	 	:= {}
Local bAuxProce		:= {|oSelf| fAuxPro(,,,oSelf)}
Local cTitulo		:= STR0001 // "Geracao das inconsistoncias do e-social"
Private cPerg:="GPM035"

Iif( FindFunction("fVersEsoc"), fVersEsoc( "S2200", .T., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio, @cVersGPE ),)

If Empty(cVersGPE)
	cVersGPE := cVersEnvio
EndIf

If lIntTAF
	/*	Esta rotina deve ser utilizada antes da Carga Inicial, com o objetivo de auxiliar no
	saneamento de dados, sendo assim o par�metro MV_RHTAF deve estar igual a .F., caso o
	par�metro esteja como .T. importante ressaltar que a corre��o das tabelas feita nesta
	rotina ser�o v�lidas apenas para o SIGAGPE e n�o ser�o transmitidas para o SIGATAF	*/
	Help( ,, 'HELP',,OemToAnsi(STR0192)+" "+OemToAnsi(STR0193)+" "+OemToAnsi(STR0194)+" "+OemToAnsi(STR0195) , 1, 0 )	//"Tipo de Lota��o Inv�lida"
EndIf

Aadd(aTitle, cTitulo)
oProcess := tNewProcess():New(cPerg, cTitulo, bAuxProce, STR0002 , cPerg,,,,, .T., .F.)   // "Essa rotina ira processar as inconsistoncias do e-social, permitindo a manutecao das mesmas."

Return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fTrataLog   �Autor  �Gustavo M.		   � Data �  27/05/14 ���
�������������������������������������������������������������������������͹��
���Desc.     �Trata o log para demonstracao na tela.					  ���
�������������������������������������������������������������������������͹��
���Uso       �GPEM035				                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function fTrataLog(aLog)

Local nX 			:= 1
Local nA 			:= 0
Local oDlgConsulta 	:= Nil
Local aSize			:= FWGetDialogSize( oMainWnd )
Local cCodVer 		:= ''
Local cDesc 		:= ''
Local cProce		:= ''
Local nSeta 		:= 0
Local nSeta1 		:= 0
Local cErro 		:= ''
Local nFim  		:= 0
Local nAte  		:= 0
Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), {.T.,.F.}) //[1] Acesso; [2]Ofusca
Local lOfuscaNom	:= .F.
Local aFldOfusca	:= {}

Private oBrw := Nil
Private aDados35:= {}
Private aLogAux := aClone(aLog)

	If Len(aLog) > 0
		aSRA:=fCamposSRA()
	EndIf

	If aOfusca[2]
		aFldOfusca := FwProtectedDataUtil():UsrNoAccessFieldsInList( {'RA_NOME'} ) // CAMPOS SEM ACESSO
		lOfuscaNom := Len(aFldOfusca) > 0
	EndIf

	For nX:=1 to Len(aLog)
		If "Verba:" $ aLog[nX]
			cProce := STR0005  // "Rubrica"
			nSeta  := At('->',aLog[nX])
			cCodVer:= SubStr(aLog[nX],8,TamSx3('RV_FILIAL')[1] + TamSx3('RV_COD')[1])
			nSeta  := At('->',aLog[nX])
			cDesc  := SubStr( aLog[nX],nSeta+3)
			nA++
			AAdd(aDados35,{cProce,cCodVer,cDesc})
		ElseIf "RV_" $ aLog[nX]
			nFim:= At(Space(1),aLog[nX])
			nCol:= At(' - ',aLog[nX])
			AAdd(aDados35[nA],Alltrim(SubStr(aLog[nX],nFim,nCol-nFim)))
		ElseIf "Fun��o"  $ aLog[nX] .And. ((nSeta  := At('->',aLog[nX]) )> 0 )
			cProce := STR0040 // "Fun��o"
			cCodVer:= SubStr(aLog[nX],8,TamSx3('RJ_FILIAL')[1]+ TamSx3('RJ_FUNCAO')[1])
			cDesc  := SubStr( aLog[nX],nSeta+3)
			nA++
			AAdd(aDados35,{cProce,cCodVer,cDesc })
		ElseIf "RJ_" $ aLog[nX]
			nFim:= At(Space(1),aLog[nX])
			AAdd(aDados35[nA],Alltrim(SubStr(aLog[nX],1,nFim)))
		ElseIf "Turno " $ aLog[nX]
			cProce := "Turno"  // "Turno"
			nSeta  := At('->',aLog[nX])
			cCodVer:= SubStr(aLog[nX],11,TamSx3('R6_FILIAL')[1] + TamSx3('R6_TURNO')[1])
			nSeta  := At('--',aLog[nX])
			cDesc  := SubStr( aLog[nX],nSeta+2)
			nA++
			AAdd(aDados35,{cProce,cCodVer,cDesc})
		ElseIf "R6_" $ aLog[nX]
			nFim:= At(Space(1),aLog[nX])
			nCol:= At('Mot.:',aLog[nX])
			AAdd(aDados35[nA],Alltrim(SubStr(aLog[nX],1,nFim)))
		ElseIf "Centro de Custo" $ aLog[nX] .And. ((nSeta  := At('->',aLog[nX]) )> 0 )
			cProce := STR0006  // "Centro de Custo"
			cCodVer:= SubStr(aLog[nX],19,TamSx3('CTT_FILIAL')[1]+ TamSx3('CTT_CUSTO')[1])
			cDesc  := SubStr( aLog[nX],nSeta+3)
			If "CTT_" $ aLog[nX+1] .And. aScan(aDados35,{|x|x[1]+x[2]=cProce+cCodVer}) == 0
				nA++
				AAdd(aDados35,{cProce,cCodVer,cDesc })
			EndIf
		Elseif "CTT_" $ aLog[nX]
			nFim:= At(Space(1),aLog[nX])
			AAdd(aDados35[nA],Alltrim(SubStr(aLog[nX],1,nFim)))
		ElseIf "Filial/Turno/Semana/Dia"  $ aLog[nX] .And. ((nSeta  := At('->',aLog[nX]) )> 0 )
			cProce := STR0223 // "Hor�rios e Regras"
			nSeta  := At('--',aLog[nX])
			cCodVer:= SubStr(aLog[nX],30,TamSx3('PJ_FILIAL')[1]+ TamSx3('PJ_TURNO')[1] + TamSx3('PJ_SEMANA')[1] + TamSx3('PJ_DIA')[1])
			nSeta  := At('--',aLog[nX])
			cDesc  := SubStr( aLog[nX],nSeta+2)
			nA++
			AAdd(aDados35,{cProce,cCodVer,cDesc})
			While !Empty(aLog[nX]) .And. nX <> Len(aLog)
				If "PJ_" $ aLog[nX]
					nFim:= At(Space(1),aLog[nX])
					AAdd(aDados35[nA],Alltrim(SubStr(aLog[nX],1,nFim)))
				Endif
				nX++
			EndDo
		ElseIf "Matr�cula" $ aLog[nX]
			cProce := STR0008  // "Trabalhador"
			nFim   := At("Filial:",aLog[nX])
			cCodVer:= SubStr(aLog[nX],nFim+8,TamSx3('RA_FILIAL')[1])
			nFim   := At("Matr�cula:",aLog[nX])
			cCodVer:= cCodVer+SubStr( aLog[nX],nFim+11,6)
			dbSelectArea('SRA')
			dbSeek(cCodVer)
			cDesc := If(lOfuscaNom,Replicate('*',15),SRA->RA_NOME)
			nA++
			AAdd(aDados35,{cProce,cCodVer,cDesc})
			While !Empty(aLog[nX]) .And. nX <> Len(aLog)
				If "RA_" $ aLog[nX] .Or. "RB_" $ aLog[nX] .Or. "RBW_" $ aLog[nX] .Or. "RS9_" $ aLog[nX]
					cCampo := rtrim(substr(aLog[Nx],1,At(" - ",aLog[Nx])))
					AAdd(aDados35[nA],cCampo)
				ElseIf "tabela RS9" $ aLog[nX]
					cCampo := "tabela RS9"
					AAdd(aDados35[nA],cCampo)
				EndIf
				nX++
			EndDo
		ElseIf "Sindicato"  $ aLog[nX] .And. ((nSeta  := At('->',aLog[nX]) )> 0 )
			cProce := STR0197 // "Sindicato"
			cCodVer:= SubStr(aLog[nX],10,TamSx3('RCE_FILIAL')[1]+ TamSx3('RCE_CODIGO')[1])
			cDesc  := SubStr( aLog[nX],nSeta+3)
			nA++
			AAdd(aDados35,{cProce,cCodVer,cDesc })
		Elseif "RCE_" $ aLog[nX]
			nFim:= At(Space(1),aLog[nX])
			AAdd(aDados35[nA],Alltrim(SubStr(aLog[nX],1,nFim)))

		Elseif "Estabelecimento\Obra:" $ aLog[nX] .And. ((nSeta  := At(':',aLog[nX]) )> 0 )
			nFim   := At("Estabelecimento\Obra:",aLog[nX])
			cCodVer:= SubStr(aLog[nX],nFim+22,TamSx3('RCE_FILIAL')[1]+TamSx3('CTT_CUSTO')[1])
			cProce := STR0006  // "Centro de Custo"
			While !Empty(aLog[nX]) .And. nX <> Len(aLog)
				If "Tipo do Ponto" $ aLog[nX]
					cDesc	:= "Tabela S119 - Tipo do Ponto"
					nA++
					AAdd(aDados35,{cProce,cCodVer,cDesc})
					nFim:= At(Space(1),aLog[nX])
					AAdd(aDados35[nA],Alltrim(SubStr(aLog[nX],1,nFim)))
				ElseIf "Contrata Aprendiz" $ aLog[nX]
					cDesc  := "Tabela S119 - Contrata Aprendiz"
					nA++
					AAdd(aDados35,{cProce,cCodVer,cDesc})
					nFim:= At(Space(1),aLog[nX])
					AAdd(aDados35[nA],Alltrim(SubStr(aLog[nX],1,nFim)))
				ElseIf "Processo Aprendiz" $ aLog[nX]
					cDesc  := "Tabela S119 - N�mero do Processo Aprendiz"
					nA++
					AAdd(aDados35,{cProce,cCodVer,cDesc})
					nFim:= At(Space(1),aLog[nX])
					AAdd(aDados35[nA],Alltrim(SubStr(aLog[nX],1,nFim)))
				ElseIf "Tipo de Entidade" $ aLog[nX]
					cDesc  := "Tabela S119 - Tipo de Entidade Educativa"
					nA++
					AAdd(aDados35,{cProce,cCodVer,cDesc})
					nFim:= At(Space(1),aLog[nX])
					AAdd(aDados35[nA],Alltrim(SubStr(aLog[nX],1,nFim)))
				ElseIf "Campo Entidade Educativa" $ aLog[nX]
					cDesc  := "Tabela S120 - Entidade Educativa"
					nA++
					AAdd(aDados35,{cProce,cCodVer,cDesc})
					nFim:= At(Space(1),aLog[nX])
					AAdd(aDados35[nA],Alltrim(SubStr(aLog[nX],1,nFim)))
				EndIf
				nX++
			EndDo
		Elseif "Filial:" $ aLog[nX] .And. ((nSeta  := At(':',aLog[nX]) )> 0 )
			nFim   := At("Filial:",aLog[nX])
			cCodVer:= SubStr(aLog[nX],nFim+8,TamSx3('CTT_FILIAL')[1])
			cProce := STR0086  // "Filial"
			While !Empty(aLog[nX]) .And. nX <> Len(aLog)
				If "C�digo CNAE" $ aLog[nX] .And. ((nSeta  := At('-',aLog[nX]) )> 0 )
					cDesc  := "SIGAMAT - SIGACFG - " + SubStr( aLog[nX],nSeta+2,21)
					nA++
					AAdd(aDados35,{cProce,cCodVer,cDesc})
					nFim:= At(Space(1),aLog[nX])
					AAdd(aDados35[nA],Alltrim(SubStr(aLog[nX],1,nFim)))
				ElseIf "Tabela S037" $ aLog[nX] .And. ((nSeta  := At('-',aLog[nX]) )> 0 )
					cDesc  := "Tabela S037 - " + SubStr( aLog[nX],nSeta+2,36)
					nA++
					AAdd(aDados35,{cProce,cCodVer,cDesc})
					nFim:= At(Space(1),aLog[nX])
					AAdd(aDados35[nA],Alltrim(SubStr(aLog[nX],1,nFim)))
				ElseIf "Tabela S038" $ aLog[nX] .And. ((nSeta  := At('-',aLog[nX]) )> 0 )
					cDesc  := "Tabela S038 - " + SubStr( aLog[nX],nSeta+2,36)
					nA++
					AAdd(aDados35,{cProce,cCodVer,cDesc})
					nFim:= At(Space(1),aLog[nX])
					AAdd(aDados35[nA],Alltrim(SubStr(aLog[nX],1,nFim)))
				ElseIf "Tipo do Ponto" $ aLog[nX]
					cDesc  := "Tabela S119 - Tipo do Ponto"
					nA++
					AAdd(aDados35,{cProce,cCodVer,cDesc})
					nFim:= At(Space(1),aLog[nX])
					AAdd(aDados35[nA],Alltrim(SubStr(aLog[nX],1,nFim)))
				ElseIf "Contrata Aprendiz" $ aLog[nX]
					cDesc  := "Tabela S119 - Contrata Aprendiz"
					nA++
					AAdd(aDados35,{cProce,cCodVer,cDesc})
					nFim:= At(Space(1),aLog[nX])
					AAdd(aDados35[nA],Alltrim(SubStr(aLog[nX],1,nFim)))
				ElseIf "Processo Aprendiz" $ aLog[nX]
					cDesc  := "Tabela S119 - N�mero do Processo Aprendiz"
					nA++
					AAdd(aDados35,{cProce,cCodVer,cDesc})
					nFim:= At(Space(1),aLog[nX])
					AAdd(aDados35[nA],Alltrim(SubStr(aLog[nX],1,nFim)))
				ElseIf "Tipo de Entidade" $ aLog[nX]
					cDesc  := "Tabela S119 - Tipo de Entidade Educativa"
					nA++
					AAdd(aDados35,{cProce,cCodVer,cDesc})
					nFim:= At(Space(1),aLog[nX])
					AAdd(aDados35[nA],Alltrim(SubStr(aLog[nX],1,nFim)))
				ElseIf "Campo Entidade Educativa" $ aLog[nX]
					cDesc  := "Tabela S120 - Entidade Educativa"
					nA++
					AAdd(aDados35,{cProce,cCodVer,cDesc})
					nFim:= At(Space(1),aLog[nX])
					AAdd(aDados35[nA],Alltrim(SubStr(aLog[nX],1,nFim)))
				ElseIf "A Empresa foi marcada" $ aLog[nX]
					cDesc  := "Tabela S119 - Contrata PCD"
					nA++
					AAdd(aDados35,{cProce,cCodVer,cDesc})
					nFim:= At(Space(1),aLog[nX])
					AAdd(aDados35[nA],Alltrim(SubStr(aLog[nX],1,nFim)))
				EndIf
				nX++
			EndDo
		EndIf
	Next

	If Empty(aDados35)
		Alert(STR0027)
		Return
	EndIf

	DEFINE DIALOG oDlgConsulta TITLE OemToAnsi(STR0188) FROM aSize[1],aSize[2] TO aSize[3]-100,aSize[4]-100 PIXEL	 //"Consistencia de Campos Cadastrais - Leiaute eSocial"
	//-----------------------------------------------------
	// Constr�i o browse para exibi��o dos dados
	DEFINE FWFORMBROWSE oBrw DATA ARRAY ARRAY aDados35 LINE BEGIN 1 OF oDlgConsulta

	ADD COLUMN oColumns DATA &("{ || aDados35[oBrw:At()][1] }") TITLE STR0010	SIZE 30 PICTURE "@!" OF oBrw
	ADD COLUMN oColumns DATA &("{ || aDados35[oBrw:At()][2] }") TITLE STR0011	SIZE 30 PICTURE "@!" OF oBrw
	ADD COLUMN oColumns DATA &("{ || aDados35[oBrw:At()][3] }") TITLE STR0012	SIZE 30 PICTURE '' OF oBrw
	ADD COLUMN oColumns DATA &("{ || '" + STR0013+"' }") TITLE " "	SIZE 30 PICTURE '' OF oBrw

	//Adiciona o Bot�es de a��o
	ADD Button oBtLegend Title STR0014 	Action "PrepView(aDados35[oBrw:At()])"   OPERATION MODEL_OPERATION_UPDATE Of oBrw  // "Atualizar"
	ADD Button oBtLegend Title STR0019	Action "fFiltraFunc(oBrw)"				 OPERATION MODEL_OPERATION_UPDATE Of oBrw  // "Filtra Func."
	ADD Button oBtLegend Title STR0020	Action "fFiltraCC(oBrw)" 				 OPERATION MODEL_OPERATION_UPDATE Of oBrw  // "Filtra CC"
	ADD Button oBtLegend Title STR0022  Action "fLimpFiltr(oBrw)" 				 OPERATION MODEL_OPERATION_UPDATE Of oBrw  // "Limpa Filtro"

	ACTIVATE FWFORMBROWSE oBrw

	@ aSize[1]+22,aSize[2]+180 BUTTON oBtnMarcTod	PROMPT OemToAnsi( STR0021 )		SIZE 65,15 OF oDlgConsulta	PIXEL ACTION ( fImprIncon(oBrw,aLogAux)  )// "Impr. Incons."


	ACTIVATE DIALOG oDlgConsulta CENTERED

	oBrw:DeActivate()
	If Type("aDados") <> "U"
		aSize(aDados35,0)
		aDados35 := Nil
	EndIf
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PrepView    �Autor  �Gustavo M.		   � Data �  27/05/14 ���
�������������������������������������������������������������������������͹��
���Desc.     �Prepara a view de acordo com o log.						  ���
�������������������������������������������������������������������������͹��
���Uso       �GPEM035			                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PrepView( aInfos )

Local cTab 		:= ''
Local aAux 		:= {}
Local nZ   		:= 0
Local cTitulo 	:= ''
Local cFilial 	:= ''
Local nPosfil 	:= 0
Local nI 		:= 0
Local nPosDep	:= 0
Local nPosRS9	:= 0
Local lIncons	:= .F.
Local lDepend	:= .F.
Local cFilAjst	:= ""
Local aMemoria	:= {}
Local nX		:= 1
Local nPosItem	:= 0
Local lRegSRA	:= .F.
Local cCampo	:= ""
Local cValid	:= ""
Local cChv1		:= ""
Local cChv2		:= ""

Default aInfos 	:= {}

Gp35SetAlias( '' )
Gp35SetFields( {} )

If Len(aInfos) > 0
	cTab := FwTabPref(aInfos[4])
	If !empty(cTab)
		DbSelectArea(cTab)
		(cTab)->(DbSetorder(1))

		If cTab == "SRB" .Or. cTab == "RBW" .Or. cTab == "RS9"
			If cTab == "SRB"
				lDepend := .T.
			EndIf
			cTab := "SRA"
		EndIf

		cFilAux:= Substr(aInfos[2],1,FWGETTAMFILIAL)
		cCodCha:= Rtrim(Substr(aInfos[2],FWGETTAMFILIAL+1))

		If cTab == "SPJ"
			cChv1 := Substr(cCodCha, 0, TamSx3('PJ_TURNO')[1] + TamSx3('PJ_SEMANA')[1])
			cChv2 := Substr(cCodCha, TamSx3('PJ_TURNO')[1] + TamSx3('PJ_SEMANA')[1] + 1, TamSx3('PJ_DIA')[1])
			cCodCha := cChv1 + cChv2
		EndIf

		//--------------------------------------------------
		//| Realiza a pesquisa para abrir a tela de ajustes
		//--------------------------------------------------
		If (cTab)->(DbSeek(cFilAux+cCodCha))
			aAux:= fArrayIde(cTab)

			For nZ := 4 To Len(aInfos)
				If aScan(aAux, aInfos[nZ]) == 0 .And. !("RB_" $ aInfos[nZ])  .And. !("RBW_" $ aInfos[nZ]) .And.;
				                                      !("RS9_" $ aInfos[nZ]) .And. !("tabela RS9" $ aInfos[nZ])
					aAdd( aAux, aInfos[nZ])
				EndIf
			Next nZ

			Gp35SetAlias( cTab )
			Gp35SetFields( aAux )

			If cTab == "SRA"
				//-----------------------------
				//| Tratativa para Estagi�rios
				//-----------------------------
				IF SRA->RA_CATEFD == "901"
					nPosFil := aScan( aInfos , { |x| x == "RA_CATEFD" } )

					If nPosFil > 0
						cFilAjst := cFilAnt
						cFilAnt := SRA->RA_FILIAL
						If FWExecView(OemToAnsi(STR0149), "GPEA920", MODEL_OPERATION_UPDATE,,{||.T.}) == 0
							cFilAnt := cFilAjst //Volta o valor do campo
							If LEN(aInfos) == 4
								aDel( aDados35, oBrw:At())
								aSize(aDados35,Len(aDados35)-1)
								oBrw:SetArray(aDados35)
								oBrw:Refresh(.T.)
								Return()
							Endif
						Endif
						cFilAnt := cFilAjst //Volta o valor do campo
					Endif
				EndIf

				//----------------------------------
				//| Tratativa para Agentes Publicos
				//----------------------------------
				If SRA->RA_VIEMRAI $ "30|31|35"
					nPosFil := aScan( aInfos , { |x| "RS9_" $ x })

					If nPosFil > 0
						cFilAjst := cFilAnt
						cFilAnt := SRA->RA_FILIAL
						If FWExecView(OemToAnsi(STR0226), "GPEA931", MODEL_OPERATION_UPDATE,,{||.T.}) == 0
							cFilAnt := cFilAjst //Volta o valor do campo
							If LEN(aInfos) == 4 .And. ( nPosFil > 0 )
								aDel( aDados35, oBrw:At())
								aSize(aDados35,Len(aDados35)-1)
								oBrw:SetArray(aDados35)
								oBrw:Refresh(.T.)
								Return()
							Else
								nPosRS9 := aScan( aInfos , { |x| "RS9_" $ x } )
								If nPosRS9 > 0
									aDel( aDados35[oBrw:At()], nPosRS9)
									aSize(aDados35[oBrw:At()],Len(aDados35[oBrw:At()])-1)

									oBrw:SetArray(aDados35)
									oBrw:Refresh(.T.)
									If Len(aDados35) < 1
										Return()
									Endif
								EndIf

							Endif
						EndIf
						cFilAnt := cFilAjst //Volta o valor do campo
					Endif
				Endif

				//------------------------------------------------------
				//| Tratativa para Funcion�rio Tempor�rio
				//------------------------------------------------------
				IF SRA->RA_CATEFD == "106" .and. SRA->RA_TPCONTR == "2"
					//Verifica se existe registro RBW_MOTIVO
					nPosFil := aScan( aInfos , { |x| x == "RBW_MOTIVO" } )

					If nPosFil > 0
						cFilAjst := cFilAnt
						cFilAnt := SRA->RA_FILIAL
						If FWExecView(OemToAnsi(STR0150), "GPEA927", MODEL_OPERATION_UPDATE,,{||.T.}) == 0 //0 - OK | 1 - CANCELAR
							cFilAnt := cFilAjst //Volta o valor do campo
							//Caso: Tenha validado o registro RBW + Exista a inconsist�ncia do RBW_MOTIVO + S� exista essa inconsist�ncia = Limpa da GRID
							If len(aInfos) == 4 .And. ( nPosFil > 0 )
								aDel( aDados35, oBrw:At())
								aSize(aDados35,Len(aDados35)-1)
								oBrw:SetArray(aDados35)
								oBrw:Refresh(.T.)
								Return()
							EndIf
						EndIf
						cFilAnt := cFilAjst //Volta o valor do campo
					Endif
				Endif
			EndIf

			//--------------------------------------------
			//| Tratativa para Dependentes do Funcion�rio
			//--------------------------------------------
			nPosDep := aScan( aInfos , { |x| "RB_" $ x } )
			If lDepend .Or. nPosDep > 0
		 		cFilAjst := cFilAnt
		 		cFilAnt := SRA->RA_FILIAL
				If FWExecView(STR0189,'GPEA020', MODEL_OPERATION_UPDATE,,{||.T.}) == 0
					cFilAnt := cFilAjst //Volta o valor do campo
					If LEN(aInfos) == 4
						aDel( aDados35, oBrw:At())
						aSize(aDados35,Len(aDados35)-1)

						oBrw:SetArray(aDados35)
						oBrw:Refresh(.T.)
						Return()
					ElseIf nPosDep > 0
						aDel( aDados35[oBrw:At()], nPosDep)
						aSize(aDados35[oBrw:At()],Len(aDados35[oBrw:At()])-1)

						oBrw:SetArray(aDados35)
						oBrw:Refresh(.T.)
					Endif
				EndIf
				cFilAnt := cFilAjst //Volta o valor do campo
			Endif

			//-----------------------------------
			//| Guardando os valores de mem�rias
			//| Utilizado para gravar dados na SR9 - Hist�rico (Somente se for SRA)
			//----------------------------------------------------------------------
			//| Varre para ver se existe algum SRA, se n�o ja sai do fluxo
			lRegSRA := aScan( aInfos , { |x| "RA_" $ x } ) > 0

			If lRegSRA
				RegToMemory("SRA")
				For nX := 4 To Len(aInfos)
					lRegSRA := "RA_" $ aInfos[nX]

					If lRegSRA
						aAdd(aMemoria, {aInfos[nX], &(M->aInfos[nX])})
					EndIf
				Next
			EndIf

			If FWExecView(STR0015,"VIEWDEF.GPEM035",MODEL_OPERATION_UPDATE,,{||.T.},,10) == 0
				//-----------------------------
				//| atualiza os dados do array
				//-----------------------------
				lIncons := .F. // ainda tem inconsistencia

				//---------------------------------------------------------------------------------------
				//| Len(aInfos) > 3 | A partir da 4a posi��o come�am os campos com inconsist�ncias
				//---------------------------------------------------------------------------------------
				If len(aInfos) > 3
					For nI := 4 to len(aInfos)
						If "tabela RS9"  $ aInfos[nI]
							Help(,,OemToAnsi(STR0004),,OemToAnsi(STR0227),1,0)//"Aten��o"# "N�o foi encontrada a tabela RS9-Agentes P�blicos, favor executar o UPDDISTR"

						//Se o campo for diferente de vazio
						ElseIf "RA_" $ aInfos[nI]
							If !Empty(&(ctab+"->"+aInfos[nI]))
								nPosItem := aScan( aMemoria, {|x| x[1] == aInfos[nI] } )
								If ( aMemoria[nPosItem,2] <> &(ctab+"->"+aInfos[nI]) )

									cCampo	:= Upper( AllTrim( aMemoria[nPosItem,1] ) )
									cValid	:= AllTrim( GetSx3Cache( cCampo , "X3_VALID" ) )

									If cValid == "FHIST()"
										//[1] - Campo /[2] - Valor novo /[3] - Valor antigo
										fGravaSr9( aInfos[nI] , &(ctab+"->"+aInfos[nI]) , aMemoria[nPosItem,2] )
									EndIf
								EndIf
							EndIf

						ElseIf "RA_" $ aInfos[nI] .OR. cTab <> "SRA"
							If Empty(&(ctab + "->" + aInfos[nI]))
								lIncons := .T.
							EndIf

						EndIf
					Next nI
				EndIf

				//Se n�o encontrar inconsist�ncias e n�o possuir pend�ncias de outras tabelas
				if !lIncons
					aDel( aDados35, oBrw:At())
					aSize(aDados35,Len(aDados35)-1)
				EndIf

				If Len(aDados35) == 0
					oBrw:deActivate()
					oBrw:_OOWNER:END()
				Else
					oBrw:SetArray(aDados35)
					oBrw:Refresh(.T.)
				EndIf
			EndIf
		EndIf
	Else
		If len(aInfos) > 2
			If "SIGAMAT" $ aInfos[3]
				Help(,,OemToAnsi(STR0004),,OemToAnsi(STR0213)+Substr(aInfos[3],21,15)+" "+ OemToAnsi(STR0211),1,0)//"Aten��o"#O Campo: <nome do campo> dever� ser preenchido diretamente no Configurador"
			ElseIf	"Par�metro 14"  $ aInfos[3]
				Help(,,OemToAnsi(STR0004),,OemToAnsi(STR0213)+SubStr(aInfos[3],16,40)+" "+ OemToAnsi(STR0212),1,0)//"Aten��o"#O Campo: <nome do campo> dever� ser preenchido diretamente no Par�metro 14"
			ElseIf	"S119"  $ aInfos[3]
				Help(,,OemToAnsi(STR0004),,OemToAnsi(STR0213)+SubStr(aInfos[3],15,40)+" "+ OemToAnsi(STR0214),1,0)//"Aten��o"#O Campo: <nome do campo> dever� ser preenchido diretamente na Tabela S119"
			ElseIf	"S120"  $ aInfos[3]
				Help(,,OemToAnsi(STR0004),,OemToAnsi(STR0213)+SubStr(aInfos[3],15,40)+" "+ OemToAnsi(STR0215),1,0)//"Aten��o"#O Campo: <nome do campo> dever� ser preenchido diretamente na Tabela S120"
			ElseIf	"tabela RS9"  $ aInfos[4]
				Help(,,OemToAnsi(STR0004),,OemToAnsi(STR0227),1,0)//"Aten��o"# "N�o foi encontrada a tabela RS9-Agentes P�blicos, favor executar o UPDDISTR"
			EndIf
		EndIf
	EndIf
EndIf
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ModelDef    �Autor  �Gustavo M.		   � Data �  27/05/14 ���
�������������������������������������������������������������������������͹��
���Desc.     �Defini��o do modelo de Dados				  				  ���
�������������������������������������������������������������������������͹��
���Uso       �GPEM035			                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ModelDef()

Local oModel := Nil
Local oStr1:= mldoStr1Str(1)

oModel := MPFormModel():New('GPEM035')
oModel:addFields('MASTER',,oStr1)
oModel:SetPrimaryKey({})
oModel:SetDescription('Model')
oModel:getModel('MASTER'):SetDescription('Model')

Return oModel

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �mldoStr1Str �Autor  �Gustavo M.		   � Data �  27/05/14 ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna estrutura do tipo FWformModelStruct				  ���
�������������������������������������������������������������������������͹��
���Uso       �GPEM035			                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function mldoStr1Str()

Local oStruct := FWFormModelStruct():New()

oStruct:AddTable(cChargeTab,,'Fake')
oStruct:AddField('Fake','Fake' , 'FLD_TST', 'C', 1, 0, , , {}, .F., , .F., .F., .F., , )

MontaStruct( 1, oStruct, aChargeFlds )

Return oStruct
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ViewDef     �Autor  �Gustavo M.		   � Data �  27/05/14 ���
�������������������������������������������������������������������������͹��
���Desc.     �Defini��o do interface									  ���
�������������������������������������������������������������������������͹��
���Uso       �GPEM035			                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ViewDef()

Local oView
Local oModel := ModelDef()
Local oStr1:= viewoStr1Str(1)
Local bBloc		:= {|oView| CallVA010(aDados35[oBrw:At()][2])}


oView := FWFormView():New()

oView:SetModel(oModel)
oView:AddField('FORM1' , oStr1,'MASTER' )
if Ascan(aDados35,{ |X| X[1] = "Funcion�rio" } ) > 1
	oView:AddUserButton(OemToAnsi(STR0148),"botao",bBloc,OemToAnsi(STR0148))
EndIf


oView:CreateHorizontalBox( 'BOXFORM1', 100)
oView:SetOwnerView('FORM1','BOXFORM1')

Return oView

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |Gp35SetAlias�Autor  �Gustavo M.		   � Data �  27/05/14 ���
�������������������������������������������������������������������������͹��
���Desc.     �Define o alias				  							  ���
�������������������������������������������������������������������������͹��
���Uso       �GPEM035			                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Gp35SetAlias( cTabUse )

cChargeTab := cTabUse

Return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Gp35SetField�Autor  �Gustavo M.		   � Data �  27/05/14 ���
�������������������������������������������������������������������������͹��
���Desc.     �Define os campos inconsistentes							  ���
�������������������������������������������������������������������������͹��
���Uso       �GPEM035			                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Gp35SetFields( aFlds )

aChargeFlds := aClone(aFlds)

Return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MontaStruct �Autor  �Gustavo M.		   � Data �  27/05/14 ���
�������������������������������������������������������������������������͹��
���Desc.     �Monta a estrutura.										  ���
�������������������������������������������������������������������������͹��
���Uso       �GPEM035			                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MontaStruct( nTipo, oStr, aCpos )

Local nI       := 0
Local nK       := 0
Local aVirCols := {}
Local aSave    := GetArea()
Local aSaveSX3 := SX3->( GetArea() )
Local cOrdem   := '03'
Local cCpoSPJ  := ""
Local aOpcs    := {}
Local bValid   := Nil
Local cTab     := If(Len(aCpos) > 0,FwTabPref(aCpos[1]),"")
Local i:= 0

DEFAULT nTipo := 1

If !Empty(cTab)
	If nTipo == 1
		For nK := 1 To Len( aCpos )

			SX3->( DbSetOrder( 2 ) ) //X3_CAMPO

			If SX3->( DbSeek( Padr( aCpos[nK], 10 ) ) )

				If nK <= 3 .Or. (Substr(aCpos[nK],1,2) == "PJ"  .And. nK == 4)
					lNoUpdate := .T.
				Else
					lNoUpdate := .F.
				EndIf

				lObrigat  := .F.

				If !Empty(Rtrim(SX3->X3_VALID))
					bValid := &('{|a,b,c,d,e| FWInitCpo(a,b,c,d),lRet := '+Rtrim(SX3->X3_VALID)+',FWCloseCpo(a,b,c,lRet,.T.),lRet}')
				Else
					bValid := {||.T.}
				EndIf

				IF aCpos[nK] == "RA_DATCHEG"
					bValid := {||.T.}
				EndIf

				If !Empty(Rtrim(SX3->X3_WHEN))
					bWhen := &('{|a,b,c,d,e| FWInitCpo(a,b,c,d),lRet := '+Rtrim(SX3->X3_WHEN)+',FWCloseCpo(a,b,c,lRet,.T.),lRet}')
				Else
					bWhen := {||.T.}
				EndIf

				IF aCpos[nK] == "RA_PORTDEF"
						bWhen := {||.T.}
				EndIf

				IF aCpos[nK] == "RA_CLASEST"
						bWhen := {||.T.}
				EndIf

				aOpcs :={}

				If !Empty(X3CBox())
					aOpcs := StrToKArr(RTrim(X3CBox()+";"), ";" )
					for i:= 1 to len(aOpcs)
						if substr(aOpcs[i],1,1)= " "
							aOpcs[i] := substr(aOpcs[i],2,41)
						EndIf
					Next i

					aAdd(aOpcs," ")
				EndIf


				oStr:AddField( X3Titulo(), ; // cTitle // 'Mark'
								X3Descric(), ; // cToolTip // 'Mark'
								Rtrim(aCpos[nK]), ; // cIdField
								Rtrim(SX3->X3_TIPO), ; // cTipo
								SX3->X3_TAMANHO, ; // nTamanho
								SX3->X3_DECIMAL, ; // nDecimal
								bValid, ; // bValid
								bWhen, ; // bWhen
								aOpcs, ; // aValues
								lObrigat, ; // lObrigat
								Nil, ; // bInit
								Nil, ; // lKey
								lNoUpdate, ; // lNoUpd
								.F. ) // lVirtual

				cCpoSPJ := aCpos[nK]
				Do Case
					Case cCpoSPJ == "PJ_ENTRA1" .Or. cCpoSPJ == "PJ_SAIDA1"
						oStr:AddTrigger( "PJ_ENTRA1", "PJ_HRSTRAB", {||.T.}, {||fHrsTrabGat("H",,"MB","1")} )
						oStr:AddTrigger( "PJ_ENTRA1", "PJ_HRTOTAL", {||.T.}, {||fHrsTrabGat("H",,"MB","1")} )
						oStr:AddTrigger( "PJ_SAIDA1", "PJ_HRSTRAB", {||.T.}, {||fHrsTrabGat("H",,"MB","1")} )
						oStr:AddTrigger( "PJ_SAIDA1", "PJ_HRTOTAL", {||.T.}, {||fHrsTrabGat("H",,"MB","1")} )
					Case cCpoSPJ == "PJ_ENTRA2" .Or. cCpoSPJ == "PJ_SAIDA2"
						oStr:AddTrigger( "PJ_ENTRA2", "PJ_HRSTRA2", {||.T.}, {||fHrsTrabGat("H",,"MB","2")} )
						oStr:AddTrigger( "PJ_ENTRA2", "PJ_HRTOTAL", {||.T.}, {||fHrsTrabGat("H",,"MB","2")} )
						oStr:AddTrigger( "PJ_SAIDA2", "PJ_HRSTRA2", {||.T.}, {||fHrsTrabGat("H",,"MB","2")} )
						oStr:AddTrigger( "PJ_SAIDA2", "PJ_HRTOTAL", {||.T.}, {||fHrsTrabGat("H",,"MB","2")} )
					Case cCpoSPJ == "PJ_ENTRA3" .Or. cCpoSPJ == "PJ_SAIDA3"
						oStr:AddTrigger( "PJ_ENTRA3", "PJ_HRSTRA3", {||.T.}, {||fHrsTrabGat("H",,"MB","3")} )
						oStr:AddTrigger( "PJ_ENTRA3", "PJ_HRTOTAL", {||.T.}, {||fHrsTrabGat("H",,"MB","3")} )
						oStr:AddTrigger( "PJ_SAIDA3", "PJ_HRSTRA3", {||.T.}, {||fHrsTrabGat("H",,"MB","3")} )
						oStr:AddTrigger( "PJ_SAIDA3", "PJ_HRTOTAL", {||.T.}, {||fHrsTrabGat("H",,"MB","3")} )
					Case cCpoSPJ == "PJ_ENTRA4" .Or. cCpoSPJ == "PJ_SAIDA4"
						oStr:AddTrigger( "PJ_ENTRA4", "PJ_HRSTRA4", {||.T.}, {||fHrsTrabGat("H",,"MB","4")} )
						oStr:AddTrigger( "PJ_ENTRA4", "PJ_HRTOTAL", {||.T.}, {||fHrsTrabGat("H",,"MB","4")} )
						oStr:AddTrigger( "PJ_SAIDA4", "PJ_HRSTRA4", {||.T.}, {||fHrsTrabGat("H",,"MB","4")} )
						oStr:AddTrigger( "PJ_SAIDA4", "PJ_HRTOTAL", {||.T.}, {||fHrsTrabGat("H",,"MB","4")} )
				End Case
			EndIf

		Next nI

		DbSelectArea('SX3')
		SX3->( DbSetOrder( 1 ) ) // X3_TABELA+X3_ORDEM
		SX3->( DbSeek( cTab) )

		While SX3->(!EOF()) .And. SX3->X3_ARQUIVO==cTab

			If aScan( aCpos, RTrim(SX3->X3_CAMPO))==0
				SX3->( DbSetOrder( 1 ) ) // X3_ALIAS

				aOpcs :={}

						oStr:AddField( X3Titulo(), ; // cTitle // 'Mark'
									X3Descric(), ; // cToolTip // 'Mark'
									RTrim(SX3->X3_CAMPO), ; // cIdField
									Rtrim(SX3->X3_TIPO), ; // cTipo
									SX3->X3_TAMANHO, ; // nTamanho
									SX3->X3_DECIMAL, ; // nDecimal
									bValid, ; // bValid
									{||.T.}, ; // bWhen
									aOpcs, ; // aValues
									.F., ; // lObrigat
									Nil, ; // bInit
									Nil, ; // lKey
									.F., ; // lNoUpd
									.F. ) // lVirtual

			EndIf
			SX3->(DbSkip())
		End

	Else
		oStr:AddGroup( "GRP_TRABALHADOR_01", STR0016, "", 2 ) // "Informacoes do Registro"
		oStr:AddGroup( "GRP_TRABALHADOR_02", STR0017, "", 2 ) // "Campos Inconsistentes"

		aCmpGrp:= fArrayIde(cTab)

		For nK := 1 To Len( aCpos )

			SX3->( DbSetOrder( 2 ) ) //X3_CAMPO

			If SX3->( DbSeek( Padr( aCpos[nK], 10 ) ) )

				cOrdem := Soma1(cOrdem)

				aOpcs :={}

				If !Empty(X3CBox())
					aOpcs := StrToKArr(RTrim(X3CBox()+";"), ";" )
					for i:= 1 to len(aOpcs)
						if substr(aOpcs[i],1,1)= " "
							aOpcs[i] := substr(aOpcs[i],2,41)
						EndIf
					Next i

					aAdd(aOpcs," ")
				EndIf


				IF aCpos[nK] == "RA_PORTDEF"
					oStr:AddField( aCpos[nK], ; // cIdField
									cOrdem, ; // cOrdem
									X3Titulo(), ; // cTitulo
									X3Descric(), ; // cDescric
									{}, ; // aHelp
									RTrim(SX3->X3_TIPO), ; // cType
									RTrim(SX3->X3_PICTURE), ; // cPicture
									Nil, ; // nPictVar
									RTrim("SRADEF"), ; // Consulta F3
									.T., ; // lCanChange
									'01', ; // cFolder
									Nil, ; // cGroup
									aOpcs, ; // aComboValues
									1, ; // nMaxLenCombo
									Nil, ; // cIniBrow
									.F., ; // lVirtual
									RTrim(SX3->X3_PICTVAR) ) // cPictVar
				elseif aCpos[nK] == "RA_CLASEST"
					oStr:AddField( aCpos[nK], ; // cIdField
									cOrdem, ; // cOrdem
									X3Titulo(), ; // cTitulo
									X3Descric(), ; // cDescric
									{}, ; // aHelp
									RTrim(SX3->X3_TIPO), ; // cType
									RTrim(SX3->X3_PICTURE), ; // cPicture
									Nil, ; // nPictVar
									RTrim("SRACLA"), ; // Consulta F3
									.T., ; // lCanChange
									'01', ; // cFolder
									Nil, ; // cGroup
									aOpcs, ; // aComboValues
									1, ; // nMaxLenCombo
									Nil, ; // cIniBrow
									.F., ; // lVirtual
									RTrim(SX3->X3_PICTVAR) ) // cPictVar
				ELSE
					oStr:AddField( aCpos[nK], ; // cIdField
									cOrdem, ; // cOrdem
									X3Titulo(), ; // cTitulo
									X3Descric(), ; // cDescric
									{}, ; // aHelp
									RTrim(SX3->X3_TIPO), ; // cType
									RTrim(SX3->X3_PICTURE), ; // cPicture
									Nil, ; // nPictVar
									RTrim(SX3->X3_F3), ; // Consulta F3
									.T., ; // lCanChange
									'01', ; // cFolder
									Nil, ; // cGroup
									aOpcs, ; // aComboValues
									1, ; // nMaxLenCombo
									Nil, ; // cIniBrow
									.F., ; // lVirtual
									RTrim(SX3->X3_PICTVAR) ) // cPictVar

				EndIf

			EndIf

			If aScan(aCmpGrp, aCpos[nK]) == 0
				oStr:SetProperty(aCpos[nK],MVC_VIEW_GROUP_NUMBER,"GRP_TRABALHADOR_02")
			Else
				oStr:SetProperty(aCpos[nK],MVC_VIEW_GROUP_NUMBER,"GRP_TRABALHADOR_01")
			EndIf

		Next nK

	EndIf
EndIf
Return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �viewoStr1Str�Autor  �Gustavo M.		   � Data �  27/05/14 ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna estrutura do tipo FWFormViewStruct				  ���
�������������������������������������������������������������������������͹��
���Uso       �GPEM035			                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static function viewoStr1Str(nRet)

Local oStruct := FWFormViewStruct():New()

MontaStruct( 2, oStruct, aChargeFlds,nRet )

return oStruct
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fCamposSRA  �Autor  �Gustavo M.		   � Data �  27/05/14 ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna os campos e descri��es da SRA.					  ���
�������������������������������������������������������������������������͹��
���Uso       �GPEM035			                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fCamposSRA(cDesc)

Local aArea 	:= GetArea()
Local aSRA		:= {}
Local cCampos   := ""
Local nB		:= 0

Default cDesc := ""

cCampos:= "RA_CIC|RA_NOMECMP|RA_NOME|RA_SEXO|RA_RACACOR|RA_GRINRAI|RA_NASC|RA_CPAISOR|RA_NACIONC|"
cCampos+= "RA_ADMISSA|RA_ESTCIVI|RA_CATEFD|RA_PIS|RA_VIEMRAI|RA_TPPREVI|RA_TPJORNA|RA_TPCONTR|RA_CC|RA_OPCAO|RA_CARGO|RA_CATFUNC|"
cCampos+= "RA_LOGRTP|RA_LOGRDSC|RA_ESTADO|RA_CODMUN|RA_CEP|RA_MUNICIP|RA_DATCHEGA|RA_CASADBR|RA_FILHOBR|"
cCampos+= "RA_PORTDEF|RA_TPJORNA|RA_REGRA|RA_SEQTURN|RA_EAPOSEN|RA_CODCBO|RA_ESTCIVI|RA_RESEXT|RA_TPDEFFI|RA_CLASEST|"


While nB < Len(cCampos)
	nAt:= At("|",cCampos)
	cCampo := SubStr(cCampos,1,nAt-1)
	cCampos:= SubStr(cCampos,nAt+1)
	cDesc:= Posicione('SX3',2,cCampo,'X3DESCRIC()')
	aAdD(aSRA,{cCampo,cDesc})
EndDo

RestArea(aArea)

Return(aSRA)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fSearchSRA  �Autor  �Gustavo M.		   � Data �  27/05/14 ���
�������������������������������������������������������������������������͹��
���Desc.     �Procura os campos na SRA.									  ���
�������������������������������������������������������������������������͹��
���Uso       �GPEM035                                          			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fSearchSRA(cDesc,aSra)

Local cCampo:= ""
Local nPos  := 0

nPos:= aScan(aSra,{|x|AllTrim(cDesc)$x[2] })
If nPos > 0
    cCampo:= aSra[nPos][1]
EndIf

Return cCampo

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fArrayIde   �Autor  �Gustavo M.		   � Data �  27/05/14 ���
�������������������������������������������������������������������������͹��
���Desc.     �Carrega campos identificadores.							  ���
�������������������������������������������������������������������������͹��
���Uso       �GPEM035                                          			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fArrayIde(cTab)

Do Case
	Case cTab == "SRV"
		aCpId := StrToKArr("RV_FILIAL|RV_COD|RV_DESC|","|")
	Case cTab == "CTT"
		aCpId := StrToKArr("CTT_FILIAL|CTT_CUSTO|CTT_DESC01|","|")
	Case cTab == "RE0"
		aCpId:= StrToKArr("RE0_FILIAL|RE0_NUM|RE0_DESCR|","|")
	Case cTab == "SRA"
		aCpId:= StrToKArr("RA_FILIAL|RA_MAT|RA_NOME|","|")
	Case cTab == "SRJ"
		aCpId:= StrToKArr("RJ_FILIAL|RJ_FUNCAO|RJ_DESC|","|")
	Case cTab == "SPJ"
		aCpId:= StrToKArr("PJ_FILIAL|PJ_TURNO|PJ_SEMANA|PJ_DIA|","|")
	Case cTab == "SRB"
		aCpId:= StrToKArr("RB_FILIAL|RB_MAT|RB_COD|","|")
	Case cTab == "RCE"
		aCpId:= StrToKArr("RCE_FILIAL|RCE_CODIGO|RCE_DESCRI|","|")
	Case cTab == "SR6"
		aCpId:= StrToKArr("R6_FILIAL|R6_TURNO|R6_TPJORN|R6_DTPJOR|","|")
	Case cTab == "RS9"
		aCpId:= StrToKArr("RS9_FILIAL|RS9_MAT|","|")
End Case

Return(aCpId)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �fAuxPro	� Autor �Gustavo M.			    � Data �31/05/2014���
�������������������������������������������������������������������������Ĵ��
���Descricao �Monta os Processos Selecionados.					          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPEM035  					                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function fAuxPro(cVar,lImprime,nChamada,oSelf)

Local aCod		:= {}
Local nX		:= 0

Default cVar := MV_PAR03
Default lImprime:= .F.
Default nChamada := 1

If cVersGPE < "9.0.00"
	For nX:=1 to Len(AllTrim(cVar))
		If !Empty(SubStr(cVar,nX,1)) .And. SubStr(cVar,nX,1) <> '*'
			aAdD(aCod,.T.)
		Else
			aAdD(aCod,.F.)
		EndIf
	Next
Else
	//Para a vers�o S-1.0 do eSocial alguns eventos deixaram de ser enviados, a posi��o destes eventos sempre ser� .F.
	For nX:=1 to Len(AllTrim(cVar))
		If !Empty(SubStr(cVar,nX,1)) .And. SubStr(cVar,nX,1) <> '*'
			aAdD(aCod,.T.)
		Else
			aAdD(aCod,.F.)
		EndIf
		//Acrescenta como falso a posi��o de gera��o do evento S-1050
		If Len(aCod) == 3
			aAdD(aCod,.F.)
		EndIf 
	Next
EndIf

//Inclui como falso a gera��o do evento S-1030, posi��o 8 do aCod
If cVersGPE >= "9.0.00" .And. Len(aCod) == 7
	aAdD(aCod,.F.)
EndIf

nChamada := 1
if cPergAux == "GPM035A"
	nChamada := 2 //Filtro de Funcionari
elseif cPergAux == "GPM035B"
	nChamada := 3 //Filtro de cCusto
EndIf
if !IsInCallStack("fFiltraCC") .and. !IsInCallStack('fFiltraFunc')
	cPergAux := ''
	nChamada := 1
EndIf

If Len(aCod)>0
	fGp35Pro({},aCod,dDataBase,"",lImprime,nChamada,oSelf)
Else
	Help( ,, 'HELP',,OemToAnsi(STR0219) , 1, 0 )
EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �fFiltraFun� Autor �Gustavo M.			    � Data �10/07/2014���
�������������������������������������������������������������������������Ĵ��
���Descricao �Filtra os funcion�rios							          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPEM035  					                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function fFiltraFunc(oBrw)

Pergunte("GPM035",.F.)
cOpcoes := MV_PAR03

If MsgYesNo(OemtoAnsi(STR0023),OemtoAnsi(STR0004)) // "Deseja filtrar os funcionarios?"###"Atencao"
	oBrw:deActivate()
	aSize(aDados35,0)
	aDados35 := Nil
	oBrw:_OOWNER:END()

	Pergunte("GPM035A",.T.)
	cPergAux:= 'GPM035A'
	fAuxPro(cOpcoes)
EndIf

Return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �fFiltraCC	� Autor �Gustavo M.			    � Data �10/07/2014���
�������������������������������������������������������������������������Ĵ��
���Descricao �Filtra os centro de custos						          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPEM035  					                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function fFiltraCC(oBrw)

Pergunte("GPM035",.F.)
cOpcoes := MV_PAR03

	If MsgYesNo(OemtoAnsi(STR0024),OemtoAnsi(STR0004)) // "Deseja filtrar os centro de custos?"###"Atencao"
		oBrw:deActivate()
		aSize(aDados35,0)
		aDados35 := Nil
		oBrw:_OOWNER:END()
		Pergunte("GPM035B",.T.)
		cPergAux := 'GPM035B'
		fAuxPro(cOpcoes)
	EndIf
Return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �fImprIncon� Autor �Gustavo M.			    � Data �10/07/2014���
�������������������������������������������������������������������������Ĵ��
���Descricao �Imprime as inconsistencias demonstradas na tela.	          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPEM035  					                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function fImprIncon(oBrw,aLog)
Local nE 		:= 0
Local nR 		:= 0
Local aResumo	:= {}
Local aLogInco	:= {}

DEFAULT aLog 	:= {}

If MsgYesNo(OemtoAnsi(STR0025),OemtoAnsi(STR0004)) // "Deseja imprimir as inconsist�ncias demonstradas na tela?"###"Atencao"
	oBrw:deActivate()
	If !Empty(aLog) //Ja carregou tudo, apenas imprime.

		//Tratamento para a impress�o do log n�o ultrapassar o limite da p�gina
		For nE := 1 to Len(aLog)
			aResumo := FWTxt2Array( aLog[nE], 131)
			For nR := 1 to Len(aResumo)
				Aadd(aLogInco, aResumo[nR])
			Next nR
		Next nE

		fMakeLog({aLogInco}, {OemToAnsi(STR0001)}, Nil, Nil, "GPM035", OemToAnsi(STR0047), "M", "P",, .F.)

	ElseIf Empty(cPergAux) .Or. cPergAux == 'GPM035'
		nChamada := 1
		fAuxPro(MV_PAR03,.T.)
	ElseIf cPergAux == 'GPM035A'
		Pergunte("GPM035A",.F.)
		nChamada := 2
		fAuxPro(cOpcoes,.T.)
	ElseIf cPergAux == "GPM035B"
		Pergunte("GPM035B",.F.)
		nChamada := 3
		fAuxPro(cOpcoes,.T.)
	EndIf
EndIf

Return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �fLimpFiltr� Autor �Gustavo M.			    � Data �10/07/2014���
�������������������������������������������������������������������������Ĵ��
���Descricao �Limpa o Filtro.									          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPEM035  					                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function fLimpFiltr(oBrw)

If MsgYesNo(OemtoAnsi(STR0026),OemtoAnsi(STR0004)) // "Deseja limpar o filtro?"###"Atencao"
	oBrw:deActivate()
	aSize(aDados35,0)
	aDados35 := Nil
	oBrw:_OOWNER:END()
	Pergunte("GPM035",.F.)
	cPergAux:="GPM035"
	fAuxPro(MV_PAR03)
EndIf

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �fGp35Pro  � Autor � Alessandro Santos     � Data �03/02/2014���
�������������������������������������������������������������������������Ĵ��
���Descricao �Executas a integracao dos Processos de Integracao com TAF e ���
���          �as geracoes de logs.                                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � fGp53Pro()                                           	  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPEM023   					                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������� */

Function fGp35Pro(aArrayFil, aCheck, dDataRef, cProcesso, lImprime, nChamada, oSelf)

Local aArea			:= GetArea()
Local cPerg1	 	:= If(Type("cPerg")=="C",cPerg,"GPEM023")
Local nI			:= 0
Local nCheck		:= 0
Local aDados		:= {}
Local aTitle		:= {}
Local aFilInTaf		:= {}

Local nOpca     	:= IF(cPerg1 == 'GPEM023',IIF(cProcesso == STR0114, 1, IIF(cProcesso == STR0115, 2, 3)),2) //Opcao de Processamento
Local cMesAno 		:= STRZERO(MONTH(dDataRef), 2) + STRZERO(YEAR(dDataRef), 4)

Local lRegua  		:= ValType(oSelf) <> "U"

Private aLogProc	:= {}

Default lImprime	:= .F.
Default nChamada 	:= 1

dDataRef := IF(cPerg1 == 'GPEM023',dDataRef,dDataBase) //Data de Referencia

//Adiciona titulo para Log
Aadd(aTitle, OemToAnsi(STR0002)) //##"Monitoramento Envio de Eventos - TAF"

//Busca grupos de filiais para envio
fGp35Cons(aFilInTaf, aArrayFil)

If lRegua
	oSelf:SetRegua1(Len(aFilInTaf))
	For nI := 1 to Len(aCheck)
		If aCheck[nI]
			nCheck++
		EndIf
	Next nI

	If nCheck > 0 .and. aCheck[5] .and. aCheck[6] //Se os dois estiverem marcados subtrai um, pois ser�o processados juntos
		nCheck--
	EndIf
EndIf

//Efetua cargas iniciais para todas as filiais
For nI := 1 To Len(aFilInTaf)

	If lRegua
		oSelf:IncRegua1(STR0229 + aFilInTaf[nI,02]) //"Processando filial: "
		oSelf:SetRegua2(nCheck)
	EndIf

	/*�������������������Ŀ
	� S-1010 - Rubricas �
	���������������������*/
	If aCheck[1]
		If lRegua
			oSelf:IncRegua2(STR0230 + STR0198) //Processando S-1010 Rubricas
		EndIf
		fCargRubr(cMesAno, nOpcA, aLogProc, dDataRef, aDados, aFilInTaf[nI])
	EndIf

	/*���������������������������������Ŀ
	� S-1020 - Lotacoes                 �
	�����������������������������������*/
	//Rotina para carga inicial TAF - Lotacoes/Departamentos
	If aCheck[2]
		If lRegua
			oSelf:IncRegua2(STR0230 + STR0200) //Processando S-1020 Lota��es Tribut�rias
		EndIf
		fCargLota(cMesAno, nOpcA, aLogProc, dDataRef, aDados, aFilInTaf[nI],nChamada)
	EndIf

	/*���������������������������������Ŀ
	� S-1005 - Estabelecimentos         �
	�����������������������������������*/
	If aCheck[3]
		If lRegua
			oSelf:IncRegua2(STR0230 + STR0199) //Processando S-1005 Estabelecimentos/Obras
		EndIf
		fObraCTT(cMesAno, nOpcA, aLogProc, dDataRef, aDados, aFilInTaf[nI],nChamada)
	EndIf

	/*��������������������������������������Ŀ
	� S-1050 - Horarios/Turnos de Trabalho �
	����������������������������������������*/
	If aCheck[4]
	 	If lRegua
			oSelf:IncRegua2(STR0230 + STR0201 ) //Processando S-1050 Hor�rios/Turnos de Trabalho
		EndIf
		fCargHorar(cMesAno, nOpcA, aLogProc, dDataRef, aDados, aFilInTaf[nI])
	EndIf

	/*���������������������������������Ŀ
	� SindicatoS �
	�����������������������������������*/
	If aCheck[7]
		If lRegua
			oSelf:IncRegua2(STR0230 + STR0190) //Processando Sindicatos
		EndIf
		fConsSind(cMesAno, nOpcA, aLogProc, dDataRef, aDados, aFilInTaf[nI])
	EndIf

	/*�����������������Ŀ
	� S-1030 - Cargos �
	�������������������*/
	If Len(aCheck) > 7 .And. aCheck[8]
	 	If lRegua
	 		oSelf:IncRegua2(STR0230 + STR0224) //Processando S-1030 Cargos
	 	EndIf
		fCargFunc(cMesAno, nOpcA, aLogProc, dDataRef, aDados, aFilInTaf[nI])
	EndIf

Next nI

If aCheck[5] .or. aCheck[6]
	If !( FWModeAccess("SRA",1)=="E" .AND. FWModeAccess("SRA",2)=="E" .AND. FWModeAccess("SRA",3)=="E" )
		aAdd(aDados,"")
		aAdd(aDados,OemToAnsi(STR0066)+" - "+OemToAnsi(STR0082))			//### "O compartilhamento da tabela SRA n�o � exclusivo. Assim a carga n�o realizada."
	Else
		fCargSRA(aLogProc, aFilInTaf, nChamada, lRegua, oSelf, aCheck[5], aCheck[6])
	EndIf
EndIf

If Len(aLogProc) > 0
	/*
	����������������������������Ŀ
	� Apresenta com Log de erros �
	������������������������������*/
	If lImprime
		fMakeLog({aLogProc}, aTitle, Nil, Nil, cPerg1, OemToAnsi(STR0047), "M", "P",, .F.)
	Else
		fTrataLog(aLogProc)
	EndIf
Else
	MsgAlert(OemToAnsi(STR0070)) //##"N�o existem informa��es para serem impressas"
EndIf


RestArea(aArea)

Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �fCargRubr � Autor � Alessandro Santos     � Data �03/02/2014���
�������������������������������������������������������������������������Ĵ��
���Descricao �Realiza carga das tabelas de rubricas para o TAF            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � fCargRubr()                                          	  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPEM023						                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������� */

Static Function fCargRubr(cMesAno, nOpcA, aLogProc, dDataRef, aDados, aFilInTaf)

Local oModel     	:= Nil
Local aArea		 	:= GetArea()
Local aAreaSRV    	:= SRV->(GetArea())
Local cAliasSRV  	:= GetNextAlias()
Local aIncons    	:= {}
Local lSemFilial 	:= .F.
Local cFilEnv		:= aFilInTaf[2]
Local cMenIni   	:= ""
Local cMsgLog		:= ""
Local cQryWhere  	:= "%"
Local cQrySelect	:= "%"
Local lContinua 	:= .T.
Local cFilDe:= ""
Local cFilAte:= ""

//Tratamento de compartilhamento da tabela SRV
If FWModeAccess("SRV", 1) == "C" .AND. FWModeAccess("SRV", 2) == "C" .AND. FWModeAccess("SRV", 3) == "C" //SRV compartilhada
	lSemFilial := .T.
EndIf

If !Empty(cFilEnv)
	//Busca informacoes SRV - Verbas
	// Define o tipo de verbas a serem consideradas
   	Pergunte("GPM035",.F.)
   	cFilde := MV_PAR01
   	cFilAte := MV_PAR02
	cQryWhere += "(RV_COD <> '' AND RV_FILIAL >= '" + xFilial("SRV",cFilDe) + "' AND RV_FILIAL <= '" + xFilial("SRV",cFilAte) + "')%"

	cQrySelect += "RV_FILIAL, RV_COD, RV_DESC, RV_DESCDET, RV_NATUREZ, RV_TIPOCOD, RV_DSRHE, RV_MED13, RV_MEDFER, RV_MEDAVI, RV_PERC,RV_INCCP, "
	cQrySelect += "RV_INCIRF, RV_INCFGTS, RV_INCSIND, RV_INSS, RV_INCCP, RV_IR, RV_INCIRF, RV_FGTS, RV_INCFGTS, RV_CODFOL"

	If SRV->(ColumnPos("RV_INFDED")) > 0
		cQrySelect += ", RV_INFDED"
	Endif

	If SRV->(ColumnPos("RV_REMESP")) > 0
		cQrySelect += ", RV_REMESP"
	Endif

	cQrySelect += "%"

	//Query para buscar informacoes de processos e varas
	BeginSql alias cAliasSRV
		SELECT
			%exp:cQrySelect%
		FROM
			%table:SRV% SRV
		WHERE
			%exp:cQryWhere% AND SRV.%notDel%
   		ORDER BY
   			SRV.RV_FILIAL, SRV.RV_COD
	EndSql

	dbSelectArea(cAliasSRV)

	//Posiciona no inicio do arquivo
	(cAliasSRV)->(dbGoTop())

	//Inicializa regua de processamento
	ProcRegua((cAliasSRV)->(RecCount()))

	While (cAliasSRV)->(!EOF())
		//Verifica filiais
		lContinua := .T.

		If lContinua
			//Tratamento para Codigo da Rubrica
			cCodRubr := IIf(lSemFilial,(cAliasSRV)->RV_COD, (cAliasSRV)->RV_FILIAL+(cAliasSRV)->RV_COD)

			//Verificacao da condicao do registro para DBF
			If Empty(cMenIni)
				cMenIni := OemToAnsi(STR0045) //##"Inconsist�ncias de R�bricas:"
				aAdd(aLogProc, cMenIni)
				aAdd(aLogProc, "")
				aAdd(aLogProc, "")
			EndIf

			fG17VSRV(cAliasSRV) // se voltar false significa inconsistencia
		EndIf

		(cAliasSRV)->(dbSkip())
	EndDo
Else
	//Grava log
	cMsgLog := OemToAnsi(STR0126) + " - " + OemToAnsi(STR0032) + OemToAnsi(aIncons[1]) //##"Rubrica" ##"Falha no envio ao TAF: "
EndIf

//Fecha alias em uso
If (Select(cAliasSRV) > 0)
	(cAliasSRV)->(dbCloseArea())
EndIf

RestArea(aAreaSRV)
RestArea(aArea)

Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �fCargLota � Autor � Alessandro Santos     � Data �03/02/2014���
�������������������������������������������������������������������������Ĵ��
���Descricao �Realiza carga das tabelas de lotacoes para o TAF            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � fCargLota()                                          	  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPEM023   					                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������� */

Static Function fCargLota(cMesAno, nOpcA, aLogProc, dDataRef, aDados, aArrayFil,nChamada)

Local cMenIni     	:= ""
Local cMsgLog		:= ""
Local cFilEnv		:= aArrayFil[2]
Local cFilSM0		:= ""
Local lSemFilial 	:= .F.
Local lContinua		:= .T.
Local aArea		 	:= GetArea()
Local aAreaCTT  	:= CTT->(GetArea())
Local cAliasCTT  	:= GetNextAlias()
Local aIncons    	:= {}
Local cQryWhere		:= "%(CTT_FILIAL >= '"+ Space(TamSx3("CTT_FILIAL")[1])+ "')%"
Local cFilDe:= ""
Local cFilAte:= ""

Default nChamada := 1


//Tratamento de compartilhamento da tabela CTT
If FWModeAccess("CTT", 1) == "C" .AND. FWModeAccess("CTT", 2) == "C" .AND. FWModeAccess("CTT", 3) == "C" //CTT compartilhada
	lSemFilial := .T.
EndIf

If !Empty(cFilEnv)
	//Busca informacoes CTT - Centro de Custo
	cQryWhere:= "%"
    If nChamada == 1 .OR. nChamada == 2 //Sem filtro !IsInCallStack("fFiltraCC") .Or. IsInCallStack('fLimpFiltr')
		Pergunte("GPM035",.F.)
		cFilde := MV_PAR01
		cFilAte := MV_PAR02
    	cQryWhere += "(CTT_FILIAL >= '" + xFilial("CTT",cFilde) + "' AND CTT_FILIAL <= '" + xFilial("CTT",cFilAte) + "') %"
	Else
		Pergunte("GPM035",.F.)
		cFilde := MV_PAR01
		cFilAte := MV_PAR02
		Pergunte("GPM035B",.F.)
       	cQryWhere += "(CTT_FILIAL >= '" + xFilial("CTT",cFilde )+ "' AND CTT_FILIAL <= '" + xFilial("CTT",cFilAte) + "') AND"
       	cQryWhere += "(CTT_CUSTO >= '" + MV_PAR01 + "' AND CTT_CUSTO <= '" + MV_PAR02 + "') %"
    EndIf

    BeginSql alias cAliasCTT
      	SELECT
       		CTT_FILIAL, CTT_CUSTO, CTT_NOME, CTT_TPLOT, CTT_TIPO, CTT_CEI, CTT_FPAS, CTT_CODTER,
       		CTT_TPINCT,	CTT_NRINCT, CTT_TPINPR, CTT_NRINPR, CTT_TIPO2, CTT_CEI2,CTT_DTEXSF, CTT_CLASSE
       	FROM
			%table:CTT% CTT
		WHERE
			CTT.%notDel% AND %exp:cQryWhere%
		ORDER BY
           	CTT.CTT_FILIAL, CTT.CTT_CUSTO
    EndSql

   	dbSelectArea(cAliasCTT)

    //Posiciona no inicio do arquivo
    (cAliasCTT)->(dbGoTop())

    //Inicializa regua de processamento
    ProcRegua((cAliasCTT)->(RecCount()))

    While (cAliasCTT)->(!EOF())
    	//Verifica filiais
		lContinua := .T.

    	If lContinua .AND. (cAliasCTT)->CTT_CLASSE == "2" .AND. (EMPTY((cAliasCTT)->CTT_DTEXSF) .OR. Stod((cAliasCTT)->CTT_DTEXSF) >= dDataBase )
	    	//Tratamento para Codigo da Lotacao
			cCodLot := IIf(lSemFilial,(cAliasCTT)->CTT_CUSTO, (cAliasCTT)->CTT_FILIAL+(cAliasCTT)->CTT_CUSTO)

			If Empty((cAliasCTT)->CTT_FPAS) .OR. Empty((cAliasCTT)->CTT_CODTER) .OR. (((cAliasCTT)->CTT_TPLOT $ "02|03|04|05|06|07|08|09" .AND.;
				(Empty((cAliasCTT)->CTT_TIPO2) .OR. Empty((cAliasCTT)->CTT_CEI2) .OR. Empty((cAliasCTT)->CTT_TPINCT) .OR. ;
				Empty((cAliasCTT)->CTT_NRINCT) .OR. Empty((cAliasCTT)->CTT_TPINPR) .OR. Empty((cAliasCTT)->CTT_NRINPR)))) .OR. ;
				Empty((cAliasCTT)->CTT_TPLOT)

				If Empty(cMenIni)
					cMenIni := OemToAnsi(STR0051) //##"Inconsist�ncias de Lota��es - Os campos abaixo est�o vazios e s�o de preenchimento obrigat�rios:"

					aAdd(aLogProc, cMenIni)
					aAdd(aLogProc, "")
					aAdd(aLogProc, "")
				EndIf

				//Mensagem de log que sera gravado
				cMsgLog := OemToAnsi(STR0105) //##"Centro de Custo"

				//Busca campos incosistentes
				/*
				��������������������������������������������������������������Ŀ
				� Posiciona na tabela CTT - Fisica                    	 	   �
				����������������������������������������������������������������*/
				//Mensagem de log
				cMsgLog += " " + (cAliasCTT)->CTT_CUSTO + " - " + OemToAnsi(STR0125) + ": " //##"Preenchimento de campos obrigat�rios"
				cFilSM0 := IIf(lSemFilial,cFilEnv, (cAliasCTT)->CTT_FILIAL)

				CTT->(dbSetOrder(1))
				CTT->(MsSeek((cAliasCTT)->CTT_FILIAL + (cAliasCTT)->CTT_CUSTO))

				fGp35Inco(aLogProc, 2, "CTT", @cMsgLog,cFilSM0)
			EndIf
		EndIf

       (cAliasCTT)->(dbSkip())
	EndDo
Else
	//Grava log
	cMsgLog := OemToAnsi(STR0052) + " - " + OemToAnsi(STR0032) + OemToAnsi(aIncons[1]) //##"Lota��o" ##"Falha no envio ao TAF: "
EndIf

//Fecha alias em uso
If (Select(cAliasCTT) > 0)
	(cAliasCTT)->(dbCloseArea())
EndIf

RestArea(aAreaCTT)
RestArea(aArea)

Return()


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �fObraCTT  � Autor � Glaucia Messina       � Data �11/06/2014���
�������������������������������������������������������������������������Ĵ��
���Descricao �Realiza carga das tabelas de Obras para o TAF via CTT       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � fObraCTT()                                            	  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPEM023						                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������� */
Static Function fObraCTT(cMesAno, nOpcA, aLogProc, dDataRef, aDados, aArrayFil,nChamada)
Local aArea		 	:= GetArea()
Local aAreaCTT  	:= CTT->(GetArea())
Local aSM0    		:= FWLoadSM0(.T.,.T.)
Local cMenIni     	:= ""
Local cCnae       	:= ""
Local cMsgLog		:= ""
Local cSubPat		:= ""
Local nI          	:= 0
Local lSemFilial 	:= .F.
Local aLogCNPJ    	:= {}
Local aIncons    	:= {}

Local cTpReg		:= ""
Local cTpApr		:= ""
Local cNrApr		:= ""
Local cTpEEn		:= ""
Local cCodEEn		:= ""
Local cPer14		:= Iif(ExistFunc("fPerAll"),fPerAll(),AnoMes(dDataBase) ) //Ultimo dia do periodo de calculo
Local cCNAEMat		:= ""
Local cContPCD		:= ""
Local cEmpMat		:= ""
Local nM			:= 0
Local nRATMat		:= 0
Local nFAPMat		:= 0
Local nPos			:= 0
Local nPos1			:= 0
Local nS119			:= 0
Local nS120			:= 0
Local dDataMat		:= cToD("//")
Local aTabS119		:= {}
Local aTabS120		:= {}
Local aX14			:= {}
Local aObraM35		:= {}
Local aInfoMat		:= {}

Local aEstObras   	:= {}
Local cAliasCTT  	:= GetNextAlias()
Local lContinua		:= .T.
Local cQryWhere		:= "%"
Local cFilDe		:= ""
Local cFilAte		:= ""

Default nChamada := 1


//Tratamento de compartilhamento da tabela CTT
If FWModeAccess("CTT", 1) == "C" .AND. FWModeAccess("CTT", 2) == "C" .AND. FWModeAccess("CTT", 3) == "C" //CTT compartilhada
	lSemFilial := .T.
EndIf

If nChamada == 1 .OR. nChamada == 2  //!IsInCallStack("fFiltraCC") .Or. IsInCallStack('fLimpFiltr')
	Pergunte("GPM035",.F.)
	cFilde := MV_PAR01
   	cFilAte := MV_PAR02
    cQryWhere += "(CTT_FILIAL >= '" + xFilial("CTT",cFilde) + "' AND CTT_FILIAL <= '" + xFilial("CTT",cFilAte) + "') %"
Else
   	Pergunte("GPM035",.F.)
   	cFilde := MV_PAR01
   	cFilAte := MV_PAR02
   	Pergunte("GPM035B",.F.)
    cQryWhere += "(CTT_FILIAL >= '" + xFilial("CTT",cFilde) + "' AND CTT_FILIAL <= '" + xFilial("CTT",cFilAte) + "') AND"
    cQryWhere += "(CTT_CUSTO >= '" + MV_PAR01 + "' AND CTT_CUSTO <= '" + MV_PAR02 + "') %"
   	Pergunte("GPM035",.F.)
EndIf

For nM := 1 To Len(aSM0)
	If aSM0[nM,2] >= AllTrim(cFilDe) .And. aSM0[nM,2] <= AllTrim(cFilAte)
		Aadd(aObraM35, aSM0[nM,2])
	EndIf
Next nM

For nM := 1 To Len(aObraM35)

	// Atualiza o per�odo de acordo com a filial processada
	cPer14 := Iif(ExistFunc("fPerAll"), fPerAll(aObraM35[nM]), AnoMes(dDataBase) )

	//Zera as vari�veis
	cContPCD := cTpReg := cTpApr := cNrApr := cTpEEn := cEmpMat := cCodEEn := cCNAEMat := nRATMat := nFAPMat := ""

	//Busca informacoes detalhadas da filial pois FWLoadSM0 nao traz todas necessarias
	fInfo(@aInfoMat,aObraM35[nM])

	//Monta variavel dDataRef da data de competencia em aberto p/ busca do fCarrTab
	dDataMat := cToD( "01/" + SubStr( cPer14, 5, 2 ) + "/" + SubStr( cPer14, 1, 4 ) )

	//Busca informacoes do Parametro14
	fInssEmp(aObraM35[nM],@aX14,.F.,cPer14)

	//carrega dados da tabela S119 - Dados eSocial - Matriz
	fCarrTab( @aTabS119, "S119", dDataMat,.T. )

	//carrega as entidades de ensino dos tomadores
	fCarrTab( @aTabS120, "S120", dDataMat, .T. )

	cCNAEMat:= aInfoMat[16]

	If LEN(aX14) > 0
		nRATMat := Round(aX14[29,1]*100,2)
		nFAPMat := (aX14[3,1]*100) / (aX14[29,1]* 100)
	EndIf

	If Findfunction("fChav119")
		//Busca o registro da tabela S119
		nPos  := 0
		nS119 := 0
		While nPos == 0 .And. nS119 <= 3
			nS119++
			nPos := Ascan(aTabS119,{|x| AllTrim(x[2])+ AllTrim(x[3])== fChav119(nS119, .F., AllTrim(aObraM35[nM]), AllTrim(cPer14))})
		EndDo

		If nPos > 0
			cContPCD	:= aTabS119[nPos][6]				// Contrata PCD
			cTpReg := AllTrim(aTabS119[nPos][9])	// Tipo de Registro do Ponto
			cTpApr := aTabS119[nPos][10]			// Contrata Aprendiz
			cNrApr := aTabS119[nPos][11]			// N�mero de Processo
			cTpEEn := aTabS119[nPos][12]			// Tipo de entidade educativa
			If LEN(aTabS119[nPos]) >= 13
				cEmpMat	:= aTabS119[nPos][13]			// Empresa Matriz
			EndIf
		EndIf

		//Busca o registro da tabela S120
		nPos1 := 0
		nS120 := 0
		While nPos1 == 0 .And. nS120 <= 3
			nS120++
			nPos1 := Ascan(aTabS120,{|x| AllTrim(x[2])+ AllTrim(x[3])== fChav119(nS120, .F., AllTrim(aObraM35[nM]), AllTrim(cPer14))})
		EndDo

		If nPos1 > 0
			cCodEEn := aTabS120[nPos1,7]
		EndIf
	EndIf

	If Empty(cCNAEMat) .Or. Empty(nRATMat) .Or. Empty(nFAPMat) .Or. Empty(nFAPMat);
		.Or. Empty(cTpApr) .Or. (cTpApr == "1" .And. Empty(cNrApr)) .Or.  (Empty(cTpEEn) .And. cTpApr $ "12")   ;
		.Or. (cTpEEn == "1" .And. Empty(cCodEEn)) .Or. (cEmpMat == "1" .And. Empty(cContPCD))
		//tem que ter tipo e numero de inscricao, percetual acidente trabalho, CNAE, RAT, Contrata aprendiz e Informa��o de ponto
		//Impressao
		If Empty(cMenIni)
			cMenIni := OemToAnsi(STR0060) //##"Inconsist�ncias de Estabelecimentos - Os campos abaixo est�o vazios ou zerados e s�o de preenchimento obrigat�rios:"

			aAdd(aLogProc, cMenIni)
			aAdd(aLogProc, "")
			aAdd(aLogProc, "")
		EndIf

		//Mensagem de log que sera gravado
		cMsgLog := OemToAnsi(STR0086) //##"Filial"

		//Mensagem de log
		cMsgLog += " " + aObraM35[nM] + " - " + OemToAnsi(STR0125) + ": " //##"Preenchimento de campos obrigat�rios"

		//Busca campos incosistentes
		fGp35InSM0(aLogProc, {cCNAEMat,nRATMat,nFAPMat,cTpReg,cTpApr,cNrApr,cTpEEn,cCodEEn,aObraM35[nM],cContPCD,cEmpMat},@cMsgLog)
	EndIf

Next nM


BeginSql alias cAliasCTT
	SELECT
		CTT_FILIAL, CTT_TIPO2, CTT_CEI2, CTT_FPAS, CTT_CODTER, CTT_CNAE, CTT_PERRAT, CTT_FAP,
		CTT_PERCAC, CTT_CUSTO, CTT_TPLOT, CTT_ICTPAT, CTT_CLASSE
	FROM
		%table:CTT% CTT
	WHERE
		CTT.%notDel% AND %exp:cQryWhere%
	ORDER BY
		CTT.CTT_FILIAL, CTT.CTT_CUSTO
EndSql

dbSelectArea(cAliasCTT)

(cAliasCTT)->(dbGoTop()) //Posiciona no inicio do arquivo
aEstObras := {}
aIncons   := {}

While (cAliasCTT)->(!EOF())

	//-------------------------------------------
	//| Evento S-1005 - Consist�ncia do registro
	//-------------------------------------------
	If ( (cAliasCTT)->CTT_TPLOT $ "01" .AND. (cAliasCTT)->CTT_TIPO2 $ "4" ) .AND. (cAliasCTT)->CTT_CLASSE == "2"
		//Tratamento para remover caracteres do campo CNAE
		cCnae := AllTrim(StrTran(StrTran((cAliasCTT)->CTT_CNAE, "-",""), "/",""))

		//Busca informacao SubPatronal
		cSubPat := ""

		If (cAliasCTT)->CTT_TIPO2 == "4"
			cSubPat := (cAliasCTT)->CTT_ICTPAT
		EndIf

		//Adiciona Obras
		Aadd(aEstObras, {(cAliasCTT)->CTT_FILIAL,;
						  (cAliasCTT)->CTT_TIPO2,;
						  (cAliasCTT)->CTT_CEI2,;
						  (cAliasCTT)->CTT_FPAS,;
						  (cAliasCTT)->CTT_CODTER,;
					  	  cCnae,;
					  	  (cAliasCTT)->CTT_PERRAT,;
					  	  (cAliasCTT)->CTT_FAP,;
					  	  (cAliasCTT)->CTT_PERCAC,;
					  	  (cAliasCTT)->CTT_CUSTO,;
					  	  cSubPat})
	EndIf
	(cAliasCTT)->(dbSkip())
EndDo

//Inicializa regua de processamento
ProcRegua(Len(aEstObras))

//Verifica as obras de Centro de Custo
For nI := 1 To Len(aEstObras)
	//Verifica campos vazios ou zerados
	If Empty(aEstObras[nI, 2]) .Or. Empty(aEstObras[nI, 3]) .Or.;
		Empty(aEstObras[nI, 6]) .Or. aEstObras[nI, 7] == 0 .Or. aEstObras[nI, 8] == 0 .Or. aEstObras[nI, 9] == 0 .And.;
		fGp35VlFil(nI, aEstObras, aLogCNPJ, nOpcA, lSemFilial, 1) //Validacao CNPJ

		If Empty(cMenIni)
			cMenIni := OemToAnsi(STR0060) //##"Inconsist�ncias de Estabelecimento/Obra - Os campos abaixo est�o vazios ou zerados e s�o de preenchimento obrigat�rios:"

			aAdd(aLogProc, cMenIni)
			aAdd(aLogProc, "")
			aAdd(aLogProc, "")
		EndIf

		//Mensagem de log que sera gravado
		cMsgLog := OemToAnsi(STR0105) //##"Centro de Custo"

		//Verifica inconsistencias
		/*
		��������������������������������������������������������������Ŀ
		� Posiciona na tabela CTT - Fisica                    	 	   �
		����������������������������������������������������������������*/
		CTT->(dbSetOrder(1))
		CTT->(MsSeek(aEstObras[nI, 1] + aEstObras[nI, 10]))

		//Mensagem de log
	 	cMsgLog += " " + aEstObras[nI, 10] + " - " + OemToAnsi(STR0125) + ": " //##"Preenchimento de campos obrigat�rios"

		//Busca campos incosistentes
		fGp23Inco(aLogProc, 3, "CTT", @cMsgLog,aTabS119,aTabS120)
	EndIf
Next nI

//Se impressao, adiciona Log de Inconsistencias do CNPJ
For nI := 1 To Len(aLogCNPJ)
	aAdd(aLogProc, OemToAnsi(STR0025)+" "+ aLogCNPJ[nI, 1] +" "+OemToAnsi(STR0061)) //##"Estabelecimentos/Obras"##"est� cadastrado em duas ou mais filiais com dados de cadastro diferentes CTT_FPAS, CTT_CODTER"
	aAdd(aLogProc, OemToAnsi(STR0062)) //##"CTT_CNAE, CTT_PERRAT, CTT_FAT ou CTT_PERCAC"
	aAdd(aLogProc, "")

	//Grava log
	cMsgLog := OemToAnsi(STR0025)+ " " + aLogCNPJ[nI, 1] + " " + OemToAnsi(STR0061) //##"Estabelecimentos/Obras"##"est� cadastrado em duas ou mais filiais com dados de cadastro diferentes CTT_FPAS, CTT_CODTER"
	cMsgLog += ", " + OemToAnsi(STR0062)
Next nI

//Fecha alias em uso
If (Select(cAliasCTT) > 0)
	(cAliasCTT)->(dbCloseArea())
EndIf

RestArea(aAreaCTT)
RestArea(aArea)

Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �fCargProc � Autor � Alessandro Santos     � Data �02/03/2014���
�������������������������������������������������������������������������Ĵ��
���Descricao �Realiza carga das tabelas de processos para o TAF           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � fCargProc()                                          	  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� nOpc - Numero da acao Aitva (inc- alt- vis - apagar)       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPEM023						                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������� */

Static Function fCargProc(cMesAno, nOpcA, aLogProc, dDataRef, aDados, aArrayFil)

Local cQryWhere   	:= "%"
Local cMenIni   	:= ""
Local cMsgLog		:= ""
Local cFilEnv		:= aArrayFil[2]
Local aIncons    	:= {}
Local aArea		 	:= GetArea()
Local aAreaRE0  	:= RE0->(GetArea())
Local aAreaRE1  	:= RE1->(GetArea())
Local cAliasProc 	:= GetNextAlias()
Local lSemFilial 	:= .F.
Local lDataDBF 		:= .F.
Local cFilDe		:= ""
Local cFilAte		:= ""


//Tratamento de compartilhamento da tabela RE0
If FWModeAccess("RE0", 1) == "C" .AND. FWModeAccess("RE0", 2) == "C" .AND. FWModeAccess("RE0", 3) == "C" //RE0 compartilhada
	lSemFilial := .T.
EndIf

RE1->(dbSetOrder(1))

If !Empty(cFilEnv)
	//Busca informacoes RE0 - Processos e RE1 - Varas
	lDataDBF := .F.

	// Define o tipo de verbas a serem consideradas
   	Pergunte("GPM035",.F.)
   	cFilde := MV_PAR01
   	cFilAte := MV_PAR02
   	cQryWhere += "(RE0.RE0_FILIAL >= '" + xFilial("RE0",cFilde) + "' AND RE0.RE0_FILIAL <= '" + xFilial("RE0",cFilAte) + "') %"

	//Query para buscar informacoes de processos e varas
	BeginSql alias cAliasProc
		SELECT DISTINCT
			RE0_FILIAL, RE0_NUM, RE0_TPPROC, RE0_PROJUD, RE0_INDSUS, RE0_DTDECI, RE0_IDDEP, RE0_VARA, RE0_DESCR, RE0_COMAR
		FROM
			%table:RE0% RE0
		WHERE
			RE0.%notDel% AND %exp:cQryWhere%
		ORDER BY
			RE0.RE0_FILIAL, RE0.RE0_NUM
	EndSql

	dbSelectArea(cAliasProc)

	//Posiciona no inicio do arquivo
	(cAliasProc)->(dbGoTop())

	//Inicializa regua de processamento
	ProcRegua((cAliasProc)->(RecCount()))

	While (cAliasProc)->(!EOF())
		//Verificacao da condicao do registro para DBF
		If Empty(cMenIni)
			cMenIni := OemToAnsi(STR0049) + Chr(13) + Chr(10) //##"Inconsist�ncias de Processos - Os campos abaixo est�o vazios e s�o de preenchimento obrigat�rios:"
			aAdd(aLogProc, cMenIni)
			aAdd(aLogProc, "")
			aAdd(aLogProc, "")
		EndIf

		fG17VRE0(cAliasProc) // se voltar false significa inconsistencia

		(cAliasProc)->(dbSkip())
	EndDo
Else
	//Grava log
	cMsgLog := OemToAnsi(STR0041) + " - " + OemToAnsi(STR0032) + OemToAnsi(aIncons[1]) //##"Processo" ##"Falha no envio ao TAF: "
EndIf

//Fecha alias aberto
If (Select(cAliasProc) > 0)
	(cAliasProc)->(dbCloseArea())
EndIf

RestArea(aAreaRE0)
RestArea(aAreaRE1)
RestArea(aArea)

Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �fCargPort � Autor � Alessandro Santos     � Data �03/02/2014���
�������������������������������������������������������������������������Ĵ��
���Descricao �Realiza carga das tabelas de portuarios para o TAF          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � fCargPort()                                          	  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPEM023  					                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������� */

Static Function fCargPort(cMesAno, nOpcA, aLogProc, dDataRef, aDados, aArrayFil, nChamada)

Local oModel     	:= Nil
Local cMenIni     	:= ""
Local cMsgLog		:= ""
Local cFilEnv		:= aArrayFil[2]
Local nOpc       	:= 3
Local nI          	:= 0
Local lSemFilial 	:= .F.
Local lContinua		:= .T.
Local aIncons    	:= {}
Local aLogCNPJ    	:= {}
Local aPortuario  	:= {}
Local aArea		 	:= GetArea()
Local aAreaCTT  	:= CTT->(GetArea())
Local cAliasCTT  	:= GetNextAlias()
Local cQryWhere  	:= "%"
Local cFilDe:= ""
Local cFilAte:= ""

Default nChamada := 1


//Tratamento de compartilhamento da tabela CTT
If FWModeAccess("CTT", 1) == "C" .AND. FWModeAccess("CTT", 2) == "C" .AND. FWModeAccess("CTT", 3) == "C" //CTT compartilhada
	lSemFilial := .T.
EndIf

If !Empty(cFilEnv)

	//Busca informacoes CTT - Centro de Custo
	If nChamada == 1 .OR. nChamada == 2
		Pergunte("GPM035",.F.)
		cFilde := MV_PAR01
		cFilAte := MV_PAR02
		cQryWhere += "(CTT_FILIAL >= '" + xFilial("CTT",cFilde) + "' AND CTT_FILIAL <= '" + xFilial("CTT",cFilAte) + "') %"
	Else
       	Pergunte("GPM035",.F.)
		cFilde := MV_PAR01
		cFilAte := MV_PAR02
		Pergunte("GPM035B",.F.)
       	cQryWhere += "(CTT_FILIAL >= '" + xFilial("CTT",cFilde) + "' AND CTT_FILIAL <= '" + xFilial("CTT",cFilAte) + "') AND"
       	cQryWhere += "(CTT_CUSTO >= '" + MV_PAR01 + "' AND CTT_CUSTO <= '" + MV_PAR02 + "') %"
    	Pergunte("GPM035",.F.)
    EndIf

    BeginSql alias cAliasCTT
    	SELECT
    		CTT_FILIAL, CTT_CEI, CTT_CEI2, CTT_PERRAT, CTT_FAP, CTT_PERCAC, CTT_CUSTO, CTT_TPLOT, CTT_TIPO, CTT_TIPO2, CTT_NOME
    	FROM
    		%table:CTT% CTT
    	WHERE
    		CTT.%notDel%  AND %exp:cQryWhere%
    	ORDER BY
    		CTT.CTT_FILIAL, CTT.CTT_CUSTO
    EndSql

   	dbSelectArea(cAliasCTT)

    //Posiciona no inicio do arquivo
    (cAliasCTT)->(dbGoTop())

    While (cAliasCTT)->(!EOF())
    	//Verifica filiais
		If lSemFilial //Compartilhada
			lContinua := .T.
		ElseIf aScan(aArrayFil[3], {|X| FwxFilial("CTT", X) == (cAliasCTT)->CTT_FILIAL}) > 0 //Exclusiva
			lContinua := .T.
		Else
			lContinua := .F.
		EndIf

    	If lContinua .AND. (cAliasCTT)->CTT_TPLOT $ "08|09"
			Aadd(aPortuario, {(cAliasCTT)->CTT_FILIAL,;
							  IIF((cAliasCTT)->CTT_TPLOT == "08", (cAliasCTT)->CTT_CEI2, (cAliasCTT)->CTT_CEI),;
							  (cAliasCTT)->CTT_PERRAT,;
							  (cAliasCTT)->CTT_FAP,;
							  (cAliasCTT)->CTT_PERCAC,;
							  (cAliasCTT)->CTT_CUSTO,;
							  (cAliasCTT)->CTT_TPLOT,;
							  IIF((cAliasCTT)->CTT_TPLOT == "08", (cAliasCTT)->CTT_TIPO2, (cAliasCTT)->CTT_TIPO),;
							  (cAliasCTT)->CTT_NOME})
		EndIf

		(cAliasCTT)->(dbSkip())
	EndDo

   	//Inicializa regua de processamento
	ProcRegua(Len(aPortuario))

   	For nI := 1 To Len(aPortuario)
		//Verifica campos vazios ou zerados
		If Empty(aPortuario[nI, 2]) .Or. Empty(aPortuario[nI, 8]) .Or. Empty(aPortuario[nI, 9]) .Or. aPortuario[nI, 3] == 0 .Or.;
			aPortuario[nI, 4] == 0 .Or. aPortuario[nI, 5] == 0 .And. fGp35VlFil(nI, aPortuario, aLogCNPJ, nOpcA, lSemFilial, 2) //Validacao CNPJ

			If Empty(cMenIni)
				cMenIni := OemToAnsi(STR0055) //##"Inconsist�ncias de Portu�rio - Os campos abaixo est�o vazios ou zerados e s�o de preenchimento obrigat�rios:"

				aAdd(aLogProc, cMenIni)
				aAdd(aLogProc, "")
				aAdd(aLogProc, "")
			EndIf

			//Mensagem de log que sera gravado
			cMsgLog := OemToAnsi(STR0105) //##"Centro de Custo"

			//Verifica inconsistencias
			/*
			��������������������������������������������������������������Ŀ
			� Posiciona na tabela CTT - Fisica                    	 	   �
			����������������������������������������������������������������*/
			CTT->(dbSetOrder(1))
			CTT->(MsSeek(aPortuario[nI, 1] + aPortuario[nI, 6]))

			//Mensagem de log
		 	cMsgLog += " " + aPortuario[nI, 6] + " - " + OemToAnsi(STR0125) + ": " //##"Preenchimento de campos obrigat�rios"

			//Busca campos incosistentes
			fGp23Inco(aLogProc, 5, "CTT", @cMsgLog)

			//Efetua a gravacao do log
		EndIf
	Next nI

	//Se impressao, adiciona Log de Inconsistencias do CNPJ
	For nI := 1 To Len(aLogCNPJ)
		aAdd(aLogProc, OemToAnsi(STR0056)+" "+ aLogCNPJ[nI, 1] +" "+OemToAnsi(STR0057)) //##"Operador"##"est� cadastrado em duas ou mais filiais com dados de cadastro diferentes CTT_PERRAT, CTT_FAP ou CTT_PERCAC"
		aAdd(aLogProc, "")

		//Grava log
		cMsgLog := OemToAnsi(STR0054)+ " " + aLogCNPJ[nI, 1] + " " + OemToAnsi(STR0057) //##"Portu�rio"##"est� cadastrado em duas ou mais filiais com dados de cadastro diferentes CTT_FPAS, CTT_CODTER"
	Next nI
Else
	//Grava log
	cMsgLog := OemToAnsi(STR0054) + " - " + OemToAnsi(STR0032) + OemToAnsi(aIncons[1]) //##"Portu�rio" ##"Falha no envio ao TAF: "
EndIf

//Verifica se alias esta em uso
If (Select(cAliasCTT) > 0)
	(cAliasCTT)->(dbCloseArea())
EndIf

RestArea(aAreaCTT)
RestArea(aArea)

Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �fGp23Inco � Autor � Alessandro Santos     � Data �14/02/2014���
�������������������������������������������������������������������������Ĵ��
���Descricao �Adiciona informacoes no array para impressao de inconsisten ���
���          �cias.                                                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � fGp23Inco()                                           	  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� nTpCarga: 1-Rubricas/2-Lotacao/3-Obras/4-Processo          ���
���          � 5-Portuario                                                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPEM023  					                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������� */

Static Function fGp23Inco(aLogProc, nTpCarga, cAliasTmp, cMsgLog, aTabS119, aTabS120)

Local cFPAS		:= ""
Local cPer14	:= Iif(ExistFunc("fPerAll"),fPerAll(),AnoMes(dDataBase) ) //Ultimo dia do periodo de calculo
Local cContPCD	:= ""	// Contrata PCD
Local cEmpMat	:= ""	// Empresa Matriz
Local cTpReg 	:= ""	// Tipo de Registro do Ponto
Local cTpApr 	:= ""	// Contrata Aprendiz
Local cNrApr 	:= ""	// N�mero de Processo
Local cTpEEn 	:= ""	// Tipo de entidade educativa
Local cCodEEn := ""  //C�digo da entidade educativa
Local nI      	:= 0
Local nPos		:= 0
Local nPos1		:= 0
Local nS119		:= 0
Local nS120		:= 0
Local aCposImp	:= {}
Local aArea		:= GetArea()

Default aTabS119:= {}
Default aTabS120:= {}

If Findfunction("fChav119")
	//Busca o registro da tabela S119
	While nPos == 0 .And. nS119 <= 7
		nS119++
		nPos := Ascan(aTabS119,{|x| AllTrim(xFilial("CTT",x[2]))+ AllTrim(x[3])+ AllTrim(x[8])== fChav119(nS119, .T., AllTrim(CTT->CTT_FILIAL), AllTrim(cPer14), AllTrim(CTT->CTT_CUSTO) )})
	EndDo

	If nPos > 0
		cContPCD:= aTabS119[nPos][6]			// Contrata PCD
		cTpReg	:= AllTrim(aTabS119[nPos][9])	// Tipo de Registro do Ponto
		cTpApr	:= aTabS119[nPos][10]			// Contrata Aprendiz
		cNrApr	:= aTabS119[nPos][11]			// N�mero de Processo
		cTpEEn	:= aTabS119[nPos][12]			// Tipo de entidade educativa
		If LEN(aTabS119[nPos]) >= 13
			cEmpMat	:= aTabS119[nPos][13]			// Empresa Matriz
		EndIf
	EndIf

	//Busca o registro da tabela S120
	While nPos1 == 0 .And. nS120 <= 7
		nS120++
		nPos1 := Ascan(aTabS120,{|x| AllTrim(xFilial("CTT",x[2]))+ AllTrim(x[3])+ AllTrim(x[6])== fChav119(nS120, .T., AllTrim(CTT->CTT_FILIAL), AllTrim(cPer14), AllTrim(CTT->CTT_CUSTO) )})
	EndDo

	If nPos1 > 0
		cCodEEn := aTabS120[nPos1,7]
	EndIf
EndIf

SX3->(dbSetOrder(2))

If nTpCarga == 3 //Estabelecimentos/Obras
	//Inicia inconsistencias, CTT ja posicionada
	aAdd(aLogProc, OemToAnsi(STR0053) + " " + OemToAnsi(CTT->CTT_FILIAL+CTT->CTT_CUSTO) + " -> " + OemToAnsi(CTT->CTT_DESC01)) //##"Centro de Custo: "

	aCposImp :=	{"CTT_TIPO2", "CTT_CEI2", "CTT_CNAE", "CTT_PERRAT", "CTT_FAP", "CTT_PERCAC"}
EndIf

//Busca as informacoes para cada campo
For nI := 1 To Len(aCposImp)
	If (ValType((cAliasTmp)->(FieldGet(FieldPos(aCposImp[nI])))) $ "C|D" .And. Empty((cAliasTmp)->(FieldGet(FieldPos(aCposImp[nI]))))) .Or.;
		(ValType((cAliasTmp)->(FieldGet(FieldPos(aCposImp[nI])))) == "N" .And. (cAliasTmp)->(FieldGet(FieldPos(aCposImp[nI]))) == 0)

		If SX3->(MsSeek(aCposImp[nI]))
			aAdd(aLogProc, AllTrim(SX3->X3_CAMPO) + " - " + AllTrim(SX3->X3_DESCRIC))
			cMsgLog	+= " - " + AllTrim(SX3->X3_CAMPO)
		EndIf
	EndIf
Next nI

//Pula linha
aAdd(aLogProc, "")

aAdd(aLogProc, OemToAnsi(STR0216) + " " + OemToAnsi(CTT->CTT_FILIAL+CTT->CTT_CUSTO) + " -> " + OemToAnsi(CTT->CTT_DESC01)) //##"Estabelecimento/Obra: "
//Tipo Ponto
If Empty(cTpReg)
	aAdd(aLogProc,   OemToAnsi(STR0206) ) 	//##"O campo Tipo Ponto est� vazio e seu preenchimento � obrigat�rio. Utilize a Tabela S119.
	cMsgLog += " - " + OemToAnsi(STR0206)	//##"O campo Tipo Ponto est� vazio e seu preenchimento � obrigat�rio. Utilize a Tabela S119.
EndIf

//Contrata Aprendiz
If Empty(cTpApr)
	aAdd(aLogProc,   OemToAnsi(STR0207) )	//##" Campo Contrata Aprendiz est� vazio e seu preenchimento � obrigat�rio, utilize a tabela S119.
	cMsgLog += " - " + OemToAnsi(STR0207)	//##" Campo Contrata Aprendiz est� vazio e seu preenchimento � obrigat�rio, utilize a tabela S119.
Else
	//N�mero do Processo se Contrata Aprendiz for "1"
	If cTpApr == "1" .And. Empty(cNrApr)
		aAdd(aLogProc,   OemToAnsi(STR0208) )	//##" Campo N�mero do Processo Aprendiz est� vazio e seu preenchimento � obrigat�rio caso contrate aprendiz, utilize a tabela S119.
		cMsgLog += " - " + OemToAnsi(STR0208)	//##" Campo N�mero do Processo Aprendiz est� vazio e seu preenchimento � obrigat�rio caso contrate aprendiz, utilize a tabela S119.
	EndIf
EndIf

//Campo Tipo de Entidade Educativa
If Empty(cTpEEn) .And. cTpApr $ "12"
	aAdd(aLogProc,   OemToAnsi(STR0209) )	//##"Campo Tipo de Entidade Educativa est� vazio e seu preenchimento � obrigat�rio, utilize a tabela S119.
	cMsgLog += " - " + OemToAnsi(STR0209)	//##"Campo Tipo de Entidade Educativa est� vazio e seu preenchimento � obrigat�rio, utilize a tabela S119.
Else
	//Entidade Educativa (S120)
	If cTpEEn == "1" .And. Empty(cCodEEn)
		aAdd(aLogProc,   OemToAnsi(STR0210) )	//##"A Entidade Educativa est� vazia e seu preenchimento � obrigat�rio caso o tipo de entidade educativa seja "1", utilize a tabela S120.
		cMsgLog += " - " + OemToAnsi(STR0210)	//##"A Entidade Educativa est� vazia e seu preenchimento � obrigat�rio caso o tipo de entidade educativa seja "1", utilize a tabela S120.
	EndIf
EndIf

//Filial � Matriz mas n�o foi informado se contrata PCD
If cEmpMat == "1" .And. Empty(cContPCD)
	aAdd(aLogProc,   OemToAnsi(STR0228) )	//##"A Empresa foi marcada como matriz e n�o foi informado se contrata PCD, utilize a tabela S119"
	cMsgLog += " - " + OemToAnsi(STR0228)	//##"A Empresa foi marcada como matriz e n�o foi informado se contrata PCD, utilize a tabela S119"
EndIf

//Pula linha
aAdd(aLogProc, "")

RestArea(aArea)

Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �fGp35InSM0� Autor � Alessandro Santos     � Data �27/05/2014���
�������������������������������������������������������������������������Ĵ��
���Descricao �Adiciona informacoes no array para impressao de inconsisten ���
���          �cias para Sigamat.                                          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � fGp35InSM0()                                           	  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPEM023  					                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������� */

Static Function fGp35InSM0(aLogProc, aDados, cMsgLog)

Local aArea	 := GetArea()

Default aDados := {}

//Inicia inconsistencias
aAdd(aLogProc, OemToAnsi(STR0086) +  ": " + aDados[9]) //##"Filial"
//tem que ter CNAE, RAT, FAT, Tipo Registro de Ponto, Contrata Aprendiz, N�mero de Processo, Tipo de Entidade Educativa e Entidade Educativa

//CNAE
If Empty(aDados[1])
	aAdd(aLogProc,   OemToAnsi(STR0129) + " - " + OemToAnsi(STR0135)) //##"Sigamat" ##"C�digo CNAE"
 	cMsgLog += " - " + OemToAnsi(STR0135) //##"C�digo CNAE"
EndIf

//RAT
If Empty(aDados[2])
	aAdd(aLogProc,   OemToAnsi(STR0231) + " - " + OemToAnsi(STR0136)) //##"Par�metro 14" ##"RAT"
	cMsgLog += " - " + OemToAnsi(STR0136) //##"RAT"
EndIf

//FAP
If Empty(aDados[3])
	aAdd(aLogProc,   OemToAnsi(STR0231) + " - " + OemToAnsi(STR0205)) //##"Par�metro 14" ##"% FAP (% Acidente de Trabalho / RAT)"
	cMsgLog += " - " + OemToAnsi(STR0205) //##"% FAP (% Acidente de Trabalho / RAT)"
EndIf

//Tipo Ponto
If Empty(aDados[4])
	aAdd(aLogProc,   OemToAnsi(STR0206) ) 	//##"O campo Tipo Ponto est� vazio e seu preenchimento � obrigat�rio. Utilize a Tabela S119.
	cMsgLog += " - " + OemToAnsi(STR0206)	//##"O campo Tipo Ponto est� vazio e seu preenchimento � obrigat�rio. Utilize a Tabela S119.
EndIf

//Contrata Aprendiz
If Empty(aDados[5])
	aAdd(aLogProc,   OemToAnsi(STR0207) )	//##" Campo Contrata Aprendiz est� vazio e seu preenchimento � obrigat�rio, utilize a tabela S119.
	cMsgLog += " - " + OemToAnsi(STR0207)	//##" Campo Contrata Aprendiz est� vazio e seu preenchimento � obrigat�rio, utilize a tabela S119.
Else
	//N�mero do Processo se Contrata Aprendiz for "1"
	If aDados[5] == "1" .And. Empty(aDados[6])
		aAdd(aLogProc,   OemToAnsi(STR0208) )	//##" Campo N�mero do Processo Aprendiz est� vazio e seu preenchimento � obrigat�rio caso contrate aprendiz, utilize a tabela S119.
		cMsgLog += " - " + OemToAnsi(STR0208)	//##" Campo N�mero do Processo Aprendiz est� vazio e seu preenchimento � obrigat�rio caso contrate aprendiz, utilize a tabela S119.
	EndIf
EndIf

//Campo Tipo de Entidade Educativa
//Se contratar aprendiz deve informar o tipo de entidade educativa
If Empty(aDados[7]) .And. aDados[5] $ "12"
	aAdd(aLogProc,   OemToAnsi(STR0209) )	//##"Campo Tipo de Entidade Educativa est� vazio e seu preenchimento � obrigat�rio, utilize a tabela S119.
	cMsgLog += " - " + OemToAnsi(STR0209)	//##"Campo Tipo de Entidade Educativa est� vazio e seu preenchimento � obrigat�rio, utilize a tabela S119.
Else
	//Entidade Educativa (S120)
	If aDados[7] == "1" .And. Empty(aDados[8])
		aAdd(aLogProc,   OemToAnsi(STR0210) )	//##"A Entidade Educativa est� vazia e seu preenchimento � obrigat�rio caso o tipo de entidade educativa seja "1", utilize a tabela S120.
		cMsgLog += " - " + OemToAnsi(STR0210)	//##"A Entidade Educativa est� vazia e seu preenchimento � obrigat�rio caso o tipo de entidade educativa seja "1", utilize a tabela S120.
	EndIf
EndIf

//Filial � Matriz mas n�o foi informado se contrata PCD
If aDados[11] == "1" .And. Empty(aDados[10])
	aAdd(aLogProc,   OemToAnsi(STR0228) )	//##"A Empresa foi marcada como matriz e n�o foi informado se contrata PCD, utilize a tabela S119"
	cMsgLog += " - " + OemToAnsi(STR0228)	//##"A Empresa foi marcada como matriz e n�o foi informado se contrata PCD, utilize a tabela S119"
EndIf

//Pula linha
aAdd(aLogProc, "")

RestArea(aArea)

Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �fGp35Cons � Autor � Alessandro Santos     � Data �14/02/2014���
�������������������������������������������������������������������������Ĵ��
���Descricao �Verificacao se filial para envio ao TAF e consolidada ou    ���
���          �descentralizada.                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � fGp35Cons()                                           	  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aFilSM0 - Array que recebera as informacoes das filiais.   ���
���          � aComplEmp = Array contendo os complementos de empresas que ���
���          � serao consideradas, se nao for passado serao consideradas  ���
���          � todas.                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPEM023  					                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������� */

Static Function fGp35Cons(aFilSM0, aComplEmp)

Local aFilCon	:= {}
Local aArea		:= GetArea()

Default aFilSM0 	:= {}
Default aComplEmp 	:= {}

/*
�������������������������������������������������������Ŀ
� Posicoes do Array aFilSM0:	               	 	   	�
�                                              			�
� 1 - .T. (Consolidado) - .F. (Descentralizado)			�
� 2 - Filial centralizadora								�
� 3 - Array contendo as filiais que compoem o grupo		�
���������������������������������������������������������*/
	Aadd(aFilCon, cFilAnt)
	Aadd(aFilSM0, {.T.,cFilAnt,aFilCon})

RestArea(aArea)
Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �fGp35VlFil� Autor � Alessandro Santos     � Data �24/02/2014���
�������������������������������������������������������������������������Ĵ��
���Descricao �Verificacao se CNPJ esta cadastrado para mais de 1 filial   ���
���          �e se RAT, FAP e RAT Alterado estao diferentes - Consolidado ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � fGp35VlFil()                                           	  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� nTpCarga: 1-Estabelecimentos e Obras/2-Portuarios          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPEM023  					                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������� */

Static Function fGp35VlFil(nPosAtu, aDados, aLogCNPJ, nOpcA, lSemFilial, nTpCarga)

Local nI   := 0
Local nPos 	:= 0
Local lRet 	:= .T.
Local aArea := GetArea()

//Tratamento para inconsistenacia de CNPJ repetido - Apenas para consolidado
If  !lSemFilial
	For nI := 1 To Len(aDados)
		//CNPJ repetido e com divergencias
		If nTpCarga == 1 //Estabelecimentos/Obras
			If nI <> nPosAtu .And. (aDados[nI, 2] == aDados[nPosAtu, 2] .And. aDados[nI, 3] == aDados[nPosAtu, 3]) .And.;
				(aDados[nI, 4] <> aDados[nPosAtu, 4] .Or. aDados[nI, 5] <> aDados[nPosAtu, 5] .Or.;
				aDados[nI, 6] <> aDados[nPosAtu, 6] .Or. aDados[nI, 7] <> aDados[nPosAtu, 7] .Or.;
				aDados[nI, 8] <> aDados[nPosAtu, 8] .Or. aDados[nI, 9] <> aDados[nPosAtu, 9])

				If nOpcA == 2 // Se impressao adiciona informacao de divergencia no CNPJ
					nPos := aScan(aLogCNPJ, {|X| X[1] == aDados[nI, 3]})

					If nPos == 0
			 			Aadd(aLogCNPJ, {aDados[nI, 3]})
			 		EndIf
				EndIf

				lRet := .F.
			EndIf
		ElseIf nTpCarga == 2 //Portuarios
			If nI <> nPosAtu .And. aDados[nI, 2] == aDados[nPosAtu, 2] .And. (aDados[nI, 3] <> aDados[nPosAtu, 3] .Or.;
				aDados[nI, 4] <> aDados[nPosAtu, 4] .Or. aDados[nI, 5] <> aDados[nPosAtu, 5])

				If nOpcA == 2 // Se impressao adiciona informacao de divergencia no CNPJ
					nPos := aScan(aLogCNPJ, {|X| X[1] == aDados[nI, 2]})

					If nPos == 0
			 			Aadd(aLogCNPJ, {aDados[nI, 2]})
			 		EndIf
				EndIf

				lRet := .F.
			EndIf
		EndIf
	Next nI
EndIf

RestArea(aArea)

Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fGM35Fil    �Autor  �Glaucia Messina     � Data �  13/06/14 ���
�������������������������������������������������������������������������͹��
���Desc.     � Carga de string para uso em Query por taeblas envolvidas,  ���
���          � a partir das empresas centralizadoras escolhidas na carga  ���
���          � TAF                                                        ���
�������������������������������������������������������������������������͹��
���Uso       �GPEM023- fCargVI                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fGM35Fil(aFilInTaf)

Local aArea		:= GetArea()
Local x			:= 0
Local y			:= 0
Local cFilTOP	:= "%'"
Local cFilDBF	:= ""

For x:=1 to len(aFilInTaf)
	For y:=1 to len(aFilInTaf[x,3])
		cFilTOP += aFilInTaf[x,3,y]
		cFilDBF += aFilInTaf[x,3,y] + "|"
		cFilTOP += "','"
	Next y
Next x

If cFilTOP	=="%'"
	cFilTOP += "'%"
Else
	cFilTOP := SUBSTR(cFilTOP,1,(LEN(cFilTOP)-3))
	cFilTOP += "'%"
EndIf

RestArea(aArea)
Return ({cFilTOP,cFilDBF})

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �fGp35Inco � Autor � Alessandro Santos     � Data �14/02/2014���
�������������������������������������������������������������������������Ĵ��
���Descricao �Adiciona informacoes no array para impressao de inconsisten ���
���          �cias.                                                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � fGp35Inco()                                           	  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� nTpCarga: 1-Rubricas/2-Lotacao/3-Obras/4-Processo          ���
���          � 5-Portuario                                                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPEM023  					                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������� */

Static Function fGp35Inco(aLogProc, nTpCarga, cAliasTmp, cMsgLog, cFilSM0)

Local cFPAS		:= ""
Local cPer14	:= Iif(ExistFunc("fPerAll"),fPerAll(),AnoMes(dDataBase) ) //Ultimo dia do periodo de calculo
Local cRecomend	:= ""
Local nI      	:= 0
Local aCposImp	:= {}
Local aArea		:= GetArea()
Local aInfo		:= {}
Local aP14		:= {}

Local naux		:= 0

Default cFilSM0	:= cFilEnv

SX3->(dbSetOrder(2))

If CTT->CTT_TPLOT == "01"
	//Buscar CNAE do sigamat
	fInfo(@aInfo,cFilSM0)
	If Len(aInfo) > 0
		cFPAS := aInfo[17] //SM0->M0_FPAS
	EndIf

	fInssEmp(cFilSM0,@aP14,.F.,cPer14)
EndIf

If CTT->CTT_TPLOT $ "03|04|05|06|07|08|09"
	aCposImp :=	{"CTT_TPLOT", "CTT_FPAS", "CTT_CODTER","CTT_CUSTO", "CTT_TIPO2", "CTT_CEI2"}
ElseIf CTT->CTT_TPLOT == "02"
	aCposImp :=	{"CTT_TPLOT", "CTT_FPAS", "CTT_CODTER","CTT_CUSTO", "CTT_TIPO2", "CTT_CEI2", "CTT_TPINCT", "CTT_NRINCT", "CTT_TPINPR", "CTT_NRINPR"}
ElseIf CTT->CTT_TPLOT == "01" .And. ( ! Empty(CTT->CTT_CEI) .Or. ! Empty(CTT->CTT_CEI2))
	aCposImp :=	{"CTT_FPAS", "CTT_CODTER"}
Else
	aCposImp :=	{"CTT_TPLOT", "CTT_CUSTO"}
EndIf

naux := 0

//Busca as informacoes para cada campo
For nI := 1 To Len(aCposImp)
	If (ValType((cAliasTmp)->(FieldGet(FieldPos(aCposImp[nI])))) $ "C|D" .And. Empty((cAliasTmp)->(FieldGet(FieldPos(aCposImp[nI]))))) .Or.;
		(ValType((cAliasTmp)->(FieldGet(FieldPos(aCposImp[nI])))) == "N" .And. (cAliasTmp)->(FieldGet(FieldPos(aCposImp[nI]))) == 0)
		naux++
		if naux == 1
			//Inicia inconsistencias, CTT ja posicionada
			aAdd(aLogProc, OemToAnsi(STR0053) + " " + OemToAnsi(CTT->CTT_FILIAL+CTT->CTT_CUSTO) + " -> " + OemToAnsi(CTT->CTT_DESC01)) //##"Centro de Custo: "
		Endif

		If SX3->(MsSeek(aCposImp[nI]))
			If CTT->CTT_TPLOT == "01"
				If ( "CTT_FPAS" $ aCposImp[nI] .And. Empty(cFPAS) ) .Or. ( "CTT_CODTER" $ aCposImp[nI] .And. Len(aP14) > 0 .And. Empty(aP14[25,1]) )
					If "CTT_FPAS" $ aCposImp[nI]
						cRecomend := OemToAnsi(STR0217)	//" - Campo vazio no Centro de Custo e no Cadastro da Filial Preencher em um deles ou em ambos"
					Else
						cRecomend := OemToAnsi(STR0218)	//" - Campo vazio no Centro de Custo e no Par�metro 14 Preencher em um deles ou em ambos"
					EndIf
					aAdd(aLogProc, AllTrim(SX3->X3_CAMPO) + " - " + AllTrim(SX3->X3_DESCRIC) + cRecomend )
					cMsgLog	+= " - " + AllTrim(SX3->X3_CAMPO)
				EndIf
			Else
				aAdd(aLogProc, AllTrim(SX3->X3_CAMPO) + " - " + AllTrim(SX3->X3_DESCRIC))
				cMsgLog	+= " - " + AllTrim(SX3->X3_CAMPO)
			EndIf
		EndIf
	EndIf
	if ni >= len(aCposImp) .and. naux > 0
		//Pula linha
		aAdd(aLogProc, "")
	Endif
Next nI

RestArea(aArea)

Return()

//------------------------------------//
// Cadastro de Funcion�rios          //
//------------------------------------//
Function CallVA010(nChave)

Local aAreaSRA 		:= GetArea()
Private cCadastro	:= Capital( AllTrim( fDesc( "SX2" , "SRA" , "X2Nome()" , NIL , NIL , 1 , .F. ) ) )
if substr(aDados35[oBrw:At()][4],1,2) == "RA"
	dbSelectArea('SRA')
	dbSetOrder(1)
	If SRA->(dbSeek(nChave))

		Gpea010Vis( "SRA" , , 2 , NIL , .T. )

	EndIf
EndIf
Restarea(aAreaSra)
Return


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao	 �fTpDefi   � Autor � Marcia Moura		    � Data � 13/08/13 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Selecionar Informacao sobre Deficiencia Funcionario         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � fTpDefi   											 	  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Cadastro tabela SRA - Campo RA_PORTDEF					  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function fTpDefi()

Local cTitulo:= OemtoAnsi(STR0156) //"Informacoes Deficiencia" //
Local MvPar
Local MvParDef := "1234"
Local MvParDef2:= "123456"
Local lRet := .T.
Local lOpt := .F.
Local cAlias := Alias()
				//"Portador de Deficiencia"	## "Motora"				##"Portador de Deficiencia"## Auditiva" 	##"Portador de Deficiencia" ## "Visual" 			##"Funcionario Reabilitado"
Static aCat:={"1-"+OemtoAnsi(STR0164)+" "+OemtoAnsi(STR0158),"2-"+OemtoAnsi(STR0164)+" "+OemtoAnsi(STR0159),"3-"+OemtoAnsi(STR0164)+" "+OemtoAnsi(STR0160),"4-"+OemtoAnsi(STR0164)+" "+OemtoAnsi(STR0163)}
Static aCat2:={"1-"+OemtoAnsi(STR0164)+" "+OemtoAnsi(STR0158),;  //Fisica
				"2-"+OemtoAnsi(STR0164)+" "+OemtoAnsi(STR0159),; //Auditiva
				"3-"+OemtoAnsi(STR0164)+" "+OemtoAnsi(STR0160),; //Visual
				"4-"+OemtoAnsi(STR0164)+" "+OemtoAnsi(STR0161),; //"Mental"
				"5-"+OemtoAnsi(STR0164)+" "+OemtoAnsi(STR0162),; //"Intelectual"
				"6-"+OemtoAnsi(STR0163)}						 //"O trabalhador � reabilitado, e apto a retornar ao trabalho")}


	MvPar:=&(Alltrim(ReadVar()))		 // Carrega Nome da Variavel do Get em Questao
	mvRet:=Alltrim(ReadVar())			 // Iguala Nome da Variavel ao Nome variavel de Retorno

	// Chama funcao f_Opcoes
	If !aEfd[2]
		lOpt := f_Opcoes(@MvPar,cTitulo,aCat,MvParDef,12,49,.F.)
	Else
		lOpt := f_Opcoes(@MvPar,cTitulo,aCat2,MvParDef2,12,49,.F.)
	EndIf

	If lOpt
		&MvRet :=  MvPar
	EndIf

	VAR_IXB := MvPar

Return( lRet )


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao	 �fTpEst()  � Autor � Marcia Moura		    � Data � 13/08/13 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Classe de estrangeiro                                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � fTpEst    											 	  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Cadastro tabela SRA - Campo RA_PORTDEF					  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function fTpEst()

Local cTitulo:= OemtoAnsi(STR0169)

Local MvPar    	:=""
Local MvParDef 	:=""
Local lRet     	:= .T.
Local l1Elem   	:= .T.
Local oWnd
Local cTeste
Local cAlias := Alias()

If Alltrim(ReadVar())= "M->RA_CLASEST"

	aOcor := {;
	OemToAnsi(STR0170),;		//"01 - Visto permanente;"
	OemToAnsi(STR0171),;		//"02 - Visto tempor�rio;"
	OemToAnsi(STR0172),;		//"03 - Asilado;"
	OemToAnsi(STR0173),;		//"04 - Refugiado;"
	OemToAnsi(STR0174),;		//"05 - Solicitante de Ref�gio;"
	OemToAnsi(STR0175),;		//"06 - Residente em pa�s fronteiri�o ao Brasil;"
	OemToAnsi(STR0176),;		//"07 - Deficiente f�sico e com mais de 51 anos;"
	OemToAnsi(STR0177),;		//"08 - Com resid�ncia provis�ria e anistiado, em situa��o irregular;"
	OemToAnsi(STR0178),;		//"09 - Perman�ncia no Brasil em raz�o de filhos ou c�njuge brasileiros;"
	OemToAnsi(STR0179),;		//""10 - Beneficiado pelo acordo entre pa�ses do Mercosul;"
	OemToAnsi(STR0180),;		//"11 - Dependente de agente diplom�tico e/ou consular de pa�ses que mant�m conv�nio de reciprocidade para o exerc�cio de atividade remunerada no Brasil;"
	OemToAnsi(STR0181) ;   		//"12 - Beneficiado pelo Tratado de Amizade, Coopera��o e Consulta entre a Rep�blica Federativa do Brasil e a Rep�blica Portuguesa."
	}


	MvPar:=&(Alltrim(ReadVar()))		 // Carrega Nome da Variavel do Get em Questao
	mvRet:=Alltrim(ReadVar())			 // Iguala Nome da Variavel ao Nome variavel de Retorno



	MvParDef:= "010203040506070809101112"
	cTeste	:= "01#02#03#04#05#06#07#08#09#10#11#12"



	f_Opcoes(@MvPar,cTitulo,aOcor,MvParDef,,,.T.,2)  	//Chama funcao f_Opcoes

	VAR_IXB := MvPar
EndIf

Return( lRet )


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �fCargHorar� Autor � Alessandro Santos     � Data �03/03/2014���
�������������������������������������������������������������������������Ĵ��
���Descricao �Realiza carga das tabelas de Horarios para o TAF            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � fCargHorar()                                           	  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� nOpc - Numero da acao Aitva (inc- alt- vis - apagar)       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPEM023						                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������� */

Static Function fCargHorar(cMesAno, nOpcA, aLogProc, dDataRef, aDados, aArrayFil)

Local lSemFilial	:= .F.
Local aHorario 		:= {}
Local nZ 			:= 0
Local cMenIni		:= ""
Local aTurnoAux := {}

//Tratamento de compartilhamento da tabela SR6
If FWModeAccess("SR6", 1) == "C" .AND. FWModeAccess("SR6", 2) == "C" .AND. FWModeAccess("SR6", 3) == "C" //SR6 compartilhada
	lSemFilial := .T.
EndIf

//-------------------------
//| Monta o array aHorario
//| Fun��o centralizadora para Carga e Consist�ncias
//---------------------------------------------------
aHorario := fGetaHorarios(lSemFilial, aArrayFil)

//Verificacao da condicao do registro para DBF
If Empty(cMenIni)
	aAdd(aLogProc, "")
	cMenIni := OemToAnsi(STR0166) + Chr(13) + Chr(10) //##"Inconsist�ncias de Turnos/Hor�rios de Trabalho - Os campos abaixo est�o vazios e s�o de preenchimento obrigat�rios:"
	aAdd(aLogProc, cMenIni)
	aAdd(aLogProc, "")
	aAdd(aLogProc, "")
EndIf

//Inicializa regua de processamento
For nZ := 1 to len(aHorario)
	fG17VSR6(aHorario[nZ], @aLogProc, @aTurnoAux) // se voltar false significa inconsistencia
Next nZ

Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �fCargFunc � Autor � Alessandro Santos     � Data �03/02/2014���
�������������������������������������������������������������������������Ĵ��
���Descricao �Realiza carga das tabelas de funcoes para o TAF             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � fCargFunc()                                          	  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPEM023						                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������� */

Static Function fCargFunc(cMesAno, nOpcA, aLogProc, dDataRef, aDados, aArrayFil)

Local cQryWhere   	:= "%"
Local cMenIni   	:= ""
Local cFilEnv		:= aArrayFil[2]
Local aArea		 	:= GetArea()
Local aAreaSRJ  	:= SRJ->(GetArea())
Local aCposImp		:= {}
Local cAliasSRJ		:= GetNextAlias()
Local lSemFilial	:= .F.
Local lGeraItem		:= .T.
Local lCampos		:= .F.
Local cFilDe		:= ""
Local cFilAte		:= ""
Local nContInc		:= 0

Local naux			:= 0

//Tratamento de compartilhamento da tabela SRJ
If FWModeAccess("SRJ", 1) == "C" .AND. FWModeAccess("SRJ", 2) == "C" .AND. FWModeAccess("SRJ", 3) == "C" //SRJ compartilhada
	lSemFilial := .T.
EndIf

//Verifica a exist�ncia dos campos RJ_ACUM,  RJ_CTESP, RJ_DEDEXC, RJ_LEI, RJ_DTLEI, RJ_SIT
If 	SRJ->(FieldPos("RJ_ACUM")) > 0 .And. SRJ->(FieldPos("RJ_CTESP")) > 0 .And. SRJ->(FieldPos("RJ_DEDEXC")) > 0 .And. ;
	SRJ->(FieldPos("RJ_LEI")) > 0 .And. SRJ->(FieldPos("RJ_DTLEI")) > 0 .And. SRJ->(FieldPos("RJ_SIT")) > 0
	lCampos := .T.
EndIf

If lCampos
	If !Empty(cFilEnv)
		//Busca informacoes SRJ - Funcoes
		// Define o tipo de verbas a serem consideradas
	   	Pergunte("GPM035",.F.)
	   	cFilde := MV_PAR01
	   	cFilAte := MV_PAR02
	   	cQryWhere += "(SRJ.RJ_FILIAL >= '" + xFilial("SRJ",cFilde) + "' AND SRJ.RJ_FILIAL <= '" + xFilial("SRJ",cFilAte) + "') %"

		//Query para buscar informacoes de fun��es
		BeginSql alias cAliasSRJ
			SELECT
				RJ_FILIAL, RJ_FUNCAO, RJ_DESC, RJ_ACUM, RJ_CTESP, RJ_DEDEXC, RJ_LEI, RJ_DTLEI, RJ_SIT
			FROM
				%table:SRJ% SRJ
			WHERE
				SRJ.%notDel%
	   		ORDER BY
	   			SRJ.RJ_FILIAL, SRJ.RJ_FUNCAO
		EndSql

		dbSelectArea(cAliasSRJ)

		//Posiciona no inicio do arquivo
		(cAliasSRJ)->(dbGoTop())

		naux := 0

		While (cAliasSRJ)->(!EOF())

			naux++
			SX3->(dbSetOrder(2))

            lGeraItem := .T.

			//Valida os campos {RJ_ACUM,  RJ_CTESP, RJ_DEDEXC, RJ_LEI, RJ_DTLEI, RJ_SIT} se um deles estiver preenchido os outros tamb�m dever�o estar.
			//RJ_ACUM
			If Empty((cAliasSRJ)->RJ_ACUM) .And. ( (!Empty((cAliasSRJ)->RJ_CTESP)) .Or. (!Empty((cAliasSRJ)->RJ_DEDEXC)) .Or. (!Empty((cAliasSRJ)->RJ_LEI)) .Or. (!Empty((cAliasSRJ)->RJ_DTLEI)) .Or. (!Empty((cAliasSRJ)->RJ_SIT)) )
				If SX3->(MsSeek("RJ_ACUM"))
					if naux == 1
						//Verificacao da condicao do registro para DBF
						If Empty(cMenIni)
							cMenIni := OemToAnsi(STR0168) + Chr(13) + Chr(10) //##"Inconsist�ncias de Fun��es:"
							aAdd(aLogProc, cMenIni)
							aAdd(aLogProc, "")
							aAdd(aLogProc, "")
						EndIf

						nContInc := Len(aLogProc)
						naux++
					Endif

					aAdd(aLogProc, OemToAnsi(STR0040) + " " + OemToAnsi((cAliasSRJ)->RJ_FILIAL)+OemToAnsi((cAliasSRJ)->RJ_FUNCAO) + " -> " + OemToAnsi((cAliasSRJ)->RJ_DESC)) //##"Fun��o "
					aAdd(aLogProc, PADR(AllTrim(SX3->X3_CAMPO), 10, " ") + " - " + PADR(AllTrim(SX3->X3_DESCRIC), 25, " ") + " - Mot.: " + OemToAnsi(STR0167))
					lGeraItem := .F.
				EndIf
			EndIf

			//RJ_CTESP
			If Empty((cAliasSRJ)->RJ_CTESP) .And. ( (!Empty((cAliasSRJ)->RJ_ACUM)) .Or. (!Empty((cAliasSRJ)->RJ_DEDEXC)) .Or. (!Empty((cAliasSRJ)->RJ_LEI)) .Or. (!Empty((cAliasSRJ)->RJ_DTLEI)) .Or. (!Empty((cAliasSRJ)->RJ_SIT)) )
				If SX3->(MsSeek("RJ_CTESP"))
					If(lGeraItem, aAdd(aLogProc, OemToAnsi(STR0040) + " " + OemToAnsi((cAliasSRJ)->RJ_FILIAL)+OemToAnsi((cAliasSRJ)->RJ_FUNCAO) + " -> " + OemToAnsi((cAliasSRJ)->RJ_DESC)),) //##"Fun��o "
					if naux == 1
						//Verificacao da condicao do registro para DBF
						If Empty(cMenIni)
							cMenIni := OemToAnsi(STR0168) + Chr(13) + Chr(10) //##"Inconsist�ncias de Fun��es:"
							aAdd(aLogProc, cMenIni)
							aAdd(aLogProc, "")
							aAdd(aLogProc, "")
						EndIf

						nContInc := Len(aLogProc)
						naux++
					Endif

					aAdd(aLogProc, PADR(AllTrim(SX3->X3_CAMPO), 10, " ") + " - " + PADR(AllTrim(SX3->X3_DESCRIC), 25, " ") + " - Mot.: " + OemToAnsi(STR0167))
					lGeraItem := .F.
				EndIf
			EndIf

			//RJ_DEDEXC
			If Empty((cAliasSRJ)->RJ_DEDEXC) .And. ( (!Empty((cAliasSRJ)->RJ_ACUM)) .Or. (!Empty((cAliasSRJ)->RJ_CTESP)) .Or. (!Empty((cAliasSRJ)->RJ_LEI)) .Or. (!Empty((cAliasSRJ)->RJ_DTLEI)) .Or. (!Empty((cAliasSRJ)->RJ_SIT)) )
				If SX3->(MsSeek("RJ_DEDEXC"))
					If(lGeraItem, aAdd(aLogProc, OemToAnsi(STR0040) + " " + OemToAnsi((cAliasSRJ)->RJ_FILIAL)+OemToAnsi((cAliasSRJ)->RJ_FUNCAO) + " -> " + OemToAnsi((cAliasSRJ)->RJ_DESC)),) //##"Fun��o "
					if naux == 1
						//Verificacao da condicao do registro para DBF
						If Empty(cMenIni)
							cMenIni := OemToAnsi(STR0168) + Chr(13) + Chr(10) //##"Inconsist�ncias de Fun��es:"
							aAdd(aLogProc, cMenIni)
							aAdd(aLogProc, "")
							aAdd(aLogProc, "")
						EndIf

						nContInc := Len(aLogProc)
						naux++
					Endif

					aAdd(aLogProc, PADR(AllTrim(SX3->X3_CAMPO), 10, " ") + " - " + PADR(AllTrim(SX3->X3_DESCRIC), 25, " ") + " - Mot.: " + OemToAnsi(STR0167))
					lGeraItem := .F.
				EndIf
			EndIf

			//RJ_LEI
			If Empty((cAliasSRJ)->RJ_LEI) .And. ( (!Empty((cAliasSRJ)->RJ_ACUM)) .Or. (!Empty((cAliasSRJ)->RJ_CTESP)) .Or. (!Empty((cAliasSRJ)->RJ_DEDEXC)) .Or. (!Empty((cAliasSRJ)->RJ_DTLEI)) .Or. (!Empty((cAliasSRJ)->RJ_SIT)) )
				If SX3->(MsSeek("RJ_LEI"))
					If(lGeraItem, aAdd(aLogProc, OemToAnsi(STR0040) + " " + OemToAnsi((cAliasSRJ)->RJ_FILIAL)+OemToAnsi((cAliasSRJ)->RJ_FUNCAO) + " -> " + OemToAnsi((cAliasSRJ)->RJ_DESC)),) //##"Fun��o "
					if naux == 1
						//Verificacao da condicao do registro para DBF
						If Empty(cMenIni)
							cMenIni := OemToAnsi(STR0168) + Chr(13) + Chr(10) //##"Inconsist�ncias de Fun��es:"
							aAdd(aLogProc, cMenIni)
							aAdd(aLogProc, "")
							aAdd(aLogProc, "")
						EndIf

						nContInc := Len(aLogProc)
						naux++
					Endif

					aAdd(aLogProc, PADR(AllTrim(SX3->X3_CAMPO), 10, " ")  +  " - " + PADR(AllTrim(SX3->X3_DESCRIC), 25, " ") + " - Mot.: " + OemToAnsi(STR0167))
					lGeraItem := .F.
				EndIf
			EndIf

			//RJ_DTLEI
			If Empty((cAliasSRJ)->RJ_DTLEI) .And. ( (!Empty((cAliasSRJ)->RJ_ACUM)) .Or. (!Empty((cAliasSRJ)->RJ_CTESP)) .Or. (!Empty((cAliasSRJ)->RJ_DEDEXC)) .Or. (!Empty((cAliasSRJ)->RJ_LEI)) .Or. (!Empty((cAliasSRJ)->RJ_SIT)) )
				If SX3->(MsSeek("RJ_DTLEI"))
					If(lGeraItem, aAdd(aLogProc, OemToAnsi(STR0040) + " " + OemToAnsi((cAliasSRJ)->RJ_FILIAL)+OemToAnsi((cAliasSRJ)->RJ_FUNCAO) + " -> " + OemToAnsi((cAliasSRJ)->RJ_DESC)),) //##"Fun��o "
					if naux == 1
						//Verificacao da condicao do registro para DBF
						If Empty(cMenIni)
							cMenIni := OemToAnsi(STR0168) + Chr(13) + Chr(10) //##"Inconsist�ncias de Fun��es:"
							aAdd(aLogProc, cMenIni)
							aAdd(aLogProc, "")
							aAdd(aLogProc, "")
						EndIf

						nContInc := Len(aLogProc)
						naux++
					Endif

					aAdd(aLogProc, PADR(AllTrim(SX3->X3_CAMPO), 10, " ") +  " - " + PADR(AllTrim(SX3->X3_DESCRIC), 25, " ") + " - Mot.: " + OemToAnsi(STR0167))
					lGeraItem := .F.
				EndIf
			EndIf

			//RJ_SIT
			If Empty((cAliasSRJ)->RJ_SIT) .And. ( (!Empty((cAliasSRJ)->RJ_ACUM)) .Or. (!Empty((cAliasSRJ)->RJ_CTESP)) .Or. (!Empty((cAliasSRJ)->RJ_DEDEXC)) .Or. (!Empty((cAliasSRJ)->RJ_LEI)) .Or. (!Empty((cAliasSRJ)->RJ_DTLEI)) )
				If SX3->(MsSeek("RJ_SIT"))
					If(lGeraItem, aAdd(aLogProc, OemToAnsi(STR0040) + " " + OemToAnsi((cAliasSRJ)->RJ_FILIAL)+OemToAnsi((cAliasSRJ)->RJ_FUNCAO) + " -> " + OemToAnsi((cAliasSRJ)->RJ_DESC)),) //##"Fun��o "
					if naux == 1
						//Verificacao da condicao do registro para DBF
						If Empty(cMenIni)
							cMenIni := OemToAnsi(STR0168) + Chr(13) + Chr(10) //##"Inconsist�ncias de Fun��es:"
							aAdd(aLogProc, cMenIni)
							aAdd(aLogProc, "")
							aAdd(aLogProc, "")
						EndIf

						nContInc := Len(aLogProc)
						naux++
					Endif

					aAdd(aLogProc, PADR(AllTrim(SX3->X3_CAMPO), 10, " ") + " - " + PADR(AllTrim(SX3->X3_DESCRIC), 25, " ") + " - Mot.: " + OemToAnsi(STR0167))
					lGeraItem := .F.
				EndIf
			EndIf

			If nContInc <> Len(aLogProc) .and. nContInc > 0
				aAdd(aLogProc, "")
			EndIf
			(cAliasSRJ)->(dbSkip())
		EndDo
	EndIf

	//Fecha alias em uso
	If (Select(cAliasSRJ) > 0)
		(cAliasSRJ)->(dbCloseArea())
	EndIf

	RestArea(aAreaSRJ)
	RestArea(aArea)

EndIf

Return()

/*/{Protheus.doc} fConsSind
	Faz a consist�ncia dos Sindicatos
@author claudinei.soares
@since 09/10/2017
@version P12
@param cMesAno, nOpcA, aLogProc, dDataRef, aDados, aArrayFil
@return Nil, Valor Nulo
/*/
Static Function fConsSind(cMesAno, nOpcA, aLogProc, dDataRef, aDados, aArrayFil)

Local cQryWhere   	:= "%"
Local cMenIni   	:= ""
Local cFilEnv		:= aArrayFil[2]
Local aArea		 	:= GetArea()
Local aAreaRCE  	:= RCE->(GetArea())
Local cAliasRCE		:= GetNextAlias()
Local lSemFilial	:= .F.
Local cFilDe		:= ""
Local cFilAte		:= ""

//Tratamento de compartilhamento da tabela RCE
If FWModeAccess("RCE", 1) == "C" .AND. FWModeAccess("RCE", 2) == "C" .AND. FWModeAccess("RCE", 3) == "C" //SRJ compartilhada
	lSemFilial := .T.
EndIf

If !Empty(cFilEnv)
	//Busca informacoes RCE - Sindicatos

	Pergunte("GPM035",.F.)
	cFilde := MV_PAR01
	cFilAte := MV_PAR02
	cQryWhere += "(RCE.RCE_FILIAL >= '" + xFilial("RCE",cFilde) + "' AND RCE.RCE_FILIAL <= '" + xFilial("RCE",cFilAte) + "') %"

	//Query para buscar informacoes de sindicato
	BeginSql alias cAliasRCE
		SELECT
			RCE_FILIAL, RCE_CODIGO, RCE_DESCRI, RCE_CGC
		FROM
			%table:RCE% RCE
		WHERE
			RCE.%notDel%
   		ORDER BY
   			RCE.RCE_FILIAL, RCE.RCE_CODIGO
	EndSql

	dbSelectArea(cAliasRCE)

	//Posiciona no inicio do arquivo
	(cAliasRCE)->(dbGoTop())
	While (cAliasRCE)->(!EOF())
		//Verificacao da condicao do registro para DBF
		If Empty(cMenIni)
			cMenIni := OemToAnsi(STR0196) + Chr(13) + Chr(10) //##"Inconsist�ncias de Sindicatos:"
			aAdd(aLogProc, cMenIni)
			aAdd(aLogProc, "")
			aAdd(aLogProc, "")
		EndIf

		If Empty((cAliasRCE)->RCE_CGC)
			SX3->(dbSetOrder(2))
			If SX3->(MsSeek("RCE_CGC"))
				aAdd(aLogProc, OemToAnsi(STR0197) + OemToAnsi((cAliasRCE)->RCE_FILIAL)+OemToAnsi((cAliasRCE)->RCE_CODIGO) + " -> " + OemToAnsi((cAliasRCE)->RCE_DESCRI)) //##"Processo "
				aAdd(aLogProc, AllTrim(SX3->X3_CAMPO) + " - " + AllTrim(SX3->X3_DESCRIC)+ " - Mot.: " + OemToAnsi(STR0167))
			EndIf
			aAdd(aLogProc, "")
		EndIf

		//Incrementa regua
		IncProc(OemToAnsi(STR0069) + " " + (cAliasRCE)->RCE_CODIGO + " " + (cAliasRCE)->RCE_DESCRI) //##"Gerando o registro de: "
		(cAliasRCE)->(dbSkip())
	EndDo
EndIf

RestArea(aAreaRCE)
RestArea(aArea)

Return()

/*/{Protheus.doc} fCargSRA
	Faz a consist�ncias dos trabalhadores com e sem vinculo
@author leandro.drumond
@since 28/12/2017
@version P12
@param aLogProc, aFilInTaf, nChamada, lRegua, oSelf, lChk5, lChk6
@return Nil, Valor Nulo
/*/
Static Function fCargSRA( aLogProc, aFilInTaf, nChamada, lRegua, oSelf, lChk5, lChk6)
Local aArea		:= GetArea()
Local aLogAnt	:= {}
Local aLogAux5	:= {}
Local aLogAux6	:= {}
Local cAliasSRA	:= GetNextAlias()
Local cQryWhere := "%"
Local cQueryCat :=""
Local cFilDe	:= ""
Local cFilAte	:= ""
Local cMatDe	:= ""
Local cMatAte	:= ""
Local cSituac 	:= ""
Local cSitQuery := ""
Local cMenIni	:= ""
Local cCateg	:= ""
Local cTrabVincu:= "%'101','102','103','104','105','106','111','301','302','303','305','306','309','701','711'%" //Trabalhador com vinculo
Local aFilTAF	:= ""
Local cEvento	:= ""
Local cTrabSV	:= ""
Local nReg		:= 0

If cVersGPE >= "2.3"
	cEvento := OemToAnsi(STR0221) //2200
Else
	cEvento := OemToAnsi(STR0220) //2100
EndIf

cTrabSV := "%'201','202','401','410'," //Trabalhador sem vinculo
cTrabSV += "'721','722','731','734','738','741','751','761','771','781','901'%"

Private  aCIC	:= {}

DEFAULT nChamada:= 1
DEFAULT lRegua	:= .F.

If !lChk5
	cQueryCat := "'C','D','H','I','J','M','S','T'"
	cCateg    := cTrabVincu
ElseIf !lChk6
	cQueryCat := "'A','E','G','P'"
	cCateg 	  := cTrabSV
Else
	cQueryCat := "'C','D','H','I','J','M','S','T','A','E','G','P'"
	cCateg    := "%'101','102','103','104','105','106','111','301','302','303','305','306','309','701','711','201','202','401','410','721','722','731','734','738','741','751','761','771','781','901'%" //Todas as categorias
EndIf

If nChamada == 2
	cCatQuery := ""
	cCategor	:= Rtrim(MV_PAR07)
	Pergunte("GPM035",.F.)
	cFilde := MV_PAR01
	cFilAte := MV_PAR02
	Pergunte("GPM035A",.F.)

	For nReg:=1 to Len(cCategor)
		If !lChk5 .and. Substr(cCategor,nReg,1) <>"A" .and. Substr(cCategor,nReg,1) <> "E" .and. Substr(cCategor,nReg,1) <>"G" .and. Substr(cCategor,nReg,1) <> "P"
			If Empty(cCatQuery)
				cCatQuery+= "'"+Substr(cCategor,nReg,1)+"'"
			Else
				cCatQuery+= ",'"+Substr(cCategor,nReg,1)+"'"
			EndIf
		ElseIf !lChk6 .and. ( Substr(cCategor,nReg,1) =="A" .or. Substr(cCategor,nReg,1) =="E" .or. Substr(cCategor,nReg,1) =="G" .or. Substr(cCategor,nReg,1) =="P" )
			If Empty(cCatQuery)
				cCatQuery+= "'"+Substr(cCategor,nReg,1)+"'"
			Else
				cCatQuery+= ",'"+Substr(cCategor,nReg,1)+"'"
			EndIf
		Else
			If Empty(cCatQuery)
				cCatQuery+= "'"+Substr(cCategor,nReg,1)+"'"
			Else
				cCatQuery+= ",'"+Substr(cCategor,nReg,1)+"'"
			EndIf
		EndIf
	Next nReg

	If Empty(cCatQuery)
		cCatQuery := "'*'"
	EndIf

	cSitQuery := ""
	cSituac	:= Rtrim(MV_PAR08)

	For nReg:=1 to Len(cSituac)
		cSitQuery += "'"+Subs(cSituac,nReg,1)+"'"
		If ( nReg+1 ) <= Len(cSituac)
			cSitQuery += ","
		EndIf
	Next nReg

	cQryWhere += "(RA_FILIAL >= '" + cFilde  + "' AND RA_FILIAL <= '" + cFilAte  + "') AND "
	cQryWhere += "(RA_MAT >= '" + MV_PAR01 + "' AND RA_MAT <= '" + MV_PAR02 + "') AND "
	cQryWhere += "(RA_CC >= '" + MV_PAR03 + "' AND RA_CC <= '" + MV_PAR04 + "') AND "
	cQryWhere += "(RA_NOME >= '" + MV_PAR05 + "' AND RA_NOME <= '" + MV_PAR06 + "') AND "
	cQryWhere += "(RA_CATFUNC IN (" + cCatQuery + ")) "

	If !Empty(cSitQuery)
		cQryWhere += "AND (RA_SITFOLH IN (" + cSitQuery + "))"
	EndIf

	cQryWhere += "%"
Else
	Pergunte("GPM035",.F.)
	cFilde	 := MV_PAR01
	cFilAte := MV_PAR02
	cMatde	 := MV_PAR04
	cMatAte := MV_PAR05
	cSituac := Rtrim(MV_PAR06)
	For nReg:=1 to Len(cSituac)
		cSitQuery += "'"+Subs(cSituac,nReg,1)+"'"
		If ( nReg+1 ) <= Len(cSituac)
			cSitQuery += ","
		EndIf
	Next nReg

	cQryWhere += "(RA_FILIAL >= '" + cFilde  + "' AND RA_FILIAL <= '" + cFilAte + "') AND "
	cQryWhere += "(RA_MAT >= '" + cMatde  + "' AND RA_MAT <= '" + cMatAte + "') AND "
	cQryWhere += "(RA_CATFUNC IN (" + cQueryCat + ")) "
	If !Empty ( cSitQuery )
		cQryWhere += " AND (RA_SITFOLH IN (" + cSitQuery + "))"
	EndIf
	cQryWhere += "%"
EndIf

If lRegua
	BeginSql alias cAliasSRA
		SELECT
			COUNT(*) AS CONTADOR
		FROM
			%table:SRA% SRA
		WHERE
			SRA.%notDel% AND
			( SRA.RA_CATEFD IN ( %exp:cCateg% ) OR SRA.RA_CATEFD = %exp:" "%) AND
			%exp:cQryWhere%
	EndSql

	oSelf:SetRegua2((cAliasSRA)->CONTADOR)

	dbSelectArea(cAliasSRA)
	DbCloseArea()

	cAliasSRA	:= GetNextAlias()
EndIf

//Query para buscar informacoes Trabalhadores
BeginSql alias cAliasSRA
	SELECT
		RA_FILIAL, RA_MAT, RA_CIC, RA_PIS, RA_NOMECMP, RA_NOME, RA_SEXO,
		RA_RACACOR, RA_ESTCIVI, RA_GRINRAI,RA_TPDEFFI,RA_REGRA,RA_SEQTURN,
		RA_NASC, RA_CODMUNN, RA_NATURAL, RA_CPAISOR, RA_NACIONC,RA_TPPREVI,
		RA_MAE, RA_PAI, RA_NUMCP, RA_SERCP, RA_UFCP,
		RA_NUMRIC,RA_EMISRIC , RA_DEXPRIC, RA_RG, RA_RGEXP,RA_DTRGEXP,
		RA_RNE, RA_RNEORG, RA_RNEDEXP, RA_CODIGO, RA_OCEMIS, RA_OCDTEXP, RA_OCDTVAL, RA_HABILIT,
		RA_CNHORG, RA_DTEMCNH, RA_DTVCCNH, RA_RESEXT,RA_VIEMRAI,
		RA_LOGRTP, RA_LOGRDSC, RA_LOGRNUM,RA_COMPLEM, RA_BAIRRO, RA_CEP, RA_CEPCXPO, RA_CODMUN,
		RA_ESTADO, RA_PAISEXT, RA_CODMUN, RA_ESTADO, RA_MUNICIP, RA_CPOSTAL,
		RA_TELEFON, RA_DDDFONE, RA_NUMCELU, RA_DDDCELU,RA_EAPOSEN,
		RA_DATCHEG, RA_DATNATU, RA_CASADBR, RA_FILHOBR,RA_TPJORNA,
		RA_PORTDEF,RA_TELEFON, RA_NUMCELU, RA_EMAIL, RA_EMAIL2, RA_TPCONTR,
		RA_ADMISSA, RA_DEMISSA, RA_CATEFD,RA_CODFUNC, RA_CARGO, RA_SALARIO,
		RA_CATFUNC, RA_ALTOPC, RA_OPCAO, RA_CC, RA_CLASEST
	FROM
		%table:SRA% SRA
	WHERE
		SRA.%notDel% AND
		( SRA.RA_CATEFD IN ( %exp:cCateg% ) OR SRA.RA_CATEFD = %exp:" "%) AND
		%exp:cQryWhere%
	ORDER BY
		SRA.RA_FILIAL, SRA.RA_MAT
EndSql

dbSelectArea(cAliasSRA)

aLogAnt := aClone(aLogProc) //Clona log para posterior montagem

If lRegua
	oSelf:IncRegua1(STR0230 + STR0066) //Processando Cadastramento Inicial do v�nculo
EndIf

aFilTAF := fGM35Fil(aFilInTaf)

aLogProc := {}

While (cAliasSRA)->(!Eof())
	If lRegua
		oSelf:IncRegua2(STR0230 + STR0143 + " " + (cAliasSRA)->RA_FILIAL + " - " + (cAliasSRA)->RA_MAT) //"Processando Filial/Mat:"
	EndIf

	If lChk6 .and. ( Empty((cAliasSRA)->RA_CATEFD) .or. (cAliasSRA)->RA_CATEFD $ cTrabVincu ) .and. (cAliasSRA)->RA_CATFUNC $ "C*D*H*I*J*M*S*T"
		fG17VSRA(cAliasSRA,2,,,cVersEnvio)
		aEval( aLogProc , { |X| aAdd(aLogAux6, X) } ) //Coloca o log no array auxiliar
		aLogProc := {}
	EndIf

	If lChk5 .and. ( Empty((cAliasSRA)->RA_CATEFD) .or. (cAliasSRA)->RA_CATEFD $ cTrabSV ) .and. (cAliasSRA)->RA_CATFUNC $ "A*E*G*P"
		fG17VSRA(cAliasSRA,2,,,cVersEnvio)
		aEval( aLogProc , { |X| aAdd(aLogAux5, X) } ) //Coloca o log no array auxiliar
		aLogProc := {}
	EndIf

	(cAliasSRA)->(DbSkip())
EndDo

aLogProc := aClone(aLogAnt) //Retorna log original

If lChk6
	aAdd(aLogProc, "")
	cMenIni := OemToAnsi(STR0084)+": "+ IIF(cEvento == "2200", OemToAnsi(STR0233), OemToAnsi(STR0234)) 	//##Inconsist�ncias | S-2200 Cadastramento Inicial do V�nculo | S-2300 Trabalhador Sem V�nculo de Emprego
	aAdd(aLogProc, cMenIni)
	aAdd(aLogProc, "")
	aAdd(aLogProc, OemToAnsi(STR0085)) //##"Devido as inconsistencias abaixo: campos sem conteudo ou Trabalhadores com Multiplos Vinculos, os registros n�o ser�o enviados ao TAF:"
	For nReg := 1 to Len(aLogAux6)
		aAdd(aLogProc, aLogAux6[nReg])
	Next nReg
EndIf

If lChk5
	aAdd(aLogProc, "")
	If cVersGPE <= "2.3"
		cMenIni := OemToAnsi(STR0084)+ ":" + OemToAnsi(STR0202)//"S-2100 Cadastramento Inicial do V�nculo"
	Else
		cMenIni := OemToAnsi(STR0084)+ ": " + IIF(cEvento == "2200", OemToAnsi(STR0233), OemToAnsi(STR0234))//"S-2200 Cadastramento Inicial do V�nculo | S-2300 Trabalhador Sem V�nculo de Emprego"
	EndIf
	aAdd(aLogProc, cMenIni)
	aAdd(aLogProc, "")
	aAdd(aLogProc, "")
	For nReg := 1 to Len(aLogAux5)
		aAdd(aLogProc, aLogAux5[nReg])
	Next nReg
EndIf

RestArea(aArea)

Return Nil
