#INCLUDE "totvs.ch"
//#INCLUDE "frameworkng.ch"
#include 'fileio.ch'
#include 'mntcounter.ch'

//Redefined in frameworkng.ch --------------+
#DEFINE __VALID_OBRIGAT__  'O'
#DEFINE __VALID_UNIQUE__   'U'
#DEFINE __VALID_FIELDS__   'F'
#DEFINE __VALID_BUSINESS__ 'B'
#DEFINE __VALID_ALL__      'OUFB'
#DEFINE __VALID_NONE__     ''
//------------------------------------------+

#DEFINE   _BUSINESSOP_BREAKCOUNTER_    1
#DEFINE   _BUSINESSOP_TURN_            2
#DEFINE   _BUSINESSOP_INFORM_          3

//------------------------------
// For�a a publica��o do fonte
//------------------------------
Function _MNTCounter()
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTCounter
Classe que realiza a manuten��o dos contadores dos equipamentos tal como
lan�amento, repasse para estruturas, quebra, virada, rec�lculo, valida��es,
entre outros.

@author Felipe Nathan Welter
@since 20/01/2017
@version P12
/*/
//---------------------------------------------------------------------
Class MNTCounter FROM NGGenerico

	Method New() CONSTRUCTOR

	//METODOS PUBLICOS
	Method BreakCounter()
	Method Turn()
	Method Inform()

	//METODOS PRIVADOS
	Method validBusiness()

	//ATRIBUTOS PUBLICOS
	//--

	//ATRIBUTOS PRIVADOS
	Data lCount1	As Boolean Init .F. //indica que realiza procedimentos com contador 1
	Data lCount2	As Boolean Init .F. //indica que realiza procedimentos com contador 2

EndClass

//---------------------------------------------------------------------
/*/{Protheus.doc} New
M�todo inicializador da classe.

@author Felipe Nathan Welter
@since 20/01/2017
@version P12
@return Self O objeto criado.
/*/
//---------------------------------------------------------------------
Method New() Class MNTCounter

	_Super:New()
	::SetAlias("STP")
	::SetAlias("TPP")
	::initFields(.T.)

	::setUniqueField("TP_FILIAL")
	::setUniqueField("TP_CODBEM")
	::setUniqueField("TP_DTLEITU")
	::setUniqueField("TP_HORA")

	::setUniqueField("TPP_FILIAL")
	::setUniqueField("TPP_CODBEM")
	::setUniqueField("TPP_DTLEIT")
	::setUniqueField("TPP_HORA")

	::setValidationType(__VALID_BUSINESS__)

	::cClassName := 'MNTCounter'

Return Self

//---------------------------------------------------------------------
/*/{Protheus.doc} validBusiness
M�todo que realiza a valida��o da regra de neg�cio da classe.

