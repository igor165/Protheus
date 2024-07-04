#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH" 
#INCLUDE "QIPXFUN.CH"
#DEFINE PESQ_TOP  	5
#DEFINE PESQ_SKIP 	15
#DEFINE _CRLF		Chr(13)+Chr(10)
#DEFINE _TAB		Chr(11)

#DEFINE OBJ_LAUOPE 1
#DEFINE OBJ_FOLLAB 2
#DEFINE OBJ_ENSAIO 3
#DEFINE OBJ_MEDICA 4
#DEFINE OBJ_FOLNCC 5
#DEFINE OBJ_NCC    6
#DEFINE OBJ_INST   7
#DEFINE OBJ_LAUDO  8
#DEFINE OBJ_CRONIC 9
#DEFINE OBJ_LAUGER 10
#DEFINE OBJ_PLAMO  11
#DEFINE OBJ_SEQ    12

Static cVarlot := ""

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ QIPXFUN	³ Autor ³ Marcelo Pimentel      ³ Data ³ 09/03/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao de Especificacao de Produtos		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Siga Quality - Sigaqip                              		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³			ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data	³ BOPS ³  Motivo da Alteracao 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Paulo Emidio³20/07/00³------³Criacao da Funcao qCalPol para calculo de ³±±
±±³            ³        ³      ³valores em polegadas.					  ³±±
±±³Paulo Emidio³25/08/00³------³Reformulacao da qCalPol para o calculo de ³±±
±±³            ³        ³      ³valores em polegadas convencionado como   ³±±
±±³            ³        ³      ³"i".									  ³±±
±±³Paulo Emidio³29/08/00³Melhor³Inclusao da funcao qVrfCalPol.			  ³±±
±±³Paulo Emidio³29/08/00³------³Alteracao na qVrfCalPol para permitir a in³±±
±±³            ³        ³      ³clusao de qualquer valor em pol no cadas- ³±±
±±³            ³        ³      ³tro de Resultados.                        ³±±
±±³Cleber Souza³09/06/03³Meta  ³Inclusao da Rotina QPGrvAne que realiza a ³±±
±±³            ³        ³      ³gravacao dos documentos anexos na rotina  ³±±
±±³            ³        ³      ³de resultado.                             ³±±
±±³            ³        ³      ³Inclusao da rotina QPCarDA que carrega os ³±±
±±³            ³        ³      ³documentos anexos da rotina de resultados ³±±
±±³            ³        ³      ³que estao gravados na tabela QQJ.         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ QIPXDePr ³ Autor ³ Marcelo Pimentel      ³ Data ³ 09/03/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Mostra a Descricao do Produto (ultima revisao) do QP6 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QIPXDePr(ExpC1,ExpN1)									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Produto								  ³±±
±±³			 ³ ExpN1 = Tamanho da Descricao								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QIPXDePr(cPro, nTam)
nTam := Iif(nTam==NIL,Space(TamSX3("QP6_DESCPO")[1]),nTam)
QP6->(DbSetOrder(1))
QP6->(dbseek(xFilial("QP6") + cPro))
Return(QP6->QP6_DESCPO)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ QIPXDeEn ³ Autor ³ Marcelo Pimentel      ³ Data ³ 09/03/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna a Descricao do Ensaio 							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QIPXDeEn(ExpC1)											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Ensaio								      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QIPXDeEn(cEns)
Local cRet := Space(TamSX3("QPH_ENSAIO")[1])

If !Empty(cEns)
	QP1->(dbseek(xFilial("QP1") + cEns))
	cRet := QP1->QP1_DESCPO

EndIf

