/* ===
    Esse � um exemplo disponibilizado no Terminal de Informa��o
    Confira o artigo sobre esse assunto, no seguinte link: https://terminaldeinformacao.com/2015/12/17/vd-advpl-016/
    Caso queira ver outros conte�dos envolvendo AdvPL e TL++, veja em: https://terminaldeinformacao.com/advpl/
=== */

//Bibliotecas
#Include "Protheus.ch"

/*-------------------------------------------------*
 | P.E.:   A010TOK                                 |
 | Autor:  Daniel Atilio                           |
 | Data:   13/12/2015                              |
 | Descr.: Fun��o que valida o cadastro de produto |
 *-------------------------------------------------*/

User Function A010TOK()
	Local aArea := GetArea()
	Local aAreaB1 := SB1->(GetArea())
	Local lRet := .T.
	
	//Mostrando a pergunta
	lRet := MsgYesNo("Confirma o cadastro do <b>"+M->B1_DESC+"</b>?", "Aten��o")
	
	RestArea(aAreaB1)
	RestArea(aArea)
Return lRet