@protected
@param nBOP Identificador da opera��o de neg�cio (_BUSINESSOP_BREAK_)
@author Felipe Nathan Welter
@since 20/01/2017
@version P12
@return lValid Valida��o ok.
@obs este m�todo n�o � chamado diretamente.
/*/
//---------------------------------------------------------------------
Method validBusiness(nBOP) Class MNTCounter

	Local lRet     := .T.
    Local aRet     := {.T.,''}
	Local cError   := ''
	Local aArea    := GetArea()
	Local cQuery
    Local cAliasQry

	Local nOp := ::getOperation()

	//variaveis para virada
	Local nNewACUM
    Local nNewVARD

	//001 - valida filtro ativo na ST9
	If !Empty(ST9->(dbFilter()))
		lRet := .F.
		cError := STR0001 //"Filtro ativo na tabela ST9 - pode apresentar inconsist�ncia no repasse a estrutura."
	EndIf

	//Realiza valida��es b�sicas iniciais
	aRet := fBasicVld(Self)
	lRet := aRet[1]
	cError := aRet[2]

	If lRet .And. nBOP == _BUSINESSOP_BREAKCOUNTER_

		If nOp == 3

			::lCount1 := !Empty(::getValue("TP_POSCONT")) .Or. !Empty(::getValue("TP_DTLEITU")) .Or. !Empty(::getValue("TP_HORA"))
			::lCount2 := !Empty(::getValue("TPP_POSCON")) .Or. !Empty(::getValue("TPP_DTLEIT")) .Or. !Empty(::getValue("TPP_HORA"))

			//101 - consiste campos obrigat�rios (contador 1)
			//201 - consiste campos obrigat�rios (contador 2)
			If !::lCount1 .And. !::lCount2
				lRet := .F.
				cError := STR0002 //"Nenhum campo de contador foi repassado para o registro da quebra."
			EndIf

			//-----------------------------------
			//Valida��es sobre equipamento (ST9)
			//-----------------------------------
			//107 - valida se equipamento est� ativo

			dbSelectArea("ST9")
			dbSetOrder(01)
			dbSeek(xFilial("ST9")+ IIf( ::lCount1, ::getValue("TP_CODBEM"), ::getValue("TPP_CODBEM")))

			If lRet .And. ST9->T9_SITBEM <> 'A'
				lRet := .F.
				cError := STR0003 //"Equipamento n�o est� ativo, portanto n�o pode receber quebra."
			EndIf

			//----------------------------------------
			//Valida��es sobre primeiro contador (STP)
			//----------------------------------------
			If lRet .And. ::lCount1

				//102 - valida se equipamento tem contador pr�prio
				If ST9->T9_TEMCONT <> 'S'
					lRet := .F.
					cError := STR0004 //"Equipamento n�o tem contador pr�prio."
				EndIf

				//101 - consiste campos obrigat�rios (contador 1)
				If lRet .And. Empty(::getValue("TP_CODBEM"))
					lRet := .F.
					cError := STR0005 + "TP_CODBEM" + STR0006 //"Campo " //" obrigat�rio."
				ElseIf lRet .And. Empty(::getValue("TP_POSCONT"))
					lRet := .F.
					cError := STR0005 + "TP_POSCONT" + STR0006 //"Campo " //" obrigat�rio."
				ElseIf lRet .And. Empty(::getValue("TP_DTLEITU"))
					lRet := .F.
					cError := STR0005 + "TP_DTLEITU" + STR0006 //"Campo " //" obrigat�rio."
				ElseIf lRet .And. Empty(::getValue("TP_HORA"))
					lRet := .F.
					cError := STR0005 + "TP_HORA" + STR0006 //"Campo " //" obrigat�rio."
				EndIf

				dbSelectArea("STP")
				dbSetOrder(05)
				//103 - consiste a exist�ncia de hist�rico para o contador 1 (ao menos um registro)
				If lRet .And. !dbSeek(xFilial("STP")+::getValue("TP_CODBEM"))
					lRet := .F.
					cError := STR0007 //'Hist�rico do bem sem lan�amentos do contador 1.'

				//104 - verifica se n�o h� registro com mesma data e hora (contador 1)
				ElseIf lRet .And. dbSeek(xFilial("STP") + ::getValue("TP_CODBEM") + DTOS(::getValue("TP_DTLEITU")) + ::getValue("TP_HORA"))
					lRet := .F.
					cError := STR0008 //'Registro de contador 1 j� encontrado para chave filial + bem + dt.leitura + hora.'

				//105 - verifica a exist�ncia de registros posteriores, para garantir que a quebra seja o �ltimo lan�amento (contador 1)
				ElseIf lRet
					cQuery := " SELECT COUNT(TP_CODBEM) AS TOTAL FROM " + RetSQLName("STP") + " STP"
					cQuery += " WHERE STP.TP_FILIAL = " + ValToSql(xFilial("STP"))
					cQuery += "   AND STP.TP_CODBEM = " + ValToSql(::getValue("TP_CODBEM"))
					cQuery += "   AND STP.TP_DTLEITU || STP.TP_HORA > " + ValToSql(DTOS(::getValue("TP_DTLEITU")) + ::getValue("TP_HORA"))
					cQuery += "   AND STP.D_E_L_E_T_ <> '*'"
					cQuery := ChangeQuery(cQuery)
					cAliasQry := GetNextAlias()
					dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
					If (cAliasQry)->TOTAL >= 1
						lRet := .F.
						cError := STR0009 //'H� registros posteriores ao lan�amento da quebra (contador 1).'
					EndIf
					(cAliasQry)->(dbCloseArea())
				EndIf
			EndIf

			//----------------------------------------
			//Valida��es sobre segundo contador (TPE)
			//----------------------------------------
			If lRet .And. ::lCount2
				dbSelectArea("TPE")
				dbSetOrder(01)
				If lRet .And. dbSeek(xFilial("TPE")+::getValue("TPP_CODBEM"))

					//202 - valida se segundo contador est� ativo
					If FieldPos("TPE_SITUAC") > 0
						If TPE->TPE_SITUAC == '2'
							lRet := .F.
							cError := STR0010 //"Equipamento n�o tem contador 2 ativo."
						EndIf
					EndIf

					//201 - consiste campos obrigat�rios (contador 2)
					If lRet .And. Empty(::getValue("TPP_CODBEM"))
						lRet := .F.
						cError := STR0005 + "TPP_CODBEM" + STR0006 //"Campo " //" obrigat�rio."
					ElseIf lRet .And. Empty(::getValue("TPP_POSCON"))
						lRet := .F.
						cError := STR0005 + "TPP_POSCON" + STR0006 //"Campo " //" obrigat�rio."
					ElseIf lRet .And. Empty(::getValue("TPP_DTLEIT"))
						lRet := .F.
						cError := STR0005 + "TPP_DTLEIT" + STR0006 //"Campo " //" obrigat�rio."
					ElseIf lRet .And. Empty(::getValue("TPP_HORA"))
						lRet := .F.
						cError := STR0005 + "TPP_HORA" + STR0006 //"Campo "  //" obrigat�rio."
					EndIf

					dbSelectArea("TPP")
					dbSetOrder(05)
					//203 - consiste a exist�ncia de hist�rico para o contador 2 (ao menos um registro)
					If lRet .And. !dbSeek(xFilial("TPP")+::getValue("TPP_CODBEM"))
						lRet := .F.
						cError := STR0011 //'Hist�rico do bem sem lan�amentos do contador 2.'

					//204 - verifica se n�o h� registro com mesma data e hora (contador 2)
					ElseIf lRet .And. dbSeek(xFilial("TPP") + ::getValue("TPP_CODBEM") + DTOS(::getValue("TPP_DTLEIT")) + ::getValue("TPP_HORA"))
						lRet := .F.
						cError := STR0012 //'Registro de contador 2 j� encontrado para chave filial + bem + dt.leitura + hora.'

					//205 - verifica a exist�ncia de registros posteriores, para garantir que a quebra seja o �ltimo lan�amento (contador 2)
					ElseIf lRet
						cQuery := " SELECT COUNT(TPP_CODBEM) AS TOTAL FROM " + RetSQLName("TPP") + " TPP"
						cQuery += " WHERE TPP.TPP_FILIAL = " + ValToSql(xFilial("TPP"))
						cQuery += "   AND TPP.TPP_CODBEM = " + ValToSql(::getValue("TPP_CODBEM"))
						cQuery += "   AND TPP.TPP_DTLEIT || TPP.TPP_HORA > " + ValToSql(DTOS(::getValue("TPP_DTLEIT")) + ::getValue("TPP_HORA"))
						cQuery += "   AND TPP.D_E_L_E_T_ <> '*'"
						cQuery := ChangeQuery(cQuery)
						cAliasQry := GetNextAlias()
						dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
						If (cAliasQry)->TOTAL >= 1
							lRet := .F.
							cError := STR0013 //'H� registros posteriores ao lan�amento da quebra (contador 2).'
						EndIf
						(cAliasQry)->(dbCloseArea())
					EndIf

				EndIf
			EndIf

		ElseIf nOp == 4

		ElseIf nOp == 5

		EndIf

	ElseIf lRet .And. nBOP == _BUSINESSOP_TURN_

		If nOp == 3

			::lCount1 := !Empty(::getValue("TP_POSCONT")) .Or. !Empty(::getValue("TP_DTLEITU")) .Or. !Empty(::getValue("TP_HORA"))
			::lCount2 := !Empty(::getValue("TPP_POSCON")) .Or. !Empty(::getValue("TPP_DTLEIT")) .Or. !Empty(::getValue("TPP_HORA"))

			//301 - consiste campos obrigat�rios (contador 1)
			//401 - consiste campos obrigat�rios (contador 2)
			If !::lCount1 .And. !::lCount2
				lRet := .F.
				cError := STR0014 //"Nenhum campo de contador foi repassado para o registro da virada."
			EndIf

			//-----------------------------------
			//Valida��es sobre equipamento (ST9)
			//-----------------------------------
			//307 - valida se equipamento est� ativo

			dbSelectArea("ST9")
			dbSetOrder(01)
			dbSeek(xFilial("ST9")+ IIf( ::lCount1, ::getValue("TP_CODBEM"), ::getValue("TPP_CODBEM")))

			If lRet .And. ST9->T9_SITBEM <> 'A'
				lRet := .F.
				cError := STR0015 //"Equipamento n�o est� ativo, portanto n�o pode receber virada."
			EndIf

			//----------------------------------------
			//Valida��es sobre primeiro contador (STP)
			//----------------------------------------
			If lRet .And. ::lCount1

				//302 - valida se equipamento tem contador pr�prio
				If lRet .And. ST9->T9_TEMCONT <> 'S'
					lRet := .F.
					cError := STR0004 //"Equipamento n�o tem contador pr�prio."
				EndIf

				//301 - consiste campos obrigat�rios (contador 1)
				If lRet .And. Empty(::getValue("TP_CODBEM"))
					lRet := .F.
					cError := STR0005 + "TP_CODBEM" + STR0006 //"Campo " //" obrigat�rio."
				ElseIf lRet .And. Empty(::getValue("TP_POSCONT"))
					lRet := .F.
					cError := STR0005 + "TP_POSCONT" + STR0006 //"Campo " //" obrigat�rio."
				ElseIf lRet .And. Empty(::getValue("TP_DTLEITU"))
					lRet := .F.
					cError := STR0005 + "TP_DTLEITU" + STR0006 //"Campo " //" obrigat�rio."
				ElseIf lRet .And. Empty(::getValue("TP_HORA"))
					lRet := .F.
					cError := STR0005 + "TP_HORA" + STR0006 //"Campo " //" obrigat�rio."
				EndIf

				//303 - valida limite do contador 1
				If lRet
					aRet := CHKPOSLIM(::getValue("TP_CODBEM"), ::getValue("TP_POSCONT"), 1,Nil,.F.)
					lRet := aRet[1]
					cError := aRet[2]
				EndIf

				//304 - consist�ncia da virada de contador 1
				If lRet
					aRet := NGCHKVIRAD( ::getValue("TP_CODBEM"), ::getValue("TP_DTLEITU"), ::getValue("TP_POSCONT"), ::getValue("TP_HORA"), 1,Nil,.F.)
					lRet := aRet[1]
					cError := aRet[2]
				EndIf

				//305 - valida��o do limite da varia��o dia, contador 1
				If lRet
					nNewACUM := (ST9->T9_LIMICON - ST9->T9_POSCONT) + ::getValue("TP_POSCONT") + ST9->T9_CONTACU
					nNewVARD := NGVARIADT( ::getValue("TP_CODBEM"), ::getValue("TP_DTLEITU"), 1, nNewACUM, .F., .T.)
					aRet := NGCHKLIMVAR( ST9->T9_CODBEM, ST9->T9_CODFAMI, 1, nNewVARD, .F., .F.)
					lRet := aRet[1]
					cError := aRet[2]
				EndIf

			EndIf

			If lRet .And. ::lCount2

				dbSelectArea("TPE")
				dbSetOrder(01)
				If lRet .And. dbSeek(xFilial("TPE")+::getValue("TPP_CODBEM"))

					//402 - valida se segundo contador est� ativo
					If FieldPos("TPE_SITUAC") > 0
						If TPE->TPE_SITUAC == '2'
							lRet := .F.
							cError := STR0010 //"Equipamento n�o tem contador 2 ativo."
						EndIf
					EndIf

					//401 - consiste campos obrigat�rios (contador 2)
					If lRet .And. Empty(::getValue("TPP_CODBEM"))
						lRet := .F.
						cError := STR0005 + "TPP_CODBEM" + STR0006 //"Campo " //" obrigat�rio."
					ElseIf lRet .And. Empty(::getValue("TPP_POSCON"))
						lRet := .F.
						cError := STR0005 + "TPP_POSCON" + STR0006 //"Campo " //" obrigat�rio."
					ElseIf lRet .And. Empty(::getValue("TPP_DTLEIT"))
						lRet := .F.
						cError := STR0005 + "TPP_DTLEIT" + STR0006 //"Campo " //" obrigat�rio."
					ElseIf lRet .And. Empty(::getValue("TPP_HORA"))
						lRet := .F.
						cError := STR0005 + "TPP_HORA" + STR0006 //"Campo "  //" obrigat�rio."
					EndIf
				EndIf

				//403 - valida limite do contador 2
				If lRet
					aRet := CHKPOSLIM(::getValue("TPP_CODBEM"), ::getValue("TPP_POSCON"), 2, Nil, .F.)
					lRet := aRet[1]
					cError := aRet[2]
				EndIf

				//404 - consist�ncia da virada de contador 2
				If lRet
					aRet := NGCHKVIRAD( ::getValue("TPP_CODBEM"), ::getValue("TPP_DTLEIT"), ::getValue("TPP_POSCON"), ::getValue("TPP_HORA"), 2,Nil,.F.)
					lRet := aRet[1]
					cError := aRet[2]
				EndIf

				//405 - valida��o do limite da varia��o dia, contador 2
				If lRet
					nNewACUM := (TPE->TPE_LIMICO - TPE->TPE_POSCON) + ::getValue("TPP_POSCON") + TPE->TPE_CONTAC
					nNewVARD := NGVARIADT( ::getValue("TPP_CODBEM"), ::getValue("TPP_DTLEIT"), 2, nNewACUM, .F., .T.)
					aRet := NGCHKLIMVAR( ST9->T9_CODBEM, ST9->T9_CODFAMI, 2, nNewVARD, .F., .F.)
					lRet := aRet[1]
					cError := aRet[2]
				EndIf

			EndIf


		ElseIf nOp == 4

		ElseIf nOp == 5

		EndIf


	ElseIf lRet .And. nBOP == _BUSINESSOP_INFORM_

		If nOp == 3

			::lCount1 := !Empty(::getValue("TP_POSCONT")) .Or. !Empty(::getValue("TP_DTLEITU")) .Or. !Empty(::getValue("TP_HORA"))
			::lCount2 := !Empty(::getValue("TPP_POSCON")) .Or. !Empty(::getValue("TPP_DTLEIT")) .Or. !Empty(::getValue("TPP_HORA"))

			//501 - consiste campos obrigat�rios (contador 1)
			//601 - consiste campos obrigat�rios (contador 2)
			If !::lCount1 .And. !::lCount2
				lRet := .F.
				cError := STR0016 //"Nenhum campo de contador foi repassado para o registro de informe."
			EndIf

			//-----------------------------------
			//Valida��es sobre equipamento (ST9)
			//-----------------------------------
			//508 - valida se equipamento est� ativo

			dbSelectArea("ST9")
			dbSetOrder(01)
			dbSeek(xFilial("ST9")+ IIf( ::lCount1, ::getValue("TP_CODBEM"), ::getValue("TPP_CODBEM")))

			If lRet .And. ST9->T9_SITBEM <> 'A'
				lRet := .F.
				cError := STR0017 //"Equipamento n�o est� ativo, portanto n�o pode receber informe."
			EndIf

			//----------------------------------------
			//Valida��es sobre primeiro contador (STP)
			//----------------------------------------
			If lRet .And. ::lCount1

				//502 - valida se equipamento tem contador pr�prio
				If ST9->T9_TEMCONT <> 'S'
					lRet := .F.
					cError := STR0004 //"Equipamento n�o tem contador pr�prio."
				EndIf

				//501 - consiste campos obrigat�rios (contador 1)
				If lRet .And. Empty(::getValue("TP_CODBEM"))
					lRet := .F.
					cError := STR0005 + "TP_CODBEM" + STR0006 //"Campo " //" obrigat�rio."
				ElseIf lRet .And. Empty(::getValue("TP_POSCONT"))
					lRet := .F.
					cError := STR0005 + "TP_POSCONT" + STR0006 //"Campo " //" obrigat�rio."
				ElseIf lRet .And. Empty(::getValue("TP_DTLEITU"))
					lRet := .F.
					cError := STR0005 + "TP_DTLEITU" + STR0006 //"Campo " //" obrigat�rio."
				ElseIf lRet .And. Empty(::getValue("TP_HORA"))
					lRet := .F.
					cError := STR0005 + "TP_HORA" + STR0006 //"Campo " //" obrigat�rio."
				EndIf

				//503 - verifica se data � superior a data atual
				If lRet .And. !NGCPDIAATU(::getValue("TP_DTLEITU"),"<=",.T.,.T.,.F.)
					lRet := .F.
					cError := STR0018 //"Data de leitura deve ser menor ou igual a data base."
				EndIf

				//504 - valida limite do contador 1
				If lRet
					aRet := CHKPOSLIM(::getValue("TP_CODBEM"), ::getValue("TP_POSCONT"), 1,Nil,.F.)
					lRet := aRet[1]
					cError := aRet[2]
				EndIf

				//505 - valida hist�rico de contador 1
				If lRet
					aRet := NGCHKHISTO(::getValue("TP_CODBEM"),::getValue("TP_DTLEITU"),::getValue("TP_POSCONT"),::getValue("TP_HORA"),1,Nil,.F.)
					//TODO ao converter NGCHKHISTO para um m�todo, adequar esse trecho para n�o testar string
                    If !aRet[1] .And. "confirma" $ Lower(aRet[2])
						::addAsk(aRet[2])
                    ElseIf !aRet[1]
                        lRet   := aRet[1]
					    cError := aRet[2]
                    EndIf
                EndIf

				//506 - valida varia��o dia do contador 1
				If lRet
					aRet := NGVALIVARD(::getValue("TP_CODBEM"),::getValue("TP_POSCONT"),::getValue("TP_DTLEITU"),::getValue("TP_HORA"),1,.F.)
					//TODO ao converter NGVALIVARD para um m�todo, adequar esse trecho para n�o testar string
                    If !aRet[1] .And. "tolerancia" $ Lower(aRet[2]) // Indica se o erro � de toler�ncia
                        ::addAsk(STR0024+CRLF+CRLF+aRet[2])
                    ElseIf !aRet[1]
                        lRet   := aRet[1]
					    cError := aRet[2]
                    EndIf
				EndIf
			EndIf

			//----------------------------------------
			//Valida��es sobre segundo contador (TPE)
			//----------------------------------------
			If lRet .And. ::lCount2
				dbSelectArea("TPE")
				dbSetOrder(01)
				If lRet .And. dbSeek(xFilial("TPE")+::getValue("TPP_CODBEM"))

					//602 - valida se segundo contador est� ativo
					If FieldPos("TPE_SITUAC") > 0
						If TPE->TPE_SITUAC == '2'
							lRet := .F.
							cError := STR0010 //"Equipamento n�o tem contador 2 ativo."
						EndIf
					EndIf

					//601 - consiste campos obrigat�rios (contador 2)
					If lRet .And. Empty(::getValue("TPP_CODBEM"))
						lRet := .F.
						cError := STR0005 + "TPP_CODBEM" + STR0006 //"Campo " //" obrigat�rio."
					ElseIf lRet .And. Empty(::getValue("TPP_POSCON"))
						lRet := .F.
						cError := STR0005 + "TPP_POSCON" + STR0006 //"Campo " //" obrigat�rio."
					ElseIf lRet .And. Empty(::getValue("TPP_DTLEIT"))
						lRet := .F.
						cError := STR0005 + "TPP_DTLEIT" + STR0006 //"Campo " //" obrigat�rio."
					ElseIf lRet .And. Empty(::getValue("TPP_HORA"))
						lRet := .F.
						cError := STR0005 + "TPP_HORA" + STR0006 //"Campo "  //" obrigat�rio."
					EndIf

					//603 - verifica se data � superior a data atual
					If lRet .And. !NGCPDIAATU(::getValue("TPP_DTLEIT"),"<=",.T.,.T.,.F.)
						lRet := .F.
						cError := STR0018 //"Data de leitura deve ser menor ou igual a data base."
					EndIf

					//604 - valida limite do contador 2
					If lRet
						aRet := CHKPOSLIM(::getValue("TPP_CODBEM"), ::getValue("TPP_POSCON"), 2, Nil, .F.)
						lRet := aRet[1]
						cError := aRet[2]
					EndIf

					//605 - valida hist�rico de contador 2
					If lRet
						aRet := NGCHKHISTO(::getValue("TPP_CODBEM"),::getValue("TPP_DTLEIT"),::getValue("TPP_POSCON"),::getValue("TPP_HORA"),2,Nil,.F.)
						//TODO ao converter NGCHKHISTO para um m�todo, adequar esse trecho para n�o testar string
                        If !aRet[1] .And. "confirma" $ Lower(aRet[2]) // Verifica como a mensagem vai ser exibida
							::addAsk(aRet[2])
                        ElseIf !aRet[1]
                            lRet   := aRet[1]
                            cError := aRet[2]
                        EndIf
					EndIf

					//606 - valida varia��o dia do contador 2
					If lRet
						aRet := NGVALIVARD(::getValue("TPP_CODBEM"),::getValue("TPP_POSCON"),::getValue("TPP_DTLEIT"),::getValue("TPP_HORA"),2,.F.)
						//TODO ao converter NGVALIVARD para um m�todo, adequar esse trecho para n�o testar string
                        If !aRet[1] .And. "tolerancia" $ Lower(aRet[2]) // Indica se o erro � de toler�ncia
                            ::addAsk(STR0025+CRLF+CRLF+aRet[2])
                        ElseIf !aRet[1]
                            lRet   := aRet[1]
                            cError := aRet[2]
                        EndIf
					EndIf

				EndIf
			EndIf

		ElseIf nOp == 4

		ElseIf nOp == 5

		EndIf

	EndIf

	If !lRet
		::addError(cError)
	EndIf

	RestArea(aArea)

Return lRet


//---------------------------------------------------------------------
/*/{Protheus.doc} fBasicVld
Realiza valida��es b�sicas quanto aos par�metros / campos usados.

@author Felipe Nathan Welter
@since 02/04/2017
@version P12
/*/
//---------------------------------------------------------------------
Static Function fBasicVld(oSTP)

	Local aArea    := GetArea()
	Local aAreaST9 := ST9->(GetArea())
	Local aRet     := {.T.,''}
    Local cHora    := Substr(Time(),1,5)
    Local dDataAt  := dDataBase

	//002 - valida codigo do equipamento com cadastro ST9
	If !Empty(oSTP:getValue("TP_CODBEM"))
		dbSelectArea("ST9")
		dbSetOrder(01)
		If !dbSeek(xFilial("ST9")+oSTP:getValue("TP_CODBEM"))
			aRet := {.F.,STR0019} //"C�digo do equipamento inv�lido."
		EndIf
	EndIf

	//003 - valida se hora contador 1 � v�lida
	If !Empty(oSTP:getValue("TP_HORA"))
		If !NGVALHORA(oSTP:getValue("TP_HORA"),.F.) .Or. oSTP:getValue("TP_HORA") > cHora .And. dDataAt <= oSTP:getValue("TP_DTLEITU")
			aRet := {.F.,STR0020} //"Hora contador 1 inv�lida."
        EndIf
    EndIf

	//004 - valida se hora contador 2 � v�lida
	If !Empty(oSTP:getValue("TPP_HORA"))
		If !NGVALHORA(oSTP:getValue("TPP_HORA"),.F.) .Or. oSTP:getValue("TPP_HORA") > cHora .And. dDataAt <= oSTP:getValue("TPP_DTLEIT")
			aRet := {.F.,STR0021} //"Hora contador 2 inv�lida."
		EndIf
	EndIf

	RestArea(aAreaST9)
	RestArea(aArea)

Return aRet

//---------------------------------------------------------------------
/*/{Protheus.doc} BreakCounter
M�todo para realizar a quebra de contador.