Return(cRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ QIPXDeGr ³ Autor ³ Marcelo Pimentel 	    ³ Data ³ 28/09/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna a Descricao do Grupo do Produto					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QIPXDeGr(ExpC1)											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Grupo 									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QIPXDeGr(cGrp)
Local cRet := Space(TamSX3("QP3_GRUPO")[1])

QP3->(dbseek(xFilial("QP3") + cGrp))
cRet := QP3->QP3_DESCRI
Return(cRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ QIPXDeCl ³ Autor ³ Marcelo Pimentel 	    ³ Data ³ 28/09/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna a Descricao do Cliente.							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QIPXDeCl(ExpC1)											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Cliente								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QIPXDeCl(cCli)
Local cRet := Space(TamSX3("A1_NOME")[1])

SA1->(dbseek(xFilial("SA1") + cCli))
cRet := SA1->A1_NREDUZ
Return(cRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ QIPXTipo ³ Autor ³ Marcelo Pimentel      ³ Data ³ 09/03/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Mostra a Tipo do Produto.                             	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QIPXTipo(ExpC1)             								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Produto								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Siga Quality - Celerina  								  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QIPXTipo(cProd)
SB1->(dbSeek(xFilial("SB1")+cProd))
Return(SB1->B1_TIPO)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ QA_UltRvG³ Autor ³ Marcelo Pimentel 	    ³ Data ³ 09.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna a ultima revisao vigente de um Grupo 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Grupo											  ³±±
±±³			 ³ ExpD1 = Data de Referencia 								  ³±±
±±³			 ³ ExpL1 = Indica se mostra mensagem de revisao nao disponivel³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QA_UltRvG(cGrp,dData,lmen)
Local cRet := "  "
dData := If(dData==NIL,dDataBase,dData)
lmen  := If(lMen==NIL,.t.,lMen)

QQC->(dbSetOrder(1))
QQC->(dbSeek(xFilial("QQC")+cGrp))
While !QQC->(eof()) .and. QQC->QQC_FILIAL+QQC->QQC_GRUPO==xFilial("QQC")+cGrp
	cRet := QQC->QQC_REVI
	If QQC->QQC_DTINI <= dData
		Exit
	EndIf
	QQC->(dbSkip())
EndDo
// Verifica se ha' rev. disponivel
If QQC->(Eof()) .or. QQC->QQC_FILIAL+QQC->QQC_GRUPO <> xFilial("QQC")+cGrp
	cRet := "  "
	If lMen
		//mudar help para: Grupo nÆo tem revisÆo dispon¡vel
		HELP(" ",1,"QA_NREVDIS",,cGrp,2,1) 	// Produto nao tem revisao disponivel
	EndIf
EndIf
Return(cRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³QA_VerNum2³ Autor ³ Marcelo Pimentel      ³ Data ³ 09/03/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se o valor digitado e' um numero valido           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QA_VerNum(@ExpC1) 										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Valor digitado									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±³			 ³ Obs.: Aceita numeros, sinal negativo e ',' ou '.' como se- ³±±
±±³			 ³ 		parador de casa decimal.							  ³±±
±±³			 ³ 		Devolve o numero sempre com a picture com ',' como    ³±±
±±³			 ³ 		separador de casa decimal. 							  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QA_VerNum2(cValor)

Local nTamTot := len(cValor),;
		nTam := len(alltrim(cValor)),;
		cSubs, lRetu := .t., nI := 1,;
		nChr := 0

// chr(105) = ( 1 )
// chr(44) = ( , )
// chr(45) = ( - )
// chr(46) = ( . )
// chr(47) = ( / )

While nI <= nTam .and. lRetu
	cSubs := Subs(alltrim(cValor),nI,1)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Consiste se e' caracter v lido.                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If asc(cSubs) <> 44 .and. asc(cSubs) <> 45 .and. asc(cSubs) <> 46 .and. ;
       (asc(cSubs) < 48 .or. asc(cSubs) > 57) .And. asc(cSubs) <> 105 .and. ;
		asc(cSubs) <> 47
		lRetu := .f.
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica a ocorrencia do ponto e virgula:					    ³
		//³ Nao aceita mais de 1 ponto, mais de 1 virgula, ou ponto e virgu-³
		//³ la ao mesmo tempo.											    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If asc(cSubs) == 46 .or. asc(cSubs) == 44
			If empty(nChr)
				nChr := nI
			Else
				lRetu := .f.
			Endif
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o sinal negativo esta' fora da 1a. posicao          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If asc(cSubs) == 45 .and. nI <> 1
			lRetu := .f.
		Endif
	Endif
	nI++
Enddo
If lRetu
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se digitou '.' como decimal, muda para ','                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cPaisLoc <> "MEX"
		cValor := StrTran(cValor,'.',',')
    Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se comecar com virgula, coloca zero antes						³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If cPaisLoc <> "MEX"
		If left(alltrim(cValor),1) == ','
			cValor := '0'+alltrim(cValor)
		ElseIf left(alltrim(cValor),2) == '-,'
			cValor := '-0'+right(alltrim(cValor),nTam-1)
		EndIf
	Else
		If left(alltrim(cValor),1) == '.'
			cValor := '0'+alltrim(cValor)
		ElseIf left(alltrim(cValor),2) == '-.'
			cValor := '-0'+right(alltrim(cValor),nTam-1)
		EndIf
	Endif
	cValor := padr(cValor,nTamTot)

EndIf

return(lRetu)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ QAFormula³ Autor ³ Alessandro B. Freire  ³ Data ³ 23.09.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta o cadastro de formulas para ensaios 				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QAFormula( NIL )											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Siga Quality												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION QAFormula(aEnsaio,cForm)
LOCAL oDlg
LOCAL oLbxEnsaio
LOCAL cEnsaio		:= ""
LOCAL aListEnsaio := aEnsaio
LOCAL cFormula 	:= Iif(cForm==NIL,"",cForm)
LOCAL oFormula
LOCAL oFontGet 	:= TFont():New("Arial",6,15,,.T.)
LOCAL oBmp
Local nC				:= 0
Local cFormAtu		:= ''

DEFINE MSDIALOG oDlg FROM	63,114 TO 396,600 TITLE OemToAnsi(STR0001) PIXEL //"F¢rmulas"

@ 6, 81 TO 91, 240 LABEL OemToAnsi(STR0002) OF oDlg  PIXEL //"Operadores"
@ 05,03 BITMAP oBmp RESOURCE "LOGIN" OF oDlg PIXEL SIZE 75,160
@ 16,89	LISTBOX oLbxEnsaio ;
			VAR	  cEnsaio	 ;
			ITEMS   aListEnsaio;
			SIZE	  92,73		 ;
			OF 	  oDlg PIXEL ;
			ON DBLCLICK ( ChangeForm(@cFormula, @oFormula,'#'+ cEnsaio + '#', .T., cEnsaio),SetFocus(oFormula:hWnd) )
@ 16, 184	BUTTON "("    ;
				SIZE 21, 11   ;
				OF oDlg PIXEL ;
				ACTION ChangeForm( @cFormula, @oFormula, "(" )
@ 16, 210	BUTTON ")"    ;
				SIZE 21, 11   ;
				OF oDlg PIXEL ;
				ACTION ChangeForm( @cFormula, @oFormula, ")" )
@ 30, 184	BUTTON "+"    ;
				SIZE 21, 11   ;
				OF oDlg PIXEL ;
				ACTION ChangeForm( @cFormula, @oFormula, "+" )
@ 30, 210	BUTTON "-"    ;
				SIZE 21, 11   ;
				OF oDlg PIXEL ;
				ACTION ChangeForm( @cFormula, @oFormula, "-" )
@ 44, 184	BUTTON "*"    ;
				SIZE 21, 11   ;
				OF oDlg PIXEL ;
				ACTION ChangeForm( @cFormula, @oFormula, "*" )
@ 44, 210	BUTTON "/"    ;
				SIZE 21, 11   ;
				OF oDlg PIXEL ;
				ACTION ChangeForm( @cFormula, @oFormula, "/" )
@ 59, 184	BUTTON STR0003 ; //"Raiz"
				SIZE 21, 11   ;
				OF oDlg PIXEL ;
				ACTION ChangeForm( @cFormula, @oFormula, "SQRT()" )

@ 59, 210	BUTTON STR0004  ; //"Abs"
				SIZE 21, 11   ;
				OF oDlg PIXEL ;
				ACTION ChangeForm( @cFormula, @oFormula, "ABS()" )

If !Alltrim(FunName())$"QIPA160/QIPA150"
	@ 74,184 	BUTTON OemToAnsi(STR0005)	; //"M‚dia"
				SIZE 21, 11   ;
				OF oDlg PIXEL ;
				ACTION ChangeForm( @cFormula, @oFormula, "AVG()" )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Botao de desvio utilizado somente no Modulo Insp. de Entrega    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nModulo == 21        // SIGAQIE
	@ 74,210 	BUTTON OemToAnsi(STR0010)	; //"Desvio"
					SIZE 21, 11   ;
					OF oDlg PIXEL ;
					ACTION ChangeForm( @cFormula, @oFormula, "DESVPAD()" )
EndIf

@ 96, 82 GET oFormula  ;
			VAR cFormula  ;
			SIZE 158, 50  ;
			OF oDlg PIXEL ;
			MEMO ON CHANGE oFormula:SetFocus()

oFormula:SetFont( oFontGet )

DEFINE SBUTTON FROM 149,180 TYPE 1 ACTION (QPValFor(cFormula,aEnsaio),oDlg:End()) ENABLE OF oDlg
DEFINE SBUTTON FROM 149,210 TYPE 2 ACTION (Iif(!Empty(cForm),cFormula:=cForm,cFormula:=""),OdLG:eND()) enable of OdLG


ACTIVATE MSDIALOG oDlg CENTERED
oFontGet:End()
For nC := 1 To Len(cFormula)
	If Asc(Substr(cFormula,nC,1)) <> 13 .And. Asc(Substr(cFormula,nC,1)) <> 10
		cFormAtu += Substr(cFormula,nC,1)
	EndIf
Next nC

Return(cFormAtu)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ChangeForm³ Autor ³ Alessandro B. Freire  ³ Data ³ 23.09.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Altera a formula conforme selecao na QAFormula()			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ ChangeForm( cFormula, oFormula, cTexto )					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cFormula -> Variavel que contem o conteudo da formula 	  ³±±
±±³			 ³ oFormula -> Objeto Get da formula						  ³±±
±±³			 ³ cTexto	-> Texto que deve ser inserido no GET da formula  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Siga Quality												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ChangeForm( cFormula, oFormula , cTexto , lIsListBox,cEns)

LOCAL nPosForm := 0
LOCAL cFim		:= AllTrim( SubStr( cFormula, nPosForm+1, Len(cFormula) ) )
LOCAL cInicio	:= AllTrim( SubStr( cFormula, 1, nPosForm ) )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Vetor serah acrescentado o desvio padrao somente no QIE         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL aVolta1	:= Iif(nModulo==21,{"SQRT()","ABS()","AVG()","DESVPAD()"},{"SQRT()","ABS()","AVG()"})

DEFAULT cEns := ""

lIsListBox := IIF( lIsListBox == NIL, .F., lIsListBox )

If ! lIsListBox
	SetFocus(oFormula:hWnd)
EndIf

If SubStr(cInicio,Len(cInicio),1) == "#" .And. SubStr(cTexto,1,1) == "#"
	MsgInfo( OemToAnsi(STR0006) ) //"Est  faltando o operador matem tico"
	Return(NIL)
EndIf

If SubStr(cInicio,Len(cInicio),1) == "#" .And. Ascan(aVolta1,cTexto) > 0
	MsgInfo( OemToAnsi(STR0006) ) //"Est  faltando o operador matem tico"
	Return(NIL)
EndIf

If SubStr(cInicio,Len(cInicio),1) $ ("+-*/") .And. cTexto $ ("+-*/")
	MsgInfo( OemToAnsi(STR0007) ) //"N„o ‚ poss¡vel inserir dois ou mais operadores matem ticos"
	Return(NIL)
EndIf

If SubStr(cInicio,Len(cInicio),1) $ ("0123456789") .And. ! (cTexto $ ("+-*/)"))
	MsgInfo( OemToAnsi(STR0006) ) //"Est  faltando o operador matem tico"
	Return(NIL)
EndIf

If AsCan(aVolta1,cFormula) > 0 .Or. subs(cformula,len(cformula)-1,2) == '()'
	cFormula := Subs(cFormula,1,Len(cFormula)-1)+cTexto+")"
Else
	cFormula := cFim+ AllTrim(cTexto)
EndIf
oFormula:Refresh()

Return(NIL)

function AQIP(lEspRet)
If lEspRet
	Return(QQB->QQB_CODIGO $ "01/02/03/04/S1/S2/S3/S4")
Else
	Return(.T.)
Endif

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³RetDesOper³ Autor ³ Fernando Godoy	    ³ Data ³ 2/4/1999 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna a descricao da Operacao							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Num da OP											  ³±±
±±³			 ³ExpC2 - Codigo da operacao para pesquisa					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ExpC3 - Descricao. 										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³Generico QIP 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Default	 ³""                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function RetDesOper(cNumOp,cOperacao,cProduto,cRevi)
Local cRet		:= ""
Local aArea 	:= GetArea()
Local cRoteiro := ""

Default cNumOp   := ""
Default cOperacao:= ""

dbSelectArea("SC2")
dbSetOrder(1)
If dbSeek(xFilial("SC2")+cNumOp)
	cRoteiro := Iif(Empty(SC2->C2_ROTEIRO),"01",SC2->C2_ROTEIRO)
	dbSelectArea("QQK")
	dbSetOrder(1)
	If dbSeek(xFilial("QQK")+cProduto+cRevi+cRoteiro+cOperacao)
		cRet := QQK->QQK_DESCRI
	EndIf
Endif

RestArea(aArea)
Return cRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A010DCla ³ Autor ³ Marcelo Pimentel      ³ Data ³ 05.03.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Fun‡Æo  para preencher a descricao da Classe NC pelo cod.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A010DCla(ExpC1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da Classe de NC                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Qipa010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A010DCla(cClasse)
QEE->(dbSeek(xFilial("QEE") + cClasse))
Return(QEE->QEE_DESCPO)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³QipxDNCo  ³ Autor ³Marcelo Pimentel       ³ Data ³ 29.11.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna a descricao da NC								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QipxDNCo(cCodNC)
SAG->(dbSetOrder(1))
SAG->(dbSeek(xFilial("SAG") + cCodNC)) // NC posicionada na getdados
Return(SAG->AG_DESCPO)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QIPXLdLU ³ Autor ³ Marcelo Pimentel      ³ Data ³ 21/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna se o Laudo tem Categoria Liberado Urgente          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QIPXLdLU(ExpC1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Laudo                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QIPXLdLU(cLaudo)
Local lRet		:= .F.
Local nOrdQPD	:= QPD->(IndexOrd())

QPD->(dbSetOrder(1))
QPD->(dbSeek(xFilial("QPD")+cLaudo))
If QPD->QPD_CATEG == "4"	// Liberado Urgente
	lRet := .T.
EndIf
QPD->(dbSetOrder(nOrdQPD))
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ qCalPol  ³ Autor ³ Paulo Emidio de Barros³ Data ³ 19/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Realiza calculo em polegadas             		          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³qCalPol(EXPA1,EXPN1,EXPC1)								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³EXPA1 = Array conteudo VALOR1 e VALOR2, sendo que:          ³±±
±±³          ³        na Subtracao, o VALOR2 e subtraido de VALOR1        ³±±
±±³          ³EXPN1 = 1 - Soma										      ³±±
±±³  		 ³ 		  2 - Subtrai   								      ³±±
±±³  		 ³EXPC1 = Campo a ser retornado                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function qCalPol(aValores,nOperac,cCampo)
Local nNumInt  := 0
Local nDenInt  := 0
Local nNumFrc  := 0
Local nDenFrc  := 0
Local cVlrInt  := ""
Local cVlrFrc  := ""
Local nPos	   := 0
Local nX       := 0
Local aVlrCal  := {}
Local nVlrNum  := 0
Local nVlrDen  := 0
Local cRetorno := ""

For nX := 1 to Len(aValores)

	nPos    := At('i',aValores[nX])
	cVlrInt := If(nPos>0,SubStr(aValores[nX],1,nPos-1),aValores[nX])
	cVlrFrc := If(nPos>0,SubStr(aValores[nX],nPos+1,Len(aValores[nX])-nPos),"0")

	nPos    := At('/',cVlrInt)
	nNumInt := Val(If(nPos>0,SubStr(cVlrInt,1,nPos-1),cVlrInt))
	nDenInt := Val(If(nPos>0,SubStr(cVlrInt,nPos+1,Len(cVlrInt)-nPos),"0"))

	nPos    := At('/',cVlrFrc)
	nNumFrc := Val(If(nPos>0,SubStr(cVlrFrc,1,nPos-1),cVlrFrc))
	nDenFrc := Val(If(nPos>0,SubStr(cVlrFrc,nPos+1,Len(cVlrFrc)-nPos),"0"))

	If     (Abs(nNumInt) > 0 .And. nDenInt == 0 .And. nNumFrc == 0 .And. nDenFrc == 0)
		Aadd(aVlrCal,{nNumInt,0})

	ElseIf (nNumInt == 0 .And. nDenInt == 0 .And. Abs(nNumFrc) > 0 .And. nDenFrc == 0)
        Aadd(aVlrCal,{nNumFrc,0})

	ElseIf (Abs(nNumInt) > 0 .And. nDenInt > 0 .And. nNumFrc == 0 .And. nDenFrc == 0)
		Aadd(aVlrCal,{nNumInt,nDenInt})

	ElseIf (nNumInt == 0 .And. nDenInt == 0 .And. Abs(nNumFrc) > 0 .And. nDenFrc > 0)
	    Aadd(aVlrCal,{nNumFrc,nDenFrc})

 	ElseIf (Abs(nNumInt) > 0 .And. nDenInt == 0 .And. nNumFrc > 0 .And. nDenFrc > 0)
 		If nNumInt > 0
	 		Aadd(aVlrCal,{(nDenFrc*nNumInt)+nNumFrc,nDenFrc})
	 	Else
	 		Aadd(aVlrCal,{(nDenFrc*nNumInt)-nNumFrc,nDenFrc})
	 	EndIf

 	ElseIf (nNumInt > 0 .And. nDenInt > 0 .And. Abs(nNumFrc) > 0 .And. nDenFrc == 0)
 		If nNumFrc > 0
 			Aadd(aVlrCal,{(nDenInt*nNumFrc)+nNumInt,nDenInt})
 		Else
 			Aadd(aVlrCal,{(nDenInt*nNumFrc)-nNumInt,nDenInt})
 		EndIf

	ElseIf (Abs(nNumInt) > 0 .And. nDenInt == 0 .And. Abs(nNumFrc) > 0 .And. nDenFrc == 0)
		Aadd(aVlrCal,{nNumInt+nNumFrc,0})

	Else
        Aadd(aVlrCal,{0,0})

	EndIf

Next

nVlrNum := 0
nVlrDen := 0

If     aVlrCal[1,2] >= aVlrCal[2,2]
	If aVlrCal[2,2] > 0
		If nOperac == 1
			nVlrNum := aVlrCal[1,1] + ((aVlrCal[1,2]/aVlrCal[2,2])*aVlrCal[2,1])
		Else
			nVlrNum := aVlrCal[1,1] - ((aVlrCal[1,2]/aVlrCal[2,2])*aVlrCal[2,1])
		EndIf
	Else
		If aVlrCal[1,2] > 0
			If nOperac == 1
				nVlrNum := aVlrCal[1,1] + ((aVlrCal[1,2]/1)*aVlrCal[2,1])
			Else
				nVlrNum := aVlrCal[1,1] - ((aVlrCal[1,2]/1)*aVlrCal[2,1])
			EndIf
		Else
			If nOperac == 1
				nVlrNum := (aVlrCal[1,1] + aVlrCal[2,1])
			Else
				nVlrNum := (aVlrCal[1,1] - aVlrCal[2,1])
			EndIf
		EndIf
	EndIf
	nVlrDen := aVlrCal[1,2]

ElseIf aVlrCal[2,2] > aVlrCal[1,2]
	If aVlrCal[1,2] > 0
		If nOperac == 1
			nVlrNum := ((aVlrCal[2,2]/aVlrCal[1,2])*aVlrCal[1,1]) + aVlrCal[2,1]
		Else
			nVlrNum := ((aVlrCal[2,2]/aVlrCal[1,2])*aVlrCal[1,1]) - aVlrCal[2,1]
		EndIf
	Else
		If aVlrCal[2,2] > 0
			If nOperac == 1
				nVlrNum := ((aVlrCal[2,2]/1)*aVlrCal[1,1]) + aVlrCal[2,1]
			Else
				nVlrNum := ((aVlrCal[2,2]/1)*aVlrCal[1,1]) - aVlrCal[2,1]
			EndIf
		Else
			If nOperac == 1
				nVlrNum := (aVlrCal[1,1] + aVlrCal[2,1])
			Else
				nVlrNum := (aVlrCal[1,1] - aVlrCal[2,1])
			EndIf
		EndIf
	EndIf
	nVlrDen := aVlrCal[2,2]
EndIf

If Abs(nVlrNum) >= Abs(nVlrDen)
	If Abs(nVlrDen) > 0
		nResto := Abs(nVlrNum%nVlrDen)
		If nResto > 0
		    cRetorno := AllTrim(Str(Int(nVlrNum/nVlrDen)))+'i'+AllTrim(Str(Int(nResto)))+"/"+AllTrim(Str(Int(nVlrDen)))
		Else
			cRetorno := AllTrim(Str(Int(nVlrNum/nVlrDen)))+'i'
		EndIf
	Else
		cRetorno :=AllTrim(Str(Int(nVlrNum)))+'i'
	EndIf
Else
	If Abs(nVlrNum) > 0
		cRetorno := AllTrim(Str(Int(nVlrNum)))+"/"+AllTrim(Str(Int(nVlrDen)))+'i'
	Else
		cRetorno := AllTrim(Str(Int(nVlrNum)))+'i'
	EndIf
EndIf

cRetorno := cRetorno+Space(Len(cCampo)-Len(cRetorno))

Return(cRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³QMaxVlrPol³ Autor ³ Paulo Emidio de Barros³ Data ³ 19/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Verifica o maior valor quando for polegadas                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³QMaxVlrPol(EXPC1,EXPN1)						              ³±±
±±³          ³EXPC1 = Campo a ser comparado com o QP7_NOMINA	          ³±±
±±³          ³EXPN1 = 1 - Verifica se Valor1 e maior que Valor2           ³±±
±±³          ³		  2 - Verifica se Valor1 e menor que o Valor Nominal  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GENERICO                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QMaxVlrPol(cCampo1,nMaiMen)
Local nNumInt  := 0
Local nDenInt  := 0
Local nNumFrc  := 0
Local nDenFrc  := 0
Local cVlrInt  := ""
Local cVlrFrc  := ""
Local nPos	   := 0
Local nX       := 0
Local aVlrCal  := {}
Local aValores := {}
Local nVlr1    := 0
Local nVlr2    := 0
Local lRetorno := .T.

//armazena os valores contidos no aCols em aValores
nX := Ascan(aHeader,{|x|x[2]=="QP7_NOMINA"})
Aadd(aValores,cCampo1)
Aadd(aValores,aCols[N,nX])

If At('i',aValores[1]) > 0 .And. At('i',aValores[2]) > 0
    For nX := 1 to Len(aValores)

		nPos    := At('i',aValores[nX])
		cVlrInt := If(nPos>0,SubStr(aValores[nX],1,nPos-1),aValores[nX])
		cVlrFrc := If(nPos>0,SubStr(aValores[nX],nPos+1,Len(aValores[nX])-nPos),"0")

		nPos    := At('/',cVlrInt)
		nNumInt := Val(If(nPos>0,SubStr(cVlrInt,1,nPos-1),cVlrInt))
		nDenInt := Val(If(nPos>0,SubStr(cVlrInt,nPos+1,Len(cVlrInt)-nPos),"0"))

		nPos    := At('/',cVlrFrc)
		nNumFrc := Val(If(nPos>0,SubStr(cVlrFrc,1,nPos-1),cVlrFrc))
		nDenFrc := Val(If(nPos>0,SubStr(cVlrFrc,nPos+1,Len(cVlrFrc)-nPos),"0"))

		If     (Abs(nNumInt) > 0 .And. nDenInt == 0 .And. nNumFrc == 0 .And. nDenFrc == 0)
			Aadd(aVlrCal,{nNumInt,0})

		ElseIf (nNumInt == 0 .And. nDenInt == 0 .And. Abs(nNumFrc) > 0 .And. nDenFrc == 0)
    	    Aadd(aVlrCal,{nNumFrc,0})

		ElseIf (Abs(nNumInt) > 0 .And. nDenInt > 0 .And. nNumFrc == 0 .And. nDenFrc == 0)
			Aadd(aVlrCal,{nNumInt,nDenInt})

		ElseIf (nNumInt == 0 .And. nDenInt == 0 .And. Abs(nNumFrc) > 0 .And. nDenFrc > 0)
		    Aadd(aVlrCal,{nNumFrc,nDenFrc})

	 	ElseIf (Abs(nNumInt) > 0 .And. nDenInt == 0 .And. nNumFrc > 0 .And. nDenFrc > 0)
 			If nNumInt > 0
		 		Aadd(aVlrCal,{(nDenFrc*nNumInt)+nNumFrc,nDenFrc})
		 	Else
	 			Aadd(aVlrCal,{(nDenFrc*nNumInt)-nNumFrc,nDenFrc})
		 	EndIf

	 	ElseIf (nNumInt > 0 .And. nDenInt > 0 .And. Abs(nNumFrc) > 0 .And. nDenFrc == 0)
 			If nNumFrc > 0
 				Aadd(aVlrCal,{(nDenInt*nNumFrc)+nNumInt,nDenInt})
	 		Else
 				Aadd(aVlrCal,{(nDenInt*nNumFrc)-nNumInt,nDenInt})
	 		EndIf

		ElseIf (Abs(nNumInt) > 0 .And. nDenInt == 0 .And. Abs(nNumFrc) > 0 .And. nDenFrc == 0)
			Aadd(aVlrCal,{nNumInt+nNumFrc,0})

		Else
    	    Aadd(aVlrCal,{0,0})
		EndIf

	Next

	//Verifica se o VALOR1 e menor que o VALOR2
	nVlr1 := aVlrCal[1,1]/If(aVlrCal[1,2]==0,1,aVlrCal[1,2])
	nVlr2 := aVlrCal[2,1]/If(aVlrCal[2,2]==0,1,aVlrCal[2,2])

	If nMaiMen == 1
		If nVlr1 > nVlr2
		    HELP(" ",1,"QA_VALINV")//O valor informado nao podera ser gravado
		    lRetorno := .F.
		EndIf
	Else
		If nVlr1 < 0
			HELP(" ",1,"QA_VALINV")//O valor informado nao podera ser gravado
			lRetorno := .F.
		EndIf
	EndIf

EndIf

Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³qVrfCalPol³ Autor ³ Paulo Emidio de Barros³ Data ³ 21/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida os Campos AFI,AFS,LIC e LSC, quando  os mesmos forem³±±
±±³          ³ informados em polegadas.                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ GENERICO													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function qVrfCalPol(cCampo,lVlrPol,lHelp)
Local cVar     := ""
Local nPosNml  := 0
Local nPosAsp  := 0
Local nPosBar  := 0
Local lRetorno := .T.
Local nOcoAsp  := 0
Local nOcoBar  := 0
Local nOcoDes  := 0
Local nIntPol  := 0
Local nDecPol  := 0
Local nX       := 0

Default lVlrPol := .T.
Default lHelp   := .T.

cVar    := If(ValType(cCampo)=="N",Lower(AllTrim(Str(cCampo))),Lower(AllTrim(cCampo)))
nPosNml := At('i',cVar)

If nPosNml == 0 .Or. !lVlrPol
	lRetorno := .T.
Else
	If nPosNml+1 < Len(AllTrim(cVar)) .And. !IsDigit(Substr(cVar,nPosNml+1,1))
		If lHelp
			MsgAlert(STR0008,STR0009) //"Valor em polegada está incorreto."###"Atenção"
		EndIf
		lRetorno := .F.
	Else
		If !( At('"',cVar) > 0 .Or. At("'",cVar) > 0 )
			If !Empty(cVar)
				If nPosNml > 0
					For nX := 1 to Len(cVar)
						If     SubStr(cVar,nX,1) == 'i'
							nOcoAsp++
						ElseIf SubStr(cVar,nX,1) == '/'
							nOcoBar++
						ElseIf !IsDigit(SubStr(cVar,nX,1))
						    nOcoDes++
						EndIf
					Next
					If nOcoAsp > 1 .Or. nOcoAsp == 0 .Or. nOcoBar > 1 .Or.;
					   nOcoDes > 1 .Or. At(" ",cVar) > 0
		    			lRetorno := .F.
					Else
						nPosAsp := At('i',cVar)
						nPosBar := At('/',cVar)
						If nPosBar > 0
							If nPosBar > nPosAsp
								nIntPol := Val(SubStr(cVar,nPosAsp+1,nPosBar-(nPosAsp-1)))
								nDecPol := Val(SubStr(cVar,nPosBar+1,Len(cVar)-nPosbar))
							Else
							    nIntPol := Val(SubStr(cVar,1,nPosBar-1))
							    nDecPol := Val(SubStr(cVar,nPosBar+1,nPosAsp-(nPosBar-1)))
							EndIf
							If nDecPol == 0
								lRetorno := .F.
							Else
								If lVlrPol
									nResto := 128%nDecPol
									If nResto > 0
										lRetorno := .F.
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		Else
			lRetorno := .F.
		EndIf
	EndIf
EndIf
Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³QP650DIC  ³ Autor ³ Marcelo Pimentel      ³ Data ³ 21/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza o campo Insp./Certifica atraves do campo C2_VERIFI³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ MATA650 - C2_INSCER - X3_WHEN					          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QP650DIC(nOpcao,lGatilho)
Local cRet	:= Space(TamSX3("C2_INSCER")[1])
lGatilho := Iif(lGatilho == NIL,.t.,lGatilho)

If Type("INCLUI") != "U"
	If !INCLUI .or. lGatilho
		If nOpcao == 1
			cRet := STR0011		//"Inspeciona"
		ElseIf nOpcao == 2
			cRet := STR0012		//"Certifica"
		EndIf
	EndIf
EndIf
Return(cRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QP650VldVe³ Autor ³ Marcelo Pimentel      ³ Data ³22/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida a situacao a ser aplicada na Producao  			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QP650VldVe(EXPN1)										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPN1 = Situacao a ser aplicada							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA650 - VALID C2_VERIFI								  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QP650VldVe(nVerifica)
Local lRetorno := .T.

If !(nVerifica == 1 .Or. nVerifica == 2)
	lRetorno := .F.
Else
	M->C2_INSCER := QP650DIC(nVerifica,.T.)
EndIf

Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Qp650His  ³ Autor ³ Marcelo Pimentel      ³ Data ³ 07.05.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastra Texto do Historico da Ordem de Producao           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Qp650His(ExpC1,ExpN1)                     				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Ensaio									  ³±±
±±³			 ³ ExpN1 = Opcao da rotina       							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ MATA650													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Qp650His(cNumero,cItem,cSequen,cChaveSC2,lResult)
Local aArea	   := GetArea()
Local cChave   := ""
Local cCabec   := STR0030	//"Observações da Ordem de Produção"
Local nTamLin  := TamSX3("QA2_TEXTO")[1]
Local cEspecie := "MATA650 "   //Utilizado para gravacao de textos
Local axtextos := {}			//Vetor que contem os textos dos Produtos
Local lEditObs := If(lResult==NIL,Iif(INCLUI .OR. ALTERA,.T.,.F.),.F.)
Local lGrava   := .F.

DEFAULT lResult	:= .F.

If ExistBlock("QP650HOP")
	ExecBlock("QP650HOP",.F.,.F.,{cNumero,cItem,cSequen,cChaveSC2})
Else

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera/obtem a chave de ligacao com o texto do Produto/Rv  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(cChaveSC2)
		cChave		:= QA_CvKey(xFilial("SC2")+cNumero+cItem+cSequen,"SC2", 5)
		cChaveSC2	:= cChave
		If lResult
			SC2->(dbSetOrder(1))
			If SC2->(dbSeek(xFilial("SC2")+cNumero+cItem+cSequen))
				Reclock("SC2",.F.)
				SC2->C2_CHAVE := cChave
				MsUnlock()
			EndIf
		Else
			M->C2_CHAVE	:= cChave
		EndIf
	Else
		cChave := cChaveSC2
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Digita o Texto do Produto    							 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lGrava := QA_TEXTO(cChave,cEspecie,nTamLin,STR0031,cNumero+cItem+cSequen,@axtextos,1,cCabec,lEditObs)	//"Ordem de Produção : "

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava Texto do Produto no QA2							 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lGrava
		QA_GrvTxt(cChave,cEspecie,1,@axtextos)
	EndIf
EndIf

RestArea(aArea)
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³QPNewPESQ ³ Autor ³ Marcelo Pimentel      ³ Data ³ 12/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua Pesquisa Especifica do Arquivo QPR - Cadastro Resul-³±±
±±³          ³ tados.                                  					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIPA220   										 		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QPNewPESQ(cAlias)
Local oDlg
Local oCbx
Local cOrd
Local oBigGet
Local oScroll
Local oDetail
Local dCampo
Local aSix2		:= {}
Local cTexto	:= ""
Local aOrd		:= {}
Local nC		:= 0
Local nOrdem	:= 0
Local nSavReg	:= 0
Local nI		:= 0
Local cCpofil	:= ""
Local nReg		:= 0
Local cFil		:= ""
Local nOrd		:= 1
Local lSeek		:= .F.
Local nChave	:= 1
Local aLista	:= {}
Local cCampo	:= Space(40)
Local lDetail	:= .F.
Local lUseDetail:= .F.
Local aAllLista := {}
Local nPos		:= 0
Private aPesqVar:= {}
Private aControl:= {}

DbSelectArea("SIX")
DbSetOrder(1)
DbSeek(cAlias)
While !EOF() .and. cAlias == INDICE
	nOrdem++
	If Substr(SixDescricao(),1,7) == "MBROWSE"
		cTexto := Stuff(Capital(SixDescricao()),1,8,"")
		AADD(aSix2,{AllTrim(cTexto),CHAVE,nOrdem,(cAlias)->(IndexKey(nOrdem))})
	EndIf
	DbSkip()
EndDo

For nC := 1 To Len(aSix2)
	Aadd(aOrd,aSix2[nC,1])
Next

DbSelectArea(cAlias)
cCpofil := PrefixoCpo(cAlias)+"_FILIAL"
nSavReg := Recno()

If cCpofil $ Indexkey()
	DbSeek(cFilial)
Else
	DbGoTop()
EndIf

If Eof()
	Help(" ",1,"A000FI")
	Return 3
EndIf
DbGoTo(nSavReg)

nOrd := 1
cOrd := aOrd[1]
cCampo:=SPACE(40)
For nI := 1 To Len(aOrd)
	aOrd[nI] := OemToAnsi(aOrd[nI])
Next

If IndexOrd() <= 1
	cOrd := aOrd[1]
	nOrd := 1
Else
	nPos := Ascan(aSix2, { |x| AllTrim(x[4]) = IndexKey() })
	cOrd := aSix2[nPos][1]
	nOrd := nPos
EndIf

DEFINE MSDIALOG oDlg FROM 00,00 TO 100,490 PIXEL TITLE OemToAnsi(STR0032)	//"Pesquisa"

@05,05 COMBOBOX oCBX VAR cOrd ITEMS aOrd SIZE 206,36 PIXEL OF oDlg FONT oDlg:oFont;

If ( lUseDetail )
	oCbx:bChange := {|| QPPesqChan(@nOrd,oCbx:nAt,@aLista,cAlias,@aAllLista,@oScroll,@lDetail,@oDetail,@oDlg,@oBigGet)}
Else
	oCbx:bChange := {|| nOrd := oCbx:nAt}
EndIf

@22,05 MSGET oBigGet VAR cCampo SIZE 206,10 PIXEL

@22,05 SCROLLBOX oScroll VERTICAL SIZE 84,205 OF oDlg BORDER
oScroll:Hide()

DEFINE SBUTTON FROM 05,215 TYPE 1 OF oDlg ENABLE ACTION (lSeek := .T.,oDlg:End())
DEFINE SBUTTON FROM 20,215 TYPE 2 OF oDlg ENABLE ACTION oDlg:End()

If ( lUseDetail )
	DEFINE SBUTTON oDetail FROM 35,215 TYPE 5 OF oDlg ENABLE ONSTOP STR0033 ACTION (lDetail := QPPesqDeta(lDetail,@oDlg,@oScroll,@oBigGet))	//"Detalhes"
	aLista := QPPesqLi(cAlias,nOrd,@AAllLista)
	oDlg:bStart := {|| QPPesqIn(@aLista,@oScroll,0,nOrd)}
EndIf

ACTIVATE MSDIALOG oDlg CENTERED

If ( lSeek )
	nOrd := aSix2[nOrd,3]

	If ( lDetail )
		cCampo := ""
		For nI := 1 To Len(aPesqVar[nOrd])
			If ( aLista[nI][2] == "C" .And. (Len(cCampo) <> aLista[nI][3]) )
				cCampo += Subs(aPesqVar[nOrd][nI],1,aLista[nI][3])
			ElseIf ( aLista[nI][2] == "D" )
				cCampo += Dtos(aPesqVar[nOrd][nI])
			ElseIf ( aLista[nI][2] == "N" )
				cCampo += Str(aPesqVar[nOrd][nI],aLista[nI][3],aLista[nI][4])
			Else
				cCampo += aPesqVar[nOrd][nI]
			EndIf
		Next
	EndIf
	cCampo := Trim("S"+cCampo)
	nReg := Recno()
	SET SOFTSEEK ON
	DbSetOrder(nOrd)
	If (PrefixoCpo(cAlias)+"_FILIAL") $ IndexKey()  //Procura pela filial
		cFil := cFilial
		nChave := 11
	EndIf

	If !lDetail .and. (("DTOS" $ Upper(IndexKey(nOrd))) .Or. ("DTOC" $ Upper(IndexKey(nOrd)))) .And. cAlias != "SM2"
		cCampo := ConvData(IndexKey(nOrd),cCampo)
	EndIf

	If Subs(cAlias,1,3) == "SM2"
		dCampo:=Ctod(AllTrim(cCampo))
		DbSeek(dCampo)
	EndIf
	If !((PrefixoCpo(cAlias)+"_FILIAL") $ IndexKey()) .And. !("SM2" $ cAlias)  //cAlias $ "SX6/SX9"
		DbSeek(cCampo)
	ElseIf cAlias != "SM2"
		DbSeek(cFilial+cCampo)
		If Subs(&(IndexKey()),1,2) != cFilial	 // IR Para EOF
			DbSeek(chr(255))
		EndIf
	EndIf

	If Eof()
		DbGoTo(nReg)
		Help(" ",1,"PESQ01")
	EndIf
	SET SOFTSEEK OFF
	lRefresh := .t.
Else
	Return 0
EndIf

Return(.t.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ QpPesqLi ³ Autor ³ Quality				³ Data ³ 12/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna a estrutura de um arquivo						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIPA220   										 		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function QPPesqLi(cAlias,nOrd,aAllLista)
Local aArea := GetArea()
Local aReturn := {}, nI := 1
Local cChave, nAt1, cString, nAt2
Local cF3 := ""
Local nPos

nPos := Ascan(aAllLista,{|x| x[1] == nOrd})

If ( nPos == 0 )
	DbSelectArea("SIX")
	If DbSeek(cAlias)
		While ( !Eof() .And. SIX->INDICE == cAlias .And. nI < nOrd)
			DbSkip()
			nI++
		End
		nI := 0
		If ( SIX->INDICE == cAlias )
			cString := SIX->CHAVE
			While ( !Empty(cString) )
				nAt1 := At("+",cString)
				If ( nAt1 == 0 )
					cChave := AllTrim(cString)
					cString := ""
				Else
					cChave := AllTrim(Subs(cString,1,nAt1-1))
					cString := Subs(cString,nAt1+1)
				EndIf
				nAt1 := At("(",cChave)
				If ( nAt1 <> 0 )
					nAt2 := At(",",cChave)
					If nAt2 == 0
						nAt2 := At(")",cChave)
					EndIf
					cChave := AllTrim(Subs(cChave,nAt1+1,nAt2-nAt1-1))
				EndIf
				If !( "FILIAL"$cChave)
					nI++
					cF3 := QPPesqF3(SIX->F3,nI)
					cChave	:= GetSx3Cache(cChave, "X3_CAMPO")
					If !Empty(cChave)
						Aadd(aReturn,{cF3, GetSx3Cache(cChave, "X3_TIPO"), GetSx3Cache(cChave, "X3_TAMANHO"), GetSx3Cache(cChave, "X3_DECIMAL"), QAGetX3Tit(cChave), GetSx3Cache(cChave, "X3_PICTURE") })
					Else
						aReturn := {}
						Exit
					EndIf
				EndIf
			End
		EndIf
	EndIf
	Aadd(aAllLista,{nOrd,Aclone(aReturn)})
Else
	aReturn := Aclone(aAllLista[nPos][2])
EndIf

RestArea(aArea)
Return aReturn

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ QPPesqF3 ³ Autor ³ Quality				³ Data ³ 12/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Pesquisa F3												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIPA220   										 		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function QPPesqF3(cString,nPos)
Local cReturn := ""
Local i := 0, nAt

If !Empty(cString)
	While ( i <= nPos )
		i++
		nAt := At("+",cString)
		If ( nAt == 0 )
			cReturn := Trim(cString)
			cString := ""
		Else
			cReturn := Trim(Subs(cString,1,nAt-1))
			cString := Subs(cString,nAt+1)
		EndIf

		If i == nPos
			If cReturn == "XXX"
				cReturn := ""
			EndIf
			Exit
		EndIf
	End
EndIf
Return cReturn

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³QPPesqDeta³ Autor ³ Quality				³ Data ³ 12/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizado no objeto para exclusao						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIPA220   										 		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function QPPesqDeta(lDetail,oDlg,oScroll,oBigGet)

oDlg:CoorsUpdate()

lDetail := !lDetail
If ( lDetail )
	oBigGet:Hide()
	oScroll:Show()
	oDlg:Move(oDlg:nTop,oDlg:nLeft,498,250)
Else
	oScroll:Hide()
	oBigGet:Show()
	oDlg:Move(oDlg:nTop,oDlg:nLeft,498,127)
EndIf

Return lDetail

Static Function QPPesqIn(aLista,oFather,nAnt,nAtu)
Local oGet, oSay, nWidth, bGet, lCria
Local i, nTop, cVar, cPict
Local lRet := .F.

If nAtu > 0
	If (nAnt <> 0)
		If !Empty(aControl[nAnt])
			For i := 1 To Len(aControl[nAnt])
				aControl[nAnt][i]:Hide()
			Next
		EndIf
	EndIf

	lRet := !Empty(aLista)

	If ( lRet )
		If Len(aControl) < nAtu
			For i := 1 to nAtu
				If Len(aControl) < i
					Aadd(aControl,{})
					Aadd(aPesqVar,{})
				EndIf
			Next
			lCria := .T.
		ElseIf Empty(aControl[nAtu])
			lCria := .T.
		EndIf

		If lCria
			lRet := Ascan(aLista,{|x| Empty(x)}) == 0
			If ( lRet )
				aPesqVar[nAtu] := Array(Len(aLista))
				For i := 1 To Len(aLista)
					nTop := PESQ_TOP+((i-1)*PESQ_SKIP)
					cVar := "aPesqVar["+StrZero(nAtu, 2)+"]["+StrZero(i, 2)+"]"
					cGet  := "{ | u | If( PCount() == 0, "+cVar+","+cVar+" := u)}"
					If ( aLista[i][2] == "D" )
						cPict := "@D"
						aPesqVar[nAtu][i] := Ctod("")
						nWidth := 40
					Else
						If aLista[i][2] == "C"
							aPesqVar[nAtu][i] := Space(aLista[i][3])
						ElseIf aLista[i][2] == "N"
							aPesqVar[nAtu][i] := 0
						EndIf
						cPict := If(Empty(aLista[i][6]),NIL,AllTrim(aLista[i][6]))
						nWidth := CalcFieldSize(aLista[i][2],aLista[i][3],0,," ")
					EndIf

					If '"'$aLista[i][5]
						bGet := &("{|| '"+OemToAnsi(aLista [i][5])+"'}")
					Else
						bGet := &('{|| "'+OemToAnsi(aLista [i][5])+'"}')
					EndIf

					oSay := TSay():New(nTop, 10, bGet,oFather,,, .F., .F., .F., .T.,,, GetTextWidth(0,Trim(aLista [i][5])), 15, .F., .F., .F., .F., .F. )
					nWidth += 10
					nWidth := Iif(nWidth > 130,130,nWidth)
					If ( Empty(aLista[i][1]) )
						oGet := TGet():New(nTop, 70, MontaBlock(cGet),oFather,nWidth,10,cPict,,,,,.F.,, .T.,, .F.,, .F., .F.,, .F., .F.,,cVar,,,,.T.)
					Else
						oGet := TGet():New(nTop, 70, MontaBlock(cGet),oFather,nWidth,10,cPict,,,,,.F.,, .T.,, .F.,, .F., .F.,, .F., .F.,aLista[i][1],cVar,,,,.T.)
					EndIf

					Aadd(aControl[nAtu],oSay)
					Aadd(aControl[nAtu],oGet)
				Next
			EndIf
		Else
			For i := 1 To Len(aControl[nAtu])
				aControl[nAtu][i]:Show()
			Next
		EndIf
	EndIf
EndIf
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³QPPesqChan³ Autor ³ Quality				³ Data ³ 12/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizado no objeto change								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIPA220   										 		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function QPPesqChan(nOrd,nAt,aLista,cAlias,aAllLista,oScroll,lDetail,oDetail,oDlg,oBigGet)

If ( nOrd <> nAt )
	aLista := QPPesqLi(cAlias,nAt,@aAllLista)
	If QPPesqIn(@aLista,@oScroll,nOrd,nAt)
		If ( oDetail <> NIL )
			oDetail:Enable()
		EndIf
	Else
		If ( oDetail <> NIL )
			lDetail := .T.
			lDetail := QPPesqDeta(lDetail,@oDlg,@oScroll,@oBigGet)
			oDetail:Disable()
		EndIf
	EndIf
	nOrd := nAt
EndIf
Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QipAnexo   ³ Autor ³ Cleber de Souza     ³ Data ³ 02/06/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta Tela com os Anexos na tela de Resultados QIE/QIP     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QipAnexo(cAlias,nOpc,aDocAne)							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero da opcao                                    ³±±
±±³          ³ ExpA1 = Array com os anexos                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QipAnexo(cAlias, nOpc, lPodeEdt)
Local lLayout     := GetMv("MV_QPTRLAY",.F.,"1") == "1"
Local oDlg
Local aButtons    := {}
Local cLabor      := ""
Local cEnsaio     := ""
Local cOper       := ""
Local nPos        := 0
Local lInclui     := .F.
Local nOpcao      := IIF(nOpc == 2, 2, 4)
Local cSeek
Local cWhile

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Esta variavel salva a marca de exclusao da primeira linha no ³
//³ aCols se a mesma estiver como verdadeiro, este tratamento e  ³
//³ realizado, pois se o primeiro item do aCols estiver excluido ³
//³ a Getdados falha na pintura do item marcado para exclusao    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Private cAliasAnex:= ""
Private oGetDoc

Default lPodeEdt  := .T.

If !lLayout
	nFldOpe   := 2
	nOperacao := nPosOper
	nFldLab	  := nPosLab
	nEnsaio	  := oBrwJJ:nAt
Else
	If nFldOpe#2
		Return(.t.)
	EndIf
Endif

aHeaderAnt := aClone(aHeader)
aColsAnt   := aClone(aCols)
aHeader    := {}
aCols      := {}
aHeadAne   := {}
aColsAne   := {}

cAliasAnex := "QQJ"
cOper	   := aResultados[nOperacao,1]
cEnsaio	   := aResultados[nOperacao,3,nFldLab,nEnsaio,2]
cLabor     := aResultados[nOperacao,2,nFldLab]

aColsAne := aClone(aResultados[nOperacao,8,nFldLab,nEnsaio])

If Len(aColsAne) == 0 .OR. ( Len(aColsAne) == 1 .AND. Empty(aColsAne[1][2]) )
	dbSelectArea(cAliasAnex)
	dbSetOrder(1)
	If !dbSeek(xFilial("QQJ")+cOper+cLabor+cEnsaio+Iif(lLayout,M->QPK_OP,QPK->QPK_OP))
		aColsAne:={}
		lInclui := .T.
	EndIf
EndIf
cSeek  := xFilial("QQJ")+cOper+cLabor+cEnsaio+Iif(lLayout,M->QPK_OP,QPK->QPK_OP)
cWhile := "QQJ_FILIAL+QQJ_OPERAC+QQJ_LABOR+QQJ_ENSAIO+QQJ_OP"

If lInclui .And. nOpcao != 2
	FillGetDados(nOpcao,"QQJ" ,1     ,cSeek,{|| &cWhile} ,         ,         ,          ,        ,      ,           ,        ,          ,        ,          ,           ,            ,)
    //FillGetDados(nOpcao,Alias ,nOrdem,cSeek ,bSeekWhile   ,uSeekFor ,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols  ,lEmpty  ,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry
Else
	//Recuperando aCols em aResultados
	If Len(aColsAne) == 0
		FillGetDados(4   ,"QQJ" ,1     ,cSeek,{|| &cWhile} ,         ,         ,          ,        ,      ,           ,        ,          ,        ,          ,           ,            ,)
	    //FillGetDados(nOpc,Alias ,nOrdem,cSeek ,bSeekWhile   ,uSeekFor ,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols  ,lEmpty  ,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry
	Else
		aHeadAne := aClone(aSavaHeader[3])
	EndIf
EndIf

If Len(aColsAne) == 0
	aHeadAne := aClone(aHeader)
	aColsAne := aClone(aCols)
EndIf

nPos       := ascan(aHeadAne,{|x| Upper(Alltrim(x[2])) == "QQJ_ANEXO" })

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0034) FROM 000,000 TO 315,625 OF oMainWnd PIXEL  //"Documento Anexo"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao da GetDados da Rastreabilidade				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetDoc := MsNewGetDados():New(033,002,155,312,Iif(Altera .Or. Inclui, GD_INSERT+GD_DELETE+GD_UPDATE, 0),"QipAneLinOk('"+cAlias+"')","QipAneTudoOk('"+cAlias+"')","",,,,,,,oDlg,aHeadAne,aColsAne)
oGetDoc:Refresh()

If lPodeEdt
	oGetDoc:lInsert := .T.
	oGetDoc:lDelete := .T.
Else
	oGetDoc:lInsert := .F.
	oGetDoc:lDelete := .F.
EndIf

Aadd(aButtons,{"PARAMETROS",{||oGetDoc:aCols[oGetDoc:nAT,nPos] := QVRFANEXO(nOpc,oGetDoc:aCols[oGetDoc:nAT,nPos],"QIP"),oGetDoc:Refresh()},OemToAnsi(STR0035),OemToAnsi(STR0036)}) //"Incluir / Visualizar Documento Anexo" ### "Doc.Anex"

If (nOpc == 3 .Or. nOpc == 4 )
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||If(oGetDoc:TudoOk() .And. QipGrvAnexo(oGetDoc:aCols) ,oDlg:End(),.F.)},{||oDlg:End()},,aButtons) CENTERED
Else
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()},,aButtons)
EndIf

aHeader := {}
aCols   := {}
aHeader := aClone(aHeaderAnt)
aCols   := aClone(aColsAnt)
Return(NIL)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³QipAneLinOk³ Autor ³ Cleber de Souza      ³ Data ³ 06/06/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consistencia para mudanca/inclusao de linhas nos Anexos	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QipAneLinOk                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QipAneLinOk(cAlias)
Local lRet   := .T.
Local nPosD  := Ascan(oGetDoc:aHeader,{|x| Upper(Alltrim(x[2])) == "QQJ_DESCRI"})
Local nPosA  := Ascan(oGetDoc:aHeader,{|x| Upper(Alltrim(x[2])) == "QQJ_ANEXO"})

If aCols[n,Len(oGetDoc:aHeader)+1] == .F.
	If Empty(oGetDoc:aCols[N,nPosD]) .Or. Empty(oGetDoc:aCols[N,nPosA])
		Help(" ",1,"QDOBRIG") // "Existem campos obrigatorios nao preenchidos"
	   	lRet:= .F.
	EndIf
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³QipAneTudoOk³ Autor ³ Cleber de Souza     ³ Data ³ 06/06/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consistencia Ok da GetDados nos Anexos                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QipAneTudoOk                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QipAneTudoOk(cAlias)
Local lRet   := .T.
Local nY     := 0
Local nPosD  := Ascan(oGetDoc:aHeader,{|x| Upper(Alltrim(x[2])) == "QQJ_DESCRI"})
Local nPosA  := Ascan(oGetDoc:aHeader,{|x| Upper(Alltrim(x[2])) == "QQJ_ANEXO"})

For nY:=1 to Len(oGetDoc:aCols)
	If !aCols[nY,Len(oGetDoc:aHeader)+1]
		If Empty(oGetDoc:aCols[nY,nPosD]) .Or. Empty(oGetDoc:aCols[nY,nPosA])
			Help(" ",1,"QDOBRIG") // "Existem campos obrigatorios nao preenchidos"
		   	lRet:= .F.
		EndIf
	EndIf
Next nY

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³QipGrvAnexo³ Autor ³ Cleber de Souza      ³ Data ³ 06/06/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava Array com os Anexos.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QipGrvAnexo(nOpc,cLabor,cEnsaio,cOper,cAlias)		      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Numero da opcao                                    ³±±
±±³          ³ ExpC2 = Codigo do Laboratorio                              ³±±
±±³          ³ ExpC3 = Codigo do Ensaio                                   ³±±
±±³          ³ ExpC4 = Codigo da Operacao                                 ³±±
±±³          ³ ExpC5 = Alias do Modulo                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QipGrvAnexo(aCols)
Local lLayout     := GetMv("MV_QPTRLAY",.F.,"1") == "1"

If !lLayout
	nFldOpe   := 2
	nOperacao := nPosOper
	nFldLab	  := nPosLab
	nEnsaio	  := oBrwJJ:nAt
EndIf

//Salvando aCols em aResultados
aResultados[nOperacao,8,nFldLab,nEnsaio] := aClone(aCols)

//Salvando aCols para que o usuario possa
//modificar os dados antes de gravar
aColsAne := aClone(aCols)

Return .t.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³QPCarDA   ³ Autor ³ Cleber Souza          ³ Data ³ 09/06/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina que carrega a variavel aDocAne com os Documentos    ³±±
±±³          ³ em anexo do Resultado.                  			    	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da Operacao                                 ³±±
±±³          ³ ExpA2 = Array com os Documentos Anexos.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIPA220   										 		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QPCarDA(cOP,aDocAne)
Local nPosOpe  := 0
Local nPosLab  := 0
Local nPosEns  := 0
Local nY       := 0
Local aHeadTmp := aClone(APBuildHeader("QQJ"))
Local nCpoQQJ  := 0
Local aCpo

//Verifica se possui documentos anexo
dbSelectArea("QQJ")
dbSetOrder(2)
If dbSeek(xFilial("QQJ")+cOP)
	While QQJ->(!EOF()) .and. QQJ->QQJ_OP == cOP

		//Verifica se Existe operacao
		nPosLab := 0
		nPosEns := 0
		nPosOpe:= ascan(aDocAne,{|x| Upper(Alltrim(x[1])) == QQJ->QQJ_OPERAC})

		If nPosOpe== 0
			AADD(aDocAne,{QQJ->QQJ_OPERAC,{}})
			AADD(aDocAne[Len(aDocAne),2],{QQJ->QQJ_LABOR,{}})
			AADD(aDocAne[Len(aDocAne),2,1,2],{QQJ->QQJ_ENSAIO,{}})
			aCpo := {}
		    For nCpoQQJ := 1 to Len(aHeadTmp)
				If (aHeadTmp[nCpoQQJ,10] <> "V")
					Aadd(aCpo,&(FieldName(FieldPos(AllTrim(aHeadTmp[nCpoQQJ,2])))))
				EndIf
			Next nCpoQQJ
			Aadd(aCpo,.F.)
			AADD(aDocAne[Len(aDocAne),2,1,2,1,2],aClone(aCpo))

		Else
			//Verifica se Existe Laboratorio para essa Operacao
			For nY:=1 to Len(aDocAne[nPosOpe,2])
				If aDocAne[nPosOpe,2,nY,1] == QQJ->QQJ_LABOR
					nPosLab := nY
					Exit
				EndIf
			Next nY
			If nPosLab == 0
				AADD(aDocAne[nPosOpe,2],{QQJ->QQJ_LABOR,{}})
				nPosLab := Len(aDocAne[nPosOpe,2])
			EndIf

			//Verifica se Existe Ensaio pro Laboratorio
			For nY:=1 to Len(aDocAne[nPosOpe,2,nPosLab,2])
				If aDocAne[nPosOpe,2,nPosLab,2,nY,1] == QQJ->QQJ_ENSAIO
					nPosEns := nY
					Exit
				EndIf
			Next nY
			If nPosEns == 0
				AADD(aDocAne[nPosOpe,2,nPosLab,2],{QQJ->QQJ_ENSAIO,{}})
				nPosEns := Len(aDocAne[nPosOpe,2,nPosLab,2])
			EndIf
			aCpo := {}
		    For nCpoQQJ := 1 to Len(aHeadTmp)
				If (aHeadTmp[nCpoQQJ,10] <> "V")
					Aadd(aCpo,&(FieldName(FieldPos(AllTrim(aHeadTmp[nCpoQQJ,2])))))
				EndIf
			Next nCpoQQJ
			Aadd(aCpo,.F.)
			AADD(aDocAne[nPosOpe,2,nPosLab,2,nPosEns,2],aClone(aCpo))

		EndIf

		QQJ->(dbSkip())
	EndDo
EndIf

Return(aDocAne)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QIPLOAD  ³ Autor ³ Cleber Souza 			³ Data ³ 05/01/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotinas que sao executadas ao entrar no modulo.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QIPLOAD()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaQIP		                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QIPLOAD()

Local aArea := GetArea()
Private lAltEsp :=.F.

QA_TRAVUSR()

AjCargaQPF()	//Efetua o ajuste na carga na tabela QPF - Skip-Lote

RestArea(aArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QIPRevRot   ³ Autor ³ Paulo Emidio de Barros³Data³05/01/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Devolve: Grupo, Revisao e o Roteiro de Operacoes de Acordo ³±±
±±³			 ³ com a Revisao da Especificacao do Produto.			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QIPRevRot(cProduto)   									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA650.PRX - Integracao com o SIGAQIP                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QIPRevRot(cProduto,lPsQP6)
Local aAreaQP6 := QP6->(GetArea())
Local cRoteiro := Space(TamSx3("QP6_CODREC")[1])
Local cRevisao := " "
Local cGrupo   := " "
Local aRetorno := {}

Default lPsQP6 := .F.

//Retorna a ultima revisao do Produto
cRevisao := QA_UltRevEsp(cProduto,,,,"QIP")

If !Empty(cRevisao)

	cRoteiro := QP6->QP6_CODREC

	//pesquisa a ultima revisao do Produto
	dbSelectArea("QP6")
	dbSetOrder(1)
	dbSeek(xFilial("QP6")+cProduto+Inverte(cRevisao	))
	If !Eof()

		//Verifica se o produto esta definido em algum Grupo
		QPA->(dbSetOrder(2))
		QPA->(dbSeek(xFilial("QPA")+cProduto))
		If QPA->(!Eof())
			cGrupo := QPA->QPA_GRUPO
		EndIf

	EndIf
EndIf

Aadd(aRetorno,cRevisao) //Revisao da Especificacao do Produto ou Grupo
Aadd(aRetorno,cRoteiro) //Roteiro da Especificacao do Produto ou Grupo
Aadd(aRetorno,cGrupo)   //Grupo de produtos definido

If !lPsQP6
	RestArea(aAreaQP6)
Endif

Return(aRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QIPAtualiza ³ Autor ³ Paulo Emidio de Barros³Data³14/10/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza o registro de Inspecao para a Ordem de Producao   ³±±
±±³			 ³ ou Apontamento de Producao.								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QIPAtualiza(EXPC1,EXPN1)									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Alias posicionado								  ³±±
±±³			 ³ EXPN1 = 1-Atualizacao 2-Exclusao				 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ EXPL1 = T-Atualiza F-Nao atualiza						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Integracao QIP x PCP	x EST				  				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QIPAtualiza(cAlias,nOpc)
Local aAreaAnt := GetArea()
Local cChave   := " "
Local lRetorno := .T. //Flag de Retorno da Integracao
Local cRevisao := " "
Local cRoteiro := " "
Local cCodPro  := " "
Local cCerQua  := " "
Local cKeyLote := " "
PRIVATE lAltEsp		:= .F. // Indica se ‚ a 1a. Entrada ap¢s alteracao especificacao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Indica onde sera realizada a Inspecao do Material, quando houver   ³
//³ integracao entre o QIP e PCP,sendo as seguintes opcoes:			   ³
//³ 1 - Ordens de Producoes											   ³
//³ 2 - Apontamento das Producoes									   ³
//³ 3 -																   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cInspecao := GetMV("MV_QINSPEC",.T.,"1")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualizacao da Ordem de Producao  								   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (cAlias=="SC2" .And. nOpc==1 .And. cInspecao=="1" .And. SC2->C2_TPOP=="F" .And. QPInsOPInt(cAlias))

	//Atualizacao do Registro da Inspecao da Ordem de Producao
	dbSelectArea("QPK")
	dbSetOrder(1)
	dbSeek(xFilial("QPK")+SC2->(C2_NUM+C2_ITEM+C2_SEQUEN))
	If Eof()
		cChave := QA_NewChave() //Gera a chave de Ligacao para o Texto da Liberacao Urgente

		RecLock("QPK",.T.)
		QPK->QPK_FILIAL := xFilial("QPK")
		QPK->QPK_OP     := SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)
		QPK->QPK_LOTE   := " "
		QPK->QPK_NUMSER := " "
		QPK->QPK_PRODUT := SC2->C2_PRODUTO
		QPK->QPK_REVI   := SC2->C2_REVI
		QPK->QPK_TAMLOT := SC2->C2_QUANT
		QPK->QPK_SITOP  := If(SC2->C2_VERIFI==2,"2"," ")
		QPK->QPK_CHAVE  := cChave
		MsUnLock()
		QPK->(FKCOMMIT())

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualizacao do Skip-Teste								   		   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		QIPAtuSkipTeste(SC2->C2_PRODUTO,SC2->C2_REVI,SC2->C2_ROTEIRO,SC2->C2_EMISSAO,;
			SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD),"",SC2->C2_VERIFI,SC2->C2_QUANT)

		//Gera o Codigo do Certificado de Qualidade
		If SC2->C2_VERIFI == 2
			cCerQua := QA_SEQUSX6("QIP_CEQU",TamSX3("C2_CERQUA")[1],"S","Certificado Qualidade")
		EndIf

		RecLock("SC2",.F.)
		SC2->C2_LAUDO  := If(SC2->C2_VERIFI<>1,"A"," ")
		SC2->C2_CERQUA := cCerQua
		MsUnLock()

	EndIf

	RecLock("QPK",.F.)
	If SC2->C2_VERIFI == 2	.And. !Empty(cCerQua)
		QPK->QPK_LAUDO	:= "A"
		QPK->QPK_CERQUA	:= cCerQua
	Endif
	QPK->QPK_LOCAL  := SC2->C2_LOCAL
	QPK->QPK_UM     := SC2->C2_UM
	QPK->QPK_DTPROD := SC2->C2_DATPRI
	QPK->QPK_EMISSA := SC2->C2_EMISSAO
	MsUnLock()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualizacao do Apontamento da Producao							   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf (cAlias=="SH6" .And. nOpc==1 .And. cInspecao=="2" .And. QPInsOPInt(cAlias))

	//Retorna a ultima revisao do Produto
	cRevisao := QA_UltRevEsp(SH6->H6_PRODUTO,,,,"QIP") //cProduto

	//Gera o Codigo Sequencial para identificacao da Producao
	cCodPro := QA_SEQU("QIP_IDEN",TamSX3("H6_IDENTE")[1],"A",OemToAnsi("Identificador Producao"))

	//Atualizacao do Registro da Inspecao da Producao apontada
	dbSelectArea("QPK")
	dbSetOrder(1)
	dbSeek(xFilial("QPK")+SH6->(H6_OP+H6_LOTECTL+H6_NUMLOTE))
	If Eof()
		cChave := QA_NewChave() //Gera a chave de Ligacao para o Texto da Liberacao Urgente

		RecLock("QPK",.T.)
		QPK->QPK_FILIAL := xFilial("QPK")
		QPK->QPK_OP     := SH6->H6_OP
		QPK->QPK_LOTE   := IIf(Empty(cVarlot),SH6->(H6_LOTECTL+H6_NUMLOTE),cVarlot)
		QPK->QPK_NUMSER := " "
		QPK->QPK_PRODUT := SH6->H6_PRODUTO
		QPK->QPK_REVI   := cRevisao
		QPK->QPK_TAMLOT := SH6->H6_QTDPROD
		QPK->QPK_SITOP  := If(SH6->H6_VERIFI==2,"2"," ")
		QPK->QPK_CHAVE  := cChave
		MsUnLock()

		cVarlot := ""
		
		//Obtem o roteiro utilizado na producao
		QP6->(dbSetorder(1))
		QP6->(dbSeek(xFilial("QP6")+SH6->H6_PRODUTO+Inverte(cRevisao)))
		If QP6->(!Eof())
			cRoteiro := QP6->QP6_CODREC
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualizacao do Skip-Teste								   		   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		QIPAtuSkipTeste(SH6->H6_PRODUTO,cRevisao,cRoteiro,SH6->H6_DTPROD,;
			SH6->H6_OP,QPK->QPK_LOTE,SH6->H6_VERIFI,SH6->H6_QTDPROD)


		//Gera o Codigo do Certificado de Qualidade
		If SH6->H6_VERIFI == 2
			cCerQua := QA_SEQUSX6("QIP_CEQU",TamSX3("H6_CERQUA")[1],"S","Certificado Qualidade")
		EndIf

		RecLock("SH6",.F.)
		SH6->H6_REVI   := cRevisao
		SH6->H6_IDENTE := cCodPro
		SH6->H6_PRDINV := Inverte(SH6->H6_DTPROD)
		SH6->H6_LOTINV := Inverte(SH6->H6_NUMLOTE)
		SH6->H6_IDEINV := Inverte(SH6->H6_IDENTE)
		SH6->H6_CERQUA := cCerQua
		SH6->H6_LAUDO  := If(SH6->H6_VERIFI==2,"A"," ")
		MsUnLock()

	EndIf

	RecLock("QPK",.F.)
	If SH6->H6_VERIFI == 2	.And. !Empty(cCerQua)
		QPK->QPK_LAUDO	:= "A"
		QPK->QPK_CERQUA	:= cCerQua
	Endif
	QPK->QPK_LOCAL  := SH6->H6_LOCAL

	QPK->QPK_UM     := Posicione("SB1",1,xFilial("SB1")+SH6->H6_PRODUTO,"B1_UM")
	QPK->QPK_DTPROD := SH6->H6_DTPROD
	QPK->QPK_EMISSA := SH6->H6_DTAPONT

	If Empty(Alltrim(SH6->H6_LOTECTL)) .AND. SC2->C2_QUANT <> SH6->H6_QTDPROD .And. SH6->H6_PT <> "T" //Apontamento Parcial - Requer Lote
		QPK->QPK_LOTE   := SH6->(H6_IDENTE+H6_IDEINV)
	ENDIF

	MsUnLock()

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exclusao da Ordem de Producao e/ou Apontamento da Producao		   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nOpc==2)

	If (cAlias=="SC2" .And. cInspecao=="1")

	    //Posiciona o indice a ser utilizado na pesquisa do registro da inspecao
		dbSelectArea("QPK")
		dbSetOrder(1)
		dbSeek(xFilial("QPK")+SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD))
		While !Eof() .And. SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)==QPK->QPK_OP
			If !Empty(QPK->QPK_SITOP)
				lRetorno := .F.
				Exit
			EndIf
			QPK->(dbSkip())
		EndDo

	    If lRetorno
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Estorno do Skip-Teste								   		   	   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			QIPAtuSkipTeste(SC2->C2_PRODUTO,SC2->C2_REVI,SC2->C2_ROTEIRO,SC2->C2_EMISSAO,;
				SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD),,SC2->C2_VERIFI,SC2->C2_QUANT,.T.)

			//Exclusao do Registro da Inspecao
			dbSelectArea("QPK")
			dbSetOrder(1)
			dbSeek(xFilial("QPK")+SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD))
			While !Eof() .And. (QPK_FILIAL+QPK_OP)==(xFilial("QPK")+SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD))
				RecLock("QPK",.F.)
				dbDelete()
				MsUnLock()
				dbSkip()
			EndDo

		EndIf

	ElseIf (cAlias=="SH6" .And. cInspecao=="2")

		If Empty(Alltrim(SH6->H6_LOTECTL)) .AND. SC2->C2_QUANT <> SH6->H6_QTDPROD .And. SH6->H6_PT <> "T" //Apontamento Parcial - Requer Lote
			cKeyLote := SH6->(H6_IDENTE+H6_IDEINV)
		Else
			cKeyLote := SH6->(H6_LOTECTL+H6_NUMLOTE)
		EndIf

	    //Posiciona o indice a ser utilizado na pesquisa do registro da inspecao
		dbSelectArea("QPK")
		dbSetOrder(1)
		IF dbSeek(xFilial("QPK")+SH6->(H6_OP+cKeyLote))
			While !Eof() .And. SH6->(H6_OP+cKeyLote)==QPK->(QPK_OP+QPK_LOTE)
				If !Empty(QPK->QPK_SITOP)
					lRetorno := .F.
					Exit
				EndIf
				QPK->(dbSkip())
			EndDo
		ENDIF

	    If lRetorno
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Estorno do Skip-Teste								   		   	   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			QIPAtuSkipTeste(SH6->H6_PRODUTO,SH6->H6_REVI,,SH6->H6_DTPROD,SH6->H6_OP,;
				SH6->(cKeyLote),SH6->H6_VERIFI,SH6->H6_QTDPROD,.T.)

			dbSelectArea("QPK")
			dbSetOrder(1)
			dbSeek(xFilial("QPK")+SH6->(H6_OP+cKeyLote))
			While !Eof() .And. (QPK->(QPK_FILIAL+QPK_OP+QPK_LOTE))==(xFilial("QPK")+SH6->(H6_OP+cKeyLote))
				RecLock("QPK",.F.)
				dbDelete()
				MsUnLock()
				dbSkip()
			EndDo

		EndIf

    EndIf

EndIf

//Ponto de Entrada apos a Integração do QIP com o PCP.
If ExistBlock("QPGERQPK")
	ExecBlock("QPGERQPK",.F.,.F.,{cAlias,nOpc})
EndIf

RestArea(aAreaAnt)

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QAtuMatQIP  ³ Autor ³ Paulo Emidio de Barros³Data³05/01/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualizacao dos Lotes x Ordens de Producoes				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QAtuMatQIP(EXPC1,EXPC2,EXPC3,EXPC4,EXPC5)				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³	EXPC1 = Produto                          				  ³±±
±±³		  	 ³	EXPC2 = Revisao                  				  		  ³±±
±±³			 ³	EXPC3 = Roteiro de Operacoes                     		  ³±±
±±³			 ³	EXPC4 = Origem                 				  			  ³±±
±±³			 ³	EXPL1 = Indica se as Operacoes deverao se excluidas       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observac. ³	Quando a Integracao ocorrer pelo QIP, o parametro cRoteiro³±±
±±³		  	 ³	nao sera utilizado, para que haja atualizacao dos roteiros³±±
±±³			 ³	secundarios.	 										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Integracao SIGAPCP x SIGAQIP                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QAtuMatQIP( cProduto, cRevisao, cRoteiro, cOrigem, lDeleta,;
					 cPrioRot,   lNEMsg, aOperDel, lDelSG2)

Local aAreaSG2	 := {}
Local aAreaQQK	 := {}
Local aAreaAnt   := GetArea()
Local lQipMat    := IIF(cOrigem=="QIP",.T.,IntQIP(cProduto,,"T"))
Local lNovRev    := .F.
Local aRoteiro   := {}
Local nRoteiro   := 0
Local lNewSG2    := 0
Local nX		 := 0
Local lPrototipo	:= !IsInCallStack('QIPA011') .And. IsProdProt(cProduto)
Local aStruSG2 		:= FWFormStruct(3, "SG2")[3]
Local aStruQQK 		:= FWFormStruct(3, "QQK")[3]
Local lMVQPDELRO 	:= SuperGetMV("MV_QPDELRO",.T.,.F.)
Local cCampoAux		:= ""
Local lIntQIPMAT := If(SuperGetMV("MV_QIPMAT",.F.,"N")=="N",.F.,.T.) 

Default cPrioRot := "2" 	// Define a Prioridade na  atualizacao do Roteiro
Default lNEMsg   := .F. 	// Nao exibe mensagem de consistencia
Default aOperDel := {}  	// Array com operacoes deletadas
Default lDelSG2  := .T.    // Usado exclusivamente para que durante a recursividade não seja deletado o item da SG2

cRevisao := If(cRevisao==NIL,QA_UltRevEsp(cProduto,,.F.,.T.,"QIP",.T.) ,cRevisao)
lDeleta  := If(lDeleta==NIL,.F.,lDeleta)

If ExistBlock("QXFUNMAT")
	//ATENCAO
	//ATENCAO     Esse ponto somente podera ser utilizado se e somente se o parametro MV_QIPMAT = NAO - Responsabilidade de cliente.
	//ATENCAO
	lQipMat := ExecBlock("QXFUNMAT",.F.,.F.)
	//ATENCAO
	//ATENCAO     Esse ponto somente podera ser utilizado se e somente se o parametro MV_QIPMAT = NAO - Responsabilidade de cliente.
	//ATENCAO
