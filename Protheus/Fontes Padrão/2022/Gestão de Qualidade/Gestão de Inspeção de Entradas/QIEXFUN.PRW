#include "PROTHEUS.CH"
#include "QIEXFUN.CH"

#define  Confirma 1
#define  Redigita 2
#define  Abandona 3

/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ QIEXFUN  ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 18/02/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ STR		 ³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³			ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data	³ BOPS ³  Motivo da Alteracao 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Paulo Emidio³17/07/00³------³ Retirada da funcao QIEXDEER.			  ³±±
±±³Paulo Emidio³17/07/00³------³ Criacao da Funcao qRetApeNom.	          ³±±
±±³Paulo Emidio³20/09/00³------³ Remocao da funcao QE_CHKSIX().		  	  ³±±
±±³Cleber Souza³20/05/03³------³ Alteração na rotina qAtuPlAmEn para que a³±±
±±³            ³        ³------³ mesma identifique notas de Dev./Benef.   ³±±
±±³            ³        ³------³ e geração da tabela QF6 (Prod x Cliente) ³±±
±±³            ³        ³------³ Alteração na rotina qComMovPAE para que a³±±
±±³            ³        ³------³ mesma identifique notas de Dev./Benef.   ³±±
±±³            ³        ³------³ e geração da tabela QF6 (Prod x Cliente) ³±±
±±³Cleber Souza³06/08/03³------³ Criacao da funcao QAtuShelf().		  	  ³±±
±±³Cleber Souza³07/08/03³------³ Criacao da funcao QJustTxt().		  	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QIEXDeFo ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 05/06/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Mostra a Razao Social/Nome Reduzido do Fornecedor          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QIEXDeFo(ExpC1,ExpC2,ExpN1)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Fornecedor                               ³±±
±±³          ³ ExpC2 = Loja do Fornecedor                                 ³±±
±±³          ³ ExpN1 = 1 para Razao Social                                ³±±
±±³          ³         2 para Nome Reduzido                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QIEXDeFo(cFor, cLojFor, nTipo)

Local cNome 

nTipo := Iif(nTipo==NIL,2,nTipo)
SA2->(dbSetOrder(1))

If cLojFor <> NIL
	SA2->(dbseek(xFilial("SA2")+cFor+cLojFor))
Else
	SA2->(dbseek(xFilial("SA2")+cFor))
EndIf	
cNome := Iif(nTipo==1,SA2->A2_NOME,SA2->A2_NREDUZ)
Return(cNome)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QIEXDePr ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 05/06/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Mostra a Descricao do Produto (ultima revisao) do QE6      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QIEXDePr(ExpC1,ExpN1)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Produto                                  ³±±
±±³          ³ ExpN1 = Tamanho da Descricao                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QIEXDePr(cPro, nTam)

nTam := If(nTam==NIL,Space(TamSX3("QE6_DESCPO")[1]),nTam)

