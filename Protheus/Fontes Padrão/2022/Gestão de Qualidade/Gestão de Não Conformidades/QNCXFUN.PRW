STATIC aPortClie, aPortServ, aDrvServ

STATIC __nTQAAMAT := 0
STATIC __nTRECPMS := 0
STATIC __lQNCFGP			///Para ponto de entrada QNCFGP (Fim da Gravação do Plano no QI5).

#DEFINE INICABEC    Chr(27)+Chr(01)+Chr(01)
#DEFINE FIMCABEC    Chr(27)+Chr(01)+Chr(02)
#DEFINE INIFIELD    Chr(27)+Chr(02)+Chr(01)
#DEFINE FIMFIELD    Chr(27)+Chr(02)+Chr(02)
#DEFINE INIRODA     Chr(27)+Chr(03)+Chr(01)
#DEFINE FIMRODA     Chr(27)+Chr(03)+Chr(02)
#DEFINE INIPARAM    Chr(27)+Chr(04)+Chr(01)
#DEFINE FIMPARAM    Chr(27)+Chr(04)+Chr(02)
#DEFINE INITHINLINE Chr(27)+Chr(05)+Chr(01)
#DEFINE FIMTHINLINE Chr(27)+Chr(05)+Chr(02)
#DEFINE INIFATLINE  Chr(27)+Chr(06)+Chr(01)
#DEFINE FIMFATLINE  Chr(27)+Chr(06)+Chr(02)
#DEFINE INICENTER   Chr(27)+Chr(07)+Chr(01)
#DEFINE FIMCENTER   Chr(27)+Chr(07)+Chr(02)
#DEFINE INIRIGHT    Chr(27)+Chr(09)+Chr(01)
#DEFINE FIMRIGHT    Chr(27)+Chr(09)+Chr(02)
#DEFINE INILEFT     Chr(27)+Chr(11)+Chr(01)
#DEFINE FIMLEFT     Chr(27)+Chr(11)+Chr(02)
#DEFINE INILOGO     Chr(27)+Chr(14)+Chr(01)
#DEFINE FIMLOGO     Chr(27)+Chr(14)+Chr(02)
#DEFINE INIBORDER   Chr(27)+Chr(16)+Chr(01)
#DEFINE FIMBORDER   Chr(27)+Chr(16)+Chr(02)

// Constantes para identificar o tipo de impressão.
#DEFINE IMP_DISCO 1
#DEFINE IMP_SPOOL 2
#DEFINE IMP_PORTA 3
#DEFINE IMP_EMAIL 4

#DEFINE AMB_SERVER 1
#DEFINE AMB_CLIENT 2

#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "QNCXFUN.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "MSOLE.CH"
#include "AP5MAIL.CH"
#INCLUDE "FWMVCDEF.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QNCXFUN  ³ Autor ³ Aldo Marini Junior    ³ Data ³ 27/12/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcoes Genericas do Modulo                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Aldo        ³13/03/01³----- ³ Criacao da Funcao QNCCBOX()              ³±±
±±³Aldo        ³22/08/01³ 9495 ³ Alterado para imprimir cabecalho grafico ³±±
±±³Aldo        ³05/09/01³----- ³ Posicionar Alias correto apos envio email³±±
±±³Eduardo S.  ³06/11/01³----- ³ Criacao da funcao FQNCANEXO() utilizada  ³±±
±±³            ³        ³      ³ para anexar doctos na FNC e PLANO.       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FQNC_USR ³ Autor ³ Aldo Marini Junior    ³ Data ³ 27/12/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ VerIfica pendencia de acordo com o Usuario                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FQNC_USR()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FQNC_USR()

	Local lPendencia := .F.
	Local lRespDem	 := .F.
	Local cApelido  := TRIM(UPPER(cUserName))
	Local aUsrMat   := QNCUSUARIO()
	Local cMatFil   := aUsrMat[2]
	Local cMatCod   := aUsrMat[3]
	Local nNivResp  := GetMv("MV_QNCNIVR")
	Local nPerg     := GetNewPar("MV_QNCPERG",3)// Habilita exibicao da pergunta de pendencias para o usuario

	If ValType(nNivResp) == "C"
		nNivResp := Val(nNivResp)
	Endif

	DbSelectArea("QAA")
	DbSetOrder(6)

	If !DbSeek( cApelido )
		MsgAlert(OemToAnsi(STR0001)) //"Nao foi encontrado no arquivo de senhas o usuario com o apelido cadastrado"
	EndIf
	dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe pendencia das Etapas dos Planos de Acao         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	dbSelectArea("QI5")
	dbSetOrder(2)
	If dbSeek(cMatFil+cMatCod+"S")
		lPendencia := .T.
	Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe pendencia das Fichas de Ocorrencias/Nao-conformidades       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If !lPendencia
		dbSelectArea("QI2")
		dbSetOrder(4)
		If dbSeek(cMatFil+cMatCod)
			While !Eof() .And. cMatFil+cMatCod == QI2->QI2_FILRES+QI2->QI2_MATRES
				//-- Verifica se Status esta em "Registrada ou Em Analise"
				If QI2->QI2_STATUS < "3" .Or. Empty(QI2->QI2_CONREA)
					lPendencia := .T.
					Exit
				Endif
				dbSkip()
			Enddo
		Endif
		dbSetOrder(1)
	Endif

	dbSelectArea("QI5")
	dbSetOrder(3)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe pendencia de Planos de Acao                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	dbSelectArea("QI3")
	dbSetOrder(3)
	If dbSeek(cMatFil+cMatCod)
		While !Eof() .And. cMatFil+cMatCod == QI3->QI3_FILMAT+QI3->QI3_MAT
			If Empty(QI3->QI3_ENCREA)
				lPendencia := .T.
				Exit
			Endif
			dbSkip()
		Enddo
	Endif

	QI5->(dbSetOrder(2))
	QI3->(dbSetOrder(1))

// Verifica se o nivel do Usuario forca a verificacao de usuarios inativos
	If cNivel >= nNivResp
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Seleciona as Acoes Corretivas/Preventivas/Melhoria em Aberto       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		cQuery := "SELECT DISTINCT QI5_FILMAT, QI5_MAT FROM "+RetSqlName("QI5")+" WHERE D_E_L_E_T_ <> '*' AND QI5_STATUS <> '4'"
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QNCSFOL")

		While QNCSFOL->(!EOF())
			dbSelectArea("QAA")
			If QAA->(dbSeek(QNCSFOL->QI5_FILMAT+QNCSFOL->QI5_MAT))
				If ! QA_SitFolh()
					lRespDem := .T.
				Endif
			Endif
			dbSelectArea("QNCSFOL")
			QNCSFOL->(dbskip())
		Enddo

		QNCSFOL->(DbCloseArea())


		If lRespDem
			MsgAlert(OemToAnsi(STR0002),OemToAnsi(STR0003))	// "Existem pendencias para pessoas demitidas. Execute a Transferencia de Pendencias." ### "Pendencias em Aberto"
		EndIf
	EndIf
	QI5->(dbSetOrder(1))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Rotina responsavel por enviar e-mail automaticamente    ³
//³para o usuario "Logado" e os demais usuarios caso tenha ³
//³pendencias.                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If GetMV("MV_QNCAVEM") == "1"
		QNCAVMAIL()
	Endif

//Ponto de Entrada para ser executado antes da abertura da tela de Pendencias
	IF ExistBlock( "QNCINPEN" )
		ExecBlock( "QNCINPEN", .f., .f. )
	Endif

// Se existir pendencias para o usuario, pergunta se quer visualizar
	If lPendencia
		If nPerg == 1 .or. nPerg == 3
			If MsgYesNo(OemToAnsi(STR0004),OemToAnsi(STR0005))     //"Existem Pendˆncias para vocˆ. Deseja Selecion -las agora?" ### "AVISO"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Exibe as Pendencias ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				QNCA050()
			Endif
		Endif
	EndIf

	QI2->(dbSetOrder(1))
	QI3->(dbSetOrder(1))
	QI5->(dbSetOrder(1))

Return

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡…o    ³ FQNCDSX5 ³ Autor ³ Aldo Marini Junior    ³ Data ³ 06/01/00 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³ Programa generico para alteracao                           ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Sintaxe   ³ FQNCDSX5(ExpC1,ExpC2)                                      ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ ExpC1 = Codigo da Tabela - SX5                             ³±±
	±±³          ³ ExpC2 = Codigo a ser pesquisado                            ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso      ³ Generico                                                   ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FQNCDSX5(cTabela,cCodigo)
	Local cDesc:=Space(30)

	If cTabela = "QD"
		cDesc := FQNCDTPACAO(cCodigo)
	Else
		If SX5->(dbSeek(xFilial("SX5")+cTabela+cCodigo))
			cDesc := X5Descri()
		Endif
	Endif

Return cDesc

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡…o    ³ FQNCNTAB ³ Autor ³ Aldo Marini Junior    ³ Data ³ 10/01/00 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³ Programa generico para busca no QI0 - Tabela               ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Sintaxe   ³ FQNCNTAB(ExpC1,ExpC2)                                      ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ ExpC1 = Tipo (1-Causa/2-Efeito/3-Origem/4-Categoria Prob   ³±±
	±±³          ³ ExpC2 = Codigo a ser pesquisado                            ³±±
	±±³          ³ ExpC3 = Tipo de Retorno .F.-Descricao .T.-Validacao        ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso      ³ Generico                                                   ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FQNCNTAB(cTab,cCodigo,lValid)
	Local cDesc := Space(1)
	Local lRet  := .F.
	lValid := If(lValid==Nil,.F.,lValid)

	If QI0->(dbSeek(xFilial("QI0")+cTab+cCodigo))
		cDesc := QI0->QI0_DESC
		lRet := .T.
	Endif

	If Empty(cCodigo)
		lRet := .T.
	EndIF

	If lValid .And. !lRet
		Help(" ",1,"QNCNEXITAB")
	Endif

Return(IF(lValid,lRet,cDesc))

/*/
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡…o    ³QNC_GRAVCPS ³ Autor ³ Aldo Marini Junior  ³ Data ³ 14/01/00 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³ Programa de Gravacao dos Campos do aHeader                 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Sintaxe   ³ QNC_GRAVCPS(N,aArray)                                      ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ ExpN1 = Numero atual do registro (linha do array)          ³±±
	±±³          ³ ExpA1 = Array a ser gravado                                ³±±
	±±³          ³ ExpA2 = Array com o cabecalho dos campos                   ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso      ³ GENERICO                                                   ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QNC_GRAVCPS(N,aArray,aHeader)
	Local nF, nItem, cCampo
	Local cAlias:=Alias()
	Local cArqCpo

	For nF := 1 TO FCOUNT()
		cCampo:= UPPER(ALLTRIM(FieldName(nF)))
		nItem := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == cCampo })
		If nItem > 0
			cArqCpo := cAlias+"->"+cCampo
			&( cArqCpo ) := aArray[N,nItem]
		EndIf
	Next

Return


/*/
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡…o    ³FQNCCHKREV  ³ Autor ³ Aldo Marini Junior  ³ Data ³ 24/01/00 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³ Programa de Verificacao de Revisao                         ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Sintaxe   ³ FQNCCHKREV(cAlias,cChave)                                  ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ ExpC1 = Alias a ser pesquisado                             ³±±
	±±³          ³ ExpC2 = Codigo da chave a ser pesquisada                   ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso      ³ GENERICO                                                   ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FQNCCHKREV(cAlias,cChave)
	Local lRet := .T.
	Local cAliasOld:= Alias()
	Local nOrdemOld:= IndexOrd()

	dbSelectArea(cAlias)
	dbSetOrder(1)
	If dbSeek(cFilial+cChave)
		Help(" ",1,"QNCEXIREV")
		lRet := .F.
	Endif

	dbSelectArea(cAliasOld)
	dbSetOrder(nOrdemOld)

Return lRet

/*/
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡…o    ³ FQNCCHKCC  ³ Autor ³ Aldo Marini Junior  ³ Data ³ 26/01/00 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³ Valida o Departamento                                      ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Sintaxe   ³ FQNCCHKCC(cFilDest,cCodigo)                                ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ ExpC1 = Filial do Departamento                             ³±±
	±±³          ³ ExpC2 = Codigo da chave a ser pesquisada                   ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso      ³ GENERICO                                                   ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FQNCCHKCC(cFilDest,cCodigo)

	Local cFilQAD := xFilial("QAD")
	Local lRet    := .T.

	If FWModeAccess("QAD") == 'E'
		If READVAR() $ "M->QI2_ORIDEP"
			cFilQAD := M->QI2_FILORI
		ElseIf READVAR() $ "M->QI2_DESDEP"
			cFilQAD := M->QI2_FILDEP
		Endif

		QAD->(dbSetOrder(1))
		If QAD->(dbSeek(cFilQAD+cCodigo))
			If QAD->QAD_STATUS == "2"
				lRet := .F.
				//STR0216 - Departamento inativo.
				//STR0217 - Utilize outro departamento ou altere o cadastro do departamento ativando-o.
				Help( ,  , ProcName() + "-"+ cValToChar(ProcLine()), ,  STR0216, 1, 0, , , , , , {STR0217})
			EndIf
		Else
			Help(" ",1,"QNCNEXICC")
			lRet := .F.
		Endif
	Else

		BeginSql Alias "TMPQAD"

		SELECT QAD_STATUS
		FROM %Table:QAD% QAD
		WHERE QAD.QAD_CUSTO =  %Exp:cCodigo% AND
			QAD.%NotDel%
		EndSql

		If TMPQAD->(Eof())
			lRet := .F.
		ElseIf TMPQAD->QAD_STATUS == "2"
			lRet := .F.
			//STR0216 - Departamento inativo.
			//STR0217 - Utilize outro departamento ou altere o cadastro do departamento ativando-o.
			Help( ,  , ProcName() + "-"+ cValToChar(ProcLine()), ,  STR0216, 1, 0, , , , , , {STR0217})
		Endif

		TMPQAD->(dbCloseArea())

	Endif

Return lRet

/*/{Protheus.doc} RetFilQAD
Retorna o filtro para a consulta QADQNC conforme compartilhamento da QAD
@type  Function
@author Rafael Kleestadt da Cruz
@since 09/11/2020
@version 1.0
@param param_name, param_type, param_descr
@return lRet, logical, true or fslse
@example
(examples)
@see (links_or_references)
/*/
Function RetFilQAD()
Local uRet := "@#"

IF FWModeAccess("QAD") == 'E'
	IF READVAR() $ "M->QI2_ORIDEP"
		uRet := "@#QAD->QAD_FILIAL == M->QI2_FILORI .AND. QAD->QAD_STATUS == '1'@#"
	ELSEIF READVAR() $ "M->QI2_DESDEP"
		uRet := "@#QAD->QAD_FILIAL == M->QI2_FILDEP .AND. QAD->QAD_STATUS == '1'@#"
	ENDIF
ELSE
	uRet := "@#QAD->QAD_STATUS == '1'@#"
ENDIF

Return(uRet)

/*/
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡…o    ³ GETQNCSEQ  ³ Autor ³ Aldo Marini Junior  ³ Data ³ 26/01/00 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³ Gera numero sequencial por ano e arquivo                   ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Sintaxe   ³ GETQNCSEQ(cAlias,cCampo,cChave,lVolta)                     ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
	±±³          ³ ExpC2 = Campo do codigo a ser gerado                       ³±±
	±±³          ³ ExpC3 = Chave do codigo a ser pesquisado                   ³±±
	±±³          ³ ExpL1 = Valor logico definindo retorno do codigo           ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso      ³ GENERICO                                                   ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GETQNCSEQ(cAlias,cCampo,cChave,lVolta,nOpc,aQN)

	Local cAliasOld := Alias()
	Local nTam 		:= TamSX3(cCampo)[1]-4
	Local cCodigo	:= StrZero(0,nTam)
	Local cAno		:= Str(Year(dDataBase),4)
	Local nTrys 	:= 0
	Local lFinalG	:= .F.
	Local lVoltaSeq := .F.
	Local cCodIni	:= "000001"
	Local lNetErr   := .T.
	Local nTimes    := 0
	Local cAnAtu	:= ""

	Default cChave  := "000001"+Str(Year(dDataBase),4)
	Default nOpc    := 3
	Default aQN     := {}

//Tratamento da integracao entre CALL CENTER X QNC X PMS 
	If Len(cChave) == 10 .and. nTam >= 11
		cChave := "00000000001"+Str(Year(dDataBase),4)
	Endif
	IF GetMV( "MV_QNCVSEQ",.F., "S" ) == "S"
		lVoltaSeq := .T.
	Endif

	lVolta := If(lVolta == NIL, .F. , lVolta)

	If nOpc == 5 .And. !lVoltaSeq
		lVolta := .F.
	Endif

	If nModulo == 22 .and. Alltrim(FunName())<>"QMTA140" //Modulo Metrologia
		nTam := TamSX3(cCampo)[1]-5
		cAnAtu:= SubStr(cChave,9,4)
		cCodigo	:= StrZero(0,nTam)
	Else
		If TamSX3("QI2_FNC")[1] == 10
			cAnAtu:= SubStr(cChave,7,4)
		Else
			cAnAtu:= SubStr(cChave,12,4)
		Endif
	Endif
	If lVolta
		dbSelectArea("QIA")

		If !File("QNSXE" + GetDBExtension()) .Or. !File( "QNSXF" + GetDBExtension()) .Or. ;
				!QNCSEQCHK(PADR(xFilial(cAlias)+x2path(cAlias),50),cAlias)

			If !dbSeek(xFilial("QIA")+cAlias+cAnAtu+Left(cChave,nTam)+Trim(xFilial(cAlias)))
				RecLock("QIA",.T.)
				QIA->QIA_FILIAL	:= xFilial("QIA")
				QIA->QIA_ALIAS	:= cAlias
				QIA->QIA_ANO	:= cAnAtu
				QIA->QIA_CODIGO	:= Left(cChave,nTam)+Trim(xFilial(cAlias))
				MsUnLock()
			Endif
		Else
			If Select("QNSXF") <= 0
				USE QNSXF ALIAS QNSXF SHARED NEW VIA "TOPCONN"
				If NetERR()
					Final("Probs.Abertura QNSXF")
				EndIf
			Endif

			lNetErr := .T.
			While lNetErr
				DbSelectArea("QNSXF")
				dbAppEnd(.f.)
				lNetErr := NetErr()
				nTimes ++
				If nTimes > 20
					If NetCancel()
						Final( oemtoansi("PROBS.GRV.QNSXF") )
					Else
						nTimes := 0
					EndIf
				EndIf
				IF lNetErr
					Inkey( nTimes/24 )
				EndIf
			Enddo
			DbSelectArea("QNSXF")
			MSRLock(Recno())
			Replace QF_FILIAL  with PADR(xFilial(cAlias)+x2path(cAlias),50)
			Replace QF_ALIAS   with cAlias
			Replace QF_CHAVE   with cAnAtu
			Replace QF_TAMANHO with nTam
			Replace QF_NUMERO  with Left(cChave,nTam)
			DbCommit()
			AADD(aQN,{QNSXF->(Recno()),"E"})

			dbSelectArea("QIA")

		Endif

	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Nao gera caso seja "EXCLUSAO" ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nOpc == 5
			Return " "
		Endif
		dbSelectArea("QA4")
		If 	 FWModeAccess(cAlias) == "E" .And. dbSeek(xFilial("QA4")+"QNC_"+cAlias+cAno) .And.; //!Empty(xFilial(cAlias))
			Trim(QA4->QA4_CODTAB) == "QNC_"+cAlias+cAno
			cCodIni := QA4->QA4_CHAVE
			RecLock("QA4",.F.)
			DbDelete()
			MsUnLock()

			If !dbSeek(xFilial("QA4")+"QNC_"+cAlias+cAno+Trim(xFilial(cAlias)))
				RecLock("QA4",.T.)
				QA4->QA4_FILIAL	:= xFilial("QA4")
				QA4->QA4_CODTAB	:= "QNC_"+cAlias+cAno+Trim(xFilial(cAlias))
				QA4->QA4_CHAVE	:= cCodIni
				MsUnlock()
				dbCommit()
				cCodigo	:= StrZero(Val(cCodIni),nTam)
			Endif

		Endif

		If !dbSeek(xFilial("QA4")+"QNC_"+cAlias+cAno+Trim(xFilial(cAlias)))
			RecLock("QA4",.T.)
			QA4->QA4_FILIAL	:= xFilial("QA4")
			QA4->QA4_CODTAB	:= "QNC_"+cAlias+cAno+Trim(xFilial(cAlias))
			QA4->QA4_CHAVE	:= cCodIni
			MsUnlock()
			dbCommit()
			cCodigo	:= StrZero(Val(cCodIni),nTam)
		Else
			nTrys := 0
			lFinalG := .F.
			dbSelectArea("QIA")
			If dbSeek(xFilial("QIA")+cAlias+cAno)
				While !Eof() .And. QIA->QIA_FILIAL+QIA->QIA_ALIAS+QIA->QIA_ANO == xFilial("QIA")+cAlias+cAno
					If deleted()
						dbSkip()
						Loop
					Endif
					If SubStr(QIA->QIA_CODIGO,nTam+1,2)==Space(FWSizeFilial()) .Or. ; //Space(2)
						SubStr(QIA->QIA_CODIGO,nTam+1,2)==Trim(xFilial(cAlias)) //revisar Gestao Corporativa...
						cCodigo	:= SubStr(QIA->QIA_CODIGO,1,nTam)
						If RecLock("QIA",.F.)
							dbDelete()
							MsUnLock()
							dbCommit()
							lFinalG	:= .T.
							Exit
						Endif
					Endif
					dbSkip()
				Enddo

				If !lFinalG
					dbSelectArea("QA4")
					RecLock("QA4",.F.)
					cCodigo	:= StrZero(Val(QA4->QA4_CHAVE)+1,nTam)
					QA4->QA4_CHAVE	:= cCodigo
					MsUnLock()
					dbCommit()
				Endif
			Else
				dbSelectArea("QA4")
				RecLock("QA4",.F.)
				cCodigo	:= StrZero(Val(QA4->QA4_CHAVE)+1,nTam)
				QA4->QA4_CHAVE	:= cCodigo
				MsUnlock()
				dbCommit()
			Endif
		Endif
	Endif

	dbSelectArea(cAliasOld)

Return Trim(cCodigo)+cAno

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡…o    ³FQNCDESCLI ³ Autor ³ Aldo Marini Junior   ³ Data ³ 29/01/00 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³ Programa generico para Buscar Nome/Nome Reduzido Cliente   ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Sintaxe   ³ FQNCDESCLI(cCodigo,cLoja,cTipo)                            ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ ExpC1 = Codigo do Cliente a ser pesquisado                 ³±±
	±±³          ³ ExpC2 = Codigo da Loja a ser pesquisada                    ³±±
	±±³          ³ ExpC3 = Tipo (1-Nome 2-Nome Reduzido)                      ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso      ³ Generico                                                   ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FQNCDESCLI(cCodigo,cLoja,cTipo)
	Local cDesc := Space(40)

	If SA1->(dbSeek(xFilial("SA1")+cCodigo+cLoja))
		If cTipo == "1"
			cDesc := SA1->A1_NOME
		Else
			cDesc := SA1->A1_NREDUZ
		Endif
	Endif

Return cDesc

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡…o    ³FQNCDESFOR ³ Autor ³ Aldo Marini Junior   ³ Data ³ 29/01/00 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³ Programa generico para Buscar Nome/Nome Reduzido Fornecedor³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Sintaxe   ³ FQNCDESCLI(cCodigo,cLoja,cTipo)                            ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ ExpC1 = Codigo do Fornecedor a ser pesquisado              ³±±
	±±³          ³ ExpC2 = Codigo da Loja a ser pesquisada                    ³±±
	±±³          ³ ExpC3 = Tipo (1-Nome 2-Nome Reduzido)                      ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso      ³ Generico                                                   ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FQNCDESFOR(cCodigo,cLoja,cTipo)
	Local cDesc := Space(40)

	If SA2->(dbSeek(xFilial("SA2")+cCodigo+cLoja))
		If cTipo == "1"
			cDesc := SA2->A2_NOME
		Else
			cDesc := SA2->A2_NREDUZ
		Endif
	Endif

Return cDesc

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡…o    ³FQNCDESPRO ³ Autor ³ Aldo Marini Junior   ³ Data ³ 29/01/00 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³ Programa generico para Buscar Descricao do Produto         ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Sintaxe   ³ FQNCDESPRO(cCodigo)                                        ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ ExpC1 = Codigo do Produto a ser pesquisado                 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso      ³ Generico                                                   ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FQNCDESPRO(cCodigo)
	Local cDesc := Space(30)

	If SB1->(dbSeek(xFilial("SB1")+cCodigo))
		cDesc := SB1->B1_DESC
	Endif

Return cDesc

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡…o    ³FQNCDESDOC ³ Autor ³ Aldo Marini Junior   ³ Data ³ 29/01/00 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³ Programa generico para Buscar Titulo do Documento          ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Sintaxe   ³ FQNCDESDOC(cCodigo)                                        ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ ExpC1 = Codigo do Documento+Revisao a ser pesquisado       ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso      ³ Generico                                                   ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FQNCDESDOC(cCodigo)
	Local cDesc := Space(50)

	If QDH->(dbSeek(xFilial("QDH")+cCodigo))
		cDesc := QDH->QDH_TITULO
	Endif

Return cDesc

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡…o    ³FQNCDrive  ³ Autor ³ Aldo Marini Junior   ³ Data ³ 29/01/00 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³ Programa generico para Selecionar diretorio do Documento   ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Sintaxe   ³ FQNCDrive(nOpc)                                            ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ Expn1 - Opcao do Cadastro                                  ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso      ³ Generico                                                   ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FQNCDrive(nOpc,cFileTrm,cArqAnexo)

	Local cFile		:= ""
	Local cFileTmp := ""
	Local nTrm     := 0
	Local cQPathFNC:= QA_TRABAR(Alltrim(GetMv("MV_QNCPDOC")))
	Local aQPath   := QDOPATH()
	Local cQPathTrm:= aQPath[3]
	Local i			:= 0
	Local nPos		:= 0
	Local cBarSrv	:=IIF(ISSRVUNIX(),"/","\")   //Checa se o Server e Linux
	Local lRet   	:= .F.

	If !Right( cQPathFNC,1 ) == cBarSrv
		cQPathFNC := cQPathFNC + cBarSrv
	Endif

	IF Empty(cFileTrm)

		If nOpc == 2	// Visualizar - Opcao Cadastro
			MsgAlert(OemToAnsi(STR0006),OemToAnsi(STR0007))	     		//"Nao existe nenhum documento anexo a esta Ocorrencias/Nao-conformidade." ### "Aten‡ao"
		Else
			cFile := Trim(cGetFile(PADR(OemToAnsi(STR0008),27)+"|*.DOC|"+;		// "Documentos Anexos(*.Doc)"
			PADR(OemToAnsi(STR0009),27)+"|*.TXT|"+;    // "Arquivos Texto(*.Txt)"
			PADR(OemToAnsi(STR0010),27)+"|*.*|" ,;     // "Todos Arquivos(*.*)"
			OemToAnsi(STR0011),0,,.T.,;			// "Selecione Diretorio e Arquivo"
			49))

			If !Empty(cFile)

				cQPathFNC 	:= StrTran(cQPathFNC,"SERVIDOR","")

				If Lower(Right(cFile, 4))=="jpeg"
					cArqAnexo := Left(cArqAnexo, Len(cArqAnexo) - 3) + "jpg"		// Uso a extensao selecionada
				ElseIf Lower(Right(cFile, 4))=="html"
					cArqAnexo := Left(cArqAnexo, Len(cArqAnexo) - 3) + "htm"		// Uso a extensao selecionada
				Else
					nPos:=0
					For i:=Len(cFile) To 1 Step -1
						IF Subs(cFile,i,1)=="."
							nPos:=i
							Exit
						Endif
					Next
					cArqAnexo	:= Left(cArqAnexo, Len(cArqAnexo) - 3) + Subs(cFile,nPos+1)		// Uso a extensao selecionada
				Endif

				If AT(":",cFile) > 0
					lRet := __CopyFile(cFile,cQPathTrm + cArqAnexo)
					If !File(cQPathTrm + cArqAnexo)
						Help(" ",1,"QNAOCOPIOU")
						Return
					Endif
				Else
					If !CpyS2T(cFile,cQPathTrm,.T.)
						Help(" ",1,"QNAOCOPIOU")
						Return
					Endif

					cFileTmp := ""
					For nTrm:= Len(cFile) to 1 STEP -1
						If SubStr(cFile,nTrm,1) == "\"
							Exit
						Endif
						cFileTmp := SubStr(cFile,nTrm,1)+cFileTmp
					Next

					lRet := __CopyFile(cQPathTrm+cFileTmp,cQPathTrm + cArqAnexo)
					If File(cQPathTrm+cFileTmp)
						FErase(cQPathTrm+cFileTmp)
					Endif
				Endif

				cFileTrm := cArqAnexo

				If File(cQPathTrm+cFileTrm).And. ;
						MsgYesNo(OemToAnsi(STR0012),OemToAnsi(STR0013))	     	//"Deseja Visualizar o Documento Agora?" ### "Aten‡ao"
					QA_OPENARQ(cQPathTrm+cFileTrm)//Programa para abrir arquivo com qualquer extensao. - QAXFUNA.PRX
				Endif
			Endif
		Endif
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Visualiza Documento Anexo. 			   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//	If !File(cQPathTrm+AllTrim(cFileTrm))		//		Comentado para sempre copiar a versão do server para o terminal para garantir
		//      a visualização do documento atualizado.
		If !CpyS2T(cQPathFNC+AllTrim(cFileTrm),cQPathTrm,.T.)
			If !File(cQPathTrm+AllTrim(cFileTrm))
				Help(" ",1,"QNAOCOPIOU")
				Return
			Endif
		Endif
//	EndIf     

		If File(cQPathTrm+cFileTrm)
			QA_OPENARQ(cQPathTrm+cFileTrm)//Programa para abrir arquivo com qualquer extensao. - QAXFUNA.PRX
		Endif
	Endif

Return(!Empty(cFileTrm))

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡…o    ³FQNCDTPACAO³ Autor ³ Aldo Marini Junior   ³ Data ³ 01/02/00 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³ Programa generico para Visualizar o Documento              ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Sintaxe   ³ FQNCDTPACAO(cCodigo)                                       ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ ExpC1 - Codigo do Tipo de Acao a ser pesquisado            ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso      ³ Generico                                                   ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FQNCDTPACAO(cCodigo)
	Local cDesc := Space(30)
	Local nPos  := 0
	Default cCodigo := ""

	If Type('aHeader') == "A" .AND. Type('aCols[1][1]') == "C" .AND. Type('n') == "N"
		If Len(aCols[1]) == Len(aCols[Len(aCols)])
			nPos := Ascan(aHeader,{|x| AllTrim(x[2]) == "QIE_PEND"})
			If aCols[Len(aCols)][nPos] <> NIL
				cCodigo := aCols[Len(aCols)][nPos]
			EndIf
		Else
			cCodigo := '' //Quando é linha nova, para não carregar nenhum valor
		EndIf
	EndIf

	If !Empty(cCodigo)
		If QID->(dbSeek(xFilial("QID")+cCodigo))
			cDesc := QID->QID_DESCTP
		Endif
	Endif

Return cDesc


/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡…o    ³ ProcQNC   ³ Autor ³ Aldo Marini Junior   ³ Data ³ 16/02/00 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³ Programa generico para Demonstrar tela de Processamento    ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Sintaxe   ³ ProcQNC(bAction, cTitle, cMsg)              				  ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ ExpB1 - Code Block da acao a ser executa                   ³±±
	±±³          ³ ExpC1 - Titulo que sera mostrado na tela                   ³±±
	±±³          ³ ExpC2 - Mensagem que sera mostrada na tela                 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso      ³ Generico                                                   ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ProcQNC( bAction, cTitle ,cMsg )
	Local oDlg
	Local lEnd  := .f.
	Local nVal  := 0

	Private oMeter, oBmp, oNome
	Private nAtual  := 0
	Default bAction := { || Nil }
	Default cMsg    := OemToAnsi( STR0017 ) // "Processando"
	Default cTitle  := OemToAnsi( STR0018 ) // "Aguarde..."
	DEFINE MSDIALOG oDlg FROM 000,000 TO 095,310 TITLE OemToAnsi( cTitle ) STYLE DS_MODALFRAME STATUS PIXEL

	@003,003 BITMAP oBmp   RESOURCE "CLOCK01" NOBORDER          SIZE 010,010 OF oDlg PIXEL
	@005,020 SAY    oNome  VAR OemToAnsi(cMsg) FONT oDlg:oFont SIZE 140,010 OF oDlg PIXEL
	@015,003 METER  oMeter VAR nVal  TOTAL 10 					 SIZE 150,010 OF oDlg PIXEL

	DEFINE SBUTTON FROM 31.5,127.5 TYPE 2 ACTION (lEnd:=.T.,oDlg:End()) ENABLE OF oDlg

	oDlg:bStart:={||Eval(bAction,@lEnd ),lEnd :=.T.,oDlg:End()}

	ACTIVATE DIALOG oDlg VALID lEnd CENTERED

Return Nil

Function RegProcQNC( nTotal )
	oMeter:nTotal := nTotal
	nAtual        := 0
Return nil

Function IncProcQNC( cMsg )
	oMeter:Set(++nAtual)
	If cMsg <> NIL
		oNome:SetText( OemToAnsi( cMsg ) )
	Endif
	SysRefresh()
Return .T.

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡…o	 ³ fStatus  ³ Autor ³ Aldo Marini Junior    ³ Data ³ 09/03/00 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³Selecionar os Status das FNC e/ou Planos de Acao            ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Sintaxe	 ³ fStatus()                                                  ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso		 ³ Generico                                                   ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function fStatus(nCad)
	Local oDlg, nFor,  oListbox,  nOpca
	Local MvPar		:= &(Alltrim(ReadVar()))		 // Carrega Nome da Variavel do Get em Questao
	Local mvRet		:= Alltrim(ReadVar())			 // Iguala Nome da Variavel ao Nome variavel de Retorno
	Local aOpcoes	:= {OemToAnsi(STR0031),OemToAnsi(STR0032),OemToAnsi(STR0033),OemToAnsi(STR0034),OemToAnsi(STR0035)}	// "Registrada"###"Em Analise"###"Procede"###"Nao Procede"###"Cancelada"
	Local oOk		:= LoadBitmap( GetResources(), "LBOK" )
	Local oNo		:= LoadBitmap( GetResources(), "LBNO" )
	Local nAuxFor	:= 1
	Local cTitulo	:= OemToAnsi(STR0036)  //"Status de Pendencia"
	Local cOpcoes	:= "12345"
	Local nTam		:= 1
	Local cRet 		:= MvPar
	Local aListBox	:= {}
	Local cVarQ

	For nFor := 1 to Len(aOpcoes)
		AADD(aListBox,{.f.,aOpcoes[nFor]})
		IF Subs(cOpcoes,nAuxFor,nTam) $ MvPar
			aListBox[Len(aListBox),1] := .t.
		Endif
		nAuxFor := (nFor * nTam) + 1
	Next
	nOpca := 0

	DEFINE MSDIALOG oDlg FROM 5,5 TO 16,50 TITLE OemToAnsi(STR0037)	// "Escolha Padrao"

	@ .4,2 LISTBOX oListBox VAR cVarQ Fields HEADER "",OemToAnsi(cTitulo)  SIZE 150,61 ;
		ON DBLCLICK (aListBox[oListBox:nAt,1] := !aListBox[oListBox:nAt,1],oListBox:Refresh()) NOSCROLL

	oListBox:SetArray(aListBox)
	oListBox:bLine := { || {if(aListBox[oListBox:nAt,1],oOk,oNo),aListBox[oListBox:nAt,2]}}

	DEFINE SBUTTON FROM 066,112   TYPE 1 ACTION (nOpca := 1,oDlg:End()) ENABLE OF oDlg
	DEFINE SBUTTON FROM 066,139.1 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg

	ACTIVATE MSDIALOG oDlg CENTERED

	nAuxFor := 1
	If nOpca == 1
		cRet := ""
		For nFor := 1 TO Len(aListBox)
			cRet += If(aListBox[nFor,1],Subs(cOpcoes,nAuxFor,nTam),Replicate("*",nTam))
			nAuxFor := (nFor * nTam) + 1
		Next
	Endif

	&MvRet := cRet
	DeleteObject(oOk)
	DeleteObject(oNo)

Return(.T.)

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡…o    ³FQNCCHKDIS³ Autor ³ Aldo Marini Junior    ³ Data ³ 23/03/00 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³ Programa generico para busca no QI1 - Disposicao           ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Sintaxe   ³ FQNCCHKDIS(ExpC1,ExpC2)                                    ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ ExpC1 = Codigo a ser pesquisado                            ³±±
	±±³          ³ ExpC2 = Tipo de Retorno .F.-Descricao .T.-Validacao        ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso      ³ Generico                                                   ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FQNCCHKDIS(cCodigo,lValid)
	Local cDesc := Space(1)
	Local lRet  := .F.
	lValid := If(lValid==Nil,.F.,lValid)

	If QI1->(dbSeek(xFilial("QI1")+cCodigo))
		cDesc := QI1->QI1_DESC
		lRet := .T.
	Endif

	If Empty(cCodigo)
		lRet := .T.
	Endif

	If lValid .And. !lRet
		Help(" ",1,"QNCNEXITAB")
	Endif

Return(IF(lValid,lRet,cDesc))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNCAUTUSR ³ Autor ³ Aldo Marini Junior    ³ Data ³ 08.08.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida se o Usuario recebera Pendencias de FNC e/ou Acoes  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNCAUTUSR(ExpC1,ExpC2)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da Filial                                   ³±±
±±³          ³ ExpC2 = Codigo do Funcionario/Usuario                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QNCAUTUSR(cFilBsc,cMatBsc)
	Local lRet			:= .F.
	Local nPosFilMat	:= 0
	Local cFilMat		:= ""
	Local lFilAcols	:= .F.

	If Empty(cFilBsc) .And. Alltrim(FunName()) == 'QADA150'
		nPosFilMat := Ascan(aHeader,{|x| AllTrim(x[2]) == "QUM_FILMAT"})
		If nPosFilMat > 0
			cFilMat 	:= aCols[n,nPosFilMat]
			lFilAcols	:= .T.
		Endif
	Endif

	DbSelectArea("QAA")// Verifica se o arquivo QAA est  aberto
	QAA->(dbSetOrder(1))
	IF QAA->(dbSeek( Iif(lFilAcols,cFilMat,cFilBsc) + cMatBsc )) .And. QAA->QAA_RECFNC == "S"
		lRet := .T.
	Else
		Help(" ",1,"QNCNAUTUSR")  // Usuario nao recebe pendencias de Ficha de Ocorrencias/Nao-conformidades
	EndIf                         // e Plano de Acao

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNCGERA   ³ Autor ³ Aldo Marini Junior    ³ Data ³ 10.11.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao generica para geracao de FNC automatica.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNCGERA(nOpc,aQI2Campos)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Numero da Opcao(1-Inclusao/2-Exclusao)             ³±±
±±³          ³ ExpA1 = Array contedo os campos a serem gravados           ³±±
±±³          ³ ExpN2 = Habilidade                                         ³±±
±±³          ³ ExpN3 = Numero do Chamado                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/*
Funcao feita correndo para JNJ,10/11
Incluir os Alias QIA,Q4A,QI2,QAA,QAD,

nOpc = 1-Inclusao,2-Exclusao
aQI2Campos -1a.Coluna = Campos a serem preenchidos
				2a.Coluna = Conteudo dos campos
Retorno  1a.Coluna = Filial do FNC
			2a.Coluna = Codigo Sequencial da FNC
			3a.Coluna = Revisao da FNC
*/
Function QNCGERA(nOpc,aQI2Campos,cHabilidade,cChamado,lRev)
	Local cAlias	:= Alias()
	Local nOrdem	:= IndexOrd()
	Local nI		:= 0
	Local bCampo	:= { |nCPO| Field( nCPO ) }
	Local lInit		:= .F.
	Local aRetQI2	:= {}
	Local cOriFil	:= ParamXFil(GetMV("MV_QNCFORI",.F.,cFilAnt))
	Local cOriDep	:= AllTrim(GetMV("MV_QNCDORI",.F.,"1234567890123"))
	Local cDesFil	:= ParamXFil(GetMV("MV_QNCFDES",.F.,cFilAnt))
	Local cDesDep	:= AllTrim(GetMV("MV_QNCDDES",.F.,"1234567890123"))
	Local cResFil	:= ParamXFil(GetMV("MV_QNCFRES",.F.,cFilAnt))
	Local cResMat	:= AllTrim(GetMV("MV_QNCMRES",.F.,"1234567890"))
	Local cDigFil	:= ParamXFil(GetMV("MV_QNCFDIG",.F.,cFilAnt))
	Local cDigMat	:= AllTrim(GetMV("MV_QNCMDIG",.F.,"1234567890"))
	Local cDigDep	:= AllTrim(GetMV("MV_QNCDDIG",.F.,"1234567890123"))
	Local cMail		:= ""
	Local aUsuarios  := {}
	Local cMsg		 := ""
	Local aUsrMat    := QNCUSUARIO()
	Local cSendConta := aUsrMat[5]
	Local cCampo     := ""
	Local cTpMail    := "1"
	Local nC
	Local aArea      := ()
	Local cChaveQI2  := ""
	Local nRegQI2    := 0
	Local nOrdQI2    := 0
	Local aMemos     := {{"QI2_DDETA"  ,"QI2_MEMO1"},;	// Descricao Detalhada
						 {"QI2_COMEN"  ,"QI2_MEMO2"},;	// Comentarios
						 {"QI2_DISPOS" ,"QI2_MEMO3"},;	// Acao Imediata/Disposicao
						 {"QI2_MOTREV" ,"QI2_MEMO4"}}	// Motivo da Revisao

	Local cThreadID      := THREADID()  			//Armazena o identificador da thread
	Local cAviso         := ""
	Local lBloqueio      := .F.
	Local cNomeArq		 := "QTMKPMS.QNC"
	Local nHdl
	Local nFilePosTxt
	Local cBufTxt
	Local nTamTxt
	Local lAuto 		 := .F.
	Local aStruQI2 := FWFormStruct(3, "QI2",, .F.)[3]
	Local nX
	Local nMVQTMKPMS := GetMv("MV_QTMKPMS")

	Default cHabilidade := ""
	Default cChamado    := ""
	Default lRev        := .F.

	Private aMsg	 := {}
	Private cFilDest := cDesFil
	Private cFilMat  := cFilAnt
	Private cFilOrig := cOriFil
	Private cArqDele := ""
	Private __lQNSX8 := .F.
	Private aQNQI2   := {}
	Private aAliasQN := {}
	Private lTMKPMS    := If(GetMv("MV_QTMKPMS",.F.,1) == 1,.F.,.T.)//Integracao do QNC com TMK e PMS: 1-Sem integracao,2-TMKxQNC,3-QNCxPMS,4-TMKxQNCxPMS ³

	lAuto := Iif(type('lTmk503Auto')=='L',lTmk503Auto,.F.)

	If Type("cMatFil") == "U"
		Private cMatFil := cDigFil
	Endif
	If Type("cMatCod") == "U"
		Private cMatCod := cDigMat
	Endif
	If Type("cMatDep") == "U"
		Private cMatDep := cDigDep
	Endif

	If Type("INCLUI") == "U"
		INCLUI := .T.
	Endif

	Private lOldINCL := INCLUI

/*BLOQUEAR GERACAO DE FNC CASO O PARAMETRO MV_QLYXCAL TENHA SIDO DESATIVADO MAS 
AINDA EXISTE FNC'S OU PLANO'S ABERTOS*/
	IF lTMKPMS
		If (nMVQTMKPMS == 2) .Or. (nMVQTMKPMS == 4)
			If File(cNomeArq)
			nHdl := FOpen( cNomeArq, FO_READWRITE+FO_SHARED ) 
			nTamTxt := FSEEK( nHdl, 0, FS_END ) 
			FSEEK( nHdl, 0 ) //Seta o FSeek para inicio do arquivo 
			nFilePosTxt := FSEEK( nHdl, 0, FS_RELATIVE )
			cBufTxt     := FREADSTR( nHdl, nTamTxt )
				If nHdl > 0
				FClose(nHdl)
				Endif
			Endif
		DbselectArea("SUD")
		aArea := GetArea()
		dbGoTop()
		cAviso := STR0149//"A(s) FNC(s)listada(s) abaixo encontram-se aberta(s), encerre-a(s) primeiramente para em seguida ativar o paramentro MV_QTMKPMS:"
		cAviso += CRLF
			While SUD->(!Eof().And. SUD->UD_FILIAL == xFilial("SUD"))
				If SUD->UD_STATUS == "1"
	  		DbselectArea("QI2")
			QI2->(dbSetOrder(2))	
					If QI2->(MsSeek(xFilial("QI2")+SUD->UD_CODFNC+SUD->UD_FNCREV))
						If Empty(QI2->QI2_CONREA)//Validacao se a fnc nao esta encerrada
							If Empty(cBufTxt)
						cAviso += CRLF+"   "+SUD->UD_CODFNC+" - "+SUD->UD_FNCREV
						lBloqueio := .T.
							Else
						Exit
							Endif
						Endif
					Endif
				Endif
		 SUD->(dbSkip()) 	
			Enddo
		RestArea(aArea)
			If lBloqueio
			cAviso += CRLF
			Aviso(STR0007,cAviso,{"OK"},3,"Geracao de FNC") 
			Return({Space(2),Space(10),Space(4)})
			Else
				If !File(cNomeArq)
				nHdl := FCreate( cNomeArq, FC_NORMAL ) 
				FWrite( nHdl, DTOS(dDataBase)) 
					If nHdl > 0
					FClose(nHdl)
					Endif
				Endif
			Endif
		Endif
	Endif

	dbSelectArea("QI2")
	RegToMemory("QI2",.F.)

	Begin Transaction
		If nOpc == 1	// Incluir
			If Len(aQI2Campos) == 0
				If !IsBlind()
					MsgAlert(OemToAnsi(STR0040))	// "Nao foi passado os campos necessarios para a geracao da Ocorrencias/Nao-conformidade."
				Endif
				DisarmTransaction()
				Break
				aRetQI2:= {Space(2),Space(10),Space(4)}
			Endif

			INCLUI := .T.

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Gerando revisao da FNC.  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
			If lRev
				dbSelectArea("QI2")
				dbSetOrder(2)
				If dbSeek(aQI2Campos[1][2]+aQI2Campos[2][2]+aQI2Campos[3][2])

					cChaveQI2 := QI2->QI2_FILIAL+QI2->QI2_FNC
					nRegQI2   := QI2->(Recno())
					nOrdQI2   := QI2->(IndexOrd())

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Permite apenas a Geracao de Revisao se o Plano de Acao estiver BAIXADO e ³
					//³ se o numero da revisao for menor que "99"(limite de revisoes)            ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !Empty(QI2->QI2_CONREA)
						If Val(QI2->QI2_REV) < 99
							RecLock("QI2",.F.)
					    	QI2->QI2_OBSOL := "S"
							MsUnLock()					
						Endif
					Else
						DisarmTransaction()
						MsgAlert(OemToAnsi(STR0111))//"Nao sera permitida a Geracao de Revisao para Lancamentos pendentes."
						Break
					Endif
				Endif
			Endif
		
			For nX := 1 To Len(aStruQI2)
				If GetSx3Cache(aStruQI2[nX,1], "X3_TIPO") == "M"
					If (nPQNC := aScan(aQI2Campos,{ |X| UPPER(ALLTRIM(X[1])) == UPPER(ALLTRIM(aStruQI2[nX,1]))})) > 0
						&("M->"+UPPER(ALLTRIM(aStruQI2[nX,1]))) := aQI2Campos[nPQNC,2]
					Else
						&("M->"+UPPER(ALLTRIM(aStruQI2[nX,1]))) := Space(GetSx3Cache(aStruQI2[nX,1], "X3_TAMANHO"))
					Endif
				EndIf
			Next nX
	
			dbSelectArea("QI2")
			For nI := 1 To FCount()
				cCampo := EVAL(bCampo,nI)
				lInit := .F.
				If ExistIni(cCampo)
					lInit := .T.
					M->&(cCampo) := InitPad(GetSx3Cache(cCampo, "X3_RELACAO"))
					If ( ValType(M->&(cCampo)) == "C" )
						M->&(cCampo) := Padr(M->&(cCampo),GetSx3Cache(cCampo, "X3_TAMANHO"))
					Endif
					If ( M->&(cCampo) == NIL )
						lInit := .F.
					EndIf
				EndIf
				If ( ! lInit )
					If ( ValType(M->&(cCampo)) == "C" )
						M->&(cCampo) := Space(Len(M->&(cCampo)))
					ElseIf ( ValType(M->&(cCampo)) == "N" )
						M->&(cCampo) := 0
					ElseIf ( ValType(M->&(cCampo)) == "D" )
						M->&(cCampo) := Ctod("  /  /  ","DDMMYY")
					ElseIf ( ValType(M->&(cCampo)) == "L" )
						M->&(cCampo) := .F.
					EndIf
				EndIf
				dbSelectArea("QI2")
			Next
	
			M->QI2_FILIAL := xFilial("QI2")
		
			If !lTMKPMS
				M->QI2_ORIGEM := "QNC"
			
				M->QI2_FILORI	:= cOriFil
				M->QI2_ORIDEP	:= cOriDep
			
				M->QI2_FILDEP	:= cDesFil
				M->QI2_DESDEP	:= cDesDep
			
				M->QI2_FILRES	:= cResFil
				M->QI2_MATRES	:= cResMat
			
				M->QI2_FILMAT	:= cDigFil
				M->QI2_MATDEP	:= cDigDep
				M->QI2_MAT		:= cDigMat
			Else
				M->QI2_ORIGEM := cModulo
			Endif
		
			IF lTMKPMS
				If (nMVQTMKPMS >1)
					M->QI2_NCHAMA	:= cChamado
				Endif
			Endif
		
			dbSelectArea("QI2")
			For nI:=1 to FCount()
				cCampo := EVAL(bCampo,nI)
				If (nPQNC := aScan(aQI2Campos,{ |X| UPPER(ALLTRIM(X[1])) == UPPER(Field(nI))})) > 0
					M->&(cCampo) := aQI2Campos[nPQNC,2]
				Endif
				dbSelectArea("QI2")
			Next
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicializa alguns campos obrigatorios para controle de pendencias ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If len(M->QI2_FNC) == 15
	    		M->QI2_ANO  := SubStr(M->QI2_FNC,12,4)
			Else
				M->QI2_ANO  := SubStr(M->QI2_FNC,7,12)
			Endif
			
			IF ExistBlock( "QNCIFNC" )
				ExecBlock( "QNCIFNC", .f., .f. )
			Endif
	
			RecLock( "QI2", .T. )
		
			For nC := 1 TO FCount()
				FieldPut( nC, M->&( Eval( bCampo, nC ) ) )
			Next
	    
			If lRev
	    		QI2->QI2_FNC := aQI2Campos[2][2]
	    		QI2->QI2_REV := StrZero(Val(aQI2Campos[3][2])+1,2)
			Endif
	    
	    	QI2->QI2_OBSOL:="N"    
	    		    	    
			//Gravacao das chaves dos Campos Memo na Inclusao
			MSMM(QI2_DDETA ,,,M->QI2_MEMO1,1,,,"QI2","QI2_DDETA" )
			MSMM(QI2_COMEN ,,,M->QI2_MEMO2,1,,,"QI2","QI2_COMEN" )
			MSMM(QI2_DISPOS,,,M->QI2_MEMO3,1,,,"QI2","QI2_DISPOS")
	
			IF ExistBlock( "QNCGRFNC" )
				ExecBlock( "QNCGRFNC", .f., .f. )
			Endif
		
			MsUnlock()
			FKCOMMIT()                  
	
			If __lQNSX8
				ConfirmeQE(aQNQI2)
			EndIf
	
			QNCATULEG(QI2->QI2_FILRES, QI2->QI2_MATRES)
					
			aUsuarios := {}
		
			If QAA->(dbSeek(QI2->QI2_FILRES + QI2->QI2_MATRES )) .And. QAA->QAA_RECMAI == "1"
				cMail := AllTrim(QAA->QAA_EMAIL)
			Endif
	
			If !Empty(cMail)
		
				cTpMail:= QAA->QAA_TPMAIL
	
				// FNC
				If cTpMail == "1"
					cRoda := OemToAnsi(STR0046)+cModulo+" - "+OemToAnsi(STR0047)	// "Mensagem gerada automaticamente pelo Sistema SIGA"  ### "Integracao com SIGAQNC"
					cMsg := QNCSENDMAIL(1,OemToAnsi(STR0029),.F.,.F.,.F.,cRoda)	// "Ficha de Ocorrencia/Nao-Conformidade iniciada."
				Else
					cMsg := OemToAnsi(STR0029)+CHR(13)+CHR(10)	 // "Ficha de Ocorrencia/Nao-Conformidade iniciada."
					cMsg += CHR(13)+CHR(10)
					If !Empty(M->QI2_DESCR)
						cMsg += OemToAnsi(STR0043)+CHR(13)+CHR(10)	// "Descricao:"
						cMsg += M->QI2_DESCR+CHR(13)+CHR(10)
						cMsg += CHR(13)+CHR(10)                                                                  
					Endif
					If !Empty(M->QI2_MEMO1)
						cMsg += OemToAnsi(STR0044)+CHR(13)+CHR(10)	// "Descricao Detalhada:"
						cMsg += M->QI2_MEMO1+CHR(13)+CHR(10)
						cMsg += CHR(13)+CHR(10)
					Endif
					cMsg += OemToAnsi(STR0046)+cModulo+" - "+OemToAnsi(STR0047) +  CRLF	// "Mensagem gerada automaticamente pelo Sistema SIGA"  ### "Integracao com SIGAQNC"
				Endif
			
				cAttach := ""
				aMsg:={{OemToAnsi(STR0048)+" "+TransForm(M->QI2_FNC,PesqPict("QI2","QI2_FNC"))+"-"+M->QI2_REV+Space(10)+DTOC(Date())+"-"+SubStr(TIME(),1,5) , cMsg, cAttach } }	// "Ocorrencia/Nao-conformidade No. "
		
				// Geracao de Mensagem
				IF ExistBlock( "QNCFICHA" )
					aMsg := ExecBlock( "QNCFICHA", .f., .f. )
				Endif
	
				aUsuarios := {{QAA->QAA_LOGIN, cMail, aMsg} }
				QaEnvMail(aUsuarios,,,,cSendConta,"1")
			Endif
	
			dbSelectArea("QI2")
			dbSetOrder(1)
			INCLUI := lOldINCL	
			aRetQI2 := 	{M->QI2_FILIAL,M->QI2_FNC,M->QI2_REV}

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³So ira gerar Plano de Ação automaticamente quando a solicitação³
			//³partir do TMK.											      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			If (M->QI2_ORIGEM == "TMK")
				IF lTMKPMS
					If (nMVQTMKPMS == 2) .Or. (nMVQTMKPMS == 4)
				    //Atualizaco do TMK
				 
						aArea := GetArea()
						If !IsBlind()
							If lAuto
								QNCGeraPlano(M->QI2_FNC,M->QI2_REV,M->QI2_DESDEP,,,,,,lRev,,,,M->QI2_MEMO1)
							Else
								MsgRun(OemtoAnsi(STR0102),OemtoAnsi(STR0103),{||QNCGeraPlano(M->QI2_FNC,M->QI2_REV,M->QI2_DESDEP,,,,,,lRev,,,,M->QI2_MEMO1)})//"Gerando Plano de Acao"##"Aguarde"  		    		
							Endif
						Else
			  				QNCGeraPlano(M->QI2_FNC,M->QI2_REV,M->QI2_DESDEP,,,,,,lRev,,,,M->QI2_MEMO1) 		    		
						Endif
					    RestArea(aArea)
						dbSelectArea("QI9") 
						dbSetOrder(2) 
						If QI9->(MsSeek(xFilial("QI9")+M->QI2_FNC+M->QI2_REV))
							dbSelectArea("QI5") 
							dbSetOrder(1) 
							IF QI5->(MsSeek(QI9->QI9_FILIAL+QI9->QI9_CODIGO+QI9->QI9_REV))
								aArea      := GetArea()
								lPendencia := QVALPLFILHO()
							    RestArea(aArea)
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Caso a etapa possua Etapa filha, primeiramente estas deverao ser executadas , ³
								//³para apos sua conclusao a etapa pai poder ser executada.                      ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ					
								IF lPendencia
							    	RecLock("QI5",.F.)
								    QI5->QI5_PEND := "N" 
									MsUnlock() 
									dbCommit()								   		
								Endif
							Endif
						Endif
					
					Endif
				Endif
			Endif
		Else	// Excluir
		dbSetOrder(2)
			If dbSeek(aQI2Campos[1]+aQI2Campos[2]+aQI2Campos[3])
				QNC040Del()
			Endif
	
			IF ExistBlock( "QNCEXFNC" )
				ExecBlock( "QNCEXFNC", .f., .f. )
			Endif
			dbSetOrder(1)
			aRetQI2 := {}
		Endif
	End Transaction
	
dbSelectArea(cAlias)
dbSetOrder(nOrdem)

Return(aRetQI2)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNCCBOX   ³ Autor ³ Aldo Marini Junior    ³ Data ³ 13.03.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao generica para retornar em Array o X3_XCBOX          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNCCBOX(cCampo,aArray)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Caracter que contem o campo a ser pesquisado       ³±±
±±³          ³ ExpA1 = Array onde sera armazenado os itens do x3_cbox     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QNCCBOX(cCampo,aArray)
	Local nPosCBOX1 := 0
	Local nPosCBOX2 := 0
	Local nCtBOX    := 0
	Local cCBOX     := ""

	aArray := {}
	SX3->(dbSetOrder(2))
	If SX3->(dbSeek(cCampo)) .And. !Empty(X3Cbox())
		cCBOX := AllTrim(X3Cbox())
		nCtBOX := 0
		While Len(cCBOX) > 0
			nCtBOX++
			If (nPosCBOX1 := AT(Str(nCtBOX,1)+"=",cCBOX)) > 0
				nPosCBOX2 := AT(";",cCBOX)
				If nPosCBOX2 == 0
					nPosCBOX2 := Len(cCBOX)
					aAdd(aArray,SubStr(cCBOX,nPosCBOX1+2,nPosCBOX2-nPosCBOX1-1))
				Else
					aAdd(aArray,SubStr(cCBOX,nPosCBOX1+2,nPosCBOX2-nPosCBOX1-2))
				Endif
				cCBOX := SubStr(cCBOX,nPosCBOX2+1,Len(cCBOX))
			Endif
		Enddo
	Endif
	SX3->(dbSetOrder(1))

Return Nil

/*/           
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡ao    ³QNCUSUARIO³ Autor ³ Aldo Marini Junior       ³ Data ³ 03/04/01 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡ao ³Retorna um array com dados do Usuario Logado                   ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Sintaxe   ³QNCUSUARIO()                                                   ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametro ³Nenhum                                                         ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Uso       ³SIGAQNC - Generico                                             ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/           
Function QNCUSUARIO()
	Local aArray := {.F.,"","","",""}
	Local cAlias := Alias()
	Local nOrdem := IndexOrd()
	Local nRecord:= Recno()
	Local nOrdQAA:= QAA->(IndexOrd())
	Local nPosQAA:= QAA->(Recno())

	DbSelectArea("QAA")
	DbSetOrder(6)

	If dbSeek( TRIM(UPPER(cUserName)) ) //Foi trocado a função UsrFullName() pela cUserName
		aArray[1] := .T.
		aArray[2] := QAA_FILIAL
		aArray[3] := QAA_MAT
		aArray[4] := QAA_CC
		If !Empty(AllTrim(QAA->QAA_EMAIL))
			aArray[5] := QAA_EMAIL
		Else
			If !Empty(UsrRetMail(__cUserID)) //Foi trocado a função RetCodUsr() pela __cUserID 
				aArray[5] := UsrRetMail(RetCodUsr())
			Else
				aArray[5] := "SIGA"+cModulo
			EndIf
		Endif
	EndIf
	DbSetOrder(1)

	QAA->(DbSetOrder(nOrdQAA))
	QAA->(DbGoto(nPosQAA))

	If !Empty(cAlias)
		dbSelectArea(cAlias)
		dbSetOrder(nOrdem)
		dbGoTo(nRecord)
	EndiF
Return aArray

//------------------------------------------------------------------------------------//
//A função abaixo foi comentada pois é orientado que sempre se use fuções padrões já existentes.
//O cliente abriu o ticket 7735140, citando que o relatório estava imprimindo caracteres especiais.
/*Static FUNCTION cabec(cTitulo,cCabec1,cCabec2,cNomPrg,nTamanho,nChar,aCustomText,lPerg)
	Local nLin    := 0
	Local xStr    := 0
	Local nCont   := 0
	Local nI      := 0
	Local nRecuo  := 20
	Local lWin    := .f.
	Local aDriver := ReadDriver()
	Local nRow
	Local nCol
	Local nLargura
	Local cVar
	Local uVar
	Local cPicture
	Local nX

	Default aCustomText := Nil // Parâmetro que se passado suprime o texto padrao desta função por outro customizado

	If lPerg == Nil
		lPerg := If(GetMv("MV_IMPSX1") == "S" ,.T.,.F.)
	Endif

	cNomPrg := Alltrim(cNomPrg)

	Private cSuf:=""

	DEFAULT lFirst := .t.
	If TYPE("__DRIVER") == "C"
		If "DEFAULT"$__DRIVER
			lWin := .t.
		EndIf
	EndIf

	nLargura:=Iif(nTamanho=="P",80,Iif(nTamanho=="G",220,132))
	cTitulo :=Iif(TYPE("NewHead")!="U",NewHead,cTitulo)

	IF aReturn[5] == IMP_DISCO
		lWin := .f.    // Se eh disco , nao eh windows
	Endif

	If lFirst
		nRow := PRow()
		nCol := PCol()
		SetPrc(0,0)
		// Caso seja 80 colunas, sempre imprime Retrato, 220 Coluna sempre imrime Paisagem, já 132 colunas pode imprimir das duas maneiras
		If aReturn[5] <> IMP_SPOOL // Se não for via Windows manda os caracteres para setar a impressora
			If nChar == NIL .and. !lWin .and. __cInternet == Nil
				@ 0,0 PSAY &(If(nTamanho=="P",aDriver[1],If(nTamanho=="G",aDriver[5],(If(aReturn[4]=1,aDriver[3],aDriver[4])))))
			ElseIf !lWin .and. __cInternet == Nil
				If nChar == 15
					@ 0,0 PSAY &(If(nTamanho=="P",aDriver[1],If(nTamanho=="G",aDriver[5],(If(aReturn[4]=1,aDriver[3],aDriver[4])))))
				Else
					@ 0,0 PSAY &(If(nTamanho=="P",aDriver[2],If(nTamanho=="G",aDriver[6],aDriver[4])))
				EndIf
			EndIf
		EndIF
		If GetMV("MV_CANSALT",,.T.) // Saltar uma página na impressão
			If GetMv("MV_SALTPAG",,"S") != "N"
				Setprc(nRow,nCol)
			EndIf
		Endif
	EndIf

// Impressão da lista de parâmetros quando solicitada
	If Type("cPerg")!="U" .and. lPerg .and. Substr(cAcesso,101,1) == "S"
		If lFirst
			// Imprime o cabeçalho padrão
			nLin := QSendCab(lWin, nLargura, cNomPrg, RptParam+" - "+Alltrim(cTitulo), "", "", .F.)

			Pergunte(cPerg ,.F.)
			For nX := 1 to Len(aPergunta)
				cVar := "MV_PAR"+StrZero(nX,2,0)
				@(nLin+=2),5 PSAY INIFIELD+RptPerg+" "+ StrZero(nX,2,0) + " : "+ AllTrim(aPergunta[nX][1])+FIMFIELD
				If aPergunta[nX][6] == "C" // X1_GSC
					xStr:=StrZero(&cVar,2)
					If ( &(cVar)==1 )
						@ nLin,Pcol()+3 PSAY INIFIELD+aPergunta[nX][9]+FIMFIELD//X1Def01()
					ElseIf ( &(cVar)==2 )
						@ nLin,Pcol()+3 PSAY INIFIELD+aPergunta[nX][10]+FIMFIELD//X1Def02()
					ElseIf ( &(cVar)==3 )
						@ nLin,Pcol()+3 PSAY INIFIELD+aPergunta[nX][11]+FIMFIELD//X1Def03()
					ElseIf ( &(cVar)==4 )
						@ nLin,Pcol()+3 PSAY INIFIELD+aPergunta[nX][12]+FIMFIELD//X1Def04()
					ElseIf ( &(cVar)==5 )
						@ nLin,Pcol()+3 PSAY INIFIELD+aPergunta[nX][13]+FIMFIELD//X1Def05()
					Else
						@ nLin,Pcol()+3 PSAY INIFIELD+''+FIMFIELD
					EndIf
				Else
					uVar := &(cVar)
					If ValType(uVar) == "N"
						cPicture:= "@E "+Replicate("9",aPergunta[nX][3]-aPergunta[nX][4]-1) // X1_TAMANHO, X1_DECIMAL
						If( aPergunta[nX][4]>0 )//X1_DECIMAL
							cPicture+="."+Replicate("9",aPergunta[nX][4])//X1_DECIMAL
						Else
							cPicture+="9"
						EndIf
						@nLin,Pcol()+3 PSAY INIFIELD+Transform(Alltrim(Str(uVar)),cPicture)+FIMFIELD
					Elseif ValType(uVar) == "D"
						@nLin,Pcol()+3 PSAY INIFIELD+DTOC(uVar)+FIMFIELD
					Else
						@nLin,Pcol()+3 PSAY INIFIELD+uVar+FIMFIELD
					EndIf
				EndIf
			Next nX

			cFiltro := Iif (!Empty(aReturn[7]),MontDescr(Alias(),aReturn[7]),"")
			nCont := 1
			If !Empty(cFiltro)
				@(nLin+=2),5  PSAY  OemtoAnsi(STR0043) + Substr(cFiltro,nCont,nLargura-19)  // "Filtro      : "
				While Len(AllTrim(Substr(cFiltro,nCont))) > (nLargura-19)
					nCont += nLargura - 19
					@(nLin+=1),19	PSAY	Substr(cFiltro,nCont,nLargura-19)
				End
				nLin++
			EndIf
			@(++nLin),00  PSAY REPLI("*",nLargura)+FIMPARAM
		EndIf
	EndIf

//////////// Imprime Cabecalho
	nLin:=0
	@nLin,0 PSAY INICABEC //Token para identificar o inicio de uma cabec
	nLin++
	@nLin,0 PSAY Iif(!lWin,Chr(13),"")+REPLI("*",nLargura)

// Nome da Empresa
	@(++nLin), 0 PSAY "*"+INIFIELD+AllTrim(SM0->M0_NOME)+If(ExistFilial()," / "+AllTrim(SM0->M0_FILIAL),"")+FIMFIELD

// Folha
	If __SetCentury()
		nRecuo := 20
	else
		nRecuo := 18
	endif

	@nLin,nLargura-nRecuo  PSAY INIFIELD+RptFolha+" "+TRANSFORM(m_pag,'999999')+FIMFIELD
	@nLin,nLargura-1	 PSAY "*"

// Versão
	@(++nLin), 0 PSAY "*"+INIFIELD+"SIGA /"+cNomPrg+"/v."+cVersao+FIMFIELD

// Título do relatório
	@nLin,(xStr:=(Len(cNomPrg)+Len(cVersao)+10)) PSAY INIFIELD+PADC(Trim(cTitulo),nLargura-xStr-nRecuo)+FIMFIELD
	@nLin,(nLargura - (Len(RptDtRef+" "+DTOC(dDataBase)))-1) PSAY INIFIELD+RptDtRef+" "+DTOC(dDataBase)+FIMFIELD

	@nLin,nLargura-1	 PSAY "*"

// Hora da emissão
	@(++nLin),0 PSAY "*"+INIFIELD+RptHora+" "+time()+FIMFIELD

// Data de emissão
	@nLin,nLargura-nRecuo PSAY INIFIELD+RptEmiss+" "+DToC(MsDate())+FIMFIELD

	@nLin,nLargura-1	 PSAY "*"
	LI:=6

	If aCustomText == Nil // Imprime o cabeçalho padrão dos relatórios
		If LEN(Trim(cCabec1)) != 0
			LI:=8
			@(++nLin),00 PSAY REPLICATE("*",nLargura)
			@(++nLin),00 PSAY INIFIELD+cCabec1+FIMFIELD

			If LEN(Trim(cCabec2)) != 0
				@(++nLin),00  PSAY INIFIELD+cCabec2+FIMFIELD
				LI:=9
			EndIf
			@(++nLin),00  PSAY REPLICATE("*",nLargura)
		Endif
		@nLin,0 PSAY FIMCABEC //Token para identificar o final de uma cabec
	Else
		@++nLin,0 PSAY FIMCABEC //Token para identificar o final de uma cabec
		@(++nLin),00  PSAY REPLICATE("*",nLargura)
		For nI := 1 to Len(aCustomText)
			@(++nLin),0 PSAY aCustomText[nI]
		Next nI
		LI := Len(aCustomText)+8
		@(++nLin),00  PSAY REPLICATE("*",nLargura)
	EndIf

	m_pag++
	lFirst := .f.
	If Subs(__cLogSiga,4,1) == "S"
		__LogPages()
	EndIf

Return nLin*/

//------------------------------------------------------------------------------------//
Static Function ExistFilial()
	Local cAlias := Alias()
	Local nRecno, lRet := .f.
	Local cCodigo

	DbSelectArea("SM0")
	cCodigo := M0_CODIGO
	nRecno := Recno()
	DbSeek(cCodigo)
	DbSkip()
	If M0_CODIGO == cCodigo
		lRet := .t.
	EndIf
	DbGoTo(nRecno)
	If !Empty(cAlias)
		DbSelectArea(cAlias)
	EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³QImpr		³ Autor ³ Aldo Marini Junior    ³Data  ³ 08.03.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Controle de Linhas de Impressao e Cabecalho                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QIMPR(Detalhe,Fimfolha,Pos_cabec)                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Detalhe = Caracter onde contem o que vai ser impresso      ³±±
±±³          ³ FimFolha= Caracter onde especifica continua/final da folha ³±±
±±³          ³ Pos_cabec=Indica posicao do cabecalho                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QImpr( cDetalhe , cFimFolha , nReg , cRoda , nColuna , lSalta )

Local aCabec := {}
Local cDetCab:= ""
Local cWCabec:= ""
Local nCb	 := 0
Local nSpace := IIF(nTamanho=="P",80,IIF(nTamanho=="G",220,132))

Static lPerg 
Static nNormal 
Static nComp

	If nNormal = Nil
	nNormal := GetMv("MV_NORM")
	Endif
	If nComp = Nil
	nComp := GetMv("MV_COMP")
	Endif

m_pag		:= ContFl
cFimFolha	:= IF( cFimFolha		== NIL							  		, ""		, cFimFolha	)
cDetalhe	:= IF( cDetalhe			== NIL							  		, ""		, cDetalhe	)
wCabec0 	:= IF( Type("wCabec0")	== "U"							  		, 0			, wCabec0	)
wCabec1 	:= IF( Type("wCabec1")	== "U"							  		, ""		, wCabec1	)
wCabec2 	:= IF( Type("wCabec2")	== "U"							  		, ""		, wCabec2	)
nReg		:= IF( nReg				== NIL							  		, 0.00		, nReg		)
wnRel		:= IF( Type("wnRel")	== "U" .and. Type("nomeprog") != "U"	, nomeprog	, wnRel		)
nColuna 	:= IF( nColuna			== NIL							  		, 0			, nColuna	)
lSalta		:= IF( lSalta 			== NIL							  		, .T. 		, lSalta	)
nChar		:= IF( Type("nChar")	== "U"									, nNormal	, If (nChar = 15, nComp,nNoral)) 

	IF Upper(cFimFolha) $ "FP" .or. Li >= 58
		IF Li != 0.00
			IF Upper(cFimFolha) $ "F" .or. cRoda != NIL
				IF nReg == 0.00 .or. cRoda == NIL
				Roda( 0.00 , ""    , nTamanho )
				Else
				Roda( nReg , cRoda , nTamanho )
				EndIF
			EndIF
		Li := 0.00
		EndIF
		IF Upper(cFimFolha) $ "FP"
		Return( NIL )
		EndIF
	EndIF

	IF Li == 0.00
		IF wCabec0 <= 2
		Cabec( Titulo , wcabec1 , wcabec2 , wnrel , nTamanho )
		Else
			For nCb := 1 to wCabec0
				IF Type((cWCabec := "wCabec"+Alltrim(Str(nCb)))) != "U"
		    	cDetCab := &(cWCabec)
		    	cDetCab += Space(nSpace - Len(cDetCab) -1)
	    		Aadd(aCabec,cDetCab)
				EndIF
			Next nCb
	  	Cabec( Titulo , "" , "" , wnrel , nTamanho , ,aCabec )
		EndIF
	ContFl++
	EndIF

@ Li , nColuna PSAY cDetalhe

	IF(lSalta,Li++,NIL)

Return( NIL )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³QImpr		³ Autor ³ Aldo Marini Junior    ³Data  ³ 29.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Imprime o cabecalho especifico no formato grafico           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³QSendCab(lWin,nLargura,cNomPrg,cTitulo,cCabec1,cCabec2,     ³±±
±±³       	 ³         lPrtPagNum)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1   = Logico definindo copia em Video ou Impressora    ³±±
±±³          ³ ExpN1   = Numerico definindo tamanho da largura            ³±±
±±³          ³ ExpC1   = Caracter definindo nome do programa/relatorio    ³±±
±±³          ³ ExpC2   = Caracter definindo titulo do relatorio           ³±±
±±³          ³ ExpC3   = Caracter definindo linha1 do cabecalho           ³±±
±±³          ³ ExpC4   = Caracter definindo linha2 do cabecalho           ³±±
±±³          ³ ExpL2   = Logico definindo se imprime perguntas no comeco  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QNCXFUN(Funcao QImpr())                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function QSendCab(lWin, nLargura, cNomPrg, cTitulo, cCabec1, cCabec2, lPrtPagNum)
Local nLin   := 0
Local xStr   := 0
Local nRecuo := 20

@(nLin:=0),0 PSAY INICABEC //Token para identificar o inicio de uma cabec
@(++nLin) ,0 PSAY Iif(!lWin,Chr(13),"")+REPLI("*",nLargura)

// Nome da Empresa
@(++nLin), 0 PSAY "*"+INIFIELD+AllTrim(SM0->M0_NOME)+If(ExistFilial()," / "+AllTrim(SM0->M0_FILIAL),"")+FIMFIELD

// Folha
	If __SetCentury()
	nRecuo := 20
	else
	nRecuo := 18
	endif

	If lPrtPagNum // Imprimir o número da folha
	@nLin,nLargura-nRecuo  PSAY INIFIELD+RptFolha+" "+TRANSFORM(m_pag,'999999')+FIMFIELD
	Else
	@nLin,nLargura-nRecuo  PSAY INIFIELD+Space(Len(RptFolha)+7)+FIMFIELD // Manda espaços em branco para compatibilizar
	Endif
@nLin,nLargura-1	 PSAY "*"
	
// Versão
@(++nLin), 0 PSAY "*"+INIFIELD+"SIGA /"+cNomPrg+"/v."+cVersao+FIMFIELD

// Título do relatório
@nLin,(xStr:=(Len(cNomPrg)+Len(cVersao)+10)) PSAY INIFIELD+PADC(Trim(cTitulo),nLargura-xStr-nRecuo)+FIMFIELD
@nLin,(nLargura - (Len(RptDtRef+" "+DTOC(dDataBase)))-1) PSAY INIFIELD+RptDtRef+" "+DTOC(dDataBase)+FIMFIELD

@nLin,nLargura-1	 PSAY "*"

// Hora da emissão
@(++nLin),0 PSAY "*"+INIFIELD+RptHora+" "+time()+FIMFIELD

// Data de emissão
@nLin,nLargura-nRecuo PSAY INIFIELD+RptEmiss+" "+DToC(MsDate())+FIMFIELD

@nLin,nLargura-1	 PSAY "*"
LI:=6
	If LEN(Trim(cCabec1)) != 0
	LI:=8
	@(++nLin),00 PSAY REPLICATE("*",nLargura) 
	@(++nLin),00 PSAY INIFIELD+cCabec1+FIMFIELD
	
		If LEN(Trim(cCabec2)) != 0
		@(++nLin),00  PSAY INIFIELD+cCabec2+FIMFIELD
		LI:=9
		EndIf
	@(++nLin),00  PSAY REPLICATE("*",nLargura)
	Else
	@(++nLin),00 PSAY REPLICATE("*",nLargura) 
	EndIf
@nLin,0 PSAY FIMCABEC //Token para identificar o final de uma cabec

Return nLin

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³QNCSENDMAIL³ Autor ³ Aldo Marini Junior   ³Data  ³ 29.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Envia email para os responsaveis das FNC e Plano de Acao    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³QNCSENDMAIL(nTipo,cMensag,lRelac1,lRelac2,lRelac3)          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1   = Numerico definindo o tipo do email               ³±±
±±³          ³ ExpC1   = Caracter definindo a mensagem antes do corpo do e³±±
±±³          ³ ExpL1   = Logico   definindo email de FNC                  ³±±
±±³          ³ ExpL2   = Logico   definindo email de Plano de Acao        ³±±
±±³          ³ ExpL3   = Logico   definindo email de Etapas Plano de Acao ³±±
±±³          ³ ExpC2   = Caracter definindo a mensagem de Rodape          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNCSENDMAIL(nTipo,cMensag,lRelac1,lRelac2,lRelac3,cRoda)
// Tipo 1 - FNC
// Tipo 2 - Plano de Acao
// Tipo 3 - Etapas do Plano de Acao
Local aUsrMat := QNCUSUARIO()
Local cMsg    := ""
Local cAliasA := Alias()
Local nIdxQI2 := QI2->(IndexOrd())
Local nIdxQI3 := QI3->(IndexOrd())
Local nIdxQI5 := QI5->(IndexOrd())
Local nIdxQI6 := QI6->(IndexOrd())
Local nIdxQI9 := QI9->(IndexOrd())
Local nRecQI2 := QI2->(Recno())
Local nRecQI3 := QI3->(Recno())
Local nRecQI5 := QI5->(Recno())
Local nRecQI6 := QI6->(Recno())
Local nRecQI9 := QI9->(Recno())
Local nRecQAA := QAA->(Recno())

DeFault lRelac1 := .F.
DeFault lRelac2 := .F.
DeFault lRelac3 := .F.
DeFault cRoda   := OemToAnsi(STR0041)	// "Mensagem gerada automaticamente pelo Sistema SIGAQNC - Controle de Nao-conformidades"

Private aPriori := {}
Private aTipo   := {}
Private aStatus := {}
Private aTipQI3 := {}
Private cMatFil := aUsrMat[2]
Private cMatCod := aUsrMat[3]
Private cMatDep := aUsrMat[4]

	If Type('cMotivo') = 'U'
	cMotivo := ""
	Endif

QNCCBOX("QI2_PRIORI", @aPriori)
QNCCBOX("QI2_TPFIC",  @aTipo)
QNCCBOX("QI2_STATUS", @aStatus)
QNCCBOX("QI3_TIPO",   @aTipQI3)  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona na ordem correta para relacionar FNC x PLANO             ³
//³ Ordem 1(um)  sera usada para trazer FNCs do Plano de Acao          ³
//³ Ordem 2(dois)sera usada para trazer o Plano de Acao das FNCs       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QI9")
	If nTipo == 1		// FNC X Plano
	dbSetOrder(2)
	Else				// Plano X FNC
	dbSetOrder(1)
	Endif

dbSelectArea("QI6")
dbSetOrder(1)

dbSelectArea("QI5")
dbSetOrder(1)

dbSelectArea("QI2")
dbSetOrder(1)

dbSelectArea("QI3")
dbSetOrder(1)

cMsg+='<html> <head> <title>SIGAQNC</title> </head>'
cMsg+='<body>'

	If !Empty(cMotivo)
	cMsg+='<table border=1 width="657" height="29" cellspacing="1" bordercolorlight="#0099cc" bordercolordark="#0099cc" bordercolor="#0099cc" bgcolor="#0099cc" >'
	cMsg+='	<tr><td width="606" height="1" align="left" bordercolor="#0099cc" bordercolorlight="#0099cc" bordercolordark="#0099cc" bgcolor="#0099cc" >'
	cMsg+='		<p align="center"><font size="3" face="Courier New" color="#FFFFFF"><b>'+STR0208+'</b></font></td>'	// "JUSTIFICATIVA"
	cMsg+='	</tr>'
	cMsg+='	<tr><td height="26" bordercolor="#0099cc" bordercolorlight="#0099cc" bordercolordark="#0099cc" bgcolor="#FFFFFF" width="606">'
	cMsg+='		<p align="left">'+cMotivo+'</td>'
	cMsg+='	</tr>'
	cMsg+='</table>'
	cMsg+='<BR>'
	Endif

	If !Empty(cMensag)
	cMsg+='<table border=1 width="657" height="29" cellspacing="1" bordercolorlight="#0099cc" bordercolordark="#0099cc" bordercolor="#0099cc" bgcolor="#0099cc" >'
	cMsg+='	<tr><td width="606" height="1" align="left" bordercolor="#0099cc" bordercolorlight="#0099cc" bordercolordark="#0099cc" bgcolor="#0099cc" >'
	cMsg+='		<p align="center"><font size="3" face="Courier New" color="#FFFFFF"><b>'+OemToAnsi(STR0028)+'</b></font></td>'	// "MENSAGEM"
	cMsg+='	</tr>'
	cMsg+='	<tr><td height="26" bordercolor="#0099cc" bordercolorlight="#0099cc" bordercolordark="#0099cc" bgcolor="#FFFFFF" width="606">'
	cMsg+='		<p align="left">'+cMensag+'</td>'
	cMsg+='	</tr>'
	cMsg+='</table>'
	cMsg+='<BR>'
	Endif

	If nTipo == 1		// FNC
	QNCMAILFNC(@cMsg,,lRelac2)
	cMsg+='<BR>'
	cMsg+='<p style="margin-top: 0; margin-bottom: 0">'+OemToAnsi(STR0045)+'</p>'	// "Atenciosamente "
	cMsg+='<p style="margin-top: 0; margin-bottom: 0">'+PADR(QA_NUSR(cMatFil,cMatCod),40)+'</p>'
	cMsg+='<p style="margin-top: 0; margin-bottom: 0">'+QA_NDEPT(cMatDep,.T.,cMatFil)+'&nbsp;&nbsp;</p>'
	ElseIf nTipo == 2	// Plano de Acao
	QNCMAILACO(@cMsg,,lRelac1)
	cMsg+='<BR>'
	cMsg+='<p style="margin-top: 0; margin-bottom: 0">'+OemToAnsi(STR0045)+'</p>'	// "Atenciosamente "
	cMsg+='<p style="margin-top: 0; margin-bottom: 0">'+PADR(QA_NUSR(QI3->QI3_FILMAT,QI3->QI3_MAT),40)+'</p>'
	DbSelectArea("QAA")
	DbSetOrder(1)
	dbSeek(QI3->QI3_FILMAT+QI3->QI3_MAT)
	cMsg+='<p style="margin-top: 0; margin-bottom: 0">'+QA_NDEPT(QAA->QAA_CC,.T.,cMatFil)+'&nbsp;&nbsp;</p>'
	ElseIf nTipo == 3	// Etapas
	QNCMAILETA(@cMsg)
	cMsg+='<BR>'
	cMsg+='<p style="margin-top: 0; margin-bottom: 0">'+OemToAnsi(STR0045)+'</p>'	// "Atenciosamente "
	cMsg+='<p style="margin-top: 0; margin-bottom: 0">'+PADR(QA_NUSR(cMatFil,cMatCod),40)+'</p>'
	cMsg+='<p style="margin-top: 0; margin-bottom: 0">'+QA_NDEPT(cMatDep,.T.,cMatFil)+'&nbsp;&nbsp;</p>'
	Endif

cMsg+='<BR>'
cMsg+='<p><FONT size=2><EM>'+cRoda+'</EM></FONT></p>'
cMsg+='</body></html>'

dbSelectArea(cAliasA)
QI2->(dbSetOrder(nIdxQI2))
QI3->(dbSetOrder(nIdxQI3))
QI5->(dbSetOrder(nIdxQI5))
QI6->(dbSetOrder(nIdxQI6))
QI9->(dbSetOrder(nIdxQI9))
QI2->(dbGoto(nRecQI2))
QI3->(dbGoto(nRecQI3))
QI5->(dbGoto(nRecQI5))
QI6->(dbGoto(nRecQI6))
QI9->(dbGoto(nRecQI9))
QAA->(dbGoto(nRecQAA))

Return cMsg

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³QNCMAILFNC ³ Autor ³ Aldo Marini Junior   ³Data  ³ 29.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Monta o corpo do email para Ficha de Ocorrencias/Nao-Conform³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³QNCMAILFNC(cMsg,nTipo,lRelac)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Caracter onde sera armazenado o texto a enviar     ³±±
±±³          ³ ExpN1 = Numerico definindo o relacionamento em os tipos    ³±±
±±³          ³ ExpL1 = Logico definindo se havera relacionamento de tipos ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNCMAILFNC(cMsg,nTipo,lRelac)

Local bErrorBlock := Nil
Local cTxtDet     := ""
Local nA          := Nil
Local nPosQI9     := 0

DeFault lRelac    := .F.
DeFault nTipo     := 0

bErrorBlock    := ErrorBlock({|e| Help(NIL, NIL, "Help", NIL, STR0218 + e:Description, 1, 0, NIL, NIL, NIL, NIL, NIL,)})
//STR0218 - "Falha na elaboração do e-mail para envio: "
	
Begin Sequence
	cMsg+='<table border="1" width="657" height="32" bordercolor="#000000" bgcolor="#0099CC" cellspacing="1">'
	cMsg+='    <tr><td width="486" height="32" align="left">'
	cMsg+='        <p align="left"><font size="4" face="Courier New" color="#FFFFFF"><b>'+OemToAnsi(STR0042)+'</b></font></td>'	// "FICHA DE OCORRENCIAS/NAO-CONFORMIDADES"
	cMsg+='      <td width="181" height="32" align="left">'
	cMsg+='        <p align="center"><b><font face="Times New Roman" size="4" color="#FFFFFF">'
	cMsg+=            OemToAnsi(STR0050)+TransForm(QI2->QI2_FNC,PesqPict("QI2","QI2_FNC"))+"-"+QI2->QI2_REV+'</font></b></td>' 	// "No."
	cMsg+='    </tr></table>'
	cMsg+='<table border="1" width="657" height="2" bordercolor="#000080">'
	cMsg+='  <tr><td width="96" height="1" valign="top" align="left">'
	cMsg+='        <p style="margin-top: 0; margin-bottom: 0"><font size="2" face="Times New Roman"><b>'+OemToAnsi(STR0051)+'</b></font>'	// "Data de Registro"
	cMsg+='        <p style="margin-top: 0; margin-bottom: 0"><font size="2" face="Times New Roman">'+PADR(DTOC(QI2->QI2_REGIST),10)+'</font></td>'
	cMsg+='      <td width="108" height="1" valign="top" align="left">'
	cMsg+='        <p style="margin-top: 0; margin-bottom: 0"><font size="2" face="Times New Roman"><b>'+OemToAnsi(STR0052)+'</b></font>'	// "Data de Ocorrencia"
	cMsg+='        <p style="margin-top: 0; margin-bottom: 0"><font size="2" face="Times New Roman">'+PADR(DTOC(QI2->QI2_OCORRE),10)+'</font></td>'
	cMsg+='      <td width="152" height="1" valign="top" align="left">'
	cMsg+='        <p style="margin-top: 0; margin-bottom: 0"><font size="2" face="Times New Roman"><b>'+OemToAnsi(STR0053)+'</b></font>'	// "Data de Conclusao Prevista"
	cMsg+='        <p style="margin-top: 0; margin-bottom: 0"><font size="2" face="Times New Roman">'+PADR(DTOC(QI2->QI2_CONPRE),10)+'</font></td>'
	cMsg+='      <td width="116" height="1">'
	cMsg+='        <p style="margin-top: 0; margin-bottom: 0"><font size="2" face="Times New Roman"><b>'+OemToAnsi(STR0054)+'</b></font>'	// "Data Conclusao Real"
	cMsg+='        <p style="margin-top: 0; margin-bottom: 0"><font size="2" face="Times New Roman">'+PADR(DTOC(QI2->QI2_CONREA),10)+'</font></td>'
	cMsg+='      <td width="161" height="1">'
	cMsg+='        <p style="margin-top: 0; margin-bottom: 0"><font size="2" face="Times New Roman"><b>'+OemToAnsi(STR0055)+'</b></font>'	// "Status"

	If (Type("M->QI2_STATUS")) == "C"
		cMsg+='        <p style="margin-top: 0; margin-bottom: 0"><font size="2" face="Times New Roman">'+aStatus[Val(M->QI2_STATUS)]+'</font></td>'
	Else
		cMsg+='        <p style="margin-top: 0; margin-bottom: 0"><font size="2" face="Times New Roman">'+aStatus[Val(QI2->QI2_STATUS)]+'</font></td>'
	EndIf

	cMsg+='  </tr>'
	cMsg+='  <tr><td width="358" height="3" colspan="3" valign="top" align="left">'
	cMsg+='        <p style="margin-top: 0; margin-bottom: 0"><font size="2" face="Times New Roman"><b>'+OemToAnsi(STR0056)+'</b></font>'	// "Originador"
	cMsg+='        <p style="margin-top: 0; margin-bottom: 0"><font size="2" face="Times New Roman">'+PADR(QA_NUSR(QI2->QI2_FILMAT,QI2->QI2_MAT),40)+'</font></td>'
	cMsg+='      <td width="114" height="3">'
	cMsg+='        <p style="margin-top: 0; margin-bottom: 0"><font size="2" face="Times New Roman"><b>'+OemToAnsi(STR0057)+'</b></font>'	// "Prioridade"

	If (Type("M->QI2_PRIORI")) == "C"
		cMsg+='        <p style="margin-top: 0; margin-bottom: 0"><font size="2" face="Times New Roman">'+aPriori[Val(M->QI2_PRIORI)]+'</font></td>'
	Else
		cMsg+='        <p style="margin-top: 0; margin-bottom: 0"><font size="2" face="Times New Roman">'+aStatus[Val(QI2->QI2_PRIORI)]+'</font></td>'
	EndIf

	cMsg+='      <td width="161" height="3">'
	cMsg+='        <p style="margin-top: 0; margin-bottom: 0"><font size="2" face="Times New Roman"><b>'+OemToAnsi(STR0058)+'</b></font>'	// "Tipo"

	If (Type("M->QI2_TPFIC")) == "C"
		cMsg+='        <p style="margin-top: 0; margin-bottom: 0"><font size="2" face="Times New Roman">'+PADR(aTipo[Val(M->QI2_TPFIC)],32)+'</font></td>'
	Else
		cMsg+='        <p style="margin-top: 0; margin-bottom: 0"><font size="2" face="Times New Roman">'+PADR(aTipo[Val(QI2->QI2_TPFIC)],32)+'</font></td>'
	EndIf

	cMsg+='  </tr></table>'
	cMsg+='<p style="margin-top: 0; margin-bottom: 0">&nbsp;</p>'
	cMsg+='<p style="margin-top: 0; margin-bottom: 0">&nbsp;</p>'
	cMsg+='<p style="margin-top: 0; margin-bottom: 0"><b>'+OemToAnsi(STR0044)+'</b></p>'	// "Descricao Detalhada"
	cMsg+='<table border="1" width="658" bordercolor="#000080">'
	cMsg+='  <tr>'
	cMsg+='  <td width="665">'
	If (QI2->QI2_ORIGEM $ "QNC|QMT|QAD")
		cTxtDet := MSMM(QI2->QI2_DDETA)
	Else
		cTxtDet := MSMM(QI2->QI2_COMEN)
	Endif
	cMsg+='<p style="margin: 0"><font face="Courier New" size="2">'+cTxtDet+'</font>'
	cMsg+='</p></td></tr></table>'
	cMsg+='<p style="margin-top: 0; margin-bottom: 0">&nbsp;&nbsp;</p>'
	cMsg+='<p style="margin-top: 0; margin-bottom: 0"><b>'+OemToAnsi(STR0059)+'</b></p>'	// "Analise"
	cMsg+='<table border="1" width="658" bordercolor="#000080">'
	cMsg+='  <tr><td width="363">'
	cMsg+='        <p style="margin-top: 0; margin-bottom: 0"><b><font size="2" face="Times New Roman">'+OemToAnsi(STR0060)+'</font></b>'		// "Disposicao"
	cMsg+='        <p style="margin-top: 0; margin-bottom: 0"><font    size="1" face="Courier New">'+QI2->QI2_CODDIS+"-"+PADR(FQNCCHKDIS(QI2->QI2_CODDIS),40)+'</font></td>'
	cMsg+='      <td width="318">'
	cMsg+='        <p style="margin-top: 0; margin-bottom: 0"><b><font size="2" face="Times New Roman">'+OemToAnsi(STR0061)+'</font></b>' // "Origem"
	cMsg+='        <p style="margin-top: 0; margin-bottom: 0"><font    size="1" face="Courier New">'+QI2->QI2_CODORI+"-"+PADR(FQNCNTAB("3",QI2->QI2_CODORI),40)+'</font></td>'
	cMsg+='  </tr>'
	cMsg+='  <tr><td width="363">'
	cMsg+='        <p style="margin-top: 0; margin-bottom: 0"><b><font size="2" face="Times New Roman">'+OemToAnsi(STR0062)+'</font></b>'	// "Causa"
	cMsg+='        <p style="margin-top: 0; margin-bottom: 0"><font    size="1" face="Courier New">'+QI2->QI2_CODCAU+"-"+PADR(FQNCNTAB("1",QI2->QI2_CODCAU),40)+'</font></td>'
	cMsg+='      <td width="318">'
	cMsg+='        <p style="margin-top: 0; margin-bottom: 0"><b><font size="2" face="Times New Roman">'+OemToAnsi(STR0063)+'</font></b>'	// "Efeito"
	cMsg+='        <p style="margin-top: 0; margin-bottom: 0"><font    size="1" face="Courier New">'+QI2->QI2_CODEFE+"-"+PADR(FQNCNTAB("2",QI2->QI2_CODEFE),40)+'</font></td>'
	cMsg+='  </tr>'
	cMsg+='  <tr><td width="681" colspan="2">'
	cMsg+='        <p style="margin-top: 0; margin-bottom: 0"><b><font size="2" face="Times New Roman">'+OemToAnsi(STR0064)+'</font></b>'	// "Categoria FNC"
	cMsg+='        <p style="margin-top: 0; margin-bottom: 0"><font    size="1" face="Courier New">'+QI2->QI2_CODCAT+"-"+PADR(FQNCNTAB("4",QI2->QI2_CODCAT),50)+'</font></td>'
	cMsg+='  </tr>'
	cMsg+='</table>'
	cMsg+='<p style="margin-top: 0; margin-bottom: 0">&nbsp;&nbsp;</p>'

		If nTipo == 0
		nPosQI9:= QI9->(RecNo())
			If QI9->(dbSeek(QI2->QI2_FILIAL + QI2->QI2_FNC + QI2->QI2_REV))
			aPlanos := {}
				While !Eof() .And. QI9->QI9_FILIAL + QI9->QI9_FNC + QI9->QI9_REVFNC == QI2->QI2_FILIAL + QI2->QI2_FNC + QI2->QI2_REV
					IF QI3->(dbSeek(QI9->QI9_FILIAL+Right(QI9->QI9_CODIGO,4)+QI9->QI9_CODIGO+QI9->QI9_REV))
					aAdd(aPlanos,{ QI3->QI3_CODIGO,QI3->QI3_REV,QI3->QI3_FILMAT,QI3->QI3_MAT,QI3->QI3_ABERTU,QI3->QI3_ENCPRE,QI3->QI3_ENCREA })
					Endif
				QI9->(dbSkip())
				Enddo

				If Len(aPlanos) > 0
				cMsg+='<p style="margin-top: 0; margin-bottom: 0"><b><font face="Times New Roman">'+OemToAnsi(STR0065)+'</font></b></p>'	// "Plano de Acao Relacionado"
				cMsg+='<table border="1" width="658" bordercolor="#000080" height="78">'
				cMsg+='  <tr><td width="92"  height="20"><b><font size="1">'+OemToAnsi(STR0066)+'</b></font></td>'	// "Plano de Acao Rv"
				cMsg+='      <td width="271" height="20"><b><font size="1">'+OemToAnsi(STR0056)+'</font></b></td>'	// "Originador"
				cMsg+='      <td width="74"  height="20"><b><font size="1">'+OemToAnsi(STR0067)+'</font></b></td>'	// "Data Abertura"
				cMsg+='      <td width="102" height="20"><b><font size="1">'+OemToAnsi(STR0068)+'</font></b></td>'	// "Dt. Encerr.Previsto"
				cMsg+='      <td width="85"  height="20"><b><font size="1">'+OemToAnsi(STR0069)+'</font></b></td>'	// "Dt. Encerr. Real"
				cMsg+='  </tr>'
					For nA:=1 to Len(aPlanos)
					cMsg+='  <tr><td width="92"  align="center" height="15"><font size="1">'+Transform(aPlanos[nA,1],"@r 999999/9999")+" "+aPlanos[nA,2]+'</font></td>'
					cMsg+='      <td width="271" height="15"><font size="1">'+Padr(QA_NUSR(aPlanos[nA,3],aPlanos[nA,4]),30)+'</font></td>'
					cMsg+='      <td width="74"  align="center" height="15"><font size="1">'+PADR(DTOC(aPlanos[nA,5]),10)+'</font></td>'
					cMsg+='      <td width="102" align="center" height="15"><font size="1">'+PADR(DTOC(aPlanos[nA,6]),10)+'</font></td>'
					cMsg+='      <td width="85"  align="center" height="15"><font size="1">'+PADR(DTOC(aPlanos[nA,7]),10)+'</font></td>'
					cMsg+='  </tr>'
					Next
				cMsg+='</table>'
				Endif
			QI9->(DbGoTo(nPosQI9))
			Endif
		Endif
End Sequence
ErrorBlock(bErrorBlock)

Return cMsg

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³QNCMAILACO ³ Autor ³ Aldo Marini Junior   ³Data  ³ 29.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Monta o corpo do email para Plano de Acao                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³QNCMAILACO(cMsg,nTipo,lRelac)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Caracter onde sera armazenado o texto a enviar     ³±±
±±³          ³ ExpN1 = Numerico definindo o relacionamento em os tipos    ³±±
±±³          ³ ExpL1 = Logico definindo se havera relacionamento de tipos ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNCMAILACO(cMsg,nTipo,lRelac)
Local nA
Local lFnc     := .T. 

DeFault nTipo  := 0
DeFault lRelac := .T.

cMsg+='<table border="1" width="657" height="32" bordercolor="#000000" bgcolor="#0099CC" cellspacing="1">'
cMsg+='    <tr><td width="486" height="32" align="left">'
cMsg+='        <p align="left"><font size="4" face="Courier New" color="#FFFFFF"><b>'+OemToAnsi(STR0049)+'</b></font></td>'	// "PLANO DE ACAO"
cMsg+='      <td width="181" height="32" align="left">'
cMsg+='        <p align="center"><b><font face="Times New Roman" size="4" color="#FFFFFF">'
cMsg+=            OemToAnsi(STR0050)+TransForm(QI3->QI3_CODIGO,PesqPict("QI3","QI3_CODIGO"))+"-"+QI3->QI3_REV+'</font></b></td>' 	// "No."
cMsg+='    </tr></table>'
cMsg+='<A NAME="TOP"></A>'
cMsg+='<table border="1" width="657" height="2" bordercolor="#000080">'
cMsg+='  <tr><td width="80" height="1" valign="top" align="left">'
cMsg+='        <p style="margin-top: 0; margin-bottom: 0"><font size="2" face="Times New Roman"><b>'+OemToAnsi(STR0067)+'</b></font>'	// "Data Abertura"
cMsg+='        <p style="margin-top: 0; margin-bottom: 0"><font size="2" face="Times New Roman">'+PADR(DTOC(QI3->QI3_ABERTU),10)+'</font></td>'
cMsg+='      <td width="112" height="1" valign="top" align="left">'
cMsg+='        <p style="margin-top: 0; margin-bottom: 0"><font size="2" face="Times New Roman"><b>'+OemToAnsi(STR0068)+'</b></font>'	// "Dt. Encerr.Previsto"
cMsg+='        <p style="margin-top: 0; margin-bottom: 0"><font size="2" face="Times New Roman">'+PADR(DTOC(QI3->QI3_ENCPRE),10)+'</font></td>'
cMsg+='      <td width="112" height="1" valign="top" align="left">'
cMsg+='        <p style="margin-top: 0; margin-bottom: 0"><font size="2" face="Times New Roman"><b>'+OemToAnsi(STR0069)+'</b></font>'	// "Dt. Encerr. Real"
cMsg+='        <p style="margin-top: 0; margin-bottom: 0"><font size="2" face="Times New Roman">'+PADR(DTOC(QI3->QI3_ENCREA),10)+'</font></td>'
cMsg+='      <td width="166" height="1">'
cMsg+='        <p style="margin-top: 0; margin-bottom: 0"><font size="2" face="Times New Roman"><b>'+OemToAnsi(STR0070)+'</b></font>'	// "Tipo de Acao"
cMsg+='        <p style="margin-top: 0; margin-bottom: 0"><font size="2" face="Times New Roman">'+aTipQI3[Val(QI3->QI3_TIPO)]+'</font></td>'
cMsg+='      <td width="161" height="1">'
cMsg+='        <p style="margin-top: 0; margin-bottom: 0"><font size="2" face="Times New Roman"><b>'+OemToAnsi(STR0055)+'</b></font>'	// "Status"
cMsg+='        <p style="margin-top: 0; margin-bottom: 0"><font size="2" face="Times New Roman">'+aStatus[Val(QI3->QI3_STATUS)]+'</font></td>'
cMsg+='  </tr>'
cMsg+='  <tr><td height="5" colspan="5" valign="top" align="left">'
cMsg+='        <p style="margin-top: 0; margin-bottom: 0"><font size="2" face="Times New Roman"><b>'+OemToAnsi(STR0071)+'</b></font>'	// "Responsavel"
cMsg+='        <p style="margin-top: 0; margin-bottom: 0"><font size="2" face="Times New Roman">'+PADR(QA_NUSR(QI3->QI3_FILMAT,QI3->QI3_MAT),40)+'</font></td>'
cMsg+='  </tr></table>'
cMsg+='<p style="margin-top: 0; margin-bottom: 0">&nbsp;</p>'

	If lRelac
		If QI9->(dbSeek(QI3->QI3_FILIAL + QI3->QI3_CODIGO + QI3->QI3_REV))
			IF QI2->(dbSeek(QI9->QI9_FILIAL+Right(QI9->QI9_FNC,4)+QI9->QI9_FNC+QI9->QI9_REVFNC))
			cMsg+='<P align=left style="MARGIN-BOTTOM: 0px; MARGIN-TOP: 0px"><FONT size=1 face="Arial">'
			cMsg+='<A href="#FNC">'+OemToAnsi(STR0025)+'</A></FONT></P>'	// "FNC Relacionada"
			Endif
		Endif
	Endif

cTxtDet := MSMM(QI3->QI3_PROBLE)
	If !Empty(AllTrim(cTxtDet))
	cMsg+='<p style="margin-top: 0; margin-bottom: 0">&nbsp;</p>'
	cMsg+='<p style="margin-top: 0; margin-bottom: 0"><b>'+OemToAnsi(STR0044)+'</b></p>'	// "Descricao Detalhada"
	cMsg+='<table border="1" width="658" bordercolor="#000080">'
	cMsg+='  <tr>'
	cMsg+='  <td width="665">'
	cMsg+='<p style="margin: 0"><font face="Courier New" size="2">'+cTxtDet+'</font>'
	cMsg+='</p></td></tr></table>'
	cMsg+='<p style="margin-top: 0; margin-bottom: 0">&nbsp;&nbsp;</p>'
	Endif
    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime as Etapas das Acoes                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF QI5->(dbSeek( QI3->QI3_FILIAL + QI3->QI3_CODIGO + QI3->QI3_REV ))
	aEtapas := {}
		While !Eof() .And. QI5->QI5_FILIAL + QI5->QI5_CODIGO + QI5->QI5_REV == QI3->QI3_FILIAL + QI3->QI3_CODIGO + QI3->QI3_REV
		aAdd(aEtapas,{	QI5->QI5_FILMAT,QI5->QI5_MAT,QI5->QI5_PRAZO,QI5->QI5_REALIZ,QI5->QI5_DESCRE})
		QI5->(dbSkip())
		Enddo

		If Len(aEtapas) > 0
		cMsg+='<p style="margin-top: 0; margin-bottom: 0"><b><font face="Times New Roman">'+OemToAnsi(STR0074)+'</font></b></p>'	// "Acoes"
		cMsg+='<table border="1" width="658" bordercolor="#000080" height="78">'
		cMsg+='  <tr><td width="241"  height="20"><b><font size="1">'+OemToAnsi(STR0071)+'</b></font></td>'	// "Responsavel"
		cMsg+='      <td width="62" height="20"><b><font size="1">'+OemToAnsi(STR0072)+'</font></b></td>'	// "Previsao"
		cMsg+='      <td width="62" height="20"><b><font size="1">'+OemToAnsi(STR0073)+'</font></b></td>'	// "Conclusao"
		cMsg+='      <td width="281" height="20"><b><font size="1">'+OemToAnsi(STR0043)+'</font></b></td>' // "Descricao"
		cMsg+='  </tr>'

			For nA:=1 to Len(aEtapas)
			cMsg+='  <tr><td width="241" height="15"><font size="1">'+PADR(QA_NUSR(aEtapas[nA,1],aEtapas[nA,2]),30)+'</font></td>'
			cMsg+='      <td width="62"  height="15"><font size="1">'+PADR(DTOC(aEtapas[nA,3]),10)+'</font></td>'
			cMsg+='      <td width="62"  height="15"><font size="1">'+PADR(DTOC(aEtapas[nA,4]),10)+'</font></td>'
			cMsg+='      <td width="281" height="15"><font size="1">'+PADR(aEtapas[nA,5],40)+'</font></td>'
			cMsg+='  </tr>'
			Next
	
		cMsg+='</table>'
		cMsg+='<p style="margin-top: 0; margin-bottom: 0">&nbsp;&nbsp;</p>'
		Endif
	Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime as Fichas de Ocorrencias/Nao-Conformidades Relacionadas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRelac
		If QI9->(dbSeek(QI3->QI3_FILIAL + QI3->QI3_CODIGO + QI3->QI3_REV))
			While !Eof() .And. QI9->QI9_FILIAL + QI9->QI9_CODIGO + QI9->QI9_REV == QI3->QI3_FILIAL + QI3->QI3_CODIGO + QI3->QI3_REV
				IF QI2->(dbSeek(QI9->QI9_FILIAL+Right(QI9->QI9_FNC,4)+QI9->QI9_FNC+QI9->QI9_REVFNC))
					IF lFnc
					cMsg+='<P align=left style="MARGIN-BOTTOM: 0px; MARGIN-TOP: 0px"><FONT size=1 face="Arial">'
					cMsg+='<A NAME="FNC" href="#TOP">Back</A></FONT></P>'
					cMsg+='<p style="margin-top: 0; margin-bottom: 0">&nbsp;</p>'
					cMsg+='<p style="margin-top: 0; margin-bottom: 0"><b>'+OemToAnsi(STR0026)+'</b></p>' // "Fichas de Ocorrencia/Nao-Conformidade Relacionadas"
                    lFnc := .F.
					Endif
				QNCMAILFNC(@cMsg,nTipo)
				Endif
			QI9->(dbSkip())
			Enddo
		Endif
	Endif

Return cMsg

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³QNCMAILETA ³ Autor ³ Aldo Marini Junior   ³Data  ³ 29.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Monta o corpo do email para Plano de Acao                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³QNCMAILETA(cMsg,nTipo,lRelac)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Caracter onde sera armazenado o texto a enviar     ³±±
±±³          ³ ExpN1 = Numerico definindo o relacionamento em os tipos    ³±±
±±³          ³ ExpL1 = Logico definindo se havera relacionamento de tipos ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNCMAILETA(cMsg,nTipo,lRelac)
Local nA
Local lFnc     := .T.
Local aCBox    := {"  0%"," 25%"," 50%"," 75%","100%"}
DeFault nTipo  := 0
DeFault lRelac := .T.


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime as Etapas das Acoes                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF QI5->(dbSeek( QI3->QI3_FILIAL + QI3->QI3_CODIGO + QI3->QI3_REV ))
	aEtapas := {}
		While !Eof() .And. QI5->QI5_FILIAL + QI5->QI5_CODIGO + QI5->QI5_REV == QI3->QI3_FILIAL + QI3->QI3_CODIGO + QI3->QI3_REV  //.And. !(QI5->QI5_STATUS $ "4|5")
			If !(QI5->QI5_STATUS $ "4|5")
		aAdd(aEtapas,{ QI5->QI5_TPACAO,AllTrim(QI5->QI5_DESCRE),AllTrim(MSMM(QI5->QI5_DESCCO)),;
		               AllTrim(MSMM(QI5->QI5_DESCOB)),QI5->QI5_PEND,QI5->QI5_FILMAT,QI5->QI5_MAT,;
		               QI5->QI5_PRAZO,QI5->QI5_STATUS,QI5->QI5_REALIZ})
			EndIf
		QI5->(dbSkip())
		Enddo

		If Len(aEtapas) > 0
	
		cMsg+='<A NAME="TOP"></A>'
		cMsg+='<table border="1" width="657" height="32" bordercolor="#000000" bgcolor="#0099CC" cellspacing="1">'
		cMsg+='    <tr><td width="486" height="32" align="left">'
		cMsg+='          <p align="left"><font size="4" face="Courier New" color="#FFFFFF"><b>'+OemToAnsi(STR0019)+'</b></font></p></td>'	// "ETAPAS - PLANO DE ACAO"
		cMsg+='        <td width="181" height="32" align="left">'
		cMsg+='          <p align="center"><b><font face="Times New Roman" size="4" color="#FFFFFF">'
		cMsg+=            OemToAnsi(STR0050)+TransForm(QI3->QI3_CODIGO,PesqPict("QI3","QI3_CODIGO"))+"-"+QI3->QI3_REV+'</font></b></p></td>' 	// "No."
		cMsg+='    </tr>'
		cMsg+='</table>'
		cMsg+='<table border="1" width="657" height="2" bordercolor="#000080">'
		cMsg+='  <tr><td width="50%" height="1" valign="top" align="left">'  
		cMsg+='        <p style="margin-top: 0; margin-bottom: 0"><font size="2" face="Times New Roman"><b>'+OemToAnsi(STR0095)+'</b></font>'// "Data de Encerramento Previsto"
		cMsg+='        <p style="margin-top: 0; margin-bottom: 0"><font size="2" face="Times New Roman">'+PADR(DTOC(QI3->QI3_ENCPRE),10)+'</font></td>'
		cMsg+='      <td width="108" height="1" valign="top" align="left">'
		cMsg+='        <p style="margin-top: 0; margin-bottom: 0"><font size="2" face="Times New Roman"><b>'+OemToAnsi(STR0096)+'</b></font>'	// "Status da acao"
        cMsg+='        <p style="margin-top: 0; margin-bottom: 0"><font size="2" face="Times New Roman">'+aStatus[Val(QI3->QI3_STATUS)]+'</font></td>'
		cMsg+='  </tr></table>'                                        

			If QI9->(dbSeek(QI3->QI3_FILIAL + QI3->QI3_CODIGO + QI3->QI3_REV))
				IF QI2->(dbSeek(QI9->QI9_FILIAL+Right(QI9->QI9_FNC,4)+QI9->QI9_FNC+QI9->QI9_REVFNC))
				cMsg+='<P align=left style="MARGIN-BOTTOM: 0px; MARGIN-TOP: 0px"><FONT size=1 face="Arial">'
				cMsg+='<A href="#FNC">'+OemToAnsi(STR0025)+'</A></FONT></P>'	// "FNC Relacionada"
				Endif
			Endif

		cTxtDet := MSMM(QI3->QI3_PROBLE)
			If !Empty(AllTrim(cTxtDet))
			cMsg+='<p style="margin-top: 0; margin-bottom: 0">&nbsp;</p>'
			cMsg+='<p style="margin-top: 0; margin-bottom: 0"><b>'+OemToAnsi(STR0020)+'</b></p>'	// "Descricao Detalhada Plano de Acao"
			cMsg+='<table border="1" width="658" bordercolor="#000080">'
			cMsg+='  <tr><td width="665">'
			cMsg+='     <p style="margin: 0"><font face="Courier New" size="2">'+cTxtDet+'</font></p></td>'
			cMsg+='  </tr>'
			cMsg+='</table>'
			cMsg+='<p style="margin-top: 0; margin-bottom: 0">&nbsp;&nbsp;</p>'
			Endif

		cMsg+='<p style="margin-top: 0; margin-bottom: 0">&nbsp;</p>'
		cMsg+='<p style="margin-top: 0; margin-bottom: 0"><b>'+OemToAnsi(STR0021)+'</b></p>'	// "Etapas/Passos do Plano de Acao"
		cMsg+='<table border="1" width="657" height="32" cellspacing="1">'
			
			For nA:=1 to Len(aEtapas)
				If !Empty(aEtapas[nA,2]) .Or. aEtapas[nA,5] == "S"	// Verificar Descricao Resumida
				cMsg+='<tr><td>'
					If aEtapas[nA,5] == "S"	// Etapa Atual
					cMsg+='<p style="margin: 0"><font face="Courier New" size="2" color="#FF0000"><B><U>'
					Else
					cMsg+='<p style="margin: 0"><font face="Courier New" size="2"><B><U>'
					Endif
				cMsg+= aEtapas[nA,1]+"-"+FQNCDSX5("QD",aEtapas[nA,1])+'</U>'
					If aEtapas[nA,5] == "S"	// Etapa Atual
					cMsg+= Space(5)+OemToAnsi(STR0027)	// "(Etapa Atual)"
					Endif
				
				cMsg+='</p></B></font>'                                     				
				cMsg+='<BR>'
				cMsg+='<p style="margin-top: 0; margin-bottom: 0"><b>'+OemToAnsi(STR0071)+" </b>"+aEtapas[nA,6]+"-"+aEtapas[nA,7]+" "+PADR(QA_NUSR(aEtapas[nA,6],aEtapas[nA,7]),30)+'</p>'	// "Responsavel"
				cMsg+='<p style="margin-top: 0; margin-bottom: 0"><b>'+OemToAnsi(STR0022)+" </b>"+aEtapas[nA,2]+'</p>'	// "Descricao Resumida:"
                cMsg+='<p style="margin-top: 0; margin-bottom: 0"><b>'+OemToAnsi(STR0097)+" </b>"+DTOC(aEtapas[nA,8])+'</p>'// "Prazo de execucao:"
                cMsg+='<p style="margin-top: 0; margin-bottom: 0"><b>'+OemToAnsi(STR0098)+" </b>"+DTOC(aEtapas[nA,10])+'</p>'// "Data de Realizacao:"                
				cMsg+='<p style="margin-top: 0; margin-bottom: 0"><b>'+OemToAnsi(STR0096)+" </b>"+aCBox[Val(aEtapas[nA,9])+1]+'</p>' // "Status da acao:" 
                                                                                    
		
					If !Empty(aEtapas[nA,3])
					cMsg+='<BR>'
					cMsg+='<p style="margin-top: 0; margin-bottom: 0"><b>'+OemToAnsi(STR0023)+" </b>"+aEtapas[nA,3]+'</p>'	// "Descricao Completa:"
					Endif
					If !Empty(aEtapas[nA,4])
					cMsg+='<BR>'
					cMsg+='<p style="margin-top: 0; margin-bottom: 0"><b>'+OemToAnsi(STR0024)+" </b>"+aEtapas[nA,4]+'</p>'	// "Observacao:"
					Endif
				cMsg+='</td></tr>'
				Endif
			Next
		cMsg+='</table>'
		cMsg+='<BR>'

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	 	//³ Imprime as Fichas de Ocorrencias/Nao-Conformidades Relacionadas ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If QI9->(dbSeek(QI3->QI3_FILIAL + QI3->QI3_CODIGO + QI3->QI3_REV))
				While !Eof() .And. QI9->QI9_FILIAL + QI9->QI9_CODIGO + QI9->QI9_REV == QI3->QI3_FILIAL + QI3->QI3_CODIGO + QI3->QI3_REV
					IF QI2->(dbSeek(QI9->QI9_FILIAL+Right(QI9->QI9_FNC,4)+QI9->QI9_FNC+QI9->QI9_REVFNC))
						IF lFnc
 					    cMsg+='<P align=left style="MARGIN-BOTTOM: 0px; MARGIN-TOP: 0px"><FONT size=1 face="Arial">'
						cMsg+='<A NAME="FNC" href="#TOP">Back</A></FONT></P>'
						cMsg+='<p style="margin-top: 0; margin-bottom: 0">&nbsp;</p>'
						cMsg+='<p style="margin-top: 0; margin-bottom: 0"><b>'+OemToAnsi(STR0026)+'</b></p>' // "Fichas de Ocorrencia/Nao-Conformidade Relacionadas"
						lFnc := .F.
						Endif
					QNCMAILFNC(@cMsg,nTipo)
					Endif
				QI9->(dbSkip())
				Enddo
			Endif
		Endif

	Endif

Return cMsg

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNCEDMOTREV³ Autor ³ Aldo Marini Junior   ³ Data ³ 04/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para Edicao de Campos memo fora da Enchoice/Getdad³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNCEDMOTREV(nOpc,cTexto,cTitulo,nTam)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Tipo do Cadastro(1-Plano de Acao,2-FNC)            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QNCEDMOTREV(nOpc,cTexto,cTitulo,nTam)
Local oFont, oDlg, oTexto
Local nLargJan  := 0
Local nLargMemo := 0
Local cTextoOld := ""
Local nOpcao    := 2

Default nOpc    := 2
Default cTexto  := ""
Default cTitulo := OemToAnsi(STR0044)  // "Descricao Detalhada"
Default nTam    := 80

nTam := If(nTam < Len(Trim(cTitulo)),Len(Trim(cTitulo))+2,nTam)
nLargJan := (nTam * 6)+40
cTextoOld := cTexto

DEFINE FONT oFont NAME "Courier New" SIZE 6,0
 
DEFINE MSDIALOG oDlg TITLE OemToAnsi(cTitulo) FROM 15,1 TO 196,nLargJan PIXEL FONT oFont
 
	If nTam > 50
	nLargMemo := round(3.08 * nTam,0)+7
	Else
	nLargMemo := round(3.10 * nTam,0)+8
	EndIf
 
@ 6,4 GET oTexto VAR cTexto MEMO READONLY SIZE nLargMemo,60 PIXEL OF oDlg NO VSCROLL
oTexto:oFont:=oFont
	If nOpc == 3 .Or. nOpc == 4
	oTexto:lReadOnly := .F.
	Else
	oTexto:lReadOnly := .T.
	Endif

DEFINE SBUTTON FROM 75,2  TYPE 1 PIXEL ;
       ACTION (If(!Empty(cTexto),(nOpcao:=1,oDlg:End()),MsgAlert(OemToAnsi(STR0075)))) ;	// "Devera ser preenchido o Motivo da Revisao"
       ENABLE OF oDlg
       
DEFINE SBUTTON FROM 75,32 TYPE 2 PIXEL ACTION (nOpcao:=2,oDlg:End()) ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTERED

	If nOpcao == 2
	cTexto := cTextoOld
	Endif

Return (nOpcao==1)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FQNCDESETA ³ Autor ³ Aldo Marini Junior   ³ Data ³ 01/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa generico para Buscar descricao da Etapa/Passo     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FQNCDESETA(cCodigo)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da Etapa/Passo                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FQNCDESETA(cCodigo)
Local cDesc := Space(30)

	If QID->(dbSeek(xFilial("QID")+cCodigo))
	cDesc := QID->QID_DESCTP
	Endif

Return cDesc

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FQNCANEXO  ³ Autor ³ Eduardo de Souza    ³ Data ³ 04/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta Tela com os Anexos da FNC / Plano de Acao            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FQNCANEXO()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQNC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FQNCANEXO(cAlias,nOpc,cStatus,aColAnx)

	Local oGet
	Local oDlg
	Local aButtons	:= {}
	Local aAlter  	:= {}
	Local lAlter  	:= .F.
	Local nOpcao  	:= 0
	Local lRet		:= .T.
	Local lTMKPMS   := If(GetMv("MV_QTMKPMS",.F.,1) == 1,.F.,.T.)//Integracao do QNC com TMK e PMS: 1-Sem integracao,2-TMKxQNC,3-QNCxPMS,4-TMKxQNCxPMS ³


	If lTMKPMS
		Private aRotina := { {"","",0,1}, {"","",0,2}, {"","",0,3},{"","",0,4}}
		If Type("cMatFil") == "U"
			cMatFil := xFilial("QAA")
			cMatCod :=	QNCRetQAA(cUserName)
		Else
			cMatCod :=	QNCRetQAA(cUserName)
		EndIf
	Endif

	If cAlias == "QIE"
		Private cFilQIE   := cMatFil
		Private cStatusQIE:= cStatus
	Else
		Private cFilQIF   := cMatFil
		Private cStatusQIF:= cStatus
	EndIf
	If Type("cMatFil") == "U"
		cMatFil := QNCRetQAA(cUserName)
	Else
		QNCRetQAA(cUserName)
	EndIf

	Private aHeader   := {}
	Private aCols     := {}
	Private nUsado    := 0
	Private cAliasAnex:= cAlias
	Private nPosFil   := 0
	Private nPosMat   := 0
	Default aColAnx	  := {}

	n:= 1

	DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0076) FROM 000,000 TO 315,625 OF oMainWnd PIXEL // "Documento Anexo"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta vetor aHeader a ser utilizado na getdados              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QNCFGet(nOpc,cAliasAnex)
	IF Len(aColAnx)!=0
		aCols   := Aclone(aColAnx)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Campos que podem ser Alterados		  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cAliasAnex == "QIE"
		Aadd(aAlter,"QIE_TIPO"  )
		Aadd(aAlter,"QIE_ETAPA" )
		Aadd(aAlter,"QIE_DESCR" )
		Aadd(aAlter,"QIE_PEND" )
		If lTMKPMS
			Aadd(aAlter,"QIE_TIPODC" )
			Aadd(aAlter,"QIE_PEND" )
		Endif
	ElseIf cAliasAnex == "QIF"
		Aadd(aAlter,"QIF_DESCR" )
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se pode ser Alterado / Deletado ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc == 3 .Or. nOpc == 4
		lAlter:= .T.
	EndIf

	oGet := MSGetDados():New(015,002,155,312,nOpc,"QNCALinOk",," ",lAlter,aAlter,,,,,,,If(lAlter,"QNCVdRAnex",))
	oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	aAdd(aButtons,{"SDUPROP", {|| lRet:=QNCVRFANEXO(nOpc) }, OemToAnsi(STR0076),OemToAnsi(STR0077) } )  //"Documento Anexo"  //"Doc.Anexo"

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| IF(QNCATudOk(lAlter),(nOpcao:=1,aHeadAne := aClone(aHeader),aColAnx  := Aclone(aCols),oDlg:End()),"") },{|| oDlg:End()},,aButtons) CENTERED


Return(aColAnx)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ QNCALinOk ³ Autor ³ Eduardo de Souza     ³ Data ³ 04/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consistencia para mudanca/inclusao de linhas               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNCALinOk                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAQNC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNCALinOk

Local lRet   := .T.
Local nPos01 := Ascan(aHeader,{ |X| Upper( Alltrim( X[ 2 ] ) ) = "QIF_DESCR" })
Local nPos02 := Ascan(aHeader,{ |X| Upper( Alltrim( X[ 2 ] ) ) = "QIF_ANEXO" })
Local nPos03 := Ascan(aHeader,{ |X| Upper( Alltrim( X[ 2 ] ) ) = "QIE_ETAPA" })
Local nPos04 := Ascan(aHeader,{ |X| Upper( Alltrim( X[ 2 ] ) ) = "QIE_TIPO"  })
Local nPos06 := Ascan(aHeader,{ |X| Upper( Alltrim( X[ 2 ] ) ) = "QIE_ANEXO" })
Local nPos07 := Ascan(aHeader,{ |X| Upper( Alltrim( X[ 2 ] ) ) = "QIE_TIPODC" })
Local lQNCTPMS    := If(GetMv("MV_QTMKPMS",.F.,1) == 1,.F.,.T.)

	If aCols[n,nUsado+1] == .F.
		If nPos01 <> 0 .Or. nPos02 <> 0
			If Empty(Acols[n,nPos01]) .Or. Empty(Acols[n,nPos02])
			Help(" ",1,"QDOBRIG") // "Existem campos obrigatorios nao preenchidos"
		   	lRet:= .F.
			EndIf
		ElseIf nPos03 <> 0 .Or. nPos04 <> 0 .Or. nPos06 <> 0
			If Empty(Acols[n,nPos03]) .Or. Empty(Acols[n,nPos04]) .Or. Empty(Acols[n,nPos06])
			Help(" ",1,"QDOBRIG") // "Existem campos obrigatorios nao preenchidos"
			lRet:= .F.	
			EndIf
		EndIf

	//Caso exista integracao entre QNC x PMS / QNC x TMK / QNC x PMS x TMK
		If nPos07 <> 0
			If lRet .and. lQNCTPMS
				If Empty(aCols[n,nPos07])
				MessageDlg(STR0156) // "Campo obrigatorio. Deve-se informar o campo Tipo de Documento associado."
				lRet := .F.
				Endif
			Endif
		EndIf
	Endif
Return lRet



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ QNCATudOk ³ Autor ³ Telso Carneiro       ³ Data ³15/09/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consistencia para mudanca/inclusao de linhas               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNCATudOk                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAQNC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNCATudOk(lAlter)

Local lRet   := .T.
Local nPos01 := Ascan(aHeader,{ |X| Upper( Alltrim( X[ 2 ] ) ) = "QIF_DESCR" })
Local nPos02 := Ascan(aHeader,{ |X| Upper( Alltrim( X[ 2 ] ) ) = "QIF_ANEXO" })
Local nPos03 := Ascan(aHeader,{ |X| Upper( Alltrim( X[ 2 ] ) ) = "QIE_ETAPA" })
Local nPos04 := Ascan(aHeader,{ |X| Upper( Alltrim( X[ 2 ] ) ) = "QIE_TIPO"  })
Local nPos05 := Ascan(aHeader,{ |X| Upper( Alltrim( X[ 2 ] ) ) = "QIE_DESCR" })
Local nPos06 := Ascan(aHeader,{ |X| Upper( Alltrim( X[ 2 ] ) ) = "QIE_ANEXO" })
Local nPos07 := Ascan(aHeader,{ |X| Upper( Alltrim( X[ 2 ] ) ) = "QIE_TIPODC"})
Local nPos08 := Ascan(aHeader,{ |X| Upper( Alltrim( X[ 2 ] ) ) = "QIE_PEND"  })
Local nPos09 := Ascan(aHeader,{ |X| Upper( Alltrim( X[ 2 ] ) ) = "QIE_DESETA"})
Local nIc	 := 0
Local nX     := 0
Local lQNCTPMS    := If(GetMv("MV_QTMKPMS",.F.,1) == 1,.F.,.T.)
Local cEtapas := ""
Local lEtapa  := .F.

DEFAULT nRecnoQI3 := 0

	IF lAlter
		For nIc:=1 To Len(aCols)
		lEtapa := .F.
			If aCols[nIc,Len(aHeader)+1] == .F.
		
				If AllTrim(FunName()) $ "QNCA040,QNCA030"
					If nPos01 <> 0 .Or. nPos02 <> 0
						If Empty(Acols[nIc,nPos01]) .Or. Empty(Acols[nIc,nPos02])
							Help(" ",1,"QDOBRIG") // "Existem campos obrigatorios nao preenchidos"
							lRet:= .F.
						EndIf
					ElseIf nPos03 <> 0 .Or. nPos04 <> 0 .Or. nPos05 <> 0 .Or. nPos06 <> 0
						If Empty(Acols[nIc,nPos03]) .Or. Empty(Acols[nIc,nPos04]) .Or. Empty(Acols[nIc,nPos05]) .Or.;
							Empty(Acols[nIc,nPos06])
							Help(" ",1,"QDOBRIG") // "Existem campos obrigatorios nao preenchidos"
							lRet:= .F.
						EndIf
					EndIf
				ElseIf AllTrim(FunName()) $ "QNCA050,QNCLOAD"
					If nPos05 <> 0
						If Empty(Acols[nIc,nPos05])
							Help(NIL, NIL, AllTrim(RetTitle("QIE_DESCR")), NIL, STR0212+AllTrim(RetTitle("QIE_DESCR"))+STR0213, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0214+AllTrim(RetTitle("QIE_DESCR"))+STR0215+Acols[nIc][1]+"."})
							lRet:= .F. //Título: DESCRICAO ### Problema: Campo Descricao não preenchico. ### Solução: Preencha o campo Descricao da linha xxx
							Exit
						EndIf
					EndIf
				EndIf
			
				If nPos08 <> 0
					If Empty(Acols[nIc,nPos08]) .And. Alltrim(Acols[nIc,nPos04]) == "2"
						Help(NIL, NIL, STR0005, NIL, STR0210, 1, 0, NIL, NIL, NIL, NIL, NIL,)
						lRet := .F.
					Else
						IF EMPTY(nRecnoQI3)
							QI5->(DbSetOrder(1))
							QI5->(DbSeek(xFilial("QI5")+M->QI3_CODIGO+M->QI3_REV))
						ELSE
							QI3->(DBGOTO(nRecnoQI3))

							QI5->(DbSetOrder(1))
							QI5->(DbSeek(xFilial("QI5")+M->QI3_CODIGO+M->QI3_REV))
						ENDIF
						While QI5->(!EoF()) .And. QI5->QI5_CODIGO == QI3->QI3_CODIGO .And. QI5->QI5_REV == QI3->QI3_REV
							If Alltrim(QI5->QI5_TPACAO) == Alltrim(Acols[nIc,nPos08])
								lEtapa := .T.
								Exit
							EndIF
							QI5->(DbSkip())
						EndDo
					
						If !lEtapa .And. Type("aQI5") == "A"
							For nX:= 1 to Len(aQI5)
								If aQi5[nX][2] == Alltrim(Acols[nIc,nPos08])
							  		lEtapa := .T.
								EndIF
							Next
						EndIf
					
						If !lEtapa
							cEtapas += CHR(13)+CHR(10) + Alltrim(Acols[nIc,nPos08]) + " - " + Alltrim(Acols[nIc,nPos09])
						EndIf
					EndIf
				EndIf
			EndIf
		Next
	
		If !Empty(cEtapas)
			lRet:= .F.
			cEtapas := CHR(13)+CHR(10) + cEtapas
			Alert(STR0209 + cEtapas, "")//Não foi possível gravar o(s) anexo(s) pois a(s) etapa(s) abaixo não estão cadastrada(s) no plano de ação
		EndIf
		
		//Caso exista integracao entre QNC x PMS / QNC x TMK / QNC x PMS x TMK
		If nPos07 <> 0
			If lRet .and. lQNCTPMS
				If Empty(aCols[n,nPos07])
					MessageDlg(STR0156) // "Campo obrigatorio. Deve-se informar o campo Tipo de Documento associado."
					lRet := .F.
				Endif
			Endif
		EndIf
	Endif
	
Return lRet
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³QNCVRFANEXO³ Autor ³Eduardo de Souza      ³ Data ³ 04/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Inclui / Visualiza Documento Anexo                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNCVRFANEXO()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Opcao no mBrowse                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQNC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNCVRFANEXO(nOpc)

Local nPosSeq  := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == If(cAliasAnex == "QIE","QIE_SEQ","QIF_SEQ")})
Local nPos1    := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == If(cAliasAnex == "QIE","QIE_ANEXO","QIF_ANEXO")})
Local cArqAnexo:= ""
Local lRet     :=.F.
local nloop	 := 0
Local nSeq		 := 0
Local cArqAne  := ""
Local cAnaQie := "TRB"
Local lexist := .F.
Local aColsAux:= aClone(aCols)
Local aArea:= GetArea()
Local cWhereA := ""
Private lTMKPMS:= If(GetMv("MV_QTMKPMS",.F.,1) == 1,.F.,.T.)

	If nOpc <> 2
		For nLoop := 1 to 99
		nSeq := nLoop -1
		
			If cAliasAnex == "QIE"
				cArqAne  := M->QI3_CODIGO + "P" + M->QI3_REV + "P" + strzero(val(Acols[n,nPosSeq])+nSeq,2) 
				cArqAnexo:= cArqAne + ".pla"
	    		cWhereA := SubStr(cArqAne,2)+"%"	
				cSelect := "QIE_FILIAL, QIE_CODIGO, QIE_REV, QIE_SEQ,QIE_ANEXO, QIE_PEND FROM " + RetSqlName("QIE") + " WHERE D_E_L_E_T_<>'*' AND QIE_ANEXO LIKE '"+cWhereA+"' "
			ElseIf cAliasAnex == "QIF" 
		    	cArqAne  :=AllTrim(Right(M->QI2_FILIAL,2))+Right(M->QI2_FNC,10) + M->QI2_REV + StrTran(Time(), ":","" ) 
				cArqAnexo:= cArqAne  + ".fnc" 
	    		cWhereA := SubStr(cArqAne,2)+"%"			
				cSelect := "QIF_FILIAL, QIF_FNC, QIF_REV, QIF_SEQ,QIF_ANEXO FROM " + RetSqlName("QIF") + " QIF WHERE D_E_L_E_T_<>'*'AND QIF_ANEXO LIKE '"+cWhereA+"' "
			EndIf
	 		cQuery :=" SELECT "+cSelect 
	
			cQuery := ChangeQuery(cQuery)								
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"cAnaCod",.T.,.T.)
		
	
			cAnaCod->(DbGoTop())
			lExist := .F.
			WHILE cAnaCod->(!Eof())
			  lExist:= .T.
				Exit
			EndDo
			DbCloseArea ()
		
			if !Ascan(aCols, { |x| substr(x[nPos1],1,at('.',x[nPos1])-1) $ cArqAne}) > 0 .AND. !lExist
				Exit
			EndIf
		Next nLoop
		RestArea(aArea)
		
		//ATENCAO RETIRAR ESSA CONSISTENCIA A PARTIR DE RELEASE OU VERSAO SUPERIOR A P10 R13.
		If lTMKPMS
			cArqAnexo:= SubStr(cArqAnexo,6,Len(cArqAnexo)-5)
		Else
			cArqAnexo:= SubStr(cArqAnexo,2,Len(cArqAnexo))
		Endif
	EndIf


	cFileTrm:= aCols[n,nPos1]

	// Ponto de Entrada para nao utilizar o tratamento padrao de pesquisa pelo parametro MV_QNCPDOC solicitado pelo TDI
	If Existblock("QNCDOCANX")
		lRet := Execblock("QNCDOCANX", .F. , .F. , {nOpc,@cFileTrm,cArqAnexo} )
	Else
		lRet := FQNCDRIVE(nOpc,@cFileTrm,cArqAnexo)
	Endif

	aCols[n,nPos1]:= cFileTrm

Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNCGAnexo ³ Autor ³ Eduardo de Souza      ³ Data ³ 05/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava Anexos                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNCGAnexo(ExpN1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Opcao do Browse                                    ³±±
±±³			 ³ ExpA1 - aHeader do documento anexo						  ³±±
±±³			 ³ ExpA2 - aCols do documento anexo							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQNC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNCGAnexo(nOpc,aHeadAnx,aColsAnx)

Local lRecLock:= .F.
Local nCnt    := 0
Local nCpo    := 0
Local nPosDel := ""
Local nPosSeq := "" 
Local cFilAnex:= ""
Local cCodAnex:= ""
LocaL cRevAnex:= ""
Local aHeadTrb:= {}
Local aColsTrb:= {}
Local nPosAne := ""


Default aHeadAnx := {}
Default aColsAnx := {}

aHeadTrb := aClone(aHeadAnx)
aColsTrb := aClone(aColsAnx)

QNCFGet(nOpc,cAliasAnex)

	If Empty(aHeadTrb)
		aHeadTrb := aClone(aHeader)
	EndIf

	If Empty(aColsTrb)
		aColsTrb := aClone(aCols)
	EndIf

	nPosDel := Len(aHeadTrb) + 1
	nPosSeq := aScan(aHeadTrb,{ |X| UPPER(ALLTRIM(X[2])) == If(cAliasAnex=="QIE","QIE_SEQ","QIF_SEQ")})
	nPosAne := aScan(aHeadTrb,{ |X| UPPER(ALLTRIM(X[2])) == If(cAliasAnex=="QIE","QIE_ANEXO","QIF_ANEXO")})
	If nOpc == 3
		lRecLock:= .T.
	EndIf

	If cAliasAnex == "QIE"
		cFilAnex:= QI3->QI3_FILIAL
		cCodAnex:= QI3->QI3_CODIGO
		cRevAnex:= QI3->QI3_REV
	ElseIf cAliasAnex == "QIF"
		cFilAnex:= M->QI2_FILIAL
		cCodAnex:= M->QI2_FNC
		cRevAnex:= M->QI2_REV
	EndIf

	Begin Transaction
	DbSelectArea(cAliasAnex)
	DbSetOrder(1)
		For nCnt:= 1 To Len(aColsTrb)
			If !aColsTrb[nCnt, nPosDel] // Verifica se o item foi deletado

				If DbSeek(cFilAnex+cCodAnex+cRevAnex+SubStr(aColsTrb[nCnt,nPosSeq],1,2))
					RecLock(cAliasAnex,.F.)
				Else
					RecLock(cAliasAnex,.T.)
				Endif

				For nCpo := 1 To Len(aHeadTrb) - 2
					If aHeadTrb[nCpo, 10] <> "V"
						FieldPut(FieldPos(Trim(aHeadTrb[nCpo,2])),aColsTrb[nCnt,nCpo])
					EndIf
				Next nCpo

				If cAliasAnex == "QIE"
					QIE->QIE_FILIAL:= QI3->QI3_FILIAL
					QIE->QIE_CODIGO:= QI3->QI3_CODIGO
					QIE->QIE_REV   := QI3->QI3_REV
					QIE->QIE_SEQ   := StrZero(nCnt,2)
				ElseIf cAliasAnex == "QIF"
					QIF->QIF_FILIAL:= M->QI2_FILIAL
					QIF->QIF_FNC   := M->QI2_FNC
					QIF->QIF_REV   := M->QI2_REV
					QIF->QIF_TIPO  := "1"
				EndIf

				MsUnlock()
			Else
				If DbSeek(cFilAnex+cCodAnex+cRevAnex+SubStr(aColsTrb[nCnt,nPosSeq],1,2))
					cFileTrm:= aColsTrb[nCnt,nPosAne]
					If File(cQPathFNC+cFileTrm)
						FErase(cQPathFNC+cFileTrm)	
					Endif

					RecLock(cAliasAnex,.F.)
					DbDelete()
					MsUnlock()
				Endif
			Endif
		Next nCnt
	End Transaction

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNCVdRAnex³ Autor ³ Eduardo de Souza      ³ Data ³ 05/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se Usuario pode alterar / deletar Doctos Anexos   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNCVdRAnex()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQNC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNCVdRAnex()

Local lRet     := .T.
Local nPosFil  := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == If(cAliasAnex=="QIE","QIE_FILMAT","QIF_FILMAT")})
Local nPosMat  := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == If(cAliasAnex=="QIE","QIE_MAT"   ,"QIF_MAT"   )})
Local aAliasQN := {}

	If cAliasAnex == "QIE" .And. cMatFil+cMatCod <> QI3->QI3_FILMAT+QI3->QI3_MAT
		If cMatFil+cMatCod <> Acols[n,nPosFil]+Acols[n,nPosMat]
		lRet:= .F.
		EndIf

	ElseIf cAliasAnex == "QIF" .And. cMatFil+cMatCod <> M->QI2_FILRES+M->QI2_MATRES
		If cMatFil+cMatCod <> Acols[n,nPosFil]+Acols[n,nPosMat]
		lRet:= .F.
		Endif
	EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNCUSRANEX³ Autor ³ Eduardo de Souza      ³ Data ³ 18/02/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o nome do responsavel do anexo.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNCUSRANEX()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQNC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNCUSRANEX()

Local cNome:= ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variavel utilizada no inicializado padrao para o nome do Usuario ³
//³para verificar se eh inclusao ou alteracao de documento anexo.   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nAcolsAtu:= Len(Acols)
Local nx := 1
 
nPosFil := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == If(cAliasAnex=="QIE","QIE_FILMAT","QIF_FILMAT")})
nPosMat := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == If(cAliasAnex=="QIE","QIE_MAT"   ,"QIF_MAT"   )})

	For nx := 1 To Len(aCols)
	cNome:= QA_NUSR(Acols[nx,nPosFil],Acols[nx,nPosMat],.T.)
	Next nx

Return cNome  

Function GETQNCNUM(cAlias,cCpoSx8,cAliasSX8,nOrdem,cChave,aQN)
Local aSavA := GetArea()
Local cRet  := Left(GETQNCSX(cAlias,cCpoSx8,cAliasSX8,nOrdem,cChave,@aQN),TamSX3(cCpoSx8)[1])

dbSelectArea(cAlias)
(cAlias)->(DbGoTop())	
(cAlias)->(dbSetOrder(nOrdem))
If (cAlias)->(dbSeek(xFilial(cAlias)+cChave+cRet))
	While xFilial(cAlias) == &(cAlias+"->"+cAlias+"_FILIAL") .And. cChave == &(cAlias+"->"+cAlias+"_ANO")
		ConfirmeQE(aQN)
		cRet := Left(GETQNCSX(cAlias,cCpoSx8,cAliasSX8,nOrdem,cChave,@aQN),TamSX3(cCpoSx8)[1])
	(cAlias)->(DbSkip())
	Enddo
Endif
RestArea(aSavA)
               
Return cRet


Function GETQNCSX(cAlias,cCpoSx8,cAliasSX8,nOrdem,cChave,aQN)
Local cSavAlias := Alias(), cRet, nSize, lFound, lNetErr := .t.
Local nTimes    := 0,nExist, nHdl, aCampos, cMenor, nRecno, nTrys := 0
Local aAliasQN  := {}
Local nTamanho  := TamSX3(cCpoSx8)[1]
Local lAnt      := .T.
Local cRet2     := ""

Default aQN := {}

cChave:= PADR(cChave,10)

	If Type("__lFirstQNXE") == "U"
	Private __lFirstQNXE := .T.
	Endif

	If __lFirstQNXE
	__lFirstQNXE := .f.
		If InTransaction()
		StartJob("GetQNCSXT",GetEnvServer(),.T.,cEmpAnt,cFilAnt)
		Else
			If !(MsFile("QNSXE",Nil,"TOPCONN")).Or. !!(MsFile("QNSXF",Nil,"TOPCONN"))
			nHdl := MSFCREATE("SOQNSXE")
				While nHdl < 0
				nHdl := MSFCREATE("SOQNSXE")
				Inkey(5)
				nTrys++
					If nTrys > 20
					Final("Probs.Criacao SOQNSXE")
					EndIf
				Enddo

				If !(MsFile("QNSXE",Nil,"TOPCONN"))
				aCampos := {}
				AADD(aCampos,{"QE_FILIAL","C",50,0})
				AADD(aCampos,{"QE_ALIAS","C",3,0})
				AADD(aCampos,{"QE_CHAVE","C",10,0})
				AADD(aCampos,{"QE_TAMANHO","N",2,0})
				AADD(aCampos,{"QE_NUMERO","C",20,0})
				FWDBCreate("QNSXE",aCampos,"TOPCONN", .T. )
				EndIf

				If !(MsFile("QNSXF",Nil,"TOPCONN"))
				aCampos := {}
				AADD(aCampos,{"QF_FILIAL","C",50,0})
				AADD(aCampos,{"QF_ALIAS","C",3,0})
				AADD(aCampos,{"QF_CHAVE","C",10,0})
				AADD(aCampos,{"QF_TAMANHO","N",2,0})
				AADD(aCampos,{"QF_NUMERO","C",20,0})
				FWDBCreate("QNSXF",aCampos,"TOPCONN", .T. )
				EndIf

			FClose(nHdl)
			Ferase("SOQNSXE")
			DbCommitAll()
			EndIf
		EndIf
	EndIf
	If Select("QNSXE") <= 0
	USE QNSXE ALIAS QNSXE SHARED NEW VIA "TOPCONN"
		If NetERR()
		Final("Probs.Abertura QNSXE")
		EndIf
	Endif
	If Select("QNSXF") <= 0
	USE QNSXF ALIAS QNSXF SHARED NEW VIA "TOPCONN"
		If NetERR()
		Final("Probs.Abertura QNSXF")
		EndIf
	EndIf

nOrdem := Iif(nOrdem == Nil,1,nOrdem) 

	If cAliasSX8 == Nil
	nExist := ascan(aAliasQN,{|x| x[2] == Padr(xFilial(cAlias)+x2Path(cAlias),50)})
		If nExist  == 0
		AADD(aAliasQN,{cAlias,PADR(xFilial(cAlias)+x2path(cAlias),50)})
		nExist := Len(aAliasQN)
		EndIf
	cAliasSx8  :=   aAliasQN[nExist,2]
	Else
	cAliasSx8  :=   Padr(cAliasSx8,50)
	EndIf

DbSelectArea("QNSXF")     //Olhar as Sobras
DbGoTop()
lFound := .f.
	While !Eof()
		If QF_FILIAL+QF_ALIAS+QF_CHAVE != cAliasSX8+cAlias+cChave
		DbSkip()
		Loop
		EndIf
		IF Ascan(aQN,{|x| x[1]==QNSXF->(Recno())}) > 0
	   dbSkip()
	   Loop
		Endif
		If !Deleted()
		cRet    := Substr(QF_NUMERO,1,QF_TAMANHO)
		// consegui reservar
			If MayIUseCode(cRet)
			lFound  := .t.
			Exit
			Else
				if cMenor == nil
				cMenor := cRet
				nRecno := Recno()
				EndIf
				if QF_ALIAS <> "QI2"
				Exit
				Else
					if cMenor <> nil
						if cRet < cMenor
			          cMenor  := cRet
	   					nRecno 	:= Recno()
						Else
			           cRet := cMenor
						EndIf
					EndIf
				EndIf
			EndIF
		EndIf
	DbSkip()
	End
	If !lFound
	DbSelectArea("QNSXE")    //Olhar o Proximo
	DbGoTop()
		While !Eof()
			If QE_FILIAL+QE_ALIAS+QE_CHAVE == cAliasSX8+cAlias+cChave
			Exit
			EndIf
		DbSkip()
		Enddo

		If QNSXE->(Eof())
		CriaQNE(cAlias,cCpoSx8,cAliasSx8,nOrdem,cChave)
		DbSelectArea("QNSXE")                                  
		EndIf
	nTrys := 0

	reclock("QNSXE",.F.)
	
	cRet := Substr(QE_NUMERO,1,QE_TAMANHO)
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso a base seja migrada e o arquivo QNSXE ja exista e o³
	//³QE_TAMANHO esteja  com tamanho igual a 6 é necessario   ³
	//³ajusta-lo o tamanho e o QE_NUMERO para 11.              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		If cCpoSx8 == "QI2_FNC" .Or. cCpoSx8 == "QI3_CODIGO"
			IF TamSX3(cCpoSx8)[1] == 15
			cRet :=strZero(Val(cRet),11,0)
			nSize := 11  
			Replace QE_TAMANHO with nSize
			Replace QE_NUMERO  with SOMA1(Substr(cRet,1,11))
			cRet2 := QE_NUMERO
			lAnt := .F.			
			Endif
		Endif

		If lAnt
		nSize :=QE_TAMANHO
		Replace QE_NUMERO with SOMA1(Substr(QE_NUMERO,1,QE_TAMANHO))
		cRet2 := QE_NUMERO
		Endif
	
	QNSXE->(MsUnLock())
	DbSelectArea("QNSXF")
	Reclock("QNSXF",.T.)
	Replace QF_FILIAL  with cAliasSx8
	Replace QF_ALIAS   with cAlias
	Replace QF_CHAVE   with cChave
	Replace QF_TAMANHO with nSize
	Replace QF_NUMERO  with cRet
	nRecno := QNSXF->(Recno())
	MsUnLock()
	EndIf

	if !MayIUseCode(cRet)
		cRet := Alltrim(cRet2)
	Endif

__lQNSX8 := .T.

	If cAlias <> "QI2" .Or. nRecno == NIL
	AADD(aQN,{QNSXF->(Recno()),"E"})
	Else
	AADD(aQN,{nRecno,"E"})
	EndIf

DbSelectArea(cSavAlias)
Return cRet+cChave

Function RollBackQE(aQN)
Local cALias := Alias() 
Local cChav  := ""
Local cNum   := 0
Local nTam 	 := 0

	If Len(aQN) < 1
	__lQNSx8 := .f.
	EndIf

	If !__lQNSx8
	Return Nil
	EndIf

DbSelectArea("QNSXF")
DbGoTo(aQN[len(aQN),1])
aDel(aQN,len(aQN))
aSize(aQN,len(aQN)-1)
__lQNSx8 := Iif(Len(aQN) == 0,.f.,.T.)
cChav  := QF_FILIAL+QF_ALIAS+QF_CHAVE
cNum   := QF_NUMERO
nTam   := QF_TAMANHO 
RecLock("QNSXF",.F.)
dbdelete()
MsUnLock()

DbSelectArea("QNSXE")   
DbGoTop()
	While !Eof()
		If QE_FILIAL+QE_ALIAS+QE_CHAVE == cChav
			If QE_NUMERO = strzero( val(cNum)+1,nTam) .Or. QE_NUMERO > strzero( val(cNum)+1,nTam)
			RecLock("QNSXE",.F.)
			QE_NUMERO := cNum
			Leave1Code(AllTrim(cNum))
			MsUnLock()			
			EndiF
		EndIf
	DbSkip()
	Enddo

	If !Empty(cAlias)
	DbSelectArea(cAlias)
	EndIf

Return nil

Function ConfirmeQE(aQN)
Local cAlias := Alias(), nReg
Local nTimes := 0

	If Type("__lQNSX8") != "L"
	Private __lQNSX8 := .F.
	EndIf

	If Len(aQN) < 1
	__lQNSx8 := .f.
	EndIf

	If !__lQNSx8
	Return Nil
	EndIf

nReg := aQN[len(aQN),1]

DbSelectArea("QNSXF")
DbGoTo(nReg)
aDel(aQN,len(aQN))
aSize(aQN,len(aQN)-1)
nTimes := 0
Leave1Code(AllTrim(QF_NUMERO))
Reclock("QNSXF",.F.)
dbDelete()
MsUnLock()

DbSelectArea(cAlias)
Return nil


Static Function CriaQNE(cAlias,cCpoSx8,cAliasSx8,nOrdSX8,cChave)
Local nRecno, nOrdem, cNum, cFilCpo
Local lCampo := .t.,   nTamanho, lNetErr := .T., nTimes := 0
Local nHdl := -1, nTrys := 0, lFound, cCampo,cFilter

nOrdSX8 := Iif(nOrdSX8 == Nil,1,nOrdSX8)
	Do Case
	Case cAlias == "QI2"
		cCampo := "QI2_FNC"
	Case cAlias == "QI3"
		cCampo := "QI3_CODIGO"
	Case cAlias == "QMZ"
		cCampo := "QMZ_COD"
	EndCase
	If cCpoSX8 != Nil
	cCampo := cCpoSX8
	EndIf

	If lCampo
	cFilCpo := PrefixoCpo(cAlias)+"_FILIAL"
	DbSelectArea("SX3")
	DbSetOrder(2)
	DbSeek(cCampo)
	DbSetOrder(1)
	DbSelectArea(cAlias)
	nRecno := Recno()
	nOrdem := IndexOrd()
	DbSetOrder(nOrdSX8)
	cFilter := dbFilter()
	Set Filter to
	DbGoTop()		// Nao tirar !!!!!!!! - Eh usado para resolver problema quando o SXE eh chamado apos o SetDummy
	DbSeek(xFilial(cAlias)+cChave+'z',.t.)
	DbSkip(-1)
	DbSetOrder(nOrdem)
		If nModulo == 22 .and. Alltrim(FunName())<>"QMTA140"
			If (Substr(&(cFilCpo),1,2) != xFilial(cAlias)) .or. (LastRec()==0) .Or. ;
			cChave <> SubStr(&(cCampo),8,4)
			cNum := Replicate("0",7)	// SX3->X3_TAMANHO
				Else
			cNum := SubStr(&(cCampo),1,7)	// Tamanho de 7 caracteres.
			EndIf
		nTamanho := 7 // SX3->X3_TAMANHO
		Else
			If (Substr(&(cFilCpo),1,2) != xFilial(cAlias)) .or. (LastRec()==0) .Or. ;
			cChave <> SubStr(&(cCampo),7,4)
					If cCampo == "QI2_FNC" .Or. cCampo == "QI3_CODIGO"
					IF TamSX3(cCampo)[1] == 15
					cNum := Replicate("0",11)//SX3->X3_TAMANHO C/ 11 caracteres
					Else
					cNum := Replicate("0",6)//SX3->X3_TAMANHO
					Endif
				Else
				cNum := Replicate("0",6)//SX3->X3_TAMANHO
				Endif
			Else
			cNum := SubStr(&(cCampo),1,6)//Tamanho de 6 caracteres.
				If cCampo == "QI2_FNC" .Or. cCampo == "QI3_CODIGO"
					IF TamSX3(cCampo)[1] == 15
					cNum :=strZero(Val(cNum),11,0)
					Endif
				Endif
			EndIf
			If cCampo == "QI2_FNC" .Or. cCampo == "QI3_CODIGO"
				IF TamSX3(cCampo)[1] == 15
				nTamanho := 11 //SX3->X3_TAMANHO c/ 11 caracteres
				Else
				nTamanho := 6 //SX3->X3_TAMANHO
				Endif
			Else
			nTamanho := 6 //SX3->X3_TAMANHO
			Endif
		Endif
	DbGoTo(nRecno)
		If !Empty(cFilter)
		Set Filter to &cFilter
		EndIf
	cNum := Soma1(cNum)
	EndIf

nTrys := 0
nHdl := MSFCREATE("SOQNSXE"+cAlias)
	While nHdl < 0
	Inkey(3)
	nTrys++
	nHdl := MSFCREATE("SOQNSXE"+cAlias)
		If nTrys > 20
		FINAL("PROBS.CRIAQNXE")
		EndIf
	End

DbSelectArea("QNSXE")   //Garantir que nao existe o Registro
DbGoTop()
lFound := .f.

	While !Eof()
		If QE_FILIAL+QE_ALIAS+QE_CHAVE == cAliasSX8+cAlias+cChave
		lFound := .t.
		Exit
		EndIf
	DbSkip()
	End

	If !lFound
		While lNetErr
		dbAppEnd(.f.)
		lNetErr := NetErr()
		nTimes ++
			If nTimes > 20
				If NetCancel()
				Final( oemtoansi("Problema de GRAVACAO DA SEQUENCIA QNSX8" ) ) //"Problema de GRAVACAO DA SEQUENCIA QNSX8"
				Else
				nTimes := 0
				EndIf
			EndIf
		Inkey( nTimes/24 )
		End

	RecLock("QNSXE", .T.)
	Replace QE_FILIAL  with cAliasSx8
	Replace QE_ALIAS   with cAlias
	Replace QE_CHAVE   with cChave
	Replace QE_TAMANHO with nTamanho
	Replace QE_NUMERO  with cNum
	QNSXE->(MsUnLock())
	EndIf
FClose(nHdl)
Ferase("SOQNSXE"+cAlias)

Return cNum

Function QNCSEQCHK(cFilSeq,cAlias)
Local lRet := .F.

	If File("QNSXE" + GetDBExtension()) .And. File( "QNSXF" + GetDBExtension())
		If Select("QNSXE") <= 0
		USE QNSXE ALIAS QNSXE SHARED NEW VIA "TOPCONN"
			If NetERR()
			Final("Probs.Abertura QNSXE")
			EndIf
		Endif
	DbSelectArea("QNSXE")
	DbGoTop()
		While !Eof()
			If QE_FILIAL+QE_ALIAS == cFilSeq+cAlias
			lRet := .T.
			Exit
			EndIf
		DbSkip()
		Enddo
	Endif

dbSelectArea("QIA")

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QNCLOAD   ºAutor  ³Telso Carneiro	     º Data ³  01/05/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Chamada das funcoes necessarias para inicializacao do      º±±
±±º          ³ modulo SIGAQNC                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Inicializacao do Modulo SIGAQNC                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QNCLOAD()
	QA_TRAVUSR()  //Verificacao de Usuario Ativo
	QSelPlanETP() //Seleciona Plano de acao sem Projeto/EDT definidos
	FQNC_USR()    //Pendencias
	QnVerQUO()  //Verifica se foi executado update para criacao de campos e indices na QUO

	If GetMv("MV_QALOGIX") == "1" //Caso haja integracao com o Logix e exista alias QNB - verifica se tem inconsistencias nos WebServices
		If ChkFile("QNB")
			If GetMV("MV_QMLOGIX",.T.,"1") == "1" //Define se mostra a tela de inconsistencia
				QXMSLOGIX()
			Endif
		Endif
	Endif

Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QNCAVMAIL  ³ Autor ³ Rodrigo Gomes       ³ Data ³ 26/08/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Envia E-mail para usuarios com pendencias no formato HTML  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNCAVMAIL()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQNC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNCAVMAIL()

Local dDtVenc    := dDataBase + GetMv("MV_QDVQNC") // Data de Vencimento 
Local dDtFlag    := GetMv("MV_QUDQNC") // Flag contendo o ultimo dia de envio de e-mail  
Local nRegSx6	  := SX6->(Recno())  
Local aUsrMat    := QNCUSUARIO()
Local aUsuarios  := {}
Local cMensag    := ""
Local cTVenc     := ""
Local cDesCod    := ""
Local cMsg       := ""
Local cDescQI3   := ""
Local nIndQI2    := 0
Local nIndQI3    := 0
Local nIndQI5    := 0
Local cKey       := ""
Local cFiltro    := "" 
Local cFilUsr    := "" // Filial do usuario
Local cMatUsr    := "" // Matricula do usuario
Local aMail      := {} // Corpo do E-mail
Local cFiltroCli :=""
Local aAreaAnt	 := GetArea()
Local aAreaSX6	 := SX6->(GetArea())
Local lQNCMSGFI  := ExistBlock( "QNCMSGFI" )
Local lQNCMSGPA  := ExistBlock( "QNCMSGPA" )
Local lQNCMSGEP  := ExistBlock( "QNCMSGEP" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-¿
//³aMail  ==>  aMail[x][1] --> Codigo            ³
//³            aMail[x][2] --> Revisao           ³
//³            aMail[x][3] --> Descricao Resumida³
//³            aMail[x][4] --> Data de Vencimento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-Ù

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se os usuarios ja receberam E-mail hoje.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(dDtFlag) .And. CToD(dDtFlag) >= dDataBase
	Return( Nil )
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtra o Arquivo QI2 - Fichas NC³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cIndQI2 := CriaTrab(NIL,.F.)
dbSelectArea("QI2")
cKey := "QI2_FILRES+QI2_MATRES+Dtos(QI2_CONPRE)+QI2_ANO+QI2_FNC"

	If Upper(TcGetDb()) $ "DB2/400"
	cFiltro := "Dtos(QI2_CONPRE) <= '" + Dtos(dDtVenc) + "' .And. "
	cFiltro += "Dtos(QI2_CONPRE)<>'        ' .And. Dtos(QI2_CONREA)=='        '"
	Else
	cFiltro := "Dtos(QI2_CONPRE) <= '" + Dtos(dDtVenc) + "' .And. "
	cFiltro += "!Empty(Dtos(QI2_CONPRE)) .And. Empty(Dtos(QI2_CONREA)) "
	Endif

	If Existblock ("QNQI2FIL")
	cFiltro := Execblock ("QNQI2FIL",.F.,.F.,{cFiltro})
	Endif

	IF ExistBlock( "QNCQI2FT" )
	cFiltroCli := ""
	cFiltroCli := ExecBlock( "QNCQI2FT", .f., .f.)
	cFiltro += cFiltroCli
	Endif
IndRegua("QI2",cIndQI2,cKey,,cFiltro,STR0088) //"Selecionando Registro no QI2..."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtra o Arquivo QI3 - Plano de Acao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cIndQI3 := CriaTrab(NIL,.F.)
dbSelectArea("QI3")
cKey := "QI3_FILMAT+QI3_MAT+Dtos(QI3_ENCPRE)+QI3_ANO+QI3_CODIGO"

	If Upper(TcGetDb()) $ "DB2/400"
	cFiltro := "Dtos(QI3_ENCPRE) <= '" + Dtos(dDtVenc) + "' .And. "
	cFiltro += "Dtos(QI3_ENCPRE)<>'        ' .And. Dtos(QI3_ENCREA)=='        '"
	Else
	cFiltro := "Dtos(QI3_ENCPRE) <= '" + Dtos(dDtVenc) + "' .And. "
	cFiltro += "!Empty(Dtos(QI3_ENCPRE)) .And. Empty(Dtos(QI3_ENCREA)) "
	Endif

	If Existblock ("QNQI3FIL")
	cFiltro := Execblock ("QNQI3FIL",.F.,.F.,{cFiltro})
	Endif

	IF ExistBlock( "QNCQI3FT" )
	cFiltroCli := ""
	cFiltroCli := ExecBlock( "QNCQI3FT", .f., .f.)
	cFiltro += cFiltroCli
	Endif
IndRegua("QI3",cIndQI3,cKey,,cFiltro,STR0078) //"Selecionando Registro no QI3..."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtra o Arquivo QI5 - Etapas do Plano de Acao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cIndQI5 := CriaTrab(NIL,.F.)
dbSelectArea("QI5")
cKey := "QI5_FILMAT+QI5_MAT+Dtos(QI5_PRAZO)+QI5_CODIGO"

	If Upper(TcGetDb()) $ "DB2/400"
	cFiltro := "Dtos(QI5_PRAZO) <= '" + Dtos(dDtVenc) + "' .And. "
	cFiltro += "Dtos(QI5_PRAZO)<>'        ' .And. Dtos(QI5_REALIZ)=='        ' .And. QI5_STATUS <>  '4' "
	Else
	cFiltro := "Dtos(QI5_PRAZO) <= '" + Dtos(dDtVenc) + "' .And. "
	cFiltro += "!Empty(Dtos(QI5_PRAZO)) .And. Empty(Dtos(QI5_REALIZ)) .And. QI5_STATUS <>  '4'
	Endif

	If Existblock ("QNQI5FIL")
	cFiltro := Execblock ("QNQI5FIL",.F.,.F.,{cFiltro})
	Endif

	IF ExistBlock( "QNCQI5FT" )
	cFiltroCli := ""
	cFiltroCli := ExecBlock( "QNCQI5FT", .f., .f.)
	cFiltro += cFiltroCli
	Endif
IndRegua("QI5",cIndQI5,cKey,,cFiltro,STR0079) //"Selecionando Registro no QI5..."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ----ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Seleciona o indice temporario QI2 e posiciona no primeiro registro³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ----ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nIndQI2 := RetIndex("QI2")
dbSetOrder(nIndQI2 + 1)
dbGoTop() 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciona no cadastro de usuarios para pegar os dados futuramente³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QAA")
dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pega todas as Fichas de todos os usuarios.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While QI2->(!Eof())
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Limpa o Array com os dados do E-mail.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aMail := {}
	
	// Pega o novo usuario
	cFilUsr := QI2->QI2_FILRES
	cMatUsr := QI2->QI2_MATRES
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Faz a validacao do usuario para que o usuario receba e-mail devera ³
	//³ser: Ativo, Recebe  E-mail, e o campo EMAIL nao estiver vazio      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If QAA->(MsSeek(cFilUsr + cMatUsr ))
			If QAA->QAA_RECMAI == "1" .And. QAA->QAA_STATUS == "1"  .And. !Empty(QAA->QAA_EMAIL)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Pega os dados de cada usuario e envia o E-mail com os dados da ficha³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				While QI2->( !Eof() .And. QI2->QI2_FILRES + QI2->QI2_MATRES == cFilUsr + cMatUsr )
				AADD(aMail,{QI2->QI2_FNC, QI2->QI2_REV, Left(QI2->QI2_DESCR,50), QI2->QI2_CONPRE})
				QI2->( dbSkip() )
				EndDo
			EndIf
		EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso esse usuario tenha alguma pendencia Vencida ou a          ³
	//³vencer a rotina envia E-mail no formato que o usuario cadastrou³
	//³contendo as pendencias e seus respectivos vencimentos          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(aMail) > 0

		cMensag  := STR0080 //"Fichas de Ocorrencia/nao-conformidades VENCIDAS e a VENCER"
	    cTVenc   := STR0081 //"Fichas de Ocorrencia/nao-conformidades"
	    cDesCod  := STR0082 //"Numero NFC"
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta o Corpo do E-mail no Formato HTML ou Texto.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		cMsg := QNCMAILVCT(1,aMail,Val(QAA->QAA_TPMAIL),cMensag,cTVenc,cDesCod) 
		
		cAttach := ""
		aMsg:={{cMensag + Space(10)+DTOC(Date())+"-"+SubStr(TIME(),1,5) , cMsg, cAttach } }

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ExecBlock responsavel pela alteracao do Layout do E-mail³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IF lQNCMSGFI
			aMsg := ExecBlock( "QNCMSGFI", .f., .f. )
			Endif
		
		AADD(aUsuarios, {QAA->QAA_LOGIN, QAA->QAA_EMAIL, aMsg} )
		Else
		QI2->( dbSkip() )
		EndIf
	EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ----ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Seleciona o indice temporario QI3 e posiciona no primeiro registro³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ----ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nIndQI3 := RetIndex("QI3")
dbSetOrder(nIndQI3 + 1)
dbGoTop() 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-----------ÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pega todos os Planos de Acao de todos os usuarios.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-----------ÄÄÄÄÄÄÄÄÄÄÄÙ
	While QI3->(!Eof())
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Limpa o Array com os dados do E-mail.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aMail := {}
	
	// Pega o novo usuario
	cFilUsr := QI3->QI3_FILMAT
	cMatUsr := QI3->QI3_MAT

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Faz a validacao do usuario para que o usuario receba e-mail devera ³
	//³ser: Ativo, Recebe  E-mail, e o campo EMAIL nao estiver vazio      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If QAA->(MsSeek(cFilUsr + cMatUsr ))
			If QAA->QAA_RECMAI == "1" .And. QAA->QAA_STATUS == "1"  .And. !Empty(QAA->QAA_EMAIL)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ--------¿
			//³Pega os dados de cada usuario e envia o E-mail com os dados do Plano de Acao³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ--------Ù
				While QI3->( !Eof() .And. QI3->QI3_FILMAT + QI3->QI3_MAT == cFilUsr + cMatUsr )
				cDescQI3 := StrTran(AllTrim(MSMM(QI3->QI3_PROBLE)),CHR(13) + CHR(10),"")
				AADD(aMail,{QI3->QI3_CODIGO, QI3->QI3_REV, Left(cDescQI3,50), QI3->QI3_ENCPRE})
				QI3->( dbSkip() )
				EndDo
			EndIf
		EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso esse usuario tenha alguma pendencia Vencida ou a          ³
	//³vencer a rotina envia E-mail no formato que o usuario cadastrou³
	//³contendo as pendencias e seus respectivos vencimentos          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(aMail) > 0
		
		cMensag  := STR0083 //"Lancamentos de Planos de Acao VENCIDOS e a VENCER"
   		cTVenc   := STR0084 //"Planos de Acao"
		cDesCod  := STR0085 //"Codigo"
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta o Corpo do E-mail no Formato HTML ou Texto.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cMsg := QNCMAILVCT(1,aMail,Val(QAA->QAA_TPMAIL),cMensag,cTVenc,cDesCod) 

		cAttach := ""
		aMsg:={{cMensag + Space(10)+DTOC(Date())+"-"+SubStr(TIME(),1,5) , cMsg, cAttach } }
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ExecBlock responsavel pela alteracao do Layout do E-mail³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IF lQNCMSGPA
			aMsg := ExecBlock( "QNCMSGPA", .f., .f. )
			Endif
		
		AADD(aUsuarios, {QAA->QAA_LOGIN, QAA->QAA_EMAIL, aMsg} )
		Else
		QI3->( dbSkip() )
		EndIf
	EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ----ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Seleciona o indice temporario QI5 e posiciona no primeiro registro³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ----ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nIndQI5 := RetIndex("QI5")
dbSetOrder(nIndQI5 + 1)
dbGoTop() 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ---------------------ÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pega todos os Etapas de Planos de Acao de todos os usuarios.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ---------------------ÄÄÄÄÄÄÄÄÄÄÄÙ
	While QI5->(!Eof())
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Limpa o Array com os dados do E-mail.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aMail := {}
	
	// Pega o novo usuario
	cFilUsr := QI5->QI5_FILMAT
	cMatUsr := QI5->QI5_MAT

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Faz a validacao do usuario para que o usuario receba e-mail devera ³
	//³ser: Ativo, Recebe  E-mail, e o campo EMAIL nao estiver vazio      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If QAA->(MsSeek(cFilUsr + cMatUsr ))
			If QAA->QAA_RECMAI == "1" .And. QAA->QAA_STATUS == "1"  .And. !Empty(QAA->QAA_EMAIL)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ------------------¿
			//³Pega os dados de cada usuario e envia o E-mail com os dados da Etapas do Plano de Acao³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ------------------Ù
				While QI5->( !Eof() .And. QI5->QI5_FILMAT + QI5->QI5_MAT == cFilUsr + cMatUsr )
				AADD(aMail,{QI5->QI5_CODIGO, QI5->QI5_REV, Left(FQNCDSX5("QD",QI5->QI5_TPACAO),50), QI5->QI5_PRAZO})
				QI5->( dbSkip() )
				EndDo
			EndIf
		EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso esse usuario tenha alguma pendencia Vencida ou a          ³
	//³vencer a rotina envia E-mail no formato que o usuario cadastrou³
	//³contendo as pendencias e seus respectivos vencimentos          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(aMail) > 0
		
		cMensag  := STR0086 //"Lancamentos de Etapas do Plano de Acao VENCIDAS e a VENCER"
		cTVenc   := STR0087 //"Etapas para Plano de Acao"
		cDesCod  := STR0085 //"Codigo"
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta o Corpo do E-mail no Formato HTML ou Texto.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cMsg := QNCMAILVCT(1,aMail,Val(QAA->QAA_TPMAIL),cMensag,cTVenc,cDesCod) 

		cAttach := ""
		aMsg:={{cMensag + Space(10)+DTOC(Date())+"-"+SubStr(TIME(),1,5) , cMsg, cAttach } }
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ExecBlock responsavel pela alteracao do Layout do E-mail³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IF lQNCMSGEP
			aMsg := ExecBlock( "QNCMSGEP", .f., .f. )
			Endif
		
		AADD(aUsuarios, {QAA->QAA_LOGIN, QAA->QAA_EMAIL, aMsg} )
		Else
		QI5->( dbSkip() )
		EndIf
	EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Envia E-mail para cada usuario com as pendencias em vencimento ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aUsuarios) > 0
	QaEnvMail(aUsuarios,,,,aUsrMat[5],"1")
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga arquivos tempor rios e os indices	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RetIndex("QI2")
	If file(cIndQI2+OrdBagExt())
	Ferase(cIndQI2+OrdBagExt())
	EndIf

RetIndex("QI3")
	If file(cIndQI3+OrdBagExt())
	Ferase(cIndQI3+OrdBagExt())
	EndIf

RetIndex("QI5")
	If file(cIndQI5+OrdBagExt())
	Ferase(cIndQI5+OrdBagExt())
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona o Flag no SX6, indicando que ja enviou E-mail hoje³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ---ÄÄÙ
dDtFlag := Iif(Empty(dDtFlag),"01/01/04",dDtFlag)
dbSelectArea("SX6")
SX6->(DbGoTop())
	If GetMV("MV_QUDQNC", .T.) .And. CToD(dDtFlag) < dDataBase
	PutMv("MV_QUDQNC",DtoC(dDatabase))
	EndIf

RestArea(aAreaSX6)
RestArea(aAreaAnt)

Return( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QNCMSGERA ºAutor  ³Telso Carneiro      º Data ³  03/11/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Chega os Parametros para Intregacao com QNC, para uso do   º±±
±±º          ³ QNCGERA                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GENERICO                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QNCMSGERA(cParm, nVeri)

	Local   lRet  := .T.
	Local cTemsg  := ""
	Local cFilQAD := xFilial("QAD")
	Local cOriFil := ""
	Local cOriDep := Alltrim(GetMV("MV_QNCDORI")) //Define na Integracao com QNC o Departamento Origem da FNC
	Local cDesFil := ""
	Local cDesDep := Alltrim(GetMV("MV_QNCDDES")) //Define na Integracao com QNC o Departamento Destino da FNC
	Local cResFil := ParamXFil(GetMV("MV_QNCFRES")) //Define na Integracao com QNC a Filial do Responsavel da FNC
	Local cResMat := Alltrim(GetMV("MV_QNCMRES")) //Define na Integracao com QNC a Matricula do Responsavel da FNC
	Local cDigFil := ParamXFil(GetMV("MV_QNCFDIG")) //Define na Integracao com QNC a Filial do Digitador da FNC
	Local cDigMat := Alltrim(GetMV("MV_QNCMDIG")) //Define na Integracao com QNC a Matricula do Digitador da FNC
	Local cDigDep := Alltrim(GetMV("MV_QNCDDIG")) //Define na Integracao com QNC o Departamento do Digitador da FNC
	Local aArea   := GetArea()
	Local cPaMa	  := cAux := ""

	Default cParm := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Esta variavel define se o  sistema irá verificar os parametros  ³
//³do GERAQNC independente se o sistema estiver  em  TOP ou nao.   ³
//³Por default so  sera  verificaco  em  TOP.                      ³
//³Nescessidade gerada pela  integração  com o TMK                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Default nVeri := 0

	If Empty(cFilQAD)
		cOriFil	:= xFilial("QAD")
		cDesFil := cOriFil
	Else
		cOriFil := ParamXFil(GetMV("MV_QNCFORI")) //Define na Integracao com QNC a Filial Origem da FNC
		cDesFil := ParamXFil(GetMV("MV_QNCFDES")) //Define na Integracao com QNC a Filial Destino da FNC
	Endif


	QAD->(DbSetOrder(1))
	QAA->(DbSetOrder(1))

	cTemsg:=OemToAnsi(STR0089)+" "+cParm+" "+Chr(13)  //"Devido a Integracao com Ambiente SIGAQNC"
	cTemsg+=OemToAnsi(STR0090)+" "+Chr(13) //"E necessario a configuracao dos Parametros:"

	cAux:="MV_QNCFORI / MV_QNCDORI /"
	IF cOriFil != "" .AND. cOriDep != ""
		IF QAD->(MSSEEK(cOriFil+cOriDep))
			cAux:=""
		Endif
	Endif
	cPaMa+=cAux

	cAux:="MV_QNCFDES / MV_QNCDDES /"
	IF cDesFil != "" .AND. cDesDep != ""
		IF QAD->(MSSEEK(cDesFil+cDesDep))
			cAux:=""
		Endif
	Endif
	cPaMa+=cAux

	cAux:="MV_QNCFRES / MV_QNCMRES /"
	IF cResFil != "" .AND. cResMat != ""
		IF QAA->(MSSEEK(cResFil+cResMat))
			cAux:=""
		Endif
	Endif
	cPaMa+=cAux

	cAux:="MV_QNCFDIG / MV_QNCMDIG / MV_QNCDDIG"
	IF cDigFil != "" .AND. cDigMat != "" .AND. cDigDep != ""
		IF QAA->(MSSEEK(cDigFil+cDigMat))
			IF ALLTRIM(cDigDep)==ALLTRIM(QAA->QAA_CC)
				cAux:=""
			Endif
		Endif
	Else
		cAux:=""
	Endif
	cPaMa+=cAux

	IF cPaMa!=""
		MsgAlert(cTemsg+cPaMa)
		lRet:=.F.
	Endif

	RestARea(aARea)

Return(lRet)


/*/
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³ QNCXRMAIL  ³ Autor ³ Cicero Cruz           ³ Data ³ 26/09/04 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Rotina de envio do email generica de Relatório. 			    ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Sintaxe   ³ QNCXRMAIL()                                                  ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso		 ³ SIGAQNC				                 					    ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function  QNCXRMAIL(aRel)

	Local aArqAux := {}
	Local aAttach := {}
	Local aDados  := QNCXRTO()
	Local cBody   := ""
	Local cAttach := ""
	Local cSubject := IIF(aRel[1,3]=="","",aRel[1,3])
	Local aUsrMat := QA_USUARIO()
	Local nX      := 0
	Local nY      := 0

// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// |Gerando Corpo do Email com os Relatorios gerados.   |
// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(aDados[2])
		cBody := Alltrim(aDados[2])
		cBody += CHR(13)+CHR(10)+CHR(13)+CHR(10)
	EndIF
// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// |Anexa  arquivos                   |
// |       aRel{Path,Arquivo}         |
// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX:=1 to Len(aRel)
		// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		// | Verifico o arquivo.                 |
		// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aArqAux := Directory(aRel[nX,1]+aRel[nX,2]+"*.jpg")

		For nY:=1 to Len(aArqAux)
			AADD(aAttach,{aArqAux[nY,1],aRel[nX,3]})
			If !Empty(cAttach)
				cAttach +=";"
			EndIf
			cAttach +=cStartPath+aArqAux[nY,1]
		Next nY
	Next nX

	aArqAux := {}
// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// | Monta dados para envio do email.    |
// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AADD(aArqAux,{" - " + cSubject,cBody,cAttach})
	aUsuarios := {{"",aDados[1],aArqAux,"2"} }
	QaEnvMail(aUsuarios,,,,aUsrMat[5])

// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// | Deleta arquivos JPEG gerados pelos relatorios. |
// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nY:=1 to Len(aAttach)
		FErase( cStartPath+aAttach[nY,1] )
	Next nY

Return

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ QNCXRMAIL  ³ Autor ³ Cicero Cruz           ³ Data ³ 26/09/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tela de digitação do email e corpo do email.    			    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNCXRMAIL()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAQNC				                 					    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QNCXRTO()

	Local cEmail := ""
	Local cCorpo := ""
	Local lLista := .T.
	Local lCancel:= .T.
	Local oEmail
	Local oCorpo
	Local oDlg
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada para preenchimento da variavel "cEmail"³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock( "QNCEMAIL" )
		cEmail := ExecBlock( "QNCEMAIL", .F., .F. )
	Endif

	DEFINE MSDIALOG oDlg FROM 12,35 TO 33, 90 TITLE OemToAnsi(STR0091) //"Informe os Emails para envio."
	@ 03,03	  TO 34,215 LABEL OemToAnsi(STR0092) OF oDlg PIXEL  //"Para :"
	@ 34,03	  TO 138,215 LABEL OemToAnsi(STR0093) OF oDlg PIXEL  //"Mensagem :"
	@ 11,06   GET oEmail VAR cEmail MEMO SIZE 205,20 OF oDlg PIXEL
	@ 42,06   GET oCorpo VAR cCorpo MEMO SIZE 205,93 OF oDlg PIXEL
	@ 142,142 BUTTON OemToAnsi(STR0094) OF oDlg SIZE 35, 12 ACTION IIF(!Empty(cEmail),(lCancel := .F.,oDlg:End()),.t.) PIXEL //"&Enviar"
	@ 142,180 BUTTON OemToAnsi(STR0136) OF oDlg SIZE 35, 12 ACTION (oDlg:End()) PIXEL //"&Cancelar"
	ACTIVATE DIALOG oDlg CENTERED
	If lCancel
		cEmail := ""
		cCorpo := ""
	Endif

Return({cEmail,cCorpo})

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ QNCVERI    ³ Autor ³ Cicero Cruz           ³ Data ³ 06/12/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida a desvinculacao da QNC - Cancelada do Assunto         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNCVERI()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Integracao 			                  					    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QNCVERI(cQNC, cRev, cMod)
	Local   aArea   := GetArea()
	Local   lRet 	:= .F. //Ficha  Nao Conformidade nao apta  para ser desvinculada

	Default cMod 	:= "TMK"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³So sera  permitido o desvinculamento de uma FNC de um  Atendimento ³
//³ou Assunto caso a FNC esteja  Cancelada / Baixada                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("QI2")
	dbSetOrder(2)
	If dbSeek(xFilial()+cQNC+cRev)
		Do Case
		Case (cMod == "TMK") // Validacoes Integracao TMK
			If QI2->QI2_STATUS == "5"  // Verifica se a FNC esta Cancelada
				lRet := .T.
			EndIf
			If !lRet //Se nao estiver cancelada verifico se a FNC esta baixada
				If !Empty(QI2->QI2_CONREA)
					lRet := .T.
				EndIf
			EndIf
		Case (cMod == "TEC")
			If !Empty(QI2->QI2_CODACA) // Verifica se a FNC tem Plano de Acao
				lRet := .T.
			EndIf
			If !lRet
				If !Empty(QI2->QI2_CONREA) // Verifica se ja foi baixada
					lRet := .T.
				EndIf
			EndIf
		Case (cMod == "QIP")
			If QI2->QI2_STATUS $ "1"  // Verifica se a FNC esta Registrada permitindo a sua exclusao
				lRet := .T.
			EndIf
		OtherWise
			lRet := .F.
		EndCase
	Endif

	RestArea(aArea)
Return lRet

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ QNCBAIXA   ³ Autor ³ Cicero Cruz           ³ Data ³ 06/12/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Baixa a FNC e toda a sua estrutura                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNCXRMAIL()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGATMK - (Integracao)                 					    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QNCBAIXA(cQNC, cRev, cModulo, cCompl)
	Local lRet := .F.
	Local nXx := 0
	Local lComp := .F.

	Default cModulo := "TMK"
	Default cCompl  := ""

	If Empty(alltrim(cCompl))
		lComp := .F.
	Else
		lComp := .T.
	EndIf

	QI2->(DBSETORDER(2))

	If QI2->(dbSeek(xFilial("QI2")+cQNC+cRev)) .And. Empty(QI2->QI2_CONREA)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifico se a FNC esta atrelada a um Plano de Acao ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(QI2->QI2_CODACA)
			QI9->(DBSETORDER(1))
			If QI9->(dbSeek(QI3->QI3_FILIAL+QI2->QI2_CODACA+QI2->QI2_REVACA))
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifico se o Plano de Acao esta atrelado a mais de uma FNC ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				While QI9->(!Eof()) .And. QI2->QI2_FILIAL+QI2->QI2_CODACA+QI2->QI2_REVACA == QI9->QI9_FILIAL+QI9->QI9_CODIGO+QI9->QI9_REV
					QI9->(DbSkip())
					nXx ++ // Conta  o numero de FNCs relacionadas a um Plano
					If nXx == 2
						Exit
					EndIf
				EndDo
				If nXx == 1
					QI3->(DbSetOrder(2))
					If QI3->(dbSeek(xFilial("QI3")+QI2->QI2_CODACA+QI2->QI2_REVACA))
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Baixa o Plano de Acao ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						RecLock("QI3",.F.)
						QI3->QI3_ENCREA := dDataBase
						If Empty(QI3->QI3_ENCPRE)
							QI3->QI3_ENCPRE := dDataBase
						Endif
						QI3->QI3_STATUS := "5"		// 5-Cancelado
						QI3->(MsUnLock())
						If Empty(QI3->QI3_OBSERV)	// Inclusao
							MSMM(,TamSx3("QI3_MEMO5")[1],,STR0099+" "+UPPER(QA_AmbDet( Nil, "SIGA"+cModulo, 4 ))+" ** "+Iif(lComp,"-"+cCompl,""),1,,,"QI3","QI3_OBSERV") //" ** PLANO DE ACAO CANCELADO PELO "
						Else						// Alteracao
							MSMM(QI3->QI3_OBSERV,TamSx3("QI3_MEMO5")[1],,STR0099+" "+UPPER(QA_AmbDet( Nil, "SIGA"+cModulo, 4 ))+" ** "+Iif(lComp,"-"+cCompl,""),1,,,"QI3","QI3_OBSERV")
						Endif
						//Baixo as Etapas do Plano de Acao
						QI5->(DbSetOrder(1))
						If QI5->(dbSeek(xFilial()+QI2->QI2_CODACA+QI2->QI2_REVACA))
							While QI5->(!Eof()) .And. QI5->QI5_FILIAL+QI5->QI5_CODIGO+QI5->QI5_REV == xFilial("QI5")+QI2->QI2_CODACA+QI2->QI2_REVACA
								RecLock("QI5",.F.)
								QI5->QI5_REALIZ := dDataBase
								QI5->QI5_DESCRE := STR0099+" "+UPPER(QA_AmbDet( Nil, "SIGA"+cModulo, 4 ))+" ** "+Iif(lComp,"-"+cCompl,"") //" ** PLANO DE ACAO CANCELADO PELO TMK ** "
								QI5->(MsUnLock())
								QI5->(DbSkip())
							Enddo
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Baixa Ficha de Ocorrencia/Nao-conformidades ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RecLock("QI2",.F.)
		QI2->QI2_CONREA := dDatabase
		If Empty(QI2->QI2_CONPRE)
			QI2->QI2_CONPRE := dDataBase
		Endif
		QI2->QI2_STATUS := "5"		// 5-Cancelada
		MsUnlock()
		If Empty(QI2->QI2_COMEN)	// Inclusao
			MSMM(,TamSx3("QI2_MEMO2")[1],,STR0101+UPPER(QA_AmbDet( Nil, "SIGA"+cModulo, 4 ))+" ** "+Iif(lComp,"-"+cCompl,""),1,,,"QI2","QI2_COMEN") // " ** FICHA DE NAO CONFORMIDADE CANCELADA PELO"
		Else						// Alteracao
			MSMM(QI2->QI2_COMEN,TamSx3("QI2_MEMO2")[1],,STR0101+UPPER(QA_AmbDet( Nil, "SIGA"+cModulo, 4 ))+" ** "+Iif(lComp,"-"+cCompl,""),1,,,"QI2","QI2_COMEN") // " ** FICHA DE NAO CONFORMIDADE CANCELADA PELO TMK ** "
		Endif
		lRet := .F.
	EndIf

Return lRet

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ QNCxUser   ³ Autor ³ Cicero Cruz           ³ Data ³ 06/12/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna a partir do operador o usuario do quality            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNCxUser()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGATMK - (Integracao)                 					    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QNCxUser(cUser, nTipo)
	Local aArea := GetArea()
	Local aUser := {"","",""}
	Local cIdUser := ""
	Local lAchou := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ nRet == 1 -> Retorna ID User                                 ³ 
//³ nRet == 2 -> Retorna Login                                   ³
//³ nRet == 3 -> Retorna PSW                                     ³
//³ nRet == 4 -> Retorna Nome                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local nRet := 2
	Default nTipo := 2

	If nTipo == 1
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Pego o UserID do Usuario   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SU7")
		DbSetOrder(1)
		If DbSeek(xFilial()+cUser)
			cIdUser := U7_CODUSU
			lAchou := .T.
		Else
			aUser := {"  ","ZZZZZZ","  "} // Usuario nao encontrado
			MsgAlert(STR0100) // "Usuario nao esta cadastrado no QNC. Para a abertura da Ficha sera ultilizado o usuario padrao."
		EndIf
	Else
		cIdUser := cUser
		lAchou := .T.
	EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recupero o Id o Login do Usuario Responsavel   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lAchou
		PswOrder(1)
		If PswSeek(cIdUser)
			cUser := PswRet()[1][nRet]
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Recupero a Matricula do Login do Usuario Responsavel   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(cUser)
			DbSelectArea("QAA")
			DbSetOrder(6)
			If DbSeek(UPPER(cUser))
				aUser[1] := QAA->QAA_FILIAL
				aUser[2] := QAA->QAA_MAT
				aUser[3] := QAA->QAA_CC
			Else
				aUser := {"  ","ZZZZZZ","  "} // Usuario nao encontrado
			EndIf
		Else
			aUser := {"  ","ZZZZZZ","  "} // Usuario nao encontrado
		EndIf
	EndIf
	RestArea(aArea)
Return aUser

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ QNCvPen    ³ Autor ³ Cicero Cruz           ³ Data ³ 06/12/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna se existem FNC Pendentes para um atendimento Pendente³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNCxUser()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGATMK - (Integracao)                 					    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QNCvPen(cCod)
	Local nRet := 1
	Local aArea := GetArea()
	SUD->(DbSetOrder(1))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ira verificar se existe  alguma  FNC gerada  para o atendimento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SUD->(DbSeek(SUD->(xFilial())+cCod))
		nRet := 3
		While !SUD->(EOF()) .and. SUD->(xFilial())+cCod == SUD->UD_FILIAL+SUD->UD_CODIGO
			If !Empty(SUD->UD_CODFNC)
				nRet := 1
				If QNCVERI(SUD->UD_CODFNC, SUD->UD_FNCREV)
					nRet := 2
					Exit
				EndIf
			EndIF
			SUD->(DBSkip())
		End
	EndIf
	RestArea(aArea)
Return nRet

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ QNCbxTMK   ³ Autor ³ Cicero Cruz           ³ Data ³ 15/12/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Baixa a partir de uma FNC uma Assunto no TMK                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNCbxTMK()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGATMK - (Integracao)                 					    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QNCbxTMK(cCod,cRev)
	Local aArea := GetArea()
	Local nReg := 0
	Private lTk271Auto:= .F.
	DbSelectArea("SUD")
	DbSetOrder(4)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ira verificar se existe alguma FNC gerada para o atendimento   ³
//³ encerrando o assunto/acao a que se refere a FNC                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If dbseek(xFilial()+cCod+cRev)
		nReg := Recno()
		TMKQNCEnc(nReg)
	Endif
	RestArea(aArea)
Return

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ QNCatuTMK  ³ Autor ³ Cicero Cruz           ³ Data ³ 15/12/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualiza o TMK revisao da FNC no TMK                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNCatuTMK()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGATMK - (Integracao)                 					    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QNCatuTMK(cCod, cRevAtu, cRevAnt)
	Local aArea := GetArea()
	DbSelectArea("SUD")
	DbSetOrder(4)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ira verificar se existe alguma FNC gerada para o atendimento   ³
//³ e atializa a revisao                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If dbseek(xFilial()+cCod+cRevAnt)
		RecLock("SUD",.F.)
		SUD->UD_FNCREV := cRevAtu
		MsUnlock()
	Endif
	RestArea(aArea)
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ QNCFGet   ³ Autor ³Rafael S. Bernardi    ³ Data ³ 08/02/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Carrega os vetores aHeader e aCols para a GetDados         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNCFGet                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Opcao no mBrowse                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQNC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNCFGet(nOpc,cAliasAnex)
Local   cSeek
Local   cWhile
Local   aNoFields := {"QIE_CODIGO","QIF_FNC",cAliasAnex+"_REV"}
Private Altera

	If nOpc == 4
	Altera := .T.
	EndIf

	If (cAliasAnex) == "QIE"
		dbSelectArea(cAliasAnex)
		dbSetOrder(1)
		dbSeek(QI3->QI3_FILIAL+QI3->QI3_CODIGO+QI3->QI3_REV)
		
		cSeek  := QIE->QIE_FILIAL+QIE->QIE_CODIGO+QIE->QIE_REV
		cWhile := "QIE->QIE_FILIAL+QIE->QIE_CODIGO+QIE->QIE_REV"
	
		If nOpc == 3
		  FillGetDados(nOpc,cAliasAnex,1     ,      ,            ,         ,aNoFields,          ,        ,      ,        ,  .T.  ,          ,        ,          ,           ,            ,)
		//FillGetDados(nOpc,Alias     ,nOrdem,cSeek  ,bSeekWhile  ,uSeekFor ,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty ,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry
		Else
		  FillGetDados(nOpc,cAliasAnex,1     ,cSeek ,{|| &cWhile},         ,aNoFields,          ,        ,      ,        ,       ,          ,        ,          ,           ,            ,)
		//FillGetDados(nOpc,Alias     ,nOrdem,cSeek  ,bSeekWhile  ,uSeekFor ,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty ,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry
		EndIf
	ElseIf (cAliasAnex) == "QIF"
		dbSelectArea(cAliasAnex)
		dbSetOrder(1)
		dbSeek(M->QI2_FILIAL+M->QI2_FNC+M->QI2_REV)
		
		cSeek  := QIF->QIF_FILIAL+QIF->QIF_FNC+QIF->QIF_REV
		cWhile := "QIF->QIF_FILIAL+QIF->QIF_FNC+QIF->QIF_REV"
	
		If nOpc == 3
		  FillGetDados(nOpc,cAliasAnex,1     ,      ,            ,         ,aNoFields,          ,        ,      ,        ,  .T.  ,          ,        ,          ,           ,            ,)
		//FillGetDados(nOpc,Alias     ,nOrdem,cSeek  ,bSeekWhile  ,uSeekFor ,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty ,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry
		Else
		  FillGetDados(nOpc,cAliasAnex,1     ,cSeek ,{|| &cWhile},         ,aNoFields,          ,        ,      ,        ,       ,          ,        ,          ,           ,            ,)
		//FillGetDados(nOpc,Alias     ,nOrdem,cSeek  ,bSeekWhile  ,uSeekFor ,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty ,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry
		EndIf
	EndIF

nAcolsAtu := Len(aCols)

nPosFil := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == If(cAliasAnex=="QIE","QIE_FILMAT","QIF_FILMAT")})
nPosMat := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == If(cAliasAnex=="QIE","QIE_MAT"   ,"QIF_MAT"   )})

nUsado := Len(aHeader)

Return



//*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
//*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-³FUNCOES DESENVOLVIDAS PARA O SSIM³*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
//*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ QNCGeraPlano ³ Autor ³Leandro            ³ Data ³ 20/01/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Gera Plano Acao automatico quando integrado com TMK        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNCGeraPlano                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Numero da FNC 	                                  ³±±
±±³			 ³ ExpN2 - Revisao da FNC	                                  ³±±
±±³			 ³ ExpN3 - Area 			                                  ³±±
±±³			 ³ ExpN4 - Plano Filho		                                  ³±±
±±³			 ³ ExpN5 - Plano Rejeitado	                                  ³±±
±±³			 ³ ExpN6 - Revisao do Plano Rejeitado                         ³±±
±±³			 ³ ExpN7 - Etapa que o processo devera voltar qdo a etapa foi ³±±
±±³			 ³         rejeitadado.					                      ³±±	
±±³			 ³ ExpN8 - Etapa atual em que o processo se encontrava e foi  ³±±
±±³			 ³         rejeitadado.					                      ³±±
±±³			 ³ ExpN9 - Gera revisao da FNC 			                      ³±±
±±³			 ³ ExpN10- Funcao chamada p/ gerar plano filho		          ³±±
±±³			 ³ ExpN11- Numero do Plano Pai							      ³±±
±±³			 ³ ExpN12- Numero da Revisao do Plano Pai				      ³±±
±±³			 ³ ExpN13- Texto com a Descricao do Plano                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQNC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNCGeraPlano(cFNC,cRev,cDepto,cGrupo,cPlano ,cRevPlano,cEtapaRej,cEtpAtual,lRev,lPlFilho,cPlPai,cRVPlPai,cDesc,lTransf,aQI5)

Local aArea    := ()
Local nI,nC    := 0
Local lInit    := .F.
Local bCampo   := {|nCPO|Field(nCPO)}
Local aUsrMat  := QNCUSUARIO()
Local cSeek    := ""
Local nCont    := 0
Local lGeraQI5 := .F.
Local cEtapa   := ""
Local lETPParalela := .F.
Local cQUOTMin	:= ""
Local cHRFin   := ""
Local nPosIni  := "" 
Local nPosFin  := ""
Local cHRTotal := ""
Local cHRPerc  := ""
Local cElem1   := ""
Local cElem2   := ""
Local cHRParcial     := ""
Local aRequisitaResp := {}
Local aHabilidades   := {}
Local aQI5Plan		 := {}
Local cMemoLog       := ""
Local nReg           := 0
Local aCab           := {}
Local aRec           := {} 
Local aUsrPlAcao		:= {}
Local aQI5Aux    		:= {}
Local cObs   		 := ""
Local cDescr 	     := ""
Local cTexto         := ""
Local aAreaQI5       := {}
Local aTrfDatas      := {}
Local cRESP          := "2"
Local lTMKPMS 		 := If(GetMv("MV_QTMKPMS",.F.,1) == 1,.F.,.T.)//Integracao do QNC com TMK e PMS: 1-Sem integracao,2-TMKxQNC,3-QNCxPMS,4-TMKxQNCxPMS ³
Local cRecurso       := ""
Local aRQI52TRF		 := {}
Local dQI5Prazo		 := CTOD("  /  /  ")
Local dDTIQI5		 := CTOD("  /  /  ")
Local nHrAcum		 := 0

Local lQi3Exist		:= .T.
Local cNxtQi3Cod	:= ""
Local lFreeUsdQI3	:= .F.
Local cThreadID     := THREADID()  			//Armazena o identificador da thread
Local lQNCCARQUP	:= ExistBlock("QNCCARQUP")
Local lLoadQUP		:= .T.
Local cQI3Resp      := ""
Local cProdut		:= AllTrim(QI2->QI2_CODPRO)
Local nMaxCodes		:= SetMaxCodes( 999 )
Local nMVQTMKPMS    := GetMv("MV_QTMKPMS")

Default cGrupo    	:= ""
Default cPlano    	:= ""
Default cRevPlano 	:= ""
Default cEtapaRej 	:= ""
Default cEtpAtual 	:= ""
Default lRev      	:= .F.
Default lPlFilho    := .F.
Default cPlano      := ""
Default cRevPlano   := ""
Default cDesc		:= ""
Default lTransf     := .F.

Private __lQNSX8 	:= .F.
Private aQNQI3   	:= {}
Private lMsErroAuto	:=	.F.
Private cFilMat  	:= cFilAnt
Private cMatFil  	:= aUsrMat[2]
Private cMatCod  	:= aUsrMat[3]

	If ExistBlock("QNCQI3NUM")
	aRetPE_NUM := ExecBlock("QNCQI3NUM",.F.,.F.,{cFNC,cRev,cPlano,cRevPlano,cGrupo,cDepto} )
		If ValType(aRetPE_NUM) == "A" .and. Len(aRetPE_NUM) == 6
		cPlano		:= aRetPE_NUM[3]
		cRevPlano	:= aRetPE_NUM[4]
		cGrupo		:= aRetPE_NUM[5]
		cDepto		:= aRetPE_NUM[6]
		EndIf
	EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Procura a funcao de numeracao sequencial parecido com SXE/SXF                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SX3->( dbSetOrder(2) )
	If !Empty(GetSX3Cache("QI3_CODIGO","X3_CAMPO"))
		If "GETQNCNUM" $ GetSX3Cache("QI3_CODIGO","X3_RELACAO")
		lSX3Seq  := .T.
		Endif
	Endif
SX3->( dbSetOrder(1) )

	BEGIN TRANSACTION
	
	DbSelectArea("QI3")   
		For nI := 1 To fcount()
		M->&(Eval(bCampo,nI)) := FieldGet(nI)
		lInit := .F.
	
			If ( ExistIni(Eval(bCampo,nI)) )
			lInit := .T.
				If "QI3_CODIGO" $ (Eval(bCampo,nI))
					If Empty(cPlano)
					lQi3Exist := .T.
					cNxtQi3Cod := ""
					lFreeUsdQI3 := .T.
						While lQi3Exist
						cNxtQi3Cod := GETQNCNUM("QI3","QI3_CODIGO",,1,StrZero(Year(dDataBase),4),@aQNQI3)
						dbSelectArea("QI5")
						dbSelectArea("QI3")
						dbSetOrder(2)
							If MayIUseCode("QI3_CODIGO"+cNxtQI3Cod) .and. !MsSeek(xFilial("QI3")+cNxtQI3Cod,.F.) .and. QI5->(!MsSeek(xFilial("QI5")+cNxtQI3Cod,.F.))
							lQi3Exist := .F.
							Else
							Leave1Code()
							lQi3Exist := .T.
							EndIf
						EndDo
					M->&(Eval(bCampo,nI)) := cNxtQi3Cod ///COMENTADO->/// GETQNCNUM("QI3","QI3_CODIGO",,1,StrZero(Year(dDataBase),4),@aQNQI3)
					Else
					M->&(Eval(bCampo,nI)) := cPlano
					EndIf
				Else
				M->&(Eval(bCampo,nI)) := InitPad(GetSx3Cache(Eval(bCampo,nI),"X3_RELACAO"))
				EndIf
				If ( ValType(M->&(Eval(bCampo,nI))) == "C" )
				M->&(Eval(bCampo,nI)) := Padr(M->&(Eval(bCampo,nI)),GetSx3Cache(Eval(bCampo,nI),"X3_TAMANHO"))
				Endif
				If ( M->&(Eval(bCampo,nI)) == NIL )
				lInit := .F.
				EndIf
			EndIf
			If ( ! lInit  )
				If ( ValType(M->&(Eval(bCampo,nI))) == "C" )
				M->&(Eval(bCampo,nI)) := Space(Len(M->&(Eval(bCampo,nI))))
				ElseIf ( ValType(M->&(Eval(bCampo,nI))) == "N" )
				M->&(Eval(bCampo,nI)) := 0
				ElseIf ( ValType(M->&(Eval(bCampo,nI))) == "D" )
				M->&(Eval(bCampo,nI)) := Ctod("  /  /  ","DDMMYY")
				ElseIf ( ValType(M->&(Eval(bCampo,nI))) == "L" )
				M->&(Eval(bCampo,nI)) := .F.
				EndIf
			EndIf
		Next
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Obtem o Grupo para geracao das pendencias ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		If ( !Empty(cEtapaRej) .or. !Empty(cGrupo) )  .And. !Empty(cRevPlano)
		M->QI3_Codigo:= cPlano
		M->QI3_REV   := StrZero(Val(cRevPlano)+1,2)    
		
		DbSelectArea("QUS")  
		QUS->(dbSetOrder(3))
			If Empty(cGrupo)
				If QUS->(MsSeek(xFilial("QUS")+cEtpAtual+cEtapaRej))
					If !Empty(QUS->QUS_GRAGR)
					cGrupo := QUS->QUS_GRAGR
					Endif
				Endif
			EndIf

		DbSelectArea("QI3")  
		dbSetOrder(2)
			If dbSeek(xFilial("QI3")+cPlano+cRevPlano)
	    	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Carregando a descricao detalhada do problema, local da ocorrencia, resultado esperado, ³
			//³resultado atingido, observacoes e metodo utilizado.                                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
				If !Empty(QI3->QI3_PROBLE)
				M->QI3_PROBLE  := QI3->QI3_PROBLE
				Endif
				If !lTMKPMS
					If !Empty(QI3->QI3_LOCAL)
					M->QI3_LOCAL   := QI3->QI3_LOCAL
					Endif
					If !Empty(QI3->QI3_RESESP)
					M->QI3_RESEP   := QI3->QI3_RESESP
					Endif
					If !Empty(QI3->QI3_RESATI)
					M->QI3_RESATI  := QI3->QI3_RESATI
					Endif
					If !Empty(QI3->QI3_OBSERV)
					M->QI3_OBSERV  := QI3->QI3_OBSERV
					Endif
					If !Empty(QI3->QI3_METODO)
					M->QI3_METODO  := QI3->QI3_METODO
					Endif
				Endif
			Endif
	 
		RecLock("QI3",.F.)
		QI3->QI3_ENCREA := dDataBase
			If Empty(QI3->QI3_ENCPRE)
			QI3->QI3_ENCPRE := dDataBase
			Endif
		QI3->QI3_OBSOL := "S"
        cQI3Resp := QI3->QI3_MAT
		QI3->(MsUnLock())  
		FKCOMMIT()		
		Endif

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gerando revisao do Plano devido a revisao da FNC.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		If lRev
		DbselectArea("QI9")
		QI9->(dbSetOrder(2))
			If QI9->(MsSeek(XFilial("QI9")+cFNC+cRev+cPlano+cRevPlano))
			DbSelectArea("QI3")  
			dbSetOrder(2)
				If dbSeek(xFilial("QI3")+QI9->QI9_CODIGO+QI9->QI9_REV)
    			RecLock("QI3",.F.)
			    QI3->QI3_OBSOL := "S"
				MsUnLock()
				FKCOMMIT()			
				Endif
			M->QI3_Codigo:= QI9->QI9_CODIGO
			M->QI3_REV   := StrZero(Val(QI9->QI9_REV)+1,2)    					
			Endif
		Endif
	
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega os registros dos sub-Cadastros  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	M->QI3_FILIAL := xFilial("QI3")
	M->QI3_FILMAT := cMatFil
		If !Empty(cQI3Resp)
		M->QI3_MAT    := cQI3Resp
		M->QI3_NUSR   := QA_NUSR(cMatFil,cQI3Resp,.T.)
		Else
		DbselectArea("QI2")
		QI2->(dbSetOrder(2))	
			If QI2->(MsSeek(xFilial("QI2")+cFNC+cREV))
				If !Empty(QI2->QI2_MATRES)
        		M->QI3_MAT  := 	QI2->QI2_MATRES
        		M->QI3_NUSR :=  QA_NUSR(QI2->QI2_FILRES,QI2->QI2_MATRES,.T.)
				Else
					If !Empty(QI2->QI2_ORIDEP)
	    			DbselectArea("QAD")
			    	dbSetOrder(1)
						If QAD->(MsSeek(xFilial("QAD")+QI2->QI2_ORIDEP)) //Estava como campo de memoria...
							If !Empty(QAD->QAD_MAT)
							M->QI3_MAT    := QAD->QAD_MAT
							M->QI3_NUSR   := QA_NUSR(xFilial("QAD"),QAD->QAD_MAT,.T.)
							Endif
						Endif
					Endif
				Endif
			Else
			M->QI3_MAT    := cMatCod
			M->QI3_NUSR   := QA_NUSR(cMatFil,cMatCod,.T.)
			Endif
		Endif
	M->QI3_ABERTU := dDataBase
	M->QI3_ENCPRE := dDatabase+30
	M->QI3_ENCREA := Ctod("  /  /  ")
	M->QI3_ANO	  := SubStr(cFNC,12,4)
	M->QI3_OBSOL  := "N"
	M->QI3_STATUS := "3"	// "3"-Procede		
	M->QI3_CODCLI := QI2->QI2_CODCLI
	M->QI3_LOJCLI := QI2->QI2_LOJCLI
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Amarra as Acoes corretiva aos Tipo de Acao por depto. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	DbselectArea("QUO")        	
	QUO->(dbSetOrder(1))   
		If !Empty(cGrupo)
		QUO->(dbSetOrder(1))   
		cSeek := cGrupo
		Else
		QUO->(dbSetOrder(3))   
		cSeek := cDepto+cProdut  
		Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de Entrada criado pela Engenharia³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		If ExistBlock("QNCSELQUO")
		aTMPSeek := ExecBlock("QNCSELQUO",.F.,.F., {cSeek, QUO->(IndexOrd()), cGrupo , lPlFilho, M->QI3_CODIGO, M->QI3_REV, cFNC , cRev } )	
			If ValType(aTMPSeek) == "A"
				If Len(aTMPSeek) >= 1 .and. valType(aTMPSeek[1]) == "C"
				cSeek := aTMPSeek[1]	///Primeira posição do array de retorno é o argumento de pesquisa.
				EndIf
				If Len(aTMPSeek) >= 2 .and. valType(aTMPSeek[2]) == "N"
				dbSetOrder(aTMPSeek[2])	///Segunda posição do array de retorno é a ordem de pesquisa.
				EndIf
			EndIf
		EndIf

	RecLock( "QI3", .T. )
		For nC := 1 TO FCount()
		FieldPut( nC, M->&( Eval( bCampo, nC ) ) )
		Next
	MsUnlock()
	//Gravacao das chaves dos Campos Memo na Inclusao
	M->QI3_MEMO1 :=  cDesc
	MSMM(QI3_PROBLE,,,M->QI3_MEMO1,Iif(lPlFilho,1,3),,,"QI3","QI3_PROBLE")
	FKCOMMIT()               

		If !Empty(cPLPai)
	    lETPParalela := .T.
		Endif
	DbselectArea("QI2")
	QI2->(dbSetOrder(2))	
		If QI2->(MsSeek(xFilial("QI2")+cFNC+cREV))
			If !lEtpParalela	//Se não for plano agregado (é plano principal)
			RecLock( "QI2", .F. )	///Atualiza na FNC o Plano Atual (histórico é possível obter pelo QI9).
			QI2->QI2_CODACA := QI3->QI3_CODIGO
			QI2->QI2_REVACA := QI3->QI3_REV
			QI2->(MsUnLock())
	   		FKCOMMIT()
			Endif
		Endif

		If QUO->(MsSeek(xFilial("QUO")+cSeek))
		DbselectArea("QUP")
		dbGoTop()
			If Empty(cEtapaRej)
			cEtapaRej := ""	////<- FORÇA SEM ESPACOS PARA NÃO FALHAR NO SEEK DA QUP.
			QUP->(dbSetOrder(2))
			Else
		  	QUP->(dbSetOrder(1))
			Endif
			
			If Empty(cGrupo)
				If QUO->(MsSeek(xFilial("QUO")+cSeek))
		  		cGrupo := QUO->QUO_GRUPO
				Else
				MsgInfo(STR0140,STR0141+QI3->QI3_CODIGO)//"Nao existe Grupo de Etapas/Modelo cadastrado."##"Geração de Etapas do Plano de Ação: "
				EndIf
			EndIf

		RecLock("QI3",.F.)
		Field->QI3_MODELO := (cGrupo) 
		Field->QI3_ENCPRE := QI2->QI2_CONPRE
		Field->QI3_ENCPRE := QI2->QI2_CONPRE
		QI3->(MsUnlock())
		    	
			If QUP->(MsSeek(xFilial("QUP")+cGrupo+cEtapaRej))  //Se a etapa nao for de rejeicao ocorre o seek somente pelo grupo sem considerar a etapa da rejeicao
			QUP->(dbSetOrder(2)) ////<- SEMPRE IRA PROCESSAR O MODELO DE ETAPAS POR SEQUÊNCIA !
			nCont := 1
	   	    
				While QUP->(!Eof() .And. xFilial("QUP")+QUP->QUP_GRUPO == QUO->QUO_FILIAL+QUO->QUO_GRUPO)
			    				    
				lLoadQUP := .T.
					If lQNCCARQUP
					lLoadQUP := ExecBlock("QNCCARQUP",.F.,.F.)	//Deve retornar .T. para incluir o item do QUP e .F. para desconsiderar.
						If ValType(lLoadQUP) <> "L"
			 			lLoadQUP := .T.
						EndIf
					EndIf
			   
					If lLoadQUP
				  	   			   
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Amarra as Habilidades as Etapas. ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ							
					
					QNCCARHAB(QUP->QUP_TPACAO,M->QI3_FILIAL,M->QI3_CODIGO,@aHabilidades)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³aHabilidades = Array com as habilidades para executar a tarefa.                    ³                          ³
					//³dDTEncer     = Dt de Encerramento                                                  ³			  
					//³cHRParcial   = HR ref a Porcentagem p/ executar a etapa, cadastrada no arquivo QUP ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
								    
				    cQUOTMin   := Hrs2Min(QUO->QUO_PRZHR)//Hora total - Retorna a hora em minutos
					cHRParcial := QNCCalcPercHR(cQUOTMIn,QUP->QUP_PERC)
		
					dbSelectArea("QI5")
					dbSetOrder(1)
						If MsSeek(xFilial("QI5")+(QI3->QI3_CODIGO+QI3_REV)+QUP->QUP_SEQUEN,.F.)
						RecLock("QI5",.F.)
						Else
						RecLock("QI5",.T.)
						EndIf
					QI5->QI5_FILIAL := QI3->QI3_FILIAL 	  		    // Filial Plano de Acao
					QI5->QI5_CODIGO := QI3->QI3_CODIGO			    // Codigo Plano de Acao
					QI5->QI5_REV    := QI3->QI3_REV 			        // Revisao da Acao
					QI5->QI5_SEQ    := QUP->QUP_SEQUEN		    	// Sequencia da Acao
					QI5->QI5_STATUS := "0"						    // Status da Acao
					QI5->QI5_TPACAO := QUP->QUP_TPACAO             // Tipo da Acao
					QI5->QI5_DESCRE := A120DEtapa(QUP->QUP_TPACAO)	// Descricao Resumida
						If nCont = 1
						QI5->QI5_PEND   := "S" 
						Else
							If Empty(cRevPlano) .And. lETPParalela
							QI5->QI5_PEND   := "S" 					
							Endif
						Endif
					QI5->QI5_FILMAT := xFilial("QI5") 
				
						If lTMKPMS
							If nMVQTMKPMS > 2
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                                 
							//³ Integracao com o PMS ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	

					    	QI5->QI5_PROJET := QUP->QUP_PROJET //Codigo do Projeto para o Plano de Ação
					    	QI5->QI5_REVISA := QUP->QUP_REVISA //Revisão do Projeto para o Plano de Ação
							QI5->QI5_PRJEDT := QUP->QUP_CJCOD  //Codigo da EDT Pai para o Plano de Ação
							QI5->QI5_PARSEQ := QUP->QUP_PARSEQ   //Comportamento do paralelismo
							  
							Endif
						  	QI5->QI5_TRFACT := QUP->QUP_TRFACT  //Comportamento da etapa x tarefa.
						  	
							If Empty(QI5->QI5_MAT)
			                QI5->QI5_MAT    := QUP->QUP_RESP //Matricula do LIDER responsavel pela Etapa da Acao Corretiva
							EndIf
						
							If Empty(QUP->QUP_GRAGR)                    //Plano Complementar
							QI5->QI5_PLAGR  := "2"                
							QI5->QI5_GRAGR  := ""
							Else
							QI5->QI5_PLAGR  := "1" 
							QI5->QI5_GRAGR  := QUP->QUP_GRAGR
							Endif
		                QI5->QI5_PRZHR  :=  Alltrim(StrTran(Padl(Alltrim(TransForm(Min2Hrs(cHRParcial),"@R 9999.99")),7,"0")   ,".",":"))						
						Endif
					
					QI5->QI5_AGREG	:= "N"
					QI5->QI5_OBRIGA := QUP->QUP_OBRIGA 			//Refere-se a obrigatoriedade de execucao da tarefa
					QI5->QI5_AUXOBR := QUP->QUP_OBRIGA         //Referencia padrao para possibilitar ou nao a alteracao de obrigatoriedade
					QI5->QI5_ETPRLA := QNCEtpPai(cGrupo,QUP->QUP_TPACAO) //Grava etapa pai do paralelismo
					
						If Empty(QI5->QI5_MAT2) .and. !Empty(QUP->QUP_RESP2)
                  	QI5->QI5_MAT2 := QUP->QUP_RESP2  //-- Grava os recursos adicionais
						Endif
		
					QI5->(MsUnLock())
					FKCOMMIT()         
			
					aAdd(aQI5Aux,  QI5->QI5_MAT)				
						If nCont == 1 .or. lPlFilho
						aAdd(aRQI52TRF,  QI5->(Recno()) )
						EndIf
			        
	                ///Primeira dDTIQI5 virá com branco para que o primeiro prazo seja calculado a partir do PRAZO FINAL.
	   				dQI5Prazo := QN5CalPrz(dDTIQI5,@nHrAcum,QI3->QI3_ENCPRE,QI5->QI5_PRZHR,QUO->QUO_PRZHR)
					RecLock("QI5",.F.)			
						If Empty(dQI5Prazo) .and. Empty(QI5->QI5_PRAZO) ///***REVISAR*** PRAZO DEFAULT QI5 DEVE SER => PROPORCIONAL ENTRE QI3_PRAZO e PERC. ETAPA. [ (FIM-INICIO * .PERC QUP) - (FIM-INICIO) *.20 ]
						QI5->QI5_PRAZO  := dDataBase    //Data de Vecto para a Execucao da Etapa da Acao Corretiva
						Else
						QI5->QI5_PRAZO  := dQI5Prazo
						EndIf
					QI5->(MsUnLock())
			        dDTIQI5 := QI5->QI5_PRAZO		 		        
			
					nCont       := nCont+1
					lGeraQI5    := .F.  
					aHabilidades:= {}
					EndIf
				
				QUP->(dbSkip()) 				
				Enddo
            
				If ValType(__lQNCFGP) <> "L"
            	__lQNCFGP := ExistBlock("QNCFGP")
				EndIf
				If __lQNCFGP
            	ExecBlock("QNCFGP",.F.,.F.)
				EndIf
      		      
				If lTMKPMS
		    	QI5->(dbGoTo(aRQI52TRF[1]))
		    	QAltObrigEtp(QI5->QI5_CODIGO,QI5->QI5_REV,QI5->QI5_TPACAO,,,,,,.T.)  
				QNQI5xPMS(aRQI52TRF,cFNC,cRev)
				EndIf
			Endif

		ElseIf !IsBlind()
		MsgInfo(STR0140,STR0141+QI3->QI3_CODIGO)//"Nao existe Grupo de Etapas/Modelo cadastrado."##"Geração de Etapas do Plano de Ação: "
		Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Amarra a FNC atual ao Plano. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		If Empty(cFNC)
		cFNC:= QI2->QI2_FNC
		cREV:= QI2->QI2_REV	
		Endif

	DbselectArea("QI9")
	QI9->(dbSetOrder(1))	
		If !QI9->(dbSeek(M->QI3_FILIAL+M->QI3_CODIGO+M->QI3_REV+cFNC+cREV))
		RecLock("QI9",.T.)
		QI9->QI9_FILIAL := M->QI3_FILIAL
		QI9->QI9_CODIGO := M->QI3_CODIGO
		QI9->QI9_REV    := M->QI3_REV
		QI9->QI9_FNC    := AllTrim(cFNC)
		QI9->QI9_REVFNC := AllTrim(cREV)
			If lETPParalela
			QI9->QI9_PLAGRE := AllTrim(cPlPai)
			QI9->QI9_REVPL  := AllTrim(cRVPlPai)    
				IF !Empty(cPlPai)
				QI9->QI9_AGREG  := "S"
				Endif
			Else
			QI9->QI9_AGREG  := "N"
			QI9->QI9_PLAGRE := ""
			QI9->QI9_REVPL  := ""
			Endif
		
		MsUnLock()			
		FKCOMMIT()
		Endif

	DbselectArea("QI2")
	QI2->(dbSetOrder(1))	
		If QI2->(MsSeek(xFilial("QI2")+M->QI3_ANO+cFNC+cREV))
			If Empty(QI2->QI2_CODACA)//Amarra a FNC ao Plano Pai
			RecLock( "QI2", .F. )
			QI2->QI2_CODACA := M->QI3_CODIGO
			QI2->QI2_REVACA := M->QI3_REV                                                    
				
			QI2->(MsUnLock())
	   		FKCOMMIT()
			Endif
		Endif
		
    //Ponto de entrada criado para customizacoes da engenharia 
		If ExistBlock("QNCGQI3")
       ExecBlock("QNCGQI3",.F.,.F.)
		EndIf
	
		IF lTransf
    QnBXPMS(aQI5)
		Endif
	
	END TRANSACTION

	If !Empty(aQI5Aux)
		If QI5->(DbSeek(QI3->QI3_FILIAL+QI3->QI3_CODIGO+QI3->QI3_REV))
			While QI5->(!Eof()) .And. (QI5->QI5_FILIAL+QI5->QI5_CODIGO+QI5->QI5_REV == QI3->QI3_FILIAL+QI3->QI3_CODIGO+QI3->QI3_REV)
				If Ascan(aQI5Aux,{ |x| x == QI5->QI5_MAT }) > 0 .And. Ascan(aUsrPlAcao,{ |x| x == QI5->QI5_MAT }) == 0
				QNCATULEG(QI5->QI5_FILMAT,QI5->QI5_MAT)
				aAdd(aUsrPlAcao,QI5->QI5_MAT)			
				EndIf
		QI5->(DbSkip())
			EndDo
		EndIf
	EndIf


	If lFreeUsdQI3
	Leave1Code()
	FreeUsedCode(.T.)
	EndIf
                                                                      
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna ao valor original de maxcodes ( utilizado por MayiUseCode() )³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetMaxCodes( nMaxCodes )

Return Nil


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ QNCCalcPercHR³ Autor ³Leandro            ³ Data ³ 07/04/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Calcula Percentual de Horas 							      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNCCalcPercHR                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Numero da FNC 	                                  ³±±
±±³			 ³ ExpN2 - % de horas	 	                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQNC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNCCalcPercHR(cHr,cPerc)
Local cHRPerc := (Val(cPerc)*cHr)/100
Return cHRPerc

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ QNCAtuEtapa  ³ Autor ³Leandro            ³ Data ³ 07/04/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atualiza percentual de execucao da etapa via PMS e campo   ³±±
±±³              HREAL                                        		      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNCAtuEtapa                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Codigo da Filial do Plano                          ³±±
±±³			 ³ ExpN2 - Codigo do Plano 	                                  ³±±
±±³			 ³ ExpN3 - Codigo da Revisao do Plano                         ³±±
±±³			 ³ ExpN4 - Codigo da Etapa                                    ³±±
±±³			 ³ ExpN5 - Percentual de Execucao da Etapa                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQNC integrado com o PMS                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNCAtuEtapa(cFil,cPlano,cRev,cEtapa,cPercExec)

Local aAreaORI	:= GetArea()
Local aArea 	:= {}
Local lRet  	:= .F.
Local cSeek 	:= "" 
Local lTransf   := .F.  


	If FUNNAME() == "QNCA070"
	lTransf   :=.T.
	cPercExec := 100
	Endif

DbselectArea("QI5")
DEFAULT cFil := xFilial("QI5")
QI5->(dbSetOrder(4))

cSeek 	:= cFil+cPlano+cRev+cEtapa

	If QI5->(dbSeek(cSeek,.F.))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Validando se a etapa pode estar pertencendo a algum plano de acao que ja foi encerrado ³
	//³no caso por exemplo de uma etapa filha ter sido rejeitada enqto sua irma estava sendo  ³
	//³executada. 																			  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aArea := GetArea()
	
	dbSelectArea("QI3")
	QI3->(dBSetOrder(2))
		If QI3->(dbSeek(xFilial("QI3")+QI5->QI5_CODIGO+QI5->QI5_REV))
			If QI3->QI3_OBSOL == "S"
			lRet := .T.   
			Endif
		Endif
	
	RestArea(aArea)
   
	RecLock("QI5",.F.)		
		If !lRet .OR. lTransf
	
			If QI5->QI5_STATUS <> "5"
				Do case
				case cPercExec >= 0 .And. cPercExec <= 25.5
		       	    QI5->QI5_STATUS := "1"
				case cPercExec > 25.5 .And. cPercExec <= 50.5
		       	    QI5->QI5_STATUS := "2"
				case cPercExec > 50.5 .And. cPercExec < 100
		       	    QI5->QI5_STATUS  := "3"
				case cPercExec = 100
		       	    QI5->QI5_STATUS  := "4"
				EndCase
			Endif
		Else
    	QI5->QI5_STATUS  := "5"  
		Endif
	MsUnlock()
	dbCommit()
	Endif

RestArea(aAreaORI)

Return lRet



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ QNCALTRESP   ³ Autor ³Leandro            ³ Data ³ 09/04/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Altera o responsavel da etapa via PMS	        	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNCALTRESP                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Codigo da Filial do Plano                          ³±±
±±³			 ³ ExpN2 - Codigo do Plano 	                                  ³±±
±±³			 ³ ExpN3 - Codigo da Revisao do Plano                         ³±±
±±³			 ³ ExpN4 - Codigo da Etapa                                    ³±±
±±³			 ³ ExpN5 - Codigo do Novo Responsavel pela Execucao da Etapa  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQNC integrado com o PMS                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNCALTRESP(cFil,cPlano,cRev,cEtapa,cResp)
Local aArea := GetArea()
Local lRet  := .F.

	If !Empty(cResp)
	DbselectArea("QI5")
	DEFAULT cFil := xFilial("QI5")
	QI5->(dbSetOrder(4))	
		If QI5->(MsSeek(cFil+cPlano+cRev+cEtapa))
			If (cResp) <> "STOP"
			RecLock("QI5",.F.)	
			QI5->QI5_MAT:= Alltrim(cResp)
			MsUnlock()
			lRet  := .T.
			Endif
		Endif
	
	RestArea(aArea)
	Endif
	
Return lRet  


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QAltObrigEtp³ Autor ³ Leandro de Souza    ³ Data ³ 09/05/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Altera a obrigatoriedade das Etapas do QNC                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³QAltObrigEtp()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQNC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QAltObrigEtp(cPlano,cRev,cEtapa,lPMS,lRejeita,cCodRej,cDESDEP,cGrpQUO,lIsTMK)
Local aAreaOri 	:= GetArea()
Local aAreaQI5	:= {}
Local aAreaQI3	:= {}
Local aAreaQUP	:= QUP->(GetArea())
Local oDlg
Local oListbox
Local oOk       := LoaDbitmap( GetResources(),"ENABLE")//"LBOK"
Local oNo       := LoaDbitmap( GetResources(),"LBNO")
Local aPend	    := {}
Local nCont     := 0
Local cTitulo   := STR0104 //Escolha a obrigatoriedade de execucao das Pendencias 
Local lRejeite  := .F. 
Local lRet      := .F.
Local lCancela  := .F.
Local aArea 	:= {}
Local aButtons  := {}
Local nOptAVSO	:= 2
Local aEtaPar 	:= {}
Local cObriPar  := ""
Local aCabec    := {}
Local aParPai   := {}
Local nAuxPai   := 0
Local cQTmkPms  := GetMv("MV_QTMKPMS")

Default lPMS     := .F.   
Default cGrpQUO  := ""
Default lRejeita := .F.
Default lIsTMK   := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Validando se a etapa pode estar pertencendo a algum plano de acao que ja foi encerrado ³
//³no caso por exemplo de uma etapa filha ter sido rejeitada enqto sua irma estava sendo  ³
//³executada. 																			  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aArea := GetArea()

dbSelectArea("QI3")
aAreaQI3 := GetArea()
QI3->(dBSetOrder(2))
	If QI3->(MsSeek(xFilial("QI3")+cPlano+cRev))
		If QI3->QI3_OBSOL == "S" .OR. !EMPTY(QI3->QI3_ENCREA)
			If !IsBlind()
			Aviso(STR0007,STR0109, {"OK"})//"Atencao"##"Esta etapa esta sendo encerrada automaticamente porque o plano ao qual ela pertence esta encerrado."
			Endif
		lRet := .F.   
	    lCancela  := .T.
		Else
		QUP->(dbSetOrder(1))
		QUP->(dbSeek(xFilial("QUP")+QI3->QI3_MODELO))
			While !QUP->(EOF()) .And. QUP->(QUP_FILIAL+QUP_GRUPO) == xFilial("QUP")+QI3->QI3_MODELO
				If QUP->QUP_ETAPRL == "1"
				aEtaPar := StrTokarr(AllTrim(QUP->QUP_ETAPAP),";")
					If lIsTMK .And. QUP->QUP_TPACAO == cEtapa .And. nAuxPai == 0 //vejo se e primeira etapa
					//-- Monta string para analise de existencia de etapa paralela nao obrigatoria
					aEval(aEtaPar, {|x| cObriPar += Posicione("QUP",1,xFilial("QUP")+QI3->QI3_MODELO+x,"QUP_OBRIGA")})
					Else
					aEval(aEtaPar, {|x| aAdd(aParPai,{QUP->QUP_TPACAO,x})})
					EndIf
				EndIf
			
			nAuxPai := 1
			QUP->(dbSkip())
			End
		EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se na integracao com TMK nao houver etapa paralela nao obrigatoria para   ³
	//³ a primeira etapa, cancela a exibicao da tela pois nao ha o que selecionar ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lIsTMK .And. !('2' $ cObriPar)
		lCancela := .T.
		EndIf
	Endif

RestArea(aArea)	

DbSelectArea("QI5")  
aAreaQI5 := GetArea()

	If !lCancela
	QI5->(dbSetOrder(1))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carregando as pendencias referente ao plano de acao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If QI5->(dBSeek(xFilial("QI5")+cPlano+cRev))
			While QI5->(!Eof()) .And. QI5->QI5_CODIGO+QI5->QI5_REV == cPlano+cRev
				If QI5->QI5_STATUS <> "4" .Or. QI5->QI5_STATUS <> "5"
					If QI5->QI5_AUXOBR == "1"
					Aadd(aPend,{.F.,QI5->QI5_SEQ,ALLTRIM(FQNCDESETA(QI5->QI5_TPACAO)),"Sim",QI5->QI5_PEND == "S",Iif(Empty(QI5_TAREFA) .And. (QI5->QI5_PEND <> 'N' .Or. Alltrim(cQTmkPms) == '4'),.T.,.F.) })
					Else
						If QI5->QI5_OBRIGA == "1"
					  	Aadd(aPend,{.F.,QI5->QI5_SEQ,ALLTRIM(FQNCDESETA(QI5->QI5_TPACAO)),"Nao",QI5->QI5_PEND == "S",Empty(QI5_TAREFA) })
						Else
						Aadd(aPend,{.T.,QI5->QI5_SEQ,ALLTRIM(FQNCDESETA(QI5->QI5_TPACAO)),"Nao",QI5->QI5_PEND == "S",Empty(QI5_TAREFA) })
						Endif
					Endif
				
				nAuxPai := aScan(aParPai,{|x| x[2] == QI5->QI5_TPACAO})
				aAdd(aTail(aPend),If(Empty(nAuxPai),"",FQNCDESETA(aParPai[nAuxPai,1])))
				
				Endif
			QI5->(DbSkip())
			nCont := nCont +1

			Enddo
		EndIf
	
		If !Empty(aPend) .and. !IsBlind()
		DEFINE MSDIALOG oDlg FROM 05,16  TO 440,870 TITLE cTitulo PIXEL STYLE DS_MODALFRAME //larguraxxcumprimento
		
		aAdd(aCabec,"")
		aAdd(aCabec,TitSX3("QI5_SEQ")[1])
		aAdd(aCabec,TitSX3("QI5_DESCRE")[1])
		aAdd(aCabec,TitSX3("QI5_OBRIGA")[1])	
		aAdd(aCabec,STR0189) //Etp. Pai Paralelismo
			
		
		@ 005,003 LISTBOX oListBox VAR cQI5	FIELDS SIZE 340,200 OF oDlg PIXEL ;
			ON DBLCLICK (fSelecPen(oListBox:nAt,@aPend,oListBox,cPlano,cRev,cEtapa,lRejeite,@lRet),oListBox:Refresh(.T.)) ;
			SIZE 340,200 OF oDlg PIXEL OemToAnsi(STR0190) //Pendencia(s):
		
		oListBox:aHeaders := aCabec
		oListBox:SetArray(aPend)
		oListBox:cToolTip := OemToAnsi(STR0191) //Selecione as etapa que devem ser executadas !
		oListBox:aColSizes := {5,40,120,40,120}
		oListBox:bLine  := {||{QNCCorLed(aPend,oListBox:nAt),aPend[oListBox:nAt,2],aPend[oListBox:nAt,3],aPend[oListBox:nAt,4],aPend[oListBox:nAt,7]}}

			If lPMS
			DEFINE SBUTTON FROM 080,370 TYPE 1 ACTION (lRet := QNC050PMS(cPlano,cRev,cEtapa,@lRejeite,oDlg)) ENABLE OF oDlg PIXEL //Confirmar 
			DEFINE SBUTTON FROM 100,370 TYPE 2 ACTION (oDlg:End(), lRet := .F.) ENABLE OF oDlg PIXEL 
			@ 130,350 TO 160,420 Label STR0192 OF oDlg PIXEL COLOR CLR_RED //Rejeição/Revisão
			DEFINE SBUTTON oBTNRej TYPE 3 FROM 140,370 ACTION (lRejeite := .T., lRet := QNC050PMS(cPlano,cRev,cEtapa,lRejeite,oDlg)) ENABLE OF oDlg PIXEL //Rejeitar
			oBTNRej:cCaption := STR0193 //Rejeitar
			oBTNRej:CTOOLTIP := STR0194 //Rejeitar/Revisar Plano
			Else
			DEFINE SBUTTON FROM 080,370 TYPE 1 ACTION (oDlg:End(), lRet := .T.) ENABLE OF oDlg PIXEL 
			DEFINE SBUTTON FROM 100,370 TYPE 2 ACTION (oDlg:End(), lRet := .F.) ENABLE OF oDlg PIXEL 
			Endif

		@ 020,350 TO 060,420 Label STR0195 OF oDlg PIXEL COLOR CLR_BLUE //Legenda :

		@ 030,352 BITMAP oBmp1 ResName "BR_AZUL" OF oDlg Size 10,10 NoBorder When .F. Pixel 
		@ 030,362 SAY STR0196 OF oDlg PIXEL //Etapa Atual

		@ 050,352 BITMAP oBmp2 ResName "BR_VERDE" OF oDlg Size 10,10 NoBorder When .F. Pixel 
		@ 050,362 SAY STR0197 OF oDlg PIXEL //Etapa Pendente     
		
		@ 040,352 BITMAP oBmp2 ResName "BR_VERMELHO" OF oDlg Size 10,10 NoBorder When .F. Pixel 
		@ 040,362 SAY STR0204 OF oDlg PIXEL //Etapa Baixada
	                                                                          	
		ACTIVATE MSDIALOG oDlg CENTERED
		EndIf

		If lRet .AND. lRejeite
			If !IsBlind()
			nOptAVSO := Aviso(STR0198 +QI3->(ALLTRIM(QI3_CODIGO)+" / "+QI3_REV),STR0199,{STR0138,STR0139},2,STR0200) //Plano de Ação: ## Confirma modificação/rejeição do plano/sequencia atual ? ## Rejeição/Revisão de Plano de Ação/FNC !
				If nOptAVSO == 1
				QI5->(dbSetOrder(4))
				QI5->(MsSeek(xFilial("QI5")+cPlano+cRev+cEtapa,.F.))
				cCodRej := QApontaRej(cEtapa,@cDESDEP,@cGrpQUO)
					If Empty(cCodRej)
					lRet := .F.
					EndIf
				Else
				lRet := .F.
				EndIf
			EndIf
		EndIf

	//Variavel de controle usado pelo PMS
	lRejeita:=  lRejeite 

	EndIf

RestArea(aAreaQUP)
RestArea(aAreaQI5)
RestArea(aAreaQI3)
RestArea(aAreaOri)

	If lPMS .And. !lRet
		If !IsBlind()
		Aviso(STR0007,STR0154, {"OK"})//"Atencao"##"Processo de Rejeicao cancelado, por falta de Cadastro de Permissao entre etapa ou por cancelamento normal. "
		Endif
	lRejeita := .F.
	Endif

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fSelecPen ³ Autor ³ Leandro				³ Data ³ 10/04/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Tratar o click da pergunte                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fSelecPen                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQNC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fSelecPen(nSeq,aPend,oListBox,cPlano,cRev,cEtapa,lRejeite,lRet)

Local lPend 	:= .F.                   
Local aParale	:= {}
Local aGrpEtp	:= {}
Local aEtapas	:= {}
Local aAuxPrl	:= {}
Local cUltEtp	:= ""
Local cEtpPrl 	:= ""
Local nX 		:= 0
Local nY 		:= 0
Local nZ 		:= 0
Local aSeqEtp	:= {}
Local cSeqEtp	:= ""
Local nPos      := ""
              
nPos:= aScan(aPend,{|lLin| lLin[5] .AND. !lLin[6] })
         
	If !aPend[nSeq,5] .AND. !aPend[nSeq,6]
	Aviso(STR0007,STR0201 , {"OK"})//"Atencao"##"Esta etapa se encontra baixada e nao podera ser alterada!"       	         
	ElseIf Empty(nPos) .OR. aPend[nSeq,2] >= aPend[nPos,2]
	DbSelectArea("QI5")		//Ação Corretiva x Ações 
	QI5->(dbSetOrder(1))    //QI5_FILIAL+QI5_CODIGO+QI5_REV+QI5_SEQ
		If QI5->(DbSeek(xFilial("QI5")+cPlano+cRev+Alltrim(aPend[nSeq,2])))
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifico qual o grupo de etapas está o plano de ação					³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
		DbSelectArea("QI3")	//Plano de Ações
		DbSetOrder(2)		//QI3_FILIAL+QI3_CODIGO+QI3_REV
			If Dbseek( xFilial("QI3")+QI5->QI5_CODIGO+QI5->QI5_REV )
			
			cModelo := QI3->QI3_MODELO
			
				If QI5->QI5_OBRIGA != "1"
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Adiciono todas as ações do grupo de etapas								³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("QUP") //Grupo x Etapa
				DbSetOrder(1)		//QUP_FILIAL+QUP_GRUPO+QUP_TPACAO
					If Dbseek( xFilial("QUP")+QI3->QI3_MODELO+QI5->QI5_TPACAO )
						If QUP->QUP_ETAPRL # "1"
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Adiciono todas as ações do grupo de etapas								³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						DbSelectArea("QUP") //Grupo x Etapa
						DbSetOrder(2)		//QUP_FILIAL+QUP_GRUPO+QUP_SEQUEN+QUP_TPACAO
							If Dbseek( xFilial("QUP")+QI3->QI3_MODELO )
								While !Eof() .And. xFilial("QUP") == xFilial("QUP") .And. Alltrim(QUP->QUP_GRUPO) == Alltrim(QI3->QI3_MODELO)
								
								Aadd (aEtapas, {QUP->QUP_SEQUEN,;	//1-Sequencia
												QUP->QUP_TPACAO,;	//2-Etapa          
												QUP->QUP_ETAPRL,;   //3-Etapa Paralela (1-Sim/2-Não)
												QUP->QUP_ETAPAP})  	//4-Etapas Paralelas
								DbSkip()
								EndDo
							EndIF
				        
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifico se o no grupo de etapas há alguma etapa paralela				³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						nPosAux := Ascan(aEtapas,{ |x| AllTrim(x[3]) == "1" }) 
				
							If nPosAux > 0
							
								For nX := 1 To Len(aEtapas)
								
									If AllTrim(aEtapas[nX][3]) == "1"
						   			
						   			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³Verifico a posição da Primeira etapa paralela 							³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									nPosPri := Ascan(aEtapas,{ |x| AllTrim(x[2]) == AllTrim(aEtapas[nX][2]) }) 
						   			
						   			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Caso existam etapas paraleleas, verifico quais são elas					³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                  
						    	   	aParale := StrTokarr(AllTrim(aEtapas[nX][4]),";")
									     
										For nZ := 1 To Len(aParale)
									
									    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³ Verifico a sequencia da ultima etapa das etapas paralelas				³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										DbSelectArea("QUP") //Grupo x Etapa
										DbGoTop()
										DbSetOrder(1)		//QUP_FILIAL+QUP_GRUPO+QUP_TPACAO
											If Dbseek( xFilial("QUP")+cModelo+aParale[nZ])
									    	Aadd (aSeqEtp, {QUP->QUP_SEQUEN,;	//1-Sequencia
									    					QUP->QUP_TPACAO })  //2-Codigo da Acao
											EndIf
								    
										Next
									
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Verifico a sequencia da ultima etapa das etapas paralelas				³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ							    
										If Len(aSeqEtp) > 0
								    	aSeqEtp := aSort(aSeqEtp,,,{|x,y| AllTrim(x[1]) < AllTrim(y[1]) })
										cUltEtp := aSeqEtp[Len(aSeqEtp)][2]
										EndIf
														    
				   		   			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Verifico a sequencia da ultima etapa das etapas paralelas				³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									DbSelectArea("QUP") //Grupo x Etapa
									DbGoTop()
									DbSetOrder(1)		//QUP_FILIAL+QUP_GRUPO+QUP_TPACAO
										If Dbseek( xFilial("QUP")+cModelo+cUltEtp)
								    	cSeqEtp := QUP->QUP_SEQUEN
										EndIf
									
				   		   			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Adiciono do Array todas as etapas até encontrar a ultima das paralelas	³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										If !Empty(cSeqEtp)
										DbSelectArea("QUP") //Grupo x Etapa
										DbGoTop()
										DbSetOrder(2)		//QUP_FILIAL+QUP_GRUPO+QUP_SEQUEN+QUP_TPACAO
											If Dbseek( xFilial("QUP")+cModelo+aEtapas[nX][1]+aEtapas[nX][2] )
												While !Eof() .And. xFilial("QUP") == xFilial("QUP") .And. Alltrim(QUP->QUP_GRUPO) == Alltrim(cModelo).And.;
												AllTrim(QUP->QUP_SEQUEN) <= AllTrim(cSeqEtp)
												Aadd (aGrpEtp, {QUP->QUP_SEQUEN,;	//1-Sequencia
																QUP->QUP_TPACAO,;	//2-Etapa          
																QUP->QUP_ETAPRL })  //3-Etapa Paralela (1-Sim/2-Não)
												DbSkip()
													EndDo
											EndIF
										EndIf
					   		
									EndIf
					   	
								Next
					    
							EndIf
					
						EndIf
						
					EndIf
		
				EndIf
	
			EndIf
		
			If QI5->QI5_PEND == "S"
			Aviso(STR0007,STR0202,{"OK"})//"Atencao"##"" Esta etapa esta em execução e não pode ser alterada."
			ElseIf QI5->QI5_AUXOBR == "1"
			Aviso(STR0007,STR0110, {"OK"})//"Atencao"##"Esta etapa e obrigatoria e nao podera ser alterada!"       	
			Else
			RecLock("QI5",.F.)		
				If aPend[nSeq,1] == .T.
	        	lPend := .F.
	        	QI5->QI5_OBRIGA := "1"
				Else
				lPend := .T.
				QI5->QI5_OBRIGA := "2"
				Endif
			MsUnLock()			
			FKCOMMIT()
			aPend[nSeq,1]:= lPend
			oListBox:Refresh()
			lRet:= .T.
			Endif
		Else//Rejeicao do PMS
			If (aPend[nSeq,1])
			aPend[nSeq,1] := .F.
			lRejeite      := .T.	
			Else
			aPend[nSeq,1] := .T.
			lRejeite      := .F.	
			Endif
		oListBox:Refresh()
		lRet     := .T.
		//Realizado o seek abaixo para efetuar o posicionamento 
		QI5->(DbSeek(xFilial("QI5")+cPlano+cRev+cEtapa))
		Endif
	Else
	Aviso(STR0007,STR0203, {"OK"})//"Atencao"##"Não é possível selecionar uma etapa anterior a etapa atual!"       	 	

	EndIf

Return 


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QApontaRej  ³ Autor ³ Leandro de Souza    ³ Data ³ 15/04/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³No processo de rejeicao da etapa, apontar pra qual etapa e/ ³±±
±±³          ³ou grupo deseja voltar.					                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³QApontaRej()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da Etapa Atual 							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQNC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QApontaRej(cETPATU,cDESDEP,cGrpQUO)

Local oDlg
Local oListBox
Local oOk    := LoaDbitmap( GetResources(),"ENABLE")//"LBOK"
Local oNo    := LoaDbitmap( GetResources(),"LBNO")
Local aEtapa := {}
Local cEtapa := ""
Local cGrupo := ""
Local nI    
Local lRetSXB  := .F.
Local aAreaQUP := {}
Local cTPRej   := ""
Local cTipo    := ""

PRIVATE  lConfOK := .F.
PRIVATE nRecQUS := 0

Default cDESDEP := ""
Default cGrpQUO := ""

dbSelectArea("QUP")
aAreaQUP := GetArea()

DbSelectArea("QUS")  
QUS->(dbSetOrder(2))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carregando as permissoes de etapas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If QUS->(DbSeek(xFilial("QUS")+	AllTrim(cETPATU)))
		While QUS->(!Eof()) .And. QUS->QUS_ETPATU == cETPATU
			If QUS->QUS_REJPL == "1"
	  		cTPRej := STR0138//Sim
	  		cTipo  := "1"
			Else
			cTPRej := STR0139//Nao
			cTipo  := "2"
			Endif
		Aadd(aEtapa,{.T.,QUS->QUS_ETPPRX,QUS->QUS_DESCRI,cTPRej,QUS->QUS_GRAGR, QUS->(Recno()),cTipo })			
		QUS->(dbSkip())
		Enddo
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada criado para filtrar as permissoes de rejeicao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("QNCFILREJ")
	aEtapa := ExecBlock("QNCFILREJ", .f., .f.,{aEtapa})
	EndIf

	If Len(aEtapa) > 0
	DEFINE MSDIALOG oDlg FROM 05,16  TO 300,600 TITLE OemToAnsi(STR0107) PIXEL //"Selecione a Etapa que devera iniciar o processo "

	@ 005,003 LISTBOX oListBox VAR cQI5	FIELDS HEADER " ",TitSX3("QUS_ETPPRX")[1],TitSX3("QUS_DESCRI")[1],TitSX3("QUS_REJPL")[1],TitSX3("QUS_GRAGR")[1];
					           SIZE 285,100 OF oDlg PIXEL ;
					           ON DBLCLICK (fSelecEtapa(@aEtapa,oListBox:nAt,@cEtapa,oListBox,@nRecQUS),oListBox:Refresh(.T.))///;
				
	oListBox:SetArray(aEtapa)                                               
	oListBox:cToolTip := OemToAnsi(STR0108)//"Duplo click para selecionar a etapa de retorno!"	
	oListBox:bLine  := {||{If(aEtapa[oListBox:nAt,1],oNo,oOk),aEtapa[oListBox:nAt,2],aEtapa[oListBox:nAt,3],aEtapa[oListBox:nAt,4],aEtapa[oListBox:nAt,5]}}

	DEFINE SBUTTON FROM 110,255	S	 TYPE 1 ACTION {|| lConfOK := .T., oDlg:End() }  ENABLE OF oDlg PIXEL
									                                    		
	ACTIVATE MSDIALOG oDlg CENTERED
	
	EndIf

	If lConfOk .And.nRecQUS > 0
	dbSelectArea("QUS")
	MsGoTo(nRecQUS)
		If ALLTRIM(QUS->QUS_GRAGR) == "*"
		lRetSXB := ConPad1(,,,"QUO",,,.F.)
			If lRetSXB
			cGrupo  := QUO->QUO_GRUPO
			cDESDEP := QUO->QUO_DEPTO
			DbselectArea("QUP")                  
			DbSelectArea(1)
				If Empty(QUS->QUS_ETPPRX)
				cEtapa := ""
				Else
				cEtapa := QUS->QUS_ETPPRX
				EndIf
			QUP->(dbSetOrder(1))
				If QUP->(MsSeek(xFilial("QUP")+cGrupo+cEtapa,.F.))
					If Empty(cEtapa)
			   		QUP->(dbSetORder(2))	///<= Se não há etapa de rejeição definida usa a 1ª em ordem de sequencia !
			   		QUP->(MsSeek(xFilial("QUP")+cGrupo,.T.))
					EndIf
			   cEtapa := QUP->QUP_TPACAO 
				cGrpQUO := cGrupo
				Else
			   cEtapa := ""
			   cGrupo := ""
				Endif
			Else
		    cEtapa := ""
		    cGrupo := ""
			Endif
		ElseIf !Empty(QUS->QUS_GRAGR)
		cGrupo	:= QUS->QUS_GRAGR
		cGrpQUO := QUS->QUS_GRAGR
		cEtapa 	:= QUS->QUS_ETPPRX
		dbSelectArea("QUO")
		dbSetOrder(1)
			If MsSeek(xFilial("QUO")+cGrpQUO,.F.)
			cDESDEP := QUO->QUO_DEPTO
			dbSelectArea("QUP")
			dbSetOrder(1)
				If Empty(QUS->QUS_ETPPRX)
				cEtapa := ""
				Else
				cEtapa := QUS->QUS_ETPPRX
				EndIf
				If QUP->(MsSeek(xFilial("QUP")+cGrupo+cEtapa,.F.))
					If Empty(cEtapa)
			   		QUP->(dbSetORder(2))	///<= Se não há etapa de rejeição definida usa a 1ª em ordem de sequencia !
			   		QUP->(MsSeek(xFilial("QUP")+cGrupo,.T.))
					EndIf
			    cEtapa := QUP->QUP_TPACAO 
				cGrpQUO := cGrupo
				Else
			   cEtapa := ""
			   cGrupo := ""
				Endif
			EndIf
		Else
			If QUS->QUS_REJPL = "1"    //estava invertido
			cEtapa 	:= "5"
			//cEtapa 	:= QUS->QUS_ETPPRX
			Else
			//cEtapa 	:= "5"
			cEtapa 	:= QUS->QUS_ETPPRX
			Endif
		EndIf
	Else
	cDESDEP := ""
	cGrpQUO	:= ""
	cEtapa  := ""
	EndIf

	If Empty(cEtapa)
	cEtapa := ""
	EndIf

RestArea(aAreaQUP)

Return cEtapa


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fSelecEtapa ³ Autor ³ Leandro			    ³ Data ³ 16/04/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Tratar o click da etapa                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fSelecEtapa                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQNC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fSelecEtapa(aEtapa,nOrdem,cEtapa,oList,nRecQUS)
Local nI
DEFAULT nRecQUS := 0

	For nI := 1 TO Len(aEtapa)
		If nI == nOrdem
			If aEtapa[nI,7] == '1' //1 = Rejeita completamete o Plano e 2 == Rejeita somente a Etapa
    		cEtapa := '5'
			Else
	    	cEtapa := aEtapa[nI,2]
			Endif
    	aEtapa[nI,1]:= .F.
    	nRecQUS := aEtapa[nI,Len(aEtapa[nI])-1]
		Else
		aEtapa[nI,1]:= .T.
		Endif
	Next
oList:Refresh()

Return 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QNC050PMS    ºAutor  ³Leandro          º Data ³  23/08/2008 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Posicionar o Plano, a Revisao e a Etapa no arquivo QI5,     º±±
±±º			 ³para em seguida executar a rotina de baixa de pendencia	  º±±														  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe	 ³QNC050PMS(Plano, Revisao, Etapa )           				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Integracao com o PMS                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function QNC050PMS(cPlano,cRev,cEtapa,cRejeicao,oList,cETPRobo)
	Local lRet  := .T.

	Default cETPRobo := ""

	DbselectArea("QI5")
	QI5->(dbSetOrder(4))

	If QI5->(dbSeek(xFilial("QI5")+cPlano+cRev+cEtapa))
		If !cRejeicao
			If !QNC50VALPEND()
				lRet := .T.
			Else
				lRet := .F.
			Endif
		Endif
	Endif

	If Type("oMainWND") == "O"
		oList:End()
	Endif

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³QNCGeraTarefa ³ Autor ³Leandro            ³ Data ³ 30/04/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Gera Tarefa no PMS									      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNCGeraTarefa                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Numero da FNC 	                                  ³±±
±±³			 ³ ExpN2 - Revisao da FNC	                                  ³±±
±±³			 ³ ExpN3 - Area 			                                  ³±±
±±³			 ³ ExpN4 - Plano Filho		                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQNC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNCGeraTarefa(cFNC,cFil,cPlano,cRev,cEtapa,aDatas,cFNCRev)
Local cObs   		 := ""
Local cDescr 	     := ""
Local cTexto         := ""
Local aAreaQI5       := {}
Local cRESP          := "2"
Local aCab           := {}
Local aRec           := {} 
Local lMsErroAuto    := .F.
Local cHr            := ""
Local nLQI2FNC		 := 0
Local cPMSTarefa	 := ""
Local lContinua		 := .T.
Local cThreadID      := THREADID() 
Local cAviso   		 := ""	
Local aPMS           := {}
Local aAF9			 := {}
Local aRet           := {}
Local lRejeicao
Local nSaldo
Local aAreaAF8
Local nRecurso := 0
Local aRecAdic := {}  // vetor dos recursos adicionais
Local aVetTemp := {}  // vetor temporario do recurso principal
Local lAltRec	  := SuperGetMv("MV_PMSAREC",,.T.) // Altera responsável da etapa ao incluir um novo recurso?
Local nTimerQNC  := 10 // Tempo padrao em segundos para tela de aviso de mudança de tarefa 
Local nRetTimer  := 0
local lAuto	      := .F.

dbSelectArea("AF8")
lRejeicao := AF8->AF8_PAR002=="1" .Or. AF8->AF8_PAR002=="2"

dbSelectArea("QI2")
nLQI2FNC := Len(QI2->QI2_FNC)

DEFAULT cFNC	:= ""
DEFAULT cFIL	:= ""
DEFAULT cFNCRev := ""

lAuto := Iif(type('lTmk503Auto')=='L',lTmk503Auto,.F.) 
// Ponto de Entrada para alterar o tempo padrao da tela de aviso de mudança de tarefa
	If ExistBlock("QNCTIMER")
	nRetTimer := ExecBlock("QNCTIMER",.F.,.F.)
		If ValType(nRetTimer) == 'N'
		nTimerQNC := nRetTimer
		Endif
	Endif

DbselectArea("QI5")
QI5->(dbSetOrder(4))

	If QI5->(dbSeek(cFil+cPlano+cRev+cEtapa))
	DbselectArea("QI2")
	QI2->(dbSetOrder(2))

		If QI2->(MsSeek(xFilial("QI2")+PADR(cFNC,nLQI2FNC)+cFNCRev))
			If !Empty(QI2->QI2_COMEN)
			cObs   := QN030INIMEM(QI2->QI2_COMEN)
			Else
			cObs   := ""
			EndIf
		Else
    	cObs   := "FILIAL+FNC+REVISAO não encontrada: "+xFilial("QI2")+PADR(cFNC,nLQI2FNC)+cREV
		Endif

		If Empty(cDescr)
		cDescr := "[QNC PLANO: "+QI5->QI5_CODIGO+"/"+QI5->QI5_REV+"] ETAPA: "+QI5->QI5_TPACAO
			If !Empty(QI5->QI5_DESCRE)
			cDescr += " ("+ALLTRIM(QI5->QI5_DESCRE)+")"
			Else
			cDescr += " ("+ALLTRIM(FQNCDESETA(QI5->QI5_TPACAO))+")" 
			EndIf
		EndIf

		If Empty(cObs)
		cObs := cDescr
		EndIf
    
		IF QI5->QI5_TRFACT <> "0" /// Alocação Tarefa PMS: 0=Não Gera; 1=Força alocação QNC; 2=Semi-Auto ou 3=Automatica

		cPMSTarefa := PmsNxtAF9( Type("oMainWnd") == "O","", QI5->QI5_PROJET,PMSAF8VER(QI5->QI5_PROJET),,QI5->QI5_PRJEDT)

			If !Empty(cPMSTarefa)
			nPMSDURAC := QNCPrzHR2(QI5->QI5_PRZHR,"H"			,"H"		,"D"				,"H")

			/// Busca algum responsável QNC com amarração para gravar no QI5. Para a tarefa já tem no aRequisitaResp.
			cRecPMS := ""
			            
				If QNCRespDef(@cRecPMS,"",QI5->QI5_TPACAO,QI2->QI2_DESDEP,QI5->QI5_CODIGO,QI5->QI5_REV,.T.) == "STOP"
				Return("STOP")            
				Endif
            
				If lRejeicao .And. QI5->QI5_REV<>"00"
				aAreaAF8 := AF8->(GetArea())
				AF8->(dbSetOrder(1))
				AF8->(dbSeek( xFilial("AF8")+QI5->QI5_PROJET ))
				nSaldo := GetSaldoAnt( QI5->QI5_CODIGO, QI5->QI5_REV, QI5->QI5_TPACAO,nPMSDURAC )
				aRet := PMSDTaskF(aDatas[1],aDatas[2],AF8->AF8_CALEND,nSaldo,QI5->QI5_PROJET,alltrim(cRecPMS))
				aDatas[3] := aRet[3]
				aDatas[4] := aRet[4]
				nPMSDURAC := Iif(nSaldo > 0,nSaldo,0.00)
				RestArea(aAreaAF8)
				EndIf
		   	
		   	aCab  := { 	{"AF9_PROJET" ,QI5->QI5_PROJET  			,Nil},;//Codigo do Projeto	
						{"AF9_REVISA" ,PMSAF8VER(QI5->QI5_PROJET)	,Nil},;//Obtem a revisao do Projeto	
						{"AF9_EDTPAI" ,QI5->QI5_PRJEDT  			,Nil},;//Codigo da EDT Pai
						{"AF9_TAREFA" ,cPMSTarefa  					,Nil},;//Codigo da Tarefa
						{"AF9_HDURAC" ,nPMSDURAC					,Nil},;//Horas para a Execucao da Etapa da Etapa //Hrs2Min(
						{"AF9_START"  ,aDatas[1]					,Nil},;//Data de inicio prevista retornada pelo PMS	
						{"AF9_HORAI"  ,aDatas[2]     				,Nil},;//Hora de inicio prevista retornada pelo PMS 
						{"AF9_FINISH" ,aDatas[3] 					,Nil},;//Data de FIM prevista retornada pelo PMS	
						{"AF9_HORAF"  ,aDatas[4]					,Nil},;//Hora de FIM prevista retornada pelo PMS
						{"AF9_FNC"    ,AllTrim(cFNC)    			,Nil},;//Codigo da FNC
						{"AF9_REVFNC" ,AllTrim(cFNCRev)    			,Nil},;//Revisao da FNC
						{"AF9_ACAO"   ,QI5->QI5_CODIGO  			,Nil},;//Codigo do Plano de Acao
						{"AF9_REVACA" ,QI5->QI5_REV     			,Nil},;//Revisao do Plano
						{"AF9_TPACAO" ,QI5->QI5_TPACAO  			,Nil},;//Codigo da Etapa 
						{"AF9_TIPPAR" ,QI5->QI5_TPACAO  			,Nil},;//Codigo da Etapa  
						{"AF9_DESCRI" ,cDescr           			,Nil},;//Decricao cadastrada na abertura da FNC
						{"AF9_OBS"    ,cObs             			,Nil} }//Observacao cadastrada na abertura da FNC
			
			
			AADD(aCab, {"AF9_TPHORA", IIf(Val(QI5->QI5_REV)>0,"2","1"), Nil}) //Tipo de horas da tarefa	
			
				If nPMSDURAC <= 0
				nPMSDURAC := 1
				EndIf
			aRec :=	{{{"AFA_ITEM"	 	,StrZero(1, TamSX3("AFA_ITEM")[1])	,Nil},; 
					{"AFA_RECURS"	, alltrim(cRecPMS)						,Nil},;
					{"AFA_QUANT"	, nPMSDURAC									,Nil},;
					{"AFA_ALOC"	, 100	 										,Nil},;
					{"AFA_DATPRF"	, aDatas[1]	 								,Nil},;
					{"AFA_RESP"	, 1	        								,Nil}}}

			//-- Mais de um recurso na etapa
				if QI5->QI5_TRFACT $ "12"  // se forca a alocacao ou e semi-automatica
				// carrega os recursos adicionais, e copia o recurso principal para o ultimo elemento  
				// do vetor de recursos e em seguida copia este elemento e altera apenas o codigo do recurso, 
				// desta forma mantem as caracteristicas da alocacao do recurso principal. 
				// Sendo que o responsavel e o recurso principal (ultimo do vetor) e os demais nao sao responsaveis
    	   		aRecAdic := StrTokarr(AllTrim(QI5->QI5_MAT2),";")
				aVetTemp := Aclone(aRec[1])
				aRec := {}
				
				// se o paremetro estiver .T. deve gravar o responsavel por ultimo pois na gravacao
				// da AFA no PMSA203, o ultimo recurso ficara como responsavel na QI5
					if lAltRec
						For nRecurso := 1 to Len(aRecAdic)
	  	   				Aadd(aRec, Aclone(aVetTemp))   
	  	   				aRec[Len(aRec),1,2] := Strzero(Len(aRec),2)
	  	   				aRec[Len(aRec),2,2] := RDZRETENT("QAA",xFilial("QAA")+aRecAdic[nRecurso],"AE8",,,,.F.,.T.)
	  	   				aRec[Len(aRec),6,2] := 2  // Responsavel = Nao
						Next
				
					// grava o responsável por ultimo
	   				Aadd(aRec, Aclone(aVetTemp))
  	   				aRec[Len(aRec),1,2] := Strzero(Len(aRec),2)
	   				aRec[Len(aRec),6,2] := 1  // Responsavel = Sim
					Else
					// grava o responsável primeiro
	   				Aadd(aRec, Aclone(aVetTemp))
  	   				aRec[Len(aRec),1,2] := Strzero(Len(aRec),2)
	   				aRec[Len(aRec),6,2] := 1  // Responsavel = Sim

						For nRecurso := 1 to Len(aRecAdic)
	  	   				Aadd(aRec, Aclone(aVetTemp))   
	  	   				aRec[Len(aRec),1,2] := Strzero(Len(aRec),2)
		  	   			aRec[Len(aRec),2,2] := RDZRETENT("QAA",xFilial("QAA")+aRecAdic[nRecurso],"AE8",,,,.F.,.T.)
		  	   			aRec[Len(aRec),6,2] := 2  // Responsavel = Nao
						Next
					Endif
				Endif
			
				If ExistBlock("QGERAAF9")
	   			aAF9 := ExecBlock("QGERAAF9",.F.,.F.,{aCab})
					If ValType(aAF9) == "A" .And. Len(aAF9) > 0
					aCab := aClone(aAF9)
					EndIf
				EndIf
			
				If ExistBlock("QGERATRF")
	   			aPMS := ExecBlock("QGERATRF",.F.,.F.,aRec)
					If ValType(aPMS) == "A" .and. Len(aPMS) > 0
					aRec := aClone(aPMS)
					EndIf
				EndIf
			 		
				BEGIN TRANSACTION
				aAreaQI5 := QI5->(GetArea())
				MsExecAuto({|x,y,z| PMSA203(3, , x, y, , , , , z)} ,"000", aCab , aRec )
				
				QI5->(RestArea(aAreaQI5))                                          
					If !lMsErroAuto .AND. Empty(NomeAutoLog())	//Se não ocorreu erro e gerou tarefa
					RecLock("QI5",.F.)
					QI5->QI5_TAREFA := cPMSTarefa     //Registra a tarefa gerada no QNC
					QI5->QI5_PEND	:= "S"
					MsUnLock()
						If !IsBlind()
						// Projeto TDI - TEGFFJ 
						// exibicao do numero do chamado na tela final de alocacao
						cAviso := CRLF+"Chamado: "+QI2->QI2_NCHAMA
						cAviso += CRLF+"FNC:"+cFNC
						cAviso += CRLF+"Plano: "+cPlano+" - "+cRev 
						cAviso += CRLF+"Etapa: "+ALLTRIM(FQNCDESETA(QI5->QI5_TPACAO))
						cAviso += CRLF+"Recurso alocado: "+Posicione('QAA',1,xFilial('QAA')+QI5->QI5_MAT,'QAA_NOME')
						// ordena o vetor para que o responsavel fique no inicio
						aRec := Asort(aRec,,,{|d,e|  d[6,2] < e[6,2] } )
						//-- Mais de um recurso na etapa
							if Len(aRec) == 1
							cAviso += CRLF+"Recurso alocado: "
							Else
							cAviso += CRLF+"Recursos alocados : "+CRLF
							Endif

							For nRecurso := 1 to Len(aRec)
							cCodMat := Substr(RDZRetEnt("AE8",xFilial("AE8")+aRec[nRecurso,2,2],"QAA",,,.F.,.T.),3,Len(QAA->QAA_MAT))
							cAviso += "   "+if(aRec[nRecurso,6,2]== 1,"* ","  ")+Alltrim( aRec[nRecurso,2,2])+ " "+;
							Posicione('QAA',1,xFilial('QAA')+cCodMat,'QAA_NOME') + CRLF
							Next
						
						cAviso += CRLF
							If !lAuto
							AvisoQTimer(STR0117,cAviso,{"OK"},3,STR0118,,,nTimerQNC*1000,0) //"Monitor de tarefas"##"Geracao de tarefa 
							Endif
						Endif
					Else
					cMemoLog :=	""
					cTexto   := "Nao foi possivel gerar a tarefa! "	//STR0119
						If !Empty(cMemoLog)
						cTexto	+= CHR(13)+CHR(10)+"Detalhes do LOG :"+CHR(13)+CHR(10)
						cTexto	+=	cMemoLog
						Endif
						If !IsBlind()
							If !lAuto
							MostraErro()
							Endif
						Else
						FWLogMsg('WARN',, 'SIGAQNC', funName(), '', '01', cTexto , 0, 0, {})                   
						EndIf
					cPMSTarefa := ""	//Limpa o nº de tarefa para não regravar
						If ProcName(4) <> "QNCGERAPLANO"
						/*DisarmTransaction()   DÁ RETORNO .F. MAS CONTINUA A GRAVAÇÃO, FICA SEM A FNC (NA GERAÇÃO)*/
							If !lAuto
							Final()
							Endif
						EndIf
					Endif
				END TRANSACTION
			EndIf
		EndIF
	Endif

Return(cPMSTarefa)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³QNCCARHAB     ³ Autor ³Leandro            ³ Data ³ 05/05/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Carrega Habilidades para executar a Tarefa 			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNCCARHAB                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Etapa		 	                                  ³±±
±±³			 ³ ExpN2 - Filial			                                  ³±±
±±³			 ³ ExpN3 - Plano			                                  ³±±
±±³			 ³ ExpN4 - Array c/ habilidades                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQNC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNCCARHAB(cEtapa,cFil,cPlano,aHabilidades,lGravaQUR)
Local aArea := GetArea()
Local aAreaQUQ := {}
Local aAreaQUR := {}

Default aHabilidades := {}
DEFAULT lGravaQUR	 := .T.

	If lGravaQUR
	DbselectArea("QUQ")
	aAreaQUQ := GetArea()
	QUQ->(dbSetOrder(1))
	
		If QUQ->(dbSeek(xFilial("QUQ")+cEtapa))
		DbselectArea("QUR")
		aAreaQUR := GetArea()
		DbSetOrder(1)
			If !DbSeek(xFilial("QUR")+cPlano+cEtapa)
				While QUQ->(!Eof()) .And. QUQ->QUQ_FILIAL+QUQ->QUQ_TPACAO ==  xFilial("QUQ")+cEtapa
		  		DbselectArea("QUR")
				QUR->(dbSetOrder(1))	
		   		RecLock("QUR",.T.)
				QUR->QUR_FILIAL     := xFilial("QUR")	// Filial Plano de Acao
				QUR->QUR_CODIGO  	:= cPlano			   // Codigo Plano de Acao
				QUR->QUR_TPACAO 	:= QUQ->QUQ_TPACAO // Tipo da Acao
				QUR->QUR_HABIL     	:= QUQ->QUQ_HABIL  // Habilidade para executar a etapa/acao
				QUR->QUR_NOTAHB 	:= QUQ->QUQ_NOTAHB // Nota necessaria para executar a etapa
				MsUnLock()			
				FKCOMMIT()
				aAdd(aHabilidades,{QUQ->QUQ_HABIL,QUQ->QUQ_NOTAHB})
				QUQ->(dbSkip()) 	
				Enddo
			RestArea(aAreaQUR)
			EndIf
		Endif
	RestArea(aAreaQUQ)
	
		If ExistBlock("QNCALTHAB")
		aTMPHab := ExecBlock("QNCALTHAB",.F.,.F.,{cFil,cPlano,cEtapa,aHabilidades,lGravaQUR})
			If ValType(aTMPHab) == "A" .and. Len(aTMPHab) > 0
			aHabilidades := aClone(aTMPHab)
			EndIf
		EndIf
	Else
	dbSelectArea("QUR")
	aAreaQUR := GetArea()
	dbSetOrder(1)
		If MsSeek(xFilial("QUR")+cPlano+cEtapa,.F.)
			While QUR->(!Eof()) .and. QUR->QUR_FILIAL == xFilial("QUR") .AND. QUR->QUR_CODIGO == cPlano .and. QUR->QUR_TPACAO == cEtapa
			aAdd(aHabilidades,{QUR->QUR_HABIL,QUR->QUR_NOTAHB})
			QUR->(dBSKip())
			EndDo
		EndIf
	RestArea(aAreaQUR)
	EndIf

RestArea(aArea)
Return 			

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNCGvAnexo³ Autor ³ Leandro			    ³ Data ³ 03/07/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava Anexos                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNCGAnexo(ExpN1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Opcao do Browse                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQNC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNCGvAnexo(nOpc,aColsQIE)

Local lRecLock:= .F.
Local nCnt    := 0
Local nCpo    := 0
Local nPosDel := Len(aHeadAne) + 1
Local nPosSeq := Ascan(aHeadAne,{ |X| UPPER(ALLTRIM(X[2])) == If(cAliasAnex=="QIE","QIE_SEQ","QIF_SEQ")})
Local cFilAnex:= ""
Local cCodAnex:= ""
LocaL cRevAnex:= ""
Local lRet    := .F.
Local cQPathFNC:= QA_TRABAR(Alltrim(GetMv("MV_QNCPDOC")))

	If nOpc == 3
	lRecLock:= .T.
	EndIf

	If cAliasAnex == "QIE"
	cFilAnex:= QI3->QI3_FILIAL
	cCodAnex:= QI3->QI3_CODIGO
	cRevAnex:= QI3->QI3_REV
	EndIf

	Begin Transaction
	DbSelectArea(cAliasAnex)
	DbSetOrder(1)
		For nCnt:= 1 To Len(aColsQIE)
			If !aColsQIE[nCnt, nPosDel] // Verifica se o item foi deletado

				If DbSeek(cFilAnex+cCodAnex+cRevAnex+SubStr(aColsQIE[nCnt,nPosSeq],1,2))
				RecLock(cAliasAnex,.F.)
				Else
				RecLock(cAliasAnex,.T.)
				Endif

				For nCpo := 1 To Len(aHeadAne) - 2
					If aHeadAne[nCpo, 10] <> "V"
					FieldPut(FieldPos(Trim(aHeadAne[nCpo,2])),aColsQIE[nCnt,nCpo])
					EndIf
				Next nCpo

				If cAliasAnex == "QIE"
				QIE->QIE_FILIAL:= QI3->QI3_FILIAL
				QIE->QIE_CODIGO:= QI3->QI3_CODIGO
				QIE->QIE_REV   := QI3->QI3_REV
				QIE->QIE_SEQ   := StrZero(nCnt,2)
				EndIf

			MsUnlock()
			lRet    := .T.
			Else
				If DbSeek(cFilAnex+cCodAnex+cRevAnex+SubStr(aColsQIE[nCnt,nPosSeq],1,2))
				cFileTrm:= aColsQIE[nCnt,nPosSeq]
					If File(cQPathFNC+cFileTrm)
					FErase(cQPathFNC+cFileTrm)	
					Endif

				RecLock(cAliasAnex,.F.)
				DbDelete()
				MsUnlock()
				lRet    := .T.
				Endif
			Endif
		Next nCnt
	End Transaction

Return lRet  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QNCXFUN   ºAutor  ³Leonardo Quintania	 º Data ³  24/05/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna array de datas e horas para a geracao de tarefa PMS º±±
±±º          ³realizando super alocação                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QNCXFUN                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QNCPMSDtDf(dQI5PRAZO,nDurac,cPROJET,cRecPMS, aTrfDatas)

	cCalend   := Posicione("AE8",1,xFilial("AE8")+AllTrim(cRecPMS),"AE8_CALEND")
	aTrfDatas := PMSDTaskI(dQI5PRAZO,"23:59",cCalend,nDurac,cPROJET,cRecPMS)

	If aTrfDatas <> NIL // Regra para quando for superalocar por data retroativa, a data inicial nao seja inferior a data atual (pode ultrapassar o SLA)
		If aTrfDatas[1] < dDataBase
			aTrfDatas := PMSDTaskF(dDataBase,"00:00",cCalend,nDurac,cPROJET,cRecPMS)
		Endif
	Endif

Return(aTrfDatas)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QNCXFUN   ºAutor  ³Marcos S. Lobo      º Data ³  07/06/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Conversao de Prazos em Horas QNC x PMS (Decimal x Char)     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QNCPrzHR2(xHRORI,cTPOri,cUnOri,cTpRet,cUnidRet)

	Local xReturnHR
	Local nHour2Conv := 0
	Local cHour2Conv := ""

	DEFAULT cTpOri		:= "H" ///D=Decimal Numerico, "H"=Hora Caracter
	DEFAULT cUnOri		:= "H" ///H=Em horas, "M"=Em minutos
	DEFAULT cTpRet		:= "D" ///D=Decimal Numerico, "H"=Hora Caracter
	DEFAULT cUnidRet	:= "H" ///H=Em horas, "M"=Em minutos

	If cTPOri == "D"
		If cUNOri == "M"
			///CONVERTE MINUTOS DECIMAL PARA HORAS DECIMAL
			nHour2Conv := xHROri / 60
		Else
			nHour2Conv := xHROri
		EndiF
	ElseIf cTPOri == "H"
		If cUNOri == "M"	///"HORAS" é a BASE PARA CONVERSÃO
			cHour2Conv := Min2Hrs(xHRORI)
		Else
			cHour2Conv := xHRORI
		EndIf
	EndIf

	If Empty(cHour2Conv) .and. !Empty(nHour2Conv)
		///"HORAS" é a BASE PARA CONVERSÃO
		cHour2Conv := Alltrim(StrTran(Padl(Alltrim(TransForm(nHour2Conv,"@R 9999.99")),7,"0")   ,".",":"))
	EndIf

	If cTPRet == "D"
		//CONVERTE HORAS CARACTER PARA HORAS DECIMAL
		xReturnHR := Val(Left(cHour2Conv,4)) +  ( Val( Right(cHour2Conv,2) ) / 60 )
		If cUnidRet == "M"
			///CONVERTE HORAS DECIMAL PARA MINUTOS DECIMAL.
			xReturnHR := ( xReturnHR * 60)
		EndIF

	ElseIf cTPRet == "H"
		IF cUnidRet == "M"	// Retorno Em Minutos
			xReturnHR := Hrs2Min(cHour2Conv)
		Else
			xReturnHR := cHour2Conv
		EndIf
	EndIf

Return(xReturnHR)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QNCXFUN   ºAutor  ³Microsiga           º Data ³  07/06/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QNCRespDef(cRecurso,cQUPGRUPO,cEtapa,cDEPTOQNC,cPlano,cRevPlan,lShowHlp)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento de excecao para sempre selecionar um recurso que sera o responsavel pela execucao da etapa/tarefa, seguindo a sequencia de prioridade:³
//³- Melhor recurso disponivel alocado pelo PMS                                                                                                     ³
//³- Usuario pre-determinado na QUP                                                                                                                 ³
//³- Responsavel do Plano                                                                                                                           ³
//³- Responsavel do Depto/Area do Grupo de etapa                                                                                                    ³
//³- Primeiro recurso encontrado(estrategico) encontrado na QE8                                                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aAreaOri	:= {}
	LOCAL cRecPMS	:= ""
	Local nWhile	:= 0
	Local cMATRes	:= ""
	Local nOpAv		:= 1
	Local aRecurs	:= {}
	Local cMatAtu 	:= ""
	Local cRecAtu 	:= ""

	If __nTQAAMAT == 0
		dbSelectArea("QAA")
		__nTQAAMAT := Len(QAA->QAA_MAT)
	EndIf
	If __nTRECPMS == 0
		dbSelectArea("AE8")
		__nTRECPMS := Len(AE8->AE8_RECURS)
	EndIf

	While Empty(cRecPMS)
		nWhile++
		If nWhile == 1 .and. !Empty(cRecurso)
			cRecPMS := cRecurso //Recurso alocado pelo PMS
		ElseIf nWhile == 2 .and. !Empty(cPlano) .and. !Empty(cEtapa)
			dbSelectArea("QI5")
			aAreaOri := GetArea()
			dbSetOrder(4)
			If MsSeek(xFilial("QI5")+cPlano+cRevPlan+cEtapa,.F.)
				cMATRes := QI5->QI5_MAT
			EndIF
			RestArea(aAreaOri)
		ElseIf nWhile == 3 .and. !Empty(cQUPGRUPO)//Recurso estabelecido no Grupo de Etapas
			dbSelectArea("QUP")
			aAreaOri := GetArea()
			dbSetOrder(1)
			If MsSeek(xFilial("QUP")+cQUPGRUPO,.F.)
				cMATRes := QUP->QUP_RESP
			EndIf
			RestArea(aAreaOri)
		ElseIf nWhile == 4 .and. !Empty(cPlano)
			dbSelectArea("QI3")
			aAreaOri := QI3->(GetArea())
			dbSetOrder(2)
			If MsSeek(xFilial("QI3")+cPlano+cRevPlan,.F.) .or. MsSeek(xFilial("QI3")+cPlano,.F.)
				If !Empty(QI3->QI3_MAT)//Recurso responsavel pelo Plano
					cMATRes := QI3->QI3_MAT
				EndIf
			EndIf
			RestArea(aAreaOri)
		ElseIf nWhile == 5 .and. !Empty(cDEPTOQNC)
			dbSelectArea("QAD")
			aAreaOri := GetArea()
			dbSetOrder(1)
			If MsSeek(xFilial("QAD")+cDEPTOQNC)
				If !Empty(QAD->QAD_MAT)
					cMatRes := QAD->QAD_MAT //Recurso responsavel da area
				Endif
			Endif
			RestArea(aAreaOri)
		ElseIf nWhile == 6
			dbSelectArea("AE8")
			aAreaOri := GetArea()
			dbSetOrder(1)
			MsSeek(xFilial("AE8"),.T.)
			lAchei := .F.
			While AE8->(!Eof()) .AND. !lAchei
				If AE8->AE8_TIPO == "2" .AND. AE8->AE8_ATIVO == "1"	///RECURSO TRABALHO QUE ESTEJA ATIVO.
					cRecurso := AE8->AE8_RECURS //1º Recurso PMS do AE8
					lAchei := .T.
				EndIf
				AE8->(dbSkip())
			EndDo
			RestArea(aAreaOri)
		Endif

		////	 RDZRetEnt( cEntOri, cCodOri, cEntRet, cEmpENT, cFilENT, lPosicione, lRetcomFil, lParcomFil )
		If Empty(cRecurso) .and. !Empty(cMatRes)
			cRecurso  := RDZRETENT("QAA",xFilial("QAA")+cMATRes,"AE8",,,,.F.,.T.) //Codigo do Resp.QNC como Recurso AE8.
		EndIf

		If !Empty(cRecurso)
			cRecPMS := cRecurso
			/////RDZRetEnt( cEntOri, cCodOri, cEntRet, cEmpENT, cFilENT, lPosicione, lRetcomFil, lParcomFil )
			cMATRes	:= RDZRETENT("AE8",xFilial("AE8")+cRecurso,"QAA",,,,.F.,.T.) //Recurso Alocado via PMS, retorna cod.Resp.QNC.
		EndIf

		If nWhile == 2 .or. nWhile == 6
			If (Empty(cMatRes) .or. Empty(cRecurso)) .And. (nOpAv <> 2)//Qdo nao encontrar o cRecurso referente a QAA cadastrado na RDZ
				If !IsBlind()
					dbSelectArea("AE8")
					dbSetOrder(1)
					cAE8Nome := STR0123 //"(não encontrado)"
					cRecurso := PADR(cRecurso,__nTRECPMS)
					If MsSeek(xFilial("AE8")+cRecurso,.F.)
						cAE8Nome := ALLTRIM(AE8->AE8_DESCRI)
					EndIf
					cQAANome := STR0123 //"(não encontrado)"
					dbSelectArea("QAA")
					dbSetOrder(1)
					cMatRes := PADR(cMatRes,__nTQAAMAT)
					If MsSeek(xFilial("QAA")+cMatRes,.F.)
						cQAANome := ALLTRIM(QAA->QAA_NOME)
					EndIf
					nOpAv := Aviso(STR0124,STR0137+ALLTRIM(cRecurso)+" "+cAe8Nome+STR0125+ALLTRIM(cMatRes)+" "+cQAANome+". "+CRLF+CRLF+;//"Atencao ! Problemas no relacionamento de cadastros","Recurso "	##	" vs. Responsavel "
					STR0126+CRLF+; //"Selecione uma das opções:"
					STR0127+CRLF+;//"- Repetir (é necessário corrigir o relacionamento do recurso com responsável nos cadastros de usuario do QNC e depois clicar no botão Repetir)."
					STR0128+CRLF+;//"- Usar o responsável padrão (será considerado o responsável padrão cadastrado no modelo de etapas)."
					STR0129,{STR0130,STR0131,STR0132},3,STR0133)//"- Abortar (será cancelada a operação, a pendência será mantida na etapa atual). "##"Repetir"##"Padrão"##"Abortar"##"Relação recurso x responsável QNC !"
					If nOpAv == 1
						nWhile:= 1
					Else
						If nOpAv == 3
							If MsgYesNO(STR0134+CRLF+STR0135)//"Essa operação será cancelada !"##" Confirma ?"
								//Final("Problema no relacionamento do recurso x responsável no cadastro de usuario do QNC")
								nWhile  := 0
								cMATRes := "STOP"
								Exit
							Else
								nWhile  := 2
								cRecPMS := ""
							Endif
						Else
							nWhile	:= 1
							cMATRes := ""
						EndIf
					Endif
				EndIf
			Else
				IF Empty(cMatRes) .or. Empty(cRecurso)
					cMATRes := "" //Esta assumindo o recurso padrao da QUP
					Aviso(STR0007,"O recurso padrao do grupo de etapas não está relacionado a um recurso do PMS,corrija o relacionamento via rotina de cadastro de usuario do QNC",{"OK"},1,STR0137)
					nWhile:= 1
					nOpAv := 1
				Endif
			EndIf
		EndIf
	EndDo

	If nWhile <> 0
		cMatRes := PADR(cMatRes,__nTQAAMAT)
		cRecPMS := PADR(cRecPMS,__nTRECPMS)
	Endif

	If nWhile == 2 .And. Empty(cMATRes)
		cMATRes := "STOP"
	Endif

	If AllTrim(cMATRes) <> "STOP" .And. !Empty(cRecurso)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Guardo os códigos atuais do cMatRes e cRecurso para voltar caso haja erro			³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cMatAtu := cMATRes
		cRecAtu := cRecurso

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Função que Verifica se o Recurso está Off-Line. Retorna o Recurso e lRet			³
		//³ aRet[1] := Código do Recurso Substituto ou Atual / [2] := lRet .T./.F.				³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aRecurs := QNCRecOff(cRecurso,lShowHlp)

		If Len(aRecurs) > 0

			cRecurso := aRecurs[1]
			cMATRes	 := RDZRETENT("AE8",xFilial("AE8")+cRecurso,"QAA",,,,.F.,.T.) //Recurso Alocado via PMS, retorna cod.Resp.QNC.

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Caso cMATRes fique branco volto aos códigos originais								³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty(cMATRes)
				cMatRes  := cMatAtu
				cRecurso := cRecAtu
			EndIf

		EndIf

	EndIf

Return(cMATRes)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QNCXFUN   ºAutor  ³Microsiga           º Data ³  07/09/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QNCRetQAA(cUsrNam,lPosicQAA,cFilQAA)

	Local cMatQAA := ""
	Local aAreaQAA := GetArea()

	DEFAULT lPosicQAA := .T.

	dbSelectArea("QAA")
	DEFAULT cFilQAA := xFilial("QAA")
	dbSetORder(6)
	If MsSeek(cUsrNam,.F.) //cFilQAA+
		cMatQAA := QAA->QAA_MAT
	EndIf

	If QAA->(Eof())
		QAA->(dbGoTop())
		cUsrNam := Upper(cUsrNam)
		If MsSeek(cUsrNam,.F.) //cFilQAA+
			cMatQAA := QAA->QAA_MAT
		EndIf
	Endif

	If !lPosicQAA
		RestArea(aAreaQAA)
	EndIf

Return(cMatQAA)


/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡…o    ³ A200DSOL ³ Autor ³ Quality				³ Data ³22/10/2003³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³ Mostra o nome do Solicitante                               ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso      ³ QIEA200 - Cham. X3_RELACAO,X3_INIBRW e gatilho (QEK_SOLIC) ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QNCETAPA()
	Local cRetorno  := ""

	cRetorno := QUT->QUT_ETAPA

	If Empty(cRetorno)
		cRetorno :=	 QI5->QI5_TPACAO
	Endif

Return(cRetorno)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Q_CHKEDT  ³ Autor ³ Microsiga 			³ Data ³ 30.07.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida EDT. 									 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QA_CHKMAT(ExpC1,ExpC2,ExpL1)								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Projeto								  ³±±
±±³			 ³ ExpC2 = Codigo da EDT		 							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ no campo QUP_CJCOD 										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Q_CHKEDT(cCodProj,cCodEDT)
Local lRet   := .F.
Local cRev   := PmsAF8Ver(cCodProj)

cCodProj:= PadR(cCodProj,Len(AF8->AF8_PROJET))

AFC->(DbSetOrder(1))
	If AFC->(DbSeek(xFilial()+cCodProj+cRev+cCodEDT))
	lRet:= .T.
	Endif

Return (lRet)
 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QNCXFUN   ºAutor  ³Marcos S. Lobo      º Data ³  08/04/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Trata chamada da integração QNC x PMS para processamento    º±±
±±º          ³no remote ou via JOB (fora da transação atual).             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QNQI5xPMS(aRQI52TRF,cFNC,cFNCRev,lRet)

	Local aAreaOri := GetArea()
	Local aAreaQI5 := {}
	Local _nQI5 := 1
// Projeto TDI - TDZBCB - Melhoria tela de alocacao semi-automatica
	Default lRet  := .T.  // controle de transacao

	dbSelectArea("QI5")
	aAreaQI5 := GetArea()
	For _nQI5 := 1 to Len(aRQI52TRF)
		QI5->(MsGoTo(aRQI52TRF[_nQI5]))
		If QI5->QI5_TRFACT $ "13" .and. GetNewPar("MV_QPMSINJ",.F.) .And. !IsBlind() 	//Se configurado para processar alocação PMS/Tarefa em outra Thread.
			//Só pode nas opções onde não exige tela.
			StartJob("QNQI5IPMS",GetEnvServer(),.F.,cEmpAnt,cFilAnt, { aRQI52TRF[_nQI5] },cFNC,cFNCRev )
		Else
			// Projeto TDI - TDZBCB - Melhoria tela de alocacao semi-automatica
			QNQI5IPMS( { aRQI52TRF[_nQI5] },cFNC,cFNCRev,@lRet)
		EndIf
	Next
	RestArea(aAreaQI5)
	RestArea(aAreaOri)

Return( lRet ) // controle de transacao


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QNCXFUN   ºAutor  ³Microsiga           º Data ³  08/04/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QNQI5IPMS(aRQI52TRF,cFNC,cFNCRev,lRet)
	Local aAreaORI 		:= GetArea()
	Local aAreaQI5 		:= {}
	Local aAreaQI3		:= {}
	Local aAreaQUO		:= {}
	Local aAreaQAA		:= {}
	Local aAreaQUP		:= {}
	Local aQI5POS  		:= {}
	Local aHabilidades	:= {}
	Local cMVQTMKPMS	:= GetMv("MV_QTMKPMS")
	Local _nQI5 := 1
	Local cThreadID  := THREADID()  			//Armazena o identificador da thread

	Local dQI52Prazo	:= CTOD("  /  /  ")
	Local cRecPMS		:= ""
	Local aTrfDatas		:= {}
	Local aRequisitaResp:= {}
	Local cHoraQI5      := ""
	Local aRecPMS		:= {}
	Local aValRec       := {}
	Local nX			:= 0
	Local nY 			:= 0
	Local nHorasPSeq    := 0
	Local cGrpEtap 		:= ""
	Local aEtapas 		:= {}
	Local nZ 			:= 1
	Local aCRIAR		:= {}
	Local cEtpAnt     := ""
	Local aHrsSeq       := {}
	Local toMainWnd := Type("oMainWnd")
	Local lQRECDISP := ExistBlock("QRECDISP")

	DEFAULT aRQI52TRF := {}

	If (cMVQTMKPMS == 3) .Or. (cMVQTMKPMS == 4)
		aAreaQI5 := QI5->(GetArea())
		aAreaQUP := QUP->(GetArea())
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifico se o campo QUP_ETAPRL/QUP_ETAPAP/QI5_ETPRLA existem no dicionario de dados	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(aRQI52TRF) > 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³For para verificar se existem etapas paralelas para essa etapa ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nX:= 1 To Len(aRQI52TRF)
				QI5->(dbGoTo(aRQI52TRF[nX]))    //Posiciono Conforme Recno
				cGrpEtap := Posicione("QI3",2,xFilial("QI3")+QI5->QI5_CODIGO+QI5->QI5_REV,"QI3_MODELO")

				aRQI52TRF[nX] := {QI5->(Recno()),QI5->QI5_SEQ,QI5->QI5_PARSEQ}

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³For para verificar se existem etapas paralelas para essa etapa e se são Obrigatorias ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(cGrpEtap) .And. QI5->QI5_OBRIGA == "1"
					QUP->(DbSetOrder(1))	//QUP_FILIAL+QUP_GRUPO+QUP_TPACAO
					If QUP->(DbSeek(xFilial("QUP")+PadR(cGrpEtap,TamSx3("QUO_GRUPO")[1])+QI5->QI5_TPACAO)) .And. QUP->QUP_ETAPRL == "1" //Etapa Paralela
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Funcao que Retorna as Etapas Paralelas informadas no campo QUP_ETAPAP     ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aEtapas := StrTokarr(AllTrim(QUP->QUP_ETAPAP),";")
						For nY := 1 To Len(aEtapas)
							QI5->(DbSetOrder(4))	//QI5_FILIAL+QI5_CODIGO+QI5_REV+QI5_TPACAO
							If QI5->(DbSeek(xFilial("QI5")+QI5->QI5_CODIGO+QI5->QI5_REV+AllTrim(aEtapas[nY]))) .And. QI5->QI5_OBRIGA == '1'

								If QI5->QI5_PARSEQ == "1"
									nHorasPSeq += QNCPrzHR2(QI5->QI5_PRZHR,"H","H","D","H")

								EndIf
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Adiciono no array aRQI52TRF os Recno da QI5 das etapas encontradas no campo QUP_ETAPAP ³
								//³ para depois serem geradas as tarefas na funcao QNCGeraTarefa                           ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								Aadd(aRQI52TRF,{QI5->(Recno()),QI5->QI5_SEQ,QI5->QI5_PARSEQ})
							EndIf

						Next nY
					EndIf
				EndIf
			Next nX
		EndIf
		aRQI52TRF := aSort(aRQI52TRF,,,{|x,y| AllTrim(x[2]) < AllTrim(y[2]) })
		RestArea(aAreaQUP)
		RestArea(aAreaQI5)

		If Len(aRQI52TRF) > 0
			dbSelectArea("QI5")
			For _nQI5 := 1 to Len(aRQI52TRF)
				If _nQI5 > 1
					nHorasPSeq := 0
					cEtpAnt:= ""
					While Empty(cEtpAnt)
						If _nQI5-nZ == 1 .Or. aRQI52TRF[_nQI5-nZ,3] == "1"
							cEtpAnt := aRQI52TRF[_nQI5-nZ,1]
							Exit
						Else
							nZ++
						EndIf
					End
				EndIf

				If !Empty(cEtpAnt)
					aHrsSeq:={}
					QI5->(MsGoTo(cEtpAnt))
					AFA->(dbSetOrder(5))
					If AFA->(MsSeek(xFilial("AFA")+QI5->QI5_PROJET+QI5->QI5_REVISA+QI5->QI5_TAREFA))
						aAdd(aHrsSeq,AFA->AFA_FINISH)
						aAdd(aHrsSeq,AFA->AFA_HORAF)
						aAdd(aHrsSeq,AFA->AFA_RECURS)
					EndIf
				EndIf

				QI5->(MsGoTo(aRQI52TRF[_nQI5,1]))
				aQI5POS := QI5->(GetArea())

				aHabilidades	:= {}
				cPMSTarefa		:= ""
				dQI52Prazo		:= CTOD("  /  /  ")
				aTrfDatas		:= {}
				aRequisitaResp	:= {}

				dbSelectArea("QI3")
				aAreaQI3		:= GetArea()
				dbSetOrder(2)
				If !MsSeek(xFilial("QI3")+QI5->QI5_CODIGO+QI5->QI5_REV,.F.)
					MsSeek(xFilial("QI3")+QI5->QI5_CODIGO,.T.)
				EndIf

				cQI3PLANO	:= QI5->QI5_CODIGO
				cQI3REV		:= QI5->QI5_REV
				cQI3Grupo	:= QI3->QI3_MODELO
				cQI3DEPTO	:= ""

				If !Empty(cQI3Grupo)
					dbSelectArea("QUO")
					aAreaQUO		:= GetArea()
					dbSetOrder(1)
					If MsSeek(xFilial("QUO")+cQI3Grupo,.F.)
						cQI3DEPTO	:= QUO->QUO_DEPTO        /*DEVIA SER O DEPTO DO PLANO,OU, DA FNC*/
					EndIf
				EndIf
				If Empty(cQI3DEPTO)
					dbSelectArea("QAA")
					aAreaQAA		:= GetArea()
					dbSetOrder(1)
					If MsSeek(xFilial("QAA")+QI3->QI3_MAT,.F.)
						cQI3DEPTO	:= QAA->QAA_CC
					EndIf
				EndIf

				cQI5TPACAO 	:= QI5->QI5_TPACAO
				cQI5TRFACT	:= QI5->QI5_TRFACT
				dQI5PRAZO	:= If( DTOS(QI5->QI5_PRAZO) < DTOS(dDataBase), dDataBase, QI5->QI5_PRAZO )
				cPROJET		:= QI5->QI5_PROJET
				cREVISA     := QI5->QI5_REVISA

				nQI5InHrs	:= QNCPrzHR2(QI5->QI5_PRZHR	,"H","H","D","H")
				If nQI5InHrs <= 0
					nQi5InHrs := 1
				EndIf

				If cQI5TRFACT$("23") /// Alocação Tarefa PMS: 0=Não Gera; 1=Força alocação QNC; 2=Semi-Auto ou 3=Automatica, 4=Manual.

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Ponto de Entrada criado para validacao de permissao de usuario executar etapa - PRICE³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lQRECDISP
						aValRec := ExecBlock("QRECDISP",.F.,.F., {cQI3PLANO,cQI3REV,cQI5TPACAO})
					EndIf

					QNCCARHAB(cQI5TPACAO,,cQI3PLANO,@aHabilidades,.F.)

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³aHabilidades = Array com as habilidades para executar a tarefa.                    ³
					//³dDTEncer     = Dt de Encerramento                                                  ³
					//³cHRParcial   = HR ref a Porcentagem p/ executar a etapa, cadastrada no arquivo QUP ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					///PMSRecDisp(aGrpHab ,dLimite ,nDurac ,cCodProjeto,aRecursos)
					If LEN(aHabilidades) > 0    //só busca os recursos do PMS se tivr habildades. Se não houver, traz o recurso do plano.
						aRequisitaResp := PMSRECDISP(aHabilidades , dQI5PRAZO, nQI5InHrs + nHorasPSeq , cPROJET, @aRecPMS)
						If !Empty(aRequisitaResp)
							aCRIAR := PMSDTaskF(aRequisitaResp[2],aRequisitaResp[3],Posicione("AE8",1,xFilial("AE8")+AllTrim(cRecPMS),"AE8_CALEND"),nQI5InHrs,cPROJET,aRequisitaResp[1])
							aRequisitaResp[4] := aCRIAR[3]
							aRequisitaResp[5] := aCRIAR[4]
						EndIf
					EndIf
				EndIf

				RestArea(aQI5POS)

				cRecPMS			:= "" /// Recurso que poderá ser retornado pelo PMS.
				If !Empty(aRequisitaResp)
					cRecPMS			:= aRequisitaResp[1] //Recurso PMS retornado pela PMSRECDisp().
					dQI52Prazo 		:= aRequisitaResp[4] //Prazo da Etapa, estabelecido via PMS se achou alocação em data "menor" que o prazo original.
					If Empty(aTrfDatas)
						aTrfDatas := {aRequisitaResp[2],aRequisitaResp[3],aRequisitaResp[4],aRequisitaResp[5]}
					EndIf
				EndIf

				If cQI5TRFACT == "2" .and. toMainWnd == "O"	//Alocação Semi-Automatica ou Manual. (se tiver janela aberta)
					cHoraQI5 := QI5->QI5_PRZHR
					///QAlocPMS(cPlano,cRev,			 cEtapa,		 aAlocs,			cHora,  aHabsReq,	aOtherRec)

					//-- Grava os recursos adicionais
					// le os recursos adicionais do plano para serem alterados pela funcao abaixo
					aRecAdic := StrTokarr(AllTrim(QUP->QUP_RESP2),";")

					QAlocPMS(QI5->QI5_CODIGO,QI5->QI5_REV,QI5->QI5_TPACAO,@aRequisitaResp,@cHoraQI5,aHabilidades,@aRecPMS,nHorasPSeq,@lRet)
					If Len(aRequisitaResp) > 0
						aTrfDatas := {aRequisitaResp[2],aRequisitaResp[3],aRequisitaResp[4],aRequisitaResp[5]}
					EndIf
					IF !Empty(aRequisitaResp[1])
						cQI52MAT := QNCRespDef(aRequisitaResp[1],cQI3Grupo,cQI5TPACAO,cQI3DEPTO,cQI3PLANO,cQI3REV,.F.)///Obtem o código do responsável QNC correspondente ao Recurso PMS.
						IF !Empty(cQI52MAT) .And. (cQI52MAT <> "STOP")
							RecLock("QI5",.F.)
							QI5->QI5_MAT   := cQI52MAT
							If !Empty(cHoraQI5)
								QI5->QI5_PRZHR := cHoraQI5
							Endif
							//-- Grava os recursos adicionais
							// gravacao dos recursos adicionais gerados pela funcao QAlocPMS
							if Len(aRecAdic) > 0
								cRecAdic := ""
								Aeval(aRecAdic, {|e| cRecAdic += e+";" } )
								QI5->QI5_MAT2 := cRecAdic
							Endif

							QI5->(MsUnlock())
						Endif
					Endif
				Else
					cRecPMS:= If(!Empty(aHrsSeq),aHrsSeq[3],cRecPMS)
					cQI52MAT := QNCRespDef(@cRecPMS,cQI3Grupo,cQI5TPACAO,cQI3DEPTO,cQI3PLANO,cQI3REV,.F.)///Obtem o código do responsável QNC correspondente ao Recurso PMS.
					IF !Empty(cQI52MAT) .And. (cQI52MAT <> "STOP")
						aTrfDatas:= PMSRecDisp(aHabilidades ,dQI5PRAZO ,nQI5InHrs + nHorasPSeq,cPROJET,@aRecPMS,Alltrim(cRecPMS))  //Aloca recurso na primeira data disponivel.
						If !Empty(aTrfDatas)
							aCRIAR := PMSDTaskF(aTrfDatas[2],aTrfDatas[3],Posicione("AE8",1,xFilial("AE8")+AllTrim(cRecPMS),"AE8_CALEND"),nQI5InHrs,cPROJET,aTrfDatas[1])
							aTrfDatas[4] := aCRIAR[3]
							aTrfDatas[5] := aCRIAR[4]
							aDel(aTrfDatas,1)
							aSize(aTrfDatas,Len(aTrfDatas)-1)
							RecLock("QI5",.F.)
							QI5->QI5_MAT := cQI52MAT
							QI5->(MsUnlock())
						Else
							aTrfDatas := QNCPMSDtDf( dQI5PRAZO,nQI5InHrs,cPROJET,cRecPMS, aTrfDatas ) /// Assume Data Prazo da FNC Realizando superalocação de usuario.
							RecLock("QI5",.F.)
							QI5->QI5_MAT := cQI52MAT
							QI5->(MsUnlock())
						Endif
					Endif

				EndIf

				If !Empty(aHrsSeq)
					aTrfDatas := PMSDTaskF(aHrsSeq[1],aHrsSeq[2],Posicione("AE8",1,xFilial("AE8")+AllTrim(cRecPMS),"AE8_CALEND"),nQI5InHrs,cPROJET,cRecPMS)
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Conforme acordado sera criado automaticamente somente a primeira Tarefa no PMS para a primeira Etapa gerada  ³
				//³no QNC ou quando se tratar de etapas filhas as quais todas deverao ser criadas.								³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//So ira gerar tarefa atraves desse trecho qdo se tratar de um plano filho ou revisão de um plano rejeitado
				cPMSTarefa := QNCGeraTarefa(cFNC,QI5->QI5_FILIAL,QI5->QI5_CODIGO,QI5->QI5_REV,QI5->QI5_TPACAO,aTrfDatas,cFNCRev,.T.)

				If cPMSTarefa == "STOP"
					Return()
				Endif

				//	Projeto TDI	TEGJD7 -	Atualizacao	do	recurso atual no chamado
				QNCGRVOPE()  // continda no QNCXFUN

				If Empty(QI5->QI5_TAREFA) .and. !Empty(cPMSTarefa)
					RecLock("QI5",.F.)
					QI5->QI5_TAREFA	:= cPMSTarefa
					QI5->QI5_PEND	:= "S"
					QI5->(MsUnlock())
				EndIf
			Next
		EndIf
		RestArea(aAreaQI5)

		If Len(aAreaQI3) > 0
			RestArea(aAreaQI3)
		EndIf
		If Len(aAreaQUO) > 0
			RestArea(aAreaQUO)
		EndIf
		If Len(aAreaQAA) > 0
			RestArea(aAreaQAA)
		EndIf
	EndIf

	RestArea(aAreaORI)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QNCXFUN   ºAutor  ³Microsiga           º Data ³  08/04/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QN5CalPrz(dDTIni,nHrAcum,dEncPla,cDurETP,cDurPLAN)

	Local dPrazoETP		//Data/Prazo de Retorno
	Local nQPrzRecuo	:= GetNewPar("MV_QPRZRCP",10) /100 	///Percentual de Recuo no Prazo Final
	Local nQPrzREtapa	:= GetNewPar("MV_QPRZRCE",10) /100 	///Percentual de Recuo no Prazo da Etapa
	Local nHorasDia		:= GetNewpar("MV_QHRSDIA",8)		///

	Local nTOTDias		:= 0
	Local nRecDias		:= 0
	Local dPrazoFIM
	Local nDurPLAN		:= 0
	Local nDurETP		:= 0
	Local nTotPln		:= 0
	Local nAux			:= 0

	DEFAULT dEncPla		:= dDataBase + 30	///Default do QNC é 30 dias.
	DEFAULT nHrAcum		:= 0

	nDurPLAN 	:= QNCPrzHR2(cDurPLAN	,"H","H","D","H")	///Converte Duração Total do Plano para Horas em Decimal.
	nDurETP		:= QNCPrzHR2(cDurETP	,"H","H","D","H")	///Converte Duração da Etapa Plano para Horas em Decimal.
	nTotPln 	:= (dEncPla-ddatabase) * nHorasDia  // verifico as horas disponiveis de acordo com o prazo para finalizacao

	If nDurPLAN > nTotPln       //quando a duracao disponibilizada no plano é maior que o disponível no plano
		nAux	 := nDurPLAN
		nDurPLAN := nTotPln       //duracao do plano é recalculado, de acordo com o prazo do plano
		nDurETP  := (nDurETP*nDurPLAN)/ nAux             //etapa tem duracao recalculada, proporcional à duração do plano
	EndIf

	nTOTDias	:= If(Empty(dDTIni), nDurPlan/nHorasDia, dEncPla - dDTIni ) //Total de dias até o Prazo Final.
	nRECDias	:= nTOTDias * nQPrzRecuo	///Recuo do Prazo em Dias (numerico)

	dPrazoFIM	:= dEncPla - nRECDias


///Data de início do Plano (p/ calcular o Prazo p/ Etapa)
	If Empty(dDTIni)
		//Na primeira Etapa, considera a duração do Plano a Partir do Prazo Final.
		dINIPlan := DataValida( dPrazoFIM - (nDurPlan / nHorasDia) )	//A partir do "prazo do plano" já "recuado".
	Else
		//Da segunda etapa em diante, considera o prazo da etapa anterior com início.
		dINIPlan := dDTIni
	EndIf

	If dINIPlan < dDataBase
		dINIPlan := dDataBase
	EndIf

	nRECDiaEtp := ( nDurEtp / nHorasDia ) * nQPrzREtapa	///Recuo no prazo da Etapa (Em Dias)

	nETPinDias := Round( nDurEtp/nHorasDia, 0)			//Duração da Etapa (em Dias)

	dPrazoETP	 := ( dIniPlan + nETPinDias ) - nRECDiaEtp		///Prazo para a Etapa (com o Recuo em Dias).

	If DTOS(dPrazoETP) < DTOS(dINIPlan)
		dPrazoETP := dINIPlan	//Se o Prazo da Etapa recuou mais do que a data de início, considera a data de início.
	EndIf
	If DTOS(dPrazoETP) > DTOS(dEncPla)
		dPrazoETP := dEncPla	//Se o Prazo da Etapa ficou maior que a data fim do plano, considera a Data Limite.
	EndIf

	If DTOS(dPrazoETP) == DTOS(dINIPlan) .and. nHRAcum >= nHorasDia
		dPrazoETP := dPrazoETP + Round( ( nHRAcum / nHorasDia ) , 0 )
		nHRAcum := 0
		If dPrazoETP > dEncPla
			dPrazoETP := dEncPla
		EndIf
	Else
		nHrAcum += nDurETP
	EndIf

Return dPrazoETP

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QAlocPMS  ºAutor  ³Microsiga           º Data ³  08/04/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Esta funcao foi mantida por causa do legado                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QAlocPMS(cPlano,cRev,cEtapa,aAlocs,cHora,aHabsReq,aOtherRec,nHorasPSeq, lRet, aRecAdic)

// nova tela de alocacao semi-automatica
	QAlocPMS2(cPlano,cRev,cEtapa,@aAlocs,@cHora,aHabsReq,@aOtherRec,nHorasPSeq,@lRet, @aRecAdic)


Return(aAlocs)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QN5AltPrz ºAutor  ³Microsiga           º Data ³  13/08/08   º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa generico para alteracao do prazo das etapas       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QN5AltPrz(ExpC1,ExpC2,ExpC3,ExpC4)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da FNC			                          ³±±
±±³          ³ ExpC2 = Codigo da Revisao		                          ³±±
±±³          ³ ExpC3 = Codigo da Pendencia		                          ³±±
±±³          ³ ExpC4 = Data	a ser alterada		                          ³±±
±±³          ³ ExpC5 = Hora a ser alterada		                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QN5AltPrz(cFNC,cRev,cPend,cData,cHora,cHRTotal)
	Local dQI5Prazo	:= CTOD("  /  /  ")
	Local dDTQI5	:= CTOD("  /  /  ")
	Local cSeq      := 0
	Local aArea     := ()
	Local nHrAcum   := 0

	Default cData := ""
	Default cHora := ""
	Default cHRTotal := ""

	aArea := GetArea()
	DbselectArea("QI9")
	QI9->(dbSetOrder(2))
	If QI9->(MsSeek(xFilial("QI9")+cFNC+cRev))
		DbselectArea("QI3")
		QI3->(dbSetOrder(2))
		IF QI3->(MsSeek(xFilial("QI3")+QI9->QI9_CODIGO+QI9->QI9_REV))
			DbselectArea("QUO")
			QUO->(dbSetOrder(1))
			IF QUO->(MsSeek(xFilial("QUO")+QI3->QI3_MODELO))
				DbselectArea("QI5")
				QI5->(dbSetOrder(4))
				If QI5->(MsSeek(xFilial("QI5")+QI9->QI9_CODIGO+QI9->QI9_REV+cPend))
					cSeq:= QI5->QI5_SEQ
					RecLock("QI5",.F.)
					If !Empty(cData)
						QI5->QI5_PRAZO  := cData
					Endif
					If !Empty(chora)
						QI5->QI5_PRZHR  := chora
					Endif
					If !Empty(cHRTotal)
						QI5->QI5_REALHR := cHRTotal
					Endif
					QI5->(MsUnLock())

					While !Eof() .And. QI5->QI5_CODIGO+QI5->QI5_REVISA == QI9->QI9_CODIGO+QI9->QI9_REV
						IF (QI5->QI5_SEQ > cSeq)
							dQI5Prazo := QN5CalPrz(dDTIQI5,@nHrAcum,QI3->QI3_ENCPRE,QI5->QI5_PRZHR,QUO->QUO_PRZHR)
							RecLock("QI5",.F.)
							If Empty(dQI5Prazo) .and. Empty(QI5->QI5_PRAZO)
								QI5->QI5_PRAZO  := dDataBase
							Else
								QI5->QI5_PRAZO  := dQI5Prazo
							EndIf
							QI5->(MsUnLock())
							dDTQI5 := QI5->QI5_PRAZO
						Endif
						dbSkip()
					EndDo
				Endif
			Endif
		Endif
	Endif
	RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QNCCorLed ºAutor  ³Leandro             º Data ³  19/08/2008 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Led das Etapas                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe	 ³QNCCorLed(aPend)                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³aPend -                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³QNCCorLed                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function QNCCorLed(aPend,nAt)
	Local oLed    	:=""
	Local oVerde  	:=LoaDbitmap(GetResources(),"BR_VERDE")
	Local oAzul   	:=LoaDbitmap(GetResources(),"BR_AZUL")
	Local oVermelho :=LoaDbitmap(GetResources(),"BR_VERMELHO")
	Local oBranco 	:=LoaDbitmap(GetResources(),"")

	If !aPend[nAt,6] .And. !aPend[nAt,5]
		oLed:= oVermelho
	ElseIf !aPend[nAt,1] .And. aPend[nAt,4] == "Sim" .And. aPend[nAt,5]
		oLed:= oAzul
	ElseIf !aPend[nAt,1] .And. aPend[nAt,4] == "Sim" .And. !aPend[nAt,5]
		oLed:=oVerde
	ElseIf !aPend[nAt,1] .And. aPend[nAt,4] == "Nao" .And. aPend[nAt,5]
		oLed:=oAzul
	ElseIf aPend[nAt,1] .And. aPend[nAt,4] == "Nao" .And. aPend[nAt,5]
		oLed:=oAzul
	ElseIf aPend[nAt,1] .And. aPend[nAt,4] == "Nao" .And. !aPend[nAt,5]
		oLed := oBranco
	ElseIf !aPend[nAt,1] .And. aPend[nAt,4] == "Nao" .And. !aPend[nAt,5]
		oLed:=oVerde
	Endif

Return(oLed)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ QValRecursoºAutor  ³Microsiga         º Data ³  14/08/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QValRecurso(cRecurso,cPlano,cRev,cEtapa,cNomRec, cRecAdic)
// Projeto TDI - TEGL40 - Nome do recurso na tela de alocacao semi-automatica
// cNomRec -> nome do recurso (por referencia)
// cRecAdic -> Lista de recursos adicionais

	Local aArea 	:= GetArea()
	Local aAreaAE8  := {}
	Local lRet  	:= .T.
	Local aRet		:= {}

	Default cPlano 	:= ""
	Default cRev   	:= ""
	Default cEtapa 	:= ""

// Projeto TDI - TEGL40 - Nome do recurso na tela de alocacao semi-automatica
	Default cNomRec := ""

	If !Empty(cRecurso)
		dbSelectArea("AE8")
		aAreaAE8 := AE8->(GetArea())
		AE8->(DbSetOrder(1))
		If !AE8->(DbSeek(xFilial("AE8") + cRecurso))
			If !IsBlind()
				MsgAlert(OemToAnsi(STR0112))//"Digite um recurso valido"
			Endif
			lRet     := .F.
			cRecurso := space(Len(AE8->AE8_RECURS))
		Endif
		// Projeto TDI - TEGL40 - Nome do recurso na tela de alocacao semi-automatica
		if lRet
			cNomRec  := AE8->AE8_DESCRI
		Endif

		cMemo1 := Space(Len(QUP->QUP_RESP2))

		RestArea(aAreaAE8)
	Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Função que Verifica se o Recurso está Off-Line. Retorna o Recurso e lRet			³
//³ aRet[1] := Código do Recurso Substituto ou Atual / [2] := lRet .T./.F.				³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aRet := QNCRecOff(cRecurso,.T.)

	If Len(aRet) > 0 .And. lRet
		cRecurso := aRet[1]
		lRet 	 := aRet[2]
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada criado para validacao de permissao de usuario executar etapa - PRICE³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If lRet .And. ExistBlock("Q120RESP")
		lRet := ExecBlock("Q120RESP",.F.,.F., {cRecurso,cPlano,cRev,cEtapa})
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Refresh para atualização do Objeto da Seleção do Recurso								³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oRecSel1:Refresh()

	RestArea(aArea)

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNCHECK   ³ Autor ³ Leandro S. Sabino     ³ Data ³05/12/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida se rotina esta disponivel para ser acessada.	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA120, QNCA130, QNCA140, QNCA150, QNCA170                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNCHECK()
Local lTMKPMS   := If(GetMv("MV_QTMKPMS",.F.,1) == 1,.F.,.T.)//Integracao do QNC com TMK e PMS: 1-Sem integracao,2-TMKxQNC,3-QNCxPMS,4-TMKxQNCxPMS ³
Local lret := .T.

	If !lTMKPMS
	Help (" ",1,"QTMKPMS" )
	lRet:= .F.
	Else
		If (GetMv("MV_QTMKPMS") == 0)
		Help (" ",1,"QTMKPMS" )
		lRet:= .F.	
		Endif
	Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QRetDesc  ºAutor  ³Denis Martins       º Data ³  01/19/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna a descricao do tipo do Documento                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QNCXFUN                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QRetDesc()
	Local cDEtapa:= CriaVar("QIE_DESDOC",.F.)
	Local aArea := GetArea()
	Local nPosCDc := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QIE_TIPODC" })
	Local nPosDDc := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QIE_DESDOC" })
	Local nx

	If nPosDDc > 0 .and. nPosCDc > 0
		dbSelectArea("QUU")
		dbSetOrder(1)
		If dbSeek(xFilial("QUU")+aCols[n,nPosCDc])
			aCols[n,nPosDDc] := QUU->QUU_DESCDO
			cDEtapa := aCols[n,nPosDDc]
		Endif
	Endif

	If Len(aCols) > 1 .and. Alltrim(FunName()) $ "QNCA050|QNCLOAD"
		dbSelectArea("QUU")
		dbSetOrder(1)
		For nx := 1 To Len(aCols)
			If dbSeek(xFilial("QUU")+aCols[nx,nPosCDc])
				aCols[nx,nPosDDc] := QUU->QUU_DESCDO
				cDEtapa := aCols[nx,nPosDDc]
			Endif
		Next nx
	Endif

	RestArea(aArea)
Return cDEtapa

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QSelPlanETP  ºAutor  ³Leandro Sabino   º Data ³  22/01/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Seleciona Plano de acao sem Projeto/EDT definidos, qdo o    º±±
±±º          ³MV_QTMKPMS estiver configurado igual 3 ou 4                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QNCXFUN                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QSelPlanETP()
	Local cQuery := ""
	Local cAlias := ""
	Local cAviso := ""
	Local lAviso := .F.
	Local lTMKPMS:= If(GetMv("MV_QTMKPMS",.F.,1) == 1,.F.,.T.)//Integracao do QNC com TMK e PMS: 1-Sem integracao,2-TMKxQNC,3-QNCxPMS,4-TMKxQNCxPMS ³
	Local aArea  := GetArea()

	If lTMKPMS
		If (GetMv("MV_QTMKPMS") == 3) .Or. (GetMv("MV_QTMKPMS") == 4)

			ProcRegua(4)

			IncProc(STR0150)//"Selecionando Planos..."

			cQuery := " SELECT DISTINCT QI3.QI3_CODIGO, QI3.QI3_REV "
			cQuery += "FROM "+RetSqlName("QI9")+" QI9,"+RetSqlName("QI3")+" QI3, "+RetSqlName("QI2")+" QI2 "
			cQuery += "WHERE "
			cQuery += "QI9.QI9_FILIAL = '" + xFilial("QI3") + "' AND "
			cQuery += "QI9.QI9_CODIGO = QI3.QI3_CODIGO AND "
			cQuery += "QI9.QI9_REV    = (SELECT MAX(QI3_REV) QI3_REV  FROM "+RetSqlName("QI3")+" A WHERE A.QI3_FILIAL = '" + xFilial("QI3") + "' AND A.QI3_CODIGO = QI3.QI3_CODIGO AND A.D_E_L_E_T_ = ' ' ) AND "
			cQuery += "QI3.QI3_ENCREA = '' AND "
			cQuery += "QI3.QI3_OBSOL <> 'S' AND "
			cQuery += "QI9.QI9_FILIAL = QI2.QI2_FILIAL AND "
			cQuery += "QI9.QI9_FNC    = QI2.QI2_FNC AND "
			cQuery += "QI9.QI9_REVFNC = QI2.QI2_REV AND "
			cQuery += "QI2.QI2_CONREA = ''  AND "
			cQuery += "QI3.D_E_L_E_T_ = ' ' AND "
			cQuery += "QI2.D_E_L_E_T_ = ' ' "

			cQuery	:= ChangeQuery(cQuery)
			cAlias  := GetNextAlias()
			DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)

			IncProc(STR0151)//"Validando etapas do plano..."

			cAviso := STR0152//"O(s) Plano(s) de ação(ões) listado(s) abaixo encontram-se sem Projeto e/ou EDT definidos o que impossibilita a geração de sua(s) tarefa(s) no PMS"
			cAviso += CRLF

			While (cAlias)->(!EOF())
				DbSelectArea("QI5")
				DbSetOrder(1)
				If DbSeek(xFilial("QI5")+(cAlias)->QI3_CODIGO+(cAlias)->QI3_REV)
					If Empty(QI5->QI5_PROJET) .And. Empty(QI5->QI5_REVISA) .And. Empty(QI5->QI5_PRJEDT)
						cAviso += CRLF+"   "+QI5->QI5_CODIGO+" - "+QI5->QI5_REV
						lAviso:= .T.
					Endif
				EndIf
				(cAlias)->(DbSkip())
			End

			If lAviso
				cAviso += CRLF
				Aviso(STR0007,cAviso,{"OK"},3,STR0153)//"Plano(s) de açã(ões):"
			Endif

			(cAlias)->(DbCloseArea())

		Endif

	Endif

	RestArea(aArea)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QValPlanETP  ºAutor  ³Leandro Sabino   º Data ³  22/01/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida se existe Projeto/EDT definidos no plano de acao.    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QNCXFUN                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QValPlanETP(cCodigo,cRev,cEtapa)
	Local lRet := .F.
	Local aArea  := GetArea()

	DbSelectArea("QI5")
	DbSetOrder(1)
	If DbSeek(xFilial("QI5")+cCodigo+cREV+cEtapa)
		If !Empty(QI5->QI5_PROJET) .And. !Empty(QI5->QI5_REVISA) .And. !Empty(QI5->QI5_PRJEDT)
			lRet:= .T.
		Endif
	EndIf
	RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Q070VUso  ºAutor  ³Denis Martins       º Data ³  01/23/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se o campo Partic esta preenchido.                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QNCA070                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q070VUso()
	Local lRet := .T.
	Local lTMKPMS := If(GetMv("MV_QTMKPMS",.F.,1) == 1,.F.,.T.)

	If lTMKPMS
		If Empty(M->QAA_PARTIC)
			MessageDlg(STR0155) //"Devido a integracao QNC x PMS, QNC x TMK ou QNC x TMS e TMK, o campo Cod.Partic deve ser preenchido"
			lRet := .F.
		Endif
	Endif

Return lRet



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³QnVerQUO  ³ Autor ³Sandra Ribeiro         ³      ³09/03/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se executado upd de criação de campos na QUO.      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QNC                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function QnVerQUO()

Local lRet    := .T.
Local lTMKPMS := If(GetMv("MV_QTMKPMS",.F.,1) == 1,.F.,.T.)//Integracao do QNC com TMK e PMS: 1-Sem integracao,2-TMKxQNC,3-QNCxPMS,4-TMKxQNCxPMS ³

	If lTMKPMS
 		DbSelectArea("SX3")
		DbSetOrder(2)
		If DbSeek("QUO_PRODUT")
			lRet := .T.
		Else
			Final("MV_QTMKPMS",STR0157)
 			lRet := .F.
		EndIf
	EndIf

Return lRet 



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QnBXPMS     ºAutor  ³Microsiga           º Data ³  09/25/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QnBxPms(aQI5)

	Local nx := 0
	Local bCampo 	:= {|n| FieldName(n) }
	Local aArea		:= GetArea()
	Local aAreaAF9  := {}
	Local nQTMKPMS	:= GetNewPar("MV_QTMKPMS",0)
	Local cRevisao  := ""
	Local nj        := 0
	Local ni        := 0

	If ValType(nQTMKPMS) != "N"
		nQTMKPMS := 0
	EndIf

	DbSelectArea("AF9")
	DbSetOrder(1)
	cRevisao := PmsAF8Ver(aQI5[13])   //revisao do projeto
	If AF9->(dbSeek(xFilial("AF9")  + aQI5[13] + cRevisao +  aQI5[16] ))
		aAreaAF9 := AF9->(GetArea())
		DbSelectArea("AFF")
		For nj := 1 To FCount()
			M->&(EVAL(bCampo,nj)) := FieldGet(nj)
		Next nj
		M->AFF_FILIAL := xFilial("AFF")
		M->AFF_PROJET := aQI5[13]
		M->AFF_REVISA := cRevisao
		M->AFF_TAREFA :=aQI5[16]
		M->AFF_PERC   :=100
		M->AFF_OBS    := ""

		RecLock("AFF",.T.)
		For nx := 1 TO FCount()
			FieldPut(nx,M->&(EVAL(bCampo,nx)))
		Next nx
		AFF->AFF_FILIAL	:= xFilial("AFF")
		AFF->AFF_USER	:= RetCodUsr()
		MsUnlock()
		MSMM(,TamSx3("AFF_OBS")[1],,m->AFF_OBS,1,,,"AFF","AFF_CODMEM")
		PmsAvalAFF("AFF",1)

		Reclock("AF9",.F.)
		AF9->AF9_DTATUF := ddatabase
		AF9->AF9_DTATUI	:= ddatabase
		MsUnlock()
		RestArea(aAreaAF9)
	Endif

	DbSelectArea("AFU")
	For ni := 1 To FCount()
		M->&(EVAL(bCampo,ni)) := FieldGet(ni)
	Next ni
	M->AFU_OBS := ""
	Pms320Grava(NIL,.F.)

	RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GetSaldoAnºAutor  ³Marcelo Akama       º Data ³  05/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Pega saldo da tarefa anterior                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GetSaldoAnt( cAcao, cRevAcao, cTpAcao, nPMSDURAC )
	Local aArea		:= GetArea()
	Local aAreaAF9	:= AF9->(GetArea())
	Local aAreaAFU	:= AFU->(GetArea())
	Local nRet		:= 0

	If cRevAcao<="00"
		Return nRet
	EndIf
	cRevAnt := strzero(val(cRevAcao)-1,2)
	dbselectarea("AF9")
	dbsetorder(6)
	If AF9->(MsSeek(xfilial("AF9")+cAcao+cRevAnt+cTpAcao))
		nRet := AF9->AF9_HDURAC
		Dbselectarea("AFU")
		Dbsetorder(5) //AFU_FILIAL+AFU_CTRRVS+AFU_PROJET+AFU_REVISA+AFU_TAREFA+DTOS(AFU_DATA)+AFU_RECURS
		AFU->( MsSeek(xfilial("AFU")+"1"+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA) )
		Do While !AFU->(Eof()) .And. AFU->(AFU_FILIAL+AFU_CTRRVS+AFU_PROJET+AFU_REVISA+AFU_TAREFA)==xfilial("AFU")+"1"+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA
			nRet := nRet - AFU->AFU_HQUANT
			AFU->(dbSkip())
		EndDo
	Else
		//--Se nao chegou a gerar a tarefa nessa etapa na revisao anterior, gera a tarefa com a duracao do planejamento.
		nRet:= nPMSDURAC
	Endif

	RestArea(aAreaAF9)
	RestArea(aAreaAFU)
	RestArea(aArea)

Return nRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ParamXFil ºAutor  ³Rafael Duram Santos º Data ³  25/02/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ajusta o tamanho do retorno dos Parametros de Filial       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ParamXFil( cFilPar )

	Local nTamFil := FWSizeFilial()
	Local cFilAlt := Alltrim(cFilPar)
	Local nTam    := Len(Alltrim(cFilPar))
	Local nEspaco := 0
	Local nI	  := 0

	If nTam < nTamFil
		nEspaco := (nTamFil - nTam)
		For nI:=1 To nEspaco
			cFilAlt += " "
		Next
	Endif

Return cFilAlt

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡…o    ³ QNCPMSPrl  ³ Autor ³ Adriano da Silva    ³ Data ³ 27/05/10 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³ Finaliza as tarefas paralelas rejeitadas			          ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Sintaxe   ³ QNCPMSPrl(cCodPln,cRevPln,cEtpPln,cRejPln)                 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ ExpC1 = Codigo do Plano de Ação				              ³±±
	±±³          ³ ExpC2 = Revisão do Plano de Ação			                  ³±±
	±±³          ³ ExpC3 = Etapa do Plano de Ação a Rejeitar                  ³±±
	±±³          ³ ExpC4 = Etapa do Plano de Ação Rejeitado                   ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso      ³ QNCXFUN()                                                  ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QNCPMSPrl(cCodPln,cRevPln,cEtpPln,cRejPln)

	Local aArea		:= GetArea()

	Default cCodPln := ""
	Default cRevPln := ""
	Default cEtpPln := ""
	Default cRejPln := ""

	aAreaQI5 := QI5->(GetArea())

	DbSelectArea("QI5")	//Ação Corretiva x Ações
	DbGoTop()
	DbSetOrder(4)		//QI5_FILIAL+QI5_CODIGO+QI5_REV+QI5_TPACAO
	If DbSeek(xFilial("QI5")+PadR(AllTrim(cCodPln),TamSx3("QI5_CODIGO")[1])+AllTrim(cRevPln)+AllTrim(cEtpPln) )

		DbSelectArea("AF9")	//Tarefas do Projeto
		DbGoTop()
		aAreaAF9 := AF9->(GetArea())
		DbSetOrder(6)		//AF9_FILIAL+AF9_ACAO+AF9_REVACA+AF9_TPACAO

		If DbSeek(xFilial("AF9")+QI5->QI5_CODIGO+QI5->QI5_REV+QI5->QI5_TPACAO )
			Reclock("AF9",.F.)
			AF9->AF9_DTATUI	:= Date()
			AF9->AF9_DTATUF := Date()
			AF9->AF9_HRATUI	:= "00:00"
			AF9->AF9_HRATUF	:= "24:00"
			MsUnlock()
			FKCOMMIT()

			DbSelectArea("AFF")	//Confirmações
			aAreaAFF := AFF->(GetArea())
			DbSetOrder(1)		//AFF_FILIAL+AFF_PROJET+AFF_REVISA+AFF_TAREFA+DTOS(AFF_DATA)
			If DbSeek(AF9->AF9_FILIAL+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA )
				RecLock("AFF",.F.)
				AFF->AFF_QUANT := 1
				MsUnlock()
				FKCOMMIT()
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Função que Envia E-mail Para os Recursos Com Etp Paralela    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			QNCMailPrl(QI5->QI5_MAT,QI5->QI5_CODIGO,QI5->QI5_REV,QI5->QI5_TPACAO,cRejPln)

		EndIf

		RestArea(aAreaAF9)

	EndIf

	RestArea(aAreaQI5)

	RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QNCMailPrl³ Autor³ Adriano da Silva      ³ Data ³ 07/07/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina que envia e-mail ao responsaveis da rejeição das    ³±±
±±³          ³ etapas paralelas                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNCMailPrl(cMatCod,cPlnCod,cPlnRev,cPlnEtp,cPlnRej)        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do responsavel da etapa				      ³±±
±±³          ³ ExpC2 = Codigo do Plano de Ação				              ³±±
±±³          ³ ExpC3 = Revisão do Plano de Ação			                  ³±±
±±³          ³ ExpC4 = Etapa do Plano de Ação a Rejeitar                  ³±±
±±³          ³ ExpC5 = Etapa do Plano de Ação Rejeitado                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³ Nemhum													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Projeto Phoenix                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QNCMailPrl(cMatCod,cPlnCod,cPlnRev,cPlnEtp,cPlnRej)

	Local cHtml		:= " "
	Local aUsua		:= {}
	Local aMsg		:= {}
	Local cSubject	:= ""
	Local cMail		:= ""
	Local cTpMail   := ""
	Local cCodFNC	:= ""
	Local cRevFNC	:= ""
	Local cEtpAtu 	:= ""
	Local cEtpRej 	:= ""
	Local aArea		:= GetArea()
	Local aAreaQI9 	:= {}

	Default cMatCod := ""
	Default cPlnCod := ""
	Default cPlnRev := ""
	Default cPlnEtp := ""
	Default cPlnRej := ""

	DbSelectArea("QI9")	//Ação Corretiva x Não Conformidade
	aAreaQI9 	:= QI9->(GetArea())
	DbSetOrder(1)		//QI9_FILIAL+QI9_CODIGO+QI9_REV+QI9_FNC+QI9_REVFNC
	If DbSeek(xFilial("QI9")+PadR(AllTrim(cPlnCod),TamSx3("QI5_CODIGO")[1])+AllTrim(cPlnRev))
		cCodFNC	:= QI2->QI2_FNC
		cRevFNC := QI2->QI2_REV
	EndIf

	RestArea(aAreaQI9)

	DbSelectArea("QAA")	//Usuários QNC
	aAreaQAA 	:= QAA->(GetArea())
	DbSetOrder(1)		//QAA_FILIAL+QAA_MAT
	If DbSeek(xFilial("QAA")+cMatCod)
		cMail	:= QAA->QAA_EMAIL
		cTpMail := QAA->QAA_TPMAIL
	EndIf

	cEtpAtu := cPlnEtp + "-" + AllTrim(FQNCDTPACAO(cPlnEtp))
	cEtpRej := cPlnRej + "-" + AllTrim(FQNCDTPACAO(cPlnRej))

	If !Empty(cMail) .And. !Empty(cTpMail)
		If Alltrim(cTpMail) == "1" //Se For HTML
			cHtml :="<html>"
			cHtml +="<head>"
			cHtml +="<body>"
			cHtml +="<p></p>"
			cHtml +='<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width="100%"'
			cHtml +="       style='width:100.0%;"
			cHtml +="       mso-cellspacing:0cm;"
			cHtml +="       mso-yfti-tbllook:1184;"
			cHtml +="       mso-padding-alt:0cm 0cm 0cm 0cm'>"
			cHtml +=" <tr style='mso-yfti-irow:0;"
			cHtml +="              mso-yfti-firstrow:yes;"
			cHtml +="              mso-yfti-lastrow:yes'>"
			cHtml +="   <td style='background:#C5D1CB;padding:0cm 0cm 0cm 0cm'>"
			cHtml +="      <p class=MsoNormal align=center style='text-align:center'>"
			cHtml +="        <b>"
			cHtml +="          <span style='font-size:10.0pt;"
			cHtml +='                font-family:"Verdana","sans-serif";'
			cHtml +='                mso-fareast-font-family:"Times New Roman";'
			cHtml +="                color:black'>" + STR0163 + "<o:p></o:p>"	//"TRANSFERÊNCIA PARA ÁREA DE MANUTENÇÃO"
			cHtml +="          </span>"
			cHtml +="        </b>"
			cHtml +="      </p>"
			cHtml +="   </td>"
			cHtml +=" </tr>"
			cHtml +="</table>"
			cHtml +=" <tr style='mso-yfti-irow:1'>"
			cHtml +="  <td style='padding:0cm 0cm 0cm 0cm'>"
			cHtml +="   <p class=MsoNormal>"
			cHtml +="    <span style='font-size:8.5pt;"
			cHtml +='          font-family:"Verdana","sans-serif";'
			cHtml +='          mso-fareast-font-family:"Times New Roman";'
			cHtml +="          color:#333333'>"+ STR0164 + "<o:p></o:p>"
			cHtml +="    </span>"
			cHtml +="   </p>"
			cHtml +="  </td>"
			cHtml +="</tr>"
			cHtml +="</table>"
			cHtml +=" <tr style='mso-yfti-irow:3'>"
			cHtml +="  <td style='padding:0cm 0cm 0cm 0cm'>"
			cHtml +="   <p class=MsoNormal>"
			cHtml +="    <span style='font-size:8.5pt;"
			cHtml +='          font-family:"Verdana","sans-serif";'
			cHtml +='          mso-fareast-font-family:"Times New Roman";'
			cHtml +="          color:#333333'>" + STR0165 + cEtpAtu + STR0166 + cPlnCod + "/"+ cPlnRev +; 		//"A etapa " ### " pertecente ao Plano "
			" FNC "  +cCodFNC + "/" + cRevFNC + STR0167 + cEtpRej + "." 	//" foi rejeitada devido a rejeição da etapa "
			cHtml +="    </span>"
			cHtml +="   </p>"
			cHtml +="  </td>"
			cHtml +=" </tr>"
			cHtml +="</table>"
			cHtml +="<html>"
		Else
			cHtml :=STR0163+Chr(13)+Chr(10)+Chr(13)+Chr(10) 						//"TRANSFERÊNCIA PARA ÁREA DE MANUTENÇÃO"
			cHtml +=STR0164+Chr(13)+Chr(10)+Chr(13)+Chr(10)     					//"Prezado,"
			cHtml +=STR0165+cEtpAtu+STR0166+cPlnCod + "/"+ cPlnRev +; 				//"A etapa " ### " pertecente ao Plano "
			" FNC "  +cCodFNC + "/" + cRevFNC + STR0167 + cEtpRej + "."		//" foi rejeitada devido a rejeição da etapa "
			cHtml +=Chr(13)+Chr(10)
		EndIf

		If !Empty(cHtml)
			aMsg:= { { cSubject,cHtml, "" } }
			aadd(aUsua,{ QAA->QAA_NOME,Trim(cMail),aMsg })
			QNEnvMail(aUsua,,,)
			aUsua := {}
		EndIf

	EndIf

	RestArea(aAreaQAA)

	RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNEnvMail ³ Autor ³ Aldo Marini Junior    ³ Data ³ 26/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina que envia e-mail de acordo com array                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QAEnvMail(ExpA1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array com os dados de envio (To,Subject,Body,      ³±±
±±³          ³         Attachment)                                        ³±±
±±³          ³ ExpC1 = Caracter contendo conta de acesso ao servidor      ³±±
±±³          ³ ExpC2 = Caracter contendo o endereco do servidor           ³±±
±±³          ³ ExpC3 = Caracter contendo senha de acesso ao servidor      ³±±
±±³          ³ ExpC4 = Caracter contendo a conta do Usuario logado        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³ lResult = Logico retornando se houve algum erro no envio   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GENERICO                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QNEnvMail(aUsuarios,cMailConta,cMailServer,cMailSenha,cSendConta)

	Local lResult	:= .F.
	Local aRetUser := {}
	Local nAtConta

	Default cMailConta  := AllTrim(GETMV("MV_EMCONTA"))
	Default cMailServer := AllTrim(GETMV("MV_RELSERV"))
	Default cMailSenha  := AllTrim(GETMV("MV_EMSENHA"))
	Default cSendConta  := AllTrim(GETMV("MV_EMCONTA"))

	If Len(aUsuarios) == 0
		Return(.F.)
	Endif

	If Empty(AllTrim(cSendConta))
		cSendConta := AllTrim(GETMV("MV_RELACNT"))
	Endif

	If Empty(AllTrim(cMailConta))
		cMailConta := AllTrim(GETMV("MV_RELACNT"))
	Endif

	If Empty(AllTrim(cMailServer))
		cMailServer := AllTrim(GETMV("MV_RELSERV"))
	Endif

	If Empty(AllTrim(cMailSenha))
		cMailSenha := AllTrim(GETMV("MV_RELPSW"))
	Endif

	Processa({||QNRunMail(aUsuarios,cMailConta,cMailServer,cMailSenha,@lResult,cSendConta)},STR0168 )	//"Enviando e-Mail para os Usuarios..."

Return(lResult)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNRunMail ³ Autor ³ Aldo Marini Junior    ³ Data ³ 26/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina que envia e-mail Mostrando Msg de Processamento     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QARunMail(ExpA1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array com os dados de envio (To,Subject,Body,      ³±±
±±³          ³         Attachment)                                        ³±±
±±³          ³ ExpC1 = Caracter contendo conta de acesso ao servidor      ³±±
±±³          ³ ExpC2 = Caracter contendo o endereco do servidor           ³±±
±±³          ³ ExpC3 = Caracter contendo senha de acesso ao servidor      ³±±
±±³          ³ ExpL1 = Logical  indicando Erro na Conexao ao Servidor     ³±±
±±³          ³ ExpC4 = Caracter contendo a conta do Usuario logado        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³ lResult = Logico retornando se houve algum erro no envio   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GENERICO                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QNRunMail(aUsuarios,cMailConta,cMailServer,cMailSenha,lResult,cSendConta)

	Local nA := 1
	Local nI := 1
	Local cError	:= ""
	Local lAuth 	:= GetMv("MV_RELAUTH",,.F.)
	Local lMsgError	:= GetMv("MV_QMSGERM", .T., .T.)

	lResult	:= .F.

	If !Empty(cMailServer) .And. !Empty(cMailConta) .And. !Empty(cMailSenha)

		For nI :=1 to Len(aUsuarios)
			If !Empty(aUsuarios[nI,2])
				If ! lResult
					// Envia e-mail com os dados necessarios
					CONNECT SMTP SERVER cMailServer ACCOUNT cMailConta PASSWORD cMailSenha RESULT lResult

					// Autenticacao da conta de e-mail
					If lResult .And. lAuth
						lResult := MailAuth(cMailConta,cMailSenha)
						If !lResult
							lResult := QAGetMail() // Funcao que abre uma janela perguntando o usuario e senha para fazer autenticacao
						EndIf
						If !lResult
							//Erro na conexao com o SMTP Server
							If lMsgError
								GET MAIL ERROR cError
								MsgInfo(cError,OemToAnsi(STR0169))
							Endif
							Return Nil
						Endif
					Else
						If !lResult
							//Erro na conexao com o SMTP Server
							If lMsgError
								GET MAIL ERROR cError
								MsgInfo(cError,OemToAnsi(STR0170))	//"Erro de Conexao"
							Endif
							Return Nil
						Endif
					EndIf
				Endif

				If lResult
					For nA := 1 to Len(aUsuarios[nI,3])
						If !lResult
							Exit
						Endif

						SEND        MAIL  ;
							FROM        cSendConta ;
							TO          aUsuarios[nI,2] ;
							SUBJECT     "Aviso de Rejeição";
							BODY        aUsuarios[nI,3,nA,2] ;
							ATTACHMENT  aUsuarios[nI,3,nA,3];
							RESULT      lResult
					Next

					If !lResult
						//Erro no envio do email
						If lMsgError
							GET MAIL ERROR cError
							MsgInfo(cError,OemToAnsi(STR0171))	//"Erro no envio de e-Mail"
						Endif
					EndIf
				EndIf
				If ! lResult
					DISCONNECT SMTP SERVER
				Endif
			Endif
		Next
		DISCONNECT SMTP SERVER
	EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QNCRecOff ³ Autor³ Adriano da Silva      ³ Data ³ 15/07/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina que verifica se o Recurso está Off-Line e os 		  ³±±
±±³          ³ relacionamentos dos cadastros está correto                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNCRecOff(cCodRec)										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do responsavel da etapa   			      ³±±
               ExpC2 = Mostra Alerta de recurso OffLine	                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºRetorno   ³ ExpA1: Array: [1]: Codigo Recurso                          º±±
±±º          ³ ExpA2: Array: [2]: lRey				                      º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Projeto Phoenix                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QNCRecOff(cCodRec,lShowHlp)

	Local cHoraDia  := SubStr(Time(),1,5)
	Local aRet		 := {}
	Local aArea		 := GetArea()
	Local aID		 := {}
	Default lShowHlp :=.T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria indice temporario para pesquisar o Codigo de Recurso no cadastro de usuarios   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cIndQAA := CriaTrab(NIL,.F.)
	DbSelectArea("QAA")
	IndRegua("QAA",cIndQAA,"QAA_FILIAL+QAA_RECUR",,,)
	If DbSeek(xFilial("QAA")+cCodRec)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifico se o Usuario QNC está Off-Line									³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If QAA->QAA_OFFLIN == "1"

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifico se o Operador Está Preenchido no cadastro de Usuários - QNC	³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(QAA->QAA_OPERAD)

				aAreaSU7 := SU7->(GetArea())

				DbSelectArea("SU7") 	//Cadastro de Operadores
				SU7->(DbSetOrder(1))	//U7_FILIAL+U7_COD
				If SU7->(DbSeek(xFilial("SU7")+QAA->QAA_OPERAD))

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifico se o Operador Substituto Está Preenchido no cadastro na SU7	³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If Empty(SU7->U7_SUBSTIT)
						If !IsBlind() .AND. lShowHlp
							MsgAlert(OemToAnsi(STR0175 +;       //"Atenção, foi selecionado um Recurso Off-Line que NÃO tem Recurso Substituto Informado no cadastro de Operadores (Tabela SU7). "
							STR0173 +;							//" Portanto a Tarefa Será Alocada Para o Recurso Off-Line: "
							RTrim(Posicione('AE8',1,xFilial('AE8')+QAA->QAA_RECUR,'AE8_DESCRI')) ))
						EndIf
						aRet := {cCodRec,.T.}

					Else

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifico se Existe a Tabela AGF no Dicionario de Dados					³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If ChkFile("AGF")

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Verifico a Quantidade de Registros (AGF_ID) da Tabela AGF 				³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							DbSelectArea("AGF")		//Historico Status Operadores
							AGF->(DbSetOrder(1))	//AGF_FILIAL+AGF_OPERAD+AGF_ID
							DbGoTop()
							If AGF->(DbSeek(xFilial("AGF")+QAA->QAA_OPERAD) )
								While !Eof() .And. AGF->AGF_FILIAL == xFilial("AGF") .And. AGF->AGF_OPERAD == QAA->QAA_OPERAD
									Aadd (aID,AGF->AGF_ID)
									DbSkip()
								EndDo
							EndIf

							If Len(aID) > 0

								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Posiciono na Tabela AGF com o Ultimo Registro do campo AGF_ID			³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								DbSelectArea("AGF")		//Historico Status Operadores
								AGF->(DbSetOrder(1))	//AGF_FILIAL+AGF_OPERAD+AGF_ID
								DbGoTop()
								If AGF->(DbSeek(xFilial("AGF")+QAA->QAA_OPERAD+aID[Len(aID)]) )

									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Verifico se a Data e Hora Atual Está na Vigência do Ultimo Registro		³
									//³ da Tabela de Historico de Operadores - Tabele AGF						³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									If AGF->AGF_DTINI <= Date() .And. AGF->AGF_DTFIM >= Date() .And. cHoraDia > AGF->AGF_HRINI .And. cHoraDia < AGF->AGF_HRFIM

										aAreaQAA := QAA->(GetArea())

										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³ Cria indice temporario para pesquisar o Cod. Operador Substituto na Tabela QAA		³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										cIndSU7 := CriaTrab(NIL,.F.)
										DbSelectArea("QAA")
										IndRegua("QAA",cIndSU7,"QAA_FILIAL+QAA_OPERAD",,,)
										If DbSeek(xFilial("QAA")+SU7->U7_SUBSTIT)
											If !IsBlind() .OR. lShowHlp
												MsgAlert(OemToAnsi(STR0176 +; 	//"Atenção, foi selecionado um Recurso Off-Line que está dentro da Vigência "
												AllTrim(DtoC(AGF->AGF_DTINI)) + "-" + AGF->AGF_HRINI + " ás " + AllTrim(DtoC(AGF->AGF_DTFIM)) + "-" + AGF->AGF_HRFIM +;
													STR0177 +;						//" do Recurso Substituto. Portanto a Tarefa Será Alocada Para o Recurso: "
												RTrim(Posicione('AE8',1,xFilial('AE8')+QAA->QAA_RECUR,'AE8_DESCRI')) ))
											EndIf
											aRet := {QAA->QAA_RECUR,.T.}
										Else
											If !IsBlind() .OR. lShowHlp
												MsgAlert(OemToAnsi(STR0176 +;		//"Atenção, foi selecionado um Recurso Off-Line que está dentro da Vigência "
												AllTrim(DtoC(AGF->AGF_DTINI)) + "-" + AGF->AGF_HRINI + " ás " + AllTrim(DtoC(AGF->AGF_DTFIM)) + "-" + AGF->AGF_HRFIM +;
													STR0178+;							//" do Recurso Substituto, Entretanto NÃO Foi Encontrado o Código do Operador Substitudo no Cadastro de Usuários QNC(Tabela QAA)."
												STR0173+;							//" Portanto a Tarefa Será Alocada Para o Recurso Off-Line: "
												RTrim(Posicione('AE8',1,xFilial('AE8')+AllTrim(cCodRec),'AE8_DESCRI')) ))
											EndIf
											aRet := {cCodRec,.T.}
										EndIf

										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³ Apagar arquivo do Indice Temporario								³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										DbSelectArea("QAA") //Usuarios QNC
										DbSetOrder(1)
										If file(cIndSU7+OrdBagExt())
											Ferase(cIndSU7+OrdBagExt())
										EndIf

										RestArea(aAreaQAA)

									Else
										If !IsBlind() .AND. lShowHlp

											MsgAlert(STR0183+;
												RTrim(Posicione('AE8',1,xFilial('AE8')+AllTrim(cCodRec),'AE8_DESCRI'))+;
												STR0184+;
												AllTrim(DtoC(AGF->AGF_DTINI))+STR0185 + AGF->AGF_HRINI + STR0187+;
												AllTrim(DtoC(AGF->AGF_DTFIM)) + STR0185 + AGF->AGF_HRFIM+;
												STR0186  + AllTrim(DtoC(Date()))+;
												STR0188+;
												RTrim(Posicione('AE8',1,xFilial('AE8')+AllTrim(cCodRec),'AE8_DESCRI')))

										EndIf
										aRet := {cCodRec,.T.}

										// Periodo da situacao OffLine Vencido, Atualizar o cadastro para: OffLine = NAO.
										If RecLock("QAA",.F.)
											QAA->QAA_OFFLIN := '2'
											MsUnLock()
											FKCOMMIT()
										Endif

									EndIf

								Else
									If !IsBlind() .AND. lShowHlp
										MsgAlert(OemToAnsi(STR0181+; //"Atenção, foi selecionado um Recurso Off-Line Que NÃO Está Cadastrado nas Vigências do Operador Substituto (Tabela AGF)."
										STR0173+;					//" Portanto a Tarefa Será Alocada Para o Recurso Off-Line: "
										RTrim(Posicione('AE8',1,xFilial('AE8')+AllTrim(cCodRec),'AE8_DESCRI')) ))
									EndIf
									aRet := {cCodRec,.T.}
								EndIf

							Else
								If !IsBlind() .AND. lShowHlp
									MsgAlert(OemToAnsi(STR0181+;	//"Atenção, foi selecionado um Recurso Off-Line Que NÃO Está Cadastrado nas Vigências do Operador Substituto (Tabela AGF)."
									STR0173+;						//" Portanto a Tarefa Será Alocada Para o Recurso Off-Line: "
									RTrim(Posicione('AE8',1,xFilial('AE8')+AllTrim(cCodRec),'AE8_DESCRI')) ))
								EndIf
								aRet := {cCodRec,.T.}
							EndIf
						Else
							If !IsBlind() .AND. lShowHlp
								MsgAlert(OemToAnsi(STR0182 +;		//"Atenção, o Usuário/Responsável Está Off-Line, mas não existe a Tabela AGF. Favor Aplicar o UPDTMK027 e UPDTMK07!"
								STR0173+;							//" Portanto a Tarefa Será Alocada Para o Recurso Off-Line: "
								RTrim(Posicione('AE8',1,xFilial('AE8')+AllTrim(cCodRec),'AE8_DESCRI')) ))
							EndIf
							aRet := {cCodRec,.T.}
						EndIf

					EndIf

				Else
					If !IsBlind() .AND. lShowHlp
						MsgAlert(OemToAnsi(STR0172+;	//"Atenção, o Recurso Selecionado Está Como Recurso Off-Line, Mas NÃO Há Código de Operador Informado no Cadastro da Tabela SU7!"
						STR0173+;						//" Portanto a Tarefa Será Alocada Para o Recurso Off-Line: "
						RTrim(Posicione('AE8',1,xFilial('AE8')+AllTrim(cCodRec),'AE8_DESCRI')) ))
					Endif
					aRet := aRet := {cCodRec,.T.}
				EndIf

				RestArea(aAreaSU7)

			Else
				If !IsBlind() .AND. lShowHlp
					MsgAlert(OemToAnsi(STR0174 +;	//"Atenção, o Usuário/Responsável Está Como Recurso Off-Line e Não Há Código de Operador Informado no Cadastro da Tabela QAA!"
					STR0173+;						//" Portanto a Tarefa Será Alocada Para o Recurso Off-Line: "
					RTrim(Posicione('AE8',1,xFilial('AE8')+AllTrim(cCodRec),'AE8_DESCRI')) ))
				Endif
				aRet := aRet := {cCodRec,.T.}
			EndIf
		EndIf
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apagar arquivo do Indice Temporario								³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("QAA") //Usuarios QNC
	DbSetOrder(1)
	If file(cIndQAA+OrdBagExt())
		Ferase(cIndQAA+OrdBagExt())
	EndIf

	RestArea(aArea)

Return aRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QNCEtpPai ºAutor  ³Andre Anjos         º Data ³  04/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Retorna a etapa pai do paralelismo para o grupo e etapa 	  º±±
±±º          ³ informados                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cGrupo: codigo do grupo de etapas.						  º±±
±±º			 ³ cEtapa: codigo da etapa.									  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno	 ³ cRet: codigo da etapa pai do paralelismo.				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QNCXFUN                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function QNCEtpPai(cGrupo,cEtapa)
	Local aArea    := GetArea()
	Local aAreaQUP := QUP->(GetArea())
	Local cRet 	   := ""

	dbSelectArea("QUP")
	dbSetOrder(1)
	dbSeek(xFilial("QUP")+cGrupo)
	While !EOF() .And. QUP_FILIAL+QUP_GRUPO == xFilial("QUP")+cGrupo
		If cEtapa $ QUP_ETAPAP
			cRet := QUP_TPACAO
			Exit
		EndIf
		dbSkip()
	End

	RestArea(aAreaQUP)
	RestArea(aArea)
Return cRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QNRECALOC   ºAutor  ³Leonardo Quintaniaº Data ³  05/17/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Utilizado para atualizar a data de alocação do recurso     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QNCXFUN                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function QNRecAloc(cRecurso,cHora,aAlocs,dDtIniSel,cHrIni,dDtIni,nHorasPSeq)
	Local aHabsReq  := {}
	Local aAlocDisp := {}
	Local cCalend
	Local aTrfDatas := {}

// TGBOYK esta variavel e criada apenas quando a execucao passa pelo PMSMONIT, 
// entao deve criar caso nao exista para evitar errorlog
	dQI5PRAZO := if(Type("dQI5PRAZO")<>"D",Ctod(""),dQI5PRAZO)

	If YEAR(dDtIniSel)== 0
		aAlocs := PMSRecDisp(aHabsReq ,dQI5PRAZO ,QNCPrzHR2(cHora	,"H","H","D","H") + nHorasPSeq,cPROJET,@aAlocDisp,Alltrim(cRecurso))  //Aloca recurso na primeira data disponivel.
		If !Empty(aAlocs)
			aCRIAR := PMSDTaskF(aAlocs[2],aAlocs[3],Posicione("AE8",1,xFilial("AE8")+AllTrim(cRecurso),"AE8_CALEND"),QNCPrzHR2(cHora	,"H","H","D","H"),cPROJET,cRecurso)
			aAlocs[4] := aCRIAR[3]
			aAlocs[5] := aCRIAR[4]
		Else
			aAlocs := QNCPMSDtDf( dQI5PRAZO,QNCPrzHR2(cHora	,"H","H","D","H"),cPROJET,cRecurso, aTrfDatas ) /// Assume Data Prazo da FNC Realizando superalocação de usuario.
			aAlocs := {cRecurso,aAlocs[1],aAlocs[2],aAlocs[3],aAlocs[4]}
		Endif
	Else
		cCalend   := Posicione("AE8",1,xFilial("AE8")+AllTrim(cRecurso),"AE8_CALEND")
		aTrfDatas := PMSDTaskF(dDtIniSel,cHrIni,cCalend,QNCPrzHR2(cHora	,"H","H","D","H"),cPROJET,cRecurso)
		aAlocs	  := {cRecurso,aTrfDatas[1],aTrfDatas[2],aTrfDatas[3],aTrfDatas[4]}
	EndIf

	dDtIni:= aAlocs[2]
	cHrIni:= aAlocs[3]

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QValBotao ºAutor  ³Aldo Barbosa dos Santos    ³  10/04/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ativa/Desativa botoes na rotina QAlocPMS                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³QAlocPMS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QValBotao(cResour2,oBtn1,oBtn2)

	if Empty(cResour2)
	oBtn1:lActive := .T.
	oBtn2:lActive := .F.
	Else
	oBtn1:lActive := .T.
	oBtn2:lActive := .T.
	Endif
	
Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AvisoQTimer º Autor  ³ Rafael Duram    º Data ³  15/07/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Copia da funcao aviso() (matxfuna.prx) acrescentando timer  º±±
±±º          ³para nao ficar parado na tela de bloqueio do PCO            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION AvisoQTimer(cCaption,cMensagem,aBotoes,nSize,cCaption2, nRotAutDefault,cBitmap,nTime,nOpcTimer)

	Local ny        := 0
	Local nx        := 0
	Local aSize  := {  {134,304,35,155,35,113,51},;  // Tamanho 1
	{134,450,35,155,35,185,51},; // Tamanho 2
	{227,450,35,210,65,185,99} } // Tamanho 3
	Local nLinha    := 0
	Local cMsgButton:= ""
	Local oGet
	Local oTimer

	Private oDlgAviso
	Private nOpcAviso := 0

	DEFAULT nTime 		:= 0
	DEFAULT nOpcTimer 	:= 1

	cCaption2 := Iif(cCaption2 == Nil, cCaption, cCaption2)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Quando for rotina automatica, envia o aviso ao Log.          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Type('lMsHelpAuto') == 'U'
		lMsHelpAuto := .F.
	EndIf

	If !lMsHelpAuto
		If nSize == Nil
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica o numero de botoes Max. 5 e o tamanho da Msg.       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If  Len(aBotoes) > 3
				If Len(cMensagem) > 286
					nSize := 3
				Else
					nSize := 2
				EndIf
			Else
				Do Case
				Case Len(cMensagem) > 170 .And. Len(cMensagem) < 250
					nSize := 2
				Case Len(cMensagem) >= 250
					nSize := 3
				OtherWise
					nSize := 1
				EndCase
			EndIf
		EndIf
		If nSize <= 3
			nLinha := nSize
		Else
			nLinha := 3
		EndIf
		DEFINE MSDIALOG oDlgAviso FROM 0,0 TO aSize[nLinha][1],aSize[nLinha][2] TITLE cCaption Of oMainWnd PIXEL
		DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD
		@ 0, 0 BITMAP RESNAME "LOGIN" oF oDlgAviso SIZE aSize[nSize][3],aSize[nSize][4] NOBORDER WHEN .F. PIXEL
		@ 11 ,35  TO 13 ,400 LABEL '' OF oDlgAviso PIXEL
		If cBitmap <> Nil
			@ 2, 37 BITMAP RESNAME cBitmap oF oDlgAviso SIZE 18,18 NOBORDER WHEN .F. PIXEL
			@ 3  ,50  SAY cCaption2 Of oDlgAviso PIXEL SIZE 130 ,9 FONT oBold
		Else
			@ 3  ,37  SAY cCaption2 Of oDlgAviso PIXEL SIZE 130 ,9 FONT oBold
		EndIf
		If nSize < 3
			@ 16 ,38  SAY cMensagem Of oDlgAviso PIXEL SIZE aSize[nLinha][6],aSize[nLinha][5]
		Else
			@ 16 ,38  GET oGet VAR cMensagem Of oDlgAviso PIXEL SIZE aSize[nLinha][6],aSize[nLinha][5] READONLY MEMO
		EndIf
		If Len(aBotoes) > 1
			TButton():New(1000,1000," ",oDlgAviso,{||Nil},32,10,,oDlgAviso:oFont,.F.,.T.,.F.,,.F.,,,.F.)
		EndIf
		ny := (aSize[nLinha][2]/2)-36
		For nx:=1 to Len(aBotoes)
			cAction:="{||nOpcAviso:="+Str(Len(aBotoes)-nx+1)+",oDlgAviso:End()}"
			bAction:=&(cAction)
			cMsgButton:= OemToAnsi(AllTrim(aBotoes[Len(aBotoes)-nx+1]))
			cMsgButton:= IF( ( "&" $ SubStr( cMsgButton , 1 , 1 ) ) , cMsgButton , ( "&"+cMsgButton ) )
			TButton():New(aSize[nLinha][7],ny,cMsgButton, oDlgAviso,bAction,32,10,,oDlgAviso:oFont,.F.,.T.,.F.,,.F.,,,.F.)
			ny -= 35
		Next nx

		//timer para fechar tela aviso na tela de bloqueio do PCO
		If nTime > 0
			oTimer:= TTimer():New(nTime,{|| (nOpcAviso := nOpcTimer, oDlgAviso:End()) },oDlgAviso)
			oTimer:Activate()
		EndIf

		ACTIVATE MSDIALOG oDlgAviso CENTERED

	Else
		If ValType(nRotAutDefault) == "N" .And. nRotAutDefault <= Len(aBotoes)
			cMensagem += " " + aBotoes[nRotAutDefault]
			nOpcAviso := nRotAutDefault
		Endif
		AutoGrLog(cCaption)
		AutoGrLog(cMensagem)
	EndIf

Return (nOpcAviso)

/*/{Protheus.doc} QncGrvOpe

Atualizacao do recurso atual no chamado. Função já se encontra disponivel na versão P10 desde 28/06/12. 

IMPORTANTE: a funcao que chamar esta já deve estar com o registro da AF9 posicionado. 

@author Aldo Barbosa dos Santos

@since 09/12/13

@version P11 R4

@param lModo,   logico, Se deve atualizar a tabela ADE, se for por FNC

@return nulo

/*/
Function QNCGRVOPE(lModo)
// Projeto TDI TEGJD7 - Atualizacao do recurso atual no chamado
	Local cCodOper	:= "" // RDZRetEnt( "QAA", xFilial("QAA")+QI5->QI5_MAT, "SU7", /*cEmpENT*/, /*cFilAnt*/, .F., .F., .T. )
	Local cGrupo	:= "" // TkPosto( cCodOper , "U0_CODIGO" )
	Local aArea 	:= {AFA->( GetArea()), QAD->( GetArea()), QI5->( GetArea()), QI2->( GetArea()), ADE->( GetArea()), SU7->( GetArea()), GetArea()}
	Local nA 		:= 1

	Local cRecurs  := ""

	DEFAULT lModo := .T. // lModo == .F. nao atualiza por nao se tratar de FNC

	if lModo
		// Projeto TDI TEGJD7 - Atualizacao do operador no processo de execucao da tarefa
		AFA->( Dbsetorder(1)) // AFA_FILIAL+AFA_PROJET+AFA_REVISA+AFA_TAREFA+AFA_ITEM+AFA_PRODUT+AFA_RECURS
		AFA->( Dbseek( AF9->( AF9_FILIAL+AF9_PROJET+AF9_REVISA+AF9_TAREFA)))
		Do While AFA->(!Eof()) .And. AF9->( AF9_FILIAL+AF9_PROJET+AF9_REVISA+AF9_TAREFA) == AFA->( AFA_FILIAL+AFA_PROJET+AFA_REVISA+AFA_TAREFA)
			If ! Empty(AFA->AFA_RECURS)
				cRecurs := AFA->AFA_RECURS
				if AFA->AFA_RESP == "1"  // sai quando localiza o responsavel pela tarefa
					Exit
				EndIf
			EndIf
			AFA->( Dbskip())
		Enddo

		cCodOper := RDZRETENT("AE8",xFilial("AE8")+cRecurs,"SU7",,,,.F.,.T.)

		// caso nao esteja posicionado na AFA deve procurar a FNC para localizar os dados
		If Empty(cCodOper) .and. ! Empty(AF9->AF9_FNC)
			QI5->( DbSetOrder(4)) // QI5_FILIAL+QI5_CODIGO+QI5_REV+QI5_TPACAO
			if QI5->( Dbseek( AF9->(AF9_FILIAL+AF9_ACAO+AF9_REVACA+AF9_TPACAO) ))
				cCodOper := RDZRETENT("QAA",xFilial("QAA")+QI5->QI5_MAT,"SU7",,,,.F.,.T.)
			Endif
		Endif

		If ! Empty(cCodOper)

			cGrupo  := TkPosto( cCodOper , "U0_CODIGO" )
			If ! Empty(cGrupo)
				DbselectArea("QI2") //Não Conformidade
				DbSetOrder(2)	//QI2_FILIAL+QI2_FNC+QI2_REV
				If QI2->(DbSeek(xFilial("QI2")+AF9->AF9_FNC+AF9->AF9_REVFNC))
					DbselectArea("ADE")		//Chamados de Help Desk
					DbSetOrder(1)	//ADE_FILIAL+ADE_CODIGO
					If ADE->(DbSeek(xFilial("ADE")+QI2->QI2_NCHAMA))
						If (ADE->ADE_GRUPO <> cGrupo .or. Alltrim(ADE->ADE_OPERAD) <> Alltrim(cCodOper))
							RecLock("ADE",.F.)
							ADE->ADE_GRUPO  := cGrupo
							ADE->ADE_OPERAD := cCodOper
							MsUnlock()
						EndIf
					EndIf
				EndIf
			EndIf
		Endif

	Endif

// ponto de entrada que permite alterar o responsavel pelo chamado
	IF ExistBlock( "QNCGRVOP" )
		ExecBlock( "QNCGRVOP", {lModo, cGrupo, cCodOper} )
	Endif

	For nA := 1 to Len(aArea)
		RestArea(aArea[nA])
	Next

Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} QNCATULEG()
Atualiza a legenda com os status disponíveis e grava o status do usuário posicionado na tabela QAA_SITQNC sendo
Amarelo		- Normal,com lancamentos pendentes
Preta		- Inativo, com lancamentos pendentes
Verde		- Normal,sem lancamentos pendentes
Vermelho	- Inativo, sem lancamentos pendentes
@author Sergio Seiji Naka
@since 07/10/14
@version 1.0
@return nRet
/*/
//-------------------------------------------------------------------
Function QNCATULEG(cFilUsr,cMatUsr)
	Local nRet			:= 1
	Local lAtivo 		:= QA_SitFolh()
	Local lPendente	:= .F.
	Local aAreaAnt 		:= GetArea()

	BeginSql alias 'QI3TRB'
		SELECT QAA.QAA_FILIAL  FROM %table:QAA% QAA
		WHERE QAA.QAA_FILIAL= %exp:cFilUsr% AND QAA.QAA_MAT= %exp:cMatUsr% AND

			(EXISTS( SELECT R_E_C_N_O_ FROM %table:QI3% QI3 WHERE
			QI3.QI3_FILMAT=QAA.QAA_FILIAL AND
			QI3.QI3_MAT=QAA.QAA_MAT AND
			QI3.QI3_ENCREA = ' ' AND
			QI3.%notDel% )
			OR
			EXISTS( SELECT R_E_C_N_O_ FROM %table:QI2% QI2  WHERE
			QI2.QI2_FILMAT=QAA.QAA_FILIAL AND
			QI2.QI2_MATRES=QAA.QAA_MAT AND
			QI2.QI2_CONREA = ' ' AND
			QI2.%notDel%  )
			OR
			EXISTS( SELECT R_E_C_N_O_ FROM %table:QI5% QI5  WHERE
			QI5.QI5_FILMAT=QAA.QAA_FILIAL AND
			QI5.QI5_MAT=QAA.QAA_MAT AND
			QI5.QI5_STATUS <> '4' AND
			QI5.%notDel%  ))
		EndSql

		QI3TRB->(DBGotop())
		If QI3TRB->(!EOF())
			lPendente:= .T.
		Endif
		QI3TRB->(DbCloseArea())

		If lAtivo .And. lPendente//se estiver ativo e estiver com lancamentos pendentes = amarelo
			nRet:= 2
		ElseIf !lAtivo .And. lPendente    //se estiver inativo e estiver com lancamentos pendentes = Preta
			nRet:= 4
		ElseIf lAtivo .And. !lPendente   //se estiver ativo e não estiver com lancamentos pendentes = Verde
			nRet:= 1
		Else   //se estiver inativo e não estiver com lancamentos pendentes = Vermelho
			nRet:= 3
		EndIf


		QAA->(DbSetOrder(1))//QAA_FILIAL+QAA_MAT
		If QAA->(DbSeek(cFilUsr+cMatUsr))
			RecLock("QAA",.F.)
			QAA->QAA_SITQNC:= nRet
			MsUnLock()
		EndIf

		RestArea(aAreaAnt)
		Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} QNCXCompat() 
Atualiza o status do usuário
@author taniel.silva
@since 13/10/2014
@version P12
/*/
//-------------------------------------------------------------------
Function QNCXCompat()

	DbselectArea("QAA")
	dbGoTop()
	While QAA->(!Eof())
		QNCATULEG(QAA->QAA_FILIAL,QAA->QAA_MAT)
		dbSkip()
	EndDo

Return nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QAlocPMS2 ºAutor  ³Aldo Barbosa dos Santos    ³  15/07/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Nova tela de alocacao semi-automatica                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function QAlocPMS2(cPlano,cRev,cEtapa,aAlocs,cHora,aHabsReq,aOtherRec,nHorasPSeq, lRet, aRecAdic)

Local aAreaOri := GetArea()
Local aAreaSX3 := {}
Local nAloc	:= 1
Local oDlg
Local oListBox
Local oOk		:= LoadBitmap( GetResources(), "LBOK" )
Local oNo		:= LoadBitmap( GetResources(), "LBNO" )
Local nOpcA
Local aTMPAloc	  := {}
Local cResour     := PADR("",15)	
Local cResour2    := PADR("",15)	
Local cHoraSel    := "        "
Local cF3Recurs   := "AE8"
Local cTituloCP	  := OemToAnsi(STR0113)//"Recurso sugerido:"
Local cTituloCP2  := OemToAnsi(STR0114)//"Deseja alterar esse recurso?" 
Local cTituloCP3  := OemToAnsi(STR0115)//"Hora default para executar a etapa:"
Local cTituloCP4  := OemToAnsi(STR0116)//"Deseja alterar esta hora?"
Local cTituloCP5  := OemToAnsi(STR0120)//"Data de inicio para execucao da etapa:?"
Local cTituloCP6  := OemToAnsi(STR0121)//"Deseja alterar a data de inicio da etapa?"
Local cTituloCP7  := OemToAnsi(STR0205) //""Confirma")//"Confirma"
Local cTituloCP8  := OemToAnsi(STR0206) // "Seguir Sugestao"+Chr(10)+"do Sistema")//"Seguir Sugestao do Sistema"
Local cTituloCP9  := OemToAnsi(STR0207) // "Confirma alterações?") // "Confirma alterações?"

Local lPMSBTCN    := GetMV( "MV_PMSBTCN",, .T. )

Local cNome    	   := ""
Local oNomeRec
Local oHrIni
Local oHRec 
Local oHRec1
Local oDtRec
Local oPanel    
Local oMemo1
Local oBtn1
Local oBtn2

Local dDtIni
Local dDtIniSel    := CTOD("  /  /  ")    
Local aTrfDatas	   := {} 
Local cHrIni   	   := ""
Local oHrIni
Local lQnAlocSem   := .T.
Local cNomRec2 := ""
Local cMemo1		:= ""
Local lAtiva 		:= .T.
Local cRecAdic    := ""
local lAuto		  := .F.

Local lQNALOCSEM := Existblock("QNALOCSEM")

DEFAULT aAlocs	:= {}
DEFAULT aHabsReq := {}	///Array com as habilidades requisitadas.
DEFAULT aOtherRec := {} ///Outros recursos (com o mesmo perfil) considerados no cáculo da alocação/disponibilidade.
DEFAULT lRet := .T.
DEFAULT aRecAdic := {}
//DEFAULT lTmk503Auto := .F. // Define padrao .F. caso a chamada nao seja pela rotina automatica do TeleAtendimento TMKA503A

DEFINE FONT oFont NAME "Arial" BOLD SIZE 9,14

// Variaveis Private da Funcao
Private _oDlg				// Dialog Principal
// Variaveis que definem a Acao do Formulario
Private VISUAL := .F.                        
Private INCLUI := .F.                        
Private ALTERA := .F.                        
Private DELETA := .F.                        

DEFINE FONT oArialBd14 NAME "Arial" BOLD SIZE 9,14
DEFINE FONT oArialBd10 NAME "Arial" BOLD SIZE 8,09

lAuto := Iif(type('lTmk503Auto')=='L',lTmk503Auto,.F.) 

// variavel necessaria para a tela semi-automatica no fonte QNCA120
	if Type("QNA120OPC") <> "N"
	Private QNA120OPC := 4
	Endif

aVetDia := {266,262,746,965}

aVetTxt := {{006,014,180,012,CLR_BLUE	, oArialBd14},; //[1] "Recurso Sugerido :"
				{006,185,180,012,CLR_RED	, oArialBd14},; //[2] "Deseja alterar este recurso?"
				{050,015,180,012,CLR_BLACK	, oArialBd14},; //[3] "Deseja Incluir Recursos Adicionais ?"
				{100,014,180,012,CLR_BLUE	, oArialBd14},; //[4] "Hora default para executar a tarefa:"
				{100,185,180,012,CLR_RED	, oArialBd14},; //[5] "Deseja alterar esta hora ?"
				{135,014,180,012,CLR_BLUE	, oArialBd14},; //[6] "Data de inicio sugerida pela alocacao : "
				{135,185,180,012,CLR_RED	, oArialBd14},; //[7] "Alterar data de inicio para :"
				{165,090,200,012,CLR_BLACK	, oArialBd14},; //[8] "Confirma as Alteracoes ?
				{175,090,275,012,CLR_BLACK	, oArialBd14}}  //[9] (clique em seguir sugestão do sistema para ingorar as alterações)"

aVetGet := {{015,015,050,010	},; //[01]
				{030,015,160,010	},; //[02]
				{015,185,050,010	},; //[03]
				{030,185,160,010	},; //[04]
				{060,070,270,030	},; //[05]
				{110,014,040,010	},; //[06]
				{110,185,040,010	},; //[07]
				{145,014,070,010	},; //[08]
				{145,102,040,010	},; //[09]
				{145,185,070,010	},; //[10]
				{145,273,040,010	}}  //[11]

aVetBtn := {{060,014,50,17	},; //[1] "Incluir"+Chr(10)+"Recursos" 
				{190,200,47,17	},; //[2] "Confirmar"
				{190,271,47,17	}}  //[3] "Seguir Sugestao"+Chr(10)+"do Sistema"


	If !Empty(GetSX3Cache("AFA_RECURS","X3_CAMPO"))
	cResour  	:= PADR("",GetSX3Cache("AFA_RECURS","X3_TAMANHO"))	
	cF3Recurs	:= GetSX3Cache("AFA_RECURS","X3_F3")
	EndIf

dbSelectArea("AE8")

	If Len(aAlocs) > 0
		If nAloc == 1
		lChecked := .T.
		Else
		lChecked := .F.	
		Endif
    cResour := aAlocs[1]
	Else
   QNCRespDef(@cResour,"",cEtapa,"",cPlano,cRev,.F.)
		If Empty(aAlocs)	///Se não encontrou alocação disponível pelo PMS.
		aTrfDatas:= PMSRecDisp(aHabsReq ,dQI5PRAZO,nQI5InHrs + nHorasPSeq ,cPROJET,@aAlocs,Alltrim(cResour))  //Aloca recurso na primeira data disponivel.    
			If !Empty(aTrfDatas)
			aDel(aTrfDatas,1)
			aSize(aTrfDatas,Len(aTrfDatas)-1)
			aCRIAR := PMSDTaskF(aTrfDatas[1],aTrfDatas[2],Posicione("AE8",1,xFilial("AE8")+AllTrim(cResour),"AE8_CALEND"),nQI5InHrs,cPROJET,cResour)
			aTrfDatas[3] := aCRIAR[3]
			aTrfDatas[4] := aCRIAR[4]
			Else
			aTrfDatas := QNCPMSDtDf( dQI5PRAZO,nQI5InHrs,cPROJET,cResour, aTrfDatas ) /// Assume Data Prazo da FNC Realizando superalocação de usuario.				
			Endif
		aAlocs:= {cResour,aTrfDatas[1],aTrfDatas[2],aTrfDatas[3],aTrfDatas[4]}
		EndIf
	EndIf

dbSelectArea("AE8")
dbSetOrder(1)
	If MsSeek(xFilial("AE8")+ALLTRIM(cResour),.F.)
	cNome := AE8->AE8_DESCRI
	Else
	cNome := ""
	EndIf
	If Len(aRecAdic) > 0
	cRecAdic := ""
	Aeval(aRecAdic, {|e| cRecAdic += e+";" } )
	cMemo1 := Padr(cRecAdic, Len(QUP->QUP_RESP2))
	Endif

	Do While .T.
	nOpca := 0 

	DEFINE MSDIALOG _oDlg TITLE "Alocacao de Tarefas - Plano de Acao:"+cPlano+" "+cRev+" "+If(!Empty(cEtapa),"Etapa: "+A120DEtapa(cEtapa),"") FROM aVetDia[1],aVetDia[2] TO aVetDia[3],aVetDia[4] PIXEL
		// Cria Componentes Padroes do Sistema
		@ aVetTxt[1,1],aVetTxt[1,2] Say cTituloCP Size aVetTxt[1,3],aVetTxt[1,4] COLOR aVetTxt[1,5] FONT aVetTxt[1,6] PIXEL OF oPanel // "Recurso Sugerido :"
		@ aVetGet[1,1],aVetGet[1,2] MsGet oRecSel  Var cResour F3 "SA1" When .F. Size aVetGet[1,3],aVetGet[1,4] COLOR CLR_BLACK PIXEL OF oPanel
		@ aVetGet[2,1],aVetGet[2,2] MsGet oNomeRec Var cNome            When .F. Size aVetGet[2,3],aVetGet[2,4] COLOR CLR_BLACK PIXEL OF oPanel
		oRecSel:Disable()
		oNomeRec:Disable()
	
		// "Deseja alterar este recurso?"
		@ aVetTxt[2,1],aVetTxt[2,2] Say cTituloCP2 Size aVetTxt[2,3],aVetTxt[2,4] COLOR aVetTxt[2,5] FONT aVetTxt[2,6] PIXEL OF oPanel
		@ aVetGet[3,1],aVetGet[3,2] MsGet oRecSel1 Var cResour2 F3 "QAE82" ;
			       VALID QValRecurso(@cResour2,cPlano,cRev,cEtapa,@cNomRec2,@cMemo1) .And. ;
							 QNRecAloc(IIF(!Empty(cResour2),cResour2,cResour),IIF(!Empty(cHoraSel),cHoraSel,cHora),@aAlocs,dDtIniSel,@cHrIni,@dDtIni,nHorasPSeq) .and. ; 
							 QncVldResp2(@cResour, @cResour2, @cMemo1, @aRecAdic) ;
					SIZE aVetGet[3,3],aVetGet[3,4] COLOR CLR_BLACK PIXEL OF oPanel HASBUTTON
		// Projeto TDI - TEGL40
		// Exibicao do nome do novo recurso na tela de alocacao
		@ aVetGet[4,1],aVetGet[4,2] MsGet oNomeRec Var cNomRec2 WHEN .F. SIZE aVetGet[4,3],aVetGet[4,4] COLOR CLR_BLACK PIXEL OF oPanel
	
	   // "Deseja Incluir Recursos Adicionais ?"
		@ aVetTxt[3,1],aVetTxt[3,2] Say "Deseja Incluir Recursos Adicionais ?" Size aVetTxt[3,3],aVetTxt[3,4] COLOR aVetTxt[3,5] FONT aVetTxt[3,6] PIXEL OF oPanel
		@ aVetBtn[1,1],aVetBtn[1,2] Button "Incluir"+Chr(10)+"Recursos" Size aVetBtn[1,3],aVetBtn[1,4] ACTION if(lAtiva,(cMemo1 := QN120Resp2(.F., cMemo1, if(Empty(cResour2),cResour,cResour2)), _oDlg:refresh()),_oDlg:refresh()) OF oPanel PIXEL
		@ aVetGet[5,1],aVetGet[5,2] GET oMemo1 Var cMemo1 MEMO Size aVetGet[5,3],aVetGet[5,4] PIXEL OF oPanel
		oMemo1:Disable()

		// "Hora default para executar a tarefa:"
		@ aVetTxt[4,1],aVetTxt[4,2] Say cTituloCP3 Size aVetTxt[4,3],aVetTxt[4,4] COLOR aVetTxt[4,5] FONT aVetTxt[4,6] PIXEL OF oPanel 
		@ aVetGet[6,1],aVetGet[6,2] MsGet oHRec Var cHora WHEN .F. Size aVetGet[6,3],aVetGet[6,4] COLOR CLR_BLACK PIXEL OF oPanel HASBUTTON
		oHRec:Disable()
		    
		// "Deseja alterar esta hora ?"
		@ aVetTxt[5,1],aVetTxt[5,2] Say cTituloCP4 Size aVetTxt[5,3],aVetTxt[5,4] COLOR aVetTxt[5,5] FONT aVetTxt[5,6] PIXEL OF oPanel  
		@ aVetGet[7,1],aVetGet[7,2] MsGet oHRec1 Var cHoraSel PICTURE "9999:99" ;
					VALID QA_VLHR(cHoraSel,,.F.) .And. ;
							QNRecAloc(IIF(!Empty(cResour2),cResour2,cResour),IIF(!Empty(cHoraSel),cHoraSel,cHora),@aAlocs,dDtIniSel,@cHrIni,@dDtIni,nHorasPSeq) ;
					SIZE aVetGet[7,3],aVetGet[7,4] COLOR CLR_BLACK PIXEL OF oPanel
	
		// "Data de inicio sugerida pela alocacao : "
		dDtIni:= aAlocs[2]
		cHrIni:= aAlocs[3]
		@ aVetTxt[6,1],aVetTxt[6,2] Say cTituloCP5 Size aVetTxt[6,3],aVetTxt[6,4] COLOR aVetTxt[6,5] FONT aVetTxt[6,6] PIXEL OF _oDlg  
		@ aVetGet[8,1],aVetGet[8,2] MsGet oDtRec Var dDtIni When .F. Size aVetGet[8,3],aVetGet[8,4] COLOR CLR_BLACK PIXEL OF _oDlg HASBUTTON
		@ aVetGet[9,1],aVetGet[9,2] MsGet oHrIni Var cHrIni When .F. Size aVetGet[9,3],aVetGet[9,4] COLOR CLR_BLACK PIXEL OF _oDlg HASBUTTON
		oDtRec:Disable() 
		oHrIni:Disable()

		//Data de inicio Informada
		@ aVetTxt[7,1],aVetTxt[7,2] Say cTituloCP6 Size aVetTxt[7,3],aVetTxt[7,4] COLOR aVetTxt[7,5] FONT aVetTxt[7,6] PIXEL OF _oDlg  // "Alterar data de inicio para :"
		@ aVetGet[10,1],aVetGet[10,2] MsGet oDTRec Var dDtIniSel Picture "@!" ;
						VALID QNRecAloc(IIF(!Empty(cResour2),cResour2,cResour),IIF(!Empty(cHoraSel),cHoraSel,cHora),@aAlocs,dDtIniSel,@cHrIni,@dDtIni,nHorasPSeq) ;
						SIZE aVetGet[10,3],aVetGet[10,4] COLOR CLR_BLACK PIXEL OF _oDlg HASBUTTON
//		@ aVetGet[11,1],aVetGet[11,2] MsGet oEdit10 Var cEdit10 Size aVetGet[11,3],aVetGet[11,4] COLOR CLR_BLACK PIXEL OF _oDlg

		If lQNALOCSEM
			lQnAlocSem := Execblock("QNALOCSEM", .F., .F.,{nOpca,cResour,cResour2,cPlano,cRev,cEtapa,cHoraSel,cHora,@aAlocs,dDtIniSel,cHrIni,dDtIni,nHorasPSeq})
		Endif

		// "Confirma as Alteracoes ?"
		@ aVetTxt[8,1],aVetTxt[8,2] Say STR0207 Size aVetTxt[8,3],aVetTxt[8,4] COLOR aVetTxt[8,5] FONT aVetTxt[8,6] PIXEL OF _oDlg 
	
		// Projeto TDI - TDZ167 - Botao cancelar na semi-automatica
		if lPMSBTCN
			@ aVetTxt[9,1],aVetTxt[9,2] Say "(clique em seguir sugestão do sistema para ignorar as alterações)" Size aVetTxt[9,3],aVetTxt[9,4] COLOR aVetTxt[9,5] FONT aVetTxt[9,6] PIXEL OF _oDlg
		Endif
	
		@ aVetBtn[2,1],aVetBtn[2,2] Button "Confirmar" Size aVetBtn[2,3],aVetBtn[2,4] ACTION (nOpca := 1 , Iif(lQnALocSem,_oDlg:End(),)) PIXEL OF _oDlg
	
		// Projeto TDI - TDZ167 - Botao cancelar na semi-automatica
		if lPMSBTCN
			@ aVetBtn[3,1],aVetBtn[3,2] Button "Seguir Sugestao"+Chr(10)+"do Sistema" Size aVetBtn[3,3],aVetBtn[3,4] ACTION (nOpca := 2 , _oDlg:End()) PIXEL OF _oDlg
		Endif
	
//	If lTmk503Auto
		If lAuto
		nOpca := 1
		Else
		ACTIVATE MSDIALOG _oDlg CENTERED // Ativa MsDialog somente se nao for rotina automatica
		Endif
	
		if nOpca == 0
		Loop
		Endif
		
		If nOpca == 1
			If Len(aAlocs) > 0
		   aAlocs:= {IIF (!Empty(cResour2),cResour2,cResour),aAlocs[2],aAlocs[3],aAlocs[4],aAlocs[5]}
				If !Empty(cHoraSel)
		       cHora:= cHoraSel
				EndIf
			EndIf
			if ! Empty(cMemo1)
  	   	aRecAdic := StrTokarr(AllTrim(cMemo1),";")
			Endif
		Elseif nOpca == 2  // mantem o default
   	aRecAdic := StrTokarr(AllTrim(QUP->QUP_RESP2),";")
		cResour2    := PADR("",15)	
	   aAlocs:= {IIF (!Empty(cResour2),cResour2,cResour),aAlocs[2],aAlocs[3],aAlocs[4],aAlocs[5]}
		Endif
	Exit
	Enddo

RestArea(aAreaSX3)
RestArea(aAreaOri)

Return(aAlocs)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QncVldResp2ºAutor  ³Aldo Barbosa dos Santos    ³  15/07/12  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Nova tela de alocacao semi-automatica                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function QncVldResp2(cRec1, cRec2, cMemo1, aRecAdic)
// apaga os recursos adicionais se o usuario mudar o recurso principal
	if ! Empty(cRec2)
	cMemo1 	:= Space(Len(cMemo1))
	aRecAdic := {}
	Endif

Return( .T. )

// ------------------------------------------------
/*/{Protheus.doc} QadQI2ChkFil
Retorna verdadeiro caso o uso da tabela seja compartilhado
será utilizado como retorno do terceiro parâmetro da função
QA_ChkFil, do fonte QAXFUN
@author José Eulálio
@since 19/12/2016
@version 1.0
@param 
/*/
// ------------------------------------------------
Function QadQI2ChkFil(cTabela)
	Local lRet	:= .T.
	Default cTabela	:= "QAD"
Return lRet := FwModeAccess(cTabela) == "C"

// ------------------------------------------------
/*/{Protheus.doc} QadQI2InFOri
Inicializador padrão do campo QI2_FILORI
@author José Eulálio
@since 19/12/2016
@version 1.0
@param 
/*/
// ------------------------------------------------
Function QadQI2InFOri()
	Local aUsrMat  := QNCUSUARIO()
	Local cMatFil  := aUsrMat[2]
	Local cRet	   := IIF(FwModeAccess('QAD') == 'C',xFilial('QAD'),cMatFil)
Return cRet

// ------------------------------------------------
/*/{Protheus.doc} QadQI2InFDep
Inicializador padrão do campo QI2_FILDEP
@author José Eulálio
@since 19/12/2016
@version 1.0
@param 
/*/
// ------------------------------------------------
Function QadQI2InFDep()
	Local cRet	:= IIF(FwModeAccess('QAD') == 'C',xFilial('QAD'),cFilAnt)
Return cRet

/*/{Protheus.doc} GETQNCSXT
Cria tabela no banco para controle de numeração do QNC
@author QUALITY
@since 
@version 1.0
@param 
/*/
// ------------------------------------------------

Function GETQNCSXT(cEmpJob,cFilJob)


// Seta job para nao consumir licensas
	RpcSetType(3)

// Seta job para empresa filial desejadas
	RPCSetEnv(cEmpJob,cFilJob,,,'QNC')

	If !(MsFile("QNSXE",Nil,"TOPCONN")).Or. !!(MsFile("QNSXF",Nil,"TOPCONN"))
		nHdl := MSFCREATE("SOQNSXE")
		While nHdl < 0
			nHdl := MSFCREATE("SOQNSXE")
			Inkey(5)
			nTrys++
			If nTrys > 20
				Final("Probs.Criacao SOQNSXE")
			EndIf
		Enddo
		If !(MsFile("QNSXE",Nil,"TOPCONN"))
			aCampos := {}
			AADD(aCampos,{"QE_FILIAL","C",50,0})
			AADD(aCampos,{"QE_ALIAS","C",3,0})
			AADD(aCampos,{"QE_CHAVE","C",10,0})
			AADD(aCampos,{"QE_TAMANHO","N",2,0})
			AADD(aCampos,{"QE_NUMERO","C",20,0})
			FWDBCreate("QNSXE",aCampos,"TOPCONN", .T. )
		EndIf

		If !(MsFile("QNSXF",Nil,"TOPCONN"))
			aCampos := {}
			AADD(aCampos,{"QF_FILIAL","C",50,0})
			AADD(aCampos,{"QF_ALIAS","C",3,0})
			AADD(aCampos,{"QF_CHAVE","C",10,0})
			AADD(aCampos,{"QF_TAMANHO","N",2,0})
			AADD(aCampos,{"QF_NUMERO","C",20,0})
			FWDBCreate("QNSXF",aCampos,"TOPCONN", .T. )
		EndIf

		FClose(nHdl)
		Ferase("SOQNSXE")
		DbCommitAll()
	EndIf
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNCDELSEQ ³ Autor ³ Gustavo Della Giustina³ Data ³ 10/04/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ajusta a proxima sequencia livre quando o registro for     ³±± 
±±³          ³ excluido.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNCDELSEQ(cAlias, cCampo, cAliasSX8, cChave)               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQNC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNCDELSEQ(cAlias, cCampo, cAliasSX8, cChave)
Local nSize   := TamSX3(cCampo)[1]
Local cNumero := Substr(cChave, 1, nSize - 4) //Remove o ano da chave
Local cAno    := PadR(Substr(cChave, nSize - 3, 4), 10) //Remove o sequencia da chave

	If MsFile("QNSXE",Nil,"TOPCONN") .And. SuperGetMV("MV_QNCVSEQ",.F., "S") == "S"
		If Empty(cAliasSX8)
		cAliasSX8 := PadR(xFilial(cAlias)+x2path(cAlias),50)
		EndIf
	
		If Select("QNSXE") <= 0
		USE QNSXE ALIAS QNSXE SHARED NEW VIA "TOPCONN"
			If NetERR()
			Final("Probs.Abertura QNSXE")
			EndIf
		Endif
	
	DbSelectArea("QNSXE")
	DbGoTop()
		While !Eof()
			If QE_FILIAL+QE_ALIAS+QE_CHAVE == cAliasSX8+cAlias+cAno
				If Val(QNSXE->(QE_NUMERO)) > Val(cNumero)
				Reclock("QNSXE",.F.)
				Replace QE_NUMERO  with PadR(cNumero,20)
				QNSXE->(MsUnLock())
				EndIf
			Exit
			EndIf
		DbSkip()
		Enddo
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} QncAnexMVC()
Retorna o nome do responsavel do anexo para MVC
@author Luiz Henrique Bourscheid
@since 04/02/2019
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Function QncAnexMVC(cAlias)
	Local cNome   := ""
	Local cFilMat := ""
	Local cMat    := ""

	cFilMat := If(cAlias == "QIE", "QIE->QIE_FILMAT", "QIF->QIF_FILMAT")
	cMat    := If(cAlias == "QIE", "QIE->QIE_MAT"   , "QIF->QIF_MAT"   )

	If !Empty(&cMat)
		cNome:= QA_NUSR(&cFilMat, &cMat,.T.)
	EndIF

Return cNome

//-------------------------------------------------------------------
/*/{Protheus.doc} VldChkMat()
Verifica se o funcionario existe e nao é demitido para MVC.
@author Luiz Henrique Bourscheid
@since 04/02/2019
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Function VldChkMat(cAlias, cModel, cFieldFil, cFieldMat)
	Local lRet 		 := .T.
	Local oModel 	 := FWModelActive()
	Local oModlAlias := oModel:GetModel(cModel)

	lRet := QA_CHKMAT(oModlAlias:GetValue(cFieldFil), oModlAlias:GetValue(cFieldMat))

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} QAChkDepto()
Valida o Departamento para MVC.
@author Luiz Henrique Bourscheid
@since 04/02/2019
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Function QAChkDepto(cAlias, cModel, cFieldFil, cFieldDepto)
	Local lRet 		 := .T.
	Local oModel 	 := FWModelActive()
	Local oModlAlias := oModel:GetModel(cModel)

	QAD->(DbSetOrder(1))
	If !QAD->(dbSeek(oModlAlias:GetValue(cFieldFil)+oModlAlias:GetValue(cFieldDepto)))
		Help(" ",1,"QNCNEXICC")
		lRet := .F.
	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} QAChkFil()
Valida a filial para MVC.
@author Luiz Henrique Bourscheid
@since 04/02/2019
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Function QAChkFil(cField, cModel)
	Local lRet 		 := .T.
	Local oModel 	 := FWModelActive()
	Local oModlAlias := oModel:GetModel(cModel)

	lRet := FWFilExist(FWGrpCompany(), oModlAlias:GetValue(cField))

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} QNCAltAnex()
Verifica se Usuario pode alterar/deletar Doctos Anexos para MVC.
@author Luiz Henrique Bourscheid
@since 05/02/2019
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Function QNCAltAnex(cAlias, cModel)
	Local lRet       := .T.
	Local oModel 	 := FWModelActive()
	Local oModelQIX  := oModel:GetModel(cModel)
	Local oModelAnex := oModel:GetModel(cAlias+"DETAIL")
	Local aUsrMat  	 := QNCUSUARIO()
	Local cMatFil  	 := aUsrMat[2]
	Local cMatCod    := aUsrMat[3]

	If cAlias == "QIE" .And. cMatFil+cMatCod <> oModelQIX:GetValue("QI3_FILMAT")+oModelQIX:GetValue("QI3_MAT")
		If cMatFil+cMatCod <> oModelAnex:GetValue("QIE_FILMAT")+oModelAnex:GetValue("QIE_MAT")
			lRet:= .F.
		EndIf

	ElseIf cAlias == "QIF" .And. cMatFil+cMatCod <> oModelQIX:GetValue("QI2_FILRES")+oModelQIX:GetValue("QI2_MATRES")
		If cMatFil+cMatCod <> oModelAnex:GetValue("QIF_FILMAT")+oModelAnex:GetValue("QIF_MAT")
			lRet:= .F.
		Endif
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} QNCInEtapa()
Realiza a inicialização padrão dos campos QIE_ETAPA e QIF_ETAPA para MVC.
@author Luiz Henrique Bourscheid
@since 05/02/2019
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Function QncInEtapa(cAlias, cModel)
	Local oModel    := FWModelActive()
	Local oModelQIX := oModel:GetModel(cModel)
	Local cRet      := ""

	If cAlias == "QIE"
		cRet := oModelQIX:GetValue("QI3_STATUS")
	ElseIf cAlias == "QIF"
		cRet := oModelQIX:GetValue("QI2_STATUS")
	EndIF

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} QncInitAno()
Realiza a inicializaçãoo padrão dos campos QI2_ANO e QI3_ANO para MVC.
@author Luiz Henrique Bourscheid
@since 05/02/2019
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Function QncInitAno(cAlias, cModel)
	Local oModel    := FWModelActive()
	Local oModelQIX := oModel:GetModel(cModel)
	Local cRet   	:= ""

	If cAlias == "QI2"
		cRet := SubStr(oModelQIX:GetValue("QI2_FNC"),TamSX3("QI2_FNC")[1]-3,4)
	ElseIf cAlias == "QI3"
		cRet := SubStr(oModelQIX:GetValue("QI3_CODIGO"),TamSX3("QI3_CODIGO")[1]-3,4)
	EndIF

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} QncAnexoMv()
Inclui / Visualiza Documento Anexo para MVC.
@author Luiz Henrique Bourscheid
@since 05/02/2019
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Function QncAnexoMv(cAlias, cModel, cModelAnex)
	Local cArqAnexo  := ""
	Local lRet     	 :=.F.
	local nloop	 	 := 0
	Local nSeq		 := 0
	Local cArqAne  	 := ""
	Local oModel     := FWModelActive()
	Local oModelQIX  := oModel:GetModel(cModel)
	Local oModelAnex := oModel:GetModel(cModelAnex)
	Local lexist 	 := .F.
	Local cWhereA 	 := ""
	Local cSelect 	 := ""
	Local lTMKPMS	 := If(GetMv("MV_QTMKPMS",.F.,1) == 1,.F.,.T.)

	If oModel:GetOperation() <> 2
		For nLoop := 1 to 99
			nSeq := nLoop -1

			If cAlias == "QIE"
				cArqAne  := oModelQIX:GetValue("QI3_CODIGO") + "P" + oModelQIX:GetValue("QI3_REV") + "P" + strzero(val(oModelAnex:GetValue("QIE_SEQ"))+nSeq,2)
				cArqAnexo:= cArqAne + ".pla"
				cWhereA := SubStr(cArqAne,2)+"%"
				cSelect := "QIE_FILIAL, QIE_CODIGO, QIE_REV, QIE_SEQ,QIE_ANEXO, QIE_PEND FROM " + RetSqlName("QIE") + " WHERE  D_E_L_E_T_<>'*' AND QIE_ANEXO LIKE '"+cWhereA+"' "
			ElseIf cAlias == "QIF"
				cArqAne  := oModelQIX:GetValue("QI2_FNC") + "F" + oModelQIX:GetValue("QI2_REV") + "F" + SubStr(oModelAnex:GetValue("QIF_SEQ"),+nSeq,2)
				cArqAnexo:= cArqAne  + ".fnc"
				cWhereA := SubStr(cArqAne,2)+"%"
				cSelect := "QIF_FILIAL, QIF_FNC, QIF_REV, QIF_SEQ,QIF_ANEXO FROM " + RetSqlName("QIF") + " QIF WHERE D_E_L_E_T_<>'*'AND QIF_ANEXO LIKE '"+cWhereA+"' "
			EndIf

			cQuery :=" SELECT "+cSelect

			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"cAnaCod",.T.,.T.)

			cAnaCod->(DbGoTop())
			lExist := .F.
			WHILE cAnaCod->(!Eof())
				lExist:= .T.
				Exit
			EndDo
			cAnaCod->(DbCloseArea())

			If !oModelAnex:SeekLine({{cAlias+"_ANEXO", cArqAne}}) .And. !lExist
				Exit
			EndIf
		Next nLoop

		If lTMKPMS
			cArqAnexo:= SubStr(cArqAnexo,6,Len(cArqAnexo)-5)
		Else
			cArqAnexo:= SubStr(cArqAnexo,2,Len(cArqAnexo))
		Endif
	EndIf


	cFileTrm := oModelAnex:GetValue(cAlias+"_ANEXO")

	// Ponto de Entrada para nao utilizar o tratamento padrao de pesquisa pelo parametro MV_QNCPDOC solicitado pelo TDI
	If Existblock("QNCDOCANX")
		lRet := Execblock("QNCDOCANX", .F. , .F. , {oModel:GetOperation(),@cFileTrm,cArqAnexo} )
	Else
		lRet := FQNCDRIVE(oModel:GetOperation(), @cFileTrm, cArqAnexo)
	Endif

	If oModel:GetOperation() <> MODEL_OPERATION_VIEW
		oModelAnex:SetValue(cAlias+"_ANEXO", cFileTrm)
	EndIF

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} GETNEXTNUM()
Método é chamada para gerar o próximo número sequêncial do campo
QI2_FNC
@author thiago.rover
@since 29/04/2021
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Function GETNEXTNUM(cChave)

Local cQuery  := ""
Local cCodSeq := ""

If IsInCallStack("QNCA340")
	cQuery := " SELECT TOP 1 * FROM " + RetSqlName("QI2")+" QI2 " 
	cQuery += " WHERE QI2_ANO = '"+cChave+"'"
	cQuery += " AND D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY R_E_C_N_O_ DESC "
	cQuery := ChangeQuery(cQuery)
					
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QNCATRB",.T.,.T.)

	If QNCATRB->(!Eof())
		cCodSeq := Left(QNCATRB->QI2_FNC,Len(QNCATRB->QI2_FNC)-Len(cChave))
	Endif

ElseIf IsInCallStack("QNCA330")

	cQuery := " SELECT TOP 1 * FROM " + RetSqlName("QI3")+" QI3 " 
	cQuery += " WHERE QI3_ANO = '"+cChave+"'"
	cQuery += " AND D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY R_E_C_N_O_ DESC "
	cQuery := ChangeQuery(cQuery)
					
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QNCATRB",.T.,.T.)

	If QNCATRB->(!Eof())
		cCodSeq := Left(QNCATRB->QI3_CODIGO,Len(QNCATRB->QI3_CODIGO)-Len(cChave))
	Endif
Endif

QNCATRB->(DbCLOSEAREA())

Return SOMA1(cCodSeq)+cChave
