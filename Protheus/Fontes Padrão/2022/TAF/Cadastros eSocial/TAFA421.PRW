#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA421.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "APWIZARD.CH"

STATIC lLaySimplif := taflayEsoc("S_01_00_00")

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA421

Cadastro MVC da Cadastro do Trabalhador - Com ou Sem Vínculo

@author Paulo Sérgio V.B. Santana
@since 03/02/2016 
@version 1.0S

/*/
//--------------------------------------------------------------------
Function TAFA421()

	Private oBrw := FwMBrowse():New()

	If TafAtualizado()

		oBrw:SetDescription( STR0001 ) //"Cadastro do Trabalhador - Com ou Sem Vínculo"
		oBrw:SetAlias( "C9V" )
		oBrw:SetMenuDef( "TAFA421" )

		If FindFunction('TAFBrwSetFilter')
			oBrw:SetFilterDefault(TAFBrwSetFilter("C9V","TAFA421")   )
		Else
			oBrw:SetFilterDefault( "C9V_ATIVO == '1' .And. C9V_NOMEVE <> 'S2399' .And. C9V_NOMEVE <> 'TAUTO'" )
		EndIf
		
		TafLegend(2,"C9V",@oBrw)

		oBrw:Activate()
	EndIf
    
Return ( Nil )

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funçao generica do MVC com as opcoes de menu

@Return aRotina - Array com as opções do Menu

@author Denis R. de Oliveira
@since 03/02/2016
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aFuncao 		:= {}
	Local aRotina 		:= {}
	Local aRotExcl		:= {}
	Local cFunName		:= FunName()
	Local lAltFunName	:= .F.

	// Como a MenuDef é chamada em rotinas de FrameWork e o TAF "customiza" ela, força o nome do menu chamador, para que o comportamento seja idêntico em ambas chamadas.
	If !FWIsInCallStack( "TAFA421" )
		lAltFunName := .T.
		SetFunName( "TAFA421" )
	EndIf

	//Indica se o menu tera todas as opções de cadastro ou apenas a visualização
	lMenuDIf := Iif( Type( "lMenuDIf" ) == "U", .F., lMenuDIf )

	Aadd( aFuncao, { "" , "TAF421XMLVLD(1)"	, "1" } )
	Aadd( aFuncao, { "" , "xCarrHisAlt" 	, "3" } )
	Aadd( aFuncao, { "" , "ExcXmlLote" 		, "5" } )
	Aadd( aFuncao, { "" , "xFunAltRec( 'C9V' )" , "10" } )

	If (!lMenuDIf .And. cModulo <> "CFG") .Or. cModulo == "CFG"
		aRotina	:=	xFunMnuTAF( "TAFA421" , , aFuncao )
	EndIf


	If (lMenuDIf .And. cModulo <> "CFG" .And. IsInCallStack("xCarrHisAlt")) .Or. cModulo == "CFG"

		If cModulo != "CFG"
			ADD OPTION aRotina Title STR0002 Action 'xCarrVisul' OPERATION 2 ACCESS 0 //"Visualizar"
		EndIf

		// Verifica se contempla eventos extemporaneos
		If FindFunction( "TafxExtemp" ) .And. TafxExtemp()

			ADD OPTION aRotina Title 'Inclusão Extp.' 		Action "AltEvtExtemp('A')" 		OPERATION 3 ACCESS 0
			ADD OPTION aRotina Title 'retificação Extp.' 	Action "AltEvtExtemp('R')" 		OPERATION 4 ACCESS 0
			ADD OPTION aRotina Title 'Excluir Extp.' 		Action "" 						OPERATION 5 ACCESS 0
			ADD OPTION aRotina Title "Ajuste de Recibo"		Action 'xFunAltRec() 	'		OPERATION 3 ACCESS 0

			If FindFunction( "TAFA567" )//TELA DO COMPARADOR DE EVENTOS
				ADD OPTION aRotina Title 'Comparar Registros'	Action "TAFA567()" OPERATION 9 ACCESS 0
			EndIf
			//Grupo de opções para exclusão
			Aadd(aRotExcl,{"Excluir Registro"					, "DelEvtExtemp('E','1')"	, 0, 3, 0, Nil, Nil, Nil} )
			Aadd(aRotExcl,{"Desfazer Exclusão"					, "DelEvtExtemp('E','2')"	, 0, 5, 0, Nil, Nil, Nil} )
			Aadd(aRotExcl,{"Visualizar Registro de Exclusão"	, "DelEvtExtemp('E','3')"	, 0, 2, 0, Nil, Nil, Nil} )

			aRotina[4][2] := aRotExcl

		EndIf

	EndIf

	// Restaura o valor inicial do FunName() caso tenha sido alterada
	If lAltFunName
		SetFunName(cFunName)
	EndIf

Return( aRotina )

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@Return Nil

@author Denis R. de Oliveira
@since 03/02/2016
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

Return ( Nil )

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@Return Nil

@author Denis R. de Oliveira
@since 03/02/2016
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} InclCadTrab
Funçao que realiza a Inclusão do Cadastro Trabalhador

@Return 

@Author Denis R de Oliveira
@Since 03/02/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Function InclCadTrab()

	Local nOpc		:= 0
	Local aOpcoes	:= {}
	Local cTitulo	:= STR0003 //Inclusão do trabalhador
	Local cMens		:= STR0004 //Selecione o Evento que deseja incluir

	Aadd(aOpcoes,STR0005)    //S-2200
	aAdd(aOpcoes,STR0006)    //S-2300

	nOpc:= SelecOpc(aOpcoes,'INCLUI','3',cTitulo,cMens)

	If nOpc == 1
	
		If TafAtualizado(, "TAFA278")
			FWMsgRun(,{||FWExecView(STR0003, "TAFA278", 3,,{||.T.} )},,STR0087) //"Executando Rotina do Trabalhador... "
		EndIf

	ElseIf nOpc == 2
		FWMsgRun(,{||FWExecView(STR0003, "TAFA279", 3,,{||.T.} )},,STR0087) //"Executando Rotina do Trabalhador... "
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AltCadTrab
Funcao que gera o evento de Alteração do Cadastro do Trabalhador

@Return 

@Author Paulo Sérgio V.B Santana
@Since 03/02/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Function AltCadTrab()

	Local cTitulo			:= ""
	Local cRotina			:= ""
	Local nOpc 				:= 0
	Local aOpcoes			:= {} //Lista de opções de Tipo de Alteração
	Local cStat2205			:= "" //Status do Evento de Alteção do Trabalhador S2205
	Local cStat2206			:= "" //Status do Evento de Alteção do Trabalhador S2206
	Local cStat2306			:= "" //Status do Evento de Alteção do Trabalhador S2306
	Local nOpcAviso			:= 0
	Local cEvento			:= ""
	Local nOpera			:= 0  //Operação a ser realizada
	Local cChvTrab			:= ''
	Local lPermiAlt			:= .T.
	Local cNomEvC9V			:= ""
	Local cVerAnt  			:= ""
	Local cChvVAnt			:= ""
	Local nCodMen			:= 0
	Local cStatAlt			:= ""
	Local aAreaC9V			:= {}
	Local aAreaCMD			:= {}
	Local aAreaCMF			:= {}
	Local nExView			:=	-1

	Private cStaEvC9V		:= "" //Status do Registro do Evento do Trabalhador (S2200 ou S2300)
	Private lExist2205		:= .F.
	Private lExist2206		:= .F.
	Private lExist2306		:= .F.
	Private lExist2399 		:= .F.
	Private lExist2299		:= .F.
	Private ALTERA
	Private INCLUI

	cStaEvC9V	:= C9V->C9V_STATUS
	cNomEvC9V	:= C9V->C9V_NOMEVE
	cVerAnt  	:= C9V->C9V_VERANT
	cChvVAnt 	:= C9V->( C9V_ID + C9V_VERANT ) + cNomEvC9V
	cTitulo  	:= STR0058 + Iif(cNomEvC9V == "S2300",STR0055,STR0059)

	If TAFColumnPos( "C9V_IDTRAN" ) .And. C9V->C9V_ATIVO == "2" .And. C9V->C9V_IDTRAN <> ''

		msgAlert(xValStrEr("001137")) //"Registro não pode ser alterado. Este funcionário encontra-se transferido para outra Filial."

	ElseIf cStaEvC9V == '4'
		
		cChvTrab:= C9V->C9V_ID + '1'
		aOpcoes := {STR0023}//"nOpc = 1#retificar Evento do Trabalhador"

		If cNomEvC9V $ ('S2200')

			//Caso existir um S-2299 valido (STATUS = 4) ao trabalhador sem vinculo valido (STATUS = 4) não é permitido realizar uma alteração no S2205 e S2206.
			aAreaCMD := CMD->(getArea())
			CMD->( DbSetOrder( 2 ) )//CMD_FILIAL, CMD_FUNC, CMD_DTDESL, CMD_ATIVO, R_E_C_N_O_, D_E_L_E_T_
			If CMD->(MsSeek(xFilial("CMD")+ C9V->C9V_ID ))
				If CMD->CMD_ATIVO == "1"
					lExist2299 := .T.

					//VERIFICA SE EXISTE UMA REINTEGRAÇÃO S-2298
					aAreaCMF := CMF->(GetArea())

					CMF->(DbSetOrder(2)) //CMF_FILIAL+CMF_FUNC+DTOS(CMF_DTRET)+CMF_ATIVO
					If CMF->(MsSeek(xFilial('CMF') + C9V->C9V_ID))
						While CMF->(!EOF()) .And. xFilial('CMF') == CMF->CMF_FILIAL .And. C9V->C9V_ID == CMF->CMF_FUNC
							If CMF->CMF_ATIVO == '1' .And. CMF->CMF_DTRET >=  CMD->CMD_DTDESL .And. CMF->CMF_STATUS == '4'
								lExist2299 := .F.
								Exit
							EndIf
							CMF->(DbSkip())
						EndDo
					EndIf
					RestArea(aAreaCMF)

				EndIf
			EndIf
			RestArea(aAreaCMD)
			//==================================================================================++
			// O sistema permite ao usuário inserir varios eventos de alteração (S2205/S2206)	||
			// para o mesmo trabalhador com datas dIferentes. Porém apenas é permitido retificar||
			// o último evento de alteração enviado. Por isso a função RetUltAtivo posiciona no	||
			// registro ativo com a maior data. 												||
			//==================================================================================++

			//Caso exista um Evento S-2205 Ativo para o trabalhador eu insiro a opção de retificar"
			If RetUltAtivo('T1U',cChvTrab,2,.T.)
				If !lExist2299
					aAdd(aOpcoes,STR0030) //nOpc = 4#"retificar Dados Cadastrais (S-2205)"
					lExist2205	:= .T.
				EndIf
			EndIf

			//Caso existe um Evento S-2206 Ativo para o trabalhador eu insiro a opção de retificar"
			If RetUltAtivo('T1V',cChvTrab,2,.T.)
				If !lExist2299
					aAdd(aOpcoes,STR0031) //nOpc = 5#"retificar Dados Contratuais (S-2206)"
					lExist2206	:= .T.
				EndIf
			EndIf

			If lExist2205
				cStat2205 := T1U->T1U_STATUS
				//Caso o Status do evento de alteração seja 2 eu não permito a alterações pois o evento está em processo de transmissão.
				If cStat2205 == '2'
					lPermiAlt:= .F.
				EndIf
			EndIf

			If lExist2206
				cStat2206 := T1V->T1V_STATUS
				//Caso o Status do evento de alteração seja 2 eu não permito a alterações pois o evento está em processo de transmissão.
				If cStat2206 == '2'
					lPermiAlt:= .F.
				EndIf
			EndIf

			If lPermiAlt

				If !lExist2299
					aAdd(aOpcoes,STR0028) //nOpc = 2#Alterar Dados Cadastrais (S-2205)
				EndIf

				If !lExist2299
					aAdd(aOpcoes,STR0029) //nOpc = 3#Alterar Dados Contratuais (S-2206)
				EndIf

				//===========================================================================================+
				// nOpc == 2 - Alterar Dados Cadastrais (S-2205) # S-2200                                   ||
				// nOpc == 3 - Alterar Dados Contratuais (S-2206) # S-2300                                  ||
				// nOpc == 4 - retificar Alteração de Dados Cadastrais (S-2205) # S-2205                    ||
				// nOpc == 5 - retificar Alteração de Dados Contratuais (S-2206) # S-2206                   ||
				// nOpc == 6 - Alterar Dados Contratuais - Trab. Sem Vínculo (S-2306) # S-2306              ||
				// nOpc == 7 - retificar Alteração Contratual - Trab. Sem Vínculo (S-2306)                  ||
				//===========================================================================================+
				nOpc:= SelecOpc(aOpcoes,cNomEvC9V) //Abro a tela com as opções de alteração para o usuário

				If nOpc > 0

					//Opc = 2-Alteração de Dados Cadastrais S2205
					//Opc = 2-retificação de Dados Cadastrais S2205
					//Opc= 3-Alteração de Dados Contratuais S2206
					//Opc = 5-retificação Alteração de Dados Contrat. RET S2206

					If nOpc == 2 .Or. nOpc == 11 .Or. nOpc == 4 .Or. nOpc == 13

						cTitulo	:= STR0020   //"Alteração de Dados Cadastrais do Trabalhador"
						cRotina	:= "TAFA275"

						RetUltAtivo('T1U',cChvTrab,2,IIF(nOpc == 4 .or. nOpc == 13,.T.,.F.) )

						If lExist2205
							cEvento		:= T1U->T1U_EVENTO
							cStat2205	:= T1U->T1U_STATUS
						EndIf

					ElseIf nOpc == 3 .or. nOpc == 5 .or. nOpc == 12 .or. nOpc == 14

						cTitulo	:= STR0021   //"Alteração de Contrato de Trabalho"
						cRotina	:= "TAFA276"

						RetUltAtivo('T1V',cChvTrab,2,IIF(nOpc == 5 .or. nOpc == 14,.T.,.F.) )

						If lExist2206
							cEvento		:= T1V->T1V_EVENTO
							cStat2206	:= T1V->T1V_STATUS
						EndIf
					Else
						cRotina := "TAFA278"
					EndIf
				EndIf
			Else
				msgAlert(xValStrEr("000727")) //"Registro não pode ser alterado. Aguardando processo da transmissão."
			EndIf

		Else //S-2300

			//Caso existir um 2399 valido (STATUS = 4) ao trabalhador sem vinculo valido (STATUS = 4) não é permitido realizar uma alteração no S2306.
			aAreaC9V := C9V->(getArea())

			DBSelectArea("T92")
			T92->(DBSetOrder(3))
			// VerIfica se existe existe evento de termino para o trabalhador S-2399
			T92->(DBSeek(xFilial("T92")+ C9V->C9V_ID  + "1"))

			While T92->(!Eof()) .And. alltrim(T92->T92_TRABAL) == alltrim(C9V->C9V_ID)
				If T92->T92_STATUS =="4"
					lExist2399 := .T.
				EndIf
				T92->(dbSkip())
			EndDo

			RestArea(aAreaC9V)

			If !lExist2399
				aAdd(aOpcoes,STR0028) //nOpc = 2 #Alterar Dados Cadastrais (S-2205)
				aAdd(aOpcoes,STR0039) //nOpc = 6 #""Alteração Dados Contrat. - Trab. Sem Vínculo (S-2306)"
			EndIf

			//Caso exista um Evento S-2205 Ativo para o trabalhador eu insiro a opção de retificar"
			If RetUltAtivo('T1U',cChvTrab,2)

				lExist2205:= .T.
				cStat2205 := T1U->T1U_STATUS
				cEvento		:= T1U->T1U_EVENTO
				//Caso o Status do evento de alteração seja 2 eu não permito a alterações pois o evento está em processo de transmissão.
				If cStat2205 $ "2|6"
					lPermiAlt:= .F.
				EndIf

				If !lExist2399 .AND. T1U->T1U_STATUS == "4"
					aAdd(aOpcoes,STR0030) //nOpc = 4#"retificar Dados Cadastrais (S-2205)"
				EndIf
			EndIf

			//Caso exista um Evento S-2306 Ativo para o trabalhador eu insiro a opção de retificar"
			If RetUltAtivo('T0F',cChvTrab,2,.T.)
				aAdd(aOpcoes,STR0038) //nOpc = 7 "retificação Alteração Contr.-Trab. Sem Vínculo (S-2306)"
				lExist2306	:= .T.
				cEvento	:= T0F->T0F_EVENTO
				cStat2306 	:= T0F->T0F_STATUS
				RetUltAtivo('T0F',cChvTrab,2,IIF(nOpc == 7.OR. nOpc == 15,.T.,.F.) )
			EndIf

			//caso exista uma alteração para o trabalhador em processo de transmissão eu não permito outra alteração
			If cStat2306 <> '2'

				//Abro a tela com as opções de alteração para o usuário
				nOpc:= SelecOpc(aOpcoes,cNomEvC9V)
				If nOpc == 6 .or. nOpc == 7 .OR. nOpc == 16 .OR. nOpc == 15
					cTitulo	:= Iif(nOpc == 6 .OR. nOpc == 16,STR0039,STR0038) //"Alteração de Dados Contratuais - Trab. Sem Vínculo (S-2306)#retificação Alteração Contratual - Trab. Sem Vínculo (S-2306)
					cRotina	:= "TAFA277"
					RetUltAtivo('T0F',cChvTrab,2,IIF(nOpc == 6 .OR. nOpc == 16,.T.,.F.) )
				ElseIf nOpc == 2 .OR. nOpc == 4 .OR. nOpc == 11 .OR. nOpc == 13
					cTitulo	:= STR0020   //"Alteração de Dados Cadastrais do Trabalhador"
					cRotina	:= "TAFA275"
				ElseIf nOpc == 1 .OR. nOpc == 10
					cTitulo	:= STR0034
					cRotina	:= "TAFA279"
				EndIf
			EndIf
		EndIf

		If nOpc > 0

			//===================================================================================================================+
			// Chamo a Função RetCodMen o nCodMen (código de mensagem com status da operação), que será usado para validar as   ||
			// Regras de alteração.                                                                                             ||
			// nCodMen:                                                                                                         ||
			// 1 - Registro de Alteração Pendente de transmissão (Status $ " |1") - NÃO PODERÁ SER ALTERADO!!!                  ||
			// 2 - Registro de Alteração Em Processo de transmissão (Status == "2") - NÃO PODERÁ SER ALTERADO!!!                ||
			// 3 - Registro de Alteração com Inconsistencia apresentada pelo FISCO (Status == "3")-NÃO PODERÁ SER ALTERADO!!!   ||
			// 4 - Todos os eventos de alteração estão transmitidos - ALTERAÇÃO PERMITIDA!                                      ||
			// 0 - Não existe evento de alteração para este trabalhador - ALTERAÇÃO PERMITIDA!                                  ||
			//==================================================================================================================||
			// REGRAS:                                                                                                          ||
			// REGRA 1 - Quando se tratar de uma retificação do evento PAI (2200/2300), apenas será permitida a alteração, ||
			// se não houver nenhum evento de alteração pendente de transmissão (nCodMen == 4 ou 0)                             ||
			// REGRA 2 - Quando se tratar de uma INCLUSÃO de evento de ALTERAÇÃO (2205/2206/2306), ao invés de olhar para o     ||
			// nCodMen eu apenas verIfico o Status do último registro que ativo para o evento q está sendo incluso e somente	||
			// permito a inclusão se não houver nenhum outro evento ativo (DO MESMO EVENTO), pendente de transmissão.           ||
			// REGRA 3 - Quando se tratar de uma retificação do evento de ALTERAÇÃO eu efetuo a alteração direta do registro, se||
			// ele não estiver pendente de transmissão.                                                                         ||
			//===================================================================================================================+
			// ============================================= A T E N Ç Ã O ======================================================+
			// ATENÇÃO -> Durante o processo de alteração, NUNCA haverá um evento de ALTERAÇÃO, em processo                     ||
			// de transmissão de EXCLUSÃO (STATUS = 6) ou Excluído (STATUS = 7), pois NÃO SERÁ permitido                        ||
			// excluir uma alteração sem que seja excluído o Cadastro do Trabalhado (2200/2300)                            ||
			//===================================================================================================================+

			nCodMen := RetCodMen(@cStat2205,@cStat2206,@cStat2306)

			//================================== OPÇÕES DE ALTERAÇÃO ==========================================+
			// nOpc == 1 - retificar Evento do Trabalhador # S-2200/2300                                 ||
			// nOpc == 2 - Alterar Dados Cadastrais (S-2205) # S-2205                                         ||
			// nOpc == 3 - Alterar Dados Contratuais (S-2206) # S-2206                                        ||
			// nOpc == 4 - retificar Alteração de Dados Cadastrais (S-2205) # S-2205                          ||
			// nOpc == 5 - retificar Alteração de Dados Contratuais (S-2206) # S-2206                         ||
			// nOpc == 6 - Alterar Dados Contratuais - Trab. Sem Vínculo (S-2306) # S-2306                    ||
			// nOpc == 7 - retificar Alteração Contratual - Trab. Sem Vínculo (S-2306)                        ||
			//=================================================================================================+
			If nOpc == 1 .or. nOpc == 10

				INCLUI := .F.
				ALTERA := .T.

				nOpera := MODEL_OPERATION_UPDATE // Seto a Operação para Alteração
				//==============================================================================================+
				// retificar Evento do Trabalhador S-2200/2300                                            ||
				// Quando se tratar de uma retificação do Evento do Trabalhador eu só permito a retificação se ||
				// se não houver nenhum evento de alteração (2205/2206/2306) pendente. Se houver algum evento  ||
				// pendente de transmissão o usuário deve excluir para continuar.                              ||
				//==============================================================================================+
				If nCodMen == 0
					//Alteração direta no evento de alteração
					FWMsgRun(,{||nExView:=FWExecView(STR0073,cRotina,nOpera,,{||.T.} )},,STR0087) //"Executando Rotina do Trabalhador... "

				ElseIf nCodMen == 1 .or. nCodMen == 3 .OR. nCodMen == 4

					INCLUI := .F.
					ALTERA := .T.

					nOpera := MODEL_OPERATION_UPDATE // Seto a Operação para Alteração

					If nCodMen == 1
						//Não permito retificação do evento do trabalhador se houver um evento de alteração S2205/2206/23005 pendente.
						nOpcAviso := Aviso( STR0023,"Existe um evento" + STR0044 + CRLF + "Deseja Excluir o evento para gerar uma "+;
							"retificação do trabalhador?", { "Sim", "Não" },3 ) //em processo de transmissão ao RET.# Existe um evento de alteração #.
					ElseIf nCodMen == 3
						nOpcAviso := Aviso( STR0023,"Existe um evento" + STR0045 + CRLF + "Deseja Excluir este evento para gerar uma "+;
							"retificação do trabalhador?", { "Sim", "Não" },3 ) //em processo de transmissão ao RET.# Existe um evento de alteração #.
					ElseIf nCodMen == 4

						If C9V->C9V_NOMEVE == "S2200"
							If TAFCONF22()

								If TafAtualizado(, cRotina)
									FWMsgRun(,{||nExView:=FWExecView(STR0073,cRotina,nOpera,,{||.T.} )},,STR0087) //"Executando Rotina do Trabalhador... "
								EndIf
								
							EndIf
						Else
							MsgAlert( xValStrEr("001081") )
						EndIf
					Else
						//Alteração direta no evento de alteração
						FWMsgRun(,{||nExView:=FWExecView(STR0073,cRotina,nOpera,,{||.T.} )},,STR0087) //"Executando Rotina do Trabalhador... "
					EndIf

					If nOpcAviso == 1
						If cStat2205 == '1' //Se registro pedente for o 2205 Deleto
							DelEvento("TAFA275")
							lExist2205 := .F.
						EndIf
						If cStat2206 == '1'
							DelEvento("TAFA276")
							lExist2206 := .F.
						EndIf
						If cStat2306 == '1'
							DelEvento("TAFA277")
							lExist2306 := .F.
						EndIf

						// Caso ainda existe um evento de alteração eu carrego no modelo que irá gerar a retificação do evento
						If lExist2205 .or. lExist2206 .or. lExist2306
							//Carrego o modelo consolidando as informações para alteração das informações
							FWMsgRun(,{||TafCarrModel(cTitulo,cRotina,nOpera,nOpc)},,STR0087) //"Executando Rotina do Trabalhador... "
						Else
							//Alteração direta no evento de alteração
							FWMsgRun(,{||nExView:=FWExecView(cTitulo,cRotina,nOpera,,{||.T.} )},,STR0087) //"Executando Rotina do Trabalhador... "
						EndIf

					EndIf

				ElseIf nCodMen == 2
					msgAlert(xValStrEr("000727")) //"Registro não pode ser alterado, pois se encontra em processo de transmissão"
				EndIf

			//Inclusão de evento de alteração 2205/2206/2306
			ElseIf nOpc == 2 .or. nOpc == 3 .or. nOpc == 6 .or. nOpc == 11 .or. nOpc == 12 .or. nOpc == 16

				nOpera := MODEL_OPERATION_INSERT //Seta a operação de INCLUSÃO

				If nOpc == 2 .or. nOpc == 11
					cStatAlt := cStat2205
				ElseIf nOpc == 3 .or. nOpc == 12
					cStatAlt := cStat2206
				Else
					cStatAlt := cStat2306
				EndIf		

				If TafAtualizado(, cRotina)
					If cStatAlt $ '0|4'//não existe evento de alteração pendente de transmissão
						FWMsgRun(,{||TafCarrModel(cTitulo,cRotina,nOpera,nOpc)},,STR0087) //"Executando Rotina do Trabalhador... "

					ElseIf cStatAlt == '1' .or. cStatAlt == '3'
						//Não permito retificação do evento do trabalhador se houver um evento de alteração S2205/2206/23005 pendente.
						If cStatAlt == '1'
							nOpcAviso := Aviso( STR0023,"Existe um evento" + STR0044 + CRLF + "Deseja Excluir o evento para gerar uma "+;
								"retificação do trabalhador?", { "Sim", "Não","Cancelar" },3 ) //em processo de transmissão ao RET.# Existe um evento de alteração #.
						ElseIf cStatAlt == '3'
							nOpcAviso := Aviso( STR0023,"Existe um evento" + STR0045 + CRLF + "Deseja Excluir este evento para gerar uma "+;
								"retificação do trabalhador?", { "Sim", "Não","Cancelar" },3 ) //em processo de transmissão ao RET.# Existe um evento de alteração #.
						EndIf

						If nOpcAviso == 1
							//Deleto o registro pendente
							DelEvento(Iif(nOpc == 2 .or. nOpc == 11,"TAFA275",Iif(nOpc == 3 .or. nOpc == 12, "TAFA276", "TAFA277")))
							//Carrego o modelo consolidando as informações para alteração das informações
							FWMsgRun(,{||TafCarrModel(cTitulo,cRotina,nOpera,nOpc)},,STR0087) //"Executando Rotina do Trabalhador... "
						ElseIf nOpcAviso == 2
							FWMsgRun(,{||TafCarrModel(cTitulo,cRotina,nOpera,nOpc)},,STR0087) //"Executando Rotina do Trabalhador... "
						EndIf

					Else //cStatAlt == 2 - Evento em processo de transmissão
						msgAlert(xValStrEr("000727")) //"Registro não pode ser alterado, pois se encontra em processo de transmissão"
					EndIf

				EndIf

			
			//retificação de um evento de alteração.
			ElseIf nOpc == 4 .or. nOpc == 5 .or. nOpc == 7 .or. nOpc == 13 .or. nOpc == 14 .or. nOpc == 15

				INCLUI := .F.
				ALTERA := .T.

				nOpera := MODEL_OPERATION_UPDATE

				If nOpc == 4 .or. nOpc == 13
					cStatAlt := cStat2205
				ElseIf nOpc == 5 .or. nOpc == 14
					cStatAlt := cStat2206
				Else
					cStatAlt := cStat2306
				EndIf

				If cStatAlt == '1'

					If TafAtualizado(, cRotina)
						//Efetuo alteração direta no registro
						FWMsgRun(,{||nExView:=FWExecView(cTitulo,cRotina,nOpera,,{||.T.} )},,STR0087) //"Executando Rotina do Trabalhador... "
					EndIf

				ElseIf cStatAlt == '4'

					If TafAtualizado(, cRotina)
						FWMsgRun(,{||TafCarrModel(cTitulo,cRotina,nOpera,nOpc)},,STR0087) //"Executando Rotina do Trabalhador... "
					EndIf

				ElseIf cStatAlt == '3'
					nOpcAviso := Aviso( STR0023,"Existe um evento" + STR0045 + CRLF + "Deseja Excluir este evento para gerar uma "+;
					"retificação do trabalhador?", { "Sim", "Não" },3 ) //em processo de transmissão ao RET.# Existe um evento de alteração #.
					If nOpcAviso == 1 .and. cStatAlt <> '4'
						DelEvento(Iif(nOpc == 4 .or. nOpc == 13,"TAFA275", Iif(nOpc == 5 .or. nOpc == 14, "TAFA276", "TAFA277")))
					EndIf

				Else//cStatAlt == 2 - Evento em processo de transmissão
					msgAlert(xValStrEr("000727")) //"Registro não pode ser alterado, pois se encontra em processo de transmissão"
				EndIf

			EndIf

		EndIf			

	ElseIf cStaEvC9V == '2'
		msgAlert(xValStrEr("000727")) //"Registro não pode ser alterado. Aguardando processo da transmissão."

	ElseIf cStaEvC9V == '3'		

		nOpcAviso := Aviso( STR0023, STR0041 + STR0045 + CRLF + STR0046, { STR0017,STR0018 },3 ) //#retificar Evento do Trabalhador #Evento do Trabalhador #com retorno de inconsistência do RET. #
		cRotina:= Iif( cNomEvC9V == "S2200","TAFA278","TAFA279" )

		If nOpcAviso == 1
			INCLUI := .F.
			ALTERA := .T.
			nOpera := MODEL_OPERATION_UPDATE
			FWMsgRun(,{||nExView:=FWExecView(STR0014,cRotina,nOpera,,{||.T.} )},,STR0087) //"Executando Rotina do Trabalhador... "
		Else
			If Empty(cVerAnt)
				//Deleto o registro do evento
				DelEvento(cRotina)

			Else
				//Deleto o registro do evento
				DelEvento(cRotina)

				//Restauro a versão anterior
				TAFRastro( 'C9V', 1,cChvVAnt, .T.,.T., IIF(Type ("oBrw") == "U", Nil, oBrw ))
			EndIf
		EndIf

	ElseIf cStaEvC9V == '6'
		msgAlert(xValStrEr("000728")) //"Registro não pode ser alterado. Aguardando processo de transmissão do evento de Exclusão S-3000"

	ElseIf cStaEvC9V == '7'		
		msgAlert(xValStrEr("000772")) //"Registro não pode ser alterado, pois o evento de exclusão já se encontra na base do RET"
	
	ElseIf cStaEvC9V $ (' |0|1|')
		nOpera := MODEL_OPERATION_UPDATE
		INCLUI := .F.
		ALTERA := .T.
		cRotina:= Iif( cNomEvC9V == "S2200","TAFA278","TAFA279" )

		If TafAtualizado(, cRotina)
			FWMsgRun(,{||nExView:=FWExecView(STR0014,cRotina,nOpera,,{||.T.} )},,STR0087) //"Alteração do Trabalhador" # "Executando Rotina do Trabalhador... "
		EndIf
		
	EndIf

Return nExView

//-----------------------------------------------------------------------------
/*/{Protheus.doc} AltEvtExtemp
Funcao que possibilita o evento extemporaneo para os registros do trabalhador 