QE6->(dbSetOrder(1))
QE6->(dbseek(xFilial("QE6") + cPro))
Return(QE6->QE6_DESCPO)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QIEXDeEn ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 05/06/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna a Descricao do Ensaio                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QIEXDeEn(ExpC1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Ensaio                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QIEXDeEn(cEns)
Local cRet := Space(TamSX3("QEH_ENSAIO")[1])

QE1->(dbSetOrder(1))
If QE1->(dbseek(xFilial("QE1") + cEns))
	cRet := QE1->QE1_DESCPO
Endif	
Return(cRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QIEXDeGr ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 09/06/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna a Descricao do Grupo de Produtos                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QIEXDeGr(ExpC1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Grupo de Produtos                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QIEXDeGr(cGrupo)
Local cRet := Space(TamSX3("QE3_DESCRI")[1])
                                                 
QE3->(dbSetOrder(1))
If QE3->(dbseek(xFilial("QE3") + cGrupo))
	cRet := QE3->QE3_DESCRI
Endif
Return(cRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ FQIE_USR ³ Autor ³ Marcos Cesar		    ³ Data ³ 28/12/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica Pendencia das Permissoes de Uso e Follow-up NNCs  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FQIE_USR()
Local aPermissao  := {}
Local lItem		  := .F.
Local nCount	  := 0
Local nCount1	  := 0
Local nA		  := 0
Local nOrdQF3	  := QF3->(IndexOrd())
Local nOrdQF2	  := QF2->(IndexOrd())
Local lReDemPU	  := .F.
Local lReDemFN	  := .F.
Local aUsuQie     := QA_Usuario()
Local cMatCod := aUsuQie[3]
Local aArea := GetArea()
Local cMVQELAUSQ := GetMv("MV_QELAUSQ")

RestArea(aArea)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ P.U.:                                                  ³
//³ Seleciona as PUs com status Em aberto. Se o Usuario da ³
//³ Qualidade ou os Destinatarios tiverem sido demitidos,  ³
//³ eles deverao ser substituidos. Isto devera ser feito   ³
//³ na opcao Transferencia de Pendencias, no menu Miscela- ³
//³ nea, por uma pessoa com nivel de acesso devido.        ³
//³ Se existir uma PU aberta que o emissor tiver sido demi-³
//³ tido, nao troca, porque fica como historico da PU.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
QF3->(dbSetOrder(1))

dbSelectArea("QF2")
dbSetOrder(1)
dbSeek(xFilial("QF2"))

While !Eof() .And. QF2_FILIAL == xFilial("QF2")

	If QF2->QF2_STATUS == "E"	// Pu com status Em Aberto
	   	// Verifica se o Usuario da Qualidade esta demitido
		QAA->(dbSetOrder(1))
   		If 	QAA->(dbSeek(QF2->QF2_FILQLD+QF2->QF2_MATQLD)) .And. ;
   			! QA_SitFolh()
   			lReDemPU := .T.	
   			Exit
   		Else
   			// Verifica se os Destinatarios desta PU estao demitidos
  			If QF3->(dbSeek(xFilial("QF3")+QF2->QF2_FORNEC+QF2->QF2_LOJFOR+;
  						QF2->QF2_PRODUT+DtoS(QF2->QF2_DTENTR)+QF2->QF2_LOTE+;
  						QF2->QF2_NUMERO))
  					While QF3->QF3_FILIAL+QF3->QF3_FORNEC+QF3->QF3_LOJFOR+;
  							QF3->QF3_PRODUT+DtoS(QF3->QF3_DTENTR)+QF3->QF3_LOTE+;
  							QF3->QF3_NUMERO == xFilial("QF3")+QF2->QF2_FORNEC+;
  							QF2->QF2_LOJFOR+QF2->QF2_PRODUT+DtoS(QF2->QF2_DTENTR)+;
  							QF2->QF2_LOTE+	QF2->QF2_NUMERO .And. !QF3->(Eof())

					// Se o destinatario nao tiver dado laudo
					If QF3->QF3_STATUS == "E"
						QAA->(dbSetOrder(1))
	   					If 	QAA->(dbSeek(QF3->QF3_FILMAT+QF3->QF3_MAT)) .And. ;
   							! QA_SitFolh()
	   						lReDemPU := .T.	
   							Exit
   						EndIf	
   					EndIf	
   					QF3->(dbSkip())
   				EndDo	
			EndIf
		EndIf	
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existem Pendencias para o Usuario Qual. (laudo) para Baixar ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cMVQELAUSQ == "S" .And.;
			 QF2->QF2_STATUS == "P" .And. !lReDemPU
   	// Verifica se o Usuario da Qualidade esta demitido
		QAA->(dbSetOrder(1))
   		If 	QAA->(dbSeek(QF2->QF2_FILQLD+QF2->QF2_MATQLD)) .And. ;
   			! QA_SitFolh()
   			lReDemPU := .T.	
   			Exit
		EndIf
	EndIf
	
	dbSelectArea("QF2")
	dbSkip()
EndDo
   
If lReDemPU
	MessageDlg(STR0001+STR0006,,2)	//"Ha responsaveis demitidos associados a Equipes de Follow-up." #### "Execute a Transferencia de Pendencias, no menu Atualizacoes (Responsaveis) no ambiente de Inspeção de Entradas."
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Follow-up de NNCs:                                     ³
//³ Verifica o arquivo de associacao de Responsaveis a     ³
//³ Equipes de Follow-up (QE5), e se algum foi demitido,   ³
//³ deve ser substituido.                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
QAA->(dbSetOrder(1))

QE5->(dbSetOrder(1))
QE5->(dbSeek(xFilial("QE5")))
While !QE5->(Eof())
	// Verifica se o Responsavel associado a equipe esta demitido
  	If 	QAA->(dbSeek(QE5->QE5_FILRES+QE5->QE5_RESPON)) .And. ;
  		! QA_SitFolh()
  		lReDemFN := .T.	
  		Exit
  	EndIf
  	QE5->(dbSkip())	
EndDo
   
If lReDemFN
	MessageDlg(STR0005 + STR0006,,2)	// "Ha responsaveis demitidos associados a Equipes de Follow-up."
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existem Pendencias como Destinatario para Baixar ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QF3")
dbSetOrder(4)
dbSeek(cFilAnt + cMatCod)

While !Eof() .And. cFilAnt + cMatCod == QF3->QF3_FILMAT + QF3->QF3_MAT
	If QF3->QF3_PENDEN == "S"
		nCount := nCount + 1

		Aadd(aPermissao, { QF3->QF3_FORNEC, QF3->QF3_LOJFOR, QF3->QF3_PRODUT,;
							Dtos(QF3->QF3_DTENTR), QF3->QF3_LOTE })
	EndIf

	dbSelectArea("QF3")
	dbSkip()
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existem Pendencias como Usuario Qual. (laudo) para Baixar ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If GetMv("MV_QELAUSQ") == "S"
	dbSelectArea("QF2")
	dbSetOrder(4)
	dbSeek(cFilAnt + cMatCod)
	
	While !Eof() .And. cFilAnt + cMatCod == QF2->QF2_FILQLD + QF2->QF2_MATQLD
		If QF2->QF2_STATUS == "P"
			nCount := nCount + 1
	
			Aadd(aPermissao, { QF2->QF2_FORNEC, QF2->QF2_LOJFOR, QF2->QF2_PRODUT,;
								Dtos(QF2->QF2_DTENTR), QF2->QF2_LOTE })
		EndIf
	
		dbSelectArea("QF2")
		dbSkip()
	EndDo
EndIf
		
// Se existir pendencias para o usuario, pergunta se quer visualizar
If nCount > 0
	lItem := MsgYesNo(OemToAnsi(StrTran(STR0002,"%n",StrZero(nCount,2))),OemToAnsi(STR0003))     //"Existem %n Pendˆncias para vocˆ. Deseja Selecion -las agora?" ### "AVISO"
EndIf

// Volta os orders originais
QF2->(dbSetOrder(nOrdQF2))
QF3->(dbSetOrder(nOrdQF3))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exibe as Pendencias ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lItem
	Qiea310(aPermissao)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ver. se existem Permissoes Uso Encerradas (que o usuario seja emissor) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aPermissao := {}
lItem 	  := .F.
nCount1	  := 0

dbSelectArea("QF2")
dbSetOrder(3)
dbSeek(cFilAnt + cMatCod)

While !Eof() .And. cFilAnt + cMatCod == QF2->QF2_FILMAT + QF2->QF2_MAT
	If QF2->QF2_ENCERR == "S"
		nCount1 := nCount1 + 1

		Aadd(aPermissao, { QF2->QF2_FORNEC, QF2->QF2_LOJFOR, QF2->QF2_PRODUT,;
							Dtos(QF2->QF2_DTENTR), QF2->QF2_LOTE })
	EndIf

	dbSelectArea("QF2")
	dbSkip()
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ver. se existem Permissoes Uso Encerradas (que o usuar. seja Us. Qual.)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QF2")
dbSetOrder(4)
dbSeek(cFilAnt + cMatCod)

While !Eof() .And. cFilAnt + cMatCod == QF2->QF2_FILQLD + QF2->QF2_MATQLD
	If QF2->QF2_ENCQLD == "S"
		nCount1 := nCount1 + 1

		Aadd(aPermissao, { QF2->QF2_FORNEC, QF2->QF2_LOJFOR, QF2->QF2_PRODUT,;
							Dtos(QF2->QF2_DTENTR), QF2->QF2_LOTE })
	EndIf

	dbSelectArea("QF2")
	dbSkip()
EndDo

If nCount1 > 0
	lItem := MsgYesNo(OemToAnsi(StrTran(STR0004,"%n",StrZero(nCount1,2))),OemToAnsi(STR0003))  //"Existem Permissoes de Uso Encerradas p/ vocˆ. Deseja Visualiz -las agora?" ### "AVISO"
EndIf

dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exibe as Pendencias ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lItem
	Qiea310(aPermissao)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Retira a Pendencia p/ a Permissao de Uso Encerrada ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nA := 1 To Len(aPermissao)
		dbSelectArea("QF2")
		dbSetOrder(1)
		dbSeek(xFilial("QF2") + aPermissao[nA][1] + aPermissao[nA][2] +;
			aPermissao[nA][3] + aPermissao[nA][4] + aPermissao[nA][5])

		While QF2->QF2_FILIAL		 == xFilial()			 .And.;
				QF2->QF2_FORNEC		 == aPermissao[nA][1] .And.;
				QF2->QF2_LOJFOR		 == aPermissao[nA][2] .And.;
				QF2->QF2_PRODUT		 == aPermissao[nA][3] .And.;
				Dtos(QF2->QF2_DTENTR) == aPermissao[nA][4] .And.;
				QF2->QF2_LOTE			 == aPermissao[nA][5] .And. !Eof()

			// Baixa pendencia de Encerramento das PUs do Emissor
			If QF2->QF2_ENCERR == "S" .And.;
					cFilAnt+cMatCod == QF2->QF2_FILMAT+QF2->QF2_MAT
				RecLock("QF2", .F.)
				QF2->QF2_ENCERR := "N"
				MsUnLock()
			EndIf
			
			// Baixa pendencia de Encerramento das PUs do Usuario Qualidade
			If QF2->QF2_ENCQLD == "S" .And.;
					cFilAnt+cMatCod == QF2->QF2_FILQLD + QF2->QF2_MATQLD
				RecLock("QF2", .F.)
				QF2->QF2_ENCQLD := "N"
				MsUnLock()
			EndIf

			dbSkip()
		End
	Next nA
EndIf

Return(nCount+nCount1)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QIEXLdLU ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 19/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna se o Laudo tem Categoria Liberado Urgente          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QIEXLdLU(ExpC1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Laudo                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QIEXLdLU(cLaudo)
Local lRet		:= .F.
Local nOrdQED	:= QED->(IndexOrd())

QED->(dbSetOrder(1))
QED->(dbSeek(xFilial("QED")+cLaudo))
If QED->QED_CATEG == "4"	// Liberado Urgente
	lRet := .T.
EndIf
QED->(dbSetOrder(nOrdQED))
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QieAmoIni³ Autor ³ Paulo Emidio de Barros³ Data ³ 21/11/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se a Entrada a Inspecionar e Amostra Inicial 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QieAmoIni(EXPC1,EXPC2,EXPC3,EXPC4,EXPC5)					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Codigo do Fornecedor								  ³±±
±±³          ³ EXPC2 = Loja do Fornecedor								  ³±±
±±³          ³ EXPC3 = Codigo do Produto								  ³±±
±±³          ³ EXPC4 = Identificador invertido da Entrada a Inspecionar   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ EXPL1 = .T. = Amostra Inicial, .F. = Amostra Normal        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QieAmoIni(cFornece,cLoja,cProduto,cIdeInv)
Local nQtdEnt  := 0
Local aAreaAnt := GetArea()
Local aAreaQEK := QEK->(GetArea())
Local lRetorno := .T.                              
Local cSeek    := ""

dbSelectArea("QEK") 
dbSetOrder(2)
If dbSeek(xFilial("QEK")+cFornece+cLoja+cProduto+cIdeInv)         
    cSeek   := QEK_FILIAL+QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT+QEK_REVI
    While !Eof() .And. cSeek ==;
    	(QEK_FILIAL+QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT+QEK_REVI)
    	If nQtdEnt > 1		
    		Exit   
		Elseif QEK->QEK_VERIFI == 1
	  	 	nQtdEnt++             
  	 	EndIf
	 	dbSkip()
	EndDo    	
EndIf                 

If nQtdEnt > 1
    lRetorno := .F.
EndIf
	
RestArea(aAreaQEK)
RestArea(aAreaAnt)
Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³QieSkpTst ³ Autor ³Paulo Emidio de Barros ³ Data ³17/01/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se o ensaio selecionado no Laboratorio corrente,  ³±±
±±³			 ³ sera aplicado o Skip-Teste (Individual/Grupo)			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QieSkpTst(EXPC1,EXPC2,EXPC3,EXPC4,EXPD1,EXPC5)			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Codigo do Fornecedor 							  ³±±
±±³	 	     ³ EXPC2 = Loja do Fornecedor								  ³±±
±±³	 		 ³ EXPC3 = Codigo do Produto 								  ³±±
±±³	 		 ³ EXPC4 = Ensaio Corrente 									  ³±±
±±³	 		 ³ EXPD1 = Data da Entrada do Material 						  ³±±
±±³	 		 ³ EXPC5 = Numero do Lote	 								  ³±±
±±³	 		 ³ EXPL1 = Indica se o retorno do status do Skip-Teste sera   ³±±
±±³	 		 ³         abreviado.									      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPC1 = "Inspecionar"/"Certificar"/"N/A"					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QieSkpTst(cFornece,cLoja,cProduto,cEnsaio,dEntrada,cLote,lAbrev,cNiseri,cTipoNF)
Local cRetorno  := "N/A"
Local cGrupo    := ""
Local cSeek     := ""
Local cNotaF    := SubStr(cNiseri,1,TamSX3("QEK_NTFISC")[1])
Local cSeriNF   := SubStr(cNiseri,TamSX3("QEK_NTFISC")[1]+1,TamSX3("QEK_SERINF")[1])
Local cIteNF    := SubStr(cNiseri,TamSX3("QEK_NTFISC")[1]+TamSX3("QEK_SERINF")[1]+1,TamSX3("QEK_ITEMNF")[1])

Default lAbrev := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pesquisa por Grupo 												³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QEA->(dbSetOrder(2))

If QEA->(dbSeek(xFilial("QEA")+cProduto))
	cGrupo := QEA->QEA_GRUPO
EndIf

QEH->(dbSetOrder(1))
If QEH->(dbSeek(xFilial("QEH")+cFornece+cLoja+cProduto+cEnsaio))
	cRetorno := QieDescSkT(lAbrev,QEH->QEH_SKPTES,cFornece,cLoja,cProduto)
Else

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existe skip-teste por grupo definido 			³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QEI->(dbSetOrder(1))
	If QEI->(dbSeek(xFilial("QEI")+cFornece+cLoja+cGrupo+cEnsaio))

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se a Entrada existe no historico, ‚ porque ‚ p/ inspecionar ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cSeek   := xFilial("QEZ")+cFornece+cLoja+cProduto+cNotaF+cSeriNF+cIteNF+cTipoNF+cLote+cEnsaio
		QEZ->(dbSetOrder(3))
		If QEZ->(dbSeek(xFilial("QEZ")+cFornece+cLoja+cGrupo+dTos(dEntrada)+cLote+cEnsaio))
			If lAbrev 
				cRetorno := "CER"
			Else
				cRetorno := OemToAnsi(STR0008) //"Certificar"
			EndIf	
		Else
			cRetorno := QieDescSkT(lAbrev,QEI->QEI_SKPTES,cFornece,cLoja,cProduto)
		EndIf                                                                        
	EndIf
EndIf

Return(cRetorno)
                
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³qAtuPlAmEn³ Autor ³Paulo Emidio de Barros ³ Data ³17/01/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Aplica o Plano de Amostragem por Ensaios					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QAtuPlAmEn(EXPC1,EXPC2,EXPC3,EXPC4,EXPC5,EXPC6,EXPN1)	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Codigo do Fornecedor 							  ³±±
±±³	 	     ³ EXPC2 = Loja do Fornecedor								  ³±±
±±³	 		 ³ EXPC3 = Codigo do Produto 								  ³±±
±±³	 		 ³ EXPC4 = Revisao do Produto							 	  ³±±
±±³	 		 ³ EXPC5 = Chave da Entrada a Inspecionar 	  				  ³±±
±±³	 		 ³ EXPC6 = Tamanho da Amostra a Inspecionar					  ³±±
±±³	 		 ³ EXPC1 = Tipo da Nota Fiscal								  ³±±
±±³	 		 ³ EXPN1 = 1 = Inclui										  ³±±
±±³	 		 ³         2 = Exclui										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAQIE													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qAtuPlAmEn(cFornece,cLoja,cProduto,cRevi,cChave,cTamAmo,cTipoNF,nOpcao)
Local nAce11    := 0
Local nRej11    := 0
Local nTamA11   := 0
Local nAce12    := 0
Local nRej12    := 0
Local nTamA12   := 0
Local cCondicao := ""
Local cTabela   := ""
Local cAlias    := ""
Local cCodNorma := ""
Local aAmostra  := {}

//Tratamento p/ o cliente Laboris
If cTipoNF$'BD'                                 
   cCondicao := "QF6_CLIENT+QF6_LOJCLI+QF6_PRODUT+QF6_REVI"
   cTabela   := "QF6"
   cAlias    := "QF6->QF6_"
Else
   cCondicao := "QF4_FORNEC+QF4_LOJFOR+QF4_PRODUT+QF4_REVI"
   cTabela   := "QF4"
   cAlias    := "QF4->QF4_"
EndIf

dbSelectArea(cTabela)
dbSetOrder(1)
dbSeek(xFilial(cTabela)+cFornece+cLoja+cProduto+cRevi,.T.)
While !Eof() .And. &(cAlias+"FILIAL") == xFilial(cTabela) .And.;
	(cFornece+cLoja+cProduto+cRevi) == &cCondicao
	
	If !Empty(&(cAlias+"PLAMO"))

		cCodNorma := QA_Plano(&(cAlias+"TIPAMO"))

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Realiza a atualizacao do Plano de Amostragem por Ensaios	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (nOpcao == 1) 
		       
			//Retorna a Amostra, Aceite e Rejeite, basendo-se na codificacao do Plano de Amostragem selecionado
			aAmostra := Qep_RetAmostra(&(cAlias+"TIPAMO"),&(cAlias+"PLAMO"),&(cAlias+"NIVEL") ,&(cAlias+"NQA"),cTamAmo,"QEK_TAMAMO",.F.)
		                                             
		    If &(cAlias+"TIPAMO") == "3" //Plano Interno                  
		    	//Obtem somente a primeira sequencia do Plano de Amostragem
		    	nTamA11  := aAmostra[1,3] 
				nAce11   := aAmostra[1,1]
				nRej11   := aAmostra[1,2]
				nTamA12  := aAmostra[1,6]
				nAce12   := aAmostra[1,4]
			  	nRej12   := aAmostra[1,5]
			Else	   
		    	nTamA11  := aAmostra[1]
				nAce11   := aAmostra[2]
				nRej11   := aAmostra[3]
				nTamA12  := aAmostra[4]
				nAce12   := aAmostra[5]
			  	nRej12   := aAmostra[6]
		    EndIf
		   
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava o Plano de Amostragem por Ensaio						³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("QF5")
			dbSetorder(2)
			If dbSeek(xFilial("QF5")+&(cAlias+"ENSAIO")+cChave)
			   	RecLock("QF5",.F.)                                                  
			Else
				RecLock("QF5",.T.)
			EndIf               
			QF5->QF5_FILIAL := xFilial("QF5")    
			QF5->QF5_FORNEC := cFornece
			QF5->QF5_LOJFOR := cLoja
			QF5->QF5_PRODUT := cProduto
			QF5->QF5_REVI   := cRevi
			QF5->QF5_CHAVE  := cChave
			QF5->QF5_ENSAIO := &(cAlias+"ENSAIO")
			QF5->QF5_TAMA1  := nTamA11
			QF5->QF5_ACEI1  := nAce11
			QF5->QF5_REJEI1 := nRej11
			QF5->QF5_TAMA2  := nTamA12
			QF5->QF5_ACEI2  := nAce12
			QF5->QF5_REJEI2 := nRej12
			QF5->QF5_TIPO   := cTipoNF
		    MsUnlock()
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Realiza a exclusao do Plano de Amostragem por Ensaios		³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf (nOpcao == 2)

			dbSelectArea("QF5")
			dbSetorder(2)
			If dbSeek(xFilial("QF5")+&(cAlias+"ENSAIO")+cChave)
				RecLock("QF5",.F.)
				dbDelete()
				MsUnLock()
			EndIf	
					
		EndIf
		
	EndIf
	    
	dbSelectArea(cTabela)
	dbSetorder(1)
	dbSkip()	 
	
EndDo	

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³QComMovPAE³ Autor ³Paulo Emidio de Barros ³ Data ³04/04/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Compatibiliza o Plano de Amostragem por Ensaios de acordo  ³±±
±±³			 ³ com a nova revisao do Produto x Fornecedor. 				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QComMovPAE(cProduto,cRevAtu,aEnsAtu,lDelPAE,nOpc)		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Codigo do Produto								  ³±±
±±³	 	     ³ EXPC2 = Revisao atual do Produto							  ³±±
±±³	 	     ³ EXPA1 = Vetor contendo os ensaios da Revisao atual		  ³±±
±±³	 	     ³ EXPL1 = Indica se os Planos de Amostragens associados serao³±±
±±³	 	     ³ 		   excluidos sem critica.							  ³±±
±±³	 	     ³ EXPN1 = 1 = Inclui										  ³±±
±±³	 	     ³ 		   2 = Exclui										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Nulo														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAQIE													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QComMovPAE(cProduto,cRevAtu,aEnsAtu,lDelPAE,nOpc)
Local aAreaAnt   := GetArea()
Local nIniEns    := 0
Local cRevAnt    := ""
Local aRegistro  := {}
Local lContinua    
Local nY
Local cTab1      := ""
Local cCam1      := ""
Local cTab2      := ""
Local cCam2      := ""           
Local cPesq      := ""

lDelPAE := If(lDelPAE==NIL,.F.,lDelPAE)

//Armazena a revisao Anterior do Produto
cRevAnt := QieRevAnt(cProduto,cRevAtu)

If nOpc == 1 //Inclusao

	For nY:=1 to 2
		
		If nY==1
			cTab1 := "SA5"
			cCam1 := "SA5->A5_"
			cTab2 := "QF4"
			cCam2 := "QF4->QF4_"
			cPesq := "SA5->A5_FORNECE+SA5->A5_LOJA"
		Else
			cTab1 := "SA7"
			cCam1 := "SA7->A7_"
			cTab2 := "QF6"
			cCam2 := "QF6->QF6_"
			cPesq := "SA7->A7_CLIENTE+SA7->A7_LOJA"
		EndIf
		
		dbSelectArea(cTab1)
        dbSetOrder(2)
		dbSeek(xFilial(cTab1)+cProduto)
		While &(cCam1+"FILIAL") == xFilial(cTab1) .And. (&(cCam1+"PRODUTO") == cProduto)
			
			For nIniEns := 1 to Len(aEnsAtu)
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grava a especificacao, somente se nao houver Entradas com o ³
				//³ Plano de Amostragem associado ao ensaio na revisao corrente.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aRegistro := Array(&(cTab2+"->(fCount())"))
					
				//Pesquisa a revisao anterior da Especificacao do Produto
				dbSelectArea(cTab2)
				dbSetOrder(3)
				If dbSeek(xFilial(cTab2)+cProduto+cRevAnt+aEnsAtu[nIniEns,1]+&(cPesq))
						
					//Armazena o registro do ensaio na revisao anterior
					Aeval(aRegistro,{|x,y|aRegistro[y]:=&(cTab2+"->"+FieldName(y))})
						
					//Pesquisa a revisao atual da Especificacao do Produto
					dbSelectArea(cTab2)
					dbSetOrder(3)
					If !dbSeek(xFilial(cTab2)+cProduto+cRevAtu+aEnsAtu[nIniEns,1]+&(cPesq))
							
						RecLock(cTab2,.T.)
						Aeval(aRegistro,{|x,y|FieldPut(FieldPos(FieldName(y)),aRegistro[y])})
							
						//Grava a revisao atual
						&(cCam2+"REVI") := cRevAtu
						MsUnLock()
					Else
						If aEnsAtu[nIniEns,2] //marcado para exclusao
							RecLock(cTab2,.F.)
							&(cTab2+"->(dbDelete())")
							MsUnLock()
						EndIf
					EndIf
						
				EndIf
					
			Next nIniEns
			
			dbSelectArea(cTab1)
            dbSkip()
		EndDo
	Next nY
	
ElseIf nOpc == 2 //Exclusao
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exclue somente se nao houver Entradas associadas ao Plano de³
	//³ Amostragem por ensaios.										³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	For nY:=1 to 2
		
		If nY==1
			cTab1 := "SA5"
			cCam1 := "SA5->A5_"
			cTab2 := "QF4"
			cCam2 := "QF4->QF4_"
			cPesq := "SA5->A5_FORNECE+SA5->A5_LOJA"
		Else
			cTab1 := "SA7"
			cCam1 := "SA7->A7_"
			cTab2 := "QF6"
			cCam2 := "QF6->QF6_"
			cPesq := "SA7->A7_CLIENTE+SA7->A7_LOJA"
		EndIf
		
		dbSelectArea(cTab2)
		dbSetOrder(3)
		If dbSeek(xFilial(cTab2)+cProduto+cRevAtu)
			
			lContinua := .T.
			
			If cTab1 == "SA5"
				//Verifica o Historico referente as Notas Fiscais do Tipo Normal
				QF5->(dbSetOrder(5))
				If QF5->(dbSeek(xFilial("QF5")+&(cCam2+"PRODUT")+&(cCam2+"REVI")+"N"))
					If !lDelPAE
						lContinua := .F.
					EndIf
				EndIf
				
			Else
				//Verifica o Historico referente as Notas Fiscais do Tipo Devolucao
				QF5->(dbSetOrder(5))
				If QF5->(dbSeek(xFilial("QF5")+&(cCam2+"PRODUT")+&(cCam2+"REVI")+"D"))
					If !lDelPAE
						lContinua := .F.
					EndIf
				EndIf                                                                   
				
				//Verifica o Historico referente as Notas Fiscais do Tipo Beneficiamento
				If QF5->(dbSeek(xFilial("QF5")+&(cCam2+"PRODUT")+&(cCam2+"REVI")+"B"))
					If !lDelPAE
						lContinua := .F.
					EndIf
				EndIf
			EndIf
			
			While lContinua .And. &(cTab2+"->(!Eof())") .And. &(cCam2+"FILIAL") == xFilial(cTab2) .And.;
				&(cCam2+"PRODUT")+&(cCam2+"REVI") == (cProduto+cRevAtu)
				RecLock(cTab2,.F.)
				&(cTab2+"->(dbDelete())")
				MsUnLock()
				
				dbSelectArea(cTab2)
				dbSkip()
			EndDo
			
		EndIf
	Next nY
EndIf

RestArea(aAreaAnt)

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³QieRevAnt ³ Autor ³Paulo Emidio de Barros ³ Data ³04/04/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna a revisao anterior da Especificacao do Produto.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QieRevAnt(cProduto,cRevAtu)								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Codigo do Produto								  ³±±
±±³	 	     ³ EXPC2 = Revisao atual do Produto							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPC3 = Revisao anterior da Especificacao do Produto		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAQIE													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QieRevAnt(cProduto,cRevAtu)
Local aAreaAnt := GetArea()
Local cRevAnt  := " "

dbSelectArea("QE6")
dbSetOrder(1)
If dbSeek(xFilial("QE6")+cProduto+Inverte(cRevAtu))
	dbSkip()
	If (QE6_FILIAL == xFilial("QE6")) .And. (QE6_PRODUT == cProduto)
		cRevAnt := QE6_REVI	
	EndIf
EndIf
                  
If Empty(cRevAnt)
	cRevAnt := cRevAtu
EndIf
	 
RestArea(aAreaAnt)

Return(cRevAnt)                            

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³QieAtuNNC ³ Autor ³Paulo Emidio de Barros ³ Data ³18/07/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Realiza a Atualizacao das Notificacoes das nao-conformidades³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QieAtuNNC(nOpc)											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPN1 = 1) Inclusao da NNC								  ³±±
±±³			 ³         2) Exclusao da NNC								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPC1 = Numero da Notificacao da nao-conformidade          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAQIE													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QieAtuNNC(nOpc,cProg)
Local cNNC      := QEK->QEK_NNC
Local aAreaQEM 
Local cChave
Local lBaixaNNC := GetMV("MV_QBXANNC")
Local lIntQNC   := If(GetMV("MV_QINTQNC")=="S",.T.,.F.)
Local cEspecie  := "QIEA220 "           
Local aTexto    := {}
Local cTexto    := '' 

Default cProg   := ""

If nOpc == 1 //Inclusao                 
	If Empty(cNNC) .OR. cProg == "QIER030"
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Caso nao exista a NNC, realiza a Atualizacao da mesma, o QEK³ 
		//³ devera estar posicionado.									³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		QEM->(dbSetOrder(1))
		If !QEM->(dbSeek(xFilial("QEM")+cNNC))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava o Numero da Notificacao das nao-conformidades			³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cNNC := QA_SEQU("QIE_NNCO" + Str(Year(dDataBase),4),TamSX3("QEK_NNC")[1],"S",OemToAnsi(STR0009))

			RecLock("QEK",.F.)
			QEK->QEK_NNC    := cNNC
			QEK->QEK_NNCINV := Right(cNNC,4)+Left(cNNC,7)
			MsUnlock()
			
			//Gera a chave da naotificacao da NNC
			aAreaQEM := QEM->(GetArea())
			cChave := QA_NewChave(,"QEM",2)
		    RestArea(aAreaQEM)   

			RecLock("QEM",.T.)
			QEM->QEM_FILIAL := xFilial("QEM")
			QEM->QEM_NNC    := cNNC
			QEM->QEM_DTNNC  := dDataBase
			QEM->QEM_FORNEC := QEK->QEK_FORNEC
			QEM->QEM_LOJFOR := QEK->QEK_LOJFOR
			QEM->QEM_PRODUT := QEK->QEK_PRODUT
			QEM->QEM_LOTE   := QEK->QEK_LOTE
			QEM->QEM_DTENTR := QEK->QEK_DTENTR
			QEM->QEM_GRUPO  := QEK->QEK_GRUPO
			QEM->QEM_CHAVE  := cChave
			MsUnLock()
			FkCommit()
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Realiza a baixa das Notificacoes das Nao-conformidades    	³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lIntQNC //Verifica se existe integracao
			
				If lBaixaNNC //Verifica se as NNCs serao baixadas
				
					RecLock("QEM",.F.)
					QEM->QEM_DTRESP := dDataBase
					QEM->QEM_DTFECH := dDataBase
					MsUnLock()
					
					cTexto += OemToAnsi(STR0010) //"A Notificacao das Nao-conformidades apontadas no Lote :"
					cTexto += QEK->QEK_LOTE+OemToAnsi(STR0011) //", foi encerrada automaticamente pelo sistema,"
					cTexto += OemToAnsi(STR0012) //" as mesmas deverao ser tratadas atraves do modulo : "
					cTexto += OemToAnsi(STR0013) //"SIGAQNC(Controle de Nao-Confomidades)"				                               
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza o texto das Notificacoes das NCs	  			 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Aadd(aTexto,{1,cTexto})
					QA_GrvTxt(cChave,cEspecie,1,@aTexto)    
				
				EndIf
			EndIf	
		EndIf     
	EndIf   
	
ElseIf nOpc == 2
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Realiza a exclusao das NNCs vinculadas					   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cNNC)
		dbSelectArea('QEM')
		dbSetOrder(1)
		dbSeek( xFilial("QEM")+cNNC)
		While !EOF() .And. QEM_FILIAL+QEM_NNC == xFilial("QEM")+cNNC

			//Exclui o Texto das observacoes da Notificacao das nao-conformidades
			If !Empty(QEM->QEM_CHAVE)                        
				QA_DelTxt(QEM->QEM_CHAVE,"QIEA220 ")   
			EndIf   
			
			//Elimina o Numero da Notificacao da NNC no cadastro das Entradas Inspecionadas
			RecLock("QEK",.F.)
			QEK->QEK_NNC    := " "
			QEK->QEK_NNCINV := " "
			MsUnLock()

			RecLock("QEM",.F.,.T.)
			dbDelete()
			MsUnLock()         
			
			dbSelectArea('QEM')
			dbSetorder(1)
			dbSkip()
			
		EndDo          
	EndIf
EndIf	

Return(cNNC)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³QieSkipLote³ Autor ³Paulo Emidio de Barros³ Data ³ 06/06/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Aplica o Skip-Lote para as Entradas						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QieSkipLote(cFornece,cLoja,cProduto,cGrupo,dEntrada,;  	  ³±±
±±³			 ³ cLote,cDocEnt,aMsg)										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Fornecedor                	 					  ³±±
±±³			 ³ EXPC2 = Loja												  ³±±
±±³			 ³ EXPC3 = Produto											  ³±±
±±³			 ³ EXPC4 = Grupo											  ³±±
±±³			 ³ EXPD1 = Data de Entradas								      ³±±
±±³			 ³ EXPC5 = Numero do Lote									  ³±±
±±³			 ³ EXPC6 = Documento de Entrada								  ³±±
±±³			 ³ EXPA1 = Mensagens da Justificativa		  				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPL1 = .T. - Inspeciona .F. - Certifica			  		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAQIE													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QieSkipLote(cFornece,cLoja,cProduto,cGrupo,dEntrada,cLote,cDocEnt,aMsg)
Local aAreaAnt    := GetArea()
Local aAreaQEK    := QEK->(GetArea())
Local aAreaSA5    := SA5->(GetArea())
Local cLabor      := Space(TamSX3("QEL_LABOR")[1])
Local nEntradas   := 0                   
Local nRecusadas  := 0
Local nEntIns     := 0
Local nVerifica   := 1  //Define se a Entrada atual sera Inspecionada
Local dLimite   
Local lContinua   := .F.
Local cSeek       := ""
Local cNiseri	  := ""
Local lQESEMSKPLT := ExistBlock("QESEMSKPLT")
aMsg := {}              

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Identifica a Aplicacao da Unidade do Skip-Lote				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//Posiciona na Amarracao Produto x Fornecedor
dbSelectArea("SA5")
dbSetOrder(2)
If dbSeek(xFilial("SA5")+cProduto+cFornece+cLoja)
	If !Empty(SA5->A5_SKPLOT)
		dbSelectArea("QEF")
		dbSetOrder(1)
		If MsSeek(xFilial("QEF")+SA5->A5_SKPLOT)
			lContinua := .T.	
	    EndIf                    
    EndIf
EndIf       
         
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada que executa ou nao a rotina de SkipLote	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lContinua .and. ExistBlock("QESEMSKPLT")
	lContinua := ExecBlock("QESEMSKPLT",.F.,.F.,{cFornece,cLoja,cProduto,dEntrada,cLote,cDocEnt,"I",QEF->QEF_UNSKLT})  
EndIf

If !lContinua
	//Restaura as areas correntes
	RestArea(aAreaQEK)
	RestArea(aAreaSA5)
	RestArea(aAreaAnt)
	Return(nVerifica)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Identifica o Numero de Entradas a Inspecionar, referentes ao ³
//³ fator REJEITADO TOTALMENTE.									 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nEntIns := Fator("3",.F.) //Rejeitado Totalmente

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Controle por Documento de Entrada         					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If QEF->QEF_UNSKLT == "L" 
	   
	//Verifica se nao ha Skip-Teste definido por Grupo
	QEI->(dbSetorder(1))
	If !QEI->(MsSeek(xFilial("QEI")+cFornece+cLoja+cGrupo))
		nEntradas  := 0
		nRecusadas := 1
	
		dbSelectArea("QEK")
		dbSetOrder(4)
		If MsSeek(xFilial("QEK")+cDocEnt+cFornece+cLoja+cProduto)
		
			nVerifica := 2 //Certifica a Entrada Atual
			While !Eof() .And. QEK_FILIAL==xFilial("QEK") .And. QEK_DOCENT==cDocEnt .And. QEK_FORNEC==cFornece .And. QEK_LOJFOR==cLoja .And. QEK_PRODUT==cProduto
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Ponto de Entrada que executa ou nao a rotina de SkipLote	 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lQESEMSKPLT
					If !ExecBlock("QESEMSKPLT",.F.,.F.,{QEK_FORNEC,QEK_LOJFOR,QEK_PRODUT,QEK_DTENTR,QEK_LOTE,QEK_DOCENT,"P",QEF->QEF_UNSKLT})  
						QEK->(dbSkip())
						Loop
					EndIF
				EndIf
				
				//Posiciona no Laudo da Entrada Inspecionada	
				cNiseri := QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF
				QEL->(dbSetOrder(3))
				cSeek  := (QEK->(QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT)+cNiseri+(QEK->(QEK_TIPONF+DtOS(QEK_DTENTR)+QEK_LOTE)))
				If QEL->(MsSeek(xFilial("QEL")+cSeek+cLabor))
		
					//Verifica se o fator do Laudo da Entrada possui Entradas a Inspecionar
					QED->(dbSetOrder(1))
					If QED->(dbSeek(xFilial("QED")+QEL->QEL_LAUDO))	       
						If QED->QED_ENTINS > 0 .And. nEntradas <= (QED->QED_ENTINS-1)
							nRecusadas := 2
							Exit
					    EndIf
					EndIf
				EndIf
	           
				nEntradas++ //Incrementa o numero de Entradas
	    	
				If nEntradas > 5
					Exit
				EndIf
	        	dbSkip()
			EndDo				
	    EndIf
	
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Controle por Lote (Documento de Entrada) - Grupo			 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("QEA")
		dbSetOrder(1)
		MsSeek(xFilial("QEA")+cGrupo)
		While QEA_FILIAL==xFilial("QEA") .And. QEA_GRUPO==cGrupo .And. !Eof()
			dbSelectArea("QEK")
			dbSetOrder(4)
			If MsSeek(xFilial("QEK")+cDocEnt+cFornece+cLoja+QEA->QEA_PRODUT)
				nVerifica := 2
				Exit
		    EndIf 
			dbSkip()
		EndDo
		
		If nVerifica == 2
			nEntradas  := 0
			nRecusadas := 1
		
			dbSelectArea("QEK")
			dbSetOrder(4)
			While !Eof() .And. QEK_FILIAL==xFilial("QEK") .And. QEK_DOCENT==cDocEnt .And. QEK_FORNEC==cFornece .And. QEK_LOJFOR==cLoja 
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Ponto de Entrada que executa ou nao a rotina de SkipLote	 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lQESEMSKPLT
					If !ExecBlock("QESEMSKPLT",.F.,.F.,{QEK_FORNEC,QEK_LOJFOR,QEK_PRODUT,QEK_DTENTR,QEK_LOTE,QEK_DOCENT,"P",QEF->QEF_UNSKLT})  
						QEK->(dbSkip())
						Loop
					EndIF
				EndIf
				
				QEA->(dbSetOrder(2))
				QEA->(MsSeek(xFilial("QEA")+QEK->QEK_PRODUT))
				If QEA->QEA_GRUPO<>cGrupo
					dbSkip()
					Loop
				EndIf
				cNiseri := QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF
				QEL->(dbSetOrder(3))
				cSeek  := (QEK->(QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT)+cNiseri+QEK->(QEK_TIPONF+DtOS(QEK_DTENTR)+QEK_LOTE))
				If QEL->(MsSeek(xFilial("QEL")+cSeek+cLabor))

					//Verifica se o fator do Laudo da Entrada possui Entradas a Inspecionar
					QED->(dbSetOrder(1))
					If QED->(dbSeek(xFilial("QED")+QEL->QEL_LAUDO))	       
						If QED->QED_ENTINS > 0 .And. nEntradas <= (QED->QED_ENTINS-1)
							nRecusadas := 2
							Exit
					    EndIf
					EndIf
					
				EndIf

				nEntradas++
				If nEntradas > 5
					Exit
				EndIf
	            dbSkip()
			EndDo		
			
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso haja entradas anteriores com Laudo reprovados, a Entrada³
	//³ atual sera inspecionada.									 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nRecusadas > 1
		nVerifica := 1
	EndIf
    
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Controle por Entradas ou Dias         						 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nEntradas  := 0 //contador de Entradas
	nRecusadas := 1 //contador de Entradas recusadas
	
	dbSelectArea("QEK")
	dbSetOrder(2)
	dbSeek(xFilial("QEK")+cFornece+cLoja+cProduto)	
	While QEK_FILIAL==xFilial("QEK") .And.	QEK_FORNEC==cFornece .And.;
		 QEK_LOJFOR==cLoja .And. QEK_PRODUT==cProduto	
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ponto de Entrada que executa ou nao a rotina de SkipLote	 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lQESEMSKPLT
			If !ExecBlock("QESEMSKPLT",.F.,.F.,{QEK_FORNEC,QEK_LOJFOR,QEK_PRODUT,QEK_DTENTR,QEK_LOTE,QEK_DOCENT,"P",QEF->QEF_UNSKLT})  
				QEK->(dbSkip())
				Loop
			EndIF
		EndIf
		
		//Posiciona no Laudo da Entrada Inspecionada	
		QEL->(dbSetOrder(3))
		cNiseri := QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF
		cSeek   := QEK->(QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT+cNiseri+QEK_TIPONF+DtOS(QEK_DTENTR)+QEK_LOTE)
		If QEL->(MsSeek(xFilial("QEL")+cSeek+cLabor))

			//Verifica se o fator do Laudo da Entrada possui Entradas a Inspecionar
			QED->(dbSetOrder(1))
			If QED->(MsSeek(xFilial("QED")+QEL->QEL_LAUDO))	       
				If QED->QED_ENTINS > 0 .And. nEntradas <= (QED->QED_ENTINS-1)
					nRecusadas := 2
					Exit
			    EndIf
			EndIf
		EndIf
		nEntradas++ //Incrementa o numero de Entradas

		If nEntradas > nEntIns
			Exit
		EndIf
	    dbSkip()	
	    
	EndDo    
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso haja entradas anteriores com Laudo reprovados, a Entrada³
	//³ atual sera inspecionada.									 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nRecusadas  >  1
		nVerifica := 1
	Else	                      
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Controle por Unidade DIA									 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If QEF->QEF_UNSKLT == "D" 
	                                    
			//Data limite para que a Entrada seja inspecionada novamente	                                	
			dLimite := (dEntrada-(QEF->QEF_QTDE-1))

			//Busca a Entrada com data anterior a Atual
			dbSelectArea("QEK")                  
			dbSetOrder(2)    
			MsSeek(xFilial("QEK")+cFornece+cLoja+cProduto)
			While !Eof() .And. QEK_FILIAL==xFilial("QEK") .And. QEK_FORNEC==cFornece .And. QEK_LOJFOR==cLoja .And. QEK_PRODUT==cProduto 
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Ponto de Entrada que executa ou nao a rotina de SkipLote	 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lQESEMSKPLT
					If !ExecBlock("QESEMSKPLT",.F.,.F.,{QEK_FORNEC,QEK_LOJFOR,QEK_PRODUT,QEK_DTENTR,QEK_LOTE,QEK_DOCENT,"P",QEF->QEF_UNSKLT})  
						QEK->(dbSkip())
						Loop
					EndIF
				EndIf
	
				//Se nao houve Inspecao no Periodo, a Entrada atual sera Inspecionada
				If QEK_DTENTR < dLimite
					nVerifica := 1
					Exit
			    EndIf   
			                   
			    //Se houve inspecao no Periodo,  a Entrada atual sera Certificada
			    If QEK_VERIFI <> 2
			    	nVerifica := 2
			    	Exit	
			    EndIf
			    dbSkip()
			    
			EndDo
        
        Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Controle por Unidade ENTRADA								 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
			If QEF->QEF_QTDE == 9999 //Situacao FREE-PASS, sera certificado sempre
				nVerifica := 2
			Else
				nEntradas := 0
				dbSelectArea("QEK")
				dbSetOrder(2)
				MsSeek(xFilial("QEK")+cFornece+cLoja+cProduto)
				While !Eof() .And. QEK_FILIAL==xFilial("QEK") .And. QEK_FORNEC==cFornece .And. QEK_LOJFOR==cLoja .And. QEK_PRODUT==cProduto 

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Ponto de Entrada que executa ou nao a rotina de SkipLote	 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lQESEMSKPLT
						If !ExecBlock("QESEMSKPLT",.F.,.F.,{QEK_FORNEC,QEK_LOJFOR,QEK_PRODUT,QEK_DTENTR,QEK_LOTE,QEK_DOCENT,"P",QEF->QEF_UNSKLT})  
							QEK->(dbSkip())
							Loop
						EndIF
					EndIf
		
				    nEntradas++	        
					
					dbSkip()
				EndDo		
				nVerifica := If(At(".", STR(nEntradas/QEF->QEF_QTDE)) == 0 , 1, 2)
				
			EndIf
        
        EndIf
        
	EndIf
  
EndIf

If nRecusadas > 1
	//Verifica a existencia de Laudos Condicionais e Reprovados 
	Aadd(aMsg,STR0014) //"Devido à definição existente nos Fatores do IQP"
	Aadd(aMsg,STR0015) //"a entrada atual deverá ser inspecionada."
EndIf

If nVerifica == 1
	//Justificativa para o Skip-Lote a Inspecionar                 
	If Len(aMsg) == 0
		Aadd(aMsg,STR0017) //"A Entrada atual dever  ser inspecionada,"
		Aadd(aMsg,STR0018) //"pela Avaliacao do Skip-Lote.            "
    EndIf
Else
	//Justificativa para o Skip-Lote a Certificar
	Aadd(aMsg,STR0019) //"A Entrada atual poder  ser aprovada em "
	Aadd(aMsg,STR0020) //"Regime de Skip-Lote automatico.        "
  
EndIf

//Restaura as areas correntes
RestArea(aAreaQEK)
RestArea(aAreaSA5)
RestArea(aAreaAnt)
  
Return(nVerifica)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Fator     ³ Autor ³Paulo Emidio de Barros ³ Data ³06/06/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o Fator do IQP									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fator(EXPC1,EXPL1)										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Categoria a ser verificada						  ³±±
±±³	 	     ³ EXPL1 = T - Retorna a Categoria                            ³±±
±±³	 	     ³ 		   F - Retorna Quantidade de Entradas a Inspecionar   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPX1 = Categoria ou Quantidade a Inspecionar			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAQIE													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fator(cCategoria,lCategoria)
Local aAreaAnt := GetArea()
Local cFator   := Space(TamSX3("QED_CODFAT")[1])
Local nEntIns  := 0

lCategoria := If(lCategoria==NIL,.T.,lCategoria)

dbSelectArea("QED")
dbSetOrder(1)
dbSeek(xFilial("QED"))
While !Eof() .And. QED_FILIAL==xFilial("QED")
	If QED_CATEG == cCategoria
		If lCategoria
			cFator := QED_CODFAT
		Else
		    nEntIns := QED_ENTINS
		EndIf				
		Exit
	EndIf
	QED->(dbSkip())
EndDo

RestArea(aAreaAnt)
Return(If(lCategoria,cFator,nEntIns))     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ QAtuShelf   ³ Autor ³ Cleber L. Souza        ³ Data ³06/08/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Calcula dias de Validade através do Shelf Life                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Produto      										  ³±±
±±³			 ³ EXPC2 = Revisao                           					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Geral											         	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                              
Function QAtuShelf(cProduto,cRevi)

Local aArea         := GetArea()
Local cChaveQEK	:= cPRODUTO+Inverte(cREVI)
Local nDias         := 0

dbSelectArea("QE6")
dbSetOrder(1)
If dbSeek(xFilial("QE6")+cChaveQEK)
	If QE6->QE6_SHLF > 0
		If QE6->QE6_UNSHEL == "1"  // Dia
			nDias := QE6->QE6_SHLF
		Else
			If QE6->QE6_UNSHEL == "2" // Mes
				nDias := QE6->QE6_SHLF * 30
			Else
				nDias := QE6->QE6_SHLF * 365
			EndIf
		EndIf
	EndIf
EndIf
          
RestArea(aArea)          
                        
Return(nDias) 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ QJustTxt    ³ Autor ³ Cleber L. Souza        ³ Data ³06/08/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Justifica um texto e devolve o mesmo em n linhas				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = String q vai ser justificado							  ³±±
±±³			 ³ EXPN2 = Tamanho da Coluna que sera justificado.				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPA1 = Array com o texto justificado    				  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Geral											         	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/        
Function QJustTxt(cString,nTamanho)    
Return(JustificaTXT(cString,nTamanho))  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QIELOAD  ³ Autor ³ Cleber Souza 			³ Data ³ 05/01/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotinas que sao executadas ao entrar no modulo.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QIELOAD()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaQIE		                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QIELOAD()   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ MA215CHECK - Funcao utilizada para verificar se no momento da abertura  |
//³              do modulo existem tabelas exclusivas abertas pela rotina   |
//|              MATA215 ou por outro processo.                             |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MA215CHECK()

dbSelectArea("SD1")
dbSelectArea("QEK")
dbSelectArea("QER")

QA_TRAVUSR()

//Verifica se o tratamento da Reinspecao de Produtos no mesmo Dia, se foi aplicada.
QIEReinsp()

// Bloqueio no sistema  caso os  campos  compostos estejam inconsistentes
If (TamSx3("QEK_NTFISC")[1]+TamSx3("QEK_SERINF")[1]+TamSx3("QEK_ITEMNF")[1] > TamSx3("QEL_NISERI")[1] .OR.;
    TamSx3("QEK_NTFISC")[1]+TamSx3("QEK_SERINF")[1]+TamSx3("QEK_ITEMNF")[1] > TamSx3("QER_NISERI")[1] .OR.;
	TamSx3("D1_DOC")[1]+TamSx3("D1_SERIE")[1]+ TamSx3("D1_ITEM")[1] > TamSx3("QER_NISERI")[1] .OR.;
 	TamSx3("D1_DOC")[1]+TamSx3("D1_SERIE")[1]+ TamSx3("D1_ITEM")[1] > TamSx3("QEL_NISERI")[1])
	Help(" ",1,"QIENISERI")
	Return Nil
EndIf

FQIE_USR()            

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ QIEINITFUN ºAutor  ³ TOTVS S/A        º Data ³  21/01/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Executa as funcoes de inicializacao do modulo SIGAQIE       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAQIE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QIEINITFUN()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ MA215CHECK - Funcao utilizada para verificar se no momento da abertura  |
//³              do modulo existem tabelas exclusivas abertas pela rotina   |
//|              MATA215 ou por outro processo.                             |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MA215CHECK()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³QieAtuLaudo³ Autor ³Paulo Emidio de Barros³ Data ³01/06/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza o Laudo para Entradas Certificadas por Skip-Lote  ³±±
±±³			 ³ Obs.: Para utilizacao desta funcao, o registro do QEK, de- ³±±
±±³			 ³ 		 vera estar agravado e posicionado, caso contrario, o ³±±
±±³			 ³ 		 Laudo sera gravado incorretamente.					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QieAtuLaudo(EXPN1)										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPN1 = 1 = Inclui										  ³±±
±±³	 	     ³		   2 = Exclui										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPL1 = T - Atualizou									  ³±±
±±³			 ³         F - Nao atualizou				  				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAQIE													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QieAtuLaudo(nOpc)
Local lRetorno  := .F.     
Local aAreaAnt  := GetArea()
Local dValidade := dDataBase
Local nDias     := 0              
Local cFatApr   := Fator('1',.T.) //Aprovado Total
Local cCerQua   := " "
Local cLabor    := " "
Local cChave    := " "
Local cNiseri   := ""       
Local lQReinsp	:= QieReinsp()

Private lInsAmoIni := GetMv("MV_QAMOINI")

If QEK->QEK_VERIFI == 2 //Ataualiza o Laudo somenta para entradas certificadas
    cQEL_JUSTLA := GetMv("MV_QEJUSLA")

	cLabor := CriaVar("QEL_LABOR")

	cNiseri := QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF
	QEL->(dbSetOrder(3))
	cChave := (QEK->(QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT))+cNiseri+(QEK->(QEK_TIPONF+DtOS(QEK_DTENTR)+QEK_LOTE))
    //Verifica a existencia do Laudo a ser atualizado
	QEL->(dbSeek(xFilial("QEL")+cChave))
	If nOpc == 1 //Inclusao
	
		If !QEL->(dbSeek(xFilial("QEL")+cChave))  //Caso o Laudo exista, o mesmo nao sera criado
			
			If lQReinsp
				While QEL->(Eof()) .And. QEL->(QEL_FILIAL+QEL_FORNEC+QEL_LOJFOR+QEL_PRODUT+QEL_NISERI+QEL_TIPONF+DTOS(QEL_DTENTR)+QEL_LOTE) == xFilial("QEL")+cChave
					If QEL->QEL_NUMSEQ == QEK->QEK_NUMSEQ
						Exit
					Endif
					QEL->(dbSkip())
				Enddo				
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Define a data de validade do Laudo da Entrada				 ³
			//³ QE6_UNSHEL  1 = Dia											 ³
			//³ QE6_UNSHEL  2 = Mes											 ³
			//³ QE6_UNSHEL  3 = Ano											 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
			QE6->(dbSetOrder(1))
			QE6->(dbSeek(xFilial("QE6")+QEK->QEK_PRODUT+Inverte(QEK->QEK_REVI)))
			If QE6->(!Eof())
				If QE6->QE6_SHLF <> 0
					//Verifica a Unidade do Shelf-Life
					nDias := If(QE6->QE6_UNSHEL=="1",QE6->QE6_SHLF,;	 //Dia
						If(QE6->QE6_UNSHEL=="2",QE6->QE6_SHLF*30,;	 //Mes
						If(QE6->QE6_UNSHEL=="3",QE6->QE6_SHLF*365,0)))//Ano
						
					dValidade += nDias //Calcula a Validade do Laudo
				EndIf
			EndIf
			                
			//Grava o Laudo da Entrada	
			RecLock("QEL",.T.)
			QEL->QEL_FILIAL := xFilial("QEL")
			QEL->QEL_PRODUT := QEK->QEK_PRODUT
			QEL->QEL_REVI   := QEK->QEK_REVI
			QEL->QEL_FORNEC := QEK->QEK_FORNEC
			QEL->QEL_LOJFOR := QEK->QEK_LOJFOR
			QEL->QEL_DTENTR := QEK->QEK_DTENTR
			QEL->QEL_LOTE   := QEK->QEK_LOTE
			QEL->QEL_LABOR  := Space(TamSX3("QEL_LABOR")[1])
			QEL->QEL_TAMLOT := QEK->QEK_TAMLOT
			QEL->QEL_DTENLA := dDataBase
			QEL->QEL_HRENLA := Left(Time(),5)
			QEL->QEL_LAUDO  := cFatApr
			QEL->QEL_DTLAUD := dDataBase
			QEL->QEL_HRLAUD := Left(Time(),5)
			QEL->QEL_DTVAL  := dValidade
			QEL->QEL_JUSTLA := cQEL_JUSTLA 
			QEL->QEL_DTDILA := dDataBase
			QEL->QEL_HRDILA := Left(Time(),5)
			QEL->QEL_NISERI := QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF
			QEL->QEL_TIPONF := QEK->QEK_TIPONF
			QEL->QEL_NUMSEQ := QEK->QEK_NUMSEQ			
			MsUnLock()
						
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Obtem e grava o Codigo do Certificado de Qualidade			 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cCerQua := QA_SEQUSX6("QIE_CEQU",TamSX3("QEK_CERQUA")[1],"S",OemToAnsi(STR0021)) //"Certificado de Qualidade"
			
			RecLock("QEK",.F.)
				//Verifica se o numero do Certificado de Qualidade foi gerado corretamente	
				If Empty(cCerQua)
					QEK->QEK_VERIFI := 1	    //Situacao da Entrada como 'Inspecionar'
					QEK->QEK_SITENT := "1"     //Situacao da Entrada como 'Pendente'
					lRetorno := .F.            //tratar retorno como inspeç?o
				Else
					QEK->QEK_CERQUA := cCerQua //Numero do Certificado da Entrada
					QEK->QEK_SITENT := "2"     //Situacao da Entrada como 'Aprovado'
					lRetorno := .T.
				EndIf
			QEK->(MsUnLock())
			
        EndIf
        
	ElseIf nOpc == 2 //Exclusao
	
		If QEL->(dbSeek(xFilial("QEL")+cChave))  //Caso o Laudo exista, o mesmo nao sera criado
			RecLock("QEL",.F.,.T.)
			dbDelete()
			MsUnLock()
			lRetorno := .T.
		EndIf	
		
	EndIf
EndIf

RestArea(aAreaAnt)

Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³QieAtuSkpTst³Autor ³Paulo Emidio de Barros³ Data ³01/06/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza os registros do Skip-Teste						  ³±±
±±³			 ³ Obs.: Para utilizacao desta funcao, o registro do QEK, de- ³±±
±±³			 ³ 		 vera estar agravado e posicionado,caso contrario, o  ³±±
±±³			 ³ 		 Skip-Teste sera gravado incorretamente.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QieAtuSkpTst(EXPN1,EXPA1)						 		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPN1 = 1) Inclusao										  ³±±
±±³			 ³ 		   2) Exclusao										  ³±±
±±³			 ³ EXPA1 = Vetor com os Ensaios marcados com o Skip-Teste     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPL1 = T - Atualizou									  ³±±
±±³			 ³         F - Nao atualizou				  				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAQIE													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QieAtuSkpTst(nOpc,aEnsInsp)
Local lRetorno   := .T.
Local aAreaAnt   := GetArea()                                 
Local cSkpTes    := " "                         
Local cPsqSkpTst := " " 
Local cPsqSkpGrp := " "
Local nSkp       := 0  
Local cSeekQEY   := " "
Local cSeekQEZ   := " "
Local cNiseri	 := ""
If nOpc == 2  //Exclusao

	aEnsInsp := {} //define o vetor para as marcacoes
			
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Identifica os Ensaios referentes a Revisao do Produto		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QE7->(dbsetOrder(1))
	QE7->(dbSeek(xFilial("QE7")+QEK->(QEK_PRODUT+QEK_REVI))) 
	While QE7->(!Eof()) .And. QE7->QE7_FILIAL==xFilial("QE7") .And. QE7->(QE7_PRODUT+QE7_REVI)==QEK->(QEK_PRODUT+QEK_REVI)
		Aadd(aEnsInsp,{QE7->QE7_ENSAIO})
		QE7->(dbSkip())
	EndDo
	
	QE8->(dbsetOrder(1))
	QE8->(dbSeek(xFilial("QE8")+QEK->(QEK_PRODUT+QEK_REVI)))
	While QE8->(!Eof()) .And. QE8->QE8_FILIAL==xFilial("QE8") .And. QE8->(QE8_PRODUT+QE8_REVI)==QEK->(QEK_PRODUT+QEK_REVI)
		Aadd(aEnsInsp,{QE8->QE8_ENSAIO})
		QE8->(dbSkip())
	EndDo

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Controle do Skip-Teste: 1) Todas as Entradas       			 ³
//³                         2) Somente as Entradas Inspecionadas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSkpTes := GetMv("MV_QSKPTES")
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso o vetor com os ensaios marcados para o Skip-Teste nao   ³
//³ esteja definido, nao havera atualizacao do mesmo.			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (aEnsInsp==NIL) .Or. (Len(aEnsInsp)==0)
	lRetorno := .F.
