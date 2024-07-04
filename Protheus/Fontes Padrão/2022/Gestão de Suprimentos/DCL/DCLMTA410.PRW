#include "protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ DCLMTA410³ Autor ³ Antonio Codeiro       ³ Data ³JULHO/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Ponto para validacao da digitacao das placas de caminhoes  ³±±
±±³          ³ e codigos de mototistas                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Template Combustiveis Veiculos                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function DCLMTA410()    
Local aArea:=GetArea()
Local lRet:=.T.
Local cMens:=""

If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf

//Devera usar a funcao HasTemplate ao inves de se usar o ChkTemplate. 
//Como esse programa eh um ponto de entrada do pedido de venda padrao, 
//ele sera executado mesmo se o cliente nao possui licença de uso.
//Ex.: Cliente possui 2 empresas, porem compra apenas 1 licenca de template.
//Nesse caso, a empresa que nao possui licenca nao conseguirar executar um pedido
//de venda caso utilize o mesmo RPO da empresa que possui a licenca.
If SuperGetMv("MV_DCLNEW",.F.,.F.) 
//CHKTEMPLATE("DCLVEI")
	DHA->(DBSEEK(XFILIAL('DHA')+M->C5_PLACA1))
	IF DHA->DHA_TIPO =="CV" .AND. EMPTY(M->C5_PLACA2)
	   cMens:=" Se Primeira Placa Informada (Truck/Cavalo)-> Deve existir a Segunda (Carreta)"+CHR(13)
	   lRet:=.F.
	ELSEIF EMPTY(M->C5_PLACA1) .AND. ! EMPTY(M->C5_PLACA2)
	   cMens:=" Se Segunda Placa Informada (Carreta) -> Deve existir a Primeira (Truck/Cavalo)"+CHR(13)
	   lRet:=.F.
	ENDIF
	IF  ! lRet
	    MsgBox(cMens,"Informacao","INFO")
	ENDIF
EndIf	

RestArea(aArea)
Return(lRet)