@Return 

@Author  Roberto Souza
@Since 03/01/2018
@Version 1.0
/*/
//-----------------------------------------------------------------------------
Function AltEvtExtemp( cTpExtemp )

	Local nExView := 0

	Private lGoExtemp	:= .T.

	Eval( {|| nExView := GoSetExtemp( cTpExtemp ), Iif( lHistLoop .And. ValType(oDlgPrinc) == "O",oDlgPrinc:End(), Nil ) })

Return

//-----------------------------------------------------------------------------
/*/{Protheus.doc} GoSetExtemp
Funcao que possibilita o evento extemporaneo para os registros do trabalhador 

@Author  Roberto Souza
@Since 03/01/2018
@Version 1.0

@Return 
/*/
//-----------------------------------------------------------------------------
Static Function GoSetExtemp( cTpExtemp )

	Local cTitulo			:= ""
	Local cRotina			:= ""
	Local cIdTrab			:= "" //ID do Trabalhador
	Local cNomeEvto			:= ""
	Local cStatAlt			:= ""
	Local cStatsEve 		:= ""
	Local cStatSecn			:= ""
	Local cChvInd			:= ""
	Local cVersao			:= ""
	Local cAlias			:= ""
	Local cChvTrab			:= C9V->C9V_ID + '1'
	Local dDtUtlAlt			:= STOD("")
	Local nOpc 				:= 0
	Local nOpcAviso			:= 0
	Local nOpera			:= 0  //Operação a ser realizada
	Local nExView			:= -1
	Local aOpcoes			:= {} //Lista de opções de Tipo de Alteração
	Local aAreaC9V			:= {}
	Local lPermiAlt			:= .T.
	Local lRetif			:= .T.

	Private cStaEvC9V		:= "" //Status do Registro do Evento do Trabalhador (S2200 ou S2300)
	Private lExist2205		:= IIF(RetUltAtivo('T1U',cChvTrab,2),.T.,.F.)
	Private lExist2206		:= IIF(RetUltAtivo('T1V',cChvTrab,2),.T.,.F.)
	Private lExist2306		:= IIF(RetUltAtivo('T0F',cChvTrab,2),.T.,.F.)
	Private lExist2399 		:= .F.
	Private lExist2299		:= .F.
	Private ALTERA
	Private INCLUI

	Default cTpExtemp 		:= ""

	lHistLoop		:= .F.

	cStaEvC9V 		:= C9V->C9V_STATUS

	cIdTrab			:= (cAliasHist)->ID
	cVersao			:= (cAliasHist)->VERSAO
	cStatsEve		:= (cAliasHist)->STATUS
	cStatSecn		:= (cAliasHist)->STASEC
	cNomeEvto		:= (cAliasHist)->NOMEVE
	nRecno			:= (cAliasHist)->RECNO
	cAlias			:= (cAliasHist)->ALIASTAB
	cTitulo			:= STR0058 + Iif(cNomeEvto == "S2300",STR0055,STR0059)

	If cAlias == "T0F"
		cChvInd := xFilial( cAlias ) + cIdTrab + cVersao
	Else
		cChvInd := xFilial( cAlias ) + cIdTrab + cVersao + "1"
	EndIf

	If lExist2205 .And. cAlias == "T1U"
		dDtUtlAlt		:= T1U->T1U_DTALT
	ElseIf lExist2206 .And. cAlias == "T1V"
		dDtUtlAlt		:= T1V->T1V_DTALT
	ElseIf lExist2306 .And. cAlias == "T0F"
		dDtUtlAlt		:= T0F->T0F_DTALT
	EndIf

	(cAlias)->( DBSetOrder( 1 ) )
	If (cAlias)->( MsSeek( cChvInd ) )

		If cTpExtemp == "R"
			If (cAlias)->&(cAlias + "_DTALT") >= dDtUtlAlt
				lRetif := .F.
			EndIf
		EndIf

		If lRetif

			cStatsEve := (cAlias)->&(cAlias + "_STATUS")

			If cNomeEvto $ "S2200|S2300"

				Aviso(STR0082,STR0085,{STR0084}) //"e-Social" # "Eventos S-2200 | S-2300 não podem ser incluídos / retificados por esta rotina." # {"OK"}

			ElseIf cStatsEve == '4'

				cChvTrab:= C9V->C9V_ID + '1'

				If cNomeEvto $ ('S2205/S2206/S2306')

					//==================================================================================++
					// O sistema permite ao usuário inserir varios eventos de alteração (S2205/S2206)	||
					// para o mesmo trabalhador com datas dIferentes. Porém apenas é permitido retificar||
					// o último evento de alteração enviado. Por isso a função RetUltAtivo posiciona no	||
					// registro ativo com a maior data. 												||
					//==================================================================================++

					If cTpExtemp $ " /R"
						If cNomeEvto $ ('S2205')
							aAdd(aOpcoes,STR0030) //nOpc = 4#"retificar Dados Cadastrais (S-2205)"
						ElseIf cNomeEvto $ ('S2206')
							aAdd(aOpcoes,STR0031) //nOpc = 5#"retificar Dados Contratuais (S-2206)"
						ElseIf cNomeEvto $ ('S2306')
							aAdd(aOpcoes,STR0038) //nOpc = 6#"Retificação Alteração Contr.-Trab. Sem Vínculo (S-2306)"
						EndIf
					EndIf


					If lPermiAlt
						If cTpExtemp $ " /A"
							If !lExist2299
								If cNomeEvto $ ('S2205')
									aAdd(aOpcoes,STR0028) //nOpc = 2#Alterar Dados Cadastrais (S-2205)
								ElseIf cNomeEvto $ ('S2206')
									aAdd(aOpcoes,STR0029) //nOpc = 3#Alterar Dados Contratuais (S-2206)
								ElseIf cNomeEvto $ ('S2306')
									aAdd(aOpcoes,STR0039) //nOpc = 6"Alteração Dados Contrat. - Trab. Sem Vínculo (S-2306)"
								EndIf
							EndIf
						EndIf

						//===========================================================================================+
						// nOpc == 2 - Alterar Dados Cadastrais (S-2205) # S-2200                                   ||
						// nOpc == 3 - Alterar Dados Contratuais (S-2206) # S-2300                                  ||
						// nOpc == 4 - retificar Alteração de Dados Cadastrais (S-2205) # S-2205                    ||
						// nOpc == 5 - retificar Alteração de Dados Contratuais (S-2206) # S-2206                   ||
						// nOpc == 6 - Alterar Dados Contratuais - Trab. Sem Vínculo (S-2306) # S-2306              ||
						// nOpc == 7 - retificar Alteração Contratual - Trab. Sem Vínculo (S-2306)                  ||
						//===========================================================================================+
						If !Isblind()
							nOpc:= SelecOpc(aOpcoes,cNomeEvto,'4') //Abro a tela com as opções de alteração para o usuário
						ElseIf cTpExtemp $ " /A"
							nOpc := 3
						Else
							nOpc := 5
						EndIf

						If nOpc > 0

							//Opc = 2-Alteração de Dados Cadastrais S2205 # Opc = 4-retificação da Alteração de Dados Cadastrais RET S2205
							If (nOpc == 2 .or. nOpc == 4) .and. cNomeEvto $ ('S2205')
								cTitulo	:= STR0020   //"Alteração de Dados Cadastrais do Trabalhador"
								cRotina	:= "TAFA275"
								//Opc= 3-Alteração de Dados Contratuais S2206 # Opc = 5-retificação Alteração de Dados Contrat. RET S2206
							ElseIf (nOpc == 3 .or. nOpc == 5) .and. cNomeEvto $ ('S2206')
								cTitulo	:= STR0021   //"Alteração de Contrato de Trabalho"
								cRotina	:= "TAFA276"
							ElseIf (nOpc == 6 .OR. nOpc == 7) .and. cNomeEvto $ ('S2306')
								cTitulo	:= STR0021   //"Alteração de Contrato de Trabalho"
								cRotina	:= "TAFA277"
							Else
								cRotina := "TAFA278"
							EndIf
						EndIf
					Else
						msgAlert(xValStrEr("000727")) //"Registro não pode ser alterado. Aguardando processo da transmissão."
					EndIf

				Else //S-2300

					//Caso existir um 2399 valido (STATUS = 4) ao trabalhador sem vinculo valido (STATUS = 4) não é permitido realizar uma alteração no S2306.
					aAreaC9V := C9V->(getArea())
					cChvTrab := C9V->C9V_ID + '1'
					DBSelectArea("T92")
					T92->(DBSetOrder(3))
					// VerIfica se existe existe evento de termino para o trabalhador S-2399
					T92->(DBSeek(xFilial("T92")+ C9V->C9V_ID  + "1"))

					While T92->(!Eof()) .And. alltrim(T92->T92_TRABAL) == alltrim(C9V->C9V_ID)
						If T92->T92_STATUS =="4"
							lExist2399 := .T.
						EndIf
						T92->(dbSkip())
					EndDo

					RestArea(aAreaC9V)

					If cTpExtemp $ " /A"
						If !lExist2399
							aAdd(aOpcoes,STR0028) //nOpc = 2#Alterar Dados Cadastrais (S-2205)
							aAdd(aOpcoes,STR0039)//nOpc = 6 #""Alteração Dados Contrat. - Trab. Sem Vínculo (S-2306)"
						EndIf
					EndIf

					If cTpExtemp $ " /R"
						//Caso exista um Evento S-2306 Ativo para o trabalhador eu insiro a opção de retificar"
						If RetUltAtivo('T0F',cChvTrab,2)
							aAdd(aOpcoes,STR0038) //nOpc = 7 "retificação Alteração Contr.-Trab. Sem Vínculo (S-2306)"
							lExist2306	:= .T.
							cEvento	:= T0F->T0F_EVENTO
							cStat2306 	:= T0F->T0F_STATUS
						EndIf
					EndIf

				EndIf

				If nOpc > 0

					//===================================================================================================================+
					// Chamo a Função RetCodMen o nCodMen (código de mensagem com status da operação), que será usado para validar as   ||
					// Regras de alteração.                                                                                             ||
					// nCodMen:                                                                                                         ||
					// 1 - Registro de Alteração Pendente de transmissão (Status $ " |1") - NÃO PODERÁ SER ALTERADO!!!                  ||
					// 2 - Registro de Alteração Em Processo de transmissão (Status == "2") - NÃO PODERÁ SER ALTERADO!!!                ||
					// 3 - Registro de Alteração com Inconsistencia apresentada pelo FISCO (Status == "3")-NÃO PODERÁ SER ALTERADO!!!   ||
					// 4 - Todos os eventos de alteração estão transmitidos - ALTERAÇÃO PERMITIDA!                                      ||
					// 0 - Não existe evento de alteração para este trabalhador - ALTERAÇÃO PERMITIDA!                                  ||
					//==================================================================================================================||
					// REGRAS:                                                                                                          ||
					// REGRA 1 - Quando se tratar de uma retificação do evento PAI (2200/2300), apenas será permitida a alteração, ||
					// se não houver nenhum evento de alteração pendente de transmissão (nCodMen == 4 ou 0)                             ||
					// REGRA 2 - Quando se tratar de uma INCLUSÃO de evento de ALTERAÇÃO (2205/2206/2306), ao invés de olhar para o     ||
					// nCodMen eu apenas verIfico o Status do último registro que ativo para o evento q está sendo incluso e somente	||
					// permito a inclusão se não houver nenhum outro evento ativo (DO MESMO EVENTO), pendente de transmissão.           ||
					// REGRA 3 - Quando se tratar de uma retificação do evento de ALTERAÇÃO eu efetuo a alteração direta do registro, se||
					// ele não estiver pendente de transmissão.                                                                         ||
					//===================================================================================================================+
					// ============================================= A T E N Ç Ã O ======================================================+
					// ATENÇÃO -> Durante o processo de alteração, NUNCA haverá um evento de ALTERAÇÃO, em processo                     ||
					// de transmissão de EXCLUSÃO (STATUS = 6) ou Excluído (STATUS = 7), pois NÃO SERÁ permitido                        ||
					// excluir uma alteração sem que seja excluído o Cadastro do Trabalhado (2200/2300)                            ||
					//===================================================================================================================+

					//================================== OPÇÕES DE ALTERAÇÃO ==========================================+
					// nOpc == 1 - retificar Evento do Trabalhador # S-2200/2300                                 ||
					// nOpc == 2 - Alterar Dados Cadastrais (S-2205) # S-2205                                         ||
					// nOpc == 3 - Alterar Dados Contratuais (S-2206) # S-2206                                        ||
					// nOpc == 4 - retificar Alteração de Dados Cadastrais (S-2205) # S-2205                          ||
					// nOpc == 5 - retificar Alteração de Dados Contratuais (S-2206) # S-2206                         ||
					// nOpc == 6 - Alterar Dados Contratuais - Trab. Sem Vínculo (S-2306) # S-2306                    ||
					// nOpc == 7 - retificar Alteração Contratual - Trab. Sem Vínculo (S-2306)                        ||
					//=================================================================================================+

					(cAlias)->(dbGoTo(nRecno))

					//Inclusão de evento de alteração 2205/2206/2306
					If nOpc == 2 .or. nOpc == 3 .or. nOpc == 6

						nOpera := MODEL_OPERATION_INSERT //Seta a operação de INCLUSÃO

						cStatAlt := cStatsEve

						If cStatAlt $ '0|4' .Or. ( Empty( cStatAlt ) .And. cTpExtemp == "A")//não existe evento de alteração pendente de transmissão
							FWMsgRun(,{||TafCarrModel(cTitulo,cRotina,nOpera,nOpc)},,STR0087) //"Executando Rotina do Trabalhador... "

						ElseIf cStatAlt == '1' .or. cStatAlt == '3'

							//Não permito retificação do evento do trabalhador se houver um evento de alteração S2205/2206/23005 pendente.
							If cStatAlt == '1'
								nOpcAviso := Aviso( STR0023, STR0088 + STR0044 + CRLF + STR0089 +; //"Existe um evento" # " pendente de transmissão ao RET. " # "Deseja Excluir este evento para gerar uma "
								STR0090, { STR0091, STR0092 },3 ) //"retificação do trabalhador?" # { "Sim", "Não" }
							ElseIf cStatAlt == '3'
								nOpcAviso := Aviso( STR0023, STR0088 + STR0045 + CRLF + STR0089 +; //"Existe um evento" # " com retorno de inconsistência do RET. " # "Deseja Excluir este evento para gerar uma "
								STR0090, { STR0091, STR0092 },3 ) //"retificação do trabalhador?" # { "Sim", "Não" }
							EndIf

							If nOpcAviso == 1 //.and. cStatAlt <> '4'
								//Deleto o registro pendente
								DelEvento(Iif(nOpc == 2,"TAFA275",Iif(nOpc == 3, "TAFA276", "TAFA277")))

								//Carrego o modelo consolidando as informações para alteração das informações
								FWMsgRun(,{||TafCarrModel(cTitulo,cRotina,nOpera,nOpc)},,STR0087) //"Executando Rotina do Trabalhador... "
							EndIf

						Else //cStatAlt == 2 - Evento em processo de transmissão
							msgAlert(xValStrEr("000727")) //"Registro não pode ser alterado, pois se encontra em processo de transmissão"

						EndIf

						If !Isblind()
							lHistLoop := .T.
						Else
							lHistLoop := .F.
						EndIf


						//retificação de um evento de alteração.
					ElseIf nOpc == 4 .or. nOpc == 5 .or. nOpc == 7

						INCLUI := .F.
						ALTERA := .T.

						nOpera := MODEL_OPERATION_UPDATE

						cStatAlt := cStatsEve

						If cStatAlt == '1'
							//Efetuo alteração direta no registro
							FWMsgRun(,{||nExView:=FWExecView(cTitulo,cRotina,nOpera,,{||.T.} )},,STR0087) //"Executando Rotina do Trabalhador... "

						ElseIf cStatAlt == '4'
							If !Isblind()
								FWMsgRun(,{||TafCarrModel(cTitulo,cRotina,nOpera,nOpc)},,STR0087) //"Executando Rotina do Trabalhador... "
							Else
								TafCarrModel(cTitulo,cRotina,nOpera,nOpc)
							EndIf
						ElseIf cStatAlt == '3'
							nOpcAviso := Aviso( STR0023, STR0088 + STR0045 + CRLF + STR0089 +; //"Existe um evento" # " com retorno de inconsistência do RET." # "Deseja Excluir este evento para gerar uma "
							STR0090, { STR0091, STR0092 },3 ) //"retificação do trabalhador?" # "{ "Sim", "Não" }"
							If nOpcAviso == 1 .and. cStatAlt <> '4'
								DelEvento(Iif(nOpc == 2,"TAFA275", Iif(nOpc == 3, "TAFA276", "TAFA277")))
							EndIf

						Else //cStatAlt == 2 - Evento em processo de transmissão
							msgAlert(xValStrEr("000727")) //"Registro não pode ser alterado, pois se encontra em processo de transmissão"
						EndIf
						If !Isblind()
							lHistLoop := .T.
						Else
							lHistLoop := .F.
						EndIf
					EndIf

				EndIf

			ElseIf cStatsEve == '2'
				msgAlert(xValStrEr("000727")) //"Registro não pode ser alterado. Aguardando processo da transmissão."

			ElseIf cStatsEve == '3'
				msgAlert( STR0023, STR0041 + STR0045 + CRLF + STR0046, { STR0017 },3 ) //#retificar Evento do Trabalhador #Evento do Trabalhador #com retorno de inconsistência do RET. #

			ElseIf cStatsEve == '6'
				msgAlert(xValStrEr("000728")) //"Registro não pode ser alterado. Aguardando processo de transmissão do evento de Exclusão S-3000"

			ElseIf cStatsEve == '7'
				msgAlert(xValStrEr("000772")) //"Registro não pode ser alterado, pois o evento de exclusão já se encontra na base do RET"

			ElseIf cStatsEve $ (' |0|1|')
				msgAlert(xValStrEr("001119")) //"Não é permitido incluir extemporâneo para eventos não trasmitidos com sucesso ao RET."

			EndIf

		Else
			msgAlert(xValStrEr("001217"))
		EndIf

	ElseIf cAlias <> "T0F"

		msgAlert(xValStrEr("001216"))
		(cAlias)->( DBSetOrder( 1 ) )
		(cAlias)->( MsSeek( xFilial( cAlias ) + cIdTrab + cVersao ) )

	EndIf

	RefreshExt()

Return nExView

//-----------------------------------------------------------------------------
/*/{Protheus.doc} DelEvtExtemp
Funcao que possibilita o evento extemporaneo para os registros do trabalhador 