Endif
//Caso nao haja integracao definida, abandona a rotina
If !lQipMat
	Return(NIL)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Integracao PCP x QIP										 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cOrigem == "PCP"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Indica a necessidade de gerar uma nova revisao da Especifica-³
	//³ cao do Produto a partir do Roteiro de Operacoes.			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lDeleta
		lNovRev := QipRevEsp(cProduto,cRevisao,cRoteiro)
	EndIf

	If (lNovRev .And. !lDeleta)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Cria uma nova Especificacao para o Produto					 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		QIPCriaEspec(cProduto,@cRevisao,cRoteiro,aOperDel,.F.,cPrioRot)

		// Caso existam Itens para deletar
		For nX := 1 to Len(aOperDel)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exclui a Operacao na Especificacao vigente juntamente com as ³
			//³ amarracoes.                                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			QIPDelOper(cProduto,cRevisao,cRoteiro,aOperDel[nX][2])
		Next
	Else
		// Caso existam Itens para deletar
		For nX := 1 to Len(aOperDel)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exclui a Operacao na Especificacao vigente juntamente com as ³
			//³ amarracoes.                                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			QIPDelOper(cProduto,cRevisao,cRoteiro,aOperDel[nX][2])
		Next
	EndIf
		aAreaSG2 := SG2->(GetArea())
	If Empty(AllTrim(cRevisao))
		dbSelectArea("QP6")
		DBSetOrder(1)
		If dbSeek(xFilial("QP6")+cProduto)
			cRevisao := QP6->QP6_REVI
		EndIf
	EndIf

		dbSelectArea("SG2")
		dbSetOrder(1)
		dbSeek(xFilial("SG2")+cProduto+cRoteiro)
		While !Eof() .And. G2_FILIAL==xFilial("SG2") .And. (G2_PRODUTO+G2_CODIGO)==(cProduto+cRoteiro)

		If !lDeleta
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Compatibiliza as caracteristicas referentes ao PCP na revi-  ³
			//³ sao atual da Especificacao do Produto.						 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("QQK")
			dbSetOrder(1)
			If !dbSeek(xFilial("QQK")+cProduto+cRevisao+cRoteiro+SG2->G2_OPERAC)
				RecLock("QQK",.T.)
				QQK->QQK_FILIAL  := xFilial("QQK")
				QQK->QQK_CODIGO  := SG2->G2_CODIGO
				QQK->QQK_PRODUT  := SG2->G2_PRODUTO
				QQK->QQK_OPERAC  := SG2->G2_OPERAC
				QQK->QQK_REVIPR  := cRevisao
			ElseIf Iif(Len(aOperDel)>0,.T.,Ascan(aOperDel,{|x| x[1]+x[2] == cRoteiro+SG2->G2_OPERAC }) == 0)
				RecLock("QQK",.F.)
				QQK->QQK_CODIGO  := SG2->G2_CODIGO
				QQK->QQK_PRODUT  := SG2->G2_PRODUTO
				QQK->QQK_OPERAC  := SG2->G2_OPERAC
				QQK->QQK_REVIPR  := cRevisao				
			EndIf

			If Iif(Len(aOperDel)>0,.T.,Ascan(aOperDel,{|x| x[1]+x[2] == cRoteiro+SG2->G2_OPERAC }) == 0)
				QQK->QQK_RECURS := SG2->G2_RECURSO
				QQK->QQK_FERRAM := SG2->G2_FERRAM
				QQK->QQK_LINHAP := SG2->G2_LINHAPR
				QQK->QQK_TPLINH := SG2->G2_TPLINHA
				QQK->QQK_DESCRI := SG2->G2_DESCRI
				QQK->QQK_MAOOBR := SG2->G2_MAOOBRA
				QQK->QQK_SETUP  := SG2->G2_SETUP
				QQK->QQK_FORMST := SG2->G2_FORMSTP
				QQK->QQK_LOTEPA := SG2->G2_LOTEPAD
				QQK->QQK_TEMPAD := SG2->G2_TEMPAD
				QQK->QQK_TPOPER := SG2->G2_TPOPER
				QQK->QQK_TPSOBR := SG2->G2_TPSOBRE
				QQK->QQK_TEMPSO := SG2->G2_TEMPSOB
				QQK->QQK_TPDESD := SG2->G2_TPDESD
				QQK->QQK_TEMPDE := SG2->G2_TEMPDES
				QQK->QQK_DESPRO := SG2->G2_DESPROP
				QQK->QQK_CTRAB  := SG2->G2_CTRAB
				QQK->QQK_ROTALT := SG2->G2_ROTALT
				QQK->(MsUnLock())

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Copia dos campos de usuario 								³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nX := 1 To Len(aStruSG2)
					If GetSx3Cache(aStruSG2[nX,1], "X3_PROPRI") == "U" .And. GetSx3Cache(aStruSG2[nX,1], "X3_CONTEXT") <> "V"
						//Verifica se o campo existe no SG2
						cCampoAux := AllTrim("QQK_" + Substr(aStruSG2[nX,1], At("_", aStruSG2[nX,1])+1, (Len(aStruSG2[nX,1])-At("_", aStruSG2[nX,1]))))
						If !Empty(GetSX3Cache(cCampoAux,"X3_CAMPO"))
							RecLock("QQK",.F.)
							QQK->(FieldPut(FieldPos(cCampoAux),&("SG2->"+Alltrim(aStruSG2[nX,1]))))
							QQK->(MsUnlock())
						EndIf
					EndIf
				Next nX
			EndIf

			If !lDeleta //Atualizacao da Revisao do SG2
				RecLock("SG2",.F.)
				SG2->G2_REVIPRD := cRevisao
				MsUnLock()
			EndIf
		Else

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Compatibiliza as caracteristicas referentes ao PCP na revi-  ³
			//³ sao atual da Especificacao do Produto.						 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("QQK")
			dbSetOrder(1)
			If dbSeek(xFilial("QQK")+cProduto+cRevisao+cRoteiro+SG2->G2_OPERAC)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Exclui a Operacao na Especificacao vigente juntamente com as ³
				//³ amarracoes.                                                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				QIPDelOper(cProduto,cRevisao,cRoteiro,SG2->G2_OPERAC)

				RecLock("QQK",.F.)
				dbDelete()
				MsUnLock()

			EndIf

        EndIf

		dbSelectArea("SG2")
		dbSkip()

	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso o roteiro Primario tenha  sido deletado define o proxi- ³
	//³ mo roteiro como primario.                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QIPDefRotPr(cProduto, cRevisao, nil, .F.)

	RestArea(aAreaSG2)

EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Integracao QIP x PCP										 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cOrigem == "QIP" .And. lIntQIPMAT

	aAreaQQK := QQK->(GetArea())

	dbSelectArea("QQK")
	dbSetorder(1)
	dbseek(xFilial("QQK")+cProduto+cRevisao)
	While !Eof() .And. (QQK_FILIAL+QQK_PRODUT+QQK_REVIPR)==(xFilial("QQK")+cProduto+cRevisao)

		If Ascan(aOperDel,{|x| x[1]+x[2] == QQK->QQK_CODIGO+QQK->QQK_OPERAC }) > 0
			QQK->(dbSkip())
			Loop
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualizacao de todos os roteiros de Operacoes vinculados a 	 ³
		//³ Especificacao do Produto.									 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cRoteiro := QQK_CODIGO
		If Ascan(aRoteiro,{|x|x==cRoteiro})==0
			Aadd(aRoteiro,cRoteiro)
		EndIf

		While !Eof() .And. (QQK_FILIAL+QQK_PRODUT+QQK_REVIPR+QQK_CODIGO)==;
			(xFilial("QQK")+cProduto+cRevisao+cRoteiro)


			dbSelectArea("SG2")
			dbSetorder(1)
			If !dbSeek(xFilial("SG2")+QQK->(QQK_PRODUT+QQK_CODIGO+QQK_OPERAC))
				RecLock("SG2",.T.)
				SG2->G2_FILIAL  := xFilial("SG2")
				SG2->G2_CODIGO  := cRoteiro
				SG2->G2_PRODUTO := cProduto
				SG2->G2_OPERAC  := QQK->QQK_OPERAC
				lNewSG2 := .T.
			Else
				RecLock("SG2",.F.)
				lNewSG2 := .F.
			EndIF

			If (cPrioRot == "2") .OR. lNewSG2   // Caso a Prioridade seja do Quality substituo as informacoes do o roteito do Materiais
				SG2->G2_RECURSO := QQK->QQK_RECURS
				SG2->G2_FERRAM  := QQK->QQK_FERRAM
				SG2->G2_LINHAPR := QQK->QQK_LINHAP
				SG2->G2_TPLINHA := QQK->QQK_TPLINH
				SG2->G2_DESCRI  := QQK->QQK_DESCRI
				SG2->G2_MAOOBRA := QQK->QQK_MAOOBR
				SG2->G2_SETUP   := QQK->QQK_SETUP
				SG2->G2_FORMSTP := QQK->QQK_FORMST
				SG2->G2_LOTEPAD := QQK->QQK_LOTEPA
				SG2->G2_TEMPAD  := QQK->QQK_TEMPAD
				SG2->G2_TPOPER  := QQK->QQK_TPOPER
				SG2->G2_TPSOBRE := QQK->QQK_TPSOBR
				SG2->G2_TEMPSOB := QQK->QQK_TEMPSO
				SG2->G2_TPDESD  := QQK->QQK_TPDESD
				SG2->G2_TEMPDES := QQK->QQK_TEMPDE
				SG2->G2_DESPROP := QQK->QQK_DESPRO
				SG2->G2_CTRAB   := QQK->QQK_CTRAB
				SG2->G2_ROTALT  := QQK->QQK_ROTALT
				SG2->G2_GRSETUP := QQK->QQK_GRSETU
				SG2->G2_GRUPREC := QQK->QQK_GRUPRE
				SG2->G2_NIVMONT := QQK->QQK_NIVMON
				SG2->G2_CHAVMON := QQK->QQK_CHAVMO
				SG2->G2_TMAXPRO := QQK->QQK_TMAXPR
				SG2->G2_TPINTER := QQK->QQK_TPINTE
				SG2->G2_MAXINCR := QQK->QQK_MAXINC
				SG2->G2_FOLMIN  := QQK->QQK_FOLMIN
				SG2->G2_HOROTIM := QQK->QQK_HOROTI
			EndIf
			// Estas Informacoes sao exclusivas do Quality
			SG2->G2_OPE_OBR := QQK->QQK_OPE_OB
			SG2->G2_SEQ_OBR := QQK->QQK_SEQ_OB
			SG2->G2_LAU_OBR := QQK->QQK_LAU_OB
			SG2->G2_REVIPRD := QQK->QQK_REVIPR
			SG2->G2_CHAVE   := QQK->QQK_CHAVE
			SG2->G2_OPERGRP := QQK->QQK_OPERGR
			MsUnLock()

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Copia dos campos de usuario 							     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
			For nX := 1 To Len(aStruQQK)
				If GetSx3Cache(aStruQQK[nX,1], "X3_PROPRI") == "U" .And. GetSx3Cache(aStruQQK[nX,1], "X3_CONTEXT") <> "V"
					//Verifica se o campo existe no SG2
					cCampoAux := AllTrim("G2_" + Substr(aStruQQK[nX,1], At("_", aStruQQK[nX,1])+1, (Len(aStruQQK[nX,1])-At("_", aStruQQK[nX,1]))))
					If !Empty(GetSX3Cache(cCampoAux,"X3_CAMPO"))
						RecLock("SG2",.F.)
						If (cPrioRot == "2") // Caso a Prioridade seja do Quality substituo as informacoes do o roteito do Materiais
							SG2->(FieldPut(FieldPos(cCampoAux),&("QQK->"+aStruQQK[nX,1])))
						Else
							If !(cCampoAux  $ "G2_RECURSO,G2_FERRAM,G2_LINHAPR,G2_TPLINHA,G2_DESCRI,G2_MAOOBRA,G2_SETUP,G2_FORMSTP,G2_LOTEPAD,G2_TEMPAD,G2_TPOPER,G2_TPSOBRE,G2_TEMPSOB,G2_TPDESD,G2_TEMPDES,G2_DESPROP,G2_CTRAB,G2_ROTALT,G2_GRSETUP,G2_GRUPREC,G2_NIVMONT,G2_CHAVMON,G2_TMAXPRO,G2_TPINTER,G2_MAXINCR,G2_FOLMIN,G2_HOROTIM")
								SG2->(FieldPut(FieldPos(cCampoAux),&("QQK->"+aStruQQK[nX,1])))
							EndIF
						EndIf
						MsUnlock()
					EndIf
				EndIf
			Next nX

			If  (cPrioRot == "1") .AND. !lNewSG2 .AND. !lPrototipo // Caso a Prioridade seja do PCP recupero os dados do SG2 para o QQK

				If FunName() == "QIPA010" .AND. !lNEMsg
					If ( QQK->QQK_DESCRI <> SG2->G2_DESCRI .OR. QQK->QQK_RECURS <> SG2->G2_RECURSO )
						MsgAlert(STR0051) //"Devido a configuracao do parametro MV_QIPOPEP, a alteracao do Recurso/Descricao Operacao devera ser feita via rotina Operacoes no ambiente Planejamento Controle Producao"
						lNEMsg := .T.
					EndIf
				EndIf

				RecLock("QQK",.F.)
			 	QQK->QQK_RECURS := SG2->G2_RECURSO
				QQK->QQK_FERRAM := SG2->G2_FERRAM
				QQK->QQK_LINHAP := SG2->G2_LINHAPR
				QQK->QQK_TPLINH := SG2->G2_TPLINHA
				QQK->QQK_DESCRI := SG2->G2_DESCRI
				QQK->QQK_MAOOBR := SG2->G2_MAOOBRA
				QQK->QQK_SETUP  := SG2->G2_SETUP
				QQK->QQK_FORMST := SG2->G2_FORMSTP
				QQK->QQK_LOTEPA := SG2->G2_LOTEPAD
				QQK->QQK_TEMPAD := SG2->G2_TEMPAD
				QQK->QQK_TPOPER := SG2->G2_TPOPER
			    QQK->QQK_TPSOBR := SG2->G2_TPSOBRE
				QQK->QQK_TEMPSO := SG2->G2_TEMPSOB
				QQK->QQK_TPDESD := SG2->G2_TPDESD
				QQK->QQK_TEMPDE := SG2->G2_TEMPDES
				QQK->QQK_DESPRO := SG2->G2_DESPROP
				QQK->QQK_CTRAB  := SG2->G2_CTRAB
				QQK->QQK_ROTALT := SG2->G2_ROTALT
				QQK->QQK_GRSETU := SG2->G2_GRSETUP
				QQK->QQK_GRUPRE := SG2->G2_GRUPREC
				QQK->QQK_NIVMON := SG2->G2_NIVMONT
				QQK->QQK_CHAVMO := SG2->G2_CHAVMON
				QQK->QQK_TMAXPR := SG2->G2_TMAXPRO
				QQK->QQK_TPINTE := SG2->G2_TPINTER
				QQK->QQK_MAXINC := SG2->G2_MAXINCR
				QQK->QQK_FOLMIN := SG2->G2_FOLMIN
				QQK->QQK_HOROTI := SG2->G2_HOROTIM
				MsUnlock()

			EndIf

			dbSelectArea("QQK")
			dbSkip()

		EndDo

	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o Roteiro de Operacoes sera excluido juntamente  ³
	//³ com a Operacao definida na Especificacao do Produto.		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAreaSG2 := SG2->(GetArea())

	dbSelectArea("SG2")
	dbSetorder(1)
	For nRoteiro := 1 to Len(aRoteiro)

		cRoteiro := aRoteiro[nRoteiro] //Roteiro de Operacao associado a Especificacao

		dbSeek(xFilial("SG2")+cProduto+cRoteiro)
		While !Eof() .And. G2_FILIAL==xFilial("SG2") .And. (G2_PRODUTO+G2_CODIGO)==(cProduto+cRoteiro)

			//Exclui a operacao inexistente na Especificacao do Produto
			QQK->(dbSetorder(1))
			QQK->(dbSeek(xFilial("QQK")+cProduto+cRevisao+cRoteiro+SG2->G2_OPERAC))
			If QQK->(Eof())
				If lMVQPDELRO .AND. lDelSG2
					RecLock("SG2",.F.)
					dbDelete()
					MsUnLock()
				EndIf
			EndIf
			dbSelectArea("SG2")
			dbSkip()

		EndDo

	Next nRoteiro

	RestArea(aAreaSG2)
	RestArea(aAreaQQK)

EndIf

RestArea(aAreaAnt)

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QIPCriaEspec ³ Autor ³ Paulo Emidio de Barros³Data³02/03/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria uma nova revisao para a Especificacao do Produto	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QIPCriaEspec(cProduto,cRevisao,cRoteiro)				      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³	EXPC1 = Produto                          				  ³±±
±±³		  	 ³	EXPC2 = Revisao                  				  		  ³±±
±±³			 ³	EXPC3 = Roteiro de Operacoes                     		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Integracao SIGAPCP x SIGAQIP                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QIPCriaEspec( cProduto, cRevisao, cRoteiro, aOperDel, lDelSG2, cPrioRot )
Local aAreaAnt   := GetArea()
Local aAreaQP6   := QP6->(GetArea())
Local cDesPro    := " "
Local cNxtRev    := cRevisao
Local aRoteiro   := {}
Local lPrioMat   := (GetMv("MV_QIPOPEP",.F.,"2") == "1") 	//Prioriza dados do Roteiro/Operacoes de 1 = Materiais / 2 - Quality

Default lDelSG2  := .T. 	// Usado exclusivamente para que durante a recursividade não seja deletado o item da SG2
Default aOperDel := {}  	// Array com operacoes deletadas

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Obtem o proximo numero da Revisao Disponivel				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QP6->(dbSetOrder(1))
QP6->(dbSeek(xFilial("QP6")+cProduto+Inverte(cRevisao)))
cDesPro := QP6->QP6_DESCPO //Descricao do Produto

While QP6->QP6_FILIAL == xFilial("QP6") .And. QP6->(!Eof())
	cNxtRev := Soma1(cNxtRev)
	QP6->(dbSeek(xFilial("QP6")+cProduto+Inverte(cNxtRev)))
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gera a Nova Revisao da Especificacao do Produto				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lPrioMat
	QIPDupEsp( cProduto, cRevisao, "  "    , cProduto, cNxtRev ,;                    //13
           "ZZ"    , cDesPro , Nil     , Nil     , Nil     ,;
            Nil    , cPrioRot , aOperDel, lDelSG2)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a Operacao na Especificacao com a proxima vigen- ³
//³ cia (QQK) esta cadastrada no Roteiro de Operacoes, caso nao  ³
//³ esteja, a mesma sera excluida.							     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QQK->(dbSetOrder(1))
QQK->(dbSeek(xFilial("QQK")+cProduto+cNxtRev))
While QQK->(!Eof()) .And. QQK->(QQK_FILIAL+QQK_PRODUT+QQK_REVIPR)==(xFilial("QQK")+cProduto+cNxtRev)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualizacao de todos os roteiros de Operacoes vinculados a 	 ³
	//³ Especificacao do Produto.									 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cRoteiro := QQK->QQK_CODIGO
	If Ascan(aRoteiro,{|x|x==cRoteiro})==0
		Aadd(aRoteiro,cRoteiro)
	EndIf

	While QQK->(!Eof()) .And. QQK->(QQK_FILIAL+QQK_PRODUT+QQK_REVIPR+QQK_CODIGO)==;
		(xFilial("QQK")+cProduto+cNxtRev+cRoteiro)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Exclui a Operacao na Especificacao que esta inexistente no SG2³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SG2->(dbSetOrder(1))
		SG2->(dbSeek(xFilial("SG2")+cProduto+cRoteiro+QQK->QQK_OPERAC))
		If SG2->(Eof())
			QIPDelOper(cProduto,cNxtRev,cRoteiro,QQK->QQK_OPERAC)
		EndIf

		QQK->(dbSkip())

	EndDo

EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a Operacao definida no Roteiro de Operacoes (SG2)³
//³ esta definida na Especificacao com a proxima vigencia a ser  ³
//³ utilizada.													 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SG2->(dbSetOrder(1))
SG2->(dbSeek(xFilial("SG2")+cProduto))
While SG2->(!Eof()) .And. SG2->G2_FILIAL==xFilial("SG2") .And.;
	SG2->(G2_PRODUTO)==(cProduto)

	QQK->(dbSetOrder(1))
	QQK->(dbSeek(xFilial("QQK")+cProduto+cNxtRev+SG2->G2_CODIGO+SG2->G2_OPERAC))
	If QQK->(Eof())
		RecLock("QQK",.T.)
		QQK->QQK_FILIAL := xFilial("QQK")
		QQK->QQK_CODIGO := SG2->G2_CODIGO
		QQK->QQK_PRODUT := cProduto
		QQK->QQK_OPERAC := SG2->G2_OPERAC
		QQK->QQK_RECURS := SG2->G2_RECURSO
		QQK->QQK_FERRAM := SG2->G2_FERRAM
		QQK->QQK_LINHAP := SG2->G2_LINHAPR
		QQK->QQK_TPLINH := SG2->G2_TPLINHA
		QQK->QQK_DESCRI := SG2->G2_DESCRI
		QQK->QQK_MAOOBR := SG2->G2_MAOOBRA
		QQK->QQK_SETUP  := SG2->G2_SETUP
		QQK->QQK_FORMST := SG2->G2_FORMSTP
		QQK->QQK_LOTEPA := SG2->G2_LOTEPAD
		QQK->QQK_TEMPAD := SG2->G2_TEMPAD
		QQK->QQK_TPOPER := SG2->G2_TPOPER
		QQK->QQK_TPSOBR := SG2->G2_TPSOBRE
		QQK->QQK_TEMPSO := SG2->G2_TEMPSOB
		QQK->QQK_TPDESD := SG2->G2_TPDESD
		QQK->QQK_TEMPDE := SG2->G2_TEMPDES
		QQK->QQK_DESPRO := SG2->G2_DESPROP
		QQK->QQK_CTRAB  := SG2->G2_CTRAB
		QQK->QQK_OPE_OB := IIF(Empty(SG2->G2_OPE_OBR),"S",SG2->G2_OPE_OBR)
		QQK->QQK_SEQ_OB := IIF(Empty(SG2->G2_SEQ_OBR),"S",SG2->G2_SEQ_OBR)
		QQK->QQK_LAU_OB := IIF(Empty(SG2->G2_LAU_OBR),"S",SG2->G2_LAU_OBR)
		QQK->QQK_REVIPR := cNxtRev          //Atualiza a Revisao da Especificacao
		QQK->QQK_CHAVE  := fGravSG2()       //Cria nova chave para a Observacao da Operacao
		QQK->QQK_ROTALT := SG2->G2_ROTALT
		QQK->QQK_OPERGR := SG2->G2_OPERGRP
		QQK->QQK_GRSETU := SG2->G2_GRSETUP
		QQK->QQK_GRUPRE := SG2->G2_GRUPREC
		QQK->QQK_NIVMON := SG2->G2_NIVMONT
		QQK->QQK_CHAVMO := SG2->G2_CHAVMON
		QQK->QQK_TMAXPR := SG2->G2_TMAXPRO
		QQK->QQK_TPINTE := SG2->G2_TPINTER
		QQK->QQK_MAXINC := SG2->G2_MAXINCR
		QQK->QQK_FOLMIN := SG2->G2_FOLMIN
		QQK->QQK_HOROTI := SG2->G2_HOROTIM
		MsUnLock()
	EndIf

	RecLock("SG2",.F.)
	SG2->G2_REVIPRD := cNxtRev //Atualiza a Revisao da Especificacao
	MsUnLock()

	SG2->(dbSkip())

EndDo

RestArea(aAreaQP6)
RestArea(aAreaAnt)

cRevisao := cNxtRev //Caso estaja  por referencia atualizo cRevisao

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QipRevEsp   ³ Autor ³ Paulo Emidio de Barros³Data³05/01/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se ha necessidade de uma nova Revisao             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QipRevEsp(EXPC1,EXPC2,EXPC3) 							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³	EXPC1 = Produto                          				  ³±±
±±³		  	 ³	EXPC2 = Revisao                  				  		  ³±±
±±³			 ³	EXPC3 = Roteiro de Operacoes                     		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Integracao SIGAPCP x SIGAQIP                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QipRevEsp(cProduto,cRevisao,cRoteiro)
Local aAreaAnt   := GetArea()
Local aAreaSG2   := SG2->(GetArea())
Local aAreaSC2   := SC2->(GetArea())
Local aAreaQQK   := QQK->(GetARea())
Local lRevisao   := .F. //Indica se ha necessidade de uma nova Revisao para o Produto

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se as Operacoes definidas no Roteiro (SG2), estao   ³
//³ identicas as definidas na Especificacao do Produto.			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SG2->(dbSetOrder(1))
SG2->(dbSeek(xFilial("SG2")+cProduto+cRoteiro))
While SG2->G2_FILIAL==xFilial("SG2") .And. SG2->(G2_PRODUTO+G2_CODIGO)==(cProduto+cRoteiro)
	QQK->(dbSetorder(1))
	QQK->(dbSeek(xFilial("QQK")+cProduto+cRevisao+cRoteiro+SG2->G2_OPERAC))
	If QQK->(Eof())
		lRevisao := If(!lRevisao,.T.,lRevisao)
	EndIf
	SG2->(dbSkip())
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se as Operacoes definidas na Especificacao do Pro-  ³
//³ duto (QQK), estao identicas as definidas no Roteiro de  Ope- ³
//³ racoes.													     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lRevisao
	QQK->(dbSetorder(1))
	QQK->(dbSeek(xFilial("QQK")+cProduto+cRevisao+cRoteiro))
	While QQK->QQK_FILIAL==xFilial("QQK") .And. QQK->(QQK_PRODUT+QQK_REVIPR+QQK_CODIGO)==(cProduto+cRevisao+cRoteiro)

		SG2->(dbSetorder(1))
		SG2->(dbSeek(xFilial("SG2")+cProduto+cRoteiro+QQK->QQK_OPERAC))
		If SG2->(Eof())
			lRevisao := If(!lRevisao,.T.,lRevisao)
		EndIf

		QQK->(dbSkip())
	EndDo
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica caso existam ordens de producao para esta revisao.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lRevisao
	SC2->(dbSetorder(8))
	SC2->(dbSeek(xFilial("SC2")+cProduto+cRevisao))
	If SC2->(!Eof())

		While SC2->(!Eof()) .And. SC2->C2_FILIAL==xFilial("SC2") .And.;
			SC2->(C2_PRODUTO+C2_REVI)==(cProduto+cRevisao) .And. !lRevisao
			lRevisao := .T.
			SC2->(dbSkip())
		EndDo

	EndIf
EndIf

RestArea(aAreaSC2)
RestArea(aAreaSG2)
RestArea(aAreaQQK)
RestArea(aAreaAnt)

Return(lRevisao)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QipDelOper  ³ Autor ³ Paulo Emidio de Barros³Data³02/03/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exclui as Amarracoes associadas a uma Operacao na Especifi-³±±
±±³			 ³ cacao do Produto.										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QIPDelOper(EXPC1,EXPC2,EXPC3,EXPC4)	 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³	EXPC1 = Produto                          				  ³±±
±±³		  	 ³	EXPC2 = Revisao                  				  		  ³±±
±±³		  	 ³	EXPC3 = Roteiro de Operacoes                     		  ³±±
±±³			 ³	EXPC4 = Codigo da Operacao								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Integracao SIGAPCP x SIGAQIP                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QIPDelOper(cProduto,cRevisao,cRoteiro,cOperacao)
Local aAreaAnt := GetArea()
Local aAlias   := {"QP7","QP8"}
Local nAlias   := 0

QQK->(dbSetOrder(1))
QQK->(dbSeek(xFilial("QQK")+cProduto+cRevisao+cRoteiro+cOperacao))
If QQK->(!Eof())

    For nAlias := 1 to Len(aAlias)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exclui as Amarracoes referentes aos Ensaios mensuraveis		 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		(aAlias[nAlias])->(dbSetOrder(1))
		(aAlias[nAlias])->(dbSeek(xFilial(aAlias[nAlias])+cProduto+cRevisao+cRoteiro+cOperacao))
		While (aAlias[nAlias])->(!Eof()) .And.;
			(aAlias[nAlias])->(&(aAlias[nAlias]+"_FILIAL"))==xFilial(aAlias[nAlias]) .And.;
			(aAlias[nAlias])->(&(aAlias[nAlias]+"_PRODUT")+&(aAlias[nAlias]+"_REVI")+&(aAlias[nAlias]+"_CODREC")+&(aAlias[nAlias]+"_OPERAC"))==;
	  		(cProduto+cRevisao+cRoteiro+cOperacao)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exclui as Nao-Conformidades associadas ao Ensaio na Operacao ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			QP9->(dbSetOrder(3))
			QP9->(dbSeek(xFilial("QP9")+cProduto+cRevisao+cRoteiro+cOperacao+(aAlias[nAlias])->&(aAlias[nAlias]+"_ENSAIO")))
			While QP9->(!Eof()) .And. QP9->QP9_FILIAL==xFilial("QP9") .And.;
				QP9->(QP9_PRODUT+QP9_REVI+QP9_ROTEIR+QP9_OPERAC+QP9_ENSAIO)==;
				(cProduto+cRevisao+cRoteiro+cOperacao+(aAlias[nAlias])->&(aAlias[nAlias]+"_ENSAIO"))
			    RecLock("QP9",.F.)
			    dbDelete()
			    MsUnLock()
				QP9->(dbSkip())
			EndDo

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exclui os Instrumentos associados ao Ensaio na Operacao		 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			QQ1->(dbSetOrder(3))
			QQ1->(dbSeek(xFilial("QQ1")+cProduto+cRevisao+cRoteiro+cOperacao+(aAlias[nAlias])->&(aAlias[nAlias]+"_ENSAIO")))
			While QQ1->(!Eof()) .And. QQ1->QQ1_FILIAL==xFilial("QQ1") .And.;
				QQ1->(QQ1_PRODUT+QQ1_REVI+QQ1_ROTEIR+QQ1_OPERAC+QQ1_ENSAIO)==;
				(cProduto+cRevisao+cRoteiro+cOperacao+(aAlias[nAlias])->&(aAlias[nAlias]+"_ENSAIO"))
			    RecLock("QQ1",.F.)
			    dbDelete()
			    MsUnLock()
				QQ1->(dbSkip())
			EndDo

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exclui os Planos de Amostragens associados ao Ensaio na Ope- ³
			//³ racao.														 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			QQH->(dbSetOrder(1))
			QQH->(dbSeek(xFilial("QQH")+cProduto+cRevisao+cRoteiro+cOperacao+(aAlias[nAlias])->&(aAlias[nAlias]+"_ENSAIO")))
			While QQH->(!Eof()) .And. QQH->QQH_FILIAL==xFilial("QQH") .And.;
				QQH->(QQH_PRODUT+QQH_REVI+QQH_CODREC+QQH_OPERAC+QQH_ENSAIO)==;
				(cProduto+cRevisao+cRoteiro+cOperacao+(aAlias[nAlias])->&(aAlias[nAlias]+"_ENSAIO"))
			    RecLock("QQH",.F.)
			    dbDelete()
			    MsUnLock()
				QQH->(dbSkip())
			EndDo

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exclui o Resgistro da Especificacao do Ensaio associado a Ope³
			//³ racao.														 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            RecLock(aAlias[nAlias],.F.)
            dbDelete()
			MsUnLock()

		    (aAlias[nAlias])->(dbSkip())

		EndDo

	Next nAlias

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exclui a Rastreabilidade associada a Operacao				 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QQ2->(dbSetOrder(1))
	QQ2->(dbSeek(xFilial("QQ2")+cProduto+cRevisao+cRoteiro+cOperacao))
	While QQ2->(!Eof()) .And. QQ2->QQ2_FILIAL==xFilial("QQ2") .And.;
		QQ2->(QQ2_CODIGO+QQ2_REVI+QQ2_ROTEIR+QQ2_OPERAC)==;
		(cProduto+cRevisao+cRoteiro+cOperacao)
		RecLock("QQ2",.F.)
		dbDelete()
		MsUnLock()
	    QQ2->(dbSkip())
	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exclui a Operacao											 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RecLock("QQK",.F.)
	dbDelete()
	MsUnLock()

EndIf

If QPCountRot(cProduto,cRevisao,"SG2") == 0
	dbSelectArea("QP6")
	DBSetOrder(1) // Indice com Revisao Invertida
	If dbSeek(xFilial("QP6")+cProduto+Inverte(cRevisao))
		Reclock("QP6",.F.)
		QP6->QP6_SITREV := "1"
		MsUnlock()
	EndIf
EndIf

RestArea(aAreaAnt)
Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QIPCheckRoteiro³ Autor ³Paulo Emidio de Barros³Data³02/03/04³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica a existencia das amarracoes com o Roteiro de Ope- ³±±
±±³			 ³ racoes.													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QIPCheckRoteiro(EXPC1,EXPC2,EXPC3)						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³	EXPC1 = Produto                          				  ³±±
±±³		  	 ³	EXPC2 = Revisao                  				  		  ³±±
±±³		  	 ³	EXPC3 = Roteiro de Operacoes                     		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Integracao SIGAPCP x SIGAQIP                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QIPCheckRoteiro(cProduto,cRevisao,cRoteiro)
Local aAreaSG2 := SG2->(GetArea())
Local lRetorno := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso a Revisao nao seja passada, sera utilizada a revisao vi ³
//³ gente para o Produto. 										 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cRevisao := If(cRevisao==NIL,QA_UltRevEsp(cProduto,,.F.,,"QIP"),cRevisao)

//Verifica se o Roteiro de Operacoes esta definido no Cadastro de Produtos
SB1->(dbSetOrder(1))
SB1->(dbSeek(xFilial("SB1")+cProduto))
If SB1->(!Eof())
	If SB1->B1_OPERPAD == cRoteiro
		HELP(" ",1,"QPCHKQIP01") //O Roteiro nao podera ser excluido
		lRetorno := .F.
	EndIf
EndIf

//Verifica se Existe Produto+Revisao definido em uma OP em aberto
If lRetorno
	SC2->(dbSetorder(8))
	SC2->(dbSeek(xFilial("SC2")+cProduto+cRevisao))
	If SC2->(!Eof())
		While SC2->(!Eof()) .And. SC2->C2_FILIAL==xFilial("SC2") .And.;
			SC2->(C2_PRODUTO+C2_REVI)==(cProduto+cRevisao)
			If SC2->C2_ROTEIRO==cRoteiro .Or. !Empty(SC2->C2_DATRF)
				HELP(" ",1,"QPCHKQIP02") //O Roteiro nao podera ser excluido
				lRetorno := .F.
			EndIf
			SC2->(dbSkip())
		EndDo

	EndIf
EndIf

//Verifica a Existencia da amarracao Operacao x Componentes
If lRetorno
	SGF->(dbSetorder(1))
	SGF->(dbSeek(xFilial("SGF")+SGF->(GF_PRODUTO+GF_ROTEIRO),.T.))
	If SGF->(!Eof())
		HELP(" ",1,"QPCHKQIP03") //O Roteiro nao podera ser excluido
		lRetorno := .F.
	EndIf
EndIf

//Verifica se  o Roteiro Primario
If lRetorno
	lRetorno := QIPValDOpr(cProduto, cRoteiro, Nil, 0)
EndIf

RestArea(aAreaSG2)
Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QIPCheckEsp ³ Autor ³ Paulo Emidio de Barros ³Data³02/03/04³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica a existencia de Ordens de Producoes com a Revisao ³±±
±±³			 ³ da Especificacao a ser excluida.							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QIPCheckEsp(EXPC1,EXPC2,EXPL1)							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³	EXPC1 = Produto                          				  ³±±
±±³		  	 ³	EXPC2 = Revisao                  				  		  ³±±
±±³		  	 ³	EXPL1 = Indica se a verificacao sera por Produto          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Integracao SIGAPCP x SIGAQIP                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QIPCheckEsp(cGrpPrd,cRevGrpPrd,lGrupo,cRoteiro,nOpc)
Local aAreaAnt := GetArea()
Local lRetorno := .T.
Local cRevPro  := ''

Default cRoteiro := ''

lGrupo := If(lGrupo==NIL,.F.,lGrupo)

If lGrupo
	QPA->(dbSetOrder(1))
	QPA->(dbSeek(xFilial("QPA")+cGrpPrd))
	While QPA->(!Eof()) .And. QPA->QPA_FILIAL==xFilial("QPA") .And.;
		QPA->QPA_GRUPO==cGrpPrd .And. lRetorno

		//Obtem a Revisao vigente do produto definido no Grupo
		cRevPro := QA_UltRevEsp(QPA->QPA_PRODUT,,.F.,,"QIP")

		If lRetorno .and. nOpc <> 2
			If !Empty(cRevPro)
				SC2->(dbSetOrder(8))
				SC2->(dbSeek(xFilial("SC2")+QPA->(QPA_PRODUT+cRevPro)))
				If SC2->(!Eof())
					HELP(" ",1,"QPCHKGRPRV") //A especificacao do Grupo de produtos  nao podera ser alterada ou excluida.
					lRetorno := .F.
			    EndIf
		    EndIf
	    EndIf
		QPA->(dbSkip())
	EndDo
Else
	If !Empty(cRoteiro) .and. nOpc <> 2
		BeginSql Alias "TMPSC2"

		SELECT *
		FROM %Table:SC2% SC2
		WHERE SC2.C2_FILIAL = %xFilial:SC2% AND
			SC2.C2_PRODUTO = %Exp:cGrpPrd% AND
			SC2.C2_REVI = %Exp:cRevGrpPrd% AND
			SC2.C2_ROTEIRO = %Exp:cRoteiro% AND
			SC2.%NotDel%

		EndSql

		If TMPSC2->(!Eof())
			lRetorno := .F.
		EndIf

		TMPSC2->(dbCloseArea())
	Else
		SC2->(dbSetOrder(8))
		SC2->(dbSeek(xFilial("SC2")+cGrpPrd+cRevGrpPrd))
		If SC2->(!Eof()) .and. nOpc <> 2 .And.  !Empty(cGrpPrd) .And. !Empty(cRevGrpPrd)
		   lRetorno := .F.
       EndIf
	EndIf

EndIf

RestArea(aAreaAnt)
Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³qpAviso      ³Rev.  ³ Marcelo Pimentel    ³ Data ³ 04/08/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Janela de aviso com botoes                       			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³nOpc:qpAviso(cCaption,cMensagem,aBotoes)                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³nOpc       :Retorno numerico de acordo botao escolhido      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cCaption   :Titulo da Janela                                ³±±
±±³          ³cMensagem  :Texto da Janela (400 caracteres)                ³±±
±±³          ³aBotoes    :Array com titulo dos botoes  ( Max.5 )          ³±±
±±³          ³cCaption2  :Titulo da Descricao (Dentro da Janela)-opcional.³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION qpAviso(cCaption,cMensagem,aBotoes,nSize,cCaption2,cImagem)
Local ny       	:= 0
Local nx       	:= 0
Local aSize		:= { 	{134,304,35,155,35,113,51},; 	// Tamanho 1
	{134,450,35,155,35,185,51},;	// Tamanho 2
	{200,450,35,210,50,185,82} }	// Tamanho 3
