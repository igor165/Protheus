#INCLUDE "PROTHEUS.CH"
#INCLUDE "PLSP010.CH"

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁFun┤┘o    ЁPLSP010   Ё Autor Ё Henry Fila            Ё Data Ё 27/04/2007 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤┘o ЁMonta array para Painel de Gestao Tipo 2 Padrao 1: Quantidade Ё╠╠
╠╠Ё          Ёde usuarios incluidos e excluidos no periodo                  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   ЁPLSP010()                                                     Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁRetorno   Ё Array = {{cCombo1,{cText1,cValor,nColorValor,cClick},..},..} Ё╠╠
╠╠Ё          Ё cCombo1     = Detalhes                                       Ё╠╠
╠╠Ё          Ё cText1      = Texto da Coluna                         		Ё╠╠
╠╠Ё          Ё cValor      = Valor a ser exibido (string)                   Ё╠╠
╠╠Ё          Ё nColorValor = Cor do Valor no formato RGB (opcional)         Ё╠╠
╠╠Ё          Ё cClick      = Funcao executada no click do valor (opcional)  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё SIGAMDI                                                      Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Atualizacoes sofridas desde a Construcao Inicial.                       Ё╠╠
╠╠цддддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Programador  Ё Data   Ё BOPS Ё  Motivo da Alteracao                     Ё╠╠
╠╠цддддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё              Ё        Ё      Ё                                          Ё╠╠
╠╠юддддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/


Function PLSP010()

Local aArea       := GetArea()
Local aAreaBA1    := BA1->(GetArea())
Local cAliasBA1   := "BA1"
Local aRet        := {} 
Local cMes        := StrZero(Month(dDataBase),2)
Local cAno        := Substr(DTOC(dDataBase),7,2)
Local dDataIni    := CTOD("01/"+cMes+"/"+cAno)
Local dDataFim    := CTOD(StrZero(F_ULTDIA(dDataBase),2)+"/"+cMes+"/"+cAno)
Local nUsrBlo	  := 0
Local nUsrInc	  := 0
Local nUsrBloMes  := 0
Local nUsrIncMes  := 0

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё                                                                        Ё
//Ё                              D I A R I O                               Ё
//Ё                                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁNumero de pedidos no dia                                                Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cAliasBA1 := GetNextAlias()
BeginSql Alias cAliasBA1
SELECT count(*) NUSRBLO
	FROM %Table:BA1% BA1 
	WHERE BA1_FILIAL = %xFilial:BA1% AND BA1_DATBLO = %Exp:Dtos(dDataBase)% AND BA1.%NotDel% 
EndSql
nUsrBlo := (cAliasBA1)->NUSRBLO
(cAliasBA1)->(DbCloseArea())


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё                                                                        Ё
//Ё                              D I A R I O                               Ё
//Ё                                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁNumero de pedidos no dia                                                Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cAliasBA1 := GetNextAlias()
BeginSql Alias cAliasBA1
SELECT count(*) NUSRINC
	FROM %Table:BA1% BA1 
	WHERE BA1_FILIAL = %xFilial:BA1% AND BA1_DATINC = %Exp:Dtos(dDataBase)% AND BA1.%NotDel% 
EndSql
nUsrInc := (cAliasBA1)->NUSRINC
(cAliasBA1)->(DbCloseArea())


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё                                                                        Ё
//Ё                              M E N S A L                               Ё
//Ё                                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁNumero de usuarios bloqueados no mes                                    Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cAliasBA1 := GetNextAlias()
BeginSql Alias cAliasBA1
SELECT Count(*) NUSRBLOMES 
	FROM %Table:BA1% BA1 
	WHERE BA1_FILIAL = %xFilial:BA1% AND BA1_DATBLO >= %Exp:Dtos(dDataIni)% AND BA1_DATBLO <= %Exp:Dtos(dDataFim)% AND BA1.%NotDel% 
EndSql
nUsrBloMes := (cAliasBA1)->NUSRBLOMES
(cAliasBA1)->(DbCloseArea())


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁNumero de usuarios incluidos no mes                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cAliasBA1 := GetNextAlias()
BeginSql Alias cAliasBA1
SELECT Count(*) NUSRINCMES
	FROM %Table:BA1% BA1 
	WHERE BA1_FILIAL = %xFilial:BA1% AND BA1_DATINC >= %Exp:Dtos(dDataIni)% AND BA1_DATINC <= %Exp:Dtos(dDataFim)% AND BA1.%NotDel% 
EndSql
nUsrIncMes := (cAliasBA1)->NUSRINCMES
(cAliasBA1)->(DbCloseArea())
	

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁPreenche array do Painel de Gestao                                      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Aadd( aRet, { STR0001, { ;																	 
			{ STR0003, Transform(nUsrBlo  ,"@R 999,999,999.99"),CLR_BLUE,{ || } },;	 
			{ STR0004, Transform(nUsrInc  ,"@R 999,999,999.99"),CLR_BLUE,{ || } } } } ) 


Aadd( aRet, { STR0002, { ;																	 
			{ STR0003, Transform(nUsrBloMes  ,"@R 999,999,999.99"),CLR_BLUE,{ || } },;	 
			{ STR0004, Transform(nUsrIncMes  ,"@R 999,999,999.99"),CLR_BLUE,{ || } } } } ) 


                
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁRestaura areas                                                          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
RestArea(aAreaBA1)
RestArea(aArea)


Return aRet
                   