@Return 

@Author  Roberto Souza
@Since 03/01/2018
@Version 1.0
/*/
//-----------------------------------------------------------------------------
Function DelEvtExtemp( cTpExtemp, cTpExcl )

	Local cNomeTrab	:= C9V->C9V_NOME
	Local aAreaC9V	:= C9V->(GetArea())

	Default cTpExtemp := ""
	Default cTpExcl := ""

	Private lGoExtemp := .T.

	GoDelExtemp(cTpExtemp, cTpExcl)

	RefreshExt(cNomeTrab, aAreaC9V)

Return

//-----------------------------------------------------------------------------
/*/{Protheus.doc} GoSetExtemp
Funcao que possibilita o evento extemporaneo para os registros do trabalhador 

@Author  Roberto Souza
@Since 03/01/2018
@Version 1.0

@Return 
/*/
//-----------------------------------------------------------------------------
Static Function GoDelExtemp( cTpExtemp, cTpExcl )

	Local cNomeEvto		:= ""
	Local cStatSecn		:= ""
	Local cStatsEve 	:= ""
	Local cAlias 		:= ""
	Local cAtivo 		:= ""
	Local cChvTrab		:= C9V->C9V_ID + '1'
	Local dDtUtlAlt		:= STOD("")
	Local dDtUltEft		:= STOD("")
	Local nRecno		:= 0
	Local lDelet		:= .T.

	Private lExist2205	:= IIF(RetUltAtivo('T1U',cChvTrab,2),.T.,.F.)
	Private lExist2206	:= IIF(RetUltAtivo('T1V',cChvTrab,2),.T.,.F.)
	Private lExist2306	:= IIF(RetUltAtivo('T0F',cChvTrab,2),.T.,.F.)
	Private ALTERA
	Private INCLUI

	Default cTpExtemp	:= ""
	Default cTpExcl		:= ""

	cNomeEvto	:= (cAliasHist)->NOMEVE
	cStatSecn	:= (cAliasHist)->STASEC
	cStatsEve	:= (cAliasHist)->STATUS
	nRecno		:= (cAliasHist)->RECNO
	cAlias		:= (cAliasHist)->ALIASTAB

	If lExist2205 .And. cAlias == "T1U"
		dDtUtlAlt		:= T1U->T1U_DTALT
	ElseIf lExist2206 .And. cAlias == "T1V"
		dDtUtlAlt		:= T1V->T1V_DTALT
		dDtUltEft		:= T1V->T1V_DTEF
	ElseIf lExist2306 .And. cAlias == "T0F"
		dDtUtlAlt		:= T0F->T0F_DTALT
	EndIf

	//Posiciono no registro da tabela de negócio
	(cAlias)->( DbGoTo(nRecno) )

	cAtivo		:= (cAlias)->&(cAlias + '_ATIVO')

	If TafColumnPos(cAlias + "_DTEF") 
		If (cAlias)->&(cAlias + "_DTALT") >= dDtUtlAlt .And. (cAlias)->&(cAlias + "_DTEF") >= dDtUltEft
			lDelet := .F.
		EndIf
	ElseIf (cAlias)->&(cAlias + "_DTALT") >= dDtUtlAlt
		lDelet := .F.
	EndIf

	lHistLoop	:= .F.

	If cNomeEvto $ "S2200|S2300"
		Aviso(STR0082, STR0093, {STR0084}) //"e-Social" , "Eventos S2200|S2300 não podem ser excluídos por esta rotina." , {"OK"}
	ElseIf cStatsEve == '2'
		Aviso(STR0082, STR0094, {STR0084}) //"e-Social" , "Registro já foi transmitido e está aguardando retorno. Não pode ser excluido." , {"OK"}
	ElseIf cTpExcl == "1" .AND. cStatsEve == '6'
		Aviso(STR0082, STR0095, {STR0084}) //"e-Social" , "Registro pendente de exclusão no Governo ( S-3000 ). Não pode ser excluído." , {"OK"}
	ElseIf cNomeEvto $ "S2205|S2206" .And. (cAliasHist)->EVENTO == 'I' .And. cStatsEve == '2' // Inativos j? exclu?dos
		Aviso(STR0082, STR0097, {STR0084}) //"e-Social" , "Eventos S2205|S2206 Evento inativo n?o pode ser exclu?do." , {"OK"}
	ElseIf !lDelet
		Aviso(STR0082, STR0100, {STR0084}) //"e-Social" , "Última alteração cadastral  (S-2205) ou contratual (S-2206 ou  S-2306) não pode ser excluída via extemporâneo!" , {"OK"}
	Else
		nOpera := MODEL_OPERATION_DELETE
		INCLUI := .F.
		ALTERA := .F.

		//Efetuo a exclusão no registro
		xTafVExc( cAlias, nRecno, Val(cTpExcl) )
		lHistLoop := .T.

	EndIf

Return

//----------------------------------------------------------------------
/*/{Protheus.doc} TafCarrModel
Funcao para carregar o modelo de dados que será inicializado junto 
com a função FWExecView
@Parametros:
cTitulo    -> Titulo da Tela que será carregada.
cFunName   -> Nome da rotina do cadastro que será carregado
nOper	    -> Número da operação que será realizada (Inclusão ou Alteração)
cEvento	-> Tipo de Evento