Local oBtn

Private oDlgAviso
Private nOpcAviso	:= 0

Default cImagem := "LOGIN"
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
		If 	Len(aBotoes) > 3
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
	DEFINE MSDIALOG oDlgAviso FROM 0,0 TO aSize[nSize][1],aSize[nSize][2] TITLE cCaption STYLE 128 Of oMainWnd PIXEL

	DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD
	@ 0, 0 BITMAP oBmp RESNAME cImagem oF oDlgAviso SIZE aSize[nSize][3],aSize[nSize][4] NOBORDER WHEN .F. PIXEL
	@ 11 ,35  TO 13 ,400 LABEL '' OF oDlgAviso PIXEL
	@ 3  ,37  SAY cCaption2 Of oDlgAviso PIXEL SIZE 130 ,9 FONT oBold
	@ 16 ,38  SAY cMensagem Of oDlgAviso PIXEL SIZE aSize[nSize][6],aSize[nSize][5]
	TButton():New(1000,1000," ",oDlgAviso,{||Nil},32,10,,oDlgAviso:oFont,.F.,.T.,.F.,,.F.,,,.F.)
	ny := (aSize[nSize][2]/2)-36
	For nx:=1 to Len(aBotoes)
		cAction:="{||nOpcAviso:="+Str(Len(aBotoes)-nx+1)+",oDlgAviso:End()}"
		bAction:=&(cAction)
		If nX != 1
			TButton():New(aSize[nSize][7],ny,OemToAnsi(AllTrim(aBotoes[Len(aBotoes)-nx+1])), oDlgAviso,bAction,32,10,,oDlgAviso:oFont,.F.,.T.,.F.,,.F.,,,.F.)
		Else
			oBtn := TButton():New(aSize[nSize][7],ny,OemToAnsi(AllTrim(aBotoes[Len(aBotoes)-nx+1])), oDlgAviso,bAction,32,10,,oDlgAviso:oFont,.F.,.T.,.F.,,.F.,,,.F.)
			oBtn:SetFocus()
		EndIf
		ny -= 35
	Next nx

	ACTIVATE MSDIALOG oDlgAviso CENTERED
Else
	AutoGrLog(cCaption)
	AutoGrLog(cMensagem)
EndIf

Return (nOpcAviso)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ IntQIP	   ³ Autor ³ Paulo Emidio de Barros ³Data³18/03/04³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se a Integracao entre os modulos: QIP e PCP esta  ³±±
±±³			 ³ definida.												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ IntQIP(EXPC1,EXPC2,EXPC3)								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Codigo do Produto								  ³±±
±±³			 ³ EXPC2 = Evento da Inspecao do Material					  ³±±
±±³			 ³ EXPC3 = Tipo de Inspeção 								  ³±±
±±³			 ³ 			P = Verifica parametro							  ³±±
±±³			 ³ 			E = Verifica especificação						  ³±±
±±³			 ³ 			T = Verifica todos 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Integracao SIGAPCP x SIGAQIP                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function IntQIP(cProduto,cInspecao,cTipo)
Local aAreaAnt := GetArea()
Local aAreaQP6 := QP6->(GetArea())
Local lQipMat  := .F.
Local lRetorno := .F.

Default cTipo := "T"

lQipMat := IIF(cTipo$("P,T"),If(GetMV("MV_QIPMAT")=="S",.T.,.F.),.T.)

If lQipMat .AND. cTipo$("E,T")
	If (cProduto <> NIL) .And. !Empty(cProduto)
		If EMPTY(QA_UltRevEsp(cProduto,,.F.,.F.,"QIP")) //Tenta encontrar uma revisão valida para o produto na QP6
			lQipMat := .F. 
		EndIf
	EndIf
EndIF
	
If lQipMat 
	lRetorno := .T.               
Else	             
	lRetorno := .F.
EndIf 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Indica onde sera realizada a Inspecao do Material, quando houver   ³
//³ integracao entre o QIP e PCP,sendo as seguintes opcoes:			   ³
//³ 1 - Ordens de Producoes											   ³
//³ 2 - Apontamento das Producoes									   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If (cInspecao <> NIL) .And. lRetorno
	If !(SuperGetMV("MV_QINSPEC",.T.,"1")==cInspecao) 
		lRetorno := .F.
	EndIf
EndIf


RestArea(aAreaQP6)
RestArea(aAreaAnt)
Return(lRetorno)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ QPCarta  ³ Autor ³ Cleber Souza          ³ Data ³ 19/03/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna a Carta do Ensaio escolhido                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Codigo do Ensaio a pesquisar                        ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1 - Carta do Ensaio                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Generico				                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QPCarta(cEnsaio)
Local cCartEns := ""
QP1->(dbSetOrder(1))
QP1->(dbSeek(xFilial("QP1")+cEnsaio))
Do Case
Case Alltrim(QP1->QP1_TPCART) == "X"	// Tipo Texto
	cCartEns := "TXT"
Case Alltrim(QP1->QP1_TPCART) == "D"	// Tipo Dimencional/Atributo
	cCartEns := QP1->QP1_CARTA
Case Alltrim(QP1->QP1_TPCART) == "T"	// Tipo Tempo
	cCartEns := "TMP"
EndCase
Return(cCartEns)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QPVerifiPEºAutor  ³Cleber Souza		 º Data ³  04/06/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina verifica se existem pontos de entrada com nome      º±±
±±º          ³ antigo que nao sao mais utilizados pela rotina indicada    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QIPA215                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QPVerifiPE(cPrograma,aPontos,lMens)

Local  lRet  := .T.
Local  cMens := STR0037 + cPrograma + ; //"Foram encontrados os seguintes Pontos de Entrada no Programa "
				STR0038 + CHR(13)+CHR(10)+CHR(13)+CHR(10) //" cujos nomes foram modificados conforme relacao abaixo : "
Local  nY    := 0

For nY:=1 to Len(aPontos)
	If ExistBlock(Alltrim(aPontos[nY,1]))
		cMens := cMens + STR0039 + Alltrim(aPontos[nY,1]) + STR0040 + Alltrim(aPontos[nY,2])+CHR(13)+CHR(10) //"Nome Antigo: " ### " -> Nome Atual: "
		lRet := .F.
    EndIF
Next nY

If lMens .and. !lRet
	MsgAlert(cMens)
EndIf

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³QPVerNorma³ Autor ³ Paulo Emidio de Barros³ Data ³ 12/04/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se os Registros referentes a norma poderao ser ma-³±±
±±³			 ³ nipulados.												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QPVerNorma(EXPC1)           								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIP/QIE												  	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QPVerNorma(cNorma)
Local lRetorno := .T.
Local cNaoAlt  := " "

cNaoAlt += "NB5426ßNB5429ßQS9000"
cNaoAlt := AllTrim(cNaoAlt)

If (cNorma $ cNaoAlt)
	Help(" ",1,"QNALTNORMA") //Os registros referentes as Normas NBR 5426, NBR 5429 e QS 9000, nao poderao ser manipulados.
	lRetorno := .F.
EndIf
Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QPWhnOPResºAutor  ³Cleber Souza        º Data ³  05/07/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se possuiu resultados para a OP e retorna Falso.  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Utilizado nos campos WHEN da OP para que o campo fique     º±±
±±º          ³ bloqueado caso existam resultados para OP nao permitindo a º±±
±±º          ³ alteracao.												  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QPWhnOPRes()

Local lRet  := .T.
Local aArea := GetArea()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Antes de deletar verifica se tem resultados 	                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If IntQIP(SC2->C2_PRODUTO,,"E")
	QPR->(dbSetOrder(1))
	If QPR->(dbSeek( xFilial("QPR")+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN ))
		lRet := .F.
	EndIf
EndIf

RestArea(aArea)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³QipDupEsp ³ Autor ³ Paulo Emidio de Barros³ Data ³23/04/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Duplicacao das Especificacoes de Produtos				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QIPDupEsp(EXPC1,EXPC2,EXPC3,EXPC4,EXPC5,EXPC6,EXPC7,EXPC8,;³±±
±±³			 ³           EXPC9,EXPL1)									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Produto Origem									  ³±±
±±³			 ³ EXPC2 = Revisao do Produto Origem  						  ³±±
±±³			 ³ EXPC3 = Roteiro De										  ³±±
±±³			 ³ EXPC4 = Produto Destino			 						  ³±±
±±³			 ³ EXPC5 = Revisao do Produto Destino			 		  	  ³±±
±±³			 ³ EXPC6 = Roteiro Ate							 			  ³±±
±±³			 ³ EXPC7 = Descricao informada do Produto			 	  	  ³±±
±±³			 ³ EXPC8 = Grupo do Produto			 						  ³±±
±±³			 ³ EXPC9 = Revisao do Grupo do Produto						  ³±±
±±³			 ³ EXPL1 = Indica a Exibicao do Help					      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ EXPL1 = T - Gravou 										  ³±±
±±³			 ³         F - Nao Gravou                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QIPDupEsp( cProdOri, cRevOri ,   cRotDe, cProdDes, cRevDes,;
					cRotAte , cDesPro ,   cGrupo, cRevGrp , lHelp  ,;
					cRotPrim, cPrioRot, aOperDel, lDelSG2 ,cDescIn, cDescEs, cRotDes)

Local aAlias     := {"QP7","QP8"}
Local aAliasEns  := {"QQH","QQ1","QP9"}
Local aAreaAnt   := GetArea()
Local aAreaQP6   := {}
Local aOrderEns  := {1,3,3}
Local aRegEns    := {}
Local aRegEsp    := {}
Local aRegQP6    := {}
Local aRegQQ2    := {}
Local aRegQQK    := {}
Local aRegSG2    := {}
Local aTexto     := {}
Local cAlias     := " "
Local cAliasEns  := " "
Local cChavDes   := " "
Local cChavOri   := " "
Local cEspecie   := "QIPA010 "
Local cRotDesAux := " "
Local cTexto     := " "
Local cUltRev    := QA_UltRevEsp(cProdDes,dDataBase,.F.,.F.,"QIP")   // Ultima Revisão do Produto Destino
Local lAtuSB1    := .T.
Local lExistQQK  := .F.
Local lIncQQK    := .T.
Local lQEPM10B1  := ExistBlock("QEPM10B1") //Ponto de Entrada utilizado para verificar se atualiza o arquivo SB1.
Local lRetorno   := .T.
Local lRetSB1    := .T.
Local nEns       := 0
Local nEsp       := 0
Local nInitSG2   := 0
Local nRecno     := 0
Local nTamLin    := TamSX3("QA2_TEXTO")[1]

Default aOperDel := {}  	// Array com operacoes deletadas
Default cPrioRot := "2"  // Define a Prioridade do Roteiro 1-Materiais / 2-Quality
Default cRotDes  := ""
Default cRotPrim := ""   // Define o Roteiro Primario
Default lDelSG2  := .T. // Usado exclusivamente para que durante a recursividade não seja deletado o item da SG2

cRevOri  := If(cRevOri==NIL.Or.Empty(cRevOri),QA_UltRevEsp(cProdOri,dDataBase,.F.,.F.,"QIP"),cRevOri) //Sugere a Revisao Origem
cProdDes := If(cProdDes==NIL.Or.Empty(cProdDes),cProdOri,cProdDes)                                     //Sugere o Produto Destino
cRevDes  := If(cRevDes==NIL.Or.Empty(cRevDes),QA_NxtRevEsp(cProdDes,"QIP"),cRevDes)                   //Sugere a Revisao Destino
cGrupo   := If(cGrupo==NIL," ",cGrupo)
cRevGrp  := If(cRevGrp==NIL," ",cRevGrp)
lHelp    := If(lHelp==NIL,.T.,lHelp)

QP6->(dbSetOrder(1))
QP6->(dbSeek(xFilial("QP6")+cProdDes+Inverte(cRevDes)))
If QP6->(!Eof())
	If lHelp
		Help(" ",1,"QIPESPEXIS") //A Especificacao com a Revisao informada a ser duplicada ja existe.
	EndIf
	lRetorno := .F.
Else
	//Efetua a carga no QP6
	QP6->(dbSetorder(1))
	QP6->(dbSeek(xFilial("QP6")+cProdOri+Inverte(cRevOri)))
	If QP6->(Eof())
		If lHelp
			Help(" ",1,"QIPESPNEXI") //A Especificacao com a Revisao informada a ser duplicada nao existe.
		EndIf
		lRetorno := .F.
	Else
		If (Empty(cGrupo) .And. Empty(cRevGrp))
			If !Empty(QP6->QP6_GRUPO) .And. !Empty(QP6->QP6_REVIGR)
				If lHelp
				    Help(" ",1,"QIPDUPGRUP") //A especificacao informada nao podera ser duplicada, pois a mesma faz parte de um Grupo de Produtos.
				EndIf
				lRetorno := .F.
			EndIf
		EndIf
	EndIf

	If lRetorno

		Aeval(Array(QP6->(fCount())),{|x,y|Aadd(aRegQP6,QP6->(&(FieldName(y))))})

		If Empty(cRotPrim)
			cRotPrim := QP6->QP6_CODREC
		EndIf

		If !Empty(cRotDes)
			cRotPrim := cRotDes
		EndIf

		If !IsInCallStack("QPA012Dup")
			cRotPrim := QIPROTPADR(cProdDes)
		EndIf

	   	//Altera os dados para o registro destino
	   	aRegQP6[QP6->(FieldPos("QP6_PRODUT"))] := cProdDes                                                     //Produto Destino
		aRegQP6[QP6->(FieldPos("QP6_REVI"  ))] := cRevDes                                                      //Revisao do Produto Destino
		aRegQP6[QP6->(FieldPos("QP6_REVINV"))] := Inverte(cRevDes)                                             //Revisao Invertida do Produto Destino
		aRegQP6[QP6->(FieldPos("QP6_DESCPO"))] := If(cDesPro==NIL.Or.Empty(cDesPro),QP6->QP6_DESCPO,cDesPro) //Descricao do Produto Destino
		aRegQP6[QP6->(FieldPos("QP6_CODREC"))] := cRotPrim 													//Roteiro do Produto Destino
		aRegQP6[QP6->(FieldPos("QP6_DESCIN"))] := If(cDescIn==NIL.Or.Empty(cDescIn),QP6->QP6_DESCIN,cDescIn)  //Descricao em Ingles
		aRegQP6[QP6->(FieldPos("QP6_DESCES"))] := If(cDescEs==NIL.Or.Empty(cDescEs),QP6->QP6_DESCES,cDescEs)  //Descricao em Espanhol
		aRegQP6[QP6->(FieldPos("QP6_DTCAD" ))] := dDataBase                                   			        //Data do Cadastro da Especificacao
		aRegQP6[QP6->(FieldPos("QP6_DTINI" ))] := dDataBase  											        //Vigencia da Especificacao
		aRegQP6[QP6->(FieldPos("QP6_HISTOR"))] := " " 															//Atribui 'branco' para definicao de uma nova chave para o Historico
		aRegQP6[QP6->(FieldPos("QP6_CADR"))]   := cUserName
		aRegQP6[QP6->(FieldPos("QP6_GRUPO" ))] := cGrupo  //Grupo de Produtos
		aRegQP6[QP6->(FieldPos("QP6_REVIGR"))] := cRevGrp //Revisao do Grupo de Produtos

		cHistorico := MsMM(QP6->QP6_HISTOR,80)               //Recupera o Texto do Historico
		cRotDesAux := aRegQP6[QP6->(FieldPos("QP6_CODREC"))] //Salva o Codigo do Roteiro Destino

		aAreaQP6 := QP6->(GETAREA())
		//Verifica e Atualiza a Especificacao no Cadastro de Produtos (SB1)
		lAtuSB1 := If(lQEPM10B1,ExecBlock("QEPM10B1",.F.,.F.),lAtuSB1)
		If (lAtuSB1)
			lRetSB1 := QIPAtuSB1(.T.,cProdDes,cRevDes,cDesPro)
			RecLock("QP6",.T.) //Grava o Registro da Especificacao
			Aeval(aRegQP6,{|x,y|FieldPut(y,x)})
			If lRetSB1 .And. lAtuSB1 // Caso o produto já estiver cadastrado na SB1, atualiza Unidade de Medida conforme cadastro do produto
				QP6->(dbSelectArea("QP6"))
				QP6->(dbSetOrder(1))
				QP6->(dbSeek(xFilial("QP6")+cProdDes+Inverte(cRevDes)))
				QP6->QP6_UNMED1  := SB1->B1_UM
				QP6->QP6_DUNME1  := QA_DESUM(QP6->QP6_UNMED1,.T.) 
				QP6->QP6_UNAMO1  := QP6->QP6_UNMED1
				QP6->QP6_DUNAM1  := QA_DESUM(QP6->QP6_UNAMO1,.T.) 
				QP6->QP6_TIPO    := SB1->B1_TIPO
			EndIf	
			MsUnLock()
			//Grava o Texto do Historico
			MsMM(QP6->QP6_HISTOR,,,cHistorico,1,,,"QP6","QP6_HISTOR")
			
			RESTAREA(aAreaQP6)

			If cPrioRot == "1" // Verifico antes a Prioridade do Roteiro se e Materiais
				SG2->(dbSetorder(1))
				If SG2->(dbSeek(xFilial("SG2")+cProdDes))     //Se houver G2 uso o que esta  cadastrado e desconsidero o Produto Origem
					While SG2->(!Eof()) .And. SG2->G2_FILIAL==xFilial("SG2") .And. SG2->G2_PRODUTO==(cProdDes)
						Aadd(aRegSG2,{SG2->G2_CODIGO,SG2->G2_OPERAC})
						SG2->(dbSkip())
					EndDo
				EndIf
			EndIf

			//Efetua a carga no QQK
			QQK->(dbSetorder(1))
			QQK->(dbSeek(xFilial("QQK")+cProdOri+cRevOri))
			While QQK->(!Eof()) .And. QQK->QQK_FILIAL==xFilial("QQK") .And. QQK->(QQK_PRODUT+QQK_REVIPR)==(cProdOri+cRevOri)

				lIncQQK := .T.
				If Ascan(aOperDel,{|x| x[1]+x[2] == QQK->QQK_CODIGO+QQK->QQK_OPERAC }) > 0
					QQK->(dbSkip())
					Loop
				EndIf

				// Caso a Prioridade da Operacao seja do Materiais verifico o array de Operacoes
				If cPrioRot == "1"
					nInitSG2 := Ascan(aRegSG2,{|x| x[1]+x[2] == QQK->QQK_CODIGO+QQK->QQK_OPERAC })
					If nInitSG2 > 0
						lIncQQK := .F.
					EndIf
				EndIf

				If lIncQQK
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica se existem Roteiros de Operacoes esta dentro do De\Ate	   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If QQK->QQK_CODIGO < cRotDe .or. QQK->QQK_CODIGO > cRotAte
						QQK->(dbSkip())
						Loop
					EndIF

					aRegQQK := {}
					Aeval(Array(QQK->(fCount())),{|x,y|Aadd(aRegQQK,QQK->(&(FieldName(y))))})

					//Carrega o Texto da Observacao da Operacao
					cChavOri := aRegQQK[QQK->(FieldPos("QQK_CHAVE"))] //Armazena a chave para pesquisa da Observacao da Operacao
					cTexto   := " "
					If !Empty(cChavOri)
						aTexto := {}
						cTexto := QA_RecTXT(cChavOri,cEspecie,00,nTamLin,"QA2",aTexto)
					EndIf

					//Altera os dados para o registro destino
					aRegQQK[QQK->(FieldPos("QQK_PRODUT"))] := cProdDes //Produto Destino
					aRegQQK[QQK->(FieldPos("QQK_REVIPR"))] := cRevDes  //Revisao do Produto Destino
					aRegQQK[QQK->(FieldPos("QQK_CHAVE" ))] := QA_NewChave("QQK",2) //Cria nova chave para a Observacao da Operacao
					aRegQQK[QQK->(FieldPos("QQK_OPERGR"))] := " "           //Indica a Operacao por Grupo

					aRegQQK[QQK->(FieldPos("QQK_GRUPO" ))] := cGrupo  //Grupo de Produtos
					aRegQQK[QQK->(FieldPos("QQK_REVIGR"))] := cRevGrp //Revisao do Grupo de Produtos

					nRecno := QQK->(Recno())
					RecLock("QQK",.T.) //Grava o Registro da Operacao
					Aeval(aRegQQK,{|x,y|FieldPut(y,x)})
					MsUnLock()
					QQK->(dbGoTo(nRecno))

				Else

					SG2->(dbSetorder(1))
					SG2->(dbSeek(xFilial("SG2")+cProdDes+aRegSG2[nInitSG2][1]+aRegSG2[nInitSG2][2]))     //Posiciono G2

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica se existem Roteiros de Operacoes esta dentro do De\Ate	   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If aRegSG2[nInitSG2][1] < cRotDe .or. aRegSG2[nInitSG2][1] > cRotAte
						QQK->(dbSkip())
						Loop
					EndIf

					nRecno := QQK->(Recno())
					//Verifica a existencia do registro para evitar duplicação
					QQK->(dbSetOrder(1))
					lExistQQK := QQK->(dbSeek(xFilial("QQK")+cProdDes+cRevDes+SG2->(G2_CODIGO+G2_OPERAC)))
					RecLock("QQK",!lExistQQK) //Ajusta o Registro da Operacao

					QQK->QQK_FILIAL  := xFilial("QQK")
					QQK->QQK_CODIGO  := SG2->G2_CODIGO
					QQK->QQK_PRODUT  := cProdDes
					QQK->QQK_OPERAC  := SG2->G2_OPERAC
					QQK->QQK_REVIPR  := cRevDes
					QQK->QQK_RECURS  := SG2->G2_RECURSO
					QQK->QQK_FERRAM  := SG2->G2_FERRAM
					QQK->QQK_LINHAP  := SG2->G2_LINHAPR
					QQK->QQK_TPLINH  := SG2->G2_TPLINHA
					QQK->QQK_DESCRI  := SG2->G2_DESCRI
					QQK->QQK_MAOOBR  := SG2->G2_MAOOBRA
					QQK->QQK_SETUP   := SG2->G2_SETUP
					QQK->QQK_FORMST  := SG2->G2_FORMSTP
					QQK->QQK_LOTEPA  := SG2->G2_LOTEPAD
					QQK->QQK_TEMPAD  := SG2->G2_TEMPAD
					QQK->QQK_TPOPER  := SG2->G2_TPOPER
					QQK->QQK_TPSOBR  := SG2->G2_TPSOBRE
					QQK->QQK_TEMPSO  := SG2->G2_TEMPSOB
					QQK->QQK_TPDESD  := SG2->G2_TPDESD
					QQK->QQK_TEMPDE  := SG2->G2_TEMPDES
					QQK->QQK_DESPRO  := SG2->G2_DESPROP
					QQK->QQK_CTRAB   := SG2->G2_CTRAB
					QQK->QQK_ROTALT  := SG2->G2_ROTALT

					// Estas Informacoes sao exclusivas do Quality
					QQK->QQK_OPE_OB  := If(!Empty(SG2->G2_OPE_OBR),SG2->G2_OPE_OBR,"S")
					QQK->QQK_SEQ_OB  := If(!Empty(SG2->G2_SEQ_OBR),SG2->G2_SEQ_OBR,"S")
					QQK->QQK_LAU_OB  := If(!Empty(SG2->G2_LAU_OBR),SG2->G2_LAU_OBR,"S")
					QQK->QQK_OPERGR  := SG2->G2_OPERGRP
					QQK->QQK_CHAVE   := fGravSG2()    //Cria nova chave para a Observacao da Operacao
					cChavDes         := QQK->QQK_CHAVE
					QQK->(MsUnLock())
			
					QQK->(dbGoTo(nRecno))
					cChavOri := QQK->QQK_CHAVE

				EndIf

				For nEsp := 1 To Len(aAlias)
					cAlias := aAlias[nEsp]

					dbSelectArea(cAlias)
					dbSetOrder(1)
					dbSeek(xFilial(cAlias)+cProdOri+cRevOri+QQK->(QQK_CODIGO+QQK_OPERAC))
					While &(cAlias+"->(!Eof())") .And. &(cAlias+"_FILIAL")==xFilial(cAlias) .And.;
						(&(cAlias+"_PRODUT")+&(cAlias+"_REVI")+&(cAlias+"_CODREC")+&(cAlias+"_OPERAC"))==;
						(cProdOri+cRevOri+QQK->(QQK_CODIGO+QQK_OPERAC))

						aRegEsp := {}
						Aeval(Array(&(cAlias+"->(fCount())")),{|x,y|Aadd(aRegEsp,(cAlias)->&(FieldName(y)))})

						//Altera os dados para o registro destino
						aRegEsp[(cAlias)->(FieldPos((cAlias+"_PRODUT")))] := cProdDes //Produto Destino
						aRegEsp[(cAlias)->(FieldPos((cAlias+"_REVI"  )))] := cRevDes  //Revisao do Produto Destino
						aRegEsp[(cAlias)->(FieldPos((cAlias+"_GRUPO" )))] := cGrupo   //Grupo de Produtos
						aRegEsp[(cAlias)->(FieldPos((cAlias+"_REVIGR")))] := cRevGrp  //Revisao do Grupo de Produtos

						nRecno := Recno()
						RecLock(cAlias,.T.) //Grava o Registro da Operacao
						Aeval(aRegEsp,{|x,y|FieldPut(y,x)})
						MsUnLock()
						dbGoTo(nRecno)

						//QQH, QQ1, QP9
						For nEns := 1 To Len(aAliasEns)
							cAliasEns := aAliasEns[nEns]

							dbSelectArea(cAliasEns)
							dbSetOrder(aOrderEns[nEns])
							dbSeek(xFilial(cAliasEns)+cProdOri+cRevOri+QQK->(QQK_CODIGO+QQK_OPERAC)+(cAlias)->&(cAlias+"_ENSAIO"))
							While &(cAliasEns+"->(!Eof())") .And. &(cAliasEns+"_FILIAL")==xFilial(cAliasEns) .And.;
								(&(cAliasEns+"_PRODUT")+&(cAliasEns+"_REVI")+&(cAliasEns+If(cAliasEns=="QQH","_CODREC","_ROTEIR"))+&(cAliasEns+"_OPERAC")+&(cAliasEns+"_ENSAIO"))==;
								(cProdOri+cRevOri+QQK->(QQK_CODIGO+QQK_OPERAC)+(cAlias)->&(cAlias+"_ENSAIO"))
								aRegEns := {}
								Aeval(Array(&(cAliasEns+"->(fCount())")),{|x,y|Aadd(aRegEns,(cAliasEns)->&(FieldName(y)))})

								//Altera os dados para o registro destino
								aRegEns[(cAliasEns)->(FieldPos((cAliasEns+"_PRODUT")))] := cProdDes //Produto Destino
								aRegEns[(cAliasEns)->(FieldPos((cAliasEns+"_REVI"  )))] := cRevDes  //Revisao do Produto Destino
								aRegEns[(cAliasEns)->(FieldPos((cAliasEns+"_GRUPO" )))] := cGrupo   //Grupo de Produtos
								If AllTRim(cAliasEns) == "QQ1"
									aRegEns[(cAliasEns)->(FieldPos((cAliasEns+"_REVGRP")))] := cRevGrp  //Revisao do Grupo de Produtos
								Else
								aRegEns[(cAliasEns)->(FieldPos((cAliasEns+"_REVIGR")))] := cRevGrp  //Revisao do Grupo de Produtos
								EndIf

								nRecno := Recno()
								RecLock(cAliasEns,.T.)
								Aeval(aRegEns,{|x,y|FieldPut(y,x)})
								MsUnLock()
								dbGoTo(nRecno)

								dbSelectArea(cAliasEns) //QQH/QQ1/QP9
								dbSkip()

							EndDo
						Next nEns
						dbSelectArea(cAlias) //QP7/QP8
						dbSkip()

					EndDo
				Next nEsp

				//Grava a Rastreabilidade associada a Operacao
				QQ2->(dbSetorder(1))
				QQ2->(dbSeek(xFilial("QQ2")+cProdOri+cRevOri+QQK->(QQK_CODIGO+QQK_OPERAC)))
				While QQ2->(!Eof()) .And. QQ2->QQ2_FILIAL==xFilial("QQ2") .And.;
					QQ2->(QQ2_CODIGO+QQ2_REVI+QQ2_ROTEIR+QQ2_OPERAC)==(cProdOri+cRevOri+QQK->(QQK_CODIGO+QQK_OPERAC))
					aRegQQ2 := {}
					Aeval(Array(QQ2->(fCount())),{|x,y|Aadd(aRegQQ2,QQ2->&(FieldName(y)))})

					aRegQQ2[QQ2->(FieldPos("QQ2_CODIGO"))] := cProdDes //Produto Destino
					aRegQQ2[QQ2->(FieldPos("QQ2_REVI"  ))] := cRevDes  //Revisao do Produto Destino
					aRegQQ2[QQ2->(FieldPos("QQ2_GRUPO" ))] := cGrupo  //Grupo de Produtos
					aRegQQ2[QQ2->(FieldPos("QQ2_REVIGR"))] := cRevGrp //Revisao do Grupo de Produtos

					nRecno := QQ2->(Recno())
					RecLock("QQ2",.T.) //Grava o Registro da Operacao
					Aeval(aRegQQ2,{|x,y|FieldPut(y,x)})
					MsUnLock()
					QQ2->(dbGoTo(nRecno))
					QQ2->(dbSkip())

				EndDo

				If !Empty(cChavOri)
					aTexto := {}
					cTexto := QA_RecTXT(cChavOri,cEspecie,00,nTamLin,"QA2",aTexto)
				EndIf

				//Grava o Texto relacionado a Operacao
				If !Empty(cChavOri)
					If !Empty(cTexto)
						aTexto := {{1,cTexto}}
						QA_GrvTXT(IIF(!Empty(aRegQQK), aRegQQK[QQK->(FieldPos("QQK_CHAVE"))], cChavDes),cEspecie,1,aTexto)
					EndIf
				EndIf

				If cPrioRot == "1"
					nRecno := QQK->(Recno())
					QIPDupEns(	       cProdDes,; // Produto
										cUltRev,; // Ultima Revisao valida
								QQK->QQK_CODIGO,; // Roteiro Base
								QQK->QQK_OPERAC,; // Operacao Base
									"        ",; // Ensaio Base de
									"ZZZZZZZZ",; // Ensaio Base ate
											nil,; // Exibe  msg de Inconsistencia
											.T.,; // Indica que e uma duplicacao para uma revisao
									cPrioRot,; // Prioridade do Roteiro
										cRevDes)  // Revisão Destino
					QQK->(dbGoTo(nRecno))
				EndIf

				QQK->(dbSkip())

			EndDo

			If IntQIP(cProdDes,,"P")
				QAtuMatQIP( cProdDes, cRevDes,      "",   "QIP", .F.,;
							cPrioRot,    .T., aOperDel, lDelSG2)
			EndIF
		Else
			//Limpeza das variáveis não utilizado
			ASIZE(aRegQP6, 0)
			cHistorico := ""
			cRotDesAux := ""
			RestArea(aAreaQP6)
		Endif
	EndIf

	//Ponto de Entrada apos a Duplicacao do Produto
	If ExistBlock("QPM010R")
		ExecBlock("QPM010R",.F.,.F.)
	EndIf

EndIf

RestArea(aAreaAnt)
Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 |QIPUltSeqEns ³ Autor ³ Cicero Odilio Cruz    ³ Data ³05/09/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Traz a Ultima sequencia                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ EXPL1 = Ultima Sequancia                    		     	     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico 												     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QIPUltSeqEns(aAlias, cProd, cRev, cRot, cOper)
Local aAreaAnt     := GetArea()
Local cSeq		   := "00"
Local nEsp		   := 0
Local cAlias       := ""

For nEsp := 1 To Len(aAlias)
	cAlias := aAlias[nEsp]

	dbSelectArea(cAlias)
	&(cAlias+"->(dbSetOrder(1))")
	dbSeek(xFilial(cAlias)+cProd+cRev+cRot+cOper)
	While &(cAlias+"->(!Eof())") .And. &(cAlias+"_FILIAL")==xFilial(cAlias) .And.;
		(&(cAlias+"_PRODUT")+&(cAlias+"_REVI")+&(cAlias+"_CODREC")+&(cAlias+"_OPERAC"))==;
		(cProd+cRev+cRot+cOper)

        If Val(cSeq) < Val(&(cAlias+"_SEQLAB"))
        	cSeq := &(cAlias+"_SEQLAB")
        EndIf

		&(cAlias+"->(dbSkip())")
	EndDo
Next

RestArea(aAreaAnt)
Return(cSeq)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 |QIPDupEns ³ Autor ³ Paulo Emidio de Barros³ Data ³03/06/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Duplicacao das os Ensaios de um roteiro                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ EXPL1 = T - Gravou 										  ³±±
±±³			 ³         F - Nao Gravou                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QIPDupEns ( cProd,    cRev,    cRot,  cOper, cEnsDe,;
                     cEnsAte, lHelp, lRevDif, cPrioR,  cRevN) // CUIDADO: Usar lRevDif/cPrioR/cRevN/cUltSeq somente para duplicacao de Ensaios para o
                                                               //  Mesmo Roteiro/Operacao de uma Especificacao com revisão diferente
Local aAlias     := {"QP7","QP8"}
Local cAliasEns  := " "
Local aAliasEns  := {"QQH","QQ1","QP9"}
Local aOrderEns  := {1,3,3}
Local aRegEns 	 := {}
Local aRots 	 := {}
Local nEns       := 0
Local nEsp       := 0
Local nComp      := 0
Local cUltSeq    := ""
Local lEnsCalc	 := .F.
Local aRotOper	 := {}

Private cRotOper := ""

Default lRevDif := .F. // Indica se a copia sera feita para o mesmo roteiro em uma revisão diferente
Default cPrioR  := "2" // Indica a prioridade 1 - Materiais / 2 - Quality

If lRevDif .AND. cPrioR == "1"
	cUltSeq := QIPUltSeqEns(aAlias, cProd, cRev, cRot, cOper)
EndIf

