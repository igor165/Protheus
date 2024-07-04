#include "pmsa050.ch"
#include "protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} PMSA050

Rotina de atualizacao do cadastro de Recursos

@param nulo,,
@return nulo,

@author Edson Maricate
@since 25.05.2001
@version 1.0
/*/
//-------------------------------------------------------------------
Function PMSA050()
Local aAreaSX3	:= {}
Local aButtons	:= {}
Local bPMA050Grv	:= {|| PMA050Grv()}

If AMIIn(44) .And. !PMSBLKINT()
	If ExistBlock( "PA050BTN" )
		aButtons := ExecBlock( "PA050BTN" )
	EndIf

	//AxCadastro(cAlias,cTitle,cDel,cOk,aRotAdic,bPre,bOK,bTTS,bNoTTS,aAuto,nOpcAuto,aButtons,aACS,cTela)
	AxCadastro("AE8",STR0001,"Pms105VlDe()","PmsA050Ok()",,,,bPMA050Grv,,,, aButtons ) //"Recursos de Projetos"
EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PmsA050Ok

Valida a manutencao do cadastro de recurso

@param nulo,
@return logico, Verdadeiro se a validação dos campos ocorrem com sucesso

@author Cristiano Denardi
@since 25.05.2001
@version 1.0
/*/
//-------------------------------------------------------------------
Function PmsA050Ok()
Local aArea    := GetArea()
Local aAreaSF5 := {}
Local lOK      := .T.
Local cCodFun  := ""

Do Case
	// Tipo de apuracao = Custo medio/FIFO
	Case M->AE8_TPREAL == "1"
		If ExistCPO("SB1" ,M->AE8_PRDREA ,,,.F.)
			aAreaSF5 := SF5->(GetArea())
			dbSelectArea("SF5")
			dbSetOrder(1)
			If MsSeek(xFilial("SF5")+M->AE8_TMPAD) .AND. !(SF5->F5_VAL == "N")
				Aviso(STR0006 ,STR0008 ,{"OK"}) // "Gest? de Projetos" ## "Para utilizar o Tipo de Apuração 'Custo M?io/FIFO', o Tipo de Movimentação deve ser n? valorizado."
				lOk := .F.
			EndIf
			RestArea(aAreaSF5)

		EndIf
		If lOK .and. !ExistCPO("SB1" ,M->AE8_PRDREA ,,,.F.)
			Aviso(STR0006 ,STR0009 ,{"OK"}) // "Gestão de Projetos" ## "Para utilizar o Tipo de Apuração 'Custo Médio/FIFO', deve ser informado um produto."
			lOk := .F.
		EndIf
	// Tipo de apuracao = Folha de pagamento
	Case M->AE8_TPREAL == "3"
		If Empty(M->AE8_CODFUN) .AND. !PMSPesqSRA()
			Aviso(STR0006 ,STR0011 ,{"OK"}) // "Gest? de Projetos" ## "Para utilizar este Recurso com o Tipo de Apuração 'Folha de Pagamento', ?necess?io ter informado uma matricula do funcionario no cadastro do Recurso."
			lOk := .F.
		EndIf
EndCase

If lOk
    // Se o codigo do participante estiver preenchido
	If !Empty(M->AE8_CODRD0)
		//
	   // Verificar se o codigo do funcionario esta preenchido
	   //
	   If Empty(M->AE8_CODFUN)
			// carrega o codigo do funcionario atraves da RDZ.
	    	// verificar na tabela RDZ esta relacionado
	    	cCodFun := RDZRetEnt( "RD0", xFilial("AE8")+M->AE8_CODRD0, "SRA", , , , .F. )
	    	If !Empty(cCodFun)
				M->AE8_CODFUN := cCodFun
			EndIf
	  	Else
	    	// verificar na tabela RDZ esta relacionado
	    	cCodFun := RDZRetEnt( "RD0", xFilial("AE8")+M->AE8_CODRD0, "SRA", , , , .F. )

	    	If Empty(cCodFun)
				lOK := Aviso(STR0006 ,STR0012 ,{STR0014,STR0015}, 3) == 1 //"O codigo do participante não está relacionado a um funcionario informado. Deseja relacionar?" ## "SIM" ## "Não"

			ElseIf AllTrim(cCodFun) <> AllTrim(M->AE8_CODFUN)
				Aviso(STR0006 ,STR0013 ,{"OK"}) //"O código do funcionario informado não o mesmo associado ao codigo do participante informado. Verifique."
				lOk := .F.
	    	EndIf
	   EndIf
	EndIf
EndIf

If lOk .and. ExistBlock("PMA50VLD")
	lOk := ExecBlock("PMA50VLD",.F.,.F.,{INCLUI,ALTERA,.F.}) // INCLUSAO, ALTERACAO, EXCLUSAO
EndIf

RestArea(aArea)
Return( lOk )