@Return 
@Author Paulo Sérgio V.B. Santana
@Since 17/02/2016
@Version 1.0
/*/
//-----------------------------------------------------------------------
Function TafCarrModel( cTitulo,cFunName,nOper,nOpc)

	Local aCampos  		:= ""	//Array com o nome dos campos que serão atualizados
	Local cIdVerOri		:= ""	//ID. Versão do Evento de Origem
	Local cIdVerDes		:= ""	//ID. Versão do Evento de Destino
	Local cAliasOri		:= ""	//Alias de Origem das informações
	Local cAliasTab		:= ""  //Alias utilizado no posicione dos campos virtuais
	Local cAliasDes		:= ""	//Alias de Destino as Informações
	Local cIdDep		:= ""	//Id. do Tipo de Dependente
	Local cIdHor		:= ""	//ID. do código do Horário
	Local cIdTre		:= ""	//ID. do código de Capacitações e Treinamentos
	Local nDep			:= 0	//Contador da Tabela de Dependentes
	Local nHor			:= 0	//Contador da tabela de Horário.
	Local nFilS			:= 0	//Contador da tabela de Filiciação Sindical.
	Local nTrbinf       := 0    //Contador da tabela de Observação do trabalhador
	Local nCapTre       := 0    //Contador da tabela de Capacitação e Treinamentos
	Local cAliDepOri	:= ""	//Alias de ORIGEM das informações do Dependente
	Local cAliDepDes	:= "" 	//Alias de DESTINO das informações do Dependente
	Local cAliHorOri	:= ""	//Alias de ORIGEM das informações de Horário
	Local cAliHorDes	:= ""	//Alias de DESTINO das informações de Horário
	Local cAlIfilSOri	:= ""	//Alias de ORIGEM das informações de Filiação Sindical
	Local cAlIfilSDes	:= ""	//Alias de DESTINO das informações de Filiação Sindical
	Local cAlITraOri    := ""   //Alias de origem das infomações de observação
	Local cAlITraDes    := ""   //Alias de destino das informações de observação
	Local cAlICapOri    := ""   //Alias de origem dos Cadastro Código de Treinamento
	Local cAlICapDes    := ""   //Alias de destino dos Cadastro Código de Treinamento
	Local nIndHor		:= 3
	Local nIndFilS		:= 1
	Local nIndCap		:= 1
	Local cAlsCateg		:= ""
	Local cCpoCateg 	:= ""
	Local cNIS          := ""
	Local cCnpj			:= ""
	Local nY			:= 0
	Local nX			:= 0
	Local aRemoveT1U	:= {}
	Local oStruT1U		:= FWFormStruct( 1, "T1U" )

	Private oModelAlt	:= Nil

	Default cTitulo		:= ""
	Default cFunName	:= ""
	Default nOper		:= 1
	Default nOpc		:= 1

	oModelAlt := FWLoadModel(cFunName)
	oModelAlt:SetOperation(nOper)
	oModelAlt:Activate()

	//===================================================================================================================================+
	//Quando se tratar de uma retificação ou visualização do evento PAI eu preciso carregar as informações dos eventos de alteração     || 
	//(2205,2206 ou 2306), para consolidar as informações do trabalhador                                                                || 
	//========================== =========================================================================================================+
	If cFunName $ ("TAFA256|TAFA278|TAFA279")

		If lExist2205 //Carrega as informações De S2205 PARA -> S2200

			//Alias Field (cabeçalho)
			cAliasOri := "T1U"
			cAliasDes := "C9V"

			//Alias Grid (Linhas)
			cAliDepOri:= "T3T"
			cAliDepDes:= "C9Y"

		EndIf

		If lExist2206 //Carrega as informações De S2206 PARA ->  S2200

			//Alias Field (cabeçalho)
			cAliasOri := "T1V"
			cAliasDes := "C9V"

			//Alias Grid (Linhas)
			cAliHorOri:= "T3U"
			cAliHorDes:= "CRQ"
			nIndHor   := 1

		EndIf

		If lExist2306 //Carrega as informações De S2306 PARA -> S2300

			cAliasOri := "T0F"
			cAliasDes := "C9V"

		EndIf

		//crio um array com o nome dos campos que serão atualizados
		If !Empty(cAliasOri)
			cCmpExcl := "|" + cAliasOri + "_STATUS|" + cAliasOri+"_VERANT|" + cAliasOri + "_EVENTO|" + cAliasOri+"_ATIVO|" + cAliasOri+"_VERSAO|"
			cCmpExcl +=  cAliasOri + "_PROTUL|" + cAliasOri + "_PROTPN|" +  cAliasOri + "_NOMEVE|"

			aCampos  := xFunGetSX3(cAliasOri,cCmpExcl)
			//Carrego as informações no modelo
			aEval(aCampos,{|campo| If( TafColumnPos(cAliasDes + substr(Alltrim(campo[2]),4)),;
				oModelAlt:LoadValue( "MODEL_" + cAliasDes, cAliasDes + substr(Alltrim(campo[2]),4), &(cAliasOri + "->" + campo[2])),;
				Nil)})
		EndIf
		//===================================================================================================================================+
		//Quando se tratar de uma INCLUSÃO de um evento de ALTERAÇÃO (2205,2206 ou 2306), eu preciso carregar as informações dos eventos pai||
		//para garantir que as informações de alteração, serão feitas com base nas informações do TRABALHADOR (2200 ou 2300)           ||
		//===================================================================================================================================+

	Else
		
		If cFunName == "TAFA277" //Carrega as informações De S2300 PARA -> S2306

			If nOper == 4 .or. nOper == 5 .or. nOper == 7 .or. ((nOpc == 6 .Or. nOpc == 16) .And. lExist2306)

				//Alias Field (cabeçalho)
				cAliasOri := "T0F"
				cAliasDes := "T0F"
			Else
				cAliasOri := "CUU"
				cAliasDes := "T0F"

			EndIf

			//Posiciono na tabela de informações de ORIGEM, para carregar no destino
			dbSelectArea("CUU")
			CUU->(dbSetOrder(1))
			CUU->( dbSeek( xFilial("CUU")+C9V->( C9V_ID + C9V_VERSAO ) ) )

			//crio um array com o nome dos campos que não serão atualizados
			cCmpExcl := "|"
			cCmpExcl += cAliasDes + "_STATUS|" + cAliasDes + "_VERANT|"	+ cAliasDes + "_EVENTO|" + cAliasDes + "_ATIVO|"  + cAliasDes + "_VERSAO|"
			cCmpExcl += cAliasDes + "_DTALT|" 	+ cAliasDes + "_PROTUL|"	+ cAliasDes + "_PROTPN|" + cAliasDes + "_NOMEVE|" + cAliasDes + "_DESALT|"
			cCmpExcl += cAliasDes + "_NIS|" 	+ cAliasDes + "_DTALT|"	+ cAliasDes + "_CPF|"    + cAliasDes + "_MATRIC|" + cAliasDes + "_DTEF|"
			cCmpExcl += cAliasDes + "_CATAV|"

			If nOpc == 7
				cCmpExcl += cAliasDes + "_NOMCES|" + cAliasDes + "_MTVALT|"	+ cAliasDes + "_CARCI|"  + cAliasDes + "_FUNCI|"  + cAliasDes + "_VLSLCI|"
				cCmpExcl += cAliasDes + "_UNSLCI|" + cAliasDes + "_DSVRCI|"	+ cAliasDes + "_NATEES|" + cAliasDes + "_NIVEES|" + cAliasDes + "_AREAES|"
				cCmpExcl += cAliasDes + "_NRAPES|" + cAliasDes + "_VLBLES|"	+ cAliasDes + "_DTTEES|" + cAliasDes + "_CNPEES|" + cAliasDes + "_NOMEES|"
				cCmpExcl += cAliasDes + "_LOGEES|" + cAliasDes + "_NLGEES|"	+ cAliasDes + "_BAREES|" + cAliasDes + "_CEPES|"  + cAliasDes + "_MUNES|"
				cCmpExcl += cAliasDes + "_UFES|" 	+ cAliasDes + "_CNPAES|"	+ cAliasDes + "_NOMAES|" + cAliasDes + "_LOGAES|" + cAliasDes + "_NLGAES|"
				cCmpExcl += cAliasDes + "_BARAES|" + cAliasDes + "_CEPAES|"	+ cAliasDes + "_MUNAES|" + cAliasDes + "_UFAES|"  + cAliasDes + "_CPFCES|"
			EndIf

			If TafColumnPos( cAliasDes + "_XMLID" )
				cCmpExcl += cAliasDes + "_XMLID|"
			EndIf

			If TafColumnPos( cAliasDes + "_DINSIS")
				cCmpExcl += cAliasDes + "_DINSIS|"
			EndIf

			aCampos  := xFunGetSX3(cAliasDes,cCmpExcl)
			//Carrego as informações no modelo
			aEval(aCampos,{|campo| Iif( TafColumnPos( cAliasOri + substr(Alltrim(campo[2]),4) ), oModelAlt:LoadValue( "MODEL_" + cAliasDes, campo[2], &(cAliasOri + "->" + cAliasOri + substr(Alltrim(campo[2]),4))), &( cAliasDes + "->" + campo[2] )) })

			If Empty(oModelAlt:GetValue( "MODEL_" + cAliasDes, "T0F_ID"))
				oModelAlt:LoadValue( "MODEL_" + cAliasDes, "T0F_ID", C9V->C9V_ID)
			EndIf

			//Gravo no modelo as informações vindas da tabela do trabalhador (C9V)
			oModelAlt:LoadValue( "MODEL_" + cAliasDes,cAliasDes + "_NOME" ,C9V->C9V_NOME)
			oModelAlt:LoadValue( "MODEL_" + cAliasDes,cAliasDes + "_CATAV",C9V->C9V_CATCI)

			If lLaySimplif
				oModelAlt:LoadValue( "MODEL_" + cAliasDes,cAliasDes + "_NATATV",C9V->C9V_NATATV)	
			EndIf

		ElseIf cFunName == "TAFA275" //Carrega as informações De S2200 PARA -> S2205

			If nOper == 4 .or. nOper == 5 .or. nOper == 7 .or. ((nOpc == 2 .Or. nOpc == 11) .And. (lExist2205.AND.nOper != 3)) //retificação

				//Alias Field (cabeçalho)
				cAliasOri	:= "T1U"
				cAliasDes	:= "T1U"

				//Alias Grid (Linhas)
				cAliDepOri	:= "T3T"
				cAliDepDes	:= "T3T"
				nIndDep  	:= 1

			Else

				//Alias Field (cabeçalho)
				cAliasOri	:= "C9V"
				cAliasDes	:= "T1U"

				If  C9V->C9V_NOMEVE == "S2200"
					//Alias Grid (Linhas)
					cAliDepOri	:= "C9Y"
					cAliDepDes	:= "T3T"
				Else
					//Alias Grid (Linhas)
					cAliDepOri	:= "T2F"
					cAliDepDes	:= "T3T"
					nIndDep  	:= 1
				EndIf

			EndIf

			//crio um array com o nome dos campos que serão atualizados
			cCmpExcl := "|" + cAliasDes + "_STATUS|" + cAliasDes+"_VERANT|" + cAliasDes + "_EVENTO|" + cAliasDes+"_ATIVO|" + cAliasDes +"_VERSAO|"
			cCmpExcl += cAliasDes + "_DTALT|" + cAliasDes + "_PROTUL|" + cAliasDes + "_PROTPN|" + cAliasDes + "_NOMEVE|"  + cAliasDes + "_DESALT|"
			cCmpExcl += cAliasDes + "_NIS|" + cAliasDes + "_DTALT|" + cAliasDes + "_CPF|" + "_DESALT|" + cAliasDes + "_DTEF|" + cAliasDes + "_MATRIC|"

			If TafColumnPos( cAliasDes + "_DPAINA" )
				cCmpExcl += cAliasDes + "_DCODPA|" + cAliasDes + "_DCODUF|" + cAliasDes + "_DCODMU|" + cAliasDes + "_DPAINA|"
			EndIf

			If TafColumnPos( cAliasDes + "_STATSE" )
				cCmpExcl += cAliasDes + "_STATSE|"
			EndIf

			If TafColumnPos( cAliasDes + "_XMLID" )
				cCmpExcl += cAliasDes + "_XMLID|"
			EndIf

			If TafColumnPos( cAliasDes + "_DINSIS")
				cCmpExcl += cAliasDes + "_DINSIS|"
			EndIf

			If TafColumnPos("T1U_DTRANS")
				cCmpExcl += cAliasDes + "_DINSIS|" + cAliasDes + "_DTRANS|" + cAliasDes + "_HTRANS|" + cAliasDes + "_DTRECP|" + cAliasDes + "_HRRECP|"
			EndIf

			oModelAlt:LoadValue( "MODEL_" + cAliasDes,cAliasDes + "_NOME" ,C9V->C9V_NOME)

			aCampos  := xFunGetSX3(cAliasDes,cCmpExcl)

			If lLaySimplif

				oStruT1U:RemoveField("T1U_NIS")
				AADD(aRemoveT1U, "T1U_NIS")
				oStruT1U:RemoveField("T1U_NRCTPS")
				AADD(aRemoveT1U, "T1U_NRCTPS")
				oStruT1U:RemoveField("T1U_SERCTP")
				AADD(aRemoveT1U, "T1U_SERCTP")
				oStruT1U:RemoveField("T1U_UFCTPS")
				AADD(aRemoveT1U, "T1U_UFCTPS")
				oStruT1U:RemoveField("T1U_DUFCTP")
				AADD(aRemoveT1U, "T1U_DUFCTP")
				oStruT1U:RemoveField("T1U_NRRIC")
				AADD(aRemoveT1U, "T1U_NRRIC")
				oStruT1U:RemoveField("T1U_OREMRI")
				AADD(aRemoveT1U, "T1U_OREMRI")
				oStruT1U:RemoveField("T1U_DTEXRI")
				AADD(aRemoveT1U, "T1U_DTEXRI")
				oStruT1U:RemoveField("T1U_NRRG")
				AADD(aRemoveT1U, "T1U_NRRG")
				oStruT1U:RemoveField("T1U_OREMRG")
				AADD(aRemoveT1U, "T1U_OREMRG")
				oStruT1U:RemoveField("T1U_DTEMRG")
				AADD(aRemoveT1U, "T1U_DTEMRG")
				oStruT1U:RemoveField("T1U_NRRNE")
				AADD(aRemoveT1U, "T1U_NRRNE")
				oStruT1U:RemoveField("T1U_OREMRN")
				AADD(aRemoveT1U, "T1U_OREMRN")
				oStruT1U:RemoveField("T1U_DTEMRN")
				AADD(aRemoveT1U, "T1U_DTEMRN")
				oStruT1U:RemoveField("T1U_NUMOC")
				AADD(aRemoveT1U, "T1U_NUMOC")
				oStruT1U:RemoveField("T1U_OREMOC")
				AADD(aRemoveT1U, "T1U_OREMOC")
				oStruT1U:RemoveField("T1U_DTEXOC")
				AADD(aRemoveT1U, "T1U_DTEXOC")
				oStruT1U:RemoveField("T1U_DTVLOC")
				AADD(aRemoveT1U, "T1U_DTVLOC")
				oStruT1U:RemoveField("T1U_NRCNH")
				AADD(aRemoveT1U, "T1U_NRCNH")
				oStruT1U:RemoveField("T1U_DTEXCN")
				AADD(aRemoveT1U, "T1U_DTEXCN")
				oStruT1U:RemoveField("T1U_UFCNH")
				AADD(aRemoveT1U, "T1U_UFCNH")
				oStruT1U:RemoveField("T1U_DUFCN")
				AADD(aRemoveT1U, "T1U_DUFCN")
				oStruT1U:RemoveField("T1U_DTVLCN")
				AADD(aRemoveT1U, "T1U_DTVLCN")
				oStruT1U:RemoveField("T1U_DTPCNH")
				AADD(aRemoveT1U, "T1U_DTPCNH")
				oStruT1U:RemoveField("T1U_CATCNH")
				AADD(aRemoveT1U, "T1U_CATCNH")
				oStruT1U:RemoveField("T1U_APOSEN")
				AADD(aRemoveT1U, "T1U_APOSEN")
				oStruT1U:RemoveField("T1U_DTNASC")
				AADD(aRemoveT1U, "T1U_DTNASC")
				oStruT1U:RemoveField("T1U_CODPAI")
				AADD(aRemoveT1U, "T1U_CODPAI")
				oStruT1U:RemoveField("T1U_DCODPA")
				AADD(aRemoveT1U, "T1U_DCODPA")
				oStruT1U:RemoveField("T1U_CODUF")
				AADD(aRemoveT1U, "T1U_CODUF")
				oStruT1U:RemoveField("T1U_DCODUF")
				AADD(aRemoveT1U, "T1U_DCODUF")
				oStruT1U:RemoveField("T1U_CODMUN")
				AADD(aRemoveT1U, "T1U_CODMUN")
				oStruT1U:RemoveField("T1U_DCODMU")
				AADD(aRemoveT1U, "T1U_DCODMU")
				oStruT1U:RemoveField("T1U_NOMMAE")
				AADD(aRemoveT1U, "T1U_NOMMAE")
				oStruT1U:RemoveField("T1U_NOMPAI")
				AADD(aRemoveT1U, "T1U_NOMPAI")

				For nX := 1 To Len(aRemoveT1U)

					For nY := 1 To Len(aCampos)

						nPosDel	:=	aScan( aCampos , { | aX | AllTrim( aCampos[nY][2] ) == aRemoveT1U[nX] } )
						If nPosDel > 0
							aDel( aCampos, nY )
							aSize( aCampos, Len( aCampos ) - 1 )
							Exit
						EndIf

					Next

				Next

			Else

				oStruT1U:RemoveField("T1U_TPRESI")
				AADD(aRemoveT1U, "T1U_TPRESI")
				oStruT1U:RemoveField("T1U_CNDING")
				AADD(aRemoveT1U, "T1U_CNDING")
				
				For nX := 1 To Len(aRemoveT1U)

					For nY := 1 To Len(aCampos)

						nPosDel	:=	aScan( aCampos , { | aX | AllTrim( aCampos[nY][2] ) == aRemoveT1U[nX] } )
						If nPosDel > 0
							aDel( aCampos, nY )
							aSize( aCampos, Len( aCampos ) - 1 )
							Exit
						EndIf

					Next

				Next

			EndIf

			//Carrego as informações no modelo
			aEval(aCampos,{|campo|oModelAlt:LoadValue( "MODEL_" + cAliasDes, campo[2], &(cAliasOri + "->" + cAliasOri + substr(Alltrim(campo[2]),4)))})

		ElseIf cFunName == "TAFA276" //Carrega as informações De S2200 PARA -> S2206

			//Alias Field (cabeçalho)
			If nOper == 4 .or. nOper == 5 .or. nOper == 7 .or. ((nOpc == 3 .Or. nOpc == 12) .And. lExist2206)  //retificação

				//Alias Field (cabeçalho)
				cAliasOri	:= "T1V"
				cAliasDes	:= "T1V"

				//Alias Grid Horario (Linhas)
				cAliHorOri	:= "T3U"
				cAliHorDes	:= "T3U"
				nIndHor   	:= 1

				//Alias Grid Filiação Sindical
				cAlIfilSOri	:= "T79"
				cAlIfilSDes	:= "T79"
				nIndFilS   	:= 1

				//Alias Grid Filiação Sindical
				cAlITraOri	:= "T91"
				cAlITraDes	:= "T91"
				nIndFilS   	:= 1

				//Alias Grid Capacitação e Treinamentos
				cAlICapOri    := IIF(TAFAlsInDic("V87"), "V87", "")
				cAlICapDes    := IIF(TAFAlsInDic("V91"), "V91", "")
				nIndCap		  := 1

			Else

				//Alias Field (cabeçalho)
				cAliasOri	:= "CUP"
				cAliasDes	:= "T1V"

				//Alias Grids (Linhas)
				cAliHorOri	:= "CRQ"
				cAliHorDes	:= "T3U"

				//Alias Grid Filiação Sindical
				cAlIfilSOri	:= "T80"
				cAlIfilSDes	:= "T79"

				//Alias Grid Filiação Sindical
				cAlITraOri	:= "T90"
				cAlITraDes	:= "T91"

				//Alias Grid Capacitação e Treinamentos
				cAlICapOri    := IIF(TAFAlsInDic("V87"), "V87", "")
				cAlICapDes    := IIF(TAFAlsInDic("V91"), "V91", "")

				//Posiciono na tabela de informações de ORIGEM, para carregar no destino
				dbSelectArea("CUP")
				CUP->(dbSetOrder(1))
				CUP->( dbSeek( xFilial("CUP")+C9V->( C9V_ID + C9V_VERSAO ) ) )

			EndIf

			//crio um array com o nome dos campos que serão atualizados
			cCmpExcl := "|" + cAliasDes + "_STATUS|" + cAliasDes+"_VERANT|" + cAliasDes + "_EVENTO|" + cAliasDes+"_ATIVO|" + cAliasDes +"_VERSAO|"
			cCmpExcl += cAliasDes + "_DTALT|" + cAliasDes + "_PROTUL|" + cAliasDes + "_PROTPN|" + cAliasDes + "_NOMEVE|"  + cAliasDes + "_DESALT"
			cCmpExcl += cAliasDes + "_NIS|" + cAliasDes + "_DTALT|" + cAliasDes + "_CPF|" + "_DESALT|" + cAliasDes + "_DTEF|" + cAliasDes + "_MATRIC|"
			cCmpExcl += cAliasDes + "_JUSTPR|" + cAliasDes + "_MTVALT|"

			If TafColumnPos( cAliasDes + "_XMLID" )
				cCmpExcl += cAliasDes + "_XMLID|"
			EndIf

			If TafColumnPos( cAliasDes + "_DINSIS")
				cCmpExcl += cAliasDes + "_DINSIS|"
			EndIf

			// Tratamento para a simplificação do e-Social
			If lLaySimplif
				cCmpExcl += cAliasDes + "_CODCGO|" + cAliasDes + "_CODFUN|" + cAliasDes + "_CODCAR|" + cAliasDes + "_DTINGC|" + cAliasDes + "_NIS|"
				cCmpExcl += cAliasDes + "_DTPJOR|" + cAliasDes + "_DCODCG|" + cAliasDes + "_DCODFU|" + cAliasDes + "_DESCAR|" + cAliasDes + "_DESSVR|"
				cCmpExcl += cAliasDes + "_MTVALT"
			Else
				cCmpExcl += cAliasDes + "_CODTRE|" + cAliasDes + "_DSCTRE|" + cAliasDes + "_TERGPS|" + cAliasDes + "_ABOPER|" + cAliasDes + "_NMCARG|"
				cCmpExcl += cAliasDes + "_CBOCAR|" + cAliasDes + "_NMFUNC|" + cAliasDes + "_CBOFUN|" + cAliasDes + "_ACCARG|" + cAliasDes + "_HRSNOT|"
				cCmpExcl += cAliasDes + "_DSCJOR|" + cAliasDes + "_DSCSAL|" + cAliasDes + "_DCBOCG|" + cAliasDes + "_DCBOFC|" 
			EndIf

			oModelAlt:LoadValue( "MODEL_" + cAliasDes,cAliasDes + "_MATRIC" ,C9V->C9V_MATRIC)

			aCampos  := xFunGetSX3(cAliasDes,cCmpExcl)
			//Carrego as informações no modelo
			aEval(aCampos,{|campo|oModelAlt:LoadValue( "MODEL_" + cAliasDes, campo[2], &(cAliasOri + "->" + cAliasOri + substr(Alltrim(campo[2]),4)))})

			If Empty(oModelAlt:GetValue( "MODEL_" + cAliasDes, "T1V_ID"))
				oModelAlt:LoadValue( "MODEL_" + cAliasDes, "T1V_ID", C9V->C9V_ID)
			EndIf

		EndIf

		oModelAlt:LoadValue( "MODEL_" + cAliasDes,cAliasDes + "_CPF"    ,C9V->C9V_CPF)

		If !lLaySimplif
			If FindFunction("TAF250NIS")
				cNIS := TAF250Nis( C9V->C9V_FILIAL, C9V->C9V_ID, C9V->C9V_NIS )
			Else
				cNIS := C9V->C9V_NIS
			EndIf

			oModelAlt:LoadValue( "MODEL_" + cAliasDes,cAliasDes + "_NIS"    , cNIS)
		EndIf

		oModelAlt:LoadValue( "MODEL_" + cAliasDes,cAliasDes + "_NOME"   ,C9V->C9V_NOME)

	EndIf

	//Seleciono a Alias da tabela de acordo com a operação
	If (nOpc == 1 .OR. nOpc == 4 .OR. nOpc == 5 .OR. nOpc == 7 .OR. nOpc == 10)
		If nOpc == 10
			cAliasDes	:= "CUU"
		EndIf
		cAliasTab 	:= cAliasDes
		cAlsCateg	:= "T0F"
		cCpoCateg 	:= "_CATAV"	
	Else
		cAliasTab 	:= cAliasOri
		cAlsCateg	:= "C9V"
		cCpoCateg 	:= "_CATCI"
	EndIf

	If cFunName $ ("TAFA256|TAFA278|TAFA275")

		//Carrego as informações referente aos campos virtuais
		//S2205 PARA S2200 ou S2200 para S2205
		oModelAlt:LoadValue( "MODEL_" + cAliasDes,cAliasDes + "_DGRINS",Alltrim(Posicione("CMH",1,xFilial("CMH")+&(cAliasTab + "->" + cAliasTab + "_GRINST"),"Alltrim(CMH_ID)+' - '+CMH_DESCRI")))
		oModelAlt:LoadValue( "MODEL_" + cAliasDes,cAliasDes + "_DUFCTP",Alltrim(Posicione("C09",3,xFilial("C09")+&(cAliasTab + "->" + cAliasTab + "_UFCTPS"),"Alltrim(C09_UF)+' - '+C09_DESCRI")))
		oModelAlt:LoadValue( "MODEL_" + cAliasDes,cAliasDes + "_DUFCN" ,Alltrim(Posicione("C09",3,xFilial("C09")+&(cAliasTab + "->" + cAliasTab + "_UFCTPS"),"Alltrim(C09_UF)+' - '+C09_DESCRI")))
		oModelAlt:LoadValue( "MODEL_" + cAliasDes,cAliasDes + "_DPAIS" ,Alltrim(Posicione("C08",3,xFilial("C08")+&(cAliasTab + "->" + cAliasTab + "_PAIS")  ,"Alltrim(C08_CODIGO)+' - '+C08_DESCRI")))
		oModelAlt:LoadValue( "MODEL_" + cAliasDes,cAliasDes + "_DUF"   ,Alltrim(Posicione("C09",3,xFilial("C09")+&(cAliasTab + "->" + cAliasTab + "_UF")    ,"Alltrim(C09_UF)+' - '+C09_DESCRI")))
		oModelAlt:LoadValue( "MODEL_" + cAliasDes,cAliasDes + "_DMUN"  ,Alltrim(Posicione("C07",3,xFilial("C07")+&(cAliasTab + "->" + cAliasTab + "_MUN")   ,"Alltrim(C07_CODIGO)+' - '+C07_DESCRI")))
		oModelAlt:LoadValue( "MODEL_" + cAliasDes,cAliasDes + "_DTPLOG",Alltrim(Posicione("C06",3,xFilial("C06")+&(cAliasTab + "->" + cAliasTab + "_TPLOGR"),"Alltrim(C06_CESOCI)+' - '+C06_DESCRI")))
		oModelAlt:LoadValue( "MODEL_" + cAliasDes,cAliasDes + "_DCONTE",Alltrim(Posicione("T13",1,xFilial("T13")+&(cAliasTab + "->" + cAliasTab + "_CCTRAE"),"Alltrim(T13_CODIGO)+'-'+T13_DESCRI")))

		
	ElseIf cFunName $ ("TAFA279|TAFA277")

		//Carrego as informações referente aos campos virtuais
		//S2306 PARA S2300 ou S2300 para S2306
		If !lLaySimplif
			oModelAlt:LoadValue( "MODEL_" + cAliasDes,cAliasDes + "_DCARCI",Alltrim(Posicione("C8V",1,xFilial("C8V")+&(cAliasTab + "->" + cAliasTab + "_CARCI" ), "Alltrim(C8V_CODIGO)+' - '+C8V_DESCRI")))
			oModelAlt:LoadValue( "MODEL_" + cAliasDes,cAliasDes + "_DFUNCI",Alltrim(Posicione("C8X",1,xFilial("C8X")+&(cAliasTab + "->" + cAliasTab + "_FUNCI" ), "Alltrim(C8X_CODIGO)+' - '+C8X_DESCRI")))
			oModelAlt:LoadValue( "MODEL_" + cAliasDes,cAliasDes + "_DCATAV",Alltrim(Posicione("C87",1,xFilial("C87")+&(cAlsCateg + "->" + cAlsCateg + cCpoCateg), "Alltrim(C87_CODIGO)+' - '+C87_DESCRI")))
			oModelAlt:LoadValue( "MODEL_" + cAliasDes,cAliasDes + "_DMUNAE",Alltrim(Posicione("C07",3,xFilial("C07")+&(cAliasTab + "->" + cAliasTab + "_MUNAES"), "Alltrim(C07_CODIGO)+' - '+C07_DESCRI")))			
			oModelAlt:LoadValue( "MODEL_" + cAliasDes,cAliasDes + "_DUFAES",Alltrim(Posicione("C09",3,xFilial("C09")+&(cAliasTab + "->" + cAliasTab + "_UFAES" ), "Alltrim(C09_UF)+' - '+C09_DESCRI")))
			oModelAlt:LoadValue( "MODEL_" + cAliasDes,cAliasDes + "_DUFES" ,Alltrim(Posicione("C09",3,xFilial("C09")+&(cAliasTab + "->" + cAliasTab + "_UFES"  ), "Alltrim(C09_UF)+' - '+C09_DESCRI")))
		Else	
			oModelAlt:LoadValue( "MODEL_" + cAliasDes,cAliasDes + "_DMUNES",Alltrim(Posicione("C07",3,xFilial("C07")+&(cAliasTab + "->" + cAliasTab + "_MUNES" ), "Alltrim(C07_CODIGO)+ ' - ' +C07_DESCRI")))
			oModelAlt:LoadValue( "MODEL_" + cAliasDes,cAliasDes + "_DCATAV",Alltrim(Posicione("C87",1,xFilial("C87")+&(cAlsCateg + "->" + cAlsCateg + cCpoCateg), "Alltrim(C87_CODIGO)+' - '+C87_DESCRI")))
			oModelAlt:LoadValue( "MODEL_" + cAliasDes,cAliasDes + "_DUFES" ,Alltrim(Posicione("C09",3,xFilial("C09")+&(cAliasTab + "->" + cAliasTab + "_UFES"  ), "Alltrim(C09_UF)+' - '+C09_DESCRI")))
		EndIf

	ElseIf cFunName $ ("TAFA256|TAFA278|TAFA276")

		//Carrego as informações referente aos campos virtuais
		//S2206 PARA S2200 ou S2200 para S2206
		If cFunName $ ("TAFA256|TAFA278") .OR. !lLaySimplif
			oModelAlt:LoadValue( "MODEL_" + cAliasDes, cAliasDes + "_DCODCG",Alltrim(Posicione("C8V",1,xFilial("C8V")+&(cAliasTab + "->" + cAliasTab + "_CODCGO"),"ALLTRIM(C8V->C8V_CODIGO)+' - '+C8V->C8V_DESCRI")))
			oModelAlt:LoadValue( "MODEL_" + cAliasDes, cAliasDes + "_DCODFU",Alltrim(Posicione("C8X",1,xFilial("C8X")+&(cAliasTab + "->" + cAliasTab + "_CODFUN"),"Alltrim(C8X_CODIGO)+' - '+C8X_DESCRI")))
			oModelAlt:LoadValue( "MODEL_" + cAliasDes, cAliasDes + "_DESCAR",Alltrim(Posicione("T5K",5,xFilial("T5K")+&(cAliasTab + "->" + cAliasTab + "_CODCAR")+"1","Alltrim(T5K_CODIGO)+'-'+T5K_DESCRI")))
		EndIf

		oModelAlt:LoadValue( "MODEL_" + cAliasDes, cAliasDes + "_DCODCA",Alltrim(Posicione("C87",1,xFilial("C87")+&(cAliasTab + "->" + cAliasTab + "_CODCAT"),"Alltrim(C87_CODIGO)+' - '+C87_DESCRI")))
		oModelAlt:LoadValue( "MODEL_" + cAliasDes, cAliasDes + "_DSCTPL",Alltrim(Posicione("C06",3,xFilial("C06")+&(cAliasTab + "->" + cAliasTab + "_TPLOGD"),"Alltrim(C06_CODIGO)+' - '+C06_DESCRI")))
		oModelAlt:LoadValue( "MODEL_" + cAliasDes, cAliasDes + "_DUFTRD",Alltrim(Posicione("C09",3,xFilial("C09")+&(cAliasTab + "->" + cAliasTab + "_UFTRBD"),"Alltrim(C09_UF)+' - '+C09_DESCRI")))
		oModelAlt:LoadValue( "MODEL_" + cAliasDes, cAliasDes + "_DSCMTD",Alltrim(Posicione("C07",3,xFilial("C07")+&(cAliasTab + "->" + cAliasTab + "_CMUNTD"),"Alltrim(C07_CODIGO)+' - '+C07_DESCRI")))
		oModelAlt:LoadValue( "MODEL_" + cAliasDes, cAliasDes + "_DALVJU",Alltrim(Posicione("C1G",8,xFilial("C1G")+&(cAliasTab + "->" + cAliasTab + "_ALVJUD"),"Alltrim(C1G_TPPROC)+' - '+C1G_NUMPRO")))

	EndIf

	//***********
	//Dependentes
	//***********		 	 
	If !Empty( cAliDepOri )
		
		dbSelectArea(cAliDepOri)
		(cAliDepOri)->(dbSetOrder(1))
		(cAliDepOri)->(dbGotop()) //Desposiciono para através do Seek garantir que ele está posicionado no primeiro Item de Dependente para este funcionário.

		//========================================================================================================================================+
		//Caso seja uma retificação do Evento do Trabalhador (S2200), o ID + Versão da Tabela de ORIGEM, virá do evento de Alteração,   ||
		//pois eu preciso carregar os dependentes do evento de alteração no Evento do PAI, que será retIficado.                                  ||                                                                  ||
		//========================================================================================================================================+
		If cFunName $ ("TAFA256|TAFA278")
			cIdVerOri := T1U->( T1U_ID + T1U_VERSAO )
		Else
			cIdVerOri := C9V->( C9V_ID + C9V_VERSAO )
		EndIf
		
		If (cAliDepOri)->( dbSeek( xFilial(cAliDepOri) + cIdVerOri ))

			cIdVerDes	:= (cAliDepOri)->( &(cAliDepOri + "_ID") + &(cAliDepOri + "_VERSAO"))

			While (cAliDepOri)->( !Eof() ) .And. cIdVerDes == (cAliDepOri)->( &(cAliDepOri + "_ID") + &(cAliDepOri + "_VERSAO") )
				
				If TafColumnPos( cAliDepDes + "_SEXDEP") .And. (!lLaySimplif .Or. !TafColumnPos( cAliDepOri + "_SEXDEP"))
					cCmpExcl += cAliDepDes + "_SEXDEP|"
				EndIf

				//crio um array com o nome dos campos que serão atualizados
				aCampos  := xFunGetSX3(cAliDepDes,cCmpExcl)
				cidDep   := (cAliDepOri)->&(cAliDepOri + "_TPDEP")

				//Valido e adiciono mais uma linha
				If nDep > 0
					oModelAlt:GetModel( "MODEL_" + cAliDepDes ):lValid:= .T.
					oModelAlt:GetModel( "MODEL_" + cAliDepDes ):AddLine()
				EndIf

				//Carrego as informações no modelo
				aEval(aCampos,{|Campo|oModelAlt:LoadValue( "MODEL_"+cAliDepDes,campo[2],(cAliDepOri)->&(cAliDepOri + Substr(Alltrim(campo[2]),4)))})
				oModelAlt:LoadValue( "MODEL_" + cAliDepDes, cAliDepDes + "_DTPDE",;
					Alltrim(POSICIONE("CMI",1,XFILIAL("CMI") + cidDep,"CMI_CODIGO+' - '+CMI_DESCRI") ) )

				( cAliDepOri )->( dbSkip() )
				nDep ++

			Enddo
		EndIf

	EndIf

	//***********
	//Horário
	//***********		 	 
	If !Empty( cAliHorOri )

		dbSelectArea( cAliHorOri )
		( cAliHorOri )->( dbSetOrder( nIndHor ) )

		//========================================================================================================================================+
		//Caso seja uma retificação do Evento do Trabalhador (S2200), o ID + Versão da Tabela de ORIGEM, virá do evento de Alteração,   ||
		//pois eu preciso carregar os dependentes do evento de alteração no Evento do PAI, que será retIficado.                                  ||                                                                  ||
		//========================================================================================================================================+
		If cFunName $ ("TAFA256|TAFA278")
			cIdVerOri := T1V->( T1V_ID + T1V_VERSAO )
		Else
			If cAliHorOri == "T3U"
				cIdVerOri := T1V->( T1V_ID + T1V_VERSAO)
			Else
				cIdVerOri := C9V->( C9V_ID + C9V_VERSAO + C9V_NOMEVE)
			EndIf
		EndIf

		If (cAliHorOri)->( dbSeek( xFilial( cAliHorOri ) + cIdVerOri ))
			if nOper == 4
				cIdVerOri := (cAliHorOri)->(&(cAliHorOri + "_ID") + &(cAliHorOri + "_VERSAO") + Iif(cFunName $ ("TAFA256|TAFA278|TAFA276"),&(cAliHorOri + "_NOMEVE" ),"") )
			Else
				cIdVerOri := (cAliHorOri)->(&(cAliHorOri + "_ID") + &(cAliHorOri + "_VERSAO") + Iif(cFunName $ ("TAFA256|TAFA278"),&(cAliHorOri + "_NOMEVE" ),"") )
			EndIf

			While ((cAliHorOri)->(!Eof()) .And. cIdVerOri == (cAliHorOri)->(&(cAliHorOri + "_ID") + &(cAliHorOri + "_VERSAO") + Iif(cFunName $ ("TAFA256|TAFA278"),&(cAliHorOri + "_NOMEVE" ),"") ))

				//crio um array com o nome dos campos que serão atualizados
				aCampos  := xFunGetSX3((cAliHorDes))

				cIdHor	  := (cAliHorOri)->&(cAliHorOri + "_CODHOR")

				If nHor > 0
					oModelAlt:GetModel( "MODEL_" + cAliHorDes ):lValid:= .T.
					oModelAlt:GetModel( "MODEL_" + cAliHorDes ):AddLine()
				EndIf

				//Carrego as informações no modelo
				aEval(aCampos,{|Campo|oModelAlt:LoadValue( "MODEL_" + cAliHorDes, campo[2],(cAliHorOri)->&(cAliHorOri + Substr( Alltrim( campo[2] ),4 ) ) ) } )
				oModelAlt:LoadValue( "MODEL_" +cAliHorDes,cAliHorDes + "_DCODHO",;
					Alltrim(POSICIONE("C90",1,XFILIAL("C90")+cidHor,"Alltrim(C90_CODIGO)+' - '+C90_DESCRI" ) ) )
				(cAliHorOri)->( dbSkip() )
				nHor++
			Enddo

		EndIf
	EndIf

	//*******************
	//Filiação Sindical
	//*******************		 	 
	If !Empty( cAlIfilSOri )

		dbSelectArea( cAlIfilSOri )
		( cAlIfilSOri )->( dbSetOrder( nIndFilS ) )

		//========================================================================================================================================+
		//Caso seja uma retificação do Evento do Trabalhador (S2200), o ID + Versão da Tabela de ORIGEM, virá do evento de Alteração,   ||
		//pois eu preciso carregar os dependentes do evento de alteração no Evento do PAI, que será retIficado.                                  ||                                                                  ||
		//========================================================================================================================================+
		If cFunName $ ("TAFA256|TAFA278")
			cIdVerOri := T1V->( T1V_ID + T1V_VERSAO )
		Else
			If cAlIfilSOri == "T79"
				cIdVerOri := T1V->( T1V_ID + T1V_VERSAO )
			Else
				cIdVerOri := C9V->( C9V_ID + C9V_VERSAO + C9V_NOMEVE)
			EndIf
		EndIf

		If (cAlIfilSOri)->( dbSeek( xFilial( cAlIfilSOri ) + cIdVerOri ))

			cCnpj := (cAlIfilSOri)->&(cAlIfilSOri + "_CNPJSD")

			cIdVerOri := (cAlIfilSOri)->(&(cAlIfilSOri + "_ID") + &(cAlIfilSOri + "_VERSAO") + Iif(cFunName $ ("TAFA256|TAFA278"),&(cAlIfilSOri + "_NOMEVE" ),"") + Iif(nOper == 4 .AND. cFunName $ ("TAFA276"),&(cAlIfilSOri + "_CNPJSD" ),"") )

			While ((cAlIfilSOri)->(!Eof()) .And. cIdVerOri == (cAlIfilSOri)->(&(cAlIfilSOri + "_ID") + &(cAlIfilSOri + "_VERSAO") + Iif(cFunName $ ("TAFA256|TAFA278"),&(cAlIfilSOri + "_NOMEVE" ),"") + Iif(nOper == 4 .AND. cFunName $ ("TAFA276"),&(cAlIfilSOri + "_CNPJSD" ),"")))

				//crio um array com o nome dos campos que serão atualizados
				aCampos  := xFunGetSX3((cAlIfilSDes))

				If nFilS > 0
					oModelAlt:GetModel( "MODEL_" + cAlIfilSDes ):lValid:= .T.
					oModelAlt:GetModel( "MODEL_" + cAlIfilSDes ):AddLine()
				EndIf

				//Carrego as informações no modelo
				aEval(aCampos,{|Campo|oModelAlt:LoadValue( "MODEL_" + cAlIfilSDes, campo[2],(cAlIfilSOri)->&(cAlIfilSOri + Substr( Alltrim( campo[2] ),4 ) ) ) } )

				(cAlIfilSOri)->( dbSkip() )

				nFilS++
			Enddo

		EndIf
	EndIf

	//***********
	//Observações de contrato de trabalho
	//***********		 	 
	If !Empty( cAlITraOri )

		dbSelectArea(cAlITraOri)
		(cAlITraOri)->(dbSetOrder(1))
		(cAlITraOri)->(dbGotop()) //Desposiciono para através do Seek garantir que ele está posicionado no primeiro Item de Dependente para este funcionário.

		//========================================================================================================================================+
		//Caso seja uma retificação do Evento do Trabalhador (S2200), o ID + Versão da Tabela de ORIGEM, virá do evento de Alteração,   ||
		//pois eu preciso carregar os dependentes do evento de alteração no Evento do PAI, que será retIficado.                                  ||                                                                  ||
		//========================================================================================================================================+
		if cAlITraOri == "T91"
			cIdVerOri := T1V->( T1V_ID + T1V_VERSAO )
		Else
			cIdVerOri := C9V->( C9V_ID + C9V_VERSAO )
		EndIf

		If (cAlITraOri)->( dbSeek( xFilial(cAlITraOri) + cIdVerOri ))
			cIdVerDes	:= (cAlITraOri)->( &(cAlITraOri + "_ID") + &(cAlITraOri + "_VERSAO"))

			While (cAlITraOri)->( !Eof() ) .And. cIdVerDes == (cAlITraOri)->( &(cAlITraOri + "_ID") + &(cAlITraOri + "_VERSAO")) .AND. nOper = 3
				//crio um array com o nome dos campos que serão atualizados
				aCampos  := xFunGetSX3(cAlITraDes)

				cIdHor	  := (cAlITraOri)->&(cAlITraOri + "_CODOBS")

				//Valido e adiciono mais uma linha
				If nTrbinf > 0
					oModelAlt:GetModel( "MODEL_" + cAlITraDes ):lValid:= .T.
					oModelAlt:GetModel( "MODEL_" + cAlITraDes ):AddLine()
				EndIf

				//Carrego as informações no modelo
				aEval(aCampos,{|Campo|oModelAlt:LoadValue( "MODEL_" + cAlITraDes, campo[2],(cAlITraOri)->&(cAlITraOri + Substr( Alltrim( campo[2] ),4 ) ) ) } )
				oModelAlt:LoadValue( "MODEL_" +cAlITraDes,cAlITraDes + "_CODOBS",cIdHor)

				( cAlITraOri )->( dbSkip() )
				nTrbinf++

			Enddo
		EndIf

	EndIf

	//***********
	//Capacitação e Treinamentos
	//***********		 	 
	If lLaySimplif

		If !Empty( cAlICapOri )
			dbSelectArea(cAlICapOri)
			(cAlICapOri)->(dbSetOrder(1))
			(cAlICapOri)->(dbGotop()) //Desposiciono para através do Seek garantir que ele está posicionado no primeiro Item de Dependente para este funcionário.

			//========================================================================================================================================+
			//Caso seja uma retificação do Evento do Trabalhador (S2200), o ID + Versão da Tabela de ORIGEM, virá do evento de Alteração,   ||
			//pois eu preciso carregar os dependentes do evento de alteração no Evento do PAI, que será retIficado.                                  ||                                                                  ||
			//========================================================================================================================================+
			If cAlICapOri == "V91"
				cIdVerOri := T1V->( T1V_ID + T1V_VERSAO )
			Else
				cIdVerOri := C9V->( C9V_ID + C9V_VERSAO )
			EndIf

			If (cAlICapOri)->( dbSeek( xFilial(cAlICapOri) + cIdVerOri ))
				cIdVerDes	:= (cAlICapOri)->( &(cAlICapOri + "_ID") + &(cAlICapOri + "_VERSAO"))

				While (cAlICapOri)->( !Eof() ) .And. cIdVerDes == (cAlICapOri)->( &(cAlICapOri + "_ID") + &(cAlICapOri + "_VERSAO")) .AND. nOper = 3
					//crio um array com o nome dos campos que serão atualizados
					aCampos  := xFunGetSX3(cAlICapDes)

					cIdTre	  := (cAlICapOri)->&(cAlICapOri + "_CODTRE")

					//Valido e adiciono mais uma linha
					If nCapTre > 0
						oModelAlt:GetModel( "MODEL_" + cAlICapDes ):lValid:= .T.
						oModelAlt:GetModel( "MODEL_" + cAlICapDes ):AddLine()
					EndIf

					//Carrego as informações no modelo
					aEval(aCampos,{|Campo|oModelAlt:LoadValue( "MODEL_" + cAlICapDes, campo[2],(cAlICapOri)->&(cAlICapOri + Substr( Alltrim( campo[2] ),4 ) ) ) } )
					oModelAlt:LoadValue( "MODEL_" +cAlICapDes,cAlICapDes + "_CODTRE",cIdTre)
					oModelAlt:LoadValue( "MODEL_" +cAlICapDes,cAlICapDes + "_DSCTRE",;
						AllTrim(POSICIONE("V2M", 1, XFILIAL("V2M") + cIdTre,"Alltrim(V2M_CODIGO+' - '+V2M_DESCRI)") ) )
					( cAlICapOri )->( dbSkip() )				
						
					nCapTre++
				Enddo

			EndIf
		EndIf
	EndIf

	If !IsBlind()
		FWExecView(cTitulo,cFunName,nOper,,{||.T.},,,,,,,oModelAlt)
	Else

		If cFunName == "TAFA276"
			oModelAlt:LoadValue("MODEL_T1V", "T1V_DTALT", dDataBase)
		EndIf

		If oModelAlt:VldData()
			oModelAlt:CommitData()
		EndIf
	EndIf

Return	(.T.)

//----------------------------------------------------------------------
/*/{Protheus.doc} AtuaInfo
Atualiza a variável cTexto com a informação referente a opção selecionada