// Pego os Roteiro/Operacao caso estes  nao possuam ensaios estão aptos
DBSelectArea("QQK")
If DBSeek(xFilial("QQK")+cProd+cRev)

	If !(lRevDif .AND. cPrioR == "1")
		While !Eof() .And. QQK_FILIAL+QQK_PRODUT+QQK_REVIPR == xFilial("QQK")+cProd+cRev
			If QQK_CODIGO != cRot .OR. QQK_OPERAC != cOper
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se todos Roteiro + Operacao + Ensaios (Origem), existem   ³
				//³ no Roteiro + Operacao + Ensaios (Destino).                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !QIPXChkEns(cProd, cRev, QQK_CODIGO, QQK_OPERAC)
					Aadd(aRots,{QQK_CODIGO,QQK_OPERAC})
				EndIf
			EndIf
			dbSelectArea("QQK")
			dbSkip()
		EndDo
	Else
		While !Eof() .AND.;
			QQK_FILIAL+QQK_PRODUT+QQK_REVIPR == xFilial("QQK")+cProd+cRev
			If QQK_CODIGO == cRot .OR. QQK_OPERAC == cOper
				Aadd(aRots,{QQK_CODIGO,QQK_OPERAC})
			EndIf
			dbSelectArea("QQK")
			dbSkip()
		EndDo
	EndIf

	If len(aRots) >= 1
		For nEsp := 1 To Len(aAlias)
			cAlias := aAlias[nEsp]

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se existem Ensaios Calculados na Origem                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !lEnsCalc
				dbSelectArea(cAlias)
				dbSetOrder(1)
				dbSeek(xFilial(cAlias)+cProd+cRev+cRot+cOper)
				While &(cAlias+"->(!Eof())") .And. &(cAlias+"_FILIAL")==xFilial(cAlias) .And.;
					(&(cAlias+"_PRODUT")+&(cAlias+"_REVI")+&(cAlias+"_CODREC")+&(cAlias+"_OPERAC"))==;
					(cProd+cRev+cRot+cOper)

					If !(cEnsDe <= &(cAlias+"_ENSAIO") .AND. cEnsAte >= &(cAlias+"_ENSAIO"))
						dbSelectArea(cAlias)
						dbSkip()
						Loop
					EndIf

					If (lRevDif .AND. cPrioR == "1")
						nRecno := &(cAlias+"->(Recno())")
						dbSetOrder(1)
						If dbSeek(xFilial(cAlias)+cProd+cRevN+cRot+cOper+&(cAlias+"_ENSAIO"))
							&(cAlias+"->(dbGoTo(nRecno))")
							&(cAlias+"->(dbSkip())")
							Loop
						EndIf
						&(cAlias+"->(dbGoTo(nRecno))")
					EndIf

					If !Empty(&(cAlias+"_FORMUL"))
						lEnsCalc := .T.
						Exit
					EndIf

					dbSelectArea(cAlias)
					dbSkip()
				EndDo
			Endif

			dbSelectArea(cAlias)
			dbSetOrder(1)
			dbSeek(xFilial(cAlias)+cProd+cRev+cRot+cOper)
			While &(cAlias+"->(!Eof())") .And. &(cAlias+"_FILIAL")==xFilial(cAlias) .And.;
				(&(cAlias+"_PRODUT")+&(cAlias+"_REVI")+&(cAlias+"_CODREC")+&(cAlias+"_OPERAC"))==;
				(cProd+cRev+cRot+cOper)

				If !(cEnsDe <= &(cAlias+"_ENSAIO") .AND. cEnsAte >= &(cAlias+"_ENSAIO"))
					dbSelectArea(cAlias)
					dbSkip()
					Loop
				EndIf

				If (lRevDif .AND. cPrioR == "1")
					nRecno := &(cAlias+"->(Recno())")
					dbSetOrder(1)
					If dbSeek(xFilial(cAlias)+cProd+cRevN+cRot+cOper+&(cAlias+"_ENSAIO"))
						&(cAlias+"->(dbGoTo(nRecno))")
						&(cAlias+"->(dbSkip())")
						Loop
					EndIf
					&(cAlias+"->(dbGoTo(nRecno))")
				EndIf

				aRegEsp := {}

				Aeval(Array(&(cAlias+"->(fCount())")),{|x,y|Aadd(aRegEsp,(cAlias)->&(FieldName(y)))})

				For nComp:=1 to Len(aRots)
					If (lRevDif .AND. cPrioR == "1")
						//Altera os dados para o registro destino
						cUltSeq := Soma1(cUltSeq)
						aRegEsp[(cAlias)->(FieldPos((cAlias+"_REVI")))]   := cRevN
						aRegEsp[(cAlias)->(FieldPos((cAlias+"_SEQLAB")))] := cUltSeq
					Else
						If cOper == aRots[nComp,2]
							//Altera os dados para o registro destino
							aRegEsp[(cAlias)->(FieldPos((cAlias+"_OPERAC")))] := aRots[nComp,2] //Operacao
							aRegEsp[(cAlias)->(FieldPos((cAlias+"_CODREC")))] := aRots[nComp,1] //Roteiro
						EndIF
					EndIf

					nRecno := Recno()

					If lEnsCalc
						If aScan(aRotOper,{|x|x[1]==aRots[nComp,1]+"/"+aRots[nComp,2]}) > 0 .Or. ;
							!dbSeek(xFilial(cAlias)+aRegEsp[(cAlias)->(FieldPos((cAlias+"_PRODUT")))]+;
							aRegEsp[(cAlias)->(FieldPos((cAlias+"_REVI")))]+;
							aRegEsp[(cAlias)->(FieldPos((cAlias+"_CODREC")))]+;
							aRegEsp[(cAlias)->(FieldPos((cAlias+"_OPERAC")))])
							If aScan(aRotOper,{|x|x[1]==aRots[nComp,1]+"/"+aRots[nComp,2]}) == 0
								AADD(aRotOper,{aRots[nComp,1]+"/"+aRots[nComp,2]})
							Endif
							If !dbSeek(xFilial(cAlias)+aRegEsp[(cAlias)->(FieldPos((cAlias+"_PRODUT")))]+;
								aRegEsp[(cAlias)->(FieldPos((cAlias+"_REVI")))]+;
								aRegEsp[(cAlias)->(FieldPos((cAlias+"_CODREC")))]+;
								aRegEsp[(cAlias)->(FieldPos((cAlias+"_OPERAC")))]+;
								aRegEsp[(cAlias)->(FieldPos((cAlias+"_ENSAIO")))])
								RecLock(cAlias,.T.) //Grava o Registro da Operacao
								Aeval(aRegEsp,{|x,y|FieldPut(y,x)})
								MsUnLock()
							Endif
						Else
							If !( aRots[nComp,1]+"/"+aRots[nComp,2] $ cRotOper )
								cRotOper  += IIf(Empty(cRotOper),""," - ")+aRots[nComp,1]+"/"+aRots[nComp,2]
							Endif
						Endif
					Else
						If !dbSeek(xFilial(cAlias)+aRegEsp[(cAlias)->(FieldPos((cAlias+"_PRODUT")))]+;
							aRegEsp[(cAlias)->(FieldPos((cAlias+"_REVI")))]+;
							aRegEsp[(cAlias)->(FieldPos((cAlias+"_CODREC")))]+;
							aRegEsp[(cAlias)->(FieldPos((cAlias+"_OPERAC")))]+;
							aRegEsp[(cAlias)->(FieldPos((cAlias+"_ENSAIO")))])
							RecLock(cAlias,.T.) //Grava o Registro da Operacao
							Aeval(aRegEsp,{|x,y|FieldPut(y,x)})
							MsUnLock()
						EndIf
					EndIf

					dbGoTo(nRecno)
				Next nComp

				//QQH, QQ1, QP9
				For nEns := 1 To Len(aAliasEns)
					cAliasEns := aAliasEns[nEns]

					dbSelectArea(cAliasEns)
					dbSetOrder(aOrderEns[nEns])
					dbSeek(xFilial(cAliasEns)+cProd+cRev+cRot+cOper+(cAlias)->&(cAlias+"_ENSAIO"))
					While &(cAliasEns+"->(!Eof())") .And. &(cAliasEns+"_FILIAL")==xFilial(cAliasEns) .And.;
						(&(cAliasEns+"_PRODUT")+&(cAliasEns+"_REVI")+&(cAliasEns+If(cAliasEns=="QQH","_CODREC","_ROTEIR"))+&(cAliasEns+"_OPERAC")+&(cAliasEns+"_ENSAIO"))==;
						(cProd+cRev+cRot+cOper+(cAlias)->&(cAlias+"_ENSAIO"))

						If (lRevDif .AND. cPrioR == "1")
							nRecno := &(cAliasEns+"->(Recno())")
							dbSetOrder(aOrderEns[nEns])
							If dbSeek(xFilial(cAliasEns)+cProd+cRevN+cRot+cOper+(cAliasEns)->&(cAliasEns+"_ENSAIO"))
								&(cAliasEns+"->(dbGoTo(nRecno))")
								&(cAliasEns+"->(dbSkip())")
								Loop
							EndIf
							&(cAliasEns+"->(dbGoTo(nRecno))")
						EndIf

						aRegEns 	 := {}
						Aeval(Array(&(cAliasEns+"->(fCount())")),{|x,y|Aadd(aRegEns,(cAliasEns)->&(FieldName(y)))})

						For nComp:=1 to Len(aRots)
							If !( aRots[nComp,1]+"/"+aRots[nComp,2] $ cRotOper )
								If (lRevDif .AND. cPrioR == "1")
									//Altera os dados para o registro destino
									aRegEns[(cAliasEns)->(FieldPos((cAliasEns+"_REVI")))] := cRevN
								Else
									//Altera os dados para o registro destino
									aRegEns[(cAliasEns)->(FieldPos((cAliasEns+"_OPERAC")))]                           		:= aRots[nComp,2] // Operacao
									aRegEns[(cAliasEns)->(FieldPos(cAliasEns+If(cAliasEns=="QQH","_CODREC","_ROTEIR")))]    := aRots[nComp,1]  // Roteiro
								EndIf

								nRecno := Recno()

								If !dbSeek(xFilial(cAliasEns)+aRegEns[(cAliasEns)->(FieldPos((cAliasEns+"_PRODUT")))]+;
									aRegEns[(cAliasEns)->(FieldPos((cAliasEns+"_REVI")))]+;
									aRegEns[(cAliasEns)->(FieldPos((cAliasEns+Iif(cAliasEns=="QQH","_CODREC","_ROTEIR"))))]+;
									aRegEns[(cAliasEns)->(FieldPos((cAliasEns+"_OPERAC")))]+;
									aRegEns[(cAliasEns)->(FieldPos((cAliasEns+"_ENSAIO")))])
									RecLock(cAliasEns,.T.)
									Aeval(aRegEns,{|x,y|FieldPut(y,x)})
									MsUnLock()
								EndIf

								dbGoTo(nRecno)
							Endif
						Next nComp

						dbSelectArea(cAliasEns) //QQH/QQ1/QP9
						dbSkip()
					EndDo
				Next nEns

				dbSelectArea(cAlias) //QP7/QP8
				dbSkip()
			EndDo
		Next nEsp
	EndIf
EndIf

If !Empty( cRotOper ) .And. lEnsCalc
	MsgStop(OemToAnsi(STR0071)+CHR(13)+CHR(13)+OemToAnsi(STR0072)+cRotOper,OemToAnsi(Upper(STR0009)))
Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ QIPOEns   ³ Autor ³Cicero Odilio Cruz    ³ Data ³02/06/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Verifica se a Operacao + Roteiro tem ensaios               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QIPOEns(cProd, cRev, cRot, cOper, lMsg)

Local lRet	:= .F.
Local aArea := GetArea()

Default cProd := QP6->QP6_PRODUT
Default cRev  := QP6->QP6_REVI
Default cRot  := MV_PAR01
Default cOper := MV_PAR02
Default lMsg  := .T.

If lMsg .And. ( MV_PAR04 < MV_PAR03 )
	MsgAlert(STR0070,STR0009)	//Ensaio Final Menor que o Ensaio Inicial Informado! # Atencao!
Else
	dbSelectArea("QP7")
	dbSetOrder(1)
	If dbSeek(xFilial("QP7")+cProd+cRev+cRot+cOper)
		While !EOF() .And. xFilial("QP7")+cProd+cRev+cRot+cOper == QP7->(QP7_FILIAL+QP7_PRODUT+QP7_REVI+QP7_CODREC+QP7_OPERAC)
			If MV_PAR03 <= QP7->QP7_ENSAIO .AND. MV_PAR04 >= QP7->QP7_ENSAIO
				lRet := .T.
				Exit
			Endif
			dbSkip()
		EndDo
	Endif

	If !lRet
		dbSelectArea("QP8")
		dbSetOrder(1)
		If dbSeek(xFilial("QP8")+cProd+cRev+cRot+cOper)
			While !EOF() .And. xFilial("QP8")+cProd+cRev+cRot+cOper == QP8->(QP8_FILIAL+QP8_PRODUT+QP8_REVI+QP8_CODREC+QP8_OPERAC)
				If MV_PAR03 <= QP8->QP8_ENSAIO .AND. MV_PAR04 >= QP8->QP8_ENSAIO
					lRet := .T.
					Exit
				Endif
				dbSkip()
			Enddo
		EndIf
	Endif
	If lMsg .And. !lRet
	     MsgAlert(OemToAnsi(STR0045))
	Endif
Endif

RestArea(aArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ QIPAtuSB1 ³ Autor ³Paulo Emidio de Barros³ Data ³12/03/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atualiza o Cadastro de Produtos (SB1), a partir das Especi-³±±
±±³			 ³ ficacoes do Produto. 									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ 	QIPAtuSB1(EXPL1)										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³  EXPL1 = Indica se o arquivo esta posicionado			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³       = Nulo 											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QIPAtuSB1(lPosicionado,cProd,cRev,cDesc)
Local cAlias   := " "
Local lRet := .T.

Default lPosicionado := .F.
cAlias       := If(lPosicionado,"QP6","M")

SB1->(dbSelectArea("SB1"))
SB1->(dbSetOrder(1))
If !(SB1->(dbSeek(xFilial("SB1")+cProd)))
	QIPCRIASB1("DUPLICAR", cProd, cDesc, cAlias)
	lRet := .F.
EndIf
Return(lRet)

//----------------------------------------------------------------------
/*/{Protheus.doc} QIPCRIASB1 
Executa o MATA010 via MsExecAuto
@author Marcos Wagner Jr
@since 15/04/2020
@version 1.0
@return lRet - .T. (gravado com sucesso), ou .F. (ocorreu um erro)
/*/
//---------------------------------------------------------------------- 
Function QIPCRIASB1(cOperacao, cProd, cDesc, cAlias)
Local aCab          := {}
Local lRet          := .t.
Private lMsErroAuto := .f.

If cOperacao == 'NOVO'
	aCab := {{"B1_FILIAL", xFilial("SB1"), NIL},;
			{"B1_COD"    , M->QP6_PRODUT, NIL},;
			{"B1_DESC"   , AllTrim(M->QP6_DESCPO), NIL},;
			{"B1_UM"     , M->QP6_UNMED1, NIL},;
			{"B1_LOCPAD" , "01", NIL},;
			{"B1_TIPO"   , M->QP6_TIPO, NIL},;
			{"B1_NUMCQPR", 1, NIL}}
ElseIf cOperacao == 'DUPLICAR'
	aCab := {{"B1_FILIAL", xFilial("SB1"), NIL},;
			{"B1_COD"    , cProd, NIL},;
			{"B1_DESC"   , AllTrim(cDesc), NIL},;
			{"B1_UM"     , &(cAlias+"->QP6_UNMED1"), NIL},;
			{"B1_LOCPAD" , "01", NIL},;
			{"B1_TIPO"   , &(cAlias+"->QP6_TIPO"), NIL},;
			{"B1_NUMCQPR", 1, NIL}}
EndIf

MSExecAuto({ |x,y| MATA010(x, y)}, aCab, 3) //Exclusao

If lMsErroAuto
	Mostraerro()
	lRet := .f.
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³QIPDupGrp ³ Autor ³ Paulo Emidio de Barros³ Data ³26/04/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Duplicacao das Especificacoes por Grupo					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QIPDupEsp(EXPC1,EXPC2,EXPC3,EXPC4,EXPC5,EXPC6,EXPC7,EXPC8,;³±±
±±³			 ³           EXPC9,EXPL1)									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Grupo de Produtos								  ³±±
±±³			 ³ EXPC2 = Revisao do Grupo de Produtos Origem 			  	  ³±±
±±³			 ³ EXPC3 = Revisao do Grupo de Produtos Destino				  ³±±
±±³			 ³ EXPC4 = Roteiro do Grupo de Produtos Destino				  ³±±
±±³			 ³ EXPL1 = Indica a Exibicao do Help					      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ EXPL1 = T - Gravou 										  ³±±
±±³			 ³         F - Nao Gravou                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QIPDupGrp(cGrpIni,cRevIni,cRevDes,cRotDes,lHelp)
Local lRetorno := .T.
Local aAreaAnt := GetArea()
Local aRegQQC  := {}
Local nRecQP6  := 0
Local cProduto := ""
Local lRet     := .F.

lHelp := If(lHelp==NIL,.T.,lHelp) //Indica se o Help sera exibido

//Verifica se o Grupo esta cadastrado
QP3->(dbSetorder(1))
QP3->(dbSeek(xFilial("QP3")+cGrpIni))
If QP3->(Eof())
	If lHelp
		Help(" ",1,"QIPDUPNEXI") //O Grupo de produtos informado para duplicacao, nao existe.
	EndIf
	lRetorno := .F.
Else

	//Verifica a existencia do Grupo+Revisao Destino
	QQC->(dbSetOrder(1))
	QQC->(dbSeek(xFilial("QQC")+cGrpIni+Inverte(cRevDes)))
	If QQC->(!Eof())
		If lHelp .And. QIPExisEsp(QQC->QQC_GRUPO, QQC->QQC_REVI)
			Help(" ",1,"QIPGRPEXIS") //Ja existe Grupo de Produtos com a Revisao informada.
		EndIf
		lRetorno := .F.
	Else
		cRevIni := If(cRevIni==NIL.Or.Empty(cRevIni),QA_UltRvG(cGrpIni,dDataBase),cRevIni) //Sugere a Revisao Origem

		//Posiciona no Grupo de Produtos a ser Duplicado
		QQC->(dbSetOrder(1))
		QQC->(dbSeek(xFilial("QQC")+cGrpIni+Inverte(cRevIni)))
		If QQC->(Eof())
		    If lHelp
				Help(" ",1,"QIPNESPGRP") //Nao existe Especificacao definida para o Grupo de Produtos informado para Duplicacao.
		    EndIf
		    lRetorno := .F.
		Else

			//Carrega o dados referentes ao grupo a ser duplicado
			Aeval(Array(QQC->(fCount())),{|x,y|Aadd(aRegQQC,QQC->(&(FieldName(y))))})

		   	//Altera os dados para o Grupo Destino
			aRegQQC[QQC->(FieldPos("QQC_REVI"  ))] := If(cRevDes==NIL.Or.Empty(cRevDes),QA_NxtRevGrp(cGrpIni),cRevDes) //Revisao do GrupoDestino
			aRegQQC[QQC->(FieldPos("QQC_REVINV"))] := Inverte(cRevDes)                                                   //Revisao Invertida do Grupo Destino
			aRegQQC[QQC->(FieldPos("QQC_CODREC"))] := If(cRotDes==NIL.Or.Empty(cRotDes),QQC->QQC_CODREC,cRotDes)        //Roteiro de Operacoes do Grupo Destino
			aRegQQC[QQC->(FieldPos("QQC_DTINI" ))] := dDataBase+If(QQC->QQC_DTINI<dDataBase,0,1)                        //Vigencia da Especificacao

			RecLock("QQC",.T.) //Grava o Registro da Especificacao
			Aeval(aRegQQC,{|x,y|FieldPut(y,x)})
			MsUnLock()

		    //Duplicacao dos Produtos relacionados ao Grupo
			QP6->(dbSetOrder(4))
			QP6->(dbSeek(xFilial("QP6")+cGrpIni+cRevIni))
			While QP6->(!Eof()) .And. QP6->QP6_FILIAL==xFilial("QP6") .And. QP6->(QP6_GRUPO+QP6_REVIGR)==(cGrpIni+cRevIni)
		
				//Verifica se o Produto a ser Duplicado esta definido por Grupo	x Produtos
				QPA->(dbSetorder(1))
				QPA->(dbSeek(xFilial("QPA")+QP6->(QP6_GRUPO+QP6_PRODUT)))
				If QPA->(Eof())
					cProduto += "Código Produto :"+ ALLTRIM(QP6->(QP6_PRODUT))+Chr(13)+Chr(10) 
					lRetorno := .F.
					lRet     := lHelp
				Else
					nRecQP6  := QP6->(Recno())
					lRetorno := QIPDupEsp(QP6->QP6_PRODUT,QP6->QP6_REVI,QP6->QP6_CODREC,QP6->QP6_PRODUT,STRZERO(Val(QP6->QP6_REVI)+1,2),cRotDes,Posicione('SB1',1,xFilial('SB1')+QP6->QP6_PRODUT,'B1_DESC'),cGrpIni,cRevDes,.T.)
					QP6->(dbSetOrder(4))
					QP6->(dbGoTo(nRecQP6))
				EndIf
				QP6->(dbSkip())

			EndDo
			If lRet //Atenção //"Não foi possível localizar algum(s) produto(s) na Amarração Grupo x Produtos na Tabela (QPA)." //"Listamos abaixo o(s) produto(s) não duplicado(s): "
				Help(, , STR0009, NIL, STR0088, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0089+Chr(13) + Chr(10)+cProduto})
			EndIf	
   		EndIf

	EndIf

EndIf
RestArea(aAreaAnt)

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FatorQIP  ³ Autor ³Paulo Emidio de Barros ³ Data ³07/10/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o Fator do IQP									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fator(EXPC1,EXPL1)										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Categoria a ser verificada						  ³±±
±±³	 	     ³ EXPL1 = T - Retorna a Categoria                            ³±±
±±³	 	     ³ 		   F - Retorna Quantidade a Inspecionar   			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPX1 = Categoria ou Quantidade a Inspecionar			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAQIE													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FatorQIP(cCategoria,lCategoria)
Local aAreaAnt := GetArea()
Local cFator   := Space(TamSX3("QPD_CODFAT")[1])
Local nEntIns  := 0

lCategoria := If(lCategoria==NIL,.T.,lCategoria)

dbSelectArea("QPD")
dbSetOrder(1)
dbSeek(xFilial("QPD"))
While !Eof() .And. QPD_FILIAL==xFilial("QPD")
	If QPD_CATEG == cCategoria
		If lCategoria
			cFator := QPD_CODFAT
		Else
		    nEntIns := QPD_ENTINS
		EndIf
		Exit
	EndIf
	QPD->(dbSkip())
EndDo

RestArea(aAreaAnt)
Return(If(lCategoria,cFator,nEntIns))

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QIPConIni ³ Autor ³ Paulo Emidio de Barros³ Data ³07/10/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Realiza as consistencias iniciais para determinar a primei ³±±
±±³ 		 ³ra inspecao da Ordem de Producao ou Apontamento da Producao ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QIPConIni(EXPC1,EXPC2,EXPD1,EXPA1,EXPN1)				      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Codigo do Produto								  ³±±
±±³          ³ EXPC2 = Revisao do Produto							      ³±±
±±³          ³ EXPD1 = Data da Ordem de Producao ou Apontamento			  ³±±
±±³          ³ EXPA1 = Justificativa da Inspecao ou Certificacao		  ³±±
±±³          ³ EXPN1 = 1-Inspeciona 2-Certifica 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Integracao QIP x PCP										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QIPConIni(cProduto,cRevi,dProducao,aJustif,nVerifica)
Local aAreaQP6   := QP6->(GetArea())
Local nRecBak    := 0
Local lContinua  := .T.
Local lJust      := .F.
Local dEmissao   := CtoD("")
Local cInspecao  := " "
Local aAreaPro   := {}
Local cAliasPro  := ""
Local nOrdem1    := 0
Local nOrdem2    := 0
Local cVerifi    := ""

nVerifica := If(nVerifica==NIL,1,nVerifica)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Indica onde sera realizada a Inspecao do Material, quando houver   ³
//³ integracao entre o QIP e PCP,sendo as seguintes opcoes:			   ³
//³ 1 - Ordens de Producoes											   ³
//³ 2 - Apontamento das Producoes									   ³
//³ 3 -																   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cInspecao := GetMV("MV_QINSPEC",.T.,"1")

If cInspecao == "1" //Ordem de Producao
	nRecBak   := IIF(nModulo==25,0,SC2->(RECNO()))
	aAreaPro  := SC2->(GetArea())
	cAliasPro := "SC2"
	nOrdem1   := 2 //C2_PRODUTO+dtos(C2_DATPRF)
	nOrdem2   := 7 //C2_PRODUTO+C2_IDEINV
	cVerifi   := "SC2->C3_VERIFI"
ElseIf cInspecao == "2" //Apontamento
	nRecBak := IIF(nModulo==25,0,SH6->(RECNO()))
	aAreaPro  := SH6->(GetArea())
	cAliasPro := "SH6"
	nOrdem1   := 2 ///***criar o indice - ordem 4 - h6_filial+h6_produto+h6_ideinv***/// NILTON INDICE VALIDO
	nOrdem2   := 2 ///***criar o indice - ordem 5 - h6_filial+h6_produto+dTos(h6_dtProd)***///
	cVerifi   := "SH6->H6_VERIFI"
EndIf

//Posiciona a especificacao do produto
QP6->(dbSetOrder(1))
QP6->(dbSeek(xFilial("QP6")+cProduto+Inverte(cRevi)))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se for a 1a. Producao , verifica o parametro MV_QPSKLPR para deter ³
//³ minar se inspeciona direto ou se verifica o skip-lote (respeitando ³
//³ o conceito do numero de producoes/apontamentos iniciais).          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAliasPro)
(cAliasPro)->(dbSetorder(nOrdem1))
(cAliasPro)->(dbSeek(xFilial(cAliasPro)+cProduto))

If Eof() .or. nRecBak == &(cAliasPro+"->(RECNO())")// Inspeciona a 1a. Producao

	If GetMv("MV_QPSKLPR") > 0 //"No. producoes iniciais p/ aplicacao skip-lote"
		Aadd(aJustif,STR0021)  //"Primeira Producao do Produto."
		lJust	  := .T.
		lContinua := .F.
		nVerifica := 1

		If QP6->(FieldPos("QP6_ALTESP"))>0 .And. Empty(QP6->QP6_ALTESP)
			lAltEsp := .T.
		EndIf
	EndIf
EndIf

If lContinua

	cAliasQry := QIPSELCPRO(cProduto, cRevi, cAliasPro) //Função que gerencia a localização dos produtos 

	dbSelectArea(cAliasQry)
	dbGoTop()
	While (cAliasQry)->(!Eof()) 
		IF cInspecao == "1" //Ordem de Producao
			If (cAliasQry)->C2_VERIFI == 0
			   (cAliasQry)->(dbSkip())
				LOOP
			EndIF
			dEmissao := (cAliasQry)->C2_EMISSAO
		ELSEIF cInspecao == "2" //Apontamento
			If (cAliasQry)->H6_VERIFI == 0
				(cAliasQry)->(dbSkip())
				LOOP
			EndIF
			dEmissao := (cAliasQry)->H6_DTPROD
		ENDIF

		If !Empty(QP6->QP6_TMPLIM) .And. (dProducao-STOD(dEmissao)) > (QP6->QP6_TMPLIM*30)	//Tempo limite
			Aadd(aJustif,STR0022) //"Tempo Limite sem Producao expirado."
			lJust	  := .T.
			nVerifica := 1
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se ‚ a primeira Ordem de Producao ou Apontamento ap¢s al- ³
			//³ teracao de especificacao.										   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If STOD(dEmissao) < QP6->QP6_DTINI
				Aadd(aJustif,STR0023) //"Primeira Producao apos alteracao Especificacao"
				lJust     := .T.
				nVerifica := 1
			EndIf

			If QP6->(FieldPos("QP6_ALTESP"))>0 .And. Empty(QP6->QP6_ALTESP)
				lAltEsp := .T.
			EndIf
		EndIf
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
EndIf

If lJust
	Aadd(aJustif,STR0024) //"A Producao devera ser inspecionada."
EndIf

RestArea(aAreaQP6)
RestArea(aAreaPro)
Return(nVerifica)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QipSkipLote³ Autor ³Paulo Emidio de Barros³ Data ³07/10/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Realiza o Calculo do Skip-Lote							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QIPSkipLote(EXPC1,EXPC2,EXPD1,EXPA1,EXPC3,EXPN1)           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Codigo do Produto                                  ³±±
±±³          ³ EXPC2 = Revisao do Produto                                 ³±±
±±³          ³ EXPD1 = Data da Ordem de Producao ou Apontamento           ³±±
±±³          ³ EXPA1 = Justificativa                                      ³±±
±±³          ³ EXPC3 = Fator de Reprovacao                                ³±±
±±³          ³ EXPN1 = 1-Inspeciona 2-Certifica                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Integracao QIP x PCP										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QIPSkipLote(cProduto,cRevi,dProducao,aJustif,cFatRep,nVerifica)
Local aAreaQP6	:= QP6->(GetArea())
Local dLimite   := Ctod("")
Local nCt		:= 0
Local nCtRecu	:= 1
Local nPrdInsp	:= 0
Local cLabor	:= CriaVar("QPL_LABOR",.F.)
Local cItemGRD  := CriaVar("C2_ITEMGRD",.F.)
Local cInspecao := " "
Local cAliasPro := " "
Local aAreaPro  := {}
Local nOrdem1   := 0
Local nOrdem2   := 0
Local cCondicao := ""
Local cChave    := ""
Local cEmissao  := ""
Local cVerifi   := ""
Local nContH6	:= 0
Local cAliasQry := ""

cFatRep := If(cFatRep==NIL,FatorQIP("3"),cFatRep) //Retorna o Fator para definicao de Laudo Reprovado

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Indica onde sera realizada a Inspecao do Material, quando houver   ³
//³ integracao entre o QIP e PCP,sendo as seguintes opcoes:			   ³
//³ 1 - Ordens de Producoes											   ³
//³ 2 - Apontamento das Producoes									   ³
//³ 3 -																   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cInspecao := GetMV("MV_QINSPEC",.T.,"1")

If cInspecao == "1" //Ordem de Producao
	cAliasPro := "SC2"
	aAreaPro  := SC2->(GetArea())
	nOrdem1   := 7 //C2_PRODUTO+C2_IDEINV
	nOrdem2   := 1 //C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD
	cCondicao := "SC2->(C2_FILIAL+C2_PRODUTO)"
	cChave    := "SC2->(C2_NUM+C2_ITEM+C2_SEQUEN)"
	cEmissao  := "SC2->C2_EMISSAO"
	cVerifi   := "SC2->C2_VERIFI"
ElseIf cInspecao == "2" //Apontamento
	cAliasPro := "SH6"
	aAreaPro  := SH6->(GetArea())
	nOrdem1   := 2 ///***DEFINIR O INDICE CORRETO***///  NILTON INDICE VALIDO
	nOrdem2   := 2 ///***DEFINIR O INDICE CORRETO***///
	cCondicao := "SH6->(H6_FILIAL+H6_PRODUTO)"
	cChave    := "SH6->H6_OP"
	cEmissao  := "SH6->H6_DTPROD"
	cVerifi   := "SH6->H6_VERIFI"
EndIf

//Posiciona a Especificacao para verificar a definicao de Skip-Lote
QP6->(dbSetOrder(1))
QP6->(dbSeek(xFilial("QP6")+cProduto+Inverte(cRevi)))

//Define a data para inspecao da Ordem de Producao ou Apontamento
QPF->(dbSetOrder(1))
QPF->(dbSeek(xFilial("QPF")+QP6->QP6_SKPLOT))
dLimite := (dProducao-(QPF->QPF_QTDE-1))

//Identifica o numero da producao a inspecionar referente ao fator de reprovacao
QPD->(dbSetOrder(1))
QPD->(dbSeek(xFilial("QPD")+cFatRep))
nPrdInsp := QPD->QPD_ENTINS

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Aplica o Skip-Lote por Producao / Dias                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nCt     := 0
nCtRecu := 1

//Verifica a existencia de Ordens de Producoes ou Apontamentos Recusados
dbSelectArea(cAliasPro)
dbSetOrder(nOrdem1)
dbSeek(xFilial(cAliasPro)+cProduto)
While !Eof() .And. &cCondicao==(xFilial(cAliasPro)+cProduto)
	IF &cVerifi<>0
		QPL->(dbSetOrder(1))
		If QPL->(dbSeek(xFilial("QPL")+xFilial("QPL")+&cChave+cItemGRD+cLabor))

			//Verifica se o Fator do Laudo tem no. producoes a inspecionar
			QPD->(dbSetOrder(1))
			QPD->(dbSeek(xFilial("QPD")+QPL->QPL_LAUDO))
			If QPD->QPD_ENTINS<>0 .And. nCt<=(QPD->QPD_ENTINS-1)
				nCtRecu := 2
				Exit
			EndIf
		EndIf
		nCt++
		If nCt > nPrdInsp
			Exit
		EndIf
	EndIF
	dbSelectArea(cAliasPro)
	dbSkip()
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso haja Ordens de Producoes ou Apontamentos com Laudos reprova-  ³
//³ dos, sera inspecionado.											   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nCtRecu <> 1
	nVerifica := 1
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Controla Skip-Lote por unidade DIA                           	   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If QPF->QPF_UNSKLT == "2"

		//Se a producao anterior foi antes da data limite, inspeciona
		If &cCondicao==(xFilial(cAliasPro)+cProduto) .And. (dProducao<dLimite)
			nVerifica := 1
		Else
			//Procura a producao com data anterior
			dbSelectArea(cAliasPro)
			dbSetOrder(nOrdem1)
			dbSeek(xFilial(cAliasPro)+cProduto)
			While !Eof() .And. &cCondicao==(xFilial(cAliasPro)+cProduto)

				IF cInspecao == "1" //Ordem de Producao
					IF SC2->(C2_FILIAL+C2_PRODUTO) == xFilial(cAliasPro)+cProduto
						If SC2->C2_VERIFI == 0
							SC2->(dbSkip())
							LOOP
						EndIF
					ELSE
						SC2->(dbSkip())
						LOOP
					ENDIF
				ELSEIF cInspecao == "2" //Apontamento
					IF SH6->(H6_FILIAL+H6_PRODUTO) == xFilial(cAliasPro)+cProduto
						If SH6->H6_VERIFI == 0
							SH6->(dbSkip())
							LOOP
						EndIF
					ELSE
						SH6->(dbSkip())
						LOOP
					ENDIF
				ENDIF
				
				//Se nao inspecionou dentro do periodo, inspeciona
				If &cEmissao < dLimite
					nVerifica := 1
					Exit
				EndIf

				//Se já inspecionou dentro do periodo, certifica
				If &cVerifi <> 2
					nVerifica := 2
					Exit
				EndIf

				(cAliasPro)->(dbSkip())
			EndDo
		EndIf
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Controla Skip-Lote por unidade PRODUCAO                      	   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If QPF->QPF_QTDE == 9999 //Free-Pass
			nVerifica := 2 //Certifica
		Else
			If cAliasPro == "SC2"
				nCt := 0

				//Posiciona na ultima Producao cadastrada
				cAliasQry := QIPULTREG(cAliasPro,cProduto,cRevi)
				dbSelectArea(cAliasQry)
				dbGoTop()
				While (cAliasQry)->(!Eof()) .And. &cCondicao==(xFilial(cAliasPro)+cProduto)
					IF(cAliasQry)->C2_VERIFI <> 0
						If (cAliasQry)->C2_VERIFI <> 2
							Exit
						EndIf
						nCt++
					EndIF
					dbSkip(-1)
				EndDo
				(cAliasQry)->(DbCloseArea())

				If nCt >= (QPF->QPF_QTDE-1)
					nVerifica := 1 //Inspeciona
				Else
					nVerifica := 2 //Certifica
				EndIf
			Else  				// Se SH6 apontamentos
				nCt := 0
				nContH6 := 0
				//Posiciona na ultima Producao cadastrada
				dbSelectArea(cAliasPro)
				dbSetOrder(nOrdem1)
				dbSeek(xFilial(cAliasPro)+cProduto)
				While !Eof() .And. &cCondicao==(xFilial(cAliasPro)+cProduto)
					if &cVerifi <> 0
						nContH6++
						If &cVerifi >= 2
							nCt++
						Else
							nCt := 0
						EndIf
					EndIF
					dbSkip()
				EndDo
				if nContH6 > GetMV('MV_QPSKLPR')
					If nCt > (QPF->QPF_QTDE-1)
						nVerifica := 1 //Inspeciona
					Else
						nVerifica := 2 //Certifica
					EndIf
				Else
					nVerifica := 1
				Endif
			EndIf
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Aviso para Ordens de Producoes ou Apontamentos Reprovados.		   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nCtRecu <> 1
	Aadd(aJustif,STR0025) //"Existe Laudo Reprovado ou com Aceitacao "
	Aadd(aJustif,STR0026) //"Condicional nas ultimas producoes."
	aadd(aJustif,STR0024) //"Producao devera ser inspecionada."
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Justificativa para aplicacao do Skip-Lote                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nVerifica == 1
	If Empty(aJustif)
		Aadd(aJustif,STR0024) //"Producao devera ser inspecionada,"
		Aadd(aJustif,STR0027) //"pela avaliacao do Skip-Lote."
	EndIf
Else
	Aadd(aJustif,STR0028) //"Producao podera ser aprovada"
	Aadd(aJustif,STR0029) //"em regime de Skip-Lote Automatico."
EndIf

RestArea(aAreaQP6)
RestArea(aAreaPro)

Return(nVerifica)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³QIPSkipTeste³ Autor ³Paulo Emidio de Barros³ Data³08/10/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calculo do Skip-Teste									  ³±±
±±³          ³ As consistencias realizadas para verificar se aplica o     ³±±
±±³          ³ Skip-Lote valem tbem para o Skip-Teste.                    ³±±
±±³          ³ Forca inspecao de todos os ensaios:1a.producao apos altera-³±±
±±³          ³ cao especificao, producao anterior recusada (mesmas regras ³±±
±±³          ³ do Skip-Lote).                                             ³±±
±±³          ³ Se o parametro para calcular o skip-teste somente para as  ³±±
±±³          ³ producoes inspecionadas estiver ligado, nao calcula o skip-³±±
±±³          ³ teste se a producao for certificada pelo skip-lote.Neste   ³±±
±±³          ³ Caso, na impressao da ficha de uso, os ensaios aparecerao  ³±±
±±³          ³ como certificados tbem.                                    ³±±
±±³          ³ Se o calculo para skip-teste for para todas as producoes,  ³±±
±±³          ³ verifica o skip-teste mesmo que a producao seja certificada³±±
±±³          ³ pelo skip-lote, porque pode ter ensaio a inspecionar, e se ³±±
±±³          ³ o parametro MV_QPCERPR ="N" (nao certifica a producao se   ³±±
±±³          ³ se tiver ensaio a inspecionar pelo skip-teste), forca a    ³±±
±±³          ³ a inspecao da producao.                                    ³±±
±±³          ³ Para gravar os controles de skip-teste(atualizar os conta- ³±±
±±³          ³ dores),verifica o parametro MV_QPSKPTE, para atualizar to- ³±±
±±³          ³ das as producoes ou somente as inspecionadas (verificacao  ³±±
±±³          ³ na gravacao da producao).                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QIPSkipTeste(EXPC1,EXPC2,EXPC3)							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Codigo do Produto								  ³±±
±±³	 	     ³ EXPC2 = Revisao do Produto								  ³±±
±±³	 	     ³ EXPC3 = Fator de Reprovacao do Laudo						  ³±±
±±³	 	     ³ EXPC4 = Roteiro de Operações     						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPA1 = Ensaios marcados para o Skip-Teste				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Integracao QIP x PCP										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QIPSkipTeste(cProduto,cRevi,cFatRep,cRoteiro,lAtualiza)
Local aAreaAnt  := GetArea()
Local aAreaQP6  := QP6->(GetArea())
Local aAreaQPH  := QPH->(GetArea())
Local aAreaQPN  := QPN->(GetArea())
Local aEns	    := {}
Local aEnsPro   := {}
Local nI	    := 0
Local nCt	    := 0
Local nCtRecu   := 0
Local nPrdInsp  := 0
Local cLabor    := CriaVar("QPL_LABOR",.F.)
Local cItemGRD  := CriaVar("C2_ITEMGRD",.F.)
Local cInspecao :=  " "
Local aAreaPro  := {}
Local cAlias    := " "
Local nOrdem    := 0
Local cCondicao := " "
Local cChave    := " "
Local nSklPrd   := GetMv("MV_QPSKLPR") //Indica o Numero de Ordens de Producoes e/ou Apontamentos para aplicacao do Skip-Lote

Default lAtualiza := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Indica onde sera realizada a Inspecao do Material, quando houver   ³
//³ integracao entre o QIP e PCP,sendo as seguintes opcoes:			   ³
//³ 1 - Ordens de Producoes											   ³
//³ 2 - Apontamento das Producoes									   ³
//³ 3 -																   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cInspecao  := GetMV("MV_QINSPEC",.T.,"1")

If cInspecao == "1" //Ordem de Producao
	cAlias    := "SC2"
    aAreaPro  := SC2->(GetArea())
	nOrdem    := 7 //C2_FILIAL+C2_PRODUTO+C2_IDEINV
	cCondicao := "SC2->(C2_FILIAL+C2_PRODUTO)"
	cChave    := "SC2->(C2_NUM+C2_ITEM+C2_SEQUEN)"
ElseIf cInspecao == "2" //Apontamento
	cAlias    := "SH6"
    aAreaPro  := SH6->(GetArea())
	nOrdem    := 2 ///***criar o indice - ordem 4 - h6_filial+h6_produto+h6_ideinv***/// NILTON usado indice valido
	cCondicao := "SH6->(H6_FILIAL+H6_PRODUTO)"
	cChave    := "SH6->H6_OP"
EndIf

cFatRep := If(cFatRep==NIL,FatorQIP("3"),cFatRep)               //Retorna o Fator para definicao de Laudo Reprovado
cRevi   := If(cRevi==NIL,QA_UltRevEsp(cProduto,,,,"QIP"),cRevi) //Retorna a Revisao do Produto

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Quantidade de Ordens de Producoes ou Apontamentos a inspecionar com³
//³ o Fator  Reprovado.												   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QPD")
QPD->(dbSetOrder(1))
QPD->(dbSeek(xFilial("QPD")+cFatRep))
nPrdInsp := QPD->QPD_ENTINS

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Identifica os Ensaios utilizados na Producao                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//Ensaios mensuraveis
QP7->(dbSetOrder(1))
QP7->(dbSeek(xFilial("QP7")+cProduto+cRevi+cRoteiro))
While QP7->(!Eof()) .And. QP7->(QP7_FILIAL+QP7_PRODUT+QP7_REVI+QP7_CODREC)==(xFilial("QP7")+cProduto+cRevi+cRoteiro)
	Aadd(aEnsPro,QP7->QP7_CODREC+QP7->QP7_OPERAC+QP7->QP7_ENSAIO)
	QP7->(dbSkip())
EndDo

//Ensaios Texto
QP8->(dbSetOrder(1))
QP8->(dbSeek(xFilial("QP8")+cProduto+cRevi+cRoteiro))
While QP8->(!Eof()) .And. QP8->(QP8_FILIAL+QP8_PRODUT+QP8_REVI+QP8_CODREC)==(xFilial("QP8")+cProduto+cRevi+cRoteiro)
	Aadd(aEnsPro,QP8->QP8_CODREC+QP8->QP8_OPERAC+QP8->QP8_ENSAIO)
	QP8->(dbSkip())
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a existencia de Ordens de Producoes ou Apontamentos recu- ³
//³ sados.															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nCt     := 0
nCtRecu := 1