//-------------------------------------------------------------------
/*/{Protheus.doc} Pms105VlDe

Verifica se recurso esta alocado em composição, orcamento, projeto ou 
houve apotnamentos de horas.
Se tiver, nao deixa deletar. Valida a manutencao do cadastro de recurso

@param nulo,
@return logico, Verdadeiro se o recurso esta sem alocacao.

@author Cristiano Denardi
@since 25.05.2001
@version 1.0
/*/
//-------------------------------------------------------------------
Function Pms105VlDe()
Local aArea		:= GetArea()
Local aAreaTMP	:= {}
Local cMsg  		:= ""
Local lRet			:= .T.
Local nMV_QTMKPMS	:= GetMv("MV_QTMKPMS")  

dbSelectArea("AFA")
aAreaTMP := AFA->(GetArea())
dbSetOrder(3) // AFA_FILIAL + AFA_RECURS + DTOS(AFA_START) + AFA_HORAI
If lRet .AND. MsSeek( xFilial("AFA") + AE8->AE8_RECURS )
	lRet := .F.

	cMsg := "(" + Alltrim(AE8->AE8_RECURS) + ") - " + FATPDObfuscate(Alltrim(AE8->AE8_DESCRI),"AE8_DESCRI",,.T.)
	cMsg += CRLF
	cMsg += STR0002 // "Este recurso já está alocado em pelo menos 1 projeto, não pode ser excluído !"
	MsgAlert( cMsg )
Endif
restArea(aAreaTMP)

SIX->(DbSetOrder(1))
If lRet .And. SIX->(DbSeek('AF34'))
	dbSelectArea("AF3")
	aAreaTMP := AF3->(GetArea())
	dbSetOrder(4) // AFA_FILIAL + AFA_RECURS + DTOS(AFA_START) + AFA_HORAI
	If MsSeek( xFilial("AF3") + AE8->AE8_RECURS )
		lRet := .F.

		cMsg := "(" + Alltrim(AE8->AE8_RECURS) + ") - " + FATPDObfuscate(Alltrim(AE8->AE8_DESCRI),"AE8_DESCRI",,.T.)  
		cMsg += CRLF
		cMsg += STR0003 // "Este recurso já está alocado em pelo menos 1 orcamento, não pode ser excluído !"
		MsgAlert( cMsg )
	Endif
	restArea(aAreaTMP)
Endif
If lRet .And. SIX->(DbSeek('AE22'))
	dbSelectArea("AE2")
	aAreaTMP := AE2->(GetArea())
	dbSetOrder(2) // AFA_FILIAL + AFA_RECURS + DTOS(AFA_START) + AFA_HORAI
	If MsSeek( xFilial("AE2") + AE8->AE8_RECURS )
		lRet := .F.

		cMsg := "(" + Alltrim(AE8->AE8_RECURS) + ") - " + FATPDObfuscate(Alltrim(AE8->AE8_DESCRI),"AE8_DESCRI",,.T.)
		cMsg += CRLF
		cMsg += STR0005 // "Este recurso já está alocado em pelo menos uma composicao orcamento, não pode ser excluído !"
		MsgAlert( cMsg )
	Endif
	restArea(aAreaTMP)
Endif
If lRet
	dbSelectArea("AFU")
	aAreaTMP := AFU->(GetArea())
	dbSetOrder(3)
	If MsSeek( xFilial("AFU") + "1"+ AE8->AE8_RECURS  ).OR.MsSeek( xFilial("AFU") + "2"+ AE8->AE8_RECURS  )
		lRet := .F.

		cMsg := "(" + Alltrim(AE8->AE8_RECURS) + ") - " + FATPDObfuscate(Alltrim(AE8->AE8_DESCRI),"AE8_DESCRI",,.T.)
		cMsg += CRLF
		cMsg += STR0004 // "Este recurso já tem apontamento em pelo menos uma tarefa, nao pode ser excluído !"
		MsgAlert( cMsg )
	Endif
	restArea(aAreaTMP)
Endif

If lRet .And. (nMV_QTMKPMS == 3 .Or.nMV_QTMKPMS == 4) //Integracao entre PMSxTMKxQNC
	lRet := QN070VldDel(AE8->AE8_CODRD0)
EndIf

If lRet .and. ExistBlock("PMA50VLD")
	lRet := ExecBlock("PMA50VLD",.F.,.F.,{.F.,.F.,.T.})  // INCLUSAO, ALTERACAO, EXCLUSAO
EndIf

RestArea( aArea )
Return( lRet )


//-------------------------------------------------------------------
/*/{Protheus.doc} PMRD0WHEN

Funcao para validar X3_WHEN ou outro campo

@param nulo,
@return logico, verdadeiro se o campo pode sofrer edicao

@author Clovis Magenta
@since 25/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function PMRD0WHEN()

Local nQTMKPMS	:= GetMv("MV_QTMKPMS")
Local lX3OK 		:= .T.

If ALTERA
	If ((nQTMKPMS == 3) .or. (nQTMKPMS == 4)) // verifica integração PMS com TMK ou QNC
		lX3OK := .F.
	EndIf
EndIf

Return lX3OK


//-------------------------------------------------------------------
/*/{Protheus.doc} PMSDELREC

Função que valida exclusao de um recurso, caso sistema utilize o parametro SSIM
habilitado para integra?o PMS x TMK x QNC.
Caso o recurso associados ao participante esteja empenhado em algum projeto,
restringe a delecao.
Atualmente utilizada nas funcões:
	Tk090Deleta do fonte TMKA090.PRX
	QNC070Dele do fonte QNCA070.PRW