@Return 

@Author Paulo Vilas Boas Santana
@Since 03/02/2016
@Version 1.0
/*/
//-----------------------------------------------------------------------
Static Function AtuaInfo(cTexto,nOpcRadio, cEvento)

	If (nOpcRadio == 1 .or. nOpcRadio == 10 ) .And. cEvento <> 'INCLUI'
		cTexto := "RetIfica informações do trabalhador, corrigindo dados referentes ao eventos S-2200 ou S-2300. Esta opção não deve ser utilizada para informar "
		cTexto	+= "alterações cadastrais ou contratuais do trabalhador, mas apenas para corrigir as informações enviadas com inconsistência."

	Else

		If cEvento $ ("S2200")

			If nOpcRadio == 2 .or. nOpcRadio == 11
				cTexto :=	"Cria um novo evento 'S-2205' com informações de 'Alteração dos Dados Cadastrais' do funcionário. Utilize esta opção para informar alterações, como: "
				cTexto +=	"Mudança de endereço do trabalhador, alteração de estado cívil, inclusão ou exclusão de dependentes, entre outras." + CRLF
				cTexto +=	"Essa opção não deve ser utilizada para corrigir informações enviadas anteriormente, para tal utilize uma das opções de retificar."

			ElseIf nOpcRadio == 3 .or. nOpcRadio == 12
				cTexto :=	"Cria um novo evento 'S-2206' com informações de 'Alteração dos Dados Contratuais' do funcionário. Utilize esta opção para informar alterações, como: "
				cTexto +=	"Mudança de cargo, aumento de salário, alteração do local de trabalho , entre outras." + CRLF
				cTexto +=	"Essa opção não deve ser utilizada para corrigir informações enviadas anteriormente, para tal utilize uma das opções de retificar."

			ElseIf nOpcRadio == 4 .or. nOpcRadio == 13
				cTexto :=	"RetIfica informações referente ao último evento de 'Alteração dos Dados Cadastrais' (S-2205), gerado para o trabalhador. Utilize esta opção para corrigir dados "
				cTexto	+=	"cadastrais inconsistentes em um evento S-2205"

			ElseIf nOpcRadio == 5 .or. nOpcRadio == 14
				cTexto :=	"RetIfica informações referente ao último evento de 'Alteração dos Dados Contratuais' (S-2206), gerado para o trabalhador. Utilize esta opção para corrigir dados "
				cTexto	+=	"contratuais inconsistentes em um evento S-2206"

			EndIf

		ElseIf cEvento == ("S2300")

			If nOpcRadio == 2 .or. nOpcRadio == 11
				cTexto :=	"Cria um novo evento 'S-2205' com informações de 'Alteração dos Dados Cadastrais' do funcionário. Utilize esta opção para informar alterações, como: "
				cTexto +=	"Mudança de endereço do trabalhador, alteração de estado cívil, inclusão ou exclusão de dependentes, entre outras." + CRLF
				cTexto +=	"Essa opção não deve ser utilizada para corrigir informações enviadas anteriormente, para tal utilize uma das opções de retificar."

			ElseIf nOpcRadio == 6 .or. nOpcRadio == 16
				cTexto :=	"Cria um novo evento 'S-2306' com informações de 'Alteração dos Dados Contratuais - Trabalhador Sem Vínculo'. Utilize esta opção para informar alterações, como: "
				cTexto +=	"Mudancaça de cargo, aumento de salário, alteração do local de trabalho, entre outras informações do trabalhador SEM vínculo empregatício." + CRLF
				cTexto +=	"Essa opção não deve ser utilizada para corrigir informações enviadas anteriormente, para tal utilize uma das opções de retificar."

			ElseIf nOpcRadio == 7 .or. nOpcRadio == 15
				cTexto :=	"RetIfica informações referente ao último evento de 'Alteração dos Dados Contratuais - Trabalhador Sem Vínculo' (S-2306), gerado para o trabalhador. Utilize esta opção para corrigir dados "
				cTexto	+=	"cadastrais inconsistentes em um evento S-2306 "

			EndIf
		Else
			If nOpcRadio == 1
				cTexto := STR0007 //"S-2200 - Admissão de Trabalhador (Inclusão do trabalhador que possui vínculo empregatício com a empresa)."
			ElseIf nOpcRadio == 2
				cTexto := STR0008 //"S-2300 - Trabalhador Sem Vínculo - Início (Inclusão do trabalhador que não possui vínculo empregatício com a empresa)."
				cTexto += " " + STR0057 //"Incluem-se neste grupo trabalhadores avulsos, dirigentes sindicais, estagiários, diretores não empregados, cooperados, servidores públicos indicados para Conselho ou Órgão Administrativo, membros de conselho tutelar e trabalhadores cedidos."
			EndIf
		EndIf

	EndIf

	oTMultiget:Refresh()

Return nOpcRadio

//----------------------------------------------------------------------------
/*/{Protheus.doc} SelecOpc
Cria tela com opções em um Radio para o usuário selecionar
aOpcoes - Array com as opções que serão apresentadas para o usuário

@Return 
nOpc - Número referente a opção selecionada pelo usuário
cNomEvt - Nome do evento do cadastro do trabalhador S2200 ou S2300
cTpTela - Uitlizado para definir o tamanho e o formato da tela a ser construida
cTpTela -> Tipo de Tela que contém as opções.
	   2 -> XML
	   3 -> VLD
	  "" -> Inclusão do Evento do Trabalhador	 

@Author Paulo Vilas Boas Santana
@Since 18/02/2016
@Version 1.0
/*/
//----------------------------------------------------------------------------
Function SelecOpc(aOpcoes, cNomEvt, cTpTela, cTitulo, cMens, lOk )

	Local oDlg			:= Nil
	Local oRadio		:= Nil
	Local oTBok			:= Nil
	Local oTBSair		:= Nil
	Local cTexto		:= ""
	Local nOpc			:= 0
	Local nLinFrom  	:= 0
	Local nColFrom  	:= 0
	Local nLinBtOk  	:= 0
	Local nColBtOk  	:= 0
	Local nLinBtSair	:= 0
	Local nColBtSair	:= 0
	Local nLinToMult	:= 0
	Local nColToMult	:= 0
	Local nLinFrMult	:= 0
	Local nColFrMult	:= 0

	Private oTMultiget	:= Nil
	Private oFont1	  	:= TFont():New( "MS Sans SerIf",0,-14,,.F.,0,,700,.F.,.F.,,,,,, )
	Private oSay1			:= Nil

	Default cTpTela		:= '1'
	Default cTitulo		:= STR0014 //Alteração do TRabalhador
	Default cMens			:= STR0026 //Selecione a operação desejada:
	Default lOk			:= .F.

	If cTpTela == '2'
		nLinTo     := 680
		nColTo     := 1192
		nLinFrom   := 428
		nColFrom   := 741
		nLinBtSair := 100
		nColBtSair := 130
		nLinBtOk   := 100
		nColBtOK   := 058
		nSayCol    := 055
		nLinToMult := 92
		nColToMult := 01
		nLinFrMult := 260
		nColFrMult := 52

	ElseIf cTpTela == '3'
		nLinTo     := 370
		nColTo     := 480
		nLinFrom   := 110
		nColFrom   := 80
		nLinBtSair := 115
		nColBtSair := 100
		nLinBtOk   := 115
		nColBtOK   := 050
		nSayCol    := 038
		nLinToMult := 58
		nColToMult := 01
		nLinFrMult := 200
		nColFrMult := 50

	ElseIf cTpTela $ '1|4'
		nLinTo     := 480
		nColTo     := 670
		nLinFrom   := 150
		nColFrom   := 150
		nLinBtSair := 150
		nColBtSair := 150
		nLinBtOk   := 150
		nColBtOK   := 070
		nSayCol    := 058
		nLinToMult := 92
		nColToMult := 01
		nLinFrMult := 260
		nColFrMult := 52

	ElseIf cTpTela == '6'
		nLinTo     := 680
		nColTo     := 1192
		nLinFrom   := 428
		nColFrom   := 741
		nLinBtSair := 100
		nColBtSair := 130
		nLinBtOk   := 100
		nColBtOK   := 058
		nSayCol    := 035
		nLinToMult := 70
		nColToMult := 01
		nLinFrMult := 350
		nColFrMult := 52

	EndIf

	DEFINE DIALOG oDlg TITLE cTitulo FROM nLinFrom,nColFrom TO nLinTo,nColTo PIXEL STYLE DS_MODALFRAME
	oDlg:lEscClose := .F.
	oRadio := TRadMenu():New (30,25,aOpcoes,,oDlg,,,,,,,,150,32,,,,.T.)
	oRadio:bSetGet := {|u|Iif (PCount()==0,nOpc,Iif( !( cTpTela $ '2|6|4'),nOpc:=AtuaInfo(@cTexto,Iif(cNomEvt=='INCLUI',u,TafRetOpc(aOpcoes,u,cTpTela)),cNomEvt),;
		nOpc:= Iif(cNomEvt=='INCLUI',u,(TafRetOpc(aOpcoes,u,cTpTela)))))}

	oSay1		:= TSay():New( 012,nSayCol,{||cMens},oDlg,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,168,010)
	If cTpTela $ ('1|3')
		oTMultiget	:= tMultiget():create( oDlg, {| u | If( pCount() > 0, cTexto := u, cTexto )  }, nLinToMult,nColToMult,nLinFrMult,nColFrMult, , , , , , .T. )
	EndIf
	oTBok	:= TButton():New( nLinBtOk  , nColBtOk, "Confirmar",oDlg,{||lOk := .T., oDlg:End()},37,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTBSair	:= TButton():New( nLinBtSair, nColBtSair, "Sair",oDlg,{||nOpc:=0,oDlg:End()}, 37,12,,,.F.,.T.,.F.,,.F.,,,.F. )

	ACTIVATE DIALOG oDlg CENTERED

Return nOpc

//----------------------------------------------------------------------
/*/{Protheus.doc} RetUltAtivo
Posiciona no último registro ativo para o Trabalhador existente na chave
cAlias	-> cAlias da tabela que irá posicionar
cChave	-> Chave utilizada para posicionar
nInd	-> Número do Indice 

@Return .T. - Se encontrar um evento de alteração ativo para o trabalhador
		.F. - Se não encontrar um evento de alteração ativo para o trabalhador

@Author Paulo Sérgio V.B. Santana
@Since 25/02/2016
@Version 1.0
/*/
//-----------------------------------------------------------------------
Function RetUltAtivo(cAlias,cChave,nInd,lTrans,cFunction,nRecnoHist)

	Local lReturn 	:= .F.
	Local nRecno	:= 0
	Local cChvComp	:= ""

	Default cFunction := ""
	Default nRecnoHist := 0

	Default lTrans	:= .F. // indica se deve procurar um registro transmitido

	If (cAlias == "T0F" .OR. cAlias == "T1V" .OR. cAlias == "T1U").AND.!Empty(cFunction)
		dbSelectArea(cAlias)
		(cAlias)->(dbSetorder(nInd)) // FILIAL + ID + ATIVO + DTALT
		(cAlias)->(dbGoTo(nRecnoHist))
		cChave += DTOS((cAlias)->&(cAlias + "_DTALT"))
		If TafColumnPos(cAlias + "_DTEF")
			cChave += DTOS((cAlias)->&(cAlias + "_DTEF"))
		EndIf
	Else
		dbSelectArea(cAlias)
		(cAlias)->(dbSetorder(nInd)) // FILIAL + ID + ATIVO + DTALT 
		(cAlias)->(dbGoTop())
	EndIf

	If (cAlias)->(msSeek(xFilial(cAlias) + cChave))

		While (cAlias)->(!Eof()) .And. xFilial(cAlias) == (cAlias)->&(cAlias + "_FILIAL")  

			If cAlias == "T1V" .And. nInd == 4
				cChvComp := (cAlias)->&(cAlias + "_CPF") + (cAlias)->&(cAlias + "_MATRIC") + (cAlias)->&(cAlias + "_ATIVO")
			ElseIf cAlias == "T1U" .And. nInd == 3
				cChvComp := (cAlias)->&(cAlias + "_CPF") + (cAlias)->&(cAlias + "_ATIVO")
			ElseIf (cAlias == "T0F" .OR. cAlias == "T1U" .OR. cAlias == "T1V").AND. !empty(cFunction)
				If TafColumnPos(cAlias + "_DTEF")
					cChvComp := (cAlias)->&(cAlias + "_ID") + (cAlias)->&(cAlias + "_ATIVO") + DTOS((cAlias)->&(cAlias + "_DTALT")) + DTOS((cAlias)->&(cAlias + "_DTEF"))//Chave com data pelo historico
				Else
					cChvComp := (cAlias)->&(cAlias + "_ID") + (cAlias)->&(cAlias + "_ATIVO") + DTOS((cAlias)->&(cAlias + "_DTALT"))//Chave com data pelo historico
				EndIf				
			Else
				cChvComp := (cAlias)->&(cAlias + "_ID") + (cAlias)->&(cAlias + "_ATIVO")//Chave Original
			EndIf

			If cChvComp == cChave
				//pulo registro até chegar no último evento para esse trabalhador

				If cAlias $ ('T1U|T1V|T0F')
					If lTrans
						If(cAlias)->&(cAlias + "_ATIVO") == '1'
							nRecno := (cAlias)->(Recno())
						EndIf
					Else
						nRecno := (cAlias)->(Recno())
					EndIf
				Else
					nRecno := (cAlias)->(Recno())
				EndIf
			EndIf
			(cAlias)->(dbSkip())
		Enddo

		If nRecno > 0
			lReturn := .T.
			(cAlias)->(dbGoto(nRecno))
		EndIf
	EndIf

Return lReturn

//----------------------------------------------------------------------
/*/{Protheus.doc} TafRetOpc
Retorna o número da opção selecionada pelo usuário 

Como o Array aOpcoes é dinâmico utilizo a função TafRetOpc para definir 
um número para	 cada uma das opções possíveis, retornando o número 
correspondente a opção selecionada.

aOpcoes -> Array com as opções disponíveis na Tela
nOpc 	 -> Opção selecionada
cTpTela -> Tipo de Tela que contém as opções.
	   2 -> XML
	   3 -> VLD
	  "" -> Inclusão do Evento do Trabalhador	
@Return nOpc