dbSelectArea(cAlias)
dbSetOrder(nOrdem)
dbSeek(xFilial(cAlias)+cProduto)
While !Eof() .And. (&cCondicao)==(xFilial(cAlias)+cProduto)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o Fator do Laudo possui Producoes a Inspecionar		   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QPL->(dbSetOrder(1))
	If QPL->(dbSeek(xFilial("QPL")+&cChave+cItemGRD+cLabor))
		QPD->(dbSetOrder(1))
		QPD->(dbSeek(xFilial("QPD")+QPL->QPL_LAUDO))
		If (QPD->QPD_ENTINS <> 0) .And. (nCt <= (QPD->QPD_ENTINS-1))
			nCtRecu := 2
			nCt		:= 0
		Else
			nCtRecu := 1
		EndIf
	EndIf

	nCt++
	If (nCt>nPrdInsp)
		Exit
	EndIf

	dbSelectArea(cAlias)
	dbSkip()
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula o Skip-Teste											   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 to Len(aEnsPro)

	//Verifica se h  skip-teste individual definido
	QPH->(dbSetOrder(1)	)
	If QPH->(dbSeek(xFilial("QPH")+cProduto+aEnsPro[nI]))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Caso haja Ordem de Producao ou Apontamento anterior com Laudo Repro³
		//³ vado, inspeciona o ensaio.										   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nCtRecu <> 1
			Aadd(aEns,{Substr(aEnsPro[nI],5,8),1,Substr(aEnsPro[nI],3,2)})
		Else
			If lAtualiza .And. nSklPrd > 1 .And. nCt <= nSklPrd
				Aadd(aEns,{Substr(aEnsPro[nI],5,8),1,Substr(aEnsPro[nI],3,2)})
			Else
				//Verifica se o ensaio dever  ser inspecionado
				QPN->(dbSetOrder(1))
				If QPN->(!dbSeek(xFilial("QPN")+cProduto+aEnsPro[nI]))
					Aadd(aEns,{Substr(aEnsPro[nI],5,8),1,Substr(aEnsPro[nI],3,2)})
				Else
					If (QPN->QPN_CONTAD+1) > QPH->QPH_SKPTES
						Aadd(aEns,{Substr(aEnsPro[nI],5,8),1,Substr(aEnsPro[nI],3,2)})
					Else
						Aadd(aEns,{Substr(aEnsPro[nI],5,8),QPN->QPN_CONTAD+1,Substr(aEnsPro[nI],3,2)})
					EndIf
				EndIf
			Endif
		EndIf
	Else
		dbSelectArea("QPA")
		QPA->(dbSetOrder(2))
		If QPA->(dbSeek(xFilial("QPA")+cProduto))
			cGrupo := QPA->QPA_GRUPO //Define o Grupo de Produtos
			//Verifica se eh skip-teste em grupo
			QPI->(dbSetOrder(1)	)
			If QPI->(dbSeek(xFilial("QPI")+cGrupo+aEnsPro[nI]))
				If nCtRecu <> 1
					Aadd(aEns,{Substr(aEnsPro[nI],5,8),1,Substr(aEnsPro[nI],3,2)})
				Else
					If lAtualiza .And. nSklPrd > 0 .And. nCt <= nSklPrd
						Aadd(aEns,{Substr(aEnsPro[nI],5,8),1,Substr(aEnsPro[nI],3,2)})
					Else
					//Verifica se o ensaio dever  ser inspecionado
						QPO->(dbSetOrder(1))
						If !QPO->(dbSeek(xFilial("QPO")+cGrupo+aEnsPro[nI]))
							Aadd(aEns,{Substr(aEnsPro[nI],5,8),1,Substr(aEnsPro[nI],3,2)})
						Else
							If (QPO->QPO_CONTAD+1) > QPI->QPI_SKPTES
								Aadd(aEns,{Substr(aEnsPro[nI],5,8),1,Substr(aEnsPro[nI],3,2)})
							Else
								Aadd(aEns,{Substr(aEnsPro[nI],5,8),QPO->QPO_CONTAD+1,Substr(aEnsPro[nI],3,2)})
							EndIf
						EndIf
					Endif
				EndIf
			Endif
		Endif
	EndIf
Next nI

RestArea(aAreaQP6)
RestArea(aAreaQPH)
RestArea(aAreaQPN)
RestArea(aAreaPro)
RestArea(aAreaAnt)
Return(aEns)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³QIPAtuSkipTeste³Autor³Paulo Emidio de Barros³Data³13/10/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza o Controle do Skip-Teste						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QIPAtuSkipTeste(EXPC1,EXPC2,EXPC3,EXPD1,EXPC4,EXPC5,;      ³±±
±±³	 	     ³				   EXPN1,EXPN2,EXPL1)						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Codigo do Produto           						  ³±±
±±³	 	     ³ EXPC2 = Revisao do Produto                                 ³±±
±±³	 	     ³ EXPC3 = Codigo do Roteiro de Operacoes   			      ³±±
±±³	 	     ³ EXPD1 = Data da Ordem de Producao ou Apontamento           ³±±
±±³	 	     ³ EXPC4 = Numero da Ordem de Producao               		  ³±±
±±³	 	     ³ EXPC5 = Numero do Lote									  ³±±
±±³	 	     ³ EXPN1 = 1-Inspeciona 2-Certifica                           ³±±
±±³	 	     ³ EXPN2 = Quantidade a Ordem de producao ou Apontamento      ³±±
±±³	 	     ³ EXPL1 = Indica se a opcao sera a exclusao do Skip-Teste	  ³±±
±±³	 	     ³ Obs. A operacao do Roteiro nao devera ser gravada no	con-  ³±±
±±³	 	     ³ 		trole do Skip-Teste.								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL                                                   	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Integracao QIP x PCP										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QIPAtuSkipTeste(cProduto,cRevisao,cRoteiro,dProducao,cOP,cLote,nVerifi,nQuantidade,lDeleta)
Local dValidade  := Ctod(" ")
Local cMvSkTes	 := GetMv("MV_QPSKPTE")
Local cGrupo	 := " "
Local aEnsInsp	 := {}
Local cFatApr    := FatorQIP("1") //Define o fator Aprovado
Local cFatRep    := FatorQIP("3") //Define o fator Reprovado
Local nDias		 := 0
Local aAreaQPA	 := QPA->(GetArea())
Local aAreaQPH	 := QPH->(GetArea())
Local aAreaQPN	 := QPN->(GetArea())
Local aAreaQPI	 := QPI->(GetArea())
Local aAreaQPO	 := QPO->(GetArea())
Local aAreaQP6	 := QP6->(GetArea())
Local nX		 := 0
Local aAreaAnt   := GetArea()
Local nTamLot    := TamSX3("QPK_LOTE")[1]
Local lQPGRVST 	 := ExistBlock("QPGRVST")

cRevisao := If(cRevisao==NIL,QA_UltRevEsp(cProduto,,.F.,,"QIP"),cRevisao) //Retorna a Revisao corrente do produto,caso a mesma nao seja passada como parametro
cLote    := IIf(cLote==NIL .Or. Empty(Alltrim(cLote)),Space(nTamLot),cLote) //Formata o Numero da OP para o controle do Skip-Teste, caso nao seja definido
lDeleta  := If(lDeleta==NIL,.F.,lDeleta)

If cRoteiro == NIL //Caso o Roteiro de Operacoes nao esteja definido
	QP6->(dbSetOrder(1))
	QP6->(dbSeek(xFilial("QP6")+cProduto+Inverte(cRevisao)))
	cRoteiro := QP6->QP6_CODREC
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava o Controle do Skip-Teste									   ³
//³ 	1-Todas as Ordens de Producoes ou Apontamentos				   ³
//³ 	2-Somente as Ordens de Producoes ou Apontamentos Inspecionados ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (cMvSkTes=="1") .Or. (cMvSkTes=="2" .And. nVerifi<>2)

	dbSelectArea("QPA")
	QPA->(dbSetOrder(2))
	If QPA->(dbSeek(xFilial("QPA")+cProduto))
		cGrupo := QPA->QPA_GRUPO //Define o Grupo de Produtos
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula o Skip-Teste											   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aEnsInsp := QIPSkipTeste(cProduto,cRevisao,cFatRep,cRoteiro,!lDeleta)

	For nX := 1 to Len(aEnsInsp)

		//Verifica se h  definicao de Skip-Teste Individual
		dbSelectArea("QPH")
		QPH->(dbSetOrder(1))
		If QPH->(dbSeek(xFilial("QPH")+cProduto+cRoteiro+aEnsInsp[nX,3]+aEnsInsp[nX,1]))

			//Atualiza o controle do Skip-Teste Individual
			dbSelectArea("QPN")
			QPN->(dbSetOrder(1))
			QPN->(dbSeek(xFilial("QPN")+cProduto+cRoteiro+aEnsInsp[nX,3]+aEnsInsp[nX,1]))
			If QPN->(Eof()) .And. !lDeleta //Atualizacao do Skip-Teste Individual
				RecLock("QPN", .T.)
				QPN->QPN_FILIAL	:= xFilial("QPN")
				QPN->QPN_PRODUT	:= cProduto
				QPN->QPN_ENSAIO	:= aEnsInsp[nX,1]
				QPN->QPN_CODREC	:= cRoteiro
				QPN->QPN_OPERAC := aEnsInsp[nX,3]
				QPN->QPN_CONTAD	:= 1
			Else
				RecLock("QPN", .F.)
				If !lDeleta //Atualizacao do Skip-Teste Individual
					QPN->QPN_CONTAD := aEnsInsp[nX,2]
				Else
					//Estorno do Skip-Teste Individual
					QPN->QPN_CONTAD := If(QPN->QPN_CONTAD<>1,QPN->QPN_CONTAD--,QPH->QPH_SKPTES)
				EndIf
			EndIf
			MsUnLock()

			If !lDeleta //Atualizacao do Skip-Teste Individual
				If aEnsInsp[nX,2] == 1	//Indica que inspecionou
					//Atualiza o Historico do Skip-Teste Individual
					dbSelectArea("QPY")
					RecLock("QPY", .T.)
					QPY->QPY_FILIAL	:= xFilial("QPY")
					QPY->QPY_PRODUT	:= cProduto
					QPY->QPY_ENSAIO	:= aEnsInsp[nX,1]
					QPY->QPY_CODREC	:= cRoteiro
					QPY->QPY_OPERAC	:= aEnsInsp[nX,3]
					QPY->QPY_DTENTR	:= dProducao
					QPY->QPY_LOTE		:= cLote
					QPY->QPY_ORDPRD	:= cOP
					MsUnLock()
				EndIf

				If lQPGRVST .And. AllTrim(FunName())=="MATA650"
	 				ExecBlock("QPGRVST",.F.,.F.,{cProduto,cRevisao,cRoteiro,aEnsInsp[nX,1],aEnsInsp[nX,3]})
				EndIf
			Else
				//Exclusao do Historico do Skip-Teste Individual
				dbSelectArea("QPY")
				QPY->(dbSetorder(1))
				QPY->(dbSeek(xFilial("QPY")+cRoteiro+aEnsInsp[nX,3]+cProduto+dTos(dProducao)+cLote+aEnsInsp[nX,1]))
				If QPY->(!Eof())
					RecLock("QPY",.F.)
					dbDelete()
				    MsUnLock()
			    EndIf
			EndIf

		Else

			//Verifica se h  definicao de Skip-Teste por Grupo
			dbSelectArea("QPI")
			QPI->(dbSetOrder(1))
			If QPI->(dbSeek(xFilial("QPI")+cGrupo+cRoteiro+aEnsInsp[nX,3]+aEnsInsp[nX,1]))

				//Atualiza o Controle do Skip-Teste por Grupo
				dbSelectArea("QPO")
				QPO->(dbSetOrder(1))
				QPO->(dbSeek(xFilial("QPO")+cGrupo+cRoteiro+aEnsInsp[nX,3]+aEnsInsp[nX,1]))
				If QPO->(Eof()) .And. !lDeleta //Atualizacao do Skip-Teste em Grupo
					RecLock("QPO", .T.)
					QPO->QPO_FILIAL	:= xFilial("QPO")
					QPO->QPO_GRUPO 	:= cGrupo
					QPO->QPO_ENSAIO	:= aEnsInsp[nX,1]
					QPO->QPO_DTENTR	:= dProducao
					QPO->QPO_CODREC	:= cRoteiro
					QPO->QPO_OPERAC	:= aEnsInsp[nX,3]
					QPO->QPO_CONTAD	:= 1
				Else
					RecLock("QPO", .F.)
					If !lDeleta //Atualizacao do Skip-Teste em Grupo
						QPO->QPO_CONTAD := aEnsInsp[nX,2]
					Else
						//Estorno do Skip-Teste em Grupo
						QPO->QPO_CONTAD := If(QPO->QPO_CONTAD<>1,QPO->QPO_CONTAD--,QPI->QPI_SKPTES)
					EndIf

				EndIf

				If !lDeleta //Atualizacao do Skip-Teste em Grupo

					//Guarda a Data Producao ou Apontamento que inspecionou o Ensaio
					If QPO->QPO_CONTAD == 1
						QPO->QPO_DTENTR	:= dProducao
					EndIf
					MsUnLock()

					If aEnsInsp[nX,2] == 1	//Indica que inspecionou

						//Atualiza o Historico do Skip-Teste por Grupo
						dbSelectArea("QPZ")
						RecLock("QPZ", .T.)
						QPZ->QPZ_FILIAL	:= xFilial("QPZ")
						QPZ->QPZ_GRUPO 	:= cGrupo
						QPZ->QPZ_DTENTR	:= dProducao
						QPZ->QPZ_ENSAIO	:= aEnsInsp[nX,1]
						QPZ->QPZ_LOTE	:= cLote
						QPZ->QPZ_PRODUT	:= cProduto
						QPZ->QPZ_CODREC	:= cRoteiro
						QPZ->QPZ_OPERAC := aEnsInsp[nX,3]
						MsUnLock()
					EndIf

					If lQPGRVST .And. AllTrim(FunName())=="MATA650"
	 					ExecBlock("QPGRVST",.F.,.F.,{cGrupo,cRevisao,cRoteiro,aEnsInsp[nX,1],aEnsInsp[nX,3]})
					EndIf
                Else
                	QPZ->(dbSetOrder(1))
                	QPZ->(dbSeek(xFilial("QPZ")+cGrupo+DtoS(dProducao)+cLote+aEnsInsp[nX,1]))
                	If QPZ->(!Eof())
                		RecLock("QPZ",.F.)
                		dbDelete()
                		MsUnLock()
                    EndIf
                EndIf

			EndIf
		EndIf
	Next nX
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula a Validade do Laudo da Ordem de Producao ou Apontamento    ³
//³ Obs. Na exclusao nao estorna o Laudo, pois devera ser excluido os  ³
//³ 	 Resultados. 												   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lDeleta
	If nVerifi == 2 //Certifica a Ordem de Producao ou Apontamento

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula a Validade do Laudo da Ordem de Producao ou Apontamento    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		QP6->(dbSetOrder(1))
		QP6->(dbSeek(xFilial("QP6")+cProduto+Inverte(cRevisao)))

		//Verifica a Unidade do Shelf-Life
		If QP6->QP6_SHLF <> 0
			If QP6->QP6_TPSLIF == "1" //Dia
				nDias := QP6->QP6_SHLF
			ElseIf QP6->QP6_TPSLIF == "2" //Mes
				nDias := (QP6->QP6_SHLF*30)
			ElseIf QP6->QP6_TPSLIF == "3" //Hora
				nDias := (QP6->QP6_SHLF/24)
			ElseIf QP6->QP6_TPSLIF == "4" //Ano
				nDias := (QP6->QP6_SHLF*365)
			EndIf
			dValidade := If(nDias<>0,dDataBase+nDias,Ctod(""))
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualizacao do Laudo da Ordem de Producao ou Apontamento de Produ- ³
		//³ cao que possuem Certificacao por Skip-Lote e/ou Skip-Teste.        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("QPL")
		RecLock("QPL",.t.)
		QPL->QPL_FILIAL	:= xFilial("QPL")
		QPL->QPL_OP 	:= cOP
		QPL->QPL_PRODUT	:= cProduto
		QPL->QPL_DTENTR	:= dProducao
		QPL->QPL_LOTE   := cLote
		QPL->QPL_LABOR	:= CriaVar("QPL_LABOR",.F.)
		QPL->QPL_OPERAC	:= CriaVar("QPL_OPERAC",.F.)
		QPL->QPL_TAMLOT	:= Str(nQuantidade)
		QPL->QPL_DTENLA	:= dDataBase
		QPL->QPL_HRENLA	:= Left(Time(),5)
		QPL->QPL_LAUDO	:= cFatApr
		QPL->QPL_DTLAUD	:= dDataBase
		QPL->QPL_HRLAUD	:= Left(Time(),5)
		QPL->QPL_DTVAL	:= dValidade
		QPL->QPL_JUSTLA	:= GetMv("MV_QPJUSLA")	//Justificativa do Laudo para Ordem de Producao e/ou Apontamento Certificados
		QPL->QPL_DTDILA	:= dDataBase
		QPL->QPL_HRDILA	:= Left(Time(),5)
		QPL->QPL_ROTEIR := cRoteiro
		MsUnLock()
		QPL->(FKCOMMIT())

	  EndIf

	If QP6->(FieldPos("QP6_ALTESP"))>0
		QP6->(dbSetOrder(1))
	 	If QP6->(dbSeek(xFilial("QP6")+cProduto+Inverte(cRevisao)))
			Reclock("QP6",.F.)
			QP6->QP6_ALTESP	:= If(lAltEsp,"S","N")
			MsUnLock()
		EndIf
	EndIf
EndIf

RestArea(aAreaQPA)
RestArea(aAreaQPH)
RestArea(aAreaQPN)
RestArea(aAreaQPI)
RestArea(aAreaQPO)
RestArea(aAreaQP6)
RestArea(aAreaAnt)

Return(NIL)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³QP650VeSk ³ Autor ³ Marcelo Pimentel      ³ Data ³ 22/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica qual a situacao do Produto : Inspec / Certifica.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ MATA650 - C2_VERIFI - X3_WHEN					          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QP650VeSk(lAtuMat)
Return(QIPSitInsPro(lAtuMat))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ QIPSitInsPro ³Autor³ Paulo Emidio de Barros³Data³25/10/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se a Situacao do Produto na Ordem de Producao ou  ³±±
±±³ 		 ³ Apontamento sera de: Inspecao ou Certificacao, de acordo   ³±±
±±³			 ³ com os criterios referentes a Skip-Teste e Skip-Lote.	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QIPSitInsPro() 										      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPL1 = T (VERDADEIRO)                                  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Integracao QIP x PCP										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QIPSitInsPro(lAtuMat)
Local aAreaAnt  := GetArea()
Local aOpc	    := {}
Local aAreaSB1  := SB1->(GetArea())
Local aAreaQPA  := QPA->(GetArea())
Local nSklPrd   := GetMv("MV_QPSKLPR") //Indica o Numero de Ordens de Producoes e/ou Apontamentos para aplicacao do Skip-Lote
Local nCntPrd   := 0
Local cGrupo    := " "
Local nI	    := 0
Local cRevi	    := " "
Local cFatRep   := FatorQIP("3") //Fator IQP com categoria = Reprovado
Local aEnsInsp  := {}
Local cSkpTst   := " "
Local lCerProd  := If(GetMv("MV_QPCERPR")=="S",.T.,.F.) //Indica havera certificacao da Ordem de Producao ou Apontamento caso haja ensaios a inspecionar em regime de Skip-Teste.
Local cInspecao := " "
Local aAreaPro  := {}
Local cAliasPro := " "
Local nOrdemPro := 0
Local cProduto  := " "
Local cVerifi   := " "
Local cInsCer   := " "
Local cEmissao  := " "
Local cRoteiro  := " "
Local cCompVer  := " "
Local cCondWhile:= " "

Private nVerifica := 1 //Inspecionar
PRIVATE lAltEsp		:= .F. // Indica se ‚ a 1a. Entrada ap¢s alteracao especificacao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Indica onde sera realizada a Inspecao do Material, quando houver   ³
//³ integracao entre o QIP e PCP,sendo as seguintes opcoes:			   ³
//³ 1 - Ordens de Producoes											   ³
//³ 2 - Apontamento das Producoes									   ³
//³ 3 -																   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cInspecao  := GetMV("MV_QINSPEC",.T.,"1")

Default lAtuMat     := .F.

If cInspecao == "1" //Ordem de Producao
 	aAreaPro  := SC2->(GetArea())
	cAliasPro := "SC2"
	nOrdemPro := 2 //C2_FILIAL+C2_PRODUTO+DTOS(C2_DATPRF)
	cCondicao := "SC2->(C2_FILIAL+C2_PRODUTO)"
	If lAtuMat
		cProduto  := "SC2->C2_PRODUTO"
		cVerifi   := "SC2->C2_VERIFI"
		cInsCer   := "SC2->C2_INSCER"
		cEmissao  := "SC2->C2_EMISSAO"
		cRoteiro  := "SC2->C2_ROTEIRO"
	Else
		cProduto  := "M->C2_PRODUTO"
		cVerifi   := "M->C2_VERIFI"
		cInsCer   := "M->C2_INSCER"
		cEmissao  := "M->C2_EMISSAO"
		cRoteiro  := "M->C2_ROTEIRO"
	EndIF
	cCompVer      := "SC2->C2_VERIFI"

ElseIf cInspecao == "2" //Apontamento
	aAreaPro  := SH6->(GetArea())
	cAliasPro := "SH6"
	nOrdemPro := 2 ///***DEFINIR ORDEM C2_FILIAL+C2_PRODUTO+DTOS(C2_DATPRF) NILTON INDICE VALIDO
	If lAtuMat
		cProduto  := "SH6->H6_PRODUTO"
		cVerifi   := "SH6->H6_VERIFI"
		cInsCer   := "SH6->H6_INSCER"
		cEmissao  := "SH6->H6_DTPROD"
		cRoteiro  := "SH6->H6_OPERAC"
	Else
		cProduto  := "M->H6_PRODUTO"
		cVerifi   := "M->H6_VERIFI"
		cInsCer   := "M->H6_INSCER"
		cEmissao  := "M->H6_DTPROD"
	Endif
	cCondicao := "SH6->(H6_FILIAL+H6_PRODUTO)"
	cCompVer  := "SH6->H6_VERIFI"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define como sera aplicado o Skip-Teste: 1= Todas as OP,s ou Apon-  ³
//³ tamento 2=Somente as OP's ou Apontamentos a Inspecionar.		   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSkpTst := GetMv("MV_QPSKPTE")

If ReadVar()==cVerifi .or. lAtuMat //M->H6_VERIFI M->C2_VERIFI

	cRevi := QA_UltRevEsp(&cProduto,,.F.,,"QIP")	//Retorna a revisao vigente do produto.

	If !Inclui .and. !lAtuMat
		Return(.F.)
	EndIf

	aJustif := {} //Justificativas

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define as opecoes: Inspecionar/Certificar                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aOpc,{STR0013,1}) //"Inspecionar"
	Aadd(aOpc,{STR0014,2}) //"Certificar"

	//Posiciona a Especificacao do Produto
	QP6->(dbSetOrder(1))
	QP6->(dbSeek(xFilial("QP6")+&cProduto))

	//Posiciona na Categoria da Situacao do Produto
	QPG->(dbSetOrder(1))
	QPG->(dbSeek(xFilial("QPG")+QP6->QP6_SITPRD))

	//Posiciona o Grupo de Produtos
	QPA->(dbSetOrder(2))
	If QPA->(dbSeek(xFilial("QPA")+&cProduto))
		cGrupo := QPA->QPA_GRUPO
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Realiza as consistencias iniciais que indicam a Inspecao           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QIPConIni(&cProduto,cRevi,&cEmissao,aJustif,@nVerifica)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se a situacao do Produto for igual a "A" = (Skip-Lote Total), ou   ³
	//³ "B" = (Skip-Lote 25%), Verifica o mesmo.						   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If QPG->QPG_CATEG $ "1ß2"

		If Len(aJustif) == 0 //Caso haja justificativa definida, o Skip-Lote nao sera verificado

			If nSklPrd > 1
				aArea := (cAliasPro)->(GetARea())
				dbSelectArea(cAliasPro)
				dbSetOrder(nOrdemPro)
				IF dbSeek(xFilial(cAliasPro)+&cProduto)
					cCondWhile := xFilial(cAliasPro)+&cProduto
					While !Eof() .And. (xFilial(cAliasPro)+&cProduto) == cCondWhile
						If &cCompVer <> 0
							nCntPrd++
							If nCntPrd >= nSklPrd
								Exit
							EndIf
						EndIF
						(cAliasPro)->(dbSkip())
					EndDo
				ENDIF
				RestArea(aArea)
				
				If nCntPrd >= nSklPrd

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica o Skip-Lote	                                           ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					QIPSkipLote(&cProduto,cRevi,&cEmissao,aJustif,,@nVerifica)

                    //Verifica se o Skip-Teste sera calculado
					If (cSkpTst=="1") .Or. (cSkpTst=="2" .And. nVerifica==1)

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Calcula o Skip-Teste	                                           ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aEnsInsp := QIPSkipTeste(&cProduto,cRevi,cFatRep,&cRoteiro)

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica se a Ordem de Producao ou Apontamento podera ser Certifi- ³
						//³ cado, caso haja ensaio a inspecionar pelo skip-teste. 			   ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If (nVerifica==2 .And. !lCerProd)

							For nI := 1 To Len(aEnsInsp)
								If aEnsInsp[nI,2]==1
									aJustif := {}
									Aadd(aJustif,STR0015) //"Producao sera inspecionada por ter ensaio a inspecionar "
									Aadd(aJustif,STR0016) //"(skip-teste)."
									nVerifica := 1
									Exit
								EndIf
							Next nI
						EndIf
					EndIf
				Else
					// Justificativa para a Inspecao
					Aadd(aJustif,STR0017) //"Nao ha o numero de Producoes iniciais "
					Aadd(aJustif,STR0018) //"necessario para a aplicacao Skip-Lote."
					Aadd(aJustif,STR0019) //"A Producao devera ser inspecionada."
				EndIf
			Else

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Aplica o Skip-Lote                                                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				QIPSkipLote(&cProduto,cRevi,&cEmissao,aJustif,,@nVerifica)

                //Verifica se o Skip-Teste sera calculado
				If (cSkpTst=="1") .Or. (cSkpTst=="2" .And. nVerifica==1)

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Calcula o Skip-Teste  	                                           ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aEnsInsp := QIPSkipTeste(&cProduto,cRevi,cFatRep,&cRoteiro)

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica se a Ordem de Producao ou Apontamento podera ser Certifi- ³
					//³ cado, caso haja ensaio a inspecionar pelo skip-teste. 			   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If (nVerifica==2 .And. !lCerProd)

						For nI := 1 To Len(aEnsInsp)
							If aEnsInsp[nI,2] == 1
								aJustif := {}
								Aadd(aJustif,STR0015) //"Producao sera inspecionada por ter ensaio a inspecionar "
								Aadd(aJustif,STR0016) //"(skip-teste)."
								nVerifica := 1
								Exit
							EndIf
						Next nI
					EndIf
				EndIf
			EndIf

		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exibe a opcao sugerida: 1=Inspeciona 2=Certifica				   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lAtuMat
			nVerifica := QA_Choice(aOpc,aJustif,nVerifica,STR0020) //"Tipo de Inspecao"
		EndIF

	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualizacao do campo: Insp/Certif.                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lAtuMat
		&cVerifi := nVerifica
		&cInsCer := QP650DIC(nVerifica,.T.)
	EndIf

EndIf

RestArea(aAreaSB1)
RestArea(aAreaQPA)
RestArea(aAreaPro)
RestArea(aAreaAnt)

Return (IIF(!lAtuMat,.T.,nVerifica))

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³QPFilRotNew ³ Autor³Paulo Emidio de Barros³ Data ³12/03/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Filtra o SG2 por chave unica								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QPFilRotNew()											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ MATA650 													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QPFilRotNew()
Return(M->C2_PRODUTO==SG2->G2_PRODUTO .And. UniqueKey("G2_CODIGO","SG2"))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QPATUQQK  ºAutor  ³Cleber Souza		 º Data ³  01/03/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao utilizado para geração da tabela QQK (Log das Opera º±±
±±º          ³ coes para que naum haja a duplicação do SG2.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QIP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QPATUQQK(cProduto)

Processa({|| QPPROCQQK(cProduto) },STR0041) //"Processando..."

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QGeraQQK  ºAutor  ³Cleber Souza		 º Data ³  01/03/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rdmake utilizado para geração da tabela QQK (Log das Opera º±±
±±º          ³ coes para que naum haja a duplicação do SG2.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QIP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QPPROCQQK(cProduto)

Local cRevisao  := ""
Local cPesqG2   := ""
Local aStruSG2  := FWFormStruct(3, "SG2")[3]
Local nX
Local cCampoAux	:=	""

Default cProduto := ""

If Empty(cProduto)
	cPesqG2 := "SG2->(!EOF())"
Else
	cPesqG2 := "'"+ cProduto + "' == SG2->G2_PRODUTO .AND. SG2->(!EOF())"
EndIf


If Empty(cProduto)
	SG2->(dbSetOrder(1))
	SG2->(dbGoTop())
Else
	SG2->(dbSetOrder(1))
	SG2->(dbSeek(xFilial("SG2")+cProduto))
EndIF
ProcRegua(SG2->(RecCount()))

While &(cPesqG2)

	cRevisao := QA_UltRvQ(SG2->G2_PRODUTO,,.F.)
	cRevisao := IIF(Empty(cRevisao),"00",cRevisao)

	If Empty(SG2->G2_REVIPRD)
		dbSelectArea("SG2")
		RecLock("SG2",.F.)
		SG2->G2_REVIPRD := cRevisao
		MsUnlock()
	EndIF

	QQK->(dbSetOrder(1))
	QQK->(dbSeek(xFilial("QQK")+SG2->G2_PRODUTO+SG2->G2_REVIPRD+SG2->G2_CODIGO+SG2->G2_OPERAC))
	If QQK->(Eof())
		RecLock("QQK",.T.)
		QQK->QQK_FILIAL := xFilial("QQK")
		QQK->QQK_CODIGO := SG2->G2_CODIGO
		QQK->QQK_PRODUT := SG2->G2_PRODUTO
		QQK->QQK_OPERAC := SG2->G2_OPERAC
		QQK->QQK_REVIPR := SG2->G2_REVIPRD
	Else
		RecLock("QQK",.F.)
	EndIF

	QQK->QQK_RECURS := SG2->G2_RECURSO
	QQK->QQK_FERRAM := SG2->G2_FERRAM
	QQK->QQK_LINHAP := SG2->G2_LINHAPR
	QQK->QQK_TPLINH := SG2->G2_TPLINHA
	QQK->QQK_DESCRI := SG2->G2_DESCRI
	QQK->QQK_MAOOBR := SG2->G2_MAOOBRA
	QQK->QQK_SETUP  := SG2->G2_SETUP
	QQK->QQK_FORMST := SG2->G2_FORMSTP
	QQK->QQK_LOTEPA := SG2->G2_LOTEPAD
	QQK->QQK_TEMPAD := SG2->G2_TEMPAD
	QQK->QQK_TPOPER := SG2->G2_TPOPER
	QQK->QQK_TPSOBR := SG2->G2_TPSOBRE
	QQK->QQK_TEMPSO := SG2->G2_TEMPSOB
	QQK->QQK_TPDESD := SG2->G2_TPDESD
	QQK->QQK_TEMPDE := SG2->G2_TEMPDES
	QQK->QQK_DESPRO := SG2->G2_DESPROP
	QQK->QQK_CTRAB  := SG2->G2_CTRAB
	QQK->QQK_OPE_OB := SG2->G2_OPE_OBR
	QQK->QQK_SEQ_OB := SG2->G2_SEQ_OBR
	QQK->QQK_LAU_OB := SG2->G2_LAU_OBR
    QQK->QQK_CHAVE  := fGravSG2()    //Cria nova chave para a Observacao da Operacao
	QQK->QQK_ROTALT := SG2->G2_ROTALT
	QQK->QQK_OPERGR := SG2->G2_OPERGRP
	QQK->QQK_GRSETU := SG2->G2_GRSETUP
	QQK->QQK_GRUPRE := SG2->G2_GRUPREC
	QQK->QQK_NIVMON := SG2->G2_NIVMONT
	QQK->QQK_CHAVMO := SG2->G2_CHAVMON
	QQK->QQK_TMAXPR := SG2->G2_TMAXPRO
	QQK->QQK_TPINTE := SG2->G2_TPINTER
	QQK->QQK_MAXINC := SG2->G2_MAXINCR
	QQK->QQK_FOLMIN := SG2->G2_FOLMIN
	QQK->QQK_HOROTI := SG2->G2_HOROTIM
	MsUnLock()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Copia dos campos de usuario 												³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 To Len(aStruSG2)
		If GetSx3Cache(aStruSG2[nX,1], "X3_PROPRI") == "U" .And. GetSx3Cache(aStruSG2[nX,1], "X3_CONTEXT") <> "V"
			//Verifica se o campo existe no SG2
			cCampoAux := AllTrim("QQK_" + Substr(aStruSG2[nX,1], At("_", aStruSG2[nX,1])+1, (Len(aStruSG2[nX,1])-At("_", aStruSG2[nX,1]))))
			If !Empty(GetSX3Cache(cCampoAux,"X3_CAMPO"))
				RecLock("QQK",.F.)
				QQK->(FieldPut(FieldPos(cCampoAux),&("SG2->"+Alltrim(aStruSG2[nX,1]))))
				MsUnlock()
			EndIf
		EndIf
	Next nX

	IncProc(STR0042 + Alltrim(SG2->G2_PRODUTO)+ STR0043 +SG2->G2_REVIPRD) //"Produto: "###" Revisao: "
	SG2->(dbSkip())

EndDo

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QPValFor  ºAutor  ³Denis Martins       º Data ³  03/08/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao responsavel por verificar se existe # no campo de forº±±
±±º          ³mula para ensaios calculados.                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QIPXFUN                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QPValFor(cFormAt,aEnsaio)
Local nC := 0

If !Empty(cFormAt)
	For nC := 1 To Len(aEnsaio)
		If (Alltrim(aEnsaio[nC]) $ cFormAt) .and. At("#",cFormAt) = 0
			MessageDlg(STR0044,,3)//"Foi detectado que a formula pode estar utilizando ensaios. Sugerimos que todos os ensaios sejam incluidos atraves de duplo click - campo Operadores."
			Exit
		Endif
	Next nC
Endif
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ QIPValEns ³ Autor ³Leandro               ³ Data ³02/06/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Verifica se o Produto possui ensaios                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QIPValEns(cProd, cRev, cRot, lForcaMsg)
Local aArea := GetArea()
Local lMsg  := .F.
Local lRet	:= .T.
Local lQBLOESP := If(GetMV("MV_QBLOESP",.F.,"2") == "2",.F.,.T.) //Devido a integracao do PCP com o QIP, bloqueia se nao tiver Especifacao. 1 = Sim/ 2 =Nao
Local lProduto
Local lQipMat  := .T.

Default lForcaMsg := .F.

dbSelectArea("SB1")
SB1->(dbSetOrder(1))
lProduto := SB1->(MsSeek(xFilial("SB1")+cProd))


If Empty(cRev)
	cRev := QA_UltRvQ(cProd,,.F.)
Endif

dbSelectArea("QP7")
dbSetOrder(1)
If !dbSeek(xFilial("QP7")+cProd+cRev+cRot)
	dbSelectArea("QP8")
	dbSetOrder(1)
	If !dbSeek(xFilial("QP8")+cProd+cRev+cRot)
		lMsg := .T.
		lRet := .F.
	Endif
Endif

If Existblock("QIP650ENSCAD")
	lMsg := Execblock("QIP650ENSCAD",.F.,.F.)
Endif

lQipMat :=  IIF((lProduto .and. SB1->B1_TIPOCQ <> 'Q'), .F. , .T.)

If lMsg .And. (!IsBlind() .Or. lQBLOESP .Or. lForcaMsg) .and. lQipMat//-- IsBlind e MV_QBLOESP incluidos para nao retornar erro na execauto do MATA650
     HELP(" ",1,"QIP650ENSCAD")
EndIf

RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ QIPGNSC2     ³ Cicero Odilio Cruz        ³ Data ³22/10/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica caso haja integracao se os campos da Ordem de Pro-³±±
±±³          ³ ducao estão de acordo com o exigido   					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QIPGNSC2()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Intergacao Materias									      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QIPGNSC2()
Local aAreaSB1:=SB1->(GetArea())
Local aAreaSC2:=SC2->(GetArea())

//Verifica se o Produto possui tratamento no Quality
If !Empty(AllTrim(M->C2_PRODUTO)) .AND. SuperGetMV("MV_QIPMAT",.F.,"N") == "S"
	SB1->(dbSetOrder(1))
	If SB1->(dbSeek(xFilial("SB1")+M->C2_PRODUTO))
		If RetFldProd(SB1->B1_COD,"B1_TIPOCQ") == "Q"
			SC2->(DBSetOrder(7))
			If SC2->(dbSeek(xFilial("SC2")+M->C2_PRODUTO))
				If M->C2_NUM < SC2->C2_NUM
					M->C2_NUM := Soma1(SC2->C2_NUM)
					SC2->(DBSetOrder(1))
					While SC2->(dbSeek(xFilial("SC2")+M->C2_NUM))
						M->C2_NUM := Soma1(SC2->C2_NUM)
					EndDo
					Help("",1,"QPXSKLNUMOP   ")//MsgAlert(STR0048) //"Devido ao controle de Skip-Lote do ambiente Inspecao de Processos o numero da Ordem de Producao foi alterado!"
				EndIf
			EndIf
		EndIf
	EndIf
EndIf
RestArea(aAreaSB1)
RestArea(aAreaSC2)
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ QIPGNSH6     ³ Cicero Odilio Cruz        ³ Data ³05/11/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica caso haja integracao se o campo se para apontamen-³±±
±±³          ³ tos parciais o numero do Lote esta preenchido    		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QIPGNSH6()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Intergacao Materias									      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QIPGNSH6()
Local aAreaSH6:=SH6->(GetArea())
Local lIntQIP :=IntQIP(M->H6_PRODUTO,"2")
Local lAponta :=(GetMV("MV_QINSPEC",.T.,"1")=='2')
Local lProdut := Posicione("SB1",1,xFilial("SB1")+M->H6_PRODUTO,"B1_RASTRO")
Local lRet    := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Valida campo chave Inspecao de Processos com Apontamento   |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .AND. lIntQIP .AND. lAponta .AND. !Rastro(M->H6_PRODUTO,"SL")
   
	If Empty(Alltrim(M->H6_LOTECTL)) .AND. SC2->C2_QUANT <> M->H6_QTDPROD .And. M->H6_PT <> "T" //Apontamento Parcial - Requer Lote
		cVarlot := QIPTrataLote(M->H6_PRODUTO,M->H6_LOTECTL,M->H6_NUMLOTE)
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Valida o conteudo informado ja existe  			    	|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SH6->(DBSetOrder(3))
	If lRet .AND. SH6->(dbSeek(xFilial("SH6")+M->H6_PRODUTO+M->H6_OP+M->H6_OPERAC+M->H6_LOTECTL+M->H6_NUMLOTE)) .And. M->H6_PT <> "T" .And. Rastro(M->H6_PRODUTO) .And. lProdut == "S"
		MsgAlert(STR0050) //"O Lote informado ja existe para esta Ordem de Producao, indique outro Lote!"
	   	lRet := .F.
	EndIf
ElseIf lRet .AND. lIntQIP .AND. lAponta .AND. !Empty(Alltrim(M->H6_LOTECTL))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Valida o conteudo informado ja existe  			    	|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SH6->(DBSetOrder(3))
	If lRet .AND. SH6->(dbSeek(xFilial("SH6")+M->H6_PRODUTO+M->H6_OP+M->H6_OPERAC+M->H6_LOTECTL+M->H6_NUMLOTE)) .AND. IsInCallStack('A680Altera')==.F.
		MsgAlert(STR0050) //"O Lote informado ja existe para esta Ordem de Producao, indique outro Lote!"
	   	lRet := .F.
	EndIf
EndIf
RestArea(aAreaSH6)
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} QIPTrataLote()
description Função para tratar lote 
@author  thiago.rover
@since   24/05/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Static Function QIPTrataLote( cProduto, cLote, cSubLote )
	
	Local nTamLote := TamSx3("H6_LOTECTL")[1]+TamSx3("H6_NUMLOTE")[1]
	Local cRetorno := " "                                   

		//Trata o Numero do Lote sequencialmente, caso o produto possua Rastreabilidade
		If GetMV('MV_PRXLOTE', .T.) .AND. Rastro(cProduto,"L")  
			cSubLote := " "
		EndIf

		//Gera o Numero Sequencial para o Lote sem o controle da Rastreabilidade
		If Empty(cLote) .And. Empty(cSubLote)          
			If !Rastro(cProduto)
				cLote := QIPNumLote(cProduto)     
			EndIf
		EndIf

	//Retira os espacos em branco do Numero do Lote
	cRetorno := PadR(AllTrim(cLote)+AllTrim(cSubLote),nTamLote) 

	// Caso o sublote esteja zerado gero um  novo  numero de lote
	If GetMV('MV_PRXLOTE', .T.) .AND. Rastro(cProduto,"L") .AND. AllTrim(FunName()) == "MATA340" 
		cRetorno := PadR(NextLote(cProduto,"L"),nTamLote)
	EndIf


Return cRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc} QIPNUMLOTE
Função de numeção de lote
@author  thiago.rover
@since   24/05/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Function QIPNumLote(cProduto)
Local aAreaAnt := GetArea()
Local cLoteCtl := " "
Local cNumLote := " "
                    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Compatibiliza a Numeracao Sequencial do Lote com Materiais           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//Sequencia do Sub-Lote