@param nulo,
@return logico, verdadeiro o recurso informado n? tem menhuma associacao aos projetos

@author Pedro Pereira Lima
@since 01/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function PMSDelRec(cCodPar)

Local aArea 		:= GetArea()
Local aAreaAE8 	:= AE8->(GetArea())
Local aRecurso 	:= {}
#IFDEF TOP
Local cAliasX    	:= GetNextAlias()
#ELSE
Local cFiltroAE8 	:= ""
#ENDIF
Local lPermite 	:= .T.
Local nX 			:= 0

DEFAULT cCodPar 	:= "" //Codigo do PARTICIPANTE

#IFDEF TOP
	BeginSQL ALIAS cAliasX
		SELECT AE8_RECURS As RECURSO FROM %Table:AE8% As AE8
			WHERE AE8_FILIAL = %EXP:xFilial("AE8")%
			AND AE8_CODRD0 = %EXP:cCodPar%
			AND AE8.%NotDel%
	EndSQL

	While !(cAliasX)->(Eof())
		aAdd(aRecurso,(cAliasX)->RECURSO)
		(cAliasX)->(dbSkip())
	EndDo

#ELSE
   cFiltroAE8 := "AE8_CODRD0 = '" + cCodPar + "'"

	dbSelectArea("AE8")
	dbSetFilter({||&cFiltroAE8},cFiltroAE8)
	dbGoTop()

	While !Eof()
		If AE8->AE8_CODRD0 == cCodPar
			aAdd(aRecurso,AE8->AE8_RECURS)
		EndIf
		dbSkip()
	EndDo
#ENDIF

If Len(aRecurso) > 0
	dbSelectArea("AE8")
	dbSetOrder(1)//AE8_FILIAL+AE8_RECURS+AE8_DESCRI
	For nX := 1 To Len(aRecurso)
		If dbSeek(xFilial("AE8")+aRecurso[nX])
			// verifica se o recurso esta alocado em alguma composicao, orcamento, projeto ou apontamentos de horas.
			lPermite := Pms105VlDe()
			If !lPermite
				Exit
			EndIf
		EndIf
	Next nX
EndIf

RestArea(aAreaAE8)
RestArea(aArea)
Return lPermite


//-------------------------------------------------------------------
/*/{Protheus.doc} PMA050Grv

Efetua a gravacao dos dados do recurso na tabela RDZ apos a validacao do AxCadastro.

@param nulo,
@return logico, sempre verdadeiro

@author Pedro Pereira Lima
@since 26/06/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function PMA050Grv()
Local cRetProc	:= "0" //Inicializo a vari?el com algum valor para que possa efetuar a busca na pilha corretamente
Local lDeleta		:= .F.
Local nX			:= 0

While cRetProc <> "AXDELETA" .And. !Empty(cRetProc)
	cRetProc := ProcName(nX)
	nX++
EndDo

If cRetProc == "AXDELETA"
	lDeleta := .T.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ??
//?uando a funcao e executada atraves de codeblock, e feito um registro na tabela RDZ ?
//?om as informacoes da tabela AE8. Em seguida, se o M->AE8_CODFUN estiver preenchido,?
//?era incluido na tabela RDZ um registro relacionado com a tabela SRA                ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ??
If !lDeleta
	// associa o codigo do recurso a um codigo de pessoa/participante
	fUpdateEnt( M->AE8_CODRD0 ,"AE8" ,xfilial("AE8")+M->AE8_RECURS ,1 ,/*cEmpAnt*/,cFilAnt)

	If !Empty(M->AE8_CODFUN)
		// associa o codigo do funcionario a um codigo de pessoa/participante
		fUpdateEnt( M->AE8_CODRD0 ,"SRA" ,xfilial("SRA")+M->AE8_CODFUN ,1 ,/*cEmpAnt*/,cFilAnt)
	EndIf
EndIf

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} UsrPesName

Funcao para retornar o nome relacionado ao c?igo do usu?io, para o campo AE8_NOME

@param nulo,
@return logico, sempre verdadeiro

@author Ramon Teodoro
@since 03/10/12
@version 1.0
/*/
//-------------------------------------------------------------------
Function UsrPesName()

M->AE8_NOME := UsrRetName(M->AE8_USER)

Return .t.

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDObfuscate
    @description
    Realiza ofuscamento de uma variavel ou de um campo protegido.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @sample FATPDObfuscate("999999999","U5_CEL")
    @author Squad CRM & Faturamento
    @since 04/12/2019
    @version P12
    @param xValue, (caracter,numerico,data), Valor que sera ofuscado.
    @param cField, caracter , Campo que sera verificado.
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado

    @return xValue, retorna o valor ofuscado.
/*/
//-----------------------------------------------------------------------------
Static Function FATPDObfuscate(xValue, cField, cSource, lLoad)
    
    If FATPDActive()
		xValue := FTPDObfuscate(xValue, cField, cSource, lLoad)
    EndIf

Return xValue   



//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Função que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive  