@Author Paulo Sérgio V.B. Santana
@Since 25/02/2016
@Version 1.0
/*/
//-----------------------------------------------------------------------
Static Function TafRetOpc( aOpcoes, nOpc, cTpTela )

	Local nOpcRet 	:= 0
	Local cEvento	:= aOpcoes[nOpc]

	Default aOpcoes	:= {}
	Default nOpc	:= 0
	Default cTpTela	:= ""

	If cEvento ==  STR0023 .Or. (STR0049 $ cEvento .AND. cTpTela <> '1')     //retificar Evento do Trabalhador
		If cTpTela == "1"
			nOpcRet := 10
		Else
			nOpcRet := 1
		EndIf

	ElseIf cEvento == STR0028 .Or. (STR0050 $ cEvento .AND. cTpTela <> '1')  //Alterar Dados Cadastrais (S-2205) # S-2200
		If cTpTela == "1"
			nOpcRet := 11
		Elseif cTpTela == "2"
			nOpcRet := 8
		Elseif cTpTela == "6"
			nOpcRet := 1
		Else
			nOpcRet := 2
		EndIf

	ElseIf cEvento == STR0029 .Or. (STR0051 $ cEvento .AND. cTpTela <> '1')  //Alterar Dados Contratuais (S-2206) # S-2300
		If cTpTela == "1"
			nOpcRet := 12
		Elseif cTpTela == "2"
			nOpcRet := 9
		Elseif cTpTela == "6"
			nOpcRet := 1
		Else
			nOpcRet := 3
		EndIf

	ElseIf cEvento == STR0030 .Or. (STR0052 $ cEvento .AND. cTpTela <> '1')  //retificar Alteração de Dados Cadastrais (S-2205) # S-2205
		If cTpTela == "1"
			nOpcRet := 13
		Else
			nOpcRet := 4
		EndIf

	ElseIf cEvento == STR0031 .Or. (STR0053 $ cEvento .AND. cTpTela <> '1')  //retificar Alteração de Dados Contratuais (S-2206) # S-2206
		If cTpTela == "1"
			nOpcRet := 14
		Else
			nOpcRet := 5
		EndIf

	ElseIf cEvento == STR0038 //retificar Alteração Contratual - Trab. Sem Vínculo (S-2306)
		If cTpTela == "1"
			nOpcRet := 15
		Else
			nOpcRet := 7
		EndIf
	ElseIf cEvento == STR0039 .Or. (STR0054 $ cEvento .AND. cTpTela <> '1')  //Alterar Dados Contratuais - Trab. Sem Vínculo (S-2306) # S-2306
		If cTpTela == "1"
			nOpcRet := 16
		Else
			nOpcRet := 6
		EndIf

	EndIf

Return nOpcRet

//-------------------------------------------------------------------
/*/{Protheus.doc} xCarrHisAlt

Funcao para carregar a tela de histórico de alteração.

@author Paulo Sérgio V.B. Santana
@since 11/10/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function xCarrHisAlt()
	Local cAliasTrb := ''
	Private lHistLoop := .T.

	If !IsBlind()
		FWMsgRun(,{|| cAliasTrb := xHisAltTrb()},,STR0087) //"Executando Rotina do Trabalhador... "
	Else
		cAliasTrb := xHisAltTrb()
	EndIf

Return cAliasTrb

//-------------------------------------------------------------------
/*/{Protheus.doc} xHisAltTrb

Funcao para criar a tela de historico de alteracoes do registro.
O registro a ser filtrado eh o mesmo selecionado pelo usuario na Grid

@Param:
cAlias  -  Alias da Tabela Principal ( Tabela onde a Grid eh baseada
                                       para montar as informacoes    )
cRotina - Rotina onde a ViewDef se encontra

@Return:

@author Gustavo G. Rueda
@since 11/10/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function xHisAltTrb()

	Local cQry			:= ""
	Local aStru			:= {}
	Local nX			:= 0
	Local nY			:= 0
	Local aCampos		:= {}
	Local cNomeve		:= ""
	Local aHeaderT  	:= {}
	Local cRotina		:= "TAFA421"
	Local cTitulo		:= STR0015 + C9V->C9V_ID
	Local cNomeTrab		:= C9V->C9V_NOME
	Local oTmpTab 		:= Nil

	Private cAliasTrb	:= ""
	Private oDlgPrinc	:= nil

	Private lMenuDIf 	:= .T.

	aAdd(aCampos,{'Filial'					,'FILIAL'		,TamSX3("C9V_FILIAL")[1]							,'C','@!',0,	0})
	aAdd(aCampos,{'Data Evento'				,'DTEVEN'		,8													,'D',''  ,1,	2})
	aAdd(aCampos,{'ID.'						,'ID'			,TamSX3("C9V_ID")[1]								,'C','@!',1,	0})
	aAdd(aCampos,{'Data Sistemica'			,'DATASYS'		,8													,'D',''  ,1,	2})
	aAdd(aCampos,{'Status Secundário'		,'STASEC'		,1													,'C',''  ,1,	0})
	aAdd(aCampos,{'Nome Evento' 			,'NOMEVE'		,TamSX3("C9V_NOMEVE")[1]							,'C','@!',1,	0})
	aAdd(aCampos,{'Evento'					,'EVENTO'		,TamSX3("C9V_EVENTO")[1]							,'C','@!',1,	0})
	aAdd(aCampos,{'CPF'						,'CPF'			,TamSX3("C9V_CPF")[1]								,'C','@!',1,	5})
	aAdd(aCampos,{'Nome'					,'NOME'		    ,TamSX3("C9V_NOME")[1]								,'C','@!',1,	0})
	aAdd(aCampos,{'Versão'					,'VERSAO'		,TamSX3("C9V_VERSAO")[1]							,'C','@!',1,	0})
	aAdd(aCampos,{'AliasTab'				,'ALIASTAB'	    ,3													,'C',''  ,1,	0})
	aAdd(aCampos,{'RecNo'					,'RECNO'		,10													,'N',''  ,1,	0})
	aAdd(aCampos,{'Status de Transmissão'	,'STATUS'		,1													,'C','@' ,1,	0})
	aAdd(aCampos,{'Ativo'					,'ATIVO'		,1													,'C','@' ,1,	0})

	For nX := 1 To Len(aCampos)
		aAdd(aStru,{ aCampos[nX][2]	, aCampos[nX][4], aCampos[nX][3], 0})
	Next nX

	cQry := ChangeQuery(FCriaQry())
	TCQuery cQry New Alias 'cAliasSelec'

	cAliasTrb := GetNextAlias()
	oTmpTab := FWTemporaryTable():New(cAliasTrb, aStru)

	oTmpTab:AddIndex("1",{"EVENTO"})
	oTmpTab:AddIndex("2",{"DTEVEN"})
	oTmpTab:AddIndex("3",{"EVENTO","DTEVEN"})
	oTmpTab:Create()

	DbSelectArea(cAliasTrb)
	(cAliasTrb)->(DbSetOrder(2))
	(cAliasTrb)->(DBGoTop())

	cAliasSelec->(dbGotop())

	nPosFld	:= aScan( aCampos, { |x| x[02] == 'NOME' } )
	nPosId		:= aScan( aCampos, { |x| x[02] == 'NOMEVE' } )

	While cAliasSelec->(!Eof())

		RecLock((cAliasTrb),.T.)
		cNomeve := cAliasSelec->&(aCampos[nPosId][2])

		For nX := 1 To Len(aCampos)
			If nX == nPosFld .And. (cNomeve == "S2306" .OR. cNomeve == "S2206")
				(cAliasTrb)->&(aCampos[nX][2]) := cNomeTrab //Tratamento feito para os eventos que possuem campo _NOME como virtual
			Else
				If aCampos[Nx][04] == "D"
					(cAliasTrb)->&(aCampos[nX][2]) := Stod(cAliasSelec->&(aCampos[nX][2]))
				Else
					(cAliasTrb)->&(aCampos[nX][2]) := cAliasSelec->&(aCampos[nX][2])
				EndIf
			EndIf

		Next nX
		(cAliasTrb)->(MsUnlock())
		cAliasSelec->(dbSkip())
	EndDo
	cAliasSelec->(dbCloseArea())

	//=================================+
	// Cria Colunas para o Browse	   ||
	//=================================+
	For nX := 1 To Len (aCampos)
		If !aCampos[nX][2] $ ("VERSAO|RECNO|EVENTO|ALIASTAB|STASEC")
			nY++
			aAdd(aHeaderT,FWBrwColumn():New())

			If 	aCampos[nX][7] <> 0
				nPosTamCol := 7
			Else
				nPosTamCol := 3
			EndIf

			If aCampos[nX][2] == "STATUS"
				aHeaderT[nY]:SetData( &("{||TAF421Sts((cAliasTrb)->"+aCampos[nX][2]+")}") )
				aHeaderT[nY]:SetSize(30)
			ElseIf aCampos[nX][2] == "ATIVO"
				aHeaderT[nY]:SetData( &("{||TAF421Atv((cAliasTrb)->"+aCampos[nX][2]+")}") )
				aHeaderT[nY]:SetSize(10)
			Else
				aHeaderT[nY]:SetData( &("{||(cAliasTrb)->"+aCampos[nX][2]+"}") )
				aHeaderT[nY]:SetSize( aCampos[nX][nPosTamCol])
			EndIf
			aHeaderT[nY]:SetTitle(aCampos[nX][1])
			aHeaderT[nY]:SetType(aCampos[nX][4])
			aHeaderT[nY]:SetDecimal(0)
			aHeaderT[nY]:SetPicture(aCampos[nX][5])
			aHeaderT[nY]:SetAlign(aCampos[nX][6])
		EndIf
	Next nX

	//Chamo a Browse do Histórico
	If !IsBlind()
		xFunNewHis( cAliasTrb, cRotina, aHeaderT, cTitulo, .T.,, aCampos)
	EndIf

Return cAliasTrb

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF421Sts
Retorna descrição do Status de Transmissão

@author Evandro
@since 26/08/2016
@version 1.0
@param cStatus - Código do Status
@return cRetStatus - Descrição do Status
/*/
//-------------------------------------------------------------------
Function TAF421Sts(cStatus)

	Local cRetStatus := ""

	Do Case

	Case Empty(cStatus)
		cRetStatus = STR0065 //"AGUARDANDO PROCESSAMENTO"
	Case  cStatus == "0"
		cRetStatus = STR0066 //"VÁLIDO"
	Case cStatus == "1"
		cRetStatus = STR0067 //"INVÁLIDO"
	Case cStatus == "2"
		cRetStatus = STR0068 //"TRANSMITIDO (AGUARDANDO RETORNO)"
	Case cStatus == "3"
		cRetStatus = STR0069 //"TRANSMITIDO INVÁLIDO"
	Case cStatus == "4"
		cRetStatus = STR0070 //"TRANSMITIDO VÁLIDO"
	Case cStatus == "6"
		cRetStatus = STR0071 //"PENDENTE DE EXCLUSÃO"
	Case cStatus == "7"
		cRetStatus = STR0072// "EXCLUSÃO EFETIVADA"

	End Case

Return cRetStatus

//-------------------------------------------------------------------
/*/{Protheus.doc} FCriaQry

Funcao para retornar a query utilizada na seleção do histórico das
alterações do trabalhador.

@Param:
cChvTrb  -  Chave do evento do trab. para o qual deve ser selecionado o
			 histórico das alterações.
cRotina - Rotina onde a ViewDef se encontra

@Return:

@author Gustavo G. Rueda
@since 11/10/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function FCriaQry()

	Local cQry			:= ''
	Local cIdTrab		:= C9V->C9V_ID
	Local cFilTrab  	:= C9V->C9V_FILIAL
	Local cEvenTrb		:= C9V->C9V_NOMEVE
	Local cTabExt   	:= Iif(cEvenTrb=="S2200","CUP_DTADMI","C9V_DTINIV")

	cQry := " SELECT C9V_FILIAL FILIAL, C9V_ID ID, C9V_NOMEVE NOMEVE, C9V_EVENTO EVENTO, C9V_CPF CPF, C9V_NOME NOME, "
	cQry += " C9V_VERSAO VERSAO, C9V_MATRIC MATRIC, C9V.R_E_C_N_O_ RECNO, C9V_STATUS STATUS, C9V_ATIVO ATIVO "
	If TafColumnPos( "C9V_STASEC" ) .And.  TafColumnPos( "C9V_DINSIS" )
		cQry += " , 'C9V' ALIASTAB, C9V_DINSIS DATASYS, C9V_STASEC STASEC, "+cTabExt+" DTEVEN "
	Else
		cQry += " , 'C9V' ALIASTAB, '' DATASYS, ' ' STASEC, "+cTabExt+" DTEVEN "
	EndIf
	cQry += " FROM " + RetSqlName("C9V") + " C9V"
	If cEvenTrb == "S2200"
		cQry += " LEFT JOIN " + RetSqlName("CUP") + " EXT "
		cQry += " ON C9V_ID = CUP_ID "
		cQry += " AND C9V_VERSAO = CUP_VERSAO "
		cQry += " AND EXT.D_E_L_E_T_ = '' "
	EndIf
	cQry += " WHERE C9V_NOMEVE <> 'ORIGI' "
	cQry += " AND C9V_ID = '" + cIdTrab + "' "
	cQry += " AND C9V_FILIAL = '" + cFilTrab + "' "
	cQry += " AND C9V_ATIVO = '1' "
	cQry += " AND C9V.D_E_L_E_T_ = '' "

	If cEvenTrb $ ("S2200")

		cQry += " UNION "
		cQry += " SELECT T1V_FILIAL FILIAL, T1V_ID ID, 'S2206' NOMEVE, T1V_EVENTO EVENTO, T1V_CPF CPF, '' NOME, "
		cQry += " T1V_VERSAO VERSAO, T1V_MATRIC MATRIC, T1V.R_E_C_N_O_ RECNO, T1V_STATUS STATUS, T1V_ATIVO ATIVO "
		If TafColumnPos( "T1V_STASEC" ) .And. TafColumnPos( "T1V_DINSIS" )
			cQry += " , 'T1V' ALIASTAB, T1V_DINSIS DATASYS, T1V_STASEC STASEC, T1V_DTALT DTEVEN "
		Else
			cQry += " , 'T1V' ALIASTAB, '' DATASYS, ' ' STASEC, T1V_DTALT DTEVEN "
		EndIf
		cQry += " FROM " + RetSqlName("T1V")+" T1V "
		cQry += " WHERE T1V_ID = '" + cIdTrab + "' "
		cQry += " AND T1V_FILIAL = '" + cFilTrab + "' "
		cQry += " AND T1V_ATIVO = '1' "
		cQry += " AND D_E_L_E_T_ = '' "

		cQry += " UNION "
		cQry += " SELECT T1U_FILIAL FILIAL, T1U_ID ID, 'S2205' NOMEVE, T1U_EVENTO EVENTO, T1U_CPF CPF, T1U_NOME NOME, "
		cQry += " T1U_VERSAO VERSAO, '' MATRIC, T1U.R_E_C_N_O_ RECNO, T1U_STATUS STATUS, T1U_ATIVO ATIVO "
		If TafColumnPos( "T1U_STASEC" ) .And. TafColumnPos( "T1U_DINSIS" )
			cQry += " , 'T1U' ALIASTAB, T1U_DINSIS DATASYS, T1U_STASEC STASEC, T1U_DTALT DTEVEN "
		Else
			cQry += " , 'T1U' ALIASTAB, '' DATASYS, ' ' STASEC, T1U_DTALT DTEVEN "
		EndIf
		cQry += " FROM " + RetSqlName("T1U")+" T1U "
		cQry += " WHERE T1U_ID = '" + cIdTrab + "' "
		cQry += " AND T1U_FILIAL = '" + cFilTrab + "' "
		cQry += " AND T1U_ATIVO = '1' "
		cQry += " AND D_E_L_E_T_ = '' "

	Else //"S2300"

		cQry += " UNION "
		cQry += " SELECT T0F_FILIAL FILIAL, T0F_ID ID, 'S2306' NOMEVE, T0F_EVENTO EVENTO, T0F_CPF CPF, '' NOME, "
		cQry += " T0F_VERSAO VERSAO, '' MATRIC, T0F.R_E_C_N_O_ RECNO, T0F_STATUS STATUS, T0F_ATIVO ATIVO "
		If TafColumnPos( "T0F_STASEC" ) .And. TafColumnPos( "T0F_DINSIS" )
			cQry += " , 'T0F' ALIASTAB, T0F_DINSIS DATASYS, T0F_STASEC STASEC, T0F_DTALT DTEVEN "
		Else
			cQry += " , 'T0F' ALIASTAB, '' DATASYS, ' ' STASEC, T0F_DTALT DTEVEN "
		EndIf
		cQry += " FROM " + RetSqlName("T0F")+" T0F "
		cQry += " WHERE T0F_ID = '" + cIdTrab + "' "
		cQry += " AND T0F_FILIAL = '" + cFilTrab + "' "
		cQry += " AND T0F_ATIVO = '1' "
		cQry += " AND D_E_L_E_T_ = '' "

		cQry += " UNION "
		cQry += " SELECT T1U_FILIAL FILIAL, T1U_ID ID, 'S2205' NOMEVE, T1U_EVENTO EVENTO, T1U_CPF CPF, T1U_NOME NOME, "
		cQry += " T1U_VERSAO VERSAO, '' MATRIC, T1U.R_E_C_N_O_ RECNO, T1U_STATUS STATUS, T1U_ATIVO ATIVO "
		If TafColumnPos( "T1U_STASEC" ) .And. TafColumnPos( "T1U_DINSIS" )
			cQry += " , 'T1U' ALIASTAB, T1U_DINSIS DATASYS, T1U_STASEC STASEC, T1U_DTALT DTEVEN "
		Else
			cQry += " , 'T1U' ALIASTAB, '' DATASYS, ' ' STASEC, T1U_DTALT DTEVEN "
		EndIf
		cQry += " FROM " + RetSqlName("T1U")+" T1U "
		cQry += " WHERE T1U_ID = '" + cIdTrab + "' "
		cQry += " AND T1U_FILIAL = '" + cFilTrab + "' "
		cQry += " AND T1U_ATIVO = '1' "
		cQry += " AND D_E_L_E_T_ = '' "

	EndIf
	cQry += " ORDER BY FILIAL, NOMEVE, DTEVEN "

Return (cQry)

//-------------------------------------------------------------------
/*/{Protheus.doc} xCarrVisul

Funcao para carregar a visualização do cadastro do trabalhador

@author Paulo Sérgio V.B. Santana
@since 11/10/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function xCarrVisul()

	FWMsgRun(,{||TafVisuTrb()},,STR0087) //"Executando Rotina do Trabalhador... "

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TafVisuTrb

Funcao utilizada para visualizar um registro no cadastro do trabalhador
Chama a execview na opção de visualizar.

@Param:
@Return:

@author Gustavo G. Rueda
@since 11/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TafVisuTrb()

	Local nOperation := MODEL_OPERATION_VIEW
	Local aEvento    := {}
	Local aOpcoes	 := {}
	Local cNomeve	 := ""
	Local cTitulo    := ""
	Local nRecno 	 := ""
	Local cTituloMsg := STR0074
	Local cMens	   	 := STR0078
	Local cFuncao	 := ""

	If Type("cAliasTrb") <> "U" .And. (!FWIsInCallStack("FopenPnTrab") .Or. FWIsInCallStack("XFUNNEWHIS") )// Quando for chamado pelo histórico de alterações
		cNomeve:= Substr((cAliasTrb)->(NOMEVE),1,1) + "-" + Substr((cAliasTrb)->(NOMEVE),2)
		cTitulo:= Iif((cAliasTrb)->(EVENTO) == 'I' .And.!(cAliasTrb)->(NOME)$('S2200|S2300'),STR0019,; //Cadastro do Trabalhador
		Iif((cAliasTrb)->(EVENTO) == 'I',STR0016,Iif((cAliasTrb)->(EVENTO) == 'A',STR0012,STR0011)))//Evento de Alteração # Informações do Trabalhador # Exclusão do Evento
		nRecno	:= (cAliasTrb)->(RECNO)

		aEvento := TAFRotinas((cAliasTrb)->(cNomeve),4,.F.,2)
		DbSelectArea(aEvento[3])
		(aEvento[3])->(DbGoTo(nRecNo))
		cFuncao := aEvento[1]
	Else // Quando for chamado pelo botão de visualizar

		cTitulo := STR0019

		If Alltrim(C9V->C9V_NOMEVE) $ "S2200"

			aAdd(aOpcoes, STR0075) //VerIfica se tem o S2200

			DbSelectArea("T1U")
			If RetUltAtivo( 'T1U', C9V->C9V_ID + "1", 2)				//VerIfica se tem o S2205
				aAdd(aOpcoes, STR0076)
			EndIf

			DbSelectArea("T1V")
			If RetUltAtivo( 'T1V', C9V->C9V_ID + "1", 2)				//VerIfica se tem o S2206
				aAdd(aOpcoes, STR0077)
			EndIf

			nOpc := SelecOpc(aOpcoes,,"6",cTituloMsg,cMens )

			If nOpc == 1 //S2200
				cFuncao := "TAFA278"
			ElseIf nOpc == 4 //S2205
				cFuncao := "TAFA275"
			ElseIf nOpc == 5 //S2206
				cFuncao := "TAFA276"
			EndIf

		ElseIf Alltrim(C9V->C9V_NOMEVE) $ "S2300|S2306"

			aAdd(aOpcoes, STR0079) //VerIfica se tem o S2300

			DbSelectArea("T1U")
			If RetUltAtivo( 'T1U', C9V->C9V_ID + "1", 2) //VerIfica se tem o S2205
				aAdd(aOpcoes, STR0076)
			EndIf

			DbSelectArea("T0F")
			If RetUltAtivo( 'T0F', C9V->C9V_ID + "1", 2) //VerIfica se tem o S2306
				aAdd(aOpcoes, STR0080)
			EndIf

			nOpc := SelecOpc(aOpcoes,,"6",cTituloMsg,cMens )

			If nOpc == 1 .Or. nOpc == 3 //S2300
				cFuncao := "TAFA279"
			ElseIf nOpc == 6 //S2306
				cFuncao := "TAFA277"
			ElseIf nOpc == 4 //S2205
				cFuncao := "TAFA275"
			EndIf

		EndIf
	EndIf

	If !Empty(cFuncao)

		If TafAtualizado(, cFuncao)
			FWExecView(cTitulo,cFuncao,nOperation,, {|| .T. } )
		EndIf
		
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF421XmlVld

Funcao de geracao do XML para atender todos os eventos relacionados
ao cadastro do trabalhador 
Quando a rotina for chamada o registro deve estar posicionado.

@Param:
nOpXmlVld - Indica se a opção escolhida foi de geração de XML ou 
Validação de evento.

@author Paulo Santana
@since 23/10/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF421XmlVld(nOpXmlVld, cFunction)

	Local aOpcoes	:= {}
	Local cTitulo	:= Iif(nOpXmlVld == 1, "Geração de XML", "Validação do Evento")
	Local cMens		:= Iif(nOpXmlVld == 1, STR0047,STR0056) //Selecione o tipo de evento desejado: # Selecione o evento que deseja validar:
	Local nOpc		:= 0
	Local nRecno	:= C9V->(Recno())
	Local lXmlVLd	:= IIF(FindFunction('TafXmlVLD'),TafXmlVLD('TAF421XMLVLD'),.T.)
	Local aGerXml   := {}
	Local aXmls     := {}
	Local aRet      := {}
	Local nRecnoHist := 0

	Default cFunction := ""

	if cFunction == "xNewHisAlt"
		nRecnoHist := (cAliasHist)->RECNO
	EndIF

	cId := C9V->C9V_ID + '1'

	If C9V->C9V_NOMEVE == "S2200"
		aAdd(aOpcoes,STR0050 + ' - ' +STR0019) //"S-2200 - Cadastro do Trabalhador
		//Pesquiso se existe S2205 ativo para o trabalhador
		If RetUltAtivo('T1U',cID,2,,cFunction,nRecnoHist)
			aAdd(aOpcoes,STR0052 + ' - ' + STR0020) //S-2205 - Alteração dos Dados Cadastrais
		EndIf
		//Pesquiso se existe S2206 ativo para o trabalhador
		If RetUltAtivo('T1V',cID,2,,cFunction,nRecnoHist)
			aAdd(aOpcoes,STR0053 + ' - ' + STR0021) //S-2206 - Alteração Contratual - Evento S-2206
		EndIf
	ElseIf C9V->C9V_NOMEVE == "S2300"
		aAdd(aOpcoes,STR0051 + ' - ' +STR0022) //"S-2300 # "Cadastro do Trabalhador Sem Vínculo"
		//Pesquiso se existe S2306 ativo para o trabalhador
		If RetUltAtivo('T0F',cID,2,,cFunction,nRecnoHist)
			aAdd(aOpcoes,STR0054 + ' - ' + STR0021 + STR0055) //S-2306 - Alteração Contratual
		EndIf
		If RetUltAtivo('T1U',cID,2,,cFunction,nRecnoHist)
			aAdd(aOpcoes,STR0052 + ' - ' + STR0020) //S-2205 - Alteração dos Dados Cadastrais
		EndIf
	EndIf
	If (!IsBlind())
		If lXmlVLd

			nOpc := SelecOpc(aOpcoes,,"2",cTitulo,cMens )
			If nOpc > 0
				If nOpXmlVld == 1
					aGerXml   := IIF(FindFunction('TAfxmltss'),TAfxmltss(),{})
				EndIf
				If Len(aGerXml) > 0
					lGerXml := aGerXml[1]
					cOpcXML := aGerXml[2]
					lRetXml := lGerXml .AND. cOpcXML == "1-XML TAF"
				Else
					lGerXml := .T.
					lRetXml := .T.
					cOpcXML := "1- XML TAF"
				EndIf
				If nOpc == 2 .or. nOpc == 8 //S-2200
					If nOpXmlVld == 1  .AND. lRetXml
						TAF278Xml( "C9V", nRecno )
					Else
						cLayout		 := "2200"
						cAlias		 := "C9V"
					EndIf
				ElseIf nOpc == 3 .or. nOpc == 9 //S-2300
					If nOpXmlVld == 1  .AND. lRetXml
						TAF279Xml( "C9V", nRecno)
					Else

						cLayout		 := "2300"
						cAlias		 := 'C9V'

					EndIf
				ElseIf nOpc == 4 //S-2205
					nRecno := T1U->(Recno())
					If nOpXmlVld == 1  .AND. lRetXml
						TAF275Xml( "T1U", nRecno )
					Else

						cLayout		 := "2205"
						cAlias		 := "T1U"
					EndIf

				ElseIf nOpc == 5 //S-2206
					nRecno := T1V->(Recno())
					If nOpXmlVld == 1  .AND. lRetXml
						TAF276Xml( "T1V", nRecno )
					Else
						cLayout		 := "2206"
						cAlias		 := "T1V"
					EndIf

				ElseIf nOpc == 6 //S-2306
					nRecno := T0F->(Recno())
					If nOpXmlVld == 1 .AND. lRetXml
						TAF277Xml( "T0F", nRecno )
					Else
						cLayout		 := "2306"
						cAlias		 := "T0F"
					EndIf
				EndIf

				If lGerXml .AND. cOpcXML == "2-XML RET"
					cTSSKey := "S" + cLayout + AllTrim( (cAlias)->&(cAlias+"_ID") ) + AllTrim( (cAlias)->&(cAlias+"_VERSAO") )
					aAdd( aXmls, cTSSKey )
					aRet := TAFGETXMLTSS(aXmls)
					If len(aRet) > 0
						cXml := aRet[1][4]
						If !Empty(cXml)
							xTafGerXml( cXml, cLayout )
						Else
							MsgInfo("Verifique se o evento está transmitido.","XML não encontrado.")
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} ExcXmlLote

Função utilizada para executar a rotina de xml em lote para todos os 
eventos do cadastro do Trabalhador

@author Paulo Santana
@since 23/02/2016
@version 1.0

/*/
//-------------------------------------------------------------------
Function ExcXmlLote()

	Local lLGPDperm := IIf(FindFunction("PROTDATA"),ProtData(),.T.)
	If lLGPDperm
		FWMsgRun(,{||SelecXmlLote()},,STR0087) //"Executando Rotina do Trabalhador... "
	EndIf
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SelecXmlLote

Função utilizada para executar a rotina de xml em lote para todos os 
eventos do cadastro do Trabalhador

@author Paulo Santana
@since 23/02/2016
@version 1.0

/*/
//-------------------------------------------------------------------
Function SelecXmlLote()

	Local aOpcoes := {}
	Local nOpc		:= 0
	Local cTitulo	:= "Geração de XML em Lote"
	Local cMens	:= STR0047 //#Selecione o tipo de evento desejado:

	aAdd(aOpcoes,STR0050 + ' - ' + STR0019) //S-2200 - Cadastro do Trabalhador
	aAdd(aOpcoes,STR0052 + ' - ' + STR0020) //S-2205 - Alteração dos Dados Cadastrais
	aAdd(aOpcoes,STR0053 + ' - ' + STR0021) //S-2206 - Alteração Contratual - Evento S-2206
	aAdd(aOpcoes,STR0051 + ' - ' + STR0022) //S-2300 # "Cadastro do Trabalhador Sem Vínculo"
	aAdd(aOpcoes,STR0054 + ' - ' + STR0021 + STR0055) //S-2306 - Alteração Contratual

	nOpc := SelecOpc(aOpcoes,,"2",cTitulo,cMens )

	If nOpc > 0
		If nOpc == 2 .OR. nOpc == 8 //S-2200
			TAFXmlLote( 'C9V', 'S-2200' , 'evtAdmissao' , 'TAF278Xml',,IIF( Type("oBrw") <> "U",oBrw,Nil) )
		ElseIf nOpc == 3 .OR. nOpc == 9 //S-2300
			TAFXmlLote( 'C9V', 'S-2300' , 'evtTSVInicio' , 'TAF279Xml', ,iIf( Type("oBrw") <> "U",oBrw,Nil) )
		ElseIf nOpc == 4 //S-2205
			TAFXmlLote( 'T1U', 'S-2205' , 'evtAltCadastral' , 'TAF275Xml', ,iIf( Type("oBrw") <> "U",oBrw,Nil) )
		ElseIf nOpc == 5 //S-2206
			TAFXmlLote( 'T1V', 'S-2206' , 'evtAltContratual' , 'TAF276Xml', ,iIf( Type("oBrw") <> "U",oBrw,Nil) )
		ElseIf nOpc == 6 //S-2306
			TAFXmlLote( 'T0F', 'S-2306' , 'evtTSVAltContr' , 'TAF277Xml', ,iIf( Type("oBrw") <> "U",oBrw,Nil) )
		EndIf
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} RetCodMen

Função utilizada para validar a operação executada pelo usuário após
selecionar o Tipo de Alteração desejado.

@author Paulo Santana
@since 23/01/2017
@version 1.0
@nCodReturn:
	1 - Registro de Alteração Pendente de transmissão (Status $ " |1") - NÃO PODERÁ SER ALTERADO!!!
	2 - Registro de Alteração Em Processo de transmissão (Status == "2") - NÃO PODERÁ SER ALTERADO!!!
	3 - Registro de Alteração com Inconsistencia apresentada pelo FISCO (Status == "3") - - NÃO PODERÁ SER ALTERADO!!!
	4 - Todos os eventos de alteração estão transmitidos - ALTERAÇÃO PERMITIDA!
	0 - Não existe evento de alteração para este trabalhador - ALTERAÇÃO PERMITIDA!

	=============================== A T E N Ç Ã O =====================================	
ATENÇÃO -> Durante o processo de alteração, NUNCA haverá um evento de ALTERAÇÃO,em processo
de transmissão de EXCLUSÃO (STATUS = 6) ou Excluído (STATUS = 7), pois NÃO SERÁ permitido
excluir uma alteração sem que seja excluído o Cadastro do Trabalhado (2200/2300)          

/*/
//-------------------------------------------------------------------
Static Function RetCodMen(cStat2205,cStat2206,cStat2306)

	Local nCodReturn := 0 //Código da mensagem do último evento de alteração transmitido

	If C9V->C9V_NOMEVE $ ("S2200")

		If (lExist2205 .And. cStat2205 $ (" |1|0")) .OR. (lExist2206 .And. cStat2206 $ (" |1|0"))
			nCodReturn := 1
		ElseIf cStat2205 == '2' .OR. cStat2206 == '2'
			nCodReturn := 2
		ElseIf cStat2205 == '3' .OR. cStat2206 == '3'
			nCodReturn := 3
		ElseIf (!lExist2205 .And. !lExist2206)
			nCodReturn := 0
		ElseIf (cStat2205 == '4' .And. cStat2206 == '4') .OR. (cStat2205 == '4' .And. !lExist2206) .OR. (cStat2206 == '4' .And. !lExist2205)
			nCodReturn := 4
		EndIf

	Else //S2300
		If !lExist2306
			nCodReturn := 0
		Else
			If cStat2306 $ (" |1|0")
				nCodReturn := 1
			Else
				nCodReturn := val(cStat2306)
			EndIf
		EndIf
	EndIf

	//Atualizando a mensagem de status de cada evento
	If lExist2205
		If cStat2205 $ (" |1|0")
			cStat2205 := '1'
		EndIf
	Else
		cStat2205 := '0'
	EndIf

	If lExist2206
		If cStat2206 $ (" |1|0")
			cStat2206 := '1'
		EndIf
	Else
		cStat2206 := '0'
	EndIf

	If lExist2306
		If cStat2306 $ (" |1|0")
			cStat2306 := '1'
		EndIf
	Else
		cStat2306 := '0'
	EndIf

Return nCodReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFCONF22
Wizard de confirmação da retificação do evento S-2200

@type        function
@author      Thiago Fernandes da Silva
@since       18/02/2020
@version     1.0
@description Wizard para alerta quanto a Retificação quando possui eventos com data 
             posterior ao do S-2200 original. 
@return      lRet22
/*/
//-------------------------------------------------------------------
Static Function TAFCONF22()

	Local oWizard    := Nil
	Local lRet22     := .F.

	Define WIZARD oWizard;
		TITLE    'RETIFICAÇÃO S-2200';
		HEADER   'T A F';
		MESSAGE  "TOTVS Automação Fiscal";
		TEXT     "<br>Esta funcionalidade foi criada para alertar os usuários quanto ao processo de Retificação do evento S-2200<br>" + ;
		"<br>Esta WIZARD foi ativada, pois o TAF identificou que para este vínculo que você esta tentando realizar o processo de retificação, existem eventos com data posterior a admissão.<br>" +;
		"<br>Segundo orientação do eSocial deve ser realizado o processo de DESEMPILHAMENTO dos eventos com data posteriores admissão.<br>"+;
		"<br><br>Me responsabilizo pela geração da Retificação sem realizar o Desempilhamento<br>"+;
		"<br><br><br>Para Prosseguir com a retificação, Selecione a opção FINALIZAR";
		FINISH { || lRet22 := .T. }

	Activate WIZARD oWizard Centered

Return lRet22

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF421Atv
Retorna descrição do Status Ativo

@author Evandro
@since 26/03/2020
@version 1.0
@param cAtivo - Código do Status
@return cRetStatus - Descrição do Status
/*/
//-------------------------------------------------------------------
Function TAF421Atv(cAtivo)

	Local cRet := ""

	If cAtivo == "1"
		cRet = STR0098 //"Ativo"
	Else
		cRet = STR0099 //"Inativo"
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RefreshExt
Refresh da tela de histórico de alterações

@author Rodrigo Nicolino
@since 29/10/2020
@version 1.0

/*/
//-------------------------------------------------------------------
Function RefreshExt(cNomeTrab, aAreaC9V)

	Local aCampos 		:= {}
	Local aStru 		:= {}
	Local nX 			:= 0
	Local cQuery 		:= ""
	Local cAlias 		:= ""
	Local nPosFld 		:= 0
	Local nPosId 		:= 0

	Default cNomeTrab	:= C9V->C9V_NOME
	Default aAreaC9V	:= C9V->(GetArea())

	If (lHistLoop)

		aAdd(aCampos,{'Filial'					,'FILIAL'		,TamSX3("C9V_FILIAL")[1]								,'C','@!',0,	0})
		aAdd(aCampos,{'Data Evento'				,'DTEVEN'		,8														,'D',''  ,1,	2})
		aAdd(aCampos,{'ID.'						,'ID'			,TamSX3("C9V_ID")[1]									,'C','@!',1,	0})
		aAdd(aCampos,{'Data Sistemica'			,'DATASYS'		,8														,'D',''  ,1,	2})
		aAdd(aCampos,{'Status Secundário'		,'STASEC'		,1														,'C',''  ,1,	0})
		aAdd(aCampos,{'Nome Evento' 			,'NOMEVE'		,TamSX3("C9V_NOMEVE")[1]								,'C','@!',1,	0})
		aAdd(aCampos,{'Evento'					,'EVENTO'		,TamSX3("C9V_EVENTO")[1]								,'C','@!',1,	0})
		aAdd(aCampos,{'CPF'						,'CPF'			,TamSX3("C9V_CPF")[1]									,'C','@!',1,	5})
		aAdd(aCampos,{'Nome'					,'NOME'			,TamSX3("C9V_NOME")[1]									,'C','@!',1,	0})
		aAdd(aCampos,{'Versão'					,'VERSAO'		,TamSX3("C9V_VERSAO")[1]								,'C','@!',1,	0})
		aAdd(aCampos,{'AliasTab'				,'ALIASTAB'		,3														,'C',''  ,1,	0})
		aAdd(aCampos,{'RecNo'					,'RECNO'		,10							    						,'N',''  ,1,	0})
		aAdd(aCampos,{'Status de Transmissão'	,'STATUS'		,1														,'C','@' ,1,	0})
		aAdd(aCampos,{'Ativo'					,'ATIVO'		,1														,'C','@' ,1,	0})

		For nX := 1 To Len(aCampos)
			aAdd(aStru,{ aCampos[nX][2]	, aCampos[nX][4], aCampos[nX][3], 0})
		Next nX

		DbSelectArea((cAliasTrb))
		(cAliasTrb)->(DbGoTop())

		While ((cAliasTrb)->(!Eof()))

			RecLock((cAliasTrb), .F.)
			(cAliasTrb)->(DbDelete())
			(cAliasTrb)->(MsUnlock())

			(cAliasTrb)->(DbSkip())

		Enddo

		RestArea(aAreaC9V)
		cQuery := ChangeQuery(FCriaQry())
		cAlias := MPSysOpenQuery(cQuery)

		nPosFld	:= aScan( aCampos, { |x| x[02] == 'NOME' } )
		nPosId := aScan( aCampos, { |x| x[02] == 'NOMEVE' } )

		While (cAlias)->(!Eof())

			RecLock((cAliasTrb),.T.)
			cNomeve := (cAlias)->&(aCampos[nPosId][2])

			For nX := 1 To Len(aCampos)

				If nX == nPosFld .And. (cNomeve == "S2306" .OR. cNomeve == "S2206")
					(cAliasTrb)->&(aCampos[nX][2]) := cNomeTrab //Tratamento feito para os eventos que possuem campo _NOME como virtual
				Else
					If aCampos[Nx][04] == "D"
						(cAliasTrb)->&(aCampos[nX][2]) := Stod((cAlias)->&(aCampos[nX][2]))
					Else
						(cAliasTrb)->&(aCampos[nX][2]) := (cAlias)->&(aCampos[nX][2])
					EndIf
				EndIf

			Next nX

			(cAliasTrb)->(MsUnlock())
			(cAlias)->(dbSkip())

		EndDo

		(cAlias)->(dbCloseArea())

		If ValType(oDlgPrinc) == "O"
			oDlgPrinc:Refresh()
		EndIf

	EndIf

Return