@author Felipe Nathan Welter
@since 20/01/2017
@version P12
/*/
//---------------------------------------------------------------------
Method BreakCounter() Class MNTCounter

	Local aArea	:= GetArea()
	Local lRet	:= .F.
    Local nX

	If ::validBusiness(_BUSINESSOP_BREAKCOUNTER_)
		lRet := .T.
	EndIf

	If lRet

		BeginTran()

		If ::lCount1
			//carrega toda a estrutura que recebe contador
			aSTC := NGESTCSTC(::getValue("TP_CODBEM"))
			aAdd(aSTC,::getValue("TP_CODBEM"))

			//para cada componente da estrutura...
			For nX := 1 To Len(aSTC)

				dbSelectArea("ST9")
				dbSetOrder(01)
				If dbSeek(xFilial("ST9") + aSTC[nX])

					//101 - atualiza informa��es do cadastro de bens
					RecLock("ST9",.F.)
					ST9->T9_POSCONT := ::getValue("TP_POSCONT")
					If ::getValue("TP_DTLEITU") > ST9->T9_DTULTAC
						ST9->T9_DTULTAC := ::getValue("TP_DTLEITU")
					EndIf
					MsUnlock()

					//102 - grava registro de hist�rico na STP
					NGGRAVAHIS(ST9->T9_CODBEM,::getValue("TP_POSCONT"),ST9->T9_VARDIA,::getValue("TP_DTLEITU"),;
							   ST9->T9_CONTACU,ST9->T9_VIRADAS,::getValue("TP_HORA"),1,"Q")

				EndIf
			Next nX
		EndIf

		//--------------------------------------

		If ::lCount2
			//carrega toda a estrutura que recebe contador
			aSTC := NGESTCSTC(::getValue("TPP_CODBEM"))
			aAdd(aSTC,::getValue("TPP_CODBEM"))

			//para cada componente da estrutura...
			For nX := 1 To Len(aSTC)
				dbSelectArea("TPE")
				dbSetOrder(01)
				If dbSeek(xFilial("TPE") + aSTC[nX])

					//201 - atualiza informa��es do segundo contador
					RecLock("TPE",.F.)
					TPE->TPE_POSCON := ::getValue("TPP_POSCON")
					If ::getValue("TPP_DTLEIT") > TPE->TPE_DTULTA
						TPE->TPE_DTULTA := ::getValue("TPP_DTLEIT")
					EndIf
					MsUnlock()

					//202 - grava registro de hist�rico na TPP
					NGGRAVAHIS(TPE->TPE_CODBEM,::getValue("TPP_POSCON"),TPE->TPE_VARDIA,::getValue("TPP_DTLEIT"),;
							   TPE->TPE_CONTAC,TPE->TPE_VIRADA,::getValue("TPP_HORA"),2,"Q")

				EndIf
			Next nX
		EndIf

		EndTran()

	EndIf

	RestArea(aArea)

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} Turn
M�todo para realizar a virada de contador.

@author Felipe Nathan Welter
@since 03/02/2017
@version P12
/*/
//---------------------------------------------------------------------
Method Turn() Class MNTCounter

	Local aArea	:= GetArea()
	Local lRet	:= .F.
    Local nX

	If ::validBusiness(_BUSINESSOP_TURN_)
		lRet := .T.
	EndIf

	If lRet

		BeginTran()

		If ::lCount1
			//301 - grava registro de hist�rico de contador 1 pela NGRETCON
			NGTRETCON( ::getValue("TP_CODBEM"), ::getValue("TP_DTLEITU"), ::getValue("TP_POSCONT"), ::getValue("TP_HORA"), 1, Nil, .T., "V")
		EndIf

		//--------------------------------------

		If ::lCount2
			//401 - grava registro de hist�rico de contador 2 pela NGRETCON
			NGTRETCON( ::getValue("TPP_CODBEM"), ::getValue("TPP_DTLEIT"), ::getValue("TPP_POSCON"), ::getValue("TPP_HORA"), 2, Nil, .T., "V")
		EndIf

		EndTran()

	EndIf

	RestArea(aArea)