EndIf
                                   
If lRetorno .And. ((cSkpTes=="1") .Or. (cSkpTes=="2" .And. QEK->QEK_VERIFI<>2))	
						
	// Atualiza os controles do skip-teste
	For nSkp := 1 to Len(aEnsInsp)
							
		//Verifica se h  skip-teste individual definido
		cPsqSkpTst := QEK->(QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT)+aEnsInsp[nSkp,1]
	
		QEH->(dbSetOrder(1))
		QEH->(MsSeek(xFilial("QEH")+cPsqSkpTst))
		If QEH->(!Eof())
								
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza o controle do Skip-Teste individual				   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			QEN->(dbSetOrder(1))
			QEN->(MsSeek(xFilial("QEN")+cPsqSkpTst))
			If QEN->(Eof())
				If nOpc == 1 //Atualizacao
					RecLock("QEN",.T.)
					QEN->QEN_FILIAL	:= xFilial("QEN")
					QEN->QEN_FORNEC	:= QEK->QEK_FORNEC
					QEN->QEN_LOJFOR	:= QEK->QEK_LOJFOR
					QEN->QEN_PRODUT	:= QEK->QEK_PRODUT
					QEN->QEN_ENSAIO	:= aEnsInsp[nSkp,1]
					QEN->QEN_CONTAD	:= 1
	    			QEN->(MsUnLock())
		        EndIf
			Else
				RecLock("QEN",.F.)
				If nOpc == 1 //Atualizacao
					QEN->QEN_CONTAD := aEnsInsp[nSkp,2]
						
				ElseIf nOpc == 2 //Exclusao
					QEN->QEN_CONTAD := If(QEN->QEN_CONTAD<>1,QEN->QEN_CONTAD--,QEH->QEH_SKPTES)
				EndIf	
				QEN->(MsUnLock())
			EndIf
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza o Historico do Skip-Teste individual				   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nOpc == 1 //Atualizacao
				If aEnsInsp[nSkp,2] == 1	 //Inspecionou a Entrada
					RecLock("QEY",.T.)
					QEY->QEY_FILIAL	:= xFilial("QEY")
					QEY->QEY_FORNEC	:= QEK->QEK_FORNEC
					QEY->QEY_LOJFOR	:= QEK->QEK_LOJFOR
					QEY->QEY_PRODUT	:= QEK->QEK_PRODUT
					QEY->QEY_DTENTR	:= QEK->QEK_DTENTR
					QEY->QEY_LOTE  	:= QEK->QEK_LOTE
					QEY->QEY_ENSAIO	:= aEnsInsp[nSkp,1]
					QEY->QEY_NTFISC := QEK->QEK_NTFISC
					//QEY->QEY_SERINF := QEK->QEK_SERINF
					SerieNfID ("QEY",1,"QEY_SERINF",,,,QEK->QEK_SERINF)
					QEY->QEY_ITEMNF := QEK->QEK_ITEMNF
					QEY->QEY_TIPONF := QEK->QEK_TIPONF
					QEY->(MsUnLock())
				EndIf
					
			ElseIf nOpc == 2 //Exclusao
				                                        
				//Subtrai o contador do Historico do Skip-Teste Individual
				cSeekQEY := QEK->(QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT+QEK_NTFISC+QEK_SERINF+QEK_ITEMNF+QEK_TIPONF+dTos(QEK_DTENTR)+QEK_LOTE)+aEnsInsp[nSkp,1]
				QEY->(dbsetOrder(4))
				QEY->(dbSeek(xFilial("QEY")+cSeekQEY))
				If QEY->(!Eof())
					RecLock("QEY",.F.)
					dbDelete()
					MsUnLock()
			    EndIf
				    
			EndIf
						
		Else                       
					
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Realiza a verificacao na exclusao do Skip-Teste por Grupo, so- ³
			//³ mente para a primeira ocorrencia do Documento de Entrada.      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lRetorno := QEK->QEK_SKLDOC
				
			If lRetorno
				
				//Verifica a existencia do Skip-Teste por grupo
				cPsqSkpGrp := QEK->(QEK_FORNEC+QEK_LOJFOR+QEK_GRUPO)+aEnsInsp[nSkp,1]					
	
				QEI->(dbSetOrder(1))
				QEI->(MsSeek(xFilial("QEI")+cPsqSkpGrp))
				If QEI->(!Eof())
							
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza o controle do skip-teste por Grupo					   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					QEO->(dbSetOrder(1))
					QEO->(MsSeek(xFilial("QEO")+cPsqSkpGrp))
					If QEO->(Eof())
						If nOpc == 1 //Atualizacao
							RecLock("QEO",.T.)
							QEO->QEO_FILIAL	:= xFilial("QEO")
							QEO->QEO_FORNEC	:= QEK->QEK_FORNEC
							QEO->QEO_LOJFOR	:= QEK->QEK_LOJFOR
							QEO->QEO_GRUPO 	:= QEK->QEK_GRUPO
							QEO->QEO_ENSAIO	:= aEnsInsp[nSkp,1]
							QEO->QEO_DTENTR	:= QEK->QEK_DTENTR
							QEO->QEO_CONTAD	:= 1 
							MsUnLock()            
						EndIf	
					Else
						RecLock("QEO",.F.)
						If nOpc == 1 //Atualizacao                  
							QEO->QEO_CONTAD := aEnsInsp[nSkp,2]    
							
						ElseIf nOpc == 2 //Exclusao
							QEO->QEO_CONTAD := If(QEO->QEO_CONTAD<>1,QEO->QEO_CONTAD--,QEI->QEI_SKPTES)
						EndIf
						MsUnLock()
	
					EndIf
								 
					//Armazena a Data da Entrada qual ensaio devera ser inspecionado
					If nOpc == 1 //Atualizacao
						If QEO->QEO_CONTAD==1 
							RecLock("QEO",.F.)
							QEO->QEO_DTENTR	:= QEK->QEK_DTENTR
							MsUnLock()
						EndIf
					EndIf	

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza o historico do Skip-Teste por Grupo				   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If nOpc == 1 //Atualizacao
						If aEnsInsp[nSkp,2]==1	//Indica que inspecionou
							RecLock("QEZ", .T.)
							QEZ->QEZ_FILIAL := xFilial("QEZ")
							QEZ->QEZ_FORNEC := QEK->QEK_FORNEC
							QEZ->QEZ_LOJFOR := QEK->QEK_LOJFOR
							QEZ->QEZ_GRUPO  := QEK->QEK_GRUPO
							QEZ->QEZ_DTENTR := QEK->QEK_DTENTR
							QEZ->QEZ_LOTE   := QEK->QEK_LOTE
							QEZ->QEZ_ENSAIO := aEnsInsp[nSkp,1]
							QEZ->QEZ_PRODUT := QEK->QEK_PRODUT
							QEZ->QEZ_NTFISC := QEK->QEK_NTFISC
							//QEZ->QEZ_SERINF := QEK->QEK_SERINF
							SerieNfID ("QEZ",1,"QEZ_SERINF",,,,QEK->QEK_SERINF)
							QEZ->QEZ_ITEMNF := QEK->QEK_ITEMNF 
//							QEZ->QEZ_NISERI := QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF								
							QEZ->QEZ_TIPONF := QEK->QEK_TIPONF
							MsUnLock()
						EndIf                            
					ElseIf nOpc == 2 //Exclusao
						                                                            
						cNiseri := QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF
						cSeekQEZ := QEK->(QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT)+cNiseri+QEK->(QEK_TIPONF+dTos(QEK_DTENTR)+QEK_LOTE)+aEnsInsp[nSkp,1]
						QEY->(dbsetOrder(3))
							
						//Subtrai o contador do Historico do Skip-Teste em Grupo
						QEZ->(dbSetOrder(1))
						QEZ->(dbSeek(xFilial("QEZ")+cSeekQEZ))
						If QEZ->(!Eof())
							RecLock("QEZ", .F.)
							dbDelete()
							MsUnLock()
						EndIf	
							
					EndIf
												
				EndIf
				
			EndIf
						
		EndIf
					
	Next nSkp
				
EndIf             
	      
RestArea(aAreaAnt)

Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³QieSitFornec³Autor ³Cleber Souza          ³ Data ³21/06/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se o Produto x Fornecedor não foi bloqueado atra- ³±±
±±³			 ³ ves do modulo de Inspeção de Processo.					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QieSitFornec(EXPC1,EXPC2,EXPC3,EXPL1)	         		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Codigo do Fornecedor								  ³±±
±±³			 ³ EXPC2 = Loja do Fornecedor							      ³±±
±±³			 ³ EXPC3 = Codigo do Produto							      ³±±
±±³			 ³ EXPL1 = Verifica se apresenta mensagens de erro.		      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPL1 = T - Fornecedor Liberado							  ³±±
±±³			 ³         F - Fornecedor Bloqueado			  				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAQIE													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QieSitFornec(cFornecedor,cLoja,cProduto,lMensagem)
   
Local lRet      := .T.
Local aAreaSB1  := SB1->(GetArea())
Local aAreaSA5  := SA5->(GetArea())
Local aAreaQEG  := QEG->(GetArea())
Local lVerifica := GetMV("MV_QBLQFOR",,"N") == "S"

lMensagem := If(lMensagem==NIL,.T.,lMensagem) 
     
//Verifica se o parametro MV_QBLQFOR indica que o fornecedor deve ser validado pela rotina.               
If !lVerifica
	Return(lRet)
EndIF	

//Validacao Produto
If cProduto == NIL .or. Empty(cProduto) 
	lRet := .F.
	If lMensagem
		Help(" ",1,"QESPROD") //"É Obrigatório Informar o Código do Produto."
	EndIf
EndIF
     
//Valida Fornecedor e Loja
If lRet   
	If (cFornecedor == NIL .or. Empty(cFornecedor)) .or. (cLoja == NIL .or. Empty(cLoja))
		lRet := .F.
		If lMensagem
			Help(" ",1,"QESFORN")  //É Obrigatório Informar o Código e Loja do Fornecedor.
		EndIf
	EndIF
EndIF

//Valida Amarração Produto x Fornecedor
If lRet
	dbSelectArea("SB1")
	dbSetOrder(1)
	If dbSeek(xFilial("SB1")+cProduto)                                  
		If RetFldProd(SB1->B1_COD,"B1_TIPOCQ")=='Q' //-- CQ Quality   
			dbSelectArea("SA5")
			dbSetOrder(1)
			If dbSeek(xFilial("SA5")+cFornecedor+cLoja+cProduto)
				If !Empty(SA5->A5_SITU)
					dbSelectArea("QEG")
					dbSetOrder(1)
					dbSeek(xFilial("QEG")+SA5->A5_SITU)
					If QEG->QEG_CATEG == "4" //Categoria para Produto x Fornecedor com Situacao: Nao-Habilitado
						lRet := .F.
						If lMensagem
							Help(" ",1,"QEBLOQF") //Não sera possivel incluir o produto pois o mesmo foi bloqueado para o Fornecedor selecionado devido bloqueio feito pela qualidade na Inspeção da Entrada. 
						EndIf
					EndIF
	        	EndIF
			EndIf
        EndIF
	Else                             
		lRet := .F.
		If lMensagem
			Help(" ",1,"QESPSB1")//Produto informado não esta cadastrado. 
		EndIf
	EndIF
EndIF            

RestArea(aAreaSB1)
RestArea(aAreaSA5)
RestArea(aAreaQEG)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QIEC050   ºAutor  ³Cicero Cruz         º Data ³  12/04/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validações do quality						                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Integração com Materias                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QIEVDOCENT(aCols)
Local aAreaSA5 := SA5->(GetArea())
Local lRet := .T.
Local nPosLF  := aScan(aHeader,{|x| AllTrim(x[2])=="D1_LOTEFOR"})
Local nPosCod := aScan(aHeader,{|x| AllTrim(x[2])=="D1_COD"})

//Posiciona na Amarracao Produto x Fornecedor

dbSelectArea("SA5")
dbSetOrder(2)
If dbSeek(xFilial("SA5")+aCols[n][nPosCod]+cA100For+cLoja)
	If !Empty(SA5->A5_SKPLOT) 
		If AllTrim(SA5->A5_SKPLOT) == "27" .AND. Empty(Alltrim(aCols[n][nPosLF]))
			lRet := .F.
			MsgInfo( OemToAnsi(STR0023), OemToAnsi(Capital(STR0003)) ) // "O Skip-Lote por Documento de Entrada esta ativado para este produto. Sera necessário informar o campo 'Lote Fornecedor' (D1_LOTEFOR)." ### "AVISO"
        EndIf
    EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a compatibilidade dos tamanho dos campos D1_LOTECTL x QEK_LOTE ³	
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If TamSX3("D1_LOTECTL")[1] != (TamSX3("QEK_LOTE")[1] - TamSX3("D1_NUMLOTE")[1] )
	Aviso(STR0028,OemToAnsi(STR0029),{"Ok"},3)//"O campo QEK_LOTE, deve ter o tamanho igual ao campo D1_LOTECTL + D1_NUMLOTE . Favor efetuar o ajuste do grupo de campo 069, conforme procedimentos descritos em Boletim Técnico."
	lRet := .F.	
EndIf

RestArea(aAreaSA5)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QieVldRef   ºAutor  ³Sandra Ribeiro     Data ³  15/12/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validação do campo A5_REFGRD                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Inspeção de Entradas                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßß
*/
Function QieVldRef() 

Local lRetu := .T.

If nModulo == 21
	lRetu := .F.	
EndIf

Return lRetu 


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QIEREINSP ³ Autor ³ Sergio S. Fuzinaka    ³ Data ³ 15.05.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Verifica se foi habilitado o Processo de Reinspecao de      ³±±
±±³          ³Produto no mesmo Dia.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QIEReinsp()

Local aArea		:= GetArea()
Local aAreaSIX	:= SIX->(GetArea())
Local lQReinsp	:= GetNewPar("MV_QREINSP",.F.)
Local lRet		:= .F.
Local cX2Uniq

If lQReinsp
	SIX->(dbSelectArea("SIX"))
	SIX->(dbSetOrder(1))
	If SIX->(dbSeek("QEL3"))
		If "QEL_NUMSEQ" $ Upper(SIX->CHAVE)
			lRet := .T.
		Else
			lRet := .F.
		Endif
	Endif
	If lRet
		If SIX->(dbSeek("QER5"))
			If "QER_NUMSEQ" $ Upper(SIX->CHAVE)
				lRet := .T.
			Else
				lRet := .F.
			Endif
		Endif
	Endif

	If lRet
		cX2Uniq := UPPER(ArrTokStr(FWFormStruct(3,"QEL",NIL,.F.)[6][2],"+"))
		If "QEL_NUMSEQ" $ cX2Uniq
			lRet := .T.
		Else
			lRet := .F.
		Endif
		If lRet
			cX2Uniq := UPPER(ArrTokStr(FWFormStruct(3,"QER",NIL,.F.)[6][2],"+"))
			If "QER_NUMSEQ" $ cX2Uniq
				lRet := .T.
			Else
				lRet := .F.
			Endif
		Endif
	Endif
	If !lRet
		MsgStop(OemToAnsi(STR0024)+CHR(13)+;			//"O processo de Reinspeção de Produto no mesmo Dia, foi habilitado através do parâmetro"
				OemToAnsi(STR0025)+CHR(13)+CHR(13)+;	//"'MV_QREINSP', porém há dados que não foram atualizados."
				OemToAnsi(STR0026),OemToAnsi(STR0027))	//"Favor executar os procedimentos descritos no Boletim Técnico Reinspeção de Produtos."##"ATENÇÃO!"
	Endif
Endif

RestArea(aAreaSIX)
RestArea(aArea)

Return( lRet )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    QieDescSkT ³ Autor ³ Marcos Wagner Jr      ³ Data ³ 07.04.20 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna a descrição do SkipTeste - Certificar ou Inspecionar³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function QieDescSkT(lAbrev,nSkipTeste,cFornece,cLoja,cProduto)
Local cRetorno   := ''
Local nRegAtual  := QEK->(Recno())
Local cNextAlias := GetNextAlias()
Local nContQEK   := 0
Local lPrimeiro	 := .T.

If lAbrev
	cRetorno := "CER"
Else
	cRetorno := OemToAnsi(STR0008) //"Certificar"
EndIf

cQuery := "SELECT R_E_C_N_O_ "
cQuery += " FROM " + RetSqlName("QEK") + " WHERE "
cQuery += " QEK_FILIAL = '" + xFilial("QEK") + "' AND "
cQuery += " QEK_FORNEC = '" + cFornece + "' AND "
cQuery += " QEK_LOJFOR = '" + cLoja + "' AND "
cQuery += " QEK_PRODUT = '" + cProduto + "' AND "
cQuery += " D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY R_E_C_N_O_ "
cQuery := ChangeQuery(cQuery)
cNextAlias := GetNextAlias()
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cNextAlias,.T.,.T.)
While !( (cNextAlias)->(Eof()) )
	If lPrimeiro
		If lAbrev														// Entradas 6
			cRetorno := "INS"											// Skip 5
		Else															// Ele testará passará todos os 6 Recno validando se são iguais			
			cRetorno := OemToAnsi(STR0007) //"Inspecionar"				// antes de abrir a tela d/ QIEA215
		EndIf

		lPrimeiro := .f.
	Else
		If nContQEK == nSkipTeste
			If lAbrev
				cRetorno := "INS"
			Else
				cRetorno := OemToAnsi(STR0007) //"Inspecionar"
			EndIf
			
			nContQEK := 0
		Else
			If lAbrev
				cRetorno := "CER"
			Else
				cRetorno := OemToAnsi(STR0008) //"Certificar"
			EndIf
		EndIf
	EndIf
	nContQEK++

	If (cNextAlias)->R_E_C_N_O_ == nRegAtual
		Exit //Quando achou o registro posicionado não há necessidade de continuar.
	EndIf
	(cNextAlias)->(dbSkip())
Enddo
(cNextAlias)->(dbCloseArea())

Return cRetorno