cNumLote := If(cNumLote==NIL,NextLote(cProduto,"S"),If(Empty(cNumLote),NextLote(cProduto,"S"),cNumLote))

//Sequencia do Lote
cLoteCtl := If(Empty(cLoteCtl),NextLote(cProduto,"L",cNumLote),cLoteCtl)
cLoteCtl := If(Empty(cLoteCtl),"AUTO"+cNumLote,cLoteCtl)

RestArea(aAreaAnt)

Return(cLoteCtl)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QIPCompSG2  ³ Autor ³ Cicero Odilio Cruz    ³Data³17/09/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao especifica para compatibilizacao da QQK com a SG2.  ³±±
±±³          ³ NAO RECOMENDAR O USO DESTA FUNCAO AO CLIENTE SEM FALAR COM ³±±
±±³          ³ O RESPONSAVEL PELO QUALITY                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QIPCompSG2()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Integracao QIP x PCP                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QIPCSG2()
// NAO RECOMENDAR O USO DESTA FUNCAO AO CLIENTE SEM FALAR COM O RESPONSAVEL PELO QUALITY
Local wnrel    		:= "QIPCSG2"													// Nome do Relatorio
Local cString  		:= "SG2" 														// Tabela Analisada
Local cDesc1   		:= OemToAnsi(STR0052) 											// "Neste relat¢rio ser„o relacionadas as inconsis"
Local cDesc2   		:= OemToAnsi(STR0053) 		 									// "tencias entre as Tabelas SG2 e QQK."
Local cDesc3   		:= ""															// 3 Linha de descricao do Relatorio
Local aDados   		:= {}															// Log de Inconsistencias
Local cAlias		:= ""															// Arquivo Temporario
Local lSimul 		:= .F.															// Indica Simulacao de Compatibilizacao

Private cTitulo   	:= OemToAnsi(STR0054)	//"Relatorio de Ocorrencias da Compatibilizacao"
Private cTamanho  	:= "M"  														// Tamanho do Realtorio
Private cPerg     	:= " "                                   						// Pergunte
Private aReturn   	:= {"Zebrado", 1,"Administracao", 1, 2, 1, "",1 } 		   		//"Zebrado" ### "Administracao"
Private cNomeProg 	:= "QIPCSG2"   											   		// Nome do Programa
Private lPrioMat  	:= (GetMv("MV_QIPOPEP",.F.,"2") == "1") 						//Prioriza dados do Roteiro/Operacoes de 1 = Materiais / 2 - Quality

If ApMsgNoYes(STR0055) // "Deseja executar somente uma Simulacao"
	lSimul 		:= .T.
Endif

If lPrioMat .AND. ApMsgNoYes( 	STR0056+CHR(13)+;		// "ANTES DA ATUALIZACAO DEVE SER FEITO UM BACKUP DOS DICIONARIOS E BASE DE"
             				  	STR0057+CHR(13)+CHR(13)+; // "DADOS."													   				// "DADOS."
			 					STR0058+CHR(13)+;   	// "Esta rotina ira executar a compatibilizacao da tabela Roteiros/Operacoes do "
             					STR0059+CHR(13)+;  			// "ambiente de Inspecao de Processos e tomando como base a sua tabela de"
             					STR0060+CHR(13)+CHR(13)+;	// "Roteiros/Operacoes do ambiente Planejamento e Controle de Producao.     "
                                STR0061) 																// "DESEJA INICIAR O PROCESSO ?"
	DbSelectArea("QQK")
	DbSetOrder(1)
	DbSelectArea("SG2")
	DbSetOrder(1)
	DbGotop()

	Processa({|| QIPCSG2G1( @aDados, lSimul )},OemToAnsi(STR0062),OemToAnsi(STR0063),.F.) //"Processando"###"Validando Dados..."

	cAlias := GetNextAlias()

	// VERIFICO ALGUMA OCORRENCIA NA QQK QUE NAO EXISTE NA SG2
	BeginSql Alias cAlias

	SELECT 	QQK_PRODUT, QQK_REVIPR, QQK_CODIGO, QQK_OPERAC, QQK_RECURS, G2_RECURSO
	FROM 	QQK010 QQK
	LEFT JOIN 	SG2010 SG2 ON QQK.QQK_PRODUT = SG2.G2_PRODUTO AND
				QQK.QQK_REVIPR =  SG2.G2_REVIPRD AND
				QQK.QQK_CODIGO =  SG2.G2_CODIGO  AND
				QQK.QQK_OPERAC =  SG2.G2_OPERAC  AND
				QQK.QQK_RECURS =  SG2.G2_RECURSO AND
	       		SG2.D_E_L_E_T_ = ' '
	WHERE 		QQK.D_E_L_E_T_ <> '*' AND
	      		SG2.G2_RECURSO IS NULL
	ORDER BY QQK_PRODUT, QQK_REVIPR, QQK_CODIGO, QQK_OPERAC, QQK_RECURS

	EndSql

	While (cAlias)->(!Eof())
        If QIPUltRevSG2((cAlias)->QQK_PRODUT) == (cAlias)->QQK_REVIPR
			If ASCAN(aDados,{|x| (cAlias)->QQK_PRODUT+(cAlias)->QQK_REVIPR+(cAlias)->QQK_CODIGO+(cAlias)->QQK_OPERAC $ x[1]+x[2]+x[3]+x[4]}) == 0
				aAdd(aDados,{(cAlias)->QQK_PRODUT,(cAlias)->QQK_REVIPR,(cAlias)->QQK_CODIGO,(cAlias)->QQK_OPERAC,"002 - Roteiro/Operacao de Producao Nao Cadastrado no SG2"})
			EndIf
		EndIf
		&(cAlias)->(dbSkip())
	EndDo

	aSort(aDados,,,{|x,y| y[5]+y[1]+y[2]+y[3]+y[4]>x[5]+x[1]+x[2]+x[3]+x[4]})

	wnrel := SetPrint(cString,wnrel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,cTamanho,,,,,.F.)

	If nLastKey == 27
		Set Filter To
		Return
	Endif

	SetDefault(aReturn,cString)

	RptStatus({|lEnd| QIPCSG2I(@lEnd,wnrel,cString,aDados)},cTitulo)

EndIf


Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QIPCSG2G1   ³ Autor ³ Cicero Odilio Cruz    ³Data³ 26/09/07³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao especifica para compatibilizacao da QQK com a SG2.  ³±±
±±³          ³ NAO RECOMENDAR O USO DESTA FUNCAO AO CLIENTE SEM FALAR COM ³±±
±±³          ³ O RESPONSAVEL PELO QUALITY                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QIPCSG2G()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Integracao QIP x PCP                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QIPCSG2G1( aDados , lSimul )
Local cRevisao 		:= "00"		// Revisao Incial
Local aStruSG2 		:= FWFormStruct(3, "SG2")[3]
Local nX
Local cCampoAux 	:= ""
Default lSimul 		:= .F.		// Indica Simulacao de Compatibilizacao

ProcRegua(SG2->(RecCount()))
Begin Transaction
While SG2->(!Eof())
	//Retorna a ultima revisao do Produto
	cRevisao := QA_UltRevEsp(SG2->G2_PRODUTO,,.F.,,"QIP")
	If Empty(AllTrim(cRevisao))
		cRevisao := Iif(Empty(AllTrim(SG2->G2_REVIPRD)),"00",SG2->G2_REVIPRD)
	EndIf
    If QQK->(dbSeek(xFilial("QQK")+SG2->(G2_PRODUTO+cRevisao+G2_CODIGO+G2_OPERAC)))

		// B - COMENTAR PARA  RODAR NA  ALLPLAS
		If xFilial("SG2") <> xFilial("QQK")
			SG2->(dbSkip())
			IncProc()
            Loop
        EndIf
		//FIM

		If QQK->QQK_RECURS <> SG2->G2_RECURSO  .OR. QQK->QQK_HOROTI <> SG2->G2_HOROTIM .OR.;
		   QQK->QQK_FERRAM <> SG2->G2_FERRAM   .OR. QQK->QQK_LINHAP <> SG2->G2_LINHAPR .OR.;
		   QQK->QQK_TPLINH <> SG2->G2_TPLINHA  .OR. QQK->QQK_DESCRI <> SG2->G2_DESCRI  .OR.;
		   QQK->QQK_MAOOBR <> SG2->G2_MAOOBRA  .OR. QQK->QQK_SETUP  <> SG2->G2_SETUP   .OR.;
		   QQK->QQK_FORMST <> SG2->G2_FORMSTP  .OR. QQK->QQK_LOTEPA <> SG2->G2_LOTEPAD .OR.;
		   QQK->QQK_TEMPAD <> SG2->G2_TEMPAD   .OR. QQK->QQK_TPOPER <> SG2->G2_TPOPER  .OR.;
		   QQK->QQK_TPSOBR <> SG2->G2_TPSOBRE  .OR. QQK->QQK_TEMPSO <> SG2->G2_TEMPSOB .OR.;
		   QQK->QQK_TPDESD <> SG2->G2_TPDESD   .OR. QQK->QQK_TEMPDE <> SG2->G2_TEMPDES .OR.;
		   QQK->QQK_DESPRO <> SG2->G2_DESPROP  .OR. QQK->QQK_CTRAB  <> SG2->G2_CTRAB   .OR.;
		   QQK->QQK_ROTALT <> SG2->G2_ROTALT   .OR. QQK->QQK_OPERGR <> SG2->G2_OPERGRP .OR.;
		   QQK->QQK_GRSETU <> SG2->G2_GRSETUP  .OR. QQK->QQK_GRUPRE <> SG2->G2_GRUPREC .OR.;
		   QQK->QQK_NIVMON <> SG2->G2_NIVMONT  .OR. QQK->QQK_CHAVMO <> SG2->G2_CHAVMON .OR.;
		   QQK->QQK_TMAXPR <> SG2->G2_TMAXPRO  .OR. QQK->QQK_TPINTE <> SG2->G2_TPINTER .OR.;
		   QQK->QQK_MAXINC <> SG2->G2_MAXINCR  .OR. QQK->QQK_FOLMIN <> SG2->G2_FOLMIN

			If !lSimul

				RecLock("QQK",.F.)
				QQK->QQK_RECURS := SG2->G2_RECURSO
				QQK->QQK_FERRAM := SG2->G2_FERRAM
				QQK->QQK_LINHAP := SG2->G2_LINHAPR
				QQK->QQK_TPLINH := SG2->G2_TPLINHA
				QQK->QQK_DESCRI := SG2->G2_DESCRI
				QQK->QQK_MAOOBR := SG2->G2_MAOOBRA
				QQK->QQK_SETUP  := SG2->G2_SETUP
				QQK->QQK_FORMST := SG2->G2_FORMSTP
				QQK->QQK_LOTEPA := SG2->G2_LOTEPAD
				QQK->QQK_TEMPAD := SG2->G2_TEMPAD
				QQK->QQK_TPOPER := SG2->G2_TPOPER
				QQK->QQK_TPSOBR := SG2->G2_TPSOBRE
				QQK->QQK_TEMPSO := SG2->G2_TEMPSOB
				QQK->QQK_TPDESD := SG2->G2_TPDESD
				QQK->QQK_TEMPDE := SG2->G2_TEMPDES
				QQK->QQK_DESPRO  := SG2->G2_DESPROP
				QQK->QQK_CTRAB   := SG2->G2_CTRAB
				QQK->QQK_ROTALT  := SG2->G2_ROTALT
				QQK->QQK_OPERGR  := SG2->G2_OPERGRP
				QQK->QQK_GRSETU  := SG2->G2_GRSETUP
				QQK->QQK_GRUPRE  := SG2->G2_GRUPREC
				QQK->QQK_NIVMON  := SG2->G2_NIVMONT
				QQK->QQK_CHAVMO  := SG2->G2_CHAVMON
				QQK->QQK_TMAXPR  := SG2->G2_TMAXPRO
				QQK->QQK_TPINTE  := SG2->G2_TPINTER
				QQK->QQK_MAXINC  := SG2->G2_MAXINCR
				QQK->QQK_FOLMIN  := SG2->G2_FOLMIN
				QQK->QQK_HOROTI  := SG2->G2_HOROTIM

				MsUnLock()


				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Copia dos campos de usuario 							     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nX := 1 To Len(aStruSG2)
					If GetSx3Cache(aStruSG2[nX,1], "X3_PROPRI") == "U" .And. GetSx3Cache(aStruSG2[nX,1], "X3_CONTEXT") <> "V"
						//Verifica se o campo existe no SG2
						cCampoAux := AllTrim("QQK_" + Substr(aStruSG2[nX,1], At("_", aStruSG2[nX,1])+1, (Len(aStruSG2[nX,1])-At("_", aStruSG2[nX,1]))))
						If !Empty(GetSX3Cache(cCampoAux,"X3_CAMPO"))
							RecLock("QQK",.F.)
							QQK->(FieldPut(FieldPos(cCampoAux),&("SG2->"+Alltrim(aStruSG2[nX,1]))))
							MsUnlock()
						EndIf
					EndIf
				Next nX
			Else
	   			If ASCAN(aDados,{|x| QQK->QQK_PRODUT+cRevisao $ x[1]+x[2]}) == 0
					aAdd(aDados,{QQK->QQK_PRODUT,cRevisao,SG2->G2_CODIGO,SG2->G2_OPERAC,"003 - Campos inconsistentes com SG2"})
				EndIf
			EndIf
		EndIf
	Else
        If QIPUltRevSG2(SG2->G2_PRODUTO) == cRevisao
			aAdd(aDados,{SG2->G2_PRODUTO,cRevisao,SG2->G2_CODIGO,SG2->G2_OPERAC,"001 - Roteiro/Operacao de Producao Nao Cadastrado no QQK"})
		EndIf
	EndIf
	SG2->(dbSkip())
	IncProc()
EndDo
End Transaction
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QIPCSG2I    ³ Autor ³ Cicero Odilio Cruz    ³Data³ 26/09/07³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao especifica para compatibilizacao da QQK com a SG2.  ³±±
±±³          ³ NAO RECOMENDAR O USO DESTA FUNCAO AO CLIENTE SEM FALAR COM ³±±
±±³          ³ O RESPONSAVEL PELO QUALITY                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QIPCompSG2()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Integracao QIP x PCP                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QIPCSG2I( lEnd, wnrel, cString, aDados )
Local cbTxt   := Space(10)
Local cbCont  := 0
Local nTipo   := If(aReturn[4]==1,15,18)
Local cCabec1 := " "
Local cCabec2 := " "
Local nX 	  := 0
Local nTot    := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime as entradas inconsistentes 							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//          1         2         3         4         5         6         7         8         9        10
//Produto        Rev Roteiro Operacao  Codigo-Descricao Inconsistencia
cCabec1 := STR0064 //"Produto        Rev Roteiro Operacao  Codigo-Descricao Inconsistencia                                 "
cCabec2 := " "
Li      := 80
m_Pag   := 01
Cabec(STR0065,cCabec1,cCabec2,cNomeProg,cTamanho,nTipo,,.F.) //"Inconsistencias compatibilizacao SG2 x QQK "
Li++

For nX := 1 to Len(aDados)
	If lEnd
		@PROW()+1,001 PSAY STR0066 //"CANCELADO PELO OPERADOR"
		Exit
	Endif

	If nX > 1
		If !(aDados[nX][5] == aDados[nX-1][5])
			Li++
			Li++
		    @ Li,000 PSAY STR0067+str(nTot) //"Inconsistencias compatibilizacao SG2 x QQK "
			Li++
			Li++
		    nTot:=0
		EndIf
    EndIf

	nTot++

	If nX == 1 .OR. aDados[nX][1]+aDados[nX][2] <> aDados[nX-1][1]+aDados[nX-1][2]
		@ Li,000 PSAY aDados[nX][1]
		@ Li,015 PSAY aDados[nX][2]
	EndIf

	@ Li,019 PSAY aDados[nX][3]
	@ Li,027 PSAY aDados[nX][4]
	@ Li,037 PSAY aDados[nX][5]
	Li++

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressao do Cabecalho										 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Li > 58
		Cabec(STR0065,cCabec1,cCabec2,cNomeProg,cTamanho,nTipo,,.F.) //"Inconsistencias compatibilizacao SG2 x QQK "
		Li++
	Endif
Next

Li++
@ Li,000 PSAY STR0067+str(nTot)
Li++


If Li != 80
	Roda(cbCont,cbTxt)
EndIf

Set device to Screen
If aReturn[5] == 1
	Set Printer To
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QIPUltRevSG2³ Autor ³ Cicero Odilio Cruz    ³Data³ 26/09/07³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao especifica para compatibilizacao da QQK com a SG2.  ³±±
±±³          ³ NAO RECOMENDAR O USO DESTA FUNCAO AO CLIENTE SEM FALAR COM ³±±
±±³          ³ O RESPONSAVEL PELO QUALITY                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QIPUltRevSG2()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Integracao QIP x PCP                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QIPUltRevSG2(cProduto)
//ATENCAO ANALISTA PARA A ULTIMA REVISAO VIGENTE USE A QA_UltRevEsp
Local aAreaAnt     := GetArea()
Local cRevisao 	   := "  "

dbSelectArea("SG2")
dbSetOrder(1)
If dbSeek(xFilial("SG2")+cProduto)
	While SG2->(!Eof()) .AND. xFilial("SG2") == xFilial("QQK") // B - COMENTAR PARA  RODAR NA  ALLPLAS
		If !Empty(AllTrim(SG2->G2_REVIPRD)) .AND. cRevisao <= SG2->G2_REVIPRD
			cRevisao := SG2->G2_REVIPRD // O SG2 guarda a ultima revisao utilizada numa especificacao
		EndIf
		SG2->(dbSkip())
	EndDo
EndIf

RestArea(aAreaAnt)
Return(cRevisao)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ QIPDefRotPr  ³ Cicero Odilio Cruz        ³ Data ³28/01/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica caso haja integracao se o roteiro primario existe ³±±
±±³          ³ caso não exista define o primeiro roteiro como primario.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QIPDefRotPr()											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Integracao Materias									      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QIPDefRotPr(cProduto, cRevisao, cRotPri, lVerif)
Local aAreaSG2 := SG2->(GetArea())
Local aAreaSH6 := SH6->(GetArea())
Local aAreaQP6 := QP6->(GetArea())
Local aAreaQQK := QQK->(GetArea())

Default lVerif := .F.
Default cRotPri := ''
Default cRevisao := ''
Default cProduto := ''

If cRotPri == Nil
	dbSelectArea("QP6")
	DBSetOrder(1)
	If dbSeek(xFilial("QP6")+cProduto)
		cRotPri := QP6->QP6_CODREC
		If Empty(AllTrim(cRevisao))
			cRevisao := QP6->QP6_REVI
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso não encontre  o Roteiro Primario, pego o primeiro roteiro da especificação e o torno primario.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QQK->(DBSetOrder(1))
If !QQK->(dbSeek(xFilial("QQK")+cProduto+cRevisao+cRotPri))
	If lVerif //Caso nao encontre o roteiro
		Return .F.
	EndIf
	QQK->(DbGoTop())
	If QQK->(dbSeek(xFilial("QQK")+cProduto+cRevisao))
		If QP6->(dbSeek(xFilial("QP6")+cProduto+Inverte(cRevisao)))
			Reclock("QP6",.F.)
			QP6->QP6_CODREC := QQK->QQK_CODIGO
			MsUnlock()
		EndIf
    ElseIf INCLUI
   		If QP6->(dbSeek(xFilial("QP6")+cProduto+Inverte(cRevisao)))
			Reclock("QP6",.F.)
			QP6->QP6_CODREC := SG2->G2_CODIGO
	   		MsUnlock()
		EndIf
    EndIf
Else
	If lVerif //Caso encontre o roteiro
		Return .T.
	EndIf
EndIf

RestArea(aAreaSG2)
RestArea(aAreaSH6)
RestArea(aAreaQP6)
RestArea(aAreaQQK)
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ QIPValDOpr   ³ Cicero Odilio Cruz        ³ Data ³28/01/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica caso haja integracao se todas as operacoes do     ³±±
±±³          ³ cadastro de Operacoes no ambiente PCP estão deletadas      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QIPValDOpr()											      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Integracao Materias									      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QIPValDOpr(cProduto, cRot, aCols, nPosDel)
Local lRet 		:= .T.
Local nIt  		:= 0
Local nTot 		:= 0
Local nContRot  := 0
Local cRotPri 	:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifico se o roteiro informado é o Primario³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbSelectArea("QP6")
DBSetOrder(1) // Indice com Revisao Invertida
If dbSeek(xFilial("QP6")+cProduto)
	cRotPri := QP6->QP6_CODREC
    If cRot == cRotPri

		If ValType(aCols) == 'A'
			For nIt := 1 To Len(aCols)
				If aCols[nIt, nPosDel]
					nTot ++
				Endif
			Next nIt

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifico se existem outros  roteiros para esta  especificação³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nContRot := QPCountRot(cProduto, Nil, "SG2")
			If nContRot > 1
				If Len(aCols) == nTot
					lRet := MsgYesNo(STR0068,STR0009)//"Este roteiro esta identificado como 'Roteiro Primario' no ambiente Inspecao de Processos, caso seja excluido, o proximo roteiro da especificação será definido como 'Roteiro Primario'. Deseja continuar S/N ?"###"Atencao"
				EndIf
			ElseIf nContRot == 1
				If Len(aCols) == nTot
					lRet := MsgYesNo(STR0069,STR0009) //"Este roteiro esta identificado como 'Roteiro Primario' no ambiente Inspeção de Processos, esta especificação possui somente um roteiro, caso seja excluido a especificação será bloqueada. Deseja Continuar S/N?"###"Atencao"
				EndIf
			EndIf
		Else
			nContRot := QPCountRot(cProduto, Nil, "SG2")
			If nContRot > 1
				lRet := MsgYesNo(STR0068,STR0009) //"Este roteiro esta identificado como 'Roteiro Primario' no ambiente Inspecao de Processos, caso seja excluido, o proximo roteiro da especificação será definido como 'Roteiro Primario'. Deseja continuar S/N ?"###"Atencao"
			ElseIf nContRot == 1
				Help( , , 'STR0087', ,STR0087, 1, 0 ) //"Não é possível excluir este roteiro pois ele está vinculado a uma especificação no ambiente Inspeção de Processos."
				lRet := .F.
			EndIf
		EndIf
    EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ QPCountRot   ³ Cicero Odilio Cruz        ³ Data ³28/01/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Conto o numero de roteiros na SG2                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPCountRot()		   								          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Integracao Materias									      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QPCountRot( cProduto, cRevisao, cAlias )
Local 	aAreaSG2 := SG2->(GetArea())
Local 	aAreaQQK := QQK->(GetArea())
Local 	nRot     := 0
Local   cRoteiro := ""

Default cRevisao := ""
Default cAlias := "SG2"

If cAlias == "SG2"
	dbSelectArea("SG2")
	dbSetOrder(1)
	dbSeek(xFilial("SG2")+cProduto)
	While !Eof() .AND. SG2->G2_FILIAL==xFilial("SG2") .AND. SG2->G2_PRODUTO == cProduto

	 	If SG2->G2_CODIGO != cRoteiro
	 		nRot++
	 		cRoteiro := SG2->G2_CODIGO
	 	EndIf

		dbSelectArea("SG2")
		dbSkip()

	EndDo
EndIf

If cAlias == "QQK"
	dbSelectArea("QQK")
	dbSetOrder(1)
	dbSeek(xFilial("QQK")+cProduto+cRevisao)

	While !Eof() .AND. QQK->QQK_FILIAL == xFilial("QQK") .And.;
		  QQK->(QQK_PRODUT+QQK_REVIPR) == (cProduto+cRevisao)

	 	If QQK->QQK_CODIGO != cRoteiro
	 		nRot++
	 		cRoteiro := QQK->QQK_CODIGO
	 	EndIf

		dbSelectArea("QQK")
		dbSkip()

	EndDo
EndIf

RestArea(aAreaQQK)
RestArea(aAreaSG2)
Return nRot

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³QIPXChkEns ³ Autor ³ Sergio S. Fuzinaka   ³ Data ³ 15.04.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Verifica se todos Roteiro + Operacao + Ensaios (Origem),    ³±±
±±³          ³existem no Roteiro + Operacao + Ensaios (Destino).          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QIPXChkEns(cProd, cRev, cRotD, cOperD)

Local aArea	:= GetArea()
Local lRet	:= .T.
Local nI	:= 0
Local aEns7	:= {}
Local aEns8	:= {}
Local cRot	:= MV_PAR01		//Roteiro Origem
Local cOper	:= MV_PAR02		//Operacao Origem

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega todos os Ensaios Origem             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QP7")
dbSetOrder(1)
If dbSeek(xFilial("QP7")+cProd+cRev+cRot+cOper)
	While !EOF() .And. xFilial("QP7")+cProd+cRev+cRot+cOper == QP7->(QP7_FILIAL+QP7_PRODUT+QP7_REVI+QP7_CODREC+QP7_OPERAC)
		If MV_PAR03 <= QP7->QP7_ENSAIO .AND. MV_PAR04 >= QP7->QP7_ENSAIO
			AADD(aEns7,{QP7->QP7_ENSAIO})
		Endif
		dbSkip()
	EndDo
Endif

dbSelectArea("QP8")
dbSetOrder(1)
If dbSeek(xFilial("QP8")+cProd+cRev+cRot+cOper)
	While !EOF() .And. xFilial("QP8")+cProd+cRev+cRot+cOper == QP8->(QP8_FILIAL+QP8_PRODUT+QP8_REVI+QP8_CODREC+QP8_OPERAC)
		If MV_PAR03 <= QP8->QP8_ENSAIO .AND. MV_PAR04 >= QP8->QP8_ENSAIO
			AADD(aEns8,{QP8->QP8_ENSAIO})
		Endif
		dbSkip()
	EndDo
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe no Destino               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aEns7) > 0
	For nI := 1 To Len(aEns7)
		dbSelectArea("QP7")
		dbSetOrder(1)
		If !dbSeek(xFilial("QP7")+cProd+cRev+cRotD+cOperD+aEns7[nI,1])
			lRet := .F.
			Exit
		Else
			If !( cRotD+"/"+cOperD $ cRotOper )
				cRotOper  += IIf(Empty(cRotOper),""," - ")+cRotD+"/"+cOperD
			Endif
		Endif
	Next
Endif

If lRet .And. Len(aEns8) > 0
	For nI := 1 To Len(aEns8)
		dbSelectArea("QP8")
		dbSetOrder(1)
		If !dbSeek(xFilial("QP8")+cProd+cRev+cRotD+cOperD+aEns8[nI,1])
			lRet := .F.
			Exit
		Endif
	Next
Endif

RestArea(aArea)

Return( lRet )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QAtuB12QP6    ³ Sergio S. Fuzinaka        ³ Data ³ 14.07.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Atualizacao dos dados do produto da tabela QP6 pela SB1.    ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³GENERICO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QAtuB12QP6()

Local aArea		:= GetArea()
Local aAreaQP6	:= QP6->(GetArea())
Local cProduto	:= SB1->B1_COD		//Produto Origem
Local cUnidade	:= SB1->B1_UM		//Unidade do Produto
Local cRevisao	:= ""				//Revisao Origem
Local cRoteiro	:= ""				//Roteiro Primario

QP6->(dbSetOrder(1))	//Indice de Revisao Invertida
If QP6->(dbSeek(xFilial("QP6")+cProduto))

	If QP6->QP6_UNMED1 <> cUnidade

		cRevisao := QP6->QP6_REVI
		cRoteiro := QIPROTPADR(cProduto)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se gera nova revisao                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If QipRevEsp(cProduto,cRevisao,cRoteiro)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gera Nova Revisao                                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			QIPCriaEspec(cProduto,cRevisao,cRoteiro)
			QP6->(dbSetOrder(1))	//Indice de Revisao Invertida
			QP6->(dbSeek(xFilial("QP6")+cProduto))
		Endif

		If QP6->QP6_PRODUT == cProduto
			RecLock("QP6",.F.)
			QP6->QP6_UNMED1 := cUnidade
			QP6->QP6_UNAMO1 := cUnidade
			MsUnlock()
		Endif

		If SB1->B1_UM <> cUnidade
			RecLock("SB1",.F.)
			SB1->B1_UM := cUnidade
			MsUnlock()
		Endif

	Endif

Endif

RestArea(aAreaQP6)
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AjCargaQPF³ Autor ³ Sergio S. Fuzinaka	³ Data ³ 16.07.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Efetua o ajuste na carga na tabela QPF - Skip-Lote.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGAQIP		                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AjCargaQPF()

Local aArea 	:= GetArea()
Local aAreaQPF	:= QPF->(GetArea())
Local aVetSkip	:= {}
Local nLoop		:= 0

If __LANGUAGE == "SPANISH"

	Aadd(aVetSkip, {"01","Controlar todas las Ord. de Prod.    ","Cont.Todas"}) //"Controlar todas as Ord. de Prod.   "
	Aadd(aVetSkip, {"02","Controla  1 de cada   2 Ord. de Prod.","1/2 O.P.  "}) //"Controla  1 a cada  2 Ord.Prod.    "
	Aadd(aVetSkip, {"03","Controla  1 de cada   3 Ord. de Prod.","1/3 O.P.  "}) //"Controla  1 a cada  3 Ord.Prod.    "
	Aadd(aVetSkip, {"04","Controla  1 de cada   4 Ord. de Prod.","1/4 O.P.  "}) //"Controla  1 a cada  4 Ord.Prod.    "
	Aadd(aVetSkip, {"05","Controla  1 de cada   5 Ord. de Prod.","1/5 O.P.  "}) //"Controla  1 a cada  5 Ord.Prod.    "
	Aadd(aVetSkip, {"06","Controla  1 de cada   7 Ord. de Prod.","1/7 O.P.  "}) //"Controla  1 a cada  7 Ord.Prod.    "
	Aadd(aVetSkip, {"07","Controla  1 de cada  10 Ord. de Prod.","1/10 O.P. "}) //"Controla  1 a cada 10 Ord.Prod.    "
	Aadd(aVetSkip, {"08","Controla  1 de cada  15 Ord. de Prod.","1/15 O.P. "}) //"Controla  1 a cada 15 Ord.Prod.    "
	Aadd(aVetSkip, {"09","Controla  1 de cada  20 Ord. de Prod.","1/20 O.P. "}) //"Controla  1 a cada 20 Ord.Prod.    "
	Aadd(aVetSkip, {"10","Controla  1 de cada  30 Ord. de Prod.","1/30 O.P. "}) //"Controla  1 a cada 30 Ord.Prod.    "
	Aadd(aVetSkip, {"11","Controla  1 de cada  40 Ord. de Prod.","1/40 O.P. "}) //"Controla  1 a cada 40 Ord.Prod.    "
	Aadd(aVetSkip, {"12","Controla  1 de cada  50 Ord. de Prod.","1/50 O.P. "}) //"Controla  1 a cada 50 Ord.Prod.    "
	Aadd(aVetSkip, {"13","Controla  1 de cada  60 Ord. de Prod.","1/60 O.P. "}) //"Controla  1 a cada 60 Ord.Prod.    "
	Aadd(aVetSkip, {"14","Controla  1 de cada  70 Ord. de Prod.","1/70 O.P. "}) //"Controla  1 a cada 70 Ord.Prod.    "
	Aadd(aVetSkip, {"15","Controla  1 de cada  80 Ord. de Prod.","1/80 O.P. "}) //"Controla  1 a cada 80 Ord.Prod.    "
	Aadd(aVetSkip, {"16","Controla  1 de cada  90 Ord. de Prod.","1/90 O.P. "}) //"Controla  1 a cada 90 Ord.Prod.    "
	Aadd(aVetSkip, {"17","Controla  1 de cada 100 Ord. de Prod.","1/100 O.P."}) //"Controla  1 a cada 100 Ord.Prod.   "
	Aadd(aVetSkip, {"18","Controla  1 Ord. de Prod. por dia    ","1 / dia   "}) //"Controla  1 Ord.Prod. por dia      "
	Aadd(aVetSkip, {"19","Controla  1 Ord. de Prod. por semana ","1 / semana"}) //"Controla  1 Ord.Producao por semana"
	Aadd(aVetSkip, {"20","Controla  1 Ord. de Prod. por mes    ","1 / mes   "}) //"Controla  1 Ord.Producao por mes   "
	Aadd(aVetSkip, {"21","Controla  1 Ord. de Prod. por 2 meses","1/2 meses "}) //"Controla  1 Ord.Producao por 2 meses"
	Aadd(aVetSkip, {"22","Controla  1 Ord. de Prod. por 3 meses","1/3 meses "}) //"Controla  1 Ord.Producao por 3 meses"
	Aadd(aVetSkip, {"23","Controla  1 Ord. de Prod. por 4 meses","1/4 meses "}) //"Controla  1 Ord.Producao por 4 meses"
	Aadd(aVetSkip, {"24","Controla  1 Ord. de Prod. por 5 meses","1/5 meses "}) //"Controla  1 Ord.Producao por 5 meses"
	Aadd(aVetSkip, {"25","Controla  1 Ord. de Prod. por 6 meses","1/6 meses "}) //"Controla  1 Ord.Producao por 6 meses"
	Aadd(aVetSkip, {"26","Controla  1 Ord. de Prod. por año    ","1 / año   "}) //"Controla  1 Ord.Producao por ano    "
	Aadd(aVetSkip, {"27","FREE-PASS                            ","FREE-PASS "}) //FREE-PASS

ElseIf __LANGUAGE == "ENGLISH"

	Aadd(aVetSkip, {"01","Control all Prod. Orders             ","Contr. All"}) //"Controlar todas as Ord. de Prod.   "
	Aadd(aVetSkip, {"02","Control  1 every   2 Prod. Order     ","1/2 P.O.  "}) //"Controla  1 a cada  2 Ord.Prod.    "
	Aadd(aVetSkip, {"03","Control  1 every   3 Prod. Order     ","1/3 P.O.  "}) //"Controla  1 a cada  3 Ord.Prod.    "
	Aadd(aVetSkip, {"04","Control  1 every   4 Prod. Order     ","1/4 P.O.  "}) //"Controla  1 a cada  4 Ord.Prod.    "
	Aadd(aVetSkip, {"05","Control  1 every   5 Prod. Order     ","1/5 P.O.  "}) //"Controla  1 a cada  5 Ord.Prod.    "
	Aadd(aVetSkip, {"06","Control  1 every   7 Prod. Order     ","1/7 P.O.  "}) //"Controla  1 a cada  7 Ord.Prod.    "
	Aadd(aVetSkip, {"07","Control  1 every  10 Prod. Order     ","1/10 P.O. "}) //"Controla  1 a cada 10 Ord.Prod.    "
	Aadd(aVetSkip, {"08","Control  1 every  15 Prod. Order     ","1/15 P.O. "}) //"Controla  1 a cada 15 Ord.Prod.    "
	Aadd(aVetSkip, {"09","Control  1 every  20 Prod. Order     ","1/20 P.O. "}) //"Controla  1 a cada 20 Ord.Prod.    "
	Aadd(aVetSkip, {"10","Control  1 every  30 Prod. Order     ","1/30 P.O. "}) //"Controla  1 a cada 30 Ord.Prod.    "
	Aadd(aVetSkip, {"11","Control  1 every  40 Prod. Order     ","1/40 P.O. "}) //"Controla  1 a cada 40 Ord.Prod.    "
	Aadd(aVetSkip, {"12","Control  1 every  50 Prod. Order     ","1/50 P.O. "}) //"Controla  1 a cada 50 Ord.Prod.    "
	Aadd(aVetSkip, {"13","Control  1 every  60 Prod. Order     ","1/60 P.O. "}) //"Controla  1 a cada 60 Ord.Prod.    "
	Aadd(aVetSkip, {"14","Control  1 every  70 Prod. Order     ","1/70 P.O. "}) //"Controla  1 a cada 70 Ord.Prod.    "
	Aadd(aVetSkip, {"15","Control  1 every  80 Prod. Order     ","1/80 P.O. "}) //"Controla  1 a cada 80 Ord.Prod.    "
	Aadd(aVetSkip, {"16","Control  1 every  90 Prod. Order     ","1/90 P.O. "}) //"Controla  1 a cada 90 Ord.Prod.    "
	Aadd(aVetSkip, {"17","Control  1 every 100 Prod. Order     ","1/100 P.O."}) //"Controla  1 a cada 100 Ord.Prod.   "
	Aadd(aVetSkip, {"18","Control  1 Prod. Ord. per day        ","1 / day   "}) //"Controla  1 Ord.Prod. por dia      "
	Aadd(aVetSkip, {"19","Control  1 Prod. Order per week      ","1 / week  "}) //"Controla  1 Ord.Producao por semana"
	Aadd(aVetSkip, {"20","Control  1 Prod. Order per month     ","1 / month "}) //"Controla  1 Ord.Producao por mes   "
	Aadd(aVetSkip, {"21","Control  1 Prod. Order every 2 months","1/2 months"}) //"Controla  1 Ord.Producao por 2 meses"
	Aadd(aVetSkip, {"22","Control  1 Prod. Order every 3 months","1/3 months"}) //"Controla  1 Ord.Producao por 3 meses"
	Aadd(aVetSkip, {"23","Control  1 Prod. Order every 4 months","1/4 months"}) //"Controla  1 Ord.Producao por 4 meses"
	Aadd(aVetSkip, {"24","Control  1 Prod. Order every 5 months","1/5 months"}) //"Controla  1 Ord.Producao por 5 meses"
	Aadd(aVetSkip, {"25","Control  1 Prod. Order every 6 months","1/6 months"}) //"Controla  1 Ord.Producao por 6 meses"
	Aadd(aVetSkip, {"26","Control  1 Prod. Order per year      ","1 / year  "}) //"Controla  1 Ord.Producao por ano    "
	Aadd(aVetSkip, {"27","FREE-PASS                            ","FREE-PASS "}) //FREE-PASS

Endif

If __LANGUAGE == "SPANISH" .Or. __LANGUAGE == "ENGLISH"

	dbSelectArea("QPF")
	dbSetOrder(1)
	For nLoop := 1 To Len(aVetSkip)

		If dbSeek(xFilial("QPF")+aVetSkip[nLoop][1])
			RecLock("QPF",.F.)
			QPF->QPF_DESCRI	:= aVetSkip[nLoop,2]
			QPF->QPF_DESRES	:= aVetSkip[nLoop,3]
			If __LANGUAGE == "SPANISH"
				QPF->QPF_DESCSP	:= aVetSkip[nLoop,2]
				QPF->QPF_DESRSP	:= aVetSkip[nLoop,3]
			Else
				QPF->QPF_DESCEN	:= aVetSkip[nLoop,2]
				QPF->QPF_DESREN	:= aVetSkip[nLoop,3]
			Endif
			MsUnLock()
		Endif

	Next

Endif

RestArea( aAreaQPF )
RestArea( aArea )

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ QIPSG2   ºAutor  ³Iolanda Vilanova    º Data ³  01/29/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Valida a alteração da ordem de operação quando esta        º±±
±±º          ³  possuir especificacao (QQK)                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA630                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QIPSG2()
Local aAreaQQK := QQK->(GetArea())
Local cIntQP   := GetMV("MV_QIPMAT",.F.,"N")
Local nPosOper := aScan(aHeader, {|x| AllTrim(x[2]) == "G2_OPERAC"})
Local cProcura := aCols[n,nPosOper]
Local lRet     := .T.

QQK->(dbSetOrder(1))

If ALTERA .and. cIntQP == "S" .And. QQK->(dbSeek(xFilial("QQK")+SG2->(G2_PRODUTO+G2_REVIPRD+G2_CODIGO+cProcura)))
	QpAviso(STR0074,STR0073,{"OK"}) //"Não é possível alterar a ordem da Operação, pois existe(m) Especificações relacionados a ele."###"Integração PCPxQIP"
	lRet := .F.
Endif

RestArea(aAreaQQK)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ QPCarta  ³ Autor ³ Iolanda Vilanova      ³ Data ³ 18/11/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna a Carta do Ensaio escolhido                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Codigo do Ensaio a pesquisar                        ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1 - Carta do Ensaio                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Generico				                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QPCTIPO(cEnsaio)
Local cCarTipo := ""
QP1->(dbSetOrder(1))

If QP1->(dbSeek(xFilial("QP1")+cEnsaio))
	cCarTipo := QP1->QP1_TIPO
EndIf

Return(cCarTipo)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QGRVLogQIPºAutor  ³Cicero Cruz         º Data ³  12/11/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Grava novos Dados                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QGRVLGQIP(nOption, aLog, cOpera, cLabi, cEnsAtual, nOPE, nLAB, nENS)
Local lLayout	 	:= GetMv("MV_QPTRLAY",.F.,"1") == "1"					// Variavel que define o Layout Simplificado
Local cAlias 	 	:= Alias()      										// Variavel que contem o Alias Posicionado
Local cLogFile 	 	:= "QLY_" + Subs(CriaTrab('',.F.),3,6) + '.LOG'		// Variavel que contem o nome do Arquivo de LOG
Local nLogHdl	 	:= 0													// Variavel que contem o Handle do arquivo
Local cString    	:= ""													// Variavel que contem os dados que devem ser enviados
Local nX 		 	:= 1		 											// Variavel para Varrer os Logs
Local nY 		 	:= 1		 											// Variavel para Varrer os Logs
Local nW 		 	:= 1		 											// Variavel para Varrer os Logs
Local nZ 		 	:= 1		 											// Variavel para Varrer os Logs
Local nCall      	:= 1													// Variavel para o Call Stacks
Local cProduto   	:= SC2->C2_PRODUTO                                   	// Armazena o Código de Produto
Local cRevi      	:= SC2->C2_REVI                                      	// Armazena a Revisão do Produto
Local cOP		 	:= SC2->C2_NUM											// Armazena o numero da OP
Local cRoteiro   	:= Iif(Empty(SC2->C2_ROTEIRO),"01",SC2->C2_ROTEIRO)	// Armazena o roteiro de Especificação
Local aArea 	 	:= GetArea()    										// Armazena a Area utilizada
Local aAreaQPR   	:= QPR->(GetArea())									// Armazena a Area utilizada QPR
Local aAreaQPQ   	:= QPQ->(GetArea())									// Armazena a Area utilizada QPQ
Local aAreaQPS   	:= QPS->(GetArea())									// Armazena a Area utilizada QPS
Local cVal 		 	:= ""													// Variavel onde é montada alinha do log
Local cCarta	 	:= ""   												// Carta do Ensaio
Local nPosChvQPR 	:= 0 													// Variavel que define onde o campo Chave esta na  Get Dados

If lLayout
	nPosOper   := nOperacao                                             // Compatibilização com o QIPA215
	nPosLab    := nFldLab												// Compatibilização com o QIPA215
	nPosEns    := nEnsaio												// Compatibilização com o QIPA215
EndIf

//If ValType(aLog) == "A"
//  	nOption    := 2
//EndIf

Default cOpera     	:= aResultados[nPosOper, 1]                         	// Operação Atual
Default cLabi      	:= aResultados[nPosOper, 2, nPosLab]                	// Laboratório Atual
Default cEnsAtual  	:= aResultados[nPosOper, 3, nPosLab, nPosEns, 2]   	// Ensaio Atual
Default aLog       	:= {}                                              		// aLog contendo as informações uteis para o Log, que pode ser preenchido previamente
Default nOption    	:= 1													// Opção de geração do
Default nOPE        := nPosOper												// Posição Operação Desejada
Default nLAB        := nPosLab												// Posição Laboratório Desejada
Default nENS		:= nPosEns												// Posição Ensaio Desejado

cCarta	   := aResultados[nPosOper, 3, nPosLab, nPosEns, 4]
nPosChvQPR := Ascan(aSavHeadEns[nPosOper,nPosLab,nPosEns,1], {|x|AllTrim(x[2])=="QPR_CHAVE"})

If nOption != 3
	If File(cLogFile)
		nLogHdl := fOpen(cLogFile, 2+64)
		fSeek(nLogHdl, 0, 2)
		cString := _CRLF + _CRLF
	Else
		nLogHdl := MsfCreate(cLogFile)
			cString := OemToAnsi("Log da Rotina QIPA216") + " " + cLogFile + _CRLF + _CRLF
	EndIf


	cString += OemToAnsi("Erro ocorrido em: ") + DtoC(dDataBase) + OemToAnsi(", as ")  + Time() + _CRLF + _CRLF
	cString += OemToAnsi("Lista de Chamadas: ") + _CRLF

	Do While !Empty(ProcName(nCall))
		cString += 'Called from ' + AllTrim(ProcName(nCall)) + '(' + AllTrim(Str(ProcLine(nCall))) + ')' + _CRLF
		nCall ++
	EndDo

	cString += _CRLF
	cString += OemToAnsi("Usuario      : ") + AllTrim(CUSERNAME) + _CRLF + _CRLF
	cString += OemToAnsi("Tabela Posicionada: ") + cAlias    + _CRLF + _CRLF
	cString += OemToAnsi("Produto      :") + AllTrim(cProduto) + _CRLF + _CRLF
	cString += OemToAnsi("Revisao      :") + AllTrim(cRevi)    + _CRLF + _CRLF
	cString += OemToAnsi("Roteiro      :") + AllTrim(cRoteiro) + _CRLF + _CRLF
	cString += OemToAnsi("Operação     :") + AllTrim(cOpera)   + _CRLF + _CRLF
	cString += OemToAnsi("Laboratório  :") + AllTrim(cLabi)    + _CRLF + _CRLF
	cString += OemToAnsi("Ensaio       :") + AllTrim(cEnsAtual)+ _CRLF + _CRLF
	cString += OemToAnsi("Carta        :") + AllTrim(cCarta)   + _CRLF + _CRLF
	cString += OemToAnsi("-------- Auditoria dos Parametros Especificos Cliente ----------") + _CRLF + _CRLF
	cString += OemToAnsi("MV_QPTRLAY -> ") + GetMv("MV_QPTRLAY",.F.,"1") + _CRLF + _CRLF
	cString += OemToAnsi("MV_QPVMDEL -> ") + GetMv("MV_QPVMDEL",.F.,"2") + _CRLF + _CRLF
	cString += OemToAnsi("MV_QPIESMD -> ") + GetMv("MV_QPIESMD",.F.,"2") + _CRLF + _CRLF
	cString += OemToAnsi("MV_QPSLFSO -> ") + GetMv("MV_QPSLFSO",.F.,"2") + _CRLF + _CRLF
	cString += OemToAnsi("MV_QINTQMT -> ") + GetMv("MV_QINTQMT")         + _CRLF + _CRLF
	cString += OemToAnsi("MV_QPINAUT -> ") + GetMv("MV_QPINAUT")         + _CRLF + _CRLF
	cString += OemToAnsi("MV_QPINSOB -> ") + GetMv("MV_QPINSOB")         + _CRLF + _CRLF
	cString += OemToAnsi("MV_QINOBFM -> ") + GetMV("MV_QINOBFM",.T.,"2") + _CRLF + _CRLF
	cString += OemToAnsi("MV_QINVLTX -> ") + Iif(Valtype(cMV_QINVLTX) == "C", GetMV("MV_QINVLTX",.T.,"2"), cValToChar(GetMV("MV_QINVLTX",.T.,2))) + _CRLF + _CRLF
	cString += OemToAnsi("MV_QINVTOT -> ") + GetMv("MV_QINVTOT",.T.,"2") + _CRLF + _CRLF
	cString += OemToAnsi("MV_QPCAROT -> ") + GetMv("MV_QPCAROT",.F.,"1") + _CRLF + _CRLF
	cString += OemToAnsi("MV_QPCPROP -> ") + GetMv("MV_QPCPROP",.F.,"1") + _CRLF + _CRLF
	cString += OemToAnsi("MV_QPVLIN  -> ") + GetMv("MV_QPVLIN") 		 + _CRLF + _CRLF
	cString += OemToAnsi("MV_QVLDTHR -> ") + GetMv("MV_QVLDTHR",.T.,"1") + _CRLF + _CRLF
	cString += OemToAnsi("----------------------------------------------------------------") + _CRLF + _CRLF
	cString += If(Len(aLog)>1, OemToAnsi("Ocorrências (")    + AllTrim(Str(Len(aLog))) + ') : ', OemToAnsi("Ocorrência: ")) + _CRLF
EndIf

Do Case
	Case nOption == 1   // Opção de Log para avaliar os dados de carga dos objetos
		// Tabela QPR/QPQ/QPS
		aColsQPR := QP215FILMED(cRoteiro,cOpera,cLabi,cEnsAtual,cCarta)
	 	aAdd(aLog,"Medicoes:")
		For nX := 1 To Len(aColsQPR)
			cVal := ""
			If nX == 1
				aAdd(aLog,"Analise das Tabelas QPR/QPQ/QPS")
			EndIf
			For nY := 1 To Len(aColsQPR[1])

				If ValType(aColsQPR[nX][nY]) == "C"
					cVal += aColsQPR[nX][nY] + _TAB
				ElseIf ValType(aColsQPR[nX][nY]) == "N"
					cVal += Str(aColsQPR[nX][nY]) + _TAB
				ElseIf ValType(aColsQPR[nX][nY]) == "L"
					cVal += If(aColsQPR[nX][nY], ".T.", ".F.") + _TAB
				ElseIf ValType(aColsQPR[nX][nY]) == "D"
				    cVal += DToC(aColsQPR[nX][nY]) + _TAB
				EndIf
			Next
			aAdd(aLog, cVal)
		    aColsNCs := Q215FilCol(aSavaHeader[1],"QPU",1,aColsQPR[nX][nPosChvQPR],"QPU_CODMED",Len(aSavaHeader[1]))
			cVal := "          NCs Associadas:"
			For nW := 1 To Len(aColsNCs)
				For nZ := 1 To Len(aColsNCs[1])
					// cVal := "Coluna "+ STR(nY) + " -> "
					If ValType(aColsNCs[nW][nZ]) == "C"
						cVal += aColsNCs[nW][nZ] + _TAB
					ElseIf ValType(aColsNCs[nW][nZ]) == "N"
						cVal += Str(aColsNCs[nW][nZ]) + _TAB
					ElseIf ValType(aColsNCs[nW][nZ]) == "L"
						cVal += Iif(aColsNCs[nW][nZ], ".T.", ".F.") + _TAB
					ElseIf ValType(aColsNCs[nW][nZ]) == "D"
					    cVal += DToC(aColsNCs[nW][nZ]) + _TAB
					EndIf
				Next
				aAdd(aLog, cVal)
				cVal := "                         "
			Next
		    aColsIns := Q215FilCol(aSavaHeader[2],"QPT",1,aColsQPR[nX][nPosChvQPR],"QPT_CODMED",Len(aSavaHeader[2]))
			cVal := "          Inst Associados:"
			For nW := 1 To Len(aColsIns)
				For nZ := 1 To Len(aColsIns[1])
					// cVal := "Coluna "+ STR(nY) + " -> "
		  			If ValType(aColsIns[nW][nZ]) == "C"
						cVal += aColsIns[nW][nZ] + _TAB
					ElseIf ValType(aColsIns[nW][nZ]) == "N"
						cVal += Str(aColsIns[nW][nZ]) + _TAB
					ElseIf ValType(aColsIns[nW][nZ]) == "L"
						cVal += Iif(aColsIns[nW][nZ], ".T.", ".F.") + _TAB
					ElseIf ValType(aColsIns[nW][nZ]) == "D"
					    cVal += DToC(aColsIns[nW][nZ]) + _TAB
					EndIf
				Next
				aAdd(aLog, cVal)
				cVal := "                          "
			Next
		Next
	Case nOption == 2 // Não executa operação alguma  soemente imprime o aLog
		// Tabela QPR/QPQ/QPS
		aColsQPR := QP215FILMED(cRoteiro,cOpera,cLabi,cEnsAtual,cCarta)
		For nX := 1 To Len(aColsQPR)
			cVal := ""
			If nX == 1
				aAdd(aLog,"Analise das Tabelas QPR/QPQ/QPS")
			EndIf
			For nY := 1 To Len(aColsQPR[1])

				If ValType(aColsQPR[nX][nY]) == "C"
					cVal += aColsQPR[nX][nY] + _TAB
				ElseIf ValType(aColsQPR[nX][nY]) == "N"
					cVal += Str(aColsQPR[nX][nY]) + _TAB
				ElseIf ValType(aColsQPR[nX][nY]) == "L"
					cVal += If(aColsQPR[nX][nY], ".T.", ".F.") + _TAB
				ElseIf ValType(aColsQPR[nX][nY]) == "D"
				    cVal += DToC(aColsQPR[nX][nY]) + _TAB
				EndIf
			Next
			aAdd(aLog, cVal)
			cVal := "                          "
		Next
	Case nOption == 3 // Dados Atuais
		// Tabela QPR/QPQ/QPS
		aColsQPR := aClone(aResultados[nOPE,4,nLAB,nENS])
		For nX := 1 To Len(aColsQPR)
			cVal := ""
			If nX == 1
				aAdd(aLog,"Medições - Analise do (aResultados) - Ensaio: "+aResultados[nOPE, 3, nLAB, nENS, 2])
			EndIf
			For nY := 1 To Len(aColsQPR[1])
				If ValType(aColsQPR[nX][nY]) == "C"
					cVal += aColsQPR[nX][nY] + _TAB
				ElseIf ValType(aColsQPR[nX][nY]) == "N"
					cVal += Str(aColsQPR[nX][nY]) + _TAB
				ElseIf ValType(aColsQPR[nX][nY]) == "L"
					cVal += If(aColsQPR[nX][nY], ".T.", ".F.") + _TAB
				ElseIf ValType(aColsQPR[nX][nY]) == "D"
				    cVal += DToC(aColsQPR[nX][nY]) + _TAB
				EndIf
			Next
			aAdd(aLog, cVal)
			cVal := "                          "
		Next
EndCase

If nOption != 3
	For nX := 1 to Len(aLog)
		cString += aLog[nX] + _CRLF + If(nX==Len(aLog),_CRLF,'')
	Next nX

	If !fWrite(nLogHdl, cString, Len(cString)) < Len(cString)
		If !fClose(nLogHdl)
		EndIf
	EndIf
Endif

// Envio dos dados por e-mail
If ExistBlock('QLOGMOV')
	ExecBlock('QLOGMOV', .F., .F., {{ cLogFile, cOP, cRoteiro }})
EndIf

fClose(nLogHdl)
fErase(cLogFile)

RestArea(aAreaQPR)
RestArea(aAreaQPQ)
RestArea(aAreaQPS)
RestArea(aArea)
Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³QPAcesso  ³ Autor ³ Sandra Ribeiro Claudio³Data  ³ 21.01.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Função para apresentacao da tela com o log de assinaturas   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QIPA215, QIPA216      									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QPAcesso(cOP)

Local aSign		:= {}
Local nOrdQAA   := QAA->(IndexOrd())

Default cOP     := " "

DbSelectArea("QQL")
QQL->(DbSetOrder(2))

If !QQL->(DbSeek(xFilial("QQL") + cOp))
	MsgAlert (STR0075)    //   "Não existem laudos definidos para esta OP"
	Return .F.
Else

	While QQL->(!Eof()) .AND. QQL->QQL_FILIAL == xFilial("QQL") .AND. QQL->QQL_OP == cOP

		Aadd( aSign, { xFilial("QQL"),QPK->QPK_OP,QQL->QQL_OPERAC, QQL->QQL_LAB, QQL->QQL_RESP, QQL->QQL_DATA, QQL->QQL_HORA, QQL->QQL_LAUDO} )

		QQL->(DbSkip())
	Enddo

EndIf

QAA->(DbSetOrder(nOrdQAA))

DEFINE MSDIALOG oDlgAss FROM	001,001 TO 240,422 TITLE OemToAnsi(STR0076) PIXEL //"Assinatura Eletronica"

oBrwAss := TWBrowse():New( 1, 1, 209, 98,{|| { " "," "," "," "," " }},;
	{STR0077,STR0078,STR0081,STR0079,STR0080,STR0086}, ; //"Operacao"###"Laboratorio"###"Responsavel"###"Data"###"Hora"###"Laudo"
	{28,30,90,25,15} , ;
	oDlgAss, , , , , , , , , , , , , , .T., , , , , )

oBrwAss:lMChange := .F.
oBrwAss:nClrBackFocus := GetSysColor( 13 )
oBrwAss:nClrForeFocus := GetSysColor( 14 )
oBrwAss:SetArray(aSign)

oBrwAss:bLine	   	:= { || { aSign[oBrwAss:nAt,3], aSign[oBrwAss:nAt,4],aSign[oBrwAss:nAt,5],aSign[oBrwAss:nAt,6],aSign[oBrwAss:nAt,7],aSign[oBrwAss:nAt,8] } }
oBrwAss:bLDblClick 	:= { || oDlgAss:End()}

DEFINE SBUTTON FROM 105,170 TYPE 1 ENABLE OF oDlgAss ACTION oDlgAss:End()

ACTIVATE MSDIALOG oDlgAss CENTERED

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³QPNivLab  ³ Autor ³ Sandra Ribeiro Claudio³Data  ³ 15.01.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Função para verificação se o usuário possui núvel necesário ³±±
±±³			 ³para emitir o laudo do laboratório 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QIPA215, QIPA216      									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QPNivLab(cOP, cDescLab, cOpera, nOpcA, oDlg)

Local cNivLau  := GetNewPar("MV_QPLDNIV","000")

Local cNivLab		:= Substr(cNivLau,1,1)
Local nOrdQAA		:= QAA->(IndexOrd())
Local lPerm			:= .F.
Local lRet 			:= .T.

DbSelectArea("QAA")
DbSetOrder(6)

If QAA->(DbSeek(Upper(cUserName)))
	cNivUsu := QAA->QAA_NIVEL

	If cNivUsu >= cNivLab
 		lPerm := .T.
	EndIf
Else
	Alert(STR0082)   				  //"Usuário logado não possui login no cadastro de usuários."
	lTeLAbr := .F.
	lRet	:= .F.
EndIf

If lLayout
	If !lPerm
		Alert(STR0083)
		aOBJETOS[OBJ_MEDICA,nOperacao,nFldLab,nEnsaio]:oBrowse:SetFocus()
		lRet := .F.
	EndIf
Else
	If lAltWind .AND. lRetLOK .AND. lTeLAbr .AND. lCPrimOP
		lTeLAbr  := .F.
		lNoAbrT  := .T.
		If  lPerm
			QipLauLab(nOpcA, Nil, oDlg)
			lNoAbrT := .F.
		Else
			Alert(STR0083)    		  //"Usuário não tem permissão para emitir o Laudo de Laboratório."
			lTeLAbr :=.T.
			SetFocus(aObjGet[Eval(bGetoGet)]:oBrowse:hWnd)
			aObjGet[Eval(bGetoGet)]:oBrowse:Refresh()
		EndIf

	ElseIf lCPrimOP
		lTeLAbr:=.T.
	 	If ValType(aObjGet[Eval(bGetoGet)]) == "O"
			SetFocus(aObjGet[Eval(bGetoGet)]:oBrowse:hWnd)
			aObjGet[Eval(bGetoGet)]:oBrowse:Refresh()
		EndIf
		lNoAbrT := .T.
	EndIf
EndIf


QAA->(DbSetOrder(nOrdQAA))

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³QPNivOpe  ³ Autor ³ Sandra Ribeiro Claudio³Data  ³ 15.01.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Função para verificação se o usuário possui núvel necesário ³±±
±±³			 ³para emitir o laudo da operação.                  		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QIPA215, QIPA216      									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QPNivOpe(cOP, cOpera, nOpcA)

Local cNivLau  := GetNewPar("MV_QPLDNIV","000")

Local cNivOpe := Substr(cNivLau,2,1)
Local nOrdQAA := QAA->(IndexOrd())
Local lPerm	  := .F.
Local lRet	  := .T.

DbSelectArea("QAA")
DbSetOrder(6)

If QAA->(DbSeek(Upper(cUserName)))
	cNivUsu := QAA->QAA_NIVEL

	If cNivUsu >= cNivOpe
 		lPerm := .T.
	EndIf
Else
	Alert(STR0082)    //"Usuário logado não possui login no cadastro de usuários."
	lTeLAbr := .F.
	lRet	:= .F.
EndIf

If lLayout
	If !lPerm
		Alert(STR0084) 					        //"Usuário não tem permissão para emitir o Laudo da Operacao."
		aOBJETOS[OBJ_MEDICA,nOperacao,nFldLab,nEnsaio]:oBrowse:SetFocus()
		lRet := .F.
	EndIf
Else
	If lAltWind .AND. lCPrimOP
		If lPerm
			QipLauOp(nOpcA)
		Else
			Alert(STR0084)						//"Usuário não tem permissão para emitir o Laudo da Operacao."
			lTeLAbr :=.T.
			SetFocus(aObjGet[Eval(bGetoGet)]:oBrowse:hWnd)
			aObjGet[Eval(bGetoGet)]:oBrowse:Refresh()
			lRet	:= .F.
		EndIf

	ElseIf lCPrimOP
		SetFocus(aObjGet[Eval(bGetoGet)]:oBrowse:hWnd)
		aObjGet[Eval(bGetoGet)]:oBrowse:Refresh()
	EndIf
Endif

QAA->(DbSetOrder(nOrdQAA))

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³QPNivGer  ³ Autor ³ Sandra Ribeiro Claudio³Data  ³ 15.01.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Função para verificação se o usuário possui núvel necesário ³±±
±±³			 ³para emitir o laudo da operação.                  		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QIPA215, QIPA216      									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QPNivGer(cOP,nOpcA)

Local cNivLau  := GetNewPar("MV_QPLDNIV","000")

Local cNivGer := Substr(cNivLau,3,1)
Local nOrdQAA := QAA->(IndexOrd())
Local lPerm	  := .F.
Local lRet	  := .T.

DbSelectArea("QAA")
DbSetOrder(6)

If QAA->(DbSeek(Upper(cUserName)))
	cNivUsu := QAA->QAA_NIVEL

	If cNivUsu >= cNivGer
 		lPerm := .T.
	EndIf
Else
	Alert(STR0082)     //"Usuário logado não possui login no cadastro de usuários."
	lTeLAbr := .F.
	lRet	:= .F.
EndIf

If lLayout

	If !lPerm
		Alert(STR0085) 					//"Usuário não tem permissão para emitir o Laudo da Operacao."
		aOBJETOS[OBJ_MEDICA,nOperacao,nFldLab,nEnsaio]:oBrowse:SetFocus()
		lRet := .F.
	EndIf

Else
	If lPerm
		QipLaudGer(nOpcA)
	Else
		Alert(STR0085)
		lTeLAbr :=.T.
		SetFocus(aObjGet[Eval(bGetoGet)]:oBrowse:hWnd)
		aObjGet[Eval(bGetoGet)]:oBrowse:Refresh()
		lRet := .F.
	EndIf
Endif



QAA->(DbSetOrder(nOrdQAA))

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³QPInsOPInt³ Autor ³ Paulo Fco. Cruz Nt.	³ Data ³ 23.06.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se inspeciona OPs intermediarias					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Alias da tabela posicionada						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1 - .T. = Inspeciona / .F. = Nao Inspeciona			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGAQIP													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QPInsOPInt(cAlias)
Local lRet		:= .T.
Local lQPOPINT	:= GetMV("MV_QPOPINT",.F.,.T.)
Local nTamSeq	:= TamSX3("C2_SEQUEN")[1]
Local nTamSH6	:= Len(SH6->H6_OP) - TamSX3("C2_ITEMGRD")[1] - nTamSeq + 1
Local cSeqPai	:= StrZero(1,nTamSeq)

Default cAlias	:= ""

If !lQPOPINT
	If cAlias == "SC2"
		lRet := If(SC2->C2_SEQUEN == cSeqPai,.T.,.F.)
	ElseIf cAlias == "SH6"
		lRet := If(SubStr(SH6->H6_OP,nTamSH6,nTamSeq) == cSeqPai,.T.,.F.)
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³SB1PrBlQ  ³ Autor ³ Rafael Duram Santos	³ Data ³ 19.08.11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se o produto esta bloqueado no cadastro (B1_MSBLQL)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cCodProduto - Codigo do produto a ser verificado			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lRetorno - .T. = Sem bloqueio / .F. = Bloqueado			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGAQIP													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SB1PrBlq(cCodProduto)

Local lRetorno 	:= .T.
Local aArea		:= GetArea()
Local aAreaSB1	:= SB1->(GetArea())

DbSelectArea("SB1")
SB1->(DbSetOrder(1))
SB1->( DbSeek( xFilial("SB1") + cCodProduto ) )

If !RegistroOK("SB1")
	lRetorno := .F.
Endif

RestArea(aArea)
RestArea(aAreaSB1)

Return lRetorno

/*/{Protheus.doc} QIPChkEspOP
//TODO Verifica na revisao informada do grupo de produto se existe Ordem de produção para os produtos
@author reynaldo
@since 18/09/2017
@version 1.0
@param cGrpPrd, characters, Código do Codigo ou Grupo de Produto
@param cRevGrpPrd, characters, código da revisão do produto ou grupo de produto
@param lGrupo, logical, .T. pesquisa por grupo de produto/ .F. Pesquisa por produto
@param cRoteiro, characters, Código do Roteiro da Ordem de Producao
@param nOpc, numeric, Operacao da rotina (inclusao,alteracao,exclusao)
@type function
/*/
Function QIPChkEspOP(cGrpPrd,cRevGrpPrd,lGrupo,cRoteiro,nOpc)
Local aAreaAnt := GetArea()
Local lRetorno := .T.

Default cRoteiro := ''

lGrupo := If(lGrupo==NIL,.F.,lGrupo)

If nOpc <> 2
	If lGrupo

		BeginSql Alias "TMPQPA"
			select SC2.C2_REVI
			from %Table:QPA% QPA
			inner join %Table:QQC% QQC on QQC.QQC_FILIAL = %xFilial:QQC%
				and QQC.QQC_GRUPO = QPA.QPA_GRUPO
				and QQC.%NotDel%
			inner join %Table:QP6% QP6 on QP6.QP6_FILIAL = %xFilial:QP6%
				and QP6.QP6_GRUPO = QQC.QQC_GRUPO
				and QP6.QP6_REVIGR = QQC.QQC_REVI
				and QP6.QP6_PRODUT = QPA.QPA_PRODUT
				and QP6.%NotDel%
			inner join %Table:SC2% SC2 on SC2.C2_FILIAL = %xFilial:SC2%
				and SC2.C2_PRODUTO = QP6.QP6_PRODUT
				and SC2.C2_REVI = QP6.QP6_REVI
				and SC2.%NotDel%
			where QPA.QPA_FILIAL = %xFilial:QPA%
				and QPA.QPA_GRUPO = %Exp:cGrpPrd%
				and QPA.%NotDel%
				and QQC.QQC_REVI = %Exp:cRevGrpPrd%
		EndSql

		If !TMPQPA->(Eof()) .AND. !Empty(TMPQPA->C2_REVI)
			HELP(" ",1,"QPCHKGRPRV") //A especificacao do Grupo de produtos  nao podera ser alterada ou excluida.
			lRetorno := .F.
		EndIf

		TMPQPA->(dbCloseArea())

	Else
		If !Empty(cRoteiro)
			BeginSql Alias "TMPSC2"

			SELECT *
			FROM %Table:SC2% SC2
			WHERE SC2.C2_FILIAL = %xFilial:SC2% AND
				SC2.C2_PRODUTO = %Exp:cGrpPrd% AND
				SC2.C2_REVI = %Exp:cRevGrpPrd% AND
				SC2.C2_ROTEIRO = %Exp:cRoteiro% AND
				SC2.%NotDel%

			EndSql

			If TMPSC2->(!Eof())
				lRetorno := .F.
			EndIf

			TMPSC2->(dbCloseArea())
		Else
			SC2->(dbSetOrder(8))
			SC2->(dbSeek(xFilial("SC2")+cGrpPrd+cRevGrpPrd))
			If SC2->(!Eof()) .and. !Empty(cGrpPrd) .And. !Empty(cRevGrpPrd)
			   lRetorno := .F.
		   EndIf
		EndIf

	EndIf
EndIf

RestArea(aAreaAnt)
Return(lRetorno) 


/*/{Protheus.doc} QIPValInst
	Função de validação da consulta padrão 
	@type  Function
	@author user
	@since 30/07/2019
	@version version
/*/
Function QIPValInst()

	Local lRet 		:= .T.

	If !GetMv("MV_QIPQMT") == "S"
		lRet := .F.
	Endif
	
Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} QIPROTPADR 
Retorna o roteiro padrão do produto
@author Marcos Wagner Jr
@since 06/02/2020
@version 1.0
@return cRotPad - Roteiro Padrão
/*/
//---------------------------------------------------------------------- 
Function QIPROTPADR(cProduto)
Local cRotPad := '01'
Local aOldSB1 := SB1->(GetArea())

dbSelectArea("SB1")
dbSetOrder(1)
If dbSeek(xFilial("SB1")+cProduto) .AND. !Empty(SB1->B1_OPERPAD)
	cRotPad := SB1->B1_OPERPAD
EndIf

RestArea(aOldSB1)

Return cRotPad

//----------------------------------------------------------------------
/*/{Protheus.doc} QIPSELCPRO 
Retorna os produtos para realizar integração via apontamento ou OP
@author Thiago Henrique Rover
@since 07/12/2020
@version 1.0
@return Produtos 
/*/
//---------------------------------------------------------------------- 
Function QIPSELCPRO(cProduto, cRevi, cAlias)
Local cAliasQry := GetNextAlias()
Local cQry      := ""

cQry := " SELECT * "
cQry += " FROM "+ RetSqlName(cAlias) +" "+ cAlias
cQry += " WHERE "
If cAlias == "SC2"
	cQry += "     C2_FILIAL  = '"+ FwxFilial(cAlias) +" '"
	cQry += " AND C2_PRODUTO = '" + cProduto           +" '"
	cQry += " AND C2_REVI = '" + cRevi           +" '"
Else 
	cQry += "     H6_FILIAL  = '"+ FwxFilial(cAlias) +" '"
	cQry += " AND H6_PRODUTO = '" + cProduto           +" '"
	cQry += " AND H6_REVI = '" + cRevi           +" '"
Endif
cQry += " AND D_E_L_E_T_ <> '*' "
cQry := ChangeQuery( cQry )	
dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )	

Return cAliasQry

/*/{Protheus.doc} fGravSG2
Função responsável pela atualização do campo G2_CHAVE e do campo QQK_CHAVE
@type  Static Function
@author thiago.rover
@since 25/06/2021
@see (links_or_references)
/*/
Static Function fGravSG2()

Local nProximo := QA_SXESXF("QQK","QQK_CHAVE",,2)

RecLock("SG2",.F.)
SG2->G2_CHAVE := nProximo
SG2->(MsUnlock())
	
Return nProximo

//----------------------------------------------------------------------
/*/{Protheus.doc} QIPULTREG 
Retorna os produtos do registro mais atual até o ultimo para realizar calculo do Skip-lote 
@author Thiago Henrique Rover
@since 25/102021
@version 1.0
@return Produtos 
/*/
//---------------------------------------------------------------------- 
Function QIPULTREG(cAliasPro,cProduto,cRevi)
Local cAliasQry := GetNextAlias()
Local cQry      := ""

cQry := " SELECT * "
cQry += " FROM "+ RetSqlName(cAliasPro) +" "+ cAliasPro
cQry += " WHERE "
If cAliasPro == "SC2"
	cQry += "     C2_FILIAL  = '"+ FwxFilial(cAliasPro) +" '"
	cQry += " AND C2_PRODUTO = '" + cProduto           +" '"
	cQry += " AND C2_REVI = '" + cRevi           +" '"
Else 
	cQry += "     H6_FILIAL  = '"+ FwxFilial(cAliasPro) +" '"
	cQry += " AND H6_PRODUTO = '" + cProduto           +" '"
	cQry += " AND H6_REVI = '" + cRevi           +" '"
Endif
cQry += " AND D_E_L_E_T_ <> '*' "
cQry += " ORDER BY R_E_C_N_O_ DESC"
cQry := ChangeQuery( cQry )	
dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )	

Return cAliasQry

/*/{Protheus.doc} QIPExisEsp
Verifica se o grupo de especificaçao de produtos possui operações e ensaios
@type Function
@author rafael.kleestadt
@since 29/03/2022
@version 1.0
@param cCodGrp, caracter, Código do grupo selecionado para gerar revisão
@param cRevGrpPrd, caracter, Revisão destino do grupo para gerar revisão
@return lRet, Lógico, se verdadeiro o grupo/revisão já possui operação e ensaio
@example
(examples)
@see (links_or_references)
/*/
Function QIPExisEsp(cCodGrp, cRevGrpPrd)
Local aAreas   := {GetArea(), QQK->(GetArea()), QP6->(GetArea()), QP7->(GetArea()), QP8->(GetArea())}
Local cFilQP6  := xFilial("QP6")
Local cFilQP7  := xFilial("QP7")
Local cFilQP8  := xFilial("QP8")
Local cFilQQK  := xFilial("QQK")
Local lRet     := .F.
Local lTemEns  := .F.
Local lTemOper := .F.

//Histórico dos produtos
DbSelectArea("QP6")
QP6->(dbSetOrder(4)) //Grupo+Revisao Grupo
If QP6->(dbSeek(cFilQP6+cCodGrp+cRevGrpPrd))

	//Especificações das Operações
	DbSelectArea("QQK")
	QQK->(dbSetOrder(1)) //QQK_FILIAL+QQK_PRODUT+QQK_REVIPR+QQK_CODIGO+QQK_OPERAC

	//Ensaios mensuraveis
	DbSelectArea("QP7")
	QP7->(dbSetOrder(1)) //QP7_FILIAL+QP7_PRODUT+QP7_REVI+QP7_CODREC+QP7_OPERAC+QP7_ENSAIO

	//Ensaios Textos dos Produtos
	DbSelectArea("QP8")
	QP8->(dbSetOrder(1)) //QP8_FILIAL+QP8_PRODUT+QP8_REVI+QP8_CODREC+QP8_OPERAC+QP8_ENSAIO

	While QP6->(!Eof()) .And. QP6->(QP6_FILIAL+QP6_GRUPO+QP6_REVIGR) == cFilQP6+cCodGrp+cRevGrpPrd
		
		If QQK->(dbSeek(cFilQQK+QP6->(QP6_PRODUT+QP6_REVI)))
			lTemOper := .T.
		EndIf
		
		If QP7->(dbSeek(cFilQP7+QP6->(QP6_PRODUT+QP6_REVI)))
			lTemEns := .T.
		Else
			If QP8->(dbSeek(cFilQP8+QP6->(QP6_PRODUT+QP6_REVI)))
				lTemEns := .T.
			EndIf
		EndIf
		
		If lTemOper .Or. lTemEns
			lRet := .T.
			EXIT
		EndIf

		QP6->(dbSkip())
	EndDo
	QQK->(DbCloseArea())
	QP8->(DbCloseArea())
	QP7->(DbCloseArea())
EndIf
QP6->(DbCloseArea())

AEval(aAreas, {|x| RestArea(x)})
Return lRet