Return lRet


//---------------------------------------------------------------------
/*/{Protheus.doc} Inform
M�todo para realizar o informe de contador.

@param aNaoRepas1 array com itens filhos a nao repassar o contador 1 (opcional)
@param aNaoRepas2 array com itens filhos a nao repassar o contador 2 (opcional)
@author Felipe Nathan Welter
@since 02/04/2017
@version P12
/*/
//---------------------------------------------------------------------
Method Inform(aNaoRepas1,aNaoRepas2) Class MNTCounter

	Local aArea := GetArea()
    Local aRet  := {}
    Local lRet  := .F.
    Local nX
    Local i

	If ::validBusiness(_BUSINESSOP_INFORM_)
		lRet := .T.
	EndIf

    If lRet
        aRet := oSTP:GetAskList()
        For i := 1 To Len(aRet)
            If !(lRet := MsgYesNo(aRet[i],STR0023) ) // Deseja Confirmar?
                Exit
            EndIf
        Next i
    EndIf

	If lRet

		If ::lCount1
			//501 - grava registro de hist�rico de contador 1 pela NGTRETCON
			NGTRETCON(::getValue("TP_CODBEM"),::getValue("TP_DTLEITU"),::getValue("TP_POSCONT"),::getValue("TP_HORA"),1,aNaoRepas1,.T.)
		EndIf

		//--------------------------------------

		If ::lCount2
			//601 - grava registro de hist�rico de contador 2 pela NGTRETCON
			NGTRETCON(::getValue("TPP_CODBEM"),::getValue("TPP_DTLEIT"),::getValue("TPP_POSCON"),::getValue("TPP_HORA"),2,aNaoRepas2,.F.)
		EndIf

		EndTran()

	EndIf

	RestArea(aArea)

Return